#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FINA667.ch'

#DEFINE OPER_LIBERAR	10
#DEFINE OPER_HIST_LIB	11
#DEFINE OPER_APROVAR	13
#DEFINE OPER_APRVLOTE	12
#DEFINE OPER_LIBPAGTO	14
#DEFINE OPER_LIBPGTOLT	15
#DEFINE OPER_ESTLIBPGTO	16
#DEFINE OPER_CONFPG_EST	17
#DEFINE OPER_ENVWF		18

Static __nOper			:= 0 // Operacao da rotina
Static __cProcPrinc		:= "FINA667"
Static __lConfirmar		:= .T.
Static __lBTNConfirma	:= .F.
Static __lBTNReprova	:= .F.
Static __lReprovou		:= .F.
Static aUser			:= {}

//Static para contingência do uso da função MTFLUIGATV
Static __lMTFLUIGATV := FindFunction("MTFLUIGATV")

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA667
manutenção de adiantamento de viagem

@author pequim
@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function FINA667()
Local oBrowse
Local lRet 		:= .T.

// Incluido por causa da rotina MSDOCUMENT, o MVC não precisa de nenhuma variável private
Private cCadastro	:= STR0001 //'Adiantamentos de Viagens'
Private aRotina	:= MenuDef()
Private cFiltro	:= ""

ChkFile("FLD")

//Limpa array para atualizacao do __cUserID
aUser := {}
//Valida e retorna filtro de visao do usuário do adiantamento de viagens
lRet := F667FilBrowse (@cFiltro)

If lRet
	dbSelectArea('FLD')
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'FLD' )
	oBrowse:SetDescription( cCadastro )
	oBrowse:SetFilterDefault( cFiltro )
	oBrowse:AddLegend( "(FLD_STATUS == '5' .OR. FLD_ENCERR== '1')", "BLACK"  	, STR0008	)		//'Encerrado'
	oBrowse:AddLegend( "FLD_STATUS == '0'", "RED"	, STR0003	)		//'Negado'
	oBrowse:AddLegend( "FLD_STATUS == '1'", "YELLOW", STR0004	)		//'Solicitado'
	oBrowse:AddLegend( "FLD_STATUS == '2'", "GREEN"	, STR0005	)		//'Aprovado'
	oBrowse:AddLegend( "FLD_STATUS == '3'", "PINK"  , STR0006	)		//'Liberado Pagamento'
	oBrowse:AddLegend( "FLD_STATUS == '4'", "BLUE"  , STR0007	)		//'Pago'
	oBrowse:AddLegend( "FLD_STATUS == '6'", "ORANGE", STR0009	)		//'Bloqueado'
	oBrowse:AddLegend( "FLD_STATUS == '7'", "WHITE" , STR0010	)		//'Sem Valor'
	oBrowse:AddLegend( "FLD_STATUS == '8'", "BROWN" , STR0011	)		//'Avaliação Gestor'
	oBrowse:AddLegend( "FLD_STATUS == '9'", "LBLUE" , STR0117	)		//'Cancelado' 
	oBrowse:Activate()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Menudef
Definição do Menu

@author pequim

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina 	:= {}
Local aUserMenu 	:= {}

ADD OPTION aRotina TITLE STR0013	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0 //'Pesquisar'
ADD OPTION aRotina TITLE STR0014	ACTION 'VIEWDEF.FINA667'	OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0015	ACTION 'VIEWDEF.FINA667'	OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0016	ACTION 'VIEWDEF.FINA667'	OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE STR0017	ACTION 'F667LIBERA'			OPERATION 2 ACCESS 0 //'Liberar'
ADD OPTION aRotina TITLE STR0131	ACTION 'F667ENVWF'			OPERATION 7 ACCESS 0 //'Reenvio WF'
ADD OPTION aRotina TITLE STR0018	ACTION 'VIEWDEF.FINA667H'	OPERATION 2 ACCESS 0 //'Hist. Liberação'
ADD OPTION aRotina TITLE STR0019	ACTION 'F667APRADI'			OPERATION 2 ACCESS 0 //'Aprovar'
ADD OPTION aRotina TITLE STR0020	ACTION 'F667APRVLT'			OPERATION 2 ACCESS 0 //'Aprovar (Lote)'
ADD OPTION aRotina TITLE STR0021	ACTION 'F667LIBPGT'			OPERATION 2 ACCESS 0 //'Liberar Pagto'
ADD OPTION aRotina TITLE STR0022	ACTION 'F667LIBPGLT'		OPERATION 2 ACCESS 0 //'Lib.Pagto.(Lote)'
ADD OPTION aRotina TITLE STR0023	ACTION 'F667ESLIBPG'		OPERATION 2 ACCESS 0 //'Estorno Lib. Pgto'
ADD OPTION aRotina TITLE STR0024	ACTION 'F667CFPGEST'		OPERATION 2 ACCESS 0 //'Confirma Pgto/Estorno'
ADD OPTION aRotina TITLE STR0124	ACTION 'FINA689TXM'			OPERATION 4 ACCESS 0 //"Cotação de moedas de Adtos Viagem"

// Ponto de entrada para acrescentar botões no menu
If ExistBlock('F667USERMENU')
      aUserMenu := ExecBlock( 'F667USERMENU')
      If ValType( aUserMenu ) == 'A'
            aEval( aUserMenu, { |aAux| aAdd( aRotina, aAux ) } )
      EndIf
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author pequim

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local aRelFLM	:= {}
	Local oModel	:= NIL
	Local oStr1	 	:= F667STRUCT()
	Local oStruFLM 	:= FWFormStruct(1, "FLM")

	oModel := MPFormModel():New('FINA667', /*bPreValid*/, { |oModel| F667POSVL(oModel) },  { |oModel| F667GRVMD( oModel ) } )
	oModel:SetDescription(STR0001)		//'Adiantamentos de Viagens'

	oModel:addFields('FLDMASTER',,oStr1)
	oModel:addGrid('FLMDETAIL','FLDMASTER',oStruFLM)

	aAdd(aRelFLM,{'FLM_FILIAL','xFilial("FLM")'})
	aAdd(aRelFLM,{'FLM_VIAGEM','FLD_VIAGEM'})
	aAdd(aRelFLM,{'FLM_PARTIC','FLD_PARTIC'})
	aAdd(aRelFLM,{'FLM_ADIANT','FLD_ADIANT'})
	oModel:SetRelation('FLMDETAIL', aRelFLM, FLM->(IndexKey(1)))

	oStruFLM:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)
	oStruFLM:SetProperty('FLM_NOMEAP', MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD) )
	oModel:GetModel('FLMDETAIL'):SetOptional(.T.)

	oModel:getModel('FLDMASTER'):SetDescription(STR0001)	//'Adiantamentos de Viagens'

	oModel:SetVldActivate( {|oModel| F667VLMod(oModel) } )
	oModel:SetActivate( {|oModel| F667LoadMod(oModel) } )

	If	__nOper == OPER_ENVWF
		oModel:lModify := .T.
	EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author pequim

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel	 := ModelDef()
Local oStr1		 := FWFormStruct(2, 'FLD')
Local nOperation := oModel:GetOperation()
Local cConfirma	 := STR0025 	//"Confirma"
Local oStruFLM	 := FWFormStruct(2, "FLM")

oStruFLM:removeField('*')	// FLM nao deve compor a view

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('FORM1' , oStr1, 'FLDMASTER')
oView:CreateHorizontalBox( 'BOXFORM1', 100)
oView:SetOwnerView('FORM1', 'BOXFORM1')
oView:EnableTitleView('FORM1', STR0001) 	//'Adiantamentos de Viagens'

If __nOper == OPER_APROVAR
	oStr1:SetProperty("FLD_APROV"  ,MVC_VIEW_ORDEM, '90')
	oStr1:SetProperty("FLD_NOMEAP" ,MVC_VIEW_ORDEM, '91')
	oStr1:SetProperty("FLD_VALAPR" ,MVC_VIEW_ORDEM, '92')
	oStr1:SetProperty("FLD_DTAPRO" ,MVC_VIEW_ORDEM, '93')
	If(__lMTFLUIGATV)
		
		oStr1:SetProperty("FLD_WFOBS" ,MVC_VIEW_ORDEM, '94')

	EndIf
	cConfirma := STR0019	//"Aprovar"

Endif

If nOperation != MODEL_OPERATION_INSERT
	oView:SetCloseOnOk({||.T.})
Endif

//Botoes de usuario
If __lBTNConfirma
	oView:AddUserButton( cConfirma , 'OK', {|oView| F667ConfVs(oView) } )
Endif

If __lBTNReprova
	oView:AddUserButton( STR0026 , 'OK', {|oView| F667ConfVs(oView) } )		//'Reprovar'
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F667FilBrowse
Filtro da Browse

@author pequim

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function F667FilBrowse (cFiltro)

Local cUsuarios		:= ""
Local cStatus		:= ""
Local cParticDe		:= Replicate (" ", Len(FLD->FLD_PARTIC)) // Space(Len(SE1->E1_NATUREZ))
Local cParticAte	:= Replicate ("Z", Len(FLD->FLD_PARTIC)) // Space(Len(SE1->E1_NATUREZ))
Local nParCont		:= 0
Local nX			:= 0
Local lContinua 	:= .T.
Local lTodos		:= .F.
Local aPerguntas	:= {}
Local aUsers		:= {}
Local aParam		:= {}
Local dDataIni		:= FirstDay(dDataBase)
Local dDataFim		:= LastDay(dDataBase)
Local lF667Fil 		:= ExistBlock("F667FilBrw")

DEFAULT cFiltro := ""

//Valida acesso do usuário
aUsers := FN683PARTI()

//Usuario sem qualquer acesso
If Alltrim(aUsers[1]) == "NO"
	Help("  ",1,"NO_ACCESSS_667",,STR0027,1,0)		//"Usuário sem acesso para manipular adiantamentos de viagem."
	lContinua := .F.
ElseIf Alltrim(aUsers[1]) == "ALL"
	lTodos := .T.
Else
	For nX := 1 to Len(aUsers)
		cUsuarios += Alltrim(aUsers[nX])+"|"
	Next
Endif

