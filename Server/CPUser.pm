use strict;
use warnings;

package CPUser;

use Method::Signatures;
use HTTP::Date qw(str2time);
use Math::Round qw(round);
use List::Util qw(first);
use HTML::Entities;

method new($resParent, $resSock) {
       my $obj = bless {}, $self;
       $obj->{parent} = $resParent;
       $obj->{sock} = $resSock;
       $obj->{property} = {
               personal => {
                        username => '',             
                        userID => 0,
                        ipAddr => '',
                        loginKey => '',
                        coins => 0,
                        rank => 1,
                        age => 0,
                        isMod => 0,
                        isMuted => 0,
                        isBanned => '',
                        isStaff => 0,
                        isAdmin => 0,
                        isAuth => 0,
                        language => 1,
                        lastHeartBeat => 0, 
                        lastCommand => 0,       
                        lastMessage => '',
                        banCount => 0
               },
               clothing => {
                        colour => 0,
                        head => 0,
                        face => 0,
                        neck => 0,
                        body => 0,
                        hand => 0,
                        feet => 0,
                        flag => 0,
                        photo => 0
               },              
               room => {
                    frame => 0,
                    xpos => 100,
                    ypos => 100,
                    roomID => 0
               },
               epf => {
                   isEPF => 0,
                   medalsUsed => 50,
                   medalsUnused => 100,
                   fieldOPStatus => 0
               },
               games => {
                     gamePuck => '',
                     waddleID => '',
                     matchID => '',
                     tableID => '',
                     seatID => '',
                     isSled => 0,
                     isSensei => 0
               }
       };
       $obj->{buddies} = ();
       $obj->{ignored} = ();
       $obj->{inventory} = ();
       $obj->{mails} = ();
       $obj->{ownedIgloos} = ();
       $obj->{ownedFurns} = ();
       %{$obj->{buddyRequests}} = ();
       return $obj;
}

method sendXT(\@arrArgs) {
       my $strPacket = '%xt%';
       $strPacket .= join('%', @arrArgs) . '%';
       $self->write($strPacket);
}

method write($strData) {
       if ($self->{sock}->connected()) {
           send($self->{sock}, $strData . chr(0), 0);
       } elsif ($self->{parent}->{servConfig}->{debugging}) {
           $self->{parent}->{modules}->{logger}->output('Packet Sent: ' . $strData, Logger::LEVELS->{dbg});        
       }
}

method sendRoom($strData) {
       foreach my $objClient (values %{$self->{parent}->{modules}->{base}->{clients}}) {
          if ($objClient->{property}->{room}->{roomID} == $self->{property}->{room}->{roomID}) {
              $objClient->write($strData);
          }
       }
}

