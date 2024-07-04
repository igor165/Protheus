#INCLUDE "FINA069.ch"
#INCLUDE "FONT.CH"
#INCLUDE "PROTHEUS.CH"

#define	 _DELETED_		"*"

///////////////////////////////////////
// melhor tamanho do objeto oMeter para
// o Size do campo criado na oDlg.
#define nMaxTamMeter	100


////////
// Cores
#define CLR_FUNDO		RGB(240,240,240)
#define CLR_FONTB		RGB(000,000,255)
#define CLR_FONTT		RGB(000,000,000)
#define CLR_FONTP		RGB(180,180,180)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ FINA069	  ³ Autor ³ Cristiano Denardi     ³ Data ³ 22/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Bordero de Distribuicao de Cobrancas 					    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FINA069()												    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAFIN		 											    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FINA069()

Local aArea		:= GetArea()
Local lValid	:= .T.
Local nMarg		:= 0.3
Local nVal		:= 0
Local nA		:= 0
Local cPriDia	:= "01"
Local cUltDia	:= StrZero( F_UltDia(dDataBase), 2 )
Local cMes		:= StrZero( Month(dDataBase)   , 2 )
Local cAno	 	:= Str ( Year(dDataBase) )
LOCAL cF3BQ1	:= 'BQLPL1'

Static  oPanel				// Painel com objetos de processamento
Private oDlg   , oMeter		// Dialog e Progress Bar
Private oBtnOk , oBtnCa		// Botoes de Ok e Cancelar
Private oBtnPr				// Botao imprimir
Private oDtIni , oDtFin		// Data de Inicio e Final usados no Filtro
Private oCliIni, oCliFin	// Cliente de Inicio e Final usados no Filtro
Private oLojIni, oLojFin	// Loja de Inicio e Final usados no Filtro
Private oBcoIni, oBcoFin	// Banco de Inicio e Final usados no Filtro
Private oAgeIni, oAgeFin	// Agencia de Inicio e Final usados no Filtro
Private oCtaIni, oCtaFin	// Conta de Inicio e Final usados no Filtro
Private oFreIni, oFreFin	// Forma recebimento de Inicio e Final usados no Filtro
Private oNumBor, oFilTit	// N. do Bordero e Filtro do Titulo que estao sendo Processados
Private oTxtPro, oTxtTer	// Objetos Textos - Processando... e PROCESSADO !
Private oFontB , oFontT		// Fontes usados para os objetos acima respectivamente
Private oFontP , oFontE		// Fontes do Texto - Processando... e PROCESSADO !
Private lPrint	:= .F. 		// Indica se ja foi impresso relacao de Titulos Processados
Private lProc	:= .F.		// Indica se foi processado titulos
Private dDtIni	:= CtoD( cPriDia+"/"+cMes+"/"+cAno )
Private dDtFin	:= CtoD( cUltDia+"/"+cMes+"/"+cAno )
Private cTxtPro	:= STR0001 //"Processando..."
Private cTxtTer	:= STR0002 //"PROCESSADO !"
Private cAreaTRB:= "TRB"
Private	nCount	:= 0
Private aCposVld:= {}
Private aPrint	:= {}
Private cCliIni, cLojIni
Private cCliFin, cLojFin
Private cBcoIni, cBcoFin
Private cAgeIni, cAgeFin
Private cCtaIni, cCtaFin
Private cFreIni, cFreFin
Private cNumBor, cFilTit
Private cCodInt	:= PLSIntPad()


///////////////////////
// Validacoes da Rotina

	////////////////////////////////
	// Campos que necessitam existir
	// para a rotina funcionar de
	// forma adequada
	If lValid
		Aadd( aCposVld, {"BQL","BQL_FILIAL"} )
		Aadd( aCposVld, {"BQL","BQL_CODIGO"} )
		Aadd( aCposVld, {"BQL","BQL_DESCRI"} )
		Aadd( aCposVld, {"BQL","BQL_BCOCLI"} )
		Aadd( aCposVld, {"BQL","BQL_BCOOPE"} )
		Aadd( aCposVld, {"SE1","E1_FORMREC"} )
		Aadd( aCposVld, {"SE1","E1_PORTADO"} )
		Aadd( aCposVld, {"SE1","E1_AGEDEP" } )
		Aadd( aCposVld, {"SE1","E1_CONTA"  } )
		Aadd( aCposVld, {"SE1","E1_BCOCLI" } )
		Aadd( aCposVld, {"SE1","E1_AGECLI" } )
		Aadd( aCposVld, {"SE1","E1_CTACLI" } )
	
		DbSelectArea("SX3")
		For nA := 1 To Len( aCposVld )
			If !ValidCpo( aCposVld[nA][1], aCposVld[nA][2] )
				lValid := .F.
				Exit
			Endif
		Next nA
		     
		// Utiliza a consulta padrao F3 correta.
		If FindFunction("PlsGetVersao")
			cF3BQ1 := Iif(PlsGetVersao() >= 8, 'BQLPL1', 'BQL')
		Endif
	Endif
    
	If !lValid
		If Select(cAreaTRB) > 0
			(cAreaTRB)->( dbCloseArea() )
		Endif
		RestArea( aArea )
		Return Nil
	Endif

