#Include "Protheus.ch"
#Include "REPORT.ch"
#Include "FISR024.ch"
//-------------------------------------------------------------------
/*/ {Protheus.doc} FISR024
Relatorio FCI Sintetico

@author Flavio Luiz Vicco
@since 31/10/2014
@version 12
/*/
//-------------------------------------------------------------------
Function FISR024()
Local oReport
Local lProcessa := .T.

If !TRepInUse()
	Alert(STR0005) //"A impressão em TREPORT deverá estar habilitada. Favor verificar o parâmetro MV_TREPORT."
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
@since 31/10/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oReport
Local oEmpresa
Local oSection
Local cCmpGTIN := SuperGetMV("MV_FCIGTIN",,"B1_CODBAR")

//-- Validar conteudo parametro MV_FCIGTIN
If (Empty(cCmpGTIN) .Or. SubStr(cCmpGTIN,1,3) <> "B1_" .Or. SB1->(FieldPos(cCmpGTIN)) == 0)
	cCmpGTIN := "B1_CODBAR"
EndIf

oReport:= TReport():New("FISR024",STR0001,"FISR024",{|oReport| ReportPrint(oReport)},STR0002) //"Relação FCI Sintético (Ficha de Conteúdo de Importação)"###"Este relatório tem como objetivo apresentar os valores sintéticos calculados na apuração do FCI."
oReport:SetLandscape()
oReport:HideParamPage()
oReport:DisableOrientation()

Pergunte(oReport:uParam,.F.)

oEmpresa:= TRSection():New(oReport,STR0003,{"SM0"}) //"Informações da empresa"
oEmpresa:SetReadOnly()
oEmpresa:SetNoFilter("SM0")

oSection:= TRSection():New(oReport,STR0004,{"CFD","SB1"}) //"Ficha de Conteúdo de Importação"

TRCell():New(oSection,"CFD_COD"   ,"CFD",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"B1_DESC"   ,"SB1",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"B1_UM"     ,"SB1",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"B1_POSIPI" ,"SB1",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"CFD_PERVEN","CFD",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"CFD_PERCAL","CFD",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"CFD_VPARIM","CFD",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oSection,"CFD_VSAIIE","CFD",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oSection,"CFD_CONIMP","CFD",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oSection,cCmpGTIN    ,"SB1","GTIN"   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,  {|| SB1->(&cCmpGTIN) })

oSection:SetEdit(.T.)
oSection:SetEditCell(.T.)

Return(oReport)

//-------------------------------------------------------------------
/*/ {Protheus.doc} ReportPrint
Impressao do relatorio

@author Flavio Luiz Vicco
@since 31/10/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local oTFont    := TFont():New('Arial',,11,,.T.)
Local cAliasCFD := GetNextAlias()
Local cFilBak   := cFilAnt
Local aFilsCalc := {}
Local nForFilial:= 0
Local aAreaSM0  := SM0->(GetArea())

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

			MakeSqlExpr(oReport:uParam)

			oSection2:BeginQuery()

			BeginSql Alias cAliasCFD
				SELECT CFD.*
				FROM %table:CFD% CFD

				WHERE CFD_FILIAL = %xFilial:CFD%  AND
					  CFD_COD   >= %Exp:mv_par01% AND
					  CFD_COD   <= %Exp:mv_par02% AND
					  CFD_PERVEN = %Exp:mv_par03% AND
					  CFD.%NotDel%
			EndSql

			oSection2:EndQuery()

			//-- Tabela FCI (CFD) -> Relac Tabela Produtos (SB1)
			TRPosition():New(oSection2,"SB1",1,{|| xFilial("SB1")+(cAliasCFD)->CFD_COD})

			oSection1:Init()
			oReport:EndPage() //Reinicia Paginas
			oReport:Say(300,20,"Razão Social: "+SM0->M0_NOMECOM,oTFont)
			oReport:Say(350,20,"Endereco: "+AllTrim(SM0->M0_ENDENT)+" Cidade: "+AllTrim(SM0->M0_CIDENT)+" - UF: "+SM0->M0_ESTENT,oTFont)
			oReport:Say(400,20,"CNPJ: "+Transform(SM0->M0_CGC,"@R 99.999.999./9999-99"),oTFont)
			oReport:Say(450,20,"Inscr. Estadual: "+SM0->M0_INSC,oTFont)
			oSection1:Finish()
			oReport:SkipLine(10)
			oReport:FatLine()
			oReport:SkipLine(01)
			oSection2:Print()
		EndIf
	Next nForFilial

cFilAnt := cFilBak
RestArea(aAreaSM0)
Return
