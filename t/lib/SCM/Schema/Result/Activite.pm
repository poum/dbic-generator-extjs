use utf8;
package SCM::Schema::Result::Activite;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SCM::Schema::Result::Activite

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<activite>

=cut

__PACKAGE__->table("activite");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'activite_id_seq'

=head2 nom

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  default_value: (empty string)
  is_nullable: 0

=head2 capacite

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 processus

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 lien_projet

  data_type: 'boolean'
  is_nullable: 1

=head2 abstraite

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 active

  data_type: 'boolean'
  default_value: true
  is_nullable: 0

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
    sequence          => "activite_id_seq",
  },
  "nom",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "text", default_value => "", is_nullable => 0 },
  "capacite",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "processus",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "lien_projet",
  { data_type => "boolean", is_nullable => 1 },
  "abstraite",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "active",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
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

=head2 C<activite_nom_key>

=over 4

=item * L</nom>

=back

=cut

__PACKAGE__->add_unique_constraint("activite_nom_key", ["nom"]);

=head1 RELATIONS

=head2 activite_emplois

Type: has_many

Related object: L<SCM::Schema::Result::ActiviteEmploi>

=cut

__PACKAGE__->has_many(
  "activite_emplois",
  "SCM::Schema::Result::ActiviteEmploi",
  { "foreign.activite" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 activites

Type: has_many

Related object: L<SCM::Schema::Result::Activite>

=cut

__PACKAGE__->has_many(
  "activites",
  "SCM::Schema::Result::Activite",
  { "foreign.root_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 capacite

Type: belongs_to

Related object: L<SCM::Schema::Result::Capacite>

=cut

__PACKAGE__->belongs_to(
  "capacite",
  "SCM::Schema::Result::Capacite",
  { id => "capacite" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 processus

Type: belongs_to

Related object: L<SCM::Schema::Result::Processus>

=cut

__PACKAGE__->belongs_to(
  "processus",
  "SCM::Schema::Result::Processus",
  { id => "processus" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 rhas

Type: has_many

Related object: L<SCM::Schema::Result::Rha>

=cut

__PACKAGE__->has_many(
  "rhas",
  "SCM::Schema::Result::Rha",
  { "foreign.activite" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 root

Type: belongs_to

Related object: L<SCM::Schema::Result::Activite>

=cut

__PACKAGE__->belongs_to(
  "root",
  "SCM::Schema::Result::Activite",
  { id => "root_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-02-02 17:33:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8eOZFDoTd1FQkPUYQA0Vrw

__PACKAGE__->load_components(qw(Tree::NestedSet));
__PACKAGE__->tree_columns({
      root_column     => 'root_id',
      left_column     => 'lft',
      right_column    => 'rgt',
      level_column    => 'level',
});

1;
