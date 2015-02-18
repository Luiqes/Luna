use strict;
use warnings;

package UserSettingsSystem;

use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       return $obj;
}

method handleUserSettingsSystem($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       my @arrCmd = split('s#', $strCmd);
       my $intItem = $arrData[5];
       my $strType = $arrCmd[0];
       my %arrTypes = (upc => 'colour', uph => 'head', upf => 'face', upn => 'neck', upb => 'body', upa => 'hand', upe => 'feet', upp => 'photo', upl => 'flag');
       return if (!exists($arrTypes{$strType}) && !int($intItem));        
       $objClient->updatePlayerCard($strType, $arrTypes{$strType}, $intItem);
}

1;