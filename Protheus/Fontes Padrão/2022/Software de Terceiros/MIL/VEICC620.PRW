// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 11     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "VEICC620.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICC620 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 23/04/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ CEV - Agendas x Visitas                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICC620(cPAREmp,aPAREmp,dPARDtI,dPARDtF,cPARVen,cPARCCl,cPARLCl,cPARAna,cPARTip,nPARPer,cPARMet,cPARCPr,cPARLPr,cPARTCP,cPARCon,cPARSEGM)
Local lDClik    := .f.
Local aFWArrFilAtu := FWArrFilAtu()
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lVerOutros:= .t.
Private oVerdMet:= LoadBitmap( GetResources() , "BR_VERDE" )
Private oVermMet:= LoadBitmap( GetResources() , "BR_VERMELHO" )
Private lImprimir := .t.
Private lMarcar := .f.
Private aCliMet := {}
Private aVetEmp := {}
Private aEmpr   := {} // Empresas Consolidadas
Private cEmpr   := "" // Nome da Empresa
Private dDatIni := (dDataBase+1)-(day(dDataBase))
Private dDatFin := dDataBase
Private cVended := space(SA3->(TamSX3("A3_COD")[1]))
Private cCodCli := space(SA1->(TamSX3("A1_COD")[1]))
Private cLojCli := space(SA1->(TamSX3("A1_LOJA")[1]))
Private cCdPros := space(SUS->(TamSX3("US_COD")[1]))
Private cLjPros := space(SUS->(TamSX3("US_LOJA")[1]))
Private cVCFCon := ""
Private aVCFCon := X3CBOXAVET("VCF_CONDIC","1")
Private aCliPros:= {"1="+STR0002,"2="+STR0031} // Cliente / Prospect
Private cCliPros:= "1"
Private cAnalis := "2"
Private aAnalis := {"1="+STR0002,"2="+STR0003} // Cliente / Vendedor
Private cCEVTip := "4"
Private aCEVTip := {"1="+STR0008,"3="+STR0007,"4="+STR0009} // Servicos / Pecas / Veiculos
Private nPeriod := 0
Private cMetAti := ""
Private aMetAti := {"","0="+STR0025,"1="+STR0026} // Nao atingida / Atingida
Private lA1_SEGMER1   := ( SA1->(FieldPos("A1_SEGMER1")) > 0 )
Private M->A1_SEGMER1 := IIf(lA1_SEGMER1,space(TamSX3("A1_SEGMER1")[1]),"") // Campo customizado ( A1_SEGMER1 )
Default cPAREmp := ""
Default aPAREmp := aEmpr
Default dPARDtI := dDatIni
Default dPARDtF := dDatFin
Default cPARVen := cVended
Default cPARCCl := cCodCli
Default cPARLCl := cLojCli
Default cPARAna := cAnalis
Default cPARTip := cCEVTip
Default nPARPer := nPeriod
Default cPARMet := cMetAti
Default cPARCPr := cCdPros
Default cPARLPr := cLjPros
Default cPARTCP := cCliPros
Default cPARCon := cVCFCon
Default cPARSEGM := M->A1_SEGMER1
//
If VCF->(FieldPos("VCF_VENVEU")) > 0 // Possui campos novos
	aCEVTip := {"1="+STR0008,"3="+STR0007,"4="+STR0032,"5="+STR0033,"6="+STR0034,"7="+STR0035} // Servicos / Pecas / Veic.Novos / Veic.Usados / Pneus / Outros
EndIf
//
aEmpr := aPAREmp
If !Empty(cPAREmp)
	cEmpr := STR0004 //  - Consolidado: 
	aEmpr := FS_FILIAIS() // Levantamento das Filiais
	If len(aEmpr) == 0
		MsgAlert(STR0006,STR0005) // Nao existem dados para esta Consulta! / Atencao
		Return
	EndIf
Else
	aAdd(aEmpr,{ cFilAnt , aFWArrFilAtu[SM0_FILIAL] })
EndIf
If len(aEmpr) == 1 .and. (aEmpr[1,1]==cFilAnt)
	cEmpr := " - "+Alltrim(FWFilialName())+" ( "+cFilAnt+" )"
EndIf
dDatIni  := dPARDtI // Data Inicial
dDatFin  := dPARDtF // Data Final
cVended  := cPARVen // Vendedor
cCodCli  := cPARCCl // Codigo do Cliente
cLojCli  := cPARLCl // Loja do Cliente
cAnalis  := cPARAna // Analise por
cCEVTip  := cPARTip // Tipo
nPeriod  := nPARPer // Periodicidade
cMetAti  := cPARMet // Meta
cCdPros  := cPARCPr // Codigo do Prospect
cLjPros  := cPARLPr // Loja do Prospect
cCliPros := cPARTCP // Cliente/Prospect
cVCFCon  := cPARCon // Condicao VCF_CONDIC
M->A1_SEGMER1 := cPARSEGM // Campo Customizado Segmento A1_SEGMER1
//
VAI->(DbSetOrder(4))
VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
If ( VAI->(FieldPos("VAI_CEVOUT")) > 0 )
	If VAI->VAI_CEVOUT == "0" // Visualiza Agendas de Outros Usuarios do CEV? (1=Sim/0=Nao)
		cVended := VAI->VAI_CODVEN
   		lVerOutros := .f.
	EndIf
EndIf

