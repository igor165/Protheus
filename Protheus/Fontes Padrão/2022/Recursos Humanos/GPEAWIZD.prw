#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEAWIZD.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOPCONN.CH"

Static cToken	:= ""

/*/{Protheus.doc} function GPEAWIZD
Realiza a configuração de componentes para chamada do TSS
@author  Hugo de Oliveira
@since   13/09/2019
@version 1.0
/*/
Function GPEAWIZD()
	Local cMsgAux	 	:= ""
	Local nAmbeSocial	:= 0
	Local lRet		 	:= .T.
	Local aTxtApre		:= {}
	Local aPaineis		:= {}
	Local aItens		:= {}

	Local cTssDef 	:= "localhost:8081"
	Local cMI01Def 	:= "localhost:8060"
	Local cMI02Def 	:= "rest/WSTSSSETUP/v1"
	Local cAMBEDef 	:= "2"
	Local cMI09Def 	:= "rest/wsesocial/v1"

	Local cAPIMID 		:= SuperGetMv("MV_MID")
	Local cAPIAMBE 		:= ALLTRIM(SuperGetMv("MV_GPEAMBE"))
	Local cAPITSS 		:= ALLTRIM(SuperGetMv("MV_GPEMURL"))
	Local cAPIMI01		:= ALLTRIM(SuperGetMv("MV_APIMI01"))
	Local cAPIMI02		:= ALLTRIM(SuperGetMv("MV_APIMI02"))
	Local cAPIMI03		:= ALLTRIM(SuperGetMv("MV_APIMI03"))
	Local cAPIMI04		:= AllTrim(SuperGetMv("MV_APIMI04"))
	Local cAPIMI05		:= ALLTRIM(SuperGetMv("MV_APIMI05"))
	Local cAPIMI06		:= ALLTRIM(SuperGetMv("MV_APIMI06"))
	Local cAPIMI07		:= ALLTRIM(SuperGetMv("MV_APIMI07"))
	Local cAPIMI08		:= ALLTRIM(SuperGetMv("MV_APIMI08"))
	Local cAPIMI09		:= ALLTRIM(SuperGetMv("MV_APIMI09"))

	Local lMVMID		:= IIF(Empty(cAPIMID),.F.,cAPIMID)
	Local dIniEs	 	:= Stod( AllTrim( GetNewPar( "MV_GPEINIE"  , Space(8) ) ) )
	Local cNomWiz	 	:= "GPEAWIZD" + StrTran( cEmpAnt," ", "") + StrTran( cFilAnt, " ", "")
	Local cAmbeSoc		:= IIF(Empty(cAPIAMBE),cAMBEDef,cAPIAMBE)
	Local cTss			:= IIF(Empty(cAPITSS),cTssDef + Space(100-LEN(cTssDef)),cAPITSS + Space(100-Len(cAPITSS)))
	Local cRest			:= IIF(Empty(cAPIMI01),cMI01Def + Space(100-Len(cMI01Def)),cAPIMI01 + Space(100-Len(cAPIMI01)))
	Local cAPISetup		:= IIF(Empty(cAPIMI02),cMI02Def + Space(100-Len(cMI02Def)),cAPIMI02 + Space(100-Len(cAPIMI02)))
	Local nTpPessoa		:= IIF(Empty(cAPIMI03), 1, Val(cAPIMI03))
	Local cAPIEnvio		:= IIF(Empty(cAPIMI09),cMI09Def + Space(100-Len(cMI09Def)),cAPIMI09 + Space(100-Len(cAPIMI09)))

	If !lMVMID
		Help(" ", 1, OemToAnsi(STR0068),, OemToAnsi(STR0069), 1, 0) // "Parâmetro não encontrado" e "É necessário criar e habilitar o parâmetro do Middleware para utilizar a rotina."
		Return .F.
	Else
		SuperGetMv()
		aAdd( aTxtApre, STR0001 ) // "Rotina de Configuração do Ambiente GPE - Gestão de Pessoal"
		aAdd( aTxtApre, "" )
		aAdd( aTxtApre, STR0002 ) // "Preencha corretamente as informações solicitadas."
		aAdd( aTxtApre, STR0003 ) // "Esta rotina tem como objetivo ajudá-lo na configuração da integração com o Protheus/Middleware com o serviço Totvs Services SOA."

		// Monta o Wizard
		aAdd( aPaineis , {} )
		nPos :=	Len ( aPaineis )
		aAdd( aPaineis[nPos], STR0004 + " - " + STR0005 ) // "Parâmetros de Ambiente - Preencha corretamente as informações solicitadas."
		aAdd( aPaineis[nPos], STR0006 ) // "Informe a URL do servidor Middleware e o ambiente do RET que o mesmo deve se conectar."
		aAdd( aPaineis[nPos], {} )

		aItens 		:= { STR0007, STR0008 } // "1-Produção"	"2-Pré Produção"
		nAmbeSocial	:= aScan( aItens, { |x| Left(x,1) == AllTrim( cAmbeSoc ) } )

		// "CPF/CNPJ"
		aAdd(aPaineis[nPos][3], {1,"CPF/CNPJ",,,,,,});													aAdd(aPaineis[nPos][3], {2,,,1,,,,14,,,,,,,,,,,,,,PadR(cAPIMI04, 14)})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});															aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		// Ambiente eSocial
		aAdd(aPaineis[nPos][3], {1, STR0009 + " e-Social",,,,,,}); 										aAdd(aPaineis[nPos][3], {3,,,,,aClone(aItens),,,,,,,,,,,,,,,,nAmbeSocial})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});															aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		// "Data de Inicio da Empresa no eSocial"
		aAdd(aPaineis[nPos][3], {1, STR0010,,,,,,});													aAdd(aPaineis[nPos][3], {2,,,3,,,,,,,,,,,,,,,,,,dIniEs})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});															aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		// Tipo Pessoa
		aAdd(aPaineis[nPos][3], {1, "Tipo Pessoa",,,,,,}); 												aAdd(aPaineis[nPos][3], {3,,,,, { "1-Pessoa Jurídica","2-Pessoa Física" },,,,,,,,,,,,,,,,nTpPessoa })
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});															aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		// "Nome/Nome Fantasia"
		aAdd(aPaineis[nPos][3], {1, "Nome/Nome Fantasia",,,,,,}); 										aAdd(aPaineis[nPos][3], {2,,,1,,,,50,,,,,,,,,,,,,,PadR(cAPIMI07, 50)})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});															aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		// "Nome da Pessoa/Razão Social da Companhia"
		aAdd(aPaineis[nPos][3], {1, "Nome da Pessoa/Razão Social da Companhia",,,,,,}); 				aAdd(aPaineis[nPos][3], {2,,,1,,,,50,,,,,,,,,,,,,,PadR(cAPIMI06, 50)})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});															aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		// "Unidade Federativa (UF)"
		aAdd(aPaineis[nPos][3], {1, "Unidade Federativa (UF)",,,,,,}); 									aAdd(aPaineis[nPos][3], {2,,,1,,,,2,,,,,,,,,,,,,,PadR(cAPIMI05, 2)})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});															aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		// "Código do Município"
		aAdd(aPaineis[nPos][3], {1, "Código do Município",,,,,,}); 										aAdd(aPaineis[nPos][3], {2,,,1,,,,6,,,,,,,,,,,,,,PadR(cAPIMI08, 6)})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});															aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		// "Endereço e Porta do serviço TSS"
		aAdd(aPaineis[nPos][3], {1, "Endereço e Porta do serviço TSS",,,,,,}); 							aAdd(aPaineis[nPos][3], {2,,,1,,,,100,,,,,,,,,,,,,,cTss})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});															aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		// "Endereço e Porta do serviço REST"
		aAdd(aPaineis[nPos][3], {1, "Endereço e Porta do serviço REST",,,,,,}); 						aAdd(aPaineis[nPos][3], {2,,,1,,,,100,,,,,,,,,,,,,,cRest})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});															aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		// "Serviço, Classe e Versão da API Setup do Middleware"
		aAdd(aPaineis[nPos][3], {1, "Serviço, Classe e Versão da API Setup",,,,,,}); 					aAdd(aPaineis[nPos][3], {2,,,1,,,,100,,,,,,,,,,,,,,cAPISetup})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});															aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		// "Serviço, Classe e Versão da API de Envio do Middleware"
		aAdd(aPaineis[nPos][3], {1, "Serviço, Classe e Versão da API de Envio",,,,,,}); 				aAdd(aPaineis[nPos][3], {2,,,1,,,,100,,,,,,,,,,,,,,cAPIEnvio})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});															aAdd(aPaineis[nPos][3], {0,"",,,,,,})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});															aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		aAdd( aPaineis , {} )
		nPos := Len(aPaineis)
		aAdd(aPaineis[nPos], STR0012 ) // "Preencha corretamente as informações solicitadas."
		aAdd(aPaineis[nPos], STR0013 ) // "Escolha um tipo de certificado e realize a sua configuração."
		aAdd(aPaineis[nPos], {})

		// "Formato Apache (.pem)", "Formato PFX (*.pfx ou *.p12)", "HSM", "KeyStore"
		aItens:= { STR0014, STR0015, STR0016, STR0017 }

		// "Tipo de certificado digital"
		aAdd(aPaineis[nPos][3], {1, STR0018,,,,,,});			aAdd(aPaineis[nPos][3], {3,,,,,aClone(aItens),,,,,,, {"fVldCampo","CFG-CERTIFICADO"}})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});					aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		// "Nome do arquivo do certificado digital"
		aAdd(aPaineis[nPos][3], {1, STR0019,,,,,,});			aAdd(aPaineis[nPos][3], {0,"",,,,,,})
		aAdd(aPaineis[nPos][3], {2,,,1,,,,,,.T.,,,,,,,,.T.});	aAdd(aPaineis[nPos][3], {0,"",,,,,,})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});					aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		// "Informe o nome do arquivo do private key"
		aAdd(aPaineis[nPos][3], {1, STR0020,,,,,,});			aAdd(aPaineis[nPos][3], {0,"",,,,,,})
		aAdd(aPaineis[nPos][3], {2,,,1,,,,,,.T.,,,,,,,,.T.});	aAdd(aPaineis[nPos][3], {0,"",,,,,,})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});					aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		// "Slot do certificado digital"
		aAdd(aPaineis[nPos][3], {1, STR0021,,,,,,});			aAdd(aPaineis[nPos][3], {2,,,1,,,,100})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});					aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		// "Label do certificado digital"
		aAdd(aPaineis[nPos][3], {1, STR0022,,,,,,});			aAdd(aPaineis[nPos][3], {2,,,1,,,,100})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});					aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		// "Senha do arquivo digital"
		aAdd(aPaineis[nPos][3], {1, STR0023,,,,,,});			aAdd(aPaineis[nPos][3], {2,,,1,,,,100,,,,,,,,,,,.T.,.F.})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});					aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		aAdd(aPaineis[nPos][3], {1, STR0024,,,,,,});			aAdd(aPaineis[nPos][3], {2,,,1,,,,100,,,,,,,,,}) // "Caminho e arquivo do módulo HSM"
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});					aAdd(aPaineis[nPos][3], {0,"",,,,,,})
		aAdd(aPaineis[nPos][3], {1, STR0025,,,,,,});			aAdd(aPaineis[nPos][3], {2,,,1,,,,100,,,,,,,,,}) // "ID Hexadecimal"
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});					aAdd(aPaineis[nPos][3], {0,"",,,,,,})
		aAdd(aPaineis[nPos][3], {1, STR0026,,,,,,});			aAdd(aPaineis[nPos][3], {2,,,1,,,,100,,,,,,,,,}) // "Hostname"
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});					aAdd(aPaineis[nPos][3], {0,"",,,,,,})
		aAdd(aPaineis[nPos][3], {1, STR0027,,,,,,});			aAdd(aPaineis[nPos][3], {0,"",,,,,,}) 	// "Issuer"
		aAdd(aPaineis[nPos][3], {2,,,1,,,,250,,,,,,,,,,.T.});	aAdd(aPaineis[nPos][3], {0,"",,,,,,})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});					aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		// "Subject"
		aAdd(aPaineis[nPos][3], {1, STR0028,,,,,,});			aAdd(aPaineis[nPos][3], {0,"",,,,,,})
		aAdd(aPaineis[nPos][3], {2,,,1,,,,250,,,,,,,,,,.T.});	aAdd(aPaineis[nPos][3], {0,"",,,,,,})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});					aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		aItens:= {"1-MY","2-Root","3-Trust","4-CA"}
		aAdd(aPaineis[nPos][3], {1,"Path",,,,,,});				aAdd( aPaineis[nPos][3], {3,,,,,aClone(aItens),,,,,,,})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});					aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		aItens:= {"1-LocalMachine","2-Default"}
		aAdd(aPaineis[nPos][3], {1,"System",,,,,,});			aAdd( aPaineis[nPos][3], {3,,,,,aClone(aItens),,,,,,,})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});					aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		aItens:= {"1-WinStore","2-LinuxStore"}
		aAdd(aPaineis[nPos][3], {1,"Type",,,,,,});				aAdd( aPaineis[nPos][3], {3,,,,,aClone(aItens),,,,,,,})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});					aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		//Obs: Esta validação valida todos os campos no Next da Wizard
		cIniCnpj := Posicione("RJ9", 3, xFilial( "RJ9" ) + PadR( SM0->M0_CODFIL, TamSX3( 'RJ9_FILIAL' )[1] ) + '1', "RJ9_NRINSC" )

		// "CNPJ/CPF Transmissor (Dif. do Empregador)"
		aAdd(aPaineis[nPos][3], {1, STR0029,,,,,,}); 			aAdd(aPaineis[nPos][3], {2,,,1,,,,100,,,,{ "fValWiz",12,{"",""}},,,,,,,,,,cIniCnpj})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,});					aAdd(aPaineis[nPos][3], {0,"",,,,,,})

		aAdd(aPaineis[nPos][3], {1,"",,,,,,})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,})
		aAdd(aPaineis[nPos][3], {0,"",,,,,,})
		aAdd( aPaineis , {} )

		nPos := Len (aPaineis)
		aAdd(aPaineis[nPos], "")
		aAdd(aPaineis[nPos], STR0030)
		aAdd(aPaineis[nPos], {})

		cMsgAux := STR0031 // "Você concluíu com sucesso a configuração da integração do Protheus/Middleware para o Totvs Services SOA."
		aAdd( aPaineis[nPos][3], { 8,,,,,,,,,,,,,,,,,, .F., .F., cMsgAux } )

		lRet :=	fCriaWizd( aTxtApre , aPaineis , cNomWiz,,,, )
	EndIf
