#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FISR070.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISR070 
Relatório de Conferência no Recebimento Fiscal

@author  Alexandre Lemes
@version P12
@since   18/06/2015
/*/
//-------------------------------------------------------------------
Function FISR070()

Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // Data de Digitacao Inicial                    ³
//³ mv_par02     // Data de Digitacao Final                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVerpesssen
	Pergunte( "FISR070", .F. )
	ReportDef()            
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Criacao dos componentes de impressao

@author  Alexandre Lemes
@version P12
@since   18/06/2015
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oReport   := Nil
Local oSection1 := Nil
Local cTitle    := STR0001 // "Relatório de Conferência no Recebimento Fiscal"
Local aOrdem    := {STR0022,STR0021} // "Por Data de Digitação" / "Por Documento"

PRIVATE cAliasQry   := GetNextAlias()

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
oReport := TReport():New("FISR070",cTitle,"FISR070", {|oReport| ReportPrint(oReport)},STR0002 )//"Identifica os impostos retidos (INSS, ISS, IRRF, PIS, COFINS e CSLL), nos documentos fiscais de entrada do período informado nas perguntas data de digitação inicial e final."
oReport:SetLandscape()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:= TRSection():New(oReport,STR0003,{"SF1","SE2","SA2"},aOrdem) //"Documentos Fiscais de Entrada"
oSection1:SetHeaderPage()
oSection1:SetNoFilter("SE2")  
oSection1:SetNoFilter("SA2") 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRCell():New(oSection1,"E2_NUM"    ,cAliasQry,STR0004,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"E2_PREFIXO",cAliasQry,STR0005,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"E2_PARCELA",cAliasQry,STR0006,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F1_FORNECE",cAliasQry,STR0007,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F1_LOJA"   ,cAliasQry,STR0008,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"A2_NOME"   ,cAliasQry,STR0009,/*Picture*/, 29        ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"E2_EMISSAO",cAliasQry,STR0010,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"E2_VENCTO" ,cAliasQry,STR0011,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F1_VALBRUT",cAliasQry,STR0012,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"E2_INSS"   ,cAliasQry,STR0013,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"E2_ISS"    ,cAliasQry,STR0014,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"E2_IRRF"   ,cAliasQry,STR0015,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"E2_PIS"    ,cAliasQry,STR0016,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"E2_COFINS" ,cAliasQry,STR0017,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"E2_CSLL"   ,cAliasQry,STR0018,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"E2_VALOR"  ,cAliasQry,STR0019,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F1_DTDIGIT",cAliasQry,STR0020,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection1 :SetTotalInLine(.F.)
TRFunction():New(oSection1:Cell("F1_VALBRUT"),NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.) 
TRFunction():New(oSection1:Cell("E2_INSS")   ,NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.) 
TRFunction():New(oSection1:Cell("E2_ISS")    ,NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.) 
TRFunction():New(oSection1:Cell("E2_IRRF")   ,NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.) 
TRFunction():New(oSection1:Cell("E2_PIS")    ,NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.) 
TRFunction():New(oSection1:Cell("E2_COFINS") ,NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.) 
TRFunction():New(oSection1:Cell("E2_CSLL")   ,NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.) 
TRFunction():New(oSection1:Cell("E2_VALOR")  ,NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.) 

//-------------------------------------------------------------------
// Apresenta a tela de impressão.
//-------------------------------------------------------------------
oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Relatorio de ISS por Tipo de Pagamento

