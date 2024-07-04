#INCLUDE "JURA254.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------- ----------------------------------
/*/{Protheus.doc} JURA254
Solicitação de Documentos

@author Willian.Kazahaya
@since 05/02/2018
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JURA254(cProcesso, lChgAll, cFilFiltro)

Local cHabPesqS := SuperGetMV("MV_JHBPESS",, '2') //“Habilita a tela de pesquisa de Solic. Documentos (1=Sim;2=Não) (Valor Padrão 2)"
Local oBrowse
Local aArea     := GetArea()
Local aAreaNSZ  := NSZ->( GetArea() )

Default lChgAll    := .T. 
Default cFilFiltro := xFilial("O0M")
	
	If cHabPesqS == '1' .AND. !(IsInCallStack('JURA162') .Or. IsInCallStack('JURA219') .Or. IsInCallStack('JURA095'))
		MsgRun(STR0014,STR0015, {||JURA162("6",STR0007,"JURA254")}) //"Carregando..." # "Aguarde..."
	Else
	
		oBrowse := FWMBrowse():New()
		oBrowse:SetDescription( STR0001 )      //Prazo de estimativa de término
		oBrowse:SetAlias( "O0M" )
		oBrowse:SetChgAll( lChgAll )
		oBrowse:SetLocate()
		If !Empty( cProcesso )
			oBrowse:SetFilterDefault( "O0M_FILIAL == '" + cFilFiltro + "' .AND. O0M_CAJURI == '" + cProcesso + "'" )
		Endif
	
		oBrowse:SetMenuDef( 'JURA254' )
		JurSetBSize( oBrowse, '50,50,50' )
		JurSetLeg( oBrowse, "O0M" )
		oBrowse:Activate()
	Endif
	
	RestArea( aAreaNSZ )
	RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Willian.Kazahaya
@since 05/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	
	If JA162AcRst('19',2)
		aAdd( aRotina, { STR0003, "VIEWDEF.JURA254", 0, 2, 0, NIL } ) //"Visualizar"
	EndIf
	If JA162AcRst('19',3)
		aAdd( aRotina, { STR0004, "VIEWDEF.JURA254", 0, 3, 0, NIL } ) //"Incluir"
	EndIf
	If JA162AcRst('19',4)
		aAdd( aRotina, { STR0005, "VIEWDEF.JURA254", 0, 4, 0, NIL } ) //"Alterar"
	EndIf
	If JA162AcRst('19',5)
		aAdd( aRotina, { STR0006, "VIEWDEF.JURA254", 0, 5, 0, NIL } ) //"Excluir"
	EndIf
	
	aAdd( aRotina, { STR0007, "VIEWDEF.JURA254", 0, 8, 0, NIL } ) //"Imprimir"
	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados da Solicitação de documentos

@author Willian.Kazahaya
@since 05/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView
	Local oModel  	:= FWLoadModel( "JURA254" )
	Local oStructO0M := FWFormStruct( 2, "O0M" )
	Local oStructO0N := FWFormStruct( 2, "O0N" )
	Local aBotoes   	:= {}
	
	oStructO0N:AddField( ;
		'BOTAO'            , ;         // [01] Campo
		"00"               , ;         // [02] Ordem
		STR0012            , ;         // [03] Titulo 
		STR0012            , ;         // [04] Descricao 
		NIL                , ;         // [05] Help
		'BT'               , ;         // [06] Tipo do campo   COMBO, Get ou CHECK
		'@BMP'             , ;		   // [07] Picture
		                   , ;		   // [08] Bloco de picture Var 
		                   , ;         // [09] Chave para ser usado no LooKUp 
		.T.                  )         // [10] Logico dizendo se o campo pode ser alterado
	
	// Cabeçalho (O0MMASTER)
	oStructO0M:RemoveField( "O0M_CUSRSL" )		

	// Detalhe (O0NDETAIL)
	oStructO0N:RemoveField( "O0N_CSLDOC" )
	oStructO0N:RemoveField( "O0N_CPART" )
	oStructO0N:RemoveField( "O0N_FLAG01" )	
	oStructO0N:RemoveField( "O0N_FLAG02" )
	
	oView := FWFormView():New()
	
	oView:SetModel( oModel )
	oView:SetDescription( STR0001 ) 
	
	oView:AddField( "JURA254_MASTER" , oStructO0M, "O0MMASTER"  )
	oView:AddGrid(  "JURA254_DETAIL" , oStructO0N, "O0NDETAIL" )
	
	oView:CreateHorizontalBox( "FORMMASTER" , 40 )
	oView:CreateHorizontalBox( "FORMDETAIL" , 60 )
		
	oView:SetOwnerView( "O0MMASTER" , "FORMMASTER" )
	oView:SetOwnerView( "O0NDETAIL" , "FORMDETAIL" )
	
	oView:AddIncrementField( 'O0NDETAIL', 'O0N_SEQ' )

	oView:SetUseCursor( .T. )
	oView:EnableControlBar( .T. )
	
	If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT01"} ) <= 0 ) ) .And. JA162AcRst('03')
		oView:AddUserButton( STR0011, "CLIPS", {|oX| JCall26O0N()  } ) // Anexos
	EndIf	
	
	oView:AddUserButton( STR0033, "BUDGET", { | oView | J254LegPag() } ) // "Legenda"
	oView:AddUserButton( STR0020, "BUDGET", { | oView | J254BtnEnv(oView:GetModel()) } ) // "Enviar e-mail"
 
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da Solicitação de documentos

@author Willian.Kazahaya
@since 05/02/2018
@version 1.0

@obs O0MMASTER - Dados da Solicitação de documentos
@obs O0NDETAIL - Documentos da Solicitação
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oModel     := NIL
	Local oStructO0M := FWFormStruct( 1, "O0M" )
	Local oStructO0N := FWFormStruct( 1, "O0N" )
	Local lTLegal  := JModRst()
		
	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	// Inclusão de campos no grid
	oStructO0N:AddField( ;
	STR0012                        , ;               			// [01] Titulo do campo // "Arquivo XML"
	STR0012                        , ;               			// [02] ToolTip do campo // "Arquivo XML"
	'BOTAO'                        , ;               			// [03] Id do Field
	'BT'                           , ;               			// [04] Tipo do campo
	20                             , ;               			// [05] Tamanho do campo
	0                              , ;               			// [06] Decimal do campo
	{|| JCall26O0N() } , ; 											// [07] Code-block de validação do campo // "Arquivo XML"
	, ;                                       					// [08] Code-block de validação When do campo
	, ;                                              			// [09] Lista de valores permitido do campo
	.F.                            , ;               			// [10] Indica se o campo tem preenchimento obrigatório
	{|| J254Legend(O0N->O0N_STATUS) }, ; 							// [11] Bloco de código de inicialização do campo.
	, ;																	// [12] Indica se trata-se de um campo chave.
	, ; 																// [13] Indica se o campo não pode receber valor em uma operação de update.
	.T.   )															// [14] Indica se o campo é virtual.
	
	If lTLegal // Se a chamada estiver vindo do TOTVS Legal
		//Campo que indica se o registro posicionado possui anexo - criado para o TOTVS Legal
		oStructO0N:AddField( ;
			""                                                 , ; // [01] Titulo do campo
			""		                                           , ; // [02] ToolTip do campo
			"O0N__TEMANX"                                      , ; // [03] Id do Field
			"C"                                                , ; // [04] Tipo do campo
			2                                                  , ; // [05] Tamanho do campo
			0                                                  , ; // [06] Decimal do campo
			,                                                    ; // [07] Bloco de código de validação do campo
			,                                                    ; // [08] Bloco de código de validação when do campo
			,                                                    ; // [09] Lista de valores permitido do campo
			,                                                    ; // [10] Indica se o campo tem preenchimento obrigatório
			{|| JTemAnexo("O0N",O0M->O0M_CAJURI,O0M->O0M_COD+O0N->O0N_SEQ)} , ; // [11] Bloco de código de inicialização do campo
			,                                                    ; // [12] Indica se trata-se de um campo chave
			,                                                    ; // [13] Indica se o campo não pode receber valor em uma operação de update
			.T.                                                  ; // [14] Indica se o campo é virtual
			,                                                    ; // [15] Valid do usuário em formato texto e sem alteração, usado para se criar o aHeader de compatibilidade
		)
		oStructO0N:SetProperty('O0N_STATUS', MODEL_FIELD_VALID, {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) })
	Endif

	// Criação do Modelo	
	oStructO0N:RemoveField('O0N_CSLDOC')

	oModel:= MPFormModel():New( "JURA254", /*Pre-Validacao*/, {|oMdl| TudoOk(oMdl)}/*bPosValid*/, {|oMdl| ModelCommit(oMdl)}, /*Cancel*/)
	oModel:SetDescription( STR0007 )//"Modelo de Dados"  
	 
	oModel:AddFields( "O0MMASTER", /*NIL*/, oStructO0M, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:AddGrid( "O0NDETAIL", "O0MMASTER" /*cOwner*/, oStructO0N, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
                                                                            
	oModel:GetModel("O0MMASTER"):SetDescription( STR0009 )  //"Regra do Follow-up Automático
	oModel:GetModel("O0NDETAIL"):SetDescription( STR0010 )  //modelos disparados
	
	If !lTLegal
		oModel:SetPrimaryKey( { "O0MMASTER", "O0M_COD" } )
		oModel:SetPrimaryKey( { "O0NDETAIL", {"O0N_FILIAL", "O0N_SEQ"} } ) 
	EndIf

	oModel:GetModel( "O0NDETAIL" ):SetUniqueLine( { "O0N_SEQ" } )
	oModel:SetRelation("O0NDETAIL", {{"O0N_FILIAL", "XFILIAL('O0N')" }, {"O0N_CSLDOC", "O0M_COD"}}, O0N->( IndexKey( 1 ))) 
	
	oModel:GetModel("O0NDETAIL"):SetDelAllLine( .F. ) 

	oModel:SetOptional( "O0NDETAIL" , .F. )
		
	JurSetRules( oModel, "O0NDETAIL",, "O0N" )
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} TudoOk
Realiza as pré-validações do modelo
@param 	oModel  Model a ser verificado
@Return lRet Retorno lógico
@since 10/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TudoOk(oModel)
Local aArea   := (getArea())
Local oModelO0N  := oModel:GetModel("O0NDETAIL")
Local nDocs      := oModelO0N:Length()
Local nI         := 0
Local cCajuri    := oModel:GetValue("O0MMASTER","O0M_CAJURI")
Local cCodSol    := ''
Local cCodSeq    := '' 
Local cTpDoc     := ''
lOCAL cNomeDoc   := ''
Local lRet       := .T.

	If (oModel:GetOperation() == MODEL_OPERATION_UPDATE)
		DBSelectArea("O0L")

		For nI := 1 To nDocs

			oModelO0N:GoLine( nI )

			If ( !oModelO0N:IsDeleted(nI) ;
				 .And. oModelO0N:IsFieldUpdated("O0N_STATUS", nI) ;
				 .And. oModelO0N:GetValue("O0N_STATUS", nI) == "2" )

				cCodSol  := oModel:GetValue("O0MMASTER","O0M_COD") 
				cCodSeq  := oModelO0N:GetValue("O0N_SEQ", nI)
				cTpDoc   := oModelO0N:GetValue("O0N_CTPDOC", nI)
				cNomeDoc := Posicione("O0L", 1, xFilial("O0L") + cTpDoc, "O0L_NOME") 
				lRet := JTemAnexo("O0N",cCajuri,cCodSol+cCodSeq) == '01'

				If !lRet ; // Não tem anexo
					.And. (O0L->(FieldPos('O0L_S_ANEX')) > 0) ;
					.And. Posicione("O0L", 1, xFilial("O0L") + cTpDoc, "O0L_S_ANEX") // Anexo opicional

					If len( oModelO0N:GetValue("O0N_OBSERV", nI)) > 3
						lRet = .T.
					Else
						JurMsgErro( STR0044 + cNomeDoc ) //"Obrigatório informar uma observação para o documento: "
						Exit
					EndIf
				ElseIf !lRet
					JurMsgErro( STR0045 + cNomeDoc ) // "Obrigatório anexar um arquivo para o documento: "
					Exit
				EndIf
			EndIf
		Next nI
	EndIf

	RestArea( aArea )
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelCommit
Realiza o commit do model
@param 	oModel  Model a ser verificado
@Return lRet	Retorno lógico
@since 28/07/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelCommit(oModel)
Local lRet := FwFormCommit(oModel)
Local lJurAuto := JurAuto()
	
	If lRet
		If !lJurAuto
			J254BtnEnv(oModel)
		Else
			STARTJOB("J254EnvJob", GetEnvServer(), .F., cEmpAnt,cFilAnt,oModel:GetValue('O0MMASTER','O0M_COD'))
		Endif
	Endif

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J254PrzRec
Recalcula o prazo de entrega do cabeçalho

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não
@author Willian.Kazahaya
@since 05/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J254PrzRec(dPrzEnt)
Local lRet     := .T.
Local oModel   := FWModelActive()

	If oModel:GetValue("O0MMASTER","O0M_PRZSOL") < dPrzEnt
		oModel:SetValue("O0MMASTER","O0M_PRZSOL",dPrzEnt) 
	EndIf	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA254CAJUR
Verifica o preenchimento do campo de código de assunto jurídico

@Return cRet	 	Código do assunto jurídico

@author Willian Yoshiaki Kazahaya
@since 01/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA254CAJUR()
Local cRet := ''

	If IsInCallStack('JURA162') .And. !Empty(M->NSZ_COD)
		cRet := M->NSZ_COD
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA254HABCJ
Verifica se a tela não está sendo chamada a partir de Assunto Jurídico
e se a operação é de inclusão, para habilitar o campo de
Código de Assunto Jurídico para preenchimento pelo usuário

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Willian Yoshiaki Kazahaya
@since 01/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA254HABCJ()
Local lRet  := JModRst() //verifica se a chamada é via REST
	
	If IsInCallStack('JURA254') .And. INCLUI .AND. Empty(M->NSZ_COD)
		lRet := .T.
	EndIf
Return lRet


//----------------------------------------------------------//
/*/{Protheus.doc} JCall26O0N(cO0MCod)
Chamada da JURA026 com o ID do Modelo + Sequencial do Anexo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Willian Yoshiaki Kazahaya
@since 20/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JCall26O0N()
Local oModel    := FWModelActive()
Local oModelO0N := oModel:GetModel("O0NDETAIL")
Local oLineO0N  := oModelO0N:GetLine()
Local cOper     := oModel:GetOperation()
Local cO0MCod   := oModel:GetValue("O0MMASTER","O0M_COD")
Local cCajuri   := oModel:GetValue("O0MMASTER","O0M_CAJURI")
Local cO0NSeq   := oModelO0N:GetValue("O0N_SEQ")
Local cStatus   := ''

	If cOper == MODEL_OPERATION_UPDATE .AND. !(oModelO0N:IsInserted(oLineO0N))

		If ( JurAnexos('O0N', cO0MCod + cO0NSeq , 1) ;
			.Or. JTemAnexo("O0N",cCajuri,cO0MCod+cO0NSeq) == '01' )
			oModelO0N:LoadValue("O0N_STATUS", "2")
		EndIf

		cStatus := oModelO0N:GetValue("O0N_STATUS")

		Do Case
			Case cStatus == "1"
				cImagem := 'BR_VERMELHO.PNG'
			Case cStatus == "2"
				cImagem := 'BR_VERDE.PNG'
			Otherwise 
				cImagem := 'BR_BRANCO.PNG'
		EndCase

		// Envio de e-mail ao solicitante
		Processa( { |lEnd| J254EnvEml(cO0MCod,'2',@lEnd) }, STR0015, STR0037, .T.) //"Aguarde..." //"Enviando e-mail ao solicitante"				
	Else
		ApMsgInfo(STR0013, STR0001)
		//"Salve a solicitação para incluir anexos aos itens" ;"Solicitação de Documentos"
	EndIf
Return .T.

//----------------------------------------------------------//
/*/{Protheus.doc} J254Legend(cStatus, oModel)
Legenda do Status

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Willian Yoshiaki Kazahaya
@since 20/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J254Legend(cStatus)
Local cImagem := ""

	Do Case
		Case cStatus == "1"
			cImagem := 'BR_VERMELHO.PNG'
		Case cStatus == "2"
			cImagem := 'BR_VERDE.PNG'
		Otherwise 
			cImagem := 'BR_BRANCO.PNG'
	EndCase

Return cImagem

//----------------------------------------------------------//
/*/{Protheus.doc} J254AltStt(cCodO0N, cStatus)
Salvar alteração do Status

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Willian Yoshiaki Kazahaya
@since 20/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J254AltStt(cCodO0N, cStatus)

	O0N->( dbSetOrder( 1 ) )
	If O0N->( dbSeek( cCodO0N ) )	
		RecLock( 'O0N', .F. )  //Trava registro
		O0N->O0N_STATUS := cStatus
		MsUnlock()     //Destrava registro
		ConfirmSX8()
	Endif
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J254LegPag
Exibe a legenda do item de solicitação de documento

@Return Nil

@author Beatriz Gomes
@since 23/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J254LegPag()
Local aCores      := {}

aAdd( aCores, { "BR_BRANCO.PNG"   , STR0016 } ) // "Registro não cadastrado"
aAdd( aCores, { "BR_VERMELHO.PNG" , STR0017 } )  // "Item sem anexos"
aAdd( aCores, { "BR_VERDE.PNG"    , STR0018 } ) // "Item com anexo

BrwLegenda( STR0019, OemToAnsi("Status"), aCores ) // "Status"

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} J254BtnEnv
Envio de Email
@param oModel - Modelo de dados
@Return Nil

@author Willian.Kazahaya
@since 07/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J254BtnEnv(oModel,lJob)
Local lRet      := .T.
Local cCodSolic := ""
Default oModel  := FWModelActive()
Default lJob    := .F.

	cCodSolic := oModel:GetValue("O0MMASTER","O0M_COD")
	lRet := J254Envio({cCodSolic, cEmpAnt, cFilAnt})

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J254EnvJob
Instancia uma nova thread para envio de email
@param cEmp - Código da empresa para iniciar o ambiente
@param cFil - Código da filial para iniciar o ambiente
@param cCodSolic - Código da Solicitiação a ser filtrada
@Return Nil

@author Willian.Kazahaya
@since 07/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J254EnvJob(cEmp, cFil, cCodSolic)
Local lRet        := .T.
Default cCodSolic := ''

	RPCSetType(3) // Prepara o ambiente e não consome licença
	RPCSetEnv(cEmp,cFil, , , 'JURI') // Abre o ambiente
	
	lRet := J254Envio({cCodSolic, cEmp, cFil})

	RpcClearEnv() // Reseta o ambiente

Return lRet 
//-------------------------------------------------------------------
/*/{Protheus.doc} J254Envio(cCodSolic)
Método de envio utilizado para o Schedule

@Return Nil

@author Willian.Kazahaya
@since 07/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J254Envio(aCodCab)
Local lRet := .T. 
Local cCodSolic := ""
Local lSchedule := .F.
	
	If Len(aCodCab) >= 4
		RpcSetType(3) 	
		RPCSetEnv( aCodCab[1],aCodCab[2], , , ,"J254Envio")
		lSchedule := .T.
	Else
		cCodSolic := aCodCab[1]
	Endif
	
	If lSchedule // Verifica se é Schedule
		lRet := J254EnvEml(cCodSolic)
		If lRet 
			lRet := J254EnvEml(cCodSolic, '2')
		EndIf
	Else 
		Processa({|lEnd| lRet := J254EnvEml(cCodSolic,,@lEnd) }, STR0015, STR0038, .T.) // "Aguarde..." //"Enviando e-mails aos responsáveis"
		If lRet
			Processa( {|lEnd| lRet := J254EnvEml(cCodSolic,'2',@lEnd)}, STR0015, STR0037, .T.) // "Aguarde..." // "Enviando e-mail ao solicitante"
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J254EnvEml(cCodSolic, cTipo, lEnd, cMsgErro)
Envio de Email ao Responsável dos Itens

@Param cCodSolic - Código da Solicitação
@Param cTipo - Tipo de Envio 1= Responsável; 2= Solicitante
@Param lEnd - Verifica se foi encerrado
@param cMsgErro - <Referencia> Retorna a mensagem de erro
@Return lRet - Validação de erro na rotina

@author Willian.Kazahaya
@since 07/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J254EnvEml(cCodSolic, cTipo, lEnd,cMsgErro)
Local lRet        := .T.
Local cAlias      := GetNextAlias()
Local cQuery      := ""
Local aEmlDocs    := {}
Local nQtdReg     := 0
Local cMsgEnv     := ""
Local cEmlTst     := ""
Local cEmlTo      := SuperGetMV( 'MV_RELACNT',, "" )
Local lRetEnvEml  := .T.
Local aCodAtuO0N  := {}
Local nI          := 0
Local cCodResp    := "" 
Local cEmlResp    := "" 
Local cNomResp    := ""
Local cNomEnvol   := ""
Local cNumProcess := ""
Local cNumSolic   := ""
Local cFiliItem   := ""
Local cCajuri     := ""

Default cTipo     := "1"
Default cCodSolic := ""
Default cMsgErro  := ""
Default lEnd      := .F.


	cQuery := ChangeQuery(J254EmlQry(cCodSolic,cTipo))
	
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )
	
	If !IsBlind()
		ProcRegua(0)
		IncProc()
	EndIf
	
	While (cAlias)->(!Eof()) .AND. !lEnd
		If !Empty(cCodResp) .AND. ((cCodResp <> (cAlias)->CodResp) .OR. (cNumSolic <> (cAlias)->codSoli))
			
			// Montagem do Texto do E-mail a partir do tipo de operação
			If cTipo == '1'
				cMsgEnv := J254TxEmlR(aEmlDocs, cNomResp, cNomEnvol, cNumProcess, cNumSolic, cFiliItem)
			Else
				cMsgEnv := J254TxEmlS(aEmlDocs, cNomResp, cNumProcess, cNumSolic, cFiliItem, cCajuri)
			Endif
			
			//JurEnvMail - Função de envio de e-mail
			//(cDe,cPara,cCc,cCCO,cAssunto,cAnexo,cMsg,cServer,cEmail,cPass,lAuth,cContAuth,cPswAuth,lSSL,lTLS)
			If Empty(cEmlResp)
				lRetEnvEml := .F.	
			Else
				lRetEnvEml := JurEnvMail(cEmlTo,cEmlResp,cEmlTst,,STR0001,,cMsgEnv)
			EndIf

			aEmlDocs := {}
			If !lRetEnvEml 
				If cTipo == '1'
					cMsgErro += CRLF + STR0024 + cNumSolic + CRLF + STR0034 + cCodResp + "]" + cNomResp
					// Solicitação: " + cNumSolic + "Responsável: [" + cCodResp + "]"
					If Empty(cEmlResp)
						cMsgErro += cNomResp + STR0023 
						// "não contem e-mail configurado."
					Else
						lEnd := .T.
					EndIf
				Else
					cMsgErro += CRLF + STR0024 + cCodSolic + CRLF + STR0035 + cCodResp + "]" + cNomResp
					// Solicitação: " + cNumSolic + "Solicitante: [" + cCodResp + "]"
					If Empty(cEmlResp)
						cMsgErro += cNomResp + STR0023
						// "não contem e-mail configurado."
					Else
						lEnd := .T.
					EndIf
				EndIf
				cMsgErro += CRLF
				aCodAtuO0N := {}
			Else
				// Atualiza os Flags dos campos
				If Len(aCodAtuO0N) > 0
					For nI := 1 to Len(aCodAtuO0N)
						J254O0NFlg(cTipo, aCodAtuO0N[nI][1], aCodAtuO0N[nI][2], aCodAtuO0N[nI][3])
					Next
					aCodAtuO0N := {}
				EndIf
			EndIf
		EndIf
		
		// Lista com os documentos vinculados ao Responsável
		aAdd(aEmlDocs,{(cAlias)->nomeDoc,(cAlias)->seqItem})
		
		// Informações do Responsável 
		cCodResp    := (cAlias)->codResp
		cNomResp    := (cAlias)->nomeResp
		cEmlResp    := (cAlias)->emailResp
		cNomEnvol   := (cAlias)->nomEnvolvido
		cNumProcess := (cAlias)->numProcesso
		cNumSolic   := (cAlias)->codSoli
		cFiliItem   := (cAlias)->filiItem
		cCajuri     := (cAlias)->cajuri
	
		// Incluindo os ids para atualização 
	 	Aadd(aCodAtuO0N, {(cAlias)->filiItem , (cAlias)->codSoli , (cAlias)->seqItem, (cAlias)->codResp})
		nQtdReg++
		
		(cAlias)->(DbSkip())
	End		
	
	(cAlias)->( dbCloseArea() )
	
	// Caso tenha um ultimo registro ou somente 1 registro. Aplica o tratamento para envio
	If nQtdReg > 0 .AND. !lEnd
		
		// Enviar o ultimo e-mail
		If cTipo == '1'
			cMsgEnv := J254TxEmlR(aEmlDocs, cNomResp, cNomEnvol, cNumProcess, cNumSolic, cFiliItem)
		Else
			cMsgEnv := J254TxEmlS(aEmlDocs, cNomResp, cNumProcess, cNumSolic, cFiliItem, cCajuri)
		EndIf
		
		//JurEnvMail
		//(cDe,cPara,cCc,cCCO,cAssunto,cAnexo,cMsg,cServer,cEmail,cPass,lAuth,cContAuth,cPswAuth,lSSL,lTLS)
		If Empty(cEmlResp)
			lRetEnvEml := .F.
		Else
			lRetEnvEml := JurEnvMail(cEmlTst,cEmlResp,cEmlTst,,STR0001,,cMsgEnv)
		EndIf
		aEmlDocs := {}
		
		If !lRetEnvEml 
			If cTipo == '1'
				cMsgErro += CRLF + STR0024 + cNumSolic + CRLF + STR0034 + cCodResp + "]" + cNomResp
				// Solicitação: " + cNumSolic + "Responsável: [" + cCodResp + "]"
				If Empty(cEmlResp)
					cMsgErro += cNomResp + STR0023 
					// "não contem e-mail configurado."
				Else
					lEnd := .T.
				EndIf
			Else
				cMsgErro += CRLF + STR0024 + cCodSolic + CRLF + STR0035 + cCodResp + "]" + cNomResp
				// Solicitação: " + cNumSolic + "Solicitante: [" + cCodResp + "]"
				If Empty(cEmlResp)
					cMsgErro +=  cNomResp + STR0023
					// "não contem e-mail configurado."
				Else
					lEnd := .T.
				EndIf
			EndIf
			cMsgErro += CRLF
		Else
			// Atualiza os Flags dos campos
			If Len(aCodAtuO0N) > 0
				For nI := 1 to Len(aCodAtuO0N)
					J254O0NFlg(cTipo, aCodAtuO0N[nI][1], aCodAtuO0N[nI][2], aCodAtuO0N[nI][3])
				Next
				aCodAtuO0N := {}
			EndIf
		EndIf
	EndIf
	
	// Tratamento de Erro
	If !Empty(cMsgErro)
		//"E-mail não enviado: " + CRLF + cMsgErro + ")." + CRLF + "Favor verificar."
		cMsgErro := STR0021 + CRLF + cMsgErro + CRLF + STR0022

		JurMsgErro(cMsgErro)

		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J254TxEmlR(aEmlDocs, cNomResp, cNomEnvol, cNumProces, cNumSolic, cFilItem)
