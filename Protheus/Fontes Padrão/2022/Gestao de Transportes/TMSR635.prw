#INCLUDE "TMSR635.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE CRLF Chr(13)+Chr(10) 

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSR635()
Relatorio de Performance de Entregas

@author Robson Melo
@since 17/09/2013
@version P12 
@menu SIGATMS/Atualizacoes/Relatorios/ Movmtos.transporte
/*/
//------------------------------------------------------------------- 

Function TMSR635()

Local oReport
Local aArea := GetArea()
Private cPerg  	 := STR0037//"TMSR635"

Pergunte(cPerg, .F.)

oReport:= ReportDef()
oReport:PrintDialog()

RestArea(aArea)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Relatorio de Performance de Entregas

@author Robson Melo
@since 17/09/2013
@version P12 
@menu SIGATMS/Atualizacoes/Relatorios/ Movmtos.transporte
/*/
//------------------------------------------------------------------- 

Static Function ReportDef()

Local oReport

Local cAliasQry := GetNextAlias()
Local aOrdem    := {}
Local aAreaSM0  := SM0->(GetArea())

Local oSection1
Local oSection2
Local oSection3
Local oSection4
Local oSection5

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:= TReport():New(STR0037,STR0038,STR0037, {|oReport| ReportPrint(oReport,oSection1,oSection2,oSection3,oSection4,oSection5)},STR0039)/*"Performance de Entregas"*///"Este programa ira emitir um relatorio de performance de entregas de acordo com os parametros escolhidos pelo usuario " 
oReport:SetLandScape() 
oReport:lDisableOrientation := .T.
oReport:oPage:nPapersize := 9 

Pergunte(oReport:uParam,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport, "Seccion1", {}, , ,)
oSection2 := TRSection():New(oReport, "Seccion2", {}, , ,)
oSection3 := TRSection():New(oReport, "Seccion3", {}, , ,)
oSection4 := TRSection():New(oReport, "Seccion4", {}, , ,)
oSection5 := TRSection():New(oReport, "Seccion5", {}, , ,)

RestArea( aAreaSM0 )

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()
Relatorio de Performance de Entregas

