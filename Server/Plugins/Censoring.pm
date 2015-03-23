package Censoring;

use strict;
use warnings;

use HTML::Entities;
use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       $obj->{pluginType} = 'XT';
       $obj->{property} = {
              'm#sm' => {
                     handler => 'handleCensoring',
                     isEnabled => 0
              }
       };
       $obj->{badWords} = ['fuck', 'penis', 'vagina', 'rape'];
       return $obj;
}

method handleCensoring($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strMsg = decode_entities($arrData[6]);
       foreach (@{$self->{badWords}}) {
               if (index($strMsg, $_) != -1)  {
                   $objClient->sendError(610);
                   return $self->{child}->{modules}->{base}->removeClientBySock($objClient->{sock});
               }
       }
}

1;