// Validacoes da Rotina
///////////////////////

cCliIni	:= Space(	TamSX3("A1_COD"    )[1] )
cLojIni	:= Space(	TamSX3("A1_LOJA"   )[1] )
cCliFin	:= Space(	TamSX3("A1_COD"    )[1] )
cLojFin	:= Space(	TamSX3("A1_LOJA"   )[1] )
cBcoIni	:= Space(	TamSX3("E1_PORTADO")[1] )
cBcoFin	:= Space(	TamSX3("E1_PORTADO")[1] )
cAgeIni	:= Space(	TamSX3("E1_AGEDEP" )[1] )
cAgeFin	:= Space(	TamSX3("E1_AGEDEP" )[1] )
cCtaIni	:= Space(	TamSX3("E1_CONTA"  )[1] )
cCtaFin	:= Space(	TamSX3("E1_CONTA"  )[1] )
cFreIni	:= Space(	TamSX3("E1_FORMREC")[1] )
cFreFin	:= Space(	TamSX3("E1_FORMREC")[1] )
cNumBor	:= Space(	TamSX3("E1_NUMBOR" )[1] )
cFilTit := Space(	TamSX3("E1_FORMREC")[1] +;
					TamSX3("E1_PORTADO")[1] +;
					TamSX3("E1_AGEDEP" )[1] +;
					TamSX3("E1_CONTA"  )[1] )


