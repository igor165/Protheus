#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//Static criada para devolver o valor para a cTipo do Mata103
Static c103Tipo := DCL013Tipo()

Static Function Dcl013Tipo()
Local cRet := IIF(Type("cTipo") == "C", cTipo, "")
Return cRet

//------------------------------------------------------
/*/{Protheus.doc}	Itens Documento de Entrada DCL / DCL-EST
@author jose.eulalio
@version P12
@since 20/02/2017
/*/
//------------------------------------------------------
Function DCLEA013()

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

If SuperGetMv("MV_DCLNEW",.F.,.F.)
	dbSelectArea("DH4")
	DH4->(dbSetOrder(1)) //DH4_FILIAL+DH4_DOC+DH4_SERIE+DH4_FORNEC+DH4_LOJA+DH4_ITEM
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("DH4")
	oBrowse:SetMenuDef("DCLEA013")
	oBrowse:SetDescription("Itens Documento de Entrada DCL")
	
	oBrowse:Activate()
EndIf
Return Nil

//-----------------------------------------------------
/*/{Protheus.doc}Modelo de Dados
@author jose.eulalio
@version P12
@since 20/02/2017
/*/
//------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStruCab := FWFormStruct(1,"DH4",{|cCampo| AllTrim(cCampo) $ "DH4_DOC|DH4_SERIE|DH4_FORNEC|DH4_LOJA"}) //Estrutura Cabecalho 
Local oStruDH4 := FWFormStruct(1,"DH4",{|cCampo| !AllTrim(cCampo) $ "DH4_DOC|DH4_SERIE|DH4_FORNEC|DH4_LOJA"})//Estrutura Itens

oModel := MPFormModel():New("DCEA013", /*bPreValidacao*/,{|oModel|EA013PosValid(oModel)}/*bPosValidacao*/,{|oModel|EA013Commit(oModel)}/*bCommit*/,{|oModel|EA013Cancel(oModel)}/*bCancel*/)
oModel:AddFields("DH4MASTER",/*cOwner*/,oStruCab,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:AddGrid("DH4DETAIL","DH4MASTER",oStruDH4,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:SetDescription("Itens Documento de Entrada DCL")
oModel:SetPrimaryKey( {} ) //Obrigatorio setar a chave primaria (mesmo que vazia)
oModel:SetRelation("DH4DETAIL",{{"DH4_FILIAL",'xFilial("DH4")'},{"DH4_DOC","DH4_DOC"},{"DH4_SERIE","DH4_SERIE"},{"DH4_FORNEC","DH4_FORNEC"},{"DH4_LOJA","DH4_LOJA"}},DH4->(IndexKey(1)))
oModel:SetActivate({|oModel| A013Active(oModel )})

Return oModel

//-----------------------------------------------------
/*/{Protheus.doc} - View do Cadastro
@author jose.eulalio
@version P12
@since 20/02/2017
/*/
//------------------------------------------------------
Static Function ViewDef()
Local oModel		:= FWLoadModel("DCLEA013")
Local oStruCab	:= FWFormStruct(2,"DH4",{|cCampo| AllTrim(cCampo) $ "DH4_DOC|DH4_SERIE|DH4_FORNEC|DH4_LOJA"}) //Estrutura Cabecalho 
Local oStruDH4	:= FWFormStruct(2,"DH4",{|cCampo| !AllTrim(cCampo) $ "DH4_DOC|DH4_SERIE|DH4_FORNEC|DH4_LOJA"})//Estrutura Itens
Local oView		:= FWFormView():New()

oView:SetModel(oModel)

//	Insere os componentes na view
oView:AddField("MASTER_DH4",oStruCab,"DH4MASTER")   //Cabecalho da matriz de abastecimento
oView:AddGrid("DETAILS_DH4",oStruDH4,"DH4DETAIL")	  //Itens da matriz de abastecimento

//	Cria os Box's
oView:CreateHorizontalBox("CABEC",20)
oView:CreateHorizontalBox("GRID",80)

//	Associa os componentes
oView:SetOwnerView("MASTER_DH4","CABEC")
oView:SetOwnerView("DETAILS_DH4","GRID")


oView:SetAfterViewActivate({|oView|oView:Refresh()}) 

Return oView


//-----------------------------------------------------
/*/{Protheus.doc}	Menu de opcoes
@author jose.eulalio
@version P12
@since 21/02/2014
/*/
//------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE "Visualizar"  ACTION "VIEWDEF.DCLEA013" OPERATION MODEL_OPERATION_VIEW 	ACCESS 0
ADD OPTION aRotina TITLE "Incluir"     ACTION "VIEWDEF.DCLEA013" OPERATION MODEL_OPERATION_INSERT ACCESS 0
ADD OPTION aRotina TITLE "Alterar"     ACTION "VIEWDEF.DCLEA013" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
ADD OPTION aRotina TITLE "Excluir"     ACTION "VIEWDEF.DCLEA013" OPERATION MODEL_OPERATION_DELETE ACCESS 3

Return aRotina

//-----------------------------------------------------
/*/{Protheus.doc}DCLEA013View
Chamada da view conforme o que já foi criado no MATA103
@author jose.eulalio
@version P12
@since 21/02/2014
/*/
//------------------------------------------------------
Function DCLEA013View(aCols,aHeader,lVisualiza,lConsMedic,aHeadSDE,aColsSDE,aHeadSEV,aColsSEV,lTxNeg,nTaxaMoeda,l103Inclui)
Local aAreaDH4	:= DH4->(GetArea())
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEM"})
Local nPosProd	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})
Local cItem		:= aCols[1][nPosItem]
Local cProd		:= aCols[1][nPosProd]
Local lRet			:= .T.
Local oModel		:= FWLoadModel("DCLEA013")
Local oView		:= FWLoadView("DCLEA013")
Local oExecView

