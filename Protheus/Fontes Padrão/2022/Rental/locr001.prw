#INCLUDE "locr001.ch" 
/*/{PROTHEUS.DOC} LOCR001.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATำRIO DE INTEGRAวรO POR OBRA
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"

FUNCTION LOCR001()
LOCAL CDESC1         := STR0001 //"ESTE PROGRAMA TEM COMO OBJETIVO IMPRIMIR RELATORIO "
LOCAL CDESC2         := STR0002 //"DE ACORDO COM OS PARAMETROS INFORMADOS PELO USUARIO."
LOCAL CDESC3         := STR0003 //"RELATำRIO DE INTEGRAวรO POR OBRA"
LOCAL TITULO         := STR0003 //"RELATำRIO DE INTEGRAวรO POR OBRA"
LOCAL NLIN           := 80
LOCAL CABEC1         := ""
LOCAL CABEC2         := ""
LOCAL AORD           := {}
LOCAL IMPRIME 

PRIVATE LEND         := .F.
PRIVATE LABORTPRINT  := .F.
PRIVATE LIMITE       := 80
PRIVATE TAMANHO      := "P"
PRIVATE NOMEPROG     := "INTOBRA"
PRIVATE NTIPO        := 18
PRIVATE ARETURN      := { "ZEBRADO", 1, "ADMINISTRACAO", 2, 2, 1, "", 1}
PRIVATE NLASTKEY     := 0
PRIVATE CPERG        := "LOCP012"
PRIVATE CBTXT        := SPACE(10)
PRIVATE CBCONT       := 00
PRIVATE CONTFL       := 01
PRIVATE M_PAG        := 01
PRIVATE WNREL        := "INTOBRA"
PRIVATE CSTRING      := "FPU"

IMPRIME := .T.

DBSELECTAREA("FPU")
DBSETORDER(1)

//VALIDSX1(CPERG)
PERGUNTE(CPERG,.F.)

WNREL := SETPRINT(CSTRING,NOMEPROG,CPERG,@TITULO,CDESC1,CDESC2,CDESC3,.F.,AORD,.F.,TAMANHO,,.T.)

IF NLASTKEY == 27
	RETURN
ENDIF

SETDEFAULT(ARETURN,CSTRING)

IF NLASTKEY == 27
	RETURN
ENDIF

NTIPO := IF(ARETURN[4]==1,15,18)

RPTSTATUS({|| RUNREPORT(CABEC1,CABEC2,TITULO,NLIN) },TITULO)

RETURN



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFUNO    ณ RUNREPORT บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 30/06/2007 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRIO ณ FUNCAO AUXILIAR CHAMADA PELA RPTSTATUS. A FUNCAO RPTSTATUS บฑฑ
ฑฑบ          ณ MONTA A JANELA COM A REGUA DE PROCESSAMENTO.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ PROGRAMA PRINCIPAL                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION RUNREPORT(CABEC1,CABEC2,TITULO,NLIN)

LOCAL CARQUIVO  								// ARQUIVO PADRรO HTML NA PASTA SERVER\SYSTEM
LOCAL NARQ      								// ABERTURA DO ARQUIVO BINมRIO
LOCAL CHTML										// STRINGS TEMPORมRIA PARA ALIMENTAR O ARQUIVO.HTML
LOCAL AARRAY := {}
LOCAL N      := 0 

IF MV_PAR13 == 1								// SE FOR EXPORTAR PARA O EXCEL
	/* Desativado por questoes dos debitos tecnicos - Frank em 06/04/2022
	CARQUIVO  := CRIATRAB(,.F.)+".HTM"			// ARQUIVO PADRรO HTML NA PASTA SERVER\SYSTEM
	NARQ      := FCREATE(CARQUIVO,0)			// ABERTURA DO ARQUIVO BINมRIO

	CHTML := STR0004 + CRLF //"<HTML><HEAD><TITLE>RELATำRIO DE INTEGRAวรO POR OBRA</TITLE></HEAD>"
	CHTML += "<BODY><TABLE BORDER='1'><TR>"
	CHTML += STR0005 //"<TD COLSPAN='9'><CENTER><H2>RELATำRIO DE INTEGRAวรO POR OBRA</H2></CENTER>"
	CHTML += STR0006 + IF( EMPTY(MV_PAR01), "", STR0007+MV_PAR01) + STR0008 + MV_PAR02 //"PARยMETROS: PROJETO"###" DE :"###" ATษ: "
	CHTML += STR0009 + IF( EMPTY(MV_PAR03), "", STR0007+MV_PAR03) + STR0008 + MV_PAR04 //" - MATRอCULA"###" DE :"###" ATษ: "
	CHTML += STR0010 + IF( EMPTY(MV_PAR05), "", STR0007+DTOC(MV_PAR05)) + STR0008 + DTOC(MV_PAR06) //" - DT INTEGRAวรO"###" DE :"###" ATษ: "
	CHTML += STR0011 + IF( EMPTY(MV_PAR07), "", STR0007+DTOC(MV_PAR07)) + STR0008 + DTOC(MV_PAR08) //" - VENCTO ASO"###" DE :"###" ATษ: "
	CHTML += STR0012 + IF( EMPTY(MV_PAR09), "", STR0007+MV_PAR09) + STR0008 + MV_PAR10 //" - CLIENTE"###" DE :"###" ATษ: "
	CHTML += STR0013 + IF( EMPTY(MV_PAR11), "", STR0007+MV_PAR11) + STR0008 + MV_PAR12 //" - LOJA"###" DE :"###" ATษ: "
	CHTML += "</TD></TR><TR>"

	CHTML += STR0014 //"<TH>PROJETO</TH>"
	CHTML += STR0015 //"<TH>OBRA</TH>"
	CHTML += STR0016 //"<TH>MATRอCULA</TH>"
	CHTML += STR0017 //"<TH>NOME</TH>"
	CHTML += STR0018 //"<TH>VAL. INTEGRAวรO</TH>"
	CHTML += STR0019 //"<TH>VAL. ASO</TH>"
	CHTML += STR0020 //"<TH>CRACHม</TH>"
	CHTML += STR0021 //"<TH>PPRA VมLIDO ATษ:</TH>"
	CHTML += STR0022	 //"<TH>PCMSO VมLIDO ATษ:</TH>"
	CHTML += "</TR>" + CRLF
	FWRITE(NARQ,CHTML,LEN(CHTML))
	*/
