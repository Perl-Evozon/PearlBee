#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/../lib";

chdir("$FindBin::Bin/../");

use PearlBee;

PearlBee->dance;
