use utf8;
package SCM::Schema::Result::ActiviteEmploi;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SCM::Schema::Result::ActiviteEmploi

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<activite_emploi>

=cut

__PACKAGE__->table("activite_emploi");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'activite_emploi_id_seq'

=head2 activite

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 emploi

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 debut

  data_type: 'date'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 fin

  data_type: 'date'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "activite_emploi_id_seq",
  },
  "activite",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "emploi",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "debut",
  {
    data_type     => "date",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "fin",
  { data_type => "date", is_nullable => 1 },
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

=head2 emploi

Type: belongs_to

Related object: L<SCM::Schema::Result::Emploi>

=cut

__PACKAGE__->belongs_to(
  "emploi",
  "SCM::Schema::Result::Emploi",
  { id => "emploi" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-02-02 17:33:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DpQ63K0/RNFq/SDmpgWbOg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
