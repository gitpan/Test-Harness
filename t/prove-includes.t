BEGIN {
    eval "use Test::More";
    if ($@) {
	print "1..0 # SKIPPED: Test::More not installed.\n";
	exit;
    }
}

use File::Spec;
use strict;

plan tests=>1;
local $/ = undef;

my $prove = File::Spec->catfile( qw( blib script prove ) );
my $actual = qx/$prove -d -v -Ifirst -I second -Ithird -b/;
my $expected = <DATA>;
is( $actual, $expected, "Matched expected output" );

__DATA__
# $Test::Harness::Switches: -Iblib/lib -Ifirst -Isecond -Ithird