Return


/*/{Protheus.doc} function fSetParam
Grava no banco de dados os parâmetros configurados no assistente
@author  Hugo de Oliveira
@since   16/01/2019
@version 1.0
/*/
Static Function fSetParam( aParam )
	Local cConteudo := ""
	Local aWizard 	:= {}
	Local cNomWiz 	:= "GPEAWIZD" + StrTran( cEmpAnt, " ", "") + StrTran( cFilAnt, " ", "" )
	Local nX		:= 1
	Local aRetSM0	:= FWLoadSM0()
	Local nTamFil 	:= FWSizeFilial()
	Local cCodEmp	:= FWCodEmp()
	Local nPos		:= 0
	Local cFil		:= ""
	Local cLayout	:= FWSM0Layout()
	Local lGestao	:= ("E" $ cLayout)

	// Carrega os dados preenchidos no assistente
	fLeProf( cNomWiz, @aWizard )

	//Verifica para qual filial está realizando a configuração do TSS
	If len(aWizard) > 0 .And. len(aRetSM0) > 0
		nPos	:= aScan( aRetSM0, { |x| x[1] + x[18] == cEmpAnt + aWizard[1][1] } )
		If nPos > 0
			cFil := aRetSM0[nPos,2]
		EndIf
	EndIf

	If Len( aWizard ) > 0 .And. Len( aWizard[1] ) > 1
		dbSelectArea( 'SX6' )
		SX6->( dbSetOrder( 1 ) )

		For nX := 1 To LEN( aWizard[1] )
			If aParam[nX] == "MV_GPEAMBE"
				cConteudo := SubStr( aWizard[1][2], 1, 1 )

			ElseIf aParam[nX] == "MV_APIMI03"
				cConteudo := SubStr( aWizard[1][4], 1, 1 )

			ElseIf aParam[nX] == "MV_GPEINIE"
				cConteudo := allTrim( Dtos(aWizard[ 1 , 3 ]) )

			Else
				cConteudo := ALLTRIM( aWizard[1][nX] )
			EndIf

			//Para ambiente com gestão grava os dados preenchidos nos parâmetros conforme a filial selecionada:
			If lGestao .And. !(SX6->(MsSeek(PADR(cCodEmp,nTamFil) + aParam[nX])))
				FWSX6Util():ReplicateParam( aParam[nX] , ( {cFil} ) , .T. , .T. )
			EndIf
			PutMV( aParam[nX], cConteudo)
		Next nX
	EndIf
Return