Default lVisualiza := .F.

//Seta Static que carrega o modelo
If oModelDcl == NIL
	oModelDcl := FWLoadModel("DCLEA013")
End If

EA013LmpAt()

If lVisualiza
	lRet := .F.
	DH4->(DbSetOrder(1))
	If DH4->(DbSeek(xFilial("DH4") + cNFiscal + cSerie + cA100For + cLoja))//DH4_FILIAL+DH4_DOC+DH4_SERIE+DH4_FORNEC+DH4_LOJA+DH4_ITEM
		FWExecView ('Complemento DCL', "DCLEA013", MODEL_OPERATION_VIEW,/*oDlg*/ ,{||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , {||.T.}/*bCancel*/ )
		
	Else
		Help(" ",1,"NODCLDOC",,"Não existe Complemento DCL para este documento",1,0,,,,,,{""})		
	EndIF
EndIf

//Caso seja Formulário Próprio (cFormul == "S") o número do Documento de Entrada será gravado no Complemento DCL (DH4) através do Ponto de Entrada DCLSD1100I no momento da gravação (a103Grava)
If lRet .And. cFormul == "N"
	If Empty(cNFiscal) .Or. Empty(cSerie)
		lRet := .F.
		Help(" ",1,"NODCLDOC",,"O Número do Documento ou a Série não estão preenchidos",1,0,,,,,,{"Prencha todos os campos obrigatórios do cabeçalho"})
	EndIf	
EndIf

If	lRet .And. Empty(cA100For) .Or. Empty(cLoja)
	lRet := .F.
	Help(" ",1,"NODCLFOR",,"O Código do Fornecedor ou Loja não estão preenchidos",1,0,,,,,,{"Prencha todos os campos obrigatórios do cabeçalho"})
EndIf

If lRet 
	If !(Empty(cProd))
	
		DH4->(DbSetOrder(1))
	
		If DH4->(DbSeek(xFilial("DH4") + cNFiscal + cSerie + cA100For + cLoja + cItem ))//DH4_FILIAL+DH4_DOC+DH4_SERIE+DH4_FORNEC+DH4_LOJA+DH4_ITEM
						
			If !oModelDcl:lActivate
				oModelDcl:SetOperation(MODEL_OPERATION_UPDATE)
				oModelDcl:Activate()
			EndIf
			
			oView:oViewOwner := FWLoadView("DCLEA013")
			oExecView := FWViewExec():New()
			oExecView:SetView(oView)
			oExecView:setTitle("Complemento DCL")
			oExecView:SetModel(oModelDcl)
			oExecView:setModal(.F.)  
			oExecView:setOperation(MODEL_OPERATION_UPDATE)
			oExecView:SetCloseOnOk({|| .t.})
			oExecView:openView(.F.)
		Else
			If !oModelDcl:lActivate				
				oModelDcl:SetOperation(MODEL_OPERATION_INSERT)
				oModelDcl:Activate()
			Else
				Ea013Carga(oModelDcl)
			EndIf			
			oView:oViewOwner := FWLoadView("DCLEA013")
			oExecView := FWViewExec():New()
			oExecView:SetView(oView)
			oExecView:setTitle("Complemento DCL")
			oExecView:SetModel(oModelDcl)
			oExecView:setModal(.F.)
			oExecView:setOperation(MODEL_OPERATION_INSERT)
			oExecView:SetCloseOnOk({|| .t.})
			oExecView:openView(.F.)
		EndIf
		
		RestArea(aAreaDH4)
		
	Else
	
		Help(" ",1,"NODCLREGIST",,"Não existem itens preenchidos no documento",1,0,,,,,,{"Prencha algum item primeiro para atualizar os complementos DCL"})
	
	EndIf
	
EndIf

EA013RetAt(lConsMedic,aHeadSDE,aColsSDE,aHeadSEV,aColsSEV,lTxNeg,nTaxaMoeda,l103Inclui)

Return

//-----------------------------------------------------
/*/{Protheus.doc}A013Active
Activate do modelo
@author jose.eulalio
@param oModel
@return aCarga
@version P12
@since 23/02/2014
/*/
//------------------------------------------------------
Static Function A013Active(oModel)
Local lRet			:= .T.
Local oModMaster	:= oModel:GetModel("DH4MASTER")
Local oModDetail	:= oModel:GetModel("DH4DETAIL")
Local nOper		:= oModel:GetOperation() 
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEM"})
Local nPosProd	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})
Local nX			:= 0
Local nLinhas		:= Len(aCols)	
Local cItem		:= ""
Local cProd		:= ""

