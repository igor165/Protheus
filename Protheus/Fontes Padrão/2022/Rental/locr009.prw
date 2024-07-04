#INCLUDE "locr009.ch" 
/*/{PROTHEUS.DOC} LOCR009.PRW
ITUP BUSINESS - TOTVS RENTAL
Relatуrio quadro resumo
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"     
#INCLUDE "RWMAKE.CH"     
#INCLUDE "TOPCONN.CH"                                                                                        

FUNCTION LOCR009()
	PRIVATE OREPORT
	PRIVATE CTITULO := STR0001 //"QUADRO RESUMO"
	PRIVATE OBREAK
	PRIVATE	NTGOCU	:=	0
	PRIVATE	NTGDISP	:=	0
	PRIVATE NTOCU	:=	0
	PRIVATE NTDISP	:=	0

	IF TREPINUSE()   
		IF PERGPARAM("LOCR009")
			OREPORT := REPORTDEF()
			IF MV_PAR11 == 2
				OREPORT:SETLANDSCAPE()
			ENDIF
			//OREPORT:SETDEVICE(4)    // MODO DEFAULT DE IMPRESSПїЅO  4 = PLANILHA
			OREPORT:PRINTDIALOG()
		ENDIF
	ENDIF       

RETURN                 
/*ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅДїПїЅПїЅ
ПїЅПїЅПїЅFUNCAO    ПїЅ REPORTDEFПїЅ AUTOR ПїЅ MIGUEL GONTIJO        ПїЅ DATA ПїЅ09/02/2017ПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅДґПїЅПїЅ
ПїЅПїЅПїЅDESCRICAO ПїЅ DEFINICAO DO LAYOUT DO RELATORIO                           ПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅЩ±ПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅ*/ 
STATIC FUNCTION REPORTDEF()

	LOCAL OSECTION
	LOCAL OSECTION1
	LOCAL OSECTION2

	PRIVATE CFILBRK := CFILANT

	//ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅДї
	//ПїЅCRIACAO DO COMPONENTE DE IMPRESSAO                                      ПїЅ
	//ПїЅ                                                                        ПїЅ
	//ПїЅTREPORT():NEW                                                           ПїЅ
	//ПїЅEXPC1 : NOME DO RELATORIO                                               ПїЅ
	//ПїЅEXPC2 : TITULO                                                          ПїЅ
	//ПїЅEXPC3 : PERGUNTE                                                        ПїЅ
	//ПїЅEXPB4 : BLOCO DE CODIGO QUE SERA EXECUTADO NA CONFIRMACAO DA IMPRESSAO  ПїЅ
	//ПїЅEXPC5 : DESCRICAO                                                       ПїЅ
	//ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅ
	OREPORT  := TREPORT():NEW("LOCR009",CTITULO,"LOCR009",{|OREPORT| PRINTREPORT()},CTITULO)
	//OREPORT:NFONTBODY    := 10
	//OREPORT:CFONTBODY    := "CALIBRI"
	//OREPORT:LUNDERLINE := .F.
	OREPORT:TOTALINLINE(.F.)	// IMPRIME TOTAL EM LINHA OU COLUNA (DEFAULT .T. - LINHA )
	//SETBORDER(UBORDER,NWEIGHT,NCOLOR,LHEADER)
	OREPORT:LPARAMPAGE := .F.
	OREPORT:LPRTPARAMPAGE := .F.
	OREPORT:UPARAM := {|| PERGPARAM("LOCR009") }

	IF MV_PAR11 == 1

		OSECTION := TRSECTION():NEW(OREPORT) //,"PROJETOS",{"ST9","SHB"})
		TRCELL():NEW(OSECTION,"CENTRAB"	,"ST9","", , 60		)
		//OREPORT:SKIPLINE()
		//	OREPORT:THINLINE()
		//OSECTION :SETLINESTYLE(.F.)

		OSECTION1 := TRSECTION():NEW(OREPORT) // ,"PROJETOS",{"ST9","SHB"})
		TRCELL():NEW(OSECTION1,"T9_CODFAMI"	,"ST9",RETTITLE("T9_CODFAMI"), , 30	)
		TRCELL():NEW(OSECTION1,"T6_NOME"	,"ST9",RETTITLE("T6_NOME"), , 30	)
		TRCELL():NEW(OSECTION1,"QTDBEM"		,"ST9",STR0002		, , 10		) //"QTD. BEM"
		TRCELL():NEW(OSECTION1,"DISP"		,"ST9",STR0003		, , 15		) //"DISPONIVEL"
		TRCELL():NEW(OSECTION1,"CON"		,"ST9",STR0004	, , 15		) //"EM CONTRATO"
		//TRCELL():NEW(OSECTION1,"MNT"		,"ST9","MANUTENCAO"		, , 15		)
		//TRCELL():NEW(OSECTION1,"NFRR"		,"ST9","INSPECAO"		, , 15		)
		TRCELL():NEW(OSECTION1,"NFRE"		,"ST9",STR0005			, , 15		) //"LOCADO"
		//TRCELL():NEW(OSECTION1,"TRE"		,"ST9","EM TRANSITO"	, , 15		)
		//TRCELL():NEW(OSECTION1,"ENT"		,"ST9","ENTREGUE"		, , 15		)
		TRCELL():NEW(OSECTION1,"SRT"		,"ST9",STR0006 , , 20		) //"SOLIC.RETIRADA"
		//TRCELL():NEW(OSECTION1,"PAR"		,"ST9","EM PARCEIRO"	, , 15		)
		TRCELL():NEW(OSECTION1,"OTR"		,"ST9",STR0007			, , 15		) //"OUTROS"
		TRCELL():NEW(OSECTION1,"OCUP"		,"ST9",STR0008		, , 15		) //"OCUPACAO %"
		/*
		OSECTION1:CELL("QTDBEM"	):SETALIGN("CENTER")	
		OSECTION1:CELL("DISP"	):SETALIGN("CENTER")
		OSECTION1:CELL("CON"	):SETALIGN("CENTER")
		OSECTION1:CELL("NFRE"	):SETALIGN("CENTER")
		OSECTION1:CELL("TRE"	):SETALIGN("CENTER")
		OSECTION1:CELL("NFRR"	):SETALIGN("CENTER")
		OSECTION1:CELL("OCUP"	):SETALIGN("CENTER")
		OSECTION1:CELL("ENT"	):SETALIGN("CENTER")
		OSECTION1:CELL("SRT"	):SETALIGN("CENTER")
		OSECTION1:CELL("PAR"	):SETALIGN("CENTER")
		OSECTION1:CELL("OTR"	):SETALIGN("CENTER")	
		OSECTION1:CELL("MNT"	):SETALIGN("CENTER")
		*/
		OBREAK := TRBREAK():NEW(OSECTION1,OSECTION:CELL("CENTRAB"),STR0009) //"SUB TOTAIS"

		TREPORT():TOTALINLINE(.T.)		// IMPRIME TOTAL EM LINHA OU COLUNA (DEFAULT .T. - LINHA )   
		TRFUNCTION():NEW(OSECTION1:CELL("QTDBEM") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 	
		TRFUNCTION():NEW(OSECTION1:CELL("DISP") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 	
		TRFUNCTION():NEW(OSECTION1:CELL("CON") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION1:CELL("MNT") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION1:CELL("NFRR") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		TRFUNCTION():NEW(OSECTION1:CELL("NFRE") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION1:CELL("TRE") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION1:CELL("ENT") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		TRFUNCTION():NEW(OSECTION1:CELL("SRT") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION1:CELL("PAR") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		TRFUNCTION():NEW(OSECTION1:CELL("OTR") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 		
		TRFUNCTION():NEW(OSECTION1:CELL("OCUP"),NIL,"ONPRINT",OBREAK,,,{|| ROUND((NTGOCU/NTGDISP)*100,2) },.F.,.T.) 		

	ELSEIF MV_PAR11 == 2

		//OSECTION := TRSECTION():NEW(OREPORT ,STR0010,{"FQ4"}) //"PROJETOS"
		OSECTION := TRSECTION():NEW(OREPORT ,STR0011,{"FQ4"}) //"PROJETOS"
		TRCELL():NEW(OSECTION,"T9_CODFAMI"	,"FQ4",STR0011 , PESQPICT("ST9","T9_CODFAMI"	) , 60 /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ ) //"FAMILIA"
		TRCELL():NEW(OSECTION,"DISP"		,"ST9",STR0003		, , 15		) //"DISPONIVEL"
		TRCELL():NEW(OSECTION,"CON"		,"ST9",STR0004	, , 15		) //"EM CONTRATO"
		//TRCELL():NEW(OSECTION,"MNT"		,"ST9","MANUTENCAO"		, , 15		)
		//TRCELL():NEW(OSECTION,"NFRR"		,"ST9","INSPECAO"		, , 15		)
		TRCELL():NEW(OSECTION,"NFRE"		,"ST9","LOCADO"			, , 15		)
		//TRCELL():NEW(OSECTION,"TRE"		,"ST9","EM TRANSITO"	, , 15		)
		//TRCELL():NEW(OSECTION,"ENT"		,"ST9","ENTREGUE"		, , 15		)
		TRCELL():NEW(OSECTION,"SRT"		,"ST9",STR0006 , , 20		) //"SOLIC.RETIRADA"
		//TRCELL():NEW(OSECTION,"PAR"		,"ST9","EM PARCEIRO"	, , 15		)
		TRCELL():NEW(OSECTION,"OTR"		,"ST9",STR0007			, , 15		) //"OUTROS"
		TRCELL():NEW(OSECTION,"OCUP"		,"ST9",STR0008		, , 15		) //"OCUPACAO %"

		OSECTION1 := TRSECTION():NEW(OREPORT) // ,"PROJETOS",{"ST9","SHB"})
		TRCELL():NEW(OSECTION1,"T9_CODBEM"	,"FQ4","" , PESQPICT("ST9","T9_CODBEM"	) , 60 /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )

		//OSECTION2 := TRSECTION():NEW(OREPORT ,STR0010,{"FQ4"}) //"PROJETOS"
		OSECTION2 := TRSECTION():NEW(OREPORT ,STR0013,{"FQ4"}) //"PROJETOS"
		TRCELL():NEW(OSECTION2,"T9_STATUS"	,"FQ4",RETTITLE("T9_STATUS") , PESQPICT("TQY","TQY_DESTAT"	) , 10 , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"T9_CODFAMI"	,"FQ4",RETTITLE("T9_CODFAMI") , PESQPICT("ST9","T9_CODFAMI"	) , 10 , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"T9_TIPMOD"	,"FQ4",RETTITLE("T9_TIPMOD") , PESQPICT("ST9","T9_TIPMOD"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"T9_FABRICA"	,"FQ4",RETTITLE("T9_FABRICA") , PESQPICT("ST9","T9_FABRICA"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		//TRCELL():NEW(OSECTION2,"T9_XSUBLOC"	,"FQ4",RETTITLE("T9_XSUBLOC") , PESQPICT("ST9","T9_XSUBLOC"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		//TRCELL():NEW(OSECTION1,"FQ4_POSCON"	,"FQ4",RETTITLE("FQ4_POSCON") , PESQPICT("FQ4","FQ4_POSCON"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"HB_COD"	,"FQ4",RETTITLE("HB_COD") , PESQPICT("SHB","HB_COD"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"HB_NOME"	,"FQ4",RETTITLE("HB_NOME") , PESQPICT("SHB","HB_NOME"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_OS"		,"FQ4",RETTITLE("FQ4_OS"	) , PESQPICT("FQ4","FQ4_OS"		) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_SERVIC"	,"FQ4",RETTITLE("FQ4_SERVIC") , PESQPICT("FQ4","FQ4_SERVIC"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_PRELIB"	,"FQ4",RETTITLE("FQ4_PRELIB") , PESQPICT("FQ4","FQ4_PRELIB"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_CODCLI"	,"FQ4",RETTITLE("FQ4_CODCLI") , PESQPICT("FQ4","FQ4_CODCLI"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_NOMCLI"	,"FQ4",RETTITLE("FQ4_NOMCLI") , PESQPICT("FQ4","FQ4_NOMCLI"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"A1_END"		,"FQ4",RETTITLE("A1_END") 	  , PESQPICT("SA1","A1_END"	) 	  , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"A1_MUN"		,"FQ4",RETTITLE("A1_MUN") 	  , PESQPICT("SA1","A1_MUN"	) 	  , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"A1_EST"		,"FQ4",RETTITLE("A1_EST") 	  , PESQPICT("SA1","A1_EST"	) 	  , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_DTINI" 	,"FQ4",RETTITLE("FQ4_DTINI" ) , PESQPICT("FQ4","FQ4_DTINI" 	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_DTFIM" 	,"FQ4",RETTITLE("FQ4_DTFIM" ) , PESQPICT("FQ4","FQ4_DTFIM" 	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_PROJET"	,"FQ4",RETTITLE("FQ4_PROJET") , PESQPICT("FQ4","FQ4_PROJET"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_OBRA" 	,"FQ4",RETTITLE("FQ4_OBRA" 	) , PESQPICT("FQ4","FQ4_OBRA" 	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_AS"		,"FQ4",RETTITLE("FQ4_AS"	) , PESQPICT("FQ4","FQ4_AS"		) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_PREDES"	,"FQ4",RETTITLE("FQ4_PREDES") , PESQPICT("FQ4","FQ4_PREDES"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_LOG"	,"FQ4",RETTITLE("FQ4_LOG"	) , PESQPICT("FQ4","FQ4_LOG"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )

		OBREAK := TRBREAK():NEW(OSECTION2,OSECTION:CELL("T9_CODFAMI"),STR0009) //"SUB TOTAIS"
		TREPORT():TOTALINLINE(.T.)		// IMPRIME TOTAL EM LINHA OU COLUNA (DEFAULT .T. - LINHA )   
		TRFUNCTION():NEW(OSECTION:CELL("DISP") ,NIL,"SUM",OBREAK,,,,.F.,.T.)
		TRFUNCTION():NEW(OSECTION:CELL("CON") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION:CELL("MNT") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION:CELL("NFRR") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		TRFUNCTION():NEW(OSECTION:CELL("NFRE") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION:CELL("TRE") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION:CELL("ENT") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		TRFUNCTION():NEW(OSECTION:CELL("SRT") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION:CELL("PAR") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		TRFUNCTION():NEW(OSECTION:CELL("OTR") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 		
		TRFUNCTION():NEW(OSECTION:CELL("OCUP"),NIL,"ONPRINT",OBREAK,,,{|| ROUND((NTGOCU/NTGDISP)*100,2) },.F.,.T.) 

	ENDIF

RETURN OREPORT
/*ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅДїПїЅПїЅ
ПїЅПїЅПїЅFUNCAO    ПїЅ PRINTREPORTПїЅ AUTOR ПїЅ MIGUEL GONTIJO        ПїЅ DATA ПїЅ09/02/2017ПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅДґПїЅПїЅ
ПїЅПїЅПїЅDESCRICAO ПїЅ IMPRIME RELATORIO                                            ПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅЩ±ПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅ*/
STATIC FUNCTION PRINTREPORT()
	LOCAL OSECTION1 := OREPORT:SECTION(1)
	LOCAL OSECTION2 := OREPORT:SECTION(2)
	LOCAL OSECTION3 := OREPORT:SECTION(3)
	LOCAL CPROJET 	:=	""
	LOCAL CAUX 		:=	""
	LOCAL CAUX2		:=	""
	LOCAL NINC 		:=	1

	IF SELDADOS()
		IF MV_PAR11 == 1
			//NOCUPACAO	:=	ST9TRB->TNFRE/ST9TRB->QTDBEMCTR
			OREPORT:SETMETER( ST9TRB->( RECCOUNT()) )
			CAUX := ST9TRB->T9_CENTRAB
			WHILE ST9TRB->(! EOF())
				IF OREPORT:CANCEL()
					EXIT
				ENDIF
				IF CAUX <> ST9TRB->T9_CENTRAB .OR. NINC == 1
					
					IF NINC > 1 
						OSECTION2:FINISH()
					ENDIF
					OSECTION1:INIT()
					OSECTION1:CELL("CENTRAB"):SETBLOCK( { || ("FILIAL - " + ST9TRB->T9_CENTRAB + " - " + ALLTRIM( STR( ST9TRB->QTDBEMCTR ) ) + STR0012)  }) //" BENS NA FILIAL."
					OSECTION1:PRINTLINE()
					OSECTION1:FINISH()
					OSECTION2:INIT()
					NTGOCU	:=	0
					NTGDISP	:=	0	
					
				ENDIF
				
				NTGOCU	+=	ST9TRB->NFRE
				NTGDISP	+=	ST9TRB->QTDBEM	
				
				NTOCU	+=	ST9TRB->NFRE
				NTDISP	+=	ST9TRB->QTDBEM	
				
				OSECTION2:CELL("T9_CODFAMI"	):SETBLOCK( { || ST9TRB->T9_CODFAMI	})
				OSECTION2:CELL("T6_NOME"	):SETBLOCK( { || ST9TRB->T6_NOME	})
				OSECTION2:CELL("QTDBEM"		):SETBLOCK( { || ST9TRB->QTDBEM		})
				OSECTION2:CELL("DISP"		):SETBLOCK( { || ST9TRB->DISP		})
				OSECTION2:CELL("CON" 		):SETBLOCK( { || ST9TRB->CON		})
				//OSECTION2:CELL("MNT"		):SETBLOCK( { || ST9TRB->MNT		})
				OSECTION2:CELL("NFRE"		):SETBLOCK( { || ST9TRB->NFRE		})
				//OSECTION2:CELL("TRE" 		):SETBLOCK( { || ST9TRB->TRE		})
				//OSECTION2:CELL("NFRR"		):SETBLOCK( { || ST9TRB->NFRR		})
				OSECTION2:CELL("OCUP" 		):SETBLOCK( { || TRANSFORM("999%",CVALTOCHAR(ROUND((ST9TRB->NFRE / ST9TRB->QTDBEM)* 100,2)))  + "%"})
				//OSECTION2:CELL("ENT" 		):SETBLOCK( { || ST9TRB->ENT		})
				OSECTION2:CELL("SRT" 		):SETBLOCK( { || ST9TRB->SRT		})
				//OSECTION2:CELL("PAR" 		):SETBLOCK( { || ST9TRB->PAR		})
				OSECTION2:CELL("OTR" 		):SETBLOCK( { || ST9TRB->OTR		})
				OSECTION2:PRINTLINE()

				CAUX := ST9TRB->T9_CENTRAB
				ST9TRB->( DBSKIP() )
				OREPORT:INCMETER(NINC++)  
			ENDDO
			
			OSECTION2:FINISH()
			NTGOCU	:=	NTOCU
			NTGDISP	:=	NTDISP
			ST9TRB->(DBCLOSEAREA())

		ELSEIF MV_PAR11 == 2

			OREPORT:SETMETER( ZZZTRB->( RECCOUNT()) )
			CAUX := ZZZTRB->T9_CODBEM
			CAUX2:=	ZZZTRB->T9_CODFAMI
			WHILE ZZZTRB->(! EOF())
				IF OREPORT:CANCEL()
					EXIT
				ENDIF
				IF CAUX2 != ZZZTRB->T9_CODFAMI .OR. NINC == 1
					IF NINC > 1
							OSECTION3:FINISH()
							OSECTION2:FINISH()
					ENDIF
					OSECTION1:INIT()
					OSECTION1:CELL("T9_CODFAMI"	):SETBLOCK( { || ALLTRIM(ZZZTRB->T9_CODFAMI) + " - " + ALLTRIM(POSICIONE("ST6",1,XFILIAL("ST6")+ZZZTRB->T9_CODFAMI,"T6_NOME")) })
					OSECTION1:CELL("DISP"		):SETBLOCK( { || ZZZTRB->DISP })
					OSECTION1:CELL("CON" 		):SETBLOCK( { || ZZZTRB->CON		})
					//OSECTION1:CELL("MNT"		):SETBLOCK( { || ZZZTRB->MNT		})
					OSECTION1:CELL("NFRE"		):SETBLOCK( { || ZZZTRB->NFRE		})
					//OSECTION1:CELL("TRE" 		):SETBLOCK( { || ZZZTRB->TRE		})
					//OSECTION1:CELL("NFRR"		):SETBLOCK( { || ZZZTRB->NFRR		})
					OSECTION1:CELL("OCUP" 		):SETBLOCK( { || TRANSFORM("999%",CVALTOCHAR(ROUND((ZZZTRB->NFRE / (ZZZTRB->(DISP+CON+MNT+NFRE+TRE+NFRR+ENT+SRT+PAR+OTR)))* 100,2)))  + "%"})
					//OSECTION1:CELL("ENT" 		):SETBLOCK( { || ZZZTRB->ENT		})
					OSECTION1:CELL("SRT" 		):SETBLOCK( { || ZZZTRB->SRT		})
					//OSECTION1:CELL("PAR" 		):SETBLOCK( { || ZZZTRB->PAR		})
					OSECTION1:CELL("OTR" 		):SETBLOCK( { || ZZZTRB->OTR		})
					
					OSECTION1:PRINTLINE()
					OSECTION1:FINISH()

					IF CAUX <> ZZZTRB->T9_CODBEM .OR. NINC == 1
						IF NINC > 1
							OSECTION3:FINISH()
						ENDIF/*
						OSECTION2:INIT()
						OSECTION2:CELL("T9_CODBEM"	):SETBLOCK( { || "HISTORICO DO BEM " + ALLTRIM(ZZZTRB->T9_CODBEM) + " - " + ALLTRIM(ZZZTRB->T9_NOME) })
						OSECTION2:PRINTLINE()
						OSECTION2:FINISH()
						OSECTION3:INIT()*/
					ENDIF
				ENDIF
				OREPORT:INCMETER(NINC++)  

				NTGOCU	+=	ZZZTRB->NFRE
				NTGDISP	+=	ZZZTRB->(DISP+CON+MNT+NFRE+TRE+NFRR+ENT+SRT+PAR+OTR)
				
				NTOCU	+=	ZZZTRB->NFRE
				NTDISP	+=	ZZZTRB->(DISP+CON+MNT+NFRE+TRE+NFRR+ENT+SRT+PAR+OTR)	

				//Posiciona na FQ4 para atender a personalizaзгo padrгo do TReport
				FQ4->(DbSeek(xFilial("FQ4") + ZZZTRB->T9_CODBEM))

				OSECTION2:INIT()
				OSECTION2:CELL("T9_CODBEM"	):SETBLOCK( { || STR0013 + ALLTRIM(ZZZTRB->T9_CODBEM) + " - " + ALLTRIM(ZZZTRB->T9_NOME) }) //"HISTORICO DO BEM "
				OSECTION2:PRINTLINE()
				OSECTION2:FINISH()
				OSECTION3:INIT()
				OSECTION3:CELL("T9_STATUS"	):SETBLOCK( { || POSICIONE("TQY",1,XFILIAL("TQY")+ZZZTRB->T9_STATUS,"TQY_DESTAT")	})
				OSECTION3:CELL("T9_CODFAMI"	):SETBLOCK( { || ZZZTRB->T9_CODFAMI	})
				OSECTION3:CELL("T9_TIPMOD"	):SETBLOCK( { || ZZZTRB->T9_TIPMOD	})
				OSECTION3:CELL("T9_FABRICA"	):SETBLOCK( { || ZZZTRB->T9_FABRICA	})
				//OSECTION3:CELL("T9_XSUBLOC"	):SETBLOCK( { || IIF(ZZZTRB->T9_XSUBLOC='1',"NAO","SIM")	})
				//OSECTION2:CELL("FQ4_POSCON"	):SETBLOCK( { || ZZZTRB->FQ4_POSCON	})
				OSECTION3:CELL("HB_COD"		):SETBLOCK( { || ZZZTRB->HB_COD	})
				OSECTION3:CELL("HB_NOME"	):SETBLOCK( { || ZZZTRB->HB_NOME	})
				OSECTION3:CELL("FQ4_OS"		):SETBLOCK( { || ZZZTRB->FQ4_OS		})
				OSECTION3:CELL("FQ4_SERVIC"	):SETBLOCK( { || ZZZTRB->FQ4_SERVIC	})
				OSECTION3:CELL("FQ4_PRELIB"	):SETBLOCK( { || STOD(ZZZTRB->FQ4_PRELIB)	})
				OSECTION3:CELL("FQ4_CODCLI"	):SETBLOCK( { || IIF(EMPTY(ZZZTRB->FQ4_CODCLI),POSICIONE("SM0",1,CEMPANT+SUBSTR(ZZZTRB->HB_COD,1,4),"M0_CODFIL"),ZZZTRB->FQ4_CODCLI)	})
				OSECTION3:CELL("FQ4_NOMCLI"	):SETBLOCK( { || IIF(EMPTY(ZZZTRB->FQ4_CODCLI),POSICIONE("SM0",1,CEMPANT+SUBSTR(ZZZTRB->HB_COD,1,4),"M0_NOME"),ZZZTRB->FQ4_NOMCLI)	})
				OSECTION3:CELL("A1_END"		):SETBLOCK( { || IIF(EMPTY(ZZZTRB->FQ4_CODCLI),POSICIONE("SM0",1,CEMPANT+SUBSTR(ZZZTRB->HB_COD,1,4),"M0_ENDCOB"),ZZZTRB->A1_END)	})
				OSECTION3:CELL("A1_MUN" 	):SETBLOCK( { || IIF(EMPTY(ZZZTRB->FQ4_CODCLI),POSICIONE("SM0",1,CEMPANT+SUBSTR(ZZZTRB->HB_COD,1,4),"M0_CIDCOB"),ZZZTRB->A1_MUN)	})
				OSECTION3:CELL("A1_EST"		):SETBLOCK( { || IIF(EMPTY(ZZZTRB->FQ4_CODCLI),POSICIONE("SM0",1,CEMPANT+SUBSTR(ZZZTRB->HB_COD,1,4),"M0_ESTCOB"),ZZZTRB->A1_EST)	})
				OSECTION3:CELL("FQ4_DTINI" 	):SETBLOCK( { || STOD(ZZZTRB->FQ4_DTINI)	})
				OSECTION3:CELL("FQ4_DTFIM" 	):SETBLOCK( { || STOD(ZZZTRB->FQ4_DTFIM)	})
				OSECTION3:CELL("FQ4_PROJET"	):SETBLOCK( { || ZZZTRB->FQ4_PROJET	})
				OSECTION3:CELL("FQ4_OBRA" 	):SETBLOCK( { || ZZZTRB->FQ4_OBRA	})
				OSECTION3:CELL("FQ4_AS"		):SETBLOCK( { || ZZZTRB->FQ4_AS		})
				OSECTION3:CELL("FQ4_PREDES"	):SETBLOCK( { || ZZZTRB->FQ4_PREDES	})
				//OREPORT:INCROW(1)
				OSECTION3:CELL("FQ4_LOG"	):SETBLOCK( { || ZZZTRB->FQ4_LOG	})
				OSECTION3:PRINTLINE()
				CAUX := ZZZTRB->T9_CODBEM
				CAUX2 := ZZZTRB->T9_CODFAMI
				ZZZTRB->( DBSKIP() )
				IF CAUX == ZZZTRB->T9_CODBEM
					OREPORT:THINLINE()
				ENDIF
				IF CAUX2 == ZZZTRB->T9_CODFAMI
					OREPORT:THINLINE()
				ENDIF
			ENDDO

			OSECTION3:FINISH()
			NTGOCU	:=	NTOCU
			NTGDISP	:=	NTDISP
			ZZZTRB->(DBCLOSEAREA())

		ENDIF
	ELSE

		AVISO(CTITULO,STR0014,{"OK"},1) //"NAO EXISTEM DADOS A SEREM EXIBIDOS"

	ENDIF

RETURN
/*ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅН»ПїЅПїЅ
ПїЅПїЅПїЅPROGRAMA  ПїЅ PERGPARAMПїЅAUTOR  ПїЅ MIGUEL GONTIJO     ПїЅ DATA ПїЅ  09/02/2017 ПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅН№ПїЅПїЅ
ПїЅПїЅПїЅDESC.     ПїЅ PERGUNTA DO RELATПїЅRIO.                                     ПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅЩ±ПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅ*/
STATIC FUNCTION PERGPARAM(CPERG)
	LOCAL APERGS  := {}
	LOCAL DDATA   := DATE()
	LOCAL ARET    := {}
	LOCAL LRET    := .F.
	LOCAL ACOMBO  := {STR0015,STR0016} //"1-SINTETICO"###"2-ANALITICO"
	LOCAL NX

	LOCAL CCENTRABI := IIF(FIELDPOS("T9_CENTRAB"	)>0,	SPACE(		GETSX3CACHE("T9_CENTRAB","X3_TAMANHO")),SPACE(10))
	LOCAL CCENTRABF := IIF(FIELDPOS("T9_CENTRAB"	)>0,REPLICATE("Z",	GETSX3CACHE("T9_CENTRAB","X3_TAMANHO")),REPLICATE("Z",10))
	LOCAL CCODBEMI  := IIF(FIELDPOS("T9_CODBEM"		)>0,	SPACE(		GETSX3CACHE("T9_CODBEM"	,"X3_TAMANHO")),SPACE(10))
	LOCAL CCODBEMF  := IIF(FIELDPOS("T9_CODBEM"		)>0,REPLICATE("Z",	GETSX3CACHE("T9_CODBEM"	,"X3_TAMANHO")),REPLICATE("Z",10))
	LOCAL CCODFAMI  := IIF(FIELDPOS("T9_CODFAMI"	)>0,	SPACE(		GETSX3CACHE("T9_CODFAMI","X3_TAMANHO")),SPACE(10))
	LOCAL CCODFAMF  := IIF(FIELDPOS("T9_CODFAMI"	)>0,REPLICATE("Z",	GETSX3CACHE("T9_CODFAMI","X3_TAMANHO")),REPLICATE("Z",10))
	LOCAL CTIPMODI  := IIF(FIELDPOS("T9_TIPMOD"		)>0,	SPACE(		GETSX3CACHE("T9_TIPMOD"	,"X3_TAMANHO")),SPACE(10))
	LOCAL CTIPMODF  := IIF(FIELDPOS("T9_TIPMOD"		)>0,REPLICATE("Z",	GETSX3CACHE("T9_TIPMOD"	,"X3_TAMANHO")),REPLICATE("Z",10))
	LOCAL CSTATUSI  := IIF(FIELDPOS("T9_STATUS"		)>0,	SPACE(		GETSX3CACHE("T9_STATUS"	,"X3_TAMANHO")),SPACE(10))
	LOCAL CSTATUSF  := IIF(FIELDPOS("T9_STATUS"		)>0,REPLICATE("Z",	GETSX3CACHE("T9_STATUS"	,"X3_TAMANHO")),REPLICATE("Z",10))
	//LOCAL CCOD_MUNI := IIF(FIELDPOS("HB_COD_MUN"	)>0,	SPACE(		GETSX3CACHE("HB_COD_MUN","X3_TAMANHO")),SPACE(10))
	//LOCAL CCOD_MUNF := IIF(FIELDPOS("HB_COD_MUN"	)>0,REPLICATE("Z",	GETSX3CACHE("HB_COD_MUN","X3_TAMANHO")),REPLICATE("Z",10))

	AADD( APERGS ,{1,RETTITLE("T9_CENTRAB"	),CCENTRABI,PESQPICT("ST9","T9_CENTRAB"	),'.T.',"SHB",'.T.', 50 ,.F.})
	AADD( APERGS ,{1,RETTITLE("T9_CENTRAB"	),CCENTRABF,PESQPICT("ST9","T9_CENTRAB"	),'.T.',"SHB",'.T.', 50 ,.T.})
	AADD( APERGS ,{1,RETTITLE("T9_CODBEM"	),CCODBEMI,	PESQPICT("ST9","T9_CODBEM"	),'.T.',"ST9",'.T.', 50 ,.F.})
	AADD( APERGS ,{1,RETTITLE("T9_CODBEM"	),CCODBEMF,	PESQPICT("ST9","T9_CODBEM"	),'.T.',"ST9",'.T.', 50 ,.T.})
	AADD( APERGS ,{1,RETTITLE("T9_CODFAMI"	),CCODFAMI,	PESQPICT("ST9","T9_CODFAMI"	),'.T.',"ST6",'.T.', 50 ,.F.})
	AADD( APERGS ,{1,RETTITLE("T9_CODFAMI"	),CCODFAMF,	PESQPICT("ST9","T9_CODFAMI"	),'.T.',"ST6",'.T.', 50 ,.T.})
	AADD( APERGS ,{1,RETTITLE("T9_TIPMOD"	),CTIPMODI,	PESQPICT("ST9","T9_TIPMOD"	),'.T.',"TQR",'.T.', 50 ,.F.})
	AADD( APERGS ,{1,RETTITLE("T9_TIPMOD"	),CTIPMODF,	PESQPICT("ST9","T9_TIPMOD"	),'.T.',"TQR",'.T.', 50 ,.T.})
	AADD( APERGS ,{1,RETTITLE("T9_STATUS"	),CSTATUSI,	PESQPICT("ST9","T9_STATUS"	),'.T.',"TQY",'.T.', 50 ,.F.})
	AADD( APERGS ,{1,RETTITLE("T9_STATUS"	),CSTATUSF,	PESQPICT("ST9","T9_STATUS"	),'.T.',"TQY",'.T.', 50 ,.T.})
	//AADD( APERGS ,{1,"Munic.Ini"			 ,CCOD_MUNI,"@!"						 ,'.T.',"CC2",'.T.', 50 ,.F.})
	//AADD( APERGS ,{1,"Munic.Fim"			 ,CCOD_MUNF,"@!"						 ,'.T.',"CC2",'.T.', 50 ,.T.})
	AADD( APERGS ,{2,STR0017 , 1 ,ACOMBO, 70 , '.T.' , .T. }) // COMBO //"TIPO RELATORIO: "

	IF PARAMBOX(APERGS ,STR0018,ARET, /*< BOK >*/, /*< ABUTTONS >*/, .T. , /*7 < NPOSX >*/, /*8 < NPOSY >*/, /*9 < ODLGWIZARD >*/, /*10 < CLOAD > */, .T. , .T. ) //"PARAMETROS "

		FOR NX := 1 TO LEN(ARET)
			&("MV_PAR"+STRZERO(NX,2)) := ARET[NX]
		NEXT
		LRET := .T.

		IF VALTYPE( MV_PAR11 ) == "C"
			IF "1" $  ALLTRIM(MV_PAR11) 
				MV_PAR11 := 1
			ELSEIF "2" $ ALLTRIM(MV_PAR11) 
				MV_PAR11 := 2
			ENDIF
		END	
	ENDIF

RETURN (LRET)
/*ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅН»ПїЅПїЅ
ПїЅПїЅПїЅPROGRAMA  ПїЅ PERGPARAMПїЅAUTOR  ПїЅ MIGUEL GONTIJO     ПїЅ DATA ПїЅ  09/02/2017 ПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅН№ПїЅПїЅ
ПїЅПїЅПїЅDESC.     ПїЅ PERGUNTA DO RELATПїЅRIO.                                     ПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅЩ±ПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅ
ПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅПїЅ*/
STATIC FUNCTION SELDADOS()
	LOCAL CQUERY := ""
	LOCAL LRET := .F.

	IF MV_PAR11 == 1

		CQUERY += " SELECT  " + CRLF
		CQUERY += " 			ST9.T9_CENTRAB,  " + CRLF
		CQUERY += " 			ST9.T9_CODFAMI,  " + CRLF
		CQUERY += " 			ST6.T6_NOME, " + CRLF
		CQUERY += "             COUNT(ST9.T9_CODBEM) QTDBEM,  " + CRLF

		/*
		CQUERY += " 			ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '00' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A'	GROUP BY ST91.T9_CODFAMI),0)  DISP, " + CRLF 
		CQUERY += " 			ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '10' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  CON, " + CRLF
		CQUERY += " 			ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '20' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  NFRE," + CRLF
		CQUERY += " 			ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '30' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  TRE, " + CRLF
		CQUERY += " 			ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '40' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  ENT, " + CRLF
		CQUERY += " 			ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '50' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A'	GROUP BY ST91.T9_CODFAMI),0)  SRT, " + CRLF
		CQUERY += " 			ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '60' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  NFRR," + CRLF
		CQUERY += " 			ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '70' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  MNT,	" + CRLF
		CQUERY += " 			ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '80' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  PAR, " + CRLF
		CQUERY += " 			ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ('08','10','11') AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  OTR, " + CRLF
		CQUERY += " 			(SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_TIPOSE IN ('E') GROUP BY ST91.T9_CENTRAB)  QTDBEMCTR,	" + CRLF                                          

		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '00')) AND ST91.T9_TIPOSE IN ('E')  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TDISP,	" + CRLF                                                
		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '10')) AND ST91.T9_TIPOSE IN ('E')  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TCON,	" + CRLF                                              
		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '20')) AND ST91.T9_TIPOSE IN ('E')  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TNFRE,	" + CRLF                                                
		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '30')) AND ST91.T9_TIPOSE IN ('E')  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TTRE,	" + CRLF                                               
		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '40')) AND ST91.T9_TIPOSE IN ('E')  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TENT,	" + CRLF                                              
		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '50')) AND ST91.T9_TIPOSE IN ('E')  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TSRT,	" + CRLF                                             
		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '60')) AND ST91.T9_TIPOSE IN ('E')  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TNFRR,	" + CRLF                                            
		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '70')) AND ST91.T9_TIPOSE IN ('E')  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TMNT,	" + CRLF                                           
		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '80')) AND ST91.T9_TIPOSE IN ('E')  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TPAR,	" + CRLF                                                
		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ('08','10','11') AND ST91.T9_TIPOSE IN ('E')  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TOTR	" + CRLF                                           
		*/

		CQUERY += " 			COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '00' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	GROUP BY ST91.T9_CODFAMI),0)  DISP, " + CRLF 
		CQUERY += " 			COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '10' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  CON, " + CRLF
		CQUERY += " 			COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '20' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  NFRE," + CRLF
		CQUERY += " 			COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '30' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  TRE, " + CRLF
		CQUERY += " 			COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '40' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  ENT, " + CRLF
		CQUERY += " 			COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '50' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	GROUP BY ST91.T9_CODFAMI),0)  SRT, " + CRLF
		CQUERY += " 			COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '60' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  NFRR," + CRLF
		CQUERY += " 			COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '70' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  MNT,	" + CRLF
		CQUERY += " 			COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '80' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  PAR, " + CRLF
		CQUERY += " 			COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ('08','10','11') AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  OTR, " + CRLF
		CQUERY += " 			(SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB GROUP BY ST91.T9_CENTRAB)  QTDBEMCTR,	" + CRLF                                          

		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '00'))  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TDISP,	" + CRLF                                                
		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '10'))  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TCON,	" + CRLF                                              
		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '20'))  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TNFRE,	" + CRLF                                                
		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '30'))  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TTRE,	" + CRLF                                               
		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '40'))  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TENT,	" + CRLF                                              
		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '50'))  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TSRT,	" + CRLF                                             
		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '60'))  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TNFRR,	" + CRLF                                            
		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '70'))  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TMNT,	" + CRLF                                           
		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '80'))  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TPAR,	" + CRLF                                                
		CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ('08','10','11')  AND ST91.T9_SITBEM	=	'A'   GROUP BY ST91.T9_CENTRAB)  TOTR	" + CRLF                                           
		
		CQUERY += "  FROM		"+RETSQLNAME("ST9")+" ST9     " + CRLF       

		CQUERY += "  LEFT JOIN	"+RETSQLNAME("SHB")+" SHB       " + CRLF
		CQUERY += " 			ON	SHB.HB_COD = ST9.T9_CENTRAB     " + CRLF       
		CQUERY += " 			AND SHB.D_E_L_E_T_=''        " + CRLF             

		//CQUERY += "  LEFT JOIN	"+RETSQLNAME("CC2")+" CC2     " + CRLF  
		//CQUERY += " 			ON	CC2.CC2_CODMUN = SHB.HB_COD_MUN      " + CRLF  
		//CQUERY += " 			AND CC2.D_E_L_E_T_=''   " + CRLF

		CQUERY += " LEFT JOIN	"+RETSQLNAME("ST6")+" ST6 " + CRLF
		CQUERY += " 			ON	ST9.T9_CODFAMI	=	ST6.T6_CODFAMI " + CRLF
		CQUERY += " 			AND ST9.D_E_L_E_T_	=	'' " + CRLF

		CQUERY += " WHERE		ST9.D_E_L_E_T_	=	''        " + CRLF           
		CQUERY += " 		AND ST9.T9_CENTRAB BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " + CRLF
		CQUERY += " 		AND ST9.T9_CODBEM  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + CRLF
		CQUERY += " 		AND ST9.T9_CODFAMI BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " + CRLF
		CQUERY += " 		AND ST9.T9_TIPMOD  BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + CRLF
		CQUERY += " 		AND ST9.T9_STATUS  BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' " + CRLF
		//CQUERY += " 		AND SHB.HB_COD_MUN BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' " + CRLF
		//CQUERY += " 		AND ST9.T9_TIPOSE	IN	('E') " + CRLF
		CQUERY += " 		AND ST9.T9_SITBEM	=	'A' " + CRLF

		CQUERY += " GROUP BY	ST9.T9_CENTRAB,  " + CRLF
		CQUERY += " 			ST9.T9_CODFAMI, " + CRLF
		CQUERY += " 			ST6.T6_NOME " + CRLF

		CQUERY += " ORDER BY	ST9.T9_CENTRAB, " + CRLF
		CQUERY += " 			ST9.T9_CODFAMI " + CRLF

		IF SELECT("ST9TRB") > 0
			ST9TRB->(DBCLOSEAREA())
		ENDIF

		//MEMOWRITE(GETTEMPPATH()+"LOCR009_SINTATICO.SQL",CQUERY)
		CQUERY := CHANGEQUERY(CQUERY) 

		TCQUERY CQUERY NEW ALIAS "ST9TRB"
		ST9TRB->(DBGOTOP())

		IIF( ST9TRB->(EOF()) , LRET := .F. , LRET := .T. )

	ELSEIF MV_PAR11 == 2

		CQUERY += " SELECT	" + CRLF
		CQUERY += "		ST9.T9_CODBEM,		" + CRLF
		CQUERY += "		ST9.T9_CODIMOB,		" + CRLF
		CQUERY += " 	ST9.T9_TIPMOD,		" + CRLF
		CQUERY += "		ST9.T9_CODFAMI,		" + CRLF
		CQUERY += "		ST9.T9_FABRICA,		" + CRLF
		CQUERY += "		ST9.T9_NOME,		" + CRLF
		CQUERY += "		ST9.T9_STATUS,		" + CRLF
		//CQUERY += "		ST9.T9_XSUBLOC,		" + CRLF
		CQUERY += "		SHB.HB_COD,		" + CRLF
		CQUERY += "		SHB.HB_NOME,		" + CRLF
		CQUERY += "		SHB.HB_CC,		" + CRLF
		//CQUERY += "		CC2.CC2_CODMUN,		" + CRLF
		//CQUERY += "		CC2.CC2_MUN,		" + CRLF
		//CQUERY += "		CC2.CC2_EST,		" + CRLF
		CQUERY += "		COALESCE(ZZZ.FQ4_DOCUME,'') FQ4_DOCUME,		" + CRLF
		CQUERY += "		COALESCE(ZZZ.FQ4_SERIE,'') FQ4_SERIE,		" + CRLF
		CQUERY += "		COALESCE(ZZZ.FQ4_OS,'') FQ4_OS,		" + CRLF
		CQUERY += "		COALESCE(ZZZ.FQ4_SERVIC,'') FQ4_SERVIC,		" + CRLF
		CQUERY += "		COALESCE(ZZZ.FQ4_PRELIB,'') FQ4_PRELIB,		" + CRLF
		CQUERY += "		COALESCE(ZZZ.FQ4_PROJET,'') FQ4_PROJET,		" + CRLF
		CQUERY += "		COALESCE(ZZZ.FQ4_OBRA,'') FQ4_OBRA,		" + CRLF
		CQUERY += "		COALESCE(ZZZ.FQ4_AS,'') FQ4_AS,		" + CRLF
		CQUERY += "		COALESCE(ZZZ.FQ4_CODCLI,'') FQ4_CODCLI,		" + CRLF
		CQUERY += "		COALESCE(ZZZ.FQ4_LOJCLI,'') FQ4_LOJCLI,		" + CRLF
		CQUERY += "		COALESCE(ZZZ.FQ4_NOMCLI,'') FQ4_NOMCLI,		" + CRLF
		CQUERY += "		COALESCE(ZZZ.FQ4_NFREM,'') FQ4_NFREM,		" + CRLF
		CQUERY += "		COALESCE(ZZZ.FQ4_SERREM,'') FQ4_SERREM,		" + CRLF
		CQUERY += "		COALESCE(ZZZ.FQ4_DTINI,'') FQ4_DTINI,		" + CRLF
		CQUERY += "		COALESCE(ZZZ.FQ4_DTFIM,'') FQ4_DTFIM,		" + CRLF
		CQUERY += "		COALESCE(ZZZ.FQ4_LOG,'') FQ4_LOG,		" + CRLF
		CQUERY += "		COALESCE(ZZZ.FQ4_PREDES,'') FQ4_PREDES,		" + CRLF
		CQUERY += "		COALESCE(SA1.A1_END,'') A1_END,		" + CRLF
		CQUERY += "		COALESCE(SA1.A1_MUN,'') A1_MUN,		" + CRLF
		CQUERY += "		COALESCE(SA1.A1_EST,'') A1_EST,		" + CRLF
		/*
		CQUERY += " 	ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '00' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A'	GROUP BY ST91.T9_CODFAMI),0)  DISP, " + CRLF 
		CQUERY += " 	ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '10' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  CON, " + CRLF
		CQUERY += " 	ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '20' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  NFRE," + CRLF
		CQUERY += " 	ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '30' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  TRE, " + CRLF
		CQUERY += " 	ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '40' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  ENT, " + CRLF
		CQUERY += " 	ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '50' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A'	GROUP BY ST91.T9_CODFAMI),0)  SRT, " + CRLF
		CQUERY += " 	ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '60' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  NFRR," + CRLF
		CQUERY += " 	ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '70' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  MNT,	" + CRLF
		CQUERY += " 	ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '80' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  PAR, " + CRLF
		CQUERY += " 	ISNULL((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ('08','10','11') AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_TIPOSE IN ('E') AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  OTR " + CRLF
		*/
		CQUERY += " 	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '00' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	GROUP BY ST91.T9_CODFAMI),0)  DISP, " + CRLF 
		CQUERY += " 	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '10' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  CON, " + CRLF
		CQUERY += " 	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '20' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  NFRE," + CRLF
		CQUERY += " 	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '30' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  TRE, " + CRLF
		CQUERY += " 	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '40' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  ENT, " + CRLF
		CQUERY += " 	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '50' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	GROUP BY ST91.T9_CODFAMI),0)  SRT, " + CRLF
		CQUERY += " 	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '60' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  NFRR," + CRLF
		CQUERY += " 	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '70' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  MNT,	" + CRLF
		CQUERY += " 	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '80' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  PAR, " + CRLF
		CQUERY += " 	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS IN ('08','10','11') AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' GROUP BY ST91.T9_CODFAMI),0)  OTR " + CRLF

		CQUERY += " FROM	"+RETSQLNAME("ST9")+"	ST9		" + CRLF

		//CQUERY += " LEFT JOIN FQ4010 ZZZ		" + CRLF     
		CQUERY += " LEFT JOIN "+RETSQLNAME("FQ4")+" ZZZ     " + CRLF

		CQUERY += " 						 ON		ZZZ.FQ4_CODBEM = ST9.T9_CODBEM		" + CRLF       
		CQUERY += "							AND ZZZ.D_E_L_E_T_=''		" + CRLF
		CQUERY += "							AND ZZZ.R_E_C_N_O_ = (SELECT MAX(ZZZ1.R_E_C_N_O_) FROM "+RETSQLNAME("FQ4")+" ZZZ1 WHERE ZZZ1.FQ4_CODBEM = ST9.T9_CODBEM AND ZZZ1.D_E_L_E_T_ = '')		" + CRLF

		CQUERY += " LEFT JOIN "+RETSQLNAME("SHB")+" SHB     " + CRLF
		CQUERY += " ON		SHB.HB_COD = ST9.T9_CENTRAB    	" + CRLF
		CQUERY += " AND 	SHB.D_E_L_E_T_=''      	" + CRLF
		
		//CQUERY += " LEFT JOIN "+RETSQLNAME("CC2")+" CC2     " + CRLF
		//CQUERY += " ON		CC2.CC2_CODMUN = SHB.HB_COD_MUN " + CRLF
		//CQUERY += " AND CC2.D_E_L_E_T_=''			      	" + CRLF

		CQUERY += " LEFT JOIN "+RETSQLNAME("SA1")+" SA1     " + CRLF
		CQUERY += " ON		SA1.A1_COD = ZZZ.FQ4_CODCLI    	" + CRLF
		CQUERY += " AND SA1.A1_LOJA = ZZZ.FQ4_LOJCLI      	" + CRLF
		CQUERY += " AND SA1.D_E_L_E_T_ = ''           		" + CRLF

		CQUERY += " WHERE ZZZ.D_E_L_E_T_=''                  " + CRLF
		CQUERY += " AND ST9.T9_CENTRAB BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " + CRLF
		CQUERY += " AND ST9.T9_CODBEM  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + CRLF
		CQUERY += " AND ST9.T9_CODFAMI BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " + CRLF
		CQUERY += " AND ST9.T9_TIPMOD  BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + CRLF
		CQUERY += " AND ST9.T9_STATUS  BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' " + CRLF
		//CQUERY += " AND SHB.HB_COD_MUN BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' " + CRLF
		//CQUERY += " AND ST9.T9_TIPOSE IN ('E')              " + CRLF
		CQUERY += " AND ST9.T9_SITBEM	=	'A'				" + CRLF

		CQUERY += "  ORDER BY		ST9.T9_CENTRAB,	" + CRLF
		CQUERY += "  				ST9.T9_CODFAMI,	" + CRLF
		CQUERY += "  				ST9.T9_TIPMOD	"

		IF SELECT("ZZZTRB") > 0
			ZZZTRB->(DBCLOSEAREA())
		ENDIF

		//MEMOWRITE(GETTEMPPATH()+"LOCR009_ANALITICO.SQL",CQUERY)
		CQUERY := CHANGEQUERY(CQUERY) 

		TCQUERY CQUERY NEW ALIAS "ZZZTRB"
		ZZZTRB->(DBGOTOP())

		IIF( ZZZTRB->(EOF()) , LRET := .F. , LRET := .T. )

	ENDIF

RETURN LRET
