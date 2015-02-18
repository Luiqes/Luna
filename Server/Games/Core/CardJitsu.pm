use strict;
use warnings;

package CardJitsu;

use Method::Signatures;
use List::Util qw(first);

method new($resParent) {
       my $obj = bless {}, $self;
       $obj->{parent} = $resParent;
       $obj->{matches} = ();
       $obj->{isWaiting} = ();
       return $obj;
}

method imReady($intMatch) {
       return if (!exists($self->{matches}->{$intMatch}));
       $self->{matches}->{$intMatch}->{isReady} = 1;
}

method isReady($intMatch) {
       return if (!exists($self->{matches}->{$intMatch}));
       return $self->{matches}->{$intMatch}->{isReady} ? 1 : 0;
}		

method addToWaitingList($objClient) {
       push (@{$self->{isWaiting}}, $objClient);
}

method removeFromWaitingList($objClient) {
       while (my ($intKey, $objPlayer) = each(@{$self->{isWaiting}})) {
              if ($objPlayer->{property}->{personal}->{userID} eq $objClient->{property}->{personal}-<{userID}) {
                  splice(@{$self->{isWaiting}}, $intKey, 1);
              }
       }
}

method tryToMatchUp($objClient) {
       my $objPlayer;
       if (scalar(keys $self->{isWaiting}) > 1) {
           my @arrWaiting = values(@{$self->{isWaiting}});
			       $objPlayer = $arrWaiting[rand(@arrWaiting)];
           if ($objPlayer->{property}->{personal}->{userID} eq $objClient->{property}->{personal}->{userID}) {				 
               $objPlayer = $arrWaiting[rand(@arrWaiting)];
           }
           my @arrMatches = (1..2500);
           my $intMatch = $arrMatches[rand(@arrMatches)];
			       if (!exists(%{$self->{matches}->{$intMatch}})) {
			           $intMatch = $arrMatches[rand(@arrMatches)];
			       } 
			       $objClient->sendXT('tmm', 0, '-1', $objClient->{property}->{personal}->{username}, $objPlayer->{property}->{personal}->{username});
			       $objClient->sendXT('scard', 0, 998, $intMatch, 2);
			       $objClient->{property}->{games}->{matchID} = $intMatch;
			       $objClient->{property}->{games}->{seatID} = 0;
			       $objPlayer->sendXT('tmm', 0, '-1', $objPlayer->{property}->{personal}->{username}, $objClient->{property}->{personal}->{username});
			       $objPlayer->sendXT('scard', 0, 998  $intMatch, 2);
           $objPlayer->{property}->{games}->{matchID} = $intMatch;
           $objPlayer->{property}->{games}->{seatID} = 1;			
           %{$self->{matches}->{$intMatch}} = (firstPlayer => $objClient, secondPlayer => $objPlayer, max => 2, isReady => 0, tmp => {});			
           $self->removeFromWaitingList($objClient);
           $self->removeFromWaitingList($objPlayer);
       } 
}

method playWithSensei($objClient) {
       my @arrMatches = (1..2500);
       my $intMatch = $arrMatches[rand(@arrMatches)];
       if (exists(%{$self->{matches}->{$intMatch}})) {
           $intMatch = $arrMatches[rand(@arrMatches)];
       }
       $objClient->sendXT('scard', 0, 998, $intMatch, 1);
       $objClient->{property}->{games}->{matchID} = $intMatch;
       $objClient->{property}->{games}->{seatID} = 0;	
       %{$self->{matches}->{$intMatch}} = (firstPlayer => $objClient, secondPlayer => undef, max => 1, tmp => {});
}

method getSenseiCards($intCount, $arrCards, $blnSensei) {
       my @arrCardID = ();        
       return if (!defined($blnSensei));
       foreach my $strCard (@$arrCards) {  
          if ($strCard->{damage} > 7 && $strCard->{attribute} < 3) {
              push (@arrCardID, $strCard->{id});
          }	        
       }
       my $strCards = join('|', @arrCardID);
       return $strCards;
}

