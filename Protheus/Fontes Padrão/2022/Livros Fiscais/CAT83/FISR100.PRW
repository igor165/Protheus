#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FWCOMMAND.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISR100

@author Erick G. Dias
@since 31/03/2015
@version 11.80

/*/
//-------------------------------------------------------------------
Function FISR100()
    
    Local oReport
    Local lProcessa := .T.
    
    If AliasIndic('CDU') .And. AliasIndic('CLP') .And. AliasIndic('CLQ') .And. ;
            AliasIndic('CLR') .And. AliasIndic('CLT') .And. AliasIndic('CLU') .And. ;
            AliasIndic('CLV') .And. AliasIndic('CLW') .And. AliasIndic('CLX') .And.;
            AliasIndic('CLZ') .And. AliasIndic('F01') .And. AliasIndic('F04')
        
        If !TRepInUse()
            Alert("A impressão em TREPORT deverá estar habilitada. Favor verificar o parâmetro MV_TREPORT.")
            lProcessa := .F.
        EndIf
        
        If lProcessa
            oReport:=ReportDef()
            oReport:PrintDialog()
        EndIf
        
    Else
        Alert('Dicionário está desatualizado, por favor verifique atualização das tabelas')
    EndIF
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

@return Nil

@author Erick Dias
@since  31/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oReport
Local oRelat
Local oCabec
Local oDetal
Local oResum
Local oBreak1
Local oBreak2
Local oBreak3
Local oBreak4
Local oBreak5
Local oBreak6
Local cAliasQry := GetNextAlias()
Local cFilter   := ""
Local nI        := 0
Local aFields   := { }

oReport:=TReport():New("FISR100","CAT83 - Relatório de Conferência de Apuração","FISR100", {|oReport| ReportPrint(oReport,cAliasQry)},'CAT83 - Relatório de Conferência de Apuração')
oReport:SetLandscape()

If !Isblind()
	Pergunte(oReport:uParam,.T.)
EndIF

//-- Relatorio Sintetico
oRelat:=TRSection():New(oReport,"Relatório Sintético") 
oRelat:SetHeaderSection(.T.)

TRCell():New(oRelat,"DESCRICAO"	,"CAT83",'Ficha - Hipótese de Geração',,150) //"Descrição da Ficha"
TRCell():New(oRelat,"VALOR"		,"CAT83",'Valor Total',"@E 99,999,999,999.99",14) //"Valor Total da Ficha"

oBreak1:= TRBreak():New(oRelat,"","TOTAL GERAL",.F.,,.T.)
TRFunction():New(oRelat:Cell("VALOR"),NIL,"SUM",oBreak1,,,,.F.,.F.)
oRelat:SetHeaderSection(.T.) //Define se imprime cabecalho das celulas na quebra de secao
oReport:Section(1):SetHeaderPage(.T.) //Define se salta a pagina na quebra de secao

//-- Relatorio Analitico
oCabec:=TRSection():New(oReport,"Cabecalho - Analitico",{"F04"})
oCabec:SetHeaderBreak(.T.) //Define se imprime cabecalho das celulas apos uma quebra (TRBreak)
oCabec:SetHeaderSection(.T.) //Define se imprime cabecalho das celulas na quebra de secao
oCabec:SetPageBreak(.T.) //Define se salta a pagina na quebra de secao
oCabec:SetLineStyle()
oCabec:SetCols(1)
TRCell():New(oCabec,"F04_PERIOD","F04",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oCabec,"F04_ID"    ,"F04",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oCabec,"F04_PROD"  ,"F04",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oCabec,"B1_DESC"   ,"SB1",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,  {|| Posicione("SB1",1,xFilial("SB1")+(cAliasQry)->F04_PROD,"B1_DESC")})
TRCell():New(oCabec,"F04_FICHA" ,"F04",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,  {|| Left((cAliasQry)->F04_FICHA,1)+Chr(Val(Right((cAliasQry)->F04_FICHA,1))+64)})
//oCabec:Cell("F04_ID"):Hide()

//TRSection():New(oParent,cTitle,uTable,aOrder,lLoadCells,lLoadOrder,uTotalText,lTotalInLine,lHeaderPage,lHeaderBreak,lPageBreak,lLineBreak,nLeftMargin,lLineStyle,nColSpace,lAutoSize,cCharSeparator,nLinesBefore,nCols,nClrBack,nClrFore,nPercentage)
oDetal:=TRSection():New(oCabec,"Detalhe - Analitico",{"CLR","CLQ"},/*aOrdem*/,/*lLoadCells*/,/*lLoadOrder*/,,,,,,,,,,.T./*lAutoSize*/)
oDetal:SetTotalInLine(.F.)
oDetal:SetLineStyle(.F.)
oBreak2:= TRBreak():New(oDetal,{||oCabec:Cell("F04_ID"):uPrint},,.F.)
//-- Preenche celulas para impressao
aFields:=MontaR4("CLR","CLR_PROD|CLR_FICHA|CLR_PERIOD|CLR_ID")
//aFields:=MontaR4("CLS","CLS_PERIOD|CLS_ID|CLS_NRLAN|CLS_NRORD|CLS_FICHA",aFields)
aFields:=MontaR4("CLQ","",aFields)
oDetal:LoadCells(, aFields)
For nI := 1 to Len(aFields)
	If	ValType(oDetal:Cell(aFields[nI])) <> "U"
		oDetal:Cell(aFields[nI]):SetCellBreak()
	EndIf
