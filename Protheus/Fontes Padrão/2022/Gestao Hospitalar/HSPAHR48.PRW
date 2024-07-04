#INCLUDE "HSPAHR48.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR48 บ Autor ณ GILSON DA SILVA    บ Data ณJaneiro/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELATORIO DA AGENDA AMBULATORIAL                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR48()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis Locais                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relat๓rio "
Local cDesc2 := STR0002 //"de acordo com os parโmetros informados pelo usuแrio."
Local cDesc3 := ""
Local Titulo := STR0003 //"Agenda Ambulatorial."
Local Cabec1 := ""
Local Cabec2 := ""
Local aOrd   := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis Privadas                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 132
Private tamanho     := "M"
Private nomeprog    := "HSPAHR48"
Private nTipo       := 15
Private aReturn     := { STR0004, 1, STR0005, 1, 2, 1, "", 1} //"Zebrado"###"Administra็ใo"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private m_pag       := 01
Private wnrel       := "HSPAHR48"
Private cString     := ""
Private aRegistros  := {}
Private nLin        := 80
Private cCodImp     := ""
Private nMaxLin     := 0 // quantidade maxima de linhas p/ impressao

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ PARAMETROS                                                         ณ
//ณ MV_PAR01	Da Filial                                                 ณ
//ณ MV_PAR02	Ate a Filial                                              ณ
//ณ MV_PAR03	Do Setor                                                  ณ
//ณ MV_PAR04	Ate Setor                                                 ณ
//ณ MV_PAR05	Da data                                                   ณ
//ณ MV_PAR06	Ate a data                                                ณ
//ณ MV_PAR07	Do Profissional                                           ณ
//ณ MV_PAR08	Ate o Profissional                                        ณ
//ณ MV_PAR09	Da Especialidade                                          ณ
//ณ MV_PAR10	Ate a Especialidade                                       ณ
//ณ MV_PAR11	Emite Status Livre?  1-Nao 2-Sim                          ณ
//| MV_PAR12 Impressora                                                |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cPerg := "HSPR48"

If FunName() <> "HSPAHM29"
	Pergunte(cPerg, .T.)
Else
	MV_PAR01 := "01"
	MV_PAR02 := "01"
	MV_PAR03 := M->GM8_CODLOC
	MV_PAR04 := M->GM8_CODLOC
	MV_PAR05 := M->GM8_DATAGE
	MV_PAR06 := M->GM8_DATAGE
	MV_PAR07 := M->GM8_CODCRM
	MV_PAR08 := M->GM8_CODCRM
	MV_PAR09 := ""
	MV_PAR10 := "ZZ"
	MV_PAR11 := 1
EndIf       

nMaxLin := HS_MaxLin(cCodImp)
nLin    := nMaxLin * 2

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho,, .F.)

If nLastKey == 27
	Return()
EndIf

SetDefault(aReturn, cString)
If nLastKey == 27
	Return()
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RptStatus({|| RunReport(Cabec1, Cabec2, Titulo)}, Titulo)

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Gilson da Silva    บ Data ณJaneiro/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1, Cabec2, Titulo)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao das variแveis locais.                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cGM8_FILAGE := ""
Local cGM8_CODDIS := ""
Local cGM8_DATAGE := ""
Local cGM8_CODCRM := ""
Local cGM8_CODAGE := ""
Local nCont       := 0
Local nLinTotal   := 0
Local nTotal      := 0
Local l1Vez       := .F.
Local lImpLin     := .T. //Variavel utilizada para evitar que imprima duas linhas pontilhadas ao efetuar a quebra de pagina.
Local cSQL        := ""
Local cLinha      := ""

