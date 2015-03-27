unit parser;

interface
    uses scanner;

    type Contents = string[255];
    type Node = record
        child : ^Node;
        next : ^Node;
        content : Contents;
    end;
    type Tree = record
        root : ^Node;
    end;
    type nodePtr = ^Node;
    type treePtr = ^Tree;

    var parseTree : Tree;
    var cellWidth : integer;
    var rowWidth : integer;

    procedure Parse;

    function ConstructNode : nodePtr;
    function ConstructParseTree : treePtr;

implementation
    type State = (Outside, ParseTable, ParseRow, ParseCell);

    var parseState : State;
    var error : boolean;

    function ConstructNode : nodePtr;
    var
        newNode : nodePtr;
    begin
        New(newNode);
        newNode^.child := nil;
        newNode^.next := nil;
        newNode^.content := '';
        ConstructNode := newNode;
    end;

    function ConstructParseTree : treePtr;
    var
        newTree : treePtr;
    begin
        New(newTree);
        newTree^.root := ConstructNode;
        ConstructParseTree := newTree;
    end;

    procedure addChild(parent, node : nodePtr);
    var
        iter : nodePtr;
    begin
        if (parent = nil) or (node = nil) then
        begin
            writeln('Error: nil pointer passed to addChild.');
            error := true;
            exit;
        end;
        iter := parent^.child;
        if (iter = nil) then
            parent^.child := node
        else
        begin
            while (not(iter^.next = nil)) do
                iter := iter^.next;
            iter^.next := node;
        end;
    end;

    procedure parseError(msg : string);
    begin
        writeln('Parse error: ' + msg);
        error := true;
    end;

    procedure Parse;
    var
        currentTable : nodePtr;
        currentRow : nodePtr;
        currentCell : nodePtr;
        rowWidthCounter : integer;
    begin
        currentTable := nil;
        currentRow := nil;
        currentCell := nil;
        rowWidthCounter := 0;
        error := false;
        parseState := Outside;

        GetSym;
        while (not(sym = EofSym)) and (not error) do
        begin
            case sym of
            TableStartSym:
            begin
                writeln('TableStartSym');
                if (parseState = Outside) then
                begin
                    parseState := ParseTable;
                    currentTable := ConstructNode;
                    addChild(parseTree.root, currentTable);
                end
                else
                    parseError('Unexpected tag: <TABLE>');
            end;
            TableEndSym:
            begin
                writeln('TableEndSym');
                if (parseState = ParseTable) then
                    parseState := Outside
                else
                    parseError('Unexpected tag: </TABLE>');
            end;
            RowStartSym:
            begin
                writeln('RowStartSym');
                if (parseState = ParseTable) then
                begin
                    rowWidthCounter := 0;
                    parseState := ParseRow;
                    currentRow := ConstructNode;
                    addChild(currentTable, currentRow);
                end
                else
                    parseError('Unexpected tag: <TR>');
            end;
            RowEndSym:
            begin
                writeln('RowEndSym');
                if (parseState = ParseRow) then
                begin
                    if (rowWidthCounter > rowWidth) then
                        rowWidth := rowWidthCounter;
                    parseState := ParseTable;
                end
                else
                    parseError('Unexpected tag: </TR>');
            end;
            CellStartSym:
            begin
                writeln('CellStartSym');
                if (parseState = ParseRow) then
                begin
                    rowWidthCounter := rowWidthCounter + 1;
                    parseState := ParseCell;
                    currentCell := ConstructNode;
                    addChild(CurrentRow, CurrentCell);
                end
                else
                    parseError('Unexpected tag: <TD>');
            end;
            CellEndSym:
            begin
                writeln('CellEndSym');
                if (parseState = ParseCell) then
                    parseState := ParseRow
                else
                    parseError('Unexpected tag: </TD>');
            end;
            ContentsSym:
            begin
                writeln('ContentsSym');
                if (parseState = ParseCell) then
                    currentCell^.content := cont;
                if (length(cont) > cellWidth) then
                    cellWidth := length(cont) - 1;
            end;
            end;
            GetSym;
        end;
    end;

begin
    parseTree := ConstructParseTree^;
    cellWidth := 0;
    rowWidth := 0;
end.
