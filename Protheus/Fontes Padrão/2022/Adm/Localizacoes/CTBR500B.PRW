#INCLUDE "CTBR500B.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE C_CONTA		1
#DEFINE C_DESC			2
#DEFINE C_SITNORMAL	3
#DEFINE C_NIVEL    	4
#DEFINE C_IDENTIFI		5

#DEFINE C_SALDOS  		5    
#DEFINE C_SALDOSEM		6
#DEFINE C_SALDOATU		7
#DEFINE C_SALDOANT		8

#DEFINE C_TOTAL   		9
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Ctbr500B	³ Autor ³ Wagner Mobile Costa	³ Data ³ 08.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Demostrativo de balancos patrimoniais  		 		  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbR500B()
Private aSelFil	 	:= {}
Private aFieldSM0 := {"M0_NOME", "M0_FILIAL", "M0_CGC"}
Private aDatosEmp := IIf (cVersao <> "11" ,FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, aFieldSM0),"")
Private cRUC	  := Trim(IIf (cVersao <> "11" ,aDatosEmp[3][2],SM0->M0_CGC))


	CTBR500AR4()
	//Limpa os arquivos temporários 
	CTBGerClean()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CTBR500R4 ³ Autor³ Daniel Sakavicius		³ Data ³ 14/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Demostrativo de balancos patrimoniais - R4		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CTBR115R4												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                    				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTBR500AR4()                           
Local aSetOfBook	
Local aCtbMoeda		:= {}
Local cDescMoeda 	:= ""
Local lRet          := .T.

Private cPerg	   	:= "CTR500"     
Private aSelFil		:={}
          
If ! CtrVld500(cPerg)
	Return
EndIf

// Faz a validacao das filiais
If lRet .And. mv_par14 == 1 .And. Len( aSelFil ) <= 0 
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		lRet := .F.
	EndIf                             
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// faz a validação do livro
If ! Empty( mv_par02 ) 
	If ! VdSetOfBook( mv_par02 , .F. )
		lRet := .F.
	EndIf
EndIf

If lRet
	// seta o livro
	aSetOfBook := CTBSetOf(mv_par02)
	// seta a moeda
	aCtbMoeda	:= CtbMoeda(mv_par03, aSetOfBook[9])
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		Return .F.
	EndIf	
        
	cDescMoeda 	:= AllTrim(aCtbMoeda[3])
	oReport := ReportDef(aSetOfBook, aCtbMoeda, cDescMoeda)      
	oReport :PrintDialog()
EndIf

Return                                

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Daniel Sakavicius		³ Data ³ 15/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Esta funcao tem como objetivo definir as secoes, celulas,   ³±±
±±³          ³totalizadores do relatorio que poderao ser configurados     ³±±
±±³          ³pelo relatorio.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                    				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(aSetOfBook, aCtbMoeda, cDescMoeda)  

Local cREPORT		:= "CTBR500B"
Local cTitulo		:= Capital(STR0001)		// "INVENTARIOS Y BALANCES - ESTADO DE RESULTADOS"
Local cDESC			:= STR0001				// "INVENTARIOS Y BALANCES - ESTADO DE RESULTADOS"
Local aTamDesc		:= TAMSX3("CTS_DESCCG")  
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local nTamAux		:= 20
Local dFinal 		:= CtoD(Space(8))

cTitulo := If(! Empty(aSetOfBook[10]), aSetOfBook[10], cTitulo )		// Titulo definido SetOfBook  
If Valtype(mv_par13)=="N" .And. (mv_par13 == 1)
	cTitulo := CTBNomeVis( aSetOfBook[5] )
EndIf
                         
//Filtra Filiais
If mv_par14 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil()
EndIf
 
If Empty(MV_PAR09)
	While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
		dFinal	:= CTG->CTG_DTFIM
		CTG->(DbSkip())
	EndDo
Else
	dFinal:= MV_PAR09
EndIf     

nAno := Year(dFinal)

If mv_par04 = 1
	cTitCol := STR0005
Else
	cTitCol	:= Dtoc(dFinal)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport	:= TReport():New( cREPORT,cTitulo,cPerg,;
	{ |oReport| Pergunte(cPerg,.F.), Iif(ReportPrint(oReport,@cTitulo,dFinal), .T., oReport:CancelPrint())}, cDESC)
oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataBase,cTitulo,,,,,oReport) } )                                        		
oReport:ParamReadOnly()

If GETNEWPAR("MV_CTBPOFF",.T.)
	oReport:SetEdit(.F.)
