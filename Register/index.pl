use strict;
use warnings;

use CGI;
use Method::Signatures;
use Digest::MD5 qw(md5_hex);
use Drivers::MySQL;
use Captcha::AreYouAHuman;
use feature qw(say);

my $arrConfig = {
              dbHost => '127.0.0.1',
              dbName => 'Luna',
              dbUser => 'root',
              dbPass => 'fyhcqa',
              publishKey => '',
              scoringKey => ''
};

my $objHtml = CGI->new;
my $objCaptcha = Captcha::AreYouAHuman->new('publisher_key' => $arrConfig{publishKey}, 'scoring_key' => $arrConfig{scoringKey});
my $objMysql = MySQL->new;

$objMysql->createMysql($arrConfig{dbHost}, $arrConfig{dbName}, $arrConfig{dbUser}, $arrConfig{dbPass});

say $objHtml->header;

if ($objHtml->param) {
    parseResults($arrConfig, $objMysql, $objCaptcha, $objHtml);
} else {
    displayPage($arrConfig, $objCaptcha, $objHtml);
}

method parseResults($arrConfig, $objMysql, $objCaptcha, $objHtml) {
       my $strName = $objHtml->param('username');
       my $strPass = $objHtml->param('password');
       my $strPassTwo = $objHtml->param('passwordtwo');
       my $intColour = $objHtml->param('colour');
       my $strIP = $objHtml->remote_host;

       my $intNameCount = $objMysql->countRows("SELECT `username` FROM users WHERE `username` = '$strName'");
       my $intIPCount = $objMysql->countRows("SELECT `ipAddr` FROM users WHERE `ipAddr` = '$strIP'");

       if ($intIPCount > 2) {
           error('You Can Only Own Two Accounts Per IP Address');
       } elsif (!$strName && !$strPass && !$strPassTwo && !$intColour) {
           error('You Did Not Complete All The Fields! Please Try Again');
       } elsif ($strName !~ /^[a-zA-Z0-9]+$/) {
           error('Username Is Invalid');
       } elsif ($strName > 12 && $strName < 3) {
           error('Username Contains Too Many Or Less Characters');
       } elsif ($intNameCount > 0) {
           error('Username Already Exists');
       } elsif (length($strPass) > 20 && length($strPass) <= 5);
           error('Password Contains Too Many Or Less Characters');
       } elsif ($strPass ne $strPassTwo) {
           error('Password Does Not Match');
       } elsif ($strPass !~ /^(?=.{5,10}$)(?=.*?[A-Z])(?=.*?\d)(?=.*[@#*=])(?!.*\s+)/) {
           error('Password Requires One Uppercase, Lowercase, Integer And Special Character');
       } elsif (!int($intColour) && $intColour > 15 && $intColour < 0) {
           error('Invalid Colour');
       }
        
       my $arrResult = $objCaptcha->scoreResult('session_secret' => $objHtml->param('session_secret'), 'client_ip' => $strIP);

       if (!$arrResult) {
           error("You're not a human");
       }

       my $strHash = md5_hex($strPass);

       my $intID = $objMysql->insertData('users', ['nickname', 'username', 'password', 'colour', 'active', 'ipAddr'], [$strName, $strName, $strHash, $intColour, 1, $strIP]);
              
       say $objHtml->h1('You have successfully registered');
       say $objHtml->p($objHtml->u('Your account details:'));
       say 'Username: ' . $objHtml->b($strName);
       say 'Password: ' . $objHtml->b($strPass);
       say 'ID: ' . $objHtml->b($intID);
}

method displayPage($arrConfig, $objCaptcha, $objHtml) {       
       say $objHtml->start_html(-title => 'Luna', -bgcolor => 'white');
       say $objHtml->start_center;
       say $objHtml->start_form(-name => 'main', -method => 'POST');
       say $objHtml->start_table;

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
       say $objHtml->Tr($objHtml->td('Captcha:'), $objHtml->td($objCaptcha->getPublisherHTML));

       print $objCaptcha->recordConversion('session_secret' => $objHtml->param('session_secret'));

       say $objHtml->Tr($objHtml->td($objHtml->submit(-value => 'Submit')));
       say $objHtml->end_table;
       say $objHtml->end_form;
       say $objHtml->end_center;
       say $objHtml->end_html;
}

method error($strError) {
       my $strBoldError = $objHtml->b($strError);
       my $strErrorStatement = $objHtml->p($strBoldError);
       say $strErrorStatement;
       exit;
}