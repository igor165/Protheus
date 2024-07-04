#INCLUDE  "QDOR082.CH"
#INCLUDE  "PROTHEUS.CH"
#INCLUDE  "Protheus.CH"
#INCLUDE  "Report.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDOR082   ºAutor  ³Leandro Sabino      º Data ³  27/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao de listagem para Registro de Treinamento         º±±
±±º          ³ (Versao Relatorio Personalizavel)                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                            
Function QDOR082(lTreina)
Local oReport
Private cFilFunc := xFilial("QAC")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ mv_par01	// Codigo Treinamento de                               ³
	//³ mv_par02	// Codigo Treinamento ate                              ³
	//³ mv_par03	// Ano de                                              ³
	//³ mv_par04	// Ano ate                                             ³
	//³ mv_par05	// De  Documento                                       ³
	//³ mv_par06	// Revisao                                             ³
	//³ mv_par07	// Ate Documento                                       ³
	//³ mv_par08	// Revisao                                             ³
	//³ mv_par09 	// Quebra por Departamento 							   ³
	//³ mv_par10 	// Mostrar Inativos		 							   	  	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oReport := ReportDef(lTreina)
	oReport:PrintDialog()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef()   ³ Autor ³ Leandro Sabino   ³ Data ³ 13/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montar a secao				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDef()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOR020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(lTreina)
Local cTitulo := OemToAnsi(STR0001) // "REGISTRO DE TREINAMENTO"
Local cDesc1  := OemToAnsi(STR0002) // "Este programa ira imprimir o registro de presenca a ser "
Local cDesc2  := OemToAnsi(STR0003) // "utilizado durante o treinamento, controlando a presenca "
Local cDesc3  := OemToAnsi(STR0004) // "dos participantes e instrutores."
Local oSection1 
Local oSection2 
Local oSection3      
Local nz	  := 0



DEFINE REPORT oReport NAME "QDOR082" TITLE cTitulo PARAMETER "QDR082" ACTION {|oReport| PrintReport(oReport,lTreina)} DESCRIPTION (cDesc1+cDesc2+cDesc3)
oReport:SetPortrait()


DEFINE SECTION oSection1 OF oReport TABLES "QDA" TITLE OemToAnsi(STR0023)
DEFINE CELL NAME "cTrein" OF oSection1 ALIAS "QDA" TITLE OemToAnsi(STR0008)  SIZE 20 BLOCK {||QDA->QDA_NUMERO+"/"+QDA->QDA_ANO }// "TREINAMENTO:"
DEFINE CELL NAME "cDoc"   OF oSection1 ALIAS "QDA" TITLE OemToAnsi(STR0009)  SIZE 20 BLOCK {||QDA->QDA_DOCTO } //Documento
DEFINE CELL NAME "cRev"   OF oSection1 ALIAS "QDA" TITLE OemToAnsi(STR0010)  SIZE 15 BLOCK {||QDA->QDA_RV}//Revisao

DEFINE SECTION oSection2 OF oSection1 TABLES "QD8" TITLE OemToAnsi(STR0018)
DEFINE CELL NAME "cTreinando" OF oSection2 ALIAS "  " TITLE OemToAnsi(STR0018) SIZE 40
DEFINE CELL NAME "cCargo"     OF oSection2 ALIAS "  " TITLE OemToAnsi(STR0019) SIZE 30
DEFINE CELL NAME "cDepto"     OF oSection2 ALIAS "  " TITLE OemToAnsi(STR0020) SIZE 40
DEFINE CELL NAME "cVisto"     OF oSection2 ALIAS "  " TITLE OemToAnsi(STR0021) SIZE 20

DEFINE SECTION oSection3 OF oSection2 TABLES "QDA" TITLE OemToAnsi(STR0022)
DEFINE CELL NAME "cTreinando" OF oSection3 ALIAS "  " TITLE OemToAnsi(STR0022) SIZE 90 //"Instrutor"
DEFINE CELL NAME "cCargo"     OF oSection3 ALIAS "  " TITLE OemToAnsi(STR0021) SIZE 12 //"Visto"

Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PrintReport   ³ Autor ³ Leandro Sabino   ³ Data ³ 27/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprimir os campos do relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrintReport(ExpO1)  	     	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOR020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                  
Static Function PrintReport(oReport,lTreina) 
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local oSection3 := oReport:Section(1):Section(1):Section(1)

Local cTreinamento := ""
Local cDepto	:= ""
Local cDoc      := ""
Local cAnoNum	:= ""
Local cORDER    := ""
Local lAchouQda := .T.
Local lList		:= .F.
Local nz		:= 0
Local cAlias	:= "QD8"
Local lAtivo	:= .T.
Local nContLin := 1


dbSelectArea("QDH")
dbSetOrder(1)

dbSelectArea("QDA")
dbSetOrder(1)

