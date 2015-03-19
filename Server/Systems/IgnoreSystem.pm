use strict;
use warnings;

package IgnoreSystem;

use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       %{$obj->{handlers}} = (
                 'n#gn' => 'handleGetIgnored',
                 'n#an' => 'handleAddIgnore',
                 'n#rn' => ' handleRemoveIgnored'
       );
       return $obj;
}

method handleIgnoreSystem($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       return if (!exists($self->{handlers}->{$strCmd}));
       my $strHandler = $self->{handlers}->{$strCmd};
       return if (!defined(&{$strHandler}));
       $self->$strHandler(\@arrData, $objClient); 
}

method handleGetIgnored(\@arrData, $objClient) {
       my $strIgnored = $self->handleFetchIgnored($objClient);
	      $objClient->write('%xt%gn%' . $arrData[4] . '%' . ($strIgnored ? $strIgnored : '%'));
}

method handleAddIgnore(\@arrData, $objClient) {
       my $intPID = $arrData[5];
       return if (!int($intPID) && exists($objClient->{ignored}->{$intPID}));
       $objClient->{ignored}->{$intPID} = $objClient->{property}->{personal}->{username};
       $objClient->updateIgnore(join(',', keys %{$objClient->{ignored}}), $objClient->{property}->{personal}->{userID});
       $objClient->sendXT(['an', $objClient->{property}->{room}->{roomID}, $intPID]);
}

method handleRemoveIgnored(\@arrData, $objClient) {
       my $intPID = $arrData[5];
       return if (!int($intPID) && !exists($objClient->{ignored}->{$intPID}));
       delete($objClient->{ignored}->{$intPID});
       $objClient->updateIgnore(join(',', keys %{$objClient->{ignored}}), $objClient->{property}->{personal}->{userID});
       $objClient->sendXT(['rn', $objClient->{property}->{room}->{roomID}, $intPID]);
}

method handleFetchIgnored($objClient) {
       my $strIgnored = '';
       foreach my $intIgnored (keys %{$objClient->{ignored}}) {
          my $arrInfo = $self->{child}->{modules}->{mysql}->fetchColumns("SELECT `nickname` FROM $self->{child}->{dbConfig}->{tables}->{main} WHERE `ID` = '$intIgnored'");
          $strIgnored .= $intIgnored . '|' . $arrInfo->{nickname} . '%';
       }
       return $strIgnored;
}

method updateIgnore($strIgnored, $intPID) {
       return if (!int($intPID));
       $self->{child}->{modules}->{mysql}->updateTable($self->{child}->{dbConfig}->{tables}->{main}, 'ignored', $strIgnored, 'ID', $intPID);
}

1;