#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA650.CH"

#Define DF_SHWFOLDER_OSSIGATEC	1
#Define DF_SHWFOLDER_OSSIGAMNT	2
#Define DF_SHWFOLDER_MOVIMEQUI	3
#Define DF_SHWFOLDER_OUTRLANCT	4

Static	cRetFtTEW	:=	""	//Retorno da consulta específica 'At650FtTEW' (SXB)
Static	cRetFtAB7	:=	""	//Retorno da consulta específica 'At650FtAB7' (SXB)
Static	cRetFtABS	:=	""	//Retorno da consulta específica 'At650FtABS' (SXB)
Static nOpcAuto	:=	0	//Variável de controle do Robô

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA650
@description	Processos de indenizações
@sample	 	TECA650() 
@param			Nenhum
@return		NIL
@author		Alexandre da Costa (a.costa)
@since			04/04/2016
@version		P12   
/*/
//------------------------------------------------------------------------------
Function TECA650()

Local	oMBrowse		:= FWmBrowse():New()

oMBrowse:SetAlias("TW9")				// "TW9"-Processos de indenização
oMBrowse:SetDescription(STR0001)	// "Processo de indenização"
//- Definição de Legendas
oMBrowse:AddLegend("Alltrim(TW9_STATUS) == '1'", "GREEN", STR0014)		// "Indenização em aberto"
oMBrowse:AddLegend("Alltrim(TW9_STATUS) == '2'", "BLUE",  STR0015)		// "Indenização faturada"
oMBrowse:AddLegend("Alltrim(TW9_STATUS) == '3'", "RED",   STR0016)		// "Indenização encerrada"
//
oMBrowse:Activate()
Return	NIL


//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@description	Define o menu funcional. 
@sample	 	MenuDef() 
@param			Nenhum
@return		ExpA	Opções da Rotina.
@author		Alexandre da Costa (a.costa)      
@since			04/04/2016
@version		P12   
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()    

Local	aRotina		:= {}

ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"			OPERATION 1                      ACCESS 0	// "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TECA650"	OPERATION MODEL_OPERATION_VIEW   ACCESS 0	// "Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TECA650"	OPERATION MODEL_OPERATION_INSERT ACCESS 0	// "Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TECA650"	OPERATION MODEL_OPERATION_UPDATE ACCESS 0	// "Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TECA650"	OPERATION MODEL_OPERATION_DELETE ACCESS 0	// "Excluir"
ADD OPTION aRotina TITLE STR0007 ACTION "At650Faturar()"	OPERATION MODEL_OPERATION_UPDATE ACCESS 0	// "Faturar"
ADD OPTION aRotina TITLE STR0036 ACTION "At650ExcFat()"		OPERATION MODEL_OPERATION_UPDATE ACCESS 0	// "Excluir faturamento"
ADD OPTION aRotina TITLE STR0008 ACTION "At650Encerra()"	OPERATION MODEL_OPERATION_UPDATE ACCESS 0	// "Encerrar"
ADD OPTION aRotina TITLE STR0012 ACTION "At650Docum()"		OPERATION MODEL_OPERATION_UPDATE ACCESS 0	// "Conhecimento"
ADD OPTION aRotina TITLE STR0059 ACTION "TECR060()"			OPERATION MODEL_OPERATION_UPDATE ACCESS 0	// "Consulta de indenização"

Return(aRotina)


//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@description	Definição do Model
@sample	 	ModelDef() 
@param			Nenhum
@return		ExpO	Objeto FwFormModel 
@author		Alexandre da Costa (a.costa)      
@since			04/04/2016
@version		P12   
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local	oModel		:= Nil
Local	oStrTW9	:= FWFormStruct(1, "TW9")
Local	oStrTWAT	:= FWFormStruct(1, "TWA")	// TWA - Itens da indenização (OS SIGATEC)
Local	oStrTWAM	:= FWFormStruct(1, "TWA")	// TWA - Itens da indenização (OS SIGAMNT)
Local	oStrTWAE	:= FWFormStruct(1, "TWA")	// TWA - Itens da indenização (Movimentação Equipamentos)
Local	oStrTWAO	:= FWFormStruct(1, "TWA")	// TWA - Itens da indenização (Outros Lançamentos)
Local	aTrigger	:= {}

// Cria o objeto do modelo de dados principal
oModel := MPFormModel():New("TECA650", /*bPreValid*/, {|oModel| At650TdOk(oModel)}, {|oModel| At650Commit(oModel)}, /*bCancel*/)

oModel:AddFields("TW9MASTER", /*cOwner*/ , oStrTW9)
oModel:AddGrid("TWATDETAIL",  "TW9MASTER", oStrTWAT) // Cria a grid dos Itens da indenização (OS SIGATEC)
oModel:AddGrid("TWAMDETAIL",  "TW9MASTER", oStrTWAM) // Cria a grid dos Itens da indenização (OS SIGAMNT)
oModel:AddGrid("TWAEDETAIL",  "TW9MASTER", oStrTWAE) // Cria a grid dos Itens da indenização (Movimentação Equipamentos)
oModel:AddGrid("TWAODETAIL",  "TW9MASTER", oStrTWAO) // Cria a grid dos Itens da indenização (Outras Movimentações)

oModel:SetRelation("TWATDETAIL", {{"TWA_FILIAL","xFilial('TWA')"}, {"TWA_CODTW9","TW9_CODIGO"}, {"TWA_TPOS","'1'"}}, TWA->(IndexKey(1)))
oModel:SetRelation("TWAMDETAIL", {{"TWA_FILIAL","xFilial('TWA')"}, {"TWA_CODTW9","TW9_CODIGO"}, {"TWA_TPOS","'2'"}}, TWA->(IndexKey(1)))
oModel:SetRelation("TWAEDETAIL", {{"TWA_FILIAL","xFilial('TWA')"}, {"TWA_CODTW9","TW9_CODIGO"}, {"TWA_TPOS","' '"}}, TWA->(IndexKey(1)))
oModel:SetRelation("TWAODETAIL", {{"TWA_FILIAL","xFilial('TWA')"}, {"TWA_CODTW9","TW9_CODIGO"}, {"TWA_TPOS","'3'"}}, TWA->(IndexKey(1)))

oModel:GetModel("TWATDETAIL"):SetDescription(STR0009)	// "O.S. SIGATEC"
oModel:GetModel("TWAMDETAIL"):SetDescription(STR0010)	// "O.S. SIGAMNT"
oModel:GetModel("TWAEDETAIL"):SetDescription(STR0011)	// "Movim./Equip."
oModel:GetModel("TWAODETAIL"):SetDescription(STR0072)	// "Outros Lançamentos"

oModel:GetModel("TWATDETAIL"):SetOptional(.T.)
oModel:GetModel("TWAMDETAIL"):SetOptional(.T.)
oModel:GetModel("TWAEDETAIL"):SetOptional(.T.)
oModel:GetModel("TWAODETAIL"):SetOptional(.T.)

oModel:GetModel("TWATDETAIL"):SetUniqueLine({"TWA_CODAB6","TWA_CODAB7"})	// Chave única na entrada de dados no GRID
oModel:GetModel("TWAMDETAIL"):SetUniqueLine({"TWA_CODSTJ"})					// Chave única na entrada de dados no GRID

oModel:SetVldActivate({|oModel| At650Vld(oModel)}) // Validação na ativação do MODEL
oModel:SetActivate({|oModel| At650Actvt(oModel)}) // Validação na ativação do MODEL
Return(oModel)


//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@description	Definição da View
@sample	 	ViewDef()
@param			Nenhum
@return		ExpO	Objeto FwFormView 
@author		Alexandre da Costa (a.costa)
@since			04/04/2016       
@version		P12   
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oView		:= Nil									// Interface de visualização construída	
Local oModel		:= ModelDef()							// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado

Local oStrTW9		:= FWFormStruct(2, "TW9", {|cCampo| ! (AllTrim(cCampo)$"TW9_STATUS") })	// Cria a estrutura a ser usada na View
Local oStrTWAT 	:= NIL
Local oStrTWAM 	:= NIL
Local oStrTWAE 	:= NIL
Local oStrTWAO 	:= NIL

Local aShwAba		:= {.T.,.T.,.T., .T.}	// Configuração inicial para determinar qual(is) aba(s) será(ão) exibida(s) na View
Local aShwAbaDef	:= aShwAba			// Configuração default para determinar qual(is) aba(s) será(ão) exibida(s) na View (utilizada se o retorno do ponto de entrada não for considerado 'válido')

If	ExistBlock( "AT650ABA" )

	aShwAba := ExecBlock("AT650ABA",.F.,.F.,aShwAba)
	If	ValType(aShwAba) <> "A"								.OR.;
		Len(aShwAba)	< 3									.OR.;
		ValType(aShwAba[DF_SHWFOLDER_OSSIGATEC]) <> "L"	.OR.;
		ValType(aShwAba[DF_SHWFOLDER_OSSIGAMNT]) <> "L"	.OR.;
		ValType(aShwAba[DF_SHWFOLDER_MOVIMEQUI]) <> "L"	.OR.;
		( !aShwAba[DF_SHWFOLDER_OSSIGATEC] .AND.;
		  !aShwAba[DF_SHWFOLDER_OSSIGAMNT] .AND.;
		  !aShwAba[DF_SHWFOLDER_MOVIMEQUI] )
		aShwAba	:=	aShwAbaDef
	EndIf

EndIf

oView	:= FWFormView():New()							// Cria o objeto de View
oView:SetModel(oModel)									// Define qual modelo de dados será utilizado

oView:CreateHorizontalBox("TOP",  30)					// Adiciona as visões na tela
oView:CreateHorizontalBox("DOWN", 70)					// Adiciona as visões na tela

oView:AddField("VIEW_TW9", oStrTW9, "TW9MASTER")		// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:SetOwnerView("VIEW_TW9", "TOP")					// Relaciona o identificador (ID) da View com o "box" para sua exibição

oView:CreateFolder("ABAS", "DOWN")						// Cria Folders na view

If	aShwAba[DF_SHWFOLDER_OSSIGATEC]						// Confirma se a aba 'O.S.SIGATEC' será exibida na View

	// Cria a estrutura a ser usada na View
	// TWA - Itens da indenização (O.S. SIGATEC)
	oStrTWAT	:= FWFormStruct(2, "TWA", {|cCampo| AllTrim(cCampo)$"TWA_CODAB6, TWA_CODAB7, TWA_NUMSER, TWA_CUSTO, TWA_VLRCOB, TWA_PRODUT, TWA_TES, TWA_BLQAA3, TWA_OBS"})
	// Cria a grid dos Itens da indenização (OS SIGATEC)
	oView:AddGrid("VIEW_TWAT", oStrTWAT, "TWATDETAIL")
	// Cria Folders na View
	oView:AddSheet("ABAS", "DOWN_TWATDETAIL", STR0009)	//"O.S. SIGATEC"
	// Define a área dos Itens da indenização (O.S. SIGATEC)
	oView:CreateHorizontalBox("ID_DOWN_TWATDETAIL", 100,,, "ABAS", "DOWN_TWATDETAIL")
	// Relaciona o identificador (ID) da View com o "box" para sua exibição
	oView:SetOwnerView("VIEW_TWAT", "ID_DOWN_TWATDETAIL")

EndIf

