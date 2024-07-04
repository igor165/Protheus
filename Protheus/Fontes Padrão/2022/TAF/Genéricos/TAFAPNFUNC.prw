#Include "Totvs.CH"
#Include "FwMvcDef.CH"
#Include "FwBrowse.CH"
#Include "TAFPNFUNC.CH"
#INCLUDE "TOPCONN.CH"

#Define LARGURA_DO_SBUTTON 32

//------------------------------------------------------------------
/*/{Protheus.doc} TAFPNFUNC
Painel de Gerenciamento do Trabalhador
@Author Rodrigo Aguilar
@Since 24/02/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAFPNFUNC()

	Local cFilPnl 		:= ""
	Local lFiltFil		:= SuperGetMV( "MV_TAFFPNT", .F., .T. )

	Private oBrw 		:= FwMBrowse():New()
	Private lMarkAll	:= .F.
	Private oBrowse 	:= Nil
	Private oPanelBrw	:= Nil
	Private oTree		:= Nil
	Private nRecnoFunc	:= 0
	Private lPainel		:= .F.
	Private lFirstOpe	:= .F.
	Private lExistAlt	:= .F.

	// Função que indica se o ambiente é válido para o eSocial 2.3
	If TafAtualizado()

		If	( FPerAcess(,,,,"TAFA420") .AND. FPerAcess(,,,,"TAFA421") ).AND. IIf(FindFunction("PROTDATA"),ProtData(),.T.)

			//Monta-se uma browse com todos os trabalhadores vigentes, dos tipos S2200 e S2300
			oBrw:SetDescription( STR0001 ) //'Painel de Gerenciamento do Trabalhador'
			oBrw:SetAlias( 'C9V' )
			oBrw:SetMenuDef( 'TafaPnFunc' )

			If !lFiltFil
				cFilPnl := "C9V_FILIAL == '" + xFilial( "C9V" ) + "' .AND.  "
			EndIf

			cFilPnl += "C9V_ATIVO == '1' .AND. ( C9V_NOMEVE == 'S2200' .OR. C9V_NOMEVE == 'S2300' )"

			oBrw:SetFilterDefault( cFilPnl  )
			oBrw:DisableDetails()

			oBrw:Activate()

		EndIf
	EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@Return
aRotina - Array com as opções do Menu
@author Rodrigo Aguilar
@since 24/02/2014
@version 1.0

/*/
//--------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	Add Option aRotina Title STR0002 Action 'VIEWDEF.TAFAPNFUNC' OPERATION 2 ACCESS 0 //'Painel do Trabalhador'
	Add Option aRotina Title STR0003 Action 'TafPnSlFun()' OPERATION 2 ACCESS 0 //'Filtro Rápido'

