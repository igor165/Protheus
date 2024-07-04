#INCLUDE "ctbr401.ch"
#Include "PROTHEUS.Ch"

#DEFINE TAM_VALOR	20
#DEFINE TAM_CONTA  17

// 17/08/2009 -- Filial com mais de 2 caracteres
//Tradução PTG 20080721

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CTBR401  ³ Autor ³ Paulo Augusto              ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CUCA                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CTBR401()                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso 		 ³ SIGACTB                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ BOPS     ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   Marco A.  ³16/04/18³DMINA-2310³Se remueven sentencias CriaTrab y se apli-³±±
±±³             ³        ³          ³ca FWTemporaryTable(), para el manejo de  ³±±
±±³             ³        ³          ³las tablas temporales.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CTBR401(	cContaIni, cContaFim, dDataIni, dDataFim, cMoeda, cSaldos,;
					cBook, lCusto, cCustoIni, cCustoFim, lItem, cItemIni, cItemFim,;
					lClVl, cClvlIni, cClvlFim,lSaltLin)

Local oReport	:= Nil          
Local aArea		:= GetArea()
Local aCtbMoeda	:= {}
Local cArqTmp	:= ""
Local lOk		:= .T.

DEFAULT lCusto		:= .F.
DEFAULT lItem		:= .F.
DEFAULT lCLVL		:= .F.
DEFAULT lSaltLin	:= .T.

Private cTipoAnt	:= ""
Private cPerg	 	:= "CTR401"
Private nomeProg  	:= "CTBR401"  
Private nSldATransp	:= 0 // Esta variavel eh utilizada para calcular o valor de transporte
Private nSldDTransp	:= 0
Private oTmpTable	:= Nil
Private aOrdem		:= {}

