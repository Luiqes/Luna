package Buddies;

use strict;
use warnings;

use Method::Signatures;

method handleGetBuddies($strData, $objClient) {
       my $strBuddies = $self->handleFetchBuddies($objClient);
       $objClient->write('%xt%gb%-1%' . ($strBuddies ? $strBuddies : '%'));
}

method handleFetchBuddies($objClient) {
       my $strInfo = '';
       foreach (keys %{$objClient->{buddies}}) {
	               my $arrInfo = $self->{modules}->{mysql}->fetchColumns("SELECT `nickname` FROM users WHERE `ID` = '$_'");
	        	      $strInfo .= $_ . '|' . $arrInfo->{nickname} . '|' . $objClient->getOnline($_) . '%';
       }
       return $strInfo;
}

method handleBuddyRequests($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intBudID = $arrData[5];
       return if (!int($intBudID));
       my $objPlayer = $objClient->getClientByID($intBudID);
       $objPlayer->{buddyRequests}->{$objClient->{ID}} = 1;
       $objPlayer->sendXT(['br', '-1', $objClient->{ID}, $objClient->{username}]);  
}

method handleBuddyAccept($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intBudID = $arrData[5];
       return if (!int($intBudID));
       my $objPlayer = $objClient->getClientByID($intBudID);
       delete($objPlayer->{buddyRequests}->{$objClient->{ID}});
       $objClient->{buddies}->{$intBudID} = $objPlayer->{username};
       $objPlayer->{buddies}->{$objClient->{ID}} = $objClient->{username};
       my $cbStr = '';
       my $pbStr = '';
       while (my ($buddyID, $buddyName) = each(%{$objClient->{buddies}})) {
              $cbStr .= $buddyID . '|' . $buddyName . ',';
       }
       while (my ($buddyID, $buddyName) = each(%{$objPlayer->{buddies}})) {
              $pbStr .= $buddyID . '|' . $buddyName . ',';
       }
			   $objClient->updateBuddies($cbStr, $objClient->{ID});
			   $objClient->updateBuddies($pbStr, $objPlayer->{ID});
			   $objPlayer->sendXT(['ba', '-1', $objClient->{ID}, $objClient->{username}]);
}

method handleBuddyRemove($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intBudID = $arrData[5];
       return if (!int($intBudID));
       my $objPlayer = $objClient->getClientByID($intBudID);
       delete($objClient->{buddies}->{$intBudID});
       delete($objPlayer->{buddies}->{$objClient->{ID}});
       my $cbStr = '';
       my $pbStr = '';
       while (my ($buddyID, $buddyName) = each(%{$objClient->{buddies}})) {
              $cbStr .= $buddyID . '|' . $buddyName . ',';
       }
       while (my ($buddyID, $buddyName) = each(%{$objPlayer->{buddies}})) {
              $pbStr .= $buddyID . '|' . $buddyName . ',';
       }
			   $objClient->updateBuddies($cbStr, $objClient->{ID});
			   $objClient->updateBuddies($pbStr, $objPlayer->{ID});
       $objPlayer->sendXT(['rb', '-1', $objClient->{ID}, $objClient->{username}]);
}

method handleBuddyFind($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intBudID = $arrData[5];
       return if (!int($intBudID));
       my $objPlayer = $objClient->getClientByID($intBudID);
       $objClient->sendXT(['bf', '-1', $objPlayer->{room}]);
}

1;