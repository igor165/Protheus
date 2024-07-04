#INCLUDE 'JURXFUN.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'DBSTRUCT.CH'
#INCLUDE 'SHELL.CH'

Static aEmprSM0     := {}      // Dados das Empresas Filiais do Sigamat.Emp
Static aLegenda     := {}      // Vetor com as legendas de rotinas do sistema
Static aGrupos      := {}      // Vetor com as grupos de campos  de rotinas do sistema
Static aObrigat     := {}      // Vetor com os campos obrigatorios de rotinas do sistema
Static xVarPassag   := NIL     // Variavel Static  para passagem de valores entre funcoes
Static __x3Cache    := {}      // Informacoes diversas dos SX3
Static aWsdl        := {}		 // Carrega os objetos TWsdlManager ja utilizados para performance
Static _cJurF3Sx9			 // Retorno da função JURF3SX9\JurF3Sx9Re

Static _lFwPDCanUse := FindFunction("FwPDCanUse")

//-------------------------------------------------------------------
/*/{Protheus.doc} IsJurTab
Verifica se uma tabela do sistema faz parte do modulo SIGAJURI.
Uso Geral.

@param 	cTabela  	Tabela a ser verificada.
@param 	lShowMsg 	.T./.F. Exibe ou nao mensagem de erro

@Return lRet	 	.T./.F. A tabela pertence ou nao ao modulo SIGAJURI

@sample
If !IsJurTab( 'NQ1', .F. )
	ApMsgStop( 'Tabela nao pertence ao Modulo Juridico' )
EndIf

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function IsJurTab( cTabela, lShowMsg )
	Local lRet := .F.

	ParamType 0 Var cTabela    As Character
	ParamType 1 Var lShowMsg   As Logical   Optional Default .T.

	cTabela := AllTrim( cTabela )
	lRet    := ( ( cTabela >= 'NQ0' .AND. cTabela <= 'NZZ' ) .OR. ( cTabela >= 'OO0' .AND. cTabela <= 'OYZ' ) ) ;
		.AND. !cTabela $ 'NQ0/NQD/NQF/NQP/NQT'

	If !lRet .AND. lShowMsg
		JurMsgErro( STR0001 + cTabela + STR0002, ProcName() ) // "A tabela "###" não faz parte do mÃ³dulo SIGAJURI."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCabLog
Cria cabeçalho com informacoes de ambiemte para uso com AutoGrLog.
Uso Geral.

@param 	cTitulo  	Titulo a ser gravado no LOGS

@sample
JurCabLog( 'ROTINA DE IMPORTAÇÃO' ))

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurCabLog( cTitulo )

	ParamType 0 Var cTitulo    As Character Optional Default STR0034 + FunName() // "ARQUIVO DE LOG "

	AutoGrLog( Replicate( '-', 78 ) )
	AutoGrLog( cTitulo )
	AutoGrLog( Replicate( '-', 78 ) )
	AutoGrLog( STR0035 + cEmpAnt + '/' + cFilAnt             ) // "Empresa/Filial .....: "
	AutoGrLog( STR0036 + Capital( AllTrim( GetAdvFVal( 'SM0', 'M0_NOMECOM', cEmpAnt + cFilAnt, 1, '' ) ) ) ) // "Nome Empresa .......: "
	AutoGrLog( STR0037 + Capital( AllTrim( GetAdvFVal( 'SM0', 'M0_FILIAL' , cEmpAnt + cFilAnt, 1, '' ) ) ) ) // "Nome Filial ........: "
	AutoGrLog( STR0038 + DToC( dDataBase )                   ) // "DataBase ...........: "
	AutoGrLog( STR0039 + DToC( Date() ) + ' / ' + Time()     ) // "Data/Hora ..........: "
	AutoGrLog( STR0040 + GetEnvServer()                      ) // "Environment ........: "
	AutoGrLog( STR0041 + GetSrvProfString( 'RootPath' , '' ) ) // "RootPath ...........: "
	AutoGrLog( STR0042 + GetSrvProfString( 'StartPath', '' ) ) // "StartPath ..........: "
	AutoGrLog( STR0043 + GetVersao( .T. )                    ) // "Versao .............: "
	AutoGrLog( STR0044 + GetModuleFileName()                 ) // "Modulo .............: "
	AutoGrLog( STR0045 + __cUserID + ' ' +  cUserName        ) // "Usuario Microsiga ..: "
	AutoGrLog( STR0046 + GetComputerName()                   ) // "Computer Name ......: "
	AutoGrLog( STR0047 + ProcName( 1 ) + ' / ' + FunName()   ) // "ProcName(1)/FunName : "
	AutoGrLog( STR0044 + AllTrim( Str( nModulo ) ) + ' ' + cModulo ) // "Modulo .............: "
	AutoGrLog( Replicate( '-', 78 ) )
	AutoGrLog( ' ' )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JurMkDir
Rotina para criacao de diretorios/subdiretorios.
Uso Geral.

@param  cDir        Diretorio a ser Criado
@param  lShowMsg    Apresenta mensagem mensagem de erro, caso não seja possível a criação da pasta
@param  lAcreBarra  Acrescenta "\" ou "\\" no inicio do diretório?

@sample JurMkDir( '\integracao\logs\tabelas' )

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurMkDir( cDir, lShowMsg, lAcreBarra )
	Local cAux      := ''
	Local cDirCriar := ''
	Local cDirTrb   := ''
	Local lRet      := .T.
	Local nPosBarra := 0

	Default cDir       := ""
	Default lShowMsg   := .T.
	Default lAcreBarra := .T.

	cAux    := AllTrim( cDir )
	cDirTrb := cAux + IIf( SubStr( cAux, Len( cAux ), 1 ) <> '\', '\', '' )

	If lAcreBarra
		cDirCriar := IIf( '\\' $ cDirTrb, '\\', '\' )
	EndIf

	While Len( cDirTrb ) > 0
		nPosBarra := At( '\', cDirTrb )

		If nPosBarra >= 2
			cDirCriar += SubStr( cDirTrb, 1, nPosBarra )
			If MakeDir( cDirCriar ) <> 0 .AND. MakeDir( cDirCriar ) <> 5
				lRet := .F.
				If lShowMsg
					JurMsgErro( STR0111 + cDirCriar ) //'Erro ao criar pasta '
				EndIf
				Exit
			EndIf
		EndIf

		cDirTrb   := SubStr( cDirTrb, nPosBarra + 1 )
	EndDo

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurRmvDir
Rotina para remover de diretorios e subdiretorios.
Uso Geral.

@param 	cDir	    Diretorio/subdiretorio a ser criado
@param 	lCompleto   Se remove ou não todos os niveis do Diretorio/subdiretorio informado
@param 	lElimArq	Se remove ou não as pastas dos Diretorio/subdiretorio

@sample
	If !JurRmvDir( '\temp\log' )
	JurMsgErro( 'Diretorio nao pode ser removido' )
	EndIf

@author Ernani Forastieri
@since 01/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurRmvDir( cDir, lCompleto, lElimArq )
	Local aLimpar   := {}
	Local cDirElim  := '\'
	Local cDirTrb   := cDir + IIf( SubStr( cDir, Len( cDir ), 1 ) <> '\', '\', '' )
	Local lRet      := .T.
	Local nI        := 0
	Local nPosBarra := 0

	ParamType 0 Var cDir       As Character
	ParamType 1 Var lCompleto  As Logical Optional Default .F.
	ParamType 2 Var lElimArq   As Logical Optional Default .F.

	cDir      := JurBarFim( cDir )

	If lCompleto

		// Elimina toda a arvore do diretorio
		nPosBarra := RAt( '\', cDirTrb )

		If nPosBarra > 2
			cDirElim := SubStr( cDirTrb, 1, nPosBarra )

			If lIsDir( cDirElim )
				// Elimina arquivos do diretorio
				If lElimArq
					aLimpar := Directory( cDirElim + '*.*', 'D' )
					aSort( aLimpar,,, { | z, w | w[NPOSDIRATRIB]+w[NPOSDIRNOME] < z[NPOSDIRATRIB]+z[NPOSDIRNOME] } )

					For nI := 1 To Len( aLimpar )
						If SubStr(aLimpar[nI][NPOSDIRNOME], 1, 1 ) <> '.'

							If aLimpar[nI][NPOSDIRATRIB] == 'D'
								JurRmvDir( AllTrim( cDirElim + aLimpar[nI][NPOSDIRNOME] ), lCompleto, lElimArq )
							EndIf

							FErase( cDirElim + aLimpar[nI][NPOSDIRNOME] )

						EndIf
					Next
				EndIf

				If !( lRet := DirRemove( cDirElim ) )
				EndIf

			EndIf

		EndIf

	Else

		// Elimina so o nivel mais baixo do diretorio
		If lIsDir( cDir )
			// Elimina arquivos do diretorio
			If lElimArq
				aLimpar := Directory( cDir + '*.*' )
				aEval( aLimpar, { |y, x| FErase( cDir + aLimpar[x][NPOSDIRNOME] ) } )
			EndIf

			lRet := DirRemove( cDir )
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTrocaExt
Devolve o nome de um arquivo com a extensao trocada
Uso Geral.

@param 	cNomeArq    Nome do arquivo
@param 	cNovaExt    Nova extensao, sem o ponto

@sample

cNomeArq  := "\system\teste.log"
cNomeArq  := JurTrocaExt( cNomeArq, "TXT" )
// Retorna "\system\teste.txt"

@author Ernani Forastieri
@since 01/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurTrocaExt( cNomeArq, cNovaExt )
	Local nPos := 0

	ParamType 0 Var cNomeArq       As Character
	ParamType 1 Var cNovaExt       As Character


	If cNomeArq <> NIL .AND. cNovaExt <> NIL
		cNomeArq := AllTrim( cNomeArq )

		If ( nPos := RAt( '.', cNomeArq ) ) > 0
			cNomeArq := Left( cNomeArq, nPos - 1 ) + cNovaExt
		Else
			cNomeArq += ( '.' + cNovaExt )
		EndIf
	EndIf

Return cNomeArq

//-------------------------------------------------------------------
/*/{Protheus.doc} JurDUteis
Calcula Quantidade de Dias Uteis entre duas datas
Uso Geral.

@param 	dData1    Primeira Data
@param 	dData2    Segunda Data

@sample

nQtdDias := JurDUteis( CToD( '01/10/09' ), CToD( '10/10/09') )
// Retorna 7

@author Ernani Forastieri
@since 01/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurDUteis( dData1, dData2 )
	Local nRet := 0
	Local nI   := 0
	Local dAux := CToD( '  /  /  ' )

	ParamType 0 Var dData1       As Date Optional Default Date()
	ParamType 1 Var dData2       As Date Optional Default Date()

	If dData2 < dData1
		dAux   := dData1
		dData1 := dData2
		dData2 := dAux
	EndIf

	For nI := 1 To ( dData2 - dData1 ) + 1
		nRet += IIf( dData1 == DataValida( dData1 ), 1, 0 )
		dData1++
	Next

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIsDUtil
Verifica de o data é um dia util
Uso Geral.

@param 	dData     Data de referencia

@sample
	If JurIsDUtil( CToD( '01/10/09' ) )
	...
	EndIf

@author Ernani Forastieri
@since 01/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurIsDUtil( dData )
	ParamType 0 Var dData       As Date Optional Default Date()
Return ( dData == DataValida( dData ) )

//-------------------------------------------------------------------
/*/{Protheus.doc} JurUsers
Retorna um Array como os usarios do sistema.
Uso Geral.

@param 	Nenhum

@Return aRet     	( A ) Array com as informacoes na estrutura
[1] Codigo do Usuario
[2] Nome do Usuario
[3] E-mail
[4] Departamento

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurUsers()
	Local aAux := AllUsers()
	Local aRet := {}
	Local nI   := 0

	For nI := 1 To Len( aAux )
		If nI == 1
			aAdd( aRet, { aAux[nI][1], aAux[nI][2], aAux[nI][4], aAux[nI][2] , ''           } )
		Else
			aAdd( aRet, { aAux[nI][1], aAux[nI][2], aAux[nI][4], aAux[nI][14], aAux[nI][12] } )
		EndIf
	Next

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurMoeda
Verifica se a moeda existe no SX3.
Uso Geral.

@param 	nMoeda		Numeroda Moeda

@Return lRet	 	.T./.F. A moeda esta valida ou nao

@sample
JurMoeda( M->NQ1_MOEDA ) // Conteudo 1 .. 99

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurMoeda( nMoeda )
	Local aArea    := GetArea()
	Local aAreaSX3 := SX3->( GetArea() )
	Local cMoeda   := ''
	Local lRet     := .T.

	ParamType 0 Var nMoeda     As Numeric

	cMoeda := AllTrim( Str( nMoeda ) )

	SX3->( dbSetOrder( 2 ) )
	If !SX3->( dbSeek( PadR( 'M2_MOEDA' + cMoeda, 10 ) ) )
		Help ( ' ', 1, 'SEMMOEDA' )
		lRet := .F.
	EndIf

	RestArea( aAreaSX3 )
	RestArea( aArea    )

Return lRet

Function JurMoed( nMoeda )
Return JurMoeda( nMoeda )

//-------------------------------------------------------------------
/*/{Protheus.doc} JurMsgErro
Exibe Mensagem de erro.
Uso Geral.

@param 	cMsg		Mensagem de erro
@param 	cRotina		Nome da rotina a ser exibida na janela
@param  cSolucao   Mensagem de solução

@Return lRet	 	 .F. Sempre retorna .F. indicando um erro para poder
usar em gatilhos e validaçÃµes onde exibira a mensagem
e retornara .F.

@sample
lRetorno := IIf(nTotal > 0 , .T.,  JurMsgErro( 'Total esta zerado', 'MinhaRotina' )

@see JurMsgOK

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurMsgErro( cMsg, cRotina, cSolucao, lDetail )
	Local oModel  := FWModelActive()
	Local aErro   := {}
	Local cAux    := ""
	Local lMsgErr := .F.
	Local lCpoErr := .F.

	ParamType 0 Var cMsg      As Character Optional Default STR0004 // "Erro ..."
	ParamType 1 Var cRotina   As Character Optional Default ProcName( 1 )
	ParamType 2 Var cSolucao  As Character Optional Default ""
	ParamType 4 Var lDetail   As Logical   Optional Default .T.

	If oModel <> NIL .And. lDetail
		aErro := oModel:GetErrorMessage()
		lMsgErr := JChkArray(aErro, 6)
		lCpoErr := JChkArray(aErro, 4)

		If lMsgErr .Or. lCpoErr
			cAux := CRLF + "--------------------" + CRLF + STR0105 + CRLF //"Detalhes técnicos:"
			If lMsgErr
				cAux += aErro[6] + CRLF //[6] = mensagem do erro
			EndIf
			If lCpoErr
				cAux += I18N(STR0149, {aErro[4]} ) + CRLF // "Campo: #1"
			EndIf
		EndIf

		If Empty(cSolucao) .And. JChkArray(aErro, 7)
			cSolucao := aErro[7] //[7] = Solução
		EndIf
		cMsg += cAux
	EndIf

	Help("", 1, "HELP", cRotina, cMsg, 1,,,,,,, {cSolucao}) // Alterado pois algumas vezes estava aparecendo a mensagem em branco.
	JurConOut("#1 - " + cMsg, {cRotina})

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} JurMsgOk
Exibe Mensagem de Ok.
Uso Geral.

@param 	cMsg		Mensagem de erro
@param 	cRotina		Nome da rotina a ser exibida na janela

@Return lRet	 	 .T. Sempre retorna .T. para poder
usar em gatilhos e validaçÃµes, onde exibira a mensagem e retornara .T.

@sample
lRetorno := IIf(nTotal > 0 , JurMsgOk( 'Total calculado', 'MinhaRotina' ), .F. )

@see JurMsgErro

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurMsgOk( cMsg, cRotina )

	ParamType 0 Var cMsg       As Character Optional Default STR0005 // "Ok ..."
	ParamType 0 Var cRotina    As Character Optional Default ProcName( 1 )

	Help( ,, 'HELP', cRotina, cMsg, 1, 0)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JurEnvMail
Rotina Generica de Envio de E-mail.
Uso Geral.

@param 	cDe	   		Remetente
@param 	cPara		Destinatario, quando mais de um separar por ";"
@param 	cCc			Destinatario de Copia, quando mais de um separar por ";"
@param 	cAssunto	Assunto
@param 	cAnexo		Anexo a ser enviado, devem estar abaixo do RootPath, com caminho completo
e quando mais de um separados por ";"
@param 	cMsg		Mensagem do e-mail no formato texto ou html

@sample
JurEnvMail( "MeuNome", "destinatario@totvs.com.br",, "Teste de Envio",, "<b>TESTE DE ENVIO<b>" )

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurEnvMail( cDe, cPara, cCc, cCCO, cAssunto, cAnexo, cMsg, cServer, cEmail, cPass, lAuth, cContAuth, cPswAuth, lSSL, lTLS)
	Local lResulConn := .T.
	Local lResulsend := .T.
	Local cError     := ''
	Local lRet       := .T.
	Local nA         := 0
	Local cFrom      := ''
	Local aPEntrada  := nil
	Local bError     := nil

	ParamType 0  Var cDe       As Character Optional Default NIL
	ParamType 1  Var cPara     As Character
	ParamType 2  Var cCc       As Character Optional Default NIL
	ParamType 3  Var cCCO      As Character Optional Default ""
	ParamType 4  Var cAssunto  As Character
	ParamType 5  Var cAnexo    As Character Optional Default NIL
	ParamType 6  Var cMsg      As Character Optional Default ""
	ParamType 7  Var cServer   As Character Optional Default Trim( SuperGetMV( 'MV_RELSERV',, '' ) )  // smtp.dominio.com.br ou 200.181.100.51
	ParamType 8  Var cEmail    As Character Optional Default Trim( SuperGetMV( 'MV_RELACNT',, '' ) )  // fulano@dominio.com.br
	ParamType 9  Var cPass     As Character Optional Default Trim( SuperGetMV( 'MV_RELPSW' ,, '' ) )  // senha
	ParamType 9  Var lAuth     As Logical   Optional Default       SuperGetMV( 'MV_RELAUTH',, .F.  )  // Tem Autenticacao ?
	ParamType 10 Var cContAuth As Character Optional Default Trim( SuperGetMV( 'MV_RELACNT',, '' ) )  // Conta Autenticacao
	ParamType 11 Var cPswAuth  As Character Optional Default Trim( SuperGetMV( 'MV_RELAPSW',, '' ) )  // Senha Autenticacao
	ParamType 12 Var lSSL      As Logical   Optional Default       SuperGetMV( 'MV_RELSSL',, .F.   )  // Utiliza protocolo SSL
	ParamType 13 Var lTLS      As Logical   Optional Default       SuperGetMV( 'MV_RELTLS',, .F.   )  // Utiliza protocolo TLS

	If Empty( cServer ) .AND. Empty( cEmail ) .AND. Empty( cPass )
		lRet := .F.
		cMsg := STR0006 // "NÃ£o foram definidos um ou mais parÃ¢metros de configuraÃ§Ã£o para envio de e-mail pelo Protheus."

		ConOut( JurTimeStamp( 2 ) + ' ' + cMsg )

		If !IsBlind()
			JurMsgErro( cMsg, cAssunto )
		EndIf

		Return lRet
	EndIf

	cDe      := IIf( cDe == NIL, SuperGetMV( 'MV_RELFROM',, STR0007 + GetVersao() ), AllTrim( cDe ) ) // "Microsiga Protheus "
	cDe      := IIf( Empty( cDe ), cEmail, cDe )
	cPara    := AllTrim( cPara )
	cCC      := AllTrim( cCC )
	cAssunto := IIf( Empty( cAssunto), STR0008, AllTrim( cAssunto ) ) // "<sem assunto>"
	cAnexo   := AllTrim( cAnexo )
	cAnexo   := IIf(  Left( cAnexo, 1 ) == ';', SubStr( cAnexo, 2 )                  , cAnexo )
	cAnexo   := IIf( Right( cAnexo, 1 ) == ';', SubStr( cAnexo, 1, Len( cAnexo) - 1 ), cAnexo )

	If lAuth
		If Empty( cContAuth ) .OR. Empty( cPswAuth )
			lRet := .F.
			cMsg := STR0009 // "NÃ£o foram definidos conta ou senha de autenticaÃ§Ã£o para envio de e-mail pelo Protheus."

			ConOut( JurTimeStamp( 2 ) + ' ' + cMsg )

			If !IsBlind()
				JurMsgErro( cMsg, cAssunto )
			EndIf

			Return lRet
		EndIf
	EndIf

	lResulConn := MailSmtpOn( cServer, cEmail, cPass,, lTLS, lSSL )

	If !lResulConn
		lRet := .F.

		GET MAIL ERROR cError
		cMsg := STR0010 + ' (' + cError + ' )' // "Falha na conexÃ£o para envio de e-mail"
		ConOut( JurTimeStamp( 2 ) + ' ' +  cMsg )

		If !IsBlind()
			JurMsgErro( cMsg, cAssunto )
		EndIf

		Return lRet
	EndIf

	If lAuth
		//
		// Primeiro tenta fazer a Autenticacao de E-mail utilizando o e-mail completo
		//
		If !( lRet := MailAuth( cContAuth, cPswAuth )   )
			//
			// Se nao conseguiu fazer a Autenticacao usando o E-mail completo,
			// tenta fazer a autenticacao usando apenas o nome de usuario do E-mail
			//
			If !lRet
				nA        := At( '@', cContAuth )
				cContAuth := IIf( nA > 0, SubStr( cContAuth, 1, nA - 1 ), cContAuth )

				If !( lRet  := MailAuth( cContAuth, cPswAuth ) )
					lRet := .F.
					cMsg := STR0011 + ' ( ' + cContAuth + ' )' // "NÃ£o conseguiu autenticar conta de e-mail"

					ConOut( JurTimeStamp( 2 ) + ' ' + cMsg )

					If !IsBlind()
						ApMsgAlert( cMsg )
					EndIf

					//	DISCONNECT SMTP SERVER

					Return lRet
				EndIf

			EndIf
		EndIf
	EndIf

	cFrom := cDe
	If AllTrim( Lower( cDe ) ) <> AllTrim( Lower( cEmail ) )
		cFrom := AllTrim( cDe ) + ' <' + AllTrim( cEmail ) + '>'
	EndIf

	If      Empty( cCc ) .AND.  Empty( cAnexo ) .And. Empty( cCCO )
		SEND MAIL FROM cFrom TO cPara SUBJECT cAssunto BODY cMsg RESULT lResulSend

	ElseIf  Empty( cCc ) .AND. !Empty( cAnexo ) .And. Empty( cCCO )
		SEND MAIL FROM cFrom TO cPara SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend

	ElseIf  Empty( cCc ) .AND. !Empty( cAnexo ) .And. !Empty( cCCO )
		SEND MAIL FROM cFrom TO cPara BCC cCCO SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend

	ElseIf !Empty( cCc ) .AND.  Empty( cAnexo ) .And. Empty( cCCO )
		SEND MAIL FROM cFrom TO cPara CC cCc SUBJECT cAssunto BODY cMsg RESULT lResulSend

	ElseIf !Empty( cCc ) .AND.  Empty( cAnexo ) .And. !Empty( cCCO )
		SEND MAIL FROM cFrom TO cPara CC cCc BCC cCCO SUBJECT cAssunto BODY cMsg RESULT lResulSend

	Else
		SEND MAIL FROM cFrom TO cPara CC cCc BCC cCCO SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend

	EndIf

	If !lResulSend
		GET MAIL ERROR cError
		lRet := .F.
		cMsg := STR0012 + ' ( ' + cError + ' )' // "Falha no envio do e-mail "

		ConOut( JurTimeStamp( 2 ) + ' ' + cMsg )

		If !IsBlind()
			JurMsgErro( cMsg, cAssunto )
		EndIf

	Else
		ConOut( JurTimeStamp( 2 ))
		ConOut( STR0013 + '[' + cPara    + ']' ) // "Enviado e-mail Para: "
		ConOut( STR0014 + '[' + cAssunto + ']' ) // "            Assunto: "

	EndIf

	DISCONNECT SMTP SERVER

	If Existblock( 'JENVMAIL' )
	 	bError := ErrorBlock( {|e| JurMsgErro(e:description) } )
		 
		aPEntrada := {}
		aADD(aPEntrada, cMsg       ) // 01
		aADD(aPEntrada, lResulConn ) // 02
		aADD(aPEntrada, lResulSend ) // 03
		aADD(aPEntrada, cDe        ) // 04
		aADD(aPEntrada, cPara      ) // 05
		aADD(aPEntrada, cCc        ) // 06
		aADD(aPEntrada, cCCO       ) // 07
		aADD(aPEntrada, cAssunto   ) // 08
		aADD(aPEntrada, cAnexo     ) // 09
		aADD(aPEntrada, cMsg       ) // 10
		aADD(aPEntrada, cServer    ) // 11
		aADD(aPEntrada, cEmail     ) // 12
		aADD(aPEntrada, cPass      ) // 13
		aADD(aPEntrada, lAuth      ) // 14
		aADD(aPEntrada, cContAuth  ) // 15
		aADD(aPEntrada, cPswAuth   ) // 16
		aADD(aPEntrada, lSSL       ) // 17
		aADD(aPEntrada, lTLS       ) // 18
		
		BEGIN SEQUENCE
			ExecBlock( 'JENVMAIL', .F., .F., aPEntrada )
		END SEQUENCE

		aSize(aPEntrada,0)
		aPEntrada := {}
		
		ErrorBlock(bError)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurDtExten
Rotina que retorna uma data por extenso.
Uso Geral.

@param 	dData		Data de referencia
@param 	lMunicip	Inclui o nome do Municipio ou nao.
@param 	cIdioma		Idioma da Data

@return	cRet		Data por extenso

@sample
//
// Ex. 13/07/05  -> 13 de maio de 2009  ou
//                  Sao Paulo, 13 de maio de 2009
//
JurDtExten( Date(), .T. ) // Sao Paulo, 13 de maio de 2009
JurDtExten( Date(), .F. ) // 13 de maio de 2009
JurDtExten( Date(), .F., 'ENGLISH' ) // May 13th of 2009  ==> cIdioma 'PORTUGUESE', 'ENGLISH', 'SPANISH'

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurDtExten( dData, lMunicip, cIdioma )
	Local cRet := ''
	Local cAux := ''
	Local nDia := 0

	ParamType 0 Var dData      As Date      Optional Default dDataBase
	ParamType 1 Var lMunicip   As Logical   Optional Default .F.
	ParamType 2 Var cIdioma    As Character Optional Default __Language

	cIdioma := Upper( cIdioma )

	If cIdioma == 'PORTUGUESE'
		cRet := IIf( lMunicip, Capital( AllTrim( SM0->M0_CIDENT ) ) + ', ' , '' ) + ;
			AllTrim( Str( Day( dData ) ,2) + ' de ' + ;
			Capital( AllTrim( MesExtenso( Month( dData ) ) ) ) +' de '+ ;
			Str( Year( dData) , 4 ) )

	ElseIf cIdioma == 'ENGLISH'
		nDia := Day( dData )
		If nDia >= 4 .AND. nDia <= 20
			cAux := "th"
		Else
			cAux := IIf( Right( Str( nDia), 1 ) =="1", "st",;
				IIf( Right( Str( nDia ), 1 ) == "2", "nd",;
				IIf( Right( Str( nDia ), 1 ) == "3", "rd",;
				"th" ) ) )
		EndIf

		cRet := AllTrim( Capital ( MesExtenso( Month( dData ) ) ) ) +', '+ ;
			AllTrim( Str( nDia, 2 ) + cAux + ' of ' + ;
			Str( Year( dData ), 4 ) ) + ;
			IIf( lMunicip, ' ' + Capital( AllTrim( SM0->M0_CIDENT ) ), '' )

	ElseIf cIdioma == 'SPANISH'
		cRet := IIf( lMunicip, Capital( AllTrim( SM0->M0_CIDENT ) ) + ', ' , '' ) + ;
			AllTrim( Str( Day( dData ), 2 ) + ' de ' + ;
			Capital( AllTrim( MesExtenso( Month( dData ) ) ) ) +' de '+ ;
			Str( Year( dData ), 4 ) )

	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTimeStamp
Funcao para retornar o time stamp.
Uso Geral.

@param 	nTipo		Tipo do time stamp, Onde
1 =	aaaammddhhmmss
2 = [FUNNAME/ROTINA dd/mm hh:mm]
3 = [dd/mm hh:mm]

@return	cRet		String com o time stamp

