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

has 'tables' => (is => 'rw');

sub BUILD {
  my $self = shift;

  $self->schema_name->require() or croak 'Unable to found/load ' . $self->schema_name . " ($!)";

  eval '$self->schema(' . $self->schema_name . '->connect());';
  $self->schema or croak 'Unable to connect to ' . $self->schema_name;

  $self->tables([$self->schema->sources]);
}

=head2 METHODS

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
  my $model = shift or croak "Model name required !";

  die dump($self->schema->source($model));
}


__PACKAGE__->meta->make_immutable;

1;