If lContinua
	aPerguntas := { { 1, STR0028	, cParticDe  ,"@!",'.T.',"RD0",".T.",60, .F.},;	//"Participante De"
					{ 1, STR0029	, cParticAte ,"@!",'.T.',"RD0",".T.",60, .F.},;		//"Participante Até"
					{ 1, STR0030	, dDataIni   ,""  ,'.T.',""   ,".T.",50, .T.},;		//"Dt. Prev. Pag De"
					{ 1, STR0031	, dDataFim   ,""  ,'.T.',""   ,".T.",50, .T.},;		//"Dt. Prev. Pag Até"
					{ 9, STR0032	, 100, 15 , .T. },;										//"Status"
					{ 5, STR0003    , .T., 100,, .T. },;									//"Negado"
					{ 5, STR0004    , .T., 100,, .T. },;									//"Solicitado"
					{ 5, STR0005    , .T., 100,, .T. },;									//"Aprovado"
					{ 5, STR0006	, .T., 100,, .T. },;										//"Liberado Pagto"
					{ 5, STR0007    , .T., 100,, .T. },;									//"Pago"
					{ 5, STR0008	, .T., 100,, .T. },; 									//"Encerrado"
					{ 5, STR0009    , .T., 100,, .T. },;									//"Bloqueado"
					{ 5, STR0010    , .T., 100,, .T. },;									//'Sem Valor'
					{ 5, STR0011    , .T., 100,, .T. }}									//'Avaliação Gestor'

	lContinua := ParamBox( aPerguntas,STR0033,aParam,{||.T.},,,,,,FunName(),.T.,.T.)	//"Parâmetros"

	//-----------------------------------------------------------
	// Garantindo que os valores do parambox estarão nas devidas variáveis MV_PARXX
	//-----------------------------------------------------------
	If lContinua
		For nParCont := 1 To Len(aParam)
			&("MV_PAR"+CVALTOCHAR(nParCont)) := aParam[nParCont]
		Next nParCont

		dDataIni	:= mv_par03
		dDataFim	:= mv_par04

		//Valida se selecionou algum Status para filtro
		//Caso contrário, sai da rotina
		If !mv_par06 .and. !mv_par07 .and.!mv_par08 .and.!mv_par09 .and.!mv_par10 .and.!mv_par11 .and.!mv_par12 .and. !mv_par13 .and. !mv_par14
			cFiltro := ""
			lContinua := .F.
		Endif
	Endif
Endif

If lContinua

	//Participantes De/Até
	//Usuario tem acesso irrestrito (Todos os participantes de adiantamentos de viagem)
	If lTodos
		cFiltro := "FLD_PARTIC >= '"+ cParticDe + "' .and. FLD_PARTIC <= '"+ cParticAte + "' .and. "
	Else
		cFiltro := "FLD_PARTIC $ '" + cUsuarios + "' .and. "
	Endif

	//Datas de previsão de pagamento De/Até
	cFiltro += "DTOS(FLD_DTPREV) >= '"+ DTOS(dDataIni) + "' .and. "
	cFiltro += "DTOS(FLD_DTPREV) <= '"+ DTOS(dDataFim) + "' "

	/*/
		Status:
		0 = Negado
		1 = Solicitado
		2 = Aprovado
		3 = Liberado Pagto
		4 = Pago
		5 = Encerrado
		6 = Bloqueado
		7 - Ag. Valor
		8 = Ag. Liberação
	/*/
	//Se não forem selecionados todos os status, avalio cada um deles
	If !(mv_par06 .and. mv_par07 .and. mv_par08 .and. mv_par09 .and. mv_par10 .and. mv_par11 .and. mv_par12 .and.  mv_par13 .and. mv_par14)
		//0 = Negado
		If mv_par06
			cStatus += "0|"
		Endif
		//1 = Solicitado
		If mv_par07
			cStatus += "1|"
		Endif
		//2 = Aprovado
		If mv_par08
			cStatus += "2|"
		Endif
		//3 = Liberado Pagto
		If mv_par09
			cStatus += "3|"
		Endif
		//4 = Pago
		If mv_par10
			cStatus += "4|"
		Endif
		//5 = Encerrado
		If mv_par11
			cStatus += "5|"
		Endif
		//6 = Bloqueado
		If mv_par12
			cStatus += "6|"
		Endif
		//7 - Ag. Valor
		If mv_par13
			cStatus += "7|"
		Endif
		//8 = Ag. Liberação
		If mv_par14
			cStatus += "8|"
		Endif

		//Monta a expressao de filtro
		If !Empty(cStatus)
			If !Empty(cFiltro)
				cFiltro += " .and. "
			Endif
			cFiltro += "FLD_STATUS $ '"+ cStatus + "' "
		Endif
	Endif
	
	If lF667Fil
		 cFiltro := ExecBlock("F667FilBrw",.F.,.F.,{cFiltro})
	EndIf
	
EndIf

Return lContinua

//-------------------------------------------------------------------
/*/{Protheus.doc} F667VLMod
Inicializador do Model

@author pequim

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function  F667VLMod(oModel)

Local nOperation := oModel:GetOperation()
Local lRet		:= .T.

//Adiantamento encerrado
If FLD->FLD_ENCERR == '1' .AND. nOperation <> MODEL_OPERATION_VIEW  .AND. nOperation <> MODEL_OPERATION_INSERT
	Help(" ",1,"F667ENCER",,STR0034 ,1,0)	//"Este adiantamento de viagem foi encerrado, não sendo possivel realizar manutenção no mesmo."
	lRet := .F.
Endif

//Exclusão
If lRet .And. nOperation == MODEL_OPERATION_DELETE .And. __nOper == 0 .And. !FLD->FLD_STATUS $ "1|8" //Status Solicitado e Avaliação Gestor
	Help(" ", 1, "F667ADTDEL", Nil, STR0035, 1, 0) //Este adiantamento de viagem não poderá ser excluido. Apenas adiantamentos com status igual a Solicitado ou Avaliação Gestor podem ser excluidos
	lRet := .F.
EndIf

//Alteração
If  lRet .and. (nOperation == MODEL_OPERATION_UPDATE ) .AND. __nOper == 0 .AND. !FWIsInCallStack("FResCancAdt") //Cancelamento do Pedido.
	If !(FLD->FLD_STATUS == "6" .AND. FinXValPC(FLD->FLD_PARTIC,.T.,,,FLD->FLD_VIAGEM))
		If FLD->FLD_STATUS $ "0|2"	//Status = 0 (Negado) ou 2 (aprovado) 
			lRet := MSGYESNO(STR0036+CRLF+STR0037,STR0038)		//"Caso deseje alterar este adiantamento, o mesmo voltará para o status <Solicitado>, necessitando nova liberação."###"Deseja Continuar?"###"Atenção"
		ElseIf !(FLD->FLD_STATUS $ "0|1|2|7|8") //Status = 0(Negado) 1(Solicitado) 2 (Aprovado) 7(Sem Valor) 8(Avaliação Gestor)
			Help(" ",1,"F667ADTALT",,STR0039 ,1,0)		//"O status dste adiantamento de viagem não permite alterações."
			lRet := .F.
		Endif
	Endif
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F667LoadMod
Inicializador de valores da View

@author pequim

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function F667LoadMod(oModel)

Local nTamAprv 	:= TamSx3("FLD_NOMEAP")[1]
Local lRet		:= .T.

If !Empty(aUser) .and. __nOper == OPER_APROVAR
	oModel:LoadValue("FLDMASTER","FLD_VALAPR" , FLD->FLD_VALOR )
	oModel:LoadValue("FLDMASTER","FLD_APROV"  , aUser[1] )
	oModel:LoadValue("FLDMASTER","FLD_NOMEAP" , PadR(aUser[2],nTamAprv) )
	oModel:LoadValue("FLDMASTER","FLD_DTAPRO" , dDatabase )
Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F667POSVL
Validação final do model

@author pequim

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function F667POSVL(oModel)

Local lRet		:= .T.
Local cMoeda	:= oModel:GetValue("FLDMASTER","FLD_MOEDA")
Local cViagem	:= oModel:GetValue("FLDMASTER","FLD_VIAGEM")
Local nVlrSol	:= oModel:GetValue("FLDMASTER","FLD_VALOR")
Local nVlrAprv	:= oModel:GetValue("FLDMASTER","FLD_VALAPR")
Local cObsAprv	:= IIf(__lMTFLUIGATV,oModel:GetValue("FLDMASTER","FLD_WFOBS"),"")
Local aArea		:= GetArea()

//Valida moeda do adiantamento
If __nOper == 0
	FL5->(DbSetOrder(1)) //FL5_FILIAL+FL5_VIAGEM
	If FL5->(MsSeek(xFilial("FL5") + cViagem))  
		If FL5->FL5_NACION == '1' .AND. cMoeda != "1"
			Help("  ",1,"MOEDANAC",,STR0040,1,0)	//"Por ser uma viagem nacional, a moeda deve ser a moeda corrente do país"
			lRet := .F.
		Endif
	Endif
Endif
	
If __nOper == OPER_APROVAR
	If !__lReprovou
		If nVlrAprv <= 0 
			Help("  ",1,"VLRAPROV",,STR0041,1,0)	//"Valor de aprovação deve ser maior que zero. Verifique o preenchimento do campo <Vl. Aprovado>."
			lRet := .F.
		ElseIf nVlrAprv != nVlrSol .AND. Empty(cObsAprv)
			Help("  ",1,"OBSAPROV",,STR0042,1,0)	//"Favor preencher o campo <Obs. Aprov.>."
			lRet := .F.
		EndIf
		//
		F667BloqAdi(oModel)
	Endif
Endif

RestArea (aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F667GRVMD
Gravação do adiantamento (FLD)

@author pequim

@since 29/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function F667GRVMD( oModel )

Local nOperation := oModel:GetOperation()
Local cViagem	 := oModel:GetValue("FLDMASTER","FLD_VIAGEM")
Local cPartic	 := oModel:GetValue("FLDMASTER","FLD_PARTIC")
Local cAdiant	 := oModel:GetValue("FLDMASTER","FLD_ADIANT")
Local lAtrasos	 := .F.
Local aAprv		 := FResAprov("1") //"1" = Adiantamentos
Local cUser		 := ""
Local aUsers	 := {}
Local cProcWF	 := "SOLADIANTA"
Local cChaveFLM	 := ""

/*
	PCREQ-3829 Aprovação Automática
	
	aAprv[1] - Aprovação de Solicitação (.T. or .F.)
	aAprv[2] - Avaliação do Gestor (.T. or .F.)
	aAprv[3] - Lib. do Pagamento (.T. or .F.)
*/

If (nOperation == MODEL_OPERATION_DELETE ) .AND. __nOper == 0
    FLM->(dbSetOrder(1))	// FLM_FILIAL+FLM_VIAGEM+FLM_PARTIC+FLM_ADIANT
	If FLM->(MSSeek(xFilial("FLM")+cViagem+cPartic+cAdiant))
		cChaveFLM := xFilial("FLM")+cViagem+cPartic+cAdiant
		While FLM->(!EOF()) .AND. FLM->(FLM_FILIAL+FLM_VIAGEM+FLM_PARTIC+FLM_ADIANT) == cChaveFLM
			//Cancelamento da Solicitação de Aprovação no FLUIG
			F667CanFlu(FLM->FLM_VIAGEM,FLM->FLM_PARTIC,FLM->FLM_ADIANT)
			FLM->(DbSkip())
		EndDo
	Endif
Endif

//Realiza a gravação do Modelo
FWFormCommit( oModel )

If  (nOperation == MODEL_OPERATION_UPDATE) .AND. __nOper == 0 .AND. !FWIsInCallStack("FResCancAdt")
	//Usuário com pendência quanto a 
	// - Prestação de contas em atraso
	// - Excesso de prestação de contas
	If lAtrasos := !(FinXValPC(cPartic,.T.,,,cViagem))
		cStatus := '6'	//Bloqueado
	ElseIf !(FLD->FLD_STATUS == '8')	//Avaliação Gestor
		cStatus := '1'	//Solicitado
		//Cancelamento da Solicitação de Aprovação no FLUIG
		F667CanFlu(FLD->FLD_VIAGEM,FLD->FLD_PARTIC,FLD->FLD_ADIANT)		
	Endif

	//Atualizo o status do adiantamento
	If !(FLD->FLD_STATUS == '8') //Avaliação Gestor
		RecLock("FLD")
		FLD->FLD_STATUS := cStatus
		MsUnlock()
	Endif
