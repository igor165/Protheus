#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM023.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPEM023A ³ Autor ³ Christiane Vieira                           ³ Data ³ 13/11/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de Envio de Eventos - Rubricas                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM023A()                                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista     ³ Data     ³ FNC/Requisito  ³ Chamado ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Christiane V.³01/12/2015|                ³TTHNFM   ³Integracao do registro S-1010 com o TAF    ³±±
±±³Marcia Moura ³18/05/2016|                ³TVEJZM   ³Adaptacao leiaute 2.2                      ³±±
±±³Marcos Cout  ³02/05/2017|DRHESOCP-214    ³         ³Adaptação do leiaute do eSocial            ³±±
±±³             ³          |                ³         ³Manutenção na tabela S-1010                ³±±
±±³Marcia Moura³02/06/2017 ³DRHESOCP-316    ³         ³Pacote para Atendimento                    ³±±
±±³Marcos Cout ³12/06/2017 ³DRHESOCP-389    ³         ³War Room + Merge                           ³±±
±±³            ³           ³                ³         ³Subir fontes para release superior (17)    ³±±
±±³Oswaldo L   ³04/07/17   ³DRHESOCP-552    ³         ³Remover tratativas de campos que passaram  ³±±
±±³            ³           ³                ³         ³a ser "nao utilizados" no SX3              ³±±
±±³Marcia Moura³04/07/2017 ³DRHESOCP-550    ³         ³Correcao da Relatorio de Inconsistencias   ³±±
±±³Marcos Cout ³28/07/2017 ³DRHESOCP-703    ³         ³Realizar ajustes estéticos e padronizados  ³±±
±±³            ³           ³                ³         ³no relatório de Carga Inicial dos Eventos  ³±±
±±³Oswaldo L   ³03/08/2017 ³DRHESOCP-755    ³         ³Merge versão 11.80 e 12.1.17 e-social      ³±±
±±³Eduardo V   ³11/08/2017 ³DRHESOCP-781    ³         ³Correções de erros apontadas a issue 592   ³±±
±±³Eduardo Vic ³17/08/2017 ³DRHESOCP-861    ³         ³Desenvolvimento de funcionalidade de envio ³±±
±±³            ³           ³                ³         ³extemporaneo na inclusao\exclusao\alteracao³±±
±±|Claudinei S.|30/08/2017|DRHESOCP-727               |Se estiver no leiaue 2.3 a TAG <fatorRubr> |±±
±±|            |          |                           |não será enviada no XML, evento S-1010.    |±±
±±³Marcos Cout |14/09/2017|DRHESOCP-1018    |         |Realizando o ajuste necessário para que o  ³±±
±±³            |          |                 |         |sistema realize a validação do layout dispo³±±
±±³            |          |                 |         |nível no ambiente para fazer a integração  ³±±
±±³            |          |                 |         |entre o SIGAGPE e o SIGATAF                ³±±
±±³Eduardo Vict|09/10/2017|DRHESOCP-1526    |         |Inc. de envio do S1010 Extemporâneo esocial³±±
±±³Marcos Cout |01/11/2017|DRHESOCP-1652    |         |Realizado ajustes na tag <IdeTabRubr> qnd a³±±
±±³            |          |                 |         |tabela é compartilhada e cadastro d empresa³±±
±±³            |          |                 |         |é de 1 x 1 ou de 1 x N                     ³±±
±±³Marcos Cout ³23/11/2017³  DRHESOCP-2119  ³         ³Retirar as TAGS do XML da carga de rubricas³±±
±±³            ³          ³                 ³         ³<repDSR>, <rep13>, <repFerias>, <repAviso >³±±
±±³            ³          ³                 ³         ³<codSusp> ideProcessoSIND e ideProcessoFGTS³±±
±±³            ³          ³                 ³         ³Corrigido erro na var retorno da integração³±±
±±³Eduardo Vic ³27/12/2017³  DRHESOCP-2456  ³         ³Inclusão de novos campos na query,para tra-³±±
±±³            ³          ³                 ³         ³tativa de campos de verbas em novas valida-³±±
±±³            ³          ³                 ³         ³ções                                       ³±±
±±³Eduardo V.  |02/01/2018³  DRHESOCP-2646  ³         ³Inclusão de consistência de tabelas entre  ³±±
±±³            |          ³                 ³         ³TAF e GPE                                  ³±±
±±³Marcos Cout |05/01/2018³  DRHESOCP-2679  ³         ³Realizando ajustes no tamanho do LOG do    ³±±
±±³            |          ³                 ³         ³log de consistência da carga de rubrica    ³±±
±±³Marcos Cout |17/01/2018³ DRHESOCP-2490   ³         ³Criando os eventos extemporâneos do even   ³±±
±±³            |          ³                 ³         ³ _to S-1035 - Carreiras Públicas           ³±±
±±|Marcos Cout.³23/02/2018³DRHESOCP-3059              ³Adicionar na carga inicial a opção         ³±±
±±|            ³          ³                           ³"Exclusão em Lote" para remover do RET os  ³±±
±±|            ³          ³                           ³eventos já integrado                       ³±±
±±|Marcos Cout.³28/02/2018³DRHESOCP-3307              ³Realizando geração da exclusao em lote para³±±
±±|            ³          ³                           ³os demais eventos de Carga Inicial         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fCargRubr ³ Autor ³ Alessandro Santos     ³ Data ³03/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Realiza carga das tabelas de rubricas para o TAF            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCargRubr()                                          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function fCargRubr(cMesAno, nOpcA, aLogProc, dDataRef, aDados, aFilInTaf, cVersEnvio, cFiltro)
Local aArea		 	:= GetArea()
Local aAreaSRV		:= SRV->(GetArea())
Local cAliasSRV  	:= GetNextAlias()
Local aIncons    	:= {}
Local lSemFilial 	:= .F.
Local lGeraCod		:= .F.
Local lConsolid		:= aFilInTaf[1]
Local cFilEnv		:= aFilInTaf[2]
Local cDescRub		:= ""
Local cREPDTE	 	:= ""
Local cREPFER	 	:= ""
Local cREPREC	 	:= ""
Local cREPDSR	 	:= ""
Local cMenIni   	:= ""
Local cMsgLog		:= ""
Local cXml			:= ""
Local cLayout		:= ""
Local nFatRub	 	:= 0
Local nI			:= 0
Local aErros 	 	:= {}
Local lContinua 	:= .T.
Local cAnoMes		:= Substr(cMesAno,3,4) + Substr(cMesAno,1,2)
Local aAuxErro		:= {}
Local cConcat		:= ""
Local nX 			:= 0
Local aAuxGeral		:= {}
Local nHrInicio
Local nHrFim
Local nReg			:= 0
Local aThreads		:= {}
Local cFilQry		:= "%%"

Private lMiddleware		:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Private nContador		:= 0
Private nContErr		:= 0

Default cVersEnvio := "2.2"
Default cFiltro 	:= ""

If !Empty(cFiltro)
    cFilQry 	:= GPEParSQL(fPrepExpIn(cFiltro))
    cFilQry 	:= "%"+cFilQry + " AND %"
EndIf

If !Empty(cFilEnv)
	//Hora Inicial
	nHrInicio := Seconds()

	//Busca informacoes SRV - Verbas
	#IFDEF TOP

			BeginSql alias cAliasSRV
				SELECT
					R_E_C_N_O_, RV_FILIAL
				FROM
					%table:SRV% SRV
				WHERE
					%exp:cFilQry% SRV.%notDel%
				ORDER BY
					SRV.R_E_C_N_O_
			EndSql

	#ELSE
		cAliasSRV := "SRV"
		dbSelectArea(cAliasSRV)
	#ENDIF

	//Posiciona no inicio do arquivo
	(cAliasSRV)->(dbGoTop())

	//Tratamento de compartilhamento da tabela SRV
	If Empty((cAliasSRV)->RV_FILIAL)
		lSemFilial := .T.
	Else
		lGeraCod   := .T.
	EndIf

	While (cAliasSRV)->(!EOF())
		Aadd(aThreads,(cAliasSRV)->R_E_C_N_O_)
		(cAliasSRV)->(DbSkip())
	EndDo

	If (Select(cAliasSRV) > 0)
		(cAliasSRV)->(dbCloseArea())
	EndIf
	If Len(aThreads) > 0
		nReg := Len(aThreads)
		//Inicializa regua de processamento
		If !IsBlind()
			ProcRegua(nReg)
		EndIf
		fRubThd(aFilInTaf,@aDados,aThreads,lSemFilial,lGeraCod,cMesAno,nOpcA,dDataRef,cVersEnvio, cFiltro)
	EndIf

	//----------------------
	//| Monta rodapé de LOG
	//----------------------
	If nOpcA == 1

		aAdd(aDados,"")
		aAdd(aDados,(OemToAnsi(STR0111)+" "+ OemToAnsi(STR0110) + " " + OemToAnsi(STR0126) ))	//"Resumo" ###"Carga Inicial" Rubrica
		aAdd(aDados, OemToAnsi(STR0009)+": " +  SecsToTime(nHrInicio))							//Inicio Processamento: A
		nHrFim 	:= SecsToTime(Seconds())
		aAdd(aDados,+OemToAnsi(STR0010)+":    " + nHrFim)											//Fim Processamento:    A
		aAdd(aDados,"")
		aAdd(aDados,OemToAnsi(STR0077)+": " + SecsToTime(Seconds() - nHrInicio))		//Duracao do Processamento
		aAdd(aDados, Iif( lMiddleware, OemToAnsi(STR0243), OemToAnsi(STR0078) ) + ": " + ALLTRIM(STR(nContador)) )	//Quantidade Registro(s) enviado(s) ao TAF # Middleware
		aAdd(aDados, Iif( lMiddleware, OemToAnsi(STR0244), OemToAnsi(STR0151) ) + ": " + ALLTRIM(STR(nContErr)) )	//Quantidade Registros Não Enviados ao TAF # Middleware
		aAdd(aDados,"")
		aAdd(aDados,"")
	EndIf


