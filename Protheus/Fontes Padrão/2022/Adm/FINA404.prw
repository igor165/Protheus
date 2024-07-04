#Include 'Protheus.ch'
#INCLUDE 'FWADAPTEREAI.CH'
#Include "FINA404.CH" 

Static _lDicInss   := AliasInDic("FJW") .and. AliasInDic("FLX") 
Static _lFLXCATEFD := FLX->(ColumnPos("FLX_CATEFD")) > 0
Static _lFLXTPREC  := FLX->(ColumnPos("FLX_TPREC")) > 0		
Static _lA2CATEFD  := SA2->(ColumnPos("A2_CATEFD")) > 0

/*/{Protheus.doc} FINA404
Funcao de integracao com o adapter EAI para envio de informações dos fornecedores autonomos.
@author	William Matos
@since		17/06/2015
/*/
Function FINA404()
Local oProcesso	:= Nil
Local oGrid		:= Nil

oGrid := FWGridProcess():New(	"FINA404",; //Nome da função
								STR0001,; //"Integraçao de Fornecedores Autonomos
								STR0002,; //Descrição da rotina
								{|lEnd| lRet := FN404EnvioXML(oGrid,@lEnd)},; //Bloco de execução
								"FINA404",;// Pergunte
								Nil,; //cGrid
								.T.) //lSaveLog

oGrid:SetMeters(1)
oGrid:Activate()

Return

/*/{Protheus.doc} FN404EnvioXML
Envio do XML com os dados dos fornecedores autonomos.
@author	William Matos
@since		17/06/2015
/*/
Function FN404EnvioXML(oGrid,lEnd)
Local cAliasXML	:= ""
Local lIntFN404	:= FWHasEAI("FINA404",.T.,.F.,.T.)
Local aLog		:= {}
Local nX		:= 0
Local nRegSM0	:= SM0->(Recno())
Local aSM0		:= FWLoadSM0()
Local nFil		:= 0
Local lErro		:= .F.
Local lRunSched	:= FWGetRunSchedule()
Local cVersion  := FwAdapterVersion("FINA404")
Local lTemDados := .F.

If lIntFN404 //Integração configurada no EAI

	If !lRunSched //Nao carrega se for schedule pois as definicoes sao obtidas de la (botao parametros)
		Pergunte("FINA404", .F. )
		//MV_PAR01 - Data Inicial
		//MV_PAR02 - Data Final
		//MV_PAR03 - Fornecedor Inicial
		//MV_PAR04 - Loja Inicial
		//MV_PAR05 - Fornecedor Final
		//MV_PAR06 - Loja Final
	EndIf

	oGrid:SetMaxMeter(Len(aSM0), 1, STR0012) //"Processando as filiais"

	For nFil := 1 To Len( aSM0 )

		oGrid:SetIncMeter(1)

		If aSM0[nFil][1] == cEmpAnt

			cFilAnt := aSM0[nFil][2]

			cAliasXML 	:= GetNextAlias()

			//Localiza dados de acordo com a versao do Adapter
			If cVersion == "1.000"
				lTemDados := FQry1000(cAliasXML)
			Elseif cVersion == "1.006" .and. _lA2CATEFD
				lTemDados := FQry1006(cAliasXML)
			Elseif cVersion == "1.006" .and. !_lA2CATEFD
				Help(" ",1,"FN404DicDes",,STR0014,1,0) //"Para utilizar a versão informada no Adapter é necessário atualizar o dicionario de dados."
				Aadd(aLog, STR0014)
				exit			
			Else
				Help(" ",1,"FN404VerInv",,STR0013,1,0) //"A versão informada no cadastro do Adapter não foi implementada! Verifique as versões validas."
				Aadd(aLog, STR0013)
				exit
			Endif
			
			//Processa o XML
			If lTemDados
				FN040Struct( (cAliasXML), aLog, @lErro, oGrid, cVersion)
				(cAliasXML)->(DBCloseArea())
				FErase((cAliasXML) + GetDbExtension())
			Else
				Aadd(aLog,STR0004 + " " + STR0007 + AllTrim(cFilAnt) + "." )//"Não existem dados para serem processados."###"Filial: "
			EndIf	

			cAliasXML := ""

		EndIf

	Next nFil

	SM0->(DBGoTo(nRegSM0))
	cFilAnt := FWGETCODFILIAL

	//Salva log de processamento do XML.
	If Len(aLog) > 0

		For nX := 1 To Len(aLog)
			oGrid:SaveLog(aLog[nX])
		Next nX

		aSize(aLog,0)
		aLog := Nil

		If lErro
			Help(" ",1,"FN404EnvioXML",,STR0011,1,0) //"Houve ocorrência na exportação dos dados, consulte o log."
		EndIf

	EndIf

