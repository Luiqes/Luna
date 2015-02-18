use strict;
use warnings;

package PuffleSystem;

use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       %{$obj->{handlers}} = (
                 'p#pg' => 'handleGetPuffle',
                 'p#pip' => 'handlePufflePip',
                 'p#pir' => 'handlePufflePir',
                 'p#ir' => 'handlePuffleIsResting',
                 'p#ip' => 'handlePuffleIsPlaying',
                 'p#pw' => 'handlePuffleWalk',
                 'p#pgu' => 'handlePuffleUser',
                 'p#pf' => 'handlePuffleFeedFood',
                 'p#phg' => 'handlePuffleClick',
                 'p#pn' => 'handleAdoptPuffle',
                 'p#pr' => 'handlePuffleRest',
                 'p#pp' => 'handlePufflePlay',
                 'p#pt' => 'handlePuffleFeed',
                 'p#pm' => 'handlePuffleMove',
                 'p#pb' => 'handlePuffleBath'
       );
       return $obj;
}

method handlePuffleSystem($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];   
       return if (!exists($self->{handlers}->{$strCmd}));
       my $strHandler = $self->{handlers}->{$strCmd};
       return if (!defined(&{$strHandler}));
       $self->$strHandler(\@arrData, $objClient);
}

method handleAdoptPuffle(\@arrData, $objClient) {
       my $intPuffle = $arrData[5];
       my $intRandID = $self->{child}->{modules}->{crypt}->generateInt(1, 5000);
       my @arrInfo = ($intRandID, $arrData[6], $intPuffle, 100, 100, 100);
       $objClient->sendXT('pn', '-1', $objClient->{property}->{personal}->{coins}, join('|', @arrInfo));
       $objClient->setCoins($objClient->{property}->{personal}->{coins} - 800);
       $self->{child}->{modules}->{mysql}->execQuery("INSERT INTO $self->{child}->{dbConfig}->{tables}->{puffle} (`ID`, `puffleID`, `puffleName`, `puffleType`) VALUES ('" . $objClient->{property}->{personal}->{userID} . "', '" . $arrInfo[0] . "', '" . $arrInfo[1] . "', '" . $arrInfo[2] . "')");
}

method handleGetPuffle(\@arrData, $objClient) {
       my $strPuffleInfo = $self->fetchPuffleData($arrData[5]);
       $objClient->sendXT('pg', $arrData[4], $strPuffleInfo);
}

method handlePuffleBath(\@arrData, $objClient) {
       $objClient->sendXT('pb', $objClient->{property}->{room}->{roomID}, $arrData[4], $arrData[5]);
       $objClient->setCoins($objClient->{property}->{personal}->{coins} - 5);
}

method handlePuffleFeed(\@arrData, $objClient) {
       $objClient->sendXT('pt', $objClient->{property}->{room}->{roomID}, $arrData[4], $arrData[5]);
       $objClient->setCoins($objClient->{property}->{personal}->{coins} - 10);
}

method handlePuffleRest(\@arrData, $objClient) {
       $objClient->sendXT('pr', $arrData[4], $arrData[5]);
       $objClient->setCoins($objClient->{property}->{personal}->{coins} - 5);
}

method handlePuffleIsResting(\@arrData, $objClient) {
       $objClient->sendXT('ir', $arrData[4], $arrData[5], $arrData[6], $arrData[7]);
}

method handlePufflePlay(\@arrData, $objClient) {
       $objClient->sendXT('pp', $objClient->{property}->{room}->{roomID}, $arrData[4], $arrData[5]);
}

method handlePuffleFeedFood(\@arrData, $objClient) {
       $objClient->sendXT('pf', $objClient->{property}->{room}->{roomID}, $arrData[4], $arrData[5]);
       $objClient->setCoins($objClient->{property}->{personal}->{coins} - 10);
}

method handlePuffleIsPlaying(\@arrData, $objClient) {
       $objClient->sendXT('ip', $arrData[4], $arrData[5], $arrData[6], $arrData[7]);
}

method handlePuffleMove(\@arrData, $objClient) {
       $objClient->sendXT('pm', $objClient->{property}->{room}->{roomID}, $arrData[5], $arrData[6], $arrData[7]);
}

method handlePuffleClick(\@arrData, $objClient) {
       $objClient->sendXT('phg', $objClient->{property}->{room}->{roomID}, $arrData[4], $arrData[5]);
}

method handlePuffleUser(\@arrData, $objClient) {
       my $strInfo = $self->fetchPuffleData($objClient->{property}->{personal}->{userID});
       $objClient->sendXT('pgu', '-1', $strInfo);
}           

method handlePufflePip(\@arrData, $objClient) {
       $objClient->sendXT('pip', $objClient->{property}->{room}->{roomID}, $arrData[4], $arrData[5], $arrData[6]);
}

method handlePufflePir(\@arrData, $objClient) {
       $objClient->sendXT('pir', $objClient->{property}->{room}->{roomID}, $arrData[4], $arrData[5], $arrData[6]);
}

method handlePuffleWalk(\@arrData, $objClient) {
       my $intPuffItem = 75 . $arrData[5];
       $objClient->updatePlayerCard('upa', 'hand', $intPuffItem);        
       $objClient->sendXT('pw', $objClient->{property}->{room}->{roomID}, $arrData[4], $arrData[5], $arrData[6]);
}

method fetchPuffleData(Int $intPID) {
       my @arrPuffle = ();
       my $arrInfo = $self->{child}->{modules}->{mysql}->fetchColumns("SELECT `puffleID`, `puffleName`, `puffleType`, `puffleEnergy`, `puffleHealth`, `puffleRest` FROM $self->{child}->{dbConfig}->{tables}->{puffle} WHERE `ID` = '$intPID'");
       while (my ($strKey, $mixVal) = each(%{$arrInfo})) {
              push(@arrPuffle, $mixVal);
       }
       my $strPuffle = join('|', @arrPuffle);
       return $strPuffle;
}

1;