@author Robson Melo
@since 17/09/2013
@version P12 
@menu SIGATMS/Atualizacoes/Relatorios/ Movmtos.transporte
/*/
//------------------------------------------------------------------- 
Static Function ReportPrint(oReport,oSection1,oSection2,oSection3,oSection4,oSection5)

Local nX        := 0 
Local cStatus := "7" 
Local cQuery := "" 
Local cAliasDT6 := GetNextAlias() 
Local cFilDoc 	 := ""
Local cDoc    	 := ""
Local cSerie  	 := ""
Local cCliRem 	 := ""
Local cCliDes 	 := ""
Local cCodReg 	 := ""
Local cUfEst  	 := ""
Local cFilDes 	 := ""
Local cTipFre 	 := ""
Local dEmis   	 := ""
Local dPrzEnt 	 := "" 
Local cRef    	 := ""
Local cQuebra    := "" 
Local cDsQuebra	 := ""
Local cDescRef   := STR0001//"Referencia:  FP - Fora do prazo de Entrega    , DP - Dentro do prazo de Entrega,    FA - Fora do prazo de agendamento,    DA - Dentro do prazo de Agendamento"
Local nPrzAge 	 := 0 
Local nPrzEnt 	 := 0
Local nTotGPrzAg := 0
Local nTotPrzAg	 := 0
Local nTotGPrzEnt:= 0
Local nTotPrzEnt := 0
Local nQtdDoc	 := 0
Local nQtdTot	 := 0
Local nQtdAG	 := 0
Local nQtdAGTot	 := 0
Local nDocQtd    := 0
Local nFp	     := 0
Local nDp 		 := 0
Local nFa    	 := 0
Local nDa 		 := 0
Local nPerf   	 := 0
Local nTtGer	 := 0 
Local nTFp	     := 0 
Local nTDp 	     := 0
Local nTFa       := 0
Local nTDa 	     := 0
Local nTPerf     := 0
Local dAgdto 
Local dEntreg 

//MV_PAR16 ...  1 = Analitico | 2= Sintetico
If MV_PAR16 = 1     

	// Filial
	TRCell():New(oSection1,"DSQUEBRA"	, 		, "" 				, "" 							, 200 						,  ,{|| cDsQuebra } 									,"LEFT"  , ,"LEFT" )
	
	// Itens
	TRCell():New(oSection2,"FILDOC"  	,		,STR0002 			, PesqPict("DT6","DT6_FILDOC") 	,12						   ,  ,{|| cFilDoc }										,"LEFT"  , ,"LEFT" )//"Fil Docto" 
	TRCell():New(oSection2,"DOC"     	,		,STR0003	   		, PesqPict("DT6","DT6_DOC")   	,12					       ,  ,{|| cDoc 	} 										,"LEFT"  , ,"LEFT" )//"Docto"
	TRCell():New(oSection2,"SERIE"   	,		,STR0004			, PesqPict("DT6","DT6_SERIE")  	,6					       ,  ,{|| cSerie 	}										,"LEFT"  , ,"LEFT" )//"Serie"
	TRCell():New(oSection2,"CLIREM"  	,		,STR0005	   		, PesqPict("DT6","DT6_CLIREM") 	,12						   ,  ,{|| cCliRem }  										,"LEFT"  , ,"LEFT" )//"Remetente"
	TRCell():New(oSection2,"CLIDES"  	,		,STR0006			, PesqPict("DT6","DT6_CLIDES") 	,14						   ,  ,{|| cCliDes }										,"LEFT"  , ,"LEFT" )//"Destinatario"
	TRCell():New(oSection2,"CDRDES"  	,		,STR0007		 	, PesqPict("DT6","DT6_CDRDES") 	,30						   ,  ,{|| cCodReg }  										,"LEFT"  , ,"LEFT" )//"Regiao Destino"
	TRCell():New(oSection2,"UFDES"   	,	   	,STR0008			, PesqPict("SA1","A1_EST") 		,4					       ,  ,{|| cUfEst  } 										,"LEFT"  , ,"LEFT" )//"UF"
	TRCell():New(oSection2,"FILDES"  	,		,STR0009			, PesqPict("DT6","DT6_FILDES")	,16						   ,  ,{|| cFilDes }  										,"LEFT"  , ,"LEFT" )//"Filial Destino"
	TRCell():New(oSection2,"TIPFRE"  	,		,STR0010			, PesqPict("DT6","DT6_TIPFRE")	,10						   ,  ,{|| cTipFre }  										,"LEFT"  , ,"LEFT" )//"CIF/FOB"
	TRCell():New(oSection2,"DATEMI"  	,		,STR0011			, PesqPict("DT6","DT6_DATEMI")	,13						   ,  ,{|| dEmis 	}  										,"LEFT"  , ,"LEFT" )//"Dt Emissao"
	TRCell():New(oSection2,"PRZENT"  	,		,STR0012			, PesqPict("DT6","DT6_PRZENT") 	,13						   ,  ,{|| dPrzEnt }										,"LEFT"  , ,"LEFT" )//"Dt Prz Ent"
	TRCell():New(oSection2,"DATAGD"  	,		,STR0013			, PesqPict("DYD","DYD_DATAGD") 	,13						   ,  ,{|| dAgdto  }										,"LEFT"  , ,"LEFT" )//"Dt Agendto"
	TRCell():New(oSection2,"DATENT"	  	,		,STR0014			, PesqPict("DT6","DT6_DATENT") 	,13						   ,  ,{|| dEntreg }										,"LEFT"  , ,"LEFT" )//"Dt Entrega"
	TRCell():New(oSection2,"PRAZAGTO"	,		,STR0015			, "" 					   		,15							,  ,{|| nPrzAge }  										,"RIGHT" , ,"RIGHT")//"Prazo Agendto"
	TRCell():New(oSection2,"PRAZENT" 	,		,STR0016			, "" 							,15  						,  ,{|| nPrzEnt }  										,"RIGHT" , ,"RIGHT")//"Prazo Entrega"
	TRCell():New(oSection2,"REF"	  	,	 	,STR0017	    	, "" 					   		,15  						,  ,{|| cRef    }										,"RIGHT" , ,"RIGHT")//"Referencia"
	
	// Totalizadores
	TRCell():New(oSection3,"DOC"	  	,		,"" 				, PesqPict("DT6","DT6_FILDOC") 	,138 						,  ,{|| STR0018+ cValtoChar(nQtdDoc) }		  			,"LEFT"  , ,"LEFT" )//"Total de FP: "
	TRCell():New(oSection3,"AGD"     	,		,"" 				, PesqPict("DT6","DT6_FILDOC") 	,138 						,  ,{|| STR0019+ cValtoChar(nQtdAG) }		  			,"LEFT"  , ,"LEFT" )//"Total de FA: "
	
	//Total Geral
	TRCell():New(oSection4,"TDESPRAZOAG",	   	,"" 				, "" 							,138  						,  ,{|| STR0020 + cValtoChar(nQtdTot)}    				,"LEFT"  , ,"LEFT")//"Total Geral de FP: "
	TRCell():New(oSection4,"TDAG"  		 ,	   	,"" 				, "" 					   		,138  						,  ,{|| STR0021 + cValtoChar(nQtdAGTot)} 				,"LEFT"  , ,"LEFT")//"Total Geral de FA: "
	
	//Descricao da referencia
	TRCell():New(oSection5,"REFE"  		 ,	   	,"" 				, "" 				   	   		,200  						,  ,{|| cDescRef} 	  									,"LEFT" , ,"LEFT")
Else 
    //Quantidades de Documentos
	TRCell():New(oSection3,"DESC"  	    ,		,"" 				, ""							,50						    ,  ,{|| cDsQuebra}										,"LEFT"  , ,"LEFT" )
	TRCell():New(oSection3,"DOC"     	,		,STR0022		   	, ""						   	,15					        ,  ,{|| nDocQtd } 										,"RIGHT" , ,"RIGHT")//"Qtde Doctos"
	TRCell():New(oSection3,"FP"   		,		,STR0023	   		, ""  							,15    					    ,  ,{|| nFp 	}										,"RIGHT" , ,"RIGHT")//"FP"
	TRCell():New(oSection3,"DP"  		,		,STR0024   			, "" 							,15   					    ,  ,{|| nDp 	}  										,"RIGHT" , ,"RIGHT")//"DP"
	TRCell():New(oSection3,"FA"  		,		,STR0025			, "" 							,15   					    ,  ,{|| nFa		}										,"RIGHT" , ,"RIGHT")//"FA"
	TRCell():New(oSection3,"DA"    		,		,STR0026			, "" 							,15   					    ,  ,{|| nDa		}  										,"RIGHT" , ,"RIGHT")//"DA"
	TRCell():New(oSection3,"PERF"   	,	   	,STR0027		 	, "" 							,15       				    ,  ,{|| nPerf	} 										,"RIGHT" , ,"RIGHT")//"% Performance" 
    
    //Total Geral
   	TRCell():New(oSection4,"DESC"  	    ,		,""					, ""							,50						    ,  ,{|| STR0028}										,"LEFT"  , ,"LEFT" ) //"Total Geral"
    TRCell():New(oSection4,"TOTGER"		,		,""					, "" 							,15   					    ,  ,{|| nTtGer	}  										,"RIGHT" , ,"LEFT")
    TRCell():New(oSection4,"FP"   		,		,""		   	   		, ""  							,15    					    ,  ,{|| nTFp 	}										,"RIGHT" , ,"RIGHT")
	TRCell():New(oSection4,"DP"  		,		,""	   		   		, "" 							,15   					    ,  ,{|| nTDp 	}  										,"RIGHT" , ,"RIGHT")
	TRCell():New(oSection4,"FA"  		,		,""			   		, "" 							,15   					    ,  ,{|| nTFa	}										,"RIGHT" , ,"RIGHT")
	TRCell():New(oSection4,"DA"    		,		,"" 				, "" 							,15   					    ,  ,{|| nTDa	}  										,"RIGHT" , ,"RIGHT")
	TRCell():New(oSection4,"PERF"   	,	   	,""				 	, "" 							,15       				    ,  ,{|| nTPerf	} 										,"RIGHT" , ,"RIGHT")

    //Descrição da Referencia
	TRCell():New(oSection5,"REFE"  		 ,	   	,"" 				, "" 				   	   		,200  						,  ,{|| cDescRef} 	  									,"LEFT" , ,"LEFT")
Endif  

cQuery := " SELECT DT6_FILIAL,DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_CLIREM, DT6_LOJREM, DT6_CLIDES, DT6_LOJDES, " + CRLF 
cQuery += " 		DT6_LOJDES, DT6_CDRDES, DT6_FILDES, DT6_DATEMI, DT6_PRZENT, DT6_DATENT, SA13.A1_NOME AS NMREM, SA12.A1_NOME AS NMDEV, " + CRLF
cQuery += " 		DT6_STATUS, DT6_CLIDEV, DT6_LOJDEV, DT6_TIPFRE,DT6_NUMAGD, DT6_ITEAGD, DYD_DATAGD , DYD_ITEAGD, SA1.A1_EST, DUY_DESCRI  "+ CRLF
If SerieNfId("DT6",3,"DT6_SERIE")=="DT6_SDOC"
	cQuery += ", DT6_SDOC "		
EndIf
cQuery += "  FROM " + RetSqlName("DT6") + " DT6 " + CRLF 

cQuery += "  JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_FILIAL = '" + xFilial("SA1") + "'" + CRLF
cQuery += "         AND SA1.A1_COD = DT6_CLIDES " 	+ CRLF 
cQuery += "			AND SA1.A1_LOJA = DT6_LOJDES "	+ CRLF 
cQuery += "			AND SA1.D_E_L_E_T_ = ' ' "	+ CRLF 

cQuery += "  JOIN " + RetSqlName("SA1") + " SA12 ON SA12.A1_FILIAL = '" + xFilial("SA1") + "'" + CRLF
cQuery += "         AND SA12.A1_COD = DT6_CLIDEV " 	+ CRLF 
cQuery += "			AND SA12.A1_LOJA = DT6_LOJDEV "	+ CRLF 
cQuery += "			AND SA12.D_E_L_E_T_ = ' ' "	+ CRLF 

cQuery += "  JOIN " + RetSqlName("SA1") + " SA13 ON SA13.A1_FILIAL = '" + xFilial("SA1") + "'" + CRLF
cQuery += "         AND SA13.A1_COD = DT6_CLIREM " 	+ CRLF 
cQuery += "			AND SA13.A1_LOJA = DT6_LOJREM "	+ CRLF 
cQuery += "			AND SA13.D_E_L_E_T_ = ' ' "	+ CRLF 

cQuery += "  JOIN " + RetSqlName("DYD") + " DYD ON DYD_FILIAL = '" + xFilial("DYD") + "'"+ CRLF 
cQuery += "         AND DYD_NUMAGD = DT6_NUMAGD " 	+ CRLF
cQuery += "			AND DYD_ITEAGD = DT6_ITEAGD "	+ CRLF 
cQuery += "			AND DYD.D_E_L_E_T_ = ' ' " 		+ CRLF 

cQuery += "  JOIN " + RetSqlName("DUY") + " DUY ON DUY_FILIAL = '" + xFilial("DUY") + "'"+ CRLF   
cQuery += "         AND DUY_GRPVEN = DT6_CDRDES " 	+ CRLF
cQuery += "			AND DUY.D_E_L_E_T_ = ' ' " 		+ CRLF 

cQuery += "	WHERE DT6_STATUS = '" +cStatus + "'"			+ CRLF
cQUERY += "			AND DT6_FILORI >= '" + MV_PAR01 +"'"	+ CRLF
CQUERY += "			AND DT6_FILORI <= '" + MV_PAR02 +"'" 	+ CRLF
CQUERY += "			AND DT6_FILDES >= '" + MV_PAR03 +"'"	+ CRLF
CQUERY += "			AND DT6_FILDES <= '" + MV_PAR04 +"'"	+ CRLF
CQUERY += "			AND DT6_CLIREM >= '" + MV_PAR05 +"'"	+ CRLF
CQUERY += "			AND DT6_LOJREM >= '" + MV_PAR06 +"'"	+ CRLF
CQUERY += "			AND DT6_CLIREM <= '" + MV_PAR07 +"'"	+ CRLF
CQUERY += "			AND DT6_LOJREM <= '" + MV_PAR08 +"'"	+ CRLF
CQUERY += "			AND DT6_CLIDEV >= '" + MV_PAR09 +"'"	+ CRLF
CQUERY += "			AND DT6_LOJDEV >= '" + MV_PAR10 +"'"	+ CRLF
CQUERY += "			AND DT6_CLIDEV <= '" + MV_PAR11 +"'"	+ CRLF
CQUERY += "			AND DT6_LOJDEV <= '" + MV_PAR12 +"'"	+ CRLF
CQUERY += "			AND DT6_DATEMI >= '" + DTOS(MV_PAR13) + "'"	+ CRLF
CQUERY += "			AND DT6_DATEMI <= '" + DTOS(MV_PAR14) + "'"	+ CRLF
cQuery += "	        AND DT6.D_E_L_E_T_ = ' ' " 

DO CASE
	CASE mv_par15 == 1
		oReport:SetTitle( oReport:Title()+STR0029)//" - Por Filial Destino"
		cQuery += " ORDER BY DT6_FILDES, DT6_CLIREM, A1_EST, DT6_CDRDES"
	CASE mv_par15 == 2
		oReport:SetTitle( oReport:Title()+STR0030)//" - Por Cliente Remetente"
		cQuery += " ORDER BY DT6_CLIREM, DT6_FILDES, A1_EST, DT6_CDRDES"
	CASE mv_par15 == 3
		oReport:SetTitle( oReport:Title()+STR0031)//" - Por Cliente Devedor"
		cQuery += " ORDER BY DT6_CLIDEV, DT6_FILDES, A1_EST, DT6_CDRDES"
ENDCASE


cQuery := ChangeQuery( cQuery )	   
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasDT6, .F., .T. )

DbSelectArea(cAliasDT6)  
(cAliasDT6)->(DbGoTop())
 
oSection1:Init()
oSection2:Init()
oSection3:Init()
oSection4:Init()
oSection5:Init()

DO CASE
	CASE MV_PAR15 == 1
		cQuebra := STR0032//"Filial Destino : "
		cDsQuebra := (cAliasDT6)->DT6_FILDES
	CASE MV_PAR15 == 2
		cQuebra := STR0033//"Cliente Remetente : "
		cDsQuebra := (cAliasDT6)->DT6_CLIREM + "/" + (cAliasDT6)->DT6_LOJREM + "/" +(cAliasDT6)->NMREM 
	CASE MV_PAR15 == 3
		cQuebra := STR0034//"Cliente Devedor : "
		cDsQuebra := (cAliasDT6)->DT6_CLIDEV + "/" + (cAliasDT6)->DT6_LOJDEV + "/" +(cAliasDT6)->NMDEV 
ENDCASE
	
While !oReport:Cancel() .And. !(cAliasDT6)->(Eof())
   		nDocQtd+= 1
		nX += 1
	If oReport:Cancel()
		Exit
	EndIf	

	IF nX == 1
		cDsQuebra := cQuebra + cDsQuebra
		oSection1:PrintLine()
		
	ELSE
		DO CASE
			CASE MV_PAR15 == 1 
			
				IF cDsQuebra <>  STR0032 +(cAliasDT6)->DT6_FILDES//"Filial Destino : "
					cDsQuebra := STR0032 +(cAliasDT6)->DT6_FILDES
					oSection1:PrintLine()
				ENDIF
					
			CASE MV_PAR15 == 2
			
				IF cDsQuebra <>  STR0033 + (cAliasDT6)->DT6_CLIREM + "/" + (cAliasDT6)->DT6_LOJREM + "/" + (cAliasDT6)->NMREM //"Cliente Remetente : "
					cDsQuebra := STR0033 + (cAliasDT6)->DT6_CLIREM + "/" + (cAliasDT6)->DT6_LOJREM + "/" + (cAliasDT6)->NMREM
					oSection1:PrintLine()
				ENDIF 
						
			CASE MV_PAR15 == 3
			
				IF cDsQuebra <>  STR0034 + (cAliasDT6)->DT6_CLIDEV + "/" + (cAliasDT6)->DT6_LOJDEV + "/" + (cAliasDT6)->NMDEV//"Cliente Devedor : "
					cDsQuebra := STR0034 + (cAliasDT6)->DT6_CLIDEV + "/" + (cAliasDT6)->DT6_LOJDEV + "/" + (cAliasDT6)->NMDEV
					oSection1:PrintLine()
				ENDIF	
		ENDCASE	
	ENDIF

	// ITENS   	   
	 cFilDoc 	:= (cAliasDT6)->DT6_FILDOC
	 cDoc    	:= (cAliasDT6)->DT6_DOC
	 cSerie  	:= SerieNfId(cAliasDT6,2,"DT6_SERIE")
	 cCliRem 	:= (cAliasDT6)->DT6_CLIREM
	 cCliDes 	:= (cAliasDT6)->DT6_CLIDES
	 cCodReg 	:= (cAliasDT6)->DUY_DESCRI
	 cUfEst  	:= (cAliasDT6)->A1_EST
	 cFilDes 	:= (cAliasDT6)->DT6_FILDES                            
	 cTipFre 	:= IIF((cAliasDT6)->DT6_TIPFRE = "1", STR0035, STR0036)//"CIF", "FOB"
	 dEmis   	:= STOD((cAliasDT6)->DT6_DATEMI)
	 dPrzEnt 	:= STOD((cAliasDT6)->DT6_PRZENT)
	 dAgdto 	:= STOD((cAliasDT6)->DYD_DATAGD)
	 dEntreg 	:= STOD((cAliasDT6)->DT6_DATENT)
	 
	 If Empty((cAliasDT6)->DYD_DATAGD)
	 	nPrzAge := 0 
	 	nPrzEnt 	:= IIf(STOD((cAliasDT6)->DT6_DATENT) - STOD((cAliasDT6)->DT6_PRZENT) <0 , STOD((cAliasDT6)->DT6_PRZENT) - STOD((cAliasDT6)->DT6_DATENT), STOD((cAliasDT6)->DT6_DATENT) - STOD((cAliasDT6)->DT6_PRZENT))
	 	cRef    	:= IIf(STOD((cAliasDT6)->DT6_DATENT) > STOD((cAliasDT6)->DT6_PRZENT), STR0023 ,Iif( STOD((cAliasDT6)->DT6_DATENT) <= STOD((cAliasDT6)->DT6_PRZENT), STR0024 , Iif( STOD((cAliasDT6)->DT6_DATENT) > STOD((cAliasDT6)->DYD_DATAGD), STR0025,Iif( STOD((cAliasDT6)->DT6_DATENT) <= STOD((cAliasDT6)->DYD_DATAGD), STR0026,))))//"FP" "DP" "FA" "DA"
	 
	 Else  
	 	nPrzEnt:= 0
		nPrzAge := IIf(STOD((cAliasDT6)->DT6_DATENT) - STOD((cAliasDT6)->DYD_DATAGD) <0 , STOD((cAliasDT6)->DYD_DATAGD) - STOD((cAliasDT6)->DT6_DATENT), STOD((cAliasDT6)->DT6_DATENT) - STOD((cAliasDT6)->DYD_DATAGD))
	 	cRef    := Iif( STOD((cAliasDT6)->DT6_DATENT) > STOD((cAliasDT6)->DYD_DATAGD), STR0025 ,Iif( STOD((cAliasDT6)->DT6_DATENT) <= STOD((cAliasDT6)->DYD_DATAGD), STR0026,))//"FA" "DA"
	                                                                                                                                                                                   
	 Endif 
	 
	If cRef = STR0023//"FP"
		nQtdDoc+= 1
		nFp+= 1
	Elseif cRef = STR0024//"DP" 
		nDp+= 1
	Elseif cRef = STR0025//"FA"   
   		nQtdAG+= 1
		nFa+= 1
	Elseif cRef = STR0026//"DA"
		nDa+= 1
	Endif
	
	If MV_PAR16 = 1
		oSection2:PrintLine()
	Endif
	
	// TOTALIZADORES
	nTotPrzAg := nTotPrzAg  + nPrzAge
	nTotPrzEnt:= nTotPrzEnt + nPrzEnt
			
	(cAliasDT6)->(DbSkip()) 
	
		DO CASE
			CASE MV_PAR15 == 1 			
				IF cDsQuebra <> STR0032 +(cAliasDT6)->DT6_FILDES//"Filial Destino : "
                	oReport:ThinLine() 
					nPerf	   := cValToChar(STR(Round((((nDa + nDp) / (nDocQtd))*100),2),3,0))+"%"
                	oReport:Section(3):PrintLine()
                	oReport:SkipLine()
                	nTotGPrzAg += nTotPrzAg 
					nTotGPrzEnt+= nTotPrzEnt
					nQtdTot	   += nQtdDoc
					nQtdAGTot  += nQtdAG
					nTtGer	   += nDocQtd
					nTFp	   += nFp 
					nTDp 	   += nDp
					nTFa       += nFa
					nTDa 	   += nDa					
					nFp	       := 0					 
				    nDp 	   := 0				    
				    nFa    	   := 0				    
				    nDa 	   := 0					   	
                	nTotPrzAg  := 0
					nTotPrzEnt := 0
					nQtdDoc    := 0
					nQtdAG     := 0
					nDocQtd    := 0
				ENDIF
			CASE MV_PAR15 == 2			
				IF cDsQuebra <> STR0033 + (cAliasDT6)->DT6_CLIREM + "/" + (cAliasDT6)->DT6_LOJREM //"Cliente Remetente : "
	               	oReport:ThinLine() 
					nPerf	   := cValToChar(STR(Round((((nDa + nDp) / (nDocQtd))*100),2),3,0))+"%"
	               	oReport:Section(3):PrintLine()
                	oReport:SkipLine() 
               		nTotGPrzAg += nTotPrzAg 
					nTotGPrzEnt+= nTotPrzEnt
					nQtdTot	   += nQtdDoc
					nQtdAGTot  += nQtdAG
					nTtGer	   += nDocQtd 
					nTFp	   += nFp 
					nTDp 	   += nDp
					nTFa       += nFa
					nTDa 	   += nDa 					
					nFp	       := 0
				    nDp 	   := 0
				    nFa    	   := 0
				    nDa 	   := 0	
                	nTotPrzAg  := 0
					nTotPrzEnt := 0
					nQtdDoc    := 0
					nQtdAG     := 0
					nDocQtd    := 0
				ENDIF 			
			CASE MV_PAR15 == 3
				IF cDsQuebra <> STR0034 + (cAliasDT6)->DT6_CLIDEV + "/" + (cAliasDT6)->DT6_LOJDEV//"Cliente Devedor : "
    				oReport:ThinLine() 
    				nPerf	   := cValToChar(STR(Round((((nDa + nDp) / (nDocQtd))*100),2),3,0))+ "%"
    				oReport:Section(3):PrintLine()
                	oReport:SkipLine()
        			nTotGPrzAg += nTotPrzAg 
					nTotGPrzEnt+= nTotPrzEnt
					nQtdTot	   += nQtdDoc
					nQtdAGTot  += nQtdAG 
					nTtGer	   += nDocQtd
					nTFp	   += nFp 
					nTDp 	   += nDp
					nTFa       += nFa
					nTDa 	   += nDa 
					nFp	       := 0
				    nDp 	   := 0
				    nFa    	   := 0
				    nDa 	   := 0	
                	nTotPrzAg  := 0
					nTotPrzEnt := 0
					nQtdDoc    := 0
					nQtdAG     := 0
					nDocQtd    := 0
				ENDIF	
		ENDCASE	      
Enddo

nTPerf:= cValToChar(Round((((nTDa + nTDp) / (nTtGer))*100),0))+ "%"


oReport:FatLine()

oReport:Section(4):PrintLine()
oReport:Section(5):PrintLine()

oReport:Section(1):Finish()
oReport:Section(2):Finish()
oReport:Section(3):Finish()
oReport:Section(4):Finish()
oReport:Section(5):Finish()

(cAliasDT6)->(DbCloseArea())

Return