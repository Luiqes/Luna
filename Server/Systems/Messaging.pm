package Messaging;

use strict;
use warnings;

use Method::Signatures;

method handleSendMessage($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strMsg = $arrData[6];
       $objClient->sendMessage($strMsg);
}

1;