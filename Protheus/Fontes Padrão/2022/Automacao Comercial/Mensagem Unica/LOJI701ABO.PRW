#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWADAPTEREAI.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJI701STBO
Mensagem unica de Rastreabilidade de Pedidos Venda com Retira com o Objeto Eai(FwObjEai)

@param oEaiObjEnt    - Objeto Eai de entrada
@param nTypeTrans    - Tipo de transacao. (Envio/Recebimento)
@param cTypeMessage    - Tipo de mensagem. (Business Type, WhoIs, etc)
@param cVersion        - Versão em uso

@retorno aRet        - Array contendo o resultado da execucao.
            aRet[1]    (boolean)    - Indica o resultado da execução da função
            aRet[2]    (indefinido)- Objeto FwObjEai ou descrição do erro
            aRet[3]    (caracter)    - Nome da mensagem
            aRet[4]    (caracter)    - Tipo da mensagem

@author     Rafael Tenorio da Costa / Julio Nery
@since      16/10/18 - 25/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function LOJI701ABO(oEaiObjEnt, nTypeTrans, cTypeMessage, cVersion, lJSon)

    Local aRet := {.F., "", "DOCUMENTTRACEABILITYORDERRETAIL", "JSON"}
    Local aAux := {}

    Default lJSon   := .F.

    If nTypeTrans == TRANS_RECEIVE

        If cTypeMessage == EAI_MESSAGE_WHOIS
            aRet[1] := .T.
            aRet[2] := "1.000|1.001"
        Else
            aRet[1] := .F.
            aRet[2] := "Tipo de mensagem não implementado: " + cTypeMessage    //"Tipo de mensagem não implementado: "
        EndIf

    ElseIf nTypeTrans == TRANS_SEND

        Do Case 
            Case !lJSon

                aRet[1] := .F.
                aRet[2] := "Adapter disponível apenas no formato JSON."
 
            //Faz chamada da versão especifica
            Case AllTrim(cVersion) == "1.000"
                aAux := v1000(oEaiObjEnt, nTypeTrans, cTypeMessage)
                
                aRet[1] := aAux[1]
                aRet[2] := aAux[2]
            Case AllTrim(cVersion) == "1.001"
			    aAux := v1001(oEaiObjEnt, nTypeTrans, cTypeMessage)
			    aRet[1] := aAux[1]
			    aRet[2] := aAux[2]
            OTherWise
                aRet[1] := .F.
                aRet[2] := "A versao da mensagem informada não foi implementada"    //"A versao da mensagem informada não foi implementada"
        End Case
    EndIf

    LjGrvLog("LOJI701ABO", "Mensagem única DOCUMENTTRACEABILITYORDERRETAIL, retorno:", aRet)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} v1000
Efetuar o envio da menaagem unica

@param oEaiObjEnt    - Objeto Eai de entrada
@param nTypeTrans    - Tipo de transacao. (Envio/Recebimento)
@param cTypeMessage    - Tipo de mensagem. (Business Type, WhoIs, etc)

@retorno aRet        - Array contendo o resultado da execucao.
            aRet[1]    (boolean)    - Indica o resultado da execução da função
            aRet[2]    (FwObjEai)     - Objeto FwObjEai utilizado para o envio

@author     Julio Nery
@since      25/09/20
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function v1000(oEaiObjEnt, nTypeTrans, cTypeMessage)
Local aArea        := GetArea()
Local aAreaSL1     := SL1->(GetArea())
Local aRet         := {.T., ""}
Local oFwEaiObj    := FwEaiObj():New()
Local oNFEaiObj    := Nil
Local aPedVen      := {}
Local aNfSaid      := {}
Local aRetSale     := {}
Local cRetSaleId   := ""    
Local cForn        := ""
Local cLoja        := ""
Local cTpDoc       := ""
Local cQry         := ""
Local aDocPai      := {}
Local aRatCC       := {}
Local aRatPrj      := {}
Local nNF          := 0
    
//Vendda com Pedido do Tipo Retira
oFwEaiObj:Activate()
oFwEaiObj:SetEvent("upsert")

If Empty(AllTrim(SL1->L1_ORCRES)) //Cancelamento de Venda

    Aadd(aDocPai,SL1->L1_DOCPED)
    Aadd(aDocPai,SL1->L1_SERPED)
    Aadd(aDocPai,LJI7AboPDV(SL1->L1_FILIAL,SL1->L1_SERPED))

    //Busca o L1_ORCRES com base no L1_NUM - pois no cancelamento vem o orçamento PAI
    cQry := "SELECT"
    cQry += " R_E_C_N_O_ RECSL1 "
    cQry += " FROM " + RetSqlName("SL1")
    cQry += " WHERE "
    cQry += " L1_FILIAL = '" + SL1->L1_FILIAL + "'"
    cQry += " AND L1_ORCRES = '" + SL1->L1_NUM + "' "
    cQry := ChangeQuery(cQry)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TBL1ORC",.T.,.T.)
	
	If ("TBL1ORC")->(Eof())
        ConOut("SL1 não encontrada - orçamento filho não encontrado")
        LjGrvLog("LOJI701ABO", "SL1 não encontrada - orçamento filho não encontrado")
    Else
        cTpDoc := "C"
        SL1->(DBGoTo(("TBL1ORC")->RECSL1))

        //Busca a venda
        aPedVen := LJI7ABVend(SL1->L1_NUM,cTpDoc,SL1->L1_DOC,SL1->L1_SERIE)
    EndIf
Else
    cQry := "SELECT"
    cQry += " L1_FILIAL,L1_DOCPED,L1_SERPED,L1_PDV "
    cQry += " FROM " + RetSqlName("SL1")
    cQry += " WHERE "
    cQry += " L1_FILIAL = '" + SL1->L1_FILIAL + "'"
    cQry += " AND L1_NUM = '" + SL1->L1_ORCRES + "' "
    cQry := ChangeQuery(cQry)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TBL1ORC",.T.,.T.)

    If ("TBL1ORC")->(Eof())
        ConOut("SL1 não encontrada - DOCPED Não associada")
        LjGrvLog("LOJI701ABO", "SL1 não encontrada - DOCPED Não associada")
    Else
        Aadd(aDocPai,("TBL1ORC")->L1_DOCPED)
        Aadd(aDocPai,("TBL1ORC")->L1_SERPED)
        Aadd(aDocPai,LJI7AboPDV(("TBL1ORC")->L1_FILIAL,("TBL1ORC")->L1_SERPED)) //O PDV deve ser da estação atual para chave da XXF bater

        //Busca a venda
        aPedVen := LJI7ABVend(SL1->L1_NUM,cTpDoc)
    EndIf    