cSQL := "SELECT GM8.GM8_FILAGE, GM8.GM8_CODDIS, GM8.GM8_CODCRM, GM8.GM8_REGGER, GM8.GM8_CODPLA, GM8.GM8_DATAGE, GM8.GM8_TIPAGE, "
cSQL += " GM8.GM8_TELPAC, GM8.GM8_HORAGE, GM8.GM8_CODPRO, GM8.GM8_CODAGE, GM8.GM8_NOMPAC, GM8.GM8_DATCAD, GM8.GM8_HORCAD, GM8.GM8_CODUSU, "
cSQL += " GCM.GCM_DESPLA, GA7.GA7_DESC, GCS.GCS_NOMLOC, GM6.GM6_DESDIS, GBJ.GBJ_ESPEC1, GBJ.GBJ_ESPEC2, "
cSQL += " GBJ.GBJ_ESPEC3, SRA.RA_NOME"
cSQL += " FROM " + RetSQLName("GM8") + " GM8"
cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GM8.GM8_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
cSQL += " JOIN " + RetSQLName("GM6") + " GM6 ON GM6.GM6_CODDIS = GM8.GM8_CODDIS AND GM6.GM6_FILIAL = '" + xFilial("GM6") + "' AND GM6.D_E_L_E_T_ <> '*' "
cSQL += " JOIN " + RetSQLName("GBJ") + " GBJ ON GBJ.GBJ_CRM    = GM8.GM8_CODCRM AND GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*' "
cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GM8.GM8_CODCRM AND SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
cSQL += " LEFT JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GM8.GM8_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*'"
cSQL += " LEFT JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GM8.GM8_CODPRO AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODESP BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
cSQL += " WHERE"
cSQL += "     GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.D_E_L_E_T_ <> '*' "
cSQL += " AND GM8.GM8_FILAGE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
cSQL += " AND GM8.GM8_CODLOC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
cSQL += " AND GM8.GM8_DATAGE BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "' "
cSQL += " AND GM8.GM8_CODCRM BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "

If MV_PAR11 == 1
	cSQL += " AND GM8.GM8_STATUS IN('1','3','4','5','6') "
Else
	cSQL += " AND GM8.GM8_STATUS NOT IN ('2')"
EndIf
cSQL += " ORDER BY GM8_FILAGE, GM8_CODDIS, GM8_CODCRM, GM8_DATAGE, GM8_HORAGE, GM8_NOMPAC"
cSQL :=  ChangeQuery(cSQL)

TCQUERY cSQL NEW ALIAS "QRY"
DbSelectArea("QRY")
DbGoTop()

Titulo := HS_MontCabe(STR0011, IIF(Empty(MV_PAR05), " ", CTOD(HS_DTOC(MV_PAR05, 1))), IIF(Empty(MV_PAR06), " ", CTOD(HS_DTOC(MV_PAR06, 1)))) //"Agenda Marcada"

If Eof()
	HS_MsgInf(STR0017, STR0018, STR0019) //"Nenhum dado foi encontrado para a sele็ใo efetuada!"###"Aten็ใo"###"Verifique a sele็ใo"
EndIf