EndIf	

// Define o tamanho da fonte a ser impressa no relatorio
oReport:nFontBody := 6

oSection1  := TRSection():New( oReport, STR0008, {"cArqTmp"},, .F., .F. )      // "Detalle"
          
TRCell():New( oSection1, "ATIVO"     , ,STR0003+cDescMoeda+")"  /*Titulo*/,/*Picture*/,aTamDesc[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)                             // "Descripción"
TRCell():New( oSection1, "ASEMESTRE" , ,STR(nAno)+CRLF+STR0004  /*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER") // "Semestre"
TRCell():New( oSection1, "AEXERCICIO", ,cTitCol                 /*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER") 
TRCell():New( oSection1, "AEXERANT"  , ,STR(nAno-1)+CRLF+STR0005/*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER") // "Ejercicio /Periodo"

oSection1:SetTotalInLine(.F.)

/* GESTAO - inicio */
/* Relacao das filiais selecionadas para compor o relatorio */
oSecFil := TRSection():New(oReport,"SECFIL")

TRCell():New(oSecFil,"CODFIL",,"Código",/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecFil,"EMPRESA",,"Empresa",/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecFil,"UNIDNEG",,"Unidade de negócio",/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecFil,"NOMEFIL",,"Filial",/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)
/* GESTAO - fim */             
Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³ Daniel Sakavicius    ³ Data ³ 15/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime o relatorio definido pelo usuario de acordo com as  ³±±
±±³          ³secoes/celulas criadas na funcao ReportDef definida acima.  ³±±
±±³          ³Nesta funcao deve ser criada a query das secoes se SQL ou   ³±±
±±³          ³definido o relacionamento e filtros das tabelas em CodeBase.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportPrint(ExpO1,ExpC1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Obj. do relatorio	                              ³±±
±±³          ³ ExpC1 = Titulo do relatorio (sera' atualizado conf. param.)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³EXPO1: Objeto do relatorio                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint( oReport,Titulo, dFinal )  

Local oSection1 	:= oReport:Section(1)  
Local aSetOfBook	:= CTBSetOf(mv_par02)
Local aCtbMoeda		:= {}
Local cArqTmp
Local cPicture
Local aColunas		:= { {}, {} }
Local aMaxCol		:= {	{ "", "", "", 0, 0, 0.00, 0.00, 0.00, 0 },;
							{ "", "", "", 0, 0, 0.00, 0.00, 0.00, 0 } }
Local nMaxCol 		:= 0
Local nPosCol		:= 0
Local nColuna		:= 1
Local nCelula		:= 0
Local lSemestre
Local lPeriodoAnt 	:= (mv_par10 == 1)
Local aPosCol
Local lColuna		:= .F.
Local cTpValor		:= GetMV("MV_TPVALOR")
Local lImpTrmAux	:= (mv_par06 == 1)
Local cArqTRM		:= ""                                       
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local cMoedaDesc	:= mv_par11 
Local nTamEmp		:= 0
Local nTamUnNeg		:= 0
Local nTamTit		:= 0
Local cFilSel		:= ""
Local cTitulo		:= ""
Local oSecFil		:= oReport:Section("SECFIL") 
Local aSM0			:= {}  
Local nX 			:= 0
Local lCharSinal	:= .F.
Local lAutomato  	:= FWIsInCallStack("UTSTARTRPT") .And. cPerg == "CTR500"


oReport:SetPageNumber( MV_PAR05 )

If  Empty(CTBSetOf(mv_par02)[5])
	ApMsgAlert(	STR0006) //"Los informes contables deben tener obligatoriamente un plan de gestion asociado al libro. íVerifique la configuracion de libros elegida!"
	Return .F.
Endif

/* imprime a lista de filiais selecionadas para o relatorio */
If Len(aSelFil) > 1
	aSM0 := FWLoadSM0()
	nTamEmp := Len(FWSM0LayOut(,1))
	nTamUnNeg := Len(FWSM0LayOut(,2))
	cTitulo := oReport:Title()
	oReport:SetTitle(cTitulo + " (" + "Filiais selecionadas para o relatorio" + ")")
	nTamTit := Len(oReport:Title())
	oSecFil:Init()  
	oSecFil:Cell("CODFIL"):SetBlock({||cFilSel})
	oSecFil:Cell("EMPRESA"):SetBlock({||aSM0[nLinha,SM0_DESCEMP]})
	oSecFil:Cell("UNIDNEG"):SetBlock({||aSM0[nLinha,SM0_DESCUN]})
	oSecFil:Cell("NOMEFIL"):SetBlock({||aSM0[nLinha,SM0_NOMRED]})

	For nX := 1 To Len(aSelFil)
		nLinha := Ascan(aSM0,{|sm0|,sm0[SM0_CODFIL] == aSelFil[nX]})
		If nLinha > 0
			cFilSel := Substr(aSM0[nLinha,SM0_CODFIL],1,nTamEmp)
			cFilSel += " "
			cFilSel += Substr(aSM0[nLinha,SM0_CODFIL],nTamEmp + 1,nTamUnNeg)
			cFilSel += " "
			cFilSel += Substr(aSM0[nLinha,SM0_CODFIL],nTamEmp + nTamUnNeg + 1)
			oSecFil:PrintLine()
		Endif
	Next
	oReport:SetTitle(cTitulo)
	oSecFil:Finish()
	oReport:EndPage()
Endif
/* GESTAO - fim */  

If mv_par04 = 1 .And. Month(dFinal) > 6
	dSemestre := Ctod("30/06/" + Str(Year(dFinal), 4))
Endif

If !lPeriodoAnt
	dFinalA := dFinal-1     	
ElseIf  Substr(dtoc(dFinal),1,5) == "29/02" // Validacao para anos bissextos
	dFinalA := Ctod("28/02/" + Str(Year(dFinal) - 1, 4))       
Else
	dFinalA := Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 1, 4))   
Endif

lSemestre	:= mv_par04 = 1 .And. Month(dFinal) > 6
aPosCol		:= {	{  175, If(lSemestre, 740 ,), 1050, If(lPeriodoAnt,1370,), 1630 },;
					{ 1695, If(lSemestre, 2220,), 2540, If(lPeriodoAnt,2860,), 3120 }	}
aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])

