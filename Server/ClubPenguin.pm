package ClubPenguin;

use strict;
use warnings;

use Moose;

extends 'Buddies';
extends 'Ignore';
extends 'EPF';
extends 'Igloos';
extends 'Settings';
extends 'Inventory';
extends 'Navigation';
extends 'Mining';
extends 'Postcards'; 
extends 'Stamps';
extends 'Messaging';
extends 'Player';
extends 'Moderator';
extends 'Pets';
extends 'Toys'; 
extends 'Tables';
extends 'Ninja';
extends 'Election';

use Method::Signatures;
use Digest::MD5 qw(md5_hex);
use Math::Round qw(round);
use List::Compare qw(is_LsubsetR);

method new($resConfig, $resDBConfig) {
       my $obj = bless {}, $self;
       $obj->{servConfig} = $resConfig;
       $obj->{dbConfig} = $resDBConfig;
       $obj->{handlers} =  {
               xml => {
                   verChk => 'handleVerChk',                          
                   rndK => 'handleRndK',				                    
                   login => 'handleLogin'
               },
               xt => {
                  s => {
                    'j#jp' => 'handleJoinPlayer',
                    'j#js' => 'handleJoinServer',
                    'j#jr' => 'handleJoinRoom',
                    'j#jg' => 'handleJoinGame',
                    'j#grs' => 'handleGetRoomSynced'
                    'b#gb' => 'handleGetBuddies',
                    'b#br' => 'handleBuddyRequest',
                    'b#ba' => 'handleBuddyAccept',
                    'b#rb' => 'handleRemoveBuddy',
                    'b#bf' => 'handleBuddyFind',
                    'f#epfai' => 'handleEPFAddItem',
                    'f#epfga' => 'handleEPFGetAgent',
                    'f#epfgr' => 'handleEPFGetRevision',
                    'f#epfgf' => 'handleEPFGetField',
                    'f#epfsf' => 'handleEPFSetField',
                    'f#epfsa' => 'handleEPFSetAgent',
                    'f#epfgm' => 'handleEPFGetMessage',
                    'g#af' => 'handleAddFurniture',
                    'g#ao' => 'handleUpdateIgloo',
                    'g#au' => 'handleAddIgloo',
                    'g#ag' => 'handleUpdateFloor',
                    'g#um' => 'handleUpdateMusic',
                    'g#gm' => 'handleGetIglooDetails',
                    'g#go' => 'handleGetOwnedIgloos',
                    'g#or' => 'handleOpenIgloo',
                    'g#cr' => 'handleCloseIgloo',
                    'g#gf' => 'handleGetOwnedFurniture',
                    'g#ur' => 'handleGetFurnitureRevision',
                    'g#gr' => 'handleGetOpenedIgloos'
                    'n#gn' => 'handleGetIgnored',
                    'n#an' => 'handleAddIgnore',
                    'n#rn' => ' handleRemoveIgnored',
                    'i#gi' => 'handleGetItems',
                    'i#ai' => 'handleAddItem',
                    'i#qpp' => 'handleQueryPlayerPins',
                    'i#qpa' => 'handleQueryPlayerAwards',
                    'm#sm' => 'handleSendMessage',
                    'r#cdu' => 'handleCoinsDigUpdate',
                    'o#k' => 'handleKick',
                    'o#m' => 'handleMute',
                    'o#b' => 'handleBan',
                    'p#pg' => 'handleGetPuffle',
                    'p#pip' => 'handlePufflePip',
                    'p#pir' => 'handlePufflePir',
                    'p#ir' => 'handlePuffleIsResting',
                    'p#ip' => 'handlePuffleIsPlaying',
                    'p#pw' => 'handlePuffleWalk',
                    'p#pgu' => 'handlePuffleUser',
                    'p#pf' => 'handlePuffleFeedFood',
                    'p#phg' => 'handlePuffleClick',
                    'p#pn' => 'handleAdoptPuffle',
                    'p#pr' => 'handlePuffleRest',
                    'p#pp' => 'handlePufflePlay',
                    'p#pt' => 'handlePuffleFeed',
                    'p#pm' => 'handlePuffleMove',
                    'p#pb' => 'handlePuffleBath',
                    'u#sf' => 'handleSetFrame',
                    'u#se' => 'handleSendEmote',
                    'u#sa' => 'handleSendAction',
                    'u#ss' => 'handleSendSafe',
                    'u#sg' => 'handleSendGuide',
                    'u#sj' => 'handleSendJoke',
                    'u#sma' => 'handleSendMascot',
                    'u#sp' => 'handleSetPosition',
                    'u#sb' => 'handleSnowball',
                    'u#glr' => 'handleGetLatestRevision',
                    'u#gp' => 'handleGetPlayer',
                    'u#h' => 'handleHeartbeat',
                    'l#mst' => 'handleMailStart',
                    'l#mg' =>	'handleMailGet',
                    'l#ms' =>	'handleMailSend',
                    'l#md'	=>	'handleMailDelete',
                    'l#mdp'	=>	'handleMailDeletePlayer',
                    'l#mc' =>	'handleMailChecked',
                    's#upc' => 'handleUpdatePlayerClothing',
                    's#uph' => 'handleUpdatePlayerClothing',
                    's#upf' => 'handleUpdatePlayerClothing',
                    's#upn' => 'handleUpdatePlayerClothing',
                    's#upb' => 'handleUpdatePlayerClothing',
                    's#upa' => 'handleUpdatePlayerClothing',
                    's#upe' => 'handleUpdatePlayerClothing',
                    's#upp' => 'handleUpdatePlayerClothing',
                    's#upl' => 'handleUpdatePlayerClothing',			
                    'st#sse'	=> 'handleSendStampEarned',
                    'st#gps'	=>	'handleGetPlayersStamps',
                    'st#gmres' =>	'handleGetMyRecentlyEarnedStamps',
                    'st#gsbcd' =>	'handleGetStampBookCoverDetails',
                    'st#ssbcd'	=>	'handleSetStampBookCoverDetails',
                    't#at' => 'handleAddToy',
                    't#rt' => 'handleRemoveToy',
                    'e#dc' => 'handleDonateCoins',
                    'e#spl' => 'handleSetPoll',
                    'ni#gnr' => 'handleGetNinjaRevision',
                    'ni#gnl' => 'handleGetNinjaLevel',
                    'ni#gcd' => 'handleGetCards',
                    'ni#gfl' => 'handleGetFireLevel',
                    'ni#gwl' => 'handleGetWaterLevel',
                    'ni#gsl' => 'handleGetSnowLevel',
                    'a#jt' => 'handleJoinTable',
                    'a#gt' => 'handleGetTable',
                    'a#upt' => 'handleUpdateTable',
                    'a#lt' => 'handleLeaveTable'
                  },
                  z => {},
                  red => {
                      rjs => 'handleRedemptionJoinServer',
                      rgbq => 'handleRedemptionGetBookQuestion',
                      rsba => 'handleRedemptionSendBookAnswer',
                      rsc => 'handleRedemptionSendCode',
                      rsgc => 'handleRedemptionSendGoldenCode'     
                  }
              }
       };
       $obj->{iplog} = {};
       $obj->{igloos} = {};
       $obj->{plugins} = {};
       $obj->{clients} = {};
       return $obj;
}

