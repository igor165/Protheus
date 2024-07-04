#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE PARAM_PERIODO		01
#DEFINE PARAM_DIVERGENCIAS	02
#DEFINE PARAM_DESTINO		03
#DEFINE PARAM_CPF			04

#DEFINE HASH_BASE_RECIBO_TRANSMISSAO			01
#DEFINE HASH_BASE_ESTABELECIMENTO				02
#DEFINE HASH_BASE_CPF							03
#DEFINE HASH_BASE_NOME							04
#DEFINE HASH_BASE_MATRICULA						05
#DEFINE HASH_BASE_CATEGORIA						06
#DEFINE HASH_BASE_LOTACAO						07
#DEFINE HASH_BASE_EVENTO_ESOCIAL				08
#DEFINE HASH_BASE_FOLHA_BASE_FGTS				09
#DEFINE HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO	10
#DEFINE HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO	11
#DEFINE HASH_BASE_TAF_BASE_FGTS					12
#DEFINE HASH_BASE_TAF_BASE_FGTS_13_SALARIO		13
#DEFINE HASH_BASE_TAF_BASE_FGTS_RESCISORIO		14
#DEFINE HASH_BASE_GOVERNO_BASE_FGTS				15
#DEFINE HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO	16
#DEFINE HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO	17
#DEFINE HASH_BASE_GOVERNO_LOCALIZADO			18
#DEFINE HASH_BASE_SEM_DIVERGENCIAS				19

#DEFINE HASH_BASE_DEP_FOLHA_DEPOSITO_FGTS				20	
#DEFINE HASH_BASE_DEP_FOLHA_DEPOSITO_FGTS_13_SALARIO	21
#DEFINE HASH_BASE_DEP_FOLHA_DEPOSITO_FGTS_RESCISORIO	22
#DEFINE HASH_BASE_DEP_TAF_DEPOSITO_FGTS					23
#DEFINE HASH_BASE_DEP_TAF_DEPOSITO_FGTS_13_SALARIO		24
#DEFINE HASH_BASE_DEP_TAF_DEPOSITO_FGTS_RESCISORIO		25
#DEFINE HASH_BASE_DEP_GOVERNO_DEPOSITO_FGTS				26
#DEFINE HASH_BASE_DEP_GOVERNO_DEPOSITO_FGTS_13_SALARIO	27
#DEFINE HASH_BASE_DEP_GOVERNO_DEPOSITO_FGTS_RESCISORIO	28
#DEFINE HASH_BASE_DEP_GOVERNO_LOCALIZADO				29

#DEFINE HASH_DEPOSITO_RECIBO_TRANSMISSAO				01
#DEFINE HASH_DEPOSITO_CPF								02
#DEFINE HASH_DEPOSITO_NOME								03
#DEFINE HASH_DEPOSITO_MATRICULA							04
#DEFINE HASH_DEPOSITO_CATEGORIA							05
#DEFINE HASH_DEPOSITO_EVENTO_ESOCIAL					06
#DEFINE HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS				07
#DEFINE HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO	08
#DEFINE HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO	09
#DEFINE HASH_DEPOSITO_TAF_DEPOSITO_FGTS					10
#DEFINE HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO		11
#DEFINE HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO		12
#DEFINE HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS				13
#DEFINE HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO	14
#DEFINE HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO	15
#DEFINE HASH_DEPOSITO_GOVERNO_LOCALIZADO				16
#DEFINE HASH_DEPOSITO_SEM_DIVERGENCIAS					17

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFR124
@type			function
@description	Relatório de Conferência de valores de FGTS.
@description	Componentizado para exportar os dados via Excel ou disponibilizar os dados para serem utilizados em outras camadas.
@author			Felipe C. Seolin
@since			10/06/2019
@version		1.0
@param			cPeriodo	-	Período de referência das informações
@param			cDiverg		-	Opção selecionada para listar apenas divergências
@param			cFileDest	-	Diretório selecionado para gravação do arquivo
@param			cCPF		-	CPF selecionado como filtro de processamento
/*/
//---------------------------------------------------------------------
Function TAFR124( cPeriodo, cDiverg, cFileDest, cCPF )

	Local cTimeStart	:=	""
	Local cTimeTotal	:=	""
	Local cMessage		:=	""
	Local cLinkDoc		:=	"https://tdn.totvs.com/x/iQFHHg"
	Local aParamBox		:=	{}
	Local aRetParam		:=	{}
	Local aFilial		:=	{}
	Local lCancel		:=	.F.
	Local lCallExternal	:=	.F.
	Local lFindHash		:=	FindFunction( "HMNew" ) .and. FindFunction( "HMList" ) .and. FindFunction( "HMClean" ) .and. FindFunction( "HMGet" ) .and. FindFunction( "HMSet" ) .and. FindFunction( "HMAdd" )
	Local lRet			:=	.T.
	Local lPermCont		:= IIf(FindFunction("PROTDATA"),ProtData(),.T.)
	Local lWebApp		:= IIF(GetRemoteType() ==  5 ,.F.,.T.)
	
	Private lVer2_5     := IIF(TafColumnPos("V3N_VLRDEP"),.F.,.T.) // Se não possuir o campo novo de valor, executa o relatório com layout da versão 2.5

	Default cPeriodo	:=	""
	Default cDiverg		:=	0
	Default cFileDest	:=	""
	Default cCPF		:=	""

	If lPermCont

		lCallExternal := !Empty( cPeriodo )

		If lFindHash
			//Executado via Smartclient
			If lCallExternal
				//Mantém a mesma estrutura de retorno da ParamBox
				aAdd( aRetParam, cPeriodo )
				aAdd( aRetParam, cDiverg )
				aAdd( aRetParam, cFileDest )
				aAdd( aRetParam, cCPF )

				R124Proc( oRunProc, lCallExternal, aRetParam ) //ajustar - melhor forma de declarar oRunProc
			Else
				aAdd( aParamBox, { 1, "Período"						, Space( 6 )	, "@E 999999"			, "R124Valid( 'MV_PAR01' )"	, ""						, ".T.", 40	, .T. } )
				aAdd( aParamBox, { 2, "Listar Apenas Divergências"	, "1"			, { "1=Sim", "2=Não" }	, 40						, "R124Valid( 'MV_PAR02' )"	, .T. } )
				aAdd( aParamBox, { 6, "Diretório Destino"			, Space( 100 )  , ""					,""     , cValToChar(lWebApp) , 60   , lWebApp,"" ,,GETF_LOCALHARD + GETF_RETDIRECTORY} )
				aAdd( aParamBox, { 1, "CPF"							, Space( 11 )	, "@E 99999999999"		, "R124Valid( 'MV_PAR04' )"	, "C9VE"					, ".T.", 40	, .F. } )


				If ParamBox( aParamBox, "Filtros", @aRetParam,,,,,,,, .T., .T. )

					While Empty( aFilial ) .and. !lCancel
						aFilial := xFunTelaFil( .T.,,,,, .F., @lCancel, .T. )
					EndDo

					If !lCancel
						cTimeStart := Time()

						FWMsgRun( , { |oRunCharge| RptCharge( oRunCharge, lCallExternal, aRetParam[PARAM_PERIODO], aFilial, aRetParam[PARAM_CPF] ) }, "Aguarde", "Verificando a necessidade de carga de dados..." )
						FWMsgRun( , { |oRunProc| lRet := R124Proc( oRunProc, lCallExternal, aRetParam , aFilial) }, "Aguarde", "Filtrando Registros..." )

						cTimeTotal := ElapTime( cTimeStart, Time() )

						If lRet
							If GetRemoteType() <> 5
								nOpcAviso := Aviso( "Relatório", "Processo finalizado. Tempo Total: " + cTimeTotal + "." + CRLF +;
									"Em caso de dúvidas sobre o relatório, favor acessar a documentação oficial através do link: " + CRLF +;
									cLinkDoc + CRLF +;
									"Ou clique no botão <Acessar Link>";
									, { "Acessar Link", "Copiar Link", "Sair" } )

								If nOpcAviso == 1
									If Upper( TCSrvType() ) == "LINUX"
										ShellExecute( "Browser", "/usr/bin/firefox", cLinkDoc, "/", 1 )
									Else
										ShellExecute( "Open", cLinkDoc, "", "C:\", 1 )
									EndIf
								ElseIf nOpcAviso == 2
									CopyToClipboard( cLinkDoc )
									MsgInfo( "Link copiado com sucesso!", "Relatório de Conferência de FGTS" )
								EndIf
							Else
								nOpcAviso := Aviso( "Relatório", "Processo finalizado. Tempo Total: " + cTimeTotal + "." + CRLF +;
									"Em caso de dúvidas sobre o relatório, favor acessar a documentação oficial através do link: " + CRLF +;
									cLinkDoc + CRLF +;
									"Ou clique no botão Acessar Link";
									, { "Acessar Link", "Sair" } )

								If nOpcAviso == 1
									If Upper( TCSrvType() ) == "LINUX"
										ShellExecute( "Browser", "/usr/bin/firefox", cLinkDoc, "/", 1 )
									Else
										ShellExecute( "Open", cLinkDoc, "", "C:\", 1 )
									EndIf
								EndIf
							EndIf
						Else
							cMessage := "Não foram encontrados dados com os parâmetros informados!"
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			cMessage := "O repositório do TAF está desatualizado. Para execução deste relatório é necessário a existência das funções de Manipulação de Matriz. Mais detalhes em: http://tdn.totvs.com/x/iYObB"
			lRet := .F.
		EndIf

		If !lRet .and. !lCancel
			If lCallExternal
				//ajustar - padronizar formato de resposta para serviço
			Else
				Aviso( "Relatório de Conferência de FGTS", cMessage, { "Encerrar" }, 2 )
			EndIf
		EndIf
	EndIf
Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} R124Proc
@type			function
@description	Encapsula as funções de processamento do relatório.
@author			Felipe C. Seolin
@since			10/06/2019
@version		1.0
@param			oRunProc		-	Objeto do FWMsgRun
@param			lCallExternal	-	Indica se a chamada é externa ao menu do TAF
@param			aRetParam		-	Array com os parâmetros selecionados
@return			lRet			-	Indica se a o relatório foi processado corretamente
/*/
//---------------------------------------------------------------------
Static Function R124Proc( oRunProc, lCallExternal, aRetParam, aFilial )

	Local oHashBase := TAFXHMNew()
	Local oHashDepo := TAFXHMNew()
	Local cFileDest := AllTrim( aRetParam[PARAM_DESTINO] )
	Local cPeriodo  := AllTrim( aRetParam[PARAM_PERIODO] )
	Local cCPF      := AllTrim( aRetParam[PARAM_CPF] )
	Local aArqBase  := {}
	Local aArqDepo  := {}
	Local lDiverg   := aRetParam[PARAM_DIVERGENCIAS] == "1"
	Local lRet      := .F.

	Default aFilial := {}

	If Len( AllTrim( cPeriodo ) ) > 4
		cPeriodo := SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 )
	EndIf

	//Monta os Hashs para posteriormente realizar a impressão dos dados
	R124Hash( "S-1200", cPeriodo, cCPF, @oHashBase, @oHashDepo, lCallExternal, oRunProc , aFilial)

	If Len( AllTrim( cPeriodo ) ) <> 4
		R124Hash( "S-2299", cPeriodo, cCPF, @oHashBase, @oHashDepo, lCallExternal, oRunProc , aFilial)
		R124Hash( "S-2399", cPeriodo, cCPF, @oHashBase, @oHashDepo, lCallExternal, oRunProc , aFilial)
	EndIf

	//Realiza a impressão do relatório
	If !lCallExternal
		TAFXHMList( oHashBase, aArqBase )
		TAFXHMList( oHashDepo, aArqDepo )

		If Len( aArqBase ) + Len( aArqDepo ) > 0
			PrintData( oRunProc, lCallExternal, AllTrim( cFileDest ), aArqBase, aArqDepo, cPeriodo, lDiverg )
			lRet := .T.
		EndIf
	EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} R124Hash
