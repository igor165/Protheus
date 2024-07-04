#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TafxSpd0

Realiza a Geracao do Bloco 0 do Sped Fiscal

@Param	aWizard	->	 Wizard de geracao do Arquivo
		cFilSel	->	Variavel com as Filiais escolhidas pelo Usuario
		lConv115   -> Indica se faz parte do convenio 115 do ICMS
		cPerfilSPD -> Indica qual o perfil do contribuinte
		cTabSped   -> Alias da tabela de geração das informações
		cJobAux    -> Nome da variavel responsavel pelo controle de termino do Bloco - Mult Thread

@Return ( Nil )

@Author Rodrigo Aguilar
@Since 14/02/2013
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TafxSpd0( aWizard, cFilSel, lConv115, cPerfilSPD, cTabSped, cJobAux )

Local cDrive  := ""
Local cPath   := ""
Local cExt    := ""
Local cTxtBlc := ""

Local lSave  := .F.
Local lFound := .T.
Local oError := ErrorBlock( { |Obj| Conout( "Mensagem de Erro: " + Chr(10)+ Obj:Description + Chr(10)+ Obj:ErrorStack ) } )

Default cJobAux := ""

//Tratamento para que caso ocorra Erro durante o processamento não estoure na tela
//é exibida uma mensagem tratada do erro para o usuário final
Begin Sequence

	//Execucao do Bloco 0
	Bloco0( aWizard, cFilSel, lConv115, cTabSped )

Recover
	lFound := .F.

End Sequence

//Tratamento para quando ocorrer erros durante o processamento
ErrorBlock( oError )

If !lFound
	//Status 9 - Indico Que ocorreu Erro no processamento
	PutGlbValue( cJobAux , "9" )
	GlbUnlock()

Else
	//Status 1 - Indico que o bloco foi encerrado corretamente para processamento Mult Thread
	PutGlbValue( cJobAux , "1" )
	GlbUnlock()

	//Altera o Status da tabela de controle para 2, indicando que o bloco foi processado
	xTafCtlObr( "2", "0", aWizard, cFilSel, , "TAFGERCTL", "SPEDFIS" )
EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} Bloco0

Monta a Estrutura de Geracao dos Registros referentes ao BLOCO 0

@Param	aWizard    -> Wizard Com as Parametrizacoes do usuario
		cFilSel    -> String com as Filiais selecionadas pelo usuario
		lConv115   -> Indica se faz parte do convenio 115 do ICMS
		cTabSped   -> Alias da tabela de geração das informações

@Return ( Nil )

@Author Rodrigo Aguilar
@Since 14/02/2013
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function Bloco0( aWizard, cFilSel, lConv115, cTabSped )

Local aRet := Array( 4 )

//Array para que as contas contabeis de excecao ( Que não se enquadra nas querys ) seja gerada ( Exemplo: Registro 0300 )
Local aCtaContab := {}

//Array paa que os centro de custos de excecao ( Que nao se enquadra nas querys ) seja gerado ( Exemplo: Registro 0300 )
Local aCentroCus := {}
Local aAreaSM0	 := SM0->( getArea() )

Private aInfoGrv := {}

//No caso do Sped Fiscal apenas pode ser gerada uma filial por processamento, sendo assim, antes de iniciar a execução dos blocos
//eu seto a filial onde ocorrera o processamento
//cFilAnt := Substr( cFilSel, 2, 2 )

//Array com as informações a serem geradas na tabela compartilhada
//Filial + Data Inicio + Data Final + Bloco + Sequencializador
aInfoGrv := { cFilAnt , DToS( aWizard[1,1] ), DToS( aWizard[1,2] ), "0", 0 }

SM0->(MsSeek (cEmpAnt+cFilAnt, .T.))

//Geração do registro 0000
Reg0000( aWizard )

//Geração do registro 0001
Reg0001( aWizard )

//Geração do registro 0005
Reg0005( aWizard )

//Geração do registro 0015
Reg0015( aWizard )

//Geração do registro 0100
Reg0100( aWizard )

restArea( aAreaSM0 )

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0000

Realiza a Emissao do Registro 0000 - Abertura, Identificacao e Referencias

@Param	aWizard  -> Parametros de Geracao do Sped Fiscal
		cStrTxt  -> String para gravacao do Registro

@Return ( nContReg )

@author Rodrigo Aguilar
@since  02/01/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Reg0000( aWizard )

Local cDelimit := "|"

//Posiciona na tabela C09 para pegar a descrição da UF por extenso
XFunUFID()

cStrTxt := cDelimit
cStrTxt += "0000" + cDelimit 																																					//01 - REG
cStrTxt += Alltrim( aWizard[1][5] ) + cDelimit                                                           															//02 - COD_VER
cStrTxt += SubStr( aWizard[2][1], 1, 1 ) + cDelimit  																														//03 - COD_FIN
cStrTxt += Dt2Caract( aWizard[1][1] )  + cDelimit	   																										//04 - DT_INI
cStrTxt += Dt2Caract( aWizard[1][2] ) + cDelimit				   																							//05 - DT_FIM
cStrTxt += Alltrim( SM0->M0_NOMECOM ) + cDelimit 																															//06 - NOME
cStrTxt += SpedConType( SpedVldIE( Iif( RetPessoa( SM0->M0_CGC ) == "J", SM0->M0_CGC, "") ) ) + cDelimit																//07 - CNPJ
cStrTxt += SpedConType( SpedVldIE( Iif( RetPessoa( SM0->M0_CGC ) == "F", SM0->M0_CGC, "") ) ) + cDelimit																//08 - CPF
cStrTxt += AllTrim(SM0->M0_ESTENT) + cDelimit 																																//09 - UF
cStrTxt += SpedConType( SpedVldIE( SM0->M0_INSC, .F., .F. ) ) + cDelimit																									//10 - IE
cStrTxt += AllTrim(Iif( Upper( SM0->M0_ESTENT ) == "EX", "", Iif( Len( Alltrim( SM0->M0_CODMUN ) ) <= 5, C09->C09_CODIGO, "") + SM0->M0_CODMUN )) + cDelimit 	//11 - COD_MUN
cStrTxt += SPEDConType( SM0->M0_INSCM ) + cDelimit 																															//12 - IM
cStrTxt += SPEDConType( SM0->M0_INS_SUF ) + cDelimit 																														//13 - SUFRAMA
cStrTxt += SubStr( aWizard[2][2], 1, 1 ) + cDelimit 																															//14 - IND_PERFIL
cStrTxt += SubStr( aWizard[2][3], 1, 1 ) + cDelimit 																															//15 - IND_ATIV
cStrTxt +=	CRLF

WrtStrTxt( , @cStrTxt, .T., aInfoGrv, "0000" )

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0001

Realiza a Emissao do Registro 0001 - Abertura do Bloco 0

@Param	aWizard  -> Parametros de Geracao do Sped Fiscal
		cStrTxt  -> String para gravacao do Registro

@Return ( nContReg )

@author Rodrigo Aguilar
@since  15/02/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Reg0001( aWizard )

Local cDelimit := "|"

cStrTxt := cDelimit
cStrTxt += "0001" + cDelimit 		//01 - REG
cStrTxt += "0" 	  + cDelimit 		//02 - IND_MOV
cStrTxt += CRLF

WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "0001" )

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0005

Realiza a Emissao do Registro 0005 - Dados Complementares da Entidade

@Param	aWizard -> Parametros de Geracao do Sped Fiscal
		cStrTxt -> String para gravacao do Registro

@Return ( nContReg )

@author Rodrigo Aguilar
@since  03/01/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Reg0005( aWizard )

Local cDelimit  := "|"
Local cEmail    := ""
Local cNomeFant := ""

