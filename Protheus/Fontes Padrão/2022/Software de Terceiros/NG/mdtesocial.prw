#INCLUDE "Protheus.ch"
#INCLUDE "MDTESOCIAL.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTESOCIAL
Fonte com as fun��es gen�ricas usadas nos eventos de integra��o do SIGAMDT com o eSocial

@author Luis Fellipy Bett
@since 16/07/2018
/*/
//---------------------------------------------------------------------

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTVldEsoc
Fun��o gen�rica que valida as condi��es para realizar a integra��o com o eSocial

@author  Luis Fellipy Bett
@since   09/11/2020

@return lRet, L�gico, Retorna verdadeiro caso exista integra��o
/*/
//---------------------------------------------------------------------
Function MDTVldEsoc()

	Local lRet := ( cPaisLoc == 'BRA' .And. SuperGetMv( "MV_NG2ESOC", .F., "2" ) == "1" )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTIntEsoc
Fun��o gen�rica que realiza valida��es e inicia o envio dos eventos ao Governo

@sample	MDTIntEsoc( "S-2210", 3, "0000001", {}, .T., oModel1, oModel2, @cMsgInc )

@param	cEvento, Caracter, Indica o evento que est� sendo enviado
@param	nOper, Num�rico, Indica a opera��o que est� sendo realizada (3-Inclus�o/4-Altera��o/5-Exclus�o)
@param	xFicMed, Caracter/Array, Indica a ficha m�dica do funcion�rio do Acidente ou do ASO (Utilizada apenas pelo S-2210 e S-2220)
@param	aFuncs, Array, Array contendo os funcion�rios que ter�o as informa��es validadas/enviadas (Utilizada apenas pelo S-2240)
	1� posi��o - Matr�cula do funcion�rio
	2� posi��o - Filial do funcion�rio
	3� posi��o - N�mero do risco
	4� posi��o - C�digo da tarefa do funcion�rio
	5� posi��o - Data in�cio da tarefa do funcion�rio
	6� posi��o - Data fim da tarefa do funcion�rio
	7� posi��o - Array com as informa��es da transfer�ncia (utilizado apenas pelo GPEA180)
		1� posi��o - Data da transfer�ncia
		2� posi��o - Empresa origem
		3� posi��o - Empresa destino
		4� posi��o - Filial origem
		5� posi��o - Filial destino
		6� posi��o - Matr�cula origem
		7� posi��o - Matr�cula destino
		8� posi��o - Centro de custo origem
		9� posi��o - Centro de custo destino
		10� posi��o - Departamento origem
		11� posi��o - Departamento destino
		12� posi��o - Fun��o destino
		13� posi��o - Cargo destino
		14� posi��o - C�digo �nico destino
	8� posi��o - Array com as informa��es dos EPIs entregues ao funcion�rio (Utilizado apenas pelo MDTA695 e MDTA630)
		1� posi��o - C�digo do EPI entregue
		2� posi��o - Data de entrega do EPI
	9� posi��o - Chave de busca do ASO a ser comunicado - Filial + C�digo do ASO (Utilizado apenas pelo S-2220)
@param	lEnvio, Boolean, Indica se � envio ou valida��o de informa��es
@param	oModelTNC, Objeto, Objeto do Acidente para busca de informa��es (Utilizada apenas pelo S-2210)
@param	oModelTNY, Objeto, Objeto do Atestado para busca de informa��es (Utilizada apenas pelo S-2210)
@param	cMsgInc, Caracter, Guarda a inconsist�ncia/solu��o e retorna para a chamada da fun��o (Utilizada apenas pelo S-2240)
@param	cChvRJE, Caracter, Guarda a chave do registro a ser utilizada na busca do registro na RJE

@author	Luis Fellipy Bett
@since	02/12/2020

@return lRet, L�gico, Retorna verdadeiro caso integra��o tenha sido bem sucedida

@obs N�o alterar o nome da fun��o pois � chamada tamb�m de espec�ficos (SSMDT01 - SEST/SENAT)
/*/
//---------------------------------------------------------------------
Function MDTIntEsoc( cEvento, nOper, xFicMed, aFuncs, lEnvio, oModelTNC, oModelTNY, cMsgInc, cChvRJE )

	//Vari�veis de controle de �rea/filial
	Local aArea	  := GetArea()
	Local cFilBkp := cFilAnt

	//Vari�veis de controle
	Local lRet := .T.
	Local lIntegra := .T. //Vari�vel respons�vel por definir se o evento deve ser integrado ou n�o

	//Vari�veis de par�metro
	Local leSocial	 := IIf( FindFunction( "MDTVldEsoc" ), MDTVldEsoc(), .F. )
	Local lSigaMdtPS := SuperGetMv( "MV_MDTPS", .F., "N" ) == "S"

	//Vari�veis de busca de informa��es
	Local cNumMat	 := ""
	Local aFunNaoEnv := {}
	Local aRetorno	 := {}

	//Vari�veis de par�metro private, usadas em todo o processo de valida��o e gera��o das informa��es
	Private dDtEsoc := SuperGetMv( "MV_NG2DTES", .F., SToD( "20211013" ) )
	Private lGPEA010 := FWIsInCallStack( "GPEA010" ) .Or. FWIsInCallStack( "Gpea010Put" ) // Cadastro de Funcion�rio
	Private lGPEA180 := FWIsInCallStack( "GPEA180" ) // Transfer�ncia
	Private lGPEA370 := FWIsInCallStack( "GPEA370" ) // Cargos
	Private lGPEM040 := FWIsInCallStack( 'Gpem040' ) // Rescis�o
	Private lMATA185 := FWIsInCallStack( "MATA185" ) // Gerar requisi��o (utilizada na fun��o fVldEsp2240)
	Private lMDTA005 := FWIsInCallStack( "MDTA005" ) // Cadastro de Fichas M�dicas
	Private lMDTA090 := FWIsInCallStack( "MDTA090" ) // Tarefas do func.
	Private lMDTA125 := FWIsInCallStack( "MDTA125" ) // Risco x EPI
	Private lMDTA130 := FWIsInCallStack( "MDTA130" ) // EPI x Risco
	Private lMDTA165 := FWIsInCallStack( "MDTA165" ) // Ambiente F�sico
	Private lMDTA180 := FWIsInCallStack( "D180INCL" ) // Cadastro de Risco
	Private lMDTA181 := FWIsInCallStack( "MDTA181" ) // Relacionamentos do Risco
	Private lMDTA215 := FWIsInCallStack( "MDTA215" ) // Laudos x Risco
	Private lMDTA630 := FWIsInCallStack( "MDTA630" ) // EPI x Funcion�rio
	Private lMDTA695 := FWIsInCallStack( "MDTA695" ) // Funcion�rio x EPI
	Private lMDTA881 := FWIsInCallStack( "MDTA881" ) // Carga Inicial
	Private lMDTA882 := FWIsInCallStack( "MDTA882" ) // Schedule de Tarefas
	Private lExecAuto := IIf( lGPEA010 .And. Type( "lGp010Auto" ) != "U", lGp010Auto, .F. ) .Or. IsBlind()
	Private lMiddleware	:= IIf( cPaisLoc == 'BRA' .And. Findfunction( "fVerMW" ), fVerMW(), .F. )

	Default lEnvio	  := .T. //Por padr�o sempre faz o envio ao Governo, se passado como .F. apenas valida as informa��es a serem enviadas e n�o envia
	Default oModelTNC := Nil
	Default oModelTNY := Nil
	Default cMsgInc	  := ""
	Default cChvRJE	  := ""
	Default aFuncs	  := {}

	//---------------------------------------------------------------------------
	// Fun��o gen�rica para posicionar na filial correta em chamadas espec�ficas
	//---------------------------------------------------------------------------
	fPosFil( cEvento )
	
	If cEvento == "S-2210" .Or. cEvento == "S-2220"
		If ValType( xFicMed ) == "A" //Caso tiver passado um array com as fichas a serem comunicadas
			aFuncs := fGetMatFic( xFicMed )
		Else
			If !Empty( cNumMat := MDTDadFun( xFicMed )[1] ) //Busca a matr�cula do funcion�rio
				aFuncs := { { cNumMat } } //Adiciona a matr�cula no array
			EndIf
		EndIf
	EndIf

	//--------------------------------
	// Realiza as valida��es iniciais
	//--------------------------------
	If lSigaMdtPS //Valida se � Prestador
		lIntegra := .F.
	ElseIf !leSocial //Valida se tem integra��o com o eSocial
		lIntegra := .F.
	ElseIf ( cEvento == "S-2210" .Or. cEvento == "S-2220" ) .And. Len( aFuncs ) == 0 //Valida se as fichas m�dicas 
		lIntegra := .F.
	ElseIf cEvento == "S-2240" .And. lMDTA005 .And. Empty( IIf( lEnvio, TM0->TM0_MAT, M->TM0_MAT ) ) //Valida se a ficha m�dica � de funcion�rio
		lIntegra := .F.
	EndIf

	//-----------------------------------------------
	// Verifica se o funcion�rio deve ser comunicado
	// ao SIGATAF/Middleware ou n�o
	//-----------------------------------------------
	If lIntegra

		//Valida se algum funcion�rio n�o deve ser integrado
		fFunNaoEnv( cEvento, @aFuncs, nOper, @aFunNaoEnv )

		//Verifica se existe pelo menos um funcion�rio que deve ser integrado
		lIntegra := Len( aFuncs ) > 0

	EndIf

	//--------------------------------------
	// Caso as valida��es predecessoras
	// estejam ok, valida/envia ao eSocial
	//--------------------------------------
	If lIntegra
		If cEvento == "S-2210"
			aRetorno := MDTS2210( cNumMat, nOper, lEnvio, oModelTNC, oModelTNY, cChvRJE )
		ElseIf cEvento == "S-2220"
			aRetorno := MDTS2220( aFuncs, nOper, lEnvio, cChvRJE, @aFunNaoEnv )
		ElseIf cEvento == "S-2240"
			aRetorno := MDTS2240( aFuncs, nOper, lEnvio, @cMsgInc, cChvRJE, @aFunNaoEnv )
		EndIf

		lRet := aRetorno[ 1 ]
		lIntegra := aRetorno[ 2 ]
	EndIf

	//-------------------------------------------------------------
	// Caso seja ap�s o envio, o envio tenha ocorrido sem
	// inconsist�ncias e tenha funcion�rios que n�o foram enviados
	//-------------------------------------------------------------
	If lEnvio .And. Len( aFunNaoEnv ) > 0
		fMsgNaoEnv( aFunNaoEnv, @cMsgInc ) //Exibe a mensagem informando quais funcion�rios n�o foram comunicados
	EndIf

	cFilAnt := cFilBkp //Retorna para filial atual
	RestArea( aArea ) //Retorna �rea

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTS2210
Fun��o gen�rica que valida o envio das informa��es do evento S-2210 (CAT)

@sample	MDTS2210( 3, "000021", .F., oModel1, oModel2 )

@param cNumMat, Caracter, Indica a matr�cula do funcion�rio do Acidente
@param nOper, Num�rico, Indica a opera��o que est� sendo realizada (3-Inclus�o/4-Altera��o/5-Exclus�o)
@param lEnvio, Boolean, Indica no caso de Acidente, se � envio ou valida��o de informa��es
@param oModelTNC, Objeto, Objeto do Acidente para busca de informa��es
@param oModelTNY, Objeto, Objeto do Atestado para busca de informa��es
@param cChvRJE, Caracter, Guarda a chave do registro a ser utilizada na busca do registro na RJE

@author	Luis Fellipy Bett
@since	09/11/2020

@return lRet, Boolean, Retorna verdadeiro caso a integra��o tenha sido bem sucedida
/*/
//---------------------------------------------------------------------
Function MDTS2210( cNumMat, nOper, lEnvio, oModelTNC, oModelTNY, cChvRJE )

	//Vari�veis de controle de �rea/filial
	Local aAreaTNC := TNC->( GetArea() )

	//Vari�veis de controle
	Local lRet	   := .T.
	Local lIntegra := .T.
	Local lValida  := !lEnvio //Caso n�o for envio das informa��es, valida

	//Vari�veis de chamadas utilizadas no MDTM002 para valida��o das informa��es
	Private lAcidente	 := fVerStack( "MDTA640", oModelTNC )
	Private lDiagnostico := fVerStack( "MDTA155", oModelTNC )
	Private lAtestado	 := fVerStack( "MDTA685", oModelTNC )

	//Vari�vel de par�metro
	Private cAtendAci := SuperGetMv( "MV_NG2IATE", .F., "3" )

	//---------------------------------------------------------------------------
	// Realiza as valida��es iniciais de envio, para verificar se o registro que
	// est� sendo incluido/alterado/exclu�do deve ser comunicado com o Governo
	//---------------------------------------------------------------------------
	If lAcidente .And. !fVincCAT( oModelTNC ) //Verifica se a CAT est� vinculada a um diagn�stico/atestado
		lIntegra := .F.
	ElseIf lDiagnostico .And. cAtendAci == "2" //Valida se o Diagn�stico deve ser considerado para envio das informa��es do atendimento
		lIntegra := .F.
	ElseIf lAtestado .And. cAtendAci == "1" //Valida se o Atestado deve ser considerado para envio das informa��es do atendimento
		lIntegra := .F.
	ElseIf lDiagnostico .And. Empty( M->TMT_ACIDEN ) //Valida se o Diagn�stico est� vinculado a um acidente
		lIntegra := .F.
	ElseIf lAtestado .And. Empty( oModelTNY:GetValue( "TNYMASTER1", "TNY_ACIDEN" ) ) //Valida se o Atestado est� vinculado a um acidente
		lIntegra := .F.
	ElseIf !( IIf( lAcidente, oModelTNC:GetValue( "TNCMASTER", "TNC_DTACID" ), TNC->TNC_DTACID ) >= dDtEsoc ) //Valida se a data do acidente � posterior a data in�cio das obrigatoriedades de SST
		lIntegra := .F.
	ElseIf !( IIf( lAcidente, oModelTNC:GetValue( "TNCMASTER", "TNC_INDACI" ), TNC->TNC_INDACI ) $ "1/2/3" ) //Valida se � acidente t�pico, doen�a do trabalho ou acidente de trajeto
		lIntegra := .F.
	ElseIf lValida .And. ( nOper == 3 .Or. nOper == 4 ) //Caso for inclus�o ou altera��o
		If lAcidente .And. !MDTObriEsoc( "TNC", , oModelTNC ) //Valida os campos obrigat�rios do Acidente
			lIntegra := .F.
			lRet := .F. //Caso os campos obrigat�rios n�o estiverem preenchidos, retorna falso para parar o envio
		ElseIf lDiagnostico .And. !MDTObriEsoc( "TMT" ) //Valida os campos obrigat�rios do Diagn�stico
			lIntegra := .F.
			lRet := .F. //Caso os campos obrigat�rios n�o estiverem preenchidos, retorna falso para parar o envio
		ElseIf lAtestado .And. !MDTObriEsoc( "TNY", , oModelTNY ) //Valida os campos obrigat�rios do Atestado
			lIntegra := .F.
			lRet := .F. //Caso os campos obrigat�rios n�o estiverem preenchidos, retorna falso para parar o envio
		EndIf
	EndIf

	//-----------------------------------------------------------------------
	// Realiza as valida��es do ambiente de envio, para verificar vers�o do
	// leiaute, se o ambiente do cliente tem dicion�rios aplicados, etc
	//-----------------------------------------------------------------------
	If lValida .And. lIntegra .And. !MDTVerAPrp( "S2210" )
		lIntegra := .F.
		lRet := .F. //Caso o ambiente n�o estiver preparado, retorna falso para parar o envio
	EndIf

	If lIntegra //Caso as valida��es predecessoras estejam ok, valida/envia ao eSocial

		If lAtestado .Or. lDiagnostico //Caso for cadastro de Acidente

			If nOper == 3 .Or. nOper == 5 //Se for inclus�o ou exclus�o de Diagn�stico/Atestado, significa que � altera��o no evento de Acidente, portanto 4- Altera��o
				nOper := 4
			EndIf

			dbSelectArea( "TNC" )
			dbSetOrder( 1 ) // TNC_FILIAL + TNC_ACIDEN
			dbSeek( xFilial( "TNC" ) + IIf( lDiagnostico, M->TMT_ACIDEN, M->TNY_ACIDEN ) )

			cChvRJE := DToS( TNC->TNC_DTACID ) + StrTran( TNC->TNC_HRACID, ":", "" ) + TNC->TNC_TIPCAT //Chave do registro do acidente que vai ser alterado

		EndIf

		If nOper <> 5 .And. lValida //Caso a opera��o seja diferente de exclus�o, valida as informa��es a serem enviadas
			lRet := MDTVldDad( "S-2210", nOper, { { cNumMat } }, , oModelTNC )
		EndIf

		If ( lRet .Or. nOper == 5 ) .And. lEnvio //Caso for envio de informa��es e n�o apenas valida��o
			lRet := MDTEnvEsoc( "S-2210", nOper, { { cNumMat } }, oModelTNC, cChvRJE )
		EndIf
	EndIf

	RestArea( aAreaTNC ) //Retorna �rea da tabela TNC

Return { lRet, lIntegra }

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTS2220
Fun��o gen�rica que valida o envio das informa��es do evento S-2220 (ASO)

@sample	MDTS2220( 3, "000021" )

@param aFuncs, Array, Array contendo os funcion�ros a serem processados
@param nOper, Num�rico, Indica a opera��o que est� sendo realizada (3-Inclus�o/4-Altera��o/5-Exclus�o)
@param lEnvio, Boolean, Indica no caso de Acidente, se � envio ou valida��o de informa��es
@param cChvRJE, Caracter, Guarda a chave do registro a ser utilizada na busca do registro na RJE
@param	aFunNaoEnv, Array, Array que receber� os funcion�rios que n�o dever�o ser integrados

@author	Luis Fellipy Bett
@since	09/11/2020

@return lRet, L�gico, Retorna verdadeiro caso a integra��o tenha sido bem sucedida
/*/
//---------------------------------------------------------------------
Function MDTS2220( aFuncs, nOper, lEnvio, cChvRJE, aFunNaoEnv )

	//Vari�veis de controle de �rea/filial
	Local aAreaTMY := TMY->( GetArea() )

	Local lRet	   := .T.
	Local lIntegra := .T.
	Local lASORet  := .T.
	Local lValida  := !lEnvio //Caso n�o for envio das informa��es, valida

	//Vari�veis de chamadas
	Local lImpASO := IsInCallStack( "NGIMPRASO" ) .Or. IsInCallStack( "MDTR465" ) .Or. IsInCallStack( "NG200IMP" )

	//---------------------------------------------------------------------------
	// Realiza as valida��es iniciais de envio, para verificar se o registro que
	// est� sendo incluido/alterado/exclu�do deve ser comunicado com o Governo
	//---------------------------------------------------------------------------
	If lValida .And. !lImpASO .And. !MDTObriEsoc( "TMY" ) //Caso for cadastro de ASO, valida os campos obrigat�rios
		lIntegra := .F.
		lRet := .F. //Caso os campos obrigat�rios n�o estiverem preenchidos, retorna falso para parar o envio
	ElseIf !lImpASO .And. Empty( M->TMY_DTEMIS ) //Valida se o ASO j� foi emitido
		lIntegra := .F.
	ElseIf !( IIf( lImpASO, dDataBase, M->TMY_DTEMIS ) >= dDtEsoc ) //Valida se a data do ASO � posterior a data in�cio das obrigatoriedades de SST
		lIntegra := .F.
	EndIf

	//-----------------------------------------------------------------------------
	// Realiza valida��es verificando caso o funcion�rio estiver demitido se o ASO
	// � demissional, se n�o for exclui o funcion�rio do array para n�o enviar
	//-----------------------------------------------------------------------------
	If lIntegra
		
		//Valida para os funcion�rio demitidos, se o ASO que est� sendo integrado � ASO demissional
		fVldFunDem( @aFuncs, lImpASO )

		//Verifica se existe pelo menos um funcion�rio que deve ser integrado
		lIntegra := Len( aFuncs ) > 0

	EndIf

	//----------------------------------------------------------------------------
	// Verifica se o evento deve ser enviado de acordo com o par�metro MV_NG2DENO 
	// caso o funcion�rio n�o esteja exposto a nenhum risco
	//----------------------------------------------------------------------------
	If lIntegra
	
		//Valida se existe algum funcion�rio sem exposi��o a risco que tenha o evento sendo enviado com uma data menor que a do par�metro MV_NG2DENO
		fEveNObrig( "S-2220", @aFuncs, nOper, @aFunNaoEnv )

		//Verifica se existe pelo menos um funcion�rio que deve ser integrado
		lIntegra := Len( aFuncs ) > 0

	EndIf

	//-----------------------------------------------------------------------
	// Realiza as valida��es do ambiente de envio, para verificar vers�o do
	// leiaute, se o ambiente do cliente tem dicion�rios aplicados, etc
	//-----------------------------------------------------------------------
	If lValida .And. lIntegra .And. !MDTVerAPrp( "S2220" )
		lIntegra := .F.
		lRet := .F.
	EndIf

	//---------------------------------------------------------------------------------
	// Realiza a valida��o referente a ASO admissional, verificando se existem
	// outros ASO's admissionais cadastrados para o funcion�rio no SIGATAF/Middleware
	//---------------------------------------------------------------------------------
	If lValida .And. lIntegra .And. nOper != 5 //Caso seja valida��o, deva integrar o evento e n�o for exclus�o

		//Verifica se existem ASO's admissionais anteriores pra casos de envio de ASO admissional		
		lASORet := fVldASOAdm( aFuncs, lImpASO )

		//Adiciona o retorno da fun��o �s vari�veis
		lIntegra := lASORet
		lRet := lASORet

	EndIf

	//Caso as valida��es predecessoras estejam ok, valida/envia ao eSocial
	If lIntegra

		//Caso n�o for exclus�o de registro e deva validar
		If nOper <> 5 .And. lValida
			lRet := MDTVldDad( "S-2220", nOper, aFuncs )
		EndIf

		If ( lRet .Or. nOper == 5 ) .And. lEnvio
			lRet := MDTEnvEsoc( "S-2220", nOper, aFuncs, , cChvRJE ) //Envia as informa��es ao Governo
		EndIf

	EndIf

	RestArea( aAreaTMY ) //Retorna �rea da tabela TMY

Return { lRet, lIntegra }

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTS2240
Fun��o gen�rica que valida o envio das informa��es do evento S-2240 (Riscos)

@sample	MDTS2240( { { "000021" } }, 3, .F., @cMsg )

@param aFuncs, Array, Array contendo os funcion�rios que ter�o as informa��es validadas/enviadas
@param nOper, Num�rico, Indica a opera��o que est� sendo realizada (3-Inclus�o/4-Altera��o/5-Exclus�o)
@param lEnvio, Boolean, Indica no caso de Acidente, se � envio ou valida��o de informa��es
@param cMsgInc, Caracter, Guarda a inconsist�ncia/solu��o e retorna para a chamada da fun��o
@param cChvRJE, Caracter, Guarda a chave do registro a ser utilizada na busca do registro na RJE
@param	aFunNaoEnv, Array, Array que receber� os funcion�rios que n�o dever�o ser integrados

@author	Luis Fellipy Bett
@since	09/11/2020

@return	lRet, L�gico, Retorna verdadeiro caso a integra��o tenha sido bem sucedida
/*/
//---------------------------------------------------------------------
Function MDTS2240( aFuncs, nOper, lEnvio, cMsgInc, cChvRJE, aFunNaoEnv )

	//Vari�veis de controle e contadores
	Local lRet	   := .T.
	Local lIntegra := .T.
	Local lValida  := .T.

	//Vari�veis de par�metro
	Local lIntRHTAF	 := SuperGetMv( "MV_RHTAF", .F., .F. )

	//Caso for Carga Inicial ou execu��o do Schedule de Tarefas, realiza a valida��o
	//Apenas o GPEA010, GPEA180, MDTA881 e MDTA882 devem ficar nessa condi��o, os outros devem ser ajustados a etapa de valida��o e envio separadamente
	If lMDTA125 .Or. lMDTA130 .Or. lMDTA181 .Or. lMDTA215 .Or. lMDTA881 .Or. lMDTA882 .Or. lGPEA180 .Or. lGPEA010 .Or. lMATA185
		lValida := .T.
	Else
		lValida := !lEnvio
	EndIf

	//---------------------------------------------------------------------------
	// Realiza as valida��es iniciais de envio, para verificar se o registro que
	// est� sendo incluido/alterado/exclu�do deve ser comunicado com o Governo
	//---------------------------------------------------------------------------
	If ( lMDTA180 .Or. lMDTA181 ) .And. Empty( M->TN0_DTAVAL ) // Valida se o risco est� avaliado, caso n�o estiver n�o envia

		lIntegra := .F.

	// Valida se o agente do risco n�o est� vazio e � diferente do c�digo de aus�ncia
	ElseIf ( lMDTA180 .Or. lMDTA181 ) .And. ( Empty( Posicione( "TMA", 1, xFilial( "TMA" ) + M->TN0_AGENTE, "TMA_ESOC" ) ) .Or. ;
		Posicione( "TMA", 1, xFilial( "TMA" ) + M->TN0_AGENTE, "TMA_ESOC" ) == "09.01.001" )

		lIntegra := .F.

	ElseIf ( lMDTA180 .Or. lMDTA181 ) .And. !Empty( M->TN0_DTELIM ) .And. M->TN0_DTELIM <= dDtEsoc //Caso o risco foi eliminado antes ou no dia da entrada do eSocial

		lIntegra := .F.

	ElseIf ( lGPEA010 .Or. lGPEA180 ) .And. ( !lIntRHTAF .And. !lMiddleware ) // Se Cadastro de Funcion�rio ou Transfer�ncias, verifica se existe integra��o do RH com o TAF ou com o Middleware

		lIntegra := .F.

	ElseIf lGPEA010 .And. !fVldEnvFun() // Valida se houve alguma altera��o no cadastro do funcion�rio que necessite retificar o S-2240

		lIntegra := .F.

	ElseIf lValida .And. lMDTA180 .And. !MDTObriEsoc( "TN0", !( Inclui .Or. Altera ) )

		// Caso os campos obrigat�rios n�o estiverem preenchidos, retorna falso para parar o envio
		lIntegra := .F.
		lRet := .F.

	// Verifica se o EPI j� foi enviado anteriormente ## Verifica o v�nculo do EPI com o risco
	ElseIf ( lMDTA630 .Or. lMDTA695 .Or. lMATA185 ) .And. !fVldEPIRis( @cMsgInc, aFuncs, lValida )

		lIntegra := .F.

	EndIf

	//----------------------------------------------------------------------------
	// Verifica se o evento deve ser enviado de acordo com o par�metro MV_NG2DENO 
	// caso o funcion�rio n�o esteja exposto a nenhum risco
	//----------------------------------------------------------------------------
	If lIntegra
	
		//Valida se existe algum funcion�rio sem exposi��o a risco que tenha o evento sendo enviado com uma data menor que a do par�metro MV_NG2DENO
		fEveNObrig( "S-2240", @aFuncs, nOper, @aFunNaoEnv )

		//Verifica se existe pelo menos um funcion�rio que deve ser integrado
		lIntegra := Len( aFuncs ) > 0

	EndIf

	//-----------------------------------------------------------------------
	// Realiza as valida��es do ambiente de envio, para verificar vers�o do
	// leiaute, se o ambiente do cliente tem dicion�rios aplicados, etc
	//-----------------------------------------------------------------------
	If lValida .And. lIntegra .And. !MDTVerAPrp( "S2240", @cMsgInc )
		lIntegra := .F.
		lRet := .F.
	EndIf

	//--------------------------------------
	// Realiza verifica��es espec�ficas
	// para algumas chamadas do S-2240
	//--------------------------------------
	If lValida .And. lIntegra
		fVldEsp2240( @cMsgInc, aFuncs, nOper )
	EndIf

	//-------------------------------------------------------------
	// Ajusta a chave �nica se necess�rio quando for transfer�ncia
	//-------------------------------------------------------------
	If lIntegra .And. lGPEA180
		fAjsCodUni( @aFuncs )
	EndIf

	If lIntegra //Caso as valida��es predecessoras estejam ok, valida/envia ao eSocial

		If nOper == 5 //Caso for exclus�o, trata como retifica��o do S-2240
			nOper := 4
		EndIf

		If nOper <> 5 .And. lValida
			Processa( { || lRet := MDTVldDad( "S-2240", nOper, aFuncs, , , , @cMsgInc ) }, STR0001 ) //Valida as informa��es a serem enviadas ## "Aguarde, validando os registros..."
		EndIf

		If ( lRet .Or. nOper == 5 ) .And. lEnvio
			Processa( { || lRet := MDTEnvEsoc( "S-2240", nOper, aFuncs, , cChvRJE, @cMsgInc ) }, STR0002 ) //Envia as informa��es ao Governo ## "Aguarde, enviando os registros..."
		EndIf
	EndIf

Return { lRet, lIntegra }

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTVerAPrp
Fun��o gen�rica que verifica se o ambiente est� preparado para o envio dos dados ao eSocial

@sample MDTVerAPrp( S2210, .T., @cMsgInc )

@param cEvento, Caracter, Indica o evento que est� sendo enviado
@param cMsgInc, Caracter, Guarda a inconsist�ncia e a solu��o e retorna para a chamada da fun��o

@author  Luis Fellipy Bett
@since   10/11/2020

