use strict;
use warnings;

package BuddySystem;

use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       %{$obj->{handlers}} = (
                 'b#gb' => 'handleGetBuddies',
                 'b#br' => 'handleBuddyRemove',
                 'b#ba' => 'handleBuddyAccept',
                 'b#rb' => 'handleRemove',
                 'b#bf' => 'handleBuddyFind'
       );
       return $obj;
}

method handleBuddySystem($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       return if (!exists($self->{handlers}->{$strCmd}));
       my $strHandler = $self->{handlers}->{$strCmd};       
       return if (!defined(&{$strHandler}));
       $self->$strHandler(\@arrData, $objClient);
}

method handleGetBuddies(\@arrData, $objClient) {
       my $strBuddies = $self->handleFetchBuddies($objClient);
       $objClient->write('%xt%gb%' . $arrData[4] . '%' . ($strBuddies ? $strBuddies : '%'));
}

method handleFetchBuddies($objClient) {
       my $strInfo = '';
       foreach my $intBudID (keys %{$objClient->{buddies}}) {
	         my $arrInfo = $self->{child}->{modules}->{mysql}->fetchColumns("SELECT `nickname` FROM $self->{child}->{dbConfig}->{tables}->{main} WHERE `ID` = '$intBudID'");
	        	$strInfo .= $intBudID . '|' . $arrInfo->{nickname} . '|' . $objClient->getOnline($intBudID) . '%';
       }
       return $strInfo;
}

method handleBuddyRequests(\@arrData, $objClient) {
       my $intBudID = $arrData[5];
       return if (!int($intBudID));
       my $objPlayer = $objClient->getClientByID($intBudID);
       $objPlayer->{buddyRequests}->{$objClient->{property}->{personal}->{userID}} = 1;
       $objPlayer->sendXT(['br', $arrData[4], $objClient->{property}->{personal}->{userID}, $objClient->{property}->{personal}->{username}]);  
}

method handleBuddyAccept(\@arrData, $objClient) {
       my $intBudID = $arrData[5];
       return if (!int($intBudID));
       my $objPlayer = $objClient->getClientByID($intBudID);
       delete($objPlayer->{buddyRequests}->{$objClient->{property}->{personal}->{userID}});
       $objClient->{buddies}->{$intBudID} = $objPlayer->{property}->{personal}->{username};
			   $objPlayer->{buddies}->{$objClient->{property}->{personal}->{userID}} = $objClient->{property}->{personal}->{username};
			   $self->updateBuddies(join(',', keys %{$objClient->{buddies}}), $objClient->{property}->{personal}->{userID});
			   $self->updateBuddies(join(',', keys %{$objPlayer->{buddies}}), $objPlayer->{property}->{personal}->{userID});
			   $objPlayer->sendXT(['ba', $arrData[4], $objClient->{property}->{personal}->{userID}, $objClient->{property}->{personal}->{username}]);
}

method handleBuddyRemove(\@arrData, $objClient) {
       my $intBudID = $arrData[5];
       return if (!int($intBudID));
       my $objPlayer = $objClient->getClientByID($intBudID);
       delete($objClient->{buddies}->{$intBudID});
       delete($objPlayer->{buddies}->{$objClient->{property}->{personal}->{userID}});
       $self->updateBuddies(join(',', keys %{$objClient->{buddies}}), $objClient->{property}->{personal}->{userID});
       $self->updateBuddies(join(',', keys %{$objPlayer->{buddies}}), $objPlayer->{property}->{personal}->{userID});
       $objPlayer->sendXT(['rb', $arrData[4], $objClient->{property}->{personal}->{userID}, $objClient->{property}->{personal}->{username}]);
}

method handleBuddyFind(\@arrData, $objClient) {
       my $intBudID = $arrData[5];
       return if (!int($intBudID));
       my $objPlayer = $objClient->getClientByID($intBudID);
       $objClient->sendXT(['bf', $arrData[4], $objPlayer->{property}->{room}->{roomID}]);
}

method updateBuddies($strBuddies, $intPID) {
       $self->{child}->{modules}->{mysql}->updateTable($self->{child}->{dbConfig}->{tables}->{main}, 'buddies', $strBuddies, 'ID', $intPID);
}


1;