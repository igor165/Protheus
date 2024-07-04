#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA014.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA014()
Permissao de Produto
@author Allyson Freitas
@since 12/01/2012
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function MATA014()
Local oBrowse := FWMBrowse():New()
	
	oBrowse:SetAlias('SDW')
	oBrowse:SetDescription(STR0001) //Cadastro de Permissoes
	oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Allyson Freitas
@since 12/01/2012
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina 	:= {}
Local nX

	ADD OPTION aRotina TITLE STR0004 ACTION 'ViewDef.MATA014'	OPERATION 2 ACCESS 0 //Visualizar
	ADD OPTION aRotina TITLE STR0005 ACTION 'ViewDef.MATA014'	OPERATION 3 ACCESS 0 //Incluir
	ADD OPTION aRotina TITLE STR0006 ACTION 'ViewDef.MATA014'	OPERATION 4 ACCESS 0 //Alterar
	ADD OPTION aRotina TITLE STR0007 ACTION 'ViewDef.MATA014'	OPERATION 5 ACCESS 0 //Excluir

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para adicionar botoes |
	//|no MenuDef                             |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If ExistBlock("MT014MNU")
	    aRotAdic := ExecBlock("MT014MNU",.F.,.F.)
	    If ValType(aRotAdic) == "A" 
	        For nX := 1 to Len(aRotAdic)
	            ADD OPTION aRotina TITLE aRotAdic [nX] [1] ACTION aRotAdic [nX] [2] OPERATION aRotAdic [nX] [4] ACCESS 0  
	        Next nX
	    EndIf
	EndIf
	
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Allyson Freitas
@since 12/01/2012
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCab := FWFormStruct(1,"SDW",{|cCampo| AllTrim(cCampo) $ "DW_PRODUTO|DW_DESC|DW_GRPPROD|DW_DESCGRP"})
Local oStruSDW := FWFormStruct(1,"SDW",{|cCampo| !AllTrim(cCampo) $ "DW_PRODUTO|DW_DESC|DW_GRPPROD|DW_DESCGRP"})
Local oModel     := Nil

oStruCab:SetProperty("DW_PRODUTO",MODEL_FIELD_WHEN,{|| A014PrdBlq("DW_PRODUTO")})
oStruCab:SetProperty("DW_GRPPROD",MODEL_FIELD_WHEN,{|| A014PrdBlq("DW_GRPPROD")})

oModel := MPFormModel():New("MATA014",,{ |oModel| A104TudoOk( oModel ) })
oModel:AddFields("MATA014_CAB",/*cOwner*/,oStruCab)
oModel:GetModel("MATA014_CAB"):SetDescription(STR0002) //Permissoes

oModel:AddGrid("MATA014_SDW","MATA014_CAB",oStruSDW,,{|oModelGrid| A014LinOk(oModelGrid)})
oModel:GetModel("MATA014_SDW"):SetDescription(STR0003) //Usuario x Documento

oModel:SetRelation("MATA014_SDW",{{"DW_FILIAL",'xFilial("SDW")'},{"DW_PRODUTO","DW_PRODUTO"},{"DW_GRPPROD","DW_GRPPROD"}},SDW->(IndexKey(1)))
oModel:GetModel("MATA014_SDW"):SetUniqueLine({"DW_USER","DW_GRUPO","DW_DOC"})
oModel:SetPrimaryKey({})

Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Allyson Freitas
@since 12/01/2012
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oStruCab := FWFormStruct(2,"SDW",{|cCampo| AllTrim(cCampo) $ "DW_PRODUTO|DW_DESC|DW_GRPPROD|DW_DESCGRP"})
Local oStruSDW := FWFormStruct(2,"SDW",{|cCampo| !AllTrim(cCampo) $ "DW_PRODUTO|DW_DESC|DW_GRPPROD|DW_DESCGRP"})
Local oModel := FWLoadModel("MATA014")
	
oView := FWFormView():New()
oView:SetUseCursor(.F.)
oView:SetModel(oModel)
oView:EnableControlBar(.T.)

oView:AddUserButton(STR0008,'CLIPS',{|| A014VCP()})  //Cad. Produto
oView:AddUserButton(STR0009,'CLIPS',{|| A014VPQ()}) //Pesquisar

