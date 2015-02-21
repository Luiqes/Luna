use strict;
use warnings;

package ClubPenguin;

use Method::Signatures;
use Digest::SHA qw(sha256_hex);
use Math::Round qw(round);
use File::Basename;
use List::Compare qw(is_LsubsetR);
use JSON qw(decode_json);
use Cwd;

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
                  s => 'handleStandard',
                  red => 'handleRedemption',
	                 z => 'handleGaming'
               },
               redemption => {
                          rjs => 'handleRedemptionJoinServer',
                          rgbq => 'handleRedemptionBookQuestion',
                          rsba => 'handleRedemptionSendBookAnswer',
                          rsc => 'handleRedemptionSendCode',
                          rsgc => 'handleRedemptionSendGoldenCode'     
               }
       };
       %{$obj->{igloos}} = ();
       $obj->{systems} = ();
       %{$obj->{plugins}} = ();
       return $obj;
}

method initializeSource {
       $self->createHeader();
       $self->loadModules();
       $self->{modules}->{crumbs}->updateCrumbs();
       $self->{modules}->{crumbs}->loadCrumbs();
       $self->loadSystems();
       $self->initiateMysql();
       $self->loadPlugins();
       $self->createServer();
       $self->initiateServers();
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
                 logger => Logger->new(),
                 mysql => Mysql->new(),
                 base => Base->new($self),
                 crypt => Crypt->new(),
                 tools => Tools->new(),
                 crumbs => Crumbs->new($self),
                 pbase => PluginBase->new($self)
       };
       # Dont uncomment until further notice
       #$self->{gaming} = {
                  #manager => Manager->new($self),
                  #tables => Tables->new($self),
                  #game => Gaming->new($self)
       #};
}

method loadSystems {
       my @arrUrls = ();
       my $resSystems = 'file://' . cwd() . '/Server/Centre/Systems.json';      
       push(@arrUrls, $resSystems);
       my $arrInfo = $self->{modules}->{tools}->asyncGetContent(\@arrUrls);
       while (my ($strFName, $arrData) = each(%{$arrInfo})) {
              my $arrSystems = decode_json($arrData);
              foreach my $strSystem (sort keys %{$arrSystems}) {
                 %{$self->{systems}->{$strSystem}} = (package => $arrSystems->{$strSystem}->{class}->new($self), method => $arrSystems->{$strSystem}->{handler});
              }
       }
       if (scalar(keys %{$self->{systems}}) > 0) {
           $self->{modules}->{logger}->output('Successfully Loaded ' . scalar(keys %{$self->{systems}}) . ' Systems', Logger::LEVELS->{inf}); 
       } else {
           $self->{modules}->{logger}->output('Failed To Load Any Systems', Logger::LEVELS->{err}); 
       }
}

method loadPlugins {       
       my @arrFiles = glob('Server/Plugins/*.pm');
       foreach my $strFile (@arrFiles) {
          my $strClass = basename($strFile, '.pm');
          if ($strClass ne 'CmdHandlers') {
              my $objPlugin = $strClass->new($self);
              $self->{plugins}->{$strClass} = $objPlugin;
          }
       }
       foreach my $objPlugin (values %{$self->{plugins}}) {
          if ($objPlugin->{isEnabled}) {
              $objPlugin->handleInitialization();
          }
       }
       if (scalar(keys %{$self->{plugins}}) > 0) {
           $self->{modules}->{logger}->output('Successfully Loaded ' . scalar(keys %{$self->{plugins}}) . ' Plugins', Logger::LEVELS->{inf}); 
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
           my $arrInfo = $self->{modules}->{mysql}->countRows("SELECT `servPort` FROM servers WHERE `servPort` = '$self->{servConfig}->{servPort}'");
           if ($arrInfo <= 0) {
               $self->{modules}->{mysql}->execQuery("INSERT INTO servers (`servPort`, `servName`, `servIP`) VALUES ('" . $self->{servConfig}->{servPort} . "', '" . $self->{servConfig}->{servName} . "', '" . $self->{servConfig}->{servHost} . "')");       
           }
       }
}

