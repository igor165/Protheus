#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "SHELL.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSR446   บAutor  ณMicrosiga           บ Data ณ  06/18/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PLSR446()
Local aArea 		:= GetArea()
Local aAreaAF8 		:= {}
Local oReport
Private cPerg := "PLR446"

dbSelectArea("CT2")
aAreaAF8 := CT2->(GetArea())
dbSetOrder(1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInterface de impressao                                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oReport := ReportDef()
oReport:PrintDialog()

RestArea(aAreaAF8)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportDef บAutor  ณMicrosiga           บ Data ณ  06/18/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ReportDef()
Local cPerg		:= "PLR446"
Local cDesc1    := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2    := "de acordo com os parametros informados pelo usuario."
Local cDesc3    := "RELATORIO CONFERสNCIA CONTมBIL PLS"
Local cTitulo   := "RELATORIO CONFERสNCIA CONTมBIL PLS"
Local oReport
Local oSection1,oSection2
Local aOrdem 	:= {}
Local nPrazoRev := GetNewPar("MV_PLPRREV",0)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCriacao do componente de impressao                                      ณ
//ณ                                                                        ณ
//ณTReport():New                                                           ณ
//ณExpC1 : Nome do relatorio                                               ณ
//ณExpC2 : Titulo                                                          ณ
//ณExpC3 : Pergunte                                                        ณ
//ณExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ณ
//ณExpC5 : Descricao                                                       ณ
//ณ                                                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
cPerg := "PLR446"
	

oReport := TReport():New("PLR446",cTitulo, cPerg,{|oReport| ReportPrint(oReport)},"RELATORIO CONFERสNCIA CONTมBIL PLS")

Pergunte(cPerg,.F.)

oReport:SetLandscape()

//oSection1 := TRSection():New(oReport,"Vendedores","TRB") 
//TRCell():New(oSection1,"F2_VEND1","TRB","Vendedor")
//TRCell():New(oSection1,"A3_NOME","TRB")
//TRFunction():New(oSection1:Cell("F2_VEND1"),NIL,"COUNT",NIL,NIL,NIL,NIL,.F.)
                                             

oSection1 := TRSection():New(oReport,cTitulo,"TRB")  //TRSection():New(oReport, "", {"TRB"}, aOrdem /*{}*/, .F., .F.)
                                                     
TRCell():New( oSection1 ,"DTAVISO" ,"TRB","DATA AVISO"   		,"@R 99/99/9999",10,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New( oSection1 ,"DTCTB"   ,"TRB","DATA CONTABIL"		,"@R 99/99/9999",10,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New( oSection1 ,"TIPOCTB" ,"TRB","TIPO"         		,"@!",03,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New( oSection1 ,"VLRBPR"  ,"TRB","VLR COBRANวA" 		,"@E 9,999,999.99",15,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New( oSection1 ,"VLRREV"  ,"TRB","VLR PROV/REV" 		,"@E 9,999,999.99",15,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New( oSection1 ,"VLRGLO"  ,"TRB",'VLR GLOSA'    		,"@E 9,999,999.99",15,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New( oSection1 ,"VLRPAG"  ,"TRB",'VLR PAGO'     		,"@E 9,999,999.99",15,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New( oSection1 ,"VLRCTB"  ,"TRB",'VLR CONTABIL' 		,"@E 9,999,999.99",15,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New( oSection1 ,"DOCCTB"  ,"TRB",'DOCUMENTO CTB'		,"@!",30,/*lPixel*/,{|| alltrim(TRB->CODRDA)+ '-' + alltrim(TRB->NOME) + '/' + alltrim(TRB->CLASSE) + '/' + alltrim(TRB->TIPORDA) })
TRCell():New( oSection1 ,"DEBITO"  ,"TRB",'CTA DEBITO'   		,"@!",20,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New( oSection1 ,"CCDEB"   ,"TRB",'CC DEBITO'    		,"@!",20,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New( oSection1 ,"CREDITO" ,"TRB","CTA CREDITO"  		,"@!",20,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New( oSection1 ,"CCCRED"  ,"TRB","CC CREDITO."  		,"@!",20,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New( oSection1 ,"GUIA"    ,"TRB","GUIA"                ,"@!",47,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New( oSection1 ,"PROCEDIM","TRB","PROCEDIMENTO"        ,"@!",15,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New( oSection1 ,"SEQUEN"  ,"TRB","SEQ"                 ,"@!",06,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New( oSection1 ,"CODUNID" ,"TRB","UNM"                 ,"@!",06,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New( oSection1 ,"BENEF"   ,"TRB","BENEFIC"             ,"@!",19,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New( oSection1 ,"CODPROD" ,"TRB","PLAN"                ,"@!",05,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New( oSection1 ,"cREV"  ,"","PRZ REV EXPI" ,"@!",05,/*lPixel*/,{||cRev:= IIF(DDATABASE-TRB->DTCTB > nPrazoRev.and. nPrazoRev > 0.AND. Empty(TRB->DTREV),"S","N")   })
  
oReport:SetTotalInLine(.F.)
Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSR446   บAutor  ณMicrosiga           บ Data ณ  06/18/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ReportPrint(oReport)

Local oSection1 	:= oReport:Section(1)
Local oBreak
Local cChave    	:= "F2_VEND1"
Local TRB 	:= GetNextAlias()


//Insere no Titulo do relat๓rio informa็๕es de conversใo da moeda
oReport:SetTitle( oReport:Title())

//
// Motagem da query de SELECT dos campos desejados e os devidos "JOINS" referentes aos pedidos de compras associados com projeto e tarefa
//        

If Select('TRB') <> 0
	DbSelectArea('TRB')                        
	DbCloseArea()
EndIf	
cSql	:= "SELECT BD7.BD7_DTDIGI AS DTAVISO, "
cSql	+= "CT2.CT2_DATA  AS DTCTB, "

If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
	cSql	+= "DECODE(CV3.CV3_LP,'9CL','P', '9CM', 'P', '9CN','P', '9CO', 'R', '9CP', 'R', '9CQ', 'R', '9CR','C', '9CS', 'C', '9CT', 'C', 'X' ) AS TIPOCTB, "
	if mv_par04 == 1
		cSql	+= "DECODE(CV3.CV3_LP,'9CL',BD7.BD7_VLPRV, '9CM', BD7.BD7_VLPRV, '9CN',BD7.BD7_VLPRV, 0 ) AS VLRREV, "
	Else	
		cSql	+= "DECODE(CV3.CV3_LP,'9CO',BD7.BD7_VLPRV, '9CP', BD7.BD7_VLPRV, '9CQ',BD7.BD7_VLPRV, 0 ) AS VLRREV, "
	EndIf	
	cSql	+= "DECODE(CV3.CV3_LP,'9CR',BD7.BD7_VLRPAG, '9CS', BD7.BD7_VLRPAG, '9CT',BD7.BD7_VLRPAG, 0 ) AS VLRPAG, "
Else
	cSql	+= " CASE WHEN CV3.CV3_LP = '9CL' THEN 'P'                                   "
	cSql	+= "      WHEN CV3.CV3_LP = '9CM' THEN 'P'                                   "
	cSql	+= "      WHEN CV3.CV3_LP = '9CN' THEN 'P'                                   "
	cSql	+= "      WHEN CV3.CV3_LP = '9CO' THEN 'R'                                   "
	cSql	+= "      WHEN CV3.CV3_LP = '9CP' THEN 'R'                                   "
	cSql	+= "      WHEN CV3.CV3_LP = '9CQ' THEN 'R'                                   "
	cSql	+= "      WHEN CV3.CV3_LP = '9CR' THEN 'C'                                   "
	cSql	+= "      WHEN CV3.CV3_LP = '9CS' THEN 'C'                                   "
	cSql	+= "      WHEN CV3.CV3_LP = '9CT' THEN 'C' ELSE 'X' END AS TIPOCTB,          "
    if mv_par04 == 1 
		cSql	+= " CASE WHEN CV3.CV3_LP = '9CL' THEN BD7.BD7_VLPRV                        "
		cSql	+= "      WHEN CV3.CV3_LP = '9CM' THEN BD7.BD7_VLPRV                        "
		cSql	+= "      WHEN CV3.CV3_LP = '9CN' THEN BD7.BD7_VLPRV ELSE 0 END  AS VLRREV, "
    Else
		cSql	+= " CASE WHEN CV3.CV3_LP = '9CO' THEN BD7.BD7_VLPRV                         "
		cSql	+= "      WHEN CV3.CV3_LP = '9CP' THEN BD7.BD7_VLPRV                         "
		cSql	+= "      WHEN CV3.CV3_LP = '9CQ' THEN BD7.BD7_VLPRV  ELSE 0 END AS VLRREV,  "
	EndIf
	cSql	+= " CASE WHEN CV3.CV3_LP = '9CR' THEN BD7.BD7_VLRPAG                        "
	cSql	+= "      WHEN CV3.CV3_LP = '9CS' THEN BD7.BD7_VLRPAG                        "
	cSql	+= "      WHEN CV3.CV3_LP = '9CT' THEN BD7.BD7_VLRPAG ELSE 0 END AS VLRPAG,  "
Endif

cSql	+= "BD7.BD7_VLRGLO AS VLRGLO, "
cSql	+= "BD7.BD7_VLRBPR AS VLRBPR, "
cSql	+= "CV3.CV3_VLR01 AS VLRCTB, "
cSql	+= "CT2.CT2_LOTE||'.'||CT2.CT2_SBLOTE||'.'||CT2.CT2_DOC||'.'||CT2.CT2_LINHA AS DOCCTB, "
cSql	+= "CV3.CV3_DEBITO AS DEBITO, "
cSql	+= "CV3.CV3_CCD AS CCDEB, "
cSql	+= "CV3.CV3_CREDIT AS CREDITO, "
cSql	+= "CV3.CV3_CCC AS CCCRED, "
cSql	+= "BD7.BD7_CODRDA AS CODRDA, "
cSql	+= "BAU.BAU_NOME AS NOME, "
cSql	+= "BAU.BAU_TIPPRE AS CLASSE, "
cSql	+= "BAU.BAU_TIPPE AS TIPORDA, "
cSql	+= "BD7.BD7_CODOPE||'.'||BD7_CODLDP||'.'||BD7.BD7_CODPEG||'.'||BD7.BD7_NUMERO||'.'||BD7_ORIMOV||'.'||BD7_SEQUEN AS GUIA, "
cSql	+= "BD7.BD7_CODPRO AS PROCEDIM, "
cSql	+= "BD7.BD7_SEQUEN AS SEQUEN, "
cSql	+= "BD7.BD7_CODUNM AS CODUNID, "
cSql	+= "BD7.BD7_DTREV AS DTREV, "
cSql	+= "BD7.BD7_CODEMP||'.'||BD7.BD7_MATRIC||'.'||BD7.BD7_TIPREG AS BENEF, "
cSql	+= "BD7.BD7_CODPLA AS CODPROD "
cSql	+= "FROM "+RetSqlname('CV3')+" CV3,"+RetSqlName('BD7')+" BD7,"+RetSqlName('BAU')+" BAU, "+RetSqlName('CT2')+" CT2 "
cSql	+= "WHERE "
cSql	+= "CV3.CV3_DTSEQ BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
cSql	+= "AND CV3.CV3_TABORI = 'BD7' "   
If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
	cSql += "  AND	NVL(CAST(CV3_RECORI as int),0) = BD7.R_E_C_N_O_   " //+ chr(13) + chr(10)
Else
    cSql += " AND CONVERT(Int,CV3_RECORI) = BD7.R_E_C_N_O_ " //+ chr(13) + chr(10)
EndIf
//cSql	+= "AND CV3.CV3_RECORI  = alltrim(str(BD7.R_E_C_N_O_))    
cSql	+= "AND CV3.CV3_FILIAL = '"+xFilial("CV3")+"' "
cSql	+= "AND CT2.CT2_FILIAL = '"+xFilial("CT2")+"' "
cSql	+= "AND BD7.BD7_FILIAL = '"+xFilial("BD7")+"' "
cSql	+= "AND BAU.BAU_FILIAL = '"+xFilial("BAU")+"' "

//cSql	+= "AND CV3.CV3_RECDES  = CT2.R_E_C_N_O_ "
If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
	cSql += "	AND NVL(CAST(CV3_RECDES as int),0) = CT2.R_E_C_N_O_   " //+ chr(13) + chr(10)
Else
    cSql += " AND CONVERT(Int,CV3_RECDES) = CT2.R_E_C_N_O_ " //+ chr(13) + chr(10)
EndIf
//--cSql	+= "AND CV3.CV3_DTSEQ   = CT2.CT2_DATA "
//If MV_PAR04 <> 2
//	cSql	+= "AND BD7.BD7_DTDIG1   = CT2.CT2_DATA "
//EndIf
cSql	+= "AND CV3.CV3_SEQUEN  = CT2.CT2_SEQUEN "
cSql	+= "AND BD7.BD7_CODRDA  = BAU.BAU_CODIGO "
cSql	+= "AND CV3.D_E_L_E_T_ =' ' "
cSql	+= "AND BD7.D_E_L_E_T_ =' ' "
cSql	+= "AND BAU.D_E_L_E_T_ =' ' "
cSql	+= "AND CT2.D_E_L_E_T_ =' ' "
cSql	+= " AND BD7.R_E_C_N_O_ = CV3.CV3_RECORI "
//
// Tratamento aos parโmetros do relat๓rio
//
// Tipo de relat๓rio - Provisใo, Reversใo, Custo ou Todos
// se Provisใo
If MV_PAR04 == 1
	cSql	+= "AND CV3.CV3_LP IN ('9CL', '9CM', '9CN') "
	// se Reversใo
ElseIf MV_PAR04 ==2
	cSql	+= "AND CV3.CV3_LP IN ('9CO', '9CP', '9CQ') "
	// ou se Custo
ElseIf MV_PAR04 == 3
	cSql	+= "AND CV3.CV3_LP IN ('9CR', '9CS', '9CT') "
EndIf
// Operadora
cSql	+= "AND BD7.BD7_CODOPE = '"+MV_PAR05+"' "
// RDA
If !Empty(MV_PAR06) .or. !Empty(MV_PAR07)
	cSql	+= "AND BD7.BD7_CODRDA BETWEEN ('"+MV_PAR06+"') AND ('"+MV_PAR07+"') "
EndIf
// Classe da RDA
If !Empty(MV_PAR08)
	cSql	+= "AND BAU.BAU_TIPPRE IN ('"+MV_PAR08+"') "
EndIf
// Tipo de Prestador
If MV_PAR09 == 1
	cSql	+= "AND BAU.BAU_TIPPE = 'F' "
ElseIf MV_PAR09 == 2
	cSql	+= "AND BAU.BAU_TIPPE = 'J' "
EndIf
// Local de Digita็ใo
If !Empty(MV_PAR10) .or. !Empty(MV_PAR11)
	cSql	+= "AND BD7.BD7_CODLDP BETWEEN ('"+MV_PAR10+"') AND ('"+MV_PAR11+"') "
EndIf
// PEG - Protocolo
If !Empty(MV_PAR12) .or. !Empty(MV_PAR13)
	cSql	+= "AND BD7.BD7_CODPEG BETWEEN ('"+MV_PAR12+"') AND ('"+MV_PAR13+"') "
EndIf
// Guia
If !Empty(MV_PAR14) .or. !Empty(MV_PAR15)
	cSql	+= "AND BD7.BD7_NUMERO BETWEEN ('"+MV_PAR14+"') AND ('"+MV_PAR15+"') "
EndIf
// Grupo Empresa
If !Empty(MV_PAR16) .or. !Empty(MV_PAR17)
	cSql	+= "AND BD7.BD7_CODEMP BETWEEN ('"+MV_PAR16+"') AND ('"+MV_PAR17+"') "
EndIf
// Contrato
If !Empty(MV_PAR18) .or. !Empty(MV_PAR19)
	cSql	+= "AND BD7.BD7_CONEMP BETWEEN ('"+MV_PAR18+"') AND ('"+MV_PAR19+"') "
EndIf
// Versใo Contrato
If !Empty(MV_PAR20) .or. !Empty(MV_PAR21)
	cSql	+= "AND BD7.BD7_VERCON BETWEEN ('"+MV_PAR20+"') AND ('"+MV_PAR21+"') "
EndIf
// Subcontrato
If !Empty(MV_PAR22) .or. !Empty(MV_PAR23)
	cSql	+= "AND BD7.BD7_SUBCON BETWEEN ('"+MV_PAR22+"') AND ('"+MV_PAR23+"') "
EndIf
// Versใo Subcontrato
If !Empty(MV_PAR24) .or. !Empty(MV_PAR25)
	cSql	+= "AND BD7.BD7_VERSUB BETWEEN ('"+MV_PAR24+"') AND ('"+MV_PAR25+"') "
EndIf
// Produto
If !Empty(MV_PAR26)
	cSql	+= "AND BD7.BD7_CODPLA IN ('"+MV_PAR26+"') "
EndIf
// Data de Aviso
If MV_PAR27 == 1
	cSql	+= "ORDER BY DTAVISO, CODRDA, GUIA, PROCEDIM, SEQUEN, DTCTB, DOCCTB --CV3_SEQUEN, CV3_LP, CV3_LPSEQ "
	// Data de Contabiliza็ใo
Else
	cSql	+= "ORDER BY DTCTB, DOCCTB, CODRDA, DTAVISO, GUIA, PROCEDIM, SEQUEN  --CV3_SEQUEN, CV3_LP, CV3_LPSEQ "
EndIf

cSql := ChangeQuery(cSql)
If Select("Trb") > 0
	Trb->( dbCloseArea() )
EndIf

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB",.F.,.T.)

TcSetField("TRB","DTAVISO","D",8,0)
TcSetField("TRB","DTCTB","D",8,0)
TcSetField("TRB","DTREV","D",8,0)
TcSetField("TRB","VLRAPR","N",TamSX3('CT2_VALOR')[1],TamSX3('CT2_VALOR')[2])
TcSetField("TRB","VLRREV","N",TamSX3('CT2_VALOR')[1],TamSX3('CT2_VALOR')[2])
TcSetField("TRB","VLRPAG","N",TamSX3('CT2_VALOR')[1],TamSX3('CT2_VALOR')[2])
TcSetField("TRB","VLRGLO","N",TamSX3('CT2_VALOR')[1],TamSX3('CT2_VALOR')[2])
TcSetField("TRB","VLRBPR","N",TamSX3('CT2_VALOR')[1],TamSX3('CT2_VALOR')[2])
TcSetField("TRB","VLRCTB","N",TamSX3('CT2_VALOR')[1],TamSX3('CT2_VALOR')[2])

If Trb->(EoF())
	MsgInfo(' Nใo hแ dados para exibi็ใo. ')
	Trb->( dbCloseArea() )
	Return
EndIf
ProcRegua(TRB->(RecCount()))


oSection1:Cell("VLRBPR"  ):SetBlock({|| ("TRB")->(VLRBPR)   })
oSection1:Cell("VLRREV" ):SetBlock({|| ("TRB")->(VLRREV)  })
oSection1:Cell("VLRGLO"  ):SetBlock({|| ("TRB")->(VLRGLO)   })
oSection1:Cell("VLRPAG"):SetBlock({|| ("TRB")->(VLRPAG) })
oSection1:Cell("VLRCTB"):SetBlock({|| ("TRB")->(VLRCTB) })

//oBreak := TRBreak():New ( oSection1 , oSection1:Cell("F2_VEND1") , OemToAnsi('TOTAL RELATORIO'))//+Str(oSection1:Cell("N3_TXDEPR1"):GetValue(),8,2), )
TRFunction():New ( oSection1:Cell("VLRBPR")  , , "SUM" ,  oBreak , , , , .F. ,  )
TRFunction():New ( oSection1:Cell("VLRREV") , , "SUM" , oBreak , , , , .F. ,  )
TRFunction():New ( oSection1:Cell("VLRGLO" ) , , "SUM" , oBreak , , , , .F. ,  )
TRFunction():New ( oSection1:Cell("VLRPAG"), , "SUM" ,oBreak , , , , .F. ,  )
TRFunction():New ( oSection1:Cell("VLRCTB"), , "SUM" ,oBreak , , , , .F. ,  )
//oReport:SetTotalInLine(.F.)

oSection1:Print()

Return