@author  Alexandre Lemes
@version P12
@since   01/06/2015
/*/
//-------------------------------------------------------------------
Static Function ReportPrint( oReport )

Local oSection1 := oReport:Section(1)
Local nOrdem    := oReport:Section(1):GetOrder()
Local cOrderBy  := "%%" 
Local oTFont    := TFont():New('Arial',,10,,.F.)   

If nOrdem == 1
	cOrderBy := "% SF1.F1_FILIAL,SF1.F1_DTDIGIT,SF1.F1_DOC,SF1.F1_SERIE,SF1.F1_FORNECE,SF1.F1_LOJA %"	
Else
	cOrderBy := "% SF1.F1_FILIAL,SF1.F1_DOC,SF1.F1_SERIE,SF1.F1_FORNECE,SF1.F1_LOJA,SF1.F1_TIPO %"	
EndIf


//-------------------------------------------------------------------
// Monta a Query com a Regra de Negocio do Relatorio.
//-------------------------------------------------------------------
BEGINSQL ALIAS cAliasQry
	
	COLUMN E2_EMISSAO AS DATE
	COLUMN E2_VENCTO  AS DATE
	COLUMN F1_DTDIGIT AS DATE
	COLUMN F1_EMISSAO AS DATE
	
	SELECT SF1.F1_FILIAL,
	SF1.F1_DOC,
	SF1.F1_SERIE,
	SF1.F1_FORNECE,
	SF1.F1_LOJA,    
	SF1.F1_TIPO,   
	SF1.F1_EMISSAO,
	SF1.F1_DTDIGIT,
	SF1.F1_VALBRUT,
	SA2.A2_COD,    
	SA2.A2_LOJA,  
	SA2.A2_NOME,  
	SE2.E2_NUM,   
	SE2.E2_PREFIXO,
	SE2.E2_PARCELA,
	SE2.E2_FORNECE,
	SE2.E2_LOJA,  
	SE2.E2_TIPO,
	SE2.E2_EMISSAO,
	SE2.E2_VENCTO,
	SE2.E2_INSS,
	SE2.E2_ISS,
	SE2.E2_IRRF,
	SE2.E2_PIS,                      
	SE2.E2_COFINS,
	SE2.E2_CSLL,
	SE2.E2_VALOR
	
	FROM %table:SF1% SF1 
	Inner JOIN %table:SE2% SE2 	ON  SE2.E2_FILIAL=%xFILIAL:SE2%
	AND SE2.E2_NUM = SF1.F1_DUPL
	AND SE2.E2_PREFIXO = SF1.F1_PREFIXO
	AND SE2.E2_FORNECE = SF1.F1_FORNECE
	AND SE2.E2_LOJA = SF1.F1_LOJA	
	INNER JOIN %table:SA2% SA2 ON SA2.A2_FILIAL = %xFILIAL:SA2%
	AND SA2.A2_COD = SF1.F1_FORNECE
	AND SA2.A2_LOJA = SF1.F1_LOJA

	WHERE     
	
	SF1.F1_FILIAL = %xFILIAL:SF1%
	AND SF1.F1_TIPO <> %Exp:'D'%
	AND SF1.F1_TIPO <> %Exp:'B'%
	AND SF1.F1_DTDIGIT BETWEEN %Exp:DToS(MV_PAR01)% AND %Exp:DToS(MV_PAR02)%
	AND SF1.%NOTDEL%
	AND SA2.%NOTDEL%
	AND SE2.E2_TIPO <> %Exp:'TX '% 
	AND SE2.E2_TIPO <> %Exp:'ISS'% 
	AND SE2.E2_TIPO <> %Exp:'INS'% 
	AND SE2.%NOTDEL%

	
	ORDER BY 
	%exp:cOrderBy%

ENDSQL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TRPosition() e necessario para que o usuario ao utilizar o relatorio possa acrescentar qualquer ³
//³coluna das tabelas que compoem a secao.                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRPosition():New(oSection1,"SF1",1,{|| xFilial("SF1") + (cAliasQry)->F1_DOC + (cAliasQry)->F1_SERIE + (cAliasQry)->F1_FORNECE + (cAliasQry)->F1_LOJA + (cAliasQry)->F1_TIPO })
TRPosition():New(oSection1,"SE2",1,{|| xFilial("SE2") + (cAliasQry)->E2_PREFIXO + (cAliasQry)->E2_NUM + (cAliasQry)->E2_PARCELA + (cAliasQry)->E2_TIPO  + (cAliasQry)->E2_FORNECE  + (cAliasQry)->E2_LOJA })
TRPosition():New(oSection1,"SA2",1,{|| xFilial("SA2") + (cAliasQry)->F1_FORNECE + (cAliasQry)->F1_LOJA })

oSection1:Init()

dbSelectArea( cAliasQry )
(cAliasQry)->(DbGoTop())

oReport:SetMeter((cAliasQry)->(LastRec()))

oReport:Say(120,1183,"Data De: " + Substr(Dtos(mv_par01),7,2) + "/" + Substr(Dtos(mv_par01),5,2) + "/" +  Substr(Dtos(mv_par01),1,4) + "   - ",oTFont )
oReport:Say(120,1485,"Data Até: " + Substr(Dtos(mv_par02),7,2) + "/" + Substr(Dtos(mv_par02),5,2) + "/" +  Substr(Dtos(mv_par02),1,4),oTFont )

While !oReport:Cancel() .And. !(cAliasQry)->(Eof())
	
	If oReport:Cancel()
		Exit
	EndIf	
	
	oReport:IncMeter()
	
	oSection1:PrintLine()
	
	( cAliasQry )->( dbSkip() )
	
EndDo

oSection1:Finish()
(cAliasQry)->( DbCloseArea() )

Return
