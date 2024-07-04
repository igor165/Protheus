#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} UpdAtuSxRU
Atualizador de traduções em russo no AtuSx

@author izac.ciszevski
@since 21/07/2017
/*/
User Function F0100302(aEmp)

    ConOut(FwTimeStamp(2) + " - Inicio do Processamento Flavours      ")

    InitProc(aEmp)

    ConOut(FwTimeStamp(2) + " - Flavour de Parametros            (XXM)")
    SendXXM()
    ConOut(FwTimeStamp(2) + " - Flavour de Perguntas             (XXG)")
    SendXXG()
    ConOut(FwTimeStamp(2) + " - Flavour de Tabelas               (XXI)")
    SendXXI()
    ConOut(FwTimeStamp(2) + " - Flavour de Campos                (XXK)")
    SendXXK()
    ConOut(FwTimeStamp(2) + " - Flavour de Tabela generica       (XXL)")
    SendXXL()
    ConOut(FwTimeStamp(2) + " - Flavour de Pastas e Agrupamentos (XXN)")
    SendXXN()
    ConOut(FwTimeStamp(2) + " - Flavour de Consulta padrao       (XXO)")
    SendXXO()
    ConOut(FwTimeStamp(2) + " - Flavour de Grupo de Campos       (XXQ)")
    SendXXQ()
    ConOut(FwTimeStamp(2) + " - Flavour de CHS                   (XXR)")
    SendXXR()
    ConOut(FwTimeStamp(2) + " - Flavour de Menus                 (XXS)")
    SendXXS()
    ConOut(FwTimeStamp(2) + " - Flavour de Helps                 (XAB)")
    SendXAB()

    ClearProc()

    ConOut(FwTimeStamp(2) + " - Final do Processamento                ")

Return

/*/{Protheus.doc} SendXXM()
Envia os registros da XXM - Parâmetros
@author izac.ciszevski
@since 21/07/2017
/*/
Static Function SendXXM()

    Local aKeys      := {}
    Local aValues    := {}
    Local cAliasAux  := GetNextAlias()
    Local cBody      := ""
    Local cKey       := ""
    Local cPutReturn := ""

    BeginSQL Alias cAliasAux
         SELECT ZA1_KEY1   VAR   ,
                ZA1_KEY2   ATTRIB,
                R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1%
          WHERE %Exp:RetZA1Where('6')%
            ORDER BY ZA1_KEY1, ZA1_KEY2 DESC
    EndSQL

    While (cAliasAux)->(!EoF())
        aValues := {}
        cKey    := VAR
        aKey    := {VAR, "RUS"}

        While (cAliasAux)->(!EoF()) .And. cKey == VAR
            GoToZA1((cAliasAux)->ZA1REC)

            If ATTRIB = "X6_DESCRIC"
                AAdd(aValues, {"description1", ZA1->ZA1_NEWTEX})
            ElseIf ATTRIB = "X6_DESC1"
                AAdd(aValues, {"description2", ZA1->ZA1_NEWTEX})
            ElseIf ATTRIB = "X6_DESC2"
                AAdd(aValues, {"description3", ZA1->ZA1_NEWTEX})
            EndIf

            (cAliasAux)->(DbSkip())
        EndDo

        cBody := ReqBody(aKey, aValues)
        
        If MakePut("/parameter", cBody)
            UpdateZA1()
        EndIf

    EndDo

    (cAliasAux)->(DbCloseArea())

Return

/*/{Protheus.doc} SendXXQ()
Envia os registros da XXQ - Grupo de campos
@author izac.ciszevski
@since 21/07/2017
/*/
Static Function SendXXQ()

    Local aKey       := {}
    Local aValues    := {}
    Local cAliasAux  := GetNextAlias()
    Local cBody      := ""
    Local cPutReturn := ""

    BeginSQL Alias cAliasAux
         SELECT ZA1_KEY1   GRUPO,
                R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1%
          WHERE %Exp:RetZA1Where('G')%
    EndSQL

    While (cAliasAux)->(!EoF())
        GoToZA1((cAliasAux)->ZA1REC)

        aKey       := {GRUPO, "RUS"}
        aValues    := {{"description", ZA1->ZA1_NEWTEX}}
        cBody := ReqBody(aKey, aValues)
        
        If MakePut("/fieldGroup", cBody)
            UpdateZA1()
        EndIf

        (cAliasAux)->(DbSkip())
    EndDo

    (cAliasAux)->(DbCloseArea())

Return

/*/{Protheus.doc} SendXXN()
Envia os registros da XXN - Pasta de agrupamento
@author izac.ciszevski
@since 21/07/2017
/*/
Static Function SendXXN()

    Local aKey       := {}
    Local aValues    := {}
    Local cAliasAux  := GetNextAlias()
    Local cBody      := ""
    Local cPutReturn := ""

    BeginSQL Alias cAliasAux
         SELECT ZA1_KEY1   ALIAS,
                ZA1_KEY2   AGRUP,
                ZA1_KEY3   ORDEM,
                R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1%
          WHERE %Exp:RetZA1Where('A')%
    EndSQL

    While (cAliasAux)->(!EoF())
        GoToZA1((cAliasAux)->ZA1REC)

        aKey       := {ALIAS, ORDEM, AGRUP}
        aValues    := {{"description", ZA1->ZA1_NEWTEX}}
        cBody := ReqBody(aKey, aValues)
        
        If MakePut("/folder", cBody)
            UpdateZA1()
        EndIf

        (cAliasAux)->(DbSkip())
    EndDo

    (cAliasAux)->(DbCloseArea())

Return

/*/{Protheus.doc} SendXXI()
Envia os registros da XXI - Tabelas
@author izac.ciszevski
@since 21/07/2017
/*/
Static Function SendXXI()

    Local aKey       := {}
    Local aValues    := {}
    Local cAliasAux  := GetNextAlias()
    Local cBody      := ""
    Local cPutReturn := ""

    BeginSQL Alias cAliasAux
         SELECT ZA1_KEY1   ALIAS,
                R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1%
          WHERE %Exp:RetZA1Where('2')%
    EndSQL

    While (cAliasAux)->(!EoF())
        GoToZA1((cAliasAux)->ZA1REC)

        aKey       := {ALIAS, "RUS"}
        aValues    := {{"description", ZA1->ZA1_NEWTEX}}
        cBody := ReqBody(aKey, aValues)
        
        If MakePut("/table", cBody)
            UpdateZA1()
        EndIf

        (cAliasAux)->(DbSkip())
    EndDo

    (cAliasAux)->(DbCloseArea())

Return

/*/{Protheus.doc} SendXXO()
Envia os registros da XXO - Consulta padrão
@author izac.ciszevski
@since 21/07/2017
/*/
Static Function SendXXO()

    Local aKey       := {}
    Local aValues    := {}
    Local cAliasAux  := GetNextAlias()
    Local cBody      := ""
    Local cPutReturn := ""

    BeginSQL Alias cAliasAux
         SELECT ZA1_IDIOM  IDIOM ,
                ZA1_KEY1   CODSXB,
                ZA1_KEY2   TIPO  ,
                ZA1_KEY3   SEQ   ,
                ZA1_KEY4   COLUNA,
                ZA1_KEY5   ATTRIB,
                R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1%
          WHERE %Exp:RetZA1Where('B')%
    EndSQL

    While (cAliasAux)->(!EoF())
        GoToZA1((cAliasAux)->ZA1REC)

        aKey       := {CODSXB, TIPO, SEQ, COLUNA, "RUS"}
        aValues    := {{"description", ZA1->ZA1_NEWTEX}}
        cBody := ReqBody(aKey, aValues)
        
        If MakePut("/lookup", cBody)
            UpdateZA1()
        EndIf

        (cAliasAux)->(DbSkip())
    EndDo

    (cAliasAux)->(DbCloseArea())

Return

/*/{Protheus.doc} SendXXG()
Envia os registros da XXG - Perguntas
@author izac.ciszevski
@since 21/07/2017
/*/
Static Function SendXXG()

    Local aKey       := {}
    Local aValues    := {}
    Local cAliasAux  := GetNextAlias()
    Local cBody      := ""
    Local cKey       := ""
    Local cPutReturn := ""

    BeginSQL Alias cAliasAux
         SELECT ZA1_KEY1   GRUPO ,
                ZA1_KEY2   IDFIL ,
                ZA1_KEY3   ORDEM ,
                ZA1_KEY4   ATTRIB,
                R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1%
          WHERE %Exp:RetZA1Where('1')%
            ORDER BY ZA1_KEY1
    EndSQL

    While (cAliasAux)->(!EoF())
        aValues := {}
        cKey    := GRUPO + ORDEM
        aKey    := {GRUPO, IDFIL, ORDEM, "RUS"}

        While (cAliasAux)->(!EoF()) .And. cKey == GRUPO + ORDEM
            GoToZA1((cAliasAux)->ZA1REC)

            If ATTRIB = "X1_PERGUNT"
                AAdd(aValues, {"description", ZA1->ZA1_NEWTEX})
            ElseIf ATTRIB = "X1_DEF01"
                AAdd(aValues, {"definition1", ZA1->ZA1_NEWTEX})
            ElseIf ATTRIB = "X1_DEF02"
                AAdd(aValues, {"definition2", ZA1->ZA1_NEWTEX})
            ElseIf ATTRIB = "X1_DEF03"
                AAdd(aValues, {"definition3", ZA1->ZA1_NEWTEX})
            ElseIf ATTRIB = "X1_DEF04"
                AAdd(aValues, {"definition4", ZA1->ZA1_NEWTEX})
            ElseIf ATTRIB = "X1_DEF05"
                AAdd(aValues, {"definition5", ZA1->ZA1_NEWTEX})
            EndIf

            (cAliasAux)->(DbSkip())
        EndDo

        cBody := ReqBody(aKey, aValues)
        
        If MakePut("/question", cBody)
            UpdateZA1()
        EndIf

    EndDo

    (cAliasAux)->(DbCloseArea())

Return

/*/{Protheus.doc} SendXXS()
Envia os registros da XXS - Menus
@author izac.ciszevski
@since 21/07/2017
/*/
Static Function SendXXS()

    Local aKeys      := {}
    Local aValues    := {}
    Local cAliasAux  := GetNextAlias()
    Local cBody      := ""
    Local cKey       := ""
    Local cPutReturn := ""

    BeginSQL Alias cAliasAux
         SELECT ZA1_KEY1   CODIGO,
                ZA1_KEY2   ATTRIB,
                R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1%
          WHERE %Exp:RetZA1Where('M')%
          ORDER BY ZA1_KEY1
    EndSQL

    While (cAliasAux)->(!EoF())
        aValues := {}
        cKey    := CODIGO
        aKey    := {CODIGO}

        While (cAliasAux)->(!EoF()) .And. cKey == CODIGO
            GoToZA1((cAliasAux)->ZA1REC)

            If ATTRIB = "ZMN_DSCBRZ"
                AAdd(aValues, {"text", ZA1->ZA1_NEWTEX})
            ElseIf ATTRIB = "ZMN_KEYBRZ"
                AAdd(aValues, {"key" , ZA1->ZA1_NEWTEX})
            EndIf

            (cAliasAux)->(DbSkip())
        EndDo

        cBody := ReqBody(aKey, aValues)
        
        If MakePut("/menu", cBody)
            UpdateZA1()
        EndIf

    EndDo

    (cAliasAux)->(DbCloseArea())

Return

/*/{Protheus.doc} SendXXL()
Envia os registros da XXL - Tabelas genericas
@author izac.ciszevski
@since 21/07/2017
/*/
Static Function SendXXL()

    Local aKey       := {}
    Local aValues    := {}
    Local cAliasAux  := GetNextAlias()
    Local cBody      := ""
    Local cPutReturn := ""

    BeginSQL Alias cAliasAux
         SELECT ZA1_KEY1   TABELA,
                ZA1_KEY2   CHAVE ,
                R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1%
          WHERE %Exp:RetZA1Where('5')%
    EndSQL

    While (cAliasAux)->(!EoF())
        GoToZA1((cAliasAux)->ZA1REC)

        aKey       := {TABELA, CHAVE, "RUS"}
        aValues    := {{"description", ZA1->ZA1_NEWTEX}}
        cBody := ReqBody(aKey, aValues)
        
        If MakePut("/genericTable", cBody)
            UpdateZA1()
        EndIf

        (cAliasAux)->(DbSkip())
    EndDo

    (cAliasAux)->(DbCloseArea())

Return

/*/{Protheus.doc} SendXXK()
Envia os registros da XXK - Campos
@author izac.ciszevski
@since 21/07/2017
/*/
Static Function SendXXK()

    Local aKeys      := {}
    Local aValues    := {}
    Local cAliasAux  := GetNextAlias()
    Local cBody      := ""
    Local cKey       := ""
    Local cPutReturn := ""

    BeginSQL Alias cAliasAux
         SELECT ZA1_KEY1   CAMPO ,
                ZA1_KEY2   ATTRIB,
                R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1%
          WHERE %Exp:RetZA1Where('3')%
          ORDER BY ZA1_KEY1, ZA1_KEY2 DESC
    EndSQL

    While (cAliasAux)->(!EoF())
        aValues := {}
        cKey    := CAMPO
        aKey    := {CAMPO, "RUS"}

        While (cAliasAux)->(!EoF()) .And. cKey == CAMPO
            GoToZA1((cAliasAux)->ZA1REC)

            If ATTRIB = "X3_TITULO"
                AAdd(aValues, {"title"      , ZA1->ZA1_NEWTEX})
            ElseIf ATTRIB = "X3_DESCRIC"
                AAdd(aValues, {"description", ZA1->ZA1_NEWTEX})
            ElseIf ATTRIB = "X3_CBOX"
                AAdd(aValues, {"options"    , ZA1->ZA1_NEWTEX})
            EndIf

            (cAliasAux)->(DbSkip())
        EndDo

        cBody := ReqBody(aKey, aValues)
        
        If MakePut("/field", cBody)
            UpdateZA1()
        EndIf

    EndDo

    (cAliasAux)->(DbCloseArea())

Return

/*/{Protheus.doc} SendXAB()
Envia os registros da XXK - Helps
@author izac.ciszevski
@since 21/07/2017
/*/
Static Function SendXAB()

    Local aKeys      := {}
    Local aValues    := {}
    Local cAliasAux  := GetNextAlias()
    Local cBody      := ""
    Local cKey       := ""
    Local cPutReturn := ""

    BeginSQL Alias cAliasAux
         SELECT ZA1_KEY1   CODHLS,
                ZA1_KEY2   ATTRIB,
                R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1%
          WHERE %Exp:RetZA1Where('H')%
          ORDER BY ZA1_KEY1, ZA1_KEY2
    EndSQL

    While (cAliasAux)->(!EoF())
        aValues := {}
        cKey    := CODHLS
        aKey    := {StrTran(CODHLS,"'",""), "RUS"}

        While (cAliasAux)->(!EoF()) .And. cKey == CODHLS
            GoToZA1((cAliasAux)->ZA1REC)

            If ATTRIB = "ZXH_IDPRB"
                AAdd(aValues, {"problemtext" , StrTran(ZA1->ZA1_NEWTEX, CRLF, " ")})
            ElseIf ATTRIB = "ZXH_IDSOL"
                AAdd(aValues, {"solutiontext", StrTran(ZA1->ZA1_NEWTEX, CRLF, " ")})
            EndIf

            (cAliasAux)->(DbSkip())
        EndDo

        cBody := ReqBody(aKey, aValues)
        
        If MakePut("/help", cBody)
            UpdateZA1()
        EndIf

    EndDo

    (cAliasAux)->(DbCloseArea())

Return

/*/{Protheus.doc} SendXXR()
Envia os registros da XXR - Strings
@author izac.ciszevski
@since 21/07/2017
/*/
Static Function SendXXR()

    Local aKeys      := {}
    Local aValues    := {}
    Local cAliasAux  := GetNextAlias()
    Local cBody      := ""
    Local cPutReturn := ""

    BeginSQL Alias cAliasAux
         SELECT ZA1_KEY1   PROGRA,
                ZA1_KEY2   CHAVE ,
                R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1%
          WHERE %Exp:RetZA1Where('S')%
    EndSQL

    While (cAliasAux)->(!EoF())
        GoToZA1((cAliasAux)->ZA1REC)

        aKey       := {RTrim(PROGRA) + ".CH" , "STR" + CHAVE, "RUS"}
        aValues    := {{"text", ZA1->ZA1_NEWTEX}}
        cBody := ReqBody(aKey, aValues)
        
        If MakePut("/programText", cBody)
            UpdateZA1()
        EndIf

        (cAliasAux)->(DbSkip())
    EndDo

    (cAliasAux)->(DbCloseArea())

Return

Static Function MakePut(cPath, cBody)

    Local aHeader    := {"Authorization: Basic " + Encode64(cUserPass)}
    Local cPutReturn := " "
    Local lOK        := .T.

    oClient:SetPath(cService + cPath)

    lOk := oClient:Put(aHeader, cBody)
   
    If lOk
        cPutReturn := " PUT: " + NoAcento(oClient:GetResult())
    Else
        cPutReturn := " PUT ERROR: " + NoAcento(oClient:GetLastError())
        ConOut(cPutReturn)
        ConOut(cBody)
    EndIf

Return lOk

Static Function ReqBody(aKey, aValues)

    Local cReqBody := ""
    Local nValue   := 0
    Local nKey     := 0

    cReqBody := "["

    For nValue := 1 To Len(aValues)
        cReqBody +=  '{"version":"","project":"","package":"",'
        cReqBody += '"key":['
        For nKey := 1 To Len(aKey)
            cReqBody += '"' + RTrim(aKey[nKey]) + '",'
        Next
        cReqBody := Left(cReqBody, Len(cReqBody) - 1) //- Remove a vírgula que sobra
        cReqBody += '],'
        cReqBody += '"property": "' + aValues[nValue][1] + '","idiom":"ru","value":"' + RTrim(aValues[nValue][2]) + '"},' // Adicionei o RTrim. Não sei se deveria.
    Next

    cReqBody := Left(cReqBody, Len(cReqBody) - 1) //- Remove a vírgula que sobra
    cReqBody += "]"

Return cReqBody

Static Function InitProc(aEmp)

    Default aEmp := {"T1", "01"}

    Static lInitialize := .F.

    Static oClient
    Static aZA1Recnos := {}
    Static cEndServer := ""
    Static cUserPass  := ""
    Static cService   := ""

    If Select("SX2") == 0
        lInitialize := .T.
        RPCSetEnv(aEmp[1], aEmp[2])
    EndIf
    
    cEndServer := GetNewPar("FS_ATUWS" , "187.94.56.126:8090"   ) //-- server do atusx
    cUserPass  := GetNewPar("FS_ATUPSW", "izac.ciszevski:123456") //-- usuario e senha para acesso no atuSx      
    cService   := GetNewPar("FS_ATUSRV", "/rest/atusx/v1"       ) //-- serviço que será utilizado
    
    oClient    := FWRest():New(cEndServer)
    aZA1Recnos := {}

Return

Static Function ClearProc()

    FreeObj(oClient)

    oClient    := Nil
    aZA1Recnos := Nil
    cEndServer := Nil
    cUserPass  := Nil
    cService   := Nil

    If lInitialize 
	    RpcClearEnv()
        lInitialize := Nil
    EndIf

Return

Static Function GoToZA1(nRecno)

    ZA1->(DbGoTo(nRecno))
    AAdd(aZA1Recnos, nRecno)

Return

Static Function UpdateZA1()

    Local aSavArea := GetArea()
    Local nRecno   := 1

    For nRecno := 1 To Len(aZA1Recnos)
        ZA1->(DbGoTo(aZA1Recnos[nRecno]))
        RecLock("ZA1", .F.)
        ZA1->ZA1_ATUSX := "1"
        ZA1->ZA1_HIST  := u_ZA1Hist("Registry sent to AtuSX.")
        ZA1->(MsUnlock())
    Next

    aZA1Recnos := {}

    RestArea(aSavArea)

Return

Static Function RetZA1Where(cOrigin)

    Local cWhere := ""

    cWhere :=   "     ZA1_IDIOM  = 'ru'"              + ;        
                " AND ZA1_ORIGIN = '" + cOrigin + "'" + ;       
                " AND ZA1_FLAV   = 'TRANSL'"          + ;            
                " AND ZA1_STATUS = '4'"               + ;       
                " AND ZA1_ATUSX != '1'"               + ;       
                " AND D_E_L_E_T_ = ' ' "            

Return "%" + cWhere + "%"
// Russia_R5