@sample
//
// Ex. dia  01/06/2009
//     hora 12:10:05
//
Alert( JurTimeStamp( 1 ) // Retorna 20090601121005
Alert( JurTimeStamp( 2 ) // Retorna [FUNNAME/ROTINA 01/06 12:05] ]
Alert( JurTimeStamp( 3 ) // Retorna [01/06 12:05]

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurTimeStamp( nTipo )
	Local cRet    := ''
	Local cRotina := ''

	ParamType 0 Var nTipo      As Numeric Optional Default 1

	If     nTipo == 1
		cRet    := DToS( Date() )+ StrTran( Time(), ':', '' )

	ElseIf nTipo == 2
		cRotina := ProcName( 1 )
		cRotina := IIf( SubStr( cRotina, 1, 2 ) $ 'u_/U_', SubStr( cRotina, 3 ), cRotina )
		cRet    := '[' + FunName() +'/'+ cRotina + ' ' + SubStr( DtoC( Date() ), 1, 5 ) + ' ' + SubStr( Time(), 1, 5 ) + ']'

	ElseIf nTipo == 3
		cRet    := '[' + SubStr( DtoC( Date() ), 1, 5 ) + ' ' + SubStr( Time(), 1, 5 ) + ']'

	EndIf

Return cRet

/*/ {Protheus.doc} JurLmpCpo( cCpoLmp,lEspec )
	Função para retirar acentos e caracteres especiais da string
	Uso Geral

	@param cCpoLmp String para linpar
	@param lEspec define se serão retirados os caracteres especiais ou não
	@param lPont - Define se irá tratar pontuação

	@return	cCpoLmp String Tratada

/*/
Function JurLmpCpo( cCpoLmp, lEspec, lPont )
	Local cAcentos   := "çÇ€áéíóúÁÉÍÓÚâêîôûÂÊÎÔÛàéíóúÁÉÍÓÚäëïöüÄËÏÖÜãõÃÕŽÀÅ… „¦åÈˆ‚èÌ¡ÒÖ“”¢§ðÙ£ùÑñþ÷Ý°ºª¬	"
	Local cAcSubst   := "cCcaeiouAEIOUaeiouAEIOUaeiouAEIOUaeiouAEIOUaoAOAAAA aaaaaEEeeeIiiOOoooooouuNooac "
	Local cCaraPont  := "/\.,;:!()-+='[]{}~<>|?¨`"
	Local cCaraEspec := "@#$%&*"
	Local nI         := 0
	Local nPos       := 0

	Default lEspec   := .T.
	Default lPont    := .T.

	cCpoLmp := AllTrim( cCpoLmp )

// Troca Acentos
	For nI := 1 To Len( cCpoLmp )
		If ( nPos := At( SubStr( cCpoLmp, nI, 1 ), cAcentos ) ) > 0
			cCpoLmp := SubStr( cCpoLmp, 1, nI - 1 ) + SubStr( cAcSubst, nPos, 1 ) +  SubStr( cCpoLmp, nI + 1 )
		EndIf
	Next

	If lEspec

		// Tira Caracteres Especiais
		For nI := 1 To Len( cCpoLmp )
			If ( nPos := At( SubStr( cCpoLmp, nI, 1 ), cCaraEspec ) ) > 0
				cCpoLmp := SubStr( cCpoLmp, 1, nI - 1 ) + '#' + SubStr( cCpoLmp, nI + 1 )
			EndIf
		Next

	EndIf
	
	If lPont
	// Tira Caracteres de pontuacao
		For nI := 1 To Len( cCpoLmp )
			If ( nPos := At( SubStr( cCpoLmp, nI, 1 ), cCaraPont ) ) > 0
				cCpoLmp := SubStr( cCpoLmp, 1, nI - 1 ) + '#' + SubStr( cCpoLmp, nI + 1 )
			EndIf
		Next
	EndIf

Return cCpoLmp

/*
ÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœ
Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±
Â±Â±Ã‰Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã‘Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã‹Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã‘Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã‹Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã‘Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Â»Â±Â±
Â±Â±ÂºPrograma  Â³JurBarFim ÂºAutor  Â³Ernani Forastieri   Âº Data Â³  26/05/06   ÂºÂ±Â±
Â±Â±ÃŒÃ¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã˜Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿ÃŠÃ¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿ÃŠÃ¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Â¹Â±Â±
Â±Â±ÂºDescricao Â³ Funcao para colocar a barra final numa string de diretorio ÂºÂ±Â±
Â±Â±Âº          Â³ local ou FTP                                               ÂºÂ±Â±
Â±Â±ÃŒÃ¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã˜Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Â¹Â±Â±
Â±Â±ÂºUso       Â³ Generico                                                   ÂºÂ±Â±
Â±Â±ÃˆÃ¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Â¼Â±Â±
Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±
ÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸ
*/
Function JurBarFim( cDir, lNormal )
	Local cRet := ''
	Local cBarraFinal := ''

	lNormal     := IIf( lNormal  == NIL, .F., lNormal )
	cBarraFinal := IIf( lNormal, '/', '\' )

	cRet := Alltrim( cDir )
	cRet += IIf( SubStr( cRet, Len( cRet ), 1 ) <> cBarraFinal, cBarraFinal, '' )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTxt2Arr
Gera Array conforme mensagem quebrando por linha.
Uso Geral.

@param 	cString		String a ser transformada em array
@param 	nTamanho	Tamanho desejado da linha
@param 	lQuebra		Se respeita ou nao as quebras de linha chr(13)+chr(10)

@return	aRet		Array com as linhas do texto

@sample
Local cTexto: 'Minha terra tem palmeiras onde canta o sabia'

VarInfo( 'Texto ', JurTxt2Arr( cTexto, 15 ) )

// Retorna
//Texto  -> ARRAY (    4) [...]
//     Texto [1] -> C (   12) [Minha terra ]
//     Texto [2] -> C (   14) [tem palmeiras ]
//     Texto [3] -> C (   13) [onde canta o ]
//     Texto [4] -> C (    5) [sabia]

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurTxt2Arr( cString, nTamanho, lQuebra )
	Local lContinua := .T.
	Local aTexto    := {}
	Local aAuxTXT   := {}
	Local cTexto    := ''
	Local nBranco   := ' '
	Local cLinha    := ''
	Local xQuebra   := CRLF
	Local nQuebra   := 0
	Local nI        := 0

	ParamType 0 Var cString    As Character
	ParamType 1 Var nTamanho   As Numeric    Optional Default 40
	ParamType 2 Var lQuebra    As Logical    Optional Default .T.

	cTexto := AllTrim( cString )

	If lQuebra .AND. At( xQuebra, cTexto ) > 0
		nQuebra := At( xQuebra, cTexto )

		While nQuebra > 0
			cLinha  := SubStr( cTexto, 1, nQuebra-1 )
			aAdd( aAuxTXT, cLinha )
			cTexto  := SubStr( cTexto, nQuebra + 2 )
			nQuebra := At( xQuebra, cTexto )
		EndDo

		If Len( cTexto ) > 0
			aAdd( aAuxTXT, cTexto )
			cTexto := Stuff( cTexto, 1, nTamanho, '' )
		EndIf

		cLinha := ''

	Else
		aAdd( aAuxTXT, cTexto )

	EndIf

	For nI := 1 To Len( aAuxTXT )

		cTexto    := aAuxTXT[nI]
		lContinua := .T.
		cLinha    := ''

		While lContinua
			nBranco := At( " ", cTexto )
			If nBranco <= nTamanho
				If ( Len( cLinha ) + nBranco ) <= nTamanho
					If nBranco > 0
						cLinha += SubStr( cTexto, 1, nBranco )
						cTexto := Stuff( cTexto, 1, nBranco, '' )
					Else
						If Len( cLinha ) > 0
							If Len( cLinha + cTexto ) >= nTamanho
								aAdd( aTexto, cLinha )
								cLinha := ''
							EndIf
						EndIf
						cLinha += SubStr( cTexto, 1, nTamanho )
						cTexto := Stuff( cTexto, 1, nTamanho, '' )
						aAdd( aTexto, cLinha )
						cLinha := ''
					EndIf
				Else
					aAdd( aTexto, cLinha )
					cLinha := ''
				EndIf

			Else

				If nBranco > nTamanho .OR. ( Len( cLinha ) + nbranco ) > nTamanho
					aAdd( aTexto, cLinha )
					cLinha := ''
					cLinha += SubStr( cTexto, 1, nTamanho )
					aAdd( aTexto, cLinha )
					cLinha := ''
					cTexto := Stuff( cTexto, 1, nTamanho, '' )

				Else
					cLinha += SubStr( cTexto, 1, nTamanho )

				EndIf

				If Len( cLinha ) > 0
					aAdd( aTexto, cLinha )
					cLinha := ''
					cTexto := Stuff( cTexto, 1, nTamanho, '' )
				EndIf

			EndIf

			If Len( cTexto ) == 0
				lContinua := .F.
			EndIf

		EndDo

		If Len( cLinha ) > 0
			aAdd( aTexto, cLinha )
			cLinha := ''
			cTexto := Stuff( cTexto, 1, nTamanho, '' )
		EndIf

	Next

	If Len( aTexto ) == 0
		aTexto := { ' ' }
	EndIf

Return aTexto

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSetRules
Cria os AddRules do Model conforme definição.
Uso Geral.

@param 	oModel    	Modelo de Dados
@param 	cIdSource 	Identificador do modelo de origem
@param 	cIdTarget 	Identificador do campo do modelo destino
@param 	cTabSource  Tabela de origem
@param 	cTabTarget	Tabela de destino
@param 	cFunction 	Nome da Funcao referente as regras. Se nao for especificado pega as definiçoes cadastradas com o
nome da funcao em branco para a tabela.

@sample
oModel:= MPFormModel():New( "ROTINA" )
oModel:AddFields( "MASTER", NIL, oStruct  )
oModel:SetDescription( "Modelo de Dados"  )
JurSetRules( oModel, "MASTER", , "SA1",, "ROTINA" )

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSetRules( oModel, cIdSource, cIdTarget, cTabSource, cTabTarget, cFunction )
	Local aRules := {}

	ParamType 0 Var oModel     As Object     Optional 
	ParamType 1 Var cIdSource  As Character
	ParamType 2 Var cIdTarget  As Character  Optional Default cIdSource
	ParamType 3 Var cTabSource As Character  Optional Default Alias()
	ParamType 4 Var cTabTarget As Character  Optional Default cTabSource
	ParamType 5 Var cFunction  As Character  Optional Default Space(10)

	If !JModRst()
		JurLoadRul( cTabSource, cFunction )

		aRules := JurGetRules( cTabSource, cTabTarget, cFunction, .T. )
		aEval( aRules, { |aX| oModel:AddRules( AllTrim( cIdSource ), AllTrim( aX[2] ), AllTrim( cIdTarget ), AllTrim( aX[1] ), Val( aX[3] ) ) } )
	Endif

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGetRules
Cria Arrays com os campos envolvidos nos AddRules do Model de tabelas conforme definição.
Uso Geral.

@param 	cTabOrigem  Tabela de origem
@param 	cTabDestino	Tabela de destino
@param 	cFunction 	Nome da Funcao referente as regras. Se nao for especificado pega as definiçoes cadastradas com o
nome da funcao em branco para a tabela.

@return	aRet		Array com os campos e tipos para uso no AddRules

@sample
JurGetRules( oModel, "MASTER", , "SA1",, "ROTINA" ))

// Retorna Array com
//     [1] -> C (   10) Campo de Origem
//     [2] -> C (   10) Campo de Destino
//     [3] -> C (    3) Tipo de Regra


@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurGetRules( cTabOrigem, cTabDestino, cFunction, lSoAtivas )
	Local aArea    := GetArea()
	Local aAreaNTZ := NTZ->( GetArea() )
	Local aRet     := {}
	Local cFilNTZ  := ''
	Local cQuery   := ''
	Local cTrab    := ''

	ParamType 0 Var cTabOrigem  As Character  Optional Default Alias()
	ParamType 1 Var cTabDestino As Character  Optional Default cTabOrigem
	ParamType 2 Var cFunction   As Character  Optional Default Space(10)
	ParamType 3 Var lSoAtivas   As Logical    Optional Default .T.

	dbSelectArea( 'NTZ' )

	cFunction   := PadR( cFunction  , 10 )
	cTabOrigem  := PadR( cTabOrigem ,  3 )
	cTabDestino := PadR( cTabDestino,  3 )

	cFilNTZ     := xFilial( 'NTZ' )

	cQuery := "SELECT NTZ_ORIGEM, NTZ_DESTIN, NTZ_TIPO, NTZ_CONDIC "
	cQuery += "  FROM " + RetSqlName( "NTZ" )
	cQuery += " WHERE NTZ_FILIAL = '" + xFilial( "NTZ" ) + "' "
	cQuery += "   AND NTZ_FUNCAO = '" + cFunction   + "' "
	cQuery += "   AND NTZ_TABORI = '" + cTabOrigem  + "' "
	cQuery += "   AND NTZ_TABDES = '" + cTabDestino + "' "
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY NTZ_ORIGEM, NTZ_DESTIN, NTZ_TIPO"

	cTrab  := GetNextAlias()

	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cTrab, .T., .F. )

	While !(cTrab)->( EOF() )

		If lSoAtivas .AND. !Empty( (cTrab)->NTZ_CONDIC )
			If !( &( (cTrab)->NTZ_CONDIC ) )
				(cTrab)->( dbSkip() )
				Loop
			EndIf
		EndIf

		aAdd( aRet, { (cTrab)->NTZ_ORIGEM, (cTrab)->NTZ_DESTIN, (cTrab)->NTZ_TIPO } )

		(cTrab)->( dbSkip() )
	EndDo

	(cTrab)->( dbCloseArea() )

	RestArea( aAreaNTZ )
	RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSetLeg
Cria os legendas do Browse conforme definição.
Uso Geral.

@param  oBrowse      Objeto Browse
@param  cTable       Tabela de origem
@param  cFunction    Nome da Funcao referente as legendas. Se nao for especificado pega as definiçoes cadastradas com o
					 nome da funcao em branco para a tabela.
@Param  aExcetoSeq   Array com a sequencias que ano serão usadas para montar a legenda

@sample
oBrowse := FWMBrowse():New()
oBrowse:SetAlias( "NUZ" )
JurSetLeg( oBrowse, "NUZ"  )
oBrowse:Activate()

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSetLeg( oBrowse, cTable, cFunction, aExcetoSeq )
	Local aTable := {}

	Default  oBrowse    := Nil
	Default  cTable     := Iif(!Empty(oBrowse), oBrowse:cAlias, '')
	Default  cFunction  := Space(10)
	Default  aExcetoSeq := {}

	JurLoadLeg( cTable, cFunction )

	aTable := JurGetLeg( cTable, cFunction, aExcetoSeq )
	aEval( aTable, { |aX| oBrowse:AddLegend( AllTrim( aX[1] ), AllTrim( aX[2] ), AllTrim( aX[3] ) ) } )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGetLeg
Cria Arrays com as legendas conforme definição.
Uso Geral.

@param 	cTabela     Tabela de referencia
@param 	cFunction 	Nome da Funcao referente as legendas. Se nao for especificado pega as definiçoes cadastradas com o
					nome da funcao em branco para a tabela.
@Param  aExcetoSeq  Array com a sequencias que ano serão usadas para montar a legenda

@return	aRet		Array com as legendas

@sample
JurGetLeg( "SA1", "ROTINA" ))

// Retorna Array com
//     [1] -> (C)  Regra
//     [2] -> (C)  Cor
//     [3] -> (C)  Legenda

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurGetLeg( cTabela, cFunction, aExcetoSeq )
	Local aArea    := GetArea()
	Local aAreaNTY := NTY->( GetArea() )
	Local aRet     := NIL
	Local cFilNTY  := ''
	Local cChave   := ''
	Local nAt      := 0
	Local cCpoLang := ''

	Default cTabela    := Alias()
	Default cFunction  := Space(10)
	Default aExcetoSeq := {}

	dbSelectArea( 'NTY' )

	cFunction  := PadR( cFunction, 10 )
	cTabela    := PadR( cTabela  ,  3 )
	cFilNTY    := xFilial( 'NTY' )
	cChave     := cFilNTY + cTabela + cFunction

	If ( nAt := aScan( aLegenda, { |aX| aX[1] + aX[2] + aX[3] == cChave } ) ) == 0

		If __Language == 'PORTUGUESE'
			cCpoLang := 'NTY_LEGEND'
		ElseIf __Language == 'ENGLISH'
			cCpoLang := 'NTY_LEGENG'
		ElseIf __Language == 'SPANISH'
			cCpoLang := 'NTY_LEGSPA'
		EndIf

		aAdd( aLegenda, { cFilNTY, cTabela, cFunction,{} } )
		nAt  := Len( aLegenda )

		If NTY->( dbSeek( cChave, .T. ) )
			While !NTY->( EOF() ) .AND. NTY->( NTY_FILIAL + NTY_TABELA + NTY_FUNCAO ) == cChave
				If JurShowLeg(NTY->NTY_SEQ, aExcetoSeq)
					aAdd( aLegenda[nAt][4], { NTY->NTY_REGRA, NTY->NTY_COR, NTY->(FieldGet(FieldPos(cCpoLang))) } )
				EndIf
				NTY->(DbSkip())
			EndDo
		EndIf

	EndIf

	aRet := aClone( aLegenda[nAt][4] )

	RestArea( aAreaNTY )
	RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurShowLeg(cSeqLeg, aExcetoSeq)
Cria Arrays com as legendas conforme definição.
Uso Geral.

@Param  cSeqLeg      Codigo da sequencia da legenda
@Param  aExcetoSeq   Array com a sequencias que ano serão usadas para montar a legenda

@return lRet         .T. Se a legenda pode ser exibida

@author Nivia Ferreira / Luciano Pereria
@since 22/08/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurShowLeg(cSeqLeg, aExcetoSeq)
	Local lRet := .T.

	If !Empty(aExcetoSeq)
		lRet := aScan(aExcetoSeq, {|a| a == cSeqLeg}) == 0
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}JurSetAgrp
Cria os agrupamentos de campos de em tela nas rotinas conforme definição.
Uso Geral.

@param 	cTable	  	Tabela de origem
@param 	cFunction 	Nome da Funcao referente aos agrupamentos. Se nao For especificado pega as definiçoes cadastradas com o
nome da funcao em branco para a tabela.
@param 	oStruct    	Objeto de estrutura do view

@sample
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( "JURA100" )
Local oStructNT4 := FWFormStruct( 2, "NT4" )
JurSetAgrp( 'NT4',, oStruct )

@author Ernani Forastieri
@since 01/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSetAgrp( cTable, cFunction, oStruct, cTipoAs )
	Local aArea      := GetArea()
	Local aAreaSXA   := SXA->( GetArea() )
	Local aGrp       := {}
	Local aNoAgrp    := {}
	Local cAux       := ''
	Local cGrupo     := ''
	Local lFirst     := .F.
	Local lOutInic   := .T.
	Local nAgrp      := 0
	Local nAtFolder  := 0
	Local nAtNoGr    := 0
	Local nCampos    := 0
	Local nFolder    := 0
	Local nX         := 0

	ParamType 0 Var cTable     As Character Optional Default Alias()
	ParamType 1 Var cFunction  As Character Optional Default Space(10)
	ParamType 2 Var oStruct    As Object
	ParamType 3 var cTipoAs    As Character Optional Default ''

	JurLoadAgp( cTable, cFunction )

	aGrp := JurGetAgrp( cTable, cFunction, cTipoAs )

/*
AddGroup
cID       Id do Group
cTitulo   Texto do Group
cIDFolder Id da Folder onde o grupo sera criado
nType     Tipo do agrupamento ( 1=Janela; 2=Separador )
*/

	If Len( aGrp[3] )  > 0

		lOutInic := ( aGrp[2] == '1' )
		cGrupo   := '0'

		For nFolder := 1 To Len( aGrp[4] )                     // Folders

			If lOutInic   // Coloca os campos sem agrupamento no inicio

				// Passa o grupo com nome em branco para nao criar a tarja de separacao
				//
				//oStruct:AddGroup( IIf( Empty( aGrp[1] ) , GetAdvFVal( 'SXA', 'XA_DESCRIC', cTable + aGrp[3][nFolder][1], 1, '' ) , aGrp[1] ) , aGrp[3][nFolder][1] )
				cGrupo := Soma1( cGrupo )
				oStruct:AddGroup( cGrupo, ' ', aGrp[4][nFolder][1],  Val( aGrp[3] ) )
				aEVal( oStruct:aFields, { | x, y | IIf( oStruct:aFields[y][11] == aGrp[4][nFolder][1], oStruct:SeTGroupField( oStruct:aFields[y][1], cGrupo ) , ) } )
			EndIf

			For nAgrp := 1 To Len( aGrp[4][nFolder][2] )          // Grupos

				cGrupo := Soma1( cGrupo )
				oStruct:AddGroup( cGrupo, aGrp[4][nFolder][2][nAgrp][2], aGrp[4][nFolder][1], Val( aGrp[4][nFolder][2][nAgrp][3] ) )

				For nCampos := 1 To Len( aGrp[4][nFolder][2][nAgrp][4] )  // Campos

					oStruct:SetGroupField( aGrp[4][nFolder][2][nAgrp][4][nCampos], cGrupo )

				Next

				if (nAgrp < Len( aGrp[4][nFolder][2] ))
					cGrupo := Soma1( cGrupo )
					oStruct:AddGroup( cGrupo, ' ', aGrp[4][nFolder][1],  Val( aGrp[3] ) )
				Endif

			Next

			//
			// Coloca os outros campos que nao tem agrupamento definido em um agrupamentos "outros"
			//
			If !lOutInic  // Se os campos sem agrupamento nao estao no inicio faz agora o agrupamento

				lFirst := .T.

				For nX := 1 To Len( oStruct:aFields )

					If oStruct:aFields[nX][12] == aGrp[4][nFolder][1]

						If  lFirst
							cAux := aGrp[1]

							If Empty( cAux )
								cAux := XADescric()
							EndIf

							If Empty( cAux )
								cAux := STR0165   // "Outros"
							EndIf

							cGrupo := Soma1( cGrupo )
							oStruct:AddGroup( cGrupo, cAux, aGrp[4][nFolder][1], Val( aGrp[3] ) )
							lFirst := .F.

						EndIf

						oStruct:SeTGroupField( oStruct:aFields[nX][1], cGrupo )

					EndIf

				Next

			EndIf

		Next

		// Cria um agrupamento para os campos em folders em que nao tem nenhum agrupamento, se nao os campos nao aparecem na tela
		aNoAgrp := {}

		For nX := 1 To Len( oStruct:aFields )

			If ( nAtFolder := aScan( aGrp[4], { | aX | aX[1] == oStruct:aFields[nX][11] } ) ) == 0 .AND. !Empty( oStruct:aFields[nX][11] ) // Nao tem grupo para a folder

				If ( nAtNoGr := aScan( aNoAgrp, { | aX | aX[1] == oStruct:aFields[nX][11] } ) ) == 0

					//oStruct:AddGroup( aGrp[1], oStruct:aFields[nX][11] )
					//oStruct:AddGroup( GetAdvFVal( 'SXA', 'XA_DESCRIC', cTable + oStruct:aFields[nX][11], 1, ' ' ) , oStruct:aFields[nX][11] )

					// Passa o grupo com nome em branco para nao criar a tarja de separacao
					cGrupo := Soma1( cGrupo )
					oStruct:AddGroup( cGrupo, ' ', oStruct:aFields[nX][11], 1 )

					aAdd( aNoAgrp, { oStruct:aFields[nX][11], cGrupo } )
					nAtNoGr := Len( aNoAgrp )

				EndIf

				oStruct:SeTGroupField( oStruct:aFields[nX][1], aNoAgrp[nAtNoGr][2] )

			EndIf

		Next

	EndIf

	RestArea( aAreaSXA )
	RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/ { Protheus.doc } JurGetAgrp
	Cria Arrays com os agrupamentos de campos conforme definição.
	Uso Geral.

	@param 	cTabela     Tabela de referencia
	@param 	cFunction 	Nome da Funcao referente aos agrupamentos. Se nao For especificado pega as definiçoes cadastradas com o
	nome da funcao em branco para a tabela.

	@Return	aRet		Array com os agrupamentos

	@sample
	aGrp := JurGetAgrp( "NT0", "ROTINA" )

// Retorna Array com
//   [1] ->( C )  Descricao do agrupamento para campos que nao possuam agrupamento definido. Default "Dados Gerais"
//   [2] ->( C )  Agrupamento dos campos sem definicao no Inicio ou final, 1=Inicio 2=Final
//   [3] ->( C )  Tipo de Agrupamento 1=Agrupamento 2=Separador
//   [4] ->( C )  Folders
//   [4][1] ->( C )  Cod. da Folder
//   [4][2] ->( C )  Agrupamentos
//   [4][2][1] ->( C )  Cod. do Grupo
//   [4][2][2] ->( C )  Descricao do Grupo
//   [4][2][3] ->( C )  Tipo do Grupo
//   [4][2][4] ->( C )  Campos do Grupo
//   [4][2][4][1] ->( C )  Nome dos Campos

	@author Ernani Forastieri
	@since 01/09/09
	@version 1.0
/*/
//-------------------------------------------------------------------
Function JurGetAgrp( cTabela, cFunction, cTipoAs )
	Local aArea     := GetArea()
	Local aAreaNUX  := NUX->( GetArea() )
	Local aRet      := { '', '', {} }
	Local cChave    := ''
	Local cChaveNUX := ''
	Local cChaveNVX := ''
	Local cFilNVX   := ''
	Local nAtFolder := 0
	Local nAt       := 0
	Local nAtAgrp   := 0
	Local nI        := 0
	Local aCodgru   := {'001', '003', '008', '009', '021'}	//Pedido, Totais Pedido, Contingência, Totais Contingência, Dados Processo
	Local lFlgaba   := .F.
	local AgrpOutr  := ""

	ParamType 0 Var cTabela    As Character  Optional Default Alias()
	ParamType 1 Var cFunction  As Character  Optional Default ''
	ParamType 3 var cTipoAs    As Character  Optional Default ''

	If !EMPTY( cTipoAs )
		lFlgaba := (JGetParTpa(cTipoAS, "MV_JVLRCO", "1") == "2") .And. (cTabela == "NSY")
	Endif

	dbSelectArea( 'NVX' )
	dbSelectArea( 'NUX' )
	dbSelectArea( 'NUY' )

	cFunction  := PadR( cFunction, 10 )
	cTabela    := PadR( cTabela  ,  3 )
	cFilNVX    := xFilial( 'NVX' )
	cChave     := cFilNVX + cTabela + cFunction

	SX3->( dbSetOrder( 2 ) )

	If ( nAt := aScan( aGrupos , { | aX | aX[1] + aX[2] + aX[3] == cChave } ) ) == 0

		If NVX->( dbSeek( cChave, .T. ) )

			aAdd( aGrupos, { cFilNVX, cTabela, cFunction, { '', '', '', {} } } )

			nAt  := Len( aGrupos )

			cChaveNVX := NVX->( NVX_FILIAL + NVX_TABELA + NVX_FUNCAO )

			//--Tramento para o agrupamento "Outros" de acordo com a Linguagem
			If  __Language == 'PORTUGUESE'
				AgrpOutr := NVX->NVX_OUTROS

			ElseIf __Language == 'ENGLISH'
				AgrpOutr := NVX->NVX_OUTENG

			ElseIf __Language == 'SPANISH'
				AgrpOutr := NVX->NVX_OUTSPA
			EndIf

			aGrupos[nAt][4][1] := AgrpOutr
			aGrupos[nAt][4][2] := NVX->NVX_INIFIM
			aGrupos[nAt][4][3] := NVX->NVX_TIPOUT

			//
			// Seleciona os grupos
			//
			NUX->( dbSetOrder( 2 ) )
			NUX->( dbSeek( cChaveNVX ) )
			nI := 1

			While !NUX->( EOF() ) .AND. NUX->( NUX_FILIAL + NUX_TABELA + NUX_FUNCAO ) == cChaveNVX

				cChaveNUX := NUX->( NUX_FILIAL + NUX_TABELA + NUX_FUNCAO + NUX->NUX_CODGRP )

				If lFlgaba
					If aScan(aCodgru,NUX->NUX_CODGRP) == 0
						NUX->( dbSkip() )
						Loop
					Endif
				Endif
				//
				// Seleciona os campos
				//
				NUY->( dbSeek( cChaveNUX ) )

				While !NUY->( EOF() ) .AND. NUY->( NUY_FILIAL + NUY_TABELA + NUY_FUNCAO + NUY->NUY_CODGRP ) == cChaveNUX

					SX3->( dbSeek( NUY->NUY_CAMPO ) )

					If ( nATFolder := aScan( aGrupos[nAt][4][4], { | aX | aX[1] == SX3->X3_FOLDER } ) ) == 0
						aAdd( aGrupos[nAt][4][4], { SX3->X3_FOLDER, {} } )
						nATFolder := Len( aGrupos[nAt][4][4] )
					EndIf

					If ( nAtAgrp  := aScan( aGrupos[nAt][4][4][nATFolder][2], { | aX | aX[1] == NUY->NUY_CODGRP } ) ) == 0
						If	    __Language == 'PORTUGUESE'
							aAdd( aGrupos[nAt][4][4][nATFolder][2], { NUX->NUX_CODGRP, NUX->NUX_GRUPO , NUX->NUX_TIPO, {} } )
						ElseIf  __Language == 'ENGLISH'
							aAdd( aGrupos[nAt][4][4][nATFolder][2], { NUX->NUX_CODGRP, NUX->NUX_GRUENG, NUX->NUX_TIPO, {} } )
						ElseIf  __Language == 'SPANISH'
							aAdd( aGrupos[nAt][4][4][nATFolder][2], { NUX->NUX_CODGRP, NUX->NUX_GRUSPA, NUX->NUX_TIPO, {} } )
						EndIf

						nAtAgrp := Len( aGrupos[nAt][4][4][nATFolder][2] )
					EndIf

					aAdd( aGrupos[nAt][4][4][nATFolder][2][nAtAgrp][4], AllTrim( NUY->NUY_CAMPO )  )

					NUY->( dbSkip() )
				EndDo

				NUX->( dbSkip() )

			EndDo

		EndIf

	EndIf

	If nAt > 0
		aRet := aClone( aGrupos[nAt][4] )
	EndIf

	RestArea( aAreaNUX )
	RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSetBSize
Determinia o percentual a ser utilizado para a grid em um FWMBROWSE connforme resolução de tela.
Uso Geral.

@param 	oBrowse	  	Objeto Browse
@param 	cPercs 		String contendo o pecertuais para as resolucoes 800,1024 e 1280 dpi. Ex. "50,60,70"

@sample
oBrowse := FWMBrowse():New()
oBrowse:SetAlias( "NRB" )
JurSetBSize( oBrowse )  // ou JurSetBSize( oBrowse, '50,60,70' )
oBrowse:Activate()

@author Ernani Forastieri
@since 01/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSetBSize( oBrowse, cPercs )
	Local aSize  := GetScreenRes()
	Local aAux   := {}
	Local nBSize := 20

	ParamType 0 Var oBrowse    As Object
	ParamType 1 Var cPercs     As Character Optional Default SuperGetMV( 'MV_JBSIZE',, '60,70,80' )

	aAux  := StrToArray( cPercs, ',' )

	If     aSize[1] >= 1280
		nBSize := Val( aAux[3] )

	ElseIf aSize[1] >= 1024
		nBSize := Val( aAux[2] )

	ElseIf aSize[1] >=  800
		nBSize := Val( aAux[1] )

	EndIf

	oBrowse:SetSizeBrowse( nBSize )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JurExistSX3
Verifica se um campo existe no dicionario de campos SX3.
Uso Geral.

@param 	cCampo      Nome do Campo para verificar a existencia
@param 	lVerUso     Verifica ou nao se o campo é usado

@return	lRet		.T./.F. Se o campo existir ou nao no Dicionario SX3

@sample
	If !JurExistSX3( 'A1_COD' )
	JurMsgErro( 'Campo nao Existe.' )
	EndIf

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurExistSX3( cCampo, lVerUso  )
	Local lRet     := .T.
	Local aArea    := GetArea()
	Local aAreaSX3 := SX3->( GetArea() )

	ParamType 0 Var cCampo     As Character  Optional Default ReadVar()
	ParamType 1 Var lVerUso    As Logical    Optional Default .F.

	SX3->( dbSetOrder( 2 ) )
	If !SX3->( dbSeek( PadR( cCampo, 10 ) ) )
		lRet := .F.
		Help( ' ', 1, 'EXISTCPO' )
	Else
		If lVerUso .and. !X3USADO( cCampo )
			lRet := .F.
			JurMsgErro( STR0015 ) // "Campo não estÃ¡ configurado como usado."
		EndIf
	EndIf

	RestArea( aAreaSX3 )
	RestArea( aArea    )

Return lRet

Function JURSX3SEL()
	JurMsgErro( 'Ainda não disponível.' )
Return .F.

/*
Local oDlg := NIL
Local oLbx := NIL

Local aArea     := GetArea()
Local aAreaSX3  := SX3->( GetArea() )
Local cTitulo   := "Campos do Sistema"

SX3->( dbSetOrder( 1 ) )

	While !SX3->(Eof()) .And. X3_ARQUIVO == M->ADI_ALIAS

		If X3USO(SX3->X3_USADO) .AND. SX3->X3_CONTEXT == "R" .AND. !AllTrim(SX3->X3_CAMPO) $ cNoCpos
aAdd( aCpos, { SX3->X3_CAMPO, SX3->&cDescr } )
		EndIf

SX3->(DbSkip())

	Enddo

	If Len( aCpos ) > 0

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL

@ 10,10 LISTBOX oLbx FIELDS HEADER '', ''  SIZE 230,95 OF oDlg PIXEL

oLbx:SetArray( aCpos )
oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2]}}
oLbx:bLDblClick := {|| {oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]}}}

DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]})  ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTER

M->ADI_CAMPO  := iIF(Len(aRet) > 0, aRet[1],"")
M->ADI_CPODES := iIF(Len(aRet) > 0, aRet[2],"")

oEnch:Refresh()

	EndIf

Return aRet
Return .T.
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} JurM1
Retorna mascara para CNPJ ou CPF para uso no dicionario.
Uso Geral.

@param 	cTipPes     Tipo da Mascara 1 ou F pessoa fisica, 2 ou J Pessoa Juridica

@return	cRet		Mascara

@sample
cTipo := '1'
cMasc := JurM1( cTipo )

//Retorna '@R 999.999.999-99'

@author Ernani Forastieri
@since 01/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurM1( cTipPes )
	Local cPict := ''

	ParamType 0 Var cTipPes     As Character

	If      cTipPes $  '1/F'
		cPict := '@R 999.999.999-99'
	ElseIf  cTipPes $  '2/J'
		cPict := '@R 99.999.999/9999-99'
	EndIf

	cPict := cPict + '%C'

Return cPict

//-------------------------------------------------------------------
/*/{Protheus.doc} JurPrefTab
Retorna o alias de uma tabela a partir de um nome de campo.
Uso Geral.

@param 	cCampo     	Nome do Campo

@return	cRet		Alias da tabela

@sample

Alert( JurPrefTab( 'A1_COD' ) // Retorna SA1

Alert( JurPrefTab( 'NQ1_COD' ) // Retorna NQ1

@author Ernani Forastieri
@since 01/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurPrefTab( cCampo )
	Local cRet := ''

	ParamType 0 Var cCampo     As Character  Optional Default ReadVar()

	cCampo := AllTrim( cCampo )

	cRet := IIf( At( '_', cCampo ) == 3, 'S' + SubStr( cCampo, 1, 2 ), SubStr( cCampo, 1, 3 ) )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SM0Load
Rotina auxiliar para carregar o vetor aEmprSM0 com dados do sigamat.emp
Uso Geral.

@author Ernani Forastieri
@since 01/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SM0Load()
	Local aArea    := {}
	Local aAreaSM0 := {}

	If Len( aEmprSM0 ) > 0
		Return NIL
	EndIf

	aArea    := GetArea()
	aAreaSM0 := SM0->( GetArea() )

	SM0->( dbSetOrder( 1 ) )
	SM0->( dbGoTop() )
	SM0->( dbEVal( { || aAdd( aEmprSM0, {;
		SM0->M0_CODIGO  ,; //  1
	SM0->M0_CODFIL  ,; //  2
	SM0->M0_FILIAL  ,; //  3
	SM0->M0_NOME    ,; //  4
	SM0->M0_NOMECOM ,; //  5
	SM0->M0_ENDCOB  ,; //  6
	SM0->M0_CIDCOB  ,; //  7
	SM0->M0_ESTCOB  ,; //  8
	SM0->M0_BAIRCOB ,; //  9
	SM0->M0_CEPCOB  ,; // 10
	SM0->M0_ENDENT  ,; // 11
	SM0->M0_CIDENT  ,; // 12
	SM0->M0_ESTENT  ,; // 13
	SM0->M0_BAIRENT ,; // 14
	SM0->M0_CEPENT  ,; // 15
	SM0->M0_CGC     ,; // 16
	SM0->M0_INSC    ,; // 17
	SM0->M0_TEL     ,; // 18
	SM0->M0_FAX      ; // 19
	} ) },, { || !EOF() } ) )

	RestArea( aAreaSM0 )
	RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSM0Info
Retorna o alias de uma tabela a partir de um nome de campo.
Uso Geral.

@param 	nTipo 		Tipo da Informacao 1=Tudo, 2=Filiais da Empresa, 3=Empresas ( 1a. Filial )
@param 	cEmp		Empresa de Referencia

@return	aRet		Vetor com as informaçÃµes do sigamat.emp, onde:
[ 1] M0_CODIGO
[ 2] M0_CODFIL
[ 3] M0_FILIAL
[ 4] M0_NOME
[ 5] M0_NOMECOM
[ 6] M0_ENDCOB
[ 7] M0_CIDCOB
[ 8] M0_ESTCOB
[ 9] M0_BAIRCOB
[10] M0_CEPCOB
[11] M0_ENDENT
[12] M0_CIDENT
[13] M0_ESTENT
[14] M0_BAIRENT
[15] M0_CEPENT
[16] M0_CGC
[17] M0_INSC
[18] M0_TEL
[19] M0_FAX

@sample

Local aVet := {}

aVet := JurSM0Info() // Retorna todas as empresas/filiais

aVet := JurSM0Info( 1 ) // Retorna todas as empresas/filiais

aVet := JurSM0Info( 2 ) // Retorna todas as filiais da empresa corrente

aVet := JurSM0Info( 3 ) // Retorna todas as empresas ( 1a. filiais )

aVet := JurSM0Info( 2, '02' ) // Retorna todas as filiais da empresa 02

@author Ernani Forastieri
@since 01/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSM0Info( nTipo, cEmp )
	Local aRet := {}
	Local uAux := NIL

	ParamType 0 Var nTipo      As Numeric   Optional Default 1
	ParamType 1 Var cEmp       As Character Optional Default cEmpAnt

	SM0Load()

	If nTipo == 1 // Tudo
		aRet := aClone( aEmprSM0 )

	ElseIf nTipo == 2 // So Filiais da Empresa
		aEVal( aEmprSM0, { | aX | IIf( aX[1] == cEmp, aAdd( aRet, aX ), ) } )

	ElseIf nTipo == 3 // So Empresas ( 1a. Filial )
		aEVal( aEmprSM0, { | aX | uAux := aX, IIf( aScan( aRet, { | aY | aY[1] == uAux[1] } ) == 0, aAdd( aRet, aX ), ) } )

	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSM0Cod
Retorna a empresa/filial do sigamat.emp para o CNPJ Informado
Uso Geral.

@param 	cCNPJ 		CNPJ para verificacao

@return	cRet		Informação de Empresa+Filial, para o CNPJ. Se o mesmo nao for encontrado retorna vazio. Retorna sempre a primeira ocorrencia encontrada se houver CNPJ repetidos.

@sample

Local cEmpFil

cInfo := JurPropCli( '53113791000122' )

	If Empty( cInfo  )
	JurMsgErro( 'CNPJ nao consta do SIGAMAT.' )
	Else
	JurMsgOk( 'Empresa/Filial do CNPJ é ' + cInfo )
	EndIf

@author Ernani Forastieri
@since 01/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSM0Cod( cCNPJ )
	Local cRet := ''
	Local nAt  := 0

	ParamType 0 Var cCNPJ      As Character

	SM0Load()

	cCNPJ := PadR( AllTrim( cCNPJ ), 14 )

	If ( nAt := aScan( aEmprSM0, { | aX | aX[16] == cCNPJ } ) ) > 0
		cRet := aEmprSM0[nAt][1] + aEmprSM0[nAt][2]
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurF3Qry
Função genérica para montagem de tela de consulta padrao baseado em query especifica
Uso Geral.

@param 	cQuery          Query a ser executada
@param 	cCodCon 	    Codigo da consulta
@param 	cCpoRecno 		Campo com o Recno()
@param 	nRetorno 		Campo onde sera retornado o recno() do registro selecionado
@param 	aCoord          Coordenadas da tela, se nao espeficicado serÃ¡ usado o tamanho padrão
@param 	aSearch         Array de campos que serao os indices utilizados para pesquisa
@sample

Funcion SA1CON()
Local nRetorno := 0

cQuery += "SELECT A1_COD, A1_LOJA, A1_NOME, SA1.R_E_C_N_O_ SA1RECNO "
cQuery += "  FROM " + RetSqlName( "SA1" ) + " SA1 "
cQuery += " WHERE A1_FILIAL = '" + xFilial( "SA1" ) + "'"
cQuery += "   AND A1_TIPO = 'J'"
cQuery += "   AND SA1.D_E_L_E_T_ = ' '"

	If JurF3Qry( cQuery, 'SA1QRY', 'SA1RECNO', @nRetorno )
	SA1->( dbGoto( uRetorno ) )
	lRet := .T.
	EndIf

// Deve ser criada uma consulta especifica no configurador para esta funcao,
// no exemplo, SA1CON()

Return lRet

@author Ernani Forastieri
@since 01/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurF3Qry( cQuery, cCodCon, cCpoRecno, uRetorno, aCoord, aSearch, cTela, lInclui, lAltera, lVisualiza, cTabela )
	Local aArea       := GetArea()
	Local aSeek	  	  := {}
	Local aIndex      := {}
	Local cIdBrowse   := ''
	Local cIdRodape   := ''
	Local cTrab       := GetNextAlias()
	Local nI          := 0
	Local cRestr      := ''
	Local oBrowse
	Local oDlg
	Local oBtnOk
	Local oBtnCan
	Local oTela
	Local oPnlBrw
	Local oPnlRoda
	Local oBtnInc
	Local oBtnAlt
	Local oBtnVis
	Local nButLeft    := 0

	Private lRetF3    := .F.

	ParamType 0 Var cQuery     As Character
	ParamType 1 Var cCodCon    As Character
	ParamType 2 Var cCpoRecno  As Character
	ParamType 3 Var uRetorno   As Character, Date, Numeric
	ParamType 4 Var aCoord     As Array Optional Default {178, 0, 543, 800} //padrï¿½o de coordenadas da consulta especï¿½fica
	ParamType 5 Var aSearch    As Array Optional Default {}
	ParamType 6 Var cTela	   As Character Optional Default ""
	ParamType 7 Var lInclui    As Logical Optional Default .F.
	ParamType 8 Var lAltera    As Logical Optional Default .F.
	ParamType 9 Var lVisualiza As Logical Optional Default .F.
	ParamType 10 Var cTabela   As Character Optional Default ""

	If !Empty(cTabela)
		cRestr := JurQryRest(cTabela)
	EndIf
	If !Empty(cRestr)
		cQuery += cRestr
	EndIf

	//-------------------------------------------------------------------
	// Indica as chaves de Pesquisa
	//-------------------------------------------------------------------
	//[1] - Nome do Campo
	//[2] - Titulo do Campo
	//[3] - Tipo do Campo
	//[4] - Tamanho do Campo
	//[5] - Casas decimais
	//-------------------------------------------------------------------
	If !Empty (aSearch)
		For nI:= 1 To Len(aSearch)
			aAdd( aIndex, aSearch[nI] )
			aAdd( aSeek, { AvSX3(aSearch[nI], 5), {{"", AvSX3(aSearch[nI], 2), AvSX3(aSearch[nI], 3), AvSX3(aSearch[nI], 4), AvSX3(aSearch[nI], 5),,}} } )

			If nI == 1
				cQuery += " ORDER BY "+aSearch[nI]
			EndIf
		Next
	EndIf

	Define MsDialog oDlg FROM aCoord[1], aCoord[2] To aCoord[3], aCoord[4] Title STR0112 Pixel Of oMainWnd //'Consulta Padrão'

	oTela     := FWFormContainer():New( oDlg )
	cIdBrowse := oTela:CreateHorizontalBox( 85 )
	cIdRodape := oTela:CreateHorizontalBox( 15 )
	oTela:Activate( oDlg, .F. )

	oPnlBrw   := oTela:GeTPanel( cIdBrowse )
	oPnlRoda  := oTela:GeTPanel( cIdRodape )

	oBrowse := CriaF3Browse(oDlg, oPnlBrw, cQuery, @cTrab, @uRetorno, aSeek, aIndex, cCodCon, cCpoRecno)

	@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 003 Button oBtnOk  Prompt STR0113 Size 25, 11 Of oPnlRoda Pixel Action ( lRetF3 := .T., uRetorno := ( cTrab )->( FieldGet( FieldPos( cCpoRecno ) ) ) , oDlg:End() ) //'Confirma'
	@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 033 Button oBtnCan Prompt STR0114 Size 25, 11 Of oPnlRoda Pixel Action ( lRetF3 := .F., oDlg:End() ) //'Cancela'

	nButLeft := 033

	If lInclui
		nButLeft += 30
		@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + nButLeft Button oBtnInc Prompt STR0115 Size 25, 12 Of oPnlRoda Pixel Action ( JurAcao(cTela, 3, oBrowse), ;
			oBrowse:DeActivate(.T.), oBrowse := CriaF3Browse(oDlg, oPnlBrw, cQuery, @cTrab, @uRetorno, aSeek, aIndex, cCodCon, cCpoRecno) ) //'Incluir'
	EndIf

	If lAltera
		nButLeft += 30
		@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + nButLeft Button oBtnAlt Prompt STR0116 Size 25, 12 Of oPnlRoda Pixel Action ( JurAcao(cTela, 4, oBrowse, (cTrab)->( FieldGet( FieldPos( cCpoRecno ) ) ), cTabela) ) //'Alterar'
	EndIf

	If lVisualiza
		nButLeft += 30
		@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + nButLeft Button oBtnVis Prompt STR0117 Size 25, 12 Of oPnlRoda Pixel Action ( JurAcao(cTela, 1, oBrowse, (cTrab)->( FieldGet( FieldPos( cCpoRecno ) ) ), cTabela) ) //'Visualizar'
	EndIf

	Activate MsDialog oDlg Centered // Ativação do janela

	RestArea( aArea )

Return lRetF3

Static Function CriaF3Browse(oDlg, oPnlBrw, cQuery, cTrab, uRetorno, aSeek, aIndex, cCodCon, cCpoRecno)
	Local oBrowse
	Local oColumn
	Local nI
	Local nAt
	Local aCampos     := {}
	Local aStru       := {}
	Local aJurF3      := {}
	Local cTitCpo     :=  ''
	Local cPicCpo     :=  ''
	Local aNoAccLGPD  := {}
	Local aDisabLGPD  := {}
	Local lOfuscate   := _lFwPDCanUse .And. FwPDCanUse(.T.)
	Local aCpos		  := {}

	If SELECT(cTrab) > 0
		(cTrab)->(DbCloseArea())
		cTrab := GetNextAlias()
	ElseIf File(cTrab + GetDbExtension())
		cTrab := GetNextAlias()
	EndIf

	nAt := aScan( aJurF3, { | aX | aX[1] == PadR( cCodCon, 10 ) } )
	If !Empty( cCodCon )

		If nAt == 0
			aAdd( aJurF3, { PadR( cCodCon, 10 ), cQuery, {} } )
		Else
			cQuery  := aJurF3[nAt][2]
		EndIf

	EndIf

	//-------------------------------------------------------------------
	// Define o Browse
	//-------------------------------------------------------------------
	Define FWBrowse oBrowse SHOWLIMIT DATA QUERY ALIAS cTrab QUERY cQuery ;
	DOUBLECLICK { || lRetF3 := .T., uRetorno := (cTrab)->( FieldGet( FieldPos( cCpoRecno ) ) ), oDlg:End() } ;
	NO LOCATE FILTER SEEK ORDER aSeek INDEXQUERY aIndex Of oPnlBrw

TcSetField( cTrab, cCpoRecno, 'N', 12, 0)

//-------------------------------------------------------------------
// Monta Estrutura de campos
//-------------------------------------------------------------------
If !Empty( cCodCon )

	If nAt == 0

		aStru := ( cTrab )->( dbStruct() )

		For nI := 1 To Len( aStru )

			//-------------------------------------------------------------------
			// Campos
			//-------------------------------------------------------------------
			// Estrutura do aFields
			//				[n][1] Campo
			//				[n][2] Título
			//				[n][3] Tipo
			//				[n][4] Tamanho
			//				[n][5] Decimal
			//				[n][6] Picture
			//-------------------------------------------------------------------

			cTitCpo := aStru[nI][1]
			cPicCpo := ''

			If AvSX3( aStru[nI][1],, cTrab, .T. )
				cTitCpo := RetTitle( aStru[nI][1] )
				cPicCpo := AvSX3( aStru[nI][1], 6, cTrab )

				If cPicCpo $ '@!'
					cPicCpo := ''
				EndIf
			EndIf

			If !PadR( cCpoRecno, 15 ) == PadR( aStru[nI][1], 15 )
				aAdd( aCampos, { aStru[nI][1], cTitCpo, aStru[nI][2], aStru[nI][3], aStru[nI][4], cPicCpo } )
				aAdd( aCpos, aStru[nI][1])
			EndIf

		Next

		If !Empty( cCodCon )
			aJurF3[Len( aJurF3 )][3] := aCampos
		EndIf

	Else
		aCampos := aClone( aJurF3[nAt][3] )
	EndIf

EndIf

//-------------------------------------------------------------------
// Adiciona as colunas do Browse
//-------------------------------------------------------------------
If lOfuscate
	aNoAccLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCpos)
	AEval(aNoAccLGPD, {|x| AAdd(aDisabLGPD, x:CFIELD)})
EndIf

lOfuscate := Len(aDisabLGPD ) > 0

For nI := 1 To Len( aCampos )

	If "NT2_DATA" $ Alltrim( aCampos[nI][1] )
		ADD COLUMN oColumn  DATA &( '{ || DTOC(STOD( &("' + aCampos[nI][1] + '") ) ) }' ) Title aCampos[nI][2] PICTURE aCampos[nI][6] Of oBrowse
	Else
		ADD COLUMN oColumn  DATA &( '{ ||' + aCampos[nI][1] + ' }' ) Title aCampos[nI][2]  PICTURE aCampos[nI][6] Of oBrowse
	EndIf

	If lOfuscate
		oColumn:SetObfuscateCol( aScan(aDisabLGPD, aCampos[nI][1]) > 0)
	EndIf

Next

//-------------------------------------------------------------------
// Adiciona as colunas do Filtro
//-------------------------------------------------------------------
oBrowse:SetFieldFilter( aCampos )
oBrowse:SetUseFilter()

//-------------------------------------------------------------------
// Ativação do Browse
//-------------------------------------------------------------------
Activate FWBrowse oBrowse

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} JurAcao
Funï¿½ï¿½o para facilitar a utilizaï¿½ï¿½o do FWExecView.

