use strict;
use warnings;

package Bait;

use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       $obj->{isEnabled} = 1;
       return $obj;
}

method handleInitialization {
       $self->{child}->{modules}->{pbase}->addCustomXTHandler($self, 'i#ai', 'handleItemBlocking');
}

method handleItemBlocking($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intItem = $arrData[5];
       if ($self->{child}->{modules}->{crumbs}->{itemCrumbs}->{$intItem}->{isBait}) {
           $objClient->sendError(800);
           return $objClient->banClient($objClient->{property}->{personal}->{username});
       }
}

1;