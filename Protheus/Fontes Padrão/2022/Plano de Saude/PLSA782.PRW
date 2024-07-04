#include "PROTHEUS.CH"
#include "FILEIO.CH"

#define F_BLOCK 1024
#define lLinux IsSrvUnix()
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF

STATIC cNamCab := "cabsib.xml"
STATIC cNamTmp := "tmpsib.xml"
STATIC cNmHash := "hashsib.tmp"
STATIC cNomPLS := "TOTVS SAฺDE CENTRAL DE OBRIGAวีES (SIGACEN)"
STATIC cFabApl := "TOTVS SA"
STATIC MATRIPLS := "@R !!!!.!!!!.!!!!!!.!!-!"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSA782   บAutor  ณMicrosiga           บ Data ณ  15/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGeracao do arquivo XML para envio do SIB                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSA782()  

Local aSays     := {}
Local aButtons  := {}
Local nOpca	    := 0
Local cCadastro := FunDesc() //"SIB XML"
Private cPerg   := "PLA780"
Private cArqLog := "PLSSIB_" + Dtos(dDataBase) + "_" + Replace(Time(),":","") + ".LOG" // Nome do arquivo de log da execucao
Private cNamArq := "" // Nome do arquivo SBX a ser gerado

aAdd(aSays,"Esta rotina irแ gerar o arquivo SBX com informa็๕es para o SIB.")

aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.)}})
aAdd(aButtons, { 1,.T.,{|| nOpca := 1, If( VldPerg(),FechaBatch(),nOpca := 0)}}) //Processamento
aAdd(aButtons, { 2,.T.,{|| FechaBatch()}})

FormBatch(cCadastro, aSays, aButtons, , 160)

If nOpca == 1
	Processa({||A782Pro(cPerg)},"Gera็ใo do arquivo do SIB - XML","Processando...",.T.)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A782Pro  บAutor  ณMicrosiga           บ Data ณ  15/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processamento da reducao de custo dos procedimentos pagos  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A782Pro()
Local cCodInt     := "" // Operadora
Local cEmpDe      := "" // Empresa de 
Local cEmpAte     := "" // Empresa ate
Local dDatRef     := Ctod("  /  /  ") // Data de referencia
Local dDatDe      := Ctod("  /  /  ") // Movimento de
Local dDatAte     := Ctod("  /  /  ") // Movimento ate
Local cSeqArq     := "" // Numero sequencial do arquivo
Local lDigito     := .T. // Envia matricula com digito 
Local lAtuSIB     := .F. // Atualiza SIB  
Local lReenvio    := .F. // Gera apenas registros criticados
Local cTipReg	  := "" // Tipo de registro
Local lProcessa   := .F. // Define se o registro posicionado do alias TRBSIB sera processado
Local aRetBlq     := {} //{"",{"00","","00000000","00000000","","",.F.}} // Informacoes de bloqueio do usuario
Local aGraPar     := {} // Grau de parentesco
Local aAltera		:= {}
Local nRegFil	  := 0 // Registros filtrados
Local nRegPro	  := 0 // Registros processados
Local lPos   	  := .F. //Define se foi possivel realizar todos posicionamentos necessarios ( BQC, BA1 ... )
Local cMsg		  := "" // Mensagem a ser apresentada no log e ao termino do processamento
Local aRegua	  := {} // tamanho da regua
Local bRegPro     := {|| Iif (nRegPro % 50 == 0,.T.,.F.)}
Private cDir      := "" // Diretorio
Private aRetPla   := {} // Codigo do plano na ANS - {BI3_SUSEP,BI3_SCPA}
Private lMatAnt   := .F. // Envia matricula antiga
Private lTrataCPT	:= .F. //Indica se envia ou nao tags de CPT
Private lCriaLog  := .F. // Gerar aquivo log
Private aRegInc	  := Array(1,30)// Matriz de registros de inclusao
Private aRegAlt	  := Array(1,36)// Matriz de registros de alteracao
Private aRegExc	  := Array(1,6)// Matriz de registros de cancelamento
Private aRegRei	  := Array(1,5)// Matriz de registros de reativacao
Private aRegMud	  := Array(1,16)// Matriz de registro de mudanca contratual
Private nRegInc	  := 0 // Contador de registros de inclusao
Private nRegAlt	  := 0 // Contador de registros de alteracao
Private nRegExc	  := 0 // Contador de registros de cancelamento
Private nRegRei	  := 0 // Contador de registros de reinclusao
Private nRegMud   := 0 // Contador de registros de mudanca de plano
Private cCodTit   := GetNewPar("MV_PLCDTIT","T") // Codigo indicador do Titular do contrato no PLS
Private aCriticas := {} // Criticas do processamento do SIB
Private aCmpAlt   := {} // Campos do BA1 que sofreram alteracao

Pergunte(cPerg,.F.)

cCodInt  := mv_par01
cEmpDe   := mv_par02
cEmpAte  := mv_par03
dDatRef  := dtos(mv_par04)
dDatDe   := dtos(mv_par05)
dDatAte  := dtos(mv_par06)
cSeqArq  := StrZero(Val(mv_par07),7)
lDigito  := If(mv_par08 == 1,.T.,.F.)
cDir     := AllTrim(mv_par09)
lAtuSIB  := If(mv_par10 == 1,.T.,.F.)
lMatAnt  := If(mv_par11 == 1,.T.,.F.)
lCriaLog := If(mv_par12 == 1,.T.,.F.)
lReenvio := If(mv_par13 == 1,.T.,.F.)
cDtRSIB := dtos(mv_par14)//data retroativa para registros incluidos
lTrataCPT  := If(mv_par15 == 1,.T.,.F.)

BA0->(DbSetOrder(1)) // Posiciono a operadora
If !BA0->(dbSeek(xFilial("BA0")+cCodInt))
	Help("",1,"PL780INT")
    Return .F.
EndIf

If lCriaLog // Cabecalho do log
	cMsg := "Gera็ใo do arquivo do SIB - Inํcio: " + Dtos(dDatabase) + " " + Time() + CRLF
	cMsg += "Parโmetros informados para processamento: " + CRLF
	cMsg += "Operadora: " + cCodInt + CRLF
	cMsg += "Empresa de: " + cEmpDe + CRLF
	cMsg += "Empresa ate: " + cEmpAte + CRLF
	cMsg += "Data refer๊ncia: " + dDatRef + CRLF
	cMsg += "Movimento de: " + dDatDe + CRLF
	cMsg += "Movimento at้: " + dDatAte + CRLF
	cMsg += "N๚mero seq. arquivo: " + cSeqArq + CRLF
	cMsg += "Envia matrํcula c/ dํgito: " + If(lDigito,"Sim","Nใo") + CRLF
	cMsg += "Diret๓rio: " + cDir + CRLF
	cMsg += "Atualiza SIB: " + If(lAtuSIB,"Sim","Nใo") + CRLF
	cMsg += "Usa matr. antiga: " + If(lMatAnt,"Sim","Nใo") + CRLF
	cMsg += "Gera arquivo log: " + If(lCrialog,"Sim","Nใo") + CRLF
	cMsg += "Reenvio: " + If(lReenvio,"Sim","Nใo") + CRLF
	cMsg += "Data retro. p/ movimentacao: " + cDtRSIB + CRLF
	PlsLogFil(cMsg,cArqLog)
EndIf
aRegua := CargaSIB(cCodInt,cEmpDe,cEmpAte) // Sera criado o alias TRBSIB
If !aRegua[2]	//	Existem Registros
	MsgInfo("Nenhum beneficiแrio encontrado para processamento do SIB.")
	If lCriaLog
		PlsLogFil("Nenhum beneficiแrio encontrado para processamento do SIB.", cArqLog)
	EndIf
	Return .F.
EndIf
PlsLogFil("Carga do SIB finalizada",cArqLog)

PlsLogFil("A782Ini - inicio",cArqLog)
A782Ini(aGraPar) // Algumas inicializacoes necessarias BRP, Indices
PlsLogFil("A782Ini - termino",cArqLog)

While !TRBSIB->(Eof())

	nRegFil++ // Contador de registros filtrados ja processados
	lPos := A782Pos(dDatDe,dDatAte,cTipReg,aRetBlq) // Posicionamentos

	If IncluiSIB(lCriaLog,dDatDe,dDatAte,lReenvio,cDtRSIB) // Verifica se vai ser inclusao
		lProcessa := .T.
		cTipReg := "3"
	EndIf

	aAltera := AlteraSIB(lCriaLog,dDatDe,dDatAte,lReenvio) // Verifica se vai ser retificacao
	If !lProcessa .And. aAltera[1] 
		lProcessa := .T.
		cTipReg := "4"
	EndIf

	If !lProcessa .And. ReInclSIB(lCriaLog,dDatDe,dDatAte,aRetBlq,lReenvio,cDtRSIB) // Verifica se vai ser reativacao
		lProcessa := .T.
		cTipReg := "A"
	EndIf

	If !lProcessa .And. MudPlaSib(dDatDe,dDatAte,lReenvio,cDtRSIB) // Verifica se vai ser mudanca contratual
		lProcessa := .T.
		cTipReg := "9"
	EndIf

	If !lProcessa .And. ExcluiSIB(lCriaLog,dDatDe,dDatAte,aRetBlq,lReenvio,cDtRSIB) // Verifica se vai ser cancelamento
		lProcessa := .T.
		cTipReg := "5"
	EndIf

	If lProcessa // Se registro deve ser processado 

		If lPos // Se conseguiu fazer os posicionamentos

			nRegPro++ // Contador de registros processados

			Do Case
				Case cTipReg == "3"
					If Eval(bRegPro)
						IncProc(AllTrim(Str(nRegPro)) +"/"+ AllTrim(Str(aRegua[1])) + " - Inclusใo: " + TRBSIB->BA1_NOMUSR)//27-07
					EndIf
					A782RegInc(lMatAnt,lDigito,cCodTit,aGraPar,dDatRef) // Processar beneficiario como inclusao
				Case cTipReg == "4"
					If Eval(bRegPro)
						IncProc(AllTrim(Str(nRegPro)) +"/"+ AllTrim(Str(aRegua[1])) + " - Retifica็ใo: " + TRBSIB->BA1_NOMUSR)//27-07
					EndIf
					A782RegAlt(dDatDe,dDatAte,dDatRef,aGraPar,aRetBlq,dDatRef,lDigito,aAltera) // Processar beneficiario como alteracao
				Case cTipReg == "5"
					If Eval(bRegPro)
						IncProc(AllTrim(Str(nRegPro)) +"/"+ AllTrim(Str(aRegua[1])) + " - Cancelamento: " + TRBSIB->BA1_NOMUSR)//27-07
					EndIf
					A782RegExc(lCriaLog,lMatAnt,aRetBlq,dDatDe,dDatAte) // Processar beneficiario como exclusao
				Case cTipReg == "A"
					If Eval(bRegPro)
						IncProc(AllTrim(Str(nRegPro)) +"/"+ AllTrim(Str(aRegua[1])) + " - Reativa็ใo: " + TRBSIB->BA1_NOMUSR)//27-07
					EndIf
					A782RegRei(aRegRei,aRetBlq) // Processar beneficiario como reativacao
				Case cTipReg == "9"
					If Eval(bRegPro)
						IncProc(AllTrim(Str(nRegPro)) +"/"+ AllTrim(Str(aRegua[1])) + " - Mudan็a contratual: " + TRBSIB->BA1_NOMUSR)//27-07
					EndIf
					A782RegMud(aRegMud,aRetBlq,aGraPar,lDigito,dDatRef) // Processar beneficiario como mudanca contratual
			EndCase

			A782AtuSib(cTipReg,dDatRef,lAtuSib) // Atualiza BA1

		Else // lPos

			If lCriaLog
				PlsLogFil(Transform(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),MATRIPLS) +"  "+;
				SubStr(AllTrim(TRBSIB->BA1_NOMUSR)+Space(30),1,30)+"Cliente nใo encontrado",cArqLog)
				aAdd(aCriticas, {Transform(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),MATRIPLS), "Cliente nใo encontrado"} )
			EndIf

		EndIf	

		lProcessa := .F.
		cTipReg   := ""

	Else
		IncProc(Transform(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),MATRIPLS) +" - "+ TRBSIB->BA1_NOMUSR)
	EndIf // lProcessa

	TRBSIB->(dbSkip())
EndDo

TRBSIB->(dbCloseArea())
IncProc("Gravando arquivo SBX a ser enviado ...")

If (nRegInc > 0) .Or. (nRegAlt > 0) .Or. (nRegExc > 0) .Or. (nRegRei > 0) .Or. (nRegMud > 0)

	A782SBX(cDir,cSeqArq,lCriaLog) // Gravacao do arquivo SBX

	If lAtuSib
		A782AtuSx1() // Atualiza a sequencia do proximo arquivo a ser gerado
	EndIf

Else
	A782SBX(cDir,cSeqArq,lCriaLog,.T.) // Gravacao do arquivo SBX de inexistencia de movimentacao
EndIf

// Resumo do processamento	
cMsg := "Arquivo gerado com sucesso - " + cNamArq + CRLF
cMsg += "Qtde registros filtrados: " + AllTrim(Str(nRegFil)) + CRLF
cMsg += "Qtde registros processados: " + AllTrim(Str(nRegPro)) + CRLF
cMsg += "Qtde registros inclusใo: " + AllTrim(Str(nReginc)) + CRLF
cMsg += "Qtde registros retifica็ใo: " + AllTrim(Str(nRegAlt)) + CRLF
cMsg += "Qtde registros cancelamento: " + AllTrim(Str(nRegExc)) + CRLF
cMsg += "Qtde registros reinclusใo: " + AllTrim(Str(nRegRei)) + CRLF
cMsg += "Qtde registros mudan็a contratual: " + AllTrim(Str(nRegMud)) + CRLF
cMsg += "Gera็ใo do arquivo do SIB - T้rmino: " + Dtos(dDatabase) + " - " + Time()

If lCriaLog
	PlsLogFil(cMsg,cArqLog)
EndIf

MsgAlert(cMsg,"Informativo")

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | CargaSIB บAutor  ณMicrosiga           บ Data ณ  15/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para carregar todos os beneficiarios que serao procesบฑฑ
ฑฑบ          ณsados para gerar o arquivo do SIB - XML                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CargaSIB(cCodInt,cEmpDe,cEmpAte)

