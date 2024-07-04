#INCLUDE "GPER140PAR.ch"
#Include "TBICONN.CH"
#DEFINE   nColMax	2300
#DEFINE   nLinMax  2870

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPER140PAR  ³ Autor ³ Cristian Franco         ³ Data ³ 24.02.21   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carta de Finiquito - Paraguay                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function GPER140PAR()

	Local olReport
	Local clNomProg		:= FunName()
	Local clTitulo 		:= STR0001 //"LIQUIDACION FINAL"
	Local clDesc   		:= STR0015 //"CARTA FINIQUITO PARAGUAY" 
	
	Private oFont		:= TFont():New("Courier New",09,12,.T.,.F.,5,.T.,5,.F.,.F.)
	Private oFont1		:= TFont():New("Courier New",09,13,.T.,.T.,5,.T.,5,.F.,.F.)
    Private oFont10 	:= TFont():New("Courier New",,-10,,)
    Private oPrint 
    Private nColIni	:= 100 
    
	If FindFunction("TRepInUse") .And. TRepInUse()
		Pergunte("GPER140PAR",.T.)
		olReport:=TReport():New(clNomProg,clTitulo,"GPER140PAR",{|olReport| fImp140Par(olReport)},clDesc)
		olReport:oPage:nPaperSize	:=  1 //cARTA //9 	// Impressão em papel A4
		olReport:lHeaderVisible  	:= .F. 	// Não imprime cabeçalho do protheus
		olReport:lFooterVisible  	:= .F.	// Não imprime rodapé do protheus
		olReport:lParamPage			:= .F.	// Não imprime pagina de parametros
		olReport:PrintDialog()
	Endif

