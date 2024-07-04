#include "protheus.ch"
#include "report.ch"
#include  "TECR982.CH"

Static cAutoPerg := "TECR982"

//-------------------------------------------------------------------
/*/{Protheus.doc} TECR982
Relatorio de Orçamentos

@author Kaique Schiller
@since 02/04/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Function TECR982()
Local oReport 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PARAMETROS                                                             ³
//³ MV_PAR01 : Orçamento De? ?                                             ³
//³ MV_PAR02 : Orçamento ate ?                                             ³
//³ MV_PAR03 : Cliente De ?                                                ³
//³ MV_PAR04 : Loja De ?                                                   ³
//³ MV_PAR05 : Cliente ate ?                                               ³
//³ MV_PAR06 : Loja Até ?                                                  ³
//³ MV_PAR07 : Filial ?                                                    ³
//³ MV_PAR08 : Exibe Item Extra?                                           ³
//³ MV_PAR09 : Data De?                                                    ³
//³ MV_PAR10 : Data Até?                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

If !Pergunte("TECR982",.T.)
	Return
EndIf

oReport := ReportDef()
oReport:PrintDialog()	

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Monta as definições do relatorio de Orçamento

@author  Kaique Schiller
@version P12.1.30
@since 	 02/04/2020
@return  Nil
/*/
//-------------------------------------------------------------------------------------
Static Function ReportDef()
Local oReport
Local oTFJ
Local oTFL
Local oTFF
Local oTFG
Local oTFH 
Local oABP
Local oTFU
Local lOrcPrc   := SuperGetMv("MV_ORCPRC",,.F.)
Local cAlias2 := GetNextAlias()

Pergunte("TECR982",.F.)
 