Envio de Email - Modelo do Responsável

@Param aEmlDocs - Array com os documentos vinculados ao responsável [1] = Nome documento [2] = Sequencial do Item
@Param cNomResp - Nome do responsável pelos documentos
@Param cNomEnvol - Nome do Envolvido da Solicitação
@Param cNumProces - Numero do Processo
@Param cNumSolic - Numero da Solicitação 
@Param cFilItem - Filial do item
@Return Texto do e-mail com o texto correto

@author Willian.Kazahaya
@since 07/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J254TxEmlR(aEmlDocs, cNomResp, cNomEnvol, cNumProces, cNumSolic, cFilItem)
Local cRet     := ""
Local cEmlDocs := ""
Local nI       := 0
Local cURLTL   := 'https://totvsjuridico.totvs.com.br/subsidios/dash?codSolic=#1'
Local cUrlSol  := StrTran(cFilItem+cNumSolic,"=","%3D")

	cURLTL := JurConvUTF8(I18n(cURLTL,{ENCODE64(cUrlSol)}))

	cRet := STR0025 + CRLF //"Prezado(a) #NomeResp#," + CRLF
	cRet += STR0026 + CRLF //"Foram solicitados os seguintes documentos referente ao Sr.(a) #NomeEnvolvido# para o processo #NumeroProcesso#." + CRLF 
	cRet += STR0027 + CRLF //"Solicitação origem: #CodSolic# " + CRLF + CRLF
	cRet += STR0028 + CRLF //"Documentos solicitados:" + CRLF
	cRet += "#ListDocs#" + CRLF
	cRet += CRLF
	cRet += I18n(STR0042,{cURLTL}) //'Para responder a solicitação <a href="#1" >acesse aqui!<a>'

	For nI := 1 to Len(aEmlDocs)
		cEmlDocs += "- " + /*"[" + aEmlDocs[nI][2] + "] " + */aEmlDocs[nI][1] + CRLF
	Next nI
	
	cRet := StrTran(cRet, "#NomeResp#", AllTrim(cNomResp))
	cRet := StrTran(cRet, "#NomeEnvolvido#", AllTrim(cNomEnvol))
	cRet := StrTran(cRet, "#NumeroProcesso#", cNumProces)
	cRet := StrTran(cRet, "#CodSolic#", cNumSolic)
	cRet := StrTran(cRet, "#ListDocs#", cEmlDocs)
	
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J254TxEmlS(aEmlDocs, cNomSolic, cNumProces,cNumSolic, cFilItem, cCajuri)
Envio de Email - Modelo do Solicitante

