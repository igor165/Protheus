#Include "Protheus.ch"
#INCLUDE "REPORT.CH"
#Include "FISR025.ch"
//-------------------------------------------------------------------
/*/ {Protheus.doc} FISR025
Relatorio Lancamentos fiscais

@author Flavio Luiz Vicco
@since 15/10/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Function FISR025()
Local oReport
Local lProcessa := .T.

If !TRepInUse()
	Alert(STR0001) //"A impressão em TREPORT deverá estar habilitada. Favor verificar o parâmetro MV_TREPORT."
	lProcessa := .F.
EndIf

If lProcessa
	oReport:= ReportDef()
	oReport:PrintDialog()
EndIf

Return

//-------------------------------------------------------------------
/*/ {Protheus.doc} ReportDef
Interface de impressao

@author Flavio Luiz Vicco
@since 15/10/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oReport
Local oEmpr
Local oCodL
Local oLanc
Local oBreak
Local cAliasCDA := GetNextAlias()

oReport:= TReport():New("FISR025",STR0002,"FISR025",{|oReport| ReportPrint(oReport,cAliasCDA)},STR0003) //"Relação de Lançamentos Fiscais"###"Este relatório tem como objetivo apresentar os lançamentos fiscais de apuração de ICMS."
oReport:SetTotalInLine(.F.)
oReport:lHeaderVisible := .T.
oReport:HideParamPage()
//oReport:DisableOrientation()

Pergunte(oReport:uParam,.F.)

