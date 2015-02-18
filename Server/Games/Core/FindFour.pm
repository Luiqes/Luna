use strict;
use warnings;

package FindFour;

use Method::Signatures;

method new($resParent) {
       my $obj = bless {}, $self;
       $obj->{parent} = $resParent;
       %{$obj->{seats}} = ();
       for my $intSeats (200..207) {
         $obj->{seats}->{$intSeats} = $self->getNewMap();
       }
       return $obj;
}

method checkGrid($intSeat, $intX, $intY) {
       return if (!exists($self->{seats}->{$intSeat}));
       my $blnCheck = $self->checkSeat($intSeat, $intX, $intY);
       my $intType = $self->{seats}->{$intSeat}->{$intX}->{$intY};
       my @arrWinType = (1 => 'WIN_ONE', 2 => 'WIN_TWO');
       if ($blnCheck) {
           return $intType ? $arrWinType[1] : $arrWinType[2];
       }
       my $blnMapFull = 1;
       for my $intX (0..6) {
         for my $intY (0..7) {
           if ($self->{seats}->{$intSeat}->{$intX}->{$intY} eq 0) {
               $blnMapFull = 0;
				      }
         }
       }
       return $blnMapFull ? 'DRAW', 'GOOD';		
}

method checkSeat($intSeat, $intX, $intY) {
       for my $intRow (0..6) {
			     for my $intCol (0..4) {
           if ($self->{seats}->{$intSeat}->{$intRow}->{$intCol} > 0) { 
               $intCount = 0;
               for my $intECol (1..4) {
                 if ($self->{seats}->{$intSeat}->{$intRow}->{$intCol} eq $self->{seats}->{$intSeat}->{$intRow}->{$intCol + $intECol}) {
                     $intCount++;
                 }
				          }
					         return ($intCount > 3 ? 1 : 0);
           }
				    }
       }
       for my $intCol (0..7) {
         for my $intRow (0..3) {
           if ($self->{seats}->{$intSeat}->{$intRow}->{$intCol} > 0) {
					         my $intCount = 0;
					         for my $intECol (1..4) {
                 if ($self->{seats}->{$intSeat}->{$intRow}->{$intCol} eq $self->{seats}->{$intSeat}->{$intRow + $intECol}->{$intCol}) {
                     $intCount++;
						          }
               }
               return (($intCount > 3) ? 1 : 0);
           }
         }
       }
}

method getNewMap {
	      my @arrMap = ();
       for my $intX (0..6) {
         for my $intY (0..7) {
				      $arrMap[$intX][$intY] = 0;
         }
       }
       return \@arrMap;
}

method resetSeat($intSeat) {
       return unless (exists($self->{seats}->{$intSeat}));
       delete($self->{seats}->{$intSeat});
       $self->{seats}->{$intSeat} = $self->getNewMap();
       return $self->{seats}->{$intSeat};
}

1;