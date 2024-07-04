//TODO Ajustar menu que chama as rotinas de manipulação do XML

#Include 'Protheus.ch'
#include 'Fileio.ch'
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

#Define F_BLOCK  512
#DEFINE PDTE_VALID     "1" // Pendente Validação
#DEFINE VALIDO         "2" // Valido
#DEFINE INVALIDO       "3" // Inválido
#DEFINE ENV_ANS        "4" // Enviado ANS
#DEFINE CRIT_ANS       "5" // Criticado ANS
#DEFINE ACAT_ANS       "6" // Acatado ANS
#DEFINE CANCELADO      "7" // Cancelado

#DEFINE SIB_INCLUIR	   "1" // Incluir
#DEFINE SIB_RETIFIC	   "2" // Retificar
#DEFINE SIB_MUDCONT	   "3" // Mud.Contrat
#DEFINE SIB_CANCELA	   "4" // Cancelar
#DEFINE SIB_REATIVA	   "5" // Reativar

#DEFINE OBRIGATORIO  1	 // Campo Obrigatorio
#DEFINE OPCIONAL 2	 // Campo Opcional
#DEFINE NAOENVIADO 3	 // Campo Não Enviado

#DEFINE GERAOPCION  1 // Gera campos opcionais
#DEFINE NAOGERAOPC  2 // Não gera campos opcionais

//Pocições do array de campos
#DEFINE COLUNA  1
#DEFINE POSICAO 2
#DEFINE TAG 3
#DEFINE TIPO_INC 4
#DEFINE TIPO_RET 5

//#DEFINE ALL "02"

STATIC cNamCab := "cabsib.xml"
STATIC cNamTmp := "tmpsib.xml"
STATIC cNmHash := "hashsib.tmp"
STATIC cNomPLS := "TOTVS SAÚDE CENTRAL DE OBRIGAÇÕES (SIGACEN)"
STATIC cFabApl := "TOTVS SA"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLCNXMLSIB

Gera o arquivo XML para o SIB