aInfo := { aSizeHalf[ 1 ] , aSizeHalf[ 2 ] , aSizeHalf[ 3 ] , aSizeHalf[ 4 ] , 3 , 3 } // Tamanho total da tela
aAdd( aObjects, { 0 ,  40 , .T. , .F. } ) // Topo
aAdd( aObjects, { 0 , 100 , .T. , .T. } ) // ListBox 
aPos := MsObjSize( aInfo, aObjects )

Processa( {|| FS_LEVANT(0) } )

DbSelectArea("VC1")

DEFINE MSDIALOG oCEVAgeVis FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) PIXEL OF oMainWnd // CEV - Agendas x Visitas

If lA1_SEGMER1
	@ aPos[2,1]+000,aPos[2,2]+000 LISTBOX oLbCliMet FIELDS HEADER "",STR0018,STR0002,STR0003,STR0014,STR0020,STR0021,STR0029,RetTitle("VCF_CONDIC"),RetTitle("A1_SEGMER1") COLSIZES 10,80,100,90,50,50,50,70,70,70 SIZE aPos[2,4]-4,aPos[2,3]-aPos[2,1] OF oCEVAgeVis PIXEL ON DBLCLICK IIf(!Empty(aCliMet[oLbCliMet:nAt,2]),VEICC500(aCliMet[oLbCliMet:nAt,2],aCliMet[oLbCliMet:nAt,3],dDatIni,dDatFin),.t.)
	oLbCliMet:SetArray(aCliMet)
	oLbCliMet:bLine := { || { IIf(aCliMet[oLbCliMet:nAt,11],oVerdMet,oVermMet),;
							aCliMet[oLbCliMet:nAt,1]+" - "+aCliMet[oLbCliMet:nAt,12],;
							aCliMet[oLbCliMet:nAt,2]+"-"+aCliMet[oLbCliMet:nAt,3]+" "+aCliMet[oLbCliMet:nAt,9],;
							aCliMet[oLbCliMet:nAt,4]+" "+aCliMet[oLbCliMet:nAt,10],;
							FG_AlinVlrs(Transform(aCliMet[oLbCliMet:nAt,5],"@EZ 999,999")),;
							FG_AlinVlrs(Transform(aCliMet[oLbCliMet:nAt,6],"@E 999,999")),;
							FG_AlinVlrs(Transform(aCliMet[oLbCliMet:nAt,7],"@E 999,999"))+FG_AlinVlrs(Transform((aCliMet[oLbCliMet:nAt,7]/aCliMet[oLbCliMet:nAt,6])*100,"@E 99999")+"%"),; 
							aCliMet[oLbCliMet:nAt,13],;
							IIf(!Empty(aCliMet[oLbCliMet:nAt,14]),X3CBOXDESC("VCF_CONDIC",aCliMet[oLbCliMet:nAt,14]),""),;
							IIf(!Empty(aCliMet[oLbCliMet:nAt,15]),FM_SQL("SELECT VX5_DESCRI FROM "+RetSQLName("VX5")+" WHERE VX5_FILIAL='"+xFilial("VX5")+"' AND VX5_CHAVE='033' AND VX5_CODIGO='"+aCliMet[oLbCliMet:nAt,15]+"' AND D_E_L_E_T_=' '"),"")}}
Else
	@ aPos[2,1]+000,aPos[2,2]+000 LISTBOX oLbCliMet FIELDS HEADER "",STR0018,STR0002,STR0003,STR0014,STR0020,STR0021,STR0029,RetTitle("VCF_CONDIC") COLSIZES 10,80,100,90,50,50,50,70,70 SIZE aPos[2,4]-4,aPos[2,3]-aPos[2,1] OF oCEVAgeVis PIXEL ON DBLCLICK IIf(!Empty(aCliMet[oLbCliMet:nAt,2]),VEICC500(aCliMet[oLbCliMet:nAt,2],aCliMet[oLbCliMet:nAt,3],dDatIni,dDatFin),.t.)
	oLbCliMet:SetArray(aCliMet)
	oLbCliMet:bLine := { || { IIf(aCliMet[oLbCliMet:nAt,11],oVerdMet,oVermMet),;
							aCliMet[oLbCliMet:nAt,1]+" - "+aCliMet[oLbCliMet:nAt,12],;
							aCliMet[oLbCliMet:nAt,2]+"-"+aCliMet[oLbCliMet:nAt,3]+" "+aCliMet[oLbCliMet:nAt,9],;
							aCliMet[oLbCliMet:nAt,4]+" "+aCliMet[oLbCliMet:nAt,10],;
							FG_AlinVlrs(Transform(aCliMet[oLbCliMet:nAt,5],"@EZ 999,999")),;
							FG_AlinVlrs(Transform(aCliMet[oLbCliMet:nAt,6],"@E 999,999")),;
							FG_AlinVlrs(Transform(aCliMet[oLbCliMet:nAt,7],"@E 999,999"))+FG_AlinVlrs(Transform((aCliMet[oLbCliMet:nAt,7]/aCliMet[oLbCliMet:nAt,6])*100,"@E 99999")+"%"),; 
							aCliMet[oLbCliMet:nAt,13],;
							IIf(!Empty(aCliMet[oLbCliMet:nAt,14]),X3CBOXDESC("VCF_CONDIC",aCliMet[oLbCliMet:nAt,14]),"")}}
EndIf

