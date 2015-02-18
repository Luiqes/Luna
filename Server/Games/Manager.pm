use strict;
use warnings;

package Manager;

use Method::Signatures;

use Core::CardJitsu;
use Core::FindFour;
use Core::Sled;
use Core::Mancala;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       $obj->{types} = {
               jitsu => CardJitsu->new($obj->{child}),
               findf => FindFour->new($obj->{child}),
               sled => Sled->new($obj->{child}),
               mcla => Mancala->new($obj->{child})
       };
       return $obj;
}

1;