//Retira o Obrigatório para atender ao Formulário Próprio
oModMaster:GetStruct():setProperty('DH4_DOC'		,MODEL_FIELD_OBRIGAT,.F.)
oModMaster:GetStruct():setProperty('DH4_SERIE'	,MODEL_FIELD_OBRIGAT,.F.)

//Libera os campos para setar o valor 
oModMaster:GetStruct():setProperty('DH4_DOC'		,MODEL_FIELD_WHEN,{||.T.})
oModMaster:GetStruct():setProperty('DH4_SERIE'	,MODEL_FIELD_WHEN,{||.T.})
oModMaster:GetStruct():setProperty('DH4_FORNEC'	,MODEL_FIELD_WHEN,{||.T.})
oModMaster:GetStruct():setProperty('DH4_LOJA'		,MODEL_FIELD_WHEN,{||.T.})
oModDetail:GetStruct():setProperty('DH4_ITEM'		,MODEL_FIELD_WHEN,{||.T.})
oModDetail:GetStruct():setProperty('DH4_CODPRO'	,MODEL_FIELD_WHEN,{||.T.})

//Atualiza os valores dos campos
If nOper == MODEL_OPERATION_INSERT
	//Cabeçalho
	oModMaster:LoadValue("DH4_DOC"		,cNFiscal)
	oModMaster:LoadValue("DH4_SERIE"	,cSerie)
	oModMaster:LoadValue("DH4_FORNEC"	,cA100For)
	oModMaster:LoadValue("DH4_LOJA"		,cLoja)
	//Itens
	For nX := 1 To nLinhas
		If nX <> 1
			oModDetail:AddLine()
		EndIf
		cItem	:= aCols[nX][nPosItem]
		cProd	:= aCols[nX][nPosProd]
		oModDetail:LoadValue("DH4_ITEM"		,cItem)
		oModDetail:LoadValue("DH4_CODPRO"	,cProd)
		If aCols[nX,Len(aHeader)+1]
			oModDetail:SetNoDeleteLine(.F.)
			oModDetail:DeleteLine()
			oModDetail:SetNoDeleteLine(.T.)
		EndIf
	Next nX
	oModDetail:GoLine(1)
	oModDetail:SetNoDeleteLine(.T.)
	oModDetail:SetNoInsertLine(.T.)
ElseIf nOper == MODEL_OPERATION_UPDATE
	//Percorre a Grid do Doc.Entrada atualizando os itens do Compl.DCL
	For nX := 1 To nLinhas
		cItem	:= aCols[nX][nPosItem]
		cProd	:= aCols[nX][nPosProd]
		//Atualiza os itens existentes a adiciona caso tenha mais linhas de grid do que no modelo
		If nX <= oModDetail:Length() 
			oModDetail:GoLine(nX)
			If !(aCols[nX,Len(aHeader)+1])
				If cProd <> oModDetail:GetValue("DH4_CODPRO")
					oModDetail:LoadValue("DH4_ITEM"		,cItem)
					oModDetail:LoadValue("DH4_CODPRO"	,cProd)
				EndIf
			Else
				oModDetail:SetNoDeleteLine(.F.)
				oModDetail:DeleteLine()
				oModDetail:SetNoDeleteLine(.T.)
			EndIf
		Else
			oModDetail:AddLine()
			cItem	:= aCols[nX][nPosItem]
			oModDetail:LoadValue("DH4_ITEM"		,cItem)
			oModDetail:LoadValue("DH4_CODPRO"	,cProd)
		EndIf
	Next nX
	//Caso tenha mais linhas no modelo do que na Grid, deleta as linhas do modelo
	If oModDetail:Length() > nLinhas
		 For nX := (nLinhas + 1) To oModDetail:Length()
		 	oModDetail:GoLine(nLinhas + 1)
		 	oModDetail:SetNoDeleteLine(.F.)
		 	oModDetail:DeleteLine()
		 	oModDetail:SetNoDeleteLine(.T.)
		 Next nX 
	EndIf
	oModDetail:GoLine(1)
	oModDetail:SetNoDeleteLine(.T.)
	oModDetail:SetNoInsertLine(.T.)
