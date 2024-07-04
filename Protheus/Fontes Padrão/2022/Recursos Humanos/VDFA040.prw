#include "VDFA040.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFA040
Cadastro de Candidato x Concurso / Controle de Requisitos.
@sample 	VDFA040()
@history	19/11/2013, Nivia F., GSP-Cadastro de Candidato x Concurso / Controle de Requisitos.
@history	18/12/2014, Marcos Pereira, Implementacao da Desistencia de Estagiario, pois não foi desenvolvido conf.especificacao.
@history	27/04/2017, Oswaldo L, Entre os dias 24-04-17 e 26-04-17 baixamos os fontes do TFS das pastas MAIN, 12.1.14 e 12.1.16. Conforme solicitado fizemos merge delas,depois removemos alteracoes em SX.
@author	    Nivia Ferreira
@since		15/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFA040()
Local oBrowse
Local cBlqCV	 := SuperGetMv("MV_BLQCV",,"1") 
Local cFiltraSQG := ''

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'SQG' )
oBrowse:SetDescription(STR0001) //'Manutenção dos Candidatos'
oBrowse:AddLegend( "QG_SITUAC=='001' .or. Empty(QG_SITUAC) ", "GREEN" , STR0018)  //"Diponível"
oBrowse:AddLegend( "QG_SITUAC=='002'", "RED"  , STR0019) //"Admitido"
oBrowse:AddLegend( "QG_SITUAC=='FUN'", "BLUE"   , STR0020) //"Servidor"
oBrowse:DisableDetails()

IF SQG->(Columnpos("QG_ACTRSP")) > 0
	cFiltraSQG := "SQG->QG_ACTRSP <> '1' " //1- sem aceite e 2-com aceite
ENDIF

IF cBlqCV == '2'
	if !empty(cFiltraSQG)
		cFiltraSQG += " .and. SQG->QG_ACEITE == '2' " //1=Sem aceite; 2=Aceite vigente gravado    
	else
		cFiltraSQG += " SQG->QG_ACEITE == '2' " //1=Sem aceite; 2=Aceite vigente gravado 
	ENDIF
ENDIF

oBrowse:SetFilterDefault(cFiltraSQG)
oBrowse:Activate()

Return NIL


//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Incluindo opção no Menu do browse.
@return		aRotina, array, opções de ações disponíveis em tela.
@author		Nivia Ferreira
@since		15/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0002  Action 'VIEWDEF.VDFA040' OPERATION 2 ACCESS 0//'Visualizar'
ADD OPTION aRotina Title STR0003  Action 'VIEWDEF.VDFA040' OPERATION 4 ACCESS 0//'Manutenção'

Return aRotina


