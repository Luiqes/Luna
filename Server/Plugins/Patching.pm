use strict;
use warnings;

package Patching;

use List::Util qw(first);
use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       $obj->{isEnabled} = 1;   
       @{$obj->{patchedItems}} = (413, 1337, 420, 6969);
       return $obj;
}

method handleInitialization {
       $self->{child}->{modules}->{pbase}->addCustomXTHandler($self, 'i#ai', 'handlePatching');
}

method handlePatching($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intItem = $arrData[5];       
       if (first {$_ == $intItem} @{$self->{patchedItems}}) {
           return $objClient->sendError(402);
       }
}

1;