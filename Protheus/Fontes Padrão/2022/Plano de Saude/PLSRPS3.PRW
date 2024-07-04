#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'TOTVS.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

Add Option aRotina Title 'Incluir'    Action 'PLSRPS3z()' Operation 3 Access 0
Add Option aRotina Title 'Visualizar' Action 'VIEWDEF.PLSRPS3' Operation 2 Access 0
Add Option aRotina Title 'Alterar'    Action 'VIEWDEF.PLSRPS3' Operation 4 Access 0
Add Option aRotina Title 'Excluir'    Action 'PLSRPS3EX()' Operation 5 Access 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel // Modelo de dados construído
Local oStrB84:= FWFormStruct(1,'B84' )// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que iráconsiderar

oModel := MPFormModel():New( 'PLSRPS3', , {|oModel| PVLDOKB84(oModel) }, {|oModel| PGRVRPSL84(oModel) } ) // Cria o objeto do Modelo de Dados e insere a funçao de pós-validação

oModel:addFields('MasterB84',/*cOwner*/,oStrB84)  // Adiciona ao modelo um componente de formulário

oStrB84:SetProperty( 'B84_CODIGO' , MODEL_FIELD_INIT , { || BAU->BAU_CODIGO } )
oStrB84:SetProperty( 'B84_CODINT' , MODEL_FIELD_INIT , { || PLSINTPAD() } )
oStrB84:SetProperty( 'B84_CODPRO' , MODEL_FIELD_VALID , { || PLSRPS3y() } )
oStrB84:SetProperty( 'B84_CODLOC' , MODEL_FIELD_INIT , { || BB8->BB8_CODLOC } )
oStrB84:SetProperty( 'B84_LOCAL'  , MODEL_FIELD_INIT , { || BB8->BB8_LOCAL } )
oStrB84:SetProperty( 'B84_CODPRO' , MODEL_FIELD_OBRIGAT , .T. )

oModel:GetModel('MasterB84'):SetDescription( 'vinculos RPS' ) // Adiciona a descrição do Modelo de Dados

Return oModel // Retorna o Modelo de dados


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() // Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado

Local oView  // Interface de visualização construída
Local oModel := FWLoadModel( 'PLSRPS3' ) // Cria as estruturas a serem usadas na View
Local oStrB84:= FWFormStruct(2, 'B84' )
Local aAux := {}

oView := FWFormView():New() // Cria o objeto de View

oView:SetModel(oModel)		// Define qual Modelo de dados será utilizado

oView:AddField('ViewB84' , oStrB84,'MasterB84' ) // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)

oView:CreateHorizontalBox( 'SUPERIOR' , 100 ) // Cria um "box" horizontal para receber cada elemento da view e Associa à Aba Correspondente

oStrB84:SetProperty( 'B84_CODIGO', MVC_VIEW_CANCHANGE, .F.)
oStrB84:SetProperty( 'B84_DESCRI', MVC_VIEW_CANCHANGE, .F.)
oStrB84:SetProperty( 'B84_CODINT', MVC_VIEW_CANCHANGE, .F.)
oStrB84:SetProperty( 'B84_VERSAO', MVC_VIEW_CANCHANGE, .F.)
oStrB84:SetProperty( 'B84_DESSEG', MVC_VIEW_CANCHANGE, .F.)
oStrB84:SetProperty( 'B84_CODSEG', MVC_VIEW_CANCHANGE, .F.)
oStrB84:SetProperty( 'B84_SUSEP' , MVC_VIEW_CANCHANGE, .F.)
oStrB84:SetProperty( 'B84_ENVRPS', MVC_VIEW_CANCHANGE, .F.)

oView:SetOwnerView('ViewB84','SUPERIOR') // Relaciona o identificador (ID) da View com o "box" para exibição

Return oView // Retorna o objeto de View criado


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRPS3z
Validação se será permitida a inclusão da vinculação
@author Oscar Zanin
@since 09/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PLSRPS3z(lAutoma)

Local oExecView
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	//Para fins de automação

