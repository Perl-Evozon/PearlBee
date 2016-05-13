#!/usr/bin/env perl

use Config::Any;
use FindBin;
use Term::ANSIColor;
use lib "$FindBin::Bin/../lib";

chdir("$FindBin::Bin/../");

use PearlBee;

# Read config
my $cfg = Config::Any->load_stems({
  stems   => [ 'config' ],
  use_ext => 1
});
$cfg = $cfg->[0];
$cfg = $cfg->{(keys %$cfg)[0]};

# Needed for mail server
my $mail_server_host = $cfg->{mail_server}{host};
my $mail_server_user = $cfg->{mail_server}{user};
my $mail_server_password = $cfg->{mail_server}{password} || $ENV{bpo_mail_server_password};

# Needed for captcha
my $recaptcha_site_key = $cfg->{plugins}{reCAPTCHA}{site_key} || $ENV{bpo_recaptcha_site_key};
my $recaptcha_secret = $cfg->{plugins}{reCAPTCHA}{secret} || $ENV{bpo_recaptcha_secret};

# Needed for login with facebook
my $facebook_client_id = $cfg->{plugins}->{social_media}->{facebook}->{client_id} || $ENV{bpo_social_media_facebook_client_id};
my $facebook_client_secret = $cfg->{plugins}->{social_media}->{facebook}->{client_secret} || $ENV{bpo_social_media_facebook_client_secret};

# Needed for login with twitter
my $twitter_consumer_key = $cfg->{plugins}->{social_media}->{twitter}->{consumer_key} || $ENV{bpo_social_media_twitter_consumer_key};
my $twitter_consumer_secret = $cfg->{plugins}->{social_media}->{twitter}->{consumer_secret} || $ENV{bpo_social_media_twitter_consumer_secret};

# Needed for login with google
my $google_client_id = $cfg->{plugins}->{social_media}->{google}->{client_id} || $ENV{bpo_social_media_google_client_id};
my $google_client_secret = $cfg->{plugins}->{social_media}->{google}->{client_secret} || $ENV{bpo_social_media_google_client_secret};

# Misc
my $color = 'white on_red';
my $delimiter = "###################################";
my $message;

# Buffer all the warnings
$message .= ( "Missing public/avatars/ symlink - run '" . q{ln -s ~/avatars public/avatars'} . "'\n" ) unless -e 'public/avatars';
$message .= ( "Missing public/userpics/ symlink - run '" . q{ln -s ~/userpics public/userpics'} . "'\n" ) unless -e 'public/userpics';

$message .= "Missing mail server host\n" unless $mail_server_host;
$message .= "Missing mail server user\n" unless $mail_server_user;
$message .= "Missing mail server password\n" unless $mail_server_password;

$message .= "Missing reCaptcha site key\n" unless $recaptcha_site_key;
$message .= "Missing reCaptcha secret\n" unless $recaptcha_secret;

$message .= "Missing facebook client_id\n" unless $facebook_client_id;
$message .= "Missing facebook client_secret\n" unless $facebook_client_secret;

$message .= "Missing twitter consumer_key\n" unless $twitter_consumer_key;
$message .= "Missing twitter consumer_secret\n" unless $twitter_consumer_secret;

$message .= "Missing google client_id\n" unless $google_client_id;
$message .= "Missing google client_secret\n" unless $google_client_secret;

# Spit out the warnings
if ($message) {
  $message = $delimiter . "\n" . $message . $delimiter;
  warn "\n".colored($message, 'white on_red')."\n";
}

# Start dancing
PearlBee->dance;
