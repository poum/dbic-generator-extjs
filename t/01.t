use strict;
use warnings;

use Test::More;
use Test::Exception;

use Data::Dumper; 

use FindBin qw($Bin);
use lib "$Bin/../lib";
use lib "$Bin/lib";

my $oldDir = chdir $Bin;

require_ok('DBICx::Generator::ExtJS');

my $generator;

throws_ok { $generator= DBICx::Generator::ExtJS->new() } 
  qr/Attribute \(schema_name\) is required/, 
  'schema_name parameter required';

throws_ok { $generator = DBICx::Generator::ExtJS->new(schema_name => 'Sorry::No::Schema::Here') } 
  qr/Unable to found\/load Sorry::No::Schema::Here/, 
  'non existent schema detected';

ok($generator = DBICx::Generator::ExtJS->new(schema_name => 'My::Schema'), 'existant schema loaded correctly');

is_deeply($generator->tables, [qw/Another Basic/], 'schema tables found');

throws_ok { $generator->translateType() }
  qr/Missing schema type to translate !/,
  'missing translateType parameter detected';

is($generator->translateType('varchar'), 'string', 'known type correctly translated');
is($generator->translateType('point'), 'float', 'known type correctly translated');
is($generator->translateType('von Bismarck'), 'auto', 'unknown type correctly translated to auto');

throws_ok { $generator->model() }
  qr/Model name required !/,
  'missing model parameter detected';

throws_ok { $generator->model('SantaClaus') }
  qr/SantaClaus does'nt exist !/,
  'non existent model detected';

ok($generator->model('Basic'), 'ExtJS Basic model generation');

chdir $oldDir;

done_testing;
