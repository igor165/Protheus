#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "FWBROWSE.CH"
#Include "TECA805.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA805

Cadastro de Checklist
@author filipe.goncalves
@since 21/06/2016
@version P12

@return  nil
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECA805()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("TWC")
oBrowse:SetDescription(STR0001)//'Cadastro de CheckList'
//Legendas
oBrowse:AddLegend("TWC_MSBLQL=='2'", "GREEN", STR0009) //Disponivel
oBrowse:AddLegend("TWC_MSBLQL=='1'", "RED",   STR0008) //Bloqueado
oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para criação do Menu.

@author filipe.goncalves
@since 21/06/2016
@version P12
@return aRotina
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina   := {}
Local aRotInc   := {}
Local aRotAnMe  := {}
Local aUserButt := {}

ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"			OPERATION 1							ACCESS 0	// "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TECA805"	OPERATION MODEL_OPERATION_VIEW		ACCESS 0	// "Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TECA805"	OPERATION MODEL_OPERATION_INSERT	ACCESS 0	// "Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TECA805"	OPERATION MODEL_OPERATION_UPDATE	ACCESS 0	// "Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TECA805"	OPERATION MODEL_OPERATION_DELETE	ACCESS 0	// "Excluir"
ADD OPTION aRotina TITLE STR0010 ACTION "Tc805CkPro()"		OPERATION 6 							ACCESS 0 	// "CheckList x Produto"
ADD OPTION aRotina TITLE STR0014 ACTION "Tc805ProCk()"		OPERATION 6 							ACCESS 0 	// "Produto x CheckList"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@description	Definição do Model
@sample	 		ModelDef()
@param			Nenhum
@return			ExpO: Objeto FwFormModel
@author 		filipe.goncalves
@since 			21/06/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel		:= Nil
Local oStrTWC		:= FWFormStruct(1, "TWC")	// Cabeçalho CheckList
Local oStrTWD 	:= FWFormStruct(1, "TWD")	// Itens CheckList

// Cria o objeto do modelo de dados principal
oModel := MPFormModel():New("TECA805", /*bPreValid*/, /*bPósValid*/, /*bCommit*/, /*bCancel*/)

// Cria a antiga Enchoice do grupo de comunicação
oModel:AddFields("TWCMASTER", /*cOwner*/ , oStrTWC, /*{|oModel, cAction, cCampo, xValor|TC805VldBl(oModel, cAction, cCampo, xValor)}*/)

// Cria a grid das etapas do grupo de comunicação
oModel:AddGrid("TWDDETAIL","TWCMASTER",oStrTWD,/*bPreValidacao*/ ,/*bPosValidacao*/,,, /*bCarga*/)

//Criação dos relacionamentos
oModel:SetRelation("TWDDETAIL", {{"TWD_FILIAL","xFilial('TWD')"}, {"TWD_CODTWC","TWC_CODIGO"}}, TWD->(IndexKey(1)))

//Definição das descrições
oModel:GetModel("TWDDETAIL"):SetDescription(STR0007)

Return(oModel)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@description	Definição da View
@sample	 		ViewDef()
@param			Nenhum
@return			ExpO	Objeto FwFormView
@author 		filipe.goncalves
@since 			21/06/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oView	:= Nil							// Interface de visualização construída
Local oModel	:= ModelDef()					// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oStrTWC	:= FWFormStruct(2, "TWC")	// Cria a estrutura a ser usada na View
Local oStrTWD := FWFormStruct(2, "TWD", {|cCampo| !AllTrim(cCampo)$ "TWD_CODTWC"})

// Cria o objeto de View
oView	:= FWFormView():New()

// Define qual modelo de dados será utilizado
oView:SetModel(oModel)

oView:AddField("VIEW_TWC", oStrTWC, "TWCMASTER")	// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddGrid("VIEW_TWD", oStrTWD, "TWDDETAIL")		// Cria as grids para o modelo

