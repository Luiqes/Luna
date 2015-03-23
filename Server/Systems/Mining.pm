package Mining;

use strict;
use warnings;

use Method::Signatures;

method handleCoinsDigUpdate($strData, $objClient) {
       my $intCoins = $self->{modules}->{crypt}->generateInt(1, 100);
       $objClient->setCoins($objClient->{coins} + $intCoins);
       $objClient->sendXT(['cdu', '-1', $intCoins, $objClient->{coins}]);
}

1;