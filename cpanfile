requires 'Parse::CPAN::Meta';
requires 'CPAN::Meta::Check';
requires 'Test::Warnings';
requires 'Dancer2'                   => 0.163000;
requires 'Dancer2::Plugin::DBIC';
requires 'DBIx::Class::TimeStamp';
requires 'DateTime';
requires 'Digest::Bcrypt';
requires 'Data::Entropy::Algorithms';
requires 'Dancer2::Plugin::REST';
requires 'Dancer2::Plugin::Feed';
requires 'Dancer2::Plugin::reCAPTCHA';
requires 'Data::GUID';
requires 'String::Dirify';
requires 'String::Random';
requires 'String::Util';
requires 'Data::Pageset';
requires 'Search::Elasticsearch';

requires 'Email::Template';
requires 'Moose';
requires 'XML::Simple';

requires 'Gravatar::URL';
requires 'HTML::Strip';

requires 'DBD::mysql';

# speed up Dancer2
requires 'Scope::Guard';
requires 'URL::Encode::XS';
requires 'CGI::Deurl::XS';
requires 'HTTP::Parser::XS';
requires 'Math::Random::ISAAC::XS';
