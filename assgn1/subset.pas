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
    i: integer;

begin
    wordDelim := [' '];
    readln(line);
    for i := 0 to wordCount(line, wordDelim) do
    begin
        nextWord := extractWord(i, line, wordDelim);
    end;
end.