Return ( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@Return
oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 24/02/2014
@version 1.0

/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel    := FWLoadModel( 'TAFA256' )
	Local oView     := FWFormView():New()

	Local oStruC9V:= Nil

	oView:SetModel( oModel )

	oStruC9V  := FwFormStruct( 2, 'C9V',{ |x| AllTrim( x ) + '|' $ 'C9V_CPF|C9V_NOME|' } )

	oView:AddField( 'VIEW_C9V', oStruC9V, 'MODEL_C9V' )

	//Tree com os Eventos do Trabalhador
	oView:AddOtherObject( 'PANEL_TREE',  { |oPanel| FGerTree( oPanel ) } )

	//Espaço Vazio
	oView:AddOtherObject( 'PANEL_EMPTY', { |oPanel| } )

	//Browse Com as Informações do trabalhador
	oView:AddOtherObject( 'PANEL_BROWSE',{ |oPanel| oPanelBrw := oPanel, FBrowseMon( oPanel ) } )

	oView:CreateHorizontalBox( 'INFO_FUNC',   08 )
	oView:CreateHorizontalBox( 'EVENTO_FUNC', 91 )
	oView:CreateHorizontalBox( 'FIM_TELA',    01 )

	oView:CreateVerticalBox( 'INFO_FUNC_ESQ', 100,'INFO_FUNC' )

	oView:CreateVerticalBox( 'EVENTO_FUNC_ESQ', 27,'EVENTO_FUNC' )
	oView:CreateVerticalBox( 'EVENTO_FUNC_CENTER', 01,'EVENTO_FUNC' )
	oView:CreateVerticalBox( 'EVENTO_FUNC_DIR', 72,'EVENTO_FUNC' )

	oView:CreateVerticalBox( 'FIM_TELA_EMPTY', 100, 'FIM_TELA' )

	oView:SetOwnerView( 'VIEW_C9V', 'INFO_FUNC_ESQ' )
	oView:SetOwnerView( 'PANEL_TREE', 'EVENTO_FUNC_ESQ' )
	oView:SetOwnerView( 'PANEL_EMPTY', 'EVENTO_FUNC_CENTER' )
	oView:SetOwnerView( 'PANEL_BROWSE', 'EVENTO_FUNC_DIR' )
	oView:SetOwnerView( 'PANEL_EMPTY', 'FIM_TELA_EMPTY' )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafPnSlFun
Função de Filtro rápido de trabalhador para visualização no Painel

@author Rodrigo Aguilar
@since 24/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function TafPnSlFun()

	Local oDlg			:= Nil
	Local oMainWnd		:= Nil
	Local cTitle		:= STR0002 //'Painel do Trabalhador'
	Local cMatric		:= ''
	Local cCpf    		:= ''
	Local cNome   		:= ''
	Local nAltura	    := 270
	Local nLargura      := 400
	Local nAlturaBox    := 0
	Local nLarguraBox   := 0
	Local nLarguraSay   := 0
	Local nTop         	:= 0
	Local nPosIni       := 0
	Local nAlturaButton	:= 0
	Local nButtons      := 2
	Local aButtons 		:= {}
	Local lOk 			:= .F.

	Define Font oFont Name "Arial" Size 0, -11

	Define MsDialog oDlg Title cTitle From 0,0 To nAltura, nLargura Of oMainWnd Pixel

	//Ajustando Tamanho da Tela
	nAlturaBox		:=	( nAltura - 70 ) / 2
	nLarguraBox	:= 	( nLargura- 20 ) / 2

	@30,10 To nAlturaBox , nLarguraBox Of oDlg Pixel

	cMatric := Space( TamSx3( 'CUP_MATRIC' )[ 1 ] )
	cCpf    := Space( TamSx3( 'C9V_CPF' )[ 1 ] )

	//Ajustando Tamanho da Tela
	nLarguraSay := 	nLarguraBox - 30
	nTop :=	 10

	TSay():New( nTop , 10 , {|| STR0004 } , oDlg , , oFont , .F. , .F. , .F. , .T. , , , nLargura - 25 , 10 , .F. , .F. , .F. , .F. , .F. ) //'Informe a matrícula ou o CPF do Trabalhador que '

	//Ajustando Tamanho da Tela
	nTop +=	 10

	TSay():New( nTop , 10 , {|| STR0005 } , oDlg , , oFont , .F. , .F. , .F. , .T. , , , nLargura - 25 , 10 , .F. , .F. , .F. , .F. , .F. ) //'deseja visualizar no Painel:'

	//Ajustando Tamanho da Tela
	nTop +=	 20

	TSay():New( nTop , 20 , {|| STR0006 } , oDlg , , oFont , .F. , .F. , .F. , .T. , , , nLarguraSay / 2 , 10 , .F. , .F. , .F. , .F. , .F. ) //'Matrícula:'
	TSay():New( nTop , 85 , {|| STR0007 } , oDlg , , oFont , .F. , .F. , .F. , .T. , , , nLarguraSay / 2 , 10 , .F. , .F. , .F. , .F. , .F. ) //'CPF:'

	//Ajustando Tamanho da Tela
	nTop += 10
	TGet():New( nTop , 20  , { | u | If( PCount() == 0 , cMatric , cMatric := RetMatric(u) ) } , oDlg , 060 , 10 , '@!', {|| FVldFuncPn( @cMatric, cCpf, @cNome, @lOk, 1 ) } , , , ,  , , .T. , , , ,, , , .F. , , 'C9VD' )
	TGet():New( nTop , 85  , { | u | If( PCount() == 0 , cCpf , cCpf := u ) } , oDlg , 85 , 10 , '@R 999.999.999-99',{|| FVldFuncPn( @cMatric, @cCpf, @cNome, @lOk, 2 ) } , , , , .F. , , .T. , , .F. , {|| .T. } , .F. , .F. , , .F. , .F. )

	//Ajustando Tamanho da Tela
	nTop += 20

	TSay():New( nTop , 20 , {|| STR0008 } , oDlg , , oFont , .F. , .F. , .F. , .T. , , , nLarguraSay / 2 , 10 , .F. , .F. , .F. , .F. , .F. ) //'Nome:'

	//Ajustando Tamanho da Tela
	nTop += 10

	TGet():New( nTop , 20  , { | u | If( PCount() == 0 , cNome , cNome := AllTrim(u) ) } , oDlg , 150 , 10 , '@!', {|| .T. } , , , , .F. , , .T. , , .F. , {|| .F. } , .F. , .F. , , .F. , .F. )

	//Ajustando Tamanho da Tela
	nTop += 20

	nPosIni := 	( ( nLargura - 20 ) / 2 ) - ( nButtons * LARGURA_DO_SBUTTON )
	nAlturaButton	:= 	nAlturaBox + 10

	//Botão Confirmar
	SButton():New( nAlturaButton , nPosIni , 1 , { | o | lOk := .T., o:oWnd:End() } , oDlg , .T. , , )

	//Ajustando Tamanho da Tela
	nPosIni	+=	LARGURA_DO_SBUTTON

	//Botão Cancelar
	SButton():New( nAlturaButton , nPosIni , 2 , { | o | lOk := .F., o:oWnd:End() } , oDlg , .T. , , )

	oDlg:Activate( , , , .T.,, , , , )

	//Caso o Trabalhador informado tenha sido localizado abro o Painel para manutenção/visualização
	If lOk
		aButtons := { { .F., Nil }, { .F., Nil }, { .F., Nil }, { .T., Nil }, { .T., Nil }, { .T., Nil }, { .T., Nil }, { .T., STR0009}, { .T., Nil }, { .T., Nil },{ .T., Nil }, { .T. , Nil }, { .T., Nil }, { .T., Nil } } //"Fechar"
		FWExecView( STR0002, 'TAFAPNFUNC', MODEL_OPERATION_UPDATE, , { || .T. }, , ,aButtons )  //'Painel do Trabalhador'
	
	EndIf


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FVldFuncPn

Função que verifica se a matricula ou CPF informado existem na base de dados
de acordo com a seguinte regra:

Quando informado o CPF o SEEK é exato, ou seja, logicamente só deve existir um
trabalhador com seu CPF.

Quando informada a Matrícula e a mesma existe exise para dois trabalhadores é montado
um MsSelect para que seja selecionado o trabalhador que deseja visualizar

@param
cMatric - Matricula informado pelo usuário
cCpf    - CPF informado pelo usuário
cNome   - Nome do Trabalhador
lOk     - Indica se algum trabalhador foi selecionado
nOpc    - Indica de qual campo a funçaõ foi chamada

@return
lOk - Indica se o CPF ou Matrícula informado foi encontrado

@author Rodrigo Aguilar
@since 24/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FVldFuncPn( cMatric, cCpf, cNome, lOk, nOpc )

	Local cChvVinc	:= ""
	Local cAliasQry	:=	GetNextAlias()
	Local cQuery	:=	""
	Local aFunc		:= {}
	Local aAreaCUP 	:= CUP->(GetArea())
	Local aAreaC9V 	:= C9V->(GetArea())

	//Campo Matricula
	If nOpc == 1
		If !Empty(cMatric) // Apenas valido se o usuário informou a matricula do trabalhador
			If Posicione("C9V", 21, xFilial("C9V") + PadR(cMatric, TamSx3("C9V_MATTSV")[1]), "C9V_NOMEVE") == "S2300"
				lOk		:= ExistCpo("C9V", PadR(cMatric, TamSx3("C9V_MATTSV")[1]), 21)
				cNome 	:= Iif(lOk, AllTrim(Posicione("C9V", 21, xFilial("C9V") + PadR(cMatric, TamSx3("C9V_MATTSV")[1]), "C9V_NOME")), "")
			Else
				lOk 	:= ExistCpo("C9V", PadR(cMatric, TamSx3("C9V_MATRIC")[1]) + "1", 11)
				cNome 	:= Iif(lOk, AllTrim(Posicione("C9V", 11, xFilial("C9V") + PadR(cMatric, TamSx3("C9V_MATRIC")[1]), "C9V_NOME")), "")
			EndIf
		EndIf
	ElseIf nOpc == 2 //Campo CPF

		//Apenas valido a informação se o usuário informou o CPF do trabalhador
		If !Empty( cCpf )

			cQuery := "SELECT C9V_ID, C9V_CPF, C9V_NOMEVE, C9V_NOME, R_E_C_N_O_ Recno "
			cQuery += "FROM " + RetSqlName( "C9V" ) 
			cQuery += " WHERE C9V_FILIAL = '" + xFilial( "C9V" ) + "' "
			cQuery += " AND C9V_ATIVO = '1' AND ( C9V_NOMEVE = 'S2200' OR C9V_NOMEVE = 'S2300' ) "
			cQuery += " AND C9V_CPF = '" + cCpf + "' "
			cQuery += " AND D_E_L_E_T_ = '' "

			cQuery := ChangeQuery( cQuery )
			
			TcQuery cQuery New Alias (cAliasQry)
			
			(cAliasQry)->(dbGoTop()) 		

			While (cAliasQry)->(!Eof())

				Aadd( aFunc, { (cAliasQry)->C9V_NOMEVE, (cAliasQry)->C9V_CPF, (cAliasQry)->C9V_NOME, (cAliasQry)->Recno, (cAliasQry)->C9V_ID } )

				(cAliasQry)->(dbSkip())

			Enddo

			//zero o campo referente a matricula do trabalhador
			cMatric := Space( TamSx3( 'CUP_MATRIC' )[ 1 ] )							

			(cAliasQry)->( DBCloseArea() )	

		EndIf
	EndIf

	//Caso os campos referentes a matricula e CPF nao tenham sido informados nenhuma ação deve ser realizada
	If nOpc == 2 .AND. !Empty(cCpf)

		//Verifico se foi encontrado trabalhador com os filtros indicados
		If Len( aFunc ) > 0

			//Verifico se existe apenas um trabalhador com os filtros indicados
			If Len( aFunc ) > 1

				//Monto tela para seleção do trabalhador desejado no caso de encontrar mais de um registro
				//para o filtro
				FMultFunc( aFunc, @lOk )

				//Alimento o nome com o trabalhador escolhido
				If lOk
					cNome := C9V->C9V_NOME
				EndIf
			Else

				//No caso de existir apenas um retorno para a consulta posiciono no registro corrente
				C9V->( DbGoTo( aFunc[ 1, 4 ] ) )

				//Alimento o nome com o trabalhador escolhido
				cNome := C9V->C9V_NOME
				lOk := .T.
			EndIf

			nRecnoFunc := C9V->( Recno() )

		Else

			//Caso não encontre nenhum trbalhador com o CPF/MATRICULA informada retorno .F.
			lOk := .F.
		EndIf
	Else
		lOk := .T.
	EndIf

	If !lOk
		CUP->( RestArea( aAreaCUP ) )
		C9V->( RestArea( aAreaC9V ) )
	EndIf

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} FMultFunc
Monta tela para seleção no caso de Multiplos Vínculos( Matrícula repetida )