method initializeSource {
       $self->createHeader;
       $self->loadModules;
       $self->{modules}->{crumbs}->updateCrumbs;
       $self->{modules}->{crumbs}->loadCrumbs;
       $self->initiateMysql;
       $self->loadPlugins;
       $self->createServer;
       $self->initiateServer;
}

method createHeader {
       print chr(10);
       print '*************************************' . chr(10);
       print '*              Luna                 *' . chr(10);
       print '*************************************' . chr(10);
       print '*   Club Penguin Server Emulator    *' . chr(10);
       print '*************************************' . chr(10);
       print '*   Creator: Lynx                   *' . chr(10);
       print '*   License: MIT                    *' . chr(10);
       print '*   Protocol: Action Script 2.0     *' . chr(10);
       print '*************************************' . chr(10);
       print chr(10);
}

method loadModules {
       $self->{modules} = {
                 logger => Logger->new,
                 mysql => MySQL->new,
                 base => Socket->new($self),
                 crypt => Cryptography->new,
                 tools => Tools->new,
                 crumbs => Crumbs->new($self),
                 pbase => CPPlugins->new($self)
       };
}

method loadPlugins {       
       my @arrFiles = glob('Server/Plugins/*.pm');
       foreach (@arrFiles) {
                my $strClass = basename($_, '.pm');
                my $objPlugin = $strClass->new($self);
                $self->{plugins}->{$strClass} = $objPlugin;
       }
       my $pluginCount = scalar(keys %{$self->{plugins}});
       if ($pluginCount > 0) {
           $self->{modules}->{logger}->output('Successfully Loaded ' . $pluginCount . ' Plugins', Logger::LEVELS->{inf}); 
       } else {
           $self->{modules}->{logger}->output('Failed To Load Any Plugins', Logger::LEVELS->{err}); 
       }
}