If	aShwAba[DF_SHWFOLDER_OSSIGAMNT]						// Confirma se a aba 'O.S.SIGAMNT' será exibida na View

	// Cria a estrutura a ser usada na View
	// TWA - Itens da indenização (O.S. SIGAMNT)
	oStrTWAM	:= FWFormStruct(2, "TWA", {|cCampo| AllTrim(cCampo)$"TWA_CODSTJ, TWA_NUMSER, TWA_CUSTO, TWA_VLRCOB, TWA_PRODUT, TWA_TES, TWA_BLQAA3, TWA_OBS"})
	// Cria a grid dos Itens da indenização (OS SIGAMNT)
	oView:AddGrid("VIEW_TWAM", oStrTWAM, "TWAMDETAIL")
	// Cria Folders na View
	oView:AddSheet("ABAS", "DOWN_TWAMDETAIL", STR0010)	//"O.S. SIGAMNT"
	// Define a área dos Itens da indenização (O.S. SIGAMNT)
	oView:CreateHorizontalBox("ID_DOWN_TWAMDETAIL", 100,,, "ABAS", "DOWN_TWAMDETAIL")
	// Relaciona o identificador (ID) da View com o "box" para sua exibição
	oView:SetOwnerView("VIEW_TWAM", "ID_DOWN_TWAMDETAIL")

EndIf

If	aShwAba[DF_SHWFOLDER_MOVIMEQUI]						// Confirma se a aba 'Movimentação Equipamentos' será exibida na View

	// Cria a estrutura a ser usada na View
	// TWA - Itens da indenização (Movimentação Equipamentos)
	oStrTWAE	:= FWFormStruct(2, "TWA", {|cCampo| AllTrim(cCampo)$"TWA_CODTFI, TWA_CODTEW, TWA_NUMSER, TWA_VLRCOB, TWA_PRODUT, TWA_TES, TWA_BLQAA3, TWA_OBS, TWA_QTDSEP"})
	//Ordema o campo.
	oStrTWAE:SetProperty('TWA_QTDSEP', MVC_VIEW_ORDEM, "11")
	// Cria a grid dos Itens da indenização (Movimentação Equipamentos)
	oView:AddGrid("VIEW_TWAE", oStrTWAE, "TWAEDETAIL")
	// Cria Folders na View
	oView:AddSheet("ABAS", "DOWN_TWAEDETAIL", STR0011)	//"Movim./Equip."
	// Define a área dos Itens da indenização (Movimentação Equipamentos)
	oView:CreateHorizontalBox("ID_DOWN_TWAEDETAIL", 100,,, "ABAS", "DOWN_TWAEDETAIL")
	// Relaciona o identificador (ID) da View com o "box" para sua exibição
	oView:SetOwnerView("VIEW_TWAE", "ID_DOWN_TWAEDETAIL")

EndIf

If Len(aShwAba) > 3 .AND. aShwAba[DF_SHWFOLDER_OUTRLANCT]	
	// Cria a estrutura a ser usada na View
	// TWA - Itens da indenização (Outros Lançamentos)
	oStrTWAO	:= FWFormStruct(2, "TWA", {|cCampo| AllTrim(cCampo)$"TWA_VLRCOB, TWA_PRODUT, TWA_TES, TWA_OBS, TWA_QTDSEP"})
	oStrTWAO:SetProperty('TWA_PRODUT', MVC_VIEW_ORDEM, "10")
	//Ordema o campo.
	oStrTWAO:SetProperty('TWA_QTDSEP', MVC_VIEW_ORDEM, "11")
	
	oStrTWAO:SetProperty('TWA_QTDSEP', MVC_VIEW_CANCHANGE, .t.)
	
	oStrTWAO:SetProperty('TWA_QTDSEP', MVC_VIEW_TITULO, STR0073) //"Quantidade"
	
	oStrTWAO:SetProperty('TWA_VLRCOB', MVC_VIEW_TITULO, STR0074) //"Vlr Unitario"	
	
	oStrTWAO:SetProperty('TWA_VLRCOB', MVC_VIEW_ORDEM, "13")
	
	// Cria a grid dos Itens da indenização (Outros Lançamentos)
	oView:AddGrid("VIEW_TWAO", oStrTWAO, "TWAODETAIL")
	// Cria Folders na View
	oView:AddSheet("ABAS", "DOWN_TWAODETAIL", STR0072)	//"Outros Lançamentos"
	// Define a área dos Itens da indenização (Outros Lançamentos)
	oView:CreateHorizontalBox("ID_DOWN_TWAODETAIL", 100,,, "ABAS", "DOWN_TWAODETAIL")
	// Relaciona o identificador (ID) da View com o "box" para sua exibição
	oView:SetOwnerView("VIEW_TWAO", "ID_DOWN_TWAODETAIL")

EndIf

// Opções extras da rotina
oView:AddUserButton(STR0031,'BUDGET', {|oModel| At650VsPed(oModel)}) //"Visualizar pedido"
// Identificação (Nomeação) da VIEW
oView:SetDescription(STR0001) // "Processo de indenização"

Return(oView)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At650Vld
@description	Validação na ativação do MODEL
@sample	 	At650Vld(oModel)
@param			oModel		Model
@return		ExpL	.T.=Ativação do MODEL é permitida; .F.=Ativação do MODEL não é permitida
@author		Alexandre da Costa (a.costa)
@since			08/04/2016
@version		P12   
/*/
//------------------------------------------------------------------------------
Static Function At650Vld(oModel)
Local lRet 		:= .T.
Local lFaturar	:= IsInCallStack("At650Faturar")
Local lExcFat		:= IsInCallStack("At650ExcFat")
Local lEncerrar	:= IsInCallStack("At650Encerra")
Local nOperation	:= oModel:GetOperation()

If ! ( nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_VIEW )
	
	If TW9->TW9_STATUS == "3"	//"3"=Encerrado
		Help( , , "At650Vld", , STR0023, 1, 0) //"Processo de indenização encerrado. Permitido somente visualizar o processo."
		lRet	:=	.F.
	
	Elseif TW9->TW9_STATUS == "2" .AND. !lEncerrar .AND. !lFaturar .AND. !lExcFat		//"2"=Faturado
		If nOperation == MODEL_OPERATION_UPDATE
			Help( , , "At650Vld", , STR0043, 1, 0,,,,,,{STR0044}) //"Não é possivel alterar a indenização." ## "Realize o cancelamento do faturamento para alterar a indenização."
		Elseif nOperation == MODEL_OPERATION_DELETE
			Help( , , "At650Vld", , STR0045, 1, 0,,,,,,{STR0046}) // "Não é possivel deletar a indenização" ## "Realize o cancelamento do faturamento para deletar a indenização."
		Endif
		lRet	:=	.F.
	EndIf

Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} At650Actvt
@description	Ativação do MODEL
@sample	 	At650Actvt(oModel)
@param			oModel		Model
@return		NIL
@author		Alexandre da Costa (a.costa)
@since			08/04/2016
@version		P12
/*/
//------------------------------------------------------------------
Static Function At650Actvt(oModel)

Local	lEncerrar			:= IsInCallStack("At650Encerra")
Local	oMdlTW9MASTER		:= oModel:GetModel("TW9MASTER")
Local	oMdlTWATDETAIL	:= oModel:GetModel('TWATDETAIL')
Local	oMdlTWAMDETAIL	:= oModel:GetModel('TWAMDETAIL')
Local	oMdlTWAEDETAIL	:= oModel:GetModel('TWAEDETAIL')
Local	oMdlTWAODETAIL	:= oModel:GetModel('TWAODETAIL')

If	lEncerrar
	oMdlTW9MASTER:LoadValue('TW9_STATUS','3')	//1=Aberta;2=Faturada;3=Encerrada
	oMdlTW9MASTER:SetOnlyView(.T.)
	oMdlTWATDETAIL:SetNoInsertLine(.T.)
	oMdlTWATDETAIL:SetNoUpdateLine(.T.)
	oMdlTWATDETAIL:SetNoDeleteLine(.T.)
	oMdlTWAMDETAIL:SetNoInsertLine(.T.)
	oMdlTWAMDETAIL:SetNoUpdateLine(.T.)
	oMdlTWAMDETAIL:SetNoDeleteLine(.T.)
	oMdlTWAEDETAIL:SetNoInsertLine(.T.)
	oMdlTWAEDETAIL:SetNoUpdateLine(.T.)
	oMdlTWAEDETAIL:SetNoDeleteLine(.T.)
	oMdlTWAODETAIL:SetNoInsertLine(.T.)
	oMdlTWAODETAIL:SetNoUpdateLine(.T.)
	oMdlTWAODETAIL:SetNoDeleteLine(.T.)
EndIf