@param
aFunc - Array com as informações de todos os trabalhadores encontrados
lOk   - Indica se algum Trabalhador foi selecionado

@return
lOk - Indica se algum Trabalhador foi selecionado

@author Rodrigo Aguilar
@since 24/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function FMultFunc( aFunc, lOk )

	Local nlI := 0

	Local _stru   := {}
	Local aCpoBro := {}

	Local oDlgLocal, oMark

	Local lInverte  := .F.
	Local lRegSel   := .F.

	Local oTmpTab	:= Nil
	Local cMark   	:= GetMark()

	Local cAliasTRB := GetNextAlias()

	//Estrutura da tabela temporaria
	Aadd( _stru,{ "OK", "C"	, 2	,	0	} )
	Aadd( _stru,{ "NOMEVE", "C"	, 10	,0	} )
	Aadd( _stru,{ "CPF"   , "C"	, 20	,0	} )
	Aadd( _stru,{ "NOME"  , "C"	, 200	,0	} )
	Aadd( _stru,{ "RECNO" , "N"	, 10	,0	} )
	Aadd( _stru,{ "ID" 	  , "C"	, 6		,0	} )

	oTmpTab := FWTemporaryTable():New(cAliasTRB, _stru)
	oTmpTab:Create()

	DbSelectArea(cAliasTRB)
	//(cAliasTRB)->(DBGoTop())

	//Alimentando a tabela com os trabalhadores encontrados com a mesma matricula
	For nlI := 1 To Len( aFunc )
		RecLock( cAliasTRB, .T. )
		(cAliasTRB)->NOMEVE := aFunc[nlI,1]
		(cAliasTRB)->CPF    := aFunc[nlI,2]
		(cAliasTRB)->NOME   := aFunc[nlI,3]
		(cAliasTRB)->RECNO  := aFunc[nlI,4]
		(cAliasTRB)->ID  	:= aFunc[nlI,5]
		(cAliasTRB)->( MsUnlock() )
	Next

	//Definindo a visualização das informações
	aCpoBro	:= {{ "OK"		,, " "   ,"@!"},;		
		{ "ID"		,, "Id"    	 ,"@!" },;
		{ "NOMEVE"	,,"Evento"  ,"@!"},;
		{ "CPF"		,, "CPF"     ,"@R 999.999.999-99" },;
		{ "NOME"	,, "Nome"    ,"@!" } }

	//Posicionando no inicio da tabela temporaria
	//DbSelectArea( cAliasTRB )
	(cAliasTRB)->( DbGoTop() )

	Define Font oFont Name "Arial" Size 0, -11

	Define MsDialog oDlgLocal Title STR0010 From 9,0 To 315,800 Pixel //"Múltiplos Trabalhadores"

	TSay():New( 5 , 1 , {|| STR0011 } , oDlgLocal , , oFont , .F. , .F. , .F. , .T. , , , 200 , 10 , .F. , .F. , .F. , .F. , .F. ) //"Selecione o Trabalhador que deseja visualizar"
	oMark := MsSelect():New( cAliasTRB, "OK", "", aCpoBro, @lInverte, @cMark,{17,1,150,400},,,,,{})
	oMark:bMark := {| | FAltSel( cAliasTRB, cMark, oMark, @lRegSel )}

	Activate MsDialog oDlgLocal Centered On Init EnchoiceBar( oDlgLocal,{ || lOk := VldGrid( .T., cAliasTRB ),iif(lOk,oDlgLocal:End(),"" )}, { || oDlgLocal:End() } )

	//Fecho o Alias de Trabalho utilizado
	oTmpTab:Delete()

