use strict;
use warnings;

package MailSystem;

use Method::Signatures;
use HTTP::Date qw(str2time);

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       %{$obj->{handlers}} = (
                 'l#mst' => 'handleMailStart',
                 'l#mg' =>	'handleMailGet',
                 'l#ms' =>	'handleMailSend',
                 'l#md'	=>	'handleMailDelete',
                 'l#mdp'	=>	'handleMailDeletePlayer',
                 'l#mc' =>	'handleMailChecked'
       );
       return $obj;
}

method handleMailSystem($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       return if (!exists($self->{handlers}->{$strCmd}));
       my $strHandler = $self->{handlers}->{$strCmd};
       return if (!defined(&{$strHandler}));
       $self->$strHandler(\@arrData, $objClient);
}

method handleMailStart(\@arrData, $objClient) {
       $self->loadMailFromDB($objClient);
       my $intCount = 0;
       foreach my $strMail (keys %{$objClient->{mails}}) {
          if (!$strMail->{hasRead}) {
              $intCount++;
          }
       }
       $objClient->sendXT(['mst', '-1', $intCount, scalar(keys %{$objClient->{mails}})]);
}

method handleMailGet(\@arrData, $objClient) {
       my $strMail = $self->fetchMailData($objClient);
       $objClient->write('%xt%mg%' . $arrData[4] . '%' . ($strMail ? $strMail : '%'));
}

method handleMailSend(\@arrData, $objClient) {
       my $intPID = $arrData[5];
       my $intCard = $arrData[6];
       my $strDetails = $arrData[7];
       return if (!exists($self->{child}->{modules}->{crumbs}->{mailCrumbs}->{$intCard}) && !int($intPID) && !int($intCard) && $intPID eq $objClient->{property}->{personal}->{userID});
       my @arrNewCard = ('fromID' => $objClient->{property}->{personal}->{userID}, 'fromName' => $objClient->{property}->{personal}->{username}, 'type' => $intCard, 'extra' => $strDetails, 'timestamp' => time());        
       $self->{child}->{modules}->{mysql}->execQuery("INSERT INTO $self->{child}->{dbConfig}->{tables}->{mail} (`toUser`, `fromID`, `fromName`, `cardType`, `details`) VALUES ('" . $intPID . "', '" . $arrNewCard[0] . "', '" . $arrNewCard[1] . "', '" . $arrNewCard[2] . "', '" . $arrNewCard[3] . "')");
       $objClient->setCoins($objClient->{property}->{personal}->{coins} - 10);
       $objClient->sendXT(['ms', '-1', $objClient->{property}->{personal}->{coins}]);
       my $objPlayer = $objClient->getClientByID($intPID);
       $objPlayer->{mails}->{$intCard}->{fromID} = $arrNewCard[0];
       $objPlayer->{mails}->{$intCard}->{fromName} = $arrNewCard[1];
       $objPlayer->{mails}->{$intCard}->{type} = $arrNewCard[2];
       $objPlayer->{mails}->{$intCard}->{extra} = $arrNewCard[3];
       $objPlayer->{mails}->{$intCard}->{timestamp} = $arrNewCard[4];
       $objPlayer->{mails}->{$intCard}->{hasRead} = 0;
       $objPlayer->sendXT(['mr', '-1', join('|', @arrNewCard), scalar(keys %{$objPlayer->{mails}})]);
}		  

method handleMailChecked(\@arrData, $objClient) {
       my $intCard = $arrData[5];
       return if (!int($intCard));
       $self->{child}->{modules}->{mysql}->updateTable($self->{child}->{dbConfig}->{tables}->{mail}, 'isRead', 1, 'cardType', $intCard);
       $objClient->sendXT(['mc', '-1', $intCard]);
}

method handleMailDeletePlayer(\@arrData, $objClient) {
       my $intPID = $arrData[5];
       return if (!int($intPID));
       foreach my $strCard (keys %{$objClient->{mails}}) {
          if ($strCard->{fromID} eq $intPID) {
              delete($objClient->{mails}->{$strCard->{type}});
          }
       } 
       $objClient->sendXT(['mdp', $arrData[4], $intPID]);
       $self->{child}->{modules}->{mysql}->execQuery("DELETE FROM $self->{child}->{dbConfig}->{tables}->{mail} WHERE `toUser` = '$intPID' AND `fromID` = '$objClient->{property}->{personal}->{userID}'");
}

method handleDeleteMail(\@arrData, $objClient) {
       my $intPID = $arrData[5];
       return if (!int($intPID));
       foreach my $strCard (keys %{$objClient->{mails}}) {
          if ($strCard->{type} eq $intPID) {
              delete($objClient->{mails}->{$strCard->{type}});
          }
       }
       $self->{child}->{modules}->{mysql}->execQuery("DELETE FROM $self->{child}->{dbConfig}->{tables}->{mail} WHERE `cardType` = '$intPID'");
       $objClient->sendXT(['md', '-1', $intPID]);
}

method fetchMailData($objClient) {
       if (scalar(keys %{$objClient->{mails}}) <= 0) {
           $self->loadMailFromDB();
       }
       my $strMail = '';
       my $intCards = scalar(keys %{$objClient->{mails}});
       for my $intCount (0..$intCards) {
         my @arrDetails = ($objClient->{mails}->{$intCount}->{fromName}, $objClient->{mails}->{$intCount}->{fromID}, $objClient->{mails}->{$intCount}->{type}, $objClient->{mails}->{$intCount}->{extra}, $objClient->{mails}->{$intCount}->{timestamp});
         $strMail .= join('|', @arrDetails) . '%';
       }
       return $strMail;
}


method loadMailFromDB($objClient) {
       my $arrInfo = $self->{child}->{modules}->{mysql}->fetchColumns("SELECT * from $self->{child}->{dbConfig}->{tables}->{mail} WHERE `toUser` = '$objClient->{property}->{personal}->{userID}'");    
       my $strName = $arrInfo->{fromName};
       my $intID = $arrInfo->{fromID};
       my $intCard = $arrInfo->{cardType};
       my $strDetails = $arrInfo->{details};
       my $intTime = str2time($arrInfo->{timestamp});
       my $blnRead = $arrInfo->{isRead};
       %{$objClient->{mails}->{$intCard}} = (fromName => $strName, fromID => $intID, type => $intCard, extra => $strDetails, timestamp => $intTime, hasRead => $blnRead);
}

1;