method initiateMysql {
       $self->{modules}->{mysql}->createMysql($self->{dbConfig}->{dbHost}, $self->{dbConfig}->{dbName}, $self->{dbConfig}->{dbUser}, $self->{dbConfig}->{dbPass}) or $self->{modules}->{logger}->kill('Failed To Connect To Mysql', Logger::LEVELS->{err});
       $self->{modules}->{logger}->output('Successfully Connected To Mysql', Logger::LEVELS->{inf}); 
}

method createServer {
       if ($self->{servConfig}->{servType} eq 'game') {
           my $intExist = $self->{modules}->{mysql}->countRows("SELECT `servPort` FROM servers WHERE `servPort` = '$self->{servConfig}->{servPort}'");
           if ($intExist <= 0) {
               $self->{modules}->{mysql}->insertData('servers', ['servPort', 'servName', 'servIP'], [$self->{servConfig}->{servPort}, $self->{servConfig}->{servName}, $self->{servConfig}->{servHost}]);       
           }
       }
}

method initiateServer {
       $self->{modules}->{base}->createSocket($self->{servConfig}->{servPort}) or $self->{modules}->{logger}->kill('Failed to Bind to Port: ' . $self->{servConfig}->{servPort}, Logger::LEVELS->{err});
       $self->{modules}->{logger}->output('Successfully Started ' . ucfirst($self->{servConfig}->{servType}) . ' Server', Logger::LEVELS->{inf});
}

method handleCustomPlugins($strType, $strData, $objClient) {    
       my $blnXML = $strType eq 'xml' ? 1 : 0;
       my $blnXT = $strType eq 'xt' ? 1 : 0;
       return if (!$blnXML && !$blnXT);
       $blnXML ? $self->{modules}->{pbase}->handleXMLData($strData, $objClient) : $self->{modules}->{pbase}->handleXTData($strData, $objClient);
}

method handleXMLData($strData, $objClient) {
       if ($strData eq '<policy-file-request/>') {
	          return $self->handleCrossDomainPolicy($objClient);
       }
       my $strXML = $self->{modules}->{tools}->parseXML($strData);
       if (!$strXML) {
           return $self->{modules}->{base}->removeClientBySock($objClient->{sock});
       }
       my $strAct = $strXML->{body}->{action};
       return if (!exists($self->{handlers}->{xml}->{$strAct}));
       my $strHandler = $self->{handlers}->{xml}->{$strAct};
       return if (!defined(&{$strHandler}));
       $self->$strHandler($strXML, $objClient);
       $self->handleCustomPlugins('xml', $strData, $objClient);
}

method handleCrossDomainPolicy($objClient) {
       $objClient->write("<cross-domain-policy><allow-access-from domain='*' to-ports='" . $self->{servConfig}->{servPort} . "'/></cross-domain-policy>");
}

method handleVerChk($strXML, $objClient) {
       return $strXML->{body}->{v} eq 153 ? $objClient->write("<msg t='sys'><body action='apiOK' r='0'></body></msg>") : $objClient->write("<msg t='sys'><body action='apiKO' r='0'></body></msg>");
}

method handleRndK($strXML, $objClient) {
       $objClient->{loginKey} = $self->{modules}->{crypt}->generateKey;
       $objClient->write("<msg t='sys'><body action='rndK' r='-1'><k>" . $objClient->{loginKey} . "</k></body></msg>");
}

method handleLogin($strXML, $objClient) {     
       my $strName = $strXML->{body}->{login}->{nick};
       my $strPass = $strXML->{body}->{login}->{pword};     
       $self->checkBeforeLogin($strName, $strPass, $objClient);
}

