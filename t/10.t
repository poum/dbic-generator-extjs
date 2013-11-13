#!/usr/bin/perl
use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Files;

use File::Path qw/make_path remove_tree/;
use File::Copy;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use lib "$Bin/lib";

# name of models we have to generate
my @models = qw/Another Basic/;
# path of generated files (w/o trailing slash)
my $gpath = './js/app';
# path of expected files (w/o traling slash)
my $epath = './expected_js';

diag('Testing ExtJS::Generator::DBIC ...');

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

is_deeply($generator->tables, [ @models ], 'schema tables found');

# Testing model / models (re)generation ...
TODO: {
  local $TODO = "put in a specific test file";
  ok(0);
}

throws_ok { $generator->model() }
  qr/Model name required !/,
  'missing model parameter detected';

throws_ok { $generator->model('SantaClaus') }
  qr/SantaClaus doesn't exist !/,
  'non existent model detected';

foreach my $model (@models) {
    ok($generator->model($model), "ExtJS $model model generation");
    equivalent_files_ok("model/$model.js", "10-unmodified-model-$model.js", "Generated ExtJS $model model ok");
}

remove_tree('js');

ok($generator->models(), 'Extjs model global generation');

foreach my $model (@models) {
    equivalent_files_ok("model/$model.js", "10-unmodified-model-$model.js", 'Generated ExtJS ' . $model . ' model ok');
}

BAIL_OUT("houba");

ok($generator->models(), 'Extjs model global regeneration');

foreach my $model (@models) {
    ok(-e "$gpath/model/$model.js.bak", "$model backup exists");
    equivalent_files_ok("model/$model.js.bak", "10-unmodified-model-$model.js", "Generated ExtJS $model backup ok");
    equivalent_files_ok("model/$model.js", "10-unmodified-model-$model.js", "Generated ExtJS $model model ok");
    copy("$epath/10-modified-model-$model.js", "$gpath/model/$model.js");
}
   
diag('#' x 30); 
ok($generator->models(), 'Extjs model global regeneration from modified files');
diag('#' x 30); 

foreach my $model (@models) {
    ok(-e "$gpath/model/$model.js.bak", "$model backup exists");
    equivalent_files_ok("model/$model.js.bak", "10-modified-model-$model.js", "Regenerated ExtJS $model backup ok");
    equivalent_files_ok("model/$model.js", "10-modified-model-$model.js", "Regenerated ExtJS $model model ok");
    diag("model/$model.js" . ' *** ' . "10-modified-model-$model.js");
}


# Testing store / stores (re)generation ...
TODO: {
  local $TODO = "put in a specific test file";
  ok(0);
}

=cut
throws_ok { $generator->store() }
  qr/Store name required !/,
	'missing store parameter detected';

throws_ok { $generator->store('BigFoot') }
	qr/BigFoot doesn't exist !/,
	'non existent store detected';

ok($generator->store('Basic'), 'ExtJS Basic store generation');
compare_ok('./js/app/store/Basic.js', './expected_js/10-unmodified-store-Basic.js', 'Generated ExtJS Basic store ok');

ok($generator->store('Another'), 'ExtJS Another store generation');
compare_ok('./js/app/store/Another.js', './expected_js/10-unmodified-store-Another.js', 'Generated ExtJS Another store ok');

remove_tree('js');
ok($generator->stores(), 'ExtJS store global generation');
compare_ok('./js/app/store/Basic.js', './expected_js/10-unmodified-store-Basic.js', 'Generated ExtJS Basic store ok');
compare_ok('./js/app/store/Another.js', './expected_js/10-unmodified-store-Another.js', 'Generated ExtJS Another store ok');

copy('./expected_js/10-modified-store-Basic.js', './js/app/store/Basic.js');
copy('./expected_js/10-modified-store-Another.js', './js/app/store/Another.js');

remove_tree('js');

TODO: {
  local $TODO = "put in a specific test file";
  ok(0);
}
ok($generator->mvc(), 'ExtJS global generation');
compare_ok('./js/app/model/Basic.js', './expected_js/10-unmodified-model-Basic.js', 'Generated ExtJS Basic model ok');
compare_ok('./js/app/model/Another.js', './expected_js/10-unmodified-model-Another.js', 'Generated ExtJS Another model ok');
compare_ok('./js/app/store/Basic.js', './expected_js/10-unmodified-store-Basic.js', 'Generated ExtJS Basic store ok');
compare_ok('./js/app/store/Another.js', './expected_js/10-unmodified-store-Another.js', 'Generated ExtJS Another store ok');
=cut

done_testing;

# cleaning
remove_tree('js');
chdir $oldDir;

# compare file stripping integer quoting and newline after main object
TODO: {
  local $TODO = "put in a test lib module";
  ok(0);
}
sub equivalent_files_ok {
  my ($file1, $file2, $msg) = @_;
  $file1 = "$gpath/$file1";
  $file2 = "$epath/$file2";
  compare_filter_ok($file1, $file2, \&filter_int_eof, $msg);
}

# Remove quotes around integer in defaultValue
# and newline after }); ending the object
# causing false alarm test failure 
sub filter_int_eof {
    my $line = shift;
    $line =~ s/(defaultValue:)(")(\d+)\2/$1$3/g;
    $line =~ s/\}\);\n*$/\}\);/;

    return $line;
}