@author Felipe Bonvicini Conti
@since 13/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurAcao(cTela, nAcao, oBrowse, nRecno, cTabela, IsMVC)
	Local lOk     := .T.
	Local cTitulo := ""

	Default nRecno := 0
	Default cTabela:= ''
	Default IsMVC   := .T.

	If nAcao == 1 .Or. nAcao == 4
		If !Empty(cTabela)
			(cTabela)->( dbGoto( nRecno ) )
		Else
			Return lOk
		EndIf
	EndIf

	Do Case
	Case nAcao == 1
		cTitulo := STR0117 // "Visualizar"
	Case nAcao == 3
		cTitulo := STR0115 // "Incluir"
	Case nAcao == 4
		cTitulo := STR0116 // "Alterar"
	EndCase

	If IsMVC
		FWExecView( cTitulo, cTela, nAcao,, { || lOk := .T., lOk } )

		If nAcao <> 3
			oBrowse:Refresh(nAcao == 3)
		EndIf
	Else
		EVal(&("{||" +cTela+"}"))
	EndIf

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} FWFldGet
Retorna o valor de um campo do Modelo
Uso Geral.

@param 	cCampo 		Nome do campo que se deseja pegar o conteudo
@param 	nLinha 		Numero da linhas do campo que se deseja pegar o conteudo quando ele esta numa FORMGRID
@param 	lShowMsg 	.T./.F. Exibe ou não mensagem de erro quando o campo não é encontrado no Model

@return xRet		Conteudo do campo

@author Ernani Forastieri
@since 31/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurFldGet( cCampo, nLinha, oModel, lShowMsg )
	Local xRet   := NIL
//Local oModel := FWModelActive( , .T. )
	Local cId    := ''

	ParamType 0 Var cCampo     As Character
	ParamType 1 Var nLinha     As Numeric Optional Default 0
	ParamType 2 Var lShowMsg   As Logical Optional Default .T.
	ParamType 4 Var oModel     As Object  Optional Default FWModelActive()

	cCampo := AllTrim( Upper( cCampo ) )

//
// Verifica o ID do campo no Model
//
	cId := FwFindId( cCampo, oModel:aModelStruct[1] )

	If Empty( cId ) .and. lShowMsg
		Help( ,, 'HELP', ProcName( 1 ), STR0048 + cCampo + STR0049, 1, 0) // "Campo "###" não pertence ao Model."
		Return xRet
	EndIf

// Se a propria variavel editada no momento volto a variavel de memoria
	If 'M->' + cCampo == ReadVar() .AND. IsMemVar(  'M->' + cCampo )
		xRet :=  &( 'M->' + cCampo )

	Else
		If oModel:GetModel( cId ):ClassName() == 'FWFORMGRID'
			oModel := oModel:GetModel( cId )
			xRet := oModel:GetValue( cCampo, IIf( nLinha > 0, nLinha, NIL ) )
		Else
			xRet := oModel:GetValue( cId, cCampo )
		EndIf

	EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FwFindId
Retorna o ID de um campo do modelo
Uso Geral.

@param 	cCampo 	     	Nome do campo que se deseja encontrar o Id no Model
@param 	aModelStruct 	Array com a estrutura do Model

@return cRet	 		Id do campo

@author Ernani Forastieri
@since 31/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurFindId( cCampo, aModelStruct )
	Local cRet   := ''
	Local nAt    := 0
	Local oModel := NIL
	Local nI     := 0

	ParamType 0 Var cCampo       As Character
	ParamType 1 Var aModelStruct As Array Optional

	If ValType( aModelStruct ) == 'U'
		oModel := FWModelActive()
		aModelStruct := oModel:aModelStruct[1]
	EndIf

	cCampo := AllTrim( Upper( cCampo ) )

	If      aModelStruct[1] == 'FIELD'
		//
		// Tenta achar no FormFields
		//
		If ( nAt := aScan( aModelStruct[3]:aDataModel, { | x | AllTrim( x[1] ) == cCampo } ) ) == 0
			For nI := 1 To Len( aModelStruct[4] ) // Pode Haver mais de uma FORMGRID no Model
				If !Empty( cRet := FwFindId( cCampo, aModelStruct[4][nI] ) )
					Exit
				EndIF
			Next
		Else
			cRet := aModelStruct[2]
		EndIf

	ElseIf	aModelStruct[1] == 'GRID'
		//
		// Tenta achar no FormGrid
		//
		If ( nAt := aScan( aModelStruct[3]:aHeader, { | x | AllTrim( x[2] ) == cCampo } ) ) == 0
			For nI := 1 To Len( aModelStruct[4] ) // Pode Haver mais de uma FORMGRID no Model
				If !Empty( cRet := FwFindId( cCampo, aModelStruct[4][nI] ) )
					Exit
				EndIF
			Next
		Else
			cRet := aModelStruct[2]
		EndIf

	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurDow
Retorna o dia da semana por extenso
Uso Geral.

@param 	xData 	     	Data de referencia
@param 	lAbrev		 	.T. Retorna abreviado

@return cRet	 		Dia por extenso

@author Ernani Forastieri
@since 31/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurDow( xData, lAbrev )
	Local cRet       := ''
	Local nDow       := 0
	Local aDiaSemana := { STR0050, STR0051, STR0052, STR0053, STR0054, STR0055, STR0056 } // "Domingo"###"Segunda"###"Terça"###"Quarta"###"Quinta"###"Sexta"###"SÃ¡bado"
	Local aDiaSemAbr := { STR0057, STR0058, STR0059, STR0060, STR0061, STR0062, STR0063 } // "Dom."###"Seg."###"Ter."###"Qua."###"Qui."###"Sex."###"SÃ¡b."

	ParamType 0 Var xData      As Character, Date Optional Default Date()
	ParamType 1 Var lAbrev     As Array           Optional Default .F.

	If ValType( xData ) == 'C'
		xData := CToD( xData )

	ElseIf ValType( xData ) <> 'D'
		Return cRet

	EndIf

	nDow := Dow( xData )

	If nDow > 0 .and. nDow <= 7 .and. !Empty( xData )
		cRet := IIf( lAbrev, aDiaSemAbr[nDow], aDiaSemana[nDow] )
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGatilho
Função genérica para verificar um campo de cÃ³digo e obrigar a execução
do gatilho para trazer sua descrição
Uso Geral. Para quando algum campo da tela vir com o valor do cÃ³digo
preenchido e for necessÃ¡rio trazer a descrição do mesmo

@param 	cCod 	     	Campo de cÃ³digo a ser verificado
@param 	cEntidade 	    Nome da Entidade (range da tabela)
@param 	cDesc		 	Campo de descrição a ser verificado
@param 	cMaster	 		Nome do master a ser verificado

@return cResultPad	 	Descrição do cÃ³digo

IIF(!INCLUI,Posicione('NQM',1,xFilial('NQM')+NTA->NTA_CPREPO,'NQM_DESC'), JurGatilho('NTA_CPREPO','NQM','NQM_DESC' ))

@author Juliana Iwayama Velho
@since 01/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurGatilho(cCod, cEntidade, cDesc, cMaster)
	Local aArea     := GetArea()
	Local cResultPad:= ''
	Local oModel    := FWModelActive()
	Local oM        := oModel:GetModel( cMaster )

	If INCLUI

		cResultPad:= oM:GetValue(cCod)

		If !Empty(cResultPad)

			cResultPad := Posicione(cEntidade, 1 , xFilial(cEntidade) + cResultPad, cDesc)

		EndIf

	EndIf

	RestArea( aArea )

Return If(cResultPad==Nil,"",cResultPad)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCpoObrig
Retorna os campos obrigatorios de uma tabela.
Uso Geral.

@param 	cTabela		Tabela de referencia
@param 	aVet		Vetor opcional com campo, se este vetor for informado, ele sera completado com os campos obrigatorios faltantes

@return	aRet		Array com os campos Obrigatorios

@sample
aVet := JurCpoObrig()        // Retorna os campo Obrigatorios da area corrente
aVet := JurCpoObrig( 'SA1' ) // Retorna os campo Obrigatorios da tabela SA1

aVet := { 'A1_COD', 'A1_MUN' }
JurCpoObrig( 'SA1', aVet )   // O aVet sera completado com os campos obrigatorios faltantes da tabela SA1

@author Ernani Forastieri
@since 01/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurCpoObrig( cTabela, aVet )
	Local aArea    := GetArea()
	Local aAreaSX3 := SX3->( GetArea() )
	Local aRet     := {}
	Local nAt      := 0
	Local cAux     := ''

	ParamType 0 Var cTabela    As Character Optional Default Alias()
	ParamType 1 Var aVet       As Array     Optional Default {}

	If ( nAt := aScan( aObrigat, { |aX| aX[1] == cTabela } ) ) == 0

		SX3->( dbSetOrder( 1 ) )
		SX3->( dbSeek( cTabela ) )

		aAdd( aObrigat,  { cTabela, {} } )
		nAt := Len( aObrigat )

		While !SX3->( EOF() ) .AND. SX3->X3_ARQUIVO == cTabela

			If X3Obrigat( SX3->X3_CAMPO  )
				aAdd( aObrigat[nAt][2], SX3->X3_CAMPO )
			EndIf

			SX3->( dbSkip() )
		EndDo

	EndIf

	aEval( aObrigat[nAt][2], { |cX| cAux := cX, IIf( aScan( aVet, { |cX| PadR( cX, 10 ) == PadR( cAux, 10 ) } ) == 0, aAdd( aVet, cAux ), ) } )
	aRet := aClone( aVet )

	RestArea( aAreaSX3 )
	RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurShowErro
Formata vetor de erro do model para exibir ou retornar em forma de texto.
Uso Geral.

@param 	aErro		Vetor de erro
@param 	aMaster		Vetor com os dados do master
@param 	aDetail		Vetor com os dados do detail ( se houver )
@param 	lShowTela 	Exibe ou nao na tela
@param  lGravLog	Se .T. armazena o erro em arquivo grava arquivo de log.

@sample
aErro := oModel:GetErrorMessage()
JurShowErro( aErro )

@author Ernani Forastieri
@since 01/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurShowErro(aErro, aMaster, aDetail, lShowTela, lGravLog )
/*
[1] ExpC: Id do submodelo de origem
[2] ExpC: Id do campo de origem
[3] ExpC: Id do submodelo de erro
[4] ExpC: Id do campo de erro
[5] ExpC: Id do erro
[6] ExpC: mensagem do erro
[7] ExpC: mensagem da solução
[8] ExpX: Valor atribuido
[9] ExpX: Valor anterior
*/
	Local aArea     := GetArea()
	Local nTamVet   := Len(aErro)
	Local cRet      := ''
	Local nI        := 0
	Local lInfValor := .F.
	Local lOfuscate := _lFwPDCanUse .And. FwPDCanUse(.T.) .And. nModulo == 77 .And. !Iif(FindFunction("JPDUserAc"), JPDUserAc(), FwProtectedDataUtil():UsrPersonAccessPD() .And. FwProtectedDataUtil():UsrSensiAccessPD() )

	ParamType 0 Var lShowTela  As Logical   Optional Default .T.
	ParamType 1 Var lGravLog   As Logical   Optional Default .T.
	ParamType 2 Var aMaster    As Array     Optional Default {}
	ParamType 3 Var aDetail    As Array     Optional Default {}

//--------------------------------------------------------------------
	If JChkArray(aErro, 6)
		cRet += STR0075 + CRLF // "Mensagem do erro: "
		cRet += aErro[6] + CRLF
	EndIf

	If JChkArray(aErro, 7)
		cRet += STR0076 + CRLF // "Mensagem da solução: "
		cRet += aErro[7] + CRLF
	EndIf
//--------------------------------------------------------------------

	cRet += CRLF + Replicate('-', 78 ) + CRLF + STR0132 + CRLF + CRLF // Detalhes técnicos:

	Iif(JChkArray(aErro, 1), cRet += STR0070 + ' [' + AllToChar(aErro[1]) + ']' + CRLF, Nil) // "Id do formulário de origem:"
	Iif(JChkArray(aErro, 2), cRet += STR0071 + ' [' + AllToChar(aErro[2]) + ']' + CRLF, Nil) // "Id do campo de origem:     "
	Iif(JChkArray(aErro, 3), cRet += STR0072 + ' [' + AllToChar(aErro[3]) + ']' + CRLF, Nil) // "Id do formulário de erro:  "
	Iif(JChkArray(aErro, 4), cRet += STR0073 + ' [' + AllToChar(aErro[4]) + ']' + CRLF, Nil) // "Id do campo de erro:       "
	Iif(JChkArray(aErro, 5), cRet += STR0074 + ' [' + AllToChar(aErro[5]) + ']' + CRLF, Nil) // "Id do erro:                "

	lInfValor := JChkArray(aErro, 8) .Or. JChkArray(aErro, 9)

	If lInfValor
		If lOfuscate .and. !Empty(aErro[4])
			lOfuscate := Len(FwProtectedDataUtil():UsrNoAccessFieldsInList({aErro[4]})) > 0
		EndIf
	EndIf

	If nTamVet >= 8
		Iif(lInfValor, cRet += STR0077 + ' [' + IIF(!lOfuscate .or. Empty(aErro[8]), AllToChar(aErro[8]), Replicate("*", Len(aErro[8]))) + ']' + CRLF, Nil) // "Valor informado:           "
	EndIf

	If nTamVet >= 9
		Iif(lInfValor, cRet += STR0078 + ' [' + IIF(!lOfuscate .or. Empty(aErro[9]), AllToChar(aErro[9]), Replicate("*", Len(aErro[9]))) + ']' + CRLF, Nil) // "Valor anterior:            "
	EndIf

	cRet += CRLF + Replicate('-', 78) + CRLF

	If !Empty(aMaster)
		cRet += STR0079 + CRLF //"Dados Informados: "
		cRet += Replicate('-', 78) + CRLF
		cRet += JuraDataStr(aMaster)
		cRet += Replicate('-', 78) + CRLF
	EndIf

	If !Empty(aDetail)
		For nI := 1 To Len(aDetail)
			cRet += STR0081 + CRLF //"Dados Informados Itens: "
			cRet += Replicate('-', 78) + CRLF
			cRet += JuraDataStr(aDetail[nI])
		Next nI
		cRet += Replicate('-', 78) + CRLF
	EndIf

	If lGravLog
		AutoGrLog(cRet)
	EndIf

	If lGravLog .And. lShowTela
		MostraErro()
	EndIf

	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JuraDataStr()
transforma informação de array de campos sem formato texto
@param aDados Array com informação de campos
          [n][1] Nome do campo
          [n][2] informação

@return cRet  Retorna informação formatada em formato de texto

@author Luciano Pereira dos Santos
@since 04/02/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function JuraDataStr(aDados , lCabec)
	Local nI    := 0
	Local cRet  := ""
	Local cCpo  := ""
	Local cPic  := ""
	Local cData := ""

	Default aDados := {}
	Default lCabec := .F.

	If lCabec .And. Len(aDados)
		cRet += STR0079 + CRLF //"Dados Informados: "
		cRet += Replicate('-', 78) + CRLF
	EndIf

	For nI := 1 to Len(aDados)
		cCpo := aDados[nI][1]
		cPic := X3Picture(cCpo)
		If!Empty(cPic)
			cData := Alltrim(Transform(aDados[nI][2], cPic))
		Else
			cData := Alltrim(aDados[nI][2])
		EndIf
		cRet += STR0106 + cCpo + CRLF + STR0162 + RetTitle(cCpo) + CRLF + STR0163 + cData + CRLF + CRLF  //#"Campo: " ##"Título: " ###"Conteúdo: "
	Next nI

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JChkArray
Valida a informação do array de erro do modelo para a rotina
JurShowErro() e JurModErro().
@param aErro  Array de erro do modelo
@param nPos   Posição a ser validada

@return lRet  .T. Se a informação for valida

@author Luciano Pereira dos Santos
@since 30/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JChkArray(aErro, nPos)
	Local nTam    := 0
	Local lRet    := .F.

	Default aErro := {}
	Default nPos  := 1

	nTam := Len(aErro)

	If (nTam >= nPos)
		lRet := !(Empty(aErro[nPos]) .Or. AllToChar(aErro[nPos]) == CRLF)
	EndIf

	If (nPos == 1) .Or. (nPos == 2) //Desabilita a informação se a origem e erro forem as mesmas
		If nTam >= nPos + 2
			lRet := (aErro[nPos] != aErro[nPos + 2])
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurModErro
Baseada na JurShowErro, trata o array de erro do modelo devolvendo uma
string tratada para ser usada com a JurMsgErro
Uso Geral.

@param 	oModelo     Modelo de dados
@param 	lShowTela   Exibe ou nao na tela

@Return cRet       String tratada com o erro do modelo

@author Luciano Pereira dos Santos
@since 01/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurModErro(oModel, lShowTela)
	Local aArea       := GetArea()
	Local aErro       := oModel:GetErrorMessage()
	Local cRet        := ''
	Local cDescr      := ''
	Local cModelId    := ''
	Local cCampo      := ''
	Local cDesCpo     := ''
	Local cSolucao    := ''
	Local lOfuscate   := _lFwPDCanUse .And. FwPDCanUse(.T.) .And. nModulo == 77 .And. !Iif(FindFunction("JPDUserAc"), JPDUserAc(), FwProtectedDataUtil():UsrPersonAccessPD() .And. FwProtectedDataUtil():UsrSensiAccessPD() ) //Somente ofusca para pfs

	Default lShowTela := .F.

	If JChkArray(aErro, 6)
		cRet += aErro[6] + CRLF //[6] mensagem do erro
	EndIf

	If JChkArray(aErro, 7)
		If !lShowTela
			cRet += STR0147 + aErro[7] + CRLF // "Solução: "
		Else
			cSolucao := aErro[7]
		EndIf
	EndIf

	If JChkArray(aErro, 3)
		If oModel:ClassName() == 'FWFORMMODEL'
			cDescr   := AllTrim(oModel:GetDescription())
		Else
			cModelId := AllTrim(AllToChar(aErro[3]))
			cDescr   := AllTrim(oModel:GetModel(cModelId):GetDescription())
		EndIf
		cRet     += I18N(STR0148, {"'"+cDescr+"'"}) + CRLF // "Formulário: #1"
	EndIf

	If JChkArray(aErro, 4)
		cCampo   := AllTrim(AllToChar(aErro[4]))
		cDesCpo  := AllTrim(RetTitle(cCampo))
		cRet     += I18N(STR0149, {"'"+cDesCpo+"'"} )+ CRLF // "Campo: #1"
	EndIf

	If JChkArray(aErro, 5)
		cRet += I18N(STR0150, {"'"+AllToChar( aErro[5]+"'" )})+ CRLF // "Origem : #1"
	EndIf


	If lOfuscate .And. JChkArray(aErro, 8) .Or. JChkArray(aErro, 9) .And. !Empty(aErro[4])
		lOfuscate := Len(FwProtectedDataUtil():UsrNoAccessFieldsInList({aErro[4]})) > 0
	EndIf


	If JChkArray(aErro, 8)
		cRet += STR0077 +"'"+  IIF(!lOfuscate .Or. Empty(aErro[8]), AllToChar(aErro[8]), Replicate("*", Len(aErro[8])))+"'"+ CRLF // "Valor informado:           "
	EndIf

	If JChkArray(aErro, 9)
		cRet += STR0078 +"'"+ IIF(!lOfuscate .Or. Empty(aErro[9]), AllToChar(aErro[9]), Replicate("*", Len(aErro[9]))) + "'" + CRLF // "Valor anterior:            "
	EndIf

	RestArea( aArea )

	If lShowTela
		JurMsgErro(cRet, , cSolucao, .F.)
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSpell
Executa o corretor ortografico para um campo texto.
Uso Geral.

@param 	oCampo		Objeto de tela refenrente ao campo
@param 	cTexto		Texto para ser verificada a coreção ortogrÃ¡fica.
@param 	cDll		DLL a ser utilizada. Default 'SIGAADDICT.DLL'
@param 	lShowMsg	Exibe ou não as mensagens de erro

@return	lRet		Encontrou oou não erros na execução

@sample
Define MsDialog oDlg Title 'Teste do Corretor OrtogrÃ¡fico' From 178, 181 To 548, 717 Pixel

@ 002, 002 Get oMemo Var cMemo Memo Size 220, 180 Pixel Of oDlg
@ 002, 226 Button 'Corrigir' Size 037, 012 Pixel Of oDlg  Action JurSpell( oMemo, @cMemo )

Activate MsDialog oDlg Centered

Return NIL

@author Ernani Forastieri
@since 01/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSpell( oCampo, cTexto, cDll, lShowMsg )
	Local   nHandle    := -1
	Local   lRet       := .T.
	Local   cPassagem  := ''
	Local   nRet       := 0

	ParamType 0 Var oCampo     As Object	 	Optional
	ParamType 1 Var cTexto     As Character		Optional Default ''
	ParamType 2 Var cDll       As Character 	Optional Default 'SIGAADDICT.DLL'
	ParamType 3 Var lShowMsg   As Logical   	Optional Default .T.

	If ValType( cTexto ) == 'C' .AND. !Empty( cTexto ) .AND. !( GetRemoteType() == 2) // Nao e remote em LINUX

		If ( lRet := SuperGetMV( 'MV_JURSPEL',, .T. ) )

			nHandle := ExecInDLLOpen( cDll )

			If ( lRet := !( nHandle < 0 ) )

				cPassagem := Padr( cTexto, 4095 )
				nRet := ExeDLLRun2( nHandle, 1, @cPassagem )

				If ( lRet := !( nRet < 0 ) )
					cTexto := AllTrim( cPassagem )

					ExecInDllClose( nHandle )

					If oCampo <> NIL
						oCampo:Refresh()
					EndIf

				Else
					If lShowMsg
						JurMsgErro( STR0030 ) // "Erro de CheckSpell com a DLL de Corretor OrtogrÃ¡fico."
					EndIf

				EndIf

			Else
				If lShowMsg
					JurMsgErro( STR0031 + CRLF + STR0032 + cDLL ) // "Erro de conexão com a DLL de Corretor OrtogrÃ¡fico."###"Verifique se a existe a DLL "
				EndIf

			EndIf

		Else
			If lShowMsg
				JurMsgErro( STR0033 ) // "Correcão ortogrÃ¡fica estÃ¡ desabilitada. Verifique o parÃ¢metro MV_JURSPEL"
			EndIf

		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVet2Aut
Executa a ordenacao de um vetor conforme os campos do SX3
Uso Geral.

@param 	aVetor		Vetor a ser ordenado
@param 	cTabela		Tabela a que se refere os campos do vetor
@param 	lItens		O Vetor é ou não de itens de uma rotina automatica
@param 	nColCampo	Posicao do vetor que contem os nomes de campos

@Return	aRet		Vetor ordenado

@sample
aVetor := {}

aAdd( aVetor, { 'A1_LOJA'  , '01'            , NIL } )
aAdd( aVetor, { 'A1_COD'   , '000001'        , NIL } )
aAdd( aVetor, { 'A1_FILIAL', xFilial( 'SA1' ) , NIL } )

aVetor := JurVet2Aut( aVetor, 'SA1' ) )

// Retorna o aVetor na ordem A1_FILIAL, A1_COD, A1_LOJA

Return NIL

@author Ernani Forastieri
@since 01/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurVet2Aut( aVetor, cTabela, lItens, nColCampo )
	Local aArea     := GetArea()
	Local aAreaSX3  := SX3->( GetArea() )
	Local aStrSX3   := {}
	Local aStrSX3SF := {}
	Local aRet      := {}
	Local aAux      := {}
	Local nI        := 0
	Local nJ        := 0

	ParamType 0 Var aVetor     As Array
	ParamType 1 Var cTabela    As Character Optional Default Alias()
	ParamType 2 Var lItens     As Logical   Optional Default .F.
	ParamType 3 Var nColCampo  As Numeric   Optional Default 1

	SX3->( dbSetOrder( 4 ) )

	If cTabela == NIL
		cTabela := SubStr( aVetor[1][nColCampo], 1, At( '_', aVetor[1][nColCampo] ) - 1 )
		cTabela := IIf( Len( cTabela ) == 2, 'S' + cTabela, cTabela )
	EndIf

	SX3->( dbSeek( cTabela ) )

	While !SX3->( Eof () ) .AND. SX3->X3_ARQUIVO == cTabela

		If Empty( SX3->X3_FOLDER )
			aAdd( aStrSX3SF,  SX3->X3_CAMPO )
		Else
			aAdd( aStrSX3  ,  SX3->X3_CAMPO )
		EndIf

		SX3->( dbSkip() )
	EndDo

	aEVal( aStrSX3SF, { | x | aAdd( aStrSX3 , x ) } )

	If lItens
		//
		// Faz a classificacao de um vetor de "itens"
		//
		For nI := 1 To Len( aVetor )

			aAux := {}

			For nJ := 1 To Len( aStrSX3 )

				If ( nPos := aScan( aVetor[nI], { | x | RTrim( aStrSX3[nJ] ) == RTrim( x[nColCampo] ) } ) ) <> 0
					aAdd( aAux, aVetor[nI][nPos] )
				EndIf

			Next

			aEval( aVetor, { |x,y| IIf( Left( x[nColCampo], 3 ) == 'AUT', aAdd( aAux, x ), )})

			aAdd( aRet, aAux )

		Next

	Else
		//
		// Faz a classificacao de um vetor simples ou de "cabecalho"
		//
		aAux := {}

		For nJ := 1 To Len( aStrSX3 )

			If ( nPos := aScan( aVetor, { | x | RTrim( aStrSX3[nJ] ) == RTrim( x[nColCampo] ) } ) ) <> 0
				aAdd( aAux, aVetor[nPos] )
			EndIf

		Next

		aEval( aVetor, { |x| IIf( Left( x[nColCampo], 3 ) == 'AUT', aAdd( aAux, x ), )})

		aRet := aClone( aAux )

	EndIf

	RestArea( aAreaSX3 )
	RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCalcRef
Executa somas e subtracoes de quantidade de meses em dados de formato ano/mes
Uso Geral.

@param 	cAnoMes		Referencia ano/mes no formato AAAAMM
@param 	nQtdMeses	Quantidade de meses a ser somado ou subtraido
@param 	nSomaSub	Operacao: 1=Soma, 2=Subtrai

@Return	cRet		Nova referencia ano/mes

@sample
cAnoMes    := '200908'

cNewAnoMes := JurCalcRef( cAnomes, 3 )
// Retorna '200911'

Alert( cNewAnoMes )

Return NIL

@author Ernani Forastieri
@since 01/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurCalcRef( cAnoMes, nQtdMeses, nSomaSub )
	Local cRet := ''
	Local nI   := 0
	Local nAno := 0
	Local nMes := 0

	ParamType 0 Var cAnoMes    As Character Optional Default SubStr( DToS( dDataBase ), 1, 6 )
	ParamType 1 Var nQtdMeses  As Numeric   Optional Default 1
	ParamType 2 Var nSomaSub   As Numeric   Optional Default 1

	nAno := Val(  Left( cAnoMes, 4 ) )
	nMes := Val( Right( cAnoMes, 2 ) )

	If     nSomaSub == 1  // Soma Meses

		For nI := 1 To nQtdMeses
			nMes++

			If nMes == 13
				nMes := 1
				nAno++
			EndIf
		Next

	ElseIf nSomaSub == 2  // Subtrai Meses

		For nI := nQtdMeses To 1 Step -1
			nMes--

			If nMes == 0
				nMes := 12
				nAno--
			EndIf

		Next

	EndIf

	cRet := StrZero( nAno, 4 ) + StrZero( nMes, 2 )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurPrxData
Executa somas e subtracoes em datas com unidades de dias, meses ou anos
Uso Geral.

@param 	dData		Data de Referencia
@param 	nQuant		Quantidade a ser somado ou subtraido
@param 	nUnidade	Unidade: A=Anos, M=Meses, D=Dias
@param 	nSomaSub	Operacao: 1=Soma, 2=Subtrai

@Return	dRet		Nova Data

@sample

dVar := JurPrxData()
// Retorna o dDataDase somado de um mes

dVar := JurPrxData( CToD( '31/07/09' ) )
// Retorna 31/08/09

dVar := JurPrxData( CToD( '31/08/09' ) )
// Retorna 30/09/09

dVar := JurPrxData( CToD( '31/08/09' ) ,  1, 'A'    )
// Retorna 31/08/10

dVar := JurPrxData( CToD( '30/06/09' ) ,  2         )
// Retorna 30/08/09

dVar := JurPrxData( CToD( '29/02/04' ) ,  2, 'A'    )
// Retorna 28/02/06

dVar := JurPrxData( CToD( '28/02/06' ) ,  2, 'A', 2 )
// Retorna 28/02/04

@author Ernani Forastieri
@since 01/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurPrxData( dData, nQuant, cUnidade, nSomaSub )
	Local dRet       := ''
	Local cNewAnoMes := ''
	Local cAnoNovo   := ''
	Local cMesNovo   := ''
	Local dUltDiaMes := CToD( '  /  /  '  )

	ParamType 0 Var dData      As Date      Optional Default dDataBase
	ParamType 1 Var nQuant     As Numeric   Optional Default 1
	ParamType 2 Var cUnidade   As Character Optional Default 'M'
	ParamType 3 Var nSomaSub   As Numeric   Optional Default 1

	dRet     := dData
	cUnidade := Upper( cUnidade )

	If     cUnidade == 'M' .OR. cUnidade == 'A'

		cNewAnoMes  := JurCalcRef( SubStr( DToS( dData ) , 1, 6 ), IIf( cUnidade == 'M', nQuant, nQuant * 12 ), nSomaSub )
		cAnoNovo    := Left(  cNewAnoMes, 4 )
		cMesNovo    := Right( cNewAnoMes, 2 )
		dUltDiaMes  := LastDay( CToD( '01/' + cMesNovo + '/' + cAnoNovo ) )

		If Day( dData ) > Day( dUltDiaMes )
			dRet := dUltDiaMes
		Else
			dRet := SToD( cAnoNovo + cMesNovo + StrZero( Day( dData ), 2 ) )
		EndIf

	ElseIf cUnidade == 'D'
		dRet := dData + IIf( nSomaSub == 1, nQuant, nQuant * -1 )

	EndIf

Return dRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURF3SX3
Função genérica para montagem de tela de consulta padrao para campos do sistema
Uso Geral.

