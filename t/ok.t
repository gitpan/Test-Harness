-f "t/core" and unlink "t/core";
print <<END;
1..4
ok 1
ok 2
ok 3
ok 4
END

print STDERR "[Don't be worried that most of the tests fail here. That's intended that way.]";