// Ajusta Variaveis Finais com ZZZ
// Posteriormente o ideal eh gravar
// os valores do filtro no Profile
// do usuario
cCliFin := Replicate( "z", Len(cCliFin) )
cLojFin := Replicate( "z", Len(cLojFin) )
cBcoFin := Replicate( "z", Len(cBcoFin) )
cAgeFin := Replicate( "z", Len(cAgeFin) )
cCtaFin := Replicate( "z", Len(cCtaFin) )
cFreFin := Replicate( "z", Len(cFreFin) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A fun‡„o SomaAbat reabre o SE1 com outro nome pela ChkFile para  ³
//³ efeito de performance. Se o alias auxiliar para a SumAbat() n„o  ³
//³ estiver aberto antes da IndRegua, ocorre Erro de & na ChkFile,   ³
//³ pois o Filtro do SE1 uptrapassa 255 Caracteres.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SomaAbat("","","","R")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desenha tela para gets do codigo e loja						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0005) FROM 5,0 To 20,60 //"Bordero de Cobranca Automatico"

	@ 00+nMarg,00+nMarg			SAY		OemToAnsi(STR0006) //"Escopo do Filtro"
	@ 00+nMarg+0.50,00+nMarg 	TO 5.6+nMarg,30-nMarg OF oDlg

	//////////////////
	// Filtro de Datas
	@ 01+nMarg,01+nMarg		SAY		OemToAnsi(STR0007) //"Data De"
	@ 01+nMarg,04+nMarg		MSGET	oDtIni VAR dDtIni ;
									Valid F069VldCpo( "D", dDtIni ) ;
									SIZE 50,10 hasbutton

	@ 02+nMarg,01+nMarg		SAY		OemToAnsi(STR0008) //"Data Ate"
	@ 02+nMarg,04+nMarg		MSGET	oDtFin VAR dDtFin ;
									Valid F069VldCpo( "D", dDtFin ) ;
									SIZE 50,10 hasbutton
	// Filtro de Datas
	//////////////////

	/////////////////////
	// Filtro de Clientes
	@ 01+nMarg,10+nMarg		SAY		OemToAnsi( STR0009 ) //"Cliente De"
	@ 01+nMarg,14+nMarg 	MSGET	oCliIni VAR cCliIni ;
									Valid F069VldCpo( "C",, cCliIni ) ;
									SIZE 35,10 ;
									F3 "SA1" hasbutton
	@ 01+nMarg,19+nMarg		SAY		OemToAnsi( STR0010 ) //"Loja De"
	@ 01+nMarg,22+nMarg 	MSGET	olojIni VAR cLojIni ;
									Valid F069VldCpo( "L",, cCliIni, cLojIni ) ;
									SIZE 20,10 hasbutton

	@ 02+nMarg,10+nMarg		SAY		OemToAnsi( STR0011 ) //"Cliente Ate"
	@ 02+nMarg,14+nMarg 	MSGET	oCliFin VAR cCliFin ;
									Valid F069VldCpo( "C",, cCliFin ) ;
									SIZE 35,10 ;
									F3 "SA1" hasbutton
	@ 02+nMarg,19+nMarg		SAY		OemToAnsi( STR0012 ) //"Loja Ate"
	@ 02+nMarg,22+nMarg 	MSGET	oLojFin VAR cLojFin ;
									Valid F069VldCpo( "L",, cCliFin, cLojFin ) ;
									SIZE 20,10 hasbutton
	// Filtro de Clientes
	/////////////////////

	//////////////////
	// Filtro de Forma
	// de Recebimento
	@ 03+nMarg,01+nMarg		SAY		OemToAnsi( STR0034 )  //"Tipo Recebimento De"
	@ 03+nMarg,08+nMarg 	MSGET	oFreIni VAR cFreIni ;
									Valid F069VldCpo( "R",, cFreIni ) ;
									SIZE 25,10 ;
									F3 cF3BQ1 hasbutton

	@ 03+nMarg,12+nMarg		SAY		OemToAnsi( STR0035 )  //"Tipo Recebimento Ate"
	@ 03+nMarg,19+nMarg 	MSGET	oFreFin VAR cFreFin ;
									Valid F069VldCpo( "R",, cFreFin ) ;
									SIZE 25,10 ;
									F3 cF3BQ1 hasbutton
	// Filtro de Forma
	// de Recebimento
	//////////////////

	////////////////////////
	// Filtro de Bco+Age+Cta
	@ 04+nMarg,01+nMarg		SAY		OemToAnsi( STR0036 )  //"Bco De"
	@ 04+nMarg,04+nMarg 	MSGET	oBcoIni VAR cBcoIni ;
									Valid F069VldCpo( "B",, cBcoIni ) ;
									SIZE 20,10 ;
									F3 "SA6" hasbutton
	@ 04+nMarg,7.5+nMarg	SAY		OemToAnsi( STR0037 ) //"Age. De"
	@ 04+nMarg,10.5+nMarg 	MSGET	oAgeIni VAR cAgeIni ;
									Valid F069VldCpo( "A",, cBcoIni, cAgeIni ) ;
									SIZE 25,10 hasbutton

	@ 04+nMarg,15+nMarg		SAY		OemToAnsi( STR0038 ) //"Cta De"
	@ 04+nMarg,18+nMarg 	MSGET	oCtaIni VAR cCtaIni ;
									Valid F069VldCpo( "T",, cBcoIni, cAgeIni, cCtaIni ) ;
									SIZE 30,10 hasbutton


	@ 05+nMarg,01+nMarg		SAY		OemToAnsi( STR0039 )  //"Bco Ate"
	@ 05+nMarg,04+nMarg 	MSGET	oBcoFin VAR cBcoFin ;
									Valid F069VldCpo( "B",, cBcoFin ) ;
									SIZE 20,10 ;
									F3 "SA6" hasbutton
	@ 05+nMarg,7.5+nMarg	SAY		OemToAnsi( STR0040 ) //"Age. Ate"
	@ 05+nMarg,10.5+nMarg 	MSGET	oAgeFin VAR cAgeFin ;
									Valid F069VldCpo( "A",, cBcoFin, cAgeFin ) ;
									SIZE 25,10 hasbutton

	@ 05+nMarg,15+nMarg		SAY		OemToAnsi( STR0041 ) //"Cta Ate"
	@ 05+nMarg,18+nMarg 	MSGET	oCtaFin VAR cCtaFin ;
									Valid F069VldCpo( "T",, cBcoFin, cAgeFin, cCtaFin ) ;
									SIZE 30,10 hasbutton
	// Filtro de Bco+Age+Cta
	////////////////////////

	DEFINE SBUTTON oBtnOk FROM 14,205 TYPE 1 ACTION ( FINA069Pro(@oMeter) ) ENABLE OF oDlg Pixel
	DEFINE SBUTTON oBtnCa FROM 28,205 TYPE 2 ACTION ( FINA069Exi()        ) ENABLE OF oDlg Pixel
	DEFINE SBUTTON oBtnPr FROM 42,205 TYPE 6 ACTION ( FINA069Pri()        ) ENABLE OF oDlg Pixel

	////////
	// Panel - ativado somente qdo estiver processando
	@ 84,02 MSPANEL oPanel PROMPT "" COLOR CLR_FONTT,CLR_FUNDO SIZE 234,30 OF oDlg LOWERED

		DEFINE FONT oFontB NAME "Arial" 		SIZE 7,20 BOLD	// Bordero
		DEFINE FONT oFontT NAME "Arial" 		SIZE 5,15 		// Filtro da quebra (Titulo)
		DEFINE FONT oFontP NAME "Courier New"	SIZE 7,20 BOLD	// Processando...
		DEFINE FONT oFontE NAME "Arial"			SIZE 9,20 BOLD	// PROCESSADO!

		@ 01,100 SAY oTxtPro PROMPT cTxtPro	FONT oFontP COLOR CLR_FONTP,CLR_FUNDO OF oPanel PIXEL
		@ 01,085 SAY oTxtTer PROMPT cTxtTer	FONT oFontE COLOR CLR_FONTB,CLR_FUNDO OF oPanel PIXEL

		@ 10,002 SAY oNumBor PROMPT	cNumBor	FONT oFontB COLOR CLR_FONTB,CLR_FUNDO OF oPanel PIXEL
		@ 10,028 SAY oFilTit PROMPT cFilTit	FONT oFontT COLOR CLR_FONTT,CLR_FUNDO OF oPanel PIXEL

		///////////////
		// Progress Bar
		@ 19,02 METER oMeter VAR nVal SIZE 230,010 TOTAL nMaxTamMeter OF oPanel PIXEL

	oBtnPr:Disable()
	oPanel:Hide()
	oTxtTer:Hide()
	// Panel
	////////

ACTIVATE MSDIALOG oDlg CENTERED

If Select(cAreaTRB) > 0
	(cAreaTRB)->( dbCloseArea() )
Endif
RestArea( aArea )
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ FINA069Pro ³ Autor ³ Cristiano Denardi     ³ Data ³ 22/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento dos titulos (Montagem do Bordero)			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FINA069()												    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA069		 											    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FINA069Pro(oMeter)

Local 	nA, nB, nC	:= 0
Local 	aTitBor		:= {}
Local	nAbatim		:= 0
Local 	nValTit		:= 0
Local 	cQuery		:= ""
Local	cNumBorNew	:= ""
Local	cChave		:= ""
Local	cQuebraAnt 	:= ""
Local	cQuebra 	:= ""
Local 	cSepNeg   	:= If("|"$MV_CRNEG,"|",",")
Local	cSepProv  	:= If("|"$MVPROVIS,"|",",")
Local 	cSepRec   	:= If("|"$MVRECANT,"|",",")
Local lFa069Fil     := Existblock("FA069FIL")
Local lFA069GRV     := Existblock("FA069GRV")

/////////////////////
// Mostra Panel e
// Objetos pendurados
oPanel:Show()
oMeter:Show()
oMeter:SetTotal(nMaxTamMeter)
oMeter:Set(0)

//////////////////
// Muda Status
// para Processado
lProc := .T.

cQuery := " Select "
cQuery +=	" se1.E1_FILIAL, se1.E1_PREFIXO, se1.E1_NUM, se1.E1_PARCELA, se1.E1_TIPO, "
cQuery +=	" se1.E1_SALDO, se1.E1_VALOR, se1.E1_VLCRUZ, "
cQuery +=	" se1.E1_NUMBOR, se1.E1_VENCREA, se1.E1_SITUACA, "
cQuery +=	" se1.E1_CLIENTE, se1.E1_LOJA, se1.E1_MOEDA, "
cQuery +=	" se1.E1_FORMREC, se1.E1_PORTADO, se1.E1_AGEDEP, se1.E1_CONTA, "
cQuery +=	" se1.E1_BCOCLI, se1.E1_AGECLI, se1.E1_CTACLI, "
cQuery +=	" se1.E1_SDACRES, se1.E1_SDDECRE "
cQuery += " From "
cQuery +=	RetSqlName( "SE1" ) + " se1 "
cQuery += " Where "
cQuery +=	" se1.E1_VENCREA >= '" + DtoS(dDtIni) 						+ "' And "
cQuery +=	" se1.E1_VENCREA <= '" + DtoS(dDtFin) 						+ "' And "
cQuery +=	" se1.E1_CLIENTE >= '" + cCliIni      						+ "' And "
cQuery +=	" se1.E1_CLIENTE <= '" + cCliFin      						+ "' And "
cQuery +=	" se1.E1_LOJA >= '"    + cLojIni      						+ "' And "
cQuery +=	" se1.E1_LOJA <= '"    + cLojFin        					+ "' And "
cQuery += 	" se1.E1_TIPO NOT IN " + FormatIn(MVABATIM,"|") 			+ " And "
cQuery += 	" se1.E1_TIPO NOT IN " + FormatIn(MV_CRNEG,cSepNeg)  		+ " And "
cQuery += 	" se1.E1_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) 		+ " And "
cQuery += 	" se1.E1_TIPO NOT IN " + FormatIn(MVRECANT,cSepRec)  		+ " And "
cQuery +=	" se1.E1_FORMREC <> '" + Space( TamSX3("E1_FORMREC")[1] )  + "' And "
cQuery +=	" se1.E1_FORMREC >= '" + cFreIni  							+ "' And "
cQuery +=	" se1.E1_FORMREC <= '" + cFreFin  							+ "' And "
cQuery +=	" se1.E1_PORTADO <> '" + Space( TamSX3("E1_PORTADO")[1] )  + "' And "
cQuery +=	" se1.E1_PORTADO >= '" + cBcoIni  							+ "' And "
cQuery +=	" se1.E1_PORTADO <= '" + cBcoFin  							+ "' And "
cQuery +=	" se1.E1_AGEDEP <> '"  + Space( TamSX3("E1_AGEDEP" )[1] )  + "' And "
cQuery +=	" se1.E1_AGEDEP >= '"  + cAgeIni  							+ "' And "
cQuery +=	" se1.E1_AGEDEP <= '"  + cAgeFin  							+ "' And "
cQuery +=	" se1.E1_CONTA <> '"   + Space( TamSX3("E1_CONTA"  )[1] )  + "' And "
cQuery +=	" se1.E1_CONTA >= '"   + cCtaIni  							+ "' And "
cQuery +=	" se1.E1_CONTA <= '"   + cCtaFin  							+ "' And "
cQuery +=	" se1.E1_NUMBOR = '"   + Space( TamSX3("E1_NUMBOR" )[1] )  + "' And "
cQuery +=	" se1.E1_FILIAL = '"   + xFilial("SE1") 					+ "' And "

If lFa069Fil
	cQuery := Execblock("FA069FIL", .F. , .F. , { cQuery } )    				// permite uma inserçao na clausula da query
	If Empty(cQuery)
		Return(.T.)
	Endif
Endif

cQuery +=	" se1.D_E_L_E_T_ != '" + _DELETED_    						+ "' "
cQuery += " ORDER BY se1.E1_FORMREC, se1.E1_PORTADO, se1.E1_AGEDEP, se1.E1_CONTA "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAreaTRB, .F., .T.)
TcSetField( cAreaTRB, "E1_VENCREA", "D" )

