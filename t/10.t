use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Files;

use File::Path qw/remove_tree/;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use lib "$Bin/lib";

my $oldDir = chdir $Bin;

remove_tree('js');

require_ok('ExtJS::Generator::DBIC');

my $generator;

throws_ok { $generator= ExtJS::Generator::DBIC->new() } 
  qr/Attribute \(schema_name\) is required/, 
  'schema_name parameter required';

throws_ok { $generator = ExtJS::Generator::DBIC->new(schema_name => 'Sorry::No::Schema::Here') } 
  qr/Unable to found\/load Sorry::No::Schema::Here/, 
  'non existent schema detected';

ok($generator = ExtJS::Generator::DBIC->new(schema_name => 'My::Schema'), 'existant schema loaded correctly');
can_ok($generator, qw/model models store stores/);

is_deeply($generator->tables, [qw/Another Basic/], 'schema tables found');

is($generator->typeTranslator->translate('varchar'), 'string', 'known type correctly translated');

throws_ok { $generator->model() }
  qr/Model name required !/,
  'missing model parameter detected';

throws_ok { $generator->model('SantaClaus') }
  qr/SantaClaus doesn't exist !/,
  'non existent model detected';

ok($generator->model('Basic'), 'ExtJS Basic model generation');

compare_ok('./js/app/model/Basic.js', './expected_js/10-unmodified-model-Basic.js', 'Generated ExtJS Basic model ok');

ok($generator->model('Another'), 'ExtJS Another model update');

remove_tree('js');

ok($generator->models(), 'Extjs model global generation');

throws_ok { $generator->store() }
  qr/Store name required !/,
	'missing store parameter detected';

throws_ok { $generator->store('BigFoot') }
	qr/BigFoot doesn't exist !/,
	'non existent store detected';

ok($generator->store('Basic'), 'ExtJS Basic store generation');
compare_ok('./js/app/store/Basic.js', './expected_js/10-unmodified-store-Basic.js', 'Generated ExtJS Basic store ok');

ok($generator->store('Another'), 'ExtJS Another store generation');

remove_tree('js');
ok($generator->stores(), 'ExtJS store global generation');

remove_tree('js');
ok($generator->mvc(), 'ExtJS global generation');

chdir $oldDir;
done_testing;
