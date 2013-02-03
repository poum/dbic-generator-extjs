use strict;
use warnings;
package DBICx::Generator::ExtJS;

=head1 NAME

DBICx::Generator::ExtJS - ExtJS MVC class generator

=head1 SYNOPSYS

  use DBICx::Generator::ExtJS;

  my $extjs_generator = DBICx::Generator::ExtJS->new('My::Schema');

  $extjs_generator->make_model();

=cut

use Carp;
use UNIVERSAL::require;
use Data::Dump qw/dump/;

sub new {
  my ($self, $schema_name) = @_;
  croak "Mandatory schema name parameter is missing" unless $schema_name;

  $schema_name->require() or croak $!;
  my $schema;
  eval '$schema = ' . $schema_name . '->connect();';

  my (@pk, $table);
  foreach my $rsrc ($schema->sources) {
    $table = $schema->source($rsrc); 
    @pk = $table->primary_columns;
  }
}

1;