If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)
cPicture 	:= aSetOfBook[4]
lComNivel	:= .T.
m_pag := mv_par05

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(	oMeter, oText, oDlg, @lEnd,@cArqTmp,;
						dFinalA+1,dFinal,"","","",Repl("Z", Len(CT1->CT1_CONTA)),;
		   				"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
		   				"",Repl("Z", Len(CTH->CTH_CLVL)),mv_par03,;
		   				MV_PAR12,aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30);
		   				,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,cMoedaDesc,,aSelFil)},;
			STR0002, Titulo) //"Creando archivo temporal..."

dbSelectArea("cArqTmp")
dbGoTop()
lColuna	:= FieldPos("COLUNA") > 0

While !Eof()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³indica se a entidade gerencial sera impressa/visualizada em ³
	//³um relatorio ou consulta apos o processamento da visao      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cArqTmp->VISENT == "2"
		cArqTmp->( DbSkip() )
		Loop
	EndIf

	If cArqTmp->IDENTIFI = "4"
		aMaxCol[nColuna][C_CONTA] 		:= cArqTmp->CONTA
		aMaxCol[nColuna][C_DESC] 		:= cArqTmp->DESCCTA
		aMaxCol[nColuna][C_SITNORMAL]	:= cArqTmp->NORMAL
		aMaxCol[nColuna][C_NIVEL]		:= cArqTmp->NIVEL
		aMaxCol[nColuna][C_IDENTIFI]	:= "4"
		aMaxCol[nColuna][C_SALDOANT] 	+= cArqTmp->SALDOANT
		aMaxCol[nColuna][C_SALDOATU] 	+= cArqTmp->SALDOATU
		If lSemestre
			aMaxCol[nColuna][C_SALDOSEM] += cArqTmp->SALDOSEM
		EndIf
	Else
		Aadd(aColunas[nColuna], { 	cArqTmp->CONTA, cArqTmp->DESCCTA, cArqTmp->NORMAL, cArqTmp->NIVEL, cArqTmp->IDENTIFI,;
									If(lSemestre, cArqTmp->SALDOSEM, 0), cArqTmp->SALDOATU, cArqTmp->SALDOANT })
		aMaxCol[nColuna][C_TOTAL] ++
	EndIf

	DbSkip()
EndDo

If aMaxCol[1][C_TOTAL] > aMaxCol[1][C_TOTAL]
	nMaxCol := aMaxCol[1][C_TOTAL]
Else
	nMaxCol := aMaxCol[1][C_TOTAL]
EndIf

DbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
 
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIf
	
dbselectArea("CT2")
nCol1Pos	:= 0
nCol1Pos	:= 0

If  ! lSemestre
	oSection1:Cell("ASEMESTRE"):Disable()
