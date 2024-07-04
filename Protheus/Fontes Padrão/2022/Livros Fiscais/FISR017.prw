#include "PROTHEUS.CH"
#include "FISR017.CH"
#INCLUDE "REPORT.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ FISR017  ³ Autor ³ Natalia Antonucci     ³ Data ³ 31/10/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Controle para restituição do ICMS ST (Art 23,                ³±± 
±±³			 |	Livro III do RICMS/RS de 1997)                              ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIS   	                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fisr017()

Local cMVEstado := GetMV('MV_ESTADO')
Local oReport
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)   

If lVerpesssen .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport	:= ReportDef(cMVEstado)
	oReport:PrintDialog()
   	
Endif 
 
Return   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ReportDef ³ Autor ³ Natalia Antonucci     ³ Data ³ 31/10/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Definicao do componente                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef(cMVEstado)

Local oPosition
Local oReport
Local oRelat
Local oProd
Local oSai
Local oNomes
Local oBreak
Local lAgrupaHip	:= .F. 
Local lIcmsProp		:= .F.
 
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
	
oReport := TReport():New("FISR017",STR0001,"FISR017", {|oReport| ReportPrint(oReport,cMVEstado)},STR0001+" "+STR0002)
oReport:SetTotalInLine(.F.)
oReport:SetLandscape() 

ValidPerg("FISR017")
Pergunte("FISR017",.T.) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as OrdensÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                      do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                       ³
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
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Secao Quadro Hipotese

lAgrupaHip	:= Iif(MV_PAR03 == 1 .AND. cMVEstado=='SC',.T.,.F.) 
lIcmsProp	:= Iif(MV_PAR04 == 1 .AND. cMVEstado=='SC' ,.T.,.F.)


