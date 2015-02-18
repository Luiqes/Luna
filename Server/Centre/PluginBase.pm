use strict;
use warnings;

package PluginBase;

use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       return $obj;
}

method addCustomXTHandler($objClass, $strHandle, $strHandler) {
       %{$self->{xtHandlers}->{$strHandle}} = (class => $objClass, method => $strHandler);
}

method addCustomXMLHandler($objClass, $strHandle, $strHandler) {
       %{$self->{xmlHandlers}->{$strHandle}} = (class => $objClass, method => $strHandler);
}

method handleXMLData($strData, $objClient) {     
       my $strXML = $self->{child}->{modules}->{tools}->parseXML($strData);
       return  if (!$strXML);
       my $strAct = $strXML->{body}->{action};
       return if (!exists($self->{xmlHandlers}->{$strAct}));
       my $objClass = $self->{xmlHandlers}->{$strAct}->{class};
       my $strHandler = $self->{xmlHandlers}->{$strAct}->{method};
       $objClass->$strHandler($strXML, $objClient);
}

method handleXTData($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       return if (!exists($self->{xtHandlers}->{$strCmd}));
       my $objClass = $self->{xtHandlers}->{$strCmd}->{class};
       my $strHandler = $self->{xtHandlers}->{$strCmd}->{method};
       $objClass->$strHandler($strData, $objClient);
}

1;