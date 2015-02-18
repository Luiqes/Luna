use strict;
use warnings;

package StampSystem;

use Method::Signatures;
use List::Util qw(first);

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       %{$obj->{handlers}} = (
                 'st#sse'	=> 'handleSendStampEarned',
                 'st#gps'	=>	'handleGetPlayersStamps',
                 'st#gmres' =>	'handleGetMyRecentlyEarnedStamps',
                 'st#gsbcd' =>	'handleGetStampBookCoverDetails',
	                'st#ssbcd'	=>	'handleSetStampBookCoverDetails'
       );
       return $obj;
}

method handleStampSystem($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       return if (!exists($self->{handlers}->{$strCmd}));
       my $strHandler = $self->{handlers}->{$strCmd};
       return if (!defined(&{$strHandler}));
       $self->$strHandler(\@arrData, $objClient);
}

method handleSendStampEarned(\@arrData, $objClient) {
       my $intStamp = $arrData[5];
       my $arrInfo = $self->{child}->{modules}->{mysql}->fetchColumns("SELECT `stamps`, `restamps` FROM $self->{child}->{dbConfig}->{tables}->{stamp} WHERE `ID` = '$objClient->{property}->{personal}->{userID}'");
       my $strFetchedStamps = $arrInfo->{stamps};
       my $strFetchedREStamps = $arrInfo->{restamps};
       my @arrStamps = split('\\|', $strFetchedStamps);
       return if (!exists($self->{child}->{modules}->{crumbs}->{stampCrumbs}->{$intStamp}));
       return if (first {$_ == $intStamp} @arrStamps);
       my $strStamps = $strFetchedStamps . '|' . $intStamp;
       my $strREStamps = $strFetchedREStamps . '|' . $intStamp;
       $self->{child}->{modules}->{mysql}->updateTable($self->{child}->{dbConfig}->{tables}->{stamp}, 'stamps', $strStamps, 'ID', $objClient->{property}->{personal}->{userID});
       $self->{child}->{modules}->{mysql}->updateTable($self->{child}->{dbConfig}->{tables}->{stamp}, 'restamps', $strREStamps, 'ID', $objClient->{property}->{personal}->{userID});
       $objClient->sendXT('aabs', '-1', $intStamp);
}

method handleGetPlayersStamps(\@arrData, $objClient) {
       my $intID = $arrData[5];
       my $arrInfo = $self->{child}->{modules}->{mysql}->fetchColumns("SELECT `stamps` FROM $self->{child}->{dbConfig}->{tables}->{stamp} WHERE `ID` = '$intID'");
       my $strStamps = $arrInfo->{stamps};
       $objClient->sendXT('gps', '-1', $intID, $strStamps);
}

method handleGetMyRecentlyEarnedStamps(\@arrData, $objClient) {
       my $intID = $objClient->{property}->{personal}->{userID};
       my $arrInfo = $self->{child}->{modules}->{mysql}->fetchColumns("SELECT `restamps` FROM $self->{child}->{dbConfig}->{tables}->{stamp} WHERE `ID` = '$intID'");
       my $strREStamps = $arrInfo->{restamps};
       $objClient->sendXT('gmres', '-1', $intID, $strREStamps);
       $self->{child}->{modules}->{mysql}->updateTable($self->{child}->{dbConfig}->{tables}->{stamp}, 'restamps', '', 'ID', $intID);
}

method handleGetStampBookCoverDetails(\@arrData, $objClient) {
       my $intID = $arrData[5];
       my $arrInfo = $self->{child}->{modules}->{mysql}->fetchColumns("SELECT `cover` FROM $self->{child}->{dbConfig}->{tables}->{stamp} WHERE `ID` = '$intID'");
       my $strCover = $arrInfo->{cover};
       $objClient->write('%xt%gsbcd%-1%' . $strCover);     
}

method handleSetStampBookCoverDetails(\@arrData, $objClient) {
       my @arrCover = ();
       while (my ($intKey, $intValue) = each(@arrData)) {
              if ($intKey > 4) {
                  push(@arrCover, $intValue);
              }
       }
       my $strCover = join('%', @arrCover);
       $self->{child}->{modules}->{mysql}->updateTable($self->{child}->{dbConfig}->{tables}->{stamp}, 'cover', $strCover, 'ID', $objClient->{property}->{personal}->{userID});
       $objClient->write('%xt%ssbcd%-1%' . $strCover);
}

1;