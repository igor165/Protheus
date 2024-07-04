#INCLUDE "HSPAHR01.ch"
#INCLUDE "PROTHEUS.CH"      
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#define TRACE repl("_",80)
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HSPAHR01  ∫ Autor ≥ Mario Arizono      ∫ Data ≥  17/10/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Criar relatorio que apresente informacoes da Prod. Ambula		∫±±
±±∫          ≥ torial        																																						       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar                                   ∫±±    
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Function HSPAHR01(cCodPla, cMesRef)

Local cDesc1       	:= STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2       	:= STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3       	:= ""
Local cPict        	:= ""
Local titulo       	:= ""
Local nLin         	:= 80
Local Cabec1       	:= ""
Local Cabec2       	:= ""
Local imprime      	:= .T.
Local aOrd 									:= {}
Local nTpForm       := 0
Private lEnd       	:= .F.
Private lAbortPrint	:= .F.
Private limite     	:= 80
Private tamanho    	:= "P"
Private nomeprog   	:= "HSPAHR01" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo      	:= 18
Private aReturn    	:= { STR0003, 1, STR0004, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey   	:= 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "HSPAHR01" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString 				:= "GE7"
Private nMaxLin 				:= 0 // quantidade maxima de linhas p/ impressao
Private cCODIMP					:= ""
Private cCodPlaR				:= "", cMesRefR := ""
Private nImpress    := 0, nOrdemI := 0
Private cCnes       := getMv("MV_HSPCNES",,"")
Private cNome       := Hs_IniPadr("GAZ",1 , getMv("MV_HSPPRE",,""), "GAZ_FANPRE",, .F.)

/* Chamado pelo MENU */

If FunName() == "HSPAHR01"
 
	If Pergunte("HSR01A", .T.)
		cCodPlaR := MV_PAR01
		cMesRefR := MV_PAR02
 	nImpres  := MV_PAR03
	 nOrdemI  := MV_PAR04
	 nTpForm  := MV_PAR05
		cCODIMP		:= MV_PAR06
	Else
	 Return(nil)
	EndIf

Else

	If Pergunte("HSR01B", .T.)
		cCodPlaR := cCodPla
		cMesRefR := cMesRef
		nImpres  := 1
		nOrdemI  := 1 
		cCODIMP		:= MV_PAR01
	Else
	 Return(nil)
	EndIf
	
EndIf

Titulo := STR0005 + "-" + STR0006 + cMesRefR   //"Prod. Ambulatorial"##"MÍs Ref.: "

 If nTpForm == 1
  Processa({|| Fs_BPACons()  })
 Else                           
  Processa({|| Fs_BPAInd()  })  
 EndiF 

Return

Function Hs_RMesAno(dDataRef, lAnoMes, lSepara)
 Local aArea   := GetArea()
 Local nQtdDig := IIF(Len(DTOC(dDataBase)) > 8, 4, 2) 
 Local cRet    := ""          
 Local cAno    := ""
 Local cMes    := ""
 Local cSep    := "" 

 Default lSepara := .F.
 Default lAnoMes := .F.

 cSep := IF(lSepara, "/", "")

 If ValType(dDataRef) == "C" 
  dDataRef := CToD("01/"+dDataRef)
Endif

 If nQtdDig == 2 
  SET DATE FORMAT "dd/mm/yyyy"
 EndIf 

 cMes := SubStr(DToC(dDataRef),4,2)
 cAno := AllTrim(Str(Year(dDataRef))) 

 cRet := IIF(lAnoMes, cAno + cSep + cMes, cMes + cSep + cAno)

 SET DATE FORMAT "dd/mm/"+REPLICATE("y",nQtdDig) 

 RestArea(aArea)
Return({cRet, cMes, cAno})

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫FunáÑo    ≥RUNREPORT ∫ Autor ≥ AP6 IDE            ∫ Data ≥  17/10/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DescriáÑo ≥ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ∫±±
±±∫          ≥ monta a janela com a regua de processamento.               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Programa principal                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Static Function Fs_BPACons()

 Local nSeqProc := 0
 Local cSql       := ""
 Local cCmdSubStr := IIf(TcGetDb() = "MSSQL","SUBSTRING","SUBSTR")
 
 Private nLinPos  := 0
 Private nTot  := 0 
 Private nLinMax	:=  3160	
	Private nColMax	:=  2400
 Private nSeqPag := 0
 
                           //New([acName]     , [nPar2], [anHeight], [lPar4], [alBold], [nPar6], [lPar7], [nPar8], [alItalic], [alUnderline]) 
 Private oFont   	 := TFont():New("Courier New",     10 , 10         ,        , .F.    ,        ,        ,        , .T.       , .F.) // Normal
 Private oFont1  	 := TFont():New("Courier New",     10 , 12         ,        , .F.    ,        ,        ,        , .T.       , .F.) // Normal 
 Private oFontTit	:= TFont():New("Courier New",     12 , 12         ,        , .T.    ,        ,        ,        , .F.       , .F.)  
 Private oFontTit1 := TFont():New("Courier New",     10 , 10         ,        , .F.    ,        ,        ,        , .T.       , .F.) // Normal
 Private oFontTit2 := TFont():New("Courier New",     10 , 10         ,        , .T.    ,        ,        ,        , .T.       , .F.) // Normal
 Private oFontCab  := TFont():New("Courier New",        , 11         ,        , .T.    ,        ,        ,        , .F.       , .F.) // Normal
                  
	cSql := "  SELECT GE7.GE7_CODPRT CODDES,        "
	cSql += "         GHD.GHD_CODCBO CODCBO,        "	
	cSql += "         " + cCmdSubStr + "(GCY.GCY_IDADE,1,3) IDADE,          "
	cSql += "         SUM(GE7.GE7_QTDDES) QTDDES    "
	cSql += "    FROM " + RetSqlName("GE7") + " GE7    "
 	cSql += "    JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GE7.GE7_CODDES "
 	cSql += "    JOIN " + RetSqlName("GK6") + " GK6 ON GK6.GK6_FILIAL = '" + xFilial("GK6") + "' AND GK6.D_E_L_E_T_ <> '*' AND GK6.GK6_CODPRO = GA7.GA7_CODPRO "
 	cSql += "    AND GK6.GK6_CODINR = '01' " // '01' = BPA consolidado Valor chumbado pois esse dado vem da tabela unificada
	cSql += "    JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = GE7.GE7_REGATE "
	cSql += "    JOIN " + RetSqlName("GD1") + " GD1 ON GD1.GD1_FILIAL = '" + xFilial("GD1") + "' AND GD1.D_E_L_E_T_ <> '*' AND GD1.GD1_CARATE = GCY.GCY_CARATE "
	cSql += "    JOIN " + RetSqlName("GBJ") + " GBJ ON GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*' AND GBJ.GBJ_CRM    = GE7.GE7_CODCRM "
	cSql += "    JOIN " + RetSqlName("GHD") + " GHD ON GHD.GHD_FILIAL = '" + xFilial("GHD") + "' AND GHD.D_E_L_E_T_ <> '*' AND GHD.GHD_CODPRO = GE7.GE7_CODDES "
	cSql += "    JOIN " + RetSqlName("GCZ")+" GCZ ON GCZ.GCZ_FILIAL = '"+xFilial("GCZ")+"' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = GE7.GE7_NRSEQG  "
	cSql += "    JOIN " + RetSqlName("GAT")+" GAT ON GAT.GAT_FILIAL = '"+xFilial("GAT")+"' AND GAT.D_E_L_E_T_ <> '*' AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE  "
	cSql += "    JOIN " + RetSqlName("GLZ")+" GLZ ON GLZ.GLZ_FILIAL = '"+xFilial("GLZ")+"' AND GLZ.D_E_L_E_T_ <> '*' AND GLZ.GLZ_CODPRO = GE7.GE7_CODDES AND GLZ.GLZ_CODDET ='012' "
	cSql += "	 WHERE GE7.GE7_FILIAL = '"+xFilial("GE7")+"' AND GE7.D_E_L_E_T_ <> '*' AND GCZ.GCZ_CODPLA = '" + cCodPlaR + "'"
 	cSql += "    AND GAT.GAT_MESREF  = '" + cMesRefR + "'"  
 	cSql += " 	 AND (GHD.GHD_CODCBO IN (SELECT GFR.GFR_CBOSUS 
	cSql += " 	 FROM " + RetSqlName("GFR") + " GFR, "
    cSql += " 	 " + RetSqlName("GFP") + " GFP WHERE GFP.GFP_FILIAL = '"+xFilial("GFP")+ "' AND GFP.D_E_L_E_T_ <> '*' AND "
    cSql += " 	 GFP.GFP_CODESP = GFR.GFR_CDESPE AND GFP.GFP_CODCRM = GE7.GE7_CODCRM  AND GE7.GE7_CODESP = GFR.GFR_CDESPE "
    cSql += " 	 AND GFR.GFR_FILIAL = '"+xFilial("GFR")+ " ' AND GFR.D_E_L_E_T_ <> '*') 
    cSql += " 	 OR GHD.GHD_CODCBO IN (SELECT GFR.GFR_CBOSUS FROM " + RetSqlName("GFR") + " GFR, "
    cSql += " 	  " + RetSqlName("GBJ") + " GBJ WHERE GBJ.GBJ_FILIAL =  '"+xFilial("GBJ")+ "' AND GBJ.D_E_L_E_T_ <> '*' AND GBJ.GBJ_CRM = GE7.GE7_CODCRM AND GE7.GE7_CODESP = GFR.GFR_CDESPE AND "
	cSql += "   (GBJ.GBJ_ESPEC1 = GFR.GFR_CDESPE OR GBJ.GBJ_ESPEC2 = GFR.GFR_CDESPE OR GBJ.GBJ_ESPEC3 = GFR.GFR_CDESPE)" 
    cSql += " 	 AND GFR.GFR_FILIAL = '"+xFilial("GFR")+ "' AND GFR.D_E_L_E_T_ <> '*'))    
	cSql += "    GROUP BY GE7.GE7_CODPRT, GHD_CODCBO, "+cCmdSubStr+"(GCY.GCY_IDADE,1,3) "
	cSql += "  UNION        "
	cSql += "  SELECT GE7.GE7_CODPRT CODDES,        "
	cSql += "         GHD.GHD_CODCBO CODCBO,        "	
	cSql += "         '0' IDADE,          "
	cSql += "         SUM(GE7.GE7_QTDDES) QTDDES    "
	cSql += "    FROM " + RetSqlName("GE7") + " GE7    "
 	cSql += "    JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GE7.GE7_CODDES "
 	cSql += "    JOIN " + RetSqlName("GK6") + " GK6 ON GK6.GK6_FILIAL = '" + xFilial("GK6") + "' AND GK6.D_E_L_E_T_ <> '*' AND GK6.GK6_CODPRO = GA7.GA7_CODPRO "
 	cSql += "    AND GK6.GK6_CODINR = '01' " // '01' = BPA consolidado Valor chumbado pois esse dado vem da tabela unificada
	cSql += "    JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = GE7.GE7_REGATE "
	cSql += "    JOIN " + RetSqlName("GBJ") + " GBJ ON GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*' AND GBJ.GBJ_CRM    = GE7.GE7_CODCRM "
	cSql += "    JOIN " + RetSqlName("GHD") + " GHD ON GHD.GHD_FILIAL = '" + xFilial("GHD") + "' AND GHD.D_E_L_E_T_ <> '*' AND GHD.GHD_CODPRO = GE7.GE7_CODDES "
	cSql += "    JOIN " + RetSqlName("GCZ")+" GCZ ON GCZ.GCZ_FILIAL = '"+xFilial("GCZ")+"' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = GE7.GE7_NRSEQG  "
	cSql += "    JOIN " + RetSqlName("GAT")+" GAT ON GAT.GAT_FILIAL = '"+xFilial("GAT")+"' AND GAT.D_E_L_E_T_ <> '*' AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE  "
	cSql += "	 WHERE GE7.GE7_FILIAL = '"+xFilial("GE7")+"' AND GE7.D_E_L_E_T_ <> '*' AND GCZ.GCZ_CODPLA = '" + cCodPlaR + "'"
 	cSql += "    AND GAT.GAT_MESREF  = '" + cMesRefR + "'"  
 	cSql += " 	 AND (GHD.GHD_CODCBO IN (SELECT GFR.GFR_CBOSUS 
	cSql += " 	 FROM " + RetSqlName("GFR") + " GFR, "
    cSql += " 	 " + RetSqlName("GFP") + " GFP WHERE GFP.GFP_FILIAL = '"+xFilial("GFP")+ "' AND GFP.D_E_L_E_T_ <> '*' AND "
    cSql += " 	 GFP.GFP_CODESP = GFR.GFR_CDESPE AND GFP.GFP_CODCRM = GE7.GE7_CODCRM  AND GE7.GE7_CODESP = GFR.GFR_CDESPE "
    cSql += " 	 AND GFR.GFR_FILIAL = '"+xFilial("GFR")+ " ' AND GFR.D_E_L_E_T_ <> '*') 
    cSql += " 	 OR GHD.GHD_CODCBO IN (SELECT GFR.GFR_CBOSUS FROM " + RetSqlName("GFR") + " GFR, "
    cSql += " 	  " + RetSqlName("GBJ") + " GBJ WHERE GBJ.GBJ_FILIAL =  '"+xFilial("GBJ")+ "' AND GBJ.D_E_L_E_T_ <> '*' AND GBJ.GBJ_CRM = GE7.GE7_CODCRM AND GE7.GE7_CODESP = GFR.GFR_CDESPE AND "
	cSql += "   (GBJ.GBJ_ESPEC1 = GFR.GFR_CDESPE OR GBJ.GBJ_ESPEC2 = GFR.GFR_CDESPE OR GBJ.GBJ_ESPEC3 = GFR.GFR_CDESPE)" 
    cSql += " 	 AND GFR.GFR_FILIAL = '"+xFilial("GFR")+ "' AND GFR.D_E_L_E_T_ <> '*'))   "
    cSql += " 	 AND GE7.GE7_CODDES NOT IN (SELECT GLZ_CODPRO FROM  " + RetSqlName("GLZ") + "  GLZ WHERE 	GLZ.GLZ_FILIAL = '"+xFilial("GLZ")+ "' "
	cSql += "  	 AND GLZ.D_E_L_E_T_ <> '*' AND GLZ.GLZ_CODPRO = GE7.GE7_CODDES AND GLZ.GLZ_CODDET ='012' )
    cSql += "    GROUP BY GE7.GE7_CODPRT, GHD_CODCBO "
	cSql += "    ORDER BY CODDES, CODCBO "	                                                                                    
cSql := ChangeQuery(cSql)

TCQUERY cSql NEW ALIAS "QRY"

If Eof()
	HS_MsgInf(STR0011,STR0009, STR0012) //"Nenhum registro encontrado para seleÁ„o informada."###"AtenÁ„o"###"SeleÁ„o de Registros"
	DbCloseArea()
	Return(Nil)
EndIf

 ProcRegua(RecNo())   
 
 oPrint		:= TMSPrinter():New(STR0020) //"BPA CONSOLIDADO"
	
	oPrint:SetPortrait()	// Modo retrato
	oPrint:Setup()
	
 Fs_CabGf(@nSeqProc, .T.)
 
 nLinPos  := 860       
 DbSelectArea("QRY")
dbGoTop()
While !EOF()
 
  HS_ImpBox({nLinPos, 0145, nLinPos+60, 0275},,{StrZero(nSeqProc,2),Hs_Color(0), oFont1},,,.T.,oPrint)      
  HS_ImpBox({nLinPos, 0415, nLinPos+60, 0915},,{QRY->CODDES,Hs_Color(0), oFont}                        ,{10,15},,.T.,oPrint)  
  HS_ImpBox({nLinPos, 1065, nLinPos+60, 1365},,{QRY->CODCBO,Hs_Color(0), oFont}                        ,{6 ,15},,.T.,oPrint)
  HS_ImpBox({nLinPos, 1515, nLinPos+60, 1665},,{PADL(AllTrim(QRY->IDADE), 3, "0"), Hs_Color(0), oFont},{3 ,15},,.T.,oPrint)  
  HS_ImpBox({nLinPos, 1815, nLinPos+60, 2115},,{PADL(QTDDES, 5, "0"),Hs_Color(0), oFont}               ,{5,15},,.T.,oPrint) 

	 nTot += QTDDES

	 nSeqProc++             
  DbSkip()  
   
  If !EOF()
	  If Fs_CabGf(@nSeqProc)     
	   nLinPos  := 860   
	  Else    
	   nLinPos  += 90
	  EndIf 
	Else
	   nLinPos  += 90
  EndIf
 EndDo

 For nSeqProc := nSeqProc to 20
  HS_ImpBox({nLinPos, 0145, nLinPos+60, 0275},,{StrZero(nSeqProc,2),Hs_Color(0), oFont1},,,.T.,oPrint)     
  
  HS_ImpBox({nLinPos, 0415, nLinPos+60, 0915},,,{10,15},,.T.,oPrint)  
  HS_ImpBox({nLinPos, 1065, nLinPos+60, 1365},,,{6 ,15},,.T.,oPrint)
  HS_ImpBox({nLinPos, 1515, nLinPos+60, 1665},,,{3 ,15},,.T.,oPrint)  
  HS_ImpBox({nLinPos, 1815, nLinPos+60, 2115},,,{5,15},,.T.,oPrint)  
  nLinPos  += 90                          
 Next
	  
	Fs_ImpRod()
	                     
 DbSelectArea("QRY")
DbCloseArea()
 oPrint:Preview()   
Return(nil)                               
Static Function Fs_ImpRod()
 Fs_ImpTot(nLinPos, @nTot)
 HS_ImpBox({2840, 0080, nLinMax-20, nColMax-160}, {STR0021, 60, Hs_Color(0),oFontTit},,,,,oPrint) //"FormalizaÁ„o"
  
 HS_ImpBox({2890, 0120, 3090, 1120},{STR0022, 20, Hs_Color(0), oFontTit1},,,,,oPrint) //"RESPONS¡VEL(Estabelecimento de Sa˙de)"
 oPrint:Say(2910, 0160,STR0023 ,oFont) //"CARIMBO"
 oPrint:Say(2910, 0660,STR0024 ,oFont) //"RUBRICA"
 oPrint:Say(3020, 0130,STR0025 ,oFont) //"DATA"
 oPrint:Say(3020, 0260,"/"     ,oFont)
 oPrint:Say(3020, 0310,"/"     ,oFont)
  
 HS_ImpBox({2890, 1250, 3090, 2150},{STR0054, 20, Hs_Color(0), oFontTit1},,,,,oPrint) //"GESTOR MUNICIPAL/ESTADUAL"
 oPrint:Say(2910, 1290,STR0023 ,oFont) //"CARIMBO"
 oPrint:Say(2910, 1790,STR0024 ,oFont) //"RUBRICA"
 oPrint:Say(3020, 1260,STR0025 ,oFont) //"DATA"
 oPrint:Say(3020, 1390,"/"     ,oFont)
 oPrint:Say(3020, 1420,"/"     ,oFont)
Return(nil)
 
Static Function Fs_ImpTot(nLinPos, nTot)    
 oPrint:Say(nLinPos, 1515,STR0026 ,oFontTit) //"TOTAL"
 HS_ImpBox({nLinPos, 1815, nLinPos+60, 2115},,{StrZero(nTot,7),Hs_Color(0), oFontTit},{7,15},,.T.,oPrint) 
 nTot := 0
Return(nil)                        

Static Function Fs_CabGf(nSeqProc, lQuebra)
 Local lRet  := .F.
 Default lQuebra := .F.                             
 
 If lQuebra .Or. nSeqProc > 20
  nSeqProc := 1
  nSeqPag  += 1
	 lRet     := .T. //Nova Pagina
	 
	 
	 If !lQuebra
   nLinPos  += 90 
   Fs_ImpRod()
		EndIf
		 
	 oPrint:Endpage()   
	 
	 oPrint:StartPage()     			               	//** Inicia uma Nova Pagina
	 
	 oPrint:Box(0050,0050,nLinMax,nColMax-130,Hs_FchFt(10))   	// Box que circunda a pagina        

	 oPrint:Say(0120,0520,STR0027 ,oFontTit2) //"Sistema"
	 oPrint:Say(0160,0520,STR0028 ,oFontTit2) //"⁄nico"
	 oPrint:Say(0200,0520,STR0029 ,oFontTit2) //"de Sa˙de"
	 
	 oPrint:Say(0120,0740,STR0030 ,oFontTit2) //"MinistÈrio"
	 oPrint:Say(0160,0740,STR0031 ,oFontTit2) //"da"
	 oPrint:Say(0200,0740,STR0032 ,oFontTit2) //"Sa˙de"
	 
	 oPrint:Say(0140,1000,STR0033 ,oFontCab) //"SISTEMA DE INFORMA«√O AMBULATORIAL-SIA/SUS"
	 oPrint:Say(0180,1000,STR0034 ,oFontCab)	 //"Boletim de ProduÁ„o Ambulatorial/BPA(Consolidado)"

	 IF File("sus_hsp.bmp")
	  oPrint:SayBitmap(0060,0060,"sus_hsp.bmp", 450, 200 )
Else
	  oPrint:Say(0060,0060,"sus_hsp.bmp",Hs_FchFt(10))
Endif 
	 
  //HS_ImpBox(aCoords                            , aTitulo, aTexto                                    , aSepara, nCorBack, lCxAberta, oPrint)
  HS_ImpBox({0320, 0080, 0690, nColMax-160}, {STR0035, 20,Hs_Color(0), oFontTit},,,,,oPrint) //"Dados Operacionais"
                                         
	 HS_ImpBox({0410, 0120, 0500, 0680},{STR0036, 20, Hs_Color(0), oFontTit1}, {cCnes,Hs_Color(0),oFont},,,,oPrint) //"CNES do Estabelecimento"
		
	 HS_ImpBox({0410, 0730, 0500, 2165}, {STR0037, 20, Hs_Color(0), oFontTit1}, {cNome,Hs_Color(0),oFont},,,,oPrint)//"Nome Estabelecimento"
	 		
	 HS_ImpBox({0560, 0120, 0630, 0260}, {STR0038, 30,Hs_Color(0),oFontTit1},{SM0->M0_ESTCOB,Hs_Color(0), oFont},{2, 20},,,oPrint) //"UF"

	 HS_ImpBox({0560, 0910, 0630, 1060}, {STR0039,20,Hs_Color(0),oFontTit1},{Hs_RMesAno(cMesRefR)[2],Hs_Color(0),oFont}, {2, 20},,,oPrint)//"MÍs"
	 
	 HS_ImpBox({0560, 1060, 0630, 1340}, {STR0040, 90,Hs_Color(0),oFontTit1},{Hs_RMesAno(cMesRefR)[3],Hs_Color(0),oFont}, {4, 20},,,oPrint)//"Ano"
	 
	 HS_ImpBox({0560, 1940, 0630, 2165}, {STR0041, 20,Hs_Color(0),oFontTit1},{StrZero(nSeqPag,3),Hs_Color(0),oFont},{3, 20},,,oPrint)//"Folha"
	 
	 HS_ImpBox({0760, 0080, nLinMax-400, nColMax-160}, {STR0042, 60, Hs_Color(0),oFontTit},,,,,oPrint)//"Atendimentos Realiazados"
	 
	 oPrint:Say(0800,0140,STR0043 ,oFontTit2)//"Seq¸encia"
	 oPrint:Say(0800,0525,STR0044 ,oFontTit2)//"Procedimento"
	 oPrint:Say(0800,1165,STR0045 ,oFontTit2)//"CBO"
	 oPrint:Say(0800,1545,STR0046 ,oFontTit2)//"Idade"
	 oPrint:Say(0800,1865,STR0047 ,oFontTit2)//"Quantidade"
 EndIf
 
Return(lRet)

Static Function Fs_BPAInd()

 Local nSeqProc := 0
 Local cCODCRM  := "", cCODCBO := ""
 Local cSql       := ""
 Local lImp1 	:= .F.
 
 Private nLinPos  := 0

 Private nLinMax	:=  2400
	Private nColMax	:=  3400
 Private nSeqPag := 0
 
                           //New([acName]     , [nPar2], [anHeight], [lPar4], [alBold], [nPar6], [lPar7], [nPar8], [alItalic], [alUnderline]) 
 Private oFont   	 := TFont():New("Courier New",     10 , 10         ,        , .F.    ,        ,        ,        , .T.       , .F.) // Normal
 Private oFont1  	 := TFont():New("Courier New",     10 , 12         ,        , .F.    ,        ,        ,        , .T.       , .F.) // Normal 
 Private oFontTit	 := TFont():New("Courier New",     12 , 12         ,        , .T.    ,        ,        ,        , .F.       , .F.)  
 Private oFontTit1 := TFont():New("Courier New",     10 , 10         ,        , .F.    ,        ,        ,        , .T.       , .F.) // Normal
 Private oFontTit2 := TFont():New("Courier New",        , 08         ,        , .T.    ,        ,        ,        , .T.       , .F.) // Normal
 Private oFontCab  := TFont():New("Courier New",        , 11         ,        , .T.    ,        ,        ,        , .F.       , .F.) // Normal
 
 oPrint		:= TMSPrinter():New(STR0048) //"BPA INDIVIDUALIZADO"
	
	oPrint:SetLandScape()	// Modo retrato
	oPrint:Setup()
                         
 cSql += " SELECT GE7.GE7_CODPRT, GFR.GFR_CBOSUS GHD_CODCBO, "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY.GCY_IDADE,1,3) GCY_IDADE, GE7_QTDDES GE7_QTDDES, "
 cSql += "        GE7.GE7_CODCRM GE7_CODCRM, GBJ.GBJ_CODCNS GBJ_CODCNS,GD4_MATRIC GD4_MATRIC,GCY_NOME GCY_NOME,GBH_DTNASC GBH_DTNASC,GCY_SEXO GCY_SEXO, "
 cSql += "        GCY_DATATE GCY_DATATE,GCY_CIDALT GCY_CIDALT,GCY_CARATE GCY_CARATE,GBH_CORPEL GBH_CORPEL, GA7_COMPET GA7_COMPET, GCZ_NRGUIA GCZ_NRGUIA, GD1_CATAIH GD1_CATAIH, "
 cSql += "        GAM_CODIGO GAM_CODIGO "
 cSql += "   FROM " + RetSqlName("GE7") + " GE7 "
 cSql += "   JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GE7.GE7_CODDES  "
 cSql += "   JOIN " + RetSqlName("GK6") + " GK6 ON GK6.GK6_FILIAL = '" + xFilial("GK6") + "' AND GK6.D_E_L_E_T_ <> '*' AND GK6.GK6_CODPRO = GA7.GA7_CODPRO  "
 cSql += "      AND GK6.GK6_CODINR = '02' " // '02' = BPA individualizado Valor chumbado pois esse dado vem da tabela unificada 
 cSql += "   JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = GE7.GE7_REGATE  "
 cSql += "   JOIN " + RetSqlName("GD1") + " GD1 ON GD1.GD1_FILIAL = '" + xFilial("GD1") + "' AND GD1.D_E_L_E_T_ <> '*' AND GD1.GD1_CARATE = GCY.GCY_CARATE  "
 cSql += "   JOIN " + RetSqlName("GBJ") + " GBJ ON GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*' AND GBJ.GBJ_CRM    = GE7.GE7_CODCRM  " 
 cSql += "   JOIN "+RetSqlName("GCZ")+" GCZ ON GCZ.GCZ_FILIAL = '"+xFilial("GCZ")+"' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = GE7.GE7_NRSEQG "
 cSql += "   JOIN "+RetSqlName("GAT")+" GAT ON GAT.GAT_FILIAL = '"+xFilial("GAT")+"' AND GAT.D_E_L_E_T_ <> '*' AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE "
 cSql += "   JOIN "+RetSqlName("GBH")+" GBH ON GBH.GBH_FILIAL = '"+xFilial("GBH")+"' AND GBH.D_E_L_E_T_ <> '*' AND GBH.GBH_CODPAC = GCY.GCY_REGGER "        
 cSql += "   JOIN "+RetSqlName("GAM")+" GAM ON GAM.GAM_FILIAL = '"+xFilial("GAM")+"' AND GAM.D_E_L_E_T_ <> '*' AND GAM.GAM_CEP    = GBH.GBH_CEP    " 
 cSql += "   JOIN "+RetSqlName("GD4")+" GD4 ON GD4.GD4_FILIAL = '"+xFilial("GD4")+"'  AND GD4.D_E_L_E_T_ <> '*' AND GD4.GD4_CODPLA = GCZ.GCZ_CODPLA AND GD4_REGGER = GCY_REGGER "
 cSql += "   JOIN "+RetSqlName("GFR")+" GFR ON GFR.GFR_FILIAL = '"+xFilial("GFR")+"' AND GFR.D_E_L_E_T_ <> '*' AND GFR.GFR_CDESPE  = GA7.GA7_CODESP 
 cSql += "   WHERE GE7.GE7_FILIAL = '"+xFilial("GE7")+"' AND GE7.D_E_L_E_T_ <> '*' AND GCZ.GCZ_CODPLA = '" + cCodPlaR + "'"
 cSql += "     AND GAT.GAT_MESREF = '" + cMesRefR + "'"
 cSql += "   ORDER BY GE7_CODCRM, GHD_CODCBO, GE7_CODPRT, GCY_DATATE " 
     