If PRPSPERVIN(1)

	oExecView := FWViewExec():New() 		//Criamos o objeto que abre a View
	oExecView:SetTitle("vínculos x Local de atendimento") //Define título da Janela
	oExecView:SetSource('PLSRPS3') 			//Definimos o Model que iremos utilizar, no caso, o Model do fonte PLSA731
	oExecView:SetModal(.F.) 					//View não abre em janela Modal
	oExecView:SetCloseOnOk({|| .T.}) 		//A tela irá fechar ao confirmar o Ok
	oExecView:SetOperation(3) 				//Como sempre haverá um registro, o cadastro abre sempre como alteração
	//oExecView:OpenView(.F.)				 	//Abrimos o cadastro
	iif(!lAutoma, oExecView:OpenView(.F.), '')

EndIf

return 


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRPS3y
Validação se será permitida a inclusão da vinculação
@author Oscar Zanin
@since 09/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PLSRPS3y()

Local lRet 	:= .F.
Local oModel 	:= FwModelActive()

If empTy(oModel:getModel('MasterB84'):getValue("B84_CODPRO"))
	lRet := .T.
Else
	BI3->(dbsetOrder(1))
	If BI3->(MsSeek(xFilial("BI3")+oModel:getModel('MasterB84'):getValue("B84_CODINT")+oModel:getModel('MasterB84'):getValue("B84_CODPRO")))
		lRet := PRPSPERVIN(2)
		If lRet
			oModel:getModel('MasterB84'):SetValue("B84_CODSEG", BI3->BI3_CODSEG)
		EndIf
	EndIf
eNDiF

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PGRVRPSL84
Função de commit do Model. (Tabela B84)
Grava o modelo e verifica se deve gravar as tabelas de geração de RPS, caso
deva gravar, realiza a gravação
@author Oscar Zanin
@since 10/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PGRVRPSL84(oModel)

Local aAlt	:= {}
Local cTpArq	:= ""
Local oB84	:= oModel:getModel("MasterB84")
Local nI	:= 1

If oModel:VldData()
	FWFormCommit(oModel)

	If oModel:getOperation() == 5
		PLSRPS3EX("2")
	elseIf BAU->BAU_GERRPS == "1"

		If oB84:IsFieldUpdated("B84_SUSEP")
			aadd(aAlt, "B84_SUSEP")
		EndIf
		
		If Len(aAlt) > 0
			If BAU->BAU_ENVRPS $ "1,3"
				If oB84:getValue("B84_ENVRPS") $ " ,0"
					cTpArq := "2"
				Else
					cTpArq := "1"
				EndIf
			Elseif BAU->BAU_ENVRPS $ " ,0"
				cTpArq := "0"
			EndIf
			PLSRPSALT(PLSINTPAD(), BAU->(Recno()), BB8->(Recno()), B84->(recno()), aAlt, cTpArq)
		EndIf

		If cTpArq == "1" .AND. BAU->BAU_ENVRPS == "1"
			BAU->(RecLock("BAU", .F.))
				BAU->BAU_ENVRPS := "3"
			BAU->(MsUnLock())
		endIf
		
		PLRP5clr()
	EndIf
else
	MsgAlert("Houve um erro na gravação da operação")
endIf
return .T.

function PLSRPS3EX(cModo,lAutoma)

Local lret := .F.
Local cSql :=  ""
Local aVldRet := {.F.,.F.}
Local aProc	:= {}
Local nN	:= 1
Default cModo := "1" //1 = Validação, 2 = Validação + Processamento
Default lAutoma := .F.

