use strict;
use warnings;

package IglooSystem;

use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       %{$obj->{handlers}} = (
                 'g#af' => 'handleAddFurniture',
                 'g#ao' => 'handleUpdateIgloo',
                 'g#au' => 'handleAddIgloo',
                 'g#ag' => 'handleUpdateFloor',
                 'g#um' => 'handleUpdateMusic',
                 'g#gm' => 'handleGetIglooDetails',
                 'g#go' => 'handleGetOwnedIgloos',
                 'g#or' => 'handleOpenIgloo',
                 'g#cr' => 'handleCloseIgloo',
                 'g#gf' => 'handleGetOwnedFurniture',
                 'g#ur' => 'handleGetFurnitureRevision',
                 'g#gr' => 'handleGetOpenedIgloos'
       );
       return $obj;
}

method handleIglooSystem($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       return if (!exists($self->{handlers}->{$strCmd}));
       my $strHandler = $self->{handlers}->{$strCmd};
       return if (!defined(&{$strHandler}));
       $self->$strHandler(\@arrData, $objClient);
}

method handleAddFurniture(\@arrData, $objClient) {
       my $intFurn = $arrData[5];
       $objClient->addFurniture($intFurn);
}

method handleUpdateIgloo(\@arrData, $objClient) {
       my $intIgloo = $arrData[5];
       $objClient->updateIgloo($intIgloo);
}

method handleAddIgloo(\@arrData, $objClient) {
       my $intIgloo = $arrData[5];
       $objClient->addIgloo($intIgloo);
}

method handleUpdateFloor(\@arrData, $objClient) {
       my $intFloor = $arrData[5];
       $objClient->updateFloor($intFloor);
}

method handleUpdateMusic(\@arrData, $objClient) {
       my $intMusic = $arrData[5];
       $objClient->updateMusic($intMusic);
}

method handleGetIglooDetails(\@arrData, $objClient) {
       my $intPID = $arrData[5];
       my $arrInfo = $self->{child}->{modules}->{mysql}->fetchArr("SELECT `igloo`, `music`, `floor`, `furniture` FROM $self->{child}->{dbConfig}->{tables}->{igloo} WHERE `ID` = '$intPID'");
       my $intIgloo = $arrInfo->{igloo};
       my $intMusic = $arrInfo->{music};
       my $intFloor = $arrInfo->{floor};
       my $strFurn = $arrInfo->{furniture};
       $objClient->sendXT(['gm', $arrData[4], $intPID, $intIgloo, $intMusic, $intFloor, $strFurn]);
}

method handleGetOwnedIgloos(\@arrData, $objClient) {
       my $strIgloos = join('|', @{$objClient->{ownedIgloos}});
       $objClient->sendXT(['go', $arrData[4], $strIgloos]);
}

method handleOpenIgloo(\@arrData, $objClient) {
       $objClient->openIgloo();
}

method handleCloseIgloo(\@arrData, $objClient) {
       $objClient->closeIgloo();
}

method handleGetOwnedFurniture(\@arrData, $objClient) {
       my $strFurns = join('%', @{$objClient->{ownedFurns}});
       $objClient->sendXT(['gf', $arrData[4], $strFurns]);
}

method handleGetFurnitureRevision(\@arrData, $objClient) {
       my @arrFurns = ();
       while (my ($intKey, $intValue) = each(@arrData)) {
              if ($intKey > 4) {
                  push(@arrFurns, $intValue);
              }
       }
       my $strFurn = join(',', @arrFurns);
       $objClient->updateFurniture($strFurn);
}

method handleGetOpenedIgloos(\@arrData, $objClient) {
       my $strIgloos = $self->handleIglooMap();
       $objClient->write('%xt%gr%' . $arrData[4] . '%' . ($strIgloos ? $strIgloos : '')); 	 
}

method handleIglooMap {
       my $strMap = '';
       while (my ($intPID, $strName) = each(%{$self->{child}->{igloos}})) {
              $strMap .= $intPID . '|' . $strName . '%';
       }
       return $strMap;
}

1;