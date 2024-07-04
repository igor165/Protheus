#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "mdtm003.CH"

//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//  _______           _______  _       _________ _______             _______  _______  _______  _______  _______  ---
// (  ____ \|\     /|(  ____ \( (    /|\__   __/(  ___  )           (  ____ \/ ___   )/ ___   )/ ___   )(  __   ) ---
// | (    \/| )   ( || (    \/|  \  ( |   ) (   | (   ) |           | (    \/\/   )  |\/   )  |\/   )  || (  )  | ---
// | (__    | |   | || (__    |   \ | |   | |   | |   | |   _____   | (_____     /   )    /   )    /   )| | /   | ---
// |  __)   ( (   ) )|  __)   | (\ \) |   | |   | |   | |  (_____)  (_____  )  _/   /   _/   /   _/   / | (/ /) | ---
// | (       \ \_/ / | (      | | \   |   | |   | |   | |                 ) | /   _/   /   _/   /   _/  |   / | | ---
// | (____/\  \   /  | (____/\| )  \  |   | |   | (___) |           /\____) |(   (__/\(   (__/\(   (__/\|  (__) | ---
// (_______/   \_/   (_______/|/    )_)   )_(   (_______)           \_______)\_______/\_______/\_______/(_______) ---
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MDTM003
Rotina de Envio de Eventos - Monitoramento da Sa�de do Trabalhador (S-2220)
Realiza a composi��o do Xml a ser enviado ao Governo

@return cRet, Caracter, Retorna o Xml gerado pelo ASO

@sample MDTM003( 3, .T., {} )

@param nOper, Num�rico, Indica a opera��o que est� sendo realizada (3-Inclus�o/4-Altera��o/5-Exclus�o)
@param lIncons, Boolean, Indica se � avalia��o de inconsist�ncias das informa��es de envio
@param aIncEnv, Array, Array que recebe as inconsist�ncias, se houver, das informa��es a serem enviadas
@param cChave, Caracter, Chave atual do registro a ser utilizada na busca do registro na RJE
@param cChvASO, Caracter, Chave do ASO a ser validado/comunicado (Filial + C�digo do ASO)

