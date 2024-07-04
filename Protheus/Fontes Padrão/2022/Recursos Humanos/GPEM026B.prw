#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "GPEM026.CH"

Static aTabS050 := {}
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPEM026B ³ Autor ³ Eduardo Vicente F                           ³ Data ³ 10/05/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de Envio de Eventos - Relacionados a alteração salarial via JOB             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM026B()                                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista     ³ Data     ³ FNC/Requisito  ³ Chamado ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Eduardo Vicente³10/05/2017³DRHESOCP-985            ³Realizar a geração do evento S-2206        ³±±
±±³Eduardo Vicente³29/06/2017³DRHESOCP-520            ³Envio das info de Afastam(IntAfastSC)      ³±±
±±³Eduardo Vicente³03/07/2017³DRHESOCP-520            ³Ajuste de query, incluindo campo D_E_L_E_T_³±±
±±³Marcia Moura   ³07/07/2017³DRHESOCP-579            ³Apenas para subir  fonte ambiente sistemico³±±
±±³Eduardo Vicente³02/08/2017³DRHESOCP-744            ³Ajustes na chamada da Função fGp23Cons	  ³±±
±±³Oswaldo L      ³02/08/2017³DRHESOCP-755            ³Merge e-social 11.80 e 12.1.17	          ³±±
±±³Eduardo V      ³11/08/2017 ³DRHESOCP-781    ³         ³Correções de erros apontadas a issue 592   ³±±
±±³Cecília Carv   ³08/01/2018³DRHESOCP-2682           ³Ajuste para geração de contrato intermiten³±±
±±³               ³          ³                        ³te - evento S-2200.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

function GPEM026B(aParam ,aRotAuto)

Local cParam1		:= ''
Local cParam2		:= ''

Local dCortTurno	:= cToD("//")

Local lAltSal 		:= .T.
Local lAfast		:= .T.
Local lAltSindica	:= .T.
Local lConvoca		:= .T.
Local lAltDep		:= .T.
Local lAltTurno		:= .T.

Private lAuto		:=	(aRotAuto <> Nil) //verifica se é execução via robô
Private lIntegTAF	:= .T.
Private lMiddleware := .F.
Private lMVDtFimA 	:= .F.
Private lNT15 		:= .F.
Private cVersMW		:= ""
Private lTafKeys	:= .F.
Private lSPFCampos	:= .F.

	IF LEN(aParam) > 4
		if valtype(aParam[1]) == 'L'
			lAltSal 		:= aParam[1]
		elseif valtype(aParam[1]) == 'C'
			cParam1	:= aParam[1]
		endif

		if valtype(aParam[2]) == 'L'
			lAfast			:= aParam[2]
		elseif valtype(aParam[2]) == 'C'
			if Empty(cParam1)
				cParam1 := aParam[2]
			else
				cParam2 := aParam[2]
			endif
		endif

		if valtype(aParam[3]) == 'L'
			lAltSindica		:= aParam[3]
		elseif valtype(aParam[3]) == 'C'
			if Empty(cParam1)
				cParam1 := aParam[3]
			elseif empty(cParam2)
				cParam2 := aParam[3]
			endif
		endif

		if valtype(aParam[4]) == 'L'
			lConvoca		:= aParam[4]
		elseif valtype(aParam[4]) == 'C'
			if Empty(cParam1)
				cParam1 := aParam[4]
			elseif empty(cParam2)
				cParam2 := aParam[4]
			endif
		endif

		//Verifica se deve executar o job de alteração de dependente
		If valtype(aParam[5]) == 'L'
			lAltDep	:= aParam[5]
		Elseif valtype(aParam[5]) == 'C'
			If Empty(cParam1)
				cParam1 := aParam[5]
			Else
				cParam2 := aParam[5]
			Endif
		EndIf

		If valtype(aParam[6]) == 'L'
			lAltTurno	:= aParam[6]
		Elseif valtype(aParam[6]) == 'C'
			If Empty(cParam1)
				cParam1 := aParam[6]
			Else
				cParam2 := aParam[6]
			Endif
		EndIf

		RpcSetType(3)
		if empty(cParam1) .and. empty(cParam2)
			cParam1 := aParam[7]
			cParam2 := aParam[8]
		endif

		RPCsetEnv(cParam1, cParam2)

	ElseIf Len(aParam) > 0
		RpcSetType(3)
		If empty(cParam1) .and. empty(cParam2)
			cParam1 := aParam[1]
			cParam2 := aParam[2]
		Endif

		RPCsetEnv(cParam1, cParam2)
	ENDIF

	//Checa se a rotina está em execução
	If LockByName("GPEM026B"+cEmpAnt+cFilAnt,.T.,.T.,.T.)
		lIntegTAF 	:= If(cPaisLoc == 'BRA' ,SuperGetMv("MV_RHTAF",nil,.F.), .F.) ////Integracao com TAF
		lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
		lMVDtFimA   := SuperGetMV("MV_DTFIMA", Nil, .F. )
		lTafKeys	:= SR8->(ColumnPos( "R8_TAFKI")) > 0 .And. SR8->(ColumnPos( "R8_TAFKF")) > 0
		lSPFCampos	:= SPF->(ColumnPos( "PF_INTGTAF" )) > 0
		dCortTurno	:= Iif( ValType(SuperGetMv("MV_DTCGTNO", nil, cToD("//"))) != 'D', cToD("//"), SuperGetMv("MV_DTCGTNO", nil, cToD("//")) )

		If lAuto .and. lAltSal
			IntAltSal(aParam,aRotAuto)
		Else
			if lAltSal
				//------------------------------------------------
				//Chamada da função responsável por analisar e
				// enviar as informações de alterações saláriais
				//------------------------------------------------
				conout("===============================================================")
				conout("| Iniciando o Processamento das Alterações Salariais   		  |")
				conout("===============================================================")
				IntAltSal(aParam)
				conout("===============================================================")
				conout("| Termino do Processamento das Alterações Salariais 		  |")
				conout("===============================================================")
			endIf

			if lAfast
				//------------------------------------------------
				//Chamada da função responsável por analisar e
				// enviar as informações de afastamento
				//------------------------------------------------
				conout("===============================================================")
				conout("| Iniciando o Processamento dos Afastamentos Vencidos		  |")
				conout("===============================================================")
				IntAfastSC(aParam)
				conout("===============================================================")
				conout("| Termino do Processamento dos Afastamentos Vencidos		  |")
				conout("===============================================================")
			endif

			if lAltSindica
				If ChkFile("RJB") .and. ChkFile("RJC") // se existem as tabelas RJB e RJC, continua com o processamento
					//------------------------------------------------
					//Chamada da função responsável por analisar e
					// enviar as informações de alteracao do sindicato
					//------------------------------------------------
					conout("===============================================================")
					conout("| Iniciando o Processamento de Alteração dos Sindicatos		  |")
					conout("===============================================================")
					IntProcSind(aParam)
					conout("===============================================================")
					conout("| Termino do Processamento de Alteração dos Sindicatos		  |")
					conout("===============================================================")
				Endif
			endif

			if lConvoca
				If ChkFile("RJB") .and. ChkFile("RJC") // se existem as tabelas RJB e RJC, continua com o processamento
					//------------------------------------------------
					//Chamada da função responsável por analisar e
					// enviar as informações de alteracao do local de convocação
					//------------------------------------------------
					conout("===============================================================")
					conout("| Iniciando o Processamento de Alteração dos Locais de Convocação |")
					conout("===============================================================")
					IntLocConv(aParam)
					conout("===============================================================")
					conout("| Termino do Processamento de Alteração dos Locais de Convocação |")
					conout("===============================================================")
				endif
			Endif

			IF lAltDep
				If ChkFile("RJB") .and. ChkFile("RJC") // se existem as tabelas RJB e RJC, continua com o processamento
					//------------------------------------------------
					//Chamada da função responsável por analisar e
					// enviar as informações de alteracão no cadastro de dependentes
					//------------------------------------------------
					conout("===============================================================")
					conout("| Iniciando o Processamento de Alteração de Dependentes	|")
					conout("===============================================================")
					IntAltDep(aParam)
					conout("===============================================================")
					conout("| Termino do Processamento de Alteração de Dependentes |")
					conout("===============================================================")
				EndIf
			EndIf

			If lAltTurno .And. !lSPFCampos
				conout("===============================================================")
				conout("| Iniciando o Processamento de Alteração de Troca de Turno |")
				conout("===============================================================")
				conout("Para o envio da troca de turno, é necessário possuir os campos PF_INTGTAF e PF_TAFKEY no dicionário.")
				conout("Solicite a execução do UPDDISTR para o administrador do sistema.")
				conout("===============================================================")
				conout("| Termino do Processamento de Alteração de Troca de Turno |")
				conout("===============================================================")
			ElseIf lAltTurno .And. Empty( dCortTurno )
				conout("===============================================================")
				conout("| Iniciando o Processamento de Alteração de Troca de Turno |")
				conout("===============================================================")
				conout("Para o envio da troca de turno, é necessário preencher o parâmetro MV_DTCGTNO com a data inicial de corte")
				conout("para o sistema filtrar os registros de troca de turno que serão considerados para envio.")
				conout("===============================================================")
				conout("| Termino do Processamento de Alteração de Troca de Turno |")
				conout("===============================================================")
			ElseIf lAltTurno
				conout("===============================================================")
				conout("| Iniciando o Processamento de Alteração de Troca de Turno |")
				conout("===============================================================")
				IntAltTurno(dCortTurno)
				conout("===============================================================")
				conout("| Termino do Processamento de Alteração de Troca de Turno |")
				conout("===============================================================")
			EndIf

			/*
			* Destrava rotina após finalizar a execução das Threads
			*/
			UnLockByName("GPEM026B"+cEmpAnt+cFilAnt,.T.,.T.,.T.)
		EndIf
	Else
		Aviso(OemToAnsi(STR0053),OemToAnsi(STR0001),{"OK"})//"A rotina está sendo executada em outro processo."#ATENCAO
	EndIf


	If Len(aParam) > 0
		RpcClearEnv()
	EndIf

Return