Else

	oGrid:SaveLog(STR0003 ) //'Verifique se o atualizador de dicionário de dados foi aplicado no ambiente e se o Adapter EAI esta configurado corretamente no configurador.'

EndIf

aSize(aSM0,0)
aSM0 := Nil

Return 

/*/{Protheus.doc} FN404EnvioXML
Função que preenche o xml para envio.
@author	William Matos
@since 17/06/2015
@param cAlias - Entidade temporaria com os dados que serão enviados pela mensagem unica
/*/
Function FN040Struct(cAliasXML,aLog,lErro,oGrid,cVersion)
Local cEvent 		:= "UPSERT"
Local cXMLRet		:= ""
Local cXMLCab		:= ""
Local cInternalID	:= ""
Local cCEITomador	:= {}
Local cCGCTomador	:= ""
Local cTpTomador	:= ""
Local cNatService	:= "1" //Urbano
Local aResult		:= {}
Local nX			:= 0
Local nY			:= 0
Local cMensErro		:= ""
Local cChvAux		:= ""
Local lCarreteiro   := .F.
Local nBaseIrfCar	:= 0
Local aSestSenat	:= {}
Local aMultVinc     := {}

Default cVersion    := "1.000"

//Pesquisa dados na SM0
dbSelectArea("SM0")
If SM0->(dbSeek(cEmpAnt))
	cCEITomador	:= SM0->M0_CEI
	cCGCTomador	:= SM0->M0_CGC
	cTpTomador	:= '0' //Default como serviço para o segmento.
EndIf

cXMLCab := '<BusinessEvent>'
cXMLCab += '	<Entity>ExternalAutonomousPayment</Entity>'
cXMLCab += '	<Event>' + cEvent + '</Event>'
cXMLCab += '</BusinessEvent>'
cXMLCab += '<BusinessContent>'
cXMLCab += '<ListOfAutonomous>'