@author Luis Fellipy Bett
@since	29/11/2017
/*/
//----------------------------------------------------------------------------------------------------
Function MDTM003( nOper, lIncons, aIncEnv, cChave, cChvASO )

	Local aArea	   := GetArea()
	Local aAreaTMY := TMY->( GetArea() )
	Local cRet	   := ""

	//Vari�veis de chamadas
	Local lImpASO := IsInCallStack( "NGIMPRASO" ) .Or. IsInCallStack( "MDTR465" ) .Or. IsInCallStack( "NG200IMP" )
	Local lXml	  := IsInCallStack( "MDTGeraXml" ) //Verifica se � gera��o de Xml

	//Busca as informa��es do funcion�rio
	Local aDadFun := {}

	//Vari�veis auxiliares para busca das informa��es a serem enviadas
	Private cNumMat			:= "" //Matr�cula do Funcion�rio (RA_MAT)
	Private cNomeFun		:= "" //Nome do Funcion�rio (RA_NOME)
	Private dDtAdm			:= SToD( "" ) //Data de Admiss�o do Funcion�rio (RA_ADMISSA)
	Private cCodMedico		:= "" //C�digo do M�dico Emitente do ASO (TMY_CODUSU)
	Private cCodResp		:= "" //C�digo do M�dico Respons�vel/Coordenador do PCMSO

	//Vari�veis das informa��es a serem envidas
	Private cCpfTrab		:= "" //CPF do Funcion�rio (RA_CIC)
	Private cMatricula		:= "" //Matr�cula do Funcion�rio a ser considerada no envio (RA_CODUNIC)
	Private cCodCateg		:= "" //Categoria do Funcion�rio (RA_CATEFD)
	Private cTpExameOcup	:= "" //Tipo do Exame M�dico Ocupacional (TMY_NATEXA)
	Private dDtASO			:= SToD( "" ) //Data de Emiss�o do ASO (TMY_DTEMIS ou a data atual)
	Private cResAso			:= "" //Resultado do ASO (TMY_INDPAR)
	Private aExaAtes		:= {} //Exames relacionados ao ASO
	Private cNmMed			:= "" //Nome do M�dico Emitente do ASO (TMK_NOMUSU)
	Private cNrCrmMed		:= "" //N�mero de Inscri��o do Emitente do ASO no CRM (TMK_NUMENT)
	Private cUfCrmMed		:= "" //UF de Expedi��o do CRM do M�dico Emitente do ASO (TMK_UF)
	Private cCpfResp		:= "" //CPF do m�dico respons�vel/coordenador do PCMSO (TMK_CIC)
	Private cNmResp			:= "" //Nome do m�dico respons�vel/coordenador do PCMSO (TMK_NOMUSU)
	Private cNrCrmResp		:= "" //N�mero de inscri��o do m�dico respons�vel/coordenador do PCMSO no CRM (TMK_NUMENT)
	Private cUfCRMResp		:= "" //UF de expedi��o do CRM do M�dico respons�vel/coordenador do PCMSO (TMK_UF)

	Default nOper	:= 3
	Default lIncons	:= .F.
	Default cChvASO := ""

	If lImpASO .Or. lXml //Alimenta as vari�veis de mem�ria para utiliza��o
		dbSelectArea( "TMY" )
		dbSetOrder( 1 )
		dbSeek( IIf( !Empty( cChvASO ), cChvASO, TMY->TMY_FILIAL + TMY->TMY_NUMASO ) )
		RegToMemory( "TMY", .F., , .F. ) //Carrega os valores do ASO na mem�ria
	EndIf

	//Busca as informa��es do funcion�rio
	aDadFun := MDTDadFun( IIf( lImpASO .Or. lXml, TMY->TMY_NUMFIC, M->TMY_NUMFIC ) )

	//Vari�veis auxiliares para busca de informa��es a serem enviadas
	cNumMat		:= aDadFun[1] //Matr�cula do Funcion�rio
	cNomeFun	:= aDadFun[2] //Nome do Funcion�rio
	dDtAdm		:= aDadFun[6] //Data de Admiss�o do Funcion�rio
	cCodMedico	:= M->TMY_CODUSU //C�digo do M�dico Emitente do ASO
	cCodResp	:= MDTASOCoord( M->TMY_DTGERA ) //Busca o c�digo do M�dico Coordenador do PCMSO

	//Busca da informa��o a ser enviada na tag <cpfTrab>
	cCpfTrab := aDadFun[3] //CPF do Funcion�rio

	//Busca da informa��o a ser enviada na tag <matricula>
	cMatricula := aDadFun[4] //C�digo �nico do Funcion�rio

	//Busca da informa��o a ser enviada na tag <codCateg>
	cCodCateg := aDadFun[5] //Categoria do Funcion�rio

	//Busca da informa��o a ser enviada na tag <tpExameOcup>
	cTpExameOcup := MDTTpASO( M->TMY_NATEXA )

	//Busca da informa��o a ser enviada na tag <dtAso>
	dDtASO := IIf( !Empty( M->TMY_DTEMIS ), M->TMY_DTEMIS, dDataBase )

	//Busca da informa��o a ser enviada na tag <resAso>
	cResAso := M->TMY_INDPAR

	//Se o resultado do parecer do ASO for igual a "Apto com Restri��o" verifica o par�metro
	If cResAso == "3"
		If SuperGetMv( "MV_NG2RASO", .F., "1" ) == "1"
			cResAso := "1" //Apto
		Else
			cResAso := "2" //Inapto
		EndIf
	EndIf

	//Busca da informa��o a ser enviada nas tags <dtExm>, <procRealizado>, <obsProc>, <ordExame> e <indResult>
	aExaAtes := fBusExa( nOper, M->TMY_NUMASO, lImpASO, lXml, lIncons )

	//Busca da informa��o a ser enviada na tag <nmMed>
	cNmMed := Posicione( "TMK", 1, xFilial( "TMK" ) + cCodMedico, "TMK_NOMUSU" )

	//Busca da informa��o a ser enviada na tag <nrCRM>
	cNrCrmMed := SubStr( Posicione( "TMK", 1, xFilial( "TMK" ) + cCodMedico, "TMK_NUMENT" ), 1, 8 )

	//Busca da informa��o a ser enviada na tag <ufCRM>
	cUfCrmMed := Posicione( "TMK", 1, xFilial( "TMK" ) + cCodMedico, "TMK_UF" )

	//Busca da informa��o a ser enviada na tag <cpfResp>
	cCpfResp := Posicione( "TMK", 1, xFilial( "TMK" ) + cCodResp, "TMK_CIC" )

	//Busca da informa��o a ser enviada na tag <nmResp>
	cNmResp := Posicione( "TMK", 1, xFilial( "TMK" ) + cCodResp, "TMK_NOMUSU" )

	//Busca da informa��o a ser enviada na tag <nrCRM>
	cNrCrmResp := SubStr( Posicione( "TMK", 1, xFilial( "TMK" ) + cCodResp, "TMK_NUMENT" ), 1, 8 )

	//Busca da informa��o a ser enviada na tag <ufCRM>
	cUfCRMResp := Posicione( "TMK", 1, xFilial( "TMK" ) + cCodResp, "TMK_UF" )

	//Realiza a verifica��o das inconsist�ncias ou carrega o Xml
	If lIncons
		fInconsis( @aIncEnv )
	Else
		cRet := fCarrASO( cValToChar( nOper ), cChave )
	EndIf

	RestArea( aAreaTMY )
	RestArea( aArea )

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fCarrASO
Monta o Xml do ASO para envio ao Governo

@return cXml, Caracter, Xml com as informa��es a serem enviadas ao SIGATAF/Middleware

@sample fCarrASO( "3", "D MG 01" )

@param cOper, Caracter, Indica a opera��o que est� sendo realizada ("3"-Inclus�o/"4"-Altera��o/"5"-Exclus�o)
@param cChave, Caracter, Chave atual do registro a ser utilizada na busca do registro na RJE

@author Luis Fellipy Bett
@since 30/08/2018
/*/
//---------------------------------------------------------------------
Static Function fCarrASO( cOper, cChave )

	Local cXml	:= ""
	Local nCont	:= 0
	Local lIndResult := SuperGetMv( "MV_NG2INDR", .F., "1" ) == "1"

	Default cOper := "3"

	//Cria o cabe�alho do Xml com o ID, informa��es do Evento e Empregador
	MDTGerCabc( @cXml, "S2220", cOper, cChave )

	//TRABALHADOR
	cXml += 		'<ideVinculo>'
	cXml += 			'<cpfTrab>'		+ cCpfTrab		+ '</cpfTrab>' //Obrigat�rio
	If !MDTVerTSVE( cCodCateg ) //Caso n�o for TSVE
		cXml +=			'<matricula>'	+ cMatricula	+ '</matricula>' //Obrigat�rio
	Else
		cXml +=			'<codCateg>'	+ cCodCateg		+ '</codCateg>' //Obrigat�rio
	EndIf
	cXml += 		'</ideVinculo>'

	//ATESTADO ASO
	cXml += 		'<exMedOcup>'
	cXml += 			'<tpExameOcup>' + cTpExameOcup + '</tpExameOcup>' //Obrigat�rio
	cXml += 			'<aso>'
	cXml += 				'<dtAso>'	+ MDTAjsData( dDtASO )	+ '</dtAso>' //Obrigat�rio
	cXml += 				'<resAso>'	+ cResAso		 		+ '</resAso>' //Obrigat�rio
	For nCont := 1 To Len( aExaAtes )
		cXml += 			'<exame>' //Exame Ocupacional
		cXml += 				'<dtExm>' 		  + MDTAjsData( aExaAtes[ nCont, 3 ] )	+ '</dtExm>' //Obrigat�rio
		cXml += 				'<procRealizado>' + aExaAtes[ nCont, 4 ]		+ '</procRealizado>' //Obrigat�rio
		If !Empty( aExaAtes[ nCont, 5 ] )
			cXml += 			'<obsProc>'		  + aExaAtes[ nCont, 5 ]		+ '</obsProc>'
		EndIf
		cXml += 				'<ordExame>'	  + aExaAtes[ nCont, 6 ]		+ '</ordExame>' //Obrigat�rio
		If lIndResult .And. !Empty( aExaAtes[ nCont, 7 ] ) //Caso seja definido o envio pelo par�metro e n�o esteja vazio, comp�em a tag
			cXml += 			'<indResult>'	  + aExaAtes[ nCont, 7 ]		+ '</indResult>'
		EndIf
		cXml += 			'</exame>'
	Next nCont
	cXml += 				'<medico>' //M�dico Emitente do ASO
	cXml += 					'<nmMed>'	+ AllTrim( MDTSubTxt( cNmMed ) )	+ '</nmMed>' //Obrigat�rio
	cXml += 					'<nrCRM>'	+ AllTrim( cNrCrmMed )				+ '</nrCRM>' //Obrigat�rio
	cXml += 					'<ufCRM>'	+ cUfCrmMed							+ '</ufCRM>' //Obrigat�rio
	cXml += 				'</medico>'
	cXml += 			'</aso>'
	If !Empty( cCodResp ) //Se caso exisitr um m�dico respons�vel pelo PCMSO
		cXml +=			'<respMonit>' //M�dico Respons�vel/Coordenador do PCMSO
		cXml +=				'<cpfResp>'	+ cCpfResp							+ '</cpfResp>'
		cXml +=				'<nmResp>'	+ AllTrim( MDTSubTxt( cNmResp ) )	+ '</nmResp>'
		cXml +=				'<nrCRM>'	+ AllTrim( cNrCrmResp )				+ '</nrCRM>'
		cXml +=				'<ufCRM>'	+ cUfCRMResp						+ '</ufCRM>'
		cXml +=			'</respMonit>'
	EndIf
	cXml += 		'</exMedOcup>'
	cXml += 	'</evtMonit>'
	cXml += '</eSocial>'