@type			function
@description	Alimenta o objeto do HashMap com os dados relacionados a FGTS.
@author			Felipe C. Seolin
@since			11/06/2019
@version		1.0
@param			cEvento			-	Evento de referência para processamento
@param			cPeriodo		-	Período de referência das informações
@param			cCPF			-	CPF selecionado como filtro de processamento
@param			oHashBase		-	Objeto do HashMap para armazenar Base de Cálculo do FGTS ( referência )
@param			oHashDepo		-	Objeto do HashMap para armazenar Depósito do FGTS ( referência )
@param			lCallExternal	-	Indica se a chamada é externa ao menu do TAF
@param			oRunProc		-	Objeto do FWMsgRun
/*/
//---------------------------------------------------------------------
Static Function R124Hash( cEvento, cPeriodo, cCPF, oHashBase, oHashDepo, lCallExternal, oRunProc , aFilial)

	Local cNextAlias  := GetNextAlias()
	Local cNatureza   := ""
	Local cTipo       := ""
	Local cIncidFGTS  := ""
	Local nBasFGTS    := 0
	Local nDepFGTS    := 0
	Local nBasFGTSRes := 0
	Local nDepFGTSRes := 0
	Local nBasFGTS13  := 0
	Local nDepFGTS13  := 0
	Local nQtdRegs    := 0
	Local nRegistro   := 0
	Local aPosBase    := {}
	Local aPosDepo    := {}
	Local lAddBase    := .F.
	Local lAddDepo    := .F.
	Local lBaseUni	  := .F.
	Local lTafGpeFgts := IIF(FindFunction("TafGpeFgtsInss"), TafGpeFgtsInss(), .F. )
	Local lVlrDep	  := TafColumnPos("V3N_VLRDEP")
	Local cMV_TAFFGMD := SuperGetMv("MV_TAFFGMD", .F., "02|03|05|06|14|17|26|27|33") 

	Default aFilial   := {} //Filiais selecionadas

	//Garante que o aliás está fechado
	If Select( cNextAlias ) > 0
		( cNextAlias )->( DBCloseArea() )
	EndIf

	If R124Query( cEvento, cPeriodo, cCPF, @cNextAlias, @nQtdRegs , aFilial)
	
		While ( cNextAlias )->( !Eof() )
			nRegistro ++

			If !lCallExternal
				SetIncPerc( oRunProc, cEvento, nQtdRegs, nRegistro )
			EndIf

			Do Case

			Case ( cNextAlias )->V3N_ORIGEM $ "1|2"

				cNatureza	:=	AllTrim( ( cNextAlias )->V3N_NATRUB )
				cTipo		:=	AllTrim( ( cNextAlias )->V3N_TPRUBR )
				cIncidFGTS	:=	AllTrim( ( cNextAlias )->V3N_ITFGTS )

				If ( cNextAlias )->V3N_INDAPU == "1"
					If cNatureza == "9902" .and. cTipo == "3"
						nBasFGTS := ( cNextAlias )->V3N_VALOR
						lAddBase := .T.
					ElseIf cNatureza == "9904" .and. cTipo == "3"
						nBasFGTSRes := ( cNextAlias )->V3N_VALOR
						lAddBase := .T.
					ElseIf cNatureza == "9908" .and. cTipo == "3"
						// Ser S-2299/S-2399 não é motivo para automaticamente incluir como FGTS Rescisório.
						// Se o Desligamento tiver Motiv de Desligamento diferente de 02|03|05|06|14|17|26|27|33, ele não gera guia de FGTS Rescisório, sendo considerado FGTS Mensal
						If cEvento == "S-1200"  .or. ( val(( cNextAlias )->V3N_MOTDES) > 0 .and. !( cNextAlias )->V3N_MOTDES $ cMV_TAFFGMD ) 
							nDepFGTS := ( cNextAlias )->V3N_VALOR
							lAddDepo := .T.
							lBaseUni := .T.
						Else
							nDepFGTSRes := ( cNextAlias )->V3N_VALOR
							lAddDepo := .T.
							lBaseUni := .T.
						EndIf
					EndIf
				ElseIf ( cNextAlias )->V3N_INDAPU == "2"
					If cNatureza == "9902" .and. cTipo == "3"
						nBasFGTS13 := ( cNextAlias )->V3N_VALOR
						lAddBase := .T.
					ElseIf cNatureza == "9908" .and. cTipo == "3"
						nDepFGTS13 := ( cNextAlias )->V3N_VALOR
						lAddDepo := .T.
						lBaseUni := .T.
					ElseIf lTafGpeFgts .And. cNatureza == "9989" .And. cTipo == "4" .And. cIncidFGTS =="12"
						nBasFGTS13 -= ( cNextAlias )->V3N_VALOR
						lAddBase := .T.
					EndIf
				EndIf

			Case ( cNextAlias )->V3N_ORIGEM == "5"
				cTipo := AllTrim( ( cNextAlias )->V3N_TPVLR )

				If cTipo $ "11|13|15|17|41|43" 
					nBasFGTS := ( cNextAlias )->V3N_VALOR
					lAddBase := .T.
						
					IF lVlrDep .And. ( cNextAlias )->V3N_VLRDEP > 0
						nDepFGTS := ( cNextAlias )->V3N_VLRDEP
						lAddDepo := .T.
						lBaseUni := .T.
					ENDIF

				ElseIf cTipo $ "12|14|16|18|22|25|28|31|42|44|46|49"
					nBasFGTS13 := ( cNextAlias )->V3N_VALOR
					lAddBase := .T.

					IF lVlrDep .And. ( cNextAlias )->V3N_VLRDEP > 0
						nDepFGTS13 := ( cNextAlias )->V3N_VLRDEP
						lAddDepo := .T.
						lBaseUni := .T.
					ENDIF

				ElseIf cTipo $ "21|23|24|26|27|29|30|32|45|47|48|50" 
					nBasFGTSRes := ( cNextAlias )->V3N_VALOR
					lAddBase := .T.

					IF lVlrDep .And. ( cNextAlias )->V3N_VLRDEP > 0
						nDepFGTSRes := ( cNextAlias )->V3N_VLRDEP
						lAddDepo := .T.
						lBaseUni := .T.
					ENDIF

				ElseIf cTipo $ "51|53|55|57" 
					nDepFGTS := ( cNextAlias )->V3N_VALOR
					lAddDepo := .T.
					lVer2_5  := .T.
				ElseIf cTipo $ "52|54|56|58|62|65|68|71" 
					nDepFGTS13 := ( cNextAlias )->V3N_VALOR
					lAddDepo := .T.
					lVer2_5  := .T.
				ElseIf cTipo $ "61|63|64|66|67|69|70|72"
					nDepFGTSRes := ( cNextAlias )->V3N_VALOR
					lAddDepo := .T.
					lVer2_5  := .T.
				EndIf

			OtherWise

				lAddBase := .F.
				lAddDepo := .F.

			EndCase

			If lAddBase .Or. lBaseUni

				If TAFXHMGet( oHashBase, AllTrim( ( cNextAlias )->V3N_NRINSC ) + cEvento + AllTrim( ( cNextAlias )->V3N_CPF ) + AllTrim( ( cNextAlias )->V3N_MATRIC ) + AllTrim( ( cNextAlias )->V3N_CATEG ) + AllTrim( ( cNextAlias )->V3N_CODLOT ), @aPosBase )
					
					aPosBase[1,HASH_BASE_CPF]				:=	AllTrim( ( cNextAlias )->V3N_CPF )
					aPosBase[1,HASH_BASE_NOME]				:=	AllTrim( ( cNextAlias )->V3N_NOME )
					aPosBase[1,HASH_BASE_MATRICULA]			:=	AllTrim( ( cNextAlias )->V3N_MATRIC )
					aPosBase[1,HASH_BASE_LOTACAO]			:=	AllTrim( ( cNextAlias )->V3N_CODLOT )
					aPosBase[1,HASH_BASE_ESTABELECIMENTO]	:=	AllTrim( ( cNextAlias )->V3N_NRINSC )
					aPosBase[1,HASH_BASE_CATEGORIA]			:=	AllTrim( ( cNextAlias )->V3N_CATEG )
					aPosBase[1,HASH_BASE_EVENTO_ESOCIAL]	:=	cEvento

					Do Case

					Case ( cNextAlias )->V3N_ORIGEM == "1"

						If lBaseUni
							aPosBase[1,HASH_BASE_DEP_FOLHA_DEPOSITO_FGTS]				+=	nDepFGTS
							aPosBase[1,HASH_BASE_DEP_FOLHA_DEPOSITO_FGTS_13_SALARIO]	+=	nDepFGTS13
							aPosBase[1,HASH_BASE_DEP_FOLHA_DEPOSITO_FGTS_RESCISORIO]	+=	nDepFGTSRes
						Else
							aPosBase[1,HASH_BASE_FOLHA_BASE_FGTS]				+=	nBasFGTS
							aPosBase[1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]	+=	nBasFGTS13
							aPosBase[1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]	+=	nBasFGTSRes
						EndIf

					Case ( cNextAlias )->V3N_ORIGEM == "2"

						If lBaseUni
							aPosBase[1,HASH_BASE_DEP_TAF_DEPOSITO_FGTS]				+=	nDepFGTS
							aPosBase[1,HASH_BASE_DEP_TAF_DEPOSITO_FGTS_13_SALARIO]	+=	nDepFGTS13
							aPosBase[1,HASH_BASE_DEP_TAF_DEPOSITO_FGTS_RESCISORIO]	+=	nDepFGTSRes
						Else
							aPosBase[1,HASH_BASE_TAF_BASE_FGTS]				+=	nBasFGTS
							aPosBase[1,HASH_BASE_TAF_BASE_FGTS_13_SALARIO]	+=	nBasFGTS13
							aPosBase[1,HASH_BASE_TAF_BASE_FGTS_RESCISORIO]	+=	nBasFGTSRes
						EndIf
						
					Case ( cNextAlias )->V3N_ORIGEM == "5"

						If lBaseUni
							aPosBase[1,HASH_BASE_DEP_GOVERNO_DEPOSITO_FGTS]				+=	nDepFGTS
							aPosBase[1,HASH_BASE_DEP_GOVERNO_DEPOSITO_FGTS_13_SALARIO]	+=	nDepFGTS13
							aPosBase[1,HASH_BASE_DEP_GOVERNO_DEPOSITO_FGTS_RESCISORIO]	+=	nDepFGTSRes

							If (nDepFGTS + nDepFGTS13 + nDepFGTSRes) > 0
								aPosBase[1,HASH_BASE_DEP_GOVERNO_LOCALIZADO]			:=	.T.
							EndIf

							aPosBase[1,HASH_BASE_GOVERNO_BASE_FGTS]				+=	nBasFGTS
							aPosBase[1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]	+=	nBasFGTS13
							aPosBase[1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]	+=	nBasFGTSRes

							If (nBasFGTS + nBasFGTS13 + nBasFGTSRes) > 0
								aPosBase[1,HASH_BASE_GOVERNO_LOCALIZADO]		:=	.T.
							EndIf

						Else
							aPosBase[1,HASH_BASE_GOVERNO_BASE_FGTS]				+=	nBasFGTS
							aPosBase[1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]	+=	nBasFGTS13
							aPosBase[1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]	+=	nBasFGTSRes
							aPosBase[1,HASH_BASE_GOVERNO_LOCALIZADO]			:=	.T.
						EndIf

					EndCase

					aPosBase[1,HASH_BASE_RECIBO_TRANSMISSAO]	:=	AllTrim( ( cNextAlias )->V3N_RECIBO )

					TAFXHMSet( oHashBase, aPosBase, aPosBase[1,HASH_BASE_ESTABELECIMENTO] + aPosBase[1,HASH_BASE_EVENTO_ESOCIAL] + aPosBase[1,HASH_BASE_CPF] + aPosBase[1,HASH_BASE_MATRICULA] + aPosBase[1,HASH_BASE_CATEGORIA] + aPosBase[1,HASH_BASE_LOTACAO] )
				
				Else

					aPosBase := InitBase()

					aPosBase[HASH_BASE_CPF]				:=	AllTrim( ( cNextAlias )->V3N_CPF )
					aPosBase[HASH_BASE_NOME]			:=	AllTrim( ( cNextAlias )->V3N_NOME )
					aPosBase[HASH_BASE_MATRICULA]		:=	AllTrim( ( cNextAlias )->V3N_MATRIC )
					aPosBase[HASH_BASE_LOTACAO]			:=	AllTrim( ( cNextAlias )->V3N_CODLOT )
					aPosBase[HASH_BASE_ESTABELECIMENTO]	:=	AllTrim( ( cNextAlias )->V3N_NRINSC )
					aPosBase[HASH_BASE_CATEGORIA]		:=	AllTrim( ( cNextAlias )->V3N_CATEG )
					aPosBase[HASH_BASE_EVENTO_ESOCIAL]	:=	cEvento

					Do Case

					Case ( cNextAlias )->V3N_ORIGEM == "1"

						If lBaseUni
							aPosBase[HASH_BASE_DEP_FOLHA_DEPOSITO_FGTS]				:=	nDepFGTS
							aPosBase[HASH_BASE_DEP_FOLHA_DEPOSITO_FGTS_13_SALARIO]	:=	nDepFGTS13
							aPosBase[HASH_BASE_DEP_FOLHA_DEPOSITO_FGTS_RESCISORIO]	:=	nDepFGTSRes
						Else
							aPosBase[HASH_BASE_FOLHA_BASE_FGTS]				:=	nBasFGTS
							aPosBase[HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]	:=	nBasFGTS13
							aPosBase[HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]	:=	nBasFGTSRes
						EndIf

					Case ( cNextAlias )->V3N_ORIGEM == "2"

						If lBaseUni
							aPosBase[HASH_BASE_DEP_TAF_DEPOSITO_FGTS]				:=	nDepFGTS
							aPosBase[HASH_BASE_DEP_TAF_DEPOSITO_FGTS_13_SALARIO]	:=	nDepFGTS13
							aPosBase[HASH_BASE_DEP_TAF_DEPOSITO_FGTS_RESCISORIO]	:=	nDepFGTSRes
						Else
							aPosBase[HASH_BASE_TAF_BASE_FGTS]				:=	nBasFGTS
							aPosBase[HASH_BASE_TAF_BASE_FGTS_13_SALARIO]	:=	nBasFGTS13
							aPosBase[HASH_BASE_TAF_BASE_FGTS_RESCISORIO]	:=	nBasFGTSRes
						EndIf

					Case ( cNextAlias )->V3N_ORIGEM == "5"

						If lBaseUni
							aPosBase[HASH_BASE_DEP_GOVERNO_DEPOSITO_FGTS]				:=	nDepFGTS
							aPosBase[HASH_BASE_DEP_GOVERNO_DEPOSITO_FGTS_13_SALARIO]	:=	nDepFGTS13
							aPosBase[HASH_BASE_DEP_GOVERNO_DEPOSITO_FGTS_RESCISORIO]	:=	nDepFGTSRes
							aPosBase[HASH_BASE_DEP_GOVERNO_LOCALIZADO]					:=	.T.
							aPosBase[HASH_BASE_GOVERNO_LOCALIZADO]						:=	.T.
						Else
							aPosBase[HASH_BASE_GOVERNO_BASE_FGTS]				:=	nBasFGTS
							aPosBase[HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]	:=	nBasFGTS13
							aPosBase[HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]	:=	nBasFGTSRes
							aPosBase[HASH_BASE_GOVERNO_LOCALIZADO]				:=	.T.
						EndIf

					EndCase

					aPosBase[HASH_BASE_RECIBO_TRANSMISSAO]	:=	AllTrim( ( cNextAlias )->V3N_RECIBO )

					TAFXHMAdd( oHashBase, aPosBase, HASH_BASE_ESTABELECIMENTO, 3, HASH_BASE_EVENTO_ESOCIAL, 3, HASH_BASE_CPF, 3, HASH_BASE_MATRICULA, 3, HASH_BASE_CATEGORIA, 3, HASH_BASE_LOTACAO, 3 )

				EndIf

			EndIf

			If lAddDepo

				If TAFXHMGet( oHashDepo, cEvento + AllTrim( ( cNextAlias )->V3N_CPF ) + AllTrim( ( cNextAlias )->V3N_MATRIC ) + AllTrim( ( cNextAlias )->V3N_CATEG ), @aPosDepo )
					
					aPosDepo[1,HASH_DEPOSITO_CPF]				:=	AllTrim( ( cNextAlias )->V3N_CPF )
					aPosDepo[1,HASH_DEPOSITO_NOME]				:=	AllTrim( ( cNextAlias )->V3N_NOME )
					aPosDepo[1,HASH_DEPOSITO_MATRICULA]			:=	AllTrim( ( cNextAlias )->V3N_MATRIC )
					aPosDepo[1,HASH_DEPOSITO_CATEGORIA]			:=	AllTrim( ( cNextAlias )->V3N_CATEG )
					aPosDepo[1,HASH_DEPOSITO_EVENTO_ESOCIAL]	:=	cEvento

					Do Case

					Case ( cNextAlias )->V3N_ORIGEM == "1"
						aPosDepo[1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]				+=	nDepFGTS
						aPosDepo[1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]	+=	nDepFGTS13
						aPosDepo[1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]	+=	nDepFGTSRes

					Case ( cNextAlias )->V3N_ORIGEM == "2"
						aPosDepo[1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS]				+=	nDepFGTS
						aPosDepo[1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO]	+=	nDepFGTS13
						aPosDepo[1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO]	+=	nDepFGTSRes

					Case ( cNextAlias )->V3N_ORIGEM == "5"
						aPosDepo[1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]				+=	nDepFGTS
						aPosDepo[1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]	+=	nDepFGTS13
						aPosDepo[1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]	+=	nDepFGTSRes
						aPosDepo[1,HASH_DEPOSITO_GOVERNO_LOCALIZADO]				:=	.T.

					EndCase

					aPosDepo[1,HASH_DEPOSITO_RECIBO_TRANSMISSAO]	:=	AllTrim( ( cNextAlias )->V3N_RECIBO )

				    TAFXHMSet( oHashDepo, aPosDepo, aPosDepo[1,HASH_DEPOSITO_EVENTO_ESOCIAL] + aPosDepo[1,HASH_DEPOSITO_CPF] + aPosDepo[1,HASH_DEPOSITO_MATRICULA] + aPosDepo[1,HASH_DEPOSITO_CATEGORIA] )
							
				Else
					
					aPosDepo := InitDeposito()

					aPosDepo[HASH_DEPOSITO_CPF]				:=	AllTrim( ( cNextAlias )->V3N_CPF )
					aPosDepo[HASH_DEPOSITO_NOME]			:=	AllTrim( ( cNextAlias )->V3N_NOME )
					aPosDepo[HASH_DEPOSITO_MATRICULA]		:=	AllTrim( ( cNextAlias )->V3N_MATRIC )
					aPosDepo[HASH_DEPOSITO_CATEGORIA]		:=	AllTrim( ( cNextAlias )->V3N_CATEG )
					aPosDepo[HASH_DEPOSITO_EVENTO_ESOCIAL]	:=	cEvento
					
					Do Case

					Case ( cNextAlias )->V3N_ORIGEM == "1"
						aPosDepo[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]				:=	nDepFGTS
						aPosDepo[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]	:=	nDepFGTS13
						aPosDepo[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]	:=	nDepFGTSRes

					Case ( cNextAlias )->V3N_ORIGEM == "2"
						aPosDepo[HASH_DEPOSITO_TAF_DEPOSITO_FGTS]				:=	nDepFGTS
						aPosDepo[HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO]	:=	nDepFGTS13
						aPosDepo[HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO]	:=	nDepFGTSRes

					Case ( cNextAlias )->V3N_ORIGEM == "5"
						aPosDepo[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]				:=	nDepFGTS
						aPosDepo[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]	:=	nDepFGTS13
						aPosDepo[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]	:=	nDepFGTSRes
						aPosDepo[HASH_DEPOSITO_GOVERNO_LOCALIZADO]					:=	.T.

					EndCase

					aPosDepo[HASH_DEPOSITO_RECIBO_TRANSMISSAO]	:=	AllTrim( ( cNextAlias )->V3N_RECIBO )

					TAFXHMAdd( oHashDepo, aPosDepo, HASH_DEPOSITO_EVENTO_ESOCIAL, 3, HASH_DEPOSITO_CPF, 3, HASH_DEPOSITO_MATRICULA, 3, HASH_DEPOSITO_CATEGORIA, 3 )

				EndIf

			EndIf

			cNatureza	:=	""
			cTipo		:=	""
			cIncidFGTS	:=	""
			nBasFGTS	:=	0
			nDepFGTS	:=	0
			nBasFGTS13	:=	0
			nDepFGTS13	:=	0
			nBasFGTSRes	:=	0
			nDepFGTSRes	:=	0
			aPosBase	:=	{}
			aPosDepo	:=	{}
			lAddBase	:=	.F.
			lAddDepo	:=	.F.
			lBaseUni	:=	.F.

			( cNextAlias )->( DBSkip() )

		EndDo

	Else

		nRegistro ++

		If !lCallExternal
			SetIncPerc( oRunProc, cEvento, nQtdRegs, nRegistro )
		EndIf
	EndIf

	( cNextAlias )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} R124Query
@type			function
@description	Filtra os registros e disponibiliza um arquivo de trabalho via referência.
@author			Felipe C. Seolin
@since			13/06/2019
@version		1.0
@param			cEvento			-	Evento de referência para processamento
@param			cPeriodo		-	Período de referência das informações
@param			cCPF			-	CPF selecionado como filtro de processamento
@param			cNextAlias		-	Arquivo de trabalho para o resultado da consulta ( referência )
@param			nQtdRegs		-	Quantidade de registros do resultado da consulta ( referência )
@return			lRet			-	Indica se a consulta possui dados

/*/
//---------------------------------------------------------------------
Static Function R124Query( cEvento, cPeriodo, cCPF, cNextAlias, nQtdRegs, aFiliais )

	Local aFFil		:= {} //Filiais selecionadas e formatadas para serem utilizadas no in da query
	Local cFFil		:= ""
	Local cQuery	:= ""
	Local lRet		:= .F.
	Local nCFil		:= 0 //Variável contatora para controle e varredura de filiais.
	Local lVlrDep	:= TafColumnPos("V3N_VLRDEP")

	Default aFiliais:= {} //Filiais selecionadas na interface

	//----------------------------------------
	//CHECAGEM DE FILIAIS SELECIONADAS
	//----------------------------------------
	If Len(aFiliais) > 0

		For nCFil:=1 To Len(aFiliais)
			
			If aFiliais[nCFIL][1]

				aAdd(aFFil, xFilial("V3N", aFiliais[nCFIL][2]))
			
			EndIf

		Next nCFil

		cFFil := TAFCacheFil("V3N", aFFil, .T.)

	EndIf

	If cEvento == "S-1200"
		cQuery := "SELECT V3N.V3N_FILIAL, "
		cQuery += " V3N.V3N_INDAPU, " 
		cQuery += " V3N.V3N_PERAPU, " 
		cQuery += " V3N.V3N_CPF, "
	 	cQuery += " V3N.V3N_NOME, "
 		cQuery += " V3N.V3N_MATRIC, " 
		cQuery += " V3N.V3N_CATEG,  "
		cQuery += " V3N.V3N_TPINSC, " 
		cQuery += " V3N.V3N_NRINSC, " 
		cQuery += " V3N.V3N_CODLOT, " 
		cQuery += " V3N.V3N_EVENTO, " 
		cQuery += " V3N.V3N_ORIGEM, " 
		cQuery += " V3N.V3N_RECIBO, " 
		cQuery += " V3N.V3N_NATRUB, " 
		cQuery += " V3N.V3N_TPRUBR, " 
		cQuery += " V3N.V3N_ITFGTS, " 
		cQuery += " V3N.V3N_TPVLR,  "
		cQuery += " V3N.V3N_VALOR,  "
		cQuery += " V3N.V3N_MOTDES " 

		If lVlrDep
			cQuery += " ,V3N.V3N_VLRDEP  "
		EndIf 
	ElseIf cEvento $ "S-2299|S-2399"
		cQuery := 'SELECT V3N.V3N_FILIAL, '
		cQuery += 'V3N.V3N_INDAPU, '
		cQuery += 'V3N.V3N_PERAPU, '
		cQuery += 'V3N.V3N_CPF, '
		cQuery += 'V3N.V3N_NOME, '
		cQuery += 'V3N.V3N_MATRIC, '
		cQuery += 'V3N.V3N_CATEG, '
		cQuery += 'V3N.V3N_TPINSC, '
		cQuery += 'V3N.V3N_NRINSC, '
		cQuery += 'V3N.V3N_CODLOT, '
		cQuery += 'V3N.V3N_EVENTO, '
		cQuery += 'V3N.V3N_ORIGEM, '
		cQuery += 'V3N.V3N_RECIBO, '
		cQuery += 'V3N.V3N_NATRUB, '
		cQuery += 'V3N.V3N_TPRUBR, '
		cQuery += 'V3N.V3N_ITFGTS, '
		cQuery += 'V3N.V3N_TPVLR, '
		cQuery += 'V3N.V3N_VALOR, '
		cQuery += 'C8O.C8O_CODIGO "V3N_MOTDES" '
		
		If lVlrDep
			cQuery += ',V3N.V3N_VLRDEP  '
		EndIf 
	EndIf
	cQuery += "FROM " + RetSqlName( "V3N" ) + " V3N "

	If	cEvento $ "S-2299|S-2399"
		cQuery += "LEFT JOIN	" + RetSqlName( "C9V" ) + " C9V "
		cQuery += "ON "
		cQuery += "C9V.C9V_FILIAL			=	V3N.V3N_FILIAL "
		cQuery += "AND	C9V.C9V_CPF			=	V3N.V3N_CPF "
		cQuery += "AND  C9V.C9V_MATRIC		=	V3N.V3N_MATRIC "
		cQuery += "AND	C9V.C9V_ATIVO		=	'1' "
		cQuery += "AND	C9V.D_E_L_E_T_		=	' ' "
		cQuery += "LEFT JOIN	" + RetSqlName( "CMD" ) + " CMD "
		cQuery += "ON "
		cQuery += "CMD.CMD_FILIAL			=	V3N.V3N_FILIAL "
		cQuery += "AND CMD.CMD_FUNC			=	C9V.C9V_ID "
		cQuery += "AND	CMD.CMD_ATIVO		=	'1' "
		cQuery += "AND	CMD.D_E_L_E_T_		=	' ' "
		cQuery += "LEFT JOIN	" + RetSqlName( "C8O" ) + " C8O "
		cQuery += "ON "
		cQuery += "C8O.C8O_ID				=	CMD.CMD_MOTDES "
		cQuery += "AND	C8O.D_E_L_E_T_		=	' ' "
	EndIf

	cQuery += "WHERE V3N.V3N_PERAPU = '" + cPeriodo + "' "
	cQuery += "  AND V3N.V3N_EVENTO = '" + cEvento + "' "
	cQuery += "  AND V3N.V3N_ORIGEM IN ( '1', '2', '5' ) "

	If cEvento == "S-1200"

		cQuery += " AND V3N.V3N_MOTDES = '' "
		
	EndIF

	If Len(aFiliais) > 0 .AND. !Empty(cFFil)

		cQuery += "  AND V3N.V3N_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFFil + " FILIAIS ) "

	EndIf

	If !Empty( cCPF )
		cQuery += "  AND V3N.V3N_CPF = '" + cCPF + "' "
	EndIf
	
	cQuery += "  AND V3N.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cNextAlias)

	( cNextAlias )->( DBGoTop() )

	If ( cNextAlias )->( !Eof() )
		( cNextAlias )->( DBEval( { || nQtdRegs ++ } ) )
		lRet := .T.
	EndIf

	//Força o ponteiro no topo, pois o DBEval deixa em EOF
	( cNextAlias )->( DBGoTop() )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} PrintData
