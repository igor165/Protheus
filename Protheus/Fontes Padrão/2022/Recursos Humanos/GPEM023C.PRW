#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM023.CH"

Static nOrdemMult	:= 0

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPEM023C ³ Autor ³ Marcia Moura                                ³ Data ³ 10/11/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de Envio de Eventos - Cargos e turnos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM023C()                                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista     ³ Data     ³ FNC/Requisito  ³ Chamado ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcia Moura |09/11/2015|                |TTHPT7   |Integracao do registro S-1030 com o TAF    ³±±
±±³Marcia Moura |09/11/2015|                |TTHNKK   |Integracao do registro S-1050 com o TAF    ³±±
±±³Marcia Moura ³18/05/2016|                |TVEJZM   |Adaptacao leiaute 2.2                      ³±±
±±|Marcia Moura |27/09/2016|                |TVUUFA   |Melhoria para gerar registro de horario TAF³±±
±±³Marcos Cout  ³02/05/2017|DRHESOCP-214              | Ajustes para layout do eSocial 2.2.01     ³±±
±±³Marcia Moura ³02/06/2017³DRHESOCP-316              ³Pacote para Atendimento                    ³±±
±±³Marcos Cout  ³12/06/2017³DRHESOCP-389              ³War Room + Merge                           ³±±
±±³             ³          ³                          ³Subir fontes para release superior (17)    ³±±
±±³Marcos Cout  ³04/07/2017³DRHESOCP-543              ³Realizar ajustes para geração de evento    ³±±
±±³             ³          ³                          ³S-1030 Extemporâneo                        ³±±
±±³Marcia Moura ³04/07/2017³DRHESOCP-553              ³Correcao da Relatorio de Inconsistencias e ³±±
±±³             ³          ³                          ³nao estava trazendo o tempo de intervalo   ³±±
±±³Marcia Moura ³07/07/2017³DRHESOCP-567              ³Correcao na geracao de horarios para seq.  ³±±
±±³             ³          ³                          ³com o dom.trabalhado. Gravaremos como dia 8³±±
±±|Claudinei S. |24/07/2017|DRHESOCP-645/DRHESOCP-614 |S-1050 - Ajustada a fCargHorar() p/ buscar |±±
±±|             |          |                          |a filial corretamente.                     |±±
±±³Marcos Cout  ³28/07/2017³DRHESOCP-703              ³Realizar ajustes estéticos e padronizados  ³±±
±±³             ³          ³                          ³no relatório de Carga Inicial dos Eventos  ³±±
±±³Eduardo Vic  ³04/08/2017³DRHESOCP-773              ³Inclusão de laço pra envio de dados de     ³±±
±±³             ³          ³                          ³todas as filiais, ajustes do envio de      ³±±
±±³             ³          ³                          ³ turnos e cargos.		  					     ³±±
±±³Eduardo V    ³11/08/2017³DRHESOCP-781              ³Correções de erros apontadas a issue 592   ³±±
±±³Marcos Cout  |14/09/2017|DRHESOCP-1018             |Realizando o ajuste necessário para que o  ³±±
±±³             |          |                          |sistema realize a validação do layout dispo³±±
±±³             |          |                          |nível no ambiente para fazer a integração  ³±±
±±³             |          |                          |entre o SIGAGPE e o SIGATAF                ³±±
±±|Claudinei S.|21/09/2017 |DRHESOCP-1039             |Ajuste na carga inicial dos horários/turnos|±±
±±|            |           |                          |para que seja realizada também para outras |±±
±±|            |           |                          |filiais.                                   |±±
±±|Cecília C.	  |03/10/2017|DRHESOCP-1390             |Ajuste para integrar turno de funcionários |±±
±±|             |          |                          |em férias/afastado na carga inicial.       |±±
±±|Eduardo Vice |06/12/2017|DRHESOCP-2197  			  |Inclusão de novas TAGS para orgão publico  |±±
±±³Marcos Cout  ³07/12/2017³DRHESOCP-2320             ³Realizado ajustes na carga inicial e nas   ³±±
±±³             ³          ³                          ³consistências do evento S-1050 Horar/Turno ³±±
±±³João Balbino ³18/12/2017³MPRIMESP-12848            ³Realizado ajustes na carga inicial e nas   ³±±
±±³             ³          ³                          ³consistências do evento S-1030 Cargos.     ³±±
±±³Marcos Cout  ³28/12/2017³  DRHESOCP-2631           ³Realizado criação da opção de carga inicial³±±
±±³             ³          ³                          ³do evento S-1040 - Cargos/Funções Comissio_³±±
±±³             ³          ³                          ³nados. Ajustes na função para gerar XML.   ³±±
±±³             ³          ³                          ³Ajuste no evento S-2200 qnd trabalhador    ³±±
±±³             ³          ³                          ³tiver cargo comissionado                   ³±±
±±³Marcos Cout  ³05/01/2018³  DRHESOCP-2703           ³Realizado ajustes na consulta SQL para que ³±±
±±³             ³          ³                          ³não exploda erro em ambiente PostGres      ³±±
±±³João Balbino ³08/01/2018³MPRIMESP-13155            ³Realizado ajustes na carga do evento S-1050³±±
±±³             ³          ³                          ³para importar todas as filiais.            ³±±
±±³Marcos Cout  ³09/01/2018³DRHESOCP-2703             ³Realizado ajuste na variavel logica que de_³±±
±±³             ³          ³                          ³fine se será gerado evento S1030 ou S1040  ³±±
±±³Marcos Cout  ³17/01/2018³DRHESOCP-2483             ³Realizado ajustes para geração dos extempo_³±±
±±³             ³          ³                          ³râneos dos eventos S-1030 e S-1040         ³±±
±±|Eduardo Vice ³22/01/2018³DRHESOCP-2197  			  ³retirada de linha que checava o valor do	  ³±±
±±³             ³          ³                          ³RJ_ACUM redundante.					      ³±±
±±³Cecília C.   ³22/01/2018³DRHESOCP-2859             ³Ajuste para realizar carga de horário onde ³±±
±±³             ³          ³                          ³no intervalo está cadastrado meia-noite.   ³±±
±±³Cecília Carv ³26/02/2018³ DRHESOCP-2894            ³Ajuste para consistir campos do cadastro de³±±
±±³             ³          ³                          ³funções referentes aos órgãos públicos.    ³±±
±±³Marcos Cout  ³28/01/2018³DRHESOCP-3307             ³Realizando ajustes para exclusão em lote de³±±
±±³             ³          ³                          ³eventos Carga Inicial                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPEM023C()

Local aArea		 	:= GetArea()
Local aAreaCR9  	:= {}
Local oProcesso	 	:= Nil
Local oDlgEven		:= Nil
Local cAliasTRB		:= GetNextAlias()
Local cProcesso		:= ""
Local nOpcX			:= 0
Local dDataRef		:= SToD("  /  /    ")
Local aSizeTel		:= MsAdvSize(.F.)
Local aObjects		:= {}
Local aInfo			:= {}
Local aPosObj		:= {}
Local oFWLayer		:= FWLayer():New()
Local aBotoes  	 	:= {}

RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fCargHorar³ Autor ³ Alessandro Santos     ³ Data ³03/03/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Realiza carga das tabelas de Horarios para o TAF            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCargHorar()                                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc - Numero da acao Aitva (inc- alt- vis - apagar)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

Function fCargHorar( cMesAno, nOpcA, aLogProc, aLogDds, aArrayFilP, aPar7, nP, cVersEnvio, cFiltro )

Local cXml			:= ""
Local cFilEnv		:= ""
Local lSemFilial	:= .F.
Local aHorario 		:= {}
Local aErros		:= {}
Local nZ 			:= 0
Local aFilTAF 		:= {}
Local aConcat 		:= {}
Local nX 			:= 0
Local cMenIni		:= ""
Local cAliasSRA 	:= GetNextAlias()

Local nHrInicio		:= 0
Local nHrFim
Local aTurnoAux		:= {}
Local lGeraXml 		:= .F.
Local nPosFil		:= 0
Local nPosTur		:= 0
Local nPosReg		:= 0
Local cChave		:= ""
Local cSituac		:= "%' ','A','F'%"
Local cTipJor		:= "%'1','2','4'%"
Local cJoinSPA		:= "%" + FWJoinFilial( "SRA", "SPA" ) + "%"
Local cJoinSRA		:= "%" + FWJoinFilial( "SRA", "SR6" ) + "%"
Local aThreads		:= {}
Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Local cFilQry		:= "%%"

Private nContador		:= 0
Private nContErr		:= 0

Default cMesAno 	:= ""
Default nOpcA 		:= 1
Default aPar7 		:= {}
Default aLogDds		:= {}
Default cVersEnvio	:= "2.2"
Default cFiltro		:= ""

aFilTAF	:= fGM23Fil(aArrayFilP,nP)

If Empty( xFilial("SR6") )
	lSemFilial := .T.
Endif

If !Empty(cFiltro)
	cFilQry 	:= "% " + GPEParSQL(fPrepExpIn(cFiltro)) + " AND %"
EndIf

nHrInicio := Seconds()

//Busca informacoes de horarios
If lSemFilial
	BeginSql alias cAliasSRA
		SELECT
			DISTINCT SR6.R_E_C_N_O_
		FROM
			%table:SR6% SR6
		INNER JOIN
			%table:SRA% SRA  ON %exp: cJoinSRA% AND SR6.R6_TURNO = SRA.RA_TNOTRAB AND SRA.RA_SITFOLH IN ( %exp:cSituac% ) AND SRA.RA_TPJORNA IN ( %exp:cTipJor% )  AND SRA.%notDel%
		INNER JOIN
			%table:SPA% SPA  ON %exp: cJoinSPA% AND SPA.PA_CODIGO = SRA.RA_REGRA AND SPA.%notDel%
		INNER JOIN
			%table:SPJ% SPJ  ON SR6.R6_FILIAL = SPJ.PJ_FILIAL AND SR6.R6_TURNO = SPJ.PJ_TURNO AND SPJ.PJ_TPDIA = %exp:"S"% AND SPJ.%notDel%
		WHERE
			%exp:cFilQry% SR6.%notDel%
		ORDER BY
			SR6.R_E_C_N_O_
	EndSql
Else
	BeginSql alias cAliasSRA
		SELECT
			DISTINCT SR6.R_E_C_N_O_
		FROM
			%table:SR6% SR6
		INNER JOIN
			%table:SRA% SRA  ON %exp: cJoinSRA% AND SR6.R6_TURNO = SRA.RA_TNOTRAB AND SRA.RA_FILIAL IN (%exp:aFilTAF[1]%) AND SRA.RA_SITFOLH IN ( %exp:cSituac% ) AND SRA.RA_TPJORNA IN ( %exp:cTipJor% )  AND SRA.%notDel%
		INNER JOIN
			%table:SPA% SPA  ON %exp: cJoinSPA% AND SPA.PA_CODIGO = SRA.RA_REGRA AND SPA.%notDel%
		INNER JOIN
			%table:SPJ% SPJ  ON SR6.R6_FILIAL = SPJ.PJ_FILIAL AND SR6.R6_TURNO = SPJ.PJ_TURNO AND SPJ.PJ_TPDIA = %exp:"S"% AND SPJ.%notDel%
		WHERE
			%exp:cFilQry% SR6.%notDel%
		ORDER BY
			SR6.R_E_C_N_O_
	EndSql
EndIf

While (cAliasSRA)->(!EOF())
	Aadd(aThreads,(cAliasSRA)->R_E_C_N_O_)
	(cAliasSRA)->(DbSkip())
EndDo

If (Select(cAliasSRA) > 0)
	(cAliasSRA)->(dbCloseArea())
EndIf

If Len(aThreads) > 0
	fHorThd( aArrayFilP, @aLogDds, aThreads, lSemFilial, cMesAno, nOpcA, cVersEnvio )
EndIf
//----------------------
//| Monta rodapé de LOG
//----------------------
If nOpcA == 1 .OR. nOpcA == 5 .AND. Len(aLogDds) > 1

	aAdd(aLogDds,"")
	aAdd(aLogDds,OemToAnsi(STR0226)) //"OBSERVAÇÕES:
	aAdd(aLogDds,OemToAnsi(STR0227)) //"1) Para empresas que utilizam o módulo SIGAPON: a partir de Setembro/2018, em decorrência das alterações para o eSocial, será necessário que o período de apontamento esteja compatível com a competência da Folha de Pagamento."
	aAdd(aLogDds,"")
	aAdd(aLogDds,If(lMiddleware,OemToAnsi(STR0274),OemToAnsi(STR0228))) //"2) Os registros cujo 'Tipo do Regime da Jornada de Trabalho' seja igual a '3-Funções específicadas no Inciso II do Art. 62 da CLT', não serão enviados ao TAF conforme layout do evento S-1050"

	aAdd(aLogDds,"")
	aAdd(aLogDds,"")
	aAdd(aLogDds,(OemToAnsi(STR0111)+" "+ OemToAnsi(STR0110) ))					//"Resumo" ###"Carga Inicial"
	aAdd(aLogDds, OemToAnsi(STR0009)+": " +  SecsToTime(nHrInicio))				//Inicio Processamento: A
	nHrFim 	:= SecsToTime(Seconds())
	aAdd(aLogDds,+OemToAnsi(STR0010)+":    " + nHrFim)							//Fim Processamento:    A
	aAdd(aLogDds,"")
	aAdd(aLogDds,OemToAnsi(STR0077)+": " + SecsToTime(Seconds() - nHrInicio))	//Duracao do Processamento
	aAdd(aLogDds,Iif(lMiddleware, OemToAnsi(STR0243), OemToAnsi(STR0078))+": "+ ALLTRIM(STR(nContador)))						//Quantidade Registro(s) enviado(s) ao TAF
	aAdd(aLogDds,Iif(lMiddleware, OemToAnsi(STR0244), OemToAnsi(STR0151))+": "+ ALLTRIM(STR(nContErr)))						//Quantidade Registros Não Enviados ao TAF
	aAdd(aLogDds,"")
	aAdd(aLogDds,"")

EndIf

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGp23Comp	³ Autor ³ Alessandro Santos     ³ Data ³05/03/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verificacao do compartilhamento das tabelas SPA e SR6 para  ³±±
±±³          ³cargas de horarios.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGp23Comp()                                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFilSPA: Filial da SPA - cFilSR6: Filial da SR6            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023  					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

Static Function fGp23Comp(cFilSPA, cFilSR6)

Local lRet 			:= .T.
Local nTamLayEmp 	:= Len(FWCompany()) //Tamanho empresa
Local nTamLayUO	  	:= Len(FWUnitBusiness()) //Tamanho Unidade Organizacional
Local aArea 		:= GetArea()

//Tratamentos para compartilhamentos SPA e SR6
If FWModeAccess("SPA", 1) == "C" .AND. FWModeAccess("SPA", 2) == "C" .AND. FWModeAccess("SPA", 3) == "C" //SPA compartilhada nao trata
	lRet := .T.
ElseIf FWModeAccess("SR6", 1) == "C" .AND. FWModeAccess("SR6", 2) == "C" .AND. FWModeAccess("SR6", 3) == "C" //SR6 compartilhada nao trata
	lRet := .T.
Else
	Do Case
		Case FWModeAccess("SPA", 1) == "E" .AND. FWModeAccess("SPA", 2) == "C" .AND. FWModeAccess("SPA", 3) == "C" //SPA com Empresa exclusiva
			If FWModeAccess("SR6", 1) == "E" //Tratamento empresa
				If Substr(cFilSPA, 1, nTamLayEmp) <> Substr(cFilSR6, 1, nTamLayEmp)
					lRet := .F.
				EndIf
			EndIf
		Case FWModeAccess("SPA", 1) == "E" .AND. FWModeAccess("SPA", 2) == "E" .AND. FWModeAccess("SPA", 3) == "C" //SPA com UO exclusiva
			If FWModeAccess("SR6", 1) == "E" .And. FWModeAccess("SR6", 2) == "C" //Tratamento Empresa
				If Substr(cFilSPA, 1, nTamLayEmp) <> Substr(cFilSR6, 1, nTamLayEmp)
					lRet := .F.
				EndIf
			ElseIf FWModeAccess("SR6", 1) == "E" .And. FWModeAccess("SR6", 2) == "E" //Tratamento Empresa e UO
				If Substr(cFilSPA, 1, nTamLayEmp + nTamLayUO) <> Substr(cFilSR6, 1, nTamLayEmp + nTamLayUO)
					lRet := .F.
				EndIf
			EndIf
		Case FWModeAccess("SPA", 1) == "E" .AND. FWModeAccess("SPA", 2) == "E" .AND. FWModeAccess("SPA", 3) == "E" //SPA totalmente exclusiva
			If FWModeAccess("SR6", 1) == "E" .And. FWModeAccess("SR6", 2) == "C" .And. FWModeAccess("SR6", 3) == "C" //Tratamento Empresa
				If Substr(cFilSPA, 1, nTamLayEmp) <> Substr(cFilSR6, 1, nTamLayEmp)
					lRet := .F.
				EndIf
			ElseIf FWModeAccess("SR6", 1) == "E" .And. FWModeAccess("SR6", 2) == "E" .And. FWModeAccess("SR6", 3) == "C" //Tratamento Empresa e UO
				If Substr(cFilSPA, 1, nTamLayEmp + nTamLayUO) <> Substr(cFilSR6, 1, nTamLayEmp + nTamLayUO)
					lRet := .F.
				EndIf
			ElseIf FWModeAccess("SR6", 1) == "E" .And. FWModeAccess("SR6", 2) == "E" .And. FWModeAccess("SR6", 3) == "E" //Tratamento Empresa, UO e Filial
				If cFilSPA <> cFilSR6
					lRet := .F.
				EndIf
			EndIf
	EndCase
