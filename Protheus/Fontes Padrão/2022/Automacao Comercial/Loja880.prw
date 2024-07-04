#INCLUDE "Protheus.ch"
#INCLUDE "LOJA880.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 
 

Static lR7 := GetRpoRelease("R7")

//-------------------------------------------------------------------
/*{Protheus.doc} Loja880
Cadastro de Kits

@author leandro.dourado
@since 06/08/2012
@version 11.7
*/
//-------------------------------------------------------------------

Function Loja880()

Private aRotina	:= MenuDef()

If lR7
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('MEU')
	oBrowse:SetDescription(STR0001) //"Cadastro de Kit de Produtos"
	oBrowse:Activate()
Else
	Help('',1,'INVLDVER',,STR0002,1,0) //"Essa função está disponível apenas para a versão 11.8 ou superior."
EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Menu Funcional

@author leandro.dourado
@since 06/08/2012
@version 11.7
*/
//-------------------------------------------------------------------
Static Function MenuDef()     
Local aRotina        := {}

ADD OPTION aRotina TITLE STR0003 ACTION "PesqBrw"             OPERATION 0                         ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.LOJA880"     OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.LOJA880"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.LOJA880"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.LOJA880"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0 //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definicao do Modelo

@author leandro.dourado
@since 06/08/2012
@version 11.7
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructMEU 	:= FWFormStruct(1,"MEU")
Local oStructMEV 	:= FWFormStruct(1,"MEV")
Local oModel 		:= Nil

//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA880",/*Pre-Validacao*/,{|oModel| LJ880TOk(oModel)}/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("MEUMASTER", Nil/*cOwner*/, oStructMEU ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
oModel:GetModel("MEUMASTER"):SetDescription(STR0001)  //"Cadastro de Kit de Produtos"

oModel:SetPrimaryKey({"MEU_FILIAL+MEU_CODIGO"})

oModel:AddGrid("MEVDETAIL", "MEUMASTER"/*cOwner*/, oStructMEV,/*{|oModelGrid,nLinha,cAction| LJ880LnPos(oModelGrid,nLinha,cAction)}LinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/) 
oModel:SetRelation("MEVDETAIL",{{"MEV_FILIAL",'xFilial("MEV")'},{"MEV_CODKIT","MEU_CODIGO"}},MEV->(IndexKey()))

oModel:AddCalc("LJ880CALC","MEUMASTER","MEVDETAIL","MEV_QTD","NUMITENS","COUNT",,,STR0008)	//"Número de Itens"
oModel:AddCalc("LJ880CALC","MEUMASTER","MEVDETAIL","MEV_QTD","NUMPECAS","SUM",,,STR0009)	//"Número de Peças"

oModel:GetModel('MEVDETAIL'):SetUniqueLine({'MEV_PRODUT'})

Return oModel

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definicao da Visao

@author leandro.dourado
@since 06/08/2012
@version 11.7
*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView  		:= Nil
Local oModel  		:= FWLoadModel("LOJA880")
Local oStructMEU 	:= FWFormStruct(2,"MEU")
Local oStructMEV 	:= FWFormStruct(2,"MEV")
Local oCalc  		:= FWCalcStruct(oModel:GetModel('LJ880CALC'))

//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)   
oView:EnableControlBar(.T.)  
oView:AddField( "VIEW_CABMEU" , oStructMEU, "MEUMASTER" )
oView:CreateHorizontalBox( "HEADER" , 30 )
oView:SetOwnerView( "VIEW_CABMEU" , "HEADER" )

oView:AddGrid("VIEW_ITMEV" , oStructMEV,"MEVDETAIL")
oView:CreateHorizontalBox( "ITENS" , 60 )
oView:SetOwnerView( "VIEW_ITMEV" , "ITENS" )

oView:AddField( 'VIEW_CALC', oCalc, 'LJ880CALC' )
oView:CreateHorizontalBox( "CALC" , 10 )
oView:SetOwnerView( 'VIEW_CALC' , 'CALC')
                
Return oView

//-------------------------------------------------------------------
/*{Protheus.doc} LJ880VldProd
Realiza o valid do campo MEV_PRODUT

@author leandro.dourado
@since 07/08/2012
@param - nCampo: Indica qual é o campo que está chamando a função
		  nCampo = 1: Chamado pelo campo MEU_CODIGO
		  nCampo = 2: Chamado pelo campo MEV_PRODUT
@version 11.7
*/
//-------------------------------------------------------------------
Function LJ880VldProd(nCampo)
Local oModel	:= FwModelActive()
Local lRet  	:= .T.
Local cProdMEU	:= oModel:GetValue("MEUMASTER","MEU_CODIGO")
Local cProdMEV	:= oModel:GetValue("MEVDETAIL","MEV_PRODUT")

If nCampo == 1 //campo MEU_CODIGO
	lRet := ExistChav("MEU",cProdMEU) 
	
	If !lRet
		Help('',1,'PRDINVALID',,STR0010,1,0)		//"O produto selecionado já foi utilizado no cadastro de Kit de Produtos."
	EndIf
	
	If lRet
		lRet := ExistCpo("SB1",cProdMEU)
	EndIf
	
	If lRet
		lRet := Posicione('SB1',1,xFilial('SB1')+cProdMEU,'B1_TIPO') == "KT"
		If !lRet
			Help('',1,'PRDINVALID',,STR0011,1,0)		//"Somente produtos do tipo 'KT' podem ser selecionados."
		EndIf
	EndIf
			
ElseIf nCampo == 2 //campo MEV_PRODUT
	lRet := ExistCpo("SB1",cProdMEV)
	
	If lRet
		lRet := Posicione('SB1',1,xFilial('SB1')+cProdMEV,'B1_TIPO') != "KT"
		If !lRet
			Help('',1,'PRDINVALID',,STR0012,1,0)	//"Os produtos que compõe um Kit de Produtos não podem ser do tipo KT."
		EndIf
	EndIf
	
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} LJ880VldDesc
Realiza o valid dos campos de Desconto