EndIf

("TBL1ORC")->(DBCloseArea())

If (Len(aPedVen) > 0) .And. (Len(aDocPai) > 0)
    aItens   := aPedVen[1][7]
    aRatCC   := aPedVen[1][8]
    aRatPrj  := aPedVen[1][9]
    cForn    := Separa(aPedVen[1][4], "|")[1]
    cLoja    := Separa(aPedVen[1][4], "|")[2]
    cRetSaleId := IntVendExt( , SL1->L1_FILIAL, aDocPai[2], aDocPai[1], aDocPai[3])[2]
    
    oFwEaiObj:SetProp("InternalId"               , LJI7PdVEx( , , aPedVen[1][1])[2])
    oFwEaiObj:SetProp("CompanyInternalId"        , AllTrim(cEmpAnt) + "|" + AllTrim(cFilAnt))
    oFwEaiObj:SetProp("CompanyId"                , AllTrim(cEmpAnt)            )
    oFwEaiObj:SetProp("BranchId"                 , AllTrim(cFilAnt)            )
    oFwEaiObj:SetProp("Number"                   , AllTrim(aPedVen[1][1])      )
    oFwEaiObj:SetProp("Status"                   , AllTrim(aPedVen[1][6])      )
    oFwEaiObj:SetProp("TraceabilityCode"         , AllTrim(aPedVen[1][10])     )
    oFwEaiObj:SetProp("RegisterDate"             , AllTrim( Transform(DtoS(aPedVen[1][2]), "@R 9999-99-99") )    )
    oFwEaiObj:SetProp("DeliveryDate"             , AllTrim( Transform(DtoS(aPedVen[1][3]), "@R 9999-99-99") )    )
    oFwEaiObj:SetProp("CustomerVendorInternalId" , IntCliExt( , , cForn, cLoja)[2])
    oFwEaiObj:SetProp("Value"                    , cValToChar(aPedVen[1][5]) )
    oFwEaiObj:SetProp("Type"                     , "001" )
    oFwEaiObj:SetProp("RetailSalesInternalId"    , cRetSaleId)
    
    //Carrega itens do pedido
    CarItens(aItens  , aRatCC  , aRatPrj , "PV"     , aPedVen[1][1],;
            /*cSer*/, /*cCli*/, /*cLoj*/, @oFwEaiObj)

    oFwEaiObj:SetProp("ReturnTraceability")
    oFwEaiObj:GetPropValue("ReturnTraceability"):SetProp("ListOfTraceability")

    //Carrega as notas de saida
    aNfSaid := LJ7IABNFS(SL1->L1_DOC,SL1->L1_SERIE,SL1->L1_CLIENTE,SL1->L1_LOJA,cTpDoc)

    If Len(aNfSaid) > 0
    
        For nNF:= 1 To Len(aNfSaid)
            aItens   := aNfSaid[nNF][8]
            aRatCC   := aNfSaid[nNF][9]
            aRatPrj  := aNfSaid[nNF][10]
            cForn    := Separa(aNfSaid[nNF][4], "|")[1]
            cLoja    := Separa(aNfSaid[nNF][4], "|")[2]
            
            oNFEaiObj := oFwEaiObj:GetPropValue("ReturnTraceability"):GetPropValue("ListOfTraceability"):SetProp("Invoice", {})
            oNFEaiObj[nNF]:SetProp("InternalId"           , AllTrim(cEmpAnt) + "|" + AllTrim(cFilAnt) + "|" + ;
                            AllTrim(aNfSaid[nNF][1]) + "|" + AllTrim(aNfSaid[nNF][2]) + "|" + AllTrim(cForn) + "|" + AllTrim(cLoja))
            oNFEaiObj[nNF]:SetProp("CompanyInternalId"    , AllTrim(cEmpAnt) + "|" + AllTrim(cFilAnt)            )                    
            oNFEaiObj[nNF]:SetProp("CompanyId"            , AllTrim(cEmpAnt)                                     )
            oNFEaiObj[nNF]:SetProp("BranchId"             , AllTrim(cFilAnt)                                     )
            oNFEaiObj[nNF]:SetProp("Number"               , AllTrim(aNfSaid[nNF][1])                             )
            oNFEaiObj[nNF]:SetProp("Serie"                , AllTrim(aNfSaid[nNF][2])                             )
            oNFEaiObj[nNF]:SetProp("Status"               , AllTrim(aNfSaid[nNF][7])                             )
            oNFEaiObj[nNF]:SetProp("IssueDate"            , AllTrim(Transform(DtoS(aNfSaid[nNF][3]), "@R 9999-99-99")))
            oNFEaiObj[nNF]:SetProp("VendorInternalId"     , IntCliExt( , , cForn, cLoja)[2]                      )
            oNFEaiObj[nNF]:SetProp("Value"                , AllTrim( cValToChar(aNfSaid[nNF][6]) )               )
            oNFEaiObj[nNF]:SetProp("TypeOfDocument"       , AllTrim(aNfSaid[nNF][5])                             )
            oNFEaiObj[nNF]:SetProp("ElectronicAccessKey"  , AllTrim(aNfSaid[nNF][12])                            )
            
            //Carrega itens da nota fiscal
            CarItens(   aItens            , aRatCC, aRatPrj   , "NFS"          , aNfSaid[nNF][1],;
                        aNfSaid[nNF][2]   , cForn , cLoja     , @oNFEaiObj[nNF])

            oNFEaiObj[nNF]:SetProp("ListOfParentInternalId")
            oNFEaiObj[nNF]:GetPropValue("ListOfParentInternalId"):SetProp("ParentInternalId")
            oNFEaiObj[nNF]:GetPropValue("ListOfParentInternalId"):GetPropValue("ParentInternalId"):SetProp("InternalId", LJI7PdVEx( , , aNfSaid[nNF][11])[2] )
            oNFEaiObj[nNF]:GetPropValue("ListOfParentInternalId"):GetPropValue("ParentInternalId"):SetProp("TypeCode"  , "004"  )
        Next nNF
    Endif
    
    aRet[1] := .T.
    aRet[2] := oFwEaiObj
Else        
    LjGrvLog("LOJI701ABO","Dados de Pedido Retira Encontrado ?", aPedVen)
    LjGrvLog("LOJI701ABO","Dados de Orçamento Pai Encontrado ?", aDocPai)
    aRet[1] := .F.
    aRet[2] := "Pedido do tipo Retira não encontrado no Protheus"
    LjGrvLog("LOJI701ABO",aRet[2])
EndIf

