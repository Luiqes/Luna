package Postcards;

use strict;
use warnings;

use Method::Signatures;
use HTTP::Date qw(str2time);
use HTML::Entities;

method handleMailGet($strData, $objClient) {
       if ($objClient->{isNewMail}) {
           my $dbInfo = $self->{modules}->{mysql}->fetchColumns("SELECT `age` FROM users WHERE `ID` = '$objClient->{ID}'");
           my $timestamp = str2time($dbInfo->{age});
           $objClient->sendPostcard($objClient->{userID}, 'Sleize', 0, 'Welcome To Luna!', 125, $timestamp);
           $objClient->updateNewMail(0);
       }
       my $arrReceived = $objClient->getPostcards($objClient->{ID});
       my $arrCards = reverse($arrReceived);
       my $strCards = '';
       foreach (%{$arrCards}) {
                $strCards .= $_ . '%';
       }
       $objClient->write('%xt%mg%-1%' . ($strCards ? $strCards : '%'));
}

method handleMailStart($strData, $objClient) {
       my $unreadCount = $objClient->getUnreadPostcards($objClient->{ID});
       my $postcardCount = $objClient->getPostcardCount($objClient->{ID});
       $objClient->sendXT(['mst', '-1', $unreadCount, $postcardCount]);
}

method handleMailSend($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $recepientID = $arrData[5];
       my $postcardType = $arrData[6];
       my $postcardNotes = decode_entities($arrData[7]);
       return if (!int($recepientID) && !int($postcardType) && !defined($postcardNotes));
       return if (!exists($self->{modules}->{crumbs}->{mailCrumbs}->{$postcardType}));
       if ($objClient->{coins} < 10) {
           $objClient->sendXT(['ms', '-1', $objClient->{coins}, 2]);
       } else {
           $objClient->updateCoins($objClient->{coins} - 10);
           my $timestamp = time;
           my $postcardID = $objClient->sendPostcard($recepientID, $objClient->{username}, $objClient->{ID}, $postcardNotes, $postcardType, $timestamp);
           my $objPlayer = $objClient->getClientByID($recepientID);
           $objPlayer->write('%xt%mr%-1%' . $objClient->{username} . '%' . $objClient->{ID} . '%' . $postcardType . '%%' . $timestamp . '%' . $postcardID . '%');
       }
}

method handleMailCheck($strData, $objClient) {
       $self->{modules}->{mysql}->updateTable('postcards', 'isRead', 1, 'recepient', $objClient->{ID});
       $objClient->sendXT(['mc', '-1', 1]);
}

method handleMailDelete($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $postcardID = $arrData[5];
       return if (!int($postcardID));
       $self->{modules}->{mysql}->deleteData('postcards', 'postcardID', $postcardID);
       $objClient->sendXT(['md', '-1', $postcardID]);
}

method handleMailDeletePlayer($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $playerID = $arrData[5];
       return if (!int($playerID));
       $self->{modules}->{mysql}->deleteData('postcards', 'recepient', $objClient->{ID}, 'mailerID', $playerID, 1);
       my $intCount = $objClient->getPostcardCount($objClient->{ID});
       $objClient->sendXT(['mdp', '-1', $intCount]);
}	
       	     
1;