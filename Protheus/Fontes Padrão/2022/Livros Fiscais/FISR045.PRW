#Include "Protheus.ch"
#Include "REPORT.CH"
#Include "FISR045.CH"

STATIC cDbType := TCGetDB()

//-------------------------------------------------------------------
/*/ {Protheus.doc} FISR045
Relatorio INOVAR-AUTO

@author Flavio Luiz Vicco
@since 01/12/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Function FISR045()
Local oReport
Local lProcessa := .T.
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

If lVerpesssen
	If !TRepInUse()
		Alert(STR0001) //"A impressão em TREPORT deverá estar habilitada. Favor verificar o parâmetro MV_TREPORT."
		lProcessa := .F.
	EndIf

	If lProcessa
		oReport:= ReportDef()
		oReport:PrintDialog()
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/ {Protheus.doc} ReportDef
Interface de impressao

@author Flavio Luiz Vicco
@since 01/12/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oReport
Local oFilial
Local oSection1
Local cAlias := GetNextAlias()

oReport:= TReport():New("FISR045",STR0002,"FISR045",{|oReport| ReportPrint(oReport,cAlias)},STR0003) //"Relatorio INOVAR-AUTO"###"Este relatório tem como objetivo apoiar a conferencia dos valores gerados para o INOVAR-AUTO."
oReport:SetTotalInLine(.F.)
oReport:lHeaderVisible := .T.
oReport:HideParamPage()

Pergunte(oReport:uParam,.F.)

oFilial:= TRSection():New(oReport,"Filial",{"SM0"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/,,,,.T.)
oFilial:SetReadOnly()
oFilial:SetNoFilter("SM0")

oSection1:= TRSection():New(oReport,"Cliente",{cAlias})
oSection1:SetReadOnly()
oSection1:SetEditCell(.F.)
oSection1:SetLineStyle()

TRCell():New(oSection1,"A1_NOME"   ,"SA1",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*bBlock*/,/*cAlign*/,,,,,,,,/*lBold*/.T.)
TRCell():New(oSection1,"A1_CGC"    ,"SA1",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*bBlock*/,/*cAlign*/,,,,,,,,/*lBold*/.T.)

oSection2:= TRSection():New(oSection1,"Doc.Fiscais",{cAlias})
oSection2:SetTotalInLine(.F.)
oSection2:SetReadOnly()
oSection2:SetEditCell(.F.)

TRCell():New(oSection2,"FT_NFISCAL","SFT",/*Title*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*bBlock*/,/*cAlign*/,,,,,,,,/*lBold*/.T.)
TRCell():New(oSection2,"FT_SERIE"  ,"SFT",/*Title*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*bBlock*/,/*cAlign*/,,,,,,,,/*lBold*/.T.)
TRCell():New(oSection2,"FT_EMISSAO","SFT",/*Title*/,/*Picture*/,13,/*lPixel*/,/*bBlock*/,/*cAlign*/,,,,,,,,/*lBold*/.T.)
TRCell():New(oSection2,"FT_PRODUTO","SFT",/*Title*/,/*Picture*/,TamSX3("FT_PRODUTO")[1]+2,/*lPixel*/,/*bBlock*/,/*cAlign*/,,,,,,,,/*lBold*/.T.)
TRCell():New(oSection2,"B1_DESC"   ,"SB1",/*Title*/,/*Picture*/,TamSX3("B1_DESC")[1]+2,/*lPixel*/,/*bBlock*/,/*cAlign*/,,,,,,,,/*lBold*/.T.)
TRCell():New(oSection2,"B1_UM"     ,"SB1",/*Title*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*bBlock*/,/*cAlign*/,,,,,,,,/*lBold*/.T.)
TRCell():New(oSection2,"CLJ_PROCOM","CLJ","Origem" ,/*Picture*/,15/*Tamanho*/,/*lPixel*/,{||IIF((cAlias)->(CLJ_PROCOM)=="C","Comprado","Produzido")})
TRCell():New(oSection2,"FT_QUANT"  ,"SFT",/*Title*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*bBlock*/,/*cAlign*/,,,,,,,,/*lBold*/.T.)
TRCell():New(oSection2,"FT_VALCONT","SFT","Vlr.Tot."		  ,"@E 999,999,999.99",14/*Tamanho*/,/*lPixel*/,{||IIf(mv_par05 = 1 .And. Alltrim((cAlias)->FT_TIPO) == "Devolução",-(cAlias)->FT_VALCONT,(cAlias)->FT_VALCONT)},/*cAlign*/,,,,,,,,/*lBold*/.T.)
TRCell():New(oSection2,"CLJ_VLRVI" ,"CLJ","Vlr.Imp."      ,"@E 999,999,999.99",14/*Tamanho*/,/*lPixel*/,{||IIf(mv_par05 = 1 .And. Alltrim((cAlias)->FT_TIPO) == "Devolução",-(cAlias)->CLJ_VLRVI,(cAlias)->CLJ_VLRVI)},/*cAlign*/,,,,,,,,/*lBold*/.T.)
TRCell():New(oSection2,"CLJ_VLRTOT",     ,"Parc.Dedutivel","@E 999,999,999.99",14/*Tamanho*/,/*lPixel*/,{||IIf(mv_par05 = 1 .And. Alltrim((cAlias)->FT_TIPO) == "Devolução",-(cAlias)->CLJ_VLRTOT,(cAlias)->CLJ_VLRTOT)},/*cAlign*/,,,,,,,,/*lBold*/.T.)