While (cAliasXML)->( !Eof() ) .AND. nX <= 50

	//Caso um dos campos necessarios nao estejam preenchidos, nao envia os dados e gera log
	If	Empty((cAliasXML)->A2_NOME)		.Or.; 
		Empty((cAliasXML)->A2_CGC)		.Or.;
		Empty((cAliasXML)->A2_CBO)		.Or.;
		Empty((cAliasXML)->A2_DTNASC)	.Or.;
		Empty((cAliasXML)->A2_CODNIT)	.Or.;
		Empty((cAliasXML)->A2_CATEG)	.Or.;
		Empty((cAliasXML)->A2_OCORREN)	.Or.;
		(cVersion == "1.006"  .and. Empty((cAliasXML)->A2_CATEFD))

		cChvAux := (cAliasXML)->A2_FILIAL + (cAliasXML)->A2_COD + (cAliasXML)->A2_LOJA

		cMensErro := STR0005 + AllTrim((cAliasXML)->A2_COD) + STR0006 + AllTrim((cAliasXML)->A2_LOJA) + If(!Empty((cAliasXML)->A2_FILIAL)," (" + STR0007 + AllTrim(cFilAnt) + ")","" ) + STR0008 //"O Fornecedor: "###" Loja: "###"Filial: "###", está com seu cadastro incompleto para envio dos dados."

		cMensErro += STR0009 //" Confira os campos: "

		cMensErro += AllTrim(RetTitle("A2_NOME"))		+ ", "
		cMensErro += AllTrim(RetTitle("A2_CGC"))		+ ", "
		cMensErro += AllTrim(RetTitle("A2_CBO"))		+ ", "
		cMensErro += AllTrim(RetTitle("A2_DTNASC"))		+ ", "
		cMensErro += AllTrim(RetTitle("A2_CODNIT"))		+ ", "
		If cVersion == "1.006"
			cMensErro += AllTrim(RetTitle("A2_CATEFD"))		+ ", "
		Endif
		cMensErro += AllTrim(RetTitle("A2_CATEG"))		+ STR0010 //" e "
		cMensErro += AllTrim(RetTitle("A2_OCORREN"))	+ "."

		Aadd(aLog,cMensErro)
		lErro := .T.

		//Faz laço para pular todos os titulos do fornecedor com dados incompletos
		While (cAliasXML)->(!Eof()) .And. cChvAux == (cAliasXML)->A2_FILIAL + (cAliasXML)->A2_COD + (cAliasXML)->A2_LOJA  
			(cAliasXML)->(DBSkip())
		EndDo

		//Se nao acabou os dados, volto 1, pois o loop avancara para o proximo
		If (cAliasXML)->(!Eof())
			(cAliasXML)->(DBSkip(-1))
		EndIf

		Loop

	EndIf

	If (cAliasXML)->A2_INDRUR == '0' //Não é Produtor rural.
		cNatService := '1' //Urbano 
	Else
		cNatService := '2' //Rural
	EndIf

	cInternalID :=	cEmpAnt							+ "|" + ;
					RTrim(XFilial("SE2"))			+ "|" + ;
					RTrim((cAliasXML)->E2_PREFIXO)	+ "|" + ;
					RTrim((cAliasXML)->E2_NUM)		+ "|" + ;
					RTrim((cAliasXML)->E2_PARCELA)	+ "|" + ;
					RTrim((cAliasXML)->E2_TIPO)		+ "|" + ;
					RTrim((cAliasXML)->E2_FORNECE)	+ "|" + ;
					RTrim((cAliasXML)->E2_LOJA)

	lCarreteiro := F404Carret(cAliasXML,cVersion)
	nBaseIrfCar	:= IIF(lCarreteiro,F404BasIRC(cAliasXML,cVersion),0)
	aSestSenat	:= F404SestSenat(cAliasXML,cVersion)
	aMultVinc	:= F404MultVinc(cAliasXML,cVersion)

	cXMLRet +=	'<Autonomous>'
	cXMLRet +=	'<CompanyId>'						+ AllTrim(cEmpAnt)  	 								+ '</CompanyId>'
	cXMLRet +=	'<BranchId>'						+ AllTrim(cFilAnt) 	 									+ '</BranchId>'
	cXMLRet +=	'<InternalId>'						+ cInternalID 		 									+ '</InternalId>'
	cXMLRet +=  '<CompanyInternalId>'				+ AllTrim(cEmpAnt + "|" + cFilAnt) 						+ '</CompanyInternalId>'
	cXMLRet +=	'<TakerId>'							+ cCGCTomador 		 									+ '</TakerId>'
	cXMLRet +=	'<TakerSpecificId>'					+ cCEITomador 											+ '</TakerSpecificId>'
	cXMLRet +=	'<TakerType>'						+ cTpTomador 			 								+ '</TakerType>'
	cXMLRet +=	'<AutonomousName>'					+ _NoTags((cAliasXML)->A2_NOME)							+ '</AutonomousName>'
	cXMLRet +=	'<DateOfBirth>'						+ Transform((cAliasXML)->A2_DTNASC,"@R 9999-99-99")		+ '</DateOfBirth>'
	cXMLRet +=	'<AutonomousId>'					+ AllTrim((cAliasXML)->A2_CGC)							+ '</AutonomousId>'
	cXMLRet +=	'<RegistrationNumber>'				+ (cAliasXML)->A2_CODNIT								+ '</RegistrationNumber>'
	cXMLRet +=	'<AutonomousOcupationNationalCode>'	+ (cAliasXML)->A2_CBO									+ '</AutonomousOcupationNationalCode>'
	cXMLRet +=	'<AutonomousCategory>'				+ (cAliasXML)->A2_CATEG									+ '</AutonomousCategory>'
	cXMLRet +=	'<SefipEventCode>'					+ (cAliasXML)->A2_OCORREN								+ '</SefipEventCode>'
	cXMLRet +=	'<IssueDate>'						+ Transform((cAliasXML)->E2_EMISSAO, "@R 9999-99-99")	+ '</IssueDate>'
	cXMLRet +=	'<DueDate>'							+ Transform((cAliasXML)->E2_VENCTO,"@R 9999-99-99" )	+ '</DueDate>'
	cXMLRet +=	'<InitiationDate>'					+ Transform((cAliasXML)->E2_EMISSAO,"@R 9999-99-99")	+ '</InitiationDate>'
	cXMLRet +=	'<ServiceNature>'					+ _NoTags(cNatService)									+ '</ServiceNature>'
	cXMLRet +=	'<DependentsNumber>'				+ cValToChar((cAliasXML)->A2_NUMDEP)					+ '</DependentsNumber>'
	cXMLRet +=	'<IRRFDependentsNumber>'			+ cValToChar((cAliasXML)->A2_NUMDEP)					+ '</IRRFDependentsNumber>'
	cXMLRet +=	'<PaymentValue>'					+ cValtoChar(ABS((cAliasXML)->E2_BASEINS))				+ '</PaymentValue>'
	cXMLRet +=	'<INSSValue>'						+ cValtoChar(ABS((cAliasXML)->E2_INSS))					+ '</INSSValue>'

	If cVersion == "1.006"
		If _lA2CATEFD
			cXMLRet +=	'<eSocialAutonomousCategory>'		    + (cAliasXML)->A2_CATEFD			+ '</eSocialAutonomousCategory>'
		Endif
		cXMLRet +=	'<ISSValue>'					    	+ cValtoChar(ABS((cAliasXML)->E2_ISS))				+ '</ISSValue>'   
		cXMLRet +=	'<SESTValue>'						    + cValtoChar(ABS(aSestSenat[1]))				    + '</SESTValue>'  
		cXMLRet +=	'<SENATValue>'						    + cValtoChar(ABS(aSestSenat[2]))		   	        + '</SENATValue>' 
		cXMLRet +=	'<IRRFValue>'							+ cValtoChar(ABS((cAliasXML)->E2_IRRF)) 	   		+ '</IRRFValue>' 
		cXMLRet +=	'<RemunerationValueWithIRRFIncidence>'  + cValtoChar(ABS(nBaseIrfCar))                      + '</RemunerationValueWithIRRFIncidence>'
		If lCarreteiro
			cXMLRet +=	'<FreightRemunerationValue>'            + cValtoChar(ABS((cAliasXML)->E2_VALOR))  	    + '</FreightRemunerationValue>' 		
			cXMLRet +=	'<RemunerationValueWithINSSIncidence>'	+ cValtoChar(ABS((cAliasXML)->E2_BASEINS))      + '</RemunerationValueWithINSSIncidence>'
		Endif
		If !Empty((cAliasXML)->E2_BAIXA)
			cXMLRet +=	'<PaymentDate>'	+ Transform((cAliasXML)->E2_BAIXA, "@R 9999-99-99") + '</PaymentDate>'
		Endif 
		If !Empty(aMultVinc) //Verifica se há multiplos vinculos empregaticios p/ o fornecedor
			cXMLRet +=	'<MultipleEmploymentIndicator>'	  + aMultVinc[1][1]	  + '</MultipleEmploymentIndicator>'
			cXMLRet +=	'<OtherEmployments>
			For nY := 1 To Len(aMultVinc)
				cXMLRet +=	'<OtherEmployment>
				cXMLRet +=	'<OtherEmploymentId>'	      + aMultVinc[nY][2]  + '</OtherEmploymentId>'
				cXMLRet +=	'<OtherEmploymentCategory>'	  + aMultVinc[nY][3]  + '</OtherEmploymentCategory>'
				cXMLRet +=	'<OtherEmploymentINSSBasis>'  + aMultVinc[nY][4]  + '</OtherEmploymentINSSBasis>'
				cXMLRet +=	'</OtherEmployment>   
			Next nY
			cXMLRet +=	'</OtherEmployments>'
		Endif 

	Endif
	
	cXMLRet +=	'</Autonomous>'	
	
	nX++
	(cAliasXML)->(DbSkip())
	If nX == 50

		cXMLRet += 	'	</ListOfAutonomous>'
		cXMLRet += 	'</BusinessContent>'

		cXmlRet := cXMLCab + cXmlRet

		//Envia os dados.
		aResult := FwIntegDef( 'FINA404', EAI_MESSAGE_BUSINESS , TRANS_SEND , cXMLRet ) 
		If !aResult[1]
			Aadd(aLog,cValToChar(aResult[2]))
			lErro := .T.
		Else
			cXMLRet := ""
			nX 		 := 0
		EndIf

	EndIf