Endif

//Aprovação
If  (nOperation == MODEL_OPERATION_UPDATE ) .AND. __nOper == OPER_APROVAR
	FI667APGES(FLD->FLD_VIAGEM,FLD->FLD_PARTIC,FLD->FLD_ADIANT,__lReprovou)
	F667CanFlu(cViagem,cPartic,cAdiant)
	__lReprovou := .F.
Endif

//Envio WF
If (!IsInCallStack("F666ENVCON")) .and. (nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT ) .AND. ( __nOper == OPER_ENVWF .Or. __nOper == 0 )
	If aAprv[2]
		If FLD->FLD_STATUS == "8" .Or. FLD->FLD_STATUS == "1"
			If __lMTFLUIGATV
				If MTFluigAtv("WFFINA667", cProcWF, "WFFIN667")
					If Empty(FLD->FLD_WFKID)
						FI667WF(cViagem, cPartic,FLD->FLD_ADIANT, cUser, aUsers)
					Else
						If nOperation == MODEL_OPERATION_UPDATE .And.  __nOper == 0
							F667CanFlu(FLD->FLD_VIAGEM,FLD->FLD_PARTIC,FLD->FLD_ADIANT)
							FI667WF(cViagem, cPartic,FLD->FLD_ADIANT, cUser, aUsers)
						Else
							Help(" ",1,"F667WFEXIST",,STR0128 + FLD->FLD_WFKID, 1, 0) //"Já existe no Fluig o precesso: "
						Endif
					EndIf
				EndIf
			EndIf
		Else
			Help(" ",1,"F667STATUS",,STR0129, 1, 0) //"Status não permite o reenvio"
		EndIf
	EndIf
Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F677STRUCT
Montagem da estrutura do model

@author Mauricio Pequim Jr
@since 29/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function F667STRUCT()

Local oStruct 		:= FWFormStruct( 1, "FLD", /*bAvalCampo*/, /*lViewUsado*/ )

If  __nOper == 0
	oStruct:SetProperty( 'FLD_VALAPR' , MODEL_FIELD_WHEN , {|| .F. } )
	If(__lMTFLUIGATV)

		oStruct:SetProperty( 'FLD_WFOBS' , MODEL_FIELD_WHEN , {|| .F. } )

	EndIf
Endif

If __nOper == OPER_APROVAR
	// Bloqueia todos os campos menos valor de aprovação e Observacao do aprovador
	oStruct:SetProperty( '*'          , MODEL_FIELD_WHEN , {|| .F. } )
	oStruct:SetProperty( 'FLD_VALAPR' , MODEL_FIELD_WHEN , {|| .T. } )
	If(__lMTFLUIGATV)
		
		oStruct:SetProperty( 'FLD_WFOBS' , MODEL_FIELD_WHEN , {|| .T. } )

	EndIf
Endif

Return oStruct


//-------------------------------------------------------------------
/*/{Protheus.doc} F667APRADI
Aprovação de adiantamento

@author Mauricio Pequim Jr
@since 29/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------

Function F667APRADI(cAlias,nReg,nOpc,lAutomato)

Local aArea			:= GetArea()
Local cTitulo 		:= ""
Local cPrograma 	:= ""
Local nOperation 	:= MODEL_OPERATION_UPDATE
Local lRet			:= .T.
Local cStatus 		:= ""
Local aEnableButtons	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0019},{.T.,STR0044},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Aprovar"###"Fechar"
Local bOk				:= {|| If(MsgYesNo (STR0043,STR0038), F667VldV(), .F. ) }		//"Confirma a aprovação do adiantamento ?"###"Atenção"
Local oModel 			:= Nil
Local aAprv			:= FResAprov("1") //"1" = Adiantamentos

Default lAutomato	:= .F.

/*
	PCREQ-3829 Aprovação Automática
	
	aAprv[1] - Aprovação de Solicitação (.T. or .F.)
	aAprv[2] - Avaliação do Gestor (.T. or .F.)
	aAprv[3] - Lib. do Pagamento (.T. or .F.)
*/

//PE - Manipula os processos de aprovação para exceções
If ExistBlock("F667STRAPR") 
	
	//aAprv[1] - Aprovação de Solicitação (.T. or .F.)
	//aAprv[2] - Avaliação do Gestor (.T. or .F.)
	//aAprv[3] - Lib. do Pagamento (.T. or .F.)
	
	aAprv := ExecBlock( "F667STRAPR", .F., .F., {aAprv} )
EndIf

If Empty(aUser)
	lRet := FINXUser(__cUserId,aUser,.T.)
Endif

//PCREQ-3829 Aprovação Automática
If !aAprv[2]//Se aAprv[2] == .F., Avaliação do Gestor está configurado para aprovação automatica
	lRet := .F.
	Help(" ",1,"F667APROA",,STR0120,1,0)//Processo de avaliação do gestor não habilitado
Endif

//Verifica o aprovador do adiantamento
If lRet
	oModel := FWLoadModel('FINA667')
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	If oModel:Activate()
		If ExistBlock("F667APROP")
			lRet := ExecBlock("F667APROP",.F.,.F.)
		Else
			lRet := F667AdiAprov(oModel, aUser)
		EndIf
		
		//Exibe help caso o usuário não seja o aprovador da viagem
		If !lRet
			Help(" ",1,"F667ADTNAP",, STR0119 ,1,0)		//O usuário não é aprovador deste adiantamento
		EndIf
	Else
		lRet := .F.
	Endif
EndIf
	
If lRet .and. !(FLD->FLD_STATUS $ "1|6")	//Status = Avaliação Gestor

	cStatus := F667Status(FLD->FLD_STATUS)

	Help(" ",1,"F667ADTAPR",,STR0045 + CRLF + STR0032 + " ==> " + cStatus ,1,0) //"O status dste adiantamento de viagem não permite aprovações."###"Atenção"
	lRet := .F.
Endif

If lRet
	cTitulo			:= STR0046	//"Aprovação de Adiantamento"
	cPrograma		:= 'FINA667'
	nOperation		:= MODEL_OPERATION_UPDATE //Alterar
	__lConfirmar	:= .F.
	__nOper			:= OPER_APROVAR
	__lBTNConfirma	:= .F.
	__lBTNReprova	:= .T.
	If !lAutomato
		FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/, bOk , /*nPercReducao*/, aEnableButtons, /*bCancel*/ )
	Else
		If oModel:VldData()
			oModel:CommitData()
		Else
			cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[6])        	
		Endif
	EndIf

EndIf

__lConfirmar	:= .F.
__lReprovou		:= .F.
__lBTNConfirma	:= .F.
__lBTNReprova	:= .F.
__nOper			:= 0

RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F667LIBPGT
Aprovação de adiantamento

@author Mauricio Pequim Jr
@since 29/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------

Function F667LIBPGT(cAlias,nReg,nOpc,lAutomato)

Local aArea			:= GetArea()
Local cTitulo 		:= ""
Local cPrograma 	:= ""
Local nOperation 	:= MODEL_OPERATION_VIEW //Visualizar
Local lRet			:= .T.
Local cStatus 		:= ""
Local nRecno		:= FLD->(recno())
Local cNaturez		:= SuperGetMV("MV_RESNTAD",.T.,"")
Local nTamNat		:= TamSx3("E2_NATUREZ")[1]
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0044},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
Local nAdiTxMe		:= SuperGetMV("MV_ADITXME",.T.,1)

Default lAutomato	:= .F.

If Empty(aUser)
	lRet := FINXUser(__cUserId,aUser,.T.)
Endif

If lRet .and. FLD->FLD_STATUS != "2"	//Status = Aprovado
	cStatus := F667Status(FLD->FLD_STATUS)
	Help(" ",1,"F667ADTLPG",,STR0047+CRLF+STR0032+" ==> "+cStatus ,1,0)	//"O status dste adiantamento de viagem não permite liberações para pagamento."###"Status"
	lRet := .F.
Endif

If lRet
	RD0->(dbSetOrder(1))	//Filial + Codigo
	If RD0->(MsSeek( xFilial("RD0") + FLD->FLD_PARTIC ))
		If Empty(RD0->RD0_FORNEC) .or. Empty(RD0->RD0_LOJA)
			Help("  ",1,"NO_FORNEC",,STR0048,1,0)	//"Participante não possui cadastro de fornecedor relacionado ao mesmo para geração de adiantamento."
			lRet := .F.
		Endif
	Endif
Endif
//Valida a natureza do titulo a ser gerado
If lRet
	 If !Empty(cNaturez)
		lRet := FinVldNat( .F., PadR(cNaturez,nTamNat), 0 , 2 )
	Else
		Help("  ",1,"NO_NATUREZ",,STR0049 +CRLF+ STR0052,1,0)	//"Para efetivação da liberaçã0 é necessário parametrizar a natureza do titulo a ser gerado."###"Verifique o parâmetro < MV_RESNTAD >."
		lRet := .F.
	Endif
Endif

//Valida taxa da moeda
If lRet .and. nAdiTxMe == 1 .and. FLD->FLD_MOEDA != '1'.and. FLD->FLD_TAXA == 0 
	Help("  ",1,"NO_COTACAO",,STR0122+CRLF+STR0123,1,0)		//"Para efetivação da liberaçãO é necessário informar a cotação da moeda para este adiantamento."###"Utilize a rotina de Cotação de Moedas para informar a cotação."
	lRet := .F.
Endif

If lRet
	cTitulo 		:= STR0050		//"Liberar Pagamentos"
	cPrograma 		:= 'FINA667'
	nOperation	 	:= MODEL_OPERATION_VIEW //Visualizar
	__lConfirmar	:= .F.
	__lReprovou 	:= .F.
	__nOper     	:= OPER_LIBPAGTO
	__lBTNConfirma  := .T.
	__lBTNReprova	:= .F.

	If !lAutomato
		FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/, /*bOk*/ , /*nPercReducao*/, aEnableButtons, /*bCancel*/ )
	Else	
		__lConfirmar	:= .T.
	EndIf

	If __lConfirmar
		MsgRun( STR0051,, {||	lRet := F667GeraLib(1,nRecno,.T.) } ) //"Processando liberação de pagamento..."
	EndIf

EndIf

__lConfirmar := .F.
__lReprovou  := .F.
__lBTNConfirma  := .F.
__lBTNReprova	:= .F.
__nOper     := 0

RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F667ConfVs
Aprovação de adiantamento - Botoes

@author Mauricio Pequim Jr
@since 29/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function F667ConfVs(oView)

Local cStatus	:= FLD->FLD_STATUS
Local cMensagem := ""
Local nOpcao  := 1

If __nOper == OPER_APROVAR
	cMensagem := STR0053	//"Confirma a reprovação do adiantamento ?"
	__lReprovou := .T.
	nOpcao	:= 2
Endif

If __nOper == OPER_LIBPAGTO
	cMensagem := STR0054	//"Confirma a liberação para o pagamento deste adiantamento ?"
Endif

If __nOper == OPER_CONFPG_EST
	If cStatus == '3' //Liberado para pagamento
		cMensagem := STR0055	//"Confirma o pagamento deste adiantamento ?"
	ElseIf  cStatus == '4' //Pago
		cMensagem := STR0056	//"Confirma o estorno do pagamento deste adiantamento ?"
	Endif