oView:AddField("HEADER_SDW",oStruCab,"MATA014_CAB")   
oView:CreateHorizontalBox("CABEC",20)
oView:SetOwnerView("HEADER_SDW","CABEC")


oView:AddGrid("GRID_SDW",oStruSDW,"MATA014_SDW")
oView:CreateHorizontalBox("GRID",80)
oView:SetOwnerView("GRID_SDW","GRID")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} A014LinOk()
Visualizacao do Cadastro de Produtos
@author Allyson Freitas
@since 12/01/2012
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function A014LinOk(oModel)
Local lRet := .T.

lRet := !(Empty(oModel:GetValue("DW_USER")) .And. Empty(oModel:GetValue("DW_GRUPO")))
If !lRet	
	Help(" ",1,"OBRIGAT2")
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A014VCP()
Visualizacao do Cadastro de Produtos
@author Allyson Freitas
@since 12/01/2012
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function A014VCP()
Local aArea := GetArea()	
Local nOpcao

Private cCadastro := STR0018 //Cadastro de Produtos

	DbSelectArea('SB1')
	DbSeek(xFilial('SB1')+M->DW_PRODUTO)
	nOpcao := AxVisual("SB1",Recno(),2)
	
	RestArea(aArea)
Return Nil    


//-------------------------------------------------------------------
/*/{Protheus.doc} A014VPQ()
Cria e ativa a tela de pesquisa
@author Allyson Freitas
@since 12/01/2012
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function A014VPQ()
Local oDlg
Local oRadio,nRadio,oBtnConf,oBtnCanc,oDado,oGetDoc,oSayDoc,oChkBus
Local lCheck := .F.
Local cDado := Space(30)
Local cDoc := Space(6)
Local aItems := {STR0011,STR0012,STR0013}	 //Por usuario ; Por grupo; Por nome
	
	//Construcao da Tela de Pesquisa
	DEFINE MSDIALOG oDlg FROM 0,0 TO 150,500 PIXEL TITLE STR0010 													//Pesquisa
		oRadio := TRadMenu():New(10,10,aItems,{|u|If(PCount()==0,nRadio,nRadio:=u)},oDlg,,,,,,,,50,12,,,,.T.)
		oDado := TGet():New(20,50,{|u|If(Pcount()>0,cDado:= u,cDado)},oDlg,100,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cDado,,,,)
		oCheckBus := TCheckBox():New(22,155,STR0014,{|u|If(Pcount()==0,lCheck,lCheck:=u)},oDlg,100,210,,,,,,,,.T.,,,)  			//Buscar expressao exata
		oSayDoc := TSay():New(43,15,{||STR0015},oDlg,,,,,,.T.,,,200,20)  														//Documento
		oGetDoc := TGet():New(40,50,{|u| If(Pcount()>0,cDoc := u,cDoc)},oDlg,100,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cDoc,,,,)
		oBtnConf := TButton():New(60,164,STR0016,oDlg,{||A014PESQ(oDlg,nRadio,cDado,cDoc,lCheck)},40,12,,,.F.,.T.,.F.,,.F.,,,.F.)	//Confirma
    	oBtnCanc := TButton():New(60,207,STR0017,oDlg,{||oDlg:End()},40,12,,,.F.,.T.,.F.,,.F.,,,.F.) 								//Cancela
	ACTIVATE MSDIALOG oDlg CENTERED

Return NIL


//------------------------------------------------------------------------------
/*/{Protheus.doc} A014PESQ(oDlg,nTipo,cDado,cDoc,lBusca)
Pesquisa no Grid por usuario, grupo ou nome e, se encontrar, posiciona no grid
@author Allyson Freitas
@since 12/01/2012
@version 1.0
@return NIL
/*/
//------------------------------------------------------------------------------
Static Function A014PESQ(oDlg,nTipo,cDado,cDoc,lBusca)
Local oModel := FWModelActive()
Local oModelGrid := oModel:GetModel("MATA014_SDW")
Local nCont := 0
Local lAchou := .F.
Local cUsu,cGrupo,cNome,cDocum 
Local cOper := "$"
Local lCod := ".F."
Local cCond := ".F."
Local cCondDoc := ".T."

	If !Empty(cDado) 
		If lBusca
			cOper := "=="
		EndIf
	
		While nCont <= oModelGrid:Length(.T.) .And. !lAchou	
			oModelGrid:GoLine(nCont)
			cUsu := Upper(oModel:GetValue("MATA014_SDW","DW_USER"))
			cGrupo := Upper(oModel:GetValue("MATA014_SDW","DW_GRUPO"))
			cNome := Upper(oModel:GetValue("MATA014_SDW","DW_NOME"))
			cDocum := Upper(oModel:GetValue("MATA014_SDW","DW_DOC"))	
			
			If !Empty(cDoc)
				cCondDoc := "AllTrim('" + cDocum + "') == AllTrim('" + cDoc + "')"
			EndIf 
			
			Do Case
				Case nTipo == 1 // por Usuario
					cCond := " AllTrim('" + cDado +"')" + cOper + "AllTrim('"+ cUsu +"') " + " .And. " + cCondDoc
				Case nTipo == 2 // por Grupo
					cCond := " AllTrim('" + cDado +"')" + cOper + "AllTrim('"+ cGrupo +"') " + " .And. " + cCondDoc
				Case nTipo == 3 // por Nome
					cCond := " AllTrim('" + cDado +"')" + cOper + "AllTrim('"+ cNome +"') " + " .And. " + cCondDoc
			EndCase

			If &(cCond)
				lAchou := .T.
				oDlg:End()
			EndIf
			nCont++
		End
	
		If !lAchou
			Help(" ",1,"A014REGNF") // Registro nao encontrado  
		EndIf
	Else
		Help(" ",1,"A014PESQ") // Selecione usuario/grupo/nome
	EndIf

Return NIL
                                      

//-------------------------------------------------------------------
/*/{Protheus.doc} A014PrdBlq(cCampo)
Controla o bloqueio dos campos DW_PRODUTO e DW_GRPPROD.
Se DW_PRODUTO estiver preenchido, DW_GRPPROD fica bloqueado e vice-versa.
@author Allyson Freitas
@since 12/01/2012
@version 1.0
@return lRet (.T. - desbloqueia | .F. - bloqueia)
/*/
//-------------------------------------------------------------------
Static Function A014PrdBlq(cCampo)
Local lRet := .T.	
Local oModel := FWModelActive()
Local cProd := AllTrim(oModel:GetValue('MATA014_CAB','DW_PRODUTO')) 
Local cGProd := AllTrim(oModel:GetValue('MATA014_CAB','DW_GRPPROD'))
	
	If AllTrim(cCampo) == "DW_PRODUTO" .And. Len(cGProd) != 0
		lRet := .F.
	ElseIf AllTrim(cCampo) == "DW_GRPPROD" .And. Len(cProd) != 0
		lRet := .F.
	EndIf
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} A014IniNom(cUser,cGrupo)
Inicializa o campo virtual DW_NOME.
@author Allyson Freitas
@since 12/01/2012
@version 1.0
@return cNome (Nome do usuario/grupo)
/*/
//-------------------------------------------------------------------
Function A014IniNom(cUser,cGrupo)
Local cNome := ""
Local oModel  := FWModelActive()    
 
	If ValType(oModel) != "U"
		If oModel:GetOperation() != MODEL_OPERATION_INSERT
			If !Empty(cUser)
				cNome := UsrRetName(cUser)
			Else
				cNome := GrpRetName(cGrupo)
			EndIf
		EndIf
	Else
		If !Empty(cUser)
			cNome := UsrRetName(cUser)
		Else
			cNome := GrpRetName(cGrupo)
		EndIf
	EndIf

