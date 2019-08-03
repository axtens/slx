IMPLEMENTATION MODULE Vars;

(* (C) Copyright 1992 Fitted Software Tools. All rights reserved. *)


(* IMPLEMENTATION *) CLASS VarsLinkedList;

END VarsLinkedList;



(* IMPLEMENTATION *) CLASS VarsLinkedListItem;

    (*PROCEDURE print;
    END print;
    *)
    PROCEDURE vInsert( oItem : VarsLinkedListItem); (* if exists, updates, else inserts *)
        TYPE
            oTempItem : VarsLinkedListItem;
        BEGIN
            oTempItem := oItem;
            IF NOT getfirst( oTempItem) THEN
                SELF.insert(oTempItem)
            ELSE
                WHILE NOT getnext( oTempItem) DO



    PROCEDURE vDelete( oItem : VarsLinkedListItem) : BOOLEAN;
    PROCEDURE vFetch( VAR oItem : VarsLinkedListItem) : BOOLEAN;END VarsLinkedListItem;


END Vars.