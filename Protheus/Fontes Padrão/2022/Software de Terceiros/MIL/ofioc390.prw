// ษออออออออหออออออออป
// บ Versao บ 31     บ
// ศออออออออสออออออออผ

#Include "Protheus.ch"
#Include "OFIOC390.ch"
#Include "OFIXDEF.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  04/10/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007157_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ OFIOC390 ณ Autor ณ  Andre Luis / Rubens  ณ Data ณ 01/06/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Consulta Gerencial da Oficina                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOC390(cPAREmp, aPAREmp, cPARFil)
//variaveis controle de janela
Local aObjects := {}, aPosObj := {}, aInfo := {}
Local aSizeAut := MsAdvSize(.f.) // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor  := 0

Local aFWArrFilAtu := FWArrFilAtu()

Local lDClik    := .f.
Local lUsuEmpr  := .t. // Selecionar Empresas
Private lMarcar := .f.
Private aVetEmp := {}
Private aEmpr   := {} // Empresas Consolidadas
Private cEmpr   := "" // Nome da Empresa

Private aFilDias   := { STR0002 + " (" + FG_CMONTH(dDataBase) + "/" + strzero(year(dDataBase), 4) + ")",; // Do Mes
					  STR0003,                                                                        ; // Ultimos 30 dias
					  STR0004,                                                                        ; // Ultimos 90 dias
					  STR0005,                                                                        ; // Ultimos 180 dias
					  STR0006,                                                                        ; // Ultimos 365 dias
					  STR0007,                                                                        ; // Ultimos 2 anos
					  STR0008,                                                                        ; // Ultimos 3 anos
					  STR0009,                                                                        ; // Total
					  STR0083}                                                                          // Periodo
Private cFilDias   := STR0002 + " (" + FG_CMONTH(dDataBase) + "/" + strzero(year(dDataBase), 4) + ")" // Do Mes
Private dDtFin     := dDataBase
Private dDtIni     := (dDtFin - day(dDtFin)) + 1
Private dDtMesIni  := dDtIni
Private dDtMesFin  := dDtFin
Private cDtMesIni  := DtoS(dDtIni)    // Usada para comparar se esta dentro do Mes
Private cDtMesFin  := DtoS(dDtFin)    // Usada para comparar se esta dentro do Mes
Private cAuxDtBase := DtoS(dDataBase) // Usada para comparar se ้ do DIA

Private cTitulo  := ""
Private cFiltro  := ""
Private aSrvOfi  := {} // Ordens de Servico
Private aHrsOfi  := {} // Tempos Oficina
Private aOSsOfi  := {} // OS's Oficina
Private aAnalit  := {} // Analitico
Private aAnalOS  := {} // Analitico por Ordem de Servico
Private oFilHlp  := DMS_FilialHelper():New()
Private oArHlp   := DMS_ArrayHelper():New()
Private aFatDia  := {} // Faturamento Dia
Private aFatPer  := {} // Faturamento Periodo
Private aVetDia  := {}
Private oDmsUtil := DMS_Util():New()

Default cPAREmp := ""
Default aPAREmp := aEmpr
Default cPARFil := cFilDias

cFilDias := cPARFil

aEmpr := aPAREmp
If !Empty(cPAREmp)
	cEmpr := " - " + STR0010 + " " // Consolidado:
	aEmpr := OFIXFUNA01_SelecaoFiliais({cFilAnt}) // Levantamento das Filiais
	If len(aEmpr) == 0
		MsgAlert(STR0012, STR0011) // Nao existem dados para esta Consulta ! / Atencao

		Return
	EndIf
Else
	aAdd(aEmpr, cFilAnt)
EndIf

If len(aEmpr) == 1 .and. (aEmpr[1] == cFilAnt)
	cEmpr := " - " + Alltrim(FWFilialName()) + " ( " + cFilAnt + " )"
EndIf

// Configura os tamanhos dos objetos
aObjects := {}
AAdd(aObjects, { 05, 24, .T., .F. }) //Cabecalho
AAdd(aObjects, { 70, 10, .T., .T. }) //list box superior
AAdd(aObjects, { 30, 10, .T., .T. }) //list box inferior
AAdd(aObjects, { 10, 14, .T., .F. }) //rodape
aInfo   := { aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 2, 2 }
aPosObj := MsObjSize (aInfo, aObjects, .F.)

Processa({|| FS_ATUDT(), FS_LEVANT(0) })

DEFINE MSDIALOG oSrvOfi FROM aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] TITLE (STR0001 + cEmpr) OF oMainWnd PIXEL // "Consulta Oficina"
oSrvOfi:lEscClose := .F.

// Parametros da Consulta
@ aPosObj[1,1], aPosObj[1,2] TO aPosObj[1,3], aPosObj[1,2] + 320 LABEL (" " + STR0027 + " ") OF oSrvOfi PIXEL // "Levantamento"
@ aPosObj[1,1] + 009, aPosObj[1,2] + 004 MSCOMBOBOX oFilDias VAR cFilDias ITEMS aFilDias VALID Processa({|| FS_ATUDT() }) SIZE 110,10 OF oSrvOfi PIXEL COLOR CLR_BLUE
@ aPosObj[1,1] + 011, aPosObj[1,2] + 120 SAY STR0084 SIZE 100,08 OF oSrvOfi PIXEL COLOR CLR_BLUE // "De"
@ aPosObj[1,1] + 009, aPosObj[1,2] + 130 MSGET oPeriodo VAR dDtIni Picture "@D" SIZE 60,09 OF oSrvOfi PIXEL COLOR CLR_BLUE WHEN cFilDias == STR0083 HASBUTTON // Periodo
@ aPosObj[1,1] + 011, aPosObj[1,2] + 195 SAY STR0085 SIZE 100,08 OF oSrvOfi PIXEL COLOR CLR_BLUE // "Ate"
@ aPosObj[1,1] + 009, aPosObj[1,2] + 210 MSGET oPeriodo VAR dDtFin Picture "@D" VALID ((dDtFin >= dDtIni)) SIZE 60,09 OF oSrvOfi PIXEL COLOR CLR_BLUE WHEN cFilDias == STR0083 HASBUTTON // Periodo

@ aPosObj[1,1] + 009, aPosObj[1,2] + 270 BUTTON oEmpr PROMPT STR0103 OF oSrvOfi SIZE 45,10 PIXEL ACTION (Processa({|| FS_LEVANT(1) })) // Filtrar

@ aPosObj[1,1] + 009, aPosObj[1,4] - 55 BUTTON oEmpr PROMPT UPPER(STR0028) OF oSrvOfi SIZE 45,10 PIXEL ACTION (lDClik := .t., oSrvOfi:End()) WHEN lUsuEmpr // "Filiais"

// Listbox OFICINA com valores (R$) de OS's
@ aPosObj[2,1], aPosObj[2,2] TO aPosObj[2,3], aPosObj[2,4] LABEL (" " + STR0014 + " ") OF oSrvOfi PIXEL // "Oficina"
@ aPosObj[2,1] + 007, aPosObj[2,2] + 002 LISTBOX oLbSrvOfi FIELDS HEADER       ;
	STR0017,                                                                   ; // "Ordens de Servico"
	STR0018,                                                                   ; // "Em Andamento"
	"%",                                                                       ;
	STR0019,                                                                   ; // "Faturamento Pendente"
	"%",                                                                       ;
	STR0020 + " (" + Transform(dDataBase, "@D") + ")",                         ; // "Faturadas Dia"
	"%",                                                                       ;
	STR0096 + " (" + FG_CMONTH(dDataBase) + ")",                               ; // "Faturadas Mes"
	"%",                                                                       ;
	STR0087,                                                                   ; // "Faturadas Periodo"
	"%",                                                                       ;
	COLSIZES 55, 60, 25, 65, 25, 71, 25, 71, 25, 71, 25                        ;
	SIZE aPosObj[2,4] - 007, aPosObj[2,3] - aPosObj[1,3] - 011 OF oSrvOfi PIXEL;
	ON CHANGE FS_TXTBOTAO(oLbSrvOfi:nAt)                                       ;
	ON DBLCLICK IIf(len(aSrvOfi) > 1, Processa({|| FS_ANALIT(oLbSrvOfi:nAt, oLbSrvOfi:nColPos)}), .t.)

oLbSrvOfi:SetArray(aSrvOfi)
oLbSrvOfi:bLine := { || { aSrvOfi[oLbSrvOfi:nAt, 1],                           ;
	FG_AlinVlrs(Transform(aSrvOfi[oLbSrvOfi:nAt, 2], "@E 999,999,999,999.99")),;
	Transform((aSrvOfi[oLbSrvOfi:nAt, 2] / aSrvOfi[1, 2]) * 100, "@E 999.9%"), ;
	FG_AlinVlrs(Transform(aSrvOfi[oLbSrvOfi:nAt, 3], "@E 999,999,999,999.99")),;
	Transform((aSrvOfi[oLbSrvOfi:nAt, 3] / aSrvOfi[1, 3]) * 100, "@E 999.9%"), ;
	FG_AlinVlrs(Transform(aSrvOfi[oLbSrvOfi:nAt, 4], "@E 999,999,999,999.99")),;
	Transform((aSrvOfi[oLbSrvOfi:nAt, 4] / aSrvOfi[1, 4]) * 100, "@E 999.9%"), ;
	FG_AlinVlrs(Transform(aSrvOfi[oLbSrvOfi:nAt, 5], "@E 999,999,999,999.99")),;
	Transform((aSrvOfi[oLbSrvOfi:nAt, 5] / aSrvOfi[1, 5]) * 100, "@E 999.9%"), ;
	FG_AlinVlrs(Transform(aSrvOfi[oLbSrvOfi:nAt, 6], "@E 999,999,999,999.99")),;
	Transform((aSrvOfi[oLbSrvOfi:nAt, 6] / aSrvOfi[1, 6]) * 100, "@E 999.9%") }}

// Listbox com Totais de HORAS da Oficina
@ aPosObj[3,1] + 001, aPosObj[3,2] TO aPosObj[3,3], aPosObj[3,4] - ((aPosObj[3,4] / 2) - 004) LABEL (" " + STR0015 + " ") OF oSrvOfi PIXEL // "Produtivos"
@ aPosObj[3,1] + 009, aPosObj[3,2] + 002 LISTBOX oLbHrsOfi FIELDS HEADER;
	STR0022,                                                            ; // "Producao"
	STR0023 + " (" + DTOC(dDataBase) + ")",                             ; // "No Dia"
	STR0024,                                                            ; // 'No M๊s'
	STR0095                                                             ; // "No Perํodo"
	COLSIZES 65, 65, 65, 65                                             ;
	SIZE aPosObj[3,4] - ((aPosObj[3,4] / 2) + 002), aPosObj[3,3] - aPosObj[2,3] - 13 OF oSrvOfi PIXEL // WHEN .f.

oLbHrsOfi:SetArray(aHrsOfi)
oLbHrsOfi:bLine := { || { aHrsOfi[oLbHrsOfi:nAt, 1],                                                                            ;
	IIf(oLbHrsOfi:nAt > 5, OFIOC39002_FmtPercentual(aHrsOfi[oLbHrsOfi:nAt, 2]), OFIOC39001_FmtValor(aHrsOfi[oLbHrsOfi:nAt, 2])),; // Dia
	IIf(oLbHrsOfi:nAt > 5, OFIOC39002_FmtPercentual(aHrsOfi[oLbHrsOfi:nAt, 3]), OFIOC39001_FmtValor(aHrsOfi[oLbHrsOfi:nAt, 3])),; // Perํodo
	IIf(oLbHrsOfi:nAt > 5, OFIOC39002_FmtPercentual(aHrsOfi[oLbHrsOfi:nAt, 4]), OFIOC39001_FmtValor(aHrsOfi[oLbHrsOfi:nAt, 4]))}} // M๊s

// Listbox com Informacoes de OS's Abertas
@ aPosObj[3,1] + 001, aPosObj[3,4] - ((aPosObj[3,4] / 2) - 008) TO aPosObj[3,3], aPosObj[3,4] LABEL (" " + STR0016 + " ") OF oSrvOfi PIXEL // "Ordem de Servico: Abertas"
@ aPosObj[3,1] + 009, aPosObj[3,4] - ((aPosObj[3,4] / 2) - 010) LISTBOX oLbOSsOfi FIELDS HEADER      ;
	STR0025,                                                                                         ; // "Status Atual"
	STR0023 + " (" + Transform(dDataBase, "@D") + ")",                                               ; // "No Dia"
	STR0024 + " (" + FG_CMONTH(dDataBase) + ")",                                                     ; // "No Mes"
	STR0095                                                                                          ; // "No Perํodo"
	COLSIZES 53, 53, 53, 53                                                                          ;
	SIZE aPosObj[3,4] - ((aPosObj[3,4] / 2) + 012), aPosObj[3,3] - aPosObj[2,3] - 13 OF oSrvOfi PIXEL;
	ON DBLCLICK IIf(len(aOSsOfi) > 1, Processa({|| FS_ANALOS(oLbOSsOfi:nAt, oLbOSsOfi:nColPos)}), .t.)

oLbOSsOfi:SetArray(aOSsOfi)
oLbOSsOfi:bLine := { || { aOSsOfi[oLbOSsOfi:nAt, 1],                     ;
	FG_AlinVlrs(Transform(aOSsOfi[oLbOSsOfi:nAt, 2], "@E 9,999,999,999")),;
	FG_AlinVlrs(Transform(aOSsOfi[oLbOSsOfi:nAt, 3], "@E 9,999,999,999")),;
	FG_AlinVlrs(Transform(aOSsOfi[oLbOSsOfi:nAt, 4], "@E 9,999,999,999")) }}

nTam := (aPosObj[3,4] / 4)

// Botao "Faturamento Dia / Periodo"
@ aPosObj[4,1] + 001, aPosObj[4,2] + 002 + (nTam * 0) + ((((nTam * 1) - (nTam * 0)) - 80) / 2) BUTTON oFDiaMes PROMPT STR0065 OF oSrvOfi; // "Faturamento Dia / Periodo"
	SIZE 80,10 PIXEL ACTION FS_FDIAMES() WHEN len(aSrvOfi) > 1

// Botao "Grafico OS"
@ aPosObj[4,1] + 001, aPosObj[4,2] + 002 + (nTam * 1) + ((((nTam * 2) - (nTam * 1)) - 80) / 2) BUTTON oGrafFat PROMPT (STR0066 + " ( " + STR0031 + " )") OF oSrvOfi; // "Grafico OS" / Total Geral
	SIZE 80,10 PIXEL ACTION Processa({|| FS_GRAFFAT(oLbSrvOfi:nAt)}) WHEN len(aSrvOfi) > 1

// Botao "Consultores"
@ aPosObj[4,1] + 001, aPosObj[4,2] + 002 + (nTam * 2) + ((((nTam * 3) - (nTam * 2)) - 80) / 2) BUTTON oConsult PROMPT STR0064 OF oSrvOfi; // "Consultores"
	SIZE 80,10 PIXEL ACTION Processa({|| FS_CONSULT()}) WHEN len(aSrvOfi) > 1

// Botal "< SAIR >"
@ aPosObj[4,1] + 001, aPosObj[4,2] + 002 + (nTam * 3) + ((((nTam * 4) - (nTam * 3)) - 80) / 2) BUTTON oSair PROMPT STR0029 OF oSrvOfi; // "< SAIR >"
	SIZE 80,10 PIXEL ACTION oSrvOfi:End()

oLbSrvOfi:SetFocus()

ACTIVATE MSDIALOG oSrvOfi

If lDClik
	OFIOC390(cEmpr, aEmpr, cFilDias)
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFS_TXTBOTAO บAutor  ณMicrosiga         บ Data ณ  01/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Muda Texto do Botao "Grafico OS"                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TXTBOTAO(nTip)
oGrafFat:cCaption := STR0066 + " ( " + substr(Alltrim(aSrvOfi[nTip, 1]), IIf(left(Alltrim(aSrvOfi[nTip, 1]), 1) <> "-", 1, 3)) + " )" // "Grafico OS"

oGrafFat:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FS_LEVANT  บAutor  ณMicrosiga         บ Data ณ  01/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Levantamento                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_LEVANT(nx)
Local cQuery    := ""
Local cAliasVO3 := "SQLVO3" // PECAS
Local cAliasVO4 := "SQLVO4" // SERVICOS
Local cAliasVAI := "SQLVAI" // PRODUTIVOS
Local cAliasAus := "SQLVO4" // AUSENCIAS
Local cAliasVO1 := "SQLVO1" // OS's
Local cAliasVOO := "SQLVOO" // Valores Servicos Fechados

Local nLin     := 0
Local nCol     := 0
Local niP      := 0
Local niS      := 0
Local nValor   := 0
Local ni       := 1
Local nRCount  := 0
Local nTpoDis  := 0

Local nTpoAusD := 0
Local nTpoAusM := 0
Local nTopAusP := 0

Local nTpoTraD := 0
Local nTpoTraM := 0
Local nTpoTraP := 0

Local nTpoVenD := 0
Local nTpoVenM := 0
Local nTpoVenP := 0

Local ix1        := 0
Local aVerPad    := {}
Local cFilSALVA  := cFilAnt
Local nPosAnalit := 0
Local nPosApon   := 0
Local lAtrasada

Local lVO3VALLIQ := VO3->(FieldPos("VO3_VALLIQ")) <> 0

// Inicializa็ใo das variแveis usadas nas gridbox's da tela
OFC3900016_InicializacaoVariaveisGridbox(nx)