/*/{Protheus.doc} function fCriaWizd
Grava no banco de dados o valor configurado no assistente
@author  Hugo de Oliveira
@since   13/09/2019
@version 1.0
/*/
Static Function fCriaWizd( aTxtApre, aPaineis, cNomeWizard, cNomeAnt, nTamSay, lBackIni, bFinalExec )
	Local oFont
	Local oWizard
	Local cAuxVar		:=	""
	Local cAlsF3		:=	""
	Local cBLine		:=	""
	Local cSep			:=	""
	Local cTextoMGet 	:=  ""
	Local nInd			:=	0
	Local nInd2			:=	0
	Local nI			:=	0
	Local nObject		:=	0
	Local nLinha		:=	0
	Local nTpColIni		:=	0
	Local nQtdTW		:=	0
	Local nColuna		:=	10
	Local nTamCmpDlg	:=	115
	Local lMarkCB		:=	.F.
	Local lIniWiz		:=	.F.
	Local lFim			:=	.F.
	Local lRet			:=	.T.
	Local lGetRdOnly	:=	.F.
	Local lInitPad		:=	.F.
	Local lPassword		:= 	.F.
	Local aItObj		:=	{}
	Local aButtons		:=	{}
	Local aFunParGet	:=	{}
	Local aVarPaineis	:=	{}
	Local aIniWiz		:=	{}
	Local aHeader		:=	{}
	Local bProcura		:=	{ || }
	Local bValidGet		:=	{ || }
	Local bDblClick		:=	{ || }
	Local bNext			:=	{ || }
	Local bBack			:=	{ || }
	Local bFinish		:=	{ || }
	Local aArea			:=	GetArea()
	Local cAmbeSoc		:= AllTrim( GetNewPar( "MV_GPEAMBE", "" ) ) // Identificação do Ambiente e-Social 1-Produção, 3-Produção restrita-dados fictícios;
	Local cStrIniWiz	:= ""

	Default cNomeAnt	:=	""
	Default nTamSay		:=	0
	Default lBackIni	:=	.F.
	Default bFinalExec	:=	Nil

	lIniWiz := fLeProf( Iif( Empty( cNomeAnt ), cNomeWizard, cNomeAnt ), @aIniWiz )

	Define FONT oFont NAME "Arial" SIZE 00,-11 BOLD

	Define WIZARD oWizard;
		TITLE SubStr( aTxtApre[1], 1, 80 );
		HEADER SubStr( aTxtApre[2], 1, 80 );
		MESSAGE SubStr( aTxtApre[3], 1, 80 );
		TEXT aTxtApre[4];
		NEXT { || .T. };
		FINISH { || .T. }

		For nInd := 1 to Len( aPaineis )
			// Tratamento para casos em que é passada posição 4. Utilizado para Code Block do botão Avançar
			If Len( aPaineis[nInd] ) >= 4 .and. aPaineis[nInd,4] <> Nil
				bNext := &( "{ || Iif( fValWizd( aPaineis, oWizard:nPanel, aVarPaineis, oWizard ), " + aPaineis[nInd,4] + ", .F. ) }" )
			Else
				bNext := &( "{ || fValWizd( aPaineis, oWizard:nPanel, aVarPaineis, oWizard ) }" )
			EndIf

			// Tratamento para casos em que é passada posição 5. Utilizado para Code Block do botão Voltar
			If Len( aPaineis[nInd] ) >= 5 .and. aPaineis[nInd,5] <> Nil
				bBack := &( "{ || Iif( fRetWizd( lBackIni, oWizard ), " + aPaineis[nInd,5] + ", .F. ) }" )
			Else
				bBack := &( "{ || fRetWizd( lBackIni, oWizard ) }" )
			EndIf

			// Tratamento para casos em que é passada posição 6. Utilizado para Code Block do botão Finalizar
			If Len( aPaineis[nInd] ) >= 6 .and. aPaineis[nInd,6] <> Nil
				bFinish := &( "{ || Iif( lFim := fValWizd( aPaineis, oWizard:nPanel, aVarPaineis, oWizard ), " + aPaineis[nInd,6] + ", .F. ) }" )
			Else
				bFinish := &( "{ || lFim := fValWizd( aPaineis, oWizard:nPanel, aVarPaineis, oWizard ) }" )
			EndIf

			CREATE PANEL oWizard;
				HEADER aPaineis[nInd,1];
				MESSAGE aPaineis[nInd,2];
				BACK bBack;
				NEXT bNext;
				FINISH bFinish

			/* Este array aVarPaineis contém as variáveis objetos dos componentes de cada painél. Estrutura:
			{ <conteúdo atribuído ao componente através da dialog>,<variável do objeto componente>}
			Obs: As linhas do array indicam cada componente do respectivo painél.*/

			aAdd( aVarPaineis, {} )

			nLinha	:=	0
			nColuna	:=	10
			nObject	:=	0

			For nInd2 := 1 to Len( aPaineis[nInd,3] )

				// Obs: A Coluna pode mudar de valor caso a posição 18 do aPaineis existir
				//neste caso a coluna terá o valor 10 e o nTamCmpDlg será multiplicado por 2
				If ( nInd2 % 2 == 0 )
					nColuna	:=	nTamCmpDlg + 20
				Else
					nColuna	:=	10
					nLinha		+=	10
				EndIf

				nTpObj		:=	Iif( aPaineis[nInd][3][nInd2][1] == Nil, 0, aPaineis[nInd][3][nInd2][1] )				//Tipo do objeto = 1=SAY, 2=MSGET, 3=COMBOBOX, 4=CHECKBOX, 5=LISTBOX, 6=RADIO, 7=BUTTON	,8=Multi-Get	( OBRIGATORIO )
				cTitObj		:=	Iif( aPaineis[nInd][3][nInd2][2] == Nil, "", OemToAnsi( aPaineis[nInd][3][nInd2][2] ) )	//Título do objeto, quando tiver. Ex: SAY( Caption ), CHECKBOX									( G=OPCIONAL, E=OBRIGATORIO )
				cPctObj		:=	Iif( aPaineis[nInd][3][nInd2][3] == Nil, "", aPaineis[nInd][3][nInd2][3] )				//Picture quando for necessário. Ex: MSGET														( G=OPCIONAL, E=OBRIGATORIO )
				cTpContObj	:=	Iif( aPaineis[nInd][3][nInd2][4] == Nil, "", aPaineis[nInd][3][nInd2][4] )				//Tipo de conteúdo do objeto. Ex: 1=Caracter, 2=Numérico, 3=Data								( G=OPCIONAL, E=OBRIGATORIO )
				nDecObj		:=	Iif( aPaineis[nInd][3][nInd2][5] == Nil, 0 , aPaineis[nInd][3][nInd2][5] )				//Número de casas decimais do objeto MSGET caso seja numérico.									( G=OPCIONAL, E=OBRIGATORIO )
				aItObj		:=	Iif( aPaineis[nInd][3][nInd2][6] == Nil, {}, aPaineis[nInd][3][nInd2][6] )				//Itens de seleção dos objetos. Ex: COMBOBOX, LISTBOX, RADIO									( G=OPCIONAL, E=OBRIGATORIO )
				lMarkCB		:=	Iif( aPaineis[nInd][3][nInd2][7] == Nil, .F., aPaineis[nInd][3][nInd2][7] )				//Opção de seleção do item quando CHECKBOX. Determina se iniciará marcado ou não.			( G=OPCIONAL, E=OBRIGATORIO )
				nNumIntObj	:=	Iif( aPaineis[nInd][3][nInd2][8] == Nil, 0, aPaineis[nInd][3][nInd2][8] )				//Número de casas inteiras quando o conteúdo do objeto MSGET for numérico.					( G=OPCIONAL, E=OBRIGATORIO )
				cIniPad		:=  Iif( Len(aPaineis[nInd][3][nInd2]) < 22 , "", aPaineis[nInd][3][nInd2][22] )

				If ( Len( aPaineis[nInd][3][nInd2] ) >= 9 ) .and. aPaineis[nInd][3][nInd2][9] <> Nil
					lGetRdOnly	:=	aPaineis[nInd][3][nInd2][9][1]
					cTitObj	:=	aPaineis[nInd][3][nInd2][9][2]

					If Len( aPaineis[nInd][3][nInd2][9] ) >= 3
						lInitPad := aPaineis[nInd][3][nInd2][9][3]
					Else
						lInitPad := aPaineis[nInd][3][nInd2][9][1]
					EndIf
				Else
					lGetRdOnly := .F.
				EndIf

				If ( Len( aPaineis[nInd][3][nInd2] ) >= 10 ) .and. aPaineis[nInd][3][nInd2][10] <> Nil
					lGetFile := aPaineis[nInd][3][nInd2][10]
				Else
					lGetFile := .F.
				EndIf

				If ( Len( aPaineis[nInd][3][nInd2] ) >= 11 ) .and. aPaineis[nInd][3][nInd2][11] <> Nil
					cAlsF3 := aPaineis[nInd][3][nInd2][11]
				Else
					cAlsF3 := ""
				EndIf

				//------------------------------------------------------------
				// Tratamento para casos em que é passada posição 13.
				// Utilizado para validar o conteúdo dos campos da wizard.
				// Deverá ser enviado dentro de um array o nome da função que
				// será utilizada para realizar a validação e os parâmetros
				// necessários para processar esta função.

				//------------------------------------------------------------
				If Len( aPaineis[nInd,3,nInd2] ) >= 13 .and. aPaineis[nInd,3,nInd2,13] <> Nil
					aFunParGet	:=	aPaineis[nInd,3,nInd2,13]
					bValidGet	:=	&( "{ || " + aFunParGet[1] + "('" + aFunParGet[2] + "', aVarPaineis[" + AllTrim( Str( nInd ) ) + "," + AllTrim( Str( nInd2 ) ) + "], @aVarPaineis[" + AllTrim( Str( nInd ) ) + "," + AllTrim( Str( nInd2 + 1 ) ) + "], @aVarPaineis[" + AllTrim( Str( nInd ) ) + "," + AllTrim( Str( nInd2 - 1 ) ) + "], @aVarPaineis, aButtons, oWizard ) }" )
				Else
					aFunParGet	:=	{}
					bValidGet	:=	{ || }
				EndIf

				// Tratamento para casos em que é passada posição 14.
				// Utilizado para Header de objetos que necessitam desta funcionalidade
				If Len( aPaineis[nInd,3,nInd2] ) >= 14 .and. aPaineis[nInd,3,nInd2,14] <> Nil
					aHeader := aPaineis[nInd,3,nInd2,14]
				Else
					aHeader := {}
				EndIf

				//----------------------------------------------------
				// Tratamento para casos em que é passada posição 15.
				// Utilizado para tipo da primeira coluna do Browse
				// 1=MARK, 2=LEGEND
				//----------------------------------------------------
				If Len( aPaineis[nInd,3,nInd2] ) >= 15 .and. aPaineis[nInd,3,nInd2,15] <> Nil
					nTpColIni := aPaineis[nInd,3,nInd2,15]
				Else
					nTpColIni := 0
				EndIf

				//-------------------------------------------------------
				// Tratamento para casos em que é passada posição 16.
				// Utilizado para Bloco de Código de Double Click
				// Obs: Opção automática de Marca/Desmarca quando é MARK
				//-------------------------------------------------------
				If Len( aPaineis[nInd,3,nInd2] ) >= 16 .and. aPaineis[nInd,3,nInd2,16] <> Nil
					bDblClick := &( "{ || " + aPaineis[nInd,3,nInd2,16] + " }" )
				Else
					bDblClick := { || }
				EndIf

				//-------------------------------------------------------
				// Tratamento para casos em que é passada posição 17.
				// Utilizado para Bloco de Código de Action
				//-------------------------------------------------------
				If Len( aPaineis[nInd,3,nInd2] ) >= 17 .and. aPaineis[nInd,3,nInd2,17] <> Nil
					bAction := &( "{ || " + aPaineis[nInd,3,nInd2,17] + " }" )
				Else
					bAction := { || }
				EndIf

				//-------------------------------------------------------
				// Tratamento para casos em que é passada posição 18.
				// o objeto ira ocupar o tamnho das 2 colunas e seu tamanho será dobrado
				// para o mesmo ocupar toda a largura da linha na qual está posicionado.
				//-------------------------------------------------------
				If Len( aPaineis[nInd,3,nInd2] ) >= 18 .and. aPaineis[nInd,3,nInd2,18] <> Nil
					If aPaineis[nInd,3,nInd2,18]
						nTamCmpDlg := nTamCmpDlg*2 + 10
						nColuna := 10
					EndIf
				Else
					nTamCmpDlg := 115
				EndIf

				//-------------------------------------------------------
				// Tratamento para casos em que é passada posição 19.
				// Seta a propriedade de Password em um campo TGET
				//-------------------------------------------------------
				If Len( aPaineis[nInd,3,nInd2] ) >= 19 .and. aPaineis[nInd,3,nInd2,19] <> Nil
					lPassword := aPaineis[nInd,3,nInd2,19]
				Else
					lPassword := .F.
				EndIf

				// Posição 20.
				// Determina se deve gravar as Informações do objeto no profile
				// A lógica está na função fGrvWizd
				//-------------------------------------------------------------

				//------------------------------------------------------------
				// Posição 21.
				// Texto padrão para os objetos TMULTIGET
				//-------------------------------------------------------------
				If Len( aPaineis[nInd,3,nInd2] ) >= 21 .and. aPaineis[nInd,3,nInd2,21] <> Nil
					cTextoMGet := aPaineis[nInd,3,nInd2,21]
				Else
					cTextoMGet := ""
				EndIf

				//------------------------------------------------------------
				// Posição 22.
				// Iniciar padrão
				//-------------------------------------------------------------

				//Se já exisitir um .WIZ criado anteriormente carrego-o para exibição e alteração conforme necessidade.
				If lIniWiz .and. ( nTpObj >= 2 .and. nTpObj <= 8 ) //Somente objetos que geram txt

					//Contador somente dos objetos que irão gerar o txt para que se possa recuperá-lo na ordem de exibição dos objetos de cada painél.
					nObject ++

					//No caso de CHECKBOX não posso armazenar "" e sim lógico.
					If nTpObj == 4
						aAdd( aVarPaineis[nInd], { Iif( nTpObj == 4, lMarkCB, "" ), } )
					Else
						aAdd( aVarPaineis[nInd], { "", } )
					EndIf

					//Contém somente o conteúdo que será atribuído em cada objeto. Sem a cláusula { OBJ??? } que é gerado no txt.
					If Len( aIniWiz ) >= nInd
						If Len( aIniWiz[nInd] ) >= nObject
							cStrIniWiz := aIniWiz[nInd,nObject]
						Else
							cStrIniWiz := ""
						EndIf
					Else
						cStrIniWiz := ""
					EndIf

					//Caso venha conteúdo a ser utilizado pela wizard devo desconsiderar os valores de antes e assumir sempre o default passado como parâmetro.
					If lInitPad .and. !Empty( cTitObj ) .and. nTpObj == 2
						cStrIniWiz := cTitObj
					EndIf

				ElseIf lIniWiz .and. ( nTpObj >= 0 .and. nTpObj <= 1 ) //Somente objetos que não geram txt.

					aAdd( aVarPaineis[nInd], { "", } )

				ElseIf !lIniWiz .and. ( nTpObj >= 0 .and. nTpObj <= 8 ) //Caso não tenha um .WIZ anterior, carrego os objetos normalmente e no padrão. ( Branco ou lógicos ).

					If lGetRdOnly .and. !Empty( cTitObj ) .and. nTpObj == 2
						cStrIniWiz := cTitObj
					EndIf

					aAdd( aVarPaineis[nInd], { Iif( nTpObj == 4, lMarkCB, "" ), } )
				EndIf

				If ( nTpObj >= 2 .and. nTpObj <= 8 ) //Somente objetos que geram txt
					If ("GPEAWIZD" $ cNomeWizard) .and. nInd == 1 .and. Len( aPaineis[nInd,3,nInd2]) >= 22 .and. !Empty( aPaineis[nInd,3,nInd2,22] )
						If nTpObj == 3 .And. Len(aItObj) > 0
							cStrIniWiz := aItObj[aPaineis[nInd,3,nInd2,22]]
						Else
							cStrIniWiz := aPaineis[nInd,3,nInd2,22]
						EndIf
					Endif
				Endif

				//Quando o tipo de objeto for SAY, devo tratar somente como informativo, ou seja, somente para exibição na Dialog.
				If nTpObj == 1
					aVarPaineis[nInd][nInd2][2] := TSay():New( nLinha, nColuna, &( "{ |u| Iif( PCount() == 0, aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1], aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1] := u ) }" ), oWizard:oMPanel[nInd + 1],,, .F., .F., .F., .T., CLR_BLUE,, nTamCmpDlg + nTamSay, 10, .F., .F., .F., .F., .F. )
					aVarPaineis[nInd][nInd2][2]:cCaption := cTitObj

				//Quando o tipo de objeto for tipo MSGET devo tratar os casos de terem conteúdo como Caracter, Numérico ou Data.
				ElseIf nTpObj == 2

					If cTpContObj == 1 //Caracter
						If lIniWiz
							aVarPaineis[nInd][nInd2][1] := cStrIniWiz + Iif( nNumIntObj > Len( cStrIniWiz ), Space( nNumIntObj - Len( cStrIniWiz ) ), "" )
						Else
							aVarPaineis[nInd][nInd2][1] := Iif( !Empty( cTitObj ), cTitObj, Space( nNumIntObj ) )
						EndIf

					ElseIf cTpContObj == 2 //Numérico
						If lIniWiz
							aVarPaineis[nInd][nInd2][1] := cStrIniWiz
						ElseIf nDecObj == 0
							aVarPaineis[nInd][nInd2][1] := Val( Replicate( "0", nNumIntObj ) )
						Else
							aVarPaineis[nInd][nInd2][1] := Val( Replicate( "0", nNumIntObj ) + "." + Replicate( "0", nDecObj ) )
						EndIf

					ElseIf cTpContObj == 3 //Data
						If lIniWiz
							aVarPaineis[nInd][nInd2][1] := cStrIniWiz
						Else
							aVarPaineis[nInd][nInd2][1] := CToD( "  /  /  " )
						EndIf
					EndIf

					//Verifica se utiliza validação do conteúdo do campo na Wizard. Executa Bloco de Código conforme função e parâmetros enviados.
					If !Empty( aFunParGet )
						bValidGet := &( "{ || " + aFunParGet[1] + "('" + aFunParGet[2] + "', aVarPaineis[" + Str( nInd ) + "," + Str( nInd2 ) + "], @aVarPaineis[" + Str( nInd ) + "," + Str( nInd2 + 1 ) + "], aVarPaineis[" + Str( nInd ) + "," + Str( nInd2 - 1 ) + "], @aVarPaineis, aButtons, oWizard ) }" )
					EndIf

					aVarPaineis[nInd][nInd2][2] := TGet():New( nLinha, nColuna, &( "{ |u| Iif( PCount() == 0, aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1], aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1] := u ) }" ), oWizard:oMPanel[nInd + 1], nTamCmpDlg - Iif( lGetFile, 30, 0 ), 9, cPctObj, bValidGet,,,,,, .T.,,,,,,, lGetRdOnly,lPassword, cAlsF3 )

					If lGetFile
						cAuxVar	:=	'aVarPaineis[' +  AllTrim( Str( nInd ) ) + '][' + AllTrim( Str( nInd2 ) ) + '][1] := cGetFile( "", OemToAnsi( "Procurar" ),,,, 12345 )'
						bProcura	:=	&( '{ || ' + cAuxVar + ', Iif( Empty( aVarPaineis[' + Str( nInd ) + '][' + Str( nInd2 ) + '][1] ), aVarPaineis[' + AllTrim( Str( nInd ) ) + '][' + AllTrim( Str( nInd2 ) ) + '][1] := Space( 115 ), Nil ) }' )

						//Adiciono o botão e a posição do array da variável do cGetFile
						aAdd( aButtons, { TButton():New( nLinha, nColuna + nTamCmpDlg - 30, OemToAnsi( "..." ), oWizard:oMPanel[nInd + 1], bProcura, 30, 12,,, .F., .T., .F.,, .F.,,, .F. ), { nInd, nInd2, 1 } } )
					EndIf

					If !Empty(cIniPad)
						aVarPaineis[nInd][nInd2][2]:cText :=  cIniPad
					EndIf

				ElseIf nTpObj == 3 //Quando o objeto for do tipo COMBOBOX

					If lIniWiz .Or. (("GPEAWIZD" $ cNomeWizard) .And. nInd == 1 .And. Len(aPaineis[nInd,3,nInd2]) >= 22 .And. !Empty(cStrIniWiz))
						aVarPaineis[nInd][nInd2][1] := cStrIniWiz
					EndIf

					//Validação para manipular/alterar a criação do cGetFile
					If Len( aFunParGet ) > 0
						Eval( &( "{ || " + aFunParGet[1] + "('" + aFunParGet[2] + "', aVarPaineis[" + Str( nInd ) + "," + Str( nInd2 ) + "],,, @aVarPaineis, aButtons ) }" ) )
					EndIf

					If cAmbeSoc == "1"
						aVarPaineis[1][4][1] := "1-Produção"
					EndIf

					aVarPaineis[nInd][nInd2][2] := TCombobox():New( nLinha, nColuna, &( "{ |u| Iif( PCount() == 0, aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1], aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1] := u ) }" ), aItObj, nTamCmpDlg, 10, oWizard:oMPanel[nInd + 1],,, bValidGet,,, .T. )

				ElseIf nTpObj == 4 //Quando o objetvo for do tipo CHECKBOX devo converter caso exista um .WIZ para booleano.

					If lIniWiz
						If (valtype( cStrIniWiz ) = "L")
							aVarPaineis[nInd][nInd2][1] := cStrIniWiz
						ElseIf "T" $ cStrIniWiz
							aVarPaineis[nInd][nInd2][1] := .T.
						Else
							aVarPaineis[nInd][nInd2][1] := .F.
						EndIf
					EndIf

					aVarPaineis[nInd][nInd2][2] := TCheckBox():New( nLinha, nColuna, cTitObj, &( "{ |u| Iif( PCount() == 0, aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1], aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1] := u ) }" ), oWizard:oMPanel[nInd + 1], nTamCmpDlg, 10,,,,, CLR_BLUE,,, .T. )

				ElseIf nTpObj == 5

					nQtdTW ++
					&( "aItObj" + AllTrim( Str( nQtdTW ) ) ) := aClone( aItObj )
					cAuxVar := "aItObj" + AllTrim( Str( nQtdTW ) )

					aVarPaineis[nInd][nInd2][2] := TWBrowse():New( nLinha, nColuna, 273, 80,, aHeader,, oWizard:oMPanel[nInd + 1],,,,, bDblClick,,,,,,,,, .T.,,,, .T., .T. )
					aVarPaineis[nInd][nInd2][2]:SetArray( &cAuxVar )

					If !Empty( &cAuxVar )
						cSep := ""
						cBLine := "{ || { "

						For nI := 1 to Len( aHeader )
							If nI == 1
								If nTpColIni == 1
									cBLine += cSep + "Iif( " + cAuxVar + "[aVarPaineis[" + AllTrim( Str( nInd ) ) + "][" + AllTrim( Str( nInd2 ) ) + "][2]:nAt," + AllTrim( Str( nI ) ) + "], LoadBitmap( GetResources(), 'LBTIK' ), LoadBitmap( GetResources(), 'LBNO' ) )"
								//LEGEND - Desenvolver
								ElseIf nTpColIni == 2
									cBLine += cSep
								Else
									cBLine += cSep + cAuxVar + "[aVarPaineis[" + AllTrim( Str( nInd ) ) + "][" + AllTrim( Str( nInd2 ) ) + "][2]:nAt," + AllTrim( Str( nI ) ) + "]"
								EndIf
							Else
								cBLine += cSep + cAuxVar + "[aVarPaineis[" + AllTrim( Str( nInd ) ) + "][" + AllTrim( Str( nInd2 ) ) + "][2]:nAt," + AllTrim( Str( nI ) ) + "]"
							EndIf

							cSep := ","
						Next nI

						cBLine += " } }"
						aVarPaineis[nInd][nInd2][2]:bLine := &( cBLine )
					EndIf

				ElseIf nTpObj == 6
					If lIniWiz
						aVarPaineis[nInd][nInd2][1] := cStrIniWiz
					EndIf

					aVarPaineis[nInd][nInd2][2] := TRadMenu():New( nLinha, nColuna, aItObj, &( "{ |u| Iif( PCount() == 0, aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1], aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1] := u ) }" ), oWizard:oMPanel[nInd + 1],,,,,,,, nTamCmpDlg, 10,,,, .T. )

				ElseIf nTpObj == 7
					aVarPaineis[nInd][nInd2][2] := TButton():New( nLinha - 2, nColuna, cTitObj, oWizard:oMPanel[nInd + 1], bAction, 50, 10,,,, .T. )

				ElseIf nTpObj == 8
					aVarPaineis[nInd][nInd2][1] := cTextoMGet
					aVarPaineis[nInd][nInd2][2] := tMultiGet():New( nLinha, nColuna, &( "{ |u| Iif( PCount() == 0, aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1], aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1] := u ) }" ), oWizard:oMPanel[nInd + 1],280,120,,,,,,.T.,,,,,,.T.)
				EndIf
			Next nInd2

		Next nInd

	Activate WIZARD oWizard Centered

	// lFim indica se o botão fim foi pressionado. .T. = Sim ou .F. = Não.
	If lFim
		fGrvWizd( cNomeWizard, aVarPaineis, aPaineis )

		If bFinalExec <> Nil
			Eval( bFinalExec )
		EndIf
	Else
		lRet := .F.
	EndIf

	RestArea( aArea )

