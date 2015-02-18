use strict;
use warnings;

package MessageSystem;

use HTML::Entities;
use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       return $obj;
}

method handleMessageSystem($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       my $strMsg = $arrData[6];
       if ($strCmd eq 'm#sm') {
           $objClient->sendMessage($strMsg);
       }
}

1;