If nx # 0
	ProcRegua((8 * len(aEmpr)))

	For ni := 1 to len(aEmpr)
		cFilAnt := aEmpr[ni] // Carrega Filial correspondente para ser utilizada na funcao xFilial() //

		IncProc(STR0048) // "Levantando OS's"

		// Analisando OS's ...
		cQuery := "SELECT VO1.VO1_STATUS, VO1.VO1_DATABE, VO1.VO1_DATENT, VO1.VO1_NUMOSV "
		cQuery += "FROM " + RetSqlName("VO1") + " VO1 "
		cQuery += "WHERE VO1.VO1_FILIAL='" + xFilial("VO1") + "' "
		cQuery += "  AND ( "
		cQuery += " (VO1.VO1_DATABE >= '" + cDtMesIni + "' AND VO1.VO1_DATABE <= '" + cDtMesFin + "') " // Dentro do Mes
		cQuery += " OR "
		cQuery += "     (VO1.VO1_DATABE >= '" + DtoS(dDtIni) + "' AND VO1.VO1_DATABE <= '" + DtoS(dDtFin) + "')) " // Dentro do Periodo
		cQuery += "  AND VO1.D_E_L_E_T_=' ' "
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasVO1, .F., .T.)

		Do While !(cAliasVO1)->(Eof())
			lAtrasada := .f.

			If (cAliasVO1)->VO1_STATUS == "A"
				// Abertas
				nLin := 2

				If !Empty((cAliasVO1)->VO1_DATENT) .And. (cAliasVO1)->VO1_DATENT < cAuxDtBase
					lAtrasada := .t.
				EndIf
			ElseIf (cAliasVO1)->VO1_STATUS == "D"
				// Liberadas
				nLin := 3

				If !Empty((cAliasVO1)->VO1_DATENT) .And. (cAliasVO1)->VO1_DATENT < cAuxDtBase
					lAtrasada := .t.
				EndIf
			ElseIf (cAliasVO1)->VO1_STATUS == "C"
				// Canceladas
				nLin := 4
			ElseIf (cAliasVO1)->VO1_STATUS == "F"
				// Fechadas
				nLin := 5
			EndIf

			// Dentro do Mes
			If (cAliasVO1)->VO1_DATABE >= cDtMesIni .And. (cAliasVO1)->VO1_DATABE <= cDtMesFin
				aOSsOfi[nLin, 3] += 1 // No Mes
				nCol := 3             // No Mes

				If (cAliasVO1)->VO1_DATABE == cAuxDtBase
					aOSsOfi[nLin, 2] += 1 // No Dia
					nCol := 2             // No Dia
				EndIf

				If lAtrasada
					aOSsOfi[6, nCol] += 1
				EndIf

				// Adiciona na matriz que sera utilizada posteriormente quando
				// o usuario clicar na listbox de "Ordem de Servicos:Abertas"
				aAdd(aAnalOS, { (cAliasVO1)->VO1_STATUS,;
					Str(nCol, 1),                       ;
					cFilAnt,                            ;
					(cAliasVO1)->VO1_NUMOSV,            ;
					lAtrasada })
			EndIf

			// Dentro do Periodo
			If (cAliasVO1)->VO1_DATABE >= DtoS(dDtIni) .And. (cAliasVO1)->VO1_DATABE <= DtoS(dDtFin)
				aOSsOfi[nLin,4 ] += 1

				If lAtrasada
					aOSsOfi[6, 4] += 1
				EndIf

				// Adiciona na matriz que sera utilizada posteriormente quando
				// o usuario clicar na listbox de "Ordem de Servicos:Abertas"
				aAdd(aAnalOS, { (cAliasVO1)->VO1_STATUS,;
					"4",                                ;
					cFilAnt,                            ;
					(cAliasVO1)->VO1_NUMOSV,            ;
					lAtrasada })
			EndIf

			(cAliasVO1)->(DbSkip())
		EndDo

		(cAliasVO1)->(dbCloseArea())

		DbSelectArea("VO1")

		IncProc(STR0048) // "Levantando OS's"

		// PECAS //
		IncProc(STR0049) // "Levantando Pecas"

		cQuery := "SELECT DISTINCT VO1.VO1_NUMOSV, VO3.VO3_TIPTEM, VO3.VO3_LIBVOO "
		cQuery += "FROM " + RetSQLName("VO1") + " VO1 "
		cQuery += "INNER JOIN " + RetSQLName("VO2") + " VO2 ON VO2.VO2_FILIAL = VO1.VO1_FILIAL AND VO1.VO1_NUMOSV = VO2.VO2_NUMOSV AND VO2.D_E_L_E_T_ = ' ' "
		cQuery += "INNER JOIN " + RetSQLName("VO3") + " VO3 ON VO3.VO3_FILIAL = VO1.VO1_FILIAL AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM AND VO3.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN " + RetSQLName("VEC") + " VEC ON VEC.VEC_FILIAL = '" + xFilial("VEC") + "' AND VEC.VEC_NUMOSV = VO1.VO1_NUMOSV "
		cQuery += "  AND VEC.VEC_TIPTEM = VO3.VO3_TIPTEM AND VEC.VEC_GRUITE = VO3.VO3_GRUITE AND VEC.VEC_CODITE = VO3.VO3_CODITE AND VEC.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.D_E_L_E_T_ = ' ' AND VO3.VO3_DATCAN = '" + Space(8) + "' " // Ignora itens cancelados
		cQuery += "  AND ((VO1.VO1_STATUS IN ('A','D') AND VO3.VO3_DATFEC = '        ') "
		cQuery += "      OR "
		cQuery += " (VO3.VO3_DATFEC >= '" + cDtMesIni + "' AND VO3.VO3_DATFEC <= '" + cDtMesFin + "') " // OS's faturadas no Mes
		cQuery += " OR "
		cQuery += "     (VO3.VO3_DATFEC >= '" + DtoS(dDtIni) + "' AND VO3.VO3_DATFEC <= '" + DtoS(dDtFin) + "')) " // OS's faturadas no Periodo
		cQuery += "ORDER BY VO1.VO1_NUMOSV "
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasVO3, .F., .T.)

		Do While !(cAliasVO3)->(Eof())
			a390TPC := FMX_CALPEC((cAliasVO3)->VO1_NUMOSV,;
				(cAliasVO3)->VO3_TIPTEM,                  ;
				,                                         ;
				,                                         ;
				.T.,                                      ;
				.T.,                                      ;
				.F.,                                      ;
				.T.,                                      ;
				.T.,                                      ;
				.T.,                                      ;
				.T.,                                      ;
				(cAliasVO3)->VO3_LIBVOO) // Matriz TOTAL de Pe็as/Requisi็oes da OS

			dbSelectArea("VOI")
			dbSetOrder(1)

			For niP := 1 to Len(a390TPC)
				VOI->(MsSeek(xFilial("VOI") + a390TPC[niP, PECA_TIPTEM]))

				nLin := 3 // "Cliente"

				If VOI->VOI_SITTPO == "2"     // Garantia
					nLin := 5 // "Garantia"
				ElseIf VOI->VOI_SITTPO == "3" // Interno
					nLin := 8 // "Internas"
				ElseIf VOI->VOI_SITTPO == "4" // Revisao
					nLin := 6 // "Revisao"
				EndIf

				If VOI->VOI_SEGURO == "1"     // Seguradora
					nLin := 4 // "Seguradora"
				ElseIf VOI->VOI_SEGURO == "2" // Franquia
					nLin := 7 // "Franquia"
				EndIf

				lColEmAnda := .f. // Pertence a Coluna "Em Andamento"
				lColFatPen := .f. // Pertence a Coluna "Faturamento Pendente"
				lColFatDia := .f. // Pertence a Coluna "Faturamento Dia"
				lColFatMes := .f. // Pertence a Coluna "Faturamento Mes"
				lColFatPer := .f. // Pertence a Coluna "Faturamento Periodo"

				If Empty(a390TPC[niP,PECA_DATFEC])
					// Em Aberto
					nValor := a390TPC[niP, PECA_VALBRU] - a390TPC[niP, PECA_VALDES]

					If Empty(a390TPC[niP, PECA_DATLIB])
						nCol       := 2   // Servicos em Andamento
						lColEmAnda := .t. // Pertence a Coluna "Em Andamento"
					Else
						nCol       := 3   // Faturamento Pendente
						lColFatPen := .t. // Pertence a Coluna "Faturamento Pendente"
					EndIf

					aSrvOfi[nLin, nCol] += nValor
				Else
					// Fechadas
					nValor :=  a390TPC[niP, PECA_VALBRU] - a390TPC[niP, PECA_VALDES] // Valor

					// Faturada no Dia
					If dtos(a390TPC[niP, PECA_DATFEC]) == cAuxDtBase
						lColFatDia       := .t. // Pertence a Coluna "Faturamento Dia"
						aSrvOfi[nLin, 4] += nValor
						aFatDia[nLin, 6] += nValor
					EndIf

					// Dentro do Mes
					If dtos(a390TPC[niP, PECA_DATFEC]) >= cDtMesIni .And. dtos(a390TPC[niP, PECA_DATFEC]) <= cDtMesFin
						lColFatMes      := .t. // Pertence a Coluna "Faturamento Mes"
						aSrvOfi[nLin,5] += nValor
					EndIf

					// Dentro do Periodo
					If dtos(a390TPC[niP, PECA_DATFEC]) >= DtoS(dDtIni) .And. dtos(a390TPC[niP, PECA_DATFEC]) <= DtoS(dDtFin)
						lColFatPer       := .t. // Pertence a Coluna "Faturamento Periodo"
						aFatPer[nLin, 6] += nValor
						aSrvOfi[nLin, 6] += nValor
					EndIf
				EndIf

				// Adiciona na matriz que sera utilizada posteriormente quando
				// o usuario clicar na listbox de "Oficina"
				If (nPosAnalit := aScan(aAnalit, { |x| x[1] == cFilAnt .And. x[2] == a390TPC[niP, PECA_NUMOSV] .And. x[3] == a390TPC[niP, PECA_TIPTEM] })) == 0
					aadd(aAnalit, { cFilAnt,      ;
						a390TPC[niP, PECA_NUMOSV],;
						a390TPC[niP, PECA_TIPTEM],;
						nLin,                     ;
						lColEmAnda,               ; // Pertence a Coluna "Em Andamento"
						lColFatPen,               ; // Pertence a Coluna "Faturamento Pendente"
						lColFatDia,               ; // Pertence a Coluna "Faturamento Dia"
						lColFatMes,               ; // Pertence a Coluna "Faturamento Mes"
						lColFatPer,               ; // Pertence a Coluna "Faturamento Periodo"
						0,                        ;
						"PECA"})

					nPosAnalit := Len(aAnalit)
				EndIf

				aAnalit[nPosAnalit, 10] += nValor
			Next

			(cAliasVO3)->(DbSkip())
		EndDo

		(cAliasVO3)->(dbCloseArea())

		dbSelectArea("VO3")

		IncProc(STR0049) // "Levantando Pecas"

		// SERVICOS //
		IncProc(STR0050) // "Levantando Servicos"

		nTpoAusD := 0
		nTpoAusM := 0
		nTpoAusP := 0
		nTpoTraD := 0
		nTpoTraM := 0
		nTpoTraP := 0
		nTpoVenD := 0
		nTpoVenM := 0
		nTpoVenP := 0
		aVerPad  := {}

		cQuery := "SELECT DISTINCT VO1.VO1_NUMOSV, VO4.VO4_TIPTEM "
		cQuery += "FROM " + RetSQLName("VO1") + " VO1 "
		cQuery += "INNER JOIN " + RetSQLName("VO4") + " VO4 ON VO4.VO4_FILIAL = VO1.VO1_FILIAL AND VO4.VO4_NUMOSV = VO1.VO1_NUMOSV AND VO4.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.D_E_L_E_T_=' ' AND VO4.VO4_DATCAN = '" + Space(8) + "' " // Ignora itens cancelados
		cQuery += "  AND ((VO1.VO1_STATUS IN ('A','D') AND VO4.VO4_DATFEC = '        ') "
		cQuery += "      OR "
		cQuery += " (VO4.VO4_DATFEC >= '" + cDtMesIni + "' AND VO4.VO4_DATFEC <= '" + cDtMesFin + "') " // OS's faturadas no Mes
		cQuery += " OR "
		cQuery += "     (VO4.VO4_DATFEC >= '" + DtoS(dDtIni) + "' AND VO4.VO4_DATFEC <= '" + DtoS(dDtFin) + "')) " // OS's faturadas no Periodo
		cQuery += "GROUP BY VO1.VO1_NUMOSV , VO1.VO1_DATABE, VO4.VO4_GRUSER , VO4.VO4_CODSER , VO4.VO4_TIPTEM , VO4.VO4_TIPSER , VO4.VO4_DATFEC , VO4.VO4_DATDIS "
		cQuery += "ORDER BY VO1.VO1_NUMOSV "
		dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQuery ), cAliasVO4 , .F. , .T. )

		Do While !(cAliasVO4)->(Eof())
			// Verifica se deve utilizar apontamento
			lCalcApon := .f.

			aValSer := FMX_CALSER(;
				(cAliasVO4)->VO1_NUMOSV,;
				(cAliasVO4)->VO4_TIPTEM,;
				,;
				,;
				.F.,;
				.T.,;
				.T.,;
				.T.,;
				.T.,;
				.F.;
			)

			If Len(aValSer) == 0
				(cAliasVO4)->(dbSkip())
				Loop
			EndIf

			dbSelectArea("VOI")
			dbSetOrder(1)

			For niS := 1 to Len(aValSer)
				If dtos(aValSer[niS, SRVC_DATFEC]) >= cDtMesIni
					If dtos(aValSer[niS, SRVC_DATFEC]) == cAuxDtBase //.or. (cAliasVO4)->VO4_DATINI == cAuxDtBase
						nTpoTraD += aValSer[niS, SRVC_TEMTRA]
						nTpoVenD += aValSer[niS, SRVC_TEMVEN]
					EndIf
					nTpoTraM += aValSer[niS, SRVC_TEMTRA]
					nTpoVenM += aValSer[niS, SRVC_TEMVEN]
				EndIf
				If aValSer[niS, SRVC_DATFEC] >= dDtIni .And. aValSer[niS, SRVC_DATFEC] <= dDtFin // periodo
					nTpoTraP += aValSer[niS, SRVC_TEMTRA]
					nTpoVenP += aValSer[niS, SRVC_TEMVEN]
				EndIf

				VOI->(MsSeek(xFilial("VOI") + aValSer[niS, SRVC_TIPTEM]))
				nLin := 3 // "Cliente"

				If VOI->VOI_SITTPO == "2"     // Garantia
					nLin := 5 // "Garantia"
				ElseIf VOI->VOI_SITTPO == "3" // Interno
					nLin := 8 // "Internas"
				ElseIf VOI->VOI_SITTPO == "4" // Revisao
					nLin := 6 // "Revisao"
				EndIf

				If VOI->VOI_SEGURO == "1"     // Seguradora
					nLin := 4 // "Seguradora"
				ElseIf VOI->VOI_SEGURO == "2" // Franquia
					nLin := 7 // "Franquia"
				EndIf

				nValor     := aValSer[niS, SRVC_VALLIQ] // Valor
				lColEmAnda := .f.                       // Pertence a Coluna "Em Andamento"
				lColFatPen := .f.                       // Pertence a Coluna "Faturamento Pendente"
				lColFatDia := .f.                       // Pertence a Coluna "Faturamento Dia"
				lColFatMes := .f.                       // Pertence a Coluna "Faturamento Mes"
				lColFatPer := .f.                       // Pertence a Coluna "Faturamento Periodo"

				If Empty(aValSer[niS, SRVC_DATFEC])
					If Empty(aValSer[niS, SRVC_DATLIB]) // Em Aberto
						nCol       := 2   // Servicos em Andamento
						lColEmAnda := .t. // Pertence a Coluna "Em Andamento"
					Else
						nCol       := 3   // Faturamento Pendente
						lColFatPen := .t. // Pertence a Coluna "Faturamento Pendente"
					EndIf
					aSrvOfi[nLin, nCol] += nValor
				Else
					If dtos(aValSer[niS, SRVC_DATFEC]) == cAuxDtBase // Faturada no Dia
						lColFatDia       := .t. // Pertence a Coluna "Faturamento Dia"
						aFatDia[nLin, 3] += aValSer[niS, SRVC_TEMTRA]
						aFatDia[nLin, 4] += aValSer[niS, SRVC_TEMVEN]
						aFatDia[nLin, 5] += nValor
						aSrvOfi[nLin, 4] += nValor
					EndIf

					// Dentro do Mes
					If dtos(aValSer[niS, SRVC_DATFEC]) >= cDtMesIni .And. dtos(aValSer[niS, SRVC_DATFEC]) <= cDtMesFin
						lColFatMes       := .t. // Pertence a Coluna "Faturamento Mes"
						aSrvOfi[nLin, 5] += nValor
					EndIf

					// Dentro do Periodo
					If dtos(aValSer[niS, SRVC_DATFEC]) >= DtoS(dDtIni) .And. dtos(aValSer[niS, SRVC_DATFEC]) <= DtoS(dDtFin)
						lColFatPer       := .t. // Pertence a Coluna "Faturamento Periodo"
						aFatPer[nLin, 3] += aValSer[niS, SRVC_TEMTRA]
						aFatPer[nLin, 4] += aValSer[niS, SRVC_TEMVEN]
						aFatPer[nLin, 5] += nValor
						aSrvOfi[nLin, 6] += nValor
					EndIf
				EndIf

				// Adiciona na matriz que sera utilizada posteriormente quando
				// o usuario clicar na listbox de "Oficina"
				If (nPosAnalit := aScan(aAnalit, { |x| x[1] == cFilAnt .And. x[2] == aValSer[niS, SRVC_NUMOSV] .And. x[3] == aValSer[niS, SRVC_TIPTEM] })) == 0
					AADD(aAnalit,;
						{;
							cFilAnt,;
							aValSer[niS, SRVC_NUMOSV],;
							aValSer[niS, SRVC_TIPTEM],;
							nLin,;
							lColEmAnda,; // Pertence a Coluna "Em Andamento"
							lColFatPen,; // Pertence a Coluna "Faturamento Pendente"
							lColFatDia,; // Pertence a Coluna "Faturamento Dia"
							lColFatMes,; // Pertence a Coluna "Faturamento Mes"
							lColFatPer,; // Pertence a Coluna "Faturamento Periodo"
							0,;
							"SERVICO";
						};
					)
					nPosAnalit := Len(aAnalit)
				EndIf

				aAnalit[nPosAnalit, 10] += nValor
			Next

			(cAliasVO4)->(DbSkip())
		EndDo

		(cAliasVO4)->(dbCloseArea())

		DbSelectArea("VO4")

		IncProc(STR0050) // "Levantando Servicos"
		
		// PRODUTIVOS -> TEMPOS //
		IncProc(STR0051) // "Levantando Tempos"

		aHrsOfi[4, 2] += nTpoTraD // Dia Trabalhado
		aHrsOfi[4, 3] += nTpoTraM // Mes Trabalhado
		aHrsOfi[4, 4] += nTpoTraP // Periodo Ausente
		aHrsOfi[5, 2] += nTpoVenD // Dia Vendido
		aHrsOfi[5, 3] += nTpoVenM // Mes Vendido
		aHrsOfi[5, 4] += nTpoVenP // Periodo Ausente

		// Hrs Escalas //
		cQuery := "SELECT VAI.VAI_CODTEC "
		cQuery += "FROM " + RetSqlName("VAI") + " VAI "
		cQuery += "WHERE VAI.VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI.VAI_FILPRO = '" + cFilAnt + "' AND VAI.VAI_FUNPRO = '1' "
		cQuery += "  AND (VAI.VAI_DATDEM = '" + space(8) + "' OR VAI.VAI_DATDEM >= '" + dtos(dDtFin) + "') AND VAI.D_E_L_E_T_=' ' "
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasVAI, .F., .T.)

		Do While !(cAliasVAI)->(Eof())
			aHrsOfi[2, 2] += FS_HRSPROD((cAliasVAI)->(VAI_CODTEC), dDataBase, dDataBase, "0") // Dia
			aHrsOfi[2, 3] += FS_HRSPROD((cAliasVAI)->(VAI_CODTEC), dDtMesIni, dDtMesFin, "0") // M๊s
			aHrsOfi[2, 4] += FS_HRSPROD((cAliasVAI)->(VAI_CODTEC), dDtIni, dDtFin, "0") 	  // Periodo

			(cAliasVAI)->(DbSkip())
		EndDo

		(cAliasVAI)->(dbCloseArea())

		dbSelectArea("VAI")

		// Hrs Ausentes //
		cQuery := "SELECT VO4.VO4_DATINI, VO4.VO4_DATFIN, SUM(VO4.VO4_TEMAUS) AS TEMAUS "
		cQuery += "FROM " + RetSqlName("VO4") + " VO4 "
		cQuery += "WHERE VO4.VO4_FILIAL='" + xFilial("VO4") + "' AND VO4.VO4_NUMOSV = ' ' AND VO4.VO4_NOSNUM = '99999999' "
		cQuery += "  AND ((VO4.VO4_DATINI >= '" + cDtMesIni +    "' AND VO4.VO4_DATINI <= '" + cDtMesFin    + "') " // OS's no Mes
		cQuery += "   OR (VO4.VO4_DATINI >= '" + DtoS(dDtIni) + "' AND VO4.VO4_DATINI <= '" + DtoS(dDtFin) + "')) " // OS's no Periodo
		cQuery += "GROUP BY VO4.VO4_DATINI , VO4.VO4_DATFIN "
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasAus, .F., .T.)

		Do While !(cAliasAus)->(Eof())
			If (cAliasAus)->VO4_DATINI >= cDtMesIni
				If (cAliasAus)->VO4_DATINI  == cAuxDtBase
					nTpoAusD += (cAliasAus)->(TEMAUS) // Dia
				EndIf
				nTpoAusM += (cAliasAus)->(TEMAUS) // Mes
			EndIf
			If (cAliasAus)->VO4_DATINI >= DtoS(dDtIni) .And. (cAliasAus)->VO4_DATINI <= DtoS(dDtFin)
				nTpoAusP += (cAliasAus)->(TEMAUS) // Periodo
			EndIf
			(cAliasAus)->(DbSkip())
		EndDo
		(cAliasAus)->(dbCloseArea())

		aHrsOfi[3, 2] += nTpoAusD // Dia Ausente
		aHrsOfi[3, 3] += nTpoAusM // Mes Ausente
		aHrsOfi[3, 4] += nTpoAusP // Periodo Ausente

		IncProc(STR0051) // "Levantando Tempos"
	Next

	aSort(aAnalit,,, {|x, y| x[1] + x[2] + x[3] < y[1] + y[2] + y[3]})

	// Atualiza linha com Totais (Externas)
	For nLin := 3 to Len(aSrvOfi) - 1
		For nCol := 2 to Len(aSrvOfi[nLin])
			aSrvOfi[1, nCol] += aSrvOfi[nLin, nCol] // Total Geral
			aSrvOfi[2, nCol] += aSrvOfi[nLin, nCol] // Externas
		Next nCol
	Next nLin

	// Soma a linha de internas no total geral
	nLin := Len(aSrvOfi)
	For nCol := 2 to Len(aSrvOfi[nLin])
		aSrvOfi[1, nCol] += aSrvOfi[nLin, nCol] // Total Geral
	Next nCol

	// Atualiza linha com Totais (Externas)
	For nLin := 3 to Len(aFatDia) - 1
		aFatDia[1, 3] += aFatDia[nLin, 3] // Total Geral (Horas Trabalhadas)
		aFatDia[1, 4] += aFatDia[nLin, 4] // Total Geral (Horas Vendidas)
		aFatDia[1, 5] += aFatDia[nLin, 5] // Total Geral (Servicos)
		aFatDia[1, 6] += aFatDia[nLin, 6] // Total Geral (Pe็as)
		aFatDia[2, 3] += aFatDia[nLin, 3] // Total Externas (Horas Trabalhadas)
		aFatDia[2, 4] += aFatDia[nLin, 4] // Total Externas (Horas Vendidas)
		aFatDia[2, 5] += aFatDia[nLin, 5] // Total Externas (Servicos)
		aFatDia[2, 6] += aFatDia[nLin, 6] // Total Externas (Pe็as)
	Next nLin

	// Soma a linha de internas no total geral
	nLin := Len(aFatDia)
	aFatDia[1, 3] += aFatDia[nLin, 3] // Total Geral (Horas Trabalhadas)
	aFatDia[1, 4] += aFatDia[nLin, 4] // Total Geral (Horas Vendidas)
	aFatDia[1, 5] += aFatDia[nLin, 5] // Total Geral (Servicos)
	aFatDia[1, 6] += aFatDia[nLin, 6] // Total Geral (Pe็as)

	// Atualiza linha com Totais (Externas)
	For nLin := 3 to Len(aFatPer) - 1
		aFatPer[1, 5] += aFatPer[nLin, 5] // Total Geral (Servicos)
		aFatPer[2, 5] += aFatPer[nLin, 5] // Total Externas (Servicos)
		aFatPer[1, 6] += aFatPer[nLin, 6] // Total Geral (Pe็as)
		aFatPer[2, 6] += aFatPer[nLin, 6] // Total Externas (Pe็as)
		aFatPer[1, 3] += aFatPer[nLin, 3] // Total Geral (Horas Trabalhadas)
		aFatPer[2, 3] += aFatPer[nLin, 3] // Total Externas (Horas Vendidas)
		aFatPer[1, 4] += aFatPer[nLin, 4] // Total Geral (Horas Trabalhadas)
		aFatPer[2, 4] += aFatPer[nLin, 4] // Total Externas (Horas Vendidas)
	Next nLin

	// Soma a linha de internas no total geral
	nLin := Len(aFatPer)
	aFatPer[1, 3] += aFatPer[nLin, 3] // Total Geral (Horas Trabalhadas)
	aFatPer[1, 4] += aFatPer[nLin, 4] // Total Geral (Horas Vendidas)
	aFatPer[1, 5] += aFatPer[nLin, 5] // Total Geral (Servicos)
	aFatPer[1, 6] += aFatPer[nLin, 6] // Total Geral (Pe็as)

	// Disponivel //
	aHrsOfi[1, 2] := ((aHrsOfi[2, 2] - aHrsOfi[3, 2]) / 100) // Dia
	aHrsOfi[1, 3] := ((aHrsOfi[2, 3] - aHrsOfi[3, 3]) / 100) // Mes

	// Escala //
	aHrsOfi[2, 2] := (aHrsOfi[2, 2] / 100) // Dia
	aHrsOfi[2, 3] := (aHrsOfi[2, 3] / 100) // Mes

	// Ausentes //
	aHrsOfi[3, 2] := (aHrsOfi[3, 2] / 100) // Dia
	aHrsOfi[3, 3] := (aHrsOfi[3, 3] / 100) // Mes

	// Trabalhadas //
	aHrsOfi[4, 2] := (aHrsOfi[4,2] / 100) // Dia
	aHrsOfi[4, 3] := (aHrsOfi[4,3] / 100) // Mes

	// Vendidas //
	aHrsOfi[5, 2] := (aHrsOfi[5, 2] / 100) // Dia
	aHrsOfi[5, 3] := (aHrsOfi[5, 3] / 100) // Mes

	// Produtividade //
	aHrsOfi[6, 2] := ((aHrsOfi[4, 2] / aHrsOfi[2, 2]) * 100) // Dia (Hrs Trabalhadas / Hrs Disponiveis)
	aHrsOfi[6, 3] := ((aHrsOfi[4, 3] / aHrsOfi[2, 3]) * 100) // Mes (Hrs Trabalhadas / Hrs Disponiveis)

	// Eficiencia //
	aHrsOfi[7, 2] := ((aHrsOfi[5, 2] / aHrsOfi[4, 2]) * 100) // Dia (Hrs Vendidas / Hrs Trabalhadas)
	aHrsOfi[7, 3] := ((aHrsOfi[5, 3] / aHrsOfi[4, 3]) * 100) // Mes (Hrs Vendidas / Hrs Trabalhadas)

	// Disponivel //
	aHrsOfi[1, 4] := ((aHrsOfi[2, 4] - aHrsOfi[3, 4]) / 100) // Periodo

	// Escala //
	aHrsOfi[2, 4] := (aHrsOfi[2, 4] / 100) // Periodo

	// Ausentes //
	aHrsOfi[3, 4] := (aHrsOfi[3, 4] / 100) // Periodo

	// Trabalhadas //
	aHrsOfi[4, 4] := (aHrsOfi[4, 4] / 100) // Periodo

	// Vendidas //
	aHrsOfi[5, 4] := (aHrsOfi[5, 4] / 100) // Periodo

	// Produtividade //
	aHrsOfi[6, 4] := ((aHrsOfi[4, 4] / aHrsOfi[2, 4]) * 100) // Periodicidade (Hrs Trabalhadas / Hrs Disponiveis)

	// Eficiencia //
	aHrsOfi[7, 4] := ((aHrsOfi[5, 4] / aHrsOfi[4, 4]) * 100) // Periodicidade (Hrs Vendidas / Hrs Trabalhadas)

	For ni := 2 to 5
		aOSsOfi[1, 2] += aOSsOfi[ni, 2] // Dia
		aOSsOfi[1, 3] += aOSsOfi[ni, 3] // Mes
		aOSsOfi[1, 4] += aOSsOfi[ni, 4] // Geral
	Next

	// Hrs Produtivos //
	If oLbHrsOfi:nAt > len(aHrsOfi)
		oLbHrsOfi:nAt := 1
	EndIf

	oLbHrsOfi:SetArray(aHrsOfi)
	oLbHrsOfi:bLine := { || { aHrsOfi[oLbHrsOfi:nAt, 1],                                                                            ;
		IIf(oLbHrsOfi:nAt > 5, OFIOC39002_FmtPercentual(aHrsOfi[oLbHrsOfi:nAt, 2]), OFIOC39001_FmtValor(aHrsOfi[oLbHrsOfi:nAt, 2])),; // Dia
		IIf(oLbHrsOfi:nAt > 5, OFIOC39002_FmtPercentual(aHrsOfi[oLbHrsOfi:nAt, 3]), OFIOC39001_FmtValor(aHrsOfi[oLbHrsOfi:nAt, 3])),; // Perํodo
		IIf(oLbHrsOfi:nAt > 5, OFIOC39002_FmtPercentual(aHrsOfi[oLbHrsOfi:nAt, 4]), OFIOC39001_FmtValor(aHrsOfi[oLbHrsOfi:nAt, 4])),; // M๊s
		"" }}

	oLbHrsOfi:SetFocus()
	oLbHrsOfi:Refresh()

	// Qtde de OS's //
	If oLbOSsOfi:nAt > len(aOSsOfi)
		oLbOSsOfi:nAt := 1
	EndIf

	oLbOSsOfi:SetArray(aOSsOfi)
	oLbOSsOfi:bLine := { || { aOSsOfi[oLbOSsOfi:nAt, 1],                     ;
		FG_AlinVlrs(Transform(aOSsOfi[oLbOSsOfi:nAt, 2], "@E 9,999,999,999")),;
		FG_AlinVlrs(Transform(aOSsOfi[oLbOSsOfi:nAt, 3], "@E 9,999,999,999")),;
		FG_AlinVlrs(Transform(aOSsOfi[oLbOSsOfi:nAt, 4], "@E 9,999,999,999"))}}

	oLbOSsOfi:SetFocus()
	oLbOSsOfi:Refresh()

	// Valores de Pecas e Servicos //
	If oLbSrvOfi:nAt > len(aSrvOfi)
		oLbSrvOfi:nAt := 1
	EndIf

	oLbSrvOfi:SetArray(aSrvOfi)
	oLbSrvOfi:bLine := { || { aSrvOfi[oLbSrvOfi:nAt, 1],                            ;
		FG_AlinVlrs(Transform(aSrvOfi[oLbSrvOfi:nAt, 2], "@E 999,999,999,999.99")), ;
		Transform((aSrvOfi[oLbSrvOfi:nAt, 2] / aSrvOfi[1, 2]) * 100, "@E 999.9%"),  ;
		FG_AlinVlrs(Transform(aSrvOfi[oLbSrvOfi:nAt, 3], "@E 999,999,999,999.99")), ;
		Transform((aSrvOfi[oLbSrvOfi:nAt, 3] / aSrvOfi[1, 3]) * 100, "@E 999.9%"),  ;
		FG_AlinVlrs(Transform(aSrvOfi[oLbSrvOfi:nAt, 4], "@E 999,999,999,999.99")), ;
		Transform((aSrvOfi[oLbSrvOfi:nAt, 4] / aSrvOfi[1, 4]) * 100, "@E 999.9%"),  ;
		FG_AlinVlrs(Transform(aSrvOfi[oLbSrvOfi:nAt, 5], "@E 999,999,999,999.99")), ;
		Transform((aSrvOfi[oLbSrvOfi:nAt, 5] / aSrvOfi[1, 5]) * 100, "@E 999.9%"),  ;
		FG_AlinVlrs(Transform(aSrvOfi[oLbSrvOfi:nAt, 6], "@E 999,999,999,999.99")), ;
		Transform((aSrvOfi[oLbSrvOfi:nAt, 6] / aSrvOfi[1, 6]) * 100, "@E 999.9%") }}

	oLbSrvOfi:SetFocus()
	oLbSrvOfi:Refresh()