Local cTel := SpedConType( SpedVldIE( SM0->M0_TEL ) )
Local cFax := SpedConType( SpedVldIE( SM0->M0_FAX ) )

//Busca pelo Email no Cadastro de complemento de Empresa
C1E->(DbSetOrder(3))
If C1E->( MsSeek( xFilial( "C1E" ) + Alltrim( SM0->M0_CODFIL ) ) )
	cEmail    := C1E->C1E_EMAIL
	cNomeFant := C1E->C1E_NOME
EndIf

//Se não estiver preenchido informação na C1E então pega inf. da SM0
If Empty(cNomeFant)
	cNomeFant := SM0->M0_NOME
EndIf

cStrTxt := cDelimit
cStrTxt += "0005" + cDelimit 																										 						//01 - REG
cStrTxt += Alltrim( cNomeFant ) + cDelimit																								 				//02 - FANTASIA
cStrTxt += SpedConType( SM0->M0_CEPENT ) + cDelimit 																				 						//03 - CEP
cStrTxt += Alltrim( SpedConType( FisGetEnd( SM0->M0_ENDENT, SM0->M0_ESTENT ) [1] ) ) + cDelimit			 									 	//04 - END
cStrTxt += Iif( !Empty( FisGetEnd( SM0->M0_ENDENT, SM0->M0_ESTENT )[2] ), FisGetEnd( SM0->M0_ENDENT, SM0->M0_ESTENT )[3], "SN" ) + cDelimit //05 - NUM
cStrTxt += SpedConType( Iif( !Empty( SM0->M0_COMPENT ), SM0->M0_COMPENT, FisGetEnd( SM0->M0_ENDENT, SM0->M0_ESTENT )[4] ) ) + cDelimit 	 	//06 - COMPL
cStrTxt += SpedConType( SM0->M0_BAIRENT ) + cDelimit																				 						//07 - BAIRRO
cStrTxt += Iif( Len( Alltrim( cTel ) ) == 10, cTel, SubStr( cTel, ( Len ( cTel ) - 9 ), Len( cTel ) ) ) + cDelimit								//08 - FONE
cStrTxt += Iif( Len( Alltrim( cFax ) ) == 10, cFax, SubStr( cFax, ( Len ( cFax ) - 9 ), Len( cFax ) ) ) + cDelimit 								//09 - FAX
cStrTxt += Alltrim( Iif( !Empty(aWizard[2][4]), aWizard[2][4], cEmail ) ) + cDelimit 														 		//10 - EMAIL
cStrTxt +=	CRLF


WrtStrTxt( , @cStrTxt, .T., @aInfoGrv, "0005" )


Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0015

Realiza a Emissao do Registro 0015 - Dados do Contribuinte Substituto

@Param	aWizard -> Parametros de Geracao do Sped Fiscal
		cStrTxt -> String para gravacao do Registro

@Return ( nContReg )

@author Rodrigo Aguilar
@since  08/01/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Reg0015( aWizard )

Local cStrTxt   := ""
Local cDelimit  := "|"
Local cAliasC1E := GetNextAlias()
Local cIEST 	  := ""

A117QrySp0( cAliasC1E, aWizard, "C1E" )

While (cAliasC1E)->(!Eof())
	If (cAliasC1E)->C1F_IEST $ "."
		cIEST := StrTran( (cAliasC1E)->C1F_IEST, ".", "")
	ElseIf (cAliasC1E)->C1F_IEST $ "-"
		cIEST := StrTran( (cAliasC1E)->C1F_IEST, "-", "")
	ElseIf (cAliasC1E)->C1F_IEST $ "/"
		cIEST := StrTran( (cAliasC1E)->C1F_IEST, "/", "")
	ElseIf (cAliasC1E)->C1F_IEST $ "\"
		cIEST := StrTran( (cAliasC1E)->C1F_IEST, "\", "")
	Else
		cIEST := (cAliasC1E)->C1F_IEST
	EndIf
	cStrTxt += cDelimit
	cStrTxt += "0015" + cDelimit                      		//01 - REG
	cStrTxt += (cAliasC1E)->C09_UF + cDelimit        		//02 - UF_ST
	cStrTxt += Alltrim( cIEST ) + cDelimit  					//03 - IE_ST
	cStrTxt +=	CRLF

	(cAliasC1E)->(DbSkip())
EndDo

//Tratamento para que a informação somente seja gerada quando exista
If !Empty( cStrTxt )
	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "0015" )
EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0100

Realiza a Emissao do Registro 0100 - Dados do Contabilista

@Param	aWizard -> Parametros de Geracao do Sped Fiscal
		cStrTxt -> String para gravacao do Registro

@Return ( nContReg )

@author Rodrigo Aguilar
@since 08/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Reg0100( aWizard )

Local cStrTxt  := ""
Local cDelimit := "|"

Local cAliasC2J := "C2J"

Local cIdCont   := Alltrim( aWizard[3][1] )

C09->(DbSetOrder(3))
C07->(DbSetOrder(4))

DbSelectArea(cAliasC2J)
(cAliasC2J)->(DbSetOrder(5))
If (cAliasC2J)->( MsSeek( xFilial( cAliasC2J ) + cIdCont, .T. ) )

	cStrTxt += cDelimit
	cStrTxt += "0100" + cDelimit            		  			  											  //01 - REG
	cStrTxt += Alltrim( (cAliasC2J)->C2J_NOME ) + cDelimit	  	  										  //02 - NOME
	cStrTxt += Alltrim( (cAliasC2J)->C2J_CPF  ) + cDelimit 	  											  //03 - CPF
	cStrTxt += Alltrim( (cAliasC2J)->C2J_CRC  ) + cDelimit 	  											  //04 - CRC
	cStrTxt += Alltrim( (cAliasC2J)->C2J_CNPJ ) + cDelimit	  	  										  //05 - CNPJ
	cStrTxt += Alltrim( (cAliasC2J)->C2J_CEP  ) + cDelimit  	                                     //06 - CEP
	cStrTxt += Alltrim( (cAliasC2J)->C2J_END  ) + cDelimit	  	  									     //07 - ENDERECO
	cStrTxt += Alltrim( (cAliasC2J)->C2J_NUM  ) + cDelimit  	  										  //08 - NUMERO
	cStrTxt += Alltrim( (cAliasC2J)->C2J_COMPL ) + cDelimit     										  //09 - COMPLEMENTO
	cStrTxt += Alltrim( (cAliasC2J)->C2J_BAIRRO ) + cDelimit	  										  //10 - BAIRRO
	cStrTxt += Alltrim( (cAliasC2J)->C2J_DDD    ) + Alltrim( (cAliasC2J)->C2J_FONE   ) + cDelimit	  //11 - FONE
	cStrTxt += Alltrim( (cAliasC2J)->C2J_DDDFAX ) + Alltrim( (cAliasC2J)->C2J_FAX    ) + cDelimit	  //12 - FAX
	cStrTxt += Alltrim( (cAliasC2J)->C2J_EMAIL  ) + cDelimit

	If C09->(MsSeek( xFilial("C09") + (cAliasC2J)->C2J_UF ) )
		If C07->( MsSeek( xFilial("C07") + (cAliasC2J)->C2J_UF + (cAliasC2J)->C2J_CODMUN ) )
			cStrTxt += Alltrim( C09->C09_CODIGO + C07->C07_CODIGO ) + cDelimit	  						  //14 - COD_MUN
		Else
			cStrTxt += "" + cDelimit	  																		  //14 - COD_MUN
		EndIf
	Else
		cStrTxt += "" + cDelimit	  																		  //14 - COD_MUN
	EndIf
	cStrTxt	+=	CRLF

	WrtStrTxt( , @cStrTxt, .T., @aInfoGrv, "0100" )
EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} R0150R0175