//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Cria a estrutura a ser usada no Modelo de Dados.
@return		oModel, objeto, Retorna o Modelo de dados.
@author		Nivia Ferreira
@since		15/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
//
Local oStruSQG := FWFormStruct( 1, 'SQG', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruREY := FWFormStruct( 1, 'REY', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruREZ := FWFormStruct( 1, 'REZ', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

bCpoInit1 := {|| oModel:GetValue("SQGMASTER", "QG_CIC") }
oStruREy:SetProperty('REY_CPF', MODEL_FIELD_INIT, bCpoInit1 )

bCpoInit1 := {|| oModel:GetValue("REYDETAIL", "REY_CPF") }
oStruREZ:SetProperty('REZ_CPF', MODEL_FIELD_INIT, bCpoInit1 )

oStruREY:SetProperty('REY_CPF',    MODEL_FIELD_OBRIGAT, .F. )
oStruREY:SetProperty('REY_CLASSI',	MODEL_FIELD_VALID,{||VldClassi()})
oStruREY:SetProperty('REY_SITUAC',	MODEL_FIELD_VALID,{||VldCposREY()})
oStruREY:SetProperty('REY_EXONER',	MODEL_FIELD_VALID,{||VldCposREY()})
oStruREZ:SetProperty('REZ_CPF',    MODEL_FIELD_OBRIGAT, .F. )
oStruREY:SetProperty('REY_CODCON', MODEL_FIELD_VALID, {|oGrid| fVldCodCon(oGrid)} )
oStruREY:SetProperty('REY_CODFUN', MODEL_FIELD_VALID, {|oGrid| fLoadREZ(oGrid)} )
oStruREZ:SetProperty('REZ_NOME',   MODEL_FIELD_OBRIGAT, .F. )
oStruREZ:SetProperty('REZ_CODCON', MODEL_FIELD_OBRIGAT, .F. )
oStruREZ:SetProperty('REZ_DESCON', MODEL_FIELD_OBRIGAT, .F. )
oStruREZ:SetProperty('REZ_CODFUN', MODEL_FIELD_OBRIGAT, .F. )
oStruREZ:SetProperty('REZ_FILFUN', MODEL_FIELD_OBRIGAT, .F. )
oStruREZ:SetProperty('REZ_CODREQ', MODEL_FIELD_WHEN , {|| .F.})

If FUNNAME() == 'VDFM010'
	oStruSQG:SetProperty("QG_CIC",MODEL_FIELD_WHEN,{||.T.})
EndIf

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('VDFA040MODEL', /*bPreValidacao*/, { |oModel| fVldPublic(oModel)} /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'SQGMASTER', /*cOwner*/, oStruSQG )
	oModel:GetModel ( 'SQGMASTER'):SetOnlyQuery(.T.)
	oModel:GetModel ( 'SQGMASTER'):SetOnlyView(.T.)

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'REYDETAIL', 'SQGMASTER', oStruREY, {|oGrid,nLine, cAction| fDelREY(oGrid, nLine, cAction)}/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'REZDETAIL', 'REYDETAIL', oStruREZ, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'REYDETAIL', { { 'REY_FILIAL', 'FWxFilial( "REY",SQG->QG_FILIAL )' }, { 'REY_CPF', 'QG_CIC' } }, REY->( IndexKey( 1 ) ) )
oModel:SetRelation( 'REZDETAIL', { { 'REZ_FILIAL', 'FWxFilial( "REZ",SQG->QG_FILIAL )' }, { 'REZ_CPF', 'REY_CPF' }, { 'REZ_CODCON', 'REY_CODCON' },{ 'REZ_FILFUN', 'REY_FILFUN' },{ 'REZ_CODFUN', 'REY_CODFUN' }} , REZ->( IndexKey( 1 ) ) )


// Liga o controle de nao repeticao de linha
oModel:GetModel( 'REZDETAIL' ):SetUniqueLine( { 'REZ_CODREQ' } )
oModel:GetModel( 'REYDETAIL' ):SetUniqueLine( { 'REY_FILIAL','REY_CODCON' } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0004 )//'Modelo de Curriculos'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'SQGMASTER' ):SetDescription( STR0005 )//'Dados do Curriculo'
oModel:GetModel( 'REYDETAIL' ):SetDescription( STR0017 )
oModel:GetModel( 'REZDETAIL' ):SetDescription( STR0006  )//'Requisitos dos Concursos do Curriculo'

//Permissão de grid sem dados
oModel:GetModel( 'REZDETAIL' ):SetOptional( .T. )
oModel:GetModel( 'REYDETAIL' ):SetOptional( .T. )

//Não permite incluir linhas no REZ. Os dados serão carregados automaticamente.
oModel:GetModel( 'REZDETAIL' ):SetNoInsertLine( .T. )

//Não permite alterar as linhas do grid.
oModel:GetModel( 'REYDETAIL' ):SetNoDeleteLine( .F. )

Return oModel


//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado.
@return		oView, objeto, Retorna o objeto de View criado.
@author		Nivia Ferreira
@since		15/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oStruSQG := FWFormStruct( 2, 'SQG' )
Local oStruREY := FWFormStruct( 2, 'REY' )
Local oStruREZ := FWFormStruct( 2, 'REZ' )

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'VDFA040' )
Local oView
Local nOper   := ALTERA

//Remove campos da struct
oStruREY:RemoveField( 'REY_CPF' )
oStruREY:RemoveField( 'REY_FILIAL' )
oStruREY:RemoveField( 'REY_NOME' )
oStruREZ:RemoveField( 'REZ_FILIAL' )
oStruREZ:RemoveField( 'REZ_CPF' )
oStruREZ:RemoveField( 'REZ_NOME' )
oStruREZ:RemoveField( 'REZ_CODCON' )
oStruREZ:RemoveField( 'REZ_DESCON' )
oStruREZ:RemoveField( 'REZ_CODFUN' )
oStruREZ:RemoveField( 'REZ_DESFUN' )
oStruREZ:RemoveField( 'REZ_FILFUN' )

oStruREY:SetProperty( 'REY_FILFUN'  , MVC_VIEW_ORDEM, '06')
oStruSQG:SetProperty('*', MVC_VIEW_CANCHANGE  ,.F.)

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )


//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_SQG', oStruSQG, 'SQGMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_REY',  oStruREY,  'REYDETAIL' )
oView:AddGrid(  'VIEW_REZ',  oStruREZ,  'REZDETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR',  20 )
oView:CreateHorizontalBox( 'INFERIOR1', 40 )
oView:CreateHorizontalBox( 'INFERIOR2', 40 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_SQG', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_REY', 'INFERIOR1')
oView:SetOwnerView( 'VIEW_REZ', 'INFERIOR2')
oView:EnableTitleView('VIEW_REZ' ,STR0008, RGB(0,0,0 )  )

// Liga a identificacao do componente
oView:EnableTitleView( 'VIEW_SQG' )
oView:EnableTitleView( 'VIEW_REY', STR0007, RGB( 224, 30, 43 )  )//"Funções do Curriculo"

oView:AddUserButton(STR0009,"QCLASSI",    {|oView|QCLASSI(),oView:Refresh()}) 								//"Reclassificar"
oView:AddUserButton(STR0024,"DESISTENCIA",{|oView|DESISTENCIA(),oView:Refresh()}) 							//"Desistência"
oView:AddUserButton(STR0010,"VDFM040",    {|oView|oModel := FWModelActive(),VDFM040(),   oView:Refresh()})	//"Incl.Fol.Pagto."
oView:AddUserButton(STR0011,"VDF040CANC", {|oView|oModel := FWModelActive(),VDF040CANC(),oView:Refresh()})	//"Exclui Item Nomeação"

// Define fechamento da tela
oView:SetCloseOnOk( {||.T.} )

Return oView


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDF040CANC
Cancelamento do item.
@author		Nivia Ferreira
@since		30/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDF040CANC()
Local aArea   := GetArea()
Local cCmd    := ''
Local oModel  := FWModelActive()

dbSelectArea("RI6")
DbSetOrder(1)
//Filial+TabOri+Cpf+FilMat+Mat

If  (RI6->(DbSeek(FWXFILIAL("RI6")+'REY'+FwFldGet( 'REY_CPF' )))) .And. RI6_CLASTP=='01'

	If !Empty(RI6_NUMDOC)

			 Help(,,'Help',,STR0022,1,0)   			//MsgAlert(STR0022)//'Já houve a publicação do Item e não poderá ser excluído.'

	ElseIf IsBlind() .Or. ( !IsBlind() .And. MsgYesNo(STR0012))//"Confirma a exclusão do item de nomeação ? A data de nomeação e posse também serão excluídas."

		Begin Transaction

	    cCmd := "UPDATE " + RetSqlName( 'REY' )                     +;
   		        " SET  REY_NOMEAC = ' ' " + ","                     +;
   		        " REY_POSSE= ' ' "                                  +;
    	        " WHERE D_E_L_E_T_= ' ' AND "                       +;
	            "REY_FILIAL= '" +FwFldGet( 'REY_FILIAL' )+ "' AND " +;
	            "REY_CPF= '"    +FwFldGet( 'REY_CPF' )   + "' AND " +;
	            "REY_CODCON= '" +FwFldGet( 'REY_CODCON' )+ "' AND " +;
	            "REY_CODFUN= '" +FwFldGet( 'REY_CODFUN' )+ "'"
	    TCSQLExec(cCmd)

		RecLock("RI6",.F.)
		DbDelete()
		RI6->(MsUnlock())

		//Atualiza GRID
		oModel:DeActivate()
		oModel:Activate()

				Help(,,'Help',,STR0023,1,0)  		//MsgAlert(STR0023)//'Excluído com sucesso.'

		End Transaction

	Endif
