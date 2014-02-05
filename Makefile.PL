use strict;
use warnings;
use ExtUtils::MakeMaker;

# Normalize version strings like 6.30_02 to 6.3002,
# so that we can do numerical comparisons on it.
my $eumm_version = $ExtUtils::MakeMaker::VERSION;
$eumm_version =~ s/_//;

WriteMakefile(
    NAME                => 'PearlBee',
    AUTHOR              => q{Andrei Cacio <andrei.cacio@evozon.com},
    VERSION_FROM        => 'lib/PearlBee.pm',
    ABSTRACT            => 'PealBee is an open source blogging platform',
    ($eumm_version >= 6.3001
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'                    => 0,
        'YAML'                          => 0,
        'Dancer2'                       => 0.11,
        'Dancer2::Plugin::DBIC'         => 0,
        'Authen::Captcha'               => 0,
        'Digest::SHA1'                  => 0,
        'String::Dirify'                => 0,
        'String::Util'                  => 0,
        'DateTime::Format::Strptime'    => 0,
        'Crypt::RandPasswd'             => 0,
        'Email::MIME'                   => 0,
        'Email::Sender::Simple'         => 0,
        'Template::Plugin::HTML::Strip' => 0,
        'Email::Template'               => 0
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'PearlBee-*' },
);
