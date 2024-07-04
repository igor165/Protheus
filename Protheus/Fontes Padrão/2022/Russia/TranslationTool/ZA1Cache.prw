#INCLUDE "PROTHEUS.CH"

Static __lCacheZA1 := .T.


Function __FlvEntrRus(cCodFlav, cIdiom, cCache, cText, cOrigin, cKey1, cKey2, cKey3, cKey4, cKey5)
    Local aArea	
    Local cKey      := ""
    Local lNew      := .F.
    
    If !__lCacheZA1 .OR. !select("SX2") > 0 
        Return
    EndIf

    If Empty(cText)
        Return
    EndIf
  
  
    Chkfile("ZA1")
    If select("ZA1") == 0
    	Return
    Endif
    
    If select("SM0") == 0
    	Return
    Endif


    aArea     := GetArea()
    //cKey      := SubStr(cCache, Len(cIdiom) + 1) // CAZARINI - 21/12/17 - Alterei para apos o tratamento de tamanho do cIdiom 
    cIdiom    := PadR(cIdiom, 5)
    cKey      := SubStr(cCache, Len(cIdiom) + 1)

    ZA1->(DbSetOrder(1))
    lNew := ! ZA1->(DbSeek(XFilial("ZA1") + cIdiom + cOrigin + cKey))
        
    ZA1->(RecLock("ZA1", lNew))
        If lNew
            ZA1->ZA1_FILIAL := XFilial("ZA1")
            ZA1->ZA1_STATUS	:= "1"                      //1=Unchanged;2=ABBY Sent;3=Pending Approval;4=Translated;5=Applied                                                              
            ZA1->ZA1_FLAV	:= cCodFlav
            ZA1->ZA1_IDIOM	:= cIdiom
            ZA1->ZA1_ORIGIN	:= cOrigin                 //S=Source;1=Questions;2=Table Name;3=Fields;5=Generic Table;6=Parametros;A=Folders;B=Queries;G=Field Groups;H=Help;M=Menu        
            ZA1->ZA1_SHORT	:= Left(cText, Len(ZA1->ZA1_SHORT))
            ZA1->ZA1_TEXT	:= cText                    // Texto original
            ZA1->ZA1_NEWTEX	:= " "                      // Texto traduzido final
            ZA1->ZA1_MANUAL := " "                      // Texto sugerido
            ZA1->ZA1_KEY    := cKey
            ZA1->ZA1_KEY1	:= cKey1
            ZA1->ZA1_KEY2	:= cKey2
            ZA1->ZA1_KEY3	:= cKey3
            ZA1->ZA1_KEY4	:= cKey4
            ZA1->ZA1_KEY5	:= cKey5
            ZA1->ZA1_SEEK   := GetSeekKey(cOrigin, {cCodFlav, cKey1, cKey2,  cKey3,  cKey4, cKey5, cIdiom})
            ZA1->ZA1_HIST   := U_ZA1Hist("Registry included" )
        ElseIf Alltrim(ZA1->ZA1_TEXT) <> Alltrim(cText)
            ZA1->ZA1_HIST   := U_ZA1Hist("Registry updated from '" + Alltrim(ZA1->ZA1_TEXT) + "' to '" + Alltrim(cText) + "'" )
            ZA1->ZA1_SHORT	:= Left(cText, Len(ZA1->ZA1_SHORT))
            ZA1->ZA1_TEXT	:= cText                    // Texto original
            ZA1->ZA1_NEWTEX	:= ""                       // Texto traduzido final
            ZA1->ZA1_MANUAL := ""                       // Texto sugerido
            // CAMPOS CONTROLE
            ZA1->ZA1_STATUS	:= "1"
            ZA1->ZA1_ATUSX	:= " "
            ZA1->ZA1_APROV	:= " "
            ZA1->ZA1_APLICA	:= " "
            ZA1->ZA1_SENT	:= " "
        EndIf
        ZA1->ZA1_TIME	:= Time()
        ZA1->ZA1_DATE	:= MsDate()
        ZA1->ZA1_THREAD	:= StrZero(ThreadId(), 6)   //uso para filtro de manutencao manual
        ZA1->ZA1_FUNNAM	:= FunName()                //uso para filtro de manutencao manual        
        ZA1->ZA1_MODULO	:= Iif(!Empty(cModulo), cModulo, GetStack(3,.T.))
		ZA1->ZA1_STACK	:= GetStack(3,.F.)
    ZA1->(MsUnLock())
    RestArea(aArea)

Return

