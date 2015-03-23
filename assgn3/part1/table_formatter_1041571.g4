grammar table_formatter_1041571;

r
locals [
    int columnIndex = 0,
    int rowIndex = 0,
    List<Integer> colWidths = new ArrayList<Integer>(),
    List<List <String>> cells = new ArrayList<List <String>>()
] : table;

table : TableStartTag row* TableEndTag {
    System.out.println("found a table");

    // Print the table
    for (List <String> row : $r::cells) {
        for (int i = 0; i < row.size(); ++i) {
            System.out.print("| " + row.get(i));
        }
    }
};

row : RowStartTag cell* RowEndTag {
    System.out.println("found a row");

    if ($r::cells.size() <= $r::rowIndex) {
        // Create new row
        $r::cells.add(new ArrayList<String>());
    }

    // Update position
    $r::rowIndex++;
    $r::columnIndex = 0;
};

cell : CellStartTag String CellEndTag {
    System.out.println("found a cell");

    int stringWidth = $String.text.length();
    int column = $r::columnIndex;
    int row = $r::rowIndex;

    if ($r::colWidths.size() <= column) {
        // Add new column width
        $r::colWidths.add(stringWidth);
    } else if (stringWidth > $r::colWidths.get(column)) {
        $r::colWidths.set(column, stringWidth);
    }

    if (column == 0) {
        $r::cells.add(new ArrayList<String>());
    }

    $r::cells.get(row).add($String.text);

    $r::columnIndex++;
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