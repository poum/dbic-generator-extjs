package DBICx::Generator::ExtJS;
use Moose;
use namespace::autoclean;
use JSON::DWIW;
use Carp;
use UNIVERSAL::require;

use Data::Dump qw/dump/;

# ABSTRACT: DBICx::Generator::ExtJS - ExtJS MVC class generator

=head1 SYNOPSYS

  use DBICx::Generator::ExtJS;

  my $extjs_generator = DBICx::Generator::ExtJS->new(schema_name => 'My::Schema');

  $extjs_generator->make_model();

=cut


=head2 METHODS

=head3 schema_name

  give the name of the schema module passed as parameter

=cut
has 'schema_name' => ( 
  is => 'ro',
  isa => 'Str',
  required => 1
);

=head3 schema

  return the DBIx::Class schema object

=cut
has 'schema' => ( 
  is => 'rw',
  isa => 'DBIx::Class::Schema'
);

=head3 tables

  return an array reference of all schema table names

=cut
has 'tables' => (is => 'rw');

=head3 order

  return an hashref of applied order to json extjs generated file

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

  return an hashref of all known type ExtJS translation
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
sub BUILD {
  my $self = shift;

  $self->schema_name->require() or croak 'Unable to found/load ' . $self->schema_name . " ($!)";

  eval '$self->schema(' . $self->schema_name . '->connect());';
  $self->schema or croak 'Unable to connect to ' . $self->schema_name;

  $self->tables([$self->schema->sources]);
}

=head3 models

  generate all ExtJS models found in the DBIx::Class Schema

=cut
sub models {
  my $self = shift;
  $self->model($_) foreach @{$self->tables()};
}

=head3 model

  generate specified ExtJS model

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
      # supress presence validation if the field is now nullable
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

  mkdir 'js' unless -e 'js';
  mkdir 'js/app' unless -e 'js/app';
  mkdir 'js/app/model' unless -e 'js/app/model';

  open(my $fh, '>', 'js/app/model/' . $name . '.js') or croak $!;
  print $fh "Ext.define('$name', ";
  warn $model;
  print $fh $self->json->to_json($model);
  print $fh ');';
  return $model;
}

=head3 translateType

  translate the original type in ExtJS corresponding type.
  if this type is unknown, return 'auto'

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

  my $filename = "js/app/$type/$name.js"; 
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
