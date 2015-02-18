use strict;
use warnings;

package Crumbs;

use Method::Signatures;
use Scalar::Util qw(reftype);
use JSON qw(decode_json);
use Cwd;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       $obj->{jsons} =  {
               items => 'paper_items.json',
               igloos => 'igloos.json',
               floors => 'igloo_floors.json',
               furns => 'furniture_items.json',
               rooms => 'rooms.json',
               stamps => 'stamps.json',
               pcards => 'postcards.json',
               jcards => 'jitsu_cards.json',
               redeem => 'redeem.json'
       };  
       $obj->{methods} = {
               paper_items => 'loadItems',
               igloos => 'loadIgloos',
               igloo_floors => 'loadFloors',
               furniture_items => 'loadFurnitures',
               rooms => 'loadRooms',
               stamps => 'loadStamps',
               postcards => 'loadPostcards',
               jitsu_cards => 'loadJitsuCards',
               redeem => 'loadRedemptions'
       };
       $obj->{directory} = 'file://' . cwd() . '/Misc/JSON/';
       return $obj;
}

method updateCrumbs {
       my $strDir = 'Misc/JSON/';
       my @arrUrls = ();
       while (my ($strKey, $strFile) = each(%{$self->{jsons}})) {
              if ($strKey ne 'pcards' && $strKey ne 'jcards' && $strKey ne 'redeem') {
                  my $strLink = 'http://media1.clubpenguin.com/play/en/web_service/game_configs/';
                  my $strUrl = $strLink . $strFile;
                  push(@arrUrls, $strUrl);
              }
       }
       $self->{child}->{modules}->{tools}->asyncDownload($strDir, \@arrUrls);
       $self->{child}->{modules}->{logger}->output('Successfully Updated Crumbs', Logger::LEVELS->{inf});
}

method loadCrumbs {
       my @arrFiles = ();
       foreach my $strUrl (values %{$self->{jsons}}) {
          my $strFile = $self->{directory} . $strUrl;
          push(@arrFiles, $strFile);
       }
       my $arrInfo = $self->{child}->{modules}->{tools}->asyncGetContent(\@arrFiles);
       while (my ($strKey, $arrData) = each(%{$arrInfo})) {
              if (exists($self->{methods}->{$strKey})) {
                  my $strMethod = $self->{methods}->{$strKey};
                  if (defined(&{$strMethod})) {
                      $self->$strMethod(decode_json($arrData));
                  }
              }
       }
}

method loadItems($arrItems) {
       foreach my $strItem (sort @{$arrItems}) {
          %{$self->{itemCrumbs}->{$strItem->{paper_item_id}}} = (cost => $strItem->{cost}, type => $strItem->{type}, isBait => $strItem->{is_bait});
       }
       $self->{child}->{modules}->{logger}->output('Successfully Loaded ' . scalar(keys %{$self->{itemCrumbs}}) . ' Items', Logger::LEVELS->{inf});
}

method loadStamps($arrStamps) {
       foreach my $arrIndexStamps (sort @{$arrStamps}) {
          foreach my $arrIndexTwoStamps (sort %{$arrIndexStamps}) {
             if (reftype($arrIndexTwoStamps)) {
                 foreach my $strStamp (sort @{$arrIndexTwoStamps}) {
                    %{$self->{stampCrumbs}->{$strStamp->{stamp_id}}} = (rank => $strStamp->{rank});
				            }	
			         }
	         }
       }
       $self->{child}->{modules}->{logger}->output('Successfully Loaded ' . scalar(keys %{$self->{stampCrumbs}}) . ' Stamps', Logger::LEVELS->{inf});
}

method loadIgloos($arrIgloos) {
       foreach my $strIgloo (sort keys %{$arrIgloos}) {
          %{$self->{iglooCrumbs}->{$arrIgloos->{$strIgloo}->{igloo_id}}} = (cost => $arrIgloos->{$strIgloo}->{cost});    
       }
       $self->{child}->{modules}->{logger}->output('Successfully Loaded ' . scalar(keys %{$self->{iglooCrumbs}}) . ' Igloos', Logger::LEVELS->{inf});
}

method loadFloors($arrFloors) {
       foreach my $strFloor (sort @{$arrFloors}) {
          %{$self->{floorCrumbs}->{$strFloor->{igloo_floor_id}}} = (cost => $strFloor->{cost});
       }
       $self->{child}->{modules}->{logger}->output('Successfully Loaded ' . scalar(keys %{$self->{floorCrumbs}}) . ' Floors', Logger::LEVELS->{inf});
}

method loadFurnitures($arrFurns) {
       foreach my $strFurn (sort @{$arrFurns}) {
          %{$self->{furnitureCrumbs}->{$strFurn->{furniture_item_id}}} = (cost => $strFurn->{cost});
       }
       $self->{child}->{modules}->{logger}->output('Successfully Loaded ' . scalar(keys %{$self->{furnitureCrumbs}}) . ' Furnitures', Logger::LEVELS->{inf});
}

method loadRooms($arrRooms) {
       foreach my $strRoom (sort keys %{$arrRooms}) {
          my $intRoom = $arrRooms->{$strRoom}->{room_id};
          my $intLimit = $arrRooms->{$strRoom}->{max_users};
          if ($intRoom <= 899) {
	             %{$self->{roomCrumbs}->{$intRoom}} = (limit => $intLimit);
          }
       }
       $self->{child}->{modules}->{logger}->output('Successfully Loaded ' . scalar(keys %{$self->{roomCrumbs}}) . ' Rooms', Logger::LEVELS->{inf});
}

method loadPostcards($arrPostcards) {
       while (my ($intCardID, $intCardCost) = each(%{$arrPostcards})) {
              %{$self->{mailCrumbs}->{$intCardID}}  = (cost => $intCardCost);
       }
       $self->{child}->{modules}->{logger}->output('Successfully Loaded ' . scalar(keys %{$self->{mailCrumbs}}) . ' Postcards', Logger::LEVELS->{inf});
}

method loadJitsuCards($arrCards) {
       foreach my $strCard (sort keys %{$arrCards}) {
          %{$self->{jitsuCrumbs}->{$arrCards->{$strCard}->{id}}} = (power => $arrCards->{$strCard}->{power}, destruction => $arrCards->{$strCard}->{damage}, attribute => $arrCards->{$strCard}->{attribute}, colour => $arrCards->{$strCard}->{color});                                                    
       }
       $self->{child}->{modules}->{logger}->output('Successfully Loaded ' . scalar(keys %{$self->{jitsuCrumbs}}) . ' Jitsu Cards', Logger::LEVELS->{inf});
}

method loadRedemptions($arrRedemptions) {
       foreach my $strRedemption (sort keys %{$arrRedemptions}) {
          %{$self->{redeemCrumbs}->{$arrRedemptions->{$strRedemption}->{redeemName}}} = (type => $arrRedemptions->{$strRedemption}->{redeemType}, items => $arrRedemptions->{$strRedemption}->{redeemItems}, cost => $arrRedemptions->{$strRedemption}->{redeemCoins});
       }
       $self->{child}->{modules}->{logger}->output('Successfully Loaded ' . scalar(keys %{$self->{redeemCrumbs}}) . ' Redemptions', Logger::LEVELS->{inf}); 
}

1;