Return cXml

//---------------------------------------------------------------------
/*/{Protheus.doc} fInconsis
Valida as informa��es a serem enviadas para o SIGATAF/Middleware

@return	Nil, Nulo

@sample fInconsis( aIncEnv )

@param	aIncEnv, Array, Array passado por refer�ncia que ir� receber os logs de inconsist�ncias (se houver)

@author	Luis Fellipy Bett
@since	30/08/2018 - Refatorada em: 17/02/2021
/*/
//---------------------------------------------------------------------
Static Function fInconsis( aIncEnv )

	//Vari�veis de controle
	Local aArea	  := GetArea()
	Local cFilBkp := cFilAnt

	Local nCont		:= 0
	Local cStrFil	:= STR0036 + ": " + AllTrim( cFilEnv ) //Filial: XXX
	Local cStrASO	:= STR0001 + ": " + M->TMY_NUMASO //Atestado ASO: XXX
	Local cStrFunc	:= STR0002 + ": " + AllTrim( cNumMat ) + " - " + AllTrim( cNomeFun ) //Funcion�rio: XXX - XXXXX
	Local cStrEmit	:= STR0003 + ": " + AllTrim( cCodMedico ) + " - " + AllTrim( cNmMed ) //M�dico Emitente do ASO: XXX - XXXXX
	Local cStrResp	:= STR0004 + ": " + AllTrim( cCodResp ) + " - " + AllTrim( cNmResp ) //M�dico Respons�vel/Coordenador do PCMSO: XXX - XXXXX

	//Seta a filial de envio para as valida��es de tabelas do TAF
	cFilAnt := cFilEnv

	Help := .T. //Desativa as mensagens de Help

	//Valida��o da tag <cpfTrab> - CPF do trabalhador
	//Preencher com o n�mero do CPF do trabalhador.
	//Informa��o obrigat�ria.
	If Empty( cCpfTrab )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0013 + ": " + STR0007 ) //Funcion�rio: XXX - XXXXX / CPF: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !CHKCPF( cCpfTrab )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0013 + ": " + cCpfTrab ) //Funcion�rio: XXX - XXXXX / CPF: XXX
		aAdd( aIncEnv, STR0008 + ": " + STR0012 ) //Valida��o: Deve ser um n�mero de CPF v�lido
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <matricula> - Matr�cula atribu�da ao trabalhador pela empresa
	//Deve corresponder � matr�cula informada pelo empregador no evento S-2190, S-2200 ou S-2300 do respectivo contrato. N�o preencher no caso de
	//Trabalhador Sem V�nculo de Emprego/Estatut�rio - TSVE sem informa��o de matr�cula no evento S-2300
	//A valida��o de exist�ncia de um registro S-2190, S-2200 ou S-2300 j� � realizada no come�o do envio, atrav�s da fun��o MDTVld2200

	//Valida��o da tag <codCateg> - C�digo da categoria do trabalhador
	//Informa��o obrigat�ria e exclusiva se n�o houver preenchimento de matricula. Se informado, deve ser um c�digo v�lido e existente na Tabela 01.
	If Empty( cMatricula ) .And. Empty( cCodCateg )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0014 + ": " + STR0007 ) //Funcion�rio: XXX - XXXXX / Categoria: Em branco
		aAdd( aIncEnv, '' )
	ElseIf Empty( cMatricula ) .And. !ExistCPO( "C87", cCodCateg, 2 )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0014 + ": " + cCodCateg ) //Funcion�rio: XXX - XXXXX / Categoria: XXX
		aAdd( aIncEnv, STR0008 + ": " + STR0015 ) //Valida��o: Deve ser um c�digo v�lido e existente na tabela 01 do eSocial
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <dtAso> - Data de emiss�o do ASO
	//Valida��o: Deve ser uma data v�lida, igual ou anterior � data atual e igual ou posterior � data de in�cio da obrigatoriedade deste 
	//evento para o empregador no eSocial. Se tpExameOcup for diferente de [0], tamb�m deve ser igual ou posterior � data de 
	//admiss�o/exerc�cio ou de in�cio.
	//Informa��o obrigat�ria.
	If Empty( dDtASO )
		aAdd( aIncEnv, cStrFil + " / " + cStrASO + " / " + STR0019 + ": " + STR0007 ) //Atestado ASO: XXX / Data de Emiss�o do ASO: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !( dDtASO <= dDataBase .And. dDtASO >= dDtEsoc .And. IIf( cTpExameOcup != "0", dDtASO >= dDtAdm, .T. ) )
		aAdd( aIncEnv, cStrFil + " / " + cStrASO + " / " + STR0019 + ": " + DToC( dDtASO ) ) //Atestado ASO: XXX / Data de Emiss�o do ASO: XX/XX/XXXX
		aAdd( aIncEnv, STR0008 + ": " + STR0020 + ": " ) //Valida��o: Deve ser uma data v�lida e:
		aAdd( aIncEnv, "* " + STR0021 + ": " + DToC( dDataBase ) ) //* Igual ou anterior � data atual: XX/XX/XXXX
		aAdd( aIncEnv, "* " + STR0022 + ": " + DToC( dDtEsoc ) ) //* Igual ou posterior � data de in�cio de obrigatoriedade dos eventos de SST ao eSocial: XX/XX/XXXX
		aAdd( aIncEnv, "* " + STR0038 + ": " + DToC( dDtAdm ) ) //* Igual ou posterior � data de admiss�o do funcion�rio quando o ASO for diferente de admissional: XX/XX/XXXX
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <resAso> - Resultado do ASO
	//Valores v�lidos: 1 - Apto ou 2 - Inapto
	//Informa��o obrigat�ria.
	If Empty( cResAso )
		aAdd( aIncEnv, cStrFil + " / " + cStrASO + " / " + STR0023 + ": " + STR0007 ) //Atestado ASO: XXX / Resultado do ASO: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !( cResAso $ "1/2" )
		aAdd( aIncEnv, cStrFil + " / " + cStrASO + " / " + STR0023 + ": " + cResAso ) //Atestado ASO: XXX / Resultado do ASO: XXX
		aAdd( aIncEnv, STR0008 + ": " + STR0024 ) //Valida��o: Deve ser igual a 1- Apto ou 2- Inapto
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o das tags <dtExm>, <procRealizado>, <obsProc>, <ordExame> e de exist�ncia de exames relacionados ao ASO
	If Len( aExaAtes ) > 0
		For nCont := 1 To Len( aExaAtes )

			//Valida��o da tag <dtExm> - Data do Exame
			//Deve ser uma data v�lida, igual ou anterior � data do ASO informada em dtAso.
			//Informa��o obrigat�ria.
			If Empty( aExaAtes[ nCont, 3 ] ) //<dtExm> - Data do exame realizado
				aAdd( aIncEnv, cStrFil + " / " + cStrFunc ) //Funcion�rio: XXX - XXXXX
				aAdd( aIncEnv, STR0025 + ": " + AllTrim( aExaAtes[ nCont, 1 ] ) + " - " + AllTrim( aExaAtes[ nCont, 2 ] ) + " / " + STR0026 + ": " + STR0007 ) //Exame: XXX / Data de Realiza��o: Em branco
				aAdd( aIncEnv, '' )
			ElseIf !( aExaAtes[ nCont, 3 ] <= dDtASO ) //<dtExm> - Data do exame realizado
				aAdd( aIncEnv, cStrFil + " / " + cStrFunc ) //Funcion�rio: XXX - XXXXX
				aAdd( aIncEnv, STR0025 + ": " + AllTrim( aExaAtes[ nCont, 1 ] ) + " - " + AllTrim( aExaAtes[ nCont, 2 ] ) + " / " + STR0026 + ": " + DToC( aExaAtes[ nCont, 3 ] ) ) //Exame: XXX / Data de Realiza��o: XX/XX/XXXX
				aAdd( aIncEnv, STR0008 + ": " + STR0020 + ": " ) //Valida��o: Deve ser uma data v�lida e:
				aAdd( aIncEnv, "* " + STR0039 + ": " + DToC( dDtASO ) ) //* Igual ou anterior a data de emiss�o do ASO: XX/XX/XXXX
				aAdd( aIncEnv, '' )
			EndIf

			//Valida��o da tag <procRealizado> - Procedimento Diagn�stico
			//Valida��o: Deve ser um c�digo v�lido e existente na Tabela 27
			//Informa��o obrigat�ria.
			If Empty( aExaAtes[ nCont, 4 ] ) //<procRealizado>
				aAdd( aIncEnv, cStrFil + " / " + cStrFunc ) //Funcion�rio: XXX - XXXXX
				aAdd( aIncEnv, STR0025 + ": " + AllTrim( aExaAtes[ nCont, 1 ] ) + " - " + AllTrim( aExaAtes[ nCont, 2 ] ) + " / " + STR0028 + ": " + STR0007 ) //Exame: XXX / Procedimento Diagn�stico: Em branco
				aAdd( aIncEnv, '' )
			ElseIf !ExistCPO( "V2K", aExaAtes[ nCont, 4 ], 2 ) //<procRealizado>
				aAdd( aIncEnv, cStrFil + " / " + cStrFunc ) //Funcion�rio: XXX - XXXXX
				aAdd( aIncEnv, STR0025 + ": " + AllTrim( aExaAtes[ nCont, 1 ] ) + " - " + AllTrim( aExaAtes[ nCont, 2 ] ) + " / " + STR0028 + ": " + aExaAtes[ nCont, 4 ] ) //Exame: XXX / Procedimento Diagn�stico: XXX
				aAdd( aIncEnv, STR0008 + ": " + STR0029 ) //Valida��o: Deve ser um c�digo v�lido e existente na tabela 27 do eSocial
				aAdd( aIncEnv, '' )
			EndIf

			//Valida��o da tag <obsProc> - Observa��o do Procedimento Diagn�stico
			//Valida��o: Preenchimento obrigat�rio se procRealizado = [0583, 0998, 0999, 1128, 1230, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999, 9999].
			If aExaAtes[ nCont, 4 ] $ "0583/0998/0999/1128/1230/1992/1993/1994/1995/1996/1997/1998/1999/9999" .And. Empty( aExaAtes[ nCont, 5 ] ) //<obsProc>
				aAdd( aIncEnv, cStrFil + " / " + cStrFunc ) //Funcion�rio: XXX - XXXXX
				aAdd( aIncEnv, STR0025 + ": " + AllTrim( aExaAtes[ nCont, 1 ] ) + " - " + AllTrim( aExaAtes[ nCont, 2 ] ) + " / " + STR0037 + ": " + STR0007 ) //Exame: XXX / Observa��o sobre o Procedimento Diagn�stico: Em branco
				aAdd( aIncEnv, '' )
			EndIf

			//Valida��o da tag <ordExame> - Ordem do Exame
			//Valores v�lidos: 1 - Inicial ou 2 - Sequencial
			//Valida��o: Preenchimento obrigat�rio se procRealizado = [0281].
			If Empty( aExaAtes[ nCont, 6 ] ) .And. aExaAtes[ nCont, 4 ] $ "0281" //<ordExame>
				aAdd( aIncEnv, cStrFil + " / " + cStrASO + " / " + STR0030 + ": " + STR0007 ) //Atestado ASO: XXX / Indicativo do Tipo de Exame: Em branco
				aAdd( aIncEnv, '' )
			ElseIf !Empty( aExaAtes[ nCont, 6 ] ) .And. !( aExaAtes[ nCont, 6 ] $ "1/2" ) //<ordExame>
				aAdd( aIncEnv, cStrFil + " / " + cStrASO + " / " + STR0030 + ": " + aExaAtes[ nCont, 6 ] ) //Atestado ASO: XXX / Indicativo do Tipo de Exame: XXX
				aAdd( aIncEnv, STR0008 + ": " + STR0031 ) //Valida��o: Deve ser igual a 1- Inicial ou 2- Sequencial
				aAdd( aIncEnv, '' )
			EndIf

		Next nCont
	Else
		aAdd( aIncEnv, cStrFil + " / " + cStrASO + " / " + STR0032 ) //Atestado ASO: XXX / N�o existem exames do tipo Ocupacional relacionados ao ASO
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <nmMed> - Nome do m�dico emitente do ASO
	//Informa��o obrigat�ria
	If Empty( cNmMed )
		aAdd( aIncEnv, cStrFil + " / " + cStrEmit + " / " + STR0033 + ": " + STR0007 ) //M�dico Emitente do ASO: XXX - XXXXX / Nome: Em branco
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <nrCRM> - N�mero de inscri��o do m�dico emitente do ASO no Conselho Regional de Medicina - CRM
	//Informa��o obrigat�ria
	If Empty( cNrCrmMed )
		aAdd( aIncEnv, cStrFil + " / " + cStrEmit + " / " + STR0034 + ": " + STR0007 ) //M�dico Emitente do ASO: XXX - XXXXX / N�mero de Inscri��o no CRM: Em branco
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <ufCRM> - UF de expedi��o do CRM
	//Valores v�lidos: AC, AL, AP, AM, BA, CE, DF, ES, GO, MA, MT, MS, MG, PA, PB, PR, PE, PI, RJ, RN, RS, RO, RR, SC, SP, SE, TO
	//Informa��o obrigat�ria
	If Empty( cUfCrmMed )
		aAdd( aIncEnv, cStrFil + " / " + cStrEmit + " / " + STR0035 + ": " + STR0007 ) //M�dico Emitente do ASO: XXX - XXXXX / UF de Expedi��o do CRM: Em branco
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <cpfResp> - CPF do m�dico respons�vel/coordenador do PCMSO
	//Valida��o: Se informado, deve ser um CPF v�lido.
	If !Empty( cCodResp )
		If !Empty( cCpfResp ) .And. !CHKCPF( cCpfResp )
			aAdd( aIncEnv, cStrFil + " / " + cStrResp + " / " + STR0013 + ": " + cCpfResp ) //M�dico Respons�vel/Coordenador do PCMSO: XXX - XXXXX / CPF: XXX
			aAdd( aIncEnv, STR0008 + ": " + STR0012 ) //Valida��o: Deve ser um n�mero de CPF v�lido
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o da tag <nmResp> - Nome do m�dico respons�vel/coordenador do PCMSO
	//Informa��o obrigat�ria caso exista um m�dico respons�vel/coordenador do PCMSO
	If !Empty( cCodResp )
		If Empty( cNmResp )
			aAdd( aIncEnv, cStrFil + " / " + cStrResp + " / " + STR0033 + ": " + STR0007 ) //M�dico Respons�vel/Coordenador do PCMSO: XXX - XXXXX / Nome: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o da tag <nrCRM> - N�mero de inscri��o do m�dico respons�vel/coordenador do PCMSO no CRM
	//Informa��o obrigat�ria caso exista um m�dico respons�vel/coordenador do PCMSO
	If !Empty( cCodResp )
		If Empty( cNrCrmResp )
			aAdd( aIncEnv, cStrFil + " / " + cStrResp + " / " + STR0034 + ": " + STR0007 ) //M�dico Respons�vel/Coordenador do PCMSO: XXX - XXXXX / N�mero de Inscri��o no CRM: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Valida��o da tag <ufCRM> - UF de expedi��o do CRM
	//Valores v�lidos: AC, AL, AP, AM, BA, CE, DF, ES, GO, MA, MT, MS, MG, PA, PB, PR, PE, PI, RJ, RN, RS, RO, RR, SC, SP, SE, TO
	//Informa��o obrigat�ria caso exista um m�dico respons�vel/coordenador do PCMSO
	If !Empty( cCodResp )
		If Empty( cUfCRMResp )
			aAdd( aIncEnv, cStrFil + " / " + cStrResp + " / " + STR0035 + ": " + STR0007 ) //M�dico Respons�vel/Coordenador do PCMSO: XXX - XXXXX / UF de Expedi��o do CRM: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	Help := .F. //Ativa novamente as mensagens de Help

	cFilAnt := cFilBkp //Retorna filial do registro
	RestArea( aArea ) //Retorna �rea

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fBusExa
Busca os exames relacionados ao atestado ASO

