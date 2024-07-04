#include "GCPA101.CH"
#Include "Protheus.ch"
#Include "FWMVCDEF.CH"
#Include "FWEVENTVIEWCONSTS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA101()
Cadastro de Analise de Mercado X Lote
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCPA101()
Local oBrowse	

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('COM')
oBrowse:SetDescription(STR0001)//'Cadastro de Análises de Mercado'

oBrowse:AddLegend( "COM_STATUS=='1'", "GREEN", STR0002  )//"Aberto"
oBrowse:AddLegend( "COM_STATUS=='2'", "RED"  , STR0003 )//"Fechado"
oBrowse:AddLegend( "COM_STATUS=='3'", "BLUE"  , STR0004 )//"Gerado Por processo licitatório"
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Matheus Lando Raimundo
@since 03/07/13 
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCOM := FWFormStruct(1,'COM')
Local oStruCON := FWFormStruct(1,'CON')
Local oStruCOO := FWFormStruct(1,'COO')  
Local oStruCOP := FWFormStruct(1,'COP')
Local oStruCOQ := FWFormStruct(1,'COQ')
Local oStruCOY := FWFormStruct(1,'COY', {|cCampo| !AllTrim(cCampo) $ "COY_CODIGO , COY_CODFOR , COY_LOJFOR , COY_LOTE"})
Local bVldCalc := {|x| GCP100Calc(x) }
Local oModel   := MPFormModel():New('GCPA101', ,{|oModel|GCPPosVld(oModel)},{|oModel|GCP101Cmt(oModel)})

oModel:AddFields('COM_MASTER', /*cOwner*/,oStruCOM) //-- Cadastro do Análises

oModel:AddGrid('COQ_DETAIL', 'COM_MASTER', oStruCOQ,{|oModelGrid,  nLine,cAction,cField|PreValCOQ(oModelGrid, nLine, cAction, cField)}, {|oModelGrid|LinhaOkCOQ(oModelGrid)}) //--Lote
oModel:AddGrid('CON_DETAIL', 'COQ_DETAIL', oStruCON,{|oModelGrid, nLine,cAction,cField|PreValCON(oModelGrid, nLine, cAction, cField)}) //-- Produtos
oModel:AddGrid('COO_DETAIL', 'CON_DETAIL', oStruCOO,{|oModelGrid, nLine,cAction,cField|PreValCOO(oModelGrid, nLine, cAction, cField)}) //-- Solicitações
oModel:AddGrid('COP_DETAIL', 'COQ_DETAIL', oStruCOP,{|oModelGrid, nLine,cAction,cField|PreValCOP(oModelGrid, nLine, cAction, cField)}, {|oModelGrid|LinhaOkCOP(oModelGrid)}) //--Fornecedores
oModel:AddGrid('COY_DETAIL', 'COP_DETAIL', oStruCOY) //--Composição de Lote

oModel:SetRelation('COQ_DETAIL',{{'COQ_FILIAL','xFilial("COQ")'},{'COQ_CODIGO', 'COM_CODIGO'}}, COQ->(IndexKey(1)))
oModel:SetRelation('CON_DETAIL',{{'CON_FILIAL','xFilial("CON")'},{'CON_CODIGO', 'COM_CODIGO'} , {'CON_LOTE', 'COQ_LOTE'}}		,CON->(IndexKey(2)))
oModel:SetRelation('COO_DETAIL',{{'COO_FILIAL','xFilial("COO")'},{'COO_CODIGO', 'COM_CODIGO'} , {'COO_CODPRO','CON_CODPRO'}, {'COO_LOTE','COQ_LOTE'}}	,COO->(IndexKey(1)))
oModel:SetRelation('COP_DETAIL',{{'COP_FILIAL','xFilial("COP")'},{'COP_CODIGO', 'COM_CODIGO'} , {'COP_LOTE','COQ_LOTE'}}		,COP->(IndexKey(2)))
oModel:SetRelation('COY_DETAIL',{{'COY_FILIAL','xFilial("COY")'},{'COY_CODIGO', 'COM_CODIGO'} , {'COY_LOTE', 'COQ_LOTE'}, {'COY_CODFOR', 'COP_CODFOR'}, {'COY_LOJFOR', 'COP_LOJFOR'}, {'COY_TIPO', 'COP_TIPO'}} ,COY->(IndexKey(1)))

// Adiciona descricoes para as partes do modelo
oModel:SetDescription(STR0010) //"Analise de Mercado"//'Analise de Mercado'

oModel:GetModel('COM_MASTER'):SetDescription(STR0011) //"Resumo"
oModel:GetModel('CON_DETAIL'):SetDescription(STR0013) //"Produtos"  
oModel:GetModel('COO_DETAIL'):SetDescription(STR0014) //"Solicitações"
oModel:GetModel('COP_DETAIL'):SetDescription(STR0015) //"Forncedores Consultados"
oModel:GetModel('COQ_DETAIL'):SetDescription(STR0027)  //"Lote"
oModel:GetModel('COY_DETAIL'):SetDescription(STR0028)  //"Composição do Lote"

oModel:SetPrimaryKey({'COM_FILIAL'},{'COM_CODIGO'})

oModel:GetModel("CON_DETAIL"):SetUniqueLine({"CON_CODPRO"})
oModel:GetModel("COP_DETAIL"):SetUniqueLine({"COP_TIPO", "COP_CODFOR", "COP_LOJFOR" })
oModel:GetModel("COQ_DETAIL"):SetUniqueLine({"COQ_LOTE"})

oModel:GetModel("COQ_DETAIL"):SetOptional(.F.)
oModel:GetModel("COO_DETAIL"):SetOptional(.T.)	
oModel:GetModel("COP_DETAIL"):SetOptional(.T.)
oModel:GetModel("COY_DETAIL"):SetOptional(.T.)

