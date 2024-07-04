#INCLUDE "TMSR147.CH"
#INCLUDE "PROTHEUS.CH"

//-----------------------------------------------------------------------------------------------------------
/* Romaeio de Entrega
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	12/06/2012
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Function TMSR147()
Local oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf

Return

//-----------------------------------------------------------------------------------------------------------
/* A funcao estatica ReportDef devera ser criada para todos os relatorios que poderao ser agendados pelo 
   usuario. 
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	12/06/2012
@return 	Objeto do relatório */
//-----------------------------------------------------------------------------------------------------------
Static Function ReportDef()

Local oReport 
Local oSection1
Local oSection2 
Local oSection3 
Local oCell         
Local oBreak

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:= TReport():New("TMSR147", STR0001, "TMSR147", {|oReport| ReportPrint(oReport)}, STR0001) //"Romaneio de Entrega"
oReport:SetTotalInLine(.F.)

Pergunte("TMSR147",.F.)

oSection1 := TRSection():New(oReport, STR0001, {"DYB","DYC"}) //"Romaneio de Entrega"
oSection1 :SetTotalInLine(.F.)

TRCell():New(oSection1,"DYB_NUMROM","DYB",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DYB_DATGER","DYB",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DYB_HORGER","DYB",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DYB_NOMMOT","DYB",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Posicione("DA4",1,xFilial("DA4")+(cAlias)->DYB_CODMOT,"DA4_NOME") })
TRCell():New(oSection1,"DYB_CODVEI","DYB",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DYB_MODVEI","DYB",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Posicione('DA3',1,xFilial('DA3')+(cAlias)->DYB_CODVEI,'DA3_DESC')})

oSection2 := TRSection():New(oSection1, STR0002, {"DYC","DT6"}) //"Documentos"
oSection2 :SetTotalInLine(.F.)
oSection2:SetParentFilter({|x| (cAlias)->DYC_NUMROM == x },{|| (cAlias)->DYB_NUMROM})

TRCell():New(oSection2,"DYC_FILDOC" ,"DYC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"DYC_DOC"    ,"DYC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"DYC_SERIE"  ,"DYC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"DT6_NOMREM" ,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"DT6_NOMDES" ,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"DT6_QTDVOL" ,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"DT6_PESO"   ,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"DT6_PESOM3" ,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"DT6_VALMER" ,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRFunction():New(oSection2:Cell("DT6_QTDVOL"),NIL,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.T.,,) 
TRFunction():New(oSection2:Cell("DT6_PESO"  ),NIL,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.T.,,) 
TRFunction():New(oSection2:Cell("DT6_PESOM3"),NIL,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.T.,,) 
TRFunction():New(oSection2:Cell("DT6_VALMER"),NIL,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.T.,,) 

Return(oReport)

//-----------------------------------------------------------------------------------------------------------
/* A funcao estatica ReportPrint devera ser criada para todos os relatorios que poderao ser agendados pelo 
   usuario. 
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	12/06/2012
@return 	Objeto do relatório */
//-----------------------------------------------------------------------------------------------------------
Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1) 
Local oSection2 := oReport:Section(1):Section(1)  
Local	cAlias 	:= GetNextAlias()

cAlias := GetNextAlias()
MakeSqlExpr(oReport:uParam)

oReport:Section(1):BeginQuery()	
		 
BeginSql Alias cAlias

	SELECT DYB_NUMROM, DYB_DATGER, DYB_HORGER, DYB_CODMOT, DYB_CODVEI, DYC_NUMROM, DYC_FILDOC,DYC_DOC,DYC_SERIE,
			 DT6_QTDVOL, DT6_PESO, DT6_PESOM3, DT6_VALMER, SA1R.A1_NOME DT6_NOMREM, SA1D.A1_NOME DT6_NOMDES	
	
	FROM %table:DYB% DYB, %table:DYC% DYC, %table:DT6% DT6, %table:SA1% SA1R, %table:SA1% SA1D
	
	WHERE DYB_FILIAL = %xFilial:DYB% AND 
	   	  DYB_NUMROM 		>= %Exp:mv_par01% AND 
		  DYB_NUMROM 		<= %Exp:mv_par02% AND
		  DYB_DATGER     >= %Exp:DtoS(mv_par03)% AND
		  DYB_DATGER     <= %Exp:DtoS(mv_par04)% AND 		  
		  DYC_FILIAL 		= %xFilial:DYC% AND
		  DYC_NUMROM 		= DYB_NUMROM AND
		  DT6_FILIAL 		= %xFilial:DT6% AND 
		  DT6_FILDOC 		= DYC_FILDOC AND
		  DT6_DOC    		= DYC_DOC  AND
		  DT6_SERIE  		= DYC_SERIE AND
		  SA1R.A1_FILIAL	= %xFilial:SA1% AND
		  SA1R.A1_COD		= DT6_CLIREM AND
		  SA1R.A1_LOJA	= DT6_LOJREM AND
		  SA1D.A1_FILIAL	= %xFilial:SA1% AND
		  SA1D.A1_COD		= DT6_CLIDES AND
		  SA1D.A1_LOJA 	= DT6_LOJDES AND		  
		  DYB.%NotDel% AND
	  		  DYC.%NotDel% AND
	  		  SA1R.%NotDel% AND
	  		  SA1D.%NotDel% AND
	  		  DT6.%NotDel% 
			  
	ORDER BY %Order:DYB% 
		
EndSql 
oReport:Section(1):EndQuery()

oSection2:SetParentQuery()

oReport:SetMeter((cAlias)->(LastRec()))
oSection1:Init()
oReport:Section(1):Print()
oSection1:Finish()

Return NIL

