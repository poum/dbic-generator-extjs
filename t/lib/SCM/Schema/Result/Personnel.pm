use utf8;
package SCM::Schema::Result::Personnel;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SCM::Schema::Result::Personnel

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<personnel>

=cut

__PACKAGE__->table("personnel");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'personnel_id_seq'

=head2 uid

  data_type: 'name'
  is_nullable: 0
  size: 64

=head2 nom

  data_type: 'name'
  is_nullable: 0
  size: 64

=head2 prenom

  data_type: 'name'
  is_nullable: 0
  size: 64

=head2 grade

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 fonction

  data_type: 'name'
  is_nullable: 1
  size: 64

=head2 root_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 lft

  data_type: 'integer'
  is_nullable: 0

=head2 rgt

  data_type: 'integer'
  is_nullable: 0

=head2 level

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "personnel_id_seq",
  },
  "uid",
  { data_type => "name", is_nullable => 0, size => 64 },
  "nom",
  { data_type => "name", is_nullable => 0, size => 64 },
  "prenom",
  { data_type => "name", is_nullable => 0, size => 64 },
  "grade",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "fonction",
  { data_type => "name", is_nullable => 1, size => 64 },
  "root_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "lft",
  { data_type => "integer", is_nullable => 0 },
  "rgt",
  { data_type => "integer", is_nullable => 0 },
  "level",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<personnel_uid_key>

=over 4

=item * L</uid>

=back

=cut

__PACKAGE__->add_unique_constraint("personnel_uid_key", ["uid"]);

=head1 RELATIONS

=head2 grade

Type: belongs_to

Related object: L<SCM::Schema::Result::Grade>

=cut

__PACKAGE__->belongs_to(
  "grade",
  "SCM::Schema::Result::Grade",
  { id => "grade" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 personnel_emploi_projets

Type: has_many

Related object: L<SCM::Schema::Result::PersonnelEmploiProjet>

=cut

__PACKAGE__->has_many(
  "personnel_emploi_projets",
  "SCM::Schema::Result::PersonnelEmploiProjet",
  { "foreign.personnel" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 personnels

Type: has_many

Related object: L<SCM::Schema::Result::Personnel>

=cut

__PACKAGE__->has_many(
  "personnels",
  "SCM::Schema::Result::Personnel",
  { "foreign.root_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 personnels_unite

Type: has_many

Related object: L<SCM::Schema::Result::PersonnelUnite>

=cut

__PACKAGE__->has_many(
  "personnels_unite",
  "SCM::Schema::Result::PersonnelUnite",
  { "foreign.personnel" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 rhas

Type: has_many

Related object: L<SCM::Schema::Result::Rha>

=cut

__PACKAGE__->has_many(
  "rhas",
  "SCM::Schema::Result::Rha",
  { "foreign.personnel" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 root

Type: belongs_to

Related object: L<SCM::Schema::Result::Personnel>

=cut

__PACKAGE__->belongs_to(
  "root",
  "SCM::Schema::Result::Personnel",
  { id => "root_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-02-02 17:33:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mnIKs+irbfkZtWnIMQtXqQ


__PACKAGE__->load_components(qw( Tree::NestedSet ));
__PACKAGE__->tree_columns({
             root_column     => 'root_id',
             left_column     => 'lft',
             right_column    => 'rgt',
             level_column    => 'level',
         });


1;
