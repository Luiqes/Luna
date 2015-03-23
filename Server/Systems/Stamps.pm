package Stamps;

use strict;
use warnings;

use Method::Signatures;

method handleSendStampEarned($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intStamp = $arrData[5];
       return if (!int($intStamp));
       return if (!exists($self->{modules}->{crumbs}->{stampCrumbs}->{$intStamp}));
       return if (grep /$intStamp/, @{$objClient->{stamps}});
       push(@{$objClient->{stamps}}, $intStamp);
       push(@{$objClient->{restamps}}, $intStamp);
       $self->{modules}->{mysql}->updateTable('users', 'stamps', join('|', @{$objClient->{stamps}}, 'ID', $objClient->{ID});
       $self->{modules}->{mysql}->updateTable('users', 'restamps', join('|', @{$objClient->{restamps}}, 'ID', $objClient->{ID});
       $objClient->sendXT(['aabs', '-1', $intStamp]);
}

method handleGetPlayersStamps($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intPID = $arrData[5];
       return if (!int($intPID));
       my $arrInfo = $self->{modules}->{mysql}->fetchColumns("SELECT `stamps` FROM users WHERE `ID` = '$intPID'");
       my $strStamps = $arrInfo->{stamps};
       $objClient->sendXT(['gps', '-1', $intPID, $strStamps]);
}

method handleGetMyRecentlyEarnedStamps($strData, $objClient) {
       my $intID = $objClient->{ID};
       my $arrInfo = $self->{modules}->{mysql}->fetchColumns("SELECT `restamps` FROM users WHERE `ID` = '$intID'");
       my $strREStamps = $arrInfo->{restamps};
       $objClient->sendXT(['gmres', '-1', $intID, $strREStamps]);
       $self->{modules}->{mysql}->updateTable('users', 'restamps', '', 'ID', $intID);
}

method handleGetStampBookCoverDetails($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intPID = $arrData[5];
       return if (!int($intPID));
       my $arrInfo = $self->{modules}->{mysql}->fetchColumns("SELECT `cover` FROM users WHERE `ID` = '$intPID'");
       my $strCover = $arrInfo->{cover};
       $objClient->write('%xt%gsbcd%-1%' . ($strCover ? $strCover : '1%1%1%1%'));     
}

method handleSetStampBookCoverDetails($strData, $objClient) {
       my @arrData = split('%', $strData);
       my @arrCover;
       while (my ($intKey, $intValue) = each(@arrData)) {
              if ($intKey > 4) {
                  push(@arrCover, $intValue);
              }
       }
       my $strCover = join('%', @arrCover);
       $self->{modules}->{mysql}->updateTable('users', 'cover', $strCover, 'ID', $objClient->{ID});
       $objClient->write('%xt%ssbcd%-1%' . ($strCover ? $strCover : '%'));
}

1;