Return	NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} At650TdOk
@description	Validação final do Model, antes da gravação
@sample	 	At650TdOk(oModel)
@param			oModel		Model
@return		ExpL	.T.=Gravação permitida, .F.=Gravação não permitida
@author		Alexandre da Costa (a.costa)
@since			08/04/2016
@version		P12
/*/
//------------------------------------------------------------------
Function At650TdOk(oModel)

Local	cOldAlias			:= If( !( Empty(Alias()) ), Alias(), "")
Local	aOldAlias			:= If( !( Empty(cOldAlias) ), (cOldAlias)->(GetArea()), {})
Local	oMdlTW9MASTER		:= oModel:GetModel("TW9MASTER")
Local	oMdlTWATDETAIL	:= oModel:GetModel('TWATDETAIL')
Local	oMdlTWAMDETAIL	:= oModel:GetModel('TWAMDETAIL')
Local	oMdlTWAEDETAIL	:= oModel:GetModel('TWAEDETAIL')
Local	oMdlTWAODETAIL	:= oModel:GetModel('TWAODETAIL')
Local	lTWATEmpty			:= oMdlTWATDETAIL:IsEmpty()	// Grid vazia?
Local	lTWAMEmpty			:= oMdlTWAMDETAIL:IsEmpty()	// Grid vazia?
Local	lTWAEEmpty			:= oMdlTWAEDETAIL:IsEmpty()	// Grid vazia?
Local	lTWAOEmpty			:= oMdlTWAODETAIL:IsEmpty()	// Grid vazia?
Local	cTW9Codigo			:= oMdlTW9MASTER:GetValue("TW9_CODIGO")
Local	cCodAB6			:= ""
Local	cCodAB7			:= ""
Local	cCodSTJ			:= ""
Local	cNewAlias			:= ""
Local	cTitCodAB6			:= ""
Local	cTitCodAB7			:= ""
Local	cTitCodSTJ			:= ""
Local	cMsgShwLog			:= ""
Local	nTWATotLin			:= 0
Local	nX					:= 0
Local	lRet				:= .T.

SX3->(DbSetOrder(2))			// X3_CAMPO
SX3->(DbSeek("TWA_CODAB6"))
cTitCodAB6	:=	AllTrim( X3Titulo() )
SX3->(DbSeek("TWA_CODAB7"))
cTitCodAB7	:=	AllTrim( X3Titulo() )
SX3->(DbSeek("TWA_CODSTJ"))
cTitCodSTJ	:=	AllTrim( X3Titulo() )
SX3->(DbSetOrder(1))			// X3_ARQUIVO+X3_ORDEM

If	lTWATEmpty .AND. lTWAMEmpty .AND. lTWAEEmpty .AND. lTWAOEmpty

	Help( , , "At650TdOk", , STR0021, 1, 0,,,,,,{STR0022}) //"Não foram informadas quaisquer ordens de serviços e/ou equipamentos para o processo de indenização." ## "Informe, ao menos, uma ordem de serviço e/ou equipamento para possibilitar a gravação do processo de indenização."
	lRet		:= .F.

Else

	If !( lTWATEmpty )
		nTWATotLin := oMdlTWATDETAIL:Length()
		For nX := 1 To nTWATotLin

			oMdlTWATDETAIL:GoLine(nX)
			cCodAB6	:= oMdlTWATDETAIL:GetValue("TWA_CODAB6")
			cCodAB7	:= oMdlTWATDETAIL:GetValue("TWA_CODAB7")
			cNewAlias	:= GetNextAlias()

			BeginSql Alias cNewAlias

			   SELECT 'S' AS WASFOUND, TW9.TW9_CODIGO
			     FROM %Table:TW9% TW9
			    INNER JOIN %Table:TWA% TWA ON TWA.TWA_FILIAL = %xFilial:TWA% 
			                               AND TWA.%NotDel%
			                               AND TWA.TWA_TPOS = '1'
			                               AND TWA.TWA_CODTW9 = TW9.TW9_CODIGO
			                               AND TWA.TWA_CODAB6 = %Exp:cCodAB6%
			                               AND TWA.TWA_CODAB7 = %Exp:cCodAB7%
			    WHERE TW9.TW9_FILIAL = %xFilial:TW9%
			      AND TW9.%NotDel%
			      AND TW9.TW9_CODIGO <> %Exp:cTW9Codigo%
			      AND TW9.TW9_STATUS IN ('1','2')

			EndSql

			DbSelectArea(cNewAlias)
			If (cNewAlias)->(! Eof() )
				cMsgShwLog	+= If(Empty(cMsgShwLog),STR0054+CRLF+CRLF,"")	//"As O.S.SIGATEC abaixo relacionadas já estão cadastradas num outro processo de indenização."
				cMsgShwLog	+= cTitCodAB6 + ": '" + AllTrim(cCodAB6) + "' " + cTitCodAB7 + ": '" + cCodAB7 + "' " + STR0055 + " '" + (cNewAlias)->TW9_CODIGO + "'" + CRLF	//"Esta O.S. foi encontrada no processo de indenização:"
				lRet		:= .F.
			EndIf
			(cNewAlias)->(DbCloseArea())
			If	!( Empty(cOldAlias) )
				DbSelectArea(cOldAlias)
			EndIf
			
		Next nX
	Endif

	If	!Empty(cMsgShwLog)
		cMsgShwLog	+= CRLF+CRLF
	EndIf
	
	If !( lTWAMEmpty )
		nTWATotLin := oMdlTWAMDETAIL:Length()
		For nX := 1 To nTWATotLin

			oMdlTWAMDETAIL:GoLine(nX)
			cCodSTJ	:= oMdlTWAMDETAIL:GetValue("TWA_CODSTJ")
			cNewAlias	:= GetNextAlias()

			BeginSql Alias cNewAlias

			   SELECT 'S' AS WASFOUND, TW9.TW9_CODIGO
			     FROM %Table:TW9% TW9
			    INNER JOIN %Table:TWA% TWA ON TWA.TWA_FILIAL = %xFilial:TWA% 
			                               AND TWA.%NotDel%
			                               AND TWA.TWA_TPOS = '2'
			                               AND TWA.TWA_CODTW9 = TW9.TW9_CODIGO
			                               AND TWA.TWA_CODSTJ = %Exp:cCodSTJ%
			    WHERE TW9.TW9_FILIAL = %xFilial:TW9%
			      AND TW9.%NotDel%
			      AND TW9.TW9_CODIGO <> %Exp:cTW9Codigo%
			      AND TW9.TW9_STATUS IN ('1','2')

			EndSql

			DbSelectArea(cNewAlias)
			If (cNewAlias)->(! Eof() )
				cMsgShwLog	+= If(Empty(cMsgShwLog),STR0056+CRLF+CRLF,"")	//"As O.S.SIGAMNT abaixo relacionadas já estão cadastradas num outro processo de indenização."
				cMsgShwLog	+= cTitCodSTJ + ": '" + AllTrim(cCodSTJ) + "' " + STR0055 + " '" + (cNewAlias)->TW9_CODIGO + "'" + CRLF	//"Esta O.S. foi encontrada no processo de indenização:"
				lRet		:= .F.
			EndIf
			(cNewAlias)->(DbCloseArea())
			If	!( Empty(cOldAlias) )
				DbSelectArea(cOldAlias)
			EndIf
			
		Next nX
	Endif

	If	!Empty(cMsgShwLog)
		AtShowLog(cMsgShwLog,STR0001,,,,.F.)	// "Processo de indenização"
		Help( , , "At650TdOk", , STR0057, 1, 0,,,,,,{STR0058})	//	"Não é permitido cadastrar uma mesma O.S. em mais de um processo de indenização que esteja classificado com o status 'EM ABERTO' ou 'FATURADO'" ## "Elimine, neste processo de indenização, as O.S. que se encontram relacionadas em outro processo de indenização 'EM ABERTO' e/ou 'FATURADO'"
	EndIf
EndIf
If	!( Empty(cOldAlias) )
	(cOldAlias)->(RestArea(aOldAlias))
EndIf
Return	lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} At650FtTEW
@description	Consulta especifica TEW
@sample	 	At650FtTEW()
@param			Nenhum
@return		ExpL	.T.=Confirmou a seleção do registro, .F.=Cancelou a seleção do registro
@author		Alexandre da Costa (a.costa)
@since			06/04/2016
@version		P12
/*/
//------------------------------------------------------------------
Function At650FtTEW()

Local	oModel		:= FWModelActive()
Local	oView		:= FwViewActive()
Local	cTEWCodEqu	:= oModel:GetModel('TWAEDETAIL'):GetValue("TWA_CODTFI")
Local	cNxtAliTEW	:= GetNextAlias()
Local	lRet		:= .F.
Local	nTamCodMV	:= 0
Local	nSuperior	:= 0
Local	nEsquerda	:= 0
Local	nInferior	:= 460
Local	nDireita	:= 800
Local	oBrowse	:= Nil
Local	oDlgTela	:= Nil
Local	cTEWQry	:= ""
Local	cTitFilial	:= ""
Local	cTitCodMV	:= ""
Local	cTitProdut	:= ""
Local	cTitDesc	:= ""
Local	cTitBaAtd	:= ""
Local	cTitMotivo	:= ""
Local	cTitObsMNT	:= ""
Local	cTitEQ3	:= ""
Local	aOldSX3	:= SX3->(GetArea())
Local	aIndex		:= {"TEW_CODMV"}		// Definição do índice da Consulta Padrão
Local	aSeek		:= {}					// Definição da Descrição da Chave de Pesquisa da Consulta Padrão
Local 	cTitSep		:= ""

SX3->(DbSetOrder(2))			// X3_CAMPO
SX3->(DbSeek("TEW_FILIAL"))
cTitFilial	:=	X3Titulo()
SX3->(DbSeek("TEW_CODMV"))
cTitCodMV	:=	X3Titulo()
aAdd(aSeek,{STR0017,{{STR0017,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"",,}}})	//"Mov. Equip. Locação"#"Mov. Equip. Locação"
nTamCodMV	:=	SX3->X3_TAMANHO
SX3->(DbSeek("TEW_PRODUT"))
cTitProdut	:=	X3Titulo()
SX3->(DbSeek("B1_DESC"))
cTitDesc	:=	X3Titulo()
SX3->(DbSeek("TEW_BAATD"))
cTitBaAtd	:=	X3Titulo()
SX3->(DbSeek("TEW_MOTIVO"))
cTitMotivo	:=	X3Titulo()
SX3->(DbSeek("TEW_OBSMNT"))
cTitObsMNT	:=	X3Titulo()
SX3->(DbSeek("AA3_EQ3"))
cTitEQ3	:=	X3Titulo()
SX3->(DbSeek("TEW_QTDVEN"))
cTitSep	:=	X3Titulo()
SX3->(DbSetOrder(1))			// X3_ARQUIVO+X3_ORDEM

cRetFtTEW := Space(nTamCodMV)

cTEWQry := " SELECT TEW.TEW_FILIAL, TEW.TEW_CODMV, TEW.TEW_PRODUT, SB1.B1_DESC, TEW.TEW_BAATD, TEW.TEW_MOTIVO, TEW.TEW_OBSMNT, AA3.AA3_EQ3, TEW.TEW_QTDVEN  " + CRLF
cTEWQry += "   FROM " + RetSqlName("TEW") + " TEW "+CRLF
cTEWQry += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON " + RetSqlCond("SB1") + " AND SB1.B1_COD = TEW.TEW_PRODUT " + CRLF
cTEWQry += "  INNER JOIN " + RetSqlName("AA3") + " AA3 ON " + RetSqlCond("AA3") + " AND AA3.AA3_NUMSER = TEW.TEW_BAATD " + CRLF
cTEWQry += " WHERE " + RetSqlCond("TEW") + CRLF
cTEWQry += " AND TEW.TEW_CODEQU = '" + cTEWCodEqu + "' "

DEFINE MSDIALOG oDlgTela TITLE STR0017 FROM nSuperior, nEsquerda TO nInferior, nDireita PIXEL	//"Mov. Equip. Locação"
 
oBrowse := FWFormBrowse():New()
oBrowse:SetDescription(STR0017) // "Mov. Equip. Locação"
oBrowse:SetAlias(cNxtAliTEW)
oBrowse:SetDataQuery()
oBrowse:SetQuery(cTEWQry)
oBrowse:SetOwner(oDlgTela)
oBrowse:SetDoubleClick({|| lRet := .T., cRetFtTEW := (oBrowse:Alias())->TEW_CODMV, oDlgTela:End()})
oBrowse:AddButton( OemTOAnsi(STR0018), {|| lRet := .T., cRetFtTEW := (oBrowse:Alias())->TEW_CODMV, oDlgTela:End()},, 2 ) //"Confirmar"
oBrowse:AddButton( OemTOAnsi(STR0019), {|| lRet := .F., cRetFtTEW := Space(Len((oBrowse:Alias())->TEW_CODMV)), oDlgTela:End()},, 2 ) //"Cancelar"
oBrowse:DisableDetails()
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetSeek({||.T.},aSeek)

ADD COLUMN oColumn DATA {|| TEW_FILIAL} TITLE cTitFilial SIZE 15 OF oBrowse	//"Filial"
ADD COLUMN oColumn DATA {|| TEW_CODMV}  TITLE cTitCodMV  SIZE 15 OF oBrowse	//"Cod Moviment"
ADD COLUMN oColumn DATA {|| TEW_PRODUT} TITLE cTitProdut SIZE 15 OF oBrowse	//"Produto"
ADD COLUMN oColumn DATA {|| B1_DESC}    TITLE cTitDesc   SIZE 15 OF oBrowse	//"Descricao"
ADD COLUMN oColumn DATA {|| TEW_BAATD}  TITLE cTitBaAtd  SIZE 15 OF oBrowse	//"Base Atend."
ADD COLUMN oColumn DATA {|| TEW_MOTIVO} TITLE cTitMotivo SIZE 15 OF oBrowse	//"Situação"
ADD COLUMN oColumn DATA {|| TEW_OBSMNT} TITLE cTitObsMNT SIZE 15 OF oBrowse	//"Obs. Mnt."
ADD COLUMN oColumn DATA {|| AA3_EQ3}    TITLE cTitEQ3    SIZE 15 OF oBrowse	//"Eq. Terceiro"
ADD COLUMN oColumn DATA {|| TEW_QTDVEN} TITLE cTitSep  	 SIZE 15 OF oBrowse	//"Quantidade"

oBrowse:Activate()
ACTIVATE MSDIALOG oDlgTela CENTERED
oView:Refresh()

