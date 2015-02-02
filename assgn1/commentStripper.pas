program ReadFile;
type
    states = (start, slash, slashSlash, slashStar, slashStarStar, slashStarStarSlash, quote, quoteBackslash);
var
    inputFile: text;
    outputFile: text;
    filename, outputBuffer: string;
    c: char;
    currentState: states;

function transitionFunction(state: states; c: char): states;
begin
    transitionFunction := state;
    case state of
        start:
            begin
            writeln('State is start');
            if c = '/' then
                transitionFunction := slash
            else if c = '"' then
                transitionFunction := quote
            else
                ;
            end;
        slash:
            begin
            writeln('State is slash');
            if c = '/' then
                transitionFunction := slashSlash
            else if c = '*' then
                transitionFunction := slashStar
            else
                transitionFunction := start;
            end;
        slashSlash:
            begin
            writeln('State is slashSlash');
            {Only recognize unix style line endings.}
            if c = chr(10) then
                transitionFunction := start
            else
                ;{dump all characters until end of line}
            end;
        slashStar:
            begin
            writeln('State is slashStar');
            if c = '*' then
                transitionFunction := slashStarStar
            else
                ;{dump all characters until comment is ended}
            end;
        slashStarStar:
            begin
            writeln('State is slashStarStar');
            if c = '/' then
                transitionFunction := slashStarStarSlash
            else
                transitionFunction := slashStar;
            end;
        slashStarStarSlash:
            if c = '/' then
                transitionFunction := slash
            else if c = '"' then
                transitionFunction := quote
            else
                transitionFunction := start;
        quote:
            begin
            writeln('State is quote');
            if c = '\' then
                transitionFunction := quoteBackslash
            else if c = '"' then
                transitionFunction := start
            else
                ;
            end;
        quoteBackslash:
            begin
            writeln('State is quoteBackslash');
            transitionFunction := quote;
            end;
    end;
end;

procedure handleChar(state: states; c: char; outputBuffer: string);
begin
    case state of
        start:
            begin
            if outputBuffer <> '' then
                write(outputFile, outputBuffer);
            write(outputFile, c);
            end;
        slash:
            outputBuffer :=  outputBuffer + c;
        slashSlash, slashStar:
            outputBuffer := '';
        slashStarStar, slashStarStarSlash:
            ;
        quote:
            write(outputFile, c);
        quoteBackslash:
            ;{TODO: handle escaped character}
    end;
end;

begin
    currentState := start;

    writeln('Enter the name of the file to strip comments from:');
    readln(filename);
    assign(inputFile, filename);
    {$I-}
    reset(inputFile);
    {$I+}

    if IOResult = 2 then
        begin
        writeln('File not found.');
        exit;
        end
    else if IOResult <> 0 then
        begin
        writeln('IO error while opening file.');
        exit;
        end;

    assign(outputFile, concat(filename, '.out'));
    rewrite(outputFile);
    while not eof(inputFile) do
    begin
        read(inputFile, c);
        currentState := transitionFunction(currentState, c);
        handleChar(currentState, c, outputBuffer);
    end;
    close(inputFile);
    close(outputFile);
end.
