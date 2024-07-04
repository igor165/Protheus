#include "PROTHEUS.ch"
#include "TMSRE75.ch"


/*/{Protheus.doc} TMSRE75
Relatório de Divergência entre Pré-Fatura x Documentos
@type		function
@author  	Daniel Leme
@version 	P12
@since   	12/03/2019
@return  	Nil
/*/
Function TMSRE75()

Local cPerg   := 'TMSRE75'

If DEB->(ColumnPos("DEB_CGCDEV")) > 0 .And. DEB->(ColumnPos("DEB_FILDOC")) > 0
    AjustaSX1(cPerg)

    oReport:= ReportDef()
    oReport:PrintDialog()
Else
    MsgAlert("Atualize o dicionário - Pré-fatura não implantada (DEB_CGCDEV/DEB_FILDOC)!")
EndIf

Return Nil

/*/{Protheus.doc} ReportDef
Layout do Report

@type		function
@author  	Daniel Leme
@version 	P12
@since   	12/03/2019
@return  	oReport
/*/
Static Function ReportDef()

Local cPerg   := 'TMSRE75'
Local cTitulo := STR0001 //-- 'Rel.Divergências Pré-Fatura'
Local wnRel   := 'TMSRE75'

Local oReport    
oReport := TReport():New(wnRel,cTitulo,cPerg,{|oReport| ReportPrint(oReport)},cTitulo)

oSection1:= TRSection():New(oReport,STR0002,{"DT6","DEB"}) //-- "Documentos"
oSection1:SetTotalInLine(.F.)

	TRCell():New(oSection1,"DEB_CGCDEV" ,"DEB",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DEB_NUMPRE" ,"DEB",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DEB_FILDOC"	,"DEB",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DEB_DOC"	,"DEB",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DEB_SERIE"	,"DEB",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DEB_VALOR"	,"DEB",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT6_VALFAT"	,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"QRY_DIF"	,     ,STR0003  /*Titulo*/,"@E 9,999,999,999.99"/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //-- "Diferença"
	TRCell():New(oSection1,"TOLERANCIA"	,     ,STR0004 /*Titulo*/,"@!"/*Picture*/,20/*Tamanho*/,/*lPixel*/,{|| TMRE75Tole(DEB_CGCDEV)}/*{|| code-block de impressao }*/) //-- "Tolerância"

	TRFunction():New(oSection1:Cell( "DEB_SERIE" ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection1:Cell( "DEB_VALOR" ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection1:Cell( "DT6_VALFAT"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
	TRFunction():New(oSection1:Cell( "QRY_DIF"   ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)

Return(oReport)

/*/{Protheus.doc} ReportPrint
Impressão do Report

@type		function
@author  	Daniel Leme
@version 	P12
@since   	12/03/2019
@return  	oReport
/*/
Static Function ReportPrint(oReport)
Local oSection1	:= oReport:Section(1)

oSection1:BeginQuery()

BeginSql Alias 'QRYRELX'  
    SELECT (DEB_VALOR - COALESCE(DT6_VALFAT,0)) QRY_DIF, * 
    FROM %table:DEB% DEB
    LEFT JOIN %table:DT6% DT6
      ON  DT6.DT6_FILIAL = %xFilial:DT6% 
      AND DT6.DT6_FILDOC = DEB.DEB_FILDOC 
      AND DT6.DT6_DOC    = DEB.DEB_DOC 
      AND DT6.DT6_SERIE  = DEB.DEB_SERIE 
      AND DT6.%NotDel%
    WHERE DEB.DEB_FILIAL = %xFilial:DEB% 
      AND DEB.DEB_CGCDEV  BETWEEN  %Exp:mv_par01% AND %Exp:mv_par02%
      AND DEB.DEB_DATVEN  BETWEEN  %Exp:mv_par03% AND %Exp:mv_par04%
      AND DEB.%NotDel%
    ORDER BY DEB_NUMPRE, DEB_FILDOC, DEB_DOC, DEB_SERIE
EndSql		

oSection1:EndQuery() 	
                  
oSection1:Print() // processa as informacoes da tabela principal		

Return( NIL )


/*/{Protheus.doc} AjustaSX1
Criação de Perguntas

@type		function
@author  	Daniel Leme
@version 	P12
@since   	12/03/2019
@return  	oReport
/*/
Static Function AjustaSX1(cPerg)

CheckSX1(cPerg,"01","CGC Devedor De ?","CGC Devedor De ?","CGC Devedor De ?","mv_ch1",;
			"C",TamSx3("DEB_CGCDEV")[1],0,0,"G","","DE4","","","mv_par01","","","","","","","","","","","","","","","","",;
			{},{},{})

CheckSX1(cPerg,"02","CGC Devedor Até ?","CGC Devedor Até ?","CGC Devedor Até ?","mv_ch2",;
			"C",TamSx3("DEB_CGCDEV")[1],0,0,"G","","DE4","","","mv_par02","","","","","","","","","","","","","","","","",;
			{},{},{})

CheckSX1(cPerg,"03","Vencimento De ?","Vencimento De ?","Vencimento De ?","mv_ch3",;
			"D",8,0,0,"G"," ","","","","mv_par03","","","","","","","","","","","","","","","","",;
			{},{},{})

CheckSX1(cPerg,"04","Vencimento Até ?","Vencimento Até ?","Vencimento Até ?","mv_ch4",;
			"D",8,0,0,"G"," ","","","","mv_par04","","","","","","","","","","","","","","","","",;
			{},{},{})

Pergunte(cPerg,.F.)
Return NIL

/*/{Protheus.doc} TMRE75Tole
Retorna a Tolerância do Cliente

@type		function
@author  	Daniel Leme
@version 	P12
@since   	12/03/2019
@return  	oReport
/*/
Static Function TMRE75Tole(cCGCDev)
Local cRet    := "Não Considera"
Local cCliDev := ""
Local cLojDev := ""
Local aPerfil

SA1->(DbSetOrder(3))
If SA1->(DbSeek(xFilial("SA1") + cCGCDev))
    cCliDev := SA1->A1_COD
    cLojDev := SA1->A1_LOJA
    aPerfil := TmsPerfil(cCliDev,cLojDev,,.F.)
    If Len(aPerfil) >= 61 .And. ValType(aPerfil[61]) == "A" .And. Len(aPerfil[61]) >= 7
        If aPerfil[61][4] == "1" //Percentual
            cRet := Transform(aPerfil[61][5],"@E 999.99") + " %"
        ElseIf aPerfil[61][4] != "3" // Diferente de "Não Considera"
            cRet := Transform(aPerfil[61][5],PesqPict("DEB","DEB_VALOR"))
	    EndIf
	EndIf
EndIf

cRet := PadR(cRet,20)

Return cRet