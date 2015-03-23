package EPF;

use strict;
use warnings;

use Method::Signatures;

method handleEPFAddItem($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intItem = $arrData[5];
       return if (!int($intItem));
       if (!exists($self->{modules}->{crumbs}->{epfCrumbs}->{$intItem})) {
           return $objClient->sendError(402);
       } elsif (grep /$intItem/, @{$objClient->{inventory}) {
           return $objClient->sendError(400);
       } elsif ($objClient->{epfPoints} < $self->{modules}->{crumbs}->{epfCrumbs}->{$intItem}->{points}) {
           return $objClient->sendError(405);
       }
       push(@{$objClient->{inventory}}, $intItem);
       $self->{modules}->{mysql}->updateTable('users', 'inventory', join('%', @{$objClient->{inventory}}) , 'ID', $objClient->{ID});
       $client->updateEPFPoints($objClient->{epfPoints} - $self->{modules}->{crumbs}->{epfCrumbs}->{$intItem}->{points});
       $client->sendXT(['epfai', '-1', $intItem, $objClient->{epfPoints}]);
}

method handleEPFGetAgent($strData, $objClient) {
	      $objClient->sendXT(['epfga', '-1', $objClient->{isEPF}]);
}

method handleEPFGetRevision($strData, $objClient) {
	      $objClient->sendXT(['epfgr', '-1', $objClient->{totalEPFPoints}, $objClient->{epfPoints}]);
}

method handleEPFGetField($strData, $objClient) {
	      $objClient->sendXT(['epfgf', '-1', $objClient->{fieldOPStatus}]);
}

method handleEPFSetField($strData, $objClient) {
       $objClient->{fieldOPStatus} ? $objClient->updateOPStat(0) : $objClient->updateOPStat(1);
       $objClient->sendXT(['epfsf', '-1', $objClient->{fieldOPStatus}]);
}

method handleEPFSetAgent($strData, $objClient) {
       if (!$objClient->{isEPF}) {
           $objClient->updateEPF(1);
           $objClient->sendXT(['epfsa', '-1', 1]);
       }
}

method handleEPFGetMessage($strData, $objClient) {
       my @arrInfo = ('u wot m8', time, 15);
       $objClient->sendXT(['epfgm', '-1', $objClient->{ID}, join('|', @arrInfo)]);
}

1;
