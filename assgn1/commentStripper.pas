program ReadFile;
type
    states = (start, slash, slashSlash, slashStar, slashStarStar, slashStarStarSlash, quote, quoteBackslash);
var
    input, outputBuffer: string;
    c: char;
    currentState: states;

function transitionFunction(state: states; c: char): states;
begin
    transitionFunction := state;
    case state of
        start:
            if c = '/' then
                transitionFunction := slash
            else if c = '"' then
                transitionFunction := quote
            else
                ;
        slash:
            if c = '/' then
                transitionFunction := slashSlash
            else if c = '*' then
                transitionFunction := slashStar
            else
                transitionFunction := start;
        slashSlash:
            {Only recognize unix style line endings.}
            if c = chr(10) then
                transitionFunction := start
            else
                ;{dump all characters until end of line}
        slashStar:
            if c = '*' then
                transitionFunction := slashStarStar
            else
                ;{dump all characters until comment is ended}
        slashStarStar:
            if c = '/' then
                transitionFunction := slashStarStarSlash
            else
                transitionFunction := slashStar;
        slashStarStarSlash:
            if c = '/' then
                transitionFunction := slash
            else if c = '"' then
                transitionFunction := quote
            else
                transitionFunction := start;
        quote:
            if c = '\' then
                transitionFunction := quoteBackslash
            else if c = '"' then
                transitionFunction := start
            else
                ;
        quoteBackslash:
            transitionFunction := quote;
    end;
end;

procedure handleChar(state: states; c: char; outputBuffer: string);
begin
    case state of
        start:
            begin
            if outputBuffer <> '' then
                write(outputBuffer);
            write(c);
            end;
        slash:
            outputBuffer :=  outputBuffer + c;
        slashSlash, slashStar:
            outputBuffer := '';
        slashStarStar, slashStarStarSlash:
            ;
        quote:
            write(c);
        quoteBackslash:
            ;{TODO: handle escaped character}
    end;
end;

begin
    currentState := start;

    while not eof do
    begin
        read(c);
        currentState := transitionFunction(currentState, c);
        handleChar(currentState, c, outputBuffer);
    end;
end.