method loadDetails {
       my $arrInfo = $self->{parent}->{modules}->{mysql}->fetchColumns("SELECT * FROM $self->{parent}->{dbConfig}->{tables}->{main} WHERE `ID` = '$self->{property}->{personal}->{userID}'");
       my $arrIglooInfo = $self->{parent}->{modules}->{mysql}->fetchColumns("SELECT * FROM $self->{parent}->{dbConfig}->{tables}->{igloo} WHERE `ID` = '$self->{property}->{personal}->{userID}'");
       $self->{property}->{personal}->{username} = $arrInfo->{username};
       $self->{property}->{clothing}->{colour} = $arrInfo->{colour};
       $self->{property}->{clothing}->{head} = $arrInfo->{head};
       $self->{property}->{clothing}->{face} = $arrInfo->{face};
       $self->{property}->{clothing}->{neck} = $arrInfo->{neck};
       $self->{property}->{clothing}->{body} = $arrInfo->{body};
       $self->{property}->{clothing}->{hand} = $arrInfo->{hand};
       $self->{property}->{clothing}->{feet} = $arrInfo->{feet};
       $self->{property}->{clothing}->{flag} = $arrInfo->{flag};
       $self->{property}->{clothing}->{photo} = $arrInfo->{photo};
       $self->{property}->{personal}->{coins} = $arrInfo->{coins};
       $self->{property}->{personal}->{age} = round((time() - str2time($arrInfo->{age})) / 86400);
       $self->{property}->{personal}->{rank} = $arrInfo->{rank};
       $self->{property}->{personal}->{language} = $arrInfo->{bitMask};        
       $self->{property}->{personal}->{isStaff} = $arrInfo->{isStaff};
       $self->{property}->{personal}->{isAdmin} = $arrInfo->{isAdmin};
       $self->{property}->{personal}->{isMuted} = $arrInfo->{isMuted};
       $self->{property}->{personal}->{isBanned} = $arrInfo->{isBanned};
       $self->{property}->{personal}->{banCount} = $arrInfo->{banCount};        
       $self->{property}->{epf}->{isEPF} = $arrInfo->{isEPF};
       $self->{property}->{epf}->{fieldOPStatus} = $arrInfo->{fieldOPStatus};
       $self->{property}->{epf}->{medalsUsed} = $arrInfo->{medalsUsed};
       $self->{property}->{epf}->{medalsUnused} = $arrInfo->{medalsUnused};
       %{$self->{buddies}} = split(',', $arrInfo->{buddies});
       %{$self->{ignored}} = split(',', $arrInfo->{ignored});
       @{$self->{inventory}} = split('%', $arrInfo->{items});      
       @{$self->{ownedIgloos}} = split('\\|', $arrIglooInfo->{ownedIgloos});
       @{$self->{ownedFurns}} = split('%', $arrIglooInfo->{ownedFurns});
}

method buildClientString {
       my @arrInfo = (
                   $self->{property}->{personal}->{userID}, 
                   $self->{property}->{personal}->{username},
                   $self->{property}->{personal}->{language},
                   $self->{property}->{clothing}->{colour}, 
                   $self->{property}->{clothing}->{head}, 
                   $self->{property}->{clothing}->{face}, 
                   $self->{property}->{clothing}->{neck}, 
                   $self->{property}->{clothing}->{body}, 
                   $self->{property}->{clothing}->{hand}, 
                   $self->{property}->{clothing}->{feet}, 
                   $self->{property}->{clothing}->{flag}, 
                   $self->{property}->{clothing}->{photo}, 
                   $self->{property}->{room}->{xpos}, 
                   $self->{property}->{room}->{ypos}, 
                   $self->{property}->{room}->{frame}, 1, 
                   $self->{property}->{personal}->{rank} * 146,                
       );
       my $strInfo = join('|', @arrInfo);
       return $strInfo;
}

method getClientByID(Int $intPID) {
       foreach my $objClient (values %{$self->{parent}->{modules}->{base}->{clients}}) {
          if ($objClient->{property}->{personal}->{userID} eq $intPID) {
              return $objClient;
          }
	      }
}

method getClientByName(Str $strName) {
       foreach my $objClient (values %{$self->{parent}->{modules}->{base}->{clients}}) {
          if (lc($objClient->{property}->{personal}->{userID}) eq lc($strName)) {
              return $objClient;
          }
	      }
}

method sendError($intError) {
       $self->write('%xt%e%-1%' . $intError . '%');
}

method updateCoins(Int $intCoins) {
       $self->sendXT(['zo', '-1', $intCoins]);
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{main}, 'coins', $intCoins, 'ID', $self->{property}->{personal}->{userID});
       $self->{property}->{personal}->{coins} = $intCoins;
}

method setCoins(Int $intCoins) {
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{main}, 'coins', $intCoins, 'ID', $self->{property}->{personal}->{userID});
       $self->{property}->{personal}->{coins} = $intCoins;
}

method updateKey(Str $strKey, Defined $strName) {
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{main}, 'loginKey', $strKey, 'username', $strName);
}

method updatePlayerCard(Str $strData, Str $strType, Int $intItem) {
       $self->sendRoom('%xt%' . $strData . '%-1%' . $self->{property}->{personal}->{userID} . '%' . $intItem . '%');
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{main}, $strType, $intItem, 'ID', $self->{property}->{personal}->{userID});
       $self->{property}->{clothing}->{$strType} = $intItem;
}