/*/{Protheus.doc} IntAltSal
Rotina responsável pela leitura e processamento das alterações salariais.
@type function
@author Eduardo
@since 28/06/2017
@version 1.0
@param aParam, array, Parametros enviados pelo Schedule
/*/
Static function IntAltSal(aParam,aRotAuto)

	Local dDtCorte
	Local cCateg		:= fCatTrabEFD("TCV") + "|" + fCatTrabEFD("TSV") //'101*102*103*104*105*106*111*301*302*303*306*307*309'+'201*202*305*308*401*410*701*711*712*721*722*723*731*734*738*741*751*761*771*781*901*902*903'
	Local cCategCV		:= fCatTrabEFD("TCV")
	Local cAliasSR3		:= nil
	Local cCPF			:= ""
	Local cStatus		:= ""
	Local cVersEnvio	:= ""
	Local cVersGPE		:= ""
	Local cTipo			:= ""
	Local lAdmPubl	 	:= .F.
	Local aInfoC	 	:= {}
	Local aErros		:= {}
	Local cMsgErro		:= ""
	Local lGeraMat		:= .F.
	Local lMatTSV		:= SRA->(ColumnPos("RA_DESCEP")) > 0

	default aParam		:= {}
	default lAuto		:= .F.

		If lMiddleware .And. !ChkFile("RJE")
			Return
		EndIf

		dDtCorte	:= SuperGetMV("MV_DTCGINI",nil,DDATABASE)
		If FindFunction("fVersEsoc")
			fVersEsoc( "S2206", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE )
		EndIf

		//Realiza a Consulta na SR3 para checagem de atualizações salariais
		If lAuto
			cAliasSR3:= GPR3SAL(dDTCorte, aRotAuto[1] , aRotAuto[2])
		Else
			cAliasSR3:= GPR3SAL(dDtCorte)
		EndIf

		DbSelectArea("SR3")
		DbSelectArea("SRA")
		SR3->(dbSetOrder(1))
		SRA->(dbSetOrder(1))

		cTipo := fBuscaTipo(.F.)

		//REALIZA A VARREDURA NO ALIAS, CHECANDO QUAIS FORAM OS NOVOS REGISTROS
		While (cAliasSR3)->(!Eof())

			If !Empty((cAliasSR3)->R3_INTGTAF) .AND. ( (cAliasSR3)->R3_DATA < dDTCorte .OR. ( !Empty((cAliasSR3)->R3_DTCDISS) .AND. STOD((cAliasSR3)->R3_DTCDISS) < dDTCorte .And. (cAliasSR3)->R3_TIPO $ cTipo ) )
				(cAliasSR3)->(DBSkip())
				loop
			EndIf

			//POSICIONA NA SRA PARA ENVIAR O REGISTRO CORRETO PARA O TAF
			If !Empty((cAliasSR3)->R3_FILIAL+(cAliasSR3)->R3_MAT) .And. SRA->(dbSeek((cAliasSR3)->R3_FILIAL+(cAliasSR3)->R3_MAT)) .And. SRA->RA_SITFOLH <> "D"

				//CHECAGEM SE É VIA SCHEDULE, APRESENTANDO A MENSAGEM DE REGISTRO SENDO PROCESSADO
				if Len(aParam) > 0
					// "Processando " #	 "Nome: "			 "Matricula: "					 " Filial: "
					MSGINFO( STR0052 + " " + STR0010+": " +SRA->RA_NOME + " "+STR0009+": "+ SRA->RA_MAT + STR0051 + SRA->RA_FILIAL , STR0001)
				endIf
				//VALIDA CATEGORIA DO FUNCIONÁRIO
				If !Empty(SRA->RA_CATEFD) .And. (SRA->RA_CATEFD $ cCateg )
					If SRA->RA_CATEFD $ cCategCV
						cCPF 	:= AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC)
						If  !lMiddleware
							//VERIFICA SE FUNCIONÁRIO JÁ FOI INTEGRADO
							cStatus := TAFGetStat( "S-2200", cCPF )//ADMISSAO POR CADASTRO
						Else
							cStatus := "-1"
							fPosFil( cEmpAnt, SRA->RA_FILIAL )
							aInfoC   := fXMLInfos()
							If LEN(aInfoC) >= 4
								cTpInsc  := aInfoC[1]
								lAdmPubl := aInfoC[4]
								cNrInsc  := aInfoC[2]
							Else
								cTpInsc  := ""
								lAdmPubl := .F.
								cNrInsc  := "0"
							EndIf
							cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
							cStatus 	:= "-1"
							//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
							GetInfRJE( 2, cChaveMid, @cStatus )
						Endif
					Else
						If !lMiddleware 
							 lGeraMat :=  If(lMatTSV .And. SRA->RA_DESCEP == "1", .T., lGeraMat) 
							If cVersEnvio >= "9.0"
								cCPF := AllTrim( SRA->RA_CIC ) + ";" + Iif(lGeraMat, SRA->RA_CODUNIC, "") + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + dToS( SRA->RA_ADMISSA )  //  S.1 o índice na C9V é o 22 => C9V_FILIAL, C9V_CPF, C9V_MATTSV, C9V_CATCI, C9V_DTINIV, C9V_ATIVO
							Else
								cCPF := AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + dToS( SRA->RA_ADMISSA ) //  2.5 o índice na C9V é o 17 => C9V_FILIAL, C9V_CPF, C9V_CATCI, C9V_DTINIV, C9V_ATIVO
							EndIf 
							//VERIFICA SE FUNCIONÁRIO JÁ FOI INTEGRADO
							cStatus := TAFGetStat( "S-2300", cCPF )
						Else
							cCPF 	:= AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA )
							fPosFil( cEmpAnt, SRA->RA_FILIAL )
							aInfoC   := fXMLInfos()
							If LEN(aInfoC) >= 4
								cTpInsc  := aInfoC[1]
								lAdmPubl := aInfoC[4]
								cNrInsc  := aInfoC[2]
							Else
								cTpInsc  := ""
								lAdmPubl := .F.
								cNrInsc  := "0"
							EndIf
							cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cCPF, 40, " ")
							cStatus 	:= "-1"
							//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
							GetInfRJE( 2, cChaveMid, @cStatus )
						EndIf
                    EndIf

					If (cStatus  == "4" )
						aErros := {}
						RegToMemory("SRA",.F.,.T.,.F.)

						If SRA->RA_ADMISSA == StoD((cAliasSR3)->R3_DATA) .And. (cAliasSR3)->R3_TIPO = '001'
							//se o registro encontrado do funcionário for referente à admissão, atualiza a data de integracao e verifica se há outro aumento para este funcionario
							If SR3->(DBSEEK((cAliasSR3)->R3_FILIAL+(cAliasSR3)->R3_MAT+(cAliasSR3)->R3_DATA+(cAliasSR3)->R3_TIPO+(cAliasSR3)->R3_PD))
								GPR3INT((cAliasSR3)->R3_FILIAL+(cAliasSR3)->R3_MAT+(cAliasSR3)->R3_DATA+(cAliasSR3)->R3_TIPO+(cAliasSR3)->R3_PD)
								(cAliasSR3)->(dbSkip())
								//verifica se é a mesma matrícula. Caso não seja a mesma matrícula volta para o inicio do loop
								If !((cAliasSR3)->R3_FILIAL+(cAliasSR3)->R3_MAT == SRA->RA_FILIAL+SRA->RA_MAT)
									loop
								EndIf
							EndIf
						EndIf
						If SR3->(DBSEEK((cAliasSR3)->R3_FILIAL+(cAliasSR3)->R3_MAT+(cAliasSR3)->R3_DATA+(cAliasSR3)->R3_TIPO+(cAliasSR3)->R3_PD))
							If (SRA->RA_CATEFD $ cCategCV .And. fInt2206("SRA", ,If(lMiddleware,4 ,Nil ) ,"S2206",,DTOS(SR3->R3_DATA),,,,,cVersEnvio, Nil, Nil, Nil, Nil, @aErros, .F.,,Iif( !lMiddleware, Transform(SR3->R3_VALOR,"@E 999999999.99"), SR3->R3_VALOR),,,,,,,SR3->R3_DTCDISS )) .Or.;
                                (!(SRA->RA_CATEFD $ cCategCV) .And. fInt2306New("SRA", Nil, If(lMiddleware, 4, Nil), "S2306", Nil, Nil, cVersEnvio, Nil, Nil, Nil, SR3->R3_DATA, .T., @aErros, .F.))
								//ATUALIZA O CAMPO R3_INTGTAF
								GPR3INT((cAliasSR3)->R3_FILIAL+(cAliasSR3)->R3_MAT+(cAliasSR3)->R3_DATA+(cAliasSR3)->R3_TIPO+(cAliasSR3)->R3_PD)
								if Len(aParam) > 0
									// "Funcionário: " #	 "Nome: "					 "Matricula: "					" Filial: "						"Processado com Sucesso"
									MSGINFO( STR0035 + ":" + STR0010+": "+SRA->RA_NOME + " "+STR0009+": "+ SRA->RA_MAT + STR0051 + SRA->RA_FILIAL + " " +STR0049 , STR0001)
								EndIf
							Else
								// "Funcionário: " #	 "Nome: "					 "Matricula: "					" Filial: "						" não enviado(a) ao TAF. Erro: "##" não enviado(a) ao Middleware. Erro: "
								MSGINFO( STR0035 + ":" + STR0010+": "+SRA->RA_NOME + " "+STR0009+": "+ SRA->RA_MAT + STR0051 + SRA->RA_FILIAL + " " + Iif( !lMiddleware, STR0036, STR0137), STR0001)
								If Len( aErros ) > 0
									If !lMiddleware
										FeSoc2Err( aErros[1], @cMsgErro , Iif( aErros[1] != '000026',1,2 ) )
										FrmTexto(@cMsgErro)
										MSGINFO(cMsgErro)
									Else
										MSGINFO(aErros[1])
									EndIf
								EndIf
							Endif

						EndIf
					Else
						if Len(aParam) > 0
							If !lMiddleware
								msginfo( STR0087, STR0001)//"Verificar colaborador, pois o mesmo se encontra com a categoria em branco ou incorreta para o eSocial:"#ATENCAO
							Else
								Msginfo( STR0139, STR0001)//"Verificar colaborador, pois o mesmo se encontra com a categoria em branco ou incorreta para o eSocial:"#ATENCAO
							Endif
						endif
					EndIf
				EndIf
			EndIf
			(cAliasSR3)->(dbSkip())
			//verifica se é a mesma matrícula, pois será enviado apenas 1 aumento por funcionário por execução do JOB.
			While (cAliasSR3)->(!EoF()) .And. ((cAliasSR3)->R3_FILIAL+(cAliasSR3)->R3_MAT == SRA->RA_FILIAL+SRA->RA_MAT)
				(cAliasSR3)->(dbSkip())
			EndDo
		EndDo
return .T.


/*/{Protheus.doc} GPR3SAL
//Função responsável pela busca de alterações Salariais e retorno do alias
@author Eduardo
@since 11/05/2017
@param dDTCorte, date, descricao
@param cFilial, characters, descricao
@param cMat, characters, descricao
@return return, return_description
/*/
function GPR3SAL(dDTCorte, cFil , cMat ,lSalRedRGE)
Local cQryWhere		:= ""
Local cAliasSR3  	:= GetNextAlias()
Local cDtEnvio		:= "%%"
Local cQryWh1		:= ""
Local cTipo			:= ""

Default dDTCorte:= DDATABASE
Default cFil	:= ""
Default cMat	:= ""
Default lSalRedRGE := .F.

	cTipo := fBuscaTipo(.T.)
	cQryWhere := "SR3.R3_INTGTAF = '' AND  (SR3.R3_DATA >='"+DtoS(dDTCorte)+"' OR (SR3.R3_DTCDISS <> '' AND SR3.R3_DTCDISS >= '"+DtoS(dDTCorte)+"' AND SR3.R3_TIPO IN ("+cTipo+")))"

	if !Empty(cFil) .And. !Empty(cMat)
		cQryWhere	+= " AND SR3.R3_FILIAL= '"+cFil+"' AND SR3.R3_MAT = '"+cMat+"'"
	Else
		cQryWhere	+= " AND SR3.R3_FILIAL= '"+xFilial("SR3")+"'
	endIf

	cQryWhere:="%("+cQryWhere+")%"
	If !Empty(cFil) .And. !Empty(cMat)
		cQryWh1:= Replace(cQryWhere,"R3_INTGTAF = ''","R3_INTGTAF <> ''")

		BeginSql alias cAliasSR3
			SELECT R3_FILIAL, R3_MAT, MAX(R3_DATA) R3_DATA
				FROM  %table:SR3% SR3
				WHERE SR3.D_E_L_E_T_= ' ' AND   (%exp:cQryWh1%)
				GROUP BY R3_FILIAL,R3_MAT, R3_DATA
		EndSql

		If !(cAliasSR3)->(eof())
			cDtEnvio := "% WHERE SR3.R3_DATA > '"+(cAliasSR3)->R3_DATA+"' %"
		EndIf
		(cAliasSR3)->(DbCloseArea())
		cAliasSR3  	:= GetNextAlias()
	EndIf
	If !lSalRedRGE
		BeginSql alias cAliasSR3
			Select SR3.* from
			(SELECT R3_FILIAL, R3_MAT, MAX(R3_DATA) R3_DATA
			FROM  %table:SR3% SR3
			WHERE SR3.D_E_L_E_T_= ' ' AND   (%exp:cQryWhere%)
			GROUP BY R3_FILIAL,R3_MAT,R3_DATA ) SR3V
			JOIN %table:SR3% SR3
			ON	SR3.R3_DATA = SR3V.R3_DATA 		AND
					SR3.R3_MAT	= SR3V.R3_MAT 		AND
					SR3.R3_FILIAL = SR3V.R3_FILIAL 	AND
					SR3.D_E_L_E_T_= ' ' 			AND
					SR3.R3_INTGTAF = ''				AND
					SR3.R3_PD = '000'
			%exp:cDtEnvio%
			ORDER BY
			SR3.R3_MAT
		EndSql
	Else
		cQryWhere:= Replace(cQryWhere,"R3_INTGTAF = ''","R3_INTGTAF <> ''")
		BeginSql alias cAliasSR3
			Select SR3.* from
			(SELECT R3_FILIAL, R3_MAT, MAX(R3_DATA) R3_DATA
			FROM  %table:SR3% SR3
			WHERE SR3.D_E_L_E_T_= ' ' AND   (%exp:cQryWhere%)
			GROUP BY R3_FILIAL,R3_MAT,R3_DATA ) SR3V
			JOIN %table:SR3% SR3
			ON	SR3.R3_DATA = SR3V.R3_DATA 		AND
					SR3.R3_MAT	= SR3V.R3_MAT 		AND
					SR3.R3_FILIAL = SR3V.R3_FILIAL 	AND
					SR3.D_E_L_E_T_= ' ' 			AND
					SR3.R3_INTGTAF <> ''				AND
					SR3.R3_PD = '000'
			%exp:cDtEnvio%
			ORDER BY
			SR3.R3_MAT
		EndSql
	Endif
	(cAliasSR3)->(DBGotop())
	dbSelectArea(cAliasSR3)
return cAliasSR3

/*/{Protheus.doc} GPR3INT
//Rotina de preenchimento do campo de flag da SR3
@author Eduardo
@since 15/05/2017
@param cChave, characters, chave de busca
/*/
function GPR3INT(cChave)

	DbSelectArea("SR3")
	SR3->(dbSetOrder(1))
	If SR3->(DbSeek(cChave))
		If Empty(SR3->R3_INTGTAF)
			//ATUALIZA O CAMPO R3_INTGTAF
			RecLock("SR3",.F.)
			SR3->R3_INTGTAF:= SR3->R3_DATA
			SR3->(MsUnlock())
		EndIf
	EndIf