Next nI

//-- Relatorio Resumo
oResum:=TRSection():New(oReport,"Resumo",{"F04"})
oResum:SetTotalInLine(.F.)
oResum:SetLineStyle(.F.)
oResum:SetPageBreak(.T.)
TRCell():New(oResum,"F04_FICHA" ,"F04",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,  {|| Left(F04->F04_FICHA,1)+Chr(Val(Right(F04->F04_FICHA,1))+64)})
TRCell():New(oResum,"F04_PROD"  ,"F04",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oResum,"B1_DESC"   ,"SB1",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,  {|| Posicione("SB1",1,xFilial("SB1")+F04->F04_PROD,"B1_DESC")})
TRCell():New(oResum,"F04_STATUS","F04",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oResum,"F04_OBSER" ,"F04",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPadminixel*/,/*{|| code-block de impressao }*/)
cFilter:= ""
cFilter:= AddcFilter(cFilter,"F04->F04_FILIAL = '"+xFilial("F04")+"'")
cFilter:= AddcFilter(cFilter,"DToS(F04->F04_PERIOD) >= '"+DToS(MV_PAR01)+"'")
cFilter:= AddcFilter(cFilter,"DToS(F04->F04_PERIOD) <= '"+DToS(MV_PAR02)+"'")
oResum:SetFilter(cFilter)

//-- 5A - Ficha Tecnica Unitaria da Producao do Periodo
oFic5A:=TRSection():New(oReport,"Ficha 5A",{"CLU"})
oFic5A:SetTotalInLine(.F.)
oFic5A:SetLineStyle(.F.)
oFic5A:SetHeaderBreak(.T.) //Define se imprime cabecalho das celulas apos uma quebra (TRBreak)
oFic5A:SetHeaderSection(.T.) //Define se imprime cabecalho das celulas na quebra de secao
oFic5A:SetPageBreak(.T.) //Define se salta a pagina na quebra de secao
cFilter:= ""
cFilter:= AddcFilter(cFilter,"CLU->CLU_FILIAL = '"+xFilial("CLU")+"'")
cFilter:= AddcFilter(cFilter,"DToS(CLU->CLU_PERIOD) >= '"+DToS(MV_PAR01)+"'")
cFilter:= AddcFilter(cFilter,"DToS(CLU->CLU_PERIOD) <= '"+DToS(MV_PAR02)+"'")
oFic5A:SetFilter(cFilter)
oBreak3:= TRBreak():New(oFic5A,{||CLU->CLU_PROD},,.F.)
//-- Preenche celulas para impressao
aFields:=MontaR4("CLU")
oFic5A:LoadCells(, aFields)
For nI := 1 to Len(aFields)
	If	ValType(oFic5A:Cell(aFields[nI])) <> "U"
		oFic5A:Cell(aFields[nI]):SetCellBreak()
	EndIf
Next

