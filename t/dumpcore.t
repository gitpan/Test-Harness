print STDERR "[I'm gonna core dump after test 1 of 1]";
-d "t" and chdir "t";
# We'll remove the core file in the ok.t script
print <<END;
1..1
ok 1
END

dump;