@Param aEmlDocs - Array com os documentos vinculados ao responsável [1] = Nome documento [2] = Sequencial do Item
@Param cNomSolic - Nome do solicitante pelos documentos
@Param cNumProces - Numero do Processo
@Param cNumSolic - Numero da Solicitação 
@Param cFilItem - Filial do item 
@Param cCajuri - Código do assunto juridico
@Return Texto do e-mail com o texto correto

@author Willian.Kazahaya
@since 07/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J254TxEmlS(aEmlDocs, cNomSolic, cNumProces, cNumSolic, cFilItem, cCajuri )
Local cRet := ""
Local cEmlDocs := ""
Local nI := 0
Local cURLTL   := 'https://totvsjuridico.totvs.com.br/processo/#1/#2/subsidios/#3'

	cURLTL := JurConvUTF8(I18n(cURLTL,{ENCODE64(cFilItem),ENCODE64(cCajuri),ENCODE64(cFilItem+cNumSolic)}))
	cURLTL := StrTran(cURLTL,"=","%3D")

	cRet := STR0029 + CRLF //"Prezado(a) #NomeSolic#," + CRLF
	cRet += STR0030 + CRLF //"Foram anexados os seguintes documentos referente a solicitação de documentos #CodSolic# do processo #CodProcess#." + CRLF 
	cRet += STR0031 + CRLF // "Itens anexados à solicitação:" + CRLF + CRLF
	cRet += "#ListDocs#"
	cRet += CRLF
	cRet += I18n(STR0043,{cURLTL})//'Para avaliar a solicitação <a href="#1" >acesse aqui!<a>'
	
	For nI := 1 to Len(aEmlDocs)
		cEmlDocs += "- " + /*"[" + aEmlDocs[nI][2] + "] " + */aEmlDocs[nI][1] + CRLF
	Next nI
	
	cRet := StrTran(cRet, "#NomeSolic#", AllTrim(cNomSolic))
	cRet := StrTran(cRet, "#CodSolic#", cNumSolic)
	cRet := StrTran(cRet, "#CodProcess#", cNumProces)
	cRet := StrTran(cRet, "#ListDocs#", cEmlDocs)
	
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J254EmlQry(cCodSolic ,cTipoOp)
Query de envio do e-mail