Pergunte("CTR401", .T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lOk
	aCtbMoeda  	:= CtbMoeda(mv_par04) // Moeda?
   If Empty(aCtbMoeda[1])
      Help(" ",1,"NOMOEDA")
      lOk := .F.
   Endif
Endif 

If lOk	
	lCusto	:= .F.
	lItem	:= .F.
	lCLVL	:= .F.
			
	oReport := ReportDef(aCtbMoeda,lCusto,lItem,lCLVL,@cArqTmp)
	oReport:PrintDialog()
	             
	If oTmpTable <> Nil
		dbSelectArea("cArqTmp")
		cArqTmp->(dbCloseArea())
		oTmpTable:Delete()
		oTmpTable := Nil
	EndIf
		
EndIf

RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ReportDef º Autor ³ Paulo Augusto      ³ Data ³ 20.12.06   ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definicao do objeto do relatorio personalizavel e das      º±±
±±º          ³ secoes que serao utilizadas                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aCtbMoeda  - Matriz ref. a moeda                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef(aCtbMoeda,lCusto,lItem,lCLVL,cArqTmp)

Local oReport
Local oSection1
Local oSection2 
Local oSection3 

Local cDesc1		:= STR0001 //"Este programa ir  imprimir o Conta,"
Local cDesc2		:= STR0002 //"Capital de Aportacao Atualizada de acordo com os "
Local cDesc3		:= STR0003 //"parametros solicitados pelo usuario."
Local titulo		:= STR0004 //"Emissao do Conta Capital"
Local cNormal		:= ""
Local aTamInpc	:=	TAMSX3("IE_INDICE")
Local cPictInpc	:=	PesqPict("SIE","IE_INDICE")
Local aTamConta	:= TAMSX3("CT1_CONTA")
Local aTamCusto	:= TAMSX3("CT3_CUSTO")
Local nTamConta	:= Len(CriaVar("CT1_CONTA"))
Local nTamHist	:= Len(CriaVar("CT2_HIST"))
Local nTamItem	:= Len(CriaVar("CTD_ITEM"))
Local nTamCLVL	:= Len(CriaVar("CTH_CLVL"))
Local nDigitAte		:= 0
Local aSetOfBook := CTBSetOf("   ")// Set Of Books	
Local cPicture 		:= aSetOfBook[4]
Local cDescMoeda 	:= aCtbMoeda[2]
Local nDecimais 	:= DecimalCTB(aSetOfBook,mv_par04)// Moeda

oReport := TReport():New(nomeProg,titulo,cPerg, {|oReport| ;
			ReportPrint(oReport,aCtbMoeda,aSetOfBook,cPicture,cDescMoeda,nDecimais,nTamConta,.T.,lCusto,lItem,lCLVL,cArqTmp)},cDesc1+cDesc2+cDesc3)
oReport:SetTotalInLine(.F.)
oReport:EndPage(.T.)

oReport:SetPortrait(.T.)
	
// oSection1
oSection1 := TRSection():New(oReport,"Conta",{"cArqTmp"},/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/)

oSection1:SetPageBreak(.T.)

TRCell():New(oSection1,"CONTA"	,"cArqTmp",STR0005,/*Picture*/,aTamConta[1],/*lPixel*/,/*{|| }*/)	 //"CONTA "
TRCell():New(oSection1,"DESCCC"	,"cArqTmp",STR0006,/*Picture*/,nTamConta,/*lPixel*/,/*{|| }*/)		 //"DESCRICAO"

oSection1:OnPrintLine( {|| oReport:SkipLine() } )

// oSection2
oSection2 := TRSection():New(oReport,STR0007,{"cArqTmp","CT2"},/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/)	 //"Custo"
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderPage(.T.)

If cPaisLoc $ "CHI|ARG"
 	TRCell():New(oSection2,"SEGOFI"	,"",STR0036,/*Picture*/,15,/*lPixel*/,{|| cArqTmp->SEGOFI }) // "CORRELATIVO"
EndIf

TRCell():New(oSection2,"Movimento"	,"",STR0008,/*Picture*/,15,/*lPixel*/,/*{|| }*/)	 //"MOVIMENTOS"
TRCell():New(oSection2,"DATAL"		,"cArqTmp",STR0009,/*Picture*/,10,/*lPixel*/,/*{|| }*/)	//  //"DATA"
TRCell():New(oSection2,"LANCDEB"	,"cArqTmp",STR0021,/*Picture*/,TAM_VALOR,/*lPixel*/,{|| ValorCTB(cArqTmp->LANCDEB,,,TAM_VALOR,nDecimais,.T.,cPicture,/*"1"*/,,,,,,.T.,.F.) },"RIGHT",,"RIGHT") //"AUMENTO"
TRCell():New(oSection2,"LANCCRD"	,"cArqTmp",STR0010,/*Picture*/,TAM_VALOR,/*lPixel*/,{|| ValorCTB(cArqTmp->LANCCRD,,,TAM_VALOR,nDecimais,.T.,cPicture,/*"2"*/,,,,,,.T.,.F.) },"RIGHT",,"RIGHT")// "CREDITO" //"DIMINUICAO"
TRCell():New(oSection2,"INPC" 		,"",STR0012+CHR(13)+CHR(10)+ STR0013,cPictInpc,aTamInpc[1],/*lPixel*/,/*{|| }*/)	// "DATA" //"INPC"###"INPC DO"###"  MES"
TRCell():New(oSection2,"ULTINPC"	,"",STR0014+CHR(13)+CHR(10)+ STR0015,cPictInpc/*Picture*/,aTamInpc[1],/*lPixel*/,/*{|| }*/)	// "DATA" //"ULTIMO INPC"###"     ACT."
TRCell():New(oSection2,"FTATUAL"	,"",STR0016+CHR(13)+CHR(10)+ STR0017,"@e 999.99999"/*Picture*/,9,/*lPixel*/,/*{|| }*/)	// "DATA" //"    FATOR"###"ATUALIZACAO"
TRCell():New(oSection2,"TPSLDATU"	,"",STR0018+CHR(13)+CHR(10)+STR0019,/*Picture*/,TAM_VALOR,/*lPixel*/,/*{|| }*/)	// "DATA" //"    SALDO"###"ATUALIZADO"

// oSection3 - Totais das sessoes	
oSection3 := TRSection():New( oReport,STR0020,,, .F., .F. )	//"Totais" //"Saldo Final"
TRCell():New(oSection3,"TOT"			,"",STR0020,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)	//"DESCRICAO" //"SALDO FINAL"
TRCell():New(oSection3,"DATAL"			,"",STR0009,/*Picture*/,10,/*lPixel*/,/*{|| }*/)	// "DATA" //"DATA"
TRCell():New(oSection3,"TOT_DEBITO"		,"",STR0021,/*Picture*/,TAM_VALOR,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,"RIGHT")	// "DEBITO" //"AUMENTO"
TRCell():New(oSection3,"TOT_CREDITO"	,"",STR0010,/*Picture*/,TAM_VALOR,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,"RIGHT")	// "CREDITO" //"DIMINUICAO"
TRCell():New(oSection3,"INPC"			,"",STR0014+CHR(13)+CHR(10)+ "ACT.",cPictInpc,aTamInpc[1],/*lPixel*/,,"RIGHT",,"RIGHT")// "CREDITO" //"ULTIMO INPC"
TRCell():New(oSection3,"ULTINPC"		,"",STR0016+CHR(13)+CHR(10)+ STR0017,cPictInpc,aTamInpc[1],/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")// "SALDO ATUAL" //"    FATOR"###"ATUALIZACAO"
TRCell():New(oSection3,"FTATUAL"		,"",STR0018+CHR(13)+CHR(10)+STR0019,"@E 999.99999"/*Picture*/,9,/*lPixel*/,,"RIGHT",,"RIGHT")// "CREDITO" //"    SALDO"###"ATUALIZADO"
TRCell():New(oSection3,"TOT_ATU"		,"",STR0022,/*Picture*/,TAM_VALOR,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,"RIGHT")	// "SALDO ATUAL" //"SALDO ATUAL"
oSection3:Cell("TOT_DEBITO"):HideHeader()
oSection3:Cell("TOT_CREDITO"):HideHeader()
oSection3:Cell("TOT_ATU"):HideHeader()    
oSection3:Cell("ULTINPC"):HideHeader()
oSection3:Cell("FTATUAL"):HideHeader()
oSection3:Cell("TOT_ATU"):HideHeader()
oSection3:Cell("INPC"):HideHeader()
oSection3:Cell("DATAL"):HideHeader()

// oSection4 - Complemento
oSection4 := TRSection():New( oReport,STR0023,,, .F., .F. )	 //"Complemento"
TRCell():New(oSection4,"COMP","",STR0023,/*Picture*/,17+nTamHist+aTamConta[1],/*lPixel*/,/*{|| code-block de impressao }*/)	 //"COMPLEMENTO"
oSection4:Cell("COMP"):HideHeader()

oReport:ParamReadOnly() 

TRPosition():New( oSection2, "CT2", 1,;
	{|| xFilial("CT2")+cArqTmp->(DtoS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+mv_par05+EMPORI+FILORI+mv_par04) } )

Return oReport

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportPrintº Autor ³ Paulo Augusto      ³ Data ³ 20.12.06   ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definicao do objeto do relatorio personalizavel e das      º±±
±±º          ³ secoes que serao utilizadas                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportPrint(oReport,aCtbMoeda,aSetOfBook,cPicture,cDescMoeda,nDecimais,nTamConta,lAnalitico,lCusto,lItem,lCLVL,cArqTmp)

Local oSection1 	:= oReport:Section(1)
Local oSection2		:= oReport:Section(2)
Local oSection3		:= oReport:Section(3)

Local cFiltro	:= oSection2:GetAdvplExp()
Local aSaldo		:= {}
Local aSaldoAnt		:= {}

Local cContaIni		:= mv_par01 // da conta
Local cContaFIm		:= mv_par01 // ate a conta 
Local cMoeda		:= mv_par04 // Moeda
Local cSaldo		:= mv_par05 // Saldos
Local cCustoIni		:= " "
Local cCustoFim		:= " "
Local cItemIni		:= " "
Local cItemFim		:= " "
Local cCLVLIni		:= " "
Local cCLVLFim		:= " "
Local cContaAnt		:= ""
Local cDescConta	:= ""
Local cCodRes		:= ""
Local cResCC		:= ""
Local cResItem		:= ""
Local cResCLVL		:= ""
Local cDescSint		:= ""
Local cContaSint	:= ""
Local cNormal 		:= ""

Local xConta		:= ""

Local cSepara1		:= ""
Local cSepara2		:= ""
Local cSepara3		:= ""
Local cSepara4		:= ""
Local cMascara1		:= ""
Local cMascara2		:= ""
Local cMascara3		:= ""
Local cMascara4		:= ""

Local dDataAnt		:= CTOD("  /  /  ")
Local dDataIni		:= mv_par02 // da data
Local dDataFim		:= mv_par03 // Ate a data

Local nPagIni		:= mv_par08 // Pagina Inicial 
Local nReinicia 	:= mv_par10 // Numero da Pag p/ Reiniciar 
Local nPagFim		:= mv_par09 // Pagina Final 

Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotGerDeb	:= 0
Local nTotGerCrd	:= 0
Local nVlrDeb		:= 0
Local nVlrCrd		:= 0
Local nCont			:= 0

Local lNoMov		:= .T. // Imprime conta sem movimento?
Local lSldAnt		:= .F. // Imprime conta sem movimento?

Local lEmissUnica	:= If(GetNewPar("MV_CTBQBPG","M") == "M",.T.,.F.)			/// U=Quebra única (.F.) ; M=Multiplas quebras (.T.)
Local lSldAntCta	:= Iif(mv_par11 == 1, .T.,.F.)// Saldo Ant. nivel?Cta/C.C/Item/Cl.Vlr
Local nTaxaAtu	:= 0
Local lPrimVz:=.T.
Local nTaxaAnt:=0
	// Mascara da Conta
	cMascara1 := IIf (Empty(aSetOfBook[2]),GetMv("MV_MASCARA"),RetMasCtb(aSetOfBook[2],@cSepara1) )
	
	If lCusto .Or. lItem .Or. lCLVL
		// Mascara do Centro de Custo
		cMascara2 := IIf ( Empty(aSetOfBook[6]),GetMv("MV_MASCCUS"),RetMasCtb(aSetOfBook[6],@cSepara2) )
		// Mascara do Item Contabil
		dbSelectArea("CTD")
		cMascara3 := IIf ( Empty(aSetOfBook[7]),ALLTRIM(STR(Len(CTD->CTD_ITEM))) , RetMasCtb(aSetOfBook[7],@cSepara3) )
		// Mascara da Classe de Valor
		dbSelectArea("CTH")
		cMascara4 := IIf ( Empty(aSetOfBook[8]) , ALLTRIM(STR(Len(CTH->CTH_CLVL))) , RetMasCtb(aSetOfBook[8],@cSepara4) )
	EndIf	

	oReport:SetPageNumber(nPagIni) //mv_par22	-	Pagina Inicial
	oReport:SetCustomText( {|| 	CTBRCABEC(dDataFim ,STR0024,,oReport) } )   //"Conta de Capital de Aportacion (CUCA)"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Arquivo Temporario para Impressao   					 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
					CTBGerCuc(oMeter,oText,oDlg,lEnd,@cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
					 cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
					  aSetOfBook,lNoMov,cSaldo,.T.,"1",.T.,,,cFiltro,lSldAnt)},;
					   STR0025,;		 //"Criando Arquivo Tempor rio..."
						STR0026)	 //"Emissao do CUCA"
		dbSelectArea("cArqTmp")
		dbGoTop()
		oReport:SetMeter( RecCount() )
		oReport:NoUserFilter()

		//Se tiver parametrizado com Plano Gerencial, exibe a mensagem que o Plano Gerencial 
		//nao esta disponivel e sai da rotina.
		If cArqTmp->(EoF())              
			Aviso(STR0027,STR0028,{"Ok"}) //"Atencao"###"Nao existem dados para os parâmetros especificados."
			oReport:CancelPrint()
			Return
		Else
			While cArqTmp->(!Eof()) .And. !oReport:Cancel()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³INICIO DA 1a SECAO             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    If oReport:Cancel()
			    	Exit
			    EndIf        
				
				aSaldo 		:= SaldoCT7(cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo)	
				aSaldoAnt	:= SaldoCT7(cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,"CTBR400")
				
				If f180Fil(lNoMov,aSaldo,dDataIni,dDataFim)
					dbSkip()
					Loop
				EndIf

				nSaldoAtu:= 0
				nTotDeb	:= 0
				nTotCrd	:= 0                              

				// Conta Sintetica	
				CT1->(DBSETORDER(1))
				CT1->(dBSEEK(xFilial("CT1")+cArqTmp->CONTA))
				 
				If mv_par07 == 1
					oSection1:Cell("CONTA" ):SetBlock( { || EntidadeCTB(CT1->CT1_CONTA,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.) } )
					oSection1:Cell("DESCCC"):SetBlock( { || " - " + CT1->CT1_DESC01 } )
				Else
					oSection1:Cell("CONTA" ):SetBlock( { || CT1->CT1_RES } )
					oSection1:Cell("DESCCC"):SetBlock( { || " - " + CT1->CT1_DESC01 } )
				Endif
				
				// A TRANSPORTAR :  	
				oReport:SetPageFooter( 5 , {|| IIF(oSection2:Printing() .Or. oSection3:Printing() ,oReport:PrintText(STR0029 + ValorCTB(nSldATransp,,,TAM_VALOR,nDecimais,.T.,cPicture,,,,,,,.T.,.F.) ),nil) } ) //"A TRANSPORTAR"

				//"DE TRANSPORTE : "
				oReport:OnPageBreak( {|| IIF(oSection2:Printing() .Or. oSection3:Printing() , (oReport:PrintText(xConta +STR0030 + ValorCTB(nSldDTransp,,,TAM_VALOR,nDecimais,.T.,cPicture,,,,,,,.T.,.F.),oReport:Row(),10),oReport:Skipline()),nil) } ) //"DE TRANSPORTE : "
				 
				nSaldoAtu := aSaldoAnt[6]                                           
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³INICIO DA 2a SECAO³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("cArqTmp")
				cContaAnt:= cArqTmp->CONTA
				dDataAnt	:= CTOD("  /  /  ")

				oSection1:Init()
				oSection1:PrintLine()         
                oSection1:Finish()        
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Impressao do Saldo Anterior do Centro de Custo³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oReport:PrintText( STR0031 + ValorCTB(aSaldoAnt[6],,,TAM_VALOR,nDecimais,.T.,cPicture,,,,,,,.T.,.F.) ) //"SALDO ANTERIOR: "
	   			
	   			oSection3:Init() // oSection3 - Totalizadora
				oSection2:Init()
				
				Do While cArqTmp->(!Eof() .And. CONTA == cContaAnt ) .And. !oReport:Cancel()

				    If oReport:Cancel()
				    	Exit
				    EndIf        

					If dDataAnt <> cArqTmp->DATAL 
						If (cArqTmp->LANCDEB <> 0 .Or. cArqTmp->LANCCRD <> 0)
							oSection2:Cell("DATAL"):SetBlock( { || dDataAnt } )
						Endif	
						dDataAnt := cArqTmp->DATAL    
					EndIf
   					 
					nTotDeb		+= cArqTmp->LANCDEB
					nTotCrd		+= cArqTmp->LANCCRD
					nTotGerDeb	+= cArqTmp->LANCDEB
					nTotGerCrd	+= cArqTmp->LANCCRD			
						
					DbSelectArea("SIE")
					DbSetOrder(1)
						
					cPesq1:= Str(Year(cArqTmp->DATAL),4) + Strzero(Month(cArqTmp->DATAL),2)
					
                    If lPrimVz
						If Month(cArqTmp->DATAL)==1
							cPesq:= Str(Year(cArqTmp->DATAL)-1,4) + Strzero(12,2)
						Else
							cPesq:= Str(Year(cArqTmp->DATAL),4) + Strzero(Month(cArqTmp->DATAL)-1,2)
						EndIf	
						If DbSeek( xFilial("SIE") + cPesq )
							nTaxaAnt:= SIE->IE_INDICE
						EndIf
	       			    	lPrimVz:=.F.
			        Else
				       	nTaxaAnt:= nTaxaAtu
					EndIf
						
					If DbSeek( xFilial("SIE") + cPesq1 )
						nTaxaAtu:= SIE->IE_INDICE
					EndIf						
						
					nFator:= NoRound(nTaxaAtu /nTaxaAnt,4)
					
					nSaldoAtu 	:= (nSaldoAtu * nFator) +cArqTmp->LANCDEB- cArqTmp->LANCCRD
					
					dbSelectArea("cArqTmp")

					oSection2:Cell("INPC"):SetBlock( { ||nTaxaAtu} )  
					oSection2:Cell("ULTINPC"):SetBlock( { || nTaxaAnt} ) 
					oSection2:Cell("FTATUAL"):SetBlock( { || nFator} ) 
					oSection2:Cell("TPSLDATU"):SetBlock({ || ValorCTB(nSaldoAtu,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cNormal,,,,,,.T.,.F.) } )
					nSldATransp := nSaldoAtu // Valor a Transportar - 1

				   	oSection2:PrintLine()
				    oReport:IncMeter()

					nSldDTransp := nSaldoAtu // Valor de Transporte - 2

					// Procura complemento de historico e imprime
					ImpCompl(oReport)
				        
					dbSkip()
				
				EndDo
   				oSection2:Finish()        
		
				nTaxaAnt:=nTaxaAtu
                                       
				DbSelectArea("SIE")
					DbSetOrder(1)
						cPesq:= Str(Year(dDataBase),4) + Strzero(Month(dDataBase),2)
						

						If DbSeek( xFilial("SIE") + cPesq )
							nTaxaAtu:= SIE->IE_INDICE
						EndIf

				nFator:= NoRound(nTaxaAtu /nTaxaAnt,4)
				oSection3:Cell("INPC"	):SetBlock(	{ || nTaxaAtu } )
				oSection3:Cell("ULTINPC"	):SetBlock(	{ || nTaxaAnt } )
				oSection3:Cell("FTATUAL"	):SetBlock(	{ || nFator})
				oSection3:Cell("TOT_ATU"	):SetBlock(	{ || ValorCTB((nSaldoAtu * nFator),,,TAM_VALOR-2,nDecimais,.T.,cPicture,cNormal,,,,,,.T.,.F.) } )

				// Imprime totalizado
				oSection3:PrintLine()
				oSection3:Finish()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³FIM DA 3a SECAO - Totais da Conta³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			EndDo 

		EndIf
	
	dbselectArea("CT2")
	If !Empty(dbFilter())
		dbClearFilter()
	Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpCompl  ºAutor  ³Paulo Augusto       ³ Data ³ 20.12.06    ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a descricao, da conta contabil, item, centro de     º±±
±±º          ³custo ou classe valor                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBR390                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ImpCompl(oReport)
	
	Local oSection4 := oReport:Section(4)

	oSection4:Cell("COMP"):SetBlock({|| Space(15)+CT2->CT2_LINHA,Subs(CT2->CT2_HIST,1,40) } )
	
	// Procura pelo complemento de historico
	dbSelectArea("CT2")
	dbSetOrder(10)
	If MsSeek(xFilial("CT2")+cArqTMP->(DTOS(DATAL)+LOTE+SUBLOTE+DOC+SEQLAN+EMPORI+FILORI),.F.)
		dbSkip()
		If CT2->CT2_DC == "4"			//// TRATAMENTO PARA IMPRESSAO DAS CONTINUACOES DE HISTORICO
			oSection4:Init()
			While !CT2->(Eof()) .And.;
					CT2->CT2_FILIAL == xFilial("CT2") .And.;
					 CT2->CT2_LOTE == cArqTMP->LOTE .And.;
					  CT2->CT2_SBLOTE == cArqTMP->SUBLOTE .And.;
					   CT2->CT2_DOC == cArqTmp->DOC .And.;
						CT2->CT2_SEQLAN == cArqTmp->SEQLAN .And.;
						 CT2->CT2_EMPORI == cArqTmp->EMPORI .And.;
						  CT2->CT2_FILORI == cArqTmp->FILORI .And.;
						   CT2->CT2_DC == "4" .And.;
				    	    DTOS(CT2->CT2_DATA) == DTOS(cArqTmp->DATAL)
				oSection4:Printline()
				CT2->(dbSkip())			
			EndDo	
			oSection4:Finish()
		EndIf
	EndIf                  

	dbSelectArea("cArqTmp")

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³f180Fil   ºAutor  ³Paulo Augusto       º Data ³  20/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBR401                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function f180Fil(lNoMov,aSaldo,dDataIni,dDataFim)