//Define divisão da tela para o cabeçalho e itens
oView:CreateHorizontalBox("CABEC", 20)
oView:CreateHorizontalBox("GRID", 80)

// Relaciona o identificador (ID) da View com o "box" para sua exibição
oView:SetOwnerView("VIEW_TWC", "CABEC")
oView:SetOwnerView("VIEW_TWD", "GRID")

// Campos incrementais
oView:AddIncrementField("VIEW_TWD", "TWD_ITEM")

// Identificação (Nomeação) da VIEW
oView:SetDescription(STR0001) // "CheckList"

Return(oView)

//------------------------------------------------------------------------------
/*/{Protheus.doc} TC805VldBl()
@description	Validação do campo TWC_MSBLQL
@param			Nenhum
@return			lRet 	Lógico (T/F)
@author 		filipe.goncalves
@since 			22/06/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Function TC805VldBl(oMod, cCampo, xValue, xOldValue)
Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel 		:= FwModelActive()
Local oModTWC		:= oModel:GetModel("TWCMASTER")
Local lRet 			:= .T.

If cCampo == "TWC_MSBLQL"
	DbSelectArea("TWE")
	TWE->(DbSetOrder(1))	//TWE_FILIAL+TWE_CODTWC+TWE_CODPRO
	If xValue == "1" .And. TWE->(DbSeek(xFilial("TWE")+ TWC->TWC_CODIGO))
		If !(lRet := (MsgYesNo(STR0012, STR0015)))	//"Deseja realizar o bloqueio do ChackList? " ## "Atenção"
			Help("",1,"TC805VLDNLQ",,STR0013)			//'CheckiList não será bloqueado!'
			oModTWC:LoadValue("TWC_MSBLQL", xOldValue)
		EndIf
	EndIf
EndIf

FWRestRows(aSaveLines)
RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TC805CKPRO()
@description	Associação CheckList x Produto
@param			Nenhum
@return			lRet 	Lógico (T/F)
@author 		filipe.goncalves
@since 			22/06/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Function Tc805CkPro()

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMod805A	:= Nil
Local oModCab		:= Nil
Local cCodTWC		:= TWC->TWC_CODIGO
Local cDescTWC	:= TWC->TWC_DESCRI

DbSelectArea("TWE")
TWE->(DbSetOrder(1))	//TWE_FILIAL+TWE_CODTWC+TWE_CODPRO
TWE->(DbSeek(xFilial("TWE")+ TWC->TWC_CODIGO))

oMod805A := FwLoadModel("TECA805A")
oMod805A:SetOperation(MODEL_OPERATION_UPDATE)
oMod805A:Activate()
oModCab := oMod805A:GetModel("CABMASTER")

oModCab:SetValue("TWE_CODTWC", cCodTWC)
oModCab:SetValue("TWE_DESTWC", cDescTWC)

FWExecView (STR0011, "TECA805A", MODEL_OPERATION_UPDATE ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ ,  /*bCancel*/,,, oMod805A)

oMod805A:Deactivate()
oMod805A := Nil

FWRestRows(aSaveLines)
RestArea(aArea)
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} TC805CKPRO()
@description	Associação Produto X CheckList
@param			Nenhum
@return			lRet 	Lógico (T/F)
@author 		filipe.goncalves
@since 			23/06/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Function Tc805ProCk(cCdProd, cCodChe)

Local aArea		:= GetArea()
Local nTamCTWC	:= TamSx3("TWE_CODTWC")[1]
Local nTamDTWC	:= TamSx3("TWE_DESTWC")[1]
Local nTamCPROD	:= TamSx3("TWE_CODPRO")[1]
Local nTamDPROD	:= TamSx3("TWE_DESPRO")[1]
Local cCodPro	:= Space(nTamCPROD)
Local cDescPro	:= Space(nTamDPROD)
Local cCheck	:= Space(nTamCTWC)
Local cDescCk	:= Space(nTamDTWC)
Local lRet		:= .T.
Local oDlg

