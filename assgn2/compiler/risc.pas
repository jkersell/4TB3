{$I+} {$R+} {$S+}

unit risc;

interface

  const MemSize = 4096;  {in bytes}

  type Memory = array [0 .. (MemSize div 4) - 1] of longint;

  procedure Execute (pc0: longint);

  procedure LoadCode (var code: Memory; len: longint);

implementation

  const
    ADDOP = 0; SUBOP = 1; MULOP = 2; DIVOP = 3; MODOP = 4; CMPOP = 5;
    OROP = 8; ANDOP = 9; BICOP = 10; XOROP = 11; LSHOP = 12; ASHOP = 13;
    CHKOP = 14; ADDIOP = 16; SUBIOP = 17; MULIOP = 18; DIVIOP = 19;
    MODIOP = 20; CMPIOP = 21; ORIOP = 24; ANDIOP = 25; BICIOP = 26;
    XORIOP = 27; LSHIOP = 28; ASHIOP = 29; CHKIOP = 30; LDWOP = 32;
    LDBOP = 33; POPOP = 34; STWOP = 36; STBOP = 37; PSHOP = 38; BEQOP = 40;
    BNEOP = 41; BLTOP = 42; BGEOP = 43; BLEOP = 44; BGTOP = 45; BSROP = 46;
    JSROP = 48; RETOP = 49; RDOP = 50; WRDOP = 51; WRLOP = 52;

  type Registers = array [0..31] of longint;

  var
    PC, IR: longint;
    R: Registers;
    M: Memory;

  { R[0] = 0, R[30] = SP, R[31] = link }

  procedure State;
  begin
    write ('PC=', PC * 4 :6);
    write (' SP=', R[30] :6);
    write (' FP=', R[29] :6);
    write (' R1=', R[1] :6);
    write (' R2=', R[2] :6);
    write (' R3=', R[3] :6);
    writeln (' R4=', R[4] :6)
  end;

  procedure Execute (pc0: longint);
    var opc, a, b, c, nxt: longint;
      done : boolean;
  begin
    R[31] := 0; PC := pc0 div 4;
    done := false;
    repeat
      if paramcount >= 3 then State;
      R[0] := 0; nxt := PC + 1;
      IR := M[PC];
      opc := (IR shr 26) and $0000003F;
      a := (IR shr 21) and $0000001F;
      b := (IR shr 16) and $0000001F;
      c := IR and  $0000FFFF;
      if opc < ADDIOP then c := R[c and $0000001F]
      else if c >= $8000 then c := c - $10000;  {sign extension}
      case opc of
        ADDOP, ADDIOP: R[a] := R[b] + c;
        SUBOP, SUBIOP, CMPOP, CMPIOP: R[a] := R[b] - c;
        MULOP, MULIOP: R[a] := R[b] * c;
        DIVOP, DIVIOP: R[a] := R[b] div c;
        MODOP, MODIOP: R[a] := R[b] mod c;
        OROP,  ORIOP : R[a] := R[b] or c;
        ANDOP, ANDIOP: R[a] := R[b] and c;
        BICOP, BICIOP: R[a] := R[b] and not c;
        XOROP, XORIOP: R[a] := R[b] xor c;
        LSHOP, LSHIOP: {positive count denotes shift to left, negative to right}
          if c >= 0 then R[a] := R[b] shl c
          else R[a] := R[b] shr (-c); {not implemented correctly}
        ASHOP, ASHIOP: {positive count denotes shift to left, negative to right}
          if c >= 0 then R[a] := R[b] shl c
          else R[a] := R[b] shr (-c);
        CHKOP, CHKIOP: if (R[a] < 0) or (R[a] >= c) then 
          begin writeln ('Trap at ', PC*4 :2); done := true end;
        LDWOP: R[a] := M[(R[b] + c) div 4];
        LDBOP: R[a] := (M[(R[b] + c) div 4] shr (R[b] + c) mod 4 * 8) and
          $000000FF;
        POPOP: begin R[a] := M[(R[b]) div 4]; R[b] := R[b] + c end;
        STWOP: M[(R[b] + c) div 4] := R[a];
        STBOP: {not implemented};
        PSHOP: begin R[b] := R[b] - c; M[(R[b]) div 4] := R[a] end;
        BEQOP: if R[a] = R[b] then nxt := PC + c;
        BNEOP: if R[a] <> R[b] then nxt := PC + c;
        BLTOP: if R[a] < R[b] then nxt := PC + c;
        BGEOP: if R[a] >= R[b] then nxt := PC + c;
        BLEOP: if R[a] <= R[b] then nxt := PC + c;
        BGTOP: if R[a] > R[b] then nxt := PC + c;
        BSROP: begin nxt := PC + c; R[31] := (PC + 1) * 4 end;
        JSROP: begin nxt := IR and $03FFFFFF; R[31] := (PC + 1) * 4 end;
        RETOP:
          begin nxt := R[c and $0000001F] div 4; if nxt = 0 then done := true
          end;
        RDOP:  read (R[a]);
        WRDOP: write (' ', R[c]);
        WRLOP: writeln
      end ;
      PC := nxt
    until done;
    if paramcount >= 3 then State;
  end;

  procedure LoadCode (var code: Memory; len: longint);
    var i: longint;
  begin i := 0;
    while i < len do
      begin M[i] := code[i]; i := i + 1 end
  end;
end.
