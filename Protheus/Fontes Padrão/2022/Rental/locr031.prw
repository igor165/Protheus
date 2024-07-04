/*/{PROTHEUS.DOC} LOCR031.PRW 
ITUP BUSINESS - TOTVS RENTAL
RELATำRIO DE RENTABILIDADE
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

FUNCTION LOCR031()
// --> DECLARACAO DE VARIAVEIS.
LOCAL CDESC1  := "RELATำRIO DE RENTABILIDADE "
LOCAL CDESC2  := ""
LOCAL CDESC3  := ""
LOCAL TITULO  := "RELATำRIO DE RENTABILIDADE"
LOCAL NLIN    := 80
LOCAL CABEC1  := "  FILIAL    CLIENTE                                 GESTOR                               AS                             NOTA       SERIE            VLR. N.F.        VLR DO CUSTO   RENTABILIDADE"
LOCAL CABEC2  := ""
               //          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
               //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
               //  XX  
LOCAL AORD    := {"FILIAL","PROJETO","CLIENTE","GESTOR","FROTA"}
LOCAL IMPRIME 

PRIVATE LEND        := .F.
PRIVATE LABORTPRINT := .F.
PRIVATE LIMITE      := 220
PRIVATE TAMANHO     := "G"
PRIVATE NOMEPROG    := "LOCR031" 	// COLOQUE AQUI O NOME DO PROGRAMA PARA IMPRESSAO NO CABECALHO
PRIVATE NTIPO       := 18
PRIVATE ARETURN     := { "ZEBRADO", 1, "ADMINISTRACAO", 2, 2, 1, "", 1}
PRIVATE NLASTKEY    := 0
PRIVATE CPERG       := "LOCP067"
PRIVATE CBTXT       := SPACE(10)
PRIVATE CBCONT      := 00
PRIVATE CONTFL      := 01
PRIVATE M_PAG       := 01
PRIVATE WNREL       := "LOCR031" 	// COLOQUE AQUI O NOME DO ARQUIVO USADO PARA IMPRESSAO EM DISCO
PRIVATE CSTRING     := "FPN"

IMPRIME := .T.

PERGUNTAS()
PERGUNTE(CPERG,.F.)

// --> MONTA A INTERFACE PADRAO COM O USUARIO... 
WNREL := SETPRINT(CSTRING,NOMEPROG,CPERG,@TITULO,CDESC1,CDESC2,CDESC3,.F.,AORD,.F.,TAMANHO,,.F.)

IF NLASTKEY == 27
	RETURN
ENDIF

SETDEFAULT(ARETURN,CSTRING)

IF NLASTKEY == 27
	RETURN
ENDIF

NTIPO := IF(ARETURN[4]==1,15,18)

// --> PROCESSAMENTO. RPTSTATUS MONTA JANELA COM A REGUA DE PROCESSAMENTO.
RPTSTATUS({|| RUNREPORT(CABEC1,CABEC2,TITULO,NLIN) },TITULO)

RETURN



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFUNO    ณ RUNREPORT บ AUTOR ณ IT UP BUSINESS     บ DATA ณ 01/09/2007 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDESCRIO ณ FUNCAO AUXILIAR CHAMADA PELA RPTSTATUS. A FUNCAO RPTSTATUS บฑฑ
ฑฑบ          ณ MONTA A JANELA COM A REGUA DE PROCESSAMENTO.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ PROGRAMA PRINCIPAL                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION RUNREPORT(CABEC1,CABEC2,TITULO,NLIN)

LOCAL NORDEM      := ARETURN[8]
LOCAL _ACOLRAT    := {}
LOCAL _ACOLRENT   := {}
LOCAL _NTOTAL     := 0
LOCAL _CNOMGESTOR := ""
LOCAL _CNOMCLI    := ""
LOCAL _CTIPOSER   := ""
LOCAL _NVLRDESP   := ""    
LOCAL _NCUSTO     := 0
LOCAL _E          := 0 
LOCAL _Y          := 0 

If MV_PAR13 <> 2
	MsgAlert("Tipo de servi็o nใo implementado.","Aten็ใo!")
	Return
EndIf

DBSELECTAREA("FPN")
DBSETORDER(1)
DBGOTOP()
WHILE !EOF()
	
	_GESTOR := POSICIONE("SA1",1,XFILIAL("SA1")+FPN_CLIENT+FPN_LOJA,"A1_VEND")
	_CNF    := POSICIONE("SC5",1,XFILIAL("SC5")+FPN->FPN_NUMPV,"C5_NOTA")
	_CSERIE := POSICIONE("SC5",1,XFILIAL("SC5")+FPN->FPN_NUMPV,"C5_SERIE")
	
	IF FPN->FPN_FILIAL >= MV_PAR09 .AND. FPN->FPN_FILIAL <= MV_PAR10 .AND. ;
	   FPN->FPN_PROJET >= MV_PAR01 .AND. FPN->FPN_PROJET <= MV_PAR02 .AND. ;
	   FPN->FPN_DTINIC >= MV_PAR11 .AND. FPN->FPN_DTINIC <= MV_PAR12 .AND. ;
	   FPN->FPN_CLIENT >= MV_PAR03 .AND. FPN->FPN_CLIENT <= MV_PAR04 .AND. ;
	           _GESTOR >= MV_PAR05 .AND.         _GESTOR <= MV_PAR06 .AND. ;
	       FPN->FPN_AS >= MV_PAR07 .AND. FPN->FPN_AS <= MV_PAR08 .AND. !EMPTY(FPN->FPN_NUMPV)

	   _CNOMGESTOR:= SUBSTR(POSICIONE("SA3",1,XFILIAL("SA3")+_GESTOR , "A3_NOME"),1,40)
	   _CNOMCLI   := SUBSTR(POSICIONE("SA1",1,XFILIAL("SA1")+FPN->(FPN_CLIENT+FPN_LOJA) , "A1_NOME"),1,50)
	   _CTIPOSER  := POSICIONE("FP0",1,XFILIAL("FP0")+FPN->FPN_PROJET , "FP0_TIPOSE")
	   _NVLRDESP  := LOCR03101(FPN->FPN_PROJET)   
	   _NCUSTO	  := LOCR03102(FPN->FPN_PROJET)

		// TIPO SERVICO
		IF ( MV_PAR13 == 1 .AND. _CTIPOSER == 'T' .OR. MV_PAR13 == 5 .AND. _CTIPOSER == 'I') //TRANSPORTE INTERNO OU TRANSPORTES 
			AADD(_ACOLRAT,{FPN->FPN_FILIAL,FPN->FPN_PROJET,_CNOMCLI,FPN->FPN_LOJA,_CNOMGESTOR,FPN->FPN_AS,_CNF, _CSERIE,_NVLRDESP,_NCUSTO})
		ELSEIF ( MV_PAR13 == 2 .AND. _CTIPOSER == 'G' .OR. MV_PAR13 == 4 .AND. _CTIPOSER == 'R' ) //REMOวรO //GUINDASTES
			AADD(_ACOLRAT,{FPN->FPN_FILIAL,FPN->FPN_PROJET,_CNOMCLI,FPN->FPN_LOJA,_CNOMGESTOR,FPN->FPN_AS,_CNF, _CSERIE,_NVLRDESP,_NCUSTO})
		ELSEIF MV_PAR13 == 3 .AND. _CTIPOSER == 'U' //GRUAS
			AADD(_ACOLRAT,{FPN->FPN_FILIAL,FPN->FPN_PROJET,_CNOMCLI,FPN->FPN_LOJA,_CNOMGESTOR,FPN->FPN_AS,_CNF, _CSERIE,_NVLRDESP,_NCUSTO})
		ENDIF
	//	AADD(_ACOLRAT,{FPN->FPN_FILIAL,FPN->FPN_PROJET,FPN->FPN_CLIENT,FPN->FPN_LOJA,_CNOMGESTOR,FPN->FPN_AS,_CNF, _CSERIE})
	ENDIF
	/*	
	IF NORDEM == 1
		IF FPN->FPN_FILIAL >= MV_PAR09  .AND. FPN->FPN_FILIAL <= MV_PAR10 AND. !EMPTY(FPN->FPN_NUMPV)	
			AADD(_ACOLRAT,{FPN->FPN_FILIAL,FPN->FPN_PROJET,FPN->FPN_CLIENT,FPN->FPN_LOJA,_GESTOR,FPN->FPN_AS,_CNF, _CSERIE})
		END IF	
	ENDIF
	IF NORDEM == 2
		IF FPN->FPN_PROJET >= MV_PAR01  .AND. FPN->FPN_PROJET <= MV_PAR02  AND. !EMPTY(FPN->FPN_NUMPV)
			AADD(_ACOLRAT,{FPN->FPN_FILIAL,FPN->FPN_PROJET,FPN->FPN_CLIENT,FPN->FPN_LOJA,_GESTOR,FPN->FPN_AS,_CNF, _CSERIE})
		ENDIF	
	ENDIF
	IF NORDEM == 3
		IF FPN->FPN_CLIENT >= MV_PAR03  .AND. FPN->FPN_CLIENT <= MV_PAR04  AND. !EMPTY(FPN->FPN_NUMPV)
			AADD(_ACOLRAT,{FPN->FPN_FILIAL,FPN->FPN_PROJET,FPN->FPN_CLIENT,FPN->FPN_LOJA,_GESTOR,FPN->FPN_AS,_CNF, _CSERIE})
		ENDIF	
	ENDIF
	IF NORDEM == 4
		IF _GESTOR >= MV_PAR04  .AND. _GESTOR <= MV_PAR05  .AND. !EMPTY(FPN->FPN_NUMPV)
			AADD(_ACOLRAT,{FPN->FPN_FILIAL,FPN->FPN_PROJET,FPN->FPN_CLIENT,FPN->FPN_LOJA,_GESTOR,FPN->FPN_AS,_CNF, _CSERIE})
		ENDIF	
	ENDIF
	IF NORDEM == 5
		IF FPN->FPN_AS >= MV_PAR06  .AND. FPN->FPN_AS <= MV_PAR07 .AND. !EMPTY(FPN->FPN_NUMPV)
			AADD(_ACOLRAT,{FPN->FPN_FILIAL,FPN->FPN_PROJET,FPN->FPN_CLIENT,FPN->FPN_LOJA,_GESTOR,FPN->FPN_AS,_CNF, _CSERIE})
		ENDIF	
	ENDIF
	*/	
	DBSELECTAREA("FPN")
	DBSKIP()
	
