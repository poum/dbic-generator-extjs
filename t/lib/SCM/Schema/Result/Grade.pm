use utf8;
package SCM::Schema::Result::Grade;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SCM::Schema::Result::Grade

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<grade>

=cut

__PACKAGE__->table("grade");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'grade_id_seq'

=head2 nom

  data_type: 'name'
  is_nullable: 0
  size: 64

=head2 description

  data_type: 'text'
  default_value: 'Ã  renseigner'
  is_nullable: 0

=head2 militaire

  data_type: 'boolean'
  default_value: true
  is_nullable: 0

=head2 categorie

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=head2 active

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 root_id

  data_type: 'integer'
  default_value: 2
  is_foreign_key: 1
  is_nullable: 0

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
    sequence          => "grade_id_seq",
  },
  "nom",
  { data_type => "name", is_nullable => 0, size => 64 },
  "description",
  {
    data_type     => "text",
    default_value => "\xC3\xA0 renseigner",
    is_nullable   => 0,
  },
  "militaire",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
  "categorie",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "active",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "root_id",
  {
    data_type      => "integer",
    default_value  => 2,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
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

=head1 RELATIONS

=head2 grades

Type: has_many

Related object: L<SCM::Schema::Result::Grade>

=cut

__PACKAGE__->has_many(
  "grades",
  "SCM::Schema::Result::Grade",
  { "foreign.root_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 personnels

Type: has_many

Related object: L<SCM::Schema::Result::Personnel>

=cut

__PACKAGE__->has_many(
  "personnels",
  "SCM::Schema::Result::Personnel",
  { "foreign.grade" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 root

Type: belongs_to

Related object: L<SCM::Schema::Result::Grade>

=cut

__PACKAGE__->belongs_to(
  "root",
  "SCM::Schema::Result::Grade",
  { id => "root_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-02-02 17:33:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TFtDI68yxdrULjN/VBc2gw

__PACKAGE__->load_components(qw( Tree::NestedSet ));
__PACKAGE__->tree_columns({
             root_column     => 'root_id',
             left_column     => 'lft',
             right_column    => 'rgt',
             level_column    => 'level',
         });


1;