@ aPos[1,1]+000,aPos[1,2]+002 SAY STR0010 SIZE 30,08 OF oCEVAgeVis PIXEL COLOR CLR_BLUE //Periodo
@ aPos[1,1]+008,aPos[1,2]+002 MSGET oDatIni VAR dDatIni PICTURE "@D" VALID FS_IMPREF(.f.) SIZE 42,06 OF oCEVAgeVis PIXEL COLOR CLR_BLUE
@ aPos[1,1]+009,aPos[1,2]+046 SAY STR0011 SIZE 10,08 OF oCEVAgeVis PIXEL COLOR CLR_BLUE //a
@ aPos[1,1]+008,aPos[1,2]+050 MSGET oDatFin VAR dDatFin PICTURE "@D" VALID ( FS_IMPREF(.f.) .and. ( dDatIni <= dDatFin ) ) SIZE 42,06 OF oCEVAgeVis PIXEL COLOR CLR_BLUE

@ aPos[1,1]+000,aPos[1,2]+097 SAY STR0003 SIZE 30,08 OF oCEVAgeVis PIXEL COLOR CLR_BLUE //Vendedor
@ aPos[1,1]+008,aPos[1,2]+097 MSGET oVended VAR cVended PICTURE "@!" F3 "SA3" VALID FS_IMPREF(.f.) SIZE 35,06 OF oCEVAgeVis PIXEL COLOR CLR_BLUE WHEN lVerOutros

@ aPos[1,1]+000,aPos[1,2]+137 SAY STR0012 SIZE 30,08 OF oCEVAgeVis PIXEL COLOR CLR_BLUE //Analise
@ aPos[1,1]+008,aPos[1,2]+137 MSCOMBOBOX oAnalis VAR cAnalis VALID FS_IMPREF(.f.) SIZE 42,08 COLOR CLR_BLACK ITEMS aAnalis OF oCEVAgeVis PIXEL COLOR CLR_BLUE

@ aPos[1,1]+000,aPos[1,2]+184 SAY STR0013 SIZE 30,08 OF oCEVAgeVis PIXEL COLOR CLR_BLUE //Tipo
@ aPos[1,1]+008,aPos[1,2]+184 MSCOMBOBOX oCEVTip VAR cCEVTip VALID FS_IMPREF(.f.) SIZE 55,08 COLOR CLR_BLACK ITEMS aCEVTip OF oCEVAgeVis PIXEL COLOR CLR_BLUE

@ aPos[1,1]+000,aPos[1,2]+245 SAY STR0014 SIZE 50,08 OF oCEVAgeVis PIXEL COLOR CLR_BLUE //Periodicidade
@ aPos[1,1]+008,aPos[1,2]+245 MSGET oPeriod VAR nPeriod PICTURE "@E 999" VALID FS_IMPREF(.f.) SIZE 33,06 OF oCEVAgeVis PIXEL COLOR CLR_BLUE

@ aPos[1,1]+000,aPos[1,2]+285 SAY STR0024 SIZE 30,08 OF oCEVAgeVis PIXEL COLOR CLR_BLUE //Meta
@ aPos[1,1]+008,aPos[1,2]+285 MSCOMBOBOX oMetAti VAR cMetAti VALID FS_IMPREF(.f.) SIZE 43,08 COLOR CLR_BLACK ITEMS aMetAti OF oCEVAgeVis PIXEL COLOR CLR_BLUE

@ aPos[1,1]+025,aPos[1,2]+002 MSCOMBOBOX oCliPros VAR cCliPros ITEMS aCliPros ON CHANGE FS_CLIPROS() SIZE 38,08 OF oCEVAgeVis PIXEL COLOR CLR_BLUE
@ aPos[1,1]+025,aPos[1,2]+045 MSGET oCodCli VAR cCodCli PICTURE "@!" F3 "SA1" VALID FS_IMPREF(.f.) SIZE 35,06 OF oCEVAgeVis PIXEL COLOR CLR_BLUE
@ aPos[1,1]+025,aPos[1,2]+080 MSGET oLojCli VAR cLojCli PICTURE "@!" VALID FS_IMPREF(.f.) SIZE 15,06 OF oCEVAgeVis PIXEL COLOR CLR_BLUE
@ aPos[1,1]+025,aPos[1,2]+045 MSGET oCdPros VAR cCdPros PICTURE "@!" F3 "SUS" VALID FS_IMPREF(.f.) SIZE 35,06 OF oCEVAgeVis PIXEL COLOR CLR_BLUE
@ aPos[1,1]+025,aPos[1,2]+080 MSGET oLjPros VAR cLjPros PICTURE "@!" VALID FS_IMPREF(.f.) SIZE 15,06 OF oCEVAgeVis PIXEL COLOR CLR_BLUE

@ aPos[1,1]+026,aPos[1,2]+108 SAY RetTitle("VCF_CONDIC") SIZE 40,08 OF oCEVAgeVis PIXEL COLOR CLR_BLUE // Condicao
@ aPos[1,1]+025,aPos[1,2]+135 MSCOMBOBOX oVCFCon VAR cVCFCon ITEMS aVCFCon SIZE 50,08 OF oCEVAgeVis PIXEL COLOR CLR_BLUE

If lA1_SEGMER1
	@ aPos[1,1]+026,aPos[1,2]+190 SAY RetTitle("A1_SEGMER1") SIZE 40,08 OF oCEVAgeVis PIXEL COLOR CLR_BLUE // Campo customizado A1_SEGMER1
	@ aPos[1,1]+025,aPos[1,2]+233 MSGET oA1SEGMER1 VAR M->A1_SEGMER1 PICTURE SA1->(X3PICTURE("A1_SEGMER1")) F3 "VX5MZ1" SIZE 45,06 OF oCEVAgeVis PIXEL COLOR CLR_BLUE
