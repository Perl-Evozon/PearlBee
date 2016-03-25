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
        'Parse::CPAN::Meta'          => 0,
        'CPAN::Meta::Check'          => 0,
        'Test::Warnings'             => 0,
        'Term::ANSIColor'            => 0,
        'Dancer2'                    => 0.136000,
        'Dancer2::Plugin::DBIC'      => 0,
        'DBIx::Class::TimeStamp'     => 0,
        'DateTime'                   => 0,
        'Date::Period::Human'        => 0,
        'Digest::Bcrypt'             => 0,
        'Data::Entropy::Algorithms'  => 0,
        'Dancer2::Plugin::REST'      => 0,
        'Dancer2::Plugin::Feed'      => 0,
        'Dancer2::Plugin::reCAPTCHA' => 0,
        'Data::GUID'                 => 0,
        'String::Dirify'             => 0,
        'String::Random'             => 0,
        'String::Util'               => 0,
        'Data::Pageset'              => 0,
        'Text::Markdown'             => 0,

        'IO::All'                             => 0,
        'MIME::Lite'                          => 0,
        'MIME::Lite::TT'                      => 0,
        'Email::MIME'                         => 0,
        'Email::Sender::Simple'               => 0,
        'Email::Sender::Transport::SMTP::TLS' => 0,
        'Email::Template'                     => 0,
        'Moose'                               => 0,
        'XML::Simple'                         => 0,

        'Search::Elasticsearch'      => 0,

        # Dynamically loaded dependencies now

        'Gravatar::URL'              => 0,
        'HTML::Strip'                => 0,

        'DBD::Pg'                    => 0,

    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'PearlBee-*' },
);
