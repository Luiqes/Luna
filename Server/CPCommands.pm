package CPCommands;

use strict;
use warnings;

use Switch;
use Method::Signatures;

method handleAddItem($objClient, $intItem) {
       $objClient->addItem($intItem);
}

method handleSendPong($objClient, $nullVar) {
       $self->handleServerSay($objClient, 'pong');
}

method handleSendID($objClient, $nullVar) {
       my $strName = $objClient->{username};
       my $intID = $objClient->{ID};
       my $strMsg = $strName . ' Your ID: ' . $intID;
       $self->handleServerSay($objClient, $strMsg);
}

method handleServerSay($objClient, $strMsg) {
       $objClient->botSay($strMsg);
}

method handleAddCoins($objClient, $intCoins) {
       $objClient->updateCoins($intCoins);
}

method handleSendServerPopulation($objClient, $nullVar) {
       my $intCount = scalar(keys %{$self->{child}->{clients}});
       my $strMsg = 'There are currently ' . $intCount . ' users in this Server';
       $self->handleServerSay($objClient, $strMsg);
} 

method handleSendRoomPopulation($objClient, $nullVar) {
       my $intCount = $objClient->getRoomCount;
       my $strMsg = 'There are currently ' . $intCount . ' users in this Room';
       $self->handleServerSay($objClient, $strMsg);
}

method handleRebootServer($objClient, $nullVar) {
       return if (!$objClient->{isAdmin});
       foreach (values %{$self->{child}->{clients}}) {
                $_->sendError(990);
                $self->{child}->{modules}->{base}->removeClientBySock($_->{sock});
       }
}

method handleKickClient($objClient, $strName) {
       my $objPlayer = $objClient->getClientByName($strName);
       $objPlayer->sendError(610);
       $self->{child}->{modules}->{base}->removeClientBySock($objPlayer->{sock});
}

method handleBanClient($objClient, $strName) {
       return if ($objClient->{rank} < 4);
       my $objPlayer = $objClient->getClientByName($strName);
       $objPlayer->sendError(603);
       $self->{child}->{modules}->{base}->removeClientBySock($objPlayer->{sock});
       $self->{child}->{modules}->{mysql}->updateTable('users', 'isBanned', 'PERM', 'username', $strName);
       $objPlayer->{property}->{personal}->{isBanned} = 'PERM';
}

method handleKickBanClient($objClient, $strName) {
       $self->handleKickClient($objClient, $strName);
       $self->handleBanClient($objClient, $strName);
}

method handleUnbanClient($objClient, $strName) {
       return if ($objClient->{rank} < 4);
       $self->{child}->{modules}->{mysql}->updateTable('users', 'isBanned', '', 'username', $strName);
       $self->{child}->{modules}->{mysql}->updateTable('users', 'banCount', 0, 'username', $strName);
}

method handleChangeNickname($objClient, $strNick) {
       if ($strNick !~ /^[a-zA-Z0-9]+$/) {
           return $objClient->sendError(441);
       }
       my $arrInfo = $self->{child}->{modules}->{mysql}->fetchColumns("SELECT `username`, `nickname` FROM users WHERE `nickname` = '$strNick'");
       my $strUCNick = uc($strNick);
       my $strDBName = uc($arrInfo->{username});
       my $strDBNick = uc($arrInfo->{nickname});
       if ($strUCNick eq $strDBName && $strDBNick eq $strUCNick) {
           return $objClient->sendError(441);
       }
       $self->{child}->{modules}->{mysql}->updateTable('users', 'nickname', $strNick, 'ID', $objClient->{ID});
}

method handleTimeBanClient($objClient, $strName) {
       return if ($objClient->{rank} < 4);
       my $objPlayer = $objClient->getClientByName($strName);
       switch ($objPlayer->{banCount}) {
               case (0) {
                     $objClient->updateBanCount($objPlayer, 1);
                     $self->{child}->{modules}->{mysql}->updateTable('users', 'isBanned', time + 86400, 'ID', $objPlayer->{ID});
                     $objPlayer->sendError(610 . '%' . 'Your account has temporarily been suspended for 24 hours by ' . $objClient->{username});
                     return $self->{child}->{modules}->{base}->removeClientBySock($objPlayer->{sock});
               }
               case (1) {
                     $objClient->updateBanCount($objPlayer, 2);
                     $self->{child}->{modules}->{mysql}->updateTable('users', 'isBanned', time + 172800, 'ID', $objPlayer->{ID});
                     $objPlayer->sendError(610 . '%' . 'Your account has been temporarily suspended for 48 hours by ' . $objClient->{username});
                     return $self->{child}->{modules}->{base}->removeClientBySock($objPlayer->{sock});
               }
               case (2) {
                     $objClient->updateBanCount($objPlayer, 3);
                     $self->{child}->{modules}->{mysql}->updateTable('users', 'isBanned', time + 259200, 'ID', $objPlayer->{ID});
                     $objPlayer->sendError(610 . '%' . 'Your account has been temporarily suspended for 72 hours by ' . $objClient->{username});
                     return $self->{child}->{modules}->{base}->removeClientBySock($objPlayer->{sock});
               } 
               case (3) {                        
                     $self->handleBanClient($objClient, $strName);
               }
       }
}

1;