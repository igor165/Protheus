/*/{PROTHEUS.DOC} LOCR010.PRW 
ITUP BUSINESS - TOTVS RENTAL
RELATORIO DO BOLETIM VIAGEM POR MOTORISTA
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "PROTHEUS.CH"     
#INCLUDE "TOPCONN.CH"                                                               

FUNCTION LOCR010()
LOCAL   XALIAS  := GETAREA() 

PRIVATE CCABEC  := ""
PRIVATE CPERG   := "BVMOT1    " 	// CRIAR PERGUNTA

VALIDPERG(CPERG)  					// VERIFICAR PERGUNTAS

// --> VARIAVEIS UTILIZADAS PARA PARAMETROS:
//     MV_PAR01               PROJETO 
//     MV_PAR02               MOTORISTA 
//     MV_PAR03               BOLETIM 
IF PERGUNTE(CPERG,.T.) 				// SOLICITAR PARAMETROS.

	// --> CRIA AS TABELAS TEMPORARIA PARA GERACAO DO RELATORIO. 
	// --> TABELA DE VALES - INCLUIR CAMPOS ( FPI_TOTVLE, FPI_TIMEAB, FPI_TIMEFE ) 
	AVALES:= {{"FPI_NRBV"  ,"C",6,0 },;
              {"FPH_VALOR" ,"N",14,00}}
          
	IF SELECT("TRC") > 0
		DBSELECTAREA("TRC")
		DBCLOSEAREA()
	ENDIF   

	//CRELTRB1 := CRIATRAB(AVALES,.T.)  
	//ITRC1    := CRIATRAB(NIL,.F.)

	// --> PREPARA OS REGISTROS A SEREM IMPRESSOS EM ARQUIVO DE TRABALHO 
	//     PARA IMPRESSAO INDEXADA DE ACORDO COM SOLICITACAO DO USUARIO.
	//DBUSEAREA(.T.,"DBFCDX",CRELTRB1,"TRC",.T.,.F.)
	//INDREGUA("TRC",ITRC1,"FPI_NRBV",,, "ORGANIZANDO ...",.F. )
	// FRANK 23/11/20

	CT1  := "T1"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
	CTI1 := "TI1"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
	IF TCCANOPEN(CT1)
    	TCDELFILE(CT1)
  	ENDIF
	DBCREATE(CT1, AVALES, "TOPCONN")
  	DBUSEAREA(.T., "TOPCONN", CT1, ("TRC"), .F., .F.)
  	DBCREATEINDEX(CTI1, "FPI_NRBV"         , {|| FPI_NRBV         })
  	TRC->( DBCLEARINDEX() ) //FORÇA O FECHAMENTO DOS INDICES ABERTOS
  	DBSETINDEX(CTI1) //ACRESCENTA A ORDEM DE INDICE PARA A ÁREA ABERTA

	//AINDICES := {}
	//AADD(AINDICES,{"FPI_NRBV"})
	//AARQ := LOCXITU06(3, NIL, AVALES, AINDICES)
	//CQUERYSQL := "SELECT FPI_NRBV, FPH_VALOR FROM " + AARQ[3]
	//DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERYSQL), "TRC", .T., .T.)
	//DBCREATEINDEX("T1INDEX1", "FPI_NRBV"         , {|| FPI_NRBV         })

	// --> CHAMADA PARA FUNCAO QUE IRA MONTAR SELECAO DE REGISTROS DE VENDAS.
	MONTAVALE()

	// --> GRAVO REGISTROS NA TABELA TEMPORARIA CONFORME NECESSIDADE.
	DBSELECTAREA("TRB")
	DBGOTOP()

	WHILE !EOF()
		RECLOCK("TRC",.T.)
		FPI_NRBV := TRB->NRBV 
		FPH_VALOR:= TRB->VALE	
		MSUNLOCK()
		DBSELECTAREA("TRB")
		DBSKIP()
	ENDDO 

	// TABELA DE DESPESAS
	ADESP := {{"FPI_NRBV"  , "C" ,6,0 },;
              {"FPK_VLTOT" , "N" ,14,02}}

	IF SELECT("TRE") > 0
		DBSELECTAREA("TRE")
		DBCLOSEAREA()
	ENDIF 

	//CRELTRB2 := CRIATRAB(ADESP,.T.)
	//ITRC2    := CRIATRAB(NIL,.F.)
	//AINDICES := {}
	//AADD(AINDICES,{"FPI_NRBV"})
	//AARQ := LOCXITU06(3, NIL, ADESP, AINDICES)
	//CQUERYSQL := "SELECT FPI_NRBV, FPK_VLTOT FROM " + AARQ[3]
	//DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERYSQL), "TRE", .T., .T.)
	//DBCREATEINDEX("T1INDEX2", "FPI_NRBV"         , {|| FPI_NRBV         })

	CT2 := "T2"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
	CTI2 := "TI2"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
	IF TCCANOPEN(CT2)
    	TCDELFILE(CT2)
  	ENDIF
	DBCREATE(CT2, ADESP, "TOPCONN")
  	DBUSEAREA(.T., "TOPCONN", CT2, ("TRE"), .F., .F.)
  	DBCREATEINDEX(CTI2, "FPI_NRBV"         , {|| FPI_NRBV         })
  	TRE->( DBCLEARINDEX() ) //FORÇA O FECHAMENTO DOS INDICES ABERTOS
  	DBSETINDEX(CTI2) //ACRESCENTA A ORDEM DE INDICE PARA A ÁREA ABERTA


	// --> PREPARA OS REGISTROS A SEREM IMPRESSOS EM ARQUIVO DE TRABALHO 
	//     PARA IMPRESSAO INDEXADA DE ACORDO COM SOLICITACAO DO USUARIO.
	//DBUSEAREA(.T.,"DBFCDX",CRELTRB2,"TRE",.T.,.F.)
	//INDREGUA("TRE",ITRC2,"FPI_NRBV",,, "ORGANIZANDO ...",.F. )

	// --> CHAMADA PARA FUNCAO QUE IRA MONTAR AS DESPESAS.
	MONTADESP()

	// --> GRAVO REGISTROS NA TABELA TEMPORARIA CONFORME NECESSIDADE.
	DBSELECTAREA("TRD")
	DBGOTOP()

	WHILE !EOF()
		RECLOCK("TRE",.T.)
		FPI_NRBV  := TRD->NRBV 
		FPK_VLTOT := TRD->DESPES 
		MSUNLOCK()
		DBSELECTAREA("TRD")
		DBSKIP()
	ENDDO 

	// TABELA DE ABASTECIMENTOS        
	AABAST:=  {{"FPI_NRBV"   ,"C",6,0 },;
              {"ZL5_VLTOT"  ,"N",14,02}}
	
	IF SELECT("TRG") > 0
		DBSELECTAREA("TRG")
		DBCLOSEAREA()
	ENDIF 

	//CRELTRB3 := CRIATRAB(AABAST,.T.)
	//ITRC3    := CRIATRAB(NIL,.F.)

	//AINDICES := {}
	//AADD(AINDICES,{"FPI_NRBV"})
	//AARQ := LOCXITU06(3, NIL, AABAST, AINDICES)
	//CQUERYSQL := "SELECT FPI_NRBV, ZL5_VLTOT FROM " + AARQ[3]
	//DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERYSQL), "TRG", .T., .T.)
	//DBCREATEINDEX("T1INDEX3", "FPI_NRBV"         , {|| FPI_NRBV         })

	CT3 := "T3"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
	CTI3 := "TI3"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
	IF TCCANOPEN(CT3)
    	TCDELFILE(CT3)
  	ENDIF
	DBCREATE(CT3, AABAST, "TOPCONN")
  	DBUSEAREA(.T., "TOPCONN", CT3, ("TRG"), .F., .F.)
  	DBCREATEINDEX(CTI3, "FPI_NRBV"         , {|| FPI_NRBV         })
  	TRG->( DBCLEARINDEX() ) //FORÇA O FECHAMENTO DOS INDICES ABERTOS
  	DBSETINDEX(CTI3) //ACRESCENTA A ORDEM DE INDICE PARA A ÁREA ABERTA

    // --> PREPARA OS REGISTROS A SEREM IMPRESSOS EM ARQUIVO DE TRABALHO 
    //     PARA IMPRESSAO INDEXADA DE ACORDO COM SOLICITACAO DO USUARIO.
    //DBUSEAREA(.T.,"DBFCDX",CRELTRB3,"TRG",.T.,.F.)
    //INDREGUA("TRG",ITRC3,"FPI_NRBV",,, "ORGANIZANDO ...",.F. )

	// --> CHAMADA PARA FUNCAO QUE IRA MONTAR AS DESPESAS.
	MONTAABAST()

	// --> GRAVO REGISTROS NA TABELA TEMPORARIA CONFORME NECESSIDADE.
	DBSELECTAREA("TRF")
	DBGOTOP()

	WHILE !EOF()
		RECLOCK("TRG",.T.)
		FPI_NRBV := TRF->NRBV
		ZL5_VLTOT:= TRF->ABAST
		MSUNLOCK()
		DBSELECTAREA("TRF")
		DBSKIP()
	ENDDO 

    // MONTA QUERY
	MONTAQRY()
   
	IF QRY->(EOF()) 
		MSGALERT("NÃO EXISTE DADOS PARA A IMPRESSÃO" , "GPO - LOCI021.PRW") 
		RETURN                                                                                        
		QRY->(DBCLOSEAREA())
    ENDIF 
   
    // --> SELECAO DA IMPRESSORA. 
    OOBJPRINT:= TMSPRINTER():NEW(CCABEC)
    OOBJPRINT:SETSIZE( 210, 297 )
    OOBJPRINT:SETUP()   
   
    LJMSGRUN("POR FAVOR AGUARDE, IMPRIMINDO BOLETINS O DO MOTORISTA...",,{|| IMPBVM()})

    // --> MOSTRA RELATORIO PARA IMPRIMIR.
    OOBJPRINT:SETSIZE( 210, 297 )
    OOBJPRINT:PREVIEW()
    RESTAREA(XALIAS)   
                     
    QRY->(DBCLOSEAREA())

    TRB->(DBCLOSEAREA())
    TRF->(DBCLOSEAREA())
    TRD->(DBCLOSEAREA())

	TCSQLEXEC("DROP TABLE "+CT1)
	TCSQLEXEC("DROP TABLE "+CTI1)
	TCSQLEXEC("DROP TABLE "+CT2)
	TCSQLEXEC("DROP TABLE "+CTI2)
	TCSQLEXEC("DROP TABLE "+CT3)
	TCSQLEXEC("DROP TABLE "+CTI3)
	

    
    //FERASE(CRELTRB1+GETDBEXTENSION())
    //FERASE(CRELTRB2+GETDBEXTENSION())
    //FERASE(CRELTRB3+GETDBEXTENSION())
    //FERASE (ITRC1+ORDBAGEXT())
    //FERASE (ITRC2+ORDBAGEXT())
    //FERASE (ITRC3+ORDBAGEXT())
    
ENDIF 

RETURN(NIL)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ IMPBVM    º AUTOR ³ IT UP BUSINESS     º DATA ³ 21/04/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION IMPBVM()

PRIVATE OFONTE01	:= NIL
PRIVATE OFONTE02	:= NIL
PRIVATE OFONTE03	:= NIL
PRIVATE OFONTE04	:= NIL
PRIVATE OFONTE05	:= NIL
PRIVATE OFONTE06	:= NIL
PRIVATE OFONTE07	:= NIL
PRIVATE OFONTE08    := NIL
PRIVATE NLINHAATUAL := 0
PRIVATE NNUMPAGINA	:= 0

// --> INICIALIZA OBJETOS DA CLASSE TMSPRINTER. 
OFONTE01 := TFONT():NEW("ARIAL",12,20,,.T.,,,16,.F.)
OFONTE02 := TFONT():NEW("ARIAL",06,10,,.T.,,,08,.F.)
OFONTE03 := TFONT():NEW("ARIAL",10,14,,.T.,,,08,.F.)
OFONTE04 := TFONT():NEW("ARIAL",10,12,,.F.,,,08,.F.)
OFONTE05 := TFONT():NEW("ARIAL",08,09,,.T.,,,08,.F.)
OFONTE06 := TFONT():NEW("ARIAL",06,09,,.T.,,,08,.F.)
OFONTE07 := TFONT():NEW("ARIAL",06,20,,.T.,,,08,.F.)
OFONTE08 := TFONT():NEW("ARIAL",06,-11,,.F.,,,08,.F.)

NNUMPAGINA  := 0
NLINHAATUAL := 0
CUSER       := "" 
LFIRST      := .T.

// IMPRESSÃO DE CABEÇARIO PADRAO E VALES
_FLAGIMP   := .T.
LINHAATUAL := 0
IMP_CABEC2("V"/*,@LINHAATUAL*/)
LINHAATUAL := LINHAATUAL + 50 
    
