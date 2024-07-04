#INCLUDE "GPER140COL.ch"

#DEFINE nColMax	 2300
#DEFINE nLinMax 2870

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Gper140col  ³ Autor ³ Cesar Bautista          ³ Data ³ 26.09.18   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carta de Finiquito - Colombia                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador   ³ Data   ³ BOPS/FNC  ³          Motivo da Alteracao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marco A. Glez ³04/05/21³DMINA-11978³Se realizan ajustes a la funciones fEnc()y³±±
±±³              ³        ³           ³fRodape() para imprimir de forma correcta ³±±
±±³              ³        ³           ³la Carta de Finiquitos.                   ³±±
±±³Diego Rivera  ³29/09/21³DMINA-13717³Se realizan ajustes en función fImp140Col ³±±
±±³              ³        ³           ³Se modifican formatos de importes para que³±±
±±³              ³        ³           ³se impriman de forma correcta valores de  ³±±
±±³              ³        ³           ³100 millones o más en Carta de Finiquitos.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function GPER140COL()

	Local olReport	:= Nil
	Local oSection1	:= Nil
	Local clNomProg	:= FunName()
	Local clTitulo	:= STR0001 //"CARTA FINIQUITO"
	Local clDesc	:= STR0002 //"Empresa: "
	Local aOrdem	:= {OemToAnsi(STR0057),OemToAnsi(STR0058)} // 1- Matrícula , 2- Centro de Trabajo
	
	Private oFont	:= TFont():New("Courier New",09,12,.T.,.F.,5,.T.,5,.F.,.F.)
	Private oFont1	:= TFont():New("Courier New",09,13,.T.,.T.,5,.T.,5,.F.,.F.)
    Private oFont10	:= TFont():New("Courier New",,-10,,)
    Private oPrint	:= Nil 
    Private nColIni	:= 100
    
	If FindFunction("TRepInUse") .And. TRepInUse()
		Pergunte("GPER140COL",.T.)
		olReport := TReport():New(clNomProg,clTitulo,"GPER140COL",{|olReport|iif(ValTipImp(olReport),fImp140Col(olReport),olReport:CancelPrint())},clDesc)
		oSection1 := TRSection():New(olReport,,, aOrdem)
		olReport:oPage:nPaperSize	:=  1 //cARTA //9 	// Impressão em papel A4
		olReport:lHeaderVisible  	:= .F. 	// Não imprime cabeçalho do protheus
		olReport:lFooterVisible  	:= .F.	// Não imprime rodapé do protheus
		olReport:lParamPage			:= .F.	// Não imprime pagina de parametros
		olReport:PrintDialog()
	Endif

Return

/*/{Protheus.doc} ValTipImp
Función que valida si el Tipo de impresión esta disponible o no.
@type
@author eduardo.manriquez
@since 01/03/2021
@version 1.0
@param oReport, Object, Instancia de TReport.
@return boolean,retorna .F. cuando el Tipo de impresión no esta disponible.
@example
ValTipImp(oReport)
@see (links_or_references)
/*/
Function ValTipImp(oReport)
	if oReport:nDevice == 4 //1-Archivo,2-Spool,3-Email,4-Planilla,5-Html y 6-PDF
		MsgAlert(STR0059) //"La opción Planilla no se encuentra disponible"
		Return .F.
	EndIf
Return .T.