EndIf

RestArea(aArea)

Return(lRet)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCarrFun    ºAutor  ³Marcia Moura        º Data ³  06/11/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega Cargos  (estamos levando tab funcao)               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023-                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ cFuncao - Codigo da Funcao que sera enviado ao TAF         º±±
±±º          ³ cDescricao - Descricao do Codigo que seja enviado ao TAF   º±±
±±º          ³ cCodCBO - Codigo CBO da Função                             º±±
±±º          ³ nOper - Operacao que esta sendo realizada                  º±±
±±º          ³ cAnoMes - Data de insercao do evento                       º±±
±±º          ³ aErros - Array de referencia para capturar os erros geradosº±±
±±º          ³ cFilEnv - Filial de envio para o evento                    º±±
±±º          ³ aCposVal - Campos dos Orgãos Publicos                      º±±
±±º          ³ lCargo - Verifica se gera o arquivo evento S-1040 ou não   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fCarrFun(cFuncao, cDescricao, cCodCBO, nOper, cAnoMes, aErros, cFilEnv, aCposVal, lCargo, cVersEnvio, cRetXML, cId, lTabSQ3)

	Local cXml			:= ""
	Local cDesc			:= ""
	Local lGravou		:= .T.
	Local aIncons		:= {}
	Local aFilInTaf 	:= {}
	Local aArrayFil 	:= {}
	Local lAdmPubl		:= .F.
	Local cDtLei		:= ""

	Local aInfoC		:= {}
	Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
	Local cGpeAmbe		:= ""
	Local cChaveMid		:= ""
	Local cStatMid		:= ""
	Local cOpcRJE		:= "I"
	Local cRetfRJE		:= ""
	Local nRecRJE		:= 0
	Local cOperNew		:= ""
	Local cRetfNew		:= ""
	Local cStatNew		:= "1"
	Local lNovoRJE		:= .F.
	Local dDtGer		:= Date()
	Local cHrGer		:= Time()
	Local aDados		:= {}
	Local nOpcao		:= 3
	Local cMsgErro		:= ""
	Local cRjeFil		:= ""

	default cFuncao		:= ""
	default cDescricao	:= ""
	default cCodCBO		:= ""
	default nOper		:= 3// inclusao
	default cAnoMes		:= ""
	default cFilEnv 	:= ""
	default aCposVal	:= {}
	Default lCargo		:= .F.
	Default cRetXML		:= ""
	Default cVersEnvio  := ""
	Default cId			:= ""
	Default lTabSQ3		:= .F.

	cDesc := FSubst(cDescricao)

	If lMiddleware .And. ChkFile("RJE")

		If Empty(cVersEnvio)
			fVersEsoc("S1030", .F.,,,,,@cVersEnvio,, @cGpeAmbe)
		Else
			fVersEsoc("S1030", .F.,,,,,,, @cGpeAmbe)
		EndIf

		aInfoC	:= fXMLInfos()

		if len(aInfoC) >= 4
			cId 	:= aInfoC[3]
			cTpInsc := aInfoC[1]
			cNrInsc := aInfoC[2]
			lAdmPubl:= aInfoC[4]
		Else
			cTpInsc  := ""
			lAdmPubl := .F.
			cNrInsc  := "0"
			cId		 := ""
		Endif

		If lCargo //S-1040
			cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtTabFuncao/v" + cVersEnvio + "'>"
			cXML += 	"<evtTabFuncao Id='" + cId + "'>"
		Else
			cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtTabCargo/v" + cVersEnvio + "'>"
			cXML += 	"<evtTabCargo Id='" + cId + "'>"
		Endif

		fXMLIdEve( @cXML, { Nil, Nil, Nil, Nil, cGpeAmbe, 1, "12" } )
		fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
	Else
		cXml := '<eSocial>'
		If lCargo //S-1040
			cXml += '	<evtTabFuncao>'
		Else
			cXml += '	<evtTabCargo>'
		Endif
	Endif
	//----------------
	//| Inicio do XML
	//----------------

	If lCargo //S-1040
		cXml += '		<infoFuncao>'

		//Verifica o tipo de operacao
		If nOper == 3
			cXml += '		<inclusao>'
		Elseif  nOper == 4
			cXml += '		<alteracao>'
		Elseif  nOper == 5
			cXml += '		<exclusao>'
		Endif

		cXml += '				<ideFuncao>'
		cXml += '					<codFuncao>' + cFuncao	+ '</codFuncao>'
		cXml += '					<iniValid>' + cAnoMes + '</iniValid>'
		If !lMIddleware
			cXml += '					<fimValid></fimValid>'
		Endif
		cXml += '				</ideFuncao>'

		If nOper <> 5
			cXml += '				<dadosFuncao>'
			cXml += '					<dscFuncao>' + AllTrim(cDesc) + '</dscFuncao>'
			cXml += '					<codCBO>' + Iif(lMiddleware, Alltrim(cCodCBO), cCodCBO) + '</codCBO>'
			cXml += '				</dadosFuncao>'

			If nOper == 4
				cXml += '			<novaValidade>'
				cXml += '				<iniValid>' + cAnoMes + '</iniValid>'
				If !lMIddleware
					cXml += '				<fimValid>' + '' + '</fimValid>'
				EndIf
				cXml += '			</novaValidade>'
			EndIf
		EndIf

		If nOper == 3
			cXml += '			</inclusao>'
		Elseif nOper == 4
			cXml += '			</alteracao>'
		Elseif nOper == 5
			cXml += '			</exclusao>'
		EndIf

		cXml += '		</infoFuncao>'
		cXml += '	</evtTabFuncao>'

	Else //S-1030
		cXml += '		<infoCargo>'

		//Verifica o tipo de operacao
		If nOper == 3
			cXml += '		<inclusao>'
		Elseif  nOper == 4
			cXml += '		<alteracao>'
		Elseif  nOper == 5
			cXml += '		<exclusao>'
		Endif

		cXml += '				<ideCargo>'
		cXml += '					<codCargo>'		+ cFuncao	+ '</codCargo>'
		cXml += '					<iniValid>' 	+ cAnoMes	+ '</iniValid>'
		if !lMIddleware
			cXml += '					<fimValid></fimValid>'
		ENDIF
		cXml += '				</ideCargo>'

		If nOper <> 5
			cXml += '			<dadosCargo>'
			cXml += '				<nmCargo>' + AllTrim(cDesc) + '</nmCargo>'
			cXml += '				<codCBO>' + Iif(lMiddleware, Alltrim(cCodCBO), cCodCBO) + '</codCBO>'
			if Len(aCposVal) > 0 .And. !Empty(aCposVal[1])
				cXml += '				<cargoPublico>'
				cXml += '					<acumCargo>'+aCposVal[1]+'</acumCargo>'
				cXml += '					<contagemEsp>'+aCposVal[2]+'</contagemEsp>'
				cXml += '					<dedicExcl>'+IIF(aCposVal[3]=='1','S','N')+'</dedicExcl>'
				cXml += '					<leiCargo>'
				cXml += '						<nrLei>'+ Iif(lMiddleware, Alltrim(aCposVal[4]), aCposVal[4]) + '</nrLei>'
				cDtLei	:= IIF(ValType(aCposVal[5])=="C",aCposVal[5],DtoS(aCposVal[5]))
				If !lMiddleware
					cXml += '						<dtLei>' + cDtLei + '</dtLei>'
				Else
					cXml += '						<dtLei>' + SubStr( cDtLei, 1, 4 ) + "-" + SubStr( cDtLei, 5, 2 ) + "-" + SubStr( cDtLei, 7, 2 ) + '</dtLei>'
				EndIf
				cXml += '						<sitCargo>'+aCposVal[6]+'</sitCargo>'
				cXml += '					</leiCargo>'
				cXml += '				</cargoPublico>'
			EndIf
			cXml += '			</dadosCargo>'
		EndIf

		If nOper == 4
			cXml += '			<novaValidade>'
			cXml += '				<iniValid>' + cAnoMes + '</iniValid>'
			if !lMIddleware
				cXml += '				<fimValid>' + '' + '</fimValid>'
			ENDIF
			cXml += '			</novaValidade>'
		EndIf

		If nOper == 3
			cXml += '		</inclusao>'
		Elseif nOper == 4
			cXml += '		</alteracao>'
		Elseif nOper == 5
			cXml += '		</exclusao>'
		EndIf

		cXml += '		</infoCargo>'
		cXml += '	</evtTabCargo>'
	EndIf
	cXml += '</eSocial>'

	cRetXML := cXml
	//---------------
	//| Final do XML
	//---------------

	//Recupera a filial Pai
	//cFilSM0 := fTafGetFil(cEmpAnt+cFilant, aIncons)
	//fGp23Cons(@aFilInTaf, @aArrayFil,@cFilSM0)

	If Empty(cFilEnv)
		cFilEnv:= cFilAnt
	EndIf

	GrvTxtArq(cXml)

	//----------------------------------------------------------
	//| Realiza a integração do evento S-1030 ou S-1040 no TAF
	//----------------------------------------------------------
	If lMiddleware .And. !(IsInCallStack("GP370TOK") .Or. IsInCallStack("GPEA030TOK"))

		cChaveMid	:= cTpInsc + PADR(Iif(!lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + If(lCargo, "S1040", "S1030") + Padr(cFuncao, fTamRJEKey(), " ") + SubStr(cAnoMes, 1, 4) + SubStr(cAnoMes, 6, 2)
		cStatMid	:= "-1"

		//RJE_TPINSC + RJE_INSCR + RJE_EVENTO + RJE_KEY + RJE_INI
		GetInfRJE(2, cChaveMid, @cStatMid, @cOpcRJE, @cRetfRJE, @nRecRJE)

		If nOper == 4 .Or. nOper == 5
			//Retorno pendente impede o cadastro
			If cStatMid == "2"
				cMsgErro := OemToAnsi(STR0246)//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
			EndIf

			//Alteração
			If nOper == 4
				//Evento de exclusão sem transmissão impede o cadastro
				If cOpcRJE == "E" .And. cStatMid != "4"
					cMsgErro := OemToAnsi(STR0247)//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"

				//Não existe na fila, será tratado como inclusão
				ElseIf cStatMid == "-1"
					nOpcao 		:= 3
					cOperNew 	:= "I"
					cRetfNew	:= "1"
					cStatNew	:= "1"
					lNovoRJE	:= .T.

				//Evento sem transmissão, irá sobrescrever o registro na fila
				ElseIf cStatMid $ "1/3"
					If cOpcRJE == "A"
						nOpcao 	:= 4
					EndIf

					cOperNew 	:= cOpcRJE
					cRetfNew	:= cRetfRJE
					cStatNew	:= "1"
					lNovoRJE	:= .F.

				//Evento diferente de exclusão transmitido, irá gerar uma retificação
				ElseIf cOpcRJE != "E" .And. cStatMid == "4"
					nOpcao 		:= 4
					cOperNew 	:= "A"
					cRetfNew	:= "2"
					cStatNew	:= "1"
					lNovoRJE	:= .T.

				//Evento de exclusão transmitido, será tratado como inclusão
				ElseIf cOpcRJE == "E" .And. cStatMid == "4"
					nOpcao 		:= 3
					cOperNew 	:= "I"
					cRetfNew	:= "1"
					cStatNew	:= "1"
					lNovoRJE	:= .T.
				EndIf
			//Exclusão
			ElseIf nOper == 5
				nOpcao := 5
				//Evento de exclusão sem transmissão impede o cadastro
				If cOpcRJE == "E" .And. cStatMid != "4"
					cMsgErro := OemToAnsi(STR0247)//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"

				//Evento diferente de exclusão transmitido irá gerar uma exclusão
				ElseIf cOpcRJE != "E" .And. cStatMid == "4"
					cOperNew 	:= "E"
					cRetfNew	:= cRetfRJE
					cStatNew	:= "1"
					lNovoRJE	:= .T.
				EndIf
			EndIf
		ElseIf nOper == 3
			//Retorno pendente impede o cadastro
			If cStatMid == "2"
				cMsgErro := OemToAnsi(STR0246)//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"

			//Evento de exclusão sem transmissão impede o cadastro
			ElseIf cOpcRJE == "E" .And. cStatMid != "4"
				cMsgErro := OemToAnsi(STR0247)//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"

			//Evento sem transmissão, irá sobrescrever o registro na fila
			ElseIf cStatMid $ "1/3"
				nOpcao		:= Iif( cOpcRJE == "I", 3, 4 )
				cOperNew 	:= cOpcRJE
				cRetfNew	:= cRetfRJE
				cStatNew	:= "1"
				lNovoRJE	:= .F.

			//Evento diferente de exclusão transmitido, irá gerar uma retificação
			ElseIf cOpcRJE != "E" .And. cStatMid == "4"
				cOperNew 	:= "A"
				cRetfNew	:= "2"
				cStatNew	:= "1"
				lNovoRJE	:= .T.

			//Será tratado como inclusão
			Else
				cOperNew 	:= "I"
				cRetfNew	:= "1"
				cStatNew	:= "1"
				lNovoRJE	:= .T.
			EndIf
		EndIf

		cRjeFil := xFilial(Iif(lTabSQ3, "SQ3", "SRJ"), cFilEnv)

		aAdd(aDados, {xFilial("RJE", cFilAnt), cRjeFil, cTpInsc, Iif(cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc), If(lCargo, "S1040", "S1030"), substr(cAnoMes,1,4) + substr(cAnoMes,6,2), cFuncao, cId, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew})

		//Se não for uma exclusão de registro não transmitido, cria/atualiza registro na fila
		If !(nOpcao == 5 .And. ((cOpcRJE == "E" .And. cStatMid == "4") .Or. cStatMid $ "-1/1/3") )
			If !(lGravou := fGravaRJE(aDados, cXml, lNovoRJE, nRecRJE))
				cMsgErro := OemToAnsi(STR0253)//"Ocorreu um erro na gravação do registro na tabela RJE"
			EndIf

		//Se for uma exclusão e não for de registro de exclusão transmitido, exclui registro de exclusão na fila
		ElseIf nOpcao == 5 .And. cStatMid != "-1" .And. !(cOpcRJE == "E" .And. cStatMid == "4")
			If !( lGravou := fExcluiRJE( nRecRJE ) )
				cMsgErro := OemToAnsi(STR0254)//"Ocorreu um erro na exclusão do registro na tabela RJE"
			EndIf
		EndIf

		If !Empty(cMsgErro)
			aAdd(aErros, cMsgErro)
		EndIf

	Else
		If lMiddleware
			lGravou := .T.
		Else
			If lCargo
				aErros := TafPrepInt( cEmpAnt, cFilEnv , cXml,, "1", "S1040")
			Else
				aErros := TafPrepInt( cEmpAnt, cFilEnv , cXml,, "1", "S1030")
			EndIf

			If Len( aErros ) > 0
				//Aviso(OemtoAnsi(STR0001), aErros[1],{"Ok"},3) //"Integração - TAF"
				lGravou := .F.
			Endif
		Endif
	Endif

	If Len(aErros) > 0
		FeSoc2Err(aErros[1], @cMsgErro, Iif(aErros[1] != '000026', 1, 2))
		lGravou := Iif(aErros[1] != '000026', .F., .T.)

		If aErros[1] == '000026'
			aErros := {}
			fEFDMsgErro(cMsgErro)
		Else
			aErros[1] := cMsgErro

			If Len(aErros) > 1
				aErros[1] := aErros[2]
			EndIf
		EndIf
	EndIf

	cRjeFil := ""

Return lGravou

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fCargFunc ³ Autor ³ Alessandro Santos     ³ Data ³03/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Realiza carga das tabelas de funcoes para o TAF             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCargFunc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

Function fCargFunc( cMesAno, nOpcA, aLogProc, aDados, aFilInTaf, cVersEnvio, lCargo, cFiltro)

Local cFuncao		:= ""
Local cDescr		:= ""
Local cCodCBO		:= ""
Local cMsgLog		:= ""
Local cMenIni   	:= ""
Local cXml			:= ""
Local cLayout		:= ""
Local cFilEnv		:= ""
Local aArea		 	:= GetArea()
Local aAreaSRJ  	:= SRJ->(GetArea())
Local cAliasSRJ		:= GetNextAlias()
Local lContinua		:= .T.
Local lSemFilial	:= .F.
Local lEOrgP		:= .F.
Local lOrgPubl		:= .F.
Local cFilCort		:= ""
Local cCpo			:= ""
Local nOpcAP 		:= 1
Local aArrayP 		:= {}
Local aCposVal		:= {}
Local aConcat 		:= {}
Local nX			:= 0
Local aErros		:= {}
Local nHrInicio
Local nContador		:= 0
Local nContErr		:= 0
Local nHrFim
Local cEventDesc	:= ""
Local cFunText		:= ""
Local nOpcAux		:= 0
Local cChave		:= ""
Local cStatus		:= ""
Local cEvento		:= ""
Local cAnoMes 		:= ""
Local lMiddleware	:= If(cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F.)
Local cFilQry		:= "%%"

Default cMesAno 	:= ""
Default nOpcA 		:= 1
Default aFilInTaf 	:= {}
Default cVersEnvio	:= "2.2"
Default lCargo		:= .F.
Default cFiltro		:= ""

cAnoMes			:= substr(cMesAno,3,4) + "-" + substr(cMesAno,1,2)
nOpcAP			:= nOpcA
aArrayFilP		:= aFilInTaf

cFilEnv		:= aArrayFilP[2]

//Definindo o nOpc do processo
If nOpcAP == 1
	nOpcAux := 3
ElseIf nOpcAP == 5
	nOpcAux := 5
End

//Tratamento de compartilhamento da tabela SRJ
If FWModeAccess("SRJ", 1) == "C" .AND. FWModeAccess("SRJ", 2) == "C" .AND. FWModeAccess("SRJ", 3) == "C" //SRJ compartilhada
	lSemFilial := .T.
EndIf
DBSELECTAREA("SRJ")
If !SRJ->(ColumnPos( 'RJ_ACUM' )) > 0

	cCpo:= "%RJ_FILIAL, RJ_FUNCAO, RJ_DESC, RJ_CODCBO%"
Else
	lEOrgP:= .T.
	lOrgPubl := .T.
	cCpo:= "%RJ_FILIAL, RJ_FUNCAO, RJ_DESC, RJ_CODCBO,RJ_ACUM,RJ_CTESP,RJ_DEDEXC,RJ_LEI,RJ_DTLEI,RJ_SIT%"
EndIf
If !Empty(cFilEnv)

	If !Empty(cFiltro)
		cFilQry 	:= "%" + GPEParSQL(fPrepExpIn(cFiltro)) + " AND %"
	EndIf

    //Inicio de Operação
    nHrInicio := Seconds()

	//Busca informacoes SRJ - Funcoes
	//Query para buscar informacoes de processos e varas
	BeginSql alias cAliasSRJ
		SELECT
			%exp:cCpo%
		FROM
			%table:SRJ% SRJ
		WHERE
			%exp:cFilQry% SRJ.%notDel%
		ORDER BY
			SRJ.RJ_FILIAL, SRJ.RJ_FUNCAO
	EndSql

	dbSelectArea(cAliasSRJ)

	//Posiciona no inicio do arquivo
	(cAliasSRJ)->(dbGoTop())

	//Inicializa regua de processamento
	ProcRegua((cAliasSRJ)->(RecCount()))

	While (cAliasSRJ)->(!EOF())

		//Verifica filiais
		If lSemFilial //Compartilhada
			lContinua := .T.
		ElseIf aScan(aArrayFilP[3], {|X| FwxFilial("SRJ", X) == (cAliasSRJ)->RJ_FILIAL}) > 0 //Exclusiva
			lContinua := .T.
		Else
			lContinua := .F.
		EndIf

		If lContinua .AND. nOpcAP == 5
			If lCargo
				cEvento := "S-1040"
			Else
				cEvento := "S-1030"
			EndIf

			//Montando as variaveis utilizadas na chave de pesquisa
			cFuncao := IIf(lSemFilial, AllTrim( (cAliasSRJ)->RJ_FUNCAO ), AllTrim( (cAliasSRJ)->RJ_FILIAL + (cAliasSRJ)->RJ_FUNCAO ) )

			If !lMiddleware
				cChave  := cFuncao + ";" + cMesAno
				fVerExtemp(cEvento, cChave, nOpcAux, @cStatus, lContinua, cFilEnv, @aErros)
			Else
				cChave := StrTran(cEvento, "-", "") + cFuncao
				GetInfRJE(4, cChave, @cStatus)
			EndIf

			If(cStatus $ "2|4") .Or. (lMiddleware .And. !Empty(cStatus))
				lContinua := .T.
			Else
				lContinua := .F.
			EndIf
		EndIf


		If lContinua
			//Descrição do item: S-1030 ou S-1040
			cEventDesc := Iif(!lCargo, Alltrim(OemToAnsi(STR0014)+ " " + OemToAnsi(STR0190)), Alltrim(OemToAnsi(STR0197) + "-" + OemToAnsi(STR0198)))
			If nOpcAP == 1 .OR. nOpcAP == 5 //Carga
				//CBO não informado
				If Empty((cAliasSRJ)->RJ_CODCBO) .AND. nOpcAP == 1
					//------------------------------------------------------------------------------------------------------------------------------------
					//Cargo                     XYZABC1230                                                                    Nâo Enviada ao TAF         "
					//Cargo Comissionado        XYZABC1230                                                                    Nâo Enviada ao TAF         "
					//Comentario do erro
					//
					//------------------------------------------------------------------------------------------------------------------------------------
					If lMiddleware
						aAdd(aDados, PADR(cEventDesc, 25) + " " + PADR((cAliasSRJ)->RJ_FUNCAO, 65 ) + " " + PADR(OemToAnsi(STR0242), 40)) //Funcao XYZ - Não enviado ao TAF
					Else
						aAdd(aDados, PADR(cEventDesc, 25) + " " + PADR((cAliasSRJ)->RJ_FUNCAO, 77 ) + " " + PADR(OemToAnsi(STR0029), 26)) //Funcao XYZ - Não enviado ao TAF
					EndIf

					aAdd( aDados, OemToAnsi(STR0038) ) //#"CBO não informado."
					aAdd( aDados, "" )
					lContinua := .F.
					nContErr++
				EndIf

				If lContinua .And. lOrgPubl //se for órgão público
					//Valida os campos {RJ_ACUM,  RJ_CTESP, RJ_DEDEXC, RJ_LEI, RJ_DTLEI, RJ_SIT} se um deles estiver preenchido os outros também deverão estar.
					cFunText := ""
					If (!Empty((cAliasSRJ)->RJ_ACUM) .And. !Empty((cAliasSRJ)->RJ_CTESP) .And. !Empty((cAliasSRJ)->RJ_DEDEXC) .And. !Empty((cAliasSRJ)->RJ_LEI) .And. !Empty((cAliasSRJ)->RJ_DTLEI) .And. !Empty((cAliasSRJ)->RJ_SIT) .Or.;
					   (Empty((cAliasSRJ)->RJ_ACUM) .And. Empty((cAliasSRJ)->RJ_CTESP) .And. Empty((cAliasSRJ)->RJ_DEDEXC) .And. Empty((cAliasSRJ)->RJ_LEI) .And. Empty((cAliasSRJ)->RJ_DTLEI) .And. Empty((cAliasSRJ)->RJ_SIT)))
						lContinua := .T.
					Else
						If Empty((cAliasSRJ)->RJ_ACUM)
						    cFunText := cFunText + Iif(Len(cFunText)>0,", ","") + "RJ_ACUM"
						EndIf
						If Empty((cAliasSRJ)->RJ_CTESP)
						    cFunText := cFunText + Iif(Len(cFunText)>0,", ","") + "RJ_CTESP"
						EndIf
						If Empty((cAliasSRJ)->RJ_DEDEXC)
						    cFunText := cFunText + Iif(Len(cFunText)>0,", ","") + "RJ_DEDEXC"
						EndIf
						If Empty((cAliasSRJ)->RJ_LEI)
						    cFunText := cFunText + Iif(Len(cFunText)>0,", ","") + "RJ_LEI"
						EndIf
						If Empty((cAliasSRJ)->RJ_DTLEI)
						    cFunText := cFunText + Iif(Len(cFunText)>0,", ","") + "RJ_DTLEI"
						EndIf
						If Empty((cAliasSRJ)->RJ_SIT)
						    cFunText := cFunText + Iif(Len(cFunText)>0,", ","") + "RJ_SIT"
						EndIf

						If lMiddleware
							aAdd(aDados, PADR(cEventDesc, 20) + " " + PADR((cAliasSRJ)->RJ_FUNCAO, 65 ) + " " + PADR(OemToAnsi(STR0242), 40)) //Funcao XYZ - Não enviado ao TAF
						Else
							aAdd(aDados, PADR(cEventDesc, 25) + " " + PADR((cAliasSRJ)->RJ_FUNCAO, 77 ) + " " + PADR(OemToAnsi(STR0029), 26)) //Funcao XYZ - Não enviado ao TAF
						EndIf

						aAdd(aDados, cFunText + " - Mot.: " + OemToAnsi(STR0184))
						aAdd( aDados, "" )

						lContinua := .F.
						nContErr++
					EndIf
				EndIf

				//Se tiver o CBO da função, realiza a integração
				If lContinua
					Begin Transaction
						//Tratamento para Cargo
						If lOrgPubl
							lEOrgP    := Iif(Empty((cAliasSRJ)->RJ_ACUM),.F.,.T.)
						EndIf
						cFuncao := IIf(lSemFilial,ALLTRIM((cAliasSRJ)->RJ_FUNCAO), ALLTRIM((cAliasSRJ)->RJ_FILIAL+(cAliasSRJ)->RJ_FUNCAO))
						aCposVal		:= {}
						If lEOrgP
							aAdd(aCposVal,(cAliasSRJ)->RJ_ACUM)
							aAdd(aCposVal,(cAliasSRJ)->RJ_CTESP)
							aAdd(aCposVal,(cAliasSRJ)->RJ_DEDEXC)
							aAdd(aCposVal,(cAliasSRJ)->RJ_LEI)
							aAdd(aCposVal,(cAliasSRJ)->RJ_DTLEI)
							aAdd(aCposVal,(cAliasSRJ)->RJ_SIT)
						EndIf

						cDescr  := (cAliasSRJ)->RJ_DESC
						cCodCBO := (cAliasSRJ)->RJ_CODCBO

						lRet := fCarrFun( cFuncao, cDescr, cCodCBO, nOpcAux, cAnoMes, @aErros, cFilEnv ,aCposVal, lCargo )

					 	If Len( aErros ) <= 0
							//--------------------------------------------------------------
							//| Os erros serão impressos alinhados | Tamanho cabecalho: 132
							//| Colunas: Eventos (25+1) | Item/Registro (77+1) | Status (26)
							//| PADR("Eventos", 25) + " " + PADR("ITEM/REGISTRO", 77) + " " + PADR("STATUS", 26))
							//------------------------------------------------------------------------------------------------------------------------------------
							//Cargo                     XYZABC1230                                                                    Enviada ao TAF com sucesso."
							If lMiddleware
								aAdd(aDados, PADR(cEventDesc, 20) + " " + PADR(cFuncao, 65) + " " + PADR(OemToAnsi(STR0241), 40))
							Else
								aAdd(aDados, PADR(cEventDesc, 25) + " " + PADR(cFuncao, 77) + " " + PADR(OemToAnsi(STR0030), 26))
							EndIf
							nContador++
						Else
							aConcat := {}

							//Le o erro e quebra num array de acordo com a quantidade de enter
							aConcat := StrTokArr(aErros[1], chr(13)+chr(10))

							//------------------------------------------------------------------------------------------------------------------------------------
							//Cargo                     XYZABC1230                                                                    Nâo Enviada ao TAF         "
							//Comentario do erro
							//Cargo Comissionado        XYZABC1230                                                                    Nâo Enviada ao TAF         "
							//
							//------------------------------------------------------------------------------------------------------------------------------------
							If lMiddleware
								aAdd(aDados, PADR(cEventDesc, 20) + " " + PADR((cAliasSRJ)->RJ_FUNCAO, 65 ) + " " + PADR(OemToAnsi(STR0242), 40)) //Funcao XYZ - Não enviado ao TAF
							Else
								aAdd(aDados, PADR(cEventDesc, 25) + " " + PADR((cAliasSRJ)->RJ_FUNCAO, 77 ) + " " + PADR(OemToAnsi(STR0029), 26)) //Funcao XYZ - Não enviado ao TAF
							EndIf

							If( Len(aConcat) == 1 )
								aAdd( aDados, aConcat[1] )
							ElseIf( Len(aConcat) > 1 )

						   	//Atribui o erro no aDados para impressão em tela
								For nX := 2 To len(aConcat) step 2
								  	aAdd( aDados, aConcat[nX] )
								Next
							EndIf
							nContErr++
							aAdd(aDados, "")
						EndIf

				   	//Incrementa regua
						IncProc(OemToAnsi(STR0069) + " " + cFuncao)

					End Transaction
				Endif
			Else //Impressao

				If Empty((cAliasSRJ)->RJ_CODCBO)

					If Empty(cMenIni)
						cMenIni := OemToAnsi(STR0200) + cEventDesc + OemToAnsi(STR0201) //##"Inconsistências de XXXXXXXXXXXX - Os campos abaixo estão vazios e são de preenchimento obrigatórios:"
						aAdd(aLogProc, cMenIni)
						aAdd(aLogProc, "")
						aAdd(aLogProc, "")
					EndIf

					aAdd(aLogProc, cEventDesc + ": " + OemToAnsi((cAliasSRJ)->RJ_FILIAL)+OemToAnsi((cAliasSRJ)->RJ_FUNCAO) + " -> " + OemToAnsi((cAliasSRJ)->RJ_DESC)) //##"Funcao "

					If SX3->(MsSeek("RJ_CODCBO"))
						aAdd(aLogProc, AllTrim(SX3->X3_CAMPO) + " - " + OemToAnsi(STR0038))
					EndIf

					aAdd(aLogProc, "")
				EndIf

				//Incrementa regua
				IncProc(OemToAnsi(STR0069) + " " + (cAliasSRJ)->RJ_FUNCAO + " " + (cAliasSRJ)->RJ_DESC) //##"Gerando o registro de: "
	 		EndIf

		EndIf

		(cAliasSRJ)->(dbSkip())
	EndDo
Else
	//Grava log
	//cMsgLog := OemToAnsi(STR0040) + " - " + OemToAnsi(STR0032) + OemToAnsi(aIncons[1]) //##"Função" ##"Falha no envio ao TAF: "
	//fGp23GrLog(cFilEnv, "S1040", cMsgLog, "2")
EndIf

//----------------------
//| Monta rodapé de LOG
//----------------------
If nOpcAP == 1

	aAdd(aDados,"")
	aAdd(aDados,(OemToAnsi(STR0111)+" "+ OemToAnsi(STR0110) + " " + OemToAnsi(STR0039) ))	//"Resumo" ###"Carga Inicial" Rubrica
	aAdd(aDados, OemToAnsi(STR0009)+": " +  SecsToTime(nHrInicio))							//Inicio Processamento: A
	nHrFim 	:= SecsToTime(Seconds())
	aAdd(aDados,+OemToAnsi(STR0010)+":    " + nHrFim)											//Fim Processamento:    A
	aAdd(aDados,"")
	aAdd(aDados,OemToAnsi(STR0077)+": " + SecsToTime(Seconds() - nHrInicio))		//Duracao do Processamento
	aAdd(aDados,Iif(lMiddleware, OemToAnsi(STR0243), OemToAnsi(STR0078))+": "+ ALLTRIM(STR(nContador)))						//Quantidade Registro(s) enviado(s) ao TAF
	aAdd(aDados,Iif(lMiddleware, OemToAnsi(STR0244), OemToAnsi(STR0151))+": "+ ALLTRIM(STR(nContErr)))						//Quantidade Registros Não Enviados ao TAF
	aAdd(aDados,"")
	aAdd(aDados,"")

EndIf

//Fecha alias em uso
#IFDEF TOP
	If (Select(cAliasSRJ) > 0)
		(cAliasSRJ)->(dbCloseArea())
	EndIf
#ENDIF

RestArea(aAreaSRJ)
RestArea(aArea)

Return()


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

Local aAcentos:={}
Local aAcSubst:={}
Local cImpCar := Space(01)
Local cImpLin :=""
Local cAux 	  :=""
Local cAux1	  :=""
Local nTamTxt := Len(cTexto)
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
			Chr(213),Chr(245),Chr(227),Chr(252),Chr(045),Chr(047),Chr(061),Chr(060),Chr(062);
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
			"O","o","a","u","","","","","";
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



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGrvHorTAF³ Autor ³ Alessandro Santos     ³ Data ³03/03/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Realiza carga das tabelas de Horarios para o TAF            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGrvHorTAF()                                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc - Numero da acao Aitva (inc- alt- vis - apagar)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

Function fGrvHorTAF(cPar1, cFilEnv, cTurno, cRegra, cSeq, dDataRef, cEmpEnv, aErroTur, cVersEnvio )

Local aArea	    	:= GetArea()
Local aAreaSR6  	:= SR6->(GetArea())
Local aAreaSPA  	:= SPA->(GetArea())
Local aAreaSPJ  	:= SPJ->(GetArea())
Local cAliasTMP 	:= GetNextAlias()
Local cAliasSRA 	:= cPar1
Local cLayout		:= ""
Local cTpInterv		:= ""
Local cSeek			:= ""
Local cMsgLog		:= ""
Local cMenIni   	:= ""
Local cXml			:= ""
Local nHrSaida		:= 0
Local nDurInt		:= 0
Local nDuracao		:= 0
Local nDeltaE		:= 0
Local nDeltaS		:= 0
Local lSemFilial	:= .F.
Local lContinua		:= .T.
Local aHorario 		:= {}
Local aErros		:= {}
Local nPosH			:= 0
Local nZ 			:= 0
Local aFilTAF 		:= {}
Local aAreaSRA		:= {}
Local cMesAnoP 		:= ""
Local nOpcAP 		:= 1
Local aArrayP 		:= {}
Local cChave 		:= ""
Local cChaveSPA 	:= ""
Local cChaveSR6 	:= ""
Local cChaveSPJ 	:= ""
Local lRegra 		:= .F.
Local lTurno 		:= .F.
Local cDia 			:= ""
Local cAliasSR6		:= "SR6"
Local cAliasSPA		:= "SPA"
Local cAliasSPJ		:= "SPJ"
Local aErrosRet		:= {}
Local lArqEmp		:= .F.
Local dDtCgini		:= SuperGetMV("MV_DTCGINI", Nil, dDataBase )
Local lRegNovo		:= .F.
Local lErroT		:= .F.

Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Local lAdmPubl		:= .F.
Local cId			:= ""
Local aInfoC		:= {}
Local cOperNew 		:= "I"
Local cRetfNew		:= "1"
Local cStatNew		:= "1"
Local lNovoRJE		:= .T.
Local cKeyMid		:= ""
Local dDtGer		:= Date()
Local cNumDat 		:= DTOS(Date())+SubStr(Time(),1,2)+SubStr(Time(),4,2)+StrZero(Val(SubStr(Time(),7,2))+1,2) 	// AAAAMMDDHHMMSS
Local aDados		:= {}
Local cBkpFil		:= cFilAnt
Local cChaveMid		:= ""
Local lFirst		:= .T.
Local cGpeAmbe		:= ""
Local cDtIni		:= ""
Local lGpa180		:= IsInCallStack("GPEA180MAT") .Or. IsInCallStack("fEnvTaf180")

Default cVersEnvio  := ""

Default cPar1 := ""
Default cTurno := M->RA_TNOTRAB
Default cRegra := M->RA_REGRA
Default cSEQ := M->RA_SEQTURN
Default dDataRef := cTod("")
Default cEmpEnv	:= cEmpAnt
Default aErroTur := {}

If GetMemVar("RA_TPJORNA") == "1" // Submetidos a Horario de Trabalho
	//Empresa diferente da empresa logada
	If cEmpEnv != cEmpAnt
		lArqEmp := .T.
		fAbrEmpresa("SR6", , cEmpEnv, cFilEnv)
		fAbrEmpresa("SPA", , cEmpEnv, cFilEnv)
		fAbrEmpresa("SPJ", , cEmpEnv, cFilEnv)
		cAliasSR6 := "GPESR6"
		cAliasSPA := "GPESPA"
		cAliasSPJ := "GPESPJ"
	EndIf

	aAreaSRA := GetArea()
	lSemFilial := .F.

	if Empty(xFilial("SR6"))
		lSemFilial := .T.
	Endif

	If !Empty(dDataRef) .And. dDataRef > dDtCgini
		cMesAnoP := Month2Str(dDataRef) + Year2Str(dDataRef)
	Else
		cMesAnoP := Month2Str(dDtCgini) + Year2Str(dDtCgini)
	EndIf

	//Procura Regra
	lRegra := .F.
	dbSelectArea(cAliasSPA)
	(cAliasSPA)->(dbGoTop()) //Posiciona no inicio da tabela de regras
	If Empty(xFilial("SPA"))
		cChaveSPA := xFilial("SPA")+cRegra
	Else
		cChaveSPA := xFilial("SPA", cFilEnv) + cRegra
	Endif
	If dbSeek(cChaveSPA) // so gera se a regra for encontrada
		lRegra := .T.
	EndIf

	//Procura Turno
	lTurno := .F.
	dbSelectArea(cAliasSR6)
	(cAliasSR6)->(dbGoTop()) //Posiciona no inicio da tabela de regras
	If Empty(xFilial("SR6"))
		cChaveSR6 := xFilial("SR6") + cTurno
	Else
		cChaveSR6 := xFilial("SR6", cFilEnv) + cTurno
	EndIf

	If dbseek(cChaveSR6) // so gera se o turno for encontrado
		lTurno := .T.
	EndIf

	If lMiddleware .And. !ChkFile("RJE")
		cMsgLog := OemToAnsi(STR0258)		 //###"Tabela RJE não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
		Aadd(aErroTur, cMsgLog)
		lTurno := .F.
	Endif

	lErro := .F.
	if lTurno .and. lRegra
		dbSelectArea(cAliasSPJ)
		(cAliasSPJ)->(dbGoTop()) //Posiciona no inicio do arquivo temporario
		IF empty(xFilial("SPJ"))
			cChaveSPJ := xFilial("SPJ")+ cTurno
		else
			cChaveSPJ := xFilial("SPJ", cFilEnv) + cTurno
		Endif
		if dbseek(cChaveSPJ) // so gera se o turno for encontrado
			While (cAliasSPJ)->(!EOF()) .AND.;
			(( empty((cAliasSPJ)->PJ_FILIAL) .AND. cTurno == (cAliasSPJ)->PJ_TURNO ) .or.;
			( !empty((cAliasSPJ)->PJ_FILIAL) .AND. xFilial("SPJ", cFilEnv) + cTurno == (cAliasSPJ)->PJ_FILIAL + (cAliasSPJ)->PJ_TURNO ))

				lErro := If( ((cAliasSPJ)->PJ_SAIDA4 + (cAliasSPJ)->PJ_SAIDA3 + (cAliasSPJ)->PJ_SAIDA2 + (cAliasSPJ)->PJ_SAIDA1 + (cAliasSPJ)->PJ_ENTRA4 + (cAliasSPJ)->PJ_ENTRA3 + (cAliasSPJ)->PJ_ENTRA2 + (cAliasSPJ)->PJ_ENTRA1 == 0) .Or. ((cAliasSPJ)->PJ_TPDIA <> "S"), .T., .F. )
				lErroT:= If( ((cAliasSPJ)->PJ_SAIDA4 + (cAliasSPJ)->PJ_SAIDA3 + (cAliasSPJ)->PJ_SAIDA2 + (cAliasSPJ)->PJ_SAIDA1 + (cAliasSPJ)->PJ_ENTRA4 + (cAliasSPJ)->PJ_ENTRA3 + (cAliasSPJ)->PJ_ENTRA2 + (cAliasSPJ)->PJ_ENTRA1 == 0) .And. ((cAliasSPJ)->PJ_TPDIA == "S"), .T., .F. )

				//Horario de saida
				nHrSaida := ""
				If (cAliasSPJ)->PJ_SAIDA4 <> 0 .Or. (cAliasSPJ)->PJ_ENTRA4 <> 0
					nHrSaida := (cAliasSPJ)->PJ_SAIDA4
				ElseIf (cAliasSPJ)->PJ_SAIDA3 <> 0 .Or. (cAliasSPJ)->PJ_ENTRA3 <> 0
					nHrSaida := (cAliasSPJ)->PJ_SAIDA3
				ElseIf (cAliasSPJ)->PJ_SAIDA2 <> 0 .Or. (cAliasSPJ)->PJ_ENTRA2 <> 0
					nHrSaida := (cAliasSPJ)->PJ_SAIDA2
				Else
					nHrSaida := (cAliasSPJ)->PJ_SAIDA1
				EndIf

				//Tempo de durcao
				nDuracao := Int((cAliasSPJ)->PJ_HRSTRAB) * 60 + (((cAliasSPJ)->PJ_HRSTRAB - Int((cAliasSPJ)->PJ_HRSTRAB)) * 100)
				nDuracao += Int((cAliasSPJ)->PJ_HRSTRA2) * 60 + (((cAliasSPJ)->PJ_HRSTRA2 - Int((cAliasSPJ)->PJ_HRSTRA2)) * 100)
				nDuracao += Int((cAliasSPJ)->PJ_HRSTRA3) * 60 + (((cAliasSPJ)->PJ_HRSTRA3 - Int((cAliasSPJ)->PJ_HRSTRA3)) * 100)
				nDuracao += Int((cAliasSPJ)->PJ_HRSTRA4) * 60 + (((cAliasSPJ)->PJ_HRSTRA4 - Int((cAliasSPJ)->PJ_HRSTRA4)) * 100)

				//Tempo de Intervalo
				nDurInt := Int((cAliasSPJ)->PJ_HRSINT1) * 60 + (((cAliasSPJ)->PJ_HRSINT1 - Int((cAliasSPJ)->PJ_HRSINT1)) * 100)
				nDurInt += Int((cAliasSPJ)->PJ_HRSINT2) * 60 + (((cAliasSPJ)->PJ_HRSINT2 - Int((cAliasSPJ)->PJ_HRSINT2)) * 100)
				nDurInt += Int((cAliasSPJ)->PJ_HRSINT3) * 60 + (((cAliasSPJ)->PJ_HRSINT3 - Int((cAliasSPJ)->PJ_HRSINT3)) * 100)

				//Delta de Entrada
				nDeltaE := Int((cAliasSR6)->R6_HORMENO) * 60 + (((cAliasSR6)->R6_HORMENO - Int((cAliasSR6)->R6_HORMENO)) * 100)

				//Delta de Saida
				nDeltaS := Int((cAliasSR6)->R6_HORMAIS) * 60 + (((cAliasSR6)->R6_HORMAIS - Int((cAliasSR6)->R6_HORMAIS)) * 100)

				//Tipo de Intervalo
				If (cAliasSPA)->PA_INMOVEL == "N"
					cTpInterv := "1"
				Else
					cTpInterv := "2"
				Endif

				//Controle para gravar o domingo
				cDia := (cAliasSPJ)->PJ_DIA
				if cDia == "1"
					cDia := "8"
				Endif

				//Monta chave de busca
				if Empty(xFilial("SPJ"))
					cSeek := (cAliasSPJ)->PJ_TURNO + (cAliasSPA)->PA_CODIGO + (cAliasSPJ)->PJ_SEMANA + cDia
				Else
					cSeek := xFilial("SPJ", cFilEnv) + (cAliasSPJ)->PJ_TURNO + (cAliasSPA)->PA_CODIGO + (cAliasSPJ)->PJ_SEMANA + cDia
				Endif

				nPosH 	:= aScan( aHorario , { |x| x[19] == cSeek  } )
				if nPosH == 0
					if Empty(xFilial("SPJ"))
						cChave := (cAliasSPJ)->PJ_TURNO + (cAliasSPA)->PA_CODIGO + (cAliasSPJ)->PJ_SEMANA + cDia
					Else
						cChave := xFilial("SPJ", cFilEnv) + (cAliasSPJ)->PJ_TURNO + (cAliasSPA)->PA_CODIGO + (cAliasSPJ)->PJ_SEMANA + cDia
					Endif
					If !lMiddleware
						cStatus := TAFGetStat("S-1050",cChave,,,4)
					Else
						If lMiddleware .And. ChkFile("RJE") .And. lFirst
							lFirst	 := .F.
							fPosFil( cEmpAnt, cFilEnv )
							aInfoC   := fXMLInfos()
							IF LEN(aInfoC) >= 4
								cTpInsc  := aInfoC[1]
								lAdmPubl := aInfoC[4]
								cNrInsc  := aInfoC[2]
								cId 	 := aInfoC[3]
							Else
								cTpInsc  := ""
								lAdmPubl := .F.
								cNrInsc  := "0"
							Endif
						EndIf
						cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1050" + Padr(cChave, fTamRJEKey(), " ")
						cStatus 	:= "-1"
						//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
						GetInfRJE( 2, cChaveMid, @cStatus,,,,,,,,, @cDtIni)
						If substr(cMesAnoP, 3, 4) + substr(cMesAnoP, 1, 2) < cDtIni
							cStatus	:= "-1"
						EndIf
					EndIf
					If !lRegNovo .And. cStatus == "-1"  .And. lErroT
						lRegNovo := .T.
					Endif
					If cStatus == "-1" .AND. !lErro
						aAdd	( aHorario ,{xFilial("SPJ", cFilEnv),;
											cChave,;
											(cAliasSPJ)->PJ_ENTRA1,;
											nHrSaida,;
											nDuracao,;
											(cAliasSPA)->PA_HRMOVEL,;
											cTpInterv,;
											IIF((cAliasSPJ)->PJ_INTERV1 == "S" .and. cTpInterv == "1" .and. (cAliasSPJ)->PJ_SAIDA1<>0 .and. (cAliasSPJ)->PJ_ENTRA2<>0, (cAliasSPJ)->PJ_SAIDA1, 0),;
											IIF((cAliasSPJ)->PJ_INTERV1 == "S".and. cTpInterv == "1" .and. (cAliasSPJ)->PJ_SAIDA1<>0 .and. (cAliasSPJ)->PJ_ENTRA2<>0, (cAliasSPJ)->PJ_ENTRA2, 0),;
											Int((cAliasSPJ)->PJ_HRSINT1) * 60 + (((cAliasSPJ)->PJ_HRSINT1 - Int((cAliasSPJ)->PJ_HRSINT1)) * 100),;
											IIF((cAliasSPJ)->PJ_INTERV2 == "S" .and. cTpInterv == "1" .and. (cAliasSPJ)->PJ_SAIDA2<>0 .and. (cAliasSPJ)->PJ_ENTRA3<>0, (cAliasSPJ)->PJ_SAIDA2, 0),;
											IIF((cAliasSPJ)->PJ_INTERV2 == "S" .and. cTpInterv == "1" .and. (cAliasSPJ)->PJ_SAIDA2<>0 .and. (cAliasSPJ)->PJ_ENTRA3<>0, (cAliasSPJ)->PJ_ENTRA3, 0),;
											Int((cAliasSPJ)->PJ_HRSINT2) * 60 + (((cAliasSPJ)->PJ_HRSINT2 - Int((cAliasSPJ)->PJ_HRSINT2)) * 100),;
											IIF((cAliasSPJ)->PJ_INTERV3 == "S" .and. cTpInterv == "1" .and. (cAliasSPJ)->PJ_SAIDA3<>0 .and. (cAliasSPJ)->PJ_ENTRA4<>0, (cAliasSPJ)->PJ_SAIDA3, 0),;
											IIF((cAliasSPJ)->PJ_INTERV3 == "S" .and. cTpInterv == "1" .and. (cAliasSPJ)->PJ_SAIDA3<>0 .and. (cAliasSPJ)->PJ_ENTRA4<>0, (cAliasSPJ)->PJ_ENTRA4, 0),;
											Int((cAliasSPJ)->PJ_HRSINT3) * 60 + (((cAliasSPJ)->PJ_HRSINT3 - Int((cAliasSPJ)->PJ_HRSINT3)) * 100),;
											nDeltaE,;
											nDeltaS,;
											cChave,;
											(cAliasSR6)->R6_FILIAL + (cAliasSPA)->PA_CODIGO})
					Endif
				Endif
				(cAliasSPJ)->(dbSkip())

			Enddo
		Endif
	Endif

	If lGpa180 .And. !Empty(dDataTra) .And. Len(aHorario) > 0
		If dDataTra > dDtCgini
			cMesAnoP := Month2Str(dDataTra) + Year2Str(dDataTra)
		Endif
	Endif

	//Inicializa regua de processamento
	For nZ := 1 to len(aHorario)
			//Verifica filiais

			aErros := {}
			If lMiddleware .And. ChkFile("RJE")

				fVersEsoc("S1030", .F.,,,,,,, @cGpeAmbe)

				aInfoC   := fXMLInfos()
				IF LEN(aInfoC) >= 4
					cId 	 := aInfoC[3]
				Else
					cId	  	 := ""
				Endif
				cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtTabHorTur/v" + cVersEnvio + "'>"
				cXML += 	"<evtTabHorTur Id='" + cId + "'>"
				fXMLIdEve( @cXML, { Nil, Nil, Nil, Nil, cGpeAmbe, 1, "12" } )
				fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
			Else
				cXml := '<eSocial>'
				cXml += '	<evtTabHorTur>'
			Endif
			cXml += '		<infoHorContratual>'
			cXml += '			<inclusao>'
			cXml += '				<ideHorContratual>'
			cXml += '					<codHorContrat>'+ aHorario[nZ,2]			+ '</codHorContrat>'
			cXml += '					<iniValid>' 	+ substr(cMesAnoP, 3, 4) + "-" + substr(cMesAnoP, 1, 2) + '</iniValid>'
			if !lMIddleware
				cXml += '					<fimValid>'	    + ''        				+ '</fimValid>'
			ENDIF
			cXml += '				</ideHorContratual>'
			cXml += '				<dadosHorContratual>'
			cXml += '					<hrEntr>'     	 + StrTran(StrZero(aHorario[nZ,3], 5, 2), ".", "") + '</hrEntr>'
			cXml += '					<hrSaida>'    	 + StrTran(StrZero(aHorario[nZ,4], 5, 2), ".", "") + '</hrSaida>'
			cXml += '					<durJornada>' 	 + Transform(aHorario[nZ,5], PesqPict("C90", "C90_DURJOR")) + '</durJornada>'
			cXml += '					<perHorFlexivel>'+ aHorario[nZ,6] 			+ '</perHorFlexivel>'

			if aHorario[nZ,7] == "2" .and. aHorario[nZ,8] == 0  // vai gravar o total de minutos
				cXml += '				<horarioIntervalo>'
				cXml += '					<tpInterv>'		+ aHorario[nZ,7] 											+ '</tpInterv>'
				cXml += '					<durInterv>'	+ alltrim(STR(aHorario[nZ,10]+aHorario[nZ,13]+aHorario[nZ,16]))									+ '</durInterv>'
				if !lMIddleware
					cXml += '					<iniInterv>'	+ '' 	+ '</iniInterv>'
					cXml += '					<termInterv>'	+ ''	+ '</termInterv>'
				ENDIF
				cXml += '				</horarioIntervalo>'
			Else
				If aHorario[nZ,8] > 0
					cXml += '				<horarioIntervalo>'
					cXml += '					<tpInterv>'		+ aHorario[nZ,7]										+ '</tpInterv>'
					cXml += '					<durInterv>'	+ alltrim(STR(aHorario[nZ,10]))									+ '</durInterv>'
					IF !EMPTY(aHorario[nZ,8])
						cXml += '					<iniInterv>'	+ StrTran(StrZero(aHorario[nZ,8], 5, 2), ".", "") 	+ '</iniInterv>'
					EndIf
					IF !EMPTY(aHorario[nZ,9])
						cXml += '					<termInterv>'	+ StrTran(StrZero(aHorario[nZ,9], 5, 2), ".", "")	+ '</termInterv>'
					ENDIF
					cXml += '				</horarioIntervalo>'
				Endif

				If aHorario[nZ,11] > 0
					cXml += '				<horarioIntervalo>'
					cXml += '					<tpInterv>'		+ aHorario[nZ,7]											+ '</tpInterv>'
					cXml += '					<durInterv>'	+ alltrim(STR(aHorario[nZ,13]))									+ '</durInterv>'
					if !empty(aHorario[nZ,11])
						cXml += '					<iniInterv>'	+ StrTran(StrZero(aHorario[nZ,11], 5, 2), ".", "") 	+ '</iniInterv>'
					Endif
					if !empty(aHorario[nZ,12])
						cXml += '					<termInterv>'	+ StrTran(StrZero(aHorario[nZ,12], 5, 2), ".", "")	+ '</termInterv>'
					Endif
					cXml += '				</horarioIntervalo>'
				Endif

				If aHorario[nZ,14] > 0
					cXml += '				<horarioIntervalo>'
					cXml += '					<tpInterv>'		+ aHorario[nZ,7]										+ '</tpInterv>'
					cXml += '					<durInterv>'	+ alltrim(STR(aHorario[nZ,16]))									+ '</durInterv>'
					if !empty(aHorario[nZ,14])
						cXml += '					<iniInterv>'	+ StrTran(StrZero(aHorario[nZ,14], 5, 2), ".", "") 	+ '</iniInterv>'
					Endif
					if !empty(aHorario[nZ,15])
						cXml += '					<termInterv>'	+ StrTran(StrZero(aHorario[nZ,15], 5, 2), ".", "")	+ '</termInterv>'
					Endif
					cXml += '				</horarioIntervalo>'
				Endif
			Endif

			cXml += '				</dadosHorContratual>'
			cXml += '			</inclusao>'
			cXml += '		</infoHorContratual>'
			cXml += '	</evtTabHorTur>'
			cXml += '</eSocial>'


			If lMiddleware .And. ChkFile("RJE")
				aDados  := {}
				cKeyMid	:= aHorario[nZ,2]
				aAdd( aDados, { xFilial("RJE", cFilAnt), aHorario[nZ,1], cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1050", substr(cMesAnoP, 3, 4) + substr(cMesAnoP, 1, 2), cKeyMid, cId, cRetfNew, "12", cStatNew, dDtGer, Time(), cOperNew } )

				If Len(aDados) > 0
					If !( lRetorno := fGravaRJE( aDados, cXml, lNovoRJE ) )
						cMsgLog := STR0259//"Ocorreu um erro na gravação do registro na tabela RJE"
						Aadd(aErroTur, cMsgRJE)
					EndIf
				Endif
			Else

				If lArqEmp
					aErros := TafPrepInt( cEmpAnt, If(lGpa180, cFilAnt, cFilEnv), cXml,     , "1"     , 	;
								"S1050", /*cXERPAlias*/, /*cTicket*/, /*cStatQueue*/,	;
								/*aStsInteg*/, /*lExcluiObjs*/, "GPE", cFilEnv,	 ;
								/*cPredeces*/, /*cComplem*/, cEmpEnv, If(lGpa180, .T., .F.) )
				Else
					aErros := TafPrepInt( cEmpEnv, cFilEnv, cXml, , "1", "S1050")
				EndIf

				If Len( aErros ) > 0
					cMsgLog := OemToAnsi(STR0065) + " " + aHorario[nZ,2] + " " + OemToAnsi(STR0029) + " " + OemToAnsi(STR0037) //##"Horário/Turno" ##"Não enviado ao TAF." ##"Reavaliar o cadastro."
					Aadd(aErrosRet, cMsgLog)
					Aadd(aErrosRet, aErros[1])
				EndIf
			Endif
			//Realiza geração de XML na System
			GrvTxtArq(alltrim(cXml), "S1050")

		IncProc(OemToAnsi(STR0069) + " " + aHorario[nZ,2]) //##"Gerando o registro de: "
	Next nZ

	If Len(aHorario) == 0 .And. lRegNovo
		cMsgLog := OemToAnsi(STR0065) + " " + cTurno + " " + OemToAnsi(STR0029) + " " + OemToAnsi(STR0037) //##"Horário/Turno" ##"Não enviado ao TAF." ##"Reavaliar o cadastro."
		Aadd(aErroTur, cMsgLog)
	Endif

	If lMiddleware
		fPosFil( cEmpAnt, cBkpFil )
	EndIf
EndIf

restarea(aArea)

Return(aErrosRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGM23Fil    ºAutor  ³Glaucia Messina     º Data ³  13/06/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carga de string para uso em Query por taeblas envolvidas,  º±±
±±º          ³ a partir das empresas centralizadoras escolhidas na carga  º±±
±±º          ³ TAF                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023- fCargVI                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGM23Fil(aFilInTaf)

Local aArea		:= GetArea()
Local x			:= 0
Local y			:= 0
Local cFilTOP	:= "%'"
Local cFilDBF	:= ""


For y:=1 to len(aFilInTaf[3])
	cFilTOP += aFilInTaf[3,y]
	cFilDBF += aFilInTaf[3,y] + "|"
	cFilTOP += "','"
Next y


If cFilTOP	=="%'"
	cFilTOP += "'%"
Else
	cFilTOP := SUBSTR(cFilTOP,1,(LEN(cFilTOP)-3))
	cFilTOP += "'%"
EndIf

RestArea(aArea)
Return ({cFilTOP,cFilDBF})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGetaHorarios ºAutor  ³Marcos Coutinho   º Data ³  07/12/17 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Centraliza a criação do evento S-1050 - Horários/Turnos em º±±
±±º          ³ somente 1 lugar.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023 e GPEM035                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGetaHorarios( lSemFilial, aArrayFil, aThreads, nRecDe, nRecAte, nOpc, cMesAno)
Local aArea	    	:= GetArea()
Local aAreaSR6  	:= SR6->(GetArea())
Local aAreaSPA  	:= SPA->(GetArea())
Local aAreaSPJ  	:= SPJ->(GetArea())
Local cAliasTMP 	:= GetNextAlias()
Local cTpInterv		:= ""
Local cSeek			:= ""
Local cFilEnv		:= aArrayFil[2]
Local nHrSaida		:= 0
Local nDurInt		:= 0
Local nDuracao		:= 0
Local lContinua		:= .T.
Local aHorario 		:= {}
Local nPosH			:= 0
Local cFilDe		:= ""
Local cFilAte		:= ""
Local cQryWhere   	:= "%"
Local cJoinSRA		:= "%" + FWJoinFilial( "SRA", "SR6" ) + "%"
Local aContainer := {}
Local nX			:= 0
Local cDia			:= ""
Local nTamReg		:= TamSx3("PA_CODIGO")[1]
Local nTamTur		:= TamSx3("PJ_TURNO")[1]
Local nTamFil		:= TamSx3("PJ_FILIAL")[1]
Local cRegra		:= ""
Local nRecno		:= 0
Local cAliasSRJ		:= "SRJ"
Local cJoinSPA		:= "%" + FWJoinFilial( "SRA", "SPA" ) + "%"
Local cAliasSPA		:= "SPA"
Local cSituac		:= "%' ','A','F'%"
Local cTipJor		:= "%'1','2','4'%"
Local cOpcAux		:= ""
Local cChave		:= ""
Local cStatus		:= ""
Local aErros		:= {}
Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Local cVersEnvio	:= ""
Local lTpJorn1      := SR6->(ColumnPos("R6_TPJOR1")) > 0 

Default nOpc		:= 3
Default cMesAno		:= ""
Default aThreads	:= {}

If lMiddleware
	cFilEnv := xFilial("SPJ", cFilEnv)
EndIf

fVersEsoc("S1050", .F.,,,,,@cVersEnvio,,)

If !Empty(cFilEnv)

	// Define o tipo de verbas a serem consideradas
	If !(Len(aThreads) > 0)
   		Pergunte("GPM035",.F.)
   		cFilde := MV_PAR01
   		cFilAte := MV_PAR02
   		cQryWhere += "(SR6.R6_FILIAL >= '" + xFilial("SR6",cFilde) + "' AND SR6.R6_FILIAL <= '" + xFilial("SR6",cFilAte) + "') %"
   	Else
		cQryWhere += "(SR6.R_E_C_N_O_ >= " + Alltrim(STR(aThreads[nRecDe])) + " AND SR6.R_E_C_N_O_ <= " + Alltrim(STR(aThreads[nRecAte])) + " ) %"
	EndIf

	//Query para buscar informacoes de turnos e horários
	If cVersEnvio >= "9.0.00" .And. lTpJorn1

		BeginSql alias cAliasTMP
			SELECT DISTINCT
				SR6.R6_FILIAL, SR6.R6_TURNO, SR6.R6_DESC, SR6.R6_TPJOR1, SR6.R6_DTPJOR, SPJ.PJ_TURNO, SPJ.PJ_SEMANA, SPJ.PJ_DIA, SPJ.PJ_ENTRA1, SPJ.PJ_ENTRA2, SPJ.PJ_INTSREP,
				SPJ.PJ_TPDIA, SPJ.PJ_ENTRA3, PJ_ENTRA4, SPJ.PJ_SAIDA1, SPJ.PJ_SAIDA2, SPJ.PJ_SAIDA3, SPJ.PJ_SAIDA4, SPJ.PJ_HRSTRAB, SPJ.PJ_HRSTRA2,
				SPJ.PJ_HRSTRA3, SPJ.PJ_HRSTRA4, SPJ.PJ_HRSINT1, SPJ.PJ_HRSINT2, SPJ.PJ_HRSINT3, SPJ.PJ_INTERV1, SPJ.PJ_INTERV2, SPJ.PJ_INTERV3 ,
				SPA.PA_FILIAL, SPA.PA_CODIGO, SPA.PA_INMOVEL, SPA.PA_HRMOVEL
			FROM
				%table:SR6% SR6
			INNER JOIN
				%table:SRA% SRA  ON %exp: cJoinSRA% AND SR6.R6_TURNO = SRA.RA_TNOTRAB AND SRA.RA_SITFOLH IN ( %exp:cSituac% ) AND SRA.RA_TPJORNA IN ( %exp:cTipJor% )  AND SRA.%notDel%
			INNER JOIN
				%table:SPA% SPA  ON %exp: cJoinSPA% AND SPA.PA_CODIGO = SRA.RA_REGRA AND SPA.%notDel%
			INNER JOIN
				%table:SPJ% SPJ  ON SR6.R6_FILIAL = SPJ.PJ_FILIAL AND SR6.R6_TURNO = SPJ.PJ_TURNO AND SPJ.PJ_TPDIA = %exp:"S"% AND SPJ.%notDel%
			WHERE
				SR6.%notDel% AND %exp:cQryWhere%
			ORDER BY
				SR6.R6_FILIAL, SR6.R6_TURNO, SPJ.PJ_SEMANA, SPJ.PJ_DIA
		EndSql
	Else
		BeginSql alias cAliasTMP
			SELECT DISTINCT
				SR6.R6_FILIAL, SR6.R6_TURNO, SR6.R6_DESC, SR6.R6_TPJORN, SR6.R6_DTPJOR, SPJ.PJ_TURNO, SPJ.PJ_SEMANA, SPJ.PJ_DIA, SPJ.PJ_ENTRA1, SPJ.PJ_ENTRA2, SPJ.PJ_INTSREP,
				SPJ.PJ_TPDIA, SPJ.PJ_ENTRA3, PJ_ENTRA4, SPJ.PJ_SAIDA1, SPJ.PJ_SAIDA2, SPJ.PJ_SAIDA3, SPJ.PJ_SAIDA4, SPJ.PJ_HRSTRAB, SPJ.PJ_HRSTRA2,
				SPJ.PJ_HRSTRA3, SPJ.PJ_HRSTRA4, SPJ.PJ_HRSINT1, SPJ.PJ_HRSINT2, SPJ.PJ_HRSINT3, SPJ.PJ_INTERV1, SPJ.PJ_INTERV2, SPJ.PJ_INTERV3 ,
				SPA.PA_FILIAL, SPA.PA_CODIGO, SPA.PA_INMOVEL, SPA.PA_HRMOVEL
			FROM
				%table:SR6% SR6
			INNER JOIN
				%table:SRA% SRA  ON %exp: cJoinSRA% AND SR6.R6_TURNO = SRA.RA_TNOTRAB AND SRA.RA_SITFOLH IN ( %exp:cSituac% ) AND SRA.RA_TPJORNA IN ( %exp:cTipJor% )  AND SRA.%notDel%
			INNER JOIN
				%table:SPA% SPA  ON %exp: cJoinSPA% AND SPA.PA_CODIGO = SRA.RA_REGRA AND SPA.%notDel%
			INNER JOIN
				%table:SPJ% SPJ  ON SR6.R6_FILIAL = SPJ.PJ_FILIAL AND SR6.R6_TURNO = SPJ.PJ_TURNO AND SPJ.PJ_TPDIA = %exp:"S"% AND SPJ.%notDel%
			WHERE
				SR6.%notDel% AND %exp:cQryWhere%
			ORDER BY
				SR6.R6_FILIAL, SR6.R6_TURNO, SPJ.PJ_SEMANA, SPJ.PJ_DIA
		EndSql
	Endif	

	dbSelectArea(cAliasTMP)

	(cAliasTMP)->(dbGoTop()) //Posiciona no inicio do arquivo temporario

	While (cAliasTMP)->(!EOF())

		cStatus := ""

		//Verifica filiais
		If lSemFilial //Compartilhada
			lContinua := .T.
		ElseIf aScan(aArrayFil[3], {|X| FwxFilial("SR6", X) == (cAliasTMP)->R6_FILIAL}) > 0 //Exclusiva
			lContinua := .T.
		Else
			lContinua := .F.
		EndIf

		If lContinua

			//Horario de saida
			If (cAliasTMP)->PJ_SAIDA4 <> 0 .Or. (cAliasTMP)->PJ_ENTRA4 <> 0
				nHrSaida := (cAliasTMP)->PJ_SAIDA4
			ElseIf (cAliasTMP)->PJ_SAIDA3 <> 0 .Or. (cAliasTMP)->PJ_ENTRA3 <> 0
				nHrSaida := (cAliasTMP)->PJ_SAIDA3
			ElseIf (cAliasTMP)->PJ_SAIDA2 <> 0 .Or. (cAliasTMP)->PJ_ENTRA2 <> 0
				nHrSaida := (cAliasTMP)->PJ_SAIDA2
			Else
				nHrSaida := (cAliasTMP)->PJ_SAIDA1
			EndIf

			//Tempo de durcao
			nDuracao := Int((cAliasTMP)->PJ_HRSTRAB) * 60 + (((cAliasTMP)->PJ_HRSTRAB - Int((cAliasTMP)->PJ_HRSTRAB)) * 100)
			nDuracao += Int((cAliasTMP)->PJ_HRSTRA2) * 60 + (((cAliasTMP)->PJ_HRSTRA2 - Int((cAliasTMP)->PJ_HRSTRA2)) * 100)
			nDuracao += Int((cAliasTMP)->PJ_HRSTRA3) * 60 + (((cAliasTMP)->PJ_HRSTRA3 - Int((cAliasTMP)->PJ_HRSTRA3)) * 100)
			nDuracao += Int((cAliasTMP)->PJ_HRSTRA4) * 60 + (((cAliasTMP)->PJ_HRSTRA4 - Int((cAliasTMP)->PJ_HRSTRA4)) * 100)

			//Tempo de Intervalo
			nDurInt := Int((cAliasTMP)->PJ_HRSINT1) * 60 + (((cAliasTMP)->PJ_HRSINT1 - Int((cAliasTMP)->PJ_HRSINT1)) * 100)
			nDurInt += Int((cAliasTMP)->PJ_HRSINT2) * 60 + (((cAliasTMP)->PJ_HRSINT2 - Int((cAliasTMP)->PJ_HRSINT2)) * 100)
			nDurInt += Int((cAliasTMP)->PJ_HRSINT3) * 60 + (((cAliasTMP)->PJ_HRSINT3 - Int((cAliasTMP)->PJ_HRSINT3)) * 100)

			//Tipo de Intervalo
			If (cAliasTMP)->PA_INMOVEL = "S"
				cTpInterv := "2"
			Else
				cTpInterv := "1"
			EndIf

			cDia := (cAliasTMP)->PJ_DIA
			If cDia == "1"
				cDia := "8"
			Endif

			//Monta chave de busca e realiza a busca no array
			If Funname() $ "GPEM035"
				cSeek := (cAliasTMP)->R6_FILIAL + (cAliasTMP)->PJ_TURNO + (cAliasTMP)->PJ_SEMANA + cDia
			Else
				cSeek := (cAliasTMP)->R6_FILIAL + (cAliasTMP)->PJ_TURNO + (cAliasTMP)->PA_CODIGO + (cAliasTMP)->PJ_SEMANA + cDia
			Endif
			nPosH 	:= aScan( aHorario , { |x| x[17] == cSeek  } )

			If nOpc == 5
				If !lMiddleware
					cChave := cSeek + ";" + cMesAno
					fVerExtemp( "S-1050", cChave, nOpc, @cStatus, lContinua, cFilEnv, @aErros )
				Else
					cChave := "S1050" + cSeek
					GetInfRJE( 4, cChave, @cStatus)
				EndIf

				If(cStatus $ "2|4") .Or. (lMiddleware .And. !Empty(cStatus))
					lContinua := .T.
				Else
					lContinua := .F.
				EndIf
			EndIf

			If lContinua
				//Se não encontrar, inclui
				If nPosH == 0

					aContainer := {}
					aAdd( aContainer, {; //Array contendo os dados de horários
							FunName(),;		//01 - Função de Origem
							cFilEnv,;		//02 - Filial de Envio
							cAliasTMP,;		//03 - Alias vinda do Banco
							nHrSaida,;		//04 - Hora de Saída
							nDuracao,;		//05 - Duração
							cTpInterv,;		//06 - Tipo de Intervalo
							cSeek})			//07 - Chave de Pesquisa

					//-----------------------------
					//| Monta o array de aHorarios
					//-----------------------------
					fMntaHorar(@aHorario, aContainer,.T.)

				Endif
			EndIf

		EndIf

		(cAliasTMP)->(dbSkip())
	EndDo

	//Verifica se alias esta em uso
	If (Select(cAliasTMP) > 0)
		(cAliasTMP)->(dbCloseArea())
	EndIf

	RestArea(aAreaSR6)
	RestArea(aAreaSPA)
	RestArea(aAreaSPJ)
	RestArea(aArea)
EndIf

Return aHorario

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fMntaHorar  ºAutor  ³Marcos Coutinho     º Data ³  07/12/17 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carga de string para uso em Query por taeblas envolvidas,  º±±
±±º          ³ a partir das empresas centralizadoras escolhidas na carga  º±±
±±º          ³ TAF                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023- fCargVI                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fMntaHorar(aHorario, aContainer, lTop)
Local cFilEnv := aContainer[1,2]
Local nHrSaida := aContainer[1,4]
Local nDuracao := aContainer[1,5]
Local cTpInterv := aContainer[1,6]
Local cSeek 	:= aContainer[1,7]
Local cAliasBD := aContainer[1,3]
Local cChave := ""
Local cTurno := ""
Local nSaida1 := 0
Local nSaida2 := 0
Local nSaida3 := 0
Local nEntra1 := 0
Local nEntra2 := 0
Local nEntra3 := 0
Local nEntra4 := 0
Local nHrsint1:= 0
Local nHrsint2:= 0
Local nHrsint3:= 0
Local cDesc := ""
Local cTpJorn:= ""
Local cDTpJorn := ""
Local cFilTur := ""
Local cDia		:= ""
Local cVersEnvio	:= ""
Local lTpJorn1      := SR6->(ColumnPos("R6_TPJOR1")) > 0 

Default aHorario		:= {}
Default aContainer	:= {}
Default lTop 			:= .T.

fVersEsoc("S1050", .F.,,,,,@cVersEnvio,,)
/*--------------------------------------------
Conteúdo de aContainer
[1,1]	FunName(),;		//01 - Função de Origem
[1,2] cFilEnv,;		//02 - Filial de Envio
[1,3]	cAliasTMP,;		//03 - Alias vinda do Banco
[1,4]	nHrSaida,;		//04 - Hora de Saída
[1,5]	nDuracao,;		//05 - Duração
[1,6]	cTpInterv,;		//06 - Tipo de Intervalo
[1,7]	cSeek})			//07 - Chave de Pesquisa
[1,8]	cChave})			//08 - Chave (Somente na Carga)
----------------------------------------------*/

cDia := (cAliasBD)->PJ_DIA
If cDia == "1"
	cDia := "8"
Endif
cChave    := (cAliasBD)->R6_FILIAL + (cAliasBD)->PJ_TURNO + (cAliasBD)->PA_CODIGO + (cAliasBD)->(PJ_SEMANA) + cDia
cTurno    := (cAliasBD)->PA_HRMOVEL
nSaida1 := IiF((cAliasBD)->PJ_INTERV1 == "S" .And. cTpInterv == "1", (cAliasBD)->PJ_SAIDA1, 0)
nSaida2 := IIF((cAliasBD)->PJ_INTERV2 == "S" .And. cTpInterv == "1", (cAliasBD)->PJ_SAIDA2, 0)
nSaida3 := IIF((cAliasBD)->PJ_INTERV3 == "S" .And. cTpInterv == "1", (cAliasBD)->PJ_SAIDA3, 0)
nEntra1 := (cAliasBD)->PJ_ENTRA1
nEntra2   := IIF((cAliasBD)->PJ_INTERV1 == "S" .And. cTpInterv == "1", (cAliasBD)->PJ_ENTRA2, 0)
nEntra3   := IIF((cAliasBD)->PJ_INTERV2 == "S" .And. cTpInterv == "1", (cAliasBD)->PJ_ENTRA3, 0)
nEntra4   := IIF((cAliasBD)->PJ_INTERV3 == "S" .And. cTpInterv == "1", (cAliasBD)->PJ_ENTRA4, 0)
nHrsint1  := Int((cAliasBD)->PJ_HRSINT1) * 60 + (((cAliasBD)->PJ_HRSINT1 - Int((cAliasBD)->PJ_HRSINT1)) * 100)
nHrsint2  := Int((cAliasBD)->PJ_HRSINT2) * 60 + (((cAliasBD)->PJ_HRSINT2 - Int((cAliasBD)->PJ_HRSINT2)) * 100)
nHrsint3  := Int((cAliasBD)->PJ_HRSINT3) * 60 + (((cAliasBD)->PJ_HRSINT3 - Int((cAliasBD)->PJ_HRSINT3)) * 100)
cDesc := (cAliasBD)->R6_DESC
cTpJorn   := If(cVersEnvio >= "9.0.00" .And. lTpJorn1, (cAliasBD)->R6_TPJOR1, (cAliasBD)->R6_TPJORN )
cDTpJorn  := (cAliasBD)->R6_DTPJOR
cFilTur   := (cAliasBD)->R6_FILIAL + (cAliasBD)->R6_TURNO


aAdd(aHorario,{;
		/*01*/ cFilEnv,;
		/*02*/ cChave,;
		/*03*/ nEntra1,;
		/*04*/ nHrSaida,;
		/*05*/ nDuracao,;
		/*06*/ cTurno,;
		/*07*/ cTpInterv,;
		/*08*/ nSaida1,;
		/*09*/ nEntra2,;
		/*10*/ nHrsint1,;
		/*11*/ nSaida2,;
		/*12*/ nEntra3,;
		/*13*/ nHrsint2,;
		/*14*/ nSaida3,;
		/*15*/ nEntra4,;
		/*16*/ nHrsint3,;
		/*17*/ cSeek,;
		/*18*/ cDesc,;
		/*19*/ cTpJorn,;
		/*20*/ cDTpJorn,;
		/*21*/ cFilTur})
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    fHorThd ³ Autor ³ Renan Borges             ³ Data ³17/01/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Direcionamento da execução da carga de rubricas.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fHorThd ()                                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023a  					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */

Function fHorThd( aFilInTaf, aDados, aThreads, lSemFilial, cMesAno, nOpca, cVersEnvio )
Local aParams		:= {}
Local nTotProc		:= 0
Local nPos			:= 0
Local cUserAux		:= __cUserId
Local nRotFim		:= 0
Local aLogTitle		:= {}
Local aLogItens		:= {}
Local aLogThd		:= {}
Local nX			:= 0
Local nY			:= 0
Local nTotThread	:= Min(GetMvRH("MV_CALCTHD",, 5),5) // Se o parametro esta configurado para utilizacao do GRID
Local nThdAux		:= 1
Local aLogPrc		:= {}
Local aDadosAux		:= {}
Local nSkip			:= 0
Local nFinal		:= 0
Local nThreads		:= 0
Local nPosX			:= 0
Local nThrPos		:= 0
Local nContEnv		:= 0
Local nContNEnv		:= 0

nTotProc 	:= Len(aThreads)
nTotThread	:= Min(nTotProc,nTotThread)
nThreads	:= Max(nTotThread,1)
nSkip	   := Round(nTotProc / nThreads,1)
While nSkip < 2 .AND.  nThreads > 1
	nThreads--
	nSkip	   := Round(nTotProc / nThreads,1)
EndDo
nSkip	   := Round(nTotProc / nThreads,0)
nFinal     := nSkip

If nThreads > 1
	VarSetUID("fHorThd",.T.)
	VarSetXD("fHorThd","nRotFim",0)
	VarSetXD("fHorThd","nContEnv",0)
	VarSetXD("fHorThd","nContNEnv",0)
	VarSetAD("fHorThd","aLogThd",{})
	VarSetAD("fHorThd","aLogPrc",{})
	VarSetAD("fHorThd","aDadosAux",{})

	For nPos := 1 to nTotProc STEP nSkip
			nPosX  := nPos
			nFinal := (nSkip + nPos) - 1
			If (nThdAux == nThreads)
				nFinal := nTotProc
				nPosX  := nTotProc
			EndIf

			StartJob("fHorExeThd",GetEnvServer(),.F.,cEmpAnt,cFilAnt,"000000",aFilInTaf,aDados,aThreads,lSemFilial,cMesAno,nOpca,nPos,nFinal,cVersEnvio,nThdAux)
			nThdAux++
			//Processa enquanto as threads não forem finalizadas
			While nPosX == nTotProc
				nPos	:= nPosX
				VarGetXD("fHorThd","nRotFim",@nRotFim)

				If nRotFim == nThreads
					VarGetAD("fHorThd","aLogPrc",@aLogPrc)
						aSort(aLogPrc,,, { |x, y| x[1] < y[1] })
						For nx := 1 to len(aLogPrc)
							For nY := 1 to len(aLogPrc[nX][2])
								aAdd(aLogProc,aLogPrc[nx][2][nY])
							Next nY
						Next nX
					VarGetAD("fHorThd","aDadosAux",@aDadosAux)
						aSort(aDadosAux,,, { |x, y| x[1] < y[1] })
						For nx := 1 to len(aDadosAux)
							For nY := 1 to len(aDadosAux[nX][2])
								aAdd(aDados,aDadosAux[nx][2][nY])
							Next nY
						Next nX
					VarGetXD("fHorThd","nContEnv",@nContEnv)
					VarGetXD("fHorThd","nContNEnv",@nContNEnv)
					nContador := nContEnv
					nContErr  := nContNEnv
					VarClean("fHorThd")
					Exit
				EndIf
			EndDo
	Next nPos
Else
	fCrgHor(aFilInTaf,aDados,aThreads,lSemFilial,cMesAno,1,nTotProc,nOpca,cVersEnvio)
EndIf

__cUserId := cUserAux

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    fHorExeThd ³ Autor ³ Renan Borges          ³ Data ³17/01/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Execução da carga de Horarios em multi-thread.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fHorExeThd ()                                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023a  					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */
Function fHorExeThd(xEmp,xFil,xUser,aFilInTaf,aDados,aThreads,lSemFilial,cMesAno,nOpca,nRecDe,nRecAte,cVersEnvio,nThread)

Local aLogAux	:= {}
Local aLogThd	:= {}
Local aLogPrc	:= {}
Local aDadosAux	:= {}
Local aLogTitle	:= {}
Local nRotFim	:= 0
Local nX		:= 1
Local aDados	:= {}
Local nTam		:= 0
Local nContEnv	:= 0
Local nContNEnv	:= 0

//Prepara ambiente
RPCSetType( 3 )
RpcSetEnv( xEmp, xFil,,,"GPE")
SetsDefault()

Private lAutoErrNoFile 	:= .T.
Private aLogProc		:= {}
Private nContador		:= 0
Private nContErr		:= 0

If Empty(cFilAnt)
	cFilAnt:= xFil
EndIf

__cUserId := xUser

fCrgHor( aFilInTaf, @aDados, aThreads, lSemFilial, cMesAno, nRecDe, nRecAte, nOpca, cVersEnvio )

If Len(aLogProc) > 0
	VarBeginT("fHorThd","aLogPrc")
		VarGetAD("fHorThd","aLogPrc",@aLogPrc)
			For nX := 1 to Len(aLogProc)
				If nX == 1
					aAdd(aLogPrc, {nThread,{aLogProc[nx]}})
					nTam := Len(aLogPrc)
				Else
					aAdd(aLogPrc[nTam,2],aLogProc[nx])
				EndIf
			Next
		VarSetAD("fHorThd","aLogPrc",aLogPrc)
	VarEndT("fHorThd","aLogPrc")
EndIf

If Len(aDados) > 0
	VarBeginT("fHorThd","aDadosAux")
		VarGetAD("fHorThd","aDadosAux",@aDadosAux)
			For nX := 1 to Len(aDados)
				If nX == 1
					aAdd(aDadosAux, {nThread,{aDados[nx]}})
					nTam := Len(aDadosAux)
				Else
					aAdd(aDadosAux[nTam,2],aDados[nx])
				EndIf
			Next
		VarSetAD("fHorThd","aDadosAux",aDadosAux)
	VarEndT("fHorThd","aDadosAux")
EndIf

//Soma Contador de Enviadas
VarBeginT("fHorThd","nContEnv")
	VarGetXD("fHorThd","nContEnv",@nContEnv)
	nContEnv += nContador
	VarSetXD("fHorThd","nContEnv",nContEnv)
VarEndT("fHorThd","nContEnv")

//Soma Contador de Não Enviadas
VarBeginT("fHorThd","nContNEnv")
	VarGetXD("fHorThd","nContNEnv",@nContNEnv)
	nContNEnv += nContErr
	VarSetXD("fHorThd","nContNEnv",nContNEnv)
VarEndT("fHorThd","nContNEnv")

//Soma 1 no controle de threads finalizadas
VarBeginT("fHorThd","nRotFim")
	VarGetXD("fHorThd","nRotFim",@nRotFim)
	nRotFim++
	VarSetXD("fHorThd","nRotFim",nRotFim)
VarEndT("fHorThd","nRotFim")

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    fCrgHor ³ Autor ³ Renan Borges          ³ Data ³17/01/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Execução da carga de Horarios.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCrgHor ()                                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023a  					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */
Function fCrgHor( aFilInTaf, aLogDds, aThreads, lSemFilial, cMesAno, nRecDe, nRecAte, nOpca, cVersEnvio )

Local cXml			:= ""
Local cFilEnv		:= ""
Local lSemFilial	:= .F.
Local aHorario 		:= {}
Local aErros		:= {}
Local nZ 			:= 0
Local aFilTAF 		:= {}
Local cMesAnoP 		:= ""
Local nOpcAP 		:= 1
Local aConcat 		:= {}
Local nX 			:= 0
Local cMenIni		:= ""
Local cAliasSRA 	:= GetNextAlias()

Local nHrFim
Local aTurnoAux		:= {}
Local lGeraXml 		:= .F.
Local nPosFil		:= 0
Local nPosTur		:= 0
Local nPosReg		:= 0
Local cChave		:= ""
Local cSituac		:= "%' ','A','F'%"
Local nOpc			:= 0

Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Local lAdmPubl		:= .F.
Local cId			:= ""
Local aInfoC		:= {}
Local cOperNew 		:= "I"
Local cRetfNew		:= "1"
Local cStatNew		:= "1"
Local lNovoRJE		:= .T.
Local cKeyMid		:= ""
Local dDtGer		:= Date()
Local cHrGer		:= Time()
Local cNumDat 		:= DTOS(Date())+SubStr(Time(),1,2)+SubStr(Time(),4,2)+StrZero(Val(SubStr(Time(),7,2))+1,2) 	// AAAAMMDDHHMMSS
Local aDados		:= {}
Local cAnoMes   	:= ""
Local cChaveMid		:= ""
Local cStatMid   	:= ""
Local cOpcRJE    	:= ""
Local cRetfRJE		:= ""
Local nRecRJE   	:= 0
Local cGpeAmbe		:= ""
Local cMsgRJE		:= ""

Default cVersEnvio  := ""

Default aLogDds		:= {}
Default cVersEnvio	:= "2.2"
Default aThreads	:= {}

cMesAnoP   := cMesAno
nOpcAP     := nOpca
aArrayFilP := aFilInTaf

cFilEnv	:= aArrayFilP[2]

cAnoMes:= Substr(cMesAno,3,5)+Substr(cMesAno,1,2)

If lMiddleware .And. !ChkFile("RJE")
	cMsgLog := OemToAnsi(STR0258)		 //###"Tabela RJE não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
	Aadd(aErroTur, cMsgLog)
Endif

If nOpcAP == 1
	nOpc := 3
ElseIf nOpcAP == 5
	nOpc := 5
EndIf

aHorario := fGetaHorarios(lSemFilial, aArrayFilP, aThreads, nRecDe, nRecAte, nOpc, cMesAnoP)

If lMiddleware .And. ChkFile("RJE") .And. Len(aHorario) > 0
	aInfoC   := fXMLInfos()
	IF LEN(aInfoC) >= 4
		cTpInsc  := aInfoC[1]
		lAdmPubl := aInfoC[4]
		cNrInsc  := aInfoC[2]
		cId 	 := aInfoC[3]
	Else
		cTpInsc  := ""
		lAdmPubl := .F.
		cNrInsc  := "0"
		cId		 := ""
	Endif
Endif

//Inicializa regua de processamento
For nZ := 1 to len(aHorario)

	//Reinicia variáveis de uso no Middleware:
	cStatMid   	:= ""
	cOpcRJE    	:= ""
	cRetfRJE	:= ""
	nRecRJE   	:= 0
	cMsgRJE 	:= ""

	//-----------------
	//| Realizar Carga
	//-----------------
	If nOpcAp == 1 .OR. nOpcAp == 5
		lGeraXml := fG17VSR6(aHorario[nZ], aLogProc, aTurnoAux, nOpcAp)
		If lGeraXml
			aErros := {}
			If lMiddleware .And. ChkFile("RJE")
				fVersEsoc("S1050", .F.,,,,,@cVersEnvio,, @cGpeAmbe)

				cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtTabHorTur/v" + cVersEnvio + "'>"
				cXML += 	"<evtTabHorTur Id='" + cId + "'>"
				fXMLIdEve( @cXML, { Nil, Nil, Nil, Nil, cGpeAmbe, 1, "12" } )
				fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )

				aInfoC   := fXMLInfos()
				If Len(aInfoC) >= 4
					cId 	 := aInfoC[3]
				Else
					cId	  	 := ""
				EndIf

			Else
		 		cXml := '<eSocial>'
				cXml += '	<evtTabHorTur>'
			Endif

			cXml += '		<infoHorContratual>'

			If nOpc == 3
				cXml += '			<inclusao>'
			ElseIf nOpc == 4
				cXml += '			<alteracao>'
			Else
				cXml += '			<exclusao>'
			EndIf

			cXml += '					<ideHorContratual>'
			cXml += '						<codHorContrat>' + aHorario[nZ,2] + '</codHorContrat>'
			cXml += '						<iniValid>' + substr(cMesAnoP,3,4) + "-" + substr(cMesAnoP,1,2) + '</iniValid>'
			if !lMIddleware
				cXml += '						<fimValid>' + '' + '</fimValid>'
			ENDIF
	     	cXml += '					</ideHorContratual>'

	     	If nOpc <> 5
		     	cXml += '				<dadosHorContratual>'
		     	cXml += '					<hrEntr>' + StrTran(StrZero(aHorario[nZ,3], 5, 2), ".", "") + '</hrEntr>'
		     	cXml += '					<hrSaida>' + StrTran(StrZero(aHorario[nZ,4], 5, 2), ".", "") + '</hrSaida>'
		     	cXml += '					<durJornada>' + Transform(aHorario[nZ,5], PesqPict("C90", "C90_DURJOR")) + '</durJornada>'
		     	cXml += '					<perHorFlexivel>' + aHorario[nZ,6] + '</perHorFlexivel>'

				if aHorario[nZ,7] == "2" .and. aHorario[nZ,8] == 0  // vai gravar o total de minutos
					cXml += '				<horarioIntervalo>'
					cXml += '					<tpInterv>'	+ aHorario[nZ,7] + '</tpInterv>'
					cXml += '					<durInterv>' + alltrim(STR(aHorario[nZ,10]+aHorario[nZ,13]+aHorario[nZ,16])) + '</durInterv>'
					if !lMIddleware
						cXml += '					<iniInterv>' + '' + '</iniInterv>'
						cXml += '					<termInterv>' + '' + '</termInterv>'
					ENDIF
					cXml += '				</horarioIntervalo>'
				Else
					If aHorario[nZ,10] > 0
						cXml += '				<horarioIntervalo>'
						cXml += '					<tpInterv>'	+ aHorario[nZ,7] + '</tpInterv>'
						cXml += '					<durInterv>' + alltrim(STR(aHorario[nZ,10])) + '</durInterv>'
						if !empty(aHorario[nZ,8])
							cXml += '					<iniInterv>' + StrTran(StrZero(aHorario[nZ,8], 5, 2), ".", "") + '</iniInterv>'
						Endif
						if !empty(aHorario[nZ,9])
							cXml += '					<termInterv>' + StrTran(StrZero(aHorario[nZ,9], 5, 2), ".", "") + '</termInterv>'
						Endif
						cXml += '				</horarioIntervalo>'
					Endif

					If aHorario[nZ,13] > 0
						cXml += '				<horarioIntervalo>'
						cXml += '					<tpInterv>' + aHorario[nZ,7] + '</tpInterv>'
						cXml += '					<durInterv>' + alltrim(STR(aHorario[nZ,13])) + '</durInterv>'
						if !empty(aHorario[nZ,11])
							cXml += '					<iniInterv>' + StrTran(StrZero(aHorario[nZ,11], 5, 2), ".", "") + '</iniInterv>'
						Endif
						if !empty(aHorario[nZ,12])
							cXml += '					<termInterv>' + StrTran(StrZero(aHorario[nZ,12], 5, 2), ".", "") + '</termInterv>'
						Endif
						cXml += '				</horarioIntervalo>'
					Endif

					If aHorario[nZ,16] > 0
						cXml += '				<horarioIntervalo>'
						cXml += '					<tpInterv>' + aHorario[nZ,7] + '</tpInterv>'
						cXml += '					<durInterv>' + alltrim(STR(aHorario[nZ,16])) + '</durInterv>'
						if !empty(aHorario[nZ,14])
							cXml += '					<iniInterv>' + StrTran(StrZero(aHorario[nZ,14], 5, 2), ".", "") + '</iniInterv>'
						Endif
						if !empty(aHorario[nZ,15])
							cXml += '					<termInterv>' + StrTran(StrZero(aHorario[nZ,15], 5, 2), ".", "") + '</termInterv>'
						Endif
						cXml += '				</horarioIntervalo>'
					Endif
				Endif

				cXml += '				</dadosHorContratual>'

			EndIf

			If nOpc == 4
				cXml += '				<novaValidade>'
				cXml += '					<iniValid>'	+ '' + '</iniValid>'
				cXml += '					<fimValid>'	+ '' + '</fimValid>'
				cXml += '				</novaValidade>'
			EndIf

			If nOpc == 3
				cXml += '			</inclusao>'
			ElseIf nOpc == 4
				cXml += '			</alteracao>'
			Else
				cXml += '			</exclusao>'
			EndIf

			cXml += '		</infoHorContratual>'
			cXml += '	</evtTabHorTur>'
			cXml += '</eSocial>'

			//Geração do XML de apoio
			GrvTxtArq(cXml)

			If lMiddleware .And. ChkFile("RJE")
				cKeyMid	:= aHorario[nZ,2]
				cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1050" + Padr(cKeyMid, fTamRJEKey(), " ") + cAnoMes
				cStatMid := "-1"

				//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
				GetInfRJE( 2, cChaveMid, @cStatMid, @cOpcRJE, @cRetfRJE, @nRecRJE )

				If nOpc == 5
					//Retorno pendente impede o cadastro
					If cStatMid == "2"
						cMsgRJE := OemToAnsi(STR0246)//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
					Else
						//Evento de exclusão sem transmissão impede o cadastro
						If cOpcRJE == "E" .And. cStatMid == "2"
							cMsgRJE := OemToAnsi(STR0247)//"Operação não será realizada pois há evento de excusão que não foi transmitido ou com retorno pendente"

						//Evento de exclusão já transmitido
						ElseIf cOpcRJE == "E" .And. cStatMid == "4"
							cMsgRJE := OemToAnsi(STR0280)//"Operação não será realizada pois evento de exclusão já foi transmitido"

						//Evento diferente de exclusão transmitido irá gerar uma exclusão
						ElseIf cOpcRJE != "E" .And. cStatMid == "4"
							cOperNew 	:= "E"
							cRetfNew	:= cRetfRJE
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						EndIf
					EndIf
				ElseIf nOpc == 3
					//Retorno pendente impede o cadastro
					If cStatMid == "2"
						cMsgRJE := OemToAnsi(STR0246)//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"

						//Evento de exclusão sem transmissão impede o cadastro
					ElseIf cOpcRJE == "E" .And. cStatMid != "4"
						cMsgRJE := OemToAnsi(STR0247)//"Operação não será realizada realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"

						//Evento sem transmissão, irá sobrescrever o registro na fila
					ElseIf cStatMid $ "1/3"
						cOperNew 	:= cOpcRJE
						cRetfNew	:= cRetfRJE
						cStatNew	:= "1"
						lNovoRJE	:= .F.

						//Será tratado como inclusão
					Else
						cOperNew 	:= "I"
						cRetfNew	:= "1"
						cStatNew	:= "1"
						lNovoRJE	:= .T.
					EndIf
				EndIf

				aDados  := {}
				cKeyMid	:= aHorario[nZ,2]
				aAdd( aDados, { xFilial("RJE", cFilAnt), aHorario[nZ,1], cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1050", cAnoMes, cKeyMid, cId, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew, , } )

				If Len(aDados) > 0 .And. cStatMid <> "2" .And. Empty(cMsgRJE)
					//Se não for uma exclusão inclui registro quando cOpcRJE for "E" não está com status 4. Se for uma inclusão não grava se status for 4.
					If !(nOpc == 5 .And. ((cOpcRJE == "E" .And. cStatMid == "4") .Or. cStatMid $ "-1/1/3")) .And. !(nOpc == 3 .And. cStatMid == "4" .And. cOpcRJE <> "E")
						If !(lRetorno := fGravaRJE(aDados, cXml, lNovoRJE, nRecRJE))
							cMsgLog := STR0259//"Ocorreu um erro na gravação do registro na tabela RJE"
							Aadd(aErroTur, OemToAnsi(cMsgLog))
						Else
							aAdd( aLogDds, PADR(OemToAnsi(STR0065), 25) + " " + PADR(aHorario[nZ,2], 77) + " " + PADR(If(nOpc = 5,OemToAnsi(STR0283),OemToAnsi(STR0265)), 46) )
							nContador++
						EndIf
					ElseIf nOpc == 5 .And. cStatMid != "-1" .And. !(cOpcRJE == "E" .And. cStatMid == "4")
						If !( lGravou := fExcluiRJE( nRecRJE ) )
							cMsgLog := OemToAnsi(STR0254)//"Ocorreu um erro na exclusão do registro na tabela RJE"
							Aadd(aErroTur, OemToAnsi(cMsgLog))
						Else
							aAdd( aLogDds, PADR(OemToAnsi(STR0065), 25) + " " + PADR(aHorario[nZ,2], 77) + " " + PADR(OemToAnsi(STR0282), 33) )
							nContador++
						EndIf
					Else
						aAdd( aLogDds, PADR(OemToAnsi(STR0065), 25) + " " + PADR(aHorario[nZ,2], 77) + " " + PADR(OemToAnsi(STR0261), 26) )
						aAdd( aLogDds, OemToAnsi(STR0281))//"Não será possível a inclusão do registro. Existe um evento S-1050 na base, com o mesmo Codigo de turno e transmitido com sucesso"
						nContErr++
					EndIf
				Else
					aAdd( aLogDds, PADR(OemToAnsi(STR0065), 25) + " " + PADR(aHorario[nZ,2], 77) + " " + PADR(OemToAnsi(STR0261), 26) )
					aAdd( aLogDds, OemToAnsi(cMsgRJE) )
					nContErr++
				EndIf
			Else
				aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S1050")

			 	If Len( aErros ) <= 0
					//--------------------------------------------------------------
					//| Os erros serão impressos alinhados | Tamanho cabecalho: 132
					//| Colunas: Eventos (25+1) | Item/Registro (77+1) | Status (26)
					//| PADR("Eventos", 25) + " " + PADR("ITEM/REGISTRO", 77) + " " + PADR("STATUS", 26))
					//------------------------------------------------------------------------------------------------------------------------------------
			 		//Horário/Turno             Descricao Turno                                                                Enviada ao TAF com sucesso.
					If lMiddleware
						aAdd(aLogDds, PADR(OemToAnsi(STR0065), 20) + " " + PADR(cFuncao, 65) + " " + PADR(OemToAnsi(STR0241), 40))
					Else
						aAdd(aLogDds, PADR(OemToAnsi(STR0065), 25) + " " + PADR(cFuncao, 77) + " " + PADR(OemToAnsi(STR0030), 26))
					EndIf
			 		nContador++
				Else
					aConcat := {}

					//Le o erro e quebra num array de acordo com a quantidade de enter
					aConcat := StrTokArr(aErros[1], chr(13)+chr(10))

					//------------------------------------------------------------------------------------------------------------------------------------
					//Rubrica                   XYZABC1230                                                                    Nâo Enviada ao TAF         "
					//Comentario do erro
					//
					//------------------------------------------------------------------------------------------------------------------------------------
					aAdd( aLogDds, PADR(OemToAnsi(STR0065), 25) + " " + PADR(aHorario[nZ,2], 77) + " " + PADR(OemToAnsi(STR0029), 26) )

					If( Len(aConcat) == 1 )
						aAdd( aLogDds, aConcat[1] )
					ElseIf( Len(aConcat) > 1 )

						//Atribui o erro no aLogDds para impressão em tela
						For nX := 2 To len(aConcat) step 2
							aAdd( aLogDds, aConcat[nX] )
						Next

					EndIf
					aAdd(aLogDds, "") //Pula Linha
					nContErr++
				EndIf
			Endif
		Else
			If !lMiddleware
				aAdd( aLogDds, PADR(OemToAnsi(STR0065), 25) + " " + PADR(aHorario[nZ,2], 77) + " " + PADR(OemToAnsi(STR0029), 26) )
			Else
				aAdd( aLogDds, PADR(OemToAnsi(STR0065), 25) + " " + PADR(aHorario[nZ,2], 77) + " " + PADR(OemToAnsi(STR0261), 26) )
			Endif
			aAdd( aLogDds, OemToAnsi(STR0224) )//"Não é possível a inclusão do registro. Verifique se a duração da jornada, duração do intervalo e/ou descrição do turno estão preenchidos."
			nContErr++
		EndIf
	Else //Listagem
		//Verificacao da condicao do registro para DBF
		If Empty(cMenIni)
			cMenIni := OemToAnsi(STR0145) //##"Inconsistências de Rúbricas:"
			aAdd(aLogProc, cMenIni)
			aAdd(aLogProc, "")
			aAdd(aLogProc, "")
		EndIf

		fG17VSR6(aHorario[nZ], @aLogProc, @aTurnoAux) // se voltar false significa inconsistencia

	Endif
	//Incrementa regua
	IncProc(OemToAnsi(STR0069) + " " + aHorario[nZ,2]) //##"Gerando o registro de: "
Next nZ

Return

/*--------------------------------------------------*//*--------------------------------------------------*/
/*/{Protheus.doc} fCargSQ3
Realiza carga das tabelas de cargos para o TAF
@author Claudinei Soares
@since 16/04/2018
@version P12
@return Nil

@example fCargSQ3()
/*/

Function fCargSQ3( cMesAno, nOpcA, aLogProc, aDados, aFilInTaf, cVersEnvio, lCargo, lTabSQ3, cFiltro)

Local cFuncao		:= ""
Local cDescr		:= ""
Local cCodCBO		:= ""
Local cMsgLog		:= ""
Local cMenIni   	:= ""
Local cXml			:= ""
Local cLayout		:= ""
Local cFilEnv		:= ""
Local aArea		 	:= GetArea()
Local aAreaSQ3  	:= SQ3->(GetArea())
Local cAliasSQ3		:= GetNextAlias()
Local lContinua		:= .T.
Local lSemFilial	:= .F.
Local cFilCort		:= ""
Local cAnoMes 		:= ""
Local cCpo			:= ""
Local nOpcAP 		:= 1
Local aArrayP 		:= {}
Local aCposVal		:= {}
Local aConcat 		:= {}
Local nX			:= 0
Local aErros		:= {}
Local nHrInicio
Local nContador		:= 0
Local nContErr		:= 0
Local nHrFim
Local cEventDesc 	:= (OemToAnsi(STR0014)+ " " + OemToAnsi(STR0190))
Local cFunText		:= ""
Local nOpcAux		:= 0
Local cChave		:= ""
Local cStatus		:= ""
Local cEvento		:= ""
Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Local cFilQry		:= "%%"

Default cMesAno 	:= ""
Default nOpcA 		:= 1
Default aFilInTaf 	:= {}
Default cVersEnvio	:= "2.2"
Default lCargo		:= .F.
Default lTabSQ3		:= .T.
Default cFiltro		:= ""

cAnoMes			:= substr(cMesAno,3,4) + "-" + substr(cMesAno,1,2)
nOpcAP			:= nOpcA
aArrayFilP		:= aFilInTaf

cFilEnv		:= aArrayFilP[2]

//Definindo o nOpc do processo
If nOpcAP == 1
	nOpcAux := 3
ElseIf nOpcAP == 5
	nOpcAux := 5
End

//Tratamento de compartilhamento da tabela SQ3
If FWModeAccess("SQ3", 1) == "C" .AND. FWModeAccess("SQ3", 2) == "C" .AND. FWModeAccess("SQ3", 3) == "C" //SQ3 compartilhada
	lSemFilial := .T.
EndIf
DBSELECTAREA("SQ3")
If !SQ3->(ColumnPos( 'Q3_CBO' )) > 0
	aAdd( aDados, cEventDesc + Space(13) + OemToAnsi(STR0223) + Space(73) + OemToAnsi(STR0029) ) //Evento: S-1030 Todos Não enviado ao TAF
	aAdd( aDados, OemToAnsi(STR0222) ) //"Não foram encontrados os novos campos para o eSocial do cadastro de Cargos, como por exemplo o CBO, favor executar o UPDDISTR."
	aAdd( aDados, "" )
	RestArea(aAreaSQ3)
	RestArea(aArea)
	Return()
Else
	cCpo:= "%Q3_FILIAL, Q3_CARGO, Q3_DESCSUM, Q3_CBO, Q3_ACUM, Q3_CTESP, Q3_DEDEXC, Q3_LEI, Q3_DTLEI, Q3_SIT%"
EndIf

If !Empty(cFilEnv)

	If !Empty(cFiltro)
		cFilQry 	:= "% " + GPEParSQL(fPrepExpIn(cFiltro)) + " AND %"
	EndIf

    //Inicio de Operação
    nHrInicio := Seconds()

	//Busca informacoes SQ3 - Cargos
	//Query para buscar informacoes de processos e varas
	BeginSql alias cAliasSQ3
		SELECT
			%exp:cCpo%
		FROM
			%table:SQ3% SQ3
		WHERE
			%exp:cFilQry% SQ3.%notDel%
		ORDER BY
			SQ3.Q3_FILIAL, SQ3.Q3_CARGO
	EndSql

	dbSelectArea(cAliasSQ3)

	//Posiciona no inicio do arquivo
	(cAliasSQ3)->(dbGoTop())

	//Inicializa regua de processamento
	ProcRegua((cAliasSQ3)->(RecCount()))

	While (cAliasSQ3)->(!EOF())

		//Verifica filiais
		If lSemFilial //Compartilhada
			lContinua := .T.
		ElseIf aScan(aArrayFilP[3], {|X| FwxFilial("SQ3", X) == (cAliasSQ3)->Q3_FILIAL}) > 0 //Exclusiva
			lContinua := .T.
		Else
			lContinua := .F.
		EndIf

		If lContinua .AND. nOpcAP == 5
			cEvento := "S-1030"

			//Montando as variaveis utilizadas na chave de pesquisa
			cFuncao := IIf(lSemFilial, AllTrim( (cAliasSQ3)->Q3_CARGO ), AllTrim( (cAliasSQ3)->Q3_FILIAL + (cAliasSQ3)->Q3_CARGO ) )

			If !lMiddleware
				cChave  := cFuncao + ";" + cMesAno
				fVerExtemp(cEvento, cChave, nOpcAux, @cStatus, lContinua, cFilEnv, @aErros)
			Else
				cChave := StrTran(cEvento, "-", "") + cFuncao
				GetInfRJE(4, cChave, @cStatus)
			EndIf

			If(cStatus $ "2|4") .Or. (lMiddleware .And. !Empty(cStatus))
				lContinua := .T.
			Else
				lContinua := .F.
			EndIf
		EndIf


		If lContinua
			If nOpcAP == 1 .OR. nOpcAP == 5 //Carga
				//CBO não informado
				If Empty((cAliasSQ3)->Q3_CBO) .AND. nOpcAP == 1
					//------------------------------------------------------------------------------------------------------------------------------------
					//Cargo                     XYZABC1230                                                                    Nâo Enviada ao TAF         "
					//Cargo Comissionado        XYZABC1230                                                                    Nâo Enviada ao TAF         "
					//Comentario do erro
					//
					//------------------------------------------------------------------------------------------------------------------------------------
					If lMiddleware
						aAdd(aDados, PADR(cEventDesc, 20) + " " + PADR((cAliasSQ3)->Q3_CARGO, 65 ) + " " + PADR(OemToAnsi(STR0242), 40)) //Funcao XYZ - Não enviado ao TAF
					Else
						aAdd(aDados, PADR(cEventDesc, 25) + " " + PADR((cAliasSQ3)->Q3_CARGO, 77 ) + " " + PADR(OemToAnsi(STR0029), 26)) //Funcao XYZ - Não enviado ao TAF
					EndIf
					aAdd( aDados, OemToAnsi(STR0038) ) //#"CBO não informado."
					aAdd( aDados, "" )
					lContinua := .F.
					nContErr++
				EndIf

				If lContinua
					//Valida os campos {Q3_ACUM,  Q3_CTESP, Q3_DEDEXC, Q3_LEI, Q3_DTLEI, Q3_SIT} se um deles estiver preenchido os outros também deverão estar.
					cFunText := ""
					If (!Empty((cAliasSQ3)->Q3_ACUM) .And. !Empty((cAliasSQ3)->Q3_CTESP) .And. !Empty((cAliasSQ3)->Q3_DEDEXC) .And. !Empty((cAliasSQ3)->Q3_LEI) .And. !Empty((cAliasSQ3)->Q3_DTLEI) .And. !Empty((cAliasSQ3)->Q3_SIT) .Or.;
					   (Empty((cAliasSQ3)->Q3_ACUM) .And. Empty((cAliasSQ3)->Q3_CTESP) .And. Empty((cAliasSQ3)->Q3_DEDEXC) .And. Empty((cAliasSQ3)->Q3_LEI) .And. Empty((cAliasSQ3)->Q3_DTLEI) .And. Empty((cAliasSQ3)->Q3_SIT)))
						lContinua := .T.
					Else
						If Empty((cAliasSQ3)->Q3_ACUM)
						    cFunText := cFunText + Iif(Len(cFunText)>0,", ","") + "Q3_ACUM"
						EndIf
						If Empty((cAliasSQ3)->Q3_CTESP)
						    cFunText := cFunText + Iif(Len(cFunText)>0,", ","") + "Q3_CTESP"
						EndIf
						If Empty((cAliasSQ3)->Q3_DEDEXC)
						    cFunText := cFunText + Iif(Len(cFunText)>0,", ","") + "Q3_DEDEXC"
						EndIf
						If Empty((cAliasSQ3)->Q3_LEI)
						    cFunText := cFunText + Iif(Len(cFunText)>0,", ","") + "Q3_LEI"
						EndIf
						If Empty((cAliasSQ3)->Q3_DTLEI)
						    cFunText := cFunText + Iif(Len(cFunText)>0,", ","") + "Q3_DTLEI"
						EndIf
						If Empty((cAliasSQ3)->Q3_SIT)
						    cFunText := cFunText + Iif(Len(cFunText)>0,", ","") + "Q3_SIT"
						EndIf

						If lMiddleware
							aAdd(aDados, PADR(cEventDesc, 20) + " " + PADR((cAliasSQ3)->Q3_CARGO, 65 ) + " " + PADR(OemToAnsi(STR0242), 40)) //Funcao XYZ - Não enviado ao TAF
						Else
							aAdd(aDados, PADR(cEventDesc, 25) + " " + PADR((cAliasSQ3)->Q3_CARGO, 77 ) + " " + PADR(OemToAnsi(STR0029), 26)) //Funcao XYZ - Não enviado ao TAF
						EndIf

						aAdd(aDados, cFunText + " - Mot.: " + OemToAnsi(STR0184))
						aAdd( aDados, "" )

						lContinua := .F.
						nContErr++
					EndIf
				EndIf

				//Se tiver o CBO da função, realiza a integração
				If lContinua
					Begin Transaction
						//Tratamento para Cargo
						cFuncao := IIf(lSemFilial,ALLTRIM((cAliasSQ3)->Q3_CARGO), ALLTRIM((cAliasSQ3)->Q3_FILIAL+(cAliasSQ3)->Q3_CARGO))
						aCposVal		:= {}
						aAdd(aCposVal,(cAliasSQ3)->Q3_ACUM)
						aAdd(aCposVal,(cAliasSQ3)->Q3_CTESP)
						aAdd(aCposVal,(cAliasSQ3)->Q3_DEDEXC)
						aAdd(aCposVal,(cAliasSQ3)->Q3_LEI)
						aAdd(aCposVal,(cAliasSQ3)->Q3_DTLEI)
						aAdd(aCposVal,(cAliasSQ3)->Q3_SIT)

						cDescr  := (cAliasSQ3)->Q3_DESCSUM
						cCodCBO := (cAliasSQ3)->Q3_CBO

						lRet := fCarrFun(cFuncao, cDescr, cCodCBO, nOpcAux, cAnoMes, @aErros, cFilEnv ,aCposVal, lCargo,,,, lTabSQ3)

					 	If Len( aErros ) <= 0
							//--------------------------------------------------------------
							//| Os erros serão impressos alinhados | Tamanho cabecalho: 132
							//| Colunas: Eventos (25+1) | Item/Registro (77+1) | Status (26)
							//| PADR("Eventos", 25) + " " + PADR("ITEM/REGISTRO", 77) + " " + PADR("STATUS", 26))
							//------------------------------------------------------------------------------------------------------------------------------------
							//Cargo                     XYZABC1230                                                                    Enviada ao TAF com sucesso."
							If lMiddleware
								aAdd(aDados, PADR(cEventDesc, 20) + " " + PADR(cFuncao, 65) + " " + PADR(OemToAnsi(STR0241), 40))
							Else
								aAdd(aDados, PADR(cEventDesc, 25) + " " + PADR(cFuncao, 77) + " " + PADR(OemToAnsi(STR0030), 26))
							EndIf

							nContador++
						Else
							aConcat := {}

							//Le o erro e quebra num array de acordo com a quantidade de enter
							aConcat := StrTokArr(aErros[1], chr(13)+chr(10))

							//------------------------------------------------------------------------------------------------------------------------------------
							//Cargo                     XYZABC1230                                                                    Nâo Enviada ao TAF         "
							//Comentario do erro
							//Cargo Comissionado        XYZABC1230                                                                    Nâo Enviada ao TAF         "
							//
							//------------------------------------------------------------------------------------------------------------------------------------
							If lMiddleware
								aAdd(aDados, PADR(cEventDesc, 20) + " " + PADR((cAliasSQ3)->Q3_CARGO, 65 ) + " " + PADR(OemToAnsi(STR0242), 40)) //Funcao XYZ - Não enviado ao TAF
							Else
								aAdd(aDados, PADR(cEventDesc, 25) + " " + PADR((cAliasSQ3)->Q3_CARGO, 77 ) + " " + PADR(OemToAnsi(STR0029), 26)) //Funcao XYZ - Não enviado ao TAF
							EndIf

							If( Len(aConcat) == 1 )
								aAdd( aDados, aConcat[1] )
							ElseIf( Len(aConcat) > 1 )

						   	//Atribui o erro no aDados para impressão em tela
								For nX := 2 To len(aConcat) step 2
								  	aAdd( aDados, aConcat[nX] )
								Next
							EndIf
							nContErr++
							aAdd(aDados, "")
						EndIf

				   	//Incrementa regua
						IncProc(OemToAnsi(STR0069) + " " + cFuncao)

					End Transaction
				Endif
			Else //Impressao

				If Empty((cAliasSQ3)->Q3_CBO)

					If Empty(cMenIni)
						cMenIni := OemToAnsi(STR0200) + cEventDesc + OemToAnsi(STR0201) //##"Inconsistências de XXXXXXXXXXXX - Os campos abaixo estão vazios e são de preenchimento obrigatórios:"
						aAdd(aLogProc, cMenIni)
						aAdd(aLogProc, "")
						aAdd(aLogProc, "")
					EndIf

					aAdd(aLogProc, cEventDesc + ": " + OemToAnsi((cAliasSQ3)->Q3_FILIAL)+OemToAnsi((cAliasSQ3)->Q3_CARGO) + " -> " + OemToAnsi((cAliasSQ3)->Q3_DESCSUM)) //##"Funcao "

					If SX3->(MsSeek("Q3_CBO"))
						aAdd(aLogProc, AllTrim(SX3->X3_CAMPO) + " - " + OemToAnsi(STR0038))
					EndIf

					aAdd(aLogProc, "")
				EndIf

				//Incrementa regua
				IncProc(OemToAnsi(STR0069) + " " + (cAliasSQ3)->Q3_CARGO + " " + (cAliasSQ3)->Q3_DESCSUM) //##"Gerando o registro de: "
	 		EndIf

		EndIf

		(cAliasSQ3)->(dbSkip())
		aErros := {}
	EndDo
Else
	//Grava log
	//cMsgLog := OemToAnsi(STR0040) + " - " + OemToAnsi(STR0032) + OemToAnsi(aIncons[1]) //##"Função" ##"Falha no envio ao TAF: "
	//fGp23GrLog(cFilEnv, "S1040", cMsgLog, "2")
EndIf

//----------------------
//| Monta rodapé de LOG
//----------------------
If nOpcAP == 1

	aAdd(aDados,"")
	aAdd(aDados,(OemToAnsi(STR0111)+" "+ OemToAnsi(STR0110) + " " + OemToAnsi(STR0039) ))	//"Resumo" ###"Carga Inicial" Rubrica
	aAdd(aDados, OemToAnsi(STR0009)+": " +  SecsToTime(nHrInicio))							//Inicio Processamento: A
	nHrFim 	:= SecsToTime(Seconds())
	aAdd(aDados,+OemToAnsi(STR0010)+":    " + nHrFim)											//Fim Processamento:    A
	aAdd(aDados,"")
	aAdd(aDados,OemToAnsi(STR0077)+": " + SecsToTime(Seconds() - nHrInicio))		//Duracao do Processamento
	aAdd(aDados,Iif(lMiddleware, OemToAnsi(STR0243), OemToAnsi(STR0078))+": "+ ALLTRIM(STR(nContador)))						//Quantidade Registro(s) enviado(s) ao TAF
	aAdd(aDados,Iif(lMiddleware, OemToAnsi(STR0244), OemToAnsi(STR0151))+": "+ ALLTRIM(STR(nContErr)))						//Quantidade Registros Não Enviados ao TAF
	aAdd(aDados,"")
	aAdd(aDados,"")

EndIf

//Fecha alias em uso
If (Select(cAliasSQ3) > 0)
	(cAliasSQ3)->(dbCloseArea())
EndIf

RestArea(aAreaSQ3)
RestArea(aArea)

Return()
