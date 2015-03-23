use strict;
use warnings;

require 'Configuration/Config.pl';

use vars qw($loginConfig $gameConfig $redeemConfig $dbConfig);

use Module::Find;

use Utils::Tools;
use Utils::Logger;
use Utils::Cryptography;

use Drivers::MySQL;
use Drivers::Socket;

use Misc::Crumbs;

use Server::CPPlugins;
use Server::CPCommands;

usesub Server::Systems;
usesub Server::Plugins;

use Server::ClubPenguin;
use Server::CPUser;

my $objLoginServer = ClubPenguin->new($loginConfig, $dbConfig);
my $objGameServer = ClubPenguin->new($gameConfig, $dbConfig);
my $objRedeemServer = ClubPenguin->new($redeemConfig, $dbConfig);

$objLoginServer->initializeSource;
$objGameServer->initializeSource;
$objRedeemServer->initializeSource;

while (1) {
       $objLoginServer->{modules}->{base}->serverLoop;
       $objGameServer->{modules}->{base}->serverLoop;
       $objRedeemServer->{modules}->{base}->serverLoop;
}