ENDDO

_ACOLRAT := ASORT(_ACOLRAT,,,{|X,Y| X[NORDEM] > Y[NORDEM]})

FOR _E := 1 TO LEN(_ACOLRAT)                           
	SETREGUA(RECCOUNT())
	
	DBSELECTAREA("SF2")
	DBSETORDER(1)
	DBGOTOP()
	DBSEEK(XFILIAL("SF2")+_ACOLRAT[_E][7]+_ACOLRAT[_E][8])
	
 //	AADD(_ACOLRENT,{_ACOLRAT[_E][1],_ACOLRAT[_E][2],_ACOLRAT[_E][3],_ACOLRAT[_E][4],_ACOLRAT[_E][5],_ACOLRAT[_E][6],SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_VALFAT,_ACOLRAT[_E][9]})
	AADD(_ACOLRENT,{_ACOLRAT[_E][1],_ACOLRAT[_E][2],_ACOLRAT[_E][3],_ACOLRAT[_E][4],_ACOLRAT[_E][5],_ACOLRAT[_E][6],SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_VALFAT,_ACOLRAT[_E][9],_ACOLRAT[_E][10]})
	
	_NTOTAL:=_NTOTAL+SF2->F2_VALFAT
NEXT _E 

//IF MV_PAR11 == 1
	FOR _Y:=1 TO LEN(_ACOLRENT)

		IF NLIN > 55 // SALTO DE PมGINA. NESTE CASO O FORMULARIO TEM 55 LINHAS...
			CABEC(TITULO,CABEC1,CABEC2,NOMEPROG,TAMANHO,NTIPO)
			NLIN := 8
			@ NLIN,001 PSAY IIF (NORDEM == 1,"FILIAL:"+_ACOLRENT[1][1],IIF (NORDEM == 2,"PROJETO: "+_ACOLRENT[1][2],IIF (NORDEM == 3,"CLIENTE: "+_ACOLRENT[1][3],IIF (NORDEM == 4,"GESTOR: "+_ACOLRENT[1][4],IIF (NORDEM == 5,"FROTA: "+_ACOLRENT[1][5],"")))))
			NLIN := NLIN+2
		ENDIF
    	
		@ NLIN,003 PSAY	_ACOLRENT[_Y][01] 														// FILIAL
		@ NLIN,008 PSAY	_ACOLRENT[_Y][03] 														// CLIENTE
		@ NLIN,052 PSAY	SUBSTR(_ACOLRENT[_Y][05],1,40) 											// GESTOR
		@ NLIN,087 PSAY	_ACOLRENT[_Y][06] 														// FROTA
		@ NLIN,120 PSAY	_ACOLRENT[_Y][07] 														// NOTA
		@ NLIN,134 PSAY	_ACOLRENT[_Y][08] 														// SERIE
		@ NLIN,140 PSAY	_ACOLRENT[_Y][09] PICTURE "@E 999,999,999,999.99" 						// VLR. N.F.
		@ NLIN,158 PSAY	_ACOLRENT[_Y][11] PICTURE "@E 999,999,999,999.99" 						// VLR. CUSTO
		@ NLIN,176 PSAY	_ACOLRENT[_Y][09] - _ACOLRENT[_Y][11] PICTURE "@E 999,999,999,999.99" 	// RENTABILIDADE
		
		NLIN := NLIN+1
	NEXT
	NLIN := NLIN+1
	@ NLIN,001 PSAY REPLICATE("-",LIMITE)
	NLIN := NLIN+1
	@ NLIN,001 PSAY	"TOTAL: "  
	@ NLIN,140 PSAY _NTOTAL   PICTURE"@E 999,999,999,999.99"
	NLIN := NLIN+1
	@ NLIN,001 PSAY REPLICATE("-",LIMITE)
