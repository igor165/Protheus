#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA996A.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA996A
@description	Configurações de calculo
@sample	 		TECA996A()
@author			Kaique Schiller
@since			19/07/2022
/*/
//------------------------------------------------------------------------------
Function TECA996A()
Local oMBrowse := FWmBrowse():New()

oMBrowse:SetAlias("TCW")
oMBrowse:SetDescription(STR0001)	//"Configurações de Calculo"
oMBrowse:Activate()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@description	Define o menu funcional.
@sample	 		MenuDef()
@return			Opções da Rotina.
@author			Kaique Schiller
@since			19/07/2022
/*/

//------------------------------------------------------------------------------
Static Function MenuDef(aRotina)
Default	aRotina	:= {}

ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw" 		   OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TECA996A" OPERATION MODEL_OPERATION_VIEW ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TECA996A" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TECA996A" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TECA996A" OPERATION MODEL_OPERATION_DELETE ACCESS 0 // "Excluir"
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.TECA996A" OPERATION 9 ACCESS 0 // "Copiar"

Return(aRotina)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@description	Definição do Model
@sample	 		ModelDef()
@author			Kaique Schiller
@since			19/07/2022
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oStrTCW	:= FWFormStruct( 1, "TCW")
Local oStrTCX1 	:= FWFormStruct( 1, "TCX")
Local oStrTCX2 	:= FWFormStruct( 1, "TCX")
Local oStrTDZ 	:= FWFormStruct( 1, "TDZ")
Local oStrTEX1 	:= FWFormStruct( 1, "TEX")
Local oStrTEX2 	:= FWFormStruct( 1, "TEX")
Local oModel
Local xAux

xAux := FwStruTrigger( 'TCW_CODCCT', 'TCW_DSCCCT', 'Posicione("SWY",1,xFilial("SWY")+FwFldGet("TCW_CODCCT"),"WY_DESC")', .F. )
	oStrTCW:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TCX_TIPTBL', 'TCX_TABELA', 'At996aGtTb("1")', .F. )
	oStrTCX1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TCX_TIPTBL', 'TCX_TABELA', 'At996aGtTb("2")', .F. )
	oStrTCX2:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TCX_TIPTBL', 'TCX_CODTBL', '""', .F. )
	oStrTCX1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	oStrTCX2:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TCX_CODTBL', 'TCX_PORCEN', 'At996aGtPc("1")', .F. )
	oStrTCX1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TCX_CODTBL', 'TCX_PORCEN', 'At996aGtPc("2")', .F. )
	oStrTCX2:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TCX_TIPTBL', 'TCX_PORCEN', '', .F. )
	oStrTCX1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	oStrTCX2:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TCW_CODCCT', 'TCW_CODCCT', 'At996aGCCT()', .F. )
	oStrTCW:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TDZ_VALOR', 'TDZ_VLRDIF', 'FwFldGet("TDZ_VALOR")', .F. )
	oStrTDZ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

oStrTCX1:SetProperty('TCX_CODTBL',MODEL_FIELD_VALID,{|oMdl|At996aVlBn(oMdl,FwFldGet("TCW_CODCCT") )})
oStrTCX2:SetProperty('TCX_CODTBL',MODEL_FIELD_VALID,{|oMdl|At996aVlBn(oMdl,FwFldGet("TCW_CODCCT") )})

oStrTCX1:SetProperty('TCX_TIPOPE',MODEL_FIELD_INIT,{|| "1" } )
oStrTCX2:SetProperty('TCX_TIPOPE',MODEL_FIELD_INIT,{|| "2" } )