@Param cCodSolic - Código da solicitação
@Param cTipoOp   - Tipo de operação [1] Responsável [2] Solicitante 
@Return cQuery   - Retorna a Query usada para envio de e-mail

@author Willian.Kazahaya
@since 07/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J254EmlQry(cCodSolic ,cTipoOp)
Local cQuery := ""
Local cQrySel, cQryFrm, cQryWhr, cQryOrd := ""

Default cCodSolic := ""
Default cTipoOp := "1"

	// Clausula Select
	cQrySel := " SELECT "
	cQrySel +=    " O0N.O0N_CSLDOC codSoli "
	cQrySel +=    " ,O0N.O0N_SEQ seqItem "
	cQrySel +=    " ,O0N.O0N_Filial filiItem "
	cQrySel +=    " ,O0N.O0N_CTPDOC codDoc "
	cQrySel +=    " ,O0L.O0L_NOME nomeDoc "
	cQrySel +=    " ,O0N.O0N_FLAG01 flgEnvEmlResp "
	cQrySel +=    " ,O0N.O0N_FLAG02 flgEnvEmlSoli "
	cQrySel +=    " ,O0N.O0N_STATUS flgAnexoVinc "
	cQrySel +=    " ,O0M.O0M_CENVOL codEnvolvido "
	cQrySel +=    " ,NT9.NT9_NOME nomEnvolvido "
	cQrySel +=    " ,NUQ.NUQ_NUMPRO numProcesso "
	cQrySel +=    " ,O0M.O0M_CAJURI cajuri "
	
	If cTipoOp == '1'
		cQrySel +=    " ,O0N.O0N_CPART codResp "
		cQrySel +=    " ,RD0Resp.RD0_NOME nomeResp "
		cQrySel +=    " ,RD0Resp.RD0_SIGLA siglaResp "
		cQrySel +=    " ,RD0Resp.RD0_EMAIL emailResp "
	Else
		cQrySel +=    " ,O0M.O0M_CUSRSL codResp "
		cQrySel +=    " ,RD0Soli.RD0_NOME nomeResp"
		cQrySel +=    " ,RD0Soli.RD0_SIGLA siglaResp "
		cQrySel +=    " ,RD0Soli.RD0_EMAIL emailResp "
	EndIf
	
	// Clausula From
	cQryFrm := " FROM " +  RetSqlName('O0M') + " O0M INNER JOIN " +  RetSqlName('O0N') + " O0N ON (O0N.O0N_CSLDOC = O0M.O0M_COD " 
	cQryFrm += 											 										     " AND O0N.O0N_FILIAL = O0M.O0M_FILIAL "
	cQryFrm += 											 										     " AND O0N.D_E_L_E_T_ = ' ') "
	cQryFrm += " INNER JOIN " +  RetSqlName('O0L') + " O0L ON (O0L.O0L_COD = O0N.O0N_CTPDOC "
	cQryFrm += 						 					    " AND O0L.O0L_FILIAL = '" + xFilial("O0L") + "' "
	cQryFrm +=							 					    " AND O0L.D_E_L_E_T_ = ' ') "
	cQryFrm += " INNER JOIN " +  RetSqlName('NT9') + " NT9 ON (NT9.NT9_COD = O0M.O0M_CENVOL "
	cQryFrm +=                      					    " AND NT9.NT9_FILIAL = O0M.O0M_FILIAL  "
	cQryFrm +=                      					    " AND NT9.D_E_L_E_T_ = ' ') "
	cQryFrm += " INNER JOIN " +  RetSqlName('NSZ') + " NSZ ON (NSZ.NSZ_COD = O0M.O0M_CAJURI "
	cQryFrm += 						  					    " AND NSZ.NSZ_FILIAL = O0M.O0M_FILIAL " 
	cQryFrm +=                   	  					    " AND NSZ.D_E_L_E_T_ = ' ' )  "
	cQryFrm += " LEFT JOIN " +  RetSqlName('NUQ') + " NUQ ON (NUQ.NUQ_CAJURI = NSZ.NSZ_COD "
	cQryFrm += 						  					    " AND NUQ.NUQ_FILIAL = NSZ.NSZ_FILIAL "
	cQryFrm += 						  					    " AND NUQ.NUQ_INSATU = '1' "
	cQryFrm += 						  					    " AND NUQ.D_E_L_E_T_ = ' ') "
	
	If cTipoOp == '1'
		cQryFrm += " INNER JOIN " +  RetSqlName('RD0') + " RD0Resp ON (RD0Resp.RD0_CODIGO = O0N.O0N_CPART "
		cQryFrm += 						 	  				        " AND RD0Resp.D_E_L_E_T_ = ' ') "
	Else
		cQryFrm += " LEFT  JOIN " +  RetSqlName('RD0') + " RD0Soli ON (RD0Soli.RD0_USER = O0M.O0M_CUSRSL "
		cQryFrm += 							  						 " AND RD0Soli.D_E_L_E_T_ = ' ') "
	EndIf
	
	// Clausula Where
	cQryWhr := " WHERE 1=1"
	
	If !Empty(cCodSolic)
		cQryWhr += " AND O0M_COD = '" + cCodSolic + "' "
	EndIf
	
	If cTipoOp == '1'
		cQryWhr +=   " AND O0N_FLAG01 = '1' "
		cQryWhr +=   " AND O0N_STATUS = '1' "
  	Else
  		cQryWhr +=   " AND O0N_FLAG02 = '1' "
  		cQryWhr +=   " AND O0N_STATUS = '2' "
  	EndIf
  	
  	// Clausula Ordem
  	cQryOrd := " ORDER BY O0M_COD, O0N_CPART, O0M_USRSOL "
  	
	cQuery := cQrySel + cQryFrm + cQryWhr + cQryOrd
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J254Schedu()
Criação do Schedule para envio dos emails

