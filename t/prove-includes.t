BEGIN {
    if( $ENV{PERL_CORE} ) {
        chdir 't';
        @INC = ('../lib', 'lib');
    }
    else {
        unshift @INC, 't/lib';
    }
}

use strict;
use File::Spec;
use Test::More;
plan skip_all => "Not installing prove" if -e "t/SKIP-PROVE";

plan tests=>1;
local $/ = undef;

my $prove = File::Spec->catfile( qw( blib script prove ) );
my $actual = qx/$prove -d -v -Ifirst -I second -Ithird -T -b/;
my $expected = <DATA>;
is( $actual, $expected, "Proper flags found" );

__DATA__
# $Test::Harness::Switches: -Iblib/lib -Ifirst -Isecond -Ithird -T
