#!/usr/bin/perl
use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Files;

use File::Path qw/make_path remove_tree/;
use File::Copy;
use File::Slurp;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use lib "$Bin/lib";

my $oldDir = chdir $Bin;

diag('Testing ExtJS::Generator::DBIC::JsFile ...');

require_ok('ExtJS::Generator::DBIC::JsFile');

ok(my $file = ExtJS::Generator::DBIC::JsFile->new(), 'Load file');
can_ok($file, qw/parse output write/);

throws_ok { $file->parse() }
	qr/File name parameter mandatory/,
	'Missing file parameter';

throws_ok { $file->parse(file => '/non/existant/file.js') }
	qr/Namespace mandatory for first generation/,
	'File loading error if no namespace is specified';

remove_tree('model', 'js');
unlink 'Basic.js';

ok($file->parse(file => 'Basic.js', namespace => 'My.Namespace'), 'Parsing correctly a .js file');

remove_tree('model');

ok($file->parse(file => 'Basic', namespace => 'My.Namespace'), 'Automatically add .js extension if omitted');

is($file->output(), "Ext.define('My.Namespace.model.Basic', {});", 'check file generation');

remove_tree('model');

# Testing parsing an previoulsy generated file

copy('expected_js/02-unmodified-model-Basic.js', 'Basic.js');

ok($file->parse(file => 'Basic.js'), 'Parsing correctly a previously existant .js file');

TODO: {
  local $TODO = 'Should be Basic.js, not ././Basic.js';
  is($file->file, 'Basic.js', 'No extra path part');
}

is($file->file, '././Basic.js', 'File name correctly extracted');

is($file->className, 'File.model.Basic', 'Class name correctly extracted');

is($file->define, q/Ext.define('File.model.Basic', /, 'Define statement correctly extracted');

my $object = read_file('expected_js/02-unmodified-model-object-Basic.js');
chomp $object;
is($file->object, $object, 'Object correctly extracted');

is_deeply($file->methods(), {}, 'No method detected');

is_deeply($file->comments(), {}, 'No comment detected');

is($file->prefix, '', 'No prefix for now');

is($file->suffix, "\n", 'No suffix for now');

my $output = read_file('expected_js/02-unmodified-model-Basic.js');
is($file->output, $output, 'Unmodified Basic.js get as it was');

unlink 'Basic.js';

# Testing parsing an modified file

copy('expected_js/02-modified-model-Basic.js', 'Basic.js');

ok($file->parse(file => 'Basic.js'), 'Parsing correctly a previously existant .js file');

is($file->className, 'File.model.Basic', 'Class name correctly extracted');

is($file->define, q/Ext.define('File.model.Basic', /, 'Define statement correctly extracted');

$object = read_file('expected_js/02-modified-model-object-Basic.js');
chomp $object;
is($file->object, $object, 'Object correctly extracted');

is(scalar keys %{$file->methods()}, 2, '2 methods detected');

is(scalar keys %{$file->comments()}, 4, '4 comments detected');

my $prefix = read_file('expected_js/02-modified-model-prefix-Basic.js');
is($file->prefix, $prefix, 'Initial part correctly captured');

my $suffix = read_file('expected_js/02-modified-model-suffix-Basic.js');
is($file->suffix, $suffix, 'Final part correctly captured');

$output = read_file('expected_js/02-modified-model-Basic.js');
is($file->output, $output, 'Modified Basic.js get as it was');

unlink 'Basic.js';

# Testing parsing an modified file

make_path('js/app/model');
ok(! -e 'Basic.js', "Make sure no more Basic.js in current dir");

copy('expected_js/02-modified-model-Basic.js', 'js/app/model/Basic.js');

ok($file->parse(file => 'js/app/model/Basic.js'), 'Parsing correctly a previously existant .js file');

is($file->className, 'File.model.Basic', 'Class name correctly extracted');

is($file->define, q/Ext.define('File.model.Basic', /, 'Define statement correctly extracted');

$object = read_file('expected_js/02-modified-model-object-Basic.js');
chomp $object;
is($file->object, $object, 'Object correctly extracted');

is(scalar keys %{$file->methods()}, 2, '2 methods detected');

is(scalar keys %{$file->comments()}, 4, '4 comments detected');

$prefix = read_file('expected_js/02-modified-model-prefix-Basic.js');
is($file->prefix, $prefix, 'Initial part correctly captured');

$suffix = read_file('expected_js/02-modified-model-suffix-Basic.js');
is($file->suffix, $suffix, 'Final part correctly captured');

$output = read_file('expected_js/02-modified-model-Basic.js');
is($file->output, $output, 'Modified Basic.js get as it was');

ok($file->write, "Generate modified file");
compare_ok('js/app/model/Basic.js', 'expected_js/02-modified-model-Basic.js', 'Modified file writing');

remove_tree('js');

done_testing;

# cleaning ...
chdir $oldDir;
