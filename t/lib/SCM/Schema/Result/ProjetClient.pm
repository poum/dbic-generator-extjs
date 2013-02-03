use utf8;
package SCM::Schema::Result::ProjetClient;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SCM::Schema::Result::ProjetClient

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<projet_client>

=cut

__PACKAGE__->table("projet_client");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'projet_client_id_seq'

=head2 projet

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 client

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 prorata

  data_type: 'double precision'
  default_value: 1.0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "projet_client_id_seq",
  },
  "projet",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "client",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "prorata",
  {
    data_type     => "double precision",
    default_value => "1.0",
    is_nullable   => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 client

Type: belongs_to

Related object: L<SCM::Schema::Result::Client>

=cut

__PACKAGE__->belongs_to(
  "client",
  "SCM::Schema::Result::Client",
  { id => "client" },
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
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-02-02 17:33:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GO2s3I1/+LUB7jaeosJQgA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