Return


 
Static Function fImp140Par(oReport)

	Local i			:= 0
	Local k			:= 0
	Local cFilMat	:= ""
	Local cAcessaSRG	:= ""
	Local cAcessaSRR	:= ""
	Local cAcessaSRC	:= ""
	Local nHoras   	:= ""
	Local nOrdSRC	:= RetOrdem("SRC","RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA")
	Local cRoteir  	:= fGetCalcRot('4')	// RESCISAO
	Local ntot		:= 0
	Local nCont		:= 2
	Local Imprime	:= 1   				//LINHA DE IMPRESSAO DO RELATORIO GRAFICO 
	Local nImpr2    := 1
	Local n			:= 0
	Local 	nI			:=0
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
	Private nTot		:= 0
	Private nNumMax		:= 25				//Numero maximo de verbas impressas no Detalhe da rescisao 
	Private nImprime	:= 1 				//Variavel Auxiliar 
	Private nImpre		:= 1 
	Private CONTFL		:= 1				//CONTA PAGINA
	Private cCodMsg 	:= ""
	Private nNumLn		:=0
	Private c0075		:=0
	Private c0761		:=0
	Private c0250		:=0
	Private c0907		:=0
	
	cAcessaSRG	:= &( " { || " + ChkRH( "GPER140" , "SRG" , "2" ) + " } " )
	cAcessaSRR	:= &( " { || " + ChkRH( "GPER140" , "SRR" , "2" ) + " } " )
	cAcessaSRC	:= &( " { ||  } " )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Objetos para Impressao Grafica - Declaracao das Fontes Utilizadas.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private oFont11n,oFont14n, oFont09, oFont09n,oFont07 
	
	oFont07	:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
	oFont07n:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
	oFont09	:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
	oFont09n:= TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)     //Negrito//
	oFont12 := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)     //Negrito//
	oFont12n:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)     //Negrito//
	oFont11n:= TFont():New("Arial",11,11,,.T.,,,,.T.,.F.)     //Negrito//
	oFont14 := TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)     //Negrito//
	oFont14n:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)     //Negrito//
	Pergunte("GPER140PAR",.F.)
	MakeAdvplExpr("GPER140PAR")
	cRanProces	:= MV_PAR01
	cRoteir		:= MV_PAR02
	cMatriculas := IIF(Empty(AllTrim(MV_PAR05)),"1==1",MV_PAR05)
	cCodMsg 	:= MV_PAR06
	
	dbSelectArea("SRA")
	SRA->(DBGOTOP())
	SRA->(dbSetOrder(1))
	WHILE ! (SRA->(eof()))	
	 
	 	If ( &(cMatriculas))
		 	// Obtiene Datos
		 	//MOVIMENTA REGUA DE PROCESSAMENTO
			//IncRegua()
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
			If SRG->(dbSeek(xFilial("SRG")+SRA->RA_MAT))
	 			If SRG->RG_EFETIVA != "1"
					dDtDemi := SRG->RG_DATADEM
				EndIf						
			EndIf
	
			lSelec	:= .F.
			DbSelectArea("SRC")
			SRC->(DbSetOrder(nOrdSRC))
			SRC->(DbSeek(xFILIAL("SRC")+SRA->RA_MAT+cRanProces+cRoteir+MV_PAR03+MV_PAR04, .F.))
			If SRC->(Eof())
			  	cSvRoteir	:= cRoteir 
			  	cRoteir 	:= fGetCalcRot('A')	// Aplicacao de Rescisao
			   	DbSeek(SRA->(RA_FILIAL+RA_MAT+RA_PROCES)+cRoteir, .F.)
			   	If SRC->(Eof())
			   	   cRoteir := cSvRoteir
			   	Else
			   		lSelec	:= .T.
			   	EndIf
			Else
				lSelec	:= .T.
			EndIf
	
			nProv := nDesc := nNProv := 0.00
	
			If lSelec
				c0075 := 0
				c0761 := 0
				c0250 := 0
				c0907 := 0
				While SRC->(!Eof()) .And.	;
						(SRC->RC_FILIAL + SRC->RC_MAT + SRC->RC_PROCES + SRC->RC_ROTEIR + SRC->RC_PERIODO + SRC->RC_SEMANA) == ;
						(SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRoteir+MV_PAR03+MV_PAR04)
					//CONSISTE FILIAIS E ACESSOS
					If !(SRC->RC_FILIAL $ fValidFil()) //.Or. !Eval(cAcessaSRC))
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
						Aadd(aPdv, Str(nHoras,6,2) + " " + Substr(ObtDescDet(SRC->RC_PD,xFilial( "SRV", SRA->RA_FILIAL),20),1,20) + " " + TransForm(SRC->RC_VALOR,"99,999,999.99") )
						nProv += SRC->RC_VALOR
					ElseIf PosSrv(SRC->RC_PD,SRA->RA_FILIAL,"RV_TIPOCOD") == "2" .And. SRC->RC_PD # aCodfol[126,1] .AND. PosSrv(SRC->RC_PD,SRA->RA_FILIAL,"RV_IMPRIPD") == "1" // Desconto e Despreza Liq. da Rescisao
						Aadd(aPdd, Str(nHoras,6,2) + " " + Substr(ObtDescDet(SRC->RC_PD,xFilial( "SRV", SRA->RA_FILIAL),20),1,20) + " " + TransForm(SRC->RC_VALOR,"99,999,999.99") )
						nDesc += SRC->RC_VALOR					
					ElseIf PosSrv(SRC->RC_PD,SRA->RA_FILIAL,"RV_TIPOCOD") == "3" .AND. (PosSrv(SRC->RC_PD,SRA->RA_FILIAL,"RV_CODFOL") == "0075")
						c0075:= TransForm(SRC->RC_VALOR,"99,999,999.99") 	
					ElseIf PosSrv(SRC->RC_PD,SRA->RA_FILIAL,"RV_TIPOCOD") == "3" .AND. (PosSrv(SRC->RC_PD,SRA->RA_FILIAL,"RV_CODFOL") == "0761")
						c0761 := TransForm(SRC->RC_VALOR,"99,999,999.99") 
					ElseIf PosSrv(SRC->RC_PD,SRA->RA_FILIAL,"RV_TIPOCOD") == "3" .AND. (PosSrv(SRC->RC_PD,SRA->RA_FILIAL,"RV_CODFOL") == "0250")
						c0250 := TransForm(SRC->RC_VALOR,"99,999,999.99") 	
					ElseIf PosSrv(SRC->RC_PD,SRA->RA_FILIAL,"RV_TIPOCOD") == "3" .AND. (PosSrv(SRC->RC_PD,SRA->RA_FILIAL,"RV_CODFOL") == "0907")	
						c0907 := TransForm(SRC->RC_VALOR,"99,999,999.99") 							
					EndIf
					
					SRC->(dbSkip())
				EndDo
			EndIf
			If lSelec
				//fInfo(@aInfo,SRA->RA_FILIAL)
				cCodSaq 	:= "  "
				cImpSac 	:= " "    
				cCodR		:= " "                                        
	
				cCausa := Space(30)

	
				//IMPRIME O NUMERO DE VIAS ESPECIfICADO
				SET CENTURY OFF
					nTot 	:= Max( Len(aPdv) , Len(aPdd) )
					nTot	:= Max( nTot , Len(aPdpm) )
					
				//For nImprVias := 1 to nNumVias
					///------------------------
					// Imprimi reporte
					
					fEnc(oReport,@nNumLn)
					
					//*--------------------
					oReport:say (nNumLn,nColIni+20 ,oemtoansi(STR0013), oFont14n)		//-- HABERES
					oReport:say (nNumLn,nColIni+1870 , Transform(nProv        ,"@E 999,999,999.99"), oFont14n)
					nNumLn +=40
					While Imprime <=  nTot
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
								//Columna de Haberes
								oReport:say (nNumLn,nColIni + 080,Space(3) + PADL(Subs(aPdv[nImpre],08,20),20),oFont14) 
								oReport:say (nNumLn,nColIni + 1200,Space(1) + PADR(Subs(aPdv[nImpre],01,06),6),oFont14,,,,1)
								oReport:say (nNumLn,nColIni + 1800,Space(1) + PADR(Subs(aPdv[nImpre],29,13),13),oFont14,,,,1) 
								nImpre	+= 1
							Endif	
						Endif  
						
						Imprime 	+= 1
						nNumLn +=40 
						
					Enddo
					
					nImpre := 1
					Imprime :=1
					oReport:say (nNumLn,nColIni+20 ,oemtoansi(STR0014), oFont14n)		//-- Descontos
					oReport:say (nNumLn,nColIni+1870 , Transform(nDesc        ,"@E 999,999,999.99"), oFont14n)	
					nNumLn +=40
					While Imprime <=  nTot
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
							//-- Columna de descuentos
							If nImprime <= Len(aPdd)  
								oReport:say (nNumLn,nColIni + 080,Space(3)  + PADL(Subs(aPdd[nImprime],08,20),20) , oFont14)
								oReport:say (nNumLn,nColIni + 1200,Space(1)  + PADR(Subs(aPdd[nImprime],01,06),6)   , oFont14,,,,1)
								oReport:say (nNumLn,nColIni + 1800,Space(1)  + PADR(Subs(aPdd[nImprime],29,13),13), oFont14,,,,1)
								nImprime	++
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
	Local cDir	:= GetSrvProfString("Startpath","")//GetClientDir()
	Local cTeImss	:= ''
	Local nAux01	:= 0	
	Local dFchIn 	:=CTOD("//") 
	Local dDemissa	:=CTOD("//")
	Local cDemissa	:= " "
	Private nDiasRep  	:= 0
	Private nMesRep		:= 0
	Private nAnioRep	:= 0
	Private DIAS_ANTIG  	:= 0
	Private MESES_ANTIG		:= 0
	Private ANIOS_ANTIG		:= 0
	Private aMnemonicos :={ {"DIAS_ANTIG"}, {"MESES_ANTIG"} , {"ANIOS_ANTIG"} }
	