Return ( lOk )

//-------------------------------------------------------------------
/*/{Protheus.doc} VldGrid             
Valida se os dados da Grid estão integros 

@author David Costa
@since  06/01/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function VldGrid( lConfirm, cAliasTRB )

Local lOk	:= .F.
Local nI	:= 0


//Verifica se o usuário acionou o botão confirmar da tela
If lConfirm

	//Verifico se algum trabalhador foi selecionado
	(cAliasTRB)->( DbGoTop() )
	While (cAliasTRB)->( !Eof() )
		If !Empty( (cAliasTRB)->OK )

			//Posiciono no trabalhador selecionado pelo usuário
			C9V->( DbGoto( (cAliasTRB)->RECNO ) )

			lOk := .T.			
		EndIf
		(cAliasTRB)->( DbSkip() )
	Enddo

	If !lOk
		MSGALERT("Necessário selecionar um trabalhador.", "Aviso")
	EndIf

Else
	//Caso nenhum trabalhador tenha sido selecionado retorno como .F.
	lOk := .F.
EndIf


Return (lOk)

//-------------------------------------------------------------------
/*/{Protheus.doc} FAltSel
Tratamento para mudança de seleção do MsSelect da escolha do trabalhador
a ser visualizado no Painel

@param
cAliasTRB - Alias Utilizado para montar o MsSelect
cMark     - Variável de controle de seleção
oMark     - Objeto do MsSelect
lRegSel   - Variável que indica se já existe algum registro do MsSelect selecionado,
apenas pode ser escolhido um funcionário por vez.

@return ( Nil )

@author Rodrigo Aguilar
@since 07/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function FAltSel( cAliasTRB, cMark, oMark, lRegSel )

	RecLock( cAliasTRB, .F. )
	If Marked( "Ok" )
		If !lRegSel
			(cAliasTRB)->OK := cMark
			lRegSel := .T.
		Else
			(cAliasTRB)->OK := ""
		EndIf
	Else
		(cAliasTRB)->OK := ""
		lRegSel := .F.
	Endif
	(cAliasTRB)->(MsUnlock() )

	//Atualizo o MsSelect
	oMark:oBrowse:Refresh()

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} FChcTpFunc
Retorna o cadastro que deve ser aberto de acordo com o tipo do trabalhador
ou qual o nível da árvore que o usuário selecionou

@Param
cIdTreePos - Nível da àrvore que o trabalhador selecionou

@Return
aRet - Array com as informações do cadastro que deve ser aberto

