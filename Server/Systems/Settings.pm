package Settings;

use strict;
use warnings;

use Method::Signatures;

method handleUpdatePlayerClothing($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       my @arrCmd = split('#', $strCmd);
       my $intItem = $arrData[5];
       my $strType = $arrCmd[1];
       my $arrTypes = {upc => 'colour', uph => 'head', upf => 'face', upn => 'neck', upb => 'body', upa => 'hand', upe => 'feet', upp => 'photo', upl => 'flag'};
       return if (!exists($arrTypes{$strType}));        
       $objClient->updatePlayerCard($strType, $arrTypes{$strType}, $intItem);
}

1;