SX3->( RestArea(aOldSX3) )
Return( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} At650RtTEW
@description	Retorno da consulta especifica TEW
@sample	 	At650RtTEW()
@param			Nenhum
@return		ExpC	Código do movimento de locação da tabela TEW
@author		Alexandre da Costa (a.costa)
@since			06/04/2016
@version		P12
/*/
//------------------------------------------------------------------
Function At650RtTEW()

Return cRetFtTEW


//-------------------------------------------------------------------
/*/{Protheus.doc} At650FtAB7
@description	Consulta especifica AB7
@sample	 	At650FtAB7()
@param			Nenhum
@return		ExpL	.T.=Confirmou a seleção do registro, .F.=Cancelou a seleção do registro
@author		Alexandre da Costa (a.costa)
@since			08/04/2016
@version		P12
/*/
//------------------------------------------------------------------
Function At650FtAB7()

Local	oModel		:= FWModelActive()
Local	oView		:= FwViewActive()
Local	cAB7NumOS	:= oModel:GetModel('TWATDETAIL'):GetValue("TWA_CODAB6")
Local	cNxtAliAB7	:= GetNextAlias()
Local	lRet		:= .F.
Local	nTamItem	:= 0
Local	nSuperior	:= 0
Local	nEsquerda	:= 0
Local	nInferior	:= 460
Local	nDireita	:= 800
Local	oBrowse	:= Nil
Local	oDlgTela	:= Nil
Local	cAB7Qry	:= ""
Local	cTitFilial	:= ""
Local	cTitNumOS	:= ""
Local	cTitItem	:= ""
Local	cTitProdut	:= ""
Local	cTitNumSer	:= ""
Local	aOldSX3	:= SX3->(GetArea())
Local	aIndex		:= {"AB7_NUMOS"}		// Definição do índice da Consulta Padrão
Local	aSeek		:= {}					// Definição da Descrição da Chave de Pesquisa da Consulta Padrão

SX3->(DbSetOrder(2))			// X3_CAMPO
SX3->(DbSeek("AB7_FILIAL"))
cTitFilial	:=	X3Titulo()
SX3->(DbSeek("AB7_NUMOS"))
cTitNumOS	:=	X3Titulo()
SX3->(DbSeek("AB7_ITEM"))
cTitItem	:=	X3Titulo()
aAdd(aSeek,{STR0020,{{STR0020,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"",,}}})	//"Itens das ordens de serviços"#"Itens das ordens de serviços"
nTamItem	:=	SX3->X3_TAMANHO
SX3->(DbSeek("AB7_CODPRO"))
cTitProdut	:=	X3Titulo()
SX3->(DbSeek("AB7_NUMSER"))
cTitNumSer	:=	X3Titulo()
SX3->(DbSetOrder(1))			// X3_ARQUIVO+X3_ORDEM

cRetFtAB7 := Space(nTamItem)

cAB7Qry := " SELECT AB7.AB7_FILIAL, AB7.AB7_NUMOS, AB7.AB7_ITEM, AB7.AB7_CODPRO, AB7.AB7_NUMSER " + CRLF
cAB7Qry += "   FROM " + RetSqlName("AB7") + " AB7 "+CRLF
cAB7Qry += "  INNER JOIN " + RetSqlName("AB6") + " AB6 ON " + RetSqlCond("AB6") + " AND AB6.AB6_NUMOS = AB7.AB7_NUMOS " + CRLF
cAB7Qry += " WHERE " + RetSqlCond("AB7") + CRLF
cAB7Qry += " AND AB7.AB7_NUMOS = '" + cAB7NumOS + "' " + CRLF
cAB7Qry += " ORDER BY AB7.AB7_FILIAL, AB7.AB7_NUMOS, AB7.AB7_ITEM "

DEFINE MSDIALOG oDlgTela TITLE STR0020 FROM nSuperior, nEsquerda TO nInferior, nDireita PIXEL	//"Itens das ordens de serviços"
 
oBrowse := FWFormBrowse():New()
oBrowse:SetDescription(STR0020) // "Itens das ordens de serviços"
oBrowse:SetAlias(cNxtAliAB7)
oBrowse:SetDataQuery()
oBrowse:SetQuery(cAB7Qry)
oBrowse:SetOwner(oDlgTela)
oBrowse:SetDoubleClick({|| lRet := .T., cRetFtAB7 := (oBrowse:Alias())->AB7_ITEM, oDlgTela:End()})
oBrowse:AddButton( OemTOAnsi(STR0018), {|| lRet := .T., cRetFtAB7 := (oBrowse:Alias())->AB7_ITEM, oDlgTela:End()},, 2 ) //"Confirmar"
oBrowse:AddButton( OemTOAnsi(STR0019), {|| lRet := .F., cRetFtAB7 := Space(Len((oBrowse:Alias())->AB7_ITEM)), oDlgTela:End()},, 2 ) //"Cancelar"
oBrowse:DisableDetails()
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetSeek({||.T.},aSeek)

ADD COLUMN oColumn DATA {|| AB7_FILIAL} TITLE cTitFilial SIZE 15 OF oBrowse	//"Filial"
ADD COLUMN oColumn DATA {|| AB7_NUMOS}  TITLE cTitNumOS  SIZE 15 OF oBrowse	//"O.S."
ADD COLUMN oColumn DATA {|| AB7_ITEM}   TITLE cTitItem   SIZE 15 OF oBrowse	//"Item"
ADD COLUMN oColumn DATA {|| AB7_CODPRO} TITLE cTitProdut SIZE 15 OF oBrowse	//"Produto/Eqto"
ADD COLUMN oColumn DATA {|| AB7_NUMSER} TITLE cTitNumSer SIZE 15 OF oBrowse	//"Id.Unico"

oBrowse:Activate()
ACTIVATE MSDIALOG oDlgTela CENTERED
oView:Refresh()

SX3->( RestArea(aOldSX3) )
Return( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} At650RtAB7
@description	Retorno da consulta especifica AB7
@sample		At650RtAB7()
@param			Nenhum
@return		ExpC	Código do item da OS da tabela AB7
@author		Alexandre da Costa (a.costa)
@since			08/04/2016
@version		P12
/*/
//------------------------------------------------------------------
Function At650RtAB7()

Return cRetFtAB7


//-------------------------------------------------------------------
/*/{Protheus.doc} At650FtABS
@description	Consulta especifica ABS
@sample	 	At650FtABS()
@param			Nenhum
@return		ExpL	.T.=Confirmou a seleção do registro, .F.=Cancelou a seleção do registro
@author		Alexandre da Costa (a.costa)
@since			19/04/2016
@version		P12
/*/
//------------------------------------------------------------------
Function At650FtABS()

Local	oModel		:= FWModelActive()
Local	oView		:= FwViewActive()
Local	cTW9Contrt	:= oModel:GetModel('TW9MASTER'):GetValue("TW9_CONTRT")
Local	cNxtAliABS	:= GetNextAlias()
Local	lRet		:= .F.
Local	nTamLocal	:= 0
Local	nSuperior	:= 0
Local	nEsquerda	:= 0
Local	nInferior	:= 460
Local	nDireita	:= 800
Local	oBrowse	:= Nil
Local	oDlgTela	:= Nil
Local	cABSQry	:= ""
Local	cTitFilial	:= ""
Local	cTitLocal	:= ""
Local	cTitDescri	:= ""
Local	cTitCCusto	:= ""
Local	cTitRegiao	:= ""
Local	cTitLocPai	:= ""
Local	aOldSX3	:= SX3->(GetArea())
Local	aIndex		:= {"ABS_LOCAL"}		// Definição do índice da Consulta Padrão
Local	aSeek		:= {}					// Definição da Descrição da Chave de Pesquisa da Consulta Padrão

SX3->(DbSetOrder(2))			// X3_CAMPO
SX3->(DbSeek("ABS_FILIAL"))
cTitFilial	:=	X3Titulo()
SX3->(DbSeek("ABS_LOCAL"))
cTitLocal	:=	X3Titulo()
aAdd(aSeek,{STR0060,{{STR0060,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"",,}}})	//"Local de atendimento"#"Local de atendimento"
nTamLocal	:=	SX3->X3_TAMANHO
SX3->(DbSeek("ABS_DESCRI"))
cTitDescri	:=	X3Titulo()
SX3->(DbSeek("ABS_CCUSTO"))
cTitCCusto	:=	X3Titulo()
SX3->(DbSeek("ABS_REGIAO"))
cTitRegiao	:=	X3Titulo()
SX3->(DbSeek("ABS_LOCPAI"))
cTitLocPai	:=	X3Titulo()
SX3->(DbSetOrder(1))			// X3_ARQUIVO+X3_ORDEM

cRetFtABS := Space(nTamLocal)

cABSQry := " SELECT DISTINCT ABS.ABS_FILIAL, ABS.ABS_LOCAL, ABS.ABS_DESCRI, ABS.ABS_CCUSTO, ABS.ABS_REGIAO, ABS.ABS_LOCPAI " + CRLF
cABSQry += "   FROM " + RetSqlName("ABS") + " ABS, "
cABSQry += RetSqlName("TFL") + " TFL "
cABSQry += "  WHERE " + RetSqlCond("ABS") + CRLF
cABSQry += "  AND  " + RetSqlCond("TFL") + CRLF
cABSQry += "  AND TFL.TFL_LOCAL = ABS.ABS_LOCAL " + CRLF
cABSQry += "  AND TFL.TFL_CONTRT = '"+cTW9Contrt+"' " + CRLF
cABSQry += "  ORDER BY ABS.ABS_FILIAL, ABS.ABS_LOCAL "

DEFINE MSDIALOG oDlgTela TITLE STR0061 FROM nSuperior, nEsquerda TO nInferior, nDireita PIXEL	//"Locais de atendimento do contrato"
 
oBrowse := FWFormBrowse():New()
oBrowse:SetDescription(STR0060) // "Local de atendimento"
oBrowse:SetAlias(cNxtAliABS)
oBrowse:SetDataQuery()
oBrowse:SetQuery(cABSQry)
oBrowse:SetOwner(oDlgTela)
oBrowse:SetDoubleClick({|| lRet := .T., cRetFtABS := (oBrowse:Alias())->ABS_LOCAL, oDlgTela:End()})
oBrowse:AddButton( OemTOAnsi(STR0018), {|| lRet := .T., cRetFtABS := (oBrowse:Alias())->ABS_LOCAL, oDlgTela:End()},, 2 ) //"Confirmar"
oBrowse:AddButton( OemTOAnsi(STR0019), {|| lRet := .F., cRetFtABS := Space(Len((oBrowse:Alias())->ABS_LOCAL)), oDlgTela:End()},, 2 ) //"Cancelar"
oBrowse:DisableDetails()
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetSeek({||.T.},aSeek)

ADD COLUMN oColumn DATA {|| ABS_FILIAL} TITLE cTitFilial SIZE 15 OF oBrowse	//"Filial"
ADD COLUMN oColumn DATA {|| ABS_LOCAL}  TITLE cTitLocal  SIZE 15 OF oBrowse	//"Local"
ADD COLUMN oColumn DATA {|| ABS_DESCRI} TITLE cTitDescri SIZE 15 OF oBrowse	//"Descrição"
ADD COLUMN oColumn DATA {|| ABS_CCUSTO} TITLE cTitCCusto SIZE 15 OF oBrowse	//"Centro de custo"
ADD COLUMN oColumn DATA {|| ABS_REGIAO} TITLE cTitRegiao SIZE 15 OF oBrowse	//"Região"
ADD COLUMN oColumn DATA {|| ABS_LOCPAI} TITLE cTitLocPai SIZE 15 OF oBrowse	//"Local pai"

oBrowse:Activate()
ACTIVATE MSDIALOG oDlgTela CENTERED
oView:Refresh()