@author Rodrigo Aguilar
@since 11/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function FChcTpFunc( cIdTreePos )
	Local aRet    		:= Array( 04 )
	Local cCpfTrab 		:= ""
	Local lCadIni			:= .F.

	Default cIdTreePos 	:= ""

	cCpfTrab := IIf(FunName() == "TAFMONTES",(cAliasTrb)->C9V_CPF,M->C9V_CPF)
	cIdTrab	 :=	M->C9V_ID
	
	C9V->( DbSetOrder(4) )

	/*--------------------------------------------------------------------------
	Verifico se a função esta sendo chamada para montar a Browse Inicial, neste
	caso, verifico qual cadastro alimentará a Browse de acordo com o tipo do
	Trabalhador, respeitando a ordem: ( Cadastro Inicial, Admissão e
	Trabalhador sem vínculo ) oque ocorrer primeiro alimenta a Browse.
	----------------------------------------------------------------------------*/
	If Empty( cIdTreePos )

		/*--------------------------------------------------------------------------
		Cadastro Inicial do Vínculo
		Caso exista o campo C9V_CADINI, procuro o cadastro inicial pelo índice 17
		eSocial layout 2.3
		--------------------------------------------------------------------------*/
		C9V->( DbSetOrder(17) )	// C9V_FILIAL+C9V_CPF+C9V_CATCI+C9V_ATIVO

		If C9V->( MsSeek( xFilial( "C9V" ) + cCpfTrab + "S" + "1"   ) )
			aRet[1] 	:= 'TAFA256'
			aRet[2] 	:= 'C9V'
			aRet[3] 	:= "C9V_ATIVO == '1' .And. C9V_NOMEVE == 'S2200' .And. C9V_ID == '" + C9V->C9V_ID + "' .AND. C9V_FILIAL == '" + xFilial( "C9V" ) + "' .AND. C9V_CADINI = 'S' "
			aRet[4] 	:= STR0012 //"Cadastro Inicial do Vínculo"
			lCadIni	:= .T.
		EndIf

		C9V->( DbSetOrder(16) )

		If !lCadIni
			/*--------------------------------------------------------------------------
			Admissão do Trabalhador
			--------------------------------------------------------------------------*/
			If M->C9V_NOMEVE == 'S2200' .AND. C9V->( MsSeek( xFilial( "C9V" ) +  cIdTrab + "S2200" + "1" ) )
				aRet[1] := 'TAFA278'
				aRet[2] := 'C9V'
				aRet[3] := "C9V_ATIVO == '1' .and. C9V_NOMEVE == 'S2200' .And. C9V_ID == '" + C9V->C9V_ID + "' .AND. C9V_FILIAL == '" + xFilial( "C9V" ) + "'"
				aRet[4] := STR0013 //"Admissão do Trabalhador"

			/*--------------------------------------------------------------------------
			Trabalhador sem Vínculo
			--------------------------------------------------------------------------*/
			ElseIf M->C9V_NOMEVE == 'S2300' .AND. C9V->( MsSeek( xFilial( "C9V" ) + cIdTrab + "S2300" + "1"  ) )
				aRet[1] := 'TAFA279'
				aRet[2] := 'C9V'
				aRet[3] := "C9V_ATIVO == '1' .and. C9V_NOMEVE == 'S2300' .And. C9V_ID == '" + C9V->C9V_ID + "' .AND. C9V_FILIAL == '" + xFilial( "C9V" ) + "'"
				aRet[4] := STR0014 //"Trabalhador sem Vínculo"
			EndIf
		EndIf

	//Caso contrário a função esta sendo chamada pelo Tree
	Else
		
		C9V->(dBSetOrder(16))
		
		//Referentes a Trabalhadores com Vínculo ( Inicial / Admissão )
		If cIdTreePos $ '001|004|005|006|007|008|009|010|011|012|013|014|015|016'

			//Posiciono no registro correto para que possa ser realizado o Filtro na Browse de acordo com
			//o id do Trabalhador
			If M->C9V_NOMEVE == 'S2200' .AND. C9V->( MsSeek( xFilial( "C9V" ) + cIdTrab + "S2200" + "1" ) )

				If cIdTreePos == '001' .And. C9V->C9V_NOMEVE = 'S2200'
					aRet[1] := 'TAFA278'
					aRet[2] := 'C9V'
					aRet[3] := "C9V_ATIVO == '1' .and. C9V_NOMEVE == 'S2200' .And. C9V_ID == '" + C9V->C9V_ID + "' .AND. C9V_FILIAL == '" + xFilial( "C9V" ) + "'"
					aRet[4] := STR0016 //'Admissão do Trabalhador'

					//Alteração Cadastral
				ElseIf cIdTreePos == '004'
					aRet[1] := 'TAFA275'
					aRet[2] := 'C9V'
					aRet[3] := "C9V_ATIVO == '1' .and. C9V_NOMEVE == 'S2205' .And. C9V_CPF == '" + C9V->C9V_CPF + "' .AND. C9V_FILIAL == '" + xFilial( "C9V" ) + "'"
					aRet[4] := STR0017 //"Alteração Cadastral"

					//Alteração Contratual
				ElseIf cIdTreePos == '005'
					aRet[1] := 'TAFA276'
					aRet[2] := 'C9V'
					aRet[3] := "C9V_ATIVO == '1' .and. C9V_NOMEVE == 'S2206' .And. C9V_CPF == '" + C9V->C9V_CPF + "' .AND. C9V_FILIAL == '" + xFilial( "C9V" ) + "'"
					aRet[4] := STR0018 //"Alteração Contratual"

					//CAT
				ElseIf cIdTreePos == '006'
					aRet[1] := 'TAFA257'
					aRet[2] := 'CM0'
					aRet[3] := "CM0_ATIVO == '1' .And. CM0_TRABAL == '" + C9V->C9V_ID + "' .AND. CM0_FILIAL == '" + xFilial( "CM0" ) + "'"
					aRet[4] := STR0019 //"Comun. Acidente de Trabalho"

					//Monitoramento da Saúde do Trabalhador
				ElseIf cIdTreePos == '007'
					aRet[1] := 'TAFA258'
					aRet[2] := 'C8B'
					aRet[3] := "C8B_ATIVO == '1' .And. C8B_FUNC == '" + C9V->C9V_ID + "' .AND. C8B_FILIAL == '" + xFilial( "C8B" ) + "'"
					aRet[4] := STR0040 //"Monitoramento da Saúde do Trabalhador"

					//Afastamento Temporário
				ElseIf cIdTreePos == '008'
					aRet[1] := 'TAFA261'
					aRet[2] := 'CM6'
					aRet[3] := "CM6_ATIVO == '1' .And. CM6_FUNC == '" + C9V->C9V_ID + "' .AND. CM6_FILIAL == '" + xFilial( "CM6" ) + "'"
					aRet[4] := STR0021 //"Afastamento Temporário"

					//Condições Ambientais do Trabalho - Fatores de Risco
				ElseIf cIdTreePos == '009'
					aRet[1] := 'TAFA264'
					aRet[2] := 'CM9'
					aRet[3] := "CM9_ATIVO == '1' .And. CM9_FUNC == '" + C9V->C9V_ID + "' .AND. CM9_FILIAL == '" + xFilial( "CM9" ) + "'"
					aRet[4] := STR0026 //"Condições Ambientais do Trabalho - Fatores de Risco"

					//Insalubridade, Periculosidade e Aposentadoria Especial
				ElseIf cIdTreePos == '010'
					aRet[1] := 'TAFA404'
					aRet[2] := 'T3B'
					aRet[3] := "T3B_ATIVO == '1' .And. T3B_IDTRAB == '" + C9V->C9V_ID + "' .AND. T3B_FILIAL == '" + xFilial( "T3B" ) + "'"
					aRet[4] := STR0058 //Insalubridade, Periculosidade e Aposentadoria Especial

					//Aviso Prévio
				ElseIf cIdTreePos == '011'
					aRet[1] := 'TAFA263'
					aRet[2] := 'CM8'
					aRet[3] := "CM8_ATIVO == '1' .And. CM8_TRABAL == '" + C9V->C9V_ID + "' .AND. CM8_FILIAL == '" + xFilial( "CM8" ) + "'"
					aRet[4] := STR0028 //"Aviso Prévio"

					//Reintegração
				ElseIf cIdTreePos == '012'
					aRet[1] := 'TAFA267'
					aRet[2] := 'CMF'
					aRet[3] := "CMF_ATIVO == '1' .And. CMF_FUNC == '" + C9V->C9V_ID + "' .AND. CMF_FILIAL == '" + xFilial( "CMF" ) + "'"
					aRet[4] := STR0031 //"Reintegração"

					//Desligamento
				ElseIf cIdTreePos == '013'
					aRet[1] := 'TAFA266'
					aRet[2] := 'CMD'
					aRet[3] := "CMD_ATIVO == '1' .And. CMD_FUNC == '" + C9V->C9V_ID + "' .AND. CMD_FILIAL == '" + xFilial( "CMD" ) + "'"
					aRet[4] := STR0030 //"Desligamento"

					//Folha de Pagamento
				ElseIf cIdTreePos == '014'
					aRet[1] := 'TAFA250'
					aRet[2] := 'C91'
					aRet[3] := "C91_ATIVO == '1' .And. C91_TRABAL == '" + C9V->C9V_ID + "' .AND. C91_FILIAL == '" + xFilial( "C91" ) + "' .AND. C91_NOMEVE == 'S1200'"
					aRet[4] := STR0032 // "Folha de Pagamento"

					//Remuneração Servidor RPPS
				ElseIf cIdTreePos == '015'
					aRet[1] := 'TAFA413'
					aRet[2] := 'C91'
					aRet[3] := "C91_ATIVO == '1' .And. C91_TRABAL == '" + C9V->C9V_ID + "' .AND. C91_FILIAL == '" + xFilial( "C91" ) + "' .AND. C91_NOMEVE == 'S1202'"
					aRet[4] := STR0059 // "Remuneração Servidor RPPS"

					//Pagto. Rendimentos Trabalho
				ElseIf cIdTreePos == '016'
					aRet[1] := 'TAFA407'
					aRet[2] := 'T3P'
					aRet[3] := "T3P_ATIVO == '1' .And. T3P_BENEFI == '" + C9V->C9V_ID + "' .AND. T3P_FILIAL == '" + xFilial( "T3P" ) + "'"
					aRet[4] := STR0061 // "Pagto. Rendimentos Trabalho"

				EndIf
			EndIf

			//Referentes a Trabalhadores Sem Vínculo
		ElseIf cIdTreePos $ '101|102|103|104|105|106|107|108|109|110|111|112|113'

			//Posiciono no registro correto para que possa ser realizado o Filtro na Browse de acordo com
			//o id do Trabalhador
			If M->C9V_NOMEVE == 'S2300' .AND. C9V->( MsSeek( xFilial( "C9V" ) + cIdTrab + "S2300" + "1" ) )

				//Cadastro do Trabalhador Sem Vínculo - Início
				If cIdTreePos == '101'
					aRet[1] := 'TAFA278'
					aRet[2] := 'C9V'
					aRet[3] := "C9V_ATIVO == '1' .and. C9V_NOMEVE == 'S2300' .And. C9V_ID == '" + C9V->C9V_ID + "' .AND. C9V_FILIAL == '" + xFilial( "C9V" ) + "'"
					aRet[4] := STR0060 //"Trabalhador Sem Vínculo - Início""

					//Alteração Contratual
				ElseIf cIdTreePos == '104'
					aRet[1] := 'TAFA277'
					aRet[2] := 'C9V'
					aRet[3] := "C9V_ATIVO == '1' .and. C9V_NOMEVE == 'S2306' .And. C9V_CPF == '" + C9V->C9V_CPF + "' .AND. C9V_FILIAL == '" + xFilial( "C9V" ) + "'"
					aRet[4] := STR0018 //"Alteração Contratual"

					//Término do Contrato
				ElseIf cIdTreePos == '105'
					aRet[1] := 'TAFA280'
					aRet[2] := 'T92'
					aRet[3] := "T92_ATIVO == '1' .And. T92_TRABAL == '" + C9V->C9V_ID + "' .AND. T92_FILIAL == '" + xFilial( "T92" ) + "'"
					aRet[4] := STR0033 //"Término do Contrato"

					//CAT
				ElseIf cIdTreePos == '106'
					aRet[1] := 'TAFA257'
					aRet[2] := 'CM0'
					aRet[3] := "CM0_ATIVO == '1' .And. CM0_TRABAL == '" + C9V->C9V_ID + "' .AND. C9V_FILIAL == '" + xFilial( "C9V" ) + "'"
					aRet[4] := STR0019 //"Comun. Acidente de Trabalho"

					//Afastamento Temporário
				ElseIf cIdTreePos == '107'
					aRet[1] := 'TAFA261'
					aRet[2] := 'CM6'
					aRet[3] := "CM6_ATIVO == '1' .And. CM6_FUNC == '" + C9V->C9V_ID + "' .AND. CM6_FILIAL == '" + xFilial( "CM6" ) + "'"
					aRet[4] := STR0021 //"Afastamento Temporário"

					//Condições Ambientais do Trabalho - Fatores de Risco
				ElseIf cIdTreePos == '108'
					aRet[1] := 'TAFA264'
					aRet[2] := 'CM9'
					aRet[3] := "CM9_ATIVO == '1' .And. CM9_FUNC == '" + C9V->C9V_ID + "' .AND. CM9_FILIAL == '" + xFilial( "CM9" ) + "'"
					aRet[4] := STR0026 //"Cond. Amb. Trab.- Fatores de Risco"

					//Insalubridade, Periculosidade e Aposentadoria Especial
				ElseIf cIdTreePos == '109'
					aRet[1] := 'TAFA404'
					aRet[2] := 'T3B'
					aRet[3] := "T3B == '1' .And. T3B_IDTRAB == '" + C9V->C9V_ID + "' .AND. T3B_FILIAL == '" + xFilial( "T3B" ) + "'"
					aRet[4] := STR0058 //"Insalub., Pericul. e Aposen. Especial"

					//Folha de Pagamento
				ElseIf cIdTreePos == '111'
					aRet[1] := 'TAFA250'
					aRet[2] := 'C91'
					aRet[3] := "C91_ATIVO == '1' .And. C91_TRABAL == '" + C9V->C9V_ID + "' .AND. C91_FILIAL == '" + xFilial( "C91" ) + "' .AND. C91_NOMEVE == 'S1200'"
					aRet[4] := STR0032 // "Folha de Pagamento"

					//Remuneração Servidor RPPS
				ElseIf cIdTreePos == '112'
					aRet[1] := 'TAFA413'
					aRet[2] := 'C91'
					aRet[3] := "C91_ATIVO == '1' .And. C91_TRABAL == '" + C9V->C9V_ID + "' .AND. C91_FILIAL == '" + xFilial( "C91" ) + "' .AND. C91_NOMEVE == 'S1202'"
					aRet[4] := STR0059 // "Remuneração Servidor RPPS"

					//Pagto. Rendimentos Trabalho
				ElseIf cIdTreePos == '113'
					aRet[1] := 'TAFA407'
					aRet[2] := 'T3P'
					aRet[3] := "T3P_ATIVO == '1' .And. T3P_BENEFI == '" + C9V->C9V_ID + "' .AND. T3P_FILIAL == '" + xFilial( "T3P" ) + "'"
					aRet[4] := STR0061 // "Pagto. Rendimentos Trabalho"

				EndIf

			EndIf
		EndIf
	EndIf

