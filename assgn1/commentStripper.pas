program ReadFile;
type
    states = (start, slash, slashSlash, slashStar, slashStarStar, quote, quoteBackslash);
var
    inputFile: text;
    outputFile: text;
    filename: string;
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
            if EOLn(inputFile) then
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
                transitionFunction := start
            else
                transitionFunction := slashStar;
            end;
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
            {TODO: handle escaped characters properly}
            transitionFunction := quote;
            end;
    end;
end;
begin
    currentState := start;
    filename := 'testFile';
    assign(inputFile, filename);
    reset(inputFile);
    assign(outputFile, concat(filename, '.out'));
    rewrite(outputFile);
    while not eof(inputFile) do
    begin
        read(inputFile, c);
        currentState := transitionFunction(currentState, c);
    end;
    close(inputFile);
    close(outputFile);
end.