DEFINE REPORT oReport NAME "TECR982" TITLE STR0001 PARAMETER "TECR982" ACTION {|oReport| PrintReport(oReport,cAlias2),STR0034} //"Relatório de orçamentos"#"Orçamentos"
 
    DEFINE SECTION oTFJ OF oReport TITLE STR0034 TABLES "TFJ","SA1" //"Orçamentos"

        DEFINE CELL NAME "TFJ_FILIAL"   OF oTFJ ALIAS "TFJ" TITLE STR0029 //"Filial"   
        DEFINE CELL NAME "TFJ_CODIGO"   OF oTFJ ALIAS "TFJ" TITLE STR0002 //"Cód. Orçamento"
        DEFINE CELL NAME "TFJ_CODENT"   OF oTFJ ALIAS "TFJ" TITLE STR0003 //"Cod. Cliente"
        DEFINE CELL NAME "TFJ_LOJA"     OF oTFJ ALIAS "TFJ" TITLE STR0005 //"Loja"
        DEFINE CELL NAME "A1_NOME"      OF oTFJ ALIAS "SA1" TITLE STR0004 //"Cliente"

        DEFINE SECTION oTFL OF oTFJ TITLE STR0035 TABLE "TFL","ABS" //"Locais"   

            DEFINE CELL NAME "TFL_LOCAL"    OF oTFL ALIAS "TFL" TITLE STR0007 //"Cód. Local"
            DEFINE CELL NAME "ABS_DESCRI"   OF oTFL ALIAS "ABS" TITLE STR0008 //"Local"
            DEFINE CELL NAME "TFL_DTINI"    OF oTFL ALIAS "TFL" TITLE STR0009 //"Data Inicial"
            DEFINE CELL NAME "TFL_DTFIM"    OF oTFL ALIAS "TFL" TITLE STR0010 //"Data Final"
            DEFINE CELL NAME "TFL_TOTRH"    OF oTFL ALIAS "TFL" TITLE STR0011 //"Total RH"
            DEFINE CELL NAME "TFL_TOTMI"    OF oTFL ALIAS "TFL" TITLE STR0012 //"Total MI"
            DEFINE CELL NAME "TFL_TOTMC"    OF oTFL ALIAS "TFL" TITLE STR0013 //"Total MC"
            DEFINE CELL NAME "TFLATV"       OF oTFL ALIAS "TFL" TITLE STR0046 Block {|| TECRTATV(oTFL:Cell("TFL_LOCAL"):GetValue(.T.),oTFL:Cell("TFL_DTINI"):GetValue(.T.),oTFL:Cell("TFL_DTFIM"):GetValue(.T.),oTFJ:Cell("TFJ_CODIGO"):GetValue(.T.),(cAlias2)->TFL_CODIGO)}//"Total Ativo"

            
             oTFL:SetLeftMargin(05)
 
            DEFINE SECTION oTFF OF oTFL TITLE STR0036 TABLE "TFF","SRJ","SR6" //"Recursos Humanos"

                DEFINE CELL NAME "TFF_ITEM"     OF oTFF ALIAS "TFF" TITLE STR0042 //"Item RH"
                DEFINE CELL NAME "TFF_PRODUT"   OF oTFF ALIAS "TFF" TITLE STR0015 //"Cód. Porduto"
                DEFINE CELL NAME "TFF_QTDVEN"   OF oTFF ALIAS "TFF" TITLE STR0017 //"Quantidade"
                DEFINE CELL NAME "TFF_PRCVEN"   OF oTFF ALIAS "TFF" TITLE STR0018 //"Preço"
                DEFINE CELL NAME "TFF_PERINI"   OF oTFF ALIAS "TFF" TITLE STR0009 //"Data Inicial"
                DEFINE CELL NAME "TFF_PERFIM"   OF oTFF ALIAS "TFF" TITLE STR0010 //"Data Final"
                DEFINE CELL NAME "RJ_DESC"      OF oTFF ALIAS "SRJ" TITLE STR0020 //"Função"
                DEFINE CELL NAME "TDW_DESC"     OF oTFF ALIAS "TDW" TITLE STR0037 //"Escala"
                DEFINE CELL NAME "R6_DESC"      OF oTFF ALIAS "SR6" TITLE STR0022 //"Turno"

                oTFF:SetLeftMargin(10)

                If !lOrcPrc
                    DEFINE SECTION oTFG OF oTFF TITLE STR0038 TABLE "TFG" //"Material de Implantação"
                    DEFINE SECTION oTFH OF oTFF TITLE STR0039 TABLE "TFH" //"Material de Consumo"                   

                    oTFG:SetLeftMargin(15)
                    oTFH:SetLeftMargin(15)

                Else
                    DEFINE SECTION oTFG OF oTFL TITLE STR0038 TABLE "TFG" //"Material de Implantação"
                    DEFINE SECTION oTFH OF oTFL TITLE STR0039 TABLE "TFH" //"Material de Consumo"

                    oTFG:SetLeftMargin(10)
                    oTFH:SetLeftMargin(10)

                Endif

                    DEFINE CELL NAME "TFG_ITEM"     OF oTFG ALIAS "TFG" TITLE STR0043 //"Item MI"
                    DEFINE CELL NAME "TFG_PRODUT"   OF oTFG ALIAS "TFG" TITLE STR0015 //"Cód. Porduto"
                    DEFINE CELL NAME "TFG_QTDVEN"   OF oTFG ALIAS "TFG" TITLE STR0017 //"Quantidade"
                    DEFINE CELL NAME "TFG_PRCVEN"   OF oTFG ALIAS "TFG" TITLE STR0018 //"Preço"
                    DEFINE CELL NAME "TFG_PERINI"   OF oTFG ALIAS "TFG" TITLE STR0009 //"Data Inicial"
                    DEFINE CELL NAME "TFG_PERFIM"   OF oTFG ALIAS "TFG" TITLE STR0010 //"Data Final"

                    DEFINE CELL NAME "TFH_ITEM"     OF oTFH ALIAS "TFH" TITLE STR0044 //"Item MC"
                    DEFINE CELL NAME "TFH_PRODUT"   OF oTFH ALIAS "TFH" TITLE STR0015 //"Cód. Porduto"
                    DEFINE CELL NAME "TFH_QTDVEN"   OF oTFH ALIAS "TFH" TITLE STR0017 //"Quantidade"
                    DEFINE CELL NAME "TFH_PRCVEN"   OF oTFH ALIAS "TFH" TITLE STR0018 //"Preço"
                    DEFINE CELL NAME "TFH_PERINI"   OF oTFH ALIAS "TFH" TITLE STR0009 //"Data Inicial"
                    DEFINE CELL NAME "TFH_PERFIM"   OF oTFH ALIAS "TFH" TITLE STR0010 //"Data Final"
                    
                DEFINE SECTION oABP OF oTFF TITLE STR0040 TABLE "ABP","SRV" //"Verbas Adicionais"

                    DEFINE CELL NAME "ABP_ITEM"     OF oABP ALIAS "ABP" TITLE STR0045 //"Item Verba"
                    DEFINE CELL NAME "ABP_BENEFI"   OF oABP ALIAS "ABP" TITLE STR0025 //"Benefício"
                    DEFINE CELL NAME "ABP_VALOR"    OF oABP ALIAS "ABP" TITLE STR0026 //"Valor"
                    DEFINE CELL NAME "ABP_VERBA"    OF oABP ALIAS "ABP" TITLE STR0027 //"Cód. Verba"
                    DEFINE CELL NAME "RV_DESC"      OF oABP ALIAS "ABP" TITLE STR0028 //"Verba"
                  
                    oABP:SetLeftMargin(15)

                DEFINE SECTION oTFU OF oTFF TITLE STR0041 TABLE "TFU","ABN" //"Hora Extra"

                    DEFINE CELL NAME "TFU_CODABN"   OF oTFU ALIAS "TFU" TITLE STR0030 //"Cód. Hora"
                    DEFINE CELL NAME "ABN_DESC"     OF oTFU ALIAS "ABN" TITLE STR0031 //"Desc. Motivo"
                    DEFINE CELL NAME "TFU_VALOR"    OF oTFU ALIAS "TFU" TITLE STR0032 //"Valor"
                    
                    oTFU:SetLeftMargin(15)

