#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MDTM004.CH"

//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//  _______           _______  _       _________ _______             _______  _______  _______    ___    _______  ---
// (  ____ \|\     /|(  ____ \( (    /|\__   __/(  ___  )           (  ____ \/ ___   )/ ___   )  /   )  (  __   ) ---
// | (    \/| )   ( || (    \/|  \  ( |   ) (   | (   ) |           | (    \/\/   )  |\/   )  | / /) |  | (  )  | ---
// | (__    | |   | || (__    |   \ | |   | |   | |   | |   _____   | (_____     /   )    /   )/ (_) (_ | | /   | ---
// |  __)   ( (   ) )|  __)   | (\ \) |   | |   | |   | |  (_____)  (_____  )  _/   /   _/   /(____   _)| (/ /) | ---
// | (       \ \_/ / | (      | | \   |   | |   | |   | |                 ) | /   _/   /   _/      ) (  |   / | | ---
// | (____/\  \   /  | (____/\| )  \  |   | |   | (___) |           /\____) |(   (__/\(   (__/\    | |  |  (__) | ---
// (_______/   \_/   (_______/|/    )_)   )_(   (_______)           \_______)\_______/\_______/    (_)  (_______) ---
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MDTM004
Rotina de Envio de Eventos - Condi��o Ambiental de Trabalho - Riscos (S-2240)
Realiza a composi��o do Xml a ser enviado ao Governo

@return cRet, Caracter, Retorna o Xml gerado pelo Risco

@sample MDTM004( '0000001', 3, 01/01/2019, .T., {} )

@param cNumMat, Caracter, Indica a matr�cula do Funcion�rio ao qual ser�o enviadas as informa��es
@param nOper, Num�rico, Indica a opera��o que est� sendo realizada (3-Inclus�o/4-Altera��o/5-Exclus�o)
@param dDtIniCond, Date, Indica a data de refer�ncia do per�odo de exposi��o que ser� enviado
@param lIncons, Boolean, Indica se � avalia��o de inconsist�ncias das informa��es de envio
@param aIncEnv, Array, Array que recebe as inconsist�ncias, se houver, das informa��es a serem enviadas
@param cChave, Caracter, Chave atual do registro a ser utilizada na busca do registro na RJE
@param aGPEA180, Array, Array contendo as informa��es da transfer�ncia do funcion�rio
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
@since 27/11/2017
/*/
//------------------------------------------------------------------------------------------------------------------
Function MDTM004( cNumMat, nOper, dDtIniCond, lIncons, aIncEnv, cChave, aGPEA180 )

	//Vari�veis de controle de troca de empresa, quando transfer�ncia de empresa
	Local aAreaBk  := GetArea()
	Local cEmpBkp  := cEmpAnt
	Local cFilBkp  := cFilAnt
	Local cArqBkp  := cArqTab

	//Vari�veis de controle de tabelas na troca de empresa, quando transfer�ncia de empresa
	Local aAreaTOQ := TOQ->( GetArea() )
	Local aAreaTOR := TOR->( GetArea() )
	Local aAreaTOS := TOS->( GetArea() )
	Local aAreaTOT := TOT->( GetArea() )
	Local aAreaTOU := TOU->( GetArea() )
	Local aAreaTNE := TNE->( GetArea() )
	Local aAreaTN6 := TN6->( GetArea() )
	Local aAreaSR8 := SR8->( GetArea() )
	Local aAreaSQ3 := SQ3->( GetArea() )
	Local aAreaTN5 := TN5->( GetArea() )
	Local aAreaSRJ := SRJ->( GetArea() )
	Local aAreaTN0 := TN0->( GetArea() )
	Local aAreaTO9 := TO9->( GetArea() )
	Local aAreaTMA := TMA->( GetArea() )
	Local aAreaTLK := TLK->( GetArea() )
	Local aAreaTO0 := TO0->( GetArea() )
	Local aAreaTMK := TMK->( GetArea() )
	Local aAreaTNX := TNX->( GetArea() )
	Local aAreaTNF := TNF->( GetArea() )
	Local aAreaTN3 := TN3->( GetArea() )
	Local aAreaTL0 := TL0->( GetArea() )
	Local aAreaTJF := TJF->( GetArea() )
	Local aAreaSB1 := SB1->( GetArea() )
	Local aAreaCTT := CTT->( GetArea() )
	Local aAreaSQB := SQB->( GetArea() )
	Local aAreaC92 := C92->( GetArea() )
	Local aAreaC87 := C87->( GetArea() )
	Local aAreaTO1 := TO1->( GetArea() )
	Local aAreaV5Y := V5Y->( GetArea() )
	Local aAreaV3F := V3F->( GetArea() )
	Local aAreaRJ9 := RJ9->( GetArea() )
	Local aAreaRJE := RJE->( GetArea() )
	
	//Vari�vel das tabelas a serem abertas
	Local aTbls := { "TOQ", "TOR", "TOS", "TOT", "TOU", ;
					"TNE", "TN6", "SR8", "SQ3", "TN5", ;
					"SRJ", "TN0", "TO9", "TMA", "TLK", ;
					"TO0", "TMK", "TNX", "TNF", "TN3", ;
					"TL0", "TJF", "SB1", "CTT", "SQB", ;
					"C92", "C87", "TO1", "V5Y", "V3F" }

	//Vari�veis de busca das informa��es
	Local cRet		:= ""
	Local cCCusto	:= ""
	Local cDepto	:= ""
	Local cFuncao	:= ""

	//Vari�veis private auxiliares para valida��o e busca das informa��es a serem enviadas
	Private cNomeFun   := "" //Nome do Funcion�rio (RA_NOME)
	Private dDtAdm	   := SToD( "" ) //Data de Admiss�o do Funcion�rio (RA_ADMISSA)
	Private cCCustoAnt := ""
	Private cDeptoAnt  := ""
	Private cFuncaoAnt := ""
	Private cCargoAnt  := ""

	//Vari�veis das informa��es a serem envidas
	Private cCpfTrab	:= "" //CPF do Funcion�rio (RA_CIC)
	Private cMatricula	:= "" //Matr�cula do Funcion�rio a ser considerada no envio (RA_CODUNIC)
	Private cCodCateg	:= "" //Categoria do Funcion�rio (RA_CATEFD)
	Private aAmbExp		:= {} //Ambiente de Exposi��o do Funcion�rio
	Private cDscAtivDes	:= "" //Descri��o das Atividades do Funcion�rio (TN5_DESCRI ou TN5_NOMTAR/Q3_DESCDET ou Q3_DESCSUM/RJ_DESCREQ ou RJ_DESC/Q3_DESCDET ou Q3_DESCSUM + TN5_DESCRI ou TN5_NOMTAR)
	Private aRisTrat 	:= {} //Riscos a que o Funcion�rio est� exposto
	Private aRespAmb    := {} //Respons�vel pelos Registros Ambientais

	//Define os valores padr�es para os par�metros
	Default nOper	:= 3
	Default lIncons	:= .F.

	//Caso for integra��o via Middleware
	If lMiddleware
	
		//Adiciona as tabelas do Middleware
		aAdd( aTbls, "RJ9" )
		aAdd( aTbls, "RJE" )

	EndIf

	//Posiciona no registro do funcion�rio na SRA
	dbSelectArea( "SRA" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "SRA" ) + cNumMat )

	//Salva as informa��es da filial de origem
	cCCustoAnt := SRA->RA_CC
	cDeptoAnt  := SRA->RA_DEPTO
	cFuncaoAnt := SRA->RA_CODFUNC
	cCargoAnt  := SRA->RA_CARGO

	//Caso for chamada pelo GPEA180
	If lGPEA180

		//Altera o valor dos campos para considerar corretamente os dados da filial destino
		MDTChgSRA( .T., aGPEA180 )

	EndIf

	//Salva as informa��es nas vari�veis
	cNomeFun := SRA->RA_NOME //Nome do Funcion�rio
	dDtAdm	 := SRA->RA_ADMISSA //Data de Admiss�o do Funcion�rio
	cCCusto	 := SRA->RA_CC //Centro de Custo do Funcion�rio
	cDepto	 := SRA->RA_DEPTO //Departamento do Funcion�rio
	cFuncao	 := SRA->RA_CODFUNC //Fun��o do Funcion�rio

	//Caso for chamada pelo GPEA180, altera a filial para buscar as informa��es da filial de destino
	If lGPEA180

		//Caso a empresa destino seja diferente da empresa atual
		If cEmpAnt <> cEmpDes

			//Caso Middleware
			If lMiddleware

				//Posiciona a SM0 na empresa destino
				MDTPosSM0( cEmpDes, cFilDes )

			EndIf

			//Abre as tabelas na empresa destino
			MDTChgEmp( aTbls, cEmpAnt, cEmpDes )

			//Abre o SX6 na empresa destino
			fOpenSX6( cEmpDes )

			//Posiciona na empresa destino
			cEmpAnt := cEmpDes

		EndIf

		//Posiciona na filial destino
		cFilAnt := cFilDes

	EndIf

	//Busca da informa��o a ser enviada na tag <cpfTrab>
	cCpfTrab := SRA->RA_CIC //CPF do Funcion�rio

	//Busca da informa��o a ser enviada na tag <matricula>
	cMatricula := IIf( lGPEA180, aGPEA180[ 1, 14 ], SRA->RA_CODUNIC ) //C�digo �nico do Funcion�rio

	//Busca da informa��o a ser enviada na tag <matricula>
	cCodCateg := SRA->RA_CATEFD //Categoria do Funcion�rio

	//O valor da tag <dtIniCondicao> � passado por par�metro
	//Informar a data em que o trabalhador iniciou as atividades nas condi��es descritas ou a data de in�cio da obrigatoriedade deste evento
	//para o empregador no eSocial, a que for mais recente
	If dDtIniCond < dDtEsoc

		//Define o in�cio da condi��o como sendo o in�cio de obrigatoriedade do eSocial
		dDtIniCond := dDtEsoc

	EndIf

	//Busca da informa��o a ser enviada nas tags <localAmb>, <dscSetor>, <tpInsc> e <nrInsc>
	aAmbExp := fGetAmbExp( cCCusto, cDepto, cFuncao, cNumMat, dDtIniCond )

	//Busca da informa��o a ser enviada na tag <dscAtivDes>
	cDscAtivDes := fGetDscAti( cNumMat, dDtIniCond, aGPEA180 )

	//Busca da informa��o a ser enviada nas tags <codAgNoc>, <dscAgNoc>, <tpAval>, <intConc>, <limTol>, <unMed>, <tecMedicao>, <utilizEPC>,
	//<eficEpc>, <utilizEPI>, <docAval>, <dscEPI>, <eficEpi>, <medProtecao>, <condFuncto>, <usoInint>, <przValid>, <periodicTroca> e <higienizacao>
	aRisTrat := fGetRisExp( cNumMat, dDtIniCond, nOper, lIncons )

	//Busca da informa��o a ser enviada nas tags <cpfResp>, <ideOC>, <dscOC>, <nrOC> e <ufOC>
	aRespAmb := fGetResAmb( dDtIniCond, aRisTrat )

	//Caso for verifica��o das inconsist�ncias
	If lIncons

		//Analisa as inconsist�ncias
		fInconsis( @aIncEnv, dDtIniCond, cNumMat, cCCusto, cDepto, cFuncao )

	Else

		//Carrega o xml do evento
		cRet := fCarrRis( cValToChar( nOper ), dDtIniCond, cChave )

	EndIf

	//Caso for chamada pelo GPEA180, altera a empresa e filial para a atual ap�s ter buscado as informa��es
	If lGPEA180

		//Caso a empresa destino seja diferente da empresa atual
		If cEmpAnt <> cEmpBkp

			//Caso Middleware
			If lMiddleware

				//Posiciona a SM0 na filial logada novamente
				MDTPosSM0( cEmpBkp, cFilBkp )

			EndIf

			//Abre as tabelas na empresa logada novamente
			MDTChgEmp( aTbls, cEmpDes, cEmpBkp )

			//Abre o SX6 na empresa logada novamente
			fOpenSX6( cEmpBkp )

			//Posiciona na empresa logada novamente
			cEmpAnt := cEmpBkp

		EndIf

		//Posiciona na filial logada novamente
		cFilAnt := cFilBkp

	EndIf

	//Caso for chamada pelo GPEA180
	If lGPEA180

		//Volta o valor dos campos
		MDTChgSRA( .F., aGPEA180 )

	EndIf

	//Reposiciona as tabelas na filial logada
	RestArea( aAreaTOQ )
	RestArea( aAreaTOR )
	RestArea( aAreaTOS )
	RestArea( aAreaTOT )
	RestArea( aAreaTOU )
	RestArea( aAreaTNE )
	RestArea( aAreaTN6 )
	RestArea( aAreaSR8 )
	RestArea( aAreaSQ3 )
	RestArea( aAreaTN5 )
	RestArea( aAreaSRJ )
	RestArea( aAreaTN0 )
	RestArea( aAreaTO9 )
	RestArea( aAreaTMA )
	RestArea( aAreaTLK )
	RestArea( aAreaTO0 )
	RestArea( aAreaTMK )
	RestArea( aAreaTNX )
	RestArea( aAreaTNF )
	RestArea( aAreaTN3 )
	RestArea( aAreaTL0 )
	RestArea( aAreaTJF )
	RestArea( aAreaSB1 )
	RestArea( aAreaCTT )
	RestArea( aAreaSQB )
	RestArea( aAreaC92 )
	RestArea( aAreaC87 )
	RestArea( aAreaTO1 )
	RestArea( aAreaV5Y )
	RestArea( aAreaV3F )
	RestArea( aAreaRJ9 )
	RestArea( aAreaRJE )

	//Retorna as informa��es da empresa e filial logada
	cEmpAnt := cEmpBkp
	cFilAnt := cFilBkp
	cArqTab := cArqBkp
	
	//Retorna a �rea posicionada
	RestArea( aAreaBk )

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fCarrRis
Monta o Xml dos Riscos para envio ao Governo

@return cXml Caracter Estrutura XML a ser enviada para o SIGATAF/Middleware

@sample fCarrRis( "3", 01/06/2021 )

@param cOper, Caracter, Indica a opera��o que est� sendo realizada (3-Inclus�o/4-Altera��o/5-Exclus�o)
@param dDtIniCond, Data, Data de refer�ncia que o sistema considera como in�cio de exposi��o do funcion�rio
@param cChave, Caracter, Chave atual do registro a ser utilizada na busca do registro na RJE

@author Luis Fellipy Bett
@since 30/08/2018
/*/
//---------------------------------------------------------------------
Static Function fCarrRis( cOper, dDtIniCond, cChave )

	Local cXml	:= ""
	Local aEPIs	:= {}

	//Contadores
	Local nRis	:= 0
	Local nEPI	:= 0
	Local nRes	:= 0

	If cOper == "5" //Caso for exclus�o define como altera��o
		cOper := "4"
	EndIf

	//Cria o cabe�alho do Xml com o ID, informa��es do Evento e Empregador
	MDTGerCabc( @cXml, "S2240", cOper, cChave )

	//FUNCIONARIO
	cXml += 		'<ideVinculo>'
	cXml += 			'<cpfTrab>'		+ cCpfTrab		+ '</cpfTrab>' //Obrigat�rio
	If !MDTVerTSVE( cCodCateg ) //Caso n�o for TSVE
		cXml +=			'<matricula>'	+ cMatricula	+ '</matricula>' //Obrigat�rio
	Else
		cXml +=			'<codCateg>'	+ cCodCateg		+ '</codCateg>' //Obrigat�rio
	EndIf
	cXml += 		'</ideVinculo>'

	//MONITORAMENTO DA SA�DE DO TRABALHADOR
	cXml += 		'<infoExpRisco>'
	cXml += 			'<dtIniCondicao>' + MDTAjsData( dDtIniCond ) + '</dtIniCondicao>' //Obrigat�rio
	If Len( aAmbExp ) > 0
		cXml += 		'<infoAmb>'
		cXml += 			'<localAmb>'	+ aAmbExp[ 1, 2 ]	+ '</localAmb>' //Obrigat�rio
		cXml += 			'<dscSetor>'	+ aAmbExp[ 1, 3 ]	+ '</dscSetor>' //Obrigat�rio
		cXml += 			'<tpInsc>'		+ aAmbExp[ 1, 4 ]	+ '</tpInsc>' //Obrigat�rio
		cXml += 			'<nrInsc>'		+ aAmbExp[ 1, 5 ]	+ '</nrInsc>' //Obrigat�rio
		cXml += 		'</infoAmb>'
	EndIf
	cXml += 			'<infoAtiv>'
	cXml += 				'<dscAtivDes>'	+ cDscAtivDes	+ '</dscAtivDes>' //Obrigat�rio
	cXml += 			'</infoAtiv>'

	If Len( aRisTrat ) > 0
		For nRis := 1 To Len( aRisTrat )

			cXml += 	'<agNoc>'
			cXml += 		'<codAgNoc>'		+ aRisTrat[ nRis, 3 ]		+ '</codAgNoc>' //Obrigat�rio
			cXml +=			'<dscAgNoc>'		+ aRisTrat[ nRis, 4 ]		+ '</dscAgNoc>'
			If aRisTrat[ nRis, 3 ] != "09.01.001" //Caso n�o for aus�ncia de fator de risco
				cXml +=		'<tpAval>'			+ aRisTrat[ nRis, 5 ]		+ '</tpAval>' //Obrigat�rio
			EndIf
			If aRisTrat[ nRis, 5 ] == "1" //Se o tipo de avalia��o for quantitativa
				cXml += 	'<intConc>'			+ aRisTrat[ nRis, 6 ]		+ '</intConc>'
				If aRisTrat[ nRis, 3 ] $ "01.18.001/02.01.014"
					cXml +=	'<limTol>'			+ aRisTrat[ nRis, 7 ]		+ '</limTol>'
				EndIf
				cXml += 	'<unMed>'			+ aRisTrat[ nRis, 8 ]		+ '</unMed>'
				cXml += 	'<tecMedicao>'		+ aRisTrat[ nRis, 9 ]		+ '</tecMedicao>'
			EndIf
			cXml += 		'<epcEpi>'
			cXml += 			'<utilizEPC>'	+ aRisTrat[ nRis, 10 ]		+ '</utilizEPC>' //Obrigat�rio
			If aRisTrat[ nRis, 10 ] == "2"
				cXml +=			'<eficEpc>'		+ aRisTrat[ nRis, 11 ]		+ '</eficEpc>'
			EndIf
			cXml += 			'<utilizEPI>'	+ aRisTrat[ nRis, 12 ]		+ '</utilizEPI>' //Obrigat�rio
			If aRisTrat[ nRis, 12 ] == "2"
				aEPIs := aClone( aRisTrat[ nRis, 13 ] )
				If Len( aEPIs ) > 0
					cXml +=		'<eficEpi>'		+ aEPIs[ Len( aEPIs ), 4 ]	+ '</eficEpi>'
					For nEPI := 1 To Len( aEPIs )
						cXml += 	'<epi>'
						If !Empty( aEPIs[ nEPI, 2 ] )
							cXml +=		'<docAval>'			+ aEPIs[ nEPI, 2 ] + '</docAval>' //Certificado de Aprova��o ou Documento de Avalia��o do EPI
						Else
							cXml += 	'<dscEPI>'			+ aEPIs[ nEPI, 3 ] + '</dscEPI>'
						EndIf
						cXml += 	'</epi>'
					Next nEPI
					cXml += 		'<epiCompl>'
					cXml += 			'<medProtecao>'		+ aEPIs[ Len( aEPIs ), 5 ] + '</medProtecao>'
					cXml += 			'<condFuncto>'		+ aEPIs[ Len( aEPIs ), 6 ] + '</condFuncto>'
					cXml += 			'<usoInint>'		+ aEPIs[ Len( aEPIs ), 7 ] + '</usoInint>'
					cXml += 			'<przValid>'		+ aEPIs[ Len( aEPIs ), 8 ] + '</przValid>'
					cXml += 			'<periodicTroca>'	+ aEPIs[ Len( aEPIs ), 9 ] + '</periodicTroca>'
					cXml += 			'<higienizacao>'	+ aEPIs[ Len( aEPIs ), 10 ] + '</higienizacao>'
					cXml += 		'</epiCompl>'
				EndIf
			EndIf
			cXml += 		'</epcEpi>'
			cXml += 	'</agNoc>'
		Next nRis
	Else
		cXml += 		'<agNoc>'
		cXml += 			'<codAgNoc>09.01.001</codAgNoc>'
		cXml += 		'</agNoc>'
	EndIf
	For nRes := 1 To Len( aRespAmb )
		cXml += 		'<respReg>'
		cXml += 			'<cpfResp>'	+ aRespAmb[ nRes, 3 ]	+ '</cpfResp>' //Obrigat�rio
		If !Empty( aRespAmb[ nRes, 4 ] )
			cXml +=			'<ideOC>'	+ aRespAmb[ nRes, 4 ]	+ '</ideOC>' //Obrigat�rio
		EndIf
		If !Empty( aRespAmb[ nRes, 4 ] ) .And. aRespAmb[ nRes, 4 ] == "9"
			cXml += 		'<dscOC>'	+ aRespAmb[ nRes, 5 ]	+ '</dscOC>'
		EndIf
		If !Empty( aRespAmb[ nRes, 6 ] )
			cXml +=			'<nrOC>'	+ aRespAmb[ nRes, 6 ]	+ '</nrOC>' //Obrigat�rio
		EndIf
		If !Empty( aRespAmb[ nRes, 7 ] )
			cXml +=			'<ufOC>'	+ aRespAmb[ nRes, 7 ]	+ '</ufOC>' //Obrigat�rio
		EndIf
		cXml += 		'</respReg>'
	Next nRes
	cXml += 		'</infoExpRisco>'
	cXml += 	'</evtExpRisco>'
	cXml += '</eSocial>'