//END IF

/*IF MV_PAR11 == 2
	CABEC1:=""
	CABEC(TITULO,CABEC1,CABEC2,NOMEPROG,TAMANHO,NTIPO)
	NLIN := 8
	
	NLIN := NLIN+2
	@ NLIN,001 PSAY IIF (NORDEM == 1,"FILIAL:"+_ACOLRENT[1][1],IIF (NORDEM == 2,"PROJETO: "+_ACOLRENT[1][2],IIF (NORDEM == 3,"CLIENTE: "+_ACOLRENT[1][3],IIF (NORDEM == 4,"GESTRO: "+_ACOLRENT[1][4],IIF (NORDEM == 5,"FROTA: "+_ACOLRENT[1][5],"")))))
		
	NLIN := NLIN+1
	@ NLIN,001 PSAY REPLICATE("-",LIMITE)
	NLIN := NLIN+1
	@ NLIN,001 PSAY	"TOTAL: "  
	@ NLIN,020 PSAY _NTOTAL PICTURE"@E 999,999,999,999.99"
	NLIN := NLIN+1
	@ NLIN,001 PSAY REPLICATE("-",LIMITE) 
ENDIF*/

// --> FINALIZA A EXECUCAO DO RELATORIO...                    
SET DEVICE TO SCREEN

