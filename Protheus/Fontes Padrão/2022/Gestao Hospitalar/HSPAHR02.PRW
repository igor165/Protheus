#INCLUDE "HSPAHR02.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ             	
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR02 บ Autor ณ Antonio Carlos     บ Data ณ09/05/2006   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELATORIO DOS AGENDAMENTOS COM RELACAO DOS PRONTUARIOS DE  บฑฑ
ฑฑบ          ณ ENDERECOS EXTERNOS                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR02()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis Locais                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3 := ""
Local Titulo := STR0003 //"Agenda prontuarios end. Externos"
Local Cabec1 := STR0004 //"Data  /  Hora Agendamento     Prontuแrio  Nome"
Local Cabec2 := STR0022 //"          Endereco                                           "
Local aOrd   := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis Privadas                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private lEnd        := .F.
Private lAbortPrint := .F.
Private tamanho     := "P"
Private nomeprog    := "HSPAHR02"
Private nTipo       := 18
Private aReturn     := { STR0005 , 1, STR0006 , 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private m_pag       := 01
Private wnrel       := "HSPAHR02"
Private cString     := ""
Private aRegistros  := {}
Private nLin        := 80

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ PARAMETROS                                                         ณ
//ณ MV_PAR01	Da Filial                                              ณ
//ณ MV_PAR02	Ate a Filial                                           ณ
//ณ MV_PAR03	Da data                                                ณ
//ณ MV_PAR04	Ate a data                                             ณ
//ณ MV_PAR05	Tipo :  1-Ambulatorial  2-PA 3-Hospitalar 4-Todos      ณ
//ณ MV_PAR06	Externo:  1-Externo  2-Nao Externo 3-Ambos             ณ
//| MV_PAR07    Impressora ?                                           |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

cPerg := "HSPR02"
Pergunte(cPerg,.T.)

DbSelectArea("GM8")
dbsetorder(1)

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cString)
If nLastKey == 27
	Return
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RptStatus({|| FS_RunReport(Cabec1,Cabec2,Titulo) },Titulo)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT   บ Autor ณ Antonio Carlos   บ Data ณ09/05/2006   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_RunReport(Cabec1,Cabec2,Titulo)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao das variแveis locais.                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local cGM8_FILAGE  := ""
Local cGM8_DATAGE  := ""
Local cGM8_CODCRM  := ""
Static cGSD_TIPEND := ""
Static cDescTiPo   := ""
Local nTotGer      := 0
Local nTotal       := 0
Local nTotAmb      := 0
Local nTotPA       := 0
Local nTotHos      := 0
Local nTotMed      := 0
Local n1vez        := 0
Local n2vez        := 0
Local cSQL         := ""

cSQL := "SELECT GM8.GM8_FILAGE, GM8.GM8_CODCRM, GM8.GM8_REGGER, GM8.GM8_DATAGE, GM8.GM8_HORAGE, GM8.GM8_NOMPAC,"
cSQL += " GSB.GSB_CODEND,  GSD.GSD_CODEND, GSD.GSD_ARQEXT, GSD.GSD_DESEND, GSD.GSD_TIPEND, SRA.RA_NOME"
cSQL += " FROM " + RetSQLName("GM8") + " GM8"
cSQL += " JOIN " + RetSQLName("GSB") + " GSB ON GSB.GSB_FILIAL = '" + xFilial("GSB") + "' AND GSB.D_E_L_E_T_ <> '*' AND GSB.GSB_REGGER = GM8.GM8_REGGER"
cSQL += " JOIN " + RetSQLName("GSD") + " GSD ON GSD.GSD_FILIAL = '" + xFilial("GSD") + "' AND GSD.D_E_L_E_T_ <> '*' AND GSD.GSD_CODEND = GSB.GSB_CODEND"

If MV_PAR06 = 1
	cSQL += " AND GSD.GSD_ARQEXT = '1'"
ElseIf MV_PAR06 = 2
	cSQL += " AND GSD.GSD_ARQEXT = '0'"
EndIf

If MV_PAR05 = 1
	cSQL += " AND GSD.GSD_TIPEND = '1'"
ElseIf MV_PAR05 = 2
	cSQL += " AND GSD.GSD_TIPEND = '2'"
ElseIf MV_PAR05 = 3
	cSQL += " AND GSD.GSD_TIPEND = '3'"
EndIf

cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO = GM8.GM8_CODCRM"

cSQL += " WHERE"
cSQL += "     GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.D_E_L_E_T_ <> '*'"
cSQL += " AND GM8.GM8_FILAGE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cSQL += " AND GM8.GM8_DATAGE BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "'"