Private cArquivo    	:= "GPE140PAR"	//Nome do arquivo Bitmap que sera impresso na primeira pagina


	fSM0(@aInfo,SRA->RA_FILIAL)
	oPrint:StartPage() 			//Inicia uma nova pagina  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TERMO DE RESCISAO DO CONTRATO DE TRABALHO                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nlin := 50
	
	oPrint:SayBitmap(nlin+30, 110, cDir + "lgrl" + FwCodEmp("SM0")+".bmp", 250, 120)
	oPrint:say (nlin+50,1000,STR0001,oFont14n)			 	//"TERMO DE RESCISAO DO CONTRATO DE TRABALHO"
	
	////////////////////////////////////////////
	nlin += 110
	
	nlin += 60
	oPrint:Box( nlin , nColIni , nlin+180 ,nColMax ) 					 	  			 	//-- Box Identificacao da Empresa
	
	nlin += 50
	oPrint:say (nlin , nColIni+35	, STR0002, oFont14n) // "Empresa: "
	oPrint:say (nlin , 0700	, aInfo[1], oFont09)
	oPrint:say (nlin , 1250	,(GetSX3Cache("RA_CODRPAT","X3_TITSPA")), oFont14n) 
	oPrint:say (nlin , 1700	,SRA->RA_CODRPAT, oFont09) 
	
	nlin += 70
	oPrint:say (nlin , nColIni+35 , STR0004, oFont14n) //"RUC"
	oPrint:say (nlin , 0700, aInfo[8], oFont09) 
	oPrint:say (nlin , 1250 , (GetSX3Cache("RA_REGISTR","X3_TITSPA")), oFont14n) 
	oPrint:say (nlin , 1700	,SRA->RA_REGISTR, oFont09)
	
	////////////////////////////////////////////
	nlin += 150
	oPrint:Box( nlin , nColIni , nlin+1050 ,nColMax )					 	  			 	//-- Box Identificacao do Trabalhador
	
	nlin +=50
	oPrint:say (nlin,nColIni+35,(GetSX3Cache("RA_MAT","X3_TITSPA")), oFont14n) 		 							
	oPrint:say (nlin,0700,SRA->RA_MAT, oFont09)								   
	oPrint:say (nlin , 1250 , (GetSX3Cache("RA_CODFUNC ","X3_TITSPA")), oFont14n) 
	oPrint:say (nlin , 1700	,Posicione("SRJ",1,xFilial("SRJ")+SRA->RA_CODFUNC,"RJ_DESC"), oFont09)
	
	nlin += 100                               
	oPrint:say (nlin,nColIni+35 ,(GetSX3Cache("RA_NOME","X3_TITSPA")), oFont14n ) 			
	oPrint:say (nlin,0550 ,SRA->RA_NOME, oFont09 )						   		
	oPrint:say (nlin , 1250 , (GetSX3Cache("RA_CARGO ","X3_TITSPA")), oFont14n) 
	oPrint:say (nlin , 1700	,Posicione("SQ3",1,xFilial("SQ3")+SRA->RA_CARGO,"Q3_DESCSUM"), oFont09)
	

	nlin += 100
	oPrint:say (nlin,nColIni+35 ,STR0006, oFont14n)  // "Tipo ID y Num ID ""							
	oPrint:say (nlin,0700,SRA->RA_TPCIC +" "+ SRA->RA_CIC, oFont09)	
	oPrint:say (nlin , 1250 , (GetSX3Cache("RA_CC ","X3_TITSPA")), oFont14n) 
	oPrint:say (nlin , 1700	,Posicione("CTT",1,xFilial("CTT")+SRA->RA_CC,"CTT_DESC01"), oFont09)
						   							  	  		
	nlin += 100		 	  						
	oPrint:say (nlin,nColIni+35 ,(GetSX3Cache("RA_ADMISSA","X3_TITSPA")), oFont14n)  						
	oPrint:say (nlin,0700,DTOC(SRA->RA_ADMISSA), oFont09)	
	oPrint:say (nlin , 1250 , (GetSX3Cache("RA_RG ","X3_TITSPA")), oFont14n) 
	oPrint:say (nlin , 1700	,SRA->RA_RG, oFont09)
	
	nlin += 100
	dDemissa:=IIf(Empty (SRA->RA_DEMISSA),SRG->RG_DATADEM,SRA->RA_DEMISSA)
	oPrint:say (nlin,nColIni+35 ,(GetSX3Cache("RA_DEMISSA","X3_TITSPA")), oFont14n) 						
	oPrint:say (nlin,0700,DTOC(dDemissa), oFont09)	
	oPrint:say (nlin , 1250 , (GetSX3Cache("RA_DEPTO ","X3_TITSPA")), oFont14n) 
	oPrint:say (nlin , 1700	,Posicione("SQB",1,xFilial("SQB")+SRA->RA_DEPTO,"QB_DESCRIC"), oFont09)	 	  						
	
	nlin += 100
	oPrint:say (nlin,nColIni+35 ,STR0005, oFont14n)  	//"Antigüedad"
	dFchIn:= IIf(Empty (SRA->RA_DTREC),SRA->RA_ADMISSA,SRA->RA_DTREC)
	If fDias360(dFchIn,dDemissa,aMnemonicos) > 0 
		nDiasRep := DIAS_ANTIG
		nMesRep	 := MESES_ANTIG
		nAnioRep := ANIOS_ANTIG
	EndIf
	oPrint:say (nlin,+0700 ,cValToChar(nAnioRep)+STR0025+ cValToChar(nMesRep)+STR0026+ cValToChar(nDiasRep)+STR0027, oFont09) //"AÑOS, MESES, DIAS "
			
	If(SRA->RA_TEIMSS=="1")
		cTeImss= ' Supervisores'
	ElseIf (SRA->RA_TEIMSS=="2")
		cTeImss= ' Empleados'
	ElseIf	(SRA->RA_TEIMSS=="3")
		cTeImss= ' Obreros'
	ElseIf(SRA->RA_TEIMSS=="4")
		cTeImss= ' Menores'
	EndIf		
	
	oPrint:say (nlin , 1250 , (GetSX3Cache("RA_TEIMSS ","X3_TITSPA")), oFont14n) 
	oPrint:say (nlin , 1700	,cTeImss, oFont09)			 	  						
					   	   				

	nlin += 100
	oPrint:say (nlin,nColIni+35 ,(GetSX3Cache("RA_TIPOFIN","X3_TITSPA")), oFont14n)  
	nAux01:= fPosTab("S005",SRA->RA_TIPOFIN ,"=", 4)
	IF  nAux01>0
		cDemissa := fTabela("S005",nAux01,5)
	Endif							
	oPrint:say (nlin,0700,cDemissa, oFont09)		 	  	  			
	
	nlin += 100
	oPrint:say (nlin,nColIni+35 ,STR0007, oFont14n)  //"Salario Mensual en Gs."							
	oPrint:say (nlin,0700,TRANSFORM(SRA->RA_SALARIO,"999,999,999,999.99"), oFont09)	
	oPrint:say (nlin , 1250 , STR0008, oFont14n) //"Salario por día em Gs."
	oPrint:say (nlin , 1700	,TRANSFORM(SRA->RA_SALDIA,"999,999,999,999.99"), oFont09)
	
	nlin += 100
	oPrint:say (nlin,nColIni+35 ,STR0012, oFont14n)//"SBC Aguinaldo"
	If (!Empty(c0907) )
	oPrint:say (nlin,0700,cValToChar(c0907), oFont09)	
	EndIf
	oPrint:say (nlin , 1250 , STR0009, oFont14n) //"SBC Indemnización"
	If (!Empty(c0761) )
	oPrint:say (nlin,1700,cValToChar(c0761), oFont09)	
	EndIf
	nlin += 100
	oPrint:say (nlin,nColIni+35 ,STR0011, oFont14n) // "SBC Vacaciones"
	If (!Empty(c0075))
	oPrint:say (nlin,0700,cValToChar(c0075), oFont09)	
	EndIf
	oPrint:say (nlin , 1250 , STR0010, oFont14n) //"SBC Aviso Previo"
	If (!Empty(c0250 ))
	oPrint:say (nlin,1700,cValToChar(c0250), oFont09)	
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄaaÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Discriminacao das Verbas Rescisorias                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nlin += 170
	oPrint:Box( nlin, nColIni, nlin+970, nColMax )
	
	nlin += 30
	nNumLn := nLin 