// --> SE IMPRESSAO EM DISCO, CHAMA O GERENCIADOR DE IMPRESSAO... 
IF ARETURN[5]==1
	DBCOMMITALL()
	SET PRINTER TO
	OURSPOOL(WNREL)
ENDIF

MS_FLUSH()

RETURN ()



// ======================================================================= \\
STATIC FUNCTION PERGUNTAS()
// ======================================================================= \\

LOCAL _I := 0 
LOCAL _J := 0 

_APERGUNTAS := {} 

DBSELECTAREA("SX1") 
DBSETORDER(1) 
CPERG := PADR(CPERG,10) 

AADD(_APERGUNTAS,{CPERG,"01","DO  PROJETO   ?","","","MV_CH1","C",15,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","FP0","","","","","","","","","","","","","","","","",""})
AADD(_APERGUNTAS,{CPERG,"02","ATE PROJETO   ?","","","MV_CH2","C",15,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","FP0","","","","","","","","","","","","","","","","",""})
AADD(_APERGUNTAS,{CPERG,"03","DO  CLIENTE   ?","","","MV_CH3","C",06,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","","","","","","","","","","","","","",""})
AADD(_APERGUNTAS,{CPERG,"04","ATE CLIENTE   ?","","","MV_CH4","C",06,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","","","","","","","","","","","","","",""})
AADD(_APERGUNTAS,{CPERG,"05","DA  GESTOR    ?","","","MV_CH5","C",06,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","SA3","","","","","","","","","","","","","","","","",""})
AADD(_APERGUNTAS,{CPERG,"06","ATE GESTOR    ?","","","MV_CH6","C",06,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","SA3","","","","","","","","","","","","","","","","",""})
AADD(_APERGUNTAS,{CPERG,"07","DA  FROTA     ?","","","MV_CH7","C",15,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","","","","","","","","","","","","","","",""})
AADD(_APERGUNTAS,{CPERG,"08","ATE FROTA     ?","","","MV_CH8","C",15,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","","","","","","","","","","","","","","",""})
AADD(_APERGUNTAS,{CPERG,"09","DA  FILIAL    ?","","","MV_CH9","C",02,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","","","","","","","","","","","","","","",""})
AADD(_APERGUNTAS,{CPERG,"10","ATE FILIAL    ?","","","MV_CHA","C",02,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","","","","","","","","","","","","","","",""})
AADD(_APERGUNTAS,{CPERG,"11","PERIODO DE    ?","","","MV_CHB","D",08,0,0,"G","","MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","","","","","","","","","","","","","","",""})
AADD(_APERGUNTAS,{CPERG,"12","PERIODO ATE   ?","","","MV_CHC","D",08,0,0,"G","","MV_PAR12",""           ,""           ,""           ,"","",""          ,""          ,""          ,"","",""     ,""     ,""     ,"","",""           ,""           ,""           ,"","",""         ,""         ,""         ,"","","" ,"","",""})
AADD(_APERGUNTAS,{CPERG,"13","TIPO DE SERVICO","","","MV_CHD","N",01,0,0,"C","","MV_PAR13","TRANSPORTES","TRANSPORTES","TRANSPORTES","","","EQUIPAMENTOS","EQUIPAMENTOS","EQUIPAMENTOS","","","","","","","","","","","","","","","","","","S","","",""})  
//DD(_APERGUNTAS,{CPERG,"11","RELATำRIO     ?","","","MV_CHB","N",01,0,0,"C","","MV_PAR11","ANALITICO","","","","","SINTษTICO","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

FOR _I:=1 TO LEN(_APERGUNTAS)
	IF SX1->(!DBSEEK(CPERG+STRZERO(_I,2) ))
		RECLOCK("SX1",.T.)    // .T. NOVO
		FOR _J:=1 TO FCOUNT()
			IF _J <= LEN(_APERGUNTAS[_I])
				FIELDPUT(_J,_APERGUNTAS[_I,_J])
			ENDIF
		NEXT _J 
		MSUNLOCK()
	ENDIF
NEXT _I 

RETURN()



// ======================================================================= \\
FUNCTION LOCR03101(_CAUTSERV)
// ======================================================================= \\

LOCAL NVALOR
LOCAL CQUERY := "" 
 
CQUERY := " SELECT SUM(CT2_VALOR) DEBITO "
CQUERY += " FROM " + RETSQLNAME("CT2")
CQUERY += " WHERE  CT2_FILIAL = '"+XFILIAL("CT2")+"' "
CQUERY += "   AND  CT2_CLVLDB = '"+_CAUTSERV+"'"
CQUERY += "   AND  CT2_DATA  BETWEEN '"+DTOS(MV_PAR11)+"' AND '"+DTOS(MV_PAR12)+"'"
CQUERY += "   AND  D_E_L_E_T_ = ' '"
CQUERY := CHANGEQUERY(CQUERY)
IF SELECT("TRB") > 0
	TRB->(DBCLOSEAREA())
ENDIF
TCQUERY CQUERY NEW ALIAS "TRB"

NVALOR := TRB->DEBITO
TRB->(DBCLOSEAREA())

RETURN(NVALOR)                



// ======================================================================= \\
FUNCTION LOCR03102(CPROJE)
// ======================================================================= \\
		
LOCAL _CUSTO := 0
LOCAL CQUERY := ""
 
CQUERY := " SELECT SUM(FP6_VALOR) CUSTO "
CQUERY += " FROM " + RETSQLNAME("FP6")
CQUERY += " WHERE  FP6_FILIAL = '"+XFILIAL("FP6")+"' "
CQUERY += "   AND  FP6_PROJET = '"+CPROJE+"'"
CQUERY += "   AND  D_E_L_E_T_ = ' '"
CQUERY := CHANGEQUERY(CQUERY)
IF SELECT("TRB2") > 0
	TRB2->(DBCLOSEAREA())
ENDIF
TCQUERY CQUERY NEW ALIAS "TRB2"

_CUSTO := TRB2->CUSTO
TRB2->(DBCLOSEAREA())

RETURN(_CUSTO)
