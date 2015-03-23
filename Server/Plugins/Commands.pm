package Commands;

use strict;
use warnings;

use Method::Signatures;

use Moose;

extends 'CPCommands';

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       $obj->{pluginType} = 'XT';
       $obj->{property} = {
              'm#sm' => {
                     handler => 'handleCommand',
                     isEnabled => 1
              }
       };
       $obj->{commands} = {
                 members => {
                         ai => 'handleAddItem',
                         ac => 'handleAddCoins',
                         cnick => 'handleChangeNickname',
                         sping => 'handleSendPong',
                         sid => 'handleSendID',
                         scount => 'handleSendServerPopulation',
                         rcount => 'handleSendRoomPopulation'                                  
                 },
                 staff => {
                       tban => 'handleTimeBanClient',
                       kbc => 'handleKickBanClient',
                       ban => 'handleBanClient',
                       unban => 'handleUnbanClient',
                       reboot => 'handleServerReboot',
                       global => 'handleServerSay',
                       summon => 'handleSummonClient'
                 }
       };
       return $obj;
}

method handleCommand($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strMsg = $arrData[6];
       my $chrCmd = substr($strMsg, 0, 1);
       my $blnMember = $chrCmd eq $self->{child}->{servConfig}->{userPrefix} ? 1 : 0;
       my $blnStaff = $chrCmd eq $self->{child}->{servConfig}->{staffPrefix} ? 1 : 0;
       return if (!$blnMember && !$blnStaff);
       $blnMember ? $self->handleCommands($strMsg, $objClient) : $self->handleStaffCommands($strMsg, $objClient);
}

method handleCommands($strMsg, $objClient) {
       my @arrParts = split(' ', substr($strMsg, 1), 2);
       my $strCmd = lc($arrParts[0]);
       my $strArg = $arrParts[1];
       return if (!exists($self->{commands}->{members}->{$strCmd}));
       my $strHandler = $self->{commands}->{members}->{$strCmd};
       $self->$strHandler($objClient, $strArg);
}

method handleStaffCommands($strMsg, $objClient) {
       my @arrParts = split(' ', substr($strMsg, 1), 2);
       my $strCmd = lc($arrParts[0]);
       my $strArg = $arrParts[1];
       return if (!exists($self->{commands}->{staff}->{$strCmd}));
       my $strHandler = $self->{commands}->{staff}->{$strCmd};
       if ($objClient->{isStaff}) {
           $self->$strHandler($objClient, $strArg);
       }
}

1;