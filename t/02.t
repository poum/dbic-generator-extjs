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

ok($file->parse(file => 'Basic.js', namespace => 'My.Namespace'), 'Parsing correctly a .js file');

remove_tree('model');

ok($file->parse(file => 'Basic', namespace => 'My.Namespace'), 'Automatically add .js extension if omitted');

is($file->output(), "Ext.define('My.Namespace.model.Basic', {});", 'check file generation');


ok($file->write(), 'check file writing');

remove_tree('model');

chdir $oldDir;

done_testing;