////////////////////
// Desabilita Botoes
oBtnOk:Disable()
oBtnCa:Disable()

////////////////////
// Desabilita campos
// do Filtro
oDtIni:Disable()
oDtFin:Disable()
oCliIni:Disable()
oCliFin:Disable()
oLojIni:Disable()
oLojFin:Disable()
oBcoIni:Disable()
oBcoFin:Disable()
oAgeIni:Disable()
oAgeFin:Disable()
oCtaIni:Disable()
oCtaFin:Disable()
oFreIni:Disable()
oFreFin:Disable()

////////////////////////////////
// Somente para pegar RecCount()
// na RecorSet da query (TOP)
IncProc()
dbSelectArea(cAreaTRB)
dbgotop()
dbeval({||nCount++})
dbgotop()
IncProc()

If nCount = 0
	MsgAlert(STR0013) //"Nao existem titulos para gerar bordero pelo filtro acima."

	lProc := .F.

	oDlg:End()

	If Select(cAreaTRB) > 0
		(cAreaTRB)->( dbCloseArea() )
	Endif
	Return Nil
Endif

////////////////////////////
// Ajusta pulo no Obj oMeter
nA := If( nMaxTamMeter>nCount, nMaxTamMeter/nCount, nCount/nMaxTamMeter )
nA := Max( Round(nA,0), nA+1 )

