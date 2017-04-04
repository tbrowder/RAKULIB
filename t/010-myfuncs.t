use v6;
use Test;

use File::Temp;

use MyFuncs :ALL;

plan 3;

# some test files
my ($f1, $fh1) = tempfile;
my ($f2, $fh2) = tempfile;
$fh1.print: 'text';
$fh1.close;
$fh2.print: 'text';
$fh2.close;

ok compare-files $f1, $f2;
lives-ok { compare-files $f1, $f2, :size; }
lives-ok { compare-files $f1, $f2, :time; }