Local cSqlSIB := ""
Local cStmSIB := ""
LOCAL cFrom := ""
Local lRet := .F.
lOCAL nQtde := 0
LOCAL nFor := 0

//	Filtro
cFrom :=  " FROM " + RetSqlName("BA1") + " BA1, " + RetSqlName("BTS") + " BTS, " + RetSqlName("BA3") + " BA3 "
cFrom += " WHERE BA1_FILIAL = '" + xFilial("BA1") + "' AND BA1.D_E_L_E_T_ = ' '"
cFrom +=   " AND BTS_FILIAL = '" + xFilial("BTS") + "' AND BTS.D_E_L_E_T_ = ' '"
cFrom +=   " AND BA3_FILIAL = '" + xFilial("BA3") + "' AND BA3.D_E_L_E_T_ = ' '"
cFrom +=   " AND BA1_MATVID = BTS_MATVID AND BA1_CODINT = BA3_CODINT AND BA1_CODEMP = BA3_CODEMP AND BA1_MATRIC = BA3_MATRIC"
cFrom +=   " AND BA1_CODINT = '" + cCodInt + "' AND BA1_OPEORI =  '" + cCodInt + "'"
cFrom +=   " AND BA1_CODEMP BETWEEN '" + cEmpDe + "' AND '" + cEmpAte + "'"
cFrom +=   " AND BA1_INFANS <> '0' AND BA1_ATUSIB <> '0' AND BA1_INFSIB <> '0' AND BA1_LOCSIB IN ('0','1','2','6','7','8','B','C')" // Atualiza SIB ? Considera SIB ?

FOR nfor := 1 TO 2
	IF nFor == 1	//	Total dos Registros
		cSqlSIB := "SELECT COUNT(*) QTDE " + cFrom
	ELSE	//	Sele็ใo dos registros
		cSqlSIB := "SELECT BA1.R_E_C_N_O_ BA1RECNO,BTS.R_E_C_N_O_ BTSRECNO, BA1_PLPOR, BA1_INCANS, BA1_EXCANS, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO,"
		cSqlSIB +=   " BA1_NOMUSR, BA1_OPEORI, BA1_INFANS, BA1_ATUSIB, BA1_LOCSIB, BA1_MATANT,BA1_MATUSB, BA1_CONEMP, BA1_VERCON, BA1_SUBCON, BA1_VERSUB,"
		cSqlSIB +=   " BA1_INFSIB, BA1_CODPLA, BA1_VERSAO, BA1_DATBLO, BA1_DATNAS, BA1_SEXO, BA1_CPFUSR, BA1_MAE, BA1_TIPUSU, BA1_ENDERE, BA1_CEPUSR, BA1_TRADES, BA1_TRAORI,"
		cSqlSIB +=   " BA1_MUNICI, BA1_ESTADO, BA1_DATINC, BA1_DATTRA, BA1_CODCLI, BA1_LOJA, BA1_COBNIV, BA1_NR_END, BA1_COMEND, BA1_BAIRRO, BA1_CODMUN, BA1_TIPEND, BA1_RESEXT, BA1_MUNRES,"
		cSqlSIB +=   " BA1_GRAUPA, BA1_MATVID, BA1_CPFMAE, BA1_CPFPRE, BA1_CODCCO, BA1_DATADP, BTS_DRGUSR, BTS_ORGEM, BTS_RGEST,BTS_PISPAS, BTS_NRCRNA, BTS_DENAVI, BTS_TIPEND, "
		cSqlSIB +=   " BA3_TIPOUS, BA3_PLPOR , BA3_CODPLA, BA3_VERSAO, BA3_CODCLI, BA3_LOJA, BA3_COBNIV, BA1_DTRSIB"

		// Preciso do order by pois ocorreu de ir no arquivo inclusao de dependente antes do titular, isso da critica na ANS
		cSqlSIB += cFrom + " ORDER BY BA1_FILIAL, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, CASE WHEN BA1_TIPUSU = '" + cCodTit + "' THEN '1' ELSE '2' END, BA1_TIPREG, BA1_DIGITO"
	ENDIF

	cStmSIB := ChangeQuery(cSqlSIB)
	If Select('TRBSIB') > 0
		TRBSIB->(dbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cStmSIB),"TRBSIB",.F.,.T.)
	IF nFor == 1
		nQtde := TRBSIB->QTDE
	ENDIF
NEXT
If lCrialog
	PlsLogFil("Carga SIB: " + cStmSIB,cArqlog)
EndIf
lRet := !TRBSIB->(Eof())

Return({nQtde, lRet})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | IncluiSIBบAutor  ณMicrosiga           บ Data ณ  16/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o registro posicionado de TRBSIB sera enviado coบฑฑ
ฑฑบ          ณmo inclusao                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IncluiSIB(lCriaLog,dDatDe,dDatAte,lReenvio,cDtRSIB)

If TRBSIB->BA1_LOCSIB == "6" //6=Criticado Inclusao
	Return .T.
EndIf

// 0=Nao enviado; nao pode ser transferencia; data de bloqueio futuro ou inclusao e bloqueio dentro do periodo de envio do SIB
If TRBSIB->BA1_LOCSIB == "0" .And. Empty(TRBSIB->BA1_TRAORI) .And. (TRBSIB->BA1_DATBLO >= dDatAte .Or. ;
	( (TRBSIB->BA1_DATINC >= dDatDe .Or. (!Empty(cDtRSIB) .And. TRBSIB->BA1_DATINC >= cDtRSIB)) .And. TRBSIB->BA1_DATBLO <= dDatAte)) .And. !lReenvio

	If TRBSIB->BA1_DATINC <= dDatAte

		If TRBSIB->BA3_TIPOUS == "1" // PF
			Return .T.
		ElseIf TRBSIB->BA3_TIPOUS == "2" // PJ

			If ! BT5->(msSeek(xFilial("BT5")+TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)))
				If lCriaLog
					PlsLogFil(Transform(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),MATRIPLS) +"  "+ ;
					SubStr(AllTrim(PlRetponto(TRBSIB->BA1_NOMUSR))+Space(30),1,30)+ "   Nao   " + "Contrato nใo encontrado",cArqLog)
				EndIf

				aAdd(aCriticas, {Transform(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),MATRIPLS), "Contrato nใo encontrado"} )
				Return .F.
			EndIf

			If !BQC->(dbSeek(xFilial("BQC")+TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
				If lCriaLog
					PlsLogFil(Transform(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),MATRPLS) +"  "+ ;
					SubStr(AllTrim(PlRetponto(TRBSIB->BA1_NOMUSR))+Space(30),1,30)+ "   Nao   " + "SubContrato nใo encontrado",cArqLog)
				EndIf

				aAdd(aCriticas, {Transform(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),MATRIPLS), "SubContrato nใo encontrado"} )
				Return .F.
			EndIf

			If (TRBSIB->BA1_INFSIB != "1" .And. TRBSIB->BA1_INFANS != "1") .And. (BT5->BT5_INFANS == "0" .Or. BQC->BQC_INFANS == "0") // Contrato ou Subcontrato nao informado a ANS
				Return .F.
			Else
				Return .T.
			EndIF

		EndIf

	Else
		Return .F.
	EndIf

EndIf

Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |A782RegIncบAutor  ณMicrosiga           บ Data ณ  16/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdiciona um registro de inclusao para ser gravado no XML    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A782RegInc(lMatAnt,lDigito,cCodTit,aGraPar,dDatRef)
Local aRetCli := {}
Local aRet    := {}
Local nPos    := 0
Local lPosBQC := .T.

If nRegInc >= 1
	nRegInc++
	aAdd(aRegInc,Array(31))
Else
	nRegInc := 1
EndIf

/* IDENTIFICACAO PESSOAL */  

// Codigo de Identificacao do beneficiario na operadora
If lMatAnt // Enviar matricula antiga
	If Empty(TRBSIB->BA1_MATANT) .And. !Empty(TRBSIB->BA1_MATUSB)
		aRegInc[nRegInc,1] := allTrim(TRBSIB->BA1_MATUSB)
	Else
		If !Empty(TRBSIB->BA1_MATANT)
			aRegInc[nRegInc,1] := AllTrim(TRBSIB->BA1_MATANT)
		Else
			If !lDigito // Enviar matricula sem o digito
				aRegInc[nRegInc,1] := AllTrim(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG))
			Else
				aRegInc[nRegInc,1] := AllTrim(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))
			EndIf
		EndIf
	EndIf
Else
	If !lDigito // Enviar matricula sem o digito
		aRegInc[nRegInc,1] := AllTrim(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG))
	Else
		aRegInc[nRegInc,1] := AllTrim(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))
	EndIf
EndIf

// Nome do Beneficiario
aRegInc[nRegInc,2] := AllTrim(SubStr(PlRetponto(TRBSIB->BA1_NOMUSR)+Space(70),1,70))

// Data de nascimento do beneficiario
aRegInc[nRegInc,3] := SubStr(TRBSIB->BA1_DATNAS,1,4) + "-" + SubStr(TRBSIB->BA1_DATNAS,5,2) + "-" + SubStr(TRBSIB->BA1_DATNAS,7,2)

// Sexo do beneficiario
aRegInc[nRegInc,4] := If(TRBSIB->BA1_SEXO == "1","1","3")

// CPF - Cadastro de Pessoas Fisicas - do beneficiario
If !Empty(TRBSIB->BA1_CPFUSR)
	aRegInc[nRegInc,5] := TRBSIB->BA1_CPFUSR
Else
	If Calc_Idade(Ctod(dDatRef),Ctod(TRBSIB->BA1_DATNAS)) < 18 .And. TRBSIB->BA1_TIPUSU <> cCodTit
		aRegInc[nRegInc,5] := ""
	Else
		If !Empty(TRBSIB->BA1_CPFMAE)
			aRegInc[nRegInc,5] := TRBSIB->BA1_CPFMAE
		Else
			If !Empty(TRBSIB->BA1_CPFPRE)
				aRegInc[nRegInc,5] := TRBSIB->BA1_CPFPRE
			Else
				aRegInc[nRegInc,5] := ""
			EndIf
		EndIf
	EndIf
EndIf

// Numero do PIS/PASEP do beneficiario ou Numero de Identificacao do Trabalhador - NIT
aRegInc[nRegInc,6] := AllTrim(TRBSIB->BTS_PISPAS)

// Nome da mae do beneficiario
aRegInc[nRegInc,7] := AllTrim(SubStr(PlRetponto(TRBSIB->BA1_MAE)+Space(70),1,70))

// Numero da Declaracao de Nascido Vivo
If TRBSIB->BA1_DATNAS >= "20100101"
	aRegInc[nRegInc,8] := AllTrim(TRBSIB->BTS_DENAVI)
Else
	aRegInc[nRegInc,8] := ""
EndIf

// Numero do Cartao Nacional de Saude
aRegInc[nRegInc,9] := AllTrim(TRBSIB->BTS_NRCRNA)

// Codigo de identificacao do beneficiario titular na operadora para beneficiarios informados como dependentes
If TRBSIB->BA1_TIPUSU <> cCodTit
	aRegInc[nRegInc,10] := A782Tit(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),lDigito,lMatAnt)
Else
	aRegInc[nRegInc,10] := ""
EndIf

/* IDENTIFICACAO DE ENDERECO */

// Indicacao de endereco residencial ou profissional 2,1
aRegInc[nRegInc,11] := TRBSIB->BTS_TIPEND
If Empty(aRegInc[nRegInc,11])
	aRegInc[nRegInc,11] := TRBSIB->BA1_TIPEND
EndIf

// Logradouro do beneficiario
aRegInc[nRegInc,12] := AllTrim(SubStr(TRBSIB->BA1_ENDERE + Space(50),1,50))

// Numero do logradouro
aRegInc[nRegInc,13] := AllTrim(SubStr(TRBSIB->BA1_NR_END + Space(05),1,05))

// Complemento do logradouro
aRegInc[nRegInc,14] := AllTrim(SubStr(TRBSIB->BA1_COMEND + Space(15),1,15))

// Bairro do logradouro do beneficiario
aRegInc[nRegInc,15] := AllTrim(SubStr(TRBSIB->BA1_BAIRRO + Space(30),1,30))

// Codigo do municipio do logradouro indicado
aRegInc[nRegInc,16] := A782TamCmp(6,AllTrim(TRBSIB->BA1_CODMUN))

// CEP
aRegInc[nRegInc,17] := AcerCEP(TRBSIB->BA1_CEPUSR)

// Indicacao se a residencia do beneficiario e no Brasil (0) ou no exterior(1)
aRegInc[nRegInc,18] := TRBSIB->BA1_RESEXT

// Codigo do municipio de residencia do beneficiario, caso o endereco informado seja indicado como endereco profissional
aRegInc[nRegInc,19] := A782TamCmp(6,AllTrim(TRBSIB->BA1_MUNRES))

/* IDENTIFICACAO CONTRATUAL */

// Numero do registro do plano na ANS (RPS)
aRegInc[nRegInc,20] := aRetPla[1]

// Codigo do cadastro do plano na ANS (SCPA)
aRegInc[nRegInc,21] := aRetPla[2]

// Numero do plano origem RPS (portabilidade)
aRegInc[nRegInc,22] := AllTrim(If( !Empty(TRBSIB->BA3_PLPOR) .Or. !Empty(TRBSIB->BA1_PLPOR),;
				If(!Empty(TRBSIB->BA1_PLPOR),TRBSIB->BA1_PLPOR,TRBSIB->BA3_PLPOR),''))

// Data de contratacao do plano
aRegInc[nRegInc,23] := SubStr(TRBSIB->BA1_DATINC,1,4) + "-" + SubStr(TRBSIB->BA1_DATINC,5,2) + "-" + SubStr(TRBSIB->BA1_DATINC,7,2)
// Indicacao de cobertura parcial temporaria
aRegInc[nRegInc,24] := PLSIBCPT(dDatRef,TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG))

// Indicacao de itens de procedimentos excluidos da cobertura
aRegInc[nRegInc,25] := "0"