Return Nil


Static Function fSM0( aInfo1 )
	Local aArea				:= GetArea()
	Local aAreaSM0			:= SM0->(GetArea())
	Local cTipEnd			:= "E"
	Local lRetorno			:= .T.
	Local cFilCorrente	:= cFilAnt
	Local cEmpCorrente	:= cEmpAnt
	
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


Static Function fRodape(oPrint, nLinIni)

	Local aLey := {}
	Local i
	Local cValext   := ""
	Local nLinTotal := 0
	Local aInfo := {}
	Local cPrisobr := ""
	Local cSecsobr := ""
	Local cPrinome := ""
	Local cSecnome := ""
	Local cTipoId  :=""
	Local cNumId   :=""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Totais das Verbas Rescisorias                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	nlin := nLinIni         
	
	
	If Len(aPdd) > nNumMax .or. Len(aPdv) > nNumMax 
	
		nlin += 35 
		oPrint:say(nlin,1900, oemtoAnsi(STR0028), oFont09n ) 	//--  " Continua ... "
		
	Else
		oPrint:Box( nlin , nColIni ,nlin+50 ,nColMax )
		oPrint:say (nlin,nColIni+20, STR0023, oFont14n)											//"TOTAL A PAGAR"
		oPrint:say (nlin,nColIni+1900, Transform(nProv - nDesc,"@E 999,999,999.99"), oFont14n)
		nlin += 35		                     
		cValext := Alltrim(Extenso(nProv - nDesc))
		nLinTotal := MlCount(cValext,100)
		
			
	Endif	                              
	nlin += 30 
	  
	aLey := { Transform(nProv - nDesc,"@E 999,999,999.99") + "  (" + cValext + ")" }
	
	nlin += 20
	fSM0(@aInfo,SRA->RA_FILIAL)
	oPrint:say( nlin,nColIni,STR0019 + AllTrim(aInfo[1]) + STR0020+AllTrim(aInfo[8])+STR0021, oFont07)
	For i:=1 to len(aLey)
		oPrint:say( nlin,nColIni+780 ,aLey[i], oFont07)
		nlin += 40
	Next i
	oPrint:say( nlin,nColIni ,STR0022, oFont07) //"en concepto de Liquidación final de haberes laborales correspondientes, conforme a detalle mostrado."
	nlin += 80
	oPrint:say( nlin,nColIni ,Alltrim(fQuery(cCodMsg)), oFont09)
	nlin += 200
	oPrint:say( nlin,600   ,"__________________________________", oFont09n)	
	oPrint:say( nlin,1250  ,"__________________________________", oFont09n)	
	
	nLin+= 50
	nAux01:=fPosTab("S006",SM0->M0_CGC,"=",6)
	If nAux01>0
	   cTipoID  := RTRIM(fTabela("S006",nAux01,9))
	   cNumID   := RTRIM(fTabela("S006",nAux01,10))
	   cPrisobr := RTRIM(fTabela("S006",nAux01,11))
	   cSecsobr := RTRIM(fTabela("S006",nAux01,12))
	   cPrinome := RTRIM(fTabela("S006",nAux01,13))
	   cSecnome := RTRIM(fTabela("S006",nAux01,14))
	EndIf	
	oPrint:say( nlin,600 ,RTRIM(cPrinome) + " "+ RTRIM(cSecnome)+ " " + RTRIM(cPrisobr)+" "+ RTRIM(cSecsobr), oFont09n)	
	oPrint:say( nlin,1250 ,RTRIM(SRA->RA_PRINOME) + " "+ RTRIM(SRA->RA_SECNOME)+ " " + RTRIM(SRA->RA_PRISOBR)+" "+ RTRIM(SRA->RA_SECSOBR), oFont09n)
	
	nlin += 50
	oPrint:say( nlin,600 ,(STR0004)+cNumId, oFont09n) //"RUC "	
	oPrint:say( nlin,1250 ,SRA->RA_TPCIC+" "+SRA->RA_CIC, oFont09n)
	nlin += 50
	oPrint:say( nlin,600 ,STR0017, oFont09n)	//"Representante Legal"
	oPrint:say( nlin,1250 ,STR0018, oFont09n)	 //"Empleado"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FIM DO RELATORIO                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:EndPage()
	CONTFL:=1
	
