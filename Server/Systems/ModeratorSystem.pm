use strict;
use warnings;

package ModeratorSystem;

use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       %{$obj->{handlers}} = (
                 'o#k' => 'handleKickButton',
                 'o#m' => 'handleMuteButton',
                 'o#b' => 'handleBanButton'
       );
       return $obj;
}

method handleModeratorSystem($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       my $intPID = $arrData[5];
       return if (!exists($self->{handlers}->{$strCmd}));
       my $strHandler = $self->{handlers}->{$strCmd};
       return if (!defined(&{$strHandler}));
       if ($objClient->{property}->{personal}->{isStaff}) {
           $self->$strHandler($intPID, $objClient);
       }
}

method handleKickButton(Int $intPID, $objClient) {
       my $objPlayer = $objClient->getClientByID($intPID);
       $objPlayer->sendError(610);
	      $self->{child}->{modules}->{base}->removeClientBySock($objPlayer->{sock});
}

method handleMuteButton(Int $intPID, $objClient) {
       my $objPlayer = $objClient->getClientByID($intPID);
       if (!$objPlayer->{property}->{personal}->{isMuted}) {
				      $self->updateMute($objPlayer, 1);
				      $objClient->botSay($objPlayer->{property}->{personal}->{username} . ' Has Been Muted By: ' . $objClient->{property}->{personal}->{username});
       } elsif ($objPlayer->{property}->{personal}->{isMuted}) {
				      $self->updateMute($objPlayer, 0);
				      $objClient->botSay($objPlayer->{property}->{personal}->{username} . ' Has Been Unmuted By: ' . $objClient->{property}->{personal}->{username});
       }
}

method handleBanButton(Int $intPID, $objClient) {
       my $objPlayer = $objClient->getClientByID($intPID);
       if ($objPlayer->{property}->{personal}->{isBanned} eq '') {
				      $objPlayer->updateBan($objPlayer, 'PERM');
				      $objPlayer->sendError(603);
           $objClient->botSay($objClient->{property}->{personal}->{username} . ' Has Banned: ' . $objPlayer->{property}->{personal}->{username});
			      	 $self->{child}->{modules}->{base}->removeClientBySock($objPlayer->{sock});
       } elsif ($objPlayer->{property}->{isBanned} eq 'PERM') {
			      	 $objPlayer->updateBan($objPlayer, '');
				      $objClient->botSay($objClient->{property}->{personal}->{username} . ' Has Unbanned: ' . $objPlayer->{property}->{personal}->{username});
       }
}

method updateMute($objClient, Bool $blnMute) {
       $self->{child}->{modules}->{mysql}->updateTable($self->{child}->{dbConfig}->{tables}->{main}, 'isMuted', $blnMute, 'ID', $objClient->{property}->{personal}->{userID});
       $objClient->{property}->{personal}->{isMuted} = $blnMute;
}

method updateBan($objClient, $strBan) {
       $self->{child}->{modules}->{mysql}->updateTable($self->{child}->{dbConfig}->{tables}->{main}, 'isBanned', $strBan, 'ID', $objClient->{property}->{personal}->{userID});
       $objClient->{property}->{personal}->{isBanned} = $strBan;   
}

1;