//-- 5G - Inventario de Produtos em Elaboracao por Material Componente
oFic5G:=TRSection():New(oReport,"Ficha 5G",{"CLV"})
oFic5G:SetTotalInLine(.F.)
oFic5G:SetLineStyle(.F.)
oFic5G:SetHeaderBreak(.T.) //Define se imprime cabecalho das celulas apos uma quebra (TRBreak)
oFic5G:SetHeaderSection(.T.) //Define se imprime cabecalho das celulas na quebra de secao
oFic5G:SetPageBreak(.T.) //Define se salta a pagina na quebra de secao
cFilter:= ""
cFilter:= AddcFilter(cFilter,"CLV->CLV_FILIAL = '"+xFilial("CLV")+"'")
cFilter:= AddcFilter(cFilter,"DToS(CLV->CLV_PERIOD) >= '"+DToS(MV_PAR01)+"'")
cFilter:= AddcFilter(cFilter,"DToS(CLV->CLV_PERIOD) <= '"+DToS(MV_PAR02)+"'")
oFic5G:SetFilter(cFilter)
oBreak4:= TRBreak():New(oFic5G,{||CLV->CLV_PROD},,.F.)
//-- Preenche celulas para impressao
aFields:=MontaR4("CLV")
oFic5G:LoadCells(, aFields)
For nI := 1 to Len(aFields)
	If	ValType(oFic5G:Cell(aFields[nI])) <> "U"
		oFic5G:Cell(aFields[nI]):SetCellBreak()
	EndIf
Next

//-- 5H - Dados da Exportacao Indireta Comprovada
oFic5H:=TRSection():New(oReport,"Ficha 5H",{"CLW"})
oFic5H:SetTotalInLine(.F.)
oFic5H:SetLineStyle(.F.)
oFic5H:SetHeaderBreak(.T.) //Define se imprime cabecalho das celulas apos uma quebra (TRBreak)
oFic5H:SetHeaderSection(.T.) //Define se imprime cabecalho das celulas na quebra de secao
oFic5H:SetPageBreak(.T.) //Define se salta a pagina na quebra de secao
cFilter:= ""
cFilter:= AddcFilter(cFilter,"CLW->CLW_FILIAL = '"+xFilial("CLW")+"'")
cFilter:= AddcFilter(cFilter,"DToS(CLW->CLW_PERIOD) >= '"+DToS(MV_PAR01)+"'")
cFilter:= AddcFilter(cFilter,"DToS(CLW->CLW_PERIOD) <= '"+DToS(MV_PAR02)+"'")
oFic5H:SetFilter(cFilter)
oBreak5:= TRBreak():New(oFic5H,{||CLW->CLW_PROD},,.F.)
//-- Preenche celulas para impressao
aFields:=MontaR4("CLW")
oFic5H:LoadCells(, aFields)
For nI := 1 to Len(aFields)
	If	ValType(oFic5H:Cell(aFields[nI])) <> "U"
		oFic5H:Cell(aFields[nI]):SetCellBreak()
	EndIf
Next

//-- 4A - Rateio de Energia Eletrica
//-- 4B - Apuração do Indice de Alocação de Custo e ICMS do Insumo...
//-- 4C - Rateio Gastos Gerais de Fabricacao
oFic4x:=TRSection():New(oReport,"Ficha 4A/4B/4C",{"CLT"})
oFic4x:SetTotalInLine(.F.)
oFic4x:SetLineStyle(.F.)
oFic4x:SetHeaderBreak(.T.) //Define se imprime cabecalho das celulas apos uma quebra (TRBreak)
oFic4x:SetHeaderSection(.T.) //Define se imprime cabecalho das celulas na quebra de secao
oFic4x:SetPageBreak(.T.) //Define se salta a pagina na quebra de secao
cFilter:= ""
cFilter:= AddcFilter(cFilter,"CLT->CLT_FILIAL = '"+xFilial("CLT")+"'")
cFilter:= AddcFilter(cFilter,"DToS(CLT->CLT_PERIOD) >= '"+DToS(MV_PAR01)+"'")
cFilter:= AddcFilter(cFilter,"DToS(CLT->CLT_PERIOD) <= '"+DToS(MV_PAR02)+"'")
oFic4x:SetFilter(cFilter)
oBreak6:= TRBreak():New(oFic4x,{||CLT->CLT_FICHA+CLT->CLT_PRDDST},,.F.)
//-- Preenche celulas para impressao
aFields:=MontaR4("CLT")
oFic4x:LoadCells(, aFields)
For nI := 1 to Len(aFields)
	If	ValType(oFic4x:Cell(aFields[nI])) <> "U"
		oFic4x:Cell(aFields[nI]):SetCellBreak()
	EndIf