Static Function fImp140Col(oReport)

	Local nHoras   	:= ""
	Local cRoteir  	:= fGetCalcRot('4')	// RESCISAO
	Local nTot		:= 0
	Local nCont		:= 2
	Local Imprime	:= 1   				//LINHA DE IMPRESSAO DO RELATORIO GRAFICO 
	Local nImpr2    := 1
	Local n			:= 0
	Local nOrden    := oReport:Section(1):GetOrder()
	Local nTipImp   := oReport:nDevice //1-Archivo,2-Spool,3-Email,4-Planilla,5-Html y 6-PDF
	Local lImpPDF   := Iif(nTipImp == 6 , .T.,.F.)
	Local cTabSR	:= ""
	Local lSelec	:= .F.
	
	Private cMatriculas := ""
	Private cRanProces := "" 
	Private cfiltroSRC := ""
	Private aPdv 	:= {}
	Private	aHomV	:= {}
	Private	aHomD	:= {}	
	Private	aPdd 	:= {}
	Private	aPdn	:= {} 
	Private	aPdpm	:= {}
	Private	aPddm	:= {}
	Private	aImpr	:= {}
	Private	aResc	:= {}
	Private aCodFol		:= {}         // Matriz com Codigo da folha
	Private cFiliAnt := "__cFiliAnt__"
	Private nPos		:= 0				//LINHA DE IMPRESSAO DO RELATORIO GRAFICO
	Private nNumMax		:= 25				//Numero maximo de verbas impressas no Detalhe da rescisao 
	Private nImprime	:= 1 				//Variavel Auxiliar 
	Private nImpre		:= 1 
	Private CONTFL		:= 1				//CONTA PAGINA
	Private cCodMsg 	:= ""
	Private cIdRep	:= ""
	Private cTpIdRep 	:= ""
	Private cNomRep	:= ""
	Private nNumLn		:=0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Objetos para Impressao Grafica - Declaracao das Fontes Utilizadas.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private oFont11n,oFont14n, oFont09, oFont09n,oFont07 
	
	oFont07	:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
	oFont07n:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
	oFont09	:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
	oFont09n:= TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)     //Negrito//
	oFont11n:= TFont():New("Arial",11,11,,.T.,,,,.T.,.F.)     //Negrito//
	oFont14n:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)     //Negrito//
	
	/*
	* MV_PAR01 - ¿Proceso?
	* MV_PAR02 - ¿Procedimiento?
	* MV_PAR03 - ¿Periodo?
	* MV_PAR04 - ¿Num Pago ?
	* MV_PAR05 - ¿Matrícula ?
	* MV_PAR06 - ¿Mensaje ?
	* MV_PAR07 - ¿Nombre empleador/Represent ?
	* MV_PAR08 - ¿Tipo Id Representante ?
	* MV_PAR09 - ¿Doc Empleador/Representante ?
	*/
	Pergunte("GPER140COL",.f.)
	
	MakeAdvplExpr("GPER140COL")
	
	cRanProces	:= MV_PAR01
	cRoteir		:= MV_PAR02
	cMatriculas := IIF(Empty(AllTrim(MV_PAR05)),"1==1",MV_PAR05)
	cCodMsg 	:= MV_PAR06
	cNomRep		:= MV_PAR07
	cTpIdRep 	:= MV_PAR08
	cIdRep		:= MV_PAR09

	DbSelectArea("RCH") 
	RCH->(DbSetOrder(1)) //RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR
	If RCH->(MsSeek(xFilial("RCH") + cRanProces + MV_PAR03 + MV_PAR04 + cRoteir))
		If Empty(RCH->RCH_DTFECH) // Validar si ya se ha cerrado en el periodo y procedimiento indicado
			DbSelectArea("SRC")
			SRC->(DbSetOrder(6)) //RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA+RC_PD
			cTabSR := "C"
		Else
			DbSelectArea("SRD")
			SRD->(DbSetOrder(5)) //RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA+RD_PD
			cTabSR := "D"
		EndIf
	EndIf

	dbSelectArea("SRA")
	If nOrden == 1
		SRA->(dbSetOrder(nOrden)) //RA_FILIAL+RA_MAT+RA_NOME
	Else
		SRA->(dbSetOrder(19)) //RA_FILIAL+RA_KEYLOC+RA_NOME
	EndIf
	SRA->(DBGOTOP())

	WHILE !Empty(cTabSR) .And. !(SRA->(eof()))
	 
	 	If ( &(cMatriculas))
		 	// Obtiene Datos
		 	//MOVIMENTA REGUA DE PROCESSAMENTO
			cFilMat	:= ( SRA->RA_FILIAL + SRA->RA_MAT )
			
			aPdv 	:= {}
			aHomV	:= {}
			aHomD	:= {}	
			aPdd 	:= {}
			aPdn	:= {} 
			aPdpm	:= {}
			aPddm	:= {}
			aImpr	:= {}
			aResc	:= {}
		 	
		 	//CARREGA VARIAVEIS CODIGOS DA FOLHA
			If ( cFiliAnt # SRA->RA_FILIAL )
				cFiliAnt := SRA->RA_FILIAL
				If !fP_CodFol(@aCodFol,cFiliAnt)
					Return
				EndIf
			EndIf
		 	//DEFINE CODIGOS DE IDENTIfICADORES PARA O PERGUNTE MV_PAR16 PARA CALCULAR FERIAS EM AVOS OU EM HORAS
			cVerCodFol:=aCodFol[086,1]+"*"+ ;	//  Ferias Indenizadas
			            aCodFol[087,1]+"*"+ ;	//  Ferias Proporcionais
			            aCodFol[230,1]+"*"+ ;	//	Ferias s/ Av.Previo Indenizado
			            aCodFol[248,1]+"*"+ ;	//	Media Ferias Vencidas Rescisao
			            aCodFol[249,1]+"*"+ ;	//	Media Ferias Proporcionais Rescisao
			            aCodFol[252,1]			//	Media Ferias Sobre Aviso Indenizado Rescisao
			//DEFINE CODIGOS DE IDENTIfICADORES PARA O PERGUNTE MV_PAR32 PARA CALCULAR 13 SAL.EM AVOS OU EM HORAS.
			cVerCod13 :=aCodFol[114,1]+"*"+ ;	//  13o. na Indenizacao
		            	aCodFol[115,1]+"*"+ ;  	//  13o. Sobre Aviso Previo
		            	aCodFol[251,1]+"*"+ ; 	//	Media 13o. Salario Rescisao
		            	aCodFol[253,1]        	//	Media 13o. Salario Sobre Aviso Indenizado Rescisao
		
			// Busca en SRG
			dDtDemi := ctod("  /  /")
			dbSelectArea("SRG")
			If SRG->(MsSeek(xFilial("SRG")+SRA->RA_MAT))
	 			If SRG->RG_EFETIVA != "1"
					dDtDemi := SRG->RG_DATADEM
				EndIf
			EndIf

			lSelec	:= .F.
			nProv	:= nDesc := nNProv := 0.00
					
			If cTabSR == "C"

				If SRC->(MsSeek(xFILIAL("SRC")+SRA->RA_MAT+cRanProces+cRoteir+MV_PAR03+MV_PAR04))
					lSelec	:= .T.
				Else
					cSvRoteir	:= cRoteir 
					cRoteir 	:= fGetCalcRot('A')	// Aplicacao de Rescisao
					If SRC->(MsSeek(SRA->(RA_FILIAL+RA_MAT+RA_PROCES)+cRoteir))
						lSelec	:= .T.
					Else
				   	   cRoteir := cSvRoteir
					EndIf
				EndIf

				While SRC->(!Eof()) .And.	;
						(SRC->RC_FILIAL + SRC->RC_MAT + SRC->RC_PROCES + SRC->RC_ROTEIR + SRC->RC_PERIODO + SRC->RC_SEMANA) == ;
						(SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRoteir+MV_PAR03+MV_PAR04)
					//CONSISTE FILIAIS E ACESSOS
					If !(SRC->RC_FILIAL $ fValidFil())
						dbSelectArea("SRC")
						SRC->( dbSkip() )
						Loop
					EndIf
					//NAO IMPRIME VALORES ZERADOS
					If (SRC->RC_VALOR == 0.00 )
						SRC->( dbSkip() )
						Loop
					EndIf
					//VERIfICA O TIPO DA VERBA E CARREGA NO aPd CORRESPONDENTE
					nHoras	:= If(SRC->RC_TIPO1=="H",fConvHoras(SRC->RC_HORAS,"1"),SRC->RC_HORAS)

					If PosSrv(SRC->RC_PD,SRA->RA_FILIAL,"RV_TIPOCOD") == "1" .AND. PosSrv(SRC->RC_PD,SRA->RA_FILIAL,"RV_IMPRIPD") == "1"  //Provento
						Aadd(aPdv, Str(nHoras,6,2) + " " + Substr(DescPd(SRC->RC_PD,xFilial( "SRV", SRA->RA_FILIAL),20),1,20) + " " + TransForm(SRC->RC_VALOR,"@E 999,999,999.99") )
						nProv += SRC->RC_VALOR
					ElseIf PosSrv(SRC->RC_PD,SRA->RA_FILIAL,"RV_TIPOCOD") == "2" .And. SRC->RC_PD # aCodfol[126,1] .AND. PosSrv(SRC->RC_PD,SRA->RA_FILIAL,"RV_IMPRIPD") == "1" // Desconto e Despreza Liq. da Rescisao
						Aadd(aPdd, Str(nHoras,6,2) + " " + Substr(DescPd(SRC->RC_PD,xFilial( "SRV", SRA->RA_FILIAL),20),1,20) + " " + TransForm(SRC->RC_VALOR,"@E 999,999,999.99") )
						nDesc += SRC->RC_VALOR
					ElseIf PosSrv(SRC->RC_PD,xFilial( "SRV", SRA->RA_FILIAL),"RV_TIPOCOD") == "3" .AND. PosSrv(SRC->RC_PD,SRA->RA_FILIAL,"RV_IMPRIPD") == "1" //Base Provento
						Aadd(aPdpm,Str(nHoras,6,2) + " " + Substr(DescPd(SRC->RC_PD,xFilial( "SRV", SRA->RA_FILIAL),20),1,20) + " " + TransForm(SRC->RC_VALOR,"@E 999,999,999.99") )					
					EndIf

					SRC->(dbSkip())
				EndDo
				
			ElseIf cTabSR == "D"

				If SRD->(MsSeek(xFILIAL("SRD")+SRA->RA_MAT+cRanProces+cRoteir+MV_PAR03+MV_PAR04))
					lSelec	:= .T.
				Else
					cSvRoteir	:= cRoteir 
					cRoteir 	:= fGetCalcRot('A')	// Aplicacao de Rescisao
					If SRD->(MsSeek(SRA->(RA_FILIAL+RA_MAT+RA_PROCES)+cRoteir))
						lSelec	:= .T.
					Else
				   	   cRoteir := cSvRoteir
					EndIf
				EndIf

				While SRD->(!Eof()) .And.	;
						(SRD->RD_FILIAL + SRD->RD_MAT + SRD->RD_PROCES + SRD->RD_ROTEIR + SRD->RD_PERIODO + SRD->RD_SEMANA) == ;
						(SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRoteir+MV_PAR03+MV_PAR04)
					//CONSISTE FILIAIS E ACESSOS
					If !(SRD->RD_FILIAL $ fValidFil())
						dbSelectArea("SRD")
						SRD->( dbSkip() )
						Loop
					EndIf
					//NAO IMPRIME VALORES ZERADOS
					If (SRD->RD_VALOR == 0.00 )
						SRD->( dbSkip() )
						Loop
					EndIf
					//VERIfICA O TIPO DA VERBA E CARREGA NO aPd CORRESPONDENTE
					nHoras	:= If(SRD->RD_TIPO1=="H",fConvHoras(SRD->RD_HORAS,"1"),SRD->RD_HORAS)

					If PosSrv(SRD->RD_PD,SRA->RA_FILIAL,"RV_TIPOCOD") == "1" .AND. PosSrv(SRD->RD_PD,SRA->RA_FILIAL,"RV_IMPRIPD") == "1"  //Provento
						Aadd(aPdv, Str(nHoras,6,2) + " " + Substr(DescPd(SRD->RD_PD,xFilial( "SRV", SRA->RA_FILIAL),20),1,20) + " " + TransForm(SRD->RD_VALOR,"@E 999,999,999.99") )
						nProv += SRD->RD_VALOR
					ElseIf PosSrv(SRD->RD_PD,SRA->RA_FILIAL,"RV_TIPOCOD") == "2" .And. SRD->RD_PD # aCodfol[126,1] .AND. PosSrv(SRD->RD_PD,SRA->RA_FILIAL,"RV_IMPRIPD") == "1" // Desconto e Despreza Liq. da Rescisao
						Aadd(aPdd, Str(nHoras,6,2) + " " + Substr(DescPd(SRD->RD_PD,xFilial( "SRV", SRA->RA_FILIAL),20),1,20) + " " + TransForm(SRD->RD_VALOR,"@E 999,999,999.99") )
						nDesc += SRD->RD_VALOR
					ElseIf PosSrv(SRD->RD_PD,xFilial( "SRV", SRA->RA_FILIAL),"RV_TIPOCOD") == "3" .AND. PosSrv(SRD->RD_PD,SRA->RA_FILIAL,"RV_IMPRIPD") == "1" //Base Provento
						Aadd(aPdpm,Str(nHoras,6,2) + " " + Substr(DescPd(SRD->RD_PD,xFilial( "SRV", SRA->RA_FILIAL),20),1,20) + " " + TransForm(SRD->RD_VALOR,"@E 999,999,999.99") )					
					EndIf

					SRD->(dbSkip())
				EndDo
				
			EndIf

			If lSelec
				cCodSaq 	:= "  "
				cImpSac 	:= " "    
				cCodR		:= " "
				Imprime		:= 1
				nImprime	:= 1
				nImpre		:= 1
				nImpr2		:= 1
	
				cCausa := Space(30)

				//IMPRIME O NUMERO DE VIAS ESPECIfICADO
				SET CENTURY OFF
					nTot 	:= Max( Len(aPdv) , Len(aPdd) )
					nTot	:= Max( nTot , Len(aPdpm) )
					
					// Imprimi reporte
					fEnc(oReport,@nNumLn)
					
					//*--------------------
					While Imprime <=  nTot
						//-- Impressao do rodape e quebra de pagina 
						If nImpre > ( nNumMax ) .or. nImprime > nNumMax .or. nImpr2 > nNumMax
						nNumLn := 2650
							fRodape(oReport,nNumLn) 
							oReport:EndPage() 
							oReport:StartPage() 
							ContFl++  
							nNumLn := 0
							fEnc(oReport,@nNumLn)
							nCont += 2
							nNumMax := ( nNumMax * nCont ) 
							nImpre	:= ( nImpre + n)
						Endif 
					
						If nImpre <= nNumMax .or. Imprime <= nNumMax .or. nImpr2 <= nNumMax
							
							//--Coluna de Proventos  
							If nImpre <= Len(aPdv) 
								//--Primeira coluna de Provento 
								oReport:say (nNumLn,nColIni + Iif(lImpPDF,0,80) ,Space(1) + PADR(Subs(aPdv[nImpre],01,06),6),oFont07n,,,,1)
								oReport:say (nNumLn,nColIni + 100 ,Space(1) + PADL(Subs(aPdv[nImpre],08,20),20),oFont07n) 
								oReport:say (nNumLn,nColIni + Iif(lImpPDF,500,680),Space(1) + PADR(Subs(aPdv[nImpre],29,14),14),oFont07n,,,,1) 
								nImpre	+= 1
							Endif
							//-- Coluna de Descontos
							If nImprime <= Len(aPdd)  
								oReport:say (nNumLn,nColIni + Iif(lImpPDF,700,780),Space(1)  + PADR(Subs(aPdd[nImprime],01,06),6)   , oFont07n,,,,1)
								oReport:say (nNumLn,nColIni + 800,Space(1)  + PADL(Subs(aPdd[nImprime],08,20),20) , oFont07n)
								oReport:say (nNumLn,nColIni + Iif(lImpPDF,1250,1430),Space(1) + PADR(Subs(aPdd[nImprime],29,14),14), oFont07n,,,,1)
								nImprime	++
							Endif
							//-- Coluna de Base 
							If nImpr2 <= Len(aPdpm)  
								oReport:say (nNumLn,nColIni + Iif(lImpPDF,1450,1530),Space(1) + PADR(Subs(aPdpm[nImpr2],01,06),6)    , oFont07n,,,,1)
								oReport:say (nNumLn,nColIni + 1550,Space(1) + PADL(Subs(aPdpm[nImpr2],08,20),20) , oFont07n)
								oReport:say (nNumLn,nColIni + Iif(lImpPDF,2000,2180) ,Space(1) + PADR(Subs(aPdpm[nImpr2],29,14),14), oFont07n,,,,1)
								nImpr2	++
							Endif
										
						Endif  
						
						Imprime 	+= 1
						nNumLn +=40 
						
					Enddo 
					nNumLn := 2650
					fRodape(oReport,nNumLn)
					
				If nTData == 10
					SET CENTURY ON
				Else
					SET CENTURY OFF
				EndIf
			EndIf
			
			If SRA->(eof())
				exit
			EndIF
						
		EndIf
		SRA->(DbSkip())
	EndDo	
Return

Static Function fEnc(oPrint,nNumLn)
	Local ainfo := {}
	Local cDir	:= GetSrvProfString("Startpath","")
	
	Private cArquivo := "GPE140COL"	 //Nome do arquivo Bitmap que sera impresso na primeira pagina

	fSM0(@aInfo)
	oPrint:StartPage() //Inicia uma nova pagina  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TERMO DE RESCISAO DO CONTRATO DE TRABALHO                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nlin := 50
	
	oPrint:SayBitmap(nlin+30, 110, cDir + "lgrl" + FwCodEmp("SM0")+".bmp", 250, 120)
	oPrint:say (nlin+50,1000,STR0001,oFont14n) //"TERMO DE RESCISAO DO CONTRATO DE TRABALHO"
	
	////////////////////////////////////////////
	nlin += 110
	
	nlin += 60
	oPrint:Box( nlin , nColIni , nlin+180 ,nColMax ) //-- Box Identificacao da Empresa
	
	nlin += 20
	oPrint:say (nlin , nColIni+20	, STR0002, oFont09n) // "Empresa: "
	oPrint:say (nlin , 0820			, STR0003, oFont09n) //"Sucursal: "
	oPrint:say (nlin , 1520 		, STR0004, oFont09n)  // nit
	
	nlin += 50
	oPrint:say (nlin , nColIni+35 , aInfo[1], oFont09) 
	oPrint:say (nlin , 0825 , aInfo[3], oFont09) 
	oPrint:say (nlin , 1535 , aInfo[8], oFont09) 
	
	nlin += 50
	cDir := alltrim(aInfo[4]) + STR0047 + alltrim(aInfo[13]) + STR0047 + alltrim(aInfo[5]) + STR0047 +STR0048 + aInfo[7]
	oPrint:say (nlin , nColIni+35 , cDir, oFont09) 

	////////////////////////////////////////////
	nlin += 150
	oPrint:Box( nlin , nColIni , nlin+1050 ,nColMax ) //-- Box Identificacao do Trabalhador
	
	nlin +=20
	oPrint:say (nlin,nColIni+20,STR0005, oFont09n) 		 							
	oPrint:say (nlin,0820,STR0006, oFont09n)		//Nombre						   

	nlin += 50                                 
	oPrint:say (nlin,nColIni+35 ,SRA->RA_MAT , oFont07n ) 			
	oPrint:say (nlin,0820 ,SRA->RA_NOME, oFont07n )						   		

	nlin += 60
	oPrint:say (nlin,nColIni + 20, STR0007, oFont09n) // "Tipo Id: "	
	oPrint:say (nlin,0820, STR0008, oFont09n) // "No. Id: "
	
	nlin += 50
	oPrint:say (nlin,nColIni+35 ,AllTrim(fDescRCC("S022", SRA->RA_TPCIC, 1, 2, 3, 25)), oFont07n) //Imprime Tipo Id
	oPrint:say (nlin,0820, SRA->RA_CIC, oFont07n) //Imprime No. Id

	nlin += 50
	oPrint:say (nlin,nColIni + 20,STR0009, oFont09n) // Centro de Costos
	oPrint:say (nlin,0820 		 ,STR0010, oFont09n) // Departamento
	oPrint:say (nlin,1635 		 ,STR0011, oFont09n) // cARGO
	
	nlin += 50
	oPrint:say (nlin,nColIni + 35,SRA->RA_CC+" - "+Posicione("CTT",1,xFilial("CTT")+SRA->RA_CC,"CTT_DESC01"), oFont07n)	
	oPrint:say (nlin,0820 ,SRA->RA_DEPTO+" - "+Posicione("SQB",1,xFilial("SQB")+SRA->RA_DEPTO,"QB_DESCRIC"), oFont07n)
	oPrint:say (nlin,1635 ,SRA->RA_CARGO +" - "+Posicione("SQ3",1,xFilial("SQ3")+SRA->RA_CARGO,"Q3_DESCSUM"), oFont07n)

	nlin += 50
	oPrint:say (nlin,nColIni+20 ,STR0012, oFont09n)  		// Función							
	oPrint:say (nlin,0820,STR0013, oFont09n)				// Sindicato			   	
	oPrint:say (nlin,1620,STR0014, oFont09n) 				// Proceso		  	  			
	
	nlin += 50
	oPrint:say (nlin,nColIni+35 ,Posicione("SRJ",1,xFilial("SRJ")+SRA->RA_CODFUNC,"RJ_DESC"), oFont07n)				 	  					
	oPrint:say (nlin,0820 ,Posicione("RCE",1,xFilial("RCE")+SRA->RA_SINDICA,"RCE_DESCRI"), oFont07n)	 				   	   				
	oPrint:say (nlin,1635,SRA->RA_PROCES + " - " + Posicione("RCJ",1,xFilial("RCJ") + SRA->RA_PROCES,"RCJ_DESCRI") , oFont07n)	   								   
	
	nlin += 50
	oPrint:say (nlin,nColIni+20 ,STR0015, oFont09n)  		// EPS							
	oPrint:say (nlin,0820,STR0016, oFont09n)				// AFP			   	
	oPrint:say (nlin,1620,STR0017, oFont09n) 				// ARL	
	
	nlin += 50
	oPrint:say (nlin,nColIni+35 , AllTrim(SRA->RA_CODRPAT) +"-"+ Alltrim(fDescRCC("S008",SRA->RA_CODRPAT,1,17,18,80)), oFont07n)				 	  					
	oPrint:say (nlin,0820 , AllTrim(SRA->RA_CODAFP) +"-"+Alltrim(fDescRCC("S008",SRA->RA_CODAFP,1,17,18,80)), oFont07n)	 				   	   				
	oPrint:say (nlin,1635, AllTrim(SRA->RA_NITARL) +"-"+Alltrim(fDescRCC("S008",SRA->RA_NITARL,1,17,18,80)) , oFont07n)	   								   
	
	nlin += 50
	oPrint:say (nlin,nColIni+20 ,STR0018, oFont09n)  		// CCF							
	oPrint:say (nlin,0820,STR0019, oFont09n)				// oFICIO

	nlin += 50
	oPrint:say (nlin,nColIni+35,SRA->RA_CXCOMP +" - "+Alltrim(fDescRCC("S008",SRA->RA_CXCOMP,1,17,18,80)), oFont07n)    
	oPrint:say (nlin,0820 , SRA->RA_OFICIO + "-" + Alltrim(fDescRCC("S017",SRA->RA_OFICIO,1,6,7,50)), oFont07n)
	
	nlin += 50
	oPrint:say (nlin,nColIni+20 ,STR0020, oFont09n)  		// "Horas por mes: "						
	oPrint:say (nlin,0820,STR0021, oFont09n)				// "ReteFte: "			   	
	oPrint:say (nlin,1620,STR0022, oFont09n) 				// "% ReteFte: "	
	
	nlin += 50
	oPrint:say (nlin,nColIni+35 ,TRANSFORM(SRA->RA_HRSMES,"999.99"), oFont07n)  		// "Horas por mes: "						
	oPrint:say (nlin,0820, IIf(SRA->RA_TIPOPRC == '1', STR0060, STR0061), oFont07n) // "Procedimiento 1" - "Procedimiento 2"	   	
	oPrint:say (nlin,1620,TRANSFORM(SRA->RA_PERCIR,"999.99"), oFont07n) 				// "% ReteFte: "	
	
	nlin += 50
	oPrint:say (nlin,nColIni+20 ,STR0023, oFont09n)  		// "Tipo Cesantia: "					
	oPrint:say (nlin,0820,STR0024, oFont09n)				// "Tipo Salario: "			   	
	oPrint:say (nlin,1620,STR0025, oFont09n) 				// "Salario: "	
	
	nlin += 50
	oPrint:say (nlin,nColIni+35 ,SRA->RA_OPTLEI, oFont07n)  		// "Horas por mes: "						
	oPrint:say (nlin,0820,FTIPOSAL(SRA->RA_TIPOSAL), oFont07n)				// "ReteFte: "			   	
	oPrint:say (nlin,1620,TRANSFORM(SRA->RA_SALARIO,"999,999,999,999.99"), oFont07n) 				// "% ReteFte: "	
	
	nlin += 50
	oPrint:say (nlin,nColIni+20 ,STR0026, oFont09n)  		// "Tipo Cesantia: "					
	oPrint:say (nlin,0820,STR0027, oFont09n)				// "Tipo Salario: "			   	
	oPrint:say (nlin,1620,STR0028, oFont09n) 				// "Salario: "	
	nlin += 50
	oPrint:say (nlin,nColIni+35 ,DTOC(SRA->RA_ADMISSA), oFont07n)  	// "Horas por mes: "						
	oPrint:say (nlin,0820,DTOC(SRA->RA_DTREC), oFont07n)				// "ReteFte: "			   	
	oPrint:say (nlin,1620,DTOC(SRA->RA_FECAUM), oFont07n) 			// "% ReteFte: "	
	
	nlin += 50
	oPrint:say (nlin,nColIni+20 ,STR0029, oFont09n)  		// "Tipo Cesantia: "					
	oPrint:say (nlin,0820,STR0030, oFont09n)				// "Tipo Salario: "			   	
	oPrint:say (nlin,1620,STR0031, oFont09n) 				// "Salario: "	
	nlin += 50
	oPrint:say (nlin,nColIni+35 ,SRA->RA_TIPOCO +"-"+ Alltrim(fDescRCC("S018",SRA->RA_TIPOCO,1,3,4,50)), oFont07n)  		// "Horas por mes: "						
	oPrint:say (nlin,0820,DTOC(SRA->RA_DEMISSA), oFont07n)				// "ReteFte: "			   	
	oPrint:say (nlin,1620,SRA->RA_TIPFIN +"-"+ Alltrim(fDescRCC("S020",SRA->RA_TIPFIN,1,2,3,50)), oFont07n) 				// "% ReteFte: "	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Discriminacao das Verbas Rescisorias                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nlin += 170
	oPrint:Box( nlin, nColIni, nlin+970, nColMax )
	oPrint:line(nlin,0800,nlin+970,0800) 							//-- Linha Vertical Meio 
	oPrint:line(nlin,1550,nlin+970,1550)							//-- Linha Vertical Meio 
	
	nlin += 20
	oPrint:say (nlin,nColIni+20 ,oemtoansi(STR0032), oFont09n)		//-- Proventos
	oPrint:say (nlin,820 ,oemtoansi(STR0033), oFont09n)		//-- Descontos
	oPrint:say (nlin,1570,oemtoansi(STR0034), oFont09n)		//-- Bases
	
	nlin += 70
	oPrint:line(nlin,nColIni,nlin,nColMax) 						//-- Linha Horizontal Proventos/Descontos
	
	nlin += 30
	nNumLn := nLin // 970 original 570 ajusta texto pei de pagina
Return Nil


Static Function fSM0( aInfo1 )
	Local aArea				:= GetArea()
	Local aAreaSM0			:= SM0->(GetArea())
	Local cTipEnd			:= "E"
	Local lRetorno			:= .T.
	Local cFilCorrente	:= cFilAnt
	Local cEmpCorrente	:= cEmpAnt
	
    // 01 - Filial
	// 02 - Reduz Filial
	// 03 - Nome Completo
	// 04 - Endereco Cobranca
	// 05 - Cidade Cobranca
	// 06 - Estado Cobranca
	// 07 - Cep Cobranca
	// 08 - Cgc Cobranca
	// 09 - Insc Cobranca
	// 10 - Telefone
	// 11 - Fax 					Char	14
	// 12 - Producao Rural			Char	01  - "S" ou "N""
	// 13 - Bairro Cobranca 		Char	20
	// 14 - Compl. End. Cobranca	Char	12
	// 15 - Tipo de Inscricao		Num	01  -  1-CEI, 2-CGC, 3-CPF, 4-INCRA
	// 16 - CNAE					Char	05
	// 17 - FPAS					Char	04
	// 18 - Acid. de Trabalho		Char	08
	// 19 - C¢digo Municipio		Char	07
	// 20 - Natureza Juridica		Char	04
	// 21 - Data Base Pgto. RAIS	Char	02
	// 22 - N§ de Proprietarios		Char	02
	// 23 - Se Modificou Endere‡o 	Char	01  - "S" ou "N"
	// 24 - Se Modificou INSC/CGC 	Char	01  - "S" ou "N"
	// 25 - Causa da Mudan‡a		Char	01
	// 26 - INC./CGC Anterior		Char	14
	// 27 - CEI						Char	14	
	
	aInfo := Array(28)
	
	IF ( lRetorno := SM0->( dbSeek( cEmpCorrente + cFilCorrente ) ) )
		aInfo[ 01 ] := SM0->M0_FILIAL
		aInfo[ 02 ] := SM0->M0_NOME
		aInfo[ 03 ] := SM0->M0_NOMECOM

		IF ( cTipEnd == "C" )
			aInfo[ 04 ] := SM0->M0_ENDCOB
			aInfo[ 05 ] := SM0->M0_CIDCOB
			aInfo[ 06 ] := SM0->M0_ESTCOB
			aInfo[ 07 ] := SM0->M0_CEPCOB
		Else
			aInfo[ 04 ] := SM0->M0_ENDENT
			aInfo[ 05 ] := SM0->M0_CIDENT
			aInfo[ 06 ] := SM0->M0_ESTENT
			aInfo[ 07 ] := SM0->M0_CEPENT
		EndIf

		aInfo[ 08 ] := SM0->M0_CGC
		aInfo[ 09 ] := SM0->M0_INSC
		aInfo[ 10 ] := SM0->M0_TEL
		aInfo[ 11 ] := SM0->M0_FAX
		aInfo[ 12 ] := SM0->M0_PRODRUR

		IF ( cTipEnd == "C" )
			aInfo[ 13 ] := SM0->M0_BAIRCOB
			aInfo[ 14 ] := SM0->M0_COMPCOB
		Else
			aInfo[ 13 ] := SM0->M0_BAIRENT
			aInfo[ 14 ] := SM0->M0_COMPENT
		EndIf

		aInfo[ 15 ] := If( Type("SM0->M0_CEI") # "U" .And. !Empty( SM0->M0_CEI ), 1, SM0->M0_TPINSC )		
		aInfo[ 16 ] := SM0->M0_CNAE
		aInfo[ 17 ] := SM0->M0_FPAS
		aInfo[ 18 ] := SM0->M0_ACTRAB
		aInfo[ 19 ] := SM0->M0_CODMUN
		aInfo[ 20 ] := SM0->M0_NATJUR
		aInfo[ 21 ] := SM0->M0_DTBASE
		aInfo[ 22 ] := SM0->M0_NUMPROP
		aInfo[ 23 ] := SM0->M0_MODEND
		aInfo[ 24 ] := SM0->M0_MODINSC
		aInfo[ 25 ] := SM0->M0_CAUSA
		aInfo[ 26 ] := SM0->M0_INSCANT
		aInfo[ 27 ] := If( Type("SM0->M0_CEI") # "U" .And. !Empty( SM0->M0_CEI ), SM0->M0_CEI, "" )
		aInfo[ 28 ] := SM0->M0_TPINSC

	Else
		aFill( aInfo , "" )
	EndIf
	
	aInfo1	:= aClone(aInfo)
	
	
	RestArea( aAreaSM0 )
	RestArea( aArea )
Return( lRetorno )

STATIC FUNCTION FTIPOSAL(cTipoSal)
	Local cRet := ""
	Local aTpSal := {}
	dbselectarea("SX3")
	SX3->(DBSETORDER(2))
	
	IF SX3->(DBSEEK("RA_TIPOSAL"))
		aTpSal := STRTOKARR(sx3->x3_cboxspa,";")
		cRet := aTpSal[val(cTipoSal)]
	EndIf
	
RETURN CRET

Static Function fRodape(oPrint, nLinIni)

	Local aLey		:= {}
	Local i			:= 0
	Local cValext	:= ""
	Local nLinTotal	:= 0
	Local aInfo		:= {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Totais das Verbas Rescisorias ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nlin := nLinIni //2030           
	
	IF Len(aPdd) > nNumMax .or. Len(aPdv) > nNumMax .or. Len(aPdpm) > nNumMax
	
		nlin += 35 
		oPrint:say(nlin,1900, oemtoAnsi(STR0049), oFont09n ) 	//--  " Continua ... "
		
	ELSE
	
		nlin += 30 //35
		oPrint:say (nlin,nColIni , STR0050, oFont09n)											//"|30-TOTAL BRUTO"
	    oPrint:say (nlin,0450 , Transform(nProv        ,"@E 999,999,999.99"), oFont09n)
		oPrint:say (nlin,0850 , STR0051, oFont09n)											//"|TOTAL DESCONTOS "
		oPrint:say (nlin,1240 , Transform(nDesc        ,"@E 999,999,999.99"), oFont09n)	
		
		oPrint:say (nlin,1570 , STR0052, oFont09n)											//"|LIQUIDO A RECEBER "
		oPrint:say (nlin,1870 , Transform(nProv - nDesc,"@E 999,999,999.99"), oFont09n)
		
		cValext := Alltrim(Extenso(nProv - nDesc))
		nLinTotal := MlCount(cValext,100)

	Endif	                              
	nlin += 30 //50
	  
	aLey := {STR0053 + Transform(nProv - nDesc,"@E 999,999,999.99") + "  " + cValExt + "," }
	
	nlin += 20
	
	For i:=1 to len(aLey)
		oPrint:say( nlin,nColIni+20 ,aLey[i], oFont09)
		nlin += 40
	Next i
	
	fSM0(@aInfo)

	oPrint:say( nlin,nColIni+20 ,STR0042 + AllTrim(aInfo[1]) + STR0043, oFont09)
	nlin += 40
	oPrint:say( nlin,nColIni+20, IIf(!Empty(cCodMsg), AllTrim(fDescRCC("S091", cCodMsg, 1, 2, 4, 200)), ""), oFont09)
	nlin += 90
	oPrint:say( nlin,nColIni+310, STR0062, oFont09n) //"_____________________________"
	oPrint:say( nlin,1480, STR0062, oFont09n) //"_____________________________"
	
	nLin+= 50
	oPrint:say( nlin,nColIni+280,SRA->RA_NOME, oFont09n) //Nombre del empleado
	oPrint:say( nlin,1450, cNomRep, oFont09n) //Nombre del representante
	nLin+= 50
	If !Empty(SRA->RA_TPCIC) .And. !Empty(SRA->RA_CIC)
		oPrint:say( nlin,nColIni+200, STR0007 + AllTrim(fDescRCC("S022", SRA->RA_TPCIC, 1, 2, 3, 25)) + "   " + STR0008 + AllTrim(SRA->RA_CIC), oFont07n) //"Tipo Id: " - "No. Id: "
	Endif
	If !Empty(cTpIdRep) .And. !Empty(cIdRep)
		oPrint:say( nlin,1380, STR0007 + AllTrim(cTpIdRep) + "   " + STR0008 + AllTrim(cIdRep), oFont07n) //"Tipo Id: " - "No. Id: "
	EndIf
	
	nlin += 180
	oPrint:say( nlin,nColIni+100, STR0062, oFont09n) //"_____________________________"
	oPrint:say( nlin,0970, STR0062, oFont09n) //"_____________________________"
	oPrint:say( nlin,1700, STR0062, oFont09n) //"_____________________________"
	nlin += 40
	oPrint:say( nlin, 350, STR0054, oFont09n)
	oPrint:say( nlin, 1110, STR0055, oFont09n)
	oPrint:say( nlin, 1840, STR0056, oFont09n)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FIM DO RELATORIO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:EndPage()
	CONTFL:=1
	
Return 

Static Function fLoadLogo(cNomeArq)

	Local cStartPath := GetClientDir()

	If Substr(cStartPath, Len(cStartPath), 1) == "\"
		cImagem := cStartPath + cNomeArq        
	Else
		cImagem := cStartPath + "\" + cNomeArq    
	Endif

Return cImagem