@param 	cFiltro 	    Filtro para a consulta
@sample JURF3SX3( "X3_ARQUIVO =='SA1'" )
@author Ernani Forastieri
@since 01/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURF3SX3( cFiltro )
	Local aArea      := GetArea()
	Local lRet       := .F.
	Local oMain      := Nil
	Local oMainPanel := Nil
	Local oPanelBrw  := Nil
	Local oBrowse    := Nil
	Local oColumn1   := Nil
	Local oColumn2   := Nil
	Local oColumn3   := Nil
	Local oColumn4   := Nil
	Local cFilterDef := ""

	ParamType 0 Var cFiltro  As Character Optional Default ''

	If Select( 'JURSX3' ) == 0
		OpenSxs(,,,,cEmpAnt, "JURSX3", "SX3",, .F., .T., .T., .T.)
	EndIf

	If Select('JURSX3') > 0

		cFilterDef := JURSX3->(DBFilter())

		If (cFiltro != cFilterDef)
			JURSX3->( dbClearFilter() )
			JURSX3->(dbSetFilter({|| &(cFiltro)}, cFiltro))
		EndIf

		oModal := FWDialogModal():New()
		oModal:SetFreeArea(420, 180)
		oModal:SetEscClose(.T.)
		oModal:SetTitle(STR0089 ) //"Consulta Padrão - Campos do Sistema"

		oModal:createDialog()
		oModal:addOkButton({|| ( lRet := .T., oModal:oOwner:End() ) })
		oModal:addCloseButton({|| ( lRet := .F., oModal:oOwner:End() ) })

		oMain := oModal:GetPanelMain()
		oMainPanel := TPanel():Create(oMain, 02,,,,,,, /*CLR_RED*/,, 20)
		oMainPanel:Align := CONTROL_ALIGN_TOP

		oPanelBrw := TPanel():Create(oMain, 02,,,,,,, /*CLR_BLUE*/)
		oPanelBrw:Align := CONTROL_ALIGN_ALLCLIENT

		Define FWBrowse oBrowse DATA TABLE ALIAS 'JURSX3' NO LOCATE  NO CONFIG  NO REPORT ;
		DOUBLECLICK { || lRet := .T., oModal:oOwner:End() } Of oPanelBrw
	ADD COLUMN oColumn1 DATA { || JURSX3->X3_CAMPO } Title STR0090 Size Len( JURSX3->X3_CAMPO ) Of oBrowse // "Campo"
	If __Language == 'PORTUGUESE'
		ADD COLUMN oColumn2  DATA { || JURSX3->X3_DESCRIC } Title STR0091 Size Len( JURSX3->X3_DESCRIC ) Of oBrowse // "Descrição"
	ElseIf __Language == 'ENGLISH'
		ADD COLUMN oColumn2  DATA { || JURSX3->X3_DESCENG } Title STR0091 Size Len( JURSX3->X3_DESCENG ) Of oBrowse // "Descrição"
	ElseIf __Language == 'SPANISH'
		ADD COLUMN oColumn2  DATA { || JURSX3->X3_DESCSPA } Title STR0091 Size Len( JURSX3->X3_DESCSPA ) Of oBrowse // "Descrição"
	EndIf
	ADD COLUMN oColumn3 DATA { || JURSX3->X3_ARQUIVO }  Title STR0092  Size Len( JURSX3->X3_ARQUIVO ) Of oBrowse // "Tabela"
	ADD COLUMN oColumn4 DATA { || IIf(JURSX3->X3_CONTEXT == 'V', STR0093, STR0094 ) } Title STR0095 Size 10 Of oBrowse // "Virtual"###"Real"###"Contexto"

	oBrowse:Activate()
	oModal:Activate()

	RestArea( aArea )

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurQtdReg
Função genérica para contagem de registros de uma tabela do sistema. Apenas para TOP
Uso Geral.

@param 	cTabela 	    Tabela de Referencia
@param 	cFiltro 	    Filtro para contagem em sintaxe SQL
@param 	lDeletados 	    Conta tambem os deletados da tabela
@param 	lSoFilial 	    Conta apenas a filial
@param 	cEmpr    	    Empresa da tabela de referencia
@param 	cFil    	    Filial  da tabela de referencia

@sample JurQtdReg( 'NQ1', "NQ1_TIPO = '3'" )

@author Ernani Forastieri
@since 01/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurQtdReg( cTabela, cFiltro, lDeletados, lSoFilial, cEmpr, cFil )
	Local nRet   := 0
	Local cQuery := ''
	Local cTmp   := ''
	Local aArea  := GetArea()

	ParamType 0 Var cTabela    As Character Optional Default Alias()
	ParamType 1 Var cFiltro    As Character Optional Default ''
	ParamType 2 Var lDeletados As Logical   Optional Default .F.
	ParamType 3 Var lSoFilial  As Character Optional Default .T.
	ParamType 4 Var cEmpr      As Character Optional Default ''
	ParamType 5 Var cFil       As Character Optional Default xFilial( cTabela )

	cTabela := Upper( cTabela )

	cQuery := "SELECT COUNT(*) QTDREG FROM " + IIf( Empty( cEmpr ), RetSQLName( cTabela ), cTabela + cEmpr + '0' )
	cQuery += " WHERE 1 = 1 "

	If lSoFilial
		cQuery += "   AND " + PrefixoCpo( cTabela ) + "_FILIAL = '" + cFil + "' "
	EndIf

	If !Empty( cFiltro )
		cQuery += "   AND " + cFiltro
	EndIf

	If !lDeletados
		cQuery += "   AND D_E_L_E_T_ = ' ' "
	EndIf

	cTmp  := GetNextAlias()

	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cTmp, .T., .F. )

	nRet := (cTmp)->QTDREG

	(cTmp)->( dbCloseArea() )

	RestArea( aArea )

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURSETXVAR
Guarda os valores de um array para utilização posterior
Uso Geral.

@Param xConteudo	 	Array de valores

@author Juliana Iwayama Velho
@since 06/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURSETXVAR( xConteudo )
	xVarPassag := xConteudo
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JURGETXVAR
Retorna o valor guardado na variÃ¡vel
Uso Geral.

@Return xVarPassag	 	ConteÃºdo de valores

@author Juliana Iwayama Velho
@since 06/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURGETXVAR()
Return xVarPassag

//-------------------------------------------------------------------
/*/{Protheus.doc} JURCLEXVAR
Limpa o conteÃºdo da variavel
Uso Geral.

@author Juliana Iwayama Velho
@since 06/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURCLEXVAR()
	xVarPassag := NIL
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JurAtAll
Retorna vetor com todas os posicoes de ocorrencia de uma string dentro da outra
Uso Geral.

@param 	cCarac 	    	Caracter ou cadeia de caracteres a ser(em) pesquisado(s)
@param 	cString 	    String onde se deseja pesquisar

@sample
aPosicoes := JurAtAll( 'A', 'AMANHA DE MANHA' )
// Retorna { 1, 3, 6, 12, 15 }

@author Ernani Forastieri
@since 01/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurAtAll( cCarac, cString )
	Local aRet    := {}
	Local nPos    := 0
	Local nPosIni := 1

	ParamType 0 Var cCarac     As Character Optional Default ''
	ParamType 1 Var cString    As Character Optional Default ''

	While ( nPos := At( cCarac, cString, nPosIni ) ) > 0
		aAdd( aRet, nPos )
		nPosIni := nPos + 1
	EndDo

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURRELASX9
Retorna Array com as tabelas relacionadas.
Uso Geral.

@param 	cTabela			Tabela de Referencia
@param 	lDescricao 		Indica se as tabelas terão a descrição junto entre parentesÃªs

@Return aRet	 		Tabelas relacionadas a tabela de referencia

@author Felipe Bonvicini Conti
@since 10/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURRELASX9(cTabela, lDescricao, cTipoRel)
	Local aRet := {}

	ParamType 2 Var cTipoRel As Numeric Optional Default 1

	Default lDescricao := .T.

	If lDescricao
		aAdd(aRet, cTabela+' ('+AllTrim(JA023TIT(cTabela))+')')
	Else
		aAdd(aRet, cTabela)
	EndIF

	SX9->(dbsetorder(cTipoRel))

	IF SX9->(DBSeek(cTabela))

		If cTipoRel == 1

			While !(SX9->(Eof())) .And. (SX9->X9_DOM == cTabela)
				If lDescricao
					aAdd(aRet, SX9->X9_CDOM+' ('+AllTrim(JA023TIT(SX9->X9_CDOM))+')')
				Else
					aAdd(aRet, SX9->X9_CDOM)
				EndIF
				SX9->(dbSkip())
			EndDo

		ElseIf cTipoRel == 2

			While !(SX9->(Eof())) .And. (SX9->X9_CDOM == cTabela)
				If lDescricao
					aAdd(aRet, SX9->X9_DOM+' ('+ AllTrim(JA023TIT(SX9->X9_DOM))+')')
				Else
					aAdd(aRet, SX9->X9_DOM)
				EndIF
				SX9->(dbSkip())
			EndDo

		EndIf

	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURUSUARIO
Retorna o codigo do participante relacionado ao codigo do usuÃ¡rio logado
Uso Geral.

@param 	cUserID		Codigo do usuÃ¡rio logado
@Return cUser			Codigo do Participante relacionado

@author Felipe Bonvicini Conti
@since 14/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurUsuario(cUserID)
	Local cUser
	Local aArea    := GetArea()
	Local cAliasQry := nil
	Local cQuery := ""

	cQuery := " SELECT RD0_CODIGO "
	cQuery += " FROM " + RetSqlName("RD0") + " RD0 "
	cQuery += " WHERE RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cQuery += " AND RD0.RD0_USER = '" + cUserID + "' "
	cQuery += " AND RD0.D_E_L_E_T_ = ' ' "

	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry, .T., .F. )

	cUser := (cAliasQry)->RD0_CODIGO

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

Return cUser

//-------------------------------------------------------------------
/*/{Protheus.doc} JurChkPK
Verifica se existe a ja existe a chave unica na tabela com os dados do Model
Uso Geral.

@param 	cTabela			Tabela de Referencia
@param 	oModel	 		Objeto do Modelo de dados

@sample
Local oModel := FWModelActive()

	If !JurChkPK( 'NTZ', oModel )
	HELP( " ",1,"JAGRAVADO" )
	EndIf

@author Ernani Forastieri
@since 01/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurChkPK( cTabela, oModel, nRecno )
	Local lRet       := .T.
	Local aArea      := GetArea()
	Local aPK        := {}
	Local cQuery     := ''
	Local nI         := 0
	Local cTmp       := ''
	Local nOperation := 0

	ParamType 0 Var cTabela    As Character Optional Default Alias()
	ParamType 1 Var oModel     As Object    Optional Default FWModelActive()
	ParamType 2 Var nRecno     As Numeric   Optional Default Recno()

	nOperation := oModel:GetOperation()

	aPK := StrToArray(FWX2Unico(cTabela), '+' )

	If !Empty( aPK )

		cQuery :="SELECT 'X' FROM " + RetSqlName( cTabela )
		cQuery +=" WHERE "
		For nI := 1 To Len( aPK )
			cQuery += IIf( nI == 1, "", " AND ") + aPK[nI]  + " = " + ;
				JurCpo2Qry( IIf( '_FILIAL' $ aPK[nI], xFilial( cTabela ), FwFldGet( aPK[nI] ) ) )
		Next
		If nOperation <> MODEL_OPERATION_INSERT
			cQuery +=" AND R_E_C_N_O_ <> " + Str( nRecno) + " "
		EndIf
		cQuery +=" AND D_E_L_E_T_ = ' '"

		cTmp  := GetNextAlias()
		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cTmp, .F., .T. )
		lRet := (cTmp)->( EOF() )
		(cTmp)->( dbCloseArea() )

	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCpo2Qry
Monta o conteudo passado para ser usado em clausulas SQL
Uso Geral.

@param 	uVar			Conteudo a ser Tratado

@author Ernani Forastieri
@since 01/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurCpo2Qry( uVar )
	Local cRet  := ''
	Local cTipo := ValType( uVar )
	Local uAux  := NIL

	If     cTipo == 'C'
		cRet := "'" + uVar + "'"

		If SubStr( cRet, 2, 1 ) == '#'
			cRet := SubStr( cRet, 3, Len( cRet ) - 3 )
		EndIf

	ElseIf cTipo == 'N'
		cRet := AllTrim( Str( uVar ) )

	ElseIf cTipo == 'D'
		cRet := "'" + DToS( uVar ) + "'"

	ElseIf cTipo == 'L'
		cRet := IIf( uVar, '.T.', '.F.' )

	ElseIf cTipo == 'A'
		cRet := "''"

	ElseIf cTipo == 'M'
		cRet := "''"

	ElseIf cTipo == 'B'
		uAux := EVal( uVar )
		cRet := JurCpo2Qry( uAux )

	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVinMoe(dDtMoeda, cMoeda)
Verifica se a data da moeda selecionada esta dentro de sua vigÃªncia
Uso Geral.
@param 	dDtInicio - Data selecionada pelo usuÃ¡rio
@param 	cMoeda    - CÃ³d. Moeda selecionada pelo usuÃ¡rio
@author ClÃ³vis Eduardo Teixeira
@since 14/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurVinMoe(dDtMoeda, cMoeda)
	Local lRet      	:= .T.
	Local dDtaInicio
	Local dDtaFim
	local cTmpMoed

	Default dDtMoeda	:= '00/00/0000'
	Default cMoeda		:= ''

	If ( ValType(dDtMoeda) <> 'D').OR.(ValType(cMoeda) <> 'C')
		lRet := .F.
		JurMsgErro(STR0124) //"Atenção: Favor verificar os parametros de entrada da função 'JurVinMoe'"
	ElseIf !EMPTY(cMoeda)

		cTmpMoed	:= JurGetDados("CTO",1,xFILIAL("CTO")+cMoeda, "CTO_MOEDA")
		dDtaInicio	:= JurGetDados("CTO",1,xFILIAL("CTO")+cMoeda, "CTO_DTINIC")
		dDtaFim	:= JurGetDados("CTO",1,xFILIAL("CTO")+cMoeda, "CTO_DTFINA")

		Do Case
		Case lRet.And.Empty(cTmpMoed ).And.Empty(dDtaInicio) .AND. Empty(dDtaFim)
			lRet := .F.
			JurMsgErro(STR0122)//"Moeda nã¯ encontrada."

		Case lRet.AND.!Empty(cTmpMoed).AND. Empty(dDtaInicio) .AND. !Empty(dDtaFim)
			//"A moeda escolhida nã¯ possui data de inicio de vigê®£ia cadastrada, poré­ a data final esta preenchida. Por Favor, verifique."
			JurMsgErro(STR0123)
			lRet := .F.

		Case lRet.AND.!Empty(cTmpMoed).AND.!Empty(dDtaInicio).AND.(dDtMoeda < dDtaInicio)
			JurMsgErro(STR0097 + DToC(dDtaInicio)) //Para essa moeda, a data deve ser maior que
			lRet := .F.

		Case lRet.AND.!Empty(cTmpMoed).AND.!Empty(dDtaFim).AND.(dDtMoeda > dDtaFim)
			JurMsgErro(STR0098 + DToC(dDtaFim)) //Para essa moeda, a data deve ser menor que
			lRet := .F.

		End Case
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIsOpera
Retorna True se a Operacao passada for a mesma do model.
Uso Geral.

@param 	nOperation		Operacao a ser verificada.

@author Felipe Bonvicini Conti
@since 24/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurIsOpera(nOperation)
	Local oModel := FWModelActive()
	Local lRet   := .F.

	If oModel <> NIL
		lRet := ( oModel:GetOperation() == nOperation )
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIsInc
Retorna True se o model esstiver como Inclusão.
Uso Geral.

@param 	nOperation		Operacao a ser verificada.

@author Felipe Bonvicini Conti
@since 24/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurIsInc()
Return  JurIsOpera( MODEL_OPERATION_INSERT )

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIsAlt
Retorna True se o model esstiver como Alteração.
Uso Geral.

@param 	nOperation		Operacao a ser verificada.

@author Felipe Bonvicini Conti
@since 24/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurIsAlt()
Return JurIsOpera( MODEL_OPERATION_UPDATE )

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIsExc
Retorna True se o model esstiver como Exclusão.
Uso Geral.

@param 	nOperation		Operacao a ser verificada.

@author Felipe Bonvicini Conti
@since 24/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurIsExc()
Return JurIsOpera( MODEL_OPERATION_DELETE )

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIsAdmin
Verifica se o usuario é administrador ou pertence ao grupo
Uso Geral.

@param 	cUser			Codigo de usuario, se nao for informado usara o corrente

@sample
	If JurIsAdmin()
	JurMsgOk( 'Usuario é administrador.' )
	EndIf

@author Ernani Forastieri
@since 01/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurIsAdmin( cUser )
	Local lRet    := .F.
	Local aGrupos := {}

	ParamType 0 Var cUser      As Character Optional Default __cUserID

// Se a senha for do ADMINISTRADOR ou o usuario pertencer
// ao grupo de administradores
	If cUser == '000000'
		lRet := .T.

	Else
		//
		// Para verificar se faz parte do grupo de administradores
		//
		PswOrder( 1 )

		If PswSeek( cUser )

			aGrupos := Pswret( 1 )

			If aScan( aGrupos[1][10], '000000' ) <> 0
				lRet := .T.
			EndIf

		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURVALCT
Função genérica para verificar se o campo digitado pertence a tabela
Uso Geral.

@param 	cCampo 	    Nome do campo
@param 	cTabela 	Nome do campo de tabela

@Return lRet	 	.T./.F. As informaçÃµes são vÃ¡lidas ou não

@author Juliana Iwayama Velho
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURVALCT( cCampo , cCampoTab )
	Local aArea	:= GetArea()
	Local aAreaSX3:= SX3->( GetArea() )
	Local lRet		:= .T.
	Local cTabela	:= FwFldGet( cCampoTab )

	cCampo := Alltrim( cCampo )

	SX3->( dbSetOrder( 2 ) )
	SX3->( dbSeek( cCampo ) )

	If !SX3->( EOF() ) .AND. SX3->X3_ARQUIVO <> cTabela
		lRet := .F.
		JurMsgErro( STR0099 )
	EndIf

	RestArea( aAreaSX3 )
	RestArea( aArea    )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AtoC
Transforma um array de uma dimensão em uma string.
Uso Geral.

@param 		aArray		Array.
@param 		cSepara		Caracter de separação.
@Return		cRet		  String com os dados do array.

@author Felipe Bonvicini Conti
@since 19/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function AtoC(aArray, cSepara)
	Local nQtd := Len(aArray), cRet := ""
	Local cTipo := "", cValor := ""
	Local nI

	Default cSepara := ", "

	For nI := 1 to nQtd

		cTipo := ValType(aArray[nI])
		Do case
		Case cTipo == 'D'
			cValor := DToC(aArray[nI])
		Case cTipo == 'N'
			cValor := STR(aArray[nI])
		Case cTipo == 'C' .Or. cTipo == 'M'
			cValor := aArray[nI]
		Otherwise
			cValor := ""
		EndCase

		If nI == 1
			cRet += cValor
		else
			cRet += cSepara + cValor
		EndIf

	Next

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURVLDSX2
Valida se a tabela B estÃ¡ relacionada com a A
Uso Geral.

@param 	cTabelaA 	Nome da tabela A
@param 	cTabelaB 	Nome da tabela B

@sample
JURVLDSX2(FwFldGet('NQ0_TABELA'), FwFldGet('NQ2_TABELA'))

@Return lRet	 	.T./.F. As informaçÃµes são vÃ¡lidas ou não

@author Juliana Iwayama Velho
@since 22/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURVLDSX2(cTabelaA, cTabelaB)
	Local aArea   := GetArea()
	Local aTabelas:= JURRELASX9(cTabelaA, .F.)
	Local lRet    := .F.
	Local nI, nJ

	For nJ:= 1 to 2

		For nI := 1 to LEN(aTabelas)

			If aTabelas[nI] == cTabelaB
				lRet := .T.
				Exit
			EndIf

		Next

		If !lRet
			aTabelas:= JURRELASX9(cTabelaA, .F.,2)
		EndIf

	Next

	If !lRet
		JurMsgErro(STR0101+" "+AllTrim( JA023TIT( cTabelaA)))
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURSX9
Verifica os relacionamento entre a Tabela 1 e 2
Uso Geral.

@param 	cTabela 	Nome da tabela 1
@param 	cTabela2 	Nome da tabela 2

@Return aRet	 	Array de campos do relacionamento

@author Juliana Iwayama Velho
@since 26/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURSX9(cTabela, cTabela2)
	Local aRet    := {}
	Local aArea   := GetArea()
	Local aAreaSX9:= SX9->(GetArea())

	SX9->(dbsetorder(1))

	If SX9->(DBSeek(cTabela))

		While !(SX9->(Eof())) .And. (SX9->X9_DOM == cTabela)

			If SX9->X9_CDOM == cTabela2
				aAdd(aRet, { SX9->X9_EXPDOM, SX9->X9_EXPCDOM, 1 })
			EndIf
			SX9->(dbSkip())
		EndDo

	EndIf

	If Empty (aRet)
		SX9->(dbsetorder(2))

		IF SX9->(DBSeek(cTabela))
			While !(SX9->(Eof())) .And. (SX9->X9_CDOM == cTabela)

				If SX9->X9_DOM == cTabela2
					aAdd(aRet, { SX9->X9_EXPDOM, SX9->X9_EXPCDOM, 2 })
				EndIf
				SX9->(dbSkip())
			EndDo
		EndIf

	EndIf

	RestArea( aAreaSX9 )
	RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JFindMdl
Função utilizada para buscar no model e trazer o valor de um campo
Uso Geral.

@param 	oModel 			Model
@param 	cCpoBusca 	Nome do campo que serÃ¡ buscado
@param 	cBusca			Valor a ser encontrado
@param aCampo      Array com os nomes dos campo de retorno

@Return aValor    Array com valor do campo

@author Felipe Bonvicini Conti
@since 28/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JFindMdl(oModel, cCpoBusca, cBusca, aCampos)
	Local nI   := 0
	Local nY   := 0
	Local nQtd := oModel:length()
	Local aValor := {}

	For nI := 1 to nQtd
		If !oModel:IsDeleted(nI) .And. oModel:GetValue(cCpoBusca, nI) == cBusca
			For nY := 1 to Len(aCampos)
				If aCampos[nY] == "POSICAO"
					aAdd(aValor, nI)
				ElseIf aCampos[nY] == "RECNO"
					aAdd(aValor, oModel:GetDataID(nI))
				Else
					aAdd(aValor, oModel:GetValue(aCampos[nY], nI))
				Endif
			Next
		EndIf
	Next

Return aValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JFindMdlM
Função utilizada para buscar no model e trazer o valor de um campo
utilizando macro substituição.
Uso Geral.

@param 	oModel 			Model
@param 	cCondicao		Condição para a macrosubstituição.
@param 	cCampo			Nome do campo de retorno

@Return cValor	 	Valor do campo

@author Felipe Bonvicini Conti
@since 28/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JFindMdlM(oModel, cCondicao, aCampos)
	Local aValor   := {}
	Local nI, nY, nQtd := oModel:length()
	Local nLinOld  := oModel:nLine

	For nI := 1 to nQtd
		oModel:GoLine(nI)

		If !oModel:IsDeleted(nI) .And. &(cCondicao)
			For nY := 1 to Len(aCampos)
				If aCampos[nY] == "POSICAO"
					aAdd(aValor, nI)
				Else
					aAdd(aValor, oModel:GetValue(aCampos[nY], nI))
				EndIf
			Next
		EndIf
	Next

	oModel:GoLine(nLinOld)

Return aValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JModelGoLn
Função utilizada para setar a linha no model

@author Felipe Bonvicini Conti
@since 11/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JModelGoLn(oModel, nLine)
	Local lRet := .F.
	lRet := oModel:GoLine(nLine) == nLine
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSQL
Função utilizada para rodar uma query e trazer o result em um array.

@param cSQL       - Query que será executada
@param xCamposRet - Campo(s) da tabela a ser retornado
@param lCommit    - Indica se será efetivada a alteração no banco
@param aReplace   - Array com os replaces para serem feitos após o changeQuery
                    [1] - Primeira parte do Replace
                    [2] - Segunda parte do Replace
@param lChangeQry - Indica se será executado o ChangeQuery

@return aValor    - Array com os valores retornados pela query

@author Felipe Bonvicini Conti
@since 05/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSQL(cSQL, xCamposRet, lCommit, aReplace, lChangeQry)
Local aValor   := {}
Local aArea    := GetArea()
Local cQry     := ""
Local cTmp     := ""
Local cAux     := ""
Local nI       := 1
Local nY       := 1
Local aFldPos  := {}
Local aStru    := {}
Local cType    := ""
Local nJ       := 0
Local cCpfCnpj := ""

Default cSQL       := ""
Default xCamposRet := {}
Default lCommit    := .T.
Default aReplace   := {}
Default lChangeQry := .T.

	If !Empty(cSQL) .And. !Empty(xCamposRet)

		If lCommit
			DbCommitAll() //Para efetivar a alteraï¿½ï¿½o no banco de dados (nï¿½o impacta no rollback da transaï¿½ï¿½o)
		EndIf

		If lChangeQry
			cQry  := ChangeQuery(cSQL)
		Else	
			cQry  := cSQL
		EndIf

		If Len(aReplace) > 0
			For nJ := 1 to Len(aReplace)
				cQry := StrTran(cQry, aReplace[nJ][1], aReplace[nJ][2])
			Next
		EndIf

		cTmp  := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ), cTmp, .T., .F. )

		cType := ValType(xCamposRet)

		If cType == "A" .And. LEN(xCamposRet) == 1 .And. xCamposRet[1] == "*" // Tratamento para aceitar tanto "*" como {"*"}
			xCamposRet := "*"
			cType      := "C"
		EndIf

		If cType == "C"
			If xCamposRet == "*"
				xCamposRet := {}
				aStru := (cTmp)->(dbStruct())
				For nI := 1 to Len(aStru)
					aAdd(xCamposRet, aStru[nI][DBS_NAME])
				Next
			else
				cAux := xCamposRet
				xCamposRet := {}
				aAdd(xCamposRet, cAux)
			EndIf
		EndIF
		aFldPos := Array(Len(xCamposRet))

		While !(cTmp)->(EOF())

			aAdd(aValor, {})
			For nI := 1 to Len(xCamposRet)
				If aFldPos[nI] == Nil
					aFldPos[nI] := (cTmp)->(FieldPos(xCamposRet[nI]))
				EndIf

				//-- Verifica se é o campo A1_CGC (CPF/CNPJ) e coloca a mascara
				If "A1_CGC" $ xCamposRet[nI]
					cCpfCnpj := JCpfCnpj( (cTmp)->(FieldGet(aFldPos[nI])) )
					aAdd( aValor[nY], cCpfCnpj )

				Else
					aAdd(aValor[nY], (cTmp)->(FieldGet(aFldPos[nI])))
				EndIf
			Next
			nY += 1
			(cTmp)->(dbSkip())

		EndDo

		(cTmp)->( dbCloseArea() )

	EndIf

	RestArea( aArea )

Return aValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIsEMail
Rotina para validar de formato de um e-mail
Uso Geral.

@param 	cEmail   	Email a ser validado

@sample

	If !JurIsEMail( 'fulano@dominio.com.br' )
	JurMsgErro( 'O e-mail parece não estar escrito num formato de e-mail vÃ¡lido.' )
	EndIf

@author Ernani Forastieri
@since 01/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurIsEMail( cEmail )
	Local aMails := {}
	Local cLit   := ' {}()<>[]|\/&*$ %?!^~`:=#'
	Local lRet   := .T.
	Local nResto := 0
	Local nI     := 0
	Local nJ     := 0
//Local nChar  := 0

	ParamType 0 Var cEmail    As Character

	cEmail := AllTrim( cEmail )
	cEmail := StrTran( cEmail , ",", ";")

	aMails := Str2Arr( cEmail , ";")

	For nJ := 1 To Len( aMails )
		For nI := 1 To Len( aMails[nJ] )
			If At( SubStr( aMails[nJ], nI, 1 ), cLit ) >  0
				lRet   := .F.
				Exit
			EndIf
		Next nI

		If lRet
			If ( nResto := At( '@', aMails[nJ] ) ) > 0 .AND. At( '@', Right( aMails[nJ], Len( aMails[nJ] ) - nResto ) ) == 0
				If ( nResto := At( '.', Right( aMails[nJ], nResto ) ) ) == 0
					lRet := .F.
				Else
					//			nChar := Asc( SubStr( aMails[nJ], RAt(  '.', aMails[nJ] ) + 1, 1 ) )
					//			If  !( ( nChar > 64 .AND. nChar < 91 ) .OR. ( nChar > 97 .AND. nChar < 122 ) )
					If !IsAlPha( SubStr( aMails[nJ], RAt(  '.', aMails[nJ] ) + 1, 1 ) )
						lRet := .F.
					EndIf
				EndIf
			Else
				lRet := .F.
			EndIf
		EndIf

		If !lRet
			Exit
		EndIf

	Next nJ

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVEMail
Rotina para validar de formato de um e-mail
Uso Geral.

@param 	cEmails   	Lista de Emails a serem validados separados por ";" ponto-e-virgula

@sample

JurValEMail( 'fulano@dominio.com.br;cicrano@dominio.com.br' )

@author Ernani Forastieri
@since 01/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurVEMail( cEmails, lShowMsg )
	Local lRet    := .T.
	Local aEmails := StrToArray( cEmails, ';' )
	Local nI      := 0

	ParamType 0 Var cEmails    As Character
	ParamType 1 Var lShowMsg   As Logical   Optional Default .T.


	For nI := 1 To Len( aEmails )
		If !JurIsEMail( aEmails[nI] )
			lRet := .F.
			If lShowMsg
				JurMsgErro( STR0102 + '"' + aEmails[nI] + '"' + STR0103 ) //"O e-mail "###" parece não estar escrito num formato de e-mail vÃ¡lido."
			EndIf
			Exit
		EndIf
	Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIN
Function utilizada para verificar se tal valor esta contido numa lista de valores.
Uso Geral.

@param 	Valor   	Valor a verificar se esta contido na lista.
@param 	aItens		Lista de valores.

@sample

JurIN( "A", {"A","B","C","D"} )

@author Felipe Bonvicini Conti
@since 18/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurIN(Valor, aItens)
	Local lRet 			:= .F.
	Local nQtdItens := Len(aItens)
	Local cTpValor  := ValType(Valor)
	Local cTpItens  := IIF(nQtdItens > 0, ValType(aItens[1]), "")
	Local nI

	If cTpValor == cTpItens
		For nI := 1 to nQtdItens
			If Valor == aItens[nI]
				lRet := .T.
				Exit
			EndIf
		Next
	Else
		JurMsgErro(STR0104) //"Tipos incompativeis!"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurUsrName
Função genérica para retornar o nome do usuÃ¡rio

@param 	cCodUser 	CÃ³digo do usuÃ¡rio

@return cName	 	Nome

@author Juliana Iwayama Velho
@since 23/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurUsrName(cCodUser)
	Local cName := Space(15)

	If !Empty(cCodUser)

		If cCodUser == "******"
			cName := "Todos"
		Else
			If PswSeek( cCodUser, .T. )
				cName := PswRet()[1][2]
			EndIf
		EndIf

	EndIf

Return cName

//-------------------------------------------------------------------
/*/{Protheus.doc} JURX3INFO
Função genérica para retornar informacoes do SX3

@param 	cCampo	 	Nome do campo
@param 	cInfo	 	Informacao a retornar

@author Wagner Manfre
@since 30/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURX3INFO( cCampo, cInfo )
	Local xRet      := ""
	Local aAreaSAV  := GetArea()
	Local aAreaSX3  := SX3->( GetArea() )
	Local nPos      := 0

	ParamType 0 Var cCampo    As Character Optional Default SX3->X3_CAMPO
	ParamType 1 Var cInfo     As Character Optional Default 'X3->X3_TITULO'

	dbSelectArea( "SX3" )
	dbSetOrder( 2 )

	If FieldPos( cInfo ) == 0
		cInfo := "X3_TITULO"
	EndIf
	cInfo := AllTrim(cInfo)

	nPos := aScan( __x3Cache, { |x| AllTrim( Upper( x[1] ) ) == AllTrim( Upper( cCampo ) ) .AND. ;
		AllTrim( Upper( x[2] ) ) == AllTrim( Upper( cInfo ) ) } )

	If nPos == 0

		If dbSeek( AllTrim( Upper( cCampo ) ) )

			Do Case
			Case cInfo == "X3_TITULO"
				xRet :=	AllTrim( X3Titulo() )

			Case cInfo == "X3_DESCRIC"
				xRet := AllTrim( X3Descric() )

			Case cInfo == "X3_CBOX"
				xRet := AllTrim( X3Cbox() )

			OtherWise
				cVar := cInfo
				xRet := SX3->&( cVar )

			End Case

			aAdd( __x3Cache, { cCampo, cInfo, xRet } )
			nPos := Len( __x3Cache )
		EndIf

	EndIf

	If nPos > 0
		xRet := __x3Cache[nPos][3]
	EndIf

	RestArea( aAreaSX3 )
	RestArea( aAreaSAV )

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurDtAdd
Função utilizada para adicionar ou subtrair dias, meses ou anos a uma data no formato System

@param 	cDate		Campo de data no formato YYYYMMDD.
@param 	cTipo		Tipo que serÃ¡ adicionado, "D", "M", "Y" ou "A"..
@param 	nQtd		Quantidade a ser adicionada ou subtraída.

@author Felipe Bonvicini Conti
@since 09/04/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurDtAdd( cDate, cTipo, nQtd )
	Local cRet := ''
	Local nI   := 0
	Local nDia
	Local nMes
	Local nAno

	Default cDate := DtoS(Date())
	Default cTipo := 'D'
	Default nQtd  := 0

	If ValType(cDate) == "D"
		cDate := DToS(cDate)
	EndIf
	nDia := Day(SToD(cDate))
	nMes := Month(STOD(cDate))
	nAno := Year(STOD(cDate))

	Do Case
	Case Upper(cTipo) == "D"
		nDia := Day(SToD(cDate) + nQtd)
		nMes := Month(STOD(cDate) + nQtd)
		nAno := Year(STOD(cDate) + nQtd)

	Case Upper(cTipo) == "M"
		For nI := 1 To ABS(nQtd)
			If nQtd > 0
				nMes++
			Else
				nMes--
			EndIf

			If nMes == 13
				nMes := 1
				nAno++
			EndIf
			If nMes == 0
				nMes := 12
				nAno--
			EndIf
		Next

	Case Upper(cTipo) == "Y" .Or. Upper(cTipo) == "A"
		nAno := nAno + nQtd

	EndCase

	cRet := StrZero(nAno, 4) + StrZero(nMes, 2) + StrZero(nDia, 2)

	While Empty(StoD(cRet))
		nDia--
		cRet := StrZero(nAno, 4) + StrZero(nMes, 2) + StrZero(nDia, 2)
	EndDo

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JSToFormat
Função utilizada para converter uma data no formato System para qualquer formato de data.
Ex: "YYYY-MM" ou "YYYY-MM-DD"

@author Felipe Bonvicini Conti
@since 09/04/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JSToFormat(cData, cFormat)
	Local cRet       := ""
	Local cLetra     := ""
	Local aFormatos  := {}
	Local cSeparador := ""
	Local nI, nAt

	Default cData   := DToS(Date())
	Default cFormat := "YYYY-MM"

	If ValType(cData) == "D"
		cData := DToS(cData)
	EndIf
	cFormat := Upper(cFormat)

	IIF (At( "-", cFormat ) > 0, cSeparador := "-", )
	IIF (At( "/", cFormat ) > 0, cSeparador := "/", )

	For nI := 1 to Len(cFormat)
		cLetra := SubStr(cFormat,nI,1)
		If !cLetra == cSeparador
			If (nAt := aScan(aFormatos, {|x| x[1] == cLetra})) == 0
				aAdd(aFormatos, {cLetra, 1, cSeparador})
			Else
				aFormatos[nAt][2] += 1
			EndIf
		EndIf
	Next

	For nI := 1 to Len(aFormatos)
		Do Case
		Case Upper(aFormatos[nI][1]) == 'D'
			cRet += StrZero(Day(SToD(cData)), aFormatos[nI][2]) + aFormatos[nI][3]
		Case Upper(aFormatos[nI][1]) == 'M'
			cRet += StrZero( Month(STOD(cData)), aFormatos[nI][2]) + aFormatos[nI][3]
		Case Upper(aFormatos[nI][1]) == 'Y'
			cRet += StrZero( Year(STOD(cData)), aFormatos[nI][2]) + aFormatos[nI][3]
		EndCase
	Next

	If SubStr(cRet,Len(cRet),1) == cSeparador
		cRet := SubStr(cRet,1, Len(cRet)-1)
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JbF3LookUp
Função utilizada para consulta padrão que tenha fonte feito a mão no MVC.

@author Felipe Bonvicini Conti
@since 23/06/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JbF3LookUp(cTable, oObj, cVar)
	Local oLkUp := __FWLookUp(cTable)

	oLkUp:SetRetFunc( { |x,y| LKRetSimp(x, y, @cVar) } )

	If oLkUp:Activate(cVar)
		oLkUp:ExecuteReturn(oObj)
		oObj:lModified := .T.
	EndIf

Return oLkUp:DeActivate()

//-------------------------------------------------------------------
/*/{Protheus.doc} LKRetSimp
Função utilizada para consulta padrão que tenha fonte feito a mão no MVC.

@author Felipe Bonvicini Conti
@since 23/06/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function LKRetSimp(oLookUp, oObj, cVar)
	Local oSXB     := oLookUp:GetCargo()
	Local aReturns := oSXB:GetReturnFields()
	Local xValue   := ''

	aEval( aReturns, { |x| xValue += Eval( & ( '{||' + x + '}' ) ) } )
	cVar := AllTrim( xValue )
	oObj:Refresh()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} LKRetSimp
Função utilizada para consulta padrão que tenha fonte feito a mão no MVC para retorno mÃºltiplo.