Else
	aAdd(aDados, OemToAnsi(STR0126) + " - " + OemToAnsi(STR0032) + OemToAnsi(aIncons[1]))

EndIf

//Fecha alias em uso
#IFDEF TOP
	If (Select(cAliasSRV) > 0)
		(cAliasSRV)->(dbCloseArea())
	EndIf
#ENDIF

RestArea(aAreaSRV)
RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCarrRub    ºAutor  ³Christiane Vieira   º Data ³  16/11/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega Verbas                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023-                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fCarrRub(cAliasSRV, cCodRubr, cAnoMes, lGeraCod, cOper,aErros,cFilEnv,oMdl, cVersEnvio, cRetXML, cId, cGpeAmbe, lTemRJG, lRotRJG, oGrid)
Local cXml 		:= ""
Local cDescAux	:= ""
Local cDescRub	:= ""
Local cREPDSR	:= ""
Local cREPDTE	:= ""
Local cREPFER	:= ""
Local cREPREC	:= ""
Local cINDTRB	:= ""
Local cNATUREZ	:= ""
Local cINCCP	:= ""
Local cINCIRF	:= ""
Local cINCFGTS	:= ""
Local cINCSIND	:= ""
Local cINCOP	:= ""
Local cTETOP	:= ""
Local nFatRub	:= 0
Local lRet		:= .T.
Local cIdTbRub	:= ""
Local lAdmPubl	:= .F.
Local cVersMW	:= ""
Local lIncCP	:= .F.
Local lIncIRRF	:= .F.
Local lIncFGTS	:= .F.
Local lIncSind	:= .F.
Local aProcRJG	:= {}
Local nProcRJG	:= 0
Local nCont		:= 0
Local aInfos	:= {}
Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