Endif

If __nOper == OPER_ESTLIBPGTO
	cMensagem := STR0057	//"Confirma o cancelamento da liberação de pagamento deste adiantamento ?"
Endif

If __nOper > 0
	If nOpcao == 1
		If MsgNoYes(cMensagem)
			__lConfirmar := .T.
			oView:ButtonCancelAction()
		EndIf
	Else	
		/*/	
		ATENCAO - NAO MUDAR __lConfirmar para .T.	
		------------------------------------------------------------------------
		Manter __lConfirmar := .F. pois necessitamos de que a tela feche
		Caso seja mudado para .T., o MVC faz refresh na View e não fecha a tela
		/*/	

		__lConfirmar := .F.
		If MsgNoYes(cMensagem)
			//Manda Email para o participante - Negado (Depto Viagens)
			F667MsgMail(3,,,,FLD->FLD_VIAGEM,FLD->FLD_ITEM,FLD->FLD_PARTIC)

			oView:ButtonOKAction(.T.)
		EndIf
	Endif
Endif

Return .F.


//-------------------------------------------------------------------
/*/{Protheus.doc} F667Status
Retorna descrição do Status do adiantamento

@author Mauricio Pequim Jr
@since 29/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Function F667Status(cCodStatus)

Local cStatus := ""

Default cCodStatus := ''

DO CASE
	CASE cCodStatus == '0'
		cStatus := STR0003	//'Negado'
	CASE cCodStatus == '1'
		cStatus := STR0004	//'Solicitado'
	CASE cCodStatus == '2'
		cStatus := STR0005	//'Aprovado'
	CASE cCodStatus == '3'
		cStatus := STR0006	//'Liberado'
	CASE cCodStatus == '4'
		cStatus := STR0007	//'Pago'
	CASE cCodStatus == '5'
		cStatus := STR0008	//'Encerrado'
	CASE cCodStatus == '6'
		cStatus := STR0009	//'Bloqueado'
	CASE cCodStatus == '7'
		cStatus := STR0010	//'Sem Valor'
	CASE cCodStatus == '8'
		cStatus := STR0011	//'Avaliação Gestor'
END CASE

Return cStatus


//-------------------------------------------------------------------
/*/{Protheus.doc} F667GeraLib
Gera titulo contas a pagar no Financeiro (Lib. Pagto)
Exclui titulo contas a pagar no Financeiro (Canc Lib Pagto)

@author Mauricio Pequim Jr
@since 29/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Function F667GeraLib(nOpcao, nRecno,lGravaFLD,lLote )

Local aArea		:= GetArea()
Local _aTit 	:= {}
Local lRet		:= .F.
Local cPrefixo	:= SuperGetMV("MV_RESPRFP",.T.,"   ")
Local cNaturez	:= SuperGetMV("MV_RESNTAD",.T.,"")
Local cTipo		:= SuperGetMV("MV_RESTPAD",.T.,"DP ")
Local nTamPrf	:= TamSx3("E2_PREFIXO")[1]
Local nTamNum	:= TamSx3("E2_NUM")[1]
Local nTamParc	:= TamSx3("E2_PARCELA")[1]
Local nTamTipo	:= TamSx3("E2_TIPO")[1]
Local nTamNat	:= TamSx3("E2_NATUREZ")[1]
Local cNumTit	:= ""
Local cFornece	:= ""
Local cLoja		:= ""
Local dDtVenc	:= dDatabase
Local lAdian
Local aCC		:= {}
Local aAuxSEV	:= {}
Local aAuxSEZ	:= {}
Local aRatSEZ	:= {}
Local aRatSEVEZ := {}
Local aFa677Tit := {}
Local nX		:= 0
Local cMoedD	:= cValToChar(f677GetMoeda(1))
Local cMoedE	:= cValToChar(f677GetMoeda(2))
Local cMoedaTit := ''

DEFAULT nOpcao 	:= 1
DEFAULT nRecno 	:= 0
DEFAULT lGravaFLD	:= .F.
DEFAULT lLote		:= .F.

