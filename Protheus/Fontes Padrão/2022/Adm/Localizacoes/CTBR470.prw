#include "CTBR470.ch"
#include "protheus.ch"
#include "report.ch"
#Include "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBR470   บAutor  ณMARCOS HIRAKAWA     บ Data ณ  09/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ RELATORIO Diario auxiliar por grupo de contas em colunas.  บฑฑ
ฑฑบ          ณ PARA VENEZUELA.                                            บฑฑ
ฑฑบ          ณ VEN_11_CTR_008. chm: SCVGF8 ; pln: 00000020444/2010        บฑฑ
ฑฑบ          ณ fnc: 00000020517/2010                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP11 - PARA VENEZUELA.                                     บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณData    ณ BOPS     ณ Motivo da Alteracao                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณJonathan Glzณ26/06/15ณPCREQ-4256ณSe elimina la funcion AjustaSx1() la  ณฑฑ
ฑฑณ            ณ        ณ          ณcual realiza modificacion a SX1 por   ณฑฑ
ฑฑณ            ณ        ณ          ณmotivo de adecuacion a fuentes a nuevaณฑฑ
ฑฑณ            ณ        ณ          ณestructura de SX para Version 12.     ณฑฑ
ฑฑณJonathan Glzณ09/10/15ณPCREQ-4261ณMerge v12.1.8                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function CTBR470()
LOCAL aAREA0:= GETAREA()
Local oReport

PRIVATE cPerg := "CTR470"
PRIVATE cTitle:= STR0002 // "DIARIO AUXILIAR"
PRIVATE cCOL01 , cCOL02, cCOL03, cCOL04, cCOL05, cCOL06, cQUERY1, cQUERY2 
PRIVATE nCOL01 , nCOL02, nCOL03, nCOL04, nCOL05, nCOL06
PRIVATE cDSC01D ,  cDSC02D , cDSC03D , cDSC04D , cDSC05D ,cDSC06D 
PRIVATE cDSC01C ,  cDSC02C , cDSC03C , cDSC04C , cDSC05C ,cDSC06C 

PRIVATE aHIST := {}
PRIVATE aArqtrb := {}
PRIVATE cArqtrb  , cIndTRB1,  cNomIND
PRIVATE aStru := {}
PRIVATE XCT1 
PRIVATE cPICTURED := "@e 999999,999,999.99"
Private oTmpTable 

DBSELECTAREA("CT5")
DBSETORDER(1)

DBSELECTAREA("CT2")
DBSETORDER(1)

DBSELECTAREA("CT1")
XCT1 := XFILIAL("CT1")

aadd(aArqtrb,{"IDENT"   , "C" , 03,0})
aadd(aArqtrb,{"FECHAD"  , "D" , 08,0})
aadd(aArqtrb,{"CONCEPTO", "C" , 40,0})
aadd(aArqtrb,{"COL1DB"  , "N" , 15,2})
aadd(aArqtrb,{"COL1CR"  , "N" , 15,2})
aadd(aArqtrb,{"COL2DB"  , "N" , 15,2})
aadd(aArqtrb,{"COL2CR"  , "N" , 15,2})
aadd(aArqtrb,{"COL3DB"  , "N" , 15,2})
aadd(aArqtrb,{"COL3CR"  , "N" , 15,2})
aadd(aArqtrb,{"COL4DB"  , "N" , 15,2})
aadd(aArqtrb,{"COL4CR"  , "N" , 15,2})
aadd(aArqtrb,{"COL5DB"  , "N" , 15,2})
aadd(aArqtrb,{"COL5CR"  , "N" , 15,2})
aadd(aArqtrb,{"COL6DB"  , "N" , 15,2})
aadd(aArqtrb,{"COL6CR"  , "N" , 15,2})
aadd(aArqtrb,{"DIA_REC" , "C" , 15,0})
aadd(aArqtrb,{"CDEUDOR" , "C" , 20,0})
aadd(aArqtrb,{"CCREDOR" , "C" , 20,0})

