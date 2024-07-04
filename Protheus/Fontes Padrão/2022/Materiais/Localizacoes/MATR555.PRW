#Include "PROTHEUS.CH"
#Include "REPORT.CH"
#Include "TOPCONN.CH"
#Include "MATR555.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ MATR555    ³ Autor ³Leandro Sousa dos Santos³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descriçào ³ Movimentos ajustados pela Inflacion.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MATR555()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEST                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MATR555()
Local nOpcA    := 0
Local aSays    := {}
Local aButtons := {}
Local aArea    := GetArea()

Private cPerg      := "MATR555"
Private dDatIni    := ("//")
Private dDatFim    := ("//")
Private cIniPro    := ""
Private cFimPro    := ""
Private oReport    := Nil
Private oSectionA  := Nil 
Private cTmpQry    := GetNextAlias()
Private cPictVlr   := "@E 999,999,999,999.99"
	
Pergunte( cPerg, .F. )
aAdd(aSays, OemToAnsi( STR0004 ) )  
aAdd(aButtons, { 5,.T.,{ || Pergunte(cPerg,.T. ) } } )
aAdd(aButtons, { 1,.T.,{ |o| IIf(VldParam(), (nOpcA := 1, o:oWnd:End()), Nil) }} )
aAdd(aButtons, { 2,.T.,{ |o| nOpcA := 2, o:oWnd:End() }} )             

If !(isBlind())
	FormBatch( oemtoansi(STR0001), aSays, aButtons )  //"Este informe imprimira el Ajuste por Inflación."
Else
	nOpcA := 1 //Indica que el usuario seleccionó si para continuar con la impresión.
EndIf


If  nOpcA == 2
	Return
Else
	dDatIni  := MV_PAR01
	dDatFim  := MV_PAR02
	cIniPro  := MV_PAR03
	cFimPro  := MV_PAR04
EndIf 
	
ReportDef()

If isBlind()
	oReport:SetDevice(1)
	oReport:nRemoteType := -1
Endif

oReport:PrintDialog()
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ReportDef³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()
Local cNomeProg := FunName()
Local aSald	:= {}

DEFINE REPORT oReport NAME cNomeProg TITLE STR0002 PARAMETER "" ACTION {|oReport| PrintReport(oReport) } DESCRIPTION STR0003 
oReport:SetTotalInLine(.F.)
oReport:SetLandscape(.T.)	
oReport:ShowParamPage()
oReport:lParamPage := .T.

DEFINE SECTION oSectionA OF oReport TITLE  STR0002  TOTAL IN COLUMN
	