cChave     := "(cAreaTRB)->E1_FORMREC + (cAreaTRB)->E1_PORTADO + (cAreaTRB)->E1_AGEDEP + (cAreaTRB)->E1_CONTA"
cQuebraAnt := &cChave

nB := 0
nC := 0
While (cAreaTRB)->( !Eof() )

	///////////////////////////////
	// Bloqueia titulos que deverao
	// ficar em carteira
	If !VlBqlTR( (cAreaTRB)->E1_FORMREC )
		nB += nA
		(cAreaTRB)->( DbSkip() )
		Loop
	Endif

	dbSelectArea(cAreaTRB)

	cQuebra := &cChave

	nAbatim := SomaAbat(	(cAreaTRB)->E1_PREFIXO, (cAreaTRB)->E1_NUM, (cAreaTRB)->E1_PARCELA, "R", ;
							(cAreaTRB)->E1_MOEDA  ,dDataBase           ,(cAreaTRB)->E1_CLIENTE ,(cAreaTRB)->E1_LOJA)
	nValTit := (cAreaTRB)->E1_SALDO + (cAreaTRB)->E1_SDACRES - (cAreaTRB)->E1_SDDECRE - nAbatim

	////////////////////////////////////////
	// Titulos ja baixados serao desconsiderados...
	If nValTit <= 0
		cQuebraAnt := &cChave
		///////////////////
		oFilTit:cCaption := " - "	+ STR0030 + (cAreaTRB)->E1_FORMREC ; //" TR: "
								+ STR0031 + (cAreaTRB)->E1_PORTADO ; //" Bco: "
								+ STR0032 + (cAreaTRB)->E1_AGEDEP  ; //" Age: "
								+ STR0033 + (cAreaTRB)->E1_CONTA 	  //" Cta: "
		oMeter:Set( nB )

		oNumBor:Refresh()
		oFilTit:Refresh()
		oMeter:Refresh()
		// Atualiza Objetos
		// de Indicacao
		///////////////////
		TRB->( DbSkip() )
		Loop
	Endif

	nB += nA
	nC++

	If ( cQuebraAnt <> cQuebra ) .Or. ( nC == 1 )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica numero do ultimo Bordero Gerado                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cNumBorNew := Soma1(GetMV("MV_NUMBORR"),6)
		While !MayIUseCode( "E1_NUMBOR"+xFilial("SE1")+cNumBorNew)  //verifica se esta na memoria, sendo usado
	        cNumBorNew := Soma1(cNumBorNew)                                                                               // busca o proximo numero disponivel
		EndDo

		dbSelectArea("SX6")
		PutMv("MV_NUMBORR",cNumBorNew)
	Endif

	dbSelectArea(cAreaTRB)

	///////////////////
	// Atualiza Objetos
	// de Indicacao
	oNumBor:cCaption := cNumBorNew
	oFilTit:cCaption := " - "	+ STR0030 + (cAreaTRB)->E1_FORMREC ; //" TR: "
								+ STR0031 + (cAreaTRB)->E1_PORTADO ; //" Bco: "
								+ STR0032 + (cAreaTRB)->E1_AGEDEP  ; //" Age: "
								+ STR0033 + (cAreaTRB)->E1_CONTA 	  //" Cta: "
	oMeter:Set( nB )

	oNumBor:Refresh()
	oFilTit:Refresh()
	oMeter:Refresh()
	// Atualiza Objetos
	// de Indicacao
	///////////////////

	////////////////////////////////////////
	// Array para geracao do Relatorio Final
	Aadd( aPrint,	{	cNumBorNew ,; 				// 1
						(cAreaTRB)->E1_PORTADO ,; 	// 2
						(cAreaTRB)->E1_AGEDEP ,; 	// 3
						(cAreaTRB)->E1_CONTA ,; 	// 4
						(cAreaTRB)->E1_FORMREC ,; 	// 5
						nValTit ,; 					// 6
						(cAreaTRB)->E1_PREFIXO ,; 	// 7
						(cAreaTRB)->E1_NUM ,; 		// 8
						(cAreaTRB)->E1_PARCELA ,; 	// 9
						(cAreaTRB)->E1_TIPO ,; 		// 10
						(cAreaTRB)->E1_CLIENTE ,; 	// 11
						(cAreaTRB)->E1_LOJA ,; 		// 12
					})

	//////////////////
	// Gravacao no SE1
	DbSelectArea("SE1")
	DbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If DbSeek( xFilial("SE1") + (cAreaTRB)->E1_PREFIXO + (cAreaTRB)->E1_NUM + (cAreaTRB)->E1_PARCELA + (cAreaTRB)->E1_TIPO )
		RecLock("SE1",.F.)
			SE1->E1_NUMBOR  := cNumBorNew
			SE1->E1_SITUACA := "1"
		MsUnLock()
	Endif
	// Gravacao no SE1
	//////////////////

	//////////////////
	// Gravacao no SEA
	DbSelectArea("SEA")
	RecLock("SEA",.T.)
		SEA->EA_FILIAL	:= xFilial()
		SEA->EA_NUMBOR	:= cNumBorNew
		SEA->EA_DATABOR	:= dDataBase
		SEA->EA_TIPOPAG	:= (cAreaTRB)->E1_FORMREC
		SEA->EA_PORTADO	:= (cAreaTRB)->E1_PORTADO
		SEA->EA_AGEDEP	:= (cAreaTRB)->E1_AGEDEP
		SEA->EA_NUMCON	:= (cAreaTRB)->E1_CONTA
		SEA->EA_NUM		:= (cAreaTRB)->E1_NUM
		SEA->EA_PARCELA	:= (cAreaTRB)->E1_PARCELA
		SEA->EA_PREFIXO	:= (cAreaTRB)->E1_PREFIXO
		SEA->EA_TIPO	:= (cAreaTRB)->E1_TIPO
		SEA->EA_CART	:= "R"
		SEA->EA_SITUACA	:= "1"
		SEA->EA_SITUANT	:= (cAreaTRB)->E1_SITUACA
		SEA->EA_FILORIG := (cAreaTRB)->E1_FILIAL
		SEA->EA_PORTANT := (cAreaTRB)->E1_PORTADO
		SEA->EA_AGEANT  := (cAreaTRB)->E1_AGEDEP
		SEA->EA_CONTANT := (cAreaTRB)->E1_CONTA
	MsUnlock()
	// Gravacao no SEA
	//////////////////

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada do FA069GRV, permite a gravação de ³
	//³ dados complementares.                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lFA069GRV
		Execblock("FA069GRV",.F.,.F.)
	Endif

	cQuebraAnt := &cChave
	TRB->( DbSkip() )
