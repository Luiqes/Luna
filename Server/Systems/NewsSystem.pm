use strict;
use warnings;

package NewsSystem;

use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       %{$obj->{handlers}} = (  
                 't#at' => 'handleAddToy',
                 't#rt' => 'handleRemoveToy' 
       );
       return $obj;
}

method handleNewsSystem($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       return if (!exists($self->{handlers}->{$strCmd}));
       my $strHandler = $self->{handlers}->{$strCmd};
       return if (!defined(&{$strHandler}));
       $self->$strHandler($objClient, $arrData[5]);
}

method handleAddToy($objClient, Int $intPID) {
       $objClient->sendXT('at', '-1', $intPID, 1);
}

method handleRemoveToy($objClient, Int $intPID) {
       $objClient->sendXT('rt', '-1', $intPID);
}

1;