DEFINE CELL NAME "COD_PROD"  	OF oSectionA TITLE "COD_PROD"  SIZE TamSX3("B1_COD")[1]    HEADER ALIGN LEFT 
DEFINE CELL NAME "DESC_PROD"  	OF oSectionA TITLE "DESC_PROD"   SIZE TamSX3("B1_DESC")[1] HEADER ALIGN LEFT 
DEFINE CELL NAME "CONTA"  		OF oSectionA TITLE "CONTA"   SIZE TamSX3("B1_CONTA")[1] HEADER ALIGN LEFT
DEFINE CELL NAME "TIPO"		  	OF oSectionA TITLE "TIPO"   SIZE TamSX3("B1_TIPO")[1] HEADER ALIGN LEFT
DEFINE CELL NAME "VLR_INICIAL"	OF oSectionA TITLE "VLR_INICIAL"  SIZE TamSX3("B1_PRV1")[1] HEADER ALIGN LEFT 
DEFINE CELL NAME "ENTRADAS"  	OF oSectionA TITLE "ENTRADAS"  SIZE TamSX3("B1_PRV1")[1]  HEADER ALIGN LEFT 
DEFINE CELL NAME "SAIDAS"   	OF oSectionA TITLE "SAIDAS"  SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT 
DEFINE CELL NAME "INTERNA"		OF oSectionA TITLE "INTERNA"  SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT
DEFINE CELL NAME "FINAL"			OF oSectionA TITLE "FINAL"  SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT
DEFINE CELL NAME "VLR_ATUAL"	OF oSectionA TITLE "VLR_ATUAL"  SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT	
DEFINE CELL NAME "ENTRADA_ATUAL"OF oSectionA TITLE "ENTRADA_ATUAL"  SIZE TamSX3("B1_PRV1")[1]  HEADER ALIGN LEFT 
DEFINE CELL NAME "SAIDA_ATUAL"  OF oSectionA TITLE "SAIDA_ATUAL"  SIZE TamSX3("B1_PRV1")[1]  HEADER ALIGN LEFT
DEFINE CELL NAME "INT_ATUAL_INTERNA"OF oSectionA TITLE "INT_ATUAL_INTERNA" SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT 
DEFINE CELL NAME "INT_ATUAL_FINAL"OF oSectionA TITLE "INT_ATUAL_FINAL" SIZE TamSX3("B1_PRV1")[1]    HEADER ALIGN LEFT 
DEFINE CELL NAME "ULT_COMPRA"   OF oSectionA TITLE "ULT_COMPRA"  SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT
DEFINE CELL NAME "ULT_COMPRA_ENT" OF oSectionA TITLE "ULT_COMPRA_ENT"  SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT
DEFINE CELL NAME "ULT_COMPRA_SAI" OF oSectionA TITLE "ULT_COMPRA_SAI"  SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT
DEFINE CELL NAME "U_COMPRA_INTERNA" OF oSectionA TITLE "U_COMPRA_INTERNA"  SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT
DEFINE CELL NAME "U_COMPRA_ATUAL" OF oSectionA TITLE "U_COMPRA_ATUAL"  SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT
DEFINE CELL NAME "DIF_VALOR" OF oSectionA TITLE "DIF_VALOR"  SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT
DEFINE CELL NAME "DIF_VALOR_ENT" OF oSectionA TITLE "DIF_VALOR_ENT"  SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT
DEFINE CELL NAME "DIF_VALOR_SAI" OF oSectionA TITLE "DIF_VALOR_SAI"  SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT
DEFINE CELL NAME "DIF_INTERNA" OF oSectionA TITLE "DIF_INTERNA"  SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT
DEFINE CELL NAME "DIF_ATUAL" OF oSectionA TITLE "DIF_ATUAL"  SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT
DEFINE CELL NAME "DIF_COMPRA" OF oSectionA TITLE "DIF_COMPRA"  SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT
DEFINE CELL NAME "DIF_COMPRA_ENT" OF oSectionA TITLE "DIF_COMPRA_ENT"  SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT
DEFINE CELL NAME "DIF_COMPRA_SAI" OF oSectionA TITLE "DIF_COMPRA_SAI"  SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT
DEFINE CELL NAME "DIF_COMPRA_INTERNA" OF oSectionA TITLE "DIF_COMPRA_INTERNA"  SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT
DEFINE CELL NAME "DIF_COMPRA_ATUAL" OF oSectionA TITLE "DIF_COMPRA_ATUAL"  SIZE TamSX3("B1_PRV1")[1]   HEADER ALIGN LEFT



	
oSectionA:Cell("COD_PROD"):SetTitle("")
oSectionA:Cell("DESC_PROD"):SetTitle("")
oSectionA:Cell("CONTA"):SetTitle("")
oSectionA:Cell("TIPO"):SetTitle("")
oSectionA:Cell("VLR_INICIAL"):SetTitle("")
oSectionA:Cell("ENTRADAS"):SetTitle("")
oSectionA:Cell("SAIDAS"):SetTitle("")
oSectionA:Cell("INTERNA"):SetTitle("")
oSectionA:Cell("FINAL"):SetTitle("")		
oSectionA:Cell("VLR_ATUAL"):SetTitle("")
oSectionA:Cell("ENTRADA_ATUAL"):SetTitle("")	
oSectionA:Cell("SAIDA_ATUAL"):SetTitle("")
oSectionA:Cell("INT_ATUAL_INTERNA"):SetTitle("")
oSectionA:Cell("INT_ATUAL_FINAL"):SetTitle("") 	
oSectionA:Cell("ULT_COMPRA"):SetTitle("")
oSectionA:Cell("ULT_COMPRA_ENT"):SetTitle("")
oSectionA:Cell("ULT_COMPRA_SAI"):SetTitle("")
oSectionA:Cell("U_COMPRA_INTERNA"):SetTitle("")
oSectionA:Cell("U_COMPRA_ATUAL"):SetTitle("")
oSectionA:Cell("DIF_VALOR"):SetTitle("")
oSectionA:Cell("DIF_VALOR_ENT"):SetTitle("")
oSectionA:Cell("DIF_VALOR_SAI"):SetTitle("")
oSectionA:Cell("DIF_INTERNA"):SetTitle("")
oSectionA:Cell("DIF_ATUAL"):SetTitle("")
oSectionA:Cell("DIF_COMPRA"):SetTitle("")
oSectionA:Cell("DIF_COMPRA_ENT"):SetTitle("")
oSectionA:Cell("DIF_COMPRA_SAI"):SetTitle("")
oSectionA:Cell("DIF_COMPRA_INTERNA"):SetTitle("")
oSectionA:Cell("DIF_COMPRA_ATUAL"):SetTitle("")

	
	
	
oSectionA:SetHeaderPage(.F.)
oSectionA:SetTotalInLine(.F.)
oSectionA:SetHeaderSection(.F.)
oSectionA:SetHeaderBreak(.T.)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PrintReport ³ Autor ³                    ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintReport(oReport)
Local cQuery    := ""
Local nIndPer   := 0 
Local nIndPerA  := 0
Local nIndReaj  := 0
Local nCont	  := 1
Local aSldAtu := { 0,0,0,0,0,0,0 }
Local aArraySld := {}
Local nx := 1
Local nc := 1
Local cFil		:= '' // FIlial
Local cProd	:= '' // Produto
Local dEmissa	:= ("//") // emissao
Local nQtdIni	:= 0 // Quantidade inicial
Local nSldIni	:= 0 // saldo inicial
Local nIniReaj:= 0 // saldo inicial * reajuste sie
Local nCustE	:= 0 // saldo de todas as entradas sd1
Local nQtdE	:= 0 // quantidade de todas as entradas sd1
Local nReajE	:= 0 // saldo de todas as entradas com seus respectivos reajustes sd1
Local nCustS	:= 0 // saldo de todas as saidas sd2
Local nQtdS	:= 0 // quantidade de todas as saidas sd2
Local nReajS	:= 0 // saldo de todas as entradas com seus respectivos reajustes sd2
Local nCstIntE:= 0 // saldo de todas as entradas internas sd3 
Local nQtdIntE:= 0 // quantidade de todas as entradas internas sd3
Local nReaIntE:= 0 // saldo de todas as entradas internas com seus respectivos reajustes sd3
Local nCstIntS:= 0 // saldo de todas as saidas internas sd3 
Local nQtdIntS:= 0 // quantidade de todas as saidas internas sd3
Local nReaIntS:= 0 // saldo de todas as saidas internas com seus respectivos reajustes sd3
Local nVlUltC	:= 0 // valor ultima compra com o reajuste do parametro inicial
Local nCstIniVl:= 0  // custo inicial valorizado (qtdini) qtd incial * (nVlUltC) // valor ultima compra com o reajuste do parametro inicial 
Local nCstEntVl:= 0 // custo inicial valorizado (nQtdE) qtd incial entrada * (nVlUltC) // valor ultima compra com o reajuste do parametro inicial
Local nCstSaiVl:= 0 // custo inicial valorizado (nQtds) qtd incial saida * (nVlUltC) // valor ultima compra com o reajuste do parametro inicial
Local nCstEntIn := 0
Local nCstSaiInt := 0
Local aSald:={}
Local cDesc := ''
Local dUltCmp :=  ("//")
Local nUltCmp := 0                                            
Local nAHist1:=0
Local nAHist2:=0
Local nAHist3:=0
Local nAHist4:=0
Local nAHist5:=0
			
Local nAHistA1:=0
Local nAHistA2:=0
Local nAHistA3:=0
Local nAHistA4:=0
Local nAHistA5:=0

			
Local nAHistR1:=0
Local nAHistR2:=0
Local nAHistR3:=0
Local nAHistR4:=0
Local nAHistR5:=0

Local nAHistVA1:=0
Local nAHistVA2:=0
Local nAHistVA3:=0
Local nAHistVA4:=0
Local nAHistVA5:=0

Local nAHistVR1:=0
Local nAHistVR2:=0
Local nAHistVR3:=0
Local nAHistVR4:=0
Local nAHistVR5:=0

Local nHist1:=0
Local nHist2:=0
Local nHist3:=0
Local nHist4:=0
Local nHist5:=0
						
Local nHistA1:=0
Local nHistA2:=0
Local nHistA3:=0
Local nHistA4:=0
Local nHistA5:=0
			
						
Local nHistR1:=0
Local nHistR2:=0
Local nHistR3:=0
Local nHistR4:=0
Local nHistR5:=0
			
