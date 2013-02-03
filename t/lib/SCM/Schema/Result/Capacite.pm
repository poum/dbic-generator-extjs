use utf8;
package SCM::Schema::Result::Capacite;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SCM::Schema::Result::Capacite

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<capacite>

=cut

__PACKAGE__->table("capacite");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'capacite_id_seq'

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
    sequence          => "capacite_id_seq",
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

=head2 C<capacite_nom_key>

=over 4

=item * L</nom>

=back

=cut

__PACKAGE__->add_unique_constraint("capacite_nom_key", ["nom"]);

=head1 RELATIONS

=head2 activites

Type: has_many

Related object: L<SCM::Schema::Result::Activite>

=cut

__PACKAGE__->has_many(
  "activites",
  "SCM::Schema::Result::Activite",
  { "foreign.capacite" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-02-02 17:33:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rpbzo6qRbsYr0E3ET+Fd0Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
