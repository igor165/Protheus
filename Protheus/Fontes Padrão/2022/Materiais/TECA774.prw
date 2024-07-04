#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA774.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA774
@description	Grupo de comunicação
@sample	 	TECA774()
@param			Nenhum
@return		NIL
@author		Alexandre da Costa (a.costa)
@since			23/05/2016
@version		P12   
/*/
//------------------------------------------------------------------------------
Function TECA774()
Local	oMBrowse	:= FWmBrowse():New()
Local	nTamX5Chav	:= TamSX3("X5_CHAVE")[1]
Local	nX			:= 0
Local	nPos		:= 0
Local	cFilSX5	:= xFilial("SX5")

oMBrowse:SetAlias("TWJ")			// "TWJ"-Grupos de comunicação
oMBrowse:SetDescription(STR0001)	// "Grupos de comunicação"
oMBrowse:Activate()

Return	NIL

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@description	Define o menu funcional.
@sample	 	MenuDef()
@param			Nenhum
@return		ExpA: Opções da Rotina.
@author		Alexandre da Costa (a.costa)
@since			23/05/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()    

Local	aRotina	:= {}

ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"         OPERATION 1                      ACCESS 0	// "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TECA774" OPERATION MODEL_OPERATION_VIEW   ACCESS 0	// "Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TECA774" OPERATION MODEL_OPERATION_INSERT ACCESS 0	// "Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TECA774" OPERATION MODEL_OPERATION_UPDATE ACCESS 0	// "Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TECA774" OPERATION MODEL_OPERATION_DELETE ACCESS 0	// "Excluir"
Return(aRotina)


//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@description	Definição do Model
@sample	 	ModelDef()
@param			Nenhum
@return		ExpO: Objeto FwFormModel
@author		Alexandre da Costa (a.costa)
@since			23/05/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local	oModel		:= Nil
Local	oStrTWJ	:= FWFormStruct(1, "TWJ")	// TWJ - Grupos de comunicação
Local	oStrTWK	:= FWFormStruct(1, "TWK")	// TWK - Etapas dos grupos de comunicação
Local	oStrTWL	:= FWFormStruct(1, "TWL")	// TWK - Usuários das etapas dos grupos de comunicação
Local	aTrigger	:= {}

oModel := MPFormModel():New("TECA774", /*bPreValid*/, {|oModel| At774TdOk(oModel)}, /*bCommit*/, /*bCancel*/)											// Cria o objeto do modelo de dados principal

oModel:AddFields("TWJMASTER", /*cOwner*/ , oStrTWJ)																							// Cria a antiga Enchoice do grupo de comunicação
oModel:AddGrid("TWKDETAIL", "TWJMASTER", oStrTWK, {|oModTWK, nLine, cAcao, cCampo| PrLinOkTWK(oModTWK, nLine, cAcao, cCampo)} /*bPreValidacao*/,/*bPosValidacao*/,,, /*bCarga*/) // Cria a grid das etapas do grupo de comunicação
oModel:AddGrid("TWLDETAIL", "TWKDETAIL", oStrTWL)																								// Cria a grid dos usuários das etapas dos grupos de comunicação 

// Configura os relacionamentos entre os elementos do modelo
oModel:SetRelation("TWKDETAIL", {{"TWK_FILIAL","xFilial('TWK')"}, {"TWK_CODTWJ","TWJ_CODIGO"}}, TWK->(IndexKey(2)))
oModel:SetRelation("TWLDETAIL", {{"TWL_FILIAL","xFilial('TWL')"}, {"TWL_CODTWJ","TWJ_CODIGO"}, {"TWL_CODTWK","TWK_CODIGO"}}, TWL->(IndexKey(1)))

// Nomeia os grids do modelo
oModel:GetModel("TWKDETAIL"):SetDescription(STR0007)		// "Etapas"
oModel:GetModel("TWLDETAIL"):SetDescription(STR0008)		// "Usuários"

// Verificação de linhas únicas em cada grid
oModel:GetModel("TWKDETAIL"):SetUniqueLine({"TWK_CODIGO"})	// Não podem repetir etapas no mesmo grupo de comunicação
oModel:GetModel("TWLDETAIL"):SetUniqueLine({"TWL_EMAIL"})	// Não podem repetir e-mails dentro da mesma etapa do grupo de comunicação

oModel:GetModel("TWKDETAIL"):SetNoInsertLine(.T.)			// Configura que não será permitida a inserção de linhas na grid de etapas por parte do usuário
oModel:GetModel("TWKDETAIL"):SetNoDeleteLine(.T.)			// Configura que não será permitida a deleção de linhas na grid de etapas por parte do usuário

oModel:GetModel("TWLDETAIL"):SetOptional(.T.)					// Configura que o preenchimento da grid dos e-mails dos usuários das etapas do grupo de comunicação é opcional

oModel:SetActivate({|oModel| At774Load(oModel)})
Return(oModel)


