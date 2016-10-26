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
<ul>
<li>Authen::Captcha ( needs GD, which neeeds libgd2-xpm-dev package : 'yum install libgd2-xpm-dev', 'yum install gd-devel', 'yum install gd')</li>
<li>XML::Simple ( needs libxml : 'yum install libxml2', 'yum install libxml2-devel')</li>
<li>Crypt::RandPasswd</li>
<li>Dancer2</li>
<li>Dancer2::Plugin::DBIC</li>
<li>Dancer2::Plugin::REST</li>
<li>Data::GUID</li>
<li>Data::Entropy::Algorithms</li>
<li>Data::Pageset</li>
<li>DateTime::Format::Strptime</li>
<li>DateTime</li>
<li>DateTime::TimeZone</li>
<li>DateTime::Format::MySQL</li>
<li>DBI</li>
<li>DBD::mysql and libmysqlclient-dev </li>
<li>DBIx::Class</li>
<li>Crypt::RandPasswd</li>
<li>Digest::Bcrypt</li>
<li>Digest::MD5</li>
<li>Digest::SHA1</li>
<li>Email::Template(if it fails with Warning: prerequisite HTML::FormatText::WithLinks::AndTables not found; prerequisite MIME::Lite 3.01_04 not found needs Test::Pod::Coverage and --f to install)</li>
<li>HTML::Strip</li>
<li>Gravatar::URL</li>
<li>MIME::Base64</li>
<li>Moose</li>
<li>Plack</li>
<li>String::Dirify</li>
<li>String::Util</li>
<li>String::Random</li>
<li>Template</li>
<li>Template::Plugin::HTML::Strip</li>
<li>Text::Unidecode</li>
<li>Time::HiRes</li>

<li>You will need a MySQL/MariaDB server for the blog's database.</li>
<li>You will need a SMTP Server for sending messages. Email are sent automatically by PearlBee in different scenarios like adding a new user </li> 
</ul>

<h4>Installing / Updating perl modules</h4>
<pre><blockquote>./build.sh</blockquote></pre>
>>>>>>> 25251428cdd2f23ddd0d2f92009ba7f996d89548

or, if cpanm is available (App::cpanminus on CPAN)
run 
`cpanm --installdeps .`
in the folder where PearlBee was checked out and the Makefile.PL is.


#### Creating database
You'll need to have installed and running either MySQL or MariaDB. Update the file db_patches/create_tables.sql, replacing 'username' and 'password' with the credentials you'd like the PearlBee system to use. Add these same credentials to the user and pass sections in config.yml.

At the terminal from the root application directory, run this command:
`mysql -u root -p &lt; pearlbee/db_patches/create_tables.sql`

An alternative way of setting up the db is by running this command:
`mysql -u root -p &lt; pearlbee/db_patches/set_up_new_db.sql`

Don't forget to edit your config.yml file at line 44 to enter your mysql password!


That's it, now from within the root directory run the following command:

`plackup -R lib/ bin/app.pl`

Or:

`./scripts/launch-devel`

And your blog is now running!

### Usage

#### Admin
Once you have started your web server.
Open your browser and go to the url http:://<YOUR_IP>:5000/admin
Use the default login / password to enter, you should change them before starting using the blog!
via "My Account -> Profile".

```
http://127.0.0.1:5000/admin/

user:     admin
password: asdf
```

### PearlBee in the news
[Is PearlBee Perl's next great blogging platform?](http://perltricks.com/article/69/2014/2/17/Is-PearlBee-Perl-s-next-great-blogging-platform-) - PerlTricks

Thank you for using PearlBee!