User Function ZA1Cache()

    If ChkFile("ZA1")
        __lCacheZA1 := !__lCacheZA1
        If __lCacheZA1
            MsgAlert('ZA1 cache enabled')
        else
            MsgAlert('ZA1 cache disabled')
        EndIf
    Else
        MsgAlert("Table ZA1 doesn't exists")
    EndIf

Return

User Function ZA1Hist( cMsg)
    Local cHistory:= ""

    cHistory := RTrim(ZA1->ZA1_HIST) 
    cHistory += FWTimeStamp(2) + "|" + ZA1->ZA1_STATUS + "|" + cMsg + CRLF

Return cHistory

User Function ZA1HasCache()

Return __lCacheZA1


/**
    Set the System Language.
 */
User Function ZA1SetIdiom(cIdiom)
    Local nLang

    nLang  := Aviso("Multi language", "Please choose system language", {"Ðóññêèé", "English", "Spanish", "Portuguese"})
    
    Do Case
        Case nLang==1
            FwSetIdiom("ru")
        Case nLang==2
            FwSetIdiom("en")
        Case nLang==3
            FwSetIdiom("es")
        Case nLang==4
            FwSetIdiom("pt-br")
    EndCase

Return

/**
    Set hotkeys for:
    CTRL + L -> Language selection
    CTRL + U -> Translation Maintenance
    CTRL + P -> Enable/Disable Translation Cache
 */
User Function ZA1SetKey()

     //SetKey(K_CTRL_L, {|| U_ZA1ExecKey("L")})
    SetKey(K_CTRL_U, {|| U_ZA1ExecKey("U")})
    //SetKey(K_CTRL_P, {|| U_ZA1ExecKey("P")})
    SetKey(K_CTRL_T, {|| U_F0101001()})
    SetKey(K_CTRL_Q, {|| U_F0100800()}) // atualiza Flavour

Return

/**
    Tratamento para não chamar a função da hotkey se ela já estiver sendo executada
*/
User Function ZA1ExecKey(cKey)

    Do Case
        Case cKey == "L"
            If !IsInCallStack("U_ZA1SetIdiom")
                U_ZA1SetIdiom()
            EndIf
        Case cKey == "U"
            If !IsInCallStack("U_FlavorEdt")
                U_FlavorEdt(.F.)
            EndIf
        Case cKey == "P"
            If !IsInCallStack("U_ZA1Cache") 
                U_ZA1Cache()
            EndIf
    EndCase

Return

Static Function GetStack( nProc,lFirst)
    Local cProcname	:=	Procname(nProc)
    Local cRet		:=	""
    Default lFirst	:=	.F.

    While ! Empty(cProcname) .And. Len(cRet) < 60
        If lFirst
            cRet	:=	AllTrim(cProcName)+"->"
        ElseIf Substr(cProcName,1,1)<>"{"
            cRet	+=	AllTrim(cProcName)+"->"
        Endif
        cProcname := Procname(++nProc)
    Enddo	
    cRet	:=	Substr(cRet,1,Len(cRet)-2)

Return cRet 


Static Function GetSeekKey(cOrigin, aKey)
    Local cSeekKey := ""
    Local aIndex   := {}
    Local nIndex   := 0
    Local cFlvAlias:= GetOrigin(cOrigin)
    Local nKey     := 0

    If cFlvAlias == "XXR"
        aKey[2] := aKey[2] + ".CH"
        aKey[3] := "STR" + aKey[3]
        aKey[4] := "ZB1_TXTPOR"
    EndIf

    aIndex := StrTokArr((cFlvAlias)->(IndexKey()),"+")
    
    For nKey := 1 to Len(aKey)
        If aKey[nKey] == Nil
            Loop 
        Endif
        nIndex ++
        cSeekKey += PadR(aKey[nKey], Len((cFlvAlias)->(FieldGet(FieldPos(aIndex[nIndex])))))
    Next

Return cSeekKey

Static Function GetOrigin(cOrigin)
    Local nPosAlias := 0
    Local aAlias := {;
                        {"1", "XXG"},;
                        {"2", "XXI"},;
                        {"3", "XXK"},;
                        {"5", "XXL"},;
                        {"6", "XXM"},;
                        {"A", "XXN"},;
                        {"B", "XXO"},;
                        {"G", "XXQ"},;
                        {"S", "XXR"},;
                        {"M", "XXS"},;
                        {"H", "XAB"};
                    }

    nPosAlias := AScan(aAlias, {|aOrigin| aOrigin[1] == cOrigin })

Return aAlias[nPosAlias, 2]


// Russia_R5