If !ISBlind()
	DEFINE DIALOG oDlg TITLE STR0014 FROM 00,00 TO 170,450 PIXEL

	@ 010,010 SAY STR0016    OF oDlg SIZE 200,09             PIXEL 	//"Cód.Produto"
	@ 010,050 MsGet cCodPro  OF oDlg SIZE 120,10 F3 "SB5TFI" PIXEL;
          PICTURE "@!";
          VALID At805Valid("CODPRO", cCodPro, cCheck) .AND.;
                At805Gat("TWE_CODPRO", cCodPro, @cDescPro, @cDescCk, @cCheck)

	@ 025,010 SAY STR0017    OF oDlg SIZE 200,09             PIXEL 	//"Descr.Produto"
	@ 025,050 MsGet cDescPro OF oDlg SIZE 170,10             PIXEL;
          PICTURE "@!" WHEN .F.

	@ 040,010 SAY STR0018    OF oDlg SIZE 200,09             PIXEL 	//"Cód.Checklist"
	@ 040,050 MsGet cCheck   OF oDlg SIZE 120,10 F3 "TWC"    PIXEL;
          PICTURE "@!" WHEN ! Empty(cCodPro);
          VALID At805Valid("CODTWC", cCodPro, cCheck) .AND.;
                At805Gat("TWE_CODTWC", cCodPro, cDescPro, @cDescCk, cCheck)

	@ 055,010 SAY STR0019    OF oDlg SIZE 200,09             PIXEL 	//"Descr.Checklist"
	@ 055,050 MsGet cDescCk  OF oDlg SIZE 170,10             PIXEL;
          PICTURE "@!" WHEN .F.
		    								    																 							 							 				 					 										 																	
	oDlg:Refresh()
	DEFINE SBUTTON oBut2 FROM 070,165 TYPE 1 ACTION (If(At805Valid("OK", cCodPro, cCheck),;
                                                    Eval({|| At805Grav(cCodPro, cCheck), oDlg:End()}),;
                                                    Eval({|| MsgAlert(STR0023, STR0015), oDlg:End()})));	//"Processamento não realizado"##"Atenção"
                                                    ENABLE of oDlg
	DEFINE SBUTTON oBut2 FROM 070,195 TYPE 2 ACTION oDlg:End()                                                                                                                                    ENABLE of oDlg

	ACTIVATE DIALOG oDlg CENTERED

Else
	lRet := At805Valid("CODPRO",cCdProd) .AND. At805Valid("CODTWC",, cCodChe)
	If lRet
		At805Grav(cCdProd, cCodChe)
	EndIf
EndIf
RestArea(aArea)
Return Nil


