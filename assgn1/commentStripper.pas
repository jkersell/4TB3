program ReadFile;
type
    states = (start, slash, slashSlash, slashStar, slashStarStar, quote, quoteBackslash);
var
    inputFile: text;
    outputFile: text;
    filename: string;
    c: char;
    state: states;
begin
    state := start;
    filename := 'testFile';
    assign(inputFile, filename);
    reset(inputFile);
    assign(outputFile, concat(filename, '.out'));
    rewrite(outputFile);
    while not eof(inputFile) do
    begin
        read(inputFile, c);
        case state of
            start:
                begin
                writeln('State is start');
                if c = '/' then
                    state := slash
                else if c = '"' then
                    state := quote
                else
                    ;
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
                if EOLn(inputFile) then
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
                    ;
                end;
            quoteBackslash:
                begin
                writeln('State is quoteBackslash');
                {TODO: handle escaped characters properly}
                state := quote;
                end;
        end;
    end;
    close(inputFile);
    close(outputFile);
end.
