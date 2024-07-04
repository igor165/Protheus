#INCLUDE "MATREQ2.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMATREQ2   บ Autor ณ Eduardo Dias       บ Data ณ  29/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para impressใo de Dev. Guia Recep็ใo sem Nota Cred. บฑฑ
ฑฑบ          ณ Rotina de impressใo utilizado tecnologia TReport.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TOTVS                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑณOscar Garciaณ21/05/18ณDMINA-2802ณSe eliminan #IFNDEF TOP, #IFNDEF TOP  ณฑฑ
ฑฑณ            ณ        ณ          ณy CriaTrab() por SONARQUBE.           ณฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function MATREQ2()
Local oReport := ReportDef()
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
Static Function ReportDef()
Local aOrdem	:= {RetTitle("D2_COD"),RetTitle("D2_EMISSAO")}
Local oReport   := TReport():New("MATREQ2",STR0010,"MTREQ2",{|oReport| ReportPrint(oReport,aOrdem)}, STR0010) //"RCD sem NCP"
Local oDados1 	:= TRSection():New(oReport,STR0011,{"SA2"})	//"Fornecedores"  
Local oDados2 	:= TRSection():New(oDados1,STR0003,{"SD2"},aOrdem) //"Dev. formulแrio rec."
Local oBreak	:= NIL
Local cPictVal	:= PesqPict("SB2","B2_VATU1")
Local cPictQtd	:= PesqPict("SB2","B2_QATU")

Pergunte(oReport:uParam,.F.)  

