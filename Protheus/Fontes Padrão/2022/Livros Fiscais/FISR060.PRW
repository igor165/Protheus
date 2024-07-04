#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FISR060.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISR060
Relatorio de ISS por Tipo de Pagamento

@author  Alexandre Lemes
@version P12
@since   01/06/2015
/*/
//-------------------------------------------------------------------
Function FISR060()

Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // Data de Emissao Inicial                      ³
//³ mv_par02     // Data de Emissao Final                        ³
//³ mv_par03     // Dentro do Municipio                          ³
//³ mv_par04     // Fora do Municipio                            ³
//³ mv_par05     // Isencao                                      ³
//³ mv_par06     // Imune                                        ³
//³ mv_par07     // Exigibilidade Suspensa Judicial              ³
//³ mv_par08     // Exigibilidade Suspensa Proc.Adm.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVerpesssen
	Pergunte( "FISR060", .F. )
	ReportDef()            
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Criacao dos componentes de impressao

@author  Alexandre Lemes
@version P12
@since   01/06/2015
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oReport   := Nil
Local oSection1 := Nil
Local cTitle    := STR0001 // "Relação de itens de ISS dos Documentos Fiscais de Saída por Tipo de Pagamento"

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
oReport := TReport():New("FISR060",cTitle,"FISR060", {|oReport| ReportPrint(oReport)},STR0002 ) //"Lista os Itens do Documento Fiscal de Saída conforme o filtro por Tipo de Pagamento do ISS definido na TES (F4_ISSST)"
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
oSection1:= TRSection():New(oReport,STR0003,{"SF2","SA1","SD2","SF4"},/*aOrdem*/) //"Documentos Fiscais"
oSection1:SetHeaderPage()
oSection1:SetNoFilter("SA1")
oSection1:SetNoFilter("SD2")
oSection1:SetNoFilter("SF4")
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
TRCell():New(oSection1,"F2_DOC"    ,cAliasQry,STR0004,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F2_SERIE"  ,cAliasQry,STR0005,"!!!"      ,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"A1_COD"    ,cAliasQry,STR0006,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"A1_LOJA"   ,cAliasQry,STR0007,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"A1_NOME"   ,cAliasQry,STR0008,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"A1_CGC"    ,cAliasQry,STR0009,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F2_EMISSAO",cAliasQry,STR0010,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F2_VALBRUT",cAliasQry,STR0011,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F4_CODIGO" ,cAliasQry,STR0012,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"BASEISS",cAliasQry,STR0013,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D2_ALIQISS",cAliasQry,STR0014,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"VALISS" ,cAliasQry,STR0015,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F4_ISSST"  ,cAliasQry,STR0016,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F2_RECISS" ,cAliasQry,STR0017,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| IIf( (cAliasQry)->F2_RECISS == "1" , STR0018 , STR0019 ) })

oSection1 :SetTotalInLine(.F.)
TRFunction():New(oSection1:Cell("F2_VALBRUT"),NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.) 
TRFunction():New(oSection1:Cell("BASEISS"),NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.) 
TRFunction():New(oSection1:Cell("VALISS") ,NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.) 

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

Local cFilterSF4 := ""
Local cTipoSF4   := ""

If MV_PAR03 == 1 // Dentro do Municipio
	cTipoSF4 += "1/" // Tem o caractere '/' para poder considerar o F4_ISSST com Branco no cadastro como '1'
EndIf

If MV_PAR04 == 1 // Fora do Municipio
	cTipoSF4 += IIf( !Empty( cTipoSF4 ) , "/2" , "2" )
EndIf

If MV_PAR05 == 1 // Isencao
	cTipoSF4 += IIf( !Empty( cTipoSF4 ) , "/3" , "3" )
EndIf

If MV_PAR06 == 1 // Imune
	cTipoSF4 += IIf( !Empty( cTipoSF4 ) , "/4" , "4" )
EndIf

If MV_PAR07 == 1 // Exigibilidade Suspensa Judicial
	cTipoSF4 += IIf( !Empty( cTipoSF4 ) , "/5" , "5" )
EndIf

If MV_PAR08 == 1 // Exigibilidade Suspensa Proc.Adm.
	cTipoSF4 += IIf( !Empty( cTipoSF4 ) , "/6" , "6" )
EndIf

If !Empty(cTipoSF4)
	cFilterSF4 := "%AND SF4.F4_ISSST IN " + FormatIn( cTipoSF4 , "/" ) + "%"
Else
	cFilterSF4 := "%AND SF4.F4_ISSST = 'X'%" // Nao ha selecao valida cancela a geracao do relatorio.
EndIf

//-------------------------------------------------------------------
// Monta a Query com a Regra de Negocio do Relatorio.
//-------------------------------------------------------------------
BEGINSQL ALIAS cAliasQry
	
	COLUMN F2_EMISSAO AS DATE
	COLUMN F2_DTDIGIT AS DATE
	COLUMN F2_EMINFE  AS DATE
	
	SELECT 	SF2.F2_FILIAL,
	SF2.F2_DOC,
	SF2.F2_SERIE,
	SF2.F2_CLIENTE,
	SF2.F2_LOJA,
	SF2.F2_FORMUL,
	SF2.F2_TIPO,
	SF2.F2_EMISSAO,
	SF2.F2_DTDIGIT,
	SF2.F2_NFELETR,
	SF2.F2_EMINFE,
	SF2.F2_HORNFE,
	SF2.F2_CODNFE,
	SF2.F2_VALBRUT,
	SF2.F2_RECISS,
	SA1.A1_COD,
	SA1.A1_LOJA,
	SA1.A1_NOME,
	SA1.A1_CGC,
	SA1.A1_MUN,
	SD2.D2_DOC,
	SD2.D2_SERIE,
	SD2.D2_CLIENTE,
	SD2.D2_LOJA,
	Sum(SD2.D2_BASEISS) BASEISS,
	SD2.D2_ALIQISS,
	Sum(SD2.D2_VALISS) VALISS,
	SD2.D2_TES,
	SF4.F4_CODIGO,
	SF4.F4_ISS,
	SF4.F4_ISSST
	
	FROM %table:SF2% SF2,
	%table:SD2% SD2,
	%table:SA1% SA1,
	%table:SF4% SF4
	
	WHERE
	
	SF2.F2_FILIAL = %xFILIAL:SF2%
	AND SF2.F2_TIPO <> %Exp:'D'%
	AND SF2.F2_TIPO <> %Exp:'B'%
	AND SF2.F2_EMISSAO BETWEEN %Exp:DToS(MV_PAR01)% AND %Exp:DToS(MV_PAR02)%
	AND SF2.%NOTDEL%
	AND SA1.A1_FILIAL = %xFILIAL:SA1%
	AND SA1.A1_COD = SF2.F2_CLIENTE
	AND SA1.A1_LOJA = SF2.F2_LOJA
	AND SA1.%NOTDEL%
	AND SD2.D2_FILIAL=%xFILIAL:SD2%
	AND SD2.D2_DOC = SF2.F2_DOC
	AND SD2.D2_SERIE = SF2.F2_SERIE
	AND SD2.D2_CLIENTE = SF2.F2_CLIENTE
	AND SD2.D2_LOJA = SF2.F2_LOJA
	AND SD2.%NOTDEL%
	AND SF4.F4_FILIAL=%xFILIAL:SF4%
	AND SF4.F4_CODIGO = SD2.D2_TES
	%exp:cFilterSF4%
	AND SF4.F4_LFISS <> %Exp:'N'%
	AND SF4.%NOTDEL%
	
	GROUP BY 	SF2.F2_FILIAL,
	SF2.F2_DOC,
	SF2.F2_SERIE,
	SF2.F2_CLIENTE,
	SF2.F2_LOJA,
	SF2.F2_FORMUL,
	SF2.F2_TIPO,
	SF2.F2_EMISSAO,
	SF2.F2_DTDIGIT,
	SF2.F2_NFELETR,
	SF2.F2_EMINFE,
	SF2.F2_HORNFE,
	SF2.F2_CODNFE,
	SF2.F2_VALBRUT,
	SF2.F2_RECISS,
	SA1.A1_COD,
	SA1.A1_LOJA,
	SA1.A1_NOME,
	SA1.A1_CGC,
	SA1.A1_MUN,
	SD2.D2_DOC,
	SD2.D2_SERIE,
	SD2.D2_CLIENTE,
	SD2.D2_LOJA,
	SD2.D2_ALIQISS,
	SD2.D2_TES,
	SF4.F4_CODIGO,
	SF4.F4_ISS,
	SF4.F4_ISSST	
	
	ORDER BY
	SF2.F2_FILIAL,
	SF2.F2_DOC,
	SF2.F2_SERIE,
	SF2.F2_CLIENTE,
	SF2.F2_LOJA,
	SF2.F2_FORMUL,
	SF2.F2_TIPO

ENDSQL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TRPosition() e necessario para que o usuario ao utilizar o relatorio possa acrescentar qualquer ³
//³coluna das tabelas que compoem a secao.                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRPosition():New(oSection1,"SF2",1,{|| xFilial("SF2") + (cAliasQry)->F2_DOC + (cAliasQry)->F2_SERIE + (cAliasQry)->F2_CLIENTE + (cAliasQry)->F2_LOJA + (cAliasQry)->F2_FORMUL + (cAliasQry)->F2_TIPO })
TRPosition():New(oSection1,"SD2",3,{|| xFilial("SD2") + (cAliasQry)->D2_DOC + (cAliasQry)->D2_SERIE + (cAliasQry)->D2_CLIENTE + (cAliasQry)->D2_LOJA })
TRPosition():New(oSection1,"SA1",1,{|| xFilial("SA1") + (cAliasQry)->F2_CLIENTE + (cAliasQry)->F2_LOJA })
TRPosition():New(oSection1,"SF4",1,{|| xFilial("SF4") + (cAliasQry)->F4_CODIGO})

oSection1:Init()

dbSelectArea( cAliasQry )
(cAliasQry)->(DbGoTop())

oReport:SetMeter((cAliasQry)->(LastRec()))

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