Return oReport
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Monta a query para exebir no relatório.

@author  Kaique Schiller
@version P12.1.30
@since 	 02/04/2020
@return  Nil
/*/
//-------------------------------------------------------------------------------------
Static Function PrintReport(oReport,cAlias2)
Local lOrcPrc   := SuperGetMv("MV_ORCPRC",,.F.)
Local lHasOrcSmp := HasOrcSimp()
Local lOrcSimp  := lHasOrcSmp .And. SuperGetMv("MV_ORCSIMP",,"2") == "1"
Local cXfilTFJ  :=  " = '" + xFilial("TFJ", cFilAnt) +"'"   
Local cFiSA1TFJ := FWJoinFilial("SA1","TFJ","SA1","TFJ",.T.)
Local cFiSA1AD1 := FWJoinFilial("SA1","AD1","SA1","AD1",.T.)
Local cFiABSTFL := FWJoinFilial("ABS","TFL","ABS","TFL",.T.)
Local cFiSRJTFF := FWJoinFilial("SRJ","TFF","SRJ","TFF",.T.)
Local cFiSR6TFF := FWJoinFilial("SR6","TFF","SR6","TFF",.T.)
Local cFiTDWTFF := FWJoinFilial("TDW","TFF","TDW","TFF",.T.)
Local cFiSRVABP := FWJoinFilial("SRV","ABP","SRV","ABP",.T.)
Local cFiABNTFU := FWJoinFilial("ABN","TFU","ABN","TFU",.T.)
Local cAlias1 := GetNextAlias()
Local cAlias3 := GetNextAlias()
Local cAlias4 := GetNextAlias()
Local cAlias5 := GetNextAlias()
Local cAlias6 := GetNextAlias()
Local cAlias7 := GetNextAlias() 
Local cQuery := ""
Local cQueryTFJ := ""
Local cQueryTFL := ""
Local cOrcSimp := ""
Local cMVTFF := ""
Local cMVTFG := ""
Local cMVTFH := ""
Local aFilsPAR07 := {}
Local cValMVPAR07 := ""
Local nX

MakeSqlExp("TECR982")

If !Empty(MV_PAR07)
    cXfilTFJ    := ""    
	cValMVPAR07 := STRTRAN(MV_PAR07, "TFJ_FILIAL")
	cValMVPAR07 := REPLACE(cValMVPAR07, " IN")
	cValMVPAR07 := REPLACE(cValMVPAR07, "(")
	cValMVPAR07 := REPLACE(cValMVPAR07, ")")
	cValMVPAR07 := REPLACE(cValMVPAR07, "'")
	aFilsPAR07 := StrTokArr(cValMVPAR07,",")
	For nX := 1 To LEN(aFilsPAR07)
		If nX == 1
			cXfilTFJ += " IN ("
		EndIf
		cXfilTFJ += "'" + xFilial("TFJ", aFilsPAR07[nX] )
		If nX >= 1 .AND. nX < LEN(aFilsPAR07)
			cXfilTFJ +=  "',"
		EndIf
		If nX == LEN(aFilsPAR07)
			cXfilTFJ += " ') "
		EndIf
	Next nX   
EndIf

If !lOrcSimp
    cQuery += " LEFT JOIN " + RetSqlName("ADY") + " ADY"
    cQuery += " ON ADY.ADY_FILIAL = TFJ.TFJ_FILIAL AND "
    cQuery += " ADY.D_E_L_E_T_ = ' ' AND "

    cQuery += " TFJ.TFJ_PROPOS = ADY.ADY_PROPOS AND "
    cQuery += " TFJ.TFJ_PREVIS = ADY.ADY_PREVIS AND "
    cQuery += " TFJ.D_E_L_E_T_ = ' ' "

    cQuery += " LEFT JOIN " + RetSqlName("AD1") + " AD1 "
    cQuery += " ON AD1.AD1_FILIAL = ADY.ADY_FILIAL AND "
    cQuery += " AD1.AD1_NROPOR = ADY.ADY_OPORTU  AND "
    cQuery += " AD1.AD1_REVISA = ADY.ADY_REVISA  AND "
    cQuery += " AD1.D_E_L_E_T_ = ' ' "

    cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += " ON " + cFiSA1AD1 + " AND "
	cQuery += " SA1.A1_COD = AD1.AD1_CODCLI AND "
	cQuery += " SA1.A1_LOJA = AD1.AD1_LOJCLI AND "
	cQuery += " SA1.D_E_L_E_T_ = ' ' "

    cOrcSimp += " ((AD1.AD1_DTINI <= '"+DTOS(mv_par09)+"' OR AD1.AD1_DTINI BETWEEN '"+DTOS(mv_par09)+"'AND '"+DTOS(mv_par10)+"')"
    cOrcSimp += " AND ( AD1.AD1_DTFIM >= '"+DTOS(mv_par10)+"' OR AD1.AD1_DTFIM BETWEEN '"+DTOS(mv_par09)+"'AND '"+DTOS(mv_par10)+"') OR AD1.AD1_DTINI = '"+ '' + "' OR AD1.AD1_DTFIM = '"+ '' + "')"

else
    cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += " ON " + cFiSA1TFJ + " AND "
	cQuery += " SA1.D_E_L_E_T_ = ' '  AND "
	cQuery += " SA1.A1_COD = TFJ.TFJ_CODENT AND "
	cQuery += " SA1.A1_LOJA = TFJ.TFJ_LOJA "

    cOrcSimp := " TFJ.TFJ_DATA >= '" +DTOS(mv_par09) + "' AND TFJ.TFJ_DATA <= '" +DTOS(mv_par10)+"'"
EndIf 

cQueryTFJ := " AND EXISTS ( SELECT 1  FROM " + RetSqlName('TFL') + " TFLSUB"
cQueryTFJ += " LEFT JOIN " + RetSqlName('TFF') + " TFFSUB"
cQueryTFJ += " ON TFFSUB.TFF_FILIAL = TFLSUB.TFL_FILIAL"
cQueryTFJ += " AND TFFSUB.TFF_CODPAI = TFLSUB.TFL_CODIGO"
cQueryTFJ += " AND TFFSUB.D_E_L_E_T_= ' ' "

If lOrcprc            
    cQueryTFJ += " LEFT JOIN " + RetSqlName('TFG') + " TFGSUB"
    cQueryTFJ += " ON TFGSUB.TFG_FILIAL = TFLSUB.TFL_FILIAL"
    cQueryTFJ += " AND TFGSUB.TFG_CODPAI = TFLSUB.TFL_CODIGO"
    cQueryTFJ += " AND TFGSUB.D_E_L_E_T_= ' ' " 			
        
    cQueryTFJ += " LEFT JOIN " + RetSqlName('TFH') + " TFHSUB"
    cQueryTFJ += " ON TFHSUB.TFH_FILIAL = TFLSUB.TFL_FILIAL"
    cQueryTFJ += " AND TFHSUB.TFH_CODPAI = TFLSUB.TFL_CODIGO"
    cQueryTFJ += " AND TFHSUB.D_E_L_E_T_= ' ' " 		
Else		            
    cQueryTFJ += " LEFT JOIN " + RetSqlName('TFG') + " TFGSUB"
    cQueryTFJ += " ON TFGSUB.TFG_FILIAL = TFFSUB.TFF_FILIAL"
    cQueryTFJ += " AND TFGSUB.TFG_CODPAI = TFFSUB.TFF_COD"
    cQueryTFJ += " AND TFGSUB.D_E_L_E_T_= ' ' " 			
        
    cQueryTFJ += " LEFT JOIN " + RetSqlName('TFH') + " TFHSUB"
    cQueryTFJ += " ON TFHSUB.TFH_FILIAL = TFFSUB.TFF_FILIAL"
    cQueryTFJ += " AND TFHSUB.TFH_CODPAI = TFFSUB.TFF_COD"
    cQueryTFJ += " AND TFHSUB.D_E_L_E_T_= ' ' " 		

EndIf

cQueryTFL := cQueryTFJ
            
cQueryTFJ += " WHERE TFJ.TFJ_FILIAL = TFLSUB.TFL_FILIAL"
cQueryTFJ += " AND TFJ.TFJ_CODIGO = TFLSUB.TFL_CODPAI"

cQueryTFL += " WHERE TFL.TFL_FILIAL = TFFSUB.TFF_FILIAL"
cQueryTFL += " AND TFL.TFL_CODIGO = TFFSUB.TFF_CODPAI"


If TYPE("MV_PAR08") == "C" .OR. TYPE("MV_PAR08") == "D"
    MV_PAR08 := 1
EndIf

If MV_PAR08 == 1
    cMVTFF := "(TFF.TFF_COBCTR IS NULL OR TFF.TFF_COBCTR IN ('','1','2')) "
    cMVTFG := "(TFG.TFG_COBCTR IS NULL OR TFG.TFG_COBCTR IN ('','1','2')) "
    cMVTFH := "(TFH.TFH_COBCTR IS NULL OR TFH.TFH_COBCTR IN ('','1','2')) "

    cQueryTFJ += " AND ((TFFSUB.TFF_COBCTR IS NULL OR TFFSUB.TFF_COBCTR IN ('','1','2'))"
    cQueryTFJ += " OR (TFGSUB.TFG_COBCTR IS NULL OR TFGSUB.TFG_COBCTR IN ('','1','2'))"
    cQueryTFJ += " OR (TFHSUB.TFH_COBCTR IS NULL OR TFHSUB.TFH_COBCTR IN ('','1','2')))"
    cQueryTFJ += " AND TFLSUB.D_E_L_E_T_= ' ' )"

    cQueryTFL += " AND ((TFFSUB.TFF_COBCTR IS NULL OR TFFSUB.TFF_COBCTR IN ('','1','2'))"
    cQueryTFL += " OR (TFGSUB.TFG_COBCTR IS NULL OR TFGSUB.TFG_COBCTR IN ('','1','2'))"
    cQueryTFL += " OR (TFHSUB.TFH_COBCTR IS NULL OR TFHSUB.TFH_COBCTR IN ('','1','2')))"
    cQueryTFL += " AND TFLSUB.D_E_L_E_T_= ' ' )"

ElseIf MV_PAR08 == 2
    cMVTFF := "(TFF.TFF_COBCTR IS NULL OR TFF.TFF_COBCTR IN ('','1'))"
    cMVTFG := "(TFG.TFG_COBCTR IS NULL OR TFG.TFG_COBCTR IN ('','1'))"
    cMVTFH := "(TFH.TFH_COBCTR IS NULL OR TFH.TFH_COBCTR IN ('','1'))"

    cQueryTFJ += " AND ((TFFSUB.TFF_COBCTR IS NULL OR TFFSUB.TFF_COBCTR IN ('','1'))"
    cQueryTFJ += " OR (TFGSUB.TFG_COBCTR IS NULL OR TFGSUB.TFG_COBCTR IN ('','1'))"
    cQueryTFJ += " OR (TFHSUB.TFH_COBCTR IS NULL OR TFHSUB.TFH_COBCTR IN ('','1')))"
    cQueryTFJ += " AND TFLSUB.D_E_L_E_T_= ' ' )"

    cQueryTFL += " AND ((TFFSUB.TFF_COBCTR IS NULL OR TFFSUB.TFF_COBCTR IN ('','1'))"
    cQueryTFL += " OR (TFGSUB.TFG_COBCTR IS NULL OR TFGSUB.TFG_COBCTR IN ('','1'))"
    cQueryTFL += " OR (TFHSUB.TFH_COBCTR IS NULL OR TFHSUB.TFH_COBCTR IN ('','1')))"
    cQueryTFL += " AND TFLSUB.D_E_L_E_T_= ' ' )"

ElseIf MV_PAR08 == 3
    cMVTFF := "(TFF.TFF_COBCTR = '2')"
    cMVTFG := "(TFG.TFG_COBCTR = '2')"
    cMVTFH := "(TFH.TFH_COBCTR = '2')" 
    
    cQueryTFJ += " AND ((TFFSUB.TFF_COBCTR = '2')"
    cQueryTFJ += " OR (TFGSUB.TFG_COBCTR = '2')"
    cQueryTFJ += " OR (TFHSUB.TFH_COBCTR = '2'))" 
    cQueryTFJ += " AND TFLSUB.D_E_L_E_T_= ' ' )"

    cQueryTFL += " AND ((TFFSUB.TFF_COBCTR = '2')"
    cQueryTFL += " OR (TFGSUB.TFG_COBCTR = '2')"
    cQueryTFL += " OR (TFHSUB.TFH_COBCTR = '2'))" 
    cQueryTFL += " AND TFLSUB.D_E_L_E_T_= ' ' )"
EndIf 

cMVTFF := "%"+cMVTFF+"%"
cMVTFG := "%"+cMVTFG+"%"
cMVTFH := "%"+cMVTFH+"%"

cQueryTFJ := "%"+cQueryTFJ+"%"
cQueryTFL := "%"+cQueryTFL+"%"

cXfilTFJ := "%"+cXfilTFJ+"%" 
cFiABSTFL := "%"+cFiABSTFL+"%"
cFiSRJTFF := "%"+cFiSRJTFF+"%"
cFiSR6TFF := "%"+cFiSR6TFF+"%"
cFiTDWTFF := "%"+cFiTDWTFF+"%"
cFiSRVABP := "%"+cFiSRVABP+"%"
cFiABNTFU := "%"+cFiABNTFU+"%"

cQuery := "%"+cQuery+"%"
cOrcSimp := "%"+cOrcSimp+"%"

BEGIN REPORT QUERY oReport:Section(1)
    
BeginSql alias cAlias1
    SELECT TFJ_FILIAL,TFJ_CODIGO,TFJ_CODENT,TFJ_LOJA,A1_NOME
    FROM %table:TFJ% TFJ
    %exp:cQuery%
    WHERE TFJ.TFJ_FILIAL %exp:cXfilTFJ%
        AND TFJ.TFJ_CODIGO BETWEEN %exp:mv_par01% AND %exp:mv_par02%
        AND TFJ.TFJ_CODENT BETWEEN %exp:mv_par03% AND %exp:mv_par05%
        AND TFJ.TFJ_LOJA   BETWEEN %exp:mv_par04% AND %exp:mv_par06%
        AND %exp:cOrcSimp% 
        AND TFJ.%notDel%  
        %exp:cQueryTFJ%          
    ORDER BY TFJ_FILIAL,TFJ_CODIGO
EndSql
    
END REPORT QUERY oReport:Section(1)

BEGIN REPORT QUERY oReport:Section(1):Section(1)
    
BeginSql alias cAlias2
    SELECT TFL_FILIAL,TFL_CODIGO,TFL_LOCAL,TFL_DTINI,TFL_DTFIM,TFL_TOTRH,TFL_TOTMI,TFL_TOTMC,ABS_DESCRI
    FROM %table:TFL% TFL
        JOIN %Table:ABS% ABS
            ON %exp:cFiABSTFL%	
            AND ABS.ABS_LOCAL = TFL.TFL_LOCAL
            AND ABS.%NotDEL%
    WHERE TFL_FILIAL   = %report_param: (cAlias1)->TFJ_FILIAL% 
        AND TFL_CODPAI = %report_param: (cAlias1)->TFJ_CODIGO%                         
        AND TFL.%notDel% 
        %exp:cQueryTFL%
    ORDER BY TFL_FILIAL,TFL_CODIGO
EndSql
    
END REPORT QUERY oReport:Section(1):Section(1)

BEGIN REPORT QUERY oReport:Section(1):Section(1):Section(1)

BeginSql alias cAlias3
    SELECT TFF_FILIAL,TFF_COD,TFF_ITEM,TFF_PRODUT,TFF_QTDVEN,TFF_PRCVEN,TFF_PERINI,TFF_PERFIM,RJ_DESC,R6_DESC,TDW_DESC
    FROM %table:TFF% TFF
        LEFT JOIN %Table:TDW% TDW
            ON %exp:cFiTDWTFF%	
            AND TDW.TDW_COD = TFF.TFF_ESCALA
            AND TDW.%NotDEL%
        LEFT JOIN %Table:SRJ% SRJ
            ON %exp:cFiSRJTFF%	
            AND SRJ.RJ_FUNCAO = TFF.TFF_FUNCAO
            AND SRJ.%NotDEL%
        LEFT JOIN %Table:SR6% SR6
            ON %exp:cFiSR6TFF%	
            AND SR6.R6_TURNO = TFF.TFF_TURNO
            AND SR6.%NotDEL%
    WHERE TFF_FILIAL   = %report_param: (cAlias2)->TFL_FILIAL% 
        AND TFF_CODPAI = %report_param: (cAlias2)->TFL_CODIGO% 
        AND %exp:cMVTFF%
        AND TFF.%notDel% 
    ORDER BY TFF_ITEM
EndSql
    
END REPORT QUERY oReport:Section(1):Section(1):Section(1)

If !lOrcPrc
    BEGIN REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(1)
        
    BeginSql alias cAlias4
        SELECT TFG_ITEM,TFG_PRODUT,TFG_QTDVEN,TFG_PRCVEN,TFG_PERINI,TFG_PERFIM
        FROM %table:TFG% TFG
        WHERE TFG_FILIAL   = %report_param: (cAlias3)->TFF_FILIAL%
            AND TFG_CODPAI = %report_param: (cAlias3)->TFF_COD% 
            AND %exp:cMVTFG%
            AND TFG.%notDel% 
        ORDER BY TFG_ITEM
    EndSql
    
    END REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(1)

    BEGIN REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(2)
        
    BeginSql alias cAlias5
        SELECT TFH_ITEM,TFH_PRODUT,TFH_QTDVEN,TFH_PRCVEN,TFH_PERINI,TFH_PERFIM
        FROM %table:TFH% TFH
        WHERE TFH_FILIAL   = %report_param: (cAlias3)->TFF_FILIAL%
            AND TFH_CODPAI = %report_param: (cAlias3)->TFF_COD% 
            AND %exp:cMVTFH%
            AND TFH.%notDel% 
        ORDER BY TFH_ITEM
    EndSql
    
    END REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(2)

    BEGIN REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(3)

    BeginSql alias cAlias6
        SELECT ABP_COD,ABP_ITEM,ABP_BENEFI,ABP_VALOR,ABP_VERBA,RV_DESC
        FROM %table:ABP% ABP
            LEFT JOIN %Table:SRV% SRV
                ON %exp:cFiSRVABP%
                AND SRV.RV_COD = ABP.ABP_VERBA
                AND SRV.%NotDEL%
        WHERE ABP_FILIAL = %report_param: (cAlias3)->TFF_FILIAL%
            AND ABP_ITRH = %report_param: (cAlias3)->TFF_COD% 
            AND ABP.%notDel% 
        ORDER BY ABP_ITEM
    EndSql
    
    END REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(3)

    BEGIN REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(4)

    BeginSql alias cAlias7
        SELECT TFU_CODABN,TFU_VALOR,ABN_DESC
        FROM %table:TFU% TFU
            LEFT JOIN %Table:ABN% ABN
                ON %exp:cFiABNTFU%	
                AND ABN.ABN_CODIGO = TFU.TFU_CODABN
                AND ABN.%NotDEL%
        WHERE TFU.TFU_FILIAL = %report_param: (cAlias3)->TFF_FILIAL%
            AND TFU_CODTFF   = %report_param: (cAlias3)->TFF_COD% 
            AND TFU.%notDel% 
        ORDER BY TFU_CODIGO
    EndSql
    
    END REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(4)
Else
    BEGIN REPORT QUERY oReport:Section(1):Section(1):Section(2)
        
    BeginSql alias cAlias4
        SELECT TFG_ITEM,TFG_PRODUT,TFG_QTDVEN,TFG_PRCVEN,TFG_PERINI,TFG_PERFIM
        FROM %table:TFG% TFG
        WHERE TFG_FILIAL   = %report_param: (cAlias2)->TFL_FILIAL%
            AND TFG_CODPAI = %report_param: (cAlias2)->TFL_CODIGO% 
            AND TFG_LOCAL  = %report_param: (cAlias2)->TFL_LOCAL%
            AND %exp:cMVTFG%
            AND TFG.%notDel% 
        ORDER BY TFG_ITEM
    EndSql
    
    END REPORT QUERY oReport:Section(1):Section(1):Section(2)

    BEGIN REPORT QUERY oReport:Section(1):Section(1):Section(3)
        
    BeginSql alias cAlias5
        SELECT TFH_ITEM,TFH_PRODUT,TFH_QTDVEN,TFH_PRCVEN,TFH_PERINI,TFH_PERFIM
        FROM %table:TFH% TFH
        WHERE TFH_FILIAL   = %report_param: (cAlias2)->TFL_FILIAL%
            AND TFH_CODPAI = %report_param: (cAlias2)->TFL_CODIGO% 
            AND TFH_LOCAL  = %report_param: (cAlias2)->TFL_LOCAL%
            AND %exp:cMVTFH%
            AND TFH.%notDel% 
        ORDER BY TFH_ITEM
    EndSql
    
    END REPORT QUERY oReport:Section(1):Section(1):Section(3)

    BEGIN REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(1)

    BeginSql alias cAlias6
        SELECT ABP_COD,ABP_ITEM,ABP_BENEFI,ABP_VALOR,ABP_VERBA,RV_DESC
        FROM %table:ABP% ABP
            LEFT JOIN %Table:SRV% SRV
                ON %exp:cFiSRVABP%	
                AND SRV.RV_COD = ABP.ABP_VERBA
                AND SRV.%NotDEL%
        WHERE ABP_FILIAL = %report_param: (cAlias3)->TFF_FILIAL%
            AND ABP_ITRH = %report_param: (cAlias3)->TFF_COD% 
            AND ABP.%notDel% 
        ORDER BY ABP_ITEM
    EndSql
    
    END REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(1)

    BEGIN REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(2)

    BeginSql alias cAlias7
        SELECT TFU_CODABN,TFU_VALOR,ABN_DESC
        FROM %table:TFU% TFU
            LEFT JOIN %Table:ABN% ABN
                ON %exp:cFiABNTFU%
                AND ABN.ABN_CODIGO = TFU.TFU_CODABN
                AND ABN.%NotDEL%
        WHERE TFU.TFU_FILIAL = %report_param: (cAlias3)->TFF_FILIAL%
            AND TFU_CODTFF   = %report_param: (cAlias3)->TFF_COD% 
            AND TFU.%notDel% 

        ORDER BY TFU_CODIGO
    EndSql
    
    END REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(2)
Endif
oReport:Section(1):Print()

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPergTRp
Retorna o nome do Pergunte utilizado no relatório
Função utilizada na automação
@author Junior Geraldo
@since 29/05/2020
@return cAutoPerg, string, nome do pergunte
/*/
//-------------------------------------------------------------------------------------
Static Function GetPergTRp()

