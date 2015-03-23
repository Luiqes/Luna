package Ignore;

use strict;
use warnings;

use Method::Signatures;

method handleGetIgnored($strData, $objClient) {
       my $strIgnored = $self->handleFetchIgnored($objClient);
	      $objClient->write('%xt%gn%-1%' . ($strIgnored ? $strIgnored : '%'));
}

method handleAddIgnore($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intPID = $arrData[5];
       return if (!int($intPID) && exists($objClient->{ignored}->{$intPID}));
       $objClient->{ignored}->{$intPID} = $objClient->{username};
       my $string = '';
       while (my ($ignID, $ignName) = each(%{$objClient->{ignored}})) {
              $string .= $ignID . '|' . $ignName . ',';
       }
       $objClient->updateIgnore($string, $objClient->{ID});
       $objClient->sendXT(['an', $objClient->{room}, $intPID]);
}

method handleRemoveIgnored($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intPID = $arrData[5];
       return if (!int($intPID) && !exists($objClient->{ignored}->{$intPID}));
       delete($objClient->{ignored}->{$intPID});
       my $string = '';
       while (my ($ignID, $ignName) = each(%{$objClient->{ignored}})) {
              $string .= $ignID . '|' . $ignName . ',';
       }
       $objClient->updateIgnore($string, $objClient->{ID});
       $objClient->sendXT(['rn', $objClient->{room}, $intPID]);
}

method handleFetchIgnored($objClient) {
       my $strIgnored = '';
       foreach (keys %{$objClient->{ignored}}) {
                my $arrInfo = $self->{modules}->{mysql}->fetchColumns("SELECT `nickname` FROM users WHERE `ID` = '$_'");
                $strIgnored .= $_ . '|' . $arrInfo->{nickname} . '%';
       }
       return $strIgnored;
}

1;