Next

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

@param oReport -> Objeto TREPORT

@return Nil

@author Erick Dias
@since  31/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasQry)

Local oRelat := oReport:Section(1)
Local oCabec := oReport:Section(2)
Local oDetal := oReport:Section(2):Section(1)
Local oResum := oReport:Section(3)
Local oFic5A := oReport:Section(4)
Local oFic5G := oReport:Section(5)
Local oFic5H := oReport:Section(6)
Local oFic4x := oReport:Section(7)

Local cFilBak   := cFilAnt
Local aFilsCalc := {}
Local nForFilial:= 0
Local aAreaSM0  := SM0->(GetArea())

Private cArqRel := ""

//-- Seleciona Filiais
//If MV_PAR03==1
	//aFilsCalc := MatFilCalc(.T.) 
//Else
	aFilsCalc := {{.T.,cFilAnt}}
//EndIf

For nForFilial := 1 To Len(aFilsCalc)
	If aFilsCalc[ nForFilial, 1 ]
		cFilAnt := aFilsCalc[ nForFilial, 2 ]
		SM0->(DbSetOrder(1))
		SM0->(DbSeek(cEmpAnt + cFilAnt))

		If MV_PAR03 == 1
			//-- Sintetico
			oReport:SetTitle("Relatório Sintético")
			SelRelR100(mv_par01,mv_par02, oReport, oRelat)			
			oRelat:Finish()	

		ElseIf MV_PAR03 == 2
			//-- Analitico
			oReport:SetTitle("Relatório Analitico")
			MakeSqlExpr(oReport:uParam)
			oCabec:BeginQuery()
			BeginSql Alias cAliasQry
				COLUMN F04_PERIOD AS DATE
				COLUMN CLR_PERIOD AS DATE				
				SELECT
					CLR.*, F04.*
				FROM
					%TABLE:F04% F04
				INNER JOIN %Table:CLR% CLR ON (
					CLR.CLR_FILIAL  = %xFilial:CLR% AND
					CLR.CLR_IDCAB   = F04.F04_ID AND
					CLR.CLR_PERIOD >= %Exp:mv_par01% AND
					CLR.CLR_PERIOD <= %Exp:mv_par02% AND
					CLR.%NotDel%)					
				LEFT JOIN %Table:CLQ% CLQ ON (
					CLQ.CLQ_FILIAL = %xFilial:CLQ% AND
					CLQ.CLQ_IDNF  = CLR.CLR_IDNF AND					
					CLQ.CLQ_DATA >= %Exp:mv_par01% AND
					CLQ.CLQ_DATA <= %Exp:mv_par02% AND
					CLQ.%NotDel%)
										
				WHERE
					F04.F04_FILIAL  = %xFilial:F04%  AND
					F04.F04_PERIOD >= %Exp:mv_par01% AND
					F04.F04_PERIOD <= %Exp:mv_par02% AND
					F04.%NotDel%
				ORDER BY
				F04.F04_PERIOD, F04.F04_FICHA, F04.F04_PROD, CLR.CLR_TPMOV, CLR.CLR_NRORD, CLR.CLR_NRLAN
			EndSql
			oCabec:EndQuery()
			oDetal:SetParentQuery()
			oDetal:SetParentFilter({|cParam| (cAliasQry)->CLR_IDCAB == cParam},{|| (cAliasQry)->F04_ID })
			oCabec:Print()
		ElseIf MV_PAR03 == 3
			oReport:SetTitle("Resumo")
			oResum:Print()
		ElseIf MV_PAR03 == 4
			//-- 5A - Ficha Tecnica Unitaria da Producao do Periodo
			oReport:SetTitle("5A - Ficha Tecnica Unitaria da Producao do Periodo")
			oFic5A:Print()
			oReport:EndPage()
			//-- 5G - Inventario de Produtos em Elaboracao por Material Componente
			oReport:SetTitle("Ficha 5G - Inventario de Produtos em Elaboracao por Material Componente")
			oFic5G:Print()
			oReport:EndPage()
			//-- 5H - Dados da Exportacao Indireta Comprovada
			oReport:SetTitle("5H - Dados da Exportacao Indireta Comprovada")
			oFic5H:Print()
			oReport:EndPage()
			//-- 4A - Rateio de Energia Eletrica
			//-- 4B - Apuração do Indice de Alocação de Custo e ICMS do Insumo...
			//-- 4C - Rateio Gastos Gerais de Fabricacao
			oReport:SetTitle("Fichas 4A/4B/4C")
			oFic4x:Cell("CLT_FICHA"):SetBlock({|| Left(CLT->CLT_FICHA,1)+Chr(Val(Right(CLT->CLT_FICHA,1))+64)})
			oFic4x:Print()
			oReport:EndPage()
		EndIf
	EndIf
