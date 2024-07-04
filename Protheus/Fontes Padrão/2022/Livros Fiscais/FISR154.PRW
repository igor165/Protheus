#Include "Protheus.ch"
#INCLUDE "REPORT.CH"
#Include "FISR154.ch"
//-------------------------------------------------------------------
/*/ {Protheus.doc} FISR154
Relatorio Lancamentos fiscais

@author Rafael.Soliveira
@since 04/08/2018
@version 12.17
/*/
//-------------------------------------------------------------------
Function FISR154()
Local oReport
Local lProcessa := .T.
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)


If lVerpesssen
	If !TRepInUse()
		Alert(STR0003) //"A impressão em TREPORT deverá estar habilitada. Favor verificar o parâmetro MV_TREPORT."
		lProcessa := .F.
	EndIf

	AjusteSX1() //release 12.1.17
   
	If lProcessa
		oReport:= ReportDef()
		oReport:PrintDialog()
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/ {Protheus.doc} ReportDef
Interface de impressao

@author Rafael.Soliveira
@since 04/08/2018
@version 12.17
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oReport
Local oEmpr
Local oBreak
Local oSection
Local oSection1
Local cAlias := GetNextAlias()
Local cCGC := ""
Local cTpFrete := ""
Local lSF2frt	:= SF2->(FieldPos("F2_FRTCFOP")) > 0

oReport:= TReport():New("FISR154",STR0001,"FISR154",{|oReport| ReportPrint(oReport,cAlias,lSF2frt)},STR0002,.T.)
oReport:lHeaderVisible := .T.
oReport:HideParamPage()
oReport:lDisableOrientation := .T.
oReport:SetLandscape()

//Carrega SX1
Pergunte(oReport:uParam,.F.)