// Numero do CNPJ da pessoa juridica contratante do plano coletivo
If TRBSIB->BA3_TIPOUS <> "1" //Beneficiario PJ
	If !Empty(BQC->BQC_CNPJ)
		aRegInc[nRegInc,26] := BQC->BQC_CNPJ
	Else
		If SA1->(dbSeek(xFilial("SA1")+BQC->(BQC_CODCLI+BQC_LOJA)))
			aRegInc[nRegInc,26] := SA1->A1_CGC
		Else
			aRetCli := PLSRETNCB(TRBSIB->BA1_CODINT,TRBSIB->BA1_CODEMP,TRBSIB->BA1_MATRIC,TRBSIB->BA1_OPEORI)
			If aRetCli[1]
				If SA1->(msSeek(xFilial("SA1")+TRBSIB->(BA3_CODCLI+BA3_LOJA)))
					aRegInc[nRegInc,26] := SA1->A1_CGC
				EndIf
			EndIf
		EndIf
	EndIf
Else
	aRegInc[nRegInc,26] := ""
EndIf

// Numero do CEI do contratante do plano coletivo
If aRetPla[3] $ "3,4"
	If !Empty(BQC->BQC_CAEPF) .AND. Empty(BQC->BQC_CNPJ) .AND. BQC->(FieldPos('BQC_CAEPF')) > 0
		aRegInc[nRegInc,26] := "" // Vou informar o CAEPF e nao o CNPJ
		aRegInc[nRegInc,30] := AllTrim(BQC->BQC_CAEPF)		
	ElseIf !Empty(BQC->BQC_CEINSS) .AND. Empty(BQC->BQC_CNPJ) 
		aRegInc[nRegInc,26] := "" // Vou informar o CEI e nao o CNPJ
		aRegInc[nRegInc,27] := AllTrim(BQC->BQC_CEINSS)
	ElseIf Empty(BQC->BQC_CNPJ) .And. !Empty(SA1->A1_CEINSS)
		aRegInc[nRegInc,26] := "" // Vou informar o CEI e nao o CNPJ
		aRegInc[nRegInc,27] := AllTrim(SA1->A1_CEINSS)
	Else
		aRegInc[nRegInc,27] := ""
		aRegInc[nRegInc,30] := ""
	EndIf
Else
	aRegInc[nRegInc,26] := "" // CNPJ
	aRegInc[nRegInc,27] := "" // CEI
	aRegInc[nRegInc,30] := "" // CAEPF
EndIf

// Relacao de dependencia
nPos := aScan(aGraPar,{|x| x[1] == TRBSIB->BA1_GRAUPA})
If nPos > 0
	aRegInc[nRegInc,28] := aGraPar[nPos,2]
Else
	aRegInc[nRegInc,28] := "10"
EndIf

aRegInc[nRegInc,29] := .T. //Indica que o registro sera escrito no arquivo SBX

If lCriaLog
	PlsLogFil(Transform(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),MATRIPLS) +"  "+ ;
	SubStr(AllTrim(TRBSIB->BA1_NOMUSR)+Space(30),1,30)+ " - Inclusใo ",cArqLog)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | PLSIBPLA บAutor  ณMicrosiga           บ Data ณ  16/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o plano principal do beneficiario                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSIBPLA(cAlias)
Local lCodPla := .T.
Local cSUSEP  := ""
Local cSCPA   := ""
Local cNatJur := ""
Local nRecBQC := BQC->(Recno())

If !BI3->(dbSeek(xFilial("BI3")+&(cAlias+"->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO)"))) // Produto no usuario
	If !BI3->(dbSeek(xFilial("BI3")+&(cAlias+"->(BA1_CODINT+BA3_CODPLA+BA3_VERSAO)"))) // Produto na familia
		If TRBSIB->BA3_TIPOUS <> "1" // Beneficiario PJ
			BQC->(dbSeek(&(cAlias+"->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)"))) // Posicona o BQC
			If !BT6->(dbSeek(xFilial("BT6")+BQC->(BQC_CODINT+BQC_CODEMP+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB))) // Produto no Sub-contrato
				lCodPla := .F.
			Else
				If !BI3->(dbSeek(xFilial("BI3")+BT6->(BT6_CODINT+BT6_CODPRO+BT6_VERSAO)))
					lCodPla := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If !lCodPla
	cSUSEP := StrZero(0,9,0)
	cSCPA  := StrZero(0,20,0)

	If lCriaLog
		PlsLogFil(Transform(&(cAlias+"->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)"),MATRIPLS) +"  "+ ;
		SubStr(AllTrim(PlRetponto(&(cAlias+"->BA1_NOMUSR")))+Space(30),1,30) + "Produto nใo encontrado",cArqLog)
	EndIf
	aAdd(aCriticas, {Transform(&(cAlias+"->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)"),MATRIPLS), "Produto nใo encontrado"} )
Else
	cSUSEP := If(BI3->BI3_APOSRG == "1",AllTrim(BI3->BI3_SUSEP),"")
	cSCPA  := If(BI3->BI3_APOSRG == "1","",AllTrim(BI3->BI3_SCPA))
	cNatJur := BI3->BI3_NATJCO
EndIf

BQC->(dbGoTo(nRecBQC))

Return {cSUSEP,cSCPA,cNatJur} //{BI3_SUSEP,BI3_SCPA,BI3_NATJCO}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | A782Ini  บAutor  ณMicrosiga           บ Data ณ  16/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Algumas inicializadoes necessarios                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A782Ini(aGraPar)
aGraPar := {}

//Seleciono os indices
BA3->(DbSetOrder(1))
BG1->(DbSetOrder(1))
BG3->(DbSetOrder(1))
BG9->(DbSetOrder(1))
BI3->(DbSetOrder(1))
BQC->(DbSetOrder(1))
BQU->(DbSetOrder(1))
BT5->(DbSetOrder(1))
BT6->(DbSetOrder(1))
SA1->(DbSetOrder(1))
BA1->(DbSetOrder(2))

//Grau de parentesco
BRP->(dbSetOrder(1))
BRP->(dbSeek(xFilial("BRP")))
While !BRP->(Eof()) .And. BRP->BRP_FILIAL == xFilial("BRP")
	If !Empty(BRP->BRP_CODSIB)
		aAdd(aGraPar,{BRP->BRP_CODIGO,BRP->BRP_CODSIB})
	EndIf
	BRP->(dbSkip())
EndDo

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | A782Pos  บAutor  ณMicrosiga           บ Data ณ  16/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Alguns posicionamentos necessarios                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A782Pos(dDatDe,dDatAte,cTipReg,aRetBlq)
Local lRet := .T.

// Beneficiario PJ
BQC->(dbSetOrder(1))
If TRBSIB->BA3_TIPOUS <> "1" 
	If !BQC->(dbSeek(xFilial("BQC")+TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
		lRet := .F.
	Else
		If !BT5->(dbSeek(xFilial("BT5")+BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON)))
			lRet := .F.
		EndIf
	EndIf
EndIf

//Cliente
If lRet .And. (TRBSIB->BA1_COBNIV == "1" .Or. TRBSIB->BA3_COBNIV == "1")
	If !SA1->(dbSeek(xFilial("SA1")+TRBSIB->(BA1_CODCLI+BA1_LOJA))) .Or. (SA1->(Found()) .And. TRBSIB->BA1_COBNIV <> "1")
		If !SA1->(dbSeek(xFilial("SA1")+TRBSIB->(BA3_CODCLI+BA3_LOJA))) .Or. (SA1->(Found()) .And. TRBSIB->BA3_COBNIV <> "1")
			lRet := .F.
		EndIf
	EndIf
ElseIf lRet .And. TRBSIB->BA3_TIPOUS <> "1"
	If !SA1->(dbSeek(xFilial("SA1")+TRBSIB->(BA3_CODCLI+BA3_LOJA))) .Or. (SA1->(Found()) .And. TRBSIB->BA3_COBNIV <> "1")
		If !SA1->(dbSeek(xFilial("SA1")+BQC->(BQC_CODCLI+BQC_LOJA))) .Or. (SA1->(Found()) .And. BQC->BQC_COBNIV <> "1")
			If !SA1->(dbSeek(xFilial("SA1")+BT5->(BT5_CODCLI+BT5_LOJA))) .Or. (SA1->(Found()) .And. BT5->BT5_COBNIV <> "1")
				If !SA1->(dbSeek(xFilial("SA1")+BG9->(BG9_CODCLI+BG9_LOJA)))
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
Else
	lRet := .F.
EndIf

aRetPla := PLSIBPLA("TRBSIB") // {BI3_SUSEP,BI3_SCPA,BI3_NATJCO}

If cTipReg <> "1" // Se nao for inclusao verifico bloqueio/desbloqueio
	aRetBlq := PLSIBBLQ(dDatDe,dDatAte,aRetBlq,TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),TRBSIB->BA1_TIPREG,TRBSIB->BA1_LOCSIB,TRBSIB->BA1_EXCANS)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | AlteraSIBบAutor  ณMicrosiga           บ Data ณ  16/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o registro posicionado de TRBSIB sera enviado coบฑฑ
ฑฑบ          ณmo alteracao                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AlteraSIB(lCriaLog,dDatDe,dDatAte,lReenvio)
Local cCmpSIB := GetNewPar("MV_PLSSIB","BA1_DATNAS;BA1_SEXO;BA1_CPFUSR;BA1_NOMUSR;BA1_MAE;BA1_TIPUSU;BA1_ENDERE;BA1_CEPUSR;BA1_MUNICI;BA1_ESTADO;BTS_NRCRNA")
Local cCmpIn  := ""
Local cQryBlq := ""
Local cStmBlq := ""
Local aCmpAlt := {}

If TRBSIB->BA1_LOCSIB $ '1,7' .And. !lReenvio//1=Ativo

	If Empty(TRBSIB->BA1_DATBLO) .And. (Empty(TRBSIB->BA1_DATTRA) .Or. (!Empty(TRBSIB->BA1_DATTRA) .And. TRBSIB->BA1_DATINC < dDatDe))// Nao bloqueado, nao transferido ou transferido antes do periodo

		// Vou verificar todos os campos que tiveram alteracao
		cCmpIn := "('" + cCmpSIB + "')"
		cCmpIn := STRTRAN(cCmpIn, ";", "','")

		cQryBlq := " SELECT BX2_CAMPO FROM " + RetSQLName("BX1") + " X1, " + RetSQLName("BX2") + " X2"
		cQryBlq  += " WHERE BX1_FILIAL = '" + xFilial("BX1") + "' AND BX2_FILIAL = '" + xFilial("BX2") + "' AND X1.BX1_ALIAS IN ('BA1','BTS') AND X1.BX1_TIPO = 'A' AND"
		cQryBlq += 		    " BX1_DATA   >= '" + dDatDe  + "' AND"
		cQryBlq +=        " BX1_DATA   <= '" + dDatAte + "' AND"
		cQryBlq  += " X1.BX1_RECNO IN ( '" + StrZero(TRBSIB->BA1RECNO,10) + "', '" + StrZero(TRBSIB->BTSRECNO,10) + "' ) AND"
		cQryBlq +=        " BX2_CAMPO  IN " + cCmpIn + " AND"
		cQryBlq +=        " BX1_SEQUEN =  BX2_SEQUEN AND"
		cQryBlq +=       " (BX1_DATA   >= '" + TRBSIB->BA1_DATINC + "' OR "
		cQryBlq +=        " BX1_DATA   >= '" + TRBSIB->BA1_INCANS + "'"
		If !Empty(TRBSIB->BA1_DATTRA)
			cQryBlq += " OR X1.BX1_DATA >= '" + TRBSIB->BA1_DATTRA + "'"
		EndIf
		cQryBlq += ") AND X1.D_E_L_E_T_ = ' ' AND X2.D_E_L_E_T_ = ' '"

		cStmBlq := ChangeQuery(cQryBlq)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cStmBlq),"TRBBLQ",.F.,.T.)
		aCmpAlt := {}

		While TRBBLQ->(!Eof())
			aAdd(aCmpAlt,{AllTrim(TRBBLQ->BX2_CAMPO)})
			TRBBLQ->(DbSkip())
		EndDo
		TRBBLQ->(DbCloseArea())

		If Len(aCmpAlt) > 0
			Return {.T.,aCmpAlt}
		EndIf
		
	Else //Empty(TRBSIB->BA1_DATBLO) // Retificacao por transferencia, preciso alterar a matricula
	
		If !Empty(TRBSIB->BA1_TRADES) .And. (TRBSIB->BA1_DATBLO >= dDatDe .And. TRBSIB->BA1_DATBLO <= dDatAte)
			aAdd(aCmpAlt,{"BA1_CODCCO"})
			aAdd(aCmpAlt,{"BA1_MATRIC"})
			Return {.T.,aCmpAlt}
		EndIf

	EndIf

EndIf

If TRBSIB->BA1_LOCSIB == '7' //7=Criticado Alteracao
	Return {.T.,aCmpAlt}
EndIf

Return {.F.,{}}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |ExcluiSIB บAutor  ณMicrosiga           บ Data ณ  18/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o registro posicionado de TRBSIB sera enviado coบฑฑ
ฑฑบ          ณmo exclusao                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ExcluiSIB(lCriaLog,dDatDe,dDatAte,aRetBlq,lReenvio,cDtRSIB)
Local nFor  		:= 0
Local lRet  		:= .F.
Default cDtRSIB	:= ""

If TRBSIB->BA1_LOCSIB == "8" //8=Criticado exclusao
	Return .T.
EndIf

// 1=Ativo; tem codigo CCO; esta bloqueado
If TRBSIB->BA1_LOCSIB == "1" .And. !Empty(TRBSIB->BA1_CODCCO) .And. !Empty(TRBSIB->BA1_DATBLO) .And. ! lReenvio

	If !Empty(TRBSIB->BA1_EXCANS)

		If TRBSIB->BA1_EXCANS >= dDatDe .And. TRBSIB->BA1_EXCANS <= dDatAte
			lRet := .T.
		EndIf

	Else
	
		For nFor := 1 To Len(aRetBlq)
			If Len(aRetBlq[nFor]) > 1
				// E do tipo bloqueio, interessa a ANS 
				If (aRetBlq[nFor-1] == "0" .And. aRetBlq[nFor,7]) .And. ( ; 
					((aRetBlq[nFor,3] >= dDatDe) .And. (aRetBlq[nFor,3] <= dDatAte) ) .Or. ;//bloqueio efetuado no periodo Movimento de ate Movimento Ate
					(Empty(dDatDe) .And. (aRetBlq[nFor,3] <= dDatAte) ) .Or. ;//Movimento De vazio e bloqueio antes do Movimento Ate
					((aRetBlq[nFor,3] >= dDatDe) .And. Empty(dDatAte) ) .Or. ;//Bloqueio posterior a Movimento De
					(Empty(dDatDe) .And. Empty(dDatDe)) .Or. ;//Periodo nao informado
					(!Empty(cDtRSIB) .And. aRetBlq[nFor,3] >= cDtRSIB) .And. (Empty(TRBSIB->BA1_DTRSIB) .Or. TRBSIB->BA1_DTRSIB < cDtRSIB) )//Bloqueio posterior a data para envio retroativo informada
					         
					lRet := .T.
				Else
					lRet := .F.
				EndIf

			EndIf
		Next
	
	EndIf

EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |ReInclSIB บAutor  ณMicrosiga           บ Data ณ  03/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o registro posicionado de TRBSIB sera enviado coบฑฑ
ฑฑบ          ณmo reinclusao                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReInclSIB(lCriaLog,dDatDe,dDatAte,aRetBlq,lReenvio,cDtRSIB)
Local lRet			:= .F.
Local nFor			:= 0
Local nOk			:= 0
Default cDtRSIB	:= ""

If TRBSIB->BA1_LOCSIB == "C" //Criticado na reativacao
	lRet := .T.
EndIf

If !lRet .And. TRBSIB->BA1_LOCSIB $ "2,4" .And. Empty(TRBSIB->BA1_DATBLO) .And. !lReenvio//2=Excluido; 4=Criticado alteracao, sem data de bloqueio
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Primeiro verifica se tem mais de 5 anos de bloqueio                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nFor := 1 To Len(aRetBlq)
		If Len(aRetBlq[nFor]) > 1
			// Nao tem mais de 5 anos de bloqueio
			If (Calc_Idade(Ctod(aRetBlq[nFor,3]),Ctod(dDatAte)) <= 5 ).And. aRetBlq[nFor-1] == "0"
				lRet := .T.     
				nOk  := nFor
			EndIf
		EndIf
	Next nFor
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica se o desbloqueio esta compreendido no periodo informado         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lRet 
		lRet := .F.
		For nFor := nOk To Len(aRetBlq)
			If Len(aRetBlq[nFor]) > 1
				If  aRetBlq[nFor-1] == "1" .And. ( ;//E um desbloqueio
			    		((aRetBlq[nFor,4] >= dDatDe) .And. (aRetBlq[nFor,4] <= dDatAte) ) .Or. ;//Data de desbloqueito entre Movimeto De e Movimento Ate
						(Empty(dDatDe) .And. (aRetBlq[nFor,4] <= dDatAte) ) .Or. ;//Movimento De vazio e desbloqueio anterior a Movimento Ate
						((aRetBlq[nFor,4] >= dDatDe) .And. Empty(dDatAte) ) .Or. ;//Desbloqueio depois de Movimento De e Movimento Ate vazio
						(Empty (dDatDe) .And. Empty(dDatDe) ) .Or.;//Movimento De e Movimetno Ate vazio
						( !Empty(cDtRSIB) .And. (aRetBlq[nFor,4] >= cDtRSIB) .And. (Empty(TRBSIB->BA1_DTRSIB) .Or. TRBSIB->BA1_DTRSIB < cDtRSIB) ) )//Data de desbloqueio posterior a data retroativa informada, e data de retorno do sib anterior a data retroativa
					
					lRet := .T.
				EndIf
			EndIf
		Next nFor
    Endif
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |A782RegAltบAutor  ณMicrosiga           บ Data ณ  16/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdiciona um registro de alteracao para ser gravado no XML   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A782RegAlt(dDatDe,dDatAte,dDatRef,aGraPar,aRetBlq,dDatRef,lDigito,aAltera)
Local nPos    := 0
Local nFor    := 0
Local nCmpAlt := 0
Local cMatAlt := "" //Alteracao de matricula por transferencia
Default aAltera := {}

If nRegAlt >= 1
	nRegAlt++
	aAdd(aRegAlt,Array(35))
Else
	nRegAlt := 1
EndIf

//Se o beneficiario foi transferido no periodo, preciso enviar alteracao da matricula
If !Empty(TRBSIB->BA1_TRADES) .And. ( (TRBSIB->BA1_DATBLO >= dDatDe .And. TRBSIB->BA1_DATBLO <= dDatAte) .Or. (TRBSIB->BA1_LOCSIB == '7')) .Or.;
	( !Empty(TRBSIB->BA1_TRAORI) .And. (TRBSIB->BA1_DATINC >= dDatDe .And. TRBSIB->BA1_DATINC <= dDatAte) )

	If !lDigito // Enviar matricula sem o digito
		cMatAlt := SubStr(AllTrim(TRBSIB->BA1_TRADES),1,Len(AllTrim(TRBSIB->BA1_TRADES))-1)
	Else
		cMatAlt := AllTrim(Iif(!Empty(TRBSIB->BA1_TRADES),TRBSIB->BA1_TRADES,TRBSIB->BA1_TRAORI))
	EndIf

EndIf

/* IDENTIFICACAO PESSOAL */

// CC0 - Codigo de Controle Operacional
aRegAlt[nRegAlt,1] := A782TamCmp(12,TRBSIB->BA1_CODCCO,.F.)

// Codigo de Identificacao do beneficiario na operadora
If lMatAnt .And. Empty(cMatAlt)// Enviar matricula antiga
	If Empty(TRBSIB->BA1_MATANT) .And. !Empty(TRBSIB->BA1_MATUSB)
		aRegAlt[nRegAlt,2] := AllTrim(TRBSIB->BA1_MATUSB)
	Else
		If !Empty(TRBSIB->BA1_MATANT)
			aRegAlt[nRegAlt,2] := AllTrim(TRBSIB->BA1_MATANT)
		Else
			If !lDigito // Enviar matricula sem o digito
				aRegAlt[nRegAlt,2] := AllTrim(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG))
			Else
				aRegAlt[nRegAlt,2] := AllTrim(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))
			EndIf
		EndIf
	EndIf
ElseIf Empty(cMatAlt)
	If !lDigito // Enviar matricula sem o digito
		aRegAlt[nRegAlt,2] := AllTrim(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG))
	Else
		aRegAlt[nRegAlt,2] := AllTrim(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))
	EndIf
Else
	aRegAlt[nRegAlt,2] := Iif(lMatAnt .And. !Empty(TRBSIB->BA1_MATUSB),AllTrim(TRBSIB->BA1_MATUSB),Iif(!Empty(TRBSIB->BA1_MATANT),TRBSIB->BA1_MATANT,cMatAlt)) // Alteracao de matricula por transferencia
EndIf

aRegAlt[nRegAlt,34] := AllTrim(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)) // PARA TRATAMENTO NO PONTO DE ENTRADA PLS782DAD

// Nome do Beneficiario
aRegAlt[nRegAlt,3] := AllTrim(PlRetponto(TRBSIB->BA1_NOMUSR))

// Data de nascimento do beneficiario
aRegAlt[nRegAlt,4] := If(!Empty(TRBSIB->BA1_DATNAS),;
						SubStr(TRBSIB->BA1_DATNAS,1,4) + "-" + SubStr(TRBSIB->BA1_DATNAS,5,2) + "-" + SubStr(TRBSIB->BA1_DATNAS,7,2),;
						StrZero(0,4,0) + "-" + StrZero(0,2,0) + "-" + StrZero(0,2,0))

// Sexo do beneficiario
aRegAlt[nRegAlt,5] := If(TRBSIB->BA1_SEXO == "1","1","3")

// CPF - Cadastro de Pessoas Fisicas - do beneficiario
If !Empty(TRBSIB->BA1_CPFUSR)
	aRegAlt[nRegAlt,6] := TRBSIB->BA1_CPFUSR
Else
	If Calc_Idade(Ctod(dDatRef),Ctod(TRBSIB->BA1_DATNAS)) < 18 .And. TRBSIB->BA1_TIPUSU <> cCodTit
		aRegAlt[nRegAlt,6] := ""
	Else
		If !Empty(TRBSIB->BA1_CPFMAE)
			aRegAlt[nRegAlt,6] := TRBSIB->BA1_CPFMAE
		Else
			If !Empty(TRBSIB->BA1_CPFPRE)
				aRegAlt[nRegAlt,6] := TRBSIB->BA1_CPFPRE
			Else
				aRegAlt[nRegAlt,6] := ""
			EndIf
		EndIf
	EndIf
EndIf

// Numero do PIS/PASEP do beneficiario ou Numero de Identificacao do Trabalhador - NIT
aRegAlt[nRegAlt,7] := AllTrim(TRBSIB->BTS_PISPAS)

// Nome da mae do beneficiario
aRegAlt[nRegAlt,8] := AllTrim(PlRetponto(TRBSIB->BA1_MAE))

// Numero da Declaracao de Nascido Vivo
If TRBSIB->BA1_DATNAS > "20100101"
	aRegAlt[nRegAlt,9] := AllTrim(TRBSIB->BTS_DENAVI)
Else
	aRegAlt[nRegAlt,9] := ""
EndIf

// Numero do Cartao Nacional de Saude
aRegAlt[nRegAlt,10] := AllTrim(TRBSIB->BTS_NRCRNA)

// Codigo de identificacao do beneficiario titular na operadora para beneficiarios informados como dependentes
If TRBSIB->BA1_TIPUSU <> cCodTit
	If Empty(cMatAlt)
		aRegAlt[nRegAlt,11] := A782Tit(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),lDigito,lMatAnt)
	Else
		aRegAlt[nRegAlt,11] := A782Tit(SubStr(cMatAlt,1,14),lDigito,lMatAnt)
	EndIf
Else
	aRegAlt[nRegAlt,11] := ""
EndIf

/* IDENTIFICACAO DE ENDERECO */

// Indicacao de endereco residencial ou profissional 2,1
aRegAlt[nRegAlt,12] := TRBSIB->BTS_TIPEND
If Empty(aRegAlt[nRegAlt,12])
	aRegAlt[nRegAlt,12] := TRBSIB->BA1_TIPEND
EndIf

// Logradouro do beneficiario
aRegAlt[nRegAlt,13] := AllTrim(TRBSIB->BA1_ENDERE)

// Numero do logradouro
aRegAlt[nRegAlt,14] := AllTrim(TRBSIB->BA1_NR_END)

// Complemento do logradouro
aRegAlt[nRegAlt,15] := A782TamCmp(15,AllTrim(TRBSIB->BA1_COMEND))

// Bairro do logradouro
aRegAlt[nRegAlt,16] := AllTrim(TRBSIB->BA1_BAIRRO)

// Codigo do municipio do logradouro indicado
aRegAlt[nRegAlt,17] := A782TamCmp(TamSX3("BA1_CODMUN")[1],AllTrim(TRBSIB->BA1_CODMUN))

// CEP
aRegAlt[nRegAlt,18] := AcerCEP(TRBSIB->BA1_CEPUSR)

// Indicacao se a residencia do beneficiario e no Brasil ou no exterior
aRegAlt[nRegAlt,19] := TRBSIB->BA1_RESEXT

// Codigo do municipio de residencia do beneficiario, caso o endereco informado seja indicado como endereco profissional
aRegAlt[nRegAlt,20] := A782TamCmp(TamSX3("BA1_CODMUN")[1],AllTrim(TRBSIB->BA1_CODMUN))

/* IDENTIFICACAO CONTRATUAL */

// Numero do registro do plano na ANS - BI3_SUSEP
aRegAlt[nRegAlt,21] := aRetPla[1]

// Codigo do cadastrado do plano na ANS - BI3_SCPA
aRegAlt[nRegAlt,22] := aRetPla[2]

// Numero do plano origem ( portabilidade )
If !Empty(TRBSIB->BA3_PLPOR) .Or. !Empty(TRBSIB->BA1_PLPOR)
	aRegAlt[nRegAlt,23] := If(!Empty(TRBSIB->BA1_PLPOR),TRBSIB->BA1_PLPOR,TRBSIB->BA3_PLPOR)
Else
	aRegAlt[nRegAlt,23] := ''
EndIf

// Data de contratacao do plano
aRegAlt[nRegAlt,24] := SubStr(TRBSIB->BA1_DATINC,1,4) + "-" + SubStr(TRBSIB->BA1_DATINC,5,2) + "-" + SubStr(TRBSIB->BA1_DATINC,7,2)

// Data de cancelamento do plano
For nFor := 1 To Len(aRetBlq)
	If Len(aRetBlq[nFor]) > 1
		// E do tipo bloqueio, interessa a ANS, ultima data de bloqueio
		If (aRetBlq[nFor-1] == "0" .And. aRetBlq[nFor,7]) .And. (Empty(aRegAlt[nRegAlt,25]) .Or. (aRetBlq[nFor,3] >= aRegAlt[nRegAlt,25]))			
			aRegAlt[nRegAlt,25] := aRetBlq[nFor,3]// Data de cancelamento do plano
			aRegAlt[nRegAlt,26] := aRetBlq[nFor,1]// Codigo do motivo de cancelamento do plano
		Else
			aRegAlt[nRegAlt,25] := ""// Data de cancelamento do plano
			aRegAlt[nRegAlt,26] := ""// Codigo do motivo de cancelamento do plano
		EndIf
	EndIf
Next

If !Empty(aRegAlt[nRegAlt,25]) // Formata a data de bloqueio
	aRegAlt[nRegAlt,25] := SubStr(aRegAlt[nRegAlt,25],1,4) + "-" + SubStr(aRegAlt[nRegAlt,25],5,2) + "-" + SubStr(aRegAlt[nRegAlt,25],7,2)
EndIf

// Data de reativacao do plano
For nFor := 1 To Len(aRetBlq)
	If Len(aRetBlq[nFor]) > 1
		// E do tipo desbloqueio, interessa a ANS, ultima data de bloqueio
		If (aRetBlq[nFor-1] == "1" .And. aRetBlq[nFor,7]) .And. (Empty(aRegAlt[nRegAlt,27]) .Or. (aRetBlq[nFor,4] >= aRegAlt[nRegAlt,27]))			
			aRegAlt[nRegAlt,27] := aRetBlq[nFor,4]// Data de cancelamento do plano
		Else
			aRegAlt[nRegAlt,27] := ""// Data de reativacao do plano
		EndIf
	EndIf
