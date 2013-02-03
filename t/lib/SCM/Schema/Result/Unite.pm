use utf8;
package SCM::Schema::Result::Unite;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SCM::Schema::Result::Unite

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<unite>

=cut

__PACKAGE__->table("unite");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'unite_id_seq'

=head2 nom

  data_type: 'name'
  is_nullable: 0
  size: 64

=head2 libelle

  data_type: 'name'
  is_nullable: 0
  size: 64

=head2 logo

  data_type: 'text'
  is_nullable: 1

=head2 timbre

  data_type: 'text'
  is_nullable: 0

=head2 active

  data_type: 'boolean'
  default_value: false
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
    sequence          => "unite_id_seq",
  },
  "nom",
  { data_type => "name", is_nullable => 0, size => 64 },
  "libelle",
  { data_type => "name", is_nullable => 0, size => 64 },
  "logo",
  { data_type => "text", is_nullable => 1 },
  "timbre",
  { data_type => "text", is_nullable => 0 },
  "active",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
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

=head2 C<unite_timbre_key>

=over 4

=item * L</timbre>

=back

=cut

__PACKAGE__->add_unique_constraint("unite_timbre_key", ["timbre"]);

=head1 RELATIONS

=head2 personnels_unite

Type: has_many

Related object: L<SCM::Schema::Result::PersonnelUnite>

=cut

__PACKAGE__->has_many(
  "personnels_unite",
  "SCM::Schema::Result::PersonnelUnite",
  { "foreign.unite" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 root

Type: belongs_to

Related object: L<SCM::Schema::Result::Unite>

=cut

__PACKAGE__->belongs_to(
  "root",
  "SCM::Schema::Result::Unite",
  { id => "root_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 unites

Type: has_many

Related object: L<SCM::Schema::Result::Unite>

=cut

__PACKAGE__->has_many(
  "unites",
  "SCM::Schema::Result::Unite",
  { "foreign.root_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-02-02 17:33:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:S5T6Ftg/OlF8YbPPgGZOUA

__PACKAGE__->load_components(qw( Tree::NestedSet ));
__PACKAGE__->tree_columns({
             root_column     => 'root_id',
             left_column     => 'lft',
             right_column    => 'rgt',
             level_column    => 'level',
         });


1;
