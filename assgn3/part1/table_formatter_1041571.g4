grammar table_formatter_1041571;

r
locals [
    int columnIndex = 0,
    int rowIndex = 0,
    int maxColumns = 0,
    int cellWidth = 0,
    List<List <String>> cells = new ArrayList<List <String>>()
] : table;

table : TableStartTag row* TableEndTag {
    System.out.println("found a table");

    // Print the table
    for (List <String> row : $r::cells) {
        for (int i = 0; i < $r::maxColumns; ++i) {
            boolean cellHasText = i < row.size();
            System.out.print(" | " + (cellHasText ? row.get(i) : ""));
            for (int j = cellHasText ? row.get(i).length() : 0; j < $r::cellWidth; ++j) {
                System.out.print("_");
            }
        }
        System.out.println(" |");
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

    String contents = new String($String.text).trim();
    int stringWidth = contents.length();
    int column = $r::columnIndex;
    int row = $r::rowIndex;

    if (stringWidth > $r::cellWidth) {
        $r::cellWidth = stringWidth;
    }

    if (column == 0) {
        $r::cells.add(new ArrayList<String>());
    }

    $r::cells.get(row).add(contents);

    $r::columnIndex++;

    if ($r::columnIndex > $r::maxColumns) {
        $r::maxColumns = $r::columnIndex;
    }
};

TableStartTag : '<TABLE>';
TableEndTag   : '</TABLE>';
RowStartTag   : '<TR>';
RowEndTag     : '</TR>';
CellStartTag  : '<TD>';
CellEndTag    : '</TD>';
String        : STRING+;

WS : [\t\r\n]+ -> skip ;

fragment STRING : ~[<\r\n];