TRCell():New(oDados1,'A2_COD'    ,"TRBSD2",RetTitle("A2_COD"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New(oDados1,"A2_LOJA"   ,"TRBSD2",RetTitle("A2_LOJA"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDados1,"A2_NOME"   ,"TRBSD2",RetTitle("A2_NOME"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oDados2,"D2_EMISSAO","TRBSD2",RetTitle("D2_EMISSAO"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New(oDados2,"D2_DOC"    ,"TRBSD2",RetTitle("D2_DOC"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDados2,SerieNfId("SD2",3,"D2_SERIE"),"TRBSD2",SerieNfId("SD2",7,"D2_SERIE"),/*Picture*/,SerieNfId("SD2",6,"D2_SERIE"),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDados2,"D2_ITEM"   ,"TRBSD2",RetTitle("D2_ITEM"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDados2,"D2_COD"    ,"TRBSD2",RetTitle("D2_COD"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDados2,"D2_QUANT"  ,"TRBSD2",RetTitle("D2_QUANT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDados2,"D2_PRCVEN" ,"TRBSD2",RetTitle("D2_PRCVEN"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDados2,"D2_TOTAL"  ,"TRBSD2",RetTitle("D2_TOTAL"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDados2,"SALDOQTD"  ,"TRBSD2",STR0006,cPictQtd,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // "Saldo em Quantidade"
TRCell():New(oDados2,"SALDOVLR"  ,"TRBSD2",STR0007,cPictVal,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // "Saldo em Valor"

oBreak := TRBreak():New(oDados1,oDados1:Cell("A2_COD"),"",.T.)
TRFunction():New(oDados2:Cell("SALDOVLR"),NIL,"SUM",oBreak,STR0004,/*cPicture*/,/*uFormula*/,.F.,.F.) //"Saldo Total em Valor"

oDados1:SetLineStyle()    
oDados1:SetHeaderPage()	
oDados2:SetTotalInLine(.F.)
	 
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
Static Function ReportPrint(oReport,aOrdem)
Local oDados1	:= oReport:Section(1) 
Local oDados2	:= oReport:Section(1):Section(1)   
Local cQuebra := ""      
Local cOrderby:= "" 
Local cSelect := ""    

If oDados2:GetOrder() == 1
	cOrderBY := '%SA2.A2_COD,SA2.A2_LOJA,SD2RCD.D2_COD,SD2RCD.D2_EMISSAO%'
Else
	cOrderBY := '%SA2.A2_COD,SA2.A2_LOJA,SD2RCD.D2_EMISSAO,SD2RCD.D2_COD%'
EndIf

cSelect:="%"
cSelect+="SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SD2RCD.D2_EMISSAO, SD2RCD.D2_DOC, SD2RCD.D2_SERIE,"
If SerieNfId("SD2",3,"D2_SERIE")<>"D2_SERIE"
	cSelect+= "SD2RCD."+SerieNfId("SD2",3,"D2_SERIE")+","
Endif	
cSelect+="	SD2RCD.D2_ITEM, SD2RCD.D2_COD, SD2RCD.D2_QUANT, SD2RCD.D2_PRCVEN, SD2RCD.D2_TOTAL,"
cSelect+="	SD2RCD.D2_QUANT - CASE WHEN SUM(SD2NCP.D2_QUANT) IS NULL THEN 0 ELSE SUM(SD2NCP.D2_QUANT) END AS SALDOQTD," 
cSelect+="	SD2RCD.D2_TOTAL - CASE WHEN SUM(SD2NCP.D2_TOTAL) IS NULL THEN 0 ELSE SUM(SD2NCP.D2_TOTAL) END AS SALDOVLR"
cSelect+="%"
oDados1:BeginQuery()
BeginSQL Alias "TRBSD2"
	SELECT %Exp:cSelect%
	FROM %Table:SD2% SD2RCD
		JOIN %Table:SA2% SA2 ON
			SA2.%NotDel% AND
			SA2.A2_FILIAL = %xFilial:SA2% AND
			SA2.A2_COD = SD2RCD.D2_CLIENTE AND
			SA2.A2_LOJA = SD2RCD.D2_LOJA			
		LEFT JOIN %Table:SD2% SD2NCP ON
			SD2NCP.D2_FILIAL  = %xFilial:SD2% AND 
			SD2NCP.D2_ESPECIE LIKE 'NC%' AND 
			SD2NCP.D2_CLIENTE = SD2RCD.D2_CLIENTE AND
			SD2NCP.D2_LOJA = SD2RCD.D2_LOJA AND
			SD2NCP.D2_REMITO  = SD2RCD.D2_DOC AND
			SD2NCP.D2_SERIREM = SD2RCD.D2_SERIE AND 
			SD2NCP.D2_ITEMREM = SD2RCD.D2_ITEM AND
			SD2NCP.%NotDel%
	WHERE SD2RCD.D2_EMISSAO >= %Exp:Dtos(mv_par01)% AND 
		SD2RCD.D2_EMISSAO <= %Exp:Dtos(mv_par02)% AND               
	    SD2RCD.D2_CLIENTE >= %Exp:mv_par03% AND 
	    SD2RCD.D2_CLIENTE <= %Exp:mv_par04% AND                    
	    SD2RCD.D2_COD >= %Exp:mv_par05% AND 
		SD2RCD.D2_COD <= %Exp:mv_par06% AND 
		SD2RCD.D2_FILIAL   =   %xFilial:SD2% AND
		SD2RCD.D2_ESPECIE  = 'RCD' AND
		SD2RCD.%NotDel%
	GROUP BY SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SD2RCD.D2_EMISSAO, SD2RCD.D2_DOC, SD2RCD.D2_SERIE,
		SD2RCD.D2_ITEM, SD2RCD.D2_COD, SD2RCD.D2_QUANT, SD2RCD.D2_PRCVEN, SD2RCD.D2_TOTAL
	HAVING CASE WHEN SUM(SD2NCP.D2_QUANT) IS NULL THEN 0 ELSE SUM(SD2NCP.D2_QUANT) END < SD2RCD.D2_QUANT
	ORDER BY %Exp:cOrderby%
EndSQL
oDados1:EndQuery()
oDados2:SetparentQuery() //utiliza a mesma query do oDados1   
TcSetField("TRBSD2","D2_EMISSAO","D",TamSX3("D2_EMISSAO")[1],TamSX3("D2_EMISSAO")[2])
TcSetField("TRBSD2","D2_QUANT","N",TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2])
TcSetField("TRBSD2","D2_PRCVEN","N",TamSX3("D2_PRCVEN")[1],TamSX3("D2_PRCVEN")[2])
TcSetField("TRBSD2","D2_TOTAL","N",TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2])
TcSetField("TRBSD2","SALDOQTD","N",TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2])
TcSetField("TRBSD2","SALDOVLR","N",TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2])	    

dbSelectArea("TRBSD2")  
While !EOF()
	If SALDOQTD > 0
		oDados1:Init()
		oDados1:PrintLine()
		cQuebra := ("TRBSD2")->(A2_COD+A2_LOJA)
		oDados2:Init()
		While !EOF() .And. cQuebra == A2_COD+A2_LOJA
			oDados2:PrintLine()	
			dBSkip()
		End   
		oDados2:Finish()
		oDados1:Finish()
	Else
		dBSkip()
	EndIf                   
EndDo  

dbSelectArea("TRBSD2")
dbCloseArea()	        
	
Return