cSql := ChangeQuery(cSql)

TCQUERY cSql NEW ALIAS "QRY"

If Eof()
	HS_MsgInf(STR0011,STR0009, STR0012) //"Nenhum registro encontrado para seleÁ„o informada."###"AtenÁ„o"###"SeleÁ„o de Registros"
	DbCloseArea()
	Return(Nil)
EndIf

 cCodCrm := QRY->GE7_CODCRM
 cCodCbo := QRY->GHD_CODCBO 
 lImp1 := .T.

 Fs_CbcBPAI(@nSeqProc,,.T.)  
 nLinPos  := 450  
dbGoTop()
While !EOF()

	If  !lImp1           
  
  If Fs_CbcBPAI(@nSeqProc,cCodCrm # QRY->GE7_CODCRM .Or. cCodCbo # QRY->GHD_CODCBO)
   nLinPos  := 450   
  Else    
   nLinPos  += 30
  EndIf 
   	Else
   		lImp1 := .F.	  
	EndIf	

  	Fs_BpaI(nSeqProc)
  
  	nLinPos += 95
  
  	nSeqProc++
  cCodCrm := QRY->GE7_CODCRM
  cCodCbo := QRY->GHD_CODCBO 
								
   DbSkip()
EndDo

 For nSeqProc := nSeqProc to 8
  Fs_BpaI(nSeqProc, .F.)
  nLinPos += 125
 Next

 Fs_RodBPAI()
	                     
 DbSelectArea("QRY")
DbCloseArea()
 oPrint:Preview()   

Return(nil)

Static Function Fs_CbcBPAI(nSeqProc, lQuebra, lQbrIni)

 Local lRet := .F.
   
 Default lQuebra := .F.
 Default lQbrIni := .F.

 If nSeqProc > 8 .Or. lQuebra .Or. lQbrIni 
	 If !lQbrIni
   nLinPos  += 30
   For nSeqProc := nSeqProc to 8
    Fs_BpaI(nSeqProc, .F.)
    nLinPos += 125
   Next          
   
   nLinPos += 125
   Fs_RodBPAI()
		EndIf
		 
  nSeqPag  += 1//PADL(Soma1(cSeqPag), 3, "0")
  nSeqProc := 1                        
	 lRet     := .T. //Nova Pagina
	 		 
	 oPrint:Endpage()   
	 
	 oPrint:StartPage()     			               	//** Inicia uma Nova Pagina
	 
	 
	 HS_ImpBox({0050, 0050, 0260, 3210},,,,,,oPrint)

	 IF File("sus_hsp.bmp")
	  oPrint:SayBitmap(0060,0060,"sus_hsp.bmp", 460, 200 )
	 Else
	  oPrint:Say(0060,0060,"sus_hsp.bmp",Hs_FchFt(10))
Endif

	 oPrint:Say(0125,0570,STR0049 ,oFontCab) //"MINIST…RIO DA SA⁄DE"
	 oPrint:Say(0165,0520,STR0050 ,oFontCab)//"SISTEMA ⁄NICO DE SA⁄DE"

	 oPrint:Say(0125,1250,STR0033 ,oFontCab)//"SISTEMA DE INFORMA«√O AMBULATORIAL-SIA/SUS"
	 oPrint:Say(0165,1110,STR0051,oFontCab)	 
	 
	 HS_ImpBox({0135, 2520, 0205, 2670}, {STR0039,20,Hs_Color(0),oFontTit1},{Hs_RMesAno(cMesRefR)[2],Hs_Color(0),oFont}, {2, 20},,,oPrint)   
	 
	 HS_ImpBox({0135, 2670, 0205, 2950}, {STR0040, 90,Hs_Color(0),oFontTit1},{Hs_RMesAno(cMesRefR)[3],Hs_Color(0),oFont}, {4, 20},,,oPrint)
	 
	 HS_ImpBox({0135, 2980, 0205, 3190}, {STR0041, 20,Hs_Color(0),oFontTit1},{StrZero(nSeqPag,3),Hs_Color(0),oFont},{3, 20},,,oPrint)
	 	 
  //HS_ImpBox(aCoords                            , aTitulo, aTexto                                    , aSepara, nCorBack, lCxAberta, oPrint)
  HS_ImpBox({0290, 0050, 0400, 3210}, {STR0052, 90,Hs_Color(0), oFontTit},,,,,oPrint)//"Dados Operacionais"
	 
	 HS_ImpBox({0320, 0070, 0390, 0160}, {STR0038, 30,Hs_Color(0),oFontTit1},{SM0->M0_ESTCOB,Hs_Color(0), oFont},{2, 20},,,oPrint) 

	 HS_ImpBox({0320, 0190, 0390, 0700}, {STR0036, 20, Hs_Color(0), oFontTit1}, {cCnes,Hs_Color(0),oFont},,,,oPrint) 
		
	 HS_ImpBox({0320, 0720, 0390, 1730}, {STR0037, 20, Hs_Color(0), oFontTit1}, {cNome,Hs_Color(0),oFont},,,,oPrint)  

	 HS_ImpBox({0320, 1750, 0390, 2820}, {STR0053 , 20, Hs_Color(0), oFontTit1}, {QRY->GBJ_CODCNS,Hs_Color(0),oFont},{15, 20},,,oPrint) //"CNS DO PROFISSIONAL"

	 HS_ImpBox({0320, 2840, 0390, 3190}, {STR0045 , 90, Hs_Color(0), oFontTit1}, {QRY->GHD_CODCBO	,Hs_Color(0),oFont},{7, 20},,,oPrint)  //C.B.O.
	                                                                                                            
	 oPrint:Say(0410,1450,STR0042,oFontTit) //"ATENDIMENTOS REALIZADOS"
	 HS_ImpBox({0450,0050, nLinMax-200, 3210},,,,,,oPrint)
	 
 EndIf
 
Return(lRet)                       

Static Function Fs_RodBPAI()
  
 HS_ImpBox({nLinMax-170, 0050, nLinMax-30, 1585},{STR0022, 20, Hs_Color(0), oFontTit1},,,,,oPrint) //"RESPONS¡VEL(Estabelecimento de Sa˙de)"
 oPrint:Say(nLinMax-150, 0190,STR0023,oFont)//"CARIMBO"
 oPrint:Say(nLinMax-150, 1250,STR0024,oFont)//"RUBRICA"
 oPrint:Say(nLinMax-100, 0070,STR0025,oFont)//"DATA"
 oPrint:Say(nLinMax-100, 0200,"/"    ,oFont)
 oPrint:Say(nLinMax-100, 0250,"/"    ,oFont)
  
 HS_ImpBox({nLinMax-170, 1605, nLinMax-30, 3210},{STR0054, 20, Hs_Color(0), oFontTit1},,,,,oPrint)//"GESTOR MUNICIPAL/ESTADUAL"
 oPrint:Say(nLinMax-150, 1745,STR0023,oFont) //"CARIMBO"
 oPrint:Say(nLinMax-150, 2805,STR0024,oFont) //"RUBRICA"
 oPrint:Say(nLinMax-100, 1625,STR0025,oFont) //"DATA"
 oPrint:Say(nLinMax-100, 1755,"/"    ,oFont)
 oPrint:Say(nLinMax-100, 1805,"/"    ,oFont)
Return(nil)                                    


Static Function Fs_BpaI(nSeqProc, lImpDados)              
  local cDatAte  :=  StrTran(DtoC(StoD(QRY->GCY_DATATE)), "/", "")
  local cDatNasc :=  StrTran(DtoC(StoD(QRY->GBH_DTNASC)), "/", "")
  
  Default lImpDados := .T.
   
  HS_ImpBox({nLinPos,0050, nLinPos+190, 3210},,,,,,oPrint)

  HS_ImpBox({nLinPos+25,0050, nLinPos+190, 0110},{STR0055, 05, Hs_Color(0),oFontTit2},{StrZero(nSeqProc,2),Hs_Color(0), oFont1},,,.T.,oPrint)//"SEQ"
 
  HS_ImpBox({nLinPos+15,0110, nLinPos+95, 0910},{STR0056, 05, Hs_Color(0),oFontTit2},IIF(lImpDados,{QRY->GD4_MATRIC,Hs_Color(0), oFont},{}),{15,25},,.T.,oPrint) //"NRO CART√O NACIONAL SA⁄DE(CNS) DO USU¡RIO"
  oPrint:Line(nLinPos, 0110, nLinPos+95, 0110) 
  	 
  HS_ImpBox({nLinPos+15,0910, nLinPos+95, 2330},{STR0057, 05, Hs_Color(0),oFontTit2},IIF(lImpDados,{SUBSTR(QRY->GCY_NOME,1,27),Hs_Color(0), oFont},{}),{27,25},,.T.,oPrint) //"NOME DO PACIENTE"
  oPrint:Line(nLinPos, 0910, nLinPos+95, 0910)                                                       

  HS_ImpBox({nLinPos+15,2330, nLinPos+95, 2880},{STR0058, 05, Hs_Color(0),oFontTit2},IIF(lImpDados,{cDatNasc,Hs_Color(0), oFont},{}),{8,25},,.T.,oPrint)  //"DATA NASCIMENTO"
  oPrint:Line(nLinPos, 2330, nLinPos+95, 2330) 
                                                                                                                                 
  HS_ImpBox({nLinPos+15,2880, nLinPos+95, 3210},{STR0059, 05, Hs_Color(0),oFontTit2},IIF(lImpDados,{QRY->GAM_CODIGO,Hs_Color(0), oFont},{}),{8,25},,.T.,oPrint)//"C”D.IBGE MUNIC.RES."
                                          
  nLinPos += 95

  HS_ImpBox({nLinPos+15,0110, nLinPos+95, 0270},{STR0060, 05, Hs_Color(0),oFontTit2},,,,.T.,oPrint)  //"SEXO"
  oPrint:Line(nLinPos, 0270, nLinPos+95, 0270)  
   
  HS_ImpBox({nLinPos+48,0115, nLinPos+80, 0145},,,,,,oPrint)    
  oPrint:Say(nLinPos+48,0150,STR0061,oFont) //"M"
  
  HS_ImpBox({nLinPos+48,0185, nLinPos+80, 0215},,,,,,oPrint)
  oPrint:Say(nLinPos+48,0220,STR0062,oFont) //"F"
  
  If !Empty(QRY->GCY_SEXO) .And. lImpDados
   oPrint:Say(nLinPos+48,IIF(QRY->GCY_SEXO == "0", 0121, 0191),"X",oFont) 
  EndIf  

  HS_ImpBox({nLinPos+15,0300, nLinPos+95, 0740},{STR0063, 05, Hs_Color(0),oFontTit2},IIF(lImpDados,{cDatAte,Hs_Color(0), oFont},{}),{8,25},,.T.,oPrint)//"DATA ATENDIMENTO"
  oPrint:Line(nLinPos, 0300, nLinPos+95, 0300)   

  HS_ImpBox({nLinPos+15,0800, nLinPos+95, 1350},{STR0064, 05, Hs_Color(0),oFontTit2},IIF(lImpDados,{QRY->GE7_CODPRT,Hs_Color(0), oFont},{}),{10,25},,.T.,oPrint)//"C”DIGO PROCEDIMENTO"
  oPrint:Line(nLinPos, 0800, nLinPos+95, 0800)   
  
  HS_ImpBox({nLinPos+15,1430, nLinPos+95, 1650},{STR0065, 05, Hs_Color(0),oFontTit2},IIF(lImpDados,{StrZero(QRY->GE7_QTDDES,4),Hs_Color(0), oFont},{}),{4,25},,.T.,oPrint)//"QTD"
  oPrint:Line(nLinPos, 1430, nLinPos+95, 1430)     
    
  HS_ImpBox({nLinPos+15,1730, nLinPos+95, 1940},{STR0066, 05, Hs_Color(0),oFontTit2},IIF(lImpDados,{QRY->GCY_CIDALT,Hs_Color(0), oFont},{}),{4,25},,.T.,oPrint)//"CID-10"
  oPrint:Line(nLinPos, 1730, nLinPos+95, 1730)     
  
  HS_ImpBox({nLinPos+15,2039, nLinPos+95, 2220},{STR0067, 05, Hs_Color(0),oFontTit2},IIF(lImpDados,{QRY->GD1_CATAIH,Hs_Color(0), oFont},{}),{2,25},,.T.,oPrint)//"CAR.ATEND"
  oPrint:Line(nLinPos, 2039, nLinPos+95, 2039)  
  
  HS_ImpBox({nLinPos+15,2290, nLinPos+95, 2450},{STR0068, 05, Hs_Color(0),oFontTit2},IIF(lImpDados,{QRY->GBH_CORPEL,Hs_Color(0), oFont},{}),{2,25},,.T.,oPrint)//"RA«A COR"
  oPrint:Line(nLinPos, 2290, nLinPos+95, 2290)  

  HS_ImpBox({nLinPos+15,2510, nLinPos+95, 3210},{STR0069, 05, Hs_Color(0),oFontTit2},IIF(lImpDados,{QRY->GCZ_NRGUIA,Hs_Color(0), oFont},{}),{13,25},,.T.,oPrint)//"NUMERO DA AUTORIZA«√O"
  oPrint:Line(nLinPos, 2510, nLinPos+95, 2510)  
Return()  
