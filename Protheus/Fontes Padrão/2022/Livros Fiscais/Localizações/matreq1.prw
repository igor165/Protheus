#INCLUDE "MATREQ1.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMATRNPC   บ Autor ณ Eduardo Dias       บ Data ณ  29/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para impressใo de Guia de Recep็ใo sem NF           บฑฑ
ฑฑบ          ณ Rotina de impressใo utilizado tecnologia TReport.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TOTVS                                                      บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณData    ณ BOPS     ณ Motivo da Alteracao                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณJonathan Glzณ05/12/16ณSERINN001-ณse agrega condicion de #IFNDEF para   ณฑฑ
ฑฑณ            ณ        ณ       685ณtratar el borrado de la tabla temporalณฑฑ
ฑฑณ            ณ        ณ          ณy se soluciona error en el query que  ณฑฑ
ฑฑณ            ณ        ณ          ณcausaba error.                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑณOscar Garciaณ18/05/18ณ          ณSe eliminan #IFNDEF TOP y CriaTrab()  ณฑฑ
ฑฑณ            ณ        ณ          ณpor SONARQUBE.                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function MATREQ1()
Local oReport

oReport := ReportDef()
oReport:PrintDialog()
Return
             
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportDef บ Autor ณ Eduardo Dias       บ Data ณ  29/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de defini็ใo das c้lulas de impressใo.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TOTVS                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static function ReportDef()
Local oDados1  
Local oDados2
Local oBreak
Local aOrdem    := {}
Local cPicture  := PesqPict("SB2","B2_VATU1")
Local cPicture2 := PesqPict("SB2","B2_QATU")

aAdd(aOrdem,STR0001)  // "Produto" 
aAdd(aOrdem,STR0002) // "Data Emissใo"

oReport := TReport():New("MATREQ1",STR0003,"MTREQ1",{|oReport| ReportPrint(oReport,aOrdem)},STR0004) //"RCN sem NF" 

Pergunte("MTREQ1",.F.)

oDados1 := TRSection():New(oReport,STR0005,{"SA2"}) //"Fornecedor"  
oDados1 :SetLineStyle()    
oDados1:SetHeaderPage()

