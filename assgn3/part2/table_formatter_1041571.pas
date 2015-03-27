program table_formatter_1041571;
uses parser;

var
    currentTable : nodePtr;

procedure printCell(currentCell : nodePtr);
var
    content : string;
    i : integer;
begin
    content := currentCell^.content;
    write(content);
    for i := length(content) to cellWidth do write('_');
    write(' | ');
end;

procedure printRow(currentRow : nodePtr);
var
    nextCell : nodePtr;
begin
    nextCell := currentRow^.child;
    write('| ');
    repeat
        printCell(nextCell);
        nextCell := nextCell^.next;
    until (nextCell = nil);
    writeln;
end;

procedure printTable(currentTable : nodePtr);
var
    nextRow : nodePtr;
begin
    nextRow := currentTable^.child;
    repeat
        printRow(nextRow);
        nextRow := nextRow^.next;
    until (nextRow = nil);
end;


begin
    Parse;
    printTable(parseTree.root^.child);
end.