Local nHistVA1:=0
Local nHistVA2:=0
Local nHistVA3:=0
Local nHistVA4:=0
Local nHistVA5:=0
			
Local nHistVR1:=0
Local nHistVR2:=0
Local nHistVR3:=0
Local nHistVR4:=0
Local nHistVR5:=0

Local nInterna:= 0
Local nFinal:= 0
Local nIntAju:=0 
Local nFinal:=0
Local nInternaC:=0
Local nFinalC:= 0
Local nIntAjIn:= 0
Local nFimaJ:= 0
Local nCompInt := 0
Local nFimComp :=0
Local cConta:=" "

cQuery := " SELECT D1_FILIAL FILIAL, B1_COD PRODUTO, B1_DESC DESCRICAO , B1_TIPO TIPO ,B1_CONTA CONTA,  D1_QUANT QUANTIDADE,D1_EMISSAO EMISSAO, D1_TES TES, 'SD1' AS TABELA, D1_REMITO REMITO, B1_UCOM ULT_COMP, B1_UVLRC VLR_ULT_C ,SUM(D1_CUSTO) CUSTO " 
cQuery += " FROM "  + RetSqlName("SD1") + " SD1 "
cQuery += " INNER JOIN "  + RetSqlName("SB1") + " SB1 ON B1_COD = D1_COD "
cQuery += " WHERE "
cQuery += " D1_COD  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " 
cQuery += " D1_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' AND "
cQuery += " D1_FILIAL = '" + xFilial("SD1") + "   ' AND     "
cQuery += " D1_CUSTO <> 0 AND "
cQuery += " SD1.D_E_L_E_T_ = '' "
cQuery += " AND SB1.D_E_L_E_T_ = '' AND  B1_FILIAL = '" + xFilial("SB1") + "'  "
cQuery += " GROUP BY D1_FILIAL, B1_COD,B1_DESC, B1_TIPO ,B1_CONTA , D1_QUANT ,D1_EMISSAO, D1_TES , D1_REMITO, B1_UCOM, B1_UVLRC "
cQuery += " UNION ALL "
cQuery += " SELECT D2_FILIAL, B1_COD,B1_DESC,B1_TIPO TIPO ,B1_CONTA CONTA, D2_QUANT ,D2_EMISSAO, D2_TES, 'SD2' AS TABELA, D2_REMITO, B1_UCOM, B1_UVLRC , SUM(D2_CUSTO1) CUSTO "  
cQuery += " FROM "  + RetSqlName("SD2") + " SD2 " 
cQuery += " INNER JOIN "  + RetSqlName("SB1") + " SB1 ON B1_COD = D2_COD "
cQuery += " WHERE "
cQuery += " D2_COD  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
cQuery += " D2_FILIAL = '" + xFilial("SD2") + "' AND   "
cQuery += " D2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' AND " 
cQuery += " D2_CUSTO1 <> 0  AND "
cQuery += " SD2.D_E_L_E_T_ = '' "
cQuery += " AND SB1.D_E_L_E_T_ = '' AND  B1_FILIAL = '" + xFilial("SB1") + "'  "
cQuery += " GROUP BY D2_FILIAL, B1_COD,B1_DESC, B1_TIPO ,B1_CONTA , D2_QUANT ,D2_EMISSAO, D2_TES , D2_REMITO, B1_UCOM, B1_UVLRC "
cQuery += " UNION ALL "
cQuery += " SELECT D3_FILIAL, B1_COD,B1_DESC, B1_TIPO TIPO ,B1_CONTA CONTA, D3_QUANT ,D3_EMISSAO, D3_TM, 'SD3' AS TABELA, 'REMITO' REMITO, B1_UCOM, B1_UVLRC , SUM(D3_CUSTO1) CUSTO  "
cQuery += " FROM "  + RetSqlName("SD3") + " SD3 " 
cQuery += " INNER JOIN "  + RetSqlName("SB1") + " SB1 ON B1_COD = D3_COD "
cQuery += " WHERE D3_COD  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " 
cQuery += " D3_FILIAL = '" + xFilial("SD3") + "'  AND   "
cQuery += " D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' AND " 
cQuery += " D3_CUSTO1 <> 0 AND  SD3.D_E_L_E_T_ = '' "
cQuery += " AND SB1.D_E_L_E_T_ = '' AND  B1_FILIAL = '" + xFilial("SB1") + "'  "
cQuery += " GROUP BY D3_FILIAL, B1_COD,B1_DESC, B1_TIPO ,B1_CONTA , D3_QUANT ,D3_EMISSAO, D3_TM ,  B1_UCOM, B1_UVLRC "
cQuery += " order by FILIAL,CONTA,PRODUTO,EMISSAO "

cQuery := ChangeQuery(cQuery)	
	
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cTmpQry,.T.,.T.)


oSectionA:Init()
oSectionA:Cell("COD_PROD"):SetTitle("")
oSectionA:Cell("DESC_PROD"):SetTitle("")
oSectionA:Cell("CONTA"):SetTitle("")
oSectionA:Cell("TIPO"):SetTitle("")
oSectionA:Cell("VLR_INICIAL"):SetTitle("")
oSectionA:Cell("ENTRADAS"):SetTitle("")
oSectionA:Cell("SAIDAS"):SetTitle("")
oSectionA:Cell("INTERNA"):SetTitle("")
oSectionA:Cell("FINAL"):SetTitle("")		
oSectionA:Cell("VLR_ATUAL"):SetTitle("")
oSectionA:Cell("ENTRADA_ATUAL"):SetTitle("")	
oSectionA:Cell("SAIDA_ATUAL"):SetTitle("")
oSectionA:Cell("INT_ATUAL_INTERNA"):SetTitle("")
oSectionA:Cell("INT_ATUAL_FINAL"):SetTitle("") 	
oSectionA:Cell("ULT_COMPRA"):SetTitle("")
oSectionA:Cell("ULT_COMPRA_ENT"):SetTitle("")
oSectionA:Cell("ULT_COMPRA_SAI"):SetTitle("")
oSectionA:Cell("U_COMPRA_INTERNA"):SetTitle("")
oSectionA:Cell("U_COMPRA_ATUAL"):SetTitle("")
oSectionA:Cell("DIF_VALOR"):SetTitle("")
oSectionA:Cell("DIF_VALOR_ENT"):SetTitle("")
oSectionA:Cell("DIF_VALOR_SAI"):SetTitle("")
oSectionA:Cell("DIF_INTERNA"):SetTitle("")
oSectionA:Cell("DIF_ATUAL"):SetTitle("")
oSectionA:Cell("DIF_COMPRA"):SetTitle("")
oSectionA:Cell("DIF_COMPRA_ENT"):SetTitle("")
oSectionA:Cell("DIF_COMPRA_SAI"):SetTitle("")
oSectionA:Cell("DIF_COMPRA_INTERNA"):SetTitle("")
oSectionA:Cell("DIF_COMPRA_ATUAL"):SetTitle("")

