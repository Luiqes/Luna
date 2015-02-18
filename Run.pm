use strict;
use warnings;

require 'Configuration/Config.pl';

use vars qw($loginConfig $gameConfig $redeemConfig $dbConfig);

use Module::Find;

use Utils::Tools;
use Utils::Logger;
use Utils::Crypt;

use Drivers::Mysql;
use Drivers::Sock;

use Misc::Crumbs;

use Server::Centre::PluginBase;

usesub Server::Systems;
usesub Server::Plugins;

# Dont uncomment until further notice
#use ServerGames::Manager;
#use Server::Games::Gaming;
#use server::Games::Tables;

use Server::ClubPenguin;
use Server::CPUser;

my $objLoginServer = ClubPenguin->new($loginConfig, $dbConfig);
my $objGameServer = ClubPenguin->new($gameConfig, $dbConfig);
my $objRedeemServer = ClubPenguin->new($redeemConfig, $dbConfig);

$objLoginServer->initializeSource();
$objGameServer->initializeSource();
$objRedeemServer->initializeSource();

while (1) {
       $objLoginServer->{modules}->{base}->serverLoop();
       $objGameServer->{modules}->{base}->serverLoop();
       $objRedeemServer->{modules}->{base}->serverLoop();
}