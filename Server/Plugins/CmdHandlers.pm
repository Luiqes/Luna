use strict;
use warnings;

package CmdHandlers;

use Switch;
use Method::Signatures;

method new($resParent) {
       my $obj = bless {}, $self;
       $obj->{parent} = $resParent;        
       return $obj;
}

method handleAddItem($objClient, $intItem) {
       $objClient->addItem($intItem);
}

method handleSendPong($objClient, Undef $nullVar) {
       $self->handleServerSay($objClient, 'pong');
}

method handleSendID($objClient, Undef $nullVar) {
       my $strName = $objClient->{property}->{personal}->{username};
       my $intID = $objClient->{property}->{personal}->{userID};
       my $strMsg = $strName . ' Your ID: ' . $intID;
       $self->handleServerSay($objClient, $strMsg);
}

method handleServerSay($objClient, Defined $strMsg) {
       $objClient->botSay($strMsg);
}

method handleAddCoins($objClient, $intCoins) {
       $objClient->updateCoins($intCoins);
}

method handleSendServerPopulation($objClient, Undef $nullVar) {
       my $intCount = scalar(keys %{$self->{parent}->{modules}->{base}->{clients}});
       my $strMsg = 'There are currently ' . $intCount . ' users in this Server';
       $self->handleServerSay($objClient, $strMsg);
} 

method handleSendRoomPopulation($objClient, Undef $nullVar) {
       my $intCount = $objClient->getRoomCount();
       my $strMsg = 'There are currently ' . $intCount . ' users in this Room';
       $self->handleServerSay($objClient, $strMsg);
}

method handleRebootServer($objClient, Undef $nullVar) {
       return if (!$objClient->{property}->{personal}->{isAdmin});
       foreach my $objPlayer (values %{$self->{parent}->{modules}->{base}->{clients}}) {
          $objPlayer->sendError(990);
          $self->{parent}->{modules}->{base}->removeClientBySock($objPlayer->{sock});
       }
}

method handleKickClient($objClient, Defined $strName) {
       my $objPlayer = $objClient->getClientByName($strName);
       $objPlayer->sendError(610);
       $self->{parent}->{modules}->{base}->removeClientBySock($objPlayer->{sock});
}

method handleBanClient($objClient, Defined $strName) {
       return if ($objClient->{property}->{personal}->{rank} < 4);
       my $objPlayer = $objClient->getClientByName($strName);
       $objPlayer->sendError(603);
       $self->{parent}->{modules}->{base}->removeClientBySock($objPlayer->{sock});
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{main}, 'isBanned', 'PERM', 'username', $strName);
       $objPlayer->{property}->{personal}->{isBanned} = 'PERM';
}

method handleUnbanClient($objClient, Defined $strName) {
       return if ($objClient->{property}->{personal}->{rank} < 4);
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{main}, 'isBanned', '', 'username', $strName);
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{main}, 'banCount', 0, 'username', $strName);
}

method handleChangeNickname($objClient, Defined $strNick) {
       if ($strNick !~ /^[a-zA-Z0-9]+$/) {
           return $objClient->sendError(441);
       }
       my $arrInfo = $self->{parent}->{modules}->{mysql}->fetchColumns("SELECT `username`, `nickname` FROM $self->{parent}->{dbConfig}->{tables}->{main} WHERE `nickname` = '$strNick'");
       my $strUCNick = uc($strNick);
       my $strDBName = uc($arrInfo->{username});
       my $strDBNick = uc($arrInfo->{nickname});
       if ($strUCNick eq $strDBName && $strDBNick eq $strUCNick) {
           return $objClient->sendError(441);
       }
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{main}, 'nickname', $strNick, 'ID', $objClient->{property}->{personal}->{userID});
}

method handleTimeBanClient($objClient, Defined $strName) {
       return if ($objClient->{property}->{personal}->{rank} < 4);
       my $objPlayer = $objClient->getClientByName($strName);
       switch ($objPlayer->{property}->{personal}->{banCount}) {
               case (0) {
                     $self->updateBanCount($objPlayer, 1);
                     $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{main}, 'isBanned', time() + 86400, 'ID', $objPlayer->{property}->{personal}->{userID});
                     $objPlayer->sendError(610 . '%' . 'Your account has temporarily been suspended for 24 hours by ' . $objClient->{property}->{personal}->{username});
                     return $self->{parent}->{modules}->{base}->removeClientBySock($objPlayer->{sock});
               }
               case (1) {
                     $self->updateBanCount($objPlayer, 2);
                     $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{main}, 'isBanned', time() + 172800, 'ID', $objPlayer->{property}->{personal}->{userID});
                     $objPlayer->sendError(610 . '%' . 'Your account has been temporarily suspended for 48 hours by ' . $objClient->{property}->{personal}->{username});
                     return $self->{parent}->{modules}->{base}->removeClientBySock($objPlayer->{sock});
               }
               case (2) {
                     $self->updateBanCount($objPlayer, 3);
                     $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{main}, 'isBanned', time() + 259200, 'ID', $objPlayer->{property}->{personal}->{userID});
                     $objPlayer->sendError(610 . '%' . 'Your account has been temporarily suspended for 72 hours by ' . $objClient->{property}->{personal}->{username});
                     return $self->{parent}->{modules}->{base}->removeClientBySock($objPlayer->{sock});
               } 
               case (3) {                        
                     $self->handleBanClient($objClient, $strName);
               }
       }
}

method updateBanCount($objClient, Int $intVal) {
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{main} , 'banCount', $intVal, 'ID', $objClient->{property}->{personal}->{userID});
       $objClient->{property}->{personal}->{banCount} = $intVal;
}

1;