Return cXml

//---------------------------------------------------------------------
/*/{Protheus.doc} fInconsis
Valida as informa��es a serem enviadas para o SIGATAF/Middleware

@return	Nil, Nulo

@sample	fInconsis( aIncEnv, 21/10/2021, "0000001", "000031", "000000002", "00003" )

@param	aIncEnv, Array, Array passado por refer�ncia que ir� receber os logs de inconsist�ncias (se houver)
@param	dDtIniCond, Data, Data de in�cio de exposi��o
@param	cNumMat, Caracter, Matr�cula do funcion�rio
@param	cCCusto, Caracter, Centro de custo do funcion�rio
@param	cDepto, Caracter, Departamento do funcion�rio
@param	cFuncao, Caracter, Fun��o do funcion�rio

@author	Luis Fellipy Bett
@since	30/08/2018 - Refatorada em: 17/02/2021
/*/
//---------------------------------------------------------------------
Static Function fInconsis( aIncEnv, dDtIniCond, cNumMat, cCCusto, cDepto, cFuncao )

	//Vari�veis de controle
	Local aArea	  := GetArea()
	Local cFilBkp := cFilAnt

	Local lVldNrIns	 := .T.
	Local nCont		 := 0
	Local cTarefas	 := ""
	Local cBarra	 := " / "
	Local aTarefas	 := {}
	Local oModel	 := Nil
	Local lGerXml	 := IsInCallStack( "MDTGeraXml" ) //Caso for gera��o de xml
	Local cEntAmb	 := SuperGetMv( "MV_NG2EAMB", .F., "1" ) //Indica qual entidade ser� considerada no relacionamento com o ambiente
	Local lVldDsc	 := IIf( SuperGetMv( "MV_NG2TDES", .F., "1" ) == "1", ( lGPEA010 .And. lGerXml ) .Or. ( !lGPEA010 .And. !lGPEA180 .And. !lMDTA090 .And. !lMDTA165 ), .T. )
	Local cStrFil	 := STR0062 + ": " + AllTrim( cFilEnv ) //Filial: XXX
	Local cStrFunc	 := STR0001 + ": " + AllTrim( cNumMat ) + " - " + AllTrim( cNomeFun ) //Funcion�rio: XXX - XXXXX
	Local cStrCCus	 := STR0051 + ": " + AllTrim( cCCusto ) + " - " + AllTrim( Posicione( "CTT", 1, xFilial( "CTT" ) + cCCusto, "CTT_DESC01" ) ) //Centro de Custo: XXX - XXXXX
	Local cStrDepto  := STR0054 + ": " + AllTrim( cDepto ) + " - " + AllTrim( Posicione( "SQB", 1, xFilial( "SQB" ) + cDepto, "QB_DESCRIC" ) ) //Departamento: XXX - XXXXX
	Local cStrFuncao := STR0055 + ": " + AllTrim( cFuncao ) + " - " + AllTrim( Posicione( "SRJ", 1, xFilial( "SRJ" ) + cFuncao, "RJ_DESC" ) ) //Fun��o: XXX - XXXXX

	//Busca a filial de envio a ser considerada nas valida��es
	cFilAnt := cFilEnv

	Help := .T. //Desativa as mensagens de Help

	//Valida��o da tag <cpfTrab> - CPF do trabalhador
	//Preencher com o n�mero do CPF do trabalhador.
	If Empty( cCpfTrab )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0010 + ": " + STR0004 ) //Funcion�rio: XXX - XXXXX / CPF: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !CHKCPF( cCpfTrab )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0010 + ": " + cCpfTrab ) //Funcion�rio: XXX - XXXXX / CPF: XXX
		aAdd( aIncEnv, STR0005 + ": " + STR0009 ) //Valida��o: Deve ser um n�mero de CPF v�lido
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <matricula> - Matr�cula atribu�da ao trabalhador pela empresa
	//Deve corresponder � matr�cula informada pelo empregador no evento S-2190, S-2200 ou S-2300 do respectivo contrato. N�o preencher no caso de
	//Trabalhador Sem V�nculo de Emprego/Estatut�rio - TSVE sem informa��o de matr�cula no evento S-2300
	//A valida��o de exist�ncia de um registro S-2190, S-2200 ou S-2300 j� � realizada no come�o do envio, atrav�s da fun��o MDTVld2200

	//Valida��o da tag <codCateg> - C�digo da categoria do trabalhador
	//Informa��o obrigat�ria e exclusiva se n�o houver preenchimento de matricula. Se informado, deve ser um c�digo v�lido e existente na Tabela 01.
	If Empty( cMatricula ) .And. Empty( cCodCateg )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0011 + ": " + STR0004 ) //Funcion�rio: XXX - XXXXX / Categoria: Em branco
		aAdd( aIncEnv, '' )
	ElseIf Empty( cMatricula ) .And. !ExistCPO( "C87", cCodCateg, 2 )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0011 + ": " + cCodCateg ) //Funcion�rio: XXX - XXXXX / Categoria: XXX
		aAdd( aIncEnv, STR0005 + ": " + STR0012 ) //Valida��o: Deve ser um c�digo v�lido e existente na tabela 01 do eSocial
		aAdd( aIncEnv, '' )
	EndIf

	//Valida��o da tag <dtIniCondicao> - Data em que o trabalhador iniciou as atividades nas condi��es descritas ou a data de in�cio da
	//obrigatoriedade deste evento para o empregador no eSocial, a que for mais recente
	//Valida��o: Deve ser uma data v�lida, igual ou posterior � data de admiss�o do v�nculo a que se refere. N�o pode ser anterior � data de
	//in�cio da obrigatoriedade deste evento para o empregador no eSocial, nem pode ser posterior a 30 (trinta) dias da data atual.
	If Empty( dDtIniCond )
		aAdd( aIncEnv, cStrFil + " / " + STR0013 + ": " + STR0004 ) //Data de In�cio das Atividades: Em Branco
		aAdd( aIncEnv, '' )
	ElseIf !( dDtIniCond >= dDtAdm .And. dDtIniCond >= dDtEsoc .And. IIf( ( lGPEA010 .And. lGerXml ) .Or. !lGPEA010, dDtIniCond <= ( dDataBase + 30 ), .T. ) )
		aAdd( aIncEnv, cStrFil + " / " + STR0013 + ": " + DToC( dDtIniCond ) ) //Data de In�cio das Atividades: XX/XX/XXXX
		aAdd( aIncEnv, STR0005 + ": " + STR0014 + ":" ) //Valida��o: Deve ser uma data v�lida e:
		aAdd( aIncEnv, "* " + STR0015 + ": " + DToC( dDtAdm ) ) //* Igual ou posterior � data de admiss�o do trabalhador: XX/XX/XXXX
		aAdd( aIncEnv, "* " + STR0016 + ": " + DToC( dDtEsoc ) ) //* Igual ou posterior � data de in�cio de obrigatoriedade dos eventos de SST ao eSocial: XX/XX/XXXX
		aAdd( aIncEnv, "* " + STR0017 + ": " + DToC( dDataBase + 30 ) ) //* Igual ou anterior � 30 dias a partir da data atual: XX/XX/XXXX
		aAdd( aIncEnv, '' )
	EndIf

	//Ambiente de trabalho do funcion�rio
	If Len( aAmbExp ) > 0

		//Valida��o da tag <localAmb> - Tipo de estabelecimento do ambiente de trabalho
		//Valores v�lidos: 1 - Estabelecimento do pr�prio empregador ou 2 - Estabelecimento de terceiros
		If Empty( aAmbExp[ 1, 2 ] )
			aAdd( aIncEnv, cStrFil + " / " + STR0018 + ": " + aAmbExp[ 1, 1 ] + " / " + STR0019 + ": " + STR0004 ) //Ambiente: XXX / Tipo do Estabelecimento: Em Branco
			aAdd( aIncEnv, '' )
		ElseIf !( aAmbExp[ 1, 2 ] $ "1/2" )
			aAdd( aIncEnv, cStrFil + " / " + STR0018 + ": " + aAmbExp[ 1, 1 ] + " / " + STR0019 + ": " + aAmbExp[ 1, 2 ] ) //Ambiente: XXX / Tipo do Estabelecimento: XXX
			aAdd( aIncEnv, STR0005 + ": " + STR0020 ) //Valida��o: Deve ser igual a 1- Estabelecimento do Empregador ou 2- Estabelecimento de Terceiro
			aAdd( aIncEnv, '' )
		EndIf

		//Valida��o da tag <dscSetor> - Descri��o do lugar administrativo, na estrutura organizacional da empresa, onde o trabalhador exerce suas
		//atividades laborais.
		//Informa��o obrigat�ria
		If Empty( aAmbExp[ 1, 3 ] )
			aAdd( aIncEnv, cStrFil + " / " + STR0018 + ": " + aAmbExp[ 1, 1 ] + " / " + STR0021 + ": " + STR0004 ) //Ambiente: XXX / Descri��o: Em Branco
			aAdd( aIncEnv, '' )
		EndIf

		//Valida��o da tag <tpInsc> - C�digo correspondente ao tipo de inscri��o, conforme Tabela 05
		//Valores v�lidos: 1 - CNPJ, 3 - CAEPF ou 4 - CNO
		If Empty( aAmbExp[ 1, 4 ] )
			aAdd( aIncEnv, cStrFil + " / " + STR0018 + ": " + aAmbExp[ 1, 1 ] + " / " + STR0003 + ": " + STR0004 ) //Ambiente: XXX / Tipo de Inscri��o: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !( aAmbExp[ 1, 4 ] $ "1/3/4" )
			aAdd( aIncEnv, cStrFil + " / " + STR0018 + ": " + aAmbExp[ 1, 1 ] + " / " + STR0003 + ": " + aAmbExp[ 1, 4 ] ) //Ambiente: XXX / Tipo de Inscri��o: XXX
			aAdd( aIncEnv, STR0005 + ": " + STR0022 ) //Valida��o: Deve ser igual a 1- CNPJ, 3- CAEPF ou 4- CNO
			aAdd( aIncEnv, '' )
		EndIf

		//Valida��o da tag <nrInsc> - N�mero de inscri��o onde est� localizado o ambiente
		//Valida��o: Deve ser um identificador v�lido, compat�vel com o conte�do do campo infoAmb/tpInsc e: a) Se localAmb = [1], deve ser v�lido
		//e existente na Tabela de Estabelecimentos (S-1005); b) Se localAmb = [2], deve ser diferente dos estabelecimentos informados na Tabela
		//S-1005 e, se infoAmb/tpInsc = [1] e o empregador for pessoa jur�dica, a raiz do CNPJ informado deve ser diferente da constante em S-1000.
		//Caso o tipo de inscri��o seja igual a 1 (CNPJ), valida primeiramente se � um CNPJ v�lido
		If Empty( aAmbExp[ 1, 5 ] )
			aAdd( aIncEnv, cStrFil + " / " + STR0018 + ": " + aAmbExp[ 1, 1 ] + " / " + STR0007 + ": " + STR0004 ) //Ambiente: XXX / N�mero de Inscri��o: Em branco
			aAdd( aIncEnv, '' )
		Else
			If !Empty( aAmbExp[ 1, 4 ] ) //Caso o tipo de inscri��o estiver preenchido, valida o n�mero da inscri��o
				If aAmbExp[ 1, 4 ] == "1" //Caso o tipo de inscri��o for igual a CNPJ, valida se � um CNPJ v�lido
					If !CGC( aAmbExp[ 1, 5 ] )
						aAdd( aIncEnv, cStrFil + " / " + STR0018 + ": " + aAmbExp[ 1, 1 ] + " / " + STR0007 + ": " + aAmbExp[ 1, 5 ] ) //Ambiente: XXX / N�mero de Inscri��o: XXX
						aAdd( aIncEnv, STR0005 + ": " + STR0008 ) //Valida��o: Deve ser um n�mero de CNPJ v�lido
						aAdd( aIncEnv, '' )
						lVldNrIns := .F.
					EndIf
				EndIf

				If lVldNrIns
					If !MDTNrInsc( aAmbExp[ 1, 2 ], aAmbExp[ 1, 4 ], aAmbExp[ 1, 5 ], cNumMat ) //Valida o N�mero de Inscri��o do Ambiente
						aAdd( aIncEnv, cStrFil + " / " + STR0018 + ": " + aAmbExp[ 1, 1 ] + " / " + STR0007 + ": " + aAmbExp[ 1, 5 ] ) //Ambiente: XXX / N�mero de Inscri��o: XXX
						aAdd( aIncEnv, STR0005 + ": " + STR0023 ) //Valida��o: 1) Deve constar na tabela S-1005 se o local do ambiente for igual a 'Estabelecimento do pr�prio empregador'.
						aAdd( aIncEnv, STR0024 ) //2) Deve ser diferente dos estabelecimentos informados na Tabela S-1005 se o local do ambiente for igual a 'Estabelecimento de
						aAdd( aIncEnv, STR0025 ) //terceiros' e diferente do CNPJ base indicado em S-1000 se o tipo de inscri��o do local do ambiente for igual a CNPJ.
						aAdd( aIncEnv, '' )
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		If cEntAmb == "1" //Centro de Custo

			aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + cStrCCus ) //Funcion�rio: XXX - XXXXX / Centro de Custo: XXX - XXXXX
			aAdd( aIncEnv, STR0026 ) //N�o foi encontrado um Ambiente relacionado ao Centro de Custo do funcion�rio
			aAdd( aIncEnv, '' )

		ElseIf cEntAmb == "2" //Departamento

			aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + cStrDepto ) //Funcion�rio: XXX - XXXXX / Departamento: XXX - XXXXX
			aAdd( aIncEnv, STR0056 ) //N�o foi encontrado um ambiente relacionado ao departamento do funcion�rio
			aAdd( aIncEnv, '' )

		ElseIf cEntAmb == "3" //Fun��o

			aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + cStrFuncao ) //Funcion�rio: XXX - XXXXX / Fun��o: XXX - XXXXX
			aAdd( aIncEnv, STR0057 ) //N�o foi encontrado um ambiente relacionado � fun��o do funcion�rio
			aAdd( aIncEnv, '' )

		ElseIf cEntAmb == "4" //Tarefa

			// Caso for chamada pelo cadastro de funcion�rio e � gera��o de xml ou
			// caso n�o for chamada via cadastro do funcion�rio (n�o existe como vincular uma tarefa ao funcion�rio antes de cadastr�-lo no GPEA010) ou
			// caso for transfer�ncia n�o existe como vincular o funcion�rio a alguma tarefa
			If ( lGPEA010 .And. lGerXml ) .Or. ( !lGPEA010 .And. !lGPEA180 .And. !lGPEM040 .And. !lMDTA090 )
			
				If lMDTA090 //Caso for chamado pela rotina de Tarefas do Funcion�rio
					oModel := FWModelActive()
				EndIf

				//Busca as tarefas que o funcion�rio realiza
				aTarefas := MDTGetTar( cNumMat, dDtIniCond, oModel )

				For nCont := 1 To Len( aTarefas )
					If nCont == Len( aTarefas )
						cBarra := ""
					EndIf
					cTarefas += AllTrim( aTarefas[ nCont, 1 ] ) + " - " + AllTrim( Posicione( "TN5", 1, xFilial( "TN5" ) + aTarefas[ nCont, 1 ], "TN5_NOMTAR" ) ) + cBarra
				Next nCont

				aAdd( aIncEnv, cStrFil + " / " + cStrFunc ) //Funcion�rio: XXX - XXXXX
				aAdd( aIncEnv, STR0060 + ": " + IIf( !Empty( cTarefas ), cTarefas, STR0061 ) ) //"Tarefas: XXX - XXXXX" ou "Nenhuma tarefa vinculada ao funcion�rio"
				aAdd( aIncEnv, STR0058 ) //N�o foi encontrado um ambiente relacionado � alguma tarefa do funcion�rio
				aAdd( aIncEnv, '' )

			EndIf

		ElseIf cEntAmb == "5" //Funcion�rio

			// Caso for chamada pelo cadastro de funcion�rio e � gera��o de xml ou
			// Caso n�o for chamada via cadastro do funcion�rio (n�o existe como vincular um ambiente ao funcion�rio antes de cadastr�-lo no GPEA010)
			// Mesmo caso para transfer�ncia do funcion�rio
			// Caso n�o for chamada via cadastro de ambiente (precisa permitir o v�nculo antes de validar)
			// Cadastro de tarefas tamb�m
			If ( lGPEA010 .And. lGerXml ) .Or. ( !lGPEA010 .And. !lGPEA180 .And. !lMDTA090 )
				aAdd( aIncEnv, cStrFil + " / " + cStrFunc ) //Funcion�rio: XXX - XXXXX
				aAdd( aIncEnv, STR0059 ) //"N�o foi encontrado um ambiente relacionado ao funcion�rio"
				aAdd( aIncEnv, '' )
			EndIf

		EndIf
	EndIf

	//Valida��o da tag <dscAtivDes> - Descri��o das atividades, f�sicas ou mentais, realizadas pelo trabalhador, por for�a do poder de comando a
	//que se submete. As atividades dever�o ser escritas com exatid�o, e de forma sucinta, com a utiliza��o de verbos no infinitivo impessoal.
	//Ex.: Distribuir panfletos, operar m�quina de envase, etc.
	//Informa��o obrigat�ria
	If lVldDsc .And. Empty( cDscAtivDes )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0027 + ": " + STR0004 ) //Funcion�rio: XXX - XXXXX / Descri��o das Atividades Realizadas: Em branco
		aAdd( aIncEnv, '' )
	EndIf

	//Agentes nocivos a que o funcion�rio est� exposto
	For nCont := 1 To Len( aRisTrat )

		//Valida��o da tag <codAgNoc> - C�digo do agente nocivo ao qual o trabalhador est� exposto
		//Valida��o: Deve ser um c�digo v�lido e existente na Tabela 24. N�o � poss�vel informar nenhum outro c�digo de agente nocivo quando
		//houver o c�digo [09.01.001].
		If Empty( aRisTrat[ nCont, 3 ] ) //<codAgNoc>
			aAdd( aIncEnv, cStrFil + " / " + STR0028 + ": " + aRisTrat[ nCont, 2 ] + " / " + STR0029 + ": " + STR0004 ) //Agente: XXX / C�digo eSocial: Em branco
			aAdd( aIncEnv, '' )
		ElseIf aRisTrat[ nCont, 3 ] != "09.01.001"
			If !ExistCPO( "V5Y", aRisTrat[ nCont, 3 ], 2 )
				aAdd( aIncEnv, cStrFil + " / " + STR0028 + ": " + aRisTrat[ nCont, 2 ] + " / " + STR0029 + ": " + aRisTrat[ nCont, 3 ] ) //Agente: XXX / C�digo eSocial: XXX
				aAdd( aIncEnv, STR0005 + ": " + STR0030 ) //Valida��o: Deve ser um c�digo v�lido e existente na tabela 24 do eSocial
				aAdd( aIncEnv, '' )
			EndIf
		EndIf

		//Valida��o da tag <dscAgNoc> - Descri��o do agente nocivo
		//Valida��o: Preenchimento obrigat�rio se codAgNoc = [01.01.001, 01.02.001, 01.03.001, 01.04.001, 01.05.001, 01.06.001, 01.07.001,
		//01.08.001, 01.09.001, 01.10.001, 01.12.001, 01.13.001, 01.14.001, 01.15.001, 01.16.001, 01.17.001, 01.18.001, 05.01.001].
		If Empty( aRisTrat[ nCont, 4 ] ) .And. aRisTrat[ nCont, 3 ] $ "01.01.001/01.02.001/01.03.001/01.04.001/01.05.001/01.06.001/01.07.001/01.08.001/01.09.001/01.10.001/01.12.001/01.13.001/01.14.001/01.15.001/01.16.001/01.17.001/01.18.001/05.01.001" //</dscAgNoc>
			aAdd( aIncEnv, cStrFil + " / " + STR0028 + ": " + aRisTrat[ nCont, 2 ] + " / " + STR0021 + ": " + STR0004 ) //Agente: XXX / Descri��o: Em branco
			aAdd( aIncEnv, '' )
		EndIf

		//Valida��o da tag <tpAval> - Tipo de avalia��o do agente nocivo
		//Valores v�lidos: 1 - Crit�rio quantitativo ou 2 - Crit�rio qualitativo
		//Valida��o: Preenchimento obrigat�rio e exclusivo se codAgNoc for diferente de [09.01.001].
		If aRisTrat[ nCont, 3 ] != "09.01.001"
			If Empty( aRisTrat[ nCont, 5 ] ) //</tpAval>
				aAdd( aIncEnv, cStrFil + " / " + STR0028 + ": " + aRisTrat[ nCont, 2 ] + " / " + STR0031 + ": " + STR0004 ) //Agente: XXX / Tipo de Avalia��o: Em branco
				aAdd( aIncEnv, '' )
			ElseIf !( aRisTrat[ nCont, 5 ] $ "1/2" )
				aAdd( aIncEnv, cStrFil + " / " + STR0028 + ": " + aRisTrat[ nCont, 2 ] + " / " + STR0031 + ": " + aRisTrat[ nCont, 5 ] ) //Agente: XXX / Tipo de Avalia��o: XXX
				aAdd( aIncEnv, STR0005 + ": " + STR0032 ) //Valida��o: Deve ser igual a 1- Crit�rio quantitativo ou 2- Crit�rio qualitativo
				aAdd( aIncEnv, '' )
			EndIf
		EndIf

		//Valida��o da tag <intConc> - Intensidade, concentra��o ou dose da exposi��o do trabalhador ao agente nocivo
		//Valida��o: Preenchimento obrigat�rio e exclusivo se tpAval = [1].
		If Empty( aRisTrat[ nCont, 6 ] ) .And. aRisTrat[ nCont, 5 ] == "1" //<intConc>
			aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0034 + ": " + STR0004 ) //Risco: XXX / Intensidade de Exposi��o: Em branco
			aAdd( aIncEnv, '' )
		EndIf

		//Valida��o da tag <limTol> - Limite de toler�ncia calculado para agentes espec�ficos
		//Valida��o: Preenchimento obrigat�rio e exclusivo se tpAval = [1] e codAgNoc = [01.18.001, 02.01.014].
		If Empty( aRisTrat[ nCont, 7 ] ) .And. aRisTrat[ nCont, 5 ] == "1" .And. aRisTrat[ nCont, 3 ] $ "01.18.001/02.01.014" //<limTol>
			aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0035 + ": " + STR0004 ) //Risco: XXX / Limite de Toler�ncia: Em branco
			aAdd( aIncEnv, '' )
		EndIf

		//Valida��o da tag <unMed> - Dose ou unidade de medida da intensidade ou concentra��o do agente
		//Valores v�lidos:
		// 1 - dose di�ria de ru�do
		// 2 - decibel linear (dB (linear))
		// 3 - decibel (C) (dB(C))
		// 4 - decibel (A) (dB(A))
		// 5 - metro por segundo ao quadrado (m/s�)
		// 6 - metro por segundo elevado a 1,75 (m/s^1,75)
		// 7 - parte de vapor ou g�s por milh�o de partes de ar contaminado (ppm)
		// 8 - miligrama por metro c�bico de ar (mg/m�)
		// 9 - fibra por cent�metro c�bico (f/cm�)
		// 10 - grau Celsius (�C)
		// 11 - metro por segundo (m/s)
		// 12 - porcentual
		// 13 - lux (lx)
		// 14 - unidade formadora de col�nias por metro c�bico (ufc/m�)
		// 15 - dose di�ria
		// 16 - dose mensal
		// 17 - dose trimestral
		// 18 - dose anual
		// 19 - watt por metro quadrado (W/m�)
		// 20 - amp�re por metro (A/m)
		// 21 - militesla (mT)
		// 22 - microtesla (?T)
		// 23 - miliamp�re (mA)
		// 24 - quilovolt por metro (kV/m)
		// 25 - volt por metro (V/m)
		// 26 - joule por metro quadrado (J/m�)
		// 27 - milijoule por cent�metro quadrado (mJ/cm�)
		// 28 - milisievert (mSv)
		// 29 - milh�o de part�culas por dec�metro c�bico (mppdc)
		// 30 - umidade relativa do ar (UR (%))
		//Valida��o: Preenchimento obrigat�rio e exclusivo se tpAval = [1].
		If aRisTrat[ nCont, 5 ] == "1" // Se o agente for quantitativo
			If Empty( aRisTrat[ nCont, 8 ] ) //<unMed>
				aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0036 + ": " + STR0004 ) //Risco: XXX / Unidade de Medida: Em branco
				aAdd( aIncEnv, '' )
			Else
				If !ExistCPO( "V3F", aRisTrat[ nCont, 8 ], 2 )
					aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0036 + ": " + aRisTrat[ nCont, 8 ] ) //Risco: XXX / Unidade de Medida: XXX
					aAdd( aIncEnv, STR0005 + ": " + STR0037 ) //Valida��o: Deve ser um c�digo v�lido e existente na descri��o da tag <unMed> do evento S-2240 do eSocial
					aAdd( aIncEnv, '' )
				EndIf
			EndIf
		EndIf

		//Valida��o da tag <tecMedicao> - T�cnica utilizada para medi��o da intensidade ou concentra��o
		//Valida��o: Preenchimento obrigat�rio e exclusivo se tpAval = [1].
		If Empty( aRisTrat[ nCont, 9 ] ) .And. aRisTrat[ nCont, 5 ] == "1" //<tecMedicao>
			aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0038 + ": " + STR0004 ) //Risco: XXX / T�cnica de Medi��o: Em branco
			aAdd( aIncEnv, '' )
		EndIf

		//Valida��o da tag <utilizEPC> - O empregador implementa medidas de prote��o coletiva (EPC) para eliminar ou reduzir a exposi��o dos
		//trabalhadores ao agente nocivo?
		//Valores v�lidos: 0 - N�o se aplica, 1 - N�o implementa ou 2 - Implementa
		If Empty( aRisTrat[ nCont, 10 ] ) //<utilizEPC>
			aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0039 + ": " + STR0004 ) //Risco: XXX / Indicativo de Implementa��o de EPC: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !( aRisTrat[ nCont, 10 ] $ "0/1/2" )
			aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0039 + ": " + aRisTrat[ nCont, 10 ] ) //Risco: XXX / Indicativo de Implementa��o de EPC: XXX
			aAdd( aIncEnv, STR0005 + ": " + STR0040 ) //Valida��o: Deve ser igual a 0- N�o se aplica, 1- N�o implementa ou 2- Implementa
			aAdd( aIncEnv, '' )
		EndIf

		//Valida��o da tag <eficEpc> - Os EPCs s�o eficazes na neutraliza��o dos riscos ao trabalhador?
		//Valores v�lidos: S - Sim ou N - N�o
		//Valida��o: Preenchimento obrigat�rio e exclusivo se utilizEPC = [2].
		If Empty( aRisTrat[ nCont, 11 ] ) .And. aRisTrat[ nCont, 10 ] == "2"
			aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0041 + ": " + STR0004 ) //Risco: XXX / Indicativo de Efi�ncia dos EPC's: Em branco
			aAdd( aIncEnv, '' )
		EndIf

		//Valida��o da tag <utilizEPI> - Utiliza��o de EPI
		//Valores v�lidos: 0 - N�o se aplica, 1 - N�o utilizado ou 2 - Utilizado
		If Empty( aRisTrat[ nCont, 12 ] ) //<utilizEPI>
			aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0042 + ": " + STR0004 ) //Risco: XXX / Indicativo de Utiliza��o de EPI: Em branco
			aAdd( aIncEnv, '' )
		EndIf

		//Caso n�o for cadastro de risco
		If ( lGPEA010 .And. lGerXml ) .Or. ( !lGPEA010 .And. !lGPEA180 .And. !lMDTA165 .And. !lMDTA180 )
			//Caso a tag <utilizEPI> seja igual a 'Sim'
			If !Empty( aRisTrat[ nCont, 12 ] ) .And. aRisTrat[ nCont, 12 ] == "2"
				//Valida��o de exist�ncia de EPI's entregues ao funcion�rio
				If Len( aRisTrat[ nCont, 13 ] ) == 0
					aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0042 + ": " + aRisTrat[ nCont, 12 ] ) //Risco: XXX / Indicativo de Utiliza��o de EPI: XXX
					aAdd( aIncEnv, cStrFunc ) //Funcion�rio: XXX - XXXXX
					aAdd( aIncEnv, STR0005 + ": " + STR0063 ) //"O risco foi definido com o indicativo de utiliza��o de EPI igual a 'Sim' por�m n�o existem"
					aAdd( aIncEnv, STR0064 ) //"EPI's necess�rios a esse risco entregues ao funcion�rio"
					aAdd( aIncEnv, '' )
				EndIf
			EndIf
		EndIf

	Next nCont

	//Respons�vel pelos Registros Ambientais
	If Len( aRespAmb ) > 0
		For nCont := 1 To Len( aRespAmb )

			//Valida��o da tag <cpfResp> - CPF do respons�vel pelos registros ambientais
			//Valida��o: Deve ser um CPF v�lido.
			If Empty( aRespAmb[ nCont, 3 ] ) //<cpfResp>
				aAdd( aIncEnv, cStrFil + " / " + STR0044 + ": " + aRespAmb[ nCont, 1 ] + " - " + aRespAmb[ nCont, 2 ] + " / " + STR0010 + ": " + STR0004 ) //Respons�vel pelos Registros Ambientais: XXX - XXX / CPF: Em branco
				aAdd( aIncEnv, '' )
			ElseIf !CHKCPF( aRespAmb[ nCont, 3 ] ) //<cpfResp>
				aAdd( aIncEnv, cStrFil + " / " + STR0044 + ": " + aRespAmb[ nCont, 1 ] + " - " + aRespAmb[ nCont, 2 ] + " / " + STR0010 + ": " + aRespAmb[ nCont, 3 ] ) //Respons�vel pelos Registros Ambientais: XXX - XXX / CPF: XXX
				aAdd( aIncEnv, STR0005 + ": " + STR0009 ) //Valida��o: Deve ser um n�mero de CPF v�lido
				aAdd( aIncEnv, '' )
			EndIf

			//Valida��o da tag <ideOC> - �rg�o de classe ao qual o respons�vel pelos registros ambientais est� vinculado
			//Valores v�lidos: 1 - Conselho Regional de Medicina - CRM, 4 - Conselho Regional de Engenharia e Agronomia - CREA ou 9 - Outros
			//Preenchimento obrigat�rio se codAgNoc for diferente de [09.01.001].
			If Len( aRisTrat ) > 0 //Caso o funcion�rio esteja exposto a algum risco diferente de 09.01.001
				If Empty( aRespAmb[ nCont, 4 ] ) //<ideOC>
					aAdd( aIncEnv, cStrFil + " / " + STR0044 + ": " + aRespAmb[ nCont, 1 ] + " - " + aRespAmb[ nCont, 2 ] + " / " + STR0045 + ": " + STR0004 ) //Respons�vel pelos Registros Ambientais: XXX - XXXXX / �rg�o de Classe: Em branco
					aAdd( aIncEnv, '' )
				ElseIf !( aRespAmb[ nCont, 4 ] $ "1/4/9" )
					aAdd( aIncEnv, cStrFil + " / " + STR0044 + ": " + aRespAmb[ nCont, 1 ] + " - " + aRespAmb[ nCont, 2 ] + " / " + STR0045 + ": " + aRespAmb[ nCont, 4 ] ) //Respons�vel pelos Registros Ambientais: XXX - XXXXX / �rg�o de Classe: XXX
					aAdd( aIncEnv, STR0005 + ": " + STR0046 ) //Valida��o: Deve ser igual a 1- CRM, 4- CREA ou 9- Outros
					aAdd( aIncEnv, '' )
				EndIf
			EndIf

			//Valida��o da tag <dscOC> - Descri��o (sigla) do �rg�o de classe ao qual o respons�vel pelos registros ambientais est� vinculado
			//Valida��o: Preenchimento obrigat�rio e exclusivo se ideOC = [9].
			If Empty( aRespAmb[ nCont, 5 ] ) .And. aRespAmb[ nCont, 4 ] == "9" //<dscOC>
				aAdd( aIncEnv, cStrFil + " / " + STR0044 + ": " + aRespAmb[ nCont, 1 ] + " - " + aRespAmb[ nCont, 2 ] + " / " + STR0047 + ": " + STR0004 ) //Respons�vel pelos Registros Ambientais: XXX - XXXXX / Descri��o do �rg�o de Classe: Em branco
				aAdd( aIncEnv, '' )
			EndIf

			//Valida��o da tag <nrOC> - N�mero de inscri��o no �rg�o de classe.
			//Informa��o Obrigat�ria
			//Preenchimento obrigat�rio se codAgNoc for diferente de [09.01.001].
			If Len( aRisTrat ) > 0 //Caso o funcion�rio esteja exposto a algum risco diferente de 09.01.001
				If Empty( aRespAmb[ nCont, 6 ] ) //<nrOC>
					aAdd( aIncEnv, cStrFil + " / " + STR0044 + ": " + aRespAmb[ nCont, 1 ] + " - " + aRespAmb[ nCont, 2 ] + " / " + STR0048 + ": " + STR0004 ) //Respons�vel pelos Registros Ambientais: XXX - XXXXX / N�mero do �rg�o de Classe: Em branco
					aAdd( aIncEnv, '' )
				EndIf
			EndIf

			//Valida��o da tag <ufOC> - UF do �rg�o de classe
			//Valores v�lidos: AC, AL, AP, AM, BA, CE, DF, ES, GO, MA, MT, MS, MG, PA, PB, PR, PE, PI, RJ, RN, RS, RO, RR, SC, SP, SE, TO
			//Preenchimento obrigat�rio se codAgNoc for diferente de [09.01.001].
			If Len( aRisTrat ) > 0 //Caso o funcion�rio esteja exposto a algum risco diferente de 09.01.001
				If Empty( aRespAmb[ nCont, 7 ] ) //<ufOC>
					aAdd( aIncEnv, cStrFil + " / " + STR0044 + ": " + aRespAmb[ nCont, 1 ] + " - " + aRespAmb[ nCont, 2 ] + " / " + STR0049 + ": " + STR0004 ) //Respons�vel pelos Registros Ambientais: XXX - XXXXX / UF do �rg�o de Classe: Em branco
					aAdd( aIncEnv, '' )
				EndIf
			EndIf

		Next nCont
	Else
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc ) //Funcion�rio: XXX - XXXXX
		aAdd( aIncEnv, STR0050 ) //N�o existem Respons�veis Ambientais para o per�odo de exposi��o do funcion�rio
		aAdd( aIncEnv, '' )
	EndIf

	Help := .F. //Ativa novamente as mensagens de Help

	cFilAnt := cFilBkp //Retorna filial do registro
	RestArea( aArea ) //Retorna �rea

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetAmbExp
Busca as informa��es do Ambiente de Exposi��o do Funcion�rio

