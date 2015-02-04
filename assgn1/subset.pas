program subsetConstructioni;

uses strutils, sysutils;

type
    transition = record
        fromState, toState: Byte;
        symbol: shortString;
    end;

    automaton = record
        Q: set of Byte;
        R: array [1..256] of transition;
        initState: Byte;
        F: set of Byte;
    end;

var
    nonDet, det: automaton;
    wordDelim: set of char;
    line, nextWord: string;
    i, lineNumber, numWords, numTransitions: integer;

function validateLine(lineNumber: integer; line: string): integer;
var
    numWords: integer;
begin
    numWords := wordCount(line, wordDelim);

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

    {return number of words in this line}
    validateLine := numWords;
end;

begin
    wordDelim := [' '];
    lineNumber := 0;
    numTransitions := 1;
    while not eof do
    begin
        readln(line);

        numWords := validateLine(lineNumber, line);

        for i := 1 to numWords do
        begin
            nextWord := extractWord(i, line, wordDelim);
            if lineNumber = 0 then
                nonDet.initState := strToInt(nextWord)
            else if lineNumber = 1 then
                include(nonDet.F, strToInt(nextWord))
            else if lineNumber > 1 then
                if i = 1 then
                    nonDet.R[numTransitions].fromState := strToInt(nextWord)
                else if i = 2 then
                    nonDet.R[numTransitions].symbol := nextWord
                else if i = 3 then
                    nonDet.R[numTransitions].toState := strToInt(nextWord);
        end;
        lineNumber := lineNumber + 1;
    end;
end.