method throwSnowball(Int $intX, Int $intY) {
       $self->sendRoom('%xt%sb%-1%' . $self->{property}->{personal}->{userID} . '%' . $intX . '%' . $intY . '%');
}

method sendJoke(Int $intJoke) {
       $self->sendRoom('%xt%sj%-1%' . $self->{property}->{personal}->{userID} . '%' . $intJoke . '%');
}

method sendEmote(Int $intEmote) {
       $self->sendRoom('%xt%se%-1%' . $self->{property}->{personal}->{userID} . '%' . $intEmote . '%');
}

method sendTourMsg(Int $intMsg) {
       $self->sendRoom('%xt%sg%-1%' . $self->{property}->{personal}->{userID} . '%' . $intMsg . '%');
}

method sendSafeMsg(Int $intMsg) {
       $self->sendRoom('%xt%ss%-1%' . $self->{property}->{personal}->{userID} . '%' . $intMsg . '%');    
}

method sendMascotMsg(Int $intMsg) {
       $self->sendRoom('%xt%sma%-1%' . $self->{property}->{personal}->{userID} . '%' . $intMsg . '%');
}

method sendMessage(Str $strMsg) {
       $strMsg = decode_entities($strMsg);
       return if ($self->{property}->{personal}->{isMuted} && $self->{property}->{personal}->{lastMessage} eq $strMsg && length($strMsg) > 250);
       $self->{property}->{personal}->{lastMessage} = $strMsg;
       $self->sendRoom('%xt%sm%-1%' .  $self->{property}->{personal}->{userID} . '%' . $strMsg . '%');
}

method getLatestRevision {
       $self->sendXT(['glr', '-1', 3555]);
}

method getPlayer(Int $intPID) {
       my $arrInfo = $self->{parent}->{modules}->{mysql}->fetchColumns("SELECT `ID`, `nickname`, `bitMask`, `colour`, `face`, `body`, `feet`, `hand`, `neck`, `head`, `flag`, `photo`, `rank` * 146 FROM $self->{parent}->{dbConfig}->{tables}->{main} WHERE `ID` = '$intPID'");
       return if (!$arrInfo);
       $self->sendXT(['gp', '-1', join('|', values %{$arrInfo})]);
}

method sendHeartBeat {
       return if ($self->{property}->{personal}->{lastHeartBeat} > time());
       $self->sendXT(['h', '-1']);
       $self->{property}->{personal}->{lastHeartBeat} = time() + 6;
}

method setPosition(Int $intX, Int $intY) {
       $self->sendRoom('%xt%sp%-1%' . $self->{property}->{personal}->{userID} . '%' . $intX . '%' . $intY . '%');
       $self->{property}->{room}->{xpos} = $intX;
       $self->{property}->{room}->{ypos} = $intY;
}

method setFrame(Int $intFrame) {
       $self->sendRoom('%xt%sf%-1%' . $self->{property}->{personal}->{userID} . '%' . $intFrame . '%');
       $self->{property}->{room}->{frame} = $intFrame;
}

method setAction(Int $intAction) {
       $self->sendRoom('%xt%sa%-1%' . $self->{property}->{personal}->{userID} . '%' . $intAction . '%');
}

method removePlayer {
       $self->sendRoom('%xt%rp%-1%' . $self->{property}->{personal}->{userID} . '%');
}