method checkBeforeLogin($strName, $strPass, $objClient) {
       my $intNames = $self->{modules}->{mysql}->countRows("SELECT `username` FROM $self->{dbConfig}->{tables}->{main} WHERE `username` = '$strName'");
       my $arrInfo = $self->{modules}->{mysql}->fetchColumns("SELECT * FROM $self->{dbConfig}->{tables}->{main} WHERE `username` = '$strName'");
       my $strHash = $self->generateHash($arrInfo, $objClient);      
       if ($intNames <= 0) {
           $objClient->sendError(100);
           return $self->{modules}->{base}->removeClientBySock($objClient->{sock});
       } elsif ($strPass ne $strHash) {
           $objClient->sendError(101);	
           $objClient->updateInvalidLogins($arrInfo->{invalidLogins} + 1, $strName);
           return $self->{modules}->{base}->removeClientBySock($objClient->{sock});
       } elsif ($arrInfo->{invalidLogins} > 3) {
           $objClient->sendError(900);
           return $self->{modules}->{base}->removeClientBySock($objClient->{sock});
       } elsif (!$arrInfo->{active})  {
           $objClient->sendError(900);
           return $self->{modules}->{base}->removeClientBySock($objClient->{sock});
       } elsif ($arrInfo->{isBanned} eq 'PERM' || $arrInfo->{isBanned} > time) {
                if (int($arrInfo->{isBanned})) {
                    my $intTime = round(($arrInfo->{isBanned} - time) / 3600);
                    $objClient->sendError(601 . '%' . $intTime);	
                } else {
                    $objClient->sendError(603);	
                }
                return $self->{modules}->{base}->removeClientBySock($objClient->{sock});                
       }
       $self->continueLogin($strName, $arrInfo, $objClient);
} 

method generateHash($arrInfo, $objClient) {
       my $strLoginKey = $objClient->{loginKey};
       my $strLoginHash = $self->{modules}->{crypt}->encryptPass(uc($arrInfo->{password}), $strLoginKey);                            
       my $strGameHash = $self->{modules}->{crypt}->swapMD5(md5_hex($arrInfo->{loginKey} . $strLoginKey)) . $arrInfo->{loginKey};
       my $strType = $self->{servConfig}->{servType};
       my $strHash = $strType eq 'login' ? $strLoginHash : $strGameHash;
       return $strHash;
}

method continueLogin($strName, $arrInfo, $objClient) {
       if ($self->{servConfig}->{servType} eq 'login') {
           $objClient->write('%xt%gs%-1%' . $self->generateServerList . '%');  
           $objClient->write('%xt%l%-1%' . $arrInfo->{ID} . '%' . $self->{modules}->{crypt}->reverseMD5($objClient->{loginKey}) . '%0%');
           $objClient->updateKey($self->{modules}->{crypt}->reverseMD5($objClient->{loginKey}), $strName);
       } else {
           $objClient->{userID} = $arrInfo->{ID};
           $objClient->{isAuth} = 1;
           $objClient->updateIP($objClient->{ipAddr});
           $objClient->loadDetails;
           $objClient->sendXT(['l', '-1']);
           $objClient->handleBuddyOnline;
       }
}

method generateServerList {
       my $strServer = '';
       my $arrInfo = $self->{modules}->{mysql}->fetchColumns("SELECT * FROM servers");
       my $intPopulation = $arrInfo->{curPop};
       my $intBars = 0;
       if ($intPopulation <= 50) {    
           $intBars = 1;
       } elsif ($intPopulation > 50 && $intPopulation <= 100) {
           $intBars = 2;
       } elsif ($intPopulation > 100 && $intPopulation <= 200) {
           $intBars = 3;
       } elsif ($intPopulation > 200 && $intPopulation <= 300) {
           $intBars = 4;
       } elsif ($intPopulation > 300 && $intPopulation <= 400) {
           $intBars = 5;
       } elsif ($intPopulation > 400 && $intPopulation <= 500 && $intPopulation > 500) {
           $intBars = 6;
       }
       $strServer .= $arrInfo->{servIP} . ':' . $arrInfo->{servPort} . ':' . $arrInfo->{servName} . ':' . $intBars . '|';     
       return $strServer;
}