oSectionA:Cell("COD_PROD"):SetValue(STR0009) //CODIGO PRODUTO
oSectionA:Cell("DESC_PROD"):SetValue(STR0010)//DESCRICAO
oSectionA:Cell("CONTA"):SetValue(STR0011)//CONTA
oSectionA:Cell("TIPO"):SetValue(STR0012)//TIPO
oSectionA:Cell("VLR_INICIAL"):SetValue(STR0013)//VLR_INICIAL
oSectionA:Cell("ENTRADAS"):SetValue(STR0014)// ENTRADAS
oSectionA:Cell("SAIDAS"):SetValue(STR0015)//SAIDA
oSectionA:Cell("INTERNA"):SetValue(STR0016)//INTERNAS
oSectionA:Cell("FINAL"):SetValue(STR0017)//FINAL
oSectionA:Cell("VLR_ATUAL"):SetValue(STR0018)//VLR_ATUAL
oSectionA:Cell("ENTRADA_ATUAL"):SetValue(STR0019)//ENTRADA_ATUAL
oSectionA:Cell("SAIDA_ATUAL"):SetValue(STR0020)//SAIDA_ATUAL
oSectionA:Cell("INT_ATUAL_INTERNA"):SetValue(STR0021)//INT_ATUAL_ENT
oSectionA:Cell("INT_ATUAL_FINAL"):SetValue(STR0022)//INT_ATUAL_SAI
oSectionA:Cell("ULT_COMPRA"):SetValue(STR0023)//ULT_COMPRA
oSectionA:Cell("ULT_COMPRA_ENT"):SetValue(STR0024)//ULT_COMPRA_ENT
oSectionA:Cell("ULT_COMPRA_SAI"):SetValue(STR0025)//ULT_COMPRA_SAI
oSectionA:Cell("U_COMPRA_INTERNA"):SetValue(STR0027)//U_COMPRA_SAI_INT
oSectionA:Cell("U_COMPRA_ATUAL"):SetValue(STR0038)//U_COMPRA_SAI_INT
oSectionA:Cell("DIF_VALOR"):SetValue(STR0028)//DIF_VALOR
oSectionA:Cell("DIF_VALOR_ENT"):SetValue(STR0029)//DIF_VALOR_ENT
oSectionA:Cell("DIF_VALOR_SAI"):SetValue(STR0030)//DIF_VALOR_SAI
oSectionA:Cell("DIF_INTERNA"):SetValue(STR0031)//DIF_INTERNA
oSectionA:Cell("DIF_ATUAL"):SetValue(STR0032)//DIF_ATUAL
oSectionA:Cell("DIF_COMPRA"):SetValue(STR0033)//DIF_COMPRA
oSectionA:Cell("DIF_COMPRA_ENT"):SetValue(STR0034)//DIF_COMPRA_ENT
oSectionA:Cell("DIF_COMPRA_SAI"):SetValue(STR0035)//DIF_COMPRA_SAI
oSectionA:Cell("DIF_COMPRA_INTERNA"):SetValue(STR0036)//DIF_COMPRA_INTERNA
oSectionA:Cell("DIF_COMPRA_ATUAL"):SetValue(STR0037)//DIF_COMPRA_ATUAL

oSectionA:PrintLine()
oReport:ThinLine()	

