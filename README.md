<h2>PearlBee</h2>
An open source blogging platform written in Perl. <a href="http://pearlbee.org/">pearlbee.org</a>
<h3>Version</h3>
0.9
<h3>Setup</h3>
You can try it for yourself! All you need is a Unix-based system and a few dependencies installed.

<ul>
<li>make</li>
<li>libplack-perl</li>
<li>Dancer2</li>
<li>Dancer2::Plugin::DBIC</li>
<li>Authen::Captcha ( needs libgd2-xpm-dev package)</li>
<li>Digest::SHA1</li>
<li>String::Dirify</li>
<li>String::Util</li>
<li>DateTime::Format::Strptime</li>
<li>Crypt::RandPasswd</li>
<li>Email::MIME</li>
<li>Email::Sender::Simple</li>
<li>Template::Plugin::HTML::Strip</li>
<li>You will need a MySQL/MariaDB server for the blog's database.</li>
<li>You will need a SMTP Server for sending messages. Email are sent automatically by PearlBee in different scenarios like adding a new user </li> 
</ul>

<h4>Installing / Updating perl modules</h4>
<pre><blockquote>./build.sh</blockquote></pre>

<h4>Creating database</h4>
You'll need to have installed and running either MySQL or MariaDB. To create and configure the database. Update the file db_patches/create_tables.sql, replacing 'username' and 'password' with the credentials you'd like the PearlBee system to use. Add these same credentials to the user and pass sections in config.yml.

At the terminal from the root application directory, run this command:
<pre><blockquote>mysql -u root -p &lt; pearlbee/db_patches/create_tables.sql</blockquote></pre>

That's it, now you just go into the 'pearlbee' folder and run the following command:

<pre><blockquote>plackup -R lib/ bin/app.pl</p></blockquote></pre>

Or:

<pre><blockquote>./scripts/launch-devel</p></blockquote></pre>

And your blog is now running!

<h3>Usage</h3>

<h4>Admin</h4>
Once you have started your web server.
Open your browser and go to the url http:://<YOUR_IP>:5000/admin
Use the default login / password to enter, you should change them before starting using the blog!
via "My Account -> Profile".

<pre><blockquote>http://127.0.0.1:5000/admin/

user:        admin
password: password
</blockquote></pre>


Thank you for using PearlBee!

