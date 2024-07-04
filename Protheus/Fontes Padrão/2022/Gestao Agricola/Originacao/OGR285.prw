#INCLUDE "Report.ch"
#INCLUDE "Protheus.ch
#INCLUDE 'TopConn.ch'
#INCLUDE "OGR285.CH"

/** {Protheus.doc} OGR285
Listagem de Extrato do Contrato.

@param: 	Nil
@author: 	Emerson coelho
@since: 	17/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGR285()
	Private cPerg	 := STR0001

	If !Pergunte(cPerg,.T.)
		Return
	EndIf

	oReport := ReportDef()
	oReport:PrintDialog()
Return

/** {Protheus.doc} ReportDef

@param: 	Nil
@author: 	Emerson coelho
@since: 	17/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function ReportDef()
	Private oSec1,oSec2,oSec3,oSec4,oSec5,oSec6,oSec7,oSec8
	Private oReport

	//Montando o objeto oReport
	oReport := TReport():NEW(STR0001, STR0002 , cPerg, {|oReport|PrintReport(oReport)}, STR0003)	//"OGR285"#"Extrato de Contrato"#"Este relatório "

	//Para não imprimir a página de parâmetros
	oReport:lParamPage 	:= .F.
	oReport:GetOrientation(2)
	oreport:nFontBody 	:= 6
	oReport:CFONTBODY	:= "COURIER NEW"
	oReport:nLineHeight	:= 40
	oReport:SetDevice(2) //IMPRESSORA
	oReport:oPage:setPaperSize(9) // 9 e 10 sao A4
	
	/*
  		Secçoes ,  oSec0 deveria ser a parte que imprime os dados especificos do contrato
        porem por questoes de alinhamento se faz manual na funcao PrnCtr
	*/
	
	//******************** Bloco Contas a Receber
	oSec1 := TRSection():New(oReport,STR0004,{})	//"CReceber"
	TRCell():New(oSec1,"PREFIXO"	,"",STR0005	 	,PesqPict('SE1',"E1_PREFIXO")  	,10	,.f.)	//"Prefixo"
	TRCell():New(oSec1,"NUMERO"		,"",STR0006	 	,PesqPict('SE1',"E1_NUM")		,09	,.f.)	//"Numero"
	TRCell():New(oSec1,"PARCELA"	,"",STR0007 	,PesqPict('SE1',"E1_PARCELA")	,06	,.f.)	//"Parcela"
	TRCell():New(oSec1,"TIPO"     	,"",STR0008	 	,PesqPict('SE1',"E1_TIPO")		,04	,.f.)	//"Tipo"
	TRCell():New(oSec1,"EMISSAO"    ,"",STR0009	 	,PesqPict('SE1',"E1_EMISSAO")	,10	,.f.)	//"Emissão"
	TRCell():New(oSec1,"VENCTO"		,"",STR0010 	,PesqPict('SE1','E1_VENCTO')	,10	,.f.)	//"Vencimento"
	TRCell():New(oSec1,"DTBAIXA"	,"",STR0011		,PesqPict('SE1',"E1_BAIXA")		,10	,.f.)	//"Dt. Baixa"
	TRCell():New(oSec1,"VRTITULO"	,"",STR0012		,PesqPict('SE1',"E1_VALOR")		,22	,.f.)	//"Valor Titulo"
	TRCell():New(oSec1,"VRSALDO"	,"",STR0013		,PesqPict('SE1',"E1_SALDO")		,22	,.f.)	//"Valor Saldo"
	oSec1:SetColSpace(5,)
	oSec1:lAutosize  := .f.
	osec1:llinebreak := .f. //-- Utilizado com T. para ver como os espaçoes entre as colunas estavam
	oSec1:SetHeaderBreak(.T.)
	
	oBreak1 := TRBreak():New( oSec1, oSec1:Cell("TIPO"), STR0014 )	//"                    T O T A L :"
	TRFunction():New(oSec1:Cell("VRTITULO"),,"SUM",oBreak1,,,,.T., .F. )
	TRFunction():New(oSec1:Cell("VRSALDO") ,,"SUM",oBreak1,,,,.T., .F. )
	oSec1:settotalinline(.f.)
	
	
	//******************** Bloco Contas a Pagar
	oSec2 := TRSection():New(oReport,STR0015,{})	//"CPagar" 
	nAddtam:=0
	TRCell():New(oSec2,"PREFIXO"	,"",STR0005		 	,PesqPict('SE2',"E2_PREFIXO") 	,10 ,.f.)	
	TRCell():New(oSec2,"NUMERO"		,"",STR0006		 	,PesqPict('SE2',"E2_NUM")		,09	,.f.)	
	TRCell():New(oSec2,"PARCELA"	,"",STR0007  		,PesqPict('SE2',"E2_PARCELA")	,06,.f.)
	TRCell():New(oSec2,"TIPO"     	,"",STR0008			,PesqPict('SE2',"E2_TIPO")		,04	,.f.)
	TRCell():New(oSec2,"EMISSAO"    ,"",STR0009	 		,PesqPict('SE2',"E2_EMISSAO")	,10	,.f.)
	TRCell():New(oSec2,"VENCTO"		,"",STR0010 		,PesqPict('SE2','E2_VENCTO')	,10	,.f.)
	TRCell():New(oSec2,"DTBAIXA"	,"",STR0011			,PesqPict('SE2',"E2_BAIXA")		,10	,.f.)
	TRCell():New(oSec2,"VRTITULO"	,"",STR0012			,PesqPict('SE2',"E2_VALOR")		,22	,.f.)
	TRCell():New(oSec2,"VRSALDO"	,"",STR0013			,PesqPict('SE2',"E2_SALDO")		,23	,.f.)
	oSec2:SetColSpace(5,)
	oSec2:lAutosize  := .f.
	oSec2:llinebreak := .f.
	oSec2:SetHeaderBreak(.T.)
	
	oBreak2 := TRBreak():New( oSec2,  oSec2:Cell("TIPO"), STR0014 )	//"                    T O T A L :"
	TRFunction():New(oSec2:Cell("VRTITULO"),,"SUM",oBreak2,,,,.T., .F. )
	TRFunction():New(oSec2:Cell("VRSALDO") ,,"SUM",oBreak2,,,,.T., .F. )
	oSec2:settotalinline(.f.)
	
	
	//******************** Bloco de Fixações de Preço
	oSec3 := TRSection():New(oReport,STR0024,{})	//"Fixacoes Preco"
	TRCell():New(oSec3,"TIPO"		,"",STR0025			,'@!' 							,11	,.f.)	//"Tipo"
	TRCell():New(oSec3,"DATA"		,"",STR0020			,PesqPict('NN8',"NN8_DATA")		,15	,.f.)	//"Data"
	TRCell():New(oSec3,"QUANT"		,"",STR0026  		,PesqPict('NN8',"NN8_QTDFIX")	,20	,.f.)	//"Quantidade"
	TRCell():New(oSec3,"VRUM1"   	,"",STR0027			,PesqPict('NN8',"NN8_VLRUNI")	,18	,.f.)	//"Valor UM1"
	TRCell():New(oSec3,"VRUM2"   	,"",STR0028			,PesqPict('NKT',"NKT_VRVNDP")	,18	,.f.)	//"Valor UM2"
	TRCell():New(oSec3,"VRTOTAL"    ,"",STR0029			,PesqPict('NN8',"NN8_VLRTOT")	,24	,.f.)	//"Valor Total"
	TRCell():New(oSec3,"QTDENTR"   	,"",STR0137			,PesqPict('NN8',"NN8_VLRTOT")	,18	,.f.)	//"Qtd. Entrega"
	//TRCell():New(oSec3,"VRENTR"   ,"",STR0030			,PesqPict('NN8',"NN8_VLRTOT")	,18	,.f.)	//"Valor Entrega"
	TRCell():New(oSec3,"QTDOPOR"	,"",STR0138			,PesqPict('NN8','NN8_VLRTOT')	,18	,.f.)	//"Qtd. OP/OR"
	oSec3:SetColSpace(1, )
	oSec3:lAutosize:=.f.
	oSec3:llinebreak:=.f.
    
	
	//******************** Bloco de Cadencia
	oSec4 := TRSection():New(oReport,STR0032,{})	//"Cadencia"
	TRCell():New(oSec4,"TIPO"		,"",STR0025			,'@!' 							,10	,.f.)	//"Tipo"
	TRCell():New(oSec4,"DTINI"		,"",STR0033 		,PesqPict('NNY',"NNY_DATINI")	,12	,.f.)	//"Dt.Inicial"
	TRCell():New(oSec4,"DTFIM"		,"",STR0034	 		,PesqPict('NNY',"NNY_DATFIM")	,12	,.f.)	//"Dt. Final"
	TRCell():New(oSec4,"QTD"     	,"",STR0026	 		,PesqPict('NNY',"NNY_QTDINT")	,20	,.f.)	//"Quantidade"
	TRCell():New(oSec4,"LOCORI"   	,"",STR0035			,'@!'							,45	,.f.)	//"Local Origem"
	TRCell():New(oSec4,"LOCDES"		,"",STR0036			,'@!'							,45	,.f.)	//"Local Destino"
	oSec4:SetColSpace(1,.f. )
	oSec4:lAutosize:=.f.
	oSec4:llinebreak:=.f.
    
    
    //******************** Bloco de Entregas
	oSec5 := TRSection():New(oReport,STR0037,{})	//"Entregas"
	TRCell():New(oSec5,"EMISSAO"	,"",STR0038			,PesqPict('NNY',"NNY_DATINI")	,10	,.f.)	//"Emissão"
	TRCell():New(oSec5,"DOCTO"		,"",STR0039			,'@!'							,10	,.f.)	//"Documento"
	TRCell():New(oSec5,"SERIE"		,"",STR0040  		,'@!'							,05	,.f.)	//"Serie"
	TRCell():New(oSec5,"PLACA"     	,"",STR0041		 	,'@!'							,10	,.f.)	//"Placa"
	TRCell():New(oSec5,"ROMAN"   	,"",STR0042			,'@!'							,11	,.f.)	//"Romaneio"
	TRCell():New(oSec5,"STATROM"   	,"",STR0130			,'@!'							,11	,.f.)	//"Status Rom."
	TRCell():New(oSec5,"QTBRUTO"	,"",STR0131			,'@E 999,999,999.99'			,14	,.f.)	//"Qtd.Bruta"
	TRCell():New(oSec5,"QTDESCO"	,"",STR0132		 	,'@E 999,999,999.99'			,14	,.f.)	//"Qtd.Desconto"
	TRCell():New(oSec5,"QTLIQUI"	,"",STR0133			,'@E 999,999,999.99'			,14	,.f.)	//"Qtd.Liquida"
	TRCell():New(oSec5,"QTFISCA"	,"",STR0134		 	,'@E 999,999,999.99'			,14 ,.f.)	//"Qtd.Fiscal"
	TRCell():New(oSec5,"VLRMERC"	,"",STR0135			,'@E 999,999,999.99'			,14 ,.f.)	//"Vlr.Mercadoria"
	TRCell():New(oSec5,"VLRDESP"	,"",STR0136			,'@E 999,999,999.99'			,14 ,.f.)	//"Vlr.Despesa"
	oSec5:SetColSpace(1, )
	oSec5:lAutosize:=.f.
	oSec5:llinebreak:=.f.
    
	TRFunction():New(oSec5:Cell("QTDESCO"),,"SUM",,,,, .T., .f. )
	TRFunction():New(oSec5:Cell("QTLIQUI"),,"SUM",,,,, .T., .f. )
	TRFunction():New(oSec5:Cell("QTFISCA"),,"SUM",,,,, .T., .f. )
	TRFunction():New(oSec5:Cell("VLRMERC"),,"SUM",,,,, .T., .f. )
	TRFunction():New(oSec5:Cell("VLRDESP"),,"SUM",,,,, .T., .f. )
	oSec5:SetTotalText(STR0014)	//"                    T O T A L :"
	oSec5:settotalinline(.f.)
	
	
	//******************** Bloco de Amostra
	oSec6 := TRSection():New(oReport,STR0047,{})	//"Amostra"
	TRCell():New(oSec6,"AMOSTRA"	,"",STR0047			,'@!'	,08	,.f.)	//"Amostra"
	TRCell():New(oSec6,"STATUS"		,"",STR0048			,'@!'	,12	,.f.)	//"STATUS"
	TRCell():New(oSec6,"DATA"		,"",STR0020  		,PesqPict('NNY',"NNY_DATINI")	,10	,.f.)	//"Data"
	TRCell():New(oSec6,"TAB"     	,"",STR0049		 	,'@!'	,09	,.f.)	//"Tabela"
	TRCell():New(oSec6,"SEM"   		,"",STR0050			,'@!'	,07	,.f.)	//"Semente"
	TRCell():New(oSec6,"LIBCTR"		,"",STR0051		 	,'@!'	,07	,.f.)	//"Lib.Ctr"
	TRCell():New(oSec6,"OBS"		,"",STR0052		 	,'@!'	,86	,.f.)	//"Observação"
	oSec6:SetColSpace(3, )


	//******************** Bloco de Autorização
	oSec7 := TRSection():New(oReport,STR0139,{})	//"Autorização"
	TRCell():New(oSec7,"ITEM"		,"",STR0140				,'@!'	,04	,.f.)	//"Item"
	TRCell():New(oSec7,"TIPO"		,"",STR0141				,'@!'	,10	,.f.)	//"Tipo"
	TRCell():New(oSec7,"DATINI"		,"",STR0142		  		,PesqPict('NJP',"NJP_DATINI")	,10	,.f.)	//"Data Ini."
	TRCell():New(oSec7,"DATFIM"    	,"",STR0143		  		,PesqPict('NJP',"NJP_DATFIM")	,10	,.f.)	//"Data Fim."
	TRCell():New(oSec7,"QTDAUT" 	,"",STR0144				,'@E 999,999,999.99'			,14	,.f.)	//"Qtd. Autorizada"
	TRCell():New(oSec7,"ENTIDA"		,"",STR0145		 		,'@!'	,50	,.f.)	//"Entidade"
	oSec7:SetColSpace(3, )

	//******************** Bloco de Alterações Contrato
	oSec8 := TRSection():New(oReport,STR0146,{})	//"Alterações Contrato"	
	TRCell():New(oSec8,"SEQUEN"		,"",STR0147			,'@!'	,04	,.f.)	//"Sequência"
	TRCell():New(oSec8,"TIPO"		,"",STR0148			,'@!'	,10	,.f.)	//"Tipo"
	TRCell():New(oSec8,"DATA"		,"",STR0149			,PesqPict('NNW',"NNW_DATA")	,10	,.f.)	//"Data"
	TRCell():New(oSec8,"QTDALT" 	,"",STR0150			,'@E 999,999,999.99'		,14	,.f.)	//"Qtd. Alteração"
	TRCell():New(oSec8,"MOTIVO"		,"",STR0151	 		,'@!'	,60	,.f.)	//"Motivo"
	TRCell():New(oSec8,"OBSERV"		,"",STR0152		 	,'@!'	,86,.f.)	//"Observação"
	oSec8:SetColSpace(3, )

	oReport:SetLandScape()
	oReport:DisableOrientation()

