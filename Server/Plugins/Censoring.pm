use strict;
use warnings;

package Censoring;

use HTML::Entities;
use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       $obj->{isEnabled} = 1;
       @{$obj->{badWords}} = ('fuck', 'penis', 'vagina', 'rape');
       return $obj;
}

method handleInitialization {
       $self->{child}->{modules}->{pbase}->addCustomXTHandler($self, 'm#sm', 'handleCensoring');
}

method handleCensoring($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strMsg = $arrData[6];
       foreach my $strWord (@{$self->{badWords}}) {
          if (index($strMsg, $strWord) != -1)  {
              $objClient->sendError(610);
              return $self->{child}->{modules}->{base}->removeClientBySock($objClient->{sock});
          }
       }
}

1;