//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@description	Definição da View
@sample	 	ViewDef()
@param			Nenhum
@return		ExpO: Objeto FwFormView
@author		Alexandre da Costa (a.costa)
@since			23/05/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oView		:= Nil								// Interface de visualização construída	
Local oModel		:= ModelDef()						// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oStrTWJ		:= FWFormStruct(2, "TWJ")																	// Cria a estrutura a ser usada na View
Local oStrTWK		:= FWFormStruct(2, "TWK", {|cCampo| !( AllTrim(cCampo)$"TWK_CODTWJ")})				// Cria a estrutura a ser usada na View
Local oStrTWL		:= FWFormStruct(2, "TWL", {|cCampo| !( AllTrim(cCampo)$"TWL_CODTWJ, TWL_CODTWK")})	// Cria a estrutura a ser usada na View

oView	:= FWFormView():New()						// Cria o objeto de View
oView:SetModel(oModel)								// Define qual modelo de dados será utilizado

oView:AddField("VIEW_TWJ", oStrTWJ, "TWJMASTER")	// Adiciona ao nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddGrid("VIEW_TWK", oStrTWK, "TWKDETAIL")	// Adiciona a grid responsável pelas etapas do grupo de comunicação
oView:AddGrid("VIEW_TWL", oStrTWL, "TWLDETAIL")	// Adiciona a grid responsável pelos usuários das etapas do grupo de comunicação

oView:CreateHorizontalBox("TOP",    15)			// Proporciona o tamanho da visão destinada às informações dos grupos de comunicação
oView:CreateHorizontalBox("MIDDLE", 35)			// Proporciona o tamanho da visão destinada às informações das etapas dos grupos de comunicação
oView:CreateHorizontalBox("DOWN",   50)			// Proporciona o tamanho da visão destinada às informações dos e-mails dos usuários de cada uma das etapas dos grupos de comunicação

oView:SetOwnerView("VIEW_TWJ", "TOP")				// Relaciona o identificador (ID) da View com o "box" para sua exibição
oView:SetOwnerView("VIEW_TWK", "MIDDLE")			// Relaciona o identificador (ID) da View com o "box" para sua exibição
oView:SetOwnerView("VIEW_TWL", "DOWN")				// Relaciona o identificador (ID) da View com o "box" para sua exibição

oView:AddIncrementField("VIEW_TWL", "TWL_ITEM")	// Sequência de usuários da etapa (campo incremental - automático) 

// Opções extras da rotina
oView:AddUserButton(STR0009,"BUDGET", {|oModel| At774CgEtapa(oModel)}) //"Recarga das etapas"

// Identificação (Nomeação) da VIEW
oView:SetDescription(STR0001)		// "Grupos de comunicação"
Return(oView)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At774Load
@description	Carga inicial do grid das etapas do grupo de comunicação
@sample	 	At774Load(oGrdMdl)
@param			ExpO: Objeto do Grid das etapas
@return		Nil
@author		Alexandre da Costa (a.costa)
@since			24/05/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function At774Load(oModel)

Local aOldAlias	:= If( !( Empty(Alias()) ), (Alias())->(GetArea()), {})
Local aOldSX5		:= SX5->(GetArea())
Local aSaveRows	:= {}
Local oTWKDETAIL	:= NIL
Local nTamCodTWJ	:= Len(TWK->TWK_CODTWJ)
Local nTamCodigo	:= Len(TWK->TWK_CODIGO)
Local nTamDescr	:= Len(SX5->X5_DESCRI)
Local nTamX5Chav	:= TamSX3("X5_CHAVE")[1]
Local cFilSX5		:= xFilial("SX5")
Local cFilTWK		:= xFilial("TWK")
Local nInd			:= 0
Local aLoad		:= {}
Local cEtapas 	:= "EO|GC|CT|ME|RE|SE|LI|EN|ER"
Local aEtapas 	:= Separa(cEtapas,'|')
Local nX			:= 0

