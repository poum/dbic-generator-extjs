package ExtJS::Generator::DBIC;

use Moose;
use namespace::autoclean;
use JSON::DWIW;
use Carp;
use UNIVERSAL::require;
use ExtJS::Generator::DBIC::JsFile;
use ExtJS::Generator::DBIC::TypeTranslator;

#ABSTRACT: ExtJS::Generator::DBIC - ExtJS MVC class generator using DBIx::Class schema

=head1 SYNOPSYS

  use ExtJS::Generator::DBIC;

  my $extjs_generator = ExtJS::Generator::DBIC->new(schema_name => 'My::Schema');

  $extjs_generator->model('Basic');

  # all models in one shot
  $extjs_generator->models();

  $extjs_generator->store('Another');

  # all stores in one shot
  $extjs_generator->stores();

  # all ExtJS artifacts in one shot (models & stores)
  $extjs_generator->mvc();

=cut

=head2 DESCRIPTION

ExtJS::Generator::DBIC try to reuse all the work already done in Perl with DBIx::Class or in SQL with DBIx::Class::Loader 
to (re)generate corresponding ExtJS MVC javascript files. For now, it produces :

=over 4

=item B<the model files> : with typed fields, validations rules, and associations. The DBIx::Class::Schema namespace is reused.

=item B<the store files> : with model and proxy

=back

It handles the already existings ExtJS javascript files, trying to preserve comment and non JSON parts. If an absolute or relative path is given,
files are only looked for in this location. Otherwise try <path>/<type>/<file>, <path>/<file>, ./<type>/<file> and finally ./<file>. 
See L<ExtJS::Generator::DBIC::JsFile>.

=cut


has 'schema_name' => ( 
  is => 'ro',
  isa => 'Str',
  required => 1
);

has 'js_namespace' => (
  is => 'rw',
  isa => 'Str'
);

has 'schema' => ( 
  is => 'rw',
  isa => 'DBIx::Class::Schema'
);

has 'tables' => (is => 'rw');

# not used for now ... TODO
has 'order' => (
  is => 'ro',
  isa => 'HashRef',
  default => sub {

    {
      model => [ qw/extend fields validations associations proxy/ ],
      fields => [ qw/name type defaultValue/ ],
      proxy => [ qw/type api/ ],
    }
  }
);

has 'path' => (
  is => 'rw',
  isa => 'Str',
  default => 'js/app'
);

has 'backup' => (
    is => 'ro',
    isa => 'Bool',
    default => 1
);

# TODO : Better in JsFile
has 'json' => (
  is => 'ro',
  isa => 'JSON::DWIW',
  default => sub { 
    new JSON::DWIW->new({ 
      pretty    => 1, 
      bare_keys => 1,
      convert_bool => 1,
      sort_keys => 1,
      bare_solidus => 1
    }) 
  }
);

# TODO : maybe in specific generator ...
has 'typeTranslator' => (
	is => 'rw',
	isa => 'ExtJS::Generator::DBIC::TypeTranslator'
);

=head2 METHODS

=head2 new

  my$ generator = ExtJS::Generator::DBIC->new(
    schema_name => 'My::Schema',
    js_namespace => 'My.App',
    path => 'public/js/app',
    backup => 1,
  );

=head3 parameters

=over 4

=item B<schema_name> : name of the DBIx::Schema from which the files are to be generated. B<Mandatory>. Should be in @INC. 

=item B<js_namespace> : the JavaScript namespace to use. If not speficied, use schema_name ('My::Extra::Schema' produce 'My.Extra').

=item B<path> : the path where javacript files will be looked for / writed. './js/app' by default.

=item B<backup> : flag to generate a backup before modifying an existing ExtJS javascript file (true by default).

=back

=cut 