Next nForFilial

cFilAnt := cFilBak
RestArea(aAreaSM0)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SelRelR100

@author Erick Dias
@since  31/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Function SelRelR100(mv_par01,mv_par02,oReport, oRelat)
Local objMod6  		:= MOD6XCAT83():New()
Local nX       		:= 0
Local aAreaSM0 		:= GetArea ()
Local cFicha		:= ''
Local cDescFicha	:= ''

objMod6:setDtDe(mv_par01)
objMod6:setDtAte(mv_par02)
objMod6:ProcMod6()
RestArea(aAreaSM0)

oRelat:Init()
oReport:SetTitle("Relatório Sintético CAT83")

For nX := 1 to 8
	
	//Chama função para obter a descrição e ficha 
	DescFicha(nX, @cDescFicha, @cFicha)
	
	oRelat:Cell("DESCRICAO"):SetValue(cDescFicha)
	oRelat:Cell("VALOR"):SetValue(objMod6:getValor(cFicha))						
	oRelat:PrintLine()		

Next nX

FreeObj( objMod6 )
objMod6:= Nil

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} DescFicha

Função para obter a descrição das fichas.

@author Erick Dias
@since  24/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function DescFicha(nOpc, cDescr, cFicha)

cDescr	:= ''
cFicha	:= ''

Do Case
	Case nOpc == 1
		cDescr	:= "Ficha 6A - Operações com Aplicação de Alíquotas Diversificadas"
		cFicha	:= '6A'
	Case nOpc == 2
		cDescr	:= "Ficha 6B - Operações com Redução de Base de Cálculo"
		cFicha	:= '6B'
	Case nOpc == 3
		cDescr	:= "Ficha 6C - Operações Sem Pagamento do Imposto(Exportação)"
		cFicha	:= '6C'
	Case nOpc == 4
		cDescr	:= "Ficha 6D - Operações Sem Pagamento do Imposto(Zona Franca de Manaus)"
		cFicha	:= '6D'
	Case nOpc == 5
		cDescr	:= "Ficha 6E - Operações Sem Pagamento do Imposto(Demais Casos)"
		cFicha	:= '6E'
	Case nOpc == 6
		cDescr	:= "Ficha 6F - Operações Não geradoras de Crédito Acumulado"
		cFicha	:= '6F'
	Case nOpc == 7
		cDescr	:= "Ficha 6G - Demonstrativo das Prestações de Serviço de Transporte - Crédito Outorgado"
		cFicha	:= '6G'
	Case nOpc == 8
		cDescr	:= "Ficha 6H - Demonstrativo das Prestações de Serviço de Transporte - Combustível e Redespacho"
		cFicha	:= '6H'
EndCase

Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} MontaR4

@author Flavio Luiz Vicco
@since  30/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function MontaR4(cAlias, cFields, aFields)

Default cFields := ""
Default aFields := {}

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias)
While X3_ARQUIVO == cAlias
	If X3USO(X3_USADO) .And. X3_CONTEXT <> "V" .And. !AllTrim(X3_CAMPO)$cFields
		AADD(aFields,AllTrim(X3_CAMPO))
	EndIf
	dbSkip()
EndDo

Return aFields
