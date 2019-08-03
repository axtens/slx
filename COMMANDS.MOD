IMPLEMENTATION MODULE Commands;
    FROM Storage IMPORT ALLOCATE, DEALLOCATE;
    FROM Files IMPORT Close, Open, READ;
    FROM Strings IMPORT Append, Insert, Assign, CompareStr;
    FROM XString IMPORT UpperCase, RightTrim, YesNo, Equiv;
    FROM Dict IMPORT DictGet, DictInsert, DictSize, DictRetrieve, aDict, DictSave, DictLoad;
    FROM SHELL IMPORT Shell;
    FROM Display IMPORT Goto;
    FROM System IMPORT Terminate;
    FROM InOut IMPORT ReadLine, WriteLine, Read, WriteString;
    FROM NumberConversion IMPORT CardToString, StringToInt;
    FROM Menu IMPORT PullDownMenu;
    FROM DEBUG IMPORT DebugC, DebugL, DebugS, IsDebug, SetDebug;
    FROM Directories IMPORT ChDir;
    TYPE
        tCommand = RECORD
                    name : ARRAY [0..15] OF CHAR;
                    proc : PROCEDURE() : BOOLEAN;
                   END;
        pCommand = POINTER TO tCommand;
        StdString = ARRAY [0..254] OF CHAR;
    VAR
        aCommands : ARRAY [1..20] OF pCommand;
        n, nMaxCommands : CARDINAL;
        DICT : aDict;

    PROCEDURE SetCommandsDebug( bFlag : BOOLEAN);
    BEGIN
