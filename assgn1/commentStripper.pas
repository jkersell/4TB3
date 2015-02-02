program ReadFile;
type
    states = (start, slash, slashSlash, slashStar, slashStarStar, quote, quoteBackslash);
var
    myFile: text;
    filename: string;
    c: char;
    state: states;
begin
    state := start;
    filename := 'testFile';
    assign(myFile, filename);
    reset(myFile);
    while not eof(myFile) do
    begin
        read(myFile, c);
        case state of
            start:
                begin
                writeln('State is start');
                if c = '/' then
                    state := slash
                else if c = '"' then
                    state := quote
                else
                    {Just write directly to output}
                    write(c);
                end;
            slash:
                begin
                writeln('State is slash');
                if c = '/' then
                    state := slashSlash
                else if c = '*' then
                    state := slashStar
                else
                    state := start;
                end;
            slashSlash:
                begin
                writeln('State is slashSlash');
                if EOLn(myFile) then
                    state := start
                else
                    ;{dump all characters until end of line}
                end;
            slashStar:
                begin
                writeln('State is slashStar');
                if c = '*' then
                    state := slashStarStar
                else
                    ;{dump all characters until comment is ended}
                end;
            slashStarStar:
                begin
                writeln('State is slashStarStar');
                if c = '/' then
                    state := start
                else
                    state := slashStar;
                end;
            quote:
                begin
                writeln('State is quote');
                if c = '\' then
                    state := quoteBackslash
                else if c = '"' then
                    state := start
                else
                    write(c);
                end;
            quoteBackslash:
                begin
                writeln('State is quoteBackslash');
                {TODO: handle escaped characters properly}
                state := quote;
                end;
        end;
    end;
    close(myFile);
end.