Local lDeixa	:= .F.

	If !lNoMov //Se imprime conta sem movimento
		If aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0 
			lDeixa	:= .T.
		Endif	
	Endif             
	
	If lNoMov .And. aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0 
		If CtbExDtFim("CT1") 			
			dbSelectArea("CT1") 
			dbSetOrder(1) 
			If MsSeek(xFilial()+cArqTmp->CONTA)
				If !CtbVlDtFim("CT1",dDataIni) 		
					lDeixa	:= .T.
	            EndIf                                   
	            
	            If !CtbVlDtIni("CT1",dDataFim)
					lDeixa	:= .T.
	            EndIf                                   

		    EndIf
		EndIf
	EndIf

	dbSelectArea("cArqTmp")

Return (lDeixa)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CtbGerCuc ³ Autor ³ Paulo Augusto       	 ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Cria Arquivo Temporario para imprimir o CUCA                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³CtbGerCuc(oMeter,oText,oDlg,lEnd,cArqTmp,cContaIni,cContaFim³±±
±±³			  ³cCustoIni,cCustoFim,cItemIni,cItemFim,cCLVLIni,cCLVLFim,    ³±±
±±³			  ³cMoeda,dDataIni,dDataFim,aSetOfBook,lNoMov,cSaldo,lJunta,   ³±±
±±³			  ³cTipo,lAnalit)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³Nome do arquivo temporario                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpO1 = Objeto oMeter                                      ³±±
±±³           ³ ExpO2 = Objeto oText                                       ³±±
±±³           ³ ExpO3 = Objeto oDlg                                        ³±±
±±³           ³ ExpL1 = Acao do Codeblock                                  ³±±
±±³           ³ ExpC1 = Arquivo temporario                                 ³±±
±±³           ³ ExpC2 = Conta Inicial                                      ³±±
±±³           ³ ExpC3 = Conta Final                                        ³±±
±±³           ³ ExpC4 = C.Custo Inicial                                    ³±±
±±³           ³ ExpC5 = C.Custo Final                                      ³±±
±±³           ³ ExpC6 = Item Inicial                                       ³±±
±±³           ³ ExpC7 = Cl.Valor Inicial                                   ³±±
±±³           ³ ExpC8 = Cl.Valor Final                                     ³±±
±±³           ³ ExpC9 = Moeda                                              ³±±
±±³           ³ ExpD1 = Data Inicial                                       ³±±
±±³           ³ ExpD2 = Data Final                                         ³±±
±±³           ³ ExpA1 = Matriz aSetOfBook                                  ³±±
±±³           ³ ExpL2 = Indica se imprime movimento zerado ou nao.         ³±±
±±³           ³ ExpC10= Tipo de Saldo                                      ³±±
±±³           ³ ExpL3 = Indica se junta CC ou nao.                         ³±±
±±³           ³ ExpC11= Tipo do lancamento                                 ³±±
±±³           ³ ExpL4 = Indica se imprime analitico ou sintetico           ³±±
±±³           ³ c2Moeda = Indica moeda 2 a ser incluida no relatorio       ³±±
±±³           ³ cUFilter= Conteudo Txt com o Filtro de Usuario (CT2)       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbGerCuc(oMeter,oText,oDlg,lEnd,cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
						cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
						aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,lAnalit,c2Moeda,;
						nTipo,cUFilter,lSldAnt)

Local aTamConta	:= TAMSX3("CT1_CONTA")
Local aTamCusto	:= TAMSX3("CT3_CUSTO") 
Local aTamVal	:= TAMSX3("CT2_VALOR")
Local aCtbMoeda	:= {}
Local aSaveArea	:= GetArea()                       
Local aCampos	:= {}

Local cChave

Local nTamHist	:= Len(CriaVar("CT2_HIST"))
Local nTamItem	:= Len(CriaVar("CTD_ITEM"))
Local nTamCLVL	:= Len(CriaVar("CTH_CLVL"))
Local nDecimais	:= 0    
Local cMensagem	:= STR0032 //" O plano gerencial nao esta disponivel nesse relatorio. "

DEFAULT c2Moeda := ""
DEFAULT nTipo	:= 1
DEFAULT cUFilter:= ""
DEFAULT lSldAnt		:= .F.
#IFDEF TOP
	If TcSrvType() != "AS/400" .And. cTipo == "1" .And. FunName() == 'CTBR401' .And. TCGetDb() $ "MSSQL7/MSSQL"		
		DEFAULT cUFilter	:= ".T."		
    Else
#ENDIF
	DEFAULT cUFilter	:= ""			    	
#IFDEF TOP
	Endif
#ENDIF
// Retorna Decimais
aCtbMoeda := CTbMoeda(cMoeda)
nDecimais := aCtbMoeda[5]
                
aCampos :={	{ "CONTA"		, "C", aTamConta[1], 0 },;  		// Codigo da Conta
			{ "XPARTIDA"   	, "C", aTamConta[1] , 0 },;		// Contra Partida
			{ "TIPO"       	, "C", 01			, 0 },;			// Tipo do Registro (Debito/Credito/Continuacao)
			{ "LANCDEB"		, "N", aTamVal[1]+2, nDecimais },; // Debito
			{ "LANCCRD"		, "N", aTamVal[1]+2	, nDecimais },; // Credito
			{ "SALDOSCR"	, "N", aTamVal[1]+2, nDecimais },; 			// Saldo
			{ "TPSLDANT"	, "C", 01, 0 },; 					// Sinal do Saldo Anterior => Consulta Cuca
			{ "TPSLDATU"	, "C", 01, 0 },; 					// Sinal do Saldo Atual => Consulta Cuca			
			{ "HISTORICO"	, "C", nTamHist   	, 0 },;			// Historico
			{ "CCUSTO"		, "C", aTamCusto[1], 0 },;			// Centro de Custo
			{ "ITEM"		, "C", nTamItem		, 0 },;			// Item Contabil
			{ "CLVL"		, "C", nTamCLVL		, 0 },;			// Classe de Valor
			{ "DATAL"		, "D", 10			, 0 },;			// Data do Lancamento
			{ "LOTE" 		, "C", 06			, 0 },;			// Lote
			{ "SUBLOTE" 	, "C", 03			, 0 },;			// Sub-Lote
			{ "DOC" 		, "C", 06			, 0 },;			// Documento
			{ "LINHA"		, "C", 03			, 0 },;			// Linha
			{ "SEQLAN"		, "C", 03			, 0 },;			// Sequencia do Lancamento
			{ "SEQHIST"		, "C", 03			, 0 },;			// Seq do Historico
			{ "EMPORI"		, "C", 02			, 0 },;			// Empresa Original
			{ "FILORI"		, "C", 02			, 0 },;			// Filial Original
			{ "NOMOV"		, "L", 01			, 0 }}			// Conta Sem Movimento

If cPaisLoc $ "CHI|ARG"
	Aadd(aCampos,{"SEGOFI","C",TamSx3("CT2_SEGOFI")[1],0})
EndIf
If ! Empty(c2Moeda)
	Aadd(aCampos, { "LANCDEB_1"	, "N", aTamVal[1]+2, nDecimais }) // Debito
	Aadd(aCampos, { "LANCCRD_1"	, "N", aTamVal[1]+2, nDecimais }) // Credito
	Aadd(aCampos, { "TXDEBITO"	, "N", aTamVal[1]+2, 6 }) // Taxa Debito
	Aadd(aCampos, { "TXCREDITO"	, "N", aTamVal[1]+2, 6 }) // Taxa Credito
Endif

If cTipo == "1" // Cuca por Conta
	aOrdem   := {"CONTA", "DATAL", "LOTE", "SUBLOTE", "DOC", "LINHA", "EMPORI", "FILORI"}
ElseIf cTipo == "2"	 // Cuca por Centro de Custo                   
	If lAnalit // Se o relatorio for analitico
		aOrdem 	:= {"CCUSTO", "CONTA", "DATAL", "LOTE", "SUBLOTE", "DOC", "LINHA", "EMPORI", "FILORI"}
	Else                                                                  
		aOrdem 	:= {"CCUSTO", "DATAL", "LOTE", "SUBLOTE", "DOC", "LINHA", "EMPORI", "FILORI"}
	Endif
ElseIf cTipo == "3" //Cuca por Item Contabil      
	If lAnalit // Se o relatorio for analitico               
		If FunName() <> "CTBC480"
			aOrdem 	:= {"ITEM", "CONTA", "DATAL", "LOTE", "SUBLOTE", "DOC", "LINHA", "EMPORI", "FILORI"}
		Else
			aOrdem 	:= {"ITEM", "CONTA", "DATAL", "LOTE", "SUBLOTE", "DOC", "EMPORI", "FILORI", "LINHA"}		
		Endif
	Else                                                                  
		aOrdem 	:= {"ITEM", "DATAL", "LOTE", "SUBLOTE", "DOC", "LINHA", "EMPORI", "FILORI"}
	Endif
ElseIf cTipo == "4" //Cuca por Classe de Valor	
	If lAnalit // Se o relatorio for analitico
		aOrdem 	:= {"CLVL", "CONTA", "DATAL", "LOTE", "SUBLOTE", "DOC", "LINHA", "EMPORI", "FILORI"}
	Else                                                                  
		aOrdem 	:= {"CLVL", "DATAL", "LOTE", "SUBLOTE", "DOC", "LINHA", "EMPORI", "FILORI"}
	Endif	
EndIf

oTmpTable := FWTemporaryTable():New("cArqTmp")
oTmpTable:SetFields( aCampos )
oTmpTable:AddIndex("I1", aOrdem)
oTmpTable:Create()

If !Empty(aSetOfBook[5])
	MsgAlert(cMensagem)
	Return
EndIf                   

//CT2->(dbGotop())
#IFDEF TOP
	If TcSrvType() != "AS/400" .And. cTipo == "1" .And. FunName() == 'CTBR401' .And. TCGetDb() $ "MSSQL7/MSSQL"		
		CtbQryCuc(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,cCustoIni,cCustoFim,;
				cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
				aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,c2Moeda,cUFilter,lSldAnt)	
	Else
#ENDIF
	// Monta Arquivo para gerar o Cuca
	CtbCuc(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,cCustoIni,cCustoFim,;
			cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
			aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,c2Moeda,nTipo,cUFilter,lSldAnt)
#IFDEF TOP
	EndIf
#ENDIF	

RestArea(aSaveArea)

