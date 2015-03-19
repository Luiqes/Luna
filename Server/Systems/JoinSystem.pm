use strict;
use warnings;

package JoinSystem;

use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       %{$obj->{handlers}} = (
                 'j#jp' => 'handleJoinPlayer',
                 'j#js' => 'handleJoinServer',
                 'j#jr' => 'handleJoinRoom'
       );
       return $obj;
}

method handleJoinSystem($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       return if (!exists($self->{handlers}->{$strCmd}));
       my $strHandler = $self->{handlers}->{$strCmd};
       return if (!defined(&{$strHandler}));
       $self->$strHandler(\@arrData, $objClient);
}

method handleJoinPlayer(\@arrData, $objClient) {
       my $intRoom = $arrData[5];
       $objClient->sendXT(['jp', $arrData[4], $intRoom]); 
       $objClient->joinRoom($intRoom);
}

method handleJoinRoom(\@arrData, $objClient) {
       my $intRoom = $arrData[5];
       my $intX = $arrData[6];
       my $intY = $arrData[7];
       $objClient->joinRoom($intRoom, $intX, $intY);
}

method handleJoinServer(\@arrData, $objClient) {
       $objClient->updateKey('', $objClient->{property}->{personal}->{username});
       $objClient->sendXT(['js', $arrData[4], 1, ($objClient->{property}->{epf}->{isEPF} ? 1 : 0), ($objClient->{property}->{personal}->{isStaff} ? 1 : 0)]);
       $objClient->sendXT(['lp', $arrData[4], $objClient->buildClientString(), $objClient->{property}->{personal}->{coins}, 0, 1440, 100, $objClient->{property}->{personal}->{age}, 4, $objClient->{property}->{personal}->{age}, 7]);
       $objClient->sendEarnedStamps();
       $objClient->joinRoom($self->{child}->generateRoom());     
}

1;