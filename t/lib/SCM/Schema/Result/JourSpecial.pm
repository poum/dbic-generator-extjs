use utf8;
package SCM::Schema::Result::JourSpecial;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SCM::Schema::Result::JourSpecial

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<jour_special>

=cut

__PACKAGE__->table("jour_special");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'jour_special_id_seq'

=head2 jour

  data_type: 'date'
  is_nullable: 0

=head2 heures

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 commentaire

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "jour_special_id_seq",
  },
  "jour",
  { data_type => "date", is_nullable => 0 },
  "heures",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "commentaire",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-02-02 17:33:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Id8voTCUwdFgQxdtumibbw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