EndIf

//Bloquei novamente os campos
oModMaster:GetStruct():setProperty('DH4_DOC'		,MODEL_FIELD_WHEN,{||.F.})
oModMaster:GetStruct():setProperty('DH4_SERIE'	,MODEL_FIELD_WHEN,{||.F.})
oModMaster:GetStruct():setProperty('DH4_FORNEC'	,MODEL_FIELD_WHEN,{||.F.})
oModMaster:GetStruct():setProperty('DH4_LOJA'		,MODEL_FIELD_WHEN,{||.F.})
oModDetail:GetStruct():setProperty('DH4_ITEM'		,MODEL_FIELD_WHEN,{||.F.})
oModDetail:GetStruct():setProperty('DH4_CODPRO'	,MODEL_FIELD_WHEN,{||.F.})

Return lRet

//-----------------------------------------------------
/*/{Protheus.doc}EA013PosValid
Activate do modelo
@author jose.eulalio
@param oModel
@return lRet
@version P12
@since 23/02/2014
/*/
//------------------------------------------------------
Function EA013PosValid(oModel,lDclNew)
Local lRet			:= .T.
Local oModDetail
Local nLinAtu
Local nX
Local nOpcDcl

Default lDclNew	:= .T.

If lDclNew

	If oModel <> NIL

		oModDetail	:= oModel:GetModel("DH4DETAIL")
		nLinAtu	:= oModDetail:GetLine()
		nOpcDcl	:= oModel:GetOperation()
		
		//Verifica se os itens da NF estão iguais ao complemento
		If nOpcDcl == MODEL_OPERATION_INSERT .Or. nOpcDcl == MODEL_OPERATION_UPDATE
			
			Ea013Carga(oModel)
	
			For nX := 1 To oModDetail:Length()
				oModDetail:GoLine(nX)
				If !oModDetail:IsDeleted() .And. Empty(oModDetail:GetValue("DH4_MODANP"))
					Help(" ",1,"NOMODALANP",,"Existem campos obrigatórios não preenchidos",1,0,,,,,,{"Verifique o campo Modal ANP no Compl. DCL Item " + oModDetail:GetValue("DH4_ITEM") })
					lRet := .F.
					Exit
				EndIf
			Next nX
			oModDetail:GoLine(nLinAtu)
			
		EndIf
	
	EndIf
	
EndIf

Return lRet

//-----------------------------------------------------
/*/{Protheus.doc}DCLA013Del
Rotina automatica para deletar
@author jose.eulalio
@return lRet
@version P12
@since 24/02/2014
/*/
//------------------------------------------------------
Function DCLA013Del()
Local lRet			:= .T.
Local oModel

DH4->(DbSetOrder(1))

If DH4->(DbSeek(xFilial("DH4") + cNFiscal + cSerie + cA100For + cLoja))
	oModel := FwLoadModel("DCLEA013")
	oModel:SetOperation(MODEL_OPERATION_DELETE)  
	oModel:Activate()
	oModel:CommitData()
	oModel:DeActivate()
EndIf

Return lRet

//-----------------------------------------------------
/*/{Protheus.doc}EA013Commit
Commit do modelo
@author jose.eulalio
@param oModel
@return lRet
@version P12
@since 23/02/2014
/*/
//------------------------------------------------------
Static Function EA013Commit(oModel)
Local lRet			:= .T.

lRet := FwFormCommit(oModel)

//Devolve o valor para a variável cTipo do Mata103
If Valtype(cTipo) == "C"
	cTipo := c103Tipo
EndIf 

Return lRet

//-----------------------------------------------------
/*/{Protheus.doc}EA013Cancel
//Devolve o valor para a variável cTipo do Mata103
@author jose.eulalio
@param oModel
@return lRet
@version P12
@since 23/02/2014
/*/
//------------------------------------------------------
Static Function EA013Cancel(oModel)
Local lRet			:= .T.