@Return Nil

@author Willian.Kazahaya
@since 07/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J254Schedu()
Local aParams := {}
Local cCodSched 

	// Estrutura - [1] ID, [2] Empresa, [3] Filial
	aAdd( aParams, { "", cEmpAnt, cFilAnt })	 
  	cCodSched := FWAddSchedule( 'J254Envio',aParams)
	
	// Mensagem de geração do Schedule
	If !Empty(cCodSched)
		ApMsgInfo(STR0039, STR0001)
		//"Schedule criado com sucesso. Favor configurar a recorrência no configurador, caso necessário."; "Solicitação de Documentos"
	EndIf

Return !Empty(cCodSched)

//-------------------------------------------------------------------
/*/{Protheus.doc} J254O0NFlg(cTipo, cFilialSol, cCodSoli, cCodSeq, cFlag)
Atualização das Flags

@Param cTipo - Tipo de Envio de e-mail 1=Responsável 2=Solicitante
@Param cFilialSol - Filial da Solicitação
@Param cCodSoli - Código da Solicitação
@Param cCodSeq - Sequencial do Item
@Param cFlag - Status da flag

@Return lRet - Valida se foi executado com sucesso

@author Willian.Kazahaya
@since 12/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J254O0NFlg(cTipo, cFilialSol, cCodSoli, cCodSeq, cFlag)
Local lRet     := .T.
Local cCodigo  := cFilialSol + cCodSoli + cCodSeq
Local aAreaO0N := O0N->(GetArea())

Default cFlag  := "2"

	// Filial + CódSolicitação + SequencialItem
	O0N->( dbSetOrder( 1 ) )
	If O0N->( dbSeek( cCodigo ) )	
		RecLock( 'O0N', .F. )  //Trava registro
		If cTipo == '1'
			O0N->O0N_FLAG01 := cFlag
		Else
			O0N->O0N_FLAG02 := cFlag
		Endif
		MsUnlock()     //Destrava registro
		ConfirmSX8()
	Endif
	RestArea(aAreaO0N)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J254HabPrz()
Habilita ou não o prazo conforme o tipo de documento

@Return lRet - Se irá permitir alteração ou não

@author Willian.Kazahaya
@since 21/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J254HabPrz()
Local lRet 		:= .F.
Local oModel 		:= FWModelActive()
Local cCodDocto 	:= oModel:GetValue("O0NDETAIL","O0N_CTPDOC")

	O0L->( dbSetOrder( 1 ))
	If O0L->( dbSeek( xFilial("O0L") + cCodDocto) )
		lRet := O0L->O0L_INFPER == '1'
	EndIf 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J254DocSta()
Responsável por apresentar as opções do combo caso possua o campo 
O0L_REVISA

@Return cOpcoes - Lista de opções do combo de status
@since 10/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function J254DocSta()

Local cOpcoes    := ""
Local lO0LStatus := .F.

	// Verifica se o campo O0L_REVISA existe no dicionário
	If Select("O0L") > 0
		lO0LStatus := (O0L->(FieldPos('O0L_REVISA')) > 0)
	Else
		DBSelectArea("O0L")
			lO0LStatus := (O0L->(FieldPos('O0L_REVISA')) > 0)
		O0L->( DBCloseArea() )
	EndIf

	If lO0LStatus
		cOpcoes := AllTrim(STR0040) // "1=Pendente;2=Entregue;3=Em Revisão;"
	Else
		cOpcoes := AllTrim(STR0041) // "1=Pendente;2=Entregue;"
	EndIf

Return cOpcoes

//-------------------------------------------------------------------
/*/{Protheus.doc} J254LimpaFlag(cCodSolic)
Responsável por limpar a flag de envio de email