oStrTCX1:SetProperty( "TCX_CODTBL", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TCX_CODTBL',"1" ) } )
oStrTCX2:SetProperty( "TCX_CODTBL", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TCX_CODTBL',"2" ) } )

oModel := MPFormModel():New("TECA996A", /*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )
oModel:AddFields("TCWMASTER",/*cOwner*/,oStrTCW, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetDescription(STR0001) //"Configurações de calculo"

oModel:AddGrid("TCXDETAIL1","TCWMASTER",oStrTCX1,{|oMdl,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTCX1(oMdl, nLine, cAcao, cCampo, xValue, xOldValue) },{|oMdl, nLine| PosLinTCX1(oMdl,nLine)},,, )
oModel:SetRelation("TCXDETAIL1", {{"TCX_FILIAL","xFilial('TCX')"}, {"TCX_CODTCW","TCW_CODIGO"}, {"TCX_TIPOPE",'"1"'}}, TCX->(IndexKey(1)))

oModel:AddGrid("TCXDETAIL2","TCWMASTER",oStrTCX2,{|oMdl,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTCX2(oMdl, nLine, cAcao, cCampo, xValue, xOldValue) },{|oMdl, nLine| PosLinTCX2(oMdl,nLine)},,, )
oModel:SetRelation("TCXDETAIL2", {{"TCX_FILIAL","xFilial('TCX')"}, {"TCX_CODTCW","TCW_CODIGO"}, {"TCX_TIPOPE",'"2"'} }, TCX->(IndexKey(1)))

oModel:AddGrid("TDZDETAIL","TCWMASTER",oStrTDZ,,{|oMdl, nLine| PosLinTDZ(oMdl,nLine)},,,)
oModel:SetRelation("TDZDETAIL", {{"TDZ_FILIAL","xFilial('TDZ')"}, {"TDZ_CODTCW","TCW_CODIGO"}}, TDZ->(IndexKey(1)))

oModel:AddGrid("TEXDETAIL1","TCWMASTER",oStrTEX1,/*{|oMdl,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTCX1(oMdl, nLine, cAcao, cCampo, xValue, xOldValue) }*/,/*{|oMdl, nLine| PosLinTCX1(oMdl,nLine)}*/,,, )
oModel:SetRelation("TEXDETAIL1", {{"TEX_FILIAL","xFilial('TEX')"}, {"TEX_CODTCW","TCW_CODIGO"}, {"TEX_TIPOPE",'"1"'}}, TEX->(IndexKey(1)))

oModel:AddGrid("TEXDETAIL2","TCWMASTER",oStrTEX2,/*{|oMdl,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTCX2(oMdl, nLine, cAcao, cCampo, xValue, xOldValue) }*/,/*{|oMdl, nLine| PosLinTCX2(oMdl,nLine)}*/,,, )
oModel:SetRelation("TEXDETAIL2", {{"TEX_FILIAL","xFilial('TEX')"}, {"TEX_CODTCW","TCW_CODIGO"}, {"TEX_TIPOPE",'"2"'} }, TEX->(IndexKey(1)))

oModel:GetModel("TCXDETAIL1"):SetFldNoCopy( { "TCX_CODIGO" } )
oModel:GetModel("TCXDETAIL2"):SetFldNoCopy( { "TCX_CODIGO" } )
oModel:GetModel("TDZDETAIL"):SetFldNoCopy(  { "TDZ_CODIGO" } )
oModel:GetModel("TEXDETAIL1"):SetFldNoCopy( { "TEX_CODIGO" } )
oModel:GetModel("TEXDETAIL2"):SetFldNoCopy( { "TEX_CODIGO" } )

oModel:GetModel('TCXDETAIL1'):SetOptional(.T.)
oModel:GetModel('TCXDETAIL2'):SetOptional(.T.)
oModel:GetModel('TDZDETAIL'):SetOptional(.T.)
oModel:GetModel('TEXDETAIL1'):SetOptional(.T.)
oModel:GetModel('TEXDETAIL2'):SetOptional(.T.)

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return(oModel)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@description	Definição da View
@sample	 		ViewDef()
@author			Kaique Schiller
@since			19/07/2022
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView  
Local oModel  := FWLoadModel("TECA996A")
Local oStrTCW := FWFormStruct( 2,"TCW")  
Local oStrTCX := FWFormStruct( 2,"TCX",{ | cCampo | !(AllTrim(cCampo) $ "TCX_CODIGO|TCX_CODTCW|TCX_TIPOPE") })
Local oStrTDZ := FWFormStruct( 2,"TDZ",{ | cCampo | !(AllTrim(cCampo) $ "TDZ_CODIGO|TDZ_CODTCW") })
Local oStrTEX := FWFormStruct( 2,"TEX",{ | cCampo | !(AllTrim(cCampo) $ "TEX_CODIGO|TEX_CODTCW|TEX_TIPOPE") })

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_TCW" ,oStrTCW, "TCWMASTER")
oView:AddGrid("VIEW_TCX1" ,oStrTCX, "TCXDETAIL1")
oView:AddGrid("VIEW_TCX2" ,oStrTCX, "TCXDETAIL2")
oView:AddGrid("VIEW_TDZ"  ,oStrTDZ, "TDZDETAIL")
oView:AddGrid("VIEW_TEX1" ,oStrTEX, "TEXDETAIL1")
oView:AddGrid("VIEW_TEX2" ,oStrTEX, "TEXDETAIL2")

oView:CreateHorizontalBox( "TOP"   , 30 )
oView:CreateHorizontalBox( "MIDDLE", 70 )

oView:CreateFolder( "ABAS", "MIDDLE")
oView:AddSheet("ABAS","ABA01", STR0008) // "Mão de Obra"
oView:CreateHorizontalBox( 'ID_ABA01' , 100,,, 'ABAS','ABA01' )

oView:AddSheet("ABAS","ABA02", STR0009) // "Encargos Sociais"
oView:CreateHorizontalBox( 'ID_ABA02' , 100,,, 'ABAS','ABA02' )

oView:AddSheet("ABAS","ABA03", STR0053) // "Benefícios"
oView:CreateHorizontalBox( 'ID_ABA03' , 100,,, 'ABAS','ABA03' )

oView:AddSheet("ABAS","ABA04", STR0054) // "Taxas"
oView:CreateHorizontalBox( 'ID_ABA04' , 100,,, 'ABAS','ABA04' )

oView:AddSheet("ABAS","ABA05", STR0055) // "Impostos"
oView:CreateHorizontalBox( 'ID_ABA05' , 100,,, 'ABAS','ABA05' )

oView:SetOwnerView("VIEW_TCW"	,"TOP")			// Cabeçalho
oView:SetOwnerView("VIEW_TCX1"	,"ID_ABA01")	// Grid de Mão de Obra
oView:SetOwnerView("VIEW_TCX2"	,"ID_ABA02")	// Grid de Encargos Sociais
oView:SetOwnerView("VIEW_TDZ"	,"ID_ABA03")	// Grid de Encargos Sociais
oView:SetOwnerView("VIEW_TEX1"	,"ID_ABA04")	// Grid de Taxas
oView:SetOwnerView("VIEW_TEX2"	,"ID_ABA05")	// Grid de Impostos

oView:AddIncrementField('VIEW_TCX1' , 'TCX_ITEM' )
oView:AddIncrementField('VIEW_TCX2' , 'TCX_ITEM' )
oView:AddIncrementField('VIEW_TDZ'  , 'TDZ_ITEM' )

Return(oView)

//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados
@description	Inicialização dos dados
@sample	 		InitDados()
@author			Kaique Schiller
@since			19/07/2022
/*/
//------------------------------------------------------------------------------
Static Function InitDados(oMdl)
Local nOperation := oMdl:GetOperation()

If nOperation == MODEL_OPERATION_INSERT
	FwMsgRun(Nil,{|| At996GerLn(oMdl)}, Nil, STR0010) 
Endif

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aGtTb
@description	Gatilho do campo TCX_TIPTBL
@sample	 		At996aGtTb()
@author			Kaique Schiller
@since			19/07/2022
/*/
//------------------------------------------------------------------------------
Function At996aGtTb(cTip)
Local cRet := ""
Local oMdl := FwModelActive()

If cTip == "1" .And. oMdl:GetValue('TCXDETAIL1',"TCX_TIPTBL") == "1"
	cRet := "1"
Elseif cTip == "2" .And. oMdl:GetValue('TCXDETAIL2',"TCX_TIPTBL") == "1"
	cRet := "1"
Endif

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996GerLn
@description	Geração de linhas no grid TCX
@sample	 		At996GerLn()
@author			Kaique Schiller
@since			19/07/2022
/*/
//------------------------------------------------------------------------------
Static Function At996GerLn(oMdl)
Local oMdlTCX1 := oMdl:GetModel("TCXDETAIL1")
Local oMdlTCX2 := oMdl:GetModel("TCXDETAIL2")
Local nX := 0
Local aMaoObra := At996aMaOb()
Local aEncargos := At996aEcrg()
	
For nX := 1 To Len(aMaoObra)
	If !Empty(oMdlTCX1:GetValue("TCX_DESCRI"))
		oMdlTCX1:AddLine()
	Endif
	oMdlTCX1:SetValue("TCX_DESCRI",aMaoObra[nX])
	oMdlTCX1:SetValue("TCX_TIPTBL","2")
Next nX

For nX := 1 To Len(aEncargos)
	If !Empty(oMdlTCX2:GetValue("TCX_DESCRI"))
		oMdlTCX2:AddLine()
	Endif
	oMdlTCX2:SetValue("TCX_DESCRI",aEncargos[nX,1])
	If !Empty(aEncargos[nX,2])
		oMdlTCX2:SetValue("TCX_TIPTBL","1")
		oMdlTCX2:SetValue("TCX_TABELA","2")
		oMdlTCX2:SetValue("TCX_CODTBL",aEncargos[nX,2])
	Else
		oMdlTCX2:SetValue("TCX_TIPTBL","2")
	Endif
Next nX

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT996When
@description	When dos campos da TCX
@sample	 		AT996When()
@author			Kaique Schiller
@since			19/07/2022
/*/
//------------------------------------------------------------------------------
Function AT996When( oMdl, cCampo, cTip )
Local lRet := .T.
Local oMdlTCW := oMdl:GetModel("TCWMASTER")
Local oMdlTCX1 := oMdl:GetModel("TCXDETAIL1")
Local oMdlTCX2 := oMdl:GetModel("TCXDETAIL2")

If !IsInCallStack("InitDados")
	If cCampo == "TCX_CODTBL"
		If !Empty(oMdlTCW:GetValue("TCW_CODCCT"))			
			If cTip == "1" .And. oMdlTCX1:GetValue("TCX_TABELA") <> "1"
				lRet := .F.
			Elseif cTip == "2" .And. oMdlTCX2:GetValue("TCX_TABELA") <> "1"
				lRet := .F.
			Endif
		Else
			lRet := .F.		
		EndIf		
	Endif
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTCX1
@description	Função de Prevalidacao do grid Mão de Obra
@sample	 		PreLinTCX2()
@author			Natacha Romeiro
@since			27/07/22
/*/
//------------------------------------------------------------------------------
Function PreLinTCX1(oMdl,nLine,cAcao,cCampo, xValue, xOldValue)
Local lRet := .T.
Local nLinhas := Len(At996aMaOb())

If cAcao == "DELETE" .And. Val(oMdl:GetValue("TCX_ITEM")) <= nLinhas
	Help(,, "PreLinTCX1",,STR0011 ,1,0,,,,,,{STR0012}) //"Não é possível excluir um item incluso pelo sistema."##"Realize a inclusão de outro item."
	lRet := .F.
Endif

If !IsInCallStack("InitDados") .And. lRet .And. cAcao == "SETVALUE" .And. Val(oMdl:GetValue("TCX_ITEM")) <= nLinhas
	If cCampo == "TCX_DESCRI"
		Help(,, "PreLinTCX1",,STR0013,1,0,,,,,,{STR0012}) //"Não é possível alterar a descrição de um item incluso pelo sistema."##"Realize a inclusão de outro item."
		lRet := .F.
	Endif
Endif

If lRet .And. cAcao == "UNDELETE"
	If oMdl:GetValue("TCX_TABELA") == "1" .And. !Empty(oMdl:GetValue("TCX_CODTBL")) .And. !AtCdTabOk(oMdl:GetValue("TCX_CODTBL"),FwFldGet("TCW_CODCCT"))
		Help(,, "PreLinTCX1",,STR0049,1,0,,,,,,{STR0050}) //"Não é possível retirar a deleção desse item, o código da CCT não está vinculado a essa verba."##"Realize a inclusão de um novo item."
		lRet := .F.
	Endif
Endif

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTCX2
@description	Função de Prevalidacao do grid Encargos Sociais 
@sample	 		PreLinTCX2()
@author			Kaique Schiller
@since			19/07/2022
/*/
//------------------------------------------------------------------------------
Function PreLinTCX2(oMdl,nLine,cAcao,cCampo, xValue, xOldValue)
Local lRet := .T.
Local nLinhas := Len(At996aEcrg())

If cAcao == "DELETE" .And. Val(oMdl:GetValue("TCX_ITEM")) <= nLinhas
	Help(,, "PreLinTCX2",,STR0011 ,1,0,,,,,,{STR0012}) //"Não é possível excluir um item incluso pelo sistema."##"Realize a inclusão de outro item."
	lRet := .F.
Endif

If !IsInCallStack("InitDados") .And. lRet .And. cAcao == "SETVALUE" .And. Val(oMdl:GetValue("TCX_ITEM")) <= nLinhas
	If cCampo == "TCX_DESCRI"
		Help(,, "PreLinTCX2",,STR0013,1,0,,,,,,{STR0012}) //"Não é possível alterar a descrição de um item incluso pelo sistema."##"Realize a inclusão de outro item."
		lRet := .F.
	Endif
	If cCampo == "TCX_TIPTBL" .And. oMdl:GetValue("TCX_TABELA") == "2" 
		Help(,, "PreLinTCX2",,STR0014,1,0,,,,,,{STR0012}) //"Não é possível alterar o tipo da tabela REB de um item incluso pelo sistema."##"Realize a inclusão de outro item."
		lRet := .F.
	Endif
Endif

If lRet .And. cAcao == "UNDELETE"
	If oMdl:GetValue("TCX_TABELA") == "1" .And. !Empty(oMdl:GetValue("TCX_CODTBL")) .And. !AtCdTabOk(oMdl:GetValue("TCX_CODTBL"),FwFldGet("TCW_CODCCT"))
		Help(,, "PreLinTCX2",,STR0049,1,0,,,,,,{STR0050}) //"Não é possível retirar a deleção desse item, o código da CCT não está vinculado a essa verba."##"Realize a inclusão de um novo item."
		lRet := .F.
	Endif
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aFlCCT
	Filtro da consulta padrão TCX_CODTBL
@author		Kaique Schiller
@since		20/06/2022
/*/
//-------------------------------------------------------------------------------
Function At996aFlCCT()
Local cFiltro := "@#"
Local cCodCCT :=  FwFldGet("TCW_CODCCT")

cFiltro += '(REB->REB_FILIAL == "' + xFilial("REB")  +'" .And. REB->REB_CODCCT == "' + cCodCCT+ '" )'

Return cFiltro+"@#"

//------------------------------------------------------------------------------
/*/{Protheus.doc} AtCdTabOk
	Verifica a existencia do codigo CCT na tabela REB
@author	Natacha Romeiro
@since		25/07/2022
/*/
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function AtCdTabOk(cCodSRV,cCodCCT)
Local lRet 		:= .T.
Local cAlias    := GetNextAlias()

BeginSql Alias cAlias
	SELECT 1		
	FROM  %table:REB% REB 
	WHERE REB.%NotDel%
		AND REB.REB_FILIAL = %xFilial:REB%
		AND REB.REB_CODSRV = %exp:cCodSRV%
		AND REB.REB_FILCCT = %xFilial:SWY%
		AND REB.REB_CODCCT = %exp:cCodCCT%
EndSql
	
lRet := (cAlias)->(!Eof())
(cAlias)->(DbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aGtPc
	Retorna mesmo valor do campo RV_PERC para o campo TCX_PORCEN 
@author		Kaique Schiller
@since		28/06/2022
/*/
//-------------------------------------------------------------------------------
Function At996aGtPc(cTip)
Local nRet := 0
Local oMdl := FwModelActive()
Local cCodTbl := ""

If cTip == "1" 
	cCodTbl := oMdl:GetValue('TCXDETAIL1',"TCX_CODTBL")	
Elseif cTip == "2"
	cCodTbl := oMdl:GetValue('TCXDETAIL2',"TCX_CODTBL")
Endif

If !Empty(cCodTbl)
	nRet := Posicione("SRV",1,xFilial("SRV")+cCodTbl,"RV_PERC")
Endif

Return nRet

// ------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At996aVlBn
	Envia parametros para função de consulta no banco 
@author		Kaique Schiller
@since		28/07/2022
/*/

// ------------------------------------------------------------------------------------------------
Function At996aVlBn(oMdl,cCodCCT)
Local lRet := .T.

If !IsInCallStack("InitDados") .And. !AtCdTabOk(oMdl:GetValue("TCX_CODTBL"),cCodCCT)
	lRet := .F.
Endif

Return lRet

// ------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At996aGCCT
	-Restaura os valores dos grids caso o usuário altere o código da CCT.
	-Impossibilita o "UNDELETE" da linha caso o usuário tenha alterado o código da CCT e 
	 o código da tabela não estiver vinculado ao novo código CCT selecionado.
@author		Jack Junior
@since		28/07/2022
/*/
// ------------------------------------------------------------------------------------------------
Function At996aGCCT()
Local lRet := .T. 
Local oMdl := FwModelActive()
Local oMdlTCX1 := oMdl:GetModel( 'TCXDETAIL1' )
Local oMdlTCX2 := oMdl:GetModel( 'TCXDETAIL2' )
Local nI := 0
Local aSaveRows := FwSaveRows()
Local oView := FwViewActive()
Local lRefresh := .F.

For nI := 1 To oMdlTCX1:Length()
    oMdlTCX1:GoLine( nI )
    If !(oMdlTCX1:IsDeleted()) .And. oMdlTCX1:GetValue('TCX_TABELA') == "1" //Validação se pode ou não restaurar a linha
        oMdlTCX1:SetValue('TCX_TIPTBL', '2' )
		lRefresh := .T.
    EndIf    
Next nI 

For nI := 1 To oMdlTCX2:Length()
    oMdlTCX2:GoLine( nI ) 
    If  !(oMdlTCX2:IsDeleted()) .And. oMdlTCX2:GetValue('TCX_TABELA') == "1" //Validação se pode ou não restaurar a linha
        oMdlTCX2:SetValue('TCX_TIPTBL', '2' ) 
		lRefresh := .T.
    EndIf
Next nI

If lRefresh
	FwRestRows( aSaveRows )
	oView:Refresh("VIEW_TCX1")
	oView:Refresh("VIEW_TCX2")
Endif

Return lRet

// ------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At996aMaOb
Array com as posições de Mão de Obra
@author		Kaique Schiller
@since		01/08/2022
/*/
// ------------------------------------------------------------------------------------------------
Static Function At996aMaOb()
Local aMaoObra := {STR0015,; //"Hora Extra"
				   STR0016,; //"Hora Extra Feriado"
				   STR0017,; //"Intervalo de Refeição Remunerado"
				   STR0018,; //"Gratificação Função"			   				   
				   STR0019,; //"Gratificação Contrato"				   
				   STR0020,; //"Adicional Noturno"			   
				   STR0021,; //"Hora Noturna Reduzida"				   
				   STR0022,; //"Periculosidade"
				   STR0023,; //"Insalubridade"
				   STR0024} //"DSR"
Return aMaoObra

// ------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At996aEcrg
Array com as posições de Mão de Obra
@author		Kaique Schiller
@since		01/08/2022
/*/
// ------------------------------------------------------------------------------------------------
Static Function At996aEcrg()
Local aEncargos := {{STR0025,"S001"},; //"Desc INSS"
				   {STR0026,"S001"},; //"Ded. Base IR"
				   {STR0027,"S037"},; //"F.G.T.S"
				   {STR0028,"S038"},; //"Salário Educação"
				   {STR0029,"S038"},; //"SESI"
				   {STR0047,"S038"},; //"SESC"
				   {STR0030,"S038"},; //"SENAI"
				   {STR0048,"S038"},; //"SENAC"
				   {STR0031,"S038"},; //"INCRA"				   
				   {STR0032,""},; //"Riscos de Acidente de Trabalho"			   
				   {STR0033,"S038"},; //"SEBRAE"
				   {STR0034,""},; //"Férias"
				   {STR0035,""},; //"Faltas Abonadas"
				   {STR0036,""},; //"Licença Paternidade"
				   {STR0037,""},; //"Faltas Legais"
				   {STR0038,""},; //"Acidente de trabalho"
				   {STR0039,""},; //"Aviso Previo Trabalhado"
				   {STR0040,""},; //"Adicional 1/3 Férias"
				   {STR0041,""},;//"13º Salário"										   
				   {STR0042,""},; //"Aviso Previo Inden. + 13º, Fériase 1/3 Const."									   
				   {STR0043,""},; //"FGTS Sobre Aviso Previo + 13º Inden."		 									   
				   {STR0044,""},; //"Inden. Compensa. Por Demissão S/Justa Causa"									   
				   {STR0045,""},; //"Aprovisionam. Feérias S/Licen. Maternidade"											   
				   {STR0046,""}} //"Aprovisionam. 1/3 Const. Férias S/Licen. Mat"
Return aEncargos

// ------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinTCX1
Realiza a validação do poslinha do grid de Mão de Obra
@author		Kaique Schiller
@since		01/08/2022
/*/
// ------------------------------------------------------------------------------------------------
Function PosLinTCX1(oMdl,nLine)
Local lRet := .T.

If oMdl:GetValue("TCX_TABELA") == "1" .And. Empty(oMdl:GetValue("TCX_CODTBL")) 
	Help(,, "PosLinTCX1",,STR0051,1,0,,,,,,{STR0052}) //"O campo Cod. Tabela é obrigatório com o tipo 1 de tabela selecionado."##"Realize o preenchimento do campo Cod. Tabela."
	lRet := .F.
Endif

Return lRet

// ------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinTCX2
Realiza a validação do poslinha do grid de Encargos Sociais
@author		Kaique Schiller
@since		01/08/2022
/*/
// ------------------------------------------------------------------------------------------------
Function PosLinTCX2(oMdl,nLine)
Local lRet := .T.

If oMdl:GetValue("TCX_TABELA") == "1" .And. Empty(oMdl:GetValue("TCX_CODTBL"))
	Help(,, "PosLinTCX2",,STR0051,1,0,,,,,,{STR0052}) //"O campo Cod. Tabela é obrigatório com o tipo 1 de tabela selecionado."##"Realize o preenchimento do campo Cod. Tabela."
	lRet := .F.
Endif

Return lRet

// ------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinTDZ
Realiza a validação do poslinha do grid de Benefícios
@author		Kaique Schiller
@since		01/08/2022
/*/
// ------------------------------------------------------------------------------------------------
Function PosLinTDZ(oMdl,nLine)
Local lRet := .T.

If Empty(oMdl:GetValue("TDZ_CODSLY"))
	Help(,, "PosLinTDZ",,STR0056,1,0,,,,,,{STR0057}) //"O campo Cod. Benefic. é obrigatório."##"Realize o preenchimento do campo Cod. Benefic."
	lRet := .F.
Endif

If lRet .And. Empty(At996aDsc(oMdl:GetValue("TDZ_CODSLY"),oMdl:GetValue("TDZ_TIPBEN"),.T.))
	Help(,, "PosLinTDZ",,STR0058,1,0,,,,,,{STR0059}) //"Não existe esse Cod de Beneficio vinculado a esse Tipo de Beneficio."##"Utilize a consulta F3 para selecionar o registro corretamente."
	lRet := .F.
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aFlBn
	Filtro da consulta padrão TDZ_TIPBEN
@author		Kaique Schiller
@since		20/06/2022
/*/
//-------------------------------------------------------------------------------
Function At996aFlBn()
Local cFiltro := "@#"
Local cTabela := "SWY"
Local cCodCCT :=  FwFldGet("TCW_CODCCT")

cFiltro += '(SLY->LY_FILIAL == "' + xFilial("SLY")  +'" .And. SLY->LY_ALIAS == "' +cTabela+ '" .And. SLY->LY_CHVENT == "' +cCodCCT+ '" )'

Return cFiltro+"@#"

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aDsc
	Descrição do beneficio.
@author		Kaique Schiller
@since		09/08/2022
/*/
//-------------------------------------------------------------------------------
Function At996aDsc(cChave,cTipoBen,lInic)
Local cRet 		:= ""
Local aArea 	:= {}
Default cChave	:= ""
Default cTipoBen := ""
Default lInic    := .F.

If !lInic
	cChave	:= Alltrim(SLY->LY_CODIGO)
	cTipoBen := Alltrim(SLY->LY_TIPO)
Endif

If !Empty(cChave)
	aArea := GetArea()
	If cTipoBen == "VR"
		//1=Vale Refeicao;2=Vale Alimentacao                                                                                              
		cRet  := Fdesc("RFO", "1"+cChave, "RFO_DESCR")
	ElseIf cTipoBen == "VA"
		//1=Vale Refeicao;2=Vale Alimentacao                                                                                              
		cRet  := Fdesc("RFO", "2"+cChave, "RFO_DESCR")
	ElseIf cTipoBen == "PS"
		cRet  := Fdesc("SG0", cChave, "G0_DESCR")
	Else
		cRet  := Fdesc("RIS", cTipoBen+cChave, "RIS_DESC")
	EndIf
	RestArea(aArea)
EndIf

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aDcTp
	Descrição do tipo de beneficio.
@author		Kaique Schiller
@since		09/08/2022
/*/
//-------------------------------------------------------------------------------
Function At996aDcTp(cChave,lInic)
Local aArea 	:= {}
Local aRet		:= {}
Local nPos		:= 0
Local cRet		:= "" 
Default cChave 	:= ""
Default lInic 	:= .F.

If !lInic
	cChave := Alltrim(SLY->LY_TIPO)
Endif

If !Empty(cChave)
	aArea:= GetArea()
	aRet := At996aCrg()
	nPos := ascan(aRet,{|x| x[2][1] == cChave})
	RestArea(aArea)
Endif
	
If nPos > 0
	cRet := aRet[nPos][2][2]
Endif

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aCrg
	Carrega as informações dos tipos de beneficio.
@author		Kaique Schiller
@since		09/08/2022
/*/
//-------------------------------------------------------------------------------
Static Function At996aCrg()
Local aRet 	:= {}
Local aBen 	:= {}
Local nI	:= 1
Local aTb11	:= {}

aadd(aBen,{"VR",STR0060})//"Vale Refeição"
aadd(aBen,{"VA",STR0061})//"Vale Alimentação"
aadd(aBen,{"PS",STR0062})//"Plano de Saude"

For nI := 1 To Len(aBen)
	aadd(aRet,{1,1})
	aRet[nI][1]	:= 1
	aRet[nI][2]	:= {aBen[nI][1],aBen[nI][2]}
Next nI

fCarrTab(@aTb11,"S011" )
fVerVinc(@aTb11)

For nI := 1 To Len(aTb11)
	aadd(aRet,{1,1})
	aRet[len(aRet)][1]	:= 1
	aRet[len(aRet)][2]	:= {aTb11[nI][5],aTb11[nI][6]}
Next nI

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aVlrB
	Valor do beneficio.
@author		Kaique Schiller
@since		09/08/2022
/*/
//-------------------------------------------------------------------------------
Function At996aVlrB()
Local nRet 		:= 0
Local aArea 	:= {}
Local cChave	:= ""
Local cTipoBen	:= ""

cChave := Alltrim(SLY->LY_CODIGO)
If !Empty(cChave)
	cTipoBen := Alltrim(SLY->LY_TIPO)
	aArea := GetArea()
	If cTipoBen == "VR"
		//1=Vale Refeicao                                                                                              
		nRet := Posicione("RFO",1,xFilial("RFO")+"1"+cChave,"RFO_VALOR")
	ElseIf cTipoBen == "VA"
		//1=Vale Refeicao                   
		nRet :=  Posicione("RFO",1,xFilial("RFO")+"2"+cChave,"RFO_VALOR")
	EndIf
	RestArea(aArea)
EndIf

Return nRet