cSQL += " AND GM8.GM8_STATUS = '1'"

cSQL += " ORDER BY GM8.GM8_CODCRM, GM8.GM8_FILAGE, GSD_TIPEND, GM8_DATAGE, GM8_HORAGE, GM8_NOMPAC"

cSQL := ChangeQuery(cSQL)

TCQUERY cSQL NEW ALIAS "QRY"

DbSelectArea("QRY")
DbGoTop()

If Eof()
	HS_MsgInf(STR0007, STR0008 , STR0009) //"Nenhum dado foi encontrado para a sele็ใo efetuada!"###"Aten็ใo"###"Verifique a sele็ใo"
	DbCloseArea()
	Return
EndIf

SetRegua(200)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega o vetor aRegistros com todos os dados a serem impressos.    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

While !EOF()
	
	IncRegua()
	
	If lAbortPrint
		@nLin,000 PSAY STR0010 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf
	
	If cGM8_FILAGE <> QRY->GM8_FILAGE .Or. cGM8_DATAGE <> DTOC(STOD(QRY->GM8_DATAGE))
		If nTotPA > 0
			@nLin,000 PSAY  Repl("-",80)
			nLin ++
			@nLin,000 PSAY STR0011 + cGM8_DATAGE + Transform(nTotPA, "@E 999,999") //"Total PA (Pronto Atendimento) do Dia: "
			nLin ++
			nTotPA     := 0
		EndIf
		
		If nTotAmb > 0
			@nLin,000 PSAY  Repl("-",80)
			nLin ++
			@nLin,000 PSAY STR0012  + cGM8_DATAGE + Transform(nTotAmb, "@E 999,999") //"Total Ambulatorial do Dia: "
			nLin ++
			nTotAmb := 0
		EndIf
		
		If nTotHos > 0
			@nLin,000 PSAY  Repl("-",80)
			nLin ++
			@nLin,000 PSAY STR0013 + cGM8_DATAGE + Transform(nTotHos, "@E 999,999") //"Total Hospitalar do Dia: "
			nLin ++
			nTotHos := 0
		EndIf
		
		If n2Vez > 0
			@nLin,000 PSAY  Repl("-",80)
			nLin ++
		EndIf
		
		n1vez++
		n2vez++
		
		cGM8_FILAGE := QRY->GM8_FILAGE
		cGM8_DATAGE := DTOC(STOD(QRY->GM8_DATAGE))
	EndIf
	
	If cGM8_CODCRM <> QRY->GM8_CODCRM
		If nTotMed > 0
			@nLin,000 PSAY "Total do Medico : " + Transform(nTotMed, "@E 999,999")
			nLin ++
			@nLin,000 PSAY  Repl("-",80)
			nLin ++
			nTotMed := 0
			nLin := nMaxLin * 2 // Saltar pagina....
		EndIf
		
		cGM8_CODCRM := QRY->GM8_CODCRM
	EndIf
	
	If nLin > nMaxLin // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		nLin := 09
		nLin := ImpCabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo,nLin)
		HS_VerTipEnd() //Imprime tipo de endereco qdo salta pagina
		nLin++
	EndIf
	
	If MV_PAR05 == 4 // Condicao 4=Todos (Ambulatorial/PA/Hospitalar
		If cGSD_TIPEND <> QRY->GSD_TIPEND
			If nTotal > 0
				nLin ++
				@nLin,000 PSAY STR0014+ cDescTipo + Transform(nTotal, "@E 999,999") //"Total Geral : "
				nLin ++
				@nLin,000 PSAY  Repl("-",80)
				nLin ++
				nTotal := 0
				
				nLin := 09
				nLin := ImpCabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo,nLin)
				HS_VerTipEnd()
			EndIf
			
			cGSD_TIPEND := QRY->GSD_TIPEND
			
		EndIf
	EndIf
	
	If n1vez > 0
		nLin++
		@nLin,000 PSAY DTOC(STOD(QRY->GM8_DATAGE))   // Data do Agendamento
		cGSD_TIPEND := QRY->GSD_TIPEND
		n1vez := 0
	EndIf
	
	@nLin,015 PSAY QRY->GM8_HORAGE  									     // Hora do Agendamento
	@nLin,030 PSAY QRY->GM8_REGGER               // Prontuario do Paciente
	@nLin,040 PSAY SUBSTR(QRY->GM8_NOMPAC,1,38)  // Nome do Paciente
	nLin++
	@nLin,010 PSAY AllTrim(QRY->GSD_CODEND) + " - " + QRY->GSD_DESEND               // Endereco
	
	nLin++
	
	If QRY->GSD_TIPEND == '1'       //Tipo Ambulatorial
		nTotAmb++
	ElseIf QRY->GSD_TIPEND == '2'  //Tipo PA(Pronto Atendimento)
		nTotPA++
	ElseIf QRY->GSD_TIPEND == '3'  //Tipo Hospitalar
		nTotHos++
	EndIf
	
	nTotGer++
	nTotal++
	nTotMed++
	
	DbSelectArea("QRY")
	Dbskip()
	If EOF()
		If nTotPA > 0
			nLin ++
			@nLin,000 PSAY  Repl("-",80)
			nLin ++
			@nLin,000 PSAY STR0011 + cGM8_DATAGE + Transform(nTotPA, "@E 999,999") //"Total PA (Pronto Atendimento) do Dia: "
		EndIf
		
		If nTotAmb > 0
			nLin ++
			@nLin,000 PSAY  Repl("-",80)
			nLin ++
			@nLin,000 PSAY STR0012 + cGM8_DATAGE + Transform(nTotAmb, "@E 999,999") //"Total Ambulatorial do Dia: "
		EndIf
		
		If nTotHos > 0
			nLin ++
			@nLin,000 PSAY  Repl("-",80)
			nLin ++
			@nLin,000 PSAY STR0013 + cGM8_DATAGE + Transform(nTotHos, "@E 999,999") //"Total Hospitalar do Dia: "
		EndIf
		
		If nTotMed > 0
			nLin ++
			@nLin,000 PSAY  Repl("-",80)
			nLin ++
			@nLin,000 PSAY "Total do Medico : " + Transform(nTotMed, "@E 999,999")
		EndIf
		
		If nTotal > 0
			nLin ++
			@nLin,000 PSAY  Repl("-",80)
			nLin ++
			@nLin,000 PSAY STR0014+ cDescTipo + Transform(nTotal, "@E 999,999") //"Total Geral : "
		EndIf
		
		nLin ++
		@nLin,000 PSAY  Repl("-",80)
		
	EndIf