DBSELECTAREA("QRY")
DBGOTOP()
    
_TOTDESP := 0
_TOTVALE := 0
_TOTSALD := 0
_TOTABAS := 0
    
WHILE ! EOF()                                       
	LINHAATUAL :=LINHAATUAL + 50  
	IF 	LINHAATUAL > 3400
		IMP_CABEC2("T"/*,@LINHAATUAL*/)
		LINHAATUAL := LINHAATUAL + 50  
	ENDIF   
        
	_DIAS   := 0
	_DOCORI := SPACE(25)
	ZL6->(DBSEEK(XFILIAL("ZL6")+QRY->NRBV))
	WHILE ZL6->(!EOF()) .AND. ZL6->ZL6_NRBV=QRY->NRBV
    	_DIAS+=ZL6->ZL6_DTFIM-ZL6->ZL6_DTINI
		_DOCORI:=ZL6->ZL6_ORIGEM
		ZL6->(DBSKIP())
	ENDDO 
        
	// PESQUISA O VALE 
	_VALE := 0
	//TRC->(DBGOTOP())
	//WHILE !TRC->(EOF())
	//	IF TRC->FPI_NRBV == QRY->NRBV
	//		_VALE := TRC->FPH_VALOR
	//		EXIT
	//	ENDIF
	//	TRC->(DBSKIP())
	//ENDDO
	IF TRC->(DBSEEK(QRY->NRBV))
		_VALE := TRC->FPH_VALOR
	ENDIF
        
	// PESQUISA O VALE 
	// TABELA DE DESPESAS
	_DESP := 0
	IF TRE->(DBSEEK(QRY->NRBV))
		_DESP := TRE->FPK_VLTOT
	ENDIF
	//TRE->(DBGOTOP())
	//WHILE !TRE->(EOF())
	//	IF TRE->FPI_NRBV == QRY->NRBV
	//		_DESP := TRE->FPK_VALOR
	//		EXIT
	//	ENDIF
	//	TRE->(DBSKIP())
	//ENDDO
             
	_ABAS := 0
	IF TRG->(DBSEEK(QRY->NRBV))
		_ABAS := TRG->ZL5_VLTOT
	ENDIF
	//TRG->(DBGOTOP())
	//WHILE !TRG->(EOF())
	//	IF TRG->FPI_NRBV == QRY->NRBV
	//		_ABAS := TRG->ZL5_VALOR
	//		EXIT
	//	ENDIF
	//	TRG->(DBSKIP())
	//ENDDO
      
	_DIAS := STR(_DIAS,4)
	OOBJPRINT:SAY(LINHAATUAL, 0060 , DTOC(QRY->DTABERT) ,OFONTE02 , 100 )      
	OOBJPRINT:SAY(LINHAATUAL, 0291 , DTOC(QRY->DTFECH)  ,OFONTE02 , 100 )
	OOBJPRINT:SAY(LINHAATUAL, 0553 , QRY->NRBV          ,OFONTE02 , 100 )
	OOBJPRINT:SAY(LINHAATUAL, 0805 , SUBSTR(QRY->FROTA,1,16),OFONTE02 , 100 )
	OOBJPRINT:SAY(LINHAATUAL, 1200 , PADR(TRANSFORM(_DESP,"@E 9999,999.99"),12)         , OFONTE02 , 100 )  // TRANSFORM(QRY->DESPES,"@E 99,999.99")
	OOBJPRINT:SAY(LINHAATUAL, 1436 , PADR(TRANSFORM(_VALE,"@E 9999,999.99"),12)         , OFONTE02 , 100 ) 	// TRANSFORM(QRY->VALE,"@E 999,999.99")
	OOBJPRINT:SAY(LINHAATUAL, 1692 , PADR(TRANSFORM((_VALE-_DESP),"@E 9999,999.99"),12) , OFONTE02 , 100 ) 	// SALDO   
 //	OOBJPRINT:SAY(LINHAATUAL, 1928 , PADR(TRANSFORM(_ABAS,"@E 9999,999.99"),12)         , OFONTE02 , 100 )	// TRANSFORM(QRY->ABAST,"@E 999,999.99")
	OOBJPRINT:SAY(LINHAATUAL, 1928/*2170*/ , _DIAS                                      , OFONTE02 , 100 )	// TRANSFORM(QRY->ABAST,"@E 999,999.99")
	OOBJPRINT:SAY(LINHAATUAL, 2170/*2360*/ , _DOCORI                                    , OFONTE02 , 100 )  // DIAS 
    	
	_TOTDESP += _DESP
	_TOTVALE += _VALE
	_TOTSALD += (_VALE-_DESP)
	_TOTABAS += _ABAS
        	                                       
	DBSKIP() 