Return

/*/{Protheus.doc} IntAfastSC
Função responsável pela tratativa dos afastamentos.
@author Eduardo
@since 28/06/2017
@param aParam, array, Parametros enviados via schedule
/*/
Static function IntAfastSC(aParam)

	Local dDtCorte
	Local cCateg	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|304|306|901" //Trabalhador com vinculo
	Local cAliasSR8	:= nil
	Local cCPF		:= ""
	Local cStatus	:= ""

	Local dDcgIni      :=  SuperGetMV("MV_DTCGINI",nil,CTOD(" / / ") )
	Local cVersEnv	:= ""
	Local aInfoC	:= {}
	Local cChaveMid	:= ""
	Local cNrInsc	:= ""
	Local cTpInsc	:= ""
	Local lAdmPubl	:= .F.
	Local cId		:= ""
	Local lCpoInt	:= ( SR8->(ColumnPos("R8_INTTAF")) > 0 )
	Local lGeraMat	:= SRA->(ColumnPos("RA_DESCEP")) > 0 .And. SRA->RA_DESCEP == "1"
	Local lGera2231		:= (SR8->(ColumnPos( "R8_CNPJCES")) > 0 .And. SR8->(ColumnPos("R8_TPCES")) > 0 )

	default aParam	:= {}

	dDtCorte	:= DDATABASE

	//Realiza a Consulta na SR8 para checagem de Afastamentos
	cAliasSR8:= GPR8AFAST(dDtCorte, Nil, Nil, lCpoInt, lGera2231)
	DbSelectArea("SR8")
	DbSelectArea("SRA")
	SR8->(dbSetOrder(1))
	SRA->(dbSetOrder(1))

	If FindFunction("fVersEsoc")
		fVersEsoc( "S2230", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnv, Nil, @cVersMW, @lNT15  )
	EndIf

	//REALIZA A VARREDURA NO ALIAS, CHECANDO QUAIS FORAM OS NOVOS REGISTROS
	While (cAliasSR8)->(!Eof())

		IF !EMPTY((cAliasSR8)->R8_TAFKI) .AND. !EMPTY((cAliasSR8)->R8_TAFKF)
			(cAliasSR8)->(DBSkip())
			loop
		EndIf

		IF (cAliasSR8)->R8_INTGTAF >= (cAliasSR8)->R8_DATAFIM .And. If((cAliasSR8)->R8_TPEFD <> "40" .Or.((cAliasSR8)->R8_TPEFD == "40".And. !EMPTY((cAliasSR8)->R8_TAFKF)),.T.,.F.)
			(cAliasSR8)->(DBSkip())
			loop
		EndIf

		If dDTCorte >= Stod((cAliasSR8)->R8_DATAFIM) .Or. ( (cAliasSR8)->R8_TIPOAFA == "001" .And. (cAliasSR8)->R8_DATAINI >= DtoS(dDcgIni) .And. (cAliasSR8)->R8_DATAINI <= DtoS(dDtCorte) .And. Empty((cAliasSR8)->R8_INTGTAF) )
			If (cAliasSR8)->R8_TIPOAFA == "001" //ferias
				If !Empty((cAliasSR8)->R8_INTGTAF) .Or.;
				( !Empty(dDcgIni) .And. !Empty((cAliasSR8)->R8_DATAFIM) .And. dDcgIni >= Stod((cAliasSR8)->R8_DATAFIM) )
					(cAliasSR8)->(DBSkip())
					loop
				EndIf
			Else
				If ((cAliasSR8)->R8_DURACAO > 15 .AND. (cAliasSR8)->R8_INTGTAF >= (cAliasSR8)->R8_DATAFIM) .OR.;
				Empty((cAliasSR8)->R8_DATAFIM) .OR. ;
				((cAliasSR8)->R8_DURACAO < 3 .AND. !((cAliasSR8)->R8_TPEFD $ "01|02|40")) .OR.;
				(!Empty(Stod((cAliasSR8)->R8_DATAINI)) .AND. !Empty(Stod((cAliasSR8)->R8_DATAFIM)) .And. !Empty(dDcgIni) .And. (dDcgIni >= Stod((cAliasSR8)->R8_DATAINI) .AND. dDcgIni >= Stod((cAliasSR8)->R8_DATAFIM)))

					(cAliasSR8)->(DBSkip())
					loop

				EndIf
			EndIf
		Else
			(cAliasSR8)->(DBSkip())
			loop
		EndIf
		//POSICIONA NA SRA PARA ENVIAR O REGISTRO CORRETO PARA O TAF
		If !Empty((cAliasSR8)->R8_FILIAL+(cAliasSR8)->R8_MAT) .And. SRA->(dbSeek((cAliasSR8)->R8_FILIAL+(cAliasSR8)->R8_MAT))

			//CHECAGEM SE É VIA SCHEDULE, APRESENTANDO A MENSAGEM DE REGISTRO SENDO PROCESSADO
			if Len(aParam) > 0
					// "Processando " #	 "Nome: "			 "Matricula: "					 " Filial: "
				MSGINFO( STR0052 + " " + STR0010 +": " +SRA->RA_NOME + " "+STR0009+": "+ SRA->RA_MAT + STR0051 + SRA->RA_FILIAL , STR0001)
			endIf
				//VALIDA CATEGORIA DO FUNCIONÁRIO
			If !Empty(SRA->RA_CATEFD)

				If lMiddleware
					cStatus := "-1"
					fPosFil( cEmpAnt, SRA->RA_FILIAL )
					aInfoC   := fXMLInfos()
					If Len(aInfoC) >= 4
						cTpInsc  := aInfoC[1]
						lAdmPubl := aInfoC[4]
						cNrInsc  := aInfoC[2]
						cId  	 := aInfoC[3]
					Else
						cTpInsc  := ""
						lAdmPubl := .F.
						cNrInsc  := "0"
						cId  	:= ""
					EndIf
				EndIf

				//VERIFICA SE FUNCIONÁRIO JÁ FOI INTEGRADO
				If (SRA->RA_CATEFD $ cCateg )
					If !lMiddleware
						cCPF    := AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC)
						cStatus := TAFGetStat( "S-2200", cCPF )//ADMISSAO POR CADASTRO
					Else
						cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
						//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
						GetInfRJE( 2, cChaveMid, @cStatus )
					EndIf
				ElseIf !(SRA->RA_CATEFD $ cCateg )
					If !lMiddleware
						If cVersEnv >= "9.0"
							cCPF := AllTrim( SRA->RA_CIC ) + ";" + If(lGeraMat, SRA->RA_CODUNIC, "") + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
						Else
							cCPF := AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
						EndIf
						cStatus := TAFGetStat( "S-2300", cCPF )//ADMISSAO POR CADASTRO
					Else
						cCPF := If( cVersEnv >= "9.0" .And. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + dToS( SRA->RA_ADMISSA ) )
						cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cCPF, 40, " ")
						//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
						GetInfRJE( 2, cChaveMid, @cStatus )
					EndIf
				Endif
				If cStatus == "4"
					If SR8->(DBSEEK((cAliasSR8)->R8_FILIAL+(cAliasSR8)->R8_MAT+(cAliasSR8)->R8_DATAINI+(cAliasSR8)->R8_TIPO))
						If (cAliasSR8)->R8_TPEFD == "40" 
							If !lGera2231
								MsgInfo(STR0312,STR0001)//""#ATENCAO ##"Ambiente desatualizado para geração do evento S-2231"
							Else
								If IntEnvCes(Stod((cAliasSR8)->R8_DATAINI), Stod((cAliasSR8)->R8_DATAFIM), Stod((cAliasSR8)->R8_INTGTAF), dDtCorte, (cAliasSR8)->R8_TIPOAFA, lAdmPubl, cTpInsc, cNrInsc, cId, lCpoInt, Iif( lCpoInt, (cAliasSR8)->R8_INTTAF, Nil ), cVersEnv )
									//ATUALIZA O CAMPO R8_INTGTAF
									GPR8INT((cAliasSR8)->R8_FILIAL+(cAliasSR8)->R8_MAT+(cAliasSR8)->R8_DATAINI+(cAliasSR8)->R8_TIPO)

									if Len(aParam) > 0
											// "Funcionário: " #	 "Nome: "					 "Matricula: "					" Filial: "						"Processado com Sucesso"
										MSGINFO( STR0035 + ":" + STR0010+": "+SRA->RA_NOME + " "+STR0009+": "+ SRA->RA_MAT + STR0051 + SRA->RA_FILIAL + " " +STR0049 , STR0001)
									EndIf
								Endif	
							Endif	
						Else
							If IntEnvAf(Stod((cAliasSR8)->R8_DATAINI), Stod((cAliasSR8)->R8_DATAFIM), Stod((cAliasSR8)->R8_INTGTAF), dDtCorte, (cAliasSR8)->R8_TIPOAFA, lAdmPubl, cTpInsc, cNrInsc, cId, lCpoInt, Iif( lCpoInt, (cAliasSR8)->R8_INTTAF, Nil ), cVersEnv )

								//ATUALIZA O CAMPO R8_INTGTAF
								GPR8INT((cAliasSR8)->R8_FILIAL+(cAliasSR8)->R8_MAT+(cAliasSR8)->R8_DATAINI+(cAliasSR8)->R8_TIPO)

								if Len(aParam) > 0
										// "Funcionário: " #	 "Nome: "					 "Matricula: "					" Filial: "						"Processado com Sucesso"
									MSGINFO( STR0035 + ":" + STR0010+": "+SRA->RA_NOME + " "+STR0009+": "+ SRA->RA_MAT + STR0051 + SRA->RA_FILIAL + " " +STR0049 , STR0001)
								EndIf
							Endif
						Endif	
					EndIf
				Else
					if Len(aParam) > 0
						If !lMiddleware
							msginfo( STR0087, STR0001)//"Favor verificar o Status do registro do funcionário no TAF, pois o mesmo não se encontra enviado para o TAF ou possui algum problema no mesmo antes de enviar esta solicitação."#ATENCAO
						Else
							msginfo( STR0148, STR0001)//"Favor verificar o Status do registro do funcionário no Middleware, pois o mesmo não se encontra enviado para o Middleware ou possui algum problema no mesmo antes de enviar esta solicitação."#ATENCAO
						EndIf
					endif
				EndIf
			EndIf
		EndIf
		(cAliasSR8)->(dbSkip())
	EndDo
return .T.

/*/{Protheus.doc} GPR8AFAST
//Função responsável pela busca de afastamentos e retorno do alias
@author Eduardo
@since 11/05/2017
@param dDTCorte, date, descricao
@param cFilial, characters, descricao
@param cMat, characters, descricao
@return return, return_description
/*/
function GPR8AFAST(dDTCorte, cFil , cMat, lCpoInt, lGera2231 )

	Local cCpos			:= "SR8.R8_FILIAL, SR8.R8_MAT, SR8.R8_DATAINI, SR8.R8_TIPO, SR8.R8_TIPOAFA, SR8.R8_DATAFIM, SR8.R8_INTGTAF, SR8.R8_DURACAO, SR8.R8_TPEFD, SR8.R8_TAFKI, SR8.R8_TAFKF"
	Local cQryWhere		:= ""
	Local cAliasSR8  	:= GetNextAlias()
	Local dDcgIni       := SuperGetMV("MV_DTCGINI",nil,CTOD(" / / ") )
	
	Default dDTCorte	:= DDATABASE
	Default cFil		:= ""
	Default cMat		:= ""
	Default lCpoInt 	:= .F.
	Default lGera2231   := .F.

	if !Empty(cFil) .And. !Empty(cMat)
		cQryWhere	+= "SR8.R8_FILIAL= '"+cFil+"' AND SR8.R8_MAT = '"+cMat+"' "
	Else
		cQryWhere	+= "SR8.R8_FILIAL= '"+xFilial("SR8")+"' "
	endIf

	cQryWhere += "AND (SR8.R8_DATAFIM <= '"+DtoS(dDTCorte)+"' OR "
	cQryWhere += "(SR8.R8_DATAINI >= '"+DtoS(dDcgIni)+"' AND SR8.R8_DATAINI <= '"+DtoS(dDTCorte)+"' AND SR8.R8_TIPOAFA = '001' AND SR8.R8_INTGTAF = '"+Space(8)+"')) "
	cQryWhere += "AND D_E_L_E_T_= ' '"

	cQryWhere := "%("+cQryWhere+")%"

	If lCpoInt
		cCpos	+= ", SR8.R8_INTTAF"
	EndIf

	If lGera2231
		cCpos	+= ", SR8.R8_CNPJCES, SR8.R8_TPCES "
	Endif

	cCpos := "% " + cCpos + " %"
	BeginSql alias cAliasSR8
		Select %exp:cCpos%
		FROM  %table:SR8% SR8
		Where
		(%exp:cQryWhere%)
		ORDER BY
		SR8.R8_MAT
	EndSql

	dbSelectArea(cAliasSR8)
return cAliasSR8