(*        bDebug := bFlag*)
    END SetCommandsDebug;

    PROCEDURE Crash() : BOOLEAN;
    BEGIN
        WriteLine("CRASH!!");
        RETURN TRUE
    END Crash;

    PROCEDURE Translation() : BOOLEAN;
    VAR
        sTemp1 : StdString;
    BEGIN
        DebugL("Translation()");
        DictRetrieve(DICT,"$P1", sTemp1);
        RightTrim( sTemp1);
        UpperCase( sTemp1);
        IF Equiv(sTemp1,"ON") OR Equiv(sTemp1,"OFF") THEN
            DictInsert(DICT,"$TRANSLATION",sTemp1);
            DictInsert(DICT,"$STATUS","SUCCESS")
        ELSE
            DictInsert(DICT,"$STATUS","FAILURE")
        END;
        RETURN TRUE
    END Translation;




    PROCEDURE ActivateMenu() : BOOLEAN;
    VAR
        cLine : CARDINAL;
        bFrame: BOOLEAN;
        sMain : StdString;
        sSub  : StdString;
        bClear: BOOLEAN;
        cCmd1,
        cCmd2 : CARDINAL;
        sCmd1,
        sCmd2,
        sCmd12 : StdString;
    BEGIN
        DebugL("ActivateMenu()");
        cLine := 0;
        bFrame:= TRUE;
        bClear:= TRUE;
        DictRetrieve(DICT,"$P1",sMain);
        DictRetrieve(DICT,"$P2",sSub);
        PullDownMenu(cLine, bFrame, sMain, sSub, bClear, cCmd1, cCmd2);
        CardToString(cCmd1, sCmd1, 1);
        CardToString(cCmd2, sCmd2, 1);
        Append(sCmd1,"_");
        Append(sCmd1,sCmd2);
        Insert("@$M",sCmd1,0);
        DictInsert(DICT,"$MENUOPT",sCmd1);
        DictInsert(DICT,"$STATUS","SUCCESS");
        RETURN TRUE
    END ActivateMenu;

    PROCEDURE Say() : BOOLEAN;
    VAR
        sTemp : StdString;
    BEGIN
        DebugL("Say()");
        DictRetrieve(DICT,"$CMDTAIL",sTemp);
        WriteLine(sTemp);
        DictInsert(DICT,"$STATUS","SUCCESS");
        RETURN TRUE
    END Say;

    PROCEDURE AtSay() : BOOLEAN;
    VAR
        sTemp : StdString;
        cRow, cCol : INTEGER;
        sRow, sCol : StdString;
        bFlag : BOOLEAN;
    BEGIN
        DebugL("AtSay()");
        DictRetrieve(DICT,"$P1",sRow);
        DictRetrieve(DICT,"$P2",sCol);
        DictRetrieve(DICT,"$P3",sTemp);
        StringToInt(sRow,cRow,bFlag);
        IF bFlag THEN
            StringToInt(sCol,cCol,bFlag);
            IF bFlag THEN
                Goto(cRow,cCol);
                WriteString(sTemp)
            ELSE
                DictInsert(DICT,"$STATUS","FAILURE");
                RETURN FALSE
            END
        ELSE
            DictInsert(DICT,"$STATUS","FAILURE");
            RETURN FALSE
        END;
        DictInsert(DICT,"$STATUS","SUCCESS");
        RETURN TRUE
    END AtSay;

    PROCEDURE At() : BOOLEAN;
    VAR
        sTemp : StdString;
        cRow, cCol : INTEGER;
        sRow, sCol : StdString;
        bFlag : BOOLEAN;
    BEGIN
        DebugL("At()");
        DictRetrieve(DICT,"$P1",sRow);
        DictRetrieve(DICT,"$P2",sCol);
        StringToInt(sRow,cRow,bFlag);
        IF bFlag THEN
            StringToInt(sCol,cCol,bFlag);
            IF bFlag THEN
                Goto(cRow,cCol);
            ELSE
                DictInsert(DICT,"$STATUS","FAILURE");
                RETURN FALSE
            END
        ELSE
            DictInsert(DICT,"$STATUS","FAILURE");
            RETURN FALSE
        END;
        DictInsert(DICT,"$STATUS","SUCCESS");
        RETURN TRUE
    END At;

    PROCEDURE TraceOn() : BOOLEAN;
    VAR
        sTemp1 : StdString;
    BEGIN
        DebugL("TraceOn()");
        SetDebug( TRUE);
        DictInsert(DICT,"$STATUS","SUCCESS");
        RETURN TRUE
    END TraceOn;

    PROCEDURE TraceOff() : BOOLEAN;
    VAR
        sTemp1 : StdString;
    BEGIN
        DebugL("TraceOff()");
        SetDebug( FALSE);
        DictInsert(DICT,"$STATUS","SUCCESS");
        RETURN TRUE
    END TraceOff;





    PROCEDURE ScriptDebug() : BOOLEAN;
    VAR
        sTemp1 : StdString;
    BEGIN
        DebugL("ScriptDebug()");
        DictRetrieve(DICT,"$P1", sTemp1);
        RightTrim( sTemp1);
        SetDebug( Equiv( sTemp1, "ON"));
        DictInsert(DICT,"$STATUS","SUCCESS");
        RETURN TRUE
    END ScriptDebug;


    PROCEDURE SaveDictionary() : BOOLEAN;
    VAR
        sTemp1 : StdString;
    BEGIN
        DebugL("SaveDictionary()");
        DictRetrieve(DICT,"$P1", sTemp1);
        RightTrim( sTemp1);
        DictInsert(DICT,"$STATUS","SUCCESS");
        DictSave( DICT,sTemp1);
        RETURN TRUE
    END SaveDictionary;

    PROCEDURE LoadDictionary() : BOOLEAN;
    VAR
        sTemp1 : StdString;
    BEGIN
        DebugL("LoadDictionary()");
        DictRetrieve(DICT,"$P1", sTemp1);
        RightTrim( sTemp1);
        DictInsert(DICT,"$STATUS","SUCCESS");
        DictLoad( DICT, sTemp1);
        RETURN TRUE
    END LoadDictionary;


    PROCEDURE Define( ) : BOOLEAN;
    VAR
        sTemp1,
        sTemp2 : StdString;
    BEGIN
        DebugL("Define()");
        DictRetrieve(DICT,"$P1",sTemp1);
        RightTrim(sTemp1);
        DictRetrieve(DICT,"$P2",sTemp2);
        (*RightTrim(sTemp2);*)
        DictInsert(DICT,sTemp1,sTemp2);
        RETURN TRUE

    END Define;
    PROCEDURE XYesNo( ) : BOOLEAN;
    VAR
        sTemp1,
        sTemp2,
        sTemp3 : StdString;
        lFlag  : BOOLEAN;

    BEGIN
        DebugL("XYesNo()");
        DictRetrieve(DICT,"$P1",sTemp1);
        (*RightTrim(sTemp1);*)
        lFlag:=YesNo( sTemp1);
        DictRetrieve(DICT,"$P2",sTemp1);
        DictRetrieve(DICT,"$P3",sTemp2);
        RightTrim(sTemp1);
        RightTrim(sTemp2);
        IF sTemp1[0] = 0X THEN
            IF NOT lFlag THEN
                sTemp3 := '2'
            ELSE
                sTemp3 := '1'
            END
        ELSE
            IF sTemp2[0] = 0X THEN
                IF NOT lFlag THEN
                    Assign(sTemp1,sTemp3)
                ELSE
                    sTemp3 := '1'
                END
            ELSE
                IF NOT lFlag THEN
                    Assign(sTemp2,sTemp3)
                ELSE
                    Assign(sTemp1,sTemp3)
                END
            END
        END;
        IF lFlag THEN
            DictInsert(DICT,"$YESNO","YES")
        ELSE
            DictInsert(DICT,"$YESNO","NO")
        END;
        DictInsert(DICT,"$INCR",sTemp3);
        RETURN TRUE

    END XYesNo;


    PROCEDURE OnError( ) : BOOLEAN;
    VAR
        sTemp1,
        sTemp2 : StdString;
        lFlag : BOOLEAN;
    BEGIN
        DebugL("OnError()");
        DictRetrieve(DICT,"$P1",sTemp1);
        RightTrim(sTemp1);
        IF CompareStr(sTemp1,"FAIL")=0 THEN
            DictInsert(DICT,"$ONERROR","FAIL")
        ELSE
            DictInsert(DICT,"$ONERROR","PASS")
        END;
        RETURN TRUE
    END OnError;

    PROCEDURE End() : BOOLEAN;
    BEGIN
        DebugL("End()");
        Terminate(0);
        RETURN TRUE
    END End;


    PROCEDURE Require() : BOOLEAN;
    VAR
        nBuf : INTEGER;
        lFlag: BOOLEAN;
        sTemp: ARRAY [0..65] OF CHAR;

    BEGIN
        DebugL("Require()");
        DictRetrieve(DICT,"$P1",sTemp);
        Open(nBuf,sTemp,READ);
        IF nBuf = -1 THEN
            DictInsert(DICT,"$STATUS","FAIL");
            DictInsert(DICT,"$ERP","REQUIRE");
            DictInsert(DICT,"$ERM","File not found.");
            DictInsert(DICT,"$ERI",sTemp);
            lFlag := FALSE
        ELSE
            DictInsert(DICT,"$STATUS","SUCCESS");
            Close(nBuf);
            lFlag := TRUE
        END;
        RETURN lFlag
    END Require;

    PROCEDURE GetLine() : BOOLEAN;
    VAR
        sTemp,
        cSym : StdString;
    BEGIN
        DebugL("GetLine()");
        DictRetrieve(DICT,"$P1",cSym);
        DictRetrieve(DICT,"$P2",sTemp);
        (*RightTrim(sTemp);*)
        WriteString(sTemp);
        ReadLine(sTemp);
        WriteLine("");
        DictInsert(DICT,cSym,sTemp);
        RETURN TRUE
    END GetLine;

    PROCEDURE GetKey() : BOOLEAN;
    VAR
        cKeyTemp : CHAR;
        sTemp,
        cSym : StdString;
    BEGIN
        DebugL("GetKey()");
        DictRetrieve(DICT,"$P1",cSym);
        DictRetrieve(DICT,"$P2",sTemp);
        (*RightTrim(sTemp);*)
        WriteString(sTemp);
        Read(cKeyTemp);
        WriteLine(cKeyTemp);
        DictInsert(DICT,cSym,cKeyTemp);
        RETURN TRUE
    END GetKey;

    PROCEDURE Execute( ) : BOOLEAN;
    VAR
        sTemp : StdString;
        cErr  : StdString;
        n : CARDINAL;
        b : BOOLEAN;
    BEGIN
        DebugL("Execute()");
        DictRetrieve(DICT,"$CMDTAIL",sTemp);
        IF Shell(sTemp,n) THEN
            DictInsert(DICT,"$STATUS","SUCCESS");
            b := FALSE
        ELSE
            DictInsert(DICT,"$ERP","Execute()");
            DictInsert(DICT,"$ERM","Dos Error in Shell()");
            CardToString(n,cErr,5);
            DictInsert(DICT,"$ERI",cErr);
            DictInsert(DICT,"$STATUS","FAIL");
            b := TRUE
        END;
        RETURN b
    END Execute;

    PROCEDURE Skip() : BOOLEAN;
        VAR
            sTemp : StdString;
            i     : INTEGER;
            l     : BOOLEAN;
        BEGIN
        DebugL("Skip()");
            DictRetrieve(DICT, "$P1", sTemp);
            DictInsert(DICT, "$INCR",sTemp);
            StringToInt(sTemp,i,l);
            IF NOT l THEN
                DictInsert(DICT, "$ERP","SKIP");
                DictInsert(DICT, "$ERM","Parameter does not resolve to an integer");
                DictInsert(DICT, "$ERI",sTemp);
                RETURN FALSE
            ELSE
                RETURN TRUE
            END;
        END Skip;

    PROCEDURE ChangeDirectory() : BOOLEAN;
        VAR
            sTemp : StdString;
            i     : INTEGER;
            l     : BOOLEAN;
        BEGIN
            DebugL("ChangeDirectory()");
            DictRetrieve(DICT, "$P1", sTemp);
            ChDir(sTemp);
            RETURN TRUE
        END ChangeDirectory;

    PROCEDURE Process( VAR Dictionary : aDict ) : CARDINAL;
    VAR
        n : CARDINAL;
        cSearch,
        cKnown : ARRAY [0..15] OF CHAR;
        pTemp  : PROCEDURE():BOOLEAN;
        nResult: CARDINAL;
        lFlag,
        lResponse  : BOOLEAN;
        sSym, sDef : StdString;

    BEGIN
        DICT := Dictionary;
        DebugL("Process()");
        IF IsDebug() THEN
            nResult := DictSize( DICT);
            FOR n := 1 TO nResult DO
                DictGet( DICT, n, sSym,sDef);
                WriteString(sSym);
                WriteString("=");
                WriteLine(sDef)
            END
        END;
        DictRetrieve(DICT,"$CMDNAME",cSearch);
        RightTrim(cSearch);

        pTemp := Crash;
        nResult := 0;
        n := 1;
        lFlag := FALSE;
        LOOP
            Assign(aCommands[n]^.name,cKnown);
            RightTrim(cKnown);
            IF Equiv(cSearch,cKnown) THEN
                pTemp := aCommands[n]^.proc;
                lFlag := TRUE;
            END;
            IF lFlag THEN
                lResponse := pTemp();
                IF lResponse THEN
                    nResult := 0
                ELSE
                    nResult := 1
                END;
                EXIT
            ELSE
                INC(n);
                IF n > nMaxCommands THEN
                    nResult := 0FFFFH;
                    EXIT
                END;

            END;
        END;

        RETURN nResult

    END Process;