Return cArqTmp

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CtbCuc    ³ Autor ³ Paulo Augusto       	 ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Realiza a "filtragem" dos registros do Cuca                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³CtbCuc(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,		   ³±±
±±³			  ³cCustoIni,cCustoFim, cItemIni,cItemFim,cCLVLIni,cCLVLFim,   ³±±
±±³			  ³cMoeda,dDataIni,dDataFim,aSetOfBook,lNoMov,cSaldo,lJunta,   ³±±
±±³			  ³cTipo)                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpO1 = Objeto oMeter                                      ³±±
±±³           ³ ExpO2 = Objeto oText                                       ³±±
±±³           ³ ExpO3 = Objeto oDlg                                        ³±±
±±³           ³ ExpL1 = Acao do Codeblock                                  ³±±
±±³           ³ ExpC2 = Conta Inicial                                      ³±±
±±³           ³ ExpC3 = Conta Final                                        ³±±
±±³           ³ ExpC4 = C.Custo Inicial                                    ³±±
±±³           ³ ExpC5 = C.Custo Final                                      ³±±
±±³           ³ ExpC6 = Item Inicial                                       ³±±
±±³           ³ ExpC7 = Cl.Valor Inicial                                   ³±±
±±³           ³ ExpC8 = Cl.Valor Final                                     ³±±
±±³           ³ ExpC9 = Moeda                                              ³±±
±±³           ³ ExpD1 = Data Inicial                                       ³±±
±±³           ³ ExpD2 = Data Final                                         ³±±
±±³           ³ ExpA1 = Matriz aSetOfBook                                  ³±±
±±³           ³ ExpL2 = Indica se imprime movimento zerado ou nao.         ³±±
±±³           ³ ExpC10= Tipo de Saldo                                      ³±±
±±³           ³ ExpL3 = Indica se junta CC ou nao.                         ³±±
±±³           ³ ExpC11= Tipo do lancamento                                 ³±±
±±³           ³ c2Moeda = Indica moeda 2 a ser incluida no relatorio       ³±±
±±³           ³ cUFilter= Conteudo Txt com o Filtro de Usuario (CT2)       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbCuc(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,cCustoIni,cCustoFim,;
					  	cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
					  	aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,c2Moeda,nTipo,cUFilter,lSldAnt)

Local cCpoChave	:= ""
Local cTmpChave	:= ""
Local cContaI	:= ""
Local cContaF	:= ""
Local cCustoI	:= ""
Local cCustoF	:= ""
Local cItemI	:= ""
Local cItemF	:= ""
Local cClVlI	:= ""
Local cClVlF	:= ""
Local cVldEnt	:= ""
Local cAlias	:= ""
Local lUFilter	:= !Empty(cUFilter)			//// SE O FILTRO DE USUÁRIO NÃO ESTIVER VAZIO - TEM FILTRO DE USUÁRIO
Local cFilMoeda	:= "" 							
Local cAliasCT2	:= "CT2"	
Local bCond		:= {||.T.}

#IFDEF TOP
	Local cQuery	:= ""
	Local cOrderBy	:= ""
	Local nI	:= 0
	Local aStru	:= {}
#ENDIF

DEFAULT cUFilter := ".T."
DEFAULT lSldAnt	 := .F.

cCustoI	:= CCUSTOINI
cCustoF := CCUSTOFIM
cContaI	:= CCONTAINI
cContaF := CCONTAFIM
cItemI	:= CITEMINI      
cItemF 	:= CITEMFIM
cClvlI	:= CCLVLINI
cClVlF 	:= CCLVLFIM

#IFDEF TOP
	If TcSrvType() != "AS/400"
		If !Empty(c2Moeda) 			
			cFilMoeda	:= " (CT2_MOEDLC = '" + cMoeda + "' OR "		
			cFilMoeda	+= " CT2_MOEDLC = '" + c2Moeda + "') " 			
		Else
			cFilMoeda	:= " CT2_MOEDLC = '" + cMoeda + "' "				
		EndIf
	Else
#ENDIF 
	If !Empty(c2Moeda) 			
		cFilMoeda	:= " (CT2_MOEDLC = '" + cMoeda + "' .Or. "		
		cFilMoeda	+= " CT2_MOEDLC = '" + c2Moeda + "') " 			
	Else
		cFilMoeda	:= " CT2_MOEDLC = '" + cMoeda + "' "				
	EndIf
#IFDEF TOP
	EndIf
#ENDIF 

oMeter:nTotal := CT1->(RecCount())

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Obt‚m os d‚bitos ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo <> "1"
	If cTipo = "2" .And. Empty(cCustoIni)
		CTT->(DbSeek(xFilial("CTT")))
		cCustoIni := CTT->CTT_CUSTO
	Endif
	If cTipo = "3" .And. Empty(cItemIni)
		CTD->(DbSeek(xFilial("CTD")))
		cItemIni := CTD->CTD_ITEM
	Endif
	If cTipo = "4" .And. Empty(cClVlIni)
		CTH->(DbSeek(xFilial("CTH")))
		cClVlIni := CTH->CTH_CLVL
	Endif
Endif