EndDo

If nX > 0

	cXMLRet += '	</ListOfAutonomous>'
	cXMLRet += '</BusinessContent>'

	cXmlRet := cXMLCab + cXmlRet

	//Envia os dados.
	aResult := FwIntegDef( 'FINA404', EAI_MESSAGE_BUSINESS , TRANS_SEND , cXMLRet ) 

	If !aResult[1]
		Aadd(aLog,cValToChar(aResult[2]))
		lErro := .T.
	EndIf

EndIf

FwFreeArray(aSestSenat)
FwFreeArray(aMultVinc)
FwFreeArray(aResult)

Return

/*/{Protheus.doc}IntegDef
Mensagem unica de integração com RM, envio de dados dos fornecedores autonomos.
@param cXml	  Xml passado para a rotina
@param nType 	  Determina se e uma mensagem a ser enviada/recebida ( TRANS_SEND ou TRANS_RECEIVE)
@param cTypeMessage Tipo de mensagem ( EAI_MESSAGE_WHOIS, EAI_MESSAGE_RESPONSE, EAI_MESSAGE_BUSINESS)
@author William Matos
@since  19/06/15
/*/

Static Function IntegDef( cXml, cType, cTypeMessage, cVersion, cTransac)
Local aRet := {}

aRet := FINI404( cXml, cType, cTypeMessage, cVersion, cTransac)

Return aRet

/*/{Protheus.doc} SchedDef
Utilizado somente se a rotina for executada via Schedule.
Permite usar o botao Parametros da nova rotina de Schedule
para definir os parametros(SX1) que serao passados a rotina agendada.
@author  TOTVS
@version 12.1.11
@since   04/03/2016
@return  aParam
/*/
Static Function SchedDef()
Local aParam := {}

aParam := {	"P"			,;	//Tipo R para relatorio P para processo
				"FINA404"	,;	//Nome do grupo de perguntas (SX1)
				Nil			,;	//cAlias (para Relatorio)
				Nil			,;	//aArray (para Relatorio)
				Nil			}	//Titulo (para Relatorio)

