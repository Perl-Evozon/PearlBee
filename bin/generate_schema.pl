#!/usr/bin/perl

use strict;
use warnings;

use YAML qw( LoadFile );
use FindBin qw( $Bin );

my $config    = LoadFile( "$Bin/../config.yml" );
my $dbic_conf = $config->{ plugins }->{ DBIC }->{ default };

my $dsn  = $dbic_conf->{ dsn };
my $user = $dbic_conf->{ user };
my $pass = $dbic_conf->{ password };

exec(
    qq{dbicdump -o dump_directory=$Bin/../lib PearlBee::Model::Schema "$dsn" "$user" "$pass" }
);