SX3->( RestArea(aOldSX3) )
Return( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} At650RtABS
@description	Retorno da consulta especifica ABS
@sample		At650RtABS()
@param			Nenhum
@return		ExpC	Código do item da OS da tabela ABS
@author		Alexandre da Costa (a.costa)
@since			19/04/2016
@version		P12
/*/
//------------------------------------------------------------------
Function At650RtABS()

Return cRetFtABS


//------------------------------------------------------------------------------
/*/{Protheus.doc} At650Faturar
@description	Função responsável por Faturar a Idenização.
@sample		At650Faturar()
@param			Nenhum
@return		NIL
@author		Kaique Schiller
@since			04/04/2016       
@version		P12   
/*/
//------------------------------------------------------------------------------
Function At650Faturar(nAuto)
Local oModelo 	:= Nil
Local oMdlInde	:= Nil
Local oGridItem	:= Nil
Local lRet 		:= .T.
Local cMemoLog	:= ""
Local cAgpPed	:= ""
Local aGridItem	:= {}
Local aVldInde	:= {}
Local aVldItem	:= {}
Local nX		:= 0
Local nZ		:= 0
Local nK		:= 0
Local nY		:= 0
Local lPasta	:= .T.
Local lChave	:= .T.
Local nContGrid	:= 0
Local nTWATotLin:= 0
Local nContVld	:= 0

Default nAuto := 0

nOpcAuto := nAuto

If TW9->TW9_STATUS == "1" //Quando estiver em aberto.
	
	oModelo := FWLoadModel("TECA650")	
	oModelo:SetOperation(MODEL_OPERATION_UPDATE)
	oModelo:Activate()
		
	oMdlInde := oModelo:GetModel("TW9MASTER")

	cAgpPed  := oMdlInde:GetValue("TW9_AGPPED")
	
	//Separando campos a serem verificados.
	aAdd(aVldInde,"TW9_CLIENT")
	aAdd(aVldInde,"TW9_CLILOJ")
	aAdd(aVldInde,"TW9_CONDPG")
	aAdd(aVldItem,"TWA_VLRCOB")
	
	If cAgpPed == "1"
		aAdd(aVldInde,"TW9_PRODUT")
		aAdd(aVldInde,"TW9_TES")
		
	Elseif cAgpPed == "2"
		aAdd(aVldItem,"TWA_PRODUT")
		aAdd(aVldItem,"TWA_TES")
	
	Endif

	nContVld := Len(aVldInde)

	//Valida os campos do cabeçalho
	For nX := 1 To nContVld
		If Empty(oMdlInde:GetValue(aVldInde[nX]))
			cMemoLog += aVldInde[nX]+CRLF
			lRet 	 := .F.
		Endif
	Next nX
	
	If !Empty(aVldItem)
	
		aAdd( aGridItem, {"TWATDETAIL"}) //1 = SIGATEC
		aAdd( aGridItem, {"TWAMDETAIL"}) //2 = SIGAMNT
		aAdd( aGridItem, {"TWAEDETAIL"})
		aAdd( aGridItem, {"TWAODETAIL"}) //3 = Outras Movimentações
			
		nContGrid := Len(aGridItem)
		
		For nK := 1 To nContGrid
		
			oGridItem := oModelo:GetModel(aGridItem[nK,1])
			nTWATotLin := oGridItem:Length()
			For nY := 1 To nTWATotLin
				oGridItem:GoLine(nY)
				//Valida o campos dos itens.
				For nZ := 1 To Len(aVldItem)
					If Empty(oGridItem:GetValue(aVldItem[nZ]))
						//Inserindo pasta.
						If oGridItem:GetValue("TWA_TPOS") == "1" .AND. !Empty(oGridItem:GetValue("TWA_CODAB6"))
							If lPasta
								cMemoLog += CRLF+STR0009+CRLF
								lPasta := .F.
							Endif
							//Inserindo chave para localização do registro.
							If lChave
								cMemoLog += CRLF+Alltrim(TxSX3Campo("TWA_CODAB6")[1])+": ";
											+oGridItem:GetValue("TWA_CODAB6")+CRLF
											
								cMemoLog += Alltrim(TxSX3Campo("TWA_CODAB7")[1])+": ";
											+oGridItem:GetValue("TWA_CODAB7")+CRLF+CRLF
								lChave := .F.
							Endif
	
						ElseIf oGridItem:GetValue("TWA_TPOS") == "2" .AND. !Empty(oGridItem:GetValue("TWA_CODSTJ"))
							If lPasta
								cMemoLog += CRLF+STR0010+CRLF
								lPasta := .F.
							Endif
							If lChave 
								cMemoLog += CRLF+Alltrim(TxSX3Campo("TWA_CODSTJ")[1])+": ";
											+oGridItem:GetValue("TWA_CODSTJ")+CRLF
											
								cMemoLog += Alltrim(TxSX3Campo("TWA_CODTFI")[1])+": ";
											+oGridItem:GetValue("TWA_CODTFI")+CRLF+CRLF
								lChave := .F.
							Endif
						ElseIf oGridItem:GetValue("TWA_TPOS") == "3" .AND. !Empty(oGridItem:GetValue("TWA_PRODUT"))
							If lPasta
								cMemoLog += CRLF+STR0072+CRLF //"Outros Lançamentos"
								lPasta := .F.
							Endif
							If lChave 
								cMemoLog += CRLF+Alltrim(TxSX3Campo("TWA_PRODUT")[1])+": ";
											+oGridItem:GetValue("TWA_PRODUT")+CRLF

								lChave := .F.
							Endif
						Elseif Empty(oGridItem:GetValue("TWA_TPOS")) .AND. !Empty(oGridItem:GetValue("TWA_CODTEW"))
							If lPasta
								cMemoLog += CRLF+STR0011+CRLF
								lPasta := .F.
							Endif
							If lChave
								cMemoLog += CRLF+Alltrim(TxSX3Campo("TWA_CODTEW")[1])+": ";
											+oGridItem:GetValue("TWA_CODTEW")+CRLF
											
								cMemoLog += Alltrim(TxSX3Campo("TWA_NUMSER")[1])+": ";
											+oGridItem:GetValue("TWA_NUMSER")+CRLF+CRLF
								lChave := .F.
							Endif
						Endif
						If !lChave
							//Indicando o campo que esta vazio.
							cMemoLog += aVldItem[nZ]+CRLF
							lRet 	 := .F.
						Endif
					Endif
				Next nZ
				lChave := .T.
			Next nY
			lPasta := .T.
		Next nK
	Endif
	
	If lRet
	
		oMdlInde:SetValue("TW9_STATUS","2")		//1=Aberta;2=Faturada;3=Encerrada
		oModelo:GetModel("TW9MASTER"):SetOnlyView(.T.)
	
		For nX := 1 To nContGrid
			oModelo:GetModel(aGridItem[nX,1]):SetNoInsertLine()
			oModelo:GetModel(aGridItem[nX,1]):SetNoUpdateLine()
			oModelo:GetModel(aGridItem[nX,1]):SetNoDeleteLine()
		Next
		//Tratativa para executar via Robô
		If !IsBlind()
			FWExecView(STR0024,"TECA650",MODEL_OPERATION_UPDATE,,{|| .T.},,,,,,,oModelo) //"Faturar"
		EndIf
	Else
		cMemoLog := (STR0025 + CRLF+CRLF) += cMemoLog //"Os campos da Indenização estão em branco:"
		AtShowLog(cMemoLog,STR0026,,,,.F.)	//"Faturamento da indenização"
		Help(,, "At650Faturar",,STR0027,1,0,,,,,,{STR0028}) //"Preenchimento dos campos em branco" ## "Realize o prechimento dos campos informados."
		oModelo:DeActivate()
		oModelo:Destroy()
	Endif
Else
	Help(,, "At650Faturar",,STR0029,1,0,,,,,,{STR0030}) //"Não é possivel realizar o faturamento." ## "É necessario que a indenização esteja em aberto."
Endif

Return oModelo


//-------------------------------------------------------------------
/*/{Protheus.doc} At650Encerra
@description	Realiza o encerramento da indenização
@sample		At650Encerra()
@param			Nenhum
@return		NIL
@author		Alexandre da Costa (a.costa)
@since			08/04/2016
@version		P12
/*/
//------------------------------------------------------------------
Function At650Encerra(nAuto)

Local oModel := Nil

Default nAuto := 0

nOpcAuto := nAuto

If TW9->TW9_STATUS == "1"	//"1"=Em aberto
	
	If !IsBlind()
		FWExecView(STR0008,"TECA650",MODEL_OPERATION_UPDATE,,{|| .T.},,,,,,,)	//"Encerrar"
	Else
		oModel := FwLoadModel('TECA650')
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()
	EndIf
Else	
	lRet := .F.
	Help(,, "At650Encerra",,STR0047,1,0,,,,,,{STR0030}) //"Não é possivel realizar o encerramento." ## "É necessario que a indenização esteja em aberto."	
Endif

Return	oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} At650Docum
@description	Acessa o banco de conhecimento
@sample		At650Docum(cAlias,cCampo,nOpc)
@param			cAlias		Alias da tabela ativo
@param			cCampo		Posição campo
@param			nOpc		Opção do menu
@return		NIL
@author		Alexandre da Costa (a.costa)
@since			06/04/2016
@version		P12
/*/
//------------------------------------------------------------------
Function At650Docum(cAlias,cCampo,nOpc)
//Variáveis adicionadas devido a suas utilizações na função MsDocument.
Private	aRotina	:= MenuDef()
Private	cCadastro	:= STR0013	//"Documentos"

