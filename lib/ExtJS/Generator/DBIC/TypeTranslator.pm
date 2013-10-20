package ExtJS::Generator::DBIC::TypeTranslator;

use Moose;
use namespace::autoclean;
use Carp;

# ABSTRACT: DBIx::Class - ExtJS Generic Type Translator

=head1 METHODS

=head2 new

Create a new type translator object

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

=head2 translate

Translate the original type in ExtJS corresponding type.
If this type is unknown, return 'auto'

=head3 parameters

=over 4

=item schema type to translate in extjs type

=back

=head3 return

ExtJS type string

=cut
sub translate {
  my $self = shift;
  my $schemaType = shift or croak "Missing schema type to translate !";

  return $self->pierreDeRosette->{$schemaType} || 'auto';
}

__PACKAGE__->meta->make_immutable;

1;