cProd :=""
(cTmpQry)->(dbGoTop())
While (cTmpQry)->(!Eof())
	
	nExist:=  aScan(aSald, {|x| x[1]== (cTmpQry)->(PRODUTO)})
	IF nExist == 0  

		aArea:=GetArea()
		
		dbSelectArea("SB2")
		dbSetOrder(1)
		aSldAtu := { 0,0,0,0,0,0,0 } 
		MsSeek(xFilial("SB2")+(cTmpQry)->(PRODUTO))
		While SB2->(!Eof()) .And. SB2->B2_FILIAL+ SB2->B2_COD == xFilial("SB2") +(cTmpQry)->(PRODUTO)
			aArraySld := CalcEst((cTmpQry)->(PRODUTO),SB2->B2_LOCAL,mv_par01)
			For nx :=1 to Len(aSldAtu)
				aSldAtu[nx] += aArraySld[nx]
			Next nx
			SB2->(dbSkip())
			nQtdIni := aSldAtu[1]
			nSldIni := aSldAtu[2]
		EndDo
		RestArea(aArea)
		
		nIndPerA := POSICIONE("SIE",1,XFILIAL("SIE")+STRZERO(YEAR(stod((cTmpQry)->(ULT_COMP))),4)+STRZERO(MONTH(stod((cTmpQry)->(ULT_COMP))),2),"IE_INDICE")
		nIndPer  := POSICIONE("SIE",1,XFILIAL("SIE")+STRZERO(YEAR(dDatFim),4)+STRZERO(MONTH(dDatFim),2),"IE_INDICE")
		nIndReaj := (nIndPer/nIndPerA)
		nVlUltC  := (cTmpQry)->(VLR_ULT_C) * nIndReaj
		nCstIniVl:= nVlUltC * nQtdIni
		
		cProd := (cTmpQry)->(PRODUTO)
		cTipo :=(cTmpQry)->(TIPO )
		cConta:=(cTmpQry)->(CONTA)
		
		cFil  := (cTmpQry)->(FILIAL) 
		cProd := (cTmpQry)->(PRODUTO) 
		cDesc := (cTmpQry)->(DESCRICAO)
		
		cDtReaj := STRZERO(YEAR(dDatIni),4)+STRZERO(MONTH(dDatIni),2)
		nIndPerA := POSICIONE("SIE",1,XFILIAL("SIE")+STRZERO(YEAR(dDatIni),4)+STRZERO(MONTH(dDatIni),2),"IE_INDICE")
		nIndPer  := POSICIONE("SIE",1,XFILIAL("SIE")+STRZERO(YEAR(dDatFim),4)+STRZERO(MONTH(dDatFim),2),"IE_INDICE")
		nIndReaj := (nIndPer/nIndPerA)
		nIniReaj := nSldIni * nIndReaj
		
		
		
		aadd(aSald,{cProd,cDesc,cConta,cTipo,nSldIni,0,0,0,0,nIniReaj,0,0,0,0,nCstIniVl,0,0,0,0})
		nLin:=Len(aSald)
	Else
		nLin:= nExist
	ENDIF
	
	
	IF (cTmpQry)->(TABELA) $ 'SD1|SD2'
		If cPaisloc<>"BRA" .AND. !Empty((cTmpQry)->(REMITO))
			(cTmpQry)->(dbSkip())
			Loop
		EndIf
	EndIf

	IF (cTmpQry)->(TABELA) <> 'SD3'
		aArea:=GetArea()
		dbSelectArea("SF4")
		dbSetOrder(1)
		SF4->(MsSeek(xFilial("SF4")+(cTmpQry)->TES))
		If SF4->F4_ESTOQUE # "S"
			RestArea(aArea)
			(cTmpQry)->(dbSkip())
			Loop
		EndIf
		RestArea(aArea)
	ENDIF
	
	
	 
	nIndPerA := POSICIONE("SIE",1,XFILIAL("SIE")+STRZERO(YEAR(stod((cTmpQry)->(EMISSAO))),4)+STRZERO(MONTH(stod((cTmpQry)->(EMISSAO))),2),"IE_INDICE")
	nIndPer  := POSICIONE("SIE",1,XFILIAL("SIE")+STRZERO(YEAR(dDatFim),4)+STRZERO(MONTH(dDatFim),2),"IE_INDICE")
	nIndReaj := (nIndPer/nIndPerA)
	
	dEmissa := (cTmpQry)->(EMISSAO)
	dUltCmp :=  (cTmpQry)->(ULT_COMP)
	nUltCmp := (cTmpQry)->(VLR_ULT_C)	
	nQtdAux := nQtdIni
	nAuxIni := nSldIni 
	
	If (cTmpQry)->(TABELA) <> "SD3"			
		If (cTmpQry)->(TES) <= "500"
			// nCustE += (cTmpQry)->(CUSTO) 
			aSald[nLin][6] += (cTmpQry)->(CUSTO)
			nQtdE  += (cTmpQry)->(QUANTIDADE)
			// nReajE += (cTmpQry)->(CUSTO) * nIndReaj
			aSald[nLin][11]+= (cTmpQry)->(CUSTO) * nIndReaj
		Else
			// nCustS += (cTmpQry)->(CUSTO)
			 aSald[nLin][7] += (cTmpQry)->(CUSTO)
			nQtdS  += (cTmpQry)->(QUANTIDADE)
			
			// nReajS += (cTmpQry)->(CUSTO) * nIndReaj
			aSald[nLin][12]+= (cTmpQry)->(CUSTO) * nIndReaj
		EndIf
	ELSE
		If (cTmpQry)->(TES) <= "500"
			// nCstIntE += (cTmpQry)->(CUSTO) 
			aSald[nlin][8] += (cTmpQry)->(CUSTO)
			nQtdIntE  += (cTmpQry)->(QUANTIDADE)
			
			//nReaIntE += (cTmpQry)->(CUSTO) * nIndReaj
			aSald[nlin][13]+= (cTmpQry)->(CUSTO) * nIndReaj
		Else
			// nCstIntS += (cTmpQry)->(CUSTO) 
			aSald[nLin][9]+= (cTmpQry)->(CUSTO)
			nQtdIntS  += (cTmpQry)->(QUANTIDADE)
			
			// nReaIntS += (cTmpQry)->(CUSTO) * nIndReaj
			aSald[nLin][14]+= (cTmpQry)->(CUSTO) * nIndReaj
		EndIf
	ENDIF
	
	
	(cTmpQry)->(dbSkip())
	
	If cProd <> (cTmpQry)->(PRODUTO)  .or. (cTmpQry)->(EOF())
			
		nIndPerA := POSICIONE("SIE",1,XFILIAL("SIE")+STRZERO(YEAR(STOD(dUltCmp)),4)+STRZERO(MONTH(STOD(dUltCmp)),2),"IE_INDICE")
		nIndPer  := POSICIONE("SIE",1,XFILIAL("SIE")+STRZERO(YEAR(dDatFim),4)+STRZERO(MONTH(dDatFim),2),"IE_INDICE")
		nIndReaj := (nIndPer/nIndPerA)
		nVlUltC  := nUltCmp * nIndReaj
		aSald[nLin][16]:= nUltCmp * nQtdE 
		aSald[nLin][17]:= nUltCmp * nQtdS
		aSald[nLin][18] := nUltCmp * nQtdIntE
		aSald[nLin][19]:= nUltCmp * nQtdIntS
	EndIf		

EndDo
	
	
If Len(aSald)>0
	cConta:= aSald[1][3]
