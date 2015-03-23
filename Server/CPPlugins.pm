package CPPlugins;

use strict;
use warnings;

use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       return $obj;
}

method handleXMLData($strData, $objClient) {     
       my $strXML = $self->{child}->{modules}->{tools}->parseXML($strData);
       if (!$strXML) {
           return $self->{child}->{modules}->{base}->removeClientBySock($objClient->{sock});
       }
       my $strAct = $strXML->{body}->{action};
       while (my ($objClass, $className) = each(%{$self->{plugins}})) {
              if ($objClass->{pluginType} eq 'XML') {
                  if (exists($objClass->{property}->{$strAct})) {
                      if ($objClass->{property}->{$strAct}->{isEnabled}) {
                          my $strHandler = $objClass->{property}->{$strAct}->{handler};
                          $objClass->$strHandler($strXML, $objClient);
                      }
                  }
              }
       }
}

method handleXTData($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       while (my ($objClass, $className) = each(%{$self->{plugins}})) {
              if ($objClass->{pluginType} eq 'XT') {
                  if (exists($objClass->{property}->{$strCmd})) {
                      if ($objClass->{property}->{$strCmd}->{isEnabled}) {
                          my $strHandler = $objClass->{property}->{$strCmd}->{handler};
                          $objClass->$strHandler($strData, $objClient);
                      }
                  }
              }
       }
}

1;