@author Felipe Bonvicini Conti
@since 23/06/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LKRetMult( oLookUp, oObj, cVar )
	Local oSXB     := oLookUp:GetCargo()
	Local aReturns := oSXB:GetReturnFields()
	Local xValue   := ''

	If !Empty(aReturns) .And. Len(aReturns) > 0
		xValue := Eval( & ( '{||' + aReturns[1] + '}' ) )
	EndIf
	cVar := AllTrim( cVar ) + AllTrim( xValue ) + ';'
	oObj:Refresh()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JbF3LUpMul
Função utilizada para consulta padrão que tenha fonte feito a mão no MVC para retorno multiplo

@author Felipe Bonvicini Conti
@since 23/06/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JbF3LUpMul(cTable, oObj, cVar)
	Local oLkUp := __FWLookUp(cTable)

	oLkUp:SetRetFunc( { |x,y| LKRetMult(x, y, @cVar) } )

	If oLkUp:Activate(cVar)
		oLkUp:ExecuteReturn(oObj)
		oObj:lModified := .T.
	EndIf

Return oLkUp:DeActivate()

//-------------------------------------------------------------------
/*/{Protheus.doc} JURF3CONT
Consulta Padrao de Contatos

@author Ernani Forastieri
@since 18/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURGetPag()
	Local oModel := FWModelActive()
	Local cChave := ""

	If oModel != Nil

		If oModel:GetId() $ 'JURA033|JURA202|JURA203'
			cChave := oModel:GetValue('NXGDETAIL','NXG_CLIPG') + oModel:GetValue('NXGDETAIL','NXG_LOJAPG')
		ElseIf oModel:GetId() == 'JURA204'
			cChave := oModel:GetValue('NXAMASTER','NXA_CLIPG') + oModel:GetValue('NXAMASTER','NXA_LOJPG')
		Else
			cChave := oModel:GetValue('NXPDETAIL','NXP_CLIPG') + oModel:GetValue('NXPDETAIL','NXP_LOJAPG')
		EndIf

	EndIf

Return cChave
//-------------------------------------------------------------------
/*/{Protheus.doc} JURF3CONT
Consulta Padrao de Contatos

@author Ernani Forastieri
@since 18/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURF3CONT( cEntidade, cChave, cFilter )
	Local lRet   := .F.
	Local aArea  := GetArea()
	Local cQuery := ""

	Default cEntidade := "SA1"
	Default cChave    := FwFldGet( 'NXP_CLIPG' ) + FwFldGet( 'NXP_LOJAPG' )
	Default cFilter   := "SU5.U5_ATIVO='1'"

	cQuery += "SELECT U5_CODCONT, U5_CONTAT,  SU5.R_E_C_N_O_ SU5RECNO FROM " + RetSqlName( 'SU5') + " SU5 "
	cQuery += " INNER JOIN " + RetSqlName( 'AC8') + " AC8 "
	cQuery += "    ON AC8_FILIAL = '" + xFilial( 'AC8' ) + "' "
	cQuery += "   AND AC8_ENTIDA = '" + cEntidade + "' "
	cQuery += "   AND AC8_CODENT = '" + cChave + "' "
	cQuery += "   AND AC8_CODCON = U5_CODCONT "
	cQuery += "   AND AC8.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE U5_FILIAL = '" + xFilial( 'SU5' ) + "' "
	If !Empty( cFilter )
		cQuery += "   AND " + AllTrim( cFilter ) +  " "
	EndIf
	cQuery += "   AND SU5.D_E_L_E_T_ = ' ' "

	uRetorno := ''

	If JurF3Qry( cQuery, 'SU5NT0', 'SU5RECNO', @uRetorno,, { "U5_CODCONT", "U5_CONTAT" } )
		SU5->( dbGoto( uRetorno ) )
		lRet := .T.
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURCONTOK
Rotina para validacao de Contatos

@author Ernani Forastieri
@since 18/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURCONTOK( cEntidade, cChaveSU5, cChaveAC8, cFilter, lShowMsg )
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local aAreaSU5 := SU5->( GetArea() )
	Local aAreaAC8 := AC8->( GetArea() )
	Local cCliLoj  := ""
	Local cMsgEnt  := ""
	Local cErro    := ""
	Local cSolucao := ""
	Local aRet     := {.T., ""}

	Default cEntidade := "SA1"
	Default cChaveSU5 := ""
	Default cChaveAC8 := ""
	Default cFilter   := ""
	Default lShowMsg  := .T.

	SU5->( dbSetOrder( 1 ) )
	If SU5->( dbSeek( xFilial( 'SU5' ) + cChaveSU5 ) )
		If Empty( cFilter ) .OR. Eval( &( '{|| ' + cFilter + ' }' ) )
			AC8->( dbSetOrder( 1 ) )
			If AC8->( dbSeek( xFilial( 'AC8' ) + cChaveSU5 + cEntidade + cChaveAC8 ) )
				lRet := .T.
			Else
				If cEntidade == "SA1"
					cMsgEnt := STR0109 //"Não existe relacionamento entre o cliente #1 e o contato #2."
				ElseIf cEntidade == "SA2"
					cMsgEnt := STR0110 //"Não existe relacionamento entre o fornecedor #1 e o contato #2."
				Else
					cMsgEnt := STR0125 //"Não existe relacionamento entre o registro #1 e o contato #2."
				EndIf

				cCliLoj := Right(cChaveAC8, TamSX3('A1_COD')[1]+TamSX3('A1_LOJA')[1])
				cCliLoj := Substr(cCliLoj, 1, TamSX3('A1_COD')[1])+ "-" + Substr(cCliLoj,TamSX3('A1_COD')[1]+1)

				cErro    := I18N(cMsgEnt, {cCliLoj,cChaveSU5})//"Verifique o relacionamento no cadastro antes de confirmar."
				cSolucao := STR0156
			EndIf
		Else
			cSolucao := I18N(STR0157, {cChaveSU5})//# "O contato não é válido."  ##"Verifique o contato '#1' no cadastro de contatos."
			cErro    := STR0107
		EndIf
	Else
		cSolucao := I18N(STR0157, {cChaveSU5})
		cErro    := STR0108 //# "O contato não existe no cadastro." ##"Verifique o contato '#1' no cadastro de contatos."
	EndIf

	If lShowMsg .And. !lRet
		lRet := JurMsgErro(cErro, ProcName(), cSolucao)
	Else
		If !Empty(cErro)
			cErro += CRLF + cSolucao
		EndIf
		aRet := { lRet, cErro }
	EndIf

	RestArea( aAreaSU5 )
	RestArea( aAreaAC8 )
	RestArea( aArea )

Return Iif(lShowMsg, lRet, aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JURNUTNCLI
Rotina para retornar nome do cliente na pela NUT

@author Ernani Forastieri
@since 18/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURNUTNCLI()
	Local cRet := ''

	If IsInCallStack('JURA096')
		cRet := JA096RELA("NUT_DCLIEN")
	Else
		cRet := Posicione( 'SA1', 1, xFilial( 'SA1') + NUT->( NUT_CCLIEN+NUT_CLOJA ), 'A1_NOME' )
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURHabMul
Rotina que verifica se deve habilitar o campo de multa
@author Clï¿½vis Eduardo Teixeira
@since 13/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURHabMul(cCampo, cCodigo)
	Local oModel    := FWModelActive()
	Local oView     := FWViewActive()
	Local nOper     := oModel:GetOperation()
	Local cTabela   := SubStr(cCampo,1,3)
	Local oMdActive := nil
	Local cFormaCor := ''
	Local cCajuri   := ''
	Local cFormula  := ''
	Local lRet      := .F.

	if cTabela == 'NSZ'
		cFormaCor := FwFldGet('NSZ_CFCORR')
		oMdActive := oModel:GetModel("NSZMASTER")

	Elseif cTabela == 'NT2'
		cFormaCor := FwFldGet('NT2_CCOMON')
		oMdActive := oModel:GetModel("NT2MASTER")

		if Empty(cFormaCor)
			cCajuri   := Posicione('NT2', 2 , xFilial('NT2') + cCodigo, 'NT2_CAJURI')
			cFormaCor := Posicione('NSZ', 1 , xFilial('NSZ') + cCajuri, 'NSZ_CFCORR')
		Endif

	Elseif cTabela == 'NSY'
		oMdActive := oModel:GetModel("NSYMASTER")

		Do Case
		Case cCampo == 'NSY_PERMUL'
			cFormaCor := FwFldGet('NSY_CCOMON')

		Case cCampo == 'NSY_PERMU1'
			cFormaCor := FwFldGet('NSY_CFCOR1')

		Case cCampo == 'NSY_PERMUC'
			cFormaCor := FwFldGet('NSY_CFCORC')

		Case cCampo == 'NSY_PERMU2'
			cFormaCor := FwFldGet('NSY_CFCOR2')

		Case cCampo == 'NT2_PERMUT'
			cFormaCor := FwFldGet('NSY_CFCORT')
		End Case

		if Empty(cFormaCor)
			cCajuri   := Posicione('NSY', 2 , xFilial('NSY') + cCodigo, 'NSY_CAJURI')
			cFormaCor := Posicione('NSZ', 1 , xFilial('NSZ') + cCajuri, 'NSZ_CFCORR')
		Endif

	Endif

	if !Empty(cFormaCor)
		cFormula := Posicione('NW7', 1 , xFilial('NW7') + cFormaCor, 'NW7_FORMUL')
		lRet := '#VLRMULTA' $ cFormula

		if !lRet .And. (nOper == 3 .Or. nOper == 4) .And. !Empty(FwFldGet(cCampo))
			oMdActive:LoadValue(cCampo,'')
			oView:Refresh()
		Endif
	Else
		lRet := .F.
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LtoC
Funï¿½ï¿½o para converter logico em caracter
Uso Geral.

@param 	lParam			Variï¿½vel logica

@Return cRet	 		Campo logico como caracter

@author Felipe Bonvicini Conti
@since 07/11/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function LtoC(lParam)
	Local cRet := ""

	ParamType 0 Var lParam	As Logical   Optional Default .T.

	If lParam
		cRet := ".T."
	Else
		cRet := ".F."
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaF3Tab
Cria a tela para consulta especï¿½fica com filtro.
Utilizada em consultas que retornem mais de 4.000 registros e que utilizem
filtro de mais de uma tabela (substituiï¿½ï¿½o de consulta com query)

@param 	oDlg		Objeto onde serï¿½ inserido o browse
@param 	oPnlBrw 	Panel do browse
@param 	aSearch		Array dos campos da pesquisa
@param 	aCampos 	Array de campos de colunas da pesquisa
@param 	cTabela 	Nome da tabela do browse
@param 	aFiltro 	Array de filtros da pesquisa

@Return oBrowse	 	Objeto browse

@author Juliana Iwayama Velho
@since 27/01/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function CriaF3Tab(oDlg, oPnlBrw, aSearch, aCampos, cTabela, aFiltro )
	Local oBrowse
	Local oColumn
	Local nI
	Local aColunas   := {}
	Local aIndex     := {}
	Local aSeek      := {}
	Local aNoAccLGPD := {}
	Local aDisabLGPD := {}
	Local lOfuscate  := _lFwPDCanUse .And. FwPDCanUse(.T.)

	If !Empty (aSearch)
		For nI:= 1 to Len(aSearch)
			aAdd( aIndex, aSearch[nI][1] )
			aAdd( aSeek, { AvSX3(aSearch[nI][1],5), {{"",AvSX3(aSearch[nI][1],2),AvSX3(aSearch[nI][1],3),AvSX3(aSearch[nI][1],4),;
				AvSX3(aSearch[nI][1],5),,}},aSearch[nI][2], .T. } )
		Next
	EndIf

/* Estrutura de colunas
[1] Nome do campo
[2] Tï¿½tulo do campo
[3] Mï¿½scara
*/
	If !Empty (aCampos)
		For nI:= 1 to Len(aCampos)
			aAdd( aColunas, { aCampos[nI], AvSX3(aCampos[nI],5), AvSX3(aCampos[nI],6) } )
		Next

		If lOfuscate
			aNoAccLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCampos)
			AEval(aNoAccLGPD, {|x| AAdd( aDisabLGPD, x:CFIELD)})
		EndIf
	EndIf

	lOfuscate := Len(aDisabLGPD ) > 0

	Define FWBrowse oBrowse DATA TABLE ALIAS cTabela FILTER SEEK ACTION { || JurAdFil(oBrowse,cTabela) } SEEK ORDER aSeek INDEXQUERY aIndex;
		NO LOCATE NO CONFIG  NO REPORT DOUBLECLICK { || lRetTab := .T., oDlg:End() } Of oPnlBrw

	For nI := 1 To Len( aColunas )
		ADD COLUMN oColumn  DATA &( '{ ||' + aColunas[nI][1] + ' }' ) Title aColunas[nI][2]  PICTURE aColunas[nI][3] Size Len(aColunas[nI][1]) Of oBrowse
		If lOfuscate
			oColumn:SetObfuscateCol( aScan(aDisabLGPD,aColunas[nI][1]) > 0)
		EndIf
	Next

	For nI := 1 To Len( aFiltro )
		If (aFiltro[nI][1])
			If (aFiltro[nI][2]) == 'A'
				oBrowse:AddFilter(aFiltro[nI][3],aFiltro[nI][4],.T.,.T.,)
			ElseIf (aFiltro[nI][2]) == 'S'
				oBrowse:AddFilter(aFiltro[nI][3],aFiltro[nI][4],.T.,.T.,aFiltro[nI][5])
			EndIf
		EndIf
	Next

	oBrowse:Activate()

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} JurAdFil
Adiciona internamente a filial da tabela para realizar a pesquisa

@author Juliana Iwayama Velho
@since 26/01/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurAdFil(oBrowse, cTabela)
	Local cSeek    := xFilial(cTabela)
	Local oFWSeek  := oBrowse:GetSeek()
	Local cSeekOld := oFWSeek:GetSeek()
	Local nRet

	cSeek := cSeek + oFWSeek:GetSeek()
	oFWSeek:cSeek := RTrim(cSeek)
	nRet := oBrowse:oData:Seek(oFWSeek, oBrowse)
	oFWSeek:cSeek:= cSeekOld

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurF3Tab
Cria a tela para consulta específica com filtro.
Utilizada em consultas que retornem mais de 4.000 registros e que utilizem
filtro de mais de uma tabela (substituição de consulta com query)

@param 	aSearch		Array dos campos da pesquisa
@param 	cTabela 	Nome da tabela do browse
@param 	aFiltro 	Array de filtros da pesquisa
@param 	aCampos 	Array de campos de colunas da pesquisa
@param 	cTela	 	Nome do fonte da tela
@param	cTitulo		Titulo da janela de pesquisa

@Return lRetTab	 	.T./.F. As informações válidas ou não

@author Juliana Iwayama Velho
@since 27/01/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurF3Tab( aSearch, cTabela, aFiltro, aCampos, cTela, cTitulo, lVisual, IsMVC )
	Local cIdBrowse := ''
	Local cIdRodape := ''
	Local oBrowse
	Local oDlg
	Local oBtnOk
	Local oBtnCan
	Local oTela
	Local oPnlBrw
	Local oPnlRoda
	Local oBtnInc
	Local oBtnVis

	Private lRetTab  := .F.

	Default cTitulo  := STR0118 //"Consulta Específica"
	Default lVisual  := .T.
	Default IsMVC    := .T.

	Define MsDialog oDlg From 178, 0 To 543, 800 Title cTitulo Pixel Of oMainWnd

	oTela     := FWFormContainer():New( oDlg )
	cIdBrowse := oTela:CreateHorizontalBox( 85 )
	cIdRodape := oTela:CreateHorizontalBox( 15 )
	oTela:Activate( oDlg, .F. )

	oPnlBrw   := oTela:GeTPanel( cIdBrowse )
	oPnlRoda  := oTela:GeTPanel( cIdRodape )

	oBrowse   := CriaF3Tab(oDlg, oPnlBrw, aSearch, aCampos, cTabela, aFiltro )

	@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 003 Button oBtnOk  Prompt STR0119 Size 25, 11 Of oPnlRoda Pixel Action ( lRetTab := .T., oDlg:End() ) //'Ok'
	@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 033 Button oBtnCan Prompt STR0114 Size 25, 11 Of oPnlRoda Pixel Action ( lRetTab := .F., oDlg:End() ) //'Cancela'

//<--Ponto de Entrada para tratamento do botão incluir das Consultas Específicas-->

	If VerSenha(24) // Verifica se usuário tem permissão na restrição de acesso
		If Existblock( 'JUF3BTNINC' )

			If (Execblock('JUF3BTNINC', .F., .F.))
				@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 063 Button oBtnInc Prompt STR0115 Size 25, 11 Of oPnlRoda Pixel Action ( JurAcao(cTela, 3, oBrowse, , , IsMVC), ;//'Incluir'
				oBrowse:DeActivate(.T.), oBrowse := CriaF3Tab(oDlg, oPnlBrw, aSearch, aCampos, cTabela, aFiltro ) )
			EndIf
		Else

			@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 063 Button oBtnInc Prompt STR0115 Size 25, 11 Of oPnlRoda Pixel Action ( JurAcao(cTela, 3, oBrowse, , , IsMVC), ;//'Incluir'
			oBrowse:DeActivate(.T.), oBrowse := CriaF3Tab(oDlg, oPnlBrw, aSearch, aCampos, cTabela, aFiltro ) )
		EndIf
	EndIf

	If lVisual
		@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 093 Button oBtnVis Prompt STR0117 Size 25, 11 Of oPnlRoda Pixel Action ( JurAcao(cTela, 1, oBrowse, &(cTabela)->(Recno()), cTabela, IsMVC) ) //'Visualizar'
	EndIf

	Activate MsDialog oDlg Centered

Return lRetTab

//-------------------------------------------------------------------
/*/{Protheus.doc} JFldNoUpd
Funï¿½ï¿½o utilizada para setar como no update apenas os campos padrï¿½es do sistema. (SX3_PROPRI <> "U")

@author Felipe Bonvicini Conti
@since 13/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JFldNoUpd(cCampo, oStruct, lNoUpd, nPropri)
	Local lRet      := .T.
	Local aArea     := GetArea()
	Local aAreaSX3  := SX3->( GetArea() )
	Local cTabela   := oStruct:GetTable()[1]
	Local lExist    := .F.

	Default nPropri := MODEL_FIELD_NOUPD

	If cCampo = "*"
		dbSelectArea('SX3')
		SX3->(dbSetOrder(1))
		SX3->(dbSeek(cTabela))

		//Rodar todos os campos que sejam do sistema (SX3_PROPRI = "" ou "S")
		While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO == cTabela

			lExist := oStruct:HasField(AllTrim(SX3->X3_CAMPO)) // verifica se o campo existe na estrutura

			If lExist .and. X3USO(SX3->X3_USADO) .And. SX3->X3_CONTEXT == "R" .And. (Empty(SX3->X3_PROPRI) .Or. SX3->X3_PROPRI == "S")
				oStruct:SetProperty(AllTrim(SX3->X3_CAMPO), nPropri, lNoUpd)
			EndIf

			SX3->(DBSkip())

		EndDo

	Else
		oStruct:SetProperty( cCampo, nPropri, lNoUpd )
	EndIf

	RestArea(aAreaSX3)
	RestArea(aArea)

Return lRet

/*******************************************************
Armazena os campos especï¿½ficos do usuï¿½rio para nï¿½o perder
os valores ao refazer o registro.
(obs - utilizado na rotina de faturamento - JURA201H)
*******************************************************/
Function JGetFldUsu(cTabela, cCampo, nRecno )
Local aRet     := {}
Local aArea    := GetArea()
Local aAreaSX3 := SX3->( GetArea() )

	If cCampo = "*"
		dbSelectArea(cTabela)
		&(cTabela)->(dbGoTo(nRecno))

		dbSelectArea('SX3')
		SX3->(dbSetOrder(1))
		SX3->(dbSeek(cTabela))

		//Rodar todos os campos que sejam do sistema (SX3_PROPRI = "" ou "S")
		While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO == cTabela

			If X3USO(SX3->X3_USADO) .And. !Empty(SX3->X3_PROPRI) .AND. SX3->X3_PROPRI <> "S" .AND. SX3->X3_CONTEXT == "R"
				aAdd( aRet, { AllTrim(SX3->X3_CAMPO), (cTabela)->&(SX3->X3_CAMPO) })
			EndIf

	    SX3->(DBSkip())

		End

	Else
		aAdd( aRet, { AllTrim(cCampo), (cTabela)->&(cCampo) })
	EndIf

	RestArea(aAreaSX3)
	RestArea(aArea)

Return aRet

/*******************************************************
Restaura os valores dos campos especï¿½ficos do usuï¿½rio
para nï¿½o perder os valores ao refazer o registro.
(obs - utilizado na rotina de faturamento - JURA201H)
*******************************************************/
Function JSetFldUsu(cTabela, aCampos, nRecno )
Local lRet := .T.
Local nI   := 0

	dbSelectArea(cTabela)
	&(cTabela)->(dbGoTo(nRecno))

	RecLock(cTabela,.F.)
	For nI := 1 to Len(aCampos)
		(cTabela)->&(aCampos[nI][1]) := aCampos[nI][2]
	Next nI

	&(cTabela)->(MsUnlock())
	&(cTabela)->(DbCommit())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurOperacao
Funï¿½ï¿½o utilizada para efetuar inclusï¿½o, alteraï¿½ï¿½o e exclusï¿½o de registros utilizando reclock.

@param  nOpc     Operação (3=Inclusão, 4=Alteração, 5=Exclusão)
@param  cTabela  Nome da tabela aonde serão feito a alteração de valor do campo
@param  nIndex   Index para o dbSeek
@param  cChave   Chave para encontrar o registro a ser alterado
@param  cCampo   Campo que sofrerão a alteração
@param  xValor   Novo valor do campo
@param  nREcno   Recno do registro a ser alterado

@Return lRetTab  .T./.F. As informações são válidas ou não

@author Felipe Bonvicini Conti
@since 06/03/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurOperacao(nOpc, cTabela, nIndex, cChave, xCampo, xValor, nREcno)
	Local lRet       := .T.
	Local aArea      := GetArea()
	Local aAreaTable := (cTabela)->(GetArea())
	Local cFiltro    := ""
	Local lInclusao	 := .F.
	Local bFiltro    := {}
	Local aCampos    := {}
	Local aValores   := {}
	Local nI
	Local nPos       := 0

	Default nOpc     := 4
	Default nIndex   := 1
	Default cChave   := ""
	Default nREcno   := 0

	If !Empty(cTabela) .And. (nOpc == 3 .Or. !Empty(cChave)) .And. (nOpc == 5 .Or. (!Empty(xCampo)))

		lInclusao := nOpc == 3

		Do Case
		Case ValType(xCampo) == "A"
			aCampos := aClone(xCampo)
		OtherWise
			aAdd(aCampos, xCampo)
		End Case

		Do Case
		Case ValType(xValor) == "A"
			aValores := aClone(xValor)
		OtherWise
			aAdd(aValores, xValor)
		End Case

		nQtdCampos  := Len(aCampos)
		nQtdValores := Len(aValores)

		If nQtdCampos == nQtdValores

			dbSelectArea(cTabela)

			If !lInclusao
				cFiltro := (cTabela)->(dbFilter())
				bFiltro := IIf(!Empty(cFiltro), &('{|| '+AllTrim(cFiltro)+'}'), '')
				(cTabela)->(dbClearFilter())
				(cTabela)->(dbSetOrder(nIndex))
				(cTabela)->(dbSkip())
				(cTabela)->(dbGoTop())
				If nRecno == 0
					lRet := (cTabela)->(dbSeek(cChave))
				Else
					(cTabela)->(dbGoto(nRecno))
					lRet := (cTabela)->(!EOF())
				EndIf
			EndIf

			If lRet
				RecLock(cTabela, lInclusao)
				Do Case
				Case nOpc == 3 .Or. nOpc == 4 // Inclusï¿½o ou Alteraï¿½ï¿½o
					For nI := 1 to nQtdCampos
						nPos := FieldPos(aCampos[nI])
						If nPos > 0
							(cTabela)->( FieldPut(nPos, aValores[nI]) )
						EndIf
					Next
				Case nOpc == 5 // Exclusï¿½o
					(cTabela)->(DbDelete())
				End Case
				(cTabela)->(MsUnlock())

				While __lSX8
					ConfirmSX8()
				EndDo

			EndIf

			If !lInclusao
				If !Empty(cFiltro)
					(cTabela)->(dbSetFilter(bFiltro, cFiltro))
				EndIf
			EndIf

		EndIf

	EndIf

	RestArea(aAreaTable)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JBrwMarkAll
Chamada da rotina que avalia a acao de marcar todos

@author Felipe Bonvicini Conti
@since 24/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JBrwMarkAll(oBrowse)

	MsgRun( STR0120, STR0121, {|| JBrwMrkAll(oBrowse) } ) //"Aguarde... Marcando Registros"###"Marcar Todos"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JBrwMrkAll
Funcao para marcar efetivamente os registros ao utilizar o recurso
de marcar todos (duplo clique na header da marcacao)

@author Felipe Bonvicini Conti
@since 24/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JBrwMrkAll(oBrowse)
	Local nCurrRec := oBrowse:At()
	Local nLoopRec := 0

	oBrowse:GoTop(.T.)
	While .T.
		nLoopRec := oBrowse:At()
		If SimpleLock()
			oBrowse:MarkRec()
			MsRUnlock(nLoopRec)
		EndIf
		oBrowse:GoDown()
		If nLoopRec == oBrowse:At()
			Exit
		EndIf

	EndDo

	oBrowse:GoTo( nCurrRec, .T. )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGetDados
Funï¿½ï¿½o semelhante a POSICIONE, porem nï¿½o desposiciona a tabela e busca
sempre valores atualisados da tabela buscada

@param 	cTabela		Nome da tabela aonde serï¿½ feito a alteraï¿½ï¿½o de valor do campo
@param 	nIndex 		Index para o dbSeek
@param 	cChave 		Chave para encontrar o registro a ser alterado
@param 	xCampo 		Campo(s) a serem localizados para buscar os seus valores

@Return xRet		 	Valor dos xampos

@author Felipe Bonvicini Conti
@since 04/05/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurGetDados(cTabela, nIndex, cChave, xCampo, lQuery)
	Local xRet
	Local aCampos := {}

	Default nIndex	:= 1
	Default cChave	:= ""
	Default xCampo  := ""
	Default lQuery  := .F.

	If !Empty(cTabela) .And. !Empty(cChave) .And. !Empty(xCampo)
		Do Case
		Case ValType(xCampo) == "A"
			aCampos := aClone(xCampo)
		OtherWise
			aAdd(aCampos, xCampo)
		End Case

		If lQuery
			xRet := JurGetDdQy(cTabela, nIndex, cChave, aCampos)
		Else
			xRet := JurGetDdTB(cTabela, nIndex, cChave, aCampos)
		EndIf

	EndIf

	If xRet == NIL .And. ValType(xCampo) <> "A" .and. xCampo <> ""
		xRet := CriaVar(xCampo, .F.)
	ElseIf xRet == NIL .And. ValType(xCampo) == "A"
		xRet := {}
	EndIf

Return xRet

Function JurGetDdQy(cTabela, nIndex, cChave, aCampos)
	Local xRet
	Local cQuery   := ""
	Local aSQL     := {}
	Local cCposChv := JurGetChave(cTabela, nIndex)
	Local nQtdCpos := LEN(aCampos)
	Local nI

	cQuery += " SELECT "+AtoC(aCampos, ", ")
	cQuery += "   FROM " + RetSqlName( cTabela )
	cQuery += "  WHERE "+cTabela+"_FILIAL = '" + xFilial( cTabela ) + "' "
	cQuery += "    AND " + cCposChv + " = '" + cChave + "'"
	cQuery += "    AND D_E_L_E_T_ = ' ' "

	aSQL := JurSQL(cQuery, aCampos)

	If !Empty(aSQL)

		If nQtdCpos == 1
			xRet := aSQL[1][1]
		Else
			For nI := 1 to nQtdCpos
				aAdd(xRet, aSQL[1][nI])
			Next
		EndIf

	EndIf

Return xRet

Function JurGetDdTB(cTabela, nIndex, cChave, aCampos)
//Local cOldAlias   := Alias()
	Local aArea       := GetArea()
	Local aAreaTable	:= (cTabela)->(GetArea())
	Local xRet
	Local cFiltro			:= ""
	Local bFiltro			:= {}
	Local lSeek       := .T.
	Local nI

	DEFAULT nIndex	:= 1
	DEFAULT cChave	:= ""

	nQtdCampos := Len(aCampos)
	If nQtdCampos > 0
		cFiltro := (cTabela)->(dbFilter())
		If !Empty(cFiltro)
			bFiltro := IIf(!Empty(cFiltro), &('{|| '+AllTrim(cFiltro)+'}'), '')
			(cTabela)->(dbClearFilter())
		EndIf
		(cTabela)->(dbSetOrder(nIndex))
		lSeek := (cTabela)->(dbSeek(cChave))
		If lSeek
			If nQtdCampos > 1
				xRet := {}
				For nI := 1 to nQtdCampos
					aAdd(xRet, (cTabela)->(FieldGet(FieldPos(aCampos[nI]))))
				Next
			Else
				xRet := (cTabela)->(FieldGet(FieldPos(aCampos[1])))
			EndIf
		EndIf
		If !Empty(cFiltro)
			(cTabela)->(dbSetFilter(bFiltro, cFiltro))
		EndIf
	EndIf
	RestArea(aAreaTable)
	RestArea(aArea)
	//dbSelectArea(cOldAlias)

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGetChave
Funï¿½ï¿½o utilizada para retornar a chave da tabela e ordem indicada.

@author Felipe Bonvicini Conti
@since 13/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurGetChave(cTabela, xOrder)
	Local cRet     := ""
	Local aArea    := GetArea()
	Local aAreaSIX := SIX->(GetArea())
	Local cOrder   := ""

	Default cTabela := ""
	Default xOrder  := 1

	Do Case
	Case ValType(xOrder) == "N"
		cOrder := AllTrim(Str(xOrder))
	Case ValType(xOrder) == "C"
		cOrder := AllTrim(xOrder)
	End Case

	SIX->( dbSetOrder(1) )
	If SIX->( dbSeek( cTabela + cOrder ) )
		cRet := AllTrim(SIX->CHAVE)
	EndIf

	RestArea(aAreaSIX)
	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIndxTam(cIndExpr)
Função utilizada para calcular a soma do tamanho(Len) dos campos de um índice.

@Param cIndExpr     Expressão do índice

@author Ricardo Ferreira Neves
@since 31/03/16
/*/
//-------------------------------------------------------------------
Function JurIndxTam(cIndExpr)
	Local aIndex := STRTOKARR(cIndExpr , '+' )
	Local nRet   := 0
	Local nI     := 0

	For nI :=1 to Len(aIndex)
		If AT('(',aIndex[nI]) > 0
			aIndex[nI] := SUBSTR(aIndex[nI], AT('(',aIndex[nI]) + 1)
			aIndex[nI] := SUBSTR(aIndex[nI], 1, AT(')',aIndex[nI]) - 1)
		EndIf
		nRet := nRet + GetSx3Cache(aIndex[nI], 'X3_TAMANHO')
	Next nI

Return nRet

/*-------------------------------------------------------------------
{Protheus.doc} JurGetNum()
Funï¿½ï¿½o utilizada para substituir o GetSxEnum() validando se o registro retornado ï¿½ valido.

@author Felipe Bonvicini Conti
@since 10/08/2012
-------------------------------------------------------------------*/
Function JurGetNum(cTabela, cCampo, cAliasSX8, nOrdem)
Local cRet := ""
Local nQtd := 0

Default cTabela := ""
Default cCampo  := ""

	If !Empty(cTabela) .And. !Empty(cCampo)
		cRet := GetSxEnum(cTabela, cCampo, cAliasSX8, nOrdem)
		If !Empty(cRet)
			While !JValidNum(cTabela, cCampo, cRet)
				ConOut("JurGetNum: 'GetSxEnum' retornou uma chave repetida "+AllTrim(Str(nQtd))+" vez(es)!(cTabela: "+cTabela +", cCampo: "+cCampo+", Valor: "+cRet+")")
				cRet := GetSxEnum(cTabela, cCampo, cAliasSX8, nOrdem)
				nQtd++
				If nQtd > 1000 .Or. Empty(cRet)
					cRet := ""
					Exit
				EndIf
			End
		EndIF
	EndIF

Return cRet

/*-------------------------------------------------------------------
{Protheus.doc} JValidNum()
Funï¿½ï¿½o utilizada para verificar se o registro novo existe

@author Felipe Bonvicini Conti
@since 10/08/2012
-------------------------------------------------------------------*/
Static Function JValidNum(cTabela, cCampo, cValor)
Local cQry := ""

	cQry += " SELECT Count('1') QTD"
	cQry += "   FROM " + RetSqlName(cTabela)
	cQry += "  WHERE " + cTabela+ "_FILIAL = '" + xFilial(cTabela) + "' "
	cQry += "    AND " + cCampo + " = '" + cValor + "'"
	cQry += "    AND D_E_L_E_T_ = ' ' "

Return JurSQL(cQry, "QTD", .F.)[1][1] == 0

/*-------------------------------------------------------------------
{Protheus.doc} JGetSx3()
Função utilizada para retornar campos específicos da SX3 perante filtro.

@author Felipe Bonvicini Conti
@since 13/03/2013
-------------------------------------------------------------------*/
Function JGetSx3(cFiltro, aCols, nOrder)
Local aRet     := {}
Local aArea    := GetArea()
Local aAreaSX3 := SX3->( GetArea() )
Local cFilOld  := ""
Local aStru    := {}
Local aAux     := {}
Local nI, nQtd

Default cFiltro := ""
Default aCols   := {"*"}
Default nOrder  := 1

	If !Empty(cFiltro) .And. !Empty(aCols)
		cFilOld := SX3->(dbFilter())

		SX3->(dbClearFilter())
		SX3->(dbSetFilter(&('{|| '+AllTrim(cFiltro)+'}'), cFiltro))
		SX3->(dbSetOrder(nOrder))
		SX3->(dbGoTop())
		nQtd := Len(aCols)
		If (nQtd == 1) .And. aCols[1] == "*"
			aCols := {}
			aStru := SX3->(DBSTRUCT())
			For nI := 1 to Len(aStru)
				aAdd(aCols, aStru[nI][1])
			Next
		EndIf

		While !SX3->(Eof())
			For nI := 1 to nQtd
				aAdd( aAux, SX3->(FieldGet(FieldPos(aCols[nI]))) )
			Next
			aAdd(aRet, aAux)
			aAux := {}
			SX3->(dbSkip())
		End
		SX3->(dbClearFilter())
		If !Empty(cFilOld)
			SX3->(dbSetFilter(&('{|| '+AllTrim(cFilOld)+'}'), cFilOld))
		EndIf
	EndIf

	RestArea(aAreaSX3)
	RestArea(aArea)

Return aRet

/*-------------------------------------------------------------------
{Protheus.doc} JurThreadIsLive(oClass, lConout)
Função utilizada para verificar se uma determinada thread esta ativa

@author Felipe Bonvicini Conti
@since 30/09/2013
-------------------------------------------------------------------*/
Function JurThreadIsLive(nThreadID, aInfo)
Default nThreadID := 0
Default aInfo     := GetUserInfoArray()
Return aScan( aInfo, { |aX| aX[3] == nThreadID } ) > 0

/*-------------------------------------------------------------------
{Protheus.doc} JurGetMethods(oClass, lConout)
Função utilizada retornar todos os methodos da classe informada

@author Felipe Bonvicini Conti
@since 30/09/2013
-------------------------------------------------------------------*/
function JurGetMethods(oClass, lConout)
Local aMethods    := {}
Local cClassName  := ""

Default oClass  := Nil
Default lConout := .F.

	//aProperties := ClassDataArr(oConn)
	//aMethods    := ClassMethArr(oConn)
	//aClass      := __ClsArr()
	//aFuns       := __FunArr()
	//GetUserInfoArray()

	If oClass <> Nil
		aMethods   := ClassMethArr(oClass)
		cClassName := GetClassName(oClass)

		If lConout
			aEval(aMethods, {|aMethod| JurConOut("Method of #1: #2", {cClassName, aMethod[1]}) })
		EndIf
	EndIf

Return aMethods

/*-------------------------------------------------------------------
{Protheus.doc} JurConOut()
Função utilizada para efetuar conout utilizando I18N

@author Felipe Bonvicini Conti
@since 30/09/2013
-------------------------------------------------------------------*/
Function JurConOut(cText, aValues, cProgName)
Local cAux := ""
Default cProgName := ProcName(1)
Default aValues := {}

	cAux := DtoC(Date()) + " " + Time() + " (" + cProgName + ") - "

	cAux += I18n(cText, aValues)
	Conout(cAux)

Return cAux