ENDIF

DBSELECTAREA(CSTRING)
DBSETORDER(1)

SETREGUA(RECCOUNT())

NX       := 1
CPROJANT := ""
COBRAANT := ""  

// MONTAGEM DOS ITENS DO RELATำRIO
// INCLUIDO A CONDIวรO FPU_CONTRO. SOMENTE TRAZER REGISTROS COM O CAMPO PREENCHIDO E O MAIOR NUMERO REFERENTE AO FUNCIONARIO.
CQRY1 := " SELECT DISTINCT MAX(FPU_CONTRO) FPU_CONTRO,FPU_PROJ, FPU_OBRA, FPU_MAT, FPU_NOME, MAX(TM5_DATVAL) AS TM5_DATVAL ,MAX(TO0_DTVALI) TO0_DTVALI,"			+CRLF
CQRY1 += " 		  MAX(TMW_DTFIM) AS TMW_DTFIM, FPU_AS  ,FPU_DTFIN, FPU_VALID,FPU_CRACHA, CONVERT(VARCHAR(8),DATEADD ( MONTH ,FPU_VALID, FPU_DTFIN ),112) SOMDATA " 		+CRLF
CQRY1 += " FROM	( "																																					+CRLF
CQRY1 += "	SELECT FPU_CONTRO, ZM0.FPU_PROJ, ZM0.FPU_OBRA, ZM0.FPU_MAT, ZM0.FPU_NOME ,TM5.TM5_DATVAL,TO0_DTVALI , TMW_DTFIM,FPU_AS ,FPU_DTFIN, FPU_VALID, FPU_CRACHA " 							+CRLF
CQRY1 += "	FROM "+RETSQLNAME("FPU")+" ZM0  " 																		                                   				+CRLF
CQRY1 += " 		LEFT JOIN "+RETSQLNAME("TMW")+" TMW ON TMW.D_E_L_E_T_ = '' " 																						+CRLF
CQRY1 += "	        AND TMW.TMW_PROJET = ZM0.FPU_PROJ " 																											+CRLF
CQRY1 += "	       	AND TMW.TMW_OBRA = ZM0.FPU_OBRA " 																												+CRLF
CQRY1 += "         	AND TMW.TMW_FILIAL = ZM0.FPU_FILIAL " 																											+CRLF
CQRY1 += "		LEFT JOIN "+RETSQLNAME("TM5")+" TM5 ON TM5.D_E_L_E_T_ = ''"																							+CRLF
CQRY1 += "			AND TM5.TM5_FILIAL = '"+XFILIAL("TM5")+"' "			   																							+CRLF
CQRY1 += "			AND ZM0.FPU_MAT = TM5.TM5_MAT "																													+CRLF
CQRY1 += "			AND TM5.TM5_EXAME = 'NR7'  "       																												+CRLF
CQRY1 += "         	AND TMW.TMW_PCMSO = TM5.TM5_PCMSO " 																											+CRLF
CQRY1 += "		LEFT JOIN "+RETSQLNAME("TM0")+" TM0 ON TM0.D_E_L_E_T_ = '' "																						+CRLF
CQRY1 += "	   		AND TM0.TM0_FILFUN = '"+CFILANT+"'"																											    +CRLF
CQRY1 += "	   		AND  TM5.TM5_MAT = TM0.TM0_MAT "																												+CRLF
CQRY1 += "	   		AND TM5_NUMFIC = TM0_NUMFIC "                      			                       																+CRLF
CQRY1 += " 		LEFT JOIN "+RETSQLNAME("TO0")+" TO0 ON TO0.D_E_L_E_T_ = '' " 																						+CRLF
CQRY1 += "          AND TO0.TO0_PROJET = ZM0.FPU_PROJ "																												+CRLF
CQRY1 += "          AND TO0.TO0_OBRA = ZM0.FPU_OBRA " 											   																	+CRLF
CQRY1 += "          AND TO0.TO0_FILIAL = ZM0.FPU_FILIAL " 								   																			+CRLF
CQRY1 += " 	WHERE ZM0.D_E_L_E_T_='' "                                                                        	              										+CRLF
CQRY1 += "   	AND ZM0.FPU_FILIAL = '"+XFILIAL("FPU")+"'  "                                                                       									+CRLF
CQRY1 += "		AND ZM0.FPU_MAT BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "                                                        									+CRLF
CQRY1 += "		AND ZM0.FPU_DTFIN BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"'  " 				                                  						+CRLF
CQRY1 += "		AND FPU_CONTRO <> '' "																																+CRLF
CQRY1 += "	) TMP "																																					+CRLF
CQRY1 += "  GROUP BY FPU_PROJ, FPU_OBRA, FPU_MAT, FPU_NOME ,FPU_AS ,FPU_DTFIN, FPU_VALID, FPU_CRACHA "																+CRLF
CQRY1 += "	ORDER BY FPU_PROJ "																																		+CRLF
TCQUERY CQRY1 NEW ALIAS "TRB2"