Return ( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} FGerTree
Função responsável por montar o Tree de navegação

@Param
oPanel - Painel onde será montado o Tree

@Author Rodrigo Aguilar
@since 24/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function FGerTree( oPanel )

	Local aCoors	:= FWGetDialogSize( oPanel )

	Local bChange := { || Processa( { || FChgTree()  }, STR0002, STR0034 ) } //"Painel do Trabalhador"#"Atualizando Informações do Browse..."

	Local cCpfTrab := M->C9V_CPF

	C9V->( DbSetOrder(4) )

	// Cria a Tree
	oTree := DbTree():New( aCoors[1] + 10 ,aCoors[2] + 10,aCoors[3]-10,aCoors[4]-10, oPanel, bChange , , .T. )


	If M->C9V_NOMEVE == 'S2200' .AND. C9V->( MsSeek( xFilial( "C9V" ) + cCpfTrab+ "S2200" + "1" ) )
		oTree:AddTree( STR0013 , .T., "FOLDER10" ,"FOLDER11",,,"001" )//"Admissão do Trabalhador"
		
	ElseIf M->C9V_NOMEVE == 'S2300' .AND. C9V->( MsSeek( xFilial( "C9V" ) + cCpfTrab+ "S2300" + "1" ) )
		oTree:AddItem( STR0014, "101", "FOLDER10" ,"FOLDER11",,,1 ) //"Trabalhador Sem Vínculo"
		
	EndIf

	
	If oTree:TreeSeek( "001" )

		oTree:AddItem( STR0056, "002", "FOLDER5","FOLDER6",,,2) //"Eventos Não Periódicos"
		oTree:AddItem( STR0057, "003", "FOLDER5","FOLDER6",,,2) //"Eventos Periódicos"

		//Eventos Não Periódicos
		If oTree:TreeSeek("002")
			//oTree:AddItem( STR0037, "004", "PMSEDT3",,,,2 ) //"Alter.Dados Cadastrais"
			//oTree:AddItem( STR0038, "005", "PMSEDT3",,,,2 ) //"Alter.Dados Contratuais"
			oTree:AddItem( STR0039, "006", "PMSEDT3",,,,2 ) //"Com.Acidente Trabalho"
			oTree:AddItem( STR0040, "007", "PMSEDT3",,,,2 ) //"Monitoramento da Saúde do Trabalhador"
			oTree:AddItem( STR0041, "008", "PMSEDT3",,,,2 ) //"Afast. Temporário"
			oTree:AddItem( STR0026, "009", "PMSEDT3",,,,2 ) //"Condições Amb. Trab. - Fatores de Risco"
			oTree:AddItem( STR0058, "010", "PMSEDT3",,,,2 ) //"Insalubridade, Periculosidade e Aposentadoria Especial"
			oTree:AddItem( STR0048, "011", "PMSEDT3",,,,2 ) //"Aviso Prévio"
			oTree:AddItem( STR0051, "012", "PMSEDT3",,,,2 ) //"Reintegração"
			oTree:AddItem( STR0050, "013", "PMSEDT3",,,,2 ) //"Desligamento"

		Endif

		//Eventos Periódicos
		If oTree:TreeSeek( "003" )
			oTree:AddItem( STR0032, "014", "PMSEDT3",,,,2 ) //"Folha de Pagamento"
			oTree:AddItem( STR0059, "015", "PMSEDT3",,,,2 ) //"Remuneração Servidor RPPS"
			oTree:AddItem( STR0061, "016", "PMSEDT3",,,,2 ) //"Pagto. Rendimentos Trabalho"
		Endif
	Endif

	If oTree:TreeSeek( "101" )

		oTree:AddItem( STR0056, "102", "FOLDER5","FOLDER6",,,2) //"Eventos Não Periódicos"
		oTree:AddItem( STR0057, "103", "FOLDER5","FOLDER6",,,2) //"Eventos Periódicos"

		//Eventos Não Periódicos
		If oTree:TreeSeek( "102" )
			//oTree:AddItem( STR0054, "104", "PMSEDT3",,,,2 ) //"Alteração Contratual"
			oTree:AddItem( STR0055, "105", "PMSEDT3",,,,2 ) //"Término do Contrato"
			oTree:AddItem( STR0053, "106", "PMSEDT3",,,,2 ) //"Comun. Acidente de Trabalho"
			oTree:AddItem( STR0041, "107", "PMSEDT3",,,,2 ) //"Afast. Temporário"
			oTree:AddItem( STR0026, "108", "PMSEDT3",,,,2 ) //"Condições Amb. Trab. - Fatores de Risco"
			//oTree:AddItem( STR0058, "109", "PMSEDT3",,,,2 ) //"Insalubridade, Periculosidade e Aposentadoria Especial"

		Endif

		//Eventos Periódicos
		If oTree:TreeSeek( "103" )
			oTree:AddItem( STR0032, "111", "PMSEDT3",,,,2 ) //"Folha de Pagamento"
			oTree:AddItem( STR0059, "112", "PMSEDT3",,,,2 ) //"Remuneração Servidor RPPS"
			oTree:AddItem( STR0061, "113", "PMSEDT3",,,,2 ) //"Pagto. Rendimentos Trabalho"
		Endif

	EndIf

	oTree:TreeSeek( "001" )

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} FBrowseMon
Monta o Browse de visualização das informações

