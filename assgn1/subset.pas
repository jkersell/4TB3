program subsetConstructioni;
uses strutils;
type
    transition = record
        fromState, toState: Byte;
        symbol: char;
    end;

    automaton = record
        Q: set of Byte;
        R: array [0..255] of transition;
        initState: Byte;
        F: set of Byte;
    end;

var
    nonDet, det: automaton;
    wordDelim: set of char;
    line, nextWord: string;
    i, lineNumber, numWords: integer;

begin
    wordDelim := [' '];
    lineNumber := 0;
    while not eof do
    begin
        readln(line);
        numWords := wordCount(line, wordDelim);

        {validate file format}
        if lineNumber = 0 then
        begin
            if numWords <> 1 then
            begin
                writeln('There should only be one state on the first line.');
                exit;
            end;
        end
        else if lineNumber > 1 then
            if numWords <> 3 then
            begin
                writeln('Lines 3 and up must have format: <state> <symbol> <state>');
                exit;
            end;
        lineNumber := lineNumber + 1;

        for i := 0 to numWords do
        begin
            nextWord := extractWord(i, line, wordDelim);
        end;
    end;
end.