MsDocument(cAlias, (cAlias)->(Recno()), 1)
Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} At650Commit
@description	Efetivação da gravação das informações do Model na base de dados
@sample	 	At650Commit(oModel)
@param			oModel		Model
@return		ExpL	.T.=Gravação com sucesso, .F.=Gravação sem sucesso
@author		Kaique Schiller
@since			08/04/2016
@version		P12
/*/
//------------------------------------------------------------------
Static Function At650Commit(oModel)

Local	cOldAlias		:= If( !( Empty(Alias()) ), Alias(), "")
Local	aOldAlias		:= If( !( Empty(cOldAlias) ), (cOldAlias)->(GetArea()), {})
Local	aOldAA3			:= AA3->(GetArea())
Local	oMdlTW9MASTER	:= oModel:GetModel("TW9MASTER")
Local	oMdlTWADETAIL	:= NIL
Local	lEncerrar		:= IsInCallStack("At650Encerra")
Local	lFaturar		:= IsInCallStack("At650Faturar")
Local 	lExcFat			:= IsInCallStack("At650ExcFat")
Local	aPedCabec		:= {}
Local	aPedItens		:= {}
Local	aGridItem		:= {}
Local	xAux			:= {}
Local	nLin			:= 0
Local	nY				:= 0
Local	nX				:= 0
Local	nValPed			:= 0
Local	nOpcx			:= 3
Local	nTWATotLin		:= 0
Local	cItem			:= ""
Local	cAgpPed			:= ""
Local	lRet			:= .T.
Local 	nContGrid		:= 0
Local 	nOperation 		:= oModel:GetOperation()
Local	nQtdSep				:= 1
Local 	nValUni			:= 0
Local   nQtde			:= 0

Private	lMsErroAuto	:= .F.

//Variáveis utilizadas para controle do robô
If IsBlind() 
	lEncerrar := (nOpcAuto == 1)
	lFaturar  := (nOpcAuto == 2)
	lExcFat   := (nOpcAuto == 3)
EndIf

aAdd( aGridItem, "TWATDETAIL")
aAdd( aGridItem, "TWAMDETAIL")
aAdd( aGridItem, "TWAEDETAIL")
aAdd( aGridItem, "TWAODETAIL")

nContGrid := Len(aGridItem)

If lFaturar
	cItem := StrZero(0,TAMSX3("C6_ITEM")[1])
	//Monta o cabeçalho do pedido
	aAdd( aPedCabec, {"C5_TIPO",    "N",                                  Nil } )
	aAdd( aPedCabec, {"C5_CLIENTE", oMdlTW9MASTER:GetValue("TW9_CLIENT"), Nil } )
	aAdd( aPedCabec, {"C5_LOJACLI", oMdlTW9MASTER:GetValue("TW9_CLILOJ"), Nil } )
	aAdd( aPedCabec, {"C5_CONDPAG", oMdlTW9MASTER:GetValue("TW9_CONDPG"), Nil } )
	aAdd( aPedCabec, {"C5_NATUREZ", oMdlTW9MASTER:GetValue("TW9_NATCOB"), Nil } )
	ABS->(DbSetOrder(1))
	If ABS->(MsSeek(xFilial("ABS")+oMdlTW9MASTER:GetValue("TW9_LOCAL")))
		If !EMPTY(ABS->ABS_CODMUN)
			aAdd( aPedCabec, {"C5_MUNPRES",ABS->ABS_CODMUN, Nil } )
		EndIf
		If !EMPTY(ABS->ABS_RECISS)
			aAdd( aPedCabec, {"C5_RECISS",ABS->ABS_RECISS, Nil } )
		EndIf
		If !EMPTY(ABS->ABS_ESTADO)
			aAdd( aPedCabec, {"C5_ESTPRES",ABS->ABS_ESTADO, Nil } )
		EndIf
	EndIf
		
	cAgpPed := oMdlTW9MASTER:GetValue("TW9_AGPPED")

	// Monta os itens do pedido
	If cAgpPed == "1" //Agrupa pedidos = Sim
		cItem := Soma1(cItem)

		For nY := 1 To nContGrid
			oMdlTWADETAIL	:= oModel:GetModel(aGridItem[nY])

			If !( oMdlTWADETAIL:IsEmpty() )
				nTWATotLin := oMdlTWADETAIL:Length()
				For nX := 1 To nTWATotLin //Totaliza itens.
					oMdlTWADETAIL:GoLine(nX)
					nQtde :=  IIF(oMdlTWADETAIL:GetValue("TWA_QTDSEP") > 0 , oMdlTWADETAIL:GetValue("TWA_QTDSEP") , 1 )				
					nValPed += (nQtde * oMdlTWADETAIL:GetValue("TWA_VLRCOB"))

					oMdlTWADETAIL:SetNoUpdateLine(.F.)		
					oMdlTWADETAIL:SetValue("TWA_ITEMPD",cItem)
					oMdlTWADETAIL:SetNoUpdateLine(.T.)	
				Next nX
			Endif

		Next nY

		If nValPed > 0
			nQtdSep := 1
			aAdd( xAux, {"C6_ITEM",    cItem,                                Nil} )
			aAdd( xAux, {"C6_PRODUTO", oMdlTW9MASTER:GetValue("TW9_PRODUT"), Nil} )
			aAdd( xAux, {"C6_QTDVEN",  nQtdSep,                              Nil} )
			aAdd( xAux, {"C6_PRCVEN",  nValPed,                              Nil} )
			aAdd( xAux, {"C6_PRUNIT",  nValPed,                              Nil} )
			aAdd( xAux, {"C6_VALOR",   nValPed,                		 Nil} )
			aAdd( xAux, {"C6_TES",     oMdlTW9MASTER:GetValue("TW9_TES"),    Nil} )

			aAdd( aPedItens, aClone( xAux ) )
			xAux := {}

		Endif

	Elseif cAgpPed == "2" //Agrupa pedidos = Não

		For nY := 1 To nContGrid
			oMdlTWADETAIL	:= oModel:GetModel(aGridItem[nY])

			If !( oMdlTWADETAIL:IsEmpty() )

				nTWATotLin := oMdlTWADETAIL:Length()
				For nX := 1 To nTWATotLin
					oMdlTWADETAIL:GoLine(nX)
					cItem		:= Soma1(cItem)
					nQtdSep	:= IIF(oMdlTWADETAIL:GetValue("TWA_QTDSEP") > 0 , oMdlTWADETAIL:GetValue("TWA_QTDSEP") , 1 )
					nValPed	:= oMdlTWADETAIL:GetValue("TWA_VLRCOB")
					
					aAdd( xAux, {"C6_ITEM",    cItem,                                Nil} )
					aAdd( xAux, {"C6_PRODUTO", oMdlTWADETAIL:GetValue("TWA_PRODUT"), Nil} )
					aAdd( xAux, {"C6_QTDVEN",  nQtdSep,                              Nil} )
					aAdd( xAux, {"C6_PRCVEN",  nValPed,                              Nil} )
					aAdd( xAux, {"C6_PRUNIT",  nValPed,                              Nil} )
					aAdd( xAux, {"C6_VALOR",   nQtdSep*nValPed,                      Nil} )
					aAdd( xAux, {"C6_TES",     oMdlTWADETAIL:GetValue("TWA_TES"),    Nil} )
					
					aAdd( aPedItens, aClone( xAux ) )
					xAux := {}
					
					oMdlTWADETAIL:SetNoUpdateLine(.F.)		
					oMdlTWADETAIL:SetValue("TWA_ITEMPD",cItem)
					oMdlTWADETAIL:SetNoUpdateLine(.T.)	
					
				Next nX

			Endif

		Next nY

	Endif

Elseif lExcFat
	oMdlTW9MASTER := oModel:GetModel("TW9MASTER")
	nOpcx    := 5
	aAdd( aPedCabec, {"C5_NUM", oMdlTW9MASTER:GetValue("TW9_NUMPED"),	Nil } )
Endif

Begin Transaction
	If ( lFaturar .And. Len( aPedItens ) > 0 .And. Len( aPedCabec ) > 0 ) .Or. ( lExcFat .And. Len( aPedCabec ) > 0 )
		// dispara execauto para gravação do Pedido de cobrança da indenização.
		MsExecAuto( { |x,y,z| MATA410( x, y, z ) }, aPedCabec, aPedItens, nOpcx )
		If lMsErroAuto
			xAux := GetAutoGrLog()
			MostraErro()
			lRet := .F.
		Else
			If lFaturar
				oMdlTW9MASTER:LoadValue("TW9_NUMPED",SC5->C5_NUM)
				oMdlTW9MASTER:LoadValue("TW9_STATUS","2")			//1=Aberta;2=Faturada;3=Encerrada
			ElseIf lExcFat
				oMdlTW9MASTER:LoadValue("TW9_NUMPED","")
				oMdlTW9MASTER:LoadValue("TW9_STATUS","1")					//1=Aberta;2=Faturada;3=Encerrada

				For nY := 1 To nContGrid
					oMdlTWADETAIL	:= oModel:GetModel(aGridItem[nY])
					If !( oMdlTWADETAIL:IsEmpty() )
						nTWATotLin := oMdlTWADETAIL:Length()
		
						For nX := 1 To nTWATotLin //Totaliza itens.
							oMdlTWADETAIL:GoLine(nX)

							oMdlTWADETAIL:SetNoUpdateLine(.F.)		
							oMdlTWADETAIL:SetValue("TWA_ITEMPD","")
							oMdlTWADETAIL:SetNoUpdateLine(.T.)
		
						Next nX
					Endif		
				Next nY
			Endif
		Endif

	EndIf

	If	lRet .and. ( lFaturar .or. lEncerrar )
		DbSelectArea("AA3")
		AA3->(dBSetOrder(6))	//AA3_FILIAL+AA3_NUMSER
		For nY := 1 To Len(aGridItem)
			oMdlTWADETAIL	:= oModel:GetModel(aGridItem[nY])

			If !( oMdlTWADETAIL:IsEmpty() )

				nTWATotLin := oMdlTWADETAIL:Length()
				For nX := 1 To nTWATotLin
					oMdlTWADETAIL:GoLine(nX)
					If	oMdlTWADETAIL:GetValue("TWA_BLQAA3") == "1"	//Bloqueia equipamento? (1=Sim/2=Não)	
						At650BqAA3(oMdlTWADETAIL:GetValue("TWA_NUMSER"))
					EndIf
				Next nX

			Endif

		Next nY

	EndIf

	If lRet

		//Atualliza a data de finalização do processo de indenização
		If nOperation <> MODEL_OPERATION_DELETE
			If	oMdlTW9MASTER:GetValue("TW9_STATUS") == "1"	//1=Aberta;2=Faturada;3=Encerrada
				oMdlTW9MASTER:LoadValue("TW9_DTFINA",CtoD(Space(08)))
			Else
				If	Empty(oMdlTW9MASTER:GetValue("TW9_DTFINA"))
					oMdlTW9MASTER:LoadValue("TW9_DTFINA",dDataBase)
				EndIf
			EndIf
		Endif

		If oModel:VldData()
			If !FWFormCommit(oModel)
				lRet := .F.
				If !ISBlind()
					JurShowErro( oModel:GetModel():GetErrormessage() )
				EndIf				
			Endif
		Else
			lRet := .F.
			If !IsBlind()
				JurShowErro( oModel:GetModel():GetErrormessage() )
			EndIf
		EndIf
	EndIf

End Transaction

AA3->(RestArea(aOldAA3))
If	!( Empty(cOldAlias) )
	(cOldAlias)->(RestArea(aOldAlias))
EndIf
Return	lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} At650BqAA3
@description	Realiza o bloqueio do equipamento
@sample	 	At650BqAA3(cEquipam)
@param			cEquipam	Código do equipamento
@return		NIL
@author		Alexandre da Costa (a.costa)
@since			11/04/2016
@version		P12
/*/
//------------------------------------------------------------------
Static Function At650BqAA3(cEquipam)

AA3->(dBSeek(xFilial("AA3") + cEquipam))
AA3->(RecLock("AA3",.F.))
AA3->AA3_MSBLQL	:=	"1"		//"1"=Bloqueado (SIM);"2"=Bloqueado (NÃO)
AA3->(MsUnLock())
Return NIL


