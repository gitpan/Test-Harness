#!/usr/bin/perl -w

BEGIN {
    if ( $ENV{PERL_CORE} ) {
        chdir 't';
        @INC = ( '../lib', 'lib' );
    }
    else {
        unshift @INC, 't/lib';
    }
}

use strict;
use Test::More;
use File::Spec;

my $Curdir       = File::Spec->curdir;
my $SAMPLE_TESTS =
    $ENV{PERL_CORE}
    ? File::Spec->catdir( $Curdir, 'lib', 'sample-tests' )
    : File::Spec->catdir( $Curdir, 't',   'sample-tests' );

my $IsMacPerl = $^O eq 'MacOS';
my $IsVMS     = $^O eq 'VMS';

# VMS uses native, not POSIX, exit codes.
my $die_exit = $IsVMS ? 44 : 1;

# We can only predict that the wait status should be zero or not.
my $wait_non_zero = 1;

my %samples = (
    'with_comments' => {
        passing => 1,
        'exit'  => 0,
        'wait'  => 0,

        max  => 5,
        seen => 5,

        'ok'   => 5,
        'todo' => 4,
        'skip' => 0,
        bonus  => 2,

        details => [
            {
                'ok'        => 1,
                actual_ok   => 0,
                diagnostics => "Failed test 1 in t/todo.t at line 9 *TODO*\n",
                type        => 'todo'
            },
            {
                'ok'      => 1,
                actual_ok => 1,
                reason    => 'at line 10 TODO?!)',
                type      => 'todo'
            },
            {
                'ok'      => 1,
                actual_ok => 1,
            },
            {
                'ok'        => 1,
                actual_ok   => 0,
                diagnostics => "Test 4 got: '0' (t/todo.t at line 12 *TODO*)\n"
                    . "  Expected: '1' (need more tuits)\n",
                type => 'todo'
            },
            {
                'ok'        => 1,
                actual_ok   => 1,
                reason      => 'at line 13 TODO?!)',
                diagnostics => "woo\n",
                type        => 'todo'
            },
        ]
    },
);

plan tests => ( keys(%samples) * 5 ) + 3;

use Test::Harness::Straps;

$SIG{__WARN__} = sub {
    warn @_
        unless $_[0] =~ /^Enormous test number/
        || $_[0]     =~ /^Can't detailize/;
};

for my $test ( sort keys %samples ) {
    my $expect = $samples{$test};

    for ( 0 .. $#{ $expect->{details} } ) {
        $expect->{details}[$_]{type} = ''
            unless exists $expect->{details}[$_]{type};
        $expect->{details}[$_]{name} = ''
            unless exists $expect->{details}[$_]{name};
        $expect->{details}[$_]{reason} = ''
            unless exists $expect->{details}[$_]{reason};
    }

    my $test_path = File::Spec->catfile( $SAMPLE_TESTS, $test );
    my $strap = Test::Harness::Straps->new();
    isa_ok( $strap, 'Test::Harness::Straps' );
    my %results = $strap->analyze_file($test_path);

    is_deeply( $results{details}, $expect->{details}, "$test details" );

    delete $expect->{details};
    delete $results{details};

    SKIP: {
        skip '$? unreliable in MacPerl', 2 if $IsMacPerl;

        # We can only check if it's zero or non-zero.
        is( !!$results{'wait'}, !!$expect->{'wait'}, 'wait status' );
        delete $results{'wait'};
        delete $expect->{'wait'};

        # Have to check the exit status seperately so we can skip it
        # in MacPerl.
        is( $results{'exit'}, $expect->{'exit'} );
        delete $results{'exit'};
        delete $expect->{'exit'};
    } # SKIP

    is_deeply( \%results, $expect, "  the rest $test" );
}    # for %samples

NON_EXISTENT_FILE: {
    my $strap = Test::Harness::Straps->new;
    isa_ok( $strap, 'Test::Harness::Straps' );
    ok( !$strap->analyze_file('I_dont_exist') );
    is( $strap->{error}, "I_dont_exist does not exist" );
}