FwFreeObj(aPedVen)
FwFreeObj(aNfSaid)
FwFreeObj(aRetSale)
FwFreeObj(aRatCC)
FwFreeObj(aRatPrj)
RestArea(aAreaSL1)
RestArea(aArea)
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CarItens
Carrega os itens da mensagem do Pedido de venda ou da Nota fiscal de saida

@param aItens     - Itens a serem informados
@param aRatCC    - Rateio por centro de custo a ser informado
@param aRatPrj   - Rateio por projeto a ser informado
@param cTipo     - Tipo dos itens a serem carregados
@param cNum         - Numero do peodito ou nota
@param cSer         - Serie da nota
@param cCli         - Cliente da nota
@param cLoj         - Loja do cliente da nota
@param oFwEaiObj - Objeto Eai para ser atualizado com os itens

@return oFwEaiObj - Objeto atualizado com os itens

@author     Rafael Tenorio da Costa 
@since      17/10/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CarItens(aItens , aRatCC, aRatPrj , cTipo    , cNum,;
                          cSer  , cCli  , cLoj    , oFwEaiObj)
Local nItem      := 0
Local nRat       := 0
Local cInterId   := ""
Local oItem      := Nil    
Local oRatCC     := Nil
Local oRatPrj    := Nil

Default cSer     := ""
Default cCli     := ""
Default cLoj     := ""

oFwEaiObj:SetProp("ListOfItem")

If Len(aItens) > 0

    For nItem:= 1 To Len(aItens)
    
        If cTipo == "PV"
            cInterId := LJI7PdVEx( , , cNum, aItens[nItem][1])[2]
        Else
            cInterId :=  AllTrim(cEmpAnt) + "|" + AllTrim(cFilAnt) + "|" + AllTrim(cNum) + "|" + ;
                         AllTrim(cSer) + "|" + AllTrim(cCli) + "|" + AllTrim(cLoj) + "|" + AllTrim(aItens[nItem][1])
        EndIf
        
        oItem := oFwEaiObj:GetPropValue("ListOfItem"):SetProp("Item", {})
        oItem[nItem]:SetProp("InternalId"                , cInterId                )
        oItem[nItem]:SetProp("Number"                    , AllTrim(aItens[nItem][1]) )
        oItem[nItem]:SetProp("ItemInternalId"            , IntProExt( , , aItens[nItem][2])[2] )
        oItem[nItem]:SetProp("UnitofMeasureInternalId"   , IntUndExt( , , aItens[nItem][3])[2])
        oItem[nItem]:SetProp("Quantity"                  , AllTrim( cValToChar(aItens[nItem][4])))
        oItem[nItem]:SetProp("UnitPrice"                 , AllTrim( cValToChar(aItens[nItem][5])))
        oItem[nItem]:SetProp("TotalPrice"                , AllTrim( cValToChar(aItens[nItem][6])))
        oItem[nItem]:SetProp("WarehouseInternalId"       , IntLocExt( , , aItens[nItem][7])[2])        
        oItem[nItem]:SetProp("ListOfApportionCost")
        
        If Len(aRatCC) > 0
            For nRat:= 1 To Len(aRatCC)
            
                If AllTrim(aItens[nItem][1]) == AllTrim(aRatCC[nRat][3])
                    If cTipo == "PV"
                        cInterId := LJI7PdVEx( , , cNum, aRatCC[nRat][3])[2]
                    Else
                        cInterId := AllTrim(cEmpAnt) + "|" + AllTrim(cFilAnt) + "|" + AllTrim(cNum) + "|" +;
                                     AllTrim(cSer) + "|" + AllTrim(cCli) + "|" + AllTrim(cLoj) + "|" + AllTrim(aRatCC[nRat][3]) 
                    EndIf
                    
                    oRatCC := oItem[nItem]:GetPropValue("ListOfApportionCost"):SetProp("ApportionCost", {})                    
                    oRatCC[nRat]:SetProp("InternalId"            , cInterId )
                    oRatCC[nRat]:SetProp("CostCenterInternalId"  , IntCusExt( , , aRatCC[nRat][1])[2] )
                    oRatCC[nRat]:SetProp("Percentual"            , AllTrim(cValToChar(aRatCC[nRat][2])))
                EndIf
            Next nRat
        EndIf
            
        oItem[nItem]:SetProp("ListOfApportionTask")
        
        If Len(aRatPrj) > 0
            For nRat:= 1 To Len(aRatPrj)

                If AllTrim(aItens[nItem][2]) == AllTrim(aRatPrj[nRat][4])
                    oRatPrj := oItem[nItem]:GetPropValue("ListOfApportionTask"):SetProp("ApportionTask", {})                                            
                    oRatPrj[nRat]:SetProp("InternalId"           , IntProExt( , , aRatPrj[nRat][4])[2]                                        )
                    oRatPrj[nRat]:SetProp("ProjectInternalId"    , IntPrjExt( , , aRatPrj[nRat][1])[2]                                        )
                    oRatPrj[nRat]:SetProp("SubProjectInternalId" , ""                                                                        )
                    oRatPrj[nRat]:SetProp("TaskInternalId"       , IntTrfExt( , , aRatPrj[nRat][1], aRatPrj[nRat][5], aRatPrj[nRat][2])[2]    )
                    oRatPrj[nRat]:SetProp("Quantity"             , AllTrim( cValToChar(aRatPrj[nRat][3]) )                                    )
                EndIf
            Next nRat
        EndIf
    Next nItem
EndIf

Return oFwEaiObj

//-------------------------------------------------------------------
/*/{Protheus.doc} LJI7PdVEx
Monta o InternalID do Pedido de Venda ou dos itens de acordo
com os parâmetros passados

@param   cEmpresa Código da empresa (Default cEmpAnt)
@param   cFil     Código da Filial (Default xFilial(SL1))
@param   cNum     Número do Pedido de Venda
@param   cItem    Item do Pedido de Venda
@param   cVersao  Versão da mensagem única (Default 3.002)

@author  Julio Nery
@version P12
@since   24/09/2020
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado.
         No segundo parâmetro uma variável string com o InternalID
         montado.

@sample  LJI7PdVEx(,,'0001','01') irá retornar {.T.,'01|01|00001|001|2'}
/*/
//-------------------------------------------------------------------
Function LJI7PdVEx(cEmpresa, cFil, cNum, cItem, cVersao)
Local   aResult  := {}
Local   cTemp    := ""

Default cEmpresa := cEmpAnt
Default cFil     := FWxFilial('SL1')
Default cVersao  := '3.002'

If cVersao = "1."
    cTemp := cFil + cNum
    aAdd(aResult, .T.)
    aAdd(aResult, cTemp)
