require 5.004;

use ExtUtils::MakeMaker;
use ExtUtils::Command qw( touch rm_f );

warn "Test::Harness likes to have Devel::CoreStack, but doesn't require it.\n"
  unless eval { require Devel::CoreStack; 1 };

use constant FLAG_SKIP_PROVE => "t/SKIP-PROVE";

my %parms = (
    NAME            => "Test::Harness",
    VERSION_FROM    => "lib/Test/Harness.pm",
    PREREQ_PM       => { File::Spec => 0.6 },
    INSTALLDIRS     => 'perl',
    clean	    => { FILES => join( " ", FLAG_SKIP_PROVE, 'Test-Harness-*', '*~' ) },
);

my $install_prove = eval "use Pod::Usage 1.12; 1";
if ( $install_prove ) {
    $parms{EXE_FILES} = [ 'bin/prove' ];
    local @ARGV = FLAG_SKIP_PROVE;
    rm_f();
} else {
    warn "Pod::Usage 1.12 or higher not found, so prove utility will not be installed.\n";
    local @ARGV = FLAG_SKIP_PROVE;
    touch();
}

WriteMakefile( %parms );