Return( lRet )

/*/{Protheus.doc} function fRetWizd
Fun~]ao que realiza o Retorno para a primeira tela da Wizard criada.
@author  Hugo de Oliveira
@since   17/09/2019
@version 1.0
/*/
Static Function fRetWizd( lBackIni, oWizard )
	If lBackIni
		oWizard:nPanel := 2
	Endif
Return .T.


/*/{Protheus.doc} function fLeProf
Funcao que carrega os profiles do assistente
@author  Hugo de Oliveira
@since   17/09/2019
@version 1.0
/*/
Static Function fLeProf(cNomeWizard, aIniWiz)
	Local 	nJ			:=	0
	Local	nI			:=	0
	Local	nPadR		:=	0
	Local	cTipo		:=	""
	Local	cLinha		:=	""
	Local	lRet		:=	.F.
	Local	cUserName	:= __cUserID
	Local 	cBarra 		:= 	Iif ( IsSrvUnix() , "/" , "\" )

	If !ExistDir( cBarra + "PROFILE" + cBarra )
		Makedir( cBarra + "PROFILE" + cBarra )
	EndIf

	cArqWiz 	:= Upper(Substring(cNomeWizard, 1, 8))
	cNomeWizard	:= cNomeWizard + "_" + cUserName

	If File( cBarra + "PROFILE" + cBarra + Alltrim( cNomeWizard ) + ".PRB" )
		If FT_FUse( cBarra + "PROFILE" + cBarra + Alltrim( cNomeWizard ) + ".PRB" ) <> -1
			FT_FGoTop()

			While ( !FT_FEof() )
				cLinha	:=	FT_FReadLn()

				If ( "PAINEL" $ cLinha )
					aAdd( aIniWiz , {} )
				Else
					aAdd( aIniWiz[Len( aIniWiz )] , cLinha )
				EndIf

				FT_FSkip()
			Enddo

			FT_FUse()

			For nJ := 1 To Len( aIniWiz )
				For nI := 1 To Len( aIniWiz[nJ] )
					If (SubStr(aIniWiz[nJ][nI], 8, 1)==";")
						cTipo	:=	SubStr( aIniWiz[nJ][nI] , 9 , 1 )
						nPadR	:=	Val( SubStr(aIniWiz[nJ][nI] , 11 , 3 ) )
						cLinha	:=	SubStr( aIniWiz[nJ][nI] , 15 , nPadR )

						Do case
							Case cTipo == "L"
								aIniWiz[nJ][nI]	:= 	Iif( cLinha == "F" , .F. , .T. )
							Case cTipo == "D"
								aIniWiz[nJ][nI]	:= 	SToD( cLinha )
							Case cTipo == "N"
								aIniWiz[nJ][nI]	:= 	Val( cLinha )
							OtherWise
								aIniWiz[nJ][nI]	:=	cLinha
						EndCase
					Else
						aIniWiz[nJ][nI]	:=	SubStr( aIniWiz[nJ][nI] , 9 )
					EndIf
				Next nI
			Next nJ
			lRet :=	.T.
		EndIf
	EndIf
Return lRet


/*/{Protheus.doc} function fGrvWizd
Gravacao dos dados inseridos
@author  Hugo de Oliveira
@since   17/09/2019
@version 1.0
/*/
Static Function fGrvWizd( cNomeWizard , aVarPaineis , aPaineis )
	Local	cConteudo		:=	""
	Local	nInd			:=	0
	Local	nInd2			:=	0
	Local	nQtdCasasInt	:=	0
	Local	nQtdCasasDec	:=	0
	Local	nTipObj			:=	0
	Local	nCtdObj			:=	1
	Local	nPadR			:=	0
	Local	lRet			:= .T.
	Local 	lGrvCmp			:= .T.
	Local	aGrava			:= {}

	For nInd := 1 To Len(aVarPaineis)
		nCtdObj	:=	1
		aAdd( aGrava, "{PAINEL"+StrZero (nInd, 3)+"}" )

		For nInd2 := 1 To Len(aVarPaineis[nInd])
			nQtdCasasInt	:=	aPaineis[nInd][3][nInd2][8]
			nQtdCasasDec	:=	aPaineis[nInd][3][nInd2][5]
			nTipObj			:=	aPaineis[nInd][3][nInd2][1]

			//Verifica se deve grava as informações do campo
			If Len( aPaineis[nInd,3,nInd2] ) >= 20 .and. aPaineis[nInd,3,nInd2,20] <> Nil
				lGrvCmp :=  aPaineis[nInd,3,nInd2,20]
			Else
				lGrvCmp := .T.
			EndIf

			If lGrvCmp
				//Tratamento para gravacao de objetos com retorno logigos, tipo CHECKBOX
				If (ValType(aVarPaineis[nInd][nInd2][1])=="L")
					If (aVarPaineis[nInd][nInd2][1])
						cConteudo	:=	"T"
					Else
						cConteudo	:=	"F"
					EndIf

					nPadR	:=	1

				//Tratamento da gravacao do objeto GET com conteudo do tipo DATA
				ElseIf ( ValType(aVarPaineis[nInd][nInd2][1])=="D")
					cConteudo	:=	DToS(aVarPaineis[nInd][nInd2][1])
					nPadR		:=	8

				//tratamento da gravacao do objeto GET com conteudo NUMERICO+CASAS DECIMAIS.
				ElseIf (ValType(aVarPaineis[nInd][nInd2][1])=="N")
					If nTipObj==6
						cConteudo	:=	StrZero(aVarPaineis[nInd][nInd2][1], 3, 0)
						nPadR	:=	3
					ElseIf (nQtdCasasDec==0)
						cConteudo	:=	StrZero(aVarPaineis[nInd][nInd2][1], nQtdCasasInt, 0)
						nPadR	:=	nQtdCasasInt
					Else
						cConteudo	:=	StrZero(aVarPaineis[nInd][nInd2][1], nQtdCasasInt+nQtdCasasDec+1, nQtdCasasDec)	//O 1 eh por causa do ponto Ex: 99.99
						nPadR	:=	nQtdCasasInt+nQtdCasasDec+1
					EndIf
				Else
					//Tratamento do objeto GET para conteudos CARACTER onde devera menter a quantidade de casas na gravacao para que nao
					//	ocasione problema de truncagem no momendo da recuperacao das informacoes para exibicao no CFP.
					If (nQtdCasasInt<>Nil .And. nQtdCasasInt>0)
						cConteudo	:=	SubStr(aVarPaineis[nInd][nInd2][1], 1, nQtdCasasInt)
						nPadR		:=	nQtdCasasInt
					Else
						cConteudo	:=	aVarPaineis[nInd][nInd2][1]
						nPadR		:=	Len(aVarPaineis[nInd][nInd2][1])
					EndIf
				EndIf
			Else
				cConteudo := ""
			EndIf

			If (nTipObj>1)
				cConteudo	:=	"{OBJ"+StrZero (nCtdObj++, 3)+";"+ValType (aVarPaineis[nInd][nInd2][1])+";"+AllTrim (StrZero (nPadR, 3))+"}"+cConteudo
				aAdd( aGrava, cConteudo )
			EndIf
		Next (nInd2)
	Next (nInd)

	If nInd >= 1
		fSaveProf( cNomeWizard, aGrava )
	EndIf

	fSetParam( { "MV_APIMI04","MV_GPEAMBE","MV_GPEINIE","MV_APIMI03","MV_APIMI07","MV_APIMI06","MV_APIMI05","MV_APIMI08","MV_GPEMURL","MV_APIMI01","MV_APIMI02","MV_APIMI09" } )
Return (lRet)


/*/{Protheus.doc} function fSaveProf
Funcao que salva os parametros no profile
@author  Hugo de Oliveira
@since   17/09/2019
@version 1.0
/*/
Static Function fSaveProf( cNomeWizard , aParametros )
	local 	nX			:=	0
	Local 	cWrite		:= 	""
	Local	cBarra		:= 	If( IsSrvUnix () , "/" , "\" )
	Local	lRet		:=	.T.
	Local	cUserName	:= __cUserID

	If !ExistDir( cBarra + "PROFILE" + cBarra )
		Makedir( cBarra + "PROFILE" + cBarra )
	EndIf

	For nX := 1 to Len(aParametros)
		cWrite 	+= 	aParametros[nx]+CRLF
	Next

	cNomeWizard	:=	cNomeWizard + "_" + cUserName
	MemoWrit( cBarra + "PROFILE" + cBarra + Alltrim ( cNomeWizard ) + ".PRB" , cWrite )

Return lRet

/*/{Protheus.doc} function fValWiz
Funcao que valida conteudo digitado nos campos da wizard, conforme parametros enviados.
@author  Hugo de Oliveira
@since   17/09/2019
@version 1.0
/*/
Static Function fValWiz( nVal, aInfo, aObj, aPosterior, aAnterior, aCmpsPan, aAllCmps )
	Local lRet			:=	.T.
	Local nX			:=	0
	Local cContent		:=	""
	Local aCmpsPanel	:= {}
	Local aAuxCmps		:= {}

	Default nVal		:=	0
	Default aInfo		:=	{}
	Default aObj		:=	{}

	If Len( aObj ) > 0
		If ValType( aObj[1] ) == "D"
			cContent := AllTrim( DToS( aObj[1] ) )
		ElseIf ValType( aObj[1] ) == "N"
			cContent := AllTrim( cValToChar( aObj[1] ) )
		Else
			cContent := AllTrim( aObj[1] )
		EndIF
	EndIf

	// Remoção de objetos Null
	aEval(aCmpsPan,{|x| IIf(!Empty(x[2]),aAdd(aCmpsPanel,x),) })

	Do Case
		Case nVal == 12 .Or. nVal == 13
			//Pego somente os Campos, faço isso por que os objetos de Input estão sempre nas posições de numeros pares.
			For nX := 1 To Len(aCmpsPanel)
				If Mod(nX,2) == 0
					aAdd(aAuxCmps,aCmpsPanel[nX])
				EndIf
			Next nX

			If nVal == 12
				// Chamada Antecipada para gravar o CNPJ/CPF antes de executar a

				If lRet .And. Len( aAuxCmps) > 8
					lDocValid 	:= .F.

					If GetVersao(.f.) < '12'
						nPosCNPJ 	:= 9
					Else
						nPosCNPJ 	:= 15
					EndIf

					If Empty(aAuxCmps[nPosCNPJ][1])
						lDocValid := .T.
					Else
						If CGC(aAuxCmps[nPosCNPJ][1] ,,.F.) // Verifica se é um documento valido
							lDocValid := .T.
						Else
							MsgInfo( "CNPJ/CPF do transmissor inválido: "+ aAuxCmps[nPosCNPJ][1])
						EndIf
					EndIf
				EndIf

				if len( aAuxCmps ) > 7 //proteção para quando não existir a posição 8 - ID Hexadecimal HSM
					lRet := fMIDTrsf(aAuxCmps[1][2]:nAt,aAuxCmps[2][1],aAuxCmps[3][1],aAuxCmps[6][1],aAuxCmps[4][1],aAuxCmps[5][1],aAuxCmps[7][1],aAuxCmps[8][1],aAllCmps[1][34][1],aAllCmps[1][38][1],SUBSTR(aAllCmps[1][14][1],1,1),aAllCmps[1][22][1],aAllCmps[1][30][1],aAllCmps[1][26][1],,aAllCmps[1][2][1],aAllCmps[1][18][1],aAllCmps[1][42][1],aAllCmps[2][66][1])
				else
					lRet := fMIDTrsf(aAuxCmps[1][2]:nAt,aAuxCmps[2][1],aAuxCmps[3][1],aAuxCmps[6][1],aAuxCmps[4][1],aAuxCmps[5][1],aAuxCmps[7][1],"",aAllCmps[1][34][1],aAllCmps[1][38][1],SUBSTR(aAllCmps[1][14][1],1,1),aAllCmps[1][22][1],aAllCmps[1][30][1],aAllCmps[1][26][1],,aAllCmps[1][2][1],aAllCmps[1][18][1],aAllCmps[1][42][1])
				endif
			Else
				lRet := fMailSpd(1,aAuxCmps[1][1],aAuxCmps[2][1],aAuxCmps[3][1],aAuxCmps[4][1],aAuxCmps[5][1],aAuxCmps[6][1],aAuxCmps[7][1],aAuxCmps[8][1],.F.)
			EndIf

		OtherWise
			lRet := .F.
	EndCase

Return( lRet )


/*/{Protheus.doc} function fVldCampo
Função para validação dos campos da wizard.
@author  Hugo de Oliveira
@since   17/09/2019
@version 1.0
/*/
Static Function fVldCampo( cTipoVld, aObj, aPosterior, aAnterior, aPainels , aButtons, oWizard )
	Local nX			:= 0
	Local lRet			:= .T.
	Local aCmpsPanel	:= {}
	Local aAuxCmps		:= {}

	Default aObj		:=	{}
	Default aPosterior	:=	{}
	Default aAnterior	:=	{}
	Default aPainels	:=	{}
	Default aButtons	:=	{}
	Default oWizard		:=	Nil

	//Retiro os objetos Null, desta forma ficam no array somente os objetos reais da tela
	aEval(aPainels[2],{|x| IIf(!Empty(x[2]),aAdd(aCmpsPanel,x),) })

	//Pego somente os Campos, faço isso por que os objetos de Input estão sempre nas posições de numeros pares.
	For nX := 1 To Len(aCmpsPanel)
		If Mod(nX,2) == 0
			aAdd(aAuxCmps,aCmpsPanel[nX])
		EndIf
	Next nX

	//Após o Tratamento o array aAuxCmps estará somente com os campos de Input de acordo com suas ordens na tela
	//sendo assim posso determinar quem é quem dentro do Array
	If Len(aPainels) > 2
		If aAuxCmps[1][2]:nAt == 1 //Combo de certificado Digital #.pem
			aAuxCmps[2][2]:bWhen := {||.T.}
			aAuxCmps[3][2]:bWhen := {||.T.}
			aAuxCmps[4][2]:bWhen := {||.F.}
			aAuxCmps[5][2]:bWhen := {||.F.}
			aAuxCmps[6][2]:bWhen := {||.T.}
			aAuxCmps[7][2]:bWhen := {||.F.}

			If len( aAuxCmps ) > 7 //proteção para quando não existir a posição 8 - ID Hexadecimal HSM
				aAuxCmps[8][2]:bWhen := {||.F.}
			EndIf

		ElseIf aAuxCmps[1][2]:nAt == 2 //.pfx ou .p12
			aAuxCmps[2][2]:bWhen := {||.T.}
			aAuxCmps[3][2]:bWhen := {||.F.}
			aAuxCmps[4][2]:bWhen := {||.F.}
			aAuxCmps[5][2]:bWhen := {||.F.}
			aAuxCmps[6][2]:bWhen := {||.T.}
			aAuxCmps[7][2]:bWhen := {||.F.}

			If len( aAuxCmps ) > 7 //proteção para quando não existir a posição 8 - ID Hexadecimal HSM
				aAuxCmps[8][2]:bWhen := {||.F.}
			EndIf
		Else
			aAuxCmps[2][2]:bWhen := {||.F.}
			aAuxCmps[3][2]:bWhen := {||.F.}
			aAuxCmps[4][2]:bWhen := {||.T.}
			aAuxCmps[5][2]:bWhen := {||.T.}
			aAuxCmps[6][2]:bWhen := {||.T.}
			aAuxCmps[7][2]:bWhen := {||.T.}
			if len( aAuxCmps ) > 7 //proteção para quando não existir a posição 8 - ID Hexadecimal HSM
				aAuxCmps[8][2]:bWhen := {||.T.}
			endif
		EndIf
	EndIf

	If !lRet
		MsgInfo( "STR0088" )
	EndIf

Return( lRet )


/*/{Protheus.doc} function fMIDTrsf
Função para validação dos campos da wizard.
@author  Hugo de Oliveira
@since   17/09/2019
@version 1.0
/*/
Static Function fMIDTrsf(nTipo,cCert,cKey,cPassWord,cSlot,cLabel,cModulo,cIdHex,cTssUrl,cRestUrl,cRegType,cCompName,cCounty,cUF,cInsc,cRegNumb,cBranch,cSetup,cGrantNumber)
	Local oWS
	Local cIdEnt   	:= ""
	Local lRetorno 	:= .T.
	Local aParams	:= {}
	Local cRetorno	:= ""

	Default cIdHex 			:= ""
	Default cGrantNumber	:= ""

	// Obtem o codigo da entidade
	If ((!Empty(cCert) .And. !Empty(cKey) .And. !Empty(cPassWord) .And. nTipo == 1) .Or. ;
		(!Empty(cSlot) .And. !Empty(cLabel) .And. !Empty(cPassword) .And. nTipo == 3) .Or. ;
		(!Empty(cSlot) .And. !Empty(cIdHex) .And. !Empty(cPassword) .And. nTipo == 3) .Or. ;
		(!Empty(cCert) .And. !Empty(cPassWord) .And. nTipo == 2))

		If !Empty(cLabel) .and. !Empty(cIdHex)
			Aviso("SPED",STR0049, { STR0047 }, 3) // "Para o tipo de certificado HSM, os campos Label e ID Hexadecimal não podem ser preenchidos simultaneamente."
			lRetorno := .F.
		Else
			aadd(aParams, Alltrim(cCert))
			aadd(aParams, Alltrim(cPassWord))
			aadd(aParams, Alltrim(cTssUrl))
			aadd(aParams, Alltrim(cRestUrl))
			aadd(aParams, Alltrim(cRegType))
			aadd(aParams, Alltrim(cCompName))
			aadd(aParams, Alltrim(cCounty))
			aadd(aParams, Alltrim(cUF))
			aadd(aParams, Alltrim(cInsc))
			aadd(aParams, Alltrim(cRegNumb))
			aadd(aParams, Alltrim(cBranch))
			aadd(aParams, Alltrim(cSetup))
			aadd(aParams, nTipo)
			aadd(aParams, AllTrim(cModulo))
			aadd(aParams, AllTrim(cIdHex))
			aadd(aParams, AllTrim(cLabel))
			aadd(aParams, AllTrim(cSlot))
			aadd(aParams, AllTrim(cGrantNumber))

			cIdEnt :=  fGetIdEnt(aParams, @cRetorno) // Grava Entidade na RJ9

			If Empty(cIdEnt)
				Aviso("SPED", If(Empty(cRetorno), STR0071, cRetorno), { STR0047 }, 3) //"Verifique se os serviços do Rest e TSS informados estão ativos"
				lRetorno := .F.
			EndiF

			If nTipo <> 3 .And. !File(cCert)
				Aviso("SPED", STR0050, { STR0047 }, 3) //"Arquivo não encontrado"
				lRetorno := .F.
			EndIf

			If nTipo == 1 .And. !File(cKey) .And. lRetorno
				Aviso("SPED", STR0050, { STR0047 }, 3) //"Arquivo não encontrado"
				lRetorno := .F.
			EndIf

			If !Empty(cIdEnt) .And. lRetorno .And. nTipo <> 3
				oWs:= WsSpedCfgNFe():New()
				oWs:cUSERTOKEN  	:= "TOTVS"
				oWs:cID_ENT     	:= cIdEnt
				oWs:cCertificate	:= fLoadTxt(cCert)

				If nTipo == 1
					oWs:cPrivateKey  := fLoadTxt(cKey)
				EndIf

				oWs:cPASSWORD   	:= AllTrim(cPassWord)
				oWS:_URL        	:= Alltrim(cTssUrl)+"/SPEDCFGNFe.apw"
				
				If !Empty(cToken)
					oWS:_HEADOUT := {}
					aAdd( oWs:_HEADOUT, "Authorization: " + "Bearer" + " " + cToken )
				EndIf

				If IIF(nTipo==1,oWs:CfgCertificate(),oWs:CfgCertificatePFX())
					Aviso("SPED",IIF(nTipo==1,oWS:cCfgCertificateResult,oWS:cCfgCertificatePFXResult),{ STR0047 },3)
					If STR0070 $ oWS:cCfgCertificatePFXResult //Certificado não registrado
						lRetorno := .F.
					EndIf
				Else
					lRetorno := .F.
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0047},3)
				EndIf
			EndIf

			If !Empty(cIdEnt) .And. lRetorno .And. nTipo == 3
				oWs:= WsSpedCfgNFe():New()
				oWs:cUSERTOKEN   		:= "TOTVS"
				oWs:cID_ENT      	:= cIdEnt
				oWs:cSlot        	:= cSlot
				oWs:cModule      	:= AllTrim(cModulo)
				oWs:cPASSWORD    	:= AllTrim(cPassWord)

				If !Empty( cIdHex )
					oWs:cIDHEX	:= AllTrim(cIdHex)
					oWs:cLabel  := ""
				Else
					oWs:cIDHEX  := ""
					oWs:cLabel  := cLabel
				EndIf
				oWS:_URL        := AllTrim(cTssUrl)+"/SPEDCFGNFe.apw"

				If oWs:CfgHSM()
					Aviso("SPED",oWS:cCfgHSMResult,{STR0047},3)
				Else
					lRetorno := .F.
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0047},3)
				EndIf
			EndIf
		EndIf
	Else
		Aviso("SPED", STR0051, { STR0047 }, 3) //"É Necessário preencher todos os campos que estão habilitados para a correta configuração do certificado."
		lRetorno := .F.
	EndIf