If B84->B84_ENVRPS == "0"
	aVldRet[1] := .T.

	cSql += " Select B5B.R_E_C_N_O_ RECB5B, B4K.R_E_C_N_O_ RECB4K From " + RetSqlName("B5B") + " B5B "
	cSql += " Inner Join " + RetSqlName("B4K") + " B4K "
	cSql += " On "
	cSql += " B4K_FILIAL = '" + xFilial("B4K") + "' AND "
	cSql += " B4K_CODOPE = B5B_CODOPE AND "
	cSql += " B4K_NUMLOT = B5B_NUMLOT AND "
	If cModo == "2"
		cSql += " B4K_STATUS = '0' AND "
	endIf
	cSql += " B4K_TIPARQ <> '3' AND "
	cSql += " B4K.D_E_L_E_T_ = ' ' "
	cSql += " Where "
	cSql += " B5B_FILIAL = '" + xFilial("B5B") + "' AND "
	cSql += " B5B_SEQVIN = " + Alltrim(str(B84->(Recno()))) + " AND "
	cSql += " B5B.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"RPS3EX",.F.,.T.)
	
	If !(RPS3EX->(Eof()))
		While !(RPS3EX->(Eof()))
			B4K->(DbGoto(RPS3EX->RECB4K))
			If B4K->B4K_STATUS == "0"
				aVldRet[2] := .T.
				If cModo == "2"
					AAdd(aProc, {RPS3EX->RECB4K, RPS3EX->RECB5B, B4K->B4K_TIPARQ == "2"})
				endIf
			endIf
			RPS3EX->(DbSkip())
		EndDo
	else
		aVldRet[2] := .T.
	endIf

	RPS3EX->(DbcloseArea())
endIf

lRet := aVldRet[1] .AND. aVldRet[2]

If !lRet
	MsgAlert("Não é possível excluir o vínculo pois o mesmo já foi informado à ANS")
elseif lRet .AND. cModo == '1'
	oExecView := FWViewExec():New() 		//Criamos o objeto que abre a View
	oExecView:SetTitle("vínculos x Local de atendimento") //Define título da Janela
	oExecView:SetSource('PLSRPS3') 			//Definimos o Model que iremos utilizar, no caso, o Model do fonte PLSA731
	oExecView:SetModal(.F.) 					//View não abre em janela Modal
	oExecView:SetCloseOnOk({|| .T.}) 		//A tela irá fechar ao confirmar o Ok
	oExecView:SetOperation(5) 				//Como sempre haverá um registro, o cadastro abre sempre como alteração
	iif(!lAutoma, oExecView:OpenView(.F.), '')
elseIf lret .AND. cModo == '2'
	For nN := 1 To len(aProc)
		B5B->(DbGoTo(aProc[nN][2]))
		B5B->(RecLock("B5B",.F.))
		If aProc[nN][3] //Se for Lote de vinculação, deleta a linha, se não, limpa os campos de vínculo
			B5B->(dbdelete())
		else
			B5B->B5B_REGPLV := ""
			B5B->B5B_CODPLV := ""
			B5B->B5B_SEQVIN := 0
		endIf
		B5B->(MsUnlock())
	next
endIf
return lRet

static function PVLDOKB84(oModel)
Local lRet := .T.
local oDados := oModel:getModel('MasterB84')
Local cCodigo := oDados:getValue("B84_CODIGO")
Local cCodInt := oDados:getValue("B84_CODINT")
Local cCodLoc := oDados:getValue("B84_CODLOC")
Local cLocal  := oDados:getValue("B84_LOCAL")
Local cCodPro := oDados:getValue("B84_CODPRO")
Local cVersao := oDados:getValue("B84_VERSAO")
Local cSusep  := oDados:getValue("B84_SUSEP")
Local aArea := B84->(getArea())
Local nRecno := 0

B84->(dbsetOrder(2))
//B84_FILIAL+B84_CODIGO+B84_CODINT+B84_CODLOC+B84_LOCAL+B84_CODPRO+B84_VERSAO+B84_SUSEP
If oModel:getOperation() ==  MODEL_OPERATION_INSERT
	If B84->(MsSeek(xFilial("B84") + cCodigo + cCodInt + cCodLoc + cLocal + cCodPro + cVersao + cSusep))
		Help(,,"Inclusão não permitida",,"Este vínculo já está cadastrado, não pode ser incluído novamente",1,0)
		lRet := .F.
	endIf
elseIf oModel:getOperation() ==  MODEL_OPERATION_UPDATE
	nRecno := B84->(recno())
	If B84->(MsSeek(xFilial("B84") + cCodigo + cCodInt + cCodLoc + cLocal + cCodPro + cVersao + cSusep)) .AND. nRecno <> B84->(recno())
		Help(,,"Alteração não permitida",,"Este vínculo já está cadastrado, não pode ser incluído novamente",1,0)
		lRet := .F.
	endIf
endIf
RestArea(aArea)

return lRet