EndIf

cFilAnt := cFilSALVA
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FS_HRSPROD บAutor  ณMicrosiga         บ Data ณ  01/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Levanta Hrs dos Produtivos                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_HRSPROD(_cProd, _dDtIni, _dDtFin, _cTipo)
Local aVetDis := {}
Local nRet    := 0
Local dDatRef := dDataBase
Local cSQLVOE := "SQLVOE"
Local cQuery  := ""
Local nx      := 0
Local ny      := 0

If _cTipo == "0"
	For dDatRef := _dDtIni to _dDtFin
		cQuery := "SELECT VOE.VOE_CODPRO, VOH.VOH_INIPER, VOH.VOH_INICF1, VOH.VOH_FINCF1, VOH.VOH_INIREF, "
		cQuery += "       VOH.VOH_FINREF, VOH.VOH_INICF2, VOH.VOH_FINCF2, VOH_FINPER "
		cQuery += "FROM " + RetSqlName("VOE") + " VOE, " + RetSqlName("VOH") + " VOH "
		cQuery += "WHERE VOE.VOE_FILIAL = '" + xFilial("VOE") + "' AND VOE.VOE_CODPRO = '" + _cProd + "' AND VOE.VOE_DATESC <= '" + dtos(dDatRef) + "' "
		cQuery += "  AND VOH.VOH_FILIAL = '" + xFilial("VOH") + "' AND VOE.VOE_CODPER = VOH.VOH_CODPER AND VOE.D_E_L_E_T_ = ' ' AND VOH.D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY VOE.VOE_DATESC DESC "
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLVOE, .F., .T.)

		If !(cSQLVOE)->(Eof())
			aVetDis := {}

			Aadd(aVetDis, (cSQLVOE)->(VOH_INIPER))
			Aadd(aVetDis, (cSQLVOE)->(VOH_INICF1))
			Aadd(aVetDis, (cSQLVOE)->(VOH_FINCF1))
			Aadd(aVetDis, (cSQLVOE)->(VOH_INIREF))
			Aadd(aVetDis, (cSQLVOE)->(VOH_FINREF))
			Aadd(aVetDis, (cSQLVOE)->(VOH_INICF2))
			Aadd(aVetDis, (cSQLVOE)->(VOH_FINCF2))
			Aadd(aVetDis, (cSQLVOE)->(VOH_FINPER))

			For nx := 1 to (Len(aVetDis) - 1)
				For ny := (nx + 1) to Len(aVetDis)
					If !Empty(aVetDis[nx]) .And. !Empty(aVetDis[ny])
						nRet += FS_VLSERTP(dDatRef, aVetDis[nx], dDatRef, (aVetDis[ny] + If(aVetDis[ny] < aVetDis[nx], 2400, 0)))

						nx := ny

						Exit
					EndIf
				Next
			Next
		EndIf

		(cSQLVOE)->(dbCloseArea())

		dbSelectArea("VOE")
	Next