aadd(aStru,{"CT1_CONTA"  ,"C" ,020,0})
aadd(aStru,{"CT2_RECNO"  ,"N" ,015,0})
aadd(aStru,{"CT2_DATA"   ,"D" ,008,0})
aadd(aStru,{"CT2_DC"     ,"C" ,001,0})
aadd(aStru,{"CT2_DEBITO" ,"C" ,020,0})
aadd(aStru,{"CT2_CREDIT" ,"C" ,020,0})
aadd(aStru,{"CT2_LP"     ,"C" ,003,0})
aadd(aStru,{"CT2_VALOR"  ,"N" ,017,2})
aadd(aStru,{"CT5_LANPAD" ,"C" ,003,0})
aadd(aStru,{"CT5_HIST"   ,"C" ,200,0})
aadd(aStru,{"CT5_DESC"   ,"C" ,040,0})

cQUERY1 := ""
cQUERY2 := ""

If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
	
	If !Pergunte(cPerg,.T.)      // Pergunte("REPORT",.F.)
		Return
	EndIf
	
	If 	MV_PAR01 + 30 < MV_PAR02
		MsgInfo( STR0011 ,STR0001) // "Periodo Excedeu 30 dias" // "CTBR470"
		RETURN
	EndIf
	cCOL01:= ALLTRIM(MV_PAR05)
	cCOL02:= ALLTRIM(MV_PAR06)
	cCOL03:= ALLTRIM(MV_PAR07)
	cCOL04:= ALLTRIM(MV_PAR08)
	cCOL05:= ALLTRIM(MV_PAR09)
	
	nCOL01:= len(cCOL01)
	nCOL02:= len(cCOL02)
	nCOL03:= len(cCOL03)
	nCOL04:= len(cCOL04)
	nCOL05:= len(cCOL05)

	If 	nCOL01	>	0
		DBSELECTAREA("CT1")
		DBSETORDER(1)
		DBSEEK( XCT1 +	cCOL01 )
		cDSC01D:= SUBS(ALLTRIM(CT1_DESC01) + SPACE(15),1,12)
		cDSC01C:= cDSC01D + " CR"
		cDSC01D+= " DB"
	EndIf
	If 	nCOL02	>	0	
		DBSEEK( XCT1 +	cCOL02 )
		cDSC02D:= SUBS(ALLTRIM(CT1_DESC01)+SPACE(15),1,12)
		cDSC02C:= cDSC02D + " CR"
		cDSC02D+= " DB"
	EndIf
	If 	nCOL03	>	0		
		DBSEEK( XCT1 +	cCOL03 )
		cDSC03D:= SUBS(ALLTRIM(CT1_DESC01)+SPACE(15),1,12)
		cDSC03C:= cDSC03D + " CR"
		cDSC03D+= " DB"
	EndIf
	If 	nCOL04	>	0	
		DBSEEK( XCT1 +	cCOL04 )
		cDSC04D:= SUBS(ALLTRIM(CT1_DESC01)+SPACE(15),1,12)
		cDSC04C:= cDSC04D + " CR"
		cDSC04D+= " DB"
	EndIf
	If 	nCOL05	>	0	
		DBSEEK( XCT1 +	cCOL05 )
		cDSC05D:= SUBS(ALLTRIM(CT1_DESC01)+SPACE(15),1,12)
		cDSC05C:= cDSC05D + " CR"
		cDSC05D+= " DB"
	EndIf

	cDSC06D:= SUBS(ALLTRIM(STR0008)+SPACE(15),1,12) // "CTAS VARIAS"
	cDSC06C:= cDSC06D + " CR"
	cDSC06D+= " DB"
	
	
	
	
	If oTmpTable <> Nil
		oTmpTable:Delete()
	EndIf
	
	oTmpTable := FWTemporaryTable():New("TRB") 
	oTmpTable:SetFields( aArqTRB ) 	
	oTmpTable:AddIndex("T1", {"FECHAD","IDENT","CONCEPTO"}) 
	oTmpTable:Create()

	dbSelectArea("TRB")
	dbSetOrder(1)
	DBGOTOP()
		
	oReport := ReportDef()
	oReport:PrintDialog()
	
	
	If oTmpTable <> Nil
		oTmpTable:Delete()
	EndIf
	
	
	If Select("DIARIO") > 0
		dbSelectArea("DIARIO")
		dbCloseArea()
	Endif

EndIf

RESTAREA(aAREA0)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportDef() บAutor  ณMicrosiga           บFecha ณ 21/02/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBR                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

