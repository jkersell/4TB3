unit parser;

interface
    uses scanner;

    type Contents = string[255];
    type Node = record
        child : ^node;
        next : ^node;
        content : Contents; end;

    procedure Parse;

implementation
    type State = (Outside, ParseTable, ParseRow, ParseCell);

    var parseState : State;
    var error : boolean;

    procedure Parse;
    begin
        error := false;
        GetSym;
        parseState := Outside;

        while (not(sym = EofSym)) and (not error) do
        begin
            GetSym;
        end;
    end;

begin
end.