Realiza a Emissao dos Registros 0150 - Cadastro do Participante
                    e Registros 0175 - Alteracao do Participante

Serao realizadas querys para TODAS as filiais selecionadas nos parametros de
Emissao do Sped, assim garanto que toda informacao retornada nos blocos de
movimentos estarao contidas no BLOCO 0

@Param		cFilSel   -> Filiais Selecionadas para Emissao
			aWizard   -> Parametros de Geracao do Sped Fiscal
			cStrTxt   -> String para gravacao do Registro

@Return ( { nCont0150, nCont0175 } )

@author Rodrigo Aguilar
@since  03/01/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function R0150R0175( cFilSel, aWizard, cCodPar, aInfoGrv )

Local cDelimit  	:= "|"
Local cDataAlt  	:= ""
Local cNumCamp  	:= ""
Local cCodMun     := ""
Local cStrTxt     := ""
Local cAliasC1H 	:= "C1H"
Local cAliasC1R 	:= "C1R"
Local lInfHist 	:= .T.
Local cPerDe 		:= StrZero(Month(aWizard[1][1]),2) + StrZero(Year(aWizard[1][1]),4)		// Data De digitada na Wizard
Local cPerAte		:= StrZero(Month(aWizard[1][2]),2) + StrZero(Year(aWizard[1][2]),4)		// Data Até digitada na Wizard
Local aDadosPart	:= {}
Local aAreaC1H	:=	C1H->( GetArea() )
Local aAreaC07	:=	C07->( GetArea() )
Local cChave		:= ""																				// Chave para busca das informacoes historicas
Local cAliasTbH	:= "C1I"																			// Alias da tabela que contem historico de alterações
Local aCmpTbHist 	:= {"C1I_DTALT","C1I_NRCAMP","C1I_CTDANT"}
Local aTbCmps		:= {"C1R",3,"C1R_NOME"}
Local cIE			:= ""

// Abre tabela de historico - C1I
dbSelectArea(cAliasTbH)
(cAliasTbH)->(dbSetOrder(1))

//Abre tabela de campos do cadastro - C1R
dbSelectArea(aTbCmps[1])
(aTbCmps[1])->(dbSetOrder(aTbCmps[2])) // Order(3) -> FILIAL + ID

//Setando Indices para Seeks no Processamento
C1R->(DbSetOrder(3))
C08->(DbSetOrder(3))
C09->(DbSetOrder(3))
C07->(DbSetOrder(4))
C1H->(DbSetOrder(1))

If (cAliasC1H)->( MsSeek( xFilial("C1H") + cCodPar ) )

	cCodPar   := (cAliasC1H)->( C1H_CODPAR )
	cChave 	:= (cAliasC1H)->( C1H_FILIAL + C1H_ID )

	//Busca do Código do Municipio
	dbSelectArea("C09")
	C09->(dBSetOrder(3))
	If C09->( MsSeek( xFilial( "C09" ) + (cAliasC1H)->C1H_UF ) )
		dbSelectArea("C07")
		C07->(dBSetOrder(4))
		If C07->( MsSeek( xFilial( "C07" ) + C09->C09_ID + (cAliasC1H)->C1H_CODMUN ) )
			cCodMun := ( Alltrim(C09->C09_CODIGO) + Alltrim(C07->C07_CODIGO) )
		EndIf
	EndIf

	//Se IE for isento, usar em branco. Fonte: http://www1.receita.fazenda.gov.br/sped/faq/Perguntas_Frequentes_versao10_032013.pdf
	If AllTrim((cAliasC1H)->C1H_IE) == "ISENTO" .Or. AllTrim((cAliasC1H)->C1H_IE) == "ISENTA"
		cIE := ""
	Else
		cIE := AllTrim((cAliasC1H)->C1H_IE    )	//IE PART
	EndIf

	// -----------------------------------------------------------------------
	// aDadosPart - Array contendo informaçoes do participante.
	// Carga inicial com as informacoes corrente do cadastro de participantes
	//					[1] - Dado/informacao					[2] - token/nome do campo
	aDadosPart := {	{(cAliasC1H)->C1H_CODPAR    			,"CODPAR" 		},;		//01 - CODIGO PART
						{(cAliasC1H)->C1H_NOME					,"NOME"		},;		//02 - NOME PART
						{(cAliasC1H)->C1H_CODPAI					,"CODPAI"		},;		//03 - PAIS
						{(cAliasC1H)->C1H_CNPJ					,"CNPJ"		},;		//04 - CNPJ PART
						{(cAliasC1H)->C1H_CPF					,"CPF"			},;		//05 - CPF PART
						{ cIE 										,"IE"			},;		//06 - IE PART
						{ cCodMun									,"CODMUN"		},;		//07 - MUNICIPO PART
						{(cAliasC1H)->C1H_SUFRAM					,"SUFRAM"		},;		//08 - SUFRAMA PART
						{(cAliasC1H)->C1H_END 					,"END"			},;		//09 - ENDERECO PART
						{(cAliasC1H)->C1H_NUM 					,"NUM"			},;		//10 - NUM PART
						{(cAliasC1H)->C1H_COMPL					,"COMPL"		},;		//11 - COMPLEMENTO PART
						{(cAliasC1H)->C1H_BAIRRO					,"BAIRRO"		}} 		//12 - BAIRRO PART

	// ---------------------------------------------------------
	// Verifica se deve buscar alteracoes de historico
	If lInfHist
		TAFSpdHist(@aDadosPart,cAliasTbH,cChave,"C1I_FILIAL+C1I_ID",aCmpTbHist,aTbCmps,cPerDe,cPerAte)
	EndIf

	cStrTxt := cDelimit
	cStrTxt += "0150" + cDelimit 	               								//01 - REG

	// ----------------------------------------------------------
	// Gera as informacoes de acordo com o Array aDadosPart
	cStrTxt += Alltrim( aDadosPart[01,01] ) 	+ cDelimit   						//02 - CODIGO PART
	cStrTxt += Alltrim( aDadosPart[02,01]   ) + cDelimit 	    				//03 - NOME PART

	//Busca pelo código do País
	If C08->(MsSeek( xFilial("C08") + aDadosPart[03,01]  ) )
		cStrTxt += Alltrim( C08->C08_CODIGO ) + cDelimit 						//04 - PAIS
	Else
		cStrTxt += "" + cDelimit								 						//04 - PAIS
	EndIf

	cStrTxt += Alltrim( aDadosPart[04,01]  ) + cDelimit      					//05 - CNPJ PART
	cStrTxt += Alltrim( aDadosPart[05,01]  ) + cDelimit      					//06 - CPF PART
	cStrTxt += Alltrim( aDadosPart[06,01]  ) + cDelimit     					//07 - IE PART
	cStrTxt += Alltrim( aDadosPart[07,01]  ) + cDelimit    						//08 - MUNICIPO PART
	cStrTxt += Alltrim( aDadosPart[08,01]  ) + cDelimit    						//09 - SUFRAMA PART
	cStrTxt += Alltrim( aDadosPart[09,01]  ) + cDelimit    						//10 - ENDERECO PART
	cStrTxt += Alltrim( aDadosPart[10,01]  ) + cDelimit    						//11 - NUM PART
	cStrTxt += Alltrim( aDadosPart[11,01]  ) + cDelimit    						//12 - COMPLEMENTO PART
	cStrTxt += Alltrim( aDadosPart[12,01]  ) + cDelimit    						//13 - BAIRRO PART
	cStrTxt	+=	CRLF

	//Verifica se existem alterações para o Participant que está sendo processado
	If C1I->( MsSeek( xFilial( "C1I" ) + (cAliasC1H)->C1H_ID ) )

		//Laço para verificar todas as alterações realizadas
		While C1I->( !Eof() ) .And. C1I->C1I_ID == (cAliasC1H)->C1H_ID

			//Verifico se a alteração esta entre o período de geração do Sped
			If C1I->C1I_DTALT >= aWizard[1][1] .And. C1I->C1I_DTALT <= aWizard[1][2]

				//Busco o código do campo que foi alterado
				If C1R->( MsSeek( xFilial( "C1R" ) + C1I->C1I_NRCAMP ) )

					//Verifico se o campo alterado eh solicitado no Sped
					If C1R->C1R_CODIGO $ ( '003|004|005|006|008|009|011|012|013|015' )
					
						cNumCamp := Right(AllTrim((cAliasC1R)->C1R_CODIGO), 2)
					
						If cNumCamp $ ( '11|12|13' )
							cNumCamp := AllTrim(Str(Val(cNumCamp) - 1))						
						EndIf
						
						If cNumCamp == "15"
							cNumCamp := '13'
						EndIf
				    		    	
				    	cDataAlt := Left(DTOC((cAliasTbH)->C1I_DTALT), 2) + SubStr(DTOC((cAliasTbH)->C1I_DTALT), 4, 2 ) + Right(DTOC((cAliasTbH)->C1I_DTALT), 4 )			    	                  
				    	
				    	cStrTxt += cDelimit					    						
						cStrTxt += "0175" + cDelimit      	 							//01 - REG   
						cStrTxt += cDataAlt + cDelimit        							//02 - DT_ALT
						cStrTxt += cNumCamp + cDelimit        		   		     		//03 - NR_CAMPO
						cStrTxt += Alltrim( (cAliasTbH)->C1I_CTDANT ) + cDelimit	//04 - CONT_ANT
						cStrTxt	+=	CRLF

					EndIf
				EndIf
			EndIf
			C1I->( DbSkip() )
		EndDo
	EndIf