Return aParam

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FQry1000
Executa query para atender a versao 1.000 do Adapter

@author fabio.casagrande
@since 05/01/2021

@param cAliasXML, characters, alias para a tabela temporaria
@return lRet, Lógico indicado se a query foi executada
/*/
//-------------------------------------------------------------------------------
Static Function FQry1000(cAliasXML As Character) As Logical

	Local lRet     As Logical
	Local cQuery   As Character
	Local cSepAba  As Character
	Local cSepAnt  As Character
	Local cSepNeg  As Character
	Local cSepProv As Character
	Local cSepRec  As Character

	Default cAliasXML := GetNextAlias()

	lRet     := .F.
	cQuery   := ""
	cSepAba	 := If("|"$MVABATIM,"|",",")
	cSepAnt	 := If("|"$MVPAGANT,"|",",")
	cSepNeg	 := If("|"$MV_CRNEG,"|",",")
	cSepProv := If("|"$MVPROVIS,"|",",")
	cSepRec	 := If("|"$MVRECANT,"|",",")

	//Monta query.
	cQuery := " SELECT E2_BASEINS, E2_INSS, E2_EMISSAO, E2_VENCTO, E2_FORNECE, E2_LOJA, E2_PREFIXO, "   + CRLF 
	cQuery +=		" E2_NUM, E2_PARCELA, E2_TIPO, SE2.R_E_C_N_O_, " 								    + CRLF
	cQuery +=		" A2_NOME, A2_CGC, A2_NUMDEP, A2_FILIAL, A2_COD, A2_LOJA, A2_DTNASC, "				+ CRLF
	cQuery +=		" A2_INDRUR, A2_CODNIT, A2_CBO, A2_CATEG, A2_OCORREN " 								+ CRLF
	cQuery += " FROM " + RetSQLName("SE2") + ' SE2 ' 													+ CRLF
	cQuery +=		" INNER JOIN " + RetSQLName("SA2") + " SA2 ON A2_COD = E2_FORNECE " 				+ CRLF
	cQuery +=		" AND A2_LOJA = E2_LOJA " 															+ CRLF
	cQuery += " WHERE " 																				+ CRLF
	cQuery +=		" A2_FILIAL = '" + XFilial("SA2") + "' AND "										+ CRLF
	cQuery +=		" A2_TIPO = 'F' AND " 																+ CRLF //Apenas registros de fornecedore fisicos.
	cQuery +=		" (A2_DTNASC	<> ' ' OR "															+ CRLF //Considera o fornecedor caso algum dado da pasta Autonomos esteja preenchido
	cQuery +=		" A2_CODNIT	<> ' ' OR "																+ CRLF
	cQuery +=		" A2_CATEG		<> ' ' OR "															+ CRLF
	cQuery +=		" A2_OCORREN	<> ' ') AND "														+ CRLF
	cQuery +=		" E2_FILORIG = '"			+ cFilAnt + "' AND "									+ CRLF
	cQuery +=		" E2_EMISSAO BETWEEN '"	+ DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02)	+ "' AND "	+ CRLF
	cQuery +=		" E2_FORNECE BETWEEN '"	+ MV_PAR03 + "' AND '"+ MV_PAR05 				+ "' AND "	+ CRLF
	cQuery +=		" E2_LOJA    BETWEEN '"	+ MV_PAR04 + "' AND '"+ MV_PAR06				+ "' AND "	+ CRLF
	cQuery +=		" E2_TIPO NOT IN "		+ FormatIn(MVABATIM,cSepAba)					+ " AND "	+ CRLF
	cQuery +=		" E2_TIPO NOT IN "		+ FormatIn(MVPAGANT,cSepAnt)					+ " AND "	+ CRLF
	cQuery +=		" E2_TIPO NOT IN "		+ FormatIn(MV_CRNEG,cSepNeg)					+ " AND "	+ CRLF
	cQuery +=		" E2_TIPO NOT IN "		+ FormatIn(MVPROVIS,cSepProv)					+ " AND "	+ CRLF
	cQuery +=		" E2_TIPO NOT IN "		+ FormatIn(MVRECANT,cSepRec)					+ " AND "	+ CRLF
	cQuery +=		" E2_SEFIP = ' ' AND "																+ CRLF //Apenas registros que não foram integrados.
	cQuery +=		" SA2.D_E_L_E_T_ = '' AND SE2.D_E_L_E_T_ = '' "										+ CRLF
	cQuery +=		"AND NOT EXISTS ("																	+ CRLF
	cQuery +=			" SELECT E5_NUMERO "															+ CRLF
	cQuery +=			" FROM " + RetSQLName("SE5") + " SE5 "											+ CRLF
	cQuery +=			" WHERE SE5.E5_FILIAL = '" + XFilial("SE5") + "' AND "							+ CRLF
	cQuery +=				" SE5.E5_PREFIXO	= SE2.E2_PREFIXO	AND "								+ CRLF
	cQuery +=				" SE5.E5_NUMERO	= SE2.E2_NUM	AND "										+ CRLF
	cQuery +=				" SE5.E5_PARCELA	= SE2.E2_PARCELA	AND "								+ CRLF
	cQuery +=				" SE5.E5_TIPO		= SE2.E2_TIPO		AND "								+ CRLF
	cQuery +=				" SE5.E5_CLIFOR	= SE2.E2_FORNECE	AND "									+ CRLF
	cQuery +=				" SE5.E5_LOJA		= SE2.E2_LOJA		AND "								+ CRLF
	cQuery +=				" SE5.E5_MOTBX	= 'DSD'			AND "										+ CRLF
	cQuery +=				" SE5.E5_RECPAG	= 'P'				AND "									+ CRLF
	cQuery +=				" SE5.D_E_L_E_T_	= ' ') "												+ CRLF
	cQuery += " ORDER BY A2_COD, A2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO "

	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasXML,.T.,.T.)
	DbSelectArea(cAliasXML)

	//Processa o XML
	If (cAliasXML)->( !Eof() )
		lRet := .T.
	Endif

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FQry1006
Executa query para atender a versao 1.006 do Adapter

@author fabio.casagrande
@since 05/01/2021

@param cAliasXML, characters, alias para a tabela temporaria
@return lRet, Lógico indicado se a query foi executada
/*/
//-------------------------------------------------------------------------------
Static Function FQry1006(cAliasXML As Character) As Logical

	Local lRet      As Logical
	Local cQuery 	As Character
	Local cSepAba   As Character
	Local cSepAnt   As Character
	Local cSepNeg   As Character
	Local cSepProv  As Character
	Local cSepRec   As Character

	lRet      := .F.
	cQuery    := ""
	cSepAba	  := If("|"$MVABATIM,"|",",")
	cSepAnt	  := If("|"$MVPAGANT,"|",",")
	cSepNeg	  := If("|"$MV_CRNEG,"|",",")
	cSepProv  := If("|"$MVPROVIS,"|",",")
	cSepRec	  := If("|"$MVRECANT,"|",",")

	Default cAliasXML := GetNextAlias()

	//Monta query.
	cQuery := " SELECT E2_BASEINS, E2_BASEIRF, E2_INSS, E2_SEST, E2_ISS, E2_IRRF, E2_VALOR, E2_EMISSAO,  "	    + CRLF
	cQuery +=		" E2_VENCTO, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_ORIGEM, "     + CRLF
	cQuery +=		" E2_BAIXA, SE2.R_E_C_N_O_, A2_NOME, A2_CGC, A2_NUMDEP, A2_FILIAL, A2_COD, A2_LOJA, "  		+ CRLF
	cQuery +=		" A2_DTNASC, A2_INDRUR, A2_CODNIT, A2_CBO, A2_CATEG, A2_OCORREN, "					    	+ CRLF
	If _lA2CATEFD
		cQuery +=		" A2_CATEFD," 																			+ CRLF	
	Endif
	cQuery +=		" ED_IRRFCAR, ED_INSSCAR, ED_PERCSES, "														+ CRLF
	If _lDicInss
		cQuery +=	" COALESCE(FJW_FORNEC,'') FJW_FORNEC "														+ CRLF
	Endif
	cQuery += " FROM " + RetSQLName("SE2") + ' SE2 ' 													    	+ CRLF
	cQuery +=		" INNER JOIN " + RetSQLName("SA2") + " SA2 ON A2_COD = E2_FORNECE " 					    + CRLF
	cQuery +=		" AND A2_LOJA = E2_LOJA AND A2_FILIAL = '" + xFilial("SA2") + "' "   						+ CRLF
	cQuery +=		" INNER JOIN " + RetSQLName("SED") + " SED ON ED_CODIGO = E2_NATUREZ " 						+ CRLF
	cQuery +=		" AND SED.ED_FILIAL  = '" + xFilial("SED") + "' AND SED.D_E_L_E_T_ = ' ' "											+ CRLF	
	If _lDicInss
		cQuery +=	" LEFT JOIN " + RetSQLName("FJW") + " FJW ON FJW_FORNEC = A2_COD AND FJW.D_E_L_E_T_ = ' ' " + CRLF	
	Endif	
	cQuery += " WHERE " 																						+ CRLF
	cQuery +=		" A2_FILIAL = '" + XFilial("SA2") + "' AND "												+ CRLF
	cQuery +=		" A2_TIPO = 'F' AND " 																		+ CRLF
	cQuery +=		" (A2_DTNASC	<> ' ' OR "																	+ CRLF
	cQuery +=		" A2_CODNIT	<> ' ' OR "																		+ CRLF
	cQuery +=		" A2_CATEG		<> ' ' OR "																	+ CRLF
	cQuery +=		" A2_OCORREN	<> ' ') AND "																+ CRLF
	cQuery +=		" E2_FILORIG = '"			+ cFilAnt + "' AND "											+ CRLF
	cQuery +=		" E2_FORNECE BETWEEN '"	+ MV_PAR03 + "' AND '"+ MV_PAR05 				+ "' AND "			+ CRLF
	cQuery +=		" E2_LOJA    BETWEEN '"	+ MV_PAR04 + "' AND '"+ MV_PAR06				+ "' AND "			+ CRLF
	cQuery +=		" E2_TIPO NOT IN "		+ FormatIn(MVABATIM,cSepAba)					+ " AND "			+ CRLF
	cQuery +=		" E2_TIPO NOT IN "		+ FormatIn(MVPAGANT,cSepAnt)					+ " AND "			+ CRLF
	cQuery +=		" E2_TIPO NOT IN "		+ FormatIn(MV_CRNEG,cSepNeg)					+ " AND "			+ CRLF
	cQuery +=		" E2_TIPO NOT IN "		+ FormatIn(MVPROVIS,cSepProv)					+ " AND "			+ CRLF
	cQuery +=		" E2_TIPO NOT IN "		+ FormatIn(MVRECANT,cSepRec)					+ " AND "			+ CRLF
	cQuery +=		" ((E2_SEFIP =' ' AND E2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') OR "+ CRLF
	cQuery +=		" (E2_SEFIP = 'X' AND E2_SALDO = 0 AND  " 													+ CRLF			
	cQuery +=		" E2_BAIXA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"')) and	"					+ CRLF
	cQuery +=		" SA2.D_E_L_E_T_ = '' AND SE2.D_E_L_E_T_ = '' "												+ CRLF
	cQuery +=		"AND NOT EXISTS ("																			+ CRLF
	cQuery +=			" SELECT E5_NUMERO "																	+ CRLF
	cQuery +=			" FROM " + RetSQLName("SE5") + " SE5 "													+ CRLF
	cQuery +=			" WHERE SE5.E5_FILIAL = '" + XFilial("SE5") + "' AND "									+ CRLF
	cQuery +=				" SE5.E5_PREFIXO	= SE2.E2_PREFIXO	AND "										+ CRLF
	cQuery +=				" SE5.E5_NUMERO	= SE2.E2_NUM	AND "												+ CRLF
	cQuery +=				" SE5.E5_PARCELA	= SE2.E2_PARCELA	AND "										+ CRLF
	cQuery +=				" SE5.E5_TIPO		= SE2.E2_TIPO		AND "										+ CRLF
	cQuery +=				" SE5.E5_CLIFOR	= SE2.E2_FORNECE	AND "											+ CRLF
	cQuery +=				" SE5.E5_LOJA		= SE2.E2_LOJA		AND "										+ CRLF
	cQuery +=				" SE5.E5_MOTBX	= 'DSD'			AND "												+ CRLF
	cQuery +=				" SE5.E5_RECPAG	= 'P'				AND "											+ CRLF
	cQuery +=				" SE5.D_E_L_E_T_	= ' ') "														+ CRLF
	cQuery += " ORDER BY A2_COD, A2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO "

	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasXML,.T.,.T.)
	DbSelectArea(cAliasXML)

	//Processa o XML
	If (cAliasXML)->( !Eof() )
		lRet := .T.
	Endif

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} F404Carret
Verifica se o autonomo é carreteiro

