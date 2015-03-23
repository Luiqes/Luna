Luna
====

Club Penguin Server Emulator - AS2 Protocol

### Requirements:
<ul>
 <li> Perl 5.10+</li>
 <li> Apache/Nginx</li>
 <li> Phpmyadmin/Adminer</li>
 <li> MYSQL</li>
 <li> Internet Connection</li>
</ul>

### Instructions:
<ul>
 <li> Setup an AS2 Media Server</li>
 <li> Install all the Perl modules from the list below</li>
 <li> Import the <b>Database.sql</b> from the <b>SQL</b> folder using <b>Phpmyadmin/Adminer</b></li>
 <li> Setup the <b>Register</b> and create an account</li>
 <li> Edit <b>Config.pl</b> from the <b>Configuration</b> folder</li>
 <li> Execute <b>Run.pm</b></li>
</ul>

### Usage:

Open <b>Terminal/Cmd</b> and type the following:

<code>cd /tmp/Luna</code>

and then type:

<code>perl Run.pm</code>

If you are using Windows, you can use the <b>Run.bat</b>

### Modules: 
<ul>
 <li> CPAN</li>
 <li> Method::Signatures</li>
 <li> HTML::Entities</li>
 <li> IO::Socket</li>
 <li> IO::Select</li>
 <li> Digest::MD5</li>
 <li> XML::Simple</li>
 <li> LWP::Simple</li>
 <li> Cwd</li>
 <li> JSON</li>
 <li> Coro</li>
 <li> DBI</li>
 <li> DBD::mysql</li>
 <li> Module::Find</li>
 <li> List::Compare</li>
 <li> HTTP::Date</li>
 <li> Math::Round</li>
 <li> POSIX</li>
 <li> Captcha::AreYouAHuman</li>
 <li> CGI</li>
 <li> Switch</li>
 <li> File::Basename</li>
 <li> File::Fetch</li>
</ul>

<u><b>Important Note:</b></u> After you install <b>CPAN</b>, type <code>reload cpan</code> and continue installing the other modules

### Tutorials:
<ul>
 <li><a href="http://areyouahuman.com/">Are You A Human?(Required)</a></li>
 <li><a href="https://www.apachefriends.org/">Install XAMPP - Windows Users</a></li>
 <li><a href="https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mysql-php-lamp-stack-on-ubuntu">Install LAMP - Linux Users</a></li>
 <li><a href="http://learn.perl.org/installing/">How to install Perl</a></li>
 <li><a href="http://perlmaven.com/how-to-install-a-perl-module-from-cpan">How to install Perl modules</a></li>
 <li><a href="http://nginx.org/en/docs/install.html">How to install Nginx(Optional)</a></li>
 <li><a href="http://www.adminer.org/">How to install Adminer(Optional)</a></li>
</ul>

<u><b>Note:</b></u> Windows users please do not install Perl when installing XAMPP

### Default Server Account:

The source now comes with a default account, this account is created when you import the SQL into your database. 

<b>Username:</b> Isis
<b>Password:</b> imfuckinggay