Return(oReport)

/** {Protheus.doc} PrintReport(oReport)

@param: 	oReport
@author: 	Emerson coelho
@since: 	17/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function PrintReport(oReport)
	Local cQuery	:= ""

	Private oSec1	:= oReport:Section(1)
	Private oSec2	:= oReport:Section(2)
	Private oSec3	:= oReport:Section(3)	
	Private oSec4	:= oReport:Section(4)
	Private oSec5	:= oReport:Section(5)
	Private oSec6	:= oReport:Section(6)
	Private oSec7	:= oReport:Section(7)
	Private oSec8	:= oReport:Section(8)

	nCont	:= 0
	nPag	:= 1

	oReport:SetPageNumber(nPag)
	oReport:Page(nPag)

	cquery :=  " SELECT * FROM " + RetSqlName("NJR")+" NJR "
	cQuery +=  " WHERE NJR.NJR_CODCTR BETWEEN '" + ( MV_PAR01 ) + "' AND '" +( MV_PAR02 ) + "'"
	cQuery +=    " AND NJR.NJR_DATA BETWEEN   '" + ( dToS(MV_PAR03) ) +  "' AND '" +( dToS(MV_PAR04) ) + "'"
	cQuery +=    " AND NJR.NJR_CODENT BETWEEN '" + ( MV_PAR05 ) + "' AND '" +( MV_PAR07 ) + "'"
	cQuery +=    " AND NJR_LOJENT BETWEEN     '" + ( MV_PAR06 ) + "' AND '" +( MV_PAR08 ) + "'"
	cQuery +=    " AND NJR_MODAL BETWEEN      '" + ( MV_PAR09 ) + "' AND '" +( MV_PAR10 ) + "'"
	cQuery +=    " AND NJR_CODSAF BETWEEN     '" + ( MV_PAR11 ) + "' AND '" +( MV_PAR12 ) + "'"
	cQuery +=    " AND NJR_CODPRO BETWEEN     '" + ( MV_PAR13 ) + "' AND '" +( MV_PAR14 ) + "'"
	cQuery +=    " AND NJR.NJR_FILIAL = '" + xFilial( "NJR" ) + "'"
	cQuery +=    " AND NJR.D_E_L_E_T_ = ' ' "
	cQuery:= ChangeQuery(cQuery)
	
	If select("QRY1") <> 0
		dbCloseArea()
	endif

	TCQUERY cQuery NEW ALIAS "QRY1"
	nreccount := 0
	count to     nreccount

	cNum := ""
	
	dbSelectArea("QRY1")
	DbGotop()
	QRY1->(DBGOTOP())

	nCont := 0
	While QRY1->(!Eof())
		
		prnctr()  // Imprime os dados do contrato deveria ser oSec0
		iIf(MV_PAR19 == 1, PrnSec1(),  )	//C.Receber			
		iIf(MV_PAR18 == 1, PrnSec2(),  ) 	//C.Pagar			
		iIf(MV_PAR17 == 1, PrnSec03(), ) 	//Fixações de preço	
		iIf(MV_PAR15 == 1, PrnSec04(), ) 	//Cadencia			
		iIf(MV_PAR16 == 1, PrnSec05(), )	//Entregas			
		iIf(MV_PAR20 == 1, PrnSec06(), ) 	//Amostra
		iIf(MV_PAR21 == 1, PrnSec07(), ) 	//Autorização			
		iIf(MV_PAR22 == 1, PrnSec08(), ) 	//Alteração de Contrato	
		
		QRY1->(DbSkip())
		oReport:EndPage()
	Enddo


	dbSelectArea("QRY1")
	dbCloseArea()

Return oReport

/** {Protheus.doc} PrnCtr
Função que imprime os dados ref. a seção 0 (Dados do contrato )

@param: 	Nil
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function PrnCtr()
	Local c1aUm			:= QRY1->NJR_UM1PRO
	Local c2aUm   		:= Posicione( "SB1", 1, xFilial( "SB1" ) + QRY1->NJR_CODPRO, "B1_SEGUM" )
	Local nQtdeFixada	:=	0

	//Tipo do contrato
	Do Case
	Case QRY1->NJR_TIPO =='1'
		cTpCtrato := STR0109	//'Ctr. Compra    :'
	Case QRY1->NJR_TIPO =='2'
		cTpCtrato := STR0110	//'Ctr. Venda     :'
	Case QRY1->NJR_TIPO =='3'
		cTpCtrato := STR0111	//'Ct.Armaz.de 3o :'
	Case QRY1->NJR_TIPO =='4'
		cTpCtrato := STR0112	//'Ctr.Armaz.em 3o:'
	EndCase
	
	nVrtotPrev := Qry1->NJR_VLRUNI  * Qry1->NJR_QTDCTR
	
	//---Garantindo integridade entre Unids. de medida >>--
	//--- Calculo do valor retirado do OGA250
	nQTUmPRC := AGRX001( Qry1->NJR_UMPRC , Qry1->NJR_UM1PRO ,1,  Qry1->NJR_CODPRO ) 
    nVrUnUm1 := Qry1->NJR_VLRUNI / nQTUmPRC
	nVrUnUm1 := Round( nVrUnUm1, TamSX3( "NJM_VLRUNI" )[2] ) 
	
	//---Alimentando valor unidade medida de preco
	nVrUnUm2 := Qry1->NJR_VLRUNI 
	
	oreport:PrintText ( STR0093	,oreport:row() 	, 10)	//"Dados do Contrato de Compra"
	oreport:SkipLine(2)
	
	//*********************** LINHA 1
	//-------------- Dados do contrato
	oreport:PrintText ( cTpCtrato						,oreport:row() 	, 10)	//Tipo do Contrato: 
	oreport:PrintText ( QRY1->NJR_CODCTR				,oreport:row() 	, 370)				
	//-------------- Dados da entidade
	oreport:PrintText ( STR0113							,oreport:row() 	, 830)	//"Entidade/Loja  :"
	cEntidade := QRY1->NJR_CODENT + ' ' + QRY1->NJR_LOJENT + ' ' + Posicione("NJ0",1,xFilial("NJ0")+QRY1->NJR_CODENT+QRY1->NJR_LOJENT,"NJ0_NOME")
	oreport:PrintText ( cEntidade						,oreport:row() 	, 1200)				
	//-------------- Dados da Moeda
	oreport:PrintText ( STR0114							,oreport:row() 	, 2500)	//"Moeda        :"
	oreport:PrintText ( fDesMoeda( NJR->NJR_MOEDA )		,oreport:row() 	, 2820)		
	oreport:SkipLine(1)

	//*********************** LINHA 2
	//-------------- Dados da safra
	oreport:PrintText ( STR0115							,oreport:row() 	, 10)	//"Safra          :"
	oreport:PrintText ( QRY1->NJR_CODSAF				,oreport:row() 	, 370)
	//-------------- Dados do produto
	oreport:PrintText ( STR0116							,oreport:row() 	, 830)	//"Produto        :"
	cProd := QRY1->NJR_CODPRO + ' ' + Posicione('SB1',1,xFilial('SB1')+QRY1->NJR_CODPRO,'B1_DESC')
	oreport:PrintText ( cProd 							,oreport:row() 	, 1200)
	//-------------- Dados de data
	oreport:PrintText ( STR0117							,oreport:row() 	, 2500)	//"Data         :"
	oreport:PrintText ( DtoC( stod( QRY1->NJR_DATA ) )	,oreport:row() 	, 2820)
	oreport:SkipLine(1)

	//*********************** LINHA 3
	//-------------- Dados do frete
	oreport:PrintText ( STR0118				,oreport:row() 	, 10)	//"Tipo de Frete  :"
	cFrete := iIf(QRY1->NJR_TPFRET == 'C', 'CIF' , 'FOB' )
	oreport:PrintText ( cFrete				,oreport:row() 	, 370)
	//-------------- Dados da modalidade
	oreport:PrintText ( STR0119				,oreport:row() 	, 830)	//"Modalidade     :"
	cModal := Posicione( "NK5", 1, xFilial( "NK5" ) + QRY1->NJR_MODAL, "NK5_DESMOD" )
	oreport:PrintText ( cModal				,oreport:row() 	, 1200)
	//-------------- Dados do tipo de preço
	oreport:PrintText ( STR0120				,oreport:row() 	, 2500)	//"Tp.Preço     :"
	cTipoFix := IIF( AllTrim( QRY1->NJR_TIPFIX ) == '1' , 'Fixo' , 'A Fixar' )
	oreport:PrintText ( cTipoFix			,oreport:row() 	, 2820)
	oreport:SkipLine(1)

	//*********************** LINHA 4
	//-------------- Dados inscricao de campo
	oreport:PrintText ( STR0121							,oreport:row() 	, 10)	//"Insc.Campo     :"
	oreport:PrintText ( QRY1->NJR_INSCPO 				,oreport:row() 	, 370)
	//-------------- Dados de quantidade
	oreport:PrintText ( STR0122							,oreport:row() 	, 830)	//"Quantidade     :"##UM
	oreport:PrintText ( Transform(Qry1->NJR_QTDCTR ,"@E 9999,999,999,999.99") + '    ' + Alltrim(c1aUm),oreport:row() 	, 1200)
	//-------------- Dados de valor
	oreport:PrintText ( STR0123 + Alltrim(c1aUm)+ "  :"						,oreport:row() 	, 2500)	//"Valor em "
	oreport:PrintText ( Transform(nVrUnUm1 , PesqPict('NJM',"NJM_VLRUNI"))	,oreport:row() 	, 2820) 
	oreport:SkipLine(1)
	//-------------- Dados de valor  
	oreport:PrintText ( STR0123 + Alltrim(c2aUm)+ "    :"					,oreport:row() 	, 10)	//"Valor em "### UM
	oreport:PrintText ( Transform(nVrUnUm2 	, PesqPict('NJM',"NJM_VLRUNI"))	,oreport:row() 	, 370)
	//-------------- Dados de qtde fixada
	nQtdeFixada := fGetQtdFixada()
	oreport:PrintText ( STR0157												,oreport:row() 	, 830)	//"Qtd.Tot.Fixada :"
	oreport:PrintText ( Transform(nQtdeFixada ,"@E 9999,999,999,999.99")	,oreport:row() 	, 1200)
	oreport:SkipLine(1)

	//*********************** LINHA 6
	oreport:PrintText ( STR0158												,oreport:row() 	, 010)	//"Qtd.Ent.Fisico :"
	oreport:PrintText ( Transform(Qry1->NJR_QTEFCO,"@E 9999,999,999,999.99"),oreport:row() 	, 0370)

	oreport:PrintText ( STR0159												,oreport:row() 	, 830)	//"Qtd.Sld.Fisico :"	
	oreport:PrintText ( Transform(Qry1->NJR_QSLFCO,"@E 9999,999,999,999.99"),oreport:row() 	, 1200)
	oreport:SkipLine(1)
	
	//*********************** LINHA 7
	oreport:PrintText ( STR0160												,oreport:row() 	, 010)	//"Qtd.Ent.Fiscal :"	
	oreport:PrintText ( Transform(Qry1->NJR_QTEFIS,"@E 9999,999,999,999.99"),oreport:row() 	, 0370)

	oreport:PrintText ( STR0161												,oreport:row() 	, 830)	//"Qtd.Sld.Fiscal :"	
	oreport:PrintText ( Transform(Qry1->NJR_SLDFIS,"@E 9999,999,999,999.99"),oreport:row() 	, 1200)
	oreport:SkipLine(2)
	oreport:fatline()

Return

/** {Protheus.doc} PrnSec1
Função que imprime a Seção1 

@param: 	Nil
@author: 	Emerson coelho
@since: 	17/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static function PrnSec1()
	Local lImprimiu := .f.
	Local cQuery	:= ''
	Local cQuebra	:= ''

	cquery += " SELECT SE1.*, N8L.* FROM " + RetSqlName('SE1')+ " SE1 "
	cQuery += 		" INNER JOIN " + RetSqlName('N8L')+ " N8L "
	cQuery += 		" ON  N8L.N8L_FILIAL 	= SE1.E1_FILIAL "
	cQuery += 		" AND N8L.N8L_PREFIX 	= SE1.E1_PREFIXO "
	cQuery += 		" AND N8L.N8L_NUM	   	= SE1.E1_NUM "
	cQuery += 		" AND N8L.N8L_PARCEL 	= SE1.E1_PARCELA "
	cQuery += 		" AND N8L.N8L_TIPO		= SE1.E1_TIPO "
	cQuery += 		" AND N8L.D_E_L_E_T_  	!= '*' "				
	cQuery += " WHERE "
	cQuery += 	" N8L.N8L_CODCTR = '" + QRY1->NJR_CODCTR + "'"
	cQuery += 	" AND SE1.D_E_L_E_T_!= '*'"
	cQuery += 	" AND SE1.E1_FILIAL = '" + fwxFilial('SE1') + "'"

	cQuery:= ChangeQuery(cQuery)

	If select("QrySE1") <> 0
		dbCloseArea()
	endif

	TCQUERY cQuery NEW ALIAS "QrySE1"

	If QrySE1->( EOF() ) .and. SE1->(ColumnPos('E1_CTROG')) > 0  //NÃO ACHOU TABELA DE EXTENÇÃO N8L, MAS TEM CAMPO E2_CTROG LEGADO NA BASE
		cquery += " SELECT * FROM " + RetSqlName('SE1')+ " SE1 "
		cQuery += " WHERE SE1.E1_CTROG = '" + QRY1->NJR_CODCTR + "'"
		cQuery += " AND SE1.D_E_L_E_T_!= '*'"
		cQuery += " AND SE1.E1_FILIAL = '" + xFilial('SE1') + "'"
	EndIF

	QrySE1->( DbGotop() )
    
	oSec1:Init()
	oreport:PrtCenter ( STR0094	,oreport:row() )	//"Dados do Contas a Receber"
	oreport:SkipLine(1)
	
	While QrySE1->(!Eof()) 
		
		IF cQuebra != QrySE1->E1_TIPO
			cQuebra	:= QrySE1->E1_TIPO
			
			
		EndIF
		
		oSec1:Cell( "PREFIXO"	):SetValue( QrySE1->E1_PREFIXO )
		oSec1:Cell( "NUMERO"	):SetValue( QrySE1->E1_NUM )
		oSec1:Cell( "PARCELA"	):SetValue( QrySE1->E1_PARCELA )
		oSec1:Cell( "TIPO"		):SetValue( QrySE1->E1_TIPO )
		oSec1:Cell( "EMISSAO"	):SetValue( dToc( StoD(QrySE1->E1_EMISSAO )) )
		oSec1:Cell( "VENCTO"	):SetValue( dToc( StoD(QrySE1->E1_VENCTO  )) )
		oSec1:Cell( "DTBAIXA"	):SetValue( dToc( StoD(QrySE1->E1_BAIXA   )) )
		
		oSec1:Cell( "VRTITULO"	):SetValue( QrySE1->E1_VALOR )
		oSec1:Cell( "VRTITULO"	):SetHeaderAlign('RIGHT' )
		oSec1:Cell( "VRTITULO"	):SetAlign('RIGHT' )
		
		oSec1:Cell( "VRSALDO" 	):SetValue( QrySE1->E1_SALDO )
		oSec1:Cell( "VRSALDO"	):SetHeaderAlign('RIGHT' )
		oSec1:Cell( "VRSALDO"	):SetAlign('RIGHT' )
	
		oSec1:PrintLine()
		lImprimiu := .t.
		
		QrySE1->(DbSkip())
	Enddo
	
	QrySE1->( dBClosearea() )
	
	 IF .not. lImprimiu //Como tem total imprimo antes do Finish para a mensagem ficar antes do total da seção
		oreport:PrintText ( STR0095	,oreport:row() 	, 100)	//"Não foram encontrados títulos a Imprimir."
	EndIF
	
	oSec1:Finish()
		
	oreport:SkipLine(2)
	oreport:fatline()

Return( nil )

/** {Protheus.doc} PrnSec2
Função que imprime a Seção2

@param: 	Nil
@author: 	Emerson coelho
@since: 	17/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static function PrnSec2()
	Local lImprimiu := .f.
	Local cQuery	:= ''
	Local cQuebra	:= ''
	
	cquery += " SELECT SE2.* FROM " + RetSqlName('SE2') + " SE2 "
	cQuery += " INNER JOIN " + RetSqlName('N8M') + " N8M "
	cQuery += 		" ON  N8M.N8M_FILIAL 	= SE2.E2_FILIAL "
	cQuery += 		" AND N8M.N8M_PREFIX 	= SE2.E2_PREFIXO "
	cQuery += 		" AND N8M.N8M_NUM	   	= SE2.E2_NUM "
	cQuery += 		" AND N8M.N8M_PARCEL 	= SE2.E2_PARCELA "
	cQuery += 		" AND N8M.N8M_TIPO		= SE2.E2_TIPO "
	cQuery += 		" AND N8M.D_E_L_E_T_  	!= '*' "
	cQuery += " WHERE N8M.N8M_CODCTR = '" + QRY1->NJR_CODCTR + "'"
	cQuery += " AND SE2.D_E_L_E_T_!= '*'"
	cQuery += " AND SE2.E2_FILIAL = '" + fwxFilial('SE2') + "'"

	cQuery:= ChangeQuery(cQuery)

	If select("QrySE2") <> 0
		dbCloseArea()
	endif

	TCQUERY cQuery NEW ALIAS "QrySE2"

	QrySE2->( DbGotop() )
	
	oreport:PrtCenter ( STR0096	,oreport:row() )	//"Dados do Contas a Pagar"
	oreport:SkipLine(1)
	
	oSec2:Init()
	
	While QrySE2->(!Eof())
		
		IF cQuebra != QrySE2->E2_TIPO
			cQuebra	:= QrySE2->E2_TIPO
		EndIF
	
		oSec2:Cell( "PREFIXO"	):SetValue( QrySE2->E2_PREFIXO )
		oSec2:Cell( "NUMERO"	):SetValue( QrySE2->E2_NUM )
		oSec2:Cell( "PARCELA"	):SetValue( QrySE2->E2_PARCELA )
		oSec2:Cell( "TIPO"		):SetValue( QrySE2->E2_TIPO )
		oSec2:Cell( "EMISSAO"	):SetValue( dToc( StoD(QrySE2->E2_EMISSAO )) )
		oSec2:Cell( "VENCTO"	):SetValue( dToc( StoD(QrySE2->E2_VENCTO  )) )
		oSec2:Cell( "DTBAIXA"	):SetValue( dToc( StoD(QrySE2->E2_BAIXA   )) )
		
		oSec2:Cell( "VRTITULO"	):SetValue( QrySE2->E2_VALOR )
		oSec2:Cell( "VRTITULO"	):SetHeaderAlign('RIGHT' )
		oSec2:Cell( "VRTITULO"	):SetAlign('RIGHT' )
		
		oSec2:Cell( "VRSALDO" 	):SetValue( QrySE2->E2_SALDO )
		oSec2:Cell( "VRSALDO"	):SetHeaderAlign('RIGHT' )
		oSec2:Cell( "VRSALDO"	):SetAlign('RIGHT' )
		oSec2:PrintLine()
		lImprimiu := .t.

		QrySE2->(DbSkip())
	Enddo
	
	QrySE2->( dBClosearea() )
	
	oSec2:fInish()
		
	IF .not. lImprimiu
		oreport:PrintText ( STR0095	,oreport:row() 	, 100)	//"Não foram encontrados títulos a Imprimir."
	EndIF
	oreport:SkipLine(2)
	oreport:fatline()
	
Return ( nil )


/** {Protheus.doc} PrnSec03
Função que imprime a Seção03

@param: 	Nil
@author: 	Emerson coelho
@since: 	17/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static function PrnSec03()
	Local cQuery 		:= ''
	Local lImprimiu	:= .f.
	
	cquery:=''
	cquery += " SELECT * FROM " + RetSqlName('NN8')+ " NN8 "
	cQuery += " WHERE NN8.NN8_CODCTR = '" + QRY1->NJR_CODCTR + "'"
	cQuery += " AND NN8.D_E_L_E_T_!= '*'"
	cQuery += " AND NN8.NN8_FILIAL = '" + xFilial('NN8') + "'"

	cQuery:= ChangeQuery(cQuery)

	If select("QryNN8") <> 0
		QryNN8->( dbCloseArea() )
	endif

	TCQUERY cQuery NEW ALIAS "QryNN8"

	QryNN8->( DbGotop() )
	
	oreport:PrtCenter ( STR0099	,oreport:row()  )//	, 10)	//"Dados Ref. ao Processo de Fixação "
	oreport:SkipLine(1)

	oSec3:Init()

	While QryNN8->(!Eof())
		cTipo := iIF(QryNN8->NN8_TIPOFX == '0' , 'PREVISTA','FIRME')
	       
		oSec3:Cell( "TIPO"     	):SetValue( cTipo )
		oSec3:Cell( "DATA"      ):SetValue( DtoC(StoD(QryNN8->NN8_DATA)) )
		oSec3:Cell( "QUANT"     ):SetValue( QryNN8->NN8_QTDFIX )
		oSec3:Cell( "QUANT"		):SetHeaderAlign('RIGHT' )
		oSec3:Cell( "QUANT"		):SetAlign('RIGHT' )
		oSec3:Cell( "QUANT"		):SetTitle("Quantidade em " + QRY1->NJR_UM1PRO )

		// -- Encontrando valor unitario da fixacao na unidade de medida do produto do contrato  --//
  		nVrUni := Round( QryNN8->NN8_VLRLIQ / AGRX001( QRY1->NJR_UMPRC , QRY1->NJR_UM1PRO, 1 ,  Qry1->NJR_CODPRO) , TamSX3("NN8_VLRUNI")[2] )		
		oSec3:Cell( "VRUM1"    	):SetValue(nVrUni)
		oSec3:Cell( "VRUM1"		):SetHeaderAlign('RIGHT' )
		oSec3:Cell( "VRUM1"		):SetAlign('RIGHT' )
		oSec3:Cell( "VRUM1"		):SetTitle("Valor em " + QRY1->NJR_UM1PRO )
	
		oSec3:Cell( "VRUM2"    	):SetValue(QRYNN8->NN8_VLRUNI)
		oSec3:Cell( "VRUM2"		):SetHeaderAlign('RIGHT' )
		oSec3:Cell( "VRUM2"		):SetAlign('RIGHT' )
		oSec3:Cell( "VRUM2"		):SetTitle("Valor em " + QRY1->NJR_UMPRC )
	
		nvrtotal:= QryNN8->NN8_VLRTOT
		oSec3:Cell( "VRTOTAL"  	):SetValue( nvrtotal )
		oSec3:Cell( "VRTOTAL"	):SetHeaderAlign('RIGHT' )
		oSec3:Cell( "VRTOTAL"	):SetAlign('RIGHT' )
	
		oSec3:Cell( "QTDENTR"  	):SetValue( QryNN8->NN8_QTDENT )
		oSec3:Cell( "QTDENTR"	):SetHeaderAlign('RIGHT' )
		oSec3:Cell( "QTDENTR"	):SetAlign('RIGHT' )	
	
		//nvrEntrega:=QRYNN8->NN8_QTDENT * QRYNN8->NN8_VLRUNI
		//oSec3:Cell( "VRENTR"    ):SetValue(nvrEntrega)
		//oSec3:Cell( "VRENTR"	):SetHeaderAlign('RIGHT' )
		//oSec3:Cell( "VRENTR"	):SetAlign('RIGHT' )
    
		oSec3:Cell( "QTDOPOR"   ):SetValue( QryNN8->NN8_QTDFIN )
		oSec3:Cell( "QTDOPOR"	):SetHeaderAlign('RIGHT' )
		oSec3:Cell( "QTDOPOR"	):SetAlign('RIGHT' )
		
		oSec3:PrintLine()
		lImprimiu :=.t.
	
		QryNN8->(DbSkip())
	Enddo
	
	QryNN8->( dBClosearea() )
	
	oSec3:Finish()
	
	IF .not. lImprimiu
		oreport:PrintText ( STR0100	,oreport:row() 	, 100)	//"Não foram encontrados movimentos de Fixação para listar."
	EndIF
	oreport:SkipLine(2)
	oreport:fatline()	

Return

/** {Protheus.doc} PrnSec04
Função que imprime a Seção04

@param: 	Nil
@author: 	Emerson coelho
@since: 	17/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static function PrnSec04()
	Local cQuery := ''
	Local lImprimiu := .f.

	cquery:=''
	cquery += " SELECT * FROM " + RetSqlName('NNY')+ " NNY "
	cQuery += " WHERE NNY.NNY_CODCTR = '" + QRY1->NJR_CODCTR + "'"
	cQuery += " AND NNY.D_E_L_E_T_!= '*'"
	cQuery += " AND NNY.NNY_FILIAL = '" + xFilial('NNY') + "'"

	cQuery:= ChangeQuery(cQuery)

	If select("QryNNY") <> 0
		QryNNY->( dbCloseArea() )
	endif

	TCQUERY cQuery NEW ALIAS "QryNNY"
	
	oreport:PrtCenter ( STR0101	,oreport:row() 	, 10)	//"Dados Referente a Cadencia"
	oreport:SkipLine(1)

	oSec4:Init()
	QryNNY->( DbGotop() )

	While QryNNY->(!Eof())
		cTipo := iIF(QryNNY->NNY_TIPENT == '0' , 'Físico','Gerencial')

		oSec4:Cell( "TIPO"   ):SetValue(cTIPO)
		oSec4:Cell( "DTINI"  ):SetValue(DtoC(StoD(QryNNY->NNY_DATINI)))
		oSec4:Cell( "DTFIM"  ):SetValue(DtoC(StoD(QryNNY->NNY_DATFIM)))
		oSec4:Cell( "QTD"    ):SetValue(QryNNY->NNY_QTDINT)
		oSec4:Cell( "QTD"	 ):SetHeaderAlign('RIGHT' )
		
		cAux:=QryNNY->NNY_ENTORI + '-' + QryNNY->NNY_LOJORI
		cAux+= ' '+ Posicione('NJ0',1,xFilial('NJ0')+QryNNY->(NNY_ENTORI + NNY_LOJORI),'NJ0_NOME')
		oSec4:Cell( "LOCORI" ):SetValue(cAux)

		cAux:=QryNNY->NNY_ENTDES + '-' + QryNNy->NNY_LOJDES

		cAux+= ' '+ Posicione('NJ0',1,xFilial('NJ0')+QryNNY->(NNY_ENTDES + NNY_LOJDES),'NJ0_NOME')
		oSec4:Cell( "LOCDES" ):SetValue(cAux)
	
		oSec4:PrintLine()
		lImprimiu := .t.
	
		QryNNY->(DbSkip())
	Enddo
	
	QryNNY->( dBClosearea() )
	
	oSec4:Finish()
	
	IF .not. lImprimiu
		oreport:PrintText ( STR0102	,oreport:row() 	, 100)	//"Não foram encontrados movimentos de Cadencia a Imprimir."
	EndIF
	oreport:SkipLine(2)
	oreport:fatline()
	
Return

/** {Protheus.doc} PrnSec05
Função que imprime a Seção05

@param: 	Nil
@author: 	Emerson coelho
@since: 	17/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static function PrnSec05()
	Local lImprimiu 	:= .f.
	Local cQuery 		:= ''
	Local cStatus		:= ''
	Local nDesconto 	:= 0
	Local nPeso1 		:= 0
	Local nPeso2 		:= 0
	Local nPercRom 		:= 0
	Local nPesoBruto 	:= 0
	Local nVlrDesp		:= 0
	Local nDevol        := 1

	cquery:=''
	cquery += " SELECT * FROM " + RetSqlName('NJM')+ " NJM "
	cQuery += " LEFT  JOIN " + RetSqlName("NJJ")+" NJJ" +" ON"
	cQuery += " NJJ.NJJ_FILIAL = NJM.NJM_FILIAL "
	cQuery += " AND NJJ.NJJ_CODROM = NJM.NJM_CODROM "
	cQuery += " WHERE NJM.NJM_CODCTR = '" + QRY1->NJR_CODCTR + "'"
	cQuery += " AND NJM.D_E_L_E_T_ = ' ' "
	cQuery += " AND NJM.NJM_FILIAL = '" + xFilial('NJM') + "'"
	cQuery += " AND NJJ.NJJ_STATUS != '4' " 

	cQuery:= ChangeQuery(cQuery)

	If select("QryNJM") <> 0
		QryNJM->( dbCloseArea() )
	endif

	TCQUERY cQuery NEW ALIAS "QryNJM"

	QryNJM->( DbGotop() )

	oreport:PrtCenter ( STR0103	,oreport:row() 	, 10)	//"Dados Referente as Entregas"
	oreport:SkipLine(1)
	
	oSec5:Init()
	While QryNJM->(!Eof())
		nDevol := 1 //redefine variavel
		dbSelectArea( "NJJ" )
		NJJ->( dbSetOrder( 1 ) )
		cTransp 	:= ''
		cPlaca		:= ''
		cStatus		:= ''
		If NJJ->( dbSeek( xFilial( "NJJ" ) + QryNJM->NJM_CODROM ) )
			cTransp 	:= NJJ->NJJ_CODTRA + ' ' + POSICIONE('SA4',1,XFILIAL('SA4')+NJJ->NJJ_CODTRA,'A4_NOME')
			cPlaca  	:= NJJ->NJJ_PLACA

			Do Case
			Case NJJ->NJJ_STATUS == '0'
				cStatus := STR0169	//'Pendente'
			Case NJJ->NJJ_STATUS == '1'
				cStatus := STR0170	//'Completo'
			Case NJJ->NJJ_STATUS == '2'
				cStatus := STR0171	//'Atualizado'
			Case NJJ->NJJ_STATUS == '3'
				cStatus := STR0172	//'Confirmado'
			Case NJJ->NJJ_STATUS == '4'
				cStatus := STR0173	//'Cancelado'
			End Case		
			
			nDesconto 	:= 0
			nPeso1		:= 0
			nPeso2		:= 0
			nPercRom	:= 0
			nPesoBruto	:= 0
			nPesoLiq	:= 0
			
			dbSelectArea( "NJK" )
			NJK->( dbSetOrder( 1 ) )
			If NJK->( dbSeek( xFilial( "NJK" ) + NJJ->NJJ_CODROM ) )
				While NJK->(!Eof()) .AND. xFilial( "NJK" ) == NJJ->NJJ_FILIAL .AND. NJK->NJK_CODROM == NJJ->NJJ_CODROM
					nDesconto 	+= NJK->NJK_QTDDES
					NJK->( DbSkip() )
				EndDo
			EndIf 
			
			nPeso1 		:= NJJ->NJJ_PESO1
			nPeso2 		:= NJJ->NJJ_PESO2
			nPercRom  	:= QryNJM->NJM_PERDIV
			//Verificando se o item do Romaneio e 100 % da Carga 
			IF !nPercRom = 100
				nPeso1 		*= nPercRom / 100
				nPeso2 		*= nPercRom / 100
				nDesconto 	*= nPercRom / 100
			EndIF  
			
			nPesoBruto 	:= ABS( nPeso1 - nPeso2 )	//ABS=VALOR ABSOLUTO
			nPesoLiq 	:= ABS(nPesoBruto - nDesconto)	
		EndIf

		oSec5:Cell( "EMISSAO"   ):SetValue(DtoC(StoD(QryNJM->NJM_DOCEMI)))
		oSec5:Cell( "DOCTO"  	):SetValue(QryNJM->NJM_DOCNUM)
		oSec5:Cell( "SERIE"  	):SetValue(QryNJM->NJM_DOCSER)
		oSec5:Cell( "PLACA"    	):SetValue(cPlaca)
		oSec5:Cell( "ROMAN"    	):SetValue(QryNJM->NJM_CODROM)
		oSec5:Cell( "STATROM"  	):SetValue(cStatus)
		
		If QryNJM->NJJ_TIPO $ "6|7|8|9"
			nDevol := -1 //devido ao comando SUM, o sistema está somando os romaneios de devolução ao inves de diminuir o saldo, ao final estrapolando o valor final
		EndIf 
		oSec5:Cell( "QTBRUTO"   ):SetValue(nPesoBruto * nDevol)  
		oSec5:Cell( "QTBRUTO"	):SetHeaderAlign('RIGHT' )
		oSec5:Cell( "QTBRUTO"	):SetAlign('RIGHT' )	
		
		oSec5:Cell( "QTDESCO"  	):SetValue( nDesconto * nDevol)
		oSec5:Cell( "QTDESCO"	):SetHeaderAlign('RIGHT' )
		oSec5:Cell( "QTDESCO"	):SetAlign('RIGHT' )	
		
		oSec5:Cell( "QTLIQUI"   ):SetValue(nPesoLiq * nDevol) 
		oSec5:Cell( "QTLIQUI"	):SetHeaderAlign('RIGHT' )
		oSec5:Cell( "QTLIQUI"	):SetAlign('RIGHT' )		

		oSec5:Cell( "QTFISCA"   ):SetValue(QryNJM->NJM_QTDFIS  * nDevol)   
		oSec5:Cell( "QTFISCA"	):SetHeaderAlign('RIGHT' )
		oSec5:Cell( "QTFISCA"	):SetAlign('RIGHT' )	
		
		oSec5:Cell( "VLRMERC"  	):SetValue(QryNJM->NJM_VLRTOT  * nDevol)
		oSec5:Cell( "VLRMERC"	):SetHeaderAlign('RIGHT' )
		oSec5:Cell( "VLRMERC"	):SetAlign('RIGHT' )	
		
		nVlrDesp := QryNJM->NJM_FRETE + QryNJM->NJM_SEGURO + QryNJM->NJM_DESPES
		oSec5:Cell( "VLRDESP"   ):SetValue(nVlrDesp  * nDevol) 
		oSec5:Cell( "VLRDESP"	):SetHeaderAlign('RIGHT' )
		oSec5:Cell( "VLRDESP"	):SetAlign('RIGHT' )	

		oSec5:PrintLine()
		lImprimiu := .t.
	
		QryNJM->( DbSkip() )
	Enddo
	
	QryNJM->( dBClosearea() )
	
	oSec5:Finish()
	
	IF .not. lImprimiu
		oreport:PrintText ( STR0104	,oreport:row() 	, 100)	//"Não foram encontrados Entregas a Imprimir."
	EndIF
	oreport:SkipLine(2)
	oreport:fatline()
	
Return

/** {Protheus.doc} PrnSec06
Função que imprime a Seção06

@param: 	Nil
@author: 	Emerson coelho
@since: 	17/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static function PrnSec06()
	Local lImprimiu := .f.
	Local cQuery := ''
	
	cquery:=''
	cquery += " SELECT * FROM " + RetSqlName('NJF')+ " NJF "
	cQuery += " WHERE NJF.NJF_CODCTR = '" + QRY1->NJR_CODCTR + "'"
	cQuery += " AND NJF.D_E_L_E_T_ = ' ' "
	cQuery += " AND NJF.NJF_FILIAL = '" + xFilial('NJF') + "'"

	cQuery:= ChangeQuery(cQuery)

	If select("QryNJF") <> 0
		QryNJF->( dbCloseArea() )
	endif

	cQuery:= ChangeQuery(cQuery)

	TCQUERY cQuery NEW ALIAS "QryNJF"

	oSec6:Init()
    
	QryNJF->( DbGotop() )
	
	oreport:PrtCenter( STR0105	,oreport:row() )// 	, 10)	//"Dados Referente as Amostras"
	oreport:SkipLine(1)

	While QryNJF->(!Eof())
		cStatus:=''
		Do Case
		Case QryNJF->NJF_STATUS == '0'
			cStatus := STR0127	//'Amostra'
		Case QryNJF->NJF_STATUS == '1'
			cStatus := STR0128	//'Classificada'
		Case QryNJF->NJF_STATUS == '2'
			cStatus := STR0129	//'Vinculada'
		Case QryNJF->NJF_STATUS == '3'
			cStatus := STR0166	//'Liberada' 
		Case QryNJF->NJF_STATUS == '4'
			cStatus := STR0167	//'Reprovada'
		Case QryNJF->NJF_STATUS == '5'
			cStatus := STR0168	//'Cancelada'
		End Case
		cEhSemente:= iIf(QryNJF->NJF_SEMENT == '1', 'Sim','Não')
		cLibctr:= iIf(QryNJF->NJF_LIBCTR == '1', 'Sim','Não')
                                                                                                   
		oSec6:Cell( "AMOSTRA"   ):SetValue( QryNJF->NJF_CODAMO )
		oSec6:Cell( "STATUS"  	):SetValue( cStatus )
		oSec6:Cell( "DATA"  	):SetValue( DtoC(StoD(QryNJF->NJF_DATA)) )
		oSec6:Cell( "TAB"    	):SetValue( QryNJF->NJF_TABELA )
		oSec6:Cell( "SEM"    	):SetValue( cEhSemente )
		oSec6:Cell( "LIBCTR"    ):SetValue( cLibctr )
		oSec6:Cell( "OBS"    	):SetValue(QryNJF->NJF_OBS)
				
		oSec6:PrintLine()
		lImprimiu := .t.
	
		QryNJF->(DbSkip())
	Enddo
	
	QryNJF->( dBClosearea() )
	
	oSec6:Finish()
	
	IF .not. lImprimiu
		oreport:PrintText ( STR0106	,oreport:row() 	, 100)	//"Não foram encontrados movimentos de Amostra a Imprimir."
	EndIF
	oreport:SkipLine(2)
	oreport:fatline()

Return


/** {Protheus.doc} PrnSec07
Função que imprime a Seção07

@param: 	Nil
@author: 	Emerson coelho
@since: 	17/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static function PrnSec07()
	Local lImprimiu := .f.
	Local cQuery 	:= ''
	Local cTipo 	:= ''
	
	cquery:=''
	cquery += " SELECT * FROM " + RetSqlName('NJP')+ " NJP "
	cQuery += " WHERE NJP.NJP_CODCTR = '" + QRY1->NJR_CODCTR + "'"
	cQuery += " AND NJP.D_E_L_E_T_  != '*'"
	cQuery += " AND NJP.NJP_FILIAL   = '" + xFilial('NJP') + "'"

	cQuery:= ChangeQuery(cQuery)

	If select("QryNJP") <> 0
		QryNJP->( dbCloseArea() )
	endif

	cQuery:= ChangeQuery(cQuery)

	TCQUERY cQuery NEW ALIAS "QryNJP"

	oSec7:Init()
    
	QryNJP->( DbGotop() )
	
	oreport:PrtCenter( STR0162	,oreport:row() )// 	, 10)	//"Dados Referente as Autorizações"
	oreport:SkipLine(1)

	While QryNJP->(!Eof())
		                                                 
        cTipo := ''
		Do Case
		Case QryNJP->NJP_TIPO  == 'E'
			cTipo := "Entrada"	//'Entrada'
		Case QryNJP->NJP_TIPO  == 'S'
			cTipo := "Saida"	//'Saida'
		End Case                            
        
        cCodEnt	 := Alltrim(QryNJP->NJP_CODTER) 
        cLojEnt	 := Alltrim(QryNJP->NJP_LOJTER)
        cNomeEnt := Alltrim(Posicione('NJ0',1,xFilial('NJ0')+QryNJP->NJP_CODTER+QryNJP->NJP_LOJTER,'NJ0_NOME'))
                                                                                           
		oSec7:Cell( "ITEM"   ):SetValue( QryNJP->NJP_ITEM )
		oSec7:Cell( "TIPO"   ):SetValue( cTipo )		
		oSec7:Cell( "DATINI" ):SetValue( DtoC(StoD(QryNJP->NJP_DATINI)) )
		oSec7:Cell( "DATFIM" ):SetValue( DtoC(StoD(QryNJP->NJP_DATFIM)) )
		oSec7:Cell( "QTDAUT" ):SetValue( QryNJP->NJP_QTDAUT)
		oSec7:Cell( "ENTIDA" ):SetValue( cCodEnt + '  ' + cLojEnt + '  ' + cNomeEnt)
				
		oSec7:PrintLine()
		lImprimiu := .t.
	
		QryNJP->(DbSkip())
	Enddo
	
	QryNJP->( dBClosearea() )
	
	oSec7:Finish()
	
	IF .not. lImprimiu
		oreport:PrintText ( STR0163	,oreport:row() 	, 100)	//"Não foram encontrados movimentos de Autorizações a Imprimir."
	EndIF
	oreport:SkipLine(2)
	oreport:fatline()

Return

/** {Protheus.doc} PrnSec08
Função que imprime a Seção08

@param: 	Nil
@author: 	Emerson coelho
@since: 	17/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static function PrnSec08()
	Local lImprimiu := .f.
	Local cQuery 	:= ''
	Local cTipo 	:= ''
	
	cquery += " SELECT * FROM " + RetSqlName('NNW')+ " NNW "
	cQuery += " WHERE NNW.NNW_CODCTR = '" + QRY1->NJR_CODCTR + "'"
	cQuery += " AND NNW.D_E_L_E_T_  != '*'"
	cQuery += " AND NNW.NNW_FILIAL   = '" + xFilial('NNW') + "'"

	cQuery:= ChangeQuery(cQuery)

	If select("QryNNW") <> 0
		QryNNW->( dbCloseArea() )
	endif

	cQuery:= ChangeQuery(cQuery)

	TCQUERY cQuery NEW ALIAS "QryNNW"

	oSec8:Init()
    
	QryNNW->( DbGotop() )
	
	oreport:PrtCenter( STR0164	,oreport:row() )// 	, 10)	//"Dados Referente as Alterações de Contrato"
	oreport:SkipLine(1)

	While QryNNW->(!Eof())
		                                                 
        cTipo := ''
		Do Case
		Case QryNNW->NNW_TIPO  == '1'
			cTipo := "Aditação"		//'Aditação'   
		Case QryNNW->NNW_TIPO  == '2'
			cTipo := "Supressão"	//'Supressão'
		End Case                            
        
        cCodMot	:= Alltrim(QryNNW->NNW_CODMTV) 
        cDesMot := Alltrim(Posicione('NNQ',1,xFilial('NNQ')+QryNNW->NNW_CODMTV,'NNQ_DESCRI'))
                                                                                           
		oSec8:Cell( "SEQUEN" ):SetValue( QryNNW->NNW_SEQ )
		oSec8:Cell( "TIPO"   ):SetValue( cTipo )		
		oSec8:Cell( "DATA" 	 ):SetValue( DtoC(StoD(QryNNW->NNW_DATA)) )
		oSec8:Cell( "QTDALT" ):SetValue( QryNNW->NNW_QTDALT)
		oSec8:Cell( "MOTIVO" ):SetValue( cCodMot + '  ' + cDesMot)
		oSec8:Cell( "OBSERV" ):SetValue( QryNNW->NNW_OBSERV)
				
		oSec8:PrintLine()
		lImprimiu := .t.
	
		QryNNW->(DbSkip())
	Enddo
	
	QryNNW->( dBClosearea() )
	
	oSec8:Finish()
	
	IF .not. lImprimiu
		oreport:PrintText ( STR0165	,oreport:row() 	, 100)	//"Não foram encontrados movimentos de Alterações de Contrato a Imprimir."
	EndIF
	oreport:SkipLine(2)
	oreport:fatline()

Return


/** {Protheus.doc} fDesMoeda( nMoeda )
Função que Retorna a Descricao da Moeda

@param: 	nMoeda
@author: 	Emerson coelho
@since: 	17/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fDesMoeda( nMoeda )
	Local cDesMoeda	:= ""
	Do Case
	Case nMoeda == 1
		cDesMoeda := Alltrim(GetMv('MV_SIMB1'))
	Case nMoeda == 2
		cDesMoeda := Alltrim(GetMv('MV_SIMB2'))
	Case nMoeda == 3
		cDesMoeda := Alltrim(GetMv('MV_SIMB3'))
	Case nMoeda == 4
		cDesMoeda := Alltrim(GetMv('MV_SIMB4'))
	Case nMoeda == 5
		cDesMoeda := Alltrim(GetMv('MV_SIMB5'))
	EndCase
Return cDesMoeda


/** {Protheus.doc} fGetQtdFixada()
Encontra a Qtidade total Fixada

@param: 	nil
@author: 	Emerson coelho
@since: 	17/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static function fGetQtdFixada()
	Local cQuery := ''
	
	cquery	:=''
	cQuery += " SELECT SUM(NN8_QTDFIX) AS QTFIXATOT "
	cQuery +=   " FROM " + RetSqlName('NN8')+ " NN8 "
	cQuery +=  " WHERE NN8.NN8_CODCTR = '" + QRY1->NJR_CODCTR + "'"
	cQuery +=    " AND NN8.NN8_FILIAL = '" + xFilial('NN8') + "'"
	cQuery +=    " AND NN8_TIPOFX 	 != '0'"
	cQuery +=    " AND NN8.D_E_L_E_T_!= '*'"
	cQuery := ChangeQuery(cQuery)
	If select("QryNN8") <> 0
		QryNN8->( dbCloseArea() )
	endif
	TCQUERY cQuery NEW ALIAS "QryNN8"

	QryNN8->( DbGotop() )
	
	nQFixada := QryNN8->QTFIXATOT
	
	QryNN8->( dBClosearea() )
Return( nQFixada )