EndIf

@ aPos[1,1]+025,aPos[1,2]+285 BUTTON oOk PROMPT STR0015 OF oCEVAgeVis SIZE 43,10 PIXEL ACTION Processa( {|| FS_IMPREF(.t.) , FS_LEVANT(1) } ) //Filtrar
@ aPos[1,1]+000,aPos[1,4]-090 BUTTON oEmpr PROMPT UPPER(STR0017) OF oCEVAgeVis SIZE 40,09 PIXEL ACTION (lDClik:=.t.,oCEVAgeVis:End())  //Filiais
@ aPos[1,1]+011,aPos[1,4]-090 BUTTON oImpr PROMPT STR0016 OF oCEVAgeVis SIZE 40,09 PIXEL ACTION FS_IMPRIMIR() WHEN lImprimir //Imprimir

@ aPos[1,1]+000,aPos[1,4]-045 BUTTON oLegenda PROMPT STR0027 OF oCEVAgeVis SIZE 40,09 PIXEL ACTION FS_LEGMET() // Legenda
@ aPos[1,1]+011,aPos[1,4]-045 BUTTON oSair PROMPT STR0028 OF oCEVAgeVis SIZE 40,09 PIXEL ACTION oCEVAgeVis:End() // SAIR
ACTIVATE MSDIALOG oCEVAgeVis CENTER
If lDClik
	VEICC620(cEmpr,aEmpr,dDatIni,dDatFin,cVended,cCodCli,cLojCli,cAnalis,cCEVTip,nPeriod,cMetAti,cCdPros,cLjPros,cCliPros,cVCFCon,M->A1_SEGMER1)
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_IMPREF ³ Autor ³  Andre Luis Almeida   ³ Data ³ 23/04/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Refresh no botao Imprimir ( .t. somente apos FILTRO )      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPREF(lRefresh)
lImprimir := lRefresh
oImpr:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_LEVANT ³ Autor ³  Andre Luis Almeida   ³ Data ³ 23/04/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levantamento dos Valores                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVANT(nTip)
Local cQuery      := ""
Local cFilVCF     := ""
Local cQAlias     := "SQLVCF"
Local nCli        := 0
Local nEmpr       := 0
Local cFilSALVA   := cFilAnt
Local cV          := ""
Local nX          := 0
Local nP          := 0
Local nDias       := 0
Local nRecAux     := 0
Local aAux        := {}
Local lVC1_CONPRO := ( VC1->(FieldPos("VC1_CONPRO")) > 0 )
Local lVCF_GRUECN := ( VCF->(FieldPos("VCF_GRUECN")) > 0 )
Local cA1_SEGMER1 := ""
//
aCliMet := {}            
aAdd(aCliMet,{ STR0022 , "" , "" , "" ,  0 , 0 , 0 , "0" , "" , "" , .f. , "" , "" , "" , "" }) // Total Geral
//
If cCliPros == "2" .and. !Empty(cCdPros+cLjPros) // Prospect
	cCodCli := space(SA1->(TamSX3("A1_COD")[1]))
	cLojCli := space(SA1->(TamSX3("A1_LOJA")[1]))
	cQuery  := "SELECT R_E_C_N_O_ FROM "+RetSqlName("SUS")+" WHERE US_FILIAL='"+xFilial("SUS")+"' AND US_COD='"+cCdPros+"' AND US_LOJA='"+cLjPros+"' AND D_E_L_E_T_=' '"
	nRecAux := FM_SQL(cQuery)
	If nRecAux > 0
		DbSelectArea("SUS")
		DbGoTo(nRecAux)
		cCodCli := SUS->US_CODCLI
		cLojCli := SUS->US_LOJACLI
	EndIf
	If Empty(cCodCli+cLojCli)
		MsgStop(STR0030,STR0005) // Prospect não foi convertido para Cliente. Impossível continuar... / Atencao
		cCodCli := repl("_",SA1->(TamSX3("A1_COD")[1]))
		cLojCli := repl("_",SA1->(TamSX3("A1_LOJA")[1]))
	EndIf