oEmpr:= TRSection():New(oReport,"Filiais",{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/,,,,.T.)
oEmpr:SetReadOnly()
oEmpr:SetNoFilter("SM0")

oCodL:= TRSection():New(oReport,"Código de Lancamento",{cAliasCDA,"CDA"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oCodL,"CDA_CODLAN","CDA",/*Title*/            ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New(oCodL,"cDescLan"  ,     ,/*Title*/            ,/*Picture*/,30         ,/*lPixel*/,{|| IIF((cAliasCDA)->CDA_TPLANC=="1",(cAliasCDA)->CDO_DESCR,(cAliasCDA)->CC6_DESCR)})
TRCell():New(oCodL,"cDescLan"  ,     ,/*Title*/            ,/*Picture*/,120         ,/*lPixel*/,{|| IIF((cAliasCDA)->CDA_TPLANC=="1",MSMM((cAliasCDA)->CDO_DESCR2),MSMM((cAliasCDA)->CC6_DESCR2))})	

oLanc:= TRSection():New(oCodL,"Notas Fiscais",{cAliasCDA,"CDA"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oLanc,"CDA_NUMERO","CDA","Num. Doc.",/*Picture*/,TamSx3("D2_DOC")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLanc,"CDA_SERIE" ,"CDA","Serie",/*Picture*/,TamSx3("D2_SERIE")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLanc,"CDA_CLIFOR","CDA","Código",/*Picture*/,TamSx3("A1_COD")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLanc,"CDA_LOJA"  ,"CDA","Loja",/*Picture*/,TamSx3("A1_LOJA")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New(oLanc,"CNOME"     ,     ,RetTitle("A1_NREDUZ"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| IIF((cAliasCDA)->CDA_TPMOVI=="E",Posicione("SA2",1,xFilial("SA2")+(cAliasCDA)->(CDA_CLIFOR+CDA_LOJA),"A2_NREDUZ"),Posicione("SA1",1,xFilial("SA1")+(cAliasCDA)->(CDA_CLIFOR+CDA_LOJA),"A1_NREDUZ"))})

TRCell():New(oLanc,"CDA_NUMITE","CDA",RetTitle("D2_ITEM"  ),/*Picture*/,TamSx3("D2_ITEM")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLanc,"B1_COD"    ,"SB1",RetTitle("D2_COD"   ),/*Picture*/,TamSx3("D2_COD")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New(oLanc,"B1_DESC"   ,"SB1",RetTitle("B1_DESC"  ),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New(oLanc,"CDA_TPLANC","CDA",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New(oLanc,"CDA_TPREG" ,"CDA",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLanc,"CDA_BASE"  ,"CDA",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLanc,"CDA_ALIQ"  ,"CDA",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLanc,"CDA_VALOR" ,"CDA",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLanc,"CDA_TPMOVI","CDA","Tp. Mov."/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLanc,"CDA_ESPECI","CDA","Especie"/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLanc,"FT_EMISSAO","SFT","Emissao"/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oBreak := TRBreak():New(oCodL,oCodL:Cell("CDA_CODLAN"),"Código de Lançamentos",.T.,'Código de Lançamentos',.F.)
TRFunction():New(oLanc:Cell("CDA_VALOR"),Nil,"SUM",/*oBreak2*/,"Valor Total ","999,999,999.99",/*uFormula*/,.T.,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/) // "Total de documentos importados sem erro: "

Return(oReport)

//-------------------------------------------------------------------
/*/ {Protheus.doc} ReportPrint
Impressao do relatorio

@author Flavio Luiz Vicco
@since 15/10/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasCDA)
Local oEmpr     := oReport:Section(1)
Local oCodL     := oReport:Section(2)
Local oLanc     := oReport:Section(2):Section(1)
Local oTFont    := TFont():New('Arial',,11,,.T.)
Local cFilBak   := cFilAnt
Local aFilsCalc := {}
Local nForFilial:= 0
Local cWhere1   := "%"
Local cWhere2   := "%%"
Local aAreaSM0  := SM0->(GetArea())

	//-- Seleciona Filiais
	If MV_PAR05==1
		aFilsCalc := MatFilCalc(.T.)
	Else
		aFilsCalc := {{.T.,cFilAnt}}
	EndIf
	//-- Seleciona Livro
	If MV_PAR06 <> "*"
		cWhere1 += "FT_NRLIVRO = '" +%Exp:(MV_PAR06)% +"' AND%"
	EndIf
	//-- Documento de/ate
	If !Empty(MV_PAR01+MV_PAR02)
		cWhere2 := "%CDA_NUMERO >= '"+MV_PAR01+"' AND CDA_NUMERO <= '"+MV_PAR02+"' AND%"
	EndIf

	For nForFilial := 1 To Len(aFilsCalc)

		If aFilsCalc[ nForFilial, 1 ]
			cFilAnt := aFilsCalc[ nForFilial, 2 ]
            SM0->( DbSetOrder(1) )
			SM0->( DbSeek( cEmpAnt + cFilAnt ) )

			MakeSqlExpr(oReport:uParam)

			oCodL:BeginQuery()

			BeginSql Alias cAliasCDA
				SELECT CDA.*, SB1.B1_COD, SB1.B1_DESC, CDO.CDO_DESCR,CDO.CDO_DESCR2, CC6.CC6_DESCR,CC6.CC6_DESCR2, SFT.FT_EMISSAO

				FROM %table:CDA% CDA

				INNER JOIN %table:SFT% SFT
				ON    FT_FILIAL   = %xFilial:SFT% AND
					  FT_NFISCAL  = CDA_NUMERO AND
					  FT_SERIE    = CDA_SERIE  AND
					  FT_CLIEFOR  = CDA_CLIFOR AND
					  FT_LOJA     = CDA_LOJA   AND
					  FT_ITEM     = CDA_NUMITE AND
					  FT_TIPOMOV  = CDA_TPMOVI AND
					  FT_ENTRADA >= %Exp:mv_par03% AND
					  FT_ENTRADA <= %Exp:mv_par04% AND
					  %Exp:cWhere1%
					  SFT.%NotDel%

				LEFT JOIN %table:CC6% CC6
				ON    CC6_FILIAL = %xFilial:CC6%  AND
					  CC6_CODLAN = CDA.CDA_CODLAN AND
					  CC6.%NotDel%

				LEFT JOIN %table:CDO% CDO
				ON    CDO_FILIAL = %xFilial:CDO%  AND
					  CDO_CODAJU = CDA.CDA_CODLAN AND
					  CDO.%NotDel%

				INNER JOIN %table:SB1% SB1
				ON    B1_FILIAL = %xFilial:SB1% AND
					  B1_COD    = FT_PRODUTO AND
					  SB1.%NotDel%

				WHERE CDA_FILIAL = %xFilial:CDA% AND
					  %Exp:cWhere2%
					  CDA.%NotDel%

				ORDER BY
					  CDA_FILIAL,CDA_CODLAN,CDA_NUMERO,CDA_SERIE,CDA_CLIFOR,CDA_LOJA,CDA_NUMITE
			EndSql

			oCodL:EndQuery()

			oLanc:SetParentQuery()
			oLanc:SetParentFilter({ |cParam| /*CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA+*/CDA_CODLAN == cParam },{ || (cAliasCDA)->(/*CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA+*/CDA_CODLAN) })			

			oEmpr:Init()
			oReport:EndPage() //Reinicia Paginas
			oReport:Say(300,20,"Razão Social: "+SM0->M0_NOMECOM,oTFont)
			oReport:Say(350,20,"Endereco: "+AllTrim(SM0->M0_ENDENT)+" Cidade: "+AllTrim(SM0->M0_CIDENT)+" - UF: "+SM0->M0_ESTENT,oTFont)
			oReport:Say(400,20,"CNPJ: "+Transform(SM0->M0_CGC,"@R 99.999.999./9999-99"),oTFont)
			oReport:Say(450,20,"Inscr. Estadual: "+SM0->M0_INSC,oTFont)
			oEmpr:Finish()
			oReport:SkipLine(10)
			oReport:FatLine()
			oReport:SkipLine(01)
			oCodL:Print()
		EndIf
	Next nForFilial

cFilAnt := cFilBak
RestArea(aAreaSM0)
Return