@sample	fGetAmbExp( "000000001", "000000002", "00003", "000005" )

@return	aInfAmb, Array, Array contendo as informa��es do ambiente de exposi��o

@param cCCusto, Caracter, Centro de Custo do Funcion�rio
@param cDepto, Caracter, Departamento do Funcion�rio
@param cFuncao, Caracter, Fun��o do Funcion�rio
@param cNumMat, Caracter, Matr�cula do Funcion�rio

@author Luis Fellipy Bett
@since  19/02/2021
/*/
//-------------------------------------------------------------------
Static Function fGetAmbExp( cCCusto, cDepto, cFuncao, cNumMat, dDtIniCond )

	Local aArea	    := GetArea() //Salva a �rea
	Local cEntAmb   := SuperGetMv( "MV_NG2EAMB", .F., "1" ) //Indica qual entidade ser� considerada no relacionamento com o ambiente
	Local lTOQ	    := AliasInDic( "TOQ" )
	Local lTOR	    := AliasInDic( "TOR" )
	Local lTOS	    := AliasInDic( "TOS" )
	Local lTOT	    := AliasInDic( "TOT" )
	Local lTOU	    := AliasInDic( "TOU" )
	Local aInfAmb   := {}
	Local aTarefas  := {}
	Local nIndTNE   := 1
	Local nCont	    := 0
	Local cSeekTNE  := ""
	Local oModel    := Nil

	//----------------------------------------------------------------------
	// Busca o ambiente relacionado ao funcion�rio de acordo com a entidade
	//----------------------------------------------------------------------
	If lTOQ .And. cEntAmb == "1" //Centro de Custo
		
		dbSelectArea( "TOQ" )
		dbSetOrder( 2 )
		If dbSeek( xFilial( "TOQ" ) + cCCusto )
			cSeekTNE := TOQ->TOQ_CODAMB
		EndIf

	ElseIf lTOR .And. cEntAmb == "2" //Departamento

		dbSelectArea( "TOR" )
		dbSetOrder( 2 )
		If dbSeek( xFilial( "TOR" ) + cDepto )
			cSeekTNE := TOR->TOR_CODAMB
		EndIf

	ElseIf lTOS .And. cEntAmb == "3" //Fun��o

		dbSelectArea( "TOS" )
		dbSetOrder( 2 )
		If dbSeek( xFilial( "TOS" ) + cFuncao )
			cSeekTNE := TOS->TOS_CODAMB
		EndIf

	ElseIf lTOT .And. cEntAmb == "4" //Tarefa

		If lMDTA090 //Caso for chamado pela rotina de Tarefas do Funcion�rio
			oModel := FWModelActive()
		EndIf

		//Busca as tarefas que o funcion�rio realiza
		aTarefas := MDTGetTar( cNumMat, dDtIniCond, oModel )

		dbSelectArea( "TOT" )
		dbSetOrder( 2 )
		For nCont := 1 To Len( aTarefas )
			If dbSeek( xFilial( "TOT" ) + aTarefas[ nCont, 1 ] )
				cSeekTNE := TOT->TOT_CODAMB
				Exit
			EndIf
		Next nCont

	ElseIf lTOU .And. cEntAmb == "5" //Funcion�rio

		If lMDTA165 //Caso for chamado pela rotina de Ambiente F�sico
			//Pega o modelo ativo da TNE
			oModel := FWModelActive()

			cSeekTNE := oModel:GetValue( "TNEMASTER", "TNE_CODAMB" )
		Else
			dbSelectArea( "TOU" )
			dbSetOrder( 2 )
			If dbSeek( xFilial( "TOU" ) + cNumMat )
				cSeekTNE := TOU->TOU_CODAMB
			EndIf
		EndIf

	Else //Caso o ambiente n�o esteja atualizado com as tabelas relacionais, pega de acordo com o campo TNE_CODLOT

		nIndTNE := 2
		cSeekTNE := cCCusto

	EndIf

	//-------------------------------------------------------------------------------
	// Posiciona na tabela TNE para buscar as informa��es do ambiente do funcion�rio
	//-------------------------------------------------------------------------------
	If !Empty( cSeekTNE ) //Caso exista um ambiente vinculado

		//Caso o relacionamento do ambiente for por funcion�rio e seja chamada pelo cadastro de ambiente
		If lTOU .And. cEntAmb == "5" .And. lMDTA165

			//Adiciona as informa��es do modelo no array
			aAdd( aInfAmb, { AllTrim( oModel:GetValue( "TNEMASTER", "TNE_CODAMB" ) ), ;
								IIf( oModel:GetValue( "TNEMASTER", "TNE_LOCAMB" ) == "1", "1", "2" ), ; //Informa��o obrigat�ria a ser enviada na tag <localAmb>
								AllTrim( SubStr( MDTSubTxt( Upper( oModel:GetValue( "TNEMASTER", "TNE_MEMODS" ) ) ), 1, 99 ) ), ; //Informa��o obrigat�ria a ser enviada na tag <dscSetor>
								IIf( oModel:GetValue( "TNEMASTER", "TNE_TPINS" ) == "2", "3", IIf( oModel:GetValue( "TNEMASTER", "TNE_TPINS" ) == "3", "4", oModel:GetValue( "TNEMASTER", "TNE_TPINS" ) ) ), ; //Informa��o obrigat�ria a ser enviada na tag <tpInsc>
								oModel:GetValue( "TNEMASTER", "TNE_NRINS" ) } ) //Informa��o obrigat�ria a ser enviada na tag <nrInsc>

		Else

			//Posiciona na tabela TNE
			dbSelectArea( "TNE" )
			dbSetOrder( nIndTNE )
			If dbSeek( xFilial( "TNE" ) + cSeekTNE )

				//Adiciona as informa��es da TNE no array
				aAdd( aInfAmb, { AllTrim( TNE->TNE_CODAMB ), ;
								IIf( TNE->TNE_LOCAMB == "1", "1", "2" ), ; //Informa��o obrigat�ria a ser enviada na tag <localAmb>
								AllTrim( SubStr( MDTSubTxt( Upper( TNE->TNE_MEMODS ) ), 1, 99 ) ), ; //Informa��o obrigat�ria a ser enviada na tag <dscSetor>
								IIf( TNE->TNE_TPINS == "2", "3", IIf( TNE->TNE_TPINS == "3", "4", TNE->TNE_TPINS ) ), ; //Informa��o obrigat�ria a ser enviada na tag <tpInsc>
								TNE->TNE_NRINS } ) //Informa��o obrigat�ria a ser enviada na tag <nrInsc>
			EndIf

		EndIf

	EndIf

	//Retorna a �rea
	RestArea( aArea )

Return aInfAmb

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetDscAti
Busca a descri��o das atividades desempenhadas pelo funcion�rio de acordo
com o par�metro MV_NG2TDES

@sample	fGetDscAti( "00000012" )

@return	cDscAtiv, Caracter, Descri��o das atividades do funcion�rio

@param cNumMat, Caracter, Matr�cula do funcion�rio (RA_MAT)
@param dDtIniCond, Date, Data de In�cio das condi��es ambientais
@param aGPEA180, Array, Array contendo as informa��es da transfer�ncia do funcion�rio
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
@since  19/02/2021
/*/
//-------------------------------------------------------------------
Static Function fGetDscAti( cNumMat, dDtIniCond, aGPEA180 )

	Local cDscAtiv := ""
	Local cFldDesc := ""
	Local cTraco   := ""
	Local nCont	   := 0
	Local aTarefas := {}
	Local lFirst   := .T.
	Local cCargo   := ""
	Local cFuncao  := ""
	Local cCenCus  := ""
	Local cTpDesc  := SuperGetMv( "MV_NG2TDES", .F., "1" )
	Local oModel   := Nil
	Local cFilOri  := IIf( lGPEA180, aGPEA180[ 1, 4 ], cFilAnt )

	//Caso for transfer�ncia de funcion�rio, pega a fun��o e cargo da filial de destino
	If lGPEA180
		cFuncao := IIf( Len( aGPEA180[ 1 ] ) > 11 .And. !Empty( aGPEA180[ 1, 12 ] ), aGPEA180[ 1, 12 ], "" )
		cCargo	:= IIf( Len( aGPEA180[ 1 ] ) > 12 .And. !Empty( aGPEA180[ 1, 13 ] ), aGPEA180[ 1, 13 ], "" )
	EndIf

	//Caso a fun��o n�o tenha sido preenchida na chamada do GPEA180
	If Empty( cFuncao )
		cFuncao := Posicione( "SRA", 1, xFilial( "SRA", cFilOri ) + cNumMat, "RA_CODFUNC" )
	EndIf

	//Caso o cargo n�o tenha sido preenchido na chamada do GPEA180
	If Empty( cCargo )
		cCargo	:= Posicione( "SRA", 1, xFilial( "SRA", cFilOri ) + cNumMat, "RA_CARGO" )
	EndIf

	//Verifica qual descri��o buscar de acordo com o par�metro MV_NG2TDES
	If cTpDesc $ "1/2/4" //Tarefa, Cargo ou Cargo + Tarefa

		If cTpDesc $ "2/4" //Cargo ou Cargo + Tarefa

			If lGPEA370 //Caso for chamado pela rotina de Tarefas do Funcion�rio

				oModel := FWModelActive()

				cDscAtiv := AllTrim ( oModel:GetValue( 'MODELGPEA370', 'Q3_MEMO1' ) )

			Else

				// Busca o CC do funcion�rio para pesquisar o cargo
				cCenCus := Posicione( "SRA", 1, xFilial( "SRA", cFilOri ) + cNumMat, "RA_CC" )

				// Busca as informa��es do Cargo com o CC
				cFldDesc := Posicione( "SQ3", 1, xFilial( "SQ3" ) + cCargo + cCenCus, "Q3_DESCDET" )
				cDscAtiv := AllTrim( ( MSMM( cFldDesc, 80, , , , , , "SQ3", , "RDY" ) ) )

				If Empty( cDscAtiv )

					// Busca as informa��es do Cargo sem o CC
					cFldDesc := Posicione( "SQ3", 1, xFilial( "SQ3" ) + cCargo, "Q3_DESCDET" )
					cDscAtiv := AllTrim( ( MSMM( cFldDesc, 80, , , , , , "SQ3", , "RDY" ) ) )

				EndIf

				If Empty( cDscAtiv )

					cDscAtiv := AllTrim( ( Posicione( "SQ3", 1, xFilial( "SQ3" ) + cCargo + cCenCus, "Q3_DESCSUM" ) ) )

					If Empty( cDscAtiv )

						cDscAtiv := AllTrim( ( Posicione( "SQ3", 1, xFilial( "SQ3" ) + cCargo, "Q3_DESCSUM" ) ) )

					EndIf

				EndIf

			EndIf

		EndIf

		//Caso for Cargo + Tarefa, adiciona a "/" para separar as informa��es
		If cTpDesc == "4"
			If !Empty( cDscAtiv )
				cDscAtiv += " / "
			EndIf
		EndIf

		If cTpDesc $ "1/4" //Tarefa ou Cargo + Tarefa

			If lMDTA090 //Caso for chamado pela rotina de Tarefas do Funcion�rio
				oModel := FWModelActive()
			EndIf

			//Busca as tarefas que o funcion�rio realiza
			aTarefas := MDTGetTar( cNumMat, dDtIniCond, oModel )

			For nCont := 1 To Len( aTarefas )

				If lMDTA090 .And. AllTrim( aTarefas[ nCont, 1 ] ) == AllTrim( oModel:GetValue( "TN5MASTER", "TN5_CODTAR" ) )
					cDscAtiv += cTraco + AllTrim( ( oModel:GetValue( "TN5MASTER", "TN5_DESCRI" ) ) )
				Else
					cDscAtiv += cTraco + AllTrim( ( Posicione( "TN5", 1, xFilial( "TN5", cFilOri ) + aTarefas[ nCont, 1 ], "TN5_DESCRI" ) ) ) //TN5_FILIAL+TN5_CODTAR
				EndIf

				If Empty( cDscAtiv )
					If lMDTA090 .And. AllTrim( aTarefas[ nCont, 1 ] ) == AllTrim( oModel:GetValue( "TN5MASTER", "TN5_CODTAR" ) )
						cDscAtiv += cTraco + AllTrim( ( oModel:GetValue( "TN5MASTER", "TN5_NOMTAR" ) ) )
					Else
						cDscAtiv += cTraco + AllTrim( ( Posicione( "TN5", 1, xFilial( "TN5", cFilOri ) + aTarefas[ nCont, 1 ], "TN5_NOMTAR" ) ) ) //TN5_FILIAL+TN5_CODTAR
					EndIf
				EndIf

				If lFirst
					cTraco := " / "
					lFirst := .F.
				EndIf

			Next nCont
		EndIf

	ElseIf cTpDesc == "3" //Fun��o

		cFldDesc := Posicione( "SRJ", 1, xFilial( "SRJ" ) + cFuncao, "RJ_DESCREQ" )
		cDscAtiv := AllTrim( ( MSMM( cFldDesc, 80, , , , , , "SRJ", , "RDY" ) ) )

		If Empty( cDscAtiv )
			cDscAtiv := AllTrim( ( Posicione( "SRJ", 1, xFilial( "SRJ" ) + cFuncao, "RJ_DESC" ) ) ) //RJ_FILIAL+RJ_FUNCAO
		EndIf

	EndIf

