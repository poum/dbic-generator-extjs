package DBICx::Generator::ExtJS;
use Moose;
use namespace::autoclean;

=head1 NAME

DBICx::Generator::ExtJS - ExtJS MVC class generator

=head1 SYNOPSYS

  use DBICx::Generator::ExtJS;

  my $extjs_generator = DBICx::Generator::ExtJS->new(schema_name => 'My::Schema');

  $extjs_generator->make_model();

=cut

use Carp;
use UNIVERSAL::require;

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
has 'schema' => ( is => 'rw' );

=head3 tables

    return an array reference of table name of the schema

=cut
has 'tables' => (is => 'rw');

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

  my $resultset = $self->schema->source($name); 
  my $model = { 
    extend => 'Ext.data.Model',
    fields => [],
    validations => [],
    associations => [],
    proxy => {
      type => 'ajax',
      api => {
        read   => '/' . lc $name . '/read',
        create => '/' . lc $name . '/create',
        update => '/' . lc $name . '/update',
        destroy => '/' . lc $name . '/delete'
      }
    }
  };
  my @columns = $resultset->columns;
  my ($field, $info);
  foreach my $column (@columns) {
    $field = { name => $column };

    $info = $resultset->column_info($column);
    $field->{type} = $self->translateType($info->{data_type});
    push @{$model->{fields}}, $field;
  }

  return $model;
}

sub translateType {
  my $self = shift;
  my $schemaType = shift or croak "Missing schema type to translate !";

  return $self->pierreDeRosette->{$schemaType} || 'auto';
}


__PACKAGE__->meta->make_immutable;

1;