Default cOper 		:= "3"
Default cFilEnv		:= ""
Default cAliasSRV	:= ""
Default oMdl		:= nil
Default aErros		:= {}
Default cVersEnvio	:= "2.2"
Default cAnoMes		:= LEFT(DTOS(DDATABASE),6)
Default cRetXML		:= ""
Default cId			:= ""
Default lTemRJG		:= .F.
Default lRotRJG		:= .F.
Default oGrid		:= Nil

	If oMdl == nil
		cDescAux	:= IIf (!Empty((cAliasSRV)->RV_DESCDET), (cAliasSRV)->RV_DESCDET, (cAliasSRV)->RV_DESC)
		cDescRub	:= fSubst(cDescAux)
		cREPDSR		:= (cAliasSRV)->RV_DSRHE
		cREPDTE		:= IIF((cAliasSRV)->RV_MED13 $ "N\"+Space(TamSx3("RV_MED13")[1])+"" ,"N","S")
		cREPFER		:= IIF((cAliasSRV)->RV_MEDFER $ "N\"+Space(TamSx3("RV_MEDFER")[1])+"" ,"N","S")
		cREPREC		:= IIF((cAliasSRV)->RV_MEDAVI $ "N\"+Space(TamSx3("RV_MEDAVI")[1])+"" ,"N","S")
		cNATUREZ	:= (cAliasSRV)->RV_NATUREZ
		cINCCP		:= (cAliasSRV)->RV_INCCP
		cINCIRF		:= (cAliasSRV)->RV_INCIRF
		cINCFGTS	:= (cAliasSRV)->RV_INCFGTS
		cINCSIND	:= (cAliasSRV)->RV_INCSIND
		If (cAliasSRV)->RV_PERC > 100
			nFatRub := (cAliasSRV)->RV_PERC - 100
		Endif
		If cVersEnvio >= '9.0'
			cINCOP	:= (cAliasSRV)->RV_INCOP
			cTETOP	:= (cAliasSRV)->RV_TETOP
		EndIf
	Else
		cDescAux	:= IIf (!Empty(oMdl:GetValue("RV_DESCDET")), oMdl:GetValue("RV_DESCDET"), oMdl:GetValue("RV_DESC"))
		cDescRub	:= fSubst(cDescAux)
		cREPDSR		:= oMdl:GetValue("RV_DSRHE")
		cREPDTE		:= IIF(oMdl:GetValue("RV_MED13") $ "N \"+Space(TamSx3("RV_MED13")[1])+"" ,"N","S")
		cREPFER		:= IIF(oMdl:GetValue("RV_MEDFER") $ "N \"+Space(TamSx3("RV_MEDFER")[1])+"" ,"N","S")
		cREPREC		:= IIF(oMdl:GetValue("RV_MEDAVI") $ "N \"+Space(TamSx3("RV_MEDAVI")[1])+"" ,"N","S")
		cNATUREZ	:= oMdl:GetValue("RV_NATUREZ")
		cINCCP		:= oMdl:GetValue("RV_INCCP")
		cINCIRF		:= oMdl:GetValue("RV_INCIRF")
		cINCFGTS	:= oMdl:GetValue("RV_INCFGTS")
		cINCSIND	:= oMdl:GetValue("RV_INCSIND")
		If oMdl:GetValue("RV_PERC") > 100
			nFatRub := oMdl:GetValue("RV_PERC")- 100
		Endif
		If cVersEnvio >= '9.0'
			cINCOP	:= oMdl:GetValue("RV_INCOP")
			cTETOP	:= oMdl:GetValue("RV_TETOP")
		EndIf
	EndIf

	If !Empty(cAliasSRV)
		cINDTRB:= (cAliasSRV)->RV_TIPOCOD
	Else
		cINDTRB:= oMdl:GetValue("RV_TIPOCOD")
	EndIf

	If !(cINDTRB	$ "1/2/3")
		cINDTRB	:= "4"
	EndIf

	//------------------
	//| Lógica lGeraCod
	//| .T. -> Exclusiva | .F. -> Compartilhada
	//------------------------------------------
	If lGeraCod
		cIdTbRub := Iif(!Empty(cAliasSRV),(cAliasSRV)->RV_FILIAL , IIF(Empty(oMdl:GetValue("RV_FILIAL")), xFilial("SRV"),oMdl:GetValue("RV_FILIAL")) )
	Else
		If cVersEnvio >= "2.3"
			cIdTbRub := cEmpAnt
		Else
			cIdTbRub := ""
		EndIf
	Endif

	if lMiddleware .And. ChkFile("RJE")
		cIdTbRub := fGetIdRJF( Iif(!Empty(cAliasSRV), (cAliasSRV)->RV_FILIAL, xFilial("SRV")), cIdTbRub, .T. )
		If Empty(cIdTbRub)
			aAdd(aErros, OemToAnsi(STR0266))//"Não foi possível encontrar/gerar um identificador de tabela de rubricas válido. A atualização do evento S-1010 foi cancelada.")
			Return .F.
		EndIf
		fVersEsoc( "S1010", .T., /*aRetGPE*/, /*aRetTAF*/, Nil, Nil, @cVersMW, , @cGpeAmbe )
		aInfos	:= fXMLInfos(cAnoMes)
		cAnoMes	:= SubStr(cAnoMes, 1, 4) + "-" + SubStr(cAnoMes, 5, 2)

		if len(aInfos) >= 4
			cId 	:= aInfos[3]
			cTpInsc := aInfos[1]
			cNrInsc := aInfos[2]
			lAdmPubl:= aInfos[4]
		Else
			cTpInsc  := ""
			lAdmPubl := .F.
			cNrInsc  := "0"
			cId		 := ""
		Endif

		cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtTabRubrica/v" + cVersMW + "'>"
		cXML += 	"<evtTabRubrica Id='" + cId + "'>"

		fXMLIdEve( @cXML, { Nil, Nil, Nil, Nil, cGpeAmbe, 1, "12" } )
		fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
	Else
		cXml += '<eSocial>'
		cXml += '	<evtTabRubrica>'
	Endif

	cXml += '		<infoRubrica>'

	If cOper == "3"
		cXml += '		<inclusao>'
	ElseIf cOper == "4"
		cXml += '		<alteracao>'
	Else
		cXml += '		<exclusao>'
	Endif

	cXml += '				<ideRubrica>'
	If !lMiddleware
		cXml += '					<codRubr>' + cCodRubr + '</codRubr>'
	Else
		cXml += '					<codRubr>' + Alltrim(cCodRubr) + '</codRubr>'
	Endif
	cXml += '					<ideTabRubr>' + cIdTbRub + '</ideTabRubr>'
	cXml += '					<iniValid>'	+ cAnoMes + '</iniValid>'
	If !lMIddleware
		cXml += '					<fimValid>'	+ "" + '</fimValid>'
	Endif
	cXml += '				</ideRubrica>'

	If cOper <> "5"
		If lTemRJG
			lIncCP		:= (cINCCP $ "91/92/93/94/95/96/97/98")
			lIncIRRF	:= (Left(cINCIRF,1) == "9")
			lIncFGTS	:= (cINCFGTS == "91") .Or. (cVersEnvio >= '9.0' .And. cINCFGTS $ '91|92|93')
			lIncSind	:= (cVersEnvio < '9.0' .And. cINCSIND == "91")
			If (lIncCP .Or. lIncIRRF .Or. lIncFGTS .Or. lIncSind)
				If lRotRJG
					If oGrid:GetOperation() != MODEL_OPERATION_DELETE
						For nCont := 1 To oGrid:Length()
							oGrid:GoLine(nCont)
							If !oGrid:IsDeleted() .And. oGrid:GetValue("RJG_COMPET") <= StrTran(cAnoMes, "-")
								If aScan( aProcRJG, { |x| x[1]+x[2]+x[3]+x[4]+x[5] == oGrid:GetValue("RJG_TP")+oGrid:GetValue("RJG_TPPROC")+oGrid:GetValue("RJG_NRPROC")+oGrid:GetValue("RJG_EXTDEC")+oGrid:GetValue("RJG_CSUSP") } ) == 0
									aAdd( aProcRJG, { oGrid:GetValue("RJG_TP"), oGrid:GetValue("RJG_TPPROC"), oGrid:GetValue("RJG_NRPROC"), oGrid:GetValue("RJG_EXTDEC"), oGrid:GetValue("RJG_CSUSP") } )
								EndIf
							EndIf
						Next nCont
					EndIf
				Else
					If RJG->( dbSeek( xFilial("RJG", cFilAnt)+cCodRubr) )
						While RJG->( !EoF() ) .And. RJG->RJG_FILIAL+RJG->RJG_COD == xFilial("RJG", cFilAnt)+cCodRubr
							If RJG->RJG_COMPET <= StrTran(cAnoMes, "-")
								If aScan( aProcRJG, { |x| x[1]+x[2]+x[3]+x[4]+x[5] == RJG->RJG_TP+RJG->RJG_TPPROC+RJG->RJG_NRPROC+RJG->RJG_EXTDEC+RJG->RJG_CSUSP } ) == 0
									aAdd( aProcRJG, { RJG->RJG_TP, RJG->RJG_TPPROC, RJG->RJG_NRPROC, RJG->RJG_EXTDEC, RJG->RJG_CSUSP } )
								EndIf
							EndIf
							RJG->( dbSkip() )
						EndDo
					EndIf
				EndIf
			EndIf
		EndIf
		cXml += '			<dadosRubrica>'
		cXml += '				<dscRubr>'    + cDescRub  		+ '</dscRubr>'
		cXml += '				<natRubr>'    + cNATUREZ		+ '</natRubr>'
		cXml += '				<tpRubr>'     + cINDTRB   		+ '</tpRubr>'
		cXml += '				<codIncCP>'   + cINCCP			+ '</codIncCP>'
		cXml += '				<codIncIRRF>' + Alltrim(cINCIRF)+ '</codIncIRRF>'
		cXml += '				<codIncFGTS>' + cINCFGTS		+ '</codIncFGTS>'
		If !Empty(cINCOP)
			cXml += '			<codIncCPRP>' + cINCOP			+ '</codIncCPRP>'
		EndIf
		If !Empty(cTETOP)
			cXml += '			<tetoRemun>'  + cTETOP			+ '</tetoRemun>'
		EndIf
		If cVersEnvio < '9.0'
			cXml += '				<codIncSIND>' + cINCSIND   		+ '</codIncSIND>'
		EndIf

		If cVersEnvio < "2.4"
			cXml += '			<repDSR>'     + cREPDSR	+ '</repDSR>'
			cXml += '			<rep13>'      + cREPDTE  	+ '</rep13>'
			cXml += '			<repFerias>'  + cREPFER  	+ '</repFerias>'
			cXml += '			<repAviso>'   + cREPREC  	+ '</repAviso>'
		EndIf

		If cVersEnvio < "2.3"
			CXml += '			<fatorRubr>'  + Alltrim(Str(nFatRub))		+ '</fatorRubr>'
		Endif
		if !lMIddleware
			cXml += '				<observacao>' + "" + '</observacao>'
		ENDIF
		If lTemRJG .And. lIncCP
			For nProcRJG := 1 To Len(aProcRJG)
				If aProcRJG[nProcRJG, 1] == "1"
					cXml += '	<ideProcessoCP>'
					cXml += '		<tpProc>' + aProcRJG[nProcRJG, 2] + '</tpProc>'
					cXml += '		<nrProc>' + aProcRJG[nProcRJG, 3] + '</nrProc>'
					cXml += '		<extDecisao>' + aProcRJG[nProcRJG, 4] + '</extDecisao>'
					cXml += '		<codSusp>' + aProcRJG[nProcRJG, 5] + '</codSusp>'
					cXml += '	</ideProcessoCP>'
				EndIf
			Next nProcRJG
		EndIf
		If lTemRJG .And. lIncIRRF
			For nProcRJG := 1 To Len(aProcRJG)
				If aProcRJG[nProcRJG, 1] == "2"
					cXml += '	<ideProcessoIRRF>'
					cXml += '		<nrProc>' + aProcRJG[nProcRJG, 3] + '</nrProc>'
					cXml += '		<codSusp>' + aProcRJG[nProcRJG, 5] + '</codSusp>'
					cXml += '	</ideProcessoIRRF>'
				EndIf
			Next nProcRJG
		EndIf
		If lTemRJG .And. lIncFGTS
			For nProcRJG := 1 To Len(aProcRJG)
				If aProcRJG[nProcRJG, 1] == "3"
					cXml += '	<ideProcessoFGTS>'
					cXml += '		<nrProc>' + aProcRJG[nProcRJG, 3] + '</nrProc>'
					cXml += '	</ideProcessoFGTS>'
				EndIf
			Next nProcRJG
		EndIf
		If cVersEnvio < '9.0' .And. lTemRJG .And. lIncSind
			For nProcRJG := 1 To Len(aProcRJG)
				If aProcRJG[nProcRJG, 1] == "4"
					cXml += '	<ideProcessoSIND>'
					cXml += '		<nrProc>' + aProcRJG[nProcRJG, 3] + '</nrProc>'
					cXml += '	</ideProcessoSIND>'
				EndIf
			Next nProcRJG
		EndIf
		cXml += '			</dadosRubrica>'
	EndIf

	If cOper == "3"
		cXml += '		</inclusao>'
	ElseIf cOper == "4"
		cXml += '		</alteracao>'
	Else
		cXml += '		</exclusao>'
	Endif
	cXml += '		</infoRubrica>'
	cXML += 	'</evtTabRubrica>'
	cXML += '</eSocial>'

	cRetXML := cXml

	//Só gera o XML quando for a rotina de cadastro de verbas
	IF FUNNAME() == "GPEA040" .Or. IsinCallStack("GPA936THA") .Or. FUNNAME() == "GPEA941A"
		GrvTxtArq(alltrim(cXml), "S1010")
	ENDIF

	if lMiddleware .And. ChkFile("RJE")
		lRet := .T.
	Else
		//Enviar como parametro a filial do Protheus na posição 1 e o XML na posição 2
		lRet:= Len(aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S1010")) == 0
	Endif
Return lRet

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
±±³Funcao    ³fGp23ISRV ³ Autor ³ Alessandro Santos     ³ Data ³14/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Adiciona informacoes no array para impressao de inconsisten ³±±
±±³          ³cias.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGp23Inco()                                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTpCarga: 1-Rubricas                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023a  					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function fGp23ISRV(aLogProc, nTpCarga, cAliasTmp, cMsgLog, lConsulta,aAuxErro)

Local nI      	:= 0
Local aCposImp	:= {}
Local aArea		:= GetArea()
Local lRet		:= .T.
Local nX 		:= 0

Default lConsulta := .F.
Default aAuxErro	:= {}

SX3->(dbSetOrder(2))

//Verificacao dos campos inconsistentes de Rubricas
		//Inicia inconsistencias, SRV ja posicionada
		aAdd(aLogProc, OemToAnsi(STR0044) + OemToAnsi(SRV->RV_COD) + " -> " + OemToAnsi(SRV->RV_DESC)) //##"Verba: "

		aCposImp :=	{"RV_NATUREZ", "RV_DESC", "RV_TIPOCOD", "RV_INCCP", "RV_INCIRF", ;
					 "RV_INCFGTS", "RV_INCSIND", "RV_DSRHE", "RV_MED13", "RV_MEDFER", "RV_MEDAVI"}

//Busca as informacoes para cada campo
For nI := 1 To Len(aCposImp)
	If (ValType((cAliasTmp)->(FieldGet(FieldPos(aCposImp[nI])))) $ "C|D" .And. Empty((cAliasTmp)->(FieldGet(FieldPos(aCposImp[nI]))))) .Or.;
		(ValType((cAliasTmp)->(FieldGet(FieldPos(aCposImp[nI])))) == "N" .And. (cAliasTmp)->(FieldGet(FieldPos(aCposImp[nI]))) == 0)

		If SX3->(MsSeek(aCposImp[nI]))
			lRet := .F.
			If !lConsulta
				aAdd(aLogProc, AllTrim(SX3->X3_CAMPO) + " - " + AllTrim(SX3->X3_DESCRIC))
				aAdd(aAuxErro, AllTrim(SX3->X3_CAMPO) + " - " + AllTrim(SX3->X3_DESCRIC) )
				cMsgLog	+= " - " + AllTrim(SX3->X3_CAMPO)
			Endif
		EndIf
	EndIf
Next nI

//Pula linha
aAdd(aLogProc, "")

RestArea(aArea)

Return(lRet)


/*--------------------------------------------------*//*--------------------------------------------------*/
/*/{Protheus.doc} fCarga1035
Realiza carga das tabelas de carreiras públicas para o TAF - Evento S-1035
@author Claudinei Soares
@since 05/12/2017
@version P11
@param cMesAno	 , caractere, Mes e Ano informados na rotina para gravação no TAF.
@param nOpcA	 , numérico , opção de processamento, 1=carga, 2=relatório, 3=exclusão.
@param aLogProc	 , array    , log com as ocorrências.
@param dDataRef	 , data     , data de referência.
@param aDados	 , array    , registros que serão integrados.
@param aFilInTaf , array    , filial a ser enviada.
@param cVersEnvio, caractere, versão a ser enviada do leiaute.
@return Nil

@example fCarga1035(cMesAno, nOpcA, aLogProc, dDataRef, @aDados, aFilInTaf[nI],cVersEnvio)
/*/
Function fCarga1035(cMesAno, nOpcA, aLogProc, dDataRef, aDados, aFilInTaf, cVersEnvio, cFiltro)
	Local nX 			:= 0
	Local nHrInicio		:= 0
	Local nContador		:= 0
	Local nContErr		:= 0
	Local nHrFim		:= 0
	Local nFilEmp		:= 0
	Local nRecRJE  	 	:= 0
	Local cOpcAux		:= ""
	Local cChave		:= ""
	Local cStatus		:= ""
	Local cConcat		:= ""
	Local cTpInsc  		:= ""
	Local cNrInsc  		:= ""
	Local cFilEmp	 	:= ""
	Local cRetfRJE	 	:= ""
	Local cMsgLog		:= ""
	Local cOperNew 		:= "I"
	Local cRetfNew		:= "1"
	Local cStatNew		:= "1"
	Local cRetKey		:= ""
	Local cXml			:= ""
	Local cOperRJE	 	:= "I"
	Local aInfos		:= {}
	Local aDadosRJE		:= {}
	Local aAuxErro		:= {}
	Local aErros 	 	:= {}
	Local aIncons    	:= {}
	Local aAuxGeral		:= {}
	Local lSemFilial 	:= .F.
	Local lGeraCod		:= .F.
	Local lAdmPubl	 	:= .F.
	Local lContinua 	:= .T.
	Local lNovoRJE		:= .T.
	Local dDtGer		:= Date()
	Local cHrGer		:= Time()
	Local aArea		 	:= GetArea()
	Local cFilEnv		:= aFilInTaf[2]
	Local cAliasSGY  	:= GetNextAlias()
	Local aAreaSGY		:= SGY->(GetArea())
	Local aSM0    	 	:= FWLoadSM0(.T.,,.T.)
	Local cAnoMes		:= Substr(cMesAno,3,4) + Substr(cMesAno,1,2)
	Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
	Local cFilQry		:= "%%"

	Private cMenIni   	:= ""

	Default cVersEnvio 	:= "2.2"
	Default cFiltro 	:= ""

	If nOpcA == 1
		cOpcAux := "3"
	ElseIf nOpcA == 5
		cOpcAux := "5"
	Endif

	If !Empty(cFilEnv)
		If !Empty(cFiltro)
			cFilQry 	:= "% " + GPEParSQL(fPrepExpIn(cFiltro)) + " AND %"
		EndIf

		//Hora Inicial
		nHrInicio := Seconds()

		//Busca informacoes SGY - Carreiras Públicas
		BeginSql alias cAliasSGY
			SELECT
				GY_FILIAL, GY_CODIGO, GY_DESC, GY_LEI, GY_DATA, GY_SIT
			FROM
				%table:SGY% SGY
			WHERE
				%exp:cFilQry% SGY.%notDel%
			ORDER BY
				SGY.GY_FILIAL, SGY.GY_CODIGO
		EndSql

		dbSelectArea(cAliasSGY)

		//Posiciona no inicio do arquivo
		(cAliasSGY)->(dbGoTop())

		//Inicializa regua de processamento
		ProcRegua((cAliasSGY)->(RecCount()))

		//Tratamento de compartilhamento da tabela SGY
		If Empty((cAliasSGY)->GY_FILIAL)
			lSemFilial := .T.
		Else
			lGeraCod := .T.
		EndIf

		While (cAliasSGY)->(!EOF())

			//Verifica filiais
			If lSemFilial //Compartilhada
				lContinua := .T.
			ElseIf aScan(aFilInTaf[3], {|X| FwxFilial("SGY", X) == (cAliasSGY)->GY_FILIAL}) > 0 //Exclusiva
				lContinua := .T.
			Else
				lContinua := .F.
			EndIf

			If lContinua
				cCodCarrei  := Iif( lSemFilial, AllTrim( (cAliasSGY)->GY_CODIGO ), AllTrim( (cAliasSGY)->GY_FILIAL + (cAliasSGY)->GY_CODIGO ) )

				// Geracao de Carga
				If nOpcA == 1 .OR. nOpcA == 5

					// se voltar false significa inconsistencia
					lContinua := fG23VSGY(cAliasSGY, @aAuxErro, cVersEnvio)

					If lContinua
						cChave := cCodCarrei + ";" + Substr(cAnoMes,5,2) + Substr(cAnoMes,1,4)

						If lMiddleware
							aInfos := fXMLInfos()

							If Len( aInfos ) >= 4
								cTpInsc  := aInfos[1]
								cRetKey  := aInfos[3]
								lAdmPubl := aInfos[4]
								cNrInsc  := aInfos[2]
							Else
								cTpInsc  := ""
								lAdmPubl := .F.
								cNrInsc  := "0"
								cRetKey  := ""
							EndIf

							If ( nFilEmp := aScan(aSM0, { |x| x[1] == cEmpAnt .And. X[18] == cNrInsc }) ) > 0
								cFilEmp := aSM0[nFilEmp, 2]
							Else
								cFilEmp := cFilAnt
							EndIf

							// verifica se ja existe o evento s1035 na base de dados
							cStatus := "-1"
							cChave 	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1035" + Padr( AllTrim( (cAliasSGY)->GY_FILIAL + (cAliasSGY)->GY_CODIGO ), fTamRJEKey(), " ") + cAnoMes
							GetInfRJE( 2, cChave, @cStatus, @cOperRJE, @cRetfRJE, @nRecRJE )
						Else
							fVerExtemp( "S-1035", cChave, nOpcA, @cStatus, lContinua, cFilEnv, @aErros )
						EndIf

						If lMiddleware .AND. nOpcA == 1
							//Alteração ou exclusão
							If nOpcA == 4 .Or. nOpcA == 5
								//Retorno pendente impede o cadastro
								If cStatus == "2"
									cMsgRJE 	:= "Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
									lContinua	:= .F.
								//ALTERACAO
								ElseIf nOpcA == 4 .AND. cStatus <> "2"
									//Evento de exclusão sem transmissão impede o cadastro
									If cOperRJE == "E" .And. cStatus != "4"
										cMsgRJE 	:= "Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
										lContinua	:= .F.
									//Não existe na fila, será tratado como inclusão
									ElseIf cStatus == "-1"
										nOpcao 		:= 3
										cOperNew 	:= "I"
										cRetfNew	:= "1"
										cStatNew	:= "1"
										lNovoRJE	:= .T.

									//Evento sem transmissão, irá sobrescrever o registro na fila
									ElseIf cStatus $ "1/3"
										If cOperRJE == "A"
											nOpcao 	:= 4
										EndIf
										cOperNew 	:= cOperRJE
										cRetfNew	:= cRetfRJE
										cStatNew	:= "1"
										lNovoRJE	:= .F.

									//Evento diferente de exclusão transmitido, irá gerar uma retificação
									ElseIf cOperRJE != "E" .And. cStatus == "4"
										nOpcao 		:= 4
										cOperNew 	:= "A"
										cRetfNew	:= "2"
										cStatNew	:= "1"
										lNovoRJE	:= .T.

									//Evento de exclusão transmitido, será tratado como inclusão
									ElseIf cOperRJE == "E" .And. cStatus == "4"
										nOpcao 		:= 3
										cOperNew 	:= "I"
										cRetfNew	:= "1"
										cStatNew	:= "1"
										lNovoRJE	:= .T.
									EndIf

								//Exclusão
								ElseIf nOpcA == 5
									nOpcao 		:= 5
									//Evento de exclusão sem transmissão impede o cadastro
									If cOperRJE == "E" .And. cStatus != "4"
										cMsgRJE 	:= STR0011//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
										lContinua		:= .F.
									//Evento diferente de exclusão transmitido irá gerar uma exclusão
									ElseIf cOperRJE != "E" .And. cStatus == "4"
										cOperNew 	:= "E"
										cRetfNew	:= cRetfRJE
										cStatNew	:= "1"
										lNovoRJE	:= .T.
									EndIf
								EndIf

							ElseIf nOpcA == 1
								//Retorno pendente impede o cadastro
								If cStatus == "2"
									cMsgRJE 	:= STR0010//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
									lContinua		:= .F.

								//Evento de exclusão sem transmissão impede o cadastro
								ElseIf cOperRJE == "E" .And. cStatus != "4"
									cMsgRJE 	:= STR0011//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
									lContinua		:= .F.

								//Evento sem transmissão, irá sobrescrever o registro na fila
								ElseIf cStatus $ "1/3"
									nOpcao		:= Iif( cOperRJE == "I", 3, 4 )
									cOperNew 	:= cOperRJE
									cRetfNew	:= cRetfRJE
									cStatNew	:= "1"
									lNovoRJE	:= .F.

								//Evento diferente de exclusão transmitido, irá gerar uma retificação
								ElseIf cOperRJE != "E" .And. cStatus == "4"
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
							EndIf

							If lContinua
								aDadosRJE := {}
								fCarrS1035(cAliasSGY, cCodCarrei, cAnoMes, lGeraCod, cOpcAux, @aErros, cFilEnv, cVersEnvio, ,@cXml, ,@cRetKey)

								aAdd( aDadosRJE, { xFilial("RJE", (cAliasSGY)->GY_FILIAL), (cAliasSGY)->GY_FILIAL, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1035", cAnoMes, Padr( AllTrim( (cAliasSGY)->GY_FILIAL + (cAliasSGY)->GY_CODIGO ), fTamRJEKey(), ""), @cRetKey , cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew } )

								If fGravaRJE( aDadosRJE, cXml, lNovoRJE, nRecRJE )
									lContinua := .T.
								Else
									cMsgRJE := STR0012 // "Ocorreu um erro na gravação do registro na tabela RJE"
									lContinua := .F.
								EndIf
							EndIf
						EndIf
					EndIf

					If lContinua
						Begin Transaction

							fCarrS1035(cAliasSGY, cCodCarrei, cAnoMes, lGeraCod, cOpcAux, @aErros, cFilEnv, cVersEnvio)

							If Len( aErros ) <= 0
								//--------------------------------------------------------------
								//| Os erros serão impressos alinhados | Tamanho cabecalho: 132
								//| Colunas: Eventos (25+1) | Item/Registro (77+1) | Status (26)
								//| PADR("Eventos", 25) + " " + PADR("ITEM/REGISTRO", 77) + " " + PADR("STATUS", 26))
								//------------------------------------------------------------------------------------------------------------------------------------
								//Carreira          XYZABC1230                                                                    Enviada ao TAF com sucesso."
								If lMiddleware
									aAdd( aDados, PADR(OemToAnsi(STR0180), 14) + " " + PADR(cCodCarrei, 77) + " " + PADR(OemToAnsi(STR0265), 33) )
								Else
									aAdd( aDados, PADR(OemToAnsi(STR0180), 25) + " " + PADR(cCodCarrei, 77) + " " + PADR(OemToAnsi(STR0030), 26) )
								EndIf

								nContador++
							Else
								cConcat := STRTRAN( aErros[1], chr(13) + chr(10), ": " )
								//------------------------------------------------------------------------------------------------------------------------------------
								//Carreira              XYZABC1230                                                                    Nâo Enviada ao TAF         "
								//Comentario do erro
								//
								//------------------------------------------------------------------------------------------------------------------------------------
								If lMiddleware
									aAdd( aDados, PADR(OemToAnsi(STR0180), 14) + " " + PADR(cCodCarrei, 77) + " " + PADR(OemToAnsi(STR0263), 33) )
								Else
									aAdd( aDados, PADR(OemToAnsi(STR0180), 25) + " " + PADR(cCodCarrei, 77) + " " + PADR(OemToAnsi(STR0032), 26) )
								EndIf

								aAdd( aDados, cConcat)
								aAdd( aDados, "")
								nContErr++
							EndIf

							//Incrementa regua
							IncProc(OemToAnsi(STR0069) + " " + cCodCarrei)
						End Transaction

					ElseIf nOpcA <> 5
						//Caso seja encontrado algum erro na carreira
						aAuxGeral := {}
						For nX := 1 To Len(aAuxErro)
							If (len(aAuxGeral) = 0)
								aAdd(aAuxGeral, {aAuxErro[nX, 2], aAuxErro[nX, 1] })
							Else
								If ( nPos := aScan(aAuxGeral[1], aAuxErro[nX, 2]) ) > 0
									//Faz a impressao somente do primeiro campo com GY_, o restante não
									//aAuxGeral[nPos,2] += ", " +  RIGHT(aAuxErro[nX,1],Len(aAuxErro[nX,1]) - AT("_", aAuxErro[nX,1]))
									aAuxGeral[nPos,2] += ", " +  aAuxErro[nX,1]
								Else
									aAdd(aAuxGeral, {aAuxErro[nX, 2], aAuxErro[nX, 1] })
								EndIf
							EndIf
						Next

						//------------------------------------------------------------------------------------------------------------------------------------
						//Carreira                XYZABC1230                                                                    Nâo Enviada ao TAF         "
						//Comentario do erro
						//
						//------------------------------------------------------------------------------------------------------------------------------------
						If lMiddleware
							aAdd( aDados, PADR(OemToAnsi(STR0180), 14) + " " + PADR(cCodCarrei, 77) + " " + PADR(OemToAnsi(STR0263), 33) )
						Else
							aAdd( aDados, PADR(OemToAnsi(STR0180), 25) + " " + PADR(cCodCarrei, 77) + " " + PADR(OemToAnsi(STR0032), 26) )
						EndIf

						For nX := 1 To Len(aAuxGeral)
							cConcat := aAuxGeral[nX,1] + ": " + aAuxGeral[nX,2]
							aAdd( aDados, cConcat )
						Next
						aAdd( aDados, "" )
						nContErr++
					EndIf

				//-----------------------
				//| Geracao de Relatório
				//-----------------------
				Else
					lContinua := fG23VSGY(cAliasSGY, @aAuxErro, cVersEnvio, .T.) // se voltar false significa inconsistencia

					If !lContinua

						//Mensagem de log que sera gravado
						cMsgLog := OemToAnsi(STR0180) //##"Carreira"

						//Verifica inconsistencias
						//Se codigo da carreira estiver vazio apresentar inconsistencia pois nao sera possivel buscar as demais para o registro
						If Empty( (cAliasSGY)->GY_CODIGO )
							aAdd(aLogProc, OemToAnsi(STR0183) + OemToAnsi((cAliasSGY)->GY_DESC)) //##Carreira : "
							aAdd( aLogProc, OemToAnsi(STR0182) ) //##"GY_CODIGO - Código da Carreira"
							aAdd( aLogProc, "" )

							//Mensagem de log
							cMsgLog += AllTrim((cAliasSGY)->GY_DESC) + " - " + OemToAnsi(STR0125) + ": " +  Subs(STR0182, 1, 9) //##"Preenchimento de campos obrigatórios"
						Else
							/*
							ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							³ Posiciona na tabela SGY - Fisica ³
							ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
							SGY->(dbSetOrder(1))
							SGY->(MsSeek((cAliasSGY)->GY_FILIAL + (cAliasSGY)->GY_CODIGO))

							//Mensagem de log
							cMsgLog += (cAliasSGY)->GY_CODIGO + " - " + OemToAnsi(STR0125) + ": " //##"Preenchimento de campos obrigatórios"

							//Busca campos incosistentes
							//fGp23VSGY(aLogProc, 1, "SGY", @cMsgLog)
						EndIf


						IncProc(OemToAnsi(STR0069) + " " + cCodCarrei)
					EndIf
				EndIf
			EndIf

			(cAliasSGY)->(dbSkip())
		EndDo

		//----------------------
		//| Monta rodapé de LOG
		//----------------------
		If nOpcA == 1

			aAdd(aDados,"")
			aAdd(aDados,(OemToAnsi(STR0111)+" "+ OemToAnsi(STR0110) + " " + OemToAnsi(STR0179) ))	//"Resumo" ###"Carga Inicial" Carreiras Públicas
			aAdd(aDados, OemToAnsi(STR0009)+": " +  SecsToTime(nHrInicio))							//Inicio Processamento: A
			nHrFim 	:= SecsToTime(Seconds())
			aAdd(aDados,+OemToAnsi(STR0010)+":    " + nHrFim)											//Fim Processamento:    A
			aAdd(aDados,"")
			aAdd(aDados,OemToAnsi(STR0077)+": " + SecsToTime(Seconds() - nHrInicio))		//Duracao do Processamento

			If lMiddleware
				aAdd(aDados,OemToAnsi(STR0243)+": "+ ALLTRIM(STR(nContador)))						// "Quantidade Registros enviados ao Middleware"
				aAdd(aDados,OemToAnsi(STR0244)+": "+ ALLTRIM(STR(nContErr)))						// "Quantidade de Registros não enviados ao Middleware"
			Else
				aAdd(aDados,OemToAnsi(STR0078)+": "+ ALLTRIM(STR(nContador)))						//Quantidade Registro(s) enviado(s) ao TAF
				aAdd(aDados,OemToAnsi(STR0151)+": "+ ALLTRIM(STR(nContErr)))						//Quantidade Registros Não Enviados ao TAF
			EndIf


			aAdd(aDados,"")
			aAdd(aDados,"")
		EndIf

	Else

		If lMiddleware
			aAdd(aDados, OemToAnsi(STR0180) + " - " + OemToAnsi(STR0263) + OemToAnsi(aIncons[1]))
		Else
			aAdd(aDados, OemToAnsi(STR0180) + " - " + OemToAnsi(STR0032) + OemToAnsi(aIncons[1]))
		EndIf
	EndIf

	//Fecha alias em uso

	If (Select(cAliasSGY) > 0)
		(cAliasSGY)->(dbCloseArea())
	EndIf

	RestArea(aAreaSGY)
	RestArea(aArea)
Return()

/*--------------------------------------------------*//*--------------------------------------------------*/
/*/{Protheus.doc} fCarrS1035
Realiza carga das tabelas de carreiras públicas para o TAF - Evento S-1035
@author Claudinei Soares
@since 05/12/2017
@version P11
@param cAliasSGY , caractere, Registros da tabela SGY - Carreiras Públicas.
@param cCodCarrei , caractere, Código da Carreira.
@param cAnoMes , caractere, Mes e Ano informados na rotina para gravação no TAF.
@param lGeraCod , lógico, Se a tabela está em modo exclusivo ou não, .T. = Exclusiva, .F. = Compartilhada.
@param cOper	 , numérico , Tipo de operação, 	3 = inclusao, 4 = alteração, senão exclusão (verificar talvez não seja preciso)
@param aErros	 , array    , retorno da função TafPrepInt, se não estiver vazio ocorreram erros na integração com o TAF.
@param cFilEnv	 , caractere     , filial a ser enviada.
@param cVersEnvio, caractere, versão a ser enviada do leiaute.
@return Nil

@example fCarrS1035(cAliasSGY, cCodCarrei, cAnoMes, lGeraCod, "3",@aErros,cFilEnv,cVersEnvio)
/*/

Function fCarrS1035(cAliasSGY, cCodCarrei, cAnoMes, lGeraCod, cOper, aErros, cFilEnv, cVersEnvio, oMdlSGY, cRetXML, cVersMw, cId)
	Local cXml 			:= ""
	Local cDescCar		:= ""
	Local cLei			:= ""
	Local cDatalei		:= ""
	Local cSit			:= ""
	Local lGravou		:= .T.
	Local lAdmPubl		:= .F.
	Local aInfos		:= {}

	Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

	Default cOper 		:= "3"
	Default cFilEnv		:= ""
	Default cAliasSGY	:= ""
	Default aErros		:= {}
	Default cVersEnvio	:= "2.2"
	Default cAnoMes		:= LEFT(DTOS(DDATABASE),6)
	Default oMdlSGY		:= Nil
	Default cRetXML		:= ""
	Default cVersMw		:= "02_05_00"
	Default cId			:= ""

	If !Empty(cAliasSGY)
		cDescCar	:= fSubst((cAliasSGY)->GY_DESC)
		cLei		:= (cAliasSGY)->GY_LEI
		cDatalei	:= (cAliasSGY)->GY_DATA
		cSit		:= (cAliasSGY)->GY_SIT
	ElseIf oMdlSGY <> Nil
		cDescCar	:= AllTrim( oMdlSGY:GetValue("MODELGPEA932", "GY_DESC") )
		cLei		:= AllTrim( oMdlSGY:GetValue("MODELGPEA932", "GY_LEI") )
		cDatalei	:= DtoS( oMdlSGY:GetValue("MODELGPEA932", "GY_DATA") )
		cSit		:= AllTrim( oMdlSGY:GetValue("MODELGPEA932", "GY_SIT") )
	EndIf

	If lMiddleware
		aInfos	:= fXMLInfos()

		If len(aInfos) >= 4
			cId 	:= aInfos[3]
			cTpInsc := aInfos[1]
			cNrInsc := aInfos[2]
			lAdmPubl:= aInfos[4]
		Else
			cTpInsc  := ""
			lAdmPubl := .F.
			cNrInsc  := "0"
			cId		 := ""
		Endif

		cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtTabCarreira/v" + cVersMw + "'>"
		cXML += 	"<evtTabCarreira Id='" + cId + "'>"

		fXMLIdEve( @cXML, { Nil, Nil, Nil, Nil, 1, 1, "12" } )
		fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
	Else
		cXml += '<eSocial>'
		cXml += '	<evtTabCarreira>'
	EndIf

	cXml += '		<infoCarreira>'

	If cOper == "3"
		cXml += '		<inclusao>'
	ElseIf cOper == "4"
		cXml += '		<alteracao>'
	Else
		cXml += '		<exclusao>'
	Endif

	cXml += '				<ideCarreira>'
	cXml += '					<codCarreira>' + cCodCarrei + '</codCarreira>'
	cXml += '					<iniValid>' + cAnoMes + '</iniValid>'
	cXml += '				</ideCarreira>'

	If cOper <> "5"
		cXml += '			<dadosCarreira>'
		cXml += '				<dscCarreira>' + cDescCar + '</dscCarreira>'
		If !Empty(cLei)
			cXml += '				<leiCarr>' + cLei + '</leiCarr>'
		EndIf
		If !lMiddleware
			cXml += '				<dtLeiCarr>' + cDatalei + '</dtLeiCarr>'
		Else
			cXml += '				<dtLeiCarr>' + SubStr( cDatalei, 1, 4 ) + "-" + SubStr( cDatalei, 5, 2 ) + "-" + SubStr( cDatalei, 7, 2 ) + '</dtLeiCarr>'
		EndIf
		cXml += '				<sitCarr>' + cSit + '</sitCarr>'
		cXml += '			</dadosCarreira>'

		If cOper == "4"
			cXml += '		<novaValidade>'
			cXml += '			<iniValid>' + cAnoMes + '</iniValid>'
			cXml += '		</novaValidade>'
		EndIf
	EndIf

	If cOper == "3"
		cXml += '		</inclusao>'
	ElseIf cOper == "4"
		cXml += '		</alteracao>'
	Else
		cXml += '		</exclusao>'
	Endif

	cXml += '		</infoCarreira>'
	cXml += '	</evtTabCarreira>'
	cXml += '</eSocial>'

	cRetXML := cXml

	//Realiza geração de XML na System
	GrvTxtArq(alltrim(cXml))

	//Enviar como parametro a filial do Protheus na posição 1 e o XML na posição 2
	If lMiddleware
		lGravou := .T.
	Else
		aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S1035")
	EndIf

	//Verificando retorno
	If ( Len(aErros) > 0 ) .AND. FUNNAME() <> "GPEM023"
		lGravou := .F.
	EndIf

Return lGravou

/*--------------------------------------------------*//*--------------------------------------------------*/
/*/{Protheus.doc} fG23VSGY
Valida os campos da tabela SGY Carreiras Públicas - Evento S-1035
@author Claudinei Soares
@since 05/12/2017
@version P11
@param cAliasSGY	 , caractere, registros da tabela de carreiras públicas - SGY a serem validados.
@param @aAuxErro	 , array , possíveis erros encontrados, passado como referência.
@param cVersEnvio, caractere, versão a ser enviada do leiaute.
@return lRet , lógico, se existir inconsistência o retorno será falso.

@example fG23VSGY(cAliasSGY, @aAuxErro, cVersEnvio)
/*/
Function fG23VSGY(cAliasSGY, aAuxErro, cVersEnvio,lRel)

Local aRet		:= {}
Local aCampos	:= {}
Local aCposImp	:= {}
Local lRet		:= .T.
Local nX		:= 0
Local cAliasTst := cAliasSGY
Local aArea		:= GetArea()

Default aAuxErro	:= {}
Default cVersEnvio	:= ""
Default lRel		:= .F.

If Empty(cVersEnvio)
	If FindFunction("fVersEsoc")
		fVersEsoc("S1010", .T.,/**/,/**/,@cVersEnvio)
	Else
		cVersEnvio := "2.2"
	Endif
EndIf

aCampos := 	{"GY_CODIGO", "GY_DESC", "GY_DATA", "GY_SIT"}

aCposImp := {}

If Empty((cAliasTst)->GY_CODIGO)
   	AAdd(aCposImp,{"GY_CODIGO",STR0184}) //Campo não preenchido
Endif

If Empty((cAliasTst)->GY_DESC)
   	AAdd(aCposImp,{"GY_DESC",STR0184}) //Campo não preenchido
Endif

If Empty((cAliasTst)->GY_DATA)
   	AAdd(aCposImp,{"GY_DATA",STR0184}) //Campo não preenchido
Endif

If Empty((cAliasTst)->GY_SIT)
   	AAdd(aCposImp,{"GY_SIT",STR0184}) //Campo não preenchido
Endif

SX3->(dbSetOrder(2))

If Len(aCposImp)>0
	lRet := .F.

	If lRel .And. Empty(cMenIni)
		cMenIni := OemToAnsi(STR0181) //##"Inconsistências de Carreiras Públicas - Os campos abaixo estão vazios e são de preenchimento obrigatórios:"
		aAdd(aLogProc, cMenIni)
		aAdd(aLogProc, "")
		aAdd(aLogProc, "")
	EndIf

	aAdd(aLogProc, OemToAnsi(STR0183) + OemToAnsi((cAliasTst)->GY_FILIAL)+OemToAnsi((cAliasTst)->GY_CODIGO) + " -> " + OemToAnsi((cAliasTst)->GY_DESC)) //##"Carreira: "
	For nX := 1 to len(aCposImp)
		If SX3->(MsSeek(aCposImp[nX,1]))
			aAdd(aLogProc, AllTrim(SX3->X3_CAMPO) + " - " + AllTrim(SX3->X3_DESCRIC)+" - Mot.: "+aCposImp[nX,2])
		EndIf
	Next nI
	aAdd(aLogProc, "")
Endif

aAuxErro := {}
aAuxErro := aClone(aCposImp)
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    fRubThd ³ Autor ³ Renan Borges             ³ Data ³17/01/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Direcionamento da execução da carga de rubricas.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fRubThd ()                                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023a  					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */

Function fRubThd(aFilInTaf,aDados,aThreads,lSemFilial,lGeraCod,cMesAno,nOpca,dDataRef,cVersEnvio, cFiltro)
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

Default cFiltro 	:= ""

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
	VarSetUID("fRubThd",.T.)
	VarSetXD("fRubThd","nRotFim",0)
	VarSetXD("fRubThd","nContEnv",0)
	VarSetXD("fRubThd","nContNEnv",0)
	VarSetAD("fRubThd","aLogThd",{})
	VarSetAD("fRubThd","aLogPrc",{})
	VarSetAD("fRubThd","aDadosAux",{})

	For nPos := 1 to nTotProc STEP nSkip
			nPosX := nPos
			nFinal := (nSkip + nPos) - 1
			If (nThdAux == nThreads)
				nFinal := nTotProc
				nPosX  := nTotProc
			EndIf

			Sleep(5000)
			StartJob("fRubExeThd",GetEnvServer(),.F.,cEmpAnt,cFilAnt,"000000",aFilInTaf,aDados,aThreads,lSemFilial,lGeraCod,cMesAno,nOpca,nPos,nFinal,dDataRef,cVersEnvio,nThdAux,cFiltro)
			nThdAux++
			//Processa enquanto as threads não forem finalizadas
			While nPosX == nTotProc
				nPos	:= nPosX
				VarGetXD("fRubThd","nRotFim",@nRotFim)

				If nRotFim == nThreads
					VarGetAD("fRubThd","aLogPrc",@aLogPrc)
						aSort(aLogPrc,,, { |x, y| x[1] < y[1] })
						For nx := 1 to len(aLogPrc)
							For nY := 1 to len(aLogPrc[nX][2])
								aAdd(aLogProc,aLogPrc[nx][2][nY])
							Next nY
						Next nX
					VarGetAD("fRubThd","aDadosAux",@aDadosAux)
						aSort(aDadosAux,,, { |x, y| x[1] < y[1] })
						For nx := 1 to len(aDadosAux)
							For nY := 1 to len(aDadosAux[nX][2])
								aAdd(aDados,aDadosAux[nx][2][nY])
							Next nY
						Next nX
					VarGetXD("fRubThd","nContEnv",@nContEnv)
					VarGetXD("fRubThd","nContNEnv",@nContNEnv)
					nContador := nContEnv
					nContErr  := nContNEnv
					VarClean("fRubThd")
					Exit
				EndIf
			EndDo
	Next nPos
Else
	fCrgRub(aFilInTaf,aDados,aThreads,lSemFilial,lGeraCod,cMesAno,1,nTotProc,nOpca,dDataRef,cVersEnvio,cFiltro)
EndIf

__cUserId := cUserAux

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    fRubExeThd ³ Autor ³ Renan Borges          ³ Data ³17/01/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Execução da carga de rubricas em multi-thread.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fRubExeThd ()                                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023a  					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */
Function fRubExeThd(xEmp,xFil,xUser,aFilInTaf,aDados,aThreads,lSemFilial,lGeraCod,cMesAno,nOpca,nRecDe,nRecAte,dDataRef,cVersEnvio,nThread, cFiltro)

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

Default cFiltro			:= ""

If Empty(cFilAnt)
	cFilAnt:= xFil
EndIf

__cUserId := xUser

fCrgRub(aFilInTaf,@aDados,aThreads,lSemFilial,lGeraCod,cMesAno,nRecDe,nRecAte,nOpca,dDataRef,cVersEnvio,cFiltro)

If Len(aLogProc) > 0
	VarBeginT("fRubThd","aLogPrc")
		VarGetAD("fRubThd","aLogPrc",@aLogPrc)
			For nX := 1 to Len(aLogProc)
				If nX == 1
					aAdd(aLogPrc, {nThread,{aLogProc[nx]}})
					nTam := Len(aLogPrc)
				Else
					aAdd(aLogPrc[nTam,2],aLogProc[nx])
				EndIf
			Next
		VarSetAD("fRubThd","aLogPrc",aLogPrc)
	VarEndT("fRubThd","aLogPrc")
EndIf

If Len(aDados) > 0
	VarBeginT("fRubThd","aDadosAux")
		VarGetAD("fRubThd","aDadosAux",@aDadosAux)
			For nX := 1 to Len(aDados)
				If nX == 1
					aAdd(aDadosAux, {nThread,{aDados[nx]}})
					nTam := Len(aDadosAux)
				Else
					aAdd(aDadosAux[nTam,2],aDados[nx])
				EndIf
			Next
		VarSetAD("fRubThd","aDadosAux",aDadosAux)
	VarEndT("fRubThd","aDadosAux")
EndIf

//Soma Contador de Enviadas
VarBeginT("fRubThd","nContEnv")
	VarGetXD("fRubThd","nContEnv",@nContEnv)
	nContEnv += nContador
	VarSetXD("fRubThd","nContEnv",nContEnv)
VarEndT("fRubThd","nContEnv")

//Soma Contador de Não Enviadas
VarBeginT("fRubThd","nContNEnv")
	VarGetXD("fRubThd","nContNEnv",@nContNEnv)
	nContNEnv += nContErr
	VarSetXD("fRubThd","nContNEnv",nContNEnv)
VarEndT("fRubThd","nContNEnv")

//Soma 1 no controle de threads finalizadas
VarBeginT("fRubThd","nRotFim")
	VarGetXD("fRubThd","nRotFim",@nRotFim)
	nRotFim++
	VarSetXD("fRubThd","nRotFim",nRotFim)
VarEndT("fRubThd","nRotFim")

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    fCrgRub ³ Autor ³ Renan Borges          ³ Data ³17/01/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Execução da carga de rubricas.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCrgRub ()                                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023a  					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */

Function fCrgRub(aFilInTaf,aDados,aThreads,lSemFilial,lGeraCod,cMesAno,nRecDe,nRecAte,nOpca,dDataRef,cVersEnvio, cFiltro)

Local cAliasSRV  	:= GetNextAlias()
Local cFilEnv		:= aFilInTaf[2]
Local cMenIni   	:= ""
Local cMsgLog		:= ""
Local aErros 	 	:= {}
Local lContinua 	:= .T.
Local cAnoMes		:= Substr(cMesAno,3,4) + Substr(cMesAno,1,2)
Local aAuxErro		:= {}
Local cConcat		:= ""
Local nX 			:= 0
Local aAuxGeral		:= {}
Local cOpcAux		:= ""
Local cChave		:= ""
Local cStatus		:= ""
Local nOpcAux		:= 0
Local lTemRJG		:= ChkFile("RJG")

Local aDadosRJE		:= {}
Local cXml			:= ""
Local cRetKey		:= ""
Local cGpeAmbe		:= ""
Local nRecRJE		:= 0
Local cOperRJE		:= "I"
Local cRetfRJE		:= ""
Local cRetfNew		:= ""
Local cStatNew		:= ""
Local dDtGer		:= Date()
Local cHrGer		:= Time()
Local cOperNew		:= ""
Local lRetMid		:= .T.
Local lNovoRJE		:= .T.
Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Local cFilQry		:= ""
Local cCposVers		:= If(cVersEnvio >= "9.0", "%, RV_INCOP, RV_TETOP %", "%%")

Default cFiltro		:= ""

If Empty(cFiltro)
	cFilQry		:= "% (R_E_C_N_O_ >= '" + cValToChar(aThreads[nRecDe]) + "' AND R_E_C_N_O_ <= '" + cValToChar(aThreads[nRecAte]) + "')%"
Else
	cFilQry 	:= "% " + GPEParSQL(fPrepExpIn(cFiltro)) + " %"
EndIf

	//Busca informacoes SRV - Verbas
	#IFDEF TOP
		BeginSql alias cAliasSRV
			SELECT
				RV_FILIAL, RV_COD, RV_DESC, RV_DESCDET, RV_NATUREZ, RV_TIPOCOD, RV_DSRHE, RV_MED13, RV_MEDFER, RV_MEDAVI,
				RV_PERC, RV_INCSIND , RV_INSS, RV_INCCP, RV_IR, RV_INCIRF, RV_FGTS , RV_INCFGTS, RV_CODFOL %exp:cCposVers%
			FROM
				%table:SRV% SRV
			WHERE
				SRV.%notDel%	AND %exp:cFilQry%
			ORDER BY
				SRV.RV_FILIAL, SRV.RV_COD
		EndSql

		dbSelectArea(cAliasSRV)
	#ELSE
		cAliasSRV := "SRV"
		dbSelectArea(cAliasSRV)
	#ENDIF

	//Posiciona no inicio do arquivo
	(cAliasSRV)->(dbGoTop())
	nOpcAux := nOpcA

	While (cAliasSRV)->(!EOF())
		//Verifica filiais
		If lSemFilial //Compartilhada
			lContinua := .T.
		ElseIf aScan(aFilInTaf[3], {|X| FwxFilial("SRV", X) == (cAliasSRV)->RV_FILIAL}) > 0 //Exclusiva
			lContinua := .T.
		Else
			lContinua := .F.
		EndIf

		If lContinua
			cCodRubr := (cAliasSRV)->RV_COD
			nOpcA := nOpcAux

			If lMiddleware
				// verifica se ja existe o evento s1010 na base de dados
				cChave := cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1010" + Padr( (cAliasSRV)->RV_FILIAL + cCodRubr, fTamRJEKey(), " ") + cAnoMes
				cStatus := "-1"
				GetInfRJE( 2, cChave, @cStatus, @cOperRJE, @cRetfRJE, @nRecRJE ) //RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
			EndIf
			//-------------------
			//| Geracao de Carga
			//-------------------
			If nOpcA == 1 .OR. nOpcA == 5

				If lMiddleware
					lRetMid := .T.
					Do Case
						Case cStatus == "2"
							lRetMid := .F.
							cMsgRJE := STR0246 //"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
						Case cOperRJE == "E" .And. cStatus != "4"
							lRetMid := .F.
							cMsgRJE := STR0247 //"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
					EndCase
				EndIf

				If nOpcA == 1
					cOpcAux := "3"

					If lMiddleware .And. lRetMid
						Do Case
							Case cStatus $ "1/3" //Evento sem transmissão, sobrescreve o registro na fila
								cOpcAux		:= Iif( cOperRJE == "I", "3", "4" )
								cOperNew 	:= cOperRJE
								cRetfNew	:= cRetfRJE
								cStatNew	:= "1"
								lNovoRJE	:= .F.
							Case cOperRJE != "E" .And. cStatus == "4"
								lRetMid := .F.
								cMsgRJE := STR0273 //"Não á possível a inclusão/alteração do registro. Existe um evento S-1010 com o mesmo Cod.Rubrica, Iden.Tab.Rub e mesma data de início de validade já transmitido."
							Otherwise
								cOperNew 	:= "I"
								cRetfNew	:= "1"
								cStatNew	:= "1"
								lNovoRJE	:= .T.
						EndCase
					EndIf

					// se voltar false significa inconsistencia
					lContinua := fG17VSRV(cAliasSRV, @aAuxErro,cVersEnvio,cAnoMes)

				ElseIf nOpcA == 5
					cOpcAux := "5"

					If lGeraCod
						cIdTbRub := (cAliasSRV)->RV_FILIAL
					Else
						If cVersEnvio >= "2.3"
							cIdTbRub := cEmpAnt
						Else
							cIdTbRub := ""
						EndIf
					Endif

					If !lMiddleware
						cChave := cCodRubr + ";" + cIdTbRub + ";" + Substr(cAnoMes,5,2) + Substr(cAnoMes,1,4)
						nOpcA := fVerExtemp( "S-1010", cChave, nOpcA, @cStatus, lContinua, cFilEnv, @aErros )
					elseIf lRetMid
						//Evento diferente de exclusão transmitido ir?gerar uma exclusão
						If cOperRJE != "E" .And. cStatus == "4"
							cOperNew 	:= "E"
							cRetfNew	:= cRetfRJE
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						EndIf
					EndIf

					If(cStatus $ "2|4")
						lContinua := .T.
					Else
						lContinua := .F.
					EndIf
				EndIf

				If lContinua .And. lRetMid

					Begin Transaction

						fCarrRub(cAliasSRV, cCodRubr, cAnoMes, lGeraCod, cOpcAux,@aErros,cFilEnv,,cVersEnvio, @cXml, @cRetKey, cGpeAmbe, lTemRJG)

						If lMiddleware
							aDadosRJE := {}
							aAdd( aDadosRJE, { xFilial("RJE", cFilEnv), (cAliasSRV)->RV_FILIAL, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1010", cAnoMes, (cAliasSRV)->RV_FILIAL + cCodRubr, cRetKey, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew } )

							//Se não for uma exclusão de registro não transmitido, cria/atualiza registro na fila
							If !( nOpcA == 5 .And. ((cOperRJE == "E" .And. cStatus == "4") .Or. cStatus $ "-1/1/3") )
								fGravaRJE( aDadosRJE, cXml, lNovoRJE, nRecRJE )
							//Se for uma exclusão e não for de registro de exclusão transmitido, exclui registro de exclusão na fila
							ElseIf nOpcA == 5 .And. cStatus != "-1" .And. !(cOperRJE == "E" .And. cStatus == "4")
								fExcluiRJE( nRecRJE )
							EndIf
						EndIf

						If Len( aErros ) <= 0
							//--------------------------------------------------------------
							//| Os erros serão impressos alinhados | Tamanho cabecalho: 132
							//| Colunas: Eventos (25+1) | Item/Registro (77+1) | Status (26)
							//| PADR("Eventos", 25) + " " + PADR("ITEM/REGISTRO", 77) + " " + PADR("STATUS", 26))
							//------------------------------------------------------------------------------------------------------------------------------------
							//Rubrica                   XYZABC1230                                                                    Enviada ao TAF#Middleware com sucesso."
							aAdd( aDados, PADR(OemToAnsi(STR0126), 25) + " " + PADR(cCodRubr, 70) + Iif( !lMiddleware, " " + PADR(OemToAnsi(STR0030), 26), PADR(OemToAnsi(STR0241), 33)) )
							nContador++
						Else
							cConcat := STRTRAN( aErros[1], chr(13) + chr(10), ": " )
							FeSoc2Err( aErros[1], @cConcat , Iif( aErros[1]!='000026',1,2 ) )
							//------------------------------------------------------------------------------------------------------------------------------------
							//Rubrica                   XYZABC1230                                                                    Falha no envio ao TAF#Middleware:
							//Comentario do erro
							//
							//------------------------------------------------------------------------------------------------------------------------------------
							aAdd( aDados, PADR(OemToAnsi(STR0126), 25) + " " + PADR(cCodRubr, 70) + Iif( !lMiddleware, " " + PADR(OemToAnsi(STR0032), 26), PADR(OemToAnsi(STR0263), 29)) )
							aAdd( aDados, cConcat)
							aAdd( aDados, "")
							nContErr++
						EndIf

						If !IsBlind()
							//Incrementa regua
							IncProc(OemToAnsi(STR0069) + " " + cCodRubr)
						EndIf

					End Transaction
				ElseIf !lRetMid
					aAdd( aDados, PADR(OemToAnsi(STR0126), 25) + " " + PADR(cCodRubr, 70) + PADR(OemToAnsi(STR0263), 29) )
					aAdd( aDados, cMsgRJE )
					aAdd( aDados, "" )
					nContErr++
				ElseIf cOpcAux <> "5" //Só gera o log de erro se for diferente de "Exclusão em Lote"
				//Caso seja encontrado algum erro na verba
					aAuxGeral := {}
					For nX := 1 To Len(aAuxErro)
						fGp17LmtDsc(@aAuxGeral, aAuxErro[nX, 1], aAuxErro[nX, 2])
					Next

					//------------------------------------------------------------------------------------------------------------------------------------
					//Rubrica                   XYZABC1230                                                                    Nâo Enviada ao TAF         "
					//Comentario do erro
					//
					//------------------------------------------------------------------------------------------------------------------------------------
					aAdd( aDados, PADR(OemToAnsi(STR0126), 25) + " " + PADR(cCodRubr, 70) + Iif( !lMiddleware, " " + PADR(OemToAnsi(STR0032), 26), PADR(OemToAnsi(STR0263), 29)) )
					For nX := 1 To Len(aAuxGeral)
						cConcat := aAuxGeral[nX]
						aAdd( aDados, cConcat )
					Next
					aAdd( aDados, "" )
					nContErr++
				EndIf

			//-----------------------
			//| Geracao de Relatório
			//-----------------------
			Else
				lContinua := fG17VSRV(cAliasSRV, @aAuxErro,cVersEnvio,cAnoMes) // se voltar false significa inconsistencia

				If !lContinua
					//Verifica inconsistencias
					//Se codigo da verba estiver vazio apresentar inconsistencia pois nao sera possivel buscar as demais para o registro
					If Empty( (cAliasSRV)->RV_COD )
						aAdd(aLogProc, OemToAnsi(STR0044) + OemToAnsi((cAliasSRV)->RV_DESC)) //##Verba : "
						aAdd( aLogProc, OemToAnsi(STR0046) ) //##"RV_COD - Código da Verba"
						aAdd( aLogProc, "" )

						//Mensagem de log
						cMsgLog += AllTrim((cAliasSRV)->RV_DESC) + " - " + OemToAnsi(STR0125) + ": " +  Subs(STR0046, 1, 6) //##"Preenchimento de campos obrigatórios"
					Endif
					IncProc(OemToAnsi(STR0069) + " " + cCodRubr)
				EndIf

			EndIf
		EndIf

		(cAliasSRV)->(dbSkip())
	EndDo

	//Fecha alias em uso
	#IFDEF TOP
		If (Select(cAliasSRV) > 0)
			(cAliasSRV)->(dbCloseArea())
		EndIf
	#ENDIF
Return