@author fabio.casagrande
@since 11/01/2021

@param cAliasXML, characters, alias para a tabela temporaria
@param cVersion, characters, versao do adapter
@return lRet, Lógico indicado se é carreteiro
/*/
//-------------------------------------------------------------------------------
Static Function F404Carret(cAliasXML As Character, cVersion As Character) As Logical 

	Local lRet As Logical

	Default cAliasXML := ""
	Default cVersion  := "1.000"

	lRet := .F.

	If !Empty(cAliasXML) .and. cVersion == "1.006"
		If (cAliasXML)->ED_IRRFCAR=="S" .OR. (cAliasXML)->ED_INSSCAR=="S"
			lRet := .T.
		Endif
	Endif

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} F404BasIRC
Retorna base do IR Carreteiro

@author fabio.casagrande
@since 11/01/2021

@param cAliasXML, characters, alias para a tabela temporaria
@param cVersion, characters, versao do adapter
@return nBaseIrf, numeric, valor base do IR
/*/
//-------------------------------------------------------------------------------
Static Function F404BasIRC(cAliasXML As Character, cVersion As Character) As Numeric

	Local lRet     As Logical
	Local lDedInss As Logical
	Local nBaseIrf As Numeric

	Default cAliasXML := ""
	Default cVersion  := "1.000"

	lRet     := .F.
	lDedInss := SuperGetMv("MV_INSIRF",.F., "2") == "1"
	nBaseIrf := 0

	If !Empty(cAliasXML) .and. cVersion == "1.006"
		//Caso MV_INSIRF=1 e origem "MATA", recompoe o E2_BASEIR c/ o INSS
		If lDedInss .and. Alltrim((cAliasXML)->E2_ORIGEM) $ "MATA" 
			nBaseIrf := (cAliasXML)->E2_BASEIRF-(cAliasXML)->E2_INSS
		Else 
			nBaseIrf := (cAliasXML)->E2_BASEIRF
		Endif
	Endif

