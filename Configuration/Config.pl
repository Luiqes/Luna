use strict;
use warnings;

our $loginConfig = {
    servPort => 6112,
    servType => 'login',
    debugging => 1
};

our $gameConfig = {
    servHost => '127.0.0.1',
    servName => 'Alpine',
    servPort => 6113,
    servType => 'game',
    debugging => 1,
    userPrefix => '!',
    staffPrefix => '#'
};

our $redeemConfig = {
    servPort => 6114,
    servType => 'redem',
    debugging => 1
};

our $dbConfig = {
    dbHost => '127.0.0.1',
    dbName => 'Luna',
    dbUser => 'root',
    dbPass => '1337hax',
    tables => {
         main => 'users',
         redeem => 'redemption',
         stamp => 'stamps',
         mail => 'postcards',
         puffle => 'puffles',
         igloo => 'igloos'
    }
};