SetRegua(200)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega o vetor aRegistros com todos os dados a serem impressos.    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While !EOF()
	
	IncRegua()
	
	If lAbortPrint
		@nLin, 000 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf
	
	lImpLin := .T.
	If	cGM8_FILAGE <> QRY->GM8_FILAGE .Or. ;
		cGM8_CODDIS <> QRY->GM8_CODDIS .Or. ;
		cGM8_CODCRM <> QRY->GM8_CODCRM .Or. ;
		cGM8_DATAGE <> DTOC(STOD(QRY->GM8_DATAGE))
		If nTotal > 0
			@nLin, 000 PSAY STR0012 + Transform(nToTal, "@E 999,999")//"Total     : "
			nTotal := 0
		EndIf
		ImpCabec(Cabec1, Cabec2, Titulo)
		cGM8_FILAGE := QRY->GM8_FILAGE
		cGM8_CODDIS := QRY->GM8_CODDIS
		cGM8_CODCRM := QRY->GM8_CODCRM
		cGM8_DATAGE := DTOC(STOD(QRY->GM8_DATAGE))
	EndIf
	
	If nLin > nMaxLin // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		ImpCabec(Cabec1, Cabec2, Titulo)
	EndIf
	
	@nLin, 000 PSAY QRY->GM8_HORAGE //Horario do agendamento
	If QRY->GM8_TIPAGE == "1"
		@nLin, 006 PSAY "E"  //Indica que eh um Encaixe.
	EndIf
	@nLin, 010 PSAY QRY->GM8_NOMPAC //Nome do Paciente
	@nLin, 064 PSAY QRY->GM8_TELPAC //Telefone do Paciente
	
	If !Empty(QRY->GM8_REGGER)
		@nLin, 099 PSAY PADL(ALLTRIM(QRY->GM8_REGGER), 6) // Prontuario do Paciente
		l1Vez := .F.
	Else
		l1Vez := .T.
	EndIf
	
 	@nLin, 117 PSAY IIF(Empty(QRY->GM8_DATCAD), " ", HS_DTOC(STOD(QRY->GM8_DATCAD), 1)) + " " + QRY->GM8_HORCAD  	
	nLin++                                                                                                        
	
	If cGM8_CODAGE == QRY->GM8_CODAGE
		l1Vez := .T.
	EndIf
	
	If !Empty(QRY->GM8_CODPRO) .Or. !Empty(QRY->GM8_CODPLA) .Or. l1Vez .Or. !Empty(QRY->GM8_CODUSU)
		If !Empty(QRY->GM8_CODPRO)
			@nLin, 010 PSAY QRY->GA7_DESC  // Descricao do procedimento
		EndIf
		If !Empty(QRY->GM8_CODPLA)
			@nLin, 064 PSAY QRY->GCM_DESPLA // Descricao do Plano
		EndIf
		If l1Vez
			@nLin, 101 PSAY STR0016 //"Sim"
		EndIf
		If !Empty(QRY->GM8_CODUSU)
			@nLin, 117 PSAY QRY->GM8_CODUSU  
	 	EndIf 
		nLin++
	EndIf  

	cObserv := HS_IniPadr("GM8", 1, QRY->GM8_CODAGE, "GM8_OBSERV",, .F.) // GM8/1
	nLinTotal := MlCount(cObserv)  //Imprime o campo MEMO GM8_OBSERV.
	For nCont := 1 To nLinTotal
		cLinha := AllTrim(MemoLine(cObserv, 65, nCont))
		If !Empty(cLinha)
			@ nLin, 010 PSAY cLinha
			nLin++
			If nLin >= nMaxLin
				ImpCabec(Cabec1, Cabec2, Titulo)
				lImpLin := .F.
			EndIf
		EndIf
	Next nCont
	If lImpLin
		@nLin, 000 PSAY  Repl("-", 132)
		nLin := nLin + 2
	EndIf
	
	nTotal++
	
	DbSelectArea("QRY")
	Dbskip()
	If EOF()
		@nLin, 000 PSAY STR0014 + Transform(nToTal, "@E 999,999")//###"Total     : "
	EndIf
EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SET DEVICE TO SCREEN
If aReturn[5] == 1
	DbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
EndIf

MS_FLUSH()
DbCloseArea()
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณIMPCABEC  บ Autor ณ Gilson da Silva    บ Data ณJaneiro/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Imprime o Cabecalho do relatorio.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function ImpCabec(Cabec1, Cabec2, Titulo)

			/*         1         2         3         4         5         6         7         8         9         10        11        12        13
				0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.12 */

Cabec1 := STR0008 + AllTrim(QRY->GM8_CODCRM) + " - " + QRY->RA_NOME + Space(10) + ; // "Medico: "
STR0010 + HS_DTOC(STOD(QRY->GM8_DATAGE), 1) + " - " + HS_SEMANA(DOW(STOD(QRY->GM8_DATAGE))) //"     Data: "

Cabec2 := STR0009 + QRY->GCS_NOMLOC + STR0015 + QRY->GM6_DESDIS //"Local : "###"     Disponibilidade: "
Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)

nLin := 09
@nLin, 000 PSAY  STR0006  //"Hora      Nome                                                  Telefone                       Prontuแrio            Marcado em"
nLin++
@nLin, 000 PSAY  STR0013  //"          Procedimento                                          Plano                               1aVez            Por"
nLin++
@nLin, 000 PSAY  STR0014  //"          Observa็ใo"
nLin++
@nLin, 000 PSAY  Repl("-", 132)
nLin ++

Return()