ENDDO                                  
    
LINHAATUAL :=LINHAATUAL + 50  
IF 	LINHAATUAL > 3400
	IMP_CABEC2("T"/*,@LINHAATUAL*/)
	LINHAATUAL :=LINHAATUAL + 50  
ENDIF   

OOBJPRINT:SAY(LINHAATUAL  , 0020  , REPLICATE("_",165),OFONTE02 , 100 ) 
LINHAATUAL :=LINHAATUAL + 50  
IF 	LINHAATUAL > 3400
	IMP_CABEC2("T"/*,@LINHAATUAL*/)
	LINHAATUAL :=LINHAATUAL + 50  
ENDIF   

OOBJPRINT:SAY(LINHAATUAL , 0060  , "TOTAL MOTORISTA: " ,OFONTE03 , 100 )
OOBJPRINT:SAY(LINHAATUAL, 1200 , PADR(TRANSFORM(_TOTDESP,"@E 9999,999.99"),12)       ,OFONTE02 , 100 )  // TRANSFORM(QRY->DESPES,"@E 99,999.99")
OOBJPRINT:SAY(LINHAATUAL, 1436 , PADR(TRANSFORM(_TOTVALE,"@E 9999,999.99"),12)         ,OFONTE02 , 100 ) // TRANSFORM(QRY->VALE,"@E 999,999.99")
OOBJPRINT:SAY(LINHAATUAL, 1692 , PADR(TRANSFORM(_TOTSALD,"@E 9999,999.99"),12)               ,OFONTE02 , 100 ) // SALDO   
    