#IFDEF TOP
	If TcSrvType() != "AS/400"

		If cTipo == "1"
			dbSelectArea("CT2")
			dbSetOrder(2)
			cValid	:= 	"CT2_DEBITO>='" + cContaIni + "' AND " +;
						"CT2_DEBITO<='" + cContaFim + "'"
			cVldEnt := 	"CT2_CCD>='" + cCustoIni + "' AND " +;
						"CT2_CCD<='" + cCustoFim + "' AND " +;
						"CT2_ITEMD>='" + cItemIni + "' AND " +;
						"CT2_ITEMD<='" + cItemFim + "' AND " +;
						"CT2_CLVLDB>='" + cClVlIni + "' AND " +;
						"CT2_CLVLDB<='" + cClVlFim + "'"						
			cOrderBy:= " CT2_FILIAL, CT2_DEBITO, CT2_DATA "
		ElseIf cTipo == "2"
			dbSelectArea("CT2")
			dbSetOrder(4)
			cValid	:= 	"CT2_CCD >= '" + cCustoIni + "'  AND  " +;
						"CT2_CCD <= '" + cCustoFim + "'"
			cVldEnt := 	"CT2_DEBITO >= '" + cContaIni + "'  AND  " +;
						"CT2_DEBITO <= '" + cContaFim + "'  AND  " +;
						"CT2_ITEMD >= '" + cItemIni + "'  AND  " +;
						"CT2_ITEMD <= '" + cItemFim + "'  AND  " +;
						"CT2_CLVLDB >= '" + cClVlIni + "'  AND  " +;
						"CT2_CLVLDB <= '" + cClVlFim + "'" 
			cOrderBy:= " CT2_FILIAL, CT2_CCD, CT2_DATA "						
		ElseIf cTipo == "3"
			dbSelectArea("CT2")
			dbSetOrder(6)
			cValid 	:= 	"CT2_ITEMD >= '" + cItemIni + "'  AND  " +;
						"CT2_ITEMD <= '" + cItemFim + "'"
			cVldEnt	:= 	"CT2_DEBITO >= '" + cContaIni + "'  AND  " +;
						"CT2_DEBITO <= '" + cContaFim + "'  AND  " +;
						"CT2_CCD >= '" + cCustoIni + "'  AND  " +;
						"CT2_CCD <= '" + cCustoFim + "'  AND  " +;
						"CT2_CLVLDB >= '" + cClVlIni + "'  AND  " +;
						"CT2_CLVLDB <= '" + cClVlFim + "'"
			cOrderBy:= " CT2_FILIAL, CT2_ITEMD, CT2_DATA "												
		ElseIf cTipo == "4"
			dbSelectArea("CT2")
			dbSetOrder(8)
			cValid 	:= 	"CT2_CLVLDB >= '" + cClVlIni + "'  AND  " +;
						"CT2_CLVLDB <= '" + cClVlFim + "'"
			cVldEnt	:= 	"CT2_DEBITO >= '" + cContaIni + "'  AND  " +;
						"CT2_DEBITO <= '" + cContaFim + "'  AND  " +;
						"CT2_CCD >= '" + cCustoIni + "'  AND  " +;
						"CT2_CCD <= '" + cCustoFim + "'  AND  " +;
						"CT2_ITEMD >= '" + cItemIni + "'  AND  " +;
						"CT2_ITEMD <= '" + cItemFim + "'"
			cOrderBy:= " CT2_FILIAL, CT2_CLVLDB, CT2_DATA "												
		EndIf                                           

		cAliasCT2	:= "cAliasCT2"
		
		cQuery	:= " SELECT * "
		cQuery	+= " FROM " + RetSqlName("CT2")  
		cQuery	+= " WHERE CT2_FILIAL = '"+ xFilial("CT2") + "' AND "
		cQuery	+= cValid + " AND "
		cQuery	+= " CT2_DATA >= '" + DTOS(dDataIni) + "' AND "
		cQuery	+= " CT2_DATA <= '" + DTOS(dDataFim) + "' AND "
		cQuery	+= cVldEnt+ " AND " 
		cQuery	+= cFilMoeda + " AND " 
		cQuery	+= " CT2_TPSALD = '"+ cSaldo + "'"
		cQuery	+= " AND (CT2_DC = '1' OR CT2_DC = '3')"
		cQuery   += " AND CT2_VALOR <> 0 "
		cQuery	+= " AND D_E_L_E_T_ = ' ' " 
		cQuery	+= " ORDER BY "+ cOrderBy
		cQuery := ChangeQuery(cQuery)

		If ( Select ( "cAliasCT2" ) <> 0 )
			dbSelectArea ( "cAliasCT2" )
			dbCloseArea ()
		Endif
			
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCT2,.T.,.F.)
		aStru := CT2->(dbStruct())
		
		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField(cAliasCT2, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			Endif
		Next ni		

		If lUFilter					//// ADICIONA O FILTRO DEFINIDO PELO USUÁRIO SE NÃO ESTIVER EM BRANCO
			If !Empty(cVldEnt)
				cVldEnt  += " AND "			/// SE JÁ TIVER CONTEUDO, ADICIONA "AND"				
				cVldEnt  += cUFilter				/// ADICIONA O FILTRO DE USUÁRIO		
			EndIf		
		EndIf	
		                                     
		If (!lUFilter) .or. Empty(cUFilter)
			cUFilter := ".T."
		EndIf			
		
		dbSelectArea(cAliasCT2)				
		While !Eof()
			If &cUFilter
				CtbGrvCuc(lJunta,cMoeda,cSaldo,"1",c2Moeda,cAliasCT2,nTipo)
				dbSelectArea(cAliasCT2)
			EndIf
			dbSkip()
		EndDo			
		
    Else    
#ENDIF    
	If cTipo == "1"
		dbSelectArea("CT2")                              
		dbSetOrder(2)
		cValid	:= 	"CT2_DEBITO>='" + cContaIni + "' .And. " +;
					"CT2_DEBITO<='" + cContaFim + "'"
		cVldEnt := 	"CT2_CCD>='" + cCustoIni + "' .And. " +;
					"CT2_CCD<='" + cCustoFim + "' .And. " +;
					"CT2_ITEMD>='" + cItemIni + "' .And. " +;
					"CT2_ITEMD<='" + cItemFim + "' .And. " +;
					"CT2_CLVLDB>='" + cClVlIni + "' .And. " +;
					"CT2_CLVLDB<='" + cClVlFim + "'"
		bCond 	:= { ||CT2->CT2_DEBITO >= cContaIni .And. CT2->CT2_DEBITO <= cContaFim}
	ElseIf cTipo == "2"
		dbSelectArea("CT2")
		dbSetOrder(4)
		cValid	:= 	"CT2_CCD >= '" + cCustoIni + "'  .And.  " +;
					"CT2_CCD <= '" + cCustoFim + "'"
		cVldEnt := 	"CT2_DEBITO >= '" + cContaIni + "'  .And.  " +;
					"CT2_DEBITO <= '" + cContaFim + "'  .And.  " +;
					"CT2_ITEMD >= '" + cItemIni + "'  .And.  " +;
					"CT2_ITEMD <= '" + cItemFim + "'  .And.  " +;
					"CT2_CLVLDB >= '" + cClVlIni + "'  .And.  " +;
					"CT2_CLVLDB <= '" + cClVlFim + "'"
	ElseIf cTipo == "3"
		dbSelectArea("CT2")
		dbSetOrder(6)
		cValid 	:= 	"CT2_ITEMD >= '" + cItemIni + "'  .And.  " +;
					"CT2_ITEMD <= '" + cItemFim + "'"
		cVldEnt	:= 	"CT2_DEBITO >= '" + cContaIni + "'  .And.  " +;
					"CT2_DEBITO <= '" + cContaFim + "'  .And.  " +;
					"CT2_CCD >= '" + cCustoIni + "'  .And.  " +;
					"CT2_CCD <= '" + cCustoFim + "'  .And.  " +;
					"CT2_CLVLDB >= '" + cClVlIni + "'  .And.  " +;
					"CT2_CLVLDB <= '" + cClVlFim + "'"
	ElseIf cTipo == "4"
		dbSelectArea("CT2")
		dbSetOrder(8)
		cValid 	:= 	"CT2_CLVLDB >= '" + cClVlIni + "'  .And.  " +;
					"CT2_CLVLDB <= '" + cClVlFim + "'"
		cVldEnt	:= 	"CT2_DEBITO >= '" + cContaIni + "'  .And.  " +;
					"CT2_DEBITO <= '" + cContaFim + "'  .And.  " +;
					"CT2_CCD >= '" + cCustoIni + "'  .And.  " +;
					"CT2_CCD <= '" + cCustoFim + "'  .And.  " +;
					"CT2_ITEMD >= '" + cItemIni + "'  .And.  " +;
					"CT2_ITEMD <= '" + cItemFim + "'"
	EndIf
		
	If lUFilter					//// ADICIONA O FILTRO DEFINIDO PELO USUÁRIO SE NÃO ESTIVER EM BRANCO
		If !Empty(cVldEnt)
			cVldEnt  += " .and. "			/// SE JÁ TIVER CONTEUDO, ADICIONA ".AND."		
		EndIf
	Endif
	
	cVldEnt  += cUFilter				/// ADICIONA O FILTRO DE USUÁRIO		
		
	If cTipo == "1"						/// TRATAMENTO CONTAS A CREDITO

		dbSelectArea("CT2")
		dbSetOrder(2)
		
		dbSelectArea("CT1")
		dbSetOrder(3)
		cFilCT1 := xFilial("CT1")
		cFilCT2	:= xFilial("CT2")
		cContaIni := If(Empty(cContaIni),"",cContaIni)		/// Se tiver espacos em branco usa "" p/ seek
		dbSeek(cFilCT1+"2"+cContaIni,.T.)					/// Procura inicial analitica
		
		While CT1->(!Eof()) .and. CT1->CT1_FILIAL == cFilCT1 .And. CT1->CT1_CONTA <= cContaFim
			dbSelectArea("CT2")
			MsSeek(cFilCT2+CT1->CT1_CONTA+DTOS(dDataIni),.T.)
			While !Eof() .And. CT2->CT2_FILIAL == cFilCT2 .And. CT2->CT2_DEBITO == CT1->CT1_CONTA .and. CT2->CT2_DATA <= dDataFim
		        
				If CT2->CT2_VALOR = 0
					dbSkip()
					Loop				
				EndIf
		
				If Empty(c2Moeda)			
					If CT2->CT2_MOEDLC <> cMoeda
						dbSkip()
						Loop
					EndIF
				Else
					If !(&(cFilMoeda))
						dbSkip()
						Loop
					EndIf			
				EndIf
				
				If (CT2->CT2_DC == "1" .Or. CT2->CT2_DC == "3") .And. &(cValid) .And. &(cVldEnt) .And. CT2->CT2_TPSALD == cSaldo
					CT2->(CtbGrvCuc(lJunta,cMoeda,cSaldo,"1",c2Moeda,cAliasCT2,nTipo))
				Endif
				dbSelectArea("CT2")
				dbSkip()
			EndDo
			CT1->(dbSkip())
		EndDo
	Else
		dbSelectArea("CT2")

		cTabCad := "CTT"
		cEntIni	:= cCustoIni
		bCond 	:= { || CT2->CT2_CCD == CTT->CTT_CUSTO}
		bCondCad:= { || .T.}
		dbSetOrder(4)

		If cTipo == "3"
			cTabCad := "CTD"
			cEntIni := cItemIni
			bCond 	:= { || CT2->CT2_ITEMD == CTD->CTD_ITEM}			
			dbSetOrder(6)
		ElseIf cTipo == "4"
			cTabCad := "CTH"
			cEntIni := cCLVLIni
			bCond 	:= { || CT2->CT2_CLVLDB == CTH->CTH_CLVL}					
			dbSetOrder(8)
		EndIf
		
		dbSelectArea(cTabCad)
		dbSetOrder(2)
		cFilEnt := xFilial(cTabCad)
		cFilCT2	:= xFilial("CT2")
		cEntIni := If(Empty(cEntIni),"",cEntIni)		/// Se tiver espacos em branco usa "" p/ seek
		dbSeek(cFilEnt+"2"+cEntIni,.T.)					/// Procura inicial analitica
		
		If cTipo == "2"
			bCondCad := {|| CTT->CTT_FILIAL == cFilEnt .and. CTT->CTT_CUSTO <= cCustoFim }
		ElseIf cTipo == "3"
   			bCondCad := {|| CTD->CTD_FILIAL == cFilEnt .and. CTD->CTD_ITEM <= cItemFim }
  		ElseIf cTipo == "4"
			bCondCad := {|| CTH->CTH_FILIAL == cFilEnt .and. CTH->CTH_CLVL <= cCLVLFim }  		
  		EndIf
		
		While (cTabCad)->(!Eof()) .and. Eval(bCondCad)			/// WHILE DO CADASTRO DE ENTIDADES
	
			dbSelectArea("CT2")    			
			If cTipo == "2"
				MsSeek(cFilCT2+CTT->CTT_CUSTO+DTOS(dDataIni),.T.)
			ElseIf cTipo == "3"
				MsSeek(cFilCT2+CTD->CTD_ITEM+DTOS(dDataIni),.T.)			
			Else
				MsSeek(cFilCT2+CTH->CTH_CLVL+DTOS(dDataIni),.T.)						
			EndIf

			dbSelectArea("CT2")									/// WHILE CT2 - DEBITOS
			While CT2->(!Eof()) .And. CT2->CT2_FILIAL == cFilCT2 .and. Eval(bCond) .and. CT2->CT2_DATA <= dDataFim
		
				If CT2->CT2_VALOR = 0
					dbSkip()
					Loop				
				EndIf

				If Empty(c2Moeda)			
					If CT2->CT2_MOEDLC <> cMoeda
						dbSkip()
						Loop
					EndIF
				Else
					If !(&(cFilMoeda))
						dbSkip()
						Loop
					EndIf			
				EndIf
				
				If (CT2->CT2_DC == "1" .Or. CT2->CT2_DC == "3") .And. &(cVldEnt) .And. CT2->CT2_TPSALD == cSaldo
					CT2->(CtbGrvCuc(lJunta,cMoeda,cSaldo,"1",c2Moeda,cAliasCT2,nTipo))
				Endif
				dbSelectArea("CT2")
				dbSkip()
			EndDo	
			(cTabCad)->(dbSkip())
		EndDo
	Endif
		
#IFDEF TOP
	EndIf
#ENDIF

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Obt‚m os creditos³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == "1"
	dbSelectArea("CT2")
	dbSetOrder(3)
ElseIf cTipo == "2"
	dbSelectArea("CT2")
	dbSetOrder(5)
ElseIf cTipo == "3"
	dbSelectArea("CT2")
	dbSetOrder(7)
ElseIf cTipo == "4"		
	dbSelectArea("CT2")
	dbSetOrder(9)
EndIf

#IFDEF TOP
	If TcSrvType() != "AS/400"                          
		If cTipo == "1"
			cValid	:= 	"CT2_CREDIT>='" + cContaIni + "' AND " +;
						"CT2_CREDIT<='" + cContaFim + "'"
			cVldEnt :=	"CT2_CCC>='" + cCustoIni + "' AND " +;
						"CT2_CCC<='" + cCustoFim + "' AND " +;
						"CT2_ITEMC>='" + cItemIni + "' AND " +;
						"CT2_ITEMC<='" + cItemFim + "' AND " +;
						"CT2_CLVLCR>='" + cClVlIni + "' AND " +;
						"CT2_CLVLCR<='" + cClVlFim + "'"
			cOrderBy:= " CT2_FILIAL, CT2_CREDIT, CT2_DATA "																	
		ElseIf cTipo == "2"
			cValid 	:= 	"CT2_CCC >= '" + cCustoIni + "'  AND  " +;
						"CT2_CCC <= '" + cCustoFim + "'"
			cVldEnt	:= 	"CT2_CREDIT >= '" + cContaIni + "'  AND  " +;
						"CT2_CREDIT <= '" + cContaFim + "'  AND  " +;
						"CT2_ITEMC >= '" + cItemIni + "'  AND  " +;
						"CT2_ITEMC <= '" + cItemFim + "'  AND  " +;
						"CT2_CLVLCR >= '" + cClVlIni + "'  AND  " +;
						"CT2_CLVLCR <= '" + cClVlFim + "'"
			cOrderBy:= " CT2_FILIAL, CT2_CCC, CT2_DATA "																	
		ElseIf cTipo == "3"
			cValid 	:= 	"CT2_ITEMC >= '" + cItemIni + "'  AND  " +;
						"CT2_ITEMC <= '" + cItemFim + "'"
			cVldEnt := 	"CT2_CREDIT >= '" + cContaIni + "'  AND  " +;
						"CT2_CREDIT <= '" + cContaFim + "'  AND  " +;
						"CT2_CCC >= '" + cCustoIni + "'  AND  " +;
						"CT2_CCC <= '" + cCustoFim + "'  AND  " +;
						"CT2_CLVLCR >= '" + cClVlIni + "'  AND  " +;
						"CT2_CLVLCR <= '" + cClVlFim + "'"
			cOrderBy:= " CT2_FILIAL, CT2_ITEMC, CT2_DATA "																	
		ElseIf cTipo == "4"		
			cValid 	:= 	"CT2_CLVLCR >= '" + cClVlIni + "'  AND  " +;
						"CT2_CLVLCR <= '" + cClVlFim + "'"
			cVldEnt := 	"CT2_CREDIT >= '" + cContaIni + "'  AND  " +;
						"CT2_CREDIT <= '" + cContaFim + "'  AND  " +;
						"CT2_CCC >= '" + cCustoIni + "'  AND  " +;
						"CT2_CCC <= '" + cCustoFim + "'  AND  " +;
						"CT2_ITEMC >= '" + cItemIni + "'  AND  " +;
						"CT2_ITEMC <= '" + cItemFim + "'"
			cOrderBy:= " CT2_FILIAL, CT2_CLVLCR, CT2_DATA "																						
		EndIf	                    
		
		cAliasCT2	:= "cAliasCT2"		
		
		cQuery	:= " SELECT * "
		cQuery	+= " FROM " + RetSqlName("CT2")  
		cQuery	+= " WHERE CT2_FILIAL = '"+ xFilial("CT2") + "' AND "
		cQuery	+= cValid + " AND "
		cQuery	+= " CT2_DATA >= '" + DTOS(dDataIni) + "' AND "
		cQuery	+= " CT2_DATA <= '" + DTOS(dDataFim) + "' AND "
		cQuery	+= cVldEnt+ " AND " 
		cQuery	+= cFilMoeda + " AND " 
		cQuery	+= " CT2_TPSALD = '"+ cSaldo + "' AND "  
		cQuery	+= " (CT2_DC = '2' OR CT2_DC = '3') AND "
		cQuery	+= " CT2_VALOR <> 0 AND "
		cQuery	+= " D_E_L_E_T_ = ' ' " 
		cQuery	+= " ORDER BY "+ cOrderBy
		cQuery := ChangeQuery(cQuery)

		If ( Select ( "cAliasCT2" ) <> 0 )
			dbSelectArea ( "cAliasCT2" )
			dbCloseArea ()
		Endif
			
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCT2,.T.,.F.)
		
		aStru := CT2->(dbStruct())
		
		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField(cAliasCT2, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			Endif
		Next ni		
		

		If lUFilter					//// ADICIONA O FILTRO DEFINIDO PELO USUÁRIO SE NÃO ESTIVER EM BRANCO
			If !Empty(cVldEnt)
				cVldEnt  += " AND "			/// SE JÁ TIVER CONTEUDO, ADICIONA "AND"				
				cVldEnt  += cUFilter				/// ADICIONA O FILTRO DE USUÁRIO		
			EndIf		
		EndIf	
		
		If (!lUFilter) .or. Empty(cUFilter)
			cUFilter := ".T."
		EndIf			
		
		dbSelectArea(cAliasCT2)				
		While !Eof()
			If &cUFilter
				CtbGrvCuc(lJunta,cMoeda,cSaldo,"2",c2Moeda,cAliasCT2,nTipo)
				dbSelectArea(cAliasCT2)
		    EndIf
			dbSkip()
		EndDo			
		
	Else
#ENDIF
	bCond	:= {||.T.}

	If cTipo == "1"
		cValid	:= 	"CT2_CREDIT>='" + cContaIni + "'.And." +;
					"CT2_CREDIT<='" + cContaFim + "'"
		cVldEnt :=	"CT2_CCC>='" + cCustoIni + "'.And." +;
					"CT2_CCC<='" + cCustoFim + "'.And." +;
					"CT2_ITEMC>='" + cItemIni + "'.And." +;
					"CT2_ITEMC<='" + cItemFim + "'.And." +;
					"CT2_CLVLCR>='" + cClVlIni + "'.And." +;
					"CT2_CLVLCR<='" + cClVlFim + "'"
		bCond 	:= { ||CT2->CT2_CREDIT >= cContaIni .And. CT2->CT2_CREDIT <= cContaFim}
	ElseIf cTipo == "2"
		cValid 	:= 	"CT2_CCC >= '" + cCustoIni + "' .And. " +;
					"CT2_CCC <= '" + cCustoFim + "'"
		cVldEnt	:= 	"CT2_CREDIT >= '" + cContaIni + "' .And. " +;
					"CT2_CREDIT <= '" + cContaFim + "' .And. " +;
					"CT2_ITEMC >= '" + cItemIni + "' .And. " +;
					"CT2_ITEMC <= '" + cItemFim + "' .And. " +;
					"CT2_CLVLCR >= '" + cClVlIni + "' .And. " +;
					"CT2_CLVLCR <= '" + cClVlFim + "'"
	ElseIf cTipo == "3"
		cValid 	:= 	"CT2_ITEMC >= '" + cItemIni + "' .And. " +;
					"CT2_ITEMC <= '" + cItemFim + "'"
		cVldEnt := 	"CT2_CREDIT >= '" + cContaIni + "' .And. " +;
					"CT2_CREDIT <= '" + cContaFim + "' .And. " +;
					"CT2_CCC >= '" + cCustoIni + "' .And. " +;
					"CT2_CCC <= '" + cCustoFim + "' .And. " +;
					"CT2_CLVLCR >= '" + cClVlIni + "' .And. " +;
					"CT2_CLVLCR <= '" + cClVlFim + "'"
	ElseIf cTipo == "4"		
		cValid 	:= 	"CT2_CLVLCR >= '" + cClVlIni + "' .And. " +;
					"CT2_CLVLCR <= '" + cClVlFim + "'"
		cVldEnt := 	"CT2_CREDIT >= '" + cContaIni + "' .And. " +;
					"CT2_CREDIT <= '" + cContaFim + "' .And. " +;
					"CT2_CCC >= '" + cCustoIni + "' .And. " +;
					"CT2_CCC <= '" + cCustoFim + "' .And. " +;
					"CT2_ITEMC >= '" + cItemIni + "' .And. " +;
					"CT2_ITEMC <= '" + cItemFim + "'"
	EndIf	
	
	If lUFilter					//// ADICIONA O FILTRO DEFINIDO PELO USUÁRIO SE NÃO ESTIVER EM BRANCO
		If !Empty(cVldEnt)
			cVldEnt  += " .and. "			/// SE JÁ TIVER CONTEUDO, ADICIONA ".AND."		
		EndIf
	Endif
	
	cVldEnt  += cUFilter				/// ADICIONA O FILTRO DE USUÁRIO		
	
	If cTipo == "1"						/// TRATAMENTO CONTAS A CREDITO
		dbSelectArea("CT2")
		dbSetOrder(3)
		
		dbSelectArea("CT1")
		dbSetOrder(3)
		cFilCT1 := xFilial("CT1")
		cFilCT2	:= xFilial("CT2")
		cContaIni := If(Empty(cContaIni),"",cContaIni)		/// Se tiver espacos em branco usa "" p/ seek
		dbSeek(cFilCT1+"2"+cContaIni,.T.)					/// Procura inicial analitica
		
		While CT1->(!Eof()) .and. CT1->CT1_FILIAL == cFilCT1 .And. CT1->CT1_CONTA <= cContaFim
			dbSelectArea("CT2")
			MsSeek(cFilCT2+CT1->CT1_CONTA+DTOS(dDataIni),.T.)
			While !Eof() .And. CT2->CT2_FILIAL == cFilCT2 .And. CT2->CT2_CREDIT == CT1->CT1_CONTA .and. CT2->CT2_DATA <= dDataFim

				If CT2->CT2_VALOR = 0
					dbSkip()
					Loop				
				EndIf
	
				If (CT2->CT2_DC == "2" .Or. CT2->CT2_DC == "3") .And. &(cValid) .And. &(cVldEnt) .And. CT2->CT2_TPSALD == cSaldo
					If Empty(c2Moeda)			
						If CT2->CT2_MOEDLC <> cMoeda
							dbSkip()
							Loop
						EndIF
					Else
						If !(&(cFilMoeda))
							dbSkip()
							Loop
						EndIf			
					EndIf			
					CT2->(CtbGrvCuc(lJunta,cMoeda,cSaldo,"2",c2Moeda,cAliasCT2,nTipo))
				Endif
				dbSelectArea("CT2")
				dbSkip()
			EndDo			
			CT1->(dbSkip())
		EndDo
	Else
		dbSelectArea("CT2")

		cTabCad := "CTT"
		cEntIni	:= cCustoIni
		bCond 	:= { || CT2->CT2_CCC == CTT->CTT_CUSTO}
		bCondCad:= { || .T.}
		dbSetOrder(5)

		If cTipo == "3"
			cTabCad := "CTD"
			cEntIni := cItemIni
			bCond 	:= { || CT2->CT2_ITEMC == CTD->CTD_ITEM}			
			dbSetOrder(7)
		ElseIf cTipo == "4"
			cTabCad := "CTH"
			cEntIni := cCLVLIni
			bCond 	:= { || CT2->CT2_CLVLCR == CTH->CTH_CLVL}					
			dbSetOrder(9)
		EndIf
		
		dbSelectArea(cTabCad)
		dbSetOrder(2)
		cFilEnt := xFilial(cTabCad)
		cFilCT2	:= xFilial("CT2")
		cEntIni := If(Empty(cEntIni),"",cEntIni)		/// Se tiver espacos em branco usa "" p/ seek
		dbSeek(cFilEnt+"2"+cEntIni,.T.)					/// Procura inicial analitica
		
		If cTipo == "2"
			bCondCad := {|| CTT->CTT_FILIAL == cFilEnt .and. CTT->CTT_CUSTO <= cCustoFim }
		ElseIf cTipo == "3"
   			bCondCad := {|| CTD->CTD_FILIAL == cFilEnt .and. CTD->CTD_ITEM <= cItemFim }
  		ElseIf cTipo == "4"
			bCondCad := {|| CTH->CTH_FILIAL == cFilEnt .and. CTH->CTH_CLVL <= cCLVLFim }  		
  		EndIf
		
		While (cTabCad)->(!Eof()) .and. Eval(bCondCad)			/// WHILE DO CADASTRO DE ENTIDADES
	
			dbSelectArea("CT2")    	
			If cTipo == "2"
				MsSeek(cFilCT2+CTT->CTT_CUSTO+DTOS(dDataIni),.T.)
			ElseIf cTipo == "3"
				MsSeek(cFilCT2+CTD->CTD_ITEM+DTOS(dDataIni),.T.)			
			Else
				MsSeek(cFilCT2+CTH->CTH_CLVL+DTOS(dDataIni),.T.)						
			EndIf

			dbSelectArea("CT2")									/// WHILE CT2 - CREDITO
			While CT2->(!Eof()) .And. CT2->CT2_FILIAL == cFilCT2 .and. Eval(bCond) .and. CT2->CT2_DATA <= dDataFim

				If CT2->CT2_VALOR = 0
					dbSkip()
					Loop				
				EndIf
		
				If Empty(c2Moeda)			
					If CT2->CT2_MOEDLC <> cMoeda
						dbSkip()
						Loop
					EndIF
				Else
					If !(&(cFilMoeda))
						dbSkip()
						Loop
					EndIf			
				EndIf
				
				If (CT2->CT2_DC == "2" .Or. CT2->CT2_DC == "3") .And. &(cVldEnt) .And. CT2->CT2_TPSALD == cSaldo
					CT2->(CtbGrvCuc(lJunta,cMoeda,cSaldo,"2",c2Moeda,cAliasCT2,nTipo))
				Endif
				dbSelectArea("CT2")
				dbSkip()
			EndDo	
			(cTabCad)->(dbSkip())
		EndDo
	EndIf

#IFDEF TOP
	EndIf
#ENDIF

If lNoMov .or. lSldAnt
	If cTipo == "1"
		dbSelectArea("CT1")
		dbSetOrder(3)
		IndRegua(	Alias(),CriaTrab(nil,.f.),IndexKey(),,;
						"CT1_FILIAL == '" + xFilial("CT1") + "' .And. CT1_CONTA >= '"+cContaI+ "' .And. CT1_CONTA <= '" +;
						cContaF + "' .And. CT1_CLASSE = '2'",STR0033) //"Selecionando Registros..."
		cCpoChave := "CT1_CONTA"
		cTmpChave := "CONTA"
	ElseIf cTipo == "2"
		dbSelectArea("CTT")
		dbSetOrder(2)
		IndRegua(	Alias(),CriaTrab(nil,.f.),IndexKey(),,;
						"CTT_FILIAL == '" + xFilial("CTT") + "' .And. CTT_CUSTO >= '"+cCustoI+"' .And. CTT_CUSTO <= '" +;
						cCUSTOF + "' .And. CTT_CLASSE == '2'",STR0033) //"Selecionando Registros..."
		cCpoChave := "CTT_CUSTO"
		cTmpChave := "CCUSTO"
	ElseIf ctipo == "3"
		dbSelectArea("CTD")
		dbSetOrder(2)
		IndRegua(	Alias(),CriaTrab(nil,.f.),IndexKey(),,;
						"CTD_FILIAL == '" + xFilial("CTD") + "' .And. CTD_ITEM >= '"+cItemI+"' .And. CTD_ITEM <= '" +;
						cITEMF + "' .And. CTD_CLASSE == '2'",STR0033) //"Selecionando Registros..."
		cCpoChave := "CTD_ITEM"
		cTmpChave := "ITEM"
	ElseIf ctipo == "4"
		dbSelectArea("CTH")
		dbSetOrder(2)
		IndRegua(	Alias(),CriaTrab(nil,.f.),IndexKey(),,;
						"CTH_FILIAL == '" + xFilial("CTH") + "' .And. CTH_CLVL >= '"+cClVlI+"' .And. CTH_CLVL <= '" +;
						cCLVLF + "' .And. CTH_CLASSE == '2'",STR0033) //"Selecionando Registros..."
		cCpoChave := "CTH_CLVL"
		cTmpChave := "CLVL"
	EndIf

	cAlias := Alias()

	While ! Eof()
		dbSelectArea("cArqTmp")
		cKey2Seek	:= &(cAlias + "->" + cCpoChave)
		If !DbSeek(cKey2Seek)
			If lNoMov		
				CtbGrvNoCuc(cKey2Seek,dDataIni,cTmpChave)
			ElseIf cTipo == "1"		/// SOMENTE PARA O Cuca POR CONTA
				/// TRATA OS DADOS PARA A PERGUNTA "IMPRIME CONTA SEM MOVIMENTO" = "NAO C/ SLD.ANT."
				If SaldoCT7(cKey2Seek,dDataIni,cMoeda,cSaldo,'CTBR400')[6] <> 0 .and. cArqTMP->CONTA <> cKey2Seek
					/// SE TIVER SALDO ANTERIOR E NÃO TIVER MOVIMENTO GRAVADO
					CtbGrvNoCuc(cKey2Seek,dDataIni,cTmpChave)
				Endif
			EndIf
		Endif
		DbSelectArea(cAlias)
		DbSkip()
	EndDo

	DbSelectArea(cAlias)
	DbClearFil()
	RetIndex(cAlias)
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CtbGrvCuc ³ Autor ³ Paulo Augusto         ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Grava registros no arq temporario - Cuca                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³CtbGrvCuc(lJunta,cMoeda,cSaldo,cTipo)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpL1 = Se Junta CC ou nao                                 ³±±
±±³           ³ ExpC1 = Moeda                                              ³±±
±±³           ³ ExpC2 = Tipo de saldo                                      ³±±
±±            ³ ExpC3 = Tipo do lancamento                                 ³±±
±±³           ³ c2Moeda = Indica moeda 2 a ser incluida no relatorio       ³±±
±±³           ³ cAliasQry = Alias com o conteudo selecionado do CT2        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbGrvCuc(lJunta,cMoeda,cSaldo,cTipo,c2Moeda,cAliasCT2,nTipo)

Local cConta
Local cContra
Local cCusto
Local cItem
Local cCLVL
Local cChave   	:= ""
Local lImpCPartida := GetNewPar("MV_IMPCPAR",.T.) // Se .T.,     IMPRIME Contra-Partida para TODOS os tipos de lançamento (Débito, Credito e Partida-Dobrada),
                                                  // se .F., NÃO IMPRIME Contra-Partida para NENHUM   tipo  de lançamento.

DEFAULT cAliasCT2	:= "CT2"

If !Empty(c2Moeda)
	If cTipo == "1"
		cChave	:=	(cAliasCT2)->(CT2_DEBITO+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI)
	Else
    	cChave	:=	(cAliasCT2)->(CT2_CREDIT+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI)
 	EndIf
EndIf

If cTipo == "1"
	cConta 	:= (cAliasCT2)->CT2_DEBITO
	cContra	:= (cAliasCT2)->CT2_CREDIT
	cCusto	:= (cAliasCT2)->CT2_CCD
	cItem	:= (cAliasCT2)->CT2_ITEMD
	cCLVL	:= (cAliasCT2)->CT2_CLVLDB
EndIf	
If cTipo == "2"
	cConta 	:= (cAliasCT2)->CT2_CREDIT
	cContra := (cAliasCT2)->CT2_DEBITO
	cCusto	:= (cAliasCT2)->CT2_CCC
	cItem	:= (cAliasCT2)->CT2_ITEMC
	cCLVL	:= (cAliasCT2)->CT2_CLVLCR
EndIf		           

dbSelectArea("cArqTmp")
dbSetOrder(1)	
If !Empty(c2Moeda) 
	If MsSeek(cChave,.F.)
		Reclock("cArqTmp",.F.)
	Else
		RecLock("cArqTmp",.T.)		
	EndIf
Else
	RecLock("cArqTmp",.T.)
EndIf

Replace DATAL		With (cAliasCT2)->CT2_DATA
Replace TIPO		With cTipo
Replace LOTE		With (cAliasCT2)->CT2_LOTE
Replace SUBLOTE		With (cAliasCT2)->CT2_SBLOTE
Replace DOC			With (cAliasCT2)->CT2_DOC
Replace LINHA		With (cAliasCT2)->CT2_LINHA
Replace CONTA		With cConta 
aAliasAtu:=GetArea()
CT1->(DbSeek(xFilial("CT1")+cConta ))

If ( CT1->CT1_NORMAL == "1" .AND. cAliasCT2->CT2_DEBITO == CT1->CT1_CONTA ) .OR. ( CT1->CT1_NORMAL == "2" .AND. CT2->CT2_CREDIT == CT1->CT1_CONTA )
	lAumenta:=.T.
Else
	lAumenta:=.F.

EndIf
RestArea(aAliasAtu)
If lImpCPartida
	Replace XPARTIDA	With cContra
EndIf
Replace CCUSTO		With cCusto
Replace ITEM		With cItem
Replace CLVL		With cCLVL
Replace HISTORICO	With (cAliasCT2)->CT2_HIST
Replace EMPORI		With (cAliasCT2)->CT2_EMPORI
Replace FILORI		With (cAliasCT2)->CT2_FILORI
Replace SEQHIST		With (cAliasCT2)->CT2_SEQHIST
Replace SEQLAN		With (cAliasCT2)->CT2_SEQLAN
Replace NOMOV		With .F.							// Conta com movimento

If cPaisLoc $ "CHI|ARG"
	Replace SEGOFI With (cAliasCT2)->CT2_SEGOFI// Correlativo para Chile
EndIf

If Empty(c2Moeda)	//Se nao for Cuca em 2 Moedas
	If lAumenta
		Replace LANCDEB	With LANCDEB + (cAliasCT2)->CT2_VALOR
	Else
		Replace LANCCRD	With LANCCRD + (cAliasCT2)->CT2_VALOR
	EndIf	    
	If (cAliasCT2)->CT2_DC == "3"
		Replace TIPO	With cTipo
	Else
		Replace TIPO 	With (cAliasCT2)->CT2_DC
	EndIf		
Else	//Se for Cuca em 2 Moedas
	If (nTipo = 1 .Or. nTipo = 3) .And. (cAliasCT2)->CT2_MOEDLC = cMoeda //Se Imprime Valor na Moeda ou ambos
		If lAumenta
			Replace LANCDEB With (cAliasCT2)->CT2_VALOR	
		Else			
			Replace LANCCRD With (cAliasCT2)->CT2_VALOR	
		EndIf
	EndIf
    If (nTipo = 2 .Or. nTipo = 3) .And. (cAliasCT2)->CT2_MOEDLC = c2Moeda	//Se Imprime Moeda Corrente ou Ambas
		If cTipo == "1"
			Replace LANCDEB_1	With (cAliasCT2)->CT2_VALOR
		Else
			Replace LANCCRD_1	With (cAliasCT2)->CT2_VALOR
		Endif
	EndIf
	If LANCDEB_1 <> 0 .And. LANCDEB <> 0 
		Replace TXDEBITO  	With LANCDEB_1 / LANCDEB		
	Endif                                               
	If LANCCRD_1 <> 0 .And. LANCCRD <> 0
		Replace TXCREDITO 	With LANCCRD_1 / LANCCRD
	EndIf	
	If (cAliasCT2)->CT2_DC == "3"
		Replace TIPO	With cTipo
	Else
		Replace TIPO 	With (cAliasCT2)->CT2_DC
	EndIf			
EndIf

If nTipo = 1 .And. (LANCDEB + LANCCRD) = 0
	DbDelete()
ElseIf nTipo = 2 .And. (LANCDEB_1 + LANCCRD_1) = 0
	DbDelete()
Endif
If ! Empty(c2Moeda) .And. LANCDEB + LANCDEB_1 + LANCCRD + LANCCRD_1 = 0
	DbDelete()
Endif
MsUnlock()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CtbGrvNoCuc ³ Autor ³ Paulo Augusto       ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Grava registros no arq temporario sem movimento.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³CtbGrvNoCuc(cConta)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ cConteudo = Conteudo a ser gravado no campo chave de acordo³±±
±±³           ³             com o Cuca impresso                            ³±±
±±³           ³ dDataL = Data para verificacao do movimento da conta       ³±±
±±³           ³ cCpoChave = Nome do campo para gravacao no temporario      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbGrvNoCuc(cConteudo,dDataL,cCpoTmp)

dbSelectArea("cArqTmp")
dbSetOrder(1)	

RecLock("cArqTmp",.T.)
Replace &(cCpoTmp)	With cConteudo
If cCpoTmp = "CONTA"
	Replace HISTORICO		With STR0034 //"CONTA SEM MOVIMENTO NO PERIODO"
ElseIf cCpoTmp = "CCUSTO"
	Replace HISTORICO		With Upper(AllTrim(CtbSayApro("CTT"))) + " "  + STR0035 //"SEM MOVIMENTO NO PERIODO"
ElseIf cCpoTmp = "ITEM"
	Replace HISTORICO		With Upper(AllTrim(CtbSayApro("CTD"))) + " "  + STR0035 //"SEM MOVIMENTO NO PERIODO"
ElseIf cCpoTmp = "CLVL"
	Replace HISTORICO		With Upper(AllTrim(CtbSayApro("CTH"))) + " "  + STR0035 //"SEM MOVIMENTO NO PERIODO"
Endif
Replace DATAL 			WITH dDataL 
MsUnlock()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CtbQryCuc ³ Autor ³ Paulo Augusto      	 ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Realiza a "filtragem" dos registros do Cuca                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³CtbQryCuc(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,	   ³±±
±±³			  ³	cCustoIni,cCustoFim, cItemIni,cItemFim,cCLVLIni,cCLVLFim,  ³±±
±±³			  ³	cMoeda,dDataIni,dDataFim,aSetOfBook,lNoMov,cSaldo,lJunta,  ³±±
±±³			  ³	cTipo)                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpO1 = Objeto oMeter                                      ³±±
±±³           ³ ExpO2 = Objeto oText                                       ³±±
±±³           ³ ExpO3 = Objeto oDlg                                        ³±±
±±³           ³ ExpL1 = Acao do Codeblock                                  ³±±
±±³           ³ ExpC2 = Conta Inicial                                      ³±±
±±³           ³ ExpC3 = Conta Final                                        ³±±
±±³           ³ ExpC4 = C.Custo Inicial                                    ³±±
±±³           ³ ExpC5 = C.Custo Final                                      ³±±
±±³           ³ ExpC6 = Item Inicial                                       ³±±
±±³           ³ ExpC7 = Cl.Valor Inicial                                   ³±±
±±³           ³ ExpC8 = Cl.Valor Final                                     ³±±
±±³           ³ ExpC9 = Moeda                                              ³±±
±±³           ³ ExpD1 = Data Inicial                                       ³±±
±±³           ³ ExpD2 = Data Final                                         ³±±
±±³           ³ ExpA1 = Matriz aSetOfBook                                  ³±±
±±³           ³ ExpL2 = Indica se imprime movimento zerado ou nao.         ³±±
±±³           ³ ExpC10= Tipo de Saldo                                      ³±±
±±³           ³ ExpL3 = Indica se junta CC ou nao.                         ³±±
±±³           ³ ExpC11= Tipo do lancamento                                 ³±±
±±³           ³ c2Moeda = Indica moeda 2 a ser incluida no relatorio       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbQryCuc(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,cCustoIni,cCustoFim,;
				  cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
				  aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,c2Moeda,cUFilter,lSldAnt)

Local aSaveArea := GetArea()
Local nMeter	:= 0
Local cQuery	:= ""
Local aTamVlr	:= TAMSX3("CT2_VALOR")     
Local lNoMovim	:= .F.
Local cContaAnt	:= ""
Local cCampUSU	:= ""
local aStrSTRU	:= {}
Local nStr		:= 0

Local lImpCPartida := GetNewPar("MV_IMPCPAR",.T.) // Se .T.,     IMPRIME Contra-Partida para TODOS os tipos de lançamento (Débito, Credito e Partida-Dobrada),
                                                  // se .F., NÃO IMPRIME Contra-Partida para NENHUM   tipo  de lançamento.

DEFAULT lSldAnt := .F.

oMeter:SetTotal(CT2->(RecCount()))
oMeter:Set(0)

cQuery	:= " SELECT CT1_CONTA CONTA, ISNULL(CT2_CCD,'') CUSTO,ISNULL(CT2_ITEMD,'') ITEM, ISNULL(CT2_CLVLDB,'') CLVL, ISNULL(CT2_DATA,'') DDATA, ISNULL(CT2_TPSALD,'') TPSALD, "	
cQuery	+= " ISNULL(CT2_DC,'') DC, ISNULL(CT2_LOTE,'') LOTE, ISNULL(CT2_SBLOTE,'') SUBLOTE, ISNULL(CT2_DOC,'') DOC, ISNULL(CT2_LINHA,'') LINHA, ISNULL(CT2_CREDIT,'') XPARTIDA, ISNULL(CT2_HIST,'') HIST, ISNULL(CT2_SEQHIS,'') SEQHIS, ISNULL(CT2_SEQLAN,'') SEQLAN, '1' TIPOLAN, "	
////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cUFilter)									//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := CT2->(dbStruct())				//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)						
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA 
		cCampUSU += aStrSTRU[nStr][1]+","			//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif
cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY
////////////////////////////////////////////////////////////
cQuery  += " ISNULL(CT2_VALOR,0) VALOR, ISNULL(CT2_EMPORI,'') EMPORI, ISNULL(CT2_FILORI,'') FILORI"       
If cPaisLoc $ "CHI|ARG"
	cQuery	+= ", ISNULL(CT2_SEGOFI,'') SEGOFI"
EndIf
cQuery	+= " FROM "+ RetSqlName("CT1") + " CT1 LEFT JOIN " + RetSqlName("CT2") + " CT2 "
cQuery	+= " ON CT2.CT2_FILIAL = '"+xFilial("CT2")+"' "
cQuery	+= " AND CT2.CT2_DEBITO = CT1.CT1_CONTA"  
cQuery  += " AND CT2.CT2_DATA >= '"+DTOS(dDataIni)+ "' AND CT2.CT2_DATA <= '"+DTOS(dDataFim)+"'"
cQuery	+= " AND CT2.CT2_CCD >= '" + cCustoIni + "' AND CT2.CT2_CCD <= '" + cCustoFim +"'"
cQuery  += " AND CT2.CT2_ITEMD >= '" + cItemIni + "' AND CT2.CT2_ITEMD <= '"+ cItemFim +"'"
cQuery  += " AND CT2.CT2_CLVLDB >= '" + cClvlIni + "' AND CT2.CT2_CLVLDB <= '" + cClVlFim +"'"
cQuery  += " AND CT2.CT2_TPSALD = '"+ cSaldo + "'"
cQuery	+= " AND CT2.CT2_MOEDLC = '" + cMoeda +"'"
cQuery  += " AND (CT2.CT2_DC = '1' OR CT2.CT2_DC = '3') "
cQuery  += " AND CT2_VALOR <> 0 "
cQuery	+= " AND CT2.D_E_L_E_T_ = ' ' "	
cQuery	+= " WHERE CT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
cQuery	+= " AND CT1.CT1_CLASSE = '2' "
cQuery	+= " AND CT1.CT1_CONTA >= '"+ cContaIni+"' AND CT1.CT1_CONTA <= '"+cContaFim+"'"
cQuery	+= " AND CT1.D_E_L_E_T_ = '' "
cQuery	+= " UNION "
cQuery	+= " SELECT CT1_CONTA CONTA, ISNULL(CT2_CCC,'') CUSTO, ISNULL(CT2_ITEMC,'') ITEM, ISNULL(CT2_CLVLCR,'') CLVL, ISNULL(CT2_DATA,'') DDATA, ISNULL(CT2_TPSALD,'') TPSALD, "	
cQuery	+= " ISNULL(CT2_DC,'') DC, ISNULL(CT2_LOTE,'') LOTE, ISNULL(CT2_SBLOTE,'')SUBLOTE, ISNULL(CT2_DOC,'') DOC, ISNULL(CT2_LINHA,'') LINHA, ISNULL(CT2_DEBITO,'') XPARTIDA, ISNULL(CT2_HIST,'') HIST, ISNULL(CT2_SEQHIS,'') SEQHIS, ISNULL(CT2_SEQLAN,'') SEQLAN, '2' TIPOLAN, "	
////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cUFilter)									//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := CT2->(dbStruct())				//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)						
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA 
		cCampUSU += aStrSTRU[nStr][1]+","			//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif
cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY
////////////////////////////////////////////////////////////

cQuery  += " ISNULL(CT2_VALOR,0) VALOR, ISNULL(CT2_EMPORI,'') EMPORI, ISNULL(CT2_FILORI,'') FILORI"              
If cPaisLoc $ "CHI|ARG"
	cQuery	+= ", ISNULL(CT2_SEGOFI,'') SEGOFI"
EndIf
cQuery	+= " FROM "+RetSqlName("CT1")+ ' CT1 LEFT JOIN '+ RetSqlName("CT2") + ' CT2 '
cQuery	+= " ON CT2.CT2_FILIAL = '"+xFilial("CT2")+"' "
cQuery	+= " AND CT2.CT2_CREDIT =  CT1.CT1_CONTA "
cQuery  += " AND CT2.CT2_DATA >= '"+DTOS(dDataIni)+ "' AND CT2.CT2_DATA <= '"+DTOS(dDataFim)+"'"
cQuery	+= " AND CT2.CT2_CCC >= '" + cCustoIni + "' AND CT2.CT2_CCC <= '" + cCustoFim +"'"
cQuery  += " AND CT2.CT2_ITEMC >= '" + cItemIni + "' AND CT2.CT2_ITEMC <= '"+ cItemFim +"'"
cQuery  += " AND CT2.CT2_CLVLCR >= '" + cClvlIni + "' AND CT2.CT2_CLVLCR <= '" + cClVlFim +"'"
cQuery  += " AND CT2.CT2_TPSALD = '"+ cSaldo + "'"
cQuery	+= " AND CT2.CT2_MOEDLC = '" + cMoeda +"'"
cQuery  += " AND (CT2.CT2_DC = '2' OR CT2.CT2_DC = '3') "
cQuery  += " AND CT2_VALOR <> 0 "
cQuery	+= " AND CT2.D_E_L_E_T_ = ' ' "	
cQuery	+= " WHERE CT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
cQuery	+= " AND CT1.CT1_CLASSE = '2' "
cQuery	+= " AND CT1.CT1_CONTA >= '"+ cContaIni+"' AND CT1.CT1_CONTA <= '"+cContaFim+"'"
cQuery	+= " AND CT1.D_E_L_E_T_ = ''"	            
cQuery := ChangeQuery(cQuery)		   
If Select("cArqCT2") > 0
	dbSelectArea("cArqCT2")
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"cArqCT2",.T.,.F.)
TcSetField("cArqCT2","CT2_VLR"+cMoeda,"N",aTamVlr[1],aTamVlr[2])
TcSetField("cArqCT2","DDATA","D",8,0)

