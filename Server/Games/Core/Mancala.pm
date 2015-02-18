use strict;
use warnings;

package Mancala;

use Method::Signatures;

method new($resParent) {
       my $obj = bless {}, $self;
       $obj->{parent} = $resParent;
       return $obj;
}

1;