DBSELECTAREA("TRB2")
TRB2->(DBGOTOP()) 
                   
WHILE TRB2->(!EOF())
	NPOS := ASCAN(AARRAY,{|X| X[2] == TRB2->FPU_PROJ .AND. X[4] == TRB2->FPU_MAT .AND. X[3] == TRB2->FPU_OBRA})
	
	IF NPOS > 0
		IF AARRAY[NPOS][10] < TRB2->SOMDATA //CVALTOCHAR((MONTHSUM(STOD(TRB2->FPU_DTFIN), TRB2->FPU_VALID)))//
			IF AARRAY[NPOS][1] <= TRB2->FPU_CONTRO
				AARRAY[NPOS]:= {TRB2->FPU_CONTRO,TRB2->FPU_PROJ, TRB2->FPU_OBRA, TRB2->FPU_MAT, TRB2->FPU_NOME, TRB2->TM5_DATVAL ,TRB2->TO0_DTVALI,TRB2->TMW_DTFIM, TRB2->FPU_AS ,TRB2->SOMDATA,TRB2->FPU_CRACHA}
			ENDIF
		ENDIF
	ELSE
		AADD(AARRAY, {TRB2->FPU_CONTRO,TRB2->FPU_PROJ, TRB2->FPU_OBRA, TRB2->FPU_MAT, TRB2->FPU_NOME, TRB2->TM5_DATVAL ,TRB2->TO0_DTVALI,TRB2->TMW_DTFIM, TRB2->FPU_AS,TRB2->SOMDATA,TRB2->FPU_CRACHA})	
	ENDIF
	
	TRB2->(DBSKIP()) 