static function ReportDef()
lOCAL oReport
Local oDia
Local oBreak
Local lLandscape, lTotalInCol, lPageTInCol, lTPageBreak
LOCAL l_T := .F.
PRIVATE TITULO2 := STR0002 // "DIARIO AUXILIAR" 

cTitle += STR0007 // " - CONTAS CONTมBEIS : "

if "" <> alltrim(cCOL01)
	cTitle += cCOL01
	l_T := .T.
endif	
if "" <> alltrim(cCOL02)
	cTitle += (iif(l_T," ; ","") + cCOL02)
	l_T := .T.
endif	
if "" <> alltrim(cCOL03)
	cTitle += (iif(l_T," ; ","") + cCOL03)
	l_T := .T.
endif	
if "" <> alltrim(cCOL04)
	cTitle += (iif(l_T," ; ","") + cCOL04)
	l_T := .T.
endif	
if "" <> alltrim(cCOL05)
	cTitle += (iif(l_T," ; ","") + cCOL05)
endif	

DEFINE REPORT oReport NAME STR0001 TITLE cTitle PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION STR0003 LANDSCAPE 
/*[ TOTAL TEXT <cTotalText> ]*/ /*[TOTAL IN COLUMN]*/ /*[ PAGE TOTAL TEXT <cPageTText> ]*/ /*[PAGE TOTAL IN COLUMN]*/ /*[TOTAL PAGE BREAK]*/ 
								 
DEFINE SECTION oDIA OF oReport TITLE (STR0004 + " " + TITULO2) TABLES "TRB" TOTAL IN COLUMN COLUMNS 15 // "LIBRO"

DEFINE CELL NAME "FECHAD" OF oDIA ALIAS "TRB" TITLE STR0005  SIZE 10   // "FECHAS"

DEFINE CELL NAME "CONCEPTO" OF oDIA ALIAS "TRB" TITLE STR0006 PICTURE "@X" SIZE 40 AUTO SIZE // "CONCEPTOS"

DEFINE CELL NAME "COL1DB" OF oDIA ALIAS "TRB" TITLE cDSC01D PICTURE cPICTURED SIZE 17  
DEFINE CELL NAME "COL1CR" OF oDIA ALIAS "TRB" TITLE cDSC01C PICTURE cPICTURED SIZE 17   
		
DEFINE CELL NAME "COL2DB" OF oDIA ALIAS "TRB" TITLE cDSC02D PICTURE cPICTURED SIZE 17    
DEFINE CELL NAME "COL2CR" OF oDIA ALIAS "TRB" TITLE cDSC02C PICTURE cPICTURED SIZE 17    

DEFINE CELL NAME "COL3DB" OF oDIA ALIAS "TRB" TITLE cDSC03D PICTURE cPICTURED SIZE 17    
DEFINE CELL NAME "COL3CR" OF oDIA ALIAS "TRB" TITLE cDSC03C PICTURE cPICTURED SIZE 17    
		
DEFINE CELL NAME "COL4DB" OF oDIA ALIAS "TRB" TITLE cDSC04D PICTURE cPICTURED SIZE 17   
DEFINE CELL NAME "COL4CR" OF oDIA ALIAS "TRB" TITLE cDSC04C PICTURE cPICTURED SIZE 17     
 
DEFINE CELL NAME "COL5DB" OF oDIA ALIAS "TRB" TITLE cDSC05D PICTURE cPICTURED SIZE 17     
DEFINE CELL NAME "COL5CR" OF oDIA ALIAS "TRB" TITLE cDSC05C PICTURE cPICTURED SIZE 17    

// DEFINE CELL NAME "COL6DB" OF oDIA ALIAS "TRB" TITLE cDSC06D PICTURE cPICTURED SIZE 17   AUTO SIZE
// DEFINE CELL NAME "COL6CR" OF oDIA ALIAS "TRB" TITLE cDSC06C PICTURE cPICTURED SIZE 17   AUTO SIZE

// quebra da pagina por CT2_DATA
DEFINE BREAK oBreak OF oDIA WHEN oDIA:Cell("FECHAD") PAGE BREAK  

