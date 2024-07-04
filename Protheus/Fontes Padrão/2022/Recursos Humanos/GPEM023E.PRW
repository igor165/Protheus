#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM023.CH"

Static nOrdemMult	:= 0
Static lTemGC		:= fIsCorpManage( FWGrpCompany() ) // verifica se a empresa tem gestao corporativa
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPEM023E ³ Autor ³ Marcia Moura                                ³ Data ³ 10/11/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de Envio de Eventos - Funcionarios                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM023E()                                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista     ³ Data     ³ FNC/Requisito  ³ Chamado ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcia Moura |01/12/2015|                |TTHNTA   |Integracao do registro S-2100 com o TAF    ³±±
±³Christiane V.|11/12/2015|                 |TTTTA0   |Correção na função fGM23Vinc() para excluir³±±
±±³             |          |                |         |campos não utilizados da tabela RFZ.       ³±±
±±³Marcia Moura |15/06/2016|                |TVFSO4   |Adaptacao para o leiaute 2.2.3             ³±±
±±³Marcia Moura |19/08/2016|                |TVMRZU   |Utilizacao do codigo unico do SRA para     ³±±
±±³             |          |                |         |identificacao do funcionario no TAf         ³±
±±³Marcia Moura |26/08/2016|                |TVMRZU   |Tratamento para o Novo Status da TafGetStat³±±
±±³             |          |                |         |-1, que significa registro não encontrado  ³±±
±±³Marcia Moura |12/09/2016|                |TVXAE2   |Inclusao   tratamento para a Lei de Anistia³±±
±±³             |          |                |         |anteriormente o campo era um combo e na    ³±±
±±³             |          |                |         |ultima versao esocial (2.2) o campo passa  ³±±
±±³             |          |                |         |a ser um campo de 13 caracteres livre digi-³±±
±±³             |          |                |         |cao, atualizaremos o campo na Carga Inicial³±±
±±³Marcos Cout. |26/04/2017|  DRHESOCP-     |         |Realizar a implantação da geração do Vínculo±±
±±³             |          |                |         |Inicial do trabalhado (S-2100)             ³±±
±±³Marcos Cout. |11/05/2017|  DRHESOCP-237  |         |Realizar ajustes na função fGM23DEP() para *±±
±±³             |          |                |         |adequar a geração do evento S-2300         ³±±
±±³Marcia Moura |12/05/2017|  DRHESOCP-222  |         |Realizar ajustes na função fGM23Tur() para *±±
±±³             |          |                |         |adequar a geração do evento S-2206         ³±±
±±³Marcia Moura |02/06/2017|DRHESOCP-316    |         |Pacote para Atendimento                    ³±±
±±³Marcos Cout  ³12/06/2017³DRHESOCP-389    ³         ³War Room + Merge                           ³±±
±±³             ³          ³                ³         ³Subir fontes para release superior (17)    ³±±
±±³Marcos Cout  |12/06/2017|DRHESOCP-398    |         ³Realizar ajustes na função que valida os   ³±±
±±³             |          |                |         ³campos do eSocial                          ³±±
±±³MArcia Moura ³23/06/2017³DRHESOCP-470    ³         ³Inclusao de novos campos para temporario   ³±±
±±³MArcia Moura ³05/07/2017³DRHESOCP-569    ³         ³Correcao do campo ra_ctpcd na query        ³±±
±±³MArcia Moura ³05/07/2017³DRHESOCP-554    ³         ³Correcao no relatorio de inconsistencia    ³±±
±±³MArcia Moura ³07/07/2017³DRHESOCP-576    ³         ³Correcao no codigo unico, data de nasciment³±±
±±³             ³          ³                ³         ³e relatorio de inconsistencias             ³±±
±±³Marcia Moura ³07/07/2017³DRHESOCP-567    ³         ³Correcao na geracao de horarios para seq.  ³±±
±±³             ³          ³                ³         ³com o dom.trabalhado. Gravaremos como dia 8³±±
±±³Oswaldo L    ³19/07/2017³DRHESOCP- 635   ³         ³Ajuste do DE\PARA da tabela de dependente  ³±±
±±³             ³          ³                ³         ³do e-Social para o protheus                ³±±
±±³Oswaldo L    ³19/07/2017³DRHESOCP-635    ³         ³Ajuste conversao de campo data             ³±±
±±³Oswaldo L    ³19/07/2017³DRHESOCP-646    ³         ³Gerar tipo 08 da tabela de depend do TAF   ³±±
±±³Oswaldo L    ³27/07/2017³DRHESOCP-697    ³         ³Ajuste  func comissionado e correção  do   ³±±
±±³             ³          ³                ³         ³posicionamento do ponteiro  SRA            ³±±
±±³Oswaldo L    ³27-07-2017³DRHESOCP-699    ³         ³Unificar opções da Tag undSalFixo          ³±±
±±³Marcos Cout  ³28/07/2017³DRHESOCP-703    ³         ³Realizar ajustes estéticos e padronizados  ³±±
±±³             ³          ³                ³         ³no relatório de Carga Inicial dos Eventos  ³±±
±±³Oswaldo L    ³27-07-2017³ DRHESOCP-592   ³         ³Unificar a lista de opções da Tag          ³±±
±±³             ³          ³ SubTask 709    ³         ³<estCiv>                                   ³±±
±±³Eduardo Vic  ³04/08/2017³DRHESOCP-772    ³         ³Inclusão de laço pra envio de dados de 	  ³±±
±±³             ³          ³                ³         ³todas as filiais, ajustes de conversão de  ³±±
±±³             ³          ³                ³         ³data de nascimento de dependentes          ³±±
±±³Eduardo Vic  ³08/08/2017³DRHESOCP-781    ³         ³Ajustes da query e condicional para buscade³±±
±±³             ³          ³                ³         ³filial posicionada                         ³±±
±±³Eduardo V    ³11/08/2017³DRHESOCP-781    ³         ³Correções de erros apontadas a issue 592   ³±±
±±³Eduardo V    ³21/08/2017³DRHESOCP-899    ³         ³Trat. no campo RA_TPCONTR, onde em caso  do³±±
±±³Eduardo V    ³          ³                ³         ³mesmo esteja vazio,preencher com "1" o xml.³±±
±±³Marcos Cout  |29/08/2017|DRHESOCP-708    |         |Realizar a tratativa da TAG <estCiv> para  ³±±
±±³             |          |                |         |tratar a estado "União Estavel"            ³±±
±±|Marcos Cout. |08/09/2017|DRHESOCP-887    |         |Unificação das rotinas de integração dos   |±±
±±|             |          |                |         |trabalhadores. Ajustada rotina fintAdmiss  |±±
±±|Claudinei S. |11/09/2017|DRHESOCP-729    |         |Leiaute 2.3,ajuste em n fCargVI() adequação|±±
±±|             |          |                          |do XML para os funcionários temporários    |±±
±±|             |          |                          |tabela RBW.                                |±±
±±³Marcos Cout  |14/09/2017|DRHESOCP-1018   |         |Realizando o ajuste necessário para que o  ³±±
±±³             |          |                |         |sistema realize a validação do layout dispo³±±
±±³             |          |                |         |_nível no ambiente para fazer a integração ³±±
±±³             |          |                |         |entre o SIGAGPE e o SIGATAF                ³±±
±±³Cecilia C.   |24/10/2017|DRHESOCP-1592   |         |Ajuste para leiaute 2.4 na geração da tag  ³±±
±±³             |          |                |         |<tmpPar> dos eventos S-2200 e A-2206.      ³±±
±±³Cecilia C.   |03/11/2017|DRHESOCP-1766   |         |Ajuste para leiautes 2.3 e 2.4 na carga ini³±±
±±³             |          |                |         |cial tag <localTrabGeral> do evento S-2200.³±±
±±³Cecilia C.   |06/11/2017|DRHESOCP-1802   |         |Ajuste para leiaute 2.4 na geração da tag  ³±±
±±³             |          |                |         |<sucessaoVinc> do evento S-2200, tag       ³±±
±±³             |          |                |         |<tpRegTrab> do S-2206.                     ³±±
±±³Marcos Cout. |28/12/2017|DRHESOCP-2631   |         |Ajustes no retorno do campo RA_DEMISSAO    ³±±
±±³             |          |                |         |Converter de data para string              ³±±
±±³Cecília Carv |08/01/2018|DRHESOCP-2682   |         |Ajuste para geração de contrato intermiten-³±±
±±³             |          |                |         |te - evento S-2200.                        ³±±
±±³Julio Silva  |29/01/2018|MPRIMESP-12929  |         |Ajuste para que seja importado o dependente³±±
±±³             |          |                |         |corretamente no envento  S-2200.           ³±±
±±³Marcos Cout. |09/02/2017|DRHESCOP-2924   |         |Realizado ajuste na função responsavel por ³±±
±±³             |          |                |         |retornar os dados dos dependenes fGM23Dep  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPEM023E()
	Local aArea		 	:= GetArea()

	RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fCargVI   ³ Autor ³ Glaucia Messina       ³ Data ³21/03/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Realiza carga S-2100- Trabalhadores no TAF                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fCargVI()                                             	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function fCargVI(nPar1, aLogProc, nPar2, aDados, aPar3, nPar4, cVersEnvio, nRetifica)
	Local cDadosFunc
	Local cSitQuery		:= "%"
	Local cAliasfun		:= "SRA"
	Local CodUnico		:= ""
	Local cAliasSRA		:= GetNextAlias()
	Local cEstb			:= ""
	Local cFilQry		:= ""
	Local cQryFil		:= ""
	Local cFilEnv		:= ""
	Local cTrabVincu	:= "%" + fSqlIn( StrTran(fCatTrabEFD("TCV"), "|"), 3 ) + "%" //Trabalhador com vinculo
	Local cStatTAF		:= ""

	Local nHrInicio
	Local nHrFim
	Local nX 			:= 0
	Local nI			:= 0
	Local nK			:= 0
	Local nTamFil		:= 0
	Local nContador		:= 0
	Local nContErr		:= 0
	Local nOpcaP		:= 0

	Local lPosVarAux    := .F.
	Local lGeraTAF		:= .T.
	Local lTemRegs		:= .F.

	Local aErros		:= {}
	Local aArea		 	:= GetArea()
	Local aEstb			:= {}
	Local aFilTAF		:= ""
	Local aAreaQuery	:= ""
	Local aAuxDados		:= {}
	Local aConcat		:= {}
	Local aFilial		:= {}
	Local aArrayFil		:= {}
	Local cBkpFil		:= cFilAnt

	Local cTpInsc		:= ""
	Local lAdmPubl      := .F.
	Local cNrInsc		:= ""
	Local cChaveMid		:= ""
	Local cStatus 		:= "-1"
	Local aInfoC		:= {}
	Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
	Local cMsgErro		:= ""
	Local lJorSInt		:= .F. // Jornada Sem Intervalo Definido
	Local cMsgEnvio		:= ""

	Default cSituacao 	:= " ADFT"
	Default cVersEnvio 	:= "2.2"
	Default nPar1 		:= ""
	Default nPar2 		:= date()
	Default nPar4 		:= 1
	Default aPar3 		:= {}
	Default nRetifica	:= 2

	nOpcaP := nPar1

	//-- Modifica variaveis para a Query
	If Len(cSituacao) > 0
		For nI:=1 to Len(cSituacao)
			cSitQuery += "'"+Subs(cSituacao,nI,1)+"'"
			If ( nI+1 ) <= Len(cSituacao)
				cSitQuery += ","
			Else
				cSitQuery += "%"
			Endif
		Next nI
	Else
		cSitQuery += "'*'%"
	EndIf

	nI  := 0

	cFilEnv := aPar3[nPar4,2]
	aFilTAF := fGM23Fil(aPar3,nPar4)

	Aadd(aFilial,{aPar3,aArrayFil,cFilEnv})

	If nOpcAP == 1

		//Pre-Cargas
		nHrInicio	:= Seconds()
		aEstb		:= fGM23SM0(.T., .T.)
		nTamFil		:= Len(aEstb[1,1])

		For nI := 1 To Len(aEstb)
			cEstb := aEstb[nI,1]
			If cEstb >= Alltrim(cFilDe) .And. cEstb <= Alltrim(cFilAte) .And. !aEstb[nI,4]
				cFilQry += cEstb
				If aScan(aDados, {|x| OemToAnsi(STR0219) $ x }) == 0
					aAdd( aDados, "")
					aAdd( aDados, OemToAnsi(STR0219)) //"Funcionários devem estar vinculados a uma filial ou obra própria da empresa. Verifique Dados da Filial - Módulo SIGACFG"
					aAdd( aDados, OemToAnsi(STR0220)) //"Os funcionários da(s) filial(is) abaixo estão vinculados a uma sub-empreitada ou ou os dados da obra não foram encontrados na tabela F0F, por isso não serão integrados:"
				Endif
				If aScan(aDados, {|x| OemToAnsi(STR0086) + " : " +cEstb $ x }) == 0
					Aadd(adados, OemToAnsi(STR0086) + " : " +cEstb)
				Endif
			Endif
		Next nI

		aAdd( aDados, "")
		cFilQry := fSqlIN( cFilQry, nTamFil)

		If Empty(cFilQry)
			cFilQry := "''"
		Endif

		//Busca informacoes SRA-Funcionarios
		cQryFil	:= '% SRA.RA_FILIAL NOT IN ('+ cFilQry + ') %'

		//Query para buscar informacoes Trabalhadores
		BeginSql alias cAliasSRA
			SELECT
				RA_FILIAL, RA_MAT, RA_CIC, RA_PIS, RA_NOMECMP, RA_NOME, RA_SEXO,
				RA_RACACOR, RA_ESTCIVI, RA_GRINRAI,
				RA_NASC, RA_CODMUNN, RA_NATURAL, RA_CPAISOR, RA_NACIONC,
				RA_MAE, RA_PAI, RA_NUMCP, RA_SERCP, RA_UFCP,
				RA_NUMRIC,RA_EMISRIC , RA_DEXPRIC, RA_RG, RA_RGEXP,RA_DTRGEXP,
				RA_RNE, RA_RNEORG, RA_RNEDEXP, RA_CODIGO, RA_OCEMIS, RA_OCDTEXP, RA_OCDTVAL,
				RA_HABILIT, RA_CNHORG, RA_CATCNH, RA_UFCNH, RA_DTEMCNH, RA_DTVCCNH, RA_RESEXT,
				RA_LOGRTP, RA_LOGRDSC, RA_LOGRNUM,RA_COMPLEM, RA_BAIRRO, RA_CEP, RA_CEPCXPO,
				RA_CODMUN,RA_ESTADO, RA_PAISEXT, RA_CODMUN, RA_ESTADO, RA_MUNICIP,RA_CPOSTAL,
				RA_TELEFON, RA_DDDFONE, RA_NUMCELU, RA_DDDCELU,
				RA_DATCHEG, RA_DATNATU, RA_CASADBR, RA_FILHOBR,
				RA_PORTDEF, RA_EAPOSEN, RA_TPDEFFI, RA_CLASEST,
				RA_TELEFON, RA_NUMCELU, RA_EMAIL, RA_EMAIL2,
				RA_ADMISSA, RA_DEMISSA, RA_VIEMRAI,RA_TPPREVI,
				RA_TPJORNA, RA_TNOTRAB, RA_REGRA, RA_SEQTURN,
				RA_CATEFD, RA_TIPOADM, RA_SITFOLH, RA_HOPARC,
				RA_CODFUNC, RA_CARGO, RA_SALARIO, RA_CATFUNC, RA_TPCONTR, RA_DTFIMCT, RA_CTPCD,
				RA_CC, RA_HRSEMAN, RA_NJUD14, RA_ALTOPC, RA_OPCAO, RA_SINDICA, RA_CODUNIC,RA_NSOCIAL
			FROM
				%table:SRA% SRA
			WHERE
				SRA.RA_FILIAL IN(%exp:aFilTAF[1]%) AND
				SRA.RA_FILIAL >= (%exp: cFilDe%) AND SRA.RA_FILIAL <= (%exp: cFilAte%)
				AND SRA.RA_MAT >= (%exp: cMatDe%) AND SRA.RA_MAT <= (%exp: cMatAte%)
				AND SRA.RA_CC >= (%exp: cCCDe%) AND SRA.RA_CC <= (%exp: cCCAte%)
				AND SRA.RA_SITFOLH IN ( %exp:cSitQuery% )
				AND SRA.RA_CATEFD IN ( %exp:cTrabVincu% )
				AND %exp:cQryFil%
				AND SRA.%notDel%
			ORDER BY
			SRA.RA_FILIAL, SRA.RA_MAT
		EndSql
		dbSelectArea(cAliasSRA)
		lPosVarAux    := .T.

		//Posiciona no inicio do arquivo
		(cAliasSRA)->(dbGoTop())
		nK := 0

		While (cAliasSRA)->(!EOF())

			cMsgErro := ""
			lTemRegs := .T.
			lJorSInt := .F.
			ProcRegua(nK++)

			If lPosVarAux
				//na funcao fG17VSRA sistema carrega o conteúdo do ponteiro SRA para a memória, mas no caso da query ter sido aberta com um Alias Auxiliar, o SRA oficial não estara posicionado
				dbselectArea(cAliasFun)
				DbSetOrder( 1 )
				DbSeek((cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT)
			EndIf

			aAuxDados := {}
			lGeraTAF:= fG17VSRA(cAliasSRA, 2,/*nopc*/,@aAuxDados, cVersEnvio)
			//Consistir os parâmetros informados
			If !Empty(cCCAte)
				If (cAliasSRA)->RA_CC < cCCDe .Or. (cAliasSRA)->RA_CC > cCCAte
					(cAliasSRA)->(DBSKIP())
					Loop
				Endif
			Endif
			If !Empty(cNomeAte)
				If (cAliasSRA)->RA_NOME < cNomeDe .Or. (cAliasSRA)->RA_NOME > cNomeAte
					(cAliasSRA)->(DBSKIP())
					Loop
				Endif
			Endif
			If !Empty(cMatAte)
				If (cAliasSRA)->RA_MAT < cMatDe .Or. (cAliasSRA)->RA_MAT > cMatAte
					(cAliasSRA)->(DBSKIP())
					Loop
				Endif
			Endif
			If !Empty(cFilAte)
				If (cAliasSRA)->RA_FILIAL < cFilDe .Or. (cAliasSRA)->RA_FILIAL > cFilAte
					(cAliasSRA)->(DBSKIP())
					Loop
				Endif
			Endif

			If lGeraTAF //Somente carga
				aAreaQuery := GetArea()
				CodUnico := ""
				dbselectArea(cAliasFun)
				DbSetOrder( 1 )
				If DbSeek((cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT)
					IF  SRA->( RecLock( "SRA" , .F. ) )
						If	SRA->( FieldPos( "RA_CODUNIC" ) ) > 0
							IF EMPTY(SRA->RA_CODUNIC)
								SRA->RA_CODUNIC := fRACodUnic()
							Endif
							CodUnico:= SRA->RA_CODUNIC
						Endif

						if Len(SRA->RA_NRLEIAN) == 1
							if val(SRA->RA_NRLEIAN) == 1
								SRA->RA_NRLEIAN := "6683/1979"
							Elseif val(SRA->RA_NRLEIAN) == 2
								SRA->RA_NRLEIAN := "8632/1993"
							Elseif val(SRA->RA_NRLEIAN) == 3
								SRA->RA_NRLEIAN := "8878/1994"
							Elseif val(SRA->RA_NRLEIAN) == 4
								SRA->RA_NRLEIAN := "10.559/2002"
							Elseif val(SRA->RA_NRLEIAN) == 5
								SRA->RA_NRLEIAN := "10.790/2003"
							Elseif val(SRA->RA_NRLEIAN) == 6
								SRA->RA_NRLEIAN := "11.282/2006"
							Endif
						Endif

						SRA->RA_MSBLQL := "2"
						SRA->( MsUnLock() )
					EndIF
				Endif

				RestArea(aAreaQuery)

				cFilAnt  := (cAliasSRA)->RA_FILIAL
				
				If lMiddleware
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
					GetInfRJE( 2, cChaveMid, @cStatus ) //RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
					cStatTAF := cStatus
				Else
					cStatTAF := TAFGetStat( "S-2200", AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC) )		
				EndIf
				
				cFilAnt  := cBkpFil

				//Layout 2.3 do eSocial
				If cVersEnvio >= "2.3" .And. (cStatTAF != "4" .Or. (cStatTAF == "4" .And. nRetifica == 1))
					lRet:=  fIntAdmiss(cAliasSRA, /*lAltCad*/, 3, "S2200", cFilEnv , /*aDep*/, CodUnico, /*oModel*/, "CRG", @aErros, cVersEnvio, /*oMdlRFZ*/, aFilial, /*oMdlRS9*/, /*cFilTrf*/, /*dDtAdm*/, /*aVinc*/, /*cFilDe*/, .F., /*cCCAte*/, /*cArqSR6*/, /*cSR6Fil*/, /*cEmpP*/, /*cArqSRJ*/, (cAliasSRA)->RA_FILIAL, /*cArqSQ3*/, /*cSQ3Fil*/, nPar2, /*cSVAObs*/, /*lTrfCNPJ*/, /*lNovoCPF*/, /*cNovoCodUnic*/, /*lAjustaDep*/, @lJorSInt)
				EndIf//Layout 2.3
				//Filial/Mat.: - CPF
				cDadosFunc := OemToAnsi(STR0143) + " " + (cAliasSRA)->RA_FILIAL + "/" + (cAliasSRA)->RA_MAT + " - " + OemToAnsi(STR0088) +": " + (cAliasSRA)->RA_CIC + " - " + (cAliasSRA)->RA_NOMECMP

				If SRA->RA_CATEFD $ "107/108".And. dToS(SRA->RA_ADMISSA) >= "20200421"
					nContErr++
					aAdd( aDados, PADR(OemToAnsi(STR0166), 15) + " " + PADR(cDadosFunc, 77) + " " + OemToAnsi(STR0285) )//"Trabalhador"##"Data de admissão incompatível com a categoria do funcionário"
				ElseIf cStatTAF == "4" .And. nRetifica == 2
					nContErr++
					aAdd( aDados, PADR(OemToAnsi(STR0166), 15) + " " + PADR(cDadosFunc, 77) + " " + PADR(OemToAnsi(STR0225), 33) )//"Trabalhador"##"Não foi retificado."
				ElseIf cStatTAF $ "2/6"
					nContErr++
					aAdd( aDados, PADR(OemToAnsi(STR0166), 15) + " " + PADR(cDadosFunc, 77) + " " + PADR(OemToAnsi(STR0284), 33) )//"Trabalhador"##"Está em trânsido ao RET."
				ElseIf Len( aErros ) <= 0
					//--------------------------------------------------------------
					//| Os erros serão impressos alinhados | Tamanho cabecalho: 132
					//| Colunas: Eventos (25+1) | Item/Registro (77+1) | Status (26)
					//| PADR("Eventos", 25) + " " + PADR("ITEM/REGISTRO", 77) + " " + PADR("STATUS", 26))
					//------------------------------------------------------------------------------------------------------------------------------------
					//Trabalhador               XYZABC1230                                                                   Enviada ao TAF com sucesso."

					cMsgEnvio 	:= If(lMiddleware,PADR(OemToAnsi(STR0276), 33),PADR(OemToAnsi(STR0030), 33))			
					If cVersEnvio >= "9.0" 
						If lJorSInt
							// Trabalhador + Dados do Trabalhador + "Enviado ao Middleware" + "- " + "Possui Sequência de Turno sem Intervalo Definido, verificar Tabela de Horário Padrão do Turno. "       
							aAdd( aDados, PADR(OemToAnsi(STR0166), 15) + " " + PADR(cDadosFunc, 77) + " " + cMsgEnvio + " - " + OemToAnsi(STR0301) )
						Else
							aAdd( aDados, PADR(OemToAnsi(STR0166), 15) + " " + PADR(cDadosFunc, 77) + " " + cMsgEnvio )	
						EndIf
					Else
						aAdd( aDados, PADR(OemToAnsi(STR0166), 15) + " " + PADR(cDadosFunc, 77) + " " + cMsgEnvio )				
					EndIf		

					//Tratativa do estado civil do trabalhador
					If ( (cAliasSRA)->RA_ESTCIVI $ "M|O")
						aAdd( aDados, OemToAnsi(STR0168) ) //"O registro foi integrado, entretanto sem a tag <estCiv>. O Est. Civil do trab. não corresponde a nenhuma categoria válida do eSocial."
						aAdd(aDados, "" )
					EndIf

					nContador++
				Else
					//Le o erro e quebra num array de acordo com a quantidade de enter
					aConcat := StrTokArr(aErros[1], chr(13)+chr(10))

					//Adiciona cabeçalho do erro (Filial + Matricula - Não enviado ao TAF)
					//------------------------------------------------------------------------------------------------------------------------------------
					//Trabalhador               XYZABC1230                                                                    Nâo Enviada ao TAF         "
					//Comentario do erro
					//
					//------------------------------------------------------------------------------------------------------------------------------------
					If lMiddleware
						aAdd( aDados, PADR(OemToAnsi(STR0166), 15) + " " + PADR(cDadosFunc, 77) + " " + PADR(OemToAnsi(STR0275), 33) )
					Else
						aAdd( aDados, PADR(OemToAnsi(STR0166), 15) + " " + PADR(cDadosFunc, 77) + " " + PADR(OemToAnsi(STR0029), 33) )
					EndIf

					//Atribui o erro no aDados para impressão em tela
					If( Len(aErros) == 1 )
						//Se o erro for referente ao afastamento #32#
						If(aErros[1] == "AFAST")
							aErros := {}
							aAdd( aDados, OemToAnsi(STR0172)) //"Não sera possivel efetuar a integração. O trabalhador possui afastamento com o tipo '32'. Verifique a situação e tente novamente."

						//Se o erro for referente ao tipo de jornada
						ElseIf(aErros[1] == "TPJORN")
							aErros := {}
							aAdd( aDados, OemToAnsi(STR0173)) //"Não será possível efetuar a integração. O trabalhador possui um turno de trabalho descontinuado ou inválido para o eSocial."
						//Se o erro for referente a um erro qualquer
						Else
							FeSoc2Err(aErros[1], @cMsgErro, Iif(aErros[1] != '000026', 1, 2))
							aAdd(aDados, aErros[1] + " - " + Alltrim(cMsgErro))
						EndIf
					Else
						For nX := 2 To len(aConcat) step 2
							aAdd(aDados, aConcat[nX] )
						Next
					EndIf

					//Atribui o erro no aDados para impressão em tela
					For nX := 1 To len(aAuxDados)
						aAdd(aDados, aAuxDados[nX] )
					Next
					nContErr++
					aAdd(aDados, "" )
				EndIf
			Else
				nContErr++
				//Filial/Mat.: - CPF
				cDadosFunc := OemToAnsi(STR0143) + " " + (cAliasSRA)->RA_FILIAL + "/" + (cAliasSRA)->RA_MAT + " - " + OemToAnsi(STR0088) +": " + (cAliasSRA)->RA_CIC + " - " + (cAliasSRA)->RA_NOMECMP

				If lMiddleware
					aAdd( aDados, PADR(OemToAnsi(STR0166), 15) + " " + PADR(cDadosFunc, 77) + " " + PADR(OemToAnsi(STR0275), 33) )
				Else
					aAdd( aDados, PADR(OemToAnsi(STR0166), 15) + " " + PADR(cDadosFunc, 77) + " " + PADR(OemToAnsi(STR0029), 33) )
				EndIf

				//Atribui o erro no aDados para impressão em tela
				For nX := 1 To len(aAuxDados)
					aAdd(aDados, aAuxDados[nX] )
				Next
				aAdd(aDados, "" )
			EndIf

			//Incrementa regua
			IncProc(OemToAnsi(STR0069) + " " +(cAliasSRA)->RA_FILIAL+ "-" +(cAliasSRA)->RA_MAT) //##"Gerando o registro de: "

			(cAliasSRA)->(DBSKIP())
		EndDo

		If lTemRegs
			aAdd(aDados,"")
			aAdd(aDados,(OemToAnsi(STR0111)+" "+ OemToAnsi(STR0110) + " " + OemToAnsi(STR0166) )) // "Resumo" ###"Carga Inicial" "Trabalhador"
			aAdd(aDados, OemToAnsi(STR0009)+": " +  SecsToTime(nHrInicio)) // Inicio Processamento: A
			nHrFim := SecsToTime(Seconds())
			aAdd(aDados,+OemToAnsi(STR0010)+":    " + nHrFim) // Fim Processamento:    A
			aAdd(aDados,"")
			aAdd(aDados,OemToAnsi(STR0077)+": " + SecsToTime(Seconds() - nHrInicio)) // Duracao do Processamento
			
			If lMiddleware
				aAdd(aDados,OemToAnsi(STR0277)+": "+ ALLTRIM(STR(nContador))) //Quantidade Registro(s) enviado(s) ao Middleware
			Else
				aAdd(aDados,OemToAnsi(STR0078)+": "+ ALLTRIM(STR(nContador))) // Quantidade Registro(s) enviado(s) ao TAF
			EndIf

			If lMiddleware
				aAdd(aDados,OemToAnsi(STR0279)+": "+ ALLTRIM(STR(nContErr))) // Quantidade Registros Não Enviados ao Middleware
			Else
				aAdd(aDados,OemToAnsi(STR0151)+": "+ ALLTRIM(STR(nContErr))) // Quantidade Registros Não Enviados ao TAF
			EndIf

			aAdd(aDados,"")
			aAdd(aDados,"")
		Endif
	ElseIf nOpcAP == 2
		fGM23IncVI(cTrabVincu,"2100",aLogProc,aFilTAF,cVersEnvio)
	EndIf

	RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fM23Pais  ³ Autor ³ Glaucia Messina       ³ Data ³25/03/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Transforma o cod Pais de 5 digitos para 3 digitos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fM23Pais()                                             	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPais com 5 digitos - IBGE e todo ERP                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cPais com 3 digitos - Tab 22 eSocial                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEM023- fCargVI	    		                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function fM23Pais(cPaisIBGE)
	Local aArea		:= GetArea()
	Local cPaisRFB := cPaisIBGE

	If len(cPaisIBGE) == 5
		cPaisRFB := SUBSTR(cPaisIBGE,2,3)
	EndIf

	RestArea(aArea)
Return cPaisRFB


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGM23Dep    ºAutor  ³Glaucia Messina     º Data ³  25/03/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se há dependentes e carrega Array para Carga      º±±
±±º          ³ trabalhador                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023- GPEM026                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGM23Dep(cFilTrab, cMatTrab)
	Local aArea := GetArea()
	Local aDep := {}
	Local nPosDpInc := SRB->(ColumnPos("RB_INCT"))
	Local cIncTrab := "N"

	dbSelectArea("SRB")
	SRB->(DbSetOrder(1))
	SRB->(MsSeek(cFilTrab + cMatTrab))

	While !SRB->(Eof()) .And. (cFilTrab + cMatTrab == SRB->RB_FILIAL + SRB->RB_MAT)
		If ((SRB->RB_DTBAIXA == CToD("  /  /  ") .OR. SRB->RB_DTBAIXA > dDataBase) .AND. !EMPTY(SRB->RB_TPDEP))

			If(nPosDpInc > 0)
				cIncTrab := Iif( SRB->RB_INCT $ " |1","N","S" )
			EndIf

				Aadd(aDep,{	SRB->RB_TPDEP,;
							AllTrim(SRB->RB_NOME),;
							DtoS(SRB->RB_DTNASC),;
							AllTrim(SRB->RB_CIC),;
							Iif(SRB->RB_TIPIR   == "4","N","S"),;
							Iif(SRB->RB_TIPSF   == "3","N","S"),;
							Iif(SRB->RB_PLSAUDE == "1","S","N"),;
							AllTrim(SRB->RB_COD),;
							cIncTrab,;
							AllTrim(SRB->RB_SEXO)})
		EndIf
		SRB->(dbSkip())
	Enddo

	RestArea(aArea)
Return aDep


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGM23Vinc   ºAutor  ³Glaucia Messina     º Data ³  26/03/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se ha cadastro especifico para vinculo  e devolve º±±
±±º          ³ os dados em formato de array.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023- GPEM026                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGM23Vinc(cFil,cMat,cVersEnvio,oMdl)
	Local aArea      	:= GetArea()
	Local aVinculo   	:= {}
	Local AliasRFZ   	:= "RFZ"
	Local lRfzCmp    	:= RFZ->( ColumnPos( "RFZ_DTTRA" ) ) > 0
	Local cRFZtpadm  	:= ""
	Local cRFZindadm 	:= ""
	Local cRFZindpem 	:= ""
	Local cRFZcnpjan 	:= ""
	Local cRFZmatant 	:= ""
	Local cRFZdtadn  	:= Ctod("  /  /    ")
	Local cRFZobsvan 	:= ""
	Local cRFZdttra  	:= Ctod("  /  /    ")
	Local cOnus		 	:= ""
	Local cCategOrig 	:= ""
	Local cNumPr		:= ""
	local lCmpOnus		:= RFZ->( ColumnPos( "RFZ_CATEG" ) ) > 0 .And. RFZ->( ColumnPos( "RFZ_ONUS" ) ) > 0
	Local lRfzTpIns    	:= RFZ->( ColumnPos( "RFZ_TPINSC" ) ) > 0
	Local cRFZTpIns 	:= ""

	Default cVersEnvio	:= "2.2"
	Default oMdl 		:= Nil

	If Upper(AllTrim(FunName())) == "GPEA926"
		If !oMdl:IsDeleted()
			cRFZtpadm  := oMdl:GetValue("RFZ_TPADM")
			cRFZindadm := oMdl:GetValue("RFZ_INDADM")
			cRFZindpem := oMdl:GetValue("RFZ_INDPEM")
			cRFZcnpjan := oMdl:GetValue("RFZ_CNPJAN")
			cRFZmatant := oMdl:GetValue("RFZ_MATANT")
			cRFZdtadn  := oMdl:GetValue("RFZ_DTADAN")
			cRFZobsvan := oMdl:GetValue("RFZ_OBSVAN")

			If lRfzCmp .And. cVersEnvio >= "2.4"
				cRFZdttra := oMdl:GetValue("RFZ_DTTRA")
			EndIf
			
			If cVersEnvio >= "9.0.00" .And. RFZ->(ColumnPos("RFZ_PRCAD")) > 0
				cNumPr := oMdl:GetValue("RFZ_PRCAD")
			Endif
			
			If lCmpOnus
				cOnus	:= oMdl:GetValue("RFZ_ONUS")
				cCategOrig	:= oMdl:GetValue("RFZ_CATEG")
			Endif
			
			If lRfzTpIns
				cRFZTpIns	:= oMdl:GetValue("RFZ_TPINSC")
			EndIf
			
			Aadd(aVinculo,	{;
						cRFZtpadm,;							//1
						cRFZindadm,;						//2
						IIf(cRFZindpem=="S","1","2"),;		//3
						cRFZcnpjan,;						//4
						cRFZmatant,;						//5
						cRFZdtadn,;							//6
						ALLTRIM(SUBSTR(cRFZobsvan,1,254)),;	//7
						cRFZdttra,;							//8
						cOnus,;								//9
						cCategOrig,;						//10
						cNumPr,;							//11
						,;									//12
						cRFZTpIns})							//13
		endif
	Else
		dbSelectArea(AliasRFZ)
		RFZ->(DbSetOrder(1))
		RFZ->(MsSeek(cFil + cMat))

		While !RFZ->(Eof()) .And. (cFil + cMat == RFZ->RFZ_FILIAL + RFZ->RFZ_MAT)
			If !(EMPTY(RFZ->RFZ_TPADM)) .AND. !(EMPTY(RFZ->RFZ_INDADM)) .AND. !(EMPTY(RFZ->RFZ_INDPEM))

				If cVersEnvio >= "9.0.00" .And. RFZ->(ColumnPos("RFZ_PRCAD")) > 0
					cNumPr := RFZ->RFZ_PRCAD
				Endif

				Aadd(aVinculo,	{;
								RFZ->RFZ_TPADM,;															//1
								RFZ->RFZ_INDADM,;															//2
								IIf(RFZ->RFZ_INDPEM=="S","1","2"),;											//3
								RFZ->RFZ_CNPJAN,;															//4
								RFZ->RFZ_MATANT,;															//5
								RFZ->RFZ_DTADAN,;															//6
								ALLTRIM(SUBSTR(RFZ->RFZ_OBSVAN,1,254)),;									//7
								Iif(cVersEnvio >= "2.4" .And. lRfzCmp,RFZ->RFZ_DTTRA,Ctod("  /  /    ")),;	//8
								Iif(lCmpOnus, RFZ_ONUS, ""),;												//9
								Iif(lCmpOnus, RFZ_CATEG, ""),;												//10
								cNumPr,;							                                        //11
								,;																			//12
								Iif(lRfzTpIns, RFZ->RFZ_TPINSC, "")})										//13
			EndIf
			RFZ->(dbSkip())
		Enddo
	EndIf

	RestArea(aArea)
Return aVinculo


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGM23Sind   ºAutor  ³Glaucia Messina     º Data ³  27/03/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carga de Sindicatos                                        º±±
±±º          ³ devolve em formato de array.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023- fCargVI                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGM23Sind()
	Local aArea := GetArea()
	Local aSindicato := {}

	dbSelectArea("RCE")
	RCE->(DbSetOrder(1))
	RCE->( dbGoTop() )

	While !RCE->(Eof())
		If !EMPTY(RCE->RCE_CGC)
			Aadd(aSindicato,{RCE->RCE_FILIAL,;
							RCE->RCE_CODIGO,;
							RCE->RCE_CGC,;
							RCE->RCE_MESDIS})
		EndIf
		RCE->(dbSkip())
	Enddo

	RestArea(aArea)
Return aSindicato


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGM23IncVI  ºAutor  ³Glaucia Messina     º Data ³  28/03/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera Inconsistencias do SRA para TopConnect                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023- fCargVI                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGM23IncVI(cCateg,cEvento, aLogProc, aFilTAF, cVersEnvio)
	Local aArea 	:= GetArea()
	Local cAliasSRA	:= GetNextAlias()
	Local nX		:= 0
	Local nI		:= 0
	Local cMenIni	:= ""
	Local cTitulo	:= ""
	Local cSitQuery	:= "%"
	Local cQryWhere	:= "%"
	Local lOk		:= .T.
	Local cTrabSVinc:= "201202305308401410701711712721722723731734738741751761771781901902903"
	Local cTSV		:= "%"
	Local cQryTSV	:= ""
	Local aLogAux	:= {}
	Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

	Private  aCIC	:= {}

	Default cEvento		:= "2100"
	Default cSituacao	:= " ADFT"
	Default cVersEnvio	:= "2.2"

	//-- Modifica variaveis para a Query
	For nI:=1 to Len(cSituacao)
		cSitQuery += "'"+Subs(cSituacao,nI,1)+"'"
		If ( nI+1 ) <= Len(cSituacao)
			cSitQuery += ","
		Else
			cSitQuery += "%"
		Endif
	Next nI


	cTSV := fSqlIN( cTrabSVinc, 3 )

	aFilTAF[1]:= SubStr(aFilTaf[1],2,Len(aFilTaf[1])-2)
	cQryWhere := '% SRA.RA_FILIAL IN ('+ aFilTAF[1] + ') %'
	cQryTSV	:= '% SRA.RA_CATEFD NOT IN ('+ cTSV + ') %'

	//Query para buscar informacoes Trabalhadores
	BeginSql alias cAliasSRA
		SELECT
			RA_FILIAL, RA_MAT, RA_CIC, RA_PIS, RA_NOMECMP, RA_NOME, RA_SEXO,
			RA_RACACOR, RA_ESTCIVI, RA_GRINRAI,RA_TPDEFFI,RA_REGRA,RA_SEQTURN,
			RA_NASC, RA_CODMUNN, RA_NATURAL, RA_CPAISOR, RA_NACIONC,RA_TPPREVI,
			RA_MAE, RA_PAI, RA_NUMCP, RA_SERCP, RA_UFCP, RA_NJUD14,
			RA_NUMRIC,RA_EMISRIC , RA_DEXPRIC, RA_RG, RA_RGEXP,RA_DTRGEXP,
			RA_RNE, RA_RNEORG, RA_RNEDEXP, RA_CODIGO, RA_OCEMIS, RA_OCDTEXP, RA_OCDTVAL, RA_HABILIT,
			RA_CNHORG, RA_DTEMCNH, RA_DTVCCNH, RA_RESEXT,RA_VIEMRAI, RA_SITFOLH,
			RA_LOGRTP, RA_LOGRDSC, RA_LOGRNUM,RA_COMPLEM, RA_BAIRRO, RA_CEP, RA_CEPCXPO, RA_CODMUN,
			RA_ESTADO, RA_PAISEXT, RA_CODMUN, RA_ESTADO, RA_MUNICIP, RA_CPOSTAL,
			RA_TELEFON, RA_DDDFONE, RA_NUMCELU, RA_DDDCELU,RA_EAPOSEN,
			RA_DATCHEG, RA_DATNATU, RA_CASADBR, RA_FILHOBR,RA_TPJORNA,
			RA_PORTDEF,RA_TELEFON, RA_NUMCELU, RA_EMAIL, RA_EMAIL2, RA_TPCONTR,
			RA_ADMISSA, RA_DEMISSA, RA_CATEFD,RA_CODFUNC, RA_CARGO, RA_SALARIO,
			RA_CATFUNC, RA_ALTOPC, RA_OPCAO, RA_CC, RA_CLASEST, RA_CATCNH, RA_UFCNH, RA_CODUNIC
		FROM
			%table:SRA% SRA
		WHERE
			%exp:cQryTSV%  AND
			SRA.%notDel% AND SRA.RA_SITFOLH IN ( %exp:cSitQuery% ) AND %exp:cQryWhere%
		ORDER BY
			SRA.RA_FILIAL, SRA.RA_MAT
	EndSql

	dbSelectArea(cAliasSRA)

	//Posiciona no inicio do arquivo
	(cAliasSRA)->(dbGoTop())

	aAdd(aLogProc, "")

	While (cAliasSRA)->(!EOF())

		//Consistir os parâmetros informados
		If !Empty(cCCAte)
			If (cAliasSRA)->RA_CC < cCCDe .Or. (cAliasSRA)->RA_CC > cCCAte
				(cAliasSRA)->(DBSKIP())
				Loop
			Endif
		Endif
		If !Empty(cNomeAte)
			If (cAliasSRA)->RA_NOME < cNomeDe .Or. (cAliasSRA)->RA_NOME > cNomeAte
				(cAliasSRA)->(DBSKIP())
				Loop
			Endif
		Endif
		If !Empty(cMatAte)
			If (cAliasSRA)->RA_MAT < cMatDe .Or. (cAliasSRA)->RA_MAT > cMatAte
				(cAliasSRA)->(DBSKIP())
				Loop
			Endif
		Endif
		If !Empty(cFilAte)
			If (cAliasSRA)->RA_FILIAL < cFilDe .Or. (cAliasSRA)->RA_FILIAL > cFilAte
				(cAliasSRA)->(DBSKIP())
				Loop
			Endif
		Endif


		lOk := fG17VSRA (cAliasSRA,2,,,cVersEnvio)

		if !lOk
			cTitulo:= OemToAnsi(STR0066)	// S-2100 ou S-2200 Cadastramento Inicial de Vinculo"
			If  Empty(cMenIni)
				cMenIni := OemToAnsi(STR0084)+": "+ If(cVersEnvio >= "2.3", OemToAnsi(STR0170), OemToAnsi(STR0118) ) + " " + cTitulo 	//##Inconsistências
				aAdd(aLogAux, cMenIni)
				aAdd(aLogAux, "")
				
				If lMiddleware
					aAdd(aLogAux, OemToAnsi(STR0278)) // ##"Devido as inconsistencias abaixo: campos sem conteudo ou Trabalhadores com Multiplos Vinculos, os registros não serão enviados ao Middleware:"
				Else
					aAdd(aLogAux, OemToAnsi(STR0085)) // ##"Devido as inconsistencias abaixo: campos sem conteudo ou Trabalhadores com Multiplos Vinculos, os registros não serão enviados ao TAF:"
				EndIf
				
				aAdd(aLogAux, "")

				For nX := 1 To Len(aLogProc)
					aAdd(aLogAux, aLogProc[nX])
				Next nX

				aLogProc := aClone(aLogAux)
				aLogAux  := Array(0)
			EndIf
		Endif
		(cAliasSRA)->(dbSkip())
	EndDo

	aAdd(aLogProc, "")
	RestArea(aArea)

Return aLogProc


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGM23CC     ºAutor  ³Glaucia Messina     º Data ³  03/04/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carga de Lotacao do Funcionario.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023- fCargVI                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGM23CTT()
	Local aArea			:= GetArea()
	Local aCTT			:= {}
	Local cCTT	 		:= ""
	Local cCTTRot		:= GetNextAlias()

	BeginSql alias cCTTRot
		SELECT 	 CTT_FILIAL, CTT_CUSTO, CTT_NOME, CTT_TPLOT, CTT_TIPO2, CTT_CEI2, CTT_CLASSE
		FROM	 %table:CTT% CTT
		WHERE 	 CTT_TPLOT = '01'
		AND      CTT.%notDel%
	EndSql

	While (cCTTRot)->(!EOF())
		If (cCTTRot)->CTT_TPLOT == "01"
			//Se CTT exclusiva valida filial
			if empty((cCTTRot)->CTT_FILIAL)
				cCTT := ALLTRIM((cCTTRot)->CTT_CUSTO)
			Else
				cCTT := ALLTRIM((cCTTRot)->CTT_FILIAL+(cCTTRot)->CTT_CUSTO)
			endif

			Aadd(aCTT, {(cCTTRot)->CTT_FILIAL,;
						(cCTTRot)->CTT_CUSTO,;
						(cCTTRot)->CTT_TIPO2,;
						(cCTTRot)->CTT_CEI2,;
						cCTT,;
						(cCTTRot)->CTT_TPLOT,;
						(cCTTRot)->CTT_NOME,;
						(cCTTRot)->CTT_CLASSE})
		EndIf
		(cCTTRot)->(dbSkip())
	EndDo

	(cCTTRot)->( dbCloseArea() )

	RestArea(aArea)

Return aCTT


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGM23SM0    ºAutor  ³Glaucia Messina     º Data ³  03/04/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carga de Estabelecimentos                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023- fCargVI                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGM23SM0(lCAEPF, lGrupo, cGrupo)
	Local aArea			:= GetArea()
	Local aAreaSM0		:= SM0->(GetArea())
	Local aEstabele		:= {}
	Local cCNPJ			:= ""
	Local cFilialLot	:= ""
	Local cTipo			:= ""
	Local cCodigo		:= ""
	Local lRetSM0		:= .T.

	Default lCAEPF := .F.
	Default lGrupo := .F.
	Default cGrupo := FWGrpCompany()

	// Preenche um array com as filiais
	DbSelectArea("SM0")
	SM0->(DbGoTop())

	While SM0->(!EOF())
		If SM0->(ColumnPos("M0_CODIGO"))
			If lGrupo .And. cGrupo <> SM0->M0_CODIGO
				SM0->(dbSkip())
				Loop
			Endif
		Endif

		lRetSM0 := .T.
		cCNPJ	:= ""
		cTipo	:= ""
		cFilialLot := SM0->M0_CODFIL
		cCodigo := SM0->M0_CODIGO
		
		If SM0->M0_TPINSC == 1 	//CEI
			If lCAEPF .And. SM0->M0_PRODRUR $ "1/F"
				lRetSM0 := fBuscaCAEPF( cFilialLot, @cCNPJ)
				If lRetSM0
					cTipo := "3"
				Endif
			Else
				lRetSM0:= fBuscaOBRA(cFilialLot,@cCNPJ)
				cTipo := "4"
			EndIf

		ElseIf SM0->M0_TPINSC == 2 //CNPJ
			cCNPJ:= SM0->M0_CGC
			cTipo:= "1"
		
		ElseIf SM0->M0_TPINSC == 3 //CPF
			If lCAEPF
				lRetSM0:= fBuscaCAEPF( cFilialLot, @cCNPJ)
				
				If lRetSM0
					cTipo := "3"
				ElseIf (lRetSM0 := fBuscaOBRA( cFilialLot, @cCNPJ ))
					cTipo := "4"
				Endif
			EndIf
		EndIf

		Aadd(aEstabele, {ALLTRIM(cFilialLot),;
						cCNPJ,;
						cTipo,;
						lRetSM0,;
						cCodigo,;
						Iif(Alltrim(SM0->M0_PRODRUR) == "2",.T.,.F.)  })
		SM0->(dbSkip())

	EndDo
	
	RestArea(aAreaSM0)
	RestArea(aArea)

Return aEstabele


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGM23Memo   ºAutor  ³Glaucia Messina     º Data ³  07/04/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carga Campo Memo Carga Trabalhadores                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023- fCargVI e fCargTSV                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGM23Memo(cEvento)
	Local aArea			:= GetArea()
	Local aAreaSRA		:= SRA->(GetArea())
	Local cAliasSRA		:= "SRA"
	Local aMemoDefi		:= {}
	Local lCargMemo 	:= .F.

	// Preenche um array com as filiais
	dbSelectArea(cAliasSRA)
	(cAliasSRA)->(dbGoTop())
	While (cAliasSRA)->(!EOF())
		lCargMemo := .F.
		If cEvento == '2600' .AND. (Empty((cAliasSRA)->RA_DEMISSA)) .AND. ;
			(!(Empty((cAliasSRA)->RA_CIC)) .AND. ;
			(!(Empty((cAliasSRA)->RA_NOMECMP)) .OR. !(EMPTY((cAliasSRA)->RA_NOME))) .AND.;
			!(Empty((cAliasSRA)->RA_SEXO)) .AND. !(Empty((cAliasSRA)->RA_RACACOR)) .AND. ;
			!(Empty((cAliasSRA)->RA_GRINRAI)) .AND.;
			!(Empty((cAliasSRA)->RA_NASC)) .AND. !(Empty((cAliasSRA)->RA_CPAISOR)) .AND. ;
			!(Empty((cAliasSRA)->RA_NACIONC)) .AND. ;
			!(Empty((cAliasSRA)->RA_ADMISSA)) .AND. ;
			!(Empty((cAliasSRA)->RA_ESTCIVI)) .AND. ;
			((cAliasSRA)->RA_ESTCIVI $ GpeEstCivi("3")) .AND. ;
			((cAliasSRA)->RA_CATEFD $ '201|202|203|304|401|721|722|731|732|734|735|736|741|901|')) .AND. ;
			!EMPTY((cAliasSRA)->RA_OBSDEFI)

			lCargMemo := .T.
		ElseIf 	cEvento == '2100' .AND.  (Empty((cAliasSRA)->RA_DEMISSA)) .AND. ;
			(!(Empty((cAliasSRA)->RA_CIC)) .AND. !(Empty((cAliasSRA)->RA_PIS)) .AND.;
			(!(Empty((cAliasSRA)->RA_NOMECMP)) .OR. !(EMPTY((cAliasSRA)->RA_NOME))) .AND.;
			!(Empty((cAliasSRA)->RA_SEXO)) .AND. !(Empty((cAliasSRA)->RA_RACACOR)) .AND. ;
			!(Empty((cAliasSRA)->RA_GRINRAI)) .AND.;
			!(Empty((cAliasSRA)->RA_NASC)) .AND. !(Empty((cAliasSRA)->RA_CPAISOR)) .AND. ;
			!(Empty((cAliasSRA)->RA_NACIONC)) .AND. ;
			!(Empty((cAliasSRA)->RA_ADMISSA)) .AND. !(Empty((cAliasSRA)->RA_VIEMRAI)) .AND. ;
			!(Empty((cAliasSRA)->RA_TPPREVI)) .AND. ;
			!(Empty((cAliasSRA)->RA_TPJORNA)) .AND. !(Empty((cAliasSRA)->RA_CARGO)) .AND. ;
			!(Empty((cAliasSRA)->RA_CODFUNC)) .AND. ;
			!(Empty((cAliasSRA)->RA_CATFUNC)) .AND. !(Empty((cAliasSRA)->RA_TPCONTR)) .AND. ;
			!(Empty((cAliasSRA)->RA_CC)) .AND. ;
			!(Empty((cAliasSRA)->RA_ESTCIVI)) .AND. ;
			!(Empty((cAliasSRA)->RA_OPCAO)) .AND. ;
			((cAliasSRA)->RA_ESTCIVI $ GpeEstCivi("3")) .AND. ;
			(cAliasSRA)->RA_CATEFD $ '101|102|103|104|105|106|301|302|303|305|306|309|701|711|') .AND. ;
			!EMPTY((cAliasSRA)->RA_OBSDEFI)

			lCargMemo := .T.
		EndIf

		If lCargMemo
			Aadd(aMemoDefi,{;
				(cAliasSRA)->RA_FILIAL,;
				(cAliasSRA)->RA_MAT,;
				(cAliasSRA)->RA_OBSDEFI})
		EndIf

		(cAliasSRA)->(dbSkip())
	EndDo
	RestArea(aAreaSRA)
	RestArea(aArea)
Return aMemoDefi


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGM23Tur    ºAutor  ³Glaucia Messina     º Data ³  09/04/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carga Campo Turno/Horario Trabalhadores com Vinculo        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023- fCargVI                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGM23Tur(cAliasSRA,cTurno,cRegra,cSeqT,cFilEnv, cVersEnvio, lHist)
	Local aArea			:= GetArea()
	Local aTurnos		:= {}
	Local aAreaSR6  	:= SR6->(GetArea())
	Local aAreaSPA  	:= SPA->(GetArea())
	Local aAreaSPJ  	:= SPJ->(GetArea())
	Local lSemFilial 	:= .F.
	lOCAL lRegra 		:= .F.
	Local lTurno 		:= .F.
	lOCAL cChaveSPA 	:= ""
	lOCAL cChaveSR6 	:= ""
	Local cChaveSPJ 	:= ""
	Local cSeek 		:= ""
	Local nPosH 		:= ""
	Local cChave 		:= ""
	Local lErro 		:= .F.
	Local cDia  		:= ""
	Local cHrEntrada	:= ""
	Local cSaiInt		:= ""
	Local cEntrInt		:= ""
	Local cHrSaida		:= ""
	Local nDiaSem		:= 0
	Local aDiaSem		:= {{"8","Dom: "},{"2","Seg: "},{"3","Ter: "},{"4","Qua: "},;
	{"5","Qui: "},{"6","Sex: "},{"7","Sab: "}}
	Local cCond1		:= ""
	Local cCond2		:= ""

	Default cTurno		:= ""
	Default cRegra		:= ""
	Default cSeqT		:= ""
	Default cFilEnv		:= ""
	Default cVersEnvio 	:= ""
	Default lHist		:= .F.

	dbSelectArea("SR6")
	dbSelectArea("SPJ")
	dbSelectArea("SPA")
	DbSelectArea("SPF")

	SR6->(dbSetOrder(1))
	SPA->(dbSetOrder(1))
	SPJ->(dbSetOrder(1))
	SPF->(dbSetOrder(1))
	SR6->(dbGoTop())

	If FindFunction("fBuscUltTurn") .And. FunName()!= "PONA160" .And. FunName()!= "GPEA180" .And. Procname(1) != "FINT2260" .And. !lHist
		fBuscUltTurn((cAliasSRA)->RA_MAT,cFilEnv,@cTurno,@cRegra)
	EndIf

	If Empty(cTurno)
		cTurno := (cAliasSRA)->RA_TNOTRAB
	Endif
	If empty(cRegra)
		cRegra:=(cAliasSRA)->RA_REGRA
	Endif

	If cVersEnvio >= "9.0.00" .And. Empty(cSeqT)
		cSeqT:=(cAliasSRA)->RA_SEQTURN
	Endif

	If empty(xFilial("SR6"))
		lSemFilial := .T.
	Endif

	//Procura Regra
	lRegra := .F.
	dbSelectArea("SPA")
	SPA->(dbGoTop()) //Posiciona no inicio da tabela de regras

	cChaveSPA := xFilial("SPA",cFilEnv)+ cRegra

	If dbseek(cChaveSPA) // so gera se a regra for encontrada
		lRegra := .T.
	Endif

	//Procura Turno
	lTurno := .F.
	dbSelectArea("SR6")
	SR6->(dbGoTop()) //Posiciona no inicio da tabela de regras
	cChaveSR6 := xFilial("SR6",cFilEnv)+ cTurno

	If dbseek(cChaveSR6) // so gera se o turno for encontrado
		lTurno := .T.
	Endif

	If lTurno .and. lRegra
		dbSelectArea("SPJ")
		SPJ->(dbGoTop()) //Posiciona no inicio do arquivo temporario
		If !Empty(cFilEnv)
			cFil:= xFilial("SPJ", cFilEnv)
		Else
			cFil:= xFilial("SPJ")
		EndIf
		If cVersEnvio >= "9.0.00"
			cChaveSPJ 	:= cFil + cTurno + cSeqT
			cCond1		:= "( EMPTY(SPJ->PJ_FILIAL) .AND. cTurno == SPJ->PJ_TURNO .And. cSeqT == SPJ->PJ_SEMANA)" 
			cCond2		:= "( !EMPTY(SPJ->PJ_FILIAL) .AND. cFil+cTurno+cSeqT == SPJ->PJ_FILIAL + SPJ->PJ_TURNO + SPJ->PJ_SEMANA)"
		Else
			cChaveSPJ 	:= cFil + cTurno 
			cCond1		:= "( EMPTY(SPJ->PJ_FILIAL) .AND. cTurno == SPJ->PJ_TURNO)""
			cCond2		:= "( !EMPTY(SPJ->PJ_FILIAL) .AND. cFil+cTurno == SPJ->PJ_FILIAL + SPJ->PJ_TURNO )""
		EndIf
		If dbseek(cChaveSPJ) // so gera se o turno for encontrado
			While SPJ->(!EOF()) .And. (&(cCond1) .Or. &(cCond2) ) 
				//Controle para gravar o domingo
				cDia := SPJ->PJ_DIA
				If cDia == "1"
					cDia := "8"
				Endif

				//Monta chave de busca
				If Empty(SPJ->PJ_FILIAL)
					cSeek := SPJ->PJ_TURNO + SPA->PA_CODIGO + SPJ->PJ_SEMANA + cDia
				Else
					cSeek := SPJ->PJ_FILIAL + SPJ->PJ_TURNO + SPA->PA_CODIGO + SPJ->PJ_SEMANA + cDia
				Endif
				If (SPJ->PJ_SAIDA4 + SPJ->PJ_SAIDA3 + SPJ->PJ_SAIDA2 + SPJ->PJ_SAIDA1 + SPJ->PJ_ENTRA4 + SPJ->PJ_ENTRA3 + SPJ->PJ_ENTRA2 + SPJ->PJ_ENTRA1 == 0) .OR. (SPJ->PJ_TPDIA <> "S")
					lErro := .T.
				Endif

				nPosH 	:= aScan( aTurnos , { |x| x[2] == cSeek  } )
				If nPosH == 0 .and. !lErro
					If Empty(cVersEnvio) .Or. cVersEnvio < "9.0.00"
						If Empty(SPJ->PJ_FILIAL)
							cChave := SPJ->PJ_TURNO + SPA->PA_CODIGO + SPJ->PJ_SEMANA + cDia
						Else
							cChave := SPJ->PJ_FILIAL + SPJ->PJ_TURNO + SPA->PA_CODIGO + SPJ->PJ_SEMANA + cDia
						Endif	

						aAdd( aTurnos ,{cChave,;
											cDia})
					Else
						//Verifica o horário de entrada:
						cHrEntrada	:=  StrTran(StrZero(SPJ->PJ_ENTRA1, 5, 2), ".", ":")

						//Verifica o horário de saída:
						cHrSaida := ""
						If SPJ->PJ_SAIDA4 <> 0 .Or. SPJ->PJ_ENTRA4 <> 0
							cHrSaida := StrTran(StrZero(SPJ->PJ_SAIDA4, 5, 2), ".", ":")
						ElseIf SPJ->PJ_SAIDA3 <> 0 .Or. SPJ->PJ_ENTRA3 <> 0
							cHrSaida := StrTran(StrZero(SPJ->PJ_SAIDA3, 5, 2), ".", ":")
						ElseIf SPJ->PJ_SAIDA2 <> 0 .Or. SPJ->PJ_ENTRA2 <> 0
							cHrSaida := StrTran(StrZero(SPJ->PJ_SAIDA2, 5, 2), ".", ":")
						Else
							cHrSaida := StrTran(StrZero(SPJ->PJ_SAIDA1, 5, 2), ".", ":")
						EndIf

						//Acrescenta na chave o horário de saída e entrada
						cChave	:= ""
						nDiaSem := aScan(aDiaSem, {|x| x[1] = cDia})
						If nDiaSem > 0
							cChave	:= "Seq. " + SPJ->PJ_SEMANA + ": " + aDiaSem[nDiaSem,2] + cHrEntrada + " a " + cHrSaida
						EndIF

						//Verifica se possui intervalo SREP preenchido e inclui na string o intevalo
						cSaiInt		:= ""
						cEntrInt	:= ""
						If SPJ->PJ_INTSREP == "1I" .And. (SPJ->PJ_SAIDA1 <> 0 .Or. SPJ->PJ_ENTRA2 <> 0)
							cSaiInt		:= StrTran(StrZero(SPJ->PJ_SAIDA1, 5, 2), ".", ":")
							cEntrInt	:= StrTran(StrZero(SPJ->PJ_ENTRA2, 5, 2), ".", ":")
							cChave	+= " - Interv.: " + cSaiInt  + " a " + cEntrInt
						ElseIf SPJ->PJ_INTSREP == "2I" .And. (SPJ->PJ_SAIDA2 <> 0 .Or. SPJ->PJ_ENTRA3 <> 0)
							cSaiInt		:= StrTran(StrZero(SPJ->PJ_SAIDA2, 5, 2), ".", ":")
							cEntrInt	:= StrTran(StrZero(SPJ->PJ_ENTRA3, 5, 2), ".", ":")
							cChave	+= " - Interv.: " + cSaiInt  + " a " + cEntrInt
						ElseIf SPJ->PJ_INTSREP == "3I" .And. (SPJ->PJ_SAIDA3 <> 0 .Or. SPJ->PJ_ENTRA4 <> 0)
							cSaiInt		:= StrTran(StrZero(SPJ->PJ_SAIDA3, 5, 2), ".", ":")
							cEntrInt	:= StrTran(StrZero(SPJ->PJ_ENTRA4, 5, 2), ".", ":")
							cChave	+= " - Interv.: " + cSaiInt  + " a " + cEntrInt
						EndIf

						//Grava no array a descrição dos horários:
						aAdd( aTurnos ,{cChave, cDia})
					EndIf
				Endif
				lErro := .F.
				SPJ->(dbSkip())
			Enddo
		Endif
	Endif

	RestArea(aAreaSR6)
	RestArea(aAreaSPJ)
	RestArea(aAreaSPA)
	RestArea(aArea)

Return (aTurnos)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGM23Afast   ºAutor  ³Glaucia Messina     º Data ³  26/03/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se ha cadastro especifico para vinculo  e devolve º±±
±±º          ³ os dados em formato de array.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023- GPEM026                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGM23Afast(cFil,cMat,dDataRef)
	Local aArea 	:= GetArea()
	Local aAfastFun := {}

	dbSelectArea("SR8")
	SR8->(DbSetOrder(1))
	SR8->(MsSeek(cFil + cMat))

	While !SR8->(Eof()) .And. (cFil + cMat == SR8->R8_FILIAL + SR8->R8_MAT)
	If (SR8->R8_DATAINI <= dDataRef) .And. (Empty(SR8->R8_DATAFIM) .Or. (SR8->R8_DATAFIM >= dDataRef))
			Aadd(aAfastFun,{;
				dTos(SR8->R8_DATAINI),;
				SR8->R8_TPEFD })
		EndIf
		SR8->(dbSkip())
	Enddo

	RestArea(aArea)
Return(aAfastFun)