EndIf



If !Empty( cStrTxt )
	cCodPar := "0150" + cCodPar
	WrtStrTxt( , @cStrTxt, .T., aInfoGrv, cCodPar )
EndIf

RestArea( aAreaC1H )
RestArea( aAreaC07 )

Return ( Nil )
//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0190

Realiza a Emissao da Identificacao das Unidades de Medida

@Param		cFilSel   -> Filiais Selecionadas para Emissao
			aWizard   -> Parametros de Geracao do Sped Fiscal
			cStrTxt   -> String para gravacao do Registro

@Return ( nContReg )

@author Rodrigo Aguilar
@since  03/01/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function Reg0190Spd( cFilSel, aWizard, cCodUn, aInfoGrv )

Local cStrTxt   := ""
Local cDelimit  := "|"
Local cAliasC1J := "C1J"
Local aAreaC1J  := C1J->( GetArea() )

(cAliasC1J)->( DbSetOrder( 1 ) )// FILIAL + CODIGO

If (cAliasC1J)->( MsSeek( xFilial( "C1J" ) + cCodUn ) )

	cStrTxt += cDelimit
	cStrTxt += "0190" + cDelimit                  			         						//01 - REG
	cStrTxt += Alltrim( Right( Alltrim( (cAliasC1J)->(C1J_CODIGO) ), 6 )) + cDelimit    //02 - UNID
	cStrTxt += Alltrim( StrTran( (cAliasC1J)->C1J_DESCRI, CRLF, "" ) ) + cDelimit       //03 - DESCRICAO
	cStrTxt	+=	CRLF

	(cAliasC1J)->( DbSkip() )

EndIf

If !Empty( cStrTxt )
	cCodUn := "0190" + cCodUn
	WrtStrTxt( , @cStrTxt, .T., aInfoGrv, cCodUn )
EndIf

RestArea( aAreaC1J )

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} R0200R0205

Realiza a Emissao da Tabela de Identificacao do Item  / Alteracao do Item

@Param		cFilSel   -> Filiais Selecionadas para Emissao
			aWizard   -> Parametros de Geracao do Sped Fiscal
			cStrTxt   -> String para gravacao do Registro
			lConv115  -> Indica se faz parte do convenio 115 do ICMS

@Return ( { nCont0200, nCont0205, nCont0206, nCont0220 } )

@author Rodrigo Aguilar
@since  04/01/2013

@Alter  Demetrio Fontes De Los Rios
@Date    16/08/2014
@version 1.1 - Em Joinville

