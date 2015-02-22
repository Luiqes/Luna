use strict;
use warnings;

use CGI;
use Method::Signatures;
use Digest::MD5 qw(md5_hex);
use Drivers::Mysql;
use Captcha::reCAPTCHA;
use feature qw(say);

my $arrConfig = {
   dbHost => '127.0.0.1',
   dbName => 'Luna',
   dbUser => 'root',
   dbPass => 'fyhcqa',
   dbTable => 'users',
   stampsTable => 'stamps',
   houseTable => 'igloos',
   captchaPublicKey => '6Ldbc9cSAAAAACYGs9FWEemI_A4Atx20sOtk6YA-',
   captchaPrivateKey => '6Ldbc9cSAAAAAHs88TTzyytdrIlkbVx3h5x55t8j'
};

my $objHtml = CGI->new();
my $objCaptcha = Captcha::reCAPTCHA->new();
my $objMysql = Mysql->new();

$objMysql->createMysql($arrConfig{dbHost}, $arrConfig{dbName}, $arrConfig{dbUser}, $arrConfig{dbPass});

say $objHtml->header();

if ($objHtml->param()) {
    parseResults($arrConfig, $objMysql, $objCaptcha, $objHtml);
} else {
    displayPage($arrConfig, $objCaptcha, $objHtml);
}

method parseResults($arrConfig, $objMysql, $objCaptcha, $objHtml) {
       my $strName = $objHtml->param('username');
       my $strPass = $objHtml->param('password');
       my $strPassTwo = $objHtml->param('passwordtwo');
       my $intColour = $objHtml->param('colour');
       my $strChallenge = $objHtml->param('recaptcha_challenge_field');
       my $strResponse = $objHtml->param('recaptcha_response_field');
       my $strIP = $ENV{'REMOTE_ADDR'};

       my $arrResult = $objMysql->fetchColumns("SELECT `username` FROM $arrConfig{dbTable} WHERE `username` = '$strName'");
       my $intIPCount = $objMysql->countRows("SELECT `ipAddr` FROM $arrConfig{dbTable} WHERE `ipAddr` = '$strIP'");

       my $strLCDBName = lc($arrResult->{username});
       my $strLCName = lc($strName);

       if ($intIPCount > 2) {
           error('You Can Only Own Two Accounts Per IP Address');
       } elsif (!defined($strName) && !defined($strPass) && !defined($strPassTwo) && !defined($intColour)) {
           error('You Did Not Complete All The Fields! Please Try Again');
       } elsif ($strName !~ /^[a-zA-Z0-9]+$/) {
           error('Username Is Invalid');
       } elsif (length($strLCName) > 12 && length($strLCName) < 3) {
           error('Username Contains Too Many Or Less Characters');
       } elsif ($strLCName eq $strLCDBName) {
           error('Username Already Exists');
       } elsif (length($strPass) > 20 && length($strPass) <= 5);
           error('Password Contains Too Many Or Less Characters');
       } elsif ($strPass ne $strPassTwo) {
           error('Password Does Not Match');
       } elsif (!int($intColour) && $intColour > 15 && $intColour < 0) {
           error('Invalid Colour');
       }
        
       my $arrResult = $objCaptcha->check_answer($arrConfig{captchaPrivateKey}, $strIP, $strChallenge, $strResponse);

       if (!$arrResult->{is_valid}) {
           error($arrResult->{error});
       }

       my $strHash = md5_hex($strPass);

       $objMysql->execQuery("INSERT INTO $arrConfig{dbTable} (`nickname`, `username`, `password`, `colour`, `active`, `ipAddr`) VALUES ('" . $strName . "', '" . $strName . "', '" . $strHash . "', '" . $intColour . "', '1', '" . $strIP . "')");
       $objMysql->execQuery("INSERT INTO $arrConfig{stampsTable} (`username`) VALUES ('" . $strName . "')");
       $objMysql->execQuery("INSERT INTO $arrConfig{houseTable} (`username`) VALUES ('" . $strName . "')");
       
       say $objHtml->h1('You have successfully registered');
       say $objHtml->p($objHtml->u('Your account details:'));
       say 'Username: ' . $objHtml->b($strName);
       say 'Password: ' . $objHtml->b($strPass);
}

method displayPage($arrConfig, $objCaptcha, $objHtml) {       
       say $objHtml->start_html(-title => 'Luna', -bgcolor => 'white');
       say $objHtml->start_center();
       say $objHtml->start_form(-name => 'main', -method => 'POST');
       say $objHtml->start_table();

       my %arrColours = (
                      1 => 'Blue', 2 => 'Green',3 => 'Pink',
                      4 => 'Black',5 => 'Red',6 => 'Orange',
                      7 => 'Yellow', 8 => 'Dark Purple',9 => 'Brown',
                      10 => 'Peach',11 => 'Dark Green', 12 => 'Light Blue',
                      13 => 'Light Green',14 => 'Gray', 15 => 'Aqua'
       );

       say $objHtml->Tr($objHtml->td('Username:'), $objHtml->td($objHtml->textfield(-placeholder => 'Enter your name', -type => 'text', -name => 'username', -maxlength => 12)));
       say $objHtml->Tr($objHtml->td('Password:'), $objHtml->td($objHtml->textfield(-placeholder => 'Enter your password', -type => 'password', -name => 'password', -maxlength => 20)));
       say $objHtml->Tr($objHtml->td('Repeat Password:'), $objHtml->td($objHtml->textfield(-placeholder => 'Enter your password again', -type => 'password', -name => 'passwordtwo', -maxlength => 20)));
       say $objHtml->Tr($objHtml->td('Colour:'), $objHtml->td($objHtml->popup_menu(-name   => 'colour', -values => [sort keys %arrColours], -labels => \%arrColours)));
       say $objHtml->Tr($objHtml->td('Captcha:'), $objHtml->td($objCaptcha->get_html($arrConfig{captchaPublicKey})));

       say $objHtml->Tr($objHtml->td($objHtml->submit(-value => 'Submit')), $objHtml->td('&nbsp;'));
       say $objHtml->end_table();
       say $objHtml->end_form();
       say $objHtml->end_center();
       say $objHtml->end_html();
}

method error($strError) {
       my $strBoldError = $objHtml->b($strError);
       my $strErrorStatement = $objHtml->p($strBoldError);
       say $strErrorStatement;
       exit;
}