//------------------------------------------------------------------------------
/*/{Protheus.doc} At805Valid()
@description	Função para validar as informações
@param			Nenhum
@return		lRet 	Lógico (T/F)
@author 		filipe.goncalves
@since 			23/06/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function At805Valid(cTpValid, cCodPro, cCheck)

Local lRet 		:= .T.

Default cTpValid	:= "OK"
Default cCodPro	:= Space(TamSx3("TWE_CODPRO")[1])
Default cCheck	:= Space(TamSx3("TWE_CODTWC")[1])

Do Case

	Case	cTpValid == "CODPRO"

		If	Empty(cCodPro)
			Help("",1,"At805Valid",,STR0021,1,0)	//"Produto não informado"
			lRet	:= .F.
		Else
			lRet	:= ExistCpo("SB5",cCodPro,1)
		EndIf

	Case	cTpValid == "CODTWC"

		lRet	:= Vazio(cCheck) .OR. ExistCpo("TWC",cCheck,1)

	Case	cTpValid == "OK"

		If !(Empty(cCodPro)) .AND. Empty(cCheck)
			TWE->(DbSetOrder(2))	//TWE_FILIAL+TWE_CODPRO+TWE_CODTWC
			If	(lRet	:= TWE->(DbSeek(xFilial("TWE")+cCodPro))) 
				lRet	:= MsgNoYes(STR0020)	//"Este produto possui vinculo com um checklist. Confirma a exclusão desse vínculo?"
			Else
				Help("",1,"At805Valid",,STR0022,1,0)	//"Produto não possui vínculo com um checklist para que seja processada a exclusão desse vínculo."
			EndIf
		EndIf

EndCase

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At805Gat()
@description	Função para gatilhar as informações
@param			Nenhum
@return		lRet 	Lógico (T/F)
@author 		filipe.goncalves
@since 			23/06/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function At805Gat(cCampo, cCodPro, cDescPro, cDescCk, cCheck) 
Local aArea		:= GetArea()
Local nTamCTWC	:= TamSx3("TWE_CODTWC")[1]
Local nTamDTWC	:= TamSx3("TWE_DESTWC")[1]
Local lRet 		:= .T.

Default cCheck	:= Space(nTamCTWC)
Default cDescCk	:= Space(nTamDTWC)

If cCampo == "TWE_CODPRO"
	cDescPro	:= Posicione("SB5",1,xFilial("SB5")+cCodPro,"B5_CEME")
	DbSelectArea("TWE")
	TWE->(DbSetOrder(2))//TWE_FILIAL+TWE_CODPRO+TWE_CODTWC
	If TWE->(DbSeek(xFilial("TWE")+ cCodPro))
		cCheck		:= TWE->TWE_CODTWC
		cDescCk	:= Posicione("TWC",1,xFilial("TWC")+cCheck,"TWC_DESCRI")
	Else
		cCheck		:= Space(nTamCTWC)
		cDescCk	:= Space(nTamDTWC)
	EndIf
ElseIf cCampo == "TWE_CODTWC"
	If	! Empty(cCheck)
		cDescCk	:= Posicione("TWC",1,xFilial("TWC")+cCheck,"TWC_DESCRI")
	Else
		cDescCk	:= Space(nTamDTWC)
	EndIf
EndIf

RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At805Grav()
@description	Função para fazer a gravação das informações
@param			Nenhum
@return			nil 
@author 		filipe.goncalves
@since 			23/06/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Function At805Grav(cCodPro, cCheck) 

Local aArea		:= GetArea() 
Local oMod805A	:= Nil
Local oModCab		:= Nil 
Local oModGri		:= Nil
Local lRet 		:= .T.

Default cCodPro	:= Space(TamSx3("TWE_CODPRO")[1])
Default cCheck	:= Space(TamSx3("TWE_CODTWC")[1])

If	!(Empty(cCodPro))
	DbSelectArea("TWE")
	TWE->(DbSetOrder(2))//TWE_FILIAL+TWE_CODPRO+TWE_CODTWC
	IF (TWE->(DbSeek(xFilial("TWE") + cCodPro)))
		If cCheck <> TWE->TWE_CODTWC .And. !(Empty(cCheck))
			RecLock("TWE",.F.)
			TWE->TWE_CODTWC	:= cCheck
			TWE->TWE_CODTWE	:= cCheck
			TWE->(MsUnLock())
		ElseIf Empty(cCheck)
			RecLock("TWE",.F.)
			TWE->(dbDelete())
			TWE->(MsUnLock())
		EndIf
	Else
		oMod805A	:= FwLoadModel("TECA805A")
		oMod805A:SetOperation(MODEL_OPERATION_UPDATE)
		oMod805A:Activate()
		oModCab	:= oMod805A:GetModel("CABMASTER")
		oModGri	:= oMod805A:GetModel("GRIDETAIL")
		oModCab:SetValue("TWE_CODTWC", cCheck)
		oModGri:SetValue("TWE_CODPRO", cCodPro)
		oModGri:SetValue("TWE_CODTWE", cCheck)
		If oMod805A:VldData()
			oMod805A:CommitData()
		EndIf
		oMod805A:Deactivate()
		oMod805A	:= Nil
	EndIf
EndIf

RestArea(aArea)
Return Nil