/*/{Protheus.doc} GPR8INT
//Rotina de preenchimento do campo de flag da SR8
@author Eduardo
@since 27/06/2017
@param cChave, characters, chave de busca
/*/
function GPR8INT(cChave)

	DbSelectArea("SR8")
	SR8->(dbSetOrder(1))
	If SR8->(DbSeek(cChave))
		If !(SR8->R8_INTGTAF >= SR8->R8_DATAFIM)
			//ATUALIZA O CAMPO R8_INTGTAF
			RecLock("SR8",.F.)
			SR8->R8_INTGTAF:= SR8->R8_DATAFIM
			SR8->(MsUnlock())
		EndIf
	EndIf
Return

/*/{Protheus.doc} IntEnvAf
Função responsável pela montagem XML e envio das informações via função do TAF
@type function
@author Eduardo
@since 28/06/2017
@version 1.0
/*/
Static Function IntEnvAf(dIni, dFim, dInteg, dCorte, cTipo, lAdmPubl, cTpInsc, cNrInsc, cIdXML, lCpoInt, cInteg, cVersEnvio)

	Local cMsgErro		:= ""
	Local cXml			:= ""
	Local cMsgLog		:= ""
	Local cFilEnv	 	:= ""
	Local cCateg		:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|304|306|901" //Trabalhador com vinculo
	Local nIndex 	 	:= 2
	Local nI			:= 0
	Local nX			:= 0
	Local nPosCmp 	 	:= 0
	Local nEnvS2230	:= 0

	Local lAltDtIni		:= .F.
	Local lAltDtFim		:= .F.
	Local lContinua		:= .T.
	Local lRet			:= .T.
	Local lExec:= .T.

	Local dDcgIni      :=  SuperGetMV("MV_DTCGINI",nil,CTOD(" / / ") )

	Local aAreaSRA		:= SRA->(GetArea())
	Local aAreaSR8		:= SR8->(GetArea())
	Local aIncons	 	:= {}
	Local aChave	 	:= {}
	Local aCmpsCM7		:= {}
	Local aFilInTaf 	:= {}
	Local aArrayFil 	:= {}
	Local aEstb			:= {}
	Local aDados		:= {}
	Local aErros		:= {}

	LOCAL cTicket 		:= ''
	LOCAL cTafKey		:= ''

	LOCAL LTAFINI		:= .F.

	Local cEFDAviso		:= If(cPaisLoc == 'BRA' .And. Findfunction("fEFDAviso"), fEFDAviso(), SuperGetMv("MV_EFDAVIS",, "0")) //Integracao com TAF)
	Local cChaveS2230 	:= ""
	Local cMsgRJE	 	:= ""
	Local aInfoC		:= {}
	Local cChaveMid		:= ""
	Local aDados	 	:= {}
	Local cRetfNew	 	:= ""
	Local cOperNew 	 	:= ""
	Local cOper2230	 	:= "I"
	Local cRecib2230 	:= ""
	Local cRecibAnt  	:= ""
	Local cRecibXML  	:= ""
	Local cRetf2230	 	:= "1"
	Local nRec2230   	:= 0
	Local cStatNew	 	:= ""
	Local cStatus		:= "-1"
	Local lExclui	 	:= .T.
	Local lNovoRJE	 	:= .F.
	Local lS1000 	 	:= .T.
	Local lGeraMat		:= ( cVersEnvio >= "9.0" .And. SRA->(ColumnPos("RA_DESCEP")) > 0 .And. SRA->RA_DESCEP == "1" )

	Default  dIni		:= CtoD ("//")
	Default  dFim		:= CtoD ("//")
	Default  dInteg		:= CtoD ("//")
	Default  dCorte		:= CtoD ("//")
	Default  cTipo		:= "000"
	Default  lAdmPubl	:= .F.
	Default  cTpInsc	:= ""
	Default  cNrInsc	:= ""
	Default  cIdXML		:= ""
	Default  lCpoInt	:= .F.
	Default  cInteg		:= ""
	Default  cVersEnvio	:= ""

	//Regra para envio do XML do evento S-2230 via JOB
	//nEnvS2230 	-> 0-Não envia o XML
	//			 	-> 1-Envia tag de inicio
	//				-> 2-Envia tag de fim
	//				-> 3-Envia as 2 tags (inicio e fim do afastamento)

	If !Empty(dIni) .And. !Empty(dDcgIni) .And. dDcgIni <= dIni
		If !Empty(dFim)
			If dInteg < dFim .And. !Empty(dInteg)
				nEnvS2230 := 2
			Endif
			If Empty(dInteg)
				If (!lCpoInt .Or. cInteg != "2") .And. ( dCorte > dFim .Or. (lNT15 .And. lMVDtFimA) .Or. ( cTipo == "001" .And. dIni >= dDcgIni .And. dIni <= dCorte ) )
					nEnvS2230 := 3
				ElseIf (!lCpoInt .Or. cInteg != "2") .And. dCorte >= dIni .And. dCorte < dFim
					nEnvS2230 := 1
				Endif
			Endif
		ElseIf (!lCpoInt .Or. cInteg != "2") .And. dCorte <= dIni .And. Empty(dInteg)
			nEnvS2230 := 1
		Endif
	ElseIf Empty(dInteg) .And. !Empty(dDcgIni) .And. !Empty(dIni) .And. !Empty(dFim) .And. dIni < dDcgIni .And. dDcgIni < dFim
		nEnvS2230 := 2
	Endif

	If (lIntegTAF .Or. lMiddleware) .And. nEnvS2230 <> 0
		If !lMiddleware
			fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
		EndIf

		If Empty(cFilEnv)
			cFilEnv:= cFilAnt
		EndIf

		If lMiddleware
			cStatus:= "-1"
			lS1000 := fVld1000( AnoMes(SRA->RA_ADMISSA), @cStatus )
			If !lS1000 .And. cEFDAviso != "2"
				Do Case
					Case cStatus == "-1" // nao encontrado na base de dados
						If cEFDAviso == "1"
							Conout(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130))//"Registro do evento X-XXXX não localizado na base de dados"
							lContinua	:= .F.
						EndIf
					Case cStatus == "1" // nao enviado para o governo
						If cEFDAviso == "1"
							Conout(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131))//"Registro do evento X-XXXX não transmitido para o governo"
							lContinua	:= .F.
						EndIf
					Case cStatus == "2" // enviado e aguardando retorno do governo
						If cEFDAviso == "1"
							Conout(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132))//"Registro do evento X-XXXX aguardando retorno do governo"
							lContinua	:= .F.
						EndIf
					Case cStatus == "3" // enviado e retornado com erro
						If cEFDAviso == "1"
							Conout(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133))//"Registro do evento X-XXXX retornado com erro do governo"
							lContinua	:= .F.
						EndIf
				EndCase
			EndIf
		EndIf

		//Efetua a integracao com TAF
		If !Empty(cFilEnv) .AND. lContinua
			cXml := ""
			If !lMiddleware
				cXml +='<eSocial>'
				cXml +='<evtAfastTemp>'
			Else
				If nEnvS2230 == 1 .Or. nEnvS2230 == 3
					If nEnvS2230 == 3
						cChaveS2230	:= Iif(SRA->RA_CATEFD $ cCateg .Or. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + dToS( SRA->RA_ADMISSA )) + dToS(SR8->R8_DATAINI) + "C"
					Else
						cChaveS2230	:= Iif(SRA->RA_CATEFD $ cCateg .Or. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + dToS( SRA->RA_ADMISSA )) + dToS(SR8->R8_DATAINI) + "I"
					EndIf
				Else
					cChaveS2230	:= Iif(SRA->RA_CATEFD $ cCateg .Or. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + dToS( SRA->RA_ADMISSA )) + dToS(SR8->R8_DATAINI) + "F"
				EndIf
				cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2230" + Padr(cChaveS2230, 40, " ")
				cStat2230 	:= "-1"
				nRec2230	:= 0
				GetInfRJE( 2, cChaveBus, @cStat2230, @cOper2230, @cRetf2230, @nRec2230, @cRecib2230, @cRecibAnt, Nil, Nil, .T. )

				//Retorno pendente impede o cadastro
				If cStat2230 == "2" .And. cEFDAviso != "2"
					cMsgErro 	:= STR0134//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
				//Evento com exclusão sem transmissão
				ElseIf cStat2230 == "99"
					cMsgErro 	:= STR0146//"Operação não será realizada pois há evento de exclusão pendente para transmissão"
				//Evento sem transmissão, irá sobrescrever o registro na fila
				ElseIf cStat2230 $ "1/3"
					cOperNew 	:= cOper2230
					cRetfNew	:= cRetf2230
					cStatNew	:= "1"
					lNovoRJE	:= .F.
				//Evento diferente de exclusão transmitido, irá gerar uma retificação
				ElseIf cOper2230 != "E" .And. cStat2230 == "4"
					cOperNew 	:= "A"
					cRetfNew	:= "2"
					cStatNew	:=  "1"
					lNovoRJE	:= .T.
				//Será tratado como inclusão
				Else
					cOperNew 	:= "I"
					cRetfNew	:= "1"
					cStatNew	:= "1"
					lNovoRJE	:= .T.
				EndIf
				If !Empty(cMsgErro)
					aAdd( aErros, cMsgErro )
					Conout(cMsgErro)
					lContinua := .F.
				EndIf
				If cRetfNew == "2"
					If cStat2230 == "4"
						cRecibXML 	:= cRecib2230
						cRecibAnt	:= cRecib2230
						cRecib2230	:= ""
					Else
						cRecibXML 	:= cRecibAnt
					EndIf
				EndIf

				aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2230", Space(6), cChaveS2230, cIdXml, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, cRecib2230, cRecibAnt } )

				cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtAfastTemp/v" + cVersMw + "'>"
				cXML += 	"<evtAfastTemp Id='" + cIdXml + "'>"
				fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, 1, 1, "12" } )
				fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
			EndIf
			cXml +='<ideVinculo>'
			cXml +='<cpfTrab>'+SRA->RA_CIC+'</cpfTrab>'
			If cVersEnvio < "9.0"
				If !lMiddleware
					cXml +='<nisTrab>'+SRA->RA_PIS+'</nisTrab>'
				Else
					cXml +='<nisTrab>'+AllTrim(SRA->RA_PIS)+'</nisTrab>'
				EndIf
			EndIf
			If SRA->RA_CATEFD $ cCateg .Or. lGeraMat
				cXml +='<matricula>'+SRA->RA_CODUNIC+'</matricula>'
			Else
				cXml +='<codCateg>'+ SRA->RA_CATEFD +'</codCateg>'
			EndIf
			cXml +='</ideVinculo>'
			cXml +='<infoAfastamento>'
			If nEnvS2230 == 1 .Or. nEnvS2230 == 3

				lAltDtIni := .T.

				cXml +='<iniAfastamento>'
				If !lMiddleware
					cXml +='<dtIniAfast>'+ DTOS(SR8->R8_DATAINI)+'</dtIniAfast>'
				Else
					cXml +='<dtIniAfast>'+ SubStr( DTOS(SR8->R8_DATAINI), 1, 4 ) + "-" + SubStr( DTOS(SR8->R8_DATAINI), 5, 2 ) + "-" + SubStr( DTOS(SR8->R8_DATAINI), 7, 2 )+'</dtIniAfast>'
				EndIf
				cXml +='<codMotAfast>'+ SR8->R8_TPEFD +'</codMotAfast>'
				if Empty(SR8->R8_CONTAFA) .or. Alltrim(SR8->R8_CONTAFA) $ "0/000/00/"
					cXml +='<infoMesmoMtv>N</infoMesmoMtv>'
				else
					cXml +='<infoMesmoMtv>S</infoMesmoMtv>'
				EndIf

				If SR8->R8_TPEFD $ "01/03" .And. (!lMiddleware .Or. !Empty(SR8->R8_TIPOAT))
					cXml += '<tpAcidTransito>'+ SR8->R8_TIPOAT+'</tpAcidTransito>'
				EndIf
				//cXml +='<observacao>'+ SR8->R8_MEMO +'</observacao>'
				If cVersEnvio >= "9.0"
					If SR8->(ColumnPos( "R8_DTINIF")) > 0
						If SR8->R8_TPEFD == "15" .And. SR8->R8_DATAINI >= CtoD("19/07/2021") .And. ;
						SRA->RA_CATEFD $ fCatTrabEFD("TCV")+"304|310|312|410" .And. !(SRA->RA_VIEMRAI $ "30|31|35") //Ferias
							cXml +='<perAquis>'
							If !lMiddleware
								cXml +='<dtInicio>'+ DTOS(SR8->R8_DTINIF)+'</dtInicio>'
							Else
								cXml +='<dtInicio>'+ SubStr( DTOS(SR8->R8_DTINIF), 1, 4 ) + "-" + SubStr( DTOS(SR8->R8_DTINIF), 5, 2 ) + "-" + SubStr( DTOS(SR8->R8_DTINIF), 7, 2 )+'</dtInicio>'
							EndIf
							If !Empty(SR8->R8_DTFMF)
								If !lMiddleware
									cXml +='<dtFim>'+ DTOS(SR8->R8_DTFMF)+'</dtFim>'
								Else
									cXml +='<dtFim>'+ SubStr( DTOS(SR8->R8_DTFMF), 1, 4 ) + "-" + SubStr( DTOS(SR8->R8_DTFMF), 5, 2 ) + "-" + SubStr( DTOS(SR8->R8_DTFMF), 7, 2 )+'</dtFim>'
								EndIf
							EndIf
							cXml +='</perAquis>'
						ElseIf SR8->R8_TPEFD == "22" //Mandato eletivo
							cXml +='<infoMandElet>'
							cXml +='<cnpjMandElet>'+ SR8->R8_CNPJE +'</cnpjMandElet>'
							If SRA->RA_CATEFD == "301"
								If SR8->R8_REMUN == "1"
									cXml +='<indRemunCargo>S</indRemunCargo>'
								ElseIf SR8->R8_REMUN == "2"
									cXml +='<indRemunCargo>N</indRemunCargo>'
								EndIf
							EndIf
							cXml +='</infoMandElet>'
						EndIf
					EndIf
				ElseIf SR8->R8_TPEFD $ "01/03"
					If !lNT15
						cXml +='<infoAtestado>'
						If !lMiddleware
							cXml +='<codCID>'+ SR8->R8_CID+'</codCID>'
						Else
							cXml +='<codCID>'+ AllTrim(StrTran(SR8->R8_CID, ".", ""))+'</codCID>'
						EndIf
						cXml +='<qtdDiasAfast>'+ Alltrim(Str(SR8->R8_DURACAO))+'</qtdDiasAfast>'
						cXml +='<emitente>'
						cXml +='<nmEmit>'+ SubStr(SR8->R8_NMMED,1,70)+'</nmEmit>'
						cXml +='<ideOC>'+ SR8->R8_IDEOC+'</ideOC>'
						cXml +='<nrOc>'+ SR8->R8_CRMMED+'</nrOc>'
						cXml +='<ufOC>'+ SR8->R8_UFCRM+'</ufOC>'
						cXml +='</emitente>'
						cXml +='</infoAtestado>'
					Else
						cXml +='<infoAtestado>'
						If !Empty(SR8->R8_CID)
							If !lMiddleware
								cXml +='<codCID>'+ SR8->R8_CID+'</codCID>'
							Else
								cXml +='<codCID>'+ AllTrim(StrTran(SR8->R8_CID, ".", ""))+'</codCID>'
							EndIf
						Endif
						cXml +='<qtdDiasAfast>'+ Alltrim(Str(SR8->R8_DURACAO))+'</qtdDiasAfast>'
						If !Empty(SR8->R8_IDEOC) .And. !Empty(SR8->R8_NMMED) .And. !Empty(SR8->R8_CRMMED) .And. !Empty(SR8->R8_UFCRM)
							cXml +='<emitente>'
							cXml +='<nmEmit>'+ SubStr(SR8->R8_NMMED,1,70)+'</nmEmit>'
							cXml +='<ideOC>'+ SR8->R8_IDEOC+'</ideOC>'
							cXml +='<nrOc>'+ SR8->R8_CRMMED+'</nrOc>'
							cXml +='<ufOC>'+ SR8->R8_UFCRM+'</ufOC>'
							cXml +='	</emitente>'
						Endif
						cXml +='</infoAtestado>'
					Endif
				EndIf
				If SR8->R8_TPEFD == "14"
					cXml +='<infoCessao>'
					cXml +='<cnpjCess>'+ SR8->R8_CNPJCES+'</cnpjCess>'
					cXml +='<infOnus>'+ SR8->R8_TPCES +'</infOnus>'
					cXml +='</infoCessao>'
				EndIf
				If SR8->R8_TPEFD == "24" .Or. ( SR8->R8_TPEFD $ "22/23/24" .And. cVersEnvio < "9.0" )
					cXml +='<infoMandSind>'
					cXml +='	<cnpjSind>'+ SR8->R8_CNPJSIN+'</cnpjSind>'
					cXml +='	<infOnusRemun>'+ SR8->R8_TPSIND+'</infOnusRemun>'
					cXml +='</infoMandSind>'
				EndIf
				cXml +='</iniAfastamento>'
			Endif
			If nEnvS2230 == 2 .Or. nEnvS2230 == 3

				lAltDtFim := .T.

				cXml +='<fimAfastamento>'
				If !lMiddleware
					cXml +='<dtTermAfast>'+ dtos(SR8->R8_DATAFIM)+'</dtTermAfast>'
				Else
					cXml +='<dtTermAfast>'+ SubStr( DTOS(SR8->R8_DATAFIM), 1, 4 ) + "-" + SubStr( DTOS(SR8->R8_DATAFIM), 5, 2 ) + "-" + SubStr( DTOS(SR8->R8_DATAFIM), 7, 2 )+'</dtTermAfast>'
				EndIf
				If !lMiddleware
					cXml +='<codMotAfast>'+ SR8->R8_TPEFD+' </codMotAfast>'
					if Empty(SR8->R8_CONTAFA) .or. Alltrim(SR8->R8_CONTAFA) $ "0/000/00/"
						cXml +='<infoMesmoMtv>N</infoMesmoMtv>'
					else
						cXml +='<infoMesmoMtv>S</infoMesmoMtv>'
					EndIf
				EndIf
				cXml +='</fimAfastamento>'
			Endif
			cXml +='</infoAfastamento>'
			cXml +='</evtAfastTemp>'
			cXml +='</eSocial>'
		EndIf
	EndIf

	if !empty(SR8->R8_TAFKI)
	 	LTAFINI	:= .T.
	else
		LTAFINI	:= .F.
	Endif

	IF lTafKeys
		RecLock("SR8",.F.)

		cTafKey :=  fTafKAfast(SR8->R8_FILIAL,SR8->R8_MAT,SR8->R8_SEQ)

		if lAltDtIni .AND. lAltDtFim
			SR8->R8_TAFKI := cTafKey
			SR8->R8_TAFKF := cTafKey
			cPredeces 	  := ''

		elseif !lAltDtIni .AND. lAltDtFim
			cTicket 		:= ''
			SR8->R8_TAFKF 	:= cTafKey
			cPredeces    	:= SR8->R8_TAFKI
		EndIf

		SR8->(MsUnlock())
	ENDIF

	If !Empty(cXml) .And. lContinua
		//Realiza geração de XML na System
		GrvTxtArq(alltrim(cXml), "S2230", SRA->RA_CIC)
		aErros := {}
		//O TAF fará a gravação da TAFST2 e TAFXERP somente se o quinto elemento do parâmetro for passado como "3"

		If !lMiddleware
			If lTafKeys .AND. !EMPTY(SR8->R8_TAFKI)
				aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, cTafKey , "3", "S2230", , cTicket, , , , "GPE", , cPredeces )
			Else
				aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S2230")
			EndIf
			if 	Len(aErros)> 0
				FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
				Conout(cMsgErro)
				lRet:= IIF(aErros[1]!='000026',.F.,.T.)
			EndIf
		Else
			If !( lRet := fGravaRJE( aDados, cXml, lNovoRJE, nRec2230 ) )
				Conout(STR0136)//"Ocorreu um erro na gravação do registro na tabela RJE"
				lRet := .F.
			EndIf
		EndIf
	Else
		lRet := .F.
	Endif

	IF !lRet

		RecLock("SR8",.F.)
			if !LTAFINI
				SR8->R8_TAFKI := ''
			endif
			SR8->R8_TAFKF := ''
		SR8->(MsUnlock())

	EndIf

	RestArea(aAreaSRA)
	RestArea(aAreaSR8)