Return nBaseIrf

//-------------------------------------------------------------------------------
/*/{Protheus.doc} F404SestSenat
Retorna valores desmembrados de SEST e SENAT, que é gravado aglutinado
no campo E2_SEST

@author fabio.casagrande
@since 11/01/2021

@param cAliasXML, characters, alias para a tabela temporaria
@param cVersion, characters, versao do adapter
@return aRet, Vetor com o valor de SEST e SENAT
@sample aRet[1] = Valor do SEST
		aRet[2] = Valor do SENAT
/*/
//-------------------------------------------------------------------------------
Static Function F404SestSenat(cAliasXML As Character, cVersion As Character) As Array

	Local nAliqSest  As Numeric
	Local nAliqSenat As Numeric
	Local nSest      As Numeric
	Local nSenat     As Numeric

	Default cAliasXML := ""
	Default cVersion  := "1.000"

	nSest     := 0
	nSenat    := 0

	If !Empty(cAliasXML) .and. cVersion == "1.006"
		If (cAliasXML)->E2_SEST > 0 .and. (cAliasXML)->ED_PERCSES > 0
			nAliqSest  := SuperGetMv("MV_ALSEST"  ,.F., 1.5)
			nAliqSenat := SuperGetMv("MV_ALSENAT" ,.F., 1)
			nSest      := (nAliqSest  * (cAliasXML)->E2_SEST) / (cAliasXML)->ED_PERCSES
			nSenat     := (nAliqSenat * (cAliasXML)->E2_SEST) / (cAliasXML)->ED_PERCSES
		Endif
	Endif