Next

If !Empty(aRegAlt[nRegAlt,27]) // Formata a data de reativacao
	aRegAlt[nRegAlt,27] := SubStr(aRegAlt[nRegAlt,27],1,4) + "-" + SubStr(aRegAlt[nRegAlt,27],5,2) + "-" + SubStr(aRegAlt[nRegAlt,27],7,2)
EndIf

// Indicacao de existencia de Cobertura Parcial Temporaria
aRegAlt[nRegAlt,28] := PLSIBCPT(dDatRef,TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG))

// Indicacao de itens de procedimentos excluidos da cobertura
aRegAlt[nRegAlt,29] := "0"

// Numero do CNPJ da pessoa  juridica contratante do plano coletivo
If TRBSIB->BA3_TIPOUS <> "1" //Beneficiario PJ
	If !Empty(BQC->BQC_CNPJ)
		aRegAlt[nRegAlt,30] := BQC->BQC_CNPJ
	Else
		If SA1->(dbSeek(xFilial("SA1")+BQC->(BQC_CODCLI+BQC_LOJA)))
			aRegAlt[nRegAlt,30] := SA1->A1_CGC
		Else
			aRetCli := PLSRETNCB(TRBSIB->BA1_CODINT,TRBSIB->BA1_CODEMP,TRBSIB->BA1_MATRIC,TRBSIB->BA1_OPEORI)
			If aRetCli[1]
				If SA1->(dbSeek(xFilial("SA1")+TRBSIB->(BA3_CODCLI+BA3_LOJA)))
					aRegAlt[nRegAlt,30] := SA1->A1_CGC
				EndIf
			EndIf
		EndIf
	EndIf
Else
	aRegAlt[nRegAlt,30] := ""
EndIf

// Numero do CEI do contratante do plano coletivo
If aRetPla[3] $ "3,4"
	If !Empty(BQC->BQC_CAEPF) .AND. Empty(BQC->BQC_CNPJ) .AND. BQC->(FieldPos('BQC_CAEPF')) > 0
		aRegAlt[nRegAlt,30] := "" // Vou informar o CAEPF e nao o CNPJ
		aRegAlt[nRegAlt,36] := AllTrim(BQC->BQC_CAEPF)
	ElseIf !Empty(BQC->BQC_CEINSS) .AND. Empty(BQC->BQC_CNPJ)  
		aRegAlt[nRegAlt,30] := "" // Vou informar o CEI e nao o CNPJ
		aRegAlt[nRegAlt,31] := AllTrim(BQC->BQC_CEINSS)
	ElseIf Empty(BQC->BQC_CNPJ) .AND. !Empty(SA1->A1_CEINSS)
		aRegAlt[nRegAlt,30] := "" // Vou informar o CEI e nao o CNPJ
		aRegAlt[nRegAlt,31] := AllTrim(SA1->A1_CEINSS)
	Else
		aRegAlt[nRegAlt,31] := ""
		aRegAlt[nRegAlt,36] := ""
	EndIf
Else
	aRegAlt[nRegAlt,30] := "" // CNPJ
	aRegAlt[nRegAlt,31] := "" // CEI
	aRegAlt[nRegAlt,36] := "" // CAEPF
EndIf

// Relacao de dependencia
nPos := aScan(aGraPar,{|x| x[1] == TRBSIB->BA1_GRAUPA})
If nPos > 0
	aRegAlt[nRegAlt,32] := aGraPar[nPos,2]
Else
	aRegAlt[nRegAlt,32] := "10"
EndIf

aRegAlt[nRegAlt,33] := .T.

aRegAlt[nRegAlt,35] := aAltera

If lCriaLog
	PlsLogFil(Transform(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),MATRIPLS) +"  "+ ;
	SubStr(AllTrim(TRBSIB->BA1_NOMUSR)+Space(30),1,30)+ " - Retifica็ใo ",cArqLog)
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑฑ
ฑฑณFuncao    ณ AcerCep ณ Autor ณ Tulio Cesar            ณ Data ณ 02.10.00 ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณDescricao ณ Exportacao de dados para o Ministerio da Saude.            ณฑฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑฑ
ฑฑณFuncao    ณ PLSIBBLQ| Autor ณ Microsiga              ณ Data ณ 18/02/11 ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณDescricao ณ Verifica bloqueio, desbloqueio e reinclusao do beneficiarioณฑฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function PLSIBBLQ(dDatDe,dDatAte,aRetBlq,cMatric,cTipReg,cLocSib,cExcAns)
Local cQryBlq := ""
Local cStmBlq := ""
Local nRetBlq := 0
aRetBlq := {"",{"00","","00000000","00000000","","",.F.}}
nRetBlq := Len(aRetBlq)
/*
aRetBlq[1]   0=Bloqueio/1=Desbloqueio
aRetBlq[2,1] Motivo bloqueio
aRetBlq[2,2] Nivel bloqueio
aRetBlq[2,3] Data cancelamento
aRetBlq[2,4] Data reinclusao
aRetBlq[2,5] Data bloqueio
aRetBlq[2,6] Data ultimo bloqueio
aRetBlq[2,7] Interessa a ANS ?
*/

cQryBlq := " SELECT BCA_TIPO, BCA_DATA, BCA_MOTBLO, BCA_NIVBLQ FROM " + RetSQLName("BCA")
cQryBlq += " WHERE BCA_FILIAL = '" + xFilial("BCA") + "' AND"
cQryBlq += " BCA_MATRIC = '" + cMatric + "' AND"
cQryBlq += " BCA_TIPREG = '" + cTipReg + "' AND"
cQryBlq += " BCA_DATA <= '" + dDatAte + "' AND " + RetSQLName("BCA") + ".D_E_L_E_T_ = ' '"
cQryBlq += " ORDER BY R_E_C_N_O_"
cStmBlq := ChangeQuery(cQryBlq)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cStmBlq),"TRBBLQ",.F.,.T.)

While TRBBLQ->(!Eof())
	//Caso a data do (des)bloqueio seja maior que a data final, ignoro, exceto para os usuArios com critica de exclusใo BA1_LOCSIB='8'
	If TRBBLQ->BCA_DATA > dDatAte .And. cLocSib <> "8"
		TRBBLQ->(dbSkip())
		Loop
	EndIf

	If nRetBlq > 2
		aAdd(aRetBlq,"")
		aAdd(aRetBlq,{"00","","00000000","00000000","","",.F.})
		nRetBlq :=  Len(aRetBlq)
	EndIf

	aRetAns := VerifAns(TRBBLQ->BCA_NIVBLQ,TRBBLQ->BCA_MOTBLO)	//Verifico se o bloqueio interessa a ANS

	If TRBBLQ->BCA_TIPO == "0" // bloqueio

		aRetBlq[nRetBlq-1] := "0"

		If aRetAns[1]
			aRetBlq[nRetBlq,1] := aRetAns[2] // Motivo bloqueio
			aRetBlq[nRetBlq,2] := TRBBLQ->BCA_NIVBLQ
			aRetBlq[nRetBlq,3] := TRBBLQ->BCA_DATA
			aRetBlq[nRetBlq,4] := StrZero(0,8,0)
			aRetBlq[nRetBlq,5] := TRBBLQ->BCA_DATA
			aRetBlq[nRetBlq,6] := TRBBLQ->BCA_DATA
		EndIf

	Else

		aRetBlq[nRetBlq-1] := "1" // desbloqueio
		
		If aRetAns[1]
			aRetBlq[nRetBlq,1] := aRetAns[2] // Motivo desbloqueio
			aRetBlq[nRetBlq,2] := TRBBLQ->BCA_NIVBLQ
			aRetBlq[nRetBlq,3] := cExcAns
			aRetBlq[nRetBlq,4] := TRBBLQ->BCA_DATA
			aRetBlq[nRetBlq,5] := StrZero(0,11,0)
			aRetBlq[nRetBlq,6] := cExcAns
		EndIf
		aRetBlq[nRetBlq,4] := TRBBLQ->BCA_DATA

	EndIf

	aRetBlq[nRetBlq,7] := aRetAns[1] // Interessa para ANS ?
	TRBBLQ->(dbSkip())
	nRetBlq++
EndDo
TRBBLQ->(DbCloseArea())

Return aRetBlq

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑฑ
ฑฑณFuncao    ณ VerifAns| Autor ณ Microsiga              ณ Data ณ 18/02/11 ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณDescricao ณ Verifica se um bloqueio em determinado Nivel com certo     ณฑฑฑ
ฑฑณ          ณ motivo interessa para a ANS                                ณฑฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function VerifAns(cNivel,cMotBlo)
Local lRet := .F.
Local cCod := ""

Do Case
	Case cNivel == 'U' // Nivel de Usuario
		If BG3->(dbSeek(xFilial("BG3")+cMotBlo))
			If !Empty(BG3->BG3_BLQANS)
				lRet := .T.
				cCod := StrZero(Val(BG3->BG3_BLQANS),2)
			EndIf
		EndIf
	Case cNivel == 'F' // Nivel de Familia
		If BG1->(dbSeek(xFilial("BG1")+cMotBlo))
			If !Empty(BG1->BG1_BLQANS)
				lRet := .T.
				cCod := StrZero(Val(BG1->BG1_BLQANS),2)
			EndIf
		EndIf
	Case cNivel == 'S' // Nivel de Sub-Contrato
		If BQU->(msSeek(xFilial("BQU")+cMotBlo))
			If !Empty(BQU->BQU_BLQANS)
				lRet := .T.
				cCod := StrZero(Val(BQU->BQU_BLQANS),2)
			EndIf
		EndIf
EndCase

Return({lRet,cCod})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa |A782RegExcบ Autor ณ Microsiga          บ Data ณ  21/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Desc.    ณ Adiciona um registro de exclusao para ser gravado no XML   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso      ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A782RegExc(lCriaLog,lMatAnt,aRetBlq,dDatDe,dDatAte)
Local nFor := 0

If nRegExc >= 1
	nRegExc++
	aAdd(aRegExc,Array(6))
Else
	nRegExc := 1
EndIf

/* IDENTIFICACAO PESSOAL */

// CCO - Codigo de Controle Operacional
aRegExc[nRegExc,1] := A782TamCmp(12,TRBSIB->BA1_CODCCO,.F.)

/* IDENTIFICACAO DE ENDERECO */
aRegExc[nRegExc,2] := ""

/* IDENTIFICACAO CONTRATUAL */

For nFor := 1 To Len(aRetBlq)
	If Len(aRetBlq[nFor]) > 1
		// E do tipo bloqueio, interessa a ANS, ultima data de bloqueio
		If (aRetBlq[nFor-1] == "0" .And. aRetBlq[nFor,7]) .And. (Empty(aRegExc[nRegExc,3]) .Or. (aRetBlq[nFor,3] >= aRegExc[nRegExc,3]))			
			aRegExc[nRegExc,3] := aRetBlq[nFor,3]// Data de cancelamento do plano
			aRegExc[nRegExc,4] := aRetBlq[nFor,1]// Codigo do motivo de cancelamento do plano
		Else
			aRegExc[nRegExc,3] := ""// Data de cancelamento do plano
			aRegExc[nRegExc,4] := ""// Codigo do motivo de cancelamento do plano
		EndIf
	EndIf
Next

//Formatacao da data
aRegExc[nRegExc,3] := IIf(!Empty(AllTrim(aRegExc[nRegExc,3])),SubStr(aRegExc[nRegExc,3],1,4) + "-" + SubStr(aRegExc[nRegExc,3],5,2) + "-" + SubStr(aRegExc[nRegExc,3],7,2),"")

aRegExc[nRegExc,5] := .T.
aRegExc[nRegExc,6] := TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)

If lCriaLog
	PlsLogFil(Transform(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),MATRIPLS) +"  "+ ;
	SubStr(AllTrim(TRBSIB->BA1_NOMUSR)+Space(30),1,30)+ " - Exclusใo ",cArqLog)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A782XML  บAutor  ณMicrosiga           บ Data ณ  02/22/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gravacao do arquivo SBX de envio do SIB                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A782SBX(cDir,cSeqArq,lCriaLog)
Local cTmpXml := "" // Conteudo temporario
Local nTmpXml := FCreate(cDir+cNamTmp,0,,.F.) // Arquivo temporario
Local cCabXml := "" // cabecalho do arquivo SBX
Local nCabXml := FCreate(cDir+cNamCab,0,,.F.) // Arquivo temporario
Local nArqSib := 0 // Arquivo SBX
Local cDtHr   := SubStr(Dtos(dDataBase),1,4) + "-" + SubStr(Dtos(dDataBase),5,2) + "-" + SubStr(Dtos(dDataBase),7,2) + "T" + Time() + "Z" //2001-12-17T09:30:47.0Z
Local cVerApl := GetBuild() // Versao da BUILD
Local cHash	  := "" // Hash do arquivo SBX
Local nFor	  := 0 
Local cBuffer := Space(F_BLOCK)
Local lFinal  := .F.
Local nBytes  := 0
Local lPE     := Existblock("PLS782DAD")
Private nNmHash := 0//FCreate(cNmHash,0,,.F.) // Arquivo para calculo do hash

cCabXml := '<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>' + CRLF 
cCabXml += '<mensagemSIB xmlns:ansSIB="https://www.ans.gov.br/padroes/sib/schemas" xmlns:xsi="https://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="https://www.ans.gov.br/padroes/sib/schemas https://www.ans.gov.br/padroes/sib/schemas/sib.xsd">' + CRLF

If nCabXml > 0 // Vou gravar um temporario com o cabecalho
	FWrite(nCabXml,cCabXml)
	FClose(nCabXml)
Else
	MsgInfo("Nใo foi possํvel gravar o arquivo de cabe็alho " + cNamCab)
	Return .F.
EndIf

nNmHash := FCreate(cDir+cNmHash,0,,.F.) // Arquivo para calculo do hash
If nNmHash <= 0 // arquivo temporario para calculo do HASH
	MsgInfo("Nใo foi possํvel gravar o arquivo do hash " + cNmHash)
	Return .F.
EndIf

FWrite(nNmHash,'https://www.ans.gov.br/padroes/sib/schemas https://www.ans.gov.br/padroes/sib/schemas/sib.xsd')