EndIf 
For nC := 1 to Len(aSald)
	If  oReport:Cancel()
		Exit
	EndIf

	 
	If Cconta<> aSald[nC][3]   // Totalizadores por conta
	
		oSectionA:Cell("COD_PROD"):SetValue(STR0026)//TOTAL POR CONTA
		oSectionA:Cell("DESC_PROD"):SetValue("")  
		oSectionA:Cell("CONTA"):SetValue(Cconta)
		oSectionA:Cell("TIPO"):SetValue("")
		 
		 // iNICIAL
		oSectionA:Cell("VLR_INICIAL"):SetValue(Transform(nHist1,cPictVlr)) 
		oSectionA:Cell("ENTRADAS"):SetValue(Transform(nHist2,cPictVlr))
		oSectionA:Cell("SAIDAS"):SetValue(Transform(nHist3,cPictVlr))                 
		oSectionA:Cell("INTERNA"):SetValue(Transform(nHist4,cPictVlr))
		oSectionA:Cell("FINAL"):SetValue(Transform(nHist5,cPictVlr))      
		
		//INICIAL AJUSTADO                
		oSectionA:Cell("VLR_ATUAL"):SetValue(Transform(nHistA1,cPictVlr))
		oSectionA:Cell("ENTRADA_ATUAL"):SetValue(Transform(nHistA2,cPictVlr))
		oSectionA:Cell("SAIDA_ATUAL"):SetValue(Transform(nHistA3,cPictVlr))     
		oSectionA:Cell("INT_ATUAL_INTERNA"):SetValue(Transform(nHistA4,cPictVlr))
		oSectionA:Cell("INT_ATUAL_FINAL"):SetValue(Transform(nHistA5,cPictVlr))
		
		
		  // uLTIMA COMPRA
		oSectionA:Cell("ULT_COMPRA"):SetValue(Transform(nHistR1,cPictVlr))
		oSectionA:Cell("ULT_COMPRA_ENT"):SetValue(Transform(nHistR2,cPictVlr))
		oSectionA:Cell("ULT_COMPRA_SAI"):SetValue(Transform(nHistR3,cPictVlr))
		oSectionA:Cell("U_COMPRA_INTERNA"):SetValue(Transform(nHistR4,cPictVlr))
		oSectionA:Cell("U_COMPRA_ATUAL"):SetValue(Transform(nHistR5,cPictVlr))
	    
	     //Dif  Ajust      ajustado - inicial
		oSectionA:Cell("DIF_VALOR"):SetValue(Transform(nHistVA1,cPictVlr))
		oSectionA:Cell("DIF_VALOR_ENT"):SetValue(Transform(nHistVA2,cPictVlr))
		oSectionA:Cell("DIF_VALOR_SAI"):SetValue(Transform(nHistVA3,cPictVlr))   
		oSectionA:Cell("DIF_INTERNA"):SetValue(Transform(nHistVA4,cPictVlr))
		oSectionA:Cell("DIF_ATUAL"):SetValue(Transform(nHistVA5,cPictVlr))
		                                                                                                  
		                                                                                                  
		//  Dif Compra   compras - inicial           Ajustado                                                                                                                   
		oSectionA:Cell("DIF_COMPRA"):SetValue(Transform(nHistVR1,cPictVlr))
		oSectionA:Cell("DIF_COMPRA_ENT"):SetValue(Transform(nHistVR2,cPictVlr))
		oSectionA:Cell("DIF_COMPRA_SAI"):SetValue(Transform(nHistVR3,cPictVlr))        
		oSectionA:Cell("DIF_COMPRA_INTERNA"):SetValue(Transform(nHistVR4,cPictVlr)) 
		oSectionA:Cell("DIF_COMPRA_ATUAL"):SetValue(Transform(nHistVR5,cPictVlr))
	
		oSectionA:PrintLine()
		oReport:SkipLine(1)

		nAHist1+=nHist1
		nAHist2+=nHist2
		nAHist3+=nHist3
		nAHist4+=nHist4
		nAHist5+= nHist5
			
		nAHistA1+= nHistA1
		nAHistA2+=nHistA2
		nAHistA3+=nHistA3
		nAHistA4+=nHistA4
		nAHistA5+= nHistA5

			
		nAHistR1+=nHistR1
		nAHistR2+=nHistR2
		nAHistR3+=nHistR3
		nAHistR4+=nHistR4
		nAHistR5+=nHistR5

		nAHistVA1+=nHistVA1
		nAHistVA2+=nHistVA2
		nAHistVA3+=nHistVA3
		nAHistVA4+=nHistVA4
		nAHistVA5+=nHistVA5

		nAHistVR1+=nHistVR1
		nAHistVR2+=nHistVR2
		nAHistVR3+=nHistVR3
		nAHistVR4+=nHistVR4
		nAHistVR5+=nHistVR5
	
	  // Zera Variavel total por conta          

		nHist1:=0
		NHist2:=0
		NHist3:=0
		NHist4:=0
		NHist5:=0
					
		NHistA1:=0
		NHistA2:=0
		NHistA3:=0
		NHistA4:=0
		NHistA5:=0
		
					
		NHistR1:=0
		NHistR2:=0
		NHistR3:=0
		NHistR4:=0
		NHistR5:=0
		
		NHistVA1:=0
		NHistVA2:=0
		NHistVA3:=0
		NHistVA4:=0
		NHistVA5:=0
		
		NHistVR1:=0
		NHistVR2:=0
		NHistVR3:=0
		NHistVR4:=0
		NHistVR5:=0
		
		
	EndIf

	// Dsecarrega conteudo do array
	cProd	:=aSald[nC][1]
	cDesc 	:=aSald[nC][2]
	cConta 	:=aSald[nC][3]
	cTipo 	:=aSald[nC][4]
	nSldIni 	:=aSald[nC][5]
	nCustE 	:=aSald[nC][6]
	nCustS 	:=aSald[nC][7]
	nCstIntE:=aSald[nC][8]
	nCstIntS:=aSald[nC][9]
	nIniReaj :=aSald[nC][10]
	nReajE :=aSald[nC][11]
	nReajS :=aSald[nC][12]
	nReaIntE :=aSald[nC][13]
	nReaIntS :=aSald[nC][14]
	nCstIniVl :=aSald[nC][15]
	nCstEntVl :=aSald[nC][16]
	nCstSaiVl :=aSald[nC][17]
	nCstEntIn :=aSald[nC][18]
	nCstSaiIn :=aSald[nC][19]
	
	oSectionA:Cell("COD_PROD"):SetValue(cProd)
	oSectionA:Cell("DESC_PROD"):SetValue(cDesc)  
	oSectionA:Cell("CONTA"):SetValue(cConta)
	oSectionA:Cell("TIPO"):SetValue(cTipo) 
	 // iNICIAL
	oSectionA:Cell("VLR_INICIAL"):SetValue(Transform(nSldIni,cPictVlr)) 
	oSectionA:Cell("ENTRADAS"):SetValue(Transform(nCustE,cPictVlr))
	oSectionA:Cell("SAIDAS"):SetValue(Transform(nCustS,cPictVlr))                 
	
	nInterna:=nCstIntE - nCstIntS
	oSectionA:Cell("INTERNA"):SetValue(Transform(nInterna,cPictVlr))
	
	nFinal:= nSldIni+nCustE-nCustS+nInterna
	oSectionA:Cell("FINAL"):SetValue(Transform(nFinal,cPictVlr))      
	
	//INICIAL AJUSTADO                
	oSectionA:Cell("VLR_ATUAL"):SetValue(Transform(nIniReaj,cPictVlr))
	oSectionA:Cell("ENTRADA_ATUAL"):SetValue(Transform(nReajE,cPictVlr))
	oSectionA:Cell("SAIDA_ATUAL"):SetValue(Transform(nReajS,cPictVlr))     
	 
	nIntAju:=nReaIntE-nReaIntS    // 
	oSectionA:Cell("INT_ATUAL_INTERNA"):SetValue(Transform(nIntAju,cPictVlr))
	 
	nFinal:= nIniReaj+nReajE- nReajS +nIntAju
	oSectionA:Cell("INT_ATUAL_FINAL"):SetValue(Transform(nFinal,cPictVlr))
	
	
	  // uLTIMA COMPRA
	oSectionA:Cell("ULT_COMPRA"):SetValue(Transform(nCstIniVl,cPictVlr))
	oSectionA:Cell("ULT_COMPRA_ENT"):SetValue(Transform(nCstEntVl,cPictVlr))
	oSectionA:Cell("ULT_COMPRA_SAI"):SetValue(Transform(nCstSaiVl,cPictVlr))
                                              
    nInternaC:=nCstEntIn - nCstSaiIn 
	oSectionA:Cell("U_COMPRA_INTERNA"):SetValue(Transform(nInternaC,cPictVlr))
	
    nFinalC:=nCstIniVl+nCstEntVl-nCstSaiVl-nInternaC
	oSectionA:Cell("U_COMPRA_ATUAL"):SetValue(Transform(nFinalC,cPictVlr))
    
     //Dif  Ajust      ajustado - inicial
	oSectionA:Cell("DIF_VALOR"):SetValue(Transform(nIniReaj-nSldIni,cPictVlr))
	oSectionA:Cell("DIF_VALOR_ENT"):SetValue(Transform(nReajE-nCustE,cPictVlr))
	oSectionA:Cell("DIF_VALOR_SAI"):SetValue(Transform(nReajS-nCustS,cPictVlr))   
	
	nIntAjIn:=  (nCstIntE-nCstIntE)   - (  nCstIntS-nCstIntS ) 
	oSectionA:Cell("DIF_INTERNA"):SetValue(Transform(nIntAjIn,cPictVlr))
	
	nFimaJ:= (nIniReaj-nSldIni) + (nReajE-nCustE) - ( nReajS-nCustS ) +  nIntAjIn
	oSectionA:Cell("DIF_ATUAL"):SetValue(Transform(nFimaJ,cPictVlr))
	                                                                                                  
	                                                                                                  
	//  Dif Compra   compras - inicial           Ajustado                                                                                                                   
	oSectionA:Cell("DIF_COMPRA"):SetValue(Transform(nCstIniVl - nSldIni,cPictVlr))
	oSectionA:Cell("DIF_COMPRA_ENT"):SetValue(Transform(nCstEntVl - nCustE,cPictVlr))
	oSectionA:Cell("DIF_COMPRA_SAI"):SetValue(Transform(nCstSaiVl - nCustS,cPictVlr))        
	
	          
	 nCompInt := nInternaC - (nCstIntE -nCstIntS) 
	oSectionA:Cell("DIF_COMPRA_INTERNA"):SetValue(Transform( nCompInt,cPictVlr)) 
	
	
	 nFimComp :=  (nCstIniVl - nSldIni) + (nCstEntVl - nCustE ) -( nCstSaiVl - nCustS) + ( nCompInt )
	oSectionA:Cell("DIF_COMPRA_ATUAL"):SetValue(Transform( nFimComp,cPictVlr))
	
	nHist1+=nSldIni
	nHist2+=nCustE
	nHist3+=nCustS
	nHist4+=nCstIntE
	nHist4-=nCstIntS
	nHist5+= (nHist1+nHist2)-(nHist3)+(nHist4)   
		
	nHistA1+= nIniReaj
	nHistA2+=nReajE
	nHistA3+=nReajS
	nHistA4+=nCstIntE
	nHistA4-=nCstIntS
	nHistA5+= (nHistA1+nHistA2)-(nHistA3)+(nHistA4)
		
	nHistR1+=nCstIniVl
	nHistR2+=nCstEntVl
	nHistR3+=nCstSaiVl
	nHistR4+=nInternaC
	nHistR5+= nFinalC

	nHistVA1+=	  (nIniReaj-nSldIni)		
	nHistVA2+=    (nReajE-nCustE)
	nHistVA3+=   (nReajS-nCustS)
	nHistVA4+=    nIntAjIn
	nHistVA5+=    nFimaJ

	nHistVR1+= (nCstIniVl - nSldIni)
	nHistVR2+= (nCstEntVl - nCustE)
	nHistVR3+= (nCstSaiVl - nCustS)
	nHistVR4+=nCompInt
	nHistVR5+=nFimComp
	 
	//cConta:= aSald[nC][3]
	  
	oSectionA:PrintLine()
	
	
