use utf8;
package SCM::Schema::Result::Rha;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SCM::Schema::Result::Rha

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<rha>

=cut

__PACKAGE__->table("rha");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'rha_id_seq'

=head2 jour

  data_type: 'date'
  is_nullable: 0

=head2 personnel

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 activite

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 duree

  data_type: 'integer'
  is_nullable: 0

=head2 projet

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "rha_id_seq",
  },
  "jour",
  { data_type => "date", is_nullable => 0 },
  "personnel",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "activite",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "duree",
  { data_type => "integer", is_nullable => 0 },
  "projet",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 activite

Type: belongs_to

Related object: L<SCM::Schema::Result::Activite>

=cut

__PACKAGE__->belongs_to(
  "activite",
  "SCM::Schema::Result::Activite",
  { id => "activite" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 personnel

Type: belongs_to

Related object: L<SCM::Schema::Result::Personnel>

=cut

__PACKAGE__->belongs_to(
  "personnel",
  "SCM::Schema::Result::Personnel",
  { id => "personnel" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 projet

Type: belongs_to

Related object: L<SCM::Schema::Result::Projet>

=cut

__PACKAGE__->belongs_to(
  "projet",
  "SCM::Schema::Result::Projet",
  { id => "projet" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-02-02 17:33:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xcxyYxOIkYB9CXR7Ey00WA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
