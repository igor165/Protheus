#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWBROWSE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISR133
Relatorio de Livros Fiscais - SFT

@author  Simone Oliveira
@version P12
@since   08/03/2017
/*/
//-------------------------------------------------------------------
Function FISR133()

Local oReport		:= nil
Local lProcessa 	:= .t.

Private cAliasSFT:= GetNextAlias()

If lProcessa .And. Pergunte("FISR133",.t.)
	oReport:=ReportDef()
	oReport:PrintDialog()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Criacao dos componentes de impressao

@author  Simone Oliveira
@version P12
@since   08/03/2017
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oReport, oSection1, oBreak1, oBreak 		

Local cFilter   := ""
Local nI        := 0
Local aFields   := { }

//Criação do componente de impressão  
   
oReport := TReport():New("FISR133",'Relatório de Livros Fiscais Por Item',"FISR133", {|oReport| ReportPrint(oReport)},'Relatório de Livros Fiscais Por Item' ) 
oReport:SetLandscape()

//Pergunte(oReport:uParam,.T.)

//Criação da seção utilizada pelo relatório 

oSection1:= TRSection():New(oReport,'Livros Fiscais Por Item',{"SFT"},/*aOrdem*/) 
oSection1:SetHeaderPage()

// Antes de imprimir cada linha posiciono no registro da SFT para utilizar as informações na impressão.
oSection1:OnPrintLine({|| SFT->(dbGoTo((cAliasSFT)->R_E_C_N_O_)) })	