Return(lRetorno)


/*/{Protheus.doc} function fMailSpd
Verifica se a conexao com a Totvs Sped Services pode ser estabelecida - Mail
@author  Hugo de Oliveira
@since   17/09/2019
@version 1.0
/*/
Static Function fMailSpd(nTipo,cServer,cLogin,cSenha,cFrom,lAuth,cAdmin,lSSL,lTLS,lDANFE)
	Local oWS
	Local lOk      := .F.
	Local cIdEnt   := ""
	Local cMsg     := ""
	Local cURL     := ""
	Local lRetorno := .T.

	DEFAULT lAuth  := .F.
	DEFAULT cLogin := ""
	DEFAULT lSSL   := .F.
	DEFAULT lTLS   := .F.
	DEFAULT lDANFE := .F.

	If Empty(cUrl)
		If FindFunction("fGetURLMID")
			cURL := PadR(fGetURLMID(),250)
		Else
			cURL := PadR( GetNewPar("MV_GPEMURL","http://"), 250 )
		EndIf
	EndIf

	If ValType(lSSL) == "C"
		If lSSL == "T"
			lSSL := .T.
		Else
			lSSL := .F.
		EndIf
	EndIf

	If ValType(lTLS) == "C"
		If lTLS == "T"
			lTLS := .T.
		Else
			lTLS := .F.
		EndIf
	EndIf

	If ValType(lAuth) == "C"
		If lAuth == "T"
			lAuth := .T.
		Else
			lAuth := .F.
		EndIf
	EndIf

	If ValType(lDANFE) == "C"
		If lDANFE == "T"
			lDANFE := .T.
		Else
			lDANFE := .F.
		EndIf
	EndIf

	// Obtem o codigo da entidade
	If nTipo == 1
		If !lAuth .Or. (!Empty(AllTrim(cLogin)) .And. !Empty(AllTrim(cSenha)))
			cIdEnt := AllTrim(fGetIdEnt())
			If !Empty(AllTrim(cServer))
				If !Empty(cIdEnt)
					oWs:= WsSpedCfgNFe():New()
					oWs:cUSERTOKEN      				:= "TOTVS"
					oWs:cID_ENT         				:= cIdEnt
					oWS:_URL            				:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
					lOk                 				:= oWs:CfgTSSVersao()
					oWs:oWsSMTP                        	:= SPEDCFGNFE_SMTPSERVER():New()
					oWs:oWsSMTP:cMailServer            	:= cServer
					oWS:oWsSMTP:cLoginAccount          	:= cLogin
					oWs:oWsSMTP:cMailPassword          	:= cSenha
					oWs:oWsSMTP:cMailAccount            := cFrom
					oWs:oWsSMTP:lAuthenticationRequered	:= lAuth
					oWs:oWsSMTP:cMailAdmin              := cAdmin

					If lOk
						If oWs:cCfgTSSVersaoResult >= "1.14p"
							oWs:oWsSMTP:lSSL := lSSL
						EndIf

						If oWs:cCfgTSSVersaoResult >= "1.41"
							oWs:OWSSMTP:lTLS 	:= lTLS
						EndIf
					EndIf

					If oWs:CfgSMTPMail()
						Aviso("SPED",oWS:cCfgSMTPMailResult,{STR0047},3)

						// Configuração do envio do DANFE por e-mail
						oWS					:= wsSPEDCfgNFe():new()
						oWS:_URL			:= allTrim( cURL ) + "/SPEDCFGNFe.apw"
						oWS:cUSERTOKEN		:= "TOTVS"
						oWS:cID_ENT			:= cIDEnt
						oWS:cUSACOLAB		:= ""
						oWS:nNUMRETNF		:= 0
						oWS:nAMBIENTE		:= 0
						oWS:nMODALIDADE		:= 0
						oWS:cVERSAONFE		:= ""
						oWS:cVERSAONSE		:= ""
						oWS:cVERSAODPEC		:= ""
						oWS:cVERSAOCTE		:= ""
						oWS:cPASSWORD		:= ""
						oWS:cNFEDISTRDANFE	:= iif( lDANFE, "1", "0" )

						If !fExec(oWS,"CFGPARAMSPED" )
							lRetorno	:= .F.
							Aviso( "SPED", STR0063 , {STR0047}, 3 ) // "Houve um erro ao tentar configurar o envio do DANFE por e-mail."
						endif
					Else
						lRetorno := .F.
						Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0047},3)
					EndIf
				EndIf
			Else
				oWs:= WsSpedCfgNFe():New()
				oWs:cUSERTOKEN	:= "TOTVS"
				oWs:cID_ENT    	:= cIdEnt
				oWS:_URL       	:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
				lOk            	:= oWs:CfgTSSVersao()

				If oWs:GetSMTPMail()
					DEFAULT oWS:oWSGETSMTPMAILRESULT:cMailAdmin := ""
					cMsg := STR0053 + CRLF + CRLF // "O servidor smtp do totvs sped não foi configurado. a configuração atual é:"
					cMsg += STR0054 +": "+oWS:oWSGETSMTPMAILRESULT:cMAILSERVER+CRLF 	// "Servidor Smtp"
					cMsg += STR0055 +": "+oWS:oWSGETSMTPMAILRESULT:cLOGINACCOUNT+CRLF 	// "Login do e-mail"
					cMsg += STR0056 +": "+oWS:oWSGETSMTPMAILRESULT:cMAILPASSWORD+CRLF 	// "Senha"
					cMsg += STR0057 +": "+oWS:oWSGETSMTPMAILRESULT:cMAILACCOUNT+CRLF 	// "Conta de e-mail"
					cMsg += STR0058 +": "+IIF(oWS:oWSGETSMTPMAILRESULT:lAUTHENTICATIONREQUERED,".T.",".F.")+CRLF // "Autenticação"
					cMsg += STR0059 +": "+oWS:oWSGETSMTPMAILRESULT:cMailAdmin+CRLF 	// "E-mail de notificação"

					If lOk
						If oWs:cCfgTSSVersaoResult >= "1.14p"
							cMsg += STR0060 + ": "+Iif(oWs:oWSGETSMTPMAILRESULT:lSSL, ".T.", ".F.")+CRLF // "Utilizar conexão segura?"
						EndIf

						If oWs:cCfgTSSVersaoResult >= "1.41"
							cMsg += STR0061 + ": "+Iif(oWs:oWSGETSMTPMAILRESULT:lTLS, ".T.", ".F.")+CRLF // "Utilizar conexão segura TLS?"
						EndIf
					EndIf
					Aviso("SPED", cMsg, { STR0047 }, 3)
				Else
					Aviso("SPED", IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)), { STR0062 }, 3) // "neste caso, os recolhimentos dos tributos apurados e todas as obrigações acessórias espelhos deste período de movimento."
				EndIf
			EndIf
		EndIf
	Else
		cIdEnt := AllTrim(fGetIdEnt())
		If !Empty(AllTrim(cServer))
			If !Empty(cIdEnt)
				oWs:= WsSpedCfgNFe():New()
				oWs:cUSERTOKEN      			:= "TOTVS"
				oWs:cID_ENT         		:= cIdEnt
				oWS:_URL            		:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
				lOk                 		:= oWs:CfgTSSVersao()
				oWs:oWsPOP                	:= SPEDCFGNFE_POPSERVER():New()
				oWs:oWsPOP:cMailServer     	:= cServer
				oWs:oWsPOP:cLoginAccount  	:= cLogin
				oWs:oWsPOP:cMailPassword  	:= cSenha
				If lOk
					If oWs:cCfgTSSVersaoResult >= "1.14p"
						oWs:oWsPOP:lSSL := lSSL
					EndIf
				EndIf
				If oWs:CfgPOPMail()
					Aviso("SPED",oWS:cCfgPOPMailResult,{STR0047},3)
				Else
					lRetorno := .F.
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0047},3)
				EndIf
			EndIf
		Else
			oWs:= WsSpedCfgNFe():New()
			oWs:cUSERTOKEN		:= "TOTVS"
			oWs:cID_ENT        	:= cIdEnt
			oWS:_URL           	:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
			lOk            		:= oWs:CfgTSSVersao()

			If oWs:GetPOPMail()
				cMsg := STR0064 +CRLF+CRLF // "O servidor POP do Totvs Sped não foi configurado. A configuração atual é:"
				cMsg += STR0065 +": "+oWS:oWSGETPOPMAILRESULT:cMAILSERVER+CRLF 	// "Servidor POP"
				cMsg += STR0066 +": "+oWS:oWSGETPOPMAILRESULT:cLOGINACCOUNT+CRLF 	// "Login do e-mail"
				cMsg += STR0067 +": "+oWS:oWSGETPOPMAILRESULT:cMAILPASSWORD+CRLF 	// "Senha"

				If lOk
					If oWs:cCfgTSSVersaoResult >= "1.14p"
						cMsg += STR0060 +": "+Iif(oWs:oWSGETPOPMAILRESULT:lSSL, ".T.", ".F.")+CRLF // "Utilizar conexão segura?"
					EndIf
				EndIf

				Aviso("SPED", cMsg, { STR0047 }, 3)
			Else
				Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)), { STR0047 }, 3)
			EndIf
		EndIf
	EndIf
