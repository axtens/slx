MODULE ScriptLanguageXperiment;
    FROM Storage IMPORT ALLOCATE, DEALLOCATE;
    FROM SYSTEM IMPORT ADR;
    FROM DEBUG IMPORT SetDebug, SetDebugEnv, IsDebug, DebugC, DebugL, DebugS;
    FROM FileSpec IMPORT HasExt;
    FROM Files IMPORT Close,
                      Read,
                      Write,
                      Open,
                      READ;
    FROM Strings IMPORT Assign,
                        Append,
                        Length,
                        Copy,
                        Insert,
                        Delete,
                        Pos;
    FROM InOut   IMPORT WriteLine,
                        WriteString,
                        WriteCard;
    FROM System  IMPORT GetArg,
                        Terminate;
    FROM NumberConversion IMPORT StringToInt,
                                 IntToString;
    FROM XString IMPORT Cut,
                        LeftTrim,
                        UpperCase,
                        RightTrim,
                        Equiv;
    FROM Dict IMPORT SetDictDebug,
                     DictGet,
                     DictInsert,
                     DictSubst,
                     DictSave,
                     DictRetrieve,
                     DictCreate,
                     DictDestroy,
                     aDict;
    FROM FREADLN IMPORT FReadLine;
(*    FROM XDOS    IMPORT ReadFileLine;*)
    FROM Commands IMPORT Process;
    FROM SHELL IMPORT Shell;
    FROM SLICE IMPORT Slice;

    TYPE
        cStringType = ARRAY [0..255] OF CHAR;
        pStringType = POINTER TO cStringType;
        cFileString = ARRAY [0..63]  OF CHAR;

    VAR
        lFailOnErr : BOOLEAN;
        lSuccess   : BOOLEAN;
        lEndIt     : BOOLEAN;
        cProcRes   : CARDINAL;

        nPC        : INTEGER;
        n1,
        n,
        nDictCnt,
        nCmdCnt    : CARDINAL;
        iTemp,
        nBuffer   : INTEGER;
        cTemp1,
        cTemp2,
        cCmd       : cStringType;
        aCmds  : ARRAY [1..100] OF pStringType;

        cParam,
        cCmdFile  : cFileString;

        nTemp     : CARDINAL;
        lTemp     : BOOLEAN;

        DICT    : aDict;

    PROCEDURE ErrorMessage();
    VAR
        cTemp : cStringType;
    BEGIN
        DictRetrieve(DICT,"$ERP",cTemp);
        RightTrim(cTemp);
        WriteString("Error in ");
        WriteString(cTemp);
        DictRetrieve(DICT,"$ERM",cTemp);
        RightTrim(cTemp);
        WriteString(": ");
        WriteString(cTemp);
        DictRetrieve(DICT,"$ERI",cTemp);
        RightTrim(cTemp);
        WriteString(" ");
        WriteLine(cTemp);
    END ErrorMessage;


    PROCEDURE GetUCS();
        BEGIN
            cCmd := "GETLINE $x Where is the DEFAULT.SLX file? ";
            DictInsert(DICT,"$RAWCMD",cCmd);
            DictInsert(DICT,"$FULCMD",cCmd);
            Slice(cCmd, cTemp1); (* cTemp1 contains *GETLINE *)
            DictInsert(DICT,"$CMDNAME",cTemp1);
            DictInsert(DICT,"$CMDTAIL",cCmd);
            Slice(cCmd, cTemp2); (* cTemp2 contains $x *)
            DictInsert(DICT,"$P1",cTemp2);
            DictInsert(DICT,"$P2",cCmd);
            nTemp := Process(DICT);

            cCmd := "REQUIRE @$x.\DEFAULT.SLX";
            DictInsert(DICT,"$RAWCMD",cCmd);
            DictSubst(DICT,cCmd,1);
            DictInsert(DICT,"$FULCMD",cCmd);
            Slice(cCmd, cTemp1); (* cTemp1 contains *REQUIRE *)
            DictInsert(DICT,"$CMDNAME",cTemp1);
            DictInsert(DICT,"$CMDTAIL",cCmd);
            Slice(cCmd, cTemp2);
            DictInsert(DICT,"$P1",cTemp2);
            DictInsert(DICT,"$P2",cCmd);
            IF Process(DICT) = 0 THEN
                Assign(cCmd,cCmdFile);
                DictInsert(DICT,"%1",cTemp2);
                DictInsert(DICT,"$CMDFILE",cTemp2)
            ELSE
                cCmd := "SAVEDICT ERROR.DIC";
                DictInsert(DICT,"$RAWCMD",cCmd);
                DictInsert(DICT,"$FULCMD",cCmd);
                Slice(cCmd, cTemp1); (* cTemp1 contains *SAVEDICT *)
                DictInsert(DICT,"$CMDNAME",cTemp1);
                DictInsert(DICT,"$CMDTAIL",cCmd);
                Slice(cCmd, cTemp2);
                DictInsert(DICT,"$P1",cTemp2);
                DictInsert(DICT,"$P2",cCmd);
                IF Process(DICT) = 0 THEN END;
                Failure()
            END;
        END GetUCS;
    PROCEDURE Failure();
        BEGIN
            DictRetrieve(DICT,"$FULCMD",cTemp2);
            WriteString("Command {");
            RightTrim(cTemp2);
            WriteString(cTemp2);
            WriteLine("} failed.");
            Terminate(1)
        END Failure;

    PROCEDURE InitArray();
        VAR n : CARDINAL;
        BEGIN
            FOR n := 1 TO 100 DO
                NEW(aCmds[n]);
                aCmds[n]^ := '';
            END;
        END InitArray;

    BEGIN
        WriteLine("SLX (Script Language Xperiment) v1.1 (c) Copyright Bruce M. Axtens, 1994.");
        SetDebugEnv("SLX","DEBUG");
        DICT := DictCreate();
        InitArray();

        nDictCnt := 0;
        GetArg(cParam,n);
        LOOP
            INC( nDictCnt);
            IF nDictCnt > 9 THEN EXIT END;
            cTemp1 := '%';
            IntToString(nDictCnt,cTemp2,2);
            LeftTrim( cTemp2);
            Append(cTemp1,cTemp2);
            DictInsert(DICT,cTemp1,cParam);
            GetArg(cParam,n);
        END;
        IF nDictCnt <> 0 THEN
            cCmdFile := '';
            DictRetrieve(DICT,"%1",cParam);
            IF cParam[0] = '/' THEN
                SetDebug((CAP(cParam[1])='D'));
                cCmdFile := '';
            ELSE
                cCmdFile := cParam;
            END;
            DictInsert(DICT,"$CMDFILE",cCmdFile);

            DictRetrieve(DICT,"%2",cParam);
            IF cParam[0] = '/' THEN
                SetDebug((CAP(cParam[1])='D'));
            END;
            (*SetDictDebug( lDebug);*)
            DictRetrieve(DICT, "$CMDFILE", cCmdFile);
            IF cCmdFile[0] = 0X THEN
                GetUCS();
            ELSE
                IF NOT HasExt( cCmdFile) THEN
                    Append( cCmdFile, ".SLX");
                END;
                DictInsert(DICT,"$CMDFILE",cCmdFile);
                DictInsert(DICT,"$P1",cCmdFile);
                DictInsert(DICT,"$CMDNAME","REQUIRE");
                cTemp1 := "REQUIRE $P1";
                DictSubst(DICT,cTemp1,1);
                DictInsert(DICT,"$RAWCMD",cTemp1);
                IF Process(DICT) > 0 THEN
                    Failure();
                END;
            END;

        ELSE
            GetUCS();
        END;
        DictRetrieve(DICT,"$CMDFILE",cCmdFile);
        Open(nBuffer,cCmdFile,READ);
        IF nBuffer = -1 THEN
            Failure()
        END;
        nCmdCnt := 0;
        WHILE FReadLine( nBuffer, cCmd) DO
        (*ReadFileLine(nBuffer,cCmd,n);*)
        (*WHILE n <> 0 DO*)
            RightTrim(cCmd);
            IF cCmd[0] <> 0X THEN
                DebugS("Line Read =");
                DebugL(cCmd);
                INC(nCmdCnt);
                Assign(cCmd,aCmds[nCmdCnt]^);
            END;
            (*ReadFileLine(nBuffer,cCmd,n);*)
        END;
        Close(nBuffer);
        DebugL("Commandfile contents");
        IF IsDebug() THEN
            FOR n := 1 TO nCmdCnt DO
                WriteLine(aCmds[n]^)
            END;
        END;
        lEndIt := FALSE;
        DictInsert(DICT,"$INCR",'1');
        DictInsert(DICT,"$ONERROR","PASS");
        DictInsert(DICT,"$TRANSLATION","ON");
        nPC := 1;
        LOOP
            DictInsert(DICT,"$ERP","");
            DictInsert(DICT,"$ERM","");
            DictInsert(DICT,"$ERI","");
            lSuccess := FALSE;
            cCmd := aCmds[nPC]^;
            DictInsert(DICT,"$RAWCMD",cCmd);
            DictRetrieve(DICT,"$TRANSLATION",cTemp1);
            IF Equiv(cTemp1,"ON") THEN
                DictSubst( DICT,cCmd,0);
            END;

                DebugS("MAIN LOOP ==> ");
                DebugL(cCmd);

            DictInsert(DICT,"$FULCMD",cCmd);
            Slice(cCmd,cTemp1);
            UpperCase(cTemp1);
            DictInsert(DICT,"$CMDNAME",cTemp1);
            DictInsert(DICT,"$CMDTAIL",cCmd);
            Slice(cCmd,cTemp1);
            DictInsert(DICT,"$P1",cTemp1);
            Slice(cCmd,cTemp1);
            DictInsert(DICT,"$P2",cTemp1);
            Slice(cCmd,cTemp1);
            DictInsert(DICT,"$P3",cTemp1);

            cProcRes := Process(DICT);

            DictRetrieve(DICT,"$STATUS",cTemp1);
            lSuccess := Equiv(cTemp1,"SUCCESS");
            (*lSuccess := cProcRes = 0;*)
            DictRetrieve(DICT,"$ONERROR",cTemp1);
            RightTrim(cTemp1);
            lFailOnErr := Equiv(cTemp1,"FAIL");

            IF cProcRes = 0FFFFH THEN
                DictRetrieve(DICT,"$CMDNAME",cTemp2);
                RightTrim(cTemp2);
                WriteString(cTemp2);
                WriteLine(" not recognised.");
                lSuccess := FALSE
            ELSE
                IF NOT lSuccess THEN
                    IF lFailOnErr THEN
                        ErrorMessage();
                        Failure()
                    ELSE
                        ErrorMessage();
                    END
                END;
                IF lEndIt THEN
                    Terminate(0)
                END;
            END;
            DictRetrieve(DICT,"$INCR",cTemp1);
            StringToInt(cTemp1,iTemp,lTemp);
            IF lTemp THEN
                nPC := nPC + iTemp
            ELSE
                INC(nPC)
            END;
            DictInsert(DICT,"$INCR",'1');
            IF nPC < 1 THEN
                nPC := 1
            END;
            IF nPC > INTEGER(nCmdCnt) THEN
                EXIT
            END;
        END;
    END ScriptLanguageXperiment.