ElseIf cVersao = "3." .OR. cVersao = "4."
    If Empty(cItem)
        // Montagem do InternalId de cabeçalho (SL1)
        cTemp := cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cNum) + "|2"
    Else
        // Montagem do InternalId do item (SL2)
        cFil  := xFilial('SL2')
        cTemp := cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cNum) + "|" + RTrim(cItem) + "|2"
    EndIf
    aAdd(aResult, .T.)
    aAdd(aResult, cTemp)
Else
    aAdd(aResult, .F.)
    aAdd(aResult, "Versão do Pedido Retira não suportada." + Chr(10) +;
                "As versões suportadas são: " + "1.~, 3.~, 4.~") //"Versão do Pedido de Venda não suportada." "As versões suportadas são: "
EndIf
Return aResult

/*/{Protheus.doc} LJI7ABVend()
    Busca Orçamento
@param    cNumero    Numero do Orcamento
@author Julio Nery
@since 22/09/2020
@version 12
/*/
Function LJI7ABVend(cNumero,cTpDoc,cDoc,cSerie)
Local aArea        := GetArea()
Local aAreaSL1     := SL1->(GetArea())
Local aAreaSL2     := SL2->(GetArea())
Local aRet         := {}
Local aItens       := {}
Local aRatCC       := {}
Local aRatPrj      := {}
Local nTotal       := 0
Local cQry         := ""
Local cSituacao    := ""
Local cAlias       := ""

Default cTpDoc     := ""
Default cDoc       := ""
Default cSerie     := "" 

//Cabeçalho
cQry := " SELECT "
cQry += " L2_ITEM, L2_PRODUTO, L2_UM, L2_QUANT,"
cQry += " Round(L2_VRUNIT, 2) AS L2_VRUNIT,"
cQry += " Round(L2_VLRITEM, 2) AS L2_VLRITEM,L2_LOCAL, L2_ORCRES"
cQry += " FROM " + RetSqlName("SL2")
cQry += " WHERE "
cQry += " L2_NUM = '" + cNumero + "'"

//Quando cancela a SL2 esta deletada com informações de DOC/SERIE
//por isso só considera o Deletado no momento da finalização da venda e orçamento
If cTpDoc == "C"
    cQry += " AND L2_DOC ='" + cDoc + "' "
    cQry += " AND L2_SERIE = '" + cSerie + "'"
Else
    cQry += " AND D_E_L_E_T_ = '' "
EndIf
cQry += " AND L2_ENTREGA = '1' "
cQry := ChangeQuery(cQry)
LjGrvLog("LOJI701AB","[LJI7ABVend] Query a ser executada ->", cQry)

cAlias := "SSL1L2"
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAlias,.T.,.T.)

DbSelectArea(cAlias)
If (cAlias)->(EOF())
    LjGrvLog("LOJI701AB","Não foram encontrados dados da SL2 do tipo Retira (L2_RESERVA = '1') para o orçamento " + cNumero)
Else
    While (cAlias)->(!EOF())
        aAdd(aItens,{   (cAlias)->L2_ITEM, (cAlias)->L2_PRODUTO, (cAlias)->L2_UM, (cAlias)->L2_QUANT,;
                        (cAlias)->L2_VRUNIT,(cAlias)->L2_VLRITEM,(cAlias)->L2_LOCAL})
        
        nTotal += (cAlias)->L2_VLRITEM
        (cAlias)->(DbSkip())
    Enddo

    cSituacao := LJI7ABSitu(cTpDoc)

    aAdd(aRet, {cNumero,;
                SL1->L1_EMISSAO,;
                SL1->L1_DTLIM,;
                SL1->L1_CLIENTE+"|"+SL1->L1_LOJA,;
                nTotal,;
                cSituacao,;
                aItens,;
                aRatCC,;
                aRatPrj,;
                "",; //Campo em branco pois não existe referencia de rastreio, pois eh um pedido RETIRA
                SL1->L1_FILIAL,;                
                cNumero } )

    aItens := {}
    aRatCC := {}
    aRatPrj:= {}
Endif

(cAlias)->(DbCloseArea())
RestArea(aAreaSL1)
RestArea(aAreaSL2)
RestArea(aArea)

Return aRet

/*/{Protheus.doc} LJI7ABTAB(cTab)
    Verifica dados compartilhamento da tabela
    @param    cTab        Alias da tabela
    @retorno lRet        .T. - Se for exclusiva, .F. - compartilhado
    @author    Julio Nery
    @version   P12
    @since    23/09/2020
/*/
Static Function LJI7ABTAB(cTab)
Local lRet    := .F.
lRet := ( (FWModeAccess(cTab,1) == 'E') .Or. (FWModeAccess(cTab,2) == 'E') .Or. (FWModeAccess(cTab,3) == 'E') )
Return lRet

/*/{Protheus.doc} LJI7ABSitu()
Busca situação da PV/NFS

@param  cTipo    Tipo do documento
@param  cNumero  Numero da PV/NFS 
@author Julio Nery
@since 23/09/2020
@version 12
/*/
Static Function LJI7ABSitu(cTipo)
Local cQry         := ""
Local cSituacao    := ""
Local lExistFornec := SF2->(ColumnPos("F2_FORNECE")) > 0
Local lL1Doc       := Empty(AllTrim(SL1->L1_DOC))
Local lL1Serie     := Empty(AllTrim(SL1->L1_SERIE))
Local cMotivo      := ""

Default cTipo := ""

If lL1Doc .And. lL1Serie .And. !Empty(AllTrim(SL1->L1_ORCRES))

    If AllTrim(cTipo) == "C" //Cancelamento de Orçamento Não Finalizado
        cSituacao := "Cancelado"

    ElseIf AllTrim(SL1->L1_ECFLAG) == "P"
        cSituacao := "Aberto"
    
    ElseIf AllTrim(SL1->L1_ECFLAG) == "O"
        cSituacao := "Empacotado"
    EndIf

