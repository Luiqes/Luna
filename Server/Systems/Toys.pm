package Toys;

use strict;
use warnings;

use Method::Signatures;

method handleAddToy($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intPID = $arrData[5];
       return if (!int($intPID));
       $objClient->sendXT(['at', '-1', $intPID, 1]);
}

method handleRemoveToy($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intPID = $arrData[5];
       return if (!int($intPID));
       $objClient->sendXT(['rt', '-1', $intPID]);
}

1;