use strict;
use warnings;

package Mysql;

use Method::Signatures;
use DBI;

method new {
       my $obj = bless {}, $self;
       return $obj;
}

method createMysql($strHost, $strDB, $strName, $strPass) {
       my $resMysql = DBI->connect("DBI:mysqlPP:database=$strDB;host=$strHost", $strName, $strPass);
       $self->{mysql} = $resMysql;
}

method execQuery($strSQL) {
       my $objState = $self->{mysql}->prepare($strSQL); 
       $objState->execute();
       return $objState;
}

method fetchColumns($strSQL) {
       my $strQuery = $self->execQuery($strSQL);
       my $arrResult = $strQuery->fetchrow_hashref();
       return $arrResult;
}

method countRows($strSQL) {
       my $strQuery = $self->execQuery($strSQL);
       my $arrResult = $strQuery->fetchall_arrayref(0);
       my $intCount = scalar (@{$arrResult});
       return $intCount;
}

method updateTable($resTable, $resSetCol, $resSetVal, $resWhereCol, $resWhereVal) {
       return if (!defined($resTable) && !defined($resSetCol) && !defined($resSetVal) && !defined($resWhereCol) && !defined($resWhereVal));
       my $strQuery = $self->execQuery("UPDATE $resTable SET `$resSetCol` = '$resSetVal' WHERE `$resWhereCol` = '$resWhereVal'");
       return $strQuery;
}

1;