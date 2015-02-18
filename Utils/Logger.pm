use strict;
use warnings;

package Logger;

use Method::Signatures;
use feature qw(say);
use POSIX qw(strftime);

use constant LEVELS => {
    err => 'error',
    inf => 'info',
    wrn => 'warn',
    dbg => 'debug',
    ntc => 'notice'
};

method new {
       my $obj = bless {}, $self;
       return $obj;
}

method output($strMsg, $strType) {
       my $strTime = strftime('%I:%M:%S[%p]', localtime());
       say '[' . $strTime . ']' . '[' . uc($strType) . '] =>> ' . $strMsg;
}

method kill($strMsg, $strType) {
       $self->output($strMsg, $strType);
       exit;
}

1;