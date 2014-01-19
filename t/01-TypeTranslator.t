#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use lib "$Bin/lib";

my $oldDir = chdir $Bin;

diag('Testing ExtJS::Generator::DBIC::TypeTranslator ...');

require_ok('ExtJS::Generator::DBIC::TypeTranslator');

my $translator;

ok($translator = ExtJS::Generator::DBIC::TypeTranslator->new(), 'type translator loaded correctly');
can_ok($translator, qw/translate/);

is($translator->translate('varchar'), 'string', 'known type correctly translated');
is($translator->translate('point'), 'float', 'known type correctly translated');
is($translator->translate('von Bismarck'), 'auto', 'unknown type correctly translated to auto');

done_testing;

chdir $oldDir;
