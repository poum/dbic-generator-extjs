use utf8;
package SCM::Schema::Result::PersonnelProjet;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SCM::Schema::Result::PersonnelProjet

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<personnel_projet>

=cut

__PACKAGE__->table("personnel_projet");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'personnel_projet_id_seq'

=head2 personnel

  data_type: 'integer'
  is_nullable: 0

=head2 projet

  data_type: 'integer'
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
    sequence          => "personnel_projet_id_seq",
  },
  "personnel",
  { data_type => "integer", is_nullable => 0 },
  "projet",
  { data_type => "integer", is_nullable => 0 },
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


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-02-02 17:33:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IcuLBcxTUDh3fFw4oOAbIw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