Return(lRetorno)


/*/{Protheus.doc} function fExec
Executa um método validando seu retorno.
@author  Hugo de Oliveira
@since   17/09/2019
@version 1.0
/*/
Static Function fExec( oWS, cMetodo )
	Local bBloco	:= {||}
	Local lRetorno	:= .F.
	Private oWS2

	DEFAULT oWS		:= NIL
	DEFAULT cMetodo	:= ""

	If ( ValType(oWS) <> "U" .And. !Empty(cMetodo) )
		oWS2 := oWS
		If ( Type("oWS2") <> "U" )
			bBloco 	:= &("{|| oWS2:"+cMetodo+"() }")
			lRetorno:= eval(bBloco)
			If ( lRetorno == NIL )
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
Return lRetorno


/*/{Protheus.doc} function fGetURLMID
Retorna a URL do Middleware
@author  Hugo de Oliveira
@since   17/09/2019
@version 1.0
/*/
Static Function fGetURLMID(cCodEmp)
	Local cUrl 		:= ""

	Default cCodEmp := FWCodEmp()

	cUrl := PadR( SuperGetMv("MV_GPEMURL",.F.,"",cCodEmp), 250)
Return cUrl


/*/{Protheus.doc} function fValWizd
Realiza validações do assistente
@author  Hugo de Oliveira
@since   17/09/2019
@version 1.0
/*/
Static Function fValWizd(aPanel,nPan,aVarPan,oWizard)
	Local nPanel 		:= 0
	Local nX 			:= 0
	Local aFunParGet 	:= {}
	Local bValidGet  	:= {||}
	Local lRet			:= .T.

	nPanel := nPan -1

	For nX := 1 To Len(aPanel[nPanel][3])
		If Len(aPanel[nPanel][3][nX]) >= 12 .and. lRet
			aFunParGet := aPanel[nPanel][3][nX][12]

			//Verifica se utiliza validacao do conteudo do campo na wizard. Executa bloco de codigo conforme funcao e parametros enviados
			If !Empty(aFunParGet) .And. ValType(aFunParGet) == "A"
				aFunparGet[2]	:=	Iif ( ValType(aFunparGet[2])=="N",	Str(aFunparGet[2]),	aFunparGet[2] )
				aAdd(aFunParGet,Alltrim ( Iif ( ValType(cTpContObj)=="N",Str(cTpContObj),cTpContObj) ) )
				bValidGet	:=	& ( "{|| " + aFunParGet[1] + "(" + aFunParGet[2] + ", {'" + aFunParGet[3,1] + "','" + aFunParGet[3,2] + "'}, aVarPan[" + Str( nPanel ) + "," + Str( nX ) + "], aVarPan[" + Str( nPanel ) + "," + Str( nX + 1 ) + "], aVarPan[" + Str( nPanel ) + "," + Str( nX - 1 ) + "],aVarPan[" + Str( nPanel ) + "],aVarPan) }" )
				lRet := Eval(bValidGet)
			Endif
		EndIf
	Next nX