If nRecno > 0
	
	FLD->(dbGoTo(nRecno))
	
	FL6->(dbSetOrder(1))	//FL6_FILIAL + FL6_VIAGEM + FL6_ITEM
	If FL6->(DbSeek( xFilial("FL6") + FLD->FLD_VIAGEM + FLD->FLD_ITEM ))
		lAdian := Upper(AllTrim(FL6->FL6_EXTRA1)) == "SIM" .AND. FLD->FLD_ADIANT <> ''
		cPrefixo := If( lAdian, SuperGetMV("MV_RESPREF",.T.,"   "), SuperGetMV("MV_RESPRFP",.T.,"   ") )
	EndIf
	
	If ExistBlock("F667TIT")
		//Altera os dados do titulo parametrizados no assistente de configuração para regras específicas
		aFa677Tit := ExecBlock("F667TIT",.F.,.F.)
		
		cPrefixo 	:= Iif(Empty(aFa677Tit[1]),cPrefixo,aFa677Tit[1])
		cNaturez 	:= Iif(Empty(aFa677Tit[2]),cNaturez,aFa677Tit[2])
		cTipo		:= Iif(Empty(aFa677Tit[3]),cTipo,aFa677Tit[3])
	EndIf
		
	BEGIN TRANSACTION
		
		//Adiantamento em moeda nacional
		lMsErroAuto := .F.
		lMsHelpAuto := .T.
		If IsBlind()
			lAutoErrNoFile	:= .T.
		EndIf		
		
		If nOpcao == 1
			
			//Obtenho código do fornecedor
			RD0->(dbSetOrder(1))	//Filial + Codigo
			If RD0->(MsSeek( xFilial("RD0") + FLD->FLD_PARTIC ))
				cFornece := RD0->RD0_FORNEC
				cLoja	 := RD0->RD0_LOJA
			Endif
			
			//Gero numero do titulo
			cNumTit	:= ProxTitulo("SE2",cPrefixo)
			dDtVenc := IIF(dDataBase > FLD->FLD_DTPREV, dDataBase, FLD->FLD_DTPREV)
			
			//Caso o registro da FLD esteja "vazio", é um título novo
			If Empty(FLD->(FLD_PREFIX + FLD_TITULO + FLD_PARCEL + FLD_TIPO + FLD_FORNEC + FLD_LOJA))
				
				If FLD->FLD_MOEDA == '2'
					cMoedaTit := cMoedD
				ElseIf FLD->FLD_MOEDA == '3'
					cMoedaTit := cMoedE
				Else
					cMoedaTit := FLD->FLD_MOEDA
				EndIf
				
				_aTit := {}
				AADD(_aTit , {"E2_NUM"		,PadR(cNumTit,nTamNum)									,Nil})
				AADD(_aTit , {"E2_PREFIXO"	,PadR(cPrefixo,nTamPrf)									,Nil})
				AADD(_aTit , {"E2_PARCELA"	,Space(nTamParc)										,Nil})
				AADD(_aTit , {"E2_TIPO"		,PadR(cTipo,nTamTipo)									,Nil})
				AADD(_aTit , {"E2_NATUREZ"	,PadR(cNaturez,nTamNat)									,Nil})
				AADD(_aTit , {"E2_FORNECE"	,cFornece												,Nil})
				AADD(_aTit , {"E2_LOJA"		,cLoja													,Nil})
				AADD(_aTit , {"E2_EMISSAO"	,Ddatabase												,Nil})
				AADD(_aTit , {"E2_VENCTO"	,dDtVenc												,Nil})
				AADD(_aTit , {"E2_VENCREA"	,DataValida(dDtVenc,.T.)								,Nil})
				AADD(_aTit , {"E2_EMIS1"	,Ddatabase												,Nil})
				AADD(_aTit , {"E2_MOEDA"	,Val(cMoedaTit)											,Nil})
				AADD(_aTit , {"E2_VALOR"	,FLD->FLD_VALAPR										,Nil})
				AADD(_aTit , {"E2_ORIGEM"	,"FINA667"												,Nil})
				AADD(_aTit , {"E2_HIST"		,STR0115 + FLD->FLD_VIAGEM + STR0116 + FLD->FLD_PARTIC	,Nil})
				
				If FLD->FLD_TAXA > 0
					AADD(_aTit , {"E2_TXMOEDA"	,FLD->FLD_TAXA										,Nil})
				Endif
				
				aCC := F677CalcCC(FLD->FLD_VIAGEM,FLD->FLD_VALAPR)
				
				If !Empty(aCC)
					
					If Len(aCC) == 1
						AADD(_aTit , {"E2_CCUSTO"  , aCC[1][1]										,Nil})
						AADD(_aTit , {"E2_ITEMCTA" , aCC[1][4]										,Nil})
						AADD(_aTit , {"E2_CLVL"    , aCC[1][5]										,Nil})
						
					Else
						aAdd( aAuxSEV ,{"EV_NATUREZ" , PadR(cNaturez,nTamNat)						,Nil})
						aAdd( aAuxSEV ,{"EV_VALOR"   , FLD->FLD_VALAPR								,Nil})//valor do rateio na natureza
						aAdd( aAuxSEV ,{"EV_PERC"    , "100"										,Nil})//percentual do rateio na natureza
						aAdd( aAuxSEV ,{"EV_RATEICC" , "1"											,Nil})//indicando que há rateio por centro de custo
						
						For nX := 1 To Len(aCC)
							
							aAdd( aAuxSEZ ,{"EZ_CCUSTO" ,aCC[nX][1]									,Nil})//centro de custo da natureza
							aAdd( aAuxSEZ ,{"EZ_VALOR"  ,aCC[nX][2]									,Nil})//valor do rateio neste centro de custo
							aAdd( aAuxSEZ ,{"EZ_PERC"	,aCC[nX][3]									,Nil})
							aAdd( aAuxSEZ ,{"EZ_ITEMCTA",aCC[nX][4]									,Nil})
							aAdd( aAuxSEZ ,{"EZ_CLVL"	,aCC[nX][5]									,Nil})						
							aAdd( aRatSEZ	,aClone(aAuxSEZ))
							aSize(aAuxSEZ	,0)
							aAuxSEZ := {}
							
						Next nX
						
						aAdd(aAuxSEV,{"AUTRATEICC" , aRatSEZ										,Nil})//recebendo dentro do array da natureza os multiplos centros de custo
						aAdd(aRatSEVEZ,aAuxSEV)//adicionando a natureza ao rateio de multiplas naturezas
						//
						AADD(_aTit ,{"E2_MULTNAT","1"												,Nil})
						AADD(_aTit ,{"AUTRATEEV" ,aRatSEVEZ											,Nil})//adicionando ao vetor aCab o vetor do rateio
					EndIf
				EndIf
				//Chamada da rotina automatica
				//3 = inclusao
				
				MSExecAuto({|x, y| FINA050(x, y)}, _aTit, 3)
				
				If lMsErroAuto
					If !IsBlind()
						MOSTRAERRO()
					Else
						ConOut(STR0130)//"Erro na geração do titulo!! Verificar."
						aErroAuto := GetAutoGRLog()
						cLogErro := ""
						For nX := 1 To Len(aErroAuto)
							cLogErro += aErroAuto[nX]
						Next nX
						ConOut(cLogErro)
					EndIf
					lMsErroAuto := .F.
					DisarmTransaction()
					lRet := .F.
				Else
					lRet := .T.
					If lGravaFLD
						//Atualizo o status do adiantamento
						FLD->(dbGoTo(nRecno))
						RecLock("FLD")
						FLD->FLD_PREFIX	:= cPrefixo
						FLD->FLD_TIPO	:= cTipo
						FLD->FLD_TITULO	:= cNumTit
						FLD->FLD_PARCEL	:= Space(nTamParc)
						FLD->FLD_FORNEC	:= cFornece
						FLD->FLD_LOJA	:= cLoja
						FLD->FLD_STATUS	:= "3"	//Liberado Pagamento
						MsUnLock()
					EndIf
					
					//Manda Email para o participante
					F667MsgMail(4,FLD->FLD_MOEDA,FLD->FLD_VALAPR,FLD->FLD_APROV,FLD->FLD_VIAGEM,FLD->FLD_ITEM,FLD->FLD_PARTIC)
				Endif
			Else 
				SE2->(DbSetOrder(1))
				If SE2->(DbSeek(xFilial('SE2') + FLD->(FLD_PREFIX + FLD_TITULO + FLD_PARCEL + FLD_TIPO + FLD_FORNEC + FLD_LOJA)))

					_aTit := {}
					
					AADD(_aTit , {"E2_NUM"		,FLD->FLD_TITULO,NIL})
					AADD(_aTit , {"E2_PREFIXO"	,FLD->FLD_PREFIX,NIL})
					AADD(_aTit , {"E2_PARCELA"	,FLD->FLD_PARCEL,NIL})
					AADD(_aTit , {"E2_TIPO"		,FLD->FLD_TIPO	,NIL})
					AADD(_aTit , {"E2_FORNECE"	,FLD->FLD_FORNEC,NIL})
					AADD(_aTit , {"E2_LOJA"		,FLD->FLD_LOJA	,NIL})
					
					//Chamada da rotina automatica
					//5 = Exclusao
					MSExecAuto({|x, y, z| FINA050(x, y , z)}, _aTit, 5,5)
					
					If lMsErroAuto
						If !IsBlind()
							MOSTRAERRO()
						Else
							ConOut(STR0130) //"Erro na geração do titulo!! Verificar."
							aErroAuto := GetAutoGRLog()
							cLogErro := ""
							For nX := 1 To Len(aErroAuto)
								cLogErro += aErroAuto[nX]
							Next nX
							ConOut(cLogErro)
						Endif
						lMsErroAuto := .F.
						DisarmTransaction()
						lRet := .F.
					Else

						If FLD->FLD_MOEDA == '2'
							cMoedaTit := cMoedD
						ElseIf FLD->FLD_MOEDA == '3'
							cMoedaTit := cMoedE
						Else
							cMoedaTit := FLD->FLD_MOEDA
						EndIf

						_aTit := {}
						AADD(_aTit , {"E2_NUM"		,PadR(cNumTit,nTamNum)									,Nil})
						AADD(_aTit , {"E2_PREFIXO"	,PadR(cPrefixo,nTamPrf)									,Nil})
						AADD(_aTit , {"E2_PARCELA"	,Space(nTamParc)										,Nil})
						AADD(_aTit , {"E2_TIPO"		,PadR(cTipo,nTamTipo)									,Nil})
						AADD(_aTit , {"E2_NATUREZ"	,PadR(cNaturez,nTamNat)									,Nil})
						AADD(_aTit , {"E2_FORNECE"	,cFornece												,Nil})
						AADD(_aTit , {"E2_LOJA"		,cLoja													,Nil})
						AADD(_aTit , {"E2_EMISSAO"	,Ddatabase												,Nil})
						AADD(_aTit , {"E2_VENCTO"	,dDtVenc												,Nil})
						AADD(_aTit , {"E2_VENCREA"	,DataValida(dDtVenc,.T.)								,Nil})
						AADD(_aTit , {"E2_EMIS1"	,Ddatabase												,Nil})
						AADD(_aTit , {"E2_MOEDA"	,Val(cMoedaTit)											,Nil})
						AADD(_aTit , {"E2_VALOR"	,FLD->FLD_VALAPR										,Nil})
						AADD(_aTit , {"E2_ORIGEM"	,"FINA667"												,Nil})
						AADD(_aTit , {"E2_HIST"		,STR0115 + FLD->FLD_VIAGEM + STR0116 + FLD->FLD_PARTIC	,Nil})
						
						If FLD->FLD_TAXA > 0
							AADD(_aTit , {"E2_TXMOEDA"	,FLD->FLD_TAXA										,Nil})
						Endif
						
						aCC := F677CalcCC(FLD->FLD_VIAGEM,FLD->FLD_VALAPR)
						
						If !Empty(aCC)
							
							If Len(aCC) == 1
								AADD(_aTit , {"E2_CCUSTO"  , aCC[1][1]										,Nil})
								AADD(_aTit , {"E2_ITEMCTA" , aCC[1][4]										,Nil})
								AADD(_aTit , {"E2_CLVL"    , aCC[1][5]										,Nil})
								
							Else
								aAdd( aAuxSEV ,{"EV_NATUREZ" , PadR(cNaturez,nTamNat)						,Nil})
								aAdd( aAuxSEV ,{"EV_VALOR"   , FLD->FLD_VALAPR								,Nil})//valor do rateio na natureza
								aAdd( aAuxSEV ,{"EV_PERC"    , "100"										,Nil})//percentual do rateio na natureza
								aAdd( aAuxSEV ,{"EV_RATEICC" , "1"											,Nil})//indicando que há rateio por centro de custo
								
								For nX := 1 To Len(aCC)
									
									aAdd( aAuxSEZ ,{"EZ_CCUSTO" ,aCC[nX][1]									,Nil})//centro de custo da natureza
									aAdd( aAuxSEZ ,{"EZ_VALOR"  ,aCC[nX][2]									,Nil})//valor do rateio neste centro de custo
									aAdd( aAuxSEZ ,{"EZ_PERC"	,aCC[nX][3]									,Nil})
									aAdd( aAuxSEZ ,{"EZ_ITEMCTA",aCC[nX][4]									,Nil})
									aAdd( aAuxSEZ ,{"EZ_CLVL"	,aCC[nX][5]									,Nil})						
									aAdd( aRatSEZ	,aClone(aAuxSEZ))
									aSize(aAuxSEZ	,0)
									aAuxSEZ := {}
									
								Next nX
								
								aAdd(aAuxSEV,{"AUTRATEICC" , aRatSEZ										,Nil})//recebendo dentro do array da natureza os multiplos centros de custo
								aAdd(aRatSEVEZ,aAuxSEV)//adicionando a natureza ao rateio de multiplas naturezas
								//
								AADD(_aTit ,{"E2_MULTNAT","1"												,Nil})
								AADD(_aTit ,{"AUTRATEEV" ,aRatSEVEZ											,Nil})//adicionando ao vetor aCab o vetor do rateio
							EndIf
						EndIf
						
						//Chamada da rotina automatica
						//3 = inclusao
						
						MSExecAuto({|x, y| FINA050(x, y)}, _aTit, 3)
						
						If lMsErroAuto
							If !IsBlind()
								MOSTRAERRO()
							Else
								ConOut(STR0130)//"Erro na geração do titulo!! Verificar."
								aErroAuto := GetAutoGRLog()
								cLogErro := ""
								For nX := 1 To Len(aErroAuto)
									cLogErro += aErroAuto[nX]
								Next nX
								ConOut(cLogErro)
							EndIf
							lMsErroAuto := .F.
							DisarmTransaction()
							lRet := .F.
						Else
							lRet := .T.
							If lGravaFLD
								//Atualizo o status do adiantamento
								FLD->(dbGoTo(nRecno))
								RecLock("FLD")
								FLD->FLD_PREFIX	:= cPrefixo
								FLD->FLD_TIPO	:= cTipo
								FLD->FLD_TITULO	:= cNumTit
								FLD->FLD_PARCEL	:= Space(nTamParc)
								FLD->FLD_FORNEC	:= cFornece
								FLD->FLD_LOJA	:= cLoja
								FLD->FLD_STATUS	:= "3"	//Liberado Pagamento
								MsUnLock()
							EndIf
							
							//Manda Email para o participante
							F667MsgMail(4,FLD->FLD_MOEDA,FLD->FLD_VALAPR,FLD->FLD_APROV,FLD->FLD_VIAGEM,FLD->FLD_ITEM,FLD->FLD_PARTIC)
						Endif
					Endif
				EndIf
			EndIf
		Else	//Cancelamento da liberação de pagamento
			
			lRet := .T.
			//Posiciono no titulo no Financeiro
			SE2->(dbSetOrder(1))
			If !Empty(FLD->FLD_TITULO) .and. SE2->(MsSeek(xFilial("SE2")+FLD->(FLD_PREFIX+FLD_TITULO+FLD_PARCEL+FLD_TIPO+FLD_FORNEC+FLD_LOJA)))
				
				_aTit := {}
				
				AADD(_aTit , {"E2_NUM"		,FLD->FLD_TITULO,NIL})
				AADD(_aTit , {"E2_PREFIXO"	,FLD->FLD_PREFIX,NIL})
				AADD(_aTit , {"E2_PARCELA"	,FLD->FLD_PARCEL,NIL})
				AADD(_aTit , {"E2_TIPO"		,FLD->FLD_TIPO	,NIL})
				AADD(_aTit , {"E2_FORNECE"	,FLD->FLD_FORNEC,NIL})
				AADD(_aTit , {"E2_LOJA"		,FLD->FLD_LOJA	,NIL})
				
				//Chamada da rotina automatica
				//5 = Exclusao
				MSExecAuto({|x, y, z| FINA050(x, y , z)}, _aTit, 5,5)
				
				If lMsErroAuto
					If !IsBlind()
						MOSTRAERRO()
					Else
						ConOut(STR0130)//"Erro na geração do titulo!! Verificar."
						aErroAuto := GetAutoGRLog()
						cLogErro := ""
						For nX := 1 To Len(aErroAuto)
							cLogErro += aErroAuto[nX]
						Next nX
						ConOut(cLogErro)
					Endif
					lMsErroAuto := .F.
					DisarmTransaction()
					lRet := .F.
				Endif
			Endif
			
			If lRet
				//Atualizo o status do adiantamento
				FLD->(dbGoTo(nRecno))
				RecLock("FLD")
				FLD->FLD_STATUS := "2"	//APROVADO
				FLD->FLD_PREFIX	:= ""
				FLD->FLD_TIPO	:= ""
				FLD->FLD_TITULO	:= ""
				FLD->FLD_PARCEL	:= ""
				FLD->FLD_FORNEC := ""
				FLD->FLD_LOJA	:= ""
				MsUnLock()
			Endif
		Endif
		
	END TRANSACTION
	
Endif



RestArea(aArea)
aSize(aCC,0)
aSize(aAuxSEV,0)
aSize(aAuxSEZ,0)
aSize(aRatSEZ,0)
aSize(aRatSEVEZ,0)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F667CFPGEST
Confirma pagamento ou estorno para adiantamentos em moeda estrangeira

@author Mauricio Pequim Jr
@since 29/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Function F667CFPGEST(cAlias,nReg,nOpc)