method joinRoom(Int $intRoom, Int $intX, Int $intY) {

       $self->{property}->{room}->{roomID} = $intRoom;

       $self->setPosition($intX, $intY);
       $self->removePlayer();  		

       if ($intRoom > 899) {
           return $self->sendXT(['jg', '-1', $intRoom]);
       } elsif ($self->getRoomCount() >= $self->{parent}->{modules}->{crumbs}->{roomCrumbs}->{$intRoom}->{limit}) {
           return $self->sendError(210);
       } elsif ($intRoom eq 323 && !$self->{property}->{epf}->{isEPF}) {
	          $self->updateEPF(1);
       }	  		  

	      my $strData = '%xt%jr%-1%'  . $intRoom . '%' . $self->buildClientString() . '%';
	      my $objClient = $self->getClientByName($self->{property}->{personal}->{username});       
	      if ($objClient->{property}->{room}->{roomID} eq $self->{property}->{room}->{roomID}) {
           $strData .= $objClient->buildClientString() . '%';
       }
       $self->write($strData);
       $self->sendRoom('%xt%ap%-1%' . $self->buildClientString() . '%');
}

method addItem(Int $intItem) { 

       if (!exists($self->{parent}->{modules}->{crumbs}->{itemCrumbs}->{$intItem})) {
	          return $self->sendError(402);
       } elsif (first {$_ == $intItem} @{$self->{inventory}}) {
	          return $self->sendError(400);
       } elsif ($self->{property}->{personal}->{coins} < $self->{parent}->{modules}->{crumbs}->{itemCrumbs}->{$intItem}->{cost}) {
	          return $self->sendError(401);
       }    

       push(@{$self->{inventory}}, $intItem);
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{main}, 'items', join('%', @{$self->{inventory}}) , 'ID', $self->{property}->{personal}->{userID});
       $self->updateCoins($self->{property}->{personal}->{coins} - $self->{parent}->{modules}->{crumbs}->{itemCrumbs}->{$intItem}->{cost});
       $self->sendXT(['ai', '-1', $intItem, $self->{property}->{personal}->{coins}]);
}

method updateEPF(Bool $blnEpf) {
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{main}, 'isEPF', $blnEpf, 'ID', $self->{property}->{personal}->{userID});
       $self->{property}->{epf}->{isEPF} = $blnEpf;
}

method handleBuddyOnline {
       foreach my $intBudID (%{$self->{buddies}}) {
          my $objPlayer = $self->getClientByID($intBudID);
          $objPlayer->sendXT(['bon', '-1', $self->{property}->{personal}->{userID}]);
       }
}

method handleBuddyOffline {
       foreach my $intBudID (%{$self->{buddies}}) {
          my $objPlayer = $self->getClientByID($intBudID);
          $objPlayer->sendXT(['bof', '-1', $self->{property}->{personal}->{userID}]);
       }
}

method updateOPStat(Bool $blnStat) {
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{main}, 'fieldOPStatus', $blnStat, 'ID', $self->{property}->{personal}->{userID});
       $self->{property}->{epf}->{fieldOPStatus} = $blnStat;
}

method updateMedals {
       $self->{property}->{epf}->{medalsUsed} = $self->{property}->{epf}->{medalsUsed} + 1;
       $self->{property}->{epf}->{medalsUnused} = $self->{property}->{epf}->{medalsUnused} - 1;
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{main}, 'medalsUsed', $self->{property}->{epf}->{medalsUsed}, 'ID', $self->{property}->{personal}->{userID});
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{main}, 'medalsUnused', $self->{property}->{epf}->{medalsUnused}, 'ID', $self->{property}->{personal}->{userID});
}

method getRoomCount {
       my $intCount = 0;
       foreach my $objClient (values %{$self->{parent}->{modules}->{base}->{clients}}) {
          if ($objClient->{property}->{room}->{roomID} eq $self->{property}->{room}->{roomID}) {
              $intCount++;
          }
       }
       return $intCount;
}

method getOnline(Int $intPID) {
       foreach my $objClient (values %{$self->{parent}->{modules}->{base}->{clients}}) {
          return $objClient->{property}->{personal}->{userID} eq $intPID ? 1 : 0;
	      }
}

method sendEarnedStamps {
       my $arrInfo = $self->{parent}->{modules}->{mysql}->fetchColumns("SELECT `stamps` FROM $self->{parent}->{dbConfig}->{tables}->{stamp} WHERE `ID` = '$self->{property}->{personal}->{userID}'");
       my $strStamps = $arrInfo->{stamps};
       $self->sendXT(['gps', '-1', $self->{property}->{personal}->{userID}, $strStamps]);
}