@sample	fBusExa( 3, "000026", .T., .F., .F. )

@return	aExaAtes, Array, Array com os exames relacionados ao ASO

@param	nOpc, Num�rico, Indica a opera��o que est� sendo realizada (3-Inclus�o/4-Altera��o/5-Exclus�o)
@param	cNumASO, Caracter, Indica o c�digo do ASO que est� sendo enviado para a busca de informa��es
@param	lImpASO, Boolean, Indica se � impress�o do ASO
@param	lXml, Boolean, Indica se � gera��o de Xml
@param	lIncons, Boolean, Indica se � valida��o das informa��es

@author	Guilherme Benekendorf
@since	25/11/2013
/*/
//---------------------------------------------------------------------
Static Function fBusExa( nOpc, cNumASO, lImpASO, lXml, lIncons )

	Local aExaAtes := {}
	Local aExame   := {}

	//Caso n�o for impress�o do ASO, n�o for gera��o de xml, for valida��o das informa��es e existir a tabela tempor�ria
	If !lImpASO .And. !lXml .And. lIncons .And. Type( "cTRB2200" ) == "C" .And. Select( cTRB2200 ) > 0
		dbSelectArea( cTRB2200 )
		dbGoTop()
		If ( cTRB2200 )->( !Eof() )
			While ( cTRB2200 )->( !Eof() )
				If !Empty( ( cTRB2200 )->TM5_OK )
					dbSelectArea( "TM5" )
					dbSetOrder( 8 ) //"TM5_FILIAL+TM5_NUMFIC+DTOS(TM5_DTPROG)+TM5_HRPROG+TM5_EXAME"
					If dbSeek( xFilial( "TM5" ) + ( cTRB2200 )->TM5_NUMFIC + DTOS( ( cTRB2200 )->TM5_DTPROG ) + ( cTRB2200 )->TM5_HRPROG + ( cTRB2200 )->TM5_EXAME )

						aExame := fStructExa( aExaAtes )

						If Len( aExame ) > 0
							aAdd( aExaAtes, aExame )
						EndIf

					EndIf
				EndIf
				dbSelectArea( cTRB2200 )
				( cTRB2200 )->( dbSkip() )
			End
		EndIf
	Else
		dbSelectArea( "TM5" )
		dbSetOrder( 4 ) //TM5_FILIAL+TM5_NUMASO
		If dbSeek( xFilial( "TM5" ) + cNumASO )
			While !Eof() .And. TM5->TM5_FILIAL == xFilial( "TM5" ) .And. TM5->TM5_NUMASO == cNumASO

				aExame := fStructExa( aExaAtes )

				If Len( aExame ) > 0
					aAdd( aExaAtes, aExame )
				EndIf

				dbSelectArea( "TM5" )
				dbSkip()
			End
		EndIf
	EndIf

Return aExaAtes

//---------------------------------------------------------------------
/*/{Protheus.doc} fStructExa
Retorna a estrutura do exame a ser inserido no evento