// totalizadores das colunas 
DEFINE FUNCTION oF01 FROM oDIA:Cell("COL1DB") FUNCTION SUM BREAK oBreak OF oDIA PICTURE cPICTURED NO END SECTION NO END REPORT
DEFINE FUNCTION oF02 FROM oDIA:Cell("COL1CR") FUNCTION SUM BREAK oBreak OF oDIA PICTURE cPICTURED NO END SECTION NO END REPORT
DEFINE FUNCTION oF03 FROM oDIA:Cell("COL2DB") FUNCTION SUM BREAK oBreak OF oDIA PICTURE cPICTURED NO END SECTION NO END REPORT
DEFINE FUNCTION oF04 FROM oDIA:Cell("COL2CR") FUNCTION SUM BREAK oBreak OF oDIA PICTURE cPICTURED NO END SECTION NO END REPORT
DEFINE FUNCTION oF05 FROM oDIA:Cell("COL3DB") FUNCTION SUM BREAK oBreak OF oDIA PICTURE cPICTURED NO END SECTION NO END REPORT
DEFINE FUNCTION oF06 FROM oDIA:Cell("COL3CR") FUNCTION SUM BREAK oBreak OF oDIA PICTURE cPICTURED NO END SECTION NO END REPORT
DEFINE FUNCTION oF07 FROM oDIA:Cell("COL4DB") FUNCTION SUM BREAK oBreak OF oDIA PICTURE cPICTURED NO END SECTION NO END REPORT
DEFINE FUNCTION oF08 FROM oDIA:Cell("COL4CR") FUNCTION SUM BREAK oBreak OF oDIA PICTURE cPICTURED NO END SECTION NO END REPORT
DEFINE FUNCTION oF09 FROM oDIA:Cell("COL5DB") FUNCTION SUM BREAK oBreak OF oDIA PICTURE cPICTURED NO END SECTION NO END REPORT
DEFINE FUNCTION oF10 FROM oDIA:Cell("COL5CR") FUNCTION SUM BREAK oBreak OF oDIA PICTURE cPICTURED NO END SECTION NO END REPORT
// DEFINE FUNCTION oF11 FROM oDIA:Cell("COL6DB") FUNCTION SUM BREAK oBreak OF oDIA PICTURE cPICTURED NO END SECTION NO END REPORT
// DEFINE FUNCTION oF12 FROM oDIA:Cell("COL6CR") FUNCTION SUM BREAK oBreak OF oDIA PICTURE cPICTURED NO END SECTION NO END REPORT

// HEADER BORDER oReport 
DEFINE HEADER BORDER OF oReport EDGE_ALL 

// CELL  BORDER  
DEFINE CELL BORDER OF oDIA EDGE_ALL  

// CELL HEADER BORDER  
DEFINE CELL HEADER BORDER OF oDIA EDGE_ALL 

Return oReport

// 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrintReport(oReport) บAutor  ณMicrosiga           บFecha ณ 21/02/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBR                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrintReport(oReport)   

// alimentar o arquivo TRB
REPORT121()

MakeSqlExp(cPerg)

oREPORT:SETMETER(RECCOUNT())
oReport:Section(1):Print()
oREPORT:INCMETER()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณREPORT121 บAutor  ณMicrosiga           บFecha ณ 21/02/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria o arq. temporario com filtro para o CTBR470           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBR470                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function REPORT121()
Local nII , nIJ

cQUERY1 += "SELECT DISTINCT CT1_CONTA, CT2.R_E_C_N_O_ CT2_RECNO, CT2_DATA,  " 
cQUERY1 += "( Case 	When  CT2_DC = '3' AND CT2_DEBITO = CT1_CONTA Then '1'   "  
cQUERY1 += "	   	When  CT2_DC = '3' AND CT2_CREDIT = CT1_CONTA Then '2'   "
cQUERY1 += "	 	Else  CT2_DC 	End) AS  CT2_DC, " //CT2_DC,
cQUERY1 += "( Case When  CT2_DEBITO = CT1_CONTA Then CT2_DEBITO Else  'DB' End) AS  CT2_DEBITO, " //CT2_DEBITO, " 
cQUERY1 += "( Case When  CT2_CREDIT = CT1_CONTA Then CT2_CREDIT Else  'CR' End) AS  CT2_CREDIT, " //CT2_CREDIT, " 
cQUERY1 += "CT2.CT2_LP, CT2_VALOR, CT2_HIST"
cQUERY1 += " FROM " + RetSqlName("CT1") + " CT1"
cQUERY1 +=     ", " + RetSqlName("CT2") + " CT2"
cQUERY1 += " WHERE CT1_FILIAL 		= 	'" + xFilial("CT1") + "'"
cQUERY1 += "   AND CT1.D_E_L_E_T_ 	= 	' '"