@author leandro.dourado
@since 08/08/2012
@param - nCampo: Indica qual é o campo que está chamando a função
		  nCampo = 1: Chamado pelo campo MEU_DESCNT
		  nCampo = 2: Chamado pelo campo MEV_DESCNT
@version 11.7
*/
//-------------------------------------------------------------------
Function LJ880VldDesc()
Local oModel		:= FwModelActive()
Local oModelGrid 	:= oModel:GetModel("MEVDETAIL")
Local oView		:= FwViewActive()
Local nX			:= 0
Local aSaveLine 	:= FWSaveRows()
Local lFilled		:= .F. //Indica se o campo MEV_DESCNT de alguma das linhas está preenchido
Local lRet 		:= .T.

For nX := 1 To oModelGrid:Length()
	oModelGrid:GoLine(nX)
	If !Empty(oModelGrid:GetValue("MEV_DESCNT"))
		lFilled := .T.
	EndIf
	If lFilled
		Exit
	EndIf
Next nX

If lFilled
	If oView <> Nil .OR. MsgYesNo(STR0013,STR0014)    	//"Ao preencher este campo, o campo de desconto dos itens será zerado. Confirma o preenchimento?"    //"Atenção!"
		For nX := 1 To oModelGrid:Length()
			oModelGrid:GoLine(nX)
			oModelGrid:LoadValue("MEV_DESCNT",CriaVar("MEV_DESCNT"))
		Next nX
	Else
		lRet := .F.
	EndIf
EndIf

FWRestRows(aSaveLine)
oView:Refresh()

Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} LJ880TOk()
Valida o conteúdo do kit

@author marisa.cruz
@since 22/11/2018
@param - oModel - obrigatório para validação
@version 12.1.17
*/
//-------------------------------------------------------------------
Function LJ880TOk(oModel)

Local oMdDet     := oModel:GetModel("MEVDETAIL") // Modelo de dados do Detalhe MEV
Local nX			:= 0
Local lRet			:= .T.
Local lAux			:= .T.
Local lAuxAnt		:= .T.
Local cProd			:= ""
Local cListaProd	:= ""

Default oModel := Nil

If oMdDet != Nil
	For nX := 1 to Len(oMdDet:aDataModel)
		If !oMdDet:IsDeleted()
			oMdDet:GoLine( nX )
			cProd := oMdDet:GetValue('MEV_PRODUT')
			lAux := Posicione('SB1',1,xFilial('SB1')+cProd,'B1_VALEPRE') == "1"
			
			//Informo na tela produtos de vale-presente para um aviso posterior
			If lAux
				If !Empty(cListaProd)
					cListaProd += ", "
				EndIf
				cListaProd += Alltrim(cProd)
			EndIf
			
			//Verificação, se tiver produto comum e produto vale-presente no mesmo kit, não será possível validar
			If nX > 1 .AND. lAux <> lAuxAnt
				lRet := .F.
			EndIf
			lAuxAnt := lAux
		EndIf
	Next
	
	If !lRet
		Help(" ",1,"Help","LJ880TOK",STR0015+Chr(13)+Chr(10)+Chr(13)+Chr(10)+STR0016+cListaProd,1,0) //"Para o cadastro de kits, não poderá misturar códigos de produtos Vale-Presente com produtos comuns."###"Produtos vale-presente: "
	EndIf
EndIf

Return lRet