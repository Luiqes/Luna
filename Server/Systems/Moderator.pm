package Moderator;

use strict;
use warnings;

use Method::Signatures;

method handleKick($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intPID = $arrData[5];
       my $objPlayer = $objClient->getClientByID($intPID);
       if ($objClient->{isStaff}) {
           $objPlayer->sendError(610);
           $self->{modules}->{base}->removeClientBySock($objPlayer->{sock});
       }
}

method handleMute($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intPID = $arrData[5];
       my $objPlayer = $objClient->getClientByID($intPID);
       if ($objClient->{isStaff}) {
           if (!$objPlayer->{isMuted}) {
				          $objClient->updateMute($objPlayer, 1);
				          $objClient->botSay($objPlayer->{username} . ' Has Been Muted By: ' . $objClient->{username});
           } elsif ($objPlayer->{isMuted}) {
				          $objClient->updateMute($objPlayer, 0);
				          $objClient->botSay($objPlayer->{username} . ' Has Been Unmuted By: ' . $objClient->{username});
           }
       }
}

method handleBan($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intPID = $arrData[5];
       my $objPlayer = $objClient->getClientByID($intPID);
       if ($objClient->{isStaff}) {
           if ($objPlayer->{isBanned} eq '') {
				          $objClient->updateBan($objPlayer, 'PERM');
				          $objPlayer->sendError(603);
               $objClient->botSay($objClient->{username} . ' Has Permanently Banned ' . $objPlayer->{username});
			      	     $self->{modules}->{base}->removeClientBySock($objPlayer->{sock});
           }
       }
}

1;