EndIf
Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FS_ANALIT  บAutor  ณMicrosiga         บ Data ณ  01/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Analitico por OS e Tipo de Tempo                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ANALIT(nTip, nCol)
Local aVet       := {}
Local ni         := 0
Local nj         := 0
Local oHlp       := Mil_ArrayHelper():New()
Local cFilSALVA  := cFilAnt
Local cPictPlaca := VV1->(X3Picture("VV1_PLAVEI"))

Local cSQLVO1 := "SQLVO1"
Local cQuery  := ""

Private aRotina := { { "" ,"axPesqui", 0, 1},; // Pesquisar
					 { "" ,"OC060"   , 0, 2}}  // Visualizar
Private cCadastro := STR0052 // Consulta OS
Private cCampo, nOpc := 2, inclui := .f.

ProcRegua((len(aAnalit) / 50) + 1)

// Acerta nCol, pois a listbox exibida na tela tem colunas calculadas (%)
If !(StrZero(nCol, 2) $ "02/04/06/08/09/10")
	Return
EndIf

If nCol == 2
	nCol := 5
ElseIf nCol == 4
	nCol := 6
ElseIf nCol == 6
	nCol := 7
ElseIf nCol == 8
	nCol := 8
ElseIf nCol == 10
	nCol := 9
EndIf
//

For ni := 1 to len(aAnalit)
	nj++

	If nj == 50
		IncProc(Alltrim(aSrvOfi[nTip, 1]) + " - " + STR0053) // "Analitico"
		nj := 0
	EndIf

	If aAnalit[nI, nCol] .And. (nTip == 1 .Or. (nTip == 2 .And. Str(aAnalit[nI, 4], 1) $ "34567" ) .Or. aAnalit[nI, 4] == nTip)
		cFilAnt := aAnalit[ni, 1]

		cQuery := "SELECT VO1.VO1_DATABE, VO1.VO1_FUNABE, VV1.VV1_PLAVEI, VV1.VV1_CODMAR, VV1.VV1_CHASSI, 
		cQuery += "       VV1.VV1_PROATU, VV1.VV1_LJPATU, VV2.VV2_DESMOD, VAI.VAI_NOMTEC, SA1.A1_NOME "
		cQuery += "FROM " + RetSqlName("VO1") + " VO1 "
		cQuery += "INNER JOIN " + RetSqlName("VV1") + " VV1 ON VV1.VV1_FILIAL = '" + xFilial("VV1") + "' AND VV1.VV1_CHAINT = VO1.VO1_CHAINT AND VV1.D_E_L_E_T_ = ' ' "
		cQuery += "INNER JOIN " + RetSqlName("VV2") + " VV2 ON VV2.VV2_FILIAL = '" + xFilial("VV2") + "' AND VV2.VV2_CODMAR = VV1.VV1_CODMAR "
		cQuery += "  AND VV2.VV2_MODVEI = VV1.VV1_MODVEI AND VV2.D_E_L_E_T_ = ' ' "
		cQuery += "INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_COD = VV1.VV1_PROATU "
		cQuery += "  AND SA1.A1_LOJA = VV1.VV1_LJPATU AND SA1.D_E_L_E_T_ = ' ' "
		cQuery += "INNER JOIN " + RetSqlName("VAI") + " VAI ON VAI.VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI.VAI_CODTEC = VO1.VO1_FUNABE AND VAI.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_NUMOSV = '" + aAnalit[ni,2] + "' AND VO1.D_E_L_E_T_ = ' ' "
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLVO1, .F., .T.)

		If !(cSQLVO1)->(Eof())
			If aAnalit[ni, 11] == "PECA"
				//calcula o total da peca
				/// pega valores da os
				aCalPec := FMX_CALPEC(aAnalit[ni, 2],;
					aAnalit[ni, 3],                  ;
					,                                ;
					,                                ;
					.T.,                             ;
					.T.,                             ;
					.F.,                             ;
					.T.,                             ;
					.T.,                             ;
					.T.,                             ;
					.T.)

				/// pega os totais de todos as pecas valor bruto - desconto (10-7)
				aCalPec := oHlp:Map(aCalPec, {|i| {(i[10] - i[07])}})

				/// soma tudo
				nVal    := oHlp:Sum(1, aCalPec)
			Else
				// calcula o total de servi็os para a OS
				aCalPec := FMX_CALSER(;
					aAnalit[ni, 2],;
					aAnalit[ni, 3],;
					,;
					,;
					.F.,;
					.T.,;
					.T.,;
					.T.,;
					.T.,;
					.F.;
				)

				// soma total da coluna valor liquido (9)
				nVal    := oHlp:Sum(09, aCalPec)
			EndIf

			aadd(aVet, {aAnalit[ni, 1],                                                                        ; // 01 - Filial
				aAnalit[ni, 2],                                                                                ; // 02 - Numero da OS
				Transform((cSQLVO1)->(VO1_DATABE), "@D"),                                                      ; // 03 - Data de Abertura
				(cSQLVO1)->(VO1_FUNABE) + "-" + left((cSQLVO1)->(VAI_NOMTEC), 15),                             ; // 04 - Tecnico
				Transform((cSQLVO1)->(VV1_PLAVEI), cPictPlaca),                                                ; // 05 - Placa do Veiculo
				(cSQLVO1)->(VV1_CODMAR) + " " + left((cSQLVO1)->(VV2_DESMOD), 20),                             ; // 06 - Codigo da Marca
				(cSQLVO1)->(VV1_CHASSI),                                                                       ; // 07 - Chassi
				(cSQLVO1)->(VV1_PROATU) + "-" + (cSQLVO1)->(VV1_LJPATU) + " " + left((cSQLVO1)->(A1_NOME), 25),; // 08 - Proprietario Atual
				aAnalit[ni, 3],                                                                                ; // 09 - TT
				FG_AlinVlrs(Transform(nVal, "@E 999,999,999.99"))})
		EndIf

		(cSQLVO1)->(dbCloseArea())

		DbSelectArea("VO1")
	EndIf
Next

cFilAnt := cFilSALVA

If len(aVet) > 0
	aSort(aVet,,, {|x, y| x[1] + x[2] < y[1] + y[2]})
Else
	aadd(aVet, { "", "", "", "", "", "", "", "", "", "" })
EndIf

DEFINE MSDIALOG oAnalitOS FROM 000,000 TO 031,131;
	TITLE (STR0001 + " ( " + substr(Alltrim(aSrvOfi[nTip, 1]), IIf(left(Alltrim(aSrvOfi[nTip, 1]), 1) <> "-", 1, 3)) + " ) - " + STR0053) OF oMainWnd // "Consulta Oficina" / "Analitico"
@ 001,001 LISTBOX oLbAnalit FIELDS HEADER          ;
	STR0054,                                       ; // "Filial"
	STR0055,                                       ; // "OS"
	STR0086,                                       ; // "TT"
	STR0056,                                       ; // "Abertura"
	STR0057,                                       ; // "Consultor"
	STR0058,                                       ; // "Placa"
	STR0059,                                       ; // "Veiculo"
	STR0060,                                       ; // "Chassi"
	STR0061,                                       ; // "Proprietario"
	STR0009                                        ; // "Total"
	COLSIZES 40, 42, 27, 27, 27, 40, 55, 90, 90, 90;
	SIZE 517,217 OF oAnalitOS PIXEL                ;
	ON DBLCLICK FS_CONSOS(aVet[oLbAnalit:nAt, 1], aVet[oLbAnalit:nAt, 2])

oLbAnalit:SetArray(aVet)
oLbAnalit:bLine := { || { aVet[oLbAnalit:nAt, 1],;
	aVet[oLbAnalit:nAt, 2],                      ;
	aVet[oLbAnalit:nAt, 9],                      ;
	Transform(stod(aVet[oLbAnalit:nAt, 3]),"@D"),;
	aVet[oLbAnalit:nAt, 4],                      ;
	aVet[oLbAnalit:nAt, 5],                      ;
	aVet[oLbAnalit:nAt, 6],                      ;
	aVet[oLbAnalit:nAt, 7],                      ;
	aVet[oLbAnalit:nAt, 8],                      ;
	aVet[oLbAnalit:nAt, 10] }}

@ 222,005 BUTTON oConsOS PROMPT STR0088 OF oAnalitOS SIZE 65,10 PIXEL ACTION FS_CONSOS(aVet[oLbAnalit:nAt, 1], aVet[oLbAnalit:nAt, 2]) // < Visualizar OS>
@ 222,080 BUTTON oImprim PROMPT STR0104 OF oAnalitOS SIZE 65,10 PIXEL ACTION OFC3900021_TREPORT_Analitico(aVet) // < Imprimir >
@ 222,459 BUTTON oSair PROMPT STR0029 OF oAnalitOS SIZE 45,10 PIXEL ACTION oAnalitOS:End() // "< SAIR >"

ACTIVATE MSDIALOG oAnalitOS CENTER
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FS_CONSOS  บAutor  ณMicrosiga         บ Data ณ  01/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chama a consulta de Ordem de Servico (OFIOC060)            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CONSOS(cAuxFil, cAuxNumOs)
Local cFilSALVA := cFilAnt

If Empty(cAuxNumOs)
	Return
EndIf

cFilAnt := cAuxFil

VO1->(dbSetOrder(1))
If VO1->(DbSeek(xFilial("VO1") + cAuxNumOs))
	OC060("VO1", VO1->(RECNO()), 2)
EndIf

cFilAnt := cFilSALVA
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FS_GRAFFAT บAutor  ณMicrosiga         บ Data ณ  01/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grafico OS                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GRAFFAT(nTip)
Local aObjects  := {}, aPosObj := {}, aInfo := {}
Local aSizeAut  := MsAdvSize(.f.) // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local ni        := 0
Local nj        := 0
Local aVet      := {}
Local aPeriodo  := {}
Local dDtFinLc  := dDataBase
Local dDtIniLc  := (dDtFinLc - day(dDtFinLc)) + 1
Local cQuery    := ""
Local cAliasVO3 := "SQLVO3" // PECAS
Local cAliasVO4 := "SQLVO4" // SERVICOS
Local cFilSALVA := cFilAnt
Local nFilDias  := (day(dDataBase) - 1) // "Do mes"
Local oAzul     := LoadBitmap(GetResources(), "BR_AZUL")
Local oBranco   := LoadBitmap(GetResources(), "BR_BRANCO")
Local oCinza    := LoadBitmap(GetResources(), "BR_CINZA")

If cFilDias == STR0003 // Ultimos 30 dias
	nFilDias := 30
ElseIf cFilDias == STR0004 // Ultimos 90 dias
	nFilDias := 90
ElseIf cFilDias == STR0005 // Ultimos 180 dias
	nFilDias := 180
ElseIf cFilDias == STR0006 // Ultimos 365 dias
	nFilDias := 365
ElseIf cFilDias == STR0007 // Ultimos 2 anos
	nFilDias := (365 * 2)
ElseIf cFilDias == STR0008 // Ultimos 3 anos
	nFilDias := (365 * 3)
ElseIf cFilDias == STR0009 // Total
	nFilDias := 99999
EndIf

For ni := 1 to 30
	aadd(aPeriodo, { (dDataBase - 30) + ni, Alltrim(str(val(right(dtos((dDataBase - 30) + ni), 2)), 2)) })
Next

ProcRegua((4 * len(aEmpr)))

For ni := 1 to len(aEmpr)
	cFilAnt := aEmpr[ni] // Carrega Filial correspondente para ser utilizada na funcao xFilial()

	// PECAS //
	IncProc(STR0049) // "Levantando Pecas"

	cQuery := "SELECT DISTINCT VO1.VO1_NUMOSV, VO3.VO3_TIPTEM, VO1.VO1_DATABE, VO3.VO3_DATFEC, "
	cQuery += "                VO3.VO3_FATPAR, VO3.VO3_LOJA, VOI.VOI_SITTPO, VOI.VOI_SEGURO "
	cQuery += "FROM " + RetSqlName("VO3") + " VO3, " + RetSqlName("VO1") + " VO1, " + RetSqlName("VO2") + " VO2, " + RetSqlName("VOI") + " VOI "
	cQuery += "WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_DATABE >= '" + dtos((dDtFinLc - nFilDias)) + "' AND VO2.VO2_FILIAL = VO1.VO1_FILIAL "
	cQuery += "  AND VO1.VO1_NUMOSV = VO2.VO2_NUMOSV AND VO3.VO3_FILIAL = VO1.VO1_FILIAL AND VO2.VO2_NOSNUM = VO3.VO3_NOSNUM AND VO3.VO3_DATCAN = '" + space(8) + "' "
	cQuery += "  AND VO3.VO3_DATFEC >= '" + dtos(dDtIniLc) + "' AND VO3.VO3_DATFEC <= '" + dtos(dDtFinLc) + "' AND VOI.VOI_FILIAL = '" + xFilial("VOI") + "' "
	cQuery += "  AND VO3.VO3_TIPTEM = VOI.VOI_TIPTEM AND VO3.D_E_L_E_T_ = ' ' AND VO1.D_E_L_E_T_ = ' ' AND VO2.D_E_L_E_T_ = ' ' AND VOI.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY VO1.VO1_NUMOSV, VO3.VO3_TIPTEM "
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasVO3, .F., .T.)

	Do While !(cAliasVO3)->(Eof())
		nLin := val((cAliasVO3)->(VOI_SITTPO))
		If nLin == 2     // Garantia
			nLin := 5
		ElseIf nLin == 3 // Interno
			nLin := 8
		ElseIf nLin == 4 // Revisao
			nLin := 6
		ElseIf nLin <= 1 // Sem SITTPO (P๚blico)
			nLin := 3 // Cliente
		EndIf

		If (cAliasVO3)->(VOI_SEGURO) == "1"     // Seguradora
			nLin := 4
		ElseIf (cAliasVO3)->(VOI_SEGURO) == "2" // Franquia
			nLin := 7
		EndIf

		dbSelectArea("SA1")
		dbSetOrder(1)

		If nTip == nLin .Or. nTip == 1 .Or. (nTip == 2 .And. nLin <= 7)
			SA1->(MsSeek(xFilial("SA1") + (cAliasVO3)->(VO3_FATPAR) + (cAliasVO3)->(VO3_LOJA)))

			aadd(aVet, { (cAliasVO3)->(VO1_NUMOSV) + " " + (cAliasVO3)->(VO3_TIPTEM),                    ;
				(cAliasVO3)->(VO3_FATPAR) + "-" + (cAliasVO3)->(VO3_LOJA) + " " + left(SA1->A1_NOME, 25),;
				SToD((cAliasVO3)->(VO1_DATABE)),                                                         ;
				SToD((cAliasVO3)->(VO3_DATFEC)),                                                         ;
				"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" }) // 30 posi็๕es (ฺltimos 30 dias)
		EndIf

		(cAliasVO3)->(DbSkip())
	EndDo

	(cAliasVO3)->(dbCloseArea())

	DbSelectArea("VO3")

	IncProc(STR0049) // "Levantando Pecas"

	// SERVICOS //
	IncProc(STR0050) // "Levantando Servicos"

	cQuery := "SELECT DISTINCT VO1.VO1_NUMOSV, VO4.VO4_TIPTEM, VO1.VO1_DATABE, VO4.VO4_DATFEC, "
	cQuery += "                VO4.VO4_FATPAR, VO4.VO4_LOJA, VOI.VOI_SITTPO, VOI.VOI_SEGURO "
	cQuery += "FROM " + RetSqlName("VO4") + " VO4, " + RetSqlName("VO1") + " VO1, " + RetSqlName("VOI") + " VOI "
	cQuery += "WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_DATABE >= '" + dtos((dDtFinLc - nFilDias)) + "' AND VO4.VO4_FILIAL = VO1.VO1_FILIAL "
	cQuery += "  AND VO4.VO4_NUMOSV = VO1.VO1_NUMOSV AND VO4.VO4_DATCAN = '" + space(8) + "' AND VO4.VO4_DATFEC >= '" + dtos(dDtIniLc) + "' "
	cQuery += "  AND VO4.VO4_DATFEC <= '" + dtos(dDtFinLc) + "' AND VOI.VOI_FILIAL = '" + xFilial("VOI") + "' AND VO4.VO4_TIPTEM = VOI.VOI_TIPTEM "
	cQuery += "  AND VO4.D_E_L_E_T_ = ' ' AND VO1.D_E_L_E_T_ = ' ' AND VOI.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY VO1.VO1_NUMOSV, VO4.VO4_TIPTEM "
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasVO4, .F., .T.)

	Do While !(cAliasVO4)->(Eof())
		nLin := val((cAliasVO4)->(VOI_SITTPO))
		If nLin == 2     // Garantia
			nLin := 5
		ElseIf nLin == 3 // Interno
			nLin := 8
		ElseIf nLin == 4 // Revisao
			nLin := 6
		ElseIf nLin <= 1 // Sem SITTPO (P๚blico)
			nLin := 3 // Cliente
		EndIf

		If (cAliasVO4)->(VOI_SEGURO) == "1"     // Seguradora
			nLin := 4
		ElseIf (cAliasVO4)->(VOI_SEGURO) == "2" // Franquia
			nLin := 7
		EndIf

		dbSelectArea("SA1")
		dbSetOrder(1)

		If nTip == nLin .Or. nTip == 1 .Or. (nTip == 2 .And. nLin <= 7)
			If aScan(aVet, {|x| x[1] == (cAliasVO4)->(VO1_NUMOSV) + " " + (cAliasVO4)->(VO4_TIPTEM)}) <= 0
				SA1->(MsSeek(xFilial("SA1") + (cAliasVO4)->(VO4_FATPAR) + (cAliasVO4)->(VO4_LOJA)))

				aadd(aVet, { (cAliasVO4)->(VO1_NUMOSV) + " " + (cAliasVO4)->(VO4_TIPTEM),                    ;
					(cAliasVO4)->(VO4_FATPAR) + "-" + (cAliasVO4)->(VO4_LOJA) + " " + left(SA1->A1_NOME, 25),;
					SToD((cAliasVO4)->(VO1_DATABE)),                                                         ;
					SToD((cAliasVO4)->(VO4_DATFEC)),                                                         ;
					"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" }) // 30 posi็๕es (ฺltimos 30 dias)
			EndIf
		EndIf

		(cAliasVO4)->(DbSkip())
	EndDo

	(cAliasVO4)->(dbCloseArea())

	DbSelectArea("VO4")

	IncProc(STR0050) // "Levantando Servicos"