EndIf

If  ! lPeriodoAnt
	oSection1:Cell("AEXERANT"):Disable()
Else
	If  ! lSemestre	
		oSection1:Cell("AEXERANT"):SetTitle(DTOC(dFinalA))
	EndIf	
EndIf

If  ! lSemestre	
	oSection1:Cell("AEXERCICIO"):SetTitle(DTOC(dFinal))
EndIf

oSection1:Init()
aTamVal[1] += 8

For nColuna := 1 To nMaxCol
	nCol1Pos++

	If nCol1Pos > Len(aColunas[1]) .and. nCol1Pos > Len(aColunas[2])
		Exit
	EndIf

	oSection1:Cell("ATIVO"):SetBlock( { || aColunas[1][nCol1Pos][C_DESC] } )

	If aColunas[1][nCol1Pos][C_IDENTIFI] < "5"
		For nPosCol := 2 To Len(aPosCol[1]) - 1
			If aPosCol[1][nPosCol] # Nil
				nCelula := ( C_SALDOS + nPosCol - 1 )
				If nCelula == 6 .And. lSemestre
					oSection1:Cell("ASEMESTRE")		:SetBlock( { || ValorCTB( aColunas[1][nCol1Pos][6],,,aTamVal[1],nDecimais,.T.,cPicture,;
																aColunas[1][nCol1Pos][C_SITNORMAL],aColunas[1][nCol1Pos][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
				ElseIf nCelula == 7
					oSection1:Cell("AEXERCICIO")	:SetBlock( { || ValorCTB( aColunas[1][nCol1Pos][7],,,aTamVal[1],nDecimais,.T.,cPicture,;
																aColunas[1][nCol1Pos][C_SITNORMAL],aColunas[1][nCol1Pos][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
				ElseIf nCelula == 8 .And. lPeriodoAnt
							oSection1:Cell("AEXERANT")		:SetBlock( { || ValorCTB( aColunas[1][nCol1Pos][8],,,aTamVal[1],nDecimais,.T.,cPicture,;
       									                        aColunas[1][nCol1Pos][C_SITNORMAL],aColunas[1][nCol1Pos][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
				EndIf
			EndIf
		Next
			//Somente para Linha Sem Valor
	ElseIf aColunas[1][nCol1Pos][C_IDENTIFI] == "5"
		For nPosCol := 2 To Len(aPosCol[1]) - 1
			If aPosCol[1][nPosCol] # Nil
				nCelula := ( C_SALDOS + nPosCol - 1 )
				If nCelula == 6 .And. lSemestre
					oSection1:Cell("ASEMESTRE") :SetBlock( { || " " } )
				ElseIf nCelula == 7
					oSection1:Cell("AEXERCICIO"):SetBlock( { || " " } )
				ElseIf nCelula == 8 .And. lPeriodoAnt
					oSection1:Cell("AEXERANT")  :SetBlock( { || " " } )
				EndIf
			EndIf
		Next									
	EndIf
	oSection1:PrintLine()
Next

oSection1:Cell("ATIVO"):SetBlock( { || aMaxCol[1][C_DESC] } )

For nPosCol := 2 To Len(aPosCol[1])
	nCelula := (C_SALDOS + nPosCol - 1)
	If ( aPosCol[1][nPosCol] <> Nil ) .And. ( nCelula < Len(aMaxCol[1]) )
		If nCelula == 6 .And. lSemestre
			oSection1:Cell("ASEMESTRE"):SetBlock( { || ValorCTB( aMaxCol[1][6],,,aTamVal[1],nDecimais,.T.,cPicture,;
                                		                         aMaxCol[1][C_SITNORMAL],aMaxCol[1][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
		ElseIf nCelula == 7
			oSection1:Cell("AEXERCICIO"):SetBlock( { || ValorCTB( aMaxCol[1][7],,,aTamVal[1],nDecimais,.T.,cPicture,;
                                		                         aMaxCol[1][C_SITNORMAL],aMaxCol[1][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
		ElseIf nCelula == 8 .And. lPeriodoAnt
			oSection1:Cell("AEXERANT"):SetBlock( { || ValorCTB( aMaxCol[1][8],,,aTamVal[1],nDecimais,.T.,cPicture,;
                                		                         aMaxCol[1][C_SITNORMAL],aMaxCol[1][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
		EndIf
	EndIf                              
Next

oSection1:PrintLine()
oSection1:Finish()

If !lAutomato
	If IsBlind() .OR. ( lImpTrmAux .And. MsgYesNo(STR0009) )  //"¿Imprime Termino en la Proxima Pagina?"
		oReport:EndPage()
	EndIf

	If lImpTrmAux
		cArqTRM 	:= mv_par07
		

	
		If !File(cArqTRM)
			aSavSet:=__SetSets()
			cArqTRM := CFGX024(cArqTRM,STR0007) // "Responsables..."
			__SetSets(aSavSet)
			Set(24,Set(24),.t.)
		EndIf

		If cArqTRM#NIL
			ImpTerm2(cArqTRM,,,,,oReport)
		EndIf	 
	EndIf
EndIf

If MV_PAR15 == 1
	Processa({|| GerArq(AllTrim(MV_PAR16),dFinal,aColunas,aTamVal,nDecimais,cPicture,cTpValor,lCharSinal)},,STR0013) // "Generando archivo ..."
EndIf

oReport:EndPage()
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ GerArq   ³ Autor ³ V Flores            ³ Data ³ 16.04.2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ 3.20 LIBRO DE INVENTARIOS Y BALANCES                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cDir      - Diretorio donde se creara el archivo.          ³±±
±±³            ³ aColunas  - Array con los Códigos del Edo Financiero.      ³±±
±±³            ³ aTamVal   - Array con el Tamaño del Valor.                 ³±±
±±³            ³ nDecimais - Número de Decimales.                           ³±±
±±³            ³ cTpValor  - Valor del Parametro MV_TPVALOR.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Peru                  - Arquivo Magnetico           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GerArq(cDir, dFinal, aColunas, aTamVal, nDecimais, cPicture, cTpValor, lCharSinal)

Local nHdl		:= 0
Local cLin		:= ""
Local cSep		:= "|"
Local cArq		:= ""
Local nColuna	:= 1
Local nColPos	:= 0
Local cValor	:= ""

If !(Right(cDir,1) == "\")
	cDir += "\"
EndIf

cArq += "LE"					// Fixo  'LE'
cArq +=  AllTrim(cRUC)			// Ruc
cArq +=  DtoS(dFinal)			// Fecha AAAAMMDD
cArq +=  "032000"				// Id Libro

If Month(dFinal) == 12		// Oportunidad de presentación
	cArq += "01"
ElseIf Month(dFinal) == 1
	cArq += "02"
ElseIf Month(dFinal) == 6
	cArq += "04"
Else
	cArq += "07"
EndIf

cArq += "1"						// I. Operaciones
cArq += "1"						// I. de contenido del libro/registro
cArq += "1"						// Moneda (soles)
cArq += "1"						// Generado por PLE
cArq += ".TXT"					// Extensao

nHdl := fCreate(cDir+cArq)

If nHdl <= 0
	ApMsgStop(STR0011) // "Error al crear archivo TXT"
	Return Nil

Else
	For nColPos := 1 To Len(aColunas[nColuna])

		If Alltrim(aColunas[nColuna][nColPos][C_DESC]) == "-"
			Loop
		EndIf
	
		If mv_par08 <> 1				// Se Imprime Valor Zerado = Não
			If ! (aColunas[nColuna][nColPos][C_IDENTIFI] < "5" .And. (aColunas[nColuna][nColPos][C_SALDOS + 2] <> 0 .Or. aColunas[nColuna][nCol1Pos][C_NIVEL]==1))
				Loop
			EndIf
		EndIf

		If aColunas[nColuna][nColPos][C_IDENTIFI] == "5"
			Loop
		EndIf
		cLin := ""

		//01 - Periodo
		cLin += DtoS(dFinal)
		cLin += cSep			

		//02 - Código de catálogo
		cLin += "09"
		cLin += cSep			

		//03 - Código del rubro del estado financiero
		cLin += Trim(aColunas[nColuna][nColPos][C_CONTA])
		cLin += cSep

		//04 - Saldo
		cValor := ValorCTB( aColunas[nColuna][nColPos][7],,,15,2,.T.,"@E 999999999999.99",aColunas[nColuna][nColPos][C_SITNORMAL],aColunas[nColuna][nColPos][C_CONTA],,,cTpValor,,,.F.,,lCharSinal)
		cLin += lTrim(cValor) + cSep

		//05 - Estado operación
		cLin += "1"
		cLin += cSep			

		cLin += CRLF
		fWrite(nHdl,cLin)

	Next nColPos

fClose(nHdl)
MsgAlert(STR0012) // "Archivo TXT generado con éxito."
EndIf
Return Nil