# load/store the schema using the name given as parameter
# and initialize the 'tables' array ref 
# create a javascript namespace if necessary
sub BUILD {
  my $self = shift;

  $self->schema_name->require() or croak 'Unable to found/load ' . $self->schema_name . " ($!)";
  
  $self->schema($self->schema_name->connect());

  $self->schema or croak 'Unable to connect to ' . $self->schema_name;

  $self->tables([$self->schema->sources]);
  $self->typeTranslator(new ExtJS::Generator::DBIC::TypeTranslator());

  unless ($self->js_namespace) {
    my $js_namespace = $self->schema_name;
    $js_namespace =~ s/::Schema$//;
    $js_namespace =~ s/::/./g;
    $self->js_namespace($js_namespace);
  }
}

# extjs_model_name

#This method returns the ExtJS model name for a table and can be overridden
#in a subclass.

sub extjs_model_name {
    my ( $self, $tablename ) = @_;
    $tablename = $tablename =~ m/^(?:\w+::)* (\w+)$/x ? $1 : $tablename;
    return ucfirst($tablename);
}

=head3 model

Generate specified ExtJS model (field definition, validation rules, proxy and association). 
If a javascript model file already exists, all other keys are preserved.

If a nullable boolean field is encountered, the corresponding presence validation rule isn't
generated to avoid ExtJS transform the null values into false ones.

=cut
sub model {
  my $self = shift;
  my $name = shift or croak "Model name required ! (didn't you mind 'models' ?)";

  croak "$name doesn't exist !" unless grep /^$name$/, @{$self->tables};

  my $jsFile = new ExtJS::Generator::DBIC::JsFile() or croak $!;

  $jsFile->parse(file => $name, path => $self->path, namespace => $self->js_namespace);
  my $model = $self->json->from_json($jsFile->template());

  $model->{extend} = 'Ext.data.Model' unless exists $model->{extend};
  unless (exists $model->{proxy}) {
    my $url = '/' . lc $name . '/';
    $model->{proxy} = {
      type => 'ajax',
      api => {
        read    => $url . 'read',
        create  => $url . 'create',
        update  => $url . 'update',
        destroy => $url . 'delete'
      }
    };
  }

  my $resultset = $self->schema->source($name); 
  my @columns = $resultset->columns;
  my ($field, $info, @updatedField);
  foreach my $column (@columns) {
    $info = $resultset->column_info($column);

    # the field already exists ?
    @updatedField = grep { $_->{name} eq $column } @{$model->{fields}};
    $field = @updatedField ? $updatedField[0] : { name => $column };
  
    $field->{type} = $self->typeTranslator->translate($info->{data_type});

    if ($info->{default_value}) {
      if ($field->{type} eq 'boolean') {
        $field->{defaultValue} = $info->{default_value} eq 'true' ? JSON::DWIW->true : JSON::DWIW->false;  
      } 
      else {
        $field->{defaultValue} = $info->{default_value}; 
      }
    }
    push @{$model->{fields}}, $field unless @updatedField;

    # the presence validation already exists ?
    @updatedField = grep { $_->{field} eq $column and $_->{type} eq 'presence' } @{$model->{validations}};
    if ($info->{is_nullable}) {
      # suppress presence validation if the field is now nullable
      $updatedField[0] = undef if @updatedField;
    }
    else {
      # add presence validation if it doesn't already exist
      push @{$model->{validations}}, { type => 'presence', field => $column } unless @updatedField;
    }

    # the max size validation already exists ?
    @updatedField = grep { $_->{field} eq $column and $_->{type} eq 'length' and $_->{max} } @{$model->{validations}};
    if ($info->{size} and $field->{type} eq 'string') {
      $field = @updatedField ? $updatedField[0] : { field => $column, type => 'length' };
      $field->{max} = $info->{size};
      push @{$model->{validations}}, $field unless @updatedField;
    }
    else {
      # suppress the validation if it's became useless
      $updatedField[0] = undef if @updatedField; 
    }
  }

  my ($relinfo, $attrs, $modelname, $reltype);
  foreach my $relation ($resultset->relationships()) {
    $relinfo = $resultset->relationship_info($relation);

    carp "\t\tskipping because multi-cond rels aren't supported by ExtJS 4\n" 
        if keys %{ $relinfo->{cond} } > 1;

    my $attrs = $relinfo->{attrs};

    my ($rel_col) = keys %{ $relinfo->{cond} };
    my $our_col = $relinfo->{cond}->{$rel_col};
    $modelname = $self->extjs_model_name( $relinfo->{source} );
    if ($attrs->{is_foreign_key_constraint}
        && (   $attrs->{accessor} eq 'single'
            || $attrs->{accessor} eq 'filter' )
        )
    {
        $reltype = 'belongsTo';
    }

    elsif ( $attrs->{accessor} eq 'single' ) {
        $reltype = 'hasOne';
    }
    elsif ( $attrs->{accessor} eq 'multi' ) {
        $reltype = 'hasMany';
    }
    $rel_col =~ s/^foreign\.//;
    $our_col =~ s/^self\.//;
    @updatedField = grep { $_->{model} eq $modelname and $_->{type} eq $reltype } @{$model->{associations}};
    $field = @updatedField ? $updatedField[0] : { model => $modelname, type => $reltype };
    $field->{associationKey} = $relation;
    $field->{primaryKey} = $rel_col;
    $field->{foreign} = $our_col;
    push @{$model->{associations}}, $field unless @updatedField;
  }

  $jsFile->template($self->json->to_json($model));

  $jsFile->write(backup => $self->backup);

  return $model;
}