IF cMVEstado $ 'RS/SC/PR/GO/BA/RJ'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria modelo para Estados Homologados, com suas respectivas particularidades.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	oQuadro:=TRSection():New(oReport,STR0003,{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/,,,,.T.)
	oQuadro:SetHeaderSection(.T.)
	oQuadro:SetLeftMargin(20)	
	
	//Secao Relatorio
	oRelat:=TRSection():New(oReport,STR0003,{"TRB","CDM"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oPosition:=TRPosition():New(oRelat,"CDM",2,{|| xFilial("CDM") + TRB->DOCSAI + TRB->SERIES})
	
	TRCell():New(oRelat,"DOCSAI"	,"TRB",STR0007,/*cPicture*/,TamSX3("F2_DOC")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Nota Fiscal"
	TRCell():New(oRelat,"SERIES"  	,"TRB",STR0014,/*cPicture*/,03,/*lPixel*/,/*{|| code-block de impressao }*/) //"Serie"
	TRCell():New(oRelat,"DTSAI"		,"TRB",STR0006,/*cPicture*/,08,/*lPixel*/,/*{|| code-block de impressao }*/) //"Dt. Emissao"
	TRCell():New(oRelat,"ITSAI"		,"TRB",STR0015,/*cPicture*/,02,/*lPixel*/,/*{|| code-block de impressao }*/) //"Nota Fiscal"
	TRCell():New(oRelat,"PRODUT"	,"TRB",STR0016,/*cPicture*/,TamSX3("B1_COD")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Codigo"
	TRCell():New(oRelat,"QTDVDS" 	,"TRB",STR0010,"@E 99,999,999,999.99",11,/*lPixel*/,/*{|| code-block de impressao }*/) //"Quantidade"
	
	If cMVEstado=='PR'
	 	TRCell():New(oRelat,"ICMSS","TRB",STR0027,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor ICMS SAIDA
	Endif
	
	TRCell():New(oRelat,"HIPOTESE"	,"TRB",STR0018,/*cPicture*/,01,/*lPixel*/,/*{|| code-block de impressao }*/) //"Hipotese"

	TRCell():New(oRelat,"DTENT"		,"TRB",STR0017,/*cPicture*/,08,/*lPixel*/,/*{|| code-block de impressao }*/) //"Dt. Entrada"
	TRCell():New(oRelat,"DOCENT"	,"TRB",STR0023,/*cPicture*/,TamSX3("F2_DOC")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Nota Fiscal"
	TRCell():New(oRelat,"FORNEC"	,"TRB",STR0008,/*cPicture*/,06,/*lPixel*/,/*{|| code-block de impressao }*/) //"Fornecedor	
	
	IF lIcmsProp // Irá incluir as colunas com valor do ICMS Próprio do documento de entrada
		TRCell():New(oRelat,"BCICMSE"   	,"TRB","BC.Icms","@E 999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor d base de cálculo de icms da entrada"
		TRCell():New(oRelat,"ICMSE"			,"TRB","VL.Icms","@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/)//"Valor ICMS ENTRADA"
	EndIF
	
	If cMVEstado$'RS/SC/GO/BA/ES/RJ'
		TRCell():New(oRelat,"BSERET","TRB",  Iif(lIcmsProp,"BC.IcmsSt Ent.",STR0009)  ,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Base de Calculo ICMS ST"
	Endif
	
	TRCell():New(oRelat,"QTDENT" 	,"TRB",STR0010,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Quantidade"
	
	If cMVEstado$'PR/RJ'
		TRCell():New(oRelat,"ICMSST","TRB",STR0026,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor ICMSST"
		IF cMVEstado == "PR"
			TRCell():New(oRelat,"ICMSE"	,"TRB",STR0030,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/)//"Valor ICMS ENTRADA"
			TRCell():New(oRelat,"DIFERENCA"	,"TRB",STR0028,"@E 99,999,999.99",11,/*lPixel*/,/*{|| code-block de impressao }*/) //"Diferença"
		EndIF
	Endif 
	
	If cMVEstado$'RS/SC/GO/BA/ES/RJ'
		TRCell():New(oRelat,"BASRES","TRB",Iif(lIcmsProp,"BC.Ressar.",STR0011),"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Base de Calculo do Ressarcimento"
	Endif 
	
	TRCell():New(oRelat,"VALRES"   	,"TRB",STR0012,"@E 999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor do Ressarcimento"
	
	IF lIcmsProp//Irá incluir a coluna de totalizador do ICMS Próprio da nota de entrada 
		TRCell():New(oRelat,"RECICMS"   	,"TRB","Rec.ICMS","@E 999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Recuperação ICMS"	
	EndIF
	
	TRCell():New(oRelat,"VALCUL"   	,"TRB", Iif(lIcmsProp,"Ressarc.ST","Val.Acum.Ressar."),"@E 999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Acumulado do Ressarcimento"
	
	IF lAgrupaHip // Irá fazer agrupamento e quebra de página por código de hipótese.
		oBreak := TRBreak():New(oRelat,oRelat:Cell("HIPOTESE"),"",.T.,,.T.)
		TRFunction():New(oRelat:Cell("HIPOTESE"),NIL,"MAX",oBreak,,,,.F.,.F.) //"Hipotese"
	
		IF lIcmsProp // Se controlar ICMS Próprio irá incluir coluna
			TRFunction():New(oRelat:Cell("RECICMS"),NIL,"MAX",oBreak,,,,.F.,.F.) //"Totalizador do valor de ICMS Próprio"
		EndIF
	
		TRFunction():New(oRelat:Cell("VALCUL"),NIL,"MAX",oBreak,,,,.F.,.F.) //"Totalizador do valor de ST"
		oRelat:SetHeaderBreak(.T.)
	EndIF
	
ElseIf cMVEstado == 'MG'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria modelo Padrão Genérico para os Estados não homologados.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oQuadro:=TRSection():New(oReport,STR0003,{"TRB","CDM"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/,,,,.T.)
	oQuadro:SetHeaderSection(.T.)
	oQuadro:SetLeftMargin(20)	
	
	//Secao Relatorio
    oRelat:=TRSection():New(oReport,STR0003,{"TRB","CDM"},,)
	oPosition:=TRPosition():New(oRelat,"CDM",3,{|| xFilial("CDM") + TRB->DOCENT + TRB->SERIEE + TRB->PRODUTO})
	
	//Informações do produto
	TRCell():New(oRelat,"NCM"		,"TRB",'NCM',,TamSX3("B1_POSIPI")[1],,)  	
	TRCell():New(oRelat,"PRODUTO"	,"TRB",'Produto',,TamSX3("B1_COD")[1],,)
	TRCell():New(oRelat,"DESCRPROD"	,"TRB",'Desc.Prod.',,TamSX3("B1_DESC")[1],,)
	
	//Informações do documento de entrada
	TRCell():New(oRelat,"DOCENT"	,"TRB",'NF Ent.',,12,,)
	TRCell():New(oRelat,"EMISSAOE"	,"TRB",'Emissao',,12,,)
	TRCell():New(oRelat,"CFOP"		,"TRB",'CFOP',,05,,)
	TRCell():New(oRelat,"QTDEE" 	,"TRB",'Qtd.Ent.',"@E 99999999.99",11,,)
	TRCell():New(oRelat,"VLPROD"	,"TRB",'Vl.Prod.',"@E 99,999,999,999.99",17,,) 
	TRCell():New(oRelat,"BASEENT"	,"TRB",'B.C.Ent.',"@E 99,999,999,999.99",17,,)
	TRCell():New(oRelat,"ALIQ"		,"TRB",'Alq.',"@E 999.99",6,,)	
	TRCell():New(oRelat,"ICMSP"		,"TRB",'Vl.ICMS',"@E 99,999,999,999.99",17,,)
	TRCell():New(oRelat,"DESP"		,"TRB",'Desp.Aces.',"@E 99,999,999,999.99",17,,)	
	TRCell():New(oRelat,"MVA"		,"TRB",'MVA',"@E 999.99",6,,)
	TRCell():New(oRelat,"BASEENTST"	,"TRB",'B.C.Ent.ST',"@E 99,999,999,999.99",17,,)
	TRCell():New(oRelat,"ALIQI"		,"TRB",'Alq.Int',"@E 999.99",6,,)
	TRCell():New(oRelat,"ICMSRET"	,"TRB",'ICMS ST',"@E 99,999,999,999.99",20,,)
	
	//Informações do documento de saída
	TRCell():New(oRelat,"DOCSAI"	,"TRB",'NF Sai.',,12,,)
	TRCell():New(oRelat,"EMISSAOS"	,"TRB",'Emissao',,12,,)
	TRCell():New(oRelat,"QTDES" 	,"TRB",'Qtd.Sai.',"@E 99999999.99",11,,)
	
	//~Informações dos valores a restituir
	TRCell():New(oRelat,"CALCICMS1" ,"TRB",'ICMS ST',"@E 99,999,999,999.99",17,,)
	TRCell():New(oRelat,"CALCICMS2" ,"TRB",'ICMS ST Rest.',"@E 99,999,999,999.99",17,,)	
	TRCell():New(oRelat,"CALCICMS3" ,"TRB",'ICMS',"@E 99,999,999,999.99",17,,)
	TRCell():New(oRelat,"CALCICMS4" ,"TRB",'ICMS Cred.',"@E 99,999,999,999.99",17,,)
	oRelat:SetHeaderBreak(.T.)	
	oRelat:SetPageBreak(.T.)
	oRelat:SetHeaderSection(.T.)
	oRelat:SetTitle('RESTITUIÇÃO')
	oRelat:lHeaderVisible := .T.
	
	
	oBreak := TRBreak():New(oRelat,'1',"",.T.,,.T.)	
	TRFunction():New(oRelat:Cell("CALCICMS2"),NIL,"SUM",oBreak,,,,.F.,.F.) //"Totalizador do valor de ST"	
	TRFunction():New(oRelat:Cell("CALCICMS4"),NIL,"SUM",oBreak,,,,.F.,.F.) //"Totalizador do valor de ST"
	oRelat:SetHeaderBreak(.T.)
	

	//Secao Relatorio
    oProd:=TRSection():New(oReport,'RESUMO POR PRODUTO',{"PROD","TRB","CDM"},,)
	oPosition:=TRPosition():New(oProd,"CDM",3,{|| xFilial("CDM") /*+ TRB->DOCENT + TRB->SERIEE + TRB->PRODUTO*/})
	
	TRCell():New(oProd,"NCM"			,"PROD",'NCM',,TamSX3("B1_POSIPI")[1],,)
	TRCell():New(oProd,"PRODUTO"	,"PROD",'Produto',,TamSX3("B1_COD")[1],,)
	TRCell():New(oProd,"DESCRPROD"	,"PROD",'Descrição',,TamSX3("B1_DESC")[1],,)	
	TRCell():New(oProd,"UNID"		,"PROD",'Un. Medida',,15,,)	
	TRCell():New(oProd,"QTDES" 		,"PROD",'Quantidade',"@E 99999999.99",20,,)	
	TRCell():New(oProd,"CALCICMS1" ,"PROD",'ICMS ST Restituir',"@E 99,999,999,999.99",25,,)
	TRCell():New(oProd,"CALCICMS2" ,"PROD",'ICMS a Creditar',"@E 99,999,999,999.99",25,,)
	oProd:SetHeaderBreak(.T.)	
	oProd:SetPageBreak(.T.)
	oProd:SetHeaderSection(.T.)
	oProd:SetTitle('RESUMO POR PRODUTO')	
	oProd:SkipLine(10)
	oProd:lHeaderVisible := .T.
	
	oBreak2 := TRBreak():New(oProd,'1',"",.T.,,.T.)
	TRFunction():New(oProd:Cell("CALCICMS1"),NIL,"SUM",oBreak2,,,,.F.,.F.) //"Totalizador do valor de ST"
	TRFunction():New(oProd:Cell("CALCICMS2"),NIL,"SUM",oBreak2,,,,.F.,.F.) //"Totalizador do valor de ST"	
	
	
	//Secao Relatorio
	oSai:=TRSection():New(oReport,'RESUMO POR DOCUMENTO DE SAÍDA',{"SAI","TRB","CDM"},,)
	oPosition:=TRPosition():New(oSai,"CDM",2,{|| xFilial("CDM") + TRB->DOCSAI + TRB->SERIES})

	TRCell():New(oSai,"DOCSAI"			,"SAI",'Nota Fiscal',,20,,)
	TRCell():New(oSai,"EMISSAOS"		,"SAI",'Emissão',,12,,)	
	TRCell():New(oSai,"CFOP"				,"SAI",'CFOP',,8,,)	
	TRCell():New(oSai,"RAZSOC"			,"SAI",'Razão Social',,TamSX3("A2_NOME")[1],,)
	TRCell():New(oSai,"ESTADO"			,"SAI",'UF Destino',,15,,)			
	TRCell():New(oSai,"IE"				,"SAI",'Inscrição Estadual',,30,,)	
	TRCell():New(oSai,"CNPJ"				,"SAI",'CNPJ','@R 99.999.999/9999-99',18,,)
	oSai:SetHeaderBreak(.T.)	
	oSai:SetPageBreak(.T.)
	oSai:SetHeaderSection(.T.)
	oSai:SetTitle('RESUMO POR DOCUMENTO DE SAÍDA')
	oSai:lHeaderVisible := .T.
	oSai:SetBorder('',,,.T.)

ElseIf cMVEstado == 'ES'

	If MV_PAR06 = 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria modelo Padrão Genérico para os Estados não homologados.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oQuadro:=TRSection():New(oReport,STR0003,{"TRB","CDM"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/,,,,.T.)
		oQuadro:SetHeaderSection(.T.)
		oQuadro:SetLeftMargin(20)	
		
		//Secao Relatorio
		oRelat:=TRSection():New(oReport,STR0003,{"TRB"},,)
		
		//Informações do Contribuinte - Quadro 01
		TRCell():New(oRelat,"RazSoc"	,"TRB",'REQUERENTE',,TamSX3("A1_NOME")[1],,)  	
		TRCell():New(oRelat,"IE"		,"TRB",'I.E.',,TamSX3("A1_INSCR")[1],,)
		TRCell():New(oRelat,"CNPJ"		,"TRB",'CNPJ',,TamSX3("A1_CGC")[1],,)
		TRCell():New(oRelat,"PED"	    ,"TRB",'PEDIDO Nº',,30,,)
		TRCell():New(oRelat,"ANO"	    ,"TRB",'ANO',,8,,)

		oRelat:SetHeaderBreak(.T.)	
		oRelat:SetHeaderSection(.T.)

		oProd:=TRSection():New(oReport,STR0003,{"PROD","TRB"},,)
		
		TRCell():New(oProd,"PRODUT"	,"PROD",'Produto',,TamSX3("B1_DESC")[1],,)

		oProd:SetHeaderBreak(.T.)	
		oProd:SetHeaderSection(.T.)

		oFat:=TRSection():New(oReport,STR0003,{"FAT","TRB"},,)
		TRCell():New(oFat,"FATO"		,"FAT",'FATO MOTIVADOR DO PEDIDO',,200,,)

		oFat:SetHeaderBreak(.T.)
		oFat:SkipLine(10)

		oEnt:=TRSection():New(oReport,STR0003,{"ENT","TRB","CDM"},,)	
		oPosition:=TRPosition():New(oEnt,"CDM",3,{|| xFilial("CDM") + ENT->DOCENT + ENT->SERIEE})

		//Informações do documento de entrada - Quadro 04
		TRCell():New(oEnt,"IEFORN"		,"ENT",'Inscr. Est.',,TamSX3("A2_CGC")[1],,)
		TRCell():New(oEnt,"UFENT"		,"ENT",'U.F.',,02,,)
		TRCell():New(oEnt,"DOCENT"		,"ENT",'Nº Nota Fiscal',,TamSX3("FT_NFISCAL")[1],,)
		TRCell():New(oEnt,"DTENT"		,"ENT",'Data',,12,,)
		TRCell():New(oEnt,"QTENT" 		,"ENT",'Qtd.Ent.',"@E 99999999.99",11,,)
		TRCell():New(oEnt,"BSENT"		,"ENT",'Base Calc.',"@E 99,999,999,999.99",17,,)
		TRCell():New(oEnt,"ICMS"		,"ENT",'ICMS',"@E 99,999,999,999.99",17,,)
		TRCell():New(oEnt,"BSCRUNIT"	,"ENT",'B.C.Ret.Unit.',"@E 99,999,999,999.99",17,,)
		TRCell():New(oEnt,"ICMSRET"		,"ENT",'ICMS ST',"@E 99,999,999,999.99",20,,)
		TRCell():New(oEnt,"DUAAUT"		,"ENT",'GNRE/DUA Autoriz.',,14,,) 
		TRCell():New(oEnt,"DUABCO"		,"ENT",'GNRE/DUA Banco',,06,,) 
		TRCell():New(oEnt,"DUAAGE"		,"ENT",'GNRE/DUA Agencia',,14,,) 

		oBreak := TRBreak():New(oEnt,'1',"",.T.,,.F.)
		TRFunction():New(oEnt:Cell("QTENT"),NIL,"SUM",oBreak,,,,.F.,.F.) //"Totalizador do valor de ST"
		TRFunction():New(oEnt:Cell("BSENT"),NIL,"SUM",oBreak,,,,.F.,.F.) //"Totalizador do valor de ST"	
		TRFunction():New(oEnt:Cell("ICMS"),NIL,"SUM",oBreak,,,,.F.,.F.) //"Totalizador do valor de ST"
		TRFunction():New(oEnt:Cell("BSCRUNIT"),NIL,"SUM",oBreak,,,,.F.,.F.) //"Totalizador do valor de ST"	
		TRFunction():New(oEnt:Cell("ICMSRET"),NIL,"SUM",oBreak,,,,.F.,.F.) //"Totalizador do valor de ST"	


		oEnt:SetHeaderBreak(.T.)
		oEnt:SetTitle('NOTAS FISCAIS DE ENTRADA')
		oEnt:lHeaderVisible := .T.
		oEnt:SkipLine(10)

		//Informações do documento de saída internas - Quadro 05
		oEst:=TRSection():New(oReport,STR0003,{"EST","TRB","CDM"},,)	
		oPosition:=TRPosition():New(oEst,"CDM",2,{|| xFilial("CDM") + EST->DOCENT + EST->SERIEE})

		TRCell():New(oEst,"IEFORN"		,"EST",'Inscr. Est.',,TamSX3("A2_CGC")[1],,)
		TRCell():New(oEst,"UFENT"		,"EST",'U.F.',,02,,)
		TRCell():New(oEst,"DOCENT"		,"EST",'Nº Nota Fiscal',,TamSX3("FT_NFISCAL")[1],,)
		TRCell():New(oEst,"DTENT"		,"EST",'Data',,12,,)
		TRCell():New(oEst,"QTENT" 		,"EST",'Qtd.Ent.',"@E 99999999.99",11,,)
		TRCell():New(oEst,"BSENT"		,"EST",'Base Calc.',"@E 99,999,999,999.99",17,,)
		TRCell():New(oEst,"ICMS"		,"EST",'ICMS',"@E 99,999,999,999.99",17,,)
		TRCell():New(oEst,"BSCRUNIT"	,"EST",'B.C.Ret.Unit.',"@E 99,999,999,999.99",17,,)
		TRCell():New(oEst,"ICMSRET"		,"EST",'ICMS ST',"@E 99,999,999,999.99",20,,)

		oBreak1 := TRBreak():New(oEst,'1',"",.T.,,.F.)
		TRFunction():New(oEst:Cell("ICMS"),NIL,"SUM",oBreak1,,,,.F.,.F.) //"Totalizador do valor de ST"
		TRFunction():New(oEst:Cell("ICMSRET"),NIL,"SUM",oBreak1,,,,.F.,.F.) //"Totalizador do valor de ST"	
		
		oEst:SetHeaderBreak(.T.)	
		oEst:SetTitle('MERCADORIA OBJETO DO PEDIDO')
		oEst:lHeaderVisible := .T.
		oEst:SkipLine(10)

		//Informações do documento de saída interestaduais - Quadro 06
		oInt:=TRSection():New(oReport,STR0003,{"INT","TRB","CDM"},,)
		oPosition:=TRPosition():New(oInt,"CDM",2,{|| xFilial("CDM") + INT->DOCSAI + INT->SERIES})
				
		TRCell():New(oInt,"IECLI"		,"INT",'Inscr. Est.',,TamSX3("A2_CGC")[1],,)
		TRCell():New(oInt,"UFSAI"		,"INT",'U.F.',,02,,)
		TRCell():New(oInt,"DOCSAI"		,"INT",'Nº Nota Fiscal',,TamSX3("FT_NFISCAL")[1],,)
		TRCell():New(oInt,"DTSAI"		,"INT",'Data',,12,,)
		TRCell():New(oInt,"QTSAI" 		,"INT",'Qtd.Ent.',"@E 99999999.99",11,,)
		TRCell():New(oInt,"BSSAI"		,"INT",'Base Calc.',"@E 99,999,999,999.99",17,,)
		TRCell():New(oInt,"ICMS"		,"INT",'ICMS',"@E 99,999,999,999.99",17,,)
		TRCell():New(oInt,"BSCRUNIT"	,"INT",'B.C.Ret.Unit.',"@E 99,999,999,999.99",17,,)
		TRCell():New(oInt,"ICMSRET"		,"INT",'ICMS ST',"@E 99,999,999,999.99",20,,)
		TRCell():New(oInt,"DUAAUT"		,"INT",'GNRE/DUA Autoriz.',,14,,) 
		TRCell():New(oInt,"DUABCO"		,"INT",'GNRE/DUA Banco',,06,,) 
		TRCell():New(oInt,"DUAAGE"		,"INT",'GNRE/DUA Agencia',,14,,) 

		oBreak2 := TRBreak():New(oInt,'1',"",.T.,,.F.)
		TRFunction():New(oInt:Cell("ICMS"),NIL,"SUM",oBreak2,,,,.F.,.F.) //"Totalizador do valor de ST"
		TRFunction():New(oInt:Cell("ICMSRET"),NIL,"SUM",oBreak2,,,,.F.,.F.) //"Totalizador do valor de ST"	

		oInt:SetHeaderBreak(.T.)	
		oInt:SetTitle('NOTA FISCAL DE SAÍDA')
		oInt:lHeaderVisible := .T.
		oInt:SkipLine(10)
	ElseIf MV_PAR06 == 2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria modelo Padrão Genérico para os Estados não homologados.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oQuadro:=TRSection():New(oReport,STR0003,{"TRB","CDM"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/,,,,.T.)
		oQuadro:SetHeaderSection(.T.)
		oQuadro:SetLeftMargin(20)	
		
		//Secao Relatorio
		oRelat:=TRSection():New(oReport,STR0003,{"TRB"},,)			
		
		//Informações do Contribuinte - Quadro 01
		TRCell():New(oRelat,"RazSoc"	,"TRB",'REQUERENTE',,TamSX3("A1_NOME")[1],,)  	
		TRCell():New(oRelat,"IE"		,"TRB",'I.E.',,TamSX3("A1_INSCR")[1],,)
		TRCell():New(oRelat,"CNPJ"		,"TRB",'CNPJ',,TamSX3("A1_CGC")[1],,)
		TRCell():New(oRelat,"PERIOD"	,"TRB",'PERIODO APUR.',,30,,)
	

		oRelat:SetHeaderBreak(.T.)	
		oRelat:SetHeaderSection(.T.)

        oProd:=TRSection():New(oReport,STR0003,{"PROD","TRB"},,)
				
		TRCell():New(oProd,"PRODUT"	,"PROD",'Produto',,TamSX3("B1_DESC")[1],,)

		oProd:SetHeaderBreak(.T.)	
		oProd:SetHeaderSection(.T.)

        oEnt:=TRSection():New(oReport,STR0003,{"ENT","TRB","CDM"},,)
        oPosition:=TRPosition():New(oEnt,"CDM",3,{|| xFilial("CDM") + ENT->DOCENT + ENT->SERIEE + ENT->PRODUTO})

		//Informações do documento de entrada - Quadro 04
		TRCell():New(oEnt,"CGCFORN"		,"ENT",'CNPJ Forn.',,TamSX3("A2_CGC")[1],,)
		TRCell():New(oEnt,"UFENT"		,"ENT",'U.F.',,02,,)
		TRCell():New(oEnt,"DOCENT"		,"ENT",'Nº Nota Fiscal',,TamSX3("FT_NFISCAL")[1],,)
		TRCell():New(oEnt,"DTENT"		,"ENT",'Data',,12,,)
		TRCell():New(oEnt,"QTENT" 		,"ENT",'Qtd.Ent.',"@E 99999999.99",11,,)
		TRCell():New(oEnt,"BSENT"		,"ENT",'Base Calc.',"@E 99,999,999,999.99",17,,)
		TRCell():New(oEnt,"ICMS"		,"ENT",'ICMS',"@E 99,999,999,999.99",17,,)
		TRCell():New(oEnt,"BSCR"		,"ENT",'B.C.Ret.',"@E 99,999,999,999.99",17,,)
		TRCell():New(oEnt,"ICMSRET"		,"ENT",'ICMS ST',"@E 99,999,999,999.99",20,,)
		TRCell():New(oEnt,"BSCRUN"		,"ENT",'B.C.Ret. Unit.',"@E 99,999,999,999.99",17,,) 
		TRCell():New(oEnt,"ICMSRUN"		,"ENT",'ICMS ST UNIT.',,06,,) 

		oEnt:SetHeaderBreak(.T.)
		oEnt:SetTitle('NOTAS FISCAIS DE ENTRADA')
		oEnt:lHeaderVisible := .T.
		oEnt:SkipLine(10)

		//Informações do documento de saída internas - Quadro 05
		oEst:=TRSection():New(oReport,STR0003,{"EST","TRB","CDM"},,)	
		oPosition:=TRPosition():New(oEst,"CDM",2,{|| xFilial("CDM") + EST->DOCSAI + EST->SERIES})
		
		TRCell():New(oEst,"CGCCLI"		,"EST",'CNPJ Cli.',,TamSX3("A1_CGC")[1],,)
		TRCell():New(oEst,"UFSAI"		,"EST",'U.F.',,02,,)
		TRCell():New(oEst,"DOCSAI"		,"EST",'Nº Nota Fiscal',,TamSX3("FT_NFISCAL")[1],,)
		TRCell():New(oEst,"DTSAI"		,"EST",'Data',,12,,)
		TRCell():New(oEst,"QTSAI" 		,"EST",'Qtd.Ent.',"@E 99999999.99",11,,)
		TRCell():New(oEst,"BSSAI"		,"EST",'Base Calc.',"@E 99,999,999,999.99",17,,)
		TRCell():New(oEst,"ICMS"		,"EST",'ICMS',"@E 99,999,999,999.99",17,,)
		TRCell():New(oEst,"BSCRUNIT"	,"EST",'B.C.Ret.Unit.',"@E 99,999,999,999.99",17,,)
		TRCell():New(oEst,"ICMSRET"		,"EST",'ICMS ST',"@E 99,999,999,999.99",20,,)

		oBreak := TRBreak():New(oEst,'1',"",.T.,,.F.)
		TRFunction():New(oEst:Cell("ICMSRET"),NIL,"SUM",oBreak,,,,.F.,.F.) //"Totalizador do valor de ST"
		
		oEst:SetHeaderBreak(.T.)	
		oEst:SetTitle('NOTAS FISCAIS DE SAIDAS INTERNAS')
		oEst:lHeaderVisible := .T.
		oEst:SkipLine(10)

		//Informações do documento de saída interestaduais - Quadro 06
		oInt:=TRSection():New(oReport,STR0003,{"INT","TRB","CDM"},,)
		oPosition:=TRPosition():New(oInt,"CDM",2,{|| xFilial("CDM") + INT->DOCSAI + INT->SERIES})

		TRCell():New(oInt,"CGCCLI"		,"INT",'CNPJ Cli.',,TamSX3("A1_CGC")[1],,)
		TRCell():New(oInt,"UFSAI"		,"INT",'U.F.',,02,,)
		TRCell():New(oInt,"DOCSAI"		,"INT",'Nº Nota Fiscal',,TamSX3("FT_NFISCAL")[1],,)
		TRCell():New(oInt,"DTSAI"		,"INT",'Data',,12,,)
		TRCell():New(oInt,"QTSAI" 		,"INT",'Qtd.Ent.',"@E 99999999.99",11,,)
		TRCell():New(oInt,"BSSAI"		,"INT",'Base Calc.',"@E 99,999,999,999.99",17,,)
		TRCell():New(oInt,"ICMS11"		,"INT",'ICMS 1,1 %',"@E 99,999,999,999.99",17,,)
		TRCell():New(oInt,"ICMS37"		,"INT",'ICMS 3,7 %',"@E 99,999,999,999.99",17,,)
		TRCell():New(oInt,"ICMS53"		,"INT",'ICMS 5,3 %',"@E 99,999,999,999.99",17,,)

		oBreak1 := TRBreak():New(oInt,'1',"",.T.,,.F.)
		TRFunction():New(oInt:Cell("ICMS11"),NIL,"SUM",oBreak1,,,,.F.,.F.) //"Totalizador do valor de ST"
		TRFunction():New(oInt:Cell("ICMS37"),NIL,"SUM",oBreak1,,,,.F.,.F.) //"Totalizador do valor de ST"	
		TRFunction():New(oInt:Cell("ICMS53"),NIL,"SUM",oBreak1,,,,.F.,.F.) //"Totalizador do valor de ST"	

		oInt:SetHeaderBreak(.T.)	
		oInt:SetTitle('NOTA FISCAL DE SAÍDA INTERESTADUAIS')
		oInt:lHeaderVisible := .T.
		oInt:SkipLine(10)

		//Informações do documento de saída interestaduais - Quadro 06
		oFat:=TRSection():New(oReport,STR0003,{"FAT","TRB"},,)
		
		TRCell():New(oFat,"TOTALA"		,"FAT",'ICMS-ST a recolher nas saídas internas  - CÓDIGO DE RECEITA 138-4 R$',"@E 99,999,999,999.99",17,,)
		TRCell():New(oFat,"TOTALBCD"	,"FAT",'ICMS a recolher nas saídas interestaduais COMPETE - CÓDIGO DE RECEITA 380-8 R$ ',"@E 99,999,999,999.99",17,,)

	EndIf
Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria modelo Padrão Genérico para os Estados não homologados.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oQuadro:=TRSection():New(oReport,STR0003,{"TRB","CDM"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/,,,,.T.)
	oQuadro:SetHeaderSection(.T.)
	oQuadro:SetLeftMargin(20)	
	
	//Secao Relatorio
	oRelat:=TRSection():New(oReport,STR0003,{"TRB","CDM"},,)
	oPosition:=TRPosition():New(oRelat,"CDM",2,{|| xFilial("CDM") + TRB->DOCSAI + TRB->SERIES})
	
	TRCell():New(oRelat,"DOCSAI"	,"TRB",STR0007,,TamSX3("F2_DOC")[1],,) //"Nota Fiscal"
	TRCell():New(oRelat,"SERIES"  	,"TRB",STR0014,,03,,) //"Serie"
	TRCell():New(oRelat,"DTSAI"		,"TRB",STR0006,,08,,) //"Dt. Emissao"
	TRCell():New(oRelat,"ITSAI"		,"TRB",STR0015,,02,,) //"Nota Fiscal"
	TRCell():New(oRelat,"PRODUT"	,"TRB",STR0016,,TamSX3("B1_COD")[1],,) //"Codigo"
	TRCell():New(oRelat,"QTDVDS" 	,"TRB",STR0010,"@E 99,999,999,999.99",11,,) //"Quantidade"	
	TRCell():New(oRelat,"HIPOTESE"	,"TRB",STR0018,,01,,) //"Hipotese"	
	TRCell():New(oRelat,"DTENT"		,"TRB",STR0017,,08,,) //"Dt. Entrada"
	TRCell():New(oRelat,"DOCENT"	,"TRB",STR0023,,TamSX3("F2_DOC")[1],,) //"Nota Fiscal"
	TRCell():New(oRelat,"FORNEC"	,"TRB",STR0008,,06,,) //"Fornecedor"
	TRCell():New(oRelat,"BSERET"	,"TRB",  Iif(lIcmsProp,"BC.IcmsSt Ent.",STR0009)  ,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Base de Calculo ICMS ST"
	TRCell():New(oRelat,"QTDENT" 	,"TRB",STR0010,"@E 99,999,999,999.99",14,,) //"Quantidade"
	TRCell():New(oRelat,"ICMSST"	,"TRB",STR0026,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor ICMSST"
	TRCell():New(oRelat,"BASRES"	,"TRB",Iif(lIcmsProp,"BC.Ressar.",STR0011),"@E 99,999,999,999.99",14,,) //"Base de Calculo do Ressarcimento"
	TRCell():New(oRelat,"VALRES"   	,"TRB",STR0012,"@E 999,999,999.99",14,,) //"Valor do Ressarcimento"
	TRCell():New(oRelat,"VALCUL"   	,"TRB", Iif(lIcmsProp,"Ressarc.ST","Val.Acum.Ressar."),"@E 999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Acumulado do Ressarcimento"
	
	IF lAgrupaHip // Irá fazer agrupamento e quebra de página por código de hipótese.
		oBreak := TRBreak():New(oRelat,oRelat:Cell("HIPOTESE"),"",.T.,,.T.)
		TRFunction():New(oRelat:Cell("HIPOTESE"),NIL,"MAX",oBreak,,,,.F.,.F.) //"Hipotese"
	
		TRFunction():New(oRelat:Cell("VALCUL"),NIL,"MAX",oBreak,,,,.F.,.F.) //"Totalizador do valor de ST"
		oRelat:SetHeaderBreak(.T.)
	EndIF

EndIF

Return(oReport)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Natalia Antonucci      ³ Data ³31/10/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os  ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportPrint(oReport,cMVEstado)

Local oQuadro		:= oReport:Section(1)
Local oRelat		:= oReport:Section(2)
Local oProd		
Local oSai
Local oTFont 		:= TFont():New('Arial',,09,.T.)
Local lAgrupaHip	:= Iif(MV_PAR03 == 1  .AND. cMVEstado=='SC',.T.,.F.)
Local cArqRel2	:= ''
Local cArqRel3	:= ''
Private oTempProd	:= ""
Private oTempRel	:= "" 
Private oTempFat	:= "" 
Private oTempEnt	:= ""
Private oTempEst	:= ""
Private oTempInt	:= ""

If cMVEstado == 'MG'
	cArqRel2	:= TabTempProd()  
	cArqRel3	:= TabTempSai()
	oProd		:= oReport:Section(3)
	oSai		:= oReport:Section(4)
Elseif cMVEstado == 'ES'
	If MV_PAR06 == 1
		oProd		:= oReport:Section(3)
		oFat		:= oReport:Section(4)
		oEnt		:= oReport:Section(5)
		oEst		:= oReport:Section(6)
		oInt		:= oReport:Section(7)
	ElseIf MV_PAR06 == 2
		oProd		:= oReport:Section(3)
		oEnt		:= oReport:Section(4)
		oEst		:= oReport:Section(5)
		oInt		:= oReport:Section(6)
		oFat		:= oReport:Section(7)
	EndIf
EndIF


SelRelR017(cMVEstado,mv_par01,mv_par02)

oQuadro:Init()
IF !cMVEstado == 'MG'
	If cMVEstado $ 'RS'
		oReport:Say(300,20,STR0019,oTFont)
		oReport:Say(350,20,STR0020,oTFont)
		oReport:Say(400,20,STR0021,oTFont)
		oReport:Say(450,20,STR0022,oTFont)
	Elseif cMVEstado == 'SC'
	 	IF lAgrupaHip 	
		 	oReport:Say(300,20,STR0031,oTFont)
			oReport:Say(350,20,STR0032,oTFont)
			oReport:Say(400,20,STR0033,oTFont)	
			oReport:Say(300,1200,STR0034,oTFont)
			oReport:Say(350,1200,STR0035,oTFont)
			oReport:Say(400,1200,STR0036,oTFont)
		Else
		 	oReport:Say(300,20,STR0024,oTFont)
			oReport:Say(350,20,STR0025,oTFont) 
		Endif	

	Elseif cMVEstado == 'PR'
		oReport:Say(300,20,STR0029,oTFont)
	ElseIf cMVEstado == 'GO'
		oReport:Say(300,20,STR0024,oTFont)
	Elseif cMVEstado == 'RJ'
		 oReport:Say(300,20,STR0024,oTFont)
		oReport:Say(350,20,STR0025,oTFont)
	ElseIf cMVEstado == 'BA'
		oReport:Say(300,20,STR0024,oTFont)
		Else
			oReport:Say(300,20,STR0024,oTFont)
			oReport:Say(350,20,STR0025,oTFont)
		
	EndIf	
EndIF

oQuadro:Finish()
oReport:SkipLine(10)    

oRelat:Print()
IF cMVEstado == 'MG'
	//As secoes 3 e 4 serão impressas somente para o Estado de Minas Gerais
	oReport:Section(3):Init()
	oProd:Print()
	oReport:Section(4):Init()
	oSai:Print()
ElseIf cMVEstado == 'ES'
	If MV_PAR06 == 1
		oReport:Section(3):Init()
		oProd:Print()
		oReport:Section(4):Init()
		oFat:Print()
		oReport:Section(5):Init()
		oEnt:Print()
		oReport:Section(6):Init()
		oEst:Print()
		oReport:Section(7):Init()
		oInt:Print()
	ElseIf MV_PAR06 == 2
		oReport:Section(3):Init()
		oProd:Print()
		oReport:Section(4):Init()
		oEnt:Print()
		oReport:Section(5):Init()
		oEst:Print()
		oReport:Section(6):Init()
		oInt:Print()
		oReport:Section(7):Init()
		oFat:Print()
	EndIf
EndIF

TRB->(DbCloseArea())
FErase(cArqRel+GetDBExtension())
FErase(cArqRel+IndexExt())

If cMVEstado == 'MG'
	//Somente para Minas Gerais serão deletadas estas tabelas.
	PROD->(DbCloseArea())
	FErase(cArqRel2+GetDBExtension())
	FErase(cArqRel2+IndexExt())	
	
	SAI->(DbCloseArea())
	FErase(cArqRel3+GetDBExtension())
	FErase(cArqRel3+IndexExt())

ElseIf cMVEstado == 'ES'

	oTempProd:Delete()
	oTempRel:Delete()
	oTempFat:Delete()
	oTempEnt:Delete()
	oTempEst:Delete()
	oTempInt:Delete()

EndIF


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SelRelR017   ³Autor ³ Natalia Antonucci    ³Data³31/10/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Seleciona dados para emissao do relatorio 		          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Function SelRelR017(cMVEstado,dInicial,dFinal,lApur)
Local aCampos, lRet
Local nTotal 	:= 0
Local nValor 	:= 0
Local nTotICMS 	:= 0
Local cHipotese	:= ""
Local nAlq 		:= SuperGetMv("MV_ICMPAD") 
Local lAgrupaHip:=.F. 
Local lIcmsProp	:= .F.
Local aTotal	:= {}
Local nPos		:= {}
Local nAlqInt	:=SuperGetMv('MV_ICMPAD')
Local linclui	:= .F.
Local cDocEnt 	:= ""
Local cCgc 		:= ""
Local cProd 	:= ""
Local cFato		:= ""
Local nICMSINT	:= 0 
Local nICMSEST	:= 0 
Default lApur 	:= .F.     

If !lApur
	lAgrupaHip	:= Iif(MV_PAR03 == 1 .AND. cMVEstado == "SC",.T.,.F.) 
 	lIcmsProp	:= Iif(MV_PAR04 == 1 .AND. cMVEstado == "SC",.T.,.F.)
EndIf

lRet := .F. 

DbSelectArea("SB1")	
SB1->(DbSetOrder(1))	
SB1->(dbSeek(xFilial("SB1")+SB1->B1_COD))  
if SB1->B1_PICM<>0 	
	nAlq := SB1->B1_PICM    
endif      

If cMVEstado == 'MG'
	aCampos:={{"NCM"      ,"C", TamSX3("B1_POSIPI")[1],0},;
	          {"PRODUTO"  ,"C", TamSX3("B1_DESC")[1],0},;
	          {"DESCRPROD","C", TamSX3("B1_DESC")[1],0},;
	          {"DOCENT"   ,"C", TamSX3("F1_DOC")[1],0},;
	          {"EMISSAOE" ,"D", 08,0},;
	          {"CFOP"	  ,"C", 04,0},;
	          {"QTDEE"	  ,"N", 14,2},;
	          {"VLPROD"   ,"N", 14,2},;
	          {"BASEENT"  ,"N", 14,2},;
	          {"ALIQ"     ,"N", 05,2},;
	          {"ICMSP"    ,"N", 14,2},;
	          {"DESP"	  ,"N", 14,2},;
	          {"MVA"	  ,"N", 6,2},;
	          {"BASEENTST","N", 14,2},;
	          {"ALIQI"	  ,"N", 5,2},;
	          {"ICMSRET"  ,"N", 14,2},;
	          {"DOCSAI"   ,"C", TamSX3("F2_DOC")[1],0},;
	          {"EMISSAOS" ,"D", 08,0},;
	          {"QTDES"	  ,"N", 14,2},;
	          {"CALCICMS1","N", 14,2},;
	          {"CALCICMS2","N", 14,2},;
	          {"CALCICMS3","N", 14,2},;
	          {"CALCICMS4","N", 14,2},;
	          {"SERIES"   ,"C", 03,0},;
	          {"SERIEE"   ,"C", 03,0}}
		
	cArqRel := CriaTrab(aCampos)
	dbUseArea(.T.,, cArqRel, "TRB" )	
	IndRegua("TRB",cArqRel,"NCM+DTOS(EMISSAOE)+DOCENT")


Elseif cMVEstado == 'ES'
	If MV_PAR06 == 1
		aCamposQ1:={ {"RazSoc","C", TamSX3("A1_NOME")[1],0},; //Quadro01
		             {"IE"    ,"C", TamSX3("A1_INSCR")[1],0},;//Quadro01
		             {"CNPJ"  ,"C", TamSX3("A1_CGC")[1],0},; 	//Quadro01
		             {"PED"   ,"C", 30,0},;
		             {"ANO"   ,"C", 30,0}}

		aCamposQ2:={ {"PRODUT"     	 	,"C", TamSX3("B1_DESC")[1],0}} //Quadro02

		aCamposQ3:={ {"FATO"     	 		,"C", 200,0}}
		
		aCamposQ4:={ {"IEFORN"	   	,"C", TamSX3("A2_INSCR")[1],0},;	//Quadro03
					 {"UFENT"      	,"C", TamSX3("CDM_UFENT")[1],0},;//Quadro03 
					 {"DOCENT"     	,"C", TamSX3("F1_DOC")[1],0},;	//Quadro03 
					 {"DTENT"      	,"D", 08,0},;					//Quadro03
					 {"QTENT"     	,"N", 14,2},;					//Quadro03
					 {"BSENT"     	,"N", TamSX3("CDM_BSENT")[1],0},;//Quadro03
					 {"ICMS"      	,"N", 14,2},;					//Quadro03
					 {"BSCRUNIT"    ,"N", 14,2},;					//Quadro03
					 {"ICMSRET"     ,"N", 14,2},;
					 {"DUAAUT"     	,"C", 14,0},;
					 {"DUABCO"     	,"C", 06,0},;
					 {"DUAAGE"     	,"C", 14,0},;
					 {"SERIEE"     	,"C", 03,0}}


		aCamposQ5:={ {"IEFORN"	    ,"C", TamSX3("A2_INSCR")[1],0},;	//Quadro03
					 {"UFENT"      	,"C", TamSX3("CDM_UFENT")[1],0},;//Quadro03 
					 {"DOCENT"     	,"C", TamSX3("F1_DOC")[1],0},;	//Quadro03 
					 {"DTENT"      	,"D", 08,0},;					//Quadro03
					 {"QTENT"    	,"N", 14,2},;					//Quadro03
					 {"BSENT"    	,"N", TamSX3("CDM_BSENT")[1],0},;//Quadro03
					 {"ICMS"      	,"N", 14,2},;					//Quadro03
					 {"BSCRUNIT"   	,"N", 14,2},;					//Quadro03
					 {"ICMSRET"    	,"N", 14,2},;
					 {"SERIEE"     	,"C", 03,0}}


		aCamposQ6:={ {"IECLI"	    ,"C", TamSX3("A1_INSCR")[1],0},;	//Quadro03
					 {"UFSAI"      	,"C", TamSX3("CDM_UFSAI")[1],0},;//Quadro03 
				     {"DOCSAI"     	,"C", TamSX3("F2_DOC")[1],0},;	//Quadro03 
					 {"DTSAI"      	,"D", 08,0},;					//Quadro03
					 {"QTSAI"     	,"N", 14,2},;					//Quadro03
					 {"BSSAI"     	,"N", TamSX3("CDM_BSSAI")[1],0},;//Quadro03
					 {"ICMS"      	,"N", 14,2},;					//Quadro03
				 	 {"BSCRUNIT"    ,"N", 14,2},;					//Quadro03
				 	 {"ICMSRET"     ,"N", 14,2},;					//Quadro03
					 {"DUAAUT"     	,"C", 14,0},;
					 {"DUABCO"     	,"C", 06,0},;
					 {"DUAAGE"     	,"C", 14,0},;
					 {"SERIES"     	,"C", 03,0}}					//Quadro03


		oTempRel 	:= FWTemporaryTable():New( "TRB" )
		oTempRel:SetFields( aCamposQ1 )
		oTempRel:AddIndex("01", {"CNPJ"} )
		oTempRel:Create()

		oTempProd	:= FWTemporaryTable():New( "PROD" )
		oTempProd:SetFields( aCamposQ2 )
		oTempProd:AddIndex("01", {"PRODUT"} )
		oTempProd:Create()

		oTempFat 	:= FWTemporaryTable():New( "FAT" )
		oTempFat:SetFields( aCamposQ3 )
		oTempFat:Create()
		
		oTempEnt	:= FWTemporaryTable():New( "ENT" )
		oTempEnt:SetFields( aCamposQ4 )
		oTempEnt:AddIndex("01", {"DOCENT"} )
		oTempEnt:Create()

		oTempEst	:= FWTemporaryTable():New( "EST" )
		oTempEst:SetFields( aCamposQ5 )
		oTempEst:AddIndex("01", {"DOCENT"} )
		oTempEst:Create()

		oTempInt	:= FWTemporaryTable():New( "INT" )
		oTempInt:SetFields( aCamposQ6 )
		oTempInt:AddIndex("01", {"DOCSAI"} )
		oTempInt:Create()

	ElseIf MV_PAR06 == 2

		aCamposQ1:={ {"RazSoc","C", TamSX3("A1_NOME")[1],0},; //Quadro01
		             {"IE"    ,"C", TamSX3("A1_INSCR")[1],0},;//Quadro01
		             {"CNPJ"  ,"C", TamSX3("A1_CGC")[1],0},; 	//Quadro01
		             {"PERIOD","C", 30,0}}
		

		aCamposQ2:= { {"PRODUT"     	 	,"C", TamSX3("B1_DESC")[1],0}} //Quadro02

		aCamposQ3:= { {"TOTALA"     	 		,"N", 14,2},;
					  {"TOTALBCD"     	 		,"N", 14,2}}
	
		aCamposQ4:= { {"CGCFORN"	   	,"C", TamSX3("A2_CGC")[1],0},;	//Quadro03
					  {"UFENT"      	,"C", TamSX3("CDM_UFENT")[1],0},;//Quadro03 
					  {"DOCENT"      	,"C", TamSX3("F1_DOC")[1],0},;	//Quadro03 
					  {"DTENT"      	,"D", 08,0},;					//Quadro03
					  {"QTENT"     		,"N", 14,2},;					//Quadro03
					  {"BSENT"     	 	,"N", TamSX3("CDM_BSENT")[1],0},;//Quadro03
					  {"ICMS"      		,"N", 14,2},;					//Quadro03
					  {"BSCR"   	  	,"N", 14,2},;					//Quadro03
					  {"ICMSRET"      	,"N", 14,2},;
					  {"BSCRUN"      	,"N", 14,2},;
					  {"ICMSRUN"      	,"N", 14,2},;
					  {"SERIEE"     	,"C", 03,0}}					  
					  
		aCamposQ5:= { {"CGCCLI"	     	,"C", TamSX3("A1_CGC")[1],0},;	//Quadro03
					  {"UFSAI"      	,"C", TamSX3("CDM_UFSAI")[1],0},;//Quadro03 
					  {"DOCSAI"      	,"C", TamSX3("F2_DOC")[1],0},;	//Quadro03 
					  {"DTSAI"      	,"D", 08,0},;					//Quadro03
					  {"QTSAI"     		,"N", 14,2},;					//Quadro03
					  {"BSSAI"     	 	,"N", TamSX3("CDM_BSSAI")[1],0},;//Quadro03
					  {"ICMS"      		,"N", 14,2},;					//Quadro03
					  {"BSCRUNIT"     	,"N", 14,2},;					//Quadro03
					  {"ICMSRET"      	,"N", 14,2},;
					  {"SERIES"     	,"C", 03,0}}					//Quadro03

		aCamposQ6:= { {"CGCCLI"	     	,"C", TamSX3("A1_CGC")[1],0},;	//Quadro03
					  {"UFSAI"      	,"C", TamSX3("CDM_UFSAI")[1],0},;//Quadro03 
					  {"DOCSAI"      	,"C", TamSX3("F2_DOC")[1],0},;	//Quadro03 
					  {"DTSAI"      	,"D", 08,0},;					//Quadro03
					  {"QTSAI"     		,"N", 14,2},;					//Quadro03
					  {"BSSAI"     	 	,"N", TamSX3("CDM_BSSAI")[1],0},;//Quadro03
					  {"ICMS11"     	,"N", 14,2},;					//Quadro03
					  {"ICMS37"     	,"N", 14,2},;					//Quadro03
					  {"ICMS53"     	,"N", 14,2},;
					  {"SERIES"     	,"C", 03,0}} 					//Quadro03

		oTempRel 	:= FWTemporaryTable():New( "TRB" )
		oTempRel:SetFields( aCamposQ1 )
		oTempRel:AddIndex("01", {"CNPJ"} )
		oTempRel:Create()

		oTempProd	:= FWTemporaryTable():New( "PROD" )
		oTempProd:SetFields( aCamposQ2 )
		oTempProd:AddIndex("01", {"PRODUT"} )
		oTempProd:Create()

		oTempFat 	:= FWTemporaryTable():New( "FAT" )
		oTempFat:SetFields( aCamposQ3 )
		oTempFat:Create()
		
		oTempEnt	:= FWTemporaryTable():New( "ENT" )
		oTempEnt:SetFields( aCamposQ4 )
		oTempEnt:AddIndex("01", {"DOCENT"} )
		oTempEnt:Create()

		oTempEst	:= FWTemporaryTable():New( "EST" )
		oTempEst:SetFields( aCamposQ5 )
		oTempEst:AddIndex("01", {"DOCSAI"} )
		oTempEst:Create()

		oTempInt	:= FWTemporaryTable():New( "INT" )
		oTempInt:SetFields( aCamposQ6 )
		oTempInt:AddIndex("01", {"DOCSAI"} )
		oTempInt:Create()

	EndIf
Else

	aCampos:={ {"DOCSAI" ,"C", TamSX3("F2_DOC")[1],0},;
	           {"SERIES"       ,"C", 03,0},;
	           {"DTSAI"        ,"D", 08,0},;
               {"ITSAI"        ,"C", 02,0},;
               {"PRODUT"       ,"C", TamSX3("B1_COD")[1],0},;
               {"QTDVDS"       ,"N", 11,2},;
               {"HIPOTESE"     ,"C", 01,0},;
	           {"DTENT"        ,"D", 08,0},;
	           {"DOCENT"       ,"C", TamSX3("F2_DOC")[1],0},;
               {"FORNEC"       ,"C", 06,0},;
	           {"QTDENT"       ,"N", 14,2},;
	           {"BSERET"       ,"N", 14,2},;
               {"BASRES"       ,"N", 14,2},;
               {"VALRES"       ,"N", 14,2},;
	           {"VALCUL"       ,"N", 14,2},;
	           {"ICMSST"       ,"N", 14,2},;
	           {"ICMSS"        ,"N", 14,2},;
	           {"DIFERENCA"    ,"N", 11,2},;
	           {"ICMSE"        ,"N", 14,2},;
	           {"BCICMSE"      ,"N", 14,2},;
	           {"RECICMS"      ,"N", 14,2}}
	
	cArqRel := CriaTrab(aCampos)
	dbUseArea(.F.,, cArqRel, "TRB", .F., .F. )
	IF lAgrupaHip
		IndRegua("TRB",cArqRel,"HIPOTESE+DTOS(DTSAI)+DOCSAI")
	Else
		IndRegua("TRB",cArqRel,"DTOS(DTSAI)+DOCSAI")
	EndIF
EndIF

dbSelectArea("CDM")
CDM->(dbSetOrder(4))
CDM->(dbSeek(xFilial("CDM")+Dtos(dInicial), .T. )) 
While !CDM->(Eof()) .And. xFilial("CDM") == CDM->CDM_FILIAL .And. CDM->CDM_DTSAI <= dFinal
 	If CDM->CDM_TIPO $ "ML" 
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		SA1->(MsSeek(xFilial("SA1")+CDM->CDM_CLIENT+CDM->CDM_LJCLI))
		dbSelectArea("SD2")
		SD2->(DbSetOrder (3))
		SD2->(MsSeek(xFilial("SD2")+CDM->CDM_DOCSAI+CDM->CDM_SERIES+CDM->CDM_CLIENT+CDM->CDM_LJCLI))
		dbSelectArea("SD1")
		SD1->(DbSetOrder (1))                                                                                                  
		SD1->(dbSeek(xFilial("SD1")+CDM->CDM_DOCENT+CDM->CDM_SERIEE+CDM->CDM_FORNEC+CDM->CDM_LJFOR+CDM->CDM_PRODUT))
		SB1->(dbSeek(xFilial("SB1")+CDM->CDM_PRODUT))

 		If cMVEstado == 'RS'
	 		Reclock("TRB",.T.)                  
			TRB->DOCSAI		:= CDM->CDM_DOCSAI 
			TRB->SERIES		:= CDM->CDM_SERIES 
			TRB->DTSAI		:= CDM->CDM_DTSAI 
			TRB->ITSAI		:= CDM->CDM_ITSAI 
			TRB->PRODUT		:= CDM->CDM_PRODUT 
			TRB->QTDVDS		:= CDM->CDM_QTDVDS 	
			TRB->HIPOTESE	:= Iif(substr(CDM->CDM_CFSAI,1,1) == "6","1",IIf(CDM->CDM_BSSRET > 0 .OR. CDM->CDM_BASMAN > 0,"2","3"))
			TRB->DTENT		:= CDM->CDM_DTENT  
			TRB->DOCENT		:= CDM->CDM_DOCENT  
			TRB->BSERET		:= IIf(CDM->CDM_BSERET > 0,CDM->CDM_BSERET,CDM->CDM_BASMAN) 
			TRB->QTDENT		:= CDM->CDM_QTDENT 
			TRB->BASRES		:= (TRB->BSERET/CDM->CDM_QTDENT)*CDM->CDM_QTDVDS  
			TRB->VALRES		:= (TRB->BASRES *nAlq) /100   
			TRB->VALCUL		:= TRB->VALRES + nTotal      
			nTotal += TRB->VALRES
			MsUnLock()	

		ElseIf cMVEstado == 'ES'
		
			If MV_PAR06 == 1
				dbSelectArea("SF6")
				SF6->(DbSetOrder (3))
				SF6->(MsSeek(xFilial("SF6")+"1"+AvKey(SD1->D1_TIPO,"F6_TIPODOC")+CDM->CDM_DOCENT+CDM->CDM_SERIES+CDM->CDM_FORNEC+CDM->CDM_LJFOR))

				If cCgc <> SM0->M0_CGC
					cCgc:= SM0->M0_CGC
					RecLock("TRB",.T.)
					TRB->RAZSOC 	:= SM0->M0_NOME
					TRB->IE			:= SM0->M0_INSC
					TRB->CNPJ		:= SM0->M0_CGC
					TRB->PED 		:= AllTrim(MV_PAR05)
					TRB->ANO		:= SUBSTR(DtoS(MV_PAR01),1,4)
					TRB->(MsUnLock())
				EndIf

				If cProd <> SB1->B1_COD
					RecLock("PROD",.T.)
					PROD->PRODUT		:= SB1->B1_COD+" - "+SB1->B1_DESC
					PROD->(MsUnLock())
					cProd := SB1->B1_COD

					If !Empty(SD1->D1_NFORI) 
						cFato := STR0037//"1. desfazimento do negócio"
					ElseIf Substr(CDM->CDM_CFSAI,2,3) == "927"//CFOP 5927 - Lançamento efetuado a título de baixa de estoque decorrente de perda, roubo ou deterioração 
						cFato := STR0038//"2. perecimento, deterioração ou extravio da mercadoria."
					ElseIf SD2->D2_CLASFIS = '040'
						cFato := STR0039//"3. operação isenta ou não tributada destinada a consumidor"
					ElseIf Substr(CDM->CDM_CFSAI,2,3) == "901"//CFOP 5901 - Remessa para industrialização por encomenda
						cFato := STR0040//"4.operação que destine mercadoria para industrialização"
					ElseIf Substr(CDM->CDM_CFSAI,1,1) <> "5"
						cFato := STR0041//"5. operação interestadual, para comercialização, cujo imposto já tenha sido retido"
					Else 
						cFato := ""
					EndIf 
				
					RecLock("FAT",.T.)
					FAT->FATO:= cFato
					FAT->(MsUnLock())


				EndIf

				If cDocEnt <> CDM->CDM_DOCENT 
					Reclock("ENT",.T.) 
					ENT->IEFORN		:= SA2->A2_INSCR //1. CNPJ do remetente;
					ENT->UFENT		:= CDM->CDM_UFENT	//2. Unidade da Federação;
					ENT->DOCENT		:= CDM->CDM_DOCENT //3. número da nota fiscal;
					ENT->SERIEE     := CDM->CDM_SERIEE 
					ENT->DTENT		:= CDM->CDM_DTENT //4. data;
					ENT->QTENT  	:= CDM->CDM_QTDENT //5. quantidade da mercadoria;
					ENT->BSENT		:= CDM->CDM_BSENT //6. base de cálculo;
					ENT->ICMS		:= CDM->CDM_ICMENT //7. valor do ICMS;
					ENT->BSCRUNIT 	:= SD1->D1_BRICMS/CDM->CDM_QTDENT //10. BCR unitária (obtida pela divisão da BCR pela quantidade das mercadorias adquiridas); 
					ENT->ICMSRET	:= Iif(SD1->D1_ICMSRET > 0,SD1->D1_ICMSRET,SD1->D1_ICMNDES)/CDM->CDM_QTDENT //11. ICMS-R unitário (obtido pela divisão do ICMS-R pela quantidade das mercadorias adquiridas);
					ENT->DUAAUT		:= SF6->F6_AUTENT
					ENT->DUABCO		:= SF6->F6_BANCO
					ENT->DUAAGE		:= SF6->F6_AGENCIA
					ENT->(MsUnLock())
		
					cDocEnt := CDM->CDM_DOCENT 

					Reclock("EST",.T.) 
					EST->IEFORN		:= SA2->A2_INSCR //1. CNPJ do remetente;
					EST->UFENT		:= CDM->CDM_UFENT	//2. Unidade da Federação;
					EST->DOCENT		:= CDM->CDM_DOCENT //3. número da nota fiscal;
					EST->SERIEE     := CDM->CDM_SERIEE 
					EST->DTENT		:= CDM->CDM_DTENT //4. data;
					EST->QTENT  	:= CDM->CDM_QTDENT //5. quantidade da mercadoria;
					EST->BSENT		:= CDM->CDM_BSENT //6. base de cálculo;
					EST->ICMS		:= CDM->CDM_ICMENT //7. valor do ICMS;
					EST->BSCRUNIT 	:= SD1->D1_BRICMS/CDM->CDM_QTDENT //10. BCR unitária (obtida pela divisão da BCR pela quantidade das mercadorias adquiridas); 
					EST->ICMSRET	:= Iif(SD1->D1_ICMSRET > 0,SD1->D1_ICMSRET,SD1->D1_ICMNDES)/CDM->CDM_QTDENT //11. ICMS-R unitário (obtido pela divisão do ICMS-R pela quantidade das mercadorias adquiridas);
					EST->(MsUnLock())				

				EndIf

				dbSelectArea("SF6")
				SF6->(DbSetOrder (3))
				SF6->(MsSeek(xFilial("SF6")+"2"+AvKey(SD2->D2_TIPO,"F6_TIPODOC")+SD2->D2_DOC+SD2->D2_SERIE+CDM->CDM_CLIENT+CDM->CDM_LJCLI))

				Reclock("INT",.T.)    
				INT->IECLI  	:= SA1->A1_INSCR     
				INT->UFSAI		:= CDM->CDM_UFSAI         
				INT->DOCSAI		:= CDM->CDM_DOCSAI 
				INT->SERIES     := CDM->CDM_SERIES
				INT->DTSAI		:= CDM->CDM_DTSAI 
				INT->QTSAI		:= CDM->CDM_QTDVDS 	
				INT->BSSAI		:= SD2->D2_BRICMS
				INT->ICMS		:= CDM->CDM_ICMSAI
				INT->BSCRUNIT 	:= SD2->D2_BRICMS/CDM->CDM_QTDVDS
				INT->ICMSRET	:= SD2->D2_ICMSRET/CDM->CDM_QTDVDS
				INT->DUAAUT		:= SF6->F6_AUTENT
				INT->DUABCO		:= SF6->F6_BANCO
				INT->DUAAGE		:= SF6->F6_AGENCIA
				INT->(MsUnLock())	

			ElseIf MV_PAR06 == 2

				If cCgc <> SM0->M0_CGC
					cCgc:= SM0->M0_CGC
					RecLock("TRB",.T.)
					TRB->RAZSOC 	:= SM0->M0_NOME
					TRB->IE			:= SM0->M0_INSC
					TRB->CNPJ		:= SM0->M0_CGC
					TRB->PERIOD 	:= AllTrim(DtoC(MV_PAR01)) +" A "+AllTrim(DtoC(MV_PAR02))
					TRB->(MsUnLock())
				EndIf

				If cProd <> SB1->B1_COD

					RecLock("PROD",.T.)
					PROD->PRODUT		:= AllTrim(SB1->B1_COD)+" - "+AllTrim(SB1->B1_DESC)
					PROD->(MsUnLock())
					cProd := SB1->B1_COD

				EndIf

				If cDocEnt <> CDM->CDM_DOCENT 

					Reclock("ENT",.T.) 
					ENT->CGCFORN		:= SA2->A2_CGC //1. CNPJ do remetente;
					ENT->UFENT		:= CDM->CDM_UFENT	//2. Unidade da Federação;
					ENT->DOCENT		:= CDM->CDM_DOCENT //3. número da nota fiscal;
					ENT->SERIEE     := CDM->CDM_SERIEE
					ENT->DTENT		:= CDM->CDM_DTENT //4. data;
					ENT->QTENT  	:= CDM->CDM_QTDENT //5. quantidade da mercadoria;
					ENT->BSENT		:= CDM->CDM_BSENT //6. base de cálculo;
					ENT->ICMS		:= CDM->CDM_ICMENT //7. valor do ICMS;
					ENT->BSCR	 	:= SD1->D1_BRICMS //10. BCR unitária (obtida pela divisão da BCR pela quantidade das mercadorias adquiridas); 
					ENT->ICMSRET	:= Iif(SD1->D1_ICMSRET > 0,SD1->D1_ICMSRET,SD1->D1_ICMNDES) //11. ICMS-R unitário (obtido pela divisão do ICMS-R pela quantidade das mercadorias adquiridas);
					ENT->BSCRUN	 	:= SD1->D1_BRICMS/CDM->CDM_QTDENT//10. BCR unitária (obtida pela divisão da BCR pela quantidade das mercadorias adquiridas); 
					ENT->ICMSRUN	:= Iif(SD1->D1_ICMSRET > 0,SD1->D1_ICMSRET,SD1->D1_ICMNDES)/CDM->CDM_QTDENT //11. ICMS-R unitário (obtido pela divisão do ICMS-R pela quantidade das mercadorias adquiridas);
					ENT->(MsUnLock())
		
					cDocEnt := CDM->CDM_DOCENT 

				EndIf

				If Substr(CDM->CDM_CFSAI,1,1) <> "5" 
					Reclock("INT",.T.)    
					INT->CGCCLI  	:= SA1->A1_CGC     
					INT->UFSAI		:= CDM->CDM_UFSAI         
					INT->DOCSAI		:= CDM->CDM_DOCSAI 
					INT->SERIES     := CDM->CDM_SERIES
					INT->DTSAI		:= CDM->CDM_DTSAI 
					INT->QTSAI		:= CDM->CDM_QTDVDS 	
					INT->BSSAI		:= CDM->CDM_BSSAI
					INT->ICMS11		:= CDM->CDM_BSSAI*0.011
					INT->ICMS37		:= CDM->CDM_BSSAI*0.037
					INT->ICMS53		:= CDM->CDM_BSSAI*0.053
					INT->(MsUnLock())	
					
					nICMSINT += INT->ICMS11+INT->ICMS37+INT->ICMS53
				Else
					Reclock("EST",.T.) 
					EST->CGCCLI  	:= SA1->A1_CGC    
					EST->UFSAI		:= CDM->CDM_UFSAI         
					EST->DOCSAI		:= CDM->CDM_DOCSAI 
					EST->SERIES     := CDM->CDM_SERIES
					EST->DTSAI		:= CDM->CDM_DTSAI 
					EST->QTSAI		:= CDM->CDM_QTDVDS 	
					EST->BSSAI		:= CDM->CDM_BSENT
					EST->ICMS		:= CDM->CDM_ICMSAI
					EST->BSCRUNIT 	:= SD2->D2_BRICMS/CDM->CDM_QTDVDS
					EST->ICMSRET	:= SD2->D2_ICMSRET/CDM->CDM_QTDVDS
					EST->(MsUnLock())
					nICMSEST += EST->ICMSRET			
				EndIf
			EndIf

   		ElseIf cMVEstado == 'SC'			
			
			If lAgrupaHip
				cHipotese:= Hipotese("SD1", "SD2", "SA1")				
				nPos := aScan (aTotal, {|aX|aX[1]==cHipotese })
				If nPos == 0
					aAdd(aTotal, {})
					nPos := Len(aTotal)
					aAdd (aTotal[nPos], cHipotese)
					aAdd (aTotal[nPos], 0)
					aAdd (aTotal[nPos], 0)				
				EndIF				
							
			Else
				cHipotese:= Iif(substr(CDM->CDM_CFSAI,1,1) == "6","1","2")			
			EndIF
			
			nValor := SD2->D2_PRCVEN + SD2->D2_IPI + SD2->D2_VALFRE + SD2->D2_DESPESA
	 		Reclock("TRB",.T.)                 
			TRB->DOCSAI		:= CDM->CDM_DOCSAI 
			TRB->SERIES		:= CDM->CDM_SERIES 
			TRB->DTSAI		:= CDM->CDM_DTSAI 
			TRB->ITSAI		:= CDM->CDM_ITSAI 
			TRB->PRODUT		:= CDM->CDM_PRODUT 
			TRB->QTDVDS		:= CDM->CDM_QTDVDS 	
			TRB->HIPOTESE	:= cHipotese//Iif(substr(CDM->CDM_CFSAI,1,1) == "6","1","2")
			TRB->DTENT		:= CDM->CDM_DTENT  
			TRB->DOCENT		:= CDM->CDM_DOCENT  
			TRB->FORNEC		:= CDM->CDM_FORNEC  
			TRB->BSERET		:= Iif(CDM->CDM_BSERET > 0,CDM->CDM_BSERET,CDM->CDM_BASMAN) 
			TRB->QTDENT		:= CDM->CDM_QTDENT 
			TRB->BASRES		:= Iif(SA1->A1_SIMPNAC=="1",(((nValor/CDM->CDM_QTDENT)*CDM->CDM_QTDVDS)*(70/100)*(SD1->D1_MARGEM/100)),(TRB->BSERET /CDM->CDM_QTDENT)*CDM->CDM_QTDVDS)  
			TRB->VALRES		:= Iif(SA1->A1_SIMPNAC=="1",(TRB->BASRES*nAlq)/100,Iif(CDM->CDM_BASMAN > 0, ((SD1->D1_ICMNDES/CDM->CDM_QTDENT)*CDM->CDM_QTDVDS),((SD1->D1_ICMSRET/CDM->CDM_QTDENT)*CDM->CDM_QTDVDS)))  
			TRB->VALCUL		:= TRB->VALRES + Iif(lAgrupaHip,aTotal[nPos][2],nTotal)
			If lIcmsProp
				TRB->ICMSE			:= (SD1->D1_VALICM/CDM->CDM_QTDENT)*CDM->CDM_QTDVDS
				TRB->BCICMSE		:= (SD1->D1_BASEICM/CDM->CDM_QTDENT)*CDM->CDM_QTDVDS  
				TRB->RECICMS		:= TRB->ICMSE + Iif(lAgrupaHip,aTotal[nPos][3],nTotICMS)
			EndIF
				
			IF lAgrupaHip			
				aTotal[nPos][2]	+= TRB->VALRES
		    	IF lIcmsProp
		    		aTotal[nPos][3]	+= TRB->ICMSE
		    	EndIF
		    Else
		    	nTotal	+= TRB->VALRES
		    	IF lIcmsProp
		    		nTotICMS	+= TRB->ICMSE
		    	EndIF
		    EndIF
			
			MsUnLock()
		 ElseIf cMVEstado == 'PR'
	 		Reclock("TRB",.T.)                 
			TRB->DOCSAI		:= CDM->CDM_DOCSAI 
			TRB->SERIES		:= CDM->CDM_SERIES 
			TRB->DTSAI		:= CDM->CDM_DTSAI 
			TRB->ITSAI		:= CDM->CDM_ITSAI 
			TRB->PRODUT		:= CDM->CDM_PRODUT 
			TRB->QTDVDS		:= CDM->CDM_QTDVDS 
			TRB->ICMSS		:= CDM->CDM_ICMSAI 	
			TRB->HIPOTESE	:= "1"
			TRB->DTENT		:= CDM->CDM_DTENT  
			TRB->DOCENT		:= CDM->CDM_DOCENT  
			TRB->FORNEC		:= CDM->CDM_FORNEC  
			TRB->ICMSST		:= Iif(SD1->D1_ICMSRET > 0,SD1->D1_ICMSRET,SD1->D1_ICMNDES)
			TRB->QTDENT		:= CDM->CDM_QTDENT 
			TRB->ICMSE		:= SD1->D1_VALICM 
			TRB->DIFERENCA	:= Iif(SD1->D1_ICMSRET > 0,((CDM->CDM_ICMSAI/CDM->CDM_QTDVDS)-((SD1->D1_VALICM + SD1->D1_ICMSRET)/CDM->CDM_QTDENT)),((CDM->CDM_ICMSAI/CDM->CDM_QTDVDS)- CDM->CDM_ICMMAN))  
			TRB->VALRES		:= If(TRB->DIFERENCA<0,(TRB->DIFERENCA)*(-1)*TRB->QTDVDS,0)   
			TRB->VALCUL		:= TRB->VALRES + nTotal      
			nTotal += TRB->VALRES
			MsUnLock()	

		ElseIf cMVEstado == 'GO'
			nValor := SD2->D2_PRCVEN + SD2->D2_IPI + SD2->D2_VALFRE + SD2->D2_DESPESA
	 		Reclock("TRB",.T.)                 
			TRB->DOCSAI		:= CDM->CDM_DOCSAI 
			TRB->SERIES		:= CDM->CDM_SERIES 
			TRB->DTSAI		:= CDM->CDM_DTSAI 
			TRB->ITSAI		:= CDM->CDM_ITSAI 
			TRB->PRODUT		:= CDM->CDM_PRODUT 
			TRB->QTDVDS		:= CDM->CDM_QTDVDS 	
			TRB->HIPOTESE	:= "1"
			TRB->DTENT		:= CDM->CDM_DTENT  
			TRB->DOCENT		:= CDM->CDM_DOCENT  
			TRB->FORNEC		:= CDM->CDM_FORNEC  
			TRB->BSERET		:= Iif(CDM->CDM_BSERET > 0,CDM->CDM_BSERET,CDM->CDM_BASMAN) 
			TRB->QTDENT		:= CDM->CDM_QTDENT
			TRB->BASRES		:= (TRB->BSERET /CDM->CDM_QTDENT)*CDM->CDM_QTDVDS  
			TRB->VALRES		:= Iif(CDM->CDM_BASMAN > 0, ((SD1->D1_ICMNDES/CDM->CDM_QTDENT)*CDM->CDM_QTDVDS),((SD1->D1_ICMSRET/CDM->CDM_QTDENT)*CDM->CDM_QTDVDS))  
			TRB->VALCUL		:= TRB->VALRES + nTotal      
			nTotal += TRB->VALRES
			MsUnLock() 
		ElseIf cMVEstado == 'BA'
			nValor := SD2->D2_PRCVEN + SD2->D2_IPI + SD2->D2_VALFRE + SD2->D2_DESPESA
	 		Reclock("TRB",.T.)                 
			TRB->DOCSAI		:= CDM->CDM_DOCSAI 
			TRB->SERIES		:= CDM->CDM_SERIES 
			TRB->DTSAI		:= CDM->CDM_DTSAI 
			TRB->ITSAI		:= CDM->CDM_ITSAI 
			TRB->PRODUT		:= CDM->CDM_PRODUT 
			TRB->QTDVDS		:= CDM->CDM_QTDVDS 	
			TRB->HIPOTESE	:= "1"
			TRB->DTENT		:= CDM->CDM_DTENT  
			TRB->DOCENT		:= CDM->CDM_DOCENT  
			TRB->FORNEC		:= CDM->CDM_FORNEC  
			TRB->BSERET		:= Iif(CDM->CDM_BSERET > 0,CDM->CDM_BSERET,CDM->CDM_BASMAN) 
			TRB->QTDENT		:= CDM->CDM_QTDENT
			TRB->BASRES		:= (TRB->BSERET /CDM->CDM_QTDENT)*CDM->CDM_QTDVDS  
			TRB->VALRES		:= Iif(CDM->CDM_BASMAN > 0, ((SD1->D1_ICMNDES/CDM->CDM_QTDENT)*CDM->CDM_QTDVDS),((SD1->D1_ICMSRET/CDM->CDM_QTDENT)*CDM->CDM_QTDVDS))  
			TRB->VALCUL		:= TRB->VALRES + nTotal      
			nTotal += TRB->VALRES
			MsUnLock() 
		ElseIf cMVEstado == 'RJ'

			cHipotese:= Iif(SA1->A1_SIMPNAC=="1","2","1")
			
			nValor := SD2->D2_PRCVEN + SD2->D2_IPI + SD2->D2_VALFRE + SD2->D2_DESPESA
	 		Reclock("TRB",.T.)                 
			TRB->DOCSAI		:= CDM->CDM_DOCSAI 
			TRB->SERIES		:= CDM->CDM_SERIES 
			TRB->DTSAI			:= CDM->CDM_DTSAI 
			TRB->ITSAI			:= CDM->CDM_ITSAI 
			TRB->PRODUT		:= CDM->CDM_PRODUT 
			TRB->QTDVDS		:= CDM->CDM_QTDVDS 	
			TRB->HIPOTESE		:= cHipotese
			TRB->DTENT			:= CDM->CDM_DTENT  
			TRB->DOCENT		:= CDM->CDM_DOCENT  
			TRB->FORNEC		:= CDM->CDM_FORNEC  
			TRB->ICMSST		:= Iif(SD1->D1_ICMSRET > 0,SD1->D1_ICMSRET,SD1->D1_ICMNDES)
			TRB->BSERET		:= Iif(CDM->CDM_BSERET > 0,CDM->CDM_BSERET,CDM->CDM_BASMAN) 
			TRB->QTDENT		:= CDM->CDM_QTDENT 
			TRB->BASRES		:= (TRB->BSERET /CDM->CDM_QTDENT)*CDM->CDM_QTDVDS
			TRB->VALRES		:= Iif(CDM->CDM_BASMAN > 0,((SD1->D1_ICMNDES/CDM->CDM_QTDENT)*CDM->CDM_QTDVDS),((SD1->D1_ICMSRET/CDM->CDM_QTDENT)*CDM->CDM_QTDVDS))  
			TRB->VALCUL		:= TRB->VALRES + Iif(lAgrupaHip,aTotal[nPos][2],nTotal)
			If lIcmsProp
				TRB->ICMSE		:= (SD1->D1_VALICM/CDM->CDM_QTDENT)*CDM->CDM_QTDVDS
				TRB->BCICMSE	:= (SD1->D1_BASEICM/CDM->CDM_QTDENT)*CDM->CDM_QTDVDS  
				TRB->RECICMS	:= TRB->ICMSE + Iif(lAgrupaHip,aTotal[nPos][3],nTotICMS)
			EndIF
				
			IF lAgrupaHip			
				aTotal[nPos][2]	+= TRB->VALRES
		    	IF lIcmsProp
		    		aTotal[nPos][3]	+= TRB->ICMSE
		    	EndIF
		    Else
		    	nTotal	+= TRB->VALRES
		    	IF lIcmsProp
		    		nTotICMS	+= TRB->ICMSE
		    	EndIF
		    EndIF			
			MsUnLock()		
		ElseIf cMVEstado == 'MG'
				
				Reclock("TRB",.T.)
				//----------------------
				//INFORMAÇÕES DO PRODUTO
				//----------------------                 
				TRB->NCM		:= SB1->B1_POSIPI
				TRB->PRODUTO	:= CDM->CDM_PRODUT
				TRB->DESCRPROD	:= SB1->B1_DESC

				//------------------------------
				//INFORMAÇÕES DA NOTA DE ENTRADA
				//------------------------------				
				TRB->DOCENT			:= CDM->CDM_DOCENT
				TRB->SERIEE			:= CDM->CDM_SERIEE
				TRB->EMISSAOE		:= CDM->CDM_DTENT
				TRB->CFOP			:= SD1->D1_CF
				TRB->QTDEE			:= CDM->CDM_QTDENT //COLUNA G
				TRB->VLPROD			:= SD1->D1_VUNIT
				TRB->BASEENT		:= SD1->D1_BASEICM
				TRB->ALIQ			:= SD1->D1_PICM
				TRB->ICMSP			:= SD1->D1_VALICM //COLUNA - K
				TRB->DESP			:= SD1->(D1_VALFRE+D1_SEGURO+D1_DESPESA)
				TRB->MVA			:= SD1->D1_MARGEM
				TRB->BASEENTST		:= CDM->CDM_BSERET
				TRB->ALIQI			:= nAlqInt
				TRB->ICMSRET		:= SD1->D1_ICMSRET //COLUNA - P

				//----------------------------
				//INFORMAÇÕES DA NOTA DE SAÍDA
				//----------------------------				
				TRB->DOCSAI			:= CDM->CDM_DOCSAI
				TRB->SERIES			:= CDM->CDM_SERIES 
				TRB->EMISSAOS		:= CDM->CDM_DTSAI
				TRB->QTDES			:= CDM->CDM_QTDVDS //COLUNA - S

				//---------------------------------------------------------
				//VALORES COM RESSARCIMENTO DE ST E CRÉDITO DO ICMS PRÓPRIO
				//---------------------------------------------------------				
				TRB->CALCICMS1	:= Round(TRB->ICMSRET / CDM->CDM_QTDENT,2) //COLUNA T
				TRB->CALCICMS2	:= Round(TRB->CALCICMS1 * CDM->CDM_QTDVDS,2) //COLUNA U
				TRB->CALCICMS3	:= Round(TRB->ICMSP/CDM->CDM_QTDENT,2) //COLUNA - V
				TRB->CALCICMS4	:= Round(TRB->CALCICMS3 * TRB->QTDES,2) //COLUNA W
				
				//---------------------------------------------------------
				//Atualiza as tabelas para os demais relatórios de MG
				//---------------------------------------------------------
				
				//TABELA DE PRODUTOS
				linclui:= !PROD->(MsSeek(CDM->CDM_PRODUT+SB1->B1_POSIPI))
				Reclock("PROD",linclui)				
				If linclui
					PROD->NCM		:=	SB1->B1_POSIPI
					
					PROD->PRODUTO	:=	CDM->CDM_PRODUT
					PROD->DESCRPROD	:=	SB1->B1_DESC
					PROD->UNID		:=	SB1->B1_UM
					PROD->QTDES		:=  CDM->CDM_QTDVDS
					PROD->CALCICMS1	:=	TRB->CALCICMS2
					PROD->CALCICMS2	:=	TRB->CALCICMS4				
				Else
					PROD->QTDES		+=  CDM->CDM_QTDVDS
					PROD->CALCICMS1	+=	TRB->CALCICMS2
					PROD->CALCICMS2	+=	TRB->CALCICMS4				
				EndIF
				PROD->(MsUnLock())				

				//TABELA DE DAS NOTAS DE SAÍDAS
				Reclock("SAI",.T.)
				SAI->DOCSAI		:=	CDM->CDM_DOCSAI
				SAI->EMISSAOS	:=	CDM->CDM_DTSAI
				SAI->CFOP		:=	CDM->CDM_CFSAI
				SAI->RAZSOC		:=	SA1->A1_NOME				
				SAI->ESTADO		:=  SA1->A1_EST				
				SAI->IE			:=	SA1->A1_INSCR
				SAI->CNPJ		:=	SA1->A1_CGC
				SAI->(MsUnLock())
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava os valores no formato do modelo padrão genérico para Estado não homologados.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			
			cHipotese:= Iif(SA1->A1_SIMPNAC=="1","2","1")
			
			nValor := SD2->D2_PRCVEN + SD2->D2_IPI + SD2->D2_VALFRE + SD2->D2_DESPESA
	 		Reclock("TRB",.T.)                 
			TRB->DOCSAI		:= CDM->CDM_DOCSAI 
			TRB->SERIES		:= CDM->CDM_SERIES 
			TRB->DTSAI		:= CDM->CDM_DTSAI 
			TRB->ITSAI		:= CDM->CDM_ITSAI 
			TRB->PRODUT		:= CDM->CDM_PRODUT 
			TRB->QTDVDS		:= CDM->CDM_QTDVDS 	
			TRB->HIPOTESE	:= cHipotese
			TRB->DTENT		:= CDM->CDM_DTENT  
			TRB->DOCENT		:= CDM->CDM_DOCENT  
			TRB->FORNEC		:= CDM->CDM_FORNEC  
			TRB->ICMSST		:= Iif(SD1->D1_ICMSRET > 0,SD1->D1_ICMSRET,SD1->D1_ICMNDES)
			TRB->BSERET		:= Iif(CDM->CDM_BSERET > 0,CDM->CDM_BSERET,CDM->CDM_BASMAN) 
			TRB->QTDENT		:= CDM->CDM_QTDENT 
			TRB->BASRES		:= (TRB->BSERET /CDM->CDM_QTDENT)*CDM->CDM_QTDVDS
			TRB->VALRES		:= Iif(CDM->CDM_BASMAN > 0,((SD1->D1_ICMNDES/CDM->CDM_QTDENT)*CDM->CDM_QTDVDS),((SD1->D1_ICMSRET/CDM->CDM_QTDENT)*CDM->CDM_QTDVDS))  
			TRB->VALCUL		:= TRB->VALRES + Iif(lAgrupaHip,aTotal[nPos][2],nTotal)
			If lIcmsProp
				TRB->ICMSE		:= (SD1->D1_VALICM/CDM->CDM_QTDENT)*CDM->CDM_QTDVDS
				TRB->BCICMSE	:= (SD1->D1_BASEICM/CDM->CDM_QTDENT)*CDM->CDM_QTDVDS  
				TRB->RECICMS	:= TRB->ICMSE + Iif(lAgrupaHip,aTotal[nPos][3],nTotICMS)
			EndIF
				
			IF lAgrupaHip			
				aTotal[nPos][2]	+= TRB->VALRES
		    	IF lIcmsProp
		    		aTotal[nPos][3]	+= TRB->ICMSE
		    	EndIF
		    Else
		    	nTotal	+= TRB->VALRES
		    	IF lIcmsProp
		    		nTotICMS	+= TRB->ICMSE
		    	EndIF
		    EndIF
			
			MsUnLock()
		Endif
	Endif			
CDM->(DbSkip())
Enddo

If cMVEstado = 'ES' .And. MV_PAR06 == 2

	RecLock("FAT",.T.)
	FAT->TOTALA 	:= nICMSEST
	FAT->TOTALBCD 	:= nICMSINT
	FAT->(MsUnLock())

EndIf

IF lApur
	DbSelectArea("TRB")
	TRB->( DbCloseArea() )
EndIF

Return(nTotal)

//-------------------------------------------------------------------
/*/{Protheus.doc} Hipotese     
~Função que irá retornar o número da hipótese para a geração do relatório

@param		cAliasSD1	-> Alias da tabela SD1
			cAliasSD2  -> Alias da tabela SD2
			cAliasSA1	-> Alias da tabela SA2	

@return Código da hipótese da operação
		
@author Erick G. Dias
@since 18/10/2013
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function Hipotese(cAliasSD1, cAliasSD2, cAliasSA1)

Local lAntecip	:= .F.
Local lProtoc		:= .F.
Local lSimples	:= .F.
Local cHipotese	:= ""

/*
Classificação da Hipótese:
-Antecipação quando houver valor no campo D1_VALANTI
-Substituído quando houver valor de ICMS ST na entrada nos campos D1_ICMNDES ou D1_ICMSRET;

-Se houver valor no campo D2_ICMSRET então existe protocolo 
-Se não houver valor no campo D2_ICMSRET então não existe protocolo.

Deverá verificar o cliente, se o campo A1_SIMPNAC estiver com opção 1, é venda para Simples Nacional
Se o campo A1_SIMPNAC estiver diferente de 1, então não é venda pra simples nacional.

Os códigos da hipóteses são:
1 - ICMSST Recolhido pelo Fornecedor (Entrada sem antecipação e saída com Protocolo/Convênio)
2 - ICMSST Recohlido pela Adquirente (Entrada com antecipação e saída com Protocolo/Convênio)
3 - ICMSST Recolhido pelo Fornecedor (Entrada sem antecipação e saída sem Protocolo/Convênio)
4 - ICMSST Recolhido pelo Adquirente (Entrada com antecipaçãp e saída sem Protocolo/Convênio)
5 - ICMSST Recolhido pelo Fornecedor (Entrada sem antecipação e saída para optante do Simples)
6 - ICMSST Recolhido pelo Adquitente (Entrada com antecipação e saída para optante do Simples)		
*/

lAntecip	:= iif ((cAliasSD1)->D1_VALANTI > 0,.T.,.F.)
lProtoc	:= iif ((cAliasSD2)->D2_ICMSRET > 0,.T.,.F.)
lSimples	:= iif ((cAliasSA1)->A1_SIMPNAC == "1",.T.,.F.)

Do Case
	Case lSimples
		cHipotese := IIF(lAntecip,"6","5")
	Case lProtoc
		cHipotese := IIF(lAntecip,"2","1")
	OtherWise
		cHipotese := IIF(lAntecip,"4","3")
EndCase

Return cHipotese

//-------------------------------------------------------------------
/*/{Protheus.doc} TabTempProd
 
Função que irá criar a tabela temporária para a geração do relatório 
para o Estado de Minas Gerais. Cria uma tabela temporária para gravação 
resumo por produto
 
@author Erick G. Dias
@since 18/09/2014
@version 11.80

/*/
//------------------------------------------------------------------- 
Static Function TabTempProd()
 
Local aCampos	:= {}
Local cArqRel2	:= '' 
 
 aCampos:={ {"NCM" 			,"C", TamSX3("B1_POSIPI")[1],0},;
 			{"PRODUTO"  	,"C", TamSX3("B1_COD")[1],0},;
 			{"DESCRPROD"    ,"C", TamSX3("B1_DESC")[1],0},;
 			{"UNID"	     	,"C", TamSX3("B1_UM")[1],0},;
 			{"QTDES"	    ,"N", 11,2},;
 			{"CALCICMS1"    ,"N", 14,2},;
 			{"CALCICMS2"    ,"N", 14,2}}

cArqRel2 := CriaTrab(aCampos)
dbUseArea(.T.,, cArqRel2, "PROD")
IndRegua("PROD",cArqRel2,"PRODUTO+NCM")
 
Return cArqRel2

//-------------------------------------------------------------------
/*/{Protheus.doc} TabTempSai
 
Função que irá criar a tabela temporária para a geração do relatório 
para o Estado de Minas Gerais. Cria uma tabela temporária para gravação 
resumo das notas de saídas consideradas no cálculo para Restiruição do 
ICMS e ICMS ST
 
@author Erick G. Dias
@since 18/09/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function TabTempSai()
 
Local aCampos		:= {}
Local cArqRel3	:= '' 
 
aCampos:={{"DOCSAI"		,"C", TamSX3("F2_DOC")[1],0},;
		  {"EMISSAOS"  	,"D", 08,0},;
		  {"CFOP"	   	,"C", 04,0},;
		  {"RAZSOC"   	,"C", 10,0},;
		  {"ESTADO"	   	,"C", TamSX3("A2_INSCR")[1],0},;
		  {"IE"		    ,"C", TamSX3("A2_INSCR")[1],0},;
		  {"CNPJ"     	,"C", 14,0}}
	
cArqRel3 := CriaTrab(aCampos)
dbUseArea(.T.,, cArqRel3, "SAI")
IndRegua("SAI",cArqRel3,"DOCSAI") 
 
Return cArqRel3

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg
 
Função que irá criar O SX1 complementar do Relatorio
 
@author Erich Buttner
@since 12/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------

Static Function ValidPerg(cPerg)

If FindFunction("EngSX1117")
	EngSX1117( cPerg, "05", "Nº Ped. Rest.", "Nº Ped. Rest.", "Nº Ped. Rest.", "MV_CH5", "C", 6, 0,,"G",,,,,"MV_PAR05",,,,,,,,,,,,,,,,,{"Parametro Utilizado para numero de pedido de Restituição do Estado ES"},{},{},)
	EngSX1117( cPerg, "06", "Anexo", "Anexo", "Anexo", "MV_CH6", "C", 1, 0,,"C",,,,,"MV_PAR06","Anexo LIX","Anexo LIX","Anexo LIX",,"Anexo LIX-A","Anexo LIX-A","Anexo LIX-A",,,,,,,,,,{"Parametro Utilizado para numero de pedido de Restituição do Estado ES"},{},{},)
EndIf

Return