LINHAATUAL :=LINHAATUAL + 100
    
IMP_CABEC2("X"/*,@LINHAATUAL*/)
                                                 
RETURN 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ VALIDPERG º AUTOR ³ IT UP BUSINESS     º DATA ³ 16/04/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ CRIA GRUPO DE PERGUNTAS                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION VALIDPERG(CPERG)
RETURN(NIL)



// ======================================================================= \\
STATIC FUNCTION MONTAQRY()     
// ======================================================================= \\
// --> MONTA QUERY DE MOTORISTAS
// --> CRIA AS TABELAS TEMPORARIA PARA GERACAO DO RELATORIO.     ³
IF SELECT("QRY") > 0
	DBSELECTAREA("QRY")
	DBCLOSEAREA()
ENDIF 

CQUERY     := "SELECT DISTINCT FPI_NRBV NRBV  ,  FPI_MOTORI , FPI_NOMMOT ,  FPI_DTABER  DTABERT,FPI_DTFECH DTFECH,FPI_FROTA FROTA  "
CQUERY     += "FROM "+RETSQLNAME("FPI")+" ZL2 "
CQUERY     += "WHERE  FPI_MOTORI = '"+MV_PAR01+"'  AND " 
IF MV_PAR04=1
	CQUERY +=      "  FPI_DTABER BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'  AND "
