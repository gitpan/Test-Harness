print "1..3\n";

my $test_num = 1;
sub ok ($;$) {
    my($test, $name) = @_;
    my $okstring = '';
    $okstring = "not " unless $test;
    $okstring .= "ok $test_num";
    $okstring .= " - $name" if defined $name;
    print "$okstring\n";
    $test_num++;
}

use Test::Harness::Assert;

ok( defined &assert,                'assert() exported' );

ok( !eval { assert( 0 ); 1 },       'assert( FALSE ) causes death' );
ok( eval { assert( 1 );  1 },       'assert( TRUE ) does nothing' );
