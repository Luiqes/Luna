use strict;
use warnings;

package EPFSystem;

use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       %{$obj->{handlers}} = (
                 'f#epfai' => 'handleEPFAddItem',
                 'f#epfga' => 'handleEPFGetAgent',
                 'f#epfgr' => 'handleEPFGetRevision',
                 'f#epfgf' => 'handleEPFGetFieldOPStatus',
                 'f#epfsf' => 'handleEPFSetFieldOPStatus',
                 'f#epfsa' => 'handleEPFSetAgent',
                 'f#epfgm' => 'handleEPFGetMessage'
       );
       return $obj;
}

method handleEPFSystem($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       return if (!exists($self->{handlers}->{$strCmd}));
       my $strHandler = $self->{handlers}->{$strCmd};
       return if (!defined(&{$strHandler}));
       $self->$strHandler(\@arrData, $objClient);
}

method handleEPFAddItem(\@arrData, $objClient) {
       my $intItem = $arrData[5];
       $objClient->sendXT('epfai', $arrData[4], $intItem);
       $objClient->addItem($intItem);
       $objClient->updateMedals();
}

method handleEPFGetAgent(\@arrData, $objClient) {
	      $objClient->sendXT('epfga', $arrData[4], $objClient->{property}->{epf}->{isEPF});
}

method handleEPFGetRevision(\@arrData, $objClient) {
	      $objClient->sendXT('epfgr', $arrData[4], $objClient->{property}->{epf}->{medalsUsed}, $objClient->{property}->{epf}->{medalsUnused});
}

method handleEPFGetFieldOPStatus(\@arrData, $objClient) {
	      $objClient->sendXT('epfgf', $arrData[4], $objClient->{property}->{epf}->{fieldOPStatus});
}

method handleEPFSetFieldOPStatus(\@arrData, $objClient) {
       $objClient->{property}->{epf}->{fieldOPStatus} ? $objClient->updateOPStat(0) : $objClient->updateOPStat(1);
       $objClient->sendXT('epfsf', $arrData[4], $objClient->{property}->{epf}->{fieldOPStatus});
}

method handleEPFSetAgent(\@arrData, $objClient) {
       $objClient->sendXT('epfsa', $arrData[4], $objClient->{property}->{epf}->{isEPF});
}

method handleEPFGetMessage(\@arrData, $objClient) {
       my @arrInfo = ('Thanks for using Luna', time(), 15);
       $objClient->sendXT('epfgm', $arrData[4], $objClient->{property}->{personal}->{userID}, join('|', @arrInfo));
}

1;