#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/../lib";

chdir("$FindBin::Bin/../");

use PearlBee;

unless ( -e 'public/avatars' and
         -e 'public/userpics' ) {
  -e 'public/avatars' or die "Missing public/avatars/' symlink\n";
  -e 'public/userpics' or die "Missing public/userpics/' symlink\n";
}

PearlBee->dance;