ENDDO             

FOR N:= 1 TO LEN(AARRAY)
     
 //	IF FPU->(DBSEEK(XFILIAL("FPU")+AARRAY[N][3]+AARRAY[N][2]+AARRAY[N][4]))
		IF LABORTPRINT
			@ NLIN,00 PSAY STR0023 //"*** CANCELADO PELO OPERADOR ***"
			EXIT
		ENDIF
	
		// IMPRIME CABEวALHO		
		IF NLIN > 55 .OR. 	CPROJANT <> AARRAY[N][2] .OR. COBRAANT <> AARRAY[N][3]// SALTO DE PมGINA. NESTE CASO O FORMULARIO TEM 55 LINHAS...
			CABEC(TITULO,CABEC1,CABEC2,NOMEPROG,TAMANHO,NTIPO)
			NLIN := 6
	
			NX++
			@ NLIN,00 PSAY " ________________________________________________________________________________"
			NLIN++
	
			@ NLIN,00 PSAY STR0024 //"|PROJETO:"
			@ NLIN,40 PSAY AARRAY[N][2]
			@ NLIN,81 PSAY "|"
	
			NLIN++
			@ NLIN,00 PSAY STR0025 //"|OBRA:"
			@ NLIN,40 PSAY AARRAY[N][3]
			@ NLIN,81 PSAY "|"
	
			NLIN++
			@ NLIN,00 PSAY STR0026 //"|PPRA VมLIDO ATษ:"
			@ NLIN,40 PSAY DTOC(STOD(AARRAY[N][7])) //MAICKON QUEIROZ - ALTERAวรO 
			@ NLIN,81 PSAY "|"
	
			NLIN++
			@ NLIN,00 PSAY STR0027 //"|PCMSO VมLIDO ATษ:"
			@ NLIN,40 PSAY DTOC(STOD(AARRAY[N][8]))
			@ NLIN,81 PSAY "|" 
	
		 //	NLIN++
			@ NLIN,00 PSAY " ________________________________________________________________________________ "
			NLIN++
			@ NLIN,00 PSAY STR0028 //"|MATRอCULA |NOME FUNCIONมRIO                     |VAL.INTEGR. |VAL. ASO   |CRACHA|"
			@ NLIN,00 PSAY " ________________________________________________________________________________ "
			NLIN++
	   	ENDIF
	
		// IMPRESSรO DOS ITENS
		@ NLIN, 00 PSAY "|"+ ALLTRIM(AARRAY[N][4])  										//MATRICULA
		@ NLIN, 11 PSAY "|"+ ALLTRIM(AARRAY[N][5])                                        //NOME DO FUNCIONARIO
		@ NLIN, 49 PSAY "|"+ CVALTOCHAR(STOD(ALLTRIM(AARRAY[N][10])))//CVALTOCHAR((MONTHSUM(FPU->FPU_DTFIN, FPU->FPU_VALID)))					    //VAL. INTEGRAวAี
		@ NLIN, 62 PSAY "|"+ DTOC(STOD(AARRAY[N][6]))
			
		IF ALLTRIM(AARRAY[N][11]) = '1'
			CCRACHA := STR0029 //"ATIVO"
		ELSE
			CCRACHA := STR0030 //" NAO "
		ENDIF
			
		@ NLIN, 74 PSAY "|"+ CCRACHA
		@ NLIN, 81 PSAY "|"
		NLIN := NLIN + 1 // AVANCA A LINHA DE IMPRESSAO
			
		CPROJANT := AARRAY[N][2]
		COBRAANT := AARRAY[N][3]
	
		@NLIN-1,00 PSAY  " ________________________________________________________________________________"
		
	 //	NLIN:= 95 //SALDO DE PAGINA
	    
	    IF MV_PAR13 == 1		// SE FOR EXPORTAR PARA O EXCEL
			/*
			CHTML := '<TR>'
			CHTML += '<TD>' + AARRAY[N][2] + '</TD>'
			CHTML += '<TD>&NBSP;' + AARRAY[N][3] + '</TD>'
			CHTML += '<TD>&NBSP;' + ALLTRIM(AARRAY[N][4]) + '</TD>'
			CHTML += '<TD>' + ALLTRIM(AARRAY[N][5]) + '</TD>'
			CHTML += '<TD>' + CVALTOCHAR(STOD(ALLTRIM(AARRAY[N][10]))) + '</TD>'
			CHTML += '<TD>' + DTOC(STOD(AARRAY[N][6])) + '</TD>'
			CHTML += '<TD>' + CCRACHA + '</TD>' + CRLF
			CHTML += '<TD>' + DTOC(STOD(AARRAY[N][7])) + '</TD>' + CRLF
			CHTML += '<TD>' + DTOC(STOD(AARRAY[N][8])) + '</TD></TR>' + CRLF
			FWRITE(NARQ,CHTML,LEN(CHTML))
			*/
		ENDIF    
 //	ENDIF
 //	TRB2->(DBSKIP())  
 //	TRB1->(DBCLOSEAREA()) 
	