@return	aExame, Array, Array com os exames a serem incluidos no Xml no formato de envio

@author	Luis Fellipy Bett
@since	23/10/2017
/*/
//---------------------------------------------------------------------
Function fStructExa( aExaAtes )

	Local aExame	 := {}
	Local cNomExa	 := Posicione( "TM4", 1, xFilial( "TM4" ) + TM5->TM5_EXAME, "TM4_NOMEXA" )
	Local cProcReal	 := Posicione( "TM4", 1, xFilial( "TM4" ) + TM5->TM5_EXAME, "TM4_PROCRE" )
	Local cObsProc	 := AllTrim( MDTSubTxt( TM5->TM5_OBSERV ) )
	Local cIndResult := TM5->TM5_INDRES

	//----- Indica��o dos Resultados
	// 1- Normal						1- Normal
	// 2- Alterado						2- Alterado
	// 2- Alterado e 2- Agravamento		3- Est�vel
	// 2- Alterado e 1- Agravamento		4- Agravamento
	Do Case
		Case cIndResult = "2" .And. TM5->TM5_INDAGR == "2" ; cIndResult := "3"
		Case cIndResult = "2" .And. TM5->TM5_INDAGR == "1" ; cIndResult := "4"
	End Case

	If aScan( aExaAtes, { | x | x[ 3 ] == TM5->TM5_DTRESU .And. x[ 4 ] == AllTrim( cProcReal ) } ) == 0
		If !Empty( TM5->TM5_PCMSO )
			aExame := { TM5->TM5_EXAME, ;
						cNomExa, ; //Utilizado para impress�o do nome do Exame no relat�rio de inconsist�ncias
						TM5->TM5_DTRESU, ; //Valor a ser enviado na tag <dtExm>
						AllTrim( cProcReal ), ; //Valor a ser enviado na tag <procRealizado>
						AllTrim( cObsProc ), ; //Valor a ser enviado na tag <obsProc>
						M->TMY_INDEXA, ; //Valor a ser enviado na tag <ordExame>
						cIndResult } //Valor a ser enviado na tag <indResult>
		EndIf
	EndIf

Return aExame

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTTpASO
Busca o tipo do ASO conforme o leiaute do eSocial

@return	cTipRet, Caracter, Tipo do ASO a ser retornado conforme leiaute do eSocial

@param	cTpASO, Caracter, Tipo do ASO no SIGAMDT

@sample	MDTTpASO( "1" )

@author	Luis Fellipy Bett
@since	10/01/2022
/*/
//-------------------------------------------------------------------
Function MDTTpASO( cTpASO )

	Local cTipRet := "" //Tipo do ASO que ser� retornado

	//-------------- Tipo de Atestado --------------
	// 1- Admissional			0- Admissional
	// 2- Peri�dico				1- Per�odico, conforme planejamento do PCMSO
	// 3- Mudan�a de Fun��o		3- De mudan�a de fun��o
	// 4- Retorno ao Trabalho	2- De retorno ao trabalho
	// 5- Demissional			9- Demissional
	// 6- Monitora��o Pontual	4- Exame m�dico de monitora��o pontual
	//----------------------------------------------
	Do Case
		Case cTpASO == "1" ; cTipRet := "0"
		Case cTpASO == "2" ; cTipRet := "1"
		Case cTpASO == "3" ; cTipRet := "3"
		Case cTpASO == "4" ; cTipRet := "2"
		Case cTpASO == "5" ; cTipRet := "9"
		Case cTpASO == "6" ; cTipRet := "4"
	End Case

Return cTipRet
