use strict;
use warnings;

use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use lib "$Bin/lib";

my $oldDir = chdir $Bin;

require_ok('DBICx::Generator::ExtJS');

my $generator = DBICx::Generator::ExtJS->new(schema_name => 'SCM::Schema');

ok($generator, 'existant schema loaded correctly');

is_deeply($generator->tables, [qw/Rha ActiviteEmploi Delegation Emploi Unite ProjetClient Client Pcp Processus Personnel TypeActivite Capacite JourSpecial PersonnelProjet PersonnelEmploiProjet Projet Activite PersonnelUnite Grade/ ], 'schema tables found');

ok($generator->model('Personnel'), 'ExtJS Personnel model generation');

chdir $oldDir;

done_testing;
