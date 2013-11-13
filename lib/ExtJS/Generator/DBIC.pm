package ExtJS::Generator::DBIC;

use Moose;
use namespace::autoclean;
use JSON::DWIW;
use Carp;
use UNIVERSAL::require;
use ExtJS::Generator::DBIC::JsFile;
use ExtJS::Generator::DBIC::TypeTranslator;

use Data::Dumper;

#ABSTRACT: ExtJS MVC class generator using DBIx::Class schema

=head1 SYNOPSYS

  use ExtJS::Generator::DBIC;

  my $extjs_generator = ExtJS::Generator::DBIC->new(schema_name => 'My::Schema');

  $extjs_generator->model('Basic');

  # all models in one shot
  $extjs_generator->models();

  $extjs_generator->store('Another');

  # all stores in one shot
  $extjs_generator->stores();

  # all ExtJS artifacts related to Basic model in one shot (model & store)
  $extjs_generator->mvc('Basic');

  # all ExtJS artifacts in one shot (models & stores)
  $extjs_generator->mvc();

=cut

=head1 DESCRIPTION

ExtJS::Generator::DBIC try to reuse all the work already done in Perl with DBIx::Class or in SQL with DBIx::Class::Loader 
to (re)generate corresponding ExtJS MVC javascript files. For now, it produces :

=over 4

=item B<the model files> : with typed fields, validations rules, and associations. The DBIx::Class::Schema namespace is reused.

=item B<the store files> : with model and proxy

=back

It handles the already existings ExtJS javascript files, trying to preserve comment and non JSON parts. If an absolute or relative path is given,
files are only looked for in this location. Otherwise try 'path'/'type'/'file', 'path'/'file', ./'type'/'file' and finally ./'file'. 
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

has 'order' => (
  is => 'ro',
  isa => 'HashRef',
  default => sub {

    {
      model => [ qw/extend fields validations associations proxy/ ],
      # not used yet ...
      fields => [ qw/name type defaultValue/ ],
      # associations, validations ....
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
      bare_solidus => 1,
      use_exceptions => 0
    }) 
  }
);

# TODO : maybe in specific generator ...
has 'typeTranslator' => (
	is => 'rw',
	isa => 'ExtJS::Generator::DBIC::TypeTranslator'
);

=head1 METHODS

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

=head2 model

Generate specified ExtJS model (field definition, validation rules, proxy and association). 
If a javascript model file already exists, all other keys are preserved.

If a nullable boolean field is encountered, the corresponding presence validation rule isn't
generated to avoid ExtJS transform the null values into false ones.

=head3 parameters

=over 4

=item model name for which the ExtJS model file should be generated. B<Mandatory>.

=back

=head3 return

ref to model Perl structure