NEXT

TRB2->(DBCLOSEAREA())
//FPU->(DBCLOSEAREA())
	
SET DEVICE TO SCREEN
	
IF ARETURN[5]==1
	DBCOMMITALL()
	SET PRINTER TO
	OURSPOOL(WNREL)
ENDIF
	
MS_FLUSH() 

IF MV_PAR13 == 1							// SE FOR EXPORTAR PARA O EXCEL
	/*
	CHTML := ' </TABLE></BODY></HTML>'+CRLF
	FWRITE(NARQ,CHTML,LEN(CHTML))
	FCLOSE(NARQ)							// FECHAMOS O ARQUIVO PADRรO HTML
	CPYS2T(GETSRVPROFSTRING("STARTPATH","")+CARQUIVO, ALLTRIM(GETTEMPPATH()), .T.)	// COPIA ARQUIVO HTML DO SERVER\SYSTEM P/ TEMPORมRIO DO CLIENTE
	FERASE(CARQUIVO)						// REMOVE ARQUIVO DO SERVER\SYSTEM

	IF APOLECLIENT("MSEXCEL") 				// SE TEM EXCEL NO CLIENTE. ABRIMOS O EXCEL COM O ARQUIVO HTML
		OEXCELAPP := MSEXCEL():NEW()
		OEXCELAPP:WORKBOOKS:OPEN(ALLTRIM(GETTEMPPATH()) + CARQUIVO)
		OEXCELAPP:SETVISIBLE(.T.)
		OEXCELAPP:DESTROY()
	ELSE									//SE NรO ENCONTROU O EXCEL, O S.O. DECIDE COMO ABRIR
		SHELLEXECUTE("OPEN",ALLTRIM(GETTEMPPATH()) + CARQUIVO,"","",1)
	ENDIF
	*/