//-------------------------------------------------------------------
/*/{Protheus.doc} JURF3SX9
Função gené²©ca para montagem de tela de consulta padrao para campos do sistema
Uso Geral.

@param 	cFiltro		- Filtro para a consulta
@param	lShowCmp	- Mostra campo de contra dominio na consulta
@sample JURF3SX9( "X9_DOM =='NSZ'", .T. )
@author André “pirigoni Pinto
@since 25/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURF3SX9(cFiltro, lShowCmp, cTabDom, nPosCmpRet)

	Local aArea      := GetArea()
	Local aAreaSX9   := SX9->( GetArea() )
	Local lRet       := .F.
	Local oDlg       := Nil
	Local oBrowse    := Nil
	Local oMainPanel := Nil
	Local oPanelBtn  := Nil
	Local oBtnOK     := Nil
	Local oBtnCan    := Nil
	Local aColunas   := {}
	Local aAux       := {}
	Local aSX9       := {}

	ParamType 0 Var cFiltro    As Character Optional Default ".T."
	ParamType 1 Var lShowCmp   As Logical   Optional Default .F.
	ParamType 1 Var cTabDom    As Character Optional Default ""
	ParamType 3 Var nPosCmpRet As Numeric   Optional Default 1

	If Empty(cTabDom)

		JurMsgErro( I18n(STR0158, {"JUSX9A \ JUSX9B"}) )	//"Consultas padrões #1 desatualizadas no arquivo SXB, verifique!"
		lRet := .F.
	Else

		Aadd(aColunas,{STR0092, "X9_CDOM"		   , "@!", 3 ,,,, "C",, "R",,,,,,,,})	//"Tabela"
		Aadd(aColunas,{STR0091, "JA023TIT(X9_CDOM)", "@!", 30,,,, "C",, "R",,,,,,,,})	//"Descrição"

		If lShowCmp
			Aadd(aColunas,{STR0048				, "X9_EXPCDOM"			  , "@!", 10,,,, "C",, "R",,,,,,,,})	//"Campo "
			Aadd(aColunas,{STR0091 +" "+ STR0048, "JA160X3Des(X9_EXPCDOM)", "@!", 25,,,, "C",, "R",,,,,,,,})	//"Descrição"  //"Campo "
		EndIf

		SX9->( DbSetOrder(1) )	//X9_DOM
		If SX9->( DbSeek(cTabDom) )

			While !SX9->( Eof() ) .And. SX9->X9_DOM == cTabDom

				If &(cFiltro)

					aAux := {}
					Aadd(aAux, SX9->X9_CDOM)
					Aadd(aAux, Ja023TIT(SX9->X9_CDOM))

					If lShowCmp
						Aadd(aAux, SX9->X9_EXPCDOM)
						Aadd(aAux, Ja160X3Des(SX9->X9_EXPCDOM))
					EndIf

					Aadd(aSX9, aAux)
				EndIf

				SX9->( DbSkip() )
			EndDo
		EndIf

		Define MsDialog oDlg From 178, 0 To 543, 800 Title STR0089 Pixel Of oMainWnd // "Consulta Padrão - Campos do Sistema"

		@00, 00 MsPanel oMainPanel Size 250, 80
		oMainPanel:Align := CONTROL_ALIGN_ALLCLIENT

		@00, 00 MsPanel oPanelBtn Size 250, 15
		oPanelBtn:Align := CONTROL_ALIGN_BOTTOM

		oBrowse := TJurBrowse():New(oMainPanel)
		oBrowse:SetDataArray()
		oBrowse:SetDoubleClick( {|| lRet := .T., _cJurF3Sx9 := aSX9[oBrowse:nAT][nPosCmpRet], oDlg:End()} )
		oBrowse:SetHeader(aColunas)
		oBrowse:Activate()
		oBrowse:SetArray(aSX9)
		oBrowse:Refresh()

		Define SButton oBtnOK  From 02, 02 Type 1 Enable Of oPanelBtn ONSTOP STR0087 ; // "Ok <Ctrl-O>"
		Action ( lRet := .T., _cJurF3Sx9:= aSX9[oBrowse:nAT][nPosCmpRet], oDlg:End() )

		Define SButton oBtnCan From 02, 32 Type 2 Enable Of oPanelBtn ONSTOP STR0088; // "Cancelar <Ctrl-X>"
		Action ( lRet := .F., oDlg:End() )

		Activate MsDialog oDlg Centered

	EndIf

	FreeObj(aAux)
	FreeObj(aSX9)

	RestArea( aAreaSX9 )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurF3Sx9Re
Retorna o registro posicionado pela consulta especifica JURF3SX9.

@return  _cJurF3Sx9 - Código do regristro posicionado
@author  Rafael Tenorio da Costa
@since   06/06/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurF3Sx9Re()
Return _cJurF3Sx9

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTime
Retorna a Hora atual com milisegundos

@param lData Parâmetro que controla se a data també­ deve ser retornada ou apenas a hora
@param lFormato Parâmetro que controla se o resultado vai ser formatado ou não

@return cRet Hora no formato HH:MM:SS:mmm

@sample JurTime(.T.,.T.) -> "14/03/2014 10:02:13:429" , JurTime() -> "10:02:34:212", JurTime(.T.,.F.) -> "20140314100248899"

@author Ernani Forastieri
@since  17/01/2014
@version P12
/*/
//-------------------------------------------------------------------
Function JurTime(lData, lFormato)
	Local nSeconds := Seconds()
	Local nSecs    := Int( nSeconds )
	Local nHSec    := Int( nSecs / 3600  )
	Local nMSec    := Int( ( nSecs - ( nHSec * 3600 ) ) / 60 )
	Local nSSec    := nSecs - ( nHSec * 3600 ) - ( nMSec * 60 )
	Local nMLSec   := ( nSeconds - nSecs ) * 1000
	Local cData    := ''
	Local cSepara  := ' '
	Local cRet     := ''

	Default lData    := .F.
	Default lFormato := .T.

	If lFormato
		cRet := StrZero( nHSec, 2 ) + ':' + StrZero( nMSec, 2 ) + ':' + StrZero( nSSec, 2 ) + ':' + StrZero( nMLSec, 3 )
		cSepara := ' '
	Else
		cRet := StrZero( nHSec, 2 ) + StrZero( nMSec, 2 ) + StrZero( nSSec, 2 ) + StrZero( nMLSec, 3 )
		cSepara := ''
	Endif

	If lData
		If lFormato
			cData := DTOC(Date())
		Else
			cData := DTOS(Date())
		Endif
	Endif

	cRet := cData + cSepara + cRet

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCodRst
Função para selecionar o codigo da configuração da restrição
por grupo de Clientes com o usuario logado no sistema

@Return aRet	   array com os codigos da restricao

@author Rafael Rezende Costa
@since 14/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurCodRst()
	Local cUser    := __CUSERID
	Local aCods    := {}
	Local cSqlUser := ''

	cSqlUser := " SELECT NVK.NVK_COD "
	cSqlUser += " FROM " + RetSqlName("NVK") + " NVK "
	cSqlUser += " WHERE NVK.NVK_FILIAL = '" + xFilial("NVK") + "' "
	cSqlUser += " AND NVK.D_E_L_E_T_ = ' ' "
	cSqlUser += " AND NVK.NVK_CUSER = '" + cUser + "' "

	aCods:= JurSQL(cSqlUser, "NVK_COD")

Return aCods

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCdCliRst()
Função para selecionar os codigos de cliente e loja de acordo com
o codigo da restrição passada como parametro

@Return aRet	   array com os codigos

@author Rafael Rezende Costa
@since 14/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurCdCliRst(cCodigo)
	Local aCods    := {}
	Local cSqlUser := ''

	If !Empty(cCodigo)
		cSqlUser := " SELECT NWO.NWO_CCLIEN, NWO.NWO_CLOJA "
		cSqlUser += " FROM " + RetSqlName("NWO") + " NWO "
		cSqlUser += " WHERE NWO.NWO_FILIAL = '" + xFilial("NWO") + "' "
		cSqlUser += " AND NWO.D_E_L_E_T_ = ' ' "
		cSqlUser += " AND NWO.NWO_CCONF = '" + cCodigo + "' "

		aCods:= JurSQL(cSqlUser, {"NWO_CCLIEN", "NWO_CLOJA"})
	EndIf

Return aCods

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSocieta
Função para selecionar os codigos de cliente e loja de acordo com
o codigo da restrição passada como parametro

@Return aRet	   array com os codigos

@author Rafael Rezende Costa
@since 14/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSocieta(cCod)
	Local lRet := .F.

	If cCod == '008'
		lRet := .T.
	ElseIf JurGetDados('NYB', 1, xFilial('NYB') + cCod, 'NYB_CORIG') == '008'
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JRVLDCP
Função para validar os campos Cliente, Loja e Caso.

@author Rafael Telles de Macedo
@since 27/01/2015

@version 1.0
/*/
//-------------------------------------------------------------------
Function JRVLDCP(cTab, cStruct, cCGrupo, cCClien, cCLoja, cCCaso, cDGrupo, cDClien, cDCaso )
	Local oModel   := FWModelActive()
	Local aArea    := GetArea()
	Local aAreaAli := ( cTab )->( GetArea() )
	Local lRet     := .T.
	Local cClien   := ''
	Local cLoja    := ''
	Local cCaso    := ''
	Local cNomeCli := ''

	cClien  := oModel:GetValue(cStruct, cCClien)
	cLoja   := oModel:GetValue(cStruct, cCLoja)
	cCaso   := oModel:GetValue(cStruct, cCCaso)

	If lRet .And. __ReadVar $ 'M->' + cCLoja
		If !Empty( cLoja )
			If lRet := ExistCpo('SA1', cClien + cLoja ,1)
				If JurGetDados('NUH', 1, xFilial('NUH') + cClien + cLoja, 'NUH_PERFIL') == '2'
					lRet := .F.
					JurMsgErro(STR0130) // Esse cliente é somente pagador.
				Else
					lRet := JAEXECPLAN(cStruct, cCGrupo, cCClien, cCLoja, cCCaso, cCLoja, cCLoja)

					oModel:SetValue(cStruct,cCClien, cClien)
					oModel:SetValue(cStruct,cCLoja, cLoja)
					oModel:SetValue(cStruct,cDClien, Left( SA1->A1_NOME, TamSX3(cDClien)[1]))
				EndIf
			Else
				JurMsgErro(STR0128) // Cliente/Loja não cadastrado.
			EndIf
		EndIf
	EndIf

	If lRet .And. __ReadVar $ 'M->' + cCGrupo + '/' + 'M->' + cCClien + '/' + 'M->' + cCLoja
		oModel:SetValue(cStruct,cDGrupo, Left(JurGetDados('ACY', 1, xFilial('ACY') + oModel:GetValue(cStruct, cCGrupo), 'ACY_DESCRI'), TamSX3(cDGrupo)[1]))
	EndIf

	If lRet .And. __ReadVar == 'M->' + cCCaso
		If !Empty( cCaso )
			Do Case

			Case SuperGetMV('MV_JCASO1') == '2' // Independente de Cliente

				lRet := JAEXECPLAN(cStruct, cCGrupo, cCClien, cCLoja, cCCaso, cCCaso)

				If lRet
					cNomeCli := JurGetDados('SA1',1,xFilial('SA1')+ cClien + cLoja , 'A1_NOME')
					cNomeCli := Left(cNomeCli, TamSX3(cDClien)[1])
					oModel:LoadValue(cStruct,cDClien, cNomeCli)
					oModel:LoadValue(cStruct, cDGrupo, JurGetDados('ACY',1,xFilial('ACY')+ cCGrupo ,'ACY_DESCRI') )
				EndIf

				NVE->(dbSetOrder(3))
				If !NVE->(dbSeek(xFilial('NVE') + cCaso))
					JurMsgErro(STR0129) //'Caso não localizado.'
					lRet := .F.
				EndIf

			Case SuperGetMV('MV_JCASO1') == '1' // Por Cliente
				NVE->(dbSetOrder(1))
				If !NVE->(dbSeek(xFilial('NVE') + cClien + cLoja + cCaso))
					JurMsgErro(STR0129) //'Caso não localizado.'
					lRet := .F.
				EndIf
			EndCase
		EndIf
	EndIf

	RestArea(aAreaAli)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JRVLCLC
Função para bloquear o campo.
@Param  cCampo   Campo a ser validado
@Return cRet			.T. ou .F.
@author Rafael Telles de Macedo
@since 02/02/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JRVLCLC(cTab, cCampo)
	Local lRet     := .F.
	Local lCasoNWF := cTab == "NWF" .And. cCampo == "NWF_CCASO"
	
	If cCampo == cTab + '_CCASO'
		If INCLUI .Or. Empty(FwFldGet(cTab + '_TITULO'))
			lRet := !Empty(FWFldGet(cTab + '_CCLIEN')) .And. !Empty(FWFldGet(cTab + '_CLOJA'))
		ElseIf lCasoNWF .And. FWFldGet("NWF_VALUTI") ==  0
			lRet := .T.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JCallCrys
Trata as chamadas de relatórios do Crystal Reports.
Verifica se o ambiente que está em uso é Smartclient HTML ou desktop.

@param	cReportName	Nome do relatório.
@param cParams Parâmetros do relatório.
@param cOptions Configuração de impressão.
	Onde:

	x 	 = Impressão em Vídeo(1), Impressora(2), Impressora(3), Excel(4), Excel Tabular(5), PDF(6), Texto (7) e Word (8).
	y 	 = Atualiza Dados(0) ou não(1)
	z 	 = Número de Cópias, para exportação este valor sempre será 1.
	w 	 = Título do Report, para exportação este será o nome do arquivo sem extensão.

@param lWaitRun Define se interrompe o processamento.
@param lShowGauge Define se exibe o gauge de processamento.
@param	lExportFromServer Indica que o relatório gerado no servidor será exportado.
@param	aTables Array: Define que as tabelas nele inclusas não receberão tratamento de filial e de deleção.
      Formato:  {'tabela1', 'tabela2', 'tabela3' ...} Exemplo: {'SA1', 'SB1'}

@author Wellington Coelho
@since 17/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCallCrys(cReportName, cParams, cOptions, lWaitRun, lShowGauge, lExportFromServer, aTables)
	Local lHtml	:= (GetRemoteType() == 5) //Valida se o ambiente é SmartClientHtml
	Local lServ	:= SuperGetMV('MV_JCRYSER',,.F.) //Pega a configuração do parâmetro

	If lHtml
		cOptions := '6' + SUBSTR(cOptions,2) //Muda as configurações enviadas ao CallCrys para que seja gerado um PDF.
		lServ    := .T. //força o parâmetro como .T. quando o ambiente for SmartClientHTML
		lShowGauge := .F. // Essa função na funciona no HTML.
	EndIf

//Chamada a função de frame CallCrys
	CallCrys(cReportName, cParams, cOptions, lWaitRun, lShowGauge, lServ, lExportFromServer, aTables)

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} JurCrLog(cMsgLog, cPathLog, cLogfile)
Rotina para gravar o log da operaçoes de relatório em segundo plano

@param   cMsgLog    Mensagem para ser gravada no log
@param   cPathLog   Caminho para gravar o arquivo de log. Por Pardão 'C:\'
@param   cLogfile   Nome do arquivo de log . Por Pardão 'crpfs.log'

@Return  lRet       .T. se gravou ou abriu o arquivo


@author  Luciano Pereira dos Santos
@since   09/12/2015
/*/
//---------------------------------------------------------------------------
Function JurCrLog(cMsgLog, cPathLog, cLogfile)
	Local nHandle  := 0
	Local cLogInf  := ''

	Default cLogfile := 'crpfs.log'
	Default cPathLog := JurFixPath( GetClientDir(), 0, 1 )

	If !Empty(cMsgLog)
		cLogInf := Replicate( '-', 100 ) + CRLF
		cLogInf += STR0039 + DToC( Date() ) + ' / ' + Time() + CRLF
		cLogInf += STR0045 + __cUserID + ' ' + CRLF
		cLogInf += cMsgLog + CRLF

		If !(File(cPathLog + cLogfile ))
			nHandle := FCreate( cPathLog + cLogfile )
		Else
			nHandle := FOpen( cPathLog + cLogfile, 2 )
		EndIf

		FSeek(nHandle, 0, 2)
		FWrite(nHandle, cLogInf  + CRLF)
		Fclose(nHandle)

	EndIf

Return (nHandle > 0)

//---------------------------------------------------------------------------
/*/{Protheus.doc} JurCopyS2T()
Função que verifica se o arquivo esta no servidor e copia o arquivo para
a pasta temporária do usuário retornando o novo caminho e nome do arquivo.

@param  cFile       Nome do arquivo gerado pelo Crystal Ex: Relatorio.pdf
@param  cFilePath  Caminho do arquivo no servidor Ex: 'D:\Protheus_Data\Relatorio', '\Relatorio'
@param  lAltName   Se .T. copia o arquivo com o nome acrescido de "_copia" Ex: Relatorio_copia.pdf
@Param  cMsgLog    Mensagem de log da rotina, variável passada por referência

@Return aRet      aRet[1]= caminho do arquivo, aRet[2]= Nome do arquivo

@author  Luciano Pereira dos Santos
@since   22/06/2015
/*/
//---------------------------------------------------------------------------
Function JurCopyS2T(cFile, cCrysPath, lAltName, lForce, cMsgLog, cDestPath)
	Local lRet       := .F.
	Local aArea     := GetArea()
	Local aRet      := {'', ''}
	Local cUsrPath  := ""
	Local nPos      := 0
	Local cUsrFile  := ""
	Local cSrvPath  := ""
	Local cTmpPath  := JurFixPath(GetTempPathAdmin(.T.), 0, 1) //Extrai o diretorio temp do usuário, retirado do crytal.prw
	Local lServer   := SuperGetMV('MV_JCRYSER',,.F.) //Verifica se é servidor
	Local cCopia    := STR0144 //#_Copia

	Default lAltName  := .F.
	Default lForce    := .F.
	Default cDestPath := ""

	If lServer .Or. lForce //Se é sevidor e copia o arquivo para a pasta temp do usuário

		If Empty(cDestPath)
			cUsrPath  := cTmpPath
		Else
			If SubStr(cDestPath, 2, 1) == ":" // Path Local C:\
				cUsrPath  := cDestPath
			Else
				cUsrPath  := cTmpPath
				cSrvPath  := cDestPath
			EndIf
		EndIf

		If (CpyS2TEx(cCrysPath + cFile, cUsrPath + cFile)) //copia para uma pasta temp do usuário
			lRet := .T.
		ElseIf (CpyS2T(cCrysPath + cFile, cUsrPath ))
			lRet := .T.
		Else
			cMsgLog += I18N("JurCopyS2T.: "+ STR0135, {cCrysPath + cFile}) //# "Não foi possível transferir o arquivo #1 para a estação de trabalho."
			aRet    := {cFile, cUsrPath}
		EndIf

		If lRet .And. !Empty(cSrvPath)
			If !CpyT2S( cUsrPath + cFile, cSrvPath)
				cMsgLog += I18N("JurCopyS2T.: "+ STR0135, {cCrysPath + cFile}) //# "Não foi possível transferir o arquivo #1 para a estação de trabalho."
				aRet    := {cFile, cSrvPath}
				lRet    := .F.
			EndIF
		EndIf

		If lRet
			If lAltName
				nPos := At(".", cFile)
				cUsrFile := SubStr(cFile, 1, nPos-1)+ cCopia + SubStr(cFile, nPos) //Sinaliza para o usuário que o arquivo se trata de uma cópia

				If File(cUsrPath+cUsrFile) //Verifica e apaga uma versão anterior do arquivo
					If FErase(cUsrPath + cUsrFile) == -1
						cMsgLog += "JurCopyS2T.: " + I18N(STR0143, {cUsrPath + cUsrFile} ) //# "Não foi possivel sobrescrever o arquivo '#1'."
					EndIf
				EndIf

				If FRename(cUsrPath+cFile, cUsrPath+cUsrFile) <= (-1)
					cUsrFile := cFile
				EndIf
			Else
				cUsrFile := cFile
			EndIf
			aRet  := {cUsrFile, cUsrPath}
		EndIf

	Else
		aRet  := {cFile, cCrysPath}
	EndIf

	RestArea(aArea)

Return aRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} JurCrysPath(cMsgLog)
Rotina para obter o caminho dos arquivos exportados pelo Crystal a partir do
Parametro MV_JCRYPAS, se preenchido ou da configuração da chave EXPORT do crysini.ini.

@Param  cMsgLog  mensagem de log da rotina, passada por referência

@Obs  Foi necessário criar a rotina pois não é possivel recuperar o local do arquivo
dentro da thread de relatório, que é vista pelo Protheus como um Job.
Se o servidor estiver rodando em Cloud, configure o caminho relativo a apartir do rootpath
no parametro MV_JCRYPAS Ex:'\Spool', Esse caminho deve coincidir com o item EXPORT do
pois rotinas como File(), ExistDir(), FErase()
executam local quando informado um caminho absoluto como '\\Totvs\Protheus_data\Spool' ou
'D:\Totvs\Protheus_data\Spool' causando erro.

@since   10/12/2015
/*/
//---------------------------------------------------------------------------
Function JurCrysPath(cMsgLog)
	Local cCrysIni   := 'crysini.ini'
	Local cCrysPas   := SuperGetMV("MV_JCRYPAS",,"" ) //Indica que os arquivos nao pode ser acessados por um caminho absoluto eu precisam estar de baixo do rootpath
	Local lServer    := .F. //Verifica se é servidor
	Local cRootPath  := ''
	Local cAppCrIni  := ''
	Local cMsgRet    := ''
	Local cDirCrIni  := ''

	Default cMsgLog  := ''

	If Empty(cCrysPas)
		lServer := SuperGetMV('MV_JCRYSER',,.F.)
		If lServer
			cRootPath := JurFixPath(GetSrvProfString("RootPath",""),0,1)
			cAppCrIni := JurFixPath( GetPvProfString( GetEnvServer(), "CRWINSTALLPATH", "" , GetADV97() ), 0, 1 ) //Extrai o diretorio da instalação do crystal, retirado do crytal.prw
			If (WaitRunSrv( "xcopy " + cAppCrIni+cCrysIni+" " + cRootPath +" /Y" , .T., "C:\" )) //É preciso copiar o arquivo para o rootpath para o protheus poder enxergar
				cDirCrIni := "\"
			Else
				cMsgLog += CRLF + "JurCrysPath.: " + I18N(STR0140, {cAppCrIni+cCrysIni, cRootPath+cCrysIni} ) //"Não foi possível copiar o arquivo '#1' para '#2'.
			EndIf
		Else
			cDirCrIni := JurFixPath( GetClientDir(), 0, 1 ) //Se nao é servidor, extrai o diretório do SmartClient da estação, esse comando não funciona em job
		EndIf

		cCrysPas := JurCrysInf('EXPORT', cCrysIni, cDirCrIni, @cMsgRet)[1][2] //Lê o item Export do crysini.ini utilizado
		If !Empty(cMsgRet)
			cMsgLog += CRLF + "JurCrysPath-> " + cMsgRet
		EndIf

		If lServer //Remove o arquivo temporário no servidor
			FErase(cDirCrIni+cCrysIni)
		EndIf

	Else
		cCrysPas := JurFixPath(cCrysPas, 1, 1) //Extrai do parametro MV_JCRYPAS
	EndIf

Return cCrysPas

//---------------------------------------------------------------------------
/*/{Protheus.doc} JurCrysInf(xItem, cCrysIni, cCryPath, cMsgLog)
Rotina para obter informação de item do arquivo de configuração Crysini.ini. Ex: EXPORT, PATHLOG

@Param  xItem        String ou array com os itens do arquivo de configuração Crysini.ini. Ex: EXPORT, ['LOG','PATHLOG']
@Param  cCrysIni     Nome do de configuração do Crystal. Por padrão: Crysini.ini.
@Param  cCryPath     Caminho do arquivo Crysini.ini. Obs: ver rotina JurCrysPath()
@Param  cMsgLog      cMsgLog  mensagem de log da rotina, passada por referência

@Return aRet        aRet[nI][1] Item do arquivo de configuração
                      aRet[nI][2] Informação do item do Crysini.ini
                      aRet[nI][3] Messagem de critica da rotina

@Obs Configurar o crysini.ini com item a ser extraido
Ex: "EXPORT=C:\Protheus\Protheus_Data\spool"

@author  Luciano Pereira dos Santos
@since   27/11/2015
/*/
//---------------------------------------------------------------------------
Function JurCrysInf(xItem, cCrysIni, cCryPath, cMsgLog)
	Local cBuffer    := ''
	Local cRetItem   := ''
	Local aRet       := {}
	Local cItem      := ''
	Local aItem      := {}
	Local nI         := 0

	Default cCrysIni := 'crysini.ini'
	Default cMsgLog  := ''

	If valtype(xItem) == "C"
		aItem := {xItem}
	Else
		aItem := aClone(xItem)
	EndIf

	If Empty(cCryPath)
		cMsgLog += CRLF + "JurCrysInf.: " + Iif(lServer, STR0136, I18N(STR0137, {cCrysIni}) ) //# "A chave CRWINSTALLPATH não está configurada no servidor!" ## "Não possivel recuperar o caminho do arquivo '#1' da estação."

		For nI := 1 to Len(aItem)
			AaDD(aRet, {aItem[nI] , '', cMsgLog})
		Next nI
	Else
		If (FT_FUse(cCryPath+cCrysIni) > -1) // Se houver erro de abertura abandona processamento

			For nI := 1 to Len(aItem)
				FT_FGoTop() // posiciona na primeira linha do arquivo
				cItem := Upper(AllTrim(aItem[nI]))
				While !(FT_FEof())
					cBuffer := AllTrim(FT_FReadLn()) // Retorna a linha corrente
					If Upper(Substr(cBuffer,1,Len(cItem))) == cItem
						cRetItem := Substr(cBuffer, At("=",cBuffer)+1, Len(cBuffer))
						Exit
					EndIf
					FT_FSkip() //Move o ponteiro para proxima linha
				EndDo

				If Empty( cRetItem )
					cMsgLog +=  CRLF + "JurCrysInf.: " + I18N(STR0138, {cItem, IIf(lServer,cCryIniServ,cCryPath) + cCrysIni}) //"Não foi possível obter o conteúdo do item '#1'. Verifique o arquivo '#2'."
					cRetItem := ""
				EndIf

				AaDD(aRet, {aItem[nI], cRetItem, cMsgLog})
			Next nI

			FT_FUse() // Fecha o Arquivo

		Else
			cMsgLog += CRLF + "JurCrysInf.: " + I18N(STR0139, {cCryPath+cCrysIni}) //"Não foi possível abrir o arquivo '#1'."
			For nI := 1 to Len(aItem)
				AaDD(aRet, {aItem[nI] , '', cMsgLog})
			Next nI
		EndIf
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurFixPath(cPath, nIniBar, nFimBar, cBar)
Rotina para fazer tratamento das barras em caminhos de diretorios

@Param  cPath      Caminho de diretório ser tratado pela rontina
@Param  nIniBar    1=Adiciona a barra no inicio; 2=Remove a barra. Por padrão: 0
@Param  nFimBar    1=Adiciona a barra no final; 2=Remove a barra. Por padrão: 0
@Param  cBar       Tipo de barra. Por padrão: "\"

@author Luciano Pereira dos Santos

@since 02/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurFixPath(cPath, nIniBar, nFimBar, cBar)
	Default cBar     := "\"
	Default nIniBar  := 0
	Default nFimBar  := 0

	If !Empty(cPath)
		cPath := Alltrim(cPath)
		cPath := StrTran(cPath, "\", cBar)
		cPath := StrTran(cPath, "/", cBar)

		If nIniBar == 1
			cPath := Iif( (Left(cPath,1) == cBar), cPath, "\" + cPath)
		ElseIf nIniBar == 2
			cPath := Iif( (Left(cPath,1) == cBar), Iif(SubStr(cPath,2,1) == cBar , cPath , SubStr(cPath,2)) , cPath) // Se for um caminho de rede '\\dir' não remove a barra
		EndIf

		If nFimBar == 1
			cPath := Iif( (Right(cPath,1) == cBar), cPath, cPath + "\" )
		ElseIf nFimBar == 2
			cPath := Iif( (Right(cPath,1) == cBar), SubStr(cPath,1,Len(cPath)-1) , cPath)
		EndIf
	EndIf

Return cPath

//-------------------------------------------------------------------
/*/{Protheus.doc} JurMvRelat
Função utilizada para imprimir, exibir em tela ou mover o relatório da
pasta EXPORT do crystal para a pasta a pasta do caminho de destino.

@Param   cArquivo   Nome do Arquivo
@Param   cDestPath  Caminho de destino para (pré-)fatura. Obs Ver JurImgPre e JurImgFat
@Param   cAction    Ação da rotina
					  1 - Imprime o arquivo
                      2 - Abre para visualização
                      3 - Copia o arquivo para a pasta de (pré-)fatura
                      4 - Copia o arquivo para a pasta de (pré-)fatura (Compatibilidade com resultado de emissão "Nenhum")
@Param    cMsgLog   Log da rotina, passada por referência
@Param    lImgRept  Impressão de Imagem - default .F.
@Return    aRet     aRet[1] .T. Se a rotina realizou a operação com exito
                    aRet[2] messagem de critica da rotina

@author Luciano Pereira dos Santos
@since 27/11/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurMvRelat(cArquivo, cCrysPath, cDestPath, cAction, cMsgLog, lImgRept)
Local lRet       := .T.
Local aArea      := GetArea()
Local lIsEmiPF   := FwIsInCallStack("J201Imprimi")
Local lOriginal  := (SuperGetMV("MV_JPFORIG",.F.,'2') == '1')
Local nVezes     := 0
Local lArqGerado := .F.
Local cMsgRet    := ''

Default cAction  := '2' //Visualizar
Default cMsgLog  := ''
Default lImgRept := .F.

	If !lImgRept
		cCrysPath := JurFixPath(cCrysPath, 0, 1)
	Else
		cCrysPath := cDestPath
	EndIf

	If ExistDir(cCrysPath)
		While !lArqGerado .And. nVezes <= 30
			lArqGerado := File(cCrysPath + cArquivo, 0, .T.)  //nome arquivo, local de pesquisa: 0 -indicado pelo nome / 1 - appserver / 2 - local, .T. - pesquisa mínusculo / .F. - como foi digitado
			If !lArqGerado
				Sleep(2000)
				nVezes += 1
			EndIf
		EndDo

		If lArqGerado
			If cAction $ "1|2|3|4" //Sempre copia o arquivo da (pré-)fatura se existir um diretorio de destino

				If !Empty(cDestPath)
					If (ExistDir(cDestPath))
						If !lImgRept
							If File(cDestPath+cArquivo)  //Apaga o arquivo antigo
								If FErase(cDestPath+cArquivo) == -1
									cMsgLog += CRLF + "JurMvRelat..: " + I18N(STR0143, {cDestPath+cArquivo} ) //# "Não foi possivel sobrescrever o arquivo '#1'."
									lRet := .F.
								EndIf
							EndIf

							If __COPYFILE( cCrysPath+cArquivo , cDestPath+cArquivo )
								If lOriginal .And. lIsEmiPF
									__COPYFILE( cCrysPath+cArquivo , cDestPath+Substr(cArquivo, 1, (Len(cArquivo) - 4))+"_ORIGINAL"+Right(cArquivo, 4) )
								EndIf
								FErase( cCrysPath+cArquivo )
							Else
								cMsgLog += CRLF + "JurMvRelat..: " + I18N(STR0140, {cCrysPath+cArquivo, cDestPath+cArquivo} ) //"Não foi possível copiar o arquivo '#1' para '#2'.
								lRet := .F.
							EndIf
						EndIf
					Else
						cMsgLog += CRLF + "JurMvRelat..: " + I18N(STR0142, {cDestPath, cArquivo}) //#"Não foi possivel localizar o diretório de destino '#1' para o arquivo '#2'."
						lRet := .F.
					EndIf
				Else
					lRet := .F.
				EndIf

				If lRet .And. (cAction $ "1|2" .Or. lImgRept)

					If !(lRet := JurOpenFile(cArquivo, cDestPath, cAction, .F., @cMsgRet, lImgRept))
						cMsgLog += CRLF + "JurMvRelat--> " + cMsgRet
					EndIf

				EndIf

			EndIf

		Else
			cMsgLog += CRLF + "JurMvRelat..: " + I18N(STR0139, {cCrysPath+ cArquivo}) //# "Não foi possível abrir o arquivo '#1'."
			lRet := .F.
		EndIf

	Else
		cMsgLog += CRLF + "JurMvRelat..: " + I18N(STR0141, {cArquivo, cCrysPath }) //# "Não foi possível localizar o diretório de origem '#1' para o arquivo '#2'."
		lRet := .F.
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurOpenFile(cArquivo, cPath, cAction, lShowErr, cMsgLog, lImgRept)
Função para abrir um arquivo do servidor

@Param cArquivo   Nome do arquivo
@Param cPath      Caminho do arquivo no servidor
@Param cAction    1 - Imprime o arquivo.
                  2 - Abre para visualização. Padrão
@Param lShowErr  .T. - Exibe a mensagem de erro
@Param cMsgLog   Log da rotina, passada por referência
@Param lImgRept  Impressão de Imagem do relatório - default  .F.

@Return  aRet     aRet[1] .T. (padrão) Se a rotina realizou a operação com exito
                    aRet[2] Messagem de critica da rotina

@author Luciano Pereira dos Santos

@since 27/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurOpenFile(cArquivo, cPath, cAction, lShowErr, cMsgLog, lImgRept)
Local aArea    := GetArea()
Local lRet     := .T.
Local nErro    := 0
Local aFile    := {}
Local cRetMsg  := ''

Default cAction  := "2" //Abrir
Default lShowErr := .T. //Abrir
Default cMsgLog  := ''
Default lImgRept := .F.

	If !(Empty(cArquivo) .Or. Empty(cPath))

		aFile    := JurCopyS2T(cArquivo, cPath, .T., .T. , @cRetMsg)
		cArquivo := aFile[1]
		cPath    := aFile[2]

		If Empty(cRetMsg)
			If cAction == "1"
				nErro := ShellExecute("Print", cPath+cArquivo, cPath, cPath, SW_HIDE )
			ElseIf cAction == "2" .Or. lImgRept
				nErro := ShellExecute("open" , cPath+cArquivo, cPath, cPath, SW_SHOW )
			EndIf

			If !(lRet := J204ShowEr(nErro, lShowErr, @cRetMsg))
				cMsgLog += CRLF + "JurOpenFile ->" + cRetMsg
			EndIf
		Else
			lRet := .F.
			cMsgLog += CRLF + "JurOpenFile ->" + cRetMsg
		EndIf

	EndIf

	RestArea(aArea)

Return lRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} JurInput ( cDescricao, cTitulo, nTamanho, lObrig )

Função que exibe uma janela na tela para que o usuário faça o input de uma string.
Exemplo:
cNome := JurInput("Informe um nome para o filtro:","Novo Filtro",40,.T.)