oModel:GetModel("COO_DETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("COY_DETAIL"):SetNoDeleteLine(.T.)
oModel:GetModel("COY_DETAIL"):SetNoInsertLine(.T.)

oModel:GetModel('CON_DETAIL'):SetMaxLine( 99999 )

oModel:AddCalc('GCP101CALC','COM_MASTER','CON_DETAIL','CON_VALEST','CONESTTOT','SUM', bVldCalc,,'Soma')

oStruCOM:SetProperty("COM_MODACA",MODEL_FIELD_VALID,{|a,b,c,xoldvalue|FWInitCpo(a,b,c,xoldvalue),lRet:=GCP100VlMd(xoldvalue),FWCloseCpo(a,b,c,lRet,.T.),lRet})

oModel:SetVldActivate({|oModel|VldActivate(oModel, @oStruCOM)})

oModel:SetActivate({|oModel| GCPA101Ins(oModel)})

Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel('GCPA101')
//Definição das Estruturas, removendo a visualização de alguns campos.

Local oStruCOM := FWFormStruct(2,'COM')
Local oStruCON := FWFormStruct(2,'CON', {|cCampo| !AllTrim(cCampo) $ "CON_CODIGO, CON_LOTE, CON_METODO, CON_VALEST"})  
Local oStruCOP := FWFormStruct(2,'COP', {|cCampo| !AllTrim(cCampo) $ "COP_CODIGO, COP_CODPRO, COP_LOTE, COP_VALTOT"})
Local oStruCOO := FWFormStruct(2,'COO', {|cCampo| !AllTrim(cCampo) $ "COO_CODIGO, COO_CODPRO, COO_LOTE"})
Local oStruCOQ := FWFormStruct(2,'COQ', {|cCampo| !AllTrim(cCampo) $ "COQ_CODIGO"})
Local oStruCOY := FWFormStruct(2,'COY', {|cCampo| !AllTrim(cCampo) $ "COY_CODIGO, COY_CODFOR , COY_LOJFOR , COY_LOTE , COY_TIPO"}) 

Local oView             := FWFormView():New()
oView:SetModel(oModel)  //-- Define qual o modelo de dados será utilizado

oView:AddField('VIEW_COM',oStruCOM,'COM_MASTER')
oView:AddGrid('VIEW_CON',oStruCON,'CON_DETAIL')
oView:AddGrid('VIEW_COO',oStruCOO,'COO_DETAIL')
oView:AddGrid('VIEW_COP',oStruCOP,'COP_DETAIL')
oView:AddGrid('VIEW_COQ',oStruCOQ,'COQ_DETAIL')
oView:AddGrid('VIEW_COY',oStruCOY,'COY_DETAIL')

//-- Divide a tela nas partes a utilizar
oView:CreateHorizontalBox('CIMA',37)
oView:CreateHorizontalBox('MEIO',31)
oView:CreateHorizontalBox('BAIXO',32)

oView:CreateFolder("FOLDER","MEIO")       
oView:AddSheet("FOLDER","FLDCOD1",STR0016)//"Lotes"
oView:AddSheet("FOLDER","FLDCOD2",STR0017)//"Produtos"
oView:AddSheet("FOLDER","FLDCOD3",STR0018)//"Solicitações"

oView:CreateFolder("FOLDER1","BAIXO")
oView:AddSheet("FOLDER1","FLDCOD1",STR0029)//"Fornecedores"
oView:AddSheet("FOLDER1","FLDCOD2",STR0028)//"Composição do Lote"

oView:CreateHorizontalBox('LOTE',100,,,"FOLDER","FLDCOD1")
oView:CreateHorizontalBox('PROD',100,,,"FOLDER","FLDCOD2")
oView:CreateHorizontalBox('SC'  ,100,,,"FOLDER","FLDCOD3")

oView:CreateHorizontalBox('FORNEC',100,,,"FOLDER1","FLDCOD1")
oView:CreateHorizontalBox('LOTE_FORNEC',100,,,"FOLDER1","FLDCOD2")

oView:EnableTitleView('VIEW_COM')

oView:SetOwnerView('VIEW_COM','CIMA' )
oView:SetOwnerView('VIEW_COQ','LOTE' )
oView:SetOwnerView('VIEW_CON','PROD' )
oView:SetOwnerView('VIEW_COO','SC')
oView:SetOwnerView('VIEW_COP','FORNEC')
oView:SetOwnerView('VIEW_COY','LOTE_FORNEC')

oView:EnableTitleView('VIEW_COM')

If FunName() <> "GCPA200"						
	oView:AddUserButton(STR0019, 'CLIPS', {|oView|  GCP100CaSC(oModel)})//'Solicitações'
	oView:AddUserButton(STR0020, 'CLIPS', {|oView|  VisualSC(oModel)})//'Visualiza Solicitação'
Else
	oStruCOM:SetProperty('*', 	MVC_VIEW_CANCHANGE  ,.F.) //Desabilita os campos
	oStruCOM:SetProperty('COM_CODIGO', MVC_VIEW_CANCHANGE, .T.)	//Habilita este campo
EndIf

oStruCOP:SetProperty('COP_PRCUN', 	MVC_VIEW_CANCHANGE  ,.F.)	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0021  ACTION "VIEWDEF.GCPA101"	OPERATION 2	ACCESS 0  //'Visualizar'
ADD OPTION aRotina TITLE STR0022  ACTION "VIEWDEF.GCPA101"	OPERATION 3  	ACCESS 0  //'Incluir'
ADD OPTION aRotina TITLE STR0023  ACTION "VIEWDEF.GCPA101"	OPERATION 4 	ACCESS 0  //'Alterar'
ADD OPTION aRotina TITLE STR0024  ACTION "VIEWDEF.GCPA101"	OPERATION 5  	ACCESS 3  //'Excluir'
ADD OPTION aRotina TITLE STR0025  ACTION "VIEWDEF.GCPA101" 	OPERATION 8 	ACCESS 0  //'Imprimir'
ADD OPTION aRotina TITLE STR0026  ACTION "GeraEdital()"      OPERATION 9  	ACCESS 0  //'Gerar processo licitatório'
ADD OPTION aRotina TITLE STR0030  ACTION "VIEWDEF.GCPA102" OPERATION 4 ACCESS 0   //'Manutenção do Lote'
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101Metod()
Valid do campo COQ_METODO

@author Matheus Lando Raimundo
@since 26/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCP101Metod()
Local oModel := FWModelActive()
Local oCOQ_DETAIL := oModel:GetModel('COQ_DETAIL')
Local oCOM_MASTER := oModel:GetModel('COM_MASTER')

nValor := GCPRetVE(oModel, , ,'COQ_DETAIL', 'COQ_METODO')
oCOQ_DETAIL:LoadValue('COQ_VLRTOT', nValor)

oCOM_MASTER:SetValue('COM_MODSUG',  GCP101MDSug(oModel))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LinhaOkCOQ(oModelGrid)
Linha Ok do modelo COQ

@author Matheus Lando Raimundo
@since 26/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function LinhaOkCOQ(oModelGrid)
Local lRet := .T.
Local oModel := FWModelActive()
Local oCON_DETAIL := oModel:GetModel('CON_DETAIL')
Local nI := 0
Local aSaveLines := FWSaveRows()

If oModel:GetId() == 'GCPA101'
	For nI := 1 To oCON_DETAIL:Length()
		oCON_DETAIL:GoLine(nI)
		lRet := (!oCON_DETAIL:IsDeleted()) .And. !Empty(oCON_DETAIL:GetValue('CON_CODPRO'))	
		If lRet 
			Exit			
		EndIf		 		
	Next nI	    

	If !lRet
		Help(' ', 1,'GCP101NPRD')	
	EndIf		    
EndIf
FWRestRows(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101VTot()
Valid do campo COQ_VLRTOT

@author Matheus Lando Raimundo
@since 26/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCP101VTot()
Local oModel := FWModelActive()
Local lRet := .T. 
Local oCOM_MASTER := oModel:GetModel('COM_MASTER')       
Local oCOQ_DETAIL := oModel:GetModel('COQ_DETAIL')
       
If oCOQ_DETAIL:GetValue('COQ_METODO') <> "6"
	Help(' ', 1,'GCP100VALEST')
	lRet := .F.
Else
	oCOM_MASTER:SetValue('COM_MODSUG',  GCP101MDSug(oModel))
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PreValCON(oModelGrid, nLinha, cAcao, cCampo)
Rotina de Pré validação do modelo CON(Produtos)

@author Matheus Lando Raimundo

@oModelGrid = Modelo
@nLinha  = Linha corrente
@cAcao   = Ação ("DELETE", "SETVALUE", e etc)
@cCampo  = Campo atualizado

@return lRet - Valor Booleano que confirma a validação

@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function PreValCON(oModelGrid, nLinha, cAcao, cCampo,cValue)
Local oModel 		:= FWModelActive()
Local oCOQ_DETAIL	:= oModel:GetModel('COQ_DETAIL')
Local oCON_DETAIL	:= oModel:GetModel('CON_DETAIL')
Local ltdDelet 	:= .F.
Local aSaveLines 	:= FWSaveRows()
Local nI 			:= 0

If cAcao == 'DELETE' 
	If oCON_DETAIL:Length() == 1
		lTdDelet := .T.	
	Else				
		For nI := 1 To  oCON_DETAIL:Length()
			oCON_DETAIL:GoLine(nI)
			If oCON_DETAIL:nLine == nLinha 
				GCPDelCOY(oCON_DETAIL:GetValue('CON_CODPRO')) //Efetua Delete do produto da aba composição de lote
				Loop
			EndIF			
			lTdDelet := oCON_DETAIL:IsDeleted() 
		Next nI
	EndIf
		
EndIf

If cAcao == 'UNDELETE' 
	GCPDelCOY(oCON_DETAIL:GetValue('CON_CODPRO')) //Efetua Delete do produto da aba composição de lote
EndIf

If !IsInCallStack('PreValCOQ')
	If lTdDelet
		oCOQ_DETAIL:DeleteLine()
		GCPAtuaForn(@oModel:GetModel('COP_DETAIL'), .F.)
	ElseIf oCOQ_DETAIL:IsDeleted()
		oCOQ_DETAIL:UnDeleteLine()
		GCPAtuaForn(@oModel:GetModel('COP_DETAIL'), .T.)
		
	EndIf
EndIf

GCP101CalF()

FWRestRows(aSaveLines)

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} PreValCOQ(oModelGrid, nLinha, cAcao, cCampo)
Rotina de Pre validação do modelo COQ(Lote)


@author Matheus Lando Raimundo

@oModelGrid = Modelo
@nLinha  = Linha corrente
@cAcao   = Ação ("DELETE", "SETVALUE", e etc)
@cCampo  = Campo atualizado

@return lRet - Valor Booleano que confirma a validação

@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function PreValCOQ(oModelGrid, nLinha, cAcao, cCampo)
Local oModel := FWModelActive()
Local oCOO_DETAIL := oModel:GetModel('COO_DETAIL')
Local oCON_DETAIL := oModel:GetModel('CON_DETAIL')
Local oCOQ_DETAIL := oModel:GetModel('COQ_DETAIL')
Local oCOM_MASTER := oModel:GetModel('COM_MASTER')
Local nI := 0
Local nA := 0
Local nVlrTotal := 0
Local oView 
Local aSaveLines := FWSaveRows()
Local lTdDelet := .F.

If cAcao = 'DELETE'
	For nI := 1 To  oCON_DETAIL:Length()
		oCON_DETAIL:GoLine(nI)	
		oView := FwViewActive()
		If !Empty(oCOO_DETAIL:GetValue('COO_NUMSC'))
			If oView:GetFolderActive("FOLDER", 2)[1] == 1 // Aba de Lote
				For nA := 1 To  oCOO_DETAIL:Length()
					oCOO_DETAIL:GoLine(nA)
					oCOO_DETAIL:DeleteLine()	
				Next nA
				lTdDelet := .T.
						
			EndIf
		Else	
			lTdDelet := .T.		
			oCON_DETAIL:DeleteLine()			
		EndIf
			
	Next nI		
ElseIf cAcao = 'UNDELETE'
	For nI := 1 To  oCON_DETAIL:Length()
		oCON_DETAIL:GoLine(nI)	
		oView := FwViewActive()
		If oView:GetFolderActive("FOLDER", 2)[1] == 1 // Aba de Lote
			For nA := 1 To  oCOO_DETAIL:Length()
				oCOO_DETAIL:GoLine(nA)
				oCOO_DETAIL:UnDeleteLine()	
			Next nA
		EndIf			
	Next nI
EndIf

GCPAtuaForn(@oModel:GetModel('COP_DETAIL'), !lTdDelet)

For nI := 1 To  oCOQ_DETAIL:Length()
	oCOQ_DETAIL:GoLine(nI)
	If oCOQ_DETAIL:nLine == nLinha .Or. !oCOQ_DETAIL:IsDeleted() 
		nVlrTotal := nVlrTotal + oCOQ_DETAIL:GetValue('COQ_VLRTOT')  
	ElseIf oCOQ_DETAIL:IsDeleted()
		Loop			
	EndIF			
	lTdDelet := oCON_DETAIL:IsDeleted() 
Next nI		

oCOM_MASTER:SetValue('COM_VALEST', nVlrTotal)	
FWRestRows(aSaveLines)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PreValCOP(oModelGrid, nLinha, cAcao, cCampo)
Rotina de Pós validação do modelo COP(Fornecedores)


@author Matheus Lando Raimundo

@oModelGrid = Modelo
@nLinha  = Linha corrente
@cAcao   = Ação ("DELETE", "SETVALUE", e etc)
@cCampo  = Campo atualizado

@return lRet - Valor Booleano que confirma a validação

@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Static Function PreValCOP(oModelGrid, nLinha, cAcao, cCampo)

Local oModel := FWModelActive()
Local oCOM_MASTER := oModel:GetModel('COM_MASTER')
Local oCOQ_DETAIL := oModel:GetModel('COQ_DETAIL')
Local oCON_DETAIL := oModel:GetModel('CON_DETAIL')
Local oCOY_DETAIL := oModel:GetModel('COY_DETAIL')
Local nI := 0
Local lRet := .T.

//Não permite incluir fornecedores sem antes incluir um produto para o mesmo.  		
If !IsInCallStack('PreValCOQ')
	If cAcao == 'SETVALUE'				
		if Empty(oCOQ_DETAIL:GetValue('COQ_LOTE')) .Or. oCOQ_DETAIL:IsDeleted()
			Help(' ', 1,'GCP101NLTF')	
			lRet := .F.		
		EndIf
	EndIf
EndIf					

If cAcao == 'DELETE'
	If oCOQ_DETAIL:GetValue('COQ_METODO') <> '6'
		oCOQ_DETAIL:LoadValue('COQ_VLRTOT', GCPRetVE(oModel, .T., .F., 'COQ_DETAIL', 'COQ_METODO'))
		oCOM_MASTER:SetValue('COM_MODSUG',  GCP101MDSug(oModel))
		lRet := .T. 
	EndIf		
	GCP101AtL(@oModel, .T.) //Função para deletar produtos da composição do Lote
		
ElseIf cAcao == 'UNDELETE' //Quando o fornecedor estiver "UNDELETE" refaz os calculos.
	If !IsInCallStack('PreValCOQ')
		If Empty(oCOQ_DETAIL:GetValue('COQ_LOTE')) .Or. oCOQ_DETAIL:IsDeleted()
			Help(' ', 1,'GCP100NPDF')
			lRet := .F.
		EndIf									
	EndIf
	If lRet
		If oCOQ_DETAIL:GetValue('COQ_METODO') <> '6'
			oCOQ_DETAIL:LoadValue('COQ_VLRTOT', GCPRetVE(oModel, .F.,.T., 'COQ_DETAIL', 'COQ_METODO'))
			oCOM_MASTER:SetValue('COM_MODSUG',  GCP101MDSug(oModel))
			lRet := .T.
		EndIf
		If !IsInCallStack('PreValCOQ')
			GCP101AtL(@oModel, .F.) //Função para deletar produtos da composição do Lote
		EndIf
	EndIf		
EndIf	


If lRet 
	If ((cAcao == 'SETVALUE') .And. (cCampo == 'COP_CODFOR'))
		If (Empty(oCOY_DETAIL:GetValue('COY_CODPRO')))   
			For nI := 1 to oCON_DETAIL:Length()
				oCON_DETAIL:GoLine(nI)
				oCOY_DETAIL:SetNoInsertLine(.F.)
				If !Empty(oCOY_DETAIL:GetValue('COY_CODPRO'))				
					oCOY_DETAIL:AddLine()
				EndIf
				oCOY_DETAIL:SetValue('COY_CODPRO', oCON_DETAIL:GetValue('CON_CODPRO'))
				oCOY_DETAIL:SetValue('COY_QUANT',  oCON_DETAIL:GetValue('CON_QUANT'))
				
				oCOY_DETAIL:SetNoInsertLine(.T.)									
			Next nI
		EndIf				
	EndIf
EndIf				
oCOY_DETAIL:GoLine(1)
												      			        
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP100SCS(oModel)
Rotina que retorna um array com os Produtos Selecionados na Análise de Mercado

@author Matheus Lando Raimundo
@oModel = oModel
@return = Vetor com as SC's
@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCP101ProdS(omodel)
Local aProds := {}
Local nI := 0
Local nI2 := 0
Local aSaveLines := FWSaveRows()
Local aProdsLote := {}

//Primeiro guarda os produtos que o Lote posicionado possui.
For nI := 1 To oModel:GetModel('CON_DETAIL'):Length()
	oModel:GetModel('CON_DETAIL'):GoLine(nI)
	aadd(aProdsLote, oModel:GetModel('CON_DETAIL'):GetValue('CON_CODPRO'))
Next nI		
FWRestRows(aSaveLines)

aSaveLines := FWSaveRows()
For nI := 1 To oModel:GetModel('COQ_DETAIL'):Length()
	oModel:GetModel('COQ_DETAIL'):GoLine( nI )
		
	For nI2 := 1 To oModel:GetModel('CON_DETAIL'):Length()		
		oModel:GetModel('CON_DETAIL'):GoLine( nI2 )
		//Se não encontrei o produto no Lote posicionado, adiciona nos produtos que não irão aparecer.
		If aScan(aProdsLote, oModel:GetModel('CON_DETAIL'):GetValue('CON_CODPRO')) == 0			
			aadd(aProds, oModel:GetModel('CON_DETAIL'):GetValue('CON_CODPRO'))
		EndIf			
	Next nI2
Next nI 	
FWRestRows(aSaveLines)
	
Return aProds

//-------------------------------------------------------------------
/*/{Protheus.doc} PreValCOO(oModelGrid, nLinha, cAcao, cCampo)
Rotina de Pré validação do modelo COO(Solicitações)

@author Matheus Lando Raimundo

@oModelGrid = Modelo
@nLinha  = Linha corrente
@cAcao   = Ação ("DELETE", "SETVALUE", e etc)
@cCampo  = Campo atualizado

@return .T.

@since 22/07/2013
@version P11
/*/
//------------------------------------------------------------------
Static Function PreValCOO(oModelGrid, nLinha, cAcao, cCampo)
	Local oModel 		:= oModelGrid:GetModel()
	Local oCON_DETAIL	:= oModel:GetModel('CON_DETAIL')
	Local oCOO_DETAIL	:= Nil
	Local aSaveLines 	:= {}
	Local nQtde 		:= 0
	Local nQtdeSegu 	:= 0 // Qtde Segunda unidade de medida
	Local cNumSC		:= ""

	If (cAcao == 'DELETE' .Or. cAcao == 'UNDELETE')
		aSaveLines 	:= FWSaveRows()
		oCOO_DETAIL	:= oModel:GetModel('COO_DETAIL')
		cNumSC := oCOO_DETAIL:GetValue('COO_NUMSC')

		If !Empty(cNumSC)
			//Posiciona o registro na SC1 para recuperar a quantidade da SC.
			SC1->(dbSetOrder(1))
			If SC1-> (dbSeek(xFilial('SC1')+cNumSC+oCOO_DETAIL:GetValue('COO_ITEMSC')))
				nQtde := SC1->C1_QUANT
				nQtdeSegu := SC1->C1_QTSEGUM 
			EndIf		
		EndIf

		If cAcao == 'DELETE'		
			oCON_DETAIL:LoadValue('CON_QUANT', oCON_DETAIL:GetValue('CON_QUANT') - nQtde)
			oCON_DETAIL:SetValue('CON_QTSEGU', oCON_DETAIL:GetValue('CON_QTSEGU') - nQtdeSegu)
			GCP101Load()
		ElseIf cAcao == 'UNDELETE'
			oCON_DETAIL:LoadValue('CON_QUANT', oCON_DETAIL:GetValue('CON_QUANT') + nQtde)
			oCON_DETAIL:LoadValue('CON_QTSEGU', oCON_DETAIL:GetValue('CON_QTSEGU') + nQtdeSegu)			
			oCON_DETAIL:UnDeleteLine()		
		EndIf

		If oCON_DETAIL:GetValue('CON_QUANT') == 0
			oCON_DETAIL:DeleteLine()	
		EndIf	
	EndIf

	If (cAcao != "CANSETVALUE") .And. !FwIsInCallStack("GCP100CaSC")
		If Empty(aSaveLines)
			aSaveLines 	:= FWSaveRows()
		EndIf
		GCPCalcPre() //Rotina que calculo o preço do Produto
		GCP101APrd(oCON_DETAIL:GetValue('CON_CODPRO'),oCON_DETAIL:GetValue('CON_QUANT'), @oModel)
	EndIf

	If !Empty(aSaveLines)
		FWRestRows(aSaveLines)
		FwFreeArray(aSaveLines)		
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101SCS(oModel)
Rotina que retorna um array com as SC's Selecionadas na Análise de Mercado

@author Matheus Lando Raimundo
@oModel = oModel
@return = Vetor com as SC's
@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCP101SCS(oModel)
Local nI 			:= 0
Local nI2 			:= 0
Local nI3 			:= 0
Local aSCs 		:= {}
Local aSaveLines 	:= FWSaveRows()
Local oCON_DETAIL	:= oModel:GetModel('CON_DETAIL')
Local oCOO_DETAIL	:= oModel:GetModel('COO_DETAIL')
Local oCOQ_DETAIL	:= oModel:GetModel('COQ_DETAIL')
	
For nI := 1 To oCOQ_DETAIL:Length()
	oCOQ_DETAIL:GoLine( nI )
	
	For nI2 := 1 To oCON_DETAIL:Length()
		oCON_DETAIL:GoLine( nI2 )
	
  		For nI3:= 1 To oCOO_DETAIL:Length()
    		oCOO_DETAIL:GoLine( nI3 )             
        	aadd(aSCs, oCOO_DETAIL:GetValue('COO_NUMSC')+oCOO_DETAIL:GetValue('COO_ITEMSC'))                                                                                 
    	Next nI
	Next nI2
Next nI		

FWRestRows(aSaveLines)
      
Return aSCs

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101MDSug(oCOP_DETAIL, nLinhaExc, nLinhaIns)
Rotina que retorna o Código da modalidade Sugerida. 


@author Matheus Lando Raimundo
@oModel = oModel
@return cModSug - Código da modalidade Sugerida.

@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCP101MDSug(oModel)
Local oCOM_MASTER := oModel:GetModel('COM_MASTER')
Local nI 			:= 0
Local nVlrTotal 	:= 0
Local cModSug 		:= ""
Local aSaveLines 	:= FWSaveRows()
Local oCOQ_DETAIL := oModel:GetModel('COQ_DETAIL') 

For nI := 1 to oCOQ_DETAIL:Length()
	oCOQ_DETAIL:GoLine(nI)
	
	If !oCOQ_DETAIL:IsDeleted()
		nVlrTotal := nVlrTotal + oCOQ_DETAIL:GetValue('COQ_VLRTOT')
	EndIf				 
Next nI	

FWRestRows(aSaveLines)

oCOM_MASTER:SetValue('COM_VALEST', nVlrTotal)

aModSug := GCPA017Lim(oCOM_MASTER:GetValue('COM_REGRA'),oCOM_MASTER:GetValue('COM_ESPECI'),/*cModali*/,IIF(nVlrTotal==0,1,nVlrTotal), .F.)
If Len(aModSug) > 0
	cModSug := aModSug[1]
Else
	Help(' ', 1,'GCP100VLRMD')
	cModSug := 'PG'		
EndIf
				
Return IIF(funname()<>'GCPA200',cModSug,oCOM_MASTER:GetValue("COM_MODACA"))

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA101Ins()
Rotina para trazer os dados do processo licitatório selecionado (Cabeçalho, Produtos, Solicitações e Participantes)
@author Antenor Silva
@since 10/07/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

Function GCPA101Ins(oModel)
Local oModelCOQ	:= oModel:GetModel("COQ_DETAIL") //Lote dos produtos
Local oModelCON	:= oModel:GetModel('CON_DETAIL') //Produtos da Análise de Mercado
Local oModelCOO	:= oModel:GetModel('COO_DETAIL') //Solicit. de Compras X Produtos  
Local oModelCOP	:= oModel:GetModel('COP_DETAIL') //Fornecedores X Produtos
Local cSeekCOQ	:= ""
Local cSeekCON	:= ""
Local cSeekCOO	:= ""
Local cSeekCOP	:= ""
Local nLinCOQ		:= 0
Local nLinCON		:= 0
Local nLinCOO		:= 0
Local nLinCOP		:= 0
                 
If FunName() == "GCPA200" .And. oModel:GetOperation() == MODEL_OPERATION_INSERT                           
	//Cabeçalho da Análise de Mercado                     
    GCPA100AM(oModel)
    
	CP3->(dbSetOrder(1)) //CP3_FILIAL+CP3_CODEDT+CP3_NUMPRO+CP3_LOTE 
	If CP3->(dbSeek(cSeekCOQ:=xFilial("CP3")+CO1->(CO1_CODEDT+CO1_NUMPRO) ) )
    	While CP3->(!EOF()) .And. CP3->( CP3_FILIAL+CP3_CODEDT+CP3_NUMPRO ) == cSeekCOQ
	    	nLinCOQ++
			If nLinCOQ # 1
				oModelCOQ:AddLine()
			EndIf
			oModelCOQ:SetValue('COQ_LOTE', CP3->CP3_LOTE)
			oModelCOQ:SetValue('COQ_METODO', '6')
			
			CO2->(dbSetOrder(3)) //CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_LOTE 
			If CO2->(dbSeek(cSeekCON:=xFilial("CO2")+CO1->(CO1_CODEDT+CO1_NUMPRO)+CP3->CP3_LOTE ) )
		    	nLinCON:= 0
		    	While CO2->(!EOF()) .And. CO2->( CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_LOTE ) == cSeekCON
					nLinCON++
					If nLinCON # 1
						oModelCON:SetNoInsertLine(.F.)
						oModelCON:AddLine()
					EndIf
		          	GCPA100Prd(oModel) //Carrega os produtos do processo licitatório
		          	
					CP4->(dbSetOrder(1)) //CP4_FILIAL+CP4_CODEDT+CP4_NUMPRO+CP4_REVISA+CP4_CODPRO+CP4_NUMSC+CP4_ITEMSC
					If CP4->(dbSeek( cSeekCOO:=xFilial("CP4")+CO1->(CO1_CODEDT+CO1_NUMPRO+CO1_REVISA)+CO2->CO2_CODPRO ) )
						nLinCOO:= 0
						While CP4->(!EOF()) .And. CP4->(CP4_FILIAL+CP4_CODEDT+CP4_NUMPRO+CP4_REVISA+CP4_CODPRO) == cSeekCOO
							If !Empty(CP4->CP4_NUMSC) .and. ALLTRIM(CP4->CP4_LOTE) == ALLTRIM(CO2->CO2_LOTE)                         
								nLinCOO++
								If nLinCOO # 1
									oModelCOO:SetNoInsertLine(.F.)
									oModelCOO:AddLine()
								EndIf
								GCPA100SC(oModel) //Carrega as solicitações do produto selecionado
							EndIf
							CP4->(dbSkip())
						EndDo
						oModelCOO:Goline(1)
						oModelCON:SetNoInsertLine(.T.)	
					EndIf
					CO2->(dbSkip())
				EndDo	
				oModelCON:SetNoInsertLine(.T.)
				CO3->(dbSetOrder(2))//CO3_FILIAL+CO3_CODEDT+CO3_NUMPRO+CO3_LOTE    
				If CO1->CO1_GERDOC == '2'
					Help(' ', 1,'GCP100NFOR')
				ElseIf CO3->(dbSeek(cSeekCOP:=xFilial("CO3")+CO1->CO1_CODEDT+CO1->CO1_NUMPRO+CP3->CP3_LOTE))
					nLinCOP:= 0
					While CO3->(!Eof() .And. CO3->CO3_FILIAL+CO3->CO3_CODEDT+CO3->CO3_NUMPRO+CO3->CO3_LOTE== cSeekCOP)
						nLinCOP++
						If nLinCOP # 1
							oModelCOP:AddLine()
						EndIf                                    
						GCPA100For(oModel) //Carrega os fornecedores
						CO3->(dbSkip())
					EndDo
					oModelCOP:Goline(1)
				EndIf
			EndIf
			CP3->(dbSkip())
		EndDo
		oModelCON:Goline(1)
	EndIf                     
GCP101MDSug(oModel)                     
EndIf


Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101AtL()
Atualiza Status do Lote
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP101AtL(oModel, lDelete,cProduto)
Local oCOY_DETAIL := oModel:GetModel('COY_DETAIL')
Local nI := 0

Default lDelete 	:= .F.
Default cProduto	:= NIL

oCOY_DETAIL:SetNoDeleteLine(.F.)

For nI := 1 To oCOY_DETAIL:Length()
	oCOY_DETAIL:GoLine(nI)

	If cProduto # NIL
		If oCOY_DETAIL:GetValue('COY_CODPRO') == cProduto 
			If lDelete
				oCOY_DETAIL:DeleteLine()
			Else
				oCOY_DETAIL:UndeleteLine()		
			EndIf	
		EndIf
	Else 
		If lDelete
			oCOY_DETAIL:DeleteLine()
		Else
			oCOY_DETAIL:UndeleteLine()		
		EndIf
	EndIf	
Next nI	

oCOY_DETAIL:SetNoDeleteLine(.T.)	

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101ClPU()
Valid do campo COY_VLRTOT
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP101ClPU()
Local oModel := FWModelActive()
Local oCOY_DETAIL := oModel:GetModel('COY_DETAIL')
Local oCOP_DETAIL := oModel:GetModel('COP_DETAIL')
Local nI := 0
Local nValor := 0
Local aSaveLines := FWSaveRows()

For nI := 1 To oCOY_DETAIL:Length()
 	oCOY_DETAIL:GoLine(nI)
 	If !oCOY_DETAIL:IsDeleted()
		nValor := nValor + oCOY_DETAIL:GetValue('COY_VLRTOT')
	EndIf		
Next nI

If (nValor > 0) .And. (oCOP_DETAIL:IsDeleted())
	oCOP_DETAIL:UnDeleteLine()	
EndIf


oCOP_DETAIL:SetValue('COP_PRCUN', nValor)
oCOP_DETAIL:SetValue('COP_VALTOT', nValor)
FWRestRows(aSaveLines)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101ClVl()
Valid dos campos COY_QUANT e COY_PRCUN 
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP101ClVl()
Local oModel := FWModelActive()
Local oCOY_DETAIL := oModel:GetModel('COY_DETAIL')
Local nValor := 0

nValor := oCOY_DETAIL:GetValue('COY_PRCUN') * oCOY_DETAIL:GetValue('COY_QUANT')
oCOY_DETAIL:SetValue('COY_VLRTOT', nValor)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101APrd()
Valid dos campos COY_QUANT e COY_PRCUN 
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP101APrd(cCodProd, nQtde, oModel)
Local oCOY_DETAIL := oModel:GetModel('COY_DETAIL')
Local oCOP_DETAIL := oModel:GetModel('COP_DETAIL')
Local aSaveLines := FWSaveRows()
Local nI := 0
Local nI2 := 0

For nI := 1 To oCOP_DETAIL:Length()
	oCOP_DETAIL:GoLine(nI)
	For nI2 := 1 To oCOY_DETAIL:Length()
		oCOY_DETAIL:GoLine(nI2)
		If (oCOY_DETAIL:GetValue('COY_CODPRO') == cCodProd )
			
			oCOY_DETAIL:SetNoDeleteLine(.F.)
			If nQtde == 0
				oCOY_DETAIL:SetValue('COY_QUANT', nQtde)			
				oCOY_DETAIL:DeleteLine()
			Else
				oCOY_DETAIL:UnDeleteLine()			
			
				If nQtde > 0
					oCOY_DETAIL:SetValue('COY_QUANT', nQtde)
				EndIf																	
			EndIf
			oCOY_DETAIL:SetNoDeleteLine(.T.)			
			Exit												
		EndIf
			
	Next nI2	
Next nI
	
FWRestRows(aSaveLines)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101IncP()
Inclui os produtos na aba de composição do Lote
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP101IncP(oModel)
Local oCOY_DETAIL := oModel:GetModel('COY_DETAIL')
Local oCON_DETAIL := oModel:GetModel('CON_DETAIL')
Local nI 			:= 0
Local aSaveLines := FWSaveRows()

oCOY_DETAIL:SetNoDeleteLine(.F.)
oCOY_DETAIL:SetNoInsertLine(.F.)

For nI := 1 To oCON_DETAIL:Length()
	oCON_DETAIL:GoLine(nI)
	If nI # 1
		oCOY_DETAIL:AddLine()
	EndIf				
	oCOY_DETAIL:SetValue('COY_CODPRO', oCON_DETAIL:GetValue('CON_CODPRO'))
	oCOY_DETAIL:SetValue('COY_QUANT',  oCON_DETAIL:GetValue('CON_QUANT'))	
Next nI

oCOY_DETAIL:SetNoInsertLine(.T.)
oCOY_DETAIL:SetNoDeleteLine(.T.)

FWRestRows(aSaveLines)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101VLPD()
Função que retorna calculo do produto conforme o metodo de avaliação
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP101VLPD(cCodAm, cCodProd, cLote, cMetodo)
Local nValor := 0
Do Case 
	Case cMetodo == '1'
		nValor := GCP101Glb(cCodAm, cCodProd, cLote)
	
	Case cMetodo == '2'
		nValor := GCP101MaMe(cCodAm, cCodProd, cLote)			
			
	Case cMetodo == '3'
		nValor := GCP101Mr(cCodAm, cCodProd, cLote)
	
	Case cMetodo == '4'
		nValor := GCP101Mn(cCodAm, cCodProd, cLote)
	
	Case cMetodo == '5'
		nValor := GCP101Intr(cCodAm, cCodProd, cLote)

	Case cMetodo == '6'
		nValor := GCP101Inf(cCodAm, cCodProd, cLote)																						
EndCase 
Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101Glb()
Função que retorna calculo do produto baseado na media global
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP101Glb(cCodAm, cCodProd, cLote)
Local cAliasCOY := GetNextAlias()
Local nValor := 0

BeginSQL Alias cAliasCOY
	SELECT 	AVG(COY_VLRTOT) COY_VLRTOT 
	FROM 	%Table:COY% COY
	INNER JOIN %Table:COP%  COP 
	ON 		COP.COP_FILIAL 		= COY.COY_FILIAL
			AND COY.COY_CODIGO 	= COP.COP_CODIGO
			AND COY.COY_CODFOR 	= COP.COP_CODFOR 
			AND COY.COY_LOJFOR 	= COP.COP_LOJFOR 
			AND COY.COY_LOTE 	= COP.COP_LOTE
			AND COP.%NotDel%  
	WHERE 	COY.COY_FILIAL 		= %xFilial:COY%
			AND COY.COY_CODIGO 	= %Exp:cCodAm%
			AND COY.COY_CODPRO 	= %Exp:cCodProd%
			AND COY.COY_LOTE 	= %Exp:cLote%      
			AND COP.COP_OK 		= 'T'
			AND COY.%NotDel%            
EndSQL

nValor := (cAliasCOY)->COY_VLRTOT

(cAliasCOY)->(DbCloseArea())
Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101MaMe()
Função que retorna calculo do produto baseado na media entre o maior e menor
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP101MaMe(cCodAm, cCodProd, cLote)
Local cAliasCOY	:= GetNextAlias()
Local nValor 		:= 0

Local aCalMaior	:= A100CalMaMe(1,cCodAm,cLote) //Retorna a media do maior
Local aCalMenor	:= A100CalMaMe(2,cCodAm,cLote) //Retorna a media do menor

BeginSQL Alias cAliasCOY
	SELECT DISTINCT
				(		
					(	
					SELECT 	COY_VLRTOT  
					FROM 	%Table:COY% COY
						 			
					WHERE 	COY.COY_FILIAL 		= %xFilial:COY%
							AND COY.COY_CODIGO 	= %Exp:cCodAm%
							AND COY.COY_CODPRO 	= %Exp:cCodProd%
							AND COY.COY_LOTE 	= %Exp:cLote%      
							AND COY_CODFOR 		= %Exp:aCalMaior[1]%
							AND COY_LOJFOR 		= %Exp:aCalMaior[2]%
							AND COY.%NotDel%
					) 
					+
					(
					SELECT 	COY_VLRTOT 
					FROM 	%Table:COY% COY
					WHERE 	COY.COY_FILIAL 		= %xFilial:COY%
							AND COY.COY_CODIGO 	= %Exp:cCodAm%
							AND COY.COY_CODPRO 	= %Exp:cCodProd%
							AND COY.COY_LOTE 	= %Exp:cLote%
							AND COY_CODFOR 		= %Exp:aCalMenor[1]%
							AND COY_LOJFOR 		= %Exp:aCalMenor[2]%
							AND COY.%NotDel%
					)
				)  / 2 COY_VLRTOT 		
	FROM %Table:COY%										
EndSQL
		
nValor := (cAliasCOY)->COY_VLRTOT

(cAliasCOY)->(DbCloseArea())

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101Mr()
Função que retorna calculo do produto baseado no maior valor
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP101Mr(cCodAm, cCodProd, cLote)
Local cAliasCOY := GetNextAlias()
Local nValor := 0
Local aCalMaior	:= A100CalMaMe(1,cCodAm,cLote) //Retorna a media do maior

BeginSQL Alias cAliasCOY
	SELECT	COY.COY_VLRTOT 
	FROM 	%Table:COY% COY
	WHERE 	COY.COY_FILIAL 		= %xFilial:COY%
			AND COY.COY_CODIGO 	= %Exp:cCodAm%
			AND COY.COY_CODPRO 	= %Exp:cCodProd%
			AND COY.COY_LOTE 	= %Exp:cLote%
			AND COY_CODFOR 		= %Exp:aCalMaior[1]%
			AND COY_LOJFOR 		= %Exp:aCalMaior[2]%
			AND COY.%NotDel%
EndSQL

nValor := (cAliasCOY)->COY_VLRTOT
		
(cAliasCOY)->(DbCloseArea())
Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101Mn()
Função que retorna calculo do produto baseado no menor valor
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP101Mn(cCodAm, cCodProd, cLote)
Local cAliasCOY := GetNextAlias()
Local nValor := 0
Local aCalMenor	:= A100CalMaMe(2,cCodAm,cLote) //Retorna a media do menor

BeginSQL Alias cAliasCOY
	SELECT	COY.COY_VLRTOT 
	FROM 	%Table:COY% COY
	WHERE 	COY.COY_FILIAL 		= %xFilial:COY%
			AND COY.COY_CODIGO	= %Exp:cCodAm%
			AND COY.COY_CODPRO	= %Exp:cCodProd%
			AND COY.COY_LOTE	= %Exp:cLote%
			AND COY_CODFOR		= %Exp:aCalMenor[1]%
			AND COY_LOJFOR		= %Exp:aCalMenor[2]%
			AND COY.%NotDel%	
EndSQL

nValor := (cAliasCOY)->COY_VLRTOT
		
(cAliasCOY)->(DbCloseArea())
Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101Intr()
Função que retorna calculo do produto baseado no valor intermediario
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP101Intr(cCodAm, cCodProd, cLote)
Local cAliasCOP	:= GetNextAlias()
Local cAliasCOY 	:= GetNextAlias()
Local nValor		:= 0
Local nPos 		:= 0
Local nI 			:= 0
Local cCodFor 	:= ""
LOcal cLojFor		:= ""

BeginSQL Alias cAliasCOP
	SELECT	COP.COP_CODFOR,
			COP.COP_LOJFOR,
			COP.COP_VALTOT 
	FROM	%Table:COP% COP				
	WHERE	COP.COP_FILIAL 		= %xFilial:COP%
			AND COP.COP_CODIGO 	= %Exp:cCodAm%
			AND COP.COP_LOTE 	= %Exp:cLote%
			AND COP.COP_OK 		= 'T'
			AND COP.%NotDel%
	ORDER BY COP.COP_VALTOT  
EndSQL

While (cAliasCOP)->(!Eof())
	nPos := nPos + 1
	(cAliasCOP)->(dbSkip())
EndDo
(cAliasCOP)->(dbGoTop())

nPos := round(nPos / 2,0 )
For nI := 1 To nPos
	cCodFor := (cAliasCOP)->COP_CODFOR
	cLojFor := (cAliasCOP)->COP_LOJFOR
	(cAliasCOP)->(dbSkip())
Next nI

(cAliasCOP)->(DbCloseArea())

BeginSQL Alias cAliasCOY
	SELECT 	COY.COY_VLRTOT
	FROM 	%Table:COY% COY
	WHERE	COY.COY_FILIAL		= %xFilial:COY%
			AND COY.COY_CODIGO 	= %Exp:cCodAm%
			AND COY.COY_CODPRO	= %Exp:cCodProd%
			AND COY.COY_LOTE	= %Exp:cLote%
			AND COY_CODFOR		= %Exp:cCodFor%
			AND COY_LOJFOR		= %Exp:cLojFor%
			AND COY.%NotDel%
EndSQL

nValor := (cAliasCOY)->COY_VLRTOT
		
(cAliasCOY)->(DbCloseArea())
Return nValor
  
//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101Inf()
Função que retorna calculo do produto baseado no valor informado
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP101Inf(cCodAm, cCodProd, cLote)
Local cAliasCOY := GetNextAlias()
Local nValor := 0

BeginSQL Alias cAliasCOY
	SELECT	(COQ_VLRTOT) / (
							SELECT 	COUNT(1) 
							FROM 	%Table:COY% COY 
							INNER JOIN %Table:COP% COP 
							ON 		COY.COY_FILIAL 		= COP.COP_FILIAL
									AND COY.COY_CODIGO 	= COP.COP_CODIGO
									AND COY.COY_CODFOR	= COP.COP_CODFOR 
									AND COY.COY_LOJFOR	= COP.COP_LOJFOR
									AND COY.COY_LOTE 	= COP.COP_LOTE
									AND COP.%NotDel%							
							WHERE	COY.COY_FILIAL		= %xFilial:COY%
									AND COY.COY_CODIGO	= %Exp:cCodAm%
									AND COY.COY_CODPRO	= %Exp:cCodProd%
									AND COY.COY_LOTE	= %Exp:cLote%
									AND COP.COP_OK		= 'T'
									AND COY.%NotDel%
							)  COY_VLRTOT
	FROM 	%Table:COQ% COQ
	WHERE 	COQ.COQ_FILIAL 		= %xFilial:COQ%
			AND COQ.COQ_CODIGO 	= %Exp:cCodAm%
			AND COQ.COQ_LOTE 	= %Exp:cLote%
			AND COQ.%NotDel%   																
EndSQL

nValor := (cAliasCOY)->COY_VLRTOT
		
(cAliasCOY)->(DbCloseArea())
Return nValor 

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101Cmt()
Rotina para efetuar a persistência dos dados e atualizar o status das SC's Vinculadas
@author Matheus Lando Raimundo
@since 23/09/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP101Cmt(oModel)
Local oCON_DETAIL := oModel:GetModel('CON_DETAIL')
Local oCOO_DETAIL := oModel:GetModel('COO_DETAIL')
Local oCOQ_DETAIL := oModel:GetModel('COQ_DETAIL')
Local lRet 		:= .T.
Local nI 			:= 0
Local nI2          := 0
Local nI3	 		:= 0

//AJUSTAR O INDICE
If SC1->(IndexKey(1)) == "C1_FILIAL+C1_NUM+C1_ITEM"
       SC1->(dbSetOrder(1))  
EndIf

//FOR NOS PRODUTOS E FOR NAS SOLICITAÇÕES
For nI := 1 To oCOQ_DETAIL:Length()
	oCOQ_DETAIL:GoLine(nI)

	For nI2 := 1 To oCON_DETAIL:Length()
	    oCON_DETAIL:GoLine(nI2)
	    If (oCON_DETAIL:IsDeleted() .And. !oCOO_DETAIL:IsDeleted()) .And. (oCON_DETAIL:IsDeleted() .And. oCOO_DETAIL:Length() == 0)
	       Loop
	    EndIf
	                                            
	    For nI3 := 1 To oCOO_DETAIL:Length()
	        oCOO_DETAIL:GoLine(nI3)    
	             
	        If oCOO_DETAIL:IsDeleted() .Or. (oCON_DETAIL:IsDeleted() .And. oCOO_DETAIL:Length() > 0) 
	        	If (oModel:GetOperation() == MODEL_OPERATION_UPDATE) .And. SC1->(dbSeek(xFilial("SC1")+oCOO_DETAIL:GetValue('COO_NUMSC')+oCOO_DETAIL:GetValue('COO_ITEMSC')))
	        		RecLock("SC1",.F.)
	                SC1->C1_COTACAO   := ''
	                SC1->(MsUnLock())
	        	EndIf
	        	Loop
	       	Else
	          	oCOO_DETAIL:GoLine(nI3)
	            If SC1->(dbSeek(xFilial("SC1")+oCOO_DETAIL:GetValue('COO_NUMSC')+oCOO_DETAIL:GetValue('COO_ITEMSC')))
	            	RecLock("SC1",.F.)
	                If oModel:GetOperation() == MODEL_OPERATION_DELETE
	                	SC1->C1_COTACAO   := ''
	                Else
	                	SC1->C1_COTACAO   := 'ANALISE'
	                EndIf
	                
	                SC1->(MsUnLock())
	            EndIf     
	       	EndIf
	    
	    Next nI3    
	Next nI2
Next nI	
	
If FwFormCommit(oModel)
	//EventViewer 057 - Analise de Mercado
	EnvAberAM(oModel)
EndIf   

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101CVLT(nRet,lAtualiz)
Rotina para Calcular valor do lote.

@author alexandre.gimenez
@param nRet Valor do lote, para ser atualizado por referencia.
@param lAtualiz controle para atualizar ou não o valor do lote.
@return lRet
@since 12/09/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function GCP101CVLT(nRet,lAtualiz)
Local oModel		:= FWModelActive()
Local lUsaLote	:= oModel:GetId() == 'GCPA101'
Local oModProd	:= oModel:GetModel("CON_DETAIL")
Local oModLote	:= IIF(lUsaLote,oModel:GetModel("COQ_DETAIL"),NIL)
Local aSaveLines 	:= FWSaveRows()
Local nX			:= 0
local lRet			:= .T.

Default nRet		:= 0
Default lAtualiz	:= .T.

If lUsaLote
	For nX := 1 To oModProd:length()
		oModProd:GoLine(nX)
		If !oModProd:IsDeleted()
			nRet += oModProd:GetValue("CON_QUANT") * oModProd:GetValue("CON_VALEST")
		EndIf
	Next nX	
	If lAtualiz
		oModLote:LoadValue('COQ_VLRTOT',nRet)
	EndIf
EndIf
FWRestRows(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101CalF()
Rotina para Calcular valor por fornecedor

@author Leonardo Quintania
@return lRet
@since 12/09/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function GCP101CalF()
Local oModel := FWModelActive()
Local oCOY_DETAIL := oModel:GetModel('COY_DETAIL')
Local oCOP_DETAIL := oModel:GetModel('COP_DETAIL')
Local nI := 0
Local nJ := 0
Local nValor := 0
Local aSaveLines := FWSaveRows()

For nJ := 1 To oCOP_DETAIL:Length()
	oCOP_DETAIL:GoLine(nJ)
	For nI := 1 To oCOY_DETAIL:Length()
	 	oCOY_DETAIL:GoLine(nI)
	 	If !oCOY_DETAIL:IsDeleted()
			nValor := nValor + oCOY_DETAIL:GetValue('COY_VLRTOT')
		EndIf		
	Next nI
	oCOP_DETAIL:SetValue('COP_PRCUN', nValor)
	nValor:= 0
Next nJ

If (nValor > 0) .And. (oCOP_DETAIL:IsDeleted())
	oCOP_DETAIL:UnDeleteLine()	
EndIf

FWRestRows(aSaveLines)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101Load()
Gatilho que carrega a aba de componentes do lote

@author Leonardo Quintania
@return lRet
@since 12/09/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function GCP101Load()
Local oModel 		:= FWModelActive()
Local oCON_DETAIL	:= oModel:GetModel('CON_DETAIL')
Local oCOP_DETAIL	:= oModel:GetModel('COP_DETAIL')
Local oCOY_DETAIL	:= oModel:GetModel('COY_DETAIL')
Local nI			:= 1
Local nJ			:= 1
Local lAchou		:=.F.
Local lAddLine	:=.T.
Local aSaveLines 	:= FWSaveRows()

If oCOY_DETAIL <> NIL .And. !oCON_DETAIL:IsDeleted() .And. !Empty(oCON_DETAIL:GetValue('CON_CODPRO')) .And. !Empty(oCOP_DETAIL:GetValue('COP_CODFOR'))
	oCOY_DETAIL:SetNoInsertLine(.F.)
	oCOY_DETAIL:SetNoDeleteLine(.F.)
	
	For nI := 1 To oCOP_DETAIL:Length()
		oCOP_DETAIL:GoLine( nI )
		For nJ := 1 To oCOY_DETAIL:Length()
			oCOY_DETAIL:GoLine( nJ )
			If Empty(oCOY_DETAIL:GetValue('COY_CODPRO'))
				lAddLine:= .F.
			Else
				If !GCP101Cons(oCOY_DETAIL:GetValue('COY_CODPRO')) //Caso não encontre o produto na aba de produtos
					oCOY_DETAIL:DeleteLine()
				EndIf
			EndIf
			If oCOY_DETAIL:GetValue('COY_CODPRO') == oCON_DETAIL:GetValue('CON_CODPRO')
				lAchou		:= .T.
				lAddLine	:= .F.
				Exit
			EndIf
			
		Next nJ 
		
		If !lAchou
			If lAddLine
				oCOY_DETAIL:AddLine()
			EndIf
		EndIf
	
		oCOY_DETAIL:SetValue('COY_CODPRO', oCON_DETAIL:GetValue('CON_CODPRO'))
		oCOY_DETAIL:SetValue('COY_QUANT',  oCON_DETAIL:GetValue('CON_QUANT'))	
	
	Next nI
	
	oCOY_DETAIL:SetNoInsertLine(.T.)
	oCOY_DETAIL:SetNoDeleteLine(.T.)
	
	FWRestRows(aSaveLines)
		
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP101Cons(cProduto)
Realiza Consistencia dos dados da tabela CON com a tabela COY 
@param cProduto Codigo do produto para pesquisar na tabela CON
@author Leonardo Quintania
@return lRet
@since 12/09/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function GCP101Cons(cProduto)
Local oModel 		:= FWModelActive()
Local oCON_DETAIL	:= oModel:GetModel('CON_DETAIL')
Local nI			:= 1
Local lAchou		:=.F.
Local aSaveLines 	:= FWSaveRows()

For nI := 1 To oCON_DETAIL:Length()
	oCON_DETAIL:GoLine( nI )
	If oCON_DETAIL:GetValue('CON_CODPRO') == cProduto
		lAchou:= .T.
		Exit
	EndIf
Next nI

FWRestRows(aSaveLines)

Return lAchou

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPDelCOY(cProduto)
Deleta composição de lote conforme produtos
@param cProduto Codigo do produto para pesquisar na tabela COY e efetuar o delete.
@author Leonardo Quintania
@return lRet
@since 12/09/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function GCPDelCOY(cProduto)
Local oModel 		:= FWModelActive()
Local oCOP_DETAIL	:= oModel:GetModel('COP_DETAIL')
Local oCOY_DETAIL	:= oModel:GetModel('COY_DETAIL')
Local nI			:= 1
Local nJ			:= 1
Local aSaveLines 	:= FWSaveRows()

oCOY_DETAIL:SetNoDeleteLine(.F.)

For nJ := 1 To oCOP_DETAIL:Length()
	oCOP_DETAIL:GoLine( nJ )
	For nI := 1 To oCOY_DETAIL:Length()
		oCOY_DETAIL:GoLine( nI )
		If oCOY_DETAIL:GetValue('COY_CODPRO') == cProduto
			If oCOY_DETAIL:IsDeleted()
				oCOY_DETAIL:UnDeleteLine()
			Else
				oCOY_DETAIL:DeleteLine()
			EndIf
			Exit
		EndIf
	Next nI
Next nJ

oCOY_DETAIL:SetNoDeleteLine(.T.)

FWRestRows(aSaveLines)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} A100CalMaMe(nOpc,cCodAm,cLote)
Efetua select conforme 
@author Leonardo Quintania
@return lRet
@since 12/09/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function A100CalMaMe(nOpc,cCodAm,cLote)

Local aReturn := {}

If nOpc == 1
	BeginSql Alias "COPTMP"
		SELECT	COP_CODFOR,
				COP_LOJFOR 
		FROM	%Table:COP% COP
		WHERE	COP.COP_FILIAL		= %xFilial:COP%
				AND COP.COP_CODIGO	= %Exp:cCodAm%
				AND COP.COP_LOTE	= %Exp:cLote%
				AND COP.COP_OK		= 'T'
				AND COP.COP_VALTOT	= (	SELECT	MAX(COP_VALTOT)
										FROM 	%Table:COP% COP2
										WHERE	COP2.COP_FILIAL 	= %xFilial:COP%
												AND COP2.COP_CODIGO	= %Exp:cCodAm%
												AND COP2.COP_LOTE 	= %Exp:cLote%
												AND COP2.COP_OK		= 'T'
												AND COP2.%NotDel%	)
				AND COP.%NotDel%					
	EndSQL
Else
	BeginSql Alias "COPTMP"
		SELECT	COP_CODFOR,
				COP_LOJFOR 
		FROM	%Table:COP% COP
		WHERE 	COP.COP_FILIAL		= %xFilial:COP%
				AND COP.COP_CODIGO 	= %Exp:cCodAm%
				AND COP.COP_LOTE 	= %Exp:cLote%
				AND COP.COP_OK 		= 'T'
				AND COP.COP_VALTOT 	= (	SELECT	MIN(COP_VALTOT)
										FROM 	%Table:COP% COP2
										WHERE	COP2.COP_FILIAL 	= %xFilial:COP%
												AND COP2.COP_CODIGO = %Exp:cCodAm%
												AND COP2.COP_LOTE 	= %Exp:cLote%
												AND COP2.COP_OK 	= 'T'
												and COP2.%NotDel%	)
				AND COP.%NotDel%
	EndSQL
EndIf

aAdd(aReturn,COPTMP->COP_CODFOR)
aAdd(aReturn,COPTMP->COP_LOJFOR)

COPTMP->(dbCloseArea())

Return aReturn