ElseIf !lL1Doc .And. !lL1Serie
    
    cQry := " SELECT F2_CHVNFE"
    cQry += " FROM " + RetSqlName("SF2") + " F2"
    cQry += " WHERE  F2.D_E_L_E_T_ = ' '"
    cQry += " AND F2.F2_DOC = '" + SL1->L1_DOC + "'"
    cQry += " AND F2.F2_SERIE = '" + SL1->L1_SERIE + "'"
    If lExistFornec
        cQry += " AND F2.F2_FORNECE = '" + SL1->L1_CLIENTE + "'"
    Else    
        cQry += " AND F2.F2_CLIENTE = '" + SL1->L1_CLIENTE + "'"
    EndIf
    cQry += " AND F2.F2_LOJA = '" + SL1->L1_LOJA + "'"
    
    If LJI7ABTAB("SF2")
        cQry += " AND F2.F2_FILIAL = '" + xFilial("SF2") + "'"
    Endif
    
    cQry := ChangeQuery(cQry)
    LjGrvLog("LJI7ABSitu","Query a ser executada ->", cQry)
        
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"SIT",.T.,.T.)
    
    DbSelectArea("SIT")
    If SIT->(EOF())
        If cTipo == "C"
            cSituacao := "Cancelado"
            cMotivo := "Venda Cancelada"
        Else
            cSituacao := "Empacotado"
            cMotivo   := "Possivelmente: esta venda teve dados da SF2 deletados e a SL1/SL2/SL4 não foram canceladas"
        EndIf

        LjGrvLog("LJI7ABSitu","Não foi encontrada Nota de Saída (SF2) para esta venda - Doc (L1_DOC) [" +;
                    SL1->L1_DOC + "] - Serie (L1_SERIE) [" + SL1->L1_SERIE + "] - Motivo:", cMotivo)
    Else
        If cTipo == "C" //Cancelamento
            cSituacao := "Cancelado"
        Else
            cSituacao := "Entregue"
        EndIf
    Endif
    SIT->(DbCloseArea())
Endif

Return cSituacao

/*/{Protheus.doc} LJ7IABNFS()
Busca NFs + Itens + Rateio Projeto + Rateio Centro Custo

@author Rodrigo M. Pontes 
@since 24/09/2020
@version 12
/*/
Function LJ7IABNFS(cDoc,cSerie,cCliente,cLoja,cTpDoc)
Local aAreaSF2	    := SF2->(GetArea())
Local aAreaSD2	    := SD2->(GetArea())
Local aAreaAGH	    := AGH->(GetArea())
Local aAreaAFS	    := AFS->(GetArea())
Local aRet			:= {}
Local aItens		:= {}
Local aRatCC		:= {}
Local aRatPrj		:= {}
Local cQry			:= ""
Local cSituacao     := ""
Local cFilialF2     := xFilial("SF2")
Local cFilialD2     := xFilial("SD2")
Local cFilialAGH	:= xFilial("AGH")
Local cFilialAFS	:= xFilial("AFS")
Local lTabSF2Exc	:= LJI7ABTAB("SF2")
Local lTabSD2Exc	:= LJI7ABTAB("SD2")
Local lTabAGHExc	:= LJI7ABTAB("AGH")
Local lTabAFSExc	:= LJI7ABTAB("AFS")
Local lExistFornec  := SD2->(ColumnPos("D2_FORNECE")) > 0 .AND. AGH->(ColumnPos("AGH_FORNEC")) > 0 

Default cTpDoc      := ""

//Cabeçalho da NF Saida
cQry := " SELECT F2_DOC,F2_SERIE,F2_EMISSAO,F2_CLIENTE,"
cQry += " F2_LOJA, F2_TIPO, Round(F2_VALBRUT, 2) AS F2_VALBRUT,F2_CHVNFE"	
cQry += " FROM " + RetSqlName("SF2" ) + " F2"
cQry += " WHERE "
If lTabSF2Exc
    cQry += " F2.F2_FILIAL = '" + cFilialF2 + "' AND "
Endif
cQry += " F2.F2_DOC = '" + cDoc + "'"
cQry += " AND F2.F2_SERIE = '" + cSerie + "'"
cQry += " AND F2.F2_CLIENTE = '" + cCliente + "'"
cQry += " AND F2.F2_LOJA = '" + cLoja + "'"
cQry += " AND F2.D_E_L_E_T_ = ''"

cQry := ChangeQuery(cQry)
LjgrvLog("LOJI701AB","[LJ7IABNFS] Query a ser executada ->",cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"CABEC",.T.,.T.)
TcSetField("CABEC","F2_EMISSAO","D")

DbSelectArea("CABEC")
If CABEC->(EOF())
    LjgrvLog("LOJI701AB","Nenhum SF2 encontrado para a venda (SL1) Doc+Serie+Cliente+Loja ->",{cDoc,cSerie,cCliente,cLoja})
