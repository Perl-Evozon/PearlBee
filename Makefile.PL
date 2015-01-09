use strict;
use warnings;
use ExtUtils::MakeMaker;

# Normalize version strings like 6.30_02 to 6.3002,
# so that we can do numerical comparisons on it.
my $eumm_version = $ExtUtils::MakeMaker::VERSION;
$eumm_version =~ s/_//;

WriteMakefile(
    NAME         => 'PearlBee',
    AUTHOR       => q{Andrei Cacio <andrei.cacio@evozon.com},
    VERSION_FROM => 'lib/PearlBee.pm',
    ABSTRACT     => 'PealBee is an open source blogging platform',
    (
        $eumm_version >= 6.3001
        ? ( 'LICENSE' => 'perl' )
        : ()
    ),
    PL_FILES  => {},
    PREREQ_PM => {
        'Authen::Captcha'               => 0,
        'Crypt::RandPasswd'             => 0,
        'Dancer2'                       => 0.11,
        'Dancer2::Plugin::DBIC'         => 0,
        'Dancer2::Plugin::REST'         => 0,
        'Data::Entropy::Algorithms'     => 0,
        'Data::Pageset'                 => 0,
        'DateTime'                      => 0,
        'DateTime::Format::MySQL'       => 0,
        'DateTime::Format::Strptime'    => 0,
        'DateTime::TimeZone'            => 0,
        'DBD::mysql'                    => 0,
        'DBI'                           => 0,
        'DBIx::Class'                   => 0,
        'Digest::Bcrypt'                => 0,
        'Digest::MD5'                   => 0,
        'Digest::SHA1'                  => 0,
        'Email::Template'               => 0,
        'Gravatar::URL'                 => 0,
        'MIME::Base64'                  => 0,
        'Plack'                         => 0,
        'String::Dirify'                => 0,
        'Data::GUID'                    => 0,
        'String::Util'                  => 0,
        'Template::Plugin::HTML::Strip' => 0,
        'Test::More'                    => 0,
        'Time::HiRes'                   => 0,
        'YAML'                          => 0,
        'Moose'                         => 0,
        'XML::Simple'                   => 0
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'PearlBee-*' },
);
