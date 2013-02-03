use utf8;
package SCM::Schema::Result::Client;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SCM::Schema::Result::Client

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<client>

=cut

__PACKAGE__->table("client");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'client_id_seq'

=head2 nom

  data_type: 'name'
  is_nullable: 0
  size: 64

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "client_id_seq",
  },
  "nom",
  { data_type => "name", is_nullable => 0, size => 64 },
  "description",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<client_nom_key>

=over 4

=item * L</nom>

=back

=cut

__PACKAGE__->add_unique_constraint("client_nom_key", ["nom"]);

=head1 RELATIONS

=head2 projet_clients

Type: has_many

Related object: L<SCM::Schema::Result::ProjetClient>

=cut

__PACKAGE__->has_many(
  "projet_clients",
  "SCM::Schema::Result::ProjetClient",
  { "foreign.client" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-02-02 17:33:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VBuIpF5H/Yx4/teTOlWhAQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