EndDo

////////////////////
// Ajusta Objetos ao
// final do processo
oBtnPr:Enable()
oTxtPro:Hide()
oTxtTer:Show()
oNumBor:Hide()
oFilTit:Hide()

If MsgYesNo(STR0014) //"Gostaria de imprimir a relacao de bordero gerados ?"
	FINA069Pri()
Else
	lPrint := .F.
Endif

oBtnCa:Enable()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ FINA069Exi ³ Autor ³ Cristiano Denardi     ³ Data ³ 22/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Finaliza rotina, verificando se foi processado e impresso    ³±±
±±³          ³ relacao de titulos processados							    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FINA069Exi()												    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA069		 											    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FINA069Exi()

Local cMsg	:= {}
Local lExit	:= .F.

cMsg := STR0015 //"Embora tenha sido processado, comprovante ainda nao foi impresso."
cMsg += Chr(13)+Chr(10)
cMsg += STR0016 //"Gostaria de imprimir agora ?"

If lProc .And. !lPrint
	If MsgYesNo( cMsg )
		FINA069Pri()
	Else
		lExit := .T.
    Endif
Else
	lExit := .T.
Endif

If lExit
	If Select(cAreaTRB) > 0
		(cAreaTRB)->( dbCloseArea() )
	Endif
	oDlg:End()
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ F069VldCpo ³ Autor ³ Cristiano Denardi     ³ Data ³ 22/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Data ou Codigo e Lj de Cliente.						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA069		 											    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function F069VldCpo( cTipo, dData, cCod1, cCod2, cCod3 )

Local 	lRet 	:= .T.

Default cTipo 	:= ""
Default dData 	:= ""
Default cCod1 	:= ""
Default cCod2 	:= ""
Default cCod3 	:= ""

// Tipos
// D = Data
// C = Codigo Cliente
// L = Loja Cliente
// B = Bco
// A = Agencia
// T = Conta
// R = Forma recebimento