If nTmpXml > 0 // vou escrever no arquivo temporario

	cTmpXml := A782Tag(2,'cabecalho','',.T.,.F.,.T.) // Cabecalho - inicio
	cTmpXml += A782Tag(4,'identificacaoTransacao','',.T.,.F.,.T.) 
	cTmpXml += A782Tag(6,'tipoTransacao',"SIB",.T.,.T.,.F.,.F.)
	cTmpXml += A782Tag(6,'sequencialTransacao',cSeqArq,.T.,.T.,.F.)
	cTmpXml += A782Tag(6,'dataHoraRegistroTransacao',cDtHr,.T.,.T.,.F.,.F.)
	cTmpXml += A782Tag(4,'identificacaoTransacao','',.F.,.T.,.T.)
	cTmpXml += A782Tag(4,'origem','',.T.,.F.,.T.)
	cTmpXml += A782Tag(6,'registroANS',BA0->BA0_SUSEP,.T.,.T.,.F.)
	cTmpXml += A782Tag(4,'origem','',.F.,.T.,.T.)
	cTmpXml += A782Tag(4,'destino','',.T.,.F.,.T.)
	cTmpXml += A782Tag(6,'cnpj','03589068000146',.T.,.T.,.F.)
	cTmpXml += A782Tag(4,'destino','',.F.,.T.,.T.)
	cTmpXml += A782Tag(4,'versaoPadrao','1.1',.T.,.T.,.F.,.F.)
	cTmpXml += A782Tag(4,'identificacaoSoftwareGerador','',.T.,.F.,.T.)
	cTmpXml += A782Tag(6,'nomeAplicativo',cNomPLS,.T.,.T.,.F.,.F.)
	cTmpXml += A782Tag(6,'versaoAplicativo',cVerApl,.T.,.T.,.F.,.F.)
	cTmpXml += A782Tag(6,'fabricanteAplicativo',cFabApl,.T.,.T.,.F.,.F.)
	cTmpXml += A782Tag(4,'identificacaoSoftwareGerador','',.F.,.T.,.T.)
	cTmpXml += A782Tag(2,'cabecalho','',.F.,.T.,.T.)
	cTmpXml += A782Tag(0,'mensagem','',.T.,.F.,.T.)
	cTmpXml += A782Tag(2,'operadoraParaANS','',.T.,.F.,.T.)
	FWrite(nTmpXml,cTmpXml) // Cabecalho - termino

	cTmpXml := A782Tag(4,'beneficiarios','',.T.,.F.,.T.)

	If nRegInc > 0 // Inclusao - inicio

		IncProc("Escrevendo registros de inclusao no arquivo")

		For nFor := 1 To Len(aRegInc)

			If lPE // PONTO DE ENTRADA - PLS782DAD

				aRegInc[nFor] := Execblock("PLS782DAD",.F.,.F.,{"1",aRegInc[nFor]})

				If ValType(aRegInc[nFor]) <> "A" .Or. Len(aRegInc[nFor]) < 29 .Or. !aRegInc[nFor,29] //Se o retorno do PE nao e valido, ou foi desconsiderado
					nRegInc--
					Loop
				EndIf

			Endif          
          
			cTmpXml += A782Tag(6,'inclusao','',.T.,.F.,.T.)
			cTmpXml += A782Tag(8,'identificacao','',.T.,.F.,.T.)

			cTmpXml += A782Tag(10,'cpf',aRegInc[nFor,5],.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'pisPasep',aRegInc[nFor,6],.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'dn',aRegInc[nFor,8],.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'cns',aRegInc[nFor,9],.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'nome',aRegInc[nFor,2],.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'sexo',aRegInc[nFor,4],.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'dataNascimento',aRegInc[nFor,3],.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'nomeMae',aRegInc[nFor,7],.T.,.T.,.F.)

			cTmpXml += A782Tag(8,'identificacao','',.F.,.T.,.T.)
			cTmpXml += A782Tag(8,'endereco','',.T.,.F.,.T.)

			cTmpXml += A782Tag(10,'logradouro',aRegInc[nFor,12],.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'numero',aRegInc[nFor,13],.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'complemento',aRegInc[nFor,14],.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'bairro',aRegInc[nFor,15],.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'codigoMunicipio',aRegInc[nFor,16],.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'codigoMunicipioResidencia',aRegInc[nFor,19],.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'cep',aRegInc[nFor,17],.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'tipoEndereco',aRegInc[nFor,11],.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'resideExterior',aRegInc[nFor,18],.T.,.T.,.F.)

			cTmpXml += A782Tag(8,'endereco','',.F.,.T.,.T.)
			cTmpXml += A782Tag(8,'vinculo','',.T.,.F.,.T.)

			cTmpXml += A782Tag(10,'codigoBeneficiario',aRegInc[nFor,1],.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'relacaoDependencia',IIf(aRegInc[nFor,10]!=aRegInc[nFor,1],aRegInc[nFor,28],""),.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'codigoBeneficiarioTitular',IIf(aRegInc[nFor,10]!=aRegInc[nFor,1],aRegInc[nFor,10],""),.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'dataContratacao',aRegInc[nFor,23],.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'numeroPlanoANS',aRegInc[nFor,20],.T.,.T.,.F.)
			cTmpXml += A782Tag(10,'numeroPlanoOperadora',aRegInc[nFor,21],.T.,.T.,.F.,.F.)
			cTmpXml += A782Tag(10,'numeroPlanoPortabilidade',aRegInc[nFor,22],.T.,.T.,.F.)
			If lTrataCPT
				cTmpXml += A782Tag(10,'coberturaParcialTemporaria',aRegInc[nFor,24],.T.,.T.,.F.)
				cTmpXml += A782Tag(10,'itensExcluidosCobertura',aRegInc[nFor,25],.T.,.T.,.F.)
			EndIf
			If !Empty(aRegInc[nFor,26])
				cTmpXml += A782Tag(10,'cnpjEmpresaContratante',aRegInc[nFor,26],.T.,.T.,.F.)
			ElseIf !Empty(aRegInc[nFor,30]) 
				cTmpXml += A782Tag(10,'caepfEmpresaContratante',aRegInc[nFor,30],.T.,.T.,.F.)
			ElseIf !Empty(aRegInc[nFor,27])
				cTmpXml += A782Tag(10,'ceiEmpresaContratante',aRegInc[nFor,27],.T.,.T.,.F.)
			EndIf

			cTmpXml += A782Tag(8,'vinculo','',.F.,.T.,.T.)
			cTmpXml += A782Tag(6,'inclusao','',.F.,.T.,.T.)
			FWrite(nTmpXml,cTmpXml)
			cTmpXml := ""

		Next nFor
	EndIf // Inclusao - termino

	If nRegAlt > 0 // Alteracao - inicio

		IncProc("Escrevendo registros de retifica็ใo no arquivo")
          
		For nFor := 1 To Len(aRegAlt)

			If lPE // PONTO DE ENTRADA - PLS782DAD

				aRegAlt[nFor] := Execblock("PLS782DAD",.F.,.F.,{"2",aRegAlt[nFor]})

				If ValType(aRegAlt[nFor]) <> "A" .Or. Len(aRegAlt[nFor]) < 33 .Or. !aRegAlt[nFor,33] //Se o retorno do PE nao e valido, ou foi desconsiderado
					nRegAlt--
					Loop
				EndIf 	

			Endif
			
			cGruXml := ""
			cIteXml := ""
			lGruXml := .F.

			cTmpXml += A782Tag(06,'retificacao','',.T.,.F.,.T.)
			cTmpXml += A782Tag(08,'cco',aRegAlt[nFor,1],.T.,.T.,.F.,EnviaTag(aRegAlt[nFor,35,2],"BA1_CODCCO",@lGruXml))
			cIteXml := A782Tag(10,'cpf',aRegAlt[nFor,6],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_CPFUSR",@lGruXml))
			cIteXml += A782Tag(10,'pisPasep',aRegAlt[nFor,7],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_PISPAS",@lGruXml))
			cIteXml += A782Tag(10,'dn',aRegAlt[nFor,9],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BTS_DENAVI",@lGruXml))
			cIteXml += A782Tag(10,'cns',aRegAlt[nFor,10],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BTS_NRCRNA",@lGruXml))
			cIteXml += A782Tag(10,'nome',aRegAlt[nFor,3],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_NOMUSR",@lGruXml))
			cIteXml += A782Tag(10,'sexo',aRegAlt[nFor,5],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_SEXO",@lGruXml))
			cIteXml += A782Tag(10,'dataNascimento',aRegAlt[nFor,4],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_DATNAS",@lGruXml))
			cIteXml += A782Tag(10,'nomeMae',aRegAlt[nFor,8],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_MAE",@lGruXml))

			cTmpXml += A782Tag(08,'identificacao','',.T.,.F.,.T.)
			If lGruXml
				cTmpXml += cIteXml
			EndIf
			cTmpXml += A782Tag(08,'identificacao','',.F.,.T.,.T.)

			cGruXml := ""
			cIteXml := ""
			lGruXml := .F. 

			cIteXml += A782Tag(10,'logradouro',aRegAlt[nFor,13],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_ENDERE",@lGruXml))
			cIteXml += A782Tag(10,'numero',aRegAlt[nFor,14],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_NR_END",@lGruXml))
			cIteXml += A782Tag(10,'complemento',aRegAlt[nFor,15],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_COMEND",@lGruXml))
			cIteXml += A782Tag(10,'bairro',aRegAlt[nFor,16],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_BAIRRO",@lGruXml))
			cIteXml += A782Tag(10,'codigoMunicipio',aRegAlt[nFor,17],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_CODMUN",@lGruXml))
			cIteXml += A782Tag(10,'codigoMunicipioResidencia',aRegAlt[nFor,20],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_CODMUN",@lGruXml))
			cIteXml += A782Tag(10,'cep',aRegAlt[nFor,18],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_CEPUSR",@lGruXml))
			cIteXml += A782Tag(10,'tipoEndereco',aRegAlt[nFor,12],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_TIPEND",@lGruXml))
			cIteXml += A782Tag(10,'resideExterior',aRegAlt[nFor,19],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_RESEXT",@lGruXml))

			cTmpXml += A782Tag(8,'endereco','',.T.,.F.,.T.,,.T.)
			If lGruXml
				cTmpXml += cIteXml
			EndIf
			cTmpXml += A782Tag(8,'endereco','',.F.,.T.,.T.,,.T.)
			
			cGruXml := ""
			cIteXml := ""
			lGruXml := .F. 

			cIteXml += A782Tag(10,'codigoBeneficiario',aRegAlt[nFor,2],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_MATRIC",@lGruXml))
			cIteXml += A782Tag(10,'relacaoDependencia',IIf(aRegAlt[nFor,10]!=aRegAlt[nFor,1],aRegAlt[nFor,32],""),.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_GRAUPA",@lGruXml))
			cIteXml += A782Tag(10,'codigoBeneficiarioTitular',IIf(aRegAlt[nFor,11]!=aRegAlt[nFor,2],aRegAlt[nFor,11],""),.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_MATRIC",@lGruXml))
			cIteXml += A782Tag(10,'dataContratacao',aRegAlt[nFor,24],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_DATINC",@lGruXml))
			cIteXml += A782Tag(10,'dataCancelamento',aRegAlt[nFor,25],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_DATBLO",@lGruXml))
			cIteXml += A782Tag(10,'motivoCancelamento',aRegAlt[nFor,26],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_MOTBLO",@lGruXml))			
			cIteXml += A782Tag(10,'numeroPlanoANS',aRegAlt[nFor,21],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BI3_SCPA,BI3_SUSEP",@lGruXml))
			cIteXml += A782Tag(10,'numeroPlanoOperadora',aRegAlt[nFor,22],.T.,.T.,.F.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BI3_SCPA,BI3_SUSEP",@lGruXml))
			cIteXml += A782Tag(10,'numeroPlanoPortabilidade',aRegAlt[nFor,23],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BA1_PLPOR",@lGruXml))
			If lTrataCPT
				cIteXml += A782Tag(10,'coberturaParcialTemporaria',aRegAlt[nFor,28],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BF3_UNAGR",@lGruXml))
				cIteXml += A782Tag(10,'itensExcluidosCobertura',aRegAlt[nFor,29],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BF3_UNAGR",@lGruXml))
			EndIf
			If !Empty(aRegAlt[nFor,30])
				cIteXml += A782Tag(10,'cnpjEmpresaContratante',aRegAlt[nFor,30],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BQC_CODCLI,BA3_CODCLI",@lGruXml))
			ElseIf !Empty(aRegAlt[nFor,36])
				cIteXml += A782Tag(10,'caepfEmpresaContratante',aRegAlt[nFor,36],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BQC_CAEPF",@lGruXml))
			ElseIf !Empty(aRegAlt[nFor,31])
				cIteXml += A782Tag(10,'ceiEmpresaContratante',aRegAlt[nFor,31],.T.,.T.,.F.,,EnviaTag(aRegAlt[nFor,35,2],"BQC_CEINSS",@lGruXml))
			EndIf
			//cTmpXml += A782Tag(10,'codigoProcedimentoAdministrativo',StrZero(0,20),.T.,.T.,.F.)

			cTmpXml += A782Tag(8,'vinculo','',.T.,.F.,.T.,,.T.)
			If lGruXml
				cTmpXml += cIteXml
			EndIf
			cTmpXml += A782Tag(8,'vinculo','',.F.,.T.,.T.,,.T.)
			
			cTmpXml += A782Tag(6,'retificacao','',.F.,.T.,.T.,,.T.)
			FWrite(nTmpXml,cTmpXml)
			cTmpXml := ""

		Next nFor
	EndIf // Alteracao - termino

	If nRegExc > 0 // Cancelamento - inicio

		IncProc("Escrevendo registros de cancelamento no arquivo")

		For nFor := 1 To Len(aRegExc)

			If lPE // PONTO DE ENTRADA - PLS782DAD

				aRegExc[nFor] := Execblock("PLS782DAD",.F.,.F.,{"3",aRegExc[nFor]})

				If ValType(aRegExc[nFor]) <> "A" .Or. Len(aRegExc[nFor]) < 5 .Or. !aRegExc[nFor,5] //Se o retorno do PE nao e valido, ou foi desconsiderado
					nRegExc--
					Loop
				EndIf

			EndIf

			If !Empty(aRegExc[nFor,1]) .And. !Empty(aRegExc[nFor,3]) .And. !Empty(aRegExc[nFor,4])

				cTmpXml += A782Tag(6,'cancelamento','',.T.,.F.,.T.)
				cTmpXml += A782Tag(8,'cco',aRegExc[nFor,1],.T.,.T.,.F.)
				cTmpXml += A782Tag(8,'dataCancelamento', aRegExc[nFor,3],.T.,.T.,.F.)
				cTmpXml += A782Tag(8,'motivoCancelamento',aRegExc[nFor,4],.T.,.T.,.F.)
				cTmpXml += A782Tag(6,'cancelamento','',.F.,.T.,.T.)
				FWrite(nTmpXml,cTmpXml)
				cTmpXml := ""
			Else
				nRegExc--
			EndIf

		Next nFor
	EndIf // Cancelamento - termino

	If nRegRei > 0 // Reativacao - inicio

		IncProc("Escrevendo registros de reativa็ใo no arquivo")

		For nFor := 1 To Len(aRegRei)
		
			
			If lPE // PONTO DE ENTRADA - PLS782DAD

				aRegRei[nFor] := Execblock("PLS782DAD",.F.,.F.,{"4",aRegRei[nFor]})

				If ValType(aRegRei[nFor]) <> "A" .Or. Len(aRegRei[nFor]) < 4 .Or. !aRegRei[nFor,4] //Se o retorno do PE nao e valido, ou foi desconsiderado
					nRegRei--
					Loop
				EndIf

			EndIf
		
			If !Empty(aRegRei[nFor,1]) .And. !Empty(aRegRei[nFor,3])

				cTmpXml += A782Tag(6,'reativacao','',.T.,.F.,.T.)
				cTmpXml += A782Tag(8,'cco',aRegRei[nFor,1],.T.,.T.,.F.)
				cTmpXml += A782Tag(8,'dataReativacao',aRegRei[nFor,3],.T.,.T.,.F.)
				cTmpXml += A782Tag(6,'reativacao','',.F.,.T.,.T.)
				FWrite(nTmpXml,cTmpXml)
				cTmpXml := ""
			Else
				nRegRei--
			EndIf

		Next nFor
	EndIf // Reativacao - termino

	If nRegMud > 0 // Mudanca contratual - inicio

		IncProc("Escrevendo registros de mudan็a contratual no arquivo")

		For nFor := 1 To Len(aRegMud)

			If lPE // PONTO DE ENTRADA - PLS782DAD

				aRegMud[nFor] := Execblock("PLS782DAD",.F.,.F.,{"5",aRegMud[nFor]})

				If ValType(aRegMud[nFor]) <> "A" .Or. Len(aRegMud[nFor]) < 13 .Or. !aRegMud[nFor,13] //Se o retorno do PE nao e valido, ou foi desconsiderado
					nRegMud--
					Loop
				EndIf

			Endif          

			cTmpXml += A782Tag(6,'mudancaContratual','',.T.,.F.,.T.)
			cTmpXml += A782Tag(8,'cco',aRegMud[nFor,1],.T.,.T.,.F.)
			cTmpXml += A782Tag(8,'relacaoDependencia',aRegMud[nFor,11],.T.,.T.,.F.)
			cTmpXml += A782Tag(8,'codigoBeneficiarioTitular',aRegMud[nFor,12],.T.,.T.,.F.)
            cTmpXml += A782Tag(8,'dataContratacao',Iif(aRegMud[nFor,15] == "    -  -  ", aRegMud[nFor,6],aRegMud[nFor,15]),.T.,.T.,.F.)
			cTmpXml += A782Tag(8,'numeroPlanoANS',aRegMud[nFor,3],.T.,.T.,.F.)
			cTmpXml += A782Tag(8,'numeroPlanoOperadora',aRegMud[nFor,4],.T.,.T.,.F.,.F.)
			cTmpXml += A782Tag(8,'numeroPlanoPortabilidade',aRegMud[nFor,5],.T.,.T.,.F.)
			If lTrataCPT
				cTmpXml += A782Tag(8,'coberturaParcialTemporaria',aRegMud[nFor,7],.T.,.T.,.F.)
				cTmpXml += A782Tag(8,'itensExcluidosCobertura',aRegMud[nFor,8],.T.,.T.,.F.)
			EndIf
			If !Empty(aRegMud[nFor,9])
				cTmpXml += A782Tag(8,'cnpjEmpresaContratante',aRegMud[nFor,9],.T.,.T.,.F.)
			ElseIf !Empty(aRegMud[nFor,16])
				cTmpXml += A782Tag(8,'caepfEmpresaContratante',aRegMud[nFor,16],.T.,.T.,.F.)
			ElseIf !Empty(aRegMud[nFor,10])
				cTmpXml += A782Tag(8,'ceiEmpresaContratante',aRegMud[nFor,10],.T.,.T.,.F.)
			EndIf
			cTmpXml += A782Tag(6,'mudancaContratual','',.F.,.T.,.T.)
			FWrite(nTmpXml,cTmpXml)
			cTmpXml := ""

		Next nFor
	EndIf // Mudanca contratual - termino
	
	If (nRegInc > 0) .Or. (nRegAlt > 0) .Or. (nRegExc > 0) .Or. (nRegRei > 0) .Or. (nRegMud > 0)
		cTmpXml := A782Tag(4,'beneficiarios','',.F.,.T.,.T.)
	Else
		cTmpXml := StrTran(cTmpXml,'<beneficiarios>','',1)// Retiro a tag <beneficiarios>
		cTmpXml += A782Tag(4,'naoEnvioBeneficiarios','',.T.,.F.,.T.)
		cTmpXml += A782Tag(6,'motivoNaoEnvioBeneficiarios','62',.T.,.T.,.F.)
		cTmpXml += A782Tag(4,'naoEnvioBeneficiarios','',.F.,.T.,.T.)
	EndIf

	cTmpXml += A782Tag(2,'operadoraParaANS','',.F.,.T.,.T.)
	cTmpXml += A782Tag(0,'mensagem','',.F.,.T.,.T.)
	FWrite(nTmpXml,cTmpXml)
	FClose(nTmpXml)	
Else
	MsgInfo("Nใo foi possํvel gerar o arquivo xml " + cNamTmp)
	Return .F.
EndIf

If lCrialog .And. lPE
	PlsLogFil("Escrita do arquivo SBX utilizou ponto de entrada",cArqLog)
EndIf
FClose(nNmHash)
cNamArq := cDir + BA0->BA0_SUSEP + Dtos(dDataBase) + Replace(Time(),":","") + ".SBX" // Nome do arquivo de envio do SIB a ser gerado
nArqSib := FCreate(cNamArq,0,,.F.) // criacao do arquivo SBX
If nArqSib <= 0
	MsgInfo("Nใo foi possํvel criar o arquivo " + cDir+cNamArq)
	Return .F.
EndIf

nCabXml := FOpen(cDir+cNamCab,FO_READ) // arquivo de cabecalho
If nCabXml <= 0
	MsgInfo("Nใo foi possํvel abrir o arquivo " + cDir+cNamCab)
	Return .F. 
EndIf

nTmpXml := FOpen(cDir+cNamTmp,FO_READ) // arquivo temporario
If nTmpXml <= 0
	MsgInfo("Nใo foi possํvel abrir o arquivo " + cDir+cNamTmp)
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
cHash := A782Hash(cDir+cNmHash,lCriaLog) // Efetuo o calculo do hash
FErase(cDir+cNmHash)

cTmpXml := A782Tag(0,'epilogo','',.T.,.F.,.T.)
cTmpXml += A782Tag(2,'hash',Upper(cHash),.T.,.T.,.T.)
cTmpXml += A782Tag(0,'epilogo','',.F.,.T.,.T.)
cTmpXml += A782Tag(0,'mensagemSIB','',.F.,.T.,.T.)
FWrite(nArqSib,cTmpXml)
FClose(nArqSib)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA782AtuSibบAutor  ณMicrosiga           บ Data ณ  23/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esta rotina ira atualizar os usuarios de acordo com as in  บฑฑ
ฑฑบ          ณ formacoes enviadas para ANS pelo arquivo do SIB            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ1ฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A782AtuSib(cTipReg,dDatRef,lAtuSib)

BA1->(dbGoTo(TRBSIB->BA1RECNO))
RecLock("BA1",.F.)
If lAtuSib
	Do Case
		Case cTipReg == "3" // Atualizo beneficiario enviado como inclusao
			BA1->BA1_LOCSIB := cTipReg
			BA1->BA1_EXCANS := Ctod("")
			BA1->BA1_INCANS := BA1->BA1_DATINC
		Case cTipReg == "4" // Atualizo beneficiario enviado como retificacao
			BA1->BA1_LOCSIB := cTipReg
		Case cTipReg == "5" // Atualizo beneficiario enviado como cancelamento
			BA1->BA1_LOCSIB := cTipReg
			BA1->BA1_EXCANS := BA1->BA1_DATBLO
		Case cTipReg == "A" // Atualizo beneficiario enviado como reativacao
			BA1->BA1_LOCSIB := cTipReg
			BA1->BA1_EXCANS := Ctod("")
		Case cTipReg == "9" // Atualizo beneficiario enviado como mudanca contratual
			BA1->BA1_LOCSIB := cTipReg
	EndCase
EndIf

BA1->BA1_ENVANS := Stod(dDatRef)
BA1->(msUnlock())

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA782RegReiบAutor  ณMicrosiga           บ Data ณ  14/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa registros de reinclusao                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A782RegRei(aRegRei,aRetBlq)
Local nBlq   := 0 // Contador para percorrer a matriz de historico de bloqueio
Local cDtBlq := "" // Data de desbloqueio 

If nRegRei >= 1
	nRegRei++
	aAdd(aRegRei,Array(5))
Else
	nRegRei := 1
EndIf

/* IDENTIFICACAO PESSOAL */

// CCO - Codigo de Controle Operacional
aRegRei[nRegRei,1] := A782TamCmp(12,TRBSIB->BA1_CODCCO,.F.)

/* IDENTIFICACAO DE ENDERECO */

//Codigo do municipio de residencia do beneficiario, caso o endereco informado seja indicado como endereco profissional
aRegRei[nRegRei,2] := A782TamCmp(6,AllTrim(TRBSIB->BA1_MUNRES))

/* IDENTIFICACAO CONTRATUAL */

// Data de reativacao do plano
For nBlq := 1 To Len(aRetBlq)
	If Len(aRetBlq[nBlq]) > 1
		// E um desbloqueio, encontrou a data de desbloqueio, ultima data de desbloqueio
		If aRetBlq[nBlq-1] == "1" .And. aRetBlq[nBlq,4] != "00000000" .And. (Empty(cDtBlq) .Or. cDtBlq < aRetBlq[nBlq,4])
			cDtBlq := aRetBlq[nBlq,4]
		EndIf
	EndIf	
Next

aRegRei[nRegRei,3] := Iif(!Empty(cDtBlq),SubStr(cDtBlq,1,4) + "-" + SubStr(cDtBlq,5,2) + "-" + SubStr(cDtBlq,7,2),"")

aRegRei[nRegRei,4] := .T.
aRegRei[nRegRei,5] := TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)

If lCriaLog
	PlsLogFil(Transform(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),MATRIPLS) +"  "+ ;
	SubStr(AllTrim(TRBSIB->BA1_NOMUSR)+Space(30),1,30)+ " - Reativa็ใo ",cArqLog)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VlrPerg  บAutor  ณMicrosiga           บ Data ณ  14/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o preenchimento das perguntas de execucao da rotina บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldPerg()
Local lRet := .T.
Local cMsg := ""

If Empty(mv_par01)
	lRet := .F.
	cMsg := "Informe a Operadora" + CRLF 
EndIf

If Empty(mv_par03)
	lRet := .F.
	cMsg += "Informe o Grupo/Empresa at้" + CRLF 
EndIf

If Empty(mv_par04)
	lRet := .F.
	cMsg += "Informe a Data refer๊ncia" + CRLF 
EndIf

If Empty(mv_par05)
	lRet := .F.
	cMsg += "Informe Movimento De" + CRLF 
EndIf

If Empty(mv_par06)
	lRet := .F.
	cMsg += "Informe Movimento At้" + CRLF 
EndIf

If Empty(mv_par07)
	lRet := .F.
	cMsg += "Informe Num Seq Arquivo" + CRLF 
EndIf

If Empty(mv_par09)
	lRet := .F.
	cMsg += "Informe o Diret๓rio" 
EndIf

If !lRet
	MsgInfo(cMsg)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLSA782  บ Autor ณ Microsiga          บ Data ณ  04/18/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Formata a TAG XML a ser escrita no arquivo                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
nSpc    = espaco para identar o arquivo
cTag    = nome da tab
cVal    = valor da tag
lIni    = abertura de tag
lFin    = fechamento de tag
lPerNul = permitido nulo na tag
lRetPto = retira caracteres especiais
*/
Static Function A782Tag(nSpc,cTag,cVal,lIni,lFin,lPerNul,lRetPto,lEnvTag)
Local cRetTag := "" // Tag a ser gravada no arquivo texto
Default lRetPto := .T.
Default lEnvTag := .T.

If !Empty(cVal) .Or. lPerNul

	If lIni // Inicializa a tag ?
		cRetTag += '<' + cTag + '>'
		cRetTag += AllTrim(Iif(lRetPto,PlRetponto(cVal),cVal))
	EndIf

	If lFin // Finaliza a tag ?
		cRetTag += '</' + cTag + '>'
	EndIf

	If lEnvTag .And. nNmHash > 0 // Escreve conteudo da tag no temporario pra calculo do hash
		FWrite(nNmHash,AllTrim(Iif(lRetPto,PlRetponto(cVal),cVal)))
	EndIf

	cRetTag := Space(nSpc) + cRetTag + CRLF // Identa o arquivo

EndIf

Return Iif(lEnvTag,cRetTag,"")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | MudPlaSIBบAutor  ณMicrosiga           บ Data ณ  16/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o registro posicionado de TRBSIB sera enviado coบฑฑ
ฑฑบ          ณmo mudanca de plano                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MudPlaSib(dDatDe,dDatAte,lReenvio,cDtRSIB)
Local aAreas  := {}
//Local cMatric := Iif(!Empty(TRBSIB->BA1_TRAORI),TRBSIB->BA1_TRAORI,TRBSIB->BA1_TRADES)

If TRBSIB->BA1_LOCSIB == "B" //Criticado na mudanca contratual
	Return .T.
EndIf

// Retificacao por transferencia/mudanca de plano
If !Empty(TRBSIB->BA1_TRAORI) .And. ;
	( (TRBSIB->BA1_DATINC >= dDatDe .Or. (!Empty(cDtRSIB) .And. TRBSIB->BA1_DATINC >= cDtRSIB .And. (Empty(TRBSIB->BA1_DTRSIB) .Or. cDtRSIB > TRBSIB->BA1_DTRSIB)) ) .And. TRBSIB->BA1_DATINC <= dDatAte) ;
	.And. Empty(TRBSIB->BA1_DATBLO) .And. !lReenvio

	aAreas := GetArea()
	BA1->(dbSetOrder(2))

	If BA1->(dbSeek(xFilial("BA1")+TRBSIB->BA1_TRAORI)) // Vou verificar se mudou o plano no usuario

		If !Empty(BA1->BA1_CODPLA) .And. BA1->BA1_CODPLA != TRBSIB->BA1_CODPLA
			Return .T.
		EndIf

	EndIf 

	BA3->(dbSetOrder(1))

	If BA3->(dbSeek(xFilial("BA3")+SubStr(TRBSIB->BA1_TRAORI,1,14)))
		If BA3->BA3_CODPLA != TRBSIB->BA3_CODPLA // vou verificar se mudou o plano na familia
			Return .T.
		EndIf			
	EndIf

	RestArea(aAreas)

EndIf

Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA782RegMudบAutor  ณMicrosiga           บ Data ณ  16/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa registros de mudanca contratual                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A782RegMud(aRegMud,aRetBlq,aGraPar,lDigito,dDatRef)

If nRegMud >= 1
	nRegMud++
	aAdd(aRegMud,Array(15))
Else
	nRegMud := 1
EndIf

/* IDENTIFICACAO PESSOAL */

// CC0 - Codigo de Controle Operacional
aRegMud[nRegMud,1] := A782TamCmp(12,TRBSIB->BA1_CODCCO,.F.)

/* IDENTIFICACAO DE ENDERECO */

// Codigo do municipio de residencia do beneficiario, caso o endereco informado seja indicado como endereco profissional
aRegMud[nRegMud,2] := A782TamCmp(6,AllTrim(TRBSIB->BA1_MUNRES))

/* IDENTIFICACAO CONTRATUAL */

// Numero do registro do plano na ANS - BI3_SUSEP
aRegMud[nRegMud,3] := aRetPla[1]

// Codigo do cadastrado do plano na ANS - BI3_SCPA
aRegMud[nRegMud,4] := aRetPla[2]

// Numero do plano origem ( portabilidade )
If !Empty(TRBSIB->BA3_PLPOR) .Or. !Empty(TRBSIB->BA1_PLPOR)
	aRegMud[nRegMud,5] := If(!Empty(TRBSIB->BA1_PLPOR),TRBSIB->BA1_PLPOR,TRBSIB->BA3_PLPOR)
Else
	aRegMud[nRegMud,5] := ''
EndIf

// Data de contratacao do plano
aRegMud[nRegMud,6] := SubStr(TRBSIB->BA1_DATINC,1,4) + "-" + SubStr(TRBSIB->BA1_DATINC,5,2) + "-" + SubStr(TRBSIB->BA1_DATINC,7,2)

// Indicacao de existencia de Cobertura Parcial Temporaria
aRegMud[nRegMud,7] := PLSIBCPT(dDatRef,TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG))

// Indicacao de itens de procedimentos excluidos da cobertura
aRegMud[nRegMud,8] := "0"

// Numero do CNPJ da pessoa  juridica contratante do plano coletivo
If TRBSIB->BA3_TIPOUS <> "1" //Beneficiario PJ
	If !Empty(BQC->BQC_CNPJ)
		aRegMud[nRegMud,9] := BQC->BQC_CNPJ
	Else
		If SA1->(dbSeek(xFilial("SA1")+BQC->(BQC_CODCLI+BQC_LOJA)))
			aRegMud[nRegMud,9] := SA1->A1_CGC
		Else
			aRetCli := PLSRETNCB(TRBSIB->BA1_CODINT,TRBSIB->BA1_CODEMP,TRBSIB->BA1_MATRIC,TRBSIB->BA1_OPEORI)
			If aRetCli[1]
				If SA1->(dbSeek(xFilial("SA1")+TRBSIB->(BA3_CODCLI+BA3_LOJA)))
					aRegMud[nRegMud,9] := SA1->A1_CGC
				EndIf
			EndIf
		EndIf
	EndIf
Else
	aRegMud[nRegMud,9] := ""
EndIf

// Numero do CEI do contratante do plano coletivo
If aRetPla[3] $ "3,4" 
	If !Empty(BQC->BQC_CAEPF) .AND. Empty(BQC->BQC_CNPJ) .AND. BQC->(FieldPos('BQC_CAEPF')) > 0
		aRegMud[nRegMud,9]  := "" // Vou informar o CAEPF e nao o CNPJ
		aRegMud[nRegMud,16] := AllTrim(BQC->BQC_CAEPF)
	ElseIf !Empty(BQC->BQC_CEINSS) .AND. Empty(BQC->BQC_CNPJ)
		aRegMud[nRegMud,9]  := "" // Vou informar o CEI e nao o CNPJ
		aRegMud[nRegMud,10] := AllTrim(BQC->BQC_CEINSS)
	ElseIf Empty(BQC->BQC_CNPJ) .AND. !Empty(SA1->A1_CEINSS)
		aRegMud[nRegMud,9]  := "" // Vou informar o CEI e nao o CNPJ
		aRegMud[nRegMud,10] := AllTrim(SA1->A1_CEINSS)
	Else
		aRegMud[nRegMud,10] := ""
		aRegMud[nRegMud,16] := ""
	EndIf
Else
	aRegMud[nRegMud,9]  := "" // CNPJ
	aRegMud[nRegMud,10] := "" // CEI
	aRegMud[nRegMud,16] := "" // CAEPF
EndIf

// Relacao de dependencia
nPos := aScan(aGraPar,{|x| x[1] == TRBSIB->BA1_GRAUPA})
If nPos > 0
	aRegMud[nRegMud,11] := aGraPar[nPos,2]
Else
	aRegMud[nRegMud,11] := "10"
EndIf

// Codigo de identificacao do beneficiario titular na operadora para beneficiarios informados como dependentes
If TRBSIB->BA1_TIPUSU <> cCodTit
	aRegMud[nRegMud,12] := A782Tit(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),lDigito,lMatAnt)
Else
	aRegMud[nRegMud,12] := ""
EndIf

aRegMud[nRegMud,13] := .T.  
aRegMud[nRegMud,14] := TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)

If lCriaLog
	PlsLogFil(Transform(TRBSIB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),MATRIPLS) +"  "+ ;
	SubStr(AllTrim(TRBSIB->BA1_NOMUSR)+Space(30),1,30)+ " - Mudan็a contratual ",cArqLog)
EndIf

aRegMud[nRegMud,15] := SubStr(TRBSIB->BA1_DATADP,1,4) + "-" + SubStr(TRBSIB->BA1_DATADP,5,2) + "-" + SubStr(TRBSIB->BA1_DATADP,7,2)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA782AtuSx1บAutor  ณMicrosiga           บ Data ณ  27/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a sequencia do proximo arquivo a ser gerado       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A782AtuSx1()

// *** TRATAMENTO NA FUNCIONALIDADE A782ATUSX1() - SX1 (CONFORME CODIGO FONTE PLSA782 - CHANGESET TFS: 414272) - EXCLUSAO DO MANUSEIO DO DICIONARIO ATRAVES DO CODIGO FONTE;

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA782TamCmpบAutor  ณMicrosiga           บ Data ณ  27/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta o tamanho da string retornada para o tamanho que de-บฑฑ
ฑฑบ          ณ ve ser enviado no arquivo                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A782TamCmp(nTam,cVal,lZero)
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA782Hash  บAutor  ณMicrosiga           บ Data ณ  06/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para calculo do hash do arquivo SBX           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAPLS                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A782Hash(cHashFile,lCriaLog)
Local cRetHash    := "" // Hash calculado do arquivo SBX
Local cBuffer	  := "" // Buffer lido
Local cHashBuffer := "" // Buffer do hash calculado 
Local cFnHash     := "MD5File" // Definicao da fun็ใo MD5File
Local nBytesRead  := 0 // Quantidade de bytes lidos no arquivo
Local nTamArq	  := 0 // Tamanho do arquivo em bytes
Local nFileHash	  := 0 // Arquivo de hash
Local aPatch      := {} // Conteudo do diretorio

IncProc("Calculando hash do arquivo SBX a ser enviado")      

aPatch := Directory(cHashFile,"F")

If Len(aPatch) > 0
	nTamArq := aPatch[1,2]/1048576

	If lCriaLog
		PlsLogFil("Atributos: " + aPatch[1,5] + " - Tamanho: " + AllTrim(Str(aPatch[1,2])),cArqlog)
	EndIf

	If nTamArq > 0.9
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Utilizado a macro-execucao por solicitacao da tecnologia, para evitar    ณ  
		//ณ erro na funcao MD5File decorrente a utilizacao de binarios mais antigos  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cRetHash := &(cFnHash+"('"+cHashFile+"')")

		If lCriaLog
			PlsLogFil("MD5File: " + cRetHash,cArqlog)
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

		If lCriaLog
			PlsLogFil("MD5: " + cRetHash,cArqlog)
		EndIf
	EndIf
Else
	MsgInfo("O arquivo " + cHashFile + " nใo foi encontrado ou nใo estแ acessํvel." + CRLF + "Hash do arquivo nใo pode ser calculado!")
EndIf

Return cRetHash

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA782Tit   บAutor  ณMicrosiga           บ Data ณ  06/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a matricula antiga do titular da familia se existir บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAPLS                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A782Tit(cMatFam,lDigito,lMatAnt)
Local cMatTit := "" // Matricula do titular
Local aAreas  := {}
Local cGrauTit	:= GetNewPar("MV_PLTRTIT",'00') //Codigo do Grau de Parentesco do Titular.

aAreas := GetArea()

If lMatAnt // Vou enviar a matricula antiga do titular

	BA1->(dbSetOrder(2)) // BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
	If BA1->(dbSeek(xFilial("BA1")+cMatFam)) // Posiciono na familia

		While cMatFam == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)

			If BA1->BA1_TIPUSU == cCodTit // Verifico se e titular de acordo com o parametro MV_PLCDTIT
				If !Empty(BA1->BA1_MATANT)
					cMatTit := BA1->BA1_MATANT
				Else
					cMatTit := BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
				EndIf
			EndIf

			BA1->(dbSkip())

		EndDo

	EndIf

Else // Vou mandar a matricula atual do titular
	If lDigito
		cMatTit := IIF(FindFunction("StrTPLS"),cMatFam+cGrauTit+Modulo11(StrTPLS(cMatFam+cGrauTit)),cMatFam+cGrauTit+Modulo11(cMatFam+cGrauTit))
	Else
		cMatTit := cMatFam+cGrauTit
	EndIf
EndIf

RestArea(aAreas)

Return AllTrim(cMatTit)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLSIBCPT บAutor  ณMicrosiga           บ Data ณ  12/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica para o usuario a existencia de cobertura parcial   บฑฑ
ฑฑบ          ณtemporaria                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAPLS                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSIBCPT(dDatRef,cMatric)
Local cCPT    := "0" //Beneficiario nao possui CPT a cumprir
Local dDatCPT := Ctod("")

BF3->(dbSetOrder(1))
If BF3->(msSeek(xFilial("BF3")+cMatric))
	
	While BF3->(!Eof()) .And. BF3->(BF3_FILIAL+BF3_CODINT+BF3_CODEMP+BF3_MATRIC+BF3_TIPREG) = xFilial("BF3")+cMatric
		
		If BF3->BF3_UNAGR="1" //horas
			If (BF3->BF3_MESAGR / 24) > 1 // Se qtde de horas for mais de um dia
				dDatCPT := BF3->BF3_DATCPT+Int(BF3->BF3_MESAGR / 24)
			Else
				dDatCPT := BF3->BF3_DATCPT
			EndIf
		ElseIf  BF3->BF3_UNAGR="2"  //dias
			dDatCPT := BF3->BF3_DATCPT+BF3->BF3_MESAGR
		ElseIf  BF3->BF3_UNAGR="3"  //meses
			dDatCPT := (BF3->BF3_DATCPT+(BF3->BF3_MESAGR*30))
		ElseIf  BF3->BF3_UNAGR="4"  //anos
			dDatCPT := (BF3->BF3_DATCPT+(BF3->BF3_MESAGR*365))
		EndIf
		
		If dDatCPT != Ctod("") .And. DtoS(dDatCPT) >= dDatRef
			cCPT := "1" //Beneficiario possui CPT a cumprir
		Endif
		
		BF3->(DbSkip())
	EndDo
	
EndIf

Return cCPT

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ PLSSIBDIR  ณ Autor ณ Tulio Cesar       ณ Data ณ 22.10.2002 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ F3 para selecionar diretorio                               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function PLSSIBDIR(cDado,cCampo)
Local lRet := .F.
LOCAL cPathTmp 	:= cGetFile("*.*","Selecione o diret๓rio",0,,.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY)

If Empty(cPathTmp)
	Return()
Endif

mv_par09 := cPathTmp

lRet := ! empty(cDado) 

Return(lRet)

/*
Funcao criada para verificar se deve enviar ou nao a tag referente a determinado campo
*/
Static Function EnviaTag(aAltera,cCampo,lGruXml)

Local lRetorno := .T. // Todos
Local nFor		:= 0

Default lGruXml := .F.

IF MV_PAR16 <> 1	//	Envia TODOS os Campos se for ALTERAวรO
	lRetorno := Len(aAltera) == 0	//	Para registros 7=CRI ALT em sem nem um campo encontrado no historico eu mando todos
	For nFor := 1 TO Len(aAltera)
		If aAltera[nFor,1] $ cCampo
			lRetorno := .T.
			Exit
		EndIf
	Next nFor
ENDIF
If (!lGruXml .And.  lRetorno)
	lGruXml := .T.
EndIf

Return lRetorno