print STDERR "[I'm gonna die after test 2 of 5]";
print <<END;
1..5
ok 1
ok 2
END

die "[I'm dying]";