BEGIN
    nMaxCommands := 20;
    FOR n := 1 TO nMaxCommands DO
        NEW(aCommands[n])
    END;
    aCommands[1]^.name := 'END';
    aCommands[1]^.proc := End;
    aCommands[2]^.name := 'REQUIRE';
    aCommands[2]^.proc := Require;
    aCommands[3]^.name := 'GETLINE';
    aCommands[3]^.proc := GetLine;
    aCommands[4]^.name := 'EXECUTE';
    aCommands[4]^.proc := Execute;
    aCommands[5]^.name := 'DEFINE';
    aCommands[5]^.proc := Define;
    aCommands[6]^.name := 'GETKEY';
    aCommands[6]^.proc := GetKey;
    aCommands[7]^.name := 'YESNO';
    aCommands[7]^.proc := XYesNo;
    aCommands[8]^.name := 'ONERROR';
    aCommands[8]^.proc := OnError;
    aCommands[9]^.name := 'SAVEDICT';
    aCommands[9]^.proc := SaveDictionary;
    aCommands[10]^.name := 'LOADDICT';
    aCommands[10]^.proc := LoadDictionary;
    aCommands[11]^.name := 'SKIP';
    aCommands[11]^.proc := Skip;
    aCommands[12]^.name := 'DEBUG';
    aCommands[12]^.proc := ScriptDebug;
    aCommands[13]^.name := 'MENU';
    aCommands[13]^.proc := ActivateMenu;
    aCommands[14]^.name := 'TRANSLATION';
    aCommands[14]^.proc := Translation;
    aCommands[15]^.name := 'CHDIR';
    aCommands[15]^.proc := ChangeDirectory;
    aCommands[16]^.name := 'TRACEON';
    aCommands[16]^.proc := TraceOn;
    aCommands[17]^.name := 'TRACEOFF';
    aCommands[17]^.proc := TraceOff;
    aCommands[18]^.name := 'SAY';
    aCommands[18]^.proc := Say;
    aCommands[19]^.name := 'ATSAY';
    aCommands[19]^.proc := AtSay;
    aCommands[20]^.name := 'AT';
    aCommands[20]^.proc := At;



END Commands.