TRCell():New(oDados1,'A2_COD'   ,'TRBSD1',RetTitle("A2_COD"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New(oDados1,"A2_LOJA"  ,'TRBSD1',RetTitle("A2_LOJA"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDados1,"A2_NOME"  ,'TRBSD1',RetTitle("A2_NOME"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)


oDados2 := TRSection():New(oDados1,STR0006,{"SD1"},aOrdem) //"formularios de recep็ใo"
oDados2 :SetTotalInLine(.F.)

TRCell():New(oDados2,"D1_DTDIGIT",'TRBSD1',RetTitle("D1_DTDIGIT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New(oDados2,"D1_DOC"    ,'TRBSD1',RetTitle("D1_DOC"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDados2,SerieNfId("SD1",3,"D1_SERIE")  ,'TRBSD1',SerieNfId("SD1",7,"D1_SERIE"),/*Picture*/,SerieNfId("SD1",6,"D1_SERIE"),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDados2,"D1_ITEM"   ,'TRBSD1',RetTitle("D1_ITEM"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDados2,"D1_COD"    ,'TRBSD1',RetTitle("D1_COD"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDados2,"D1_QUANT"  ,'TRBSD1',RetTitle("D1_QUANT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDados2,"D1_VUNIT"  ,'TRBSD1',RetTitle("D1_VUNIT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDados2,"D1_TOTAL"  ,'TRBSD1',RetTitle("D1_TOTAL"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDados2,"SALDOQTD"  ,'TRBSD1',STR0007,cPicture2,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // "Saldo em Quantidade"
TRCell():New(oDados2,"SALDOVLR"  ,'TRBSD1',STR0008,cPicture,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // "Saldo em Valor"

oBreak := TRBreak():New(oDados1,oDados1:Cell("A2_COD"),"",.T.)
TRFunction():New(oDados2:Cell("SALDOVLR"),NIL,"SUM",oBreak,STR0009,/*cPicture*/,/*uFormula*/,.F.,.F.) //oBreak01 / "Saldo Total em Valor' 	

Return( oReport )
   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportPrint บ Autor ณ Eduardo Dias     บ Data ณ  29/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de impressใo conforme retorno da query.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TOTVS                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ReportPrint( oReport, aOrdem)
Local oDados1  := oReport:Section(1) 
Local oDados2  := oReport:Section(1):Section(1)   
Local cQuebra  := ""       
Local cOrderBy := ""
Local cSelect  := ""

If oDados2:GetOrder() == 1
	cOrderBy := "%SA2.A2_COD,SA2.A2_LOJA,SD1RCN.D1_COD,SD1RCN.D1_DTDIGIT%"
Else
	cOrderBy := "%SA2.A2_COD,SA2.A2_LOJA,SD1RCN.D1_DTDIGIT,SD1RCN.D1_COD%"
EndIf

cSelect:= "%"
cSelect+= " SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SD1RCN.D1_DOC, SD1RCN.D1_DTDIGIT, SD1RCN.D1_DOC, "
If SerieNfId("SD1",3,"D1_SERIE")<> "D1_SERIE"
	cSelect+= " SD1RCN."+SerieNfId("SD1",3,"D1_SERIE")+","
Endif
cSelect+= " SD1RCN.D1_SERIE, SD1RCN.D1_ITEM, SD1RCN.D1_COD, SD1RCN.D1_QUANT, SD1RCN.D1_VUNIT, SD1RCN.D1_TOTAL,"
cSelect+= " SD1RCN.D1_QUANT - CASE WHEN SUM(SD1NF.D1_QUANT) IS NULL THEN 0 ELSE SUM(SD1NF.D1_QUANT) END AS SALDOQTD," 
cSelect+= " SD1RCN.D1_TOTAL - CASE WHEN SUM(SD1NF.D1_TOTAL) IS NULL THEN 0 ELSE SUM(SD1NF.D1_TOTAL) END AS SALDOVLR "
cSelect+= "%"     
oDados1:BeginQuery()
BeginSQL Alias "TRBSD1"

SELECT %Exp:cSelect%	                                    
FROM %Table:SD1% SD1RCN          
	JOIN %Table:SA2% SA2 ON
		SA2.%NotDel% AND
		SA2.A2_FILIAL = %xFilial:SA2% AND
		SA2.A2_COD = SD1RCN.D1_FORNECE AND
		SA2.A2_LOJA = SD1RCN.D1_LOJA
	LEFT JOIN %Table:SD1% SD1NF ON
		SD1NF.D1_FILIAL = %xFilial:SD1% AND 
        SD1NF.D1_ESPECIE = 'NF' AND
        SD1NF.D1_REMITO = SD1RCN.D1_DOC AND
        SD1NF.D1_SERIREM = SD1RCN.D1_SERIE AND 
        SD1NF.D1_ITEMREM = SD1RCN.D1_ITEM AND
		SD1NF.%NotDel%
WHERE SD1RCN.D1_DTDIGIT >= %Exp:Dtos(mv_par01)% AND 
    SD1RCN.D1_DTDIGIT <= %Exp:Dtos(mv_par02)% AND               
    SD1RCN.D1_FORNECE >= %Exp:mv_par03% AND 
    SD1RCN.D1_FORNECE <= %Exp:mv_par04% AND                    
    SD1RCN.D1_COD >= %Exp:mv_par05% AND 
    SD1RCN.D1_COD <= %Exp:mv_par06% AND 
	SD1RCN.D1_FILIAL   =   %xFilial:SD2% AND
	SD1RCN.D1_ESPECIE  = 'RCN' AND
	SD1RCN.D1_QTDACLA > 0 AND
	SD1RCN.%NotDel%
GROUP BY SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SD1RCN.D1_DTDIGIT, SD1RCN.D1_DTDIGIT, SD1RCN.D1_DOC, 
	SD1RCN.D1_SERIE, SD1RCN.D1_ITEM, SD1RCN.D1_COD, SD1RCN.D1_QUANT, SD1RCN.D1_VUNIT, SD1RCN.D1_TOTAL
HAVING CASE WHEN SUM(SD1NF.D1_QUANT) IS NULL THEN 0 ELSE SUM(SD1NF.D1_QUANT) END < SD1RCN.D1_QUANT				
ORDER BY %Exp:cOrderby%       

EndSQL 
oDados1:EndQuery()
oDados2:SetparentQuery() //utiliza a mesma query do oDados1

TcSetField("TRBSD1","D1_DTDIGIT","D",TamSX3("D1_DTDIGIT")[1],TamSX3("D1_DTDIGIT")[2])
TcSetField("TRBSD1","D1_QUANT","N",TamSX3("D1_QUANT")[1],TamSX3("D1_QUANT")[2])
TcSetField("TRBSD1","D1_VUNIT","N",TamSX3("D1_VUNIT")[1],TamSX3("D1_VUNIT")[2])
TcSetField("TRBSD1","D1_TOTAL","N",TamSX3("D1_TOTAL")[1],TamSX3("D1_TOTAL")[2])	
TcSetField("TRBSD1","SALDOQTD","N",TamSX3("D1_QUANT")[1],TamSX3("D1_QUANT")[2])
TcSetField("TRBSD1","SALDOVLR","N",TamSX3("D1_TOTAL")[1],TamSX3("D1_TOTAL")[2])	
	
dbSelectArea("TRBSD1")
While !EOF()     
	If SALDOQTD > 0
		oDados1:Init()
		oDados1:PrintLine()
		cQuebra := A2_COD+A2_LOJA
		oDados2:Init()
		While !EOF() .And. cQuebra = A2_COD+A2_LOJA
			oDados2:PrintLine()	
			dbSkip()
		EndDo
		oDados2:Finish()
		oDados1:Finish()
	Else
		dbSkip()
	EndIf
EndDo     

dbSelectArea("TRBSD1")
dbCloseArea()

Return