If !Empty(cUFilter)									//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA 
		If aStrSTRU[nStr][2] <> "C" .and. cArqCT2->(FieldPos(aStrSTRU[nStr][1])) > 0
			TcSetField("cArqCT2",aStrSTRU[nStr][1],aStrSTRU[nStr][2],aStrSTRU[nStr][3],aStrSTRU[nStr][4])
		EndIf
	Next
Endif
 			
dbSelectarea("cArqCT2")
If Empty(cUFilter)
	cUFilter := ".T."
Endif						

While !Eof()                                              
	If Empty(cArqCT2->DDATA) //Se nao existe movimento 
		cContaAnt	:= cArqCT2->CONTA	
		dbSkip()
		If Empty(cArqCT2->DDATA) .And. cContaAnt == cArqCT2->CONTA
			lNoMovim	:= .T.
		EndIf
	Endif        
	
	If &("cArqCT2->("+cUFilter+")")						
		If lNoMovim
			If lNoMov  
				If CtbExDtFim("CT1")							
					dbSelectArea("CT1")
					dbSetOrder(1) 
					If MsSeek(xFilial()+cArqCT2->CONTA)
						If CtbVlDtFim("CT1",dDataIni) 
							CtbGrvNoCuc(cArqCT2->CONTA,dDataIni,"CONTA")	//Esta sendo passado "CONTA" fixo, porque essa funcao esta sendo 									
						EndIf												//chamada somente para o CTBR400
					EndIf				
				Else
					CtbGrvNoCuc(cArqCT2->CONTA,dDataIni,"CONTA")	//Esta sendo passado "CONTA" fixo, porque essa funcao esta sendo 				
				EndIf												//chamada somente para o CTBR400
			ElseIf lSldAnt 
				If SaldoCT7(cArqCT2->CONTA,dDataIni,cMoeda,cSaldo,'CTBR400')[6] <> 0 .and. cArqTMP->CONTA <> cArqCT2->CONTA																							
					CtbGrvNoCuc(cArqCT2->CONTA,dDataIni,"CONTA")	
				Endif			
			EndIf
		Else
			RecLock("cArqTmp",.T.)		    	
		    Replace DATAL		With cArqCT2->DDATA
			Replace TIPO		With cArqCT2->DC
			Replace LOTE		With cArqCT2->LOTE
			Replace SUBLOTE		With cArqCT2->SUBLOTE
			Replace DOC			With cArqCT2->DOC
			Replace LINHA		With cArqCT2->LINHA
			Replace CONTA		With cArqCT2->CONTA			
			Replace CCUSTO		With cArqCT2->CUSTO
			Replace ITEM		With cArqCT2->ITEM
			Replace CLVL		With cArqCT2->CLVL
			If lImpCPartida
				Replace XPARTIDA	With cArqCT2->XPARTIDA
			EndIf		
			Replace HISTORICO	With cArqCT2->HIST
			Replace EMPORI		With cArqCT2->EMPORI
			Replace FILORI		With cArqCT2->FILORI
			Replace SEQHIST		With cArqCT2->SEQHIS
			Replace SEQLAN		With cArqCT2->SEQLAN

			If cPaisLoc $ "CHI|ARG"
				Replace SEGOFI With cArqCT2->SEGOFI// Correlativo para Chile
			EndIf
	        
			aAliasAtu:=GetArea()
			CT1->(DbSeek(xFilial("CT1")+cArqCT2->CONTA ))

			If CT1->CT1_NORMAL=="1" .And. cArqCT2->TIPOLAN=="1" .OR. CT1->(CT1_NORMAL=="2") .And.  cArqCT2->TIPOLAN=="2"
				lAumenta:=.T.
			Else
				lAumenta:=.F.
			EndIf

			RestArea(aAliasAtu)
			Replace SEQLAN		With cArqCT2->SEQLAN
			
			If lAumenta
				Replace LANCDEB	With LANCDEB + cArqCT2->VALOR
			Else
				Replace LANCCRD	With LANCCRD + cArqCT2->VALOR
			EndIf	
			MsUnlock()
		Endif         
	EndIf
	lNoMovim	:= .F.	
	dbSelectArea("cArqCT2")	
	dbSkip()
	nMeter++
	oMeter:Set(nMeter)		
