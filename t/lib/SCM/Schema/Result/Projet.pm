use utf8;
package SCM::Schema::Result::Projet;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SCM::Schema::Result::Projet

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<projet>

=cut

__PACKAGE__->table("projet");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'projet_id_seq'

=head2 nom

  data_type: 'name'
  is_nullable: 0
  size: 64

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 debut

  data_type: 'date'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 fin_prevue

  data_type: 'date'
  is_nullable: 1

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
    sequence          => "projet_id_seq",
  },
  "nom",
  { data_type => "name", is_nullable => 0, size => 64 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "debut",
  {
    data_type     => "date",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "fin_prevue",
  { data_type => "date", is_nullable => 1 },
  "fin",
  { data_type => "date", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<projet_nom_key>

=over 4

=item * L</nom>

=back

=cut

__PACKAGE__->add_unique_constraint("projet_nom_key", ["nom"]);

=head1 RELATIONS

=head2 personnel_emploi_projets

Type: has_many

Related object: L<SCM::Schema::Result::PersonnelEmploiProjet>

=cut

__PACKAGE__->has_many(
  "personnel_emploi_projets",
  "SCM::Schema::Result::PersonnelEmploiProjet",
  { "foreign.projet" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 projet_clients

Type: has_many

Related object: L<SCM::Schema::Result::ProjetClient>

=cut

__PACKAGE__->has_many(
  "projet_clients",
  "SCM::Schema::Result::ProjetClient",
  { "foreign.projet" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 rhas

Type: has_many

Related object: L<SCM::Schema::Result::Rha>

=cut

__PACKAGE__->has_many(
  "rhas",
  "SCM::Schema::Result::Rha",
  { "foreign.projet" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-02-02 17:33:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wejuxsdNZRrrQyeLsaSlnA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
