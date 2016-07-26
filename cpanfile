requires 'DBIx::Class';
requires 'DBIx::Class::Schema::Loader';
requires 'DateTime::Format::Pg';

requires 'Dancer2' => 0.163000;
requires 'Dancer2::Plugin::DBIC';
requires 'Dancer2::Plugin::REST';
requires 'Dancer2::Plugin::reCAPTCHA';
requires 'DateTime';
requires 'DateTime::TimeZone';
requires 'Data::GUID';
requires 'String::Dirify';
requires 'String::Random';
requires 'String::Util';
requires 'Data::Pageset';
requires 'Moose';
requires 'LWP::UserAgent';
requires 'LWP::Simple';
requires "DBD::Pg" => "3.5.3";
requires 'Email::Template';
requires 'XML::Simple';
requires 'Digest';
requires 'Digest::Bcrypt';
requires 'Data::Entropy::Algorithms';
requires 'MIME::Base64';
requires 'Gravatar::URL';
requires 'HTML::Strip';
requires 'Template::Plugin::HTML::Strip';
requires 'Data::Dumper';
requires 'Net::SSLeay';
requires 'IO::Socket::SSL';

requires 'Plack', '1.0000';
requires 'Template', '2.26';

# speed up Dancer2
requires 'Scope::Guard';
requires 'URL::Encode::XS';
requires 'CGI::Deurl::XS';
requires 'HTTP::Parser::XS';
requires 'Math::Random::ISAAC::XS';

requires 'MooseX::Types::JSON';
requires 'MooseX::Types::LoadableClass';
requires 'MooseX::Types::Path::Class';
