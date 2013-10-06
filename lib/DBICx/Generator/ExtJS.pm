package DBICx::Generator::ExtJS;

use Moose;
use namespace::autoclean;
use JSON::DWIW;
use Carp;
use UNIVERSAL::require;
use File::Path qw/make_path/;

# ABSTRACT: DBICx::Generator::ExtJS - ExtJS MVC class generator using DBIx::Class schema

=head1 SYNOPSYS

  use DBICx::Generator::ExtJS;

  my $extjs_generator = DBICx::Generator::ExtJS->new(schema_name => 'My::Schema');

  $extjs_generator->make_model();

=cut


=head2 METHODS

=head3 schema_name

Give the name of the schema module passed as parameter

=cut
has 'schema_name' => ( 
  is => 'ro',
  isa => 'Str',
  required => 1
);

=head3 js_name

The javascript file namespace

=cut
has 'js_namespace' => (
  is => 'rw',
  isa => 'Str'
);

=head3 schema

Return the DBIx::Class schema object

=cut
has 'schema' => ( 
  is => 'rw',
  isa => 'DBIx::Class::Schema'
);

=head3 tables

Return an array reference of all schema table names

=cut
has 'tables' => (is => 'rw');

=head3 order

Return an hashref of applied order to json extjs generated file

=cut
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

=head3 path

The path where the js files can be retrieved / writes

=cut
has 'path' => (
  is => 'rw',
  isa => 'Str',
  default => 'js/app'
);

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

=head3 pierreDeRosette

Return an hashref of all known type ExtJS translation
(MySQL, PostgreSQL & Oracle for now)

=cut
has 'pierreDeRosette' => (
  is  => 'ro',
  isa => 'HashRef',
  default => sub {

    {
      #
      # MySQL types
      #
      bigint     => 'int',
      double     => 'float',
      decimal    => 'float',
      float      => 'float',
      int        => 'int',
      integer    => 'int',
      mediumint  => 'int',
      smallint   => 'int',
      tinyint    => 'int',
      char       => 'string',
      varchar    => 'string',
      tinyblob   => 'auto',
      blob       => 'auto',
      mediumblob => 'auto',
      longblob   => 'auto',
      tinytext   => 'string',
      text       => 'string',
      longtext   => 'string',
      mediumtext => 'string',
      enum       => 'string',
      set        => 'string',
      date       => 'date',
      datetime   => 'date',
      time       => 'date',
      timestamp  => 'date',
      year       => 'date',

      #
      # PostgreSQL types
      #
      numeric             => 'float',
      'double precision'  => 'float',
      serial              => 'int',
      bigserial           => 'int',
      money               => 'float',
      character           => 'string',
      'character varying' => 'string',
      bytea               => 'auto',
      interval            => 'float',
      boolean             => 'boolean',
      point               => 'float',
      line                => 'float',
      lseg                => 'float',
      box                 => 'float',
      path                => 'float',
      polygon             => 'float',
      circle              => 'float',
      cidr                => 'string',
      inet                => 'string',
      macaddr             => 'string',
      bit                 => 'int',
      'bit varying'       => 'int',

      #
      # Oracle types
      #
      number   => 'float',
      varchar2 => 'string',
      long     => 'float',
    };
  }
);


# constructor
#
# load/store the schema using the name given as parameter
# and initialize the 'tables' array ref 
# create a javascript namespace if necessary
sub BUILD {
  my $self = shift;

  $self->schema_name->require() or croak 'Unable to found/load ' . $self->schema_name . " ($!)";
  
  #eval '$self->schema(' . $self->schema_name . '->connect());';
  $self->schema($self->schema_name->connect());

  $self->schema or croak 'Unable to connect to ' . $self->schema_name;

  $self->tables([$self->schema->sources]);

  unless ($self->js_namespace) {
    my $js_namespace = $self->schema_name;
    $js_namespace =~ s/::Schema$//;
    $js_namespace =~ s/::/./g;
    $self->js_namespace($js_namespace);
  }
}

=head3 models

Generate all ExtJS models found in the DBIx::Class Schema

=cut
sub models {
  my $self = shift;
  $self->model($_) foreach @{$self->tables()};
}

=head3 extjs_model_name

This method returns the ExtJS model name for a table and can be overridden
in a subclass.

=cut

sub extjs_model_name {
    my ( $self, $tablename ) = @_;
    $tablename = $tablename =~ m/^(?:\w+::)* (\w+)$/x ? $1 : $tablename;
    return ucfirst($tablename);
}

=head3 model

Generate specified ExtJS model (field definition, validation rules, proxy and association). 
If a javascript model file already exists, all other keys are preserved.

=cut
sub model {
  my $self = shift;
  my $name = shift or croak "Model name required ! (did'nt you mind 'models' ?)";

  croak "$name does'nt exist !" unless grep /^$name$/, @{$self->tables()};

  my ($model, $model_name) = $self->_getJSON($name, 'model');
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
  
    $field->{type} = $self->translateType($info->{data_type});

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
      # add presence validation if it does'nt already exist
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

  make_path($self->path . '/model');

  open(my $fh, '>', $self->path . '/model/' . $name . '.js') or croak $!;
  print $fh sprintf("Ext.define('%s.model.%s', %s);", $self->js_namespace, $name, $self->json->to_json($model));
  return $model;
}

=head3 translateType

Translate the original type in ExtJS corresponding type.
If this type is unknown, return 'auto'

=cut
sub translateType {
  my $self = shift;
  my $schemaType = shift or croak "Missing schema type to translate !";

  return $self->pierreDeRosette->{$schemaType} || 'auto';
}

# _getJSON
# 
#  get previous 'type' ExtJS file if any with associated full name
#
# parameters:
# - name: file name without the .js extension
# - type: type
#
# return
# - an array with the reference of the decoded Perl structure and the type name
#
sub _getJSON {
  my ($self, $name, $type) = @_;

  my $filename = join '/', $self->path, $type, "$name.js"; 
  my $json = {};
  my $type_name;
  if (-e $filename) {
    open(my $fh, '<', $filename);
    my $file = '';
    while (<$fh>) {
      chomp;
      $file .= $_; 
    }
    close $fh;

    if ($file =~ /Ext\.define\s*\(\s*('[^']+')\s*,\s*(\{.+\})\);/) {
      $type_name = $1;
      $json = $self->json->from_json($2);
    }
  }

  return ($json, $type_name);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 TODO

=over 4

=item store / treestore generator

=item controller generator (using template)

=item form generator (combo for associated data)

=item grid / tree generator

=item use md5 (has DBIx::Class::Loader do) to verify the modified parts (compress then order the json file first)

=item add backup / stop option if the generated file already exists

=item use estjs main file for finding path to file and namespace

=item use a config file

=item search in local directory by default

=back