Return cDscAtiv

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTGetTar
Busca as tarefas que o funcion�rio realiza

@sample	MDTGetTar( "00000012" )

@return	aTarFun, Array, Array contendo as tarefas realizadas pelo funcion�rio

@param cNumMat, Caracter, Matr�cula do funcion�rio (RA_MAT)
@param dDtIniCond, Date, Data de In�cio das condi��es ambientais
@param oModel, Objeto, Objeto do modelo

@author Luis Fellipy Bett
@since  19/02/2021
/*/
//-------------------------------------------------------------------
Function MDTGetTar( cNumMat, dDtIniCond, oModel )

	Local aTarFun := {}
	Local nCont	  := 0
	Local oGridTN6

	//Se for chamado pelo MDTA090 e n�o for exclus�o, pega as tarefas diretamente da Grid
	If lMDTA090 .And. oModel:GetOperation() <> 5
		oGridTN6 := oModel:GetModel( "TN6GRID" )

		For nCont := 1 To oGridTN6:Length()
			oGridTN6:GoLine( nCont )
			If oGridTN6:GetValue( "TN6_MAT" ) == cNumMat .And. ;
				aScan( aTarFun, { | x | x[1] == oModel:GetValue( "TN5MASTER", "TN5_CODTAR" ) } ) == 0 .And. ;
				oGridTN6:GetValue( "TN6_DTINIC" ) <= dDtIniCond .And. ( oGridTN6:GetValue( "TN6_DTTERM" ) > dDtIniCond .Or. ;
				Empty( oGridTN6:GetValue( "TN6_DTTERM" ) ) ) .And. !oGridTN6:IsDeleted()

				aAdd( aTarFun, { oModel:GetValue( "TN5MASTER", "TN5_CODTAR" ) } )
			EndIf
		Next nCont
	EndIf

	//Se for chamado pelo MDTA005 e n�o for exclus�o
	If lMDTA005
		For nCont := 1 To Len( aTarefaTKD )
			If !aTail( aTarefaTKD[ nCont ] ) //Se a linha n�o estiver exclu�da
				aAdd( aTarFun, { aTarefaTKD[ nCont, 1 ] } )
			EndIf
		Next nCont
	EndIf

	dbSelectArea( "TN6" )
	dbSetOrder( 2 )
	dbSeek( xFilial( "TN6" ) + cNumMat )
	While TN6->TN6_FILIAL = xFilial( "TN6" ) .And. TN6->TN6_MAT = cNumMat
		If TN6->TN6_DTINIC <= dDtIniCond .And. ( TN6->TN6_DTTERM > dDtIniCond .Or. Empty( TN6->TN6_DTTERM ) ) .And.;
			( !lMDTA090 .Or. TN6->TN6_CODTAR <> oModel:GetValue( "TN5MASTER", "TN5_CODTAR" ) ) .And. ;
			aScan( aTarFun, { | x | x[1] == TN6->TN6_CODTAR } ) == 0

			aAdd( aTarFun, { TN6->TN6_CODTAR } )
		EndIf
		TN6->( dbSkip() )
	End

Return aTarFun

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetRisExp
Busca as informa��es de exposi��o dos riscos do funcion�rio

@sample	fGetRisExp( "00000035", 12/03/2021 )

@return	aInfRis, Array, Array contendo as informa��es de exposi��o dos riscos

@param cNumMat, Caracter, Matricula do funcion�rio
@param dDtIniCond, Date, Data de In�cio das condi��es ambientais
@param nOper, Num�rico, Opera��o que est� sendo realizada (3- Inclus�o, 4- Altera��o ou 5- Exclus�o)

@author Luis Fellipy Bett
@since  19/02/2021
/*/
//-------------------------------------------------------------------
Static Function fGetRisExp( cNumMat, dDtIniCond, nOper, lIncons )

	Local nRis		:= 0
	Local nEpi		:= 0
	Local nPosRis	:= 0
	Local cEfiEPC	:= "S"
	Local aInfRis	:= {}
	Local aInfEPI	:= {}
	Local aRisExp	:= {}

	//Vari�veis utilizadas para busca da informa��o do Risco
	Local cNumRis := ""
	Local cAgente := ""
	Local nQtAgen := 0
	Local cUniMed := ""
	Local cTecUti := ""
	Local cEPC	  := ""
	Local cNecEPI := ""

	//Busca riscos expostos
	aRisExp := MDTRis2240( dDtIniCond )

	//Caso for cadastro de Risco, adiciona as informa��es da mem�ria
	If lMDTA180 .And. aScan( aRisExp, { |x| x[1] == M->TN0_NUMRIS } ) == 0 .And. MdtVldRis( dDtIniCond, .T. )
		aAdd( aRisExp, { M->TN0_NUMRIS, M->TN0_AGENTE } )
	EndIf

	For nRis := 1 To Len( aRisExp ) //Percorre os Riscos a que o funcion�rio est� exposto

		dbSelectArea( "TN0" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TN0" ) + aRisExp[ nRis, 1 ] ) .And. ;
			IIf( lMDTA180, aRisExp[ nRis, 1 ] <> M->TN0_NUMRIS, .T. )
			cNumRis := TN0->TN0_NUMRIS
			cAgente := TN0->TN0_AGENTE
			nQtAgen := TN0->TN0_QTAGEN
			cUniMed := TN0->TN0_UNIMED
			cTecUti := TN0->TN0_TECUTI
			cEPC	:= TN0->TN0_EPC
			cNecEPI	:= TN0->TN0_NECEPI
		Else
			cNumRis := aRisExp[ nRis, 1 ]
			cAgente := aRisExp[ nRis, 2 ]
			nQtAgen := M->TN0_QTAGEN
			cUniMed := M->TN0_UNIMED
			cTecUti := M->TN0_TECUTI
			cEPC	:= M->TN0_EPC
			cNecEPI	:= M->TN0_NECEPI
		EndIf

		//Se for exclus�o e o funcion�rio estiver exposto ao Risco que estou excluindo, n�o envio o Risco ao eSocial
		If !( lMDTA180 .And. nOper == 5 .And. cNumRis == M->TN0_NUMRIS )

			//Epi deve estar entregue ao funcion�rio e vinculado ao risco
			fGetEpiRis( cNumRis, cNumMat, @aInfEPI, lIncons )

			//Verifica se o EPC � eficaz
			dbSelectArea( "TO9" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "TO9" ) + cNumRis )
			While xFilial( "TO9" ) == TO9->TO9_FILIAL .And. TO9->TO9_NUMRIS == cNumRis
				If TO9->TO9_EFIEPC == "2"
					cEfiEPC := "N"
					Exit
				EndIf
				dbSkip()
			End

			//Caso n�o exista mais de um Risco com o mesmo fator de Risco no array, adiciona
			If ( nPosRis := aScan( aInfRis, { | x | x[ 3 ] == Posicione( "TMA", 1, xFilial( "TMA" ) + cAgente, "TMA_ESOC" ) .And. ;
													x[ 4 ] == AllTrim( MDTSubTxt( Posicione( "TMA", 1, xFilial( "TMA" ) + cAgente, "TMA_DESCRI" ) ) ) } ) ) == 0

				aAdd( aInfRis, { AllTrim( cNumRis ), ;
								AllTrim( cAgente ), ;
								Posicione( "TMA", 1, xFilial( "TMA" ) + cAgente, "TMA_ESOC" ), ; //Informa��o obrigat�ria a ser enviada na tag <codAgNoc>
								AllTrim( MDTSubTxt( Posicione( "TMA", 1, xFilial( "TMA" ) + cAgente, "TMA_DESCRI" ) ) ), ; //Informa��o a ser enviada na tag <dscAgNoc>
								fGetTpAval( cAgente, nQtAgen ), ; //Informa��o obrigat�ria a ser enviada na tag <tpAval>
								cValToChar( nQtAgen ), ; //Informa��o a ser enviada na tag <intConc>
								cValToChar( Posicione( "TLK", 1, xFilial( "TLK" ) + cAgente, "TLK_DEQTDE" ) ), ; //Informa��o a ser enviada na tag <limTol>
								AllTrim( cUniMed ), ; //Informa��o a ser enviada na tag <unMed>
								AllTrim( MDTSubTxt( cTecUti ) ), ; //Informa��o a ser enviada na tag <tecMedicao>
								IIf( Empty( cEPC ), "0" , IIf( cEPC == "1", "2", "1" ) ), ; //Informa��o obrigat�ria a ser enviada na tag <utilizEPC>
								cEfiEPC, ; //Informa��o a ser enviada na tag <eficEpc>
								IIf( Empty( cNecEPI ), "0", IIf( cNecEPI == "1", "2", "1" ) ), ; //Informa��o obrigat�ria a ser enviada na tag <utilizEPI>
								aClone( aInfEPI ) } )

			Else

				//Caso exista mais de um Risco com um mesmo fator de risco e caso ele tenha maior quantidade de exposi��o,
				//atribuo os valores dele para serem enviados
				If Val( aInfRis[ nPosRis, 6 ] ) < nQtAgen
					aInfRis[ nPosRis, 1 ] := AllTrim( cNumRis )
					aInfRis[ nPosRis, 2 ] := AllTrim( cAgente )
					aInfRis[ nPosRis, 4 ] := AllTrim( MDTSubTxt( Posicione( "TMA", 1, xFilial( "TMA" ) + cAgente, "TMA_DESCRI" ) ) ) //Informa��o a ser enviada na tag <dscAgNoc>
					aInfRis[ nPosRis, 5 ] := fGetTpAval( cAgente, nQtAgen ) //Informa��o obrigat�ria a ser enviada na tag <tpAval>
					aInfRis[ nPosRis, 6 ] := cValToChar( nQtAgen ) //Informa��o a ser enviada na tag <intConc>
					aInfRis[ nPosRis, 7 ] := cValToChar( Posicione( "TLK", 1, xFilial( "TLK" ) + cAgente, "TLK_DEQTDE" ) ) //Informa��o a ser enviada na tag <limTol>
					aInfRis[ nPosRis, 8 ] := AllTrim( cUniMed ) //Informa��o a ser enviada na tag <unMed>
					aInfRis[ nPosRis, 9 ] := AllTrim( MDTSubTxt( cTecUti ) ) //Informa��o a ser enviada na tag <tecMedicao>
					aInfRis[ nPosRis, 10 ] := IIf( Empty( cEPC ), "0", IIf( cEPC == "1", "2", "1" ) ) //Informa��o obrigat�ria a ser enviada na tag <utilizEPC>
					aInfRis[ nPosRis, 12 ] := IIf( Empty( cNecEPI ), "0", IIf( cNecEPI == "1", "2", "1" ) ) //Informa��o obrigat�ria a ser enviada na tag <utilizEPI>
				EndIf

				For nEpi := 1 To Len( aInfEPI )
					If ( aScan( aInfRis[ nPosRis, 13 ], { | x | x[ 1 ] == aInfEPI[ nEpi, 1 ] } ) ) == 0
						aAdd( aInfRis[ nPosRis, 13 ], aClone( aInfEPI[ nEpi ] ) )
					EndIf
				Next nEpi

				If cEfiEPC == "N"
					aInfRis[ nPosRis, 11 ] := cEfiEPC //Informa��o a ser enviada na tag <eficEpc>
				EndIf

			EndIf

			//Zera array para buscar os relacionados ao pr�ximo risco
			aInfEPI := {}

		EndIf

	Next nRis