//--- Prepara a carga das informações do modelo
If oModel:GetOperation() == MODEL_OPERATION_INSERT

	DbSelectArea("SX5")
	SX5->(dBSetOrder(1))			//X5_FILIAL+X5_TABELA+X5_CHAVE
	For nX := 1 To Len(aEtapas)
		If SX5->(dBSeek(cFilSX5+"TD"+PadR(aEtapas[nX], nTamX5Chav)))	//"TD"-Tabela genérica das etapas dos grupos de comunicação
			aAdd( aLoad, {cFilTWK, Space(nTamCodTWJ), "2", Left(AllTrim(SX5->X5_CHAVE),nTamCodigo), Left(AllTrim(X5Descri()),nTamDescr)} )
		EndIf
	Next nX

	SX5->(DbGoTop())
	SX5->(dBSeek(cFilSX5+"TD"))	//"TD"-Tabela genérica das etapas dos grupos de comunicação
	While SX5->( ! Eof() ) .AND. SX5->X5_FILIAL == cFilSX5 .AND. SX5->X5_TABELA == "TD"
		If !(Alltrim(SX5->X5_CHAVE) $ cEtapas)
			aAdd( aLoad, {cFilTWK, Space(nTamCodTWJ), "2", Left(AllTrim(SX5->X5_CHAVE),nTamCodigo), Left(AllTrim(X5Descri()),nTamDescr)} )
		Endif
		SX5->(dBSkip())
	EndDo

	If	Len(aLoad) > 0

		oTWKDETAIL	:= oModel:GetModel("TWKDETAIL")
		aSaveRows	:= FwSaveRows()	// Salva as linhas posicionadas do modelo

		oTWKDETAIL:SetNoInsertLine(.F.)		// Ativa a inserção das linhas na grid das etapas
		For nInd := 1	to	Len(aLoad)
			If	nInd > 1
				oTWKDETAIL:AddLine()
			EndIf
			oTWKDETAIL:SetValue("TWK_CODTWJ",aLoad[nInd,2])
			oTWKDETAIL:SetValue("TWK_ATIVO", aLoad[nInd,3])
			oTWKDETAIL:SetValue("TWK_CODIGO",aLoad[nInd,4])
			oTWKDETAIL:SetValue("TWK_DESCR", aLoad[nInd,5])
		Next nInd
		oTWKDETAIL:SetNoInsertLine(.T.)	// Bloqueia a inserção das linhas na grid das etapas

		FwRestRows(aSaveRows)	// Restaura o posicionamento das linhas do modelo

	EndIf

EndIf

RestArea(aOldSX5)
If	Len(aOldAlias) > 0
	RestArea(aOldAlias)
EndIf
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} PrLinOkTWK
@description  Pré-validação da GRID das etapas dos grupos de comunicação
@sample        PrLinOkTWK(oModTWK, nTWKLinGrd, cTWKAcao, cTWKFldName)
@param         oModTWK:      Modelo ativo
@param         nTWKLinGrd:  Linha do GRID
@param         cTWKAcao:    Ação
@param         cTWKFldName: Campo
@return        ExpL:        .T.=Ação válida // .F.=Ação inválida
@author        Alexandre da Costa (a.costa)
@since         06/09/2016       
@version       P12   
/*/
//------------------------------------------------------------------------------
Static Function PrLinOkTWK(oModTWK, nTWKLinGrd, cTWKAcao, cTWKFldName, lAutomato)

Local aSaveLine	:= FWSaveRows()
Local nLinAuxTWK	:= nTWKLinGrd
Local cEtapas 	:= "EO|GC|CT|ME|RE|SE|LI|EN|ER"
Local aEtapas 	:= Separa(cEtapas,'|')
Local lRet			:= .T.

Default lAutomato := .F.

If	cTWKAcao == "DELETE"

	If	aScan(aEtapas, {|x| x == AllTrim(oModTWK:GetValue("TWK_CODIGO"))}) > 0
		If !lAutomato
			Help(,, "TECA774-PrLinOkTWK",,"Operação não permitida.",1,0,,,,,,{"Não é permitida a exclusão das etapas padrões dos grupos de comunicação."})
		EndIf
		lRet	:= .F.
	EndIf

EndIf
FWRestRows(aSaveLine)
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} At774CgEtapa
@description	Recarrega as etapas conforme o cadastro existente no dicionário de Tabelas Genéricas
@sample	 	At774CgEtapa(oModel)
@param			ExpO:	Model
@Return		ExpL:	.T.=Recarga processada com sucesso ## .F.=Recarga não processada com sucesso
@author		Alexandre da Costa (a.costa)
@since			25/05/2016
@version		P12
/*/
//-------------------------------------------------------------------
Static Function At774CgEtapa(oModel, lAutomato)

Local aOldAlias	:= If( !( Empty(Alias()) ), (Alias())->(GetArea()), {})
Local aOldSX5		:= SX5->(GetArea())
Local aSaveRows	:= {}
Local oTWKDETAIL	:= NIL
Local nTamCodTWJ	:= Len(TWK->TWK_CODTWJ)
Local nTamCodigo	:= Len(TWK->TWK_CODIGO)
Local nTamDescr	:= Len(SX5->X5_DESCRI)
Local cFilSX5		:= xFilial("SX5")
Local cFilTWK		:= xFilial("TWK")
Local nInd			:= 0
Local aLoad		:= {}
Local lRet			:= .T.
Local cEtapas 		:= "EO|GC|CT|ME|RE|SE|LI|EN|ER"

Default lAutomato	:= .F.