Return cAutoPerg



//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECRTATV()
Calcula o valor ativo por database

@return 	Valor Ativo
@author 	Vitor kwon
@since		18/01/2022
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TECRTATV(cLocal,dDatIni,dDatFim,cCodTFJ,cCodTFL)

Local nRetorno      := 0
Local cQuery        := ""
Local cAliasTFG     := ""
Local cAliasTFH     := "" 
Local cAliasTFF     := ""
Local cContrt       := Posicione("TFJ",1,xFilial("TFJ")+cCodTFJ,'TFJ_CONTRT')
Local cConrev       := Posicione("TFJ",1,xFilial("TFJ")+cCodTFJ,'TFJ_CONREV')
Local cReco         := Posicione("TFJ",1,xFilial("TFJ")+cCodTFJ,'TFJ_CNTREC')

    // Inicio tabela TFF
         
        cAliasTFF := GetNextAlias()

        cQuery := " SELECT TFF.TFF_COD, TFF.TFF_PERINI ,TFF.TFF_PERFIM, TFF.TFF_QTDVEN, TFF.TFF_PRCVEN FROM "+RetSqlname("TFF")+" TFF "
        cQuery += " WHERE TFF.D_E_L_E_T_ = '' "
        cQuery += " AND TFF.TFF_CODPAI = '"+cCodTFL+"' "
        cQuery += " AND TFF.TFF_CONTRT = '"+cContrt+"' AND TFF.TFF_LOCAL = '"+cLocal+"' AND TFF.TFF_CONREV = '"+cConrev+"' AND TFF.TFF_FILIAL = '"+xFilial("TFF")+"'"
        cQuery += " AND TFF.TFF_ENCE <> '2' "
        cQuery += " AND TFF.TFF_COBCTR <> '2' "
        cQuery := ChangeQuery(cQuery)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTFF,.T.,.T.)   

        While (cAliasTFF)->(!Eof()) 

                iF cReco == '1' .And. ((dTos(dDatabase) >= (cAliasTFF)->(TFF_PERINI)) .And. ((dTos(dDatabase) <= (cAliasTFF)->(TFF_PERFIM)))) // TFF
                    nRetorno += ((cAliasTFF)->(TFF_QTDVEN)*(cAliasTFF)->(TFF_PRCVEN))  
                Elseif cReco <> '1' 
                    nRetorno += nRetorno
                Endif    
                
                //Inicio da TFG  

                cAliasTFG := GetNextAlias()
                cQuery := "  SELECT TFG.TFG_PERINI,TFG.TFG_PERFIM,TFG.TFG_PRCVEN,TFG.TFG_QTDVEN"
                cQuery += "  FROM "+RetSqlname("TFG")+" TFG "
                cQuery += "  WHERE TFG.D_E_L_E_T_ = '' "
                cQuery += "  AND TFG.TFG_FILIAL = '"+xFilial("TFG")+"' "
                cQuery += "  AND TFG.TFG_CODPAI  = '"+(cAliasTFF)->(TFF_COD)+"' "
                cQuery += "  AND TFG.TFG_COBCTR <> '2' "
                cQuery := ChangeQuery(cQuery)
                dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTFG,.T.,.T.)    

                While (cAliasTFG)->(!Eof())  
                    If  cReco == '1' .And. ((dTos(dDatabase) >= (cAliasTFG)->(TFG_PERINI)) .And. ((dTos(dDatabase) <= (cAliasTFG)->(TFG_PERFIM)))) // TFG
                        nRetorno +=((cAliasTFG)->(TFG_QTDVEN)*(cAliasTFG)->(TFG_PRCVEN))  
                    Elseif cReco <> '1' 
                        nRetorno += nRetorno
                    Endif      
                    (cAliasTFG)->(DbSkip())  
                Enddo 
                (cAliasTFG)->(DbCloseArea())

                //Inicio da TFH      

                cAliasTFH := GetNextAlias()
                cQuery := "  SELECT TFH.TFH_PERINI,TFH.TFH_PERFIM,TFH.TFH_PRCVEN,TFH.TFH_QTDVEN"
                cQuery += "  FROM "+RetSqlname("TFH")+" TFH "
                cQuery += "  WHERE TFH.D_E_L_E_T_ = '' "
                cQuery += "  AND TFH_FILIAL = '"+xFilial("TFH")+"' "
                cQuery += "  AND TFH_CODPAI  = '"+(cAliasTFF)->(TFF_COD)+"' "
                cQuery += "  AND TFH_COBCTR <> '2' "
                cQuery := ChangeQuery(cQuery)
                dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTFH,.T.,.T.)   

                While (cAliasTFH)->(!Eof())  
                    iF  cReco == '1'.And.  ((dTos(dDatabase) >= (cAliasTFH)->(TFH_PERINI)) .And. ((dTos(dDatabase) <= (cAliasTFH)->(TFH_PERFIM)))) // TFH
                        nRetorno +=((cAliasTFH)->(TFH_QTDVEN)*(cAliasTFH)->(TFH_PRCVEN))  
                    Elseif cReco <> '1' 
                        nRetorno += nRetorno
                    Endif    
                    (cAliasTFH)->(DbSkip())  
                Enddo 
                (cAliasTFH)->(DbCloseArea()) 

            (cAliasTFF)->(DbSkip())
        Enddo  
        (cAliasTFF)->(DbCloseArea())  

Return Alltrim(Transform(nRetorno,"@E 999,999,999.99")) 