Else 
    cSituacao := LJI7ABSitu(cTpDoc)
    
    //Itens da NF Saida
    cQry := " SELECT "
    cQry += " D2_ITEM,D2_COD,D2_UM,D2_QUANT,"
    cQry += " D2_PRCVEN,D2_TOTAL,D2_LOCAL"
    cQry += " FROM " + RetSqlName("SD2") + " D2"
    cQry += " WHERE  "
    cQry += " D2.D2_DOC = '" + CABEC->F2_DOC + "'"
    cQry += " AND D2.D2_SERIE = '" + CABEC->F2_SERIE + "'"
    If lExistFornec
        cQry += " AND D2.D2_FORNECE = '" + CABEC->F2_FORNECE + "'"
    EndIf			
    cQry += " AND D2.D2_LOJA = '" + CABEC->F2_LOJA + "'"
    
    If lTabSD2Exc
        cQry += " AND D2.D2_FILIAL = '" + cFilialD2 + "'"
    Endif

    cQry := ChangeQuery(cQry)
    LjGrvLog("LOJI701AB","[LJ7IABNFS] Query a ser executada ->", cQry)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"ITENS",.T.,.T.)

    DbSelectArea("ITENS")
    If ITENS->(Eof())
        LjGrvLog("LOJI701AB","Nenhum dado de SD2 encontrado")
    EndIf

    While ITENS->(!EOF())
        aAdd(aItens,{ITENS->D2_ITEM,ITENS->D2_COD,ITENS->D2_UM,ITENS->D2_QUANT,ITENS->D2_PRCVEN,ITENS->D2_TOTAL,ITENS->D2_LOCAL})
        ITENS->(DbSkip())
    Enddo
    ITENS->(DbCloseArea())

    //Rateio Centro de Custo
    cQry := " SELECT "
    cQry += " AGH_ITEMPD,AGH_CC,Sum(AGH_PERC) AS PERC"
    cQry += " FROM " + RetSqlName("AGH") + " AGH"
    cQry += " WHERE  AGH.D_E_L_E_T_ = ''"
    cQry += " AND AGH.AGH_NUM = '" + CABEC->F2_DOC + "'"
    cQry += " AND AGH.AGH_SERIE = '" + CABEC->F2_SERIE + "'"
    If lExistFornec
        cQry += " AND AGH.AGH_FORNEC = '" + CABEC->F2_FORNECE + "'"
    EndIf	
    cQry += " AND AGH.AGH_LOJA = '" + CABEC->F2_LOJA + "'"
    
    If lTabAGHExc
        cQry += " AND AGH.AGH_FILIAL = '" + cFilialAGH + "'"
    Endif
    
    cQry += " GROUP  BY AGH.AGH_ITEMPD, AGH.AGH_CC"
    cQry := ChangeQuery(cQry)
    LjGrvLog("LOJI701AB","[LJ7IABNFS] Query a ser executada ->", cQry)

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"RATCC",.T.,.T.)

    DbSelectArea("RATCC")
    If RATCC->(Eof())
        LjGrvLog("LOJI701AB","Nenhum dado de AGH encontrado")
    EndIf

    While RATCC->(!EOF())
        aAdd(aRatCC,{RATCC->AGH_CC,RATCC->PERC,RATCC->AGH_ITEMPD})
        RATCC->(DbSkip())
    Enddo
    RATCC->(DbCloseArea())

    //Rateio Projeto
    cQry := " SELECT "
    cQry += " AFS_COD,AFS_PROJET,AFS_TAREFA,AFS_QUANT,AFS_REVISA"
    cQry += " FROM " + RetSqlName("AFS") + " AFS"
    cQry += " WHERE  AFS.D_E_L_E_T_ = ''"
    cQry += "        AND AFS.AFS_DOC = '" + CABEC->F2_DOC + "'"
    cQry += "        AND AFS.AFS_SERIE = '" + CABEC->F2_SERIE + "'"
    
    If lTabAFSExc
        cQry += "    AND AFS.AFS_FILIAL = '" + cFilialAFS + "'"
    Endif
    
    cQry += " GROUP BY "
    cQry += " AFS_COD,AFS_PROJET,AFS_TAREFA,AFS_QUANT,AFS_REVISA"
    cQry := ChangeQuery(cQry)
    LjGrvLog("LOJI701AB","[LJ7IABNFS] Query a ser executada ->", cQry)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"RATPRJ",.T.,.T.)

    DbSelectArea("RATPRJ")
    If RATPRJ->(Eof())
        LjGrvLog("LOJI701AB","Nenhum dado de AFS encontrado")
    EndIf
    While RATPRJ->(!EOF())
        aAdd(aRatPrj,{RATPRJ->AFS_PROJET,RATPRJ->AFS_TAREFA,RATPRJ->AFS_QUANT,RATPRJ->AFS_COD,RATPRJ->AFS_REVISA})
        RATPRJ->(DbSkip())
    Enddo
    RATPRJ->(DbCloseArea())

    aAdd(aRet, {CABEC->F2_DOC,;
                CABEC->F2_SERIE,;
                CABEC->F2_EMISSAO,;
                CABEC->F2_CLIENTE+"|"+CABEC->F2_LOJA,;
                CABEC->F2_TIPO,;
                CABEC->F2_VALBRUT,;
                cSituacao,;
                aItens,;
                aRatCC,;
                aRatPrj,;
                CABEC->F2_DOC,;
                CABEC->F2_CHVNFE})

    aItens	:= {}
    aRatCC	:= {}
    aRatPrj	:= {}
Endif

CABEC->(DbCloseArea())
RestArea(aAreaSF2)
RestArea(aAreaSD2)
RestArea(aAreaAGH)
RestArea(aAreaAFS)

Return aRet

/*/{Protheus.doc} LJI7AboPDV
    Retorna o numero de PDV da estação de acordo com a série recebida
    @type  Static Function
    @author Julio.Nery
    @since 08/10/2020
    @version 12
    @param cFilial, string, filial para pesquisa
    @param cSerie, string, serie para pesquisa
    @return cPDV, string, Numero do PDV
/*/
Static Function LJI7AboPDV(cFilTab,cSerie)
Local cQry := ""
Local cPDV := ""

cQry := "SELECT"
cQry += " LG_PDV "
cQry += " FROM " + RetSqlName("SLG")
cQry += " WHERE "
cQry += " LG_FILIAL = '" + cFilTab + "' AND LG_SERIE ='" + cSerie + "'"
cQry := ChangeQuery(cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"PDVSLG",.T.,.T.)

If ("PDVSLG")->(Eof())
    LjGrvLog('LOJI701ABO',"PDV não encontrada na SLG - será inserida o PDV da estação atual. " + ;
            " Cadastre uma estação com a mesma Série do orçamento informado, se atentando ao PDV" + ;
            " do pedido de integração para que seja possível encontrar os dados de estação de origem " + ;
            " -> Serie Recebida [" + AllTrim(cSerie) + "]")
    cPDV := SLG->LG_PDV
Else
    cPDV := ("PDVSLG")->LG_PDV
EndIf

("PDVSLG")->(DBCloseArea())

Return cPDV

//-------------------------------------------------------------------
/*{Protheus.doc} L701aBoEai
Funcao para chamada do adapter LOJI701A que envia a chave da NFe. 
A chamada desta funcao esta no autoNfeBusines.

@type   function
@param cEmpant, Carectere, Empresa corrente
@param cFilAnt, Carectere, Filial corrente
@param cDoc, Carectere, Número da Nota Fiscal Autorizada pela Sefaz
@param cSerie, Carectere, Serie da Nota Fiscal Autorizada pela Sefaz

@author Rafael Tenorio da Costa
@since  22/09/2021
*/
//-------------------------------------------------------------------
Function L701aBoEai(cEmpEai, cFilEai, cDoc, cSerie)

    Local aRetorno := {}
    Local aAreaSL1 := {}
    Local cTipent  := ""

    RpcSetType(3)
    RpcSetEnv(cEmpEai, cFilEai, /*cEnvUser*/, /*cEnvPass*/, "LOJ", "L701aBoEai")    

    
    SL1->( DbSetOrder(2) )  //L1_FILIAL, L1_SERIE, L1_DOC, L1_PDV
    If SL1->( DbSeek(xFilial("SL1") + cSerie + cDoc) )

        //Envio rastreabilidade de venda retira posterior
        If FwHasEAI("LOJI701A", .T., /*lVerifyRec*/, .T., /*lRestArea*/)
            LjGrvLog("L701aBoEai", "Processando mensagem DOCUMENTTRACEABILITYORDERRETAIL.", {cDoc, cSerie})
                aRetorno := FwIntegDef("LOJI701A", /*cTypeMessage*/, /*cType*/, /*cXml*/, /*cFunName*/, /*lOnlyReturn*/, /*cVersion*/)            
        EndIf
        If AliasInDic("MHQ") .AND. ExistFunc("RmiExeGat") .AND. ExistFunc("SHPStatus") 
            DbSelectArea("MHQ")
            If (!Empty(SL1->L1_UMOV) .AND. !Empty(Posicione("MHQ",7,xFilial("MHQ")+SL1->L1_UMOV,"MHQ_CHVUNI"))) 
                cTipent := Posicione("SL2",1,xFilial("SL2")+SL1->L1_NUM,"L2_ENTREGA")   
                aAreaSL1 := SL1->(GetArea())
                //Atualiza o pedido pai tambem
                SL1->(DbSetOrder(1)) //L1_FILIAL + L1_NUM
                If SL1->(DBSeek(SL1->L1_FILIAL+SL1->L1_ORCRES))    
                    //Publica processo STATUS PEDIDO
                    If cTipent == "1"
                        SHPStatus("order_delivered")        
                    ElseIf cTipent == "3"
                        SHPStatus("packaged")
                    EndIf

                EndIf
                RestArea(aAreaSL1)
            EndIf
            MHQ->(DBCLOSEAREA())
        EndIf
    EndIf
    FwFreeArray(aRetorno)

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} v1001
Efetuar o envio da menaagem unica contendo dados XML da SEFAZ.

