use strict;
use warnings;
use Acme::Alien::DontPanic ();
use ExtUtils::CBuilder;
use Test::More tests => 3;
use File::Spec;
use Capture::Tiny qw( capture_merged );

my $b = ExtUtils::CBuilder->new;

ok $b->have_compiler, 'we have a compiler!';

my $src = File::Spec->catfile(qw(
  t static_link main.c
));

my $include_dirs = [
  File::Spec->catfile(qw(
    _alien dontpanic-1.0 src
  ))
];

my $extra_linker_flags = join ' ', (map { "-L$_" } (
  File::Spec->catfile(qw(
    _alien dontpanic-1.0 src
  )),
  File::Spec->catfile(qw(
    _alien dontpanic-1.0 src .libs
  )),
), Acme::Alien::DontPanic->libs);
  

note "src = $src";

my($compile_output, $obj) = capture_merged {
  eval {
    $b->compile(
      source               => $src,
      include_dirs         => $include_dirs,
      extra_compiler_flags => Acme::Alien::DontPanic->cflags,
    );
  };
};
note $compile_output;

ok defined $obj && -r $obj, "compiled $obj";

my($link_output, $lib) = capture_merged {
  eval { 
    $b->link(
      objects => [ $obj ],
      extra_linker_flags => $extra_linker_flags,
    );
  };
};
note $link_output;

ok defined $lib && -r $lib, "linked $lib";