Next

If len(aVet) > 0
	aadd(aVet, { " " + STR0031,                                                                                                               ; // Total Geral
		"",                                                                                                                                   ;
		aPeriodo[1, 1],                                                                                                                       ;
		aPeriodo[30, 1],                                                                                                                      ;
		oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco,;
		oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco }) // 30 posi็๕es (ฺltimos 30 dias)

	aSort(aVet,,, {|x, y| x[1] < y[1]})

	For ni := 2 to len(aVet)
		For nj := 1 to 30
			If aPeriodo[nj, 1] >= aVet[ni, 3] .And. aPeriodo[nj, 1] <= aVet[ni, 4]
				aVet[ni, nj + 4] := oAzul
				aVet[1, nj + 4]  := oAzul
			Else
				If dow(aPeriodo[nj, 1]) <> 1 // Diferente de Domingo
					aVet[ni, nj + 4]    := oBranco
				Else
					aVet[ni, nj + 4]    := oCinza
					If aVet[1, nj + 4] == oBranco
						aVet[1, nj + 4] := oCinza
					EndIf
				EndIf
			EndIf
		Next
	Next
Else
	aadd(aVet, { "",                                                                                                                          ;
		"",                                                                                                                                   ;
		CToD(""),                                                                                                                             ;
		CToD(""),                                                                                                                             ;
		oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco,;
		oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco, oBranco })
EndIf

cFilAnt := cFilSALVA

DbSelectArea("VO1")

// Configura os tamanhos dos objetos
aObjects := {}
AAdd(aObjects, { 10, 10, .T., .T. }) //list box
AAdd(aObjects, { 08, 08, .T., .F. }) //rodape
aInfo   := {aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 2, 2}
aPosObj := MsObjSize (aInfo, aObjects, .F.)

DEFINE MSDIALOG oAnalitOS FROM aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5];
	TITLE (STR0001 + " - " + STR0066 + " ( " + substr(Alltrim(aSrvOfi[nTip, 1]),; // "Consulta Oficina" / "Grafico OS"
	IIf(left(Alltrim(aSrvOfi[nTip, 1]), 1) <> "-", 1, 3)) + " ) - " + STR0079 + " (" + Transform(aPeriodo[1, 1] ,"@D") + STR0030 + Transform(aPeriodo[30, 1], "@D")) + " )" OF oMainWnd PIXEL // "Ultimos 30 dias" / " ate "

