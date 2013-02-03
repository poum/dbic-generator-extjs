use utf8;
package SCM::Schema::Result::TypeActivite;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SCM::Schema::Result::TypeActivite

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<type_activite>

=cut

__PACKAGE__->table("type_activite");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'type_activite_id_seq'

=head2 nom

  data_type: 'name'
  is_nullable: 0
  size: 64

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "type_activite_id_seq",
  },
  "nom",
  { data_type => "name", is_nullable => 0, size => 64 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<type_activite_nom_key>

=over 4

=item * L</nom>

=back

=cut

__PACKAGE__->add_unique_constraint("type_activite_nom_key", ["nom"]);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-02-02 17:33:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EyAhuWtEs9bGLZEqgOrVlQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