@param  cDescricao Descrição da informação
@param  cTitulo
@param  nTamanho
@param  lObrig
@author  André Spirigoni Pinto
@since   26/01/2015
/*/
//---------------------------------------------------------------------------
Function JurInput( cDescricao, cTitulo, nTamanho, lObrig )
	Local cRet := Space(nTamanho)
	Local oDlgInput
	Local oDesc
	Local oText

	Default lObrig := .F.

	oDlgInput := MSDialog():New(0,0,120,430,cTitulo,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

	oDesc := TSay():New(10,10,{||cDescricao},oDlgInput,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	@ 20,10 MSGET oText VAR cRet SIZE 200,8 Picture "@!" OF oDlgInput PIXEL

	DEFINE SBUTTON FROM 40,140 TYPE 1 ENABLE OF oDlgInput ACTION (VldInput(cRet, lObrig, oDlgInput)) // OK
	DEFINE SBUTTON FROM 40,170 TYPE 2 ENABLE OF oDlgInput ACTION (VldInput(cRet := "", .F., oDlgInput)) // CANCELA

	oDlgInput:Activate( , , , , , , ) // ATIVA A JANELA

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldInput
Função para validar se o campo cRet está preenchido.

@param cRet
@param lObrig
@param oDlgInput
@Return lRet
@author Ricardo Rampazzo
@since 08/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function VldInput(cRet, lObrig, oDlgInput)
	Local lRet := .T.
	If lObrig .AND. Empty(cRet)
		Alert(STR0131) // Campo obrigatório
		lRet := .F.
	EndIf

	If lRet
		oDlgInput:End()
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSumHora
Função que realiza a soma de duas horas informadas.

@Return cRet	   String com a hora atual.
@author André Spirigoni Pinto
@since 20/02/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSumHora(cHora1,cHora2,lLimDia,nSumDay)
	Local cRet
	Local nHorIni := 0
	Local nHorAdd := 0
	Local nMinIni := 0
	Local nMinAdd := 0
	Local nHora   := 0
	Local nMinutos:= 0

	Default lLimDia := .F.

	nSumDay := 0

	cHora1 := AllTrim(cHora1)
	cHora2 := AllTrim(cHora2)

	nHorIni := Val(Substring(cHora1,1,2))
	nHorAdd := Val(Substring(cHora2,1,2))

	nMinIni := Val(Substring(cHora1,3,2))
	nMinAdd := Val(Substring(cHora2,3,2))

	nMinutos := nMinIni + nMinAdd
	nHora := nHorIni + nHorAdd

	If nMinutos >= 60
		nHora++
		nMinutos := nMinutos - 60
	EndIf

	If lLimDia .AND. nHora > 24
		nHora    := 23
		nMinutos := 59
	ElseIf nHora > 24
		nSumDay := NOROUND(nHora/24,0)
		nHora   := ABS((24 * nSumDay) - nHora)
	ElseIf nHora == 24
		nSumDay := 1
		nHora   := 0
	EndIf

	cRet := PADL(AllTrim(str(nHora)),2,"0") + ":" + PADL(AllTrim(str(nMinutos)),2,"0")

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JurFormat(cCampo, lAcentua, lPontua)
Função utilizada para formatar o conteudo a ser pesquisado.

@param  cCampo Nome do campo
@param  lAcentua Se deve ou não ser tratada a acentuação
@param  lPontua Se deve ou não ser tratada a pontuação

@Return cRet	   Replace formatado.
@author Wellington Coelho
@since 24/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurFormat(cCampo, lAcentua, lPontua, cPrefixTb, lFullClear, lEspecial)
	Local cRet     := ""
	Local cBanco   := Upper(TcGetDb())

	Default cPrefixTb  := ""
	Default lFullClear := .F.
	Default lEspecial  := .F.

	If !Empty(cPrefixTb)
		cPrefixTb := cPrefixTb + '.'
	EndIf

	If Len(cCampo) < 11
		cRet :=	JurLower(TamSx3(cCampo)[3],cPrefixTb + cCampo, cBanco)
	Else
		cRet :=	JurLower('M',cPrefixTb + cCampo, cBanco)
	EndIf


	If (lAcentua)
		cRet :=	" REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(" + cRet
		cRet :=	" REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(" + cRet
		cRet +=	",'à','a'),'á','a'),'â','a'),'ã','a'),'°','o'),'º','o'),'ª','a'),'''',' '),"
		cRet +=	"'ç','c'),'é','e'),'ê','e'),'è','e'),'í','i'),'ì','i'),'î','i'),' ',' '),"
		cRet +=	"'ó','o'),'ò','o'),'õ','o'),'ô','o'),'ú','u'),'ù','u'),'û','u'),'ü','u') "
	EndIf

	If (lPontua)
		cRet :=	" REPLACE(REPLACE(REPLACE(REPLACE(" + cRet +	",'.',''),',',''),'-',' '),'/','') "
	EndIf

	If (lFullClear)
		cRet := " REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(" + cRet
		cRet := " REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(" + cRet
		cRet += ",'(','#'),')','#'),'!','#'),'?','#'),'[','#'),']','#')"
		cRet += ",'/','#'),'\','#'),':','#'),';','#'),'{','#'),'}','#') "
	EndIf

	If (lEspecial)
		cRet := " REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(" + cRet
		cRet := " REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(" +cRet
		cRet += ",'\',''),';',''),':',''),'!',''),'(',''),')',''),'+',''),'=',''),'[',''),']',''),'{',''),'}',''),'~','')"
		cRet += ",'<',''),'>',''),'|',''),'?',''),'¨',''),'`',''),'@',''),'#',''),'$',''),'%',''),'&',''),'*','') "
	EndIf


Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} JurLower(cTipoCpo, cCampo, cBanco)
Função utilizada para validar a conversão do campo para formar o replace

@param  cCampo Nome do campo
@param  cTipoCpo Tipo do campo
@param  cBanco Nome do banco de dados

@Return cRet	   conteudo formatado.
@author Wellington Coelho
@since 29/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurLower(cTipoCpo, cCampo, cBanco)

	Local cRet := ""

	Default cBanco := Upper( TcGetDb() )

	Do Case
	Case cBanco $ "MSSQL/MSSQL7" .And. cTipoCpo == "M"
		cRet += "Lower(CAST("+ cCampo + " AS VARCHAR(MAX))) "

	Case cBanco == "DB2" .And. cTipoCpo == "M"
		cRet += "Lower(CAST(" +  cCampo + " AS VARCHAR(32000))) "

	Otherwise
		cRet += "Lower(" +  cCampo + ") "
	EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FEXP_ENVC
Função para formula da exportação personalizada, que retorna os envolvidos concatenados

@Param  aParams:    Array de parâmetros da função
		aParams[1]: NT9_CAJURI
		aParams[2]: NT9_TIPOEN
		aParams[3]: 'All' Indica que usará cache

da formula na exportação personalizada
@Return xRet	Resultado da formula

@author Wellington Coelho
@since 03/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
FUNCTION FEXP_ENVC ( aParams )
Local aArea      := GetArea()
Local aNomes     := {}
Local cLista     := GetNextAlias()
Local cSQL       := ""
Local cQryFrom   := ""
Local cQryWhere  := ""
Local cQrySelect := ""
Local cChave     := ""
Local xRet       := ""
Local lTemFila   := JCheckFila()

	If(len(aParams) < 3 )
		aAdd(aParams, '')
		aAdd(aParams, SubStr(AllTrim(Str(ThreadId())),1,4))

	EndIf
	
	aParams[2] := StrTran(aParams[2],"'","")

	cQrySelect := " SELECT NT9.NT9_FILIAL, "
	cQrySelect +=        " NT9.NT9_CAJURI, "
	cQrySelect +=        " NT9.NT9_NOME "

	cQryFrom   := " FROM " + RetSQLName("NT9") + " NT9 "

	If lTemFila
		cQryFrom   += " INNER JOIN " + RetSQLName("NQ3") + " NQ3 "
		cQryFrom   +=   " ON ( NQ3.NQ3_CAJURI = NT9.NT9_CAJURI "  
		cQryFrom   +=        " AND NQ3.NQ3_CUSER  = '"+__CUSERID+"'" 
		cQryFrom   +=        " AND NQ3.NQ3_SECAO  = '" + aParams[4] + "'" 
		cQryFrom   +=        " AND NQ3.NQ3_FILORI = NT9.NT9_FILIAL)" 
	EndIf
	
	cQryWhere  := " WHERE NT9.D_E_L_E_T_ = ' '" 
	cQryWhere  +=   " AND NT9.NT9_TIPOEN = '" + aParams[2] + "'" 

	If aParams[3] != "All" .Or. !lTemFila
		cQryWhere  +=   " AND NT9.NT9_CAJURI = '" + aParams[1] + "'" 
		aParams[3] := "One"
	EndIf

	cSQL := cQrySelect + cQryFrom + cQryWhere

	cSQL += " ORDER BY NT9_FILIAL, NT9_CAJURI"

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL ), cLista,.T.,.T.)

	dbSelectArea(cLista)
	(cLista)->(dbGoTop())

	While (cLista)->(!Eof())

		If cChave <> (cLista)->NT9_FILIAL + (cLista)->NT9_CAJURI
			If !Empty(xRet)
				aAdd(aNomes, {cChave,substr(xRet,3)})
				xRet := ""
			EndIf
			cChave := (cLista)->NT9_FILIAL + (cLista)->NT9_CAJURI 
		EndIf

		xRet += " / " + Alltrim((cLista)->NT9_NOME)

		(cLista)->(dbSkip())
	End

	(cLista)->( dbcloseArea() )
	aAdd(aNomes, {cChave,substr(xRet,3)})

	If aParams[3] == "All"
		xRet := aNomes
	Else
		xRet := aNomes[1][2]
	EndIf

	RestArea( aArea )

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FEXP_PEDC
Função para formula da exportação personalizada, que retorna os pedidos concatenados

@Param  aParams:    Array de parâmetros da função
		aParams[1]: NSY_CAJURI
		aParams[2]: 'All' Indica que usará cache

@Return xRet	Resultado da formula

@author Wellington Coelho
@since 15/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
FUNCTION FEXP_PEDC ( aParams )
Local aArea    := GetArea()
Local aPedidos := {}
Local cLista   := GetNextAlias()
Local cQuery   := ""
Local cChave   := ""
Local xRet     := ""
Local lTemFila := JCheckFila()
Local lO0WInDic:= FwAliasinDIc('O0W')

	If(len(aParams) < 2 )
		aAdd(aParams, '')
		aAdd(aParams, SubStr(AllTrim(Str(ThreadId())),1,4))

	EndIf
	cQuery := " SELECT PEDIDO, CAJURI, FILIAL FROM ( "
	cQuery += " SELECT NSP.NSP_DESC PEDIDO, "
	cQuery +=        " NSY_CAJURI CAJURI, "
	cQuery +=        " NSY_FILIAL FILIAL "
	cQuery +=   " FROM " + RetSQLName("NSP") + " NSP "
	
	cQuery += " INNER JOIN " + RetSQLName("NSY") + " NSY "
	cQuery +=     " ON ( NSP.NSP_FILIAL = '" + xFilial("NSP") + "'"
	cQuery +=          " AND NSY.NSY_CPEVLR = NSP.NSP_COD"

	If (lO0WInDic)
		cQuery +=          " AND NSY.NSY_CVERBA = '"+ PADR(' ', TamSx3("NSY_CVERBA")[1]) + "'"
	EndIf

	cQuery +=          " AND NSY.D_E_L_E_T_ = ' ' )"

	If lTemFila
		cQuery += " INNER JOIN " + RetSQLName("NQ3") + " NQ3 "
		cQuery +=   " ON ( NQ3.NQ3_CAJURI = NSY.NSY_CAJURI "  
		cQuery +=        " AND NQ3.NQ3_FILORI = NSY.NSY_FILIAL "
		cQuery +=        " AND NQ3.NQ3_CUSER  = '"+__CUSERID+"'" 
		cQuery +=        " AND NQ3.NQ3_SECAO  = '" + aParams[3] + "' )" 
	EndIf

	cQuery += " WHERE  NSP.D_E_L_E_T_ = ' '"
	
	If aParams[2] != "All" .Or. !lTemFila
		cQuery +=   " AND NSY.NSY_CAJURI = '" + aParams[1]+"'"
		aParams[2] := "One"
	EndIf

	if lO0WInDic
		cQuery += "UNION"

		cQuery += " SELECT NSP.NSP_DESC PEDIDO, "
		cQuery +=        " O0W_CAJURI CAJURI, "
		cQuery +=        " O0W_FILIAL FILIAL "
		cQuery +=   " FROM " + RetSQLName("NSP") + " NSP "

		cQuery += " INNER JOIN " + RetSQLName("O0W") + " O0W "
		cQuery +=     " ON ( NSP.NSP_FILIAL = '" + xFilial("NSP") + "'"
		cQuery +=          " AND O0W.O0W_CTPPED = NSP.NSP_COD"
		cQuery +=          " AND O0W.D_E_L_E_T_ = ' ' )"

		If lTemFila
			cQuery += " INNER JOIN " + RetSQLName("NQ3") + " NQ3 "
			cQuery +=   " ON ( NQ3.NQ3_CAJURI = O0W.O0W_CAJURI "  
			cQuery +=        " AND NQ3.NQ3_FILORI = O0W.O0W_FILIAL "
			cQuery +=        " AND NQ3.NQ3_CUSER  = '"+__CUSERID+"'" 
			cQuery +=        " AND NQ3.NQ3_SECAO  = '" + aParams[3] + "' )" 
		EndIf

		cQuery += " WHERE  NSP.D_E_L_E_T_ = ' '"
		
		If aParams[2] != "All" .Or. !lTemFila
			cQuery +=   " AND O0W.O0W_CAJURI = '" + aParams[1]+"'"
			aParams[2] := "One"
		EndIf

	Endif

	cQuery += ") PEDIDOS ORDER BY FILIAL, CAJURI "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery ), cLista,.T.,.T.)

	dbSelectArea(cLista)
	(cLista)->(dbGoTop())

	While (cLista)->(!Eof())

		If cChave <> (cLista)->FILIAL + (cLista)->CAJURI
			If !Empty(xRet)
				aAdd(aPedidos, {cChave,substr(xRet,3)})
				xRet := ""
			EndIf
			cChave := (cLista)->FILIAL + (cLista)->CAJURI 
		EndIf

		xRet += " / " + Alltrim((cLista)->PEDIDO)
	
		(cLista)->(dbSkip())
	End

	(cLista)->( dbcloseArea() )

	aAdd(aPedidos, {cChave,substr(xRet,3)})

	If aParams[2] == "All"
		xRet := aPedidos
	Else
		xRet := aPedidos[1][2]
	EndIf

	RestArea( aArea )

Return xRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FEXP_FASE
Função para formula da exportação personalizada, que retorna a fase processual 

@Param  aParams:    Array de parâmetros da função
		aParams[1]: NT4_CAJURI
		aParams[2]: NT4_FILIAL
		aParams[3]: 1 / 2 : 1 - Retorna o código / 2 - Retorna a descrição 
		aParams[4]: 'All' Indica que usará cache

@Return xRet	Resultado da formula

@since 11/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
FUNCTION FEXP_FASE ( aParams )
Local aArea   := GetArea()
Local aFase   := {}
Local cLista  := GetNextAlias()
Local cQuery  := ""
Local lCodigo := .F.
Local xRet    := ""
Local cChave  := ""
Local lTemFila   := JCheckFila()


	if (len(aParams) < 3)
		aAdd(aParams,'2')
	EndIf

	if (len(aParams) < 4)
		aAdd(aParams,'')
		aAdd(aParams,SubStr(AllTrim(Str(ThreadId())),1,4))
	EndIf
	
	lCodigo := ( "1" $ aParams[3]) //  1 Retorna o código / 2 - Retorna a descrição

	cQuery += "SELECT NT4.NT4_FILIAL, " 
	cQuery += 	  " NT4.NT4_CAJURI, "
	cQuery += 	  " NQG.NQG_COD, "
	cQuery += 	  " NQG.NQG_DESC "
	cQuery +=  " FROM " + RetSqlName("NT4") + " NT4 "
	cQuery += " INNER JOIN " + RetSqlName("NQG") + " NQG "
	cQuery += 	" ON (NT4.NT4_CFASE = NQG_COD) "

	If lTemFila
		cQuery += " INNER JOIN " + RetSQLName("NQ3") + " NQ3 "
		cQuery +=   " ON ( NQ3.NQ3_CAJURI = NT4.NT4_CAJURI "  
		cQuery +=        " AND NQ3.NQ3_FILORI = NT4.NT4_FILIAL "
		cQuery +=        " AND NQ3.NQ3_CUSER  = '"+__CUSERID+"'" 
		cQuery +=        " AND NQ3.NQ3_SECAO  = '" + aParams[5] + "' )"
	EndIf

	cQuery += " WHERE NT4.R_E_C_N_O_ IN ( SELECT MAX( RECNO) MAX_RECNO "
	cQuery += 							" FROM( SELECT B.NQG_COD, " 
	cQuery += 										" B.NQG_DESC, " 
	cQuery += 										" PRIO.PRIORIDADE, " 
	cQuery += 										" A.NT4_FILIAL, " 
	cQuery += 										" A.NT4_CAJURI, " 
	cQuery += 										" A.NT4_CFASE, " 
	cQuery += 										" A.R_E_C_N_O_ RECNO "
	cQuery += 									" FROM " + RetSqlName("NT4") + " A "
	cQuery += 								" INNER JOIN " + RetSqlName("NQG") + " B "
	cQuery += 									" ON (B.NQG_COD = A.NT4_CFASE "
	cQuery += 									     " AND B.NQG_FILIAL = '" + xFilial("NQG") + "' "
	cQuery += 									     " AND B.D_E_L_E_T_ = ' ') "
	cQuery += 								" INNER JOIN "
	cQuery += 									" ( SELECT MAX(NQG.NQG_PRIORI) PRIORIDADE, " 
	cQuery += 											 " NT4.NT4_FILIAL, " 
	cQuery += 											 " NT4.NT4_CAJURI "
	cQuery += 									   " FROM " + RetSqlName("NT4") + " NT4 "
	cQuery += 									  " INNER JOIN " + RetSqlName("NQG") + " NQG "
	cQuery += 										 " ON (NT4_CFASE = NQG.NQG_COD "
	cQuery += 											" AND NQG.NQG_FILIAL = '" + xFilial("NQG") + "' "
	cQuery += 											" AND NQG.D_E_L_E_T_ = ' ') "
	cQuery += 									  " GROUP BY NT4.NT4_FILIAL, NT4.NT4_CAJURI ) PRIO "
	cQuery += 								  " ON( A.NT4_FILIAL = PRIO.NT4_FILIAL "
	cQuery += 										" AND A.NT4_CAJURI = PRIO.NT4_CAJURI "
	cQuery += 										" AND B.NQG_PRIORI = PRIO.PRIORIDADE) ) FASE "
	cQuery += 						" GROUP BY FASE.NT4_FILIAL, FASE.NT4_CAJURI ) "

	If aParams[4] != "All" .Or. !lTemFila
		cQuery +=   " AND NT4_FILIAL = '" + aParams[2] + "'"
		cQuery +=   " AND NT4_CAJURI = '" + aParams[1] + "'"
		aParams[4] := "One"
	EndIf

	cQuery += " ORDER BY NT4_FILIAL, NT4_CAJURI"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cLista, .T., .T.)

	dbSelectArea(cLista)
	(cLista)->(dbGoTop())

	While (cLista)->(!Eof())

		cChave := (cLista)->NT4_FILIAL + (cLista)->NT4_CAJURI

		If lCodigo
			xRet := (cLista)->NQG_COD
		Else
			xRet := (cLista)->NQG_DESC
		EndIf

		If !Empty(xRet)
			aAdd(aFase, {cChave,AllTrim(xRet)})
			xRet := ""
		EndIf

		(cLista)->(dbSkip())
	End

	(cLista)->( dbcloseArea() )

	aAdd(aFase, {cChave,AllTrim(xRet)})

	If aParams[4] == "All"
		xRet := aFase
	Else
		xRet := aFase[1][2]
	EndIf

	RestArea(aArea)

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FEXP_PROV
Função de exemplo para formulas da exportação personalizada, que retorna a soma dos objetos do processo, por prognóstico.

@Param  aParametro  [] O tamanho e posições dos parametros do Array, estão de acordo com o cadastro
da formula na exportação personalizada
aParametro  [1] Numero do processo (NSY_CAJURI)
aParametro  [2] Filial do processo (NSY_FILIAL)
aParametro  [3] Prognóstico - 1=Provavel;2=Possivel;3=Remoto;4=Incontroverso
aParametro  [4] Define se o valor retornado será o valor atualizado - 1 Atualizado 2 Original
aParametro  [5] 'All' Define se usa cache ou não

@Return xRet Resultado da formula

@since 11/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
FUNCTION FEXP_PROV ( aParams )
Local aArea      := GetArea()
Local aAreaNSY   := NSY->( GetArea() )
Local nTotal     := 0
Local aTotal     := {}
Local cTabela    := ""
Local cQuery     := ""
Local lPedidos   := .F.
Local cChave     := ""
Local xRet       := 0
Local lAtual     := .F.
Local cProcesso  := aParams[1]
Local cTipoProv  := StrTran(aParams[3],"'","")
Local cFilNsy    := aParams[2]
Local lVlrCorrec := .F.
Local lTemFila   := JCheckFila()

	if (len(aParams) < 4)
		Aadd(aParams, "2")
	Endif

	aParams[4] := StrTran(aParams[4],"'","")

	lAtual:= (aParams[4] == "1") //1 - Atualizado, 2 - Original

	if (len(aParams) < 5)
		Aadd(aParams, "")
	Endif


	//Verifica se existe ponto de entrada que irá retornar o valor dos objetos por tipo de provisão
	If ExistBlock("J94VLDIS")
		nTotal := ExecBlock("J94VLDIS", .F., .F., {cProcesso, cTipoProv, lAtual})
		aAdd(aTotal, nTotal)
		aAdd(aTotal, SubStr(AllTrim(Str(ThreadId())),1,4))
	Else
		
		//Verifica se a rotina de Pedidos foi implementada
		DBSelectArea("NSY")
		lPedidos := NSY->( FieldPos('NSY_CVERBA') ) > 0
		NSY->( DBCloseArea() )

		cQuery := " SELECT NSY_FILIAL, NSY.NSY_CAJURI, "
		cQuery +=        " ISNULL( SUM ( " 

		//Valores atualizados
		If lAtual

			If lPedidos
				cQuery += "( CASE WHEN NSY_CVERBA <> '' THEN ( "
				cQuery +=         " ISNULL( (CASE WHEN NSY_DTCONT > ''  THEN NSY_VLCONA ELSE NSY_PEVLRA END), 0)"
				cQuery +=         " + ISNULL( (CASE WHEN NSY_TRVLRA > 0 THEN NSY_TRVLRA ELSE NSY_TRVLR  END), 0)"
				cQuery +=         " + ISNULL( (CASE WHEN NSY_MUATT  > 0 THEN NSY_MUATT  ELSE NSY_VLRMT  END), 0)"
				cQuery +=         " + ISNULL( (CASE WHEN NSY_V2VLRA > 0 THEN NSY_V2VLRA ELSE NSY_V2VLR  END), 0)"
				cQuery +=         " + ISNULL( (CASE WHEN NSY_MUATU2 > 0 THEN NSY_MUATU2 ELSE NSY_VLRMU2 END), 0)"
				cQuery +=         " + ISNULL( (CASE WHEN NSY_V1VLRA > 0 THEN NSY_V1VLRA ELSE NSY_V1VLR  END), 0))" //Se tiver dados de pedidos feito pela tela nova, soma a multa, honorário e encargo.
				cQuery += " ELSE (CASE WHEN NSY_DTCONT > '' THEN NSY_VLCONA"
				cQuery +=            " WHEN NSY_TRDATA > '' THEN NSY_TRVLRA"
				cQuery +=            " WHEN NSY_DTJUR2 > '' THEN NSY_V2VLRA"
				cQuery +=            " WHEN NSY_V1DATA > '' THEN NSY_V1VLRA"
				cQuery +=       " ELSE NSY_PEVLRA END)"
				cQuery += " END)), 0) TOTAL "

				If lVlrCorrec
					cQuery += ", ISNULL( SUM( "
					cQuery +=                    " (CASE WHEN NSY_DTCONT > '' THEN NSY_CCORPC"
					cQuery +=                          " WHEN NSY_TRDATA > '' THEN NSY_CCORPT"
					cQuery +=                          " WHEN NSY_DTJUR2 > '' THEN NSY_CCORP2"
					cQuery +=                          " WHEN NSY_V1DATA > '' THEN NSY_CCORP1"
					cQuery +=                          " ELSE NSY_CCORPE END)), 0 ) CORRECAO,"
					cQuery += " ISNULL( SUM( "
					cQuery +=                    " (CASE WHEN NSY_DTCONT > '' THEN NSY_CJURPC"
					cQuery +=                          " WHEN NSY_TRDATA > '' THEN NSY_CJURPT"
					cQuery +=                          " WHEN NSY_DTJUR2 > '' THEN NSY_CJURP2"
					cQuery +=                          " WHEN NSY_V1DATA > '' THEN NSY_CJURP1"
					cQuery +=                          " ELSE NSY_CJURPE END)), 0 ) JUROS"
				EndIf

			Else
				cQuery += " (CASE WHEN NSY_DTCONT > '' THEN NSY_VLCONA"
				cQuery += 		" WHEN NSY_TRDATA > '' THEN NSY_TRVLRA"
				cQuery += 		" WHEN NSY_DTJUR2 > '' THEN NSY_V2VLRA"
				cQuery += 		" WHEN NSY_V1DATA > '' THEN NSY_V1VLRA"
				cQuery += " ELSE NSY_PEVLRA END)) "
				cQuery +=			            ", 0) TOTAL "

				If lVlrCorrec
					cQuery += ", ISNULL( SUM( "
					cQuery +=                    " (CASE WHEN NSY_DTCONT > '' THEN NSY_CCORPC END)), 0 ) CORRECAO, "
					cQuery += " ISNULL( SUM( "
					cQuery +=                    " (CASE WHEN NSY_DTCONT > '' THEN NSY_CJURPC END)), 0 ) JUROS"
				EndIf
			EndIf

			//Valores normais
		Else
			cQuery += " (CASE WHEN NSY_DTCONT > '' THEN NSY_VLCONT"
			cQuery += 		" WHEN NSY_TRDATA > '' THEN NSY_TRVLR"
			cQuery += 		" WHEN NSY_DTJUR2 > '' THEN NSY_V2VLR"
			cQuery += 		" WHEN NSY_V1DATA > '' THEN NSY_V1VLR"
			cQuery += " ELSE NSY_PEVLR END)) "
			cQuery +=			            ", 0) TOTAL "
		EndIf

		cQuery += " FROM " +RetSqlName("NSY")+ " NSY INNER JOIN " +RetSqlName("NQ7")+ " NQ7 "
		cQuery +=   " ON NQ7_FILIAL = '" +xFilial("NQ7") + "' AND NSY_CPROG = NQ7_COD "

		If lTemFila
			cQuery += " INNER JOIN " + RetSQLName("NQ3") + " NQ3 "
			cQuery +=   " ON ( NQ3.NQ3_CAJURI = NSY.NSY_CAJURI "  
			cQuery +=        " AND NQ3.NQ3_FILORI = NSY.NSY_FILIAL "
			cQuery +=        " AND NQ3.NQ3_CUSER  = '"+__CUSERID+"'" 
			cQuery +=        " AND NQ3.NQ3_SECAO  = '" + aParams[6] + "' )" 
		EndIf


		cQuery += " WHERE NQ7_TIPO = '" + cTipoProv + "' "//1=Provavel;2=Possivel;3=Remoto
		cQuery +=       " AND NSY.D_E_L_E_T_ = ' ' "
		cQuery +=       " AND NQ7.D_E_L_E_T_ = ' ' "

		If aParams[5] != "All" .Or. !lTemFila
			cQuery +=   " AND NSY_FILIAL = '" + cFilNsy + "' "
			cQuery +=   " AND NSY_CAJURI = '" + cProcesso + "' "
			aParams[5] := "One"
		EndIf

		cQuery += " GROUP BY NSY_CAJURI, NSY_FILIAL "
		cQuery += " ORDER BY NSY_CAJURI, NSY_FILIAL "

		cQuery  := ChangeQuery(cQuery)
		cTabela := GetNextAlias()

		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTabela, .F., .T.)

		While (cTabela)->(!Eof())
			cChave := (cTabela)->NSY_FILIAL + (cTabela)->NSY_CAJURI
			xRet := (cTabela)->TOTAL
			aAdd(aTotal, {cChave, xRet})

			(cTabela)->(dbSkip())
		End

		(cTabela)->( DbCloseArea() )
	EndIf

	aAdd(aTotal, {cChave, xRet})

	If aParams[5] == "All"
		xRet := aTotal
	Else
		xRet := aTotal[1][2]
	EndIf

	RestArea( aAreaNSY )
	RestArea( aArea )

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FEXP_DESP
Função para formula da exportação personalizada, que retorna a somatória das despesas

@Param  aParams:    Array de parâmetros da função
		aParams[1]: NT3_CAJURI
		aParams[2]: 'All' Indica que usará cache

@Return xRet	Resultado da formula

@since 13/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
FUNCTION FEXP_DESP ( aParams )
Local aArea    := GetArea()
Local aDesp    := {}
Local cLista   := GetNextAlias()
Local cQuery   := ""
Local cChave   := ""
Local xRet     := 0
Local lTemFila := JCheckFila()

	If Len(aParams) < 2
		aAdd(aParams, '')
		aAdd(aParams, SubStr(AllTrim(Str(ThreadId())),1,4) )
	EndIf

	cQuery := " SELECT NT3.NT3_FILIAL, "
	cQuery +=        " NT3.NT3_CAJURI, "
	cQuery +=        " SUM( ISNULL( NT3.NT3_VALOR, 0 ) ) TOTAL_DESPESAS"
	cQuery +=  " FROM " + RetSqlName("NT3") + " NT3 "

	If lTemFila
		cQuery += " INNER JOIN " + RetSQLName("NQ3") + " NQ3 "
		cQuery +=   " ON ( NQ3.NQ3_CAJURI = NT3.NT3_CAJURI "
		cQuery +=        " AND NQ3.NQ3_FILORI = NT3.NT3_FILIAL "
		cQuery +=        " AND NQ3.NQ3_CUSER  = '" + __CUSERID + "'"
		cQuery +=        " AND NQ3.NQ3_SECAO  = '" + aParams[3] + "' )"
	EndIf

	cQuery +=  " WHERE NT3.D_E_L_E_T_ = ' ' "
	
	If aParams[2] != "All" .Or. !lTemFila
		cQuery+= " AND NT3.NT3_CAJURI = '" + aParams[1] + "' "
		aParams[2] := "One"
	EndIf

	cQuery += " GROUP BY NT3_CAJURI, NT3_FILIAL "
	cQuery += " ORDER BY NT3_CAJURI, NT3_FILIAL "

	cQuery  := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cLista, .T., .T.)

	dbSelectArea(cLista)
	(cLista)->(dbGoTop())

	While (cLista)->(!Eof())

		cChave := (cLista)->NT3_FILIAL + (cLista)->NT3_CAJURI
		xRet := (cLista)->TOTAL_DESPESAS
		aAdd(aDesp, {cChave, xRet})

		(cLista)->(dbSkip())
	End

	(cLista)->( dbcloseArea() )

	aAdd(aDesp, {cChave,xRet})

	If aParams[2] == "All"
		xRet := aDesp
	Else
		xRet := aDesp[1][2]
	EndIf

	RestArea( aArea )

Return xRet
//-------------------------------------------------------------------
/*/{Protheus.doc} JDocFluig
Função de envio arquivos para o Fluig

@Param cNomArq Caminho do arquivo que deve ser enviado ao FLUIG
@Param cPasta Id da pasta destino no Fluig

@Return cDocID   Id do documento criado no fluig