//------------------------------------------------------------------------------
/*/{Protheus.doc} At650ExcFat
@description	Exclusão do Faturamento.
@sample	 	At650ExcFat()
@param			oModel
@return		Nil
@author		Kaique Schiller
@since			11/04/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Function At650ExcFat(nAuto)

Local	oModelo 	:= Nil
Local	oMdlInde	:= Nil
Local	aGridItem	:= {}
Local	nContGrid	:= 0
Local	nX			:= 0

Default nAuto := 0

nOpcAuto := nAuto

If TW9->TW9_STATUS == "2" //Quando estiver faturado.
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	If SC5->(DbSeek(xFilial("SC5")+TW9->TW9_NUMPED))
		If Empty(SC5->C5_LIBEROK) .And. Empty(SC5->C5_NOTA) .And. Empty(SC5->C5_BLQ) //Se não houver nenhum bloqueio.
			oModelo := FWLoadModel("TECA650")
			oModelo:SetOperation(MODEL_OPERATION_UPDATE)
			oModelo:Activate()
			
			oMdlInde := oModelo:GetModel("TW9MASTER")
	
			oMdlInde:SetValue("TW9_STATUS") := "1"				//1=Aberta;2=Faturada;3=Encerrada
		
			oModelo:GetModel("TW9MASTER"):SetOnlyView(.T.)
		
			aAdd( aGridItem, {"TWATDETAIL"})
			aAdd( aGridItem, {"TWAMDETAIL"})
			aAdd( aGridItem, {"TWAEDETAIL"})

			nContGrid := Len(aGridItem)
			
			For nX := 1 To nContGrid
				oModelo:GetModel(aGridItem[nX,1]):SetNoInsertLine()
				oModelo:GetModel(aGridItem[nX,1]):SetNoUpdateLine()
				oModelo:GetModel(aGridItem[nX,1]):SetNoDeleteLine()
			Next nX
			If !IsBlind()
				FWExecView(STR0036,"TECA650",MODEL_OPERATION_UPDATE,,{|| .T.},,,,,,,oModelo) //"Excluir Faturamento"
			EndIf
		Else
			Help(,, "At650ExcFat",,STR0037,1,0,,,,,,{STR0038+TW9->TW9_NUMPED}) //"O pedido não esta em aberto" ## "Verifique o pedido de venda: "
		Endif
	Else
		Help(,, "At650ExcFat",,STR0039,1,0,,,,,,{STR0040+TW9->TW9_NUMPED}) //"Pedido de venda não existe" ## "Verifique se existe o pedido de venda: "
	Endif
Else
	Help(,, "At650ExcFat",,STR0041,1,0,,,,,,{STR0042}) //"Não é possível realizar a exclusão do faturamento." ## "É necessário que a indenização esteja em faturamento."
Endif

Return oModelo


//------------------------------------------------------------------
/*/{Protheus.doc} At650VsPed
@description	Visualiza o pedido de venda associado ao processo de indenização selecionado
@sample	 	At650VsPed(oModel)
@param			oModel		Model
@Return		NIL
@author		Alexandre da Costa (a.costa)
@since			11/04/2016
@version		P12
/*/
//-------------------------------------------------------------------
Static Function At650VsPed(oModel)

Local	aOldSC5		:= SC5->(GetArea())
Local	aOldSC6		:= SC6->(GetArea())
Local	oMdlTW9MASTER	:= oModel:GetModel("TW9MASTER")
Local	cNumPedVd		:= oMdlTW9MASTER:GetValue("TW9_NUMPED")

// Variável aRotina será utilizada pela rotina A410Visual do MATA410...
Private	aRotina	:= { {OemToAnsi(STR0002), "A410Visual", 0, 2, 0, NIL} }		//"Visual"
Private	cCadastro	:= STR0032	//"Atualização de pedido de venda"

If	!Empty(cNumPedVd)
	SC5->(dBSetOrder(1))	//C5_FILIAL+C5_NUM
	SC5->(dBSeek(xFilial("SC5")+cNumPedVd))
	A410Visual("SC5",SC5->(RecNo()),MODEL_OPERATION_VIEW)
Else
	Help("", 1, "At650VsPed", "", STR0033, 1, 0,,,,,,{STR0034})	//"Processo de indenização não está faturado." ## "É necessário realizar o faturamento do processo da indenização para possibilitar a visualização do pedido de venda a ela associado."
EndIf

SC6->(RestArea(aOldSC6))
SC5->(RestArea(aOldSC5))
Return	NIL


//------------------------------------------------------------------
/*/{Protheus.doc} At650BlqPed
@description	Bloqueia o pedido de venda se foi gerado pela indenização.
@sample	 	At650BlqPed(cPedido)
@param			cPedido	Número do pedido
@Return		ExpL		.T.=Alteração do pedido de venda é permitida, .F.=Alteração do pedido de venda não é permitida, pois o mesmo foi gerado pelo SIGATEC.
@author		Kaique Schiller
@since			12/04/2016
@version		P12
/*/
//-------------------------------------------------------------------
Function At650BlqPd(cPedido)

Local	aOldArea	:= If(!( Empty(Alias()) ), (Alias())->(GetArea()), {})
Local	lAt650	 	:= IsInCallStack("TECA650") .Or. nOpcAuto == 1 .Or. nOpcAuto == 2 .Or. nOpcAuto == 3
Local	lRet 		:= .T.
Local	cNewAlias	:= ""

Default cPedido	:= ""

If !lAt650
	
	cNewAlias := GetNextAlias()
	
	BeginSql Alias cNewAlias
	
		SELECT TW9_NUMPED
		FROM %Table:TW9% TW9
		WHERE TW9_FILIAL = %xFilial:TW9%
			AND TW9_NUMPED = %Exp:cPedido%
			AND TW9.%NotDel%
	EndSql
	
	DbSelectArea(cNewAlias)
	
	If (cNewAlias)->(!Eof())
		Help(,, "At650BlqPed",,STR0048,1,0,,,,,,{STR0049}) //"O pedido de venda foi gerado pela indenização." ## "Realize o estorno do faturamento da indenização."
		lRet := .F.
	Endif

	(cNewAlias)->(DbCloseArea())

Endif
If	Len(aOldArea) > 0
	RestArea(aOldArea)
EndIf
Return lRet


//------------------------------------------------------------------
/*/{Protheus.doc} At650VldEqp
@description	Valida se o equipamento selecionado pertence ao contrato para ser gerada a indenização.
@sample	 	At650VldEqp( cNSerEqu )
@param			cNSerEqu - Número de série do equipamento
@Return		ExpL	.T.=Equipamento selecionado é válido para o contrato, .F.=Equipamento selecionado não é válido para o contrato
@author		Alexandre da Costa (a.costa)
@since			13/04/2016
@version		P12
/*/
//-------------------------------------------------------------------
Function At650VldEqp(cNSerEqu)

Local	aOldArea		:= If(!( Empty(Alias()) ), (Alias())->(GetArea()), {})
Local	oModel			:= FWModelActive()
Local	oMdlTW9MASTER	:= oModel:GetModel("TW9MASTER")
Local	cTW9Contrt		:= oMdlTW9MASTER:GetValue("TW9_CONTRT")
Local	cTW9Local		:= oMdlTW9MASTER:GetValue("TW9_LOCAL")
Local	cNewAlias		:= GetNextAlias()
Local	lRet			:= .T.

BeginSql Alias cNewAlias

   SELECT 'S' AS WASFOUND
     FROM %Table:TFI% TFI
    INNER JOIN %Table:TEW% TEW ON TEW.TEW_FILIAL = %xFilial:TEW% 
                               AND TEW.%NotDel%
                               AND TEW.TEW_CODEQU = TFI.TFI_COD
                               AND TEW.TEW_BAATD = %Exp:cNSerEqu%
    WHERE TFI.TFI_FILIAL = %xFilial:TFI%
      AND TFI.%NotDel%
      AND TFI.TFI_CONTRT = %Exp:cTW9Contrt%
      AND TFI.TFI_LOCAL = %Exp:cTW9Local%

EndSql
	
DbSelectArea(cNewAlias)

If (cNewAlias)->(Eof())
	Help(,, "At650VldEqp",,STR0070,1,0,,,,,,{STR0071}) //"Somente é possível gerar indenização para equipamentos de locação." ## "Selecione um item da OS que esteja vinculado diretamente com a base de atendimento separada."
	lRet := .F.
Endif
(cNewAlias)->(DbCloseArea())

If	Len(aOldArea) > 0
	RestArea(aOldArea)
EndIf
Return	lRet


//------------------------------------------------------------------
/*/{Protheus.doc} At650VldCtr
@description	Valida se o contrato/local de atendimento possuem os respectivos equipamentos eventualmente mencionados nas GRIDs da tela para ser gerada a indenização.
@sample	 	At650VldCtr( cTW9Contrt, cTW9Local )
@param			cTW9Contrt - Número do contrato
@param			cTW9Local - Código do local de atendimento
@Return		ExpL	.T.=Equipamentos são válidos para o contrato/local de atendimento, .F.=Equipamentos não são válidos para o contrato/local de atendimento
@author		Alexandre da Costa (a.costa)
@since			13/04/2016
@version		P12
/*/
//-------------------------------------------------------------------
Function At650VldCtr( cTW9Contrt, cTW9Local )

Local	cOldArea		:= Alias()
Local	aOldArea		:= If(!( Empty(cOldArea) ), (cOldArea)->(GetArea()), {})
Local	oModel			:= FWModelActive()
Local	oMdlTWADETAIL	:= NIL
Local	aGridItem		:= {}
Local	nContGrid		:= 0
Local	nTWATotLin		:= 0
Local	nX				:= 0
Local	nY				:= 0
Local	cNewAlias		:= ""
Local	cNSerEqu		:= ""
Local	lRet			:= .T.

aAdd(aGridItem, "TWATDETAIL")
aAdd(aGridItem, "TWAMDETAIL")
aAdd(aGridItem, "TWAEDETAIL")

nContGrid := Len(aGridItem)
For nY := 1 To nContGrid

	oMdlTWADETAIL	:= oModel:GetModel(aGridItem[nY])

	If !( oMdlTWADETAIL:IsEmpty() )

		nTWATotLin := oMdlTWADETAIL:Length()
		For nX := 1 To nTWATotLin //Totaliza itens.

			oMdlTWADETAIL:GoLine(nX)
			cNSerEqu	:= oMdlTWADETAIL:GetValue("TWA_NUMSER")

			If	! Empty(cNSerEqu)

				cNewAlias	:= GetNextAlias()
				If	! Empty(cTW9Local)
					BeginSql Alias cNewAlias

					   SELECT 'S' AS WASFOUND
					     FROM %Table:TFI% TFI
					    INNER JOIN %Table:TEW% TEW ON TEW.TEW_FILIAL = %xFilial:TEW% 
					                               AND TEW.%NotDel%
					                               AND TEW.TEW_CODEQU = TFI.TFI_COD
					                               AND TEW.TEW_BAATD = %Exp:cNSerEqu%
					    WHERE TFI.TFI_FILIAL = %xFilial:TFI%
					      AND TFI.%NotDel%
					      AND TFI.TFI_CONTRT = %Exp:cTW9Contrt%
					      AND TFI.TFI_LOCAL = %Exp:cTW9Local%

					EndSql
				Else
					BeginSql Alias cNewAlias

					   SELECT 'S' AS WASFOUND
					     FROM %Table:TFI% TFI
					    INNER JOIN %Table:TEW% TEW ON TEW.TEW_FILIAL = %xFilial:TEW% 
					                               AND TEW.%NotDel%
					                               AND TEW.TEW_CODEQU = TFI.TFI_COD
					                               AND TEW.TEW_BAATD = %Exp:cNSerEqu%
					    WHERE TFI.TFI_FILIAL = %xFilial:TFI%
					      AND TFI.%NotDel%
					      AND TFI.TFI_CONTRT = %Exp:cTW9Contrt%

					EndSql
				EndIf
				DbSelectArea(cNewAlias)

				If (cNewAlias)->(Eof())
					(cNewAlias)->(DbCloseArea())
					If	!Empty(cOldArea)
						DbSelectArea(cOldArea)
					EndIf
					lRet := .F.
					Exit
				Endif

				(cNewAlias)->(DbCloseArea())

				If	!Empty(cOldArea)
					DbSelectArea(cOldArea)
				EndIf

			EndIf

		Next nX
	Endif

	If	!( lRet )
		Exit
	EndIf

Next nY

If	!( lRet )
	Help(,, "At650VldCtr",,STR0052,1,0,,,,,,{STR0053}) //"Existe ao menos um equipamento informado que não pertence ao local de atendimento do referido contrato selecionado." ## "Certifique-se de que os equipamentos informados pertençam ao local de atendimento do contrato ao qual se deseja criar o referido processo de indenização."
EndIf

If	Len(aOldArea) > 0
	RestArea(aOldArea)
EndIf
Return	lRet


//------------------------------------------------------------------
/*/{Protheus.doc} At650VldLoc
@description	Valida se o local de atendimento selecionado pertence ao contrato para ser gerada a indenização.
@sample	 	At650VldLoc( cTW9Contrt, cTW9Local )
@param			cTW9Contrt - Número do contrato
@param			cTW9Local - Código do local de atendimento
@Return		ExpL	.T.=Local de atendimento selecionado é válido para o contrato, .F.=Local de atendimento selecionado não é válido para o contrato
@author		Alexandre da Costa (a.costa)
@since			19/04/2016
@version		P12
/*/
//-------------------------------------------------------------------
Function At650VldLoc( cTW9Contrt, cTW9Local )

Local	aOldArea		:= If(!( Empty(Alias()) ), (Alias())->(GetArea()), {})
Local	cNewAlias		:= GetNextAlias()
Local	lRet			:= .T.

BeginSql Alias cNewAlias
	
   SELECT TFL.TFL_CONTRT, TFL.TFL_LOCAL
     FROM %Table:TFL% TFL 
    WHERE TFL.TFL_FILIAL = %xFilial:TFL%
      AND TFL.%NotDel%
      AND TFL.TFL_CONTRT = %Exp:cTW9Contrt%
      AND TFL.TFL_LOCAL  = %Exp:cTW9Local%  

EndSql
	
DbSelectArea(cNewAlias)

If (cNewAlias)->(Eof())
	Help(,, "At650VldLoc",,STR0062,1,0,,,,,,{STR0063}) //"O local de atendimento que está sendo selecionado para compor o processo de indenização não pertence ao contrato mencionado." ## "Selecione um local de atendimento que pertença ao contrato ao qual se deseja criar o referido processo de indenização."
	lRet := .F.
Endif
(cNewAlias)->(DbCloseArea())

If	Len(aOldArea) > 0
	RestArea(aOldArea)
EndIf
Return	lRet


//------------------------------------------------------------------
/*/{Protheus.doc} At650VdAB7
@description	Valida se o item da OS SIGATEC pode ser selecionado para compor o processo de indenização.
@sample	 	At650VdAB7()
@param			Nenhum
@Return		ExpL	.T.=Item da O.S.SIGATEC pode ser selecionado para o processo de indenização, .F.=Item da O.S.SIGATEC não pode ser selecionado para o processo de indenização
@author		Alexandre da Costa (a.costa)
@since			20/04/2016
@version		P12
/*/
//-------------------------------------------------------------------
Function At650VdAB7()

Local	aOldArea			:= If(!( Empty(Alias()) ), (Alias())->(GetArea()), {})
Local	oModel				:= FWModelActive()
Local	oMdlTWATDETAIL	:= oModel:GetModel("TWATDETAIL")
Local	cOSAB6				:= oMdlTWATDETAIL:GetValue("TWA_CODAB6")
Local	cItOSAB7			:= oMdlTWATDETAIL:GetValue("TWA_CODAB7")
Local	cNewAlias			:= GetNextAlias()
Local	cSitOSAB7			:= ""
Local	lRet				:= .T.

BeginSql Alias cNewAlias

   SELECT 'S' AS WASFOUND
     FROM %Table:TWA% TWA
    INNER JOIN %Table:TW9% TW9 ON TW9.TW9_FILIAL = %xFilial:TW9% 
                              AND TW9.%NotDel%
                              AND TW9.TW9_CODIGO = TWA.TWA_CODTW9
                              AND TW9.TW9_STATUS IN ('1','2')
    WHERE TWA.TWA_FILIAL = %xFilial:TWA%
      AND TWA.%NotDel%
      AND TWA.TWA_CODAB6 = %Exp:cOSAB6%
      AND TWA.TWA_CODAB7 = %Exp:cItOSAB7%

EndSql
	
DbSelectArea(cNewAlias)

If (cNewAlias)->(! Eof())
	Help(,, "At650VdAB7",,STR0064,1,0,,,,,,{STR0065})	//"O item da O.S.SIGATEC (equipamento) já foi utilizado em outro processo de indenização." ## "Selecione um item da O.S.SIGATEC (equipamento) que ainda não foi utilizado em outro processo de indenização."
	lRet := .F.
Endif
(cNewAlias)->(DbCloseArea())

cSitOSAB7	:=	Posicione("AB7",1,xFilial("AB7")+cOSAB6+cItOSAB7,"AB7_TIPO")
If	cSitOSAB7 <> "4"	.AND. cSitOSAB7 <> "5"
	Help(,, "At650VdAB7",,STR0068,1,0,,,,,,{STR0069})	//"A situação do item da O.S.SIGATEC (equipamento) deve ser igual a 'atendido' ou 'encerrado' para que seja permitida a sua seleção na composição de um processo de indenização." ## "Finalize o atendimento do item da O.S.SIGATEC (equipamento)."
	lRet := .F.
EndIf

If	Len(aOldArea) > 0
	RestArea(aOldArea)
EndIf
Return	lRet


//------------------------------------------------------------------
/*/{Protheus.doc} At650VdSTJ
@description	Valida se a OS SIGAMNT já foi utilizada em algum outro processo de indenização.
@sample	 	At650VdSTJ()
@param			Nenhum
@Return		ExpL	.T.=O.S.SIGAMNT pode ser selecionada para o processo de indenização, .F.=O.S.SIGAMNT não pode ser selecionada para o processo de indenização
@author		Alexandre da Costa (a.costa)
@since			20/04/2016
@version		P12
/*/
//-------------------------------------------------------------------
Function At650VdSTJ()

Local	aOldArea			:= If(!( Empty(Alias()) ), (Alias())->(GetArea()), {})
Local	oModel				:= FWModelActive()
Local	oMdlTWATDETAIL	:= oModel:GetModel("TWAMDETAIL")
Local	cOSSTJ				:= oMdlTWATDETAIL:GetValue("TWA_CODSTJ")
Local	cNewAlias			:= GetNextAlias()
Local	lRet				:= .T.

BeginSql Alias cNewAlias

   SELECT 'S' AS WASFOUND
     FROM %Table:TWA% TWA
    INNER JOIN %Table:TW9% TW9 ON TW9.TW9_FILIAL = %xFilial:TW9% 
                              AND TW9.%NotDel%
                              AND TW9.TW9_CODIGO = TWA.TWA_CODTW9
                              AND TW9.TW9_STATUS IN ('1','2')
    WHERE TWA.TWA_FILIAL = %xFilial:TWA%
      AND TWA.%NotDel%
      AND TWA.TWA_CODSTJ = %Exp:cOSSTJ%

EndSql
	
DbSelectArea(cNewAlias)

If (cNewAlias)->(! Eof())
	Help(,, "At650VdSTJ",,STR0066,1,0,,,,,,{STR0067})	//"A O.S.SIGAMNT (equipamento) já foi utilizada em outro processo de indenização." ## "Selecione uma O.S.SIGAMNT (equipamento) que ainda não foi utilizada em outro processo de indenização."
	lRet := .F.
Endif
(cNewAlias)->(DbCloseArea())

If	Len(aOldArea) > 0
	RestArea(aOldArea)
EndIf
Return	lRet


//------------------------------------------------------------------
/*/{Protheus.doc} At650TgCus
@description	Calcula o valor de custo das O.S.SIGATEC para o processo de indenização. Utilizado no gatilho do campo TWA_CODAB7.
@sample	 	At650TgCus()
@param			Nenhum
@Return		ExpN	Valor de custo total para a O.S.SIGATEC sugerido para compor o valor total do processo de indenização
@author		Alexandre da Costa (a.costa)
@since			20/04/2016
@version		P12
/*/
//-------------------------------------------------------------------
Function At650TgCus()

Local	aOldArea			:= If(!( Empty(Alias()) ), (Alias())->(GetArea()), {})
Local	oModel				:= FWModelActive()
Local	oMdlTWATDETAIL	:= oModel:GetModel("TWATDETAIL")
Local	cOSAB6				:= oMdlTWATDETAIL:GetValue("TWA_CODAB6")
Local	cItOSAB7			:= oMdlTWATDETAIL:GetValue("TWA_CODAB7")
Local	cOSTEC				:= cOSAB6 + cItOSAB7
Local	cNewAlias			:= GetNextAlias()
Local	nRet				:= 0

BeginSql Alias cNewAlias

   SELECT SUM(AB9.AB9_CUSTO) AB9TCUSTO
     FROM %Table:AB9% AB9
    INNER JOIN %Table:AB7% AB7 ON AB7.AB7_FILIAL = %xFilial:AB7%
                         AND AB7.%NotDel%
                         AND AB7.AB7_NUMOS = %Exp:cOSAB6%
                         AND AB7.AB7_ITEM = %Exp:cItOSAB7%
    WHERE AB9.AB9_FILIAL = %xFilial:AB9%
      AND AB9.%NotDel%
      AND AB9.AB9_NUMOS = %Exp:cOSTEC%

EndSql

DbSelectArea(cNewAlias)

nRet	+=	(cNewAlias)->AB9TCUSTO

(cNewAlias)->(DbCloseArea())

BeginSql Alias cNewAlias

   SELECT SUM(SD3.D3_CUSTO1) SD3RECUSTO 
     FROM %Table:ABG% ABG
     INNER JOIN %Table:SD3% SD3 ON SD3.D3_FILIAL = %xFilial:SD3% 
                          AND SD3.%NotDel% 
                          AND SD3.D3_NUMSA = ABG.ABG_NUMSA
                          AND SD3.D3_ITEMSA = ABG.ABG_ITEMSA
                          AND SUBSTRING(SD3.D3_CF,1,2) = 'RE'
    WHERE ABG.ABG_FILIAL = %xFilial:ABG%
      AND ABG.%NotDel%
      AND ABG.ABG_NUMOS = %Exp:cOSAB6%
      AND ABG.ABG_ITEMOS = %Exp:cItOSAB7%

EndSql

DbSelectArea(cNewAlias)

nRet	+=	(cNewAlias)->SD3RECUSTO

(cNewAlias)->(DbCloseArea())

BeginSql Alias cNewAlias

   SELECT SUM(SD3.D3_CUSTO1) SD3DECUSTO 
     FROM %Table:ABG% ABG
     INNER JOIN %Table:SD3% SD3 ON SD3.D3_FILIAL = %xFilial:SD3% 
                          AND SD3.%NotDel% 
                          AND SD3.D3_NUMSA = ABG.ABG_NUMSA
                          AND SD3.D3_ITEMSA = ABG.ABG_ITEMSA
                          AND SUBSTRING(SD3.D3_CF,1,2) = 'DE'
    WHERE ABG.ABG_FILIAL = %xFilial:ABG%
      AND ABG.%NotDel%
      AND ABG.ABG_NUMOS = %Exp:cOSAB6%
      AND ABG.ABG_ITEMOS = %Exp:cItOSAB7%

EndSql

DbSelectArea(cNewAlias)

nRet	-=	(cNewAlias)->SD3DECUSTO

(cNewAlias)->(DbCloseArea())

If	Len(aOldArea) > 0
	RestArea(aOldArea)
EndIf
Return	nRet

//------------------------------------------------------------------
/*/{Protheus.doc} At650GtEqu
@description	
	Retorna o equipamento segundo o numero da O.S. de manutenção 