/*/
//-------------------------------------------------------------------
Function R0200R0205( cFilSel, aWizard, cCodItem, aInfoGrv, cUnNF, cTabSpd )

Local cStrTxt   	:= ""
Local cStrTxt02 	:= ""
Local cStrTxt03 	:= ""
Local cStrTxt04 	:= ""

Local cDataIniA 	:= ""
Local cDataFimA 	:= ""
Local cDataAnt  	:= ""
Local cQuery		:= ""
local cAliasQuery   := GetNextAlias()

Local cAliasC1L 	:= "C1L"

Local cDelimit  	:= "|"

Local lFirst0205	:= .T.

Local lInfHist 	    := .T.
Local cPerDe 		:= StrZero(Month(aWizard[1][1]),2) + StrZero(Year(aWizard[1][1]),4)		// Data De digitada na Wizard
Local cPerAte		:= StrZero(Month(aWizard[1][2]),2) + StrZero(Year(aWizard[1][2]),4)		// Data Até digitada na Wizard
Local aDadosProd	:= {}																				// Array contendo os dados do produto
Local cChave		:= ""																				// Chave para busca das informacoes historicas
Local cAliasTbH	    := "C1M"																			// Alias da tabela que contem historico de alterações
Local aCmpTbHist 	:= {"C1M_DTALT","C1M_NRCAMP","C1M_CTDANT"}
Local aTbCmps		:= {"C2Q",3,"C2Q_NOMCPO"}

Local aAreaC1J 	:= {}
Local cDataDe   	:= DToS( aWizard[1][1] )
Local cDataAte  	:= DToS( aWizard[1][2] )
Local cCest		:= ''

Default cUnNF := ""

// Abre tabela de historico - C1M
dbSelectArea(cAliasTbH)
(cAliasTbH)->(dbSetOrder(1))

//Abre tabela de campos do cadastro - C1R
dbSelectArea(aTbCmps[1])
(aTbCmps[1])->(dbSetOrder(aTbCmps[2])) // Order(3) -> FILIAL + ID

C6X->(DbSetOrder(1))
C1K->(DbSetOrder(2))
C1J->(DbSetOrder(3))

C0A->(DbSetOrder(3))
C2M->(DbSetOrder(3))
C3Z->(DbSetOrder(3))
C0B->(DbSetOrder(3))
C0G->(DbSetOrder(8))



aAreaC1L := (cAliasC1L)->(getArea())
(cAliasC1L)->(DbSetOrder(1))// FILIAL + CODIGO

If (cAliasC1L)->( MsSeek( xFilial("C1L") + cCodItem  ) )

	cCodItem := (cAliasC1L)->(C1L_CODIGO)
	cChave   := (cAliasC1L)->( C1L_FILIAL + C1L_ID )

	cTpItem  := ""
	If C2M->( MsSeek( xFilial("C2M") + (cAliasC1L)->C1L_TIPITE ) )
		cTpItem := C2M->C2M_CODIGO
	EndIf

	cCodNcm  := ""
	cExNcm   := ""
	If C0A->( MsSeek( xFilial("C0A") + (cAliasC1L)->C1L_CODNCM ) )
		cCodNcm := C0A->C0A_CODIGO
		cExNcm  := C0A->C0A_EXNCM
	EndIf

	cCodGen  := ""
	If C3Z->( MsSeek( xFilial("C3Z") + (cAliasC1L)->C1L_CODGEN ) )
		cCodGen := C3Z->C3Z_CODIGO
	EndIf

	cCodSer  := ""
	If C0B->( MsSeek( xFilial("C0B") + (cAliasC1L)->C1L_CODSER ) )
		cCodSer := C0B->C0B_CODIGO
	EndIf

	cCodUn  	:= ""
	cIdUN   	:= ""
	aAreaC1J	:= C1J->(getArea())
	C1J->(DbSetOrder(3))
	If C1J->( MsSeek( xFilial("C1J") + (cAliasC1L)->C1L_UM  ) )
		cCodUn := C1J->C1J_CODIGO
		cIdUN  := 	C1J->C1J_ID
	EndIf
	RestArea( aAreaC1J )

	cCodAnp := ""
	If C0G->( MsSeek( xFilial("C0G") + (cAliasC1L)->C1L_CODANP ) )
		cCodAnp := C0G->C0G_CODIGO
	EndIf

	/*----------------------------------------------------------------
	Busca código CEST
	----------------------------------------------------------------*/
	cCest := ''

	If TAFAlsInDic('T71')

		If !Empty((cAliasC1L)->C1L_IDCEST)

			T71->(DbSetOrder(2))
			T71->(DbGoTop())

			If T71->(MsSeek( xFilial('T71') + (cAliasC1L)->C1L_IDCEST) )
				cCest	:= T71->T71_CODIGO
			EndIf
		EndIf
	EndIf

	// -----------------------------------------------------------------------
	// aDadosPart - Array contendo informaçoes do participante.
	// Carga inicial com as informacoes corrente do cadastro de participantes
	//					[1] - Dado/informacao											[2] - token/nome do campo
	aDadosProd := {	{(cAliasC1L)->C1L_CODIGO											,"CODIGO" 		},;	//01 - COD_ITEM
						{(cAliasC1L)->C1L_DESCRI											,"DESCRI"		},;	//02 - DESCR_ITEM
						{(cAliasC1L)->C1L_CODBAR 										,"CODBAR"		},;	//03 - COD_BARRA
						{"" 																,""				},;	//04 - COD_ANT_ITEM
						{Right(Alltrim( cCodUn ), 6)									,"UM"			},;	//05 - UNID_INV
						{cTpItem 															,"TIPITE"		},;	//06 - TIPO_ITEM
						{cCodNcm															,"CODNCM"		},;	//07 - COD_NCM
						{cExNcm															,""				},;	//08 - EXP_IPI
						{cCodGen 															,"CODGEN"		},;	//09 - COD_GEN
						{cCodSer															,"CODSER"		},;	//10 - COD_LST
						{Val2Str( (cAliasC1L)->C1L_ALQICM, 6, 2 )						,"C1L_ALQICM"	},;	//11 - ALIQ_ICMS	
						{cCest																,"CEST"		}}	//12 - CEST 		


	// ---------------------------------------------------------
	// Verifica se deve buscar alteracoes de historico
	If lInfHist
		TAFSpdHist(@aDadosProd,cAliasTbH,cChave,"C1M_FILIAL+C1M_ID",aCmpTbHist,aTbCmps,cPerDe,cPerAte)
	EndIf


	cStrTxt += cDelimit
	cStrTxt += "0200" + cDelimit   				  	 				//01 - REG
	cStrTxt += Alltrim( aDadosProd[01,01] )	    + cDelimit 			//02 - COD_ITEM
	cStrTxt += Alltrim( aDadosProd[02,01] ) 	+ cDelimit   		//03 - DESCR_ITEM
	cStrTxt += Alltrim( aDadosProd[03,01] ) 	+ cDelimit   		//04 - COD_BARRA
	cStrTxt += cDelimit							                  	//05 - COD_ANT_ITEM
	cStrTxt += xGerBlc0( "0190", Alltrim( aDadosProd[05,01] ), cFilSel, aWizard, cTabSpd ) 	+ cDelimit   	   	//06 - UNID_INV
	cStrTxt += Alltrim( aDadosProd[06,01] ) 	+ cDelimit   		//07 - TIPO_ITEM
	cStrTxt += Alltrim( aDadosProd[07,01] ) 	+ cDelimit   		//08 - COD_NCM
	cStrTxt += Alltrim( aDadosProd[08,01]  ) 	+ cDelimit   		//09 - EXP_IPI
	cStrTxt += Alltrim( aDadosProd[09,01] ) 	+ cDelimit   		//10 - COD_GEN

	cCod_LST := Alltrim( aDadosProd[10,01])

	If !Empty(cCod_LST)
		cCod_LST := SubStr(cCod_LST,1,2) + "." + SubStr(cCod_LST,3,2)
	EndIf

	cStrTxt += cCod_LST  	     + cDelimit   		    			//11 - COD_LST
	cStrTxt += aDadosProd[11,01] + cDelimit   					    //12 - ALIQ_ICMS
	cStrTxt += aDadosProd[12,01] + cDelimit   					    //13 - CEST	
	cStrTxt	+=	CRLF

	If 	!Empty( cCodAnp )

		cStrTxt02 += cDelimit
		cStrTxt02 += "0206" + cDelimit   			  //01 - REG
		cStrTxt02 += Alltrim( cCodAnp ) + cDelimit    //02 - COD_COMB
		cStrTxt02 +=	CRLF

	EndIf


	/*----------------------------------------------------------
			Geração do Registro 0210 - Só é gerado se
		TIPO_ITEM do Registro 0200 for igual a 03 ou 04
	----------------------------------------------------------*/
	If(aWizard[7][2] == "0 - Sim")

	If TAFAlsInDic( "T25" ) .And. TAFAlsInDic( "LEZ" ) .And. Alltrim( aDadosProd[06,01] ) $ '03|04' .And. (Stod(cDataDe) >= CTOD("01/12/2016") .OR. Stod(cDataAte) >= CTOD("01/12/2016"))

		//Query executada para pegar o ID da tabela de produto conforme a data
		cQuery += " SELECT LEZ_FILIAL, LEZ_ID "
		cQuery += " FROM " + RetSqlName('LEZ') +" LEZ "
		cQuery += " WHERE LEZ_CODPRO = '" + (cAliasC1L)->C1L_ID + "' "
		cQuery += " AND LEZ_DTINI >= '" + cDataDe + "' "
		If !Empty(cPerAte)
			cQuery += " AND LEZ_DTFIN <= '"   + cDataAte + "' "
		EndIf

		cQuery += " AND LEZ.D_E_L_E_T_ = ' ' "

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQuery, .F., .T. )

		If !Empty((cAliasQuery)->LEZ_ID)

			DbselectArea("T25")
			("T25")->( DbSetOrder( 1 ) )
			If ("T25")->( DbSeek ( xFilial("T25")+(cAliasQuery)->LEZ_ID ) )

				//Laço para geração dos registros filhos

				While T25->(!Eof()) .And. (Alltrim(xFilial("T25")+T25->T25_ID) == Alltrim((cAliasQuery)->LEZ_FILIAL+(cAliasQuery)->LEZ_ID))

					cCdItem := POSICIONE("C1L",3, xFilial("C1L")+T25->T25_IDINSU ,"C1L_CODIGO")
					cStrTxt04 += cDelimit
					cStrTxt04 += "0210"                             + cDelimit
					cStrTxt04 += AllTrim(cCdItem )                  + cDelimit
					cStrTxt04 += Val2Str(T25->T25_QTDITE, 16, 6 ) 	+ cDelimit
					cStrTxt04 += Val2Str(T25->T25_PERDA, 8, 4 ) 	+ cDelimit
					cStrTxt04 += CRLF

					T25->( dbSkip() )
				EndDo
				EndIf
			EndIf
		EndIf
	EndIf

	//A UM do Item da Nota tem que ser diferente da UM cadastrada no produto para a geração do registro 0220
	If !Empty(cUnNF) .AND. Alltrim(cUnNF) <> AllTrim(cCodUN) .And. C1K->( MsSeek( xFilial("C1K") + cIdUN ) )
	   If C6X->( MsSeek( xFilial("C6X") + C1K->C1K_ID ) )
	   		While C6X->(!Eof()) .And. C6X->( C6X_FILIAL + C6X_ID ) == xFilial("C6X") + C1K->C1K_ID

	   			cFatConv:= Posicione("C1J",3,xFilial("C1J")+C6X->C6X_UNCONV,"C1J_CODIGO")

				cStrTxt03 += cDelimit
				cStrTxt03 += "0220" + cDelimit                                  //01 - REG
				cStrTxt03 += Alltrim( cFatConv ) + cDelimit   					 //02 - UNID_CONV
				xGerBlc0( "0190", Alltrim( cFatConv ), cFilSel, aWizard, cTabSpd )
				cStrTxt03 += Val2Str( C6X->C6X_FATCON, 16, 2 ) +  cDelimit      //03 - FAT_CONV
				cStrTxt03 += CRLF
		   		C6X->(DbSkip())
	   		EndDo
	   EndIf
	EndIf

	lFirst0205 := .T.

	C1M->(DbSetOrder(1))
	C2Q->(DbSetOrder(3))
	If C1M->( MsSeek( xFilial("C1M") + (cAliasC1L)->C1L_ID ) )

		While C1M->( !Eof() ) .And. C1M->( C1M_FILIAL + C1M_ID ) == xFilial("C1M") + (cAliasC1L)->C1L_ID;
				  .And. (C1M->( C1M_DTALT ) >= aWizard[1][1] .And. C1M->( C1M_DTALT ) < aWizard[1][2])

			//Tratamento para que as Datas de Utilizacao das alteracoes sejam gravadas,
			//a Query retorna por ordem de Data de Alteracao, assim sempre se assume para o
			//primeiro registro a Data de Inclusao como Data Inicial do registro
	       If lFirst0205
		        cDataIniA  := Right( DToS( (cAliasC1L)->C1L_DTINCL ), 2 ) + SubStr( DToS( (cAliasC1L)->C1L_DTINCL ), 5, 2 ) + Left( DToS( (cAliasC1L)->C1L_DTINCL ), 4 )
		        cDataFimA  := Right( DToS( C1M->C1M_DTALT ), 2 ) + SubStr( DToS( C1M->C1M_DTALT ), 5, 2 ) + Left( DToS( C1M->C1M_DTALT ), 4 )
		        cDataAnt   := cDataFimA
		        lFirst0205 := .F.
	       Else
		        cDataIniA := cDataAnt
		        cDataFimA := Right( DToS( C1M->C1M_DTALT ), 2 ) + SubStr( DToS( C1M->C1M_DTALT ), 5, 2 ) + Left( DToS( C1M->C1M_DTALT ), 4 )
		        cDataAnt  := cDataFimA
	       EndIf

			If C2Q->( MsSeek( xFilial("C2Q") + C1M->C1M_NRCAMP ) )

				//Alteracao do Codigo
		    	If C2Q->C2Q_NUMCPO == "01"

					cStrTxt += cDelimit
					cStrTxt += "0205" + cDelimit      				    		  //01 - REG
					cStrTxt += "" + cDelimit  								//02 - DESCR_ANT_ITEM
					cStrTxt += cDataIniA + cDelimit          					 //03 - DT_INI
					cStrTxt += cDataFimA + cDelimit        						//04 - DT_FIM
					cStrTxt += Alltrim( C1M->C1M_CTDANT ) + cDelimit   //05 - COD_ANT_ITEM
					cStrTxt	+=	CRLF

				//Alteracao da Descricao
				ElseIf C2Q->C2Q_NUMCPO == "02"

					cStrTxt += cDelimit
					cStrTxt += "0205" + cDelimit    				   //01 - REG
					cStrTxt += Alltrim( C1M->C1M_CTDANT ) + cDelimit   //02 - DESCR_ANT_ITEM
					cStrTxt += cDataIniA + cDelimit         		   //03 - DT_INI
					cStrTxt += cDataFimA + cDelimit       		  	   //04 - DT_FIM
					cStrTxt += "" + cDelimit    					   //05 - COD_ANT_ITEM
					cStrTxt += CRLF

				EndIf
			EndIf
			C1M->( DbSkip() )
		EndDo
	EndIf

	If !Empty( cStrTxt )
		cStrTxt	+= ( cStrTxt02 + cStrTxt03 + cStrTxt04	)

		cCodItem := "0200" + cCodItem
		WrtStrTxt( , @cStrTxt, .T., aInfoGrv, cCodItem )

		cStrTxt02 := ""
		cStrTxt03 := ""
		cStrTxt04 := ""
	EndIf