Return aInfRis

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetResAmb
Busca as informa��es do respons�vel pelos registros ambientais

@sample	fGetResAmb( 12/03/2021 )

@return	aResp, Array, Array contendo as informa��es do respons�vel pelos registros ambientais

@param	dDtIniCond, Date, Data de In�cio das condi��es ambientais
@param	aRisTrat, Array, Array contendo os riscos que ser�o enviados ao governo para o funcion�rio

@author	Luis Fellipy Bett
@since	22/02/2021
/*/
//-------------------------------------------------------------------
Static Function fGetResAmb( dDtIniCond, aRisTrat )

	Local lAllResp	:= SuperGetMv( "MV_NG2RAMB", .F., "1" ) == "1"
	Local cTpUsu	:= SuperGetMv( "MV_NG2REST", .F., "1" )
	Local cAliasLau	:= GetNextAlias()
	Local aResp		:= {}
	Local aUsus		:= {}
	Local nCont		:= 0
	Local cResTaf	:= ""
	Local nIdeOC	:= ""
	Local cExpRis	:= "%"
	Local cVirgula	:= ", "
	Local cSeekFil	:= ""

	//Vari�vel da tabela a ser considerada na query (usada dessa forma para pegar corretamente na transfer�ncia entre empresas)
	Local cTblTO0 := "%" + RetFullName( "TO0", cEmpAnt ) + "%"
	Local cTblTO1 := "%" + RetFullName( "TO1", cEmpAnt ) + "%"

	//Par�metro que indica que tipo de Usu�rio Respons�vel ser� enviado ao TAF
	If cTpUsu == "1" //M�dico do Trabalho
		cResTaf := "1"
	ElseIf cTpUsu == "2" //Engenheiro do Trabalho
		cResTaf := "4"
	ElseIf cTpUsu == "3" //Ambos
		cResTaf := "1/4"
	ElseIf cTpUsu == "4" //Todos
		cResTaf := "1/2/3/4/5/6/7/8/9/A/B/C"
	EndIf

	//Caso sejam enviados todos os respons�veis ambientais ou caso sejam enviados apenas os relacionados a riscos e o funcion�rio 
	//n�o estiver exposto a nenhum risco
	If lAllResp .Or. ( !lAllResp .And. Len( aRisTrat ) == 0 )

		BeginSQL Alias cAliasLau
			SELECT TO0.TO0_CODUSU
				FROM %Exp:cTblTO0% TO0
				WHERE TO0.TO0_FILIAL = %xFilial:TO0% AND
						TO0.TO0_DTINIC <= %Exp:dDtIniCond% AND
						( TO0.TO0_DTVALI >  %Exp:dDtIniCond% OR
						TO0.TO0_DTVALI = '' ) AND
						TO0.%NotDel%
		EndSQL

	Else

		//Adiciona todos os riscos na vari�vel para utiliza��o na query
		For nCont := 1 To Len( aRisTrat )
			
			//Caso for o �ltimo risco do array que estiver sendo processado, zera a v�rgula
			If nCont == Len( aRisTrat )
				cVirgula := ""
			EndIf

			//Adiciona o risco na express�o
			cExpRis += "'" + aRisTrat[ nCont, 1 ] + "'" + cVirgula

		Next nCont

		//Finaliza a express�o com o %
		cExpRis += "%"

		//Caso n�o exista nenhum risco a que o funcion�rio est� exposto
		If cExpRis == "%%"
			cExpRis := "%''%"
		EndIf

		BeginSQL Alias cAliasLau
			SELECT TO0.TO0_CODUSU
				FROM %Exp:cTblTO0% TO0
				WHERE TO0.TO0_FILIAL = %xFilial:TO0% AND
						TO0.TO0_LAUDO IN (
							SELECT TO1.TO1_LAUDO
								FROM %Exp:cTblTO1% TO1
								WHERE TO1.TO1_FILIAL = %xFilial:TO1% AND
									TO1.TO1_NUMRIS IN ( %Exp:cExpRis% ) AND
									TO1.%NotDel% ) AND
						TO0.TO0_DTINIC <= %Exp:dDtIniCond% AND
						( TO0.TO0_DTVALI >  %Exp:dDtIniCond% OR
						TO0.TO0_DTVALI = '' ) AND
						TO0.%NotDel%
		EndSQL

	EndIf

	dbSelectArea( cAliasLau )
	While ( cAliasLau )->( !EoF() )
		If ( aScan( aUsus, { | x | x[ 1 ] == ( cAliasLau )->TO0_CODUSU } ) == 0 )
			aAdd( aUsus, { ( cAliasLau )->TO0_CODUSU } )
		EndIf
		( cAliasLau )->( dbSkip() )
	End
	( cAliasLau )->( dbCloseArea() )

	dbSelectArea( "TMK" ) //Usu�rios
	dbSetOrder( 1 )
	For nCont := 1 To Len( aUsus )

		//Verifica��o pontual para casos onde tabela TMK estiver compartilhada
		If Empty( TMK->TMK_FILIAL )
			cSeekFil := TMK->TMK_FILIAL
		Else
			cSeekFil := xFilial( "TMK" )
		EndIf

		If dbSeek( cSeekFil + aUsus[ nCont, 1 ] ) .And.;
			TMK->TMK_INDFUN $ cResTaf .And. ;
			TMK->TMK_DTINIC <= dDtIniCond .And. ;
			( TMK->TMK_DTTERM >= dDtIniCond .Or. Empty( TMK->TMK_DTTERM ) ) .And. ;
			TMK->TMK_RESAMB == '1'

			If "CRM" $ TMK->TMK_ENTCLA
				nIdeOC := "1"
			ElseIf "CREA" $ TMK->TMK_ENTCLA
				nIdeOC := "4"
			Else
				nIdeOC := "9"
			EndIf

			aAdd( aResp, { AllTrim( TMK->TMK_CODUSU ), ;
							AllTrim( TMK->TMK_NOMUSU ), ;
							TMK->TMK_CIC, ; //Informa��o obrigat�ria a ser enviada na tag <cpfResp>
							nIdeOC, ; //Informa��o obrigat�ria a ser enviada na tag <ideOC>
							AllTrim( TMK->TMK_ENTCLA ), ; //Informa��o a ser enviada na tag <dscOC>
							AllTrim( TMK->TMK_NUMENT ), ; //Informa��o obrigat�ria a ser enviada na tag <nrOC>
							TMK->TMK_UF } ) //Informa��o obrigat�ria a ser enviada na tag <ufOC>
		EndIf

	Next nCont

Return aResp

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetEpiRis
Analisa os Requesitos do EPI eficazes:

@param cRiscoFun	Caracter Risco no qual est� exposto
@param cMat			Caracter Matr�cula do Funcion�rio
@param aInfEpi		Array Dados do Epi

Integra��o das condi��es diferenciais de trabalho, Evento S-2360

@author Guilherme Benkendorf
@since 28/02/2014
/*/
//---------------------------------------------------------------------
Static Function fGetEpiRis( cRiscoFun, cMat, aInfEpi, lIncons )

	// Contadores
	Local nFor1, nFor2, nFor3, nEpi, nOrdEPi

	// Variaveis de Tamanho de Campo
	Local nSizeCod := IIf( ( TAMSX3( "B1_COD" )[ 1 ] ) < 1, 15, ( TAMSX3( "B1_COD" )[ 1 ] ) )

	//Variaveis do TRB
	Local cAliTRB := GetNextAlias()
	Local aDBF := {}

	Local aAreaEPI := GetArea()

	// Controladores
	Local nPosi, nDiasUtilizados, nQtdeAfast
	Local nPosCAP
	Local cNumCAP

	Local dInicioRis, dFimRis, dtAval, dDtEntr
	Local dDtEficaz, dDtEfica2, dDtTNFfi2

	Local lFirst
	Local lStart, lEpiSub, lEpiAltOK
	Local lEpiEntregue := .F.

	// Par�metros
	Local nDias := SuperGetMv( "MV_PPPDTRI", .F., "" )
	Local nLimite_Dias_Epi := 30

	Local lConsEPI := SuperGetMv( "MV_NG2CEPI", .F., "N" ) == "S"
	Local lEPIRis  := SuperGetMv( "MV_NG2EPIR", .F., "1" ) == "2"

	// Modos de Compartilhamento
	Local cModoTN0, cXFilTN0, cModoTNX, cXFilTNX, cModoTNF, cXFilTNF, cModoTN3, cXFilTN3
	Local cFilFun := xFilial( "SRA" )

	// Controle de EPI's Obrigat�rios
	Local aTNFobr, aTNFfam, aTNFalt
	Local aOrdEPIs := {}

	Local cMedPrt := "N" //Define por padr�o a medida de prote��o igual a 'N�o'
	Local cPROTEC
	Local cCndFun
	Local cUsuIni
	Local cPrzVld
	Local cPerTrc
	Local cHigien
	Local dDtReco
	Local dDtElim
	Local cNumRis
	Local cTN0CFu
	Local cTN0PVl
	Local cTN0PTr
	Local cTN0Hig
	Local lNaoEfic := .F. //Guarda se todos os EPI's s�o eficazes

	Default aEpiEso := {}

	// Verifica quantidade de dias
	If ValType( nDias ) == "N"
		nLimite_Dias_Epi := nDias
	ElseIf ValType( nDias ) == "C"
		nLimite_Dias_Epi := Val( nDias )
	Endif

	// Monta o TRB
	aAdd( aDBF, { "DTINI", "D", 08, 0 } )
	aAdd( aDBF, { "NUMCAP", "C", 12, 0 } )
	aAdd( aDBF, { "PROTEC", "C", 02, 0 } )
	aAdd( aDBF, { "DTREAL", "D", 08, 0 } )
	aAdd( aDBF, { "SITUAC", "C", 01, 0 } )
	aAdd( aDBF, { "DTDEVO", "D", 08, 0 } )
	aAdd( aDBF, { "CODEPI", "C", nSizeCod, 0 } )

	oTempAli := FWTemporaryTable():New( cAliTRB, aDBF )
	oTempAli:AddIndex( "1", { "DTINI", "NUMCAP", "PROTEC", "DTREAL" } )
	oTempAli:AddIndex( "2", { "SITUAC", "NUMCAP", "DTINI", "PROTEC", "DTREAL" } )
	oTempAli:Create()

	// Defini��es de compartilhamento do Risco
	dbselectarea( "TN0" )
	dbsetorder( 1 )
	If dbseek( xFilial( "TN0" ) + cRiscoFun )
		dDtReco := TN0->TN0_DTRECO
		dDtElim := TN0->TN0_DTELIM
		cNumRis := TN0->TN0_NUMRIS
		cTN0CFu := TN0->TN0_CONFUN
		cTN0PVl := TN0->TN0_PRZVLD
		cTN0PTr := TN0->TN0_PERTRC
		cTN0Hig := TN0->TN0_HIGIEN
	Else
		dDtReco := M->TN0_DTRECO
		dDtElim := M->TN0_DTELIM
		cNumRis := M->TN0_NUMRIS
		cTN0CFu := M->TN0_CONFUN
		cTN0PVl := M->TN0_PRZVLD
		cTN0PTr := M->TN0_PERTRC
		cTN0Hig := M->TN0_HIGIEN
	EndIf

	cModoTN0 := NGSEEKDIC( "SX2", "TN0", 1, "X2_MODOEMP + X2_MODOUN + X2_MODO" )
	cXFilTN0 := FwxFilial( "TN0", cFilFun, Substr( cModoTN0, 1, 1 ), Substr( cModoTN0, 2, 1 ), Substr( cModoTN0, 3, 1 ) )

	cModoTNX := NGSEEKDIC( "SX2", "TNX", 1, "X2_MODOEMP + X2_MODOUN + X2_MODO" )
	cXFilTNX := FwxFilial( "TNX", cFilFun, Substr( cModoTNX, 1, 1 ), Substr( cModoTNX, 2, 1 ), Substr( cModoTNX, 3, 1 ) )

	cModoTNF := NGSEEKDIC( "SX2", "TNF", 1, "X2_MODOEMP + X2_MODOUN + X2_MODO" )
	cXFilTNF := FwxFilial( "TNF", cFilFun, Substr( cModoTNF, 1, 1 ), Substr( cModoTNF, 2, 1 ), Substr( cModoTNF, 3, 1 ) )

	cModoTN3 := NGSEEKDIC( "SX2", "TN3", 1, "X2_MODOEMP + X2_MODOUN + X2_MODO" )
	cXFilTN3 := FwxFilial( "TN3", cFilFun, Substr( cModoTN3, 1, 1 ), Substr( cModoTN3, 2, 1 ), Substr( cModoTN3, 3, 1 ) )

	cModoTL0 := NGSEEKDIC( "SX2", "TL0", 1, "X2_MODOEMP + X2_MODOUN + X2_MODO" )
	cXFilTL0 := FwxFilial( "TL0", cFilFun, Substr( cModoTL0, 1, 1 ), Substr( cModoTL0, 2, 1 ), Substr( cModoTL0, 3, 1 ) )

	lStart     := .F.
	dInicioRis := dDtReco
	dFimRis    := dDataBase

	dtAval := dDtReco

	If dtAval >= dInicioRis  .And. dtAval <= dFimRis
		lStart  := .T.

		If !Empty( dDtElim ) .And. dDtElim < dFimRis
			dFimRis := dDtElim
		EndIf

		dInicioRis := dtAval
	ElseIf dtAval < dInicioRis .And. ( Empty( dDtElim ) .Or. dDtElim >= dInicioRis )
		lStart  := .T.

		If !Empty( dDtElim ) .And. dDtElim < dFimRis
			dFimRis := dDtElim
		EndIf

	EndIf

	If lStart .And. lConsEPI // Se consiste EPI

		// Apaga todos os registros do arquivo temporario onde estao os EPI's entregues
		aTNFobr := {}
		aTNFalt := {}
		aTNFfam := {}

		lFirst     := .T.

		dbSelectArea( "TNX" )
		dbSetOrder( 1 ) // TNX_FILIAL+TNX_NUMRIS+TNX_EPI
		dbSeek( cXFilTNX + cNumRis )

		While TNX->( !Eof() ) .And. cXFilTNX == TNX->TNX_FILIAL .And. cNumRis == TNX->TNX_NUMRIS

			If TNX->TNX_TIPO == "1"
				aAdd( aTNFobr, TNX->TNX_EPI )
			Else

				If (nPosi := aSCAN( aTNFfam, { |x| x == TNX->TNX_FAMIL } ) ) > 0
					aAdd( aTNFalt[ nPosi ], TNX->TNX_EPI )
				Else
					aAdd( aTNFfam, TNX->TNX_FAMIL )
					aAdd( aTNFalt, { TNX->TNX_EPI } )
				EndIf

			EndIf

			dbSelectArea( "TNX" )
			dbSkip()
		End

		// Epi esta previsto p/ funcionario
		lEpiObr := .T. // Verifica se houve utilizacao de todos os EPIs necessarios
		dDtEficaz := STOD( Space( 8 ) ) // Data inicio Eficaz dos EPIs

		If Len( aTNFobr ) > 0 .Or. Len( aTNFalt ) > 0
			cCndFun := "S"
			cUsuIni := "S"
			cPrzVld := "S"
			cPerTrc := "S"
			cHigien := "S"
		Else
			cCndFun := "N"
			cUsuIni := "N"
			cPrzVld := "N"
			cPerTrc := "N"
			cHigien := "N"
		EndIf

		For nFor1 := 1 To Len( aTNFobr )
			cCndFun := "S"
			cUsuIni := "S"
			cPrzVld := "S"
			cPerTrc := "S"
			cHigien := "S"
			aAdd( aOrdEPIs, {} )
			nPosAdd := Len( aOrdEPIs )
			dbSelectArea( "TN3" )
			dbSetOrder( 2 )
			dbSeek( xFilial( "TN3" ) + aTNFobr[nFor1] )

			While TN3->( !EoF() ) .And. TN3->TN3_FILIAL == xFilial( "TN3" ) .And. TN3->TN3_CODEPI == aTNFobr[nFor1]

				If TN3->TN3_GENERI == "2"
					//Procurar os filhos e adicionar no Array
					dbSelectArea( "TL0" )
					dbSetOrder( 1 ) //TL0_FILIAL+TL0_EPIGEN

					If dbSeek( xFilial( "TL0" ) + TN3->TN3_CODEPI )
						aAdd( aOrdEPIs[ nPosAdd ], TL0->TL0_NUMCAP )
					EndIf

				Else
					aAdd( aOrdEPIs[ nPosAdd ], TN3->TN3_NUMCAP )
				EndIf

				TN3->( dbSkip() )
			End

			dDtEfica2 := dFimRis
			lEpiSub := .F.
			dbSelectArea( "TNF" )
			dbSetOrder( 3 )  //TNF_FILIAL+TNF_MAT+TNF_CODEPI+DTOS(TNF_DTENTR)+TNF_HRENTR

			If lIncons .And. ( lMdta695 .Or. lMdta630 )

				For nFor3 := 1 To Len( aEpiEso )

					If aTNFobr[ nFor1 ] != aEpiEso[ nFor3, 1 ] // Verifica se o EPI � o EPI obrigat�rio em quest�o
						Loop
					EndIf

					If aEpiEso[ nFor3, 9 ] != cMat // Verifica se o EPI pertence ao funcion�rio em quest�o
						Loop
					EndIf

					If !Dbseek( cXFilTNF + cMat + aTNFobr[ nFor1 ] )

						lEpiEntregue := .T.

						lEpiSub	  := .T.
						lFirst	  := .F.
						dDtEfica2 := IIf( aEpiEso[ nFor3, 2 ] > dDtEfica2, dDtEfica2, aEpiEso[ nFor3, 2 ] )
						dDtEntr	  := IIf( aEpiEso[ nFor3, 2 ] < dInicioRis, dInicioRis, aEpiEso[ nFor3, 2 ] )
						cPROTEC	  := IIf( aEpiEso[ nFor3, 8 ] == "2", "N", IIf( aEpiEso[ nFor3, 8 ] == "3", "N", "S" ) )

						If ( nPosCAP := aScan( aInfEpi, { | x | x[ 2 ] == AllTrim( TNF->TNF_NUMCAP ) } ) ) == 0

							aAdd( aInfEpi, {;
								AllTrim( aEpiEso[ nFor3, 1 ] ),;
								AllTrim( aEpiEso[ nFor3, 7 ] ),; // Informa��o a ser enviada na tag <docAval>
								AllTrim( Posicione( "SB1", 1, xFilial("SB1") + aEpiEso[ nFor3, 1 ], "B1_DESC" ) ),; // Informa��o a ser enviada na tag <dscEPI>
								cPROTEC,; // Informa��o a ser enviada na tag <eficEpi>
								cMedPrt,; // Informa��o a ser enviada na tag <medProtecao>
								cCndFun,; // Informa��o a ser enviada na tag <condFuncto>
								cUsuIni,; // Informa��o a ser enviada na tag <usoInint>
								cPrzVld,; // Informa��o a ser enviada na tag <przValid>
								cPerTrc,; // Informa��o a ser enviada na tag <periodicTroca>
								cHigien; // Informa��o a ser enviada na tag <higienizacao>
							} )

						EndIf

					EndIf

				Next

			EndIf

			If Dbseek( cXFilTNF + cMat + aTNFobr[ nFor1 ] )

				While TNF->( !Eof() ) .And. cXFilTNF + cMat + aTNFobr[nFor1] == TNF->( TNF_FILIAL + TNF_MAT + TNF_CODEPI )

					cNumCAP := TNF->TNF_NUMCAP
					lEpiEntregue := .T.

					dbSelectArea( "TN3" )
					dbSetOrder( 1 )
					dbSeek( cXFilTN3 + TNF->TNF_FORNEC + TNF->TNF_LOJA + TNF->TNF_CODEPI + TNF->TNF_NUMCAP )

					lEpiSub	  := .T.
					lFirst	  := .F.
					dDtEfica2 := IIf( TNF->TNF_DTENTR > dDtEfica2, dDtEfica2, TNF->TNF_DTENTR )
					dDtEntr	  := IIf( TNF->TNF_DTENTR < dInicioRis, dInicioRis, TNF->TNF_DTENTR )
					cPROTEC	  := IIf( TNF->TNF_EPIEFI == "2", "N", IIf( TNF->TNF_EPIEFI == "3", "N", "S" ) )

					If ( nPosCAP := aScan( aInfEpi, { | x | x[ 2 ] == AllTrim( TNF->TNF_NUMCAP ) } ) ) == 0
						aAdd( aInfEpi, { AllTrim( TNF->TNF_CODEPI ), ;
										AllTrim( TNF->TNF_NUMCAP ), ; //Informa��o a ser enviada na tag <docAval>
										AllTrim( Posicione( "SB1", 1, xFilial("SB1") + TNF->TNF_CODEPI, "B1_DESC" ) ) ,; //Informa��o a ser enviada na tag <dscEPI>
										cPROTEC, ; //Informa��o a ser enviada na tag <eficEpi>
										cMedPrt, ; //Informa��o a ser enviada na tag <medProtecao>
										cCndFun, ; //Informa��o a ser enviada na tag <condFuncto>
										cUsuIni, ; //Informa��o a ser enviada na tag <usoInint>
										cPrzVld, ; //Informa��o a ser enviada na tag <przValid>
										cPerTrc, ; //Informa��o a ser enviada na tag <periodicTroca>
										cHigien } ) //Informa��o a ser enviada na tag <higienizacao>
						nPosCAP := Len( aInfEpi )
					EndIf

					dDtDevo := dFimRis

					If !Empty( TNF->TNF_DTDEVO ) .And. TNF->TNF_DTDEVO >= dInicioRis .And. TNF->TNF_DTDEVO < dFimRis
						dDtDevo := TNF->TNF_DTDEVO
					ElseIf Empty( TNF->TNF_DTDEVO )
						dbSelectArea( "TNF" )  //TNF_FILIAL+TNF_MAT+TNF_CODEPI+DTOS(TNF_DTENTR)+TNF_HRENTR
						dbSkip()

						If cXFilTNF + cMat + aTNFobr[ nFor1 ] == TNF->( TNF_FILIAL + TNF_MAT + TNF_CODEPI ) .And. TNF->( !Eof() ) .And. TNF->TNF_INDDEV != "3"

							If dDtEntr < TNF->TNF_DTENTR
								If ( TNF->TNF_DTENTR - 1 ) >= dInicioRis .And. ( TNF->TNF_DTENTR - 1 ) < dFimRis
									dDtDevo := TNF->TNF_DTENTR - 1
								Endif

							ElseIf dDtEntr == TNF->TNF_DTENTR

								If TNF->TNF_DTENTR >= dInicioRis .And. TNF->TNF_DTENTR < dFimRis
									dDtDevo := TNF->TNF_DTENTR
								EndIf
							EndIf
						EndIf
						dbSkip( -1 )
					Endif

					// Grava no TRB
					dbSelectArea( cAliTRB )
					dbSetOrder( 1 )

					If !Dbseek( DTOS( dDtEntr ) + cNumCAP + cPROTEC + DTOS( TNF->TNF_DTENTR ) )
						RecLock( cAliTRB, .T. )
						( cAliTRB )->DTINI  := dDtEntr
						( cAliTRB )->NUMCAP := cNumCAP
						( cAliTRB )->PROTEC := cPROTEC
						( cAliTRB )->DTREAL := TNF->TNF_DTENTR
						( cAliTRB )->DTDEVO := dDtDevo
						( cAliTRB )->CODEPI := TNF->TNF_CODEPI
						Msunlock( cAliTRB )
					Else

						If ( cAliTRB )->CODEPI == TNF->TNF_CODEPI .And. dDtDevo > ( cAliTRB )->DTDEVO
							RecLock( cAliTRB, .F. )
							( cAliTRB )->DTDEVO := dDtDevo
							Msunlock( cAliTRB )
						Endif

					Endif

					// Verifica se pelo menos um EPI foi entregue fora do prazo de validade
					If !( TNF->TNF_DTENTR <= TN3->TN3_DTVENC .And. dDtDevo <= TN3->TN3_DTVENC )
						cPrzVld :=  "N"
					Endif

					// Verifica se funcionario ficou afastado
					nQtdeAfast := 0

					If NGCADICBASE( "TN3_TPDURA", "A", "TN3", .F. )

						If TN3->TN3_TPDURA == "U"
							nQtdeAfast := fQtdeAfast( cFilFun, cMat, TNF->TNF_DTENTR, dDtDevo )
						Endif

					Else
						nQtdeAfast := fQtdeAfast( cFilFun, cMat, TNF->TNF_DTENTR, dDtDevo )
					Endif

					// Verifica se pelo menos um EPI foi utilizado mais do que o seu prazo de durabilidade
					nDiasUtilizados := ( dDtDevo - TNF->TNF_DTENTR ) - nQtdeAfast

					If nDiasUtilizados > TN3->TN3_DURABI
						cPerTrc := "N"
					EndIf

					// Verifica se pelo menos um EPI nao teve higieniza��o
					If TNF->( FieldPos( "TNF_DTMANU" ) ) > 0 .And. TN3->( FieldPos( "TN3_PERMAN" ) ) > 0

						If TN3->TN3_PERMAN > 0 .And. Empty( TNF->TNF_DTMANU )
							cHigien := "N"
						EndIf

					EndIf

					// Ajusta Informa��es do C.A.
					If cPrzVld == "N"
						aInfEpi[ nPosCAP, 8 ] := cPrzVld //Informa��o a ser enviada na tag <przValid>
					EndIf

					If cPerTrc == "N"
						aInfEpi[ nPosCAP, 9 ] := cPerTrc //Informa��o a ser enviada na tag <periodicTroca>
					EndIf

					If cHigien == "N"
						aInfEpi[ nPosCAP, 10 ] := cHigien //Informa��o a ser enviada na tag <higienizacao>
					EndIf

					dbSelectArea( "TNF" )
					dbSkip()
				End

			Else
				dbSelectArea( "TN3" )
				dbSetOrder( 2 ) //TN3_FILIAL+TN3_CODEPI
				dbSeek( cXFilTN3 + aTNFobr[ nFor1 ] )

				While TN3->( !Eof() ) .And. TN3->TN3_CODEPI == aTNFobr[ nFor1 ]

					If TN3->TN3_GENERI == "2"
						dbSelectArea( "TL0" )
						dbSetOrder( 1 ) //TL0_FILIAL+TL0_EPIGEN+TL0_FORNEC+TL0_LOJA+TL0_EPIFIL
						dbSeek( cXFilTL0 + aTNFobr[ nFor1 ] )

						While TL0->( !Eof() ) .And. TL0->TL0_EPIGEN == aTNFobr[ nFor1 ]
							dbSelectArea( "TNF" )
							dbSetOrder( 3 ) //TNF_FILIAL+TNF_MAT+TNF_CODEPI+DTOS(TNF_DTENTR)+TNF_HRENTR

							If Dbseek( cXFilTNF + cMat + TL0->TL0_EPIFIL )

								While TNF->(!Eof()) .And. cXFilTNF + cMat + TL0->TL0_EPIFIL == TNF->( TNF_FILIAL + TNF_MAT + TNF_CODEPI )

									cNumCAP := Space( 12 )

									If TNF->TNF_INDDEV == "3" .Or. TNF->TNF_DTENTR > dFimRis
										dbSelectArea( "TNF" )
										dbSkip()
										Loop
									EndIf

									If TNF->TNF_DTDEVO < dInicioRis .And. !Empty( TNF->TNF_DTDEVO )
										dbSelectArea( "TNF" )
										dbSkip()
										Loop
									EndIf

									If TNF->TNF_INDDEV == "1" //Caso o EPI esteja com status igual a 'Devolvido'
										Dbselectarea( "TNF" )
										dbSkip()
										Loop
									EndIf

									cNumCAP := TNF->TNF_NUMCAP
									lEpiEntregue := .T.

									lEpiSub   := .T.
									lFirst    := .F.
									dDtEfica2 := IIf( TNF->TNF_DTENTR > dDtEfica2, dDtEfica2, TNF->TNF_DTENTR )
									dDtEntr   := IIf( TNF->TNF_DTENTR < dInicioRis, dInicioRis, TNF->TNF_DTENTR )
									cPROTEC	  := IIf( TNF->TNF_EPIEFI == "2", "N", IIf( TNF->TNF_EPIEFI == "3", "N", "S" ) )

									If ( nPosCAP := aScan( aInfEpi, { | x | x[ 2 ] == AllTrim( TNF->TNF_NUMCAP ) } ) ) == 0
										aAdd( aInfEpi, { AllTrim( TNF->TNF_CODEPI ), ;
														AllTrim( TNF->TNF_NUMCAP ), ; //Informa��o a ser enviada na tag <docAval>
														AllTrim( Posicione( "SB1", 1, xFilial( "SB1" ) + TNF->TNF_CODEPI, "B1_DESC" ) ), ; //Informa��o a ser enviada na tag <dscEPI>
														cPROTEC, ; //Informa��o a ser enviada na tag <eficEpi>
														cMedPrt, ; //Informa��o a ser enviada na tag <medProtecao>
														cCndFun, ; //Informa��o a ser enviada na tag <condFuncto>
														cUsuIni, ; //Informa��o a ser enviada na tag <usoInint>
														cPrzVld, ; //Informa��o a ser enviada na tag <przValid>
														cPerTrc, ; //Informa��o a ser enviada na tag <periodicTroca>
														cHigien } ) //Informa��o a ser enviada na tag <higienizacao>
										nPosCAP := Len( aInfEpi )
									EndIf

									dDtDevo := dFimRis

									If !Empty( TNF->TNF_DTDEVO ) .And. TNF->TNF_DTDEVO >= dInicioRis .And. TNF->TNF_DTDEVO < dFimRis
										dDtDevo := TNF->TNF_DTDEVO
									ElseIf Empty( TNF->TNF_DTDEVO )
										dbSelectArea( "TNF" )
										dbSkip()

										If cXFilTNF + cMat + TL0->TL0_EPIFIL == TNF->( TNF_FILIAL + TNF_MAT + TNF_CODEPI );
												.And. TNF->( !Eof() ) .And. TNF->TNF_INDDEV != "3"

											If dDtEntr < TNF->TNF_DTENTR

												If ( TNF->TNF_DTENTR - 1 ) >= dInicioRis .And. ( TNF->TNF_DTENTR - 1 ) < dFimRis
													dDtDevo := TNF->TNF_DTENTR - 1
												EndIf

											ElseIf dDtEntr == TNF->TNF_DTENTR

												If TNF->TNF_DTENTR >= dInicioRis .And. TNF->TNF_DTENTR < dFimRis
													dDtDevo := TNF->TNF_DTENTR
												EndIf
											EndIf
										EndIf
										dbSkip( -1 )
									EndIf

									// Grava no TRB
									dbSelectArea( cAliTRB )
									dbSetOrder( 1 )

									If !dbSeek( DTOS( dDtEntr ) + cNumCAP + cPROTEC + DTOS( TNF->TNF_DTENTR ) )
										RecLock( cAliTRB, .T. )
										( cAliTRB )->DTINI  := dDtEntr
										( cAliTRB )->NUMCAP := cNumCAP
										( cAliTRB )->PROTEC := cPROTEC
										( cAliTRB )->DTREAL := TNF->TNF_DTENTR
										( cAliTRB )->DTDEVO := dDtDevo
										( cAliTRB )->CODEPI := TNF->TNF_CODEPI
										Msunlock( cAliTRB )
									Else

										If ( cAliTRB )->CODEPI == TNF->TNF_CODEPI .And. dDtDevo > ( cAliTRB )->DTDEVO
											RecLock( cAliTRB, .F. )
											( cAliTRB )->DTDEVO := dDtDevo
											Msunlock( cAliTRB )
										Endif

									Endif

									// Verifica se pelo menos um EPI foi entregue fora do prazo de validade
									If !( TNF->TNF_DTENTR <= TN3->TN3_DTVENC .And. dDtDevo <= TN3->TN3_DTVENC )
										cPrzVld := "N"
									EndIf

									// Verifica se funcionario ficou afastado
									nQtdeAfast := 0

									If NGCADICBASE( "TN3_TPDURA", "A", "TN3", .F. )

										If NGSEEK( "TN3", TL0->TL0_FORNEC+TL0->TL0_LOJA+TL0->TL0_EPIGEN, 1, "TN3->TN3_TPDURA" ) == "U"
											nQtdeAfast := fQtdeAfast( cFilFun, cMat, TNF->TNF_DTENTR, dDtDevo )
										Endif

									Else
										nQtdeAfast := fQtdeAfast( cFilFun, cMat, TNF->TNF_DTENTR, dDtDevo )
									Endif

									// Verifica se pelo menos um EPI foi utilizado mais do que o seu prazo de durabilidade
									nDiasUtilizados := ( dDtDevo - TNF->TNF_DTENTR ) - nQtdeAfast

									If nDiasUtilizados > TN3->TN3_DURABI
										cPerTrc := "2"
									EndIf

									// Verifica se pelo menos um EPI nao teve higieniza��o
									If TNF->( FieldPos( "TNF_DTMANU" ) ) > 0 .And. TN3->( FieldPos( "TN3_PERMAN" ) ) > 0

										If TN3->TN3_PERMAN > 0 .And. Empty( TNF->TNF_DTMANU )
											cHigien := "N"
										EndIf

									Endif

									// Ajusta Informa��es do C.A.
									If cPrzVld == "N"
										aInfEpi[ nPosCAP, 8 ] := cPrzVld //Informa��o a ser enviada na tag <przValid>
									EndIf

									If cPerTrc == "N"
										aInfEpi[ nPosCAP, 9 ] := cPerTrc //Informa��o a ser enviada na tag <periodicTroca>
									EndIf

									If cHigien == "N"
										aInfEpi[ nPosCAP, 10 ] := cHigien //Informa��o a ser enviada na tag <higienizacao>
									EndIf

									dbSelectArea( "TNF" )
									dbSkip()
								End
							EndIf
							dbSelectArea( "TL0" )
							TL0->( dbSkip() )
						End
					EndIf
					dbSelectArea( "TN3" )
					TN3->( dbSkip() )
				End
			EndIf

			If !lEpiSub
				lEpiObr := .F.
			EndIf

			If dDtEfica2 > dDtEficaz
				dDtEficaz := dDtEfica2
			Endif

		Next nFor1

		For nFor1 := 1 To Len( aTNFalt )

			lEpiAltOK := .F.
			dDtEfica2 := dFimRis

			aAdd( aOrdEPIs, {} )

			nPosAdd := Len( aOrdEPIs )

			For nFor2 := 1 To Len( aTNFalt[nFor1] )

				dbSelectArea( "TN3" )
				dbSetOrder( 2 )
				dbSeek( xFilial( "TN3" ) + aTNFalt[ nFor1, nFor2 ] )

				While TN3->( !EoF() ) .And. TN3->TN3_FILIAL == xFilial( "TN3" ) .And. TN3->TN3_CODEPI == aTNFalt[ nFor1, nFor2 ]

					If TN3->TN3_GENERI == "2"
						//Procurar os filhos e adicionar no Array
						dbSelectArea( "TL0" )
						dbSetOrder( 1 ) // TL0_FILIAL + TL0_EPIGEN
						If dbSeek( xFilial( "TL0" ) + TN3->TN3_CODEPI )
							aAdd( aOrdEPIs[ nPosAdd ], TL0->TL0_NUMCAP )
						EndIf
					Else
						aAdd( aOrdEPIs[ nPosAdd ], TN3->TN3_NUMCAP )
					EndIf

					TN3->( dbSkip() )
				End

				dbSelectArea( "TNF" )
				dbSetOrder( 3 ) //TNF_FILIAL+TNF_MAT+TNF_CODEPI+DTOS(TNF_DTENTR)+TNF_HRENTR

				If lIncons .And. ( lMdta695 .Or. lMdta630 )

					For nFor3 := 1 To Len( aEpiEso )

						If aTNFalt[ nFor1, nFor2 ] != aEpiEso[ nFor3, 1 ] // Verifica se o EPI � o EPI obrigat�rio em quest�o
							Loop
						EndIf

						If aEpiEso[ nFor3, 9 ] != cMat // Verifica se o EPI pertence ao funcion�rio em quest�o
							Loop
						EndIf

						If !Dbseek( cXFilTNF + cMat + aTNFalt[ nFor1, nFor2 ] )

							lEpiEntregue := .T.

							lEpiSub	  := .T.
							lFirst	  := .F.
							dDtEfica2 := IIf( aEpiEso[ nFor3, 2 ] > dDtEfica2, dDtEfica2, aEpiEso[ nFor3, 2 ] )
							dDtEntr	  := IIf( aEpiEso[ nFor3, 2 ] < dInicioRis, dInicioRis, aEpiEso[ nFor3, 2 ] )
							cPROTEC	  := IIf( aEpiEso[ nFor3, 8 ] == "2", "N", IIf( aEpiEso[ nFor3, 8 ] == "3", "N", "S" ) )

							If ( nPosCAP := aScan( aInfEpi, { | x | x[ 2 ] == AllTrim( TNF->TNF_NUMCAP ) } ) ) == 0

								aAdd( aInfEpi, {;
									AllTrim( aEpiEso[ nFor3, 1 ] ),;
									AllTrim( aEpiEso[ nFor3, 7 ] ),; // Informa��o a ser enviada na tag <docAval>
									AllTrim( Posicione( "SB1", 1, xFilial("SB1") + aEpiEso[ nFor3, 1 ], "B1_DESC" ) ),; // Informa��o a ser enviada na tag <dscEPI>
									cPROTEC,; // Informa��o a ser enviada na tag <eficEpi>
									cMedPrt,; // Informa��o a ser enviada na tag <medProtecao>
									cCndFun,; // Informa��o a ser enviada na tag <condFuncto>
									cUsuIni,; // Informa��o a ser enviada na tag <usoInint>
									cPrzVld,; // Informa��o a ser enviada na tag <przValid>
									cPerTrc,; // Informa��o a ser enviada na tag <periodicTroca>
									cHigien; // Informa��o a ser enviada na tag <higienizacao>
								} )

							EndIf

						EndIf

					Next

				EndIf

				If Dbseek( cXFilTNF + cMat + aTNFalt[ nFor1, nFor2 ] )

					While TNF->( !Eof() ) .And. cXFilTNF + cMat + aTNFalt[ nFor1, nFor2 ] == TNF->( TNF_FILIAL + TNF_MAT + TNF_CODEPI )

						cNumCAP := Space( 12 )

						If TNF->TNF_INDDEV == "3" .Or. TNF->TNF_DTENTR > dFimRis
							Dbselectarea( "TNF" )
							Dbskip()
							Loop
						EndIf

						If TNF->TNF_DTDEVO < dInicioRis .And. !Empty( TNF->TNF_DTDEVO )
							Dbselectarea( "TNF" )
							Dbskip()
							Loop
						EndIf

						If TNF->TNF_INDDEV == "1" //Caso o EPI esteja com status igual a 'Devolvido'
							Dbselectarea( "TNF" )
							dbSkip()
							Loop
						EndIf

						cNumCAP := TNF->TNF_NUMCAP
						lEpiEntregue := .T.

						dbSelectArea( "TN3" )
						dbSetOrder( 1 ) //TN3_FILIAL+TN3_FORNEC+TN3_LOJA+TN3_CODEPI+TN3_NUMCAP
						dbSeek( xFilial( "TN3", cFilFun ) + TNF->TNF_FORNEC + TNF->TNF_LOJA + TNF->TNF_CODEPI + TNF->TNF_NUMCAP )

						lEpiAltOK := .T.
						lFirst    := .F.
						dDtEfica2 := IIf( TNF->TNF_DTENTR > dDtEfica2, dDtEfica2, TNF->TNF_DTENTR )
						dDtEntr   := IIf( TNF->TNF_DTENTR < dInicioRis, dInicioRis, TNF->TNF_DTENTR )
						cPROTEC	  := IIf( TNF->TNF_EPIEFI == "2", "N", IIf( TNF->TNF_EPIEFI == "3", "N", "S" ) )

						If ( nPosCAP := aScan( aInfEpi, { | x | x[ 2 ] == AllTrim( TNF->TNF_NUMCAP ) } ) ) == 0
							aAdd( aInfEpi, { AllTrim( TNF->TNF_CODEPI ), ;
											AllTrim( TNF->TNF_NUMCAP ), ; //Informa��o a ser enviada na tag <docAval>
											AllTrim( Posicione( "SB1", 1, xFilial( "SB1" ) + TNF->TNF_CODEPI, "B1_DESC" ) ), ; //Informa��o a ser enviada na tag <dscEPI>
											cPROTEC, ; //Informa��o a ser enviada na tag <eficEpi>
											cMedPrt, ; //Informa��o a ser enviada na tag <medProtecao>
											cCndFun, ; //Informa��o a ser enviada na tag <condFuncto>
											cUsuIni, ; //Informa��o a ser enviada na tag <usoInint>
											cPrzVld, ; //Informa��o a ser enviada na tag <przValid>
											cPerTrc, ; //Informa��o a ser enviada na tag <periodicTroca>
											cHigien } ) //Informa��o a ser enviada na tag <higienizacao>
							nPosCAP := Len( aInfEpi )
						EndIf

						dDtDevo := dFimRis

						If !Empty( TNF->TNF_DTDEVO ) .And. TNF->TNF_DTDEVO >= dInicioRis .And. TNF->TNF_DTDEVO < dFimRis
							dDtDevo := TNF->TNF_DTDEVO
						ElseIf Empty( TNF->TNF_DTDEVO )
							dbSelectArea( "TNF" )
							dbSkip()

							If cXFilTNF + cMat + aTNFalt[ nFor1, nFor2 ] == TNF->( TNF_FILIAL + TNF_MAT + TNF_CODEPI );
								.And. TNF->( Eof() ) .And. TNF->TNF_INDDEV != "3"

								If dDtEntr < TNF->TNF_DTENTR

									If ( TNF->TNF_DTENTR - 1 ) >= dInicioRis .And. ( TNF->TNF_DTENTR - 1 ) < dFimRis
										dDtDevo := TNF->TNF_DTENTR - 1
									Endif

								ElseIf dDtEntr == TNF->TNF_DTENTR

									If TNF->TNF_DTENTR >= dInicioRis .And. TNF->TNF_DTENTR < dFimRis
										dDtDevo := TNF->TNF_DTENTR
									EndIf
								EndIf
							EndIf
							dbSkip( -1 )
						Endif

						// Grava no TRB
						dbSelectArea( cAliTRB )
						dbSetOrder( 1 )

						If !dbSeek( DTOS( dDtEntr ) + cNumCAP + cPROTEC + DTOS( TNF->TNF_DTENTR ) )
							RecLock( cAliTRB, .T. )
							( cAliTRB )->DTINI  := dDtEntr
							( cAliTRB )->NUMCAP := cNumCAP
							( cAliTRB )->PROTEC := cPROTEC
							( cAliTRB )->DTREAL := TNF->TNF_DTENTR
							( cAliTRB )->DTDEVO := dDtDevo
							( cAliTRB )->CODEPI := TNF->TNF_CODEPI
							Msunlock( cAliTRB )
						Else

							If ( cAliTRB )->CODEPI == TNF->TNF_CODEPI .And. dDtDevo > ( cAliTRB )->DTDEVO
								RecLock( cAliTRB, .F. )
								( cAliTRB )->DTDEVO := dDtDevo
								Msunlock( cAliTRB )
							Endif

						Endif

						// Verifica se pelo menos um EPI foi entregue fora do prazo de validade
						If !( TNF->TNF_DTENTR <= TN3->TN3_DTVENC .And. dDtDevo <= TN3->TN3_DTVENC )
							cPrzVld := "N"
						EndIf

						// Verifica se funcionario ficou afastado
						nQtdeAfast := 0

						If NGCADICBASE( "TN3_TPDURA", "A", "TN3", .F. )

							If TN3->TN3_TPDURA == "U"
								nQtdeAfast := fQtdeAfast( cFilFun, cMat, TNF->TNF_DTENTR, dDtDevo )
							Endif

						Else
							nQtdeAfast := fQtdeAfast( cFilFun, cMat, TNF->TNF_DTENTR, dDtDevo )
						Endif

						// Verifica se pelo menos um EPI foi utilizado mais do que o seu prazo de durabilidade
						nDiasUtilizados := ( dDtDevo - TNF->TNF_DTENTR ) - nQtdeAfast

						If nDiasUtilizados > TN3->TN3_DURABI
							cPerTrc := "N"
						EndIf

						// Verifica se pelo menos um EPI nao teve higieniza��o
						If TNF->( FieldPos( "TNF_DTMANU" ) ) > 0 .And. TN3->( FieldPos( "TN3_PERMAN" ) ) > 0

							If TN3->TN3_PERMAN > 0 .And. Empty( TNF->TNF_DTMANU )
								cHigien := "N"
							EndIf

						EndIf

						//Ajusta Informa��es do C.A.
						If cPrzVld == "N"
							aInfEpi[ nPosCAP, 8 ] := cPrzVld //Informa��o a ser enviada na tag <przValid>
						EndIf

						If cPerTrc == "N"
							aInfEpi[ nPosCAP, 9 ] := cPerTrc //Informa��o a ser enviada na tag <periodicTroca>
						EndIf

						If cHigien == "N"
							aInfEpi[ nPosCAP, 10 ] := cHigien //Informa��o a ser enviada na tag <higienizacao>
						EndIf

						dbSelectArea( "TNF" )
						dbSkip()
					End

				Else
					dbSelectArea( "TN3" )
					dbSetOrder( 2 ) //TN3_FILIAL+TN3_CODEPI
					dbSeek( cXFilTN3 + aTNFalt[ nFor1, nFor2 ] )

					While TN3->( !Eof() ) .And. TN3->TN3_CODEPI == aTNFalt[ nFor1, nFor2 ]

						If TN3->TN3_GENERI == "2"
							dbSelectArea( "TL0" )
							dbSetOrder( 1 ) //TL0_FILIAL+TL0_EPIGEN+TL0_FORNEC+TL0_LOJA+TL0_EPIFIL
							dbSeek( cXFilTL0 + aTNFalt[ nFor1, nFor2 ] )

							While TL0->( !Eof() ) .And. TL0->TL0_EPIGEN == aTNFalt[ nFor1, nFor2 ]
								dbSelectArea( "TNF" )
								dbSetOrder( 3 ) //TNF_FILIAL+TNF_MAT+TNF_CODEPI+DTOS(TNF_DTENTR)+TNF_HRENTR

								If Dbseek( cXFilTNF + cMat + TL0->TL0_EPIFIL )
									While TNF->(!Eof()) .And. cXFilTNF + cMat + TL0->TL0_EPIFIL == TNF->(TNF_FILIAL + TNF_MAT + TNF_CODEPI)

										cNumCAP := Space( 12 )

										If TNF->TNF_INDDEV == "3" .Or. TNF->TNF_DTENTR > dFimRis
											Dbselectarea( "TNF" )
											Dbskip()
											Loop
										Endif

										If TNF->TNF_DTDEVO < dInicioRis .And. !Empty( TNF->TNF_DTDEVO )
											Dbselectarea( "TNF" )
											Dbskip()
											Loop
										Endif

										If TNF->TNF_INDDEV == "1" //Caso o EPI esteja com status igual a 'Devolvido'
											Dbselectarea( "TNF" )
											dbSkip()
											Loop
										EndIf

										cNumCAP := TNF->TNF_NUMCAP
										lEpiEntregue := .T.

										lEpiAltOK := .T.
										lFirst    := .F.
										dDtEfica2 := IIf( TNF->TNF_DTENTR > dDtEfica2, dDtEfica2, TNF->TNF_DTENTR )
										dDtEntr   := IIf( TNF->TNF_DTENTR < dInicioRis, dInicioRis, TNF->TNF_DTENTR )
										cPROTEC	  := IIf( TNF->TNF_EPIEFI == "2", "N", IIf( TNF->TNF_EPIEFI == "3", "N", "S" ) )

										If ( nPosCAP := aScan( aInfEpi, { | x | x[ 2 ] == AllTrim( TNF->TNF_NUMCAP ) } ) ) == 0
											aAdd( aInfEpi, { AllTrim( TNF->TNF_CODEPI ), ;
															AllTrim( TNF->TNF_NUMCAP ), ; //Informa��o a ser enviada na tag <docAval>
															AllTrim( Posicione( "SB1", 1, xFilial( "SB1" ) + TNF->TNF_CODEPI, "B1_DESC" ) ), ; //Informa��o a ser enviada na tag <dscEPI>
															cPROTEC, ; //Informa��o a ser enviada na tag <eficEpi>
															cMedPrt, ; //Informa��o a ser enviada na tag <medProtecao>
															cCndFun, ; //Informa��o a ser enviada na tag <condFuncto>
															cUsuIni, ; //Informa��o a ser enviada na tag <usoInint>
															cPrzVld, ; //Informa��o a ser enviada na tag <przValid>
															cPerTrc, ; //Informa��o a ser enviada na tag <periodicTroca>
															cHigien } ) //Informa��o a ser enviada na tag <higienizacao>
											nPosCAP := Len( aInfEpi )
										EndIf

										dDtDevo := dFimRis

										If !Empty( TNF->TNF_DTDEVO ) .And. TNF->TNF_DTDEVO >= dInicioRis .And. TNF->TNF_DTDEVO < dFimRis
											dDtDevo := TNF->TNF_DTDEVO
										Elseif Empty( TNF->TNF_DTDEVO )
											dbSelectArea( "TNF" )
											dbSkip()

											If cXFilTNF + cMat + TL0->TL0_EPIFIL == TNF->( TNF_FILIAL + TNF_MAT + TNF_CODEPI );
													.And. TNF->( !Eof() ) .And. TNF->TNF_INDDEV != "3"

												If dDtEntr < TNF->TNF_DTENTR

													If ( TNF->TNF_DTENTR - 1 ) >= dInicioRis .And. ( TNF->TNF_DTENTR - 1 ) < dFimRis
														dDtDevo := TNF->TNF_DTENTR - 1
													Endif

												ElseIf dDtEntr == TNF->TNF_DTENTR

													If TNF->TNF_DTENTR >= dInicioRis .And. TNF->TNF_DTENTR < dFimRis
														dDtDevo := TNF->TNF_DTENTR
													EndIf
												EndIf
											EndIf
											dbSkip( -1 )
										Endif

										//Grava no TRB
										dbSelectArea( cAliTRB )
										dbSetOrder( 1 )

										If !Dbseek( DTOS( dDtEntr ) + cNumCAP + cPROTEC + DTOS( TNF->TNF_DTENTR ) )
											RecLock( cAliTRB, .T. )
											( cAliTRB )->DTINI  := dDtEntr
											( cAliTRB )->NUMCAP := cNumCAP
											( cAliTRB )->PROTEC := cPROTEC
											( cAliTRB )->DTREAL := TNF->TNF_DTENTR
											( cAliTRB )->DTDEVO := dDtDevo
											( cAliTRB )->CODEPI := TNF->TNF_CODEPI
											Msunlock( cAliTRB )
										Else

											If ( cAliTRB )->CODEPI == TNF->TNF_CODEPI .And. dDtDevo > ( cAliTRB )->DTDEVO
												RecLock( cAliTRB, .F. )
												( cAliTRB )->DTDEVO := dDtDevo
												Msunlock( cAliTRB )
											Endif

										Endif

										// Verifica se pelo menos um EPI foi entregue fora do prazo de validade
										If !( TNF->TNF_DTENTR <= TN3->TN3_DTVENC .And. dDtDevo <= TN3->TN3_DTVENC )
											cPrzVld := "N"
										EndIf

										// Verifica se funcionario ficou afastado
										nQtdeAfast := 0

										If NGCADICBASE( "TN3_TPDURA", "A", "TN3", .F. )

											If NGSEEK( "TN3", TL0->TL0_FORNEC + TL0->TL0_LOJA + TL0->TL0_EPIGEN, 1, "TN3->TN3_TPDURA" ) == "U"
												nQtdeAfast := fQtdeAfast( cFilFun, cMat, TNF->TNF_DTENTR, dDtDevo )
											Endif

										Else
											nQtdeAfast := fQtdeAfast( cFilFun, cMat, TNF->TNF_DTENTR, dDtDevo )
										Endif

										// Verifica se pelo menos um EPI foi utilizado mais do que o seu prazo de durabilidade
										nDiasUtilizados := ( dDtDevo - TNF->TNF_DTENTR ) - nQtdeAfast

										If nDiasUtilizados > TN3->TN3_DURABI
											cPerTrc := "N"
										EndIf

										// Verifica se pelo menos um EPI nao teve higieniza��o
										If TNF->( FieldPos( "TNF_DTMANU" ) ) > 0 .And. TN3->( FieldPos( "TN3_PERMAN" ) ) > 0

											If TN3->TN3_PERMAN > 0 .And. Empty( TNF->TNF_DTMANU )
												cHigien := "N"
											EndIf

										EndIf

										// Ajusta Informa��es do C.A.
										If cPrzVld == "N"
											aInfEpi[ nPosCAP, 8 ] := cPrzVld //Informa��o a ser enviada na tag <przValid>
										EndIf

										If cPerTrc == "N"
											aInfEpi[ nPosCAP, 9 ] := cPerTrc //Informa��o a ser enviada na tag <periodicTroca>
										EndIf

										If cHigien == "N"
											aInfEpi[ nPosCAP, 10 ] := cHigien //Informa��o a ser enviada na tag <higienizacao>
										EndIf

										dbSelectArea( "TNF" )
										TNF->( dbSkip() )
									End
								EndIf
								dbSelectArea( "TL0" )
								TL0->( dbSkip() )
							End
						EndIf
						dbSelectArea( "TN3" )
						TN3->( dbSkip() )
					End
				EndIf

			Next nFor2

			If dDtEfica2 > dDtEficaz
				dDtEficaz := dDtEfica2
			Endif

			If !lEpiAltOK
				lEpiObr := .F.
			Endif

		Next nFor1

		For nOrdEPi := 1 To Len( aOrdEPIs ) // Verificar

			dDtEficaz := IIf( dInicioRis + nLimite_Dias_Epi >= dDtEficaz, dInicioRis, dDtEficaz )

			// Cria historico de epi's entregues
			If !lFirst  //Epi esta previsto p/ funcionario e foi entregue

				If dDtEficaz != dInicioRis
					cCndFun := "N"
					cUsuIni := "N"
				Endif

				If cCndFun == "S"
					fAjustaData( dInicioRis, cAliTRB )
					dbSelectArea( cAliTRB )
					dbSetOrder( 1 )

					// Filtrar o TRB conforme os EPIs do Array
					If dbSeek( xFilial( cAliTRB ) + aOrdEPIs[ nOrdEPi, 1 ] )
						dbGoTop()
						dDtTNFfi2 := ( cAliTRB )->DTDEVO

						While ( cAliTRB )->( !Eof() )
							dDtTNFini := ( cAliTRB )->DTINI

							If ( cAliTRB )->DTDEVO > dDtTNFfi2
								dDtTNFfi2 := ( cAliTRB )->DTDEVO
							Endif

							dbSkip()
							If !Eof()
								If ( cAliTRB )->DTINI > dDtTNFfi2 + nLimite_Dias_Epi .And. ( dDtTNFfi2 + 1 ) <= ( ( cAliTRB )->DTINI - 1 )
									cCndFun		:= "N"
									cUsuIni		:= "N"
									dDtTNFfi2	:= ( cAliTRB )->DTDEVO
									Exit
								EndIf
							Else
								If dFimRis > dDtTNFfi2 + nLimite_Dias_Epi
									cCndFun := "N"
									cUsuIni := "N"
									Exit
								EndIf
							EndIf
						End

						If cCndFun <> "S"
							dbSelectArea( cAliTRB )
							dbSetOrder( 2 )
							dbSeek( " " )

							While ( cAliTRB )->( !Eof() ) .And. ( cAliTRB )->SITUAC == " "

								If lEpiObr
									If AllTrim( ( cAliTRB )->PROTEC ) == "N"
										cCndFun := "N"
										cUsuIni := "N"
										Exit
									Endif
								Else
									cCndFun := "N"
									cUsuIni := "N"
									Exit
								Endif

								dbSelectArea( cAliTRB )
								dbSkip()
							End
						EndIf
					EndIf
				EndIf
			EndIf // Fim - Tem EPI previsto
		Next nOrdEPi
	EndIf //Fim - Consiste EPI

	If !lEpiEntregue
		cCndFun := "N"
		cUsuIni := "N"
		cPrzVld := "N"
		cPerTrc := "N"
		cHigien := "N"
	EndIf

	//------------------------------------------
	// Percorre os EPI's verificando a efic�cia
	//------------------------------------------
	For nEpi := 1 To Len( aInfEpi )
		If aInfEpi[ nEpi, 4 ] == "N"
			lNaoEfic := .T.
			Exit
		EndIf
	Next nEpi

	If lNaoEfic //Caso algum EPI entregue n�o seja eficaz, define todos como n�o eficazes
		For nEpi := 1 To Len( aInfEpi )
			aInfEpi[ nEpi, 4 ] := "N"
		Next nEpi
	EndIf

	//------------------------------------------------------------------------------------------------
	// Atualiza o envio da tag <medProtecao> de acordo com as medidas de controle vinculadas ao risco
	//------------------------------------------------------------------------------------------------
	dbSelectArea( "TJF" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "TJF" ) + cNumRis )
		While TJF->( !Eof() ) .And. TJF->TJF_FILIAL == xFilial( "TJF" ) .And. TJF->TJF_NUMRIS == cNumRis
			If Posicione( "TO4", 1, xFilial( "TO4" ) + TJF->TJF_MEDCON, "TO4_TIPCTR" ) == "2"
				cMedPrt := "S"
				Exit
			EndIf
			TJF->( dbSkip() )
		End
	EndIf

	//Caso exista medida de prote��o
	If cMedPrt == "S"
		//Percorre o array alterando
		For nEpi := 1 To Len( aInfEpi )
			aInfEpi[ nEpi, 5 ] := cMedPrt //Informa��o a ser enviada na tag <medProtecao>
		Next nEpi
	EndIf

	//Caso as informa��es complementares do EPI forem buscadas do cadastro de risco
	If lEPIRis
		For nEpi := 1 To Len( aInfEpi ) //Percorre o array ajustando com as informa��es do risco
			aInfEpi[ nEpi, 6 ] := IIf( cTN0CFu == "1", "S", "N" ) //Informa��o a ser enviada na tag <condFuncto>
			aInfEpi[ nEpi, 7 ] := IIf( cTN0CFu == "1", "S", "N" ) //Informa��o a ser enviada na tag <usoInint>
			aInfEpi[ nEpi, 8 ] := IIf( cTN0PVl == "1", "S", "N" ) //Informa��o a ser enviada na tag <przValid>
			aInfEpi[ nEpi, 9 ] := IIf( cTN0PTr == "1", "S", "N" ) //Informa��o a ser enviada na tag <periodicTroca>
			aInfEpi[ nEpi, 10 ] := IIf( cTN0Hig == "1", "S", "N" ) //Informa��o a ser enviada na tag <higienizacao>
		Next nEpi
	EndIf

	//Deleta a tabela tempor�ria
	If Select( cAliTRB ) > 0
		oTempAli:Delete()
	EndIf

	//Retorna a �rea
	RestArea( aAreaEPI )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fAjustaData
