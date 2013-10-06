use strict;
use warnings;

use Test::More;
use Test::Exception;

use Data::Dumper; 

use FindBin qw($Bin);
use lib "$Bin/../lib";
use lib "$Bin/lib";

my $oldDir = chdir $Bin;

require_ok('ExtJS::Generator::DBIC');

my $generator;

throws_ok { $generator= ExtJS::Generator::DBIC->new() } 
  qr/Attribute \(schema_name\) is required/, 
  'schema_name parameter required';

throws_ok { $generator = ExtJS::Generator::DBIC->new(schema_name => 'Sorry::No::Schema::Here') } 
  qr/Unable to found\/load Sorry::No::Schema::Here/, 
  'non existent schema detected';

ok($generator = ExtJS::Generator::DBIC->new(schema_name => 'My::Schema'), 'existant schema loaded correctly');

is_deeply($generator->tables, [qw/Another Basic/], 'schema tables found');

throws_ok { $generator->typeTranslator->translate() }
  qr/Missing schema type to translate !/,
  'missing translateType parameter detected';

is($generator->typeTranslator->translate('varchar'), 'string', 'known type correctly translated');
is($generator->typeTranslator->translate('point'), 'float', 'known type correctly translated');
is($generator->typeTranslator->translate('von Bismarck'), 'auto', 'unknown type correctly translated to auto');

throws_ok { $generator->model() }
  qr/Model name required !/,
  'missing model parameter detected';

throws_ok { $generator->model('SantaClaus') }
  qr/SantaClaus does'nt exist !/,
  'non existent model detected';

ok($generator->model('Basic'), 'ExtJS Basic model generation');
ok($generator->model('Another'), 'ExtJS Another model update');

chdir $oldDir;

done_testing;