Return lRet

Static Function fBuscaTipo(lSql)
Local cTipo := ""
Local nX	:= 1
Default lSql := .T.

If Empty(aTabS050)
	fCarrTab( @aTabS050, "S050", Nil, .T., Nil, .T.)
EndIf

For nX := 1 To Len(aTabS050)
	If Alltrim(aTabS050[nX][6]) $ "C/D"
		If lSql
			cTipo += "'" + aTabS050[nX][5] + "',"
		Else
			cTipo += aTabS050[nX][5] + "/"
		EndIf
	EndIf
Next nX

If lSql .And. !Empty(cTipo)
	cTipo := substr(cTipo ,1,Len(cTipo)-1)
EndIf

If Empty(cTipo)
	cTipo := "'003'"
EndIf

Return cTipo


/*/{Protheus.doc} IntProcSind
Rotina responsável pela leitura e processamento das alterações dos sindicatos.
@type function
@author Gisele Nuncherino
@since 02/05/19
@version 1.0
@param aParam, array, Parametros enviados pelo Schedule
/*/
Static function IntProcSind(aParam)

	Local dDtCorte		:= SuperGetMV("MV_DTCGINI", nil, DDATABASE)
	Local cCategCV		:= fCatTrabEFD("TCV")
	Local cCateg		:= cCategCV + "|" + fCatTrabEFD("TSV") //'101*102*103*104*105*106*111*301*302*303*306*307*309'+'201*202*305*308*401*410*701*711*712*721*722*723*731*734*738*741*751*761*771*781*901*902*903'
	Local cAliasProc	:= NIL
	Local cAliasRJB		:= NIL
	Local cCPF			:= ""
	Local cStatus		:= ""
	Local cVersEnvio	:= ""
	Local cVersGPE		:= ""
	Local cSelect		:= ""
	Local cQueryRJB		:= ""
	LOCAL LNew			:= .F.
	LOCAL aErros		:= {}
	LOCAL nCont			:= 0
	LOCAL cMsgLog		:= ''
	Local lRet 			:= .F.
	Local lExecutou		:= .F.
	Local lFinaliza		:= .T.
	Local nTamFil		:= 0

	Local lAdmPubl	 	:= .F.
	Local aInfoC	 	:= {}
	Local lNewSeek		:= .F.

	default aParam	:= {}

	If FindFunction("fVersEsoc")
		fVersEsoc( "S2206", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE)
	EndIf

	Begin Sequence

		nTamFil := LEN(ALLTRIM(xFilial("RCE")))

		cQueryRJB := "SELECT SRA.RA_CIC, SRA.R_E_C_N_O_ RARECNO, RJB.R_E_C_N_O_ RJBRECNO, RJB.RJB_CODIGO RJBCODIGO FROM " + RetSqlName("SRA") + " SRA "
		cQueryRJB += "INNER JOIN " + RetSqlName("RJB") + " RJB "
		cQueryRJB += "ON RJB.RJB_FCHAVE = '" + xFilial("RCE") + "' AND RTRIM(RJB.RJB_CHAVE) = RTRIM(SRA.RA_SINDICA) "
		cQueryRJB += "WHERE Substring(SRA.RA_FILIAL, 1, "+ cValToChar(Len(AllTrim(xFilial("RCE")))) +") = '" + AllTrim(xFilial("RCE")) + "' AND RJB.RJB_TIPO = '1' "
		cQueryRJB += "AND SRA.D_E_L_E_T_ = ' ' AND RJB.D_E_L_E_T_ = ' ' "
		cQueryRJB += "AND RJB.RJB_STATUS = '0' "
		cQueryRJB += "AND SRA.RA_ADMISSA < RJB.RJB_DTINC "

		cQueryRJB := ChangeQuery(cQueryRJB)

		cAliasRJB := GetNextAlias()

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQueryRJB), cAliasRJB, .T.,.F.)

		RJC->(DBSETORDER(1))
		SRA->(DBSETORDER(1))
		While (cAliasRJB)->(!Eof())

			lNewSeek := .F.

			SRA->(DBGoto((cAliasRJB)->RARECNO))
			RJB->(DBGoto((cAliasRJB)->RJBRECNO))

			IF SRA->RA_SITFOLH <> "D"
				// Verifica se será Inclusão ou atualização
				//RJC_FILIAL, RJC_CODRJB, RJC_FCHAVE, RJC_CHAVE, R_E_C_N_O_, D_E_L_E_T_
				LNew := !RJC->(DBSEEK(RJB->(RJB_FILIAL + RJB_CODIGO) + SRA->(RA_FILIAL + RA_MAT)))

				//Caso encontre o registro com chave antiga (RJC_CHAVE somente com matrícula) e não está processado com sucesso, deleta.
				If !LNew .And. RJC->RJC_STATUS <> "1"
					RecLock("RJC", .F.)
					dbDelete()
					MsUnLock()
					lNewSeek := .T.
				EndIf

				// Verifica se será Inclusão ou atualização utilizando a nova chave
				//RJC_FILIAL, RJC_CODRJB, RJC_FCHAVE, RJC_CHAVE, R_E_C_N_O_, D_E_L_E_T_
				If lNewSeek .Or. RJC->RJC_STATUS <> "1"
					LNew := !RJC->(DBSEEK(RJB->(RJB_FILIAL + RJB_CODIGO) + SRA->(RA_FILIAL + RA_FILIAL + RA_MAT)))
				EndIf

                IF !RJC->RJC_STATUS == "1"

					//CHECAGEM SE É VIA SCHEDULE, APRESENTANDO A MENSAG EM DE REGISTRO SENDO PROCESSADO
					if Len(aParam) > 0
						// "Processando " #	 "Nome: "			 "Matricula: "					 " Filial: "
						MSGINFO( STR0052 + " " + STR0010 + ": " +SRA->RA_NOME + " " + STR0009 + ": "+ SRA->RA_MAT + STR0051 + SRA->RA_FILIAL , STR0001)
					endIf

				    RECLOCK("RJC", LNew)
                    RJC->RJC_FILIAL := RJB->RJB_FILIAL
                    RJC->RJC_CODRJB	:= RJB->RJB_CODIGO
                    RJC->RJC_STATUS	:= "0"
                    RJC->RJC_FCHAVE := SRA->RA_FILIAL
					RJC->RJC_CHAVE	:= SRA->RA_FILIAL + SRA->RA_MAT
                    RJC->RJC_DTINC	:= DDATABASE
                    RJC->(MsUnlock())
                ENDIF

			ENDIF
			(cAliasRJB)->(DBSkip())
		EndDo

		(cAliasRJB)->(dbGoTop())

		cSelect := "SELECT RJC.R_E_C_N_O_ RJCRECNO, RJC.RJC_FCHAVE, RJC.RJC_CHAVE FROM " + RetSqlName("RJC") + " RJC "
		cSelect += "WHERE RJC.RJC_FCHAVE = '" + xFilial("SRA") + " ' AND RJC.RJC_CODRJB = '" + (cAliasRJB)->RJBCODIGO + "' AND  RJC.D_E_L_E_T_ = ' ' "
		cSelect += "AND RJC.RJC_STATUS <> '1' "

		cSelect := ChangeQuery(cSelect)

		cAliasProc := GetNextAlias()

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cSelect ), cAliasProc, .T.,.F. )

		While (cAliasProc)->(!Eof())
			lRet := .F.
			lExecutou := .F.
			lFinaliza := .T.
			RJC->(DBGoto((cAliasProc)->RJCRECNO))

			IF SRA->(DBSEEK(Alltrim((cAliasProc)->RJC_CHAVE)))
				lExecutou := .T.
				//VALIDA CATEGORIA DO FUNCIONÁRIO
				If !Empty(SRA->RA_CATEFD) .And. (SRA->RA_CATEFD $ cCateg )
					If SRA->RA_CATEFD $ cCategCV
						cCPF	:= AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC)
						//VERIFICA SE FUNCIONÁRIO JÁ FOI INTEGRADO

    					If  !lMiddleware
	    					//VERIFICA SE FUNCIONÁRIO JÁ FOI INTEGRADO
	    					cStatus := TAFGetStat( "S-2200", cCPF )//ADMISSAO POR CADASTRO
		    			Else
		    				cStatus := "-1"
							fPosFil( cEmpAnt, SRA->RA_FILIAL )
							aInfoC   := fXMLInfos()
							If LEN(aInfoC) >= 4
								cTpInsc  := aInfoC[1]
								lAdmPubl := aInfoC[4]
								cNrInsc  := aInfoC[2]
							Else
								cTpInsc  := ""
								lAdmPubl := .F.
								cNrInsc  := "0"
							EndIf
							cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
							cStatus 	:= "-1"
							//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
							GetInfRJE( 2, cChaveMid, @cStatus )
		    			Endif
					Else
						If !lMiddleware
							cCPF    := AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + dToS( SRA->RA_ADMISSA )
							//VERIFICA SE FUNCIONÁRIO JÁ FOI INTEGRADO
							cStatus := TAFGetStat( "S-2300", cCPF )
						Else
							cCPF 	:= AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA )
							fPosFil( cEmpAnt, SRA->RA_FILIAL )
							aInfoC   := fXMLInfos()
							If LEN(aInfoC) >= 4
								cTpInsc  := aInfoC[1]
								lAdmPubl := aInfoC[4]
								cNrInsc  := aInfoC[2]
							Else
								cTpInsc  := ""
								lAdmPubl := .F.
								cNrInsc  := "0"
							EndIf
							cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cCPF, 40, " ")
							cStatus 	:= "-1"
							//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
							GetInfRJE( 2, cChaveMid, @cStatus )
						EndIf
					EndIf

					If (cStatus  == "4" )
						aErros := {}

						RegToMemory("SRA",.F.,.T.,.F.)
						lRet := fInt2206("SRA",/*lAltCad*/,3,"S2206",/*cTFilial*/,/*dtEf*/,/*cTurno*/,/*cRegra*/,/*cSeqT*/,/*oModel*/,cVersEnvio, /*oMdlRS9*/, /*dDtAlt*/, /*lTransf*/, /*cCTT2206*/, aErros, /*lMsgHlp*/, /*lDataAlt*/)

						if Len(aParam) > 0 .And. lRet
							// "Funcionário: " #	 "Nome: "					 "Matricula: "					" Filial: "						"Processado com Sucesso"
							MSGINFO( STR0035 + ":" + STR0010+": "+SRA->RA_NOME + " "+STR0009+": "+ SRA->RA_MAT + STR0051 + SRA->RA_FILIAL + " " +STR0049 , STR0001)
						EndIf

						RecLock("RJC", .F.)

						IF lRet
							RJC->RJC_STATUS := "1"
							RJC->RJC_DTJOB	:= DDATABASE
							RJC->RJC_ERR	:= "Gerado no TAF"
						Else
							cMsgLog := ''
							If Len(aErros) > 0
								For nCont:= 1 to len(aErros)
									cMsgLog += CRLF + aErros[nCont]
								Next nCont
							ENDIF

							RJC->RJC_STATUS := "2"
							RJC->RJC_DTJOB	:= DDATABASE
							RJC->RJC_ERR	:= cMsgLog
                            lFinaliza := .F.
						ENDIF

						RJC->(MsUnlock())
					Else
						if Len(aParam) > 0
							RecLock("RJC", .F.)
								RJC->RJC_STATUS := "2"
								RJC->RJC_DTJOB	:= DDATABASE
								RJC->RJC_ERR	:= STR0087
							RJC->(MsUnlock())
						endif
                        lFinaliza := .F.
					EndIf
				EndIf
			ENDIF
			(cAliasProc)->(DBSKIP())
		EndDo
	    (cAliasProc)->(DbCloseArea())
		(cAliasRJB)->(DbCloseArea())

        IF lExecutou .AND. lFinaliza
			// Só atualiza a tabela RJB se não houver registros pendentes na RJC
			If !fTemRJC(RJC->RJC_FILIAL,RJC->RJC_CODRJB)
				RECLOCK("RJB", .F.)
				RJB->RJB_STATUS	:= "1"
				RJB->(MsUnlock())
			EndIf
		ENDIF
    End Sequence