dbSelectArea("QD8")
dbSetOrder(1)

MakeSqlExpr(oReport:uParam)

oSection2:BeginQuery()

If	Upper(TcGetDb()) $ 'ORACLE'                          
  	 cORDER += "%1,2,3,4,5,6,7%"
Else
	 cORDER += "%QD8_FILIAL,QD8_ANO,QD8_NUMERO,QD8_FILMAT,QD8_DEPTO,QD8_CARGO,QD8_MAT%"
Endif

cAlias := GetNextAlias()

BeginSQL Alias cAlias

	SELECT QD8.QD8_FILIAL,QD8.QD8_ANO,QD8.QD8_NUMERO,QD8.QD8_FILMAT,QD8.QD8_DEPTO,QD8.QD8_CARGO,QD8.QD8_MAT,QD8.QD8_SELECA
	
	FROM %table:QD8% QD8
		
	WHERE	QD8_FILIAL = %xFilial:QD8% And 	
		    QD8_NUMERO >= %Exp:mv_par01% And QD8_NUMERO <= %Exp:mv_par02% And
		    QD8_ANO >= %Exp:mv_par03% And QD8_ANO <= %Exp:mv_par04% and 
 		    QD8.%notDel%
	 		    
	ORDER BY %Exp:cOrder%
		
EndSql
    
oSection2:EndQuery()

While !oReport:Cancel() .And. (cAlias)->(!Eof())
 
	If 	!lTreina 
		If QDA->(DbSeek(xFilial("QD8")+(cAlias)->QD8_ANO+(cAlias)->QD8_NUMERO))
			If QDA->QDA_DOCTO >= mv_par05 .And. QDA->QDA_DOCTO <= mv_par07 .And. QDA->QDA_RV >= mv_par06 .And.QDA->QDA_RV <= mv_par08
				lAchouQda := .T.

				If !Empty(AllTrim(oReport:Section(1):GetAdvplExp("QDA")))
					If !QDA->(&(oReport:Section(1):GetAdvplExp("QDA")))
						lAchouQda := .F.
					Endif
				Endif
			Else
				lAchouQda := .F.
			Endif
		Else
			lAchouQda := .F.
		Endif
	Endif

   	If (cAlias)->QD8_SELECA == "S" .And. lAchouQda
      	lList := .T.
        
        If cTreinamento <> QDA->QDA_NUMERO 
	   		cDepto:= (cAlias)->QD8_DEPTO
	        cTreinamento := QDA->QDA_NUMERO
	   		QDO082Cabec(oReport)
      	Else
	   		If 	cDepto <> (cAlias)->QD8_DEPTO .And. mv_par09 == 1 
		   		cDepto:= (cAlias)->QD8_DEPTO
			   	QDO082Cabec(oReport)
			Endif
      	Endif
       
   		If FWModeAccess("QAC")=="E"  //!Empty(xFilial("QAC"))
			cFilFunc:= (cAlias)->QD8_FILMAT
		EndIf           
        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inserindo linha em branco para melhorar³
		//³  a visualização da assinatura          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSection2:Cell("cTreinando"):SetValue(Space(1))
		oSection2:Cell("cCargo"):SetValue(Space(1))
		oSection2:Cell("cDepto"):SetValue(Space(1))
		oSection2:Cell("cVisto"):SetValue(Space(1))
		
		oSection2:PrintLine()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprimindo dados do treinando          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If nContLin == 1 
			nContLin ++
			oReport:SkipLine(3)
		EndIF
		
		If QAA->(dbSeek((cAlias)->QD8_FILMAT+(cAlias)->QD8_MAT)) .And. ;
      			 (Empty(QAA->QAA_INICIO) .Or. Dtos(QAA->QAA_INICIO) <= Dtos(dDataBase))
   
	       If lAtivo := mv_par10 == 2 .Or. ( (Empty(QAA->QAA_FIM) .And. QAA->QAA_STATUS <> '2') .Or. ;
					 	 (! Empty(QAA->QAA_FIM) .And. QAA->QAA_FIM >= dDataBase) )		
					oReport:SkipLine(1) 			
					oSection2:Cell("cTreinando"):SetValue({||Substr(QA_nUsr((cAlias)->QD8_FILMAT,(cAlias)->QD8_MAT,.t.),1,30)})
					oSection2:Cell("cCargo"):SetValue({||Substr(QA_NFUNC((cAlias)->QD8_CARGO,.T.,cFilFunc),1,20)})
					oSection2:Cell("cDepto"):SetValue({||Substr(QA_nDept((cAlias)->QD8_DEPTO,.t.,(cAlias)->QD8_FILMAT),1,25)})
					oSection2:Cell("cVisto"):SetValue({||Replicate( "_", 150 )})
				
					oSection2:PrintLine()  	 
			EndIf   
		EndIf
	EndIf
	
	cAnoNum := (cAlias)->QD8_ANO+(cAlias)->QD8_NUMERO
   	(cAlias)->(DbSkip())
   	If cAnoNum # (cAlias)->QD8_ANO+(cAlias)->QD8_NUMERO
		If lList
		   	If !Empty(QDA->QDA_MAT1) .Or. !Empty(QDA->QDA_MAT2) .Or. !Empty(QDA->QDA_MAT3)
			   	For nZ:= 1 To 3
            		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inserindo linha em branco para melhorar³
					//³  a visualização da assinatura          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		            IF lAtivo
			            If nZ==1 
			            	IF lAtivo 
								oReport:SkipLine(2)
							EndIF	
							oSection3:Finish()
							oSection3:Init()           
	   						oSection3:CELL("cTreinando"):SetValue(SPACE(1))
							oSection3:CELL("cCargo"):SetValue(SPACE(1))
							oSection3:PrintLine()						
						Endif	
					EndIF
					IF !Empty(&("QDA->QDA_MAT"+Str(nZ,1)))	
						IF lAtivo	
							oReport:SkipLine(2)
						EndIF	
   						oSection3:CELL("cTreinando"):SetValue(QA_nUsr(&("QDA->QDA_FILF"+Str(nZ,1)),&("QDA->QDA_MAT"+Str(nZ,1))))
						oSection3:CELL("cCargo"):SetValue(Replicate("_",35))
						oSection3:PrintLine()
					 Endif
			   	Next nZ			      	
		   	EndIf
		EndIf
		lList := .F.	
	Endif
