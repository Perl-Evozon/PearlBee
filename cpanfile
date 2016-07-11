requires 'DBIx::Class';
requires 'GD', '2.56';
requires 'Dancer2' => 0.163000;
requires 'Dancer2::Plugin::DBIC';
requires 'Dancer2::Plugin::REST';
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
requires 'Authen::Captcha', '1.024';
requires 'Email::Template';
requires 'XML::Simple';
requires 'Digest';
requires 'Digest::Bcrypt';
requires 'Data::Entropy::Algorithms';
requires 'MIME::Base64';
requires 'Gravatar::URL';
requires 'HTML::Strip';
requires 'Template::Plugin::HTML::Strip';

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