//Criação das celulas da seção do relatório
TRCell():New(oSection1,"FT_NFISCAL",cAliasSFT,'Documento',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"FT_SERIE"  ,cAliasSFT,'Serie',"!!!",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"FT_CLIEFOR",cAliasSFT,'Cli/Forn',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"FT_LOJA"   ,cAliasSFT,'Loja',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"FT_EMISSAO",cAliasSFT,'Emissao',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"FT_VALCONT",cAliasSFT,'Val. Contabil',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"FT_BASEICM",cAliasSFT,'Base ICMS',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"FT_VALICM" ,cAliasSFT,'Valor ICMS',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection1 :SetTotalInLine(.F.)
TRFunction():New(oSection1:Cell("FT_VALCONT"),nil,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.) 
TRFunction():New(oSection1:Cell("FT_BASEICM") ,nil,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.) 
TRFunction():New(oSection1:Cell("FT_VALICM") ,nil,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.) 
		
		
Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Relatorio Livros Fiscais Por Item

@author  Simone Oliveira
@version P12
@since   08/03/2017
/*/
//-------------------------------------------------------------------
Static Function ReportPrint( oReport )

Local oSection1 := oReport:Section(1)
Local aFilsCalc := {}
Local aAreaSM0  := SM0->(GetArea())
Local nForFilial:= 0
Local aRetAuto	:= {}
Local cNFIni 	:= Space(TamSX3("FT_NFISCAL")[1])
Local cNFFim 	:= Replicate("Z", TamSX3("FT_NFISCAL")[1])
Local cSerIni 	:= Space(TamSX3("FT_SERIE")[1])
Local cSerFim 	:= Replicate("Z", TamSX3("FT_SERIE")[1])
Local cCFIni 	:= Space(TamSX3("FT_CLIEFOR")[1])
Local cCFFim 	:= Replicate("Z", TamSX3("FT_CLIEFOR")[1]) 
Local cLojIni 	:= Space(TamSX3("FT_LOJA")[1])
Local cLojFim 	:= Replicate("Z", TamSX3("FT_LOJA")[1])
Local cItemIni 	:= Space(TamSX3("FT_ITEM")[1])
Local cItemFim 	:= Replicate("Z", TamSX3("FT_ITEM")[1])
Local cProdIni 	:= Space(TamSX3("FT_PRODUTO")[1])
Local cProdFim 	:= Replicate("Z", TamSX3("FT_PRODUTO")[1]) 
Local cSelect 	:= ""
Local cDatfilt 	:= "%FT_EMISSAO%" 
Local lMV_Par04	:= .F.
Local oObj 		:= FWSX1Util():New()
Local aPergunte	:= {}
Local nCont 	:= 0


//-- Seleciona Filiais
If MV_PAR03==1
	If !IsBlind()
		aFilsCalc := MatFilCalc( .T. )
	Else
		If FindFunction("GetParAuto")
			aRetAuto := GetParAuto("FISR133TestCase")
			If Valtype(aRetAuto) == "A"
				aFilsCalc  := aRetAuto
			EndIf
		Endif
	Endif
Else
	aFilsCalc := {{.T.,cFilAnt}}
EndIf

oObj:AddGroup("FISR133")
oObj:SearchGroup()
aPergunte := oObj:GetGroup("FISR133")
For nCont := 1 To Len(aPergunte[2])
	iF nCont = 4
		lMV_Par04 := .T.
	Endif
NEXT nCont

If lMV_Par04
	If MV_PAR04 = 2
		cDatfilt := "%FT_ENTRADA%"
	Endif
Endif

SM0->(dbSetOrder(1))
SFT->(dbSetOrder(1))

// MONTAGEM DO SELECT

// Garante que os campos do indice serao sempre os primeiros da query.
cSelect := "SFT."+StrTran( Alltrim(SFT->( SqlOrder( IndexKey() ) ) ),",",",SFT.")

// Adiciono na query apenas os campos definidos na section e o RECNO para posicionar a tabela na impressao da linha.
cSelect += ", SFT.FT_EMISSAO, SFT.FT_VALCONT, SFT.FT_BASEICM, SFT.FT_VALICM, SFT.R_E_C_N_O_ "

cSelect := "%" + cSelect + "%"

For nForFilial := 1 To Len(aFilsCalc)
	If aFilsCalc[ nForFilial, 1 ]
		
		cFilAnt := aFilsCalc[ nForFilial, 2 ]
		
		SM0->(MsSeek(cEmpAnt + cFilAnt))

		//-------------------------------------------------------------------
		// Monta a Query com a Regra de Negocio do Relatorio.
		//-------------------------------------------------------------------
		BEGINSQL ALIAS cAliasSFT
			
			COLUMN FT_EMISSAO AS DATE
			
			SELECT
				%Exp:cSelect%
			FROM
				%Table:SFT% SFT
			WHERE 
				SFT.FT_FILIAL = %xFILIAL:SFT%
				AND SFT.FT_TIPOMOV IN ('E', 'S')
				AND SFT.FT_SERIE >= %Exp:cSerIni% AND SFT.FT_SERIE <= %Exp:cSerFim%
				AND SFT.FT_NFISCAL >= %Exp:cNFIni% AND SFT.FT_NFISCAL <= %Exp:cNFFim%
				AND SFT.FT_CLIEFOR >= %Exp:cCFIni% AND SFT.FT_CLIEFOR <= %Exp:cCFFim%
				AND SFT.FT_LOJA >= %Exp:cLojIni% AND SFT.FT_LOJA <= %Exp:cLojFim%
				AND SFT.FT_ITEM >= %Exp:cItemIni% AND SFT.FT_ITEM <= %Exp:cItemFim%
				AND SFT.FT_PRODUTO >= %Exp:cProdIni% AND SFT.FT_PRODUTO <= %Exp:cProdFim%
				AND SFT.%Exp:cDatfilt% BETWEEN %Exp:DToS(MV_PAR01)% AND %Exp:DToS(MV_PAR02)%
				AND SFT.%NOTDEL%		
		ENDSQL

		oSection1:Init()
	
		dbSelectArea( cAliasSFT )
		(cAliasSFT)->(DbGoTop())
				
		oReport:SetMeter((cAliasSFT)->(LastRec()))
	
		While !oReport:Cancel() .And. !(cAliasSFT)->(eof())
					
			If oReport:Cancel()
				Exit
			EndIf
			
			oReport:IncMeter()
			
			oSection1:PrintLine()
			
			( cAliasSFT )->( dbskip() )
			
		EndDo
	
		oSection1:Finish()
		(cAliasSFT)->( DbCloseArea() )
	EndIf
	
Next nForFilial

cFilAnt := FWGETCODFILIAL
RestArea(aAreaSM0)

Return