Local aArea			:= GetArea()
Local cTitulo 		:= ""
Local cPrograma 	:= ""
Local nOperation 	:= MODEL_OPERATION_UPDATE
Local lRet			:= .T.
Local cStatus 		:= ""
Local nRecno		:= FLD->(RECNO())
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,NIL},{.T.,STR0044},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Fechar"

//Verifica Status
If lRet .and. !(FLD->FLD_STATUS $ "3|4")	//Status = Aprovado
	cStatus := F667Status(FLD->FLD_STATUS)
	Help(" ",1,"F667ESLIPG",,STR0058+CRLF+STR0032+" ==> "+cStatus ,1,0)		//"O status dste adiantamento de viagem não permite confirmação ou estorno de pagamento."
	lRet := .F.
Endif

//Verifica titulo gerado
If lRet .and. !Empty(FLD->FLD_TITULO)	//Possui titulo gerado
	Help(" ",1,"F667TEMTIT",,STR0059,1,0)	//"Este adiantamento possui titulo gerado. A confirmação de pagamento será realizada através do Financeiro"
	lRet := .F.
Endif

//Verifica moeda do titulo
If lRet .and. FLD->FLD_MOEDA == '1'	//Possui titulo gerado
	Help(" ",1,"F667MOEDA",,STR0060,1,0)		//"Este adiantamento foi realizado em moeda corrente do país. A confirmação de pagamento será realizada através do Financeiro"
	lRet := .F.
Endif

If lRet
	cTitulo 		:= STR0061		//"Confirmar Pagto. / Estorno Pagto."
	cPrograma 		:= 'FINA667'
	nOperation 		:= MODEL_OPERATION_VIEW //Visualizar
	__lConfirmar	:= .F.
	__nOper     	:= OPER_CONFPG_EST
	__lBTNConfirma  := .T.
	__lBTNReprova	:= .F.

	FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/, /*bOk*/ , /*nPercReducao*/, aEnableButtons, /*bCancel*/ )

	If __lConfirmar
		//Atualizo o status
		FLD->(dbGoTo(nRecno))
		RecLock("FLD")
		FLD->FLD_STATUS := If(FLD->FLD_STATUS == "3", "4","3")	//Liberado Pagamento
		MsUnLock()
	EndIf

EndIf

__lConfirmar:= .F.
__lReprovou := .F.
__lBTNConfirma  := .F.
__lBTNReprova	:= .F.
__nOper     := 0

RestArea(aArea)

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} F667ESLIBPG
Estorno de liberação (Gestor) de adiantamento

@author Mauricio Pequim Jr
@since 29/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Function F667ESLIBPG(cAlias,nReg,nOpc,lAutomato)

Local aArea			:= GetArea()
Local cTitulo 		:= ""
Local cPrograma 	:= ""
Local nOperation 	:= MODEL_OPERATION_UPDATE
Local lRet			:= .T.
Local cStatus 		:= ""
Local nRecno		:= FLD->(RECNO())
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,NIL},{.T.,STR0044},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Fechar"

Default	lAutomato := .F.

//Verifica Status
If lRet .and. !(FLD->FLD_STATUS == "3")	//Status = Aprovado
	cStatus := F667Status(FLD->FLD_STATUS)
	Help(" ",1,"F667ESTLIBPG",,STR0062+CRLF+STR0032+" ==> "+cStatus ,1,0)   //"O status dste adiantamento de viagem não permite estorno de liberação de pagamento."
	lRet := .F.
Endif

If lRet
	cTitulo 		:= STR0063		//"Estornar Liberação Pagto."
	cPrograma 		:= 'FINA667'
	nOperation 		:= MODEL_OPERATION_VIEW //Visualizar
	__lConfirmar	:= .F.
	__nOper     	:= OPER_ESTLIBPGTO
	__lBTNConfirma  := .T.
	__lBTNReprova	:= .F.

	If !lAutomato
		FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/, /*bOk*/ , /*nPercReducao*/, aEnableButtons, /*bCancel*/ )
		If __lConfirmar
			MsgRun( STR0064,, {||	lRet := F667GeraLib(2,nRecno) } ) //"Cancelando liberação de pagamento..."
		EndIf
	Else
		F667GeraLib(2,nRecno)
	EndIf

EndIf

__lConfirmar:= .F.
__lReprovou := .F.
__lBTNConfirma  := .F.
__lBTNReprova	:= .F.
__nOper     := 0

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F667MsgMail
Estorno de liberação (Gestor) de adiantamento

