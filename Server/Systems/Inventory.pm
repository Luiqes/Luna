package Inventory;

use strict;
use warnings;

use Method::Signatures;

method handleGetItems($strData, $objClient) {
       $objClient->sendXT(['gi', '-1', join('%',  @{$objClient->{inventory}})]); 
}

method handleAddItem($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intItem = $arrData[5];
       $objClient->addItem($intItem);
}

method handleQueryPlayerAwards($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intPID = $arrData[5];
       return if (!int($intPID));
       my $objPlayer = $objClient->getClientByID($intPID);
       my @arrAwards;
       foreach (@{$objPlayer->{inventory}}) {
                if (exists($self->{modules}->{crumbs}->{itemCrumbs}->{$_})) && $self->{modules}->{crumbs}->{itemCrumbs}->{$_}->{type} == 10) {
                    push(@arrAwards, $_);
                }
       }
       my $strAwards = join('|', @arrAwards);
       $objClient->sendXT(['qpa', '-1', $intPID, $strAwards]);
}

method handleQueryPlayerPins($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intPID = $arrData[5];
       return if (!int($intPID));
       my $objPlayer = $objClient->getClientByID($intPID);
       my @arrPins;
       foreach (@{$objPlayer->{inventory}}) {
				           if (exists($self->{modules}->{crumbs}->{itemCrumbs}->{$_}) && $self->{child}->{modules}->{crumbs}->{itemCrumbs}->{$_}->{type} == 8) {
                    push(@arrPins, $_);
				           }   
       }
       my $strPins = join('|', @arrPins) . time . '|0%';
       $objClient->sendXT(['qpp', '-1', $intPID, $strPins]);
}

1;