Return cNome


//-------------------------------------------------------------------
/*/{Protheus.doc} A014VldPrd(cProd)
Validacao de Produto.
@author Allyson Freitas
@since 12/01/2012
@version 1.0
@return lRet (.T. - Valido | .F. - Invalido)
/*/
//-------------------------------------------------------------------
Function A014VldPrd(cProd)
Local lRet := .T.
Local oModel := FWModelActive()

	//Verifica se o Produto existe (caso nao seja "*")
	If AllTrim(cProd) != "*" 
		If !ExistCpo("SB1",cProd)
			lRet := .F.
		EndIf	
	EndIf
	
	//Verifica se ja existe registro gravado com mesmo produto
	If lRet 
		If !ExistChav("SDW",cProd,1)
			lRet := .F.
		Else
			If Alltrim(cProd) == "*"
				oModel:SetValue('MATA014_CAB',"DW_DESC",STR0019) //TODOS
			Else
				oModel:SetValue('MATA014_CAB',"DW_DESC",Posicione("SB1",1,xFilial("SB1")+cProd,"B1_DESC"))
			EndIf	
		EndIf
	EndIf
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} A014VldGrd(cGProd)
Validacao de Grupo de Produto.
@author Allyson Freitas
@since 12/01/2012
@version 1.0
@return lRet (.T. - Valido | .F. - Invalido)
/*/
//-------------------------------------------------------------------
Function A014VldGrd(cGProd)
Local lRet := .T.
Local oModel := FWModelActive()

	//Verifica se o Produto existe (caso nao seja "*")
	If AllTrim(cGProd) != "*" 
		If !ExistCpo("SBM",cGProd)
			lRet := .F.
		EndIf
	EndIf
	
	//Verifica se ja existe registro gravado com mesmo grupo de produto
	If lRet 
		If !ExistChav("SDW",cGProd,3)
			lRet := .F.
		Else
			If Alltrim(cGProd) == "*"
				oModel:SetValue('MATA014_CAB',"DW_DESCGRP",STR0019) //TODOS
			Else
				oModel:SetValue('MATA014_CAB',"DW_DESCGRP",Posicione("SBM",1,xFilial("SBM")+cGProd,"BM_DESC"))
			EndIf	
		EndIf
	EndIf
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} A014IniDPr(cProd)
Inicializa o campo virtual DW_DESC.
@author Allyson Freitas
@since 12/01/2012
@version 1.0
@return cRet (Descricao do Produto)
/*/
//-------------------------------------------------------------------
Function A014IniDPr(cProd)
Local cRet := ""
Local oModel  := FWModelActive()    
 
	If ValType(oModel) != "U"
		If oModel:GetOperation() != MODEL_OPERATION_INSERT
			If AllTrim(cProd) == "*"
				cRet := STR0019 //TODOS
			Else
				cRet := Posicione("SB1",1,xFilial("SB1")+cProd,"B1_DESC")
			EndIf
		EndIf
	Else
		If AllTrim(cProd) == "*"
			cRet := STR0019 //TODOS
		Else
			cRet := Posicione("SB1",1,xFilial("SB1")+cProd,"B1_DESC")
		EndIf
	EndIf
	
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} A014IniDGr(cProd)
Inicializa o campo virtual DW_DESCGRP.
@author Allyson Freitas
@since 12/01/2012
@version 1.0
@return cRet (Descricao do Grupo de Produto)
/*/
//-------------------------------------------------------------------
Function A014IniDGr(cGProd)
Local cRet := ""
Local oModel  := FWModelActive()    
 
	If ValType(oModel) != "U"
		If oModel:GetOperation() != MODEL_OPERATION_INSERT
			If AllTrim(cGProd) == "*"
				cRet := STR0019 //TODOS
			Else
				cRet := Posicione("SBM",1,xFilial("SBM")+cGProd,"BM_DESC")
			EndIf
		EndIF
	Else
		If AllTrim(cGProd) == "*"
			cRet := STR0019 //TODOS
		Else
			cRet := Posicione("SBM",1,xFilial("SBM")+cGProd,"BM_DESC")
		EndIf
	EndIf
	
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A104Tudok(oModel)
Valida Model para concluir com a inclusão
@author Leonardo Quintania
@since 16/08/2012
@version 1.0
@return lRet (Continua com gravação)
/*/
//-------------------------------------------------------------------
Static Function A104TudoOk(oModel)
Local cProd 	:= AllTrim(oModel:GetValue('MATA014_CAB','DW_PRODUTO')) 
Local cGProd 	:= AllTrim(oModel:GetValue('MATA014_CAB','DW_GRPPROD'))
Local lRet 	:= .T.

If Empty(cProd) .And. Empty(cGProd)
	Help(" ",1,"IDENTPROD")		//"É necessario identificar o produto ou grupo de produtos para o qual a permissão é valida. Caso seja para todos, preencher com *. 
	lRet:= .F.
EndIf

Return lRet