@param cCodOpe		Numero de registro da operadora na ANS
@param cCodObr		Chave da obrigacao
@param cCodComp		Chave do compromisso
@param cAno			Ano do compromisso

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLCNXMLSIB(cCodOpe,cCodObr,cCodComp,cAno,cTipo,lParcial)

	Local cTexto	 := ""
	Local cDirSib    := ""
	Local lOk		 := .T.
	Local cPerg      := ''

	Default cTipo    := ""
	Default lParcial := .F.

	If cTipo="2" //Sib
		Iif(lParcial,cPerg := 'PLSSIBXMLP', cPerg := 'PLSSIBXML')
		If Pergunte(cPerg,.T.,"Parâmetros Geração SBX",.T.)

			//Valido se os XSDs estão na pasta do SIB
			if !existDir("\sib")
				nRet := makeDir( "\sib" )
				if nRet != 0
					lAdminEmp := .T.
					lOk := .F.
					cTexto := "Não foi possível criar o diretório " + GetPvProfString(cEnvServ, "RootPath", "C:\MP811\Protheus_Data", GetADV97()) + "\sib" + " "  //"Não foi possível criar o diretório \cfglog no servidor"###"C:\MP811\Protheus_Data"
					cTexto += Replicate("-",30) + Chr(13)
					cTexto += Replicate("-",30) + Chr(13)
				endIf
			endif

			if lOk

				cDirSib := "\sib"

				cArq := ""
				aArqSch := directory(cDirSib + "\sib.xsd")
				If Len(aArqSch) == 0
					cArq := "sib.xsd"
				EndIf

				If !Empty(cArq)
					cTexto += "O arquivo "+ cDirSib +"\" + cArq + " não foi encontrado no servidor." + Chr(13)
					cTexto += Replicate("-",30) + Chr(13)
					cTexto += Replicate("-",30) + Chr(13)
					LogGerArq(cTexto)
				Else
					if lHabMetric .and. lLibSupFw .and. lVrsAppSw
						FWMetrics():addMetrics(IIF(lParcial,"Gerar Arquivo XML Parcial","Gerar Arquivo XML"), {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
					endif

					If !lParcial
						MV_PAR09:=""
						MV_PAR10:=""
						MV_PAR11:=""
						MV_PAR12:=""
						MV_PAR13:=""
						MV_PAR14:=""
						MV_PAR15:=""
						MV_PAR16:=""
						MV_PAR17:=""
						MV_PAR18:=""
					EndIF

					//Organiza o XML para envio.
					Processa( {||MontaSIBXml(cCodOpe,cCodObr,cCodComp,cAno) } , "Processando" , "Aguarde geração do XML SIB" , .F. )
				EndIf
			Else
				LogGerArq(cTexto)
			EndIf
		EndIf
	Else
		Alert("Operação não disponível para este tipo de obrigação.")
	EndIf

Return .T.
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MontaSIBXml

Monta as mensagens do SIB XML

@param cSequen		Sequencial do arquivo

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function MontaSIBXml(cCodOpe,cCodObr,cCodComp,cAno, lAuto)

	Local cSeqArq    := "" // Numero sequencial do arquivo
	Local cNamArq    := "" // Nome do Arquivo
	Local cMsg       := "" // Mensagem a ser apresentada no log e ao termino do processamento
	Local cSequen    := ""

	Local dDatDe     := Ctod("  /  /  ") // Movimento de
	Local dDatAte    := Ctod("  /  /  ") // Movimento ate

	Local nRegua     := 0 // tamanho da regua
	Local nRegInc    := 0 // Contador de registros de inclusao
	Local nRegAlt    := 0 // Contador de registros de alteracao
	Local nRegExc    := 0 // Contador de registros de cancelamento
	Local nRegRei    := 0 // Contador de registros de reinclusao
	Local nRegMud    := 0 // Contador de registros de mudanca de plano
	Local nRegNao    := 0 // Contador de registros de mudanca de plano
	Local nFiltrados := 0 // Contador de registros filtrados não obrigatórios

	Local lGeraOpcio := If(Empty(mv_par17) .OR. mv_par17 == 1,1,2)
	Local lCriaLog   := .F. // Gerar aquivo log
	Local lIncrem    := .F. // Incrementar sequencial
	Local lCriouArq  := .F.
	local lCriouCSV  := .F.
	local nCtd       := 100000
	Local aEnviados  := {}
	Local lProcessa  := .t.
	Local cNamBck    :=""
	Local aArq       :={}
	Local nI         := 0
	Private cArqlogx := "PLSSIB_" + Dtos(dDataBase) + "_" + Replace(Time(),":","") + ".LOG" // Nome do arquivo de log da execucao
	Default lAuto    := .F.
	Private cDir     := "" // Diretorio

	dDatDe   	:= dtos(mv_par01)
	dDatAte  	:= dtos(mv_par02)
	cDir     	:= "\sib\"
	cTgtDir  	:= AllTrim(mv_par03)
	lCriaLog 	:= If(mv_par04 == 1,.T.,.F.)
	cCodOpe 	:= Alltrim(mv_par05)
	lIncrem 	:= If(mv_par06 == 1,.T.,.F.)
	lCrit 		:= If(mv_par07 == 1,.T.,.F.)
	lPdteAnt	:= If(mv_par08 == 1,.T.,.F.)

	If lIncrem
		cSequen := B3R->(GetSX8Num("B3R","B3R_SEQARQ"))
	Else
		cSequen := GetNewPar("MV_PLSEQSIB","000000000001")
	EndIf

	cSeqArq  	:= Alltrim(Str(Val(cSequen)))

	If lCriaLog // Cabecalho do log
		cMsg := "Geração do arquivo do SIB - Início: " + Dtos(dDatabase) + " " + Time() + CRLF
		cMsg += "Parâmetros informados para processamento: " + CRLF

		cMsg += "Movimento de: " + dDatDe + CRLF
		cMsg += "Movimento até: " + dDatAte + CRLF
		cMsg += "Número seq. arquivo: " + cSeqArq + CRLF
		cMsg += "Diretório: " + cDir + CRLF
		cMsg += "Gera arquivo log: " + If(lCrialog,"Sim","Não") + CRLF
		if !lAuto
			PlsLogFil(cMsg,cArqlogx)
		EndIf

	EndIf

	nRegua := 13 //N  de incproc que tem no fonte
	ProcRegua(nRegua)
	IncProc("Processando os beneficiários incluídos...")

	While lProcessa

		DadosSIB(dDatDe,dDatAte,lCriaLog,cCodOpe,lCrit,lPdteAnt, lAuto)

		lCriouArq := ASIBSBX(cDir,cSeqArq,lCriaLog,@nRegInc,@nRegAlt,@nRegExc,@nRegRei,@nRegMud,cCodOpe,@cNamArq,lAuto,@aEnviados, @nFiltrados)// Gravacao do arquivo SBX

		nRegNao := InvalSIB(dDatDe,dDatAte,lCriaLog,cCodOpe,lCrit,lPdteAnt, lAuto)

		TRBSIB->(dbCloseArea())

		If lCriouArq
			IncProc("Gravando arquivo SBX a ser enviado ...")

			AtuNomArq(Strtran(cNamArq,cDir,""),cCodOpe,cCodObr,cAno,cCodComp,cSeqArq,lIncrem,getWhere(cCodOpe,dDatAte,dDatDe,lCrit,lPdteAnt),aEnviados)

			If nCtd<=100000
				cNamBck:=cNamArq
			Else
				cNamBck+= CRLF + cNamArq
			Endif

			AADD(aArq,cNamArq)

			If nCtd == (nRegInc + nRegAlt + nRegExc + nRegRei + nRegMud)
				lProcessa:=.T.
				nCtd+= 100000
			Else
				lProcessa:=.F.
			Endif

			If !lProcessa
				// Resumo do processamento
				cMsg := "Arquivo gerado com sucesso - " + cNamBck + CRLF
				cMsg += "Qtde registros inclusão: " + AllTrim(Str(nReginc)) + CRLF
				cMsg += "Qtde registros retificação: " + AllTrim(Str(nRegAlt)) + CRLF
				cMsg += "Qtde registros cancelamento: " + AllTrim(Str(nRegExc)) + CRLF
				cMsg += "Qtde registros reativação: " + AllTrim(Str(nRegRei)) + CRLF
				cMsg += "Qtde registros mudança contratual: " + AllTrim(Str(nRegMud)) + CRLF
				If lGeraOpcio == NAOGERAOPC
					cMsg += "Qtde registros opcionais de retificação filtrados: " + AllTrim(Str(nFiltrados)) + CRLF
				EndIf
				cMsg += "Qtde registros não enviados: " + AllTrim(Str(nRegNao)) + CRLF
				cMsg += "Geração do arquivo do SIB - Término: " + Dtos(dDatabase) + " - " + Time()

			EndIF

			If lCriaLog .AND. !lAuto .AND. !lProcessa
				PlsLogFil(cMsg,cArqLogx)
			EndIf

			For nI:=1 to Len(aArq)
				lCriouCSV := geraCSV(dDatDe,dDatAte,cCodOpe,lPdteAnt,aArq[nI],lAuto)

				If !lAuto
					CpyS2T( aArq[nI], cTgtDir )
					If lCriouCSV
						CpyS2T( Left(aArq[nI],Len(cNamArq)-4) + ".csv", cTgtDir )
						If !lProcessa
							cMsg += CRLF + "Arquivo CSV com os beneficiários não enviados gerado com sucesso. "
						Endif
					EndIf
					If !lProcessa  .And. nI == Len(aArq)
						MsgInfo(cMsg,"Informativo")
					Endif
				EndIf
			Next

		Else
			lProcessa:=.F.
		Endif

	EndDo

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuNomArq

Atualiza a tabela de histórico de alterações marcando o que foi enviado no arquivo com o nome do arquivo.

@param cNamArq Nome do arquivo gerado
@param cSqlInc Query dos registros incluídos
@param cSqlAlt Query dos registros alterados
@param cSqlExc Query dos registros bloqueados
@param cSqlMud Query dos registros com mudança contratual
@param cCodOpe Registro da operadora na ANS
@param cCodObr Código da Obrigação
@param cAno 	 Ano do compromisso
@param cCodComp Código do compromisso

@author TOTVS PLS Team
@since 11/04/2016
/*/
//--------------------------------------------------------------------------------------------------
STATIC FUNCTION AtuNomArq(cNamArq,cCodOpe,cCodObr,cAno,cCodComp,cSeqArq, lIncrem, cWhere, aEnviados)
	Local lRet	     := .T.
	Local cSql	     := ""
	Local nRet       := 0
	Local lGeraOpcio := If(Empty(mv_par17) .OR. mv_par17 == 1,1,2)
	Local cBanco     :=AllTrim(TcGetDB())
	Local lUsarec    :=.T.
	Local nI         :=0
	Local nJ         :=0
	//Cria registro do arquivo que foi enviado para a ANS
	If B3R->(RecLock("B3R",.T.))

		B3R->B3R_FILIAL := xFilial("B3R")
		B3R->B3R_CODOPE := cCodOpe
		B3R->B3R_CDOBRI := cCodObr
		B3R->B3R_ANO := cAno
		B3R->B3R_CDCOMP := cCodComp
		B3R->B3R_ARQUIV := cNamArq
		B3R->B3R_SEQARQ := cSeqArq
		If lIncrem
			B3R->(ConfirmSx8())
		EndIf

		If lGeraOpcio == GERAOPCION .And. !lUsarec
			//Atualização para registros Incluidos
			cSql := " UPDATE " + RetSqlName('B3X') + " SET "
			cSql += " B3X_ARQUIV ='" + cNamArq + "', "
			cSql += " B3X_STATUS ='" + ENV_ANS + "'"
			cSql += " WHERE "
			cSql += "	R_E_C_N_O_ IN (

			If cBanco == "MSSQL"
				cSql += "		SELECT TOP 100000 B3X.R_E_C_N_O_ "
			else
				cSql += "		SELECT B3X.R_E_C_N_O_ "
			Endif

			cSql += "			"+ getFrom() +" "
			cSql += " 			WHERE 1 = 1 "
			cSql += " 	"+ cWhere + "  "

			If cBanco == "ORACLE"
				cSql += " AND ROWNUM = 100000 "
			ElseIf cBanco == "POSTGRES"
				cSql += " LIMIT 100000 "
			EndIf
			cSql += " )"

			nRet := TCSQLEXEC(cSql)
			If nRet >= 0 .AND. SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
				nRet := TCSQLEXEC("COMMIT")
			Endif
		Else

			For nI:=1 To Len(aEnviados)
				aRegs:= StrTokArr(aEnviados[nI,1],",")

				For nJ:=1 To Len(aRegs)
					If Val(aRegs[nJ]) > 0
						UpdEnviados(cNamArq, aRegs[nJ])
					EndIf
				Next
			Next

		EndIf

		B3R->(msUnLock())
		if lIncrem
			RollbackSx8()
		EndIf
	EndIf

Return lRet


Static Function UpdEnviados(cNamArq, cReg)

	Local nRet
	Local cSql      := ""
	Default cNamArq := ""
	Default cReg    := ""

	If !Empty(cReg)

		cSql := " UPDATE " + RetSqlName('B3X') + " SET "
		cSql += " 	B3X_ARQUIV ='" + cNamArq + "', "
		cSql += " 	B3X_STATUS ='" + ENV_ANS + "'"
		cSql += " WHERE "
		cSql += "	R_E_C_N_O_ IN ("+ cReg +")"
		nRet := TCSQLEXEC(cSql)

		If nRet >= 0 .AND. SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
			nRet := TCSQLEXEC("COMMIT")
		Endif

	EndIf

Return nRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChecErro

Funcao criada para capturar o erro e pilha de chamado atulizando as variaveis __cError e __cCallStk
As variaveis devem ser definidas como private nas rotinas que irao ter o controle SEQUENCE implementado

@param e objeto erro

@author TOTVS PLS Team
@since 11/04/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function LogGerArq(cTexto)

	Local oDlg
	Local cMask     := "Arquivos Texto (*.TXT) |*.txt|"

	cTexto := "Log da atualização "+CHR(13)+CHR(10)+cTexto

	__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)

	DEFINE FONT oFont NAME "Mono AS" SIZE 5,12   //6,15

	DEFINE MSDIALOG oDlg TITLE "XML SIB." From 3,0 to 340,417 PIXEL

	@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL

	oMemo:bRClicked := {||AllwaysTrue() }

	oMemo:oFont:=oFont

	DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga

	DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."

	ACTIVATE MSDIALOG oDlg CENTER

Return

/*
Programa  | IncluiSIB Autor  Microsiga             Data   16/02/11
Desc.     Verifica se o registro posicionado de TRBSIB sera enviado co
          mo inclusao
Uso        SIGAPLS
*/
Static Function DadosSIB(dDatDe,dDatAte,lCriaLog,cCodOpe,lCrit,;
		lPdteAnt, lAuto)

	Local cSqlSIB := ""
	Local cStmSIB := ""
	Local lRet := .F.
	Local cSpecWhere := getWhere(cCodOpe, dDatAte, dDatDe,lCrit,lPdteAnt) //Where Especifico para organizar a query
	Local cBanco  :=AllTrim( TCGetDB() )
	Default lAuto := .F.

	/*
		Essa query foi reformulada no intuito de ordernar melhor as inclusões, que que essas venham antes das demais movimentações
		Agora a query inicial pega somente as inclusões e ordena os depententes que devem vir após os beneficiário
	*/
	if Empty(MV_PAR09) .OR. SIB_INCLUIR $ MV_PAR09
		If cBanco == "MSSQL"
			cSqlSIB += " SELECT TOP 100000"
		Else
			cSqlSIB += " SELECT "
		endIf

		cSqlSIB += " ROW_NUMBER() OVER(ORDER BY B3X_DATA, B3K_TIPDEP,B3X_HORA ASC) AS ORDENACAO, " // Incluido o B3K_TIPDEP
		cSqlSIB += getFields()
		cSqlSIB += getFrom()
		cSqlSIB += " WHERE 1=1 "
		cSqlSIB += " AND B3X_OPERA = '"+ SIB_INCLUIR +"' "  //Inclusões
		cSqlSIB += cSpecWhere

		cSqlSIB += " UNION ALL "

	endif

	/*
		Essa query foi reformulada no intuito de ordernar melhor as inclusões
		A segunda query ordena somente por DATA e HORA e sem dar prioridade ao tipo
		e somente do que for diferente de inclusão
	*/
	If cBanco == "MSSQL"
		cSqlSIB += " SELECT TOP 100000"
	Else
		cSqlSIB += " SELECT "
	endIf
	cSqlSIB += " ROW_NUMBER() OVER(ORDER BY B3X_DATA, B3X_HORA ASC) AS ORDENACAO, " // Data e Hora
	cSqlSIB += getFields()
	cSqlSIB += getFrom()
	cSqlSIB += " WHERE 1=1 "
	cSqlSIB += " AND B3X_OPERA <> '"+ SIB_INCLUIR +"' "  //Diferente de Inclusões
	cSqlSIB += " AND B3X_OPERA <> '"+ SIB_MUDCONT +"' "  //Diferente de Mudançacontratual
	cSqlSIB += cSpecWhere


	if Empty(MV_PAR09) .OR. SIB_MUDCONT $ MV_PAR09

		cSqlSIB += " UNION ALL "

		If cBanco == "MSSQL"
			cSqlSIB += " SELECT TOP 100000"
		Else
			cSqlSIB += " SELECT "
		endIf
		cSqlSIB += " ROW_NUMBER() OVER(ORDER BY B3X_DATA, B3K_TIPDEP,B3X_HORA ASC) AS ORDENACAO, " // Incluido o B3K_TIPDEP
		cSqlSIB += getFields()
		cSqlSIB += getFrom()
		cSqlSIB += " WHERE 1=1 "
		cSqlSIB += " AND B3X_OPERA = '"+ SIB_MUDCONT +"' "  //Inclusões
		cSqlSIB += cSpecWhere

	endif

	If cBanco == "ORACLE"
		cSqlSIB += " AND ROWNUM = 100000  "
	ElseIf cBanco == "POSTGRES"
		cSqlSIB += " LIMIT 100000  "
	endIf

	cStmSIB += cSqlSIB

	//Removido o change query, sem o change query é compativel com SQL Server, Oracle e Postgres
	//cStmSIB := ChangeQuery(cSqlSIB)

	If select('TRBSIB') > 0
		TRBSIB->(dbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cStmSIB),"TRBSIB",.F.,.T.)

	If lCrialog .AND. !lAuto
		PlsLogFil("Query SIB: " + cStmSIB,cArqlogx)
	EndIf

	If TRBSIB->(Eof())
		lRet := .F.
	Else
		lRet := .T.
	EndIf

Return {lRet, cSpecWhere}

Static Function getFrom()

	Local cFrom := ""

	cFrom += " FROM " + RetSqlName("B3K") + " B3K "
	cFrom += " LEFT JOIN " + RetSqlName("B3J") + " B3J ON B3J_CODIGO = B3K_CODPRO "
	cFrom += " LEFT JOIN " + RetSqlName("B3X") + " B3X ON B3K.R_E_C_N_O_ = B3X.B3X_BENEF "
	cFrom += " LEFT JOIN " + RetSqlName("B4W") + " B4W ON B4W_MATRIC = B3K_MATRIC "
	cFrom += " AND B4W_DATA = B3X_DATA "
	cFrom += " AND B4W_HORA = B3X_HORA "
	cFrom += " AND B4W_STATUS = '1' "
	cFrom += " AND B4W_FILIAL = '" + xFilial("B4W") + "' "
	cFrom += " AND B4W.D_E_L_E_T_ = ' ' "

Return cFrom


Static Function getWhere(cCodOpe, dDatAte, dDatDe, lCrit, lPdteAnt)

	Local cWhere    := ""
	Local cTpmov    := ''
	Local nI        := 0

	Default cCodOpe	:= ""
	Default dDatAte	:= Dtos("")
	Default dDatDe	:= Dtos("")

	cWhere += " AND B3K_FILIAL = '" + xFilial("B3K") + "' "
	cWhere += " AND B3J_FILIAL = '" + xFilial("B3J") + "' "
	cWhere += " AND B3X_FILIAL = '" + xFilial("B3X") + "' "

	cWhere += " AND B3J_CODOPE = B3K_CODOPE "
	cWhere += " AND B3J_CODIGO = B3K_CODPRO "
	cWhere += " AND B3K.R_E_C_N_O_ = B3X.B3X_BENEF "

	cWhere += " AND B3K_CODOPE = '" + cCodOpe + "' "

	//Olha pela data de inclusão ou se foi criticado no retorno da ANS

	cWhere += " AND ("

	If lPdteAnt //Esta opção envia todos os pendentes com data menor que a dataAte
		cWhere += "(B3X.B3X_DATA <= '" + dDatAte + "' "
		cWhere += " AND B3X_STATUS = '"+VALIDO+"' )"
	Else
		cWhere += "( B3X_DATA BETWEEN '" + dDatDe + "' AND '" + dDatAte + "' "
		cWhere += " AND B3X_STATUS = '"+VALIDO+"' )"
	EndIf

	If lCrit //Esta opção reenvia também quem esta criticado pela ANS
		cWhere += " OR (B3X_STATUS='"+CRIT_ANS+"') "
	EndIf

	cWhere += " ) "

	If AllTrim(MV_PAR09) !=""
		For nI := 1 To Len(AllTrim(MV_PAR09))
			Iif(nI == Len(AllTrim(MV_PAR09)), cTpMov += "'" + SUBSTR(MV_PAR09,nI,1) + "'", cTpMov += "'" + SUBSTR(MV_PAR09,nI,1) + "',")
		Next nI
		cWhere += " AND B3X_OPERA IN (" + cTpmov + ") "
	EndIf

	If AllTrim(MV_PAR10)!=""
		Iif(AllTrim(MV_PAR11)!="",cWhere += " AND B3K_MATRIC BETWEEN '" + MV_PAR10 + "' AND '" + MV_PAR11 + "' ",cWhere += " AND B3K_MATRIC = '" + MV_PAR10 + "' ")
	else
		Iif(AllTrim(MV_PAR11)!="", cWhere += " AND B3K_MATRIC BETWEEN '" + MV_PAR10 + "' AND '" + MV_PAR11 + "' ",cWhere:=cWhere)
	EndIf

	If AllTrim(MV_PAR12)!=""
		Iif(AllTrim(MV_PAR13)!="",cWhere += " AND B3K_CODCCO BETWEEN '" + MV_PAR12 + "' AND '" + MV_PAR13 + "' ",cWhere += " AND B3K_CODCCO = '" + MV_PAR12 + "' ")
	else
		Iif(AllTrim(MV_PAR13)!="", cWhere += " AND B3K_CODCCO BETWEEN '" + MV_PAR12 + "' AND '" + MV_PAR13 + "' ",cWhere:=cWhere)
	EndIf

	Iif(AllTrim(MV_PAR14)!="", cWhere+= " AND B3K_CNPJCO ='" + MV_PAR14 + "'",cWhere:=cWhere)

	Iif(AllTrim(MV_PAR18)!="", cWhere+= " AND B3K_NOMECO ='" + MV_PAR18 + "'",cWhere:=cWhere)

	If AllTrim(MV_PAR15)!=""
		Iif(AllTrim(MV_PAR16)!="",cWhere += " AND B3K_CODPRO BETWEEN '" + MV_PAR15 + "' AND '" + MV_PAR16 + "' ",cWhere += " AND B3K_CODPRO = '" + MV_PAR15 + "' ")
	else
		Iif(AllTrim(MV_PAR16)!="", cWhere += " AND B3K_CODPRO BETWEEN '" + MV_PAR15 + "' AND '" + MV_PAR16 + "' ",cWhere:=cWhere)
	EndIf

	cWhere += " AND B3K.D_E_L_E_T_ = ' ' "
	cWhere += " AND B3J.D_E_L_E_T_ = ' ' "
	cWhere += " AND B3X.D_E_L_E_T_ = ' ' "

Return cWhere

Static Function getFields()

	Local cFields := ""

	cFields += " B3X_OPERA,B3X_CAMPO,B3K.R_E_C_N_O_ B3KRECNO,B3X.R_E_C_N_O_ B3XRECNO, "
	cFields += " B3K_CODOPE,B3K_CODCCO,B3K_MATRIC,B3K_MATANT, "
	cFields += " B3K_NOMBEN,B3K_DATNAS,B3K_DATINC,B3K_MOTBLO,B3K_DATBLO,B3K_UF, "
	cFields += " B3K_CODPRO,B3K_ATUCAR,B3K_STASIB,B3K_DTINVL,B3K_HRINVL, "
	cFields += " B3K_DTTEVL,B3K_HRTEVL,B3K_DTINSI,B3K_HRINSI,B3K_DTTESI, "
	cFields += " B3K_HRTESI,B3K_SEXO,B3K_PISPAS,B3K_NOMMAE,B3K_DN, "
	cFields += " B3K_CNS,B3K_ENDERE,B3K_NR_END,B3K_COMEND,B3K_BAIRRO, "
	cFields += " B3K_CODMUN,B3K_MUNICI,B3K_CEPUSR,B3K_TIPEND,B3K_RESEXT, "
	cFields += " B3K_TIPDEP,B3K_CODTIT,B3K_SUSEP,B3K_SCPA,B3K_PLAORI, "
	cFields += " B3K_COBPAR,B3K_CNPJCO,B3K_CEICON,B3K_TRAORI,B3K_TRADES, "
	cFields += " B3K_OPESIB,B3K_CPF,B3K_ITEEXC,B3J_FORCON,B3K_CPFMAE, "
	cFields += " B3K_CPFPRE,B3X_DATA,B3X_HORA,B4W_DATA,B4W_MOTBLO "

	If B3K->(FieldPos("B3K_CAEPF")) > 0
		cFields += " ,B3K_CAEPF "
	EndIf

Return cFields

/*
Programa  |InvalSIB  Autor  Microsiga             Data   18/02/11
Desc.     Verifica se o registro posicionado de TRBSIB sera enviado co
          mo exclusao
Uso        SIGAPLS
*/
Static Function InvalSIB(dDatDe,dDatAte,lCriaLog,cCodOpe,lCrit,;
		lPdteAnt, lAuto)

	Local cSqlSIB			:= ""
	Local cWhere			:= ""
	Local cStmSIB 			:= ""
	Default lAuto := .F.

	cSqlSIB := "SELECT COUNT(1) QTD "
	cWhere += " FROM " + RetSqlName("B3K") + " B3K, " + RetSqlName("B3X") + " B3X "
	cWhere += " WHERE "

	cWhere += " B3K_FILIAL = '" + xFilial("B3K") + "' "
	cWhere += " AND B3X_FILIAL = '" + xFilial("B3X") + "' "

	cWhere += " AND B3K.R_E_C_N_O_ = B3X.B3X_BENEF "

	cWhere += " AND B3K_CODOPE = '" + cCodOpe + "' "

	//Filtra por data ou criticado no retorno da ANS
	cWhere += " AND ("
	If lPdteAnt
		cWhere += " (B3X.B3X_DATA <= '" + dDatAte + "' "
		cWhere += " AND B3X_STATUS IN ('"+INVALIDO+"','"+PDTE_VALID+"')  )"
	Else
		cWhere += " (B3X.B3X_DATA BETWEEN '" + dDatDe + "' AND '" + dDatAte + "' " //Não é a origem de uma transferência
		cWhere += " AND B3X.B3X_STATUS IN ('"+INVALIDO+"','"+PDTE_VALID+"') )"
	EndIf

	cWhere += " ) "

	cWhere += " AND B3K.D_E_L_E_T_ = ' '"
	cWhere += " AND B3X.D_E_L_E_T_ = ' '"

	cSqlSIB += cWhere

	cStmSIB := ChangeQuery(cSqlSIB)

	If select('TRBSIB') > 0
		TRBSIB->(dbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cStmSIB),"TRBSIB",.F.,.T.)

	If lCrialog .AND. !lAuto
		PlsLogFil("Não enviados SIB: " + cStmSIB,cArqlogx)
	EndIf
	nQtd := TRBSIB->QTD

