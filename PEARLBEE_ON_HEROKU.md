To deploy Pearlbee on heroku follow this steps:

1)Make sure your capnfile has this dependencies :

* requires 'DBIx::Class';
* requires 'DBIx::Class::Schema::Loader';
* requires 'DateTime::Format::Pg';

* requires 'Dancer2' => 0.163000;
* requires 'Dancer2::Plugin::DBIC';
* requires 'Dancer2::Plugin::REST';

* requires 'DateTime';
* requires 'DateTime::TimeZone';
* requires 'Data::GUID';
* requires 'String::Dirify';
* requires 'String::Random';
* requires 'String::Util';
* requires 'Data::Pageset';
* requires 'Moose';
* requires 'LWP::UserAgent';
* requires 'LWP::Simple';
* requires "DBD::Pg" => "3.5.3";
* requires 'Email::Template';
* requires 'XML::Simple';
* requires 'Digest';
* requires 'Digest::Bcrypt';
* requires 'Data::Entropy::Algorithms';
* requires 'MIME::Base64';
* requires 'Gravatar::URL';
* requires 'HTML::Strip';
* requires 'Template::Plugin::HTML::Strip';
* requires 'Data::Dumper';
* requires 'Net::SSLeay';
* requires 'IO::Socket::SSL';
* requires 'WebService::CaptchasDotNet';
* requires 'Plack', '1.0000';
* requires 'Template', '2.26';


* requires 'Scope::Guard';
* requires 'URL::Encode::XS';
* requires 'CGI::Deurl::XS';
* requires 'HTTP::Parser::XS';
* requires 'Math::Random::ISAAC::XS';

* requires 'MooseX::Types::JSON';
* requires 'MooseX::Types::LoadableClass';
* requires 'MooseX::Types::Path::Class';

2)git init
3)git add .
4)heroku create --stack cedar --buildpack https://github.com/miyagawa/heroku-buildpack-perl.git
5)git push heroku master

6) add a database addon on Heroku using this command : heroku addons:add heroku-postgresql

7)Create a postgres database localy.

8)Push your local database to heroku with the command :
PGUSER=your_postgres_username PGPASSWORD=your_postgres_password heroku pg:push your_local_db_name DATABASE_URL your_heroku_db_url .
9)Register on http://captchas.net and add the secret code and user name in lib/PearlBee.pm at line 56:
    my $captcha = WebService::CaptchasDotNet->new(secret   => 'g4VE1IEwYCGjCM7M14Mwy8GOILJUuGJH4wt9DP5H',
                                            username =>   'drd_drd',
                                            alphabet => 'abcdefghkmnopqrstuvwxyz',
                                            expire   => 1800); 