Else
	Help( ,, 'Help',, STR0013, 1, 0 )//'Não foi encontrado item para ser excluido.'
Endif



RestArea(aArea)
Return NIL


//------------------------------------------------------------------------------
/*/{Protheus.doc} QCLASSI
Query com as regras de Reclassificação.
@return		oView, objeto, Retorna o objeto de View criado.
@author		Nivia Ferreira
@since		15/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function QCLASSI()
Local oModel  := FWModelActive()
Local aArea   := GetArea()
Local nOper   := oModel:GetOperation()
Local cQryTmp := ' '
Local nRet    := 0

If !(nOper == MODEL_OPERATION_UPDATE)
		Help(,,'Help',,STR0016,1,0) 	//'Reclassificação disponivel apenas para Alteração'

ElseIf !(VDFCATEG(FwFldGet('REY_CODFUN'),FwFldGet('REY_FILFUN')) $ 'EG') //Não é estagiário
		Help(,,'Help',,STR0015,1,0)        //MsgAlert(STR0015)//'Reclassificação disponivel apenas para Estagiário'

Else //É estagiário
	cQryTmp += "SELECT MAX(REY_CLASSI+1) CLASSI"
    cQryTmp += "FROM "+ RetSqlName("REY") + " REY, " + CRLF
    cQryTmp += " WHERE  " + CRLF
	cQryTmp += " REY.REY_FILIAL  ='"+FwxFilial('REY')+"' AND "+ CRLF
	cQryTmp += " REY.REY_CODCON ='"+FwFldGet('REY_CODCON')+"' AND "+ CRLF
	cQryTmp += " REY.REY_CODFUN ='"+FwFldGet('REY_CODFUN')+"' AND "+ CRLF
	cQryTmp += " REY.D_E_L_E_T_ =' ' "+ CRLF
	cQryTmp := ChangeQuery(cQryTmp)
	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQryTmp), 'TRBREY', .F., .T. )
    nRet := TRBREY->CLASSI
    TRBREY->(dbCloseArea())
	
	If !IsBlind() .and. !MsgYesNo( STR0014+AllTrim(Str(nRet))+' ?')//'Confirma a Reclassificação para '
    	nRet := FwFldGet('REY_CLASSI')
    EndIf
	oModel:SetValue( 'REYDETAIL','REY_CLASSI', nRet )
EndIf

RestArea( aArea )
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} VLDCLASSI
Função para Validar o campo REY_CLASSI.
@return	lRet. lógico, resultado da validação do campo.
@author	Everson S P Junior
@since		07/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VldClassi(lbotão)
lRet	:= .T.

If !REYWHEN() .AND. !IsInCallStack("QCLASSI") .AND. !IsInCallStack("VDFM010")
	Help( ,, 'Help',, STR0021, 1, 0 )//'Utilizar o Botão Reclassifica em "Ações Relacionadas"'
	lRet	:= .F.
EndIf
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} DESISTENCIA
Query com as regras de Reclassificação.
@return		oView, objeto,	Retorna o objeto de View criado.
@author		Marcos Pereira
@since		18/12/2014
@version	P11.9
/*/
//------------------------------------------------------------------------------
Function DESISTENCIA(dDesist)
Local oModel  := FWModelActive()
Local aArea   := GetArea()
Local nOper   := oModel:GetOperation()
Local lRet    := .f.
Local oDlg, oMainWnd, oData, oFont
Local dDtDesist := ctod("//")

Default dDesist := ctod("//")

