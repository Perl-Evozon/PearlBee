## PearlBee
An open source blogging platform written in Perl. [pearlbee.org](http://pearlbee.org/)
### Version
1.0

### Setup
You can try it for yourself! All you need is a Unix-based system and a few dependencies installed.

<<<<<<< HEAD
- Authen::Captcha ( needs GD, which neeeds libgd2-xpm-dev package : 'yum install libgd2-xpm-dev', 'yum install gd-devel', 'yum install gd')
- XML::Simple ( needs libxml : 'yum install libxml2', 'yum install libxml2-devel')
- Crypt::RandPasswd
- Dancer2
- Dancer2::Plugin::DBIC
- Dancer2::Plugin::REST
- Data::GUID
- Data::Entropy::Algorithms
- Data::Pageset
- DateTime::Format::Strptime
- DateTime
- DateTime::TimeZone
- DateTime::Format::MySQL
- DBI
- DBD::mysql and libmysqlclient-dev
- DBIx::Class
- Crypt::RandPasswd
- Digest::Bcrypt
- Digest::MD5
- Digest::SHA1
- Email::Template
- HTML::Strip
- Gravatar::URL
- MIME::Base64
- Moose
- Plack
- String::Dirify
- String::Util
- String::Random
- Template
- Template::Plugin::HTML::Strip
- Text::Unidecode
- Time::HiRes

- You will need a MySQL/MariaDB server for the blog's database.
- You will need a SMTP Server for sending messages. Email are sent automatically by PearlBee in different scenarios like adding a new user

#### Installing / Updating perl modules
`./build.sh`
=======
or, if cpanm is available (App::cpanminus on CPAN) run cpanm --installdeps . in the folder where PearlBee was checked out and the Makefile.PL is.

Creating database

You'll need to have installed and running either MySQL or MariaDB. Update the file db_patches/create_tables.sql, replacing 'username' and 'password' with the credentials you'd like the PearlBee system to use. Add these same credentials to the user and pass sections in config.yml.

At the terminal from the root application directory, run this command: mysql -u root -p &lt; pearlbee/db_patches/create_tables.sql

An alternative way of setting up the db is by running this command: mysql -u root -p &lt; pearlbee/db_patches/set_up_new_db.sql

That's it, now from within the root directory run the following command:

plackup -R lib/ bin/app.pl

Or:

./scripts/launch-devel

And your blog is now running!

Usage

Admin

Once you have started your web server. Open your browser and go to the url http:://:5000/admin Use the default login / password to enter, you should change them before starting using the blog! via "My Account -> Profile".

http://127.0.0.1:5000/admin/

user:     admin
password: asdf
PearlBee in the news

Is PearlBee Perl's next great blogging platform? - PerlTricks

Thank you for using PearlBee!