EndDo

If nTotGer > 0
	If nLin > nMaxLin // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		nLin := 09
		nLin := ImpCabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo,nLin)
	EndIf
	
	If MV_PAR05 == 4
		If nTotGer > 0
			nLin += 2
			@nLin,000 PSAY STR0015 + Transform(nTotGer, "@E 999,999") //"Total Geral (Amb+PA+Hosp) : "
			nLin ++
			@nLin,000 PSAY  Repl("-",80)
		EndIf
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SET DEVICE TO SCREEN
If aReturn[5] == 1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
EndIf

MS_FLUSH()
DbCloseArea()
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpCabec  บAutor  ณLuiz Pereira S. Jr. บ Data ณ  30/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao do cabe็alho do relatorio.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImpCabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, nLin)
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

@nLin,000 PSAY " Medico : " + AllTrim(QRY->GM8_CODCRM) + " - " + QRY->RA_NOME //"Total PA (Pronto Atendimento) do Dia: "
nLin += 2

Return(nLin)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณHS_VERTIPENDบ Autor ณ Antonio Carlos   บ Data ณ11/05/2006   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Adiciona conteudo na variavel cDescTip de acordo com o Tipoบฑฑ
ฑฑบ          ณ Ambulatorial/PA/Hospitalar (Externo/Nao Externo)           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function HS_VerTipEnd()

If QRY->GSD_TIPEND == '1'  //Tipo Ambulatorial
	cDescTiPo := STR0016 //"Ambulatorial"
ElseIf QRY->GSD_TIPEND == '2'  //Tipo PA(Pronto Atendimento)
	cDescTiPo := STR0017 //"PA(Pronto Atendimento)"
ElseIf QRY->GSD_TIPEND == '3'  //Tipo Hospitalar
	cDescTiPo := STR0018 //"Hospitalar"
EndIf

If MV_PAR06 == 1
	cDescTiPo := cDescTiPo+STR0019 //" - Tipo Externo "
ElseIf MV_PAR06 == 2
	cDescTiPo := cDescTiPo+STR0020 //" - Tipo Nใo Externo "
Else
	cDescTiPo := cDescTiPo+STR0021 //" - Tipo Ambos "
EndIf

@nLin,000 PSAY cDescTiPo
nLin++
@nLin,000 PSAY  Repl("-",80)

Return