@return lRet, L�gico, Retorna verdadeiro caso exista integra��o
/*/
//---------------------------------------------------------------------
Function MDTVerAPrp( cEvento, cMsgInc )

	//Vari�veis de controle
	Local lRet := .T.
	Local cVersLyt := ""
	Local cTAFVLES := SuperGetMv( 'MV_TAFVLES', .F., "02_05_00" )

	//Vari�veis de busca de informa��o
	Local aTAF	  := {}
	Local cIncons := ""
	Local cCorrec := ""
	Local cStatus := "-1" //Verifica��o dos eventos predecessores - Evento S1000

	If lMiddleware //Valida��es de ambiente do Middleware
		If !ChkFile( "RJE" ) //Verifica se a tabela RJE existe
			cIncons := STR0003 //"Tabela RJE n�o encontrada"
			cCorrec := STR0004 //"Favor aplicar o pacote acumulado do eSocial para atualiza��o do ambiente"
		ElseIf !ChkFile( "RJ9" ) //Verifica se a tabela RJ9 existe
			cIncons := STR0005 //"Tabela RJ9 n�o encontrada"
			cCorrec := STR0004 //"Favor aplicar o pacote acumulado do eSocial para atualiza��o do ambiente"
		ElseIf Len( fXMLInfos() ) <= 0
			cIncons := STR0006 //"N�o foram encontradas as informa��es da empresa na tabela RJ9"
			cCorrec := STR0007 //"Favor configurar a empresa para envio das informa��es"
		ElseIf FindFunction( "fVersEsoc" )
			fVersEsoc( cEvento, .F., , , Nil, Nil, @cVersLyt )

			If !( "S_01_00" $ cVersLyt .Or. ( "02_05_00" $ cVersLyt .And. fVldMDTAtu() ) )
				cIncons := STR0069 //"Os eventos de SST do eSocial somente ser�o enviados caso o leiaute seja o S-1.0 simplificado ou o 2.5 e o ambiente esteja atualizado com o pacote da simplifica��o"
				cCorrec := STR0070 //"Favor configurar o ambiente nas condi��es citadas"
			EndIf
		ElseIf !fVld1000( AnoMes( dDataBase ), @cStatus )

			// 1 - N�o enviado 			- Gravar por cima do registro encontrado
			// 2 - Enviado 				- Aguarda Retorno ( Enviar mensagem em tela e n�o continuar com o processo )
			// 3 - Retorno com Erro		- Gravar por cima do registro encontrado
			// 4 - Retorno com Sucesso	- Efetivar a grava��o

			If cStatus == "-1" .Or. cStatus == "0" // nao encontrado na base de dados
				cIncons := STR0008 //"Registro do evento S-1000 n�o localizado na base de dados"
			ElseIf cStatus == "1" // nao enviado para o governo
				cIncons := STR0009 //"Registro do evento S-1000 n�o transmitido para o governo"
			ElseIf cStatus == "2" // enviado e aguardando retorno do governo
				cIncons := STR0010 //"Registro do evento S-1000 aguardando retorno do governo"
			ElseIf cStatus == "3" // enviado e retornado com erro
				cIncons := STR0011 //"Registro do evento S-1000 retornado com erro do governo"
			EndIf
			cCorrec := STR0012 //"Favor efetivar primeiramente o envio do evento S-1000"

		EndIf
	Else //Valida��es de ambiente do TAF
		aTAF := TafExisEsc( cEvento )

		If !aTAF[ 1 ] //Verifica se existe integra��o com o SIGATAF
			cIncons := STR0013 //"O ambiente n�o possui integra��o com o m�dulo do TAF"
			cCorrec := STR0014 //"Favor verificar"
		ElseIf aTAF[ 2 ] <> "1.0" //Verifica se o leiaute do eSocial � o mais atual
			cIncons := STR0015 //"A vers�o do TAF est� desatualizada"
			cCorrec := STR0014 //"Favor verificar"
		ElseIf !( "S_01_00" $ cTAFVLES .Or. ( "02_05_00" $ cTAFVLES .And. fVldMDTAtu() ) )
			cIncons := STR0069 //"Os eventos de SST do eSocial somente ser�o enviados caso o leiaute seja o S-1.0 simplificado ou o 2.5 e o ambiente esteja atualizado com o pacote da simplifica��o"
			cCorrec := STR0070 //"Favor configurar o ambiente nas condi��es citadas"
		EndIf
	EndIf

	//Valida��es de ambiente do SIGAMDT
	If Empty( cIncons ) .And. !fVldMDTAtu() //Verifica se o ambiente do MDT est� atualizado
		cIncons := STR0016 //"A vers�o do MDT est� desatualizada"
		cCorrec := STR0004 //"Favor aplicar o pacote acumulado do eSocial para atualiza��o do ambiente"
	EndIf

	If !Empty( cIncons ) //Caso houver erro nas valida��es
		If !lExecAuto //Caso n�o for execu��o autom�tica (via Schedule) emite a mensagem
			Help( ' ', 1, STR0017, , cIncons, 2, 0, , , , , , { cCorrec } ) //STR0017
		Else
			cMsgInc += CRLF + "- " + STR0018 + ": " + cIncons + CRLF + "- " + STR0019 + ": " + cCorrec //Ocorr�ncia ## Solu��o
		EndIf
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldMDTAtu
Valida se o SIGAMDT est� atualizado e preparado para o envio dos eventos

@sample fVldMDTAtu()

@author  Luis Fellipy Bett
@since   09/03/2021

@return lRet, L�gico, Retorna verdadeiro caso esteja atualizado
/*/
//---------------------------------------------------------------------
Static Function fVldMDTAtu()

	Local aArea	:= GetArea()
	Local lRet	:= .T.

	dbSelectArea( "TNE" )
	If Empty( IndexKey( 2 ) ) //Caso o �ndice 2 da TNE n�o exista, significa que o ambiente est� desatualizado
		lRet := .F.
	EndIf

	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTVldDad
Fun��o gen�rica que valida os dados dos Xml's a serem enviados ao Governo

@sample MDTVldDad( "S-2210", 3, .T., oModel )

@param cEvento, Caracter, Indica o evento que est� sendo enviado
@param nOper, Num�rico, Indica a opera��o que est� sendo realizada (3-Inclus�o/4-Altera��o/5-Exclus�o)
@param aFuncs, Array, Array contendo os funcion�rios que ter�o as informa��es de envio validadas
@param lXml, Boolean, Indica se � gera��o de Xml
@param oModel, Objeto, Modelo a ser utilizado pela busca das informa��es do Acidente (S-2210)
@param dDataEnv, Data, Data a ser considerada no envio do evento
@param cMsgInc, Caracter, Guarda a inconsist�ncia e a solu��o e retorna para a chamada da fun��o

@author  Luis Fellipy Bett
@since   09/11/2020

@return lRet, L�gico, Retorna verdadeiro caso n�o existam inconsist�ncias
/*/
//---------------------------------------------------------------------
Function MDTVldDad( cEvento, nOper, aFuncs, lXml, oModel, dDataEnv, cMsgInc )

	//Vari�veis de controle
	Local lRet := .T.
	Local cFilBkp := cFilAnt

	//Vari�veis de contadores
	Local nCont := 0

	//Vari�veis de composi��o de informa��es
	Local aIncEnv  := {}
	Local cFonte   := IIf( cEvento == "S-2210", "MDTM002", IIf( cEvento == "S-2220", "MDTM003", "MDTM004" ) )
	Local cNomeFun := ""
	Local dDtAtu   := SToD( "" )
	Local aGPEA180 := {}
	Local cChvASO  := ""

	//Vari�veis private para busca das informa��es da filial de envio e empresa e filial destino no caso da transfer�ncia
	Private cEmpDes := cEmpAnt //Empresa destino (utilizado pelo GPEA180), inicia por padr�o como a empresa atual
	Private cFilDes := cFilAnt //Filial destino (utilizado pelo GPEA180), inicia por padr�o como a filial atual
	Private cFilEnv := "" //Filial de envio do TAF/Middleware

	Default lXml	 := .F.
	Default oModel	 := Nil
	Default dDataEnv := SToD( "" )
	Default cMsgInc  := ""

	//Trata mensagem inicial de inconsist�ncias
	If cEvento == "S-2210"
		aAdd( aIncEnv, STR0020 + " (" + cEvento + ")" ) //"Inconsist�ncias da CAT"
	ElseIf cEvento == "S-2220"
		aAdd( aIncEnv, STR0021 + " (" + cEvento + ")" ) //"Inconsist�ncias do ASO"
	ElseIf cEvento == "S-2240"
		aAdd( aIncEnv, STR0022 + " (" + cEvento + ")" ) //"Inconsist�ncias dos Riscos"
	EndIf
	aAdd( aIncEnv, STR0023 + ": " ) //"Os campos abaixo est�o em branco ou possuem inconsist�ncia com rela��o ao formato padr�o do eSocial"
	aAdd( aIncEnv, "" )
	aAdd( aIncEnv, "" )

	//Define o tamanho da r�gua de processamento, caso envio do evento S-2240
	If cEvento == "S-2240"
		ProcRegua( Len( aFuncs ) )
	EndIf

	//Passa por todos os funcion�rios, validando os dados a serem enviados ao SIGATAF/Middleware
	For nCont := 1 To Len( aFuncs )

		//Incrementa a r�gua, caso envio do evento S-2240
		If cEvento == "S-2240"
			IncProc()
		EndIf

		//---------------------------------------------------------------------------
		// Fun��o gen�rica para posicionar na filial correta em chamadas espec�ficas
		//---------------------------------------------------------------------------
		fPosFil( cEvento, IIf( Len( aFuncs[ nCont ] ) > 1 .And. aFuncs[ nCont, 2 ] <> Nil, aFuncs[ nCont, 2 ], "" ) )

		//------------------------------------------------------------------------------------
		// Caso for transfer�ncia (GPEA180) adiciona as informa��es da transfer�ncia do array
		//------------------------------------------------------------------------------------
		If lGPEA180
			aGPEA180 := aFuncs[ nCont, 7 ]

			cEmpDes := aGPEA180[ 1, 3 ]
			cFilDes := aGPEA180[ 1, 5 ]
		EndIf

		//----------------------------------------------------------------
		// Busca a filial de envio que ser� considerada no TAF/Middleware
		//----------------------------------------------------------------
		cFilEnv := MDTBFilEnv()

		//-----------------------------------------------------------------------
		// Realiza as valida��es de envio dos eventos S-2190, S-2200 ou S-2230,
		// que s�o de envio obrigat�rio antes do envio de qualquer evento de SST
		//-----------------------------------------------------------------------
		If !MDTVld2200( aFuncs[ nCont, 1 ], aGPEA180 ) //Valida o envio do evento S-2190, S-2200 ou S-2300 do funcion�rio
			cNomeFun := AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_NOME" ) )
			aAdd( aIncEnv, STR0024 + ": " + AllTrim( aFuncs[ nCont, 1 ] ) + " - " + cNomeFun ) //Funcion�rio: XXX - XXXXX
			aAdd( aIncEnv, STR0018 + ": " + STR0025 + " (" + cEvento + ") " + STR0026 ) //Ocorr�ncia: N�o ser� poss�vel integrar o evento XXX com o Governo pois o registro de Admiss�o ou Carga Inicial deste
			aAdd( aIncEnv, STR0027 ) //funcion�rio ainda n�o foi integrado via SIGATAF ou Middleware
			aAdd( aIncEnv, STR0019 + ": " + STR0028 ) //Solu��o: Favor efetivar primeiramente o envio do evento S-2190, S-2200 ou S-2300 do funcion�rio
			aAdd( aIncEnv, '' )
			Loop
		EndIf

		//-----------------------------------------------------------------------
		// Realiza as valida��es de envio dos eventos S-2200 ou S-2230, que s�o
		// de envio obrigat�rio antes do envio de qualquer evento de SST
		//-----------------------------------------------------------------------
		If cEvento == "S-2210" //Caso for evento de CAT

			MDTM002( nOper, .T., @aIncEnv, oModel ) //Avalia as inconsist�ncias da CAT

		ElseIf cEvento == "S-2220" //Caso for evento de ASO

			If Len( aFuncs[ nCont ] ) > 8 .And. aFuncs[ nCont, 9 ] <> Nil
				cChvASO := aFuncs[ nCont, 9 ]
			EndIf

			MDTM003( nOper, .T., @aIncEnv, , cChvASO ) //Avalia as inconsist�ncias do ASO

		ElseIf cEvento == "S-2240" //Caso for evento de Risco

			//Busca a data de exposi��o atual do evento S-2240
			dDtAtu := MDTDtExpAtu( aFuncs[ nCont, 1 ] )

			//Busca a data de envio a ser considerada no envio do evento S-2240
			dDataEnv := MDTBscDtEnv( aFuncs[ nCont ], nOper, lXml, dDtAtu )

			If !Empty( dDataEnv ) //Caso exista uma inclus�o/altera��o do per�odo de exposi��o, envia ao Governo
				MDTM004( aFuncs[ nCont, 1 ], nOper, dDataEnv, .T., @aIncEnv, , aGPEA180 ) //Avalia as inconsist�ncias do Risco
			EndIf

		EndIf

	Next nCont

	//Monta o relat�rio de inconsist�ncias
	If Len( aIncEnv ) > 4

		//Caso seja execu��o via tela e n�o seja chamada do GPEA180
		If !lExecAuto .And. !lGPEA180

			fMakeLog( { aIncEnv }, { STR0029 }, Nil, Nil, cFonte, OemToAnsi( STR0030 ), "M", "P", , .F. )

			If lXml
				cStrInc := STR0031 //"O Xml possui inconsist�ncias de acordo com o formato padr�o do eSocial"
			Else
				cStrInc := STR0032 //"Envio ao SIGATAF/Middleware n�o realizado"
			EndIf

			Help( ' ', 1, STR0017, , cStrInc, 2, 0, , , , , , { STR0033 } )

		Else

			//Adiciona as inconsist�ncias � vari�vel para gera��o do arquivo do Schedule
			For nCont := 1 To Len( aIncEnv )

				cMsgInc += CRLF + "- " + aIncEnv[ nCont ]

			Next nCont

			//Caso for execu��o autom�tica do GPEA010
			If lExecAuto

				//Adiciona no log
				AutoGrLog( cMsgInc )

			EndIf

		EndIf

		//Define o retorno como .F.
		lRet := .F.

	EndIf

	//Volta a filial
	cFilAnt := cFilBkp

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTEnvEsoc
Fun��o gen�rica que envia Xml's ao Governo, atrav�s do TAF ou Middleware

@param cEvento, Caracter, Indica o evento que est� sendo enviado
@param nOper, Num�rico, Indica a opera��o que est� sendo realizada (3-Inclus�o/4-Altera��o/5-Exclus�o)
@param cFicMed, Caracter, Indica a ficha m�dica do funcion�rio
@param oModel, Objeto, Objeto para busca de informa��es de rotinas em MVC
@param cChvRJE, Caracter, Guarda a chave do registro a ser utilizada na busca do registro na RJE
@param cMsgInc, Caracter, Guarda a inconsist�ncia e a solu��o e retorna para a chamada da fun��o

@author  Luis Fellipy Bett
@since   09/11/2020

@return lRet, L�gico, Retorna verdadeiro caso a integra��o tenha sido bem sucedida
/*/
//---------------------------------------------------------------------
Function MDTEnvEsoc( cEvento, nOper, aFuncs, oModel, cChvRJE, cMsgInc )

	// Vari�veis de controle de troca de empresa, quando transfer�ncia de empresa
	Local cEmpBkp  := cEmpAnt
	Local cFilBkp  := cFilAnt
	Local cArqBkp  := cArqTab

	//Vari�vel das tabelas a serem abertas
	Local aTbls := { 'C1E', 'CR9', 'C9V', 'T3A', 'CM9', 'CMA', 'CMB', 'LEA', 'T3S' }
	
	//Vari�veis de busca e valida��o das informa��es
	Local lRet	   := .T.
	Local cStrChv  := ""
	Local cXml	   := ""
	Local cChvAtu  := ""
	Local cChvNov  := ""
	Local cTAFKey  := "" //TAFKey a ser utilizada na integra��o do S-2210 (quando houver altera��o da data, hora ou tipo do acidente)
	Local cTpASO   := ""
	Local dDtASO   := SToD( "" )
	Local dDataEnv := SToD( "" )
	Local dDtAtu   := SToD( "" )
	Local cEvtAux  := SubStr( cEvento, 1, 1 ) + SubStr( cEvento, 3, 4 )
	Local aRetorno := {} //Recebe o erro de integra��o, se houver
	Local lExclu   := nOper == 5 //Define se � exclus�o de registro
	Local aGPEA180 := {}
	Local nCont    := 0
	Local lIntegra

	//Array que cont�m as informa��es do funcion�rio
	Local aDadFun := {}

	//Vari�veis private para busca das informa��es da filial de envio e empresa e filial destino no caso da transfer�ncia
	Private cEmpDes := cEmpAnt //Empresa destino (utilizado pelo GPEA180), inicia por padr�o como a empresa atual
	Private cFilDes := cFilAnt //Filial destino (utilizado pelo GPEA180), inicia por padr�o como a filial atual
	Private cFilEnv := "" //Filial de envio do TAF/Middleware

	Default oModel := Nil //Define modelo como nulo
	Default cMsgInc := ""

	//Define o tamanho da r�gua de processamento, caso envio do evento S-2240
	If cEvento == "S-2240"
		ProcRegua( Len( aFuncs ) )
	EndIf

	//Passa por todos os funcion�rios, enviando ao SIGATAF/Middleware
	For nCont := 1 To Len( aFuncs )

		//Incrementa a r�gua, caso envio do evento S-2240
		If cEvento == "S-2240"
			IncProc()
		EndIf

		//---------------------------------------------------------------------------
		// Fun��o gen�rica para posicionar na filial correta em chamadas espec�ficas
		//---------------------------------------------------------------------------
		fPosFil( cEvento, IIf( Len( aFuncs[ nCont ] ) > 1 .And. aFuncs[ nCont, 2 ] <> Nil, aFuncs[ nCont, 2 ], "" ) )

		//------------------------------------------------------------------------------------
		// Caso for transfer�ncia (GPEA180) adiciona as informa��es da transfer�ncia do array
		//------------------------------------------------------------------------------------
		If lGPEA180
			aGPEA180 := aFuncs[ nCont, 7 ]

			cEmpDes := aGPEA180[ 1, 3 ]
			cFilDes := aGPEA180[ 1, 5 ]
		EndIf

		//----------------------------------------------------------------
		// Busca a filial de envio que ser� considerada no TAF/Middleware
		//----------------------------------------------------------------
		cFilEnv := MDTBFilEnv()

		lIntegra := .T. //Seta como .T. para enviar

		If cEvento == "S-2220"
			If IsInCallStack( "NGIMPRASO" ) //Caso for chamado pela impress�o do ASO
				dDtASO := IIf( Empty( TMY->TMY_DTEMIS ), dDataBase, TMY->TMY_DTEMIS )
				cTpASO := MDTTpASO( TMY->TMY_NATEXA ) //Busca o tipo do ASO conforme leiaute do eSocial
			Else
				dDtASO := M->TMY_DTEMIS
				cTpASO := MDTTpASO( M->TMY_NATEXA ) //Busca o tipo do ASO conforme leiaute do eSocial
			EndIf
		ElseIf cEvento == "S-2240" //Caso for evento de Risco

			//Busca a data de exposi��o atual do evento S-2240
			dDtAtu := MDTDtExpAtu( aFuncs[ nCont, 1 ] )

			//Busca a data de envio a ser considerada no envio do evento S-2240
			dDataEnv := MDTBscDtEnv( aFuncs[ nCont ], nOper, , dDtAtu )

			cChvRJE := DToS( dDtAtu ) //Define a chave de busca do registro na tabela RJE

			lIntegra := !Empty( dDataEnv ) //Caso exista uma inclus�o/altera��o do per�odo de exposi��o, envia ao Governo
		EndIf

		If lIntegra
			aDadFun := MDTDadFun( aFuncs[ nCont, 1 ], .T. ) //Busca as informa��es do funcion�rio
			//Posi��es do retorno
			//1- Matr�cula
			//2- CPF
			//3- PIS
			//4- C�digo �nico
			//5- Categoria
			//6- Data de Admiss�o

			//-----------------------------------------------------------------------
			// Realiza a verifica��o de exist�ncia de um registro predecessor no
			// TAF ou Middleware (RJE), para saber o tipo do envio a ser feito
			//-----------------------------------------------------------------------
			If lMiddleware //Caso for envio via Middleware

				If cEvento == "S-2210" //Caso for evento de CAT
					If lAcidente //Caso seja chamado pelo Acidente
						cStrChv := DtoS( oModel:GetValue( 'TNCMASTER', 'TNC_DTACID' ) ) + StrTran( oModel:GetValue( 'TNCMASTER', 'TNC_HRACID' ), ":", "" ) + oModel:GetValue( 'TNCMASTER', 'TNC_TIPCAT' )
					Else
						cStrChv := DtoS( TNC->TNC_DTACID ) + StrTran( TNC->TNC_HRACID, ":", "" ) + TNC->TNC_TIPCAT
					EndIf
				ElseIf cEvento == "S-2220" //Caso for evento de ASO
					cStrChv := DToS( dDtASO )
				ElseIf cEvento == "S-2240" //Caso for evento de Risco
					cStrChv := DToS( dDataEnv )
				EndIf

				If MDTVerTSVE( aDadFun[5] ) //Caso seja Trabalhador Sem V�nculo Estatut�rio
					cChvAtu := AllTrim( aDadFun[3] ) + AllTrim( aDadFun[5] ) + DToS( aDadFun[6] ) + cChvRJE
					cChvNov := AllTrim( aDadFun[3] ) + AllTrim( aDadFun[5] ) + DToS( aDadFun[6] ) + cStrChv
				Else
					cChvAtu := AllTrim( aDadFun[4] ) + cChvRJE
					cChvNov := AllTrim( IIf( lGPEA180, aGPEA180[ 1, 14 ], aDadFun[4] ) ) + cStrChv
				EndIf

				//Verifica condi��es das chaves
				If ( cEvento == "S-2210" .Or. cEvento == "S-2220" .And. nOper == 3 ) .Or. ( cEvento == "S-2240" .And. Empty( cChvRJE ) )
					cChvAtu := cChvNov
				EndIf

				lExstReg := MDTVerStat( .T., cEvtAux, cChvAtu, lExclu )

			Else //Caso for envio via SIGATAF

				If cEvento == "S-2210" //Caso for evento de CAT
					If lAcidente
						cStrChv := ";" + SubStr( cChvRJE, 1, 8 ) + ";" + SubStr( cChvRJE, 9, 4 ) + ";" + SubStr( cChvRJE, 13, 1 )
						cChvAtu := cChvRJE
						cChvNov := DtoS( oModel:GetValue( 'TNCMASTER', 'TNC_DTACID' ) ) + StrTran( oModel:GetValue( 'TNCMASTER', 'TNC_HRACID' ), ":", "" ) + oModel:GetValue( 'TNCMASTER', 'TNC_TIPCAT' )
					Else
						cStrChv := ";" + DtoS( TNC->TNC_DTACID ) + ";" + StrTran( TNC->TNC_HRACID, ":", "" ) + ";" + TNC->TNC_TIPCAT
						cChvAtu := DtoS( TNC->TNC_DTACID ) + StrTran( TNC->TNC_HRACID, ":", "" ) + TNC->TNC_TIPCAT
					EndIf
					nIndEsp := 4
				ElseIf cEvento == "S-2220" //Caso for evento de ASO
					cStrChv := ";" + cTpASO + ";" + DToS( dDtASO )
					cChvAtu := cTpASO + DToS( dDtASO )
					nIndEsp := 2
				ElseIf cEvento == "S-2240" //Caso for evento de Risco
					cStrChv := ";" + DToS( dDataEnv )
					cChvAtu := DToS( dDataEnv )
					nIndEsp := 5
				EndIf

				//Verifica o status do registro nas tabelas do SIGATAF
				lExstReg := TAFGetStat( cEvento, aDadFun[3] + aDadFun[4] + cStrChv, , cFilEnv, nIndEsp ) != "-1"

			EndIf

			//-----------------------------------------------------------------------
			// Verifica o tipo da opera��o que est� sendo realizada
			// (3-Inclus�o/4-Altera��o/5-Exclus�o) e carrega o Xml de acordo
			//-----------------------------------------------------------------------
			If nOper == 5 //Caso for exclus�o de registro
				If lExstReg
					cXml := MDTM006( cEvtAux, aDadFun[1], cChvAtu )
				EndIf
			Else
				If nOper == 4 .And. !lExstReg //Caso for altera��o de registro e o evento predecessor n�o exista, envia uma inclus�o
					nOper := 3
				ElseIf nOper == 3 .And. lExstReg //Caso for inclus�o de registro e o evento predecessor exista, envia uma altera��o
					nOper := 4
				EndIf

				If cEvento == "S-2210" //Caso for evento de CAT
					cXml := MDTM002( nOper, , , oModel, cChvAtu, cChvNov, @cTAFKey ) //Carrega o Xml
				ElseIf cEvento == "S-2220" //Caso for evento de ASO
					cXml := MDTM003( nOper, , , cChvAtu ) //Carrega o Xml
				ElseIf cEvento == "S-2240" //Caso for evento de Risco
					cXml := MDTM004( aFuncs[ nCont, 1 ], nOper, dDataEnv, , , cChvAtu, aGPEA180 ) //Carrega o Xml
				EndIf
			EndIf

			//-----------------------------------------------------------------------
			// Realiza a integra��o do evento com o Governo, atrav�s do
			// SIGATAF ou do Middleware
			//-----------------------------------------------------------------------
			If !Empty( cXml ) //Caso tenha Xml a ser integrado

				//Caso o envio do evento for via Middleware
				If lMiddleware

					//Realiza o cadastro do evento na RJE
					aRetorno := MDTEnvMid( aDadFun[1], cEvtAux, cChvAtu, cChvNov, cXml, nOper )

					//Caso o retorno seja verdadeiro e seja o �ltimo funcion�rio enviado, emite a mensagem
					If !aRetorno[ 1, 1 ] .Or. nCont == Len( aFuncs )
						
						//Caso for execu��o autom�tica
						If lExecAuto

							AutoGrLog( aRetorno[ 1, 2 ] )

						ElseIf lGPEA180 //Caso for GPEA180 a mensagem ser� retornada no log

							cMsgInc += CRLF + aRetorno[ 1, 2 ]

						Else

							Help( ' ', 1, STR0017, , aRetorno[ 1, 2 ], 2, 0 )

						EndIf

						//lRet recebe o retorno da MDTEnvMid
						lRet := aRetorno[ 1, 1 ]

					EndIf

				Else //Envia o evento ao eSocial atrav�s do SIGATAF
					
					//Caso for exclus�o define o evento como sendo o S-3000
					If nOper == 5
						cEvtAux := "S3000"
					EndIf

					If cEvtAux == 'S2240' .And. lGPEA180 .And. cEmpAnt != cEmpDes // Caso for transfer�ncias entre empresas
						MDTChgEmp( aTbls, cEmpAnt, cEmpDes ) // Abre as tabelas do TAF na empresa destino
					EndIf

					//Integra o xml com o SIGATAF
					aRetorno := TafPrepInt( IIf( cEmpAnt != cEmpDes, cEmpDes, cEmpAnt ), cFilEnv, cXml, , "1", cEvtAux, , , , , , "MDT", , cTAFKey )

					If cEvtAux == 'S2240' .And. lGPEA180 .And. cEmpAnt != cEmpDes
						MDTChgEmp( aTbls, cEmpDes, cEmpBkp ) // Retorna as tabelas do TAF na empresa logada
					EndIf

					//Caso o retorno seja verdadeiro e seja o �ltimo funcion�rio enviado, emite a mensagem
					If Len( aRetorno ) > 0 .Or. nCont == Len( aFuncs )

						//Caso o retorno possua algum conte�do significa que houve erro na integra��o
						If Len( aRetorno ) > 0

							//Caso n�o for evento de exclus�o
							If cEvtAux <> "S3000"

								//Caso for execu��o autom�tica
								If lExecAuto

									AutoGrLog( STR0036 + CRLF + aRetorno[ 1 ] + CRLF + STR0037 )

								ElseIf lGPEA180 //Caso for GPEA180 a mensagem ser� retornada no log

									cMsgInc += CRLF + aRetorno[ 1 ]

								Else //Caso n�o for Transfer�ncias, emite a mensagem
									
									Help( ' ', 1, STR0017, , STR0036 + CRLF + aRetorno[ 1 ], 2, 0, , , , , , { STR0037 } )

								EndIf

							Else

								//Caso for evento de exclus�o apenas vai ser chamado pelo S-2210 e S-2220 que podem ter a mensagem apresentada em tela
								Help( ' ', 1, STR0017, , STR0036 + CRLF + aRetorno[ 1 ], 2, 0, , , , , , { STR0038 + " " + fTabEveEso( cEvento ) + " " + STR0039 } )

							EndIf

							//Define o retorno como .F.
							lRet := .F.

						Else

							//Caso for execu��o autom�tica
							If lExecAuto

								AutoGrLog( STR0034 + " (" + cEvtAux + ") " + STR0035 )

							ElseIf !lGPEA180 .And. IIf( IsInCallStack( "R465Imp" ), lMsgS2220, .T. ) //Caso n�o for transfer�ncia e caso seja impress�o de ASO (verifica a vari�vel de controle)

								Help( ' ', 1, STR0017, , STR0034 + " (" + cEvtAux + ") " + STR0035, 2, 0 )

							EndIf

						EndIf

					EndIf

				EndIf

			EndIf

		EndIf

		//Caso tenha ocorrido erros durante a integra��o, interrompe o envio
		If !lRet
			Exit
		EndIf

	Next nCont

	//Retorna a empresa e filial
	cEmpAnt := cEmpBkp
	cFilAnt := cFilBkp
	cArqTab := cArqBkp

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTGeraXml
Fun��o gen�rica que realiza a exporta��o dos Xml's do eSocial para arquivos .xml

@sample	MDTGeraXml()

@author	Luis Fellipy Bett
@since	16/07/2018