If !(nOper == MODEL_OPERATION_UPDATE)
		Help(,,'Help',,STR0030,1,0)     //MsgAlert(STR0030) //'Desistência disponível apenas para Alteração'

ElseIf !(VDFCATEG(FwFldGet('REY_CODFUN'),FwFldGet('REY_FILFUN')) $ 'EG') //Não é estagiário
		Help(,,'Help',,STR0029,1,0)  	//MsgAlert(STR0029) //'Desistência disponível apenas para Estagiário'

Else //É estagiário
	If !empty(FwFldGet('REY_NOMEAC')) .or. !empty(FwFldGet('REY_POSSE')) .or. !empty(FwFldGet('REY_EXERCI'))
			Help(,,'Help',,STR0025,1,0)   	//MsgAlert(STR0025) //"Já existe data de nomeação/posse/exercício. Não pode inserir a desistência."
	ElseIf !(FwFldGet('REY_SITUAC') $ '1/2/3')
			Help(,,'Help',,STR0026,1,0)		//MsgAlert(STR0026) //"A situação atual não permite a desistência."
	Else
		If !IsBlind()
			Begin Sequence
				DEFINE FONT oFont NAME "Arial" SIZE 0,-16
				DEFINE MSDIALOG oDlg TITLE STR0027  FROM 9,0 TO 20,50 OF oMainWnd //"Data da Desistência"
					@51,25 SAY STR0027 + ":"  FONT oFont of oDlg PIXEL  //"Data da Desistência"
					@50,108 MSGET oData  VAR dDtDesist   PICTURE "@D" Valid F3 SIZE 60,8 FONT oFont OF oDlg PIXEL HASBUTTON
				ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||lRet:=.t.,,oDlg:End()},{||oDlg:End()})
			End Sequence
		Else
			dDtDesist	:= dDesist
			lRet 		:= .T.
		Endif

		If lRet
			If empty(dDtDesist) .or. dDtDesist > dDataBase
					Help(,,'Help',,STR0028,1,0)  	//MsgAlert(STR0028) //"Data inválida."
			Else
				oModel:SetValue( 'REYDETAIL','REY_SITUAC', '4' ) 		//Altera a situacao para 4-Desistencia Definitiva
				oModel:SetValue( 'REYDETAIL','REY_EXONER', dDtDesist ) 	//Altera a data de exoneracao
			EndIf
		EndIf
    EndIf
EndIf