ELSE
	CQUERY +=      "  FPI_DTFECH BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'  AND "
ENDIF       
IF MV_PAR04=1
	CQUERY +=      "  FPI_STATUS = '"+"A"+"'  AND "
ELSE      
	CQUERY +=      " (FPI_STATUS = 'F' OR FPI_STATUS = 'P') AND "    
ENDIF
CQUERY     +=      "  ZL2.D_E_L_E_T_ = '  ' "
CQUERY     += "GROUP BY FPI_NRBV , FPI_MOTORI , FPI_NOMMOT , FPI_DTABER , FPI_DTFECH , FPI_FROTA " 
CQUERY     += "ORDER BY FPI_NRBV "
CQUERY     := CHANGEQUERY(CQUERY)                                                   
TCQUERY CQUERY NEW ALIAS "QRY"

TCSETFIELD("QRY","DTABERT","D")                               
TCSETFIELD("QRY","DTFECH" ,"D")                               

RETURN                      



// ======================================================================= \\
STATIC FUNCTION IMP_CABEC2(_SUBC)
// ======================================================================= \\

IF 	LINHAATUAL > 3400 .OR. _FLAGIMP

    IMP_CABEC(@NNUMPAGINA,@NLINHAATUAL,CUSER,1)      

	IF CEMPANT == "07"    
    	OOBJPRINT:SAYBITMAP( -100, 005,"LGJSM.BMP"   , 290, 0500 ) //553 X 224 480
	ELSE
		OOBJPRINT:SAYBITMAP( -100, 005,"LOGO.BMP"   , 290, 0500 ) //553 X 224 480
	ENDIF                                    
	
    OOBJPRINT:SAY(050  , 0550 , IIF(MV_PAR04=2,"BOLETINS FECHADO POR MOTORISTA","BOLETINS ABERTO POR MOTORISTA")  , OFONTE01   , 100 )
    OOBJPRINT:SAY(150  , 1050 ,  "PERIODO DE "+DTOC(MV_PAR02)+" A "+DTOC(MV_PAR03)  , OFONTE01   , 100 )
    OOBJPRINT:SAY(180  , 0255 , "IMPRESSO EM : "+DTOC( DDATABASE )+" AS "+ TIME() , OFONTE02 , 100 )
    OOBJPRINT:SAY(265  , 0020 , REPLICATE("_",165),OFONTE02 , 100 ) 
  
    // MOTORISTA                                              
    MOTORISTA:=QRY->FPI_NOMMOT
    OOBJPRINT:SAY( 320  , 0060  , "MOTORISTA: " + ALLTRIM(QRY->FPI_MOTORI) + " - " + ALLTRIM(QRY->FPI_NOMMOT) ,OFONTE03 , 100 )
    OOBJPRINT:SAY( 390  , 0060  , "ABERTURA"      , OFONTE02 , 100 )
    OOBJPRINT:SAY( 390  , 0275  , "FECHAMENTO"    , OFONTE02 , 100 )
    OOBJPRINT:SAY( 390  , 0542  , "NUMERO B.V "   , OFONTE02 , 100 )
    OOBJPRINT:SAY( 390  , 0805  , "FROTA"         , OFONTE02 , 100 )
    OOBJPRINT:SAY( 390  , 1190  , "VLR.DESP."     , OFONTE02 , 100 )
    OOBJPRINT:SAY( 390  , 1425  , "VLR.VALE"      , OFONTE02 , 100 )    
    OOBJPRINT:SAY( 390  , 1660  , "VLR.SALDO"     , OFONTE02 , 100 )  
 //	OOBJPRINT:SAY( 390  , 1895  , "VLR.ABASTEC"   , OFONTE02 , 100 )
    OOBJPRINT:SAY( 390  , 1895/*2130*/ , "QTD.DIAS"   , OFONTE02 , 100 )
    OOBJPRINT:SAY( 390  , 2130/*2320*/ , "DOC.ORIGEM" , OFONTE02 , 100 )
    OOBJPRINT:SAY( 390  , 2320/*2740*/ , "NOME"       , OFONTE02 , 100 )
  
    OOBJPRINT:SAY(397 , 0060  , REPLICATE("_",08),OFONTE02 , 100 ) 
    OOBJPRINT:SAY(397 , 0275  , REPLICATE("_",10),OFONTE02 , 100 ) 
    OOBJPRINT:SAY(397 , 0542  , REPLICATE("_",12),OFONTE02 , 100 ) 
    OOBJPRINT:SAY(397 , 0805  , REPLICATE("_",16),OFONTE02 , 100 ) 
    OOBJPRINT:SAY(397 , 1190  , REPLICATE("_",10),OFONTE02 , 100 ) 
    OOBJPRINT:SAY(397 , 1425  , REPLICATE("_",10),OFONTE02 , 100 ) 
    OOBJPRINT:SAY(397 , 1660  , REPLICATE("_",10),OFONTE02 , 100 ) 
 //	OOBJPRINT:SAY(397 , 1895  , REPLICATE("_",10),OFONTE02 , 100 ) 
    OOBJPRINT:SAY(397 , 1895  , REPLICATE("_",08),OFONTE02 , 100 ) 
    OOBJPRINT:SAY(397 , 2130  , REPLICATE("_",20),OFONTE02 , 100 ) 
    OOBJPRINT:SAY(397 , 2320  , REPLICATE("_",20),OFONTE02 , 100 ) 
     
    _FLAGIMP := .F.
    LINHAATUAL := 380