@param nOpcao 	1= Gestor (Liberar solicitacao de adiantamento
				2= Paricipante (solicitacao de adiantamento negado - Gestor )
				3= Paricipante (adiantamento negado - Depto Viagens)
				4= Paricipante (pagamento de adiantamento aprovado)


@author Mauricio Pequim Jr
@since 29/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------

Function F667MsgMail(nOpcao,cMoeda,nValor,cCodAprv,cViagem,cItViagem,cPartic)

Local nLayout		:= 1		//1=Adiantamento,2=Prestação de Contas
Local nInteressado	:= 1		//1=Participante, 2=Departamento de Viagem,  3=Aprovador
Local cMensagem		:= ""  		//Mensagem a ser enviada
Local cAssunto		:= ""		//Assunto do e-mail
Local cNomeGestor	:= ""
Local lEnviaEmail	:= (SuperGetMV("MV_RESAVIS",,"") == "1")	//Para enviar email, parâmetro MV_RESAVIS == "1"
Local cLicenc		:= ""
Local cPedido		:= ""
Local cMensRESE		:= ""
local cNomePart		:= ""

DEFAULT nOpcao	  	:= 0
DEFAULT cMoeda	  	:= "1"
DEFAULT nValor	  	:= 0
DEFAULT cCodAprv  	:= ""
DEFAULT cPedido	  	:= ""
DEFAULT cItViagem 	:= "01"
DEFAULT cPartic		:= ""

//Obtenho o codigo RESERVE
FL6->(dbSetOrder(1))
If (FL6->(MsSeek(xFilial("FL6")+cViagem+cItViagem)))
	cPedido := FL6->FL6_IDRESE
	cLicenc := FL6->FL6_LICENC
Endif

If nOpcao == 1	//Aviso ao Gestor sobre solicitacao de adiantamento

	nLayOut		:= 3		//1=Participante, 2=Departamento de Viagem,  3=Aprovador

	cAssunto	:= STR0088		//"Liberação de solicitação de adiantamento de viagem"
	cMensagem	:= STR0089 		//"Existe uma aprovação pendente referente a solicitação de adiantamento de viagem."
	cMensRESE	:= STR0107		//"Adiantamento #1[Codigo]# gerado para o passageiro #2[Participante]# em #3[Data] as #4[Hora]"

ElseIf nOpcao == 2	//Aviso ao participante sobre pagamento negado (Gestor)

	cNomeGestor := GETADVFVAL("RD0","RD0_NOME",xFilial("RD0")+ cCodAprv ,1,"")+". "

	cAssunto	:= STR0090		//"Solicitação de adiantamento de viagem"
	cMensagem	:= STR0091 		//"Foi rejeitada a solicitação de adiantamento referente a viagem "
	cMensagem 	+= STR0092 + cNomeGestor  + STR0093	//"pelo Sr./Sra. "###"Por favor, entre em contato com o mesmo/mesma para maiores esclarecimentos."
	cMensRESE	:= STR0108		//"Adiantamento #1[Codigo]# negado para o passageiro #2[Participante]# em #3[Data] as #4[Hora]"

ElseIf nOpcao == 3	//Aviso ao participante sobre pagamento negado (Depto Viagens)

	cAssunto	:= STR0094 		//"Adiantamento de viagem - Pagamento"
	cMensagem	:= STR0095 		//"O pagamento de adiantamento referente a viagem foi rejeitado "
	cMensagem 	+= STR0096		//"pelo Departamento de Viagens. Por favor, entre em contato com o mesmo para maiores esclarecimentos."
	cMensRESE	:= STR0108		//"Adiantamento #1[Codigo]# negado para o passageiro #2[Participante]# em #3[Data] as #4[Hora]"

ElseIf nOpcao == 4	//Aviso ao participante sobre pagamento liberado

	cAssunto	:= STR0097	//"Liberação para pagamento - Adiantamento de viagem"
	cMensagem	:= STR0098 	//"Foi aprovado o pagamento de adiantamento referente a viagem. "
	cMensRESE	:= STR0109	//"Adiantamento #1[Codigo]# liberado para pagamento para o passageiro #2[Participante]# em #3[Data]# as #4[Hora]#"
Endif

If lEnviaEmail
	//Manda o email
	FNXRESMONTAEMAIL(nLayOut , nInteressado, cMensagem, cAssunto)
Endif

//Manda mensagem para Reserve
If !Empty(cPedido)

	//-------------------------------------------
	// Atualiza o historico do pedido no Reserve
	//-------------------------------------------
	cNomePart	:= Alltrim(GETADVFVAL("RD0","RD0_NOME",XFILIAL("RD0")+cPartic,1,""))
	cHistorico	:= I18N(cMensRESE,{cViagem,cPartic+" - "+cNomePart,DToC(dDataBase),Time()})
	FN661Hist(cLicenc,cPedido,cHistorico)

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F667GeraAdian
Gera adiantamento para os pedidos.

@param oModel Objeto com os dados necessarios.

@author William Matos Gundim Junior
@since  24/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Function F667GeraAdian(oPedidos)

Local oModel		:= Nil
Local nValorFixo	:= SuperGetMV('MV_RESADFX',.F.,0)
Local nValAdian		:= SuperGetMV('MV_RESADSP',.F.,0)
Local nValDia		:= SuperGetMV('MV_RESADDI',.F.,0)
Local nDiasPrev		:= SuperGetMV('MV_RESADDU',.F.,0)
local nUtiOco		:= SuperGetMV('MV_RESUTCO',.F.,1)//"1" = útil
local nAdUrg		:= SuperGetMV('MV_RESPURG',.F.,3)
local nBaCalc		:= SuperGetMV('MV_RESCALC',.F.,1)//"1" = pedido
Local nX			:= 0

Local cViagem		:= oPedidos:GetValue('FL5MASTER','FL5_VIAGEM')
Local cItem			:= oPedidos:GetValue('FL6DETAIL','FL6_ITEM')
Local dDataIni		:= If( nBaCalc == 2 , oPedidos:GetValue('FL5MASTER','FL5_DTINI') , oPedidos:GetValue('FL6DETAIL','FL6_DTCRIA') )
Local dDataFim		:= oPedidos:GetValue('FL5MASTER','FL5_DTFIM')
Local cNacion		:= oPedidos:GetValue('FL5MASTER','FL5_NACION')
Local cAdian		:= ''
Local cPartic		:= ''
Local cNome			:= ''
Local cMoeda		:= '1'
Local nCount		:= 0
Local cLog			:= ''
Local lBloqAdia		:= .F.
Local aAprv			:= FResAprov("1")//"1" = Adiantamentos
Local dDataPrev		:= dDataBase
Local dDataAux		:= Date()

/*
	PCREQ-3829 Aprovação Automática
	
	aAprv[1] - Aprovação de Solicitação (.T. or .F.)
	aAprv[2] - Avaliação do Gestor (.T. or .F.)
	aAprv[3] - Lib. do Pagamento (.T. or .F.)
*/
//Processo para permitir informar a quantidade mínima de dias para o vencimento dos adiantamentos de viagens
dDataPrev := dDataAux := dDataIni

//Cálculo
If nUtiOco == 1 //Util
	For nX = 1 to nDiasPrev
		If nBaCalc == 1  //Pedido
			dDataAux := (dDataPrev + 1)
			dDataPrev	:= DataValida(dDataAux)
		Else //Inicio da Viagem
			dDataAux := (dDataPrev - 1) 
			dDataPrev	:= DataValida(dDataAux,.F.)
		EndIf	
	Next nX
Else //Corrido
	If nBaCalc == 1  //Pedido
		dDataPrev := DataValida(dDataIni + nDiasPrev)
	Else //Inicio da Viagem
		dDataPrev := DataValida(dDataIni - nDiasPrev,.F.)
	EndIf
EndIf


//Verificar se o add é maior que a data base - add urgente
If dDataPrev <= dDatabase
	If nUtiOco == 1 //Util
		dDataPrev := dDatabase
		For nX = 1 to nAdUrg
			dDataAux := (dDataPrev + 1)
			dDataPrev	:= DataValida(dDataAux)	
		Next nX
	Else //Corrido
		dDataPrev := DataValida(dDataBase + nAdUrg)
	EndIf	
EndIf

	dDataIni	:= If( nBaCalc == 2 , oPedidos:GetValue('FL5MASTER','FL5_DTINI') , oPedidos:GetValue('FL6DETAIL','FL6_DTCRIA') )
	lAuto := .T.
	DbSelectArea('FLD') //Adiantamento. 
	DbSelectArea('RD0') //Participantes.
	oModel := FWLoadModel('FINA667')
	oModel:SetOperation(3)  // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
	oModel:Activate()
	oModel:GetModel('FLDMASTER')	
	oPedidos := oPedidos:GetModel('FLUDETAIL')

	For nCount := 1 To oPedidos:Length()
		
		oPedidos:GoLine(nCount)
		cPartic := oPedidos:GetValue('FLU_PARTIC')
		cNome   := oPedidos:GetValue('FLU_NOME')
		
		//Verifica se o participante pode receber adiantamento.
		RD0->(dbSeek(xFilial('RD0') + cPartic))
		lBloqAdia 	:= RD0->RD0_PERMAD == '2'  	
		cAdian  	:= FINA667NEW(cViagem, cPartic)
		
		//Verifico se as datas da prestação (caso exista) estão de acordo com as datas que serão gravadas na FLD
		//Caso as datas sejam divergentes, recalculo o número de dias da viagem para o adiantamento
		FLF->(DbSetOrder(2))
		If FLF->(DbSeek(xFilial('FLF') + cViagem + cPartic))
			If FLF->FLF_DTFIM != dDataFim
				dDataFim := FLF->FLF_DTFIM
			EndIf
		EndIf
		
		FLD->(dbSetOrder(1)) // FLD_FILIAL + FLD_VIAGEM + FLD_PARTIC
		If FLD->(!dbSeek(xFilial('FLD') + cViagem + cPartic)) .AND. !lBloqAdia .AND. F667AutAdt(oPedidos, cPartic) 
		
			//Grava os valores.
			oModel := oModel:GetModel('FLDMASTER')
			oModel:SetValue('FLD_FILIAL',xFilial('FLD'))
			oModel:SetValue('FLD_VIAGEM',cViagem)
			oModel:SetValue('FLD_PARTIC',cPartic)
			oModel:SetValue('FLD_NOMEPA',cNome)
			oModel:SetValue('FLD_ITEM'  ,cItem)
			oModel:SetValue('FLD_DTPREV',dDataPrev)
			oModel:SetValue('FLD_ADIANT',cAdian)
			oModel:SetValue('FLD_MOEDA' ,cMoeda)
			oModel:SetValue('FLD_JUSTIF',STR0017)    
			oModel:SetValue('FLD_SOLIC',cPartic)
	
			//Viagem nacional.
			If cNacion == "1"
				//Sem pernoite
				If (dDataFim - dDataIni) == 0
					oModel:SetValue('FLD_VALOR',nValAdian)
				Else
					oModel:SetValue('FLD_VALOR', nValorFixo + (nValDia *(dDataFim - dDataIni) ) )
				EndIf
			Else
				oModel:SetValue('FLD_VALOR', nValorFixo)
			EndIf

			//PCREQ-3829 Aprovação Automática
			// Se aAprv[2] == .T., Aprovação Manual do Gestor é necessaria. 
			If aAprv[2]
				oModel:SetValue('FLD_STATUS','1')//SOLICITADO
				
			//	aAprv[2]=Avaliação do Gestor, Se aAprv[2] == .F., Aprovação Automatica da Avaliação do Gestor esta Ativada
			//	aAprv[3]=Liberação do Pagamento, Se aAprv[3] == .T., Aprovação Manual da Liberação do Pagamento é necessaria
			ElseIf !aAprv[2] .AND. aAprv[3]
				oModel:SetValue('FLD_STATUS','2')//APROVADO
				
			//	aAprv[2]=Avaliação do Gestor, Se aAprv[2] == .F., Aprovação Automatica da Avaliação do Gestor esta configurada
			//	aAprv[3]=Liberação do Pagamento, Se aAprv[3] == .F., Aprovação Automatica da Liberação do Pagamento esta configurada
			ElseIf !aAprv[2] .AND. !aAprv[3]
				If FResAprov("4")[1]
	 				oModel:LoadValue('FLD_STATUS','3')//Liberado Pagamento.
	 				oModel:LoadValue('FLD_VALAPR', oModel:GetValue("FLD_VALOR") ) 				
				EndIf
 			Endif  
			
			oModel := oModel:GetModel('FINA667')
			If oModel:VldData()
				oModel:CommitData()
				oModel:DeActivate()
				oModel:= Nil
				//PCREQ-3829 Aprovação Automática
				If !aAprv[2] .AND. !aAprv[3]
					If FResAprov("4")[1]
						FwMsgRun(,{||F667GeraLib(1,FLD->(RECNO()),.T.)}," ",STR0051)//"Processando liberação de pagamento..."
					Else
						RecLock("FLD",.F.)
							FLD->FLD_STATUS	:= "1" 	//Solicitado
						FLD->(MsUnlock())	
					EndIf
				EndIf
				oModel := FWLoadModel('FINA667')
				oModel:SetOperation(3)  // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
				oModel:Activate()
				oModel:GetModel('FLDMASTER')
				//Grava hierarquia de aprovadores
				//	cViagem = Codigo da viagem
				//	cPartic = Codigo do participante
				//	cAdiant = Codigo do Adiantamento
				//	cItem	= Item do adiantamento
				FINA667LIB(cViagem, cPartic, cAdian, cItem)

			Else
				cLog := 'F665GeraAdian' + cValToChar(oModel:GetErrorMessage()[4]) + ' - ' + cValToChar(oModel:GetErrorMessage()[6]);
				 + ' - ' + cValToChar(oModel:GetErrorMessage()[8])
			EndIf

			If cNacion == "2" .AND. cLog == ''
				//Grava os valores internacional em um novo registro
				cAdian  := FINA667NEW(cViagem, cPartic)
				//
				oModel:SetValue('FLDMASTER','FLD_FILIAL',xFilial('FLD'))
				oModel:SetValue('FLDMASTER','FLD_VIAGEM',cViagem)
				oModel:SetValue('FLDMASTER','FLD_PARTIC',cPartic)
				oModel:SetValue('FLDMASTER','FLD_NOMEPA',cNome)
				oModel:SetValue('FLDMASTER','FLD_ITEM'  ,cItem)
				oModel:SetValue('FLDMASTER','FLD_DTPREV',dDataPrev)
				oModel:SetValue('FLDMASTER','FLD_ADIANT',cAdian)
				oModel:SetValue('FLDMASTER','FLD_JUSTIF',STR0017)
				oModel:SetValue('FLDMASTER','FLD_STATUS','7')
				oModel:SetValue('FLDMASTER','FLD_SOLIC',cPartic)
				oModel:SetValue('FLDMASTER','FLD_VALOR',0)
				oModel:SetValue('FLDMASTER','FLD_MOEDA','')
				If oModel:VldData()
					oModel:CommitData()
					oModel:DeActivate()
					oModel:= Nil
					oModel := FWLoadModel('FINA667')
					oModel:SetOperation(3)  // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
					oModel:Activate()
					oModel:GetModel('FLDMASTER')

					//Grava hierarquia de aprovadores
					//	cViagem = Codigo da viagem
					//	cPartic = Codigo do participante
					//	cAdiant = Codigo do Adiantamento
					//	cItem	= Item do adiantamento
					FINA667LIB(cViagem, cPartic, cAdian, cItem)
			 	Else
					cLog := 'F665GeraAdian' + cValToChar(oModel:GetErrorMessage()[4]) + ' - ' + cValToChar(oModel:GetErrorMessage()[6]);
				 	+' - ' + cValToChar(oModel:GetErrorMessage()[8])
				EndIf 			
			EndIf
		ElseIf !lBloqAdia .And. F667AutAdt(oPedidos, cPartic) 
			If oModel != Nil
				oModel:Deactivate()
				oModel:Destroy()
				oModel := Nil
			EndIf

			RecLock("FLD",.F.)

			//Viagem nacional.
			If cNacion == "1"
				//Sem pernoite
				If (dDataFim - dDataIni) == 0
					FLD->FLD_VALOR := nValAdian
				Else
					FLD->FLD_VALOR := nValorFixo + (nValDia * (dDataFim - dDataIni))
				EndIf
			Else
				FLD->FLD_VALOR := nValorFixo
			EndIf

			//PCREQ-3829 Aprovação Automática
			If aAprv[2]
				FLD->FLD_STATUS := '1' //SOLICITADO
			Elseif !(aAprv[2]) .AND. aAprv[3]//"2"=Avaliação do Gestor/"3"=Liberação do Pagamento
				FLD->FLD_STATUS := '2' //APROVADO
			ElseIf !(aAprv[2]) .AND. !(aAprv[3])
				If FResAprov("4")[1]
	 				FLD->FLD_STATUS := '3' //Liberado Pagamento.
	 				FLD->FLD_VALAPR := FLD->FLD_VALOR 				
				EndIf
 			Endif  

 			MsUnlock()

			//PCREQ-3829 Aprovação Automática
			If !(aAprv[2]) .AND. !(aAprv[3])
				If FResAprov("4")[1]
					FwMsgRun(,{||F667GeraLib(1,FLD->(RECNO()),.T.)}," ",STR0051)//"Processando liberação de pagamento..."
				Else
					RecLock("FLD",.F.)
						FLD->FLD_STATUS	:= "1" 	//Solicitado
					FLD->(MsUnlock())	
				Endif
			Endif

			//Grava hierarquia de aprovadores
			//	cViagem = Codigo da viagem
			//	cPartic = Codigo do participante
			//	cAdiant = Codigo do Adiantamento
			//	cItem	= Item do adiantamento
			FINA667LIB(cViagem, cPartic, cAdian, cItem)

		EndIf	
	Next	
	
	oPedidos := Nil
	If ValType(oModel) == 'O'
		oModel:DeActivate()
		oModel:Destroy()
		oModel:= Nil
	EndIf
		
Return cLog

//-------------------------------------------------------------------
/*/{Protheus.doc} F667Aprov
Validação dos aprovadores.

@author William Matos
@since 28/08/2014
@version 12
/*/
//-------------------------------------------------------------------
Function F667AdiAprov( oModel , aUsuario )
Local aArea := GetArea()
Local lRet  := .F.

If Empty(aUser)
	lRet := FINXUser(__cUserId,aUser,.T.)
Endif

dbSelectArea('FLJ')
dbSelectArea('RD0')
//
If FLJ->(dbSeek( xFilial('FLJ') + oModel:GetValue('FLDMASTER','FLD_VIAGEM'))) 
	While FLJ->FLJ_FILIAL + FLJ->FLJ_VIAGEM == xFilial('FLJ') + oModel:GetValue('FLDMASTER','FLD_VIAGEM') .AND. !lRet
		lRet := aUser[1] == FLJ->FLJ_PARTIC
		FLJ->(dbSkip())
	EndDo
EndIf
If !lRet
	RD0->(dbSetOrder(1))
	If RD0->(dbSeek(xFilial('RD0') + oModel:GetValue('FLDMASTER','FLD_PARTIC')))
		lRet := RD0->RD0_APROPC == aUser[1] .OR. RD0->RD0_APSUBS == aUser[1]
	EndIf
EndIf
RestArea(aArea)
Return lRet

/*/
{Protheus.doc} F667BloqAdi
Verifica se o participante pode receber adiantamento.
@author William Matos
@since 28/08/2014
@version 12
/*/
Function F667BloqAdi(oModel)
Local aArea:= GetArea()
Local lRet := .T.

dbSelectArea('RD0')
RD0->(dbSetOrder(1))
RD0->(dbSeek( xFilial('RD0') + oModel:GetValue('FLDMASTER','FLD_PARTIC')))
If RD0->RD0_PERMAD == '2' //Não permite adiantamento. 
	If !MsgNoYes(STR0118) //Participante não pode receber adiantamento, confirma esta aprovação?
		__lReprovou := .T.
	EndIf	
EndIf

RestArea(aArea)
Return lRet

/*
{Protheus.doc} F667AutAdt
Verifica se o participante solicitou adiantamento na viagem.
@author William Matos
@since 13/10/2015
@version 12
*/
Function F667AutAdt(oPedidos, cPartic)
Local oAux		:= FWModelActive(oPedidos)
Local cSolic	:= oAux:GetValue('FL5MASTER','FL5_IDSOL')
Local lReturn	:= Empty(cSolic)
Local aArea		:= GetArea()

	dbSelectArea("FW5") //Participantes da solicitação.
	FW5->(dbSeek( xFilial("FW5") + cSolic))
	While FW5->(!Eof()) .AND. xFilial("FW5") + cSolic == FW5->FW5_FILIAL + FW5->FW5_SOLICI .AND. !lReturn
		lReturn := cPartic == FW5->FW5_PARTIC .AND. FW5->FW5_ADIANT		
		FW5->(dbSkip())
	EndDo	
	RestArea(aArea)
	
Return lReturn

/*/{Protheus.doc} F667ENVWF
Executa o modelo FINA667 como alteração para o reenvio do Workflow,
caso o serviço do Fluig esta fora do ar no fluxo padrão da prestação de conta
e não tenho conseguido subir Workflow para o Fluig.   
@author lucas.oliveira
@since 09/12/2015
/*/
Function F667ENVWF()
Local aArea			:= GetArea()
Local cTitulo			:= ""
Local cPrograma		:= ""
Local nOperation		:= 0
Local aEnableButtons	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Confirmar"},{.T.,"Fechar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
Local bOk				:= {||}
Local cProcWF			:= "SOLADIANTA"

If __lMTFLUIGATV
	If MTFluigAtv("WFFINA667", cProcWF, "WFFIN667" )
		FLF->(MsRLock())
		__nOper			:= OPER_ENVWF
		cTitulo			:= STR0001
		cPrograma			:= 'FINA667'
		nOperation			:= MODEL_OPERATION_UPDATE
		__lConfReprova	:= .F.
		bOk					:= {|| .T. } 
		nRet				:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,bOk , /*nPercReducao*/, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )
		__nOper			:= 0
		FLF->(MsRUnlock())
	EndIf
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FI667WF
Botão de cancelar para operações

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Function FI667WF(cViagem, cPartic,cAdiant, cUser, aUsers)
	Local lRet 	:= .T.
	Local aArea 	:= GetArea()
	Local aAreaRD0:= RD0->(GetArea())
	Local aAreaFLD:= FLD->(GetArea())

	FLD->(dbSetOrder(1))//FLD_FILIAL+FLD_VIAGEM+FLD_PARTIC+FLD_ADIANT
	If FLD->(dbSeek(xFilial("FLD") + cViagem + cPartic + cAdiant ))
		DbSelectArea("RD0")
		RD0->(DbSetOrder(1))
		If RD0->(DbSeek( xFilial("RD0") + cPartic ))
			Iif(!Empty(RD0->RD0_APSUBS), aAdd(aUsers,RD0->RD0_APSUBS),)
			cUser := RD0->RD0_USER
		EndIf
	EndIf

	
	//Carrega todos os aprovadores do participante.
	DbSelectArea("FLM")
	FLM->(DbSetOrder(1))
	FLM->(DbSeek(xFilial("FLM") + cViagem + cPartic + cAdiant ))
		
	While FLM->FLM_FILIAL == xFilial("FLM") .AND. FLM->FLM_VIAGEM == cViagem;
			.AND. FLM->FLM_PARTIC == cPartic .AND. FLM->FLM_ADIANT == cAdiant
			
		aAdd(aUsers, FLM->FLM_APROV)
															
		FLM->(DbSkip())
	EndDo
			
	If ExistBlock("WFFIN667",.F.,.F.)//Envia Solicitação de Aprovação para o Fluig.
		ExecBlock("WFFIN667",.F.,.F.,{cViagem, cPartic, cAdiant , cUser, aUsers})
	EndIf
		
	RestArea(aAreaRD0)
	RestArea(aAreaFLD)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FI667APGES