If oModel:GetOperation() == MODEL_OPERATION_UPDATE

	aSaveRows	:= FwSaveRows()	// Salva as linhas posicionadas do modelo
	oTWKDETAIL	:= oModel:GetModel("TWKDETAIL")

	DbSelectArea("SX5")
	SX5->(dBSetOrder(1))		//X5_FILIAL+X5_TABELA+X5_CHAVE
	SX5->(dBSeek(cFilSX5+"TD"))	//"TD"-Tabela genérica das etapas dos grupos de comunicação
	While SX5->( ! Eof() ) .AND. SX5->X5_FILIAL == cFilSX5 .AND. SX5->X5_TABELA == "TD"
		If	!( oTWKDETAIL:SeekLine( {{"TWK_CODIGO", Left(SX5->X5_CHAVE,Len(TWK->TWK_CODIGO))}} ) ) .AND. !(Alltrim(SX5->X5_CHAVE) $ cEtapas)
			aAdd( aLoad, {cFilTWK, Space(nTamCodTWJ), "2", Left(AllTrim(SX5->X5_CHAVE),nTamCodigo), Left(AllTrim(X5Descri()),nTamDescr)} )
		EndIf
		SX5->(dBSkip())
	EndDo

	If	Len(aLoad) > 0

		oTWKDETAIL:SetNoInsertLine(.F.)	// Ativa a inserção das linhas na grid das etapas
		For nInd := 1	to	Len(aLoad)
			oTWKDETAIL:AddLine()
			oTWKDETAIL:SetValue("TWK_CODTWJ",aLoad[nInd,2])
			oTWKDETAIL:SetValue("TWK_ATIVO", aLoad[nInd,3])
			oTWKDETAIL:SetValue("TWK_CODIGO",aLoad[nInd,4])
			oTWKDETAIL:SetValue("TWK_DESCR", aLoad[nInd,5])
		Next nInd
		oTWKDETAIL:SetNoInsertLine(.T.)	// Bloqueia a inserção das linhas na grid das etapas

	EndIf

	FwRestRows(aSaveRows)	// Restaura o posicionamento das linhas do modelo

Else
	If !lAutomato
		Help(,, "At774CgEtapa",, STR0010, 1, 0,,,,,,{STR0011}) //"O processo da recarga das etapas do grupo de comunicação só pode ocorrer durante a execução da opção 'Alterar' da rotina." ## "Acesse a opção 'Alterar' da rotina para que seja possível a execução da recarga das etapas."
	EndIf
	lRet	:= .F.

EndIf

RestArea(aOldSX5)
If	Len(aOldAlias) > 0
	RestArea(aOldAlias)
EndIf
Return	lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At744VldCpo
@description	Validações de campos
@sample	 	At744VldCpo(cField)
@param			ExpC: Nome do Campo
@return		ExpL: .T.=Campo com conteúdo válido // .F.=Campo com conteúdo inválido
@author		Alexandre da Costa (a.costa)
@since			23/05/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Function At774VldCpo(cField)

Local oModel	:= FWModelActive()
Local cNomUsr	:= ""
Local cEmail	:= ""
Local lRet		:= .T.

Do	Case
	Case	cField == "TWL_USER"
		If	Empty( FwFldGet(cField) )
			cNomUsr	:= Space(Len(TWL->TWL_NOMUSR))
			cEmail		:= Space(Len(TWL->TWL_EMAIL))
		Else
			cNomUsr	:= UsrFullName(FwFldGet("TWL_USER"))
			cEmail		:= UsrRetMail(FwFldGet("TWL_USER"))
		EndIf
		cEmail := RTrim(cEmail)
		oModel:LoadValue('TWLDETAIL','TWL_NOMUSR',cNomUsr)
		oModel:LoadValue('TWLDETAIL','TWL_EMAIL',cEmail)