oEmpr:= TRSection():New(oReport,"Filiais",{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/,,,,.T.)
oEmpr:SetReadOnly()
oEmpr:SetNoFilter("SM0")

oSection1:= TRSection():New(oEmpr,"Notas Fiscais",{cAlias,"SA1","SA4","SF3","SF2"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection1:SetAutoSize(.T.)
oSection1:SetCellBorder(1,1,,.T.)   //cabecalho superior
oSection1:SetCellBorder(4,1,,.T.)	//cabecalho Direita
//oSection1:SetCellBorder(4,1,,.F.)	//Bordas a Direitas campos

TRCell():New(oSection1,"F3_FILIAL"	,"SF3","Filial",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F3_EMISSAO"	,"SF3",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F3_NFISCAL"	,"SF3","NF Fiscal"/*Title*/,/*Picture*/,TAMSX3("F3_NFISCAL")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F3_SERIE"	,"SF3",/*Title*/,/*Picture*/,3/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"A1_CGC"  	,"SA1","CNPJ/CPF Cliente"/*Title*/,''/*Picture*/,20/*Tamanho*/,/*lPixel*/,{|| Iif(Len(AllTrim((cAlias)->A1_CGC)) > 11,Transform((cAlias)->A1_CGC,"@R 99.999.999/9999-99"),Transform((cAlias)->A1_CGC,"@R 999.999.999-99")) })
TRCell():New(oSection1,"A1_NREDUZ"  ,"SA1","Nome Cliente"/*Title*/,/*Picture*/,TAMSX3("A1_NREDUZ")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F2_TPFRETE"	,"SF2","Tp. Frete",/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| TPFRETE((cAlias)->F2_TPFRETE) })
TRCell():New(oSection1,"TIPCGC"		,"SA4",'CGC Transp'/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{||  Iif(Len(AllTrim((cAlias)->A4_CGC)) > 11,"CNPJ","CPF") })
TRCell():New(oSection1,"A4_CGC"  	,"SA4","CNPJ/CPF Transp"/*Title*/,''/*Picture*/,20/*Tamanho*/,/*lPixel*/,{|| Iif(Len(AllTrim((cAlias)->A4_CGC)) > 11,Transform((cAlias)->A4_CGC,"@R 99.999.999/9999-99"),Transform((cAlias)->A4_CGC,"@R 999.999.999-99"))})
TRCell():New(oSection1,"A4_NREDUZ"  ,"SA4","Nome Transp"/*Title*/,/*Picture*/,TAMSX3("A4_NREDUZ")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F2_FRETE" 	,"SF2",/*Title*/,/*Picture*/,TAMSX3("F2_FRETE")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F3_ICMAUTO" ,"SF3",'A'/*Title*/,/*Picture*/,TAMSX3("F3_ICMAUTO")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F3_VALTST" 	,"SF3",'B'/*Title*/,/*Picture*/,TAMSX3("F3_VALTST")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F2_FRETAUT" ,"SF2",'Base de Cálculo'/*Title*/,/*Picture*/,TAMSX3("F2_FRETAUT")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New(oSection1,"F3_BASETST" ,"SF3",/*Title*/,/*Picture*/,TAMSX3("F3_BASETST")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
If lSF2frt
	TRCell():New(oSection1,"F2_FRTCFOP" ,"SF2",'CFOP Frete'/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
Endif

//Alinhamento Celulas
oSection1:Cell("F3_FILIAL"):nAlign := 2
oSection1:Cell("F3_EMISSAO"):nAlign := 2
oSection1:Cell("F3_NFISCAL"):nAlign := 2
oSection1:Cell("F3_SERIE"):nAlign := 2
oSection1:Cell("TIPCGC"):nAlign := 2
oSection1:Cell("F2_TPFRETE"):nAlign := 2

If lSF2frt
	oSection1:Cell("F2_FRTCFOP"):nAlign := 2
Endif

//Alinhamento Cabecalho
oSection1:Cell("F3_FILIAL"):nHeaderAlign := 2
oSection1:Cell("F3_EMISSAO"):nHeaderAlign := 2
oSection1:Cell("F3_NFISCAL"):nHeaderAlign := 2
oSection1:Cell("F3_SERIE"):nHeaderAlign := 2
oSection1:Cell("TIPCGC"):nHeaderAlign := 2
oSection1:Cell("A1_CGC"):nHeaderAlign := 2
oSection1:Cell("A1_NREDUZ"):nHeaderAlign := 2
oSection1:Cell("F2_TPFRETE"):nHeaderAlign := 2
oSection1:Cell("A4_CGC"):nHeaderAlign := 2
oSection1:Cell("A4_NREDUZ"):nHeaderAlign := 2
oSection1:Cell("F3_ICMAUTO"):nHeaderAlign := 2
oSection1:Cell("F3_VALTST"):nHeaderAlign := 2
If lSF2frt
	oSection1:Cell("F2_FRTCFOP"):nHeaderAlign := 2
Endif


oBreak := TRBreak():New(oSection1,'',STR0004,.F.,STR0004,.T.) //"Totalizadores do Relatório
TRFunction():New(oSection1:Cell("F2_FRETE"),NIL,"SUM",oBreak,  'Valor do Frete:            ',"999,999,999.99",,.F.,.F.,.F.)
TRFunction():New(oSection1:Cell("F2_FRETAUT"),NIL,"SUM",oBreak,'Credito ICMS:              ',"999,999,999.99",,.F.,.F.,.F.)
TRFunction():New(oSection1:Cell("F3_ICMAUTO"),NIL,"SUM",oBreak,'ICMS sobre frete autonomo: ',"999,999,999.99",,.F.,.F.,.F.)
TRFunction():New(oSection1:Cell("F3_VALTST"),NIL,"SUM",oBreak, 'Valor ICMS ST transporte:  ',"999,999,999.99",,.F.,.F.,.F.)
//TRFunction():New(oSection1:Cell("F3_BASETST"),NIL,"SUM",oBreak,'Base ICMS ST transporte:   ',"999,999,999.99",,.F.,.F.,.F.)

Return(oReport)

//-------------------------------------------------------------------
/*/ {Protheus.doc} ReportPrint
Impressao do relatorio

@author Rafael.Soliveira
@since 04/08/2018
@version 12.17
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAlias,lSF2frt)
Local oEmpr     := oReport:Section(1)
Local oCodL     := oEmpr:Section(1)
Local oTFont    := TFont():New('Arial',,11,,.T.)
Local oTFont2    := TFont():New('Arial',,11,,)
Local cFilBak   := cFilAnt
Local aFilsCalc := {}
Local nForFilial:= 0
Local cWhere	:= ""
Local cSelect	:= ""
Local aAreaSM0  := SM0->(GetArea())

cSelect := "SF3.F3_FILIAL,SF3.F3_EMISSAO,SF3.F3_NFISCAL,SF3.F3_SERIE,SF3.F3_CLIEFOR,SF3.F3_LOJA, SF3.F3_BASETST,SF3.F3_VALTST,SF3.F3_ICMAUTO,"
cSelect += "SF2.F2_FRTCFOP, SF2.F2_TRANSP,SF2.F2_FRETAUT,SF2.F2_ICMAUTO,SF2.F2_VALTST,SF2.F2_TPFRETE,SF2.F2_BASETST,SF2.F2_FRETE,"
If lSF2frt
	cSelect += "F2_FRTCFOP,"
Endif
cSelect +="SA1.A1_COD, SA1.A1_NOME, SA1.A1_CGC,SA1.A1_NREDUZ,"
cSelect +="SA4.A4_COD, SA4.A4_NOME, SA4.A4_CGC,SA4.A4_CGC TIPCGC ,SA4.A4_TPTRANS, SA4.A4_NREDUZ"

	//-- Seleciona Filiais
	If MV_PAR07==1
		aFilsCalc := MatFilCalc(.T.)
	Else
		aFilsCalc := {{.T.,cFilAnt}}
	EndIf
	
	//-- Documento de/ate
	If !Empty(MV_PAR01+MV_PAR02)
		cWhere += "F3_NFISCAL >= '"+MV_PAR01+"' AND F3_NFISCAL <= '"+MV_PAR02+"' AND "
	EndIf

	//-- Serie de/ate
	If !Empty(MV_PAR03+MV_PAR04)
		cWhere += "F3_SERIE >= '"+MV_PAR03+"' AND F3_SERIE <= '"+MV_PAR04+"' AND "
	EndIf

	//-- Seleciona Livro
	If MV_PAR08 <> "*"
		cWhere += "F3_NRLIVRO = '" +MV_PAR08+"' AND "
	EndIf	
	
	cSelect := '%'+cSelect+'%'
	cWhere := '%'+cWhere+'%'	

	For nForFilial := 1 To Len(aFilsCalc)

		If aFilsCalc[ nForFilial, 1 ]
			cFilAnt := aFilsCalc[ nForFilial, 2 ]
            SM0->( DbSetOrder(1) )
			SM0->( DbSeek( cEmpAnt + cFilAnt ) )
			
			MakeSqlExpr(oReport:uParam)
			
			oCodL:BeginQuery()

			BeginSql Alias cAlias
				COLUMN F3_EMISSAO AS DATE
				
				SELECT
				%Exp:cSelect%
							/*SELECT SF3.F3_FILIAL,SF3.F3_EMISSAO,SF3.F3_NFISCAL,SF3.F3_SERIE,SF3.F3_CLIEFOR,SF3.F3_LOJA, SF3.F3_BASETST,SF3.F3_VALTST,SF3.F3_ICMAUTO,;
							SF2.F2_FRTCFOP, SF2.F2_TRANSP,SF2.F2_FRETAUT,SF2.F2_ICMAUTO,SF2.F2_VALTST,SF2.F2_TPFRETE,SF2.F2_BASETST,;
							SA1.A1_COD, SA1.A1_NOME, SA1.A1_CGC,SA1.A1_NREDUZ,;
							SA4.A4_COD, SA4.A4_NOME, SA4.A4_CGC,SA4.A4_CGC TIPCGC ,SA4.A4_TPTRANS, SA4.A4_NREDUZ*/
				FROM %table:SF3% SF3
				INNER JOIN %table:SF2% SF2
				ON    F2_FILIAL			= %xFilial:SF2% AND
					  SF2.F2_DOC		= SF3.F3_NFISCAL	AND
					  SF2.F2_SERIE		= SF3.F3_SERIE  	AND
					  SF2.F2_CLIENTE 	= SF3.F3_CLIEFOR 	AND
					  SF2.F2_LOJA		= SF3.F3_LOJA   	AND					  
					  SF2.%NotDel%
					  
				INNER JOIN %table:SA4% SA4
				ON    SA4.A4_FILIAL = %xFilial:SA4% AND
					  SA4.A4_COD    = SF2.F2_TRANSP AND					  
					  SA4.%NotDel%

				INNER JOIN %table:SA1% SA1
				ON    SA1.A1_FILIAL = %xFilial:SA1% AND
					  SA1.A1_COD     = SF3.F3_CLIEFOR AND
					  SA1.A1_LOJA    = SF3.F3_LOJA	  AND
					  SA1.%NotDel%

				WHERE SF3.F3_FILIAL = %xFilial:SF3%
					  AND SF3.F3_ENTRADA >= %Exp:mv_par05%
					  AND SF3.F3_ENTRADA <= %Exp:mv_par06%
					  AND %Exp:cWhere%
					  SF3.F3_CFO >= '5'
					  AND SF3.F3_TIPO NOT IN ('D','B')
					  AND (SF3.F3_ICMAUTO > 0 Or SF3.F3_VALTST > 0)
					  AND SF3.F3_DTCANC = ''
					  AND SF3.%NotDel%
			EndSql			

			oCodL:EndQuery()

			oEmpr:Init()
			oReport:EndPage() //Reinicia Paginas
			oReport:Say(300,20,"Razão Social: "+SM0->M0_NOMECOM,oTFont)
			oReport:Say(350,20,"Endereco: "+AllTrim(SM0->M0_ENDENT)+" Cidade: "+AllTrim(SM0->M0_CIDENT)+" - UF: "+SM0->M0_ESTENT,oTFont)
			oReport:Say(400,20,"CNPJ: "+Transform(SM0->M0_CGC,"@R 99.999.999./9999-99"),oTFont)
			oReport:Say(450,20,"Inscr. Estadual: "+SM0->M0_INSC,oTFont)

			oReport:SkipLine(10)
			oReport:FatLine()
			oReport:SkipLine(01)
			oReport:Say(600,20,"Métodos de cálculo de ICMS sobre frete:")
			oReport:Say(650,20,"A = Calculado ICMS sobre frete em que alíquota utilizada será a mesma do cálculo do ICMS na operação. Fret.Aut (F4_FRETAUT) = 1")
			oReport:Say(700,20,"B = Calculado ICMS sobre frete em que alíquota do cálculo será definida a partir do parâmetro MV_ALIQFRE. Fret.Aut (F4_FRETAUT) = 3")
			
			oEmpr:Finish()
			oReport:SkipLine(7)
			//oReport:FatLine()
			//oReport:SkipLine(01)
			oCodL:Print()
		EndIf
	Next nForFilial

cFilAnt := cFilBak
RestArea(aAreaSM0)
Return


//-------------------------------------------------------------------
/*/ {Protheus.doc} TPFRETE
Retorna tipo de  Frete

@author Rafael.Soliveira
@since 04/08/2018
@version 12.17
/*/
//-------------------------------------------------------------------
Static Function TPFRETE(cFrete)
Local aCombo := {}
Local nPos :=  0

aCombo := RetSX3Box(GetSX3Cache("C5_TPFRETE","X3_CBOX"),,,1)
/*Ele retorna um array multidimensional onde cada elemento tem 3 posições, sendo :

[1] Opção completa (ex. F=Fisica)
[2] Código da opção (ex. F)
[3] Descrição da opção (ex. Fisica)
*/

If (nPos := AScan(aCombo,{|aX| aX[2]==cFrete},/*nStart*/,/*nCount*/)) > 0
	cFrete := aCombo[nPos,3]
EndIf

Return Alltrim(cFrete)


//-------------------------------------------------------------------
/*/ {Protheus.doc} AjusteSX1
Função para atualização do dicionário de perguntas SX1.
O rrr, indica o número do release à que se refere. Ex.: EngSX1114 (Release 12.1.14), EngSX1116 (Release 12.1.16), etc.
Esta função tem funcionamento similar a PUTSX1()

Sintaxe:
/*
EngSX1rrr( <cGrupo>, <cOrdem>, <cPergunt>, <cPerSpa>, <cPerEng>, <cVar>, <cTipo>, <nTamanho>, <nDecimal>, <nPresel>, <cGSC>,;
 <cValid>, <cF3>, <cGrpSxg>, <cPyme>, <cVar01>, <cDef01>, <cDefSpa1>, <cDefEng1>, <cCnt01>, <cDef02>, <cDefSpa2>, <cDefEng2>,;
 <cDef03>, <cDefSpa3>, <cDefEng3>, <cDef04>, <cDefSpa4>, <cDefEng4>, <cDef05>, <cDefSpa5>, <cDefEng5>, <aHelpPor>, <aHelpEng>, <aHelpSpa>, <cHelp> )


@author Rafael.Soliveira
@since 04/08/2018
@version 12.17
/*/
//-------------------------------------------------------------------
Static Function AjusteSX1()
Local aHelpPor := {}

/*
EngSX1rrr( <cGrupo>, <cOrdem>, <cPergunt>, <cPerSpa>, <cPerEng>, <cVar>, <cTipo>, <nTamanho>, <nDecimal>, <nPresel>, <cGSC>,;
 <cValid>, <cF3>, <cGrpSxg>, <cPyme>, <cVar01>, <cDef01>, <cDefSpa1>, <cDefEng1>, <cCnt01>, <cDef02>, <cDefSpa2>, <cDefEng2>,;
 <cDef03>, <cDefSpa3>, <cDefEng3>, <cDef04>, <cDefSpa4>, <cDefEng4>, <cDef05>, <cDefSpa5>, <cDefEng5>, <aHelpPor>, <aHelpEng>, <aHelpSpa>, <cHelp> )
*/


// ----- MV_PAR01 -> Documento de

If FindFunction("EngSX1117")

	aHelpPor := {}
	Aadd(aHelpPor,"Informe numero do Documento inicial ")
	Aadd(aHelpPor,"ser considerado.")
	EngSX1117("FISR154", "01", "Documento inicial ?", "Documento inicial ?", "Documento inicial ?", "mv_ch1", "C", 9, 0, 0,"G",;
	"","","","","mv_par01", "", "", "", "","", "", "",;
	"", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

	// ----- MV_PAR02 -> Documento ate
	aHelpPor := {}
	Aadd(aHelpPor,"Informe numero do Documento final ")
	Aadd(aHelpPor,"ser considerado.")
	EngSX1117("FISR154", "02", "Documento final ?", "Documento final ?", "Documento final ?", "mv_ch2", "C", 9, 0, 0,"G",;
	"","","","","mv_par02", "", "", "", "","", "", "",;
	"", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

	// ----- MV_PAR03 -> Serie de
	aHelpPor := {}
	Aadd(aHelpPor,"Informe a serie inicial do documento.")
	EngSX1117("FISR154", "03", "Serie inicial ?", "Serie inicial ?", "Serie inicial ?", "mv_ch3", "C", 3, 0, 0,"G",;
	"","","","","mv_par03", "", "", "", "","", "", "",;
	"", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

	// ----- MV_PAR04 -> Serie ate
	aHelpPor := {}
	Aadd(aHelpPor,"Informe a serie final do documento.")
	EngSX1117("FISR154", "04", "Serie final ?", "Serie final ?", "Serie final ?", "mv_ch4", "C", 3, 0, 0,"G",;
	"","","","","mv_par04", "", "", "", "","", "", "",;
	"", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)


	// ----- MV_PAR05 -> Data inicial ?
	aHelpPor := {}
	Aadd(aHelpPor,"Informe a data inicial para geracao do")
	Aadd(aHelpPor,"relatorio.")
	EngSX1117("FISR154", "05", "Data inicial ?", "Data inicial ?", "Data inicial ?", "mv_ch5", "D", 8, 0, 0,"G",;
	"","","","","mv_par05", "", "", "", "","", "", "",;
	"", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

	// ----- MV_PAR06 -> Data final ?
	aHelpPor := {}
	Aadd(aHelpPor,"Informe a data final para geracao do")
	Aadd(aHelpPor,"relatorio.")
	EngSX1117("FISR154", "06", "Data final ?", "Data final ?", "Data final ?", "mv_ch6", "D", 8, 0, 0,"G",;
	"","","","","mv_par06", "", "", "", "","", "", "",;
	"", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

	// ----- MV_PAR06 -> Data final ?
	aHelpPor := {}
	Aadd(aHelpPor,"Selecione as filiais desejadas. Se NAO")
	Aadd(aHelpPor,"apenas a filial corrente sera listada.")
	EngSX1117("FISR154", "07", "Seleciona filiais ?", "Seleciona filiais ?", "Seleciona filiais ?", "mv_ch7", "C", 1, 0, 0,"C",;
	"","","","","mv_par07", "Sim", "Si", "Yes", "","Nao", "No", "No",;
	"", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

	// ----- MV_PAR08 -> Data final ?
	aHelpPor := {}
	Aadd(aHelpPor,"Selecione o numero do livro desejado.")
	EngSX1117("FISR154", "08", "Livro selecionado ?", "Livro selecionado ?", "Livro selecionado ?", "mv_ch8", "C", 1, 0, 0,"G",;
	"","","","","mv_par08", "", "", "", "","", "", "",;
	"", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

EndIf 

return