If !Empty( cTipo ) .And. cTipo $ "DCLBATR"
	Do Case
		Case cTipo == "D"
			If Empty(dData)
				lRet := .F.
			Endif

		Case cTipo == "C" // Validacao no campo Codigo
			If !Empty( cCod1 ) .And. ValidZ( cCod1 )
				lRet := ExistCpo("SA1")
			Endif

		Case cTipo == "L" // Validacao no campo Loja
			If !Empty( cCod1 ) .And. !Empty( cCod2 )
				If ValidZ( cCod1 ) .And. ValidZ( cCod2 )
					lRet := ExistCpo("SA1",cCod1+cCod2)
				Endif
			Endif

		Case cTipo == "B"
			If !Empty( cCod1 ) .And. ValidZ( cCod1 )
				lRet := CarregaSA6(@cCod1,,,.T.)
			Endif

		Case cTipo == "A"
			If !Empty( cCod1 ) .And. !Empty( cCod2 )
				If  ValidZ( cCod1 ) .And. ValidZ( cCod2 )
					lRet := CarregaSA6(@cCod1,@cCod2,,.T.)
				Endif
			Endif

		Case cTipo == "T"
			If !Empty( cCod1 ) .And. !Empty( cCod2 ) .And. !Empty( cCod3 )
				If  ValidZ( cCod1 ) .And. ValidZ( cCod2 ) .And. ValidZ( cCod3 )
					lRet := CarregaSA6(@cCod1,@cCod2,@cCod3,.T.)
				Endif
			Endif

		Case cTipo == "R"
			If !Empty( cCod1 ) .And. ValidZ( cCod1 )
				If !ExistCpo("BQL",cCod1)
					lRet := .F.
				Endif
			Endif
	End Case
Else
	MsgAlert( STR0017 ) //"Erro na Validacao do Codigo, favor informar o Administrador"
	lRet := .F.
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ FINA069Pri ³ Autor ³ Cristiano Denardi     ³ Data ³ 22/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime relacao de Titulos Processados e respectivos Borderos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FINA069()												    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA069		 											    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FINA069Pri()

Local 	cDesc1      := STR0018 //"Relatorio com a lista de titulos processados e "
Local 	cDesc2      := STR0019 //"Bordero gerados de forma automatica atraves da "
Local 	cDesc3      := STR0020 //"definicao da Forma de Recebimento."
Local 	titulo      := STR0021 //"Titulos X Bordero (processados)"
Local 	nLin        := 80

Local 	Cabec1      := STR0022 //" N. Bordero"
Local 	Cabec2      := STR0023 //" Bco  Agen   Conta       Tipo de Pagamento                               Valor"
Local 	imprime     := .T.
Local 	aOrd 		:= {}
Private lEnd		:= .F.
Private lAbortPrint	:= .F.
Private CbTxt		:= ""
Private limite		:= 220
Private tamanho		:= "G"
Private nomeprog	:= "FINA069" // Coloque aqui o nome do programa para impressao no cabecalho
Private cPerg		:= "FIR069"
Private nTipo		:= 18
Private aReturn		:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey	:= 0
Private cbcont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private wnrel      	:= nomeprog // Coloque aqui o nome do arquivo usado para impressao em disco

dbSelectArea(cAreaTRB)

Pergunte(cPerg)

wnrel := SetPrint(cAreaTRB,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cAreaTRB)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

lPrint := .T.

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ RUNREPORT  ³ Autor ³ Cristiano Denardi     ³ Data ³ 22/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS   ³±±
±±³          ³ monta a janela com a regua de processamento.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FINA069()												    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA069		 											    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nP		:= 0
Local nQtdBor	:= 0 	// Quantidade de Titulos no Bordero
Local nQtdGer	:= 0 	// Quantidade de Titulos Geral
Local nTotBor	:= 0	// Total por Bordero
Local nTotGer	:= 0	// Total Geral
Local nValTit	:= 0	// Valor do titulo
Local cDescPg	:= ""
Local cBorAnt	:= ""
Local cBorAtu	:= ""
Local cCliAnt	:= ""
Local cCliAtu	:= ""
Local cPict		:= PesqPict("SE1","E1_SALDO")
Local lSinte	:= ( MV_PAR01 == 2 )
Local cDivTot	:= "--------------------"
Local cDivBor	:= "-----------------------------------------------------------------"

SetRegua( Len(aPrint) )