Ação de aprovação do gestor

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Function FI667APGES(cViagem,cPartic,cAdiant,lReprov)
Local aArea		:= GetArea()
Local aAreaFLD	:= FLD->(GetArea())
Local aAreaFL5	:= FL5->(GetArea())
Local aAprv		:= FResAprov("1") //"1" = Adiantamentos

FLD->(dbSetOrder(1))//FLD_FILIAL+FLD_VIAGEM+FLD_PARTIC+FLD_ADIANT
If FLD->(dbSeek(xFilial("FLD") + cViagem + cPartic + cAdiant ))
	If lReprov
		If FLD->FLD_STATUS  == '3'		
			If isBlind()
				F667GeraLib(2,FLD->(RECNO()))
			Else
				MsgRun( STR0140,, {|| F667GeraLib(2,FLD->(RECNO())) } ) //"Processando Estorno de liberação de pagamento..."
			EndIf
		EndIf
	Endif

	//Atualizo o status do adiantamento
	RecLock("FLD",.F.)
		If lReprov
			FLD->FLD_APROV := ""
			FLD->FLD_STATUS := "0" //0-Reprovado 
		Else 
			FLD->FLD_STATUS := "2" //2-Aprovado
		EndIf
	MsUnlock()
	
	//PCREQ-3829 Aprovação Automática
	If !(lReprov) .AND. !aAprv[3]//Libera Financeiro, se aAprv[3]== .F., Aprovação Automatica para Liberação de Pagamento esta acionada 
		If FResAprov("4")[1]
			If isBlind()
				F667GeraLib(1,FLD->(RECNO()),.T.)
			Else
				MsgRun( STR0051,, {|| F667GeraLib(1,FLD->(RECNO()),.T.) } ) //"Processando liberação de pagamento..."
			EndIf
		Else
			RecLock("FLD")
			FLD->FLD_STATUS := "1"	//Solicitado
			FLD->FLD_APROV	:= ""
			FLD->(MsUnlock())
		Endif
	Endif
EndIf

RestArea(aAreaFL5)
RestArea(aAreaFLD)
RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F667CanFlu

Realiza o cancelamento do processo no Fluig

@author Alvaro Camillo Neto
@since 09/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function F667CanFlu(cViagem,cPartic,cAdiant)
Local aArea		:= GetArea()
Local aAreaFLD	:= FLD->(GetArea())
Local cWfId		:= ""
Local cCodUsrApv	:= ""
Local cUserFluig	:= ""

FLD->(dbSetOrder(1))//FLD_FILIAL+FLD_VIAGEM+FLD_PARTIC+FLD_ADIANT
If FLD->(dbSeek(xFilial("FLD") + cViagem + cPartic + cAdiant ))
	cWfId := FLD->FLD_WFKID
	//Realiza o Cancelamento da Solicitação de Aprovação no FLUIG.
	If !Empty(cWFID) .AND. !FWIsInCallStack("WFFINA667")
		DbSelectArea("RD0")
		RD0->(DbSetOrder(1))
		RD0->(DbSeek(xFilial("RD0")+cPartic))
		cCodUsrApv := RD0->RD0_USER
		If cCodUsrApv <> ""
			cUserFluig := FWWFColleagueId(cCodUsrApv)
			CancelProcess(Val(cWfId),cUserFluig,STR0092)//"Excluido pelo sistema Protheus"
			RecLock("FLD",.F.)
				FLD->FLD_WFKID := ''
			MsUnLock()
		Endif
	Endif
EndIf

RestArea(aAreaFLD)
RestArea(aArea)
Return

//------------------------------------------
/*/{Protheus.doc} F667VldV()
Valida se o Adiantamento pode ser aprovado 
de acordo com o Status da Viagem. 

@author Rodrigo A. Pirolo
@since 20/10/2016
@version 1.0
/*/
//------------------------------------------

Static Function F667VldV()

Local lRet		:= .T.
Local oModel	:= FwModelActive()
Local oModelFLD	:= oModel:GetModel("FLDMASTER")

DbSelectArea("FL5")
FL5->( DbSetOrder(1) )

If FL5->( DbSeek( oModelFLD:GetValue("FLD_FILIAL") + oModelFLD:GetValue("FLD_VIAGEM") ) )
	If FL5->FL5_STATUS == "5" .OR. FL5->FL5_STATUS == "6" // 5 - Aguardando Aprovação	6 - Solicitada
		lRet := .F.
		Help("  ",1,"F667VldV",,STR0135 ,1,0) // "Não é permitido aprovar um Adiantamento para Viagens com Status igual a 'Aguardando Aprovação' ou 'Solicitada'."
	EndIf
Else
	lRet := .F.
	Help("  ",1,"F667VldV",,STR0136 + oModelFLD:GetValue("FLD_VIAGEM") + STR0137 ,1,0) // "Não foi possivel encontrar a Viagem de código:" + oModelFLD:GetValue("FLD_VIAGEM") + " na base de dados."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FN667Oper
Define a operação quando executado pelo Robô de Testes 

@author Automacao
@since  03/06/2016
/*/
//-------------------------------------------------------------------
Function FN667Oper(nOper,lAutoApr) //-- Automação
Default lAutoApr	:= .F.
Default nOper		:= 0

__nOper 		:= nOper
__lReprovou	:= lAutoApr

Return