IF "" == ((cCOL01 + cCOL02 + cCOL03 + cCOL04 + cCOL05))
	return
ELSE
	cQUERY1 += " AND ("
ENDIF

IF "" <> ALLTRIM(cCOL01)
	cQUERY1 +=   " CT1.CT1_CONTA LIKE '"+Substr(cCOL01,1,5)+ "%'"    
ENDIF

IF "" <> ALLTRIM(cCOL02)
	IF "" <> ALLTRIM(cCOL01)
		cQUERY1 +=" OR"
	ENDIF
	cQUERY1 +=   " CT1.CT1_CONTA LIKE '"+Substr(cCOL02,1,5)+ "%'" 
ENDIF

IF "" <> ALLTRIM(cCOL03)
	IF ("" <> ALLTRIM(cCOL01) .OR. "" <> ALLTRIM(cCOL02) )
		cQUERY1 +=" OR"
	ENDIF
	cQUERY1 +=  " CT1.CT1_CONTA LIKE '"+Substr(cCOL03,1,5)+ "%'" 
ENDIF

IF "" <> ALLTRIM(cCOL04)
	IF ("" <> ALLTRIM(cCOL01) .OR. "" <> ALLTRIM(cCOL02) .OR. "" <> ALLTRIM(cCOL03))
		cQUERY1 +=" OR"
	ENDIF
	cQUERY1 +=   " CT1.CT1_CONTA LIKE '"+Substr(cCOL04,1,5)+ "%'" 
ENDIF

IF "" <> ALLTRIM(cCOL05)
	IF ("" <> ALLTRIM(cCOL01) .OR. "" <> ALLTRIM(cCOL02) .OR. "" <> ALLTRIM(cCOL03) .OR. "" <> ALLTRIM(cCOL04))
		cQUERY1 +=" OR"
	ENDIF
	cQUERY1 +=   " CT1.CT1_CONTA LIKE '"+Substr(cCOL05,1,5)+ "%'" 
ENDIF

cQUERY1 +=   " )"
cQUERY1 +=   " AND CT2_FILIAL = '" + xFilial('CT2') + "'"
cQUERY1 +=   " AND CT2.D_E_L_E_T_ = ' '"
cQUERY1 +=   " AND CT2.CT2_DATA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
If "" <> ALLTRIM(MV_PAR03)
	cQUERY1 +=   " AND CT2.CT2_MOEDLC ='" + MV_PAR03 + "'"
EndIf
If "" <> ALLTRIM(MV_PAR04)
	cQUERY1 +=   " AND CT2.CT2_TPSALD ='" + MV_PAR04 + "'"
EndIf	
cQUERY1 +=   " AND (CT1_CONTA = CT2_DEBITO OR CT1_CONTA = CT2_CREDIT)  "
cQUERY1 +=   " ORDER BY CT2.CT2_DATA, CT2.CT2_LP, CT2_RECNO"
cQUERY1 := CHANGEQUERY(cQUERY1)

TcQuery cQUERY1 New Alias "DIARIO"

aEval(aStru, {|e| If(UPPER(e[2]) != "C", TCSetField("DIARIO", e[1], e[2],e[3],e[4]),Nil)})

DBSELECTAREA("DIARIO")
DBGOTOP()
IF (EOF() .OR. BOF())
	DBSELECTAREA("DIARIO")
	dbCloseArea()
	MsgInfo( STR0010 ,STR0001) // "ARQ.DIARIO AUXILIAR VAZIO!" // "CTBR470"
	RETURN
ENDIF
M_CT2REC:= CT2_RECNO

