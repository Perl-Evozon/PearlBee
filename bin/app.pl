#!/usr/bin/env perl

use Config::Any;
use FindBin;
use Term::ANSIColor;
use lib "$FindBin::Bin/../lib";

chdir("$FindBin::Bin/../");

use PearlBee;

my $cfg = Config::Any->load_stems({
  stems   => [ 'config' ],
  use_ext => 1
});
$cfg = $cfg->[0];
$cfg = $cfg->{(keys %$cfg)[0]};

my $error = 0;
$error++ unless -e 'public/avatars';
$error++ unless -e 'public/userpics';
$error++ unless $cfg->{mail_server}{user};
$error++ unless $cfg->{mail_server}{password};
$error++ unless $cfg->{mail_server}{host};

if ( $error ) {
  my $color = 'white on_red';
  warn colored("###################################",$color)."\n";

  -e 'public/avatars' or
    warn colored("Missing public/avatars/ symlink - run '",$color) .
      q{ln -s ~/avatars public/avatars'} .
      colored(q{'},$color);
  -e 'public/userpics' or
    warn colored("Missing public/userpics/ symlink - run '",$color) .
      q{ln -s ~/userpics public/userpics'} .
      colored(q{'},$color);
  
  my $mail_server = $cfg->{mail_server};
  $mail_server->{user} or
    warn colored("Missing mail server user",$color)."\n";
  $mail_server->{password} or
    warn colored("Missing mail server password",$color)."\n";
  $mail_server->{host} or
    warn colored("Missing mail server host",$color)."\n";

  my $reCAPTCHA = $cfg->{plugins}{reCAPTCHA};
  $reCAPTCHA->{site_key} or
    warn colored("Missing reCAPTCHA site key",$color)."\n";
  $reCAPTCHA->{secret} or
    warn colored("Missing reCAPTCHA secret",$color)."\n";

  warn colored("###################################",$color)."\n";
}

PearlBee->dance;