@Param
oPanel     - Painel onde será montado o Tree
cFonteTree - Nome do Fonte a ser utilizado para construção da Browse
cAliasTree - Nome do Alias a ser utilizado para construção da Browse
cFiltroBrw - Filtro a ser utilizado para construção da Browse
cDescBrw   - Título a ser utilizado na Browse

@Author Rodrigo Aguilar
@since 24/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function FBrowseMon( oPanel, cFonteTree, cAliasTree, cFiltroBrw, cDescBrw )

	Local cCPF      := C9V->C9V_CPF
	Local cEvento   := ""
	Local aInf      := {}
	Local aFields   := {}
	Local aButtons  := {}
	Local aArea     := {}
	Local lShowBrw  := .T.
    Local cFunName  := FunName()

	Default cFonteTree := ""
	Default cAliasTree := ""
	Default cFiltroBrw := ""
	Default cDescBrw   := ""

	//Caso não tenha sido informado os parametros da função significa que não estamos navegando
	//na browse mas sim na abertura da tela
	If Empty( cFonteTree ) .And. Empty( cAliasTree )
		aInf := FChcTpFunc()

		cFonteTree := aInf[1]
		cAliasTree := aInf[2]
		cFiltroBrw := aInf[3]
		cDescBrw   := aInf[4]
	EndIf

    // Utilizado para carregar as opções da MenuDef corretamente
    If cFonteTree $ "TAFA278|TAFA279"
        SetFunName("TAFA421")
    EndIf

	//Tratamento para eventos de alteracao cadastral/contratual do trabalhador
	If cFonteTree $ "TAFA275|TAFA276|TAFA277|TAFA280"

		lPainel   := .T.
		lFirstOpe := .F.
		lExistAlt := .T.

		Do Case
		Case cFonteTree == "TAFA275"
			cEvento := "S2205"
		Case cFonteTree == "TAFA276"
			cEvento := "S2206"
		Case cFonteTree == "TAFA277"
			cEvento := "S2306"
		Case cFonteTree == "TAFA280"
			cEvento := "S2399"
		EndCase

		aArea := C9V->( GetArea() )
		
		T92->( DbSetOrder(3) )

		//C9V->( DBSetOrder( 3 ) )
		//If !C9V->( MsSeek( xFilial( "C9V" ) + cCPF + "1" ) )
		If !T92->( MsSeek( xFilial( "T92" ) + C9V->C9V_ID + "1" ) )
			If MsgYesno( "Não existem alterações cadastradas para o trabalhador, deseja incluir ? " )
				lFirstOpe := .T.
				aButtons := { { .F., Nil }, { .F., Nil }, { .F., Nil }, { .T., Nil }, { .T., Nil }, { .T., Nil }, { .T., "Salvar" }, { .T., "Cancelar" }, { .T., Nil }, { .T., Nil },{ .T., Nil }, { .T. , Nil }, { .T., Nil }, { .T., Nil } } //#"Salvar" #"Cancelar"
				RestArea( aArea )
				lShowBrw := FwExecView( "Inclusao por FwExecView", cFonteTree, MODEL_OPERATION_INSERT, , { || .T. }, , , aButtons ) == 0
			Else
				lShowBrw := .F.
			EndIf
		EndIf

		RestArea( aArea )

	EndIf

	//Monta-se a Browse
	If lShowBrw
		oBrowse := FWmBrowse():New()

		oBrowse:SetOwner( oPanel )
		oBrowse:SetDescription( cDescBrw )
		oBrowse:SetAlias( cAliasTree )

		aFields := xFunGetSX3( cAliasTree )
		oBrowse:aFields := {}

		oBrowse:SetFields( aFields )
		oBrowse:SetMenuDef( cFonteTree )
		oBrowse:DisableDetails()
		oBrowse:SetFilterDefault( cFiltroBrw )

		oBrowse:Activate()

		//Tratamento para eventos de alteracao cadastral/contratual do trabalhador
	Else

		oTree:TreeSeek( "001" )
		FChgTree( "001" )

	EndIf

    // Restaurar a função original
    If cFonteTree $ "TAFA278|TAFA279"
        SetFunName(cFunName)
    EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} FBrowseMon