EndIf
//
For nEmpr := 1 to len(aEmpr)
	cFilAnt := aEmpr[nEmpr,1]
	cQuery := "SELECT VCF.VCF_FILIAL , VCF.VCF_CODCLI , VCF.VCF_LOJCLI , VCF.VCF_DATCAD , VCF.VCF_CONDIC "
	Do Case
		Case cCEVTIP == "1" // Servicos
			cQuery += ", VCF.VCF_VENSRV AS VCF_VEND , VCF.VCF_DIAPES AS VCF_DIAS "
		Case cCEVTIP == "3" // Pecas
			cQuery += ", VCF.VCF_VENPEC AS VCF_VEND , VCF.VCF_DIAPEP AS VCF_DIAS "
		Case cCEVTIP == "4" // Veic.Novos
			cQuery += ", VCF.VCF_VENVEI AS VCF_VEND , VCF.VCF_DIAPER AS VCF_DIAS "
		Case cCEVTIP == "5" // Veic.Usados
			cQuery += ", VCF.VCF_VENVEU AS VCF_VEND , VCF.VCF_DIAVEU AS VCF_DIAS "
		Case cCEVTIP == "6" // Pneus
			cQuery += ", VCF.VCF_VENPNE AS VCF_VEND , VCF.VCF_DIAPNE AS VCF_DIAS "
		Case cCEVTIP == "7" // Outros
			cQuery += ", VCF.VCF_VENOUT AS VCF_VEND , VCF.VCF_DIAOUT AS VCF_DIAS "
	EndCase
	If lVCF_GRUECN
		cQuery += ", VCF.VCF_GRUECN "
	EndIf
	cQuery += "FROM "+RetSqlName("VCF")+" VCF "
	cQuery += "WHERE VCF.VCF_FILIAL = '"+xFilial("VCF")+"' AND "
	If !Empty(cCodCli+cLojCli)
		cQuery += "VCF.VCF_CODCLI='"+cCodCli+"' AND VCF.VCF_LOJCLI='"+cLojCli+"' AND "
	EndIf
	Do Case
		Case cCEVTIP == "1" // Servicos
			If !Empty(cVended)
				cQuery += "VCF.VCF_VENSRV='"+cVended+"' AND "
			EndIf
			If nPeriod > 0
				cQuery += "VCF.VCF_DIAPES="+Alltrim(str(nPeriod))+" AND "
			Else
				cQuery += "VCF.VCF_DIAPES > 0 AND "
			EndIf
		Case cCEVTIP == "3" // Pecas 
			If !Empty(cVended)
				cQuery += "VCF.VCF_VENPEC='"+cVended+"' AND "
			EndIf
			If nPeriod > 0
				cQuery += "VCF.VCF_DIAPEP="+Alltrim(str(nPeriod))+" AND "
			Else
				cQuery += "VCF.VCF_DIAPEP > 0 AND "
			EndIf
		Case cCEVTIP == "4" // Veic.Novos
			If !Empty(cVended)
				cQuery += "VCF.VCF_VENVEI='"+cVended+"' AND "
			EndIf
			If nPeriod > 0
				cQuery += "VCF.VCF_DIAPER="+Alltrim(str(nPeriod))+" AND "
			Else
				cQuery += "VCF.VCF_DIAPER > 0 AND "
			EndIf
		Case cCEVTIP == "5" // Veic.Usados
			If !Empty(cVended)
				cQuery += "VCF.VCF_VENVEU='"+cVended+"' AND "
			EndIf
			If nPeriod > 0
				cQuery += "VCF.VCF_DIAVEU="+Alltrim(str(nPeriod))+" AND "
			Else
				cQuery += "VCF.VCF_DIAVEU > 0 AND "
			EndIf
		Case cCEVTIP == "6" // Pneus
			If !Empty(cVended)
				cQuery += "VCF.VCF_VENPNE='"+cVended+"' AND "
			EndIf
			If nPeriod > 0
				cQuery += "VCF.VCF_DIAPNE="+Alltrim(str(nPeriod))+" AND "
			Else
				cQuery += "VCF.VCF_DIAPNE > 0 AND "
			EndIf
		Case cCEVTIP == "7" // Outros
			If !Empty(cVended)
				cQuery += "VCF.VCF_VENOUT='"+cVended+"' AND "
			EndIf
			If nPeriod > 0
				cQuery += "VCF.VCF_DIAOUT="+Alltrim(str(nPeriod))+" AND "
			Else
				cQuery += "VCF.VCF_DIAOUT > 0 AND "
			EndIf
	EndCase
	If !Empty(cVCFCon)
		cQuery += "VCF.VCF_CONDIC='"+cVCFCon+"' AND "
	EndIf
	cQuery += "VCF.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	Do While !( cQAlias )->( Eof() )
		If cAnalis == "1" // Analise por Cliente
			cV := ""							// SEM Vendedor
		Else
			cV := ( cQAlias )->( VCF_VEND )	// Vendedor
		EndIf
		//
		nDias := ( dDatFin - dDatIni )
		If dDatIni < stod( ( cQAlias )->( VCF_DATCAD ) )
			nDias := ( dDatFin - stod( ( cQAlias )->( VCF_DATCAD ) ) )
			If nDias < 0
				( cQAlias )->( DbSkip() )
				Loop	
			EndIf
		EndIf
		//////////////////////////////////
		// Campo Customizado A1_SEGMER1 //		
		//////////////////////////////////
		cA1_SEGMER1 := ""
		If lA1_SEGMER1 .and. !Empty(M->A1_SEGMER1)
			cA1_SEGMER1 := FM_SQL("SELECT A1_SEGMER1 FROM "+RetSqlName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+( cQAlias )->( VCF_CODCLI )+"' AND A1_LOJA='"+( cQAlias )->( VCF_LOJCLI )+"' AND D_E_L_E_T_=' '")
			If !Empty(M->A1_SEGMER1) .and. cA1_SEGMER1 <> M->A1_SEGMER1 
				( cQAlias )->( DbSkip() )
				Loop
			EndIf
		EndIf
		//////////////////////////////////
		//
		nP := ( cQAlias )->( VCF_DIAS )		// Periodicidade
		If nP == 0
			nX := 0
		Else
			nX := int( nDias / nP )				// Qtd de vezes visitas
			If nX == 0 .and. nP <= nDias
				nX := 1
			EndIf
		EndIf
		cGrpEcn := ""
		If lVCF_GRUECN
			VQK->(DbSeek(xFilial("VQK")+( cQAlias )->( VCF_GRUECN )))
			cGrpEcn := VQK->VQK_CODIGO+"-"+VQK->VQK_DESCRI
		EndIf
		aAdd(aCliMet,{ ( cQAlias )->( VCF_FILIAL ) , ( cQAlias )->( VCF_CODCLI ) , ( cQAlias )->( VCF_LOJCLI ) , cV ,  nP , nX , 0 , "1" , "" , "" , .f. , Alltrim(FWFilialName()) , cGrpEcn , ( cQAlias )->( VCF_CONDIC ) , cA1_SEGMER1 })
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
Next
cFilAnt := cFilSALVA
For nEmpr := 1 to len(aEmpr)
	cFilAnt := aEmpr[nEmpr,1]
	cFilVCF := xFilial("VCF")
	For nCli := 1 to len(aCliMet)
		If aCliMet[nCli,1] == cFilVCF // Filial do Cliente VCF
			
			// Nome do Cliente
			aCliMet[nCli,9] := left(FM_SQL("SELECT SA1.A1_NOME FROM "+RetSqlName("SA1")+" SA1 WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD='"+aCliMet[nCli,2]+"' AND SA1.A1_LOJA='"+aCliMet[nCli,3]+"' AND SA1.D_E_L_E_T_=' '"),25)
			
			// Nome do Vendedor
			If !Empty(aCliMet[nCli,4]) // Vendedor
				aCliMet[nCli,10] := left(FM_SQL("SELECT SA3.A3_NOME FROM "+RetSqlName("SA3")+" SA3 WHERE SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD='"+aCliMet[nCli,4]+"' AND SA3.D_E_L_E_T_=' '"),20)
			EndIf
			
			// Levanta a Qtde de Visitas realizadas
			cQuery := "SELECT COUNT(*) AS QTD "
			cQuery += "FROM "+RetSqlName("VC1")+" VC1 , "+RetSqlName("VC5")+" VC5 WHERE "
			cQuery += "VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND VC1.VC1_CODCLI='"+aCliMet[nCli,2]+"' AND VC1.VC1_LOJA='"+aCliMet[nCli,3]+"' AND "
			cQuery += "VC1.VC1_DATAGE>='"+dtos(dDatIni)+"' AND VC1.VC1_DATAGE<='"+dtos(dDatFin)+"' AND VC1.VC1_DATVIS<>' ' AND "
			If !Empty(aCliMet[nCli,4]) // Vendedor
				cQuery += "VC1.VC1_CODVEN='"+aCliMet[nCli,4]+"' AND "
			EndIf
			If lVC1_CONPRO
				cQuery += "VC1.VC1_CONPRO<>'0' AND " // Contatos ( ' ' = VC1 antigos / '1' = produtivos )
			EndIf
			cQuery += "VC1.D_E_L_E_T_=' ' AND "
			cQuery += "VC5.VC5_FILIAL='"+xFilial("VC5")+"' AND VC5.VC5_TIPAGE=VC1.VC1_TIPAGE AND "
			If cCEVTIP == "1" // 1=Servicos
				cQuery += "VC5.VC5_AGEOFI IN ('1','2') AND "
			Else
				cQuery += "VC5.VC5_AGEOFI='"+cCEVTIP+"' AND "
			EndIf
			cQuery += "VC5.D_E_L_E_T_=' '"
			aCliMet[nCli,7] := FM_SQL(cQuery)
			If aCliMet[nCli,6] <= aCliMet[nCli,7]
				aCliMet[nCli,11] := .t.
			EndIf

			// Somar no Total Geral 
			aCliMet[1,6]    += aCliMet[nCli,6] // Visitas Previstas 
			aCliMet[1,7]    += aCliMet[nCli,7] // Visitas Realizadas 
			
		EndIf
	Next