@author André Spirigoni Pinto
@since 04/11/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JDocFluig(cNomArq, cPasta)
	Local oWsdl        := Nil
	Local xRet         := ""
	Local aSimple      := {}
	Local aComplex     := {}
	Local cErro        := ""
	Local cAviso       := ""
	Local cFilecontent := ""
	Local cIdDoc       := "0"
	Local cUsuario     := SuperGetMV('MV_ECMUSER',,'')
	Local cSenha       := SuperGetMV('MV_ECMPSW',,'')
	Local cEmpresa     := SuperGetMV('MV_ECMEMP',,'0')
	Local cColId       := JColId(cUsuario,cSenha,cEmpresa,cUsuario)
	Local cUrl         := StrTran(AllTrim(JFlgUrl())+"/ECMDocumentService?wsdl","//E","/E") //URL do Web Service
	Local cPathCab     := ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_CREATESIMPLEDOCUMENTRESPONSE:_RESULT:_ITEM"
	Local cBuffer      := SPACE(512)
	Local cCodArq      := 0  // Grava o ID do arquivo
	Local nOccurs      := 0
	Local nBytes       := 0
	Local nTam         := 0
	Local nBloco       := 524288
	Local lServer      := .F. //indica se o arquivo foi copiado para o server

	//Copia para o server para melhorar a performance, apenas se o arquivo for local
	If (At(':\',cNomArq)>0 .And. CpyT2S(cNomArq, "/spool/", .t. ))
		cNomArq := "\SPOOL\" +  substr(substr(cNomArq,RAT("/",cNomArq)+1),RAT("\",cNomArq)+1)
		lServer := .T.
	EndIf

	cCodArq := FOPEN(cNomArq,0)  // Grava o ID do arquivo

	//Le os bytes do arquivo que será enviado ao FLUIG.
	While (nBytes := FREAD(cCodArq, @cBuffer, nBloco)) > 0      // Lê os bytes
        cBuffer := Encode64(cBuffer)
        cFilecontent += cBuffer 
        cBuffer := ''
		nTam := nTam + nBytes
	End

	FCLOSE(cCodArq)

	if lServer //apaga o arquivo que foi copiado para o server antes subir para o fluig.
		FERASE(cNomArq)
	Endif

	//Cria e conecta no Wsdl
	oWsdl := JurConWsdl(cUrl, @xRet)

	If !Empty(xRet)
		Return ""
	Endif

	// Define a operação
	xRet := oWsdl:SetOperation( "createSimpleDocument" )
	if xRet == .F.
		xRet := oWsdl:cError
		Return ""
	Endif

	//Alterada a locação pois o wsdl do fluig traz o endereço como localhost.
	oWsdl:cLocation := StrTran(AllTrim(JFlgUrl())+"/ECMDocumentService","//E","/E")

	// Lista os tipos complexos da mensagem de input envolvida na operação e informa que será enviado um anexo.
	aComplex := oWsdl:NextComplex()
	While ValType( aComplex ) == "A"
		If  (aComplex[2] == "item") .And. (aComplex[5] == "Attachments#1")
			nOccurs := 1
		Else
			nOccurs := 0
		EndIf

		xRet := oWsdl:SetComplexOccurs( aComplex[1], nOccurs )
		if xRet == .F.
			xRet := I18N(STR0133,{aComplex[2],cValToChar( aComplex[1] ),cValToChar( nOccurs )}) //"Erro ao definir elemento #1, ID #2, com #3 ocorrencias"
			Return ""
		endif

		aComplex := oWsdl:NextComplex()
	EndDo

	aSimple := oWsdl:SimpleInput()

	nPos := aScan( aSimple, {|x| x[2] == "username" } )
	xRet := oWsdl:SetValue( aSimple[nPos][1], cUsuario )
	if xRet == .F.
		xRet := oWsdl:cError
		Return ""
	Endif

	nPos := aScan( aSimple, {|x| x[2] == "password" } )
	xRet := oWsdl:SetValue( aSimple[nPos][1], JurEncUTF8(cSenha))
	if xRet == .F.
		xRet := oWsdl:cError
		Return ""
	endif

	nPos := aScan( aSimple, {|x| x[2] == "companyId" } )
	xRet := oWsdl:SetValue( aSimple[nPos][1], cEmpresa )
	if xRet == .F.
		xRet := oWsdl:cError
		Return ""
	Endif

	nPos := aScan( aSimple, {|x| x[2] == "parentDocumentId" } )
	xRet := oWsdl:SetValue( aSimple[nPos][1], cPasta )
	if xRet == .F.
		xRet := oWsdl:cError
		Return ""
	Endif

	nPos := aScan( aSimple, {|x| x[2] == "publisherId" } )
	xRet := oWsdl:SetValue( aSimple[nPos][1], cColId )
	if xRet == .F.
		xRet := oWsdl:cError
		Return ""
	Endif

	nPos := aScan( aSimple, {|x| x[2] == "documentDescription" } )
	xRet := oWsdl:SetValue( aSimple[nPos][1], JurEncUTF8(substr(substr(cNomArq,RAT("\",cNomArq)+1),1)))
	if xRet == .F.
		xRet := oWsdl:cError
		Return ""
	endif

	nPos := aScan( aSimple, {|x| x[2] == "principal" .AND. x[5] == "Attachments#1.item#1"} )
	xRet := oWsdl:SetValue( aSimple[nPos][1], "true" )
	if xRet == .F.
		xRet := oWsdl:cError
		Return ""
	endif

	nPos := aScan( aSimple, {|x| x[2] == "filecontent" .AND. x[5] == "Attachments#1.item#1"} )
	xRet := oWsdl:SetValue( aSimple[nPos][1], cFilecontent)
	if xRet == .F.
		xRet := oWsdl:cError
		Return ""
	endif

	nPos := aScan( aSimple, {|x| x[2] == "fileName" .AND. x[5] == "Attachments#1.item#1"} )
	xRet := oWsdl:SetValue( aSimple[nPos][1], JurEncUTF8(substr(substr(cNomArq,RAT("\",cNomArq)+1),1)))
	if xRet == .F.
		xRet := oWsdl:cError
		Return ""
	endif

	nPos := aScan( aSimple, {|x| x[2] == "fileSize" .AND. x[5] == "Attachments#1.item#1"} )
	xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(str(nTam)) )
	if xRet == .F.
		xRet := oWsdl:cError
		Return ""
	endif


	// Log do XML de Envio
	JConLogXML(oWsdl:GetSoapMsg(), "E")

	// Envia a mensagem SOAP ao servidor
	xRet := oWsdl:SendSoapMsg()

	// Pega a mensagem de resposta
	xRet := oWsdl:GetSoapResponse()

	// Log do XML de Recebimento
	JConLogXML(xRet, "R")

	If "WEBSERVICEMESSAGE" $ Upper(xRet)
		//Localizo o id da pasta criada
		oXmlDoc := XmlParser( xRet, "_", @cErro, @cAviso )

		If oXmlDoc <> Nil
			If XmlChildEx(&("oXmlDoc" + cPathCab),"_WEBSERVICEMESSAGE") <> Nil
				If &("oXmlDoc" + cPathCab + ":_WEBSERVICEMESSAGE:TEXT") <> "ok"
					cErro := &("oXmlDoc" + cPathCab + ":_WEBSERVICEMESSAGE:TEXT")
				Else
					cIdDoc := AllTrim(&("oXmlDoc" + cPathCab + ":_DOCUMENTID:TEXT"))
				EndIf
			EndIf
			FwFreeObj(oXmlDoc)
		Else
			//³Retorna falha no parser do XML³
			cErro := STR0134 //"Upload de documento ao fluig:Falha ao interpretar xml de retorno"
		EndIf
	Endif

    cFilecontent := "" 
    xRet         := ""
    cBuffer      := ""
    FwFreeObj(oWsdl) 
    oWsdl := Nil 

Return cIdDoc

//-------------------------------------------------------------------
/*/{Protheus.doc} JurEncUTF8
Função que altera alguns caracteres que o servidor do FLUIG exige, como
&, <,  > e " e chama também a função EncodeUTF8 da tecnologia. Usado em
Web Services

@Param cPalavra String que deve ter estes caracteres convertidos

@Return cRet   Palavra com os caracteres convertidos

@author André Spirigoni Pinto
@since 14/10/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurEncUTF8(cPalavra)
Local cRet := ""
Default cPalavra := " "

	cRet := EncodeUTF8(cPalavra)

	Iif( ValType(cRet) == "U", cRet := " ", cRet)

	/*Importante que a substituição do caracter & deve vir primeiro para que
	não seja substituído nas próximas ocorrências que vão surgir desde o primeiro STRTRAN.*/

	cRet := STRTRAN(cRet,"&","&#38;")
	cRet := STRTRAN(cRet,"<","&#60;")
	cRet := STRTRAN(cRet,">","&#62;")
	cRet := STRTRAN(cRet,'"',"&#34;")
	cRet := STRTRAN(cRet,"&#38;#","&#")

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JDelFilho(aRet, cCodPai)
Exclui os registros vinculados ao processo. Andamento, Follow-up etc...
Uso Geral.

@param 	aRet Array com dados SX9 da tabela
@param 	cCodPai Valor chave para gerar query principal

@Return Nil

@author Wellington Coelho
@since 10/03/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JDelFilho(aRet, cCodPai)
	Local aArea     := GetArea()
	Local cQryRes   := ''
	Local cQuery    := ''
	Local nI        := 0
	Local nY        := 0
	Local cTabfilho := ''
	Local cTabPai   := ''
	Local cCpoPai   := ''
	Local cCpoFil   := ''
	Local aNeto     := {}
	Local cCodFil   := ''
	Local cExecTab  := 'NT9|NUQ|NYP|NXY|NYJ'//Excessão das tabelas para exclusão, pois na JURA095 já é feita a excluir

	ProcRegua(0)

	For nI := 1 to Len(aRet)
		If !(Alltrim(aRet[nI][1]) $ cExecTab ) .AND.  !(Alltrim(aRet[nI][4]) $ cExecTab )
			cTabfilho  := Alltrim(aRet[nI][1])
			cTabPai    := Alltrim(aRet[nI][4])
			cCpoPai    := StrTran(Alltrim(aRet[nI][2]), '+', '||'+cTabPai+'.')
			cCpoFil    := StrTran(Alltrim(aRet[nI][3]), '+', '||'+cTabfilho+'.')

			IncProc(I18N(STR0146, {JurX2Nome(cTabfilho)}))

			cQuery := "SELECT "+cTabfilho+".R_E_C_N_O_ RECNO "
			cQuery += " FROM "+RetSqlName(cTabfilho)+" "+cTabfilho+ ","
			cQuery += " "+RetSqlName(cTabPai)+" "+cTabPai
			cQuery += " WHERE "+cTabfilho+"."+cTabfilho+"_FILIAL = '" + xFilial( cTabfilho ) + "'"
			cQuery +=   " AND "+cTabPai+"."+cTabPai+"_FILIAL = '" + xFilial( cTabPai ) + "'"
			cQuery +=   " AND "+cTabPai+"."+cCpoPai+ " = " +cTabfilho+"."+cCpoFil
			If "NXX" $ cCpoFil
				cQuery +=   " AND "+cTabPai+"."+cCpoPai+ " = '" + xFilial( cTabPai )  + cCodPai + "'"
			Else
				cQuery +=   " AND "+cTabPai+"."+cCpoPai+ " = '" + cCodPai + "'"
			EndIf
			cQuery +=   " AND "+cTabfilho+".D_E_L_E_T_ = ' '"
			cQuery +=   " AND "+cTabPai+".D_E_L_E_T_ = ' '"

			cQuery  := ChangeQuery(cQuery)
			cQryRes := GetNextAlias()

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

			While !(cQryRes)->( EOF() )
				&(cTabfilho)->(Dbgoto((cQryRes)->RECNO))
				If Len(aNeto := JURCPOSX9(cTabfilho)) > 0
					For nY := 1 to Len(aNeto)
						cCodFil := &(cTabfilho+"->"+ StrTran( Alltrim(aNeto[nY][2]), '+', '+'+cTabfilho+'->'))
						JDelFilho(aNeto, cCodFil)
					Next nY
				EndIf
				RecLock( (cTabfilho),.F. )
				&(cTabfilho)->(Dbdelete())
				&(cTabfilho)->( MsUnlock() )
				(cQryRes)->( dbSkip() )
			EndDo
			(cQryRes)->(DbCloseArea())
		EndIf
	Next nI

	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JURCPOSX9(cTabela)
Retorna Array com os campos da SX9
Uso Geral.

@param 	cTabela		Tabela de Referencia (X9_DOM)

@Return aRet		Campos SX9
      [1]X9_CDOM
      [2]X9_EXPDOM
      [3]X9_EXPCDOM

@author Wellington Coelho
@since 16/10/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURCPOSX9(cTabela)
	Local aRet := {}

	SX9->(dbsetorder(1))

	IF SX9->(DBSeek(cTabela))
		While !(SX9->(Eof())) .And. (SX9->X9_DOM == cTabela)
			aAdd(aRet, {SX9->X9_CDOM, SX9->X9_EXPDOM, SX9->X9_EXPCDOM, SX9->X9_DOM})
			SX9->(dbSkip())
		EndDo
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCarEsp(cCompara)
Função utilizada para verificar se existe caracteres especiais numa determinada string

@param  cTab Nome da tabela

@Return aIndex  Indices da tabela
@author Marcelo Dente
@since 24/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurCarEsp(cCompara,cExcessao)
	Local aASCChar:= {}
	Local nRangeASCII:= 0
	Local lExist:= .F.
	Local nASCG :=0

	aADD(aASCChar,{33,34,35,36,37,38,39,40,41,42,43,44,45,46,47})
	aADD(aASCChar,{58,59,60,61,62,63,64})
	aADD(aASCChar,{91,92,93,94,95,96})
	aADD(aASCChar,{123,124,125,126})


	For nASCG:=1 To 4
		For nRangeASCII:=1  To Len(aASCChar[nASCG])
			If ( CHR(aASCChar[nASCG][nRangeASCII]) $ cCompara ) .AND. !(CHR(aASCChar[nASCG][nRangeASCII]) $ cExcessao)
				lExist:= .T.

			EndIF
		Next nRangeASCII
	Next nASCG

Return lExist

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIndex(cTab)
Função utilizada para buscar os campos que são utilizados como indices na tabela selecionada

@param  cTab Nome da tabela

@Return aIndex  Indices da tabela
@author Wellington Coelho
@since 11/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurIndex(cTab)
	Local aArea    := GetArea()
	Local aAreaSIX := SIX->(GetArea())
	Local cIndice  := cTab
	Local cCampos  := ""
	Local nI       := 1
	Local aIndex   := {}

	SIX->( dbSetOrder( 1 ) )
	While !Empty(cIndice := &(cTab)->(IndexKey(nI)))
		If Empty(cCampos)
			cCampos := cIndice
			nI++
		Else
			cCampos += "+" + cIndice
			nI++
		EndIf
	End

	RestArea(aAreaSIX)
	RestArea(aArea)

	aIndex := JStrArrDst(cCampos, "+")

Return aIndex

//------------------------------------------------------------------
/*/{Protheus.doc} JurAnexos(cEntidade, cCodEnt, nIndice)
Abre a janela de Anexos na opção Anexos do Menu.

@param  cEntidade,  Nome da tabela
@param  cCodEnt  ,  Chave Primaria da Tabela (X2_UNICO)
@param  nIndice  ,  Número do Índice correspondente ao cCodEnt
@param  cFilOrig ,  Filial do processo posicionado
@param  lEntPFS  ,  Indica se é uma entidade do SIGAPFS
                    Necessário devido ao uso da fila de sincronização - LegalDesk

@sample JurAnexos('NT3',NT3->NT3_CAJURI+NT3->NT3_COD, 1, "01")

@return lRet     ,  Retorna se o registro foi inserido na  tabela NUM

@author Reginaldo Soares
@since 17/02/2016
@version 1.0

@author nishizaka.cristiane
@since 03/12/2018
@version 2.0
/*/
//-------------------------------------------------------------------
Function JurAnexos(cEntidade, cCodEnt, nIndice, cFilOrig, lEntPFS)

Local cParam      := AllTrim(SuperGetMv('MV_JDOCUME',,'1'))
Local oAnexo      := Nil
Local lRet        := .F.
Local cOrdem      := "1"
Local cCajuri     := ""

Default nIndice   := 1
Default cFilOrig  := IIF( VALTYPE(cFilOrig) <> 'U', cFilOrig, xFilial(AllTrim(cEntidade)) )
Default lEntPFS   := .F.

	cEntidade 	:= AllTrim(cEntidade)
	cCodEnt 	:= AllTrim(cCodEnt)

	If JurHasClas()
		Do Case
		Case cParam == '1'
			oAnexo := TJurAnxWork():New(STR0159, cEntidade, cFilOrig, cCodEnt, nIndice, , lEntPFS) //"WorkSite"
		Case cParam == '2'
			oAnexo := TJurAnxBase():New(STR0160, cEntidade, cFilOrig, cCodEnt, nIndice, , , lEntPFS) //"Base de Conhecimento"
		Case cParam == '3'
			oAnexo := TJurAnxFluig():New(STR0161, cEntidade, cFilOrig, cCodEnt, nIndice) //"Documentos em Destaque - Fluig"
		EndCase

		lRet:= JurVldNUM(cCodEnt, cEntidade)
	Else
		If cEntidade == "NSZ"
			cCajuri := cCodEnt
		Else
			cCajuri := JURGETDADOS(cEntidade, nIndice, cFilOrig+cCodEnt, cEntidade + "_CAJURI")
		EndIf

		JURANEXDOC(	cEntidade/*cEntiMain*/,;
			''/*cModelMain*/,;
			cCajuri/*cAssJur*/,;
			cCodEnt/*cCodMain*/,;
	 			/*cEntiDet*/, /*cModelDet*/, /*cCodDetail*/, /*cClienteLoja*/, /*cCaso*/,;
			cOrdem, /*cCompl*/, .T. /*lBrowse*/, /*lOpenFluig*/,,;
			cFilOrig /*Filial origem*/)
		lRet := Nil
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurInfBox(cCampo, cValor )
Função que retorna o a descrição amigavel da opção de combobox

@param cCampo  Nome do campo (Ex: NSZ_SITUAC)
@param cValor  Opção selecionada no combo (Ex: 1)
@param cTpInfo  Tipo de informação Padrão: '1'
					Se '1': 'Em Andamento'; (somente descrição)
					Se '2': '1=Em Andamento'; (como esta gravado no dic)
					Se '3': '1 - Em Andamento'; (como é exibido pelo sistema)

@Return cRet   Valor referente a opção selecionada conforme o cTpInfo
				(Ex: 'Em Andamento')

@author Luciano Pereira dos Santos / Jorge Luis Branco Martins Junior
@since 05/07/16
@version 1.0

@Sample JurInfBox('NSZ_SITUAC', '1', '3')
/*/
//-------------------------------------------------------------------
Function JurInfBox(cCampo, cValor, cTpInfo )
	Local cRet    := ""
	Local aArea   := GetArea()
	Local aX3CBox := {}
	Local cX3CBox := ''
	Local nItem   := 0
	Local cItem   := 0
	Local nPos    := 0

	Default cTpInfo := '1'

	If !Empty(cValor)
		cValor := AlltoChar(cValor)

		If __Language == 'PORTUGUESE'
			cX3CBox := GetSx3Cache(cCampo, 'X3_CBOX')
		ElseIf __Language == 'ENGLISH'
			cX3CBox := GetSx3Cache(cCampo, 'X3_CBOXENG')
		ElseIf __Language == 'SPANISH'
			cX3CBox := GetSx3Cache(cCampo, 'X3_CBOXSPA')
		EndIf

		If ('#'$ cX3CBox)
			cX3CBox := StrTran(cX3CBox,'#','')
			cX3CBox := &(cX3CBox)
		EndIf

		aX3CBox := STRTOKARR(AllTrim(cX3CBox) ,";")

		If (nItem := aScan( aX3CBox, { |aX| cValor $ aX} )) > 0
			cItem := aX3CBox[nItem]
			If cTpInfo == '1'
				nPos := At('=', cItem)
				cRet := RIGHT(cItem, Len(cItem)-nPos)
			ElseIf cTpInfo == '2'
				cRet := cItem
			ElseIf cTpInfo == '3'
				cRet := StrTran(cItem,'=',' - ')
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIndiceN
Função para converter e validar um indice alfanumérico de uma tabela


@param cIndice    Indice da tabela. Ex: '1', 'A', 'D'
@param cTabela    Tabela para validar o índice Ex: 'SA1', 'NT2'

@return nRet	   Indice numerico para ser usado no DbsetOrder()

@Sample NUE->(DbsetOrder(JurIndiceN('A','NUE')))
]
@author Marcelo Araujo Dente
@since 27/09/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurIndiceN(cIndice, cTabela)
	Local nRet := 0

	Default cTabela := ''

	nRet := IIF(cIndice <= '9',VAL(cIndice),ASC(cIndice)-55)

	If nRet > 0
		If !Empty(cTabela)
			If !SIX->(dbSeek(cTabela + cIndice))
				nRet := 1
			EndIf
		EndIf
	Else
		nRet := 1
	Endif

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurAuto()
Função que retorna se a rotina atual está sendo executada pelo Mile
ou via rotinas automáticas, como Web Service

@Return lRet   Retorno lógico se a rotina está ou não sendo executada
				de forma automática (Mile ou Web Service)

@author André Spirigoni Pinto
@since 02/02/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurAuto()
Local lRet := .F.
Local lAuto := .F.

// Esta variável será declarada como private pelas rotinas externas que desejem ser 
// considaradas como rotinas automáticas. Se ela não for declarada, este será seu valor padrão .F.
Default lJurAuto := .F. 

	lAuto := Iif(valtype(lJurAuto) == "L", lJurAuto, .F.)

	//valida se esta em execução o MILE ou se não existe interface aberta.
	lRet := (IsBlind() .OR. IsInCallStack("MILESCHIMP") .OR. IsInCallStack("FWMILEMVC")  .OR. IsInCallStack("CFGA600") .OR. lAuto)

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} JStrArrDst(cCmpList, cLimitador)
Quebra a string em array utilizando o limitador definido verificando
se o valor não está sendo duplicado dentro do array

@param 	cCmpList    Lista a ser quebrada
@param 	cLimitador  Limitador

@return Array com os valores
@author Willian Kazahaya
@since 20/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JStrArrDst(cCmpList, cLimitador)
	Local aReturn := {}
	Local aAux    := {}
	Local nCount  := 0

	aAux := StrToKArr(cCmpList, cLimitador)

	For nCount:=1 To Len(aAux)
		If aScan(aReturn, UPPER(AllTrim(aAux[nCount] ))) == 0
			Aadd(aReturn, UPPER(AllTrim(aAux[nCount] )))
		EndIf
	Next nCount

Return aReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} JurConWsdl()
Cria o objeto TWsdlManager a partir da Url

@return  oWsdl - objeto TWsdlManager

@author  Rafael Tenorio da Costa
@since 	 31/08/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurConWsdl(cUrl, cErro)

	//Dados da configuração de Proxy no Configurador
	Local lProxy     := ( FWSFPolice("COMUNICATION", "USR_PROXY") == "T" )
	Local cPrxServer := Alltrim( FWSFPolice("COMUNICATION", "USR_PROXYIP") )
	Local nPrxPort   := Val( FWSFPolice("COMUNICATION", "USR_PROXYPORT") )
	Local cPrxUser   := Alltrim( FWSFPolice("COMUNICATION", "USR_PROXYLOGON") )
	Local cPrxPass   := Alltrim( FWSFPolice("COMUNICATION", "USR_PROXYPSW")   )

	//Cria o objeto da classe TWsdlManager
	Local oWsdl := Nil
	Local nWsdl := 0

	//Limpa a variavel de referencia antes de executar
	cErro := ""

	If ValType(aWsdl) != "A"
		aWsdl := {}
	EndIf

	//Valida se o objeto ja esta em cache
	If ( nWsdl := aScan(aWsdl, {|x| x[1] == AllTrim(cUrl)}) ) == 0 .OR. aWsdl[nWsdl][2] == NIL

		oWsdl          := TWsdlManager():New()
		oWsdl:nTimeout := 120

		If lProxy
			oWsdl:SetProxy(cPrxServer, nPrxPort)
			oWsdl:SetCredentials(cPrxUser, cPrxPass)
		EndIf

		//Verificação SSL
		If "https:" $ cUrl
			oWsdl:cSSLCACertFile := "\certs\sslCaCert.cer"
			oWsdl:cSSLCertFile 	 := "\certs\sslCert.crt"
			oWsdl:cSSLKeyFile    := "\certs\sslKeyCert.key"
			oWsdl:lSSLInsecure   := .T.
		EndIf

		//Remove tags vazias, define que irá remover os tipos complexos que foram definidos com 0 no método SetComplexOccurs
		oWsdl:lRemEmptyTags := .T.
		oWsdl:lProcResp     := .F.
		oWsdl:bNoCheckPeerCert := .T.

		//Faz o parse de uma URL
		If oWsdl:ParseURL(cUrl)
			cErro := ""

			If nWsdl > 0
				aWsdl[nWsdl][2] := oWsdl  // substitui na mesma posição por conta de performance
			Else
				Aadd(aWsdl, {AllTrim(cUrl), oWsdl})  //Cache do wsdl parseado
			EndIf

		Else
			cErro := STR0151 + AllTrim(oWsdl:cError)	//"Problema ao configurar webservice (TWsdlManager): "
			JurConout(cErro)
		EndIf

	Else
		oWsdl := aWsdl[nWsdl][2]
	Endif

Return oWsdl

//------------------------------------------------------------------
/*/{Protheus.doc} JACODINST
Função que retorna a instancia, caso, for a unica do Cajuri selecionado

Utilização apenas na inclusão

@param   cCajuri  - Codigo do assunto juridico
@param   cFil     - Filial
@Return  cCodInst - Codigo da Instancia
@author  Beatriz Gomes
@since 	 19/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JACODINST(cCajuri,cFil)
	Local cQuery    := ""
	Local cCodInst  := ""
	Local aRetorno  := {}

	Default cCajuri := ""
	Default cFil    := ""

	If !EMPTY(cCajuri)
		cQuery += " SELECT NUQ.NUQ_COD"
		cQuery += " FROM " + RetSqlName("NUQ") + " NUQ "
		If Empty(cFil)
			cQuery += " WHERE NUQ.NUQ_FILIAL = '" + xFilial("NUQ") + "'"
		Else
			cQuery += " WHERE NUQ.NUQ_FILIAL = '" + cFil + "'"
		EndIf
		cQuery += 	" AND NUQ.NUQ_CAJURI = '" + cCajuri + "'"
		cQuery += 	" AND NUQ.D_E_L_E_T_ = ' '"

		aRetorno := JurSql(cQuery, {"NUQ_COD"})

		If Len(aRetorno) == 1
			cCodInst := AllTrim(aRetorno[1][1])
		EndIf
	EndIf

Return cCodInst

//-------------------------------------------------------------------
/*/{Protheus.doc} JANUMPRO
Retorna o numero do processo, de acordo com o CAJURI e o Cod da Instancia

@Param cAssJur   Código do Assunto Jurídico
@Param cCodigo   Código da Instancia

@Return cProc    Numero do processo

@author Beatriz Gomes
@since 19/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANUMPRO(cAssJur,cCodigo)
	Local cProc := ""
	If !EMPTY(cCodigo) .AND. !EMPTY(cAssJur)
		cProc := POSICIONE('NUQ',5,XFILIAL('NUQ')+cAssJur+cCodigo,'NUQ_NUMPRO')
	EndIf
Return cProc

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCliVld (cClien, cLoja)
Validação padrão dos campos: Cliente e Loja.
Validação para bloquear a inc/alt de despesas para Cliente/Loja que seja para lançamentos futuros (MV_JURTS5 e MV_JURTS6)
e também para Cliente/Loja que represente o próprio Escritório.

@param cClien -   Valor do código do cliente no modelo
@param cLoja -    Valor da loja do cliente no modelo

@Return   lRet  .T. ou .F.

@author Nivia Ferreira
@since 26/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurCliLVld(oModel, cCliente, cLoja)
	Local lRet      := .T.
	Local aArea     := GetArea()

	Local cCliFu    := SuperGetMV("MV_JURTS5",,"" )
	Local cLojFu    := SuperGetMV("MV_JURTS6",,"" )
	Local cCliEsc   := SuperGetMV("MV_JURTS9",,"" )
	Local cLojEsc   := SuperGetMV("MV_JURTS10",,"" )

	Default cCliente:= ""
	Default cLoja   := ""

	If (cCliente == cCliFu .And. cLoja == cLojFu) //Valida cli/loja com os parametros MV_JURTS5 e MV_JURTS6.
		lRet := .F.
		oModel:SetErrorMessage(,, oModel:GetId(),, "ModelPosVld", STR0152, STR0154,, ) // "Não é permitido Cliente/Loja usado para time sheets futuros." # "Verifique os parâmetros: MV_JURTS5 e MV_JURTS6."
	EndIf

	If lRet // Validação de Cliente/Loja representa o escritorio MV_JURTS9 e MV_JURTS10
		If (cCliente == cCliEsc .And. cLoja == cLojEsc)
			lRet := .F.
			oModel:SetErrorMessage(,, oModel:GetId(),, "ModelPosVld", STR0153, STR0155,, ) // "Não é permitido Cliente/Loja que representa o escritório." # "Verifique os parâmetros: MV_JURTS9 e MV_JURTS10."
		EndIf
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCotac
Função para converter a cotação.

@param nCotac1    Cotação 1
@param nCotac2    Cotação 2

@return nRet	  Cotacao

@author Abner Fogaça de Oliveira
@since 13/03/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurCotac(nCotac1, nCotac2)
	Local nRet := 0

	If nCotac1 == 0 .Or. nCotac2 == 0
		nRet := 0
	Else
		nRet := nCotac1 / nCotac2
	EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurHora
Formata a data que bem do Banco com : para mensagens

@param cHora - Hora no formato "hhmm" conforme o Banco

@return cRet - Retorna a hora com hh:mm

@author Willian Kazahaya
@since 11/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurHora(cHora)
	Local cRet := ""
	cHora := AllTrim(cHora)
	cRet  := Substring(cHora,1,2) + ":" + Substring(cHora,3,2)
Return cRet

//----------------------------------------------------------//
/*/{Protheus.doc} JurVldNUM(cCodigo, cEntidade)
Valida a inclusão do registro na tabela de Documentos Jurídicos

@Param cCodigo		Chave da entidade (X2_UNICO) sem filial
@Param cEntidade	Tabela

@Return lHasNum	 	.T./.F. Existe o registro ou não

@author Willian Yoshiaki Kazahaya (J254VldNUM)
@since 20/02/2018
@version 1.0

@author Cristiane Nishizaka
@since 06/12/2018
@version 2.0
/*/
//-------------------------------------------------------------------
Function JurVldNUM(cCodigo, cEntidade)

	Local aArea  	  := GetArea()
	Local cQuery 	  := ""
	Local cQuerySel   := ""
	Local cQueryFrom  := ""
	Local cQueryWhere := ""
	Local cAliasNUM   := GetNextAlias()
	Local lHasNum     := .F.

	cQuerySel	:= " SELECT NUM_COD "
	cQueryFrom	:= " FROM " + RetSqlName("NUM") + " NUM "
	cQueryWhere	:= " WHERE NUM_FILENT = '" + PadR(xFilial(cEntidade), TamSx3("NUM_FILENT")[1]) + "'"
	cQueryWhere	+=   " AND NUM_CENTID = '" + cCodigo + "'"
	cQueryWhere	+=   " AND NUM_ENTIDA = '" + cEntidade + "'"
	cQueryWhere +=   " AND D_E_L_E_T_ = ' ' "

	cQuery := "" + cQuerySel + cQueryFrom + cQueryWhere

	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasNUM, .F., .F. )

	lHasNum := !(cAliasNUM)->(Eof())

	(cAliasNUM)->( dbCloseArea() )
	RestArea(aArea)

Return lHasNum

//----------------------------------------------------------//
/*/{Protheus.doc} JurHasClas()
Verifica se o Dicionário de Dados está atualizado para utilizar as classes de Anexos
DJURDEP-3762 Criar a classe TJURANXWORK

@Return lRet	 	.T./.F.

@author Cristiane Nishizaka
@since 20/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurHasClas()

	Local lRet 		:= .F.
	Local aArea		:= GetArea()
	Local aAreaNUM	:= NUM->( GetArea() )
	Local cSubRot   := 'arquitetura_antiga_'
	Local cIdMetric := 'sigajuri-protheus_uso-arquitetura-de-base-de-conhecimento-para-juridico-antiga_total'

	lRet := NUM->( FieldPos("NUM_SUBPAS") ) .And. FWX2Unico( 'NUM') == "NUM_FILIAL+NUM_COD"
	
	cSubRot += Iif(lRet,'false','true')
	If FindFunction("JurMetric")
		JurMetric('unique' ,cSubRot ,cIdMetric, '1' /*xValue*/ , /*dDateSend*/, /*nLapTime*/, 'JURA026')
	EndIf
	
	RestArea( aAreaNUM )
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVldCdLD()
Função genérica para validar o preenchimento do código LD dos
lançamentos via Rest.

@return lRet   .T./.F.

@author Queizy Nascimento
@since 18/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurVldCdLD()
Local aArea    := {}
Local cQuery   := ""
Local cResQry  := ""
Local cCampo   := ""
Local cCodigo  := ""
Local lRet     := .T.
Local lIsRest  := Iif(FindFunction("JurIsRest"), JurIsRest(), .F.)
Local lFound   := .F.

	If lIsRest
		cCampo  := ReadVar()
		cCodigo := &(cCampo)
		
		If !Empty(cCodigo)
			cCampo  := SubStr(cCampo, 4)
			cTab    := SubStr(cCampo, 1, 3)
			
			aArea := GetArea()

			cQuery := " SELECT " + cCampo
			cQuery += " FROM " + RetSqlName(cTab)
			cQuery += " WHERE " + cTab + "_FILIAL = '" + xFilial(cTab) + "'"
			cQuery +=   " AND " + cTab + "_CODLD = '" + cCodigo + "'"
			cQuery +=   " AND D_E_L_E_T_ = ' ' "

			cResQry := GetNextAlias()
			dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQry, .T., .T.)
			
			lFound := (cResQry)->(!Eof())

			(cResQry)->(DbCloseArea())

			If lFound
				lRet := JurMsgErro(I18N(STR0164, {Alltrim(cCodigo)})) // "Não foi possivel incluir o lançamento, pois o código de LD '#1' já existe."
			EndIf

			RestArea(aArea)
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurMsgCdLD()
Verifica o preenchimento do campo de Código do LD. Quando vazio,
retorna .F. e seta mensagem de erro.

@param  cCodLD  Conteúdo do campo _CODLD para validação

@return lRet    .T. se preenchido /.F. se vazio

@author Cristina Cintra
@since 25/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurMsgCdLD(cCodLD)
	Local lRet := .T.

	If Empty(cCodLD)
		JurMsgErro(STR0166,, STR0167) // "O preenchimento do Código Legal Desk é obrigatório na inclusão via REST." # "Preencha a chave do lançamento no LD."
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGetTag
Retonar o conteudo de uma tag o xml

@param cXml		- Xml de resposta do WebService
@param cTagIni	- Tag que tera o conteudo retornado
@param lTag		- Indica se deve retornar a tag tb
@return cRet

@author  Rafael Tenorio da Costa
@since 	 21/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurGetTag(cXml, cTagIni, lTag)

	Local cRet 	  := ""
	Local cTagFim := ""
	Local nAtIni  := 0
	Local nAtFim  := 0
	Local nTamTag := 0

	Default lTag  := .F.

	cTagIni := Lower(cTagIni)
	cTagFim := StrTran(cTagIni, "<", "</")

	//Localização das tags na string do XML
	nAtIni := At(cTagIni, Lower(cXml))
	nAtFim := At(cTagFim, Lower(cXml))

	//Pega o valor entre a tag inicial e final
	If nAtIni > 0 .And. nAtFim > 0
		nTamTag := Len(cTagIni)
		cRet	:= SubStr(cXml, nAtIni + nTamTag, nAtFim - nAtIni - nTamTag)
	Endif

	//Retorna a tag com o conteudo
	If !Empty(cRet) .And. lTag
		cRet := cTagIni + cRet + cTagFim
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JCompTable(cTabela)
Retorna o tipo de Compartilhamento da tabela

@param cTabela - Tabela a ser consultada
@return cComp - "Modo Filial" + "Modo Unidade de Negócio" + "Modo Empresa"

@example JCompTable("NSZ") - "CCC"
		 JCompTable("SA1") - "CEE"

@author  Willian Yoshiaki Kazahaya
@since 	 14/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCompTable(cTabela)
	Local cComp := ""
	cComp := FWModeAccess(cTabela, 1) + FWModeAccess(cTabela, 2) + FWModeAccess(cTabela, 3)
Return cComp

//-------------------------------------------------------------------
/*/{Protheus.doc} JTemAnexo(cEntidade,cCajuri,cCodigo)
Função que verifica se há anexo em determinado registro.
Criada para o TOTVS Legal.

@param cEntidade,cCajuri,cCodigo
@example JTemAnexo('NT2',0000000081,0000000185)

@return cAnexo (01 = Sim | 02 = Não)

@since 	 26/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function JTemAnexo(cEntidade,cCajuri,cCodigo)
Local cAnexo    := ''
Local lJurChave := IIF(cEntidade $ 'NT2/NT3/O0S',.T.,.F.) //indica se o cajuri faz parte da chave única

	If !EMPTY(JurGetDados('NUM', 3, XFILIAL('NUM') + cEntidade + IIF(lJurChave,cCajuri,'') + cCodigo, 'NUM_DOC'))
		cAnexo := '01'
	Else
		cAnexo := '02'
	Endif

Return cAnexo

//-------------------------------------------------------------------
/*/{Protheus.doc} JCpfCnpj
Valida se a string é um cpf ou cnpj e atribui mascara de acordo com o tipo

Usado para a consulta padrão de cliente SA1NSZ do campo NSZ_CCLIEN

@param cNum - String que receberá a mascara 

@return cTransf - string com a mascara
                CPF  - 000.000.000-00
                CNPJ - 00.000.000/0000-00
@since 05/12/2019
/*/
//-------------------------------------------------------------------
Function JCpfCnpj( cNum )

	Local cTransf := ""

	If !Empty( cNum )
		If Len( Alltrim(cNum) ) <= 11
			cTransf := Transform( cNum, '@R 999.999.999-99'    )	//-- CPF
		Else
			cTransf := Transform( cNum, '@R 99.999.999/9999-99' )	//-- CNPJ
		EndIf
	EndIf

Return cTransf

//-------------------------------------------------------------------
/*/{Protheus.doc} JCheckFila(cUser, cThread)
Verifica se existe registros em fila de impressão "NQ3" para o usuário na sessão logada.

@param cUser   - Código do usuário
@param cThread - Código da sessão logada

@return lRet   - Indica se existe registro em fila de impressão

@since 23/03/2022

/*/
//-------------------------------------------------------------------
Function JCheckFila(cUser, cThread)
Local aArea := GetArea()
Local lRet       := .F.

Default cUser    := __CUSERID
Default cThread  := SubStr(AllTrim(Str(ThreadId())),1,4)

	NQ3->(dbSetOrder(3)) // NQ3_FILIAL+NQ3_CUSER+NQ3_SECAO
	lRet := NQ3->(dbSeek(xFilial('NQ3') + cUser + cThread ))

	RestArea( aArea )
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JQryMemo( cCampo, cBanco, nReduz )
Realiza o tratamento de campo memo de acordo com o banco utilizado.

@param cCampo    - Campo memo
@param cBanco    - Banco de dados
@param nReduz    - Reduz o tamanho máximo do campo

@return cRetorno - Trecho da query com tratamento para campo memo

@since 12/04/2022
/*/
//-------------------------------------------------------------------
Function JQryMemo( cCampo, cBanco, nReduz )
Default cBanco := (Upper(TcGetDb()))
Default nReduz := 0

	If cBanco == "ORACLE"
		cCampo := " to_char(substr(" + cCampo + ",1," + cValToChar(4000 - nReduz) + ")) "
	Elseif cBanco == "MSSQL"
		cCampo := " cast(" + cCampo + " as varchar(MAX)) "
	Elseif cBanco == "DB2"
		cCampo := " cast(substr(" + cCampo + ",1," + cValToChar(8000 - nReduz) + ") as VARCHAR(8000)) "
	Elseif cBanco == "POSTGRES"
		cCampo := " cast(" + cCampo + " as TEXT) "
	EndIf

Return cCampo

//-------------------------------------------------------------------
/*/{Protheus.doc} JCmpDispPD( aCampos )
Verifica quais campos estão disponiveis para se visualizar com a LGPD
de acordo com a configuração do usuario

@param aCampos array - Campos a se verificar

@return aCampsDisp - Campos disponiveis para visualização

@since 28/04/2022
/*/
//-------------------------------------------------------------------

Function JCmpDispPD( aCampos )
Local aCampsDisp := {}
Local lCheckLGPD := FindFunction('FwProtectedDataUtil')

	If lCheckLGPD 
		Aadd(aCampsDisp,FwProtectedDataUtil():UsrAccessPDField( __CUSERID, aCampos))
	EndIf

Return aCampsDisp


//-------------------------------------------------------------------
/*/{Protheus.doc} JurClearStr( cString, lEspec, lPont, lSQL, lUpper, cReplace )
Faz o De Para de caracteres de acentuação

@param cString  - String a ser limpa 
@param lEspec   - Define se os caracteres especiais serão substituidos.
@param lPont    - Define se os caracteres de pontuação serão substituidos.
@param lSQL     - Define se o retorno será para sql
@param lUpper   - Define se o texto será convertido para maiúsculo.
@param cReplace - Texto usado na substituição de pontuação e caracteres especiais. 

@return	cRet    - String Tratada
/*/
//-------------------------------------------------------------------
Function JurClearStr(cString, lEspec, lPont, lSQL, lUpper, cReplace )
Local cAcentos   := "çÇáéíóúÁÉÍÓÚâêîôûÂÊÎÔÛäëïöüÄËÏÖÜãõÃÕàÀñÑ"
Local cAcSubst   := "cCaeiouAEIOUaeiouAEIOUaeiouAEIOUaoAOaAnN"
Local cCaraPont  := ".,;:!?-"
Local cCaraEspec := "@#$%&*¨`/\()-+='[]{}~<>|" + '"'
Local cRet       := ""
Local nI         := 0
Local aSTR       := {}
Default lEspec   := .T.
Default lPont    := .T.
Default lSQL     := .F.
Default lUpper   := .T.
Default cReplace := "#"

	If Len(cString) > 0

		cString := AllTrim(cString)

		// De Para de caracteres
		For nI := 1 to Len(cAcentos)
			aAdd(aSTR,{subStr(cAcentos,nI,1),subStr(cAcSubst,nI,1)})
		Next

		If lPont
			For nI := 1 to Len(cCaraPont)
				aAdd(aSTR,{subStr(cCaraPont,nI,1), cReplace})
			Next nI
		EndIf

		If lEspec
			For nI := 1 to Len(cCaraEspec)
				aAdd(aSTR,{subStr(cCaraEspec,nI,1), cReplace})
			Next nI
		EndIf

		If lSQL // Trata string SQL
			If lUpper
				cString := " Upper(" + cString + ")" 
			EndIf

			For nI := 1 To Len(aSTR)
				If aSTR[nI][1] == "'"
					 aSTR[nI][1] := "''"
				EndIf

				If nI == 1
					cRet := "REPLACE(" + cString + ",'" + aSTR[nI][1] + "','" + aSTR[nI][2] + "'),"
				Else
					cRet := "REPLACE(" +cRet + "'" + aSTR[nI][1] + "','" + aSTR[nI][2] + "'),"
				EndIf
			Next nI

			cRet := SubStr(cRet, 1, Len(cRet)-1)

		Else // Trata String ADVPL
			If lUpper
				cString := Upper(cString)
			EndIf

			For nI := 1 To Len( aSTR )
				cString := StrTran(cString, aSTR[nI][1], aSTR[nI][2])
			Next
			cRet := cString
		EndIf
	EndIf

	ASIZE( aSTR, 0 )
	aSTR := Nil
return cRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldPrinter
Validação do printer para exportação XLSX

@type  Function
@author Carolina Neiva/Glória Maria
@since 22/09/2022

@return lValid
/*/
//-------------------------------------------------------------------

Function JVldPrinter()
Local lValid := .F.
Local clibVersion := __FWLibVersion()
Local cPrinterVrs := PrinterVersion():fromServer()

	lValid = clibVersion >= '20201009' .And.  ;
			(cPrinterVrs >= '2.1.4' .or. (cPrinterVrs >= '2.1.0' .And. SrvDisplay()))
   
Return lValid
