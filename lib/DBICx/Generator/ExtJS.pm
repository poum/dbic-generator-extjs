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

has 'schema_name' => ( 
  is => 'ro',
  isa => 'Str',
  required => 1
);

has 'schema' => ( is => 'rw' );

sub BUILD {
  my $self = shift;

  $self->schema_name->require() or croak 'Unable to found/load ' . $self->schema_name . " ($!)";

  eval '$self->schema(' . $self->schema_name . '->connect());';
  $self->schema or croak 'Unable to connect to ' . $self->schema_name;

  my (@pk, $table);
  foreach my $rsrc ($self->schema->sources) {
    $table = $self->schema->source($rsrc); 
    @pk = $table->primary_columns;
  }
}

__PACKAGE__->meta->make_immutable;

1;
