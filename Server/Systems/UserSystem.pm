use strict;
use warnings;

package UserSystem;

use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       %{$obj->{handlers}} = (
                 'u#sf' => 'handleUserSetFrame',
                 'u#se' => 'handleUserSendEmote',
                 'u#sa' => 'handleUserSendAction',
                 'u#ss' => 'handleUserSendSafeMessage',
                 'u#sg' => 'handleUserSendTourGuideMessage',
                 'u#sj' => 'handleUserSendJoke',
                 'u#sma' => 'handleUserSendMascotMessage',
                 'u#sp' => 'handleUserSetPosition',
                 'u#sb' => 'handleUserSnowball',
                 'u#glr' => 'handleUserGetLatestRevision',
                 'u#gp' => 'handleUserGetPlayer',
                 'u#h' => 'handleUserHeartbeat'
       );
       return $obj;
}

method handleUserSystem($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       return if (!exists($self->{handlers}->{$strCmd}));
       my $strHandler = $self->{handlers}->{$strCmd};
       return if (!defined(&{$strHandler}));
       $self->$strHandler(\@arrData, $objClient);
}

method handleUserSetFrame(\@arrData, $objClient) {
       my $intFrame = $arrData[5];
       $objClient->setFrame($intFrame);
}

method handleUserSendEmote(\@arrData, $objClient) {
       my $intEmote = $arrData[5];
       $objClient->sendEmote($intEmote);
}

method handleUserSendAction(\@arrData, $objClient) {
       my $intAction = $arrData[5];
       $objClient->setAction($intAction);
}

method handleUserSendSafeMessage(\@arrData, $objClient) {
       my $intMsg = $arrData[5];
       $objClient->sendSafeMsg($intMsg);
}

method handleUserSendTourGuideMessage(\@arrData, $objClient) {
       my $intMsg = $arrData[5];
       $objClient->sendTourMsg($intMsg);
}

method handleUserSendJoke(\@arrData, $objClient) {
       my $intJoke = $arrData[5];
       $objClient->sendJoke($intJoke);
}

method handleUserSendMascotMessage(\@arrData, $objClient) {
       my $intMsg = $arrData[5];
       $objClient->sendMascotMsg($intMsg);
}

method handleUserSetPosition(\@arrData, $objClient) {
       my $intX = $arrData[5];
       my $intY = $arrData[6];
       $objClient->setPosition($intX, $intY);
}

method handleUserSnowball(\@arrData, $objClient) {
       my $intX = $arrData[5];
       my $intY = $arrData[6];
       $objClient->throwSnowball($intX, $intY);
}

method handleUserGetLatestRevision(\@arrData, $objClient) {
       $objClient->getLatestRevision();
}
          
method handleUserGetPlayer(\@arrData, $objClient) {
       my $intID = $arrData[5];
       $objClient->getPlayer($intID);
}

method handleUserHeartbeat(\@arrData, $objClient) {
       $objClient->sendHeartBeat();
}

1;