=cut
sub model {
  my $self = shift;
  my $name = shift or croak "Model name required ! (didn't you mind 'models' ?)";

  croak "$name doesn't exist !" unless grep /^$name$/, @{$self->tables};

  my $jsFile = new ExtJS::Generator::DBIC::JsFile() or croak $!;

  $jsFile->parse(file => $name, path => $self->path, namespace => $self->js_namespace);
  my ($model, $err) = $self->json->from_json($jsFile->object());

  # translate keys in ordered ones
  my %o = ();
  if (keys %$model) {
  }
  else {
    my $cpt = 1;
    foreach (@{$self->order->{model}}) {
      $o{$_} = '__' . $cpt . '__' . $_ . '__';
      $cpt++;
    }
  }

  $model->{$o{extend}} = 'Ext.data.Model' unless exists $model->{$o{extend}};
  unless (exists $model->{$o{proxy}}) {
    my $url = '/' . lc $name . '/';
    $model->{$o{proxy}} = {
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
    @updatedField = grep { $_->{name} eq $column } @{$model->{$o{fields}}};
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
    push @{$model->{$o{fields}}}, $field unless @updatedField;

    # the presence validation already exists ?
    @updatedField = grep { $_->{field} eq $column and $_->{type} eq 'presence' } @{$model->{$o{validations}}};
    if ($info->{is_nullable}) {
      # suppress presence validation if the field is now nullable
      $updatedField[0] = undef if @updatedField;
    }
    else {
      # add presence validation if it doesn't already exist
      push @{$model->{$o{validations}}}, { type => 'presence', field => $column } unless @updatedField;
    }

    # the max size validation already exists ?
    @updatedField = grep { $_->{field} eq $column and $_->{type} eq 'length' and $_->{max} } @{$model->{$o{validations}}};
    if ($info->{size} and $field->{type} eq 'string') {
      $field = @updatedField ? $updatedField[0] : { field => $column, type => 'length' };
      $field->{max} = $info->{size};
      push @{$model->{$o{validations}}}, $field unless @updatedField;
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
    @updatedField = grep { $_->{model} eq $modelname and $_->{type} eq $reltype } @{$model->{$o{associations}}};
    $field = @updatedField ? $updatedField[0] : { model => $modelname, type => $reltype };
    $field->{associationKey} = $relation;
    $field->{primaryKey} = $rel_col;
    $field->{foreign} = $our_col;
    push @{$model->{$o{associations}}}, $field unless @updatedField;
  }

  $jsFile->object($self->json->to_json($model));

  $jsFile->write(backup => $self->backup);

  return $model;
}

=head2 models

Generate all ExtJS models found in the DBIx::Class Schema

=head3 return

List of model Perl structure references

=cut
sub models {
  my $self = shift; 
  my @models = @{$self->tables};

  $self->model($_) foreach @models;

  return @models;
}

=head2 store

Generate specified ExtJS store (model and proxy). 
If a javascript store file already exists, all other keys are preserved.

=head3 parameters

=over 4

=item model name for which the ExtJS store file should be generated. B<Mandatory>.

=back

=head3 return

ref to store Perl structure

=cut
sub store {
  my $self = shift;
  my $name = shift or croak "Store name required ! (didn't you mind 'stores' ?)";
  croak "$name doesn't exist !" unless grep /^$name$/, @{$self->tables};

  my $jsFile = new ExtJS::Generator::DBIC::JsFile() or croak $!;

  $jsFile->parse(type => 'store', file => $name, path => $self->path, namespace => $self->js_namespace);
  my $store = $self->json->from_json($jsFile->object());

  $store->{extend} = 'Ext.data.Store' unless exists $store->{extend};
  $store->{model} = join '.', $self->js_namespace, 'model', $name unless exists $store->{model};
  unless (exists $store->{proxy}) {
    my $url = '/' . lc $name . '/';
    $store->{proxy} = {
      type => 'ajax',
      url  =>  '/' . lc $name . '/list.json'
    };
  }

  $jsFile->object($self->json->to_json($store));
  $jsFile->write(backup => $self->backup);

  return $store;
}

=head2 stores

Generate ExtJS stores for all models found in the DBIx::Class Schema

=head3 return

List of store Perl structure references

=cut
sub stores {
  my $self = shift;
  my @stores = ();

  push @stores, $self->store($_) foreach @{$self->tables()};

  return @stores;
}

=head2 mvc

Generate all ExtJS artifacts for the specified model or all models found in the DBIx::Class Schema

=head3 parameter

=over 4

=item model name (if no model is specified, all ExtJS artifacts will be generated)

=back

=head3 return

List of Perl structure references

=cut
sub mvc {
    my $self = shift;
    my $model = shift;

    if ($model) {
      return ($self->model($model), $self->store($model));
    }
    else {
      return ($self->models(), $self->stores());
    }
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

=item Hide JSON::DWIW in JsFile.pm ?

=item Factorize model & store and models & stores

=item Allow adding a generator with no need to modify DBIC.pm

=item add parameters to not generate validation or association in model method

=item add parameter to specify proxy values in model & store

=item add parameter to change extend value in mode & store

=item add warning if file name and class name differ

=item use a portable path separator

=item try not to alter $_

=item restore initial key order

=item use JavaScript::Beautifier

=back
