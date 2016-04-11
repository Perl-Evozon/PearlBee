PearlBee
========

An open source blogging platform written in Perl. [pearlbee.org|http://pearlbee.org/]
### Version
1.0

Setup
=====

You can try it for yourself! All you need is a Unix-based system and a few dependencies installed.

On Ubuntu, before installing, run: sudo apt-get install libssl-dev libxml2 libxml2-dev libxml-libxml-perl libexpat1-dev libexpat1-dev

After the appropriate libraries are installed, you can type:

```
sh build.sh
```

to install the appropriate Perl libraries.

You will also need:

* PostgreSQL version 8.4.20 or higher
* ElasticSearch
* An SMTP database

# Installing / Updating perl modules

or, if cpanm is available (App::cpanminus on CPAN)
run 

```
cpanm --installdeps .
```
in the folder where PearlBee was checked out and the Makefile.PL is.


# Creating the database

Run the mkpasswd script to generate a password for your admin account:

```
$ scripts/mkpasswd <admin_username> <admin_password>
```

Paste this information into db_patches/insert_data.sql, and uncomment the INSERTINTO "user" line.

From the PostgreSQL command line:

```
template1=# create database blogs_perl_org
template1=# \c blogs_perl_org
blogs_perl_org=# \i db_patches/create_tables_Pg.sql
blogs_perl_org=# \i db_patches/insert_data.sql
blogs_perl_org=# \i db_patches/update_sequences.sql
```

You should now have a working PostgreSQL database ready to accept posts.

That's it, now from within the root directory run the following command:

Starting the server
===================

```
plackup bin/app.pl -p 5000

Or:

./scripts/launch-devel
```

And your blog is now running!

### Post-installation

blogs.perl.org uses ElasticSearch for full-text searching of its database. To enable this, please install [ElasticSearch|https://www.elastic.co/] and configure it.

On Linux, 'chkconfig --add elasticsearch' will add ElasticSearch on startup.

You will also need to index your existing blog posts, to do that please run scripts/elasticsearch in the blogs-perl-org repository.

Admin
=====

Once you have started your web server.
Open your browser and go to the url http:://<YOUR_IP>:5000/admin
Use the default login / password to enter, you should change them before starting using the blog!
via "My Account -> Profile".

```
http://127.0.0.1:5000/admin/

user:     $admin_username
password: $admin_password
```

In the News
===========

[Is PearlBee Perl's next great blogging platform?|http://perltricks.com/article/69/2014/2/17/Is-PearlBee-Perl-s-next-great-blogging-platform-] - Perl Tricks

Thank you for using PearlBee!