ENDIF                                                         

RETURN .T.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ IMP_CABEC º AUTOR ³ IT UP BUSINESS     º DATA ³ 16/04/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ IMPRESSAO DO CABECALHO DA PAGINA DO RELATORIO              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION IMP_CABEC(NNUMPAGINA,NLINHAATUAL,CUSER,NVIAS)

NNUMPAGINA += 1
IF !LFIRST
	OOBJPRINT:ENDPAGE()
	OOBJPRINT:STARTPAGE()
ENDIF                                      

LFIRST := .F.

RETURN(.T.)



// ======================================================================= \\
STATIC FUNCTION MONTADESP()
// ======================================================================= \\
// --> TABELA DE DESPESAS
IF SELECT("TRD") > 0
	DBSELECTAREA("TRD")
	DBCLOSEAREA()
ENDIF

CQUERY     := "SELECT DISTINCT FPI_NRBV NRBV  , SUM (FPK_VLTOT) DESPES  "
CQUERY     += "FROM "+RETSQLNAME("FPI")+" ZL2 , "+RETSQLNAME("FPK")+" ZL4 "
CQUERY     += "WHERE  FPI_MOTORI = '"+MV_PAR01+"'  AND "
IF MV_PAR04=1
	CQUERY +=      "  FPI_DTABER BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'  AND "