@param oEaiObjEnt    - Objeto Eai de entrada
@param nTypeTrans    - Tipo de transacao. (Envio/Recebimento)
@param cTypeMessage    - Tipo de mensagem. (Business Type, WhoIs, etc)

@retorno aRet        - Array contendo o resultado da execucao e Dados da SEFAZ.
            aRet[1]    (boolean)    - Indica o resultado da execução da função
            aRet[2]    (FwObjEai)     - Objeto FwObjEai utilizado para o envio

@author     Everson S P Junior
@since      25/09/20
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function v1001(oEaiObjEnt, nTypeTrans, cTypeMessage)
Local aArea        := GetArea()
Local aAreaSL1     := SL1->(GetArea())
Local aRet         := {.T., ""}
Local oFwEaiObj    := FwEaiObj():New()
Local oNFEaiObj    := Nil
Local aPedVen      := {}
Local aNfSaid      := {}
Local aRetSale     := {}
Local cRetSaleId   := ""    
Local cForn        := ""
Local cLoja        := ""
Local cTpDoc       := ""
Local cQry         := ""
Local aDocPai      := {}
Local aRatCC       := {}
Local aRatPrj      := {}
Local nNF          := 0
Local oTssNfce     := LOJGNFCE():new()
Local lExistMeth := MethIsMemberOf(oTssnfce,"LjRetornaNotas")	
Local aRetTssNfce  := {}
    
//Vendda com Pedido do Tipo Retira
oFwEaiObj:Activate()
oFwEaiObj:SetEvent("upsert")

If Empty(AllTrim(SL1->L1_ORCRES)) //Cancelamento de Venda

    Aadd(aDocPai,SL1->L1_DOCPED)
    Aadd(aDocPai,SL1->L1_SERPED)
    Aadd(aDocPai,LJI7AboPDV(SL1->L1_FILIAL,SL1->L1_SERPED))

    //Busca o L1_ORCRES com base no L1_NUM - pois no cancelamento vem o orçamento PAI
    cQry := "SELECT"
    cQry += " R_E_C_N_O_ RECSL1 "
    cQry += " FROM " + RetSqlName("SL1")
    cQry += " WHERE "
    cQry += " L1_FILIAL = '" + SL1->L1_FILIAL + "'"
    cQry += " AND L1_ORCRES = '" + SL1->L1_NUM + "' "
    cQry := ChangeQuery(cQry)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TBL1ORC",.T.,.T.)
	
	If ("TBL1ORC")->(Eof())
        ConOut("SL1 não encontrada - orçamento filho não encontrado")
        LjGrvLog("LOJI701ABO", "SL1 não encontrada - orçamento filho não encontrado")
    Else
        cTpDoc := "C"
        SL1->(DBGoTo(("TBL1ORC")->RECSL1))

        //Busca a venda
        aPedVen := LJI7ABVend(SL1->L1_NUM,cTpDoc,SL1->L1_DOC,SL1->L1_SERIE)
    EndIf
Else
    cQry := "SELECT"
    cQry += " L1_FILIAL,L1_DOCPED,L1_SERPED,L1_PDV "
    cQry += " FROM " + RetSqlName("SL1")
    cQry += " WHERE "
    cQry += " L1_FILIAL = '" + SL1->L1_FILIAL + "'"
    cQry += " AND L1_NUM = '" + SL1->L1_ORCRES + "' "
    cQry := ChangeQuery(cQry)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TBL1ORC",.T.,.T.)

    If ("TBL1ORC")->(Eof())
        ConOut("SL1 não encontrada - DOCPED Não associada")
        LjGrvLog("LOJI701ABO", "SL1 não encontrada - DOCPED Não associada")
    Else
        Aadd(aDocPai,("TBL1ORC")->L1_DOCPED)
        Aadd(aDocPai,("TBL1ORC")->L1_SERPED)
        Aadd(aDocPai,LJI7AboPDV(("TBL1ORC")->L1_FILIAL,("TBL1ORC")->L1_SERPED)) //O PDV deve ser da estação atual para chave da XXF bater

        //Busca a venda
        aPedVen := LJI7ABVend(SL1->L1_NUM,cTpDoc)
    EndIf    
EndIf

("TBL1ORC")->(DBCloseArea())

