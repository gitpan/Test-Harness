print STDERR "[Can we require Test::Harness at all? Only one test]";
print "1..1\n";

unless (eval 'require Test::Harness') {
  print "not ok 1\n";
} else {
  print "ok 1\n";
}