Next
If !Empty(cMetAti) // Meta: 0=Nao Atingida / 1=Atingida
	aAux := {}
	aAdd(aAux,{ STR0022 , "" , "" , "" , 0 , 0 , 0 , "0" , "" , "" , .f. , "" , "" , "" , "" }) // Total Geral
	For nCli := 2 to len(aCliMet)
		// Nao Atingida ou Atingida //
		If ( cMetAti == "0" .and. !aCliMet[nCli,11] ) .or. ( cMetAti == "1" .and. aCliMet[nCli,11] )
			aAdd(aAux,aClone(aCliMet[nCli])) // inserir linha do vetor
			// Somar no Total Geral 
			aAux[1,6] += aCliMet[nCli,6] // Visitas Previstas 
			aAux[1,7] += aCliMet[nCli,7] // Visitas Realizadas 
		EndIf
	Next
	aCliMet := aClone(aAux)
EndIf
If aCliMet[1,6] <= aCliMet[1,7]
	aCliMet[1,11] := .t.
EndIf
If len(aCliMet) == 1
	If cMetAti == "0" // Meta: 0=Nao Atingida
		aCliMet[1,11] := .f.
	ElseIf cMetAti == "1" // Meta: 1=Atingida
		aCliMet[1,11] := .t.
	EndIf
EndIf
If cAnalis == "1" // Analise por Cliente
	aSort(aCliMet,1,,{|x,y| x[8]+x[9]  < y[8]+y[9]  })
Else // Analise por Vendedor
	aSort(aCliMet,1,,{|x,y| x[8]+x[10] < y[8]+y[10] })