RestArea( aArea )
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} VLDCAMPOS
Função para Validar o campos da REY
@return	lRet, lógico, resultado da validação do campo.
@author	Marcos Pereira
@since		18/12/2014
@version	P11.9
/*/
//------------------------------------------------------------------------------
Function VldCposREY()
lRet	:= .T.
	If !REYWHEN() .AND. !IsInCallStack("DESISTENCIA") .AND. !IsInCallStack("VDFM010")
		Help( ,, 'Help',, STR0031, 1, 0 )//"Utilizar o Botão Desistência em 'Ações Relacionadas'"
		lRet	:= .F.
	EndIf
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} fLoadREZ
Função para carregar o grid REZ - Requisitos da Função do Concurso
@return	lRet, lógico, resultado da validação do campo.
@author	Marcos Pereira
@since		18/12/2014
@version	P11.9
/*/
//------------------------------------------------------------------------------
Static Function fLoadREZ(oGrid)
Local oMdl			:= FwModelActive()
Local lRet			:= .T.
Local lNovo			:= .T.
Local aArea			:= GetArea()
Local nLine			:= 0
Local nLineAtual	:= oGrid:GetLine()
Local cFilCon		:= oMdl:GetModel( 'SQGMASTER' ):GetValue('QG_FILIAL') //oGrid:GetValue('REY_FILIAL')
Local cConcurso		:= oGrid:GetValue('REY_CODCON')
Local cFilFun		:= oGrid:GetValue('REY_FILFUN')
Local cFuncao		:= oGrid:GetValue('REY_CODFUN') //M->REY_CODFUN
Local cMensagem		:= ''
Local cLinhaValor	:= ''
Local oModel		:= oGrid:GetModel()
Local oGridREZ		:= oModel:GetModel('REZDETAIL')

	For nLine := 1 to oGridREZ:Length()
		oGridREZ:GoLine(nLine)
		If oGridREZ:IsDeleted()
			oGridREZ:UnDeleteLine()
		EndIf
		oGridREZ:DeleteLine()
	Next nLine

	//habilita inclusão de linhas
	oModel:GetModel( 'REZDETAIL' ):SetNoInsertLine( .F. )

	If !Empty(cFuncao)
		DbSelectArea("RI7")
		RI7->(DbSetOrder(RetOrder("RI7","RI7_FILIAL+RI7_CODCON+RI7_FILFUN+RI7_CODFUN")))
		RI7->(DbGoTop())
		If !(RI7->(DbSeek(cFilCon+cConcurso+cFilFun)))
			lRet := .F.
			//"Função não está cadastrada para o concurso e filial informada. "##"Concurso: "##"Filial da Função: "
			Help(,,"Help",,OemToAnsi(STR0037) + CRLF + CRLF + OemToAnsi(STR0033) +  cConcurso + CRLF + OemToAnsi(STR0034) + cFilFun ,1,0)
		Else
			If lRet
				oModel:GetModel( 'REYDETAIL' ):SetValue('REY_CODFUN',cFuncao)
			EndIf
		EndIf
	EndIf

	lNovo := Empty(oGridREZ:GetValue('REZ_CODREQ')) //indica se estou incluindo ou alterado a REZ
	oGridREZ:GoLine(1)
	If lRet .AND. !Empty(cConcurso) .AND. !Empty(cFuncao)
		DbSelectArea("REX") //Requistios por Funcao por Concurso
		REX->(DbSetOrder(RetOrder("REX","REX_FILIAL+REX_CODCON+REX_FILFUN+REX_CODFUN+REX_CODREQ")))
		REX->(DbGoTop())
		If REX->(DbSeek(cFilCon+cConcurso+cFilFun+cFuncao))
			If oGridREZ:IsDeleted()
				oGridREZ:UnDeleteLine()
			EndIf
			oGridREZ:LoadValue('REZ_FILIAL',REX->REX_FILIAL)
			oGridREZ:LoadValue('REZ_CODCON',REX->REX_CODCON)
			oGridREZ:LoadValue('REZ_FILFUN',REX->REX_FILFUN)
			oGridREZ:LoadValue('REZ_CODFUN',REX->REX_CODFUN)
			oGridREZ:LoadValue('REZ_CODREQ',REX->REX_CODREQ)
			oGridREZ:LoadValue('REZ_DESREQ',FDesc("REV",REX_CODREQ,"REV->REV_DESCRI",30,REX_FILIAL))
			REX->(DbSkip())

			While !Eof() .AND. REX->(REX_FILIAL+REX_CODCON+REX_FILFUN+REX_CODFUN) ==  (cFilCon+cConcurso+cFilFun+cFuncao)
				If lNovo
					nLine := oGridREZ:AddLine(.T.)
				Else
					nLine++
					If nLine > oGridREZ:Length() //se a próxima linha é nova no grid
						oGridREZ:AddLine(.T.)
						lNovo := .T.
					EndIf
				EndIf
				oGridREZ:GoLine(nLine)
				If oGridREZ:IsDeleted()
					oGridREZ:UnDeleteLine()
				EndIf
				oGridREZ:LoadValue('REZ_FILIAL',REX->REX_FILIAL)
				oGridREZ:LoadValue('REZ_CODCON',REX->REX_CODCON)
				oGridREZ:LoadValue('REZ_FILFUN',REX->REX_FILFUN)
				oGridREZ:LoadValue('REZ_CODFUN',REX->REX_CODFUN)
				oGridREZ:LoadValue('REZ_CODREQ',REX->REX_CODREQ)
				oGridREZ:LoadValue('REZ_DESREQ',FDesc("REV",REX_CODREQ,"REV->REV_DESCRI",30,REX_FILIAL))
				REX->(DbSkip())
			EndDo

			//se, após incluir os novos requisitos, ainda houver linhas no grid provenientes da outra função, deleto essas linhas
			If !lNovo .AND. nLine++ <= oGridREZ:Length()
				For nLine := nLine to oGridREZ:Length()
					oGridREZ:GoLine(nLine)
					oGridREZ:DeleteLine()
				Next nLine
			EndIf
		ElseIf !lNovo //se já houver dados na REZ , limpo o grid pois o novo código não existe na REZ.
			For nLine := 1 to oGridREZ:Length()
				oGridREZ:GoLine(nLine)
				oGridREZ:DeleteLine()
			Next nLine
			//"A Função escolhida não possui Requisitos Cadastrados."##"Função: "
			Help(,,"HELP",, OemToAnsi(STR0038) + CRLF + OemToAnsi(STR0035) + cFuncao + " - " + oGrid:GetValue('REY_DESFUN') ,1,0)
			lRet := .F.
		EndIf

	EndIf
	oGridREZ:GoLine(1)

	//desabilita inclusão de linhas
	oModel:GetModel( 'REZDETAIL' ):SetNoInsertLine( .T. )