Return {nSest, nSenat}

/*/{Protheus.doc} F404MultVinc
Função para retornar as informações de retenção de INSS do fornecedor referente 
a outras empresas, através do cadastro de prévia de INSS (FINA027)

@author fabio.casagrande
@since 12/02/2021
@version 1.0
@type function

@param cCodForn, char, Código do fornecedor
@param cLojaForn, char, Loja do fornecedor
@param cIndMV, char, Indicador de Multiplos Vinculos
@return aRet, Vetor com as informações de INSS retido em outras empresas
@sample aRet[1] = tpInsc
		aRet[2] = nrInsc
		aRet[3] = vlrRemunOE
		aRet[4] = vlrRecolhidoOE
/*/
Static Function F404MultVinc(cAliasXML As Character, cVersion As Character) As Array

	Local aRet As Array

	Default cAliasXML := ""
	Default cVersion  := "1.000"

	aRet   := {}
	
	If cVersion == "1.006" .and. _lDicInss .and. !Empty((cAliasXML)->FJW_FORNEC)
		DbSelectArea("FLX")
		FLX->( dbSetOrder(1) ) //FLX_FILIAL+FLX_FORNEC+FLX_LOJA+FLX_ITEM                                                                                                                         
		FLX->( MsSeek( FWxFilial("FLX") + (cAliasXML)->E2_FORNECE + (cAliasXML)->E2_LOJA ) )

		While FLX->(!Eof()) .AND. (cAliasXML)->E2_FORNECE == FLX->FLX_FORNEC .AND. (cAliasXML)->E2_LOJA == FLX->FLX_LOJA
			IF STOD((cAliasXML)->E2_EMISSAO) >= FLX->FLX_DTINI .AND. STOD((cAliasXML)->E2_EMISSAO) <= FLX->FLX_DTFIM
				aAdd( aRet, {IIF(_lFLXTPREC,FLX->FLX_TPREC,''),;   //MultipleEmploymentIndicator
							AllTrim(FLX->FLX_CNPJ),; 			   //OtherEmploymentId
							IIF(_lFLXCATEFD,FLX->FLX_CATEFD,''),;  //OtherEmploymentCategory
							cValToChar(ABS(FLX->FLX_BASE))} )	   //OtherEmploymentINSSBasis		
			EndIf
			FLX->(dbSkip())
		Enddo
	EndIf

Return aRet
