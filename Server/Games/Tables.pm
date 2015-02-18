use strict;
use warnings;

package Tables;

use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       $obj->{tables} = ();
       return $obj;
}

method getTableClientCount($intTable) {
       my $intCount = 0;
       while (my ($intKey, $objClient) = each(%{$self->{tables}->{$intTable}->{clients}})) {
              if (exists($self->{tables}->{$intTable}->{clients}->{$intKey}) && $objClient->{property}->{games}->{tableID} eq $intTable) {	
                  $intCount++;
              } 
       }
       return $intCount;
}

method getTable($intTable) {
       if (!exists($self->{tables}->{$intTable})) {
           $self->{tables}->{$intTable} = {clients => {}, max => 2};
       }
       my $strTable = $self->{tables}->{$intTable};
       return $strTable;
}
	
method joinTable($intTable, $objClient) { 
       return if (!exists($self->{tables}->{$intTable}));
       if ($self->getTableClientCount($intTable) >= $self->{tables}->{$tableID}->{max}) {
           return $objClient->sendError(211);
       }
       %{$self->{tables}->{$intTable}->{clients}} = $objClient;
       my $intCount = $self->getTableCount($intTable);
       return $intCount;
}
	
method resetTable($intTable) {
       return if (!exists($self->{tables}->{$intTable}));
       delete($self->{tables}->{$intTable});
       $self->getTable($intTable);
}

1;