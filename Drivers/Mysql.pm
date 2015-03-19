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
       $self->{mysql} = DBI->connect("DBI:mysql:database=$strDB;host=$strHost", $strName, $strPass);
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

method insertData($table, \@columns, \@values) {
       my $fields = join("`, `", @columns);
       my $statement = $self->{mysql}->prepare("INSERT INTO $table ($fields) VALUES " . join(", ", ("(?, ?, ?)") x scalar(@columns));
       $statement->execute(@values);
       return $statement->{mysql_insertid};
}

method deleteData(Defined $table, Defined $where, Defined $whereValue, $andKey, $andValue, $andClause = 0) {
       return $andClause ? $self->execQuery("DELETE FROM $table WHERE `$where` = '$whereValue' AND `$andKey` = '$andValue'") : $self->execQuery("DELETE FROM $table WHERE `$where` = '$whereValue'");
}

1;