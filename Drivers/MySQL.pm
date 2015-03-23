package MySQL;

use strict;
use warnings;

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
       $objState->execute;
       return $objState;
}

method fetchColumns($strSQL) {
       my $strQuery = $self->execQuery($strSQL);
       my $arrResult = $strQuery->fetchrow_hashref;
       if ($arrResult) {
           return $arrResult;
       }
}

method countRows($strSQL) {
       my $strQuery = $self->execQuery($strSQL);
       my $arrResult = $strQuery->fetchall_arrayref(0);
       my $intCount = scalar(@{$arrResult});
       return $intCount;
}

method updateTable($table, $set, $setValue, $where, $whereValue) {
       return if (!$table) && !$set && !$setValue && !$where && !$whereValue);
       my $strQuery = $self->execQuery("UPDATE $table SET `$set` = '$setValue' WHERE `$where` = '$whereValue'");
       return $strQuery;
}

method insertData($table, \@columns, \@values) {
       return if (!$table && !scalar(@columns) && !scalar(@values));
       my $fields = join("`, `", @columns);
       my $statement = $self->{mysql}->prepare("INSERT INTO $table ($fields) VALUES " . join(", ", ("(?, ?, ?)") x scalar(@columns));
       $statement->execute(@values);
       return $statement->{mysql_insertid};
}

method deleteData($table, $where, $whereValue, $andKey, $andValue, $andClause = 0) {
       return if (!$table && !$where && !$whereValue);
       return $andClause ? $self->execQuery("DELETE FROM $table WHERE `$where` = '$whereValue' AND `$andKey` = '$andValue'") : $self->execQuery("DELETE FROM $table WHERE `$where` = '$whereValue'");
}

1;