Fun��o replicada de MDTR700, Ajusta os Epis entregues em outra funcao/setor

@param dInicio Data Indica a data de in�cio de exposi��o ao risco.
@param cAliTRB Caracter Alias do TRB

@author Jackson Machado
@since 06/03/2014
/*/
//---------------------------------------------------------------------
Static Function fAjustaData( dInicio , cAliTRB )

Local aRecnos := {}
Local nFor

dbSelectArea( cAliTRB )
dbSetOrder(1)
dbSeek(DTOS(dInicio))
While !Eof() .And. dInicio == ( cAliTRB )->DTINI

	cSvCA     := ( cAliTRB )->NUMCAP
	dDtIniTRB := ( cAliTRB )->DTREAL
	nRecnoTRB := ( cAliTRB )->(Recno())
	lFirstTRB := .T.

	While !Eof() .and. dInicio == ( cAliTRB )->DTINI .And. cSvCA == ( cAliTRB )->NUMCAP
		If !lFirstTRB .and. ( cAliTRB )->DTREAL > dDtIniTRB
			dDtIniTRB := ( cAliTRB )->DTREAL
			nRecnoTRB := ( cAliTRB )->( Recno() )
		Endif

		RecLock( cAliTRB , .F. )
		( cAliTRB )->SITUAC := "S"
		MsUnLock( cAliTRB )

		lFirstTRB := .F.

		dbSelectArea( cAliTRB )
		dbSkip()
	End

	aAdd( aRecnos , nRecnoTRB )
End

For nFor := 1 to Len( aRecnos )
	dbSelectArea( cAliTRB )
	dbGoTo( aRecnos[ nFor ] )
	If ( cAliTRB )->( !Eof() ) .and. ( cAliTRB )->( !Bof() )
		RecLock( cAliTRB , .F. )
		( cAliTRB )->SITUAC := " "
		MsUnLock( cAliTRB )
	Endif
Next nFor

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fQtdeAfast
Fun��o replicada de MDTR700, Verifica se houve afastamento e retorna a
quantidade de dias.

@param cFilFun   Caracter Indica a filial do funcionario.
@param cMatric   Caracter Indica o c�digo da matricula do funcionario.
@param _dtIniRis Data Indica a data de inicio do risco
@param _dtFimRis Data Indica a data de termino do risco

@author Guilherme Benkendorf
@since 05/03/2014
/*/
//---------------------------------------------------------------------
Static Function fQtdeAfast( cFilFun , cMatric , _dtIniRis , _dtFimRis )

