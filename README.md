PearlBee v0.9

Welcome to the PearlBee bloggin platform. It's Open Source, it's written in Perl and it's very practical!

Site: www.pearlbee.org

You can try it for yourself! All you need is a linux system and a few dependencies installed.

Dependencies:

make
libplack-perl

Perl modules:

Dancer2
Dancer2::Plugin::DBIC
Authen::Captcha ( needs libgd2-xpm-dev package)
Digest::SHA1
String::Dirify
String::Util
DateTime::Format::Strptime
Crypt::RandPasswd
Email::MIME
Email::Sender::Simple
Template::Plugin::HTML::Strip

You will need a MySQL server for the blog's database.
After you've downloaded PearlBee source code, be sure to create the database by running the command: mysql -u your_user -p your_password < pearlbee/db_patches/create_tables.sql
After the database creation, you will need to configure the following file: pearlbee/config.yaml
Under the user and pass tag, please write down your own database credentials.

That's it, now you just go into the 'pearlbee' folder and run the following command:  plackup -R lib/ bin/app.pl and your blog is now running

Thank you for using PearlBee!