method handleXTData($strData, $objClient) {
       if (index($strData, '|') != -1) {
           return $self->{modules}->{base}->removeClientBySock($objClient->{sock});
       }
       my @arrData = split('%', $strData);
       my $chrXT = $arrData[2];
       my $stdXT = $arrData[3];
       return if (!exists($self->{handlers}->{xt}->{$chrXT}->{$stdXT}));
       my $strHandler = $self->{handlers}->{xt}->{$chrXT}->{$stdXT};
       return if (!defined(&{$strHandler}));
       if ($objClient->{isAuth} && $objClient->{username} ne '') { 
           $self->$strHandler($strData, $objClient);
       } else {
           $self->{modules}->{base}->removeClientBySock($objClient->{sock});
       }
}

method handleRedemptionJoinServer($strData, $objClient) {
       my @arrValues;
       for (1..16) {
            push(@arrValues, $_);
       }
       my $intStr = join(',', @arrValues);
       $objClient->sendXT(['rjs', '-1', $intStr, 0]);	             
}

method handleRedemptionGetBookQuestion($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intPage = $self->{modules}->{crypt}->generateInt(1, 80);
       my $intLine = $self->{modules}->{crypt}->generateInt(1, 50);
       my $intWord = $self->{modules}->{crypt}->generateInt(1, 25);
       $objClient->sendXT(['rgbq', '-1', $arrData[5], $intPage, $intLine, $intWord]);
}

method handleRedemptionSendBookAnswer($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $intCoins = $arrData[5];
       $objClient->sendXT(['rsba', '-1', $intCoins]);
       $objClient->updateCoins($objClient->{coins} + $intCoins);		
}

method handleRedemptionSendCode($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strName = $arrData[5];        
       if (length($strName) > 13) {
           return $objClient->sendError(21703);
       } elsif (length($strName) < 13) {
           return $objClient->sendError(21702);
       } elsif (!exists($self->{modules}->{crumbs}->{redeemCrumbs}->{$strName})) {
           return $objClient->sendError(20720);
       } elsif ($self->{modules}->{crumbs}->{redeemCrumbs}->{$strName}->{type} eq 'golden') {
           return $self->{modules}->{base}->removeClientBySock($objClient->{sock});
       }        
       my $strItems = $self->{modules}->{crumbs}->{redeemCrumbs}->{$strName}->{items};
       my $intCoins = $self->{modules}->{crumbs}->{redeemCrumbs}->{$strName}->{cost};
       my @arrItems = split('\\|', $strItems);
       my @arrExisting = @{$objClient->{inventory}};
       if (is_LsubsetR([\@arrItems, \@arrExisting])) {
           return $objClient->sendError(20721);
       }
       $objClient->sendXT(['rsc', '-1', 'CAMPAIGN', $strItems, $intCoins]);  
       $objClient->updateCoins($objClient->{coins} - $intCoins);
       foreach (@arrItems) {
                $objClient->addItem($_);
       }
}

method handleRedemptionSendGoldenCode($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strName = $arrData[5];
       if (length($strName) > 13) {
           return $objClient->sendError(21703);
       } elsif (length($strName) < 13) {
           return $objClient->sendError(21702);
       } elsif (!exists($self->{modules}->{crumbs}->{redeemCrumbs}->{$strName})) {
           return $objClient->sendError(20720);
       } elsif ($self->{modules}->{crumbs}->{redeemCrumbs}->{$strName}->{type} eq 'normal') {
           return $self->{modules}->{base}->removeClientBySock($objClient->{sock});
       }
       my $strItems = $self->{modules}->{crumbs}->{redeemCrumbs}->{$strName}->{items};
       my @arrItems = split('\\|', $strItems);
       my @arrExisting = @{$objClient->{inventory}};
       if (is_LsubsetR([\@arrItems, \@arrExisting])) {
           return $objClient->sendError(20721);
       }
       $objClient->sendXT(['rsgc', '-1', 'GOLDEN', $strItems]);  
       foreach (@arrItems) {
                $objClient->addItem($_);
       }
}

method handleGaming($strData, $objClient) {}

method generateRoom {
       my @arrRooms = keys %{$self->{modules}->{crumbs}->{roomCrumbs}};
       my $intRoom = $arrRooms[rand(@arrRooms)];
       return $intRoom;
}

1;