=head3 models

Generate all ExtJS models found in the DBIx::Class Schema

=cut
sub models {
  my $self = shift; 
  my @models = ();

  push @models, $self->model($_) foreach @{$self->tables};

  return @models;
}

=head3 store

Generate specified ExtJS store (model and proxy). 
If a javascript store file already exists, all other keys are preserved.

=cut
sub store {
  my $self = shift;
  my $name = shift or croak "Store name required ! (didn't you mind 'stores' ?)";
  croak "$name doesn't exist !" unless grep /^$name$/, @{$self->tables};

  my $jsFile = new ExtJS::Generator::DBIC::JsFile() or croak $!;

  $jsFile->parse(type => 'store', file => $name, path => $self->path, namespace => $self->js_namespace);
  my $store = $self->json->from_json($jsFile->template());

  $store->{extend} = 'Ext.data.Store' unless exists $store->{extend};
  $store->{model} = join '.', $self->js_namespace, 'model', $name unless exists $store->{model};
  unless (exists $store->{proxy}) {
    my $url = '/' . lc $name . '/';
    $store->{proxy} = {
      type => 'ajax',
      url  =>  '/' . lc $name . '/list.json'
    };
  }

  $jsFile->template($self->json->to_json($store));
  $jsFile->write(backup => $self->backup);

  return $store;
}

=head3 stores

Generate ExtJS stores for all models found in the DBIx::Class Schema

=cut
sub stores {
  my $self = shift;
  my @stores = ();

  push @stores, $self->store($_) foreach @{$self->tables()};

  return @stores;
}

=head3 mvc

Generate all ExtJS artifacts for all models found in the DBIx::Class Schema

=cut
sub mvc {
    my $self = shift;
    $self->models();
    $self->stores();
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 TODO

=over 4

=item forms, grids, controllers & mvc global generation function

=item treestore generator

=item controller generator (using template)

=item form generator (combo for associated data)

=item grid / tree generator

=item add backup / stop option if the generated file already exists

=item use extjs main file for finding path to file and namespace

=item use a config file

=item add test for rewriting existing model files 

=item add a script like the DBIx::Class::Loader one

=item make a TypeTranslator for each supported Database

=item SenchaCmd integration ?

=item Add file and script to configure/produce the jsduck documentation

=item Add inclusion, exclusion and format validation rules

=item Extract Model generator in ExtJS::Generator::DBIC::Engine::Model (and Form, Grid, Tree, Controller, Store, etc.)

=item Hide JSON::DWIW in JsFile.pm

=item Factorize model & store and models & stores

=item Allow adding a generator with no need to modify DBIC.pm

=back