Return 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³DescPd 	³ Autor ³ Cristian Franco 	  ³ Data ³ 24.02.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Descricao de mensaje de tabla S001				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Static function fQuery(cCodMsg)
Local cQuery   := ''
Local cAliasRCC := GetNextAlias()
Local cConteudo := ''

cQuery  += "SELECT "
	If 	AllTrim(Upper(TCGetDB())) $ "MSSQL"
		cQuery  +=  "SUBSTRING(RCC_CONTEU,2,30) CAMPO"
	Else
		cQuery  +=  "SUBSTR(RCC_CONTEU,2,30) CAMPO"
	EndIf
cQuery  += " FROM " + RetSqlName( 'RCC' )
cQuery  += " WHERE RCC_CODIGO='S001' "
cQuery  += " AND D_E_L_E_T_=' ' "
cQuery  += " AND RCC_FILIAL = '" + xFilial("RCC") + "' "	
If !Empty(cCodMsg)		
	If 	AllTrim(Upper(TCGetDB())) $ "MSSQL"
		cQuery  += " AND  SUBSTRING(RCC_CONTEU,01,1)  = '"+cCodMsg+"' "
		cQuery  += " AND  SUBSTRING(RCC_CONTEU,32,5) = '"+MV_PAR01+"' "
		cQuery  += " AND  SUBSTRING(RCC_CONTEU,37,3) = '"+MV_PAR02+"' "
		cQuery  += " AND  SUBSTRING(RCC_CONTEU,40,6) = '"+MV_PAR03+"' "
		cQuery  += " AND  SUBSTRING(RCC_CONTEU,46,2) = '"+MV_PAR04+"' "
	Else
		cQuery  += " AND  SUBSTR(RCC_CONTEU,01,1) = '"+cCodMsg+"' "
		cQuery  += " AND  SUBSTR(RCC_CONTEU,32,5) = '"+MV_PAR01+"' "
		cQuery  += " AND  SUBSTR(RCC_CONTEU,37,3) = '"+MV_PAR02+"' "
		cQuery  += " AND  SUBSTR(RCC_CONTEU,40,6) = '"+MV_PAR03+"' "
		cQuery  += " AND  SUBSTR(RCC_CONTEU,46,2) = '"+MV_PAR04+"' "
	EndIf	