method addIgloo(Int $intIgloo) {

       if (!exists($self->{parent}->{modules}->{crumbs}->{iglooCrumbs}->{$intIgloo})) {
	          return $self->sendError(402);
       } elsif (first {$_ == $intIgloo} @{$self->{ownedIgloos}}) {
	          return $self->sendError(400);
       } elsif ($self->{property}->{personal}->{coins} < $self->{parent}->{modules}->{crumbs}->{iglooCrumbs}->{$intIgloo}->{cost}) {
	          return $self->sendError(401);
       }   

       push(@{$self->{ownedIgloos}}, $intIgloo); 
       $self->updateIglooInventory(join('|', @{$self->{ownedIgloos}}));
       $self->updateCoins($self->{property}->{personal}->{coins} - $self->{parent}->{modules}->{crumbs}->{iglooCrumbs}->{$intIgloo}->{cost});
       $self->sendXT(['au', '-1', $intIgloo, $self->{property}->{personal}->{coins}]);
}

method addFurniture(Int $intFurn) {

       if (!exists($self->{parent}->{modules}->{crumbs}->{furnitureCrumbs}->{$intFurn})) {
           return $self->sendError(402);
       } elsif ($self->{property}->{personal}->{coins} < $self->{parent}->{modules}->{crumbs}->{furnitureCrumbs}->{$intFurn}->{cost}) {
	          return $self->sendError(401);
       }

       push(@{$self->{ownedFurns}}, $intFurn); 
       $self->updateFurnInventory(join('%', @{$self->{ownedFurns}}));
       $self->updateCoins($self->{property}->{personal}->{coins} - $self->{parent}->{modules}->{crumbs}->{furnitureCrumbs}->{$intFurn}->{cost});
       $self->sendXT(['af', '-1', $intFurn, $self->{property}->{personal}->{coins}]);
}

method openIgloo {
       my $intPID = $self->{property}->{personal}->{userID};
       my $strName = $self->{property}->{personal}->{username};
       $self->{parent}->{igloos}->{$intPID} = $strName;
}

method closeIgloo {
       my $intPID = $self->{property}->{personal}->{userID};
       delete($self->{parent}->{igloos}->{$intPID});
}

method updateFurnInventory(Str $strFurns) {
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{igloo}, 'ownedFurns', $strFurns, 'ID', $self->{property}->{personal}->{userID});
}

method updateIglooInventory(Str $strIgloos) {
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{igloo}, 'ownedIgloos', $strIgloos, 'ID', $self->{property}->{personal}->{userID});
}

method updateFurniture(Str $strFurn) {
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{igloo}, 'furniture', $strFurn, 'ID', $self->{property}->{personal}->{userID});
}

method updateIgloo(Int $intIgloo) {
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{igloo}, 'igloo', $intIgloo, 'ID', $self->{property}->{personal}->{userID});
       $self->sendXT(['ao', '-1', $intIgloo, $self->{property}->{personal}->{coins}]);
}

method updateFloor(Int $intFloor) {
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{igloo}, 'floor', $intFloor, 'ID', $self->{property}->{personal}->{userID});
       $self->sendXT(['ag', '-1', $intFloor, $self->{property}->{personal}->{coins}]);
}

method updateMusic(Int $intMusic) {
       $self->{parent}->{modules}->{mysql}->updateTable($self->{parent}->{dbConfig}->{tables}->{igloo}, 'music', $intMusic, 'ID', $self->{property}->{personal}->{userID});
       $self->sendXT(['um', '-1', $intMusic]);
}

method botSay(Str $strMsg) {
       return if (length($strMsg) > 250);
       $self->sendRoom('%xt%sm%-1%0%' . decode_entities($strMsg) . '%');
}

method DESTROY {
       $self->removePlayer();
       $self->handleBuddyOffline();
       $self->closeIgloo();
       $self->{parent}->{modules}->{base}->removeClientBySock($self->{sock});
}

1;