EndDo

oSection1:Finish()
oSection2:Finish()
oSection3:Finish()

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDO082Cabec ºAutor  ³Leandro Sabino    º Data ³  27/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprimir as secoes 01 e 02 do relatorio de acordo com o    º±±
±±º          ³ parametro mv_par09					                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QDOR082                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                            
Function QDO082Cabec(oReport)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
	   		
oSection1:SetPageBreak(.T.) 
oSection1:Finish()
oSection1:Init()
oSection1:PrintLine()
oReport:SkipLine(1)	
       		 	    
If QDH->(DbSeek(xFilial("QDH")+QDA->QDA_DOCTO+QDA->QDA_RV))
  	oReport:SkipLine(1) 
	oReport:ThinLine()
   	If Len(AllTrim(QDH->QDH_TITULO)) > 70
 		oReport:PrintText(Substr(AllTrim(QDH->QDH_TITULO),1,50),oReport:Row(),075) 
		oReport:SkipLine(1)	
		oReport:PrintText(Substr(AllTrim(QDH->QDH_TITULO),51,50),oReport:Row(),075) 
		oReport:SkipLine(1)	
   	Else
		oReport:PrintText(AllTrim(QDH->QDH_TITULO),oReport:Row(),075) 
		oReport:SkipLine(1)	
   	EndIf
Endif

oReport:ThinLine()
oReport:SkipLine(1)	
        
oReport:PrintText(OemToAnsi(STR0011)+Space(1)+QDA->QDA_LOCAL,oReport:Row(),025)  // "LOCAL:"
oReport:SkipLine(1)	
            
oReport:PrintText( OemToAnsi(STR0012)+Space(1)+DtoC(QDA->QDA_DTINIC)+" "+(Substr(QDA->QDA_HORAI,1,2)+":"+Substr(QDA->QDA_HORAI,3,2))+" "+OemToAnsi(STR0013)+" "+DTOC(QDA->QDA_DTFIM)+" "+(Substr(QDA->QDA_HORAF,1,2)+":"+Substr(QDA->QDA_HORAF,3,2)),oReport:Row(),025) // Periodo de
oReport:SkipLine(1)	

If !Empty(QDA->QDA_OBS)
	If Len(AllTrim(QDA->QDA_OBS)) > 65
		oReport:PrintText(OemToAnsi(STR0017)+Space(1)+Substr(AllTrim(QDA->QDA_OBS),1,65),oReport:Row(),025) // "OBSERVACAO:"
		oReport:SkipLine(1)	

		oReport:PrintText(Substr(AllTrim(QDA->QDA_OBS),66,65),oReport:Row(),025) 
		oReport:SkipLine(1)	

		If Len(AllTrim(QDA->QDA_OBS)) > 130				
			oReport:PrintText(Substr(AllTrim(QDA->QDA_OBS),131,65),oReport:Row(),025) 
			oReport:SkipLine(1)	
		EndIf
	Else
        oReport:PrintText(OemToAnsi(STR0017)+Space(1)+QDA->QDA_OBS,oReport:Row(),025)// "OBSERVACAO:" 
		oReport:SkipLine(1)	
	EndIf
Endif	

oSection2:Finish()
oSection2:Init()

Return ()