TRFunction():New(oSection2:Cell("FT_VALCONT"),/*cID*/,"SUM",/*oBreak*/,/*cTitulo*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oSection2:Cell("CLJ_VLRTOT"),/*cID*/,"SUM",/*oBreak*/,/*cTitulo*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,/*lEndReport*/,/*lEndPage*/)

Return(oReport)

//-------------------------------------------------------------------
/*/ {Protheus.doc} ReportPrint
Impressao do relatorio

@author Flavio Luiz Vicco
@since 01/12/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAlias)
Local oFilial   := oReport:Section(1)
Local oSection1	:= oReport:Section(2)
Local oSection2	:= oReport:Section(2):Section(1)
Local oTFont    := TFont():New('Arial',,11,,.T.)
Local aAreaSM0  := SM0->(GetArea())
Local nForFilial:= 0
Local cFilBak   := cFilAnt
Local aFilsCalc := {}
Local cPeriod   := Substr(Alltrim(mv_par03),1,2) + Substr(Alltrim(mv_par03),3,6)
Local cMesAno   := Substr(Alltrim(mv_par03),3,6) + Substr(Alltrim(mv_par03),1,2)
Local cSelect	:= ""
Local cFuncNull	:= ""
Local nNotaDev	:= IIF(SX1->(dbSeek(PadR("FISR045",Len(SX1->X1_GRUPO))+"05")),mv_par05, 2) 

Default nNotaDev := 0 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nome da funcao do banco de dados que substitui NULL por 0³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case cDbType $ "DB2/POSTGRES"
		cFuncNull	:= "COALESCE"
	Case cDbType $ "ORACLE/INFORMIX"   
  		cFuncNull	:= "NVL"
 	Otherwise
 		cFuncNull	:= "ISNULL"
EndCase

	//-- Seleciona Filiais
	If MV_PAR04==1
		aFilsCalc := MatFilCalc(.T.)
	Else
		aFilsCalc := {{.T.,cFilAnt}}
	EndIf

	For nForFilial := 1 To Len(aFilsCalc)

		If aFilsCalc[ nForFilial, 1 ]
			cFilAnt := aFilsCalc[ nForFilial, 2 ]
            SM0->( DbSetOrder(1) )
			SM0->( DbSeek( cEmpAnt + cFilAnt ) )
			
			cSelect	:=	"%	SA1.A1_FILIAL, SA1.A1_NOME, SA1.A1_CGC, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_EMISSAO, SFT.FT_PRODUTO, SB1.B1_DESC, SB1.B1_UM, SFT.FT_QUANT, SFT.FT_VALCONT, "
			cSelect	+=	"	CASE	WHEN (SFT.FT_QUANT* "+ cFuncNull +" (CLJ.CLJ_VLRVI,0)) > 0 THEN CLJ_PROCOM "
			If cFuncNull == "ISNULL"
				cSelect	+=	"	ELSE	( SELECT TOP 1 SUB.CLJ_PROCOM FROM  "+RetSqlName("CLJ")+" SUB WHERE SUB.CLJ_COD = SFT.FT_PRODUTO AND SUB.D_E_L_E_T_ <> '*' ORDER BY SUB.CLJ_PERIOD DESC ) END AS CLJ_PROCOM, "
			Else
				cSelect	+=	"	ELSE	( SELECT CLJ_PROCOM FROM (SELECT SUB.CLJ_PROCOM,SUB.CLJ_COD FROM "+RetSqlName("CLJ")+" SUB WHERE SUB.D_E_L_E_T_ <> '*' ORDER BY SUB.CLJ_PERIOD DESC) WHERE CLJ_COD = SFT.FT_PRODUTO AND ROWNUM=1  ) END AS CLJ_PROCOM, "
			Endif
			
			cSelect	+=	"	CASE	WHEN (SFT.FT_QUANT* "+ cFuncNull +" (CLJ.CLJ_VLRVI,0)) > 0 THEN CLJ_VLRVI "
			If cFuncNull	== "ISNULL"
				cSelect	+=	"	ELSE	( SELECT TOP 1 SUB.CLJ_VLRVI FROM "+RetSqlName("CLJ")+" SUB WHERE SUB.CLJ_COD = SFT.FT_PRODUTO AND SUB.D_E_L_E_T_ <> '*' ORDER BY SUBSTRING(SUB.CLJ_PERIOD,3,4)DESC, SUBSTRING(SUB.CLJ_PERIOD,1,2)DESC) END AS CLJ_VLRVI, "
			Else
				cSelect	+=	"	ELSE	( SELECT CLJ_VLRVI FROM (SELECT SUB.CLJ_VLRVI,SUB.CLJ_COD FROM  "+RetSqlName("CLJ")+" SUB WHERE SUB.D_E_L_E_T_ <> '*' ORDER BY SUBSTR(SUB.CLJ_PERIOD,3,4)DESC, SUBSTR(SUB.CLJ_PERIOD,1,2)DESC) WHERE CLJ_COD = SFT.FT_PRODUTO AND ROWNUM = 1)  END AS CLJ_VLRVI, "	
			Endif
			cSelect	+=	"	CASE	WHEN (SFT.FT_QUANT* "+ cFuncNull +" (CLJ.CLJ_VLRVI,0)) > 0 THEN (SFT.FT_QUANT*CLJ.CLJ_VLRVI) "
			If cFuncNull	== "ISNULL"
				cSelect	+=	"	ELSE   ( SELECT TOP 1 (SFT.FT_QUANT*SUB.CLJ_VLRVI) FROM "+RetSqlName("CLJ")+" SUB WHERE SUB.CLJ_COD = SFT.FT_PRODUTO AND SUB.D_E_L_E_T_ <> '*' ORDER BY SUBSTRING(SUB.CLJ_PERIOD,3,4)DESC, SUBSTRING(SUB.CLJ_PERIOD,1,2)DESC) END AS CLJ_VLRTOT "		
			Else
				cSelect	+=	"	ELSE   ( SELECT (SFT.FT_QUANT*CLJ_VLRVI) FROM (SELECT (SFT.FT_QUANT*SUB.CLJ_VLRVI) FROM "+RetSqlName("CLJ")+" SUB,"+RetSqlName("SFT")+" SFT WHERE SUB.D_E_L_E_T_ <> '*'  ORDER BY SUBSTR(SUB.CLJ_PERIOD,3,4)DESC, SUBSTR(SUB.CLJ_PERIOD,1,2)DESC) WHERE CLJ_COD = SFT.FT_PRODUTO AND ROWNUM = 1) END AS CLJ_VLRTOT "
			Endif
			If	nNotaDev == 1					
           	cSelect	+=	"	,CASE  WHEN SFT.FT_TIPO = 'S' THEN 'Serviço' "
           	cSelect	+=	"	WHEN SFT.FT_TIPO = 'L' THEN 'Em Lote' "
           	cSelect	+=	"	WHEN SFT.FT_TIPO = '' OR SFT.FT_TIPO = 'N' THEN 'Normal' "
           	cSelect	+=	"	WHEN SFT.FT_TIPO = 'D' THEN 'Devolução' "
           	cSelect	+=	"	WHEN SFT.FT_TIPO = 'B' THEN 'Beneficiamento' "
           	cSelect	+=	"	ELSE SFT.FT_TIPO END AS FT_TIPO "
			EndIf
			cSelect	+= "%"		
			
			MakeSqlExpr(oReport:uParam)

			oSection1:BeginQuery()

			If	nNotaDev == 1
				BeginSql Alias cAlias
					SELECT %Exp:cSelect%
					FROM %table:SFT% SFT
					LEFT JOIN %table:CLJ% CLJ ON CLJ.CLJ_FILIAL = %xFilial:CLJ% AND CLJ.CLJ_COD = SFT.FT_PRODUTO AND CLJ.CLJ_PERIOD = %Exp:cPeriod% AND CLJ.%NotDel%
					JOIN %table:SB1% SB1 ON SB1.B1_FILIAL  = %xFilial:SB1% AND SB1.B1_COD  = SFT.FT_PRODUTO AND SB1.%NotDel%
					LEFT JOIN %table:SD2% SD2 ON SD2.D2_FILIAL  = %xFilial:SD2% AND SD2.D2_DOC  = SFT.FT_NFISCAL AND SD2.D2_SERIE = SFT.FT_SERIE AND SD2.D2_ITEM = SFT.FT_ITEM AND SD2.D2_CLIENTE = SFT.FT_CLIEFOR AND SD2.D2_LOJA = SFT.FT_LOJA AND SD2.%NotDel%
					LEFT JOIN %table:SD1% SD1 ON SD1.D1_FILIAL  = %xFilial:SD1% AND SD1.D1_DOC  = SFT.FT_NFISCAL AND SD1.D1_SERIE = SFT.FT_SERIE AND SD1.D1_ITEM = SFT.FT_ITEM AND SD1.D1_FORNECE = SFT.FT_CLIEFOR AND SD1.D1_LOJA = SFT.FT_LOJA AND SD1.%NotDel%
					JOIN %table:SF4% SF4 ON SF4.F4_FILIAL  = %xFilial:SF4% AND (SF4.F4_CODIGO = SD2.D2_TES OR SF4.F4_CODIGO = SD1.D1_TES) AND SF4.F4_INOVAUT = '1' AND SF4.%NotDel%
					JOIN %table:SA1% SA1 ON SA1.A1_FILIAL  = %xFilial:SA1% AND SA1.A1_COD  = SFT.FT_CLIEFOR AND SA1.A1_LOJA = SFT.FT_LOJA AND SA1.%NotDel% AND SA1.A1_INOVAUT = '1'					
					WHERE SFT.FT_FILIAL = %xFilial:SFT% AND
					SUBSTRING( SFT.FT_ENTRADA, 1 , 6 )  = %Exp:cMesAno% AND
					(SUBSTRING( SFT.FT_CFOP   , 1 , 1 ) >= "5" OR SFT.FT_TIPO = 'D') AND SFT.FT_DTCANC = " " AND
					SFT.FT_PRODUTO >= %Exp:MV_PAR01% AND SFT.FT_PRODUTO <= %Exp:MV_PAR02% AND
					SFT.%NotDel%
					GROUP BY SA1.A1_FILIAL, SA1.A1_NOME, SA1.A1_CGC, SFT.FT_NFISCAL, SFT.FT_SERIE,
         					  SFT.FT_EMISSAO, SFT.FT_PRODUTO, SB1.B1_DESC, SB1.B1_UM, SFT.FT_QUANT,
         					  SFT.FT_VALCONT, SFT.FT_CLIEFOR, CLJ.CLJ_VLRVI, CLJ.CLJ_PROCOM, SFT.FT_TIPO

					ORDER BY SA1.A1_CGC, SFT.FT_NFISCAL , SFT.FT_SERIE , SFT.FT_PRODUTO
				EndSql
			Else
				BeginSql Alias cAlias
					SELECT %Exp:cSelect%
					FROM %table:SFT% SFT
					LEFT JOIN %table:CLJ% CLJ ON CLJ.CLJ_FILIAL = %xFilial:CLJ% AND CLJ.CLJ_COD = SFT.FT_PRODUTO AND CLJ.CLJ_PERIOD = %Exp:cPeriod% AND CLJ.%NotDel%
					JOIN %table:SB1% SB1 ON SB1.B1_FILIAL  = %xFilial:SB1% AND SB1.B1_COD  = SFT.FT_PRODUTO AND SB1.%NotDel%
					JOIN %table:SD2% SD2 ON SD2.D2_FILIAL  = %xFilial:SD2% AND SD2.D2_DOC  = SFT.FT_NFISCAL AND SD2.D2_SERIE = SFT.FT_SERIE AND SD2.D2_ITEM = SFT.FT_ITEM AND SD2.D2_CLIENTE = SFT.FT_CLIEFOR AND SD2.D2_LOJA = SFT.FT_LOJA AND SD2.%NotDel%
					JOIN %table:SF4% SF4 ON SF4.F4_FILIAL  = %xFilial:SF4% AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_INOVAUT = '1' AND SF4.%NotDel%
					JOIN %table:SA1% SA1 ON SA1.A1_FILIAL  = %xFilial:SA1% AND SA1.A1_COD  = SFT.FT_CLIEFOR AND SA1.A1_LOJA = SFT.FT_LOJA AND SA1.%NotDel% AND SA1.A1_INOVAUT = '1'
					WHERE SFT.FT_FILIAL = %xFilial:SFT% AND
					SUBSTRING( SFT.FT_ENTRADA, 1 , 6 )  = %Exp:cMesAno% AND
					SUBSTRING( SFT.FT_CFOP   , 1 , 1 ) >= "5" AND SFT.FT_DTCANC = " " AND
					SFT.%NotDel%
					ORDER BY SA1.A1_CGC, SFT.FT_NFISCAL , SFT.FT_SERIE , SFT.FT_PRODUTO
				EndSql
			EndIf	

			oSection1:EndQuery()
			
			If	nNotaDev == 1
				TRCell():New(oSection2,"FT_TIPO" ,	   ,"Tipo de NF." ,/*Picture*/,  TamSX3("FT_TIPO")[1]+2,/*lPixel*/,/*bBlock*/,"CENTER"/*cAlign*/,,,,,,,,/*lBold*/.T.)
			EndIf

			oSection2:SetParentQuery()
			oSection2:SetParentFilter({ |cParam| xFilial("SA1")+A1_CGC == cParam },{ || (cAlias)->(A1_FILIAL+A1_CGC) })

			oFilial:Init()
			oReport:EndPage() //Reinicia Paginas
			oReport:Say(300,20,"Razão Social: "+SM0->M0_NOMECOM,oTFont)
			oReport:Say(350,20,"Endereco: "+AllTrim(SM0->M0_ENDENT)+" Cidade: "+AllTrim(SM0->M0_CIDENT)+" - UF: "+SM0->M0_ESTENT,oTFont)
			oReport:Say(400,20,"CNPJ: "+Transform(SM0->M0_CGC,"@R 99.999.999./9999-99"),oTFont)
			oReport:Say(450,20,"Inscr. Estadual: "+SM0->M0_INSC,oTFont)
			oReport:Say(450,1050,"Periodo: "+Substr(Alltrim(mv_par03),1,2)+"/"+Substr(Alltrim(mv_par03),3,6),oTFont)
			oFilial:Finish()
			oReport:SkipLine(10)
			oReport:FatLine()
			oReport:SkipLine(01)
			oSection1:Print()
		EndIf

	Next nForFilial

cFilAnt := cFilBak
RestArea(aAreaSM0)

Return
