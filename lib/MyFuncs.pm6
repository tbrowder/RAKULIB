unit module MyFuncs;

use Test;

use File::Compare;

use Proc::More :run-command;

my $debug = 0;

sub compare-files($f1, $f2, :$time, :$size) is export(:compare-files) {
    # default is to compare contents
    my $err = 0;
    my @fils = $f1, $f2;

    for @fils -> $f {
	if !$f.IO.f {
	    note "WARNING: File '$f' doesn't exist." if $debug;
	    ++$err;
	}
    }
    return False if $err;

    if $size {
	my $s1 = $f1.IO.s;
	my $s2 = $f2.IO.s;
	if  $s1 != $s2 {
	    note "WARNING: Sizes of files '$f1' ($s1) and '$f2' ($s2) are different." if $debug;
	}
	return $s1, $s2;
    }

    if $time {
	# use modify method (last time file was changed; that will be
	# creation time if no changes since then)
	my $m1 = $f1.IO.modified;
	my $m2 = $f2.IO.modified;
	if  $m1 < $m2 {
	    note "WARNING: File '$f1' is older than '$f2'." if $debug;
	}
	return $m1, $m2;

    }

    # default
    return files_are_equal($f1, $f2);

} # compare-files

sub backup-file($fil, :$force, :$suff = 'bak') is export(:backup-file) {
    if !$fil.IO.f {
	note "WARNING: File '$fil' doesn't exist.";
	return;
    }
    my $bfil = $fil ~ '.' ~ $suff;
    # don't overwrite an existing file!
    rename $fil, $bfil, :createonly($force);
} # backup-file

sub gen-cleartext-password(UInt $pwlen where { $pwlen > 7} = 8) is export(:gen-cleartext-password) {
    # uses program 'pwgen'  as a good source of medium security passwords
    my $cmd = "pwgen -nvBc $pwlen 1"; # see man pwgen for details
    my $password = run-command $cmd, :out;
    $password .= trim;

    return $password;
} # gen-cleartext-password

sub gen-htbasic-password($user, $password) is export(:gen-htbasic-password) {
    # uses apache program 'htpasswd'
    # using for non-file purposes (such as dbd):
    #   htpasswd -nb [ -m | -B | -d | -s | -p ] [ -C cost ] username password
    #   running: htpasswd -nBb username password
    #   yields:  username:$2y$05$TqXeGfTy1OMoSovnunVxAOPsmZWCQ67xLrAlC5WS.BKFzSI6MGgWm
    #   note the actual encrypted results vary each time it is run
    # according to apache docs, use the passwords exactly as generated in the dbd file
    my $cmd = "htpasswd -nBb $user $password"; # see man htpasswd for details (-B uses bcrypt, most secure method)
    my $encrypted-password = run-command $cmd, :out;
    $encrypted-password .= trim;

    return $encrypted-password;
} # gen-htbasic-password
