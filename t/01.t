use strict;
use warnings;

use Test::More;
use lib 't/lib';
use lib 'lib';

require_ok('DBICx::Generator::ExtJS');

my $generator = DBICx::Generator::ExtJS->new('My::Schema');

ok($generator);

done_testing;
