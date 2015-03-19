use strict;
use warnings;

package MailSystem;

use Method::Signatures;
use HTTP::Date qw(str2time);
use HTML::Entities;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       %{$obj->{handlers}} = (
                 'l#mst' => 'handleMailStart',
                 'l#mg' =>	'handleMailGet',
                 'l#ms' =>	'handleMailSend',
                 'l#md'	=>	'handleMailDelete',
                 'l#mdp'	=>	'handleMailDeletePlayer',
                 'l#mc' =>	'handleMailChecked'
       );
       return $obj;
}

method handleMailSystem($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       return if (!exists($self->{handlers}->{$strCmd}));
       my $strHandler = $self->{handlers}->{$strCmd};
       return if (!defined(&{$strHandler}));
       $self->$strHandler($objClient, $strData);
}

method handleMailGet($objClient, $strData) {
       if ($objClient->{property}->{personal}->{isNewMail}) {
           my $dbInfo = $self->{child}->{modules}->{mysql}->fetchColumns("SELECT `age` FROM $self->{child}->{dbConfig}->{tables}->{mail} WHERE `ID` = '$objClient->{property}->{personal}->{userID}'");
           my $timestamp = str2time($dbInfo->{age});
           $objClient->sendPostcard($objClient->{property}->{personal}->{userID}, 'Sleize', 0, 'Welcome To Luna!', 125, $timestamp);
           $objClient->updateNewMail(0);
       }
       my $arrReceived = $objClient->getPostcards($objClient->{property}->{personal}->{userID});
       my $arrCards = reverse($arrReceived);
       my $strCards = '';
       foreach (%{$arrCards}) {
                $strCards .= $_ . '%';
       }
       $objClient->write('%xt%mg%-1%' . ($strCards ? $strCards : '%'));
}

method handleMailStart($objClient, $strData) {
       my $unreadCount = $objClient->getUnreadPostcards($objClient->{property}->{personal}->{userID});
       my $postcardCount = $objClient->getPostcardCount($objClient->{property}->{personal}->{userID});
       $objClient->sendXT(['mst', '-1', $unreadCount, $postcardCount]);
}

method handleMailSend($objClient, $strData) {
       my @arrData = split('%', $strData);
       my $recepientID = $arrData[5];
       my $postcardType = $arrData[6];
       my $postcardNotes = decode_entities($arrData[7]);
       return if (!int($recepientID) && !int($postcardType) && !defined($postcardNotes));
       if ($objClient->{property}->{personal}->{coins} < 10) {
           $objClient->sendXT(['ms', '-1', $objClient->{property}->{personal}->{coins}, 2]);
       } else {
           $objClient->updateCoins($objClient->{property}->{personal}->{coins} - 10);
           my $timestamp = time();
           my $postcardID = $objClient->sendPostcard($recepientID, $objClient->{property}->{personal}->{username}, $objClient->{property}->{personal}->{userID}, $postcardNotes, $postcardType, $timestamp);
           my $objPlayer = $objClient->getClientByID($recepientID);
           $objPlayer->write('%xt%mr%-1%' . $objClient->{property}->{personal}->{username} . '%' . $objClient->{property}->{personal}->{userID} . '%' . $postcardType . '%%' . $timestamp . '%' . $postcardID . '%');
       }
}

method handleMailCheck($objClient, $strData) {
       $self->{child}->{modules}->{mysql}->updateTable($self->{child}->{dbConfig}->{tables}->{mail}, 'isRead', 1, 'recepient', $objClient->{property}->{personal}->{userID});
       $objClient->sendXT(['mc', '-1', 1]);
}

method handleMailDelete($objClient, $strData) {
       my @arrData = split('%', $strData);
       my $postcardID = $arrData[5];
       return if (!int($postcardID));
       $self->{child}->{modules}->{mysql}->deleteData($self->{child}->{dbConfig}->{tables}->{mail}, 'postcardID', $postcardID);
       $objClient->sendXT(['md', '-1', $postcardID]);
}

method handleMailDeletePlayer($objClient, $strData) {
       my @arrData = split('%', $strData);
       my $playerID = $arrData[5];
       return if (!int($playerID));
       $self->{child}->{modules}->{mysql}->deleteData($self->{child}->{dbConfig}->{tables}->{mail}, 'recepient', $objClient->{property}->{personal}->{userID}, 'mailerID', $playerID, 1);
       my $intCount = $objClient->getPostcardCount($objClient->{property}->{personal}->{userID});
       $objClient->sendXT(['mdp', '-1', $intCount]);
}	
       	     
1;