method initiateServers {
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
       return if (index($strData, '%') != -1);
       if ($strData eq '<policy-file-request/>') {
	          return $self->handleCrossDomainPolicy($objClient);
       }
       my $strXML = $self->{modules}->{tools}->parseXML($strData);
       return  if (!$strXML);
       my $strAct = $strXML->{body}->{action};
       return if (!exists($self->{handlers}->{xml}->{$strAct}));
       my $strHandler = $self->{handlers}->{xml}->{$strAct};
       return if (!defined(&{$strHandler}));
       $self->$strHandler($strXML, $strData, $objClient);
       $self->handleCustomPlugins('xml', $strData, $objClient);
}

method handleCrossDomainPolicy($objClient) {
       $objClient->write("<cross-domain-policy><allow-access-from domain='*' to-ports='*'/></cross-domain-policy>");
}

method handleVerChk($strXML, $strData, $objClient) {
       $objClient->write("<msg t='sys'><body action='apiOK' r='0'></body></msg>");
}

method handleRndK($strXML, $strData, $objClient) {
       $objClient->{property}->{personal}->{loginKey} = $self->{modules}->{crypt}->generateKey();
       $objClient->write("<msg t='sys'><body action='rndK' r='-1'><k>" . $objClient->{property}->{personal}->{loginKey} . "</k></body></msg>");
}

method handleLogin($strXML, $strData, $objClient) {     
       my $strName = $strXML->{body}->{login}->{nick};
       my $strPass = $strXML->{body}->{login}->{pword};     
       $self->checkBeforeLogin($strName, $strPass, $objClient);
}

method checkBeforeLogin($strName, $strPass, $objClient) {
       my $intNames = $self->{modules}->{mysql}->countRows("SELECT `username` FROM $self->{dbConfig}->{tables}->{main} WHERE `username` = '$strName'");
       my $arrInfo = $self->{modules}->{mysql}->fetchColumns("SELECT * FROM $self->{dbConfig}->{tables}->{main} WHERE `username` = '$strName'");
       my $strHash = $self->generateHash($strPass, $arrInfo, $objClient);      

       return if (!$arrInfo);

       if ($intNames <= 0) {
           $objClient->sendError(100);
           return $self->{modules}->{base}->removeClientBySock($objClient->{sock});
       } elsif ($strPass ne $strHash) {
           $objClient->sendError(101);	
           return $self->{modules}->{base}->removeClientBySock($objClient->{sock});
       } elsif (!$arrInfo->{active})  {
           $objClient->sendError(900);
           return $self->{modules}->{base}->removeClientBySock($objClient->{sock});
       } elsif ($arrInfo->{isBanned} eq 'PERM') {
           $objClient->sendError(603);	
           return $self->{modules}->{base}->removeClientBySock($objClient->{sock});
       } elsif ($arrInfo->{isBanned} <= time()) {
           my $intTime = round(($arrInfo->{isBanned} - time()) / 3600);
           $objClient->sendError(601 . '%' . $intTime);	
           return $self->{modules}->{base}->removeClientBySock($objClient->{sock});
       }

       $self->continueLogin($strName, $arrInfo, $objClient);
} 

method generateHash($strPass, $arrInfo, $objClient) {
       my $strLoginKey = $objClient->{property}->{personal}->{loginKey};
       my $strLoginHash = $self->{modules}->{crypt}->encryptPass(uc($arrInfo->{password}), $strLoginKey);                            
       my $strGameHash = $self->{modules}->{crypt}->swapSHA(sha256_hex($arrInfo->{loginKey} . $strLoginKey)) . $arrInfo->{loginKey};
       my $strType = $self->{servConfig}->{servType};
       my $strHash = $strType eq 'login' ? $strLoginHash : $strGameHash;
       return $strHash;
}