return .T.



/*/{Protheus.doc} IntLocConv
Rotina responsável pela leitura e processamento das alterações dos locais de convocação.
@type function
@author Claudinei Soares
@since 30/05/19
@version 1.0
@param aParam, array, Parametros enviados pelo Schedule
/*/
Static function IntLocConv(aParam)

	Local cCateg		:= "106"
	Local cAliasProc	:= NIL
	Local cAliasRJB		:= NIL
	Local cCPF			:= ""
	Local cStatus		:= ""
	Local cVersEnvio	:= ""
	Local cSelect		:= ""
	Local cQueryRJB		:= ""
	LOCAL LNew			:= .F.
	LOCAL aErros		:= {}
	LOCAL nCont			:= 0
	LOCAL cMsgLog		:= ''
	Local cFilRBW		:= ''
	Local lRet			:= .F.
	Local lExecutou		:= .F.
	Local lFinaliza		:= .T.
	Local nTamFil		:= 0

	Local lAdmPubl	 	:= .F.
	Local aInfoC	 	:= {}

	default aParam	:= {}

	If FindFunction("fVersEsoc")
		fVersEsoc( "S2206", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio)
	EndIf

	Begin Sequence

		nTamFil := LEN(ALLTRIM(xFilial("SV6")))

		cFilRBW := If(nTamFil == 0, xFilial("SV6"), xFilial("RBW"))

		cQueryRJB := "SELECT SRA.RA_CIC, SRA.R_E_C_N_O_ RARECNO, RJB.R_E_C_N_O_ RJBRECNO, RJB.RJB_CODIGO RJBCODIGO FROM " + RetSqlName("SRA") + " SRA "
		cQueryRJB += "INNER JOIN " + RetSqlName("RBW") + " RBW "
		cQueryRJB += "ON SRA.RA_FILIAL = '" + xFilial("RBW") + "' AND SRA.RA_MAT = RBW.RBW_MAT "
		cQueryRJB += "INNER JOIN " + RetSqlName("RJB") + " RJB "
		cQueryRJB += "ON RJB.RJB_FCHAVE = '" + cFilRBW + "' AND RTRIM(RJB.RJB_CHAVE) = RTRIM(RBW.RBW_LOCT) "
		cQueryRJB += "WHERE SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND RJB.RJB_TIPO = '2' AND SRA.D_E_L_E_T_ = ' ' AND RJB.D_E_L_E_T_ = ' ' "
		cQueryRJB += "AND RJB.RJB_STATUS = '0' "
		cQueryRJB += "AND SRA.RA_ADMISSA < RJB.RJB_DTINC "

		cQueryRJB := ChangeQuery(cQueryRJB)

		cAliasRJB := GetNextAlias()

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQueryRJB), cAliasRJB, .T.,.F.)

		RJC->(DBSETORDER(1))
		SRA->(DBSETORDER(1))
		While (cAliasRJB)->(!Eof())

			SRA->(DBGoto((cAliasRJB)->RARECNO))
			RJB->(DBGoto((cAliasRJB)->RJBRECNO))

			IF SRA->RA_SITFOLH <> "D"
				// Verifica se será Inclusão ou atualização
				//RJC_FILIAL, RJC_CODRJB, RJC_FCHAVE, RJC_CHAVE, R_E_C_N_O_, D_E_L_E_T_
				LNew := !RJC->(DBSEEK(RJB->(RJB_FILIAL + RJB_CODIGO) + SRA->(RA_FILIAL + RA_MAT)))

                IF !RJC->RJC_STATUS == "1"
					//CHECAGEM SE É VIA SCHEDULE, APRESENTANDO A MENSAG EM DE REGISTRO SENDO PROCESSADO
					if Len(aParam) > 0
						// "Processando " #	 "Nome: "			 "Matricula: "					 " Filial: "
						CONOUT( STR0052 + " " + STR0010 + ": " +SRA->RA_NOME + " " + STR0009 + ": "+ SRA->RA_MAT + STR0051 + SRA->RA_FILIAL , STR0001)
					endIf

				    RECLOCK("RJC", LNew)
                    RJC->RJC_FILIAL := RJB->RJB_FILIAL
                    RJC->RJC_CODRJB	:= RJB->RJB_CODIGO
                    RJC->RJC_STATUS	:= "0"
                    RJC->RJC_FCHAVE := SRA->RA_FILIAL
					RJC->RJC_CHAVE	:= SRA->RA_MAT
                    RJC->RJC_DTINC	:= DDATABASE
                    RJC->(MsUnlock())
                ENDIF

			ENDIF
			(cAliasRJB)->(DBSkip())
		EndDo

		(cAliasRJB)->(dbGoTop())

		cSelect := "SELECT RJC.R_E_C_N_O_ RJCRECNO, RJC.RJC_FCHAVE, RJC.RJC_CHAVE FROM " + RetSqlName("RJC") + " RJC "
		cSelect += "WHERE RJC.RJC_FCHAVE = '" + xFilial("SRA") + " ' AND RJC.RJC_CODRJB = '" + (cAliasRJB)->RJBCODIGO + "' AND  RJC.D_E_L_E_T_ = ' ' "
		cSelect += "AND RJC.RJC_STATUS <> '1' "

		cSelect := ChangeQuery(cSelect)

		cAliasProc := GetNextAlias()

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cSelect ), cAliasProc, .T.,.F. )

		While (cAliasProc)->(!Eof())
			lRet := .F.
			lExecutou := .F.
			lFinaliza := .T.
			RJC->(DBGoto((cAliasProc)->RJCRECNO))

			IF SRA->(DBSEEK((cAliasProc)->RJC_FCHAVE + Alltrim((cAliasProc)->RJC_CHAVE)))
				lExecutou := .T.
				//VALIDA CATEGORIA DO FUNCIONÁRIO
				If !Empty(SRA->RA_CATEFD) .And. (SRA->RA_CATEFD $ cCateg )
					If SRA->RA_CATEFD $ cCateg
						cCPF	:= AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC)

    					If  !lMiddleware
    						//VERIFICA SE FUNCIONÁRIO JÁ FOI INTEGRADO
    						cStatus := TAFGetStat( "S-2200", cCPF )//ADMISSAO POR CADASTRO
		    			Else
		    				cStatus := "-1"
							fPosFil( cEmpAnt, SRA->RA_FILIAL )
							aInfoC   := fXMLInfos()
							If LEN(aInfoC) >= 4
								cTpInsc  := aInfoC[1]
								lAdmPubl := aInfoC[4]
								cNrInsc  := aInfoC[2]
							Else
								cTpInsc  := ""
								lAdmPubl := .F.
								cNrInsc  := "0"
							EndIf
							cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
							cStatus 	:= "-1"
							//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
							GetInfRJE( 2, cChaveMid, @cStatus )
		    			Endif
					EndIf

					If (cStatus  == "4" ) .Or. Empty(cStatus)
						aErros := {}

						RegToMemory("SRA",.F.,.T.,.F.)
						If cStatus == "4"
							lRet := fInt2206("SRA",/*lAltCad*/,3,"S2206",/*cTFilial*/,/*dtEf*/,/*cTurno*/,/*cRegra*/,/*cSeqT*/,/*oModel*/,cVersEnvio, /*oMdlRS9*/, /*dDtAlt*/, /*lTransf*/, /*cCTT2206*/, aErros, /*lMsgHlp*/, /*lDataAlt*/)
						Else
							lRet := fIntAdmiss("SRA",/*lAltCad*/,3,"S2200",/*cTFilial*/,/*aDep*/,/*cCodUn*/,/*oModel*/,/*cOrigem*/, aErros, cVersEnvio)
						Endif

						if Len(aParam) > 0
							// "Funcionário: " #	 "Nome: "					 "Matricula: "					" Filial: "						"Processado com Sucesso"
							CONOUT( STR0035 + ":" + STR0010+": "+SRA->RA_NOME + " "+STR0009+": "+ SRA->RA_MAT + STR0051 + SRA->RA_FILIAL + " " +STR0049 , STR0001)
						EndIf

						RecLock("RJC", .F.)

						IF lRet
							RJC->RJC_STATUS := "1"
							RJC->RJC_DTJOB	:= DDATABASE
							RJC->RJC_ERR	:= "Gerado no TAF"
						Else
							cMsgLog := ''
							If Len(aErros) > 0
								For nCont:= 1 to len(aErros)
									cMsgLog += CRLF + aErros[nCont]
								Next nCont
							ENDIF

							RJC->RJC_STATUS := "2"
							RJC->RJC_DTJOB	:= DDATABASE
							RJC->RJC_ERR	:= cMsgLog
                            lFinaliza := .F.
						ENDIF

						RJC->(MsUnlock())
					Else
						if Len(aParam) > 0
							RecLock("RJC", .F.)
								RJC->RJC_STATUS := "2"
								RJC->RJC_DTJOB	:= DDATABASE
								RJC->RJC_ERR	:= STR0087
							RJC->(MsUnlock())
						endif
                        lFinaliza := .F.
					EndIf
				EndIf
			ENDIF
			(cAliasProc)->(DBSKIP())
		EndDo
	    (cAliasProc)->(DbCloseArea())
		(cAliasRJB)->(DbCloseArea())
    End Sequence