ENDIF

//DBSELECTAREA("FPU")
//RETINDEX("FPU")
//FERASE(CARQUIVO+ORDBAGEXT())


RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ VALIDSX1  บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 30/06/2007 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRICAO ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ ESPECIFICO GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION VALIDSX1(CPERG)
/*
PUTSX1(CPERG, "01",STR0031," "," ","MV_CH1" ,"C",22,0,0,"G","        "      , "ZA1D"   ,"","","MV_PAR01","","",""," ","","","" ,"","","","","","","",""," ") //"PROJETO DE         ?"
PUTSX1(CPERG, "02",STR0032," "," ","MV_CH2" ,"C",22,0,0,"G","        "      , "ZA1D"   ,"","","MV_PAR02","","",""," ","","","" ,"","","","","","","",""," ") //"PROJETO ATE        ?"
PUTSX1(CPERG, "03",STR0033," "," ","MV_CH3" ,"C",06,0,0,"G","        "      , "SRAAPT" ,"","","MV_PAR03","","",""," ","","","" ,"","","","","","","",""," ") //"MATRICULA DE       ?"
PUTSX1(CPERG, "04",STR0034," "," ","MV_CH4" ,"C",06,0,0,"G","        "      , "SRAAPT" ,"","","MV_PAR04","","",""," ","","","" ,"","","","","","","",""," ") //"MATRICULA ATE      ?"
PUTSX1(CPERG, "05",STR0035," "," ","MV_CH5" ,"D",08,0,0,"G","        "      , ""       ,"","","MV_PAR05","","",""," ","","","" ,"","","","","","","",""," ") //"DT.INTEGRAวรO DE   ?"
PUTSX1(CPERG, "06",STR0036," "," ","MV_CH6" ,"D",08,0,0,"G","        "      , ""       ,"","","MV_PAR06","","",""," ","","","" ,"","","","","","","",""," ") //"DT.INTEGRAวรO ATE  ?"
PUTSX1(CPERG, "07",STR0037," "," ","MV_CH7" ,"D",08,0,0,"G","        "      , ""       ,"","","MV_PAR07","","",""," ","","","" ,"","","","","","","",""," ") //"VENCTO ASO DE      ?"
PUTSX1(CPERG, "08",STR0038," "," ","MV_CH8" ,"D",08,0,0,"G","        "      , ""       ,"","","MV_PAR08","","",""," ","","","" ,"","","","","","","",""," ") //"VENCTO ASO ATE     ?"
PUTSX1(CPERG, "09",STR0039," "," ","MV_CH9" ,"C",06,0,0,"G","        "      , "SA1"    ,"","","MV_PAR09","","",""," ","","","" ,"","","","","","","",""," ") //"CLIENTE DE         ?"
PUTSX1(CPERG, "10",STR0040," "," ","MV_CHA" ,"C",06,0,0,"G","        "      , "SA1"    ,"","","MV_PAR10","","",""," ","","","" ,"","","","","","","",""," ") //"CLIENTE ATE        ?"
PUTSX1(CPERG, "11",STR0041," "," ","MV_CHB" ,"C",02,0,0,"G","        "      , ""       ,"","","MV_PAR11","","",""," ","","","" ,"","","","","","","",""," ") //"LOJA DE            ?"
PUTSX1(CPERG, "12",STR0042," "," ","MV_CHC" ,"C",02,0,0,"G","        "      , ""       ,"","","MV_PAR12","","",""," ","","","" ,"","","","","","","",""," ") //"LOJA ATE           ?"
PUTSX1(CPERG, "13",STR0043," "," ","MV_CHD" ,"N",01,0,0,"C","        "      , ""       ,"","","MV_PAR13",STR0044,"",""," ",STR0045,"","" ,"","","","","","","",""," ") //"EXPORTA EXCEL      ?"###"SIM"###"NรO"
*/
RETURN NIL
