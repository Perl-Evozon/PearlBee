requires 'Parse::CPAN::Meta';
requires 'CPAN::Meta::Check';
requires 'Test::Warnings';
requires 'Term::ANSIColor';
requires 'Dancer2'                   => 0.163000;
requires 'Dancer2::Plugin::DBIC';
requires 'DBIx::Class::TimeStamp';
requires 'DateTime';
requires 'DateTime::Format::Pg';
requires 'Date::Period::Human';
requires 'Digest::Bcrypt';
requires 'Data::Entropy::Algorithms';
requires 'Dancer2::Plugin::REST';
requires 'Dancer2::Plugin::Feed', '< 1.160190'; # Later versions change Atom
requires 'Dancer2::Plugin::reCAPTCHA';
requires 'Data::GUID';
requires 'String::Dirify';
requires 'String::Random';
requires 'String::Util';
requires 'Data::Pageset';
requires 'Search::Elasticsearch';

requires 'Imager';
requires 'IO::All';
requires 'MIME::Lite';
requires 'MIME::Lite::TT';
requires 'Email::MIME';
requires 'Email::Sender::Simple';
requires 'Email::Sender::Transport::SMTP::TLS';
requires 'Email::Template';
requires 'Moose';
requires 'XML::Simple';

requires 'Gravatar::URL';
requires 'HTML::Scrubber::StripScripts';
requires 'Text::Markdown';

requires 'DBD::Pg';

# speed up Dancer2
requires 'Scope::Guard';
requires 'URL::Encode::XS';
requires 'CGI::Deurl::XS';
requires 'HTTP::Parser::XS';
requires 'Math::Random::ISAAC::XS';