If (Len(aPedVen) > 0) .And. (Len(aDocPai) > 0)
    aItens   := aPedVen[1][7]
    aRatCC   := aPedVen[1][8]
    aRatPrj  := aPedVen[1][9]
    cForn    := Separa(aPedVen[1][4], "|")[1]
    cLoja    := Separa(aPedVen[1][4], "|")[2]
    cRetSaleId := IntVendExt( , SL1->L1_FILIAL, aDocPai[2], aDocPai[1], aDocPai[3])[2]
    
    oFwEaiObj:SetProp("InternalId"               , LJI7PdVEx( , , aPedVen[1][1])[2])
    oFwEaiObj:SetProp("CompanyInternalId"        , AllTrim(cEmpAnt) + "|" + AllTrim(cFilAnt))
    oFwEaiObj:SetProp("CompanyId"                , AllTrim(cEmpAnt)            )
    oFwEaiObj:SetProp("BranchId"                 , AllTrim(cFilAnt)            )
    oFwEaiObj:SetProp("Number"                   , AllTrim(aPedVen[1][1])      )
    oFwEaiObj:SetProp("Status"                   , AllTrim(aPedVen[1][6])      )
    oFwEaiObj:SetProp("TraceabilityCode"         , AllTrim(aPedVen[1][10])     )
    oFwEaiObj:SetProp("RegisterDate"             , AllTrim( Transform(DtoS(aPedVen[1][2]), "@R 9999-99-99") )    )
    oFwEaiObj:SetProp("DeliveryDate"             , AllTrim( Transform(DtoS(aPedVen[1][3]), "@R 9999-99-99") )    )
    oFwEaiObj:SetProp("CustomerVendorInternalId" , IntCliExt( , , cForn, cLoja)[2])
    oFwEaiObj:SetProp("Value"                    , cValToChar(aPedVen[1][5]) )
    oFwEaiObj:SetProp("Type"                     , "001" )
    oFwEaiObj:SetProp("RetailSalesInternalId"    , cRetSaleId)
    
    //Carrega itens do pedido
    CarItens(aItens  , aRatCC  , aRatPrj , "PV"     , aPedVen[1][1],;
            /*cSer*/, /*cCli*/, /*cLoj*/, @oFwEaiObj)

    oFwEaiObj:SetProp("ReturnTraceability")
    oFwEaiObj:GetPropValue("ReturnTraceability"):SetProp("ListOfTraceability")

    //Carrega as notas de saida
    aNfSaid := LJ7IABNFS(SL1->L1_DOC,SL1->L1_SERIE,SL1->L1_CLIENTE,SL1->L1_LOJA,cTpDoc)

    If Len(aNfSaid) > 0
    
        For nNF:= 1 To Len(aNfSaid)
            aItens   := aNfSaid[nNF][8]
            aRatCC   := aNfSaid[nNF][9]
            aRatPrj  := aNfSaid[nNF][10]
            cForn    := Separa(aNfSaid[nNF][4], "|")[1]
            cLoja    := Separa(aNfSaid[nNF][4], "|")[2]
            
            oNFEaiObj := oFwEaiObj:GetPropValue("ReturnTraceability"):GetPropValue("ListOfTraceability"):SetProp("Invoice", {})
            oNFEaiObj[nNF]:SetProp("InternalId"           , AllTrim(cEmpAnt) + "|" + AllTrim(cFilAnt) + "|" + ;
                            AllTrim(aNfSaid[nNF][1]) + "|" + AllTrim(aNfSaid[nNF][2]) + "|" + AllTrim(cForn) + "|" + AllTrim(cLoja))
            oNFEaiObj[nNF]:SetProp("CompanyInternalId"    , AllTrim(cEmpAnt) + "|" + AllTrim(cFilAnt)            )                    
            oNFEaiObj[nNF]:SetProp("CompanyId"            , AllTrim(cEmpAnt)                                     )
            oNFEaiObj[nNF]:SetProp("BranchId"             , AllTrim(cFilAnt)                                     )
            oNFEaiObj[nNF]:SetProp("Number"               , AllTrim(aNfSaid[nNF][1])                             )
            oNFEaiObj[nNF]:SetProp("Serie"                , AllTrim(aNfSaid[nNF][2])                             )
            oNFEaiObj[nNF]:SetProp("Status"               , AllTrim(aNfSaid[nNF][7])                             )
            oNFEaiObj[nNF]:SetProp("IssueDate"            , AllTrim(Transform(DtoS(aNfSaid[nNF][3]), "@R 9999-99-99")))
            oNFEaiObj[nNF]:SetProp("VendorInternalId"     , IntCliExt( , , cForn, cLoja)[2]                      )
            oNFEaiObj[nNF]:SetProp("Value"                , AllTrim( cValToChar(aNfSaid[nNF][6]) )               )
            oNFEaiObj[nNF]:SetProp("TypeOfDocument"       , AllTrim(aNfSaid[nNF][5])                             )
            oNFEaiObj[nNF]:SetProp("ElectronicAccessKey"  , AllTrim(aNfSaid[nNF][12])                            )
            
            //Carrega itens da nota fiscal
            CarItens(   aItens            , aRatCC, aRatPrj   , "NFS"          , aNfSaid[nNF][1],;
                        aNfSaid[nNF][2]   , cForn , cLoja     , @oNFEaiObj[nNF])

            oNFEaiObj[nNF]:SetProp("ListOfParentInternalId")
            oNFEaiObj[nNF]:GetPropValue("ListOfParentInternalId"):SetProp("ParentInternalId")
            oNFEaiObj[nNF]:GetPropValue("ListOfParentInternalId"):GetPropValue("ParentInternalId"):SetProp("InternalId", LJI7PdVEx( , , aNfSaid[nNF][11])[2] )
            oNFEaiObj[nNF]:GetPropValue("ListOfParentInternalId"):GetPropValue("ParentInternalId"):SetProp("TypeCode"  , "004"  )
            
            If lExistMeth
                oTssnfce:LjRetornaNotas(aNfSaid[nNF][2] + aNfSaid[nNF][1])
                aRetTssNfce := oTssnfce:aResultRetornaNotasNx
            EndIf	

            oNFEaiObj[nNF]:SetProp("DocumentContent")
            oNFEaiObj[nNF]:GetPropValue("DocumentContent"):SetProp("DocumentContentxml")
            oNFEaiObj[nNF]:GetPropValue("DocumentContent"):GetPropValue("DocumentContentxml"):SetProp("Xml",IIF(lExistMeth,Encode64(aRetTssNfce[2]),""))
            oNFEaiObj[nNF]:GetPropValue("DocumentContent"):GetPropValue("DocumentContentxml"):SetProp("ReturnCode",IIF(lExistMeth,aRetTssNfce[3],""))
            oNFEaiObj[nNF]:GetPropValue("DocumentContent"):GetPropValue("DocumentContentxml"):SetProp("XmlAuth",IIF(lExistMeth,Encode64(aRetTssNfce[4]),""))
            oNFEaiObj[nNF]:GetPropValue("DocumentContent"):GetPropValue("DocumentContentxml"):SetProp("StatusCodeSefaz",IIF(lExistMeth,aRetTssNfce[5],"404"))
            oNFEaiObj[nNF]:GetPropValue("DocumentContent"):GetPropValue("DocumentContentxml"):SetProp("StatusContent",IIF(lExistMeth,aRetTssNfce[6],"Aplicar Atualização dos fontes LOJXNFCE e LOJGNFCE com data maior que 11/08/2022"))
        
        Next nNF
    Endif
    
    aRet[1] := .T.
    aRet[2] := oFwEaiObj
Else        
    LjGrvLog("LOJI701ABO","Dados de Pedido Retira Encontrado ?", aPedVen)
    LjGrvLog("LOJI701ABO","Dados de Orçamento Pai Encontrado ?", aDocPai)
    aRet[1] := .F.
    aRet[2] := "Pedido do tipo Retira não encontrado no Protheus"
    LjGrvLog("LOJI701ABO",aRet[2])
EndIf

FwFreeObj(aPedVen)
FwFreeObj(aNfSaid)
FwFreeObj(aRetSale)
FwFreeObj(aRatCC)
FwFreeObj(aRatPrj)
RestArea(aAreaSL1)
RestArea(aArea)
Return aRet
