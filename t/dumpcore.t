print STDERR "[I'm gonna core dump after test 1 of 1]";
$|=1;
# We'll remove the core file in the ok.t script
print <<END;
1..1
ok 1
END

dump;

