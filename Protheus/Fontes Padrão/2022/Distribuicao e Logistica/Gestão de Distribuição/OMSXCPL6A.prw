#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OMSXCPL6A.CH"

#DEFINE OMSCPL6A01 "OMSCPL6A01"
#DEFINE OMSCPL6A02 "OMSCPL6A02"
#DEFINE OMSCPL6A03 "OMSCPL6A03"
#DEFINE OMSCPL6A04 "OMSCPL6A04"

// ---------------------------------------------------------
/*/{Protheus.doc} OMSXCPL6A
Tela para integração parcial do pedido de venda.
@author amanda.vieira
@since 15/10/2018
@version 1.0
/*/
// ---------------------------------------------------------
// Esta função é só para o TDS reconhecer o fonte e poder gerar patch
Function OMSXCPL6ADUMMY()
Return .T.
// ---------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definições do modelo
@author amanda.vieira
@since 15/10/2018
@version 1.0
/*/
// ---------------------------------------------------------
Static Function ModelDef()
Local oModel     := MpFormMOdel():New("OMSXCPL6A",  /*bPreValid*/ , {|oModel|ValidMdl(oModel)} , {|oModel|CommitMdl(oModel)} ,/*bCancel*/ )
Local oStruField := FWFormModelStruct():New()
Local oStruGrid  := FWFormModelStruct():New()
Local aColsSX3   := {}
    //Definições do field
    oStruField:AddTable(__oTempTab:oStruct:GetAlias(),{'C6_FILIAL','C6_NUM'},STR0001) // Envio de Pedido
    oStruField:AddField(buscarSX3('C6_NUM' ,,aColsSX3),aColsSX3[1],'C6_NUM'  ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
    oStruField:AddField(buscarSX3('C6_CLI' ,,aColsSX3),aColsSX3[1],'C6_CLI'  ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
    oStruField:AddField(buscarSX3('C6_LOJA',,aColsSX3),aColsSX3[1],'C6_LOJA' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
    oStruField:AddField(buscarSX3('A1_NOME',,aColsSX3),aColsSX3[1],'C6_NMCLI','C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
    //Definições da grid
    oStruGrid:AddTable(__oTempTab:oStruct:GetAlias(),{'C6_FILIAL','C6_NUM','C6_ITEM','C6_PRODUTO'},STR0001) // Envio de Pedido
    oStruGrid:AddField(buscarSX3('C6_FILIAL' ,,aColsSX3),aColsSX3[1],'C6_FILIAL' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
    oStruGrid:AddField(buscarSX3('C6_NUM'    ,,aColsSX3),aColsSX3[1],'C6_NUM'    ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
    oStruGrid:AddField(buscarSX3('C6_ITEM'   ,,aColsSX3),aColsSX3[1],'C6_ITEM'   ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
    oStruGrid:AddField(buscarSX3('C6_PRODUTO',,aColsSX3),aColsSX3[1],'C6_PRODUTO','C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
    oStruGrid:AddField(buscarSX3('B1_DESC'   ,,aColsSX3),aColsSX3[1],'C6_DESPRD' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
    buscarSX3('C6_QTDVEN' ,,aColsSX3)
    oStruGrid:AddField(STR0002,aColsSX3[1],'C6_QTDPED' ,'N',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.F.,.F.,.T.) // Quantidade Pedido
    oStruGrid:AddField(STR0003,aColsSX3[1],'C6_QTDINT' ,'N',aColsSX3[3],aColsSX3[4],{|oModel|VldQtdInt(oModel)},{||.T.},Nil,.F.,Nil,.F.,.F.,.T.) // Quantidade Integração

	oModel:AddFields("MdFieldSC6",Nil,oStruField)
    oModel:SetPrimaryKey({'C6_FILIAL','C6_NUM','C6_ITEM','C6_PRODUTO'})
    oModel:AddGrid("MdGridSC6", "MdFieldSC6", oStruGrid , /*bLinePre*/ , /*bLinePost*/ , /*bPre*/ , /*bPost*/,/*{|oModel|LoadGrid(oModel)}*/)
    oModel:SetActivate({|oModel| ActiveModel(oModel) } )
Return oModel
// ---------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definições da view
@author amanda.vieira
@since 15/10/2018
@version 1.0
/*/
// ---------------------------------------------------------
Static Function ViewDef()
Local oModel     := FwLoadModel("OMSXCPL6A")
Local oStruField := FWFormViewStruct():New()
Local oStruGrid  := FWFormViewStruct():New()
Local oView      := FwFormView():New()
Local aColsSX3   := {}
    //Definições do field
    oStruField:AddField('C6_NUM'  ,'01',buscarSX3('C6_NUM' ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
    oStruField:AddField('C6_CLI'  ,'02',buscarSX3('C6_CLI' ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
    oStruField:AddField('C6_LOJA' ,'03',buscarSX3('C6_LOJA',,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
    oStruField:AddField('C6_NMCLI','04',buscarSX3('A1_NOME',,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
    //Definições da grid
    oStruGrid:AddField('C6_ITEM'   ,'01',buscarSX3('C6_ITEM'   ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
    oStruGrid:AddField('C6_PRODUTO','02',buscarSX3('C6_PRODUTO',,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
    oStruGrid:AddField('C6_DESPRD' ,'03',buscarSX3('B1_DESC'   ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
    buscarSX3('C6_QTDVEN' ,,aColsSX3)
    oStruGrid:AddField('C6_QTDPED' ,'04',STR0004,STR0004,Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.) // Saldo Pedido
    oStruGrid:AddField('C6_QTDINT' ,'05',STR0003,STR0003,Nil,'GET',aColsSX3[2],Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.) // Quantidade Integração
    //Definições da view
    oView:SetModel(oModel)
    oView:AddField('VwFieldSC6', oStruField , 'MdFieldSC6')
	oView:AddGrid( 'VwGridSC6' , oStruGrid  , 'MdGridSC6')
	oView:CreateHorizontalBox("SUPERIOR",15)
	oView:CreateHorizontalBox("INFERIOR",80)
	oView:EnableTitleView('VwFieldSC6',"Pedido")
	oView:EnableTitleView('VwGridSC6' ,"Itens do Pedido")
	oView:SetOwnerView("VwFieldSC6","SUPERIOR")
	oView:SetOwnerView("VwGridSC6" ,"INFERIOR")
Return oView
// ---------------------------------------------------------
/*/{Protheus.doc} OMSAliasSC6
Atribui informação do realName da tabela temporária
@author amanda.vieira
@since 15/10/2018
@version 1.0
/*/
// ---------------------------------------------------------
Static __oTempTab := Nil 
Function OMSObjTemp(oTempTab)
	__oTempTab := oTempTab
Return Nil
// ---------------------------------------------------------
/*/{Protheus.doc} ActiveModel
Carrega grid para edição das informações
@author amanda.vieira
@since 15/10/2018
@version 1.0
/*/
// ---------------------------------------------------------
Static Function ActiveModel(oModel)
Local oModelFld := oModel:GetModel('MdFieldSC6')
Local oModelGrd := oModel:GetModel('MdGridSC6')
Local cQuery    := ""
Local cAliasSC6 := ""
Local aTamSX3   := TamSX3("C6_QTDVEN")

    oModelGrd:SetNoInsertLine(.F.)
	oModelGrd:SetNoDeleteLine(.F.)
	oModelGrd:ClearData()
	oModelGrd:InitLine()
	oModelGrd:GoLine(1)

    cQuery := " SELECT SC6.C6_FILIAL,"
    cQuery +=        " SC6.C6_NUM,"
    cQuery +=        " SC6.C6_CLI,"
    cQuery +=        " SC6.C6_LOJA,"
    cQuery +=        " SC6.C6_ITEM,"
    cQuery +=        " SC6.C6_PRODUTO,"
    cQuery +=        " SC6.C6_QTDPED,"
    cQuery +=        " SC6.C6_QTDINT"
    cQuery +=   " FROM "+__oTempTab:GetRealName()+" SC6"
    cQuery +=  " WHERE SC6.C6_FILIAL = '"+SC5->C5_FILIAL+"'"
    cQuery +=    " AND SC6.C6_NUM    = '"+SC5->C5_NUM+"'"
    cQuery +=    " AND SC6.D_E_L_E_T_ = ' '"
    cAliasSC6 := GetNextAlias()
    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSC6, .F., .T.)
    TCSetField(cAliasSC6,'C6_QTDINT','N',aTamSx3[1],aTamSx3[2])
    TCSetField(cAliasSC6,'C6_QTDPED','N',aTamSx3[1],aTamSx3[2])
    While (cAliasSC6)->(!EoF())
        If !Empty(oModelGrd:GetValue("C6_ITEM"))
            oModelGrd:AddLine()
            oModelGrd:GoLine(oModelGrd:Length())
        EndIf
        oModelGrd:LoadValue("C6_FILIAL" ,(cAliasSC6)->C6_FILIAL)
        oModelGrd:LoadValue("C6_NUM"    ,(cAliasSC6)->C6_NUM)
        oModelGrd:LoadValue("C6_ITEM"   ,(cAliasSC6)->C6_ITEM)
        oModelGrd:LoadValue("C6_PRODUTO",(cAliasSC6)->C6_PRODUTO)
        If  (cAliasSC6)->C6_QTDPED < 0
            oModelGrd:LoadValue("C6_QTDPED",0)
            oModelGrd:LoadValue("C6_QTDINT",0)
        Else
            oModelGrd:LoadValue("C6_QTDPED",(cAliasSC6)->C6_QTDPED)
            oModelGrd:LoadValue("C6_QTDINT",(cAliasSC6)->C6_QTDINT)
        EndIf
        oModelGrd:LoadValue("C6_DESPRD" ,Posicione("SB1",1,FwxFilial('SB1')+(cAliasSC6)->C6_PRODUTO,"B1_DESC"))
        (cAliasSC6)->(DbSkip())
    EndDO
    (cAliasSC6)->(DbCloseArea())

    oModelFld:LoadValue("C6_NUM"  ,SC5->C5_NUM)
    oModelFld:LoadValue("C6_CLI"  ,SC5->C5_CLIENT)
    oModelFld:LoadValue("C6_LOJA" ,SC5->C5_LOJACLI)
    oModelFld:LoadValue("C6_NMCLI",Posicione("SA1",1,FwxFilial('SA1')+SC5->C5_CLIENT+SC5->C5_LOJACLI,"A1_NOME"))

    oModelGrd:SetNoInsertLine(.T.)
	oModelGrd:SetNoDeleteLine(.T.)
	oModelGrd:GoLine(1)
Return .T.
// ---------------------------------------------------------
/*/{Protheus.doc} CommitMdl
Carrega grid para edição das informações
@author amanda.vieira
@since 15/10/2018
@version 1.0
/*/
// ---------------------------------------------------------
Static Function CommitMdl(oModel)
Local lRet      := .T.
Local cQuery    := ""
Local oModelGrd := oModel:GetModel("MdGridSC6")
Local nI        := 0
    For nI := 1 To oModelGrd:Length()
        oModelGrd:GoLine(nI)
        cQuery := " UPDATE "+__oTempTab:GetRealName()
        cQuery +=    " SET C6_QTDINT = '"+cValToChar(oModelGrd:GetValue("C6_QTDINT"))+"'"
        cQuery +=  " WHERE C6_FILIAL = '"+oModelGrd:GetValue("C6_FILIAL")+"'"
        cQuery +=    " AND C6_NUM    = '"+oModelGrd:GetValue("C6_NUM")+"'"
        cQuery +=    " AND C6_ITEM   = '"+oModelGrd:GetValue("C6_ITEM")+"'"
        cQuery +=    " AND C6_PRODUTO= '"+oModelGrd:GetValue("C6_PRODUTO")+"'"
        cQuery +=    " AND D_E_L_E_T_= ' '"
        If TcSQLExec(cQuery) < 0
            oModel:GetModel():SetErrorMessage( , ,  , '', OMSCPL6A01, STR0005, STR0006, '', '') // Problema ao atualizar tabela temporária com a quantidade da integração. // Atualize a tela de envio de pedidos e tente novamente.
            lRet := .F.
            Exit
        EndIf
    Next nI
Return lRet
// ---------------------------------------------------------
/*/{Protheus.doc} ValidMdl
Realiza validações antes do commit do model
@author amanda.vieira
@since 15/10/2018
@version 1.0
/*/
// ---------------------------------------------------------
Static Function ValidMdl(oModel)
Local lRet      := .T.
Local lQtdLib   := (SuperGetMv("MV_CPLPELB",.F.,"2") == "2") //Indica se permite enviar apenas quantidades liberadas
Local lTotalLib := MV_PAR22 == 1
Local oModelGrd := oModel:GetModel("MdGridSC6")
Local oView     := FWViewActive()
Local nI        := 0
Local nSaldo    := 0
Local cQuery    := ""
    For nI := 1 To oModelGrd:Length()
        oModelGrd:GoLine(nI)
        If oModelGrd:GetValue("C6_QTDINT") > 0
            nSaldo := Cpl6SldPed(lQtdLib,lTotalLib,oModelGrd:GetValue("C6_FILIAL"),oModelGrd:GetValue("C6_NUM"),oModelGrd:GetValue("C6_ITEM"),oModelGrd:GetValue("C6_PRODUTO"),MV_PAR07,MV_PAR08,MV_PAR13,MV_PAR14)
            If nSaldo < oModelGrd:GetValue("C6_QTDINT")
                oModelGrd:GetModel():SetErrorMessage( , ,  , '', OMSCPL6A02, OmsFmtMsg(STR0007,{{"[VAR01]",cValToChar(nSaldo)},{"[VAR02]",oModelGrd:GetValue("C6_PRODUTO")},{"[VAR03]",oModelGrd:GetValue("C6_ITEM")}}), STR0008, '', '') // Saldo para integração ([VAR01]) do produto [VAR02] item [VAR03] é menor que a quantidade digitada. // Ajuste a quantidade para a integração.
                oModelGrd:SetValue("C6_QTDPED",nSaldo)
                //Ajusta na tabela temporária também
                cQuery := " UPDATE "+__oTempTab:GetRealName()
                cQuery +=    " SET C6_QTDPED = '"+cValToChar(nSaldo)+"'"
                cQuery +=  " WHERE C6_FILIAL = '"+oModelGrd:GetValue("C6_FILIAL")+"'"
                cQuery +=    " AND C6_NUM    = '"+oModelGrd:GetValue("C6_NUM")+"'"
                cQuery +=    " AND C6_ITEM   = '"+oModelGrd:GetValue("C6_ITEM")+"'"
                cQuery +=    " AND C6_PRODUTO= '"+oModelGrd:GetValue("C6_PRODUTO")+"'"
                cQuery +=    " AND D_E_L_E_T_= ' '"
                OsLogCPL("OMSXCPL6A -> ValidMdl -> Pedido ("+cValToChar(Trim(oModelGrd:GetValue("C6_FILIAL")))+"-"+cValToChar(Trim(oModelGrd:GetValue("C6_NUM")))+"). Conteúdo de cQuery: "+cValToChar(Trim(cQuery)),"INFO")
                TcSQLExec(cQuery)
                lRet := .F.
                oView:Refresh()
                Exit
            EndIf
        EndIf
    Next nI
Return lRet
// ---------------------------------------------------------
/*/{Protheus.doc} VldQtdInt
Valida se quantidade de integração conforme o saldo do model
@author amanda.vieira
@since 15/10/2018
@version 1.0
/*/
// ---------------------------------------------------------
Static Function VldQtdInt(oModel)
Local lRet      := .T.
    If oModel:GetValue("C6_QTDINT") > 0
        If oModel:GetValue("C6_QTDPED") < oModel:GetValue("C6_QTDINT")
            oModel:GetModel():SetErrorMessage( , ,  , '', OMSCPL6A02, OmsFmtMsg(STR0009,{{"[VAR01]",cValToChar(oModel:GetValue("C6_QTDPED"))}}), STR0008, '', '') // Saldo para integração ([VAR01]) é menor que a quantidade digitada. // Ajuste a quantidade para a integração.
            lRet := .F.
        EndIf
    ElseIf oModel:GetValue("C6_QTDINT") < 0
        oModel:GetModel():SetErrorMessage( , ,  , '', OMSCPL6A04, STR0010, STR0008, '', '') // Quantidade informada não pode ser negativa. //Ajuste a quantidade para a integração.
        lRet := .F.
    EndIf
Return lRet
// ---------------------------------------------------------
/*/{Protheus.doc} Cpl6SldPed
Retorna saldo à integrar do pedido
@author amanda.vieira
@since 15/10/2018
@version 1.0
/*/
// ---------------------------------------------------------
Function Cpl6SldPed(lQtdLib,lTotalLib,cFilPed,cPedido,cItem,cProduto,dDtLibIni,dDtLibFim,dDtEntIni,dDtEntFim)
Local cAliasSC6 := ""
Local cQuery    := ""
Local nSaldo    := 0
Local aTamSx3   := TamSX3("C6_QTDVEN")

	If lQtdLib
		//Se saldo da integração maior que a quantidade a integrar, então mantêm a quantidade a integrar
		//Se saldo da integração menor que a quantidade a integrar, então integra apenas a quantidade do saldo
		cQuery += " SELECT CASE WHEN (SUM(SLD.C9_QTDLIB) - SUM(SLD.C6_QTDINT)) > SUM(SC9.C9_QTDLIB) THEN SUM(SC9.C9_QTDLIB) ELSE (SUM(SLD.C9_QTDLIB) - SUM(SLD.C6_QTDINT)) END C6_SALDO "
	Else
		cQuery += " SELECT (SC6.C6_QTDVEN - SUM( CASE WHEN SLD.C6_QTDINT IS NULL THEN 0 ELSE SLD.C6_QTDINT END )) C6_SALDO"
	EndIf
	cQuery +=   " FROM "+RetSqlName('SC6')+" SC6"
	If lQtdLib
		cQuery +=  " INNER JOIN ("
	Else
		cQuery +=  " LEFT JOIN ("
	EndIf
    cQuery +=              " SELECT 0 C9_QTDLIB,"
    cQuery +=                     " SUM(DK3.DK3_QTDINT) C6_QTDINT,"
    cQuery +=                     " DK3.DK3_FILIAL SLD_FILIAL,"
    cQuery +=                     " DK3.DK3_PEDIDO SLD_PEDIDO,"
    cQuery +=                     " DK3.DK3_ITEMPE SLD_ITEM"
    cQuery +=                " FROM "+RetSqlName('DK3')+" DK3"
    cQuery +=               " WHERE DK3.DK3_FILIAL = '"+cFilPed+"'"
    cQuery +=                 " AND DK3.DK3_PEDIDO = '"+cPedido+"'"
    cQuery +=                 " AND DK3.DK3_ITEMPE = '"+cItem+"'"
    cQuery +=                 " AND DK3.DK3_PRODUT = '"+cProduto+"'"
    cQuery +=                 " AND DK3.DK3_STATUS IN ('1','3')" //Integrado ou Cancelado Parcial
    cQuery +=                 " AND DK3.D_E_L_E_T_ = ' '"
    cQuery +=                " GROUP BY DK3.DK3_FILIAL,"
    cQuery +=                         " DK3.DK3_PEDIDO,"
    cQuery +=                         " DK3.DK3_ITEMPE"
    cQuery +=                " UNION ALL"
    cQuery +=               " SELECT SUM(SC9.C9_QTDLIB) C9_QTDLIB,"
    cQuery +=                      " 0 C6_QTDINT,"
    cQuery +=                      " SC9.C9_FILIAL SLD_FILIAL,"
    cQuery +=                      " SC9.C9_PEDIDO SLD_PEDIDO,"
    cQuery +=                      " SC9.C9_ITEM SLD_ITEM"
    cQuery +=                 " FROM "+RetSqlName('SC9')+" SC9"
    cQuery +=                " WHERE SC9.C9_FILIAL  = '"+cFilPed+"'"
    cQuery +=                  " AND SC9.C9_PEDIDO  = '"+cPedido+"'"
    cQuery +=                  " AND SC9.C9_ITEM    = '"+cItem+"'"
    cQuery +=                  " AND SC9.C9_PRODUTO = '"+cProduto+"'"
    cQuery +=                  " AND SC9.D_E_L_E_T_ = ' '"
    cQuery +=                " GROUP BY SC9.C9_FILIAL,"
    cQuery +=                         " SC9.C9_PEDIDO,"
    cQuery +=                         " SC9.C9_ITEM"
    //Busca-se o saldo da SD2 por conta do parâmetro MV_DEL_PVL que pode provocar a exclusão de SC9 liberadas
    cQuery +=                " UNION ALL"
    cQuery +=               " SELECT SUM(SD2.D2_QUANT) C9_QTDLIB,"
    cQuery +=                      " 0 C6_QTDINT,"
    cQuery +=                      " SD2.D2_FILIAL SLD_FILIAL,"
    cQuery +=                      " SD2.D2_PEDIDO SLD_PEDIDO,"
    cQuery +=                      " SD2.D2_ITEMPV SLD_ITEM"
    cQuery +=                 " FROM "+RetSqlName('SD2')+" SD2"
    cQuery +=                " WHERE SD2.D2_FILIAL = '"+cFilPed+"'"
    cQuery +=                  " AND SD2.D2_PEDIDO = '"+cPedido+"'"
    cQuery +=                  " AND SD2.D2_ITEMPV = '"+cItem+"'"
    cQuery +=                  " AND SD2.D_E_L_E_T_ = ' '"
    cQuery +=                " GROUP BY SD2.D2_FILIAL,"
    cQuery +=                         " SD2.D2_PEDIDO,"
    cQuery +=                         " SD2.D2_ITEMPV ) SLD"
    cQuery +=     " ON SLD.SLD_FILIAL = SC6.C6_FILIAL"
    cQuery +=    " AND SLD.SLD_PEDIDO = SC6.C6_NUM"
    cQuery +=    " AND SLD.SLD_ITEM   = SC6.C6_ITEM"
    If lQtdLib
        cQuery +=  " INNER JOIN (SELECT SUM(SC9.C9_QTDLIB) C9_QTDLIB,"
        cQuery +=                     " SC9.C9_FILIAL,"
        cQuery +=                     " SC9.C9_PEDIDO,"
        cQuery +=                     " SC9.C9_ITEM"
        cQuery +=                " FROM "+RetSqlName('SC9')+" SC9"
        cQuery +=                " WHERE SC9.C9_FILIAL  = '"+cFilPed+"'"
        cQuery +=                  " AND SC9.C9_PEDIDO  = '"+cPedido+"'"
        cQuery +=                  " AND SC9.C9_ITEM    = '"+cItem+"'"
        cQuery +=                  " AND SC9.C9_PRODUTO = '"+cProduto+"'"
        cQuery +=                  " AND SC9.C9_CARGA   = ' '"
        cQuery +=                  " AND SC9.C9_BLEST   = ' '"  
        cQuery +=                  " AND SC9.C9_BLCRED  = ' '" 
        cQuery +=                  " AND SC9.C9_NFISCAL = ' '"
        cQuery +=                  " AND SC9.C9_DATALIB BETWEEN '" + dToS(dDtLibIni) + "' AND '" + dToS(dDtLibFim) + "'"
        If Empty(SC5->C5_FECENT)
            cQuery +=                  " AND SC9.C9_DATENT  BETWEEN '" + DtoS(dDtEntIni) + "' AND '" + DtoS(dDtEntFim) + "'"
        EndIf
        cQuery +=                  " AND SC9.D_E_L_E_T_ = ' '"
        cQuery +=                " GROUP BY SC9.C9_FILIAL,"
        cQuery +=                        " SC9.C9_PEDIDO,"
        cQuery +=                        " SC9.C9_ITEM) SC9"
        cQuery +=     " ON SC9.C9_FILIAL = SC6.C6_FILIAL"
        cQuery +=    " AND SC9.C9_PEDIDO = SC6.C6_NUM"
        cQuery +=    " AND SC9.C9_ITEM   = SC6.C6_ITEM"
    EndIf
    cQuery +=  " WHERE SC6.C6_FILIAL  = '"+cFilPed+"'"
    cQuery +=    " AND SC6.C6_NUM     = '"+cPedido+"'"
    cQuery +=    " AND SC6.C6_ITEM    = '"+cItem+"'"
    cQuery +=    " AND SC6.C6_PRODUTO = '"+cProduto+"'"
    If !lQtdLib .And. Empty(SC5->C5_FECENT)
        cQuery += " AND SC6.C6_ENTREG  BETWEEN '" + DtoS(dDtEntIni) + "' AND '" + DtoS(dDtEntFim) + "'"
    EndIf
    cQuery +=    " AND SC6.D_E_L_E_T_ = ' '"
    //Filtra apenas por pedidos que estão complemtamente liberados
    If lTotalLib
		cQuery += " AND NOT EXISTS (SELECT SC6.C6_NUM"
		cQuery +=                   " FROM "+RetSqlName('SC6')+" SC6"
		cQuery +=                  " WHERE SC6.C6_FILIAL = '"+cFilPed+"'"
		cQuery +=                    " AND SC6.C6_NUM = '"+cPedido+"'"
		cQuery +=                    " AND SC6.C6_QTDVEN > (SC6.C6_QTDEMP+SC6.C6_QTDENT)"
		cQuery +=                    " AND SC6.C6_BLQ <> 'R '"
		cQuery +=                    " AND SC6.D_E_L_E_T_ = ' ')"
		cQuery += " AND NOT EXISTS (SELECT SC9.C9_PEDIDO"
		cQuery +=                   " FROM "+RetSqlName('SC9')+" SC9"
		cQuery +=                  " WHERE SC9.C9_FILIAL = '"+cFilPed+"'"
		cQuery +=                    " AND SC9.C9_PEDIDO = '"+cPedido+"'"
		cQuery +=                    " AND (SC9.C9_BLEST NOT IN (' ','10') OR  SC9.C9_BLCRED NOT IN (' ','10'))"
		cQuery +=                    " AND SC9.D_E_L_E_T_ = ' ')"
    EndIf
    cQuery +=  " GROUP BY SC6.C6_QTDVEN"
    If lQtdLib
        cQuery +=    " ,SC9.C9_QTDLIB"
    EndIf
    cQuery := ChangeQuery(cQuery)
    OsLogCPL("OMSXCPL6A -> Cpl6SldPed -> Pedido ("+cValToChar(Trim(cFilPed))+"-"+cValToChar(Trim(cPedido))+"). Conteúdo de cQuery: "+cValToChar(Trim(cQuery)),"INFO")
    cAliasSC6 := GetNextAlias()
    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSC6, .F., .T.)
    TCSetField(cAliasSC6,'C6_SALDO','N',aTamSx3[1],aTamSx3[2])
    If (cAliasSC6)->(!EoF())
        nSaldo := (cAliasSC6)->C6_SALDO
        OsLogCPL("OMSXCPL6A -> Cpl6SldPed -> Conteúdo de nSaldo: "+cValToChar(nSaldo),"INFO")
    EndIf
    (cAliasSC6)->(DbCloseArea())
Return nSaldo


