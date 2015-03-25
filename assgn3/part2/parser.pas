unit parser;

interface
    uses scanner;

    type Contents = string[255];
    type Node = record
        child : ^Node;
        next : ^Node;
        content : Contents; end;

    procedure Parse;

implementation
    type State = (Outside, ParseTable, ParseRow, ParseCell);
    type nodePtr = ^Node;

    var parseState : State;
    var error : boolean;

    function ConstructNode : nodePtr;
    var
        newNode : nodePtr;
    begin
        New(newNode);
        newNode^.child := nil;
        newNode^.next := nil;
        ConstructNode := newNode;
    end;

    procedure parseError(msg : string);
    begin
        writeln('Parse error: ' + msg);
        error := true;
    end;

    procedure Parse;
    begin
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
                    parseState := ParseTable
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
                    parseState := ParseRow
                else
                    parseError('Unexpected tag: <TR>');
            end;
            RowEndSym:
            begin
                writeln('RowEndSym');
                if (parseState = ParseRow) then
                    parseState := ParseTable
                else
                    parseError('Unexpected tag: </TR>');
            end;
            CellStartSym:
            begin
                writeln('CellStartSym');
                if (parseState = ParseRow) then
                    parseState := ParseCell
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
                    writeln('Cell contents');
            end;
            end;
            GetSym;
        end;
    end;

begin
end.