Local nPos, nX, nCont := 0
Local nDias   := 0
Local nVetID  := 0
Local dTmpSR8 := StoD("")
Local dIniAfa := StoD("")
Local dFimAfa := StoD("")
Local cModoSR8, cXFilSR8
Local aAfasta := {}
Local lMudou := .F.

cModoSR8 := NGSEEKDIC( "SX2", "SR8", 1, "X2_MODOEMP+X2_MODOUN+X2_MODO" )
cXFilSR8 := FwxFilial( "SR8", cFilFun, Substr(cModoSR8,1,1), Substr(cModoSR8,2,1), Substr(cModoSR8,3,1) )

dbSelectArea( "SR8" )
dbSetOrder( 1 ) //R8_FILIAL+R8_MAT+DTOS(R8_DATAINI)+R8_TIPO
dbSeek( cXFilSR8 + cMatric )
While SR8->( !Eof() ) .And. SR8->R8_FILIAL + SR8->R8_MAT == cXFilSR8 + cMatric

	dTmpSR8 := If( Empty( SR8->R8_DATAFIM ) , _dtFimRis , SR8->R8_DATAFIM )

	If SR8->R8_DATAINI <= _dtFimRis .And. dTmpSR8 >= _dtIniRis .And. !Empty(SR8->R8_DATAINI)

		dIniAfa := If( SR8->R8_DATAINI < _dtIniRis , _dtIniRis , SR8->R8_DATAINI )
		dFimAfa := If( dTmpSR8 > _dtFimRis , _dtFimRis , dTmpSR8 )
		nVetID++
		aAdd( aAfasta , { dIniAfa , dFimAfa , .T. , nVetID } )

	Endif
	dbSelectArea("SR8")
	dbSkip()
