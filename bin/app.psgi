#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/../lib";
use lib 'lib';
use PearlBee::Model::Schema;

chdir("$FindBin::Bin/../");

use PearlBee;

PearlBee->dance;
