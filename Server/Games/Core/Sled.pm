use strict;
use warnings;

package Sled;

use Method::Signatures;

method new($resParent) {
       my $obj = bless {}, $self;
       $obj->{parent} = $resParent;
       $obj->{waddles} = ();
       $obj->{matches} = ();
       for my $intWaddle (100..104) {
			     $obj->{waddles}->{$intWaddle} = $self->getNewWaddleObject($intWaddle);
	      }
       for my $intWaddle (200..204) {
			     $obj->{waddles}->{$intWaddle}= $self->getNewWaddleObject($intWaddle);
       }
       return $obj;
}

method getNewWaddleObject($intWaddle) {
       my $intMax = 2;
       if ($intWaddle eq 100) {
           $intMax = 4;
       } elsif ($intWaddle eq 101) {
           $intMax = 3;
       }
       my $arrInfo = {
                   id => $intWaddle, 
                   clients => {}, 
                   max => $intMax, 
                   requests => 0
       };
       return $arrInfo;
}

method getWaddle($intWaddle) {
       return if (!exists($self->{waddles}->{$intWaddle}));
       my $strWaddle = $self->{waddles}->{$intWaddle};
       return $strWaddle;
}

method getWaddleString($intWaddle) {
       my $strWaddle = $self->getWaddle($intWaddle);
       my $strInfo = $intWaddle . '|';
       for (my $intID = 0; $intID < $strWaddle->{max} - 1; $intID++) {
            if (!exists($strWaddle->{clients}->{$intID})) {
                $strInfo .= $strWaddle->{clients}->{$intID}->{username} . ',';
            }
       }
       return $strInfo;
}

method joinWaddle($intWaddle, $objClient) {
       my $strWaddle = $self->getWaddle($intWaddle);
       my $blnReady = 0;
       %{$self->{waddles}->{$intWaddle}->{clients}} = $objClient;
       if ($self->getWaddleCount($intWaddle) >= $strWaddle->{max}) {
           $blnReady = 1;
       }
       my $arrInfo = {
                   seat => scalar(%{$self->{waddles}->{$intWaddle}->{clients}}) - 1,
                   isReady => $blnReady
       };
       return $arrInfo;
}

method leaveWaddle($intWaddle, $objClient) {
       my $strWaddle = $self->getWaddle($intWaddle);
       while (my ($intKey, $objPlayer) = each (%{$strWaddle->{clients}})) {
              if ($objPlayer->{property}->{personal}->{userID} eq $objClient->{property}->{personal}->{userID}) {
				             delete($strWaddle->{clients}->{$intKey});
			          }
		    }
}

method getWaddleCount($intWaddle) {
       my $strWaddle = $self->getWaddle($intWaddle);
       my $intCount = 0;
       while (my ($intKey, $objClient) = each(%{$strWaddle->{clients}})) {
              if ($objClient->{property}->{games}->{waddleID} eq $intWaddle) {
                  $intCount++;
              }
       }
       return $intCount;
}

method getUpdateString($intWaddle) {
       my $strWaddle = $self->getWaddle($intWaddle);	
       my $strInfo = $strWaddle->{max} . '%';
       foreach my $objClient (values %{$self->{waddles}->{$intWaddle}->{clients}}) {
          $strInfo .= $objClient->{property}->{personal}->{username} . '|' . $objClient->{property}->{clothing}->{colour} . '|' . $objClient->{property}->{clothing}->{hands} . '|' . lc($objClient->{property}->{personal}->{username}) . '%'; 
       }
       $strWaddle->{requests}++;	
       if ($strWaddle->{requests} >= $strWaddle->{max}) {
           $self->onClearOut($intWaddle);
       }
       return $strInfo;
}

method resetWaddle($intWaddle) {
       my $strWaddle = $self->getWaddle($intWaddle);
       $self->{waddles}->{$intWaddle} = $self->getNewWaddleObject($intWaddle);
}

method onClearOut($intWaddle) {
       foreach my $objClient (values %{$self->{waddles}->{$intWaddle}->{clients}}) {		
          $objClient->sendXT(['uw', '-1', $intWaddle, $objClient->{property}->{games}->{seatID}]);
       }
       $self->resetWaddle($intWaddle);
}

1;