EndCase
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} At774TdOk
@description	Validação final do Model, antes da gravação
@sample	 	At774TdOk(oModel)
@param			oModel		Model
@return		ExpL	.T.=Gravação permitida, .F.=Gravação não permitida
@author		Alexandre da Costa (a.costa)
@since			25/05/2016
@version		P12
/*/
//------------------------------------------------------------------
Function At774TdOk(oModel, lAutomato)

Local aOldAlias	:= If( !( Empty(Alias()) ), (Alias())->(GetArea()), {})
Local aSaveRows	:= FwSaveRows()	// Salva as linhas posicionadas do modelo
Local oTWKDETAIL	:= oModel:GetModel("TWKDETAIL")
Local oTWLDETAIL	:= oModel:GetModel("TWLDETAIL")
Local nTWKTotLin	:= oTWKDETAIL:Length()
Local cMailServer	:= AllTrim(SuperGetMv("MV_RELSERV"))
Local cMailConta 	:= AllTrim(SuperGetMv("MV_RELACNT"))
Local cMailSenha 	:= AllTrim(SuperGetMv("MV_RELPSW"))
Local nInd			:= 0
Local lRet			:= .T.

Default lAutomato := .F.

oTWKDETAIL:GoLine(1)
For	nInd := 1 to nTWKTotLin
	oTWKDETAIL:GoLine(nInd)
	If	oTWKDETAIL:GetValue("TWK_ATIVO") == '1' .AND. oTWLDETAIL:IsEmpty()	
		If !lAutomato	
			Help( , , "At774TdOk", , STR0012, 1, 0,,,,,,{STR0013}) //"Existe alguma etapa configurada como 'ativa' sem qualquer e-mail associado a ela." ## "Confirme a configuração das etapas. Para as etapas 'ativas' é obrigatória a associação de ao menos um e-mail. Para as etapas 'inativas' pode haver ou não e-mails associados a ela."
		EndIf
		lRet	:=	.F.
		EXIT
	EndIf
Next nInd

If Empty(cMailServer) .Or. Empty(cMailConta) .Or. Empty(cMailSenha) 
	If !lAutomato 
		Help(,, "At774ParMail",,STR0028,1,0,,,,,,{STR0029})//"Os parâmetros para envio de email não foram configurados! " ## "Verifique os parametros MV_RELSERV, MV_RELACNT, MV_RELPSW."
	EndIf 
	lRet := .F.
EndIf

FwRestRows(aSaveRows)	// Restaura o posicionamento das linhas do modelo
If	Len(aOldAlias) > 0
	RestArea(aOldAlias)
EndIf
Return	lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At744GetMail
@description	Busca os e-mails cadastrados da etapa do grupo de comunicação para receberem a 
				notificação de finalização da etapa. 
@sample	 	At744GetMail(cGrupo, cEtapa)
@param			ExpC:	Código do grupo de comunicação para o qual se deseja verificar se ocorrerá
						o envio da notificação.
@param			ExpC:	Código da etapa do grupo de comunicação que se deseja levantar
						qual(is) e-mail(s) será(ão) utilizado(s) no envio da notificação.
@return		ExpA:	Array contendo a relação de e-mails de destino para o envio da notificação.
						Se o array de retorno não contiver e-mails, então não ocorrerá o envio da
						notificação da etapa.
@author		Alexandre da Costa (a.costa)
@since			24/05/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Function At774GetMail(cGrupo, cEtapa)

Local aOldArea	:= {}
Local aRet			:= {}
Local cNewAlias	:= ""

Default cGrupo	:= ""
Default cEtapa	:= ""

If	!Empty(cGrupo) .AND. !Empty(cEtapa)

	aOldArea	:= If(!( Empty(Alias()) ), (Alias())->(GetArea()), {})
	cNewAlias	:= GetNextAlias()

	BeginSql Alias cNewAlias

		SELECT TWL.TWL_EMAIL
		  FROM %Table:TWL% TWL
		       INNER JOIN %Table:TWK% TWK ON TWK.TWK_FILIAL = %xFilial:TWK% 
		                                 AND TWK.%NotDel% 
		                                 AND TWK.TWK_CODTWJ = TWL.TWL_CODTWJ
		                                 AND TWK.TWK_CODIGO = TWL.TWL_CODTWK
		                                 AND TWK.TWK_ATIVO = '1'
		 WHERE TWL.TWL_FILIAL = %xFilial:TWL%
		   AND TWL.%NotDel%
		   AND TWL.TWL_CODTWJ = %Exp:cGrupo%
		   AND TWL.TWL_CODTWK = %Exp:cEtapa%

	EndSql

	DbSelectArea(cNewAlias)
	If (cNewAlias)->( ! Eof() )
		While	(cNewAlias)->( ! Eof() )
			aAdd(aRet, AllTrim((cNewAlias)->TWL_EMAIL))
			(cNewAlias)->(dBSkip())
		EndDo
	Endif
	(cNewAlias)->(DbCloseArea())

	If	Len(aOldArea) > 0
		RestArea(aOldArea)
	EndIf

EndIf
Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At774Mail
@description	Realiza o envio de e-mail para o grupo de comunicação.
@sample	 	At774Mail(cEtp,cTxt)
@param		cTab:	Tabela que esta posicionado, para a query.
@param		cChv:	Chave para ser utilizada na query.
@param		cEtp:	Código da etapa do grupo de comunicação.
@param		cTxt:	Texto do corpo do HTML.
@param		cStt:	Status da etapa.
@param		cRot:	Texto da rotina executada.
@param		aPlEtp: Pula as etapas que não foram realizadas.
@return		Nil
@author		Kaique Schiller
@since			24/05/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Function At774Mail(cTab,cChv,cEtp,cTxt,cStt,cRot,aPlEtp, lAutomato)
Local aArea		:= GetArea()
Local aEnvio 		:= {}
Local cAssunto 	:= ""
Local cHtml		:= ""
Local cGrp			:= ""
Local cMsgShwLog	:= ""
Local nI			:= 0
Local lVersion23	:= HasOrcSimp()
Default cTab		:= ""
Default cChv		:= ""
Default cEtp		:= ""
Default cTxt		:= ""
Default cStt		:= "GREEN"
Default cRot		:= ""
Default aPlEtp		:= {}
Default lAutomato	:= .F.

If lVersion23
	If SuperGetMv("MV_ORCSIMP",,"2") == "1"
		cTxt :=  StrTran( cTxt, STR0030, "" ) //"Num. Proposta: "
	EndIf
EndIf

cGrp := At774GtGrp(cTab,cChv) //Grupo de comunicação.

DbSelectArea("TWL")
DbSetOrder(1)

If !Empty(cGrp) .AND. !Empty(cEtp) .AND. !Empty(cTxt) .And. TWL->(dBSeek(xFilial("TWL")+ cGrp + cEtp))
	
	aEnvio := At774GetMail(cGrp,cEtp) //E-mail's do grupo de comunicação.
		
	cAssunto := AllTrim(Posicione("SX5",1,xFilial("SX5")+"TD"+PadR(cEtp, TamSX3("X5_CHAVE")[1]),"X5_DESCRI")) //Assunto do e-mail a ser enviado.

	cHtml := At774cHtml(cEtp,cAssunto,cTxt,cStt,cRot,aPlEtp) //Formação do HTML para o envio.
	
	If !Empty(aEnvio) .AND. !Empty(cAssunto) .AND. !Empty(cHtml)
		MTSendMail(aEnvio,cAssunto,cHtml) //Envio de E-mail.
	Else
		If !lAutomato
			Help( , , "At774Mail", , STR0015, 1, 0,,,,,,{STR0016})	//"Não foi possível realizar o envio da notificação 'WORKFLOW' para o Grupo de Comunicação" ## "Verifique as configurações necessárias para a utilização desta funcionalidade."
	
			cMsgShwLog	:= STR0017+CRLF	//Verifique as inconsistências na configuração para utilização da funcionalidade de envio do 'workflow' do Grupo de Comunicação."
			cMsgShwLog	+= STR0018+CRLF	//"Operação selecionada: Envio de e-mail para o Grupo de Comunicação"
			cMsgShwLog	+= STR0019+" '"+cGrp+"'"+CRLF	//"Código do Grupo de Comunicação:"
			cMsgShwLog	+= STR0020+" '"+cEtp+"'"+CRLF	//"Código da etapa de envio:"
			cMsgShwLog	+= STR0021+" '"+AllTrim(cAssunto)+"'"+;	//"Assunto do e-mail:"
							If(Empty(cAssunto)," <---- "+STR0022,"")+CRLF	//"Não foi possível identificar um assunto para o e-mail."
			cMsgShwLog	+= STR0023+" "	//"Destinatários:"
			If	Empty(aEnvio)
				cMsgShwLog	+= " <---- "+STR0024+CRLF	//"Não foi possível localizar os e-mails dos destinatários."
			Else
				cMsgShwLog	+= CRLF
				For	nI := 1 to Len(aEnvio)
					cMsgShwLog	+= Space(15)+StrZero(nI,3)+"-"+aEnvio[nI]+CRLF
				Next nI
			EndIf
			cMsgShwLog	+= STR0025+" '"+cHtml+"'"+;	//"Arquivo HTML do corpo do e-mail:"
							If(Empty(cHtml)," <---- "+STR0026,"")+CRLF	//"Não foi possível identificar o arquivo HTML para o corpo do e-mail."
			AtShowLog(	cMsgShwLog /*cMemoLog*/,;
						STR0027 /*cTitle*/,;	//"Inconsistências para envio do E-mail ao Grupo de Comunicação"
						/*lVScroll*/,;
						/*lHScroll*/,;
						/*lWrdWrap*/,;
						.F. /*lCancel*/)
		EndIf
	Endif