EndIf
If nTip # 0
	oLbCliMet:nAt := 1
	oLbCliMet:SetArray(aCliMet)
	If lA1_SEGMER1
		oLbCliMet:bLine := { || { IIf(aCliMet[oLbCliMet:nAt,11],oVerdMet,oVermMet),;
						aCliMet[oLbCliMet:nAt,1]+" - "+aCliMet[oLbCliMet:nAt,12],;
						aCliMet[oLbCliMet:nAt,2]+"-"+aCliMet[oLbCliMet:nAt,3]+" "+aCliMet[oLbCliMet:nAt,9],;
						aCliMet[oLbCliMet:nAt,4]+" "+aCliMet[oLbCliMet:nAt,10],;
						FG_AlinVlrs(Transform(aCliMet[oLbCliMet:nAt,5],"@EZ 999,999")),;
						FG_AlinVlrs(Transform(aCliMet[oLbCliMet:nAt,6],"@E 999,999")),;
						FG_AlinVlrs(Transform(aCliMet[oLbCliMet:nAt,7],"@E 999,999"))+FG_AlinVlrs(Transform((aCliMet[oLbCliMet:nAt,7]/aCliMet[oLbCliMet:nAt,6])*100,"@E 99999")+"%"),; 
						aCliMet[oLbCliMet:nAt,13],;
						IIf(!Empty(aCliMet[oLbCliMet:nAt,14]),X3CBOXDESC("VCF_CONDIC",aCliMet[oLbCliMet:nAt,14]),""),;
						IIf(!Empty(aCliMet[oLbCliMet:nAt,15]),FM_SQL("SELECT VX5_DESCRI FROM "+RetSQLName("VX5")+" WHERE VX5_FILIAL='"+xFilial("VX5")+"' AND VX5_CHAVE='033' AND VX5_CODIGO='"+aCliMet[oLbCliMet:nAt,15]+"' AND D_E_L_E_T_=' '"),"")}}
	Else
		oLbCliMet:bLine := { || { IIf(aCliMet[oLbCliMet:nAt,11],oVerdMet,oVermMet),;
						aCliMet[oLbCliMet:nAt,1]+" - "+aCliMet[oLbCliMet:nAt,12],;
						aCliMet[oLbCliMet:nAt,2]+"-"+aCliMet[oLbCliMet:nAt,3]+" "+aCliMet[oLbCliMet:nAt,9],;
						aCliMet[oLbCliMet:nAt,4]+" "+aCliMet[oLbCliMet:nAt,10],;
						FG_AlinVlrs(Transform(aCliMet[oLbCliMet:nAt,5],"@EZ 999,999")),;
						FG_AlinVlrs(Transform(aCliMet[oLbCliMet:nAt,6],"@E 999,999")),;
						FG_AlinVlrs(Transform(aCliMet[oLbCliMet:nAt,7],"@E 999,999"))+FG_AlinVlrs(Transform((aCliMet[oLbCliMet:nAt,7]/aCliMet[oLbCliMet:nAt,6])*100,"@E 99999")+"%"),; 
						aCliMet[oLbCliMet:nAt,13],;
						IIf(!Empty(aCliMet[oLbCliMet:nAt,14]),X3CBOXDESC("VCF_CONDIC",aCliMet[oLbCliMet:nAt,14]),"")}}
	EndIf
	oLbCliMet:SetFocus()
	oLbCliMet:Refresh()
EndIf
cFilAnt := cFilSALVA
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FILIAIS³ Autor ³  Andre Luis Almeida   ³ Data ³ 11/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Filiais                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILIAIS()
Local aVetAux      := {}
Local ni           := {}
Local aFilAtu      := FWArrFilAtu()
Local aSM0         := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt   := cFilAnt
Local nCont        := 0
Local aFWArrFilAtu := {}
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aFWArrFilAtu := FWArrFilAtu()
	ni := aScan(aEmpr,{|x| x[1] == cFilAnt })
	aAdd( aVetEmp, { (ni>0) , cFilAnt , aFWArrFilAtu[SM0_FILIAL] , FWFilialName() })
Next
cFilAnt := cBkpFilAnt
If Len(aVetEmp) > 1
	DEFINE MSDIALOG oDlgEmp FROM 05,01 TO 250,400 TITLE STR0017 PIXEL // Filiais
	@ 001,001 LISTBOX oLbEmp FIELDS HEADER "",STR0018,STR0019 COLSIZES 10,15,50 SIZE 165,120 OF oDlgEmp ON DBLCLICK (aVetEmp[oLbEmp:nAt,1]:=!aVetEmp[oLbEmp:nAt,1]) PIXEL
	oLbEmp:SetArray(aVetEmp)
	oLbEmp:bLine := { || {  IIf(aVetEmp[oLbEmp:nAt,1],oOk,oNo) ,;
	aVetEmp[oLbEmp:nAt,3],;
	aVetEmp[oLbEmp:nAt,4] }}
	DEFINE SBUTTON FROM 001,170 TYPE 1  ACTION (oDlgEmp:End()) ENABLE OF oDlgEmp
	@ 002, 002 CHECKBOX oMacTod VAR lMarcar PROMPT "" OF oDlgEmp ON CLICK IIf( FS_TIK(lMarcar ) , .t. , ( lMarcar:=!lMarcar , oDlgEmp:Refresh() ) ) 	SIZE 70,08 PIXEL COLOR CLR_BLUE
	ACTIVATE MSDIALOG oDlgEmp CENTER
EndIf
If len(aVetEmp) == 1
	aVetEmp[1,1] := .t.
EndIf
For ni := 1 to len(aVetEmp)
	If aVetEmp[ni,1]
		aAdd( aVetAux, { aVetEmp[ni,2] , aVetEmp[ni,3] })
		cEmpr += Alltrim(aVetEmp[ni,2])+", "
	EndIf