method checkWin($intMatch, $objPlayerOne, $objPlayerTwo, $arrCards) { # need to complete this
       my $blnFire = $self->{matches}->{$objPlayerOne->{property}->{games}->{matchID}}->{tmp}->{'p' . $objPlayerOne->{property}->{games}->{seatID}->{fire}};
       my $blnWater = $self->{matches}->{$objPlayerOne->{property}->{games}->{matchID}}->{tmp}->{'p' . $objPlayerOne->{property}->{games}->{seatID}->{water}};
       my $blnSnow = $self->{matches}->{$objPlayerOne->{property}->{games}->{matchID}}->{tmp}->{'p' . $objPlayerOne->{property}->{games}->{seatID}->{snow}};
}

method battleSensei($objClient, $intCard, $arrCards, $strBelt) {
       my @arrMasters = $self->{matches}->{$objClient->{property}->{games}->{matchID}}->{tmp}->{sensei};
       my $objSensei = $arrMasters[rand(@arrMasters)];
       if ($self->checkByElement($objSensei->{attribute}, $arrCards->{attribute} != $objSensei->{attribute}) {
				      $objSensei = $arrMasters[rand(@arrMasters)];
       }
       $objClient->sendXT('zm', $objClient->{property}->{games}->{matchID}, 'pick', 0, $objSensei);
       if ($objSensei->{power} > 0) {
           $self->getPowerCard($objSensei->{power}) ? $objClient->sendXT('zm', $objClient->{property}->{games}->{matchID}, 'power', 0, 1, $objSensei->{power}) : $objClient->sendXT('zm', $objClient->{property}->{games}->{matchID}, 'power', 0, 1, $objSensei->{power});				
       }
       $objClient->sendXT('zm', $objClient->{property}->{games}->{matchID}, 'judge', 0, '-1');
}

method addCard($intCard, $objClient, $arrCards) {
       $self->{matches}->{$objClient->{property}->{games}->{matchID}}->{tmp}->{'p' . $objClient->{property}->{games}->{seatID}}->{cardID} = $intCard;
       %{$self->{matches}->{$objClient->{property}->{games}->{matchID}}->{tmp}->{'p' . $objClient->{property}->{games}->{seatID}->{$arrCards}->{$intCard}->{attribute}} = $intCard;
}

method checkDamages($intDamage, $intDamageTwo) {
       if ($intDamage < $intDamageTwo) {
           return $intDamageTwo;
	      } elsif ($intDamage > $intDamageTwo) {
           return $intDamage;
	      } elsif ($intDamage eq $intDamageTwo) {
           return 0;
	      }
}

method checkByElement($strElm, $strElmTwo) {       
       if ($strElm eq 'fire' && $strElmTwo eq 'water' || $strElm eq 'water' && $strElm eq 'snow' || $strElm eq 'snow' && $strElmTwo eq 'fire') {
           return $strElmTwo;
       } elsif ($strElm eq 'water' && $strElmTwo eq 'fire' || $strElm eq 'snow' && $strElmTwo eq 'water' || $strElm eq 'fire' && $strElmTwo eq 'snow') {
           return $strElm;
       }
}

method getPowerCard($intPCard) {
       my @arrPowers = (1, 2, 3, 13, 14, 15, 16, 17, 18);
       my @arrPowersTwo = (4, 5, 6, 7, 8, 9, 10, 11, 12, 19, 20, 21, 22, 23, 24);
       my $blnCheck = first{$_ == $intPCard} @arrPowers ? 1 : 0;
       my $blnCheckTwo = first{$_ == $intPCard} @arrPowerdTwo ? 1 : 0;
       return if (!$blnCheck && !$blnCheckTwo);
       return $blnCheck ? 1 : 0;
}
		
1;