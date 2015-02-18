use strict;
use warnings;

package Gaming;

use Switch;
use Math::Round qw(round);
use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       $obj->{handlers} = {
               zo => 'handleGameFinish',
               gz => 'handleGameStatus',
               lz => 'handleGameLeave',
               m => 'handleMovePuck',
               zm => 'handleGameMoves',
               jz => 'handleGameJoin',
               lmm => 'handleLeaveWaitingList',
               jmm => 'handleJoinWaitingList',
               jsen => 'handleJoinSensei',
               jw => 'handleJoinWaddle',
               gw => 'handleGetWaddle',
               lw => 'handleLeaveWaddle'
       };
       return $obj;
}

method handleData($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       return if (!exists($self->{handlers}->{$strCmd}));
       my $strHandler = $self->{handlers}->{$strCmd};
       return if (!defined(&{$strHandler}));
       $self->$strHandler($strData, $objClient);
}

method handleGameFinish($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       my intCoins = $arrData[5];
       my $intSum = round($intCoins / 10) + 5;
       if ($strCmd eq 'zo') {
           $objClient->updateCoins($objClient->{property}->{personal}->{coins} + $intSum);
           $objClient->{property}->{games}->{tableID} = undef;
           $objClient->{property}->{games}->{seatID} = undef;
           $objClient->{property}->{games}->{waddleID} = undef;
           $objClient->{property}->{games}->{matchID} = undef;
       }
}

method handleMovePuck($strData, $objClient) {
       my @arrData = split('%', $strData);
       my @arrPuck = ();
       while (my ($intKey, $intVal) = each(@arrData)) {
              if ($intKey > 5) {
                  push (@arrPuck, $intVal);
              }
       }
       my $strPuck = join('%', @arrPuck);
       $objClient->sendRoom('%xt%zm%-1%' . $arrData[5] . '%' . $strPuck . '%');
       $objClient->{property}->{games}->{gamePuck} = $strPuck;
}

method handleGameStatus($strData, $objClient) {
       switch ($objClient->{property}->{room}->{roomID}) {
               case (802) {
                     $objClient->sendRoom('%xt%gz%802%' . ($objClient->{property}->{games}->{gamePuck} ? $objClient->{property}->{games}->{gamePuck} : '0%0%0%0') . '%');
               }
               case (951) {
                     my $intPMax = 2;
                     my $intPCount = 0;
                     $objClient->sendRoom('%xt%gz%' . $objClient->{property}->{games}->{matchID} . '%' . $intPMax . '%' . $intPCount . '%');
               }
               case (200 || 221) {
                     return if (!defined($objClient->{property}->{games}->{tableID}));
                     if (!exists($self->{child}->{gaming}->{tables}->{benches}->{$objClient->{property}->{gaming}->{tableID}})) {
                         $self->{child}->{gaming}->{tables}->{benches}->{$objClient->{property}->{games}->{tableID}}->{clients} = {}; 
                         $self->{child}->{gaming}->{tables}->{benches}->{$objClient->{property}->{games}->{tableID}}->{max} = 2;
                     }
                     $self->{child}->{gaming}->{tables}->{benches}->{$objClient->{property}->{games}->{tableID}}->{type} = 'four';
                     $self->{child}->{gaming}->{tables}->{benches}->{$objClient->{property}->{games}->{tableID}}->{coins} = 0;
                     my @arrGMap = ();
                     for my $intX (0..6) {
		  	  	 	 	             for my $intY (0..7) {
                         push (@arrGMap, $self->{child}->{gaming}->{manager}->{types}->{findf}->{seats}->{$objClient->{property}->{games}->{tableID}}->{$intX}->{$intY});
		  	  	 	 	             }
                     }
                     my $strGMap = join(',', @arrGMap);
                     $objClient->write('%xt%gz%-1%%%' . substr($strGMap, 0, -1) . '%');
               }
       }
}

method handleGameLeave($strData, $objClient) {
       switch ($objClient->{property}->{room}->{roomID}) {
               case (951) {
                     if (exists($self->{child}->{gaming}->{manager}->{types}->{jitsu}->{matches}->{$objClient->{property}->{games}->{matchID}})) {
                         $self->{child}->{gaming}->{manager}->{types}->{jitsu}->{matches}->{$objClient->{property}->{games}->{matchID}}->{firstPlayer}->sendXT('cjsi', '-1', 0, 10, 2);
                         $self->{child}->{gaming}->{manager}->{types}->{jitsu}->{matches}->{$objClient->{property}->{games}->{matchID}}->{firstPlayer}->sendXT('cz', '-1', $objClient->{property}->{personal}->{username});
                         if (!$self->{child}->{gaming}->{manager}->{types}->{jitsu}->{matches}->{$objClient->{property}->{games}->{matchID}}->{firstPlayer}->{property}->{games}->{isSensei}) {
                             $self->{child}->{gaming}->{manager}->{types}->{jitsu}->{matches}->{$objClient->{property}->{games}->{matchID}}->{secondPlayer}->sendXT('cjsi', '-1', 0, 10, 2);
                             $self->{child}->{gaming}->{manager}->{types}->{jitsu}->{matches}->{$objClient->{property}->{games}->{matchID}}->{secondPlayer}->sendXT('cz', '-1', $objClient->{property}->{personal}->{username});
		  	  	 			              }
                         $self->{child}->{gaming}->{manager}->{types}->{jitsu}->{matches}->{$objClient->{property}->{games}->{matchID}}->{firstPlayer}->{property}->{games}->{isSensei} = 0;
		  	  	 	            }
               }
               case (220 || 221) {
                     return if (!defined($objClient->{property}->{games}->{tableID}));
                     foreach my $objPlayer ($self->{child}->{gaming}->{tables}->{benches}->{$objClient->{property}->{games}->{tableID}}->{clients}) {
                        if ($objPlayer->{property}->{personal}->{userID} ne $objClient->{property}->{personal}->{userID}) {
                            $objPlayer->sendXT('cz', '-1', $objClient->{property}->{personal}->{username});
                            $objPlayer->{property}->{games}->{tableID} = undef;
                        }
                     }          
                     delete($self->{child}->{gaming}->{tables}->{benches}->{$objClient->{property}->{games}->{tableID}});
                     $self->{child}->{gaming}->{tables}->{benches}->{$objClient->{property}->{games}->{tableID}}->{clients} = {}; 
                     $self->{child}->{gaming}->{tables}->{benches}->{$objClient->{property}->{games}->{tableID}}->{max} = 2;                  
                     $self->{child}->{gaming}->{manager}->{types}->{findf}->{seats}->{$objClient->{property}->{games}->{tableID}} = $self->{child}->{gaming}->{manager}->{types}->{findf}->getNewMap();
               }
       }
}

method handleGameMoves($strData, $objClient) {
       my @arrData = split('%', $strData);
       switch ($objClient->{property}->{room}->{roomID}) {
               case (951) {
                     switch (lc($arrData[5])) {
                             case ('pick') {

                             }
                             case ('deal') {  

                             }
                     }
               }
       }
}

1;