EndIf

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery), cAliasRCC, .T., .T.)
dbSelectArea( cAliasRCC)


While (cAliasRCC)->(!EOF())
	cConteudo := (cAliasRCC)->CAMPO
	(cAliasRCC)->(dbSkip())	
EndDo
(cAliasRCC)->(dbCloseArea())

return (cConteudo)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³DescPd 	³ Autor ³ Cristian Franco 	  ³ Data ³ 24.02.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Descricao do Codigo de Provento / Desconto		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
static Function ObtDescDet(cCodDesc,cFil)
	Local aSaveArea	:= GetArea()
	Local nTamConc	:= TAMSX3( "RV_COD" )[1]
	
	Local nBytes := 100
	nBytes := Min(nBytes, 100)

	dbSelectArea("SRV")
	dbSetOrder(1)
	
	If cFil != Nil .and. !(cFilial == Space(FwSizeFilial()))
		cFil := xFilial('SRV',cFil) //ajusta conforme compartilhamento da tabela SRV
	Else
		cFil := cFilial
	EndIf
	
	If MsSeek(xFilial("SRV") + SubSTR(cCodDesc,1,nTamConc)) //100 Sueldo Semanal
		cRet := SubSTR(cCodDesc,1,nTamConc) +" "+ Left(RV_DESCDET + Space(nBytes), nBytes)
	Else
		cRet := SubSTR(cCodDesc,1,nTamConc) +" "+ Left("No registrado" + Space(nBytes), nBytes)  //"** Nao Cadastrado **"
	EndIf

	RestArea(aSaveArea)
Return cRet