NEXT
	
//	Linha total conta
oSectionA:Cell("COD_PROD"):SetValue(STR0026)//TOTAL POR CONTA
oSectionA:Cell("DESC_PROD"):SetValue("")  
oSectionA:Cell("CONTA"):SetValue(Cconta)
oSectionA:Cell("TIPO"):SetValue("")
 
 // iNICIAL
oSectionA:Cell("VLR_INICIAL"):SetValue(Transform(nHist1,cPictVlr)) 
oSectionA:Cell("ENTRADAS"):SetValue(Transform(nHist2,cPictVlr))
oSectionA:Cell("SAIDAS"):SetValue(Transform(nHist3,cPictVlr))                 
oSectionA:Cell("INTERNA"):SetValue(Transform(nHist4,cPictVlr))
oSectionA:Cell("FINAL"):SetValue(Transform(nHist5,cPictVlr))      

//INICIAL AJUSTADO                
oSectionA:Cell("VLR_ATUAL"):SetValue(Transform(nHistA1,cPictVlr))
oSectionA:Cell("ENTRADA_ATUAL"):SetValue(Transform(nHistA2,cPictVlr))
oSectionA:Cell("SAIDA_ATUAL"):SetValue(Transform(nHistA3,cPictVlr))     
oSectionA:Cell("INT_ATUAL_INTERNA"):SetValue(Transform(nHistA4,cPictVlr))
oSectionA:Cell("INT_ATUAL_FINAL"):SetValue(Transform(nHistA5,cPictVlr))


  // uLTIMA COMPRA
oSectionA:Cell("ULT_COMPRA"):SetValue(Transform(nHistR1,cPictVlr))
oSectionA:Cell("ULT_COMPRA_ENT"):SetValue(Transform(nHistR2,cPictVlr))
oSectionA:Cell("ULT_COMPRA_SAI"):SetValue(Transform(nHistR3,cPictVlr))
oSectionA:Cell("U_COMPRA_INTERNA"):SetValue(Transform(nHistR4,cPictVlr))
oSectionA:Cell("U_COMPRA_ATUAL"):SetValue(Transform(nHistR5,cPictVlr))

 //Dif  Ajust      ajustado - inicial