DO WHILE (! DIARIO->(EOF()))
	// VERIFICAR O HISTORICO / LANCAMENTO PADRAO.
	m_HIST :=  SUBS(DIARIO->CT2_LP + " " + CT2_HIST + SPACE(40),1,40) 
	
	nCOLDEB := {0,0,0,0,0,0}
	nCOLCRE := {0,0,0,0,0,0}
	nII := 6
	nIJ := 6
	IF 	CT2_VALOR <> 0
	   	// COLUNAS DO CREDITO
		IF (CT2_DC == '2' )
			IF Substr(cCOL01,1,5) $ subs(ALLTRIM(Substr(CT2_CREDIT,1,5)) + SPACE(nCOL01), 1 ,nCOL01) .And.  nCOL01 <> 0
				nIJ :=  1
			ELSEIF Substr(cCOL02,1,5) $ subs(ALLTRIM(Substr(CT2_CREDIT,1,5)) + SPACE(nCOL02), 1 ,nCOL02) .And.  nCOL02 <> 0
				nIJ :=  2
			ELSEIF Substr(cCOL03,1,5) $ subs(ALLTRIM(Substr(CT2_CREDIT,1,5)) + SPACE(nCOL03), 1 ,nCOL03) .And.  nCOL03 <> 0
				nIJ :=  3
			ELSEIF Substr(cCOL04,1,5) $ subs(ALLTRIM(Substr(CT2_CREDIT,1,5)) + SPACE(nCOL04), 1 ,nCOL04) .And.  nCOL04 <> 0
				nIJ :=  4
			ELSEIF Substr(cCOL05,1,5) $ subs(ALLTRIM(Substr(CT2_CREDIT,1,5)) + SPACE(nCOL05), 1 ,nCOL05) .And.  nCOL05 <> 0
				nIJ :=  5
			ENDIF
			nCOLCRE[nIJ] := CT2_VALOR
		ENDIF

		// COLUNAS DO DEBITO
	 	IF (CT2_DC == '1' ) 
			IF Substr(cCOL01,1,5) $ subs(ALLTRIM(Substr(CT2_DEBITO,1,5)) + SPACE(nCOL01), 1 ,nCOL01) .And.  nCOL01 <> 0
				nII :=  1
			ELSEIF Substr(cCOL02,1,5) $ subs(ALLTRIM(Substr(CT2_DEBITO,1,5)) + SPACE(nCOL02), 1 ,nCOL02) .And.  nCOL02 <> 0 
				nII :=  2
			ELSEIF Substr(cCOL03,1,5) $ subs(ALLTRIM(Substr(CT2_DEBITO,1,5)) + SPACE(nCOL03), 1 ,nCOL03) .And.  nCOL03 <> 0
				nII :=  3
			ELSEIF Substr(cCOL04,1,5) $ subs(ALLTRIM(Substr(CT2_DEBITO,1,5)) + SPACE(nCOL04), 1 ,nCOL04) .And.  nCOL04 <> 0
				nII :=  4
			ELSEIF Substr(cCOL05,1,5) $ subs(ALLTRIM(Substr(CT2_DEBITO,1,5)) + SPACE(nCOL05), 1 ,nCOL05) .And.  nCOL05 <> 0
				nII :=  5
			ENDIF
			nCOLDEB[nII] := CT2_VALOR
		ENDIF
		DBSELECTAREA("TRB")
		
		// INCLUIR REGISTRO DO EVENTO DO DIA XYZ NO TRB
		IF DBSEEK(DIARIO->( DTOS(CT2_DATA) ) + DIARIO->CT2_LP + m_HIST )
			m_Add:= .F.
			RECLOCK("TRB", .F. )
		ELSE
			m_Add:= .T.
			RECLOCK("TRB", .T. )
			TRB->FECHAD   := DIARIO->CT2_DATA
			TRB->IDENT    := DIARIO->CT2_LP
			TRB->CONCEPTO := m_HIST
		ENDIF
		
		TRB->COL1DB += nCOLDEB[1]
		TRB->COL2DB += nCOLDEB[2]
		TRB->COL3DB += nCOLDEB[3]
		TRB->COL4DB += nCOLDEB[4]
		TRB->COL5DB += nCOLDEB[5]
		TRB->COL6DB += nCOLDEB[6]
		
		TRB->COL1CR += nCOLCRE[1]
		TRB->COL2CR += nCOLCRE[2]
		TRB->COL3CR += nCOLCRE[3]
		TRB->COL4CR += nCOLCRE[4]
		TRB->COL5CR += nCOLCRE[5]
		TRB->COL6CR += nCOLCRE[6]
		MSUNLOCK()
	ENDIF

	DBSELECTAREA("DIARIO")
	DBSKIP()
	M_CT2REC:= CT2_RECNO
ENDDO

RETURN