Next
If len(aVetAux) > 1
	cEmpr := substr(cEmpr,1,len(cEmpr)-2)
EndIf
Return(aVetAux)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIK    ³ Autor ³  Andre Luis Almeida  ³ Data ³ 26/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Marcar todas as Filiais                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK(lMarcar)
Local ni := 0
Default lMarcar := .f.
For ni := 1 to Len(aVetEmp)
	If lMarcar
		aVetEmp[ni,1] := .t.
	Else
		aVetEmp[ni,1] := .f.
	EndIf
Next
oLbEmp:SetFocus()
oLbEmp:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LEGMET ³ Autor ³  Andre Luis Almeida  ³ Data ³ 25/04/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEGMET()
Local aLegenda := {	{'BR_VERMELHO', STR0025 },;  // Nao atingida
					{'BR_VERDE'   , STR0026 }}   // Atingida
BrwLegenda(STR0024,STR0027+" - "+STR0024,aLegenda) // Meta / Legenda
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_IMPRIMIR³ Autor ³  Andre Luis Almeida  ³ Data ³ 25/04/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRIMIR()
Local ni := 0
Private cDesc1 := ""
Private cDesc2 := ""
Private cDesc3 := ""
Private tamanho:= "G"
Private limite := 132
Private cString:= "VC1"
Private titulo := STR0001 +cEmpr
Private cabec1 := ""
Private cabec2 := STR0023+Space(10)+left(STR0029+space(31),31)+left(RetTitle("VCF_CONDIC")+space(15),15)+IIf(lA1_SEGMER1,RetTitle("A1_SEGMER1"),"") // Filial          Cliente                                  Vendedor               Periodicidade Previstas    Realizadas Meta
Private aReturn:= {"",1,"",1,2,1,"",1}
Private nomeprog:= "VEICC620"
Private nLastKey:= 0
//
cabec1 := STR0010+" "+Transform(dDatIni,"@D")+" "+STR0011+" "+Transform(dDatFin,"@D") // Periodo / a 
cabec1 += " - "+STR0012+" "+substr(aAnalis[val(cAnalis)],3) // Analise por
ni := val(cCEVTip)
If ni > 2
	ni--
EndIf
cabec1 += " - "+STR0013+" "+substr(aCEVTip[ni],3) // Tipo
cabec1 += IIf(!Empty(cCodCli+cLojCli)," - "+STR0002+" "+cCodCli+"-"+cLojCli,"")  // Cliente
cabec1 += IIf(!Empty(cVended)," - "+STR0003+" "+cVended,"") // Vendedor
cabec1 += IIf(nPeriod>0," - "+STR0014+" "+Transform(nPeriod,"@E 999"),"") // Periodicidade
//
nomeprog := SetPrint(cString,nomeprog,nil,titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
If nLastKey == 27
	Return
EndIf
SetDefault(aReturn,cString)
nLin  := 0
m_pag := 1
Set Printer to &nomeprog
Set Printer On
Set Device  to Printer
nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
For ni := 1 to len(aCliMet)
	If nLin >= 60
		nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
	EndIf
	@ nLin++, 00 PSAY 	left(aCliMet[ni,1]+"-"+aCliMet[ni,12]+space(15),15)+" "+;
						left(aCliMet[ni,2]+"-"+aCliMet[ni,3]+" "+aCliMet[ni,9]+space(40),40)+" "+;
						left(aCliMet[ni,4]+" "+aCliMet[ni,10]+space(30),30)+;
						Transform(aCliMet[ni,5],"@EZ 99,999")+;
						Transform(aCliMet[ni,6],"@E 999999,999")+Transform(aCliMet[ni,7],"@E 9999,999")+Transform((aCliMet[ni,7]/aCliMet[ni,6])*100,"@E 99999")+"% "+;
						left(IIf(aCliMet[ni,11],STR0026,STR0025)+space(14),14)+;
						left(aCliMet[ni,13],30)+" "+;
						left(IIf(!Empty(aCliMet[ni,14]),X3CBOXDESC("VCF_CONDIC",aCliMet[ni,14]),"")+space(14),14)+" "+;
						left(IIf(!Empty(aCliMet[ni,15]),FM_SQL("SELECT VX5_DESCRI FROM "+RetSQLName("VX5")+" WHERE VX5_FILIAL='"+xFilial("VX5")+"' AND VX5_CHAVE='033' AND VX5_CODIGO='"+aCliMet[ni,15]+"' AND D_E_L_E_T_=' '"),"")+space(18),18)
Next
Set Printer to
Set Device to Screen
If aReturn[5] == 1
	OurSpool( nomeprog )
EndIf
MS_Flush()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_CLIPROS³ Autor ³ Andre Luis Almeida     ³ Data ³ 02/09/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Cliente ou Prospect                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CLIPROS()
oCodCli:lVisible := .f.
oLojCli:lVisible := .f.
oCdPros:lVisible := .f.
oLjPros:lVisible := .f.
If cCliPros == "1" // Cliente
	oCodCli:lVisible := .t.
	oLojCli:lVisible := .t.
	oCodCli:SetFocus()
ElseIf cCliPros == "2" // Prospect
	oCdPros:lVisible := .t.
	oLjPros:lVisible := .t.
	oCdPros:SetFocus()
EndIf
oCodCli:Refresh()
oLojCli:Refresh()
oCdPros:Refresh()
oLjPros:Refresh()
Return(.t.)
