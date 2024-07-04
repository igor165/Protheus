#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FILEIO.CH"
/*
*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³  AUDINC328() ³ Autor ³ Lucas    ³ Data ³03/08/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna um array com Informações Complementares de Exportação, considerando            ³±±
±±³          ³       o lay-out do registro C328.                                                                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AUDINC328(dDataIni,dDataFim)    	  			                   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA1 := Array com as informações            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ FISCAL                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function AUDINC328(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,cLoja)
Local aInfExport := {}
Local cEstado := "EX"
Local cCFO := "499"

#IFDEF TOP
	AudinC328Top(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,cLoja,@aInfExport,cEstado,cCFO)
#ELSE
	AudinC328Cdx(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,cLoja,@aInfExport,cEstado,cCFO)
#ENDIF
Return( aInfExport )                   

/*
*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³  AUDINC330() ³ Autor ³ Lucas    ³ Data ³03/08/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna um array com Informações da Declaração  de Importação, considerando            ³±±
±±³          ³       o lay-out do registro C330.                                                                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AUDINC330(dDataIni,dDataFim)    	  			                   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA1 := Array com as informações            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ FISCAL                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function AUDINC330(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,cLoja)
Local aInfImport := {} 
Local cEstado := "EX"
Local cCFO := "500"

#IFDEF TOP
	AudinC330Top(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,cLoja,@aInfImport,cEstado,cCFO)
#ELSE
	AudinC330Cdx(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,cLoja,@aInfImport,cEstado,cCFO)
#ENDIF

Return( aInfImport )                   


/*
*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³  AUDINC335() ³ Autor ³ Lucas    ³ Data ³03/08/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna um array com Informações das Adiçôes das Declaracoes de Importação        ³±±
±±³          ³       considreando o lay-out do registro C335.                                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AUDINC335(dDataIni,dDataFim)    	  			                   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA1 := Array com as informações            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ FISCAL                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function AUDINC335(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,cLoja)
Local aInfAdicoes := {}
Local cEstado := "EX"
Local cCFO := "500"
Local cTipo := "A"	//Acrescimo

#IFDEF TOP
	AudinC335Top(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,cLoja,cTipo,@aInfAdicoes,cEstado,cCFO)
#ELSE
	AudinC335Cdx(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,cLoja,cTipo,@aInfAdicoes,cEstado,cCFO)
#ENDIF

Return( aInfAdicoes )                   


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³  AudinC328Top³ Autor ³ Marcos Alves      ³ Data ³08/08/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna um array com Informacoes Complementares de		  ³±±
±±³          ³ Exportação, considerandoo lay-out do registro C328.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AUDINC328(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,cLoja)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA1 := Array com as informações   				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FISCAL                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function AudinC328Top(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,cLoja,aInfExport,cEstado,cCFO)
Local aArea := GetArea()
Local aAreaSF3 := SF3->(GetArea())
Local cQuery := ""  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Verifica a existencia do arquivos temporario da Query.											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
If Select("RPTEEC") > 0
	RPTEEC->(DbCloseArea())
EndIf  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Montar Query.   																																 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		    
cQuery := "SELECT F3_ENTRADA, F3_NFISCAL, EE9_RE, EE9_DTRE, EEC_DTPROC, EES_QTDE, EEC_MOEDA, "
cQuery += "YF_DESC_SI, YE_TX_COMP, YE_VLFISCA, F3_VALICM + F3_VALIPI IMPOSTOS, F3_ISENIPI + F3_OUTRIPI CREDIPI, EEC_IMPORT "
cQuery += "  FROM " 
cQuery += RetSqlName("SF3") + " SF3, " 
cQuery += RetSqlName("SF2") + " SF2, "
cQuery += RetSqlName("EES") + " EES, "
cQuery += RetSqlName("EEC") + " EEC, "
cQuery += RetSqlName("SYF") + " SYF, "
cQuery += RetSqlName("SYE") + " SYE, "
cQuery += RetSqlName("EE9") + " EE9 "
cQuery += "WHERE "
cQuery += "SF3.F3_FILIAL = '" + xFilial("SF3") + "' "
cQuery += "  AND SF3.F3_CFO > '" + cCFO + "' "  
cQuery += "  AND   SF3.F3_ESTADO = '" + cEstado + "' "   
cQuery += "  AND   SF3.F3_ENTRADA Between  '" + DtoS(dDataIni) + "' And '" + DtoS(dDataFim) + "' " 
cQuery += "  AND   SF3.F3_NFISCAL = '" + cNFiscal + "' "  
cQuery += "  AND   SF3.F3_SERIE = '" + cSerie + "' "
cQuery += "  AND   SF3.F3_CLIEFOR = '" + cFornece + "' "
cQuery += "  AND   SF3.F3_LOJA = '" + cLoja + "' "
cQuery += "  AND   SF3.F3_NFISCAL = SF2.F2_DOC " 
cQuery += "  AND   SF3.F3_SERIE = SF2.F2_SERIE " 
cQuery += "  AND   SF2.F2_FILIAL = '" + xFilial("SF2") + "' "
cQuery += "  AND   SF2.F2_DOC = EES.EES_NRNF " 
cQuery += "  AND   SF2.F2_SERIE = EES.EES_SERIE " 
cQuery += "  AND   EES.EES_FILIAL = '" + xFilial("EES") + "' "
cQuery += "  AND   EES.EES_PREEMB = EEC.EEC_PREEMB " 
cQuery += "  AND   EEC.EEC_MOEDA = SYF.YF_MOEDA " 
cQuery += "  AND   EEC.EEC_MOEDA = SYE.YE_MOEDA " 
cQuery += "  AND   EEC.EEC_FILIAL = '" + xFilial("EEC") + "' "
cQuery += "  AND   SYF.YF_FILIAL = '" + xFilial("SYF") + "' "
cQuery += "  AND   SYE.YE_FILIAL = '" + xFilial("SYE") + "' "
cQuery += "  AND   EEC.EEC_DTPROC = SYE.YE_DATA " 
cQuery += "  AND   EEC.EEC_PREEMB = EE9.EE9_PREEMB " 
cQuery += "  AND   EE9.EE9_FILIAL = '" + xFilial("EE9") + "' "
cQuery += "  ORDER BY F3_ENTRADA, F3_NFISCAL " 

cQuery := ChangeQuery(cQuery)                                

dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'RPTEEC', .F., .T.)

TcSetField("RPTEEC","F3_ENTRADA","D",08,0)
TcSetField("RPTEEC","F3_NFISCAL" ,"C",TamSX3("F3_NFISCAL")[1],0)
TcSetField("RPTEEC","EE9_RE" ,"C",TamSX3("EE9_RE")[1],0)
TcSetField("RPTEEC","EE9_DTRE" ,"D",TamSX3("EE9_DTRE")[1],0)
TcSetField("RPTEEC","EEC_DTPROC" ,"D",TamSX3("EEC_DTPROC")[1],0)
TcSetField("RPTEEC","EES_QTDE" ,"N",TamSX3("EES_QTDE")[1],TamSX3("EES_QTDE")[2])
TcSetField("RPTEEC","EEC_MOEDA" ,"C",TamSX3("EEC_MOEDA")[1],0)
TcSetField("RPTEEC","YF_DESC_SI" ,"C",TamSX3("YF_DESC_SI")[1],0)
TcSetField("RPTEEC","YE_TX_COMP" ,"N",TamSX3("YE_TX_COMP")[1],TamSX3("YE_TX_COMP")[2])
TcSetField("RPTEEC","YE_VLFISCA" ,"N",TamSX3("YE_VLFISCA")[1],TamSX3("YE_VLFISCA")[2])
TcSetField("RPTEEC","IMPOSTOS" ,"N",TamSX3("F3_VALICM")[1],TamSX3("F3_VALICM")[2])
TcSetField("RPTEEC","CREDIPI" ,"N",TamSX3("F3_VALIPI")[1],TamSX3("F3_VALIPI")[2])
TcSetField("RPTEEC","EEC_IMPORT" ,"C",TamSX3("EEC_IMPORT")[1],0)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento dos registros para incremento no Array				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RPTEEC->(DbGoTop())

While !RPTEEC->(EOF())    
  
		AADD(aInfExport,{RPTEEC->EE9_RE,;    
  					  				RPTEEC->EE9_DTRE,; 
  					  				RPTEEC->EEC_DTPROC,;
					  				RPTEEC->EES_QTDE,;
					  				RPTEEC->EEC_MOEDA,;
					  				RPTEEC->YF_DESC_SI,;
					  				RPTEEC->YE_TX_COMP,;
					  				RPTEEC->YE_VLFISCA,;
					  				RPTEEC->IMPOSTOS,;
					  				RPTEEC->CREDIPI,;
							  	    RPTEEC->EEC_IMPORT})								  		  
 	
	RPTEEC->(DbSkip())
 
End 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Fechar o arquivo TMP da Query.																								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
If Select("RPTEEC") > 0
	RPTEEC->(DbCloseArea())
EndIf  
RestArea(aAreaSF3)
RestArea(aArea)

Return(NIL)                   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³  AudinC328Cdx³ Autor ³ Marcos Alves      ³ Data ³08/08/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna um array com Informacoes Complementares de		  ³±±
±±³          ³ Exportação, considerandoo lay-out do registro C328.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AudinC328Cdx(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,   ³±±
±±³          ³ cLoja,aInfExport,cEstado,cCFO)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA1 := Array com as informações   				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FISCAL                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function AudinC328Cdx(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,cLoja,aInfExport,cEstado,cCFO)
Local aArea		:= GetArea()
Local aAreaSF3 	:= SF3->(GetArea())

dbSelectArea("SF3") //LIVROS FISCAIS                
dbSetOrder(6) 		//F3_FILIAL+F3_NFISCAL+F3_SERIE
If dbSeek(xFilial("SF3")+cNFiscal+cSerie)
	While !SF3->(Eof())							.And.;
		SF3->F3_FILIAL==xFilial("SF3")			.And.;		
		SF3->F3_NFISCAL==cNFiscal				.And.;
		SF3->F3_SERIE==cSerie		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Filtar CFO e Estado (Esta filtrando na query) 	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If !(Val(SF3->F3_CFO) > Val(cCFO)			.And.;
			SF3->F3_ESTADO == cEstado				.And.;
			DTOS(SF3->F3_ENTRADA)>=DtoS(dDataIni)	.And.;
			DTOS(SF3->F3_ENTRADA)<=DtoS(dDataFim)	.And.;
			SF3->F3_CLIEFOR==cFornece				.And.;
			SF3->F3_LOJA==cLoja)		   
		   
			SF3->(dbSkip())
			Loop
		EndIf
	
		dbSelectArea("SF2") //CABECALHO DAS NF'S DE SAIDA   
		dbSetOrder(1) 		//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
		If dbSeek(xFilial("SF2")+SF3->F3_NFISCAL+SF3->F3_SERIE)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  (Pesquisar Preemb, nao existe na chave) EES_FILIAL+EES_PREEMB+EES_NRNF	???? 									   	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			dbSelectArea("EES") 	//NOTAS FISCAIS (POR ITENS)     
			dbSetOrder(1)		 	//EES_FILIAL+EES_PREEMB+EES_NRNF
	        EES->(dbGotop())
			While 	!EES->(Eof())
				If	!(AllTrim(SF2->F2_DOC) == AllTrim(EES->EES_NRNF) .And. AllTrim(SF2->F2_SERIE) == AllTrim(EES->EES_SERIE))
					EES->(dbSkip())
					Loop
				EndIf
				dbSelectArea("EEC") //EMBARQUE                      
				dbSetOrder(1) 		//EEC_FILIAL+EEC_PREEMB
				If dbSeek(xFilial("EEC")+EES->EES_PREEMB)
					dbSelectArea("SYF") //MOEDAS                        
					SYF->(dbSetOrder(1)) 		//YF_FILIAL+YF_MOEDA
					SYF->(dbSeek(xFilial("SYF")+EEC->EEC_MOEDA))
					
					dbSelectArea("SYE") //TAXAS DE CONVERSAO            
					SYE->(dbSetOrder(2)) 		//YE_FILIAL+YE_MOEDA+DTOS(YE_DATA)
					SYE->(dbSeek(xFilial("SYE")+EEC->EEC_MOEDA+DTOS(EEC->EEC_DTPROC)))
				
					dbSelectArea("EE9") 	//ITENS EMBARQUE                
					EE9->(dbSetOrder(2))		 	//EE9_FILIAL+EE9_PREEMB+EE9_PEDIDO+EE9_SEQUEN
					EE9->(dbSeek(xFilial("EE9")+EEC->EEC_PREEMB))
	
					AADD(aInfExport,{EE9->EE9_RE,;    
				  					EE9->EE9_DTRE,; 
				  					EEC->EEC_DTPROC,;
									EES->EES_QTDE,;
									EEC->EEC_MOEDA,;
									SYF->YF_DESC_SI,;
									SYE->YE_TX_COMP,;
									SYE->YE_VLFISCA,;
									SF3->F3_VALICM,;
									SF3->F3_VALIPI,;
									EEC->EEC_IMPORT})								  		  
				
				EndIf
				Exit
			End								
	    EndIf
		SF3->(dbSkip())
	End		
EndIf			
RestArea(aAreaSF3)
RestArea(aArea)

Return(NIL)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³  AudinC330Top³ Autor ³ Tiago Bandeira    ³ Data ³09/08/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna um array com Informacoes Complementares de		  ³±±
±±³          ³ Exportação, considerandoo lay-out do registro C328.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AUDINC330(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,cLoja)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA1 := Array com as informações   				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FISCAL                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function AudinC330Top(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,cLoja,aInfImport,cEstado,cCFO)
Local aArea := GetArea()
Local aAreaSF3 := SF3->(GetArea())
Local cQuery := ""  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Verifica a existencia do arquivos temporario da Query.											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
If Select("RPTEIC") > 0
	RPTEIC->(DbCloseArea())
EndIf  
   				    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Montar Query.   																																 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		    

cQuery := "SELECT F3_ENTRADA, F3_NFISCAL, W6_DI_NUM, W6_DTREG_D, W6_DT_DESE, "
cQuery += " (SELECT SUM(WN_CIF) FROM " + RetSqlName("SWN") + " SWN " + " WHERE SWN.WN_DOC = SF1.F1_DOC AND SF1.F1_SERIE = SWN.WN_SERIE) VALORCIF, "
cQuery += "	(SELECT SUM(WN_VLRPIS) FROM " + RetSqlName("SWN") + " SWN " + " WHERE SWN.WN_DOC = SF1.F1_DOC AND SF1.F1_SERIE = SWN.WN_SERIE) VALORPIS, "
cQuery += "	(SELECT SUM(WN_VLRCOF) FROM " + RetSqlName("SWN") + " SWN " + " WHERE SWN.WN_DOC = SF1.F1_DOC AND SF1.F1_SERIE = SWN.WN_SERIE) VALORCOF, "
cQuery += "	(SELECT SUM(WN_OUT_DES) FROM " + RetSqlName("SWN") + " SWN " + "  WHERE SWN.WN_DOC = SF1.F1_DOC AND SF1.F1_SERIE = SWN.WN_SERIE) OUTDESP, "
cQuery += "	(SELECT SUM(WN_DESPESA) FROM " + RetSqlName("SWN") + " SWN " + "  WHERE SWN.WN_DOC = SF1.F1_DOC AND SF1.F1_SERIE = SWN.WN_SERIE) DESPESA, "
cQuery += "	(SELECT 0 FROM " + RetSqlName("SWN") + " SWN " + " WHERE SWN.WN_DOC = SF1.F1_DOC AND SF1.F1_SERIE = SWN.WN_SERIE) VALORIOF, "
cQuery += "	(SELECT SUM(WN_IIVAL) FROM " + RetSqlName("SWN") + " SWN " + " WHERE SWN.WN_DOC = SF1.F1_DOC AND SF1.F1_SERIE = SWN.WN_SERIE) VALORII, "
cQuery += "	(SELECT SUM(WN_IPIBASE) FROM " + RetSqlName("SWN") + " SWN " + " WHERE SWN.WN_DOC = SF1.F1_DOC AND SF1.F1_SERIE = SWN.WN_SERIE) BASEIPI, "
cQuery += "	(SELECT SUM(WN_VALIPI) FROM " + RetSqlName("SWN") + " SWN " + " WHERE SWN.WN_DOC = SF1.F1_DOC AND SF1.F1_SERIE = SWN.WN_SERIE) VALORIPI, "
cQuery += "	(SELECT SUM(WN_BASEICM) FROM " + RetSqlName("SWN") + " SWN " + " WHERE SWN.WN_DOC = SF1.F1_DOC AND SF1.F1_SERIE = SWN.WN_SERIE) BASEICM, "
cQuery += "	(SELECT SUM(WN_VALICM) FROM " + RetSqlName("SWN") + " SWN " + " WHERE SWN.WN_DOC = SF1.F1_DOC AND SF1.F1_SERIE = SWN.WN_SERIE) VALORICM, "
cQuery += "  F1_FORNECE "
cQuery += " FROM "
cQuery += RetSqlName("SF3") + " SF3, " 
cQuery += RetSqlName("SF1") + " SF1, "
cQuery += RetSqlName("SW6") + " SW6 "
cQuery += "WHERE "
cQuery += "SF3.F3_FILIAL = '" + xFilial("SF3") + "' "
cQuery += "  AND SF3.F3_CFO < '" + cCFO + "' "  
cQuery += "  AND   SF3.F3_ESTADO = '" + cEstado + "' "   
cQuery += "  AND   SF3.F3_ENTRADA Between  '" + DtoS(dDataIni) + "' And '" + DtoS(dDataFim) + "' "
cQuery += "  AND   SF3.F3_NFISCAL = '" + cNFiscal + "' "  
cQuery += "  AND   SF3.F3_SERIE = '" + cSerie + "' "
cQuery += "  AND   SF3.F3_CLIEFOR = '" + cFornece + "' "
cQuery += "  AND   SF3.F3_LOJA = '" + cLoja + "' "
cQuery += "  AND   SF3.F3_NFISCAL = SF1.F1_DOC " 
cQuery += "  AND   SF3.F3_SERIE = SF1.F1_SERIE " 
cQuery += "  AND   SF1.F1_FILIAL = '" + xFilial("SF1") + "' "
cQuery += "  AND   SF1.F1_HAWB = SW6.W6_HAWB "
cQuery += "  AND   SW6.W6_FILIAL = '" + xFilial("SW6") + "' "
cQuery += "  ORDER BY F3_ENTRADA, F3_NFISCAL " 

cQuery := ChangeQuery(cQuery)                                

dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'RPTEIC', .F., .T.)

TcSetField("RPTEIC","F3_ENTRADA","D",08,0)
TcSetField("RPTEIC","F3_NFISCAL" ,"C",TamSX3("F3_NFISCAL")[1],0)
TcSetField("RPTEIC","W6_DI_NUM" ,"C",TamSX3("W6_DI_NUM")[1],0)
TcSetField("RPTEIC","W6_DTREG_D" ,"D",TamSX3("W6_DTREG_D")[1],0)
TcSetField("RPTEIC","W6_DT_DESE" ,"D",TamSX3("W6_DT_DESE")[1],0)
TcSetField("RPTEIC","VALORCIF" ,"N",TamSX3("WN_CIF")[1],TamSX3("WN_CIF")[2])
TcSetField("RPTEIC","VALORPIS" ,"N",TamSX3("WN_VLRPIS")[1],TamSX3("WN_VLRPIS")[2])
TcSetField("RPTEIC","VALORCOF" ,"N",TamSX3("WN_VLRCOF")[1],TamSX3("WN_VLRCOF")[2])
TcSetField("RPTEIC","OUTDESP" ,"N",TamSX3("WN_OUT_DES")[1],TamSX3("WN_OUT_DES")[2])
TcSetField("RPTEIC","DESPESA" ,"N",TamSX3("WN_DESPESA")[1],TamSX3("WN_DESPESA")[2])
TcSetField("RPTEIC","VALORIOF" ,"N",TamSX3("WN_VLRCOF")[1],TamSX3("WN_VLRCOF")[2])
TcSetField("RPTEIC","VALORII" ,"N",TamSX3("WN_IIVAL")[1],TamSX3("WN_IIVAL")[2])
TcSetField("RPTEIC","BASEIPI" ,"N",TamSX3("WN_IPIBASE")[1],TamSX3("WN_IPIBASE")[2])
TcSetField("RPTEIC","VALORIPI" ,"N",TamSX3("WN_VALIPI")[1],TamSX3("WN_VALIPI")[2])
TcSetField("RPTEIC","BASEICM" ,"N",TamSX3("WN_BASEICM")[1],TamSX3("WN_BASEICM")[2])
TcSetField("RPTEIC","VALORICM" ,"N",TamSX3("WN_VALICM")[1],TamSX3("WN_VALICM")[2])
TcSetField("RPTEIC","F1_FORNECE" ,"C",TamSX3("F1_FORNECE")[1],0)
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento dos registros para incremento no Array				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RPTEIC->(DbGoTop())

While !RPTEIC->(EOF())    
  
		AADD(aInfImport,{RPTEIC->W6_DI_NUM,;    
  					  				RPTEIC->W6_DTREG_D,; 
  					  				RPTEIC->W6_DT_DESE,;
					  				RPTEIC->VALORCIF,;
					  				RPTEIC->VALORPIS,;
					  				RPTEIC->VALORCOF,;
					  				RPTEIC->OUTDESP,;
					  				RPTEIC->DESPESA,;
					  				RPTEIC->VALORIOF,;
					  				RPTEIC->VALORII,;
					  				RPTEIC->BASEIPI,;
					  				RPTEIC->VALORIPI,;
					  				RPTEIC->BASEICM,;
					  				RPTEIC->VALORICM,;
					  				RPTEIC->F1_FORNECE})								  		  
 	
	RPTEIC->(DbSkip())
 
End 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Fechar o arquivo TMP da Query.																								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
If Select("RPTEIC") > 0
	RPTEIC->(DbCloseArea())
EndIf  
RestArea(aAreaSF3)
RestArea(aArea)

Return(NIL)                   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³AudinC330Cdx  ³ Autor ³ Tiago Bandeira    ³ Data ³09/08/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna um array com Informacoes Complementares de		  ³±±
±±³          ³ Exportação, considerandoo lay-out do registro C328.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AudinC330Cdx(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,   ³±±
±±³          ³ cLoja,aInfExport,cEstado,cCFO)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA1 := Array com as informações   				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FISCAL                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function AudinC330Cdx(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,cLoja,aInfImport,cEstado,cCFO)
Local aArea		:= GetArea()
Local aAreaSF3 	:= SF3->(GetArea())
Local aAreaSF1 	:= SF1->(GetArea())
Local aAreaSW6 	:= SW6->(GetArea())
Local aAreaSWN 	:= SWN->(GetArea())
Local nValorCIF	:= 0
Local nValorPIS	:= 0
Local nValorCOF	:= 0
Local nOutDesp	:= 0
Local nDespesa	:= 0
Local nValorIOF	:= 0
Local nValorRII	:= 0
Local nBaseIPI	:= 0
Local nValorIPI	:= 0  
Local nBaseICM	:= 0
Local nValorICM	:= 0


dbSelectArea("SF3") //LIVROS FISCAIS                
dbSetOrder(6) 		//F3_FILIAL+F3_NFISCAL+F3_SERIE
If dbSeek(xFilial("SF3")+cNFiscal+cSerie)
	While !SF3->(Eof())							.And.;
		SF3->F3_FILIAL==xFilial("SF3")			.And.;		
		SF3->F3_NFISCAL==cNFiscal				.And.;
		SF3->F3_SERIE==cSerie		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Filtar CFO e Estado (Esta filtrando na query) 	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If !(SF3->F3_CFO < cCFO						.And.;
			SF3->F3_ESTADO == cEstado				.And.;
			DTOS(SF3->F3_ENTRADA)>=DtoS(dDataIni)	.And.;
			DTOS(SF3->F3_ENTRADA)<=DtoS(dDataFim)	.And.;
			SF3->F3_CLIEFOR==cFornece				.And.;
			SF3->F3_LOJA==cLoja)		   
		   
			SF3->(dbSkip())
			Loop
		EndIf

		dbSelectArea("SF1") //CABECALHO DAS NF'S DE ENTRADA
		dbSetOrder(1) 		//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		If dbSeek(xFilial("SF1")+SF3->F3_NFISCAL+SF3->F3_SERIE)
		     
			While !SF1->(Eof()) .And. (SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE == xFilial("SF1")+SF3->F3_NFISCAL+SF3->F3_SERIE)
			
				dbSelectArea("SW6") 	//D.I. (Capa)     
				dbSetOrder(1)		 	//SW6_FILIAL+SW6_HAWB	        
		        If dbSeek(xFilial("SW6")+SF1->F1_HAWB)
		        
			        dbSelectArea("SWN") 	//ITENS DA NFE DE IMPORTACAO 
					dbSetOrder(1)		 	//WN_FILIAL+WN_DOC+WN_SERIE+WN_TEC+WN_EX_NCM+WN_EX_NBM		        
			        If dbSeek(xFilial("SWN")+SF1->F1_DOC+SF1->F1_SERIE)
			            
			        	nValorCIF	:= 0
						nValorPIS	:= 0
						nValorCOF	:= 0
						nOutDesp	:= 0
						nDespesa	:= 0
						nValorRII	:= 0
						nBaseIPI	:= 0
						nValorIPI	:= 0  
						nBaseICM	:= 0
						nValorICM	:= 0
						
						While !SWN->(Eof()) .And. (SWN->WN_FILIAL+SWN->WN_DOC+SWN->WN_SERIE == xFilial("SWN")+SF1->F1_DOC+SF1->F1_SERIE)
							
							nValorCIF	+= SWN->WN_CIF
							nValorPIS	+= SWN->WN_VLRPIS
							nValorCOF	+= SWN->WN_VLRCOF
							nOutDesp	+= SWN->WN_OUT_DES
							nDespesa	+= SWN->WN_DESPESA
							nValorRII	+= SWN->WN_IIVAL
							nBaseIPI	+= SWN->WN_IPIBASE
							nValorIPI	+= SWN->WN_VALIPI  
							nBaseICM	+= SWN->WN_BASEICM
							nValorICM	+= SWN->WN_VALICM								
							
							SWN->(dbSkip())
						EndDo				
						
						aAdd(aInfImport,{	SW6->W6_DI_NUM,;    
		  					  				SW6->W6_DTREG_D,; 
		  					  				SW6->W6_DT_DESE,;		  					  				
		  					  				nValorCIF,;
											nValorPIS,;
											nValorCOF,;
											nOutDesp,;
											nDespesa,;
											nValorIOF,;
											nValorRII,;
											nBaseIPI,;
											nValorIPI,;
											nBaseICM,;
											nValorICM,;
							  				SF1->F1_FORNECE})								  		  
					
					EndIf
				EndIf				
				SF1->(dbSkip())								
			EndDo								
	    EndIf
		SF3->(dbSkip())
	EndDo		
EndIf

RestArea(aAreaSWN)
RestArea(aAreaSW6)
RestArea(aAreaSF1)
RestArea(aAreaSF3)
RestArea(aArea)

Return(NIL)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³  AudinC335Top³ Autor ³ Tiago Bandeira    ³ Data ³09/08/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna um array com Informacoes Complementares de		  ³±±
±±³          ³ Exportação, considerandoo lay-out do registro C328.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AUDINC335(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,cLoja)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA1 := Array com as informações   				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FISCAL                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function AudinC335Top(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,cLoja,cTipo,aInfAdicoes,cEstado,cCFO)
Local aArea := GetArea()
Local cQuery := ""  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Verifica a existencia do arquivos temporario da Query.											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
If Select("RPTEIU") > 0
	RPTEIU->(DbCloseArea())
EndIf  
   				    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Montar Query.   																																 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		    

cQuery := " SELECT F3_ENTRADA, F3_NFISCAL, W6_DI_NUM, EIU_ADICAO, EIU_CODIGO, W7_FABR, EIU_VALOR "
cQuery += " FROM "
cQuery += RetSqlName("SF3") + " SF3, " 
cQuery += RetSqlName("SF1") + " SF1, "
cQuery += RetSqlName("SW6") + " SW6,"
cQuery += RetSqlName("SW7") + " SW7, "
cQuery += RetSqlName("SWN") + " SWN, "
cQuery += RetSqlName("EIU") + " EIU "
cQuery += "WHERE "
cQuery += "SF3.F3_FILIAL = '" + xFilial("SF3") + "' "
cQuery += "  AND SF3.F3_CFO < '" + cCFO + "' "  
cQuery += "  AND   SF3.F3_ESTADO = '" + cEstado + "' "   
cQuery += "  AND   SF3.F3_ENTRADA Between  '" + DtoS(dDataIni) + "' And '" + DtoS(dDataFim) + "' "
cQuery += "  AND   SF3.F3_NFISCAL = '" + cNFiscal + "' "  
cQuery += "  AND   SF3.F3_SERIE = '" + cSerie + "' "
cQuery += "  AND   SF3.F3_CLIEFOR = '" + cFornece + "' "
cQuery += "  AND   SF3.F3_LOJA = '" + cLoja + "' "
cQuery += "  AND   SF3.F3_NFISCAL = SF1.F1_DOC " 
cQuery += "  AND   SF3.F3_SERIE = SF1.F1_SERIE "
cQuery += "  AND   SF1.F1_HAWB = SW6.W6_HAWB "
cQuery += "	AND   SW6.W6_FILIAL = '" + xFilial("SW6") + "' "
cQuery += "  AND   SWN.WN_HAWB = SF1.F1_HAWB "
cQuery += "  AND   SWN.WN_DOC = SF1.F1_DOC "
cQuery += "  AND   SWN.WN_SERIE = SF1.F1_SERIE "
cQuery += "  AND   SWN.WN_HAWB = SW7.W7_HAWB "
cQuery += "  AND   SWN.WN_SI_NUM = SW7.W7_SI_NUM "
cQuery += "  AND   SWN.WN_CC = SW7.W7_CC "
cQuery += "  AND   SWN.WN_FILIAL = '" + xFilial("SWN") + "' "
cQuery += "  AND   SW7.W7_FILIAL = '" + xFilial("SW7") + "' "
cQuery += "  AND   SWN.WN_ADICAO = EIU_ADICAO "
cQuery += "  AND   SWN.WN_HAWB = EIU.EIU_HAWB "
cQuery += "  AND   EIU.EIU_FILIAL = '" + xFilial("EIU") + "' "
cQuery += "  AND   EIU.EIU_TIPO <> '" + cTipo + "' "   
cQuery += "  AND   EIU.EIU_TIPONF = SF1.F1_TIPO_NF

cQuery := ChangeQuery(cQuery)                                

dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'RPTEIU', .F., .T.)

TcSetField("RPTEIU","F3_ENTRADA","D",08,0)
TcSetField("RPTEIU","F3_NFISCAL" ,"C",TamSX3("F3_NFISCAL")[1],0)
TcSetField("RPTEIU","W6_DI_NUM" ,"C",TamSX3("W6_DI_NUM")[1],0)
TcSetField("RPTEIU","EIU_ADICAO" ,"C",TamSX3("EIU_ADICAO")[1],0)
TcSetField("RPTEIU","EIU_CODIGO" ,"C",TamSX3("EIU_CODIGO")[1],0)
TcSetField("RPTEIU","W7_FABR" ,"C",TamSX3("W7_FABR")[1],0)
TcSetField("RPTEIU","EIU_VALOR" ,"N",TamSX3("EIU_VALOR")[1],TamSX3("EIU_VALOR")[2])


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento dos registros para incremento no Array				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RPTEIU->(DbGoTop())

While !RPTEIU->(EOF())    
  
		AADD(aInfAdicoes,{RPTEIU->EIU_ADICAO,;    
  					  				   RPTEIU->EIU_CODIGO,; 
  					  				   RPTEIU->W7_FABR,;
					  				   Trans(RPTEIU->EIU_VALOR,PesqPict('EIU','EIU_VALOR'))})								  		  
 	
	RPTEIU->(DbSkip())
 
End 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Fechar o arquivo TMP da Query.																								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
If Select("RPTEIU") > 0
	RPTEIU->(DbCloseArea())
EndIf  
  
RestArea(aArea)

Return(NIL)                   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³AudinC335Cdx  ³ Autor ³ Tiago Bandeira    ³ Data ³09/08/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna um array com Informacoes Complementares de		  ³±±
±±³          ³ Exportação, considerandoo lay-out do registro C328.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AudinC335Cdx(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,   ³±±
±±³          ³ cLoja,aInfExport,cEstado,cCFO)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA1 := Array com as informações   				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FISCAL                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function AudinC335Cdx(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,cLoja,cTipo,aInfAdicoes,cEstado,cCFO)
Local aArea		:= GetArea()
Local aAreaSF3 	:= SF3->(GetArea())
Local aAreaSF1 	:= SF1->(GetArea())
Local aAreaSW6 	:= SW6->(GetArea())
Local aAreaSW7 	:= SW7->(GetArea())
Local aAreaSWN 	:= SWN->(GetArea())
Local aAreaEIU 	:= EIU->(GetArea())

dbSelectArea("SF3") //LIVROS FISCAIS                
dbSetOrder(6) 		//F3_FILIAL+F3_NFISCAL+F3_SERIE
If dbSeek(xFilial("SF3")+cNFiscal+cSerie)
	While !SF3->(Eof())							.And.;
		SF3->F3_FILIAL==xFilial("SF3")			.And.;		
		SF3->F3_NFISCAL==cNFiscal				.And.;
		SF3->F3_SERIE==cSerie		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Filtar CFO e Estado (Esta filtrando na query) 	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If !(SF3->F3_CFO < cCFO						.And.;
			SF3->F3_ESTADO == cEstado				.And.;
			DTOS(SF3->F3_ENTRADA)>=DtoS(dDataIni)	.And.;
			DTOS(SF3->F3_ENTRADA)<=DtoS(dDataFim)	.And.;
			SF3->F3_CLIEFOR==cFornece				.And.;
			SF3->F3_LOJA==cLoja)		   
		   
			SF3->(dbSkip())
			Loop
		EndIf

		dbSelectArea("SF1") //CABECALHO DAS NF'S DE ENTRADA
		dbSetOrder(1) 		//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		If dbSeek(xFilial("SF1")+SF3->F3_NFISCAL+SF3->F3_SERIE)
		     
			While !SF1->(Eof()) .And. (SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE == xFilial("SF1")+SF3->F3_NFISCAL+SF3->F3_SERIE)
			
				dbSelectArea("SW6") 	//D.I. (Capa)     
				dbSetOrder(1)		 	//SW6_FILIAL+SW6_HAWB	        
		        If dbSeek(xFilial("SW6")+SF1->F1_HAWB)
		        				        
	              	dbSelectArea("SWN") 	//ITENS DA NFE DE IMPORTACAO 
					dbSetOrder(1)		 	//WN_FILIAL+WN_DOC+WN_SERIE+WN_TEC+WN_EX_NCM+WN_EX_NBM		        
			        If dbSeek(xFilial("SWN")+SF1->F1_DOC+SF1->F1_SERIE)
			            
			        	While !SWN->(Eof()) .And. (SWN->WN_FILIAL+SWN->WN_DOC+SWN->WN_SERIE == xFilial("SWN")+SF1->F1_DOC+SF1->F1_SERIE)
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³  WN_HAWB (não possui na chave)	³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
							If (SWN->WN_HAWB <> SF1->F1_HAWB)
								SWN->(dbSkip())
								Loop
							EndIf
							
							dbSelectArea("EIU") 	//ACRESCIMOS / DEDUCOES     
							dbSetOrder(1)		 	//EIU_FILIAL+EIU_HAWB+EIU_TIPONF+EIU_ADICAO	        
					        If dbSeek(xFilial("EIU")+SF1->F1_HAWB+SF1->F1_TIPO_NF)
					                
					        	While !EIU->(Eof()) .And. EIU->EIU_FILIAL+EIU->EIU_HAWB+EIU->EIU_TIPONF == xFilial("EIU")+SF1->F1_HAWB+SF1->F1_TIPO_NF				
                                    
									If !(EIU->EIU_TIPO <> cTipo)
										EIU->(dbSkip())
										Loop
									EndIf
											
									dbSelectArea("SW7") 	//D.I. ITENS 
									dbSetOrder(1)		 	//W7_FILIAL+W7_HAWB+W7_PGI_NUM+W7_CC+W7_SI_NUM+W7_COD_I		        
							        If dbSeek(xFilial("SW7")+SWN->WN_HAWB+SWN->WN_PGI_NUM+SWN->WN_CC+SWN->WN_SI_NUM)
							            
							        	While !SW7->(Eof()) .And. (SW7->W7_FILIAL+SW7->W7_HAWB+SW7->W7_PGI_NUM+SW7->W7_CC+SW7->W7_SI_NUM == xFilial("SW7")+SWN->WN_HAWB+SWN->WN_PGI_NUM+SWN->WN_CC+SWN->WN_SI_NUM)
										
											AADD(aInfAdicoes,{	EIU->EIU_ADICAO,;    
					  					  				   		EIU->EIU_CODIGO,; 
					  					  				   		SW7->W7_FABR,;
										  				   		Trans(EIU->EIU_VALOR,PesqPict('EIU','EIU_VALOR'))})
										  	
										  	SW7->(dbSkip())								  		  
									    EndDo
									EndIf
									EIU->(dbSkip())
								EndDo
							EndIf														
							SWN->(dbSkip())
						EndDo							
					EndIf								
				EndIf				
				SF1->(dbSkip())								
			EndDo								
	    EndIf
		SF3->(dbSkip())
	EndDo		
EndIf

RestArea(aAreaEIU)
RestArea(aAreaSWN)
RestArea(aAreaSW7)
RestArea(aAreaSW6)
RestArea(aAreaSF1)
RestArea(aAreaSF3)
RestArea(aArea)


Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³  AUDTEST()   ³ Autor ³ Marcos Alves      ³ Data ³09/08/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Testar a geração dos registros de AUDIN          		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CDXAudinC335(dDataIni,dDataFim,cNFiscal,cSerie,cFornece,   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA1 := Array com as informações   				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FISCAL                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
User Function AUDTEST()
Local dDataIni := CTOD("01/06/07")
Local dDataFim := CTOD("30/08/07")


DbSelectArea("SF3")
DbSetOrder(1)
DbSeek(xFilial("SF3")+DTOS(dDataIni),.T.)
While ! Eof() .and. DTOS(F3_ENTRADA) <= DTOS(dDataFim)
	
	aInfExport := AUDINC328(dDataIni,dDataFim,SF3->F3_NFISCAL,SF3->F3_SERIE,SF3->F3_CLIEFOR,SF3->F3_LOJA)
	
	aInfImport := AUDINC330(dDataIni,dDataFim,SF3->F3_NFISCAL,SF3->F3_SERIE,SF3->F3_CLIEFOR,SF3->F3_LOJA)
	
	aInfAdicoes := AUDINC335(dDataIni,dDataFim,SF3->F3_NFISCAL,SF3->F3_SERIE,SF3->F3_CLIEFOR,SF3->F3_LOJA)
	        	    
	DbSelectArea("SF3")
	DbSkip()
End
	
Return