@type			function
@description	Gera um arquivo de excel com as informações de FGTS colhidas.
@author			Felipe C. Seolin
@since			14/06/2019
@version		1.0
@param			oRunProc		-	Objeto do FWMsgRun
@param			lCallExternal	-	Indica se a chamada é externa ao menu do TAF
@param			cPath			-	Diretório selecionado para gravação do arquivo
@param			aArqBase		-	Array com os dados de Base de Cálculo do FGTS
@param			aArqDepo		-	Array com os dados de Depósito do FGTS
@param			cPeriodo		-	Período de referência das informações
@param			lDiverg			-	Indica se de listar apenas divergências
/*/
//---------------------------------------------------------------------
Static Function PrintData( oRunProc, lCallExternal, cPath, aArqBase, aArqDepo, cPeriodo, lDiverg )

	Local oExcel     := FWMSExcel():New()
	Local oExcelApp  := Nil
	Local cAba       := ""
	Local cTabela    := ""
	Local cEvtDesc   := ""
	Local cStatusGov := ""
	Local cArquivo   := "REL_S-5003_" + cPeriodo + "_" + DToS( MsDate() ) + "_" + StrTran( Time(), ":", "" ) + ".XLS"
	Local cDefPath   := GetSrvProfString( "StartPath", "\system\" )
	Local nI         := 0
	Local nQtdTotal  := Len( aArqBase ) + Len( aArqDepo )
	Local nFGTSOri   := 0
	Local nFGTSTAF   := 0
	Local nFGTSGov   := 0
	Local nCount     := 0
	Local nCountBase := 0
	Local nFGTSDepOri := 0
	Local nFGTSDepTAF := 0
	Local nFGTSDePGov := 0

	aSort( aArqBase,,, { |x,y| x[2,1,HASH_BASE_ESTABELECIMENTO] 	+ x[2,1,HASH_BASE_LOTACAO] 	+ x[2,1,HASH_BASE_EVENTO_ESOCIAL] 		+ x[2,1,HASH_BASE_NOME] < y[2,1,HASH_BASE_ESTABELECIMENTO] + y[2,1,HASH_BASE_LOTACAO] + y[2,1,HASH_BASE_EVENTO_ESOCIAL] + y[2,1,HASH_BASE_NOME] } )
	

	For nI := 1 to Len( aArqBase )

		If nI == 1

			cAba := IIF(lVer2_5,"Base","Base - Depósito FGTS" )

			If Len( AllTrim( cPeriodo ) ) == 4 //Décimo Terceiro
				cTabela := "Periodo_" + cPeriodo
			Else
				cTabela := "Periodo_" + SubStr( cPeriodo, 5, 2 ) + "/" + SubStr( cPeriodo, 1, 4 )
			EndIf

			oExcel:AddWorkSheet( cAba )
			oExcel:AddTable( cAba, cTabela )

			oExcel:AddColumn( cAba, cTabela, "Estabelecimento", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "Lotação", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "CPF", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "Nome", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "Matrícula", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "Categoria", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "Evento eSocial", 1, 1, .F. )

			oExcel:AddColumn( cAba, cTabela, "Folha - Base FGTS", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "TAF - Base FGTS", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Base FGTS", 1, 3, .T. )

			If !lVer2_5
				oExcel:AddColumn( cAba, cTabela, "Folha - Depósito FGTS", 1, 3, .T. )
				oExcel:AddColumn( cAba, cTabela, "TAF - Depósito FGTS", 1, 3, .T. )
				oExcel:AddColumn( cAba, cTabela, "Governo - Depósito FGTS", 1, 3, .T. )
			EndIf

			oExcel:AddColumn( cAba, cTabela, "Folha - Base FGTS - 13° Salário", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "TAF - Base FGTS - 13° Salário", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Base FGTS - 13° Salário", 1, 3, .T. )

			If !lVer2_5
				oExcel:AddColumn( cAba, cTabela, "Folha - Depósito FGTS - 13° Salário", 1, 3, .T. )
				oExcel:AddColumn( cAba, cTabela, "TAF - Depósito FGTS - 13° Salário", 1, 3, .T. )
				oExcel:AddColumn( cAba, cTabela, "Governo - Depósito FGTS - 13° Salário", 1, 3, .T. )
			EndIf

			oExcel:AddColumn( cAba, cTabela, "Folha - Base FGTS - Rescisório", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "TAF - Base FGTS - Rescisório", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Base FGTS - Rescisório", 1, 3, .T. )

			If !lVer2_5
				oExcel:AddColumn( cAba, cTabela, "Folha - Depósito FGTS - Rescisório", 1, 3, .T. )
				oExcel:AddColumn( cAba, cTabela, "TAF - Depósito FGTS - Rescisório", 1, 3, .T. )
				oExcel:AddColumn( cAba, cTabela, "Governo - Depósito FGTS - Rescisório", 1, 3, .T. )
			EndIf

		EndIf

		If lDiverg

			If aArqBase[nI,2,1,HASH_BASE_EVENTO_ESOCIAL] == 'S-1200'
				nFGTSOri := aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS]   + aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]
				nFGTSTAF := aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS]   	 + aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS_13_SALARIO]
				nFGTSGov := aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS] + aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO] 

				nFGTSDepOri := aArqBase[nI,2,1,HASH_BASE_DEP_FOLHA_DEPOSITO_FGTS]   + aArqBase[nI,2,1,HASH_BASE_DEP_FOLHA_DEPOSITO_FGTS_13_SALARIO]
				nFGTSDepTAF := aArqBase[nI,2,1,HASH_BASE_DEP_TAF_DEPOSITO_FGTS]   	+ aArqBase[nI,2,1,HASH_BASE_DEP_TAF_DEPOSITO_FGTS_13_SALARIO]
				nFGTSDePGov := aArqBase[nI,2,1,HASH_BASE_DEP_GOVERNO_DEPOSITO_FGTS] + aArqBase[nI,2,1,HASH_BASE_DEP_GOVERNO_DEPOSITO_FGTS_13_SALARIO]


				If  (nFGTSTAF == nFGTSGov .and. nFGTSOri == nFGTSGov ) .And. (nFGTSDepTAF == nFGTSDePGov .and. nFGTSDepOri == nFGTSDePGov )
					aArqBase[nI,2,1,HASH_BASE_SEM_DIVERGENCIAS] := .T.
					IIF(!lVer2_5,nCountBase++,)
					Loop
				EndIf
			Else 

				nFGTSOri := aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS]   + aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]
				nFGTSTAF := aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS]   	 + aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS_RESCISORIO]
				nFGTSGov := aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS] + aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO] 

				If !lVer2_5
					nFGTSDepOri := aArqBase[nI,2,1,HASH_BASE_DEP_FOLHA_DEPOSITO_FGTS]    + aArqBase[nI,2,1,HASH_BASE_DEP_FOLHA_DEPOSITO_FGTS_RESCISORIO]
					nFGTSDepTAF := aArqBase[nI,2,1,HASH_BASE_DEP_TAF_DEPOSITO_FGTS]   	 + aArqBase[nI,2,1,HASH_BASE_DEP_TAF_DEPOSITO_FGTS_RESCISORIO]
					nFGTSDePGov := aArqBase[nI,2,1,HASH_BASE_DEP_GOVERNO_DEPOSITO_FGTS]  + aArqBase[nI,2,1,HASH_BASE_DEP_GOVERNO_DEPOSITO_FGTS_RESCISORIO]
				EndIF
				
				If nFGTSTAF == nFGTSGov .and. nFGTSOri == nFGTSGov 
					aArqBase[nI,2,1,HASH_BASE_SEM_DIVERGENCIAS] := .T.
					IIF(!lVer2_5,nCountBase++,)
					Loop
				EndIf

			EndIf
		EndIf

	

		If aArqBase[nI,2,1,HASH_BASE_EVENTO_ESOCIAL] == "S-1200"
			cEvtDesc := "Remuneração ( S-1200 )"
		ElseIf aArqBase[nI,2,1,HASH_BASE_EVENTO_ESOCIAL] == "S-2299"
			cEvtDesc := "Desligamento ( S-2299 )"
		ElseIf aArqBase[nI,2,1,HASH_BASE_EVENTO_ESOCIAL] == "S-2399"
			cEvtDesc := "Término TSV ( S-2399 )"
		EndIf

		If Empty( aArqBase[nI,2,1,HASH_BASE_RECIBO_TRANSMISSAO] )
			cStatusGov := "Não Transmitido"
		ElseIf !(aArqBase[nI,2,1,HASH_BASE_GOVERNO_LOCALIZADO] .Or. aArqBase[nI,2,1,HASH_BASE_DEP_GOVERNO_LOCALIZADO])
			cStatusGov := "Não Localizado"
		Else
			cStatusGov := ""
		EndIf

		If !lVer2_5
			oExcel:AddRow(	cAba,;
			cTabela,;
			{	aArqBase[nI,2,1,HASH_BASE_ESTABELECIMENTO],;
			aArqBase[nI,2,1,HASH_BASE_LOTACAO],;
			aArqBase[nI,2,1,HASH_BASE_CPF],;
			aArqBase[nI,2,1,HASH_BASE_NOME],;
			aArqBase[nI,2,1,HASH_BASE_MATRICULA],;
			aArqBase[nI,2,1,HASH_BASE_CATEGORIA],;
			cEvtDesc,;
			aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS],;
			aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS],;
			Iif( Empty( cStatusGov ), aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS], cStatusGov ),;
			aArqBase[nI,2,1,HASH_BASE_DEP_FOLHA_DEPOSITO_FGTS],;
			aArqBase[nI,2,1,HASH_BASE_DEP_TAF_DEPOSITO_FGTS],;
			Iif( Empty( cStatusGov ), aArqBase[nI,2,1,HASH_BASE_DEP_GOVERNO_DEPOSITO_FGTS], cStatusGov ),;
			aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO],;
			aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS_13_SALARIO],;
			Iif( Empty( cStatusGov ), aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO], cStatusGov ),;
			aArqBase[nI,2,1,HASH_BASE_DEP_FOLHA_DEPOSITO_FGTS_13_SALARIO],;
			aArqBase[nI,2,1,HASH_BASE_DEP_TAF_DEPOSITO_FGTS_13_SALARIO],;
			Iif( Empty( cStatusGov ), aArqBase[nI,2,1,HASH_BASE_DEP_GOVERNO_DEPOSITO_FGTS_13_SALARIO], cStatusGov ),;
			aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO],;
			aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS_RESCISORIO],;
			Iif( Empty( cStatusGov ), aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO], cStatusGov ),;
			aArqBase[nI,2,1,HASH_BASE_DEP_FOLHA_DEPOSITO_FGTS_RESCISORIO],;
			aArqBase[nI,2,1,HASH_BASE_DEP_TAF_DEPOSITO_FGTS_RESCISORIO],;
			Iif( Empty( cStatusGov ), aArqBase[nI,2,1,HASH_BASE_DEP_GOVERNO_DEPOSITO_FGTS_RESCISORIO], cStatusGov ) } )
		Else 
			oExcel:AddRow(	cAba,;
			cTabela,;
			{	aArqBase[nI,2,1,HASH_BASE_ESTABELECIMENTO],;
			aArqBase[nI,2,1,HASH_BASE_LOTACAO],;
			aArqBase[nI,2,1,HASH_BASE_CPF],;
			aArqBase[nI,2,1,HASH_BASE_NOME],;
			aArqBase[nI,2,1,HASH_BASE_MATRICULA],;
			aArqBase[nI,2,1,HASH_BASE_CATEGORIA],;
			cEvtDesc,;
			aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS],;
			aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS],;
			Iif( Empty( cStatusGov ), aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS], cStatusGov ),;
			aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO],;
			aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS_13_SALARIO],;
			Iif( Empty( cStatusGov ), aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO], cStatusGov ),;
			aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO],;
			aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS_RESCISORIO],;
			Iif( Empty( cStatusGov ), aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO], cStatusGov )} )

		EndIf


		SetIncPerc( oRunProc, "Print", nQtdTotal, nI )

	Next nI
	
	aSort( aArqDepo,,, { |x,y| x[2,1,HASH_DEPOSITO_EVENTO_ESOCIAL] + x[2,1,HASH_DEPOSITO_NOME] < y[2,1,HASH_DEPOSITO_EVENTO_ESOCIAL] 	+ y[2,1,HASH_DEPOSITO_NOME] } )

	IF lVer2_5 
		For nI := 1 to Len( aArqDepo )

			If nI == 1

				cAba := "Deposito"

				If Len( AllTrim( cPeriodo ) ) == 4 //Décimo Terceiro
					cTabela := "Periodo_" + cPeriodo
				Else
					cTabela := "Periodo_" + SubStr( cPeriodo, 5, 2 ) + "/" + SubStr( cPeriodo, 1, 4 )
				EndIf

				oExcel:AddWorkSheet( cAba )
				oExcel:AddTable( cAba, cTabela )

				oExcel:AddColumn( cAba, cTabela, "CPF", 1, 1, .F. )
				oExcel:AddColumn( cAba, cTabela, "Nome", 1, 1, .F. )
				oExcel:AddColumn( cAba, cTabela, "Matrícula", 1, 1, .F. )
				oExcel:AddColumn( cAba, cTabela, "Categoria", 1, 1, .F. )
				oExcel:AddColumn( cAba, cTabela, "Evento eSocial", 1, 1, .F. )

				oExcel:AddColumn( cAba, cTabela, "Folha - Depósito FGTS", 1, 3, .T. )
				oExcel:AddColumn( cAba, cTabela, "TAF - Depósito FGTS", 1, 3, .T. )
				oExcel:AddColumn( cAba, cTabela, "Governo - Depósito FGTS", 1, 3, .T. )

				oExcel:AddColumn( cAba, cTabela, "Folha - Depósito FGTS - 13° Salário", 1, 3, .T. )
				oExcel:AddColumn( cAba, cTabela, "TAF - Depósito FGTS - 13° Salário", 1, 3, .T. )
				oExcel:AddColumn( cAba, cTabela, "Governo - Depósito FGTS - 13° Salário", 1, 3, .T. )

				oExcel:AddColumn( cAba, cTabela, "Folha - Depósito FGTS - Rescisório", 1, 3, .T. )
				oExcel:AddColumn( cAba, cTabela, "TAF - Depósito FGTS - Rescisório", 1, 3, .T. )
				oExcel:AddColumn( cAba, cTabela, "Governo - Depósito FGTS - Rescisório", 1, 3, .T. )

			EndIf

			If lDiverg

				If aArqDepo[nI,2,1,HASH_DEPOSITO_EVENTO_ESOCIAL] == 'S-1200'
					nFGTSOri := aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]   + aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]
					nFGTSTAF := aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS]   	 + aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO]
					nFGTSGov := aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS] + aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO] 

					If  nFGTSTAF == nFGTSGov .and. nFGTSOri == nFGTSGov
						aArqDepo[nI,2,1,HASH_DEPOSITO_SEM_DIVERGENCIAS] := .T.
						nCount++
						Loop
					EndIf
				Else 
					nFGTSOri := aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]   + aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]
					nFGTSTAF :=	aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS]   	 + aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO]
					nFGTSGov :=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS] + aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]
				
					If nFGTSTAF == nFGTSGov .and. nFGTSOri == nFGTSGov  
						aArqDepo[nI,2,1,HASH_DEPOSITO_SEM_DIVERGENCIAS] := .T.
						nCount++
						Loop
					EndIf

				EndIf

			EndIf

			If aArqDepo[nI,2,1,HASH_DEPOSITO_EVENTO_ESOCIAL] == "S-1200"
				cEvtDesc := "Remuneração ( S-1200 )"
			ElseIf aArqDepo[nI,2,1,HASH_DEPOSITO_EVENTO_ESOCIAL] == "S-2299"
				cEvtDesc := "Desligamento ( S-2299 )"
			ElseIf aArqDepo[nI,2,1,HASH_DEPOSITO_EVENTO_ESOCIAL] == "S-2399"
				cEvtDesc := "Término TSV ( S-2399 )"
			EndIf

			If Empty( aArqDepo[nI,2,1,HASH_DEPOSITO_RECIBO_TRANSMISSAO] )
				cStatusGov := "Não Transmitido"
			ElseIf !aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_LOCALIZADO]
				cStatusGov := "Não Localizado"
			Else
				cStatusGov := ""
			EndIf

			oExcel:AddRow(	cAba,;
				cTabela,;
				{	aArqDepo[nI,2,1,HASH_DEPOSITO_CPF],;
				aArqDepo[nI,2,1,HASH_DEPOSITO_NOME],;
				aArqDepo[nI,2,1,HASH_DEPOSITO_MATRICULA],;
				aArqDepo[nI,2,1,HASH_DEPOSITO_CATEGORIA],;
				cEvtDesc,;
				aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS],;
				aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS],;
				Iif( Empty( cStatusGov ), aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS], cStatusGov ),;
				aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO],;
				aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO],;
				Iif( Empty( cStatusGov ), aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO], cStatusGov ),;
				aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO],;
				aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO],;
				Iif( Empty( cStatusGov ), aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO], cStatusGov ) } )

			SetIncPerc( oRunProc, "Print", nQtdTotal, nI )
		Next nI

	EndIf

	If lDiverg .and. nCount == Len(aArqDepo)
		MSGALERT( "Não há registros divergentes", "Atenção" )
	Elseif !lVer2_5 .and. lDiverg .and. nCountBase  == Len(aArqBase)
		MSGALERT( "Não há registros divergentes", "Atenção" )

	ElseIf !Empty( oExcel:aWorkSheet )

		oExcel:Activate()
		oExcel:GetXMLFile( cArquivo )

		__CopyFile( cDefPath + cArquivo, cPath + cArquivo )

		If GetRemoteType() ==  5 // WebAPP

			nRet := CpyS2TW( cDefPath + cArquivo , .T. )

			If (nRet == 0)
				MsgAlert("Download concluído com sucesso.") //	"Download concluído com sucesso."
			Else
				TAFConOut("Falha na copia" + str(nRet)) // "Falha na copia"
			EndIf

		Else

			ApOleClient( "MSExcel" )
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open( cPath + cArquivo ) //Abre a planilha
			oExcelApp:SetVisible( .T. )

		EndIf

	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} SetIncPerc
@type			function
@description	Incrementa o progresso realizado.
@author			Felipe C. Seolin
@since			18/06/2019
@version		1.0
@param			oRunProc	-	Objeto do FWMsgRun
@param			cEtapa		-	Etapa em curso de execução
@param			nQtdTotal	-	Quantidade total de registros a processar
@param			nQtdProc	-	Quantidade de registros processados
/*/
//---------------------------------------------------------------------
Static Function SetIncPerc( oRunProc, cEtapa, nQtdTotal, nQtdProc )

	Local cMessage	:=	""
	Local cPercent	:=	cValToChar( Int( ( nQtdProc / nQtdTotal ) * 100 ) )

	If cEtapa == "S-1200"
		cMessage := I18N( "#1 - #2 - #3 #4 - Progresso: #5%", { "Etapa 1/4", "Consultando", "Evento", "Folha", cPercent } )
	ElseIf cEtapa == "S-2299"
		cMessage := I18N( "#1 - #2 - #3 #4 - Progresso: #5%", { "Etapa 2/4", "Consultando", "Evento", "Desligamento", cPercent } )
	ElseIf cEtapa == "S-2399"
		cMessage := I18N( "#1 - #2 - #3 #4 - Progresso: #5%", { "Etapa 3/4", "Consultando", "Evento", "Término TSV", cPercent } )
	ElseIf cEtapa == "Print"
		cMessage := I18N( "#1 - #2 - Progresso: #3%", { "Etapa 4/4", "Extraindo dados para o relatório", cPercent } )
	EndIf

	oRunProc:cCaption := cMessage
	ProcessMessages()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} InitBase
@type			function
@description	Construtor do array de Base de Cálculo do FGTS.
@author			Felipe C. Seolin
@since			19/06/2019
@version		1.0
@return			aInit	-	Array para operação da Base de Cálculo do FGTS
/*/
//---------------------------------------------------------------------
Static Function InitBase()

	Local aInit	:=	Array( 29 )

	aInit[HASH_BASE_RECIBO_TRANSMISSAO]						:= ""
	aInit[HASH_BASE_ESTABELECIMENTO]						:= ""
	aInit[HASH_BASE_CPF]									:= ""
	aInit[HASH_BASE_NOME]									:= ""
	aInit[HASH_BASE_MATRICULA]								:= ""
	aInit[HASH_BASE_CATEGORIA]								:= ""
	aInit[HASH_BASE_LOTACAO]								:= ""
	aInit[HASH_BASE_EVENTO_ESOCIAL]							:= 0
	aInit[HASH_BASE_FOLHA_BASE_FGTS]						:= 0
	aInit[HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]				:= 0
	aInit[HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]				:= 0
	aInit[HASH_BASE_TAF_BASE_FGTS]							:= 0
	aInit[HASH_BASE_TAF_BASE_FGTS_13_SALARIO]				:= 0
	aInit[HASH_BASE_TAF_BASE_FGTS_RESCISORIO]				:= 0
	aInit[HASH_BASE_GOVERNO_BASE_FGTS]						:= 0
	aInit[HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]			:= 0
	aInit[HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]			:= 0
	aInit[HASH_BASE_GOVERNO_LOCALIZADO]						:= .F.
	aInit[HASH_BASE_SEM_DIVERGENCIAS] 						:= .F.		
	aInit[HASH_BASE_DEP_FOLHA_DEPOSITO_FGTS]				:= 0
	aInit[HASH_BASE_DEP_FOLHA_DEPOSITO_FGTS_13_SALARIO]		:= 0
	aInit[HASH_BASE_DEP_FOLHA_DEPOSITO_FGTS_RESCISORIO] 	:= 0
	aInit[HASH_BASE_DEP_TAF_DEPOSITO_FGTS]				 	:= 0
	aInit[HASH_BASE_DEP_TAF_DEPOSITO_FGTS_13_SALARIO]	 	:= 0
	aInit[HASH_BASE_DEP_TAF_DEPOSITO_FGTS_RESCISORIO]	 	:= 0
	aInit[HASH_BASE_DEP_GOVERNO_DEPOSITO_FGTS]			 	:= 0
	aInit[HASH_BASE_DEP_GOVERNO_DEPOSITO_FGTS_13_SALARIO]	:= 0
	aInit[HASH_BASE_DEP_GOVERNO_DEPOSITO_FGTS_RESCISORIO]	:= 0
	aInit[HASH_BASE_DEP_GOVERNO_LOCALIZADO]			  		:= .F.

Return( aInit )

//---------------------------------------------------------------------
/*/{Protheus.doc} InitDeposito
@type			function
@description	Construtor do array de Depósito do FGTS.
@author			Felipe C. Seolin
@since			19/06/2019
@version		1.0
@return			aInit	-	Array para operação da Depósito do FGTS
/*/
//---------------------------------------------------------------------
Static Function InitDeposito()

	Local aInit	:=	Array( 17 )

	aInit[HASH_DEPOSITO_RECIBO_TRANSMISSAO]					:=	""
	aInit[HASH_DEPOSITO_CPF]								:=	""
	aInit[HASH_DEPOSITO_NOME]								:=	""
	aInit[HASH_DEPOSITO_MATRICULA]							:=	""
	aInit[HASH_DEPOSITO_CATEGORIA]							:=	""
	aInit[HASH_DEPOSITO_EVENTO_ESOCIAL]						:=	0
	aInit[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]				:=	0
	aInit[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]		:=	0
	aInit[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]		:=	0
	aInit[HASH_DEPOSITO_TAF_DEPOSITO_FGTS]					:=	0
	aInit[HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO]		:=	0
	aInit[HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO]		:=	0
	aInit[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]				:=	0
	aInit[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]	:=	0
	aInit[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]	:=	0
	aInit[HASH_DEPOSITO_GOVERNO_LOCALIZADO]					:=	.F.
	aInit[HASH_DEPOSITO_SEM_DIVERGENCIAS] 					:=	.F.

Return( aInit )

//---------------------------------------------------------------------
/*/{Protheus.doc} R124Valid
@type			function
@description	Validação dos parâmetros informados.
@author			Felipe C. Seolin
@since			08/08/2019
@version		1.0
@param			cCampo	-	Campo executor da validação
@return			lRet	-	Indicador de operação válida/inválida
/*/
//---------------------------------------------------------------------
Function R124Valid( cCampo )

	Local cMes		:=	""
	Local cAno		:=	""
	Local cPeriodo	:=	""
	Local lRet		:=	.T.

	If cCampo == "MV_PAR01" .and. !Empty( MV_PAR01 )

		cPeriodo := MV_PAR01

		If Len( AllTrim( cPeriodo ) ) == 4 .And. Val( AllTrim( cPeriodo ) ) < 2019 //Décimo Terceiro

			lRet := .F.
			Help( ,, "Atenção",, "Período informado é anterior ao início do evento S-5003 do eSocial.", 1, 0 )

		ElseIf Len( AllTrim( cPeriodo ) ) == 6

			cMes := SubStr( MV_PAR01, 1, 2 )
			cAno := SubStr( MV_PAR01, 3, 4 )

			If Val( cMes ) > 12 .or. Val( cMes ) <= 0
				lRet := .F.
				Help( ,, "Atenção",, "Mês informado inválido.", 1, 0 )
			ElseIf Val( cAno ) < 2019
				lRet := .F.
				Help( ,, "Atenção",, "Período informado é anterior ao início do evento S-5003 do eSocial.", 1, 0 )
			EndIf
			
		EndIf

	ElseIf cCampo == "MV_PAR02" .and. !Empty( MV_PAR02 )

		If !( cValToChar( MV_PAR02 ) $ "1|2" )
			lRet := .F.
			Help( ,, "Atenção",, "A opção selecionada é inválida.", 1, 0 )
		EndIf

	ElseIf cCampo == "MV_PAR04" .and. !Empty( MV_PAR04 )

		lRet := CGC( MV_PAR04 )

	EndIf

Return( lRet )