Return lRet


/*/{Protheus.doc} function fLoadTxt
Obtem o codigo da entidade apos enviar o post para o Totvs Service
@author  Hugo de Oliveira
@since   17/09/2019
@version 1.0
/*/
Static Function fLoadTxt(cFileImp)
	Local cTexto		:= ""
	local cCopia		:= ""
	local cExt			:= ""
	Local nHandle		:= 0
	Local nTamanho		:= 0

	If left(cFileImp, 1) # "\"
		CpyT2S(cFileImp,"\")
	Endif

	nHandle 	:= FOpen(cFileImp)
	nTamanho 	:= Fseek(nHandle, 0, FS_END)

	FSeek(nHandle,0,FS_SET)
	FRead(nHandle,@cTexto,nTamanho)
	FClose(nHandle)

	SplitPath( cFileImp,,, @cCopia, cExt)
	FErase("\" + cCopia + cExt)
Return(cTexto)


/*/{Protheus.doc} function fGetIdEnt
Através da API(WSTSSSetup) do TSS, envia os dados do certificado e retorna a entidade.
@author  hugo.de.oliveira
@since   17/10/2019
@version 1.0
/*/
Function fGetIdEnt(aParams, cretorno)
	Local oMID
	Local oRet
	Local lRet	 	:= .F.
	Local lHeader	:= .T.
	Local cIdEnt 	:= ""
	Local cBody		:= ""
	Local cRet 		:= ""
	Local cAlias 	:= "RJ9"
	Local aHeader   := {}
	Local oBody		:= JsonObject():new()	

	Default aParams := {}
	Default cRetorno := ""

	DbSelectArea( cAlias )
	( cAlias )->( DbSetOrder( 5 ) ) // RJ9_NRINSC, RJ9_INI
	( cAlias )->( DbGoTop() )

	//Procura pelo Token
	If FindFunction("fGPETokenMid") .And. RJ9->(ColumnPos("RJ9_CLIENT")) > 0
		cToken := fGPETokenMid(,,aParams[10],aParams[3],aParams[4],aParams[12],@cRetorno)
	EndIf

	//Tratamento para apresentar mensagem de erro em caso falha na geração do Token
	//Caso o serviço do TOKEN do TAF não exista na base não será apresentado erro,
	//pois a versão do TSS pode ser menor que 12.1.33.
	If !Empty(cRetorno) .And. !("404" $ cRetorno)
		Return cIdEnt
	EndIf

	// Montagem do Header
	If Empty(cToken)
		aadd(aHeader, "Content-Type: application/json; charset=UTF-8")
	Else
		aadd(aHeader, "TokenAuthTSS: " + cToken)
	EndIf

	// Montagem dos campos do Body
	oBody["digitalCertificate"] := Encode64( aParams[1] )
	oBody["password"] 			:= aParams[2]
	oBody["url"] 				:= aParams[3]
	oBody["registrationType"] 	:= IIF(VALTYPE(aParams[5])!="N",VAL(aParams[5]),aParams[5])
	oBody["companyName"] 		:= aParams[6]
	oBody["countyCode"] 		:= aParams[7]
	oBody["uf"] 				:= aParams[8]
	oBody["ie"] 				:= aParams[9]
	oBody["registrationNumber"] := aParams[10]
	oBody["branchName"] 		:= aParams[11]
	If Len(aParams) > 12 .And. aParams[13] == 3 //HSM
		oBody["typeCert"] 		:= "A3"
		oBody["module"]			:= aParams[14]
		If !Empty(aParams[15])
			oBody["idHex"]		:= aParams[15]
		Else
			oBody["label"]		:= aParams[16]
		EndIf
		oBody["slot"]			:= aParams[17]
	EndIf
	If Len(aParams) > 17
		oBody["grantNumber"]			:= aParams[18]
	EndIf

	// Compacta e seta o retorno
	cBody := fCompress( @oBody )

	// Chamada da API
	oMID := FwRest():New(aParams[4])
	oMID:setPath("/" + aParams[12])
	oMID:SetPostParams(cBody)

	// Verificação de Retorno
	lHeader := oMID:Post( aHeader )
	lRet 	:= FWJsonDeserialize( oMID:GetResult(), @oRet )

	If lRet .And. lHeader
		cRet 	:= oMID:GetResult()
		cIdEnt	:= ALLTRIM(oRet:IdCompany)

		// Grava a entidade no cadastro do Empregador
		DbSelectArea( cAlias )
		( cAlias )->( DbSetOrder( 5 ) ) // RJ9_NRINSC, RJ9_INI
		( cAlias )->( DbGoTop() )

		If ( cAlias )->( DbSeek( aParams[10] ) ) .Or. ( cAlias )->( DbSeek( SubStr( aParams[10], 1, 8 ) ) )
			Begin Transaction
				Reclock( cAlias, .F.)

				If ( cAlias )->( ColumnPos( "RJ9_IDENT" ) ) > 0
					( cAlias )->RJ9_IDENT := cIdEnt
				EndIf

				MsUnlock()
			End Transaction
		EndIf

		cRetorno := DecodeUtf8(cRet)
	Else
		If lRet .And. oRET != Nil
			cRetorno := DecodeUtf8(oRET:MESSAGE)
		ElseIf !lHeader .And. oMID != Nil
			cRetorno := STR0072 + CRLF + CRLF + STR0073 + CRLF //"Serviço REST não localizado, verifique o endereço informado. "  "Endereço Informado: "
			cRetorno += DecodeUtf8(oMID:CHOST) + CRLF + CRLF
			cRetorno += STR0074 + CRLF //"Retorno: "
			cRetorno += DecodeUtf8(oMID:CINTERNALERROR) + CRLF + CRLF
			cRetorno += STR0075 //"Verifique as configurações e se o mesmo está ativo."
		ElseIf	!lRet .And. oRET != Nil
			cRetorno := DecodeUtf8(oRET:MESSAGE)
		EndIf
	EndIf
Return cIdEnt


/*/{Protheus.doc} function fCompress
Compress String Object
@author  Hugo de Oliveira
@since   30/09/2019
@version 1.0
/*/
Static Function fCompress(oObj)
	Local cJson    := ""
	Local cComp    := ""
	Local lCompact := .F.

	// Set gzip format to Json Object
	cJson := oObj:toJSON()

	If Type("::GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(::GetHeader('Accept-Encoding') )
		lCompact := .T.
	EndIf

	If(lCompact)
		::SetHeader('Content-Encoding','gzip')
		GzStrComp(cJson, @cComp, @nLenComp )
	Else
		cComp := cJson
	Endif
Return cComp