RestArea(aArea)
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} fREYFilFun
Valida preenchimento do campo REY_FILFUN
@author		esther.viveiro
@since		02/10/2018
@version	P12
@return		lRet, lógico, resultado da validação
/*/
//------------------------------------------------------------------------------
Function fREYFilFun()
Local oModel		:= FWModelActive()
Local oGrid		:= oModel:GetModel('REYDETAIL')
Local cFilCon		:= oModel:GetModel("SQGMASTER"):GetValue('QG_FILIAL')
Local cConcurso	:= oGrid:GetValue('REY_CODCON')
Local cFuncao		:= oGrid:GetValue('REY_CODFUN')
Local cFilFun		:= ''
Local lRet		:= .T.

	cFilFun := xFilial("SRJ",M->REY_FILFUN)

	If !(xFilial("REY",M->REY_FILFUN) == cFilCon)
		lRet := .F. //somente permito escolher filiais, para as funções, que estão dentro do compartilhamento da tabela de Concursos (REW)
	EndIf

	DbSelectArea("RI7")
	RI7->(DbSetOrder(RetOrder("RI7","RI7_FILIAL+RI7_CODCON+RI7_FILFUN+RI7_CODFUN")))
	RI7->(DbGoTop())
	If !(RI7->(DbSeek(cFilCon+cConcurso+cFilFun)))
		lRet := .F.
		//"A filial informada não está cadastrada no concurso informado: "
		Help(,,"Help",,OemToAnsi(STR0039) + cConcurso ,1,0)
	ElseIf !( AllTrim(CFILFUN) $ fValidFil() )
		MsgAlert(OemToansi(STR0040) ,  OemToAnsi( STR0041 ) ) //Usuario sem acesso a filial escolhida. Favor escolher outra filial.###Atencao
		lRet := .F.
	Else
		oModel:GetModel( 'REYDETAIL' ):SetValue('REY_FILFUN',cFilFun)
	EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} fDelREY
Função para deleção das linhas do grid REZ quando realizada deleção da linha na REY
@return	lRet, lógico, resultado da validação do campo.
@author	Marcos Pereira
@since		18/12/2014
@version	P11.9
/*/
//------------------------------------------------------------------------------
Static Function fDelREY(oGrid,nLine,cAction)
	Local lRet			:= .T.
	Local nLineREZ		:= 0
	Local oModel		:= oGrid:GetModel()
	Local oGridREZ		:= oModel:GetModel('REZDETAIL')
	Local oGridREY      := oModel:GetModel('REYDETAIL')

	If cAction == "DELETE"
		If QueryRI6( oGridREY:GetValue('REY_CPF') + oGridREY:GetValue('REY_CODCON') + oGridREY:GetValue('REY_FILFUN') + oGridREY:GetValue('REY_CODFUN'),oGridREY:GetValue('REY_FILFUN'),"","REY" ) <> "P"
			For nLineREZ := 1 to oGridREZ:Length()
				oGridREZ:GoLine(nLineREZ)
				oGridREZ:DeleteLine()
			Next nLineREZ
			oGridREZ:GoLine(1)
		Else
			lRet := .F.
			Help(,,STR0042,,STR0022,1,0, NIL, NIL, NIL, NIL, NIL, {STR0043}) //Já houve a publicação do Item, portanto ele não poderá ser excluído.
		EndIf
	ElseIf cAction == "UNDELETE"
		For nLineREZ := 1 to oGridREZ:Length()
			oGridREZ:GoLine(nLineREZ)
			oGridREZ:UnDeleteLine()
		Next nLineREZ
		oGridREZ:GoLine(1)
	EndIf
