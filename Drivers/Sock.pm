use strict;
use warnings;

package Base;

use Method::Signatures;
use IO::Socket;
use IO::Select;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       %{$obj->{clients}} = ();
       $obj->{jobStamp} = 0;
       return $obj;
}

method createSocket(Int $intPort) {
       $self->{socket} = IO::Socket::INET->new(LocalAddr => 0, LocalPort => $intPort, Proto => 0, Listen => SOMAXCONN, ReuseAddr => 1, Blocking => 0);
       $self->{listener} = IO::Select->new($self->{socket});
}

method serverLoop {
       my @arrSocks = $self->{listener}->can_read(0);
       foreach my $resSock (@arrSocks) {
          if ($resSock == $self->{socket}) {
              $self->addClient();
              next;
          }
          eval {
             my $objClient = $self->getClientBySock($resSock);              
             my $strBuffer;
             $resSock->sysread($strBuffer, 65536);
             my @arrData = split(chr(0), $strBuffer);
             foreach my $strData (@arrData) {                         
				           $self->handleData($strData, $objClient);    
             }
          };
          if ($@) {
              $self->{child}->{modules}->{logger}->output('Error: ' . $@, Logger::LEVELS->{err});
          }
      }
      $self->runCrons();
}

method runCrons {
       my $intTime = time();
       my $intStamp = $intTime + 150;
       if (!$self->{jobStamp}) {
           $self->{jobStamp} = $intStamp;
       } elsif ($intTime > $self->{jobStamp}) {
			       $self->updateServPop();
			       $self->{jobStamp} = $intStamp;
       }
}

method updateServPop {
       if ($self->{child}->{servConfig}->{servType} eq 'game') {
           my $strName = $self->{child}->{servConfig}->{servName};
           my $intPop = scalar(keys %{$self->{clients}});
           $self->{child}->{modules}->{mysql}->updateTable('servers', 'servName', $strName, 'curPop', $intPop);
           $self->{child}->{modules}->{logger}->output('Server: ' . $strName . '|Population: ' . $intPop, Logger::LEVELS->{inf});
       }
}

method getClientBySock($resSock) {
       foreach my $objClient (values %{$self->{clients}}) {
          if ($objClient->{sock} == $resSock) {
              return $objClient;
          }
       }
       return;
}

method addClient {
       my $resSocket = $self->{socket}->accept();
       $self->{listener}->add($resSocket);
       my $objClient = CPUser->new($self->{child}, $resSocket);
       my $intKey = fileno($resSocket);
       my $strIP = $self->getClientIPAddr($resSocket);
       $self->{clients}->{$intKey} = $objClient;
       $objClient->{property}->{personal}->{ipAddr} = $strIP;
       $self->{child}->{iplog}->{$strIP} = ($self->{child}->{iplog}->{$strIP}) ? $self->{child}->{iplog}->{$strIP} +1 : 1;
       if (exists($self->{child}->{iplog}->{$strIP}) && $self->{child}->{iplog}->{$strIP} > 3) {
           return $self->removeClientBySock($resSocket);
       } 
}

method handleData(Str $strData, $objClient) {
       if ($self->{child}->{servConfig}->{debugging}) {
           $self->{child}->{modules}->{logger}->output('Packet Received: ' . $strData, Logger::LEVELS->{dbg});
       }
       my $chrType = substr($strData, 0, 1);
       my $blnXML = $chrType eq '<' ? 1 : 0;
       my $blnXT = $chrType eq '%' ? 1 : 0;
       return if (!$blnXML && !$blnXT);
       $blnXML ? $self->{child}->handleXMLData($strData, $objClient) : $self->{child}->handleXTData($strData, $objClient);
}

method removeClientBySock($resSocket) {
       while (my ($intIndex, $objClient) = each(%{$self->{clients}})) {
              if ($objClient->{sock} == $resSocket) {
                  $self->{listener}->remove($resSocket);
                  $resSocket->close();
                  delete($self->{child}->{iplog}->{$objClient->{property}->{personal}->{ipAddr}});
                  delete($self->{clients}->{$intIndex});
              }
       }
}

method getClientIPAddr($resSock) {
       my $strAddr = $resSock->peeraddr;
       my $strIP = inet_ntoa($strAddr);
       return $strIP;
}

1;