End

While nCont < 1000
	nCont++
	lMudou := .F.
	For nX := 1 To Len( aAfasta )
		If aAfasta[ nX , 3 ]
			nPos := aSCAN( aAfasta , { |x| x[1] <= aAfasta[ nX , 2 ] .And. x[ 2 ] >= aAfasta[ nX , 1 ] .And. nX <> x[ 4 ] .And. x[ 3 ] } )
			If nPos > 0
				aAfasta[ nX , 1 ] := If( aAfasta[ nX , 1 ] > aAfasta[ nPos , 1 ] , aAfasta[ nPos , 1 ] , aAfasta[ nX , 1 ] )
				aAfasta[ nX , 2 ] := If( aAfasta[ nX , 2 ] < aAfasta[ nPos , 2 ] , aAfasta[ nPos , 2 ] , aAfasta[ nX , 2 ] )
				aAfasta[ nPos,3 ] := .T.
				lMudou := .T.
			Endif
		Endif
	Next nX

	If !lMudou
		Exit
	Endif
End
For nX := 1 To Len( aAfasta )
	If aAfasta[ nX , 3 ]
		nDias += ( aAfasta[ nX , 2 ] - aAfasta[ nX , 1 ] ) + 1
	Endif
Next nX

Return nDias

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetTpAval
Busca o tipo de avalia��o do agente de acordo com o par�metro MV_NG2TPAG

@return cTpAval, Caracter, Tipo de avalia��o do agente

@sample fGetTpAval( "01.01.001", 23 )

@param cAgente, Caracter, Indica o c�digo do agente do risco
@param nQtAgen, Num�rico, Indica a quantidade de agente no risco

@author Luis Fellipy Bett
@since 05/10/2021
/*/
//---------------------------------------------------------------------
Static Function fGetTpAval( cAgente, nQtAgen )

	Local aArea := GetArea() //Salva a �rea
	Local cTpAgen := SuperGetMv( "MV_NG2TPAG", .F., "1" ) //Verifica por onde o tipo do agente ser� buscado
	Local cTpAval := ""
	
	If cTpAgen == "1" //Caso o tipo do agente for buscado do cadastro de agentes
		cTpAval := Posicione( "TMA", 1, xFilial( "TMA" ) + cAgente, "TMA_AVALIA" )
	ElseIf cTpAgen == "2" //Caso o tipo do agente for buscado do cadastro de riscos
		cTpAval := IIf( nQtAgen > 0, "1", "2" )
	EndIf

	RestArea( aArea ) //Retorna a �rea

Return cTpAval

//---------------------------------------------------------------------
/*/{Protheus.doc} fOpenSX6
Abre o arquivo SX6 na empresa passada por par�metro

@return	Nil, Nulo

@sample	fOpenSX6( "T3" )

@param	cEmpCgh, Caracter, Indica a empresa para que ser� aberta o arquivo SX6

@author	Luis Fellipy Bett
@since	03/05/2022
/*/
//---------------------------------------------------------------------
Static Function fOpenSX6( cEmpCgh )

	//Fecha o arquivo da empresa posicionada
	SX6->( dbCloseArea() )

	//Abre o arquivo na empresa passada por par�metro
	OpenSXs( , , , , cEmpCgh, "SX6", "SX6", , .F. )

Return