return .T.

/*/{Protheus.doc} IntAltDep
Rotina responsável pela leitura e processamento das alterações de dependentes
@type function
@author lidio.oliveira
@since 20/02/2020
@version 1.0
@param aParam, array, Parametros enviados pelo Schedule
/*/
Static function IntAltDep(aParam)

	Local cCategCV		:= fCatTrabEFD("TCV")
	Local cCateg		:= cCategCV + "|" + fCatTrabEFD("TSV") //'101*102*103*104*105*106*111*301*302*303*306*307*309'+'201*202*305*308*401*410*701*711*712*721*722*723*731*734*738*741*751*761*771*781*901*902*903'
	Local cAliasProc	:= NIL
	Local cAliasRJB		:= NIL
	Local cCPF			:= ""
	Local cStatus		:= ""
	Local cVersEnvio	:= ""
	Local cVersGPE		:= ""
	Local cSelect		:= ""
	Local cQueryRJB		:= ""
	Local LNew			:= .F.
	Local aErros		:= {}
	Local nCont			:= 0
	Local cMsgLog		:= ''
	Local lRet 			:= .F.
	Local lExecutou		:= .F.
	Local lFinaliza		:= .T.

	Local lAdmPubl	 	:= .F.
	Local aInfoC	 	:= {}

	default aParam	:= {}

	DbSelectArea("SRB")
	SRB->(dbSetOrder(1))

	If FindFunction("fVersEsoc")
		fVersEsoc( "S2205", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE)
	EndIf

	Begin Sequence

		cQueryRJB := "SELECT SRA.RA_CIC, SRA.R_E_C_N_O_ RARECNO, RJB.R_E_C_N_O_ RJBRECNO, RJB.RJB_CODIGO RJBCODIGO FROM " + RetSqlName("SRA") + " SRA "
		cQueryRJB += "INNER JOIN " + RetSqlName("RJB") + " RJB "
		cQueryRJB += "ON RJB.RJB_FCHAVE = '" + xFilial("SRB") + "' AND RTRIM(RJB.RJB_CHAVE) = RTRIM(SRA.RA_MAT) "
		cQueryRJB += "WHERE SRA.RA_FILIAL = '" + xFilial("SRB") + "' AND RJB.RJB_TIPO = '3' AND SRA.D_E_L_E_T_ = ' ' AND RJB.D_E_L_E_T_ = ' ' "
		cQueryRJB += "AND RJB.RJB_STATUS = '0' "
		cQueryRJB += "AND SRA.RA_ADMISSA < RJB.RJB_DTINC "

		cQueryRJB := ChangeQuery(cQueryRJB)

		cAliasRJB := GetNextAlias()

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQueryRJB), cAliasRJB, .T.,.F.)

		RJC->(DBSETORDER(1))
		SRA->(DBSETORDER(1))
		While (cAliasRJB)->(!Eof())

			SRA->(DBGoto((cAliasRJB)->RARECNO))
			RJB->(DBGoto((cAliasRJB)->RJBRECNO))

			IF SRA->RA_SITFOLH <> "D"
				// Verifica se será Inclusão ou atualização
				//RJC_FILIAL, RJC_CODRJB, RJC_FCHAVE, RJC_CHAVE, R_E_C_N_O_, D_E_L_E_T_
				LNew := !RJC->(DBSEEK(RJB->(RJB_FILIAL + RJB_CODIGO) + SRA->(RA_FILIAL + RA_MAT)))

                IF !RJC->RJC_STATUS == "1"

					//CHECAGEM SE É VIA SCHEDULE, APRESENTANDO A MENSAG EM DE REGISTRO SENDO PROCESSADO
					if Len(aParam) > 0
						// "Processando " #	 "Nome: "			 "Matricula: "					 " Filial: "
						MSGINFO( STR0052 + " " + STR0010 + ": " +SRA->RA_NOME + " " + STR0009 + ": "+ SRA->RA_MAT + STR0051 + SRA->RA_FILIAL , STR0001)
					endIf

				    RECLOCK("RJC", LNew)
                    RJC->RJC_FILIAL := RJB->RJB_FILIAL
                    RJC->RJC_CODRJB	:= RJB->RJB_CODIGO
                    RJC->RJC_STATUS	:= "0"
                    RJC->RJC_FCHAVE := SRA->RA_FILIAL
					RJC->RJC_CHAVE	:= SRA->RA_MAT
                    RJC->RJC_DTINC	:= DDATABASE
                    RJC->(MsUnlock())
                ENDIF

			ENDIF
			(cAliasRJB)->(DBSkip())
		EndDo

		(cAliasRJB)->(dbGoTop())
		While (cAliasRJB)->(!Eof())

			RJB->(DBGoto((cAliasRJB)->RJBRECNO))

			cSelect := "SELECT RJC.R_E_C_N_O_ RJCRECNO, RJC.RJC_FCHAVE, RJC.RJC_CHAVE FROM " + RetSqlName("RJC") + " RJC "
			cSelect += "WHERE RJC.RJC_FCHAVE = '" + xFilial("SRA") + " ' AND RJC.RJC_CODRJB = '" + (cAliasRJB)->RJBCODIGO + "' AND  RJC.D_E_L_E_T_ = ' ' "
			cSelect += "AND RJC.RJC_STATUS <> '1' "

			cSelect := ChangeQuery(cSelect)

			cAliasProc := GetNextAlias()

			dbUseArea(.T., "TOPCONN", TcGenQry(,, cSelect ), cAliasProc, .T.,.F. )

			While (cAliasProc)->(!Eof())
				lRet := .F.
				lExecutou := .F.
				lFinaliza := .T.
				RJC->(DBGoto((cAliasProc)->RJCRECNO))

				IF SRA->(DBSEEK((cAliasProc)->RJC_FCHAVE + Alltrim((cAliasProc)->RJC_CHAVE)))
					lExecutou := .T.
					//VALIDA CATEGORIA DO FUNCIONÁRIO
					If !Empty(SRA->RA_CATEFD) .And. (SRA->RA_CATEFD $ cCateg )
						If SRA->RA_CATEFD $ cCategCV
							cCPF	:= AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC)
							//VERIFICA SE FUNCIONÁRIO JÁ FOI INTEGRADO

							If  !lMiddleware
								//VERIFICA SE FUNCIONÁRIO JÁ FOI INTEGRADO
								cStatus := TAFGetStat( "S-2200", cCPF )//ADMISSAO POR CADASTRO
							Else
								cStatus := "-1"
								fPosFil( cEmpAnt, SRA->RA_FILIAL )
								aInfoC   := fXMLInfos()
								If LEN(aInfoC) >= 4
									cTpInsc  := aInfoC[1]
									lAdmPubl := aInfoC[4]
									cNrInsc  := aInfoC[2]
								Else
									cTpInsc  := ""
									lAdmPubl := .F.
									cNrInsc  := "0"
								EndIf
								cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
								cStatus 	:= "-1"
								//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
								GetInfRJE( 2, cChaveMid, @cStatus )
							Endif
						Else
							If !lMiddleware
								cCPF    := AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + dToS( SRA->RA_ADMISSA )
								//VERIFICA SE FUNCIONÁRIO JÁ FOI INTEGRADO
								cStatus := TAFGetStat( "S-2300", cCPF )
							Else
								cCPF 	:= AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA )
								fPosFil( cEmpAnt, SRA->RA_FILIAL )
								aInfoC   := fXMLInfos()
								If LEN(aInfoC) >= 4
									cTpInsc  := aInfoC[1]
									lAdmPubl := aInfoC[4]
									cNrInsc  := aInfoC[2]
								Else
									cTpInsc  := ""
									lAdmPubl := .F.
									cNrInsc  := "0"
								EndIf
								cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cCPF, 40, " ")
								cStatus 	:= "-1"
								//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
								GetInfRJE( 2, cChaveMid, @cStatus )
							EndIf
						EndIf

						If (cStatus  == "4" )
							aErros := {}

							RegToMemory("SRA",.F.,.T.,.F.)
							lRet := fIntAdmiss("SRA",/*lAltCad*/,3,"S2205",/*cTFilial*/,/*aDep*/,/*cCodUnico*/,/*oModel*/,/*cOrigem*/,/*@aErros*/,cVersEnvio)

							RecLock("RJC", .F.)

							IF lRet
								RJC->RJC_STATUS := "1"
								RJC->RJC_DTJOB	:= DDATABASE
								RJC->RJC_ERR	:= If(!lMiddleware, STR0165, STR0166)
								// "Funcionário: " #	 "Nome: "					 "Matricula: "					" Filial: "						"Processado com Sucesso"
								MSGINFO( STR0035 + ":" + STR0010+": "+SRA->RA_NOME + " "+STR0009+": "+ SRA->RA_MAT + STR0051 + SRA->RA_FILIAL + " " +STR0049 , STR0001)
							Else
								cMsgLog := ''
								If Len(aErros) > 0
									For nCont:= 1 to len(aErros)
										cMsgLog += CRLF + aErros[nCont]
									Next nCont
								ENDIF

								RJC->RJC_STATUS := "2"
								RJC->RJC_DTJOB	:= DDATABASE
								RJC->RJC_ERR	:= cMsgLog
								lFinaliza 		:= .F.
								// "Funcionário: " #	 "Nome: "					 "Matricula: "					" Filial: "
								MSGINFO( STR0035 + ":" + STR0010+": "+SRA->RA_NOME + " "+STR0009+": "+ SRA->RA_MAT + STR0051 + SRA->RA_FILIAL + " " + cMsgLog, STR0001)
							ENDIF

							RJC->(MsUnlock())
						Else
							If !lMiddleware
								cMsgLog := STR0087
							Else
								cMsgLog := STR0148
							EndIf
							If Len(aParam) > 0
								RecLock("RJC", .F.)
									RJC->RJC_STATUS := "2"
									RJC->RJC_DTJOB	:= DDATABASE
									RJC->RJC_ERR	:= cMsgLog
								RJC->(MsUnlock())
								// "Funcionário: " #	 "Nome: "					 "Matricula: "					" Filial: "						"Favor verificar o Status do registro do funcionário"
								MSGINFO( STR0035 + ":" + STR0010+": "+SRA->RA_NOME + " "+STR0009+": "+ SRA->RA_MAT + STR0051 + SRA->RA_FILIAL + " " + cMsgLog, STR0001)
							EndIf
							lFinaliza := .F.
						EndIf
					EndIf
				EndIf
				(cAliasProc)->(DBSKIP())
			EndDo
			IF lExecutou .AND. lFinaliza
				RECLOCK("RJB", .F.)
				RJB->RJB_STATUS	:= "1"
				RJB->(MsUnlock())
			ENDIF
			(cAliasProc)->(DbCloseArea())

		(cAliasRJB)->(DBSkip())
		EndDo
		(cAliasRJB)->(DbCloseArea())
    End Sequence