@Return cCodSolic - Código da Solicitação
@since 29/07/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function J254LimpaFlag(cCodSolic)
Local cAlias      := GetNextAlias()
Local cQuery      := ""

Default cCodSolic := ""

	cQuery +=	" SELECT  "
	cQuery +=		" (CASE O0N_STATUS "
	cQuery +=		" WHEN '1' THEN '1' "
	cQuery +=			" ELSE '2' "
	cQuery +=		" END) TIPO, "
	cQuery +=		" O0M.O0M_FILIAL, "
	cQuery +=		" O0M.O0M_COD, "
	cQuery +=		" O0N.O0N_SEQ "
	cQuery +=	" FROM " + RetSqlName('O0M') + " O0M "
	cQuery +=		" INNER JOIN " + RetSqlName('O0N') + " O0N ON "
	cQuery +=			" O0N.O0N_FILIAL = O0M.O0M_FILIAL "
	cQuery +=			" AND O0N.O0N_CSLDOC = O0M.O0M_COD "
	cQuery +=			" AND O0N.D_E_L_E_T_ = ' ' "
	cQuery +=	" WHERE  "
	cQuery +=		" O0M.O0M_FILIAL = '" + FWxFilial('O0M') + "' "
	cQuery +=		" AND O0M.O0M_COD = '"+cCodSolic+"' "
	cQuery +=		" AND O0M.D_E_L_E_T_ = ' ' "
	cQuery +=		" AND O0N.O0N_STATUS <> '2' "

	cQuery := ChangeQuery(cQuery)
	
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )
	
	While (cAlias)->(!Eof())

		J254O0NFlg((cAlias)->TIPO, (cAlias)->O0M_FILIAL, (cAlias)->O0M_COD, (cAlias)->O0N_SEQ, '1')
		(cAlias)->(DbSkip())

	End
	(cAlias)->(dbCloseArea())

return


//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldValid(oMdl,cField,uNewValue,uOldValue)
Função responsavel pela validação dos campos
@since  18/11/2020
@version 1.0
@param oMdl, character, SubModelo posicionado
@param cField, character, Campo posicionado
@param uNewValue, character, novo valor do campo
@param uOldValue, character, valor anterior do campo
@return lRet, retorno booleano, retorna se o campo está valido ou não
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue)
Local lRet := .T.
Do Case 
	Case cField == 'O0N_STATUS'
		If cValToChar(uNewValue) != cValToChar(uOldValue)
			If uNewValue == '1' //Pendente - Envia para responsável
				oMdl:SetValue('O0N_FLAG01','1')
			Else //Entrege/Revisão - Envia para solicitante
				oMdl:SetValue('O0N_FLAG02','1')
			Endif

		Endif

EndCase

return lRet