oLbAnalit := TWBrowse():New(aPosObj[1,1], aPosObj[1,2], aPosObj[1,4] - 2, (aPosObj[1,3] - aPosObj[1,1]),,,, oAnalitOS,,,,,,,,,,,, .F.,, .T.,, .F.,,,)
oLbAnalit:nAt := 1
oLbAnalit:SetArray(aVet)
oLbAnalit:addColumn(TCColumn():New((STR0055 + "/" + STR0067),       {|| aVet[oLbAnalit:nAt, 1]                                                       },,,, "LEFT",  035, .F., .F.,,,, .F.,)) // OS / TpTempo
oLbAnalit:addColumn(TCColumn():New(left(RetTitle("VO1_DATABE"), 8), {|| Transform(aVet[oLbAnalit:nAt, 3], "@D")                                      },,,, "LEFT",  023, .F., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(left(RetTitle("VO3_DATFEC"), 8), {|| Transform(aVet[oLbAnalit:nAt, 4], "@D")                                      },,,, "LEFT",  023, .F., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(STR0068,                         {|| Transform((aVet[oLbAnalit:nAt, 4] - aVet[oLbAnalit:nAt, 3]) + 1, "@E 999999")},,,, "RIGHT", 015, .F., .F.,,,, .F.,)) // Dias
oLbAnalit:addColumn(TCColumn():New(aPeriodo[01, 2],                 {|| aVet[oLbAnalit:nAt, 05]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[02, 2],                 {|| aVet[oLbAnalit:nAt, 06]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[03, 2],                 {|| aVet[oLbAnalit:nAt, 07]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[04, 2],                 {|| aVet[oLbAnalit:nAt, 08]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[05, 2],                 {|| aVet[oLbAnalit:nAt, 09]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[06, 2],                 {|| aVet[oLbAnalit:nAt, 10]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[07, 2],                 {|| aVet[oLbAnalit:nAt, 11]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[08, 2],                 {|| aVet[oLbAnalit:nAt, 12]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[09, 2],                 {|| aVet[oLbAnalit:nAt, 13]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[10, 2],                 {|| aVet[oLbAnalit:nAt, 14]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[11, 2],                 {|| aVet[oLbAnalit:nAt, 15]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[12, 2],                 {|| aVet[oLbAnalit:nAt, 16]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[13, 2],                 {|| aVet[oLbAnalit:nAt, 17]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[14, 2],                 {|| aVet[oLbAnalit:nAt, 18]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[15, 2],                 {|| aVet[oLbAnalit:nAt, 19]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[16, 2],                 {|| aVet[oLbAnalit:nAt, 20]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[17, 2],                 {|| aVet[oLbAnalit:nAt, 21]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[18, 2],                 {|| aVet[oLbAnalit:nAt, 22]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[19, 2],                 {|| aVet[oLbAnalit:nAt, 23]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[20, 2],                 {|| aVet[oLbAnalit:nAt, 24]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[21, 2],                 {|| aVet[oLbAnalit:nAt, 25]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[22, 2],                 {|| aVet[oLbAnalit:nAt, 26]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[23, 2],                 {|| aVet[oLbAnalit:nAt, 27]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[24, 2],                 {|| aVet[oLbAnalit:nAt, 28]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[25, 2],                 {|| aVet[oLbAnalit:nAt, 29]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[26, 2],                 {|| aVet[oLbAnalit:nAt, 30]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[27, 2],                 {|| aVet[oLbAnalit:nAt, 31]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[28, 2],                 {|| aVet[oLbAnalit:nAt, 32]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[29, 2],                 {|| aVet[oLbAnalit:nAt, 33]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(aPeriodo[30, 2],                 {|| aVet[oLbAnalit:nAt, 34]                                                      },,,, "LEFT",  011, .T., .F.,,,, .F.,))
oLbAnalit:addColumn(TCColumn():New(STR0033,                         {|| aVet[oLbAnalit:nAt, 02]                                                      },,,, "LEFT",  130, .F., .F.,,,, .F.,)) // Cliente
oLbAnalit:Refresh()

@ aPosObj[2,1] + 001,010 BITMAP oxBran RESOURCE "BR_BRANCO" OF oAnalitOS NOBORDER SIZE 10,10 when .f. PIXEL
@ aPosObj[2,1] + 001,020 SAY STR0076 SIZE 100,08 OF oAnalitOS PIXEL COLOR CLR_BLUE // "Dias nao utilizados"
@ aPosObj[2,1] + 001,100 BITMAP oxAzul RESOURCE "BR_AZUL" OF oAnalitOS NOBORDER SIZE 10,10 when .f. PIXEL
@ aPosObj[2,1] + 001,110 SAY STR0077 SIZE 100,08 OF oAnalitOS PIXEL COLOR CLR_BLUE // "Dias utilizados"
@ aPosObj[2,1] + 001,190 BITMAP oxCinz RESOURCE "BR_CINZA" OF oAnalitOS NOBORDER SIZE 10,10 when .f. PIXEL
@ aPosObj[2,1] + 001,200 SAY STR0078 SIZE 100,08 OF oAnalitOS PIXEL COLOR CLR_BLUE // "Domingo"
@ aPosObj[2,1] + 000,aPosObj[2,4] - 050 BUTTON oSair PROMPT STR0029 OF oAnalitOS SIZE 45,10 PIXEL ACTION oAnalitOS:End() // "< SAIR >"

ACTIVATE MSDIALOG oAnalitOS CENTER
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FDIAMES บAutor  ณMicrosiga          บ Data ณ             บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processamento do Botao Faturamento Dia/Mes                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_FDIAMES()
DEFINE MSDIALOG oFatDiaMes FROM 000,000 TO 031,111 TITLE (STR0001 + " - " + STR0065) OF oMainWnd // "Consulta Oficina" / "Faturamento Dia / Periodo"
@ 006,001 TO 105,438 LABEL (" " + STR0020 + " (" + Transform(dDataBase, "@D") + ") ") OF oFatDiaMes PIXEL // "Faturadas Dia"
@ 111,001 TO 210,438 LABEL (" " + STR0021) OF oFatDiaMes PIXEL // "Faturadas Periodo"

@ 013,004 LISTBOX oLbFatDia FIELDS HEADER;
	STR0017,                             ; // "Ordens de Servico"
	STR0069,                             ; // "Qtde"
	STR0040,                             ; // "Horas Trabalhadas"
	STR0041,                             ; // "Horas Vendidas"
	STR0070,                             ; // "Servicos"
	STR0071,                             ; // "Pecas"
	STR0031                              ; // "Total Geral"
	COLSIZES 55, 55, 55, 55, 55, 55, 55  ;
	SIZE 431,089 OF oFatDiaMes PIXEL     ;
	ON DBLCLICK Processa({|| FS_ANALIT(oLbFatDia:nAt, 6)})

oLbFatDia:SetArray(aFatDia)
oLbFatDia:bLine := {|| { aFatDia[oLbFatDia:nAt, 1],;
	FG_AlinVlrs(Transform(aFatDia[oLbFatDia:nAt, 2], "@E 999,999,999")),;
	FG_AlinVlrs(Transform(oDmsUtil:Centes2Hora(aFatDia[oLbFatDia:nAt, 3]), "@R 999999:99")),;
	FG_AlinVlrs(Transform(oDmsUtil:Centes2Hora(aFatDia[oLbFatDia:nAt, 4]), "@R 999999:99")),;
	FG_AlinVlrs(Transform(aFatDia[oLbFatDia:nAt, 5], "@E 999,999,999.99")),;
	FG_AlinVlrs(Transform(aFatDia[oLbFatDia:nAt, 6], "@E 999,999,999.99")),;
	FG_AlinVlrs(Transform(aFatDia[oLbFatDia:nAt, 5] + aFatDia[oLbFatDia:nAt, 6], "@E 999,999,999.99"))}}

@ 118,004 LISTBOX oLbFatMes FIELDS HEADER;
	STR0017,; // "Ordens de Servico"
	STR0069,; // "Qtde"
	STR0040,; // "Horas Trabalhadas"
	STR0041,; // "Horas Vendidas"
	STR0070,; // "Servicos"
	STR0071,; // "Pecas"
	STR0031; // "Total Geral"
	COLSIZES 55, 55, 55, 55, 55, 55, 55;
	SIZE 431,089 OF oFatDiaMes PIXEL;
	ON DBLCLICK Processa({|| FS_ANALIT(oLbFatMes:nAt, 9)})

oLbFatMes:SetArray(aFatPer)
oLbFatMes:bLine := {|| { aFatPer[oLbFatMes:nAt, 1],;
	FG_AlinVlrs(Transform(aFatPer[oLbFatMes:nAt, 2], "@E 999,999,999")),;	
	FG_AlinVlrs(Transform(oDmsUtil:Centes2Hora(aFatPer[oLbFatMes:nAt, 3]), "@R 999999:99")),;
	FG_AlinVlrs(Transform(oDmsUtil:Centes2Hora(aFatPer[oLbFatMes:nAt, 4]), "@R 999999:99")),;
	FG_AlinVlrs(Transform(aFatPer[oLbFatMes:nAt, 5], "@E 999,999,999.99")),;
	FG_AlinVlrs(Transform(aFatPer[oLbFatMes:nAt, 6], "@E 999,999,999.99")),;
	FG_AlinVlrs(Transform(aFatPer[oLbFatMes:nAt, 5] + aFatPer[oLbFatMes:nAt, 6], "@E 999,999,999.99"))}}

@ 222,389 BUTTON oSair PROMPT STR0029 OF oFatDiaMes SIZE 45,10 PIXEL ACTION oFatDiaMes:End() // "< SAIR >"

ACTIVATE MSDIALOG oFatDiaMes CENTER
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FS_CONSULT บAutor  ณMicrosiga         บ Data ณ  01/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consultores                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CONSULT()
Local ni        := 0
Local nPos      := 0
Local lVetDia   := .f. // Processamento Dia apenas uma vez
Local aVetPer   := {}
Local dDtF      := dDtFin
Local dDtFinLc  := dDataBase
Local cQuery    := ""
Local cAliasVAI := "SQLVAI" // Equipe Tecnica (Consultores)
Local cAliasVO1 := "SQLVO1" // Ordem de Servico
Local cFilSALVA := cFilAnt

ProcRegua((12 * len(aEmpr)))

aadd(aVetPer, { STR0031, space(10), 0, 0, 0, 0, 0, 0, 0 }) // MES - Total Geral

If Empty(aVetDia)
	aadd(aVetDia, { STR0031, space(10), 0, 0, 0, 0, 0, 0, 0 }) // DIA - Total Geral
Else
	lVetDia := .t.
EndIf

For ni := 1 to len(aEmpr)
	cFilAnt := aEmpr[ni] // Carrega Filial correspondente para ser utilizada na funcao xFilial() //

	IncProc(STR0048) // "Levantando OS's"

	If !lVetDia
		// OS's ABERTAS - DIA //
		cQuery := "SELECT VO1.VO1_FUNABE, COUNT(VO1.VO1_NUMOSV) AS QTDE "
		cQuery += "FROM " + RetSqlName("VO1") + " VO1 "
		cQuery += "WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_DATABE = '" + dtos(dDtFinLc) + "' AND VO1.D_E_L_E_T_ = ' ' "
		cQuery += "GROUP BY VO1.VO1_FUNABE "
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasVO1, .F., .T.)

		Do While !(cAliasVO1)->(Eof())
			nPos := FS_ADDVET((cAliasVO1)->(VO1_FUNABE), @aVetDia)

			aVetDia[1, 3]    += (cAliasVO1)->(QTDE) // Total
			aVetDia[nPos, 3] += (cAliasVO1)->(QTDE) // Linha Consultor

			(cAliasVO1)->(DbSkip())
		EndDo

		(cAliasVO1)->(dbCloseArea())

		IncProc(STR0048) // "Levantando OS's"

		// OS's DISPONIVEIS - DIA //
		cQuery := "SELECT TEMP.VO1_FUNABE, COUNT(*) AS QTDE FROM ( "
		cQuery += "  SELECT DISTINCT VO1.VO1_FUNABE, VO1.VO1_NUMOSV AS NUMOSV, VO3.VO3_TIPTEM AS TIPTEM "
		cQuery += "  FROM " + RetSqlName("VO1") + " VO1, " + RetSqlName("VO2") + " VO2, " + RetSqlName("VO3") + " VO3 "
		cQuery += "  WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_STATUS = 'D' AND VO1.VO1_DATABE >= '" + dtos(dDtIni) + "' "
		cQuery += "    AND VO1.VO1_DATABE <= '" + dtos(dDtFinLc) + "' AND VO2.VO2_FILIAL = VO1.VO1_FILIAL AND VO1.VO1_NUMOSV = VO2.VO2_NUMOSV "
		cQuery += "    AND VO3.VO3_FILIAL = VO1.VO1_FILIAL AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM AND VO3.VO3_DATDIS = '" + dtos(dDtFinLc) + "' "
		cQuery += "     AND VO3.VO3_DATCAN = '" + space(8) + "'AND VO3.VO3_DATFEC = '" + space(8) + "' AND VO1.D_E_L_E_T_ = ' ' AND VO2.D_E_L_E_T_ = ' ' "
		cQuery += "     AND VO3.D_E_L_E_T_ = ' ' "
		cQuery += "  UNION "
		cQuery += "  SELECT DISTINCT VO1.VO1_FUNABE, VO1.VO1_NUMOSV AS NUMOSV, VO4.VO4_TIPTEM AS TIPTEM "
		cQuery += "  FROM " + RetSqlName("VO1") + " VO1, " + RetSqlName("VO2") + " VO2, " + RetSqlName("VO4") + " VO4 "
		cQuery += "  WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_STATUS = 'D' AND VO1.VO1_DATABE >= '" + dtos(dDtIni) + "' "
		cQuery += "    AND VO1.VO1_DATABE <= '" + dtos(dDtFinLc) + "' AND VO2.VO2_FILIAL = VO1.VO1_FILIAL AND VO1.VO1_NUMOSV = VO2.VO2_NUMOSV "
		cQuery += "    AND VO4.VO4_FILIAL = VO1.VO1_FILIAL AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM AND VO4.VO4_DATDIS = '" + dtos(dDtFinLc) + "' "
		cQuery += "    AND VO4.VO4_DATCAN = '" + space(8) + "' AND VO4.VO4_DATFEC = '" + space(8) + "' AND VO1.D_E_L_E_T_ = ' ' "
		cQuery += "    AND VO2.D_E_L_E_T_ = ' ' AND VO4.D_E_L_E_T_ = ' ' "
		cQuery += ") TEMP GROUP BY TEMP.VO1_FUNABE "
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasVO1, .F., .T.)

		Do While !(cAliasVO1)->(Eof())
			nPos := FS_ADDVET((cAliasVO1)->(VO1_FUNABE), @aVetDia)

			aVetDia[1, 4]    += (cAliasVO1)->(QTDE) // Total
			aVetDia[nPos, 4] += (cAliasVO1)->(QTDE) // Linha Consultor

			(cAliasVO1)->(DbSkip())
		EndDo

		(cAliasVO1)->(dbCloseArea())

		IncProc(STR0048) // "Levantando OS's"

		// OS's CANCELADAS - DIA //
		cQuery := "SELECT TEMP.VO1_FUNABE, COUNT(*) AS QTDE FROM ( "
		cQuery += "  SELECT DISTINCT VO1.VO1_FUNABE, VO1.VO1_NUMOSV AS NUMOSV, VO3.VO3_TIPTEM AS TIPTEM "
		cQuery += "  FROM " + RetSqlName("VO1") + " VO1, " + RetSqlName("VO2") + " VO2, " + RetSqlName("VO3") + " VO3 "
		cQuery += "  WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_STATUS = 'C' AND VO1.VO1_DATABE >= '" + dtos(dDtIni) + "' "
		cQuery += "    AND VO1.VO1_DATABE <= '" + dtos(dDtFinLc) + "' AND VO2.VO2_FILIAL = VO1.VO1_FILIAL AND VO1.VO1_NUMOSV = VO2.VO2_NUMOSV "
		cQuery += "    AND VO3.VO3_FILIAL = VO1.VO1_FILIAL AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM AND VO3.VO3_DATCAN = '" + dtos(dDtFinLc) + "' "
		cQuery += "    AND VO1.D_E_L_E_T_ = ' ' AND VO2.D_E_L_E_T_ = ' ' AND VO3.D_E_L_E_T_ = ' ' "
		cQuery += "  UNION "
		cQuery += "  SELECT DISTINCT VO1.VO1_FUNABE, VO1.VO1_NUMOSV AS NUMOSV, VO4.VO4_TIPTEM AS TIPTEM "
		cQuery += "  FROM " + RetSqlName("VO1") + " VO1, " + RetSqlName("VO2") + " VO2, " + RetSqlName("VO4") + " VO4 "
		cQuery += "  WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_STATUS = 'C' AND VO1.VO1_DATABE >= '" + dtos(dDtIni) + "' "
		cQuery += "    AND VO1.VO1_DATABE <= '" + dtos(dDtFinLc) + "' AND VO2.VO2_FILIAL = VO1.VO1_FILIAL AND VO1.VO1_NUMOSV = VO2.VO2_NUMOSV "
		cQuery += "    AND VO4.VO4_FILIAL = VO1.VO1_FILIAL AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM AND VO4.VO4_DATCAN = '" + dtos(dDtFinLc) + "' "
		cQuery += "    AND VO1.D_E_L_E_T_ = ' ' AND VO2.D_E_L_E_T_ = ' ' AND VO4.D_E_L_E_T_ = ' ' "
		cQuery += ") TEMP GROUP BY TEMP.VO1_FUNABE "
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasVO1, .F., .T.)

		Do While !(cAliasVO1)->(Eof())
			nPos := FS_ADDVET((cAliasVO1)->(VO1_FUNABE), @aVetDia)

			aVetDia[1, 5]    += (cAliasVO1)->(QTDE) // Total
			aVetDia[nPos, 5] += (cAliasVO1)->(QTDE) // Linha Consultor

			(cAliasVO1)->(DbSkip())
		EndDo

		(cAliasVO1)->(dbCloseArea())

		IncProc(STR0048) // "Levantando OS's"

		// OS's FECHADAS - DIA //
		cQuery := "SELECT TEMP.VO1_FUNABE, COUNT(*) AS QTDE FROM ( "
		cQuery += "  SELECT DISTINCT VO1.VO1_FUNABE, VO1.VO1_NUMOSV AS NUMOSV, VO3.VO3_TIPTEM AS TIPTEM "
		cQuery += "  FROM " + RetSqlName("VO1") + " VO1, " + RetSqlName("VO2") + " VO2, " + RetSqlName("VO3") + " VO3 "
		cQuery += "  WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_STATUS = 'F' AND VO2.VO2_FILIAL = VO1.VO1_FILIAL "
		cQuery += "    AND VO2.VO2_NUMOSV = VO1.VO1_NUMOSV AND VO3.VO3_FILIAL = VO1.VO1_FILIAL AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM "
		cQuery += "    AND VO3.VO3_DATCAN = '" + space(8) + "' AND VO3.VO3_DATFEC = '" + dtos(dDtFinLc) + "' AND VO1.D_E_L_E_T_ = ' ' "
		cQuery += "    AND VO2.D_E_L_E_T_ = ' ' AND VO3.D_E_L_E_T_ = ' ' "
		cQuery += "  UNION "
		cQuery += "  SELECT DISTINCT VO1.VO1_FUNABE, VO1.VO1_NUMOSV AS NUMOSV, VO4.VO4_TIPTEM AS TIPTEM "
		cQuery += "  FROM " + RetSqlName("VO1") + " VO1, " + RetSqlName("VO2") + " VO2, " + RetSqlName("VO4") + " VO4 "
		cQuery += "  WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_STATUS = 'F' AND VO2.VO2_FILIAL = VO1.VO1_FILIAL "
		cQuery += "    AND VO2.VO2_NUMOSV = VO1.VO1_NUMOSV AND VO4.VO4_FILIAL = VO1.VO1_FILIAL AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM "
		cQuery += "    AND VO4.VO4_DATCAN = '" + space(8) + "' AND VO4.VO4_DATFEC = '" + dtos(dDtFinLc) + "' AND VO1.D_E_L_E_T_ = ' ' "
		cQuery += "    AND VO2.D_E_L_E_T_ = ' ' AND VO4.D_E_L_E_T_ = ' ' "
		cQuery += ") TEMP GROUP BY TEMP.VO1_FUNABE "
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasVO1, .F., .T.)

		Do While !(cAliasVO1)->(Eof())
			nPos := FS_ADDVET((cAliasVO1)->(VO1_FUNABE), @aVetDia)

			aVetDia[1, 6]    += (cAliasVO1)->(QTDE) // Total
			aVetDia[nPos, 6] += (cAliasVO1)->(QTDE) // Linha Consultor

			(cAliasVO1)->(DbSkip())
		EndDo

		(cAliasVO1)->(dbCloseArea())

		IncProc(STR0048) // "Levantando OS's"

		// OS's EM ANDAMENTO - DIA //
		cQuery := "SELECT TEMP.VO1_FUNABE, COUNT(*) AS QTDE FROM ( "
		cQuery += "  SELECT DISTINCT VO1.VO1_FUNABE, VO1.VO1_NUMOSV, VO4.VO4_TIPTEM "
		cQuery += "  FROM " + RetSqlName("VO1") + " VO1, " + RetSqlName("VO4") + " VO4 "
		cQuery += "  WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_DATABE >= '" + dtos(dDtIni) + "' AND VO1.VO1_DATABE <= '" + dtos(dDtFinLc) + "' "
		cQuery += "    AND VO4.VO4_FILIAL = VO1.VO1_FILIAL AND VO4.VO4_NUMOSV = VO1.VO1_NUMOSV AND VO4.VO4_DATCAN = '" + space(8) + "' AND VO4.VO4_DATFEC = '" + space(8) + "' "
		cQuery += "    AND VO4.VO4_DATINI = '" + dtos(dDtFinLc) + "' AND VO4.VO4_DATFIN = '" + space(8) + "' AND VO1.D_E_L_E_T_ = ' ' AND VO4.D_E_L_E_T_ = ' ' "
		cQuery += ") TEMP GROUP BY TEMP.VO1_FUNABE "
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasVO1, .F., .T.)

		Do While !(cAliasVO1)->(Eof())
			nPos := FS_ADDVET((cAliasVO1)->(VO1_FUNABE), @aVetDia)

			aVetDia[1, 7]    += (cAliasVO1)->(QTDE) // Total
			aVetDia[nPos, 7] += (cAliasVO1)->(QTDE) // Linha Consultor

			(cAliasVO1)->(DbSkip())
		EndDo

		(cAliasVO1)->(dbCloseArea())

		IncProc(STR0048) // "Levantando OS's"

		// OS's VEICULOS ENTREGUES - DIA //
		cQuery := "SELECT VO1.VO1_FUNABE, COUNT(VO1.VO1_NUMOSV) AS QTDE "
		cQuery += "FROM " + RetSqlName("VO1") + " VO1 "
		cQuery += "WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_DATABE >= '" + dtos(dDtIni) + "' AND VO1.VO1_DATABE <= '" + dtos(dDtFinLc) + "' "
		cQuery += "  AND VO1.VO1_DATSAI = '" + dtos(dDtFinLc) + "' AND VO1.D_E_L_E_T_ = ' ' "
		cQuery += "GROUP BY VO1.VO1_FUNABE "
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasVO1, .F., .T.)

		Do While !(cAliasVO1)->(Eof())
			nPos := FS_ADDVET((cAliasVO1)->(VO1_FUNABE), @aVetDia)

			aVetDia[1, 8]    += (cAliasVO1)->(QTDE) // Total
			aVetDia[nPos, 8] += (cAliasVO1)->(QTDE) // Linha Consultor

			(cAliasVO1)->(DbSkip())
		EndDo

		(cAliasVO1)->(dbCloseArea())
	EndIf
	
	// OS's ABERTAS - PERIODO //
	cQuery := "SELECT VO1.VO1_FUNABE, COUNT(VO1.VO1_NUMOSV) AS QTDE "
	cQuery += "FROM " + RetSqlName("VO1") + " VO1 WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_DATABE >= '" + dtos(dDtIni) + "' "
	cQuery += "  AND VO1.VO1_DATABE <= '" + dtos(dDtF) + "' AND VO1.D_E_L_E_T_ = ' ' "
	cQuery += "GROUP BY VO1.VO1_FUNABE "
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasVO1, .F., .T.)

	Do While !(cAliasVO1)->(Eof())
		nPos := FS_ADDVET((cAliasVO1)->(VO1_FUNABE), @aVetPer)

		aVetPer[1, 3]    += (cAliasVO1)->(QTDE) // Total
		aVetPer[nPos, 3] += (cAliasVO1)->(QTDE) // Linha Consultor

		(cAliasVO1)->(DbSkip())
	EndDo

	(cAliasVO1)->(dbCloseArea())

	IncProc(STR0048) // "Levantando OS's"

	// OS's DISPONIVEIS - PERIODO //
	cQuery := "SELECT TEMP.VO1_FUNABE, COUNT(*) AS QTDE FROM ( "
	cQuery += "  SELECT DISTINCT VO1.VO1_FUNABE, VO1.VO1_NUMOSV AS NUMOSV, VO3.VO3_TIPTEM AS TIPTEM "
	cQuery += "  FROM " + RetSqlName("VO1") + " VO1, " + RetSqlName("VO2") + " VO2, " + RetSqlName("VO3") + " VO3 "
	cQuery += "  WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_STATUS = 'D' AND VO1.VO1_DATABE >= '" + dtos(dDtIni) + "' "
	cQuery += "    AND VO1.VO1_DATABE <= '" + dtos(dDtF) + "' AND VO2.VO2_FILIAL = VO1.VO1_FILIAL AND VO1.VO1_NUMOSV =VO2.VO2_NUMOSV "
	cQuery += "    AND VO3.VO3_FILIAL = VO1.VO1_FILIAL AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM AND VO3.VO3_DATDIS >= '" + dtos(dDtIni) + "' "
	cQuery += "    AND VO3.VO3_DATDIS <= '" + dtos(dDtF) + "' AND VO3.VO3_DATCAN = '" + space(8) +"' AND VO3.VO3_DATFEC = '" + space(8) + "' "
	cQuery += "    AND VO1.D_E_L_E_T_ = ' ' AND VO2.D_E_L_E_T_ = ' ' AND VO3.D_E_L_E_T_ = ' ' "
	cQuery += "  UNION "
	cQuery += "  SELECT DISTINCT VO1.VO1_FUNABE, VO1.VO1_NUMOSV AS NUMOSV, VO4.VO4_TIPTEM AS TIPTEM "
	cQuery += "  FROM " + RetSqlName("VO1") + " VO1, " + RetSqlName("VO2") + " VO2, " + RetSqlName("VO4") + " VO4 "
	cQuery += "  WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_STATUS = 'D' AND VO1.VO1_DATABE >= '" + dtos(dDtIni) + "' "
	cQuery += "    AND VO1.VO1_DATABE <= '" + dtos(dDtF) + "' AND VO2.VO2_FILIAL = VO1.VO1_FILIAL AND VO1.VO1_NUMOSV = VO2.VO2_NUMOSV "
	cQuery += "    AND VO4.VO4_FILIAL = VO1.VO1_FILIAL AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM AND VO4.VO4_DATDIS >= '" + dtos(dDtIni) + "' "
	cQuery += "    AND VO4.VO4_DATDIS <= '" + dtos(dDtF) + "' AND VO4.VO4_DATCAN = '" + space(8) + "' AND VO4.VO4_DATFEC = '" + space(8) + "' "
	cQuery += "    AND VO1.D_E_L_E_T_ = ' ' AND VO2.D_E_L_E_T_ = ' ' AND VO4.D_E_L_E_T_ = ' ' "
	cQuery += ") TEMP GROUP BY TEMP.VO1_FUNABE "
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasVO1, .F., .T.)

	Do While !(cAliasVO1)->(Eof())
		nPos := FS_ADDVET((cAliasVO1)->(VO1_FUNABE), @aVetPer)

		aVetPer[1, 4]    += (cAliasVO1)->(QTDE) // Total
		aVetPer[nPos, 4] += (cAliasVO1)->(QTDE) // Linha Consultor

		(cAliasVO1)->(DbSkip())
	EndDo

	(cAliasVO1)->(dbCloseArea())

	IncProc(STR0048) // "Levantando OS's"

	// OS's CANCELADAS - PERIODO //
	cQuery := "SELECT TEMP.VO1_FUNABE, COUNT(*) AS QTDE FROM ( "
	cQuery += "  SELECT DISTINCT VO1.VO1_FUNABE, VO1.VO1_NUMOSV AS NUMOSV, VO3.VO3_TIPTEM AS TIPTEM "
	cQuery += "  FROM " + RetSqlName("VO1") + " VO1, " + RetSqlName("VO2") + " VO2, " + RetSqlName("VO3") + " VO3 "
	cQuery += "  WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_STATUS = 'C' AND VO1.VO1_DATABE >= '" + dtos(dDtIni) + "' "
	cQuery += "    AND VO1.VO1_DATABE <= '" + dtos(dDtF) + "' AND VO2.VO2_FILIAL = VO1.VO1_FILIAL AND VO1.VO1_NUMOSV = VO2.VO2_NUMOSV "
	cQuery += "    AND VO3.VO3_FILIAL = VO1.VO1_FILIAL AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM AND VO3.VO3_DATCAN >= '" + dtos(dDtIni) + "' "
	cQuery += "    AND VO3.VO3_DATCAN <= '" + dtos(dDtF) + "' AND VO1.D_E_L_E_T_ = ' ' AND VO2.D_E_L_E_T_ = ' ' AND VO3.D_E_L_E_T_ = ' ' "
	cQuery += "  UNION "
	cQuery += "  SELECT DISTINCT VO1.VO1_FUNABE, VO1.VO1_NUMOSV AS NUMOSV, VO4.VO4_TIPTEM AS TIPTEM "
	cQuery += "  FROM " + RetSqlName("VO1") + " VO1, " + RetSqlName("VO2") + " VO2, " + RetSqlName("VO4") + " VO4 "
	cQuery += "  WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_STATUS = 'C' AND VO1.VO1_DATABE >= '" + dtos(dDtIni) + "' "
	cQuery += "    AND VO1.VO1_DATABE <= '" + dtos(dDtF) + "' AND VO2.VO2_FILIAL = VO1.VO1_FILIAL AND VO1.VO1_NUMOSV = VO2.VO2_NUMOSV "
	cQuery += "    AND VO4.VO4_FILIAL = VO1.VO1_FILIAL AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM AND VO4.VO4_DATCAN >= '" + dtos(dDtIni) + "' "
	cQuery += "    AND VO4.VO4_DATCAN <= '" + dtos(dDtF) + "' AND VO1.D_E_L_E_T_ = ' ' AND VO2.D_E_L_E_T_ = ' ' AND VO4.D_E_L_E_T_ = ' ' "
	cQuery += ") TEMP GROUP BY TEMP.VO1_FUNABE "
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasVO1, .F., .T.)

	Do While !(cAliasVO1)->(Eof())
		nPos := FS_ADDVET((cAliasVO1)->(VO1_FUNABE), @aVetPer)

		aVetPer[1, 5]    += (cAliasVO1)->(QTDE) // Total
		aVetPer[nPos, 5] += (cAliasVO1)->(QTDE) // Linha Consultor

		(cAliasVO1)->(DbSkip())
	EndDo

	(cAliasVO1)->(dbCloseArea())

	IncProc(STR0048) // "Levantando OS's"

	// OS's FECHADAS - PERIODO //
	cQuery := "SELECT TEMP.VO1_FUNABE, COUNT(*) AS QTDE FROM ( "
	cQuery += "  SELECT DISTINCT VO1.VO1_FUNABE, VO1.VO1_NUMOSV AS NUMOSV, VO3.VO3_TIPTEM AS TIPTEM "
	cQuery += "  FROM " + RetSqlName("VO1") + " VO1, " + RetSqlName("VO2") + " VO2, " + RetSqlName("VO3") + " VO3 "
	cQuery += "  WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_STATUS = 'F' AND VO2.VO2_FILIAL = VO1.VO1_FILIAL "
	cQuery += "    AND VO2.VO2_NUMOSV = VO1.VO1_NUMOSV AND VO3.VO3_FILIAL = VO1.VO1_FILIAL AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM "
	cQuery += "    AND VO3.VO3_DATCAN = '" + space(8) + "' AND VO3.VO3_DATFEC >= '" + dtos(dDtIni) + "' AND VO3.VO3_DATFEC <= '" + dtos(dDtF) + "' "
	cQuery += "    AND VO1.D_E_L_E_T_ = ' ' AND VO2.D_E_L_E_T_ = ' ' AND VO3.D_E_L_E_T_ = ' ' "
	cQuery += "  UNION "
	cQuery += "  SELECT DISTINCT VO1.VO1_FUNABE, VO1.VO1_NUMOSV AS NUMOSV, VO4.VO4_TIPTEM AS TIPTEM "
	cQuery += "  FROM " + RetSqlName("VO1") + " VO1, " + RetSqlName("VO2") + " VO2, " + RetSqlName("VO4") + " VO4 "
	cQuery += "  WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_STATUS = 'F' AND VO2.VO2_FILIAL = VO1.VO1_FILIAL "
	cQuery += "    AND VO2.VO2_NUMOSV = VO1.VO1_NUMOSV AND VO4.VO4_FILIAL = VO1.VO1_FILIAL AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM "
	cQuery += "    AND VO4.VO4_DATCAN = '" + space(8) + "' AND VO4.VO4_DATFEC >= '" + dtos(dDtIni) + "' AND VO4.VO4_DATFEC <= '" + dtos(dDtF) + "' "
	cQuery += "    AND VO1.D_E_L_E_T_ = ' ' AND VO2.D_E_L_E_T_ = ' ' AND VO4.D_E_L_E_T_ = ' ' "
	cQuery += ") TEMP GROUP BY TEMP.VO1_FUNABE "
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasVO1, .F., .T.)

	Do While !(cAliasVO1)->(Eof())
		nPos := FS_ADDVET((cAliasVO1)->(VO1_FUNABE), @aVetPer)

		aVetPer[1, 6]    += (cAliasVO1)->(QTDE) // Total
		aVetPer[nPos, 6] += (cAliasVO1)->(QTDE) // Linha Consultor

		(cAliasVO1)->(DbSkip())
	EndDo

	(cAliasVO1)->(dbCloseArea())

	IncProc(STR0048) // "Levantando OS's"

	// OS's EM ANDAMENTO - PERIODO //
	cQuery := "SELECT TEMP.VO1_FUNABE, COUNT(*) AS QTDE FROM ( "
	cQuery += "  SELECT DISTINCT VO1.VO1_FUNABE, VO1.VO1_NUMOSV, VO4.VO4_TIPTEM "
	cQuery += "  FROM " + RetSqlName("VO1") + " VO1, " + RetSqlName("VO4") + " VO4 "
	cQuery += "  WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_DATABE >= '" + dtos(dDtIni) + "' AND VO1.VO1_DATABE <= '" + dtos(dDtF) + "' "
	cQuery += "    AND VO4.VO4_FILIAL = VO1.VO1_FILIAL AND VO4.VO4_NUMOSV = VO1.VO1_NUMOSV AND VO4.VO4_DATCAN = '" + space(8) + "' "
	cQuery += "    AND VO4.VO4_DATFEC = '" + space(8) + "' AND VO4.VO4_DATINI >= '" + dtos(dDtIni) + "' AND VO4.VO4_DATINI <= '" + dtos(dDtF) + "' "
	cQuery += "    AND VO4.VO4_DATFIN = '" + space(8) + "' AND VO1.D_E_L_E_T_ = ' ' AND VO4.D_E_L_E_T_ = ' ' "
	cQuery += ") TEMP GROUP BY TEMP.VO1_FUNABE "
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasVO1, .F., .T.)

	Do While !(cAliasVO1)->(Eof())
		nPos := FS_ADDVET((cAliasVO1)->(VO1_FUNABE), @aVetPer)

		aVetPer[1, 7]    += (cAliasVO1)->(QTDE) // Total
		aVetPer[nPos, 7] += (cAliasVO1)->(QTDE) // Linha Consultor

		(cAliasVO1)->(DbSkip())
	EndDo

	(cAliasVO1)->(dbCloseArea())

	IncProc(STR0048) // "Levantando OS's"

	// OS's VEICULOS ENTREGUES - PERIODO //
	cQuery := "SELECT VO1.VO1_FUNABE, COUNT(VO1.VO1_NUMOSV) AS QTDE "
	cQuery += "FROM " + RetSqlName("VO1") + " VO1 "
	cQuery += "WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_DATABE >= '" + dtos(dDtIni) + "' AND VO1.VO1_DATABE <= '" + dtos(dDtF) + "' "
	cQuery += "  AND VO1.VO1_DATSAI >= '" + dtos(dDtIni) + "' AND VO1.VO1_DATSAI <= '" + dtos(dDtF) + "' AND VO1.D_E_L_E_T_ = ' ' "
	cQuery += "GROUP BY VO1.VO1_FUNABE "
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasVO1, .F., .T.)

	Do While !(cAliasVO1)->(Eof())
		nPos := FS_ADDVET((cAliasVO1)->(VO1_FUNABE), @aVetPer)

		aVetPer[1, 8]    += (cAliasVO1)->(QTDE) // Total
		aVetPer[nPos, 8] += (cAliasVO1)->(QTDE) // Linha Consultor

		(cAliasVO1)->(DbSkip())
	EndDo

	(cAliasVO1)->(dbCloseArea())

	IncProc(STR0048) // "Levantando OS's"

	// OS's ATRASADAS - PERIODO //
	cQuery := "SELECT VO1.VO1_FUNABE, COUNT(VO1.VO1_NUMOSV) AS QTDE "
	cQuery += "FROM " + RetSqlName("VO1") + " VO1 "
	cQuery += "WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_DATABE >= '" + DtoS(dDtIni) + "' AND VO1.VO1_DATABE <= '" + DtoS(dDtF) + "' "
	cQuery += "  AND VO1.VO1_STATUS IN('A','D') AND VO1.VO1_DATENT <>'" + space(6) + "' AND VO1.VO1_DATENT < '" + DtoS(dDataBase) + "' "
	cQuery += "  AND VO1.D_E_L_E_T_ = ' '"
	cQuery += "GROUP BY VO1.VO1_FUNABE "
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasVO1, .F., .T.)

	Do While !(cAliasVO1)->(Eof())
		nPos := FS_ADDVET((cAliasVO1)->(VO1_FUNABE), @aVetPer)

		aVetPer[1, 9]    += (cAliasVO1)->(QTDE) // Total
		aVetPer[nPos, 9] += (cAliasVO1)->(QTDE) // Linha Consultor

		(cAliasVO1)->(DbSkip())
	EndDo

	(cAliasVO1)->(dbCloseArea())

	DbSelectArea("VO1")
Next

lVetDia := .t.

cFilAnt := cFilSALVA

DEFINE MSDIALOG oAnalitOS FROM 000,000 TO 031,111 TITLE (STR0001 + " - " + STR0064) OF oMainWnd // "Consulta Oficina" / "Consultores"
@ 006,001 TO 105,438 LABEL (" " + STR0023 + " (" + Transform(dDataBase, "@D") + ") ") OF oAnalitOS PIXEL // "No Dia"
@ 111,001 TO 210,438 LABEL (" " + STR0095) OF oAnalitOS PIXEL // "No Periodo"
@ 013,004 LISTBOX oLbFatDia FIELDS HEADER;
	STR0064,                             ; // "Consultores"
	STR0073,                             ; // "Abertas"
	STR0045,                             ; // "Liberadas"
	STR0046,                             ; // "Canceladas"
	STR0047,                             ; // "Fechadas"
	STR0074,                             ; // "Em Andamento"
	STR0075                              ;  // "Veiculos Entregues"
	COLSIZES 90, 55, 55, 55, 55, 55, 55  ;
	SIZE 431,089 OF oAnalitOS PIXEL

oLbFatDia:SetArray(aVetDia)
oLbFatDia:bLine := { || { aVetDia[oLbFatDia:nAt, 1] + IIf(oLbFatDia:nAt <> 1, " - ", " ") + aVetDia[oLbFatDia:nAt, 2],;
	FG_AlinVlrs(Transform(aVetDia[oLbFatDia:nAt, 3], "@E 99,999,999")),                                                 ;
	FG_AlinVlrs(Transform(aVetDia[oLbFatDia:nAt, 4], "@E 99,999,999")),                                                 ;
	FG_AlinVlrs(Transform(aVetDia[oLbFatDia:nAt, 5], "@E 99,999,999")),                                                 ;
	FG_AlinVlrs(Transform(aVetDia[oLbFatDia:nAt, 6], "@E 99,999,999")),                                                 ;
	FG_AlinVlrs(Transform(aVetDia[oLbFatDia:nAt, 7], "@E 99,999,999")),                                                 ;
	FG_AlinVlrs(Transform(aVetDia[oLbFatDia:nAt, 8], "@E 99,999,999")) }}
							
@ 118,004 LISTBOX oLbFatMes FIELDS HEADER STR0064, STR0073, STR0045, STR0046, STR0047, STR0074, STR0075, STR0080; // "Consultores" / "Abertas" / "Liberadas" / "Canceladas" / "Fechadas" / "Em Andamento" / "Veiculos Entregues" / "Atrasadas"
	COLSIZES 90, 45, 45, 45, 45, 45, 50, 45 SIZE 431,089 OF oAnalitOS PIXEL

oLbFatMes:SetArray(aVetPer)
oLbFatMes:bLine := { || { aVetPer[oLbFatMes:nAt, 1] + IIf(oLbFatMes:nAt <> 1, " - ", " ") + aVetPer[oLbFatMes:nAt, 2],;
	FG_AlinVlrs(Transform(aVetPer[oLbFatMes:nAt, 3], "@E 99,999,999")),                                                 ;
	FG_AlinVlrs(Transform(aVetPer[oLbFatMes:nAt, 4], "@E 99,999,999")),                                                 ;
	FG_AlinVlrs(Transform(aVetPer[oLbFatMes:nAt, 5], "@E 99,999,999")),                                                 ;
	FG_AlinVlrs(Transform(aVetPer[oLbFatMes:nAt, 6], "@E 99,999,999")),                                                 ;
	FG_AlinVlrs(Transform(aVetPer[oLbFatMes:nAt, 7], "@E 99,999,999")),                                                 ;
	FG_AlinVlrs(Transform(aVetPer[oLbFatMes:nAt, 8], "@E 99,999,999")),                                                 ;
	FG_AlinVlrs(Transform(aVetPer[oLbFatMes:nAt, 9], "@E 99,999,999")) }}

@ 222,389 BUTTON oSair PROMPT STR0029 OF oAnalitOS SIZE 45,10 PIXEL ACTION oAnalitOS:End() // "< SAIR >"

ACTIVATE MSDIALOG oAnalitOS CENTER
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FS_ADDVET  บAutor  ณMicrosiga         บ Data ณ  01/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Procura/Adiciona linha no vetor de enviado como parametro  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FS_CONSULT                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ADDVET(cFunAbe, aVetRel)
Local nPos    := aScan(aVetRel, {|x| x[1] == cFunAbe })
Local cNomTec := ""

If nPos == 0
	VAI->(dbSetOrder(1))
	If VAI->(dbSeek(xFilial("VAI") + cFunAbe))
		cNomTec := VAI->VAI_NOMTEC
	EndIf

	aadd(aVetRel, { cFunAbe, cNomTec, 0, 0, 0, 0, 0, 0, 0 })

	nPos := len(aVetRel)
EndIf
Return nPos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FS_ANALOS  บAutor  ณMicrosiga         บ Data ณ  01/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Analitico por ordem de servico                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ANALOS(nLinha, nColuna)
Local ni        := 0
Local nj        := 0
Local cFilSALVA := cFilAnt
Local cQuebra   := "INICIAL"
Local cSelLin   := ""
Local nTotal    := 0
Local nTam      := 0
Local lAtrasada

Local cSQLVO1  := "SQLVO1"
Local cQuery   := ""
Local cCompara := ""

Private oVerde   := LoadBitmap(GetResources(), "BR_verde")    //Aberto
Private oVermelho:= LoadBitmap(GetResources(), "BR_vermelho") //Fechada
Private oAzul    := LoadBitmap(GetResources(), "BR_azul")     //Liberada
Private oPreto   := LoadBitmap(GetResources(), "BR_PRETO")    //Cancelada
Private oLaranja := LoadBitmap(GetResources(), "BR_LARANJA")  //Atrasada
Private obranco  := LoadBitmap(GetResources(), "BR_branco")   //todos

Private aRotina := {{ "", "axPesqui", 0, 1},; // Pesquisar
					{ "", "OC060"   , 0, 2}}  // Visualizar
Private cCadastro := OemToAnsi(STR0052) // Consulta OS
Private cCampo, nOpc := 2, inclui := .f.
Private aVetOS := {}

If nColuna <= 1
	MsgInfo(STR0082, STR0011) //Clicar no valor que deseja vizualizar analiticamente. # Atencao
	Return
EndIF

lAtrasada := .f.
If nLinha == 1 //todos
	cSelLin := ""
ElseIf nLinha == 2 // Em Aberto
	cSelLin := "A"
ElseIf nLinha == 3 // Liberadas
	cSelLin := "D"
ElseIf nLinha == 4 // Canceladas
	cSelLin := "C"
ElseIf nLinha == 5 // Fechadas
	cSelLin := "F"
ElseIf nLinha == 6 // Atrasadas
	cSelLin   := ""
	lAtrasada := .t.
EndIf

ProcRegua((len(aAnalOS) / 100) + 1)

aSort(aAnalOS,,, {|x, y| x[3] + x[4] < y[3] + y[4]})

For ni := 1 to len(aAnalOS)
	nj++

	If nj == 100
		IncProc(STR0053) // "Analitico"
		nj := 0
	EndIf

	If (Empty(cSelLin) .or. cSelLin $ aAnalOS[ni, 1]) .and. aAnalOS[ni, 2] == Alltrim(str(nColuna)) .and. (!lAtrasada .or. (lAtrasada .and. aAnalOS[ni, 5]))
		cFilAnt := aAnalOS[ni, 3] //Filial

		cQuery := "SELECT VO1.VO1_FILIAL, VO1.VO1_NUMOSV, VO1.VO1_DATABE, VO1.VO1_FUNABE, VV1.VV1_PLAVEI, VV1.VV1_CODMAR, "
		cQuery += "       VV1.VV1_CHASSI, VV1.VV1_PROATU, VV1.VV1_LJPATU, VV2.VV2_DESMOD, SA1.A1_NOME, VAI.VAI_NOMTEC "
		cQuery += "FROM " + RetSqlName("VO1") + " VO1 "
		cQuery += "INNER JOIN " + RetSqlName("VV1") + " VV1 ON VV1.VV1_FILIAL = '" + xFilial("VV1") + "' AND VV1.VV1_CHAINT = VO1.VO1_CHAINT AND VV1.D_E_L_E_T_ = ' ' "
		cQuery += "INNER JOIN " + RetSqlName("VV2") + " VV2 ON VV2.VV2_FILIAL = '" + xFilial("VV2") + "' AND VV2.VV2_CODMAR = VV1.VV1_CODMAR "
		cQuery += "  AND VV2.VV2_MODVEI = VV1.VV1_MODVEI AND VV2.D_E_L_E_T_ = ' ' "
		cQuery += "INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_COD = VV1.VV1_PROATU "
		cQuery += "  AND SA1.A1_LOJA = VV1.VV1_LJPATU AND SA1.D_E_L_E_T_ = ' ' "
		cQuery += "INNER JOIN " + RetSqlName("VAI") + " VAI ON VAI.VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI.VAI_CODTEC = VO1.VO1_FUNABE AND VAI.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_NUMOSV = '" + aAnalOS[ni, 4] + "' AND VO1.D_E_L_E_T_ = ' ' "
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLVO1, .F., .T.)

		If !(cSQLVO1)->(Eof())
			cCompara := (cSQLVO1)->(VO1_FILIAL) + (cSQLVO1)->(VO1_NUMOSV) //NUMOSV
			If cQuebra <> cCompara
				cQuebra := cCompara

				aadd(aVetOS, { aAnalOS[ni, 1], aAnalOS[ni, 5], aAnalOS[ni, 2], aAnalOS[ni, 3], aAnalOS[ni, 4], SToD((cSQLVO1)->(VO1_DATABE)),             ;
					(cSQLVO1)->(VO1_FUNABE) + "-" + left((cSQLVO1)->(VAI_NOMTEC), 15), Transform((cSQLVO1)->(VV1_PLAVEI), VV1->(X3PICTURE("VV1_PLAVEI"))),;
					(cSQLVO1)->(VV1_CODMAR) + " " + left((cSQLVO1)->(VV2_DESMOD), 20), (cSQLVO1)->(VV1_CHASSI),                                           ;
					(cSQLVO1)->(VV1_PROATU) + "-" + (cSQLVO1)->(VV1_LJPATU) + " " + left((cSQLVO1)->(A1_NOME), 25) })
			EndIf
		EndIf

		(cSQLVO1)->(dbCloseArea())

		DbSelectArea("VO1")
	EndIf
Next

cFilAnt := cFilSALVA

If len(aVetOS) > 0
	aSort(aVetOS,,, {|x, y| x[1] + x[3] < y[1] + y[3]})
Else
	aadd(aVetOS, { "", .f., "", "", "", "", "", "", "", "", "" })
EndIf

For ni := 1 to len(aVetOS)
	nTotal := nTotal + 1
Next

DEFINE MSDIALOG oAnalitOS FROM 000,000 TO 031,111 TITLE (STR0017) OF oMainWnd //ORDEM DE SERVICO
@ 001,001 LISTBOX oLbAnalOS FIELDS HEADER   ;
	"",                                     ;
	"",                                     ;
	STR0054,                                ; // "Filial"
	STR0055,                                ; // "OS"
	STR0056,                                ; // "Abertura"
	STR0057,                                ; // "Consultor"
	STR0058,                                ; // "Placa"
	STR0059,                                ; // "Veiculo"
	STR0060,                                ; // "Chassi"
	STR0061                                 ; // "Proprietario"
	COLSIZES 14, 14, 27, 27, 27, 80, 55, 110;
	SIZE 437,217 OF oAnalitOS PIXEL         ;
	ON DBLCLICK FS_CONSOS(aVetOS[oLbAnalOS:nAt, 4], aVetOS[oLbAnalOS:nAt, 5])

oLbAnalOS:SetArray(aVetOS)
oLbAnalOS:bLine := { || { Iif(left(Alltrim(aVetOS[oLbAnalOS:nAt, 1]), 1) == "A", oVerde,;
	IIf(aVetOS[oLbAnalOS:nAt, 1] == "C", oPreto,                                        ;
	Iif(left(Alltrim(aVetOS[oLbAnalOS:nAt, 1]), 1) == "D", oAzul,                       ;
	Iif(aVetOS[oLbAnalOS:nAt, 1] == "F", oVermelho,                                     ;
	Iif(aVetOS[oLbAnalOS:nAt, 1] == "AY", oBranco, oBranco))))),                        ;
	Iif(aVetOS[oLbAnalOS:nAt, 2], oLaranja, obranco),                                   ;
	aVetOS[oLbAnalOS:nAt, 4],                                                           ;
	aVetOS[oLbAnalOS:nAt, 5],                                                           ;
	aVetOS[oLbAnalOS:nAt, 6],                                                           ;
	aVetOS[oLbAnalOS:nAt, 7],                                                           ;
	aVetOS[oLbAnalOS:nAt, 8],                                                           ;
	aVetOS[oLbAnalOS:nAt, 9],                                                           ;
	aVetOS[oLbAnalOS:nAt, 10],                                                          ;
	aVetOS[oLbAnalOS:nAt, 11] }}

nTam:= 3

//legenda
@ 220,007 TO 232,199 LABEL ("") OF oAnalitOS PIXEL
@ 222,007 + nTam BITMAP oxVerde RESOURCE "BR_VERDE" OF oAnalitOS NOBORDER SIZE 10,10 PIXEL
@ 222,017 + nTam SAY STR0089 SIZE 70,08 OF oAnalitOS PIXEL COLOR CLR_BLACK // "Aberta"
@ 222,055 + nTam BITMAP oxVerme RESOURCE "BR_VERMELHO" OF oAnalitOS NOBORDER SIZE 10,10 PIXEL
@ 222,065 + nTam SAY STR0090 SIZE 70,08 OF oAnalitOS PIXEL COLOR CLR_BLACK // "Fechada"
@ 222,103 + nTam BITMAP oxAzul RESOURCE "BR_AZUL" OF oAnalitOS NOBORDER SIZE 10,10 PIXEL
@ 222,113 + nTam SAY STR0091 SIZE 70,08 OF oAnalitOS PIXEL COLOR CLR_BLACK // "Liberada"
@ 222,151 + nTam BITMAP oxVerme RESOURCE "BR_PRETO" OF oAnalitOS NOBORDER SIZE 10,10 PIXEL
@ 222,161 + nTam SAY STR0092 SIZE 70,08 OF oAnalitOS PIXEL COLOR CLR_BLACK // "Cancelada"

@ 220,201 TO 232,297 LABEL ("") OF oAnalitOS PIXEL
@ 222,201 + nTam BITMAP oxLaran RESOURCE "BR_LARANJA" OF oAnalitOS NOBORDER SIZE 10,10 PIXEL
@ 222,211 + nTam SAY STR0093 SIZE 70,08 OF oAnalitOS PIXEL COLOR CLR_BLACK // "Atrasada"
@ 222,249 + nTam BITMAP oxBranco RESOURCE "BR_BRANCO" OF oAnalitOS NOBORDER SIZE 10,10 PIXEL
@ 222,259 + nTam SAY STR0094 SIZE 70,08 OF oAnalitOS PIXEL COLOR CLR_BLACK // "Em Dia"

@ 221,320 BUTTON oConsOS PROMPT STR0088 OF oAnalitOS SIZE 65,10 PIXEL ACTION FS_CONSOS(aVetOS[oLbAnalOS:nAt, 4], aVetOS[oLbAnalOS:nAt, 5]) // < VISUALIZAR OS>
@ 221,389 BUTTON oSair PROMPT STR0029 OF oAnalitOS SIZE 45,10 PIXEL ACTION oAnalitOS:End() // "< SAIR >"

ACTIVATE MSDIALOG oAnalitOS CENTER

cFilAnt := cFilSALVA
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FS_ATUDT   บAutor  ณRubens Takahashi  บ Data ณ  22/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a data inicial e final a ser utilizada nas        บฑฑ
ฑฑบ          ณ consultas                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ATUDT()
// Calcula Data Inicial e Final para Processamento
If cFilDias == aFilDias[1] // "Do Mes"
	dDtFin := dDataBase
	dDtIni := (dDtFin - day(dDtFin)) + 1
ElseIf cFilDias == STR0003 // "Ultimos 30 dias"
	dDtFin := dDataBase
	dDtIni := dDtFin - 30
ElseIf cFilDias == STR0004 // "Ultimos 90 dias"
	dDtFin := dDataBase
	dDtIni := dDtFin - 90
ElseIf cFilDias == STR0005 // "Ultimos 180 dias"
	dDtFin := dDataBase
	dDtIni := dDtFin - 180
ElseIf cFilDias == STR0006 // "Ultimos 365 dias"
	dDtFin := dDataBase
	dDtIni := dDtFin - 365
ElseIf cFilDias == STR0007 // "Ultimos 2 anos"
	dDtFin := dDataBase
	dDtIni := dDtFin - (365 * 2)
ElseIf cFilDias == STR0008 // "Ultimos 3 anos"
	dDtFin := dDataBase
	dDtIni := dDtFin - (365 * 3)
ElseIf cFilDias == STR0009 // "Total"
	dDtIni := StoD(FM_SQL("SELECT MIN(VO1_DATABE) FROM " + RetSQLName("VO1") + " WHERE D_E_L_E_T_ = ' '"))
	dDtFin := dDataBase
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OFIOC39001 บAutor  ณ Vinicius Gati    บ Data ณ  24/02/17   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Formata valor para apresentacao em listbox                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OFIOC39001_FmtValor(nValor)
Return FG_AlinVlrs(Transform(nValor, "@E 999,999,999,999.99"))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OFIOC39002 บAutor  ณ Vinicius Gati    บ Data ณ  24/02/17   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Formata valor de percentual para apresentacao no listbox   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OFIOC39002_FmtPercentual(nValor)
Return FG_AlinVlrs(Transform(nValor, "@E 999999999999999.99 %"))

/*/{Protheus.doc} OFC3900016_InicializacaoVariaveisGridbox
Inicializa็ใo das variแveis usadas nas gridbox's da tela
@author Fernando Vitor Cavani
@since 01/04/2019
@version undefined
@poaram nx, num้rico, N๚mero de Chamadas da fun็ใo
@type function
/*/
Function OFC3900016_InicializacaoVariaveisGridbox(nx)
Local ni   :=0
Local nPos := 0

If nx == 0
	aAnalOS := {} // Analitico por Ordem de Servico - Matriz com as OS's a serem exibidas quando clicar no listbox de "Ordem de servi็o: Abertas"
	// [1] - Status da OS
	// [2] - Numero da Coluna (Usado para filtrar as OS's a serem exibidas) - 2 = No dia / 3 = No mes / 4 = Do levantamento
	// [3] - Filial da OS
	// [4] - Numero da OS
	// [5] - OS atrasada ( LOGICO )

	aAnalit := {} // Analitico - Matriz com as OS's a serem exibidas quando clicar no listbox "Oficina"
	// [1] - Filial da OS
	// [2] - Numero da OS
	// [3] - Tipo de Tempo
	// [4] - Linha a qual pertence na relacao, sera relacionada com a linha que foi clicada na Listbox de Oficina ( aSrvOfi )
	// [5] - Indica se pertenca a Coluna "Em Andamento"
	// [6] - Indica se pertenca a Coluna "Faturamento Pendente"
	// [7] - Indica se pertenca a Coluna "Faturadas no Dia"
	// [8] - Indica se pertenca a Coluna "Faturadas no Mes"
	// [9] - Indica se pertenca a Coluna "Faturadas Periodo"

	aSrvOfi := {}
	// [1] - Descricao que sera exibida na tela
	// [2] - Em Andamento
	// [3] - Faturamento Pendente
	// [4] - Faturadas Dia
	// [5] - Faturadas no Mes
	// [6] - Faturadas no Periodo

	aFatDia := {} // Utilizada para exibir faturamento do Dia BOTAO "Faturamento Dia / Mes"
	// [1] - Descricao que sera exibida na tela
	// [2] - Qtde
	// [3] - Horas Trabalhadas
	// [4] - Horas Vendidas
	// [5] - Total de Servicos
	// [6] - Total de Pecas

	aFatPer := {} // Utilizada para exibir faturamento do Mes BOTAO "Faturamento Dia / Periodo"
	// [1] - Descricao que sera exibida na tela
	// [2] - Qtde
	// [3] - Horas Trabalhadas
	// [4] - Horas Vendidas
	// [5] - Total de Servicos
	// [6] - Total de Pecas

	aHrsOfi := {}

	aOSsOfi := {}
	// [1] - Descricao que sera exibida na tela
	// [2] - Total no Dia
	// [3] - Total no Mes
	// [4] - Total no Levantamento

	// Chamada Inicial - Incluir uma linha em branco em cada vetor
	Aadd(aSrvOfi, { space(ni), 0, 0, 0, 0, 0 }) // 1
	Aadd(aFatDia, { space(ni), 0, 0, 0, 0, 0 }) // 1
	Aadd(aFatPer, { space(ni), 0, 0, 0, 0, 0 }) // 1
	Aadd(aHrsOfi, { space(ni), 0, 0, 0 })       // 1
	Aadd(aOSsOfi, { space(ni), 0, 0, 0 })       // 1
Else
	aSrvOfi := {}
	Aadd(aSrvOfi, { space(ni) + STR0031, 0, 0, 0, 0, 0 })            // 1 "Total Geral"
	Aadd(aSrvOfi, { space(ni) + STR0032, 0, 0, 0, 0, 0 })            // 2 "Externas"
	Aadd(aSrvOfi, { space(ni + 3) + "- " + STR0033, 0, 0, 0, 0, 0 }) // 3    - "Cliente"
	Aadd(aSrvOfi, { space(ni + 3) + "- " + STR0034, 0, 0, 0, 0, 0 }) // 4    - "Seguradora"
	Aadd(aSrvOfi, { space(ni + 3) + "- " + STR0035, 0, 0, 0, 0, 0 }) // 5    - "Garantia"
	Aadd(aSrvOfi, { space(ni + 3) + "- " + STR0036, 0, 0, 0, 0, 0 }) // 6    - "Revisao"
	Aadd(aSrvOfi, { space(ni + 3) + "- " + STR0037, 0, 0, 0, 0, 0 }) // 7    - "Franquia"
	Aadd(aSrvOfi, { space(ni) + STR0038, 0, 0, 0, 0, 0 })            // 8 "Internas"

	aFatDia := {} // Utilizada para exibir faturamento do Dia BOTAO "Faturamento Dia / Mes"
	Aadd(aFatDia, { space(ni) + STR0031, 0, 0, 0, 0, 0 })            // 1 "Total Geral"
	Aadd(aFatDia, { space(ni) + STR0032, 0, 0, 0, 0, 0 })            // 2 "Externas"
	Aadd(aFatDia, { space(ni + 3) + "- " + STR0033, 0, 0, 0, 0, 0 }) // 3    - "Cliente"
	Aadd(aFatDia, { space(ni + 3) + "- " + STR0034, 0, 0, 0, 0, 0 }) // 4    - "Seguradora"
	Aadd(aFatDia, { space(ni + 3) + "- " + STR0035, 0, 0, 0, 0, 0 }) // 5    - "Garantia"
	Aadd(aFatDia, { space(ni + 3) + "- " + STR0036, 0, 0, 0, 0, 0 }) // 6    - "Revisao"
	Aadd(aFatDia, { space(ni + 3) + "- " + STR0037, 0, 0, 0, 0, 0 }) // 7    - "Franquia"
	Aadd(aFatDia, { space(ni) + STR0038, 0, 0, 0, 0, 0 })            // 8 "Internas"

	aFatPer := {} // Utilizada para exibir faturamento do Mes BOTAO "Faturamento Dia / Periodo"
	Aadd(aFatPer, { space(ni) + STR0031, 0, 0, 0, 0, 0 })            // 1 "Total Geral"
	Aadd(aFatPer, { space(ni) + STR0032, 0, 0, 0, 0, 0 })            // 2 "Externas"
	Aadd(aFatPer, { space(ni + 3) + "- " + STR0033, 0, 0, 0, 0, 0 }) // 3    - "Cliente"
	Aadd(aFatPer, { space(ni + 3) + "- " + STR0034, 0, 0, 0, 0, 0 }) // 4    - "Seguradora"
	Aadd(aFatPer, { space(ni + 3) + "- " + STR0035, 0, 0, 0, 0, 0 }) // 5    - "Garantia"
	Aadd(aFatPer, { space(ni + 3) + "- " + STR0036, 0, 0, 0, 0, 0 }) // 6    - "Revisao"
	Aadd(aFatPer, { space(ni + 3) + "- " + STR0037, 0, 0, 0, 0, 0 }) // 7    - "Franquia"
	Aadd(aFatPer, { space(ni) + STR0038, 0, 0, 0, 0, 0 })            // 8 "Internas"

	aHrsOfi := {}
	Aadd(aHrsOfi, { space(ni) + STR0039, 0, 0, 0 })            // 1 "Horas Disponiveis"
	Aadd(aHrsOfi, { space(ni + 3) + "- " + STR0101, 0, 0, 0 }) // 1 "   - Horas da Escala"
	Aadd(aHrsOfi, { space(ni + 3) + "- " + STR0102, 0, 0, 0 }) // 1 "   - Horas Ausentes"
	Aadd(aHrsOfi, { space(ni) + STR0040, 0, 0, 0 })            // 2 "Horas Trabalhadas"
	Aadd(aHrsOfi, { space(ni) + STR0041, 0, 0, 0 })            // 3 "Horas Vendidas"
	Aadd(aHrsOfi, { space(ni) + STR0042, 0, 0, 0 })            // 4 "Produtividade"
	Aadd(aHrsOfi, { space(ni) + STR0043, 0, 0, 0 })            // 5 "Eficiencia"

	aOSsOfi := {}
	Aadd(aOSsOfi, { space(ni) + STR0031, 0, 0, 0 }) // 1 Total Geral
	Aadd(aOSsOfi, { space(ni) + STR0044, 0, 0, 0 }) // 2 Em Aberto
	Aadd(aOSsOfi, { space(ni) + STR0045, 0, 0, 0 }) // 3 Liberadas
	Aadd(aOSsOfi, { space(ni) + STR0046, 0, 0, 0 }) // 4 Canceladas
	Aadd(aOSsOfi, { space(ni) + STR0047, 0, 0, 0 }) // 5 Fechadas
	Aadd(aOSsOfi, { space(ni) + STR0080, 0, 0, 0 }) // 6 Atrasadas
EndIf
Return .t.


/*/{Protheus.doc} OFC3900021_TREPORT_Analitico
Monta TReport para Impressao
@author Andre Luis Almeida
@since 11/07/2019
@version undefined
@poaram aVet
@type function
/*/
Function OFC3900021_TREPORT_Analitico(aVet)

Private aVetImp  := aClone(aVet)
Private cFilOSV  := ""
Private cNumOSV  := ""
Private cTipTpo  := ""
Private dDatAbe  := dDataBase
Private cConsult := ""
Private cPlaca   := ""
Private cVeiculo := ""
Private cChassi  := ""
Private cProprie := ""
Private nVlrTot  := 0
Private oReport

oReport := TReport():New("OFIOC390",STR0001,,{|oReport| OFC3900031_Imprimir(oReport)}) // Consulta Oficina

oSection1 := TRSection():New(oReport,STR0001,{"VO1"}) // Consulta Oficina

TRCell():New(oSection1,"", ,STR0054,"@!",20,, {|| cFilOSV  } ) // Filial
TRCell():New(oSection1,"", ,STR0055,"@!",30,, {|| cNumOSV  } ) // OS
TRCell():New(oSection1,"", ,STR0086,"@!",15,, {|| cTipTpo  } ) // TT
TRCell():New(oSection1,"", ,STR0056,"@D",20,, {|| dDatAbe  } ) // Abertura
TRCell():New(oSection1,"", ,STR0057,"@!",40,, {|| cConsult } ) // Consultor
TRCell():New(oSection1,"", ,STR0058,"@!",20,, {|| cPlaca   } ) // Placa
TRCell():New(oSection1,"", ,STR0059,"@!",35,, {|| cVeiculo } ) // Veiculo
TRCell():New(oSection1,"", ,STR0060,"@!",25,, {|| cChassi  } ) // Chassi
TRCell():New(oSection1,"", ,STR0061,"@!",35,, {|| cProprie } ) // Proprietario
TRCell():New(oSection1,"", ,STR0009,"@E 999,999,999.99",20,, {|| nVlrTot },,, "RIGHT" ) // Total

oReport:PrintDialog()

Return

/*/{Protheus.doc} OFC3900031_Imprimir
Impressao
@author Andre Luis Almeida
@since 11/07/2019
@version undefined
@type function
/*/
Function OFC3900031_Imprimir()
Local nCntFor := 0
Local oSection1 := oReport:Section(1)
oSection1:Init()
For nCntFor := 1 to len(aVetImp)
	cFilOSV  := aVetImp[nCntFor, 1]
	cNumOSV  := aVetImp[nCntFor, 2]
	cTipTpo  := aVetImp[nCntFor, 9]
	dDatAbe  := stod(aVetImp[nCntFor, 3])
	cConsult := aVetImp[nCntFor, 4]
	cPlaca   := aVetImp[nCntFor, 5]
	cVeiculo := aVetImp[nCntFor, 6]
	cChassi  := aVetImp[nCntFor, 7]
	cProprie := aVetImp[nCntFor, 8]
	nVlrTot  := Val(StrTran(StrTran(aVetImp[nCntFor, 10], '.', ''), ',', '.'))
	oSection1:PrintLine()
next
oSection1:Finish()
Return