@sample	 	At650GtEqu()
@param		Nenhum
@Return		cRet Caractere codigo do Equipamento	
@author		Joni Lima (joni.carmo)
@since		14/09/2016
@version	P12
/*/
//-------------------------------------------------------------------
Function At650GtEqu(cField)
	
	Local aArea 	:= GetArea()
	Local aAreaSTJ	:= STJ->(GetArea())
	Local aAreaAA3  := AA3->(GetArea())
	Local cRet 		:= ''
	Local oModel	:= FWModelActive()	
	Local oMdlMnt   := nil
	
	If Valtype(oModel) == 'O' .and. oModel:GetId() == 'TECA650'
		
		oMdlMnt   := oModel:GetModel('TWAMDETAIL')//Modelo da base de manutenção
		
		dbSelectArea('STJ')
		STJ->(dbSetOrder(1))
		
		If STJ->(dbSeek(xFilial('STJ') + oMdlMnt:GetValue('TWA_CODSTJ')))
		
			dbSelectArea('AA3')
			AA3->(dbSetOrder(8))			
			
			If AA3->(dbSeek(xFilial("AA3") + xFilial("STJ") + STJ->TJ_CODBEM))
				
				If Alltrim(cField) == 'AA3_NUMSER'
					cRet := AA3->AA3_NUMSER
				Elseif Alltrim(cField) == 'AA3_CODPRO'
					cRet := AA3->AA3_CODPRO
				EndIf 
				
			EndIf
		
		EndIf	
		
	EndIf
	
	RestArea(aAreaAA3)
	RestArea(aAreaSTJ)
	RestArea(aArea)
	
Return cRet