<h2>PearlBee</h2>
An open source blogging platform written in Perl. <a href="http://pearlbee.org/">pearlbee.org</a>
<h3>Version</h3>
0.9
<h3>Setup</h3>
You can try it for yourself! All you need is a linux system and a few dependencies installed.

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
<li>
You will need a MySQL server for the blog's database.</li></ul>
<h4>Creating database</h4>
After you've downloaded PearlBee source code, be sure to create the database by running the command: 

<pre><blockquote>mysql -u your_user -p your_password &lt; pearlbee/db_patches/create_tables.sql</blockquote></pre>

After the database creation, you will need to configure the following file: pearlbee/config.yaml
Under the user and pass tag, please write down your own database credentials.
<p>
That's it, now you just go into the 'pearlbee' folder and run the following command:  

<pre><blockquote>plackup -R lib/ bin/app.pl</p></blockquote></pre>

And your blog is now running. 

Thank you for using PearlBee!