Endif

RestArea(aArea)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} At774GtGrp
@description	Função para selecionar o codigo do grupo de comunicação.
@sample	 	At774GtGrp(cTabela,cChave)
@param		cTabela:	Tabela.
@param		cChave:		Chave para a query.

@return		cRet:	Codigo do grupo de Comunicação.
@author		Kaique Schiller
@since			24/05/2016
@version		P12
/*/
//-----------------------------------------------------------------------------
Static Function At774GtGrp(cTabela,cChave)
Local cRet 		:= ""
Local cFrom		:= ""
Local cSelect	:= ""
Local cJoin		:= ""
Local cWhere	:= ""
Local cNewAlias	:= GetNextAlias()

If !Empty(cTabela) .AND. !Empty(cChave)
	If cTabela == "TFJ" //Orçamento de Serviços
		cRet := cChave
	Elseif cTabela == "ADY" //Proposta Comercial Cabeçalho

		cSelect := "TFJ_GRPCOM"

		cJoin :=  RetSQLName("ADY") + " ADY "

		cJoin += "	INNER JOIN " + RetSQLName("TFJ") + " TFJ "
		cJoin += "	ON ADY_FILIAL  = '" + xFilial("ADY") + "' "
		cJoin += "	AND ADY_PROPOS = TFJ_PROPOS "
		cJoin += "	AND ADY_PREVIS = TFJ_PREVIS "
		cJoin += "	AND ADY.D_E_L_E_T_ = ' ' "
		
		cWhere := "	TFJ_FILIAL = '" + xFilial("TFJ") + "' "
		cWhere += " AND TFJ_PROPOS = '" + cChave + "'"
		cWhere += "	AND TFJ.D_E_L_E_T_ = ' ' "

		cSelect	:= '%' + cSelect + '%'
		cJoin	:= '%' + cJoin + '%'
		cWhere	:= '%' + cWhere + '%'

	Elseif cTabela == "TEW" //Mov. Equip. Locação

		cSelect := "DISTINCT TFJ_GRPCOM"

		cJoin :=  RetSQLName("TEW") + " TEW "

		cJoin += "	INNER JOIN " + RetSQLName("TFJ") + " TFJ "
		cJoin += "	ON TEW_FILIAL  = '" + xFilial("TEW") + "' "
		cJoin += "	AND TEW_ORCSER = TFJ_CODIGO "
		cJoin += "	AND TEW.D_E_L_E_T_ = ' ' "
		
		cWhere := "	TFJ_FILIAL = '" + xFilial("TFJ") + "' "
		cWhere += " AND TFJ_CODIGO = '" + cChave + "'"
		cWhere += "	AND TFJ.D_E_L_E_T_ = ' ' "

		cSelect := '%' + cSelect + '%'
		cJoin	:= '%' + cJoin + '%'
		cWhere	:= '%' + cWhere + '%'	

	Endif
Endif

If !Empty(cSelect) .AND. !Empty(cJoin) .AND. !Empty(cWhere)
	BeginSql Alias cNewAlias

		SELECT %Exp:cSelect%
		FROM %Exp:cJoin%
		WHERE %Exp:cWhere%

	EndSql

	DbSelectArea(cNewAlias)

	If (cNewAlias)->(!Eof())
		cRet := (cNewAlias)->TFJ_GRPCOM
	Endif
	
	(cNewAlias)->(dbCloseArea())
Endif

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At774cHtml
@description	Responsavel por converter o arquivo html em caractere.
@sample	 	At774cHtml(cText)
@param		cEtp:	 Etapa para a localização do arquivo.
@param		cTit:	 Cabeçalho a ser exibido no HTML.
@param		cText:	 Texto a ser exibido no HTML.
@param		cStatus: Status da Etapa.
@param		aPulaEtp: Pula as etapas que não foram realizadas.
@return		cRet: 	Html em caractere.
@author		Kaique Schiller
@since			24/05/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function At774cHtml(cEtp,cTit,cText,cStatus,cRotina,aPulaEtp)
Local cRet    		:= ""
Local cHTMLSrc  	:= ""
Local cHTMLDst  	:= ""
Local oHTMLBody 	:= Nil
Local aEtapas		:= {}
Local nX			:= 0
Local nY			:= 1
Local lFeito		:= .T.
Local lExce			:= .F.
Local lVersion23	:= HasOrcSimp()

If cEtp $ ("EO|GC|CT|ME")
	
	If lVersion23
		If SuperGetMv("MV_ORCSIMP",,"2") == "2"
			aEtapas	:= {"EO","GC","CT","ME"}
		Else
			aEtapas	:= {"GC","CT","ME"}
		EndIf	
	Else
		aEtapas	:= {"EO","GC","CT","ME"}
	EndIf
ElseIf cEtp $ ("RE|SE|LI|EN|ER")
	aEtapas	:= {"RE","SE","LI","EN","ER"}
	
Endif

cText += At774GerHtm(aEtapas[1],"1") //Inicio gerando HTML.

For nX := 1 To Len(aEtapas)

	If cEtp == aEtapas[nX] //Quando for a etapa realizada no momento.
		cText += At774GerHtm(aEtapas[nX],"2",cStatus,cRotina)
		lFeito := .F.

		If nX == Len(aEtapas)
		
			If cStatus == "GREEN" //Finalizando Fluxo.
				cText += At774GerHtm(aEtapas[nX],"3","BLUE")
			Else
				cText += At774GerHtm(aEtapas[nX],"3") //Fluxo não foi finalizado.
			Endif
		Endif
		
	Elseif lFeito//Etapas realizadas.

		If Len(aPulaEtp) > 0

			If aEtapas[nX] == aPulaEtp[nY]
				cText += At774GerHtm(aEtapas[nX],"2") //Etapas não realizadas.
				If Len(aPulaEtp) <> nY
					nY++
				Endif
			Else
				cText += At774GerHtm(aEtapas[nX],"2","GREEN") //Etapa realizada.
			Endif
		Else
			cText += At774GerHtm(aEtapas[nX],"2","GREEN")
		Endif

	Elseif nX == Len(aEtapas) //Ultima Etapa.

		cText += At774GerHtm(aEtapas[nX],"2")
		cText += At774GerHtm(aEtapas[nX],"3")

	Else //Etapas não realizadas.
		cText += At774GerHtm(aEtapas[nX],"2")

	Endif
Next nX

//carga do Html genérico ou por etapa
If File("\samples\wf\TEC_"+cEtp+".html")
	cHTMLSrc  := "samples/wf/TEC_"+cEtp+".html"
	cHTMLDst  := "samples/wf/TEC_"+cEtp+".htm"
	
Elseif File("\samples\wf\TEC_GEN.html")
	cHTMLSrc  := "samples/wf/TEC_GEN.html"
	cHTMLDst  := "samples/wf/TEC_GEN.htm"

EndIf

If !Empty(cHTMLSrc)

	oHTMLBody := TWFHTML():New(cHTMLSrc)

	If ExistBlock("AT774UHTML") //Ponto de entrada para customização do HTML.
		ExecBlock("AT774UHTML",.F.,.F.,{oHTMLBody})
	Else
		oHTMLBody:ValByName("cMsgTit",cTit)  // Cabeçalho HTML
		oHTMLBody:ValByName("cMsgMail",cText)// Mensagem HTML
	EndIf
	
	If !Empty(cText)
		
		oHTMLBody:SaveFile(cHTMLDst) //Salva o HTM
		cRet:= MtHTML2Str(cHTMLDst)  //Transforma em caractere.
		FErase(cHTMLDst)			
		
	Endif
Endif

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At774GerHtm
@description	Responsavel por converter o arquivo html em caractere.
@sample	 	At774GerHtm(cText)
@param		cEtpa:	Etapa do grupo de comunicação
@param		cStep:	Trecho que será concatenado para a geração do HTML
@param		cStat:	Status da etapa.

@return		cHtml: 	Html convertido em caractere.
@author		Kaique Schiller
@since			24/05/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function At774GerHtm(cEtpa,cStep,cStat,cRoti)
Local cHtml 	:= ""
Local cDscEtp 	:= ""
Local cCorTxt	:= "white" //Branco
Local cColor	:= ""
Default cEtpa	:= ""
Default cStep 	:= ""
Default cStat 	:= ""
Default cRoti	:= ""

//Descrição da Etapa.
cDscEtp := AllTrim(Posicione("SX5",1,xFilial("SX5")+"TD"+PadR(cEtpa, TamSX3("X5_CHAVE")[1]),"X5_DESCRI"))

//Cores
If cStat == "RED" //Vermelho - Cancelado
	cColor := "#c0392b"
ElseIf cStat == "GREEN" //Verde - Realizado
	cColor 	:= "#2ecc71"
Elseif cStat == "BLUE" //Azul - Finalizado
	cColor := "#3498db"
Else
	cColor :=  "#bdc3c7" //Cinza - Pendente
	cCorTxt := "black"
Endif

If cStep == "1" //Inicio
	cHtml +=	"		<table style='width:98%;margin-left:1%: black ; font-family:verdana'>"
	cHtml +=	"			<tr style='height:50px;text-align:center'>"

Elseif cStep == "2" //Etapas
	cHtml +=	"				<td style='width:10%; font-family:verdana; background:"+cColor+"; color:"+cCorTxt+"; border-right:2px '>"
	cHtml +=	"					"+cDscEtp+" "+cRoti
	cHtml +=	"				</td>"
Elseif cStep == "3" //Final
	cHtml +=	"				<td style='width:10%; font-family:verdana; background:"+cColor+"; color:"+cCorTxt+"; border-right:2px '>"
	cHtml +=	"				"+STR0014 //Finalizado
	cHtml +=	"				</td>"
	cHtml +=	"			</tr>"
	cHtml +=	"		</table>"
Endif

Return cHtml

//------------------------------------------------------------------------------
/*/{Protheus.doc} At774PlEtp
@description	Função para pular as etapas que não foram realizadas..
@sample	 	At774PlEtp(cTabela,cChave)
@param		cTabela:	Tabela.
@param		cChave:		Chave de pesquisa.

@return		aRet:	Array com as etapas.
@author		Kaique Schiller
@since			20/06/2016
@version		P12
/*/
//-----------------------------------------------------------------------------
Function At774PlEtp(cTabela,cChave)
Local aAreaTEW := TEW->(GetArea())
Local aAreaTFI := TFI->(GetArea())
Local aRet	   := {}

If cTabela == "TEW"

	DbSelectArea("TFI")
	TFI->(DbSetOrder(1))

	If TFI->(DbSeek(cChave))
		If Empty(TFI->TFI_RESERV) //Quando não houver reserva
			AAdd( aRet, "RE" )
		Else
			aRet := {}
		Endif
	Endif

	If Empty(TEW->TEW_NFSAI) //Quando não houver Nf de saida.
		AAdd( aRet, "EN" )
	Endif

Endif

If !Empty(aAreaTEW)
	RestArea(aAreaTEW)
Endif

If !Empty(aAreaTFI)
	RestArea(aAreaTFI)
Endif

Return aRet