EndIf

RestArea( aAreaC1L )


Return ( Nil )
//-------------------------------------------------------------------
/*/{Protheus.doc} R0300R0305

Realiza a Emissao do Cadastro de Bens ou Componentes do ativo Imobilizado / Informacao Sobre a Utilizacao
Do Bem

@Param		cFilSel   -> Filiais Selecionadas para Emissao
			aWizard   -> Parametros de Geracao do Sped Fiscal
			cStrTxt   -> String para gravacao do Registro
			aCtaContab -> Array que sera populado com as contas contabeis dos Bens que possuem componentes no periodo
			aCentroCus -> Array que sera populado com os centro de custos dos Bens que possuem componentes no periodo

@Return ( { nContReg } )

@author Rodrigo Aguilar
@since  08/01/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function R0300R0305( cFilSel, aWizard, cCodBem, aInfoGrv, cUnNF, cTabSpd )

Local cCodPrc    := ""
Local cStrTxt    := ""
Local cContaCtb  := ""
Local cCusto     := ""
Local cDelimit   := "|"
Local cC2LCodPRN := ""
Local lGerBemPai := .F.

Local aAreaBem  := {}
Local aAreaC2L  := {}
Local aAreaC2La  := {}
Local aAreaC2Lb  := {}
Local aAreaC1O  := {}
Local aAreaC1P  := {}

Local cC2LCODCUS := ""
Local cC2LCODCTA := ""
Local cAliasC2L := "C2L"



aAreaC2La := C2L->(getArea())
C2L->(DbSetOrder(1))

If C2L->( MsSeek( xFilial("C2L") + cCodBem ) )
		lGerBemPai := .F.

		//A tabela C2L possui um campo que faz referencia a propria tabela, indicando
		//o Bem Principal a que deve-se amarrar o Bem/Componente cadastrado, assim a
		//query retorna o ID e nesse momento realizo a Busca do codigo do Bem para geracao
		//do registro.

       cC2LCodPRN := C2L->C2L_CODPRN
		aAreaC2Lb := C2L->(getArea())
		C2L->(DbSetOrder(3))
		If C2L->( MsSeek( xFilial("C2L") + cC2LCodPRN ) )
			cCodPrc := C2L->C2L_CODBEM
			lGerBemPai := .T.
		Else
			cCodPrc := ""
		EndIf

		//Caso seja um componente eu preciso realizar a gravacao do Bem Principal
		If lGerBemPai
			xGerBlc0( "0300", Alltrim(  cCodPrc ), cFilSel, aWizard, cTabSpd)
		EndIf

		//Volto o registro para o Seek Inicial
		RestArea( aAreaC2Lb )

		//Gero os dados do Bem/componente
		cStrTxt := cDelimit
		cStrTxt += "0300" + cDelimit                        					//01 - REG
		cStrTxt += Alltrim( (cAliasC2L)->C2L_CODBEM ) + cDelimit  			//02 - COD_IND_BEM
		cStrTxt += Alltrim( (cAliasC2L)->C2L_IDENTM ) + cDelimit      		//03 - IDENT_MERC
		cStrTxt += Alltrim( (cAliasC2L)->C2L_DESCRI ) + cDelimit     		//04 - DESCR_ITEM
		cStrTxt += Alltrim( cCodPrc ) + cDelimit                     		//05 - COD_PRNC


		cC2LCODCTA := (cAliasC2L)->C2L_CODCTA
		aAreaC1O := C1O->(getArea())
		C1O->(DbSetOrder(3))
		If C1O->( MsSeek( xFilial("C1O") + cC2LCODCTA ) )
			xGerBlc0( "0500",  Alltrim( C1O->C1O_CODIGO ), cFilSel, aWizard, cTabSpd)
			cStrTxt += Alltrim( C1O->C1O_CODIGO ) + cDelimit  							//06 - COD_CTA
		Else
			cStrTxt += "" + cDelimit 					 							//06 - COD_CTA
		EndIf
		RestArea( aAreaC1O )

		cStrTxt += Alltrim( Str( (cAliasC2L)->C2L_NRPARC ) ) + cDelimit    //07 - NR_PARC
		cStrTxt	+= CRLF

		//Apenas gero 0305 para Bens
		If Alltrim( (cAliasC2L)->C2L_IDENTM ) == "1"
			cStrTxt += cDelimit
			cStrTxt += "0305" + cDelimit               			  				  //01 - REG

			cC2LCODCUS := (cAliasC2L)->C2L_CODCUS
			aAreaC1P := C1P->(getArea())
			C1P->(DbSetOrder(3))
			If C1P->( MsSeek( xFilial("C1P") + cC2LCODCUS ) )
				xGerBlc0( "0600",  Alltrim( Left(C1P->C1P_CODCUS, 52) ), cFilSel, aWizard, cTabSpd)
				cStrTxt += Alltrim(  Left(C1P->C1P_CODCUS, 52)) + cDelimit  //02 - COD_CCUS
			Else
				cStrTxt += "" + cDelimit 										 //02 - COD_CCUS
			EndIf
			RestArea( aAreaC1P )

			cStrTxt += Alltrim( (cAliasC2L)->C2L_FUNC ) + cDelimit         	  //03 - FUNC
			cStrTxt += Alltrim( Str( (cAliasC2L)->C2L_VIDAUT ) ) + cDelimit     //04 - VIDA_UTIL
			cStrTxt += CRLF
		EndIf

		If !Empty( cStrTxt )
			cCodBem := "0300" + cCodBem
			WrtStrTxt( , @cStrTxt, .T., aInfoGrv, cCodBem )
		EndIf
EndIf
RestArea( aAreaC2La )

Return ( Nil )
//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0400

Realiza a Emissao da Tabela de Natureza da Operacao / Prestacao

@Param		cFilSel   -> Filiais Selecionadas para Emissao
			aWizard   -> Parametros de Geracao do Sped Fiscal
			cStrTxt   -> String para gravacao do Registro
			lConv115  -> Indica se faz parte do convenio 115 do ICMS

@Return ( nTotReg )

@author Rodrigo Aguilar
@since  08/01/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function Reg0400Spd( cFilSel, aWizard, cNatOper, aInfoGrv )

Local cStrTxt   := ""
Local cDelimit  := "|"
Local cAliasC1N := "C1N"

C1N->( DbSetOrder( 1 ) )


If (cAliasC1N)->( MsSeek( xFilial("C1N") + cNatOper ) )

	cStrTxt += cDelimit
    cStrTxt += "0400" + cDelimit     	 		    			   							//01 - REG
	cStrTxt += Alltrim( (cAliasC1N)->C1N_CODNAT ) + cDelimit    										//02 - COD_NAT
	cStrTxt += Alltrim( StrTran( (cAliasC1N)->C1N_DESNAT, CRLF, "" ) ) + cDelimit   //03 - DESCR_NAT
	cStrTxt	+= CRLF
EndIf


If !Empty( cStrTxt )
	cNatOper := "0400" + cNatOper
	WrtStrTxt( , @cStrTxt, .T., aInfoGrv, cNatOper )
EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0450

Realiza a Emissao da tabela de Informacao Complementar do Documento Fiscal

@Param		cFilSel   -> Filiais Selecionadas para Emissao
			aWizard   -> Parametros de Geracao do Sped Fiscal
			cStrTxt   -> String para gravacao do Registro

@Return ( nTotReg )

@author Rodrigo Aguilar
@since  08/01/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function Reg0450Spd( cFilSel, aWizard, cInfComp, aInfoGrv )

Local cStrTxt   := ""
Local cDelimit  := "|"

Local nTotReg   := 0

Local cAliasC3Q := "C3Q"

(cAliasC3Q)->( dbSetOrder( 1 ) )

If (cAliasC3Q)->( MsSeek( xFilial( "C3Q") + cInfComp ) )

	cStrTxt += cDelimit
	cStrTxt += "0450" + cDelimit	    	 	   					 			 			//01 - REG
	cStrTxt += Alltrim( (cAliasC3Q)->C3Q_CODINF ) + cDelimit 	     					//02 - COD_INF
	cStrTxt += Alltrim( StrTran( (cAliasC3Q)->C3Q_TXTCOM, CRLF, "" ) ) + cDelimit   //03 - TXT
	cStrTxt	+= CRLF

EndIf

If !Empty( cStrTxt )
	cInfComp := "0450" + cInfComp
	WrtStrTxt( , @cStrTxt, .T., aInfoGrv, cInfComp )
EndIf

Return ( nTotReg )
//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0460

Realiza a Emissao da Tabela de Observacao do Lancamento Fiscal

@Param		cFilSel   -> Filiais Selecionadas para Emissao
			aWizard   -> Parametros de Geracao do Sped Fiscal
			cStrTxt   -> String para gravacao do Registro

@Return ( nTotReg )

@author Rodrigo Aguilar
@since  08/01/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function Reg0460Spd( cFilSel, aWizard, cObserv, aInfoGrv )

Local cStrTxt   := ""
Local cDelimit  := "|"

Local cAliasC3R := "C3R"

C3R->( DbSetOrder( 1 ) )
If C3R->( MsSeek( xFilial("C3R") + cObserv ) )

	cStrTxt +=  cDelimit
	cStrTxt +=  "0460" + cDelimit                  				     			 	  //01 - REG
	cStrTxt +=	Alltrim( (cAliasC3R)->C3R_CODIGO ) + cDelimit       					  //02 - COD_OBS
	cStrTxt +=	Alltrim( StrTran( (cAliasC3R)->C3R_DESCRI, CRLF, "" ) ) + cDelimit  //03 - TXT
	cStrTxt	+= CRLF
EndIf

If !Empty( cStrTxt )
	cObserv := "0460" + cObserv
	WrtStrTxt( , @cStrTxt, .T., aInfoGrv, cObserv )
EndIf

Return ( Nil )
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0500

Realiza a Emissao do Plano de Contas Contabeis

@Param		cFilSel   -> Filiais Selecionadas para Emissao
			aWizard   -> Parametros de Geracao do Sped Fiscal
			cStrTxt   -> String para gravacao do Registro
			aCtaContab -> Array com as contas contabeis de excecao para serem geradas no registro 0500

@Return ( nTotReg )

@author Rodrigo Aguilar
@since 08/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function Reg0500Spd( cFilSel, aWizard, cCtaCont, aInfoGrv )

Local cDtAlt    := ""
Local cStrTxt   := ""
Local cDelimit  := "|"
Local cTpConta  := ""
Local cCodNatCC := ""

Local nlI      := 0

Local cAliasC1O     := "C1O"

//Seto a Ordem por FILIAL+ID
C1O->( DbSetOrder(1) )
C2R->( DbSetOrder(3) )

If C1O->( MsSeek( xFilial("C1O") + cCtaCont ) )
	If (cAliasC1O)->C1O_DTALT <= aWizard[1][2]
		cDtAlt   := Right( dToS( (cAliasC1O)->C1O_DTALT ), 2 ) + SubStr( dToS( (cAliasC1O)->C1O_DTALT ), 5, 2 ) + Left( dToS( (cAliasC1O)->C1O_DTALT ), 4 )
		cTpConta := ""

	 	If (AllTrim((cAliasC1O)->C1O_INDCTA) == '0')
	  		cTpConta := 'S'
	    Else
	        cTpConta := 'A'
	    EndIf

	   	If C2R->( MsSeek( xFilial("C2R") +  (cAliasC1O)->C1O_CODNAT ) )
	   		cCodNatCC := C2R->C2R_CODIGO
	   	EndIf

		cStrTxt += cDelimit
		cStrTxt += "0500" + cDelimit                              			//01 - REG
		cStrTxt += Alltrim( cDtAlt ) + cDelimit  								//02 - DT_ALT
		cStrTxt += Alltrim( cCodNatCC ) + cDelimit  							//03 - COD_NAT_CC
		cStrTxt += cTpConta + cDelimit  			   							//04 - IND_CTA
		cStrTxt += Alltrim( (cAliasC1O)->C1O_NIVEL  ) + cDelimit  			//05 - NIVEL
		cStrTxt += Alltrim( (cAliasC1O)->C1O_CODIGO ) + cDelimit  			//06 - COD_CTA
		cStrTxt += Alltrim( (cAliasC1O)->C1O_DESCRI ) + cDelimit  			//07 - NOME_CTA
		cStrTxt += CRLF

		If !Empty( cStrTxt )
			cCtaCont := "0500" + cCtaCont
			WrtStrTxt( , @cStrTxt, .T., aInfoGrv, cCtaCont )
		EndIf
	EndIf
EndIf

Return  ( Nil )
//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0600

Realiza a Emissao do Centro de Custo

@Param		cFilSel   -> Filiais Selecionadas para Emissao
			aWizard   -> Parametros de Geracao do Sped Fiscal
			cStrTxt   -> String para gravacao do Registro
			aCentroCus -> Array com os centros de Custo de excecao para serem gerados

@Return ( nTotReg )

@author Rodrigo Aguilar
@since 08/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function Reg0600Spd( cFilSel, aWizard, cCodCC, aInfoGrv )

Local cStrTxt  := ""
Local cDtAlt   := ""
Local cDelimit := "|"
Local cNotIn   := ""
Local nlI 		 := 0
Local nTotReg  := 0

Local cAliasC1P := "C1P"

C1P->( DbSetOrder(1) )

If (cAliasC1P)->( MsSeek( xFilial("C1P") + cCodCC ) )

	cDtAlt  := Right( dTos( (cAliasC1P)->C1P_DTALT ), 2 ) + SubStr( dToS( (cAliasC1P)->C1P_DTALT ), 5, 2 ) + Left( dToS( (cAliasC1P)->C1P_DTALT ), 4 )

	cStrTxt += cDelimit
	cStrTxt += "0600" + cDelimit                          				     	//01 - REG
	cStrTxt += Alltrim( cDtAlt ) + cDelimit										//02 - DT_ALT
	cStrTxt += Alltrim(  Left((cAliasC1P)->C1P_CODCUS, 52 )) + cDelimit      //03 - COD_CCUS
	cStrTxt += Alltrim( (cAliasC1P)->C1P_CCUS ) + cDelimit	    			   //04 - CCUS
	cStrTxt += CRLF

	If !Empty( cStrTxt )
		cCodCC := "0600" + cCodCC
		WrtStrTxt( , @cStrTxt, .T., aInfoGrv, cCodCC )
	EndIf

EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} A117QrySp0
Realiza a Query Principal para a impressao do Bloco 0 do Sped Fiscal

@Param cAliasQry  -> Alias da Query
        aWizard    -> Parametros do Sped
        cAlias     -> Define Qual sera a Query que devera ser realizada
        cFilSel    -> Filiais Selecionadas pelo Usuasrio para processamento
        lTotReg    -> Informa se Deseja a quantidade de registros
        lConv115   -> Indica se faz parte do convenio 115 do ICMS
        cNotIn     -> Indica as condicoes do Not In das querys

@Return ( Nil )

@author Rodrigo Aguilar
@since  02/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A117QrySp0( cAliasQry, aWizard, cAlias )

Local   cSelect  := ""
Local   cWhere   := ""
Local   cJoin    := ""
Local 	 cOrderBy := ""

//Dados do Contribuinte Substituto
cSelect := " DISTINCT C09.C09_UF, C1F.C1F_IEST "

cJoin := RetSqlName("C1E") + " C1E "
cJoin += " JOIN " + RetSqlName("C1F") + " C1F ON ( C1F.C1F_FILIAL  = '" + xFilial("C1F") + "' AND C1F.C1F_ID = C1E.C1E_ID AND C1F.D_E_L_E_T_ = '' )
cJoin += " JOIN " + RetSqlName("C09") + " C09 ON ( C09.C09_FILIAL  = '" + xFilial("C09") + "' AND C09.C09_ID = C1F.C1F_UFST AND C09.D_E_L_E_T_ = '')

cWhere := " C1E.C1E_FILTAF = '" + cFilAnt + "' AND C1E.D_E_L_E_T_ = '' AND ( C1F.C1F_VALIDA = '' OR C1F.C1F_VALIDA > '" + DTos( dDataBase ) + "')  "

cOrderBy := " C09_UF "

//Execucao da Query
cSelect  := "%" + cSelect  + "%"
cWhere   := "%" + cWhere   + "%"
cJoin    := "%" + cJoin    + "%"
cOrderBy := "%" + cOrderBy + "%"

BeginSql Alias cAliasQry
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cJoin%
	WHERE
		%EXP:cWhere%
	ORDER BY
		%Exp:cOrderBy%
EndSql

DbSelectArea(cAliasQry)
(cAliasQry)->(DbGoTop())

Return ( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFSpdHist

...

@Return aRet = Array de retorno

@author Demetrio Fontes De Los Rios
@since  16/08/2014
@version 1.0 - Em Joinville

/*/
//-------------------------------------------------------------------
Function TAFSpdHist(aDados,cAliasTbH,cChave,cCmpChv,aCmpTbHist,aTbCmps,cPerDe,cPerAte)