Return lRet



//------------------------------------------------------------------------------
/*/{Protheus.doc} fVldCodCon
Função para carregar o grid REZ - Requisitos da Função do Concurso
@return	lRet, lógico, resultado da validação do campo.
@author	Marcos Pereira
@since		18/12/2014
@version	P11.9
/*/
//------------------------------------------------------------------------------
Static Function fVldCodCon(oGrid)
Local lRet			:= .T.
Local aArea			:= GetArea()
Local nLine			:= 0
Local nLineAtual	:= oGrid:GetLine()
Local cFilCon		:= oGrid:GetValue('REY_FILIAL')
Local cConcurso		:= oGrid:GetValue('REY_CODCON')
Local cFilFun		:= ''
Local cFuncao		:= ''
Local cMensagem		:= ''
Local cLinhaValor	:= ''
Local oModel		:= oGrid:GetModel()

	If !Empty(cConcurso)
			For nLine := 1 to oGrid:Length()
				cLinhaValor := oGrid:GetValue('REY_FILIAL',nLine)+oGrid:GetValue('REY_CODCON',nLine)
				If !(nLine == nLineAtual) .AND. (cFilCon+cConcurso == cLinhaValor) .AND. !oGrid:IsDeleted() .AND. !oGrid:IsDeleted(nLine)
					lRet := .F.
					cFilFun := oGrid:GetValue('REY_FILFUN',nLine)
					cFuncao := oGrid:GetValue('REY_CODFUN',nLine)
					cMensagem := OemToAnsi(STR0032) + cValToChar(nLine) + ". "+ CRLF + CRLF //"Concurso já vinculado ao candidato na linha "
					cMensagem += OemToAnsi(STR0033) +  cConcurso + CRLF + OemToAnsi(STR0034) + cFilFun + CRLF + OemToAnsi(STR0035) + cFuncao + oGrid:GetValue('REY_DESFUN',nLine) //"Concurso: "##"Filial da Função: "##"Função: "
					cMensagem += CRLF + CRLF + OemToAnsi(STR0036) //"Escolha outro Concurso."
					Help(,,"HELP",, cMensagem ,1,0)
					Exit
				EndIf
			Next nLine
	EndIf

RestArea(aArea)
Return lRet

/*/{Protheus.doc} fVldPublic
	Valida publicação antes de exclusão
	@type  Function
	@author gabriel.almeida
	@since 29/10/2019
	@version version
	@param oModel, objeto, Modelo de dados
	/*/
Function fVldPublic(oModel)
	Local oGridREY := oModel:GetModel('REYDETAIL')
	Local nX       := 0

	For nX := 1 To oGridREY:Length()
		oGridREY:GoLine(nX)

		If oGridREY:IsDeleted()
			If QueryRI6( oGridREY:GetValue('REY_CPF') + oGridREY:GetValue('REY_CODCON') + oGridREY:GetValue('REY_FILFUN') + oGridREY:GetValue('REY_CODFUN'),oGridREY:GetValue('REY_FILFUN'),"","REY" ) == "NP"
				ExcluiRI6()
			EndIf
		EndIf
	Next nX
Return .T.