#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM026.CH"

Static lXmlVerbas	:= Val(SuperGetMv("MV_FASESOC",,'2')) == 2
Static nContRes		:= 0
Static lParcial		:= .F.
Static lVerRJ5 		:= FindFunction("fVldObraRJ") .And. (fVldObraRJ(@lParcial, .F.) .And. !lParcial)
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

/*/{Protheus.doc} GPEM026E
@Author   Christiane Vieira
@Since    13/11/2015
@Version  1.0
@Obs      Migrado do GPEM026A em 29/04/2020 para gerar o evento S-2399
/*/
Function GPEM026E()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  fInt2399New ºAutor ³Marcos Coutinho Araujo º Data ³ 27/06/17 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Registro Admissao Trab sem Vinculo                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM026-                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fInt2399New( oModel, aErros, cReg, cCodDslg, cTpRes, aPd, dDataRes, cDiaInde, cVersEnvio, nOpc, lResComp, lRetif )

	Local aArea 		:= GetArea()
	Local aAreaCTT 		:= {} //Centro de Custo
	Local aAreaSRV 		:= {} //Verbas
	Local aAreaRAZ 		:= {} //Multiplos Vinculos
	Local aCols040		:= {}
	Local aFilInTaf 	:= {}
	Local aArrayFil 	:= {}
	Local cFilEnv 		:= ""
	Local cXml 			:= ""
	Local lGravou 		:= .T.
	Local cCatEFD
	Local cIdDmDev    	:= ""
	Local aIdDmDev    	:= {}

	Local nI 			:= 0
	Local nY 			:= 0
	Local aErros 		:= {}
	Local aCodBenef 	:= {}
	Local nPerPens		:= 0
	Local aCC 			:= fGM23CTT()
	Local cTpInscr		:= ""
	Local cTpInsc		:= ""
	Local cInscr 		:= ""
	Local nPosEstb		:= 0
	Local lSemFilCTT 	:= .F.
	Local lSemFilRJ5 	:= .F.
	Local lSemFilSRV 	:= .F.
	Local nPosPd 		:= 0
	Local nPosValor 	:= 0
	Local nPosHoras 	:= 0
	Local cIntegra 		:= ""
	Local aASO 			:= {}
	Local cSimples 		:= ""
	Local cIndSimp 		:= ""
	Local nValor 		:= 0
	Local nPensao		:= 0
	Local dDtProj 		:= ""
	Local cNrInsc		:= 0
	Local cTpLot		:= ""
	Local lRet 			:= .T.
	Local nPosPd
	Local nPosValor
	Local nPosHoras
	Local aDadosRAZ 	:= {}
	Local aDadosCCT 	:= {}
	Local aDadosRHR 	:= {}
	Local cCodLot 		:= ""
	Local cCodRubr		:= ""
	Local cIdeRubr		:= ""
	Local cIdTabRub		:= ""
	Local cPrcrubr		:= ""
	Local cCEIObra      := ''
	Local cCAEPF		:= ''
	Local lGeraCod		:= .F.
	Local lPrimIdT		:= .T.
	Local nZ 			:= 0
	Local nX 			:= 0
	Local nW 			:= 0
	Local nY			:= 0
	Local nContDev     	:= 0
	Local cErroXERP		:= ""
	Local oModelSRG		:= NIL
	Local oGrid			:= NIL

	Local aAreaRCH		:= {}
	Local cProcess		:= ""
	Local cPeriodo		:= ""
	Local cNumPag		:= ""
	Local aDadosRHST 	:= {}
	Local aDadosRHSD 	:= {}
	Local cBolsistas    := fCatTrabEFD("BOL") //'901|902|903|904|905|'
	Local cContrib      := '701|711|712|721|722|723|731|734|738|741|751|761|771|781'
	Local lCarrDep		:= .F.
	Local lGerPla		:= .F.
	Local cVBDiss		:= ""
	Local cVbPla		:= ""
	Local cCCAnt		:= ""
	Local cTafKey		:= Nil

	Local cFncSemVer	:= "GPEA010|GPEA265|GPEA011"

	Local aAdiCC		:= {}
	Local aAdiCols		:= {}
	Local a131CC		:= {}
	Local a131Cols		:= {}
	Local aCols			:= {}
	Local aFolCC		:= {}
	Local aFolCols		:= {}

	Local lCPFDepOk		:= .T.
	Local aDepAgreg		:= {}

	Local aErrosRJ5		:= {}
	Local aRelacRJ5		:= {}
	Local cMsgErro		:= ""
	Local cTipoPLA		:= fGetCalcRot('C')

	Local cBkpFil	 	:= cFilAnt
	Local cEFDAviso		:= Alltrim(FSubst(If(cPaisLoc == 'BRA' .And. Findfunction("fEFDAviso"), fEFDAviso(), SuperGetMv("MV_EFDAVIS",, "0")))) //Integracao com TAF)
	Local cVersMw	 	:= ""
	Local cXml		 	:= ""
	Local cMsg		 	:= ""
	Local cMsgErro	 	:= ""
	Local cVersMid	 	:= ""
	Local cChave	 	:= ""
	Local cChaveS1005	:= ""
	Local cStatus	 	:= "-1"
	Local cMsgHlp	 	:= ""
	Local cMsgRJE	 	:= ""
	Local cIni 		 	:= Space(6)
	Local lAdmPubl	 	:= .F.
	Local aInfos	 	:= {}
	Local aDados	 	:= {}
	Local cFilEmp	 	:= ""
	Local dDtGer	 	:= Date()
	Local cHrGer	 	:= Time()
	Local lRet		 	:= .T.
	Local cRetfNew	 	:= ""
	Local cOperNew 	 	:= ""
	Local cStatRJE	 	:= "-1"
	Local cOper2399	 	:= "I"
	Local cRecib2399 	:= ""
	Local cRecibAnt  	:= ""
	Local cRecibXML  	:= ""
	Local cRetf2399	 	:= "1"
	Local cStat2399	 	:= "-1"
	Local nRec2399   	:= 0
	Local cRetfNew	 	:= ""
	Local cStatNew	 	:= ""
	Local lNovoRJE	 	:= .F.
	Local lS1000 	 	:= .T.
	Local lS1005 	 	:= .T.
	Local lS1010 	 	:= .T.
	Local lS1020 	 	:= .T.
	Local lPredess 	 	:= .T.
	Local nCont			:= 0
	Local aErrosExc		:= {}
	Local lRJ5FilT 		:= RJ5->(ColumnPos("RJ5_FILT")) > 0
	Local lTemReg		:= .F.
	Local cCodNat		:= ""
	Local cCodINCCP		:= ""
	Local cCodINFGTS	:= ""
	Local cContrib1     := '701|711|712|721|722|723|731|734|738|741|751|761|781'
	Local cCodINCIRF	:= ""
	Local lGeraMat		:= SRA->(ColumnPos("RA_DESCEP")) > 0 .And. SRA->RA_DESCEP == "1"
	Local dDtCgini		:= SuperGetMV("MV_DTCGINI", Nil, dDataBase )
	Local lRVIncop		:= SRV->(ColumnPos("RV_INCOP"))> 0 .And. cVersEnvio >= "9.0"
	Local lRVTetop 		:= SRV->(ColumnPos("RV_TETOP"))> 0 .And. cVersEnvio >= "9.0"

	Private aEstb 		:= fGM23SM0(.T.,.T.)
	Private bEstab 		:= {|| aScan(aEstb, {|x| x[1] == ALLTRIM(SRA->RA_FILIAL)})}
	Private cGpeAmbe	:= ""

	Default cReg 		:= "S2399"
	Default cTpRes		:= "1"
	Default cVersEnvio	:= "2.2"
	Default nOpc 		:= 3
	Default oModel		:= Nil
	Default lResComp	:= .F.
	Default lRetif		:= .F.

	If oModel != Nil .And. cTpRes == "1"
		nOpc 	:= oModel:GetOperation()
	EndIf

	//Quando vier dos cadastros "GPEA010|GPEA265|GPEA011"
	If (FunName() $ cFncSemVer) .And. cVersEnvio >= "9.0"
		If dDataBase > (M->RA_DEMISSA + 10)
			Help( ,, OemToAnsi(STR0001) ,, OemToAnsi("S-2399 - " + STR0041), 1, 0 )//##"Atencao."##"O prazo de envio deste evento foi ultrapassado. Passível de multa"
		EndIf
	EndIf

	Begin Transaction
		//----------------------------------------------------
		//| Tipo Rescisao Simples ou vinda da GPEA010/GPEA265
		//| Caso a chamada da funcao tenha vindo da GPEM040()
		//----------------------------------------------------
		If( cTpRes == "1" ) .And. nOpc != 5
			If  !(IsInCallStack("GPEA010") .OR. IsInCallStack("GPEA265")) .And. oModel != NIL
				oGrid 		:= oModel:GetModel('GPEM040_MGET')
				oModelSRG	:= oModel:GetModel('GPEM040_MSRG')
			EndIf

			If !lMiddleware
				fGp23Cons(@aFilInTaf, {SRA->RA_FILIAL}, @cFilEnv)
				cStat2399 := TAFGetStat( "S-2399", AllTrim(SRA->RA_CIC) + ";" + Space(Len(SRA->RA_CODUNIC)) + ";" + "1", , SRA->RA_FILIAL )
				If cStat2399 == "6"
					//"Atenção"##"Operação não será realizada pois há evento de exclusão pendente para transmissão"
					//"Verifique o status do evento S-3000 e tente novamente."
					Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0146), 1, 0, , , , , , {OemToAnsi(STR0326)}) 
					DisarmTransaction()
					Return .F.
				EndIf

			EndIf

			If Empty(cFilEnv)
				cFilEnv:= cFilAnt
			EndIf

			If cVersEnvio >= '2.3'
				If (IsInCallStack("GPEA010") .OR. IsInCallStack("GPEA265"))
					cIdDmDev := "R" + cEmpAnt + Alltrim(xFilial("SRA")) + SRA->RA_MAT
				Else
					cIdDmDev := "R" + cEmpAnt + Alltrim(xFilial("SRG")) + SRA->RA_MAT
				EndIf
			EndIf

			//----------------
			//| Evento S-2399
			//| Inicio da geracao do evento de desligamento
			//----------------------------------------------
			If !Empty(cFilEnv)

				If lMiddleware
					fVersEsoc( "S2399", .T., /*aRetGPE*/, /*aRetTAF*/, , , @cVersMw , ,@cGpeAmbe  )
					fPosFil( cEmpAnt, SRA->RA_FILIAL )
					lS1000 := fVld1000( AnoMes(If( FunName() $ cFncSemVer, M->RA_DEMISSA, M->RG_DATADEM) ), @cStatus )
					If !lS1000 .And. cEFDAviso != "2"
						Do Case
							Case cStatus == "-1" // nao encontrado na base de dados
								If cEFDAviso == "1"
									Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130), 1, 0 )//"Registro do evento X-XXXX não localizado na base de dados"
									Return .F.
								Else
									MsgInfo( OemToAnsi(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130)), OemToAnsi(STR0001))//"Atenção""Registro do evento X-XXXX não localizado na base de dados"
								EndIf
							Case cStatus == "1" // nao enviado para o governo
								If cEFDAviso == "1"
									Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131), 1, 0 )//"Registro do evento X-XXXX não transmitido para o governo"
									Return .F.
								Else
									MsgInfo( OemToAnsi(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131)), OemToAnsi(STR0001))//"Atenção""Registro do evento X-XXXX não transmitido para o governo"
								EndIf
							Case cStatus == "2" // enviado e aguardando retorno do governo
								If cEFDAviso == "1"
									Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132), 1, 0 )//"Registro do evento X-XXXX aguardando retorno do governo"
									Return .F.
								Else
									MsgInfo( OemToAnsi(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132)), OemToAnsi(STR0001))//"Atenção""Registro do evento X-XXXX aguardando retorno do governo"
								EndIf
							Case cStatus == "3" // enviado e retornado com erro
								If cEFDAviso == "1"
									Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133), 1, 0 )//"Registro do evento X-XXXX retornado com erro do governo"
									Return .F.
								Else
									MsgInfo( OemToAnsi(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133)), OemToAnsi(STR0001))//"Atenção""Registro do evento X-XXXX retornado com erro do governo"
								EndIf
						EndCase
					EndIf
				EndIf

				//-----------------------------
				//| Varrendo o grid das verbas
				//| Looping para centralizar dentro do aCols as rubricas iguais
				//| Quando função diferente de GÈA010 e GPEA265
				//--------------------------------------------------------------
				If !( FunName() $ cFncSemVer ) .And. lXmlVerbas

					//------------------------
					//| Verificacao de Filial
					//| Verificar o compartilhamento das tabelas CTT e SRV
					//--------------------------------------------------------------
					If Empty(xFilial("CTT")) //CTT compartilhada
						lSemFilCTT := .T.
					EndIf

					If !lMiddleware
						cTafKey := "S2399" + oModelSRG:GetValue("RG_PERIODO") + SRA->RA_CIC + SRA->RA_CODUNIC
					EndIf

					For nI := 1 To oGrid:Length()
						If oGrid:isDeleted(nI)
							Loop
						EndIf
						oGrid:GoLine(nI)

						//--------------------------------
						//| Montagem da chave de pesquisa
						//| Realiza a montagem da chave de auxilio para localizar registro
						//-----------------------------------------------------------------
						cChaveCCPD	:= oGrid:GetValue("RR_CC") + oGrid:GetValue("RR_PD")
						cChaveCC	:= oGrid:GetValue("RR_CC")
						lTemReg		:= .F.

						nPosCCPD	:= Ascan( @aCols040,{|X| X[1] == cChaveCCPD })
						nPosCC		:= Ascan( @aCols040,{|X| X[12] == cChaveCC })

						cCodNat 	:= RetValSrv( oGrid:GetValue("RR_PD"), xFilial("SRA"), "RV_NATUREZ" )
						cCodINCCP 	:= RetValSrv( oGrid:GetValue("RR_PD"), xFilial("SRA"), 'RV_INCCP' )
						cCodINCIRF  := RetValSrv( oGrid:GetValue("RR_PD"), xFilial("SRA"), 'RV_INCIRF' )
						cCodINFGTS  := RetValSrv( oGrid:GetValue("RR_PD"), xFilial("SRA"), 'RV_INCFGTS' )

						If cVersEnvio >= '2.3'
							If (SRA->RA_CATEFD $ cBolsistas + cContrib) .AND. ( cCodNat $ "1409|4050|4051|1009" )
								Loop
							EndIf
						EndIf

						If 	((SRA->RA_CATEFD $  cContrib1) .And. (cCodINCCP  $ '12|21|22|32|51|92|93|94' ) ) .Or.;						 //13o Salario, Maternidade, Sal.Fam
							 ((SRA->RA_CATEFD $  cContrib1) .And. (cCodINCIRF  $ '12|13|32|33|42|43|47|52|53|62|63|64|71|92|93')) .Or.;  //Eventos de Ferias e 13o Salario
							 (!(SRA->RA_CATEFD $ '711|712|734') .And. (cCodINCCP  $ '34|35')) .Or.;										 //SEST/SENAT
							 ((SRA->RA_CATEFD $ '701|711|712|741|751|781') .And. (cCodINCIRF  $ '14|34|54|94'))   						  //Eventos de PLR
							Loop
						EndIf

					 	If (SRA->RA_CATEFD $ cBolsistas) .And. (!(cCodINCCP  $ '00|01') .Or. cCodINFGTS  <> '00')
						 	Loop
						Endif

						//----------------------------------
						//| Centro de Custo x Verba/Rubrica
						//| Realiza o filtro para saber se a verba incide IRRF
						//| Seleciona a Verba dentro do SRA e pega seus respectivos dados
						//| Seleciona o CC    dentro da CTT e pega seus respectivos dados
						//----------------------------------------------------------------
						If ( ( cVersEnvio < "2.6.00" .And. !(SubStr(RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_INCIRF" ), 1, 2) $ "31*32*33*34*35*51*52*53*54*55*81*82*83") ) .Or.;
							( cVersEnvio >= "2.6.00" .And. !(fRetTpIRF( RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_INCIRF" ) ) $ "D|I|J") ) ) .And.;
							!(RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_CODFOL" ) $ "0126|0303")
							//--------------------
							//| Verbas / Rubricas
							//| Guarda a area atual, entra na SRV e recupera os dados da verba
							//------------------------------------------------------------------
							aAreaSRV := GetArea()
							DBSelectArea("SRV")
							SRV->(DbSetOrder(1))
							If( SRV->( dbSeek( xFilial("SRV") + oGrid:GetValue("RR_PD") ) ) )

								//Tratamento de compartilhamento da tabela SRV
								If !Empty(xFilial("SRV"))
									lGeraCod := .T.
								Else
									lSemFilSRV := .T.
								EndIf

								//------------------
								//| Lógica lGeraCod
								//| .T. -> Exclusiva | .F. -> Compartilhada
								//------------------------------------------
								If lGeraCod
									cIdeRubr := Iif(!Empty(SRV->RV_FILIAL),SRV->RV_FILIAL , (xFilial("SRV"),SRV->RV_FILIAL) )
								Else
									If cVersEnvio >= "2.3"
										cIdeRubr := cEmpAnt
									Else
										cIdeRubr := ""
									EndIf
								Endif

								If lMiddleware
									If lPrimIdT
										lPrimIdT  := .F.
										cIdTabRub := fGetIdRJF( Iif(!Empty(SRV->RV_FILIAL), SRV->RV_FILIAL, (xFilial("SRV"), SRV->RV_FILIAL) ), cIdeRubr )
										If Empty(cIdTabRub)
											Help(,,,OemToAnsi(STR0001), OemToAnsi(STR0140) + cIdeRubr + OemToAnsi(STR0141),1,0) //"Atenção"##"Não será possível efetuar a integração. O identificador de tabela de rubrica do código: "##" não está cadastrado."
											Return .F.
										EndIf
									EndIf
									cIdeRubr := cIdTabRub
								EndIf

								cCodRubr := SRV->RV_COD		//Codigo  da Rubrica
								If (SRV->RV_PERC - 100) < 0
									cPrcRubr :=	0	//Percent da Rubrica
								Else
									cPrcRubr := SRV->RV_PERC - 100//Percent da Rubrica
								EndIf

								//----------------------------------------
								//| Recuperar a natureza da verba
								//| Se estiverem vazias, vão para a geração do log
								//-------------------------------------------------
								If Empty( SRV->RV_NATUREZ )
									If( Len(aErros) == 0 )
										aAdd(aErros, OemToAnsi( STR0054 ))
									EndIf
									aAdd(aErros, SRV->RV_COD + " - " + AllTrim( SRV->RV_DESC ) )
								ElseIf ((cVersEnvio < '2.6.00' .And. SRV->RV_NATUREZ == "9219") .Or. cVersEnvio >= '2.6.00') .And. !lCarrDep
									//-----------------
									//| Plano de Saude
									//| Se a verba corrente tiver natureza de rubrica '9219' de plano de saude
									//| Entra na tabela RHR - Plano de Saude, localiza o registro do funcionário
									//| Verifica se o registro foi integrado com a folha, se sim: alimenta array
									//---------------------------------------------------------------------------
									aAreaRCH := GetArea()
									DbSelectArea("RCH")
									RCH->( dbsetOrder( Retorder( "RCH" , "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG" ) ) )
									cProcess  := oGrid:GetValue("RR_PROCES")
									cPeriodo := oModelSRG:GetValue("RG_PERIODO")
									cNumPag  := oModelSRG:GetValue("RG_SEMANA")
									RCH->( dbSeek( xFilial("RCH") + cProcess + cTipoPLA + cPeriodo + cNumPag ) )
									If Empty(RCH->RCH_DTFECH)
										cTabRH := "RHR"
									Else
										cTabRH := "RHS"
									EndIf
									RestArea(aAreaRCH)
									GetRAssMed( xFilial("SRG"), oModelSRG:GetValue("RG_MAT"), "S016", cVersEnvio, cPeriodo, @aDadosRHST, @aDadosRHSD, cTabRH, @lCPFDepOk, @aDepAgreg )
									lCarrDep	:= .T.
									cVbPla 	 	+= SRV->RV_COD + "/"
								EndIf

							EndIf
							RestArea(aAreaSRV)

							//------------------------------------------------
							//| Centro de Custo
							//| Guarda a area atual, entra na CTT e recupera os dados do cc
							//---------------------------------------------------------------
							If !lVerRJ5
								aAreaCTT := GetArea()
								DBSelectArea("CTT")
								CTT->(DbSetOrder(1))
								If( CTT->( dbSeek( xFilial("CTT") + oGrid:GetValue("RR_CC") ) ) )
									cCodLot := IIf(lSemFilCTT, CTT->CTT_CUSTO, CTT->CTT_FILIAL+CTT->CTT_CUSTO )
									cTpLot  := CTT->CTT_TPLOT	// Tipo de Lotação (?!?)

									If CTT->CTT_TPLOT == "01" .And. CTT->CTT_TIPO2 == "4" .And. CTT->CTT_CLASSE == "2"
										cTpInscr 	:= CTT->CTT_TIPO2 // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
										cInscr 	 	:= CTT->CTT_CEI2 // Codigo da inscricao
										cChaveS1005	:= xFilial("CTT", SRA->RA_FILIAL)+cInscr
									EndIf
								EndIf
								RestArea(aAreaCTT)
							Else
								If cCCAnt != cChaveCC
									cCCAnt 		:= cChaveCC
									cCodLot		:= ""
									lSemFilRJ5 	:= Empty(xFilial("RJ5"))
									RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
									If RJ5->( !dbSeek( xFilial("RJ5", M->RA_FILIAL) + cChaveCC ) )
										If aScan(aErrosRJ5, { |x| x == cChaveCC }) == 0
											aAdd( aErrosRJ5, cChaveCC )
										EndIf
									Else
										If lRJ5FilT
											RJ5->(DbSetOrder(7)) //RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
											RJ5->(dbGoTop())
											RJ5->( dbSeek( xFilial("RJ5", M->RA_FILIAL) + cChaveCC + SRA->RA_FILIAL) )
											While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", M->RA_FILIAL) .And. RJ5->RJ5_CC == cChaveCC .And. RJ5->RJ5_FILT == SRA->RA_FILIAL
												If AnoMes( Iif(FunName() $ cFncSemVer, M->RA_DEMISSA, M->RG_DATADEM) ) >= RJ5->RJ5_INI
													cTpInscr	:= RJ5->RJ5_TPIO
													cInscr  	:= RJ5->RJ5_NIO
													cCodLot		:= IIf(lSemFilRJ5, RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
													cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
													lTemReg		:= .T.
												EndIf
												RJ5->( dbSkip() )
											EndDo
											//Se não encontrou um registro com código preenchido reposiciona a tabela e executa o dbseek novamente.
											If !lTemReg
												RJ5->(DbSetOrder(4)) //RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
												RJ5->(dbGoTop())
												RJ5->( dbSeek( xFilial("RJ5", M->RA_FILIAL) + cChaveCC ) )
												While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", M->RA_FILIAL) .And. RJ5->RJ5_CC == cChaveCC .And. EMPTY(RJ5->RJ5_FILT)
													If AnoMes( Iif(FunName() $ cFncSemVer, M->RA_DEMISSA, M->RG_DATADEM) ) >= RJ5->RJ5_INI
														cTpInscr	:= RJ5->RJ5_TPIO
														cInscr  	:= RJ5->RJ5_NIO
														cCodLot		:= IIf(lSemFilRJ5, RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
														cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
													EndIf
													RJ5->( dbSkip() )
												EndDo
											EndIf
										Else
											While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", M->RA_FILIAL) .And. RJ5->RJ5_CC == cChaveCC
												If AnoMes( Iif(FunName() $ cFncSemVer, M->RA_DEMISSA, M->RG_DATADEM) ) >= RJ5->RJ5_INI
													cTpInscr	:= RJ5->RJ5_TPIO
													cInscr  	:= RJ5->RJ5_NIO
													cCodLot		:= IIf(lSemFilRJ5, RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
													cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
												EndIf
												RJ5->( dbSkip() )
											EndDo
										EndIf
										If Empty(cCodLot)
											If aScan(aErrosRJ5, { |x| x == cChaveCC }) == 0
												aAdd( aErrosRJ5, cChaveCC )
											EndIf
										Else
											If aScan( aRelacRJ5, { |x| x[1] == cChaveCC } ) == 0
												aAdd(aRelacRJ5, { cChaveCC, cCodLot })
											EndIf
										EndIf
									EndIf
								EndIf
								nPosCCPD	:= Ascan( @aCols040,{|X| X[20] == cCodLot + oGrid:GetValue("RR_PD") })
								nPosCC		:= Ascan( @aCols040,{|X| X[19] == cCodLot })
							EndIf

							If Empty(cTpInscr) .OR. Empty(cInscr)
								If fBuscaOBRA( SRA->RA_FILIAL, @cCEIObra )
									cTpInscr 	:= "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
									cInscr 	 	:= cCEIObra // Codigo da inscricao
									cChaveS1005	:= cFilEnv+cInscr
								Elseif fBuscaCAEPF( cFilEnv, @cCAEPF )
									cTpInscr 	:= "3"
									cInscr	 	:= cCAEPF
									cChaveS1005	:= cFilEnv+cInscr
								Else
									nPosEstb 	:= aScan(aEstb, {|x| x[1] == AllTrim(SRA->RA_FILIAL)})
									If nPosEstb > 0
										cTpInscr	:= aEstb[nPosEstb,3]
										cInscr		:= aEstb[nPosEstb,2]
										cChaveS1005	:= cFilEnv+cInscr
									EndIf
								EndIf
							EndIf

							//Contagem da quantidade de CCs citados na rescisao
							If(nPosCC == 0)
								aAdd(aDadosCCT, {cChaveCC, cTpInscr, cInscr, cCodLot, cChaveS1005 } )
							EndIf

							//------------------------------------------------
							//| Array de Dados
							//| Montagem do array com os dados a utilizar para o XML
							//-------------------------------------------------------
							If( nPosCCPD > 0 )
								aCols040[nPosCCPD, 15] += oGrid:GetValue("RR_HORAS") 	//Incrementa Horas
								aCols040[nPosCCPD, 17] += oGrid:GetValue("RR_VALOR") 	//Incrementa Valor
								aCols040[nPosCCPD, 18] := aCols040[nPosCCPD, 18] + 1	//Incrementa Contador
							Else
								aAdd(aCols040, { 	oGrid:GetValue("RR_CC")+ oGrid:GetValue("RR_PD"),;			//01 - Chave para pesquisa (CC+PD)
													"Dados da Verba",;					//02 - Separador - Verbas/Rubricas
													cCodRubr,;							//03 - Codigo da Rubrica
													cIdeRubr,;							//04 - Ident   da Rubrica
													cPrcRubr,;							//05 - Percent da Rubrica
													"Dados do CC",;						//06 - Separador - Centro de Custo
													cCodLot,;							//07 - Codigo da Lotação
													cTpInscr,;							//08 - Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
													cInscr,;							//09 - Codigo da inscricao
													cTpLot,;							//10 - Tipo de Lotação (?!?)
													"Dados da Grid",;					//11 - Separador - Centro de Custo
													oGrid:GetValue("RR_CC"),;			//12 - Centro de Custo
													oGrid:GetValue("RR_PD"),;			//13 - Verba da rescisão
													oGrid:GetValue("RR_DESCPD"),;		//14 - Descricao da verba
													oGrid:GetValue("RR_HORAS"),;		//15 - Horas da verba
													oGrid:GetValue("RR_VALOR"),;		//16 - Valor da verba
													oGrid:GetValue("RR_VALOR"),;		//17 - Acumulado da verba (valor inicial para soma)
													1,; 								//18 - Numero de registro repetidos (CC + PD)
													cCodLot,;							//19 - Código de lotação
													cCodLot + oGrid:GetValue("RR_PD"),; //20 - Chave para pesquisa (Código Lotação+PD)
													SRV->RV_NATUREZ,;					//21 - Natureza da verba
													SRV->RV_INCCP,;						//22 - Incidência CP da verba
													SRV->RV_INCFGTS,;					//23 - Incidência FGTS da verba
													SRV->RV_INCIRF,;					//24 - Incidência IRRF da verba
													SRV->RV_TIPOCOD,;					//25 - Tipo da verba
													If(lRVIncop, SRV->RV_INCOP,""),;	//26 - Incid RPPS
													If(lRVTetop, SRV->RV_TETOP,"") })	//27 - Teto Remun

							EndIf

						EndIf

						//----------------------
						//| Liquido da Rescisão
						//| Se a verba corrente tiver o ID de Calculo igual
						//| a 0126 O Sistema receberá o valor líquido da rescisão
						//--------------------------------------------------------
						If RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_CODFOL" ) $ "0126"
							nValor := oGrid:GetValue("RR_VALOR")
						EndIf

						//---------------------
						//| Pensão Alimenticia
						//| Se a verba corrente tiver valor de DIRF igual aos informados
						//| Realizará a soma do montante pago de pensão Alimenticia
						//-----------------------------------------------------------
						If ( ( cVersEnvio < "2.6.00" .And. SubStr(RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_INCIRF" ), 1, 2) $ "51|52|53|54|55" ) .Or.;
							( cVersEnvio >= "2.6.00" .And. RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_INCIRF" ) $ "51  |52  |53  |54  |55  " ) )
							nPensao += oGrid:GetValue("RR_VALOR")
						EndIf

						//------------------------------
						//| Verba de Multiplos Vinculos
						//| Se a verba corrente, tiver seu ID de Calculo igual a 0318
						//| realizará a procura dos multiplos vínculos do funcionário
						//------------------------------------------------------------
						If RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_CODFOL" ) $ "0318"
							aAreaRAZ := GetArea()
							DBSelectArea("RAZ")
							RAZ->(DbSetOrder(1))
							If( RAZ->( dbSeek( SRA->RA_FILIAL + SRA->RA_MAT ) ) )
								aDadosRAZ := GetMulVin( SRA->RA_FILIAL , SRA->RA_MAT, oModelSRG:GetValue("RG_PERIODO"))
							EndIf
						EndIf

					Next nI

					//Tratando o Log

					//aErros := {}
					If( Len(aErros) > 1 ) //Maior que 1 pois sempre vai existir o cabeçalho do log de erros
						If !lMiddleware
							aAdd(aErros, OemToAnsi( STR0055 ) + " " + OemToAnsi( STR0056 ) ) // "estão sem código de rubrica cadastrada (RV_NATUREZ)." "Não será possível integração com o TAF e a efetivação da rescisão."
							For nI := 1 To Len(aErros)
								cMsgErro += aErros[nI] + CRLF
							Next
							Help(,,,OemToAnsi(STR0001), cMsgErro, 1,0) //"Atenção"
							DisarmTransaction()
						Else
							aAdd(aErros, OemToAnsi( STR0055 ) + " " + OemToAnsi( STR0159 ) ) // "estão sem código de rubrica cadastrada (RV_NATUREZ)." "Não será possível integração com o Middleware e a efetivação da rescisão."
						EndIf						

						Return !lGravou
					EndIf

					If !Empty(aErrosRJ5)
						cMsgErro := OemToAnsi(STR0114) + CRLF//"Não será possível efetuar a integração. O(s) centro(s) de custo: "
						For nI := 1 To Len(aErrosRJ5)
							cMsgErro += aErrosRJ5[nI] + CRLF
						Next
						cMsgErro += OemToAnsi(STR0115)//" não está(ão) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
						Help(,,,OemToAnsi(STR0001),cMsgErro,1,0) //"Atenção"
						DisarmTransaction()
						Return .F.
					EndIf

					//Ordena o Array separando por centro de custo
					//ASORT(aCols, , , { | x,y | x[2] < y[2] } )

					If !lMiddleware
						fGp23Cons(@aFilInTaf, {SRA->RA_FILIAL}, @cFilEnv)
					EndIf

					If Empty(cFilEnv)
						cFilEnv:= cFilAnt
					EndIf

					If cVersEnvio >= '2.5.00' .And. SRA->RA_CATEFD $ "201|202|721"
						fBusCadBenef(@aCodBenef,"FOL")
						For nI := 1 to len(aCodBenef)
							If ( aCodBenef[nI,15] == "S" ) //Apenas se Imprime % no Termo de Rescisao.
								nPerPens += aCodBenef[nI,2]
							EndIf
						Next nI

						nI := 0
					Endif

					DbSelectArea("SRX")
					SRX->(DbSetOrder(1))
					If SRX->(MsSeek(xFilial("SRX",SRA->RA_FILIAL) + "14"))
						DbSkip(3)
						cSimples := SubsTr(SRX->RX_TXT,17,1)
						If cSimples == "1"
							cIndSimp := SubsTr(SRX->RX_TXT,49,1)
						EndIf
					EndIf
				EndIf

				//Se vier da rotina de rescisão, da carga na variável de memória
				If oModelSRG != NIL
					RegToMemory("SRA",,,.F.)
				EndIf

				//-------------------
				//| Inicio do XML
				//-------------------
				If lMiddleware
					aInfos   := fXMLInfos()
					IF Len(aInfos) >= 4
						cTpInsc  := aInfos[1]
						lAdmPubl := aInfos[4]
						cNrInsc  := aInfos[2]
						cId  	 := aInfos[3]
					Else
						cTpInsc  := ""
						lAdmPubl := .F.
						cNrInsc  := "0"
					EndIf

					cChave := Iif( cVersEnvio >= "9.0" .And. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA ) )
					cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2399" + Padr(cChave, fTamRJEKey(), " ")
					cStat2399 	:= "-1"
					GetInfRJE( 2, cChaveBus, @cStat2399, @cOper2399, @cRetf2399, @nRec2399, @cRecib2399, @cRecibAnt, Nil, Nil, .T. )

					//Retorno pendente impede o cadastro
					If cStat2399 == "2" .And. cEFDAviso != "2"
						cMsgRJE 	:= STR0134//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
					EndIf
					//Inclusão
					If nOpc != 5
						//Evento de exclusão sem transmissão impede o cadastro
						If cOper2399 == "E" .And. cStat2399 != "4" .And. cEFDAviso != "2"
							cMsgRJE 	:= STR0135//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
						ElseIf cStat2399 == "99"
							cMsgRJE 	:= STR0146//"Operação não será realizada pois há evento de exclusão pendente para transmissão"
						//Não existe na fila, será tratado como inclusão
						ElseIf cStat2399 == "-1"
							cOperNew 	:= "I"
							cRetfNew	:= "1"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						//Evento sem transmissão, irá sobrescrever o registro na fila
						ElseIf cStat2399 $ "1/3"
							cOperNew 	:= cOper2399
							cRetfNew	:= cRetf2399
							cStatNew	:= "1"
							lNovoRJE	:= .F.
						//Evento diferente de exclusão transmitido, irá gerar uma retificação
						ElseIf cOper2399 != "E" .And. cStat2399 == "4"
							cOperNew 	:= "A"
							cRetfNew	:= "2"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						//Evento de exclusão transmitido, será tratado como inclusão
						ElseIf cOper2399 == "E" .And. cStat2399 == "4"
							cOperNew 	:= "I"
							cRetfNew	:= "1"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						EndIf
					//Exclusão
					Else
						//Evento de exclusão sem transmissão impede o cadastro
						If cOper2399 == "E" .And. cStat2399 != "4" .And. cEFDAviso != "2"
							cMsgRJE 	:= STR0135//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
						//Evento diferente de exclusão transmitido irá gerar uma exclusão
						ElseIf cOper2399 != "E" .And. cStat2399 == "4"
							cOperNew 	:= "E"
							cRetfNew	:= cRetf2399
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						EndIf
					EndIf
					If !Empty(cMsgRJE)
						Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0137) + CRLF + cMsgRJE, 1, 0 )//" não enviado(a) ao Middleware. Erro: "
						Return .F.
					EndIf
					If cRetfNew == "2"
						If cStat2399 == "4"
							cRecibXML 	:= cRecib2399
							cRecibAnt	:= cRecib2399
							cRecib2399	:= ""
						Else
							cRecibXML 	:= cRecibAnt
						EndIf
					EndIf
					aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2399", Space(6), cChave, cId, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew, cRecib2399, cRecibAnt } )
					cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtTSVTermino/v" + cVersMw + "'>"
					cXML += 	"<evtTSVTermino Id='" + cId + "'>"
					fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, cGpeAmbe, 1, "12" }, cVersEnvio, aInfos)
					fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
				Else
					//-------------------
					//| Inicio do XML
					//-------------------
					cXml := "<eSocial>"
					cXml += "	<evtTSVTermino>"
				EndIf
				cXml += '		<ideTrabSemVinculo>'
				cXml += '			<cpfTrab>' + Alltrim( M->RA_CIC ) + '</cpfTrab>'
				If cVersEnvio < "9.0" .And. (!lMiddleware .Or. !Empty(M->RA_PIS))
					cXml += '			<nisTrab>' + ALLTRIM( M->RA_PIS )	+ '</nisTrab>'
				ElseIf lGeraMat
					cXml += '			<matricula>' + ALLTRIM( M->RA_CODUNIC )	+ '</matricula>'
				EndIf
				If cVersEnvio < "9.0" .Or. !lGeraMat
					cXml += '			<codCateg>' + AllTrim( M->RA_CATEFD ) + '</codCateg>'
				EndIf
				cXml += '		</ideTrabSemVinculo>'
				cXml += '		<infoTSVTermino>'

				//Se for de rescisão, não tem data de Demissão definida, então pega variável auxiliar
				If( FunName() $ cFncSemVer )
					cTafKey := "S2399" + AnoMes(M->RA_DEMISSA) + SRA->RA_CIC + SRA->RA_CODUNIC
					If !lMiddleware
						cXml += '			<dtTerm>' + AllTrim( DtoS(M->RA_DEMISSA) ) + '</dtTerm>'
					Else
						cXml += '			<dtTerm>' + SubStr( dToS(M->RA_DEMISSA), 1, 4 ) + "-" + SubStr( dToS(M->RA_DEMISSA), 5, 2 ) + "-" + SubStr( dToS(M->RA_DEMISSA), 7, 2 ) + '</dtTerm>'
					EndIf
					//Motivo de desligamento de Diretor não empregado (CatEfd = 721)
					If !lMiddleware .And. M->RA_CATEFD $ '721'
						cXml += '			<mtvDesligTSV>' + '</mtvDesligTSV>'
					EndIf
				Else
					If !lMiddleware
						cXml += '			<dtTerm>' + AllTrim( DtoS(M->RG_DATADEM) ) + '</dtTerm>'
					Else
						cXml += '			<dtTerm>' + SubStr( dToS(M->RG_DATADEM), 1, 4 ) + "-" + SubStr( dToS(M->RG_DATADEM), 5, 2 ) + "-" + SubStr( dToS(M->RG_DATADEM), 7, 2 ) + '</dtTerm>'
					EndIf
					//Motivo de desligamento de Diretor não empregado (CatEfd = 721)
					If (!lMiddleware .Or. !Empty(M->RG_TPDIR)) .And. M->RA_CATEFD $ '721'
						cXml += '			<mtvDesligTSV>' + AllTrim(M->RG_TPDIR) + '</mtvDesligTSV>'
					EndIf
				EndIf

				//Tag's de pensão alimentícia - Leiaute 2.5
				If cVersEnvio >= '2.5.00' .And. SRA->RA_CATEFD $ "201|202|721"

					//Pensao Alimenticia
					If nPerPens <> 0 .and. nPensao <> 0
						cXml +=				'<pensAlim>3</pensAlim>'
					Elseif nPerPens == 0 .and. nPensao == 0
						cXml +=				'<pensAlim>0</pensAlim>'
					Elseif nPerPens <> 0 .and. nPensao == 0
						cXml +=				'<pensAlim>1</pensAlim>'
					Elseif nPerPens == 0 .and. nPensao <> 0
						cXml +=				'<pensAlim>2</pensAlim>'
					Endif

					//Percentual Alimenticio
					If nPerPens <>0
						cXml +=				'<percAliment>' + Alltrim(Str(nPerPens)) + '</percAliment>'
					Endif

					//VR Alimentacao
					If nPensao <>0
						cXml +=				'<vrAlim>' + Alltrim(Str(nPensao)) + '</vrAlim>'
					Endif

				Endif

				If cVersEnvio >= '2.6.00' .And. !(FunName() $ cFncSemVer) .And. !Empty(oModelSRG:GetValue("RG_NPROC"))
					cXml +=			'<nrProcTrab>' + oModelSRG:GetValue("RG_NPROC") + '</nrProcTrab>'
				EndIf

				//------------------------------------------------------------------------------------------------------------------------------
				//| Se vier do GPEA010 (Cad. Func) ou GPEA265 (Cad. Auton). Não deverá entrar neste bloco.
				//| Só entrará se vier das rotinas de demissões (GPEM040 ou GPEM630) e se o array com dados do CTT estiver preenchido
				//| A partir da versão 9.0 só entrar se a categoria for 721 e dtTerm for superior à data de inicio da obrigatoriedade dos eventos periódicos
				//------------------------------------------------------------------------------------------------------------------------------
				If !( FunName() $ cFncSemVer ) .And. lXmlVerbas .AND. LEN(aDadosCCT) > 0 .And. (cVersEnvio < "9.0" .Or. SRA->RA_CATEFD == "721" .And. M->RG_DATADEM >= dDtCgini)
					If lMiddleware
						fExcRJO(SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, "S-2399")
					EndIf

					cXml += '			<verbasResc>'

					// Se for envio de rescisão complementar busca os valores pagos nas rescisões anteriores
					If lResComp .Or. lRetif
						fResCom(@cXml, oModel, aDadosCCT, cVBDiss, cIndSimp, lRetif, @aCols040, cVersEnvio, aRelacRJ5, @aErrosRJ5)
					EndIf

					If cVersEnvio >= '2.3'
						cIdDmDev := "R" + cEmpAnt + Alltrim(xFilial("SRG")) +  SRA->RA_MAT + If(lRetif, "C", "") + If(Empty(nContRes), (++nContRes, ""), cValToChar(nContRes++))
					EndIf

					cXml += '				<dmDev>'
					If !lMiddleware
						cXml += '					<ideDmDev>' + cIdDmDev + '</ideDmDev>'
					Else
						cXml += "					<ideDmDev>" + Alltrim(cIdDmDev) +  "</ideDmDev>"
					Endif

					//Looping para detalhar os Centros de Custos que o Trab Atuou
					For nZ := 1 To Len( aDadosCCT )
						If lResComp .Or. lRetif
							If !((!lVerRJ5 .And. aScan(aCols040, { |x| x[12] == aDadosCCT[nZ,1] .And. x[17] > 0 }) > 0) .Or.;
								(lVerRJ5 .And. aScan(aCols040, { |x| x[19] == aDadosCCT[nZ,4] .And. x[17] > 0 }) > 0))
								Loop
							EndIf
						EndIf
						cXml += "						<ideEstabLot>"
						cXml += "							<tpInsc>" + If(Empty(aDadosCCT[nZ,2]),cTpInscr,aDadosCCT[nZ,2]) + "</tpInsc>"
						cXml += "							<nrInsc>" + If(Empty(aDadosCCT[nZ,3]),cInscr,aDadosCCT[nZ,3]) + "</nrInsc>"
						If !lMiddleware
							cXml += "							<codLotacao>" + StrTran( aDadosCCT[nZ,4], "&", "&amp;") + "</codLotacao>"
						Else
							cXml += "							<codLotacao>" + Alltrim(StrTran( aDadosCCT[nZ,4], "&", "&amp;")) + "</codLotacao>"
						Endif
						//Looping nas verbas vindas
						For nX := 1 To Len( aCols040 )
							//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
							If ( ((!lVerRJ5 .And. aCols040[nX, 12] == aDadosCCT[nZ,1]) .Or. (lVerRJ5 .And. aCols040[nX, 19] == aDadosCCT[nZ,4])) .And. aCols040[nX, 17] > 0 )
								cXml += "							<detVerbas>"
								cXml += "								<codRubr>" + aCols040[nX,3] + "</codRubr>"
								cXml += "								<ideTabRubr>" + aCols040[nX,4] + "</ideTabRubr>"
								If !lMiddleware
									cXml += "							<qtdRubr>" + Str(aCols040[nX,15]) + "</qtdRubr>"
								ElseIf lMiddleware .And. !Empty(aCols040[nX,15])
									cXml += "							<qtdRubr>" + Alltrim(Str(aCols040[nX,15])) + "</qtdRubr>"
								EndIf
								If !lMiddleware .Or. !Empty(aCols040[nX,5])
									cXml += "							<fatorRubr>" + AllTrim( Transform(aCols040[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
								EndIf
								If cVersEnvio < "9.0" .And. (!lMiddleware .Or. !Empty(aCols040[nX,16]))
									If !lMiddleware
										cXml += "							<vrUnit>" + AllTrim( Transform(aCols040[nX,16],"@E 999999999.99") ) + "</vrUnit>"
									Else
										cXml += "							<vrUnit>" + AllTrim( Str(aCols040[nX,16]) ) + "</vrUnit>"
									EndIf
								EndIf
								If !lMiddleware
									cXml += "								<vrRubr>" + AllTrim( Transform(aCols040[nX,17],"@E 999999999.99") ) + "</vrRubr>"
								Else
									cXml += "								<vrRubr>" + AllTrim( Str(aCols040[nX,17]) ) + "</vrRubr>"
								EndIf
								If cVersEnvio >= "9.0" .And. cValToChar(year(M->RG_DATADEM)) >= "2021"
									cXml += "								<indApurIR>0</indApurIR>"
								EndIf
								cXml += "							</detVerbas>"
								If aCols040[nX,3] $ cVbPla
									lGerPla := .T.
								EndIf

								If lMiddleware .And. ( (aCols040[nX, 21] == "9901" .And. aCols040[nX, 25] == "3") .Or. (aCols040[nX, 21] == "9201" .And. aCols040[nX, 22] $ "31/32") .Or. (aCols040[nX, 21] == "1409" .And. aCols040[nX, 22] == "51") .Or. (aCols040[nX, 21] == "4050" .And. aCols040[nX, 22] == "21") .Or. (aCols040[nX, 21] == "4051" .And. aCols040[nX, 22] == "22") .Or. (aCols040[nX, 21] == "9902" .And. aCols040[nX, 25] == "3") .Or. (aCols040[nX, 21] == "9904" .And. aCols040[nX, 25] == "3") .Or. (aCols040[nX, 21] == "9908" .And. aCols040[nX, 25] == "3") )
									fGrvRJO(SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aDadosCCT[nZ, 2], aDadosCCT[nZ, 3], aDadosCCT[nZ, 4], aCols040[nX, 21], aCols040[nX, 25], aCols040[nX, 22], aCols040[nX, 23], aCols040[nX, 25], aCols040[nX, 17], "S-2399", , , ,aCols040[nX, 26], aCols040[nX, 27] )
								EndIf
							EndIf
						Next

						//Plano de Saude //Necessário rever o dependente
						If cVersEnvio < "9.0" .And. Len(aDadosRHST) > 0 .And. lGerPla
							cXml += "							<infoSaudeColet>"
							For nW := 1 To Len(aDadosRHST)
								cXml += "								<detOper>"
								cXml += "									<cnpjOper>" + aDadosRHST[nW,6] + "</cnpjOper>"
								cXml += "									<regANS>" + aDadosRHST[nW,7] + "</regANS>"
								If !lMiddleware
									cXml += "									<vrPgTit>" + AllTrim( Transform(aDadosRHST[nW,8],"@E 999999999.99") ) + "</vrPgTit>"
								Else
									cXml += "									<vrPgTit>" + AllTrim( Str(aDadosRHST[nW,8]) ) + "</vrPgTit>"
								EndIf
								If( Len(aDadosRHSD) > 0 )
									For nY := 1 to Len(aDadosRHSD)
										If ( aDadosRHST[nW][6] + aDadosRHST[nW][7] == aDadosRHSD[nY][7] + aDadosRHSD[nY][8] )
											cXml += "									<detPlano>"
											If cVersEnvio >= '2.3'
												cXml += "				                 	<tpDep>"+aDadosRHSD[nY,5]+"</tpDep>"
											EndIf
											If !lMiddleware .Or. !Empty(aDadosRHSD[nY,1])
												cXml += "									<cpfDep>" + aDadosRHSD[nY,1] + "</cpfDep>"
											EndIf
											cXml += "										<nmDep>" + aDadosRHSD[nY,2] + "</nmDep>"
											If !lMiddleware
												cXml += "										<dtNascto>" + aDadosRHSD[nY,3] + "</dtNascto>"
											Else
												cXml += "										<dtNascto>" + SubStr( aDadosRHSD[nY,3], 1, 4 ) + "-" + SubStr( aDadosRHSD[nY,3], 5, 2 ) + "-" + SubStr( aDadosRHSD[nY,3], 7, 2 ) + "</dtNascto>"
											EndIf
											If !lMiddleware
												cXml += "										<vlrPgDep>" + AllTrim( Transform(aDadosRHSD[nY,4],"@E 999999999.99") ) + "</vlrPgDep>"
											Else
												cXml += "										<vlrPgDep>" + AllTrim( Str(aDadosRHSD[nY,4]) ) + "</vlrPgDep>"
											EndIf
											cXml += "									</detPlano>"
										Endif
									Next
								EndIf
								cXml += "								</detOper>"
							Next
							cXml += "							</infoSaudeColet>"
							aDadosRHST	:= {}
						EndIf
						If M->RA_CATEFD $ "738/731/734/201/202/"
							cXml += "							<infoAgNocivo>"
							cXml += "								<grauExp>" + Alltrim(M->RA_OCORREN) + "</grauExp>"
							cXml += "							</infoAgNocivo>"
						EndIf
						If !lMiddleware .Or. !Empty(cIndSimp)
							cXml += "							<infoSimples>"
							cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
							cXml += "							</infoSimples>"
						EndIf
						cXml += "						</ideEstabLot>"
					Next
					cXml += '				</dmDev>'

					//Validação para verificar se gera o dmDev do PLR pago antes da rescisão no mesmo período
					fPLR2399( @cXml, oModel, aDadosCCT, cIndSimp, dDataRes)

					//Validação para verificar se gera o dmDev do ADI
					fADI2299( @aAdiCC, @aAdiCols, cFilEnv, @cIdDmDev, cVersEnvio, lRetif, @aErrosRJ5 )

					If !Empty(aErrosRJ5)
						cMsgErro := OemToAnsi(STR0114) + CRLF//"Não será possível efetuar a integração. O(s) centro(s) de custo: "
						For nI := 1 To Len(aErrosRJ5)
							cMsgErro += aErrosRJ5[nI] + CRLF
						Next
						cMsgErro += OemToAnsi(STR0115)//" não está(ão) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
						Help(,,,OemToAnsi(STR0001),cMsgErro,1,0) //"Atenção"
						DisarmTransaction()
						Return .F.
					EndIf

					//Looping para varrer as verbas
					If Len(aAdiCols) > 0
						cXml += '				<dmDev>'
						cXml += '					<ideDmDev>' + cIdDmDev + '</ideDmDev>'

						//Looping para detalhar os Centros de Custos que o Trab Atuou
						For nZ := 1 To Len( aAdiCC )
							cXml += "						<ideEstabLot>"
							cXml += "							<tpInsc>" + If(Empty(aAdiCC[nZ,2]),cTpInscr,aAdiCC[nZ,2]) + "</tpInsc>"
							cXml += "							<nrInsc>" + If(Empty(aAdiCC[nZ,3]),cInscr,aAdiCC[nZ,3]) + "</nrInsc>"
							cXml += "							<codLotacao>" + StrTran( aAdiCC[nZ,4], "&", "&amp;") + "</codLotacao>"

							//Looping nas verbas vindas
							For nX := 1 To Len( aAdiCols )
								//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
								If( ((!lVerRJ5 .And. aAdiCols[nX, 12] == aAdiCC[nZ,1]) .Or. (lVerRJ5 .And. aAdiCols[nX, 19] == aAdiCC[nZ,4])) .And. aAdiCols[nX, 17] > 0 )
									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + aAdiCols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + aAdiCols[nX,4] + "</ideTabRubr>"
									If !lMiddleware .Or. !Empty(aAdiCols[nX,15])
										cXml += "							<qtdRubr>" + Str(aAdiCols[nX,15]) + "</qtdRubr>"
									EndIf
									If !lMiddleware .Or. !Empty(aAdiCols[nX,5])
										cXml += "							<fatorRubr>" + AllTrim( Transform(aAdiCols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									EndIf
									If cVersEnvio < "9.0"  .And. (!lMiddleware .Or. !Empty(aAdiCols[nX,16]))
										If !lMiddleware
											cXml += "							<vrUnit>" + AllTrim( Transform(aAdiCols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "							<vrUnit>" + AllTrim( Str(aAdiCols[nX,16]) ) + "</vrUnit>"
										EndIf
									EndIf
									If !lMiddleware
										cXml += "								<vrRubr>" + AllTrim( Transform(aAdiCols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(aAdiCols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersEnvio >= "9.0" .And. cValToChar(year(M->RG_DATADEM)) >= "2021"
										cXml += "								<indApurIR>0</indApurIR>"
									EndIf
									cXml += "							</detVerbas>"

									If lMiddleware .And. ( (aAdiCols[nX, 21] == "9901" .And. aAdiCols[nX, 25] == "3") .Or. (aAdiCols[nX, 21] == "9201" .And. aAdiCols[nX, 22] $ "31/32") .Or. (aAdiCols[nX, 21] == "1409" .And. aAdiCols[nX, 22] == "51") .Or. (aAdiCols[nX, 21] == "4050" .And. aAdiCols[nX, 22] == "21") .Or. (aAdiCols[nX, 21] == "4051" .And. aAdiCols[nX, 22] == "22") .Or. (aAdiCols[nX, 21] == "9902" .And. aAdiCols[nX, 25] == "3") .Or. (aAdiCols[nX, 21] == "9904" .And. aAdiCols[nX, 25] == "3") .Or. (aAdiCols[nX, 21] == "9908" .And. aAdiCols[nX, 25] == "3") )
										fGrvRJO(SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aAdiCC[nZ, 2], aAdiCC[nZ, 3], aAdiCC[nZ, 4], aAdiCols[nX, 21], aAdiCols[nX, 25], aAdiCols[nX, 22], aAdiCols[nX, 23], aAdiCols[nX, 24], aAdiCols[nX, 17], "S-2399", , , ,aAdiCols[nX, 26], aAdiCols[nX, 27] )
									EndIf
								EndIf
							Next

							If M->RA_CATEFD $ "738/731/734/201/202/"
								cXml += "							<infoAgNocivo>"
								cXml += "								<grauExp>" + Alltrim(M->RA_OCORREN) + "</grauExp>"
								cXml += "							</infoAgNocivo>"
							EndIf
							If !lMiddleware .Or. !Empty(cIndSimp)
								cXml += "							<infoSimples>"
								cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
								cXml += "							</infoSimples>"
							EndIf
							cXml += "						</ideEstabLot>"
						Next
						cXml += '				</dmDev>'
					EndIf

					//Validação para verificar se gera o dmDev do ADI
					f1312299( @a131CC, @a131Cols, cFilEnv, @cIdDmDev, lRetif, @aErrosRJ5, cVersEnvio )

					If !Empty(aErrosRJ5)
						cMsgErro := OemToAnsi(STR0114) + CRLF//"Não será possível efetuar a integração. O(s) centro(s) de custo: "
						For nI := 1 To Len(aErrosRJ5)
							cMsgErro += aErrosRJ5[nI] + CRLF
						Next
						cMsgErro += OemToAnsi(STR0115)//" não está(ão) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
						Help(,,,OemToAnsi(STR0001),cMsgErro,1,0) //"Atenção"
						DisarmTransaction()
						Return .F.
					EndIf

					//Looping para varrer as verbas
					If Len(a131Cols) > 0
						cXml += '				<dmDev>'
						cXml += '					<ideDmDev>' + cIdDmDev + '</ideDmDev>'

						//Looping para detalhar os Centros de Custos que o Trab Atuou
						For nZ := 1 To Len( a131CC )
							cXml += "						<ideEstabLot>"
							cXml += "							<tpInsc>" + If(Empty(a131CC[nZ,2]),cTpInscr,a131CC[nZ,2]) + "</tpInsc>"
							cXml += "							<nrInsc>" + If(Empty(a131CC[nZ,3]),cInscr,a131CC[nZ,3]) + "</nrInsc>"
							cXml += "							<codLotacao>" + StrTran( a131CC[nZ,4], "&", "&amp;") + "</codLotacao>"

							//Looping nas verbas vindas
							For nX := 1 To Len( a131Cols )
								//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
								If( ((!lVerRJ5 .And. a131Cols[nX, 12] == a131CC[nZ,1]) .Or. (lVerRJ5 .And. a131Cols[nX, 19] == a131CC[nZ,4])) .And. a131Cols[nX, 17] > 0 )
									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + a131Cols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + a131Cols[nX,4] + "</ideTabRubr>"
									If !lMiddleware .Or. !Empty(a131Cols[nX,15])
										cXml += "							<qtdRubr>" + Str(a131Cols[nX,15]) + "</qtdRubr>"
									EndIf
									If !lMiddleware .Or. !Empty(a131Cols[nX,5])
										cXml += "							<fatorRubr>" + AllTrim( Transform(a131Cols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									EndIf
									If cVersEnvio < "9.0" .And. (!lMiddleware .Or. !Empty(a131Cols[nX,16]))
										If !lMiddleware
											cXml += "							<vrUnit>" + AllTrim( Transform(a131Cols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "							<vrUnit>" + AllTrim( Str(a131Cols[nX,16]) ) + "</vrUnit>"
										EndIf
									EndIf
									If !lMiddleware
										cXml += "								<vrRubr>" + AllTrim( Transform(a131Cols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(a131Cols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersEnvio >= "9.0" .And. cValToChar(year(M->RG_DATADEM)) >= "2021"
										cXml += "								<indApurIR>0</indApurIR>"
									EndIf
									cXml += "							</detVerbas>"

									If lMiddleware .And. ( (a131Cols[nX, 21] == "9901" .And. a131Cols[nX, 25] == "3") .Or. (a131Cols[nX, 21] == "9201" .And. a131Cols[nX, 22] $ "31/32") .Or. (a131Cols[nX, 21] == "1409" .And. a131Cols[nX, 22] == "51") .Or. (a131Cols[nX, 21] == "4050" .And. a131Cols[nX, 22] == "21") .Or. (a131Cols[nX, 21] == "4051" .And. a131Cols[nX, 22] == "22") .Or. (a131Cols[nX, 21] == "9902" .And. a131Cols[nX, 25] == "3") .Or. (a131Cols[nX, 21] == "9904" .And. a131Cols[nX, 25] == "3") .Or. (a131Cols[nX, 21] == "9908" .And. a131Cols[nX, 25] == "3") )
										fGrvRJO(SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, a131CC[nZ, 2], a131CC[nZ, 3], a131CC[nZ, 4], a131Cols[nX, 21], a131Cols[nX, 25], a131Cols[nX, 22], a131Cols[nX, 23], a131Cols[nX, 24], a131Cols[nX, 17], "S-2399", , , ,a131Cols[nX, 26], a131Cols[nX, 27] )
									EndIf
								EndIf
							Next

							If M->RA_CATEFD $ "738/731/734/201/202/"
								cXml += "							<infoAgNocivo>"
								cXml += "								<grauExp>" + Alltrim(M->RA_OCORREN) + "</grauExp>"
								cXml += "							</infoAgNocivo>"
							EndIf
							If !lMiddleware .Or. !Empty(cIndSimp)
								cXml += "							<infoSimples>"
								cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
								cXml += "							</infoSimples>"
							EndIf
							cXml += "						</ideEstabLot>"
						Next
						cXml += '				</dmDev>'
					EndIf

					If M->RG_SEMANA > "01"
						//Validação para verificar se gera o dmDev do FOL
						fFOL2299( @aFolCC, @aFolCols, cFilEnv, @aIdDmDev, cVersEnvio, lRetif, M->RG_SEMANA )
						For nContDev := 1 To Len(aIdDmDev)
							//Looping para varrer as verbas
							If Len(aFolCols[nContDev]) > 0
								cXml += "				<dmDev>"
								cXml += "					<ideDmDev>" + aIdDmDev[nContDev] +  "</ideDmDev>"

								//Looping para detalhar os Centros de Custos que o Trab Atuou
								For nZ := 1 To Len( aFolCC[nContDev] )
									cXml += "						<ideEstabLot>"
									cXml += "							<tpInsc>" + aFolCC[nContDev,nZ,2] + "</tpInsc>"
									cXml += "							<nrInsc>" + aFolCC[nContDev,nZ,3] + "</nrInsc>"
									cXml += "							<codLotacao>" + StrTran( aFolCC[nContDev,nZ,4], "&", "&amp;") + "</codLotacao>"
									//Looping nas verbas vindas
									For nX := 1 To Len( aFolCols[nContDev] )
										//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
										If( aFolCols[nContDev,nX, 12] == aFolCC[nContDev,nZ,1] .AND. aFolCols[nContDev,nX,17] > 0 )
											cXml += "							<detVerbas>"
											cXml += "								<codRubr>" + aFolCols[nContDev,nX,3] + "</codRubr>"
											cXml += "								<ideTabRubr>" + aFolCols[nContDev,nX,4] + "</ideTabRubr>"
											If !lMiddleware .Or. !Empty(aFolCols[nContDev,nX,15])
												cXml += "							<qtdRubr>" + Str(aFolCols[nContDev,nX,15]) + "</qtdRubr>"
											EndIf
											If !lMiddleware .Or. !Empty(aFolCols[nContDev,nX,5])
												cXml += "							<fatorRubr>" + AllTrim( Transform(aFolCols[nContDev,nX,5],"@E 999999999.99") ) + "</fatorRubr>"
											EndIf
											If cVersEnvio < "9.0" .And. (!lMiddleware .Or. !Empty(aFolCols[nContDev,nX,16]))
												If !lMiddleware
													cXml += "							<vrUnit>" + AllTrim( Transform(aFolCols[nContDev,nX,16],"@E 999999999.99") ) + "</vrUnit>"
												Else
													cXml += "							<vrUnit>" + AllTrim( Str(aFolCols[nContDev,nX,16]) ) + "</vrUnit>"
												EndIf
											EndIf
											If !lMiddleware
												cXml += "								<vrRubr>" + AllTrim( Transform(aFolCols[nContDev,nX,17],"@E 999999999.99") ) + "</vrRubr>"
											Else
												cXml += "								<vrRubr>" + AllTrim( Str(aFolCols[nContDev,nX,17]) ) + "</vrRubr>"
											EndIf
											If cVersEnvio >= "9.0" .And. cValToChar(year(M->RG_DATADEM)) >= "2021"
												cXml += "								<indApurIR>0</indApurIR>"
											EndIf
											cXml += "							</detVerbas>"

											If lMiddleware .And. ( (aFolCols[nContDev, nX, 21] == "9901" .And. aFolCols[nContDev, nX, 25] == "3") .Or. (aFolCols[nContDev, nX, 21] == "9201" .And. aFolCols[nContDev, nX, 22] $ "31/32") .Or. (aFolCols[nContDev, nX, 21] == "1409" .And. aFolCols[nContDev, nX, 22] == "51") .Or. (aFolCols[nContDev, nX, 21] == "4050" .And. aFolCols[nContDev, nX, 22] == "21") .Or. (aFolCols[nContDev, nX, 21] == "4051" .And. aFolCols[nContDev, nX, 22] == "22") .Or. (aFolCols[nContDev, nX, 21] == "9902" .And. aFolCols[nContDev, nX, 25] == "3") .Or. (aFolCols[nContDev, nX, 21] == "9904" .And. aFolCols[nContDev, nX, 25] == "3") .Or. (aFolCols[nContDev, nX, 21] == "9908" .And. aFolCols[nContDev, nX, 25] == "3") )
												fGrvRJO(SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aFolCC[nContDev, nZ, 2], aFolCC[nContDev, nZ, 3], aFolCC[nContDev, nZ, 4], aFolCols[nContDev, nX, 21], aFolCols[nContDev, nX, 25], aFolCols[nContDev, nX, 22], aFolCols[nContDev, nX, 23], aFolCols[nContDev, nX, 24], aFolCols[nContDev, nX, 17], "S-2399", , , ,aFolCols[nX, 26], aFolCols[nX, 27] )
											EndIf
										EndIf
									Next
									If M->RA_CATEFD $ "738/731/734/201/202/"
										cXml += "							<infoAgNocivo>"
										cXml += "								<grauExp>" + Alltrim(M->RA_OCORREN) + "</grauExp>"
										cXml += "							</infoAgNocivo>"
									EndIf
									If !Empty(cIndSimp)
										cXml += "							<infoSimples>"
										cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
										cXml += "							</infoSimples>"
									Endif
									cXml += "						</ideEstabLot>"
								Next

								cXml += "				</dmDev>"
							EndIf
						Next nContDev
					EndIf

					//Informações Multiplos Vinculos
					If ( Len( aDadosRAZ ) > 0 )
						cXml += "				<infoMV>"
						cXml += "					<indMV>" + aDadosRAZ[1,5] + "</indMV>"

						For nX := 1 To Len( aDadosRAZ )
							cXml += "					<remunOutrEmpr>"
							cXml += "						<tpInsc>" + aDadosRAZ[nX,9] + "</tpInsc>"
							cXml += "						<nrInsc>" + aDadosRAZ[nX,10] + "</nrInsc>"
							cXml += "						<codCateg>" + aDadosRAZ[nX,12] + "</codCateg>"
							cXml += "						<vlrRemunOE>" + AllTrim( Transform(aDadosRAZ[nX,11],"@E 999999999.99") ) + "</vlrRemunOE>"
							cXml += "					</remunOutrEmpr>"
						Next
						cXml += "				</infoMV>"
					EndIf
					cXml += '			</verbasResc>'
				EndIf

				cXml += '		</infoTSVTermino>'
				cXml += '	</evtTSVTermino>'
				cXml += '</eSocial>'
				//-------------------
				//| Final do XML
				//-------------------
			EndIf
		ElseIf ( cTpRes == "2" ) .And. nOpc != 5
			//------------------------
			//| Tipo Rescisao Coletiva
			//| Caso a chamada da funcao tenha vindo da GPEM630()
			//----------------------------------------------------
			If !lMiddleware
				fGp23Cons(@aFilInTaf, {SRA->RA_FILIAL}, @cFilEnv)
				cStat2399 := TAFGetStat( "S-2399", AllTrim(SRA->RA_CIC) + ";" + Space(Len(SRA->RA_CODUNIC)) + ";" + "1", , SRA->RA_FILIAL )
				If cStat2399 == "6"
					//"Atenção"##"Operação não será realizada pois há evento de exclusão pendente para transmissão"
					//"Verifique o status do evento S-3000 e tente novamente."
					aAdd(aErros, OemToAnsi(STR0146)+". "+ OemToAnsi(STR0326))//"Não será possível efetuar a integração. O identificador de tabela de rubrica do código: "##" não está cadastrado."
					DisarmTransaction()
					Return .F.
				EndIf
			EndIf

			If Empty(cFilEnv)
				cFilEnv:= cFilAnt
			EndIf

			If cVersEnvio >= '2.3'
				cIdDmDev := "R" + cEmpAnt + Alltrim(xFilial("SRA")) + SRA->RA_MAT
			EndIf

			//----------------
			//| Evento S-2399
			//| Inicio da geracao do evento de desligamento
			//----------------------------------------------
			If !Empty(cFilEnv)

				//------------------------
				//| Verificacao de Filial
				//| Verificar o compartilhamento das tabelas CTT e SRV
				//--------------------------------------------------------------
				If Empty(xFilial("CTT")) //CTT compartilhada
					lSemFilCTT := .T.
				EndIf

				If !lMiddleware
					cTafKey := "S2399" + AnoMes(M->RG_DATADEM) + SRA->RA_CIC + SRA->RA_CODUNIC
				Else
					fVersEsoc( "S2399", .T., /*aRetGPE*/, /*aRetTAF*/, , , @cVersMw )
					fPosFil( cEmpAnt, SRA->RA_FILIAL )
					lS1000 := fVld1000( AnoMes(M->RG_DATADEM), @cStatus )
					If !lS1000 .And. cEFDAviso != "2"
						Do Case
							Case cStatus == "-1" // nao encontrado na base de dados
								aAdd(aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130))//"Registro do evento X-XXXX não localizado na base de dados"
								If cEFDAviso == "1"
									DisarmTransaction()
									Return .F.
								EndIf
							Case cStatus == "1" // nao enviado para o governo
								aAdd(aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131))//"Registro do evento X-XXXX não transmitido para o governo"
								If cEFDAviso == "1"
									DisarmTransaction()
									Return .F.
								EndIf
							Case cStatus == "2" // enviado e aguardando retorno do governo
								aAdd(aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132))//"Registro do evento X-XXXX aguardando retorno do governo"
								If cEFDAviso == "1"
									DisarmTransaction()
									Return .F.
								EndIf
							Case cStatus == "3" // enviado e retornado com erro
								aAdd(aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133))//"Registro do evento X-XXXX retornado com erro do governo"
								If cEFDAviso == "1"
									DisarmTransaction()
									Return .F.
								EndIf
						EndCase
					EndIf
				EndIf

				//-----------------------------
				//| Varrendo o grid das verbas
				//| Looping para centralizar dentro do aCols as rubricas iguais
				//--------------------------------------------------------------
				For nI := 1 To Len( aPd )

					//--------------------------------
					//| Montagem da chave de pesquisa
					//| Realiza a montagem da chave de auxilio para localizar registro
					//-----------------------------------------------------------------
					cChaveCCPD	:= aPd[nI,2] + aPd[nI,1]
					cChaveCC	:= aPd[nI,2]
					lTemReg		:= .F.

					nPosCCPD		:= Ascan( @aCols,{|X| X[1] == cChaveCCPD })
					nPosCC		:= Ascan( @aCols,{|X| X[12] == cChaveCC })
					cCodNat 	:= RetValSrv( aPd[nI,1], xFilial("SRV"), "RV_NATUREZ" )
					cCodINCCP 	:= RetValSrv( aPd[nI,1], xFilial("SRV"), 'RV_INCCP' )
					cCodINCIRF  := RetValSrv( aPd[nI,1], xFilial("SRV"), 'RV_INCIRF' )
					cCodINFGTS  := RetValSrv( aPd[nI,1], xFilial("SRV"), 'RV_INCFGTS' )


					If cVersEnvio >= '2.3'
						If (SRA->RA_CATEFD $ cBolsistas + cContrib) .AND. ( cCodNat $ "1409|4050|4051|1009" )
							Loop
						EndIf
					EndIf

					If 	((SRA->RA_CATEFD $  cContrib1) .And. (cCodINCCP  $ '12|21|22|32|51|92|93|94' ) ) .Or.;
						 ((SRA->RA_CATEFD $  cContrib1) .And. (cCodINCIRF  $ '12|13|32|33|42|43|47|52|53|62|63|64|71|92|93')) .Or.;
						 (!(SRA->RA_CATEFD $ '711|712|734') .And. (cCodINCCP  $ '34|35')) .Or.;
						 ((SRA->RA_CATEFD $ '701|711|712|741|751|781') .And. (cCodINCIRF  $ '14|34|54|94'))
						Loop
					EndIf

				 	If (SRA->RA_CATEFD $ cBolsistas) .And. (!(cCodINCCP  $ '00|01') .Or. cCodINFGTS  <> '00')
					 	Loop
					Endif

					//----------------------------------
					//| Centro de Custo x Verba/Rubrica
					//| Realiza o filtro para saber se a verba incide IRRF
					//| Seleciona a Verba dentro do SRA e pega seus respectivos dados
					//| Seleciona o CC    dentro da CTT e pega seus respectivos dados
					//----------------------------------------------------------------
					If ( ( cVersEnvio < "2.6.00" .And. !(SubStr(RetValSrv( aPd[nI,1], xFilial("SRV"), "RV_INCIRF" ), 1, 2) $ "31*32*33*34*35*51*52*53*54*55*81*82*83") ) .Or.;
						( cVersEnvio >= "2.6.00" .And. !(fRetTpIRF( RetValSrv( aPd[nI,1], xFilial("SRV"), "RV_INCIRF" ) ) $ "D|I|J") ) ) .And.;
						!(RetValSrv( aPd[nI,1], xFilial("SRV"), "RV_CODFOL" ) $ "0126|0303")
						//--------------------
						//| Verbas / Rubricas
						//| Guarda a area atual, entra na SRV e recupera os dados da verba
						//------------------------------------------------------------------
						aAreaSRV := GetArea()
						DBSelectArea("SRV")
						SRV->(DbSetOrder(1))
						If( SRV->( dbSeek( xFilial("SRV") + aPd[nI,1]  ) ) )

							//Tratamento de compartilhamento da tabela SRV
						If !Empty(xFilial("SRV"))
								lGeraCod := .T.
							Else
								lSemFilSRV := .T.
							EndIf

							//------------------
							//| Lógica lGeraCod
							//| .T. -> Exclusiva | .F. -> Compartilhada
							//------------------------------------------
							If lGeraCod
								cIdeRubr := Iif(!Empty(SRV->RV_FILIAL),SRV->RV_FILIAL , (xFilial("SRV"),SRV->RV_FILIAL) )
							Else
								If cVersEnvio >= "2.3"
									cIdeRubr := cEmpAnt
								Else
									cIdeRubr := ""
								EndIf
							Endif

							If lMiddleware
								If lPrimIdT
									lPrimIdT  := .F.
									cIdTabRub := fGetIdRJF( Iif(!Empty(SRV->RV_FILIAL), SRV->RV_FILIAL, (xFilial("SRV"), SRV->RV_FILIAL) ), cIdeRubr )
									If Empty(cIdTabRub)
										aAdd(aErros, OemToAnsi(STR0140) + cIdeRubr + OemToAnsi(STR0141))//"Não será possível efetuar a integração. O identificador de tabela de rubrica do código: "##" não está cadastrado."
										DisarmTransaction()
										Return .F.
									EndIf
								EndIf
								cIdeRubr := cIdTabRub
							EndIf

							cCodRubr := SRV->RV_COD		//Codigo  da Rubrica
							If (SRV->RV_PERC - 100) < 0
								cPrcRubr :=	0	//Percent da Rubrica
							Else
								cPrcRubr := SRV->RV_PERC - 100//Percent da Rubrica
							EndIf

							//----------------------------------------
							//| Recuperar a natureza da verba
							//| Se estiverem vazias, vão para a geração do log
							//-------------------------------------------------
							If Empty( SRV->RV_NATUREZ )
								If( Len(aErros) == 0 )
									aAdd(aErros, OemToAnsi( STR0054 ))
									aAdd(aErros, SRV->RV_COD + " - " + AllTrim( SRV->RV_DESC ) )
								Else
									aAdd(aErros, SRV->RV_COD + " - " + AllTrim( SRV->RV_DESC ) )
								EndIf
							ElseIf ((cVersEnvio < '2.6.00' .And. SRV->RV_NATUREZ == "9219") .Or. cVersEnvio >= '2.6.00') .And. !lCarrDep
								//-----------------
								//| Plano de Saude
								//| Se a verba corrente tiver natureza de rubrica '9219' de plano de saude
								//| Entra na tabela RHR - Plano de Saude, localiza o registro do funcionário
								//| Verifica se o registro foi integrado com a folha, se sim: alimenta array
								//---------------------------------------------------------------------------
								aAreaRCH := GetArea()
								DbSelectArea("RCH")
								RCH->( dbsetOrder( Retorder( "RCH" , "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG" ) ) )
								cProces  := SRA->RA_PROCES
								cPeriodo := ANoMes(M->RG_DATADEM)
								cNumPag  := M->RG_SEMANA
								RCH->( dbSeek( xFilial("RCH") + cProces + cTipoPLA + cPeriodo + cNumPag ) )
								If Empty(RCH->RCH_DTFECH)
									cTabRH := "RHR"
								Else
									cTabRH := "RHS"
								EndIf
								RestArea(aAreaRCH)
								GetRAssMed( SRA->RA_FILIAL, SRA->RA_MAT, "S016", cVersEnvio, ANoMes(M->RG_DATADEM), @aDadosRHST, @aDadosRHSD, cTabRH, @lCPFDepOk, @aDepAgreg )
								lCarrDep := .T.
								cVbPla 	 += SRV->RV_COD + "/"
							EndIf

						EndIf
						RestArea(aAreaSRV)

						//------------------------------------------------
						//| Centro de Custo
						//| Guarda a area atual, entra na CTT e recupera os dados do cc
						//---------------------------------------------------------------
						If !lVerRJ5
							aAreaCTT := GetArea()
							DBSelectArea("CTT")
							CTT->(DbSetOrder(1))
							If( CTT->( dbSeek( xFilial("CTT") + aPd[nI,2]  ) ) )
								cCodLot := IIf(lSemFilCTT, CTT->CTT_CUSTO, CTT->CTT_FILIAL+CTT->CTT_CUSTO )
								cTpLot  := CTT->CTT_TPLOT	// Tipo de Lotação (?!?)

								If CTT->CTT_TPLOT == "01" .And. CTT->CTT_TIPO2 == "4" .And. CTT->CTT_CLASSE == "2"
									cTpInscr 	:= CTT->CTT_TIPO2 // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
									cInscr 		:= CTT->CTT_CEI2 // Codigo da inscricao
									cChaveS1005	:= xFilial("CTT", SRA->RA_FILIAL)+cInscr
								EndIf
							EndIf
							RestArea(aAreaCTT)
						Else
							If cCCAnt != cChaveCC
								cCCAnt 		:= cChaveCC
								cCodLot		:= ""
								lSemFilRJ5 	:= Empty(xFilial("RJ5"))
								RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
								If RJ5->( !dbSeek( xFilial("RJ5", M->RA_FILIAL) + cChaveCC ) )
									If aScan(aErrosRJ5, { |x| x == cChaveCC }) == 0
										aAdd( aErrosRJ5, cChaveCC )
									EndIf
								Else
									If lRJ5FilT
										RJ5->(DbSetOrder(7)) //RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
										RJ5->(dbGoTop())
										RJ5->( dbSeek( xFilial("RJ5", M->RA_FILIAL) + cChaveCC + SRA->RA_FILIAL) )
										While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", M->RA_FILIAL) .And. RJ5->RJ5_CC == cChaveCC .And. RJ5->RJ5_FILT == SRA->RA_FILIAL
											If AnoMes( Iif(FunName() $ cFncSemVer, M->RA_DEMISSA, M->RG_DATADEM) ) >= RJ5->RJ5_INI
												cTpInscr	:= RJ5->RJ5_TPIO
												cInscr  	:= RJ5->RJ5_NIO
												cCodLot		:= IIf(lSemFilRJ5, RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
												cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
												lTemReg		:= .T.
											EndIf
											RJ5->( dbSkip() )
										EndDo
										//Se não encontrou um registro com código preenchido reposiciona a tabela e executa o dbseek novamente.
										If !lTemReg
											RJ5->(DbSetOrder(4)) //RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
											RJ5->(dbGoTop())
											RJ5->( dbSeek( xFilial("RJ5", M->RA_FILIAL) + cChaveCC ) )
											While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", M->RA_FILIAL) .And. RJ5->RJ5_CC == cChaveCC .And. EMPTY(RJ5->RJ5_FILT)
												If AnoMes( Iif(FunName() $ cFncSemVer, M->RA_DEMISSA, M->RG_DATADEM) ) >= RJ5->RJ5_INI
													cTpInscr	:= RJ5->RJ5_TPIO
													cInscr  	:= RJ5->RJ5_NIO
													cCodLot		:= IIf(lSemFilRJ5, RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
													cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
												EndIf
												RJ5->( dbSkip() )
											EndDo
										EndIf
									Else
										While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", M->RA_FILIAL) .And. RJ5->RJ5_CC == cChaveCC
											If AnoMes( Iif(FunName() $ cFncSemVer, M->RA_DEMISSA, M->RG_DATADEM) ) >= RJ5->RJ5_INI
												cTpInscr	:= RJ5->RJ5_TPIO
												cInscr  	:= RJ5->RJ5_NIO
												cCodLot		:= IIf(lSemFilRJ5, RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
												cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
											EndIf
											RJ5->( dbSkip() )
										EndDo
									EndIf
									If Empty(cCodLot)
										If aScan(aErrosRJ5, { |x| x == cChaveCC }) == 0
											aAdd( aErrosRJ5, cChaveCC )
										EndIf
									Else
										aAdd(aRelacRJ5, { cChaveCC, cCodLot })
									EndIf
								EndIf
							EndIf
							nPosCCPD	:= Ascan( @aCols,{|X| X[20] == cCodLot + aPd[nI,1] })
							nPosCC		:= Ascan( @aCols,{|X| X[19] == cCodLot })
						EndIf

						If Empty(cTpInscr) .OR. Empty(cInscr)
							If fBuscaOBRA( SRA->RA_FILIAL, @cCEIObra )
								cTpInscr 	:= "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
								cInscr 	 	:= cCEIObra // Codigo da inscricao
								cChaveS1005	:= cFilEnv+cInscr
							Elseif fBuscaCAEPF( cFilEnv, @cCAEPF )
								cTpInscr 	:= "3"
								cInscr	 	:= cCAEPF
								cChaveS1005	:= cFilEnv+cInscr
							Else
								nPosEstb 	:= aScan(aEstb, {|x| x[1] == AllTrim(SRA->RA_FILIAL)})
								If nPosEstb > 0
									cTpInscr	:= aEstb[nPosEstb,3]
									cInscr		:= aEstb[nPosEstb,2]
									cChaveS1005	:= cFilEnv+cInscr
								EndIf
							EndIf
						EndIf

						//Contagem da quantidade de CCs citados na rescisao
						If(nPosCC == 0)
							aAdd(aDadosCCT, {cChaveCC, cTpInscr, cInscr, cCodLot, cChaveS1005 } )
						EndIf

						//------------------------------------------------
						//| Array de Dados
						//| Montagem do array com os dados a utilizar para o XML
						//-------------------------------------------------------
						If( nPosCCPD > 0 )
							aCols[nPosCCPD, 15] += aPd[nI,4]	//Incrementa Horas
							aCols[nPosCCPD, 17] += aPd[nI,5]	//Incrementa Valor
							aCols[nPosCCPD, 18] := aCols[nPosCCPD, 18] + 1	  	//Incrementa Contador
						Else
							aAdd(aCols, { 	aPd[nI,2]+ aPd[nI,1],;		//01 - Chave para pesquisa (CC+PD)
												"Dados da Verba",;		//02 - Separador - Verbas/Rubricas
												cCodRubr,;				//03 - Codigo da Rubrica
												cIdeRubr,;				//04 - Ident   da Rubrica
												cPrcRubr,;				//05 - Percent da Rubrica
												"Dados do CC",;			//06 - Separador - Centro de Custo
												cCodLot,;				//07 - Codigo da Lotação
												cTpInscr,;				//08 - Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
												cInscr,;				//09 - Codigo da inscricao
												cTpLot,;				//10 - Tipo de Lotação (?!?)
												"Dados da Grid",;		//11 - Separador - Centro de Custo
												aPd[nI,2],;				//12 - Centro de Custo
												aPd[nI,1],;				//13 - Verba da rescisão
												"",;					//14 - Descricao da verba
												aPd[nI,4],;				//15 - Horas da verba
												aPd[nI,5],;				//16 - Valor da verba
												aPd[nI,5],;				//17 - Acumulado da verba (valor inicial para soma)
												1,; 					//18 - Numero de registro repetidos (CC + PD)
												cCodLot,;				//19 - Código de lotação
												cCodLot + aPd[nI,1],;	//20 - Chave para pesquisa (Código Lotação+PD)
												SRV->RV_NATUREZ,;		//21 - Natureza da verba
												SRV->RV_INCCP,;			//22 - Incidência CP da verba
												SRV->RV_INCFGTS,;		//23 - Incidência FGTS da verba
												SRV->RV_INCIRF,;		//24 - Incidência IRRF da verba
												SRV->RV_TIPOCOD})		//25 - Tipo da verba
						EndIf
					EndIf

					//----------------------
					//| Liquido da Rescisão
					//| Se a verba corrente tiver o ID de Calculo igual
					//| a 0126 O Sistema receberá o valor líquido da rescisão
					//--------------------------------------------------------
					If RetValSrv( aPd[nI,1], xFilial("SRV"), "RV_CODFOL" ) $ "0126"
						nValor := aPd[nI,5]
					EndIf

					//---------------------
					//| Pensão Alimenticia
					//| Se a verba corrente tiver valor de DIRF igual aos informados
					//| Realizará a soma do montante pago de pensão Alimenticia
					//-----------------------------------------------------------
					If ( ( cVersEnvio < "2.6.00" .And. SubStr(RetValSrv( aPd[nI,1], xFilial("SRV"), "RV_INCIRF" ), 1, 2) $ "51|52|53|54|55" ) .Or.;
						( cVersEnvio >= "2.6.00" .And. RetValSrv( aPd[nI,1], xFilial("SRV"), "RV_INCIRF" ) $ "51  |52  |53  |54  |55  " ) )
						nPensao += aPd[nI,5]
					EndIf

					//------------------------------
					//| Verba de Multiplos Vinculos
					//| Se a verba corrente, tiver seu ID de Calculo igual a 0318
					//| realizará a procura dos multiplos vínculos do funcionário
					//------------------------------------------------------------
					If RetValSrv( aPd[nI,1], xFilial("SRV"), "RV_CODFOL" ) $ "0318"
						aAreaRAZ := GetArea()
						DBSelectArea("RAZ")
						RAZ->(DbSetOrder(1))
						If( RAZ->( dbSeek( xFilial("RAZ") + SRA->RA_MAT ) ) )
							aDadosRAZ := GetMulVin( SRA->RA_FILIAL , SRA->RA_MAT)

						EndIf
					EndIf

				Next nI

				//Tratando o Log
				If( Len(aErros) > 1 ) //Maior que 1 pois sempre vai existir o cabeçalho do log de erros
					If !lMiddleware
						aAdd(aErros, OemToAnsi( STR0055 ) + " " + OemToAnsi( STR0056 ) ) //"estão sem código de rubrica cadastrada (RV_NATUREZ)." "Não será possível integração com o TAF e a efetivação da rescisão."
					Else
						aAdd(aErros, OemToAnsi( STR0055 ) + " " + OemToAnsi( STR0159 ) ) //"estão sem código de rubrica cadastrada (RV_NATUREZ)." "Não será possível integração com o Middleware e a efetivação da rescisão."
					EndIf
					DisarmTransaction()
					Return !lGravou
				EndIf

				If !Empty(aErrosRJ5)
					aAdd( aErros, OemToAnsi(STR0114) )//"Não será possível efetuar a integração. O(s) centro(s) de custo: "
					For nI := 1 To Len(aErrosRJ5)
						aAdd( aErros, aErrosRJ5[nI] )
					Next
					aAdd( aErros, OemToAnsi(STR0115) ) //" não está(ão) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
					DisarmTransaction()
					Return .F.
				EndIf

				//Ordena o Array separando por centro de custo
				//ASORT(aCols, , , { | x,y | x[2] < y[2] } )

				If !lMiddleware
					fGp23Cons(@aFilInTaf, {SRA->RA_FILIAL}, @cFilEnv)
				EndIf

				If Empty(cFilEnv)
					cFilEnv:= cFilAnt
				EndIf

				If cVersEnvio >= '2.5.00' .And. SRA->RA_CATEFD $ "201|202|721"
					fBusCadBenef(@aCodBenef,"FOL")
					For nI := 1 to len(aCodBenef)
						If ( aCodBenef[nI,15] == "S" ) //Apenas se Imprime % no Termo de Rescisao.
							nPerPens += aCodBenef[nI,2]
						EndIf
					Next nI

					nI := 0
				Endif

				DbSelectArea("SRX")
				SRX->(DbSetOrder(1))
				If SRX->(MsSeek(xFilial("SRX",SRA->RA_FILIAL) + "14"))
					DbSkip(3)
					cSimples := SubsTr(SRX->RX_TXT,17,1)
					If cSimples == "1"
						cIndSimp := SubsTr(SRX->RX_TXT,49,1)
					EndIf
				EndIf


				//Se vier da rotina de rescisão, da carga na variável de memória
				RegToMemory("SRA",,,.F.)

				//-------------------
				//| Inicio do XML
				//-------------------
				If lMiddleware
					aInfos   := fXMLInfos()
					IF Len(aInfos) >= 4
						cTpInsc  := aInfos[1]
						lAdmPubl := aInfos[4]
						cNrInsc  := aInfos[2]
						cId  	 := aInfos[3]
					Else
						cTpInsc  := ""
						lAdmPubl := .F.
						cNrInsc  := "0"
					EndIf

					cChave := Iif( cVersEnvio >= "9.0" .And. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA ) )
					cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2399" + Padr(cChave, fTamRJEKey(), " ")
					cStat2399 	:= "-1"
					GetInfRJE( 2, cChaveBus, @cStat2399, @cOper2399, @cRetf2399, @nRec2399, @cRecib2399, @cRecibAnt, Nil, Nil, .T. )

					//Retorno pendente impede o cadastro
					If cStat2399 == "2" .And. cEFDAviso != "2"
						cMsgRJE 	:= STR0134//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
					EndIf
					//Inclusão
					If nOpc != 5
						//Evento de exclusão sem transmissão impede o cadastro
						If cOper2399 == "E" .And. cStat2399 != "4" .And. cEFDAviso != "2"
							cMsgRJE 	:= STR0135//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
						ElseIf cStat2399 == "99"
							cMsgRJE 	:= STR0146//"Operação não será realizada pois há evento de exclusão pendente para transmissão"
						//Não existe na fila, será tratado como inclusão
						ElseIf cStat2399 == "-1"
							cOperNew 	:= "I"
							cRetfNew	:= "1"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						//Evento sem transmissão, irá sobrescrever o registro na fila
						ElseIf cStat2399 $ "1/3"
							cOperNew 	:= cOper2399
							cRetfNew	:= cRetf2399
							cStatNew	:= "1"
							lNovoRJE	:= .F.
						//Evento diferente de exclusão transmitido, irá gerar uma retificação
						ElseIf cOper2399 != "E" .And. cStat2399 == "4"
							cOperNew 	:= "A"
							cRetfNew	:= "2"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						//Evento de exclusão transmitido, será tratado como inclusão
						ElseIf cOper2399 == "E" .And. cStat2399 == "4"
							cOperNew 	:= "I"
							cRetfNew	:= "1"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						EndIf
					//Exclusão
					Else
						//Evento de exclusão sem transmissão impede o cadastro
						If cOper2399 == "E" .And. cStat2399 != "4" .And. cEFDAviso != "2"
							cMsgRJE 	:= STR0135//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
						//Evento diferente de exclusão transmitido irá gerar uma exclusão
						ElseIf cOper2399 != "E" .And. cStat2399 == "4"
							cOperNew 	:= "E"
							cRetfNew	:= cRetf2399
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						EndIf
					EndIf
					If !Empty(cMsgRJE)
						aAdd( aErros, OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0137) + CRLF + cMsgRJE )//" não enviado(a) ao Middleware. Erro: "
						DisarmTransaction()
						Return .F.
					EndIf
					If cRetfNew == "2"
						If cStat2399 == "4"
							cRecibXML 	:= cRecib2399
							cRecibAnt	:= cRecib2399
							cRecib2399	:= ""
						Else
							cRecibXML 	:= cRecibAnt
						EndIf
					EndIf
					aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2399", Space(6), cChave, cId, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew, cRecib2399, cRecibAnt } )
					cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtTSVTermino/v" + cVersMw + "'>"
					cXML += 	"<evtTSVTermino Id='" + cId + "'>"
					fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, 1, 1, "12" }, cVersEnvio, aInfos)
					fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
				Else
					cXml := "<eSocial>"
					cXml += "	<evtTSVTermino>"
				EndIf
				cXml += '		<ideTrabSemVinculo>'
				cXml += '			<cpfTrab>' + Alltrim( M->RA_CIC ) + '</cpfTrab>'
				If cVersEnvio < "9.0" .And. (!lMiddleware .Or. !Empty(M->RA_PIS))
					cXml += '		<nisTrab>' + ALLTRIM( M->RA_PIS )	+ '</nisTrab>'
				ElseIf lGeraMat
					cXml += '		<matricula>' + ALLTRIM( M->RA_CODUNIC )	+ '</matricula>'
				EndIf
				If cVersEnvio < "9.0" .Or. !lGeraMat
					cXml += '			<codCateg>' + AllTrim( M->RA_CATEFD ) + '</codCateg>'
				EndIf
				cXml += '		</ideTrabSemVinculo>'
				cXml += '		<infoTSVTermino>'

				//Se for de rescisão, não tem data de Demissão definida, então pega variável auxiliar
				If( FunName() $ cFncSemVer )
					If !lMiddleware
						cXml += '			<dtTerm>' + AllTrim( DtoS(M->RA_DEMISSA) ) + '</dtTerm>'
					Else
						cXml += '			<dtTerm>' + SubStr( dToS(M->RA_DEMISSA), 1, 4 ) + "-" + SubStr( dToS(M->RA_DEMISSA), 5, 2 ) + "-" + SubStr( dToS(M->RA_DEMISSA), 7, 2 ) + '</dtTerm>'
					EndIf
					//Motivo de desligamento de Diretor não empregado (CatEfd = 721)
					If !lMiddleware .And. M->RA_CATEFD $ '721'
						cXml += '			<mtvDesligTSV>' + '</mtvDesligTSV>'
					EndIf
				Else
					If !lMiddleware
						cXml += '			<dtTerm>' + AllTrim( DtoS(dDataDem1) ) + '</dtTerm>'
					Else
						cXml += '			<dtTerm>' + SubStr( dToS(dDataDem1), 1, 4 ) + "-" + SubStr( dToS(dDataDem1), 5, 2 ) + "-" + SubStr( dToS(dDataDem1), 7, 2 ) + '</dtTerm>'
					EndIf
					//Motivo de desligamento de Diretor não empregado (CatEfd = 721)
					If (!lMiddleware .Or. !Empty(M->RG_TPDIR)) .And. M->RA_CATEFD $ '721'
						cXml += '			<mtvDesligTSV>' + AllTrim(M->RG_TPDIR) + '</mtvDesligTSV>'
					EndIf
				EndIf

				//Tag's de pensão alimentícia - Leiaute 2.5
				If cVersEnvio >= '2.5.00' .And. SRA->RA_CATEFD $ "201|202|721"

					//Pensao Alimenticia
					If nPerPens <> 0 .and. nPensao <> 0
						cXml +=				'<pensAlim>3</pensAlim>'
					Elseif nPerPens == 0 .and. nPensao == 0
						cXml +=				'<pensAlim>0</pensAlim>'
					Elseif nPerPens <> 0 .and. nPensao == 0
						cXml +=				'<pensAlim>1</pensAlim>'
					Elseif nPerPens == 0 .and. nPensao <> 0
						cXml +=				'<pensAlim>2</pensAlim>'
					Endif

					//Percentual Alimenticio
					If nPerPens <>0
						cXml +=				'<percAliment>' + Alltrim(Str(nPerPens)) + '</percAliment>'
					Endif

					//VR Alimentacao
					If nPensao <>0
						cXml +=				'<vrAlim>' + Alltrim(Str(nPensao)) + '</vrAlim>'
					Endif

				Endif

				//------------------------------------------------------------------------------------------------------------------------------
				//| Se vier do GPEA010 (Cad. Func) ou GPEA265 (Cad. Auton). Não deverá entrar neste bloco.
				//| Só entrará se vier das rotinas de demissões (GPEM040 ou GPEM630) e se o array com dados do CTT estiver preenchido
				//| A partir da versão 9.0 só entrar se a categoria for 721 e dtTerm for superior à data de inicio da obrigatoriedade dos eventos periódicos
				//------------------------------------------------------------------------------------------------------------------------------
				If !(FunName() $ cFncSemVer) .AND. LEN(aDadosCCT) > 0 .And. (cVersEnvio < "9.0" .Or. SRA->RA_CATEFD == "721" .And. M->RG_DATADEM >= dDtCgini)
					If lMiddleware
						fExcRJO(SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, "S-2399")
					EndIf

					cXml += '			<verbasResc>'

					// Se for envio de rescisão complementar busca os valores pagos nas rescisões anteriores
					If lResComp .Or. lRetif
						fResCom(@cXml, oModel, aDadosCCT, cVBDiss, cIndSimp, lRetif, @aCols, cVersEnvio, aRelacRJ5, @aErrosRJ5)
					EndIf

					If cVersEnvio >= '2.3'
						cIdDmDev := "R" + cEmpAnt + Alltrim(xFilial("SRG")) +  SRA->RA_MAT + If(lRetif, "C", "") + If(Empty(nContRes), (++nContRes, ""), cValToChar(nContRes++))
					EndIf

					cXml += '				<dmDev>'
					cXml += '					<ideDmDev>' + cIdDmDev + '</ideDmDev>'

					//Looping para detalhar os Centros de Custos que o Trab Atuou
					For nZ := 1 To Len( aDadosCCT )
						If !((!lVerRJ5 .And. aScan(aCols, { |x| x[12] == aDadosCCT[nZ,1] .And. x[17] > 0 }) > 0) .Or.;
							(lVerRJ5 .And. aScan(aCols, { |x| x[19] == aDadosCCT[nZ,4] .And. x[17] > 0 }) > 0))
							Loop
						EndIf
						cXml += "						<ideEstabLot>"
						cXml += "							<tpInsc>" + If(Empty(aDadosCCT[nZ,2]),cTpInscr,aDadosCCT[nZ,2]) + "</tpInsc>"
						cXml += "							<nrInsc>" + If(Empty(aDadosCCT[nZ,3]),cInscr,aDadosCCT[nZ,3]) + "</nrInsc>"
						cXml += "							<codLotacao>" + StrTran( aDadosCCT[nZ,4], "&", "&amp;") + "</codLotacao>"

						//Looping nas verbas vindas
						For nX := 1 To Len( aCols )
							//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
							If ( ((!lVerRJ5 .And. aCols[nX, 12] == aDadosCCT[nZ,1]) .Or. (lVerRJ5 .And. aCols[nX, 19] == aDadosCCT[nZ,4])) .And. aCols[nX, 17] > 0 )
								cXml += "							<detVerbas>"
								cXml += "								<codRubr>" + aCols[nX,3] + "</codRubr>"
								cXml += "								<ideTabRubr>" + aCols[nX,4] + "</ideTabRubr>"
								If !lMiddleware .Or. !Empty(aCols[nX,15])
									cXml += "							<qtdRubr>" + Str(aCols[nX,15]) + "</qtdRubr>"
								EndIf
								If !lMiddleware .Or. !Empty(aCols[nX,5])
									cXml += "							<fatorRubr>" + AllTrim( Transform(aCols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
								EndIf
								If cVersEnvio < "9.0" .And. (!lMiddleware .Or. !Empty(aCols[nX,16]))
									If !lMiddleware
										cXml += "							<vrUnit>" + AllTrim( Transform(aCols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
									Else
										cXml += "							<vrUnit>" + AllTrim( Str(aCols[nX,16]) ) + "</vrUnit>"
									EndIf
								EndIf
								If !lMiddleware
									cXml += "								<vrRubr>" + AllTrim( Transform(aCols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
								Else
									cXml += "								<vrRubr>" + AllTrim( Str(aCols[nX,17]) ) + "</vrRubr>"
								EndIf
								If cVersEnvio >= "9.0" .And. cValToChar(year(M->RG_DATADEM)) >= "2021"
									cXml += "								<indApurIR>0</indApurIR>"
								EndIf
								cXml += "							</detVerbas>"
								If aCols[nX,3] $ cVbPla
									lGerPla := .T.
								EndIf
								If lMiddleware .And. ( (aCols[nX, 21] == "9901" .And. aCols[nX, 25] == "3") .Or. (aCols[nX, 21] == "9201" .And. aCols[nX, 22] $ "31/32") .Or. (aCols[nX, 21] == "1409" .And. aCols[nX, 22] == "51") .Or. (aCols[nX, 21] == "4050" .And. aCols[nX, 22] == "21") .Or. (aCols[nX, 21] == "4051" .And. aCols[nX, 22] == "22") .Or. (aCols[nX, 21] == "9902" .And. aCols[nX, 25] == "3") .Or. (aCols[nX, 21] == "9904" .And. aCols[nX, 25] == "3") .Or. (aCols[nX, 21] == "9908" .And. aCols[nX, 25] == "3") )
									fGrvRJO(SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aDadosCCT[nZ, 2], aDadosCCT[nZ, 3], aDadosCCT[nZ, 4], aCols[nX, 21], aCols[nX, 25], aCols[nX, 22], aCols[nX, 23], aCols[nX, 25], aCols[nX, 17], "S-2399", , , ,aCols[nX, 26], aCols[nX, 27] )
								EndIf
							EndIf
						Next

						//Plano de Saude //Necessário rever o dependente
						If cVersEnvio < "9.0" .And. Len(aDadosRHST) > 0 .And. lGerPla
							cXml += "							<infoSaudeColet>"
							For nW := 1 To Len(aDadosRHST)
								cXml += "								<detOper>"
								cXml += "									<cnpjOper>" + aDadosRHST[nW,6] + "</cnpjOper>"
								cXml += "									<regANS>" + aDadosRHST[nW,7] + "</regANS>"
								If !lMiddleware
									cXml += "									<vrPgTit>" + AllTrim( Transform(aDadosRHST[nW,8],"@E 999999999.99") ) + "</vrPgTit>"
								Else
									cXml += "									<vrPgTit>" + AllTrim( Str(aDadosRHST[nW,8]) ) + "</vrPgTit>"
								EndIf
								If( Len(aDadosRHSD) > 0 )
									For nY := 1 to Len(aDadosRHSD)
										If ( aDadosRHST[nW][6] + aDadosRHST[nW][7] == aDadosRHSD[nY][7] + aDadosRHSD[nY][8] )
											cXml += "									<detPlano>"
											If cVersEnvio >= '2.3'
												cXml += "				               		<tpDep>"+aDadosRHSD[nY,5]+"</tpDep>"
											EndIf
											If !lMiddleware .Or. !Empty(aDadosRHSD[nY,1])
												cXml += "									<cpfDep>" + aDadosRHSD[nY,1] + "</cpfDep>"
											EndIf
											cXml += "										<nmDep>" + aDadosRHSD[nY,2] + "</nmDep>"
											If !lMiddleware
												cXml += "										<dtNascto>" + aDadosRHSD[nY,3] + "</dtNascto>"
											Else
												cXml += "										<dtNascto>" + SubStr( aDadosRHSD[nY,3], 1, 4 ) + "-" + SubStr( aDadosRHSD[nY,3], 5, 2 ) + "-" + SubStr( aDadosRHSD[nY,3], 7, 2 ) + "</dtNascto>"
											EndIf
											If !lMiddleware
												cXml += "										<vlrPgDep>" + AllTrim( Transform(aDadosRHSD[nY,4],"@E 999999999.99") ) + "</vlrPgDep>"
											Else
												cXml += "										<vlrPgDep>" + AllTrim( Str(aDadosRHSD[nY,4]) ) + "</vlrPgDep>"
											EndIf
											cXml += "									</detPlano>"
										Endif
									Next
								EndIf
								cXml += "								</detOper>"
							Next
							cXml += "							</infoSaudeColet>"
							aDadosRHST	:= {}
						EndIf
						If M->RA_CATEFD $ "738/731/734/201/202/"
							cXml += "							<infoAgNocivo>"
							cXml += "								<grauExp>" + Alltrim(M->RA_OCORREN) + "</grauExp>"
							cXml += "							</infoAgNocivo>"
						EndIf
						If !lMiddleware .Or. !Empty(cIndSimp)
							cXml += "							<infoSimples>"
							cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
							cXml += "							</infoSimples>"
						EndIf
						cXml += "						</ideEstabLot>"
					Next
					cXml += '				</dmDev>'

					//Validação para verificar se gera o dmDev do PLR pago antes da rescisão no mesmo período
					fPLR2399( @cXml, oModel, aDadosCCT, cIndSimp, dDataRes)

					//Validação para verificar se gera o dmDev do ADI
					fADI2299( @aAdiCC, @aAdiCols, cFilEnv, @cIdDmDev, cVersEnvio, lRetif, @aErrosRJ5 )

					If !Empty(aErrosRJ5)
						aAdd( aErros, OemToAnsi(STR0114) )//"Não será possível efetuar a integração. O(s) centro(s) de custo: "
						For nI := 1 To Len(aErrosRJ5)
							aAdd( aErros, aErrosRJ5[nI] )
						Next
						aAdd( aErros, OemToAnsi(STR0115) ) //" não está(ão) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
						DisarmTransaction()
						Return .F.
					EndIf

					//Looping para varrer as verbas
					If Len(aAdiCols) > 0
						cXml += '				<dmDev>'
						cXml += '					<ideDmDev>' + cIdDmDev + '</ideDmDev>'

						//Looping para detalhar os Centros de Custos que o Trab Atuou
						For nZ := 1 To Len( aAdiCC )
							cXml += "						<ideEstabLot>"
							cXml += "							<tpInsc>" + If(Empty(aAdiCC[nZ,2]),cTpInscr,aAdiCC[nZ,2]) + "</tpInsc>"
							cXml += "							<nrInsc>" + If(Empty(aAdiCC[nZ,3]),cInscr,aAdiCC[nZ,3]) + "</nrInsc>"
							cXml += "							<codLotacao>" + StrTran( aAdiCC[nZ,4], "&", "&amp;") + "</codLotacao>"
							//Looping nas verbas vindas
							For nX := 1 To Len( aAdiCols )
								//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
								If( ((!lVerRJ5 .And. aAdiCols[nX, 12] == aAdiCC[nZ,1]) .Or. (lVerRJ5 .And. aAdiCols[nX, 19] == aAdiCC[nZ,4])) .And. aAdiCols[nX, 17] > 0 )
									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + aAdiCols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + aAdiCols[nX,4] + "</ideTabRubr>"
									If !lMiddleware .Or. !Empty(aAdiCols[nX,15])
										cXml += "							<qtdRubr>" + Str(aAdiCols[nX,15]) + "</qtdRubr>"
									EndIf
									If !lMiddleware .Or. !Empty(aAdiCols[nX,5])
										cXml += "							<fatorRubr>" + AllTrim( Transform(aAdiCols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									EndIf
									If cVersEnvio < "9.0" .And. (!lMiddleware .Or. !Empty(aAdiCols[nX,16]))
										If !lMiddleware
											cXml += "							<vrUnit>" + AllTrim( Transform(aAdiCols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "							<vrUnit>" + AllTrim( Str(aAdiCols[nX,16]) ) + "</vrUnit>"
										EndIf
									EndIf
									If !lMiddleware
										cXml += "								<vrRubr>" + AllTrim( Transform(aAdiCols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(aAdiCols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersEnvio >= "9.0" .And. cValToChar(year(M->RG_DATADEM)) >= "2021"
										cXml += "								<indApurIR>0</indApurIR>"
									EndIf
									cXml += "							</detVerbas>"

									If lMiddleware .And. ( (aAdiCols[nX, 21] == "9901" .And. aAdiCols[nX, 25] == "3") .Or. (aAdiCols[nX, 21] == "9201" .And. aAdiCols[nX, 22] $ "31/32") .Or. (aAdiCols[nX, 21] == "1409" .And. aAdiCols[nX, 22] == "51") .Or. (aAdiCols[nX, 21] == "4050" .And. aAdiCols[nX, 22] == "21") .Or. (aAdiCols[nX, 21] == "4051" .And. aAdiCols[nX, 22] == "22") .Or. (aAdiCols[nX, 21] == "9902" .And. aAdiCols[nX, 25] == "3") .Or. (aAdiCols[nX, 21] == "9904" .And. aAdiCols[nX, 25] == "3") .Or. (aAdiCols[nX, 21] == "9908" .And. aAdiCols[nX, 25] == "3") )
										fGrvRJO(SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aAdiCC[nZ, 2], aAdiCC[nZ, 3], aAdiCC[nZ, 4], aAdiCols[nX, 21], aAdiCols[nX, 25], aAdiCols[nX, 22], aAdiCols[nX, 23], aAdiCols[nX, 24], aAdiCols[nX, 17], "S-2399", , , ,aAdiCols[nX, 26], aAdiCols[nX, 27] )
									EndIf
								EndIf
							Next

							If M->RA_CATEFD $ "738/731/734/201/202/"
								cXml += "							<infoAgNocivo>"
								cXml += "								<grauExp>" + Alltrim(M->RA_OCORREN) + "</grauExp>"
								cXml += "							</infoAgNocivo>"
							EndIf
							If !lMiddleware .Or. !Empty(cIndSimp)
								cXml += "							<infoSimples>"
								cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
								cXml += "							</infoSimples>"
							EndIf
							cXml += "						</ideEstabLot>"
						Next
						cXml += '				</dmDev>'
					EndIf

					//Validação para verificar se gera o dmDev do ADI
					f1312299( @a131CC, @a131Cols, cFilEnv, @cIdDmDev, lRetif, @aErrosRJ5,cVersEnvio )

					If !Empty(aErrosRJ5)
						aAdd( aErros, OemToAnsi(STR0114) )//"Não será possível efetuar a integração. O(s) centro(s) de custo: "
						For nI := 1 To Len(aErrosRJ5)
							aAdd( aErros, aErrosRJ5[nI] )
						Next
						aAdd( aErros, OemToAnsi(STR0115) ) //" não está(ão) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
						DisarmTransaction()
						Return .F.
					EndIf

					//Looping para varrer as verbas
					If Len(a131Cols) > 0
						cXml += '				<dmDev>'
						cXml += '					<ideDmDev>' + cIdDmDev + '</ideDmDev>'

						//Looping para detalhar os Centros de Custos que o Trab Atuou
						For nZ := 1 To Len( a131CC )
							cXml += "						<ideEstabLot>"
							cXml += "							<tpInsc>" + If(Empty(a131CC[nZ,2]),cTpInscr,a131CC[nZ,2]) + "</tpInsc>"
							cXml += "							<nrInsc>" + If(Empty(a131CC[nZ,3]),cInscr,a131CC[nZ,3]) + "</nrInsc>"
							cXml += "							<codLotacao>" + StrTran( a131CC[nZ,4], "&", "&amp;") + "</codLotacao>"

							//Looping nas verbas vindas
							For nX := 1 To Len( a131Cols )
								//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
								If( ((!lVerRJ5 .And. a131Cols[nX, 12] == a131CC[nZ,1]) .Or. (lVerRJ5 .And. a131Cols[nX, 19] == a131CC[nZ,4])) .And. a131Cols[nX, 17] > 0 )
									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + a131Cols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + a131Cols[nX,4] + "</ideTabRubr>"
									If !lMiddleware .Or. !Empty(a131Cols[nX,15])
										cXml += "							<qtdRubr>" + Str(a131Cols[nX,15]) + "</qtdRubr>"
									EndIf
									If !lMiddleware .Or. !Empty(a131Cols[nX,5])
										cXml += "							<fatorRubr>" + AllTrim( Transform(a131Cols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									EndIf
									If cVersEnvio < "9.0" .And. (!lMiddleware .Or. !Empty(a131Cols[nX,16]))
										If !lMiddleware
											cXml += "							<vrUnit>" + AllTrim( Transform(a131Cols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "							<vrUnit>" + AllTrim( Str(a131Cols[nX,16]) ) + "</vrUnit>"
										EndIf
									EndIf
									If !lMiddleware
										cXml += "								<vrRubr>" + AllTrim( Transform(a131Cols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(a131Cols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersEnvio >= "9.0" .And. cValToChar(year(M->RG_DATADEM)) >= "2021"
										cXml += "								<indApurIR>0</indApurIR>"
									EndIf
									cXml += "							</detVerbas>"

									If lMiddleware .And. ( (a131Cols[nX, 21] == "9901" .And. a131Cols[nX, 25] == "3") .Or. (a131Cols[nX, 21] == "9201" .And. a131Cols[nX, 22] $ "31/32") .Or. (a131Cols[nX, 21] == "1409" .And. a131Cols[nX, 22] == "51") .Or. (a131Cols[nX, 21] == "4050" .And. a131Cols[nX, 22] == "21") .Or. (a131Cols[nX, 21] == "4051" .And. a131Cols[nX, 22] == "22") .Or. (a131Cols[nX, 21] == "9902" .And. a131Cols[nX, 25] == "3") .Or. (a131Cols[nX, 21] == "9904" .And. a131Cols[nX, 25] == "3") .Or. (a131Cols[nX, 21] == "9908" .And. a131Cols[nX, 25] == "3") )
										fGrvRJO(SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, a131CC[nZ, 2], a131CC[nZ, 3], a131CC[nZ, 4], a131Cols[nX, 21], a131Cols[nX, 25], a131Cols[nX, 22], a131Cols[nX, 23], a131Cols[nX, 24], a131Cols[nX, 17], "S-2399", , , ,a131Cols[nX, 26], a131Cols[nX, 27] )
									EndIf
								EndIf
							Next

							If M->RA_CATEFD $ "738/731/734/201/202/"
								cXml += "							<infoAgNocivo>"
								cXml += "								<grauExp>" + Alltrim(M->RA_OCORREN) + "</grauExp>"
								cXml += "							</infoAgNocivo>"
							EndIf
							If !lMiddleware .Or. !Empty(cIndSimp)
								cXml += "							<infoSimples>"
								cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
								cXml += "							</infoSimples>"
							EndIf
							cXml += "						</ideEstabLot>"
						Next
						cXml += '				</dmDev>'
					EndIf

					If M->RG_SEMANA > "01"
						//Validação para verificar se gera o dmDev do FOL
						fFOL2299( @aFolCC, @aFolCols, cFilEnv, @aIdDmDev, cVersEnvio, lRetif, M->RG_SEMANA )
						For nContDev := 1 To Len(aIdDmDev)
							//Looping para varrer as verbas
							If Len(aFolCols[nContDev]) > 0
								cXml += "				<dmDev>"
								cXml += "					<ideDmDev>" + aIdDmDev[nContDev] +  "</ideDmDev>"

								//Looping para detalhar os Centros de Custos que o Trab Atuou
								For nZ := 1 To Len( aFolCC[nContDev] )
									cXml += "						<ideEstabLot>"
									cXml += "							<tpInsc>" + aFolCC[nContDev,nZ,2] + "</tpInsc>"
									cXml += "							<nrInsc>" + aFolCC[nContDev,nZ,3] + "</nrInsc>"
									cXml += "							<codLotacao>" + StrTran( aFolCC[nContDev,nZ,4], "&", "&amp;") + "</codLotacao>"
									//Looping nas verbas vindas
									For nX := 1 To Len( aFolCols[nContDev] )
										//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
										If( aFolCols[nContDev,nX, 12] == aFolCC[nContDev,nZ,1] .AND. aFolCols[nContDev,nX,17] > 0 )
											cXml += "							<detVerbas>"
											cXml += "								<codRubr>" + aFolCols[nContDev,nX,3] + "</codRubr>"
											cXml += "								<ideTabRubr>" + aFolCols[nContDev,nX,4] + "</ideTabRubr>"
											If !lMiddleware .Or. !Empty(aFolCols[nContDev,nX,15])
												cXml += "							<qtdRubr>" + Str(aFolCols[nContDev,nX,15]) + "</qtdRubr>"
											EndIf
											If !lMiddleware .Or. !Empty(aFolCols[nContDev,nX,5])
												cXml += "							<fatorRubr>" + AllTrim( Transform(aFolCols[nContDev,nX,5],"@E 999999999.99") ) + "</fatorRubr>"
											EndIf
											If cVersEnvio < "9.0" .And. (!lMiddleware .Or. !Empty(aFolCols[nContDev,nX,6]))
												If !lMiddleware
													cXml += "							<vrUnit>" + AllTrim( Transform(aFolCols[nContDev,nX,16],"@E 999999999.99") ) + "</vrUnit>"
												Else
													cXml += "							<vrUnit>" + AllTrim( Str(aFolCols[nContDev,nX,16]) ) + "</vrUnit>"
												EndIf
											EndIf
											If !lMiddleware
												cXml += "								<vrRubr>" + AllTrim( Transform(aFolCols[nContDev,nX,17],"@E 999999999.99") ) + "</vrRubr>"
											Else
												cXml += "								<vrRubr>" + AllTrim( Str(aFolCols[nContDev,nX,17]) ) + "</vrRubr>"
											EndIf
											If cVersEnvio >= "9.0" .And. cValToChar(year(M->RG_DATADEM)) >= "2021"
												cXml += "								<indApurIR>0</indApurIR>"
											EndIf
											cXml += "							</detVerbas>"

											If lMiddleware .And. ( (aFolCols[nContDev, nX, 21] == "9901" .And. aFolCols[nContDev, nX, 25] == "3") .Or. (aFolCols[nContDev, nX, 21] == "9201" .And. aFolCols[nContDev, nX, 22] $ "31/32") .Or. (aFolCols[nContDev, nX, 21] == "1409" .And. aFolCols[nContDev, nX, 22] == "51") .Or. (aFolCols[nContDev, nX, 21] == "4050" .And. aFolCols[nContDev, nX, 22] == "21") .Or. (aFolCols[nContDev, nX, 21] == "4051" .And. aFolCols[nContDev, nX, 22] == "22") .Or. (aFolCols[nContDev, nX, 21] == "9902" .And. aFolCols[nContDev, nX, 25] == "3") .Or. (aFolCols[nContDev, nX, 21] == "9904" .And. aFolCols[nContDev, nX, 25] == "3") .Or. (aFolCols[nContDev, nX, 21] == "9908" .And. aFolCols[nContDev, nX, 25] == "3") )
												fGrvRJO(SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aFolCC[nContDev, nZ, 2], aFolCC[nContDev, nZ, 3], aFolCC[nContDev, nZ, 4], aFolCols[nContDev, nX, 21], aFolCols[nContDev, nX, 25], aFolCols[nContDev, nX, 22], aFolCols[nContDev, nX, 23], aFolCols[nContDev, nX, 24], aFolCols[nContDev, nX, 17], "S-2399", , , ,aFolCols[nX, 26], aFolCols[nX, 27] )
											EndIf
										EndIf
									Next
									If M->RA_CATEFD $ "738/731/734/201/202/"
										cXml += "							<infoAgNocivo>"
										cXml += "								<grauExp>" + Alltrim(M->RA_OCORREN) + "</grauExp>"
										cXml += "							</infoAgNocivo>"
									EndIf
									If !Empty(cIndSimp)
										cXml += "							<infoSimples>"
										cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
										cXml += "							</infoSimples>"
									Endif
									cXml += "						</ideEstabLot>"
								Next

								cXml += "				</dmDev>"
							EndIf
						Next nContDev
					EndIf

					//Informações Multiplos Vinculos
					If ( Len( aDadosRAZ ) > 0 )
						cXml += "				<infoMV>"
						cXml += "					<indMV>" + aDadosRAZ[1,5] + "</indMV>"

						For nX := 1 To Len( aDadosRAZ )
							cXml += "					<remunOutrEmpr>"
							cXml += "						<tpInsc>" + aDadosRAZ[nX,9] + "</tpInsc>"
							cXml += "						<nrInsc>" + aDadosRAZ[nX,10] + "</nrInsc>"
							cXml += "						<codCateg>" + aDadosRAZ[nX,12] + "</codCateg>"
							cXml += "						<vlrRemunOE>" + AllTrim( Transform(aDadosRAZ[nX,11],"@E 999999999.99") ) + "</vlrRemunOE>"
							cXml += "					</remunOutrEmpr>"
						Next
						cXml += "				</infoMV>"
					EndIf
					cXml += '			</verbasResc>'
				EndIf

				cXml += '		</infoTSVTermino>'
				cXml += '	</evtTSVTermino>'
				cXml += '</eSocial>'
				//-------------------
				//| Final do XML
				//-------------------
			EndIf
		Else
			If !lMiddleware
				fGp23Cons(@aFilInTaf, {SRA->RA_FILIAL}, @cFilEnv)
			EndIf

			If Empty(cFilEnv)
				cFilEnv:= cFilAnt
			EndIf
			If !lMiddleware
				InExc3000(@cXml,'S-2399',SRA->RA_CIC + SRA->RA_CATEFD,SRA->RA_CIC,SRA->RA_PIS,,)
			Else
				cStatNew := ""
				cOperNew := ""
				cRetfNew := ""
				cRecibAnt:= ""
				cKeyMid	 := ""
				nRecEvt	 := 0
				lNovoRJE := .T.
				aDados	 := {}
				aInfos   := fXMLInfos()
				If Len(aInfos) >= 4
					cTpInsc  := aInfos[1]
					lAdmPubl := aInfos[4]
					cNrInsc  := aInfos[2]
					cId  	 := aInfos[3]
				Else
					cTpInsc  := ""
					lAdmPubl := .F.
					cNrInsc  := "0"
				EndIf

				cChave := Iif( cVersEnvio >= "9.0" .And. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA ) )
				cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2399" + Padr(cChave, fTamRJEKey()," ")

				cStat2399 	:= "-1"
				GetInfRJE( 2, cChaveBus, @cStat2399, @cOper2399, @cRetf2399, @nRec2399, @cRecib2399, @cRecibAnt, Nil, Nil, .T. )
				If cStat2399 == "2"
					aAdd(aErrosExc, STR0134)//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
				ElseIf cStat2399 == "99"
					aAdd(aErrosExc, STR0146)//"Operação não será realizada pois há evento de exclusão pendente para transmissão"
				Else
					InExc3000(@cXml,'S-2399',cRecib2399,SRA->RA_CIC,SRA->RA_PIS, Nil, Nil, Nil, Nil, cFilAnt, lAdmPubl, cTpInsc, cNrInsc, cId, @cStatNew, @cOperNew, @cRetfNew, @nRecEvt, @lNovoRJE, @cKeyMid, @aErros)
					fExcRJO(SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, "S-2399")
				EndIf
			EndIf
		EndIf

		aErros := {} //Limpa o campo de erro que foi utilizado acima na validação das verbas
		If lMiddleware .And. nOpc == 5
			aErros := aClone(aErrosExc)
		EndIf

		//Realiza geração de XML na System
		GrvTxtArq(alltrim(cXml), If(nOpc <> 5, "S2399", "S3000"), SRA->RA_CIC)

		If nOpc <> 5
			If !lMiddleware
				If ValType(cTafKey) == "C"
					aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, cTafKey , "3", "S2399", , "", , , , "GPE", , "" )
				Else
					aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S2399")
				EndIf
			Else
				//Validação de predecessores
				If cEFDAviso != "2" .And. !( FunName() $ cFncSemVer ) .And. lXmlVerbas
					//S-1005
					fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1005", @lS1005, aDadosCCT, lAdmPubl, cTpInsc, cNrInsc)
					fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1005", @lS1005, aAdiCC, lAdmPubl, cTpInsc, cNrInsc)
					fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1005", @lS1005, a131CC, lAdmPubl, cTpInsc, cNrInsc)
					For nCont := 1 To Len(aFolCC)
						fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1005", @lS1005, aFolCC[nCont], lAdmPubl, cTpInsc, cNrInsc)
					Next nCont

					//S-1010
					fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1010", @lS1010, If(cTpRes == "1", aCols040, aCols), lAdmPubl, cTpInsc, cNrInsc)
					fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1010", @lS1010, aAdiCols, lAdmPubl, cTpInsc, cNrInsc)
					fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1010", @lS1010, a131Cols, lAdmPubl, cTpInsc, cNrInsc)
					For nCont := 1 To Len(aFolCols)
						fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1010", @lS1010, aFolCols[nCont], lAdmPubl, cTpInsc, cNrInsc)
					Next nCont

					//S-1020
					fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1020", @lS1020, aDadosCCT, lAdmPubl, cTpInsc, cNrInsc)
					fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1020", @lS1020, aAdiCC, lAdmPubl, cTpInsc, cNrInsc)
					fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1020", @lS1020, a131CC, lAdmPubl, cTpInsc, cNrInsc)
					For nCont := 1 To Len(aFolCC)
						fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1020", @lS1020, aFolCC[nCont], lAdmPubl, cTpInsc, cNrInsc)
					Next nCont
				EndIf
				If cEFDAviso $ "0/2" .Or. (lS1005 .And. lS1010 .And. lS1020)
					For nI := 1 To Len(aErros)
						cMsgHlp += aErros[nI] + CRLF
					Next
					If !Empty(cMsgHlp) .And. cEFDAviso == "0"
						If cTpRes == "1"
							Help( ,, OemToAnsi(STR0001) ,, cMsgHlp, 1, 0 )
						Else
							aAdd( aErros, OemToAnsi(cMsgHlp) )
						EndIf
					EndIf
					If !( nOpc == 5 .And. ((cOper2399 == "E" .And. cStat2399 == "4") .Or. cStat2399 $ "-1/1/3") )
						If !(lRetorno := fGravaRJE( aDados, cXML, lNovoRJE, nRec2399 ))
							aAdd( aErros, OemToAnsi(STR0136) )//"Ocorreu um erro na gravação do registro na tabela RJE"
							DisarmTransaction()
						EndIf
					//Se for uma exclusão e não for de registro de exclusão transmitido, exclui registro de exclusão na fila
					ElseIf nOpc == 5 .And. cStat2399 != "-1" .And. !(cOper2399 == "E" .And. cStat2399 == "4")
						If !( lRet := fExcluiRJE( nRecRJE ) )
							aAdd( aErros, OemToAnsi(STR0138) )//"Ocorreu um erro na exclusão do registro na tabela RJE"
							DisarmTransaction()
						EndIf
					EndIf
				ElseIf cEFDAviso == "1"
					If Len(aErros) > 0
						For nI := 1 To Len(aErros)
							cMsgHlp += aErros[nI] + CRLF
						Next
						aErros[1] := cMsgHlp
						aSize(aErros, 1)
						DisarmTransaction()
					EndIf
				EndIf
			EndIf
		Else
			If !lMiddleware
				aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S3000")
			ElseIf Len(aErros) == 0
				If cStat2399 != "4"
					If !( lRet := fExcluiRJE( nRec2399 ) )
						aAdd( aErros, STR0138 )//"Ocorreu um erro na exclusão do registro na tabela RJE"
						DisarmTransaction()
					EndIf
				Else
					aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S3000", Space(6), cRecib2399, cId, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, NIL, NIL } )
					If !( lRet := fGravaRJE( aDados, cXML, lNovoRJE, nRecEvt ))
						aAdd( aErros, STR0138 )//"Ocorreu um erro na gravação do registro na tabela RJE"
						DisarmTransaction()
					EndIf
				EndIf
			EndIf
		EndIf
	End Transaction

	If Len(aErros) > 0
		FeSoc2Err( aErros[1], @cErroXERP ,IIF(aErros[1]!='000026',1,2))
		lGravou := IIF(aErros[1]!='000026',.F.,.T.)

		if aErros[1] == '000026'
			aErros := {}
			fEFDMsgErro(cErroXERP)
		Else
			aErros[1]:= cErroXERP
			If Len(aErros) > 1
				aErros[1] := aErros[2]
			EndIf
		EndIf

		//Só exibe a mensagem se for Rescisão Simples
		If( cTpRes == "1" .And. Len(aErros) > 0)
			If !lMiddleware
				Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0036) + aErros[1], 1, 0 )// "Atencao"##"Funcionario: "##"Não integrado com o TAF"
			Else
				Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0137) + aErros[1], 1, 0 )// "Atencao"##"Funcionario: "##"Não integrado com o Middleware"
			EndIf
		EndIf
	ElseIf nOpc <> 5 .And. !lCPFDepOk
		cMsgErro := STR0106//"O(s) dependente(s)/agregado(s) de plano de saúde abaixo não tem CPF cadastrado:"
		For nX := 1 To Len(aDepAgreg)
			cMsgErro += CRLF + aDepAgreg[nX]
		Next nX
		If cTpRes == "1"
			Aviso( OemtoAnsi(STR0001) , cMsgErro,	{ STR0038 } )
		Else
			If !lMiddleware
				aAdd(aErros, OemToAnsi(STR0074) + CRLF + cMsgErro) // "Enviada ao TAF com sucesso."
			Else
				aAdd(aErros, OemToAnsi(STR0162) + CRLF + cMsgErro) // "Enviada ao Middleware com sucesso."
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

	// Reinicializa a variável Estática nContRes
	nContRes := 0

Return lGravou

/*/{Protheus.doc} fTrf2399New
Funcao responsavel por realizar a integracao com o TAF na transferencia entre Grupo/Empresas diferentes
@author Guilherme Bertelli
@since 23/10/2018
@version 12.1.17
/*/
Function fTrf2399New( cCodDslg, cFilEnv, cCgcPara, dDataTRF, cVersEnvio, cMsgRet )

	Local aArea 		:= GetArea()
	Local lGravou		:= .T.
	Local cMsgErro    	:= ""
	Local cTafKey    	:= ""
	Local aErros		:= {}

	Local cBkpFil	 	:= cFilAnt
	Local cEFDAviso		:= Alltrim(FSubst(If(cPaisLoc == 'BRA' .And. Findfunction("fEFDAviso"), fEFDAviso(), SuperGetMv("MV_EFDAVIS",, "0")))) //Integracao com TAF)
	Local cVersMw	 	:= ""
	Local cXml		 	:= ""
	Local cMsg		 	:= ""
	Local cMsgErro	 	:= ""
	Local cVersMid	 	:= ""
	Local cChave	 	:= ""
	Local cStatus	 	:= "-1"
	Local cMsgHlp	 	:= ""
	Local cMsgRJE	 	:= ""
	Local cIni 		 	:= Space(6)
	Local lAdmPubl	 	:= .F.
	Local aInfos	 	:= {}
	Local aDados	 	:= {}
	Local cFilEmp	 	:= ""
	Local dDtGer	 	:= Date()
	Local cHrGer	 	:= Time()
	Local lRet		 	:= .T.
	Local cRetfNew	 	:= ""
	Local cOperNew 	 	:= ""
	Local cStatRJE	 	:= "-1"
	Local cOper2399	 	:= "I"
	Local cRecib2399 	:= ""
	Local cRecibAnt  	:= ""
	Local cRecibXML  	:= ""
	Local cRetf2399	 	:= "1"
	Local cStat2399	 	:= "-1"
	Local nRec2399   	:= 0
	Local cRetfNew	 	:= ""
	Local cStatNew	 	:= ""
	Local lNovoRJE	 	:= .F.
	Local nCont			:= 0
	Local lGeraMat		:= SRA->(ColumnPos("RA_DESCEP")) > 0 .And. SRA->RA_DESCEP == "1"

	Default cVersEnvio 	:= '2.2'

	//----------------
	//| Evento S-2399
	//| Inicio da geracao do evento de desligamento
	//----------------------------------------------
	If lMiddleware
		fVersEsoc( "S2399", .T., /*aRetGPE*/, /*aRetTAF*/, , , @cVersMw )
		fPosFil( cEmpAnt, SRA->RA_FILIAL )
		lS1000 := fVld1000( AnoMes(dDataTRF), @cStatus )
		If !lS1000 .And. cEFDAviso != "2"
			Do Case
				Case cStatus == "-1" // nao encontrado na base de dados
					cMsgRet := OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130)//"Registro do evento X-XXXX não localizado na base de dados"
					Return .F.
				Case cStatus == "1" // nao enviado para o governo
					cMsgRet := OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131)//"Registro do evento X-XXXX não transmitido para o governo"
					Return .F.
				Case cStatus == "2" // enviado e aguardando retorno do governo
					cMsgRet := OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132)//"Registro do evento X-XXXX aguardando retorno do governo"
					Return .F.
				Case cStatus == "3" // enviado e retornado com erro
					cMsgRet := OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133)//"Registro do evento X-XXXX retornado com erro do governo"3
					Return .F.
			EndCase
		EndIf
	EndIf
	//-------------------
	//| Inicio do XML
	//-------------------
	If lMiddleware
		aInfos   := fXMLInfos()
		IF Len(aInfos) >= 4
			cTpInsc  := aInfos[1]
			lAdmPubl := aInfos[4]
			cNrInsc  := aInfos[2]
			cId  	 := aInfos[3]
		Else
			cTpInsc  := ""
			lAdmPubl := .F.
			cNrInsc  := "0"
		EndIf

		cChave := Iif( cVersEnvio >= "9.0" .And. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA ) )
		cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2399" + Padr(cChave, fTamRJEKey()," ")

		cStat2399 	:= "-1"
		GetInfRJE( 2, cChaveBus, @cStat2399, @cOper2399, @cRetf2399, @nRec2399, @cRecib2399, @cRecibAnt )

		//Retorno pendente impede o cadastro
		If cStat2399 == "2" .And. cEFDAviso != "2"
			cMsgRJE 	:= STR0134//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
		EndIf
		//Evento de exclusão sem transmissão impede o cadastro
		If cOper2399 == "E" .And. cStat2399 != "4" .And. cEFDAviso != "2"
			cMsgRJE 	:= STR0135//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
		//Não existe na fila, será tratado como inclusão
		ElseIf cStat2399 == "-1"
			cOperNew 	:= "I"
			cRetfNew	:= "1"
			cStatNew	:= "1"
			lNovoRJE	:= .T.
		//Evento sem transmissão, irá sobrescrever o registro na fila
		ElseIf cStat2399 $ "1/3"
			cOperNew 	:= cOper2399
			cRetfNew	:= cRetf2399
			cStatNew	:= "1"
			lNovoRJE	:= .F.
		//Evento diferente de exclusão transmitido, irá gerar uma retificação
		ElseIf cOper2399 != "E" .And. cStat2399 == "4"
			cOperNew 	:= "A"
			cRetfNew	:= "2"
			cStatNew	:= "1"
			lNovoRJE	:= .T.
		//Evento de exclusão transmitido, será tratado como inclusão
		ElseIf cOper2399 == "E" .And. cStat2399 == "4"
			cOperNew 	:= "I"
			cRetfNew	:= "1"
			cStatNew	:= "1"
			lNovoRJE	:= .T.
		EndIf
		If !Empty(cMsgRJE)
			cMsgRet := cMsgRJE
			Return .F.
		EndIf
		If cRetfNew == "2"
			If cStat2399 == "4"
				cRecibXML 	:= cRecib2399
				cRecibAnt	:= cRecib2399
				cRecib2399	:= ""
			Else
				cRecibXML 	:= cRecibAnt
			EndIf
		EndIf
		aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2399", Space(6), cChave, cId, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew, cRecib2399, cRecibAnt } )
		cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtTSVTermino/v" + cVersMw + "'>"
		cXML += 	"<evtTSVTermino Id='" + cId + "'>"
		fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, 1, 1, "12" }, cVersEnvio, aInfos)
		fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
	Else
		//-------------------
		//| Inicio do XML
		//-------------------
		cXml :=	'<eSocial>'
		cXml += 	'<evtTSVTermino>'
	EndIf

	//Dados do trabalhador
	cXml += '		<ideTrabSemVinculo>'
	cXml += '			<cpfTrab>' + Alltrim( SRA->RA_CIC ) + '</cpfTrab>'
	If cVersEnvio < "9.0"
		cXml += '			<nisTrab>' + ALLTRIM( SRA->RA_PIS )	+ '</nisTrab>'
	ElseIf lGeraMat
		cXml += '			<matricula>' + ALLTRIM( M->RA_CODUNIC )	+ '</matricula>'
	EndIf
	If cVersEnvio < "9.0" .Or. !lGeraMat
		cXml += '			<codCateg>' + AllTrim( SRA->RA_CATEFD ) + '</codCateg>'
	EndIf
	cXml += '		</ideTrabSemVinculo>'

	cXml += '		<infoTSVTermino>'
	If !lMiddleware
		cXml += '			<dtTerm>' + AllTrim( DtoS(dDataTRF) ) + '</dtTerm>'
	Else
		cXml += '			<dtTerm>' + SubStr( dToS(dDataTRF), 1, 4 ) + "-" + SubStr( dToS(dDataTRF), 5, 2 ) + "-" + SubStr( dToS(dDataTRF), 7, 2 ) + '</dtTerm>'
	EndIf
	//Motivo de desligamento de Diretor não empregado (CatEfd = 721)
	If( SRA->RA_CATEFD $ '721' )
		cXml += '			<mtvDesligTSV>' + '</mtvDesligTSV>'
	EndIf

	cXml += '		</infoTSVTermino>'

	//Fechamentos de Tags
	cXml +=		'</evtTSVTermino>'
	cXml +=	'</eSocial>'
	//-------------------
	//| Final do XML
	//-------------------
	GrvTxtArq(alltrim(cXml), "S2399", SRA->RA_CIC)

	If !lMiddleware
		cTafKey := "S2399" + AnoMes(dDataTRF) + SRA->RA_CIC + SRA->RA_CODUNIC
		aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, cTafKey , "3", "S2399", , "", , , , "GPE", , "" )
	Else
		If !(lRetorno := fGravaRJE( aDados, cXML, lNovoRJE, nRec2399 ))
			aAdd( aErros, OemToAnsi(STR0136) )//"Ocorreu um erro na gravação do registro na tabela RJE"
		EndIf
	EndIf

	If Len(aErros) > 0
		lGravou := .F.
		cMsgRet := aErros[1]
	Endif

	RestArea(aArea)

Return lGravou

/*/{Protheus.doc} function
description
@author Cícero Alves
@since 16/10/2018
@version 12.1.17
@param cXml, Caracter, String com as informações que serão enviadas para o TAF - Deve ser passada por referência
@param oModel, Object, Modelo de dados com as informações da rescsão (GPEM040)
@param aDadosCCT, Array, Informações dos estabelecimentos / Lotações
@param cVBDiss, Caracter, Verbas que foram pagas no dissídio
@Param cIndSimp, Caracter, Indicador do Tipo de Simples Nacional.
@param lRetif, Logico, Indica se é retificação
@param aColsRes, Array, Informações das verbas geradas nas rescisão atual
@param cVersEnvio, Caracter, Versão do leiaute de envio
@param aRelacRJ5, Array, Informações do relacionamento da RJ5
@param aErrosRJ5, Array, Erros do relacionamento da RJ5
/*/
Static Function fResCom(cXml, oModel, aDadosCCT, cVBDiss, cIndSimp, lRetif, aColsRes, cVersEnvio, aRelacRJ5, aErrosRJ5)

	Local aPdResCom	:= {}
	Local cAliasSRR := GetNextAlias()
	Local dLastDate	:= ""
	Local cIdTbRub	:= If( ! Empty(xFilial("SRV", SRA->(RA_FILIAL))), xFilial("SRV", SRA->(RA_FILIAL)), cEmpAnt)
	Local nContCols	:= 0
	Local nContPd	:= 0
	Local nPosCC	:= 0
	Local nPosPD	:= 0
	Local nPercRub	:= 0
	Local oModelSRG	:= oModel:GetModel("GPEM040_MSRG")
	Local aCodCCT	:= {}
	Local aCols040	:= {}
	Local cCodLot	:= ""
	Local cCCAnt	:= ""
	Local cChaveRJ5	:= ""
	Local cTpInscr	:= ""
	Local cInscr	:= ""
	Local cCEIObra	:= ""
	Local cCAEPF	:= ""
	Local cChaveCC	:= ""
	Local cCodRubr	:= ""
	Local cIdeRubr	:= ""
	Local cPrcRubr	:= ""
	Local cTpLot	:= ""
	Local lGeraCod	:= .F.
	Local lSemFilCTT:= Empty(xFilial("CTT"))
	Local lSemFilRJ5:= .F.
	Local nPosCCT	:= 0
	Local nPosRJ5	:= 0
	Local lRJ5FilT  := RJ5->(ColumnPos("RJ5_FILT")) > 0
	Local lTemReg	:= .F.
	Local cBolsistas    := fCatTrabEFD("BOL") //'901|902|903|904|905|'
	Local cContrib      := '701|711|712|721|722|723|731|734|738|741|751|761|771|781'
	Local cCodNat		:= ""
	Local cCodINCCP		:= ""
	Local cCodINFGTS	:= ""
	Local cContrib1     := '701|711|712|721|722|723|731|734|738|741|751|761|781'
	Local cCodINCIRF	:= ""

	Default lRetif  	:= .F.
	Default aRelacRJ5  	:= {}

	BeginSQL Alias cAliasSRR
		SELECT SRR.RR_FILIAL, SRR.RR_MAT, SRR.RR_CC, SRR.RR_PD, SUM(SRR.RR_HORAS) RR_HORAS, SUM(SRR.RR_VALOR) RR_VALOR, MAX(SRR.RR_DATA) RR_DATA, SRR.RR_PERIODO, SRR.RR_ROTEIR, MAX(SRR.R_E_C_N_O_) RECNO
		FROM %Table:SRR% SRR
		WHERE SRR.RR_FILIAL = %Exp: oModelSRG:GetValue("RG_FILIAL")% AND
		SRR.RR_MAT = %Exp: oModelSRG:GetValue("RG_MAT")% AND
		SRR.RR_TIPO3 = 'R' AND
		SRR.RR_DATA < %Exp:dToS(oModelSRG:GetValue("RG_DTGERAR"))% AND
		SRR.%NotDel%
		GROUP BY RR_FILIAL, RR_MAT, RR_DATA, RR_CC, RR_PD, RR_PERIODO, RR_ROTEIR
		ORDER BY 1, 2, 3, 7, 4
	EndSQL

	While ! (cAliasSRR)->(Eof())

		lTemReg		:= .F.

		If dLastDate != (cAliasSRR)->RR_DATA
			If !Empty(aCols040)
				fGerXml(@cXml, cIdDmDev, cIndSimp, aCodCCT, aCols040)
			EndIf
			aCodCCT		:= {}
			aCols040	:= {}
			cCCAnt		:= {}
			dLastDate 	:= (cAliasSRR)->RR_DATA
			cIdDmDev 	:= "R" + cEmpAnt + AllTrim(oModelSRG:GetValue("RG_FILIAL")) + (cAliasSRR)->RR_MAT + If(Empty(nContRes), (++nContRes, ""), cValToChar(nContRes++))
		EndIf

		cChaveCC := (cAliasSRR)->RR_CC
		cTpLot	 := ""
		If !lVerRJ5
			aAreaCTT := GetArea()
			DBSelectArea("CTT")
			CTT->(DbSetOrder(1))
			If( CTT->( dbSeek( xFilial("CTT") + (cAliasSRR)->RR_CC ) ) )
				cCodLot := IIf(lSemFilCTT, CTT->CTT_CUSTO, CTT->CTT_FILIAL+CTT->CTT_CUSTO )
				cTpLot  := CTT->CTT_TPLOT	// Tipo de Lotação (?!?)

				If CTT->CTT_TPLOT == "01" .And. CTT->CTT_TIPO2 == "4" .And. CTT->CTT_CLASSE == "2"
					cTpInscr := CTT->CTT_TIPO2 // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
					cInscr := CTT->CTT_CEI2 // Codigo da inscricao
				EndIf
			EndIf
			RestArea(aAreaCTT)
			nPosCCPD	:= Ascan( @aCols040,{|X| X[1] == cCodLot + (cAliasSRR)->RR_PD })
			nPosCC		:= Ascan( @aCols040,{|X| X[19] == cCodLot })
		Else
			If (nPosRJ5 := aScan( aRelacRJ5, { |x| x[1] == cChaveCC } )) == 0 .Or. (nPosCCT := aScan( aDadosCCT, { |y| y[4] == aRelacRJ5[nPosRJ5, 2]} )) == 0
				cCodLot		:= ""
				lSemFilRJ5 	:= Empty(xFilial("RJ5"))
				RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
				If RJ5->( !dbSeek( xFilial("RJ5", SRA->RA_FILIAL) + cChaveCC ) )
					If aScan(aErrosRJ5, { |x| x == cChaveCC }) == 0
						aAdd( aErrosRJ5, cChaveCC )
					EndIf
				Else
					If lRJ5FilT
						RJ5->(DbSetOrder(7)) //RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
						RJ5->(dbGoTop())
						RJ5->( dbSeek( xFilial("RJ5", SRA->RA_FILIAL) + cChaveCC + SRA->RA_FILIAL) )
						While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", M->RA_FILIAL) .And. RJ5->RJ5_CC == cChaveCC .And. SRA->RA_FILIAL == RJ5->RJ5_FILT
							If AnoMes( sToD((cAliasSRR)->RR_DATA) ) >= RJ5->RJ5_INI
								cTpInscr	:= RJ5->RJ5_TPIO
								cInscr  	:= RJ5->RJ5_NIO
								cCodLot		:= IIf(lSemFilRJ5, RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
								lTemReg		:= .T.
							EndIf
							RJ5->( dbSkip() )
						EndDo
						//Se não encontrou um registro com código preenchido reposiciona a tabela e executa o dbseek novamente.
						If !lTemReg
							RJ5->(DbSetOrder(4)) //RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
							RJ5->(dbGoTop())
							RJ5->( dbSeek( xFilial("RJ5", SRA->RA_FILIAL) + cChaveCC ) )
							While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", M->RA_FILIAL) .And. RJ5->RJ5_CC == cChaveCC .And. EMPTY(RJ5->RJ5_FILT)
								If AnoMes( sToD((cAliasSRR)->RR_DATA) ) >= RJ5->RJ5_INI
									cTpInscr	:= RJ5->RJ5_TPIO
									cInscr  	:= RJ5->RJ5_NIO
									cCodLot		:= IIf(lSemFilRJ5, RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
								EndIf
								RJ5->( dbSkip() )
							EndDo
						EndIf
					Else
						While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", M->RA_FILIAL) .And. RJ5->RJ5_CC == cChaveCC
							If AnoMes( sToD((cAliasSRR)->RR_DATA) ) >= RJ5->RJ5_INI
								cTpInscr	:= RJ5->RJ5_TPIO
								cInscr  	:= RJ5->RJ5_NIO
								cCodLot		:= IIf(lSemFilRJ5, RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
							EndIf
							RJ5->( dbSkip() )
						EndDo
					EndIf
					If Empty(cCodLot)
						If aScan(aErrosRJ5, { |x| x == cChaveCC }) == 0
							aAdd( aErrosRJ5, cChaveCC )
						EndIf
					Else
						aAdd(aRelacRJ5, { cChaveCC, cCodLot })
					EndIf
				EndIf
			Else
				cTpInscr:= aDadosCCT[nPosCCT, 2]
				cInscr	:= aDadosCCT[nPosCCT, 3]
				cCodLot	:= aDadosCCT[nPosCCT, 4]
			EndIf
			nPosCCPD	:= Ascan( @aCols040,{|X| X[20] == cCodLot + (cAliasSRR)->RR_PD })
			nPosCC		:= Ascan( @aCols040,{|X| X[19] == cCodLot })
		EndIf

		If Empty(cTpInscr) .OR. Empty(cInscr)
			If fBuscaOBRA( SRA->RA_FILIAL, @cCEIObra )
				cTpInscr := "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
				cInscr 	 := cCEIObra // Codigo da inscricao
			Elseif fBuscaCAEPF( SRA->RA_FILIAL, @cCAEPF )
				cTpInscr := "3"
				cInscr	 := cCAEPF
			Else
				nPosEstb 	:= aScan(aEstb, {|x| x[1] == AllTrim(SRA->RA_FILIAL)})
				If nPosEstb > 0
					cTpInscr	:= aEstb[nPosEstb,3]
					cInscr		:= aEstb[nPosEstb,2]
				EndIf
			EndIf
		EndIf

		//Contagem da quantidade de CCs citados na rescisao
		If(nPosCC == 0)
			aAdd(aCodCCT, {cChaveCC, cTpInscr, cInscr, cCodLot } )
		EndIf

		PosSrv( (cAliasSRR)->RR_PD, (cAliasSRR)->RR_FILIAL )
		If !Empty(xFilial("SRV"))
			lGeraCod := .T.
		Else
			lSemFilSRV := .T.
		EndIf

		//------------------
		//| Lógica lGeraCod
		//| .T. -> Exclusiva | .F. -> Compartilhada
		//------------------------------------------
		If lGeraCod
			cIdeRubr := Iif(!Empty(SRV->RV_FILIAL),SRV->RV_FILIAL , (xFilial("SRV"), SRA->RA_FILIAL) )
		Else
			If cVersEnvio >= "2.3"
				cIdeRubr := cEmpAnt
			Else
				cIdeRubr := ""
			EndIf
		Endif

		cCodNat 	:= RetValSrv( (cAliasSRR)->RR_PD, xFilial("SRA"), "RV_NATUREZ" )
		cCodINCCP 	:= RetValSrv( (cAliasSRR)->RR_PD, xFilial("SRA"), 'RV_INCCP' )
		cCodINCIRF  := RetValSrv( (cAliasSRR)->RR_PD, xFilial("SRA"), 'RV_INCIRF' )
		cCodINFGTS  := RetValSrv( (cAliasSRR)->RR_PD, xFilial("SRA"), 'RV_INCFGTS' )

		If (cAliasSRR)->RR_ROTEIR != "PLR" .And. cVersEnvio >= '2.3'
			If (SRA->RA_CATEFD $ cBolsistas + cContrib) .AND. ( cCodNat $ "1409|4050|4051|1009" )
				Loop
			EndIf
		EndIf

		If 	((SRA->RA_CATEFD $  cContrib1) .And. (cCodINCCP  $ '12|21|22|32|51|92|93|94' ) ) .Or.;
			 ((SRA->RA_CATEFD $  cContrib1) .And. (cCodINCIRF  $ '12|13|32|33|42|43|47|52|53|62|63|64|71|92|93')) .Or.;
			 (!(SRA->RA_CATEFD $ '711|712|734') .And. (cCodINCCP  $ '34|35')) .Or.;
			 ((SRA->RA_CATEFD $ '701|711|712|741|751|781') .And. (cCodINCIRF  $ '14|34|54|94'))
			Loop
		EndIf
	 	If (SRA->RA_CATEFD $ cBolsistas) .And. (!(cCodINCCP  $ '00|01') .Or. cCodINFGTS  <> '00')
		 	Loop
		Endif
		cCodRubr := SRV->RV_COD		//Codigo  da Rubrica
		If (SRV->RV_PERC - 100) < 0
			cPrcRubr :=	0	//Percent da Rubrica
		Else
			cPrcRubr := SRV->RV_PERC - 100//Percent da Rubrica
		EndIf

		If (cAliasSRR)->RR_ROTEIR != "PLR" .And. ;
			( ( cVersEnvio < "2.6.00" .And. !(Substr(SRV->RV_INCIRF, 1, 2) $ "31*32*33*34*35*51*52*53*54*55*81*82*83") ) .Or.;
			( cVersEnvio >= "2.6.00" .And. !(fRetTpIRF( SRV->RV_INCIRF ) $ "D|I|J") ) ) .And.;
			!(SRV->RV_CODFOL $ "0126|0303")
			If( nPosCCPD > 0 )
				aCols040[nPosCCPD, 15] += (cAliasSRR)->RR_HORAS			//Incrementa Horas
				aCols040[nPosCCPD, 17] += (cAliasSRR)->RR_VALOR 		//Incrementa Valor
				aCols040[nPosCCPD, 18] := aCols040[nPosCCPD, 18] + 1	//Incrementa Contador
			Else
				aAdd(aCols040, { 	(cAliasSRR)->RR_CC + (cAliasSRR)->RR_PD,;//01 - Chave para pesquisa (CC+PD)
									"Dados da Verba",;					//02 - Separador - Verbas/Rubricas
									cCodRubr,;							//03 - Codigo da Rubrica
									cIdeRubr,;							//04 - Ident   da Rubrica
									cPrcRubr,;							//05 - Percent da Rubrica
									"Dados do CC",;						//06 - Separador - Centro de Custo
									cCodLot,;							//07 - Codigo da Lotação
									cTpInscr,;							//08 - Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
									cInscr,;							//09 - Codigo da inscricao
									cTpLot,;							//10 - Tipo de Lotação (?!?)
									"Dados da Grid",;					//11 - Separador - Centro de Custo
									(cAliasSRR)->RR_CC,;				//12 - Centro de Custo
									(cAliasSRR)->RR_PD,;				//13 - Verba da rescisão
									SRV->RV_DESC,;						//14 - Descricao da verba
									(cAliasSRR)->RR_HORAS,;				//15 - Horas da verba
									(cAliasSRR)->RR_VALOR,;				//16 - Valor da verba
									(cAliasSRR)->RR_VALOR,;				//17 - Acumulado da verba (valor inicial para soma)
									1,; 								//18 - Numero de registro repetidos (CC + PD)
									cCodLot,;							//19 - Código de lotação
									cCodLot + (cAliasSRR)->RR_PD,;		//20 - Chave para pesquisa (Código Lotação+PD)
									SRV->RV_NATUREZ,;					//21 - Natureza da verba
									SRV->RV_INCCP,;						//22 - Incidência CP da verba
									SRV->RV_INCFGTS,;					//23 - Incidência FGTS da verba
									SRV->RV_INCIRF,;					//24 - Incidência IRRF da verba
									SRV->RV_TIPOCOD})					//25 - Tipo da verba

			EndIf

			If ( nPosPd := aScan( aPdResCom, { |x| x[1] + x[2] == cCodLot + (cAliasSRR)->RR_PD } ) ) == 0
				aAdd( aPdResCom, { cCodLot, (cAliasSRR)->RR_PD, (cAliasSRR)->RR_HORAS, (cAliasSRR)->RR_VALOR } )
			Else
				aPdResCom[nPosPD, 3] += (cAliasSRR)->RR_HORAS
				aPdResCom[nPosPD, 4] += (cAliasSRR)->RR_VALOR
			EndIf
		EndIf

		(cAliasSRR)->(dbSkip())

		If dLastDate != (cAliasSRR)->RR_DATA .Or. (cAliasSRR)->(Eof())
			fGerXml(@cXml, cIdDmDev, cIndSimp, aCodCCT, aCols040)
		EndIf

	EndDo

	(cAliasSRR)->(dbCloseArea())

	If !lRetif
		For nContPd := 1 To Len(aColsRes)
			For nContCols := 1 To Len(aPdResCom)
				If aColsRes[nContPd, 19] + aColsRes[nContPd, 3] == aPdResCom[nContCols, 1] + aPdResCom[nContCols, 2]
					aColsRes[nContPd, 15] -= aPdResCom[nContCols, 3]
					aColsRes[nContPd, 16] -= aPdResCom[nContCols, 4]
					aColsRes[nContPd, 17] -= aPdResCom[nContCols, 4]
				EndIf
			Next nContCols
		Next nContPd
	EndIf

Return

/*/{Protheus.doc} fGerXml
Função para montar o XML com as verbas da rescisão anterior
@author Allyson Mesashi
@since 16/10/2018
@version 12.1.17
@param cXml, Caracter, String com as informações que serão enviadas para o TAF - Deve ser passada por referência
@param cIdDmDev, Caracter, Código do recibo de pagamento
@param cIndSimp, Caracter, Indicador do simples
@param aCodCCT, Array, Informações dos estabelecimentos / Lotações
@param aCols040, Array, Informações das verbas geradas nas rescisão
/*/
Static Function fGerXml(cXml, cIdDmDev, cIndSimp, aCodCCT, aCols040)

Local nZ		:= 0
Local nX		:= 0
Local cVersEnvio := ""

fVersEsoc( "S2399",.T.,,, @cVersEnvio )

cXml += "<dmDev>"
cXml += "	<ideDmDev>" + cIdDmDev +  "</ideDmDev>"

//Looping para detalhar os Centros de Custos que o Trab Atuou
For nZ := 1 To Len( aCodCCT )
	cXml += "	<ideEstabLot>"
	cXml += "		<tpInsc>" + If(Empty(aCodCCT[nZ,2]),cTpInscr,aCodCCT[nZ,2]) + "</tpInsc>"
	cXml += "		<nrInsc>" + If(Empty(aCodCCT[nZ,3]),cInscr,aCodCCT[nZ,3]) + "</nrInsc>"
	cXml += "		<codLotacao>" + StrTran( aCodCCT[nZ,4], "&", "&amp;") + "</codLotacao>"

	//Looping nas verbas vindas
	For nX := 1 To Len( aCols040 )
		//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
		If ( ((!lVerRJ5 .And. aCols040[nX, 12] == aCodCCT[nZ,1]) .Or. (lVerRJ5 .And. aCols040[nX, 19] == aCodCCT[nZ,4])) .And. aCols040[nX, 17] > 0 )
			cXml += "		<detVerbas>"
			cXml += "			<codRubr>" + aCols040[nX,3] + "</codRubr>"
			cXml += "			<ideTabRubr>" + aCols040[nX,4] + "</ideTabRubr>"
			If !lMiddleware .Or. !Empty(aCols040[nX,15])
				cXml += "			<qtdRubr>" + Str(aCols040[nX,15]) + "</qtdRubr>"
			EndIf
			If !lMiddleware .Or. !Empty(aCols040[nX,5])
				cXml += "			<fatorRubr>" + AllTrim( Transform(aCols040[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
			EndIf
			If cVersEnvio < "9.0"  .And. (!lMiddleware .Or. !Empty(aCols040[nX,16]))
				If !lMiddleware
					cXml += "			<vrUnit>" + AllTrim( Transform(aCols040[nX,16],"@E 999999999.99") ) + "</vrUnit>"
				Else
					cXml += "			<vrUnit>" + AllTrim( Str(aCols040[nX,16]) ) + "</vrUnit>"
				EndIf
			EndIf
			If !lMiddleware
				cXml += "			<vrRubr>" + AllTrim( Transform(aCols040[nX,17],"@E 999999999.99") ) + "</vrRubr>"
			Else
				cXml += "			<vrRubr>" + AllTrim( Str(aCols040[nX,17]) ) + "</vrRubr>"
			EndIf
			If cVersEnvio >= "9.0" .And. cValToChar(year(M->RG_DATADEM)) >= "2021"
				cXml += "			<indApurIR>0</indApurIR>"
			EndIf
			cXml += "		</detVerbas>"

			If lMiddleware .And. ( (aCols040[nX, 21] == "9901" .And. aCols040[nX, 25] == "3") .Or. (aCols040[nX, 21] == "9201" .And. aCols040[nX, 22] $ "31/32") .Or. (aCols040[nX, 21] == "1409" .And. aCols040[nX, 22] == "51") .Or. (aCols040[nX, 21] == "4050" .And. aCols040[nX, 22] == "21") .Or. (aCols040[nX, 21] == "4051" .And. aCols040[nX, 22] == "22") .Or. (aCols040[nX, 21] == "9902" .And. aCols040[nX, 25] == "3") .Or. (aCols040[nX, 21] == "9904" .And. aCols040[nX, 25] == "3") .Or. (aCols040[nX, 21] == "9908" .And. aCols040[nX, 25] == "3") )
				fGrvRJO(SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aCodCCT[nZ, 2], aCodCCT[nZ, 3], aCodCCT[nZ, 4], aCols040[nX, 21], aCols040[nX, 25], aCols040[nX, 22], aCols040[nX, 23], aCols040[nX, 24], aCols040[nX, 17], "S-2399" , , , ,aCols040[nX, 26], aCols040[nX, 27] )
			EndIf
		EndIf
	Next
	If SRA->RA_CATEFD $ "738/731/734/201/202/"
		cXml += "		<infoAgNocivo>"
		cXml += "			<grauExp>" + Alltrim(SRA->RA_OCORREN) + "</grauExp>"
		cXml += "			</infoAgNocivo>"
	EndIf
	If !lMiddleware .Or. !Empty(cIndSimp)
		cXml += "		<infoSimples>"
		cXml += "			<indSimples>" + cIndSimp + "</indSimples>"
		cXml += "		</infoSimples>"
	EndIf
	cXml += "</ideEstabLot>"
Next
cXml += '</dmDev>'

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FSubst        ³ Autor ³ Cristina Ogura   ³ Data ³ 17/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que substitui os caracteres especiais por espacos   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FSubst()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEM610                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FSubst(cTexto)

Local aAcentos	:={}
Local aAcSubst	:={}
Local cImpCar	:= Space(01)
Local cImpLin	:=""
Local cAux		:=""
Local cAux1		:=""
Local nTamTxt	:= Len(cTexto)
Local j
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
			Chr(213),Chr(245),Chr(227),Chr(252);
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
			"O","o","a","u";
			}

For j:=1 TO Len(AllTrim(cTexto))
	cImpCar	:=SubStr(cTexto,j,1)
	//-- Nao pode sair com 2 espacos em branco.
	cAux	:=Space(01)
    nPos 	:= 0
	nPos 	:= Ascan(aAcentos,cImpCar)
	If nPos > 0
		cAux := aAcSubst[nPos]
	Elseif (cAux1 == Space(1) .And. cAux == space(1)) .Or. Len(cAux1) == 0
		cAux :=	""
	EndIf
    cAux1 	:= 	cAux
	cImpCar	:=	cAux
	cImpLin	:=	cImpLin+cImpCar

Next j

//--Volta o texto no tamanho original
cImpLin := Left(cImpLin+Space(nTamTxt),nTamTxt)

Return cImpLin

/*/{Protheus.doc} fPLR2399
Crias as Tags no XML do Evento S-2399 com as verbas pagas no Roteiro de PLR
@author lidio.oliveira
@since 12/03/2020
@version 12.1.17
@Param cXml, Caracter, String com o XML que será enviado para o TAF - Deve ser passada por referência
@param oModel, Object, Objeto com as informações da rescisão
@Param aDadosCTT, Array, Informações dos estabelecimentos / lotações
@Param cIndSimp, Caracter, Indicador do Tipo de Simples Nacional.
/*/
Static Function fPLR2399( cXml, oModel, aDadosCCT, cIndSimp, dDataRes)

	Local cAliasPLR	:= GetNextAlias()
	Local dLastDate	:= ""
	Local cIdTbRub	:= If(! Empty(xFilial("SRV", SRA->(RA_FILIAL))), xFilial("SRV", SRA->(RA_FILIAL)), cEmpAnt)
	Local cVersEnvio:= ""
	Local nPosCC	:= 0
	Local nPercRub	:= 0
	Local aArea		:= GetArea()
	Local lRVIncop		:= SRV->(ColumnPos("RV_INCOP"))> 0
	Local lRVTetop 		:= SRV->(ColumnPos("RV_TETOP"))> 0

	fVersEsoc( "S2399",.T.,,, @cVersEnvio )
	If cVersEnvio < "9.0"
		lRVIncop	:= .F.
		lRVTetop	:= .F.
	Endif

	dDataRes		:= If(! Empty(oModel), oModel:GetModel("GPEM040_MSRG"):GetValue("RG_DATADEM"), dDataRes)
	cProcess		:= If(! Empty(oModel), oModel:GetModel("GPEM040_MSRG"):GetValue("RG_PROCES"), SRA->RA_PROCES)

	BeginSQL Alias cAliasPLR
		SELECT 	 SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_DATARQ, SRD.RD_CC, SRD.RD_PD, SRD.RD_PERIODO, SRD.RD_ROTEIR, SUM(SRD.RD_HORAS) RD_HORAS, SUM(SRD.RD_VALOR) RD_VALOR, MAX(SRD.RD_DATPGT) RD_DATPGT, MAX(SRD.R_E_C_N_O_) RECNO, 'SRD' AS TAB
		FROM	 %table:SRD% SRD
		WHERE 	 SRD.RD_FILIAL =	%exp:SRA->RA_FILIAL%
		AND 	 SRD.RD_MAT    =	%exp:SRA->RA_MAT%
		AND 	 SRD.RD_DATARQ =	%exp:AnoMes(dDataRes)%
		AND 	 SRD.RD_ROTEIR =	'PLR'
		AND      SRD.%notDel%
		GROUP BY RD_FILIAL, RD_MAT, RD_DATARQ, RD_CC, RD_PD, RD_PERIODO, RD_ROTEIR
		UNION ALL
		SELECT 	 SRC.RC_FILIAL, SRC.RC_MAT, SRC.RC_PERIODO, SRC.RC_CC, SRC.RC_PD, SRC.RC_PERIODO, SRC.RC_ROTEIR, SUM(SRC.RC_HORAS) RD_HORAS, SUM(SRC.RC_VALOR) RD_VALOR, MAX(SRC.RC_DATA) RD_DATPGT, MAX(SRC.R_E_C_N_O_) RECNO, 'SRC' AS TAB
		FROM	 %table:SRC% SRC
		WHERE 	 SRC.RC_FILIAL 	=	%exp:SRA->RA_FILIAL%
		AND 	 SRC.RC_MAT		=	%exp:SRA->RA_MAT%
		AND 	 SRC.RC_PERIODO =	%exp:AnoMes(dDataRes)%
		AND 	 SRC.RC_ROTEIR 	=	'PLR'
		AND      SRC.%notDel%
		GROUP BY RC_FILIAL, RC_MAT, RC_PERIODO, RC_CC, RC_PD, RC_PERIODO, RC_ROTEIR
		ORDER BY 1, 2, 3, 4, 5
	EndSQL

	While ! (cAliasPLR)->(Eof())

		// Verifica se a data houve integração do período de PLR
		// Se foi integrado não gera o pagamento separado
		If ! Empty(Posicione("RCH", 1, (cAliasPLR)->(xFilial("RCH", RD_FILIAL) + cProcess + RD_PERIODO + "01" + "PLR"), "RCH_DTINTE" ))
			EXIT
		EndIf

		If dLastDate != (cAliasPLR)->RD_DATPGT

			dLastDate := (cAliasPLR)->RD_DATPGT
			cIdDmDev := SRA->RA_FILIAL + (cAliasPLR)->RD_DATPGT + (cAliasPLR)->RD_PERIODO + (cAliasPLR)->RD_ROTEIR
			nPosCC := Ascan( aDadosCCT, { |X| X[1] == (cAliasPLR)->RD_CC })

			cXml += "<dmDev>"
			cXml += "<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
			cXml += "<ideEstabLot>"
			cXml += "<tpInsc>" + aDadosCCT[nPosCC, 2] + "</tpInsc>"
			If !lMiddleware
				cXml += "<nrInsc>"+ aDadosCCT[nPosCC,3] + " </nrInsc>"
			Else
				cXml += "<nrInsc>"+ Alltrim(aDadosCCT[nPosCC,3]) + "</nrInsc>"
			Endif
			cXml += "<codLotacao>" + StrTran( aDadosCCT[nPosCC,4], "&", "&amp;") + "</codLotacao>"

		EndIf

		PosSrv( (cAliasPLR)->RD_PD, (cAliasPLR)->RD_FILIAL )
		nPercRub := If( (SRV->RV_PERC - 100) <= 0, 0, SRV->RV_PERC - 100 )
		//Não leva as verbas de IR
		If ( ( cVersEnvio < "2.6.00" .And. !(Substr(SRV->RV_INCIRF, 1, 2) $ "31*32*33*34*35*51*52*53*54*55*81*82*83") ) .Or.;
			( cVersEnvio >= "2.6.00" .And. !(fRetTpIRF( SRV->RV_INCIRF ) $ "D|I|J") ) ) .And. (cAliasPLR)->RD_VALOR > 0
			cXml += "<detVerbas>"
			cXml += 	"<codRubr>" + (cAliasPLR)->RD_PD + "</codRubr>"
			cXml += 	"<ideTabRubr>" + cIdTbRub + "</ideTabRubr>"
			If !lMiddleware .Or. !Empty((cAliasPLR)->RD_HORAS)
				cXml += "<qtdRubr>" + Str((cAliasPLR)->RD_HORAS) + "</qtdRubr>"
			EndIf
			If !lMiddleware .Or. !Empty(nPercRub)
				cXml += "<fatorRubr>" + Transform(nPercRub,"@E 999.99") + "</fatorRubr>"
			EndIf
			If cVersEnvio < "9.0" .And. (!lMiddleware .Or. !Empty((cAliasPLR)->RD_VALOR))
				If !lMiddleware
					cXml += "<vrUnit>" + AllTrim( Transform((cAliasPLR)->RD_VALOR, "@E 999999999.99") ) + "</vrUnit>"
				Else
					cXml += "<vrUnit>" + AllTrim( Str((cAliasPLR)->RD_VALOR) ) + "</vrUnit>"
				EndIf
			EndIf
			If !lMiddleware
				cXml += 	"<vrRubr>" + AllTrim( Transform((cAliasPLR)->RD_VALOR, "@E 999999999.99") ) + "</vrRubr>"
			Else
				cXml += 	"<vrRubr>" + AllTrim( Str((cAliasPLR)->RD_VALOR) ) + "</vrRubr>"
			EndIf
			If cVersEnvio >= "9.0" .And. cValToChar(year(M->RG_DATADEM)) >= "2021"
				cXml += "<indApurIR>0</indApurIR>"
			EndIf
			cXml += "</detVerbas>"
			If lMiddleware .And. ( (SRV->RV_NATUREZ == "9901" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9201" .And. SRV->RV_INCCP $ "31/32") .Or. (SRV->RV_NATUREZ == "1409" .And. SRV->RV_INCCP == "51") .Or. (SRV->RV_NATUREZ == "4050" .And. SRV->RV_INCCP == "21") .Or. (SRV->RV_NATUREZ == "4051" .And. SRV->RV_INCCP == "22") .Or. (SRV->RV_NATUREZ == "9902" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9904" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9908" .And. SRV->RV_TIPOCOD == "3") )
				fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aDadosCCT[nPosCC, 2], aDadosCCT[nPosCC, 3], aDadosCCT[nPosCC, 4], SRV->RV_NATUREZ, SRV->RV_TIPOCOD, SRV->RV_INCCP, SRV->RV_INCFGTS, SRV->RV_INCIRF, (cAliasPLR)->RD_VALOR, "S-2299" , , , , If(lRVIncop, SRV->RV_INCOP,""), If(lRVTetop, SRV->RV_TETOP, ""))
			EndIf
		EndIf

		(cAliasPLR)->(dbSkip())

		If dLastDate != (cAliasPLR)->RD_DATPGT .Or. (cAliasPLR)->(Eof())
			If M->RA_CATEFD $ "738/731/734/201/202/"
				cXml += "<infoAgNocivo>"
				If ! Empty(SRA->RA_OCORREN) .And. AllTrim(SRA->RA_OCORREN) $ "02|03|04"
					cXml += "<grauExp>" + cValToChar(Val(SRA->RA_OCORREN)) + "</grauExp>"
				Else
					cXml += "<grauExp>1</grauExp>"
				EndIf
				cXml += "</infoAgNocivo>"
			EndIf
			If ! Empty(cIndSimp)
				cXml += "<infoSimples>"
				cXml += "<indSimples>" + cIndSimp + "</indSimples>"
				cXml += "</infoSimples>"
			EndIf
			cXml += "</ideEstabLot>"
			cXml += "</dmDev>"
		EndIf

	EndDo

	(cAliasPLR)->(dbCloseArea())

	RestArea(aArea)

Return