Local lRet 	:= .F.
Local nPos 	:= 0
Local cCmpDtAlt

Local cRegPer := ""

(cAliasTbH)->(dbGoTop())
If (cAliasTbH)->(MsSeek(cChave))
	While (cAliasTbH)->(!EOF()) .AND. ( (cAliasTbH)->&(cCmpChv) == cChave )

		dDtAlt := (cAliasTbH)->&(aCmpTbHist[1])
		cRegPer := StrZero(Month(dDtAlt),2) + StrZero(Year(dDtAlt),4)

		If (cRegPer <= cPerAte) .AND. (cRegPer >= cPerDe)

			cChave	:= xFilial(aTbCmps[1]) + (cAliasTbH)->&(aCmpTbHist[2])
			cCampo := AllTrim(Posicione(aTbCmps[1],aTbCmps[2],cChave,aTbCmps[3]))

			If !Empty(cCampo)
				nPos := aScan( aDados , {|x| AllTrim(x[2]) == AllTrim(cCampo)} )
				If nPos > 0
					aDados[nPos][1] :=  Iif( "Campo sem conteúdo / Vazio" == (cAliasTbH)->&(aCmpTbHist[3]), (cAliasTbH)->&(aCmpTbHist[3]), aDados[nPos][1])
					lRet := .T.
				EndIf

			EndIf

		EndIf

		(cAliasTbH)->(dbSkip())
	EndDo

EndIf

Return lRet
