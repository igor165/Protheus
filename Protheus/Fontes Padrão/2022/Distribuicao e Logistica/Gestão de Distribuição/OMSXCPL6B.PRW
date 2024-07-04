#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OMSXCPL6B.CH"

#DEFINE OMSCPL6B01 "OMSCPL6B01"
#DEFINE OMSCPL6B02 "OMSCPL6B02"
#DEFINE OMSCPL6B03 "OMSCPL6B03"
#DEFINE OMSCPL6B04 "OMSCPL6B04"
#DEFINE OMSCPL6B06 "OMSCPL6B06"
#DEFINE OMSCPL6B07 "OMSCPL6B07"
#DEFINE OMSCPL6B08 "OMSCPL6B08"

Static oModel     := Nil
Static lMarkAll   := .T.
Static aResumo    := {}
Static aFalhas    := {}
Static aEnviados  := {}
Static nQtdFalhas := 0
Static nTotalReg  := 0
Static lEsCarAut  := SuperGetMv("MV_CPLESCG",.F.,"2") == "1" //Indica se permite estorno automático da carga
Static lQuebId    := DK3->( ColumnPos( "DK3_QUEBID" ) ) > 0
//-----------------------------------------------------------
/*/{Protheus.doc} OMSXCPL6B
Tela responsável por exibir os pedidos e as sequências de integração para cancelamento
@author  amanda.vieira
@version P12
@since 12/12/2018
@version 1.0
/*/
//-----------------------------------------------------------
// Esta função é só para o TDS reconhecer o fonte e poder gerar patch
Function OMSXCPL6BDUMMY()
Return .T.
// ---------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definições do modelo
@author amanda.vieira
@since 12/12/2018
@version 1.0
/*/
// ---------------------------------------------------------
Static Function ModelDef()
Local oStruField := FWFormModelStruct():New()
Local oStruGrid  := FWFormModelStruct():New()
Local aColsSX3   := {}
	OsLogCpl("OMSXCPL6B -> ModelDef -> Inicio da função.","INFO" )
	oModel := MpFormMOdel():New("OMSXCPL6B",/*bPreValid*/,{|oModel|PosVldMdl(oModel)},{|oModel|CommitMdl(oModel)},/*bCancel*/)
    //Definições do field
    oStruField:AddTable(__cAliasTemp,{'C5_FILIAL','C5_NUM'},STR0014) // Pedido de Venda
	oStruField:AddField(buscarSX3('C5_FILIAL' ,,aColsSX3),aColsSX3[1],'C5_FILIAL' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
    oStruField:AddField(buscarSX3('C5_NUM'    ,,aColsSX3),aColsSX3[1],'C5_NUM'    ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
    oStruField:AddField(buscarSX3('C5_CLIENTE',,aColsSX3),aColsSX3[1],'C5_CLIENTE','C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
    oStruField:AddField(buscarSX3('C5_LOJACLI',,aColsSX3),aColsSX3[1],'C5_LOJACLI','C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
    oStruField:AddField(buscarSX3('A1_NOME'   ,,aColsSX3),aColsSX3[1],'C5_NMCLI'  ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
    //Definições da grid
    oStruGrid:AddTable(__cAliasTemp,{'C6_FILIAL','C6_NUM','C6_ITEM','C6_PRODUTO','DK3_SEQUEN'},STR0015) // Sequências de Integração
	oStruGrid:AddField(""," ",'MARCA','L',2,0,{|oModel|MarcaSeqInt(oModel)},{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
    oStruGrid:AddField(buscarSX3('C6_NUM'    ,,aColsSX3),aColsSX3[1],'C6_NUM'    ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
    oStruGrid:AddField(buscarSX3('DK3_SEQUEN',,aColsSX3),aColsSX3[1],'DK3_SEQUEN','C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
	oStruGrid:AddField(buscarSX3('C6_ITEM'   ,,aColsSX3),aColsSX3[1],'C6_ITEM'   ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
    oStruGrid:AddField(buscarSX3('C6_PRODUTO',,aColsSX3),aColsSX3[1],'C6_PRODUTO','C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
    oStruGrid:AddField(buscarSX3('B1_DESC'   ,,aColsSX3),aColsSX3[1],'C6_DESPRD' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
	oStruGrid:AddField(buscarSX3('DK3_VIAGID',,aColsSX3),aColsSX3[1],'DK3_VIAGID','C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
	oStruGrid:AddField(buscarSX3('DAK_COD'   ,,aColsSX3),aColsSX3[1],'DK3_CARGA' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
	If lQuebId
		oStruGrid:AddField(buscarSX3('DK3_QUEBID',,aColsSX3),aColsSX3[1],'DK3_QUEBID','C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.T.,.F.,.T.)
	EndIf
    buscarSX3('C6_QTDVEN' ,,aColsSX3)
    oStruGrid:AddField(STR0016,aColsSX3[1],'C6_QTDORI' ,'N',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,Nil,.F.,.F.,.T.)  // Qtd. Integrada
    oStruGrid:AddField(STR0017,aColsSX3[1],'C6_QTDINT' ,'N',aColsSX3[3],aColsSX3[4],{|oModel|VldQtdInt(oModel)},{||.T.},Nil,.F.,Nil,.F.,.F.,.T.) // Qtd. Cancelamento

	oModel:AddFields("MdFieldSC6",Nil,oStruField)
	If lQuebId
		oModel:SetPrimaryKey({'C6_FILIAL','C6_NUM','C6_ITEM','C6_PRODUTO','DK3_SEQINT','DK3_QUEBID'})
	Else
		oModel:SetPrimaryKey({'C6_FILIAL','C6_NUM','C6_ITEM','C6_PRODUTO','DK3_SEQINT'})
	EndIf
	oModel:SetDescription(STR0018) // Envio de Pedido
    oModel:AddGrid("MdGridSC6", "MdFieldSC6", oStruGrid , /*bLinePre*/ , /*bLinePost*/ , /*bPre*/ , /*bPost*/)
	oModel:GetModel("MdGridSC6"):SetOptional(.T.)
    oModel:SetActivate({|oModel| ActiveModel(oModel) } )
	OsLogCpl("OMSXCPL6B -> ModelDef -> Fim da função.","INFO" )
Return oModel
// ---------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definições da view
@author amanda.vieira
@since 12/12/2018
@version 1.0
/*/
// ---------------------------------------------------------
Static Function ViewDef()
Local oStruField := FWFormViewStruct():New()
Local oStruGrid  := FWFormViewStruct():New()
Local oView      := FwFormView():New()
Local aColsSX3   := {}
	OsLogCpl("OMSXCPL6B -> ViewDef -> Inicio da função.","INFO" )
	oModel := FwLoadModel("OMSXCPL6B")
    //Definições do field
    oStruField:AddField('C5_NUM'    ,'01',buscarSX3('C5_NUM'     ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.)
    oStruField:AddField('C5_CLIENTE','02',buscarSX3('C5_CLIENTE' ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
    oStruField:AddField('C5_LOJACLI','03',buscarSX3('C5_LOJACLI' ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
    oStruField:AddField('C5_NMCLI'  ,'04',buscarSX3('A1_NOME'    ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Posicione("SA1",1,OsFilial("SA1",SC5->C5_FILIAL)+SC5->C5_CLIENTE,"A1_NOME"),.T.)
    //Definições da grid
	oStruGrid:AddField('MARCA'     ,'01'," "," ",Nil,'L',"@BMP",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStruGrid:AddField('DK3_SEQUEN','02',buscarSX3('DK3_SEQUEN',,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
    oStruGrid:AddField('C6_ITEM'   ,'03',buscarSX3('C6_ITEM'   ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
    oStruGrid:AddField('C6_PRODUTO','04',buscarSX3('C6_PRODUTO',,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
    oStruGrid:AddField('C6_DESPRD' ,'05',buscarSX3('B1_DESC'   ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStruGrid:AddField('DK3_VIAGID','06',buscarSX3('DK3_VIAGID',,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStruGrid:AddField('DK3_CARGA' ,'07',buscarSX3('DAK_COD'   ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	If lQuebId
		oStruGrid:AddField('DK3_QUEBID' ,'08',buscarSX3('DK3_QUEBID'   ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	EndIf
    buscarSX3('C6_QTDVEN' ,,aColsSX3)
    oStruGrid:AddField('C6_QTDORI' ,'09',STR0016,STR0016,Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.) // Qtd. Integrada
    oStruGrid:AddField('C6_QTDINT' ,'10',STR0017,STR0017,Nil,'GET',aColsSX3[2],Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.) // Qtd. Cancelamento
    //Definições da view
    oView:SetModel(oModel)
    oView:AddField('VwFieldSC6', oStruField , 'MdFieldSC6')
	oView:AddGrid( 'VwGridSC6' , oStruGrid  , 'MdGridSC6')
	oView:AddOtherObject('VwButton',{|oPainel| ButtonMark(oPainel) })
	oView:CreateHorizontalBox('SUPERIOR',15)
	oView:CreateHorizontalBox('INFERIOR',80)
	oView:CreateHorizontalBox('RODAPE',5)
	oView:EnableTitleView('VwFieldSC6',STR0014) // Pedido de Venda
	oView:EnableTitleView('VwGridSC6',STR0015) // Sequências de Integração
	oView:SetOwnerView('VwFieldSC6','SUPERIOR')
	oView:SetOwnerView('VwGridSC6','INFERIOR')
	oView:SetOwnerView('VwButton','RODAPE')
	OsLogCpl("OMSXCPL6B -> ViewDef -> Fim da função.","INFO" )
Return oView
// ---------------------------------------------------------
/*/{Protheus.doc} ButtonMark
Botão responsável por definir se marca todos os itens da sequência ao selecionar um dos itens
@author amanda.vieira
@since 12/12/2018
@version 1.0
/*/
// ---------------------------------------------------------
Static Function ButtonMark(oPainel)
	@ 05,05 CheckBox oAllMark Var lMarkAll Prompt STR0019 Size 150,10 OF oPainel PIXEL // Marca todos os itens da sequência selecionada
Return
// ---------------------------------------------------------
/*/{Protheus.doc} ActiveModel
Carrega informações da tela
@author amanda.vieira
@since 12/12/2018
@version 1.0
/*/
// ---------------------------------------------------------
Static Function ActiveModel(oModel)
Local lRet      := .T.
Local oModelPed := oModel:GetModel("MdFieldSC6")
Local oModelSeq := oModel:GetModel("MdGridSC6")
Local cAliasQry := ""
Local cQuery    := ""
Local lEstDk3  := SuperGetMV("MV_CPLCDK3",.F.,.F.) //Define de qual tabela será considerado o Status do registro para desatualizar pedido de venda int com TOL (.F. = C6_INTROT ou .T. = DK3_STATUS)
	//Limpa variável estática do modelo
	oModel := Nil

	oModelPed:LoadValue("C5_FILIAL",SC5->C5_FILIAL)
	oModelPed:LoadValue("C5_NUM",SC5->C5_NUM)
	oModelPed:LoadValue("C5_CLIENTE",SC5->C5_CLIENTE)
	oModelPed:LoadValue("C5_LOJACLI",SC5->C5_LOJACLI)
	oModelPed:LoadValue("C5_NMCLI",Posicione("SA1",1,OsFilial("SA1",SC5->C5_FILIAL)+SC5->C5_CLIENTE,"A1_NOME"))

	oModelSeq:SetNoInsertLine(.F.)
	oModelSeq:SetNoDeleteLine(.F.)
	oModelSeq:ClearData()
	oModelSeq:InitLine()
	oModelSeq:GoLine(1)

    cQuery := "SELECT SC6.C6_NUM,"
	cQuery +=       " CASE WHEN DK3.DK3_SEQUEN IS NULL THEN 'NA    ' ELSE DK3.DK3_SEQUEN END DK3_SEQUEN,"
    cQuery +=       " SC6.C6_ITEM,"
    cQuery +=       " SC6.C6_PRODUTO,"
	cQuery +=       " SB1.B1_DESC C6_DESPRD,"
	If lQuebId
		cQuery +=       " DK3.DK3_QUEBID,"
    EndIf 
	cQuery +=       " CASE WHEN DK0.DK0_VIAGID IS NULL THEN ' ' ELSE DK0.DK0_VIAGID END DK3_VIAGID,"
	cQuery +=       " CASE WHEN DK0.DK0_CARGA IS NULL THEN ' ' ELSE DK0.DK0_CARGA END DK3_CARGA,"
	cQuery +=       " CASE WHEN DK3.DK3_QTDINT IS NULL THEN SC6.C6_QTDVEN ELSE DK3.DK3_QTDINT END C6_QTDORI,"
    cQuery +=       " CASE WHEN DK3.DK3_QTDINT IS NULL THEN SC6.C6_QTDVEN ELSE DK3.DK3_QTDINT END C6_QTDINT"
	cQuery +=  " FROM "+RetSqlName("SC6")+" SC6"
	If !lEstDk3
		cQuery +=  " LEFT JOIN "+RetSqlName('DK3')+" DK3"
		cQuery +=    " ON DK3.DK3_FILIAL = SC6.C6_FILIAL"
		cQuery +=   " AND DK3.DK3_PEDIDO = SC6.C6_NUM"
		cQuery +=   " AND DK3.DK3_ITEMPE = SC6.C6_ITEM"
		cQuery +=   " AND DK3.DK3_STATUS IN ('1','3')" //Integrado ou Cancelado Parcial
		cQuery +=   " AND DK3.D_E_L_E_T_ = ' '"
	else
		cQuery +=  " INNER JOIN "+RetSqlName('DK3')+" DK3"
		cQuery +=    " ON DK3.DK3_FILIAL = SC6.C6_FILIAL"
		cQuery +=   " AND DK3.DK3_PEDIDO = SC6.C6_NUM"
		cQuery +=   " AND DK3.DK3_ITEMPE = SC6.C6_ITEM"
		cQuery +=   " AND DK3.DK3_STATUS IN ('1','3')" //Integrado ou Cancelado Parcial
		cQuery +=   " AND DK3.D_E_L_E_T_ = ' '"
	Endif
	cQuery +=  " LEFT JOIN "+RetSqlName('DK0')+" DK0"
	cQuery +=    " ON DK0.DK0_FILIAL = "+OsFilQry("DK0","DK3.DK3_FILIAL")
	cQuery +=   " AND DK0.DK0_VIAGID = DK3.DK3_VIAGID"
	cQuery +=   " AND DK0.DK0_SITINT NOT IN ('4','5')"    // Cancelada ou Reprogramada
	cQuery +=   " AND DK0.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN "+RetSqlName('SB1')+" SB1"
	cQuery +=    " ON SB1.B1_FILIAL  = "+OsFilQry("SB1","SC6.C6_FILIAL")
	cQuery +=   " AND SB1.B1_COD     =  SC6.C6_PRODUTO"
	cQuery +=   " AND SB1.D_E_L_E_T_ = ' '"
    cQuery += " WHERE SC6.C6_FILIAL  = '"+SC5->C5_FILIAL+"'"
	cQuery +=   " AND SC6.C6_NUM     = '"+SC5->C5_NUM+"'"
	If !lEstDk3
		cQuery +=   " AND SC6.C6_INTROT IN ('2','4')" // Integrado ou Integrado Parcial
	EndIf	
	cQuery +=   " AND SC6.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY C6_FILIAL,"
	cQuery +=          " C6_NUM,"
	cQuery +=          " DK3_SEQUEN,"
	cQuery +=          " DK3_VIAGID"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!Eof())
		If !Empty(oModelSeq:GetValue("C6_NUM"))
			oModelSeq:AddLine()
			oModelSeq:GoLine(oModelSeq:Length())
		EndIf
		oModelSeq:LoadValue("C6_NUM",(cAliasQry)->C6_NUM)
		oModelSeq:LoadValue("DK3_SEQUEN",(cAliasQry)->DK3_SEQUEN)
		oModelSeq:LoadValue("C6_ITEM",(cAliasQry)->C6_ITEM)
		oModelSeq:LoadValue("C6_PRODUTO",(cAliasQry)->C6_PRODUTO)
		oModelSeq:LoadValue("C6_DESPRD",(cAliasQry)->C6_DESPRD)
		oModelSeq:LoadValue("DK3_VIAGID",(cAliasQry)->DK3_VIAGID)
		oModelSeq:LoadValue("DK3_CARGA",(cAliasQry)->DK3_CARGA)
		oModelSeq:LoadValue("C6_QTDORI",(cAliasQry)->C6_QTDORI)
		oModelSeq:LoadValue("C6_QTDINT",(cAliasQry)->C6_QTDINT)
		oModelSeq:LoadValue("MARCA",.F.)
		If lQuebId
			oModelSeq:LoadValue("DK3_QUEBID",(cAliasQry)->DK3_QUEBID)
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	oModelSeq:SetNoInsertLine(.T.)
	oModelSeq:SetNoDeleteLine(.T.)
	oModelSeq:GoLine(1)
Return lRet
//-----------------------------------------------------------
/*/{Protheus.doc} PosVldMdl
Função de validação do modelo para commit
@author  amanda.vieira
@version P12
@since 12/12/2018
@version 1.0
/*/
//-----------------------------------------------------------
Static Function PosVldMdl(oModel)
Local lRet      := .T.
Local lMarca    := .F.
Local lAtuCPL   := SuperGetMv("MV_CPLATVG",.F.,"1") == "1" //Indica se atualiza viagem no CPL ao alterar sequência de integração
Local aAreaSC5  := SC5->(GetArea())
Local oModelSeq := oModel:GetModel("MdGridSC6")
Local cSeqIntAnt:= ""
Local nI        := 1

	//Validações gerais do estorno, valido para o estorno por pedido posicionado ou por pedidos selecionados
	If !ValEstInt() .And. (ValType(__lAutoma) =='U' .Or. !__lAutoma)
		Return .F.
	EndIf

	For nI := 1 To oModelSeq:Length()
		oModelSeq:GoLine(nI)
		If ValType(__lAutoma) !='U' .And. __lAutoma
			oModelSeq:SetValue("MARCA", .T.)
		EndIf
		If oModelSeq:GetValue("MARCA") .And. !(cSeqIntAnt == oModelSeq:GetValue("DK3_SEQUEN"))
			cSeqIntAnt := oModelSeq:GetValue("DK3_SEQUEN")
			lMarca := .T.
			If !Empty(oModelSeq:GetValue("DK3_VIAGID")) .And. !lAtuCPL .And. (ValType(__lAutoma) =='U' .Or. !__lAutoma)
				If !OmsMessage(STR0028,OMSCPL6B03,3) // O parâmetro MV_CPLATVG encontra-se inativo, portanto, as alterações de itens em viagens não serão refletidas para o Cockpit Logístico. Confirma ação?
					oModel:GetModel():SetErrorMessage(oModel:GetId(),,,,OMSCPL6B07,STR0029) // Cancelamento não realizado.
					Return .F.
				EndIf
				Exit
			EndIf
		EndIf
	Next nI

	//Valida se existem registros marcados
	If !lMarca
		oModel:GetModel():SetErrorMessage(oModel:GetId(),,,,OMSCPL6B04,STR0021) // Nenhum registro encontra-se marcado para o cancelamento.
		Return .F.
	EndIf

	RestArea(aAreaSC5)
Return lRet
//-----------------------------------------------------------
/*/{Protheus.doc} ValEstInt
Função responsável por agrupar as validações que serão utilizadas tanto no estorno da integração por pedido selecionado,
quanto no estorno da integração por seleção
@author  amanda.vieira
@version P12
@since 21/02/2019
@version 1.0
/*/
//-----------------------------------------------------------
Static Function ValEstInt()
Local lRet := .T.
Local cUsr := SuperGetMv("MV_CPLURL",.F.,"")
	//Teste de conexão
	If !OMSXCPLWST(cUsr,.F.)
		If !Empty(oModel)
			oModel:GetModel():SetErrorMessage(oModel:GetId(),,,,OMSCPL6B06,STR0026,STR0027) // Não foi possível estabelecer conexão com o Cockpit Logístico. //Verifique os parâmetros da integração.
		EndIf
		lRet := .F.
	EndIf
Return lRet
//-----------------------------------------------------------
/*/{Protheus.doc} CommitMdl
Função responsável por efetivar o cancelamento/alteração dos pedidos
@author  amanda.vieira
@version P12
@since 12/12/2018
@version 1.0
/*/
//-----------------------------------------------------------
Static Function CommitMdl(oModel)
Return FWFormCommit(oModel,/*bBefore*/,/*bAfter*/,{||AfterSTTS()},{|oModel| InTTS(oModel)},/*bABeforeTTS*/,/*bIntegEAI*/)
//-----------------------------------------------------------
/*/{Protheus.doc} InTTS
Função executada dentro da transação de commit
@author  amanda.vieira
@version P12
@since 12/12/2018
@version 1.0
/*/
//-----------------------------------------------------------
Static Function InTTS(oModel)
Local lRet := .T.
	Processa({|| lRet := ProcEstInt(oModel)},STR0030,,.T.) // Cancelando Integração dos Itens Selecionados...
Return lRet
//-----------------------------------------------------------
/*/{Protheus.doc} AfterSTTS
Função executada depois da transação.
@author  amanda.vieira
@version P12
@since 12/12/2018
@version 1.0
/*/
//-----------------------------------------------------------
Static Function AfterSTTS()
Local lRet     := .T.
Local lIsBlind := IsBlind()
	If !lIsBlind
		//Apresenta resumo do cancelamento
		OmsShowWng(aResumo)
	EndIf
Return lRet
//-----------------------------------------------------------
/*/{Protheus.doc} ProcEstInt
Processa estorno do CPL das sequências de integração selecionadas do pedido posicionado
@author  amanda.vieira
@version P12
@since 12/12/2018
@version 1.0
/*/
//-----------------------------------------------------------
Static Function ProcEstInt(oModel)
Local lRet      := .T.
Local lViagComp := .T.
Local lSeqComp  := .F.
Local oModelPed := oModel:GetModel("MdFieldSC6")
Local oModelSeq := oModel:GetModel("MdGridSC6")
Local cSeqIntAnt:= ""
Local cViagem   := ""
Local cCarga    := ""
Local cItem     := ""
Local cSeqInt   := ""
Local cProduto  := ""
Local cQuebraId := ""
Local cQuebIdAtu:= ""
Local cQuebIdAnt:= ""
Local cFilPed   := oModelPed:GetValue("C5_FILIAL")
Local cPedido   := oModelPed:GetValue("C5_NUM")
Local aCabecalho:= {}
Local nI        := 1
Private lMsHelpAuto := .T. //Variavel de controle interno do ExecAuto
Private lMsErroAuto := .F. //Variavel que informa a ocorrência de erros no ExecAuto
	//Reinicia variáveis estáticas
	aResumo    := {}
	aFalhas    := {}
	aEnviados  := {}
	nQtdFalhas := 0
	nTotalReg  := 0

	ProcRegua(oModelSeq:Length())

	//Adiciona linha inicial do relatório de cancelamento
	aAdd(aCabecalho,STR0006+CRLF) // Resumo do cancelamento da(s) sequência(s) de integração.

	For nI := 1 To oModelSeq:Length()
		oModelSeq:GoLine(nI)
		IncProc(OmsFmtMsg(STR0031,{{"[VAR01]",oModelSeq:GetValue("DK3_SEQUEN")},{"[VAR02]",oModelSeq:GetValue("C6_ITEM")}})) // Processando Sequência [VAR01] / Item [VAR02]
		//Se linha encontra-se marcacada e não for estorno de sequência completa ou a sequência de integração anterior não for igual a sequência de integração atual,
		cQuebIdAtu := Iif(lQuebId,AllTrim(oModelSeq:GetValue("DK3_QUEBID")),"")
		If oModelSeq:GetValue("MARCA") .And. !(cSeqIntAnt == AllTrim(oModelSeq:GetValue("DK3_SEQUEN")) .And. cQuebIdAnt == cQuebIdAtu)
			cCarga    := oModelSeq:GetValue("DK3_CARGA")
			cViagem   := oModelSeq:GetValue("DK3_VIAGID")
			cItem     := oModelSeq:GetValue("C6_ITEM")
			cProduto  := oModelSeq:GetValue("C6_PRODUTO")
			cSeqInt   := Iif(AllTrim(oModelSeq:GetValue("DK3_SEQUEN")) == "NA"," ",oModelSeq:GetValue("DK3_SEQUEN"))
			cQuebraId := Iif(lQuebId,oModelSeq:GetValue("DK3_QUEBID"),"")
			lViagComp := ViagemComp(oModelSeq,cViagem) .And. !VldOutPed(cFilPed,cPedido,cViagem)//Indica se a viagem completa encontra-se marcada, para estornar pedido inteiro
			lSeqComp  := SeqIntComp(oModelSeq,cSeqInt,cQuebraId) //Indica se a sequência completa encontra-se marcada, para estornar pedido inteiro
			cSeqIntAnt:= AllTrim(cSeqInt)
			cQuebIdAnt:= AllTrim(cQuebraId)
			EstIntCPL(cFilPed,cPedido,cCarga,cViagem,cSeqInt,lViagComp,lSeqComp,cItem,cProduto,.F.,cQuebraId)
		EndIf
	Next nI

	IF nQtdFalhas > 0
		aAdd(aCabecalho,STR0040 + cValToChar(nQtdFalhas)+CRLF) //"Registros que apresentaram falha no cancelamento: "
	EndIF
	IF (nTotalReg - nQtdFalhas) > 0
		aAdd(aCabecalho,STR0041 + cValToChar((nTotalReg - nQtdFalhas))+CRLF) //"Registros que apresentaram sucesso no cancelamento: "
	EndIF
	aAdd(aCabecalho,STR0042 + cValToChar(nTotalReg)+CRLF) //"Total de registros processados: " 

	//Monta array do resumo
	aEval(aCabecalho,{|x|Aadd(aResumo,x)})
	aEval(aFalhas,{|x|Aadd(aResumo,x)})
	aEval(aEnviados,{|x|Aadd(aResumo,x)})
	
Return lRet
//-----------------------------------------------------------
/*/{Protheus.doc} OmsCpl6Est
Processa estorno de integração dos pedidos selecionados
@author  amanda.vieira
@version P12
@since 21/02/2018
@version 1.0
/*/
//-----------------------------------------------------------
Function OmsCpl6Est()
Local lRet      := .T.
Local lViagComp := .T.
Local lSeqComp  := .F.
Local cSeqIntAnt:= ""
Local cViagem   := ""
Local cCarga    := ""
Local cSeqInt   := ""
Local cQuery    := ""
Local cAliasQry := ""
Local cQuebraId := ""
Local aCabecalho:= {}
Local nI        := 1
Local lEstDk3  := SuperGetMV("MV_CPLCDK3",.F.,.F.) //Define de qual tabela será considerado o Status do registro para desatualizar pedido de venda int com TOL (.F. = C6_INTROT ou .T. = DK3_STATUS)
Private lMsHelpAuto := .T. //Variavel de controle interno do ExecAuto
Private lMsErroAuto := .F. //Variavel que informa a ocorrência de erros no ExecAuto

	//Realiza validações
	If !ValEstInt()
		Return .F.
	EndIf

	//Reinicia variáveis estáticas
	oModel     := Nil
	aResumo    := {}
	aFalhas    := {}
	aEnviados  := {}
	nQtdFalhas := 0
	nTotalReg  := 0
	cSelect	   := ""
	cSelectCnt := ""
	cGroupBy   := ""


	cSelect := "SELECT SC6.C6_FILIAL,"
	cSelect +=       " SC6.C6_NUM,"
	cSelect +=       " DK3.DK3_SEQUEN,"
	cSelect +=       " DK3.DK3_VIAGID,"
	If lQuebId
		cSelect +=   " DK3.DK3_QUEBID,"
	EndIf
	cSelect +=       " DK0.DK0_CARGA,"
	cSelect +=       " SC5.R_E_C_N_O_ RECNOSC5"

	cSelectCnt := "SELECT COUNT(*) QTDTOTAL"

	cQuery +=  " FROM "+ __oTempSC6:GetRealName()+" TMP"
	cQuery += " INNER JOIN "+RetSqlName('SC6')+" SC6"
	cQuery +=    " ON SC6.C6_FILIAL = TMP.TMP_FILIAL"
	cQuery +=   " AND SC6.C6_NUM    = TMP.TMP_PEDIDO"
	IF !lEstDk3
		cQuery +=   " AND SC6.C6_INTROT IN ('2','4')" // Integrado ou Integrado Parcial
	EndIf
	cQuery +=   " AND SC6.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN "+RetSqlName('SC5')+" SC5"
	cQuery +=    " ON SC5.C5_FILIAL = SC6.C6_FILIAL"
	cQuery +=   " AND SC5.C5_NUM    = SC6.C6_NUM"
	cQuery +=   " AND SC5.D_E_L_E_T_    = ' '"
	cQuery += " INNER JOIN "+RetSqlName('DK3')+" DK3"
	cQuery +=    " ON DK3.DK3_FILIAL = SC6.C6_FILIAL"
	cQuery +=   " AND DK3.DK3_PEDIDO = SC6.C6_NUM"
	cQuery +=   " AND DK3.DK3_ITEMPE = SC6.C6_ITEM"
	cQuery +=   " AND DK3.DK3_PRODUT = SC6.C6_PRODUTO"
	cQuery +=   " AND DK3.DK3_STATUS IN ('1','3')"
	cQuery +=   " AND DK3.D_E_L_E_T_ = ' '"
	cQuery +=  " LEFT JOIN "+RetSqlName('DK1')+" DK1"
	cQuery +=    " ON DK1.DK1_FILIAL = "+OsFilQry("DK1","SC6.C6_FILIAL")
	cQuery +=   " AND DK1.DK1_FILPED = SC6.C6_FILIAL"
	cQuery +=   " AND DK1.DK1_PEDIDO = SC6.C6_NUM"
	cQuery +=   " AND DK1.DK1_ITEMPE = SC6.C6_ITEM"
	cQuery +=   " AND DK1.D_E_L_E_T_ =  ' '"
	cQuery +=  " LEFT JOIN "+RetSqlName('DK0')+" DK0"
	cQuery +=    " ON DK0.DK0_FILIAL = "+OsFilQry("DK0","SC6.C6_FILIAL")
	cQuery +=   " AND DK0.DK0_REGID  = DK1.DK1_REGID"
	cQuery +=   " AND DK0.DK0_VIAGID = DK3.DK3_VIAGID"
	cQuery +=   " AND DK0.D_E_L_E_T_ = ' '"
	cQuery += " WHERE TMP.TMP_MARK  <> ' '"
	cQuery +=   " AND TMP.D_E_L_E_T_ = ' '"

	cGroupBy += " GROUP BY SC6.C6_FILIAL,"
	cGroupBy +=          " SC6.C6_NUM,"
	cGroupBy +=          " DK3.DK3_SEQUEN,"
	cGroupBy +=          " DK3.DK3_VIAGID,"
	If lQuebId
		cGroupBy +=      " DK3.DK3_QUEBID,"
	EndIf
	cGroupBy +=          " DK0.DK0_CARGA,"
	cGroupBy +=          " SC5.R_E_C_N_O_"
	cGroupBy += " ORDER BY SC6.C6_NUM"
		
	cSelectCnt := cSelectCnt + cQuery		
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSelectCnt), cAliasQry, .F., .T.)
	nTot := (cAliasQry)->QTDTOTAL
	(cAliasQry)->(dbCloseArea())

	cSelect := cSelect + cQuery	+ cGroupBy
	OsLogCPL("OMSXCPL6B -> OmsCpl6Est -> Conteúdo de cSelect: " + rTrim(cSelect),"INFO")

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSelect), cAliasQry, .F., .T.)

	ProcRegua(nTot)

	//Adiciona linha inicial do relatório de cancelamento
	aAdd(aCabecalho,STR0006+CRLF) // Resumo do cancelamento da(s) sequência(s) de integração.

	While (cAliasQry)->(!EoF())
		IncProc(OmsFmtMsg(STR0036,{{"[VAR01]",(cAliasQry)->C6_NUM},{"[VAR02]",(cAliasQry)->DK3_SEQUEN}})) // Processando Pedido [VAR01] / Sequência [VAR02]
		SC5->(DbGoTo((cAliasQry)->RECNOSC5))
		cFilPed   := (cAliasQry)->C6_FILIAL
		cPedido   := (cAliasQry)->C6_NUM
		cCarga    := (cAliasQry)->DK0_CARGA
		cViagem   := (cAliasQry)->DK3_VIAGID
		cSeqInt   := (cAliasQry)->DK3_SEQUEN
		cQuebraId := Iif(lQuebId,(cAliasQry)->DK3_QUEBID,"")
		lViagComp := !VldOutPed(cFilPed,cPedido,cViagem) //Indica que trata-se do estorno da viagem completa
		lSeqComp  := .T. //Indica que trata-se do estorno da sequência completa
		If !Empty(cViagem)
			OsLogCPL("OMSXCPL6B -> OmsCpl6Est -> Viagem ("+cValToChar(Trim(cFilPed))+"-"+cValToChar(Trim(cViagem))+"). Iniciando cancelamento de integração. " + cValToChar(Trim(cQuery)),"INFO")
		Else
			OsLogCPL("OMSXCPL6B -> OmsCpl6Est -> Pedido ("+cValToChar(Trim(cFilPed))+"-"+cValToChar(Trim(cPedido))+"). Iniciando cancelamento de integração. " + cValToChar(Trim(cQuery)),"INFO")
		EndIf
		EstIntCPL(cFilPed,cPedido,cCarga,cViagem,cSeqInt,lViagComp,lSeqComp,,,.T.,cQuebraId)
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	IF nQtdFalhas > 0
		aAdd(aCabecalho,STR0040 + cValToChar(nQtdFalhas)+CRLF) //"Registros que apresentaram falha no cancelamento: "
	EndIF
	IF (nTotalReg - nQtdFalhas) > 0
		aAdd(aCabecalho,STR0041 + cValToChar((nTotalReg - nQtdFalhas))+CRLF) //"Registros que apresentaram sucesso no cancelamento: "
	EndIF
	aAdd(aCabecalho,STR0042 + cValToChar(nTotalReg)+CRLF) //"Total de registros processados: " 
		
	//Monta array do resumo
	aEval(aCabecalho,{|x|Aadd(aResumo,x)})
	aEval(aFalhas,{|x|Aadd(aResumo,x)})
	aEval(aEnviados,{|x|Aadd(aResumo,x)})
	OmsShowWng(aResumo)
Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} EstIntCPL
Processa estorno de integração dos pedidos selecionados
@author  amanda.vieira
@version P12
@since 21/02/2018
@version 1.0
@param cFilPed, Caracter, filial do pedido
@param cPedido, Caracter, número do pedido
@param cCarga, Caracter, código da carga
@param cViagem, Caracter, código da viagem
@param cSeqInt, Caracter, código da sequência de integração
@param lViagComp, Lógico , indica se a viagem completa será estornada
@param lSeqComp, Lógico , indica se a sequência completa será estornada
@param cItem, Caracter, item do pedido
@param cProduto, Caracter, item do pedido
@param lEstPedSel, Lógico, indica se trata-se de um estorno sequência completa
@param cQuebraId, characters, id da quebra do Cockpit
@obs Necessário que a tabela SC5 esteja posicionada
/*/
//-----------------------------------------------------------
Static Function EstIntCPL(cFilPed,cPedido,cCarga,cViagem,cSeqInt,lViagComp,lSeqComp,cItem,cProduto,lEstPedSel,cQuebraId)
Local cIdPedido  := ""
Local cFalha     := ""
Local cObs       := ""
Local cFilBkp    := cFilAnt
Local lProcessa  := .T.
Local lRet       := .T.
Local lAtuCPL    := SuperGetMv("MV_CPLATVG",.F.,"1") == "1" //Indica se atualiza viagem no CPL ao alterar sequência de integração

	
	If Empty(cQuebraId)
		cIdPedido := OmsFmtMsg(STR0007,{{"[VAR01]",cFilPed},{"[VAR02]",cPedido},{"[VAR03]",cSeqInt}}) // Filial [VAR01] | Pedido [VAR02] | Sequência Integração [VAR03].
		OsLogCPL("OMSXCPL6B -> EstIntCPL -> Pedido ("+cValToChar(Trim(cFilPed))+"-"+cValToChar(Trim(cPedido))+"). Conteudo da variavel cIdPedido sem quebra: " + cValToChar(Trim(cIdPedido)),"INFO")
	Else
		cIdPedido := OmsFmtMsg(STR0039,{{"[VAR01]",cFilPed},{"[VAR02]",cPedido},{"[VAR03]",cSeqInt},{"[VAR04]",cQuebraId}}) // Filial [VAR01] | Pedido [VAR02] | Sequência Integração [VAR03] | Id Quebra [VAR04].
		OsLogCPL("OMSXCPL6B -> EstIntCPL -> Pedido ("+cValToChar(Trim(cFilPed))+"-"+cValToChar(Trim(cPedido))+"). Conteudo da variavel cIdPedido com quebra: " + cValToChar(Trim(cIdPedido)) + ". Conteudo da variavel cQuebraId: " +cValToChar(Trim(cQuebraId)),"INFO")
	EndIf
	
	lProcessa := PermEstCar(cFilPed,cPedido,cCarga,cViagem,cSeqInt,lViagComp,cItem,cProduto,@cFalha,lEstPedSel)
	
	nTotalReg += 1 //Armazena total de registros
	
	If lProcessa
		//Altera filial atual
		cFilAnt := cFilPed
		//Inicia variáveis de controle
		lProcessa  := .T.
		//Realiza validação para estorno da carga
		If !Empty(cCarga) .And. !(lProcessa := VldEstCarga(lViagComp,cCarga,cFilPed,cPedido,cItem))
			If !lViagComp
				//Mensagem referente à tentativa de estorno de um item da carga
				cFalha := STR0032 // Motivo: Não foi possível estornar os itens de suas respectivas cargas.
			Else
				//Mensagem referente à tentativa de estorno da carga completa
				cFalha := STR0035 // Motivo: Não foi possível realizar o estorno da carga.
			EndIf
			OsLogCPL("OMSXCPL6B -> EstIntCPL -> Conteudo da variavel cFalha: " + cValToChar(Trim(cFalha)),"INFO")
		EndIf
	EndIf
	//Realiza estorno do CPL
	If lProcessa .And. (Empty(cViagem) .Or. lAtuCPL)
		If (lViagComp .Or. lSeqComp)
			lProcessa := OMSXCPLENVIA("SC5",MODEL_OPERATION_DELETE,cSeqInt,Nil,@cFalha,cQuebraId)
		Else
			lProcessa := OMSXCPLENVIA("SC5",MODEL_OPERATION_UPDATE,cSeqInt,Nil,@cFalha,cQuebraId)
		EndIf
	EndIf
	
	// Caso o objeto não exista no Cockpit Logístico também deverá processar o cancelamento
	If !lProcessa .And. !Empty(cFalha)
		If (lProcessa := (At("ObjectDoesntExist",cFalha ) > 0))
			cObs := STR0038 // Pedido/item cancelado por não existir no Cockpit Logístico.
			OsLogCPL("OMSXCPL6B -> EstIntCPL -> Conteudo da variavel cObs: " + cValToChar(Trim(cObs)),"INFO")
		EndIf
	EndIf
	
	//Estorna carga para itens que foram "cortados" da viagem e que ainda possuem a carga gravada na SC9.
	If lProcessa .And. !Empty(cCarga)
		ProcEstCarg(cCarga,cFilPed,cPedido,cSeqInt,cQuebraId)
	EndIf
	If lProcessa
		//Altera status da sequência de integração
		AltStatus(cFilPed,cPedido,cSeqInt,cCarga,cViagem,cQuebraId)
	EndIf
	If lProcessa
		If Empty(aEnviados)
			aAdd(aEnviados,STR0022)
		EndIf
		aAdd(aEnviados,cIdPedido+cObs)
	Else
	//Grava erro
		nQtdFalhas += 1
		
		If Empty(aFalhas)
			aAdd(aFalhas,STR0009) // Registros Não Enviados:
		EndIf
		cFalha := FwCutOff(cFalha) //Remove quebras de linha
		aAdd(aFalhas,cIdPedido+CRLF+cFalha) // Gravado registro de falha (DJW). Motivo:
		aAdd(aFalhas,Replicate("-",166))
	EndIf
	cFilAnt := cFilBkp
Return lRet
//-----------------------------------------------------------
/*/{Protheus.doc} SeqIntComp
Verifica se a sequência completa encontra-se marcada
@author  amanda.vieira
@version P12
@since 12/12/2018
@version 1.0
@param oModelSeq, objeto, model das sequências de integração
@param cSeqInt, Caracter, sequência de integração
@param cQuebraId, characters, id da quebra do Cockpit
/*/
//-----------------------------------------------------------
Static Function SeqIntComp(oModelSeq,cSeqInt,cQuebraId)
Local lRet      := .T.
Local nI        := 1
Local nLineAtu  := oModelSeq:GetLine() 

	If lQuebId
		For nI := 1 To oModelSeq:Length()
			oModelSeq:GoLine(nI)
			If AllTrim(oModelSeq:GetValue("DK3_SEQUEN")) == AllTrim(cSeqInt) .And. AllTrim(oModelSeq:GetValue("DK3_QUEBID")) == AllTrim(cQuebraId) .And. (!oModelSeq:GetValue("MARCA") .Or. !(oModelSeq:GetValue("C6_QTDORI") == oModelSeq:GetValue("C6_QTDINT")))
				lRet := .F.
				Exit
			EndIf
		Next nI
	Else
		For nI := 1 To oModelSeq:Length()
			oModelSeq:GoLine(nI)
			If AllTrim(oModelSeq:GetValue("DK3_SEQUEN")) == AllTrim(cSeqInt) .And. (!oModelSeq:GetValue("MARCA") .Or. !(oModelSeq:GetValue("C6_QTDORI") == oModelSeq:GetValue("C6_QTDINT")))
				lRet := .F.
				Exit
			EndIf
		Next nI		
	EndIf
	//Retorna para linha anterior
	oModelSeq:GoLine(nLineAtu)
Return lRet
//-----------------------------------------------------------
/*/{Protheus.doc} ViagemComp
Verifica se a viagem completa encontra-se marcada
@author  amanda.vieira
@version P12
@since 12/12/2018
@version 1.0
@param oModelSeq, objeto, model das sequências de integração
@param cViagem, Caracter, código da viagem
/*/
//-----------------------------------------------------------
Static Function ViagemComp(oModelSeq,cViagem)
Local lRet      := .T.
Local nI        := 1
Local nLineAtu  := oModelSeq:GetLine()
	For nI := 1 To oModelSeq:Length()
		oModelSeq:GoLine(nI)
		If AllTrim(oModelSeq:GetValue("DK3_VIAGID")) == AllTrim(cViagem) .And. (!oModelSeq:GetValue("MARCA") .Or. !(oModelSeq:GetValue("C6_QTDORI") == oModelSeq:GetValue("C6_QTDINT")))
			lRet := .F.
			Exit
		EndIf
	Next nI
	//Retorna para linha anterior
	oModelSeq:GoLine(nLineAtu)
Return lRet
//-----------------------------------------------------------
/*/{Protheus.doc} VldOutPed
Verifica se possui outros pedidos na viagem
@author  amanda.vieira
@version P12
@since 12/12/2018
@version 1.0
@param cFilPed, Caracter, filial do pedido
@param cPedido, Caracter, número do pedido
@param cViagem, Caracter, código da viagem
/*/
//-----------------------------------------------------------
Static Function VldOutPed(cFilPed,cPedido,cViagem)
Local lRet      := .F.
Local cQuery    := ""
Local cAliasQry := ""
	cQuery := " SELECT DK1.R_E_C_N_O_ RECNODK1,"
	cQuery +=        " DK1.DK1_ITEMPE,"
	cQuery +=        " DK1.DK1_PRODUT"
	cQuery +=   " FROM "+RetSqlName('DK1')+" DK1"
	cQuery +=  " INNER JOIN "+RetSqlName('DK0')+" DK0"
	cQuery +=     " ON DK0.DK0_FILIAL = '"+OsFilial("DK0",cFilPed)+"'"
	cQuery +=    " AND DK0.DK0_REGID  = DK1.DK1_REGID"
	cQuery +=    " AND DK0.DK0_VIAGID = DK1.DK1_VIAGID"
	cQuery +=    " AND DK0.DK0_SITINT NOT IN ('4','5')"
	cQuery +=    " AND DK0.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE DK1.DK1_FILIAL = '"+OsFilial("DK1",cFilPed)+"'"
	cQuery +=    " AND DK1.DK1_FILPED = '"+cFilPed+"'"
	cQuery +=    " AND DK1.DK1_PEDIDO = '"+cPedido+"'"
	cQuery +=    " AND DK1.DK1_VIAGID = '"+cViagem+"'"
	cQuery +=    " AND EXISTS ( SELECT DK1A.R_E_C_N_O_"
	cQuery +=                       " FROM "+RetSqlName('DK1')+" DK1A"
	cQuery +=                      " WHERE DK1A.DK1_FILIAL = DK1.DK1_FILIAL"
	cQuery +=                        " AND DK1A.DK1_REGID  = DK1.DK1_REGID"
	cQuery +=                        " AND DK1A.DK1_VIAGID = DK1.DK1_VIAGID"
	cQuery +=                        " AND DK1A.DK1_PEDIDO <> DK1.DK1_PEDIDO"
	cQuery +=                        " AND DK1A.D_E_L_E_T_ = ' ')"
	cQuery +=    " AND DK1.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	If !Empty(cViagem)
		OsLogCPL("OMSXCPL6B -> VldOutPed -> Viagem ("+cValToChar(Trim(cFilPed))+"-"+cValToChar(Trim(cViagem))+"). Conteúdo de cQuery: " + cValToChar(Trim(cQuery)),"INFO")
	Else
		OsLogCPL("OMSXCPL6B -> VldOutPed -> Pedido ("+cValToChar(Trim(cFilPed))+"-"+cValToChar(Trim(cPedido))+"). Conteúdo de cQuery: " + cValToChar(Trim(cQuery)),"INFO")
	Endif
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	If (cAliasQry)->(!EoF())
		OsLogCPL("OMSXCPL6B -> VldOutPed -> Encontrou ao menos um registro.","INFO")
		lRet := .T.
	EndIf
	(cAliasQry)->(DbCloseArea())
Return lRet
//-----------------------------------------------------------
/*/{Protheus.doc} VldEstCarga
Valida estorno do item da carga
@author  amanda.vieira
@version P12
@since 12/12/2018
@version 1.0
@param lViagComp, Lógico , indica se a viagem completa será estornada
@param cCarga, Caracter, código da carga
@param cFilPed, Caracter, filial do pedido
@param cPedido, Caracter, número do pedido
@param cItem, Caracter, item do pedido
/*/
//-----------------------------------------------------------
Static Function VldEstCarga(lViagComp,cCarga,cFilPed,cPedido,cItem)
Local lRet      := .T.
Local cFilCarga := ""
Local cQuery    := ""
Local cAliasQry := ""
	//Posiciona na DAK
	DAK->(dbSetOrder(1)) //DAK_FILIAL+DAK_COD
	SC9->(dbSetOrder(5)) //C9_FILIAL+C9_CARGA
	SC9->(DbSeek(cFilPed+cCarga))
	cFilCarga := OsFilOpe(SC9->C9_CARGA,SC9->C9_SEQCAR,SC9->C9_SEQENT,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_PEDIDO)
	DAK->(DbSeek(OsFilial("DAK",cFilCarga)+cCarga))
	If lViagComp
		lRet := OMSVlEstDAK()
	Else
		cQuery := " SELECT SC9.R_E_C_N_O_ RECNOSC9"
		cQuery +=   " FROM "+RetSqlName('SC9')+" SC9"
		cQuery +=  " WHERE SC9.C9_FILIAL  = '"+cFilPed+"'"
		cQuery +=    " AND SC9.C9_PEDIDO  = '"+cPedido+"'"
		If !Empty(cItem)
			cQuery +=    " AND SC9.C9_ITEM    = '"+cItem+"'"
		EndIf
		cQuery +=    " AND SC9.C9_CARGA   = '"+cCarga+"'"
		cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		OsLogCPL("OMSXCPL6B -> VldEstCarga -> Pedido ("+cValToChar(Trim(cFilPed))+"-"+cValToChar(Trim(cPedido))+"). Conteudo da variavel cQuery: " + cValToChar(Trim(cQuery)),"INFO")
		cAliasQry := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		While (cAliasQry)->(!EoF()) .And. lRet
			OsLogCPL("OMSXCPL6B -> VldEstCarga -> Conteudo de RECNOSC9: " + cValToChar((cAliasQry)->RECNOSC9),"INFO")
			SC9->(DbGoTo((cAliasQry)->RECNOSC9))
			lRet := OMSVlEstSC9()
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	EndIf
Return lRet
//-----------------------------------------------------------
/*/{Protheus.doc} ProcEstCarg
Processa estorno da carga
@author  amanda.vieira
@version P12
@since 12/12/2018
@version 1.0
@param cCarga, Caracter, código da carga
@param cFilPed, Caracter, filial do pedido
@param cPedido, Caracter, número do pedido
@param cSeqInt, Caracter, sequência de integração
@param cQuebraId, characters, id da quebra do Cockpit
/*/
//-----------------------------------------------------------
Static Function ProcEstCarg(cCarga,cFilPed,cPedido,cSeqInt,cQuebraId)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasSC9 := ""
Local cItem     := ""
Local cProduto  := ""
Local oModelSeq := Iif(!Empty(oModel),oModel:GetModel("MdGridSC6"),Nil)
Local nSaldo    := 0
	cQuery := " SELECT DK3.DK3_ITEMPE,"
	cQuery +=        " DK3.DK3_PRODUT,"
	cQuery +=        " DK3.DK3_QTDINT"
	cQuery +=   " FROM "+RetSqlName('DK3')+" DK3"
	cQuery +=  " WHERE DK3.DK3_FILIAL = '"+cFilPed+"'"
	cQuery +=    " AND DK3.DK3_PEDIDO = '"+cPedido+"'"
	cQuery +=    " AND DK3.DK3_SEQUEN = '"+cSeqInt+"'"
	If lQuebId
		cQuery +=    " AND DK3.DK3_QUEBID = '"+cQuebraId+"'"
	EndIf
	cQuery +=    " AND DK3.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	OsLogCPL("OMSXCPL6B -> ProcEstCarg -> Pedido ("+cValToChar(Trim(cFilPed))+"-"+cValToChar(Trim(cPedido))+"). Conteudo da variavel cQuery 1: " + cValToChar(Trim(cQuery)),"INFO")
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!EoF())
		cItem    := (cAliasQry)->DK3_ITEMPE
		cProduto := (cAliasQry)->DK3_PRODUT
		If RegMarcado(cSeqInt,cItem,cProduto,cQuebraId)
			//Caso estorno por pedido posicionado, utiliza o valor digitado em tela,
			//ou então utiliza a quantidade total integrada
			If Empty(oModelSeq)
				nSaldo := (cAliasQry)->DK3_QTDINT
			Else
				nSaldo := oModelSeq:GetValue("C6_QTDINT")
			EndIf
			cQuery := " SELECT SC9.R_E_C_N_O_ RECNOSC9"
			cQuery +=   " FROM "+RetSqlName('SC9')+" SC9"
			cQuery +=  " WHERE SC9.C9_FILIAL  = '"+cFilPed+"'"
			cQuery +=    " AND SC9.C9_PEDIDO  = '"+cPedido+"'"
			cQuery +=    " AND SC9.C9_CARGA   = '"+cCarga+"'"
			cQuery +=    " AND SC9.C9_ITEM    = '"+cItem+"'
			cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			OsLogCPL("OMSXCPL6B -> ProcEstCarg -> Conteudo da variavel cQuery 2: " + cValToChar(Trim(cQuery)),"INFO")
			cAliasSC9 := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasSC9, .F., .T.)
			While (cAliasSC9)->(!EoF()) .And. lRet .And. nSaldo > 0
				SC9->(DbGoTo((cAliasSC9)->RECNOSC9))
				If (QtdComp(SC9->C9_QTDLIB) > QtdComp(nSaldo))
					OmsDivSC9(nSaldo)
				EndIf
				If (lRet := OMSEstSC9())
					nSaldo -= SC9->C9_QTDLIB
				EndIf
				(cAliasSC9)->(DbSkip())
			EndDo
			(cAliasSC9)->(DbCloseArea())
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
Return lRet
//-----------------------------------------------------------
/*/{Protheus.doc} AltStatus
Altera status do pedido e da sequência de integração
@author  amanda.vieira
@version P12
@since 12/12/2018
@version 1.0
@param cFilPed, Caracter, filial do pedido
@param cPedido, Caracter, número do pedido
@param cSeqInt, Caracter, sequência de integração
@param cCarga, Caracter, código da carga
@param cViagem, Caracter, código da viagem
@param cQuebraId, characters, id da quebra do Cockpit
/*/
//-----------------------------------------------------------
Static Function AltStatus(cFilPed,cPedido,cSeqInt,cCarga,cViagem,cQuebraId)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := ""
Local cAliasSeq := ""
Local cItem     := ""
Local cProduto  := ""
Local cCodFil   := ""
Local cIdPrd    := ""
Local nQtdInt   := 0
Local nQtdPeso  := 0
Local nQtdPreco := 0
Local nQtdVolume:= 0
Local nSaldo    := 0

	//Altera tabela de sequência de integração (DK3)
	If TableInDic('DK3')
		cQuery := " SELECT DK3.R_E_C_N_O_ DK3RECNO,"
		cQuery +=        " DK3.DK3_ITEMPE,"
		cQuery +=        " DK3.DK3_PRODUT"
		cQuery +=   " FROM "+RetSqlName('DK3')+" DK3"
		cQuery +=  " WHERE DK3.DK3_FILIAL = '"+cFilPed+"'"
		cQuery +=    " AND DK3.DK3_PEDIDO = '"+cPedido+"'"
		cQuery +=    " AND DK3.DK3_SEQUEN = '"+cSeqInt+"'"
		If lQuebId
			cQuery += " AND DK3.DK3_QUEBID = '"+cQuebraId+"'"
		EndIf
		cQuery +=    " AND DK3.D_E_L_E_T_ = ' '"
		OsLogCPL("OMSXCPL6B -> AltStatus -> Pedido ("+cValToChar(Trim(cFilPed))+"-"+cValToChar(Trim(cPedido))+"). Conteudo da variavel cQuery 1: " + cValToChar(Trim(cQuery)),"INFO")
		cAliasQry := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
		While (cAliasQry)->(!EoF())
			If RegMarcado(cSeqInt,(cAliasQry)->DK3_ITEMPE,(cAliasQry)->DK3_PRODUT,cQuebraId)
				nSaldo := OmsCplQAlt(cSeqInt,(cAliasQry)->DK3_ITEMPE,(cAliasQry)->DK3_PRODUT,cQuebraId)
				DK3->(DbGoTo((cAliasQry)->DK3RECNO))
				Reclock('DK3',.F.)
				If nSaldo == 0
					DK3->DK3_STATUS := '2' //Cancelado
				Else
					DK3->DK3_STATUS := '3' //Cancelado Parcial
					DK3->DK3_QTDINT := nSaldo
				EndIf
				DK3->(MsUnlock())
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	EndIf

	//Altera tabela do pedido de venda (SC6)
	cQuery := " SELECT R_E_C_N_O_ RECNOSC6,"
	cQuery +=        " SC6.C6_ITEM,"
	cQuery +=        " SC6.C6_PRODUTO"
	cQuery +=   " FROM "+RetSqlName('SC6')+" SC6"
	cQuery +=  " WHERE SC6.C6_FILIAL  = '"+cFilPed+"'"
	cQuery +=    " AND SC6.C6_NUM     = '"+cPedido+"'"
	cQuery +=    " AND SC6.D_E_L_E_T_ = ' '"
	OsLogCPL("OMSXCPL6B -> AltStatus -> Pedido ("+cValToChar(Trim(cFilPed))+"-"+cValToChar(Trim(cPedido))+"). Conteudo da variavel cQuery 2: " + cValToChar(Trim(cQuery)),"INFO")
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	While (cAliasQry)->(!EoF())
		If RegMarcado(cSeqInt,(cAliasQry)->C6_ITEM,(cAliasQry)->C6_PRODUTO,cQuebraId)
			//Busca quantidade integrada total do pedido
			nQtdInt := Cpl6QtdInt(cFilPed,cPedido,(cAliasQry)->C6_ITEM,(cAliasQry)->C6_PRODUTO)
			//Busca item do pedido para alteração do status de integração
			SC6->(DbGoTo((cAliasQry)->RECNOSC6))
			Reclock('SC6',.F.)
			If nQtdInt > 0
				SC6->C6_INTROT := '4' //Integrado parcialmente
			Else
				SC6->C6_INTROT := '1' //Não integrado
				SC6->C6_DATCPL := CtoD('')
				SC6->C6_HORCPL := ''
			EndIf
			SC6->(MsUnlock())
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	//Altera tabela da viagem (DK1)
		cQuery := " SELECT DK3.DK3_ITEMPE,"
		cQuery +=        " DK3.DK3_PRODUT"
		cQuery +=   " FROM "+RetSqlName('DK3')+" DK3"
		cQuery +=  " WHERE DK3.DK3_FILIAL = '"+cFilPed+"'"
		cQuery +=    " AND DK3.DK3_PEDIDO = '"+cPedido+"'"
		cQuery +=    " AND DK3.DK3_SEQUEN = '"+cSeqInt+"'"
		If lQuebId
			cQuery += " AND DK3.DK3_QUEBID = '"+cQuebraId+"'"
		EndIf
		cQuery +=    " AND DK3.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		OsLogCPL("OMSXCPL6B -> AltStatus -> Conteudo da variavel cQuery 3: " + cValToChar(Trim(cQuery)),"INFO")
		cAliasSeq := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSeq,.F.,.T.)
		While (cAliasSeq)->(!EoF())
			cItem    := (cAliasSeq)->DK3_ITEMPE
			cProduto := (cAliasSeq)->DK3_PRODUT
			cCodFil    := OMSXGETFIL("SC5",.F.)		
			If !Empty(cSeqInt)
				cIdPrd  := RTrim(cCodFil)+ "-" + RTrim(cSeqInt) + "-" + RTrim(cPedido) + "-" + RTrim(cItem)
			Else
				cIdPrd  := RTrim(cCodFil)+ "-" + RTrim(SC5->C5_NUM)
			EndIf
			If RegMarcado(cSeqInt,cItem,cProduto,cQuebraId)
				cQuery := " SELECT DK1.R_E_C_N_O_ RECNODK1,"
				cQuery +=        " DK1.DK1_ITEMPE,"
				cQuery +=        " DK1.DK1_PRODUT"
				cQuery +=   " FROM "+RetSqlName('DK1')+" DK1"
				cQuery +=  " INNER JOIN "+RetSqlName('DK0')+" DK0"
				cQuery +=     " ON DK0.DK0_FILIAL = '"+OsFilial("DK0",cFilPed)+"'"
				cQuery +=    " AND DK0.DK0_REGID  = DK1.DK1_REGID"
				cQuery +=    " AND DK0.DK0_VIAGID = DK1.DK1_VIAGID"
				cQuery +=    " AND DK0.DK0_SITINT NOT IN ('4','5')"
				cQuery +=    " AND DK0.D_E_L_E_T_ = ' '"
				cQuery +=  " WHERE DK1.DK1_FILIAL = '"+OsFilial("DK1",cFilPed)+"'"
				cQuery +=    " AND DK1.DK1_FILPED = '"+cFilPed+"'"
				cQuery +=    " AND DK1.DK1_PEDIDO = '"+cPedido+"'"
				cQuery +=    " AND DK1.DK1_VIAGID = '"+cViagem+"'"
				cQuery +=    " AND DK1.DK1_ITEMPE = '"+cItem+"'"
				cQuery +=    " AND DK1.DK1_ORITID = '"+cIdPrd+"'"
				If lQuebId
					cQuery += " AND DK1.DK1_QUEBID = '"+cQuebraId+"'"
				EndIf
				cQuery +=    " AND DK1.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				OsLogCPL("OMSXCPL6B -> AltStatus -> Conteudo da variavel cQuery 4: " + cValToChar(Trim(cQuery)),"INFO")
				cAliasQry := GetNextAlias()
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
				While (cAliasQry)->(!EoF())
					If RegMarcado(cSeqInt,(cAliasQry)->DK1_ITEMPE,(cAliasQry)->DK1_PRODUT,cQuebraId)
						nSaldo := OmsCplQAlt(cSeqInt,(cAliasQry)->DK1_ITEMPE,(cAliasQry)->DK1_PRODUT,cQuebraId)
						DK1->(DbGoTo((cAliasQry)->RECNODK1))
						If nSaldo == 0
							Reclock('DK1',.F.)
							DK1->(DbDelete())
							DK1->(MsUnlock())
							OsLogCPL("OMSXCPL6B -> AltStatus -> Registro DK1 Deletado","INFO")											 
						Else
							//Calcula os valores unitários com base no que já foi recebido do XML
							nQtdPeso   := nSaldo * (DK1->DK1_PESO / DK1->DK1_QTD)
							nQtdVolume := nSaldo * (DK1->DK1_VOLUME / DK1->DK1_QTD)
							nQtdPreco  := nSaldo * (DK1->DK1_PRECO / DK1->DK1_QTD)
							Reclock('DK1',.F.)
							DK1->DK1_PESO   := nQtdPeso
							DK1->DK1_VOLUME := nQtdVolume
							DK1->DK1_PRECO  := nQtdPreco
							
							DK1->DK1_QTD    := nSaldo
							DK1->(MsUnlock())
							OsLogCPL("OMSXCPL6B -> AltStatus ->Peso: " + cValToChar(nQtdPeso),"INFO")
							OsLogCPL("OMSXCPL6B -> AltStatus ->Volume: " + cValToChar(nQtdVolume),"INFO")
							OsLogCPL("OMSXCPL6B -> AltStatus ->Preco: " + cValToChar(nQtdPreco),"INFO")
							OsLogCPL("OMSXCPL6B -> AltStatus ->Quantidade: " + cValToChar(nSaldo),"INFO")																
						EndIf
					EndIf
					(cAliasQry)->(DbSkip())
				EndDo
				(cAliasQry)->(DbCloseArea())
			EndIf
			(cAliasSeq)->(DbSkip())
		EndDo
		(cAliasSeq)->(DbCloseArea())
	
Return lRet
// ---------------------------------------------------------
/*/{Protheus.doc} VldQtdInt
Valida quantidade do cancelamento com base no saldo do model
@author amanda.vieira
@since 12/12/2018
@version 1.0
/*/
// ---------------------------------------------------------
Static Function VldQtdInt(oModel)
Local lRet      := .T.
    If oModel:GetValue("C6_QTDINT") > 0
        If oModel:GetValue("C6_QTDORI") < oModel:GetValue("C6_QTDINT")
            oModel:GetModel():SetErrorMessage( , ,  , '', OMSCPL6B01, STR0023, STR0024, '', '') // Saldo integrado é menor que a quantidade digitada para cancelamento. // Ajuste a quantidade digitada.
            lRet := .F.
        EndIf
    ElseIf oModel:GetValue("C6_QTDINT") < 0
        oModel:GetModel():SetErrorMessage( , ,  , '', OMSCPL6B02, STR0025, STR0024, '', '')  // A quantidade informada não pode ser negativa. // Ajuste a quantidade digitada.
        lRet := .F.
	Else
		oModel:LoadValue("MARCA",.F.)
    EndIf
Return lRet
//-----------------------------------------------------------
/*/{Protheus.doc} MarcaSeqInt
Validação ao marcar o campo checkbox
@author  amanda.vieira
@version P12
@since 12/12/2018
@version 1.0
/*/
//-----------------------------------------------------------
Static Function MarcaSeqInt(oModelDK3)
Local lRet      := .T.
Local oModelPed := oModel:GetModel("MdFieldSC6")
Local lMarca    := oModelDK3:GetValue("MARCA")
Local lViagComp := ViagemComp(oModelDK3,oModelDK3:GetValue("DK3_VIAGID")) .And. !VldOutPed(oModelPed:GetValue("C5_FILIAL"),oModelPed:GetValue("C5_NUM"),oModelDK3:GetValue("DK3_VIAGID"))//Indica se é um estorno de viagem completa
Local cSequen   := oModelDK3:GetValue("DK3_SEQUEN")
Local oView     := FWViewActive()
Local cFalha    := ""
Local nLinAtu   := oModelDK3:GetLine()
Local nI        := 0
	If !PermEstCar(oModelPed:GetValue("C5_FILIAL"),oModelPed:GetValue("C5_NUM"),oModelDK3:GetValue("DK3_CARGA"),oModelDK3:GetValue("DK3_VIAGID"),oModelDK3:GetValue("DK3_SEQUEN"),lViagComp,oModelDK3:GetValue("C6_ITEM"),oModelDK3:GetValue("C6_PRODUTO"),@cFalha,.F.) 
		oModelDK3:GetModel():SetErrorMessage(oModel:GetId(),,,,OMSCPL6B08,cFalha) // O item selecionado possuí carga e o sistema está parametrizado para não permitir o estorno automático // Ajuste o parâmetro de estorno automático (MV_CPLESCG) ou estorne a carga manualmente.
		lRet := .F.
	Else
		If lMarkAll
			For nI := 1 To oModelDK3:Length()
				oModelDK3:GoLine(nI)
				If AllTrim(oModelDK3:GetValue("DK3_SEQUEN"))  == AllTrim(cSequen)
					oModelDK3:LoadValue("MARCA",lMarca)
				EndIf
			Next nI
			oModelDK3:GoLine(nLinAtu)
			If ValType(__lAutoma) !='U' .And. !__lAutoma
				oView:Refresh()
			EndIf
		EndIf
	EndIf
Return lRet
// ---------------------------------------------------------
/*/{Protheus.doc} OMSAliasSC6
Atribui informação do alias da tabela temporária do browse da tela principal
@author amanda.vieira
@since 12/12/2018
@version 1.0
/*/
// ---------------------------------------------------------
Static __cAliasTemp := Nil 
Static __lAutoma    := .F. 
Function OMSCPL6BAT(cAliasTemp,lAutoma)
	__cAliasTemp := cAliasTemp
	__lAutoma    := lAutoma
Return Nil
// ---------------------------------------------------------
/*/{Protheus.doc} OmsCplQAlt
Retorna quantidade para alteração
@author amanda.vieira
@since 12/12/2018
@version 1.0
@param cPedido, Caracter, número do pedido
@param cSeqInt, Caracter, sequência de integração
@param cItem, Caracter, item do pedido
@param cProduto, Caracter, código do produto
/*/
// ---------------------------------------------------------
Function OmsCplQAlt(cSeqInt,cItem,cProduto,cQuebraId)
Local nQtdAlt   := 0
Local nQtdAltPE := 0 
Local oModelSeq := Nil
Local lOMSCPLQAT := ExistBlock("OMSCPLQAT") 
	
	If !Empty(oModel)
		oModelSeq := oModel:GetModel("MdGridSC6")
		
		If lQuebId
			If oModelSeq:SeekLine({{'C6_FILIAL',SC5->C5_FILIAL},{'C6_NUM',SC5->C5_NUM},{'C6_ITEM',cItem},{'C6_PRODUTO',cProduto},{'DK3_SEQUEN',cSeqInt},{'DK3_QUEBID',cQuebraId}})
				If oModelSeq:GetValue("MARCA")
					nQtdAlt := oModelSeq:GetValue("C6_QTDORI") - oModelSeq:GetValue("C6_QTDINT")
				Else
					nQtdAlt := oModelSeq:GetValue("C6_QTDORI")
				EndIf
			EndIf
		Else
			If oModelSeq:SeekLine({{'C6_FILIAL',SC5->C5_FILIAL},{'C6_NUM',SC5->C5_NUM},{'C6_ITEM',cItem},{'C6_PRODUTO',cProduto},{'DK3_SEQUEN',cSeqInt}})
				If oModelSeq:GetValue("MARCA")
					nQtdAlt := oModelSeq:GetValue("C6_QTDORI") - oModelSeq:GetValue("C6_QTDINT")
				Else
					nQtdAlt := oModelSeq:GetValue("C6_QTDORI")
				EndIf
			EndIf		
		EndIf
	EndIf
	
	//Ponto de entrada para ajustar a quantidade
	If lOMSCPLQAT 
		nQtdAltPE := ExecBlock("OMSCPLQAT", .F., .F., {cSeqInt,cItem,cProduto,cQuebraId,nQtdAlt})				
		If ValType(nQtdAltPE)=="N"
			nQtdAlt := nQtdAltPE
		EndIf
	EndIf
	
Return nQtdAlt
// ---------------------------------------------------------
/*/{Protheus.doc} RegMarcado
Verifica se registro encontra-se marcado
@author amanda.vieira
@since 12/12/2018
@version 1.0
@param cSeqInt, Caracter, sequência de integração
@param cItem, Caracter, item do pedido
@param cProduto, Caracter, código do produto
@param cQuebraId, characters, id da quebra do Cockpit
/*/
// ---------------------------------------------------------
Static Function RegMarcado(cSeqInt,cItem,cProduto,cQuebraId)
Local lMarca    := .T.
Local oModelSeq := Nil
	If lQuebId
		If !Empty(oModel)
			oModelSeq := oModel:GetModel("MdGridSC6")
			If oModelSeq:SeekLine({{'C6_FILIAL',SC5->C5_FILIAL},{'C6_NUM',SC5->C5_NUM},{'C6_ITEM',cItem},{'C6_PRODUTO',cProduto},{'DK3_SEQUEN',cSeqInt},{'DK3_QUEBID',cQuebraId}})
				lMarca := oModelSeq:GetValue("MARCA")
			Else 
				lMarca := .F.
			EndIf
		EndIf
	Else
		If !Empty(oModel)
			oModelSeq := oModel:GetModel("MdGridSC6")
			If oModelSeq:SeekLine({{'C6_FILIAL',SC5->C5_FILIAL},{'C6_NUM',SC5->C5_NUM},{'C6_ITEM',cItem},{'C6_PRODUTO',cProduto},{'DK3_SEQUEN',cSeqInt}})
				lMarca := oModelSeq:GetValue("MARCA")
			Else 
				lMarca := .F.
			EndIf
		EndIf
	EndIf
Return lMarca
// ---------------------------------------------------------
/*/{Protheus.doc} OMSCPL6TMP
Atribui informação do objeto da tabela temporária do browse da tela principal
@author amanda.vieira
@since 19/12/2019
@version 1.0
@param oTempSC6, Objeto, tabela temporária
/*/
// ---------------------------------------------------------
Static __oTempSC6 := Nil 
Function OMSCPL6TMP(oTempSC6)
	If ValType(oTempSC6) == "O"
		__oTempSC6 := oTempSC6
	EndIf
Return oTempSC6
// ---------------------------------------------------------
/*/{Protheus.doc} PermEstCar
Verifica se permite o estorno da carga
@author amanda.vieira
@since 12/06/2019
@version 1.0
@param cFilPed, Caracter, filial do pedido
@param cPedido, Caracter, número do pedido
@param cCarga, Caracter, código da carga
@param cViagem, Caracter, código da viagem
@param cSeqInt, Caracter, código da sequência de integração
@param lViagComp, Lógico , indica se a viagem completa será estornada
@param cItem, Caracter, item do pedido
@param cProduto, Caracter, item do pedido
@param cFalha, Caracter, motivo do retorno falso
@param lEstPedSel, Lógico, indica se trata-se de um estorno sequência completa
/*/
// ---------------------------------------------------------
Static Function PermEstCar(cFilPed,cPedido,cCarga,cViagem,cSeqInt,lViagComp,cItem,cProduto,cFalha,lEstPedSel)
Local lRet   := .T.
Local aRetPE := {}
	If	ExistBlock("OMSCPL6A") //Ponto de entrada para substituir a validação da carga
		aRetPE := ExecBlock("OMSCPL6A",.F.,.F.,{cFilPed,cPedido,cCarga,cViagem,cSeqInt,lViagComp,cItem,cProduto,lEstPedSel})
		aRetPE := If(ValType(aRetPE)=="A",aRetPE,{})
		If !Empty(aRetPE)
			If !(lRet := Iif(ValType(aRetPE[1])=="L",aRetPE[1],.T.))
				If (ValType(aRetPE[2])=="C")
					cFalha := aRetPE[2]
				EndIf
			EndIf
		EndIf
	Else
		If !Empty(cCarga) .And. !lEsCarAut
			cFalha := STR0037 //A sequência de integração possui carga gerada e o sistema está parametrizado para não permitir o estorno automático. Ajuste o parâmetro de estorno automático (MV_CPLESCG) ou estorne a carga manualmente.
			lRet := .F.
		EndIf	
	EndIf
Return lRet