Função executada na mudança de seleção do Tree

@Param
cIdTreePos - Identificacao do item a ser posicionado.

@Author Rodrigo Aguilar
@since 24/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function FChgTree( cIdTreePos )

	Local aInfTree := {}

	Default cIdTreePos := oTree:GetCargo()

	//Verifico se o item da Tree selecionado deve ser atualizado
	If ! ( cIdTreePos $ "|002|003|102|" )
		oPanelBrw:FreeChildren()
		oBrowse:DeActivate()
		aInfTree := FChcTpFunc( cIdTreePos )

		If FPerAcess(,,,,aInfTree[1])
			FBrowseMon( oPanelBrw, aInfTree[1], aInfTree[2], aInfTree[3], aInfTree[4] )
		EndIf

	EndIf
	oBrowse:Refresh()

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} RetMatric
Retorna a Matrícula do trabalhador conforme ID e Evento

@param cFunc - ID do trabalhador ou Matrícula

@author Melkz Siqueira
@since 03/05/2021
@version 1.0		

@return cRet - Matrícula do trabalhador
/*/
//-------------------------------------------------------------------
Static Function RetMatric(cFunc)

	Local cRet := cFunc

	If IsInCallStack("GETF3RETFWGET")
		If Posicione("C9V", 2, xFilial("C9V") + PadR(cFunc, TamSx3("C9V_ID")[1]) + "1", "C9V_NOMEVE") == "S2300"
			cRet := AllTrim(Posicione("C9V", 2, xFilial("C9V") + PadR(cFunc, TamSx3("C9V_ID")[1]) + "1", "C9V_MATTSV"))
		Else
			cRet := AllTrim(Posicione("C9V", 2, xFilial("C9V") + PadR(cFunc, TamSx3("C9V_ID")[1]) + "1", "C9V_MATRIC"))
		EndIf
	EndIf

Return cRet