//Devolve o valor para a variável cTipo do Mata103
If Valtype(cTipo) == "C"
	cTipo := c103Tipo
EndIf  

Return lRet

//-----------------------------------------------------
/*/{Protheus.doc}EA013LmpAt
Limpa atalhos do MATA103
@author jose.eulalio
@version P12
@since 12/04/2018
/*/
//------------------------------------------------------
Static Function EA013LmpAt()
	Set Key VK_F4 TO
	Set Key VK_F5 TO 
	Set Key VK_F6 TO 
	Set Key VK_F7 TO 
	Set Key VK_F8 TO 
	Set Key VK_F9 TO  
Return

//-----------------------------------------------------
/*/{Protheus.doc}EA013LmpAt
Retorna atalhos do MATA103
@author jose.eulalio
@version P12
@since 12/04/2018
/*/
//------------------------------------------------------
Static Function EA013RetAt(lConsMedic,aHeadSDE,aColsSDE,aHeadSEV,aColsSEV,lTxNeg,nTaxaMoeda,l103Inclui)
	SetKey( VK_F4 , { || A103F4() } )
	SetKey( VK_F5 , { || A103ForF4( NIL, NIL, lNfMedic, lConsMedic, aHeadSDE, @aColsSDE, aHeadSEV, aColsSEV, @lTxNeg, @nTaxaMoeda ),aBackColsSDE:=ACLONE(aColsSDE) } )
	SetKey( VK_F6 , { || A103ItemPC( NIL,NIL,NIL,lNfMedic,lConsMedic,aHeadSDE,@aColsSDE,,@lTxNeg, @nTaxaMoeda),aBackColsSDE:=ACLONE(aColsSDE) } )
	SetKey( VK_F7 , { || A103NFORI() } )
	SetKey( VK_F8 , { || A103LoteF4() } )
	SetKey( VK_F9 , { |lValidX3| NfeRatCC(aHeadSDE,aColsSDE,l103Inclui.Or.l103Class,lValidX3),aBackColsSDE:=ACLONE(aColsSDE)})
Return

//-----------------------------------------------------
/*/{Protheus.doc}Ea013Carga
Carga para atualizar os itens do complemento DCL
@author jose.eulalio
@version P12
@since 12/04/2018
/*/
//------------------------------------------------------
Static Function Ea013Carga(oModelDcl)

Local oModDetail	:= oModelDcl:GetModel("DH4DETAIL")
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEM"})
Local nPosProd	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})
Local nX			:= 0
Local nLinhas		:= Len(aCols)	
Local cItem		:= ""
Local cProd		:= ""

//Percorre a Grid do Doc.Entrada atualizando os itens do Compl.DCL
For nX := 1 To nLinhas
	cItem	:= aCols[nX][nPosItem]
	cProd	:= aCols[nX][nPosProd]
	//Atualiza os itens existentes a adiciona caso tenha mais linhas de grid do que no modelo
	If nX <= oModDetail:Length() 
		oModDetail:GoLine(nX)
		If !(aCols[nX,Len(aHeader)+1])
		
			If oModDetail:IsDeleted()
				oModDetail:SetNoDeleteLine(.F.)
				oModDetail:UnDeleteLine()
				oModDetail:SetNoDeleteLine(.T.)
			EndIf
		
			If cProd <> oModDetail:GetValue("DH4_CODPRO")
				oModDetail:LoadValue("DH4_ITEM"		,cItem)
				oModDetail:LoadValue("DH4_CODPRO"	,cProd)
				oModDetail:LoadValue("DH4_MODANP"	,"")
			EndIf
		Else
			oModDetail:SetNoDeleteLine(.F.)
			oModDetail:DeleteLine()
			oModDetail:SetNoDeleteLine(.T.)
		EndIf
	Else
		oModDetail:SetNoInsertLine(.F.)
		oModDetail:AddLine()
		cItem	:= aCols[nX][nPosItem]
		oModDetail:LoadValue("DH4_ITEM"		,cItem)
		oModDetail:LoadValue("DH4_CODPRO"	,cProd)
		oModDetail:SetNoInsertLine(.T.)
	EndIf
Next nX
//Caso tenha mais linhas no modelo do que na Grid, deleta as linhas do modelo
If oModDetail:Length() > nLinhas
	oModDetail:SetNoDeleteLine(.F.)
	 For nX := (nLinhas + 1) To oModDetail:Length()
	 	oModDetail:GoLine(nLinhas + 1)
	 	oModDetail:DeleteLine()
	 Next nX 
	 oModDetail:SetNoDeleteLine(.T.)
EndIf
oModDetail:GoLine(1)

Return




