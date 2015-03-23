grammar table_formatter_1041571;

r : table;

table : TableStartTag row* TableEndTag {
    System.out.println("found a table");
};

row : RowStartTag cell* RowEndTag {
    System.out.println("found a row");
};

cell : CellStartTag String CellEndTag {
    System.out.println("found a cell");
};

TableStartTag : '<TABLE>';
TableEndTag   : '</TABLE>';
RowStartTag   : '<TR>';
RowEndTag     : '</TR>';
CellStartTag  : '<TD>';
CellEndTag    : '</TD>';
String        : STRING+;

WS : [ \t\r\n ]+ -> skip ;

fragment STRING : ~[<\r\n];