Enddo	

RestArea(aSaveArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBRCABEC    ³Autor ³  Paulo Augusto       ³Data³ 20/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria cabecalho para o relatorio.                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBRCABEC(dDataFim,Titulo,aCab,oReport)    

Local cChar := chr(160)  // caracter dummy para alinhamento do cabeçalho
DEFAULT aCab := {}
DEFAULT Titulo:=" "

If SM0->(Eof())                                
	SM0->(MsSeek(cEmpAnt+cFilAnt,.T.))
Endif

RptFolha := GetNewPar("MV_CTBPAG",RptFolha)

Aadd(aCab,AllTrim(SM0->M0_NOMECOM))
Aadd(aCab,AllTrim(titulo))
Aadd(aCab,Transform(Alltrim(SM0->M0_CGC),AllTrim(X3Picture("A1_CGC"))))

aCabec := {	"__LOGOEMP__" , cChar + "         " + SM0->M0_NOMECOM ;
	      + "         " + cChar + RptFolha+ TRANSFORM(oReport:Page(),'999999');	      
          , "SIGA / " + NomeProg + " /v." + cVersao ; //"SIGA / CTBR401 /v."
          + cChar + "         " + UPPER(AllTrim(titulo));
          + "         " + cChar + RptDtRef + " " + DTOC(dDataFim);
          , RptHora + " " + time() ;
          + "         " + cChar + RptEmiss + " " + Dtoc(dDataBase) }            

Return aCabec