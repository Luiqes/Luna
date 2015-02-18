use strict;
use warnings;

package InventorySystem;

use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       %{$obj->{handlers}} = (
                 'i#gi' => 'handleGetItems',
                 'i#ai' => 'handleAddItem',
                 'i#qpp' => 'handleQueryPlayerPins',
                 'i#qpa' => 'handleQueryPlayerAwards'
       );
       return $obj;
}

method handleInventorySystem($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       return if (!exists($self->{handlers}->{$strCmd}));
       my $strHandler = $self->{handlers}->{$strCmd};
       return if (!defined(&{$strHandler}));
       $self->$strHandler(\@arrData, $objClient);
}

method handleGetItems(\@arrData, $objClient) {
       $objClient->sendXT('gi', $arrData[4], join('%',  @{$objClient->{inventory}})); 
}

method handleAddItem(\@arrData, $objClient) {
       my $intItem = $arrData[5];
       $objClient->addItem($intItem);
}

method handleQueryPlayerAwards(\@arrData, $objClient) {
       my $intPID = $arrData[5];
       return if (!int($intPID));
       my @arrAwards = ();
       foreach my $intItem (@{$objClient->{inventory}}) {
	         return if (!exists($self->{child}->{modules}->{crumbs}->{itemCrumbs}->{$intItem}));
          if ($self->{child}->{modules}->{crumbs}->{itemCrumbs}->{$intItem}->{type} == 10) {
              push(@arrAwards, $intItem);
          }
       }
       my $strAwards = join('|', @arrAwards);
       $objClient->sendXT('qpa', '-1', $intPID, $strAwards);
}

method handleQueryPlayerPins(\@arrData, $objClient) {
       my $intPID = $arrData[5];
       return if (!int($intPID));
       my @arrPins = ();
       my $objPlayer = $objClient->getClientByID($intPID);
       foreach my $intItem (@{$objPlayer->{inventory}}) {
				     return if (!exists($self->{child}->{modules}->{crumbs}->{itemCrumbs}->{$intItem}));
				     if ($self->{child}->{modules}->{crumbs}->{itemCrumbs}->{$intItem}->{type} == 8) {
              push(@arrPins, $intItem);
				     }   
       }
       my $strPins = join('|', @arrPins) . time() . '|0%';
       $objPlayer->sendXT('qpp', '-1', $strPins);
}

1;