return .T.

/*/{Protheus.doc} IntAltTurno
Rotina responsável pela leitura e processamento das alterações de troca de turno
@type function
@author allyson.mesashi
@since 19/05/2020
@version 1.0
@param dCorte, data, Data de corte
/*/
Static Function IntAltTurno( dCorte )

Local aErros	:= {}
Local cAlias	:= GetNextAlias()
Local cBkpFil	:= cFilAnt
Local cCateg	:= StrTran(fCatTrabEFD("TCV"), "|") //"101|102|103|104|105|106|111|301|302|303|304|306|901" //Trabalhador com vinculo
Local cCPF		:= ""
Local cMsgErro	:= ""
Local cQuery	:= ""
Local cStatus	:= "-1"
Local cVersEnvio:= ""

Local aInfoC	:= {}
Local cChaveMid	:= ""
Local cNrInsc	:= ""
Local cTpInsc	:= ""
Local lAdmPubl	:= .F.

If FindFunction("fVersEsoc")
	fVersEsoc( "S2206", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio )
EndIf

cQuery := "SELECT SPF.R_E_C_N_O_ AS RECNO "
cQuery += "FROM " + RetSqlName('SPF') + " SPF "
cQuery += "INNER JOIN " + RetSqlName('SRA') + " SRA ON SRA.RA_FILIAL = SPF.PF_FILIAL AND SRA.RA_MAT = SPF.PF_MAT "
cQuery += "WHERE SPF.PF_DATA >= '" + dToS( dCorte ) + "' AND "
cQuery += "SPF.PF_DATA <= '" + dToS( dDatabase ) + "' AND "
cQuery += "SPF.PF_INTGTAF = '" + Space(8) + "' AND "
cQuery += "SRA.RA_CATEFD IN (" + fSQLIn( cCateg, 3 )  +  ") AND "
cQuery += "SPF.D_E_L_E_T_ = ' ' AND "
cQuery += "SRA.D_E_L_E_T_ = ' '"
cQuery += "ORDER BY SPF.PF_FILIAL, SPF.PF_MAT, SPF.PF_DATA"
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

While (cAlias)->( !Eof() )
	SPF->( dbGoTo( (cAlias)->RECNO ) )
	SRA->( dbSetOrder(1) )
    SRA->( dbSeek( SPF->PF_FILIAL + SPF->PF_MAT ) )
	aErros	:= {}
	cStatus := "-1"
	cFilAnt	:= SRA->RA_FILIAL

	If (SPF->PF_TURNODE == SPF->PF_TURNOPA .And. SPF->PF_REGRADE == SPF->PF_REGRAPA .And. SPF->PF_SEQUEDE <> SPF->PF_SEQUEPA ) .OR.;
		(SPF->PF_TURNODE == SPF->PF_TURNOPA .And. SPF->PF_REGRADE == SPF->PF_REGRAPA .And. SPF->PF_SEQUEDE == SPF->PF_SEQUEPA )
		(cAlias)->( dbSkip() )
		Loop
	Endif

	If !lMiddleware
		cCPF 	:= AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC)
		cStatus := TAFGetStat( "S-2200", cCPF )
	Else
		fPosFil( cEmpAnt, SRA->RA_FILIAL )
		aInfoC   := fXMLInfos()
		If Len(aInfoC) >= 4
			cTpInsc  := aInfoC[1]
			lAdmPubl := aInfoC[4]
			cNrInsc  := aInfoC[2]
		Else
			cTpInsc  := ""
			lAdmPubl := .F.
			cNrInsc  := "0"
		EndIf
		cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, fTamRJEKey(), " ")
		//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
		GetInfRJE( 2, cChaveMid, @cStatus )
	EndIf

	If cStatus == "4"
		RegToMemory("SRA",.F.,.T.,.F.)
		cTafKey := Substr(FWUUId(SRA->RA_FILIAL + SRA->RA_MAT + dToS(SPF->PF_DATA)), 1, 60)
		If fInt2206("SRA",, 3,"S2206",,,SPF->PF_TURNOPA,SPF->PF_REGRAPA,SPF->PF_SEQUEPA,,cVersEnvio,,SPF->PF_DATA,,,@aErros, .F., .T., Nil, Nil, Nil, Nil, cTafKey)
			// "Funcionário: " #	 "Nome: "					 "Matricula: "					" Filial: "						"Processado com Sucesso"
			MsgInfo( STR0035 + ":" + STR0010+": "+SRA->RA_NOME + " "+STR0009+": "+ SRA->RA_MAT + STR0051 + SRA->RA_FILIAL + " " +STR0049 , STR0001)
			If RecLock("SPF",.F.)
				SPF->PF_INTGTAF	:= dDatabase
				SPF->PF_TAFKEY	:= cTafKey
				MsUnLock()
			EndIf
		Else
			// "Funcionário: " #	 "Nome: "					 "Matricula: "					" Filial: "						" não enviado(a) ao TAF. Erro: "##" não enviado(a) ao Middleware. Erro: "
			MsgInfo( STR0035 + ":" + STR0010+": "+SRA->RA_NOME + " "+STR0009+": "+ SRA->RA_MAT + STR0051 + SRA->RA_FILIAL + " " + Iif( !lMiddleware, STR0036, STR0137), STR0001)
			If Len( aErros ) > 0
				If !lMiddleware
					FeSoc2Err( aErros[1], @cMsgErro , Iif( aErros[1] != '000026',1,2 ) )
					FrmTexto(@cMsgErro)
					MsgInfo(cMsgErro)
				Else
					MsgInfo(aErros[1])
				EndIf
			EndIf
		EndIf
	Else
		If !lMiddleware
			MsgInfo( STR0087, STR0001)//"Favor verificar o Status do registro do funcionário no TAF, pois o mesmo não se encontra enviado para o TAF ou possui algum problema no mesmo antes de enviar esta solicitação."
		Else
			MsgInfo( STR0139, STR0001)//"Favor verificar o Status do registro do funcionário, pois o mesmo não se encontra enviado para o Middleware ou possui algum problema no mesmo antes de enviar esta solicitação."
		Endif
	EndIf

	(cAlias)->( dbSkip() )
EndDo

(cAlias)->( dbCloseArea() )
cFilAnt	:= cBkpFil

Return

/*/{Protheus.doc} fTemRJC
Pesquisa se há registro na tabela RJC sem processamento
@type      	Static Function
@author lidio.oliveira
@since 19/02/2021
@version	1.0
@return lRet
/*/
Static Function fTemRJC(cFilRJC,cCodigo)

	Local aArea   	:= GetArea()
	Local lRet		:= .F.
	Local cQuery	:= ""
	Local cAliasRJC	:= ""

	Default cFilRJC	:= ""
	Default cCodigo	:= ""

	If !Empty(cFilRJC) .And. !Empty(cCodigo)
		cQuery := "SELECT RJC_FILIAL, RJC_CODRJB, RJC_CHAVE, RJC_STATUS FROM " + RetSqlName("RJC")
		cQuery += "WHERE RJC_FILIAL = '" + cFilRJC + "' "
		cQuery += "AND RJC_CODRJB = '" + cCodigo + "' "
		cQuery += "AND RJC_STATUS <> '1' "
		cQuery += "AND D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery(cQuery)

		cAliasRJC := GetNextAlias()

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasRJC, .T.,.F.)

		If (cAliasRJC)->(!Eof())
			lRet	:= .T.
		EndIf

		(cAliasRJC)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} IntEnvCes
Função responsável pela montagem XML e envio das informações via função do TAF
@type function
@author Silvia Taguti
@since 01/08/2022
@version 1.0
/*/
Static Function IntEnvCes(dIni, dFim, dInteg, dCorte, cTipo, lAdmPubl, cTpInsc, cNrInsc, cIdXML, lCpoInt, cInteg, cVersEnvio)

	Local cMsgErro		:= ""
	Local cXml			:= ""
	Local cFilEnv	 	:= ""
	Local cCateg		:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|304|306|901" //Trabalhador com vinculo
	Local nEnvS2231	:= 0

	Local lAltDtIni		:= .F.
	Local lAltDtFim		:= .F.
	Local lContinua		:= .T.
	Local lRet			:= .T.

	Local dDcgIni      :=  SuperGetMV("MV_DTCGINI",nil,CTOD(" / / ") )

	Local aAreaSRA		:= SRA->(GetArea())
	Local aAreaSR8		:= SR8->(GetArea())
	Local aFilInTaf 	:= {}
	Local aArrayFil 	:= {}
	Local aErros		:= {}

	LOCAL cTicket 		:= ''
	LOCAL cTafKey		:= ''

	LOCAL LTAFINI		:= .F.

	Default  dIni		:= CtoD ("//")
	Default  dFim		:= CtoD ("//")
	Default  dInteg		:= CtoD ("//")
	Default  dCorte		:= CtoD ("//")
	Default  cTipo		:= "000"
	Default  lAdmPubl	:= .F.
	Default  cTpInsc	:= ""
	Default  cNrInsc	:= ""
	Default  cIdXML		:= ""
	Default  lCpoInt	:= .F.
	Default  cInteg		:= ""
	Default  cVersEnvio	:= ""

	//Regra para envio do XML do evento S-2231 via JOB
	//nEnvS2231 	-> 0-Não envia o XML
	//			 	-> 1-Envia tag de inicio
	//				-> 2-Envia tag de fim
	//				-> 3-Envia as 2 tags (inicio e fim do afastamento)

	If !Empty(dIni) .And. !Empty(dDcgIni) .And. dDcgIni <= dIni
		If !Empty(dFim)
			nEnvS2231 := 2
		Endif
	Endif

	If (lIntegTAF .Or. lMiddleware) .And. nEnvS2231 <> 0
		If !lMiddleware
			fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
		EndIf

		//Efetua a integracao com TAF
		If !Empty(cFilEnv) .AND. lContinua
			cXml := ""
			If !lMiddleware
				cXml +='<eSocial>'
				cXml +='<evtCessao>'
			EndIf
			cXml +='<ideVinculo>'
			cXml +='<cpfTrab>'+SRA->RA_CIC+'</cpfTrab>'

			cXml +='<matricula>'+SRA->RA_CODUNIC+'</matricula>'

			cXml +='</ideVinculo>'

			cXml +='<infoCessao>'

			If nEnvS2231 == 2 
				lAltDtFim := .T.
				cXml +='<fimCessao>'
					cXml +='<dtTermCessao>'+dtos(SR8->R8_DATAFIM)+'</dtTermCessao>'
				cXml +='</fimCessao>'
			Endif	
			cXml +='</infoCessao>'

			cXml +='</evtCessao>'
			cXml +='</eSocial>'
		EndIf
	EndIf

	if !empty(SR8->R8_TAFKI)
	 	LTAFINI	:= .T.
	Endif

	IF lTafKeys
		RecLock("SR8",.F.)
		cTafKey :=  fTafKAfast(SR8->R8_FILIAL,SR8->R8_MAT,SR8->R8_SEQ)

		If !lAltDtIni .AND. lAltDtFim
			cTicket 		:= ''
			SR8->R8_TAFKF 	:= cTafKey
			cPredeces    	:= SR8->R8_TAFKI
		EndIf
		SR8->(MsUnlock())
	ENDIF

	If !Empty(cXml) .And. lContinua
		//Realiza geração de XML na System
		GrvTxtArq(alltrim(cXml), "S2231", SRA->RA_CIC)
		aErros := {}
		//O TAF fará a gravação da TAFST2 e TAFXERP somente se o quinto elemento do parâmetro for passado como "3"

		If !lMiddleware
			If lTafKeys .AND. !EMPTY(SR8->R8_TAFKI)
				aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S2231", )
			EndIf
			if 	Len(aErros)> 0
				FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
				Conout(cMsgErro)
				lRet:= IIF(aErros[1]!='000026',.F.,.T.)
			EndIf
		EndIf
	EndIf

	IF !lRet
		RecLock("SR8",.F.)
			SR8->R8_TAFKF := ''
		SR8->(MsUnlock())

	EndIf

	RestArea(aAreaSRA)
	RestArea(aAreaSR8)

Return lRet