oSectionA:Cell("DIF_VALOR"):SetValue(Transform(nHistVA1,cPictVlr))
oSectionA:Cell("DIF_VALOR_ENT"):SetValue(Transform(nHistVA2,cPictVlr))
oSectionA:Cell("DIF_VALOR_SAI"):SetValue(Transform(nHistVA3,cPictVlr))   
oSectionA:Cell("DIF_INTERNA"):SetValue(Transform(nHistVA4,cPictVlr))
oSectionA:Cell("DIF_ATUAL"):SetValue(Transform(nHistVA5,cPictVlr))
                                                                                                  
                                                                                                  
//  Dif Compra   compras - inicial           Ajustado                                                                                                                   
oSectionA:Cell("DIF_COMPRA"):SetValue(Transform(nHistVR1,cPictVlr))
oSectionA:Cell("DIF_COMPRA_ENT"):SetValue(Transform(nHistVR2,cPictVlr))
oSectionA:Cell("DIF_COMPRA_SAI"):SetValue(Transform(nHistVR3,cPictVlr))        
oSectionA:Cell("DIF_COMPRA_INTERNA"):SetValue(Transform(nHistVR4,cPictVlr)) 
oSectionA:Cell("DIF_COMPRA_ATUAL"):SetValue(Transform(nHistVR5,cPictVlr))

oSectionA:PrintLine()
		
		                              

// Totaliza relatorio


nAHist1+=nHist1
nAHist2+=nHist2
nAHist3+=nHist3
nAHist4+=nHist4
nAHist5+= nHist5
	
nAHistA1+= nHistA1
nAHistA2+=nHistA2
nAHistA3+=nHistA3
nAHistA4+=nHistA4
nAHistA5+= nHistA5

	
nAHistR1+=nHistR1
nAHistR2+=nHistR2
nAHistR3+=nHistR3
nAHistR4+=nHistR4
nAHistR5+=nHistR5

nAHistVA1+=nHistVA1
nAHistVA2+=nHistVA2
nAHistVA3+=nHistVA3
nAHistVA4+=nHistVA4
nAHistVA5+=nHistVA5

nAHistVR1+=nHistVR1
nAHistVR2+=nHistVR2
nAHistVR3+=nHistVR3
nAHistVR4+=nHistVR4
nAHistVR5+=nHistVR5
		
//		Imprime totalizador

oSectionA:Cell("COD_PROD"):SetValue(" TOTAL ")
oSectionA:Cell("DESC_PROD"):SetValue("")  
oSectionA:Cell("CONTA"):SetValue("")
oSectionA:Cell("TIPO"):SetValue("")
 
 // iNICIAL
oSectionA:Cell("VLR_INICIAL"):SetValue(Transform(nAHist1,cPictVlr)) 
oSectionA:Cell("ENTRADAS"):SetValue(Transform(nAHist2,cPictVlr))
oSectionA:Cell("SAIDAS"):SetValue(Transform(nAHist3,cPictVlr))                 
oSectionA:Cell("INTERNA"):SetValue(Transform(nAHist4,cPictVlr))
oSectionA:Cell("FINAL"):SetValue(Transform(nAHist5,cPictVlr))      

//INICIAL AJUSTADO                
oSectionA:Cell("VLR_ATUAL"):SetValue(Transform(nAHistA1,cPictVlr))
oSectionA:Cell("ENTRADA_ATUAL"):SetValue(Transform(nAHistA2,cPictVlr))
oSectionA:Cell("SAIDA_ATUAL"):SetValue(Transform(nAHistA3,cPictVlr))     
oSectionA:Cell("INT_ATUAL_INTERNA"):SetValue(Transform(nAHistA4,cPictVlr))
oSectionA:Cell("INT_ATUAL_FINAL"):SetValue(Transform(nAHistA5,cPictVlr))


  // uLTIMA COMPRA
oSectionA:Cell("ULT_COMPRA"):SetValue(Transform(nAHistR1,cPictVlr))
oSectionA:Cell("ULT_COMPRA_ENT"):SetValue(Transform(nAHistR2,cPictVlr))
oSectionA:Cell("ULT_COMPRA_SAI"):SetValue(Transform(nAHistR3,cPictVlr))
oSectionA:Cell("U_COMPRA_INTERNA"):SetValue(Transform(nAHistR4,cPictVlr))
oSectionA:Cell("U_COMPRA_ATUAL"):SetValue(Transform(nAHistR5,cPictVlr))

 //Dif  Ajust      ajustado - inicial
oSectionA:Cell("DIF_VALOR"):SetValue(Transform(nAHistVA1,cPictVlr))
oSectionA:Cell("DIF_VALOR_ENT"):SetValue(Transform(nAHistVA2,cPictVlr))
oSectionA:Cell("DIF_VALOR_SAI"):SetValue(Transform(nAHistVA3,cPictVlr))   
oSectionA:Cell("DIF_INTERNA"):SetValue(Transform(nAHistVA4,cPictVlr))
oSectionA:Cell("DIF_ATUAL"):SetValue(Transform(nAHistVA5,cPictVlr))
                                                                                                  
                                                                                                  
//  Dif Compra   compras - inicial           Ajustado                                                                                                                   
oSectionA:Cell("DIF_COMPRA"):SetValue(Transform(nAHistVR1,cPictVlr))
oSectionA:Cell("DIF_COMPRA_ENT"):SetValue(Transform(nAHistVR2,cPictVlr))
oSectionA:Cell("DIF_COMPRA_SAI"):SetValue(Transform(nAHistVR3,cPictVlr))        
oSectionA:Cell("DIF_COMPRA_INTERNA"):SetValue(Transform(nAHistVR4,cPictVlr)) 
oSectionA:Cell("DIF_COMPRA_ATUAL"):SetValue(Transform(nAHistVR5,cPictVlr))
oReport:SkipLine(1)                              
oSectionA:PrintLine()
oReport:EndReport()
(cTmpQry)->(dbCloseArea())
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VldParam ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldParam() 
Local lRet := .T. 
Local aArea     := GetArea()

dDatIni  := MV_PAR01
dDatFim  := MV_PAR02
cIniPro  := MV_PAR03
cFimPro  := MV_PAR04
//Validaciones del Periodo
If  Empty(dDatIni) .And. Empty(dDatFim)
	AVISO(STR0004,STR0006,{STR0005}) 
	lRet := .F.
Elseif (!Empty(dDatIni) .And. !Empty(dDatFim) ) .OR. (!Empty(dDatIni) .And. Empty(dDatFim))
	If  dDatIni>dDatFim .OR. (!Empty(dDatIni) .And. Empty(dDatFim))
		AVISO(STR0004,STR0008,{STR0005}) 
		lRet := .F.
	Endif
Endif

//Validaciones del Produtos
If  lRet .And. ((Empty(cIniPro) .And. Empty(cFimPro)) .OR.  (!Empty(cIniPro) .And. Empty(cFimPro)) )
	AVISO(STR0004,STR0007,{STR0005}) 
	lRet := .F.
Endif 


RestArea(aArea)
Return lRet

