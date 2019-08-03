IMPLEMENTATION MODULE Dict;
    FROM Strings IMPORT
        Copy, Assign, CompareStr, Insert, Length, Delete, Pos;
    FROM InOut IMPORT
        WriteString, WriteLine, WriteCard, RedirectOutput,
        ReadLine, CloseOutput, RedirectInput, CloseInput, Done;
    FROM XString IMPORT
        RightTrim, Equiv;
    (*FROM INSTRING IMPORT InStr;*)
    FROM INLine IMPORT
        InLine;
    FROM DEBUG IMPORT
        DebugL, DebugS, DebugC;
    FROM Storage IMPORT
        ALLOCATE, DEALLOCATE;
    CONST DEFINER = 0;
          DEFINIT = 1;
          SYMLEN  = 15;
          DEFLEN  = 255;

    TYPE
        StdString = ARRAY [0..DEFLEN] OF CHAR;
        rDict = RECORD
                       Symbol : ARRAY [0..SYMLEN] OF CHAR;
                       Definition : StdString;
                END;
        prDict = POINTER TO rDict;
        arDict = ARRAY [1..200] OF prDict;
        aDict = POINTER TO arDict;

    PROCEDURE DictCreate() : aDict;
    VAR
        aNewDict : aDict;
        cCnt : CARDINAL;
    BEGIN
        DebugL("Creating aDict");

        NEW(aNewDict);
        FOR cCnt := 1 TO 200 DO
            NEW(aNewDict^[cCnt]);
            aNewDict^[cCnt]^.Symbol := '';
            aNewDict^[cCnt]^.Definition := ''
        END;
        RETURN aNewDict;
    END DictCreate;

    PROCEDURE DictSize( aD : aDict) : CARDINAL;
    VAR
        cCnt : CARDINAL;
        cPtr : CARDINAL;
    BEGIN
        cPtr := 1;
        cCnt := 0;
        IF aD # NIL THEN
            LOOP
                IF aD^[cPtr]^.Symbol[0] = 0C THEN
                    EXIT
                ELSE
                    INC( cPtr);
                    INC( cCnt)
                END
            END
        END;
        DebugS("Size of aDict=");
        DebugC(cCnt);
        DebugL("");
        RETURN cCnt
     END DictSize;


    PROCEDURE SetDictDebug( lFlag : BOOLEAN);
    BEGIN
        (*bDebug := lFlag*)
    END SetDictDebug;

    PROCEDURE DictGet( aD : aDict; cIndex : CARDINAL; VAR sSym, sDef : ARRAY OF CHAR);
    BEGIN
        Assign( aD^[cIndex]^.Symbol, sSym);
        Assign( aD^[cIndex]^.Definition, sDef);

            DebugS("DictGet [");
            DebugC(cIndex);
            DebugS("]: ");
            DebugS(sSym);
            DebugS("=");
            DebugL(sDef)

    END DictGet;

    PROCEDURE DictInsert( VAR aD : aDict; sSym, sDef : ARRAY OF CHAR);
    VAR cIdx,
        cSize : CARDINAL;
        lFlag : BOOLEAN;
    BEGIN

            DebugS("DictInsert: ");
            DebugS(sSym);
            DebugS("=");
            DebugL(sDef);

        cSize := DictSize(aD);
        IF cSize = 0 THEN

                        DebugS("Assigning ");
                        DebugS(sSym);
                        DebugS("=");
                        DebugS(sDef);
                        DebugS(" @ ");
                        DebugC( 1);
                        DebugL("");

            Assign(sSym,aD^[1]^.Symbol);
            Assign(sDef,aD^[1]^.Definition);
        ELSE
            lFlag := FALSE;
            FOR cIdx := 1 TO cSize DO
                IF Equiv(aD^[cIdx]^.Symbol, sSym) THEN
                    Assign(sDef,aD^[cIdx]^.Definition);
                    lFlag := TRUE;

                        DebugS("Updating: Assigning ");
                        DebugS(sSym);
                        DebugS("=");
                        DebugS(sDef);
                        DebugS(" @ ");
                        DebugC( cIdx);
                        DebugL("")

                END
            END;
            IF NOT lFlag THEN
                INC(cSize); (*INC(nDictUsed);*)

                        DebugS("Adding: Assigning ");
                        DebugS(sSym);
                        DebugS("=");
                        DebugS(sDef);
                        DebugS(" @ ");
                        DebugC( cSize);
                        DebugL("");

                Assign(sSym,aD^[cSize]^.Symbol);
                Assign(sDef,aD^[cSize]^.Definition)
            END
        END
    END DictInsert;



    PROCEDURE DictRetrieve( aD : aDict; sSym : ARRAY OF CHAR; VAR sDef : ARRAY OF CHAR);
    VAR cIdx,
        cSize : CARDINAL;
        lFlag : BOOLEAN;
    BEGIN
        cSize := DictSize( aD);

            DebugS("DictRetrieve says that DictSize is : ");
            DebugC(cSize);
            DebugL("");

        IF cSize = 0 THEN
            sDef[0] := 0X;
        ELSE
            lFlag := FALSE;
            FOR cIdx := 1 TO cSize DO
                IF Equiv(aD^[cIdx]^.Symbol,sSym) THEN
                    Assign( aD^[cIdx]^.Definition, sDef);
                    lFlag := TRUE;

                        DebugS("Retrieving ");
                        DebugS(sSym);
                        DebugS("=");
                        DebugS(sDef);
                        DebugS(" @ ");
                        DebugC( cIdx);
                        DebugL("")

                END
            END;
            IF NOT lFlag THEN
                sDef[0] := 0X
            END;
        END;

            DebugS("DictRetrieve: ");
            DebugS(sSym);
            DebugS("=");
            DebugL(sDef)

    END DictRetrieve;


    PROCEDURE DictSubst( aD : aDict; VAR sString : ARRAY OF CHAR; nSwaps : CARDINAL);
        VAR
            sMacSym,
            sSym,
            sDef : StdString;

            i2,
            n    : CARDINAL;
            lSwapped : BOOLEAN;

        PROCEDURE Substitute() : BOOLEAN;
        VAR
                lSwap : BOOLEAN;
                i     : CARDINAL;
                cTemp : CARDINAL;
                cDelLen : CARDINAL;
                cOffset : CARDINAL;
                bSwap : BOOLEAN;
                xTest : CHAR;
        BEGIN
                lSwap := FALSE;
                cTemp := DictSize( aD);

                    DebugS("Substitute says that DictSize is : ");
                    DebugC(cTemp);
                    DebugL("");


                FOR i := 1 TO cTemp DO
                    DictGet( aD, i, sSym, sDef);
                    RightTrim(sSym);
                    sMacSym := sSym;
                    Insert("@",sMacSym,0);

                    DebugS("SUBST: sMacSym=");
                    DebugL(sMacSym);
                    DebugS("SUBST: sString=");
                    DebugL(sString);

                    cOffset := 0;
                    WHILE InLine( cOffset, sString, sMacSym, " .",TRUE) DO

                        DebugS("FIRST: cOffset=");
                        DebugC(cOffset);
                        DebugS(" for ");
                        DebugS(sMacSym);
                        DebugS(" in ");
                        DebugL(sString);

                        cDelLen := Length( sMacSym);

                        DebugS("cDelLen=");
                        DebugC(cDelLen);
                        DebugL("");
                        bSwap := TRUE;
                        xTest := sString[cOffset+cDelLen];
                        CASE xTest OF
                            '.' : INC(cDelLen);
                            |
                            0C  : ;
                            |
                            ' ' : ;
                            |
                            ELSE
                                bSwap := FALSE
                        END;
                        DebugS("Char at end of sString =");
                        DebugC(ORD(xTest));
                        DebugL("");
                        DebugS("Status of bSwap=");
                        DebugC(ORD(bSwap));
                        DebugL("");
                        DebugS("AFTER INC: cDelLen=");
                        DebugC(cDelLen);
                        DebugL("");
                        IF bSwap THEN
                            DebugL("SUBST IS SWAPPING");
                            lSwap := TRUE;

                                DebugS("Swapping out ");
                                DebugS(sSym);
                                DebugS(" and swapping in ");
                                DebugL(sDef);

                            Delete( sString, cOffset, cDelLen);
                            Insert( sDef, sString, cOffset);

                                DebugS("Result is ");
                                DebugL(sString)

                        END;
                    END;
                END;
                RETURN lSwap
            END Substitute;

        BEGIN
            DebugS("sString=");
            DebugL(sString);
            LOOP
                lSwapped := Substitute();
                DEC(nSwaps);
                IF nSwaps = 0 THEN EXIT END;
                IF NOT lSwapped THEN EXIT END;
            END;

        END DictSubst;

    PROCEDURE DictSave( aD : aDict; cFileName : ARRAY OF CHAR);
        VAR
            cCnt1,
            cCnt2 : CARDINAL;
            sSym,
            sDef : StdString;
        BEGIN
            RedirectOutput(cFileName);
            cCnt2 := DictSize(aD);
            FOR cCnt1 := 1 TO cCnt2 DO
                DictGet( aD, cCnt1, sSym, sDef);
                WriteString(sSym);
                WriteString("=");
                WriteLine(sDef);
            END;
            CloseOutput;
        END DictSave;

    PROCEDURE DictLoad( VAR aD : aDict; cFileName : ARRAY OF CHAR);
        VAR
            cTemp1,
            sSym,
            sDef : StdString;
            n      : CARDINAL;
        BEGIN
            RedirectInput( cFileName);
            IF NOT Done THEN
                DictInsert(aD, "$ERP","DictLoad");
                DictInsert(aD, "$ERM","File not found.");
                DictInsert(aD, "$ERI",cFileName);
                RETURN
            END;
            LOOP (*WHILE Done DO*)
                ReadLine( cTemp1);
                IF (NOT Done) OR (cTemp1[0]=0C) THEN
                    EXIT
                END;
                n := Pos( "=", cTemp1);
                IF n <= HIGH( cTemp1) THEN
                    Copy( cTemp1, 0, n, sSym);
                    Copy( cTemp1, n+1, 127, sDef);

                        DebugS("DictLoad: sSym=");
                        DebugL(sSym);
                        DebugS("DictLoad: sDef=");
                        DebugL(sDef);

                    DictInsert(aD, sSym, sDef);
                END
            END;
        END DictLoad;

    PROCEDURE DictDestroy( aD : aDict);
    BEGIN

            DebugL("Destroying aD");

        DISPOSE(aD)
    END DictDestroy;


BEGIN

END Dict.