@return	.T., Boolean, Sempre verdadeiro
/*/
//---------------------------------------------------------------------
Function MDTGeraXml()

	Local cMascara  	:= STR0040 //"Todos os arquivos|."
	Local cTitulo   	:= STR0041 //"Escolha o destino do arquivo"
	Local nMascpad  	:= 0
	Local cDirini   	:= "\"
	Local lSalvar   	:= .F. /*.F. = Salva || .T. = Abre*/
	Local nOpcoes   	:= GETF_LOCALHARD
	Local lArvore   	:= .F. /*.T. = apresenta o �rvore do servidor || .F. = n�o apresenta*/
	Local lMDTA200		:= IsInCallStack( "MDTA200" ) //Cadastro de Atestado ASO
	Local lMDTA640		:= IsInCallStack( "MDTA640" ) //Cadastro de Acidentes
	Local dDtExp		:= SToD( "" )
	Local cArqPesq		:= ""
	Local cXml			:= ""
	Local cNumMat		:= ""
	Local cCodUnic		:= ""
	Local cFilArq		:= ""
	Local cChave		:= ""
	Local cChvRJE		:= ""
	Local lValid		:= .T.
	Local lFecha		:= .F.
	Local aDadFun		:= {}
	Local cDiretorio
	Local lSucess
	Local nHandle

	//Vari�veis de par�metro private, usadas em todo o processo de gera��o das informa��es
	Private lMiddleware	 := IIf( cPaisLoc == 'BRA' .And. Findfunction( "fVerMW" ), fVerMW(), .F. )
	Private dDtEsoc		 := SuperGetMv( "MV_NG2DTES", .F., SToD( "20211013" ) )
	Private cAtendAci	 := SuperGetMv( "MV_NG2IATE", .F., "3" )
	Private lGPEA010	 := IsInCallStack( "GPEA010" ) //Cadastro de Funcion�rio
	Private lExecAuto	 := .F. //Define o ExecAuto como .F.
	Private lAcidente	 := .F. //Define as vari�veis utilizadas no MDTM002 como .F.
	Private lDiagnostico := .F. //Define as vari�veis utilizadas no MDTM002 como .F.
	Private lAtestado	 := .F. //Define as vari�veis utilizadas no MDTM002 como .F.
	Private lGPEA180	 := .F. //Define a vari�vel de chamada da rotina de transfer�ncias como .F.
	Private lMDTA090	 := .F. //Define a vari�vel de chamada da rotina de cadastro de tarefas como .F.
	Private lMDTA881	 := .F. //Define a vari�vel de chamada da rotina de carga inicial como .F.
	Private lMDTA882	 := .F. //Define a vari�vel de chamada da rotina de schedule de tarefas como .F.
	Private lMDTA005	 := .F. //Define a vari�vel de chamada da rotina de cadastro de ficha m�dica como .F.
	Private lMDTA165	 := .F. //Define a vari�vel de chamada da rotina de cadastro de ambiente como .F.
	Private lMDTA180	 := .F. //Define a vari�vel de chamada da rotina de cadastro de risco como .F.
	Private lMDTA125	 := .F. //Define a vari�vel de chamada da rotina de cadastro de risco x EPI como .F.
	Private lMDTA130	 := .F. //Define a vari�vel de chamada da rotina de cadastro de EPI x risco como .F.
	Private lMDTA181	 := .F. //Define a vari�vel de chamada da rotina de cadastro de relacionamentos do risco como .F.
	Private lMDTA215	 := .F. //Define a vari�vel de chamada da rotina de cadastro de laudos x risco como .F.
	Private lMDTA695	 := .F. //Define a vari�vel de chamada da rotina de cadastro de funcion�rios x EPI como .F.
	Private lMDTA630	 := .F. //Define a vari�vel de chamada da rotina de cadastro de EPI x funcion�rio como .F.
	Private lMATA185	 := .F. //Define a vari�vel de chamada da rotina de cadastro de requisi��o ao estoque como .F.
	Private lGPEA370	 := .F. //Define a vari�vel de chamada da rotina de cadastro de cargos como .F.
	Private cFilEnv		 := MDTBFilEnv() //Busca a filial de envio

	//----- Vari�veis para busca de informa��es espec�ficas para cada chamada ------
	If lGPEA010 //Vari�veis de Busca dos Fatores de Risco

		cNumMat	 := SRA->RA_MAT
		cCodUnic := AllTrim( SRA->RA_CODUNIC )

	ElseIf lMDTA200 //Atestado ASO

		cNumMat	 := Posicione( "TM0", 1, xFilial( "TM0" ) + TMY->TMY_NUMFIC, "TM0_MAT" )
		cCodUnic := AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + cNumMat, "RA_CODUNIC" ) )

		lValid := !Empty( Posicione( "TM0", 1, xFilial( "TM0" ) + TMY->TMY_NUMFIC, "TM0_MAT" ) )
		cMsgVld := STR0042 //"A gera��o de Xml para o eSocial s�o apenas para registros de funcion�rios"

	ElseIf lMDTA640 //Acidentes

		cNumMat	 := Posicione( "TM0", 1, xFilial( "TM0" ) + TNC->TNC_NUMFIC, "TM0_MAT" )
		cCodUnic := AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + cNumMat, "RA_CODUNIC" ) )

		If !( lValid := !Empty( Posicione( "TM0", 1, xFilial( "TM0" ) + TNC->TNC_NUMFIC, "TM0_MAT" ) ) )
			cMsgVld := STR0042 //"A gera��o de Xml para o eSocial s�o apenas para registros de funcion�rios"
		ElseIf !( lValid := ( TNC->TNC_INDACI $ "1/2/3" ) )
			cMsgVld := STR0043 //"A gera��o de Xml para o eSocial s�o apenas para acidentes t�picos, acidentes de trajeto ou doen�a do trabalho"
		EndIf

	EndIf

	//Valida��es anteriores a gera��o do Xml de acordo com cada chamada
	If !lValid
		Help( ' ', 1, STR0017, , cMsgVld, 2, 0 )
	Else

		If lGPEA010
			aOpcMnp := { STR0044, STR0045, STR0047 } //"Altera��o"###"Inclus�o"###"Fechar"
		Else
			aOpcMnp := { STR0046, STR0044, STR0045, STR0047 } //"Exclus�o"###"Altera��o"###"Inclus�o"###"Fechar"
		EndIf

		nAviso := Aviso( STR0048, STR0049, aOpcMnp ) //"Gera��o Xml eSocial"###"Escolha o tipo de manipula��o a ser considerada na gera��o do Xml"

		If lGPEA010
			Do Case
				Case nAviso == 1 ; nOpcMnp := 4
				Case nAviso == 2 ; nOpcMnp := 3
				Case nAviso == 3 ; lFecha := .T.
			End Case
		Else
			Do Case
				Case nAviso == 1 ; nOpcMnp := 5
				Case nAviso == 2 ; nOpcMnp := 4
				Case nAviso == 3 ; nOpcMnp := 3
				Case nAviso == 4 ; lFecha := .T.
			End Case
		EndIf

		If !lFecha
			cDiretorio := cGetFile( cMascara, cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore )
			cDiretorio := StrTran( cDiretorio, "\.", "\" )
		Else
			cDiretorio := ""
		EndIf

		If cDiretorio <> ""

			If lMDTA640 //S-2210 - Comunica��o de Acidente de Trabalho

				cFilArq := StrTran( AllTrim( xFilial( "TNC" ) ), " ", "_" ) + "_"

				If nOpcMnp <> 5 //Se n�o for Xml de exclus�o

					cChvRJE := DToS( TNC->TNC_DTACID ) + StrTran( TNC->TNC_HRACID, ":", "" ) + TNC->TNC_TIPCAT

					If MDTVldDad( "S-2210", nOpcMnp, { { cNumMat } }, .T. ) //Avalia as informa��es a serem enviadas
						cXml := MDTM002( nOpcMnp, , , , cChvRJE ) //Carrega o Xml
					EndIf

				Else
					//Busca as informa��es do funcion�rio
					aDadFun := MDTDadFun( cNumMat, .T. )

					If lMiddleware
						If MDTVerTSVE( aDadFun[5] ) //Caso seja Trabalhador Sem V�nculo Estatut�rio
							cChave := AllTrim( aDadFun[3] ) + AllTrim( aDadFun[5] ) + DToS( aDadFun[6] ) + DToS( TNC->TNC_DTACID ) + StrTran( TNC->TNC_HRACID, ":", "" ) + TNC->TNC_TIPCAT
						Else
							cChave := AllTrim( aDadFun[4] ) + DToS( TNC->TNC_DTACID ) + StrTran( TNC->TNC_HRACID, ":", "" ) + TNC->TNC_TIPCAT
						EndIf
					Else
						cChave := DtoS( TNC->TNC_DTACID ) + StrTran( TNC->TNC_HRACID, ":", "" ) + TNC->TNC_TIPCAT
					EndIf

					cXml := MDTM006( "S2210", cNumMat, cChave )
				EndIf

				cArqPesq := cFilArq + "evt_S-2210_" + DToS( Date() ) + "_" + StrTran( Time(), ":", "" ) + "_" + cCodUnic + DToS( TNC->TNC_DTACID ) + StrTran( TNC->TNC_HRACID, ":", "" ) + ".xml" //evt_S-2210_X_X_X.xml"

			ElseIf lMDTA200 //S-2220 - Monitoramento de Sa�de do Trabalhador - Exame Ocupacional

				cFilArq := StrTran( AllTrim( xFilial( "TMY" ) ), " ", "_" ) + "_"

				If nOpcMnp <> 5 //Se n�o for Xml de exclus�o

					cChvRJE := DToS( TMY->TMY_DTEMIS )

					If MDTVldDad( "S-2220", nOpcMnp, { { cNumMat } }, .T. ) //Avalia as informa��es a serem enviadas
						cXml := MDTM003( nOpcMnp, , , cChvRJE ) //Carrega o Xml
					EndIf

				Else
					//Busca as informa��es do funcion�rio
					aDadFun := MDTDadFun( cNumMat, .T. )

					If lMiddleware
						If MDTVerTSVE( aDadFun[5] ) //Caso seja Trabalhador Sem V�nculo Estatut�rio
							cChave := AllTrim( aDadFun[3] ) + AllTrim( aDadFun[5] ) + DToS( aDadFun[6] ) + DToS( TMY->TMY_DTEMIS )
						Else
							cChave := AllTrim( aDadFun[4] ) + DToS( TMY->TMY_DTEMIS )
						EndIf
					Else
						cChave := DToS( TMY->TMY_DTEMIS )
					EndIf

					cXml := MDTM006( "S2220", cNumMat, cChave )
				EndIf

				cArqPesq := cFilArq + "evt_S-2220_" + DToS( Date() ) + "_" + StrTran( Time(), ":", "" ) + "_" + cCodUnic + DToS( TMY->TMY_DTEMIS ) + ".xml" //evt_S-2220_X_X_X.xml"

			ElseIf lGPEA010 //S-2240 - Condi��es Ambientais de Trabalho - Fatores de Risco

				cFilArq := StrTran( AllTrim( xFilial( "SRA" ) ), " ", "_" ) + "_"

				cChvRJE := DToS( MDTDtExpAtu( cNumMat ) )

				If MDTVldDad( "S-2240", nOpcMnp, { { cNumMat } }, .T., , @dDtExp )
					cXml := MDTM004( cNumMat, nOpcMnp, dDtExp, , , cChvRJE )
				EndIf

				cArqPesq := cFilArq + "evt_S-2240_" + DToS( Date() ) + "_" + StrTran( Time(), ":", "" ) + "_" + AllTrim( cCodUnic ) + DToS( dDtExp ) + ".xml" //evt_S-2240_X_X_X.xml"

			EndIf

			//Caso exista Xml a ser gerado
			If !Empty( cXml )

				//Cria arquivo no diret�rio
				nHandle := FCREATE( cArqPesq, 0 )

				//----------------------------------------------------------------------------------
				// Verifica se o arquivo pode ser criado, caso contrario um alerta ser� exibido
				//----------------------------------------------------------------------------------
				If FERROR() <> 0
					Help( ' ', 1, STR0017, , STR0050 + " " + cArqPesq, 2, 0 )
					Return
				EndIf

				FWrite( nHandle, cXml ) //Escreve no arquivo

				FCLOSE( nHandle ) //Fecha o arquivo

				lSucess := CpyS2T( cArqPesq, cDiretorio ) //Copia o arquivo do server para o terminal

				If lSucess
					Help( ' ', 1, STR0017, , STR0051 + " " + "'" + cArqPesq + "'" + " " + STR0052 + " " + "'" + cDiretorio + "'", 2, 0 )
				Else
					Help( ' ', 1, STR0017, , STR0053 + " " + "'" + cArqPesq + "'", 2, 0 )
				Endif

				FERASE( cArqPesq )

			Else
				Help( ' ', 1, STR0017, , STR0053 + " " + "'" + cArqPesq + "'" + " " + STR0054, 2, 0 )
			EndIf

		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTSubTxt
Funcao que substitui os caracteres especiais por espacos

@return cImpLin Caracter Texto sem caracteres especiais

@sample MDTSubTxt( 'Ol�' )

@param cTexto Caracter Texto a ser verificado

@author Jackson Machado
@since 28/01/2015
/*/
//---------------------------------------------------------------------
Function MDTSubTxt( cTexto )

	Local aAcentos	:= {}
	Local aAcSubst	:= {}
	Local cImpCar 	:= Space( 01 )
	Local cImpLin 	:= ""
	Local cAux 	  	:= ""
	Local cAux1	  	:= ""
	Local nTamTxt 	:= Len( cTexto )
	Local nCont
	Local nPos

	// Para alteracao/inclusao de caracteres, utilizar a fonte TERMINAL no IDE com o tamanho
	// maximo possivel para visualizacao dos mesmos.
	// Utilizar como referencia a tabela ASCII anexa a evidencia de teste (FNC 807/2009).

	aAcentos :=	{;
		Chr(199),Chr(231),Chr(196),Chr(197),Chr(224),Chr(229),Chr(225),Chr(228),Chr(170),;
		Chr(201),Chr(234),Chr(233),Chr(237),Chr(244),Chr(246),Chr(242),Chr(243),Chr(186),;
		Chr(250),Chr(097),Chr(098),Chr(099),Chr(100),Chr(101),Chr(102),Chr(103),Chr(104),;
		Chr(105),Chr(106),Chr(107),Chr(108),Chr(109),Chr(110),Chr(111),Chr(112),Chr(113),;
		Chr(114),Chr(115),Chr(116),Chr(117),Chr(118),Chr(120),Chr(122),Chr(119),Chr(121),;
		Chr(065),Chr(066),Chr(067),Chr(068),Chr(069),Chr(070),Chr(071),Chr(072),Chr(073),;
		Chr(074),Chr(075),Chr(076),Chr(077),Chr(078),Chr(079),Chr(080),Chr(081),Chr(082),;
		Chr(083),Chr(084),Chr(085),Chr(086),Chr(088),Chr(090),Chr(087),Chr(089),Chr(048),;
		Chr(049),Chr(050),Chr(051),Chr(052),Chr(053),Chr(054),Chr(055),Chr(056),Chr(057),;
		Chr(038),Chr(195),Chr(212),Chr(211),Chr(205),Chr(193),Chr(192),Chr(218),Chr(220),;
		Chr(213),Chr(245),Chr(227),Chr(252),Chr(210),Chr(202);
		}

	aAcSubst :=	{;
		"C","c","A","A","a","a","a","a","a",;
		"E","e","e","i","o","o","o","o","o",;
		"u","a","b","c","d","e","f","g","h",;
		"i","j","k","l","m","n","o","p","q",;
		"r","s","t","u","v","x","z","w","y",;
		"A","B","C","D","E","F","G","H","I",;
		"J","K","L","M","N","O","P","Q","R",;
		"S","T","U","V","X","Z","W","Y","0",;
		"1","2","3","4","5","6","7","8","9",;
		"E","A","O","O","I","A","A","U","U",;
		"O","o","a","u","O","E";
		}

	For nCont := 1 To Len( AllTrim( cTexto ) )
		cImpCar	:= SubStr( cTexto, nCont, 1 )
		//-- Nao pode sair com 2 espacos em branco.
		cAux	:= Space( 01 )
		nPos 	:= 0
		nPos 	:= Ascan( aAcentos, cImpCar )
		If nPos > 0
			cAux := aAcSubst[ nPos ]
		Elseif ( cAux1 == Space( 1 ) .And. cAux == Space( 1 ) ) .Or. Len( cAux1 ) == 0
			cAux :=	""
		EndIf
		cAux1 	:= cAux
		cImpCar	:= cAux
		cImpLin	:= cImpLin + cImpCar

	Next nCont

	//--Volta o texto no tamanho original
	cImpLin := Left( cImpLin + Space( nTamTxt ), nTamTxt )

Return cImpLin

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTObriEsoc
Realiza verifica��o dos campos obrigat�rios nos seus respectivos
cadastros, para n�o haver inconsist�ncias no envio ao TAF

@author  Luis Fellipy Bett
@since   25/07/2018

@param   cTabela	- Caracter	- Indica as Tabelas que ser�o verificadas

@return lRet, Boolean, Retorna .T. ou .F. de acordo com as verifica��es dos campos
/*/
//-------------------------------------------------------------------
Function MDTObriEsoc( cTabela, lDelete, oModel )

	Local cIncEsoc	:= SuperGetMv( "MV_NG2AVIS", .F., "1" )
	Local leSocial	:= IIf( FindFunction( "MDTVldEsoc" ), MDTVldEsoc(), .F. )
	Local aCposInc	:= {}
	Local lRet		:= .T.
	Local cMsg		:= ""
	Local nCont		:= 0

	Default lDelete := .F.

	//Se � pra mostrar a mensagem e/ou impedir o processo
	If leSocial .And. cIncEsoc <> "2" .And. !lDelete

		If "TNC" $ cTabela //MDTA640 - Acidentes
			//Data do Acidente
			If TNC->( ColumnPos( "TNC_DTACID" ) ) > 0 .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_DTACID" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_DTACID" ) } )
			EndIf

			//Hora do Acidente
			If TNC->( ColumnPos( "TNC_HRACID" ) ) > 0 .And. oModel:GetValue( "TNCMASTER", "TNC_INDACI" ) == "1" .And. ( Empty( oModel:GetValue( "TNCMASTER", "TNC_HRACID" ) ) .Or. AllTrim( oModel:GetValue( "TNCMASTER", "TNC_HRACID" ) ) == ":" )
				aAdd( aCposInc, { NGRETTITULO( "TNC_HRACID" ) } )
			EndIf

			//Horas Trabalhadas Anteriormente ao Acidente
			If TNC->( ColumnPos( "TNC_HRTRAB" ) ) > 0 .And. oModel:GetValue( "TNCMASTER", "TNC_INDACI" ) == "1" .And. ( Empty( oModel:GetValue( "TNCMASTER", "TNC_HRTRAB" ) ) .Or. AllTrim( oModel:GetValue( "TNCMASTER", "TNC_HRTRAB" ) ) == ":" )
				aAdd( aCposInc, { NGRETTITULO( "TNC_HRTRAB" ) } )
			EndIf

			//Tipo de CAT
			If TNC->( ColumnPos( "TNC_TIPCAT" ) ) > 0 .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_TIPCAT" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_TIPCAT" ) } )
			EndIf

			//Indica��o de �bito
			If TNC->( ColumnPos( "TNC_MORTE" ) ) > 0 .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_MORTE" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_MORTE" ) } )
			EndIf

			//Data do �bito
			If TNC->( ColumnPos( "TNC_DTOBIT" ) ) > 0 .And. oModel:GetValue( "TNCMASTER", "TNC_MORTE" ) == "1" .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_DTOBIT" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_DTOBIT" ) } )
			EndIf

			//Indicativo de Comunica��o � Autoridade Policial
			If TNC->( ColumnPos( "TNC_POLICI" ) ) > 0 .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_POLICI" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_POLICI" ) } )
			EndIf

			//C�digo do Tipo do Acidnte - Utilizado para busca dos c�digos da situa��o geradora do acidente na tabela TNG
			If TNC->( ColumnPos( "TNC_TIPACI" ) ) > 0 .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_TIPACI" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_TIPACI" ) } )
			EndIf

			//Tipo de Local do Acidente
			If TNC->( ColumnPos( "TNC_INDLOC" ) ) > 0 .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_INDLOC" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_INDLOC" ) } )
			EndIf

			//Descri��o do Logradouro
			If TNC->( ColumnPos( "TNC_DESLOG" ) ) > 0 .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_DESLOG" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_DESLOG" ) } )
			EndIf

			//Indicativo de Interna��o
			If TNC->( ColumnPos( "TNC_INTERN" ) ) > 0 .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_DTATEN" ) ) .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_HRATEN" ) ) .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_INTERN" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_INTERN" ) } )
			EndIf

			//Dura��o do Tratamento
			If TNC->( ColumnPos( "TNC_QTAFAS" ) ) > 0 .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_DTATEN" ) ) .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_HRATEN" ) ) .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_QTAFAS" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_QTAFAS" ) } )
			EndIf

			//Indicativo de Afastamento
			If TNC->( ColumnPos( "TNC_AFASTA" ) ) > 0 .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_DTATEN" ) ) .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_HRATEN" ) ) .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_AFASTA" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_AFASTA" ) } )
			EndIf

			//C�digo da Natureza da Les�o - Utilizado para busca do c�digo da natureza da les�o na tabela TOJ
			If TNC->( ColumnPos( "TNC_CODLES" ) ) > 0 .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_DTATEN" ) ) .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_HRATEN" ) ) .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_CODLES" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_CODLES" ) } )
			EndIf

			//CID
			If TNC->( ColumnPos( "TNC_CID" ) ) > 0 .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_DTATEN" ) ) .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_HRATEN" ) ) .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_CID" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_CID" ) } )
			EndIf
		EndIf

		If "TNG" $ cTabela //MDTA600 - Tipos de Acidentes
			//C�digo eSocial do Tipo do Acidente
			If X3USO( GetSx3Cache( "TNG_ESOC", "X3_USADO" ) )
				If TNG->( ColumnPos( "TNG_ESOC" ) ) > 0 .And. Empty( oModel:GetValue( "TNG_ESOC" ) )
					aAdd( aCposInc, { NGRETTITULO( "TNG_ESOC" ) } )
				EndIf
			Else
				If TNG->( ColumnPos( "TNG_ESOC1" ) ) > 0 .And. Empty( oModel:GetValue( "TNG_ESOC1" ) )
					aAdd( aCposInc, { NGRETTITULO( "TNG_ESOC1" ) } )
				EndIf
			EndIf
		EndIf

		If "TOI" $ cTabela //MDTA603 - Parte do Corpo Atingida
			//C�digo eSocial da Parte do Corpo Atingida
			If TOI->( ColumnPos( "TOI_ESOC" ) ) > 0 .And. Empty( oModel:GetValue( "TOI_ESOC" ) )
				aAdd( aCposInc, { NGRETTITULO( "TOI_ESOC" ) } )
			EndIf
		EndIf

		If "TNH" $ cTabela //MDTA605 - Objeto Causador
			//C�digo eSocial do Objeto Causador
			If TNH->( ColumnPos( "TNH_ESOC" ) ) > 0 .And. Empty( oModel:GetValue( "TNH_ESOC" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNH_ESOC" ) } )
			EndIf
		EndIf

		If "TOJ" $ cTabela //MDTA604 - Natureza da Les�o do Acidente
			//C�digo eSocial da Natureza da Les�o
			If TOJ->( ColumnPos( "TOJ_ESOC" ) ) > 0 .And. Empty( oModel:GetValue( "TOJ_ESOC" ) )
				aAdd( aCposInc, { NGRETTITULO( "TOJ_ESOC" ) } )
			EndIf
		EndIf

		If "TMK" $ cTabela //MDTA070 - Usu�rios
			//Nome do M�dico
			If TMK->( ColumnPos( "TMK_NOMUSU" ) ) > 0 .And. Empty( M->TMK_NOMUSU )
				aAdd( aCposInc, { NGRETTITULO( "TMK_NOMUSU" ) } )
			EndIf

			//�rg�o de Classe
			If TMK->( ColumnPos( "TMK_ENTCLA" ) ) > 0 .And. Empty( M->TMK_ENTCLA )
				aAdd( aCposInc, { NGRETTITULO( "TMK_ENTCLA" ) } )
			EndIf

			//N�mero de Inscri��o do �rg�o de Classe
			If TMK->( ColumnPos( "TMK_NUMENT" ) ) > 0 .And. Empty( M->TMK_NUMENT )
				aAdd( aCposInc, { NGRETTITULO( "TMK_NUMENT" ) } )
			EndIf

			//UF do �rg�o de Classe
			If TMK->( ColumnPos( "TMK_UF" ) ) > 0 .And. Empty( M->TMK_UF )
				aAdd( aCposInc, { NGRETTITULO( "TMK_UF" ) } )
			EndIf
		EndIf

		If "TNP" $ cTabela //MDTA680 - Emitentes de Atestados
			//Nome do M�dico
			If TNP->( ColumnPos( "TNP_NOME" ) ) > 0 .And. Empty( oModel:GetValue( "TNP_NOME" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNP_NOME" )	} )
			EndIf

			//�rg�o de Classe
			If TNP->( ColumnPos( "TNP_ENTCLA" ) ) > 0 .And. Empty( oModel:GetValue( "TNP_ENTCLA" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNP_ENTCLA" ) } )
			EndIf

			//N�mero de Inscri��o do �rg�o de Classe
			If TNP->( ColumnPos( "TNP_NUMENT" ) ) > 0 .And. Empty( oModel:GetValue( "TNP_NUMENT" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNP_NUMENT" ) } )
			EndIf

			//UF do �rg�o de Classe
			If TNP->( ColumnPos( "TNP_UF" ) ) > 0 .And. Empty( oModel:GetValue( "TNP_UF" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNP_UF" ) } )
			EndIf
		EndIf

		If "TMY" $ cTabela //MDTA200 - Atestado ASO
			//Natureza do ASO
			If TMY->( ColumnPos( "TMY_NATEXA" ) ) > 0 .And. Empty( M->TMY_NATEXA )
				aAdd( aCposInc, { NGRETTITULO( "TMY_NATEXA" )	} )
			EndIf

			//Parecer do M�dico
			If TMY->( ColumnPos( "TMY_INDPAR" ) ) > 0 .And. Empty( M->TMY_INDPAR )
				aAdd( aCposInc, { NGRETTITULO( "TMY_INDPAR" )	} )
			EndIf

			//Tipo do Exame
			If TMY->( ColumnPos( "TMY_INDEXA" ) ) > 0 .And. Empty( M->TMY_INDEXA )
				aAdd( aCposInc, { NGRETTITULO( "TMY_INDEXA" )	} )
			EndIf
		EndIf

		If "TM4" $ cTabela //MDTA020 - Exames
			//Procedimento Realizado
			If TM4->( ColumnPos( "TM4_PROCRE" ) ) > 0 .And. Empty( M->TM4_PROCRE )
				aAdd( aCposInc, { NGRETTITULO( "TM4_PROCRE" ) } )
			EndIf
		EndIf

		If "TNE" $ cTabela //MDTA165 - Ambientes de Trabalho
			//Local do Ambiente
			If TNE->( ColumnPos( "TNE_LOCAMB" ) ) > 0 .And. Empty( oModel:GetValue( "TNE_LOCAMB" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNE_LOCAMB" ) } )
			EndIf

			//Descri��o do Ambiente
			If TNE->( ColumnPos( "TNE_MEMODS" ) ) > 0 .And. Empty( oModel:GetValue( "TNE_MEMODS" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNE_MEMODS" ) } )
			EndIf

			//Tipo de Inscri��o do Ambiente
			If TNE->( ColumnPos( "TNE_TPINS" ) ) > 0 .And. Empty( oModel:GetValue( "TNE_TPINS" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNE_TPINS" ) } )
			EndIf

			//N�mero de Inscri��o do Ambiente
			If TNE->( ColumnPos( "TNE_NRINS" ) ) > 0 .And. Empty( oModel:GetValue( "TNE_NRINS" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNE_NRINS" ) } )
			EndIf
		EndIf

		If "TMA" $ cTabela //MDTA182 - Agentes
			//Descri��o do Agente
			If TMA->( ColumnPos( "TMA_DESCRI" ) ) > 0 .And. !Empty( M->TMA_ESOC ) .And. M->TMA_ESOC $ "01.01.001/01.02.001/01.03.001/01.04.001/01.05.001/01.06.001/01.07.001/01.08.001/01.09.001/01.10.001/01.12.001/01.13.001/01.14.001/01.15.001/01.16.001/01.17.001/01.18.001/05.01.001" .And. Empty( M->TMA_DESCRI )
				aAdd( aCposInc, { NGRETTITULO( "TMA_DESCRI" ) } )
			EndIf

			//Tipo de Avalia��o do Agente
			If TMA->( ColumnPos( "TMA_AVALIA" ) ) > 0 .And. !Empty( M->TMA_ESOC ) .And. M->TMA_ESOC <> "09.01.001" .And. Empty( M->TMA_AVALIA )
				aAdd( aCposInc, { NGRETTITULO( "TMA_AVALIA" ) } )
			EndIf
		EndIf

		If "TN0" $ cTabela //MDTA180 - Riscos
			If Posicione( "TMA", 1, xFilial( "TMA" ) + M->TN0_AGENTE, "TMA_AVALIA" ) == "1"
				//Unidade de Medida
				If TN0->( ColumnPos( "TN0_UNIMED" ) ) > 0 .And. Empty( M->TN0_UNIMED )
					aAdd( aCposInc, { NGRETTITULO( "TN0_UNIMED" ) } )
				EndIf

				//T�cnica de Medi��o
				If TN0->( ColumnPos( "TN0_TECUTI" ) ) > 0 .And. Empty( M->TN0_TECUTI )
					aAdd( aCposInc, { NGRETTITULO( "TN0_TECUTI" ) } )
				EndIf
			EndIf
		EndIf

		If "TMT" $ cTabela //MDTA155 - Diagn�stico M�dico
			//Data do Atendimento
			If TMT->( ColumnPos( "TMT_DTATEN" ) ) > 0 .And. !Empty( M->TMT_ACIDEN ) .And. Empty( M->TMT_DTATEN )
				aAdd( aCposInc, { NGRETTITULO( "TMT_DTATEN" ) } )
			EndIf

			//Hora do Atendimento
			If TMT->( ColumnPos( "TMT_HRATEN" ) ) > 0 .And. !Empty( M->TMT_ACIDEN ) .And. ( Empty( M->TMT_HRATEN ) .Or. AllTrim( M->TMT_HRATEN ) == ":" )
				aAdd( aCposInc, { NGRETTITULO( "TMT_HRATEN" ) } )
			EndIf

			//CID
			If TMT->( ColumnPos( "TMT_CID" ) ) > 0 .And. !Empty( M->TMT_ACIDEN ) .And. Empty( M->TMT_CID )
				aAdd( aCposInc, { NGRETTITULO( "TMT_CID" ) } )
			EndIf
		EndIf

		If "TNY" $ cTabela //MDTA685 - Atestado M�dico
			//Hora da Consulta/Atendimento
			If TNY->( ColumnPos( "TNY_DTCONS" ) ) > 0 .And. !Empty( oModel:GetValue( "TNYMASTER1", "TNY_ACIDEN" ) ) .And. Empty( oModel:GetValue( "TNYMASTER1", "TNY_DTCONS" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNY_DTCONS" ) } )
			EndIf

			//Hora da Consulta/Atendimento
			If TNY->( ColumnPos( "TNY_HRCONS" ) ) > 0 .And. !Empty( oModel:GetValue( "TNYMASTER1", "TNY_ACIDEN" ) ) .And. ( Empty( oModel:GetValue( "TNYMASTER1", "TNY_HRCONS" ) ) .Or. AllTrim( oModel:GetValue( "TNYMASTER1", "TNY_HRCONS" ) ) == ":" )
				aAdd( aCposInc, { NGRETTITULO( "TNY_HRCONS" ) } )
			EndIf

			//CID
			If TNY->( ColumnPos( "TNY_CID" ) ) > 0 .And. !Empty( oModel:GetValue( "TNYMASTER1", "TNY_ACIDEN" ) ) .And. Empty( oModel:GetValue( "TNYMASTER1", "TNY_CID" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNY_CID" ) } )
			EndIf
		EndIf

		//Caso existam campos obrigt�rios ao eSocial n�o preenchidos
		If Len( aCposInc ) > 0

			If cIncEsoc == "0"

				cMsg := STR0055 //"Os campos abaixo s�o de import�ncia para a consist�ncia das informa��es que ser�o enviadas ao eSocial"
				For nCont := 1 To Len( aCposInc )
					cMsg += CRLF + "- " + aCposInc[ nCont, 1 ]
				Next nCont

				If !( lRet := MsgYesNo( cMsg + CRLF + STR0056, STR0017 ) )
					Help( ' ', 1, STR0017, , cMsg, 2, 0, , , , , , { STR0057 } )
				EndIf

			ElseIf cIncEsoc == "1"

				cMsg := STR0055 //"Os campos abaixo s�o de import�ncia para a consist�ncia das informa��es que ser�o enviadas ao eSocial"
				For nCont := 1 To Len( aCposInc )
					cMsg += CRLF + "- " + aCposInc[ nCont, 1 ]
				Next nCont
				Help( ' ', 1, STR0017, , cMsg, 2, 0, , , , , , { STR0057 } )
				lRet := .F.

			EndIf
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTGetFunc
Busca todos os funcion�rios cadastrados

@return aFuncs

@sample MDTGetFunc()

@author Luis Fellipy Bett
@since 09/10/2018
/*/
//---------------------------------------------------------------------
Function MDTGetFunc()

	//Vari�veis de busca das informa��es
	Local aFuncs := {}
	Local lMDTA881 := IsInCallStack( "MDTA881" ) //Caso for chamada pela carga inicial
	
	//Vari�veis de tabela tempor�ria
	Local cAliasTmp := GetNextAlias()

	//Vari�veis de montagem da tabela tempor�ria
	Local aFields  := { { "FILIAL", "C", FWSizeFilial(), 0 } }
	Local cNameTab := ""
	Local oTmpFil

	//-------------------------------------------------
	// Cria a tabela tempor�ria para salvar as filiais
	//-------------------------------------------------
	oTmpFil := FWTemporaryTable():New( cAliasTmp )
	
	//Define a tabela
	oTmpFil:SetFields( aFields )
	oTmpFil:AddIndex( "01", { "FILIAL" } )
	oTmpFil:Create()

	//Pega o nome da tabela do banco
	cNameTab := oTmpFil:GetRealName()

	//-----------------------------------------------------------------
	// Busca as filiais a serem consideradas na busca dos funcion�rios
	//-----------------------------------------------------------------
	If lMDTA881
		Processa( { || fGetFilFun( cAliasTmp, lMDTA881 ) }, STR0091 ) //"Aguarde, buscando as filiais..."
	Else
		fGetFilFun( cAliasTmp, lMDTA881 )
	EndIf

	//-----------------------
	// Busca os funcion�rios
	//-----------------------
	If lMDTA881
		Processa( { || fGetFun( cNameTab, @aFuncs, lMDTA881 ) }, STR0092 ) //"Aguarde, buscando os funcion�rios..."
	Else
		fGetFun( cNameTab, @aFuncs, lMDTA881 )
	EndIf

	//Deleta a tabela tempor�ria
	oTmpFil:Delete()

Return aFuncs

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetFilFun
Busca as filiais que dever�o ser consideradas na busca dos funcion�rios

@return Nil, Nulo

@param	cAliasTmp, Caractere, Tabela tempor�ria a ser alimentada na fun��o

@sample fGetFilFun( "SGC" )

@author	Luis Fellipy Bett
@since	03/03/2022
/*/
//---------------------------------------------------------------------
Static Function fGetFilFun( cAliasTmp, lMDTA881 )

	//Vari�veis de busca das informa��es
	Local lAllFil := SuperGetMv( "MV_NG2BLEV", .F., "ToFil", Space( Len( xFilial( "SRA" ) ) ) ) <> "ToFil"
	Local aFilSRA := {}
	Local cExpQry := ""

	//Vari�veis de contadores
	Local nCont := 0
	
	//Vari�veis de tabelas tempor�rias
	Local cAliasSM0 := ""
	
	//Caso for dicion�rio na base
	If MPDicInDB()
	
		//Pega o pr�ximo alias
		cAliasSM0 := GetNextAlias()

		//----------------------------------------------------------------------
		// Verifica se busca os funcion�rios da empresa inteira ou s� da filial
		//----------------------------------------------------------------------
		If lAllFil
			cExpQry := "%M0_CODIGO = '" + cEmpAnt + "'%"
		Else
			cExpQry := "%M0_CODFIL = '" + cFilAnt + "'%"
		EndIf

		//Busca as filiais da SM0
		BeginSQL Alias cAliasSM0
			SELECT M0_CODFIL FROM %Table:SM0% SM0
				WHERE %Exp:cExpQry%
				AND SM0.%notDel%
		EndSQL

		//Adiciona as filiais retornadas da query na tabela temrpor�ria
		dbSelectArea( cAliasSM0 )
		( cAliasSM0 )->( dbGoTop() )

		//Caso for carga inicial, define a r�gua de processamento
		If lMDTA881
			ProcRegua( RecCount() )
		EndIf
		
		While ( cAliasSM0 )->( !Eof() )

			//Caso for carga inicial, incrementa a r�gua de processamento
			If lMDTA881
				IncProc()
			EndIf

			RecLock( cAliasTmp, .T. )
				( cAliasTmp )->FILIAL := xFilial( "SRA", ( cAliasSM0 )->M0_CODFIL )
			( cAliasTmp )->( MsUnlock() )

			dbSelectArea( cAliasSM0 )
			( cAliasSM0 )->( dbSkip() )
		End

		//Fecha a tabela tempor�ria da SM0
		( cAliasSM0 )->( dbCloseArea() )

	Else //Caso for dicion�rio na system

		//Busca as filiais do sistema
		aFilSRA := FwLoadSM0()

		//Caso for carga inicial, define a r�gua de processamento
		If lMDTA881
			ProcRegua( Len( aFilSRA ) )
		EndIf

		//Percorre as filiais validando
		For nCont := 1 To Len( aFilSRA )

			//Caso for carga inicial, incrementa a r�gua de processamento
			If lMDTA881
				IncProc()
			EndIf

			//----------------------------------------------------------------------
			// Verifica se busca os funcion�rios da empresa inteira ou s� da filial
			//----------------------------------------------------------------------
			If ( lAllFil .And. aFilSRA[ nCont, 1 ] == cEmpAnt ) .Or. ;
				( !lAllFil .And. aFilSRA[ nCont, 2 ] == cFilAnt )

				RecLock( cAliasTmp, .T. )
					( cAliasTmp )->FILIAL := xFilial( "SRA", aFilSRA[ nCont, 2 ] )
				( cAliasTmp )->( MsUnlock() )

			EndIf

		Next nCont

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetFun
Busca os funcion�rios que dever�o ser integrados

@return Nil, Nulo

@param	cNameTab, Caractere, Nome da tabela tempor�ria no banco de dados

@sample fGetFun( "SGC" )

@author	Luis Fellipy Bett
@since	03/03/2022
/*/
//---------------------------------------------------------------------
Static Function fGetFun( cNameTab, aFuncs, lMDTA881 )

	//Vari�veis de tabela tempor�ria
	Local cAliasSRA	:= GetNextAlias()

	BeginSQL Alias cAliasSRA
		SELECT SRA.RA_FILIAL, SRA.RA_MAT FROM %Table:SRA% SRA
			WHERE SRA.RA_FILIAL IN (
				SELECT FILIAIS.FILIAL
					FROM %temp-table:cNameTab% FILIAIS
			)
			AND SRA.RA_SITFOLH <> 'D'
			AND SRA.RA_DEMISSA = %Exp:SToD(Space(8))%
			AND SRA.%notDel%
	EndSQL

	dbSelectArea( cAliasSRA )
	( cAliasSRA )->( dbGoTop() )

	//Caso for carga inicial, define a r�gua de processamento
	If lMDTA881
		ProcRegua( RecCount() )
	EndIf

	While ( cAliasSRA )->( !EoF() )

		//Caso for carga inicial, incrementa a r�gua de processamento
		If lMDTA881
			IncProc()
		EndIf

		aAdd( aFuncs, { ( cAliasSRA )->RA_MAT, ( cAliasSRA )->RA_FILIAL } )

		( cAliasSRA )->( dbSkip() )

	End

	//Fecha a tabela tempor�ria do SRA
	( cAliasSRA )->( dbCloseArea() )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MdtVldRis
Valida se o Risco ser� enviado para o TAF

@return lRet, Boolean, .T. caso o risco deva ser enviado ao SIGATAF/Middleware

@sample MdtVldRis()

@param [dDtRet], Date, Identifica a data de refer�ncia para busca do PPRA

@author Luis Fellipy Bett
@since 09/10/2018
/*/
//---------------------------------------------------------------------
Function MdtVldRis( dDtRef, lRisCad )

	Local aArea	   := GetArea() //Salva a �rea
	Local cRisTAF  := SuperGetMv( "MV_NG2RIST", .F., "3" )
	Local lVldPPRA := SuperGetMv( "MV_NG2VLAU", .F., "2" ) == "1"
	Local lRisEPI  := IsInCallStack( "fVldEPIFun" ) .And. lVldEPI
	Local lRet     := .T.

	//Define o valor padr�o para os par�metros
	Default dDtRef	:= dDataBase
	Default lRisCad	:= .F.

	//-------------------------------------------------------------------------------------------------------------------------------------
	// Caso for cadastro de risco e estiver validando o risco que est� sendo alterado, seta .F. pois a valida��o ser� feita posteriormente
	//-------------------------------------------------------------------------------------------------------------------------------------
	If lMDTA180 .And. !lRisCad .And. M->TN0_NUMRIS == TN0->TN0_NUMRIS
		lRet := .F.
	EndIf

	//---------------------------------------------------------------
	// Caso deva validar se o risco necessita da utiliza��o de EPI's
	//---------------------------------------------------------------
	If lRet .And. lRisEPI
		lRet := IIf( lRisCad, M->TN0_NECEPI, TN0->TN0_NECEPI ) == "1"
	EndIf

	//----------------------------------------------------------
	// Valida se o funcion�rio est� exposto ao risco no per�odo
	//----------------------------------------------------------
	If lRet .And. ( ( !Empty( SRA->RA_DEMISSA ) .And. IIf( lRisCad, M->TN0_DTRECO, TN0->TN0_DTRECO ) >= SRA->RA_DEMISSA ) .Or. ;
		( !Empty( IIf( lRisCad, M->TN0_DTELIM, TN0->TN0_DTELIM ) ) .And. ( IIf( lRisCad, M->TN0_DTELIM, TN0->TN0_DTELIM ) <= dDtRef .Or. IIf( lRisCad, M->TN0_DTELIM, TN0->TN0_DTELIM ) <= dDtEsoc ) ) .Or. ;
		( Empty( IIf( lRisCad, M->TN0_DTAVAL, TN0->TN0_DTAVAL ) ) ) )
		lRet := .F.
	EndIf

	//-------------------------------------------------------------------
	// Valida se o agente do risco est� definido no par�metro para envio
	//-------------------------------------------------------------------
	If lRet
		// Valida se busca os riscos n�o obrigat�rios
		// MV_NG2RIST - 0 - Nenhum
		// MV_NG2RIST - 1 - Somente Ergonomicos
		// MV_NG2RIST - 2 - Somente Acidentes\Mec�nicos
		// MV_NG2RIST - 3 - Somente Ergonomicos\Acidentes\Mec�nicos
		// MV_NG2RIST - 4 - Somente Perigosos
		// MV_NG2RIST - 5 - Todos
		dbSelectarea( "TMA" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "TMA" ) + IIf( lRisCad, M->TN0_AGENTE, TN0->TN0_AGENTE ) )

		//Valida se o tipo do agente do risco est� contido no par�metro MV_NG2RIST
		If ( TMA->TMA_GRISCO == "4" .And. ( cRisTAF == "2" .Or. cRisTAF == "0" .Or. cRisTAF == "4" ) ) .Or. ;
			( ( TMA->TMA_GRISCO == "5" .Or. TMA->TMA_GRISCO == "6" ) .And. ( cRisTAF == "1" .Or. cRisTAF == "0" .Or. cRisTAF == "4" ) ) .Or. ;
			( TMA->TMA_GRISCO == "7" .And. ( cRisTAF == "0" .Or. cRisTAF == "1" .Or. cRisTAF == "2" .Or. cRisTAF == "3" ) )
			lRet := .F.
		EndIf
	EndIf

	//---------------------------------------------------------------------------------------
	// Valida se o agente possui um c�digo do eSocial e se � diferente do c�digo de aus�ncia
	//---------------------------------------------------------------------------------------
	If lRet .And. ( Empty( TMA->TMA_ESOC ) .Or. TMA->TMA_ESOC == "09.01.001" )
		lRet := .F.
	EndIf

	//-------------------------------------------------------------
	// Valida se o risco est� em algum PPRA no momento da execu��o
	//-------------------------------------------------------------
	If lRet .And. lVldPPRA //Caso tenha que validar o Laudo
		lRet := .F. //Indica inicialmente que o Risco n�o ser� setado para envio, caso ache ent�o envia
		dbSelectArea( "TO1" )
		dbSetOrder( 2 ) //TO1_FILIAL+TO1_NUMRIS+TO1_LAUDO
		dbSeek( xFilial( "TO1" ) + IIf( lRisCad, M->TN0_NUMRIS, TN0->TN0_NUMRIS ) )
		While TO1->( !EoF() ) .And. TO1->TO1_FILIAL == xFilial( "TO1" ) .And. ;
				TO1->TO1_NUMRIS == IIf( lRisCad, M->TN0_NUMRIS, TN0->TN0_NUMRIS )

			dbSelectArea( "TO0" )
			dbSetOrder( 1 ) //TO0_FILIAL+TO0_LAUDO
			dbSeek( xFilial( "TO0" ) + TO1->TO1_LAUDO )
			If TO0->TO0_TIPREL == "1" .And. TO0->TO0_DTINIC <= dDtRef .And.;
				( TO0->TO0_DTVALI >= dDtRef .Or. Empty( TO0->TO0_DTVALI ) )
				lRet := .T.
				Exit
			EndIf
			TO1->( dbSkip() )
		End
	EndIf

	//Retorna a �rea
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTBFilEnv
Busca a filial de envio

@return cFilTAF, Caracter, Retorna a filial de envio

@sample MDTBFilEnv()

@author  Luis Fellipy Bett
@since   14/08/2019
/*/
//-------------------------------------------------------------------
Function MDTBFilEnv()

	Local aArea		:= GetArea() //Salva a �rea
	Local cEmpBkp	:= cEmpAnt //Salva a empresa
	Local cFilBkp	:= cFilAnt //Salva a filial
	Local cFilMtrz  := ""
	Local aFilInTaf := {}
	Local aArrayFil := {}
	Local aTbls		:= { { "C1E", 01 }, { "CR9", 01 }, { "RJ9", 01 } }

	Default lGPEA180 := .F.
	Default lMiddleware := IIf( cPaisLoc == 'BRA' .And. Findfunction( "fVerMW" ), fVerMW(), .F. )

	//Caso for transfer�ncia de funcion�rio, posiciona na empresa e filial destino
	If lGPEA180
		If cEmpAnt <> cEmpDes //Caso for transfer�ncia de empresa, abre as tabelas na nova empresa
			NGPrepTBL( aTbls, cEmpDes, cFilDes )
			cEmpAnt := cEmpDes //Posiciona na empresa destino
		EndIf
		
		cFilAnt := cFilDes
	EndIf

	If !lMiddleware
		//Busca a filial a ser considerada no envio ao TAF
		fGp23Cons( @aFilInTaf, @aArrayFil, @cFilMtrz )
	EndIf

	If Empty( cFilMtrz )
		cFilMtrz := cFilAnt
	EndIf

	//Retorna a empresa e filial para a atual
	If lGPEA180
		If cEmpAnt <> cEmpBkp
			NGPrepTBL( aTbls, cEmpBkp, cFilBkp )
			cEmpAnt := cEmpBkp //Posiciona na empresa destino
		EndIf

		cFilAnt := cFilBkp
	EndIf

	//Retorna a �rea
	RestArea( aArea )

Return cFilMtrz

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTVerTSVE
Fun��o que verifica se o funcion�rio � TSVE - Trabalhador Sem V�nculo Estatut�rio

@return lRet, L�gico, Verdadeiro caso a categoria do trabalhador for de TSVE

@sample MDTVerTSVE( "701" )

@param cCodCateg, Caracter, C�digo da Categoria do Funcion�rio

@author	Luis Fellipy Bett
@since	03/12/2019
/*/
//-------------------------------------------------------------------
Function MDTVerTSVE( cCodCateg )

	Local lRet := .T.

	If !( cCodCateg $ "201/202/304/305/308/401/410/701/711/712/721/722/723/731/734/738/741/751/761/771/901/902/903/904/905" )
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTEnvMid
Realiza o envio dos eventos de SST para o eSocial atrav�s do Middleware

@return .T., sempre verdadeiro

@sample MDTEnvMid( "D MG 01 ", "787878", "S2210", "D MG 01 2019050214001", "<eSocial></eSocial>", 3 )

@param cMatricula, Caracter, N�mero da Matr�cula do Funcion�rio
@param cEvento, Caracter, Nome do Evento
@param cChvAtu, Caracter, Chave atual do registro utilizada para busca na RJE
@param cChvNov, Caracter, Chave nova do registro utilizada para preenchimento do campo RJE_KEY
@param cXml, Caracter, Xml a ser enviado ao eSocial
@param nOper, Num�rico, Opera��o a ser realizada (3- Inclus�o, 4- Altera��o e 5-Exclus�o)

@author	Luis Fellipy Bett
@since	03/12/2019
/*/
//-------------------------------------------------------------------
Function MDTEnvMid( cMatricula, cEvento, cChvAtu, cChvNov, cXml, nOper )

	Local cEmpBkp  := cEmpAnt //Salva a empresa atual
	Local cFilBkp  := cFilAnt //Salva a filial atual
	Local aInfEnv  := {}
	Local aInfoC   := {}
	Local aRet	   := {} //Array de retorno
	Local aInfReg  := { /*cStatMid*/, /*cOpcRJE*/, /*cRetfRJE*/, /*nRecRJE*/ }
	Local lIntegra := .T.
	Local nOpcao   := 3
	Local cModo	   := ""
	Local cMsgErro := ""
	Local cOperNew := ""
	Local cRetfNew := ""
	Local cStatNew := ""
	Local lNovoRJE := .F.
	Local cTpInsc  := ""
	Local cNrInsc  := "0"
	Local cId	   := ""
	Local lAdmPubl := .F.

	Default nOper := 5

	//Caso for transfer�ncia entre empresas, posiciona na empresa destino
	If lGPEA180
		If cEmpAnt <> cEmpDes //Caso a empresa destino seja diferente da empresa atual
			
			//Posciona na empresa destino
			MDTPosSM0( cEmpDes, cFilDes )

			//Abre as tabelas na empresa destino
			EmpOpenFile( "RJ9", "RJ9", 1, .F., cEmpAnt, @cModo )
			EmpOpenFile( "RJ9", "RJ9", 1, .T., cEmpDes, @cModo )
			EmpOpenFile( "RJE", "RJE", 1, .F., cEmpAnt, @cModo )
			EmpOpenFile( "RJE", "RJE", 1, .T., cEmpDes, @cModo )

			//Posiciona na empresa destino
			cEmpAnt := cEmpDes
		EndIf

		//Posiciona na filial destino
		cFilAnt := cFilDes
	EndIf

	//Busca as informa��es da empresa
	aInfoC := fXMLInfos()

	If Len( aInfoC ) >= 4
		cTpInsc  := aInfoC[ 1 ]
		cNrInsc  := aInfoC[ 2 ]
		cId		 := aInfoC[ 3 ]
		lAdmPubl := aInfoC[ 4 ]		
	EndIf

	//Define status como "-1"
	aInfReg[ 1 ] := "-1"

	//Busca informa��es do registro
	aInfReg := MDTVerStat( .F., cEvento, cChvAtu )

	//Caso seja Altera��o ou Exclus�o
	If nOper == 4 .Or. nOper == 5

		//Retorno pendente impede o cadastro
		If aInfReg[ 1 ] == "2"
			cMsgErro := STR0058 //"Opera��o n�o ser� realizada pois o evento foi transmitido mas o retorno est� pendente"
			lIntegra := .F.
		EndIf

		If nOper == 4 //Altera��o

			If aInfReg[ 2 ] == "E" .And. aInfReg[ 1 ] != "4" //Evento de exclus�o sem transmiss�o impede o cadastro

				cMsgErro := STR0059 //"Opera��o n�o ser� realizada pois h� evento de exclus�o que n�o foi transmitido ou est� com retorno pendente"
				lIntegra := .F.

			ElseIf aInfReg[ 1 ] == "-1" //N�o existe na fila, ser� tratado como inclus�o

				nOpcao 	 := 3
				cOperNew := "I"
				cRetfNew := "1"
				cStatNew := "1"
				lNovoRJE := .T.

			ElseIf aInfReg[ 1 ] $ "1/3" //Evento sem transmiss�o, ir� sobrescrever o registro na fila

				If aInfReg[ 2 ] == "A"
					nOpcao := 4
				EndIf
				cOperNew := aInfReg[ 2 ]
				cRetfNew := aInfReg[ 3 ]
				cStatNew := "1"
				lNovoRJE := .F.

			ElseIf aInfReg[ 2 ] != "E" .And. aInfReg[ 1 ] == "4" //Evento diferente de exclus�o transmitido, ir� gerar uma retifica��o

				nOpcao 	 := 4
				cOperNew := "A"
				cRetfNew := "2"
				cStatNew := "1"
				lNovoRJE := .T.

			ElseIf aInfReg[ 2 ] == "E" .And. aInfReg[ 1 ] == "4" //Evento de exclus�o transmitido, ser� tratado como inclus�o

				nOpcao 	 := 3
				cOperNew := "I"
				cRetfNew := "1"
				cStatNew := "1"
				lNovoRJE := .T.

			EndIf

		ElseIf nOper == 5 //Exclus�o

			nOpcao := 5

			If aInfReg[2] == "E" .And. aInfReg[1] != "4" //Evento de exclus�o sem transmiss�o impede o cadastro
				cMsgErro := STR0059 //"Opera��o n�o ser� realizada pois h� evento de exclus�o que n�o foi transmitido ou est� com retorno pendente"
				lIntegra := .F.

			ElseIf aInfReg[2] != "E" .And. aInfReg[1] == "4" //Evento diferente de exclus�o transmitido ir� gerar uma exclus�o

				cOperNew := "E"
				cRetfNew := aInfReg[3]
				cStatNew := "1"
				lNovoRJE := .T.
				cEvento	 := "S3000"

			EndIf
		EndIf

	//Caso seja Inclus�o
	ElseIf nOper == 3

		If aInfReg[ 1 ] == "2" //Retorno pendente impede o cadastro

			cMsgErro := STR0058 //"Opera��o n�o ser� realizada pois o evento foi transmitido mas o retorno est� pendente"
			lIntegra := .F.

		ElseIf aInfReg[ 2 ] == "E" .And. aInfReg[ 1 ] != "4" //Evento de exclus�o sem transmiss�o impede o cadastro

			cMsgErro := STR0059 //"Opera��o n�o ser� realizada pois h� evento de exclus�o que n�o foi transmitido ou est� com retorno pendente"
			lIntegra := .F.

		ElseIf aInfReg[ 1 ] $ "1/3" //Evento sem transmiss�o, ir� sobrescrever o registro na fila

			nOpcao	 := IIf( aInfReg[ 2 ] == "I", 3, 4 )
			cOperNew := aInfReg[ 2 ]
			cRetfNew := aInfReg[ 3 ]
			cStatNew := "1"
			lNovoRJE := .F.

		ElseIf aInfReg[ 2 ] != "E" .And. aInfReg[ 1 ] == "4" //Evento diferente de exclus�o transmitido, ir� gerar uma retifica��o

			cOperNew := "A"
			cRetfNew := "2"
			cStatNew := "1"
			lNovoRJE := .T.

		Else //Ser� tratado como inclus�o
			cOperNew := "I"
			cRetfNew := "1"
			cStatNew := "1"
			lNovoRJE := .T.
		EndIf
	EndIf

	//Caso for evento de exclus�o
	If cEvento == "S3000"
		cChvNov := aInfReg[ 5 ] //A chave a ser cadastrada no campo RJE_KEY recebe o recibo do registro
		aInfReg[ 6 ] := aInfReg[ 5 ] //O recibo anterior recebe o recibo atual
	Else
		If cRetfNew == "2"
			If aInfReg[ 1 ] == "4"
				aInfReg[ 6 ] := aInfReg[ 5 ]
				aInfReg[ 5 ] := ""
			EndIf
		EndIf
	EndIf

	If lIntegra
		//RJE_FILIAL: Filial do sistema conforme compartilhamento da tabela
		//RJE_FIL: Filial que est� sendo alterada
		//RJE_TPINSC : RJ9_TPINSC
		//RJE_INSCR: RJ9_NRINSC (8 caracteres)
		//RJE_EVENTO: S1030
		//RJE_INI: Data base (AAAAMM)
		//RJE_KEY : C�digo da Filial Completa + C�digo do Cargo
		//RJE_RETKEY: ID do XML
		//RJE_RETF: "1"
		//RJE_VERS: vers�o do Protheus
		//RJE_STATUS: "1"
		//RJE_DTG : Data Gera��o do Evento
		//RJE_HORAG: Hora Gera��o do Evento
		//RJE_OPER: Opera��o a ser realizada (I-Inclus�o, A-Altera��o, E-Exclus�o)

		aAdd( aInfEnv, { xFilial( "RJE", cFilEnv ), cFilEnv, cTpInsc, IIf( cTpInsc == "1" .And. !lAdmPubl, SubStr( cNrInsc, 1, 8 ), cNrInsc ), cEvento, AnoMes( dDataBase ), cChvNov, cId, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, aInfReg[ 5 ], aInfReg[ 6 ] } )

		//Se n�o for uma exclus�o de registro n�o transmitido, cria/atualiza registro na fila
		If !( nOpcao == 5 .And. ( ( aInfReg[ 2 ] == "E" .And. aInfReg[ 1 ] == "4" ) .Or. aInfReg[ 1 ] $ "-1/1/3" ) )

			If fGravaRJE( aInfEnv, cXml, lNovoRJE, aInfReg[ 4 ] )
				aAdd( aRet, { .T., STR0060 + " (" + cEvento + ") " + STR0061 } )
			Else
				aAdd( aRet, { .F., STR0062 + " (" + cEvento + ") " + STR0063 } )
			EndIf

		//Se for uma exclus�o e n�o for de registro de exclus�o transmitido, exclui registro de exclus�o na fila
		ElseIf nOpcao == 5 .And. aInfReg[ 1 ] != "-1" .And. !( aInfReg[ 2 ] == "E" .And. aInfReg[ 1 ] == "4" )

			If fExcluiRJE( aInfReg[ 4 ] )
				aAdd( aRet, { .T., STR0064 + " (" + cEvento + ") " + STR0065 } )
			Else
				aAdd( aRet, { .F., STR0066 + " (" + cEvento + ")" } )
			EndIf

		EndIf

	Else
		aAdd( aRet, { .F., cMsgErro } )
	EndIf

	//Caso for chamada pelo GPEA180, altera a empresa e filial para a atual ap�s ter buscado as informa��es
	If lGPEA180
		If cEmpAnt <> cEmpBkp //Caso a empresa destino seja diferente da empresa atual
			
			//Posciona na empresa logada novamente
			MDTPosSM0( cEmpBkp, cFilBkp )

			//Volta as tabelas na empresa logada novamente
			EmpOpenFile( "RJ9", "RJ9", 1, .F., cEmpAnt, @cModo )
			EmpOpenFile( "RJ9", "RJ9", 1, .T., cEmpBkp, @cModo )
			EmpOpenFile( "RJE", "RJE", 1, .F., cEmpAnt, @cModo )
			EmpOpenFile( "RJE", "RJE", 1, .T., cEmpBkp, @cModo )

			//Posiciona na empresa logada novamente
			cEmpAnt := cEmpBkp
		EndIf

		//Posiciona na filial logada novamente
		cFilAnt := cFilBkp
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTVerStat
Verifica o status do registro passado por par�metro e retorna se ele
j� foi enviado ao TAF ou n�o

@return xRet, Indefindo, Ou l�gico caso o registro exista na RJE ou um Array

@sample MDTVerStat( .T., "S2210", "D MG 01 2019050214001", .F. )

@param lRetBool, Boolean, Indica se o retorno da fun��o vai ser Booleano, sen�o retorna um Array
@param cEvento, Caracter, Nome do evento
@param cChave, Caracter, Chave de busca pelo registro do evento
@param lExclu, Boolean, Indica se exclui o registro da RJE caso ele n�o esteja transmitido ao governo

@author	Luis Fellipy Bett
@since	03/12/2019
/*/
//-------------------------------------------------------------------
Function MDTVerStat( lRetBool, cEvento, cChave, lExclu )

	Local xRet
	Local cStatRJE	:= "-1"
	Local cOperRJE	:= ""
	Local cRetfRJE	:= ""
	Local nRecnRJE	:= 0
	Local cRecibRJE	:= ""
	Local CRecibAnt	:= ""
	Local cTpInsc	:= ""
	Local lAdmPubl	:= .F.
	Local cNrInsc	:= "0"
	Local cChvBus	:= ""

	Default lRetBool := .F.
	Default lExclu	 := .F.

	//Busca as informa��es da empresa
	aInfoC := fXMLInfos()

	If Len( aInfoC ) >= 4
		cTpInsc  := aInfoC[1]
		lAdmPubl := aInfoC[4]
		cNrInsc  := aInfoC[2]
	EndIf

	//RJE_TPINSC + RJE_INSCR + RJE_EVENTO + RJE_KEY + RJE_INI
	cChvBus := Padr( cTpInsc, TAMSX3( "RJE_TPINSC" )[1] ) + ;
				Padr( IIf( cTpInsc == "1" .And. !lAdmPubl, SubStr( cNrInsc, 1, 8 ), cNrInsc ), TAMSX3( "RJE_INSCR" )[1] ) + ;
				cEvento + ;
				Padr( cChave, TAMSX3( "RJE_KEY" )[1] )

	GetInfRJE( 2, cChvBus, @cStatRJE, @cOperRJE, @cRetfRJE, @nRecnRJE, @cRecibRJE, @CRecibAnt, , , lExclu )

	//Caso o retorno seja booleano
	If lRetBool
		If lExclu .And. ( cStatRJE <> "4" .And. cStatRJE <> "-1" ) .And. nRecnRJE > 0 //Caso o registro exista na RJE e n�o esteja transmitido ao governo, exclui
			If fExcluiRJE( nRecnRJE )
				Help( ' ', 1, STR0017, , STR0064 + " (" + cEvento + ") " + STR0065, 2, 0 )
				xRet := .F.
			EndIf
		ElseIf cStatRJE <> "-1" //Caso o registro exista na tabela RJE
			xRet := .T.
		Else
			//Caso o registro n�o exista na RJE
			xRet := .F.
		EndIf
	Else
		xRet := { cStatRJE, cOperRJE, cRetfRJE, nRecnRJE, cRecibRJE, CRecibAnt }
	EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTVld2200
Verifica se existe um evento S-2190, S-2200 ou S-2230 enviado ao governo para o funcion�rio

@return	lRet, Boolean, .T. se existir um evento comunicado ao governo, sen�o .F.

@sample MDTVld2200( "787878", "1", "581312150001", .F. )

@param	cMatricula, Caracter, Matr�cula do funcion�rio (RA_MAT)
@param	aGPEA180, Array, Array contendo as informa��es da transfer�ncia quando chamado pelo GPEA180

@author	Luis Fellipy Bett
@since	11/12/2019
/*/
//-------------------------------------------------------------------
Function MDTVld2200( cMatricula, aGPEA180 )

	//Vari�vel da �rea
	Local aArea := GetArea() //Salva a �rea
	
	//Vari�veis de busca e valida��o das informa��es
	Local cCodUnic	:= IIf( lGPEA180, aGPEA180[ 1, 14 ], Posicione( "SRA", 1, xFilial( "SRA" ) + cMatricula, "RA_CODUNIC" ) )
	Local cCodCateg	:= Posicione( "SRA", 1, xFilial( "SRA" ) + cMatricula, "RA_CATEFD" )
	Local cCPF		:= Posicione( "SRA", 1, xFilial( "SRA" ) + cMatricula, "RA_CIC" )
	Local dDtAdmis	:= Posicione( "SRA", 1, xFilial( "SRA" ) + cMatricula, "RA_ADMISSA" )
	Local lVldEvPre := SuperGetMv( "MV_NG2VEVP", .F., "2" ) == "1"
	Local lTSVE		:= MDTVerTSVE( cCodCateg )
	Local cEmpBkp	:= cEmpAnt //Salva a empresa
	Local cFilBkp	:= cFilAnt //Salva a filial
	Local lRet		:= .T.
	Local aInfoC	:= {}
	Local cStatus	:= "-1"
	Local cChave	:= ""
	Local cTpInsc	:= ""
	Local cNrInsc	:= ""
	Local lAdmPubl	:= ""
	Local aTbls		:= { { "T3A", 01 }, { "C9V", 01 } }

	//Caso o sistema deva realizar a valida��o dos eventos predecessores
	If lVldEvPre

		If lMiddleware //Caso for integra��o via Middleware

			//Busca as informa��es da empresa destino
			aInfoC	 := fXMLInfos()
			cTpInsc	 := aInfoC[1]
			cNrInsc	 := aInfoC[2]
			lAdmPubl := aInfoC[4]

			If MDTVerTSVE( cCodCateg ) //Caso for Trabalhador Sem V�nculo Estatut�rio
				cChave := cTpInsc + Padr( IIf( !lAdmPubl .And. cTpInsc == "1", SubStr( cNrInsc, 1, 8 ), cNrInsc ), TAMSX3( "RJE_INSCR" )[1] ) + "S2300" + Padr( AllTrim( cCPF ) + AllTrim( cCodCateg ) + DToS( dDtAdmis ), TAMSX3( "RJE_KEY" )[1], " " )
			Else
				cChave := cTpInsc + Padr( IIf( !lAdmPubl .And. cTpInsc == "1", SubStr( cNrInsc, 1, 8 ), cNrInsc ), TAMSX3( "RJE_INSCR" )[1] ) + "S2200" + Padr( AllTrim( cCodUnic ), TAMSX3( "RJE_KEY" )[1], " " )
			EndIf

			//RJE_TPINSC + RJE_INSCR + RJE_EVENTO + RJE_KEY + RJE_INI
			GetInfRJE( 2, cChave, @cStatus )

			//Caso o registro do funcion�rio exista na RJE
			If cStatus == "-1"
				lRet := .F.
			EndIf

		Else

			Help := .T. //Desabilita mensagens de valida��o da fun��o ExistCPO

			//Caso for transfer�ncia de funcion�rio, posiciona na empresa e abre as tabelas destino
			If lGPEA180
				If cEmpAnt <> cEmpDes //Caso for transfer�ncia de empresa, abre as tabelas na nova empresa
					NGPrepTBL( aTbls, cEmpDes, cFilDes )
					cEmpAnt := cEmpDes //Posiciona na empresa destino
				EndIf
			EndIf

			//Posiciona na filial de envio de acordo com a configura��o do TAF
			cFilAnt := cFilEnv

			//Verifica se existe o evento S-2190 para o funcion�rio
			lRet := ExistCPO( "T3A", cCPF, 2 )

			//Caso n�o existir o evento S-2190 para o funcion�rio, verifica se existe o evento S-2200 ou S-2300
			If !lRet
				If lTSVE
					lRet := ExistCPO( "C9V", cCPF, 3 )
				Else
					lRet := ExistCPO( "C9V", cCodUnic, 11 )
				EndIf
			EndIf

			//Caso for transfer�ncia de funcion�rio, retorna a empresa e as tabelas para a atual
			If lGPEA180
				If cEmpAnt <> cEmpBkp //Caso for transfer�ncia de empresa, retorna as tabelas para a empresa atual
					NGPrepTBL( aTbls, cEmpBkp, cFilBkp )
					cEmpAnt := cEmpBkp //Posiciona na empresa atual novamente
				EndIf
			EndIf

			//Retorna a filial
			cFilAnt := cFilBkp

			Help := .F. //Habilita mensagens de valida��o da fun��o ExistCPO

		EndIf
	
	EndIf

	//Retorna a �rea
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTGerCabc
Gera o cabe�alho dos Xml's a serem enviados ao Governo (ID Xml + Evento + Empregador)

@return .T., Sempre verdadeiro

@sample MDTGerCabc( "", "S2210", "1", "548648510000", .T., .F., "3", "", "D MG 01 " )

@param	cXml, Caracter, Xml a ser carregado
@param	cEvento, Caracter, Nome do evento
@param	cOper, Caracter, Opera��o que est� sendo realizada (3- Inclus�o, 4- Altera��o e 5-Exclus�o)
@param	cChave, Caracter, Chave do registro a ser verificado
@param	lEvtExclu, Boolean, Indica se � evento de exclus�o (S-3000)

@author	Luis Fellipy Bett
@since	12/12/2019
/*/
//-------------------------------------------------------------------
Function MDTGerCabc( cXml, cEvento, cOper, cChave, lEvtExclu )

	Local cVersLyt	:= ""
	Local cId		:= ""
	Local cStatReg	:= "-1"
	Local cOperReg	:= "I"
	Local cRetfReg	:= "1"
	Local nRecReg	:= 0
	Local cRecibReg	:= ""
	Local cRecibAnt	:= ""
	Local cRetfNew	:= "1"
	Local cRecibXML	:= ""
	Local cChvBus	:= ""
	Local cTpInsc	:= ""
	Local cNrInsc	:= ""
	Local cTag		:= MDTTagEsoc( cEvento, lEvtExclu ) //Busca a Tag referente ao evento
	Local cTpAmb	:= SuperGetMv( "MV_GPEAMBE", , "2" ) //Tipo de ambiente para envio das informa��es (1-Produ��o, 2-Produ��o Restrita)
	Local lAdmPubl	:= .F.

	//Define como padr�o Xml de inclus�o
	Default cOper := "3"
	Default lEvtExclu := .F.

	//Caso envio seja atrav�s do Middleware
	If lMiddleware

		//Busca a vers�o do leiaute a ser utilizada no envio dos eventos de SST
		cVersLyt := MDTVerEsoc( cEvento )

		//Busca informa��es da empresa
		aInfoC := fXMLInfos()

		If Len( aInfoC ) >= 4
			cTpInsc  := aInfoC[ 1 ]
			cNrInsc  := aInfoC[ 2 ]
			cId  	 := aInfoC[ 3 ]
			lAdmPubl := aInfoC[ 4 ]
		EndIf

		//RJE_TPINSC + RJE_INSCR + RJE_EVENTO + RJE_KEY + RJE_INI
		cChvBus := Padr( cTpInsc, TAMSX3( "RJE_TPINSC" )[1] ) + ;
				Padr( IIf( cTpInsc == "1" .And. !lAdmPubl, SubStr( cNrInsc, 1, 8 ), cNrInsc ), TAMSX3( "RJE_INSCR" )[1] ) + ;
				cEvento + ;
				Padr( cChave, TAMSX3( "RJE_KEY" )[1] )

		GetInfRJE( 2, cChvBus, @cStatReg, @cOperReg, @cRetfReg, @nRecReg, @cRecibReg, @cRecibAnt, Nil, Nil, .T. )

		//Evento sem transmiss�o, ir� sobrescrever o registro na fila
		If cStatReg $ "1/3"
			cOperNew 	:= cOperReg
			cRetfNew	:= cRetfReg
			cStatNew	:= "1"
			lNovoRJE	:= .F.
		//Evento diferente de exclus�o transmitido, ir� gerar uma retifica��o
		ElseIf cOperReg != "E" .And. cStatReg == "4"
			cOperNew 	:= "A"
			cRetfNew	:= "2"
			cStatNew	:=  "1"
			lNovoRJE	:= .T.
		//Ser� tratado como inclus�o
		Else
			cOperNew 	:= "I"
			cRetfNew	:= "1"
			cStatNew	:= "1"
			lNovoRJE	:= .T.
		EndIf
		If cRetfNew == "2"
			If cStatReg == "4"
				cRecibXML := cRecibReg
			Else
				cRecibXML := cRecibAnt
			EndIf
		EndIf

		cXml := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/" + cTag + "/v" + cVersLyt + "'>"
		cXml += 	"<" + cTag + " Id='" + cId + "'>"
	Else
		cXml := "<eSocial>"
		cXml += 	"<" + cTag + ">"

		//Caso seja uma altera��o, define o Xml como retifica��o
		If cOper == "4"
			cRetfNew := "2"
		EndIf
	EndIf

	//V�nculo Evento
	cXml += 			'<ideEvento>'
	If !lEvtExclu //Caso n�o for evento de exclus�o
		cXml +=				'<indRetif>' + 	cRetfNew	+ '</indRetif>'
	EndIf
	If lMiddleware //Caso seja via Middleware (pega o recibo)
		If cRetfNew == "2" .And. !lEvtExclu //Caso seja retifica��o e n�o for evento de exclus�o
			cXml +=			'<nrRecibo>' + 	cRecibXML	+ '</nrRecibo>'
		EndIf
		cXml +=				'<tpAmb>'	+	cTpAmb		+ '</tpAmb>'
		cXml +=				'<procEmi>' + 	"1"			+ '</procEmi>'
		cXml +=				'<verProc>' + 	"12"		+ '</verProc>'
	EndIf
	cXml += 			'</ideEvento>'

	//V�nculo Empregador
	If lMiddleware
		cXml +=			'<ideEmpregador>'
		cXml +=				'<tpInsc>' + cTpInsc	+ '</tpInsc>'
		cXml +=				'<nrInsc>' + SubStr( cNrInsc, 1, 8 ) + '</nrInsc>'
		cXml +=			'</ideEmpregador>'
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTXmlVal

Busca o valor de uma tag dentro do Xml

@return	 cVal, Indefinido, Valor do n� passado no caminho do Xml

@sample MDTXmlVal( "S2240", "<eSocial></eSocial>", "/ns:eSocial/ns:evtExpRisco", "D" )

@param	 cEvento, Caracter, Nome do evento
@param	 cXml, Caracter, Xml a que ser� buscado o valor
@param	 cCamTag, Caracter, Caminho do Xml onde est� o valor a ser pego
@param	 cTipRet, Caracter, Tipo de retorno do valor

@author  Luis Fellipy Bett
@since   31/01/2020
/*/
//-------------------------------------------------------------------
Function MDTXmlVal( cEvento, cXml, cCamTag, cTipRet )

	Local oXml
	Local cVal		:= ""
	Local cVersLyt	:= ""
	Local nStrIni	:= 0
	Local nStrFim	:= 0
	Local nTamStr	:= 0
	Local cTag		:= MDTTagEsoc( cEvento ) //Busca a Tag referente ao evento

	//Caso o Xml passado n�o esteja vazio
	If !Empty( cXml )

		//Busca a vers�o do leiaute de dentro do Xml
		nStrIni := At( '/v', cXml ) + 2
		nStrFim := IIf( At( '">', cXml ) > 0, At( '">', cXml ), At( "'>", cXml ) )
		nTamStr := nStrFim - nStrIni

		cVersLyt := SubStr( cXml, nStrIni, nTamStr ) //Define a vers�o do leiaute de acordo com a vers�o passada no Xml

		oXml := TXMLManager():New()

		If !oXml:Parse( cXml )
			Help( ' ', 1, STR0017, , STR0067, 2, 0, , , , , , { STR0068 } )
		Else
			oXml:XPathRegisterNs( "ns", "http://www.esocial.gov.br/schema/evt/" + cTag + "/v" + cVersLyt )

			If oXml:XPathHasNode( cCamTag )
				cVal := oXml:XPathGetNodeValue( cCamTag )
			EndIf
		EndIf
	EndIf

	//Caso a tag esteja preenchida
	If !Empty( cVal )
		If ValType( cVal ) <> cTipRet
			If cTipRet == "D"
				If Len( cVal ) > 8
					cVal := SToD( StrTran( cVal, "-", "" ) )
				Else
					cVal := SToD( cVal )
				EndIf
			ElseIf cTipRet == "N"
				cVal := Val( cVal )
			EndIf
		EndIf
	Else //Caso a tag esteja vazia
		If cTipRet == "D"
			cVal := SToD( "" )
		ElseIf cTipRet == "N"
			cVal := 0
		EndIf
	EndIf

Return cVal

//-------------------------------------------------------------------
/*/{Protheus.doc} fTabEveEso
Retorna a tabela referente ao evento passado por par�metro

@return  cTab, Caracter, Tabela referente ao evento passado por par�metro

@sample	 fTabEveEso( "S2240" )

@param	 cEvento, Caracter, Evento do eSocial

@author  Luis Fellipy Bett
@since   16/03/2021
/*/
//-------------------------------------------------------------------
Static Function fTabEveEso( cEvento )

	Local cTab := ""

	Do Case
		//Comunica��o de Acidente de Trabalho (CAT)
		Case "2210" $ cEvento
			cTab := "CM0"
		//Monitoramento de Sa�de do Trabalhador (ASO)
		Case "2220" $ cEvento
			cTab := "C8B"
		//Condi��o Ambiental de Trabalho (Risco)
		Case "2240" $ cEvento
			cTab := "CM9"
	EndCase

Return cTab

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTTagEsoc
Retorna a tag referente ao evento passado por par�metro

@return  cTag, Caracter, Tag referente ao evento passado por par�metro

@sample	 MDTTagEsoc( "S2240" )

@param	 cEvento, Caracter, Evento do eSocial

@author  Luis Fellipy Bett
@since   03/02/2020
/*/
//-------------------------------------------------------------------
Function MDTTagEsoc( cEvento, lEvtExclu )

	Local cTag := ""

	Default lEvtExclu := .F.

	Do Case
		//Exclus�o de Eventos
		Case lEvtExclu
			cTag := "evtExclusao"
		//Tabela de Estabelecimentos, Obras ou Unidades de �rg�os P�blicos
		Case "1005" $ cEvento
			cTag := "evtTabEstab"
		//Comunica��o de Acidente de Trabalho (CAT)
		Case "2210" $ cEvento
			cTag := "evtCAT"
		//Monitoramento de Sa�de do Trabalhador (ASO)
		Case "2220" $ cEvento
			cTag := "evtMonit"
		//Condi��o Ambiental de Trabalho (Risco)
		Case "2240" $ cEvento
			cTag := "evtExpRisco"
	EndCase

Return cTag

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTNrInsc
Valida o N�mero de Inscri��o do Local do Acidente ou do Ambiente de
Exposi��o do Risco

@return lRet, Boolean, .T. se o conte�do do campo estiver ok

@param cTpLocal, Caracter, Indica o tipo de local relacionado a Inscri��o
@param cTpInsc, Caracter, Indica o tipo de inscri��o a ser considerado
@param cNrInsc, Caracter, Indica o n�mero da inscri��o
@param cNumMat, Caracter, Indica a matr�cula do funcion�rio

@author Luis Fellipy Bett
@since  16/04/2020
/*/
//-------------------------------------------------------------------
Function MDTNrInsc( cTpLocal, cTpInsc, cNrInsc, cNumMat )

	//Vari�veis de busca e valida��o das informa��es
	Local aEvento   := {}
	Local lVldEvPre := SuperGetMv( "MV_NG2VEVP", .F., "2" ) == "1"
	Local cInscSM0	:= SM0->M0_CGC //N�mero de inscri��o apenas da SM0 para valida��o
	Local lMDTM002	:= IsInCallStack( "MDTM002" )
	Local lMDTM004	:= IsInCallStack( "MDTM004" )
	Local lRet		:= .T.
	Local lExist	:= .F.
	Local cAliasIns	:= ""
	Local nEvento   := 0

	//Caso o sistema deva realizar a valida��o dos eventos predecessores
	If lVldEvPre
	
		//Caso o envio seja atrav�s do Middleware
		If lMiddleware

			//Pega o pr�ximo Alias
			cAliasIns := GetNextAlias()

			//Busca os Xml's do evento S-1005
			aEvento := MDTLstXml( "S1005" )

			For nEvento := 1 To Len( aEvento )

				// Verifica se a inscri��o informada existe no arquivo S-1005
				If AllTrim( MDTXmlVal( "S1005", aEvento[ nEvento, 1 ], "/ns:eSocial/ns:evtTabEstab/ns:infoEstab/ns:inclusao/ns:ideEstab/ns:nrInsc", "C" ) ) == AllTrim( cNrInsc ) .Or.;
				AllTrim( MDTXmlVal( "S1005", aEvento[ nEvento, 1 ], "/ns:eSocial/ns:evtTabEstab/ns:infoEstab/ns:alteracao/ns:ideEstab/ns:nrInsc", "C" ) ) == AllTrim( cNrInsc )
					lExist := .T.
					Exit
				EndIf

			Next nEvento

			If cTpLocal == "1" //Se Estabelecimento do Pr�prio Empregador o CNPJ deve constar na Tabela/Evento S-1005;
				lRet := lExist
			ElseIf ( cTpLocal == "2" .And. lMDTM004 ) .Or. ( cTpLocal == "3" .And. lMDTM002 ) //Se Estabelecimento de Terceiros o CNPJ n�o deve constar na Tabela/Evento S-1005 e deve ser diferente do CNPJ informado na Tabela/Evento S-1000;
				lRet := ( !lExist .And. IIf( cTpInsc == "1", AllTrim( cNrInsc ) <> AllTrim( cInscSM0 ), .T. ) )
			EndIf

		Else
		
			If cTpLocal == "1"
				lRet := ExistCPO( "C92", cNrInsc, 3 )
			ElseIf ( cTpLocal == "2" .And. lMDTM004 ) .Or. ( cTpLocal == "3" .And. lMDTM002 )
				lRet := ( !ExistCPO( "C92", cNrInsc, 3 ) .And. IIf( cTpInsc == "1", AllTrim( cNrInsc ) <> AllTrim( cInscSM0 ), .T. ) )
			EndIf

		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTAjsData
Ajusta as datas do sistema no formato adequado para cada forma
de envio (TAF ou Middleware)

@return	 cDataRet, Caracter, Data ajustada de acordo com o formato de envio

@sample	 MDTAjsData( 13/05/2020 )

@param	 dData, Date, Data a ser tranformada

@author  Luis Fellipy Bett
@since   13/05/2020
/*/
//-------------------------------------------------------------------
Function MDTAjsData( dData )

	Local cDataRet	:= ""
	Local cAno		:= SubStr( DToS( dData ), 1, 4 )
	Local cMes		:= SubStr( DToS( dData ), 5, 2 )
	Local cDia		:= SubStr( DToS( dData ), 7, 2 )

	If !Empty( dData ) //Caso n�o tenha sido passada uma data vazia
		If lMiddleware
			cDataRet := cAno + "-" + cMes + "-" + cDia //2020-05-13
		Else
			cDataRet := cAno + cMes + cDia //20200513
		EndIf
	EndIf

Return cDataRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTDadFun
Busca algumas informa��es do funcion�rio que s�o utilizadas na
composi��o das chaves de busca

@return	 aDadFun, Array, Array contendo as informa��es do funcion�rio

@sample	 MDTDadFun( "000000001" )

@param	 cFicOrMat, Caracter, Ficha m�dica ou matr�cula do funcion�rio

@author  Luis Fellipy Bett
@since   13/05/2020
/*/
//-------------------------------------------------------------------
Function MDTDadFun( cFicOrMat, lMat )

	//Vari�veis de busca de informa��es
	Local aDadFun := {}
	Local cNumMat := ""

	Default lMat := .F.

	If lMat //Caso a matr�cula seja passada por par�metro
		cNumMat := cFicOrMat
	Else
		cNumMat := Posicione( "TM0", 1, xFilial( "TM0" ) + cFicOrMat, "TM0_MAT" ) //Busca a matr�cula do funcion�rio
	EndIf

	//----------------------
	//Posi��es do retorno
	//1- Matr�cula
	//2- Nome
	//3- CPF
	//4- C�digo �nico
	//5- Categoria
	//6- Data de Admiss�o
	//7- Centro de Custo
	//----------------------
	aDadFun := { cNumMat, ;
				Posicione( "SRA", 1, xFilial( "SRA" ) + cNumMat, "RA_NOME" ), ;
				Posicione( "SRA", 1, xFilial( "SRA" ) + cNumMat, "RA_CIC" ), ;
				Posicione( "SRA", 1, xFilial( "SRA" ) + cNumMat, "RA_CODUNIC" ), ;
				Posicione( "SRA", 1, xFilial( "SRA" ) + cNumMat, "RA_CATEFD" ), ;
				Posicione( "SRA", 1, xFilial( "SRA" ) + cNumMat, "RA_ADMISSA" ), ;
				Posicione( "SRA", 1, xFilial( "SRA" ) + cNumMat, "RA_CC" ) }

Return aDadFun

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTGetIdFun
Busca a informa��o do campo CM9_ID, referente ao ID do funcion�rio no SIGATAF

@return	 cIDFunc, Caracter, ID do funcion�rio no TAF

@sample	 MDTGetIdFun( "000000001" )

@param	 cMatricula, Caracter, Matricula do funcion�rio na SRA
@param	 cFilFun, Caracter, Filial do funcion�rio a ser considerada

@author  Luis Fellipy Bett
@since   24/11/2020
/*/
//-------------------------------------------------------------------
Function MDTGetIdFun( cMatricula, cFilFun )

	Local cIDFunc	:= ""
	Local cCodUnic	:= ""
	Local cCPF		:= ""

	//Por padr�o define a filial como sendo a atual
	Default cFilFun := cFilAnt

	cCodUnic := Posicione( "SRA", 1, xFilial( "SRA", cFilFun ) + cMatricula, "RA_CODUNIC" )
	cCPF := Posicione( "SRA", 1, xFilial( "SRA", cFilFun ) + cMatricula, "RA_CIC" )

	cIDFunc := TAFIdFunc( cCPF, cCodUnic )[ 1 ]

Return cIDFunc

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTBscDtEnv
Busca a data que dever� ser considerada na integra��o

@return	 dDataEnv, Data, Data a ser considerada no envio do evento

@param	aFuncs, Array, Array contendo as informa��es do funcion�rio
@param	nOper, Num�rico, Indica a opera��o que est� sendo realizada (3-Inclus�o/4-Altera��o/5-Exclus�o)
@param	lXml, Boolean, Indica se � valida��o chamada pela gera��o de xml
@param	dDtAtu, Data, Data de in�cio da exposi��o atual do funcion�rio

@sample	 MDTBscDtEnv( { { "100000" } }, 3, .T., 21/10/2021 )

@author  Luis Fellipy Bett
@since   24/11/2020
/*/
//-------------------------------------------------------------------
Function MDTBscDtEnv( aFuncs, nOper, lXml, dDtAtu )

	//Vari�veis de controle de �rea/filial
	Local aArea	   := GetArea()
	Local cFilBkp  := cFilAnt

	//Vari�veis de contadores
	Local nCont  := 0
	Local nCont2 := 0

	//Vari�veis de chamadas
	Local lMDTA181 := IsInCallStack( "MDTA181" )
	Local lMDTA130 := IsInCallStack( "MDTA130" )
	Local lMDTA125 := IsInCallStack( "MDTA125" )
	Local lMDTA215 := IsInCallStack( "MDTA215" )

	//Vari�veis de busca de informa��o
	Local dDataEnv		:= SToD( "" )
	Local dDtAltSal		:= SToD( "" )
	Local dDtElim		:= SToD( "" )
	Local dDtAux		:= SToD( "" )
	Local dDtReco		:= SToD( "" )
	Local dDtIniTar		:= SToD( "" )
	Local dDtFimTar		:= SToD( "" )
	Local dDataTra		:= SToD( "" )
	Local dDtAdmis		:= Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ 1 ], "RA_ADMISSA" )
	Local aEPIs			:= {}
	Local cNumRisco		:= ""

	//Define por padr�o como n�o sendo gera��o de Xml
	Default lXml := .F.

	//Adiciona os valores passados ou n�o pelo array, para as vari�veis
	If Len( aFuncs ) > 2 //Caso o risco tenha sido passado no array (MDTA125, MDTA130, MDTA180, MDTA181, MDTA215)
		cNumRisco := IIf( aFuncs[ 3 ] != Nil, aFuncs[ 3 ], "" )
	EndIf
	If Len( aFuncs ) > 4 //Caso a data de in�cio da tarefa tenha sido passada no array (MDTA005, MDTA090A, MDTA882)
		dDtIniTar := IIf( aFuncs[ 5 ] != Nil, aFuncs[ 5 ], SToD( "" ) )
	EndIf
	If Len( aFuncs ) > 5 //Caso a data de fim da tarefa tenha sido passada no array (MDTA005, MDTA090A, MDTA882)
		dDtFimTar := IIf( aFuncs[ 6 ] != Nil, aFuncs[ 6 ], SToD( "" ) )
	EndIf
	If Len( aFuncs ) > 6 .And. aFuncs[ 7 ] != Nil //Caso a data de transfer�ncia tenha sido passada no array (GPEA180)
		dDataTra := IIf( aFuncs[ 7, 1, 1 ] != Nil, aFuncs[ 7, 1, 1 ], SToD( "" ) )
	EndIf

	//Caso for cadastro de funcion�rio, Risco ou Risco x Laudos, busca informa��es das datas do Risco
	If lGPEA010 //Cadastro de Funcion�rio

		//Busca os riscos a que o funcion�rio est� exposto
		aRisExp := MDTRis2240()

		For nCont := 1 To Len( aRisExp )
			dDtAux := Posicione( "TN0", 1, xFilial( "TN0" ) + aRisExp[ nCont, 1 ], "TN0_DTRECO" )
			If dDtReco < dDtAux
				dDtReco := dDtAux
			EndIf
		Next nCont

	ElseIf lMDTA180 //Cadastro de Risco

		dDtReco := M->TN0_DTRECO
		dDtElim := M->TN0_DTELIM

	ElseIf lMDTA215 //Risco x Laudo

		dDtReco := Posicione( "TN0", 1, xFilial( "TN0" ) + cNumRisco, "TN0_DTRECO" )
		dDtElim := Posicione( "TN0", 1, xFilial( "TN0" ) + cNumRisco, "TN0_DTELIM" )

	EndIf

	//---------------------------------------------------------------------------------
	// Verifica pela chamada de cada rotina, qual a data ser� considerada para o envio
	//---------------------------------------------------------------------------------
	If lGPEA010 //Cadastro de Funcion�rio

		If lXml //Caso for gera��o de Xml
			If !Empty( dDtAtu ) //Caso exista registro comunicado para o evento pega a data comunicado, sen�o pega a data base
				dDataEnv := dDtAtu
			Else
				dDataEnv := dDataBase
			EndIf
		Else
			If nOper != 3
				//Verifica a data de altera��o salarial
				dDtAltSal := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ 1 ], "RA_DATAALT" )
			EndIf

			//Caso as vari�veis existirem
			If Type( "aSraHeader" ) == "A" .And. Type( "aSvSraCols" ) == "A"
			
				//Pega a fun��o anterior
				cFuncAnt := GdFieldGet( "RA_CODFUNC", 1, .F., aSraHeader, aSvSraCols )

			EndIf

			//Pega a fun��o atual
			cFuncAtu := GetMemVar( "RA_CODFUNC" )

			If !Empty( cFuncAnt ) .And. cFuncAnt <> cFuncAtu //Caso o funcion�rio tenha sido alterado de fun��o

				dDataEnv := dDtAltSal

			ElseIf !MDTVld2240( aFuncs[ 1 ] ) //Caso n�o exista o registro do evento S-2240 para o funcion�rio no SIGATAF/Middleware

				//Verifica qual a data de inicio da exposi��o
				If dDtReco >= dDtAdmis
					dDataEnv := dDtReco
				ElseIf dDtAdmis > dDtReco
					If dDtAdmis > dDtEsoc
						dDataEnv := dDtAdmis
					Else
						dDataEnv := dDtEsoc
					EndIf
				EndIf

			EndIf
		EndIf

	ElseIf lGPEA180 //Transfer�ncia de Funcion�rio

		dDataEnv := dDataTra

	ElseIf lMDTA005 //Ficha M�dica x Tarefas

		If dDtIniTar >= dDtAtu //Lan�amento posterior a Data Atual
			dDataEnv := dDtIniTar
		ElseIf dDtIniTar < dDtAtu .And. dDtFimTar > dDtAtu //Lan�amento contemplando a Data Atual
			dDataEnv := dDtAtu
		EndIf

	ElseIf lMDTA090 .Or. lGPEM040

		If dDtIniTar <= dDataBase .And. ( dDataBase <= dDtFimTar .Or. Empty( dDtFimTar ) )
			// Caso tenha iniciado a tarefa, verifica se a ultima exposi��o � menor
			// se for, utiliza a data de inicio como referencia
			If dDtIniTar >= dDtAtu
				dDataEnv := dDtIniTar
			ElseIf dDtIniTar < dDtAtu
				dDataEnv := dDtAtu
			EndIf

			// Verifica se est� finalizanda a Tarefa, caso esteja, utiliza como data base o fim da tarefa
			If !Empty( dDtIniTar ) .And. !Empty( dDtFimTar ) .And. dDtFimTar >= dDataBase
				dDataEnv := DaySum( dDtFimTar, 1 )
			EndIf

		Else
			//Se for um lan�amento retroativo, verifica se o per�odo � superior ao �ltimo lan�amento
			If dDtIniTar < dDataBase .And. dDtFimTar < dDataBase .And. !Empty( dDtIniTar ) .And. !Empty( dDtFimTar )
				//Caso data de inicio seja maior que ultimo lan�amento, gera novo, se n�o atualiza
				If dDtIniTar >= dDtAtu
					//Lan�ar um novo
					dDataEnv := dDtIniTar
				Else
					//Retificar o atual
					dDataEnv := dDtAtu
				EndIf

				//Caso data de fim seja maior que ultimo lan�amento, gera novo, se n�o atualiza
				If dDtFimTar >= dDtAtu
					//Lan�ar um novo
					dDataEnv := DaySum( dDtFimTar, 1 )
				Else
					//Retificar o atual
					dDataEnv := dDtAtu
				EndIf
			EndIf
		EndIf

	ElseIf lGPEA370 .Or. lMDTA181 .Or. lMDTA130 .Or. lMDTA125 //Relacionamentos do Risco, EPI x Risco, Risco x EPI

		dDataEnv := dDtAtu

	ElseIf lMDTA165 //Cadastro de Ambiente

		If !Empty( dDtAtu ) //Caso exista registro do S-2240 no TAF
			dDataEnv := dDtAtu
		Else
			If dDtAdmis > dDtEsoc //Caso a admiss�o do funcion�rio for posterior ao inicio das obrigatoriedades
				dDataEnv := dDtAdmis
			Else
				dDataEnv := dDtEsoc
			EndIf
		EndIf

	ElseIf lMDTA695 .Or. lMDTA630 .Or. lMATA185 //Entrega de EPI's

		//Salva os EPIs no array auxiliar
		aEPIs := aFuncs[ 8 ]

		//Busca a �ltima data de entrega do EPI
		For nCont2 := 1 To Len( aEPIs )
			If dDtAux < aEPIs[ nCont2, 2 ]
				dDtAux := aEPIs[ nCont2, 2 ]
			EndIf
		Next nCont2

		dDataEnv := dDtAux //A data de entrega de EPI mais atual

	ElseIf lMDTA881 //Carga Inicial Riscos

		//Caso a admiss�o do funcion�rio tenha sido feita ap�s o in�cio da obrigatoriedade
		If dDtAdmis > dDtEsoc
			dDataEnv := dDtAdmis
		Else
			dDataEnv := dDtEsoc
		EndIf

	ElseIf lMDTA882 //Schedule Tarefas

		dDataEnv := dDataBase

	ElseIf lMDTA180 .Or. lMDTA215 //Cadastro de Risco ou Laudos x Risco

		If nOper == 5 //SE EU ESTIVER EXCLUINDO ----------------------------------------------

			dDataEnv := dDataBase

		ElseIf !Empty( dDtElim ) //SE EU ESTIVER ELIMINANDO ---------------------------------

			If dDtElim <= dDtAtu
				dDataEnv := dDtAtu
			ElseIf dDtElim > dDtAtu
				dDataEnv := dDtElim
			EndIf

		Else

			If MDTVld2240( aFuncs[ 1 ], Nil, IIf( dDtAdmis > dDtReco, dDtAdmis, dDtReco ) )

				If nOper == 3
					If dDtReco <= dDtAtu
						dDataEnv := dDtAtu
					ElseIf dDtReco > dDtAtu
						dDataEnv := dDtReco
					EndIf
				Else
					dDataEnv := dDtAtu
				EndIf

			Else //Caso n�o exista o registro S-2240 para o funcion�rio, valida como sendo inclus�o do registro na CM9

				If dDtAdmis > dDtReco
					dDataEnv := dDtAdmis
				Else
					dDataEnv := dDtReco
				EndIf

			EndIf

		EndIf
	EndIf

	cFilAnt := cFilBkp //Retorna para filial atual
	RestArea( aArea ) //Retorna �rea

Return dDataEnv

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTDtExpAtu
Busca a data atual de exposi��o do funcion�rio ao evento S-2240

@return	dDtAtu, Data, Data da exposi��o mais recente do funcion�rio

@param	cMatricula, Caracter, Matr�cula do funcion�rio a ter a data buscada

@sample	MDTDtExpAtu( "000000001" )

@author	Luis Fellipy Bett
@since	24/11/2020
/*/
//-------------------------------------------------------------------
Function MDTDtExpAtu( cMatricula )

	//Vari�veis de controle de �rea/filial
	Local aArea	  := GetArea()
	Local cFilBkp := cFilAnt

	//Vari�veis de tabela tempor�ria
	Local cAliasFunc := GetNextAlias() //Pega o pr�ximo Alias

	//Vari�veis de busca de informa��o
	Local aEvento := {}
	Local dDtAtu  := SToD( "" )

	If lMiddleware //Caso seja integra��o atrav�s do Middleware

		//Busca os Xml's do evento e funcion�rio passado por par�metro
		aEvento := MDTLstXml( "S2240", cMatricula )

		//Passa o Xml para buscar a informa��o da data de exposi��o
		If Len( aEvento ) > 0
			dDtAtu := MDTXmlVal( "S2240", aEvento[ 1, 1 ], "/ns:eSocial/ns:evtExpRisco/ns:infoExpRisco/ns:dtIniCondicao", "D" )
		EndIf

	Else //Caso seja integra��o atrav�s do SIGATAF

		cIDFunc := MDTGetIdFun( cMatricula ) //Busca o ID do funcion�rio do TAF

		BeginSQL Alias cAliasFunc
			SELECT CM9.CM9_ID, CM9.CM9_DTINI
				FROM %table:CM9% CM9
				WHERE CM9.CM9_FILIAL = %xFilial:CM9% AND
						CM9.CM9_FUNC = %exp:cIDFunc% AND
						CM9.%NotDel%
				ORDER BY CM9.CM9_DTINI DESC
		EndSQL

		dbSelectArea( cAliasFunc )
		dDtAtu := SToD( ( cAliasFunc )->( CM9_DTINI ) )

		( cAliasFunc )->( dbCloseArea() )

	EndIf

	cFilAnt := cFilBkp //Retorna para filial atual
	RestArea( aArea ) //Retorna �rea

Return dDtAtu

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTLstXml
Busca os Xml's existentes referente ao evento e funcion�rio passado por par�metro

@author	Luis Fellipy Bett
@since	01/03/2021

@param	cEvento, Caracter, Evento para que ser� buscado o Xml
@param	cMatricula, Caracter, Matr�cula do funcion�rio a ter o Xml buscado

@return, aEvento, cont�m as informa��es buscadas
/*/
//-------------------------------------------------------------------
Function MDTLstXml( cEvento, cMatricula )

	//Vari�veis para busca das informa��es da empresa
	Local aInfoC	 := fXMLInfos()
	Local cTpInsc	 := ""
	Local cNrInsc	 := "0"
	Local lAdmPubl	 := .F.
	Local cChave	 := ""
	Local cNrInscChv := ""

	//Vari�veis para busca das informa��es do funcion�rio
	Local aEvento    := {}
	Local aDadFun	 := ""
	Local cCPFAux	 := ""
	Local cUnicAux	 := ""
	Local cCategAux	 := ""
	Local cPesquisa  := ''
	Local dAdmisAux	 := ""

	//Define o valor padr�o para as vari�veis
	Default cMatricula := ""

	//Caso tenha sido passado uma matr�cula por par�metro
	If !Empty( cMatricula )
		aDadFun   := MDTDadFun( cMatricula, .T. )
		cCPFAux	  := aDadFun[3]
		cUnicAux  := aDadFun[4]
		cCategAux := aDadFun[5]
		dAdmisAux := aDadFun[6]
	EndIf

	//Busca as informa��es da empresa
	If Len( aInfoC ) >= 4
		cTpInsc  := aInfoC[1]
		cNrInsc  := aInfoC[2]
		lAdmPubl := aInfoC[4]
	EndIf

	//Monta a chave para busca do registro
	If cEvento == "S1005"
		cChave := cFilEnv + AllTrim( cNrInsc )
	Else
		If MDTVerTSVE( cCategAux ) //Caso for Trabalhador Sem V�nculo Estatut�rio
			cChave := AllTrim( cCPFAux ) + AllTrim( cCategAux ) + DToS( dAdmisAux )
		Else
			cChave := AllTrim( cUnicAux )
		EndIf
	EndIf

	//Monta a inscri��o a ser considerada na busca dos xml's
	cNrInscChv := Padr( IIf( !lAdmPubl .And. cTpInsc == "1", SubStr( cNrInsc, 1, 8 ), cNrInsc ), TAMSX3( "RJE_INSCR" )[1] )

	cPesquisa := cTpInsc + cNrInscChv + cEvento

	DbSelectArea( 'RJE' )
	DbSetOrder( 2 )

	If DbSeek( cPesquisa + cChave )

		While ( 'RJE' )->( !Eof() ) .And. RJE->RJE_TPINSC + RJE->RJE_INSCR + RJE->RJE_EVENTO == cPesquisa .And. cChave $ RJE->RJE_KEY

			aAdd( aEvento, {;
				RJE->RJE_XML,;
				RJE->RJE_RECIB,;
				RJE->RJE_DTENV,;
				DtoS( RJE->RJE_DTG ),;
				RJE->RJE_HORAG;
			} )

			( 'RJE' )->( DbSkip() )

		End

		aSort( aEvento, Nil, Nil, { | x, y | x[ 4 ] + x [ 5 ] > y[ 4 ] + y[ 5 ] } ) // Ordena pelos eventos mais recentes

	EndIf

Return aEvento

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTVerEsoc
Busca a vers�o do leiaute a ser considerada no envio dos eventos de SST ao eSocial

@return	cVersMDT, Caracter, Vers�o do leiaute a ser utilizado para os eventos de SST

@param	cEvento, Caracter, Evento que est� sendo enviado ao Governo

@sample	MDTVerEsoc()

@author	Luis Fellipy Bett
@since	26/04/2021
/*/
//-------------------------------------------------------------------
Function MDTVerEsoc( cEvento )

	Local cVersMDT := ""
	Local cVersGPE := ""

	If FindFunction( "fVersEsoc" )
		fVersEsoc( cEvento, .F., /*aRetGPE*/ , /*aRetTAF*/ , Nil, Nil, @cVersGPE )
	EndIf

	cVersMDT := "_S_01_00_00"

Return cVersMDT

//-------------------------------------------------------------------
/*/{Protheus.doc} fVerStack
Verifica a chamada dos fontes de acordo com o fonte passado por par�metro

@return	lRet, Boolean, .T. caso seja chamada do fonte do par�metro

@param	cFonVer, Caracter, Fonte da chamada a ser verificado
@param	oModelTNC, Objeto, Objeto do modelo do cadastro de Acidentes

@sample	fVerStack( "MDTA640", oModelTNC )

@author	Luis Fellipy Bett
@since	27/05/2021
/*/
//-------------------------------------------------------------------
Static Function fVerStack( cFonVer, oModelTNC )

	Local lRet	:= .T.
	Local lAcid	:= oModelTNC <> Nil

	If cFonVer == "MDTA640" //Acidente
		lRet := IsInCallStack( "MDTA640" ) .Or. lAcid
	ElseIf cFonVer == "MDTA155" //Diagn�stico
		lRet := ( IsInCallStack( "MDTA155" ) .Or. IsInCallStack( "NG155CID" ) .Or. IsInCallStack( "MDT155GDI" ) ) .And. !lAcid
	ElseIf cFonVer == "MDTA685" //Atestado
		lRet := ( IsInCallStack( "MDTA685" ) .Or. IsInCallStack( "MDT685POS" ) .Or. IsInCallStack( "MDT685COMM" ) ) .And. !lAcid
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fFunNaoEnv
Valida se o evento do funcion�rio deve ser enviado ou n�o ao Governo

@return	aFunNao, Array, Array contendo os funcion�rios que n�o ser�o comunicados

@param	cEvento, Caracter, Evento que est� sendo enviado
@param	aFuncs, Array, Array contendo os funcion�rios a serem validados
@param	nOper, Num�rico, Indica a opera��o que est� sendo realizada (3-Inclus�o/4-Altera��o/5-Exclus�o)

@sample	fFunNaoEnv( "S-2240", { { "0000236" } } )

@author	Luis Fellipy Bett
@since	17/06/2021
/*/
//-------------------------------------------------------------------
Static Function fFunNaoEnv( cEvento, aFuncs, nOper, aFunNaoEnv )

	//Salva a �rea
	Local aArea := GetArea()

	Local cCategAut	 := SuperGetMv( "MV_NTSV", .F., "701/711/712/741" )
	Local cCategNao	 := SuperGetMv( "MV_NG2NENV", .F., "" )
	Local dDtDemis	 := SToD( "" )
	Local cFilBkp	 := cFilAnt
	Local cNomeFunc	 := ""
	Local cCatgFunc	 := ""
	Local cCpfFunc	 := ""
	Local cCodUnic	 := ""
	Local cSitFolh	 := ""
	Local cVersEnvio := ""
	Local nCont		 := 0
	Local nPosReg	 := 0
	Local nOpcAdd	 := 9
	Local lAdmPre	 := .F.

	//---------------------------
	// Busca a vers�o do leiaute
	//---------------------------
	fVersEsoc( "S2200", .F., , , @cVersEnvio )

	//-------------------------------------------------------
	// Percorre o array analisando as condi��es de n�o envio
	//-------------------------------------------------------
	For nCont := 1 To Len( aFuncs )

		//---------------------------------------------------------------------------
		// Fun��o gen�rica para posicionar na filial correta em chamadas espec�ficas
		//---------------------------------------------------------------------------
		fPosFil( cEvento, IIf( Len( aFuncs[ nCont ] ) > 1 .And. aFuncs[ nCont, 2 ] <> Nil, aFuncs[ nCont, 2 ], "" ) )

		//Busca as informa��es do funcion�rio
		cNomeFunc := AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_NOME" ) )
		cCatgFunc := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_CATEFD" )
		cCpfFunc  := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_CIC" )
		cCodUnic  := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_CODUNIC" )
		dDtDemis  := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_DEMISSA" )
		cSitFolh  := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_SITFOLH" )
		lAdmPre	  := fVerAdmPre( cCpfFunc, cCodUnic, cCatgFunc )

		//-------------------------------------------------------------------------
		// Realiza valida��es para verificar se o funcion�rio n�o deve ser enviado
		//-------------------------------------------------------------------------
		If !Empty( dDtDemis ) .And. cSitFolh == "D" .And. cEvento <> "S-2220" .And. !IsInCallStack( "fEnvTaf180" ) //Caso o funcion�rio esteja demitido e n�o seja envio do evento S-2220
			nOpcAdd := 0
		ElseIf cCatgFunc $ cCategNao //Caso a categoria do funcion�rio esteja no par�metro MV_NG2NENV
			nOpcAdd := 1
		ElseIf cCatgFunc $ cCategAut //Caso a categoria do funcion�rio esteja no par�metro MV_NTSV
			nOpcAdd := 2
		ElseIf lAdmPre .And. cVersEnvio < "9.0.00" //Caso o funcion�rio esteja em admiss�o preliminar e o leiaute n�o for o S-1.0
			nOpcAdd := 3
		EndIf

		//Caso o funcion�rio n�o deva ser enviado, adiciona ao array
		If nOpcAdd <> 9
			aAdd( aFunNaoEnv, { nOpcAdd, aFuncs[ nCont, 1 ], cNomeFunc, cCatgFunc } )
			nOpcAdd := 9 //Volta a vari�vel para validar o pr�ximo funcion�rio do la�o
		EndIf

	Next nCont

	//-----------------------------------------------------------------------
	// Caso exista funcion�rios que n�o devem ser enviados, deleta do array
	//-----------------------------------------------------------------------
	If Len( aFunNaoEnv ) > 0
		For nCont := 1 To Len( aFunNaoEnv )
			If ( nPosReg := aScan( aFuncs, { |x| x[ 1 ] == aFunNaoEnv[ nCont, 2 ] } ) ) > 0
				aDel( aFuncs, nPosReg ) //Deleta registro do array
				aSize( aFuncs, Len( aFuncs ) - 1 ) //Diminui a posi��o exclu�da do array
			EndIf
		Next nCont
	EndIf

	//Volta a filial
	cFilAnt := cFilBkp

	//Retorna a �rea
	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMsgNaoEnv
Exibe a mensagem informando quais funcion�rios n�o foram comunicados

@return	Nil, Nulo

@param	aNaoEnv, Array, Array contendo os funcion�rios que n�o foram enviados
@param	cMsgInc, Caracter, Vari�vel que recebe os funcion�rios que n�o foram enviados

@sample	fMsgNaoEnv( { { "0000236" } }, "" )

@author	Luis Fellipy Bett
@since	21/06/2021
/*/
//-------------------------------------------------------------------
Static Function fMsgNaoEnv( aNaoEnv, cMsgInc )

	Local cMsg1	   := STR0071 //"Os trabalhadores abaixo n�o foram comunicados pois se enquadram em alguma condi��o de n�o envio. Para saber mais sobre as condi��es clique no bot�o 'Abrir'."
	Local cMsg2	   := ""
	Local nCont	   := 0
	Local aArrAux1 := {}
	Local aArrAux2 := {}
	Local aArrAux3 := {}
	Local aArrAux4 := {}

	//Percorre todos os funcion�rios que n�o ser�o enviados e adiciona de acordo com a condi��o de n�o envio
	For nCont := 1 To Len( aNaoEnv )

		If aNaoEnv[ nCont, 1 ] == 1
			aAdd( aArrAux1, STR0024 + ": " + aNaoEnv[ nCont, 2 ] + " - " + aNaoEnv[ nCont, 3 ] + " / " + STR0072 + ": " + aNaoEnv[ nCont, 4 ] ) //Funcion�rio##Categoria
		ElseIf aNaoEnv[ nCont, 1 ] == 2
			aAdd( aArrAux2, STR0024 + ": " + aNaoEnv[ nCont, 2 ] + " - " + aNaoEnv[ nCont, 3 ] + " / " + STR0072 + ": " + aNaoEnv[ nCont, 4 ] ) //Funcion�rio##Categoria
		ElseIf aNaoEnv[ nCont, 1 ] == 3
			aAdd( aArrAux3, STR0024 + ": " + aNaoEnv[ nCont, 2 ] + " - " + aNaoEnv[ nCont, 3 ] ) //Funcion�rio
		ElseIf aNaoEnv[ nCont, 1 ] == 4
			aAdd( aArrAux4, STR0024 + ": " + aNaoEnv[ nCont, 2 ] + " - " + aNaoEnv[ nCont, 3 ] ) //Funcion�rio
		EndIf

	Next nCont

	//Comp�em a vari�vel da mensagem com os funcion�rios que tem a categoria no par�metro MV_NG2NENV
	If Len( aArrAux1 ) > 0
		cMsg2 += STR0076 + ": " + CRLF //"Os funcion�rios abaixo n�o foram comunicados devido terem suas categorias definidas no par�metro MV_NG2NENV"
		For nCont := 1 To Len( aArrAux1 ) //Percorre o array adicionando os funcion�rios
			cMsg2 += aArrAux1[ nCont ] + CRLF
		Next nCont
	EndIf

	//Comp�em a vari�vel da mensagem com os funcion�rios que tem a categoria no par�metro MV_NTSV
	If Len( aArrAux2 ) > 0
		cMsg2 += IIf( Empty( cMsg2 ), "", CRLF )
		cMsg2 += STR0074 + ": " + CRLF //"Os funcion�rios abaixo n�o foram comunicados devido terem suas categorias definidas no par�metro MV_NTSV"
		For nCont := 1 To Len( aArrAux2 ) //Percorre o array adicionando os funcion�rios
			cMsg2 += aArrAux2[ nCont ] + CRLF
		Next nCont
	EndIf

	//Comp�em a vari�vel da mensagem com os funcion�rios que est�o em admiss�o preliminar e o leiaute � anterior a vers�o S-1.0
	If Len( aArrAux3 ) > 0
		cMsg2 += IIf( Empty( cMsg2 ), "", CRLF )
		cMsg2 += STR0075 + ": " + CRLF //"Os funcion�rios abaixo n�o foram comunicados devido estarem em admiss�o preliminar e o leiaute ser anterior a vers�o S-1.0"
		For nCont := 1 To Len( aArrAux3 ) //Percorre o array adicionando os funcion�rios
			cMsg2 += aArrAux3[ nCont ] + CRLF
		Next nCont
	EndIf

	//Comp�em a vari�vel da mensagem com os funcion�rios que n�o est�o expostos a riscos e o par�metro MV_NG2DENO est� com data superior ao do envio dos eventos
	If Len( aArrAux4 ) > 0
		cMsg2 += IIf( Empty( cMsg2 ), "", CRLF )
		cMsg2 += STR0093 + ": " + CRLF //"Os funcion�rios abaixo n�o foram comunicados pois n�o est�o expostos a riscos e o par�metro MV_NG2DENO est� definido com uma data superior � data a ser considerada no envio do evento"
		For nCont := 1 To Len( aArrAux4 ) //Percorre o array adicionando os funcion�rios
			cMsg2 += aArrAux4[ nCont ] + CRLF
		Next nCont
	EndIf

	//Caso existam funcion�rios a serem informados na mensagem
	//Caso forem funcion�rios demitidos o sistema n�o emite na mensagem mas passa por essa fun��o
	If !Empty( cMsg2 )

		//Caso n�o for execu��o autom�tica mostra a mensagem
		If !lExecAuto
			MDTMEMOLINK( STR0073, cMsg1, "https://tdn.totvs.com/x/FE9uJQ", cMsg2 ) //Funcion�rios n�o comunicados
		Else
			//Adiciona as informa��es na vari�vel de retorno
			cMsgInc += cMsg1 + CRLF
			cMsgInc += "https://tdn.totvs.com/x/FE9uJQ" + CRLF
			cMsgInc += cMsg2 + CRLF
		EndIf

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVerAdmPre
Verifica se o funcion�rio est� em admiss�o preliminar

@return	lAdmPre, Boolean, .T. caso seja admiss�o preliminar sen�o .F.

@param	cCPF, Caracter, CPF do funcion�rio
@param	cCodUnic, Caracter, C�digo �nico do funcion�rio
@param	cCodCateg, Caracter, Categoria do funcion�rio

@sample	fVerAdmPre( "41458562875", "T1D MG 01 10000020180305111429", "701" )

@author	Luis Fellipy Bett
@since	06/07/2021
/*/
//-------------------------------------------------------------------
Static Function fVerAdmPre( cCPF, cCodUnic, cCodCateg )

	Local lTSVE	  := MDTVerTSVE( cCodCateg )
	Local lAdmPre := .F.

	Help := .T. //Desabilita as mensagens de Help

	//Caso o registro do funcion�rio exista na tabela do S-2190 e n�o exista na do S-2200 ou S-2300
	If ExistCPO( "T3A", cCPF, 2 ) .And. !( IIf( lTSVE, ExistCPO( "C9V", cCPF, 3 ), ExistCPO( "C9V", cCodUnic, 11 ) ) )
		lAdmPre := .T.
	EndIf

	Help := .F. //Habilita as mensagens de Help

Return lAdmPre

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldEsp2240
Realiza verifica��es espec�ficas para o evento S-2240

@return	Nil, Nulo

@param	cMsgInc, Caracter, Mensagem de inconsist�ncias a ser retornada
@param	aFuncs, Array, Array contendo os funcion�rios para valida��o
@param	nOper, Num�rico, Indica a opera��o que est� sendo realizada (3-Inclus�o/4-Altera��o/5-Exclus�o)

@sample	fVldEsp2240( "", { { "000230" } }, 3 )

@author	Luis Fellipy Bett
@since	20/07/2021
/*/
//-------------------------------------------------------------------
Static Function fVldEsp2240( cMsgInc, aFuncs, nOper )

	//---------------------------------------------------
	// Realiza verifica��es especiais para cada chamada
	//---------------------------------------------------
	If lGPEA010 //Caso for cadastro de funcion�rio

		//Verifica as tarefas vinculadas aos funcion�rios
		fVldTarFun( @cMsgInc, aFuncs )

		//Verifica se o funcion�rio est� vinculado a um ambiente
		fVldAmbFun( @cMsgInc, aFuncs, nOper )

		//Verifica se o funcion�rio est� sendo cadastrado como admiss�o futura
		fVldAdmFut( @cMsgInc, aFuncs )

		//Verifica se existem EPI's entregues ao funcion�rio quando o risco est� definido como sendo necessita EPI
		Processa( { || fVldEPIFun( @cMsgInc, aFuncs, nOper ) }, STR0090 ) //Valida as informa��es a serem enviadas ## "Aguarde, verificando os EPI's entregues ao funcion�rio..."

	ElseIf lGPEA180 //Caso for transfer�ncia de funcion�rio

		//Verifica as tarefas vinculadas aos funcion�rios
		fVldTarFun( @cMsgInc, aFuncs )

		//Verifica se o funcion�rio est� vinculado a um ambiente
		fVldAmbFun( @cMsgInc, aFuncs, nOper )

		//Verifica se existem EPI's entregues ao funcion�rio quando o risco est� definido como sendo necessita EPI
		Processa( { || fVldEPIFun( @cMsgInc, aFuncs, nOper ) }, STR0090 ) //Valida as informa��es a serem enviadas ## "Aguarde, verificando os EPI's entregues ao funcion�rio..."

	ElseIf lMDTA090 //Caso for cadastro de tarefas

		//Verifica as tarefas vinculadas aos funcion�rios
		fVldTarFun( @cMsgInc, aFuncs )

		//Verifica se o funcion�rio est� vinculado a um ambiente
		fVldAmbFun( @cMsgInc, aFuncs, nOper )

	ElseIf lMDTA165 //Caso for cadastro de de ambiente f�sico

		//Verifica as tarefas vinculadas aos funcion�rios
		fVldTarFun( @cMsgInc, aFuncs )

		//Verifica se existem EPI's entregues ao funcion�rio quando o risco est� definido como sendo necessita EPI
		Processa( { || fVldEPIFun( @cMsgInc, aFuncs, nOper ) }, STR0090 ) //Valida as informa��es a serem enviadas ## "Aguarde, verificando os EPI's entregues ao funcion�rio..."

	ElseIf lMDTA180 //Caso cadastro de risco

		//Verifica se existem EPI's entregues ao funcion�rio quando o risco est� definido como sendo necessita EPI
		Processa( { || fVldEPIFun( @cMsgInc, aFuncs, nOper ) }, STR0090 ) //Valida as informa��es a serem enviadas ## "Aguarde, verificando os EPI's entregues ao funcion�rio..."

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldTarFun
Verifica se os funcion�rios passados por par�metro est�o vinculados
a alguma tarefa

@return	Nil, Nulo

@param	cMsgInc, Caracter, Vari�vel que grava as inconsist�ncias (caso houver)
@param	aFuncs, Array, Array contendo as informa��es dos funcion�rios para valida��o

@sample	fVldTarFun( "", { { "000230" } } )

@author	Luis Fellipy Bett
@since	22/07/2021
/*/
//-------------------------------------------------------------------
Static Function fVldTarFun( cMsgInc, aFuncs )

	Local aArea	   := GetArea() // Salva a �rea
	Local oModel   := IIf( lMDTA090, FWModelActive(), Nil )
	Local cTpDesc  := SuperGetMv( "MV_NG2TDES", .F., "1" )
	Local lGetTar  := .T.
	Local cTxtMemo := ""
	Local aTarFun  := {}
	Local aGPEA180 := {}
	Local nCont	   := 0
	Local nCont2   := 0

	//----------------------------------------------
	// Caso o par�metro for definido como 1- Tarefa
	//----------------------------------------------
	If cTpDesc == "1"

		//---------------------------------------------------------------------------
		// Percorre os funcion�rios para validar se est�o vinculados a alguma tarefa
		//---------------------------------------------------------------------------
		For nCont := 1 To Len( aFuncs )

			//Caso for transfer�ncia de funcion�rio
			If lGPEA180
			
				//Salva as informa��es da transfer�ncia
				aGPEA180 := aFuncs[ nCont, 7 ]

				//Verifica se � transfer�ncia de empresa ou filial, caso for n�o deve buscar as tarefas pois n�o tem como o funcion�rio 
				//ter tarefa na empresa ou filial destino antes da transfer�ncia
				lGetTar := aGPEA180[ 1, 2 ] == aGPEA180[ 1, 3 ] .And. aGPEA180[ 1, 4 ] == aGPEA180[ 1, 5 ]

			EndIf

			//Caso deva buscar as tarefas do funcion�rio
			If lGetTar

				//Se for chamado pelo MDTA090 e n�o for exclus�o, pega as tarefas diretamente da Grid
				If lMDTA090 .And. oModel:GetOperation() <> 5
					oGridTN6 := oModel:GetModel( "TN6GRID" )

					For nCont2 := 1 To oGridTN6:Length()
						oGridTN6:GoLine( nCont2 )
						If oGridTN6:GetValue( "TN6_MAT" ) == aFuncs[ nCont, 1 ] .And. !oGridTN6:IsDeleted()
							aAdd( aTarFun, { oModel:GetValue( "TN5MASTER", "TN5_CODTAR" ) } )
							Exit
						EndIf
					Next nCont2
				EndIf

				//Caso n�o tenha nenhuma atividade vinculada na grid ao funcion�rio, verifica em toda a TN6
				If Len( aTarFun ) == 0
					dbSelectArea( "TN6" )
					dbSetOrder( 2 )
					If dbSeek( xFilial( "TN6" ) + aFuncs[ nCont, 1 ] )
						While TN6->( !Eof() ) .And. TN6->TN6_FILIAL == xFilial( "TN6" ) .And. TN6->TN6_MAT == aFuncs[ nCont, 1 ]
							If !lMDTA090 .Or. ( TN6->TN6_CODTAR <> oModel:GetValue( "TN5MASTER", "TN5_CODTAR" ) )
								aAdd( aTarFun, { TN6->TN6_CODTAR } )
								Exit
							EndIf
							TN6->( dbSkip() )
						End
					EndIf
				EndIf

			EndIf

			//Caso n�o exista nenhuma tarefa vinculada ao funcion�rio, add no array
			If Len( aTarFun ) == 0
				cTxtMemo += STR0024 + ": " + AllTrim( aFuncs[ nCont, 1 ] ) + " - " + AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_NOME" ) ) + CRLF //Funcion�rio
			EndIf

			//Zera o array para validar o pr�ximo funcion�rio
			aTarFun := {}

		Next nCont

		//--------------------------------------------------------
		// Caso existir funcion�rios sem tarefa, exibe a mensagem
		//--------------------------------------------------------
		If !Empty( cTxtMemo )
			
			// Caso n�o for execu��o autom�tica mostra a mensagem
			If !lExecAuto
				MDTMEMOLINK( STR0080, STR0079, "https://tdn.totvs.com/x/o0ebJg", cTxtMemo ) //"Funcion�rios sem tarefa"##"O par�metro MV_NG2TDES est� definido como '1- Tarefa' e os funcion�rios abaixo est�o sem tarefa. Para saber sobre como proceder em cada situa��o de funcion�rio sem tarefa clique no bot�o 'Abrir'."
			Else
				//Adiciona as informa��es na vari�vel de retorno
				cMsgInc += STR0079 + CRLF
				cMsgInc += "https://tdn.totvs.com/x/o0ebJg" + CRLF
				cMsgInc += cTxtMemo + CRLF
			EndIf

		EndIf
	EndIf

	//Retorna a �rea
	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldAmbFun
Verifica se os funcion�rios passados por par�metro est�o vinculados
a algum ambiente

@return	Nil, Nulo

@param	cMsgInc, Caracter, Vari�vel que grava as inconsist�ncias (caso houver)
@param	aFuncs, Array, Array contendo as informa��es dos funcion�rios para valida��o
@param	nOper, Num�rico, Indica a opera��o que est� sendo realizada (3-Inclus�o/4-Altera��o/5-Exclus�o)

@sample	fVldAmbFun( "", { { "000230" } }, 3 )

@author	Luis Fellipy Bett
@since	11/11/2021
/*/
//-------------------------------------------------------------------
Static Function fVldAmbFun( cMsgInc, aFuncs, nOper )

	Local aArea	   := GetArea() //Salva a �rea
	Local cEntAmb  := SuperGetMv( "MV_NG2EAMB", .F., "1" ) //Indica qual entidade ser� considerada no relacionamento com o ambiente
	Local lTOT	   := AliasInDic( "TOT" ) //Ambiente x Tarefa
	Local lTOU	   := AliasInDic( "TOU" ) //Ambiente x Funcion�rio
	Local dDataEnv := SToD( "" )
	Local dDtAtu   := SToD( "" )
	Local lExsTar  := .F.
	Local lGetRegs := .T.
	Local cTxtMemo := ""
	Local cMsg1	   := ""
	Local cMsg2	   := ""
	Local cLink	   := ""
	Local aTarefas := {}
	Local aGPEA180 := {}
	Local nCont	   := 0
	Local nTar	   := 0

	//-----------------------------------------------------------
	// Caso o v�nculo do ambiente seja por tarefa ou funcion�rio
	//-----------------------------------------------------------
	If ( cEntAmb == "4" .And. lTOT ) .Or. ( cEntAmb == "5" .And. lTOU )

		//Percorre os funcion�rios passados por par�metro
		For nCont := 1 To Len( aFuncs )

			//Caso for transfer�ncia de funcion�rio
			If lGPEA180

				//Salva as informa��es da transfer�ncia
				aGPEA180 := aFuncs[ nCont, 7 ]

				//Verifica se � transfer�ncia de empresa ou filial, caso for n�o deve buscar as informa��es pois n�o tem como o
				//funcion�rio ter tarefa ou estar relacionado a um ambiente na empresa ou filial destino antes da transfer�ncia
				lGetRegs := aGPEA180[ 1, 2 ] == aGPEA180[ 1, 3 ] .And. aGPEA180[ 1, 4 ] == aGPEA180[ 1, 5 ]

			EndIf

			//Caso o sistema deve buscar os registros para validar
			If lGetRegs

				//Caso for vinculo de ambiente por tarefa e n�o seja cadastro de tarefas (se for deve
				// haver alguma tarefa vinculada e isso ser� validado no relat�rio de inconsist�ncias)
				If cEntAmb == "4" .And. !lMDTA090

					//Busca a data de exposi��o atual do evento S-2240
					dDtAtu := MDTDtExpAtu( aFuncs[ nCont, 1 ] )

					//Busca a data de envio a ser considerada no envio do evento S-2240
					dDataEnv := MDTBscDtEnv( aFuncs[ nCont ], nOper, , dDtAtu )

					//Busca as tarefas que o funcion�rio realiza
					aTarefas := MDTGetTar( aFuncs[ nCont, 1 ], dDataEnv )

					dbSelectArea( "TOT" )
					dbSetOrder( 2 )
					For nTar := 1 To Len( aTarefas )

						//Caso encontre uma tarefa do funcion�rio vinculada a um ambiente
						If dbSeek( xFilial( "TOT" ) + aTarefas[ nTar, 1 ] )

							lExsTar := .T.
							Exit

						EndIf

					Next nTar

					//Caso n�o existirem tarefas vinculadas ao funcion�rio
					If !lExsTar
						cTxtMemo += STR0024 + ": " + AllTrim( aFuncs[ nCont, 1 ] ) + " - " + AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_NOME" ) ) + CRLF //Funcion�rio
					EndIf

					//Define a vari�vel como .F. para validar o pr�ximo funcion�rio do la�o
					lExsTar := .F.

				ElseIf cEntAmb == "5" .And. !lMDTA165 //Caso for vinculo de ambiente por funcion�rio

					dbSelectArea( "TOU" )
					dbSetOrder( 2 )
					If !dbSeek( xFilial( "TOU" ) + aFuncs[ nCont, 1 ] )
						cTxtMemo += STR0024 + ": " + AllTrim( aFuncs[ nCont, 1 ] ) + " - " + AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_NOME" ) ) + CRLF //Funcion�rio
					EndIf

				EndIf

			Else

				cTxtMemo += STR0024 + ": " + AllTrim( aFuncs[ nCont, 1 ] ) + " - " + AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_NOME" ) ) + CRLF //Funcion�rio

			EndIf

		Next nCont

		//----------------------------------------------------------
		// Caso existir funcion�rios sem ambiente, exibe a mensagem
		//----------------------------------------------------------
		If !Empty( cTxtMemo )

			//Define as mensagens de acordo com o valor do par�metro MV_NG2EAMB
			If cEntAmb == "4" //Caso for vinculo de ambiente por tarefa

				cMsg1 := STR0094 //"Funcion�rios sem tarefa vinculada a um ambiente"
				cMsg2 := STR0095 //"O par�metro MV_NG2EAMB est� definido como '4- Tarefa' e os funcion�rios abaixo est�o sem nenhuma tarefa vinculada a um ambiente. Para saber sobre como proceder em cada situa��o de funcion�rio sem tarefa vinculada a um ambiente clique no bot�o 'Abrir'."
				cLink := "https://tdn.totvs.com/x/s1ByK"

			ElseIf cEntAmb == "5" //Caso for vinculo de ambiente por funcion�rio

				cMsg1 := STR0085 //"Funcion�rios sem ambiente vinculado"
				cMsg2 := STR0086 //"O par�metro MV_NG2EAMB est� definido como '5- Funcion�rio' e os funcion�rios abaixo est�o sem ambiente vinculado. Para saber sobre como proceder em cada situa��o de funcion�rio sem ambiente clique no bot�o 'Abrir'."
				cLink := "https://tdn.totvs.com/x/8rXFJg"

			EndIf

			//Caso n�o for execu��o autom�tica mostra a mensagem
			If !lExecAuto
				MDTMEMOLINK( cMsg1, cMsg2, cLink, cTxtMemo )
			Else
				//Adiciona as informa��es na vari�vel de retorno
				cMsgInc += cMsg2 + CRLF
				cMsgInc += cLink + CRLF
				cMsgInc += cTxtMemo + CRLF
			EndIf

		EndIf

	EndIf

	//Retorna a �rea
	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldAdmFut
Verifica se os funcion�rios passados por par�metro s�o admiss�es
futuras.

@author	Gabriel Sokacheski
@since	12/11/2021

@param cMsgInc, Caracter, Grava as inconsist�ncias (caso houver)
@param aFuncs, Array, Cont�m as informa��es dos funcion�rios para valida��o

/*/
//-------------------------------------------------------------------
Static Function fVldAdmFut( cMsgInc, aFuncs )

	Local aArea	   := GetArea() //Salva a �rea
	Local dDtEnv   := dDataBase
	Local cTxtMemo := ""
	Local nCont	   := 0

	//--------------------------------------------------------------------------------
	// Percorre os funcion�rios para validar se � admiss�o futura com mais de 30 dias
	//--------------------------------------------------------------------------------
	For nCont := 1 To Len( aFuncs )

		dDtEnv := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_ADMISSA" )

		If dDtEnv > ( dDataBase + 30 )
			cTxtMemo += STR0024 + ": " + AllTrim( aFuncs[ nCont, 1 ] ) + " - " + AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_NOME" ) ) + CRLF //Funcion�rio
		EndIf

	Next nCont

	//-----------------------------------------------------------------
	// Caso existir funcion�rios por admiss�o futura, exibe a mensagem
	//-----------------------------------------------------------------
	If !Empty( cTxtMemo )
		
		//Caso n�o for execu��o autom�tica mostra a mensagem
		If !lExecAuto
			//"Funcion�rios por admiss�o futura"##"Os funcion�rios possuem admiss�o futura com data superior � 30 dias da data atual."
			MDTMEMOLINK( STR0083, STR0084 + Space( 1 ) + STR0082, "https://tdn.totvs.com/x/11q_Jg", cTxtMemo )
		Else
			//Adiciona as informa��es na vari�vel de retorno
			cMsgInc += STR0084 + Space( 1 ) + STR0082 + CRLF
			cMsgInc += "https://tdn.totvs.com/x/11q_Jg" + CRLF
			cMsgInc += cTxtMemo + CRLF
		EndIf

	EndIf

	//Retorna a �rea
	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldEPIFun
Verifica se existem EPI's entregues ao funcion�rio quando o risco est�
definido como necessita EPI (TN0_NECEPI)

@return	Nil, Nulo

@param	cMsgInc, Caracter, Vari�vel que grava as inconsist�ncias (caso houver)
@param	aFuncs, Array, Array contendo as informa��es dos funcion�rios para valida��o
@param	nOper, Num�rico, Indica a opera��o que est� sendo realizada (3-Inclus�o/4-Altera��o/5-Exclus�o)

@sample	fVldEPIFun( "", { { "000230" } }, 4 )

@author	Luis Fellipy Bett
@since	29/11/2021
/*/
//-------------------------------------------------------------------
Static Function fVldEPIFun( cMsgInc, aFuncs, nOper )

	//Vari�veis de controle de troca de empresa, quando transfer�ncia de empresa
	Local aAreaBkp := GetArea()
	Local cEmpBkp  := cEmpAnt
	Local cFilBkp  := cFilAnt
	Local cArqBkp  := cArqTab

	//Vari�veis de controle de tabelas na troca de empresa, quando transfer�ncia de empresa
	Local aAreaTN6 := TN6->( GetArea() )
	Local aAreaTN0 := TN0->( GetArea() )
	Local aAreaTMA := TMA->( GetArea() )
	Local aAreaTO0 := TO0->( GetArea() )
	Local aAreaTO1 := TO1->( GetArea() )
	
	//Vari�vel das tabelas a serem abertas
	Local aTbls := { "TN6", "TN0", "TMA", "TO0", "TO1" }
	
	//Vari�veis para busca das informa��es
	Local dDtAtu   := SToD( "" )
	Local dDataEnv := SToD( "" )
	Local lGetEPI  := .T.
	Local aRisExp  := {}
	Local aEPITNX  := {}
	Local aEPINec  := {}
	Local aEPIEnt  := {}
	Local aRisEnt  := {}
	Local aGPEA180 := {}
	Local cTxtMemo := ""
	Local cTxtAux  := ""
	Local cRiscos  := "%"
	Local cVirgula := ", "
	Local nFun	   := 0
	Local nCont	   := 0

	//Vari�veis dos alias
	Local cAliasTNX := ""
	Local cAliasTNF := ""

	//Vari�vel private utilizada na fun��o MDTVldRis para busca
	Private lVldEPI := .F.

	//Vari�veis private para utiliza��o na transfer�ncia
	Private cCCustoAnt := ""
	Private cDeptoAnt  := ""
	Private cFuncaoAnt := ""
	Private cCargoAnt  := ""

	//Define a r�gua de processamento
	ProcRegua( Len( aFuncs ) )

	//----------------------------------------------------------------------------------------------------------------
	// Percorre os funcion�rios para validar se est�o expostos a risco que necessitam de EPI e est�o sem EPI entregue
	//----------------------------------------------------------------------------------------------------------------
	For nFun := 1 To Len( aFuncs )

		//Incrementa a r�gua de proecessamento
		IncProc()

		//Seta a vari�vel para .F. para buscar todos os riscos a que o funcion�rio est� exposto no escopo da fun��o MDTBscDtEnv
		lVldEPI := .F.

		//Busca a data de exposi��o atual do evento S-2240
		dDtAtu := MDTDtExpAtu( aFuncs[ nFun, 1 ] )

		//Busca a data de envio a ser considerada no envio do evento S-2240
		dDataEnv := MDTBscDtEnv( aFuncs[ nFun ], nOper, , dDtAtu )

		//Seta a vari�vel para .T. para buscar apenas os riscos que necessitam de utiliza��o de EPI
		lVldEPI := .T.

		dbSelectArea( "SRA" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "SRA" ) + aFuncs[ nFun, 1 ] )

		//Caso for transfer�ncia de funcion�rio
		If lGPEA180

			//Busca as informa��es da transfer�ncia
			aGPEA180 := aFuncs[ nFun, 7 ]

			//Verifica se � transfer�ncia de empresa ou filial, caso for n�o deve buscar os EPI's pois n�o tem como o funcion�rio 
			//ter EPI entregue na empresa ou filial destino antes da transfer�ncia
			lGetEPI := aGPEA180[ 1, 2 ] == aGPEA180[ 1, 3 ] .And. aGPEA180[ 1, 4 ] == aGPEA180[ 1, 5 ]

			//Salva as informa��es da filial de origem
			cCCustoAnt := SRA->RA_CC
			cDeptoAnt  := SRA->RA_DEPTO
			cFuncaoAnt := SRA->RA_CODFUNC
			cCargoAnt  := SRA->RA_CARGO

			MDTChgSRA( .T., aGPEA180 )

			//Caso a empresa destino seja diferente da empresa atual
			If cEmpAnt <> aGPEA180[ 1, 3 ]

				//Caso Middleware, posiciona a SM0 na empresa destino
				If lMiddleware

					MDTPosSM0( aGPEA180[ 1, 3 ], aGPEA180[ 1, 5 ] )

				EndIf

				//Abre as tabelas na empresa destino
				MDTChgEmp( aTbls, cEmpAnt, aGPEA180[ 1, 3 ] )

				//Posiciona na empresa destino
				cEmpAnt := aGPEA180[ 1, 3 ]

			EndIf

			//Posiciona na filial destino
			cFilAnt := aGPEA180[ 1, 5 ]

		EndIf

		//Busca riscos expostos
		aRisExp := MDTRis2240( dDataEnv )

		//Caso for chamada pelo GPEA180, altera a empresa e filial para a atual ap�s ter buscado as informa��es
		If lGPEA180

			//Caso a empresa destino seja diferente da empresa atual
			If cEmpAnt <> cEmpBkp

				//Caso Middleware, posiciona a SM0 na filial logada novamente
				If lMiddleware

					MDTPosSM0( cEmpBkp, cFilBkp )

				EndIf

				//Abre as tabelas na empresa logada novamente
				MDTChgEmp( aTbls, aGPEA180[ 1, 3 ], cEmpBkp )
				
				//Posiciona na empresa logada novamente
				cEmpAnt := cEmpBkp

			EndIf

			//Posiciona na filial logada novamente
			cFilAnt := cFilBkp

		EndIf

		//Caso for chamada pelo GPEA180, volta o valor dos campos
		If lGPEA180
			MDTChgSRA( .F., aGPEA180 )
		EndIf

		//Caso for cadastro de Risco, adiciona as informa��es da mem�ria
		If lMDTA180 .And. aScan( aRisExp, { |x| x[1] == M->TN0_NUMRIS } ) == 0 .And. MdtVldRis( dDataEnv, .T. )
			aAdd( aRisExp, { M->TN0_NUMRIS } )
		EndIf

		//Caso deva buscar as informa��es dos EPI's
		If lGetEPI

			//--------------------------------------------------------------------------
			// Busca os EPI's necess�rios para os riscos a que o funcion�rio t� exposto
			//--------------------------------------------------------------------------
			//Adiciona os riscos na vari�vel para busca na query
			For nCont := 1 To Len( aRisExp )

				If nCont == Len( aRisExp )
					cVirgula := ""
				EndIf

				cRiscos += "'" + aRisExp[ nCont, 1 ] + "'" + cVirgula

			Next nCont

			//Finaliza a vari�vel com o '%' para executar corretamente na query
			cRiscos += "%"

			//Caso existam riscos a serem validados
			If cRiscos != "%%"

				cAliasTNX := GetNextAlias() //Pega o pr�ximo alias

				BeginSQL Alias cAliasTNX
					SELECT TNX.TNX_NUMRIS, TNX.TNX_EPI
						FROM %Table:TNX% TNX
						WHERE TNX.TNX_FILIAL = %xFilial:TNX% AND
								TNX.TNX_NUMRIS IN ( %Exp:cRiscos% ) AND
								TNX.%NotDel%
				EndSQL

				//Posiciona na tabela para adicionar os registros no array
				dbSelectArea( cAliasTNX )
				( cAliasTNX )->( dbGoTop() )
				While ( cAliasTNX )->( !Eof() )

					//Adiciona as informa��es no array
					aAdd( aEPITNX, { ( cAliasTNX )->TNX_NUMRIS, ( cAliasTNX )->TNX_EPI } )
				
					( cAliasTNX )->( dbSkip() )

				End

				//Exclui a tabela
				( cAliasTNX )->( dbCloseArea() )

			EndIf

			//--------------------------------------------------
			// Trata os EPI's verificando se s�o pais ou filhos
			//--------------------------------------------------
			dbSelectArea( "TL0" )
			dbSetOrder( 1 )
			For nCont := 1 To Len( aEPITNX )

				//Caso o EPI seja um EPI pai busca os filhos
				If dbSeek( xFilial( "TL0" ) + aEPITNX[ nCont, 2 ] )

					While TL0->( !Eof() ) .And. TL0->TL0_FILIAL == xFilial( "TL0" ) .And. TL0->TL0_EPIGEN == aEPITNX[ nCont, 2 ]

						aAdd( aEPINec, { aEPITNX[ nCont, 1 ], TL0->TL0_EPIFIL } )

						TL0->( dbSkip() )

					End

				Else //Sen�o adiciona o pr�prio EPI filho

					aAdd( aEPINec, { aEPITNX[ nCont, 1 ], aEPITNX[ nCont, 2 ] } )

				EndIf

			Next nCont

			//--------------------------------------------
			// Busca os EPI's j� entregues ao funcion�rio
			//--------------------------------------------
			cAliasTNF := GetNextAlias() //Pega o pr�ximo alias
			
			BeginSQL Alias cAliasTNF
				SELECT TNF.TNF_CODEPI
					FROM %Table:TNF% TNF
					WHERE TNF.TNF_FILIAL = %xFilial:TNF% AND
							TNF.TNF_MAT = %Exp:aFuncs[ nFun, 1 ]% AND
							TNF.%NotDel%
			EndSQL

			//Posiciona na tabela para adicionar os registros no array
			dbSelectArea( cAliasTNF )
			( cAliasTNF )->( dbGoTop() )
			While ( cAliasTNF )->( !Eof() )

				If aScan( aEPIEnt, { |x| x[ 1 ] == ( cAliasTNF )->TNF_CODEPI } ) == 0

					aAdd( aEPIEnt, { ( cAliasTNF )->TNF_CODEPI } )

				EndIf

				( cAliasTNF )->( dbSkip() )

			End

			//Exclui a tabela
			( cAliasTNF )->( dbCloseArea() )

			//-----------------------------------------------------------------------------------------------------
			// Verifica se algum dos EPI's necess�rios ao riscos a que o funcion�rio est� exposto j� est� entregue
			//-----------------------------------------------------------------------------------------------------
			//Caso existam EPI's entregues para o funcion�rio, verifica se j� existe EPI entregue pra cada um dos riscos a que ele est� exposto
			If Len( aEPIEnt ) > 0
			
				For nCont := 1 To Len( aEPINec )

					If aScan( aEPIEnt, { |x| x[ 1 ] == aEPINec[ nCont, 2 ] } ) > 0

						//Salvo o risco que j� tem EPI entregue
						If aScan( aRisEnt, { |x| x[ 1 ] == aEPINec[ nCont, 1 ] } ) == 0
						
							aAdd( aRisEnt, { aEPINec[ nCont, 1 ] } )

						EndIf

					EndIf

				Next nCont

			EndIf

		EndIf

		//Percorre os riscos verificando se algum est� sem EPI entregue, se tiver imprime na mensagem
		For nCont := 1 To Len( aRisExp )

			If aScan( aRisEnt, { |x| x[ 1 ] == aRisExp[ nCont, 1 ] } ) == 0

				cTxtAux += STR0024 + ; //Funcion�rio
						": " + ;
						AllTrim( aFuncs[ nFun, 1 ] ) + ;
						" - " + ;
						AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nFun, 1 ], "RA_NOME" ) ) + ;
						" / " + ;
						STR0087 + ; //Risco
						": " + ;
						AllTrim( aRisExp[ nCont, 1 ] ) + ;
						CRLF

			EndIf

		Next nCont

		//Passa a string do funcion�rio para a string a ser impressa
		cTxtMemo += cTxtAux

		//Zera as vari�veis para validar o pr�ximo funcion�rio do array
		cRiscos	 := "%"
		cVirgula := ", "
		cTxtAux	 := ""
		aEPITNX	 := {}
		aEPINec	 := {}
		aEPIEnt	 := {}
		aRisEnt	 := {}

	Next nFun

	//-----------------------------------------------------------------------------------------------------------
	// Caso existir riscos que necessitam de EPI e esse EPI n�o esteja entregue ao funcion�rio, exibe a mensagem
	//-----------------------------------------------------------------------------------------------------------
	If !Empty( cTxtMemo )
		
		//Caso n�o for execu��o autom�tica mostra a mensagem
		If !lExecAuto
			//"Funcion�rios sem EPI entregue para os riscos"##"Os funcion�rios abaixo n�o possuem pelo menos um EPI entregue para os riscos informados e os riscos est�o definidos com necessidade de EPI (TN0_NECEPI = Sim). Para saber sobre como proceder em cada situa��o de funcion�rio sem EPI entregue para os riscos com necessidade de EPI clique no bot�o 'Abrir'."
			MDTMEMOLINK( STR0088, STR0089, "https://tdn.totvs.com/x/stXaJw", cTxtMemo )
		Else
			//Adiciona as informa��es na vari�vel de retorno
			cMsgInc += STR0089 + CRLF //"Os funcion�rios abaixo n�o possuem pelo menos um EPI entregue para os riscos informados e os riscos est�o definidos com necessidade de EPI (TN0_NECEPI = Sim). Para saber sobre como proceder em cada situa��o de funcion�rio sem EPI entregue para os riscos com necessidade de EPI clique no bot�o 'Abrir'."
			cMsgInc += "https://tdn.totvs.com/x/stXaJw" + CRLF
			cMsgInc += cTxtMemo + CRLF
		EndIf

	EndIf

	//Reposiciona as tabelas na filial logada
	RestArea( aAreaTN6 )
	RestArea( aAreaTN0 )
	RestArea( aAreaTMA )
	RestArea( aAreaTO0 )
	RestArea( aAreaTO1 )

	//Retorna as informa��es da empresa e filial logada
	cEmpAnt := cEmpBkp
	cFilAnt := cFilBkp
	cArqTab := cArqBkp
	
	//Retorna a �rea posicionada
	RestArea( aAreaBkp )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldEPIRis
Verifica se os EPI's entregues ao funcion�rio est�o vinculados ao risco
que o funcion�rio est� exposto

@return	lRet, L�gico, controla o envio ou n�o do evento

@param	cMsgInc, Caracter, Vari�vel que grava as inconsist�ncias (caso houver)
@param	aFuncs, Array, Array contendo as informa��es dos funcion�rios para valida��o
@param	lValida, L�gico, Informa se deve realizar a valida��o das informa��es

@sample	fVldEPIRis( "", { { "000230" } } )

@author	Luis Fellipy Bett
@since	20/07/2021
/*/
//-------------------------------------------------------------------
Static Function fVldEPIRis( cMsgInc, aFuncs, lValida )

	Local aArea	   	 := GetArea()
	Local aEpiRis    := {} // EPI's necess�rios do risco
	Local aEpiEntFil := {} // EPI's entregues com c�digo do EPI filho
	Local aEpiEntPai := {} // EPI's entregues com c�digo do EPI gen�rico
	Local aRiscos    := {} // Riscos que o funcion�rio est� exposto
	Local aEpiEnv    := {} // EPI's do funcion�rio j� comunicados

	Local cTxtMemo := ""

	Local dDtAux := SToD( "" )

	Local lRet := .F.

	Local nEpi := 0 // EPI
	Local nFun := 0 // Funcion�rio
	Local nRis := 0 // Risco

	//------------------------------------------------------
	// Percorre todos os funcion�rios para validar os EPI's
	//------------------------------------------------------

	For nFun := 1 To Len( aFuncs )

		dbSelectArea( "SRA" )
		dbSetOrder( 1 )

		If dbSeek( xFilial( "SRA" ) + aFuncs[ nFun, 1 ] ) // Posiciona no funcion�rio em quest�o

			lRet := .F.

			aEpiEntFil := aFuncs[ nFun, 8 ] // EPI's entregues filho
			aEpiEntPai := aClone( aEpiEntFil ) // EPI's entregues pai

			//-------------------------------------------------------------------------
			// Se algum EPI for EPI gen�rico, troca o seu c�digo no array pelo EPI pai
			//-------------------------------------------------------------------------

			dbSelectArea( "TL0" )
			dbSetOrder( 2 )

			For nEpi := 1 To Len( aEpiEntPai )

				If dbSeek( xFilial( "TL0" ) + aEpiEntPai[ nEpi, 1 ] )

					aEpiEntPai[ nEpi, 1 ] := TL0->TL0_EPIGEN

				EndIf

			Next nEpi

			//---------------------------------------
			// Busca a �ltima data de entrega do EPI
			//---------------------------------------

			For nEpi := 1 To Len( aEpiEntFil )

				If dDtAux < aEpiEntFil[ nEpi, 2 ]

					dDtAux := aEpiEntFil[ nEpi, 2 ]

				EndIf

			Next nEpi

			aEpiEnv := fEpiEnv( aFuncs[ nFun, 1 ] ) // EPI's comunicados
			aRiscos := MDTRis2240( dDtAux ) // Busca os riscos a que o funcion�rio est� exposto

			//---------------------------------------------------
			// Verifica se o funcion�rio est� exposto a um risco
			//---------------------------------------------------

			If Len( aRiscos ) > 0 // Caso o funcion�rio esteja exposto a algum risco

				dbSelectArea( "TNX" )
				dbSetOrder( 2 )

				//-------------------------------------------------
				// Monta o array com os EPI's necess�rios do risco
				//-------------------------------------------------

				For nRis := 1 To Len( aRiscos )

					If dbSeek( xFilial( "TNX" ) + aRiscos[ nRis, 1 ] )

						While TNX->( !Eof() ) .And. TNX->TNX_FILIAL == xFilial( "TNX" ) .And. TNX->TNX_NUMRIS == aRiscos[ nRis, 1 ]

							If aScan( aEpiRis, { |x| x[1] == TNX->TNX_EPI } ) == 0

								aAdd( aEpiRis, { TNX->TNX_EPI } )

							EndIf

							TNX->( dbSkip() )

						End

					EndIf

				Next nRis

				For nEpi := 1 To Len( aEpiEntPai )

					//-----------------------------------------
					// Avisa quais EPI's n�o ser�o comunicados
					//-----------------------------------------

					If aScan( aEpiRis, { |x| x[1] == aEpiEntPai[ nEpi, 1 ] } ) == 0

						cTxtMemo += STR0078 +; // EPI
							": " +;
							AllTrim( aEpiEntFil[ nEpi, 1 ] ) +;
							" - " +;
							AllTrim( Posicione( "SB1", 1, xFilial( "SB1" ) + aEpiEntFil[ nEpi, 1 ], "B1_DESC" ) ) +;
							" / " +;
							STR0024 +; // Funcion�rio
							": " +;
							AllTrim( aFuncs[ nFun, 1 ] );
							+;
							" - ";
							+;
							AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nFun, 1 ], "RA_NOME" ) ) +;
							CRLF

					ElseIf !lRet

						//--------------------------------------------------------------------------------------
						// Verifica se h� pelo menos um EPI entregue que n�o foi comunicado para gerar o evento
						//--------------------------------------------------------------------------------------

						If ( Len( aEpiEnv ) == 0 .Or. aScan( aEpiEnv, { | x | x == AllTrim( aEpiEntPai[ nEpi, 7 ] ) } ) == 0 )

							lRet := .T.

						EndIf

					EndIf

				Next nEpi

			Else // Caso o funcion�rio n�o esteja exposto a nenhum risco

				lRet := .F.
				Exit

			EndIf

		EndIf

	Next nFun

	//-------------------------------------------
	// Caso existam EPI's que n�o ser�o enviados
	//-------------------------------------------

	If !Empty( cTxtMemo ) .And. lValida
		
		// Caso n�o for execu��o autom�tica mostra a mensagem
		If !lExecAuto

			MDTMEMOLINK( STR0081, STR0077, "https://tdn.totvs.com/x/PkCbJg", cTxtMemo ) // "EPI's n�o enviados"##"Os EPI's abaixo n�o foram comunicados ao SIGATAF/Middleware. Para saber mais sobre os motivos pelo qual um EPI n�o � enviado clique no bot�o 'Abrir'."

		Else

			// Adiciona as informa��es na vari�vel de retorno
			cMsgInc += STR0077 + CRLF
			cMsgInc += "https://tdn.totvs.com/x/PkCbJg" + CRLF
			cMsgInc += cTxtMemo + CRLF

		EndIf

	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fPosFil
Fun��o gen�rica para posicionamento de filial em algumas chamadas espec�ficas

@return	Nil, Nulo

@param	cEvento, Caracter, Nome do evento que est� sendo processado
@param	cFilFun, Caracter, Filial do funcion�rio

@sample	fPosFil( "S-2220", "D MG 02 " )

@author	Luis Fellipy Bett
@since	13/09/2021
/*/
//-------------------------------------------------------------------
Static Function fPosFil( cEvento, cFilFun )

	Local lMDTA410 := IsInCallStack( "MDTA410" ) //Caso for chamado pelo prontu�rio m�dico
	Local lMDTA200 := IsInCallStack( "MDTA200" ) //Caso for chamado pelo atestado ASO

	Default cFilFun := ""

	If cEvento == "S-2220" .And. ( lMDTA410 .Or. lMDTA200 ) //Caso for chamado pelo prontu�rio m�dico ou atestado ASO e seja envio do S-2220, posiciona na filial da ficha m�dica
		cFilAnt := TM0->TM0_FILFUN
	ElseIf !Empty( cFilFun ) .And. ( ( lMDTA881 .Or. lMDTA882 ) .Or. ( cEvento == "S-2240" .And. lMDTA180 ) ) //Caso for carga inicial ou schedule de tarefas ou for cadastro de risco
		cFilAnt := cFilFun //Posiciona na filial do funcion�rio para valida��o
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVincCAT
Verifica se a CAT est� vinculada a um atestado ou diagn�stico

@return	lVinc, Boolean, .T. caso o acidente esteja vinculado a um atestado ou diagn�stico

@param	oModelTNC, Objeto, Objeto do cadastro de acidentes

@sample	fVincCAT( oModelTNC )

@author	Luis Fellipy Bett
@since	16/09/2021
/*/
//-------------------------------------------------------------------
Static Function fVincCAT( oModelTNC )

	//Salva a �rea
	Local aArea := GetArea()
	
	//Vari�veis para busca das informa��es
	Local cAcidente	:= oModelTNC:GetValue( "TNCMASTER", "TNC_ACIDEN" )
	Local cNumFic	:= oModelTNC:GetValue( "TNCMASTER", "TNC_NUMFIC" )
	Local cDtAcid	:= oModelTNC:GetValue( "TNCMASTER", "TNC_DTACID" )
	Local cHrAcid	:= oModelTNC:GetValue( "TNCMASTER", "TNC_HRACID" )
	Local cTipoCAT	:= oModelTNC:GetValue( "TNCMASTER", "TNC_TIPCAT" )
	Local lVinc := .F.

	//Caso for uma CAT de reabertura ou �bito, busca o acidente inicial
	If cTipoCAT $ "2/3"

		//Busca a CAT inicial
		cAcidente := MDTCatIni( cNumFic, cDtAcid, cHrAcid )

	EndIf

	//--------------------------------------------------------
	// Verifica se o acidente est� vinculado a um diagn�stico
	//--------------------------------------------------------
	If cAtendAci == "1" .Or. cAtendAci == "3"
		dbSelectArea( "TMT" )
		dbSetOrder( 7 )
		If dbSeek( xFilial( "TMT" ) + cAcidente )
			lVinc := .T.
		EndIf
	EndIf

	//-----------------------------------------------------
	// Verifica se o acidente est� vinculado a um atestado
	//-----------------------------------------------------
	If !lVinc .And. ( cAtendAci == "2" .Or. cAtendAci == "3" )
		dbSelectArea( "TNY" )
		dbSetOrder( 5 )
		If dbSeek( xFilial( "TNY" ) + cAcidente )
			lVinc := .T.
		EndIf
	EndIf
	
	//Retorna a �rea
	RestArea( aArea )

Return lVinc

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetMatFic
Busca a matr�cula das fichas m�dicas passadas por par�metro

@return	aFuncs, Array, Array contendo as matr�culas dos funcion�rios

@param	aFichas, Array, Array contendo as fichas m�dicas

@sample	fGetMatFic( { { "000023" } } )

@author	Luis Fellipy Bett
@since	11/10/2021
/*/
//-------------------------------------------------------------------
Static Function fGetMatFic( aFichas )

	Local aArea	 := GetArea() //Salva a �rea
	Local cMat	 := ""
	Local aFuncs := {}
	Local nCont	 := 0

	For nCont := 1 To Len( aFichas )
		
		//Busca a matr�cula relacionada � ficha m�dica
		cMat := Posicione( "TM0", 1, xFilial( "TM0" ) + aFichas[ nCont, 1 ], "TM0_MAT" )

		//Caso exista matr�cula relacionada � ficha, ou seja, n�o seja ficha m�dica de um candidato
		If !Empty( cMat )
			aAdd( aFuncs, { cMat, , , , , , , , aFichas[ nCont, 2 ] } ) //Adiciona a chave do ASO na 9� posi��o pois as outras j� est�o sendo utilizadas
		EndIf

	Next nCont

	RestArea( aArea ) //Retorna a �rea

Return aFuncs

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTRis2240
Busca os riscos a que o funcion�rio est� exposto

@return	aRiscos, Array, Array contendo os riscos a que o funcion�rio est� exposto

@param	dDtRis, Data, Data a ser considerada na busca dos riscos

@sample	MDTRis2240( 13/10/2021 )

@author	Luis Fellipy Bett
@since	02/11/2021
/*/
//-------------------------------------------------------------------
Function MDTRis2240( dDtRis )

	Local aRiscos := {}
	Local cValRisco := '{ |dData| MdtVldRis( dData ) }'

	// Define por padr�o a data a ser considerado como sendo a database
	Default dDtRis := dDataBase

	// Busca os riscos a que o funcion�rio est� exposto quando n�o est� sendo demitido
	If !FWIsInCallStack( 'Gpem040' ) // Rescis�o
		aRiscos := MDTRetRis( dDtRis, , , , , , , .F., , , , cValRisco )[ 1 ]
	EndIf

Return aRiscos

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldEnvFun
Valida se o cadastro do funcion�rio vai gerar a retifica��o do S-2240

@return	lRetif, Boolean, .T. caso haja retifica��o, sen�o .F.

@sample	fVldEnvFun()

@author	Luis Fellipy Bett
@since	30/11/2021
/*/
//-------------------------------------------------------------------
Static Function fVldEnvFun()

	//Vari�veis para busca das informa��es
	Local cFuncAnt	:= ""
	Local cFuncAtu	:= GetMemVar( "RA_CODFUNC" )
	Local dDtDemiss	:= SRA->RA_DEMISSA
	Local lRetif	:= .F.

	//Caso as vari�veis existirem
	If Type( "aSraHeader" ) == "A" .And. Type( "aSvSraCols" ) == "A"

		//Pega a fun��o anterior
		cFuncAnt := GdFieldGet( "RA_CODFUNC", 1, .F., aSraHeader, aSvSraCols )

	EndIf

	//Caso o funcion�rio tenha sido demitido, alterado de fun��o ou registro do S-2240 n�o exista no SIGATAF/Middleware, gera o evento S-2240
	If !Empty( dDtDemiss ) .Or. ( !Empty( cFuncAnt ) .And. cFuncAnt <> cFuncAtu ) .Or. !MDTVld2240( SRA->RA_MAT )
		lRetif := .T.
	EndIf

Return lRetif

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTPosSM0
For�a o posicionamento na SM0

@return	Nil, Nulo

@param	cEmpAux, Caracter, Empresa a ser considerada no posicionamento da SM0
@param	cFilAux, Caracter, Filial a ser considerada no posicionamento da SM0

@sample	MDTPosSM0()

@author	Luis Fellipy Bett
@since	01/12/2021
/*/
//-------------------------------------------------------------------
Function MDTPosSM0( cEmpAux, cFilAux )

	//Posiciona na SM0
	SM0->( dbSetOrder( 1 ) )
	SM0->( dbSeek( cEmpAux + cFilAux ) )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fEpiEnv
Retorna os EPI's do funcion�rio que j� foram comunicados.

@author Gabriel Sokacheski
@since 20/12/2021

@param cMatricula, Caracter, matr�cula do funcion�rio.

@return	aEpi, Array, c�digos dos EPI's j� comunicados.
/*/
//-------------------------------------------------------------------
Static Function fEpiEnv( cMatricula )

	//Salva a �rea
	Local aArea := GetArea()

	//Vari�veis de tabelas tempor�rias
	Local cAliasV3D

	//Vari�veis de busca das informa��es
	Local cCPF := SRA->RA_CIC
	Local aEpi := {}

	//Caso for envio via SIGATAF (necess�rio realizar tratamento para envio via Middleware no Else)
	If !lMiddleware

		//Pega o pr�ximo alias
		cAliasV3D := GetNextAlias()

		//Monta a query para busca dos EPI's no TAF
		BeginSQL Alias cAliasV3D
			SELECT 
				V3D.V3D_DSCEPI
			FROM 
				%table:C9V% C9V
				INNER JOIN %table:CM9% CM9 ON 
					CM9.CM9_FILIAL = %xFilial:CM9%
					AND CM9.CM9_FUNC = C9V.C9V_ID
					AND CM9.%notDel%
				INNER JOIN %table:CMA% CMA ON 
					CMA.CMA_FILIAL = %xFilial:CMA%
					AND CMA.CMA_ID = CM9.CM9_ID
					AND CMA.CMA_VERSAO = CM9.CM9_VERSAO
					AND CMA.%notDel%
				INNER JOIN %table:CMB% CMB ON 
					CMB.CMB_FILIAL = %xFilial:CMB%
					AND CMB.CMB_ID = CMA.CMA_ID
					AND CMB.CMB_VERSAO = CMA.CMA_VERSAO
					AND CMB.CMB_CODAGE = CMA.CMA_CODAG
					AND CMB.%notDel%
				INNER JOIN %table:V3D% V3D ON 
					V3D.V3D_FILIAL = %xFilial:V3D%
					AND V3D.V3D_ID = CMB.CMB_DVAL
					AND V3D.%notDel%
			WHERE 
				C9V.C9V_FILIAL = %xFilial:C9V%
				AND C9V.C9V_CPF = %exp:cCPF%
				AND C9V.%notDel%
		EndSQL

		dbSelectArea( cAliasV3D )
		( cAliasV3D )->( dbGoTop() )

		While ( cAliasV3D )->( !EoF() ) // Monta array com os EPIs enviados

			aAdd( aEpi, AllTrim( ( cAliasV3D )->V3D_DSCEPI ) )

			( cAliasV3D )->( dbSkip() )

		End

		( cAliasV3D )->( dbCloseArea() )

	EndIf

	//Retorna a �rea
	RestArea( aArea )

Return aEpi

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldFunDem
Valida se o ASO � demissional quando o funcion�rio estiver demitido

@return	Nil, Nulo

@param	aFuncs, Array, Array contendo os funcion�rios a serem validados
@param	lImpASO, Boolean, Indica se � impress�o do ASO

@sample	fVldFunDem( { { "0000236" } }, .F. )

@author	Luis Fellipy Bett
@since	04/01/2022
/*/
//-------------------------------------------------------------------
Static Function fVldFunDem( aFuncs, lImpASO )
	
	Local aArea	   := GetArea() //Salva a �rea
	Local aAreaTMY := TMY->( GetArea() ) //Salva a �rea da TMY
	Local dDtDemis := SToD( "" )
	Local dDtASO   := SToD( "" )
	Local cSitFolh := ""
	Local cChvASO  := ""
	Local cNatASO  := ""
	Local aFunNao  := {}
	Local nCont	   := 0
	Local nPosReg  := 0

	//------------------------------------
	// Percorre os funcion�rios validando
	//------------------------------------
	For nCont := 1 To Len( aFuncs )

		//Busca as informa��es do funcion�rio
		dDtDemis := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_DEMISSA" )
		cSitFolh := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_SITFOLH" )

		//Busca a chave do ASO
		cChvASO := IIf( Len( aFuncs[ nCont ] ) > 8 .And. aFuncs[ nCont, 9 ] <> Nil, aFuncs[ nCont, 9 ], TMY->TMY_FILIAL + TMY->TMY_NUMASO )

		//Caso o funcion�rio estiver demitido
		If !Empty( dDtDemis ) .And. cSitFolh == "D"

			//Busca as informa��es do ASO
			dDtASO := IIf( lImpASO, dDataBase, M->TMY_DTEMIS )
			cNatASO := IIf( lImpASO, Posicione( "TMY", 1, cChvASO, "TMY_NATEXA" ), M->TMY_NATEXA )

			//Caso o ASO tenha sido emitido no dia da demiss�o ou posteriormente e o ASO for diferente de "Demissional"
			If dDtASO >= dDtDemis .And. cNatASO <> "5"
				aAdd( aFunNao, { aFuncs[ nCont, 1 ] } ) //Adiciona no array para depois excluir
			EndIf

		EndIf

	Next nCont

	//----------------------------------------------------------------------
	// Caso exista funcion�rios que n�o devem ser enviados, deleta do array
	//----------------------------------------------------------------------
	If Len( aFunNao ) > 0
		For nCont := 1 To Len( aFunNao )
			If ( nPosReg := aScan( aFuncs, { |x| x[ 1 ] == aFunNao[ nCont, 1 ] } ) ) > 0
				aDel( aFuncs, nPosReg ) //Deleta registro do array
				aSize( aFuncs, Len( aFuncs ) - 1 ) //Diminui a posi��o exclu�da do array
			EndIf
		Next nCont
	EndIf

	//Retorna a �rea
	RestArea( aAreaTMY )
	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fAjsCodUni
Atualiza se necess�rio o c�digo �nico do funcion�rio na transfer�ncia
entre empresas diferentes

@obs	Em casos onde � gerado o evento S-2299 e o novo S-2200 pelo SIGAGPE
e acontece algum erro na integra��o com o medicina, ao tentar refazer a transfer�ncia
o sistema tr�s como sendo o c�digo �nico o c�digo da filial origem, devido a vari�vel
cCodUnic vir vazia por n�o passar pelo trecho do GPE. Nesse cen�rio � necess�rio buscar
o c�digo �nico j� cadastrado na filial destino e considerar ele como o c�digo a ser enviado
no S-2240, esse � o papel dessa fun��o

@return	Nil, Nulo

@param	aFuncs, Array, Array contendo os funcion�rios a serem validados

@sample	fAjsCodUni( { { "0000236" } } )

@author	Luis Fellipy Bett
@since	11/02/2022
/*/
//-------------------------------------------------------------------
Static Function fAjsCodUni( aFuncs )

	//Salva a �rea
	Local aArea := GetArea()

	//Vari�veis de busca de informa��es
	Local aTbls := { { "C9V", 01 } }
	Local cEmpBkp := cEmpAnt //Salva a empresa
	Local cFilBkp := cFilAnt //Salva a filial
	Local aInfTra := {}
	Local cCPF	  := ""

	//Vari�vel contadora
	Local nCont := 1

	//Percorre todos funcion�rios a serem transferidos verificando o c�digo �nico vindo do GPE
	For nCont := 1 To Len( aFuncs )

		//Pega as informa��es da transfer�ncia
		aInfTra := aFuncs[ nCont, 7 ]

		//Caso a empresa origem seja diferente da empresa destino
		If aInfTra[ 1, 2 ] <> aInfTra[ 1, 3 ]

			//Caso a empresa do c�digo �nico do funcion�rio for diferente da empresa pra que ele ta sendo transferido
			If SubStr( aInfTra[ 1, 14 ], 1, 2 ) <> aInfTra[ 1, 3 ]

				//Caso o envio for via SIGATAF
				If !lMiddleware
				
					//Busca o CPF do funcion�rio
					cCPF := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_CIC" )

					//Posiciona na empresa destino
					NGPrepTBL( aTbls, aInfTra[ 1, 3 ], aInfTra[ 1, 5 ] ) //Abre a tabela C9V na empresa destino
					cEmpAnt := aInfTra[ 1, 3 ] //Posiciona na empresa destino
					cFilAnt := aInfTra[ 1, 5 ] //Posiciona na filial destino

					dbSelectArea( "C9V" )
					dbSetOrder( 3 )
					If dbSeek( xFilial( "C9V" ) + cCPF )
						aFuncs[ nCont, 7, 1, 14 ] := C9V->C9V_MATRIC //Atualiza o c�digo �nico do funcion�rio conforme o c�digo da filial de destino
					EndIf

					//Volta a empresa para a posicionada
					NGPrepTBL( aTbls, cEmpBkp, cFilBkp ) //Abre a tabela C9V na empresa destino
					cEmpAnt := cEmpBkp //Posiciona na empresa destino
					cFilAnt := cFilBkp //Posiciona na filial destino
				
				EndIf

			EndIf

		EndIf

	Next nCont
	
	//Retorna a �rea
	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTVld2240
Verifica se existe o evento S-2240 para o funcion�rio no
SIGATAF/Middleware

@author	Luis Fellipy Bett
@since	21/02/2022

@param	cMatFun, Matr�cula do funcion�rio a ser validado
@param	cFilFun, Filial do funcion�rio
@param	dEvento, Data de gera��o do evento a ser cadastrado

@return	lExsReg, Indica se existe o evento S-2240
/*/
//-------------------------------------------------------------------
Function MDTVld2240( cMatFun, cFilFun, dEvento )

	//Salva a �rea
	Local aArea := GetArea()

	//Vari�vel para busca das informa��es
	Local aEvento := {}
	Local cFilEnv := MDTBFilEnv() //Busca a filial de envio para posicionar na CM9
	Local lExsReg := .F.
	Local cIDFunc := ""

	//Define as vari�veis padr�es
	Default cFilFun := cFilAnt
	Default lMiddleware := IIf( cPaisLoc == 'BRA' .And. Findfunction( "fVerMW" ), fVerMW(), .F. )
	Default dEvento := CtoD( '  /  /    ' )

	//Caso for envio via Middleware
	If lMiddleware

		//Busca os Xml's do evento e funcion�rio passado por par�metro
		aEvento := MDTLstXml( "S2240", cMatFun )

		//Verifica se a query retornou algum registro
		lExsReg := !Empty( aEvento )

	Else //Caso for envio via SIGATAF

		//Busca o ID do funcion�rio no TAF
		cIDFunc := MDTGetIdFun( cMatFun, cFilFun )

		//Caso exista o funcion�rio no TAF
		If !Empty( cIDFunc )

			dbSelectArea( "CM9" )
			dbSetOrder( 2 )
			If dbSeek( xFilial( "CM9", cFilEnv ) + cIDFunc )

				If FwIsInCallStack( 'D180INCL' ) // Risco
					If dEvento == CM9->CM9_DTINI
						lExsReg := .T.
					EndIf
				Else
					lExsReg := .T.
				EndIf

			EndIf

		EndIf

	EndIf

	//Retorna a �rea
	RestArea( aArea )

Return lExsReg

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTChgSRA
Altera os campos da SRA para considerar os dados corretos quando for transfer�ncia de funcion�rio

@return Nil, Nulo

@sample MDTChgSRA( .T., { { 23/06/2021 } } )

@param lAlt, Boolean, Indica se altera os campos, caso seja .F. retorna o valor dos campos
@param aGPEA180, Array, Array com os dados da transfer�ncia do funcion�rio
	1� posi��o - Data da transfer�ncia
	2� posi��o - Empresa origem
	3� posi��o - Empresa destino
	4� posi��o - Filial origem
	5� posi��o - Filial destino
	6� posi��o - Matr�cula origem
	7� posi��o - Matr�cula destino
	8� posi��o - Centro de custo origem
	9� posi��o - Centro de custo destino
	10� posi��o - Departamento origem
	11� posi��o - Departamento destino
	12� posi��o - Fun��o destino
	13� posi��o - Cargo destino
	14� posi��o - C�digo �nico destino

@author Luis Fellipy Bett
@since 23/06/2021
/*/
//---------------------------------------------------------------------
Function MDTChgSRA( lAlt, aGPEA180 )

	dbSelectArea( "SRA" )
	Reclock( "SRA", .F. )

	If lAlt
		SRA->RA_CC := aGPEA180[ 1, 9 ]
		SRA->RA_DEPTO := aGPEA180[ 1, 11 ]
		If !Empty( aGPEA180[ 1, 12 ] )
			SRA->RA_CODFUNC	:= aGPEA180[ 1, 12 ]
		EndIf
		If !Empty( aGPEA180[ 1, 13 ] )
			SRA->RA_CARGO := aGPEA180[ 1, 13 ]
		EndIf
	Else
		SRA->RA_CC := cCCustoAnt
		SRA->RA_DEPTO := cDeptoAnt
		If !Empty( aGPEA180[ 1, 12 ] )
			SRA->RA_CODFUNC := cFuncaoAnt
		EndIf
		If !Empty( aGPEA180[ 1, 13 ] )
			SRA->RA_CARGO := cCargoAnt
		EndIf
	EndIf

	SRA->( MsUnlock() )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTChgEmp
Abre os arquivos na empresa passada por par�metro

@return	Nil, Nulo

@sample	MDTChgEmp( { "TN6", "SRA" }, "T2", "M SC 02 " )

@param	aTbls, Array, Array contendo as tabelas a serem abertas
@param	cEmpCls, Caracter, Indica a empresa para qual as tabelas ser�o fechadas
@param	cEmpOpn, Caracter, Indica a empresa para qual as tabelas ser�o abertas

@author	Luis Fellipy Bett
@since	19/10/2021
/*/
//---------------------------------------------------------------------
Function MDTChgEmp( aTbls, cEmpCls, cEmpOpn )

	//Vari�veis de busca das informa��es
	Local cModo := ""

	//Vari�veis contadoras
	Local nCont := 0

	//Percorre as tabelas fechando e abrindo nas empresas
	For nCont := 1 To Len( aTbls )

		//Fecha a tabela
		EmpOpenFile( aTbls[ nCont ], aTbls[ nCont ], 1, .F., cEmpCls, @cModo )

		//Abre a tabela
		EmpOpenFile( aTbls[ nCont ], aTbls[ nCont ], 1, .T., cEmpOpn, @cModo )

	Next nCont

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fEveNObrig
Verifica se o funcion�rio deve ser integrado estando exposto a algum
risco e tendo a data dos eventos n�o obrigat�rios maior que a data a
ser enviada nos eventos S-2220 e S-2240

@return	lEnvia, Boolean, Indica se deve ou n�o enviar o evento para o funcion�rio

@sample	fEveNObrig( "S-2220", { { "0001523" } }, 3, { {} } )

@param	cEvento, Caracter, Indica o evento que est� sendo validado
@param	aFuncs, Array, Array contendo as informa��es do funcion�rio
@param	nOper, Num�rico, Indica a opera��o que est� sendo realizada (3-Inclus�o/4-Altera��o/5-Exclus�o)
@param	aFunNaoEnv, Array, Array que receber� os funcion�rios que n�o dever�o ser integrados

@author	Luis Fellipy Bett
@since	14/03/2022

@obs	Ap�s a implementa��o do PPP eletr�nico, prevista no dia de hoje (28/04/2022) para
01/01/2023, essa fun��o poder� ser exclu�da, assim como suas respectivas chamadas pois ser�
obrigat�rio o envio dos eventos S-2220 e S-2240 para os trabalhadores sem exposi��o a riscos
/*/
//---------------------------------------------------------------------
Static Function fEveNObrig( cEvento, aFuncs, nOper, aFunNaoEnv )

	//Salva a �rea
	Local aArea := GetArea()

	//Vari�veis de busca das informa��es
	Local dDtEnv  := SToD( "" )
	Local dDtAtu  := SToD( "" )
	Local nPosReg := 0

	//Vari�veis de par�metros
	Local dDtEveNObr := SuperGetMv( "MV_NG2DENO", .F., SToD( "20211013" ) )

	//Vari�veis de chamadas
	Local lImpASO := IsInCallStack( "NGIMPRASO" ) .Or. IsInCallStack( "MDTR465" ) .Or. IsInCallStack( "NG200IMP" )

	//Vari�veis contadoras
	Local nCont := 0

	//Percorre os funcion�rios validando
	For nCont := 1 To Len( aFuncs )

		//--------------------------------------------------------
		// Verifica a data a ser considerada no envio dos eventos
		//--------------------------------------------------------
		If cEvento == "S-2220" //Caso for valida��o do evento S-2220

			dDtEnv := IIf( lImpASO, dDataBase, M->TMY_DTEMIS )

		ElseIf cEvento == "S-2240" //Caso for valida��o do evento S-2240

			//Busca a data de exposi��o atual do evento S-2240
			dDtAtu := MDTDtExpAtu( aFuncs[ nCont, 1 ] )

			//Busca a data de envio a ser considerada no envio do evento S-2240
			dDtEnv := MDTBscDtEnv( aFuncs[ nCont ], nOper, , dDtAtu )

		EndIf

		//---------------------------------------------------------------------------------------
		// Caso o funcion�rio n�o esteja exposto a nenhum risco e a data definida como in�cio de
		// envio dos eventos n�o obrigat�rios seja maior que a data a ser considerada no evento
		//---------------------------------------------------------------------------------------
		If !Empty( dDtEnv ) .And. dDtEnv < dDtEveNObr .And. Len( MDTRis2240( dDtEnv ) ) == 0

			aAdd( aFunNaoEnv, { 4, aFuncs[ nCont, 1 ], AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_NOME" ) ) } )

		EndIf

	Next nCont

	//----------------------------------------------------------------------
	// Caso exista funcion�rios que n�o devem ser enviados, deleta do array
	//----------------------------------------------------------------------
	If Len( aFunNaoEnv ) > 0
		For nCont := 1 To Len( aFunNaoEnv )
			If ( nPosReg := aScan( aFuncs, { |x| x[ 1 ] == aFunNaoEnv[ nCont, 2 ] } ) ) > 0
				aDel( aFuncs, nPosReg ) //Deleta registro do array
				aSize( aFuncs, Len( aFuncs ) - 1 ) //Diminui a posi��o exclu�da do array
			EndIf
		Next nCont
	EndIf

	//Retorna a �rea
	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldASOAdm
Valida se existe um ASO admissional anterior informado para os funcion�rios que est�o sendo enviados

@return	Nil, Nulo

@param	aFuncs, Array, Array contendo os funcion�rios para valida��o
@param	lImpASO, Boolean, Indica se � impress�o do ASO

@sample	fVldASOAdm( { { "000230" } }, .T. )

@author	Luis Fellipy Bett
@since	13/04/2022
/*/
//-------------------------------------------------------------------
Static Function fVldASOAdm( aFuncs, lImpASO )

	//Salva a �rea
	Local aArea := GetArea()
	Local aAreaTMY := TMY->( GetArea() )

	//Vari�veis de controle
	Local lRet := .T.
	Local lExsASO := .F.

	//Vari�veis de busca e valida��o das informa��es
	Local aEvento   := {}
	Local cIdFunc	:= ""
	Local cChvASO	:= ""
	Local cMsgASO	:= ""
	Local aASOAdd	:= {}
	Local aASOExc	:= {}
	Local aArrAux	:= {}
	Local aASOMsg	:= {}
	Local nPosReg	:= 0
	Local nEvento   := 0

	//Vari�veis contadoras
	Local nCont	 := 0
	Local nCont2 := 0

	//Percorre os ASO's dos funcion�rios que est�o sendo enviados para validar
	For nCont := 1 To Len( aFuncs )

		//Busca a chave do ASO
		cChvASO := IIf( Len( aFuncs[ nCont ] ) > 8 .And. aFuncs[ nCont, 9 ] <> Nil, aFuncs[ nCont, 9 ], TMY->TMY_FILIAL + TMY->TMY_NUMASO )

		//Busca a natureza do ASO
		cCodASO	:= IIf( lImpASO, Posicione( "TMY", 1, cChvASO, "TMY_NUMASO" ), M->TMY_NUMASO )
		cNatASO	:= IIf( lImpASO, Posicione( "TMY", 1, cChvASO, "TMY_NATEXA" ), M->TMY_NATEXA )
		dDtASO	:= IIf( lImpASO, dDataBase, M->TMY_DTEMIS )

		//Caso o ASO for admissional, verifica se j� n�o existe outro ASO cadastrado
		If cNatASO == "1"

			//Caso for envio via Middleware
			If lMiddleware

				//Busca os Xml's do evento S-2220 para o funcion�rio
				aEvento := MDTLstXml( "S2220", aFuncs[ nCont, 1 ] )

				For nEvento := 1 To Len( aEvento )

					If MDTXmlVal( "S2220", aEvento[ nEvento, 1 ], "/ns:eSocial/ns:evtMonit/ns:exMedOcup/ns:aso/ns:dtAso", "D" ) < dDtASO
						lExsASO := .T.
						Exit
					EndIf

				Next nEvento

			Else //Caso for envio via SIGATAF

				//Busca o ID do funcion�rio na tabela CM9
				cIdFunc := MDTGetIdFun( aFuncs[ nCont, 1 ] )

				dbSelectArea( "C8B" )
				dbSetOrder( 2 )
				dbSeek( xFilial( "C8B" ) + cIdFunc )
				While xFilial( "C8B" ) == C8B->C8B_FILIAL .And. C8B->C8B_FUNC == cIdFunc //Percorre os ASO's do funcion�rio
					
					//Caso o ASO tiver a data anterior ao ASO que est� sendo enviado
					If C8B->C8B_DTASO < dDtASO

						//Caso o ASO tenha sido inclu�do ou alterado
						If ( C8B->C8B_EVENTO == "I" .Or. C8B->C8B_EVENTO == "A" ) .And. aScan( aASOAdd, { | x | x == C8B->C8B_ID } ) == 0
							aAdd( aASOAdd, C8B->C8B_ID )
						ElseIf C8B->C8B_EVENTO == "E" .And. aScan( aASOExc, { | x | x == C8B->C8B_ID } ) == 0
							aAdd( aASOExc, C8B->C8B_ID )
						EndIf

					EndIf

					C8B->( dbSkip() )
				End

				//Passa o conte�do pro array auxiliar
				aArrAux := aClone( aASOAdd )

				//Caso existirem ASO's cadastrados para o funcion�rio
				If Len( aArrAux ) > 0
					
					//Percorre o array validando se os ASO's existentes est�o exclu�dos
					For nCont2 := 1 To Len( aArrAux )
						
						//Caso o ASO tiver sido exclu�do
						If aScan( aASOExc, { | x | x == aArrAux[ nCont2 ] } ) > 0
							
							//Exclui o ASO que possui evento de exclus�o para n�o considerar
							If ( nPosReg := aScan( aASOAdd, { | x | x == aArrAux[ nCont2 ] } ) ) > 0
								aDel( aASOAdd, nPosReg ) //Deleta registro do array
								aSize( aASOAdd, Len( aASOAdd ) - 1 ) //Diminui a posi��o exclu�da do array
							EndIf
							
						EndIf

					Next nCont2

					//Caso existam ASO's que n�o foram exclu�dos
					If Len( aASOAdd ) > 0
						lExsASO := .T.
					EndIf

				EndIf

			EndIf

			//Caso j� exista um ASO admissional
			If lExsASO

				//Adiciona o ASO para apresentar na mensagem
				aAdd( aASOMsg, { aFuncs[ nCont, 1 ], cCodASO } )

			EndIf

			//Retorna a vari�vel para validar o pr�ximo funcion�rio do la�o
			lExsASO := .F.

		EndIf

	Next nCont

	//Caso houverem ASO's a serem informados
	If Len( aASOMsg ) > 0

		//Define a pergunta inicial
		cMsgASO += STR0097 + CRLF + CRLF //"Est�o sendo integrados ASO's admissionais para os funcion�rios abaixo, por�m os mesmos j� possuem outro ASO admissional integrado ao SIGATAF/Middleware. Deseja realizar a integra��o mesmo assim?"

		//Percorre o array para montar a vari�vel
		For nCont := 1 To Len( aASOMsg )

			cMsgASO += STR0024 + ": " + AllTrim( aASOMsg[ nCont, 1 ] ) + " - " + ; //"Funcion�rio"
						AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aASOMsg[ nCont, 1 ], "RA_NOME" ) ) + " / " + ;
						STR0096 + ": " + aASOMsg[ nCont, 2 ] + CRLF //"ASO"

		Next nCont

		//Exibe a mensagem perguntando ao usu�rio se deve continuar com a integra��o ou n�o
		lRet := MsgYesNo( cMsgASO, STR0017 )

	EndIf

	//Retorna as �reas
	RestArea( aAreaTMY )
	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fMdtCarEso
Realiza a valida��o das informa��es do evento S-2240 ao Governo.
Chamada no fonte gpea370. (Cargos)

@author Gabriel Sokacheski
@since 27/04/2022

@param nOperacao, Num�rico, Tipo de opera��o realizada na rotina
@param lEnvio, Boolean, Indica se � envio de informa��es,
caso contr�rio trata como valida��o
@param oModel, Objeto, Objeto do modelo

@return lRet, Booleano, Verdadeiro caso n�o existam inconsist�ncias
/*/
//---------------------------------------------------------------------
Function mdtesoCar( nOperacao, lEnvio, oModel )

	Local aFun := {}

	Local cDesc := SuperGetMV( 'MV_NG2TDES', .F., '1' )
	Local cCargo := oModel:GetValue( 'Q3_CARGO' )
	Local cAliasFun := GetNextAlias()


	Local lRet := .T.

	If nOperacao == 4 .And. oModel:IsFieldUpdated( 'Q3_MEMO1' ) .And. cDesc $ '2/4'

		BeginSQL Alias cAliasFun
			SELECT
				RA_MAT
			FROM
				%table:SRA%
			WHERE
				RA_FILIAL = %xFilial:SRA%
				AND RA_CARGO = %exp:cCargo%
				AND %NotDel%
		EndSQL

		dbSelectArea( cAliasFun )
		dbGoTop()

		While ( cAliasFun )->( !Eof() )

			If MdtVld2240( ( cAliasFun )->RA_MAT ) // Verifica se o funcion�rio j� possui o evento S-2240

				aAdd( aFun, { ( cAliasFun )->RA_MAT } )

			EndIf

			( cAliasFun )->( dbSkip() )

		End

		( cAliasFun )->( dbCloseArea() )

		// Caso existam funcion�rios a serem enviados
		If Len( aFun ) > 0

			lRet := MDTIntEsoc( 'S-2240', nOperacao, Nil, aFun, lEnvio ) // Valida as informa��es a serem enviadas ao Governo

		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MdtEsoFimT
Verifica se a descri��o e o ambiente do S-2240 est�o vinculados a
tarefa e alerta ao preencher a data de t�rmino.

@author Gabriel Sokacheski
@since 16/08/2022

/*/
//---------------------------------------------------------------------
Function MdtEsoFimT()

	If SuperGetMV( 'MV_NG2TDES', .F., Nil ) $ '1/4'
		// "O par�metro est� configurado como tarefa e a descri��o das atividades no S-2240 poder� ficar em branco"
		// "O envio do evento sem uma informa��o obrigat�ria ir� ocasionar um erro."
		MsgAlert( STR0098 + '.' + Space( 1 ) + STR0100 + '.', 'MV_NG2TDES' )
	EndIf

	If SuperGetMV( 'MV_NG2EAMB', .F., Nil ) == '4'
		// "O par�metro est� configurado como tarefa e o ambiente no S-2240 poder� ficar em branco"
		// "O envio do evento sem uma informa��o obrigat�ria ir� ocasionar um erro."
		MsgAlert( STR0099 + '.' + Space( 1 ) + STR0100 + '.', 'MV_NG2EAMB' )
	EndIf

Return