ELSE
	CQUERY +=      "  FPI_DTFECH BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'  AND "
ENDIF   
IF MV_PAR04=1
	CQUERY +=      "  FPI_STATUS = '"+"A"+"'  AND "
ELSE      
	CQUERY +=      " (FPI_STATUS = 'F' OR FPI_STATUS = 'P') AND "    
ENDIF
CQUERY     +=      " (FPK_NRBV = FPI_NRBV OR FPK_NRBV = '') AND "
CQUERY     +=      "  ZL2.D_E_L_E_T_ = '  '  AND "
CQUERY     +=      "  ZL4.D_E_L_E_T_ = '  '  "                            
CQUERY     += "GROUP BY FPI_NRBV "
CQUERY     += "ORDER BY FPI_NRBV "
CQUERY     := CHANGEQUERY(CQUERY)
TCQUERY CQUERY NEW ALIAS "TRD"

RETURN
  


// ======================================================================= \\
STATIC FUNCTION MONTAVALE()
// ======================================================================= \\
// --> TABELA DE VALES
IF SELECT("TRB") > 0
	DBSELECTAREA("TRB")
	DBCLOSEAREA()
ENDIF
CQUERY     := "SELECT DISTINCT FPI_NRBV NRBV , SUM(FPH_VALOR)VALE "
CQUERY     += "FROM "+RETSQLNAME("FPI")+" ZL2 , "+RETSQLNAME("FPH")+" ZL1 "
CQUERY     += "WHERE  FPI_MOTORI = '"+MV_PAR01+"'  AND "
IF MV_PAR04=1
	CQUERY +=      "  FPI_DTABER BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'  AND "