Return nQtd

/*/
Funcao     AcerCep  Autor  Tulio Cesar             Data  02.10.00
Descricao  Exportacao de dados para o Ministerio da Saude.
/*/
Static Function AcerCep(cCep)
	cRet := StrTran(cCep,"-","")
	cRet := StrTran(cCep,".","")
	cCep := AllTrim(Str(Val(cRet)))
	nLen := Len(cCep)

	If nLen < 8
		nRes := 8-nLen
		cRes := Replicate("0",nRes)
		cRet := cCep+cRes
		cCep := cRet
	EndIf

Return(cCep)

/*
Programa   A782XML   Autor  Microsiga             Data   02/22/11
Desc.      Gravacao do arquivo SBX de envio do SIB
Uso        SIGAPLS
*/
Static Function ASIBSBX(cDir,cSeqArq,lCriaLog,nRegInc,nRegAlt,;
		nRegExc,nRegRei,nRegMud,cCodOpe,cNamArq,lAuto,aEnviados,nFiltrados)
	Local cTmpXml := "" // Conteudo temporario
	Local cRetTmpXml := "" // Conteudo temporario de retificação
	Local nTmpXml := FCreate(cDir+cNamTmp,0,,.F.) // Arquivo temporario
	Local cCabXml := "" // cabecalho do arquivo SBX
	Local nCabXml := FCreate(cDir+cNamCab,0,,.F.) // Arquivo temporario
	Local nArqSib := 0 // Arquivo SBX
	Local cDtHr := ASibFmtData(DTOS(dDataBase)) + "T" + Time() + "Z" //2001-12-17T09:30:47.0Z
	Local cVerApl := GetBuild() // Versao da BUILD
	Local cHash := "" // Hash do arquivo SBX
	Local cBuffer := Space(F_BLOCK)
	Local lFinal := .F.
	Local nBytes := 0
	Local lGerouArq := .T.
	Local oCenBenefi := Nil
	Local lGeraOpcio := If(Empty(mv_par17) .OR. mv_par17 == 1,1,2)
	Local cIdsEnviados := "-1"
	Local nAteMil := 0
	Local lEnviaRet := .T.
	Local aPos := TagsSIB()
	Local hMapTags := LoadHmTags(aPos)
	Local xValor := ""
	Local nCnt   := 100000
	Local nTot   :=0
	Local lMatAnt:= GetNewPar("MV_PLMATAN",.F.)
	Private nNmHash := 0 //FCreate(cNmHash,0,,.F.) // Arquivo para calculo do hash

	Default aEnviados := {}


	cCabXml := '<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>' + CRLF
	cCabXml += '<mensagemSIB xmlns:ansSIB="http://www.ans.gov.br/padroes/sib/schemas" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.ans.gov.br/padroes/sib/schemas http://www.ans.gov.br/padroes/sib/schemas/sib.xsd">' + CRLF

	If nCabXml > 0 // Vou gravar um temporario com o cabecalho
		FWrite(nCabXml,cCabXml)
		FClose(nCabXml)
	Else
		MsgInfo("Não foi possível gravar o arquivo de cabeçalho " + cNamCab)
		lGerouArq := .F.
	EndIf

	If lGerouArq
		nNmHash := FCreate(cDir+cNmHash,0,,.F.) // Arquivo para calculo do hash
		If nNmHash <= 0 // arquivo temporario para calculo do HASH
			MsgInfo("Não foi possível gravar o arquivo do hash " + cNmHash)
			lGerouArq :=  .F.
		EndIf
	EndIf
	If lGerouArq
		FWrite(nNmHash,'http://www.ans.gov.br/padroes/sib/schemas http://www.ans.gov.br/padroes/sib/schemas/sib.xsd')

		If nTmpXml > 0 // vou escrever no arquivo temporario
			cTmpXml := ASIBTag(2,'cabecalho','',.T.,.F.,.T.) // Cabecalho - inicio
			cTmpXml += ASIBTag(4,'identificacaoTransacao','',.T.,.F.,.T.)
			cTmpXml += ASIBTag(6,'tipoTransacao',"SIB",.T.,.T.,.F.,.F.)
			cTmpXml += ASIBTag(6,'sequencialTransacao',cSeqArq,.T.,.T.,.F.)
			cTmpXml += ASIBTag(6,'dataHoraRegistroTransacao',cDtHr,.T.,.T.,.F.,.F.)
			cTmpXml += ASIBTag(4,'identificacaoTransacao','',.F.,.T.,.T.)
			cTmpXml += ASIBTag(4,'origem','',.T.,.F.,.T.)
			cTmpXml += ASIBTag(6,'registroANS',cCodOpe,.T.,.T.,.F.)
			cTmpXml += ASIBTag(4,'origem','',.F.,.T.,.T.)
			cTmpXml += ASIBTag(4,'destino','',.T.,.F.,.T.)
			cTmpXml += ASIBTag(6,'cnpj','03589068000146',.T.,.T.,.F.)
			cTmpXml += ASIBTag(4,'destino','',.F.,.T.,.T.)
			cTmpXml += ASIBTag(4,'versaoPadrao','1.1',.T.,.T.,.F.,.F.)
			cTmpXml += ASIBTag(4,'identificacaoSoftwareGerador','',.T.,.F.,.T.)
			cTmpXml += ASIBTag(6,'nomeAplicativo',cNomPLS,.T.,.T.,.F.,.F.)
			cTmpXml += ASIBTag(6,'versaoAplicativo',cVerApl,.T.,.T.,.F.,.F.)
			cTmpXml += ASIBTag(6,'fabricanteAplicativo',cFabApl,.T.,.T.,.F.,.F.)
			cTmpXml += ASIBTag(4,'identificacaoSoftwareGerador','',.F.,.T.,.T.)
			cTmpXml += ASIBTag(2,'cabecalho','',.F.,.T.,.T.)
			cTmpXml += ASIBTag(0,'mensagem','',.T.,.F.,.T.)
			cTmpXml += ASIBTag(2,'operadoraParaANS','',.T.,.F.,.T.)
			FWrite(nTmpXml,cTmpXml) // Cabecalho - termino

			cTmpXml := ASIBTag(4,'beneficiarios','',.T.,.F.,.T.)
			Do While !TRBSIB->(Eof())

				//Quando vier uma inclusão em que a Operação do Beneficiário seja cancelamento e ele esteja sem o Código do CCO, significa que não foi processado o arquivo CNX.
				If TRBSIB->B3X_OPERA == SIB_INCLUIR .And. TRBSIB->B3K_OPESIB == '4' .And. Empty(TRBSIB->B3K_CODCCO) //nesse caso não envio a inclusão também.
					TRBSIB->(DbSkip())
					Loop
				EndIf

				If TRBSIB->B3X_OPERA == SIB_INCLUIR .And. nTot<nCnt // Inclusao - inicio

					IncProc("Escrevendo registros de inclusao no arquivo")

					cTmpXml += ASIBTag(6,'inclusao','',.T.,.F.,.T.)
					cTmpXml += ASIBTag(8,'identificacao','',.T.,.F.,.T.)

					cTmpXml += ASIBTag(10,'cpf',TRBSIB->B3K_CPF,.T.,.T.,.F.,,CheckEnvia(hMapTags,'cpf', TRBSIB->B3X_OPERA))
					// Numero da Declaracao de Nascido Vivo
					If !Empty(TRBSIB->B3K_DN) .And. TRBSIB->B3K_DATNAS >= "20100101"
						cDn := AllTrim(TRBSIB->B3K_DN)
					Else
						cDn := ""
					EndIf
					cTmpXml += ASIBTag(10,'dn',cDn,.T.,.T.,.F.,,CheckEnvia(hMapTags,'dn', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'pisPasep',TRBSIB->B3K_PISPAS,.T.,.T.,.F.,,CheckEnvia(hMapTags,'pisPasep', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'cns',Alltrim(TRBSIB->B3K_CNS),.T.,.T.,.F.,,CheckEnvia(hMapTags,'cns', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'nome',AllTrim(SubStr(TRBSIB->B3K_NOMBEN+Space(70),1,70)),.T.,.T.,.F.,,CheckEnvia(hMapTags,'nome', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'sexo',TRBSIB->B3K_SEXO,.T.,.T.,.F.,,CheckEnvia(hMapTags,'sexo', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'dataNascimento',ASibFmtData(TRBSIB->B3K_DATNAS),.T.,.T.,.F.,,CheckEnvia(hMapTags,'dataNascimento', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'nomeMae',AllTrim(SubStr(TRBSIB->B3K_NOMMAE+Space(70),1,70)),.T.,.T.,.F.,,CheckEnvia(hMapTags,'nomeMae', TRBSIB->B3X_OPERA))

					cTmpXml += ASIBTag(8,'identificacao','',.F.,.T.,.T.)
					cTmpXml += ASIBTag(8,'endereco','',.T.,.F.,.T.)

					cTmpXml += ASIBTag(10,'logradouro',AllTrim(SubStr(TRBSIB->B3K_ENDERE + Space(50),1,50)),.T.,.T.,.F.,,CheckEnvia(hMapTags,'logradouro', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'numero',AllTrim(SubStr(TRBSIB->B3K_NR_END + Space(05),1,05)),.T.,.T.,.F.,,CheckEnvia(hMapTags,'numero', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'complemento',AllTrim(SubStr(TRBSIB->B3K_COMEND + Space(15),1,15)),.T.,.T.,.F.,,CheckEnvia(hMapTags,'complemento', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'bairro',AllTrim(SubStr(TRBSIB->B3K_BAIRRO + Space(30),1,30)),.T.,.T.,.F.,,CheckEnvia(hMapTags,'bairro', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'codigoMunicipio',ASibTamCmp(6,AllTrim(TRBSIB->B3K_CODMUN)),.T.,.T.,.F.,,CheckEnvia(hMapTags,'codigoMunicipio', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'codigoMunicipioResidencia',ASibTamCmp(6,AllTrim(TRBSIB->B3K_MUNICI)),.T.,.T.,.F.,,CheckEnvia(hMapTags,'codigoMunicipioResidencia', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'cep',AcerCEP(TRBSIB->B3K_CEPUSR),.T.,.T.,.F.,,CheckEnvia(hMapTags,'cep', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'tipoEndereco',TRBSIB->B3K_TIPEND,.T.,.T.,.F.,,CheckEnvia(hMapTags,'tipoEndereco', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'resideExterior',TRBSIB->B3K_RESEXT,.T.,.T.,.F.,,CheckEnvia(hMapTags,'resideExterior', TRBSIB->B3X_OPERA))

					cTmpXml += ASIBTag(8,'endereco','',.F.,.T.,.T.)
					cTmpXml += ASIBTag(8,'vinculo','',.T.,.F.,.T.)

					//Matricula
					If lMatAnt
						If Empty(TRBSIB->B3K_MATANT)
							cMatricula := AllTrim(TRBSIB->B3K_MATRIC)
						Else
							cMatricula := AllTrim(TRBSIB->B3K_MATANT)
						EndIf
					Else
						cMatricula := AllTrim(TRBSIB->B3K_MATRIC)
					EndIf

					cTmpXml += ASIBTag(10,'codigoBeneficiario',cMatricula,.T.,.T.,.F.,,CheckEnvia(hMapTags,'codigoBeneficiario', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'relacaoDependencia',TRBSIB->B3K_TIPDEP,.T.,.T.,.F.,,CheckEnvia(hMapTags,'relacaoDependencia', TRBSIB->B3X_OPERA))
					// Codigo de identificacao do beneficiario titular na operadora para beneficiarios informados como dependentes
					If TRBSIB->B3K_TIPDEP $ "1,01"
						cCodTit := ""
					Else
						cCodTit := TRBSIB->B3K_CODTIT
					EndIf
					cTmpXml += ASIBTag(10,'codigoBeneficiarioTitular',cCodTit,.T.,.T.,.F.,,CheckEnvia(hMapTags,'codigoBeneficiarioTitular', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'dataContratacao',ASibFmtData(TRBSIB->B3K_DATINC),.T.,.T.,.F.,,CheckEnvia(hMapTags,'dataContratacao', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'numeroPlanoANS',AllTrim(TRBSIB->B3K_SUSEP),.T.,.T.,.F.,,CheckEnvia(hMapTags,'numeroPlanoANS', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'numeroPlanoOperadora',AllTrim(TRBSIB->B3K_SCPA),.T.,.T.,.F.,.F.,,CheckEnvia(hMapTags,'numeroPlanoOperadora', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'numeroPlanoPortabilidade',AllTrim(TRBSIB->B3K_PLAORI),.T.,.T.,.F.,,CheckEnvia(hMapTags,'numeroPlanoPortabilidade', TRBSIB->B3X_OPERA))
					cTmpXml += ASIBTag(10,'coberturaParcialTemporaria',AllTrim(TRBSIB->B3K_COBPAR),.T.,.T.,.F.,,CheckEnvia(hMapTags,'coberturaParcialTemporaria', TRBSIB->B3X_OPERA))

					// Numero do CNPJ da pessoa juridica contratante do plano coletivo
					If TRBSIB->B3J_FORCON $ "2,3" //Forma de contratação empresarial
						If !Empty(TRBSIB->B3K_CNPJCO)
							cCnpj := TRBSIB->B3K_CNPJCO
							cCaepf := ""
							cCei := ""
						ElseIf B3K->(FieldPos("B3K_CAEPF")) > 0 .AND. !Empty(TRBSIB->B3K_CAEPF)
							cCnpj := ""
							cCaepf := AllTrim(TRBSIB->B3K_CAEPF)
							cCei := ""
						Else
							cCnpj := ""
							cCaepf := ""
							cCei := AllTrim(TRBSIB->B3K_CEICON)
						EndIf
					Else
						cCnpj := ""
						cCei := ""
						cCaepf := ""
					EndIf

					If !Empty(cCnpj)
						cTmpXml += ASIBTag(10,'cnpjEmpresaContratante',cCnpj,.T.,.T.,.F.,,CheckEnvia(hMapTags,'cnpjEmpresaContratante', TRBSIB->B3X_OPERA))
						ElseIf!Empty(cCaepf)
						cTmpXml += ASIBTag(10,'caepfEmpresaContratante',cCaepf,.T.,.T.,.F.,,CheckEnvia(hMapTags,'caepfEmpresaContratante', TRBSIB->B3X_OPERA))
						ElseIf!Empty(cCei)
						cTmpXml += ASIBTag(10,'ceiEmpresaContratante',cCei,.T.,.T.,.F.,,CheckEnvia(hMapTags,'ceiEmpresaContratante', TRBSIB->B3X_OPERA))
					EndIf

					cTmpXml += ASIBTag(8,'vinculo','',.F.,.T.,.T.)
					cTmpXml += ASIBTag(6,'inclusao','',.F.,.T.,.T.)
					FWrite(nTmpXml,cTmpXml)
					cTmpXml := ""
					nRegInc++
					nTot++
					cIdsEnviados += ","+Alltrim(str(TRBSIB->B3XRECNO))

				ElseIf TRBSIB->B3X_OPERA == SIB_RETIFIC .And. nTot<nCnt// Alteracao - inicio

					IncProc("Escrevendo registros de retificação no arquivo")
					xValor := ""
					cCampo := Alltrim(TRBSIB->B3X_CAMPO)

					nPos := aScan(aPos,{|x| x[1] == cCampo})

					If nPos > 0
						xValor :=  AllTrim(&("TRBSIB->"+cCampo))
						nTam :=  aPos[nPos,2]
						cTag :=  aPos[nPos,3]

						If cCampo $ "B3K_DATNAS,B3K_DATINC,B3K_DATBLO,B3K_DTREAT"
							xValor := If(!Empty(xValor),;
								ASibFmtData(xValor),;
								ASibFmtData(StrZero(0,8,0)))
						ElseIf cCampo $ "B3K_CNPJCO,B3K_CEICON,B3K_CAEPF"
							If TRBSIB->B3J_FORCON $ "2,3" .AND. !Empty(xValor) //Forma de contratação empresarial
								xValor := ASibTamCmp(nTam,xValor,.F.)
							Else
								xValor := ""
							EndIf
						Else
							xValor := ASibTamCmp(nTam,xValor,.F.)
						EndIf
					EndIf
					If !Empty(xValor)
						lEnviaRet := CheckEnvia(hMapTags,cTag, TRBSIB->B3X_OPERA)
						If lEnviaRet
							If cTag $ "cpf,pisPasep,dn,cns,nome,sexo,dataNascimento,nomeMae"
								cTmpXml += ASIBTag(6,'retificacao','',.T.,.F.,.T.)
								cTmpXml += ASIBTag(8,'cco',ASibTamCmp(12,TRBSIB->B3K_CODCCO,.F.),.T.,.T.,.F.)
								cTmpXml += ASIBTag(8,'identificacao','',.T.,.F.,.T.)
								cTmpXml += ASIBTag(10,cTag,xValor,.T.,.T.,.F.,,lEnviaRet)
								cTmpXml += ASIBTag(8,'identificacao','',.F.,.T.,.T.)
								cTmpXml += ASIBTag(8,'endereco','',.T.,.F.,.T.,,.T.)
								cTmpXml += ASIBTag(8,'endereco','',.F.,.T.,.T.,,.T.)
								cTmpXml += ASIBTag(8,'vinculo','',.T.,.F.,.T.,,.T.)
								cTmpXml += ASIBTag(8,'vinculo','',.F.,.T.,.T.,,.T.)
								cTmpXml += ASIBTag(6,'retificacao','',.F.,.T.,.T.,,.T.)
							ElseIf cTag $ "logradouro,numero,complemento,bairro,codigoMunicipio,"+;
									"codigoMunicipioResidencia,cep,tipoEndereco,resideExterior"
								cTmpXml += ASIBTag(6,'retificacao','',.T.,.F.,.T.)
								cTmpXml += ASIBTag(8,'cco',ASibTamCmp(12,TRBSIB->B3K_CODCCO,.F.),.T.,.T.,.F.)
								cTmpXml += ASIBTag(8,'identificacao','',.T.,.F.,.T.)
								cTmpXml += ASIBTag(8,'identificacao','',.F.,.T.,.T.)
								cTmpXml += ASIBTag(8,'endereco','',.T.,.F.,.T.,,.T.)
								cTmpXml += ASIBTag(10,cTag,xValor,.T.,.T.,.F.,,lEnviaRet)
								cTmpXml += ASIBTag(8,'endereco','',.F.,.T.,.T.,,.T.)
								cTmpXml += ASIBTag(8,'vinculo','',.T.,.F.,.T.,,.T.)
								cTmpXml += ASIBTag(8,'vinculo','',.F.,.T.,.T.,,.T.)
								cTmpXml += ASIBTag(6,'retificacao','',.F.,.T.,.T.,,.T.)
							ElseIf cTag $ "codigoBeneficiario,relacaoDependencia,codigoBeneficiarioTitular,dataContratacao,"+;
									"dataCancelamento,motivoCancelamento,numeroPlanoANS,numeroPlanoOperadora,"+;
									"numeroPlanoPortabilidade,cnpjEmpresaContratante,ceiEmpresaContratante,caepfEmpresaContratante"+;
									"coberturaParcialTemporaria,itensExcluidosCobertura"

								If lMatAnt .And. cTag == "codigoBeneficiario"
									If !Empty(TRBSIB->B3K_MATANT)
										xValor := AllTrim(TRBSIB->B3K_MATANT)
									EndIf
								EndIf

								cTmpXml += ASIBTag(6,'retificacao','',.T.,.F.,.T.)
								cTmpXml += ASIBTag(8,'cco',ASibTamCmp(12,TRBSIB->B3K_CODCCO,.F.),.T.,.T.,.F.)
								cTmpXml += ASIBTag(8,'identificacao','',.T.,.F.,.T.)
								cTmpXml += ASIBTag(8,'identificacao','',.F.,.T.,.T.)
								cTmpXml += ASIBTag(8,'endereco','',.T.,.F.,.T.,,.T.)
								cTmpXml += ASIBTag(8,'endereco','',.F.,.T.,.T.,,.T.)
								cTmpXml += ASIBTag(8,'vinculo','',.T.,.F.,.T.,,.T.)
								cTmpXml += ASIBTag(10,cTag,xValor,.T.,.T.,.F.,,lEnviaRet)
								cTmpXml += ASIBTag(8,'vinculo','',.F.,.T.,.T.,,.T.)
								cTmpXml += ASIBTag(6,'retificacao','',.F.,.T.,.T.,,.T.)
							EndIf
							FWrite(nTmpXml,cTmpXml)
							cTmpXml := ""
							nRegAlt++
							cIdsEnviados += ","+Alltrim(str(TRBSIB->B3XRECNO))
							nTot++

						Else
							nFiltrados++

						EndIf

					EndIf
				ElseIf TRBSIB->B3X_OPERA == SIB_CANCELA .And. nTot<nCnt // Cancelamento - inicio

					IncProc("Escrevendo registros de cancelamento no arquivo")

					cCodCCO := ASibTamCmp(12,TRBSIB->B3K_CODCCO,.F.)
					cDatBlo := IIf(!Empty(AllTrim(TRBSIB->B4W_DATA)),ASibFmtData(TRBSIB->B4W_DATA),"")
					cMotBlo := TRBSIB->B4W_MOTBLO

					If !Empty(cCodCCO) .And. !Empty(cDatBlo) .And. !Empty(cMotBlo)
						cTmpXml += ASIBTag(6,'cancelamento','',.T.,.F.,.T.)
						cTmpXml += ASIBTag(8,'cco',cCodCCO,.T.,.T.,.F.)
						cTmpXml += ASIBTag(8,'dataCancelamento',cDatBlo,.T.,.T.,.F.)
						cTmpXml += ASIBTag(8,'motivoCancelamento',cMotBlo,.T.,.T.,.F.)
						cTmpXml += ASIBTag(6,'cancelamento','',.F.,.T.,.T.)
						FWrite(nTmpXml,cTmpXml)
						cTmpXml := ""
					EndIf
					nRegExc++
					cIdsEnviados += ","+Alltrim(str(TRBSIB->B3XRECNO))
					nTot++

				ElseIf TRBSIB->B3X_OPERA == SIB_REATIVA .And. nTot<nCnt// Reativacao - inicio

					IncProc("Escrevendo registros de reativação no arquivo")

					cCodCCO := ASibTamCmp(12,TRBSIB->B3K_CODCCO,.F.)
					cDtBlq := TRBSIB->B4W_DATA
					cDtBlq := Iif(!Empty(cDtBlq),ASibFmtData(cDtBlq),"")

					If !Empty(cCodCCO) .And. !Empty(cDtBlq)

						cTmpXml += ASIBTag(6,'reativacao','',.T.,.F.,.T.)
						cTmpXml += ASIBTag(8,'cco',cCodCCO,.T.,.T.,.F.)
						cTmpXml += ASIBTag(8,'dataReativacao',cDtBlq,.T.,.T.,.F.)
						cTmpXml += ASIBTag(6,'reativacao','',.F.,.T.,.T.)
						FWrite(nTmpXml,cTmpXml)
						cTmpXml := ""

					EndIf
					nRegRei++
					cIdsEnviados += ","+Alltrim(str(TRBSIB->B3XRECNO))
					nTot++

				ElseIf TRBSIB->B3X_OPERA == SIB_MUDCONT .And. nTot<nCnt// Mudanca contratual - inicio

					IncProc("Escrevendo registros de mudança contratual no arquivo")

					cTmpXml += ASIBTag(6,'mudancaContratual','',.T.,.F.,.T.)
					cTmpXml += ASIBTag(8,'cco',ASibTamCmp(12,TRBSIB->B3K_CODCCO,.F.),.T.,.T.,.F.)
					cTmpXml += ASIBTag(8,'relacaoDependencia',TRBSIB->B3K_TIPDEP,.T.,.T.,.F.)
					If TRBSIB->B3K_TIPDEP $ "1,01"
						cCodTit := ""
					Else
						cCodTit := TRBSIB->B3K_CODTIT
					EndIf
					cTmpXml += ASIBTag(8,'codigoBeneficiarioTitular',cCodTit,.T.,.T.,.F.)
					cTmpXml += ASIBTag(8,'dataContratacao',ASibFmtData(TRBSIB->B3K_DATINC),.T.,.T.,.F.)
					cTmpXml += ASIBTag(8,'numeroPlanoANS',AllTrim(TRBSIB->B3K_SUSEP),.T.,.T.,.F.)
					cTmpXml += ASIBTag(8,'numeroPlanoOperadora',AllTrim(TRBSIB->B3K_SCPA),.T.,.T.,.F.,.F.)
					cTmpXml += ASIBTag(8,'numeroPlanoPortabilidade',AllTrim(TRBSIB->B3K_PLAORI),.T.,.T.,.F.)

					// Numero do CNPJ da pessoa juridica contratante do plano coletivo
					If TRBSIB->B3J_FORCON $ "2,3" //Forma de contratação empresarial
						If !Empty(TRBSIB->B3K_CNPJCO)
							cCnpj := TRBSIB->B3K_CNPJCO
							cCaepf := ""
							cCei := ""
						ElseIf B3K->(FieldPos("B3K_CAEPF")) > 0 .AND. !Empty(TRBSIB->B3K_CAEPF)
							cCnpj := ""
							cCaepf := AllTrim(TRBSIB->B3K_CAEPF)
							cCei := ""
						Else
							cCnpj := ""
							cCaepf := ""
							cCei := AllTrim(TRBSIB->B3K_CEICON)
						EndIf
					Else
						cCnpj := ""
						cCei := ""
						cCaepf := ""
					EndIf

					If !Empty(cCnpj)
						cTmpXml += ASIBTag(8,'cnpjEmpresaContratante',cCnpj,.T.,.T.,.F.)
						ElseIf!Empty(cCaepf)
						cTmpXml += ASIBTag(8,'caepfEmpresaContratante',cCaepf,.T.,.T.,.F.)
						ElseIf!Empty(cCei)
						cTmpXml += ASIBTag(8,'ceiEmpresaContratante',cCei,.T.,.T.,.F.)
					EndIf
					cTmpXml += ASIBTag(6,'mudancaContratual','',.F.,.T.,.T.)
					FWrite(nTmpXml,cTmpXml)
					cTmpXml := ""
					nRegMud++
					cIdsEnviados += ","+Alltrim(str(TRBSIB->B3XRECNO))
					nTot++
				EndIf // Mudanca contratual - termino

				nAteMil := nRegInc + nRegAlt + nRegExc + nRegRei + nRegMud

				If lGeraOpcio == NAOGERAOPC .AND. nAteMil > 1000
					aAdd(aEnviados,{cIdsEnviados})
					cIdsEnviados := "-1"
				EndIf

				TRBSIB->(DbSkip())

			EndDo

			aAdd(aEnviados,{cIdsEnviados})
			cIdsEnviados := "-1"

			If (nRegInc > 0) .Or. (nRegAlt > 0) .Or. (nRegExc > 0) .Or. (nRegRei > 0) .Or. (nRegMud > 0)
				cTmpXml := ASIBTag(4,'beneficiarios','',.F.,.T.,.T.)
			Else
				oCenBenefi := DaoCenBenefi():New()
				oCenBenefi:setCodOpe(cCodOpe)

				//Não existe beneficiários
				//Caso não tenha Beneficiários código do motivoNaoEnvioBeneficiarios deve ser 61
				If(!oCenBenefi:buscar())
					cTmpXml := StrTran(cTmpXml,'<beneficiarios>','',1)// Retiro a tag <beneficiarios>
					cTmpXml += ASIBTag(4,'naoEnvioBeneficiarios','',.T.,.F.,.T.)
					cTmpXml += ASIBTag(6,'motivoNaoEnvioBeneficiarios','61',.T.,.T.,.F.)
					cTmpXml += ASIBTag(4,'naoEnvioBeneficiarios','',.F.,.T.,.T.)
				Else
					cTmpXml := StrTran(cTmpXml,'<beneficiarios>','',1)// Retiro a tag <beneficiarios>
					cTmpXml += ASIBTag(4,'naoEnvioBeneficiarios','',.T.,.F.,.T.)
					cTmpXml += ASIBTag(6,'motivoNaoEnvioBeneficiarios','62',.T.,.T.,.F.)
					cTmpXml += ASIBTag(4,'naoEnvioBeneficiarios','',.F.,.T.,.T.)
				EndIf
				oCenBenefi:Destroy()
				oCenBenefi := nil
			EndIf

			cTmpXml += ASIBTag(2,'operadoraParaANS','',.F.,.T.,.T.)
			cTmpXml += ASIBTag(0,'mensagem','',.F.,.T.,.T.)
			FWrite(nTmpXml,cTmpXml)
			FClose(nTmpXml)
		Else
			MsgInfo("Não foi possível gerar o arquivo xml " + cNamTmp)
			Return .F.
		EndIf

		If lCrialog .AND. !lAuto
			PlsLogFil("Escrita do arquivo SBX utilizou ponto de entrada",cArqLogx)
		EndIf
		FClose(nNmHash)
		cNamArq := cDir + cCodOpe + Dtos(dDataBase) + Replace(Time(),":","") + ".SBX" // Nome do arquivo de envio do SIB a ser gerado
		nArqSib := FCreate(cNamArq,0,,.F.) // criacao do arquivo SBX
		If nArqSib <= 0
			MsgInfo("Não foi possível criar o arquivo " + cDir+cNamArq)
			Return .F.
		EndIf

		nCabXml := FOpen(cDir+cNamCab,FO_READ) // arquivo de cabecalho
		If nCabXml <= 0
			MsgInfo("Não foi possível abrir o arquivo " + cDir+cNamCab)
			Return .F.
		EndIf

		nTmpXml := FOpen(cDir+cNamTmp,FO_READ) // arquivo temporario
		If nTmpXml <= 0
			MsgInfo("Não foi possível abrir o arquivo " + cDir+cNamTmp)
			Return .F.
		EndIf

		Do While !lFinal // Vou apendar o cabecalho no arquivo arquivo SBX
			nBytes := FRead(nCabXml, @cBuffer, F_BLOCK)
			If FWrite(nArqSib,cBuffer,nBytes) < nBytes
				lFinal := .T.
			Else
				lFinal := (nBytes == 0)
			EndIf
		EndDo
		FClose(nCabXml)
		FErase(cDir+cNamCab)

		lFinal := .F. // Vou apendar o arquivo temporario no arquivo SBX
		Do While !lFinal
			nBytes := FRead(nTmpXml, @cBuffer, F_BLOCK)
			If FWrite(nArqSib,cBuffer,nBytes) < nBytes
				lFinal := .T.
			Else
				lFinal := (nBytes == 0)
			EndIf
		EndDo
		FClose(nTmpXml)
		FErase(cDir+cNamTmp)

		FSeek(nArqSib, 0, FS_END) // Posiciona no final do arquivo
		cHash := ASIBHash(cDir+cNmHash,lCriaLog, lAuto) // Efetuo o calculo do hash
		FErase(cDir+cNmHash)

		cTmpXml := ASIBTag(0,'epilogo','',.T.,.F.,.T.)
		cTmpXml += ASIBTag(2,'hash',Upper(cHash),.T.,.T.,.T.)
		cTmpXml += ASIBTag(0,'epilogo','',.F.,.T.,.T.)
		cTmpXml += ASIBTag(0,'mensagemSIB','',.F.,.T.,.T.)
		FWrite(nArqSib,cTmpXml)
		FClose(nArqSib)
	EndIf

Return lGerouArq

/*
	Programa   ASIBTag    Autor  Microsiga
	Data   04/18/11
	Desc.      Formata a TAG XML a ser escrita no arquivo
	Uso        SIGAPLS
	nSpc    = espaco para identar o arquivo
	cTag    = nome da tab
	cVal    = valor da tag
	lIni    = abertura de tag
	lFin    = fechamento de tag
	lPerNul = permitido nulo na tag
	lRetPto = retira caracteres especiais
*/
Static Function ASIBTag(nSpc,cTag,cVal,lIni,lFin,lPerNul,lRetPto,lEnvTag)

	Local cRetTag := "" // Tag a ser gravada no arquivo texto
	Default lRetPto := .T.
	Default lEnvTag := .T.

	If !Empty(cVal) .Or. lPerNul

		If lIni // Inicializa a tag ?
			cRetTag += '<' + cTag + '>'
			cRetTag += AllTrim(cVal)
		EndIf

		If lFin // Finaliza a tag ?
			cRetTag += '</' + cTag + '>'
		EndIf

		If lEnvTag .And. nNmHash > 0 // Escreve conteudo da tag no temporario pra calculo do hash
			FWrite(nNmHash,AllTrim(cVal))
		EndIf

		cRetTag := Space(nSpc) + cRetTag + CRLF // Identa o arquivo

	EndIf

Return Iif(lEnvTag,cRetTag,"")

Static Function CheckEnvia(hMapTags,cTag, cOperacao)

	Local lEnvia := .T.
	Local aTag := {}
	Local lGeraOpcio := If(Empty(mv_par17) .OR. mv_par17 == 1,1,2)
	Local lTagExiste := hMapTags:get(cTag, aTag)
	Default hMapTags := THashMap():New()
	Default lGeraOpcio := 1

	If lGeraOpcio == NAOGERAOPC
		If cOperacao == SIB_INCLUIR .AND. lTagExiste
			lEnvia = aTag[TIPO_INC] == OBRIGATORIO
		EndIf
		If cOperacao == SIB_RETIFIC  .AND. lTagExiste
			lEnvia = aTag[TIPO_RET] == OBRIGATORIO
		EndIf
	Elseif lGeraOpcio == GERAOPCION
		If cOperacao == SIB_INCLUIR .AND. lTagExiste
			lEnvia = aTag[TIPO_INC] != NAOENVIADO
		EndIf
		If cOperacao == SIB_RETIFIC  .AND. lTagExiste
			lEnvia = aTag[TIPO_RET] != NAOENVIADO
		EndIf
	EndIf

Return lEnvia

Static Function TagsSIB()

	Local aTags := {}

	/*
		1 - Descrição do array
		2 - Nome do campo
		3 - Tamanho do campo
		4 - Nome da TAG
		5 - Inclusão - Obrigatória, opcional, Não enviada
		6 - Retificação - Obrigatória, opcional, Não enviada
	*/

	//Identificação pessoal
	AAdd(aTags,{"B3K_CCO",12,'cco', NAOENVIADO, OBRIGATORIO })
	AAdd(aTags,{"B3K_MATRIC",30,'codigoBeneficiario', OBRIGATORIO, OBRIGATORIO})
	AAdd(aTags,{"B3K_NOMBEN",70,'nome', OBRIGATORIO, OBRIGATORIO})
	AAdd(aTags,{"B3K_DATNAS",10,'dataNascimento', OBRIGATORIO, OBRIGATORIO})
	AAdd(aTags,{"B3K_SEXO",1,'sexo', OBRIGATORIO, OBRIGATORIO})
	AAdd(aTags,{"B3K_CPF",11,'cpf', OBRIGATORIO, OBRIGATORIO})
	AAdd(aTags,{"B3K_PISPAS",11,'pisPasep', OBRIGATORIO, OBRIGATORIO})
	AAdd(aTags,{"B3K_NOMMAE",70,'nomeMae', OBRIGATORIO, OBRIGATORIO})
	AAdd(aTags,{"B3K_DN",11,'dn', OBRIGATORIO, OBRIGATORIO})
	AAdd(aTags,{"B3K_CNS",15,'cns', OBRIGATORIO, OBRIGATORIO})
	AAdd(aTags,{"B3K_CODTIT",30,'codigoBeneficiarioTitular', OBRIGATORIO, OBRIGATORIO})

	//Identificação de Endereço
	AAdd(aTags,{"B3K_TIPEND",1,'tipoEndereco', OPCIONAL,OPCIONAL})
	AAdd(aTags,{"B3K_ENDERE",50,'logradouro', OPCIONAL,OPCIONAL})
	AAdd(aTags,{"B3K_NR_END",5,'numero', OPCIONAL,OPCIONAL})
	AAdd(aTags,{"B3K_COMEND",15,'complemento', OPCIONAL,OPCIONAL})
	AAdd(aTags,{"B3K_BAIRRO",30,'bairro', OPCIONAL,OPCIONAL})
	AAdd(aTags,{"B3K_CODMUN",6,'codigoMunicipio', OBRIGATORIO,OPCIONAL})
	AAdd(aTags,{"B3K_CEPUSR",8,'cep', OPCIONAL,OPCIONAL})
	AAdd(aTags,{"B3K_RESEXT",1,'resideExterior', OPCIONAL,OPCIONAL})
	AAdd(aTags,{"B3K_MUNICI",6,'codigoMunicipioResidencia', OPCIONAL,OPCIONAL})


	//Identificação contratual
	AAdd(aTags,{"B3K_SUSEP",9,'numeroPlanoANS', OBRIGATORIO,OPCIONAL})
	AAdd(aTags,{"B3K_SCPA",20,'numeroPlanoOperadora', OBRIGATORIO,OBRIGATORIO})
	AAdd(aTags,{"B3K_PLAORI",9,'numeroPlanoPortabilidade', OBRIGATORIO,OBRIGATORIO})
	AAdd(aTags,{"B3K_DATINC",10,'dataContratacao', OBRIGATORIO,OBRIGATORIO})
	AAdd(aTags,{"B3K_DATBLO",10,'dataCancelamento', OBRIGATORIO,OBRIGATORIO})
	AAdd(aTags,{"B3K_MOTBLO",2,'motivoCancelamento', OBRIGATORIO,OBRIGATORIO})
	AAdd(aTags,{"B3K_DTREAT",10,'dataReativacao', OBRIGATORIO,OBRIGATORIO})
	AAdd(aTags,{"B3K_COBPAR",1,'coberturaParcialTemporaria', OPCIONAL,OPCIONAL })
	AAdd(aTags,{"B3K_ITEEXC",1,'itensExcluidosCobertura', OPCIONAL,OPCIONAL })
	AAdd(aTags,{"B3K_CNPJCO",14,'cnpjEmpresaContratante', OBRIGATORIO,OPCIONAL })
	AAdd(aTags,{"B3K_CEICON",12,'ceiEmpresaContratante', OBRIGATORIO,OPCIONAL })
	AAdd(aTags,{"B3K_TIPDEP",2,'relacaoDependencia', OBRIGATORIO,OPCIONAL })
	AAdd(aTags,{"B3K_CAEPF",14,'caepfEmpresaContratante', OBRIGATORIO,OPCIONAL })

Return aTags

Static Function LoadHmTags(aTags)

	Local hMapTags := THashMap():New()
	Local nCount := 0
	Local nI := 1
	Default aTags := {}

	nCount := len(aTags)
	For nI := 1 to nCount
		hMapTags:set(aTags[nI][TAG],aTags[nI])
	Next

Return hMapTags

/*
Programa  ASibTamCmp Autor  Microsiga             Data   27/05/11
Desc.      Ajusta o tamanho da string retornada para o tamanho que de-
           ve ser enviado no arquivo
Uso        SIGAPLS
*/
Static Function ASibTamCmp(nTam,cVal,lZero)
	Local cRet := ""
	Default lZero = .F.

	If Len(cVal) > nTam
		cRet := SubStr(cVal,1,nTam)
	Else
		cRet := cVal
	EndIf

	If lZero // vou completar com zeros
		If ValType(cRet) == "N"
			cRet := StrZero(cRet,nTam)
		Else
			cRet := StrZero(Val(cRet),nTam)
		EndIf
	EndIf

Return cRet

/*
Programa  ASibTamCmp Autor  Microsiga             Data   27/05/11
Desc.      Ajusta o tamanho da string retornada para o tamanho que de-
           ve ser enviado no arquivo
Uso        SIGAPLS
*/
Static Function ASibFmtData(cData)
	Local cValor :=  ""
	cValor := SubStr(cData,1,4) + "-" + SubStr(cData,5,2) + "-" + SubStr(cData,7,2)
Return cValor

/*
Programa  ASIBHash   Autor  Microsiga             Data   06/10/11
Desc.     Funcao criada para calculo do hash do arquivo SBX
Uso       SIGAPLS
*/
Static Function ASIBHash(cHashFile,lCriaLog, lAuto)
	Local cRetHash    := "" // Hash calculado do arquivo SBX
	Local cBuffer	  := "" // Buffer lido
	Local cHashBuffer := "" // Buffer do hash calculado
	Local cFnHash     := "MD5File" // Definicao da função MD5File
	Local nBytesRead  := 0 // Quantidade de bytes lidos no arquivo
	Local nTamArq	  := 0 // Tamanho do arquivo em bytes
	Local nFileHash	  := 0 // Arquivo de hash
	Local aPatch      := {} // Conteudo do diretorio

	Default cHashFile	:= "sibhashfile.txt"
	Default lAuto := .F.

	IncProc("Calculando hash do arquivo SBX a ser enviado")

	aPatch := Directory(cHashFile,"F")

	If Len(aPatch) > 0
		nTamArq := aPatch[1,2]/1048576

		If lCriaLog .AND. !lAuto
			PlsLogFil("Atributos: " + aPatch[1,5] + " - Tamanho: " + AllTrim(Str(aPatch[1,2])),cArqlogx)
		EndIf

		If nTamArq > 0.9
			// Utilizado a macro-execucao por solicitacao da tecnologia, para evitar
			// erro na funcao MD5File decorrente a utilizacao de binarios mais antigos
			cRetHash := &(cFnHash+"('"+cHashFile+"')")

			If lCriaLog .AND. !lAuto
				PlsLogFil("MD5File: " + cRetHash,cArqlogx)
			EndIf
		Else
			cBuffer   := Space(F_BLOCK)
			nFileHash := FOpen(cHashFile, FO_READ)
			nTamArq   := aPatch[1,2]//Tamnho em bytes

			Do While nTamArq > 0
				nBytesRead := FRead(nFileHash, @cBuffer, F_BLOCK)
				nTamArq    -= nBytesRead
				cHashBuffer	+= cBuffer
			EndDo

			FClose(nFileHash)
			FErase(cHashFile)
			cRetHash := MD5(cHashBuffer,2)

			If lCriaLog .AND. !lAuto
				PlsLogFil("MD5: " + cRetHash,cArqlogx)
			EndIf
		EndIf
	Else
		MsgInfo("O arquivo " + cHashFile + " não foi encontrado ou não está acessível." + CRLF + "Hash do arquivo não pode ser calculado!")
	EndIf

Return cRetHash

/*
Programa  geraCSV   Autor  p.drivas         Data   11/09/20
Desc.     Gera relatorio CSV dos beneficiario invalidos
Uso       SIGACEN
*/
static function geraCSV(dDatDe,dDatAte,cCodOpe,lPdteAnt,cNamArq,lAuto)

	local cQuery     := ''
	local cAlias     := GetNextAlias()
	Local aOpera     := CENGETX3BX('B3X_OPERA')
	Local cOpera     := ''
	Local cPath      := "\sib\"
	Local oCSV       := Nil
	Local aHeaderCSV := {}
	Local aLineCSV   := {}
	local nArquivo   := 0
	local lGerou     := .T.

	default lAuto := .F.

	cQuery := " SELECT B3K_CODOPE,B3X_OPERA, B3K_MATRIC, B3K_CODCCO , B3F_CDCOMP, "
	cQuery += " B3F_CODCRI, B3F_CRIANS, B3F_CAMPOS, B3F_DESCRI, B3F_SOLUCA "
	cQuery += " FROM " + RetSqlName("B3K") + " B3K "
	cQuery += " JOIN " + RetSqlName("B3X") + " B3X "
	cQuery += " ON B3K_FILIAL = B3X_FILIAL "
	cQuery += " AND B3K.R_E_C_N_O_ = B3X.B3X_BENEF "
	cQuery += " JOIN " + RetSqlName("B3F") + " B3F "
	cQuery += " ON B3X.B3X_FILIAL = B3F.B3F_FILIAL "
	cQuery += " AND B3F.B3F_ORICRI = 'B3X' "
	cQuery += " AND B3F.B3F_CHVORI  = B3X.R_E_C_N_O_ "
	cQuery += " WHERE "
	cQuery += " B3K_CODOPE = '" + cCodOpe + "' "
	//Filtra por data ou criticado no retorno da ANS
	cQuery += " AND ("
	If lPdteAnt
		cQuery += " (B3X.B3X_DATA <= '" + dDatAte + "' "
		cQuery += " AND B3X_STATUS IN ('"+INVALIDO+"','"+PDTE_VALID+"')  )"
	Else
		cQuery += " (B3X.B3X_DATA BETWEEN '" + dDatDe + "' AND '" + dDatAte + "' " //Não é a origem de uma transferência
		cQuery += " AND B3X.B3X_STATUS IN ('"+INVALIDO+"','"+PDTE_VALID+"') )"
	EndIf
	cQuery += " ) "
	cQuery += " AND B3K.D_E_L_E_T_ = ' '"
	cQuery += " AND B3X.D_E_L_E_T_ = ' '"
	cQuery += " AND B3F.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY B3K_MATRIC "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)

	DBSelectArea(cAlias)

	If (cAlias)->(!EOF())

		aHeaderCSV := {"Operadora","Tipo de Movimento","Beneficiário","CCO","Compromisso","Cód Crít.",;
			"Cód Crít. ANS","Campo(s) Crítica","Descrição Crítica","Solução Crítica"}
		oCSV := CenCSV():New(aHeaderCSV,';')

		while (cAlias)->(!Eof())

			cOpera := aOpera[Val((cAlias)->B3X_OPERA)][2]
			aLineCSV := {;
				(cAlias)->B3K_CODOPE,;
				cOpera,;
				(cAlias)->B3K_MATRIC,;
				(cAlias)->B3K_CODCCO,;
				(cAlias)->B3F_CDCOMP,;
				(cAlias)->B3F_CODCRI,;
				(cAlias)->B3F_CRIANS,;
				(cAlias)->B3F_CAMPOS,;
				(cAlias)->B3F_DESCRI,;
				(cAlias)->B3F_SOLUCA;
				}
			oCSV:addLine(aLineCSV)
			(cAlias)->(DbSkip())
		EndDo

		if !ExistDir(cPath)
			if MakeDir(cPath) <> 0
				If !lAuto
					MsgStop("Não foi possível criar o diretório: " + cPath + ".","ATENÇÃO")
				EndIf
				lGerou := .F.
			EndIf
		endif

		nArquivo := fCreate (Left(cNamArq,Len(cNamArq)-4) + ".csv")
		If fError() # 0
			If !lAuto
				MsgAlert ("Não conseguiu criar o arquivo ")
			EndIf
			lGerou := .F.
		else
			fWrite (nArquivo, oCSV:cContent)
			if fError() # 0
				If !lAuto
					MsgAlert ("Não conseguiu gravar conteúdo no arquivo ")
				EndIf
				lGerou := .F.
			EndIf
		EndIf
		fClose(nArquivo)

		freeObj(oCSV)

	Else
		return lGerou
	EndIf

return lGerou

/*
Programa  CENGETX3BX   Autor  p.drivas         Data   11/09/20
Desc.     Retorna array com as opcoes do X3_CBOX de um campo
Uso       SIGACEN
*/
function CENGETX3BX(cCampo)

	Local aConjunto	:= {}
	Local aPosic    := {}
	Local nTamBox := 0
	Local nQntBox := 0
	Local nOpcoes   := 0

	Local cBox      := AllTrim(GetAdvFVal("SX3","X3_CBOX",cCampo,2,""))

	Default cMV	:= ''

	If len(cBox) > 0

		For nTamBox := 1 to len(cBox)
			If SUBSTR(cBox,nTamBox,1) == "="
				nOpcoes++
				aAdd(aPosic,{nTamBox,0})
			ElseIf SUBSTR(cBox,nTamBox,1) == ";"
				aPosic[nOpcoes][2] := nTamBox
			EndIF
		Next nTamBox

		aPosic[nOpcoes][2] := len(cBox)

		For nQntBox := 1 to nOpcoes
			If nQntBox == 1
				aAdd(aConjunto,{CVALTOCHAR(nQntBox),SUBSTR(cBox,aPosic[nQntBox][1]+1,aPosic[nQntBox][2]-3),.F.})
			ElseIf	nQntBox == nOpcoes
				aAdd(aConjunto,{CVALTOCHAR(nQntBox),SUBSTR(cBox,aPosic[nQntBox][1]+1,aPosic[nQntBox][2]-(aPosic[nQntBox-1][2]+2)),.F.})
			Else
				aAdd(aConjunto,{CVALTOCHAR(nQntBox),SUBSTR(cBox,aPosic[nQntBox][1]+1,aPosic[nQntBox][2]-(aPosic[nQntBox-1][2]+3)),.F.})
			EndIf
		Next nQntBox
	EndIf
Return aConjunto