For nP := 1 To Len( aPrint )

	If lAbortPrint
		@nLin,00 PSAY STR0024 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif

	If nLin > 55
		nLin := (Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)+1)

	Endif

	cBorAtu	:= aPrint[nP][1]
	cCliAtu	:= aPrint[nP][11]+aPrint[nP][12]
	If cBorAnt <> cBorAtu
		If nP <> 1
			////////////////////
			// TOTAIS DO BORDERO
			If !lSinte
				@ nLin,77 PSAY cDivTot
				nLin++
			Endif
			@ nLin,30 PSAY STR0025 + Str(nQtdBor,10) + STR0026 //"Total Bordero: "###" titulos "
			@ nLin,77 PSAY nTotBor Picture cPict
			If lSinte
				nLin++
				@ nLin,30 PSAY cDivBor
			Endif
			nLin += 2
		Endif

		cDescPg := DescrBQL( aPrint[nP][5] )

		If nP == 1
			nLin++
		Endif

		@ nLin,01 PSAY aPrint[nP][1] 					// Bordero
		@ nLin,09 PSAY aPrint[nP][2] 					// Banco
		@ nLin,15 PSAY aPrint[nP][3] 					// Agencia
		@ nLin,22 PSAY aPrint[nP][4] 					// Conta
		@ nLin,34 PSAY aPrint[nP][5] + "-" + cDescPg 	// Tipo Recebimento
		nLin++

		/////////////////////////
		// Zera Totais do Bordero
		nTotBor	:= 0
		nQtdBor := 0
	Endif

	nValTit := aPrint[nP][6]
	nTotBor += nValTit
	nTotGer += nValTit
	nQtdBor++
	nQtdGer++

	If !lSinte
		///////////////////////
		// CLIENTE:
		// Somente Imprime nome
		// no primeiro registro
		If ( cCliAnt <> cCliAtu ) .Or. ( cBorAnt <> cBorAtu )
			@ nLin,01 PSAY aPrint[nP][11] 								// Codigo Cliente
			@ nLin,09 PSAY aPrint[nP][12] 								// Loja Cliente
			@ nLin,14 PSAY NomeCli( aPrint[nP][11]+aPrint[nP][12] )	// Nome Cliente
		Endif
		/////////
		// FATURA
		@ nLin,56 PSAY aPrint[nP][07] // Prefixo
		@ nLin,60 PSAY aPrint[nP][08] // Numero
		@ nLin,70 PSAY aPrint[nP][09] // Parcela
		@ nLin,73 PSAY aPrint[nP][10] // Tipo

		////////
		// VALOR
		@ nLin,79 PSAY nValTit Picture cPict

		nLin++
	Endif

	cBorAnt	:= aPrint[nP][1]
	cCliAnt	:= aPrint[nP][11]+aPrint[nP][12]

Next nP

////////////////////
// Total do ultimo
// Bordero
If !lSinte
	@ nLin,77 PSAY cDivTot
Endif
nLin++
@ nLin,30 PSAY STR0025 + Str(nQtdBor,10) + STR0026 //"Total Bordero: "###" titulos "
@ nLin,77 PSAY nTotBor Picture cPict
If lSinte
	nLin++
	@ nLin,30 PSAY cDivBor
Endif
nLin += 2

//////////////
// Total Geral
If !lSinte
	@ nLin,77 PSAY cDivTot
Endif
nLin++
@ nLin,30 PSAY STR0027 + Str(nQtdGer,10) + STR0026 //"  TOTAL GERAL: "###" TITULOS "
@ nLin,77 PSAY nTotGer Picture cPict
nLin += 2

SET DEVICE TO SCREEN

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return Nil

//----------------------------
// Funcoes basicas de auxilio
//----------------------------
//----------------------
// Valida campo com ZZZZ
STATIC Function ValidZ( cTxt )

Local 	lRetz	:= .F.
Default cTxt	:= ""

If Alltrim(Upper(cTxt)) != Repl("Z", Len(Alltrim(cTxt)))
	lRetz := .T.
Endif

Return lRetz

//-----------------------------------
// Valida Existencia de campo na Base
STATIC Function ValidCpo( cAl, cCpo )

Local 	lRetC	:= .T.
Local 	aAr		:= GetArea()
Default cCpo	:= ""
Default cAl		:= ""

If !Empty( cAl ) .And. !Empty( cCpo )
	DbSelectArea( cAl )
	If !( FieldPos(cCpo) > 0 )
		MsgAlert( STR0028 + cCpo + STR0029 ) //"Campo "###" nao existente na base, favor cria-lo."
		lRetC := .F.
	Endif
Else
	lRetC := .F.
Endif

RestArea( aAr )
Return lRetC

//-------------------------------
// Valida Tipo de Recebimento que
// nao serao enviados ao Banco
// Tabela BQL
// Retorno: .T. - envia ao BCO
//          .F. - nao envia ao BCO
STATIC Function VlBqlTR( cCod )

Local 	lRetC	:= .T.
Local 	aAr		:= GetArea()
Default cCod	:= ""

If !Empty( cCod )
	DbSelectArea( "BQL" )
	DbSetOrder(1)
	If DbSeek( xFilial("BQL") + cCod )
		If BQL->BQL_BCOOPE = "0"
			lRetC := .F.
		Endif
	Else
		lRetC := .F.
	Endif
Else
	lRetC := .F.
Endif

RestArea( aAr )
Return lRetC

//-------------------------------
// Busca nome da FORMREC na BQL
STATIC Function DescrBQL( cCod )

Local 	aAr		:= GetArea()
Local 	cNomRet	:= ""
Default cCod	:= ""

If !Empty( cCod )
	DbSelectArea( "BQL" )
	DbSetOrder(1)
	If DbSeek( xFilial("BQL") + cCod )
		cNomRet := Alltrim( BQL->BQL_DESCRI )
	Endif
Endif

RestArea( aAr )
Return cNomRet

//----------------------
// Busca nome do Cliente
STATIC Function NomeCli( cCod )

Local 	aAr		:= GetArea()
Local 	cNomRet	:= ""
Default cCod	:= ""

If !Empty( cCod )
	DbSelectArea( "SA1" )
	DbSetOrder(1)
	If DbSeek( xFilial("SA1") + cCod )
		cNomRet := Alltrim( SA1->A1_NOME )
	Endif
Endif

RestArea( aAr )
Return cNomRet