ELSE
	CQUERY +=      "  FPI_DTFECH BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'  AND "
ENDIF   
IF MV_PAR04=1
	CQUERY +=      "  FPI_STATUS = '"+"A"+"'  AND "
ELSE      
	CQUERY +=      " (FPI_STATUS = 'F' OR FPI_STATUS = 'P') AND "    
ENDIF
CQUERY     +=      " (FPH_NRBV = FPI_NRBV OR FPH_NRBV = '') AND "
CQUERY     +=      "  ZL2.D_E_L_E_T_ = '  '  AND "
CQUERY     +=      "  ZL1.D_E_L_E_T_ = '  '  "
CQUERY     += "GROUP BY FPI_NRBV "
CQUERY     += "ORDER BY FPI_NRBV "
CQUERY     := CHANGEQUERY(CQUERY)                      
TCQUERY CQUERY NEW ALIAS "TRB"

RETURN



// ======================================================================= \\
STATIC FUNCTION MONTAABAST()
// ======================================================================= \\
// --> TABELA DE ABASTECIMENTOS
IF SELECT("TRF") > 0
	DBSELECTAREA("TRF")
	DBCLOSEAREA()
ENDIF 
CQUERY     := "SELECT DISTINCT FPI_NRBV NRBV  , SUM(ZL5_VLTOT) ABAST  "
CQUERY     += "FROM "+RETSQLNAME("FPI")+" ZL2 , "+RETSQLNAME("ZL5")+" ZL5  "
CQUERY     += "WHERE  FPI_MOTORI = '"+MV_PAR01+"'  AND 
IF MV_PAR04=1
	CQUERY +=      "  FPI_DTABER BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'  AND "
ELSE
	CQUERY +=      "  FPI_DTFECH BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'  AND "
ENDIF   
IF MV_PAR04=1
	CQUERY +=      "  FPI_STATUS = '"+"A"+"'  AND "
ELSE      
	CQUERY +=      " (FPI_STATUS = 'F' OR FPI_STATUS = 'P') AND "    
ENDIF
CQUERY     +=      " (ZL5_NRBV = FPI_NRBV OR ZL5_NRBV = '') AND "
CQUERY     +=      "  ZL2.D_E_L_E_T_ = '  '  AND "
CQUERY     +=      "  ZL5.D_E_L_E_T_ = '  '   "
CQUERY     += "GROUP BY FPI_NRBV "
CQUERY     += "ORDER BY FPI_NRBV "
CQUERY     := CHANGEQUERY(CQUERY)
TCQUERY CQUERY NEW ALIAS "TRF"    

RETURN