method continueLogin($strName, $arrInfo, $objClient) {
       if ($self->{servConfig}->{servType} eq 'login') {
           $objClient->write('%xt%gs%-1%' . $self->generateServerList() . '%');  
           $objClient->write('%xt%l%-1%' . $arrInfo->{ID} . '%' . $self->{modules}->{crypt}->reverseSHA($objClient->{property}->{personal}->{loginKey}) . '%0%');
           $objClient->updateKey($self->{modules}->{crypt}->reverseSHA($objClient->{property}->{personal}->{loginKey}), $strName);
       } else {
           $objClient->{property}->{personal}->{userID} = $arrInfo->{ID};
           $objClient->updateIP($objClient->{property}->{personal}->{ipAddr});
           $objClient->loadDetails();
           $objClient->sendXT('l', '-1');
           $objClient->handleBuddyOnline();
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
       return if (index($strData, '|') != -1);
       my @arrData = split('%', $strData);
       my $chrXT = $arrData[2];
       return if (!exists($self->{handlers}->{xt}->{$chrXT}));
       my $strHandler = $self->{handlers}->{xt}->{$chrXT};
       return if (!defined(&{$strHandler}));
       return defined($objClient->{property}->{personal}->{username}) ? $self->$strHandler($strData, $objClient) : $self->{modules}->{base}->removeClientBySock($objClient->{sock});
}

method handleStandard($strData, $objClient) {
       my @arrXT = split('%', $strData);
       my @arrStd = split('#', $arrXT[3]);
       my $chrStd = $arrStd[0];
       return if (!exists($self->{systems}->{$chrStd}));
       my $objClass = $self->{systems}->{$chrStd}->{package};
       my $strHandler = $self->{systems}->{$chrStd}->{method};
       $objClass->$strHandler($strData, $objClient);
       $self->handleCustomPlugins('xt', $strData, $objClient);
}

method handleRedemption($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       return if (!exists($self->{handlers}->{redemption}->{$strCmd}));
       my $strHandler = $self->{handlers}->{redemption}->{$strCmd};
       return if (!defined(&{$strHandler}));
       $self->$strHandler(\@arrData, $objClient);
}

method handleRedemptionJoinServer(\@arrData, $objClient) {
       my @arrValues = ();
       for my $intVal (1..16) {
         push(@arrValues, $intVal);
       }
       my $intStr = join(',', @arrValues);
       $objClient->sendXT('rjs', $arrData[4], $intStr, 0);	             
}

method handleRedemptionBookQuestion(\@arrData, $objClient) {
       my $intPage = $self->{modules}->{crypt}->generateInt(1, 80);
       my $intLine = $self->{modules}->{crypt}->generateInt(1, 50);
       my $intWord = $self->{modules}->{crypt}->generateInt(1, 25);
       $objClient->sendXT('rgbq', $arrData[4], $arrData[5], $intPage, $intLine, $intWord);
}

method handleRedemptionSendBookAnswer(\@arrData, $objClient) {
       my $intCoins = $arrData[5];
       $objClient->sendXT('rsba', $arrData[4] , $intCoins);
       $objClient->updateCoins($objClient->{property}->{personal}->{coins} + $intCoins);		
}

method handleRedemptionSendCode(\@arrData, $objClient) {
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
       $objClient->sendXT('rsc', $arrData[4], 'CAMPAIGN', $strItems, $intCoins);  
       foreach my $intItem (@arrItems) {
          $objClient->addItem($intItem);
          $objClient->updateCoins($objClient->{property}->{personal}->{coins} - $intCoins);
       }
}

method handleRedemptionSendGoldenCode(\@arrData, $objClient) {
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
       $objClient->sendXT('rsgc', $arrData[4], 'GOLDEN', $strItems);  
       foreach my $intItem (@arrItems) {
          $objClient->addItem($intItem);
       }
}

method handleGaming($strData, $objClient) {
       # Don't uncomment until further notice
       #$self->{gaming}->{game}->handleData($strData, $objClient);
}

method generateRoom {
       my @arrRooms = keys(%{$self->{modules}->{crumbs}->{roomCrumbs}});
       my $intRoom = $arrRooms[rand(@arrRooms)];
       return $intRoom;
}

1;