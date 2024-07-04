#Include "PROTHEUS.CH"
#INCLUDE "GPER700.CH"
#Include "REPORT.CH"
#DEFINE   nColMax	3200
#DEFINE   nLinMax  2400


Static cAliasTMP

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPER700  ³ Autor ³ Erika Kanamori                  ³ Data ³03/19/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao do relatorio RC-IVA                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER700()                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ FNC/CHAMADO  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Marcelo     |13/01/2009|00000000000400|Ajuste na funcao IMPRCIVA para calcular   |±±
±±|            |          |              |corretamente o fator de atualizacao.      |±±
±±|Luciana     |01/06/2009|000013017/2009|Ajuste na funcao IMPRCIVA para buscar como|±±
±±|            |          |              |roteiro o retorno da funcao fGetRotOrdinar|±±
±±|            |          |              |quando o mesmo estiver em branco no array |±±
±±|            |          |              |aPerFechado.                              |±±
±±|Luciana     |06/10/2009|000024608/2009|Ajuste na coluna 13% sobre 2 Suel Min para|±±
±±|            |          |              |considerar 13% sobre 2 Salarios minimos   |±±
±±|            |          |              |mesmo que a base seja menor que o valor   |±±
±±|            |          |              |apurado.                                  |±±
±±|Luciana     |29/10/2009|000026470/2009|Inclusao dos totais das colunas no final  |±±
±±|            |          |              |da planilha.                              |±±
±±|Luciana     |17/03/2010|000003287/2010|Tratamento para que os valores do total   |±±
±±|            |          |              |da planilha nao sobreponha o cabecalho.   |±±
±±|Renata      |30/09/2010|000021349/2010|Na emissao do relatorio, apos a query     |±±
±±|            |          |              |excluido o "for" executado nos periodo    |±±
±±|            |          |              |(periodos ja selecionado na query)        |±±
±±|L.Trombini  |05/08/2011|000016819/2011|Ajuste no lay out do relatorio devido mu- |±±
±±|            |          |              |dança na Legislação do Pais - Bolivia     |±±
±±|Leandro Dr. |31/01/2012|000002506/2012|Ajuste para nao emitir error.log quando n |±±
±±|            |          |              |existir dados para serem impressos.       |±±
±±|Leandro Dr. |03/02/2012|000002837/2012|Ajuste para considerar a verba com ID 728 |±±
±±|            |          |              |no Total AFP com periodo fechado.         |±±
±±|Claudinei S.|03/04/2012|        TETKC1|Ajuste para permitir impressao de filiais |±±
±±|            |          |              |sem que ocorra error.log.                 |±±
±±|Leandro Dr. |01/06/2012|        TFCQD9|Ajuste para arredondar FORM 110 conforme  |±±
±±|            |          |              |legislacao boliviana.                     |±±
±±|R.Berti     |20/06/2012|        TFEJNH|Aj.tam.do papel p/ nao truncar ult. coluna|±±
±±|            |          |              |Aj.sintaxe do order by.  	  			    |±±
±±|M. Silveira |22/11/2012|        TFYVBW|Ajustes para retirar os controles SetPrint|±±
±±|            |          |              |nao imprimir folha vazia indevidamente.   |±±
±±|Claudinei S.|21/12/2012|        TGIKW1|Ajuste: apresentar aviso quando as tabelas|±±
±±|            |          |              |S001 e S005 nao estiverem preenchidas.    |±±
±±|Claudinei S.|28/12/2012|        TGIELM|Ajuste: Reducao no tamanho da fonte de 6  |±±
±±|            |          |              |para 5 para nao cortar informacoes.       |±±
±±|Fabio G.    |10/01/2013|        TGKTKZ|Ajuste para remocao do SetPaperSize no re-|±±
±±|            |          |              |latorio e alteracoes dos fontes de 5 p/ 6.|±±
±±³R.Berti	   ³14/02/2013³        TGQLRV³Disponibilizado em formato personalizavel ³±±
±±³            ³          ³              ³(TReport) que permite exportacao p/ Excel,³±±
±±³            ³          ³              ³onde pode-se gerar TXT p/ sistema Da Vinci³±±
±±³R.Berti	   ³03/04/2013³        TGDCAO³Gera TXT DAVINCI a partir dos dados do rel³±±
±±³            ³          ³              ³(criadas funcoes chamadas por GPER705)	³±±
±±|M. Silveira |23/04/2013|        TGZK42|Ajustes p/ utilizacao do campo RA_NOMECMP.|±±
±±|A.Shibao	   |07/10/2013|        THOVM6|Ajustes no relatorio para impressao conso-|±±
±±|            |          |              |lidada por empresa, novos filtros, impres-|±±
±±|            |          |              |sao dos impostos UFV                      |±±
±±|M. Silveira |06/08/2014|        TPXQ45|Ajuste p/ checar a incidencia de RC-IVA de|±±
±±|            |          |              |faltas p/ definir ele sera ou nao deduzido|±±
±±³            ³          ³              ³                                          ³±±
±±³Jonathan Glz³06/05/2015³    PCREQ-4256³Se elimina la funcion AjustaSX, la cual   ³±±
±±³            ³          ³              ³realiza la modificacion aldiccionario de  ³±±
±±³            ³          ³              ³datos(SX1) por motivo de adecuacion  nueva³±±
±±³            ³          ³              ³estructura de SXs para version 12         ³±±
±±³Jonathan Glz³27/12/2016³SERINN001-792 ³Se modifica uso de tablas temporales por  ³±±
±±³            ³          ³              ³motivo de limpieza de CTREE en la funcion ³±±
±±³            ³          ³              ³G705CriTMP() que es usada en GPR705Proc.  ³±±
±±³            ³          ³              ³(funcion llamada del fuente GPER705)      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER700()

	Private aInfo		:= {}

	If FindFunction("TRepInUse") .And. TRepInUse()
		//Relatorio em formato TReport
		GPER700R4()
	Else
		//Relatorio em formato TMSPrinter
		GPER700R3()
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ GPER700R4  ³ Autor ³ Ricardo Berti	      ³ Data ³14/02/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Geracao do relatorio RC-IVA  								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER700                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPER700R4()

	Private oReport

	Private cPerg		:= "GPR700"
	Private cAliasQry	:= ""
	Private cCodFilial	:= ""
	Private cMatAnt		:= ""
	Private cCCAnt		:= ""
	Private aOrd		:= {	STR0004,;   //"Sucursal + Matricula"
	STR0005,;	//"Sucursal + C. Costo"
	STR0006 }	//"Sucural + Nombre"
	//Variaveis utilizadas na totalizacao
	Private nTotMin		:= 0
	Private nTotDif		:= 0
	Private nTot13		:= 0
	Private nTot2Suel	:= 0
	Private nTotFis		:= 0
	Private nTotDep		:= 0
	Private nTotAtu		:= 0
	Private nTotSUtil	:= 0
	Private nTotSFD		:= 0
	Private NTotSU		:= 0
	Private NTotColW	:= 0
	Private NTotColX	:= 0
	Private NTotColY	:= 0
	Private NTotColZ	:= 0
	Private NTotColAA	:= 0
	Private NTotColAD	:= 0
	Private nTotIRP		:= 0
	Private nTotMSeg	:= 0
	Private bBlkEmp	:= {|| If( !Empty((cAliasQry)->RA_FILIAL) .And. cCodFilial != (cAliasQry)->RA_FILIAL, Eval( {|| fInfo(@aInfo,(cAliasQry)->RA_FILIAL), aInfo[3]} ), aInfo[3] )}

	aInfo		:= Array(26)

	Pergunte(cPerg,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa relatorio T-REPORT                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef()
	oReport:SetLandscape()
	oReport:lParamPage		:= .F.		// Não imprime pagina de parametros
	oReport:PrintDialog()
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Ricardo Berti	      ³ Data ³14/02/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Geracao do relatorio RC-IVA  								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER700                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

	Local oReport
	Local oSectCab	//Section Cabecalho
	Local oSectLan 	//Section Lancamentos
	
	
	Local cTitulo	:=	STR0001		//"Planilla RC-IVA"
	Local cNomeProg	:= "GPER700"
	Local cDesc1	:= STR0001		//"Planilla RC-IVA"
	Local cDesc2	:= STR0002		//"Se imprimira de acuerdo con los parametros solicitados por el usuario."
	Local cDesc3	:= STR0003		//""Obs.: Debe imprimirse un Formulario Mensual para cada Filial.""
	Local cTime		:= Time()
	Local dData		:= dDataBase
	Local cMes		:= IIf( !Empty(mv_par03),SubStr( mv_par03, 1, 2 ), substr(dtoc(dDataBase),4,2))
	Local cAno		:= IIf( !Empty(mv_par03),SubStr( mv_par03, 3, 4 ), substr(dtoc(dDataBase),7,4))

	Local dDataRef	:= CToD(Transform(f_UltDia(cToD("01/"+cMes+"/"+cAno)),"99")+"/"+cMes+"/"+cAno)
	Local nPerIVA 	:= IF( FTABELA("S001",1,4,dDataRef) <> NIL, FTABELA("S001",1,4,dDataRef),  FTABELA("S001",1,4,))

	DEFINE REPORT oReport NAME cNomeProg TITLE cTitulo PARAMETER cPerg ACTION {|oReport| R700ImpR4(oReport,dData,cTime) } DESCRIPTION cDesc1

	oReport:nFontBody := 4
	oReport:SetDynamic()
	//oReport:SetTotalInLine(.F.)
	//oReport:SetTotalText("TOTAL DE LA PLANILLA......")
	oReport:lPageBreak := .T.	 	// lPageBreak = Quebra página antes da impressão dos totalizadores.
	oReport:lHeaderVisible := .F. 	//Nao imprime o cabecalho padrao do Protheus
	oReport:lFooterVisible := .F. 	//Nao imprime o rodape    padrao do Protheus

	oReport:SetEdit(.F.)			//Nao permite ao usuario personalizar o relatorio

	oReport:SetLeftMargin(4)

	//SECTION 1 - CABECALHO
	DEFINE SECTION oSectCab OF oReport TITLE OemToAnsi("Cabecalho") TABLE "SM0","SRA" PAGE HEADER  			//Section Fixa
	//DEFINE CELL NAME "R_EMPRESA"   	OF oSectCab TITLE ""                   	SIZE 80 BLOCK {|| Eval( bBlkEmp	) } 	//Empresa

	oSectCab:SetLineStyle()
	//SECTION 2 - LANCAMENTOS
	DEFINE SECTION oSectLan OF oReport TITLE OemToAnsi("Lancamentos") TABLE "SM0","SRA"

	DEFINE CELL NAME "ANHO"			OF oSectLan TITLE OemToAnsi(STR0059)													SIZE 04
	DEFINE CELL NAME "PERIODO"		OF oSectLan TITLE STR0060																SIZE 02
	DEFINE CELL NAME "CODDEP"		OF oSectLan TITLE STR0061 + CRLF + STR0062 + CRLF +  STR0063							SIZE tamSX3("RA_CIC")[1]
	DEFINE CELL NAME "NOMBRES"		OF oSectLan TITLE STR0064	SIZE tamSX3("RA_PRINOME")[1]//(tamSX3("RA_PRINOME")[1] + tamSX3("RA_SECNOME")[1])
	DEFINE CELL NAME "APELLIDOP"	OF oSectLan TITLE STR0065 + CRLF + STR0066												SIZE 20//tamSX3("RA_PRISOBR")[1]
	DEFINE CELL NAME "APELLIDOM"	OF oSectLan TITLE STR0067 + CRLF + STR0066												SIZE 20//tamSX3("RA_SECSOBR")[1]
	DEFINE CELL NAME "DOCUMENTO"	OF oSectLan TITLE STR0068 + CRLF + STR0069 + CRLF + STR0070 + CRLF + STR0071			SIZE tamSX3("RA_RG")[1]
	DEFINE CELL NAME "TIPODOC"		OF oSectLan TITLE STR0083 + CRLF + STR0070 + CRLF + STR0069								SIZE 05
	DEFINE CELL NAME "NOVEDADES"	OF oSectLan TITLE STR0084 + CRLF + STR0085 + CRLF + STR0086 + CRLF + STR0087			SIZE 01
	DEFINE CELL NAME "SUELNETO"		OF oSectLan TITLE STR0088 + STR0070 + CRLF + STR0092	PICTURE	"@E 9,999,999.99"		SIZE 12	HEADER ALIGN RIGHT	//"SUELDOS" "NETOS"
	DEFINE CELL NAME "2SM"			OF oSectLan TITLE STR0093 + CRLF + STR0094+ CRLF + STR0095 + CRLF + STR0096		PICTURE	"@E 9,999,999.99"	SIZE 12	HEADER ALIGN RIGHT	//"MINIMO NO"  "IMPONIBLE"
	DEFINE CELL NAME "DIFSUJ"		OF oSectLan TITLE STR0116  + CRLF + STR0089 + CRLF + STR0082 + CRLF + STR0090 + CRLF + STR0091	 	PICTURE	"@E 9,999,999.99"	SIZE 12	HEADER ALIGN RIGHT	//"DIF. SUJ" "A IMPUE"
	DEFINE CELL NAME "IMP13"		OF oSectLan TITLE STR0073 + CRLF + STR0063		PICTURE	"@E 9,999,999.99"				SIZE 12	HEADER ALIGN RIGHT	//"IMPUESTO"  "DEL 13%"
	DEFINE CELL NAME "13SUEL"		OF oSectLan TITLE STR0102 + CRLF + STR0101 + CRLF + STR0100 + CRLF + STR0099 + CRLF + STR0098		PICTURE	"@E 9,999,999.99"	SIZE 12	HEADER ALIGN RIGHT	//"13% SOBRE" "2 SUEL.MIN"
	DEFINE CELL NAME "NETOIVA"		OF oSectLan TITLE STR0073 + CRLF + STR0097 + CRLF + STR0063		PICTURE	"@E 9,999,999.99"	SIZE 12	HEADER ALIGN RIGHT
	DEFINE CELL NAME "IVAFORM"		OF oSectLan TITLE STR0103 + CRLF + STR0117 + CRLF + "693"		PICTURE	"@E 9,999,999.99"	SIZE 12	HEADER ALIGN RIGHT	//"IVA" "FORM. 110"
	DEFINE CELL NAME "SALDOFIS"		OF oSectLan TITLE STR0072 + CRLF + STR0081		PICTURE	"@E 9,999,999.99"				SIZE 12	HEADER ALIGN RIGHT	//"SALDO" "FISCO"
	DEFINE CELL NAME "AFAVDEP"		OF oSectLan TITLE STR0072 + CRLF + STR0074		PICTURE	"@E 9,999,999.99"				SIZE 12	HEADER ALIGN RIGHT	//"A FAVOR" "DEPEND"
	DEFINE CELL NAME "SALMESANT"	OF oSectLan TITLE STR0106 + CRLF + STR0107 + CRLF + STR0074 + CRLF + STR0077 + CRLF + STR0078		PICTURE	"@E 9,999,999.99"	SIZE 12	HEADER ALIGN RIGHT	//"SALDO A" "MES ANT"
	DEFINE CELL NAME "FAVACT"		OF oSectLan TITLE STR0108 + CRLF + STR0109 + CRLF + STR0110 + CRLF + STR0112 + CRLF + STR0074 + CRLF + STR0070 + STR0077 + CRLF + STR0078		PICTURE	"@E 9,999,999.99"	SIZE 12	HEADER ALIGN RIGHT
	DEFINE CELL NAME "DEPTOT"		OF oSectLan TITLE STR0075 + CRLF + STR0070 + CRLF + STR0077 + CRLF + STR0078 + CRLF + STR0079		PICTURE	"@E 9,999,999.99"	SIZE 12	HEADER ALIGN RIGHT	//"SALDO" "ATUAL."
	DEFINE CELL NAME "SALUTIL"		OF oSectLan TITLE STR0075 + CRLF + STR0076		PICTURE	"@E 9,999,999.99"				SIZE 12	HEADER ALIGN RIGHT	//"SALDO"  "UTILIZADO"
	
	DEFINE CELL NAME "COL_W"		OF oSectLan TITLE STR0075 + CRLF + STR0063 + CRLF + STR0089 + CRLF + STR0118		PICTURE	"@E 9,999,999.99"	SIZE 12	HEADER ALIGN RIGHT	//
	DEFINE CELL NAME "COL_X"		OF oSectLan TITLE STR0119 + CRLF + STR0120 + CRLF + STR0121 + CRLF + STR0122 + CRLF + STR0123		PICTURE	"@E 9,999,999.99"	SIZE 12	HEADER ALIGN RIGHT	//
	DEFINE CELL NAME "COL_Y"		OF oSectLan TITLE STR0103 + CRLF + STR0117 + CRLF + STR0124		PICTURE	"@E 9,999,999.99"	SIZE 12	HEADER ALIGN RIGHT	//
	DEFINE CELL NAME "COL_Z"		OF oSectLan TITLE STR0125 + CRLF + STR0126 + CRLF + STR0120 + CRLF + STR0121 + CRLF + STR0127		PICTURE	"@E 9,999,999.99"	SIZE 12	HEADER ALIGN RIGHT	//
	DEFINE CELL NAME "COL_AA"		OF oSectLan TITLE STR0119 + CRLF + STR0120 + CRLF + STR0121 + CRLF + STR0128	PICTURE	"@E 9,999,999.99"	SIZE 12	HEADER ALIGN RIGHT	//
	
	DEFINE CELL NAME "IMPRETPAG"	OF oSectLan TITLE STR0073 + CRLF + STR0063 + CRLF + STR0080		PICTURE	"@E 9,999,999.99"	SIZE 12	HEADER ALIGN RIGHT	//"IMPUESTOS" "RET. PAGAR"
	DEFINE CELL NAME "SALMESSEG"	OF oSectLan TITLE STR0075 + CRLF + STR0070 + CRLF + STR0113 + CRLF + STR0114 + CRLF + STR0107 + CRLF + STR0074 + CRLF + STR0111 + CRLF + STR0115		PICTURE	"@E 99999,999.99"	SIZE 12 HEADER ALIGN RIGHT	//"SALD-FAV"  "MES SGTE"

	DEFINE CELL NAME "COL_AD"		OF oSectLan TITLE STR0129 + CRLF + STR0126 + CRLF + STR0120 + CRLF + STR0121 + CRLF + STR0130 + CRLF + STR0074 + CRLF + STR0111 + CRLF + STR0115	PICTURE	"@E 9,999,999.99"	SIZE 12	HEADER ALIGN RIGHT	//
	DEFINE CELL NAME "FILIAL"		OF oSectLan TITLE STR0131 SIZE 06
	DEFINE CELL NAME "COD"			OF oSectLan TITLE STR0011	SIZE 06 	//"COD."

	
	///////////////////////////////////////////////////////////////////////
	/*
	DEFINE CELL NAME "ASOL"			OF oSectLan TITLE STR0046 +CRLF+ STR0047	PICTURE	"@E 9,999,999.99"	SIZE 12 HEADER ALIGN RIGHT	//"APORTE"  "SOLID"
	*/

	//TOTALIZADORES FINAL
	DEFINE FUNCTION NAME "TSUELNETO"	FROM oSectLan:Cell("SUELNETO") 	FUNCTION SUM 	 TITLE STR0088 + STR0070 + CRLF + STR0092	PICTURE "@E 999,999,999.99"	NO END REPORT
	DEFINE FUNCTION NAME "T2SM"			FROM oSectLan:Cell("2SM") 		FUNCTION SUM 	 TITLE STR0093 + CRLF + STR0094+ CRLF + STR0095 + CRLF + STR0096	PICTURE "@E 999,999,999.99"	NO END REPORT
	DEFINE FUNCTION NAME "TDIFSUJ"		FROM oSectLan:Cell("DIFSUJ")	FUNCTION ONPRINT TITLE STR0088 + CRLF + STR0089 + CRLF + STR0082 + CRLF + STR0090 + CRLF + STR0091	PICTURE "@E 999,999,999.99"	NO END REPORT FORMULA {|| nTotDif	}
	DEFINE FUNCTION NAME "TIMP13"	 	FROM oSectLan:Cell("IMP13") 	FUNCTION ONPRINT TITLE STR0073 + CRLF + STR0063	PICTURE "@E 999,999,999.99"	NO END REPORT FORMULA {|| nTot13	}
	DEFINE FUNCTION NAME "T13SUEL" 		FROM oSectLan:Cell("13SUEL") 	FUNCTION ONPRINT TITLE STR0102 + CRLF + STR0101 + CRLF + STR0100 + CRLF + STR0099 + CRLF + STR0098	PICTURE "@E 999,999,999.99"	NO END REPORT FORMULA {|| nTot2Suel}
	DEFINE FUNCTION NAME "TNETOIVA"  	FROM oSectLan:Cell("NETOIVA") 	FUNCTION SUM 	 TITLE STR0073 + CRLF + STR0097 + CRLF + STR0063	PICTURE "@E 999,999,999.99"	NO END REPORT
	DEFINE FUNCTION NAME "TIVAFORM"  	FROM oSectLan:Cell("IVAFORM") 	FUNCTION SUM 	 TITLE STR0103 + CRLF + STR0102 + CRLF + STR0104	+ CRLF + STR0105	PICTURE "@E 999,999,999.99"	NO END REPORT
	DEFINE FUNCTION NAME "TSALDOFIS"  	FROM oSectLan:Cell("SALDOFIS") 	FUNCTION SUM 	 TITLE STR0072 + CRLF + STR0081	PICTURE "@E 999,999,999.99"	NO END REPORT
	DEFINE FUNCTION NAME "TAFAVDEP" 	FROM oSectLan:Cell("AFAVDEP")	FUNCTION ONPRINT TITLE STR0072 + CRLF + STR0074	PICTURE "@E 999,999,999.99"	NO END REPORT FORMULA {|| nTotDep	}
	DEFINE FUNCTION NAME "TSALMESANT" 	FROM oSectLan:Cell("SALMESANT")	FUNCTION SUM 	 TITLE STR0106 + CRLF + STR0107 + CRLF + STR0074 + CRLF + STR0077 + CRLF + STR0078	PICTURE "@E 999,999,999.99"	NO END REPORT
	DEFINE FUNCTION NAME "TFAVACT"	 	FROM oSectLan:Cell("FAVACT")	FUNCTION ONPRINT TITLE STR0108 + CRLF + STR0109 + CRLF + STR0110 + CRLF + STR0112 + CRLF + STR0074 + CRLF + STR0070 + STR0077 + CRLF + STR0078	PICTURE "@E 999,999,999.99"	NO END REPORT FORMULA {|| nTotAtu	}
	DEFINE FUNCTION NAME "TDEPTOT"	 	FROM oSectLan:Cell("DEPTOT")	FUNCTION ONPRINT TITLE STR0075 + CRLF + STR0070 + CRLF + STR0077 + CRLF + STR0078 + CRLF + STR0079	PICTURE "@E 999,999,999.99"	NO END REPORT FORMULA {|| nTotSUtil }
	DEFINE FUNCTION NAME "TSALUTIL" 	FROM oSectLan:Cell("SALUTIL")	FUNCTION ONPRINT TITLE STR0075 + CRLF + STR0076	PICTURE "@E 999,999,999.99"	NO END REPORT FORMULA {|| nTotSU	}

	DEFINE FUNCTION NAME "TCOL_W"		FROM oSectLan:Cell("COL_W") 	FUNCTION ONPRINT TITLE STR0075 + CRLF + STR0063 + CRLF + STR0089 + CRLF + STR0118		PICTURE	"@E 9,999,999.99" 	NO END REPORT FORMULA {|| nTotColW	}
	DEFINE FUNCTION NAME "TCOL_X"		FROM oSectLan:Cell("COL_X") 	FUNCTION ONPRINT TITLE STR0119 + CRLF + STR0120 + CRLF + STR0121 + CRLF + STR0122 + CRLF + STR0123		PICTURE	"@E 9,999,999.99"NO END REPORT FORMULA {|| nTotColX	}
	DEFINE FUNCTION NAME "TCOL_Y"		FROM oSectLan:Cell("COL_Y") 	FUNCTION ONPRINT TITLE STR0103 + CRLF + STR0117 + CRLF + STR0124		PICTURE	"@E 9,999,999.99" NO END REPORT FORMULA {|| nTotColY	}
	DEFINE FUNCTION NAME "TCOL_Z"		FROM oSectLan:Cell("COL_Z") 	FUNCTION ONPRINT TITLE STR0125 + CRLF + STR0126 + CRLF + STR0120 + CRLF + STR0121 + CRLF + STR0127		PICTURE	"@E 9,999,999.99"NO END REPORT FORMULA {|| nTotColZ	}
	DEFINE FUNCTION NAME "TCOL_AA"		FROM oSectLan:Cell("COL_AA") 	FUNCTION ONPRINT TITLE STR0119 + CRLF + STR0120 + CRLF + STR0121 + CRLF + STR0128	PICTURE	"@E 9,999,999.99" NO END REPORT FORMULA {|| nTotColAA	}

	DEFINE FUNCTION NAME "TIMPRETPAG" 	FROM oSectLan:Cell("IMPRETPAG")	FUNCTION ONPRINT TITLE STR0073 + CRLF + STR0063 + CRLF + STR0080	PICTURE "@E 999,999,999.99"	NO END REPORT FORMULA {|| nTotIRP	}
	DEFINE FUNCTION NAME "TSALMESSEG" 	FROM oSectLan:Cell("SALMESSEG")	FUNCTION ONPRINT TITLE STR0075 + STR0070 + CRLF + STR0113 + CRLF + STR0114 + CRLF + STR0107 + CRLF + STR0074 + CRLF + STR0111 + CRLF + STR0115	PICTURE "@E 999,999,999.99"	NO END REPORT FORMULA {|| nTotMSeg	}
	
	DEFINE FUNCTION NAME "TCOL_AD"			FROM oSectLan:Cell("COL_AD") 	FUNCTION ONPRINT TITLE  STR0129 + CRLF + STR0126 + CRLF + STR0120 + CRLF + STR0121 + CRLF + STR0130 + CRLF + STR0074 + CRLF + STR0111 + CRLF + STR0115	PICTURE	"@E 9,999,999.99" NO END REPORT FORMULA {|| nTotColAD	}

	oSectLan:SetTotalInLine(.F.)
	oSectLan:SetTotalText("TOTAL DE LA PLANILLA ")
	//TRATAMENTO PARA CORREÇÃO TEMPORARIA DE CONSTANTES QUE POSSUEM ACENTUAÇÃO ESPECÍFICA PARA A LINGUA ESPANHOLA.
	//EM RELEASES MAIS NOVOS, ESTE PROBLEMA NÃO OCORRERÁ E OS ARTEFATOS GERADOS PELO ATUSX ESTÃO CORRETOS, A SUSPEITA INICIAL É QUE 
	//O BINARIO DO ROBÔ NÃO ESTEJA TOTALMENTE ATUALIZADO E POR ESTE MOTIVO GERA PACOTE COM CARACTERES TROCADOS.
	
	oSectLan:ACELL[1]:cTitle := IIF(UPPER(oSectLan:ACELL[1]:cTitle) == "AEO","Año",oSectLan:ACELL[1]:cTitle)
	oSectLan:ACELL[1]:cTitle := IIF(oSectLan:ACELL[1]:cTitle == "PerIodo","Período",oSectLan:ACELL[1]:cTitle)
Return(oReport)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ R700ImpR4  ³ Autor ³ Ricardo Berti	      ³ Data ³14/02/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Geracao do relatorio RC-IVA  								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER700                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R700ImpR4(oReport,dData,cTime)

	Local aCodFol	:= {}
	Local cCodMSeg	:= ""
	Local cSitQuery	:= ""
	Local cCatQuery	:= ""
	Local cCod1Sol	:= ""
	Local cCod2Sol	:= ""
	Local cCod3Sol	:= ""
	Local cCondicao := ""
	Local cDescMes	:= ""
	Local cFilPd	:= ""
	Local cFiltro	:= ""
	Local cMes		:= ""
	Local cAno		:= ""
	Local cPeriodo	:= ""
	Local lQuery	:= .T.
	Local nReg		:= 0
	Local nPerIVA	:= 0
	Local nFatUFV	:= 0
	Local nUFVAtu	:= 0
	Local nUFVAnt	:= 0
	Local nAux		:= 0
	Local lReg		:= .F.   //consiste se existem lancamentos para o funcionario na competencia selecionada

	Local nTotGanad := 0
	Local nSuelNeto := 0
	Local nMinNoImp := 0
	Local nIVAForm  := 0
	Local nDifSuj   := 0
	Local nImp13	:= 0
	Local n13Suel   := 0
	Local nNetoIva  := 0
	Local nSaldoFis := 0
	Local nAFavDep  := 0
	Local nSalMesAnt:= 0
	Local nFavAct   := 0
	Local nDepTot   := 0
	Local nSalUtil  := 0
	Local nImpRetPag:= 0
	Local nSalMesSeg:= 0
	Local nSalFavDep:= 0
	Local n2SM      := 0
	Local nAfp      := 0
	Local nASol     := 0
	Local nBVac     := 0
	Local nIvaNoCot := 0
	Local nForm110  := 0
	Local nColW		:= 0
	Local nColX		:= 0
	Local nColY		:= 0
	Local nColZ		:= 0
	Local nColAA	:= 0
	Local nColAB	:= 0
	Local nColAD	:= 0

	Local oCNew09	:= TFont():New("Courier New",09,09,,.F.,,,,.T.,.F.)
	Local oCNew12n	:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.) //Negrito//

	Local oSectCab	:= oReport:Section(1)
	Local oSectLan	:= oReport:Section(2)
	Local oBreakFil

	Local cFilialDe	:= mv_par01
	Local cFilialAte:= mv_par02
	Local cMatDe    := mv_par04
	Local cMatAte   := mv_par05
	Local cCustoDe  := mv_par06
	Local cCustoAte := mv_par07
	Local cNomeDe   := mv_par08
	Local cNomeAte  := mv_par09
	Local cSit      := mv_par10
	Local cCat      := mv_par11
	Local nOrdem	:= mv_par12

	Local cProcQuery:= ""
	Local cRotQuery	:= ""
	Local cProcessos:= ""
	Local cProcedi	:= ""

	Local lAllProCs	:= .F.
	Local cMnProces	:= ""
	Local cMxProces	:= "ZZZZZ"

	Local	nGTotGanad	:=	0
	Local	nGAfp		:=	0
	Local	nGAsol		:=	0
	Local	nGSuelNeto	:=	0
	Local	nG2SM		:=	0
	Local   nGForm110	:=	0
	Local	nGDifSuj	:=	0
	Local	nGImp13		:=	0
	Local	nGBVac		:=	0
	Local	nGIvaNoCot	:=	0
	Local	nGIVAForm	:=	0
	Local	nGNetoIva	:=	0
	Local	nG13Suel	:=	0
	Local	nGSaldoFis	:=	0
	Local	nGAFavDep	:=	0
	Local	nGSalMesAnt	:=	0
	Local	nGFavAct	:=	0
	Local	nGDepTot	:=	0
	Local	nGSalFavDep	:=	0
	Local	nGSalUtil	:=	0
	Local	nGImpRetPag	:=	0
	Local	nGSalMesSeg	:=	0

	Local cNomeProg	    := FunName()//"GPER700"
	Local nPage			:= 0
	Local aTabS009		:= {}
	Local nPos			:= 0
	Local nPosAnt		:= 0

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Variaveis utilizadas para parametros                         ³
	³ mv_par01        //  Filial De						           ³
	³ mv_par02        //  Filial Ate					           ³
	³ mv_par03        //  Mes/Ano Competencia Inicial?             |
	³ mv_par04        //  Matricula De                             ³
	³ mv_par05        //  Matricula Ate                            ³
	³ mv_par06        //  Centro de Custo De                       ³
	³ mv_par07        //  Centro de Custo Ate                      ³
	³ mv_par08        //  Nome De                                  ³
	³ mv_par09        //  Nome Ate                                 ³
	³ mv_par10        //  Situacoes a Imp?                         ³
	³ mv_par11        //  Categorias a Imp?                        ³
	³ mv_par12        //  Ordem                                    ³
	³ mv_par13        //  Processos ?              				   ³
	³ mv_par14        //  Roteiro ?                          	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	Local dDataRef
	Local dDataAnt

	#IFNDEF TOP
	lQuery  := .F.
	#ENDIF
	If !lQuery
		Return (.F.)
	EndIf

	If Empty(mv_par03)
		Help(" ",1,"XINVMESANO")
		Return (.F.)
	EndIf

	fCarrTab(@aTabS009,"S009")

	cMes		:= SubStr( mv_par03, 1, 2 )
	cAno		:= SubStr( mv_par03, 3, 4 )
	cPeriodo	:= cAno + cMes

	If Len(aTabS009) > 0
		nPos 	:= aScan(aTabS009, { |x| x[1] == "S009" .And. cPeriodo $ DTOS(x[5])})
	EndIf

	dDataRef	:= If( nPos > 0, aTabS009[nPos][5], datavalida(CToD(Transform(f_UltDia(cToD("01/"+cMes+"/"+cAno)),"99")+"/"+cMes+"/"+cAno),.F.))

	If Len(aTabS009) > 0
		nPosAnt	:= aScan(aTabS009, { |x| x[1] == "S009" .And. ANOMES(MonthSub( dDataRef , 1 )) $ DTOS(x[5])})
	EndIf

	dDataAnt	:= If(nPosAnt > 0, aTabS009[nPosAnt][5], datavalida(LastDate( MonthSub( dDataRef , 1 )),.F.))  //subtrai um mes da data de referencia
	cDescMes	:= STR0009 + " " + Upper(LTrim(FDESC_MES(Val(cMes)))) + " " + STR0010 + " " + cAno + "."  //"CORRESPONDIENTE AL MES DE "####"DE".

	cProcessos	:= If( Empty(mv_par13),"", ConvQry(alltrim(mv_par13),"RA_PROCES"))
	cProcedi	:= If( Empty(mv_par14),"", ConvQry(AllTrim(mv_par14),"RD_ROTEIR"))

	// Carrega codigos do Fondo Solidario
	cCod1Sol := FTABELA("S011",1,7)
	cCod2Sol := FTABELA("S011",2,7)
	cCod3Sol := FTABELA("S011",3,7)

	IF(Empty (FTABELA("S001",1,4,dDataRef)))
		Help(" ",1,"GPR700S001")
		Return (.F.)
	Endif

	nPerIVA := IF( FTABELA("S001",1,4,dDataRef) <> NIL, FTABELA("S001",1,4,dDataRef),  FTABELA("S001",1,4,))
	nPerIVA := IIF(ValType(nPerIVA) == 'C', val(nPerIVA), nPerIVA)

	//busca informacoes para gerar o nFatUFV
	nAux		:= FPosTab("S009", dDataRef, "=", 4)
	If nAux > 0
		nUFVAtu:= FTabela( "S009", nAux, 5 )
	Endif
	nAux		:= FPosTab("S009", dDataAnt, "=", 4)
	If nAux > 0
		nUFVAnt := FTabela("S009", nAux, 5 )
	Endif
	If nUFVAtu > 0 .And. nUFVAnt > 0
		nFatUFV := nUFVAtu / nUFVAnt
	Endif

	IF( Empty(FTABELA("S005",1,4,dDataRef)) )
		Help(" ",1,"GPR700S005")
		Return (.F.)
	Endif

	nAux:= 	IF( FTABELA("S005",1,2,cMes+cAno) <> NIL, FTABELA("S005",1,4,cMes+cAno),  FTABELA("S005",1,4,))

	n2SM:= (2* (IIF(ValType(nAux) == 'C',Val(nAux),nAux)))

	cSitQuery	:= ""
	If !Empty(cSit)
		For nReg:=1 to Len(cSit)
			cSitQuery += "'"+Subs(cSit,nReg,1)+"'"
			If ( nReg+1 ) <= Len(cSit)
				cSitQuery += ","
			EndIf
		Next
		cSitQuery := "%" + cSitQuery + "%"
	EndIf
	cCatQuery	:= ""
	If !Empty(cCat)
		For nReg:=1 to Len(cCat)
			cCatQuery += "'"+Subs(cCat,nReg,1)+"'"
			If ( nReg+1 ) <= Len(cCat)
				cCatQuery += ","
			Endif
		Next nReg
		cCatQuery := "%" + cCatQuery + "%"
	EndIf

	cProcedi	:= "%"+cProcedi+"%"

	cProcessos := "%" + alltrim(cProcessos) + "%"

	cAliasQry := GetNextAlias()

	cCondicao := "(cAliasQry)->RA_FILIAL == cCodFilial .And. (cAliasQry)->RA_MAT == cMatAnt"

	//DEFINE BREAK oBreakFil OF oReport   WHEN  {|| cCodFilial }  TITLE "" //PAGE BREAK

	If nOrdem == 1
		cOrdLan	  := "% RA_FILIAL, RA_MAT, PD, SEQ %"
	ElseIf nOrdem == 2
		cOrdLan   := "% RA_FILIAL, RA_CC, RA_MAT, PD, SEQ %"
	ElseIf nOrdem == 3
		cOrdLan   := "% RA_FILIAL, RA_NOME, RA_MAT, PD, SEQ %"
	EndIf

	cFilPd	:= If( Alltrim(FWModeAccess("SRV",3)) == "C", "%'" + xFilial("SRV") + "'%", "%SRA.RA_FILIAL%" )

	BEGIN REPORT QUERY oSectLan

		BeginSql alias cAliasQry

			SELECT	SRA.RA_FILIAL,	SRA.RA_MAT,				SRA.RA_CC,				SRA.RA_NOME,
			SRA.RA_PRINOME,			SRA.RA_SECNOME,			SRA.RA_PRISOBR,			SRA.RA_SECSOBR,
			SRA.RA_CIC,				SRA.RA_RG,				SRA.RA_TIPODOC,			SRA.RA_NOMECMP,
			SRA.RA_CATFUNC,			SRA.RA_SITFOLH,			SRA.RA_ADMISSA,			SRA.RA_DEMISSA,	  	SRA.RA_PROCES,
			SRC.RC_FILIAL FILIAL,	SRC.RC_MAT MAT,			SRC.RC_CC CCUSTO,		SRC.RC_PD PD,
			SRC.RC_HORAS HORAS, 	SRC.RC_VALOR VALOR,		SRC.RC_VNAOAPL VNAOAPL,	SRC.RC_SEQ SEQ,
			SRC.RC_PROCES PROCES, 	SRC.RC_PERIODO PERIODO,	SRC.RC_ROTEIR ROTEIR, 	SRC.RC_SEMANA SEMANA,
			SRV.RV_COD
			FROM %table:SRA% SRA
			INNER JOIN	%table:SRC% SRC
			ON 	    SRA.RA_FILIAL = SRC.RC_FILIAL	AND
			SRA.RA_MAT    = SRC.RC_MAT		AND
			SRA.RA_CC     = SRC.RC_CC		AND
			SRA.RA_PROCES = SRC.RC_PROCES
			INNER JOIN 	%table:SRV% SRV
			ON		SRV.RV_FILIAL = %exp:cFilPd%	AND
			SRV.RV_COD    = SRC.RC_PD

			WHERE	SRA.RA_FILIAL BETWEEN %Exp:cFilialDe% AND %Exp:cFilialAte% AND
			SRA.RA_MAT BETWEEN %Exp:cMatDe% AND %Exp:cMatAte% AND
			SRA.RA_CC BETWEEN %Exp:cCustoDe% AND %Exp:cCustoAte% AND
			SRA.RA_NOME BETWEEN %Exp:cNomeDe% AND %Exp:cNomeAte% AND
			SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) 	AND
			SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) 	AND
			SRA.RA_ADMISSA <= (%exp:dDataRef%)				AND
			(SRA.RA_DEMISSA = '' OR  SUBSTRING(SRA.RA_DEMISSA, 1, 6) >= %exp:Upper(cPeriodo)%)	AND
			SRA.RA_PROCES IN (%exp:(cProcessos)%)      	AND
			SRC.RC_ROTEIR IN (%exp:(cProcedi)%)  	   		AND
			SRC.RC_PERIODO =   %exp:Upper(cPeriodo)%   		AND
			SRA.%notDel% AND SRC.%notDel% AND SRV.%notDel%
			UNION

			(SELECT	SRA.RA_FILIAL,			SRA.RA_MAT,				SRA.RA_CC,				SRA.RA_NOME,
					SRA.RA_PRINOME,			SRA.RA_SECNOME,			SRA.RA_PRISOBR,			SRA.RA_SECSOBR,
					SRA.RA_CIC,				SRA.RA_RG,				SRA.RA_TIPODOC,			SRA.RA_NOMECMP,
					SRA.RA_CATFUNC,			SRA.RA_SITFOLH,			SRA.RA_ADMISSA,			SRA.RA_DEMISSA,		SRA.RA_PROCES,
					SRD.RD_FILIAL FILIAL,	SRD.RD_MAT MAT,			SRD.RD_CC CCUSTO,		SRD.RD_PD PD,
					SRD.RD_HORAS HORAS,   	SRD.RD_VALOR VALOR,		SRD.RD_VNAOAPL VNAOAPL,	SRD.RD_SEQ SEQ,
					SRD.RD_PROCES PROCES, 	SRD.RD_PERIODO PERIODO,	SRD.RD_ROTEIR ROTEIR,	SRD.RD_SEMANA SEMANA,
					SRV.RV_COD
			FROM %table:SRA% SRA
			INNER JOIN %table:SRD% SRD
			ON 	    SRA.RA_FILIAL = SRD.RD_FILIAL	AND
			SRA.RA_MAT    = SRD.RD_MAT		AND
			SRA.RA_CC     = SRD.RD_CC       AND
			SRA.RA_PROCES = SRD.RD_PROCES
			INNER JOIN %table:SRV% SRV
			ON		SRV.RV_FILIAL 	= %exp:cFilPd%	AND
			SRV.RV_COD    	= SRD.RD_PD

			WHERE	SRA.RA_FILIAL BETWEEN %Exp:cFilialDe% AND %Exp:cFilialAte% AND
			SRA.RA_MAT BETWEEN %Exp:cMatDe% AND %Exp:cMatAte% AND
			SRA.RA_CC BETWEEN %Exp:cCustoDe% AND %Exp:cCustoAte% AND
			SRA.RA_NOME BETWEEN %Exp:cNomeDe% AND %Exp:cNomeAte% AND
			SRA.RA_SITFOLH	IN	(%exp:Upper(cSitQuery)%)	AND
			SRA.RA_CATFUNC	IN	(%exp:Upper(cCatQuery)%)	AND
			SRA.RA_ADMISSA <=   (%exp:dDataRef%)			AND
			(SRA.RA_DEMISSA = '' OR  SUBSTRING(SRA.RA_DEMISSA, 1, 6) >= %exp:Upper(cPeriodo)%)	AND
			SRA.RA_PROCES IN    (%exp:(cProcessos)%)		AND
			SRD.RD_ROTEIR IN    (%exp:(cProcedi)% )	 	AND
			SRD.RD_PERIODO	=	%exp:Upper(cPeriodo)%		AND
			SRA.%notDel% AND SRD.%notDel% AND SRV.%notDel%)
			ORDER BY %exp:cOrdLan%

		EndSql

	END REPORT QUERY oSectLan

	//IMPRESSAO DO CABECALHO
	If (cAliasQry)->(!Eof())
		oReport:OnPageBreak({||	oSectCab:Init(),;
		oSectCab:Finish(),;
		oReport:Say( (oReport:nRow)+30, (oReport:nCol)+50  , "SIGA/"+ UPPER(cNomeProg), oCNew09 ),;            //Nome do Programa
		oReport:Say( (oReport:nRow)+30, (oReport:nCol)+3100, "Pagina: "+ ltrim(str(++nPage)), oCNew09 ),;     //Paginas
		oReport:Say( (oReport:nRow)+55, (oReport:nCol)+50  , STR0008 + cTime, oCNew09 ),;                      //Hora
		oReport:Say( (oReport:nRow)+60, (oReport:nCol)+1450, STR0001 , oCNew09),;	   			     			 //PLANILLA RC-IVA
		oReport:Say( (oReport:nRow)+55, (oReport:nCol)+3030, STR0007 + DToC(dData), oCNew09 ),;               //Fecha
		oReport:Say( (oReport:nRow)+100, (oReport:nCol)+1320, cDescMes, oCNew09),;	                             //"CORRESPONDIENTE AL MES DE FEBRERO DE 2011"
		oReport:Say((oReport:nRow)+160, (oReport:nCol)+50  , STR0056 + aInfo[3], oCNew09),;
		oReport:Say((oReport:nRow)+160, (oReport:nCol)+2830, STR0058 + aInfo[8], oCNew09),;
		oReport:Say((oReport:nRow)+185, (oReport:nCol)+50  , STR0057 + aInfo[4], oCNew09),;
		oReport:Say((oReport:nRow)+260, (oReport:nCol)+350 , "UFV ACTUAL DE FECHA " +dtoc(dDataRef)+ ": " + Transform(nUfvAtu,"999.99999"), oCNew09),;
		oReport:Say((oReport:nRow)+260, (oReport:nCol)+1295, "UFV ANTERIOR DE FECHA " +dtoc(dDataAnt)+": "+ Transform(nUfvAnt,"999.99999"), oCNew09),;
		oReport:Say((oReport:nRow)+260, (oReport:nCol)+2300, "SMN DEL MES / "+ cAno + " : "+ Transform(nAux,"9,999.99"), oCNew09),;
		oReport:SetRow(oReport:nRow+350) })
	
		//IMPRESSAO DOS LANCAMENTOS
		oSectLan:Init()

		//-- Define o total da regua da tela de processamento do relatorio
		oReport:SetMeter(SRA->( RecCount() ))

		Do While (cAliasQry)->(!Eof())

			If oReport:Cancel()
				Exit
			EndIf

			fInfo(@aInfo,cFilialDe)			// carrega dados da filial chave
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Carrega Variaveis Codigos Da Folha                           ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If !fP_CodFol(@aCodFol,cFilialDe)
				Return
			EndIf
			cCodFilial := (cAliasQry)->RA_FILIAL
			lQuebra :=.T.
			cCodMSeg := PosSrv( FGetCodFol("0733"),(cAliasQry)->RA_FILIAL,"RV_CODMSEG" )

			IF (cAliasQry)->RA_MAT <> cMatAnt .Or. lQuebra

				oSectLan:Cell("FILIAL"		):SetValue( (cAliasQry)->RA_FILIAL )
				oSectLan:Cell("COD"			):SetValue( (cAliasQry)->RA_MAT )

				oSectLan:Cell("ANHO"		):SetValue( cAno )
				oSectLan:Cell("PERIODO"		):SetValue( cValToChar(VAL(cMes)) )
				oSectLan:Cell("CODDEP"		):SetValue( TRIM((cAliasQry)->RA_CIC) )
				oSectLan:Cell("NOMBRES"		):SetValue( TRIM((cAliasQry)->RA_PRINOME) + " " + TRIM((cAliasQry)->RA_SECNOME) )
				oSectLan:Cell("APELLIDOP"	):SetValue( TRIM((cAliasQry)->RA_PRISOBR) )
				oSectLan:Cell("APELLIDOM"	):SetValue( TRIM((cAliasQry)->RA_SECSOBR) )
				oSectLan:Cell("DOCUMENTO"	):SetValue( TRIM((cAliasQry)->RA_RG) )
				If(TRIM((cAliasQry)->RA_TIPODOC) == '1')
					oSectLan:Cell("TIPODOC"		):SetValue( 'CI' )
				elseIf(TRIM((cAliasQry)->RA_TIPODOC) == '2')
					oSectLan:Cell("TIPODOC"		):SetValue( 'CE' )
				else
					oSectLan:Cell("TIPODOC"		):SetValue( '' )
				EndIf
				
				cNovedad:= ''
				if(TRIM((cAliasQry)->RA_SITFOLH) <> 'D')
					if( SUBSTR( DTOS((cAliasQry)->RA_ADMISSA), 1, 6) == cPeriodo )
						cNovedad:= 'I'
					else
						cNovedad:= 'V'
					endIf
				else
					If( SUBSTR( DTOS((cAliasQry)->RA_DEMISSA), 1, 6) <= cPeriodo )
						cNovedad:= 'D'
					else
						cNovedad:= 'V'
					EndIf
				endIf
				oSectLan:Cell("NOVEDADES"	):SetValue( cNovedad )


				//zera as variaveis para cada funcionario
				nTotGanad := nSuelNeto := nMinNoImp := 0
				nIVAForm  := nDifSuj   := nImp13	 := 0
				n13Suel   := nSaldoFis := nAFavDep  := 0
				nNetoIva  := 0
				nSalMesAnt:= nFavAct   := nDepTot   := 0
				nSalUtil  := nImpRetPag:= nSalMesSeg:= 0
				nSalFavDep:= nASol     := 0
				nAfp	   := 0
				nBVac     := 0
				nIvaNoCot := 0
				nColW	  := 0
				nColX	  := 0
				nColY	  := 0
				nColZ	  := 0
				nColAA	  := 0
				nColAB	  := 0
				nColAD	  := 0

				lReg      := .F.
				lQuebra   := .F.
				cMatAnt   := (cAliasQry)->RA_MAT

			EndIf

			cCCAnt 	:= (cAliasQry)->CCUSTO

			Do While (cAliasQry)->(!Eof()) .And. &cCondicao

				Do Case
					Case (cAliasQry)->PD == aCodFol[747,1]
					nTotGanad+= (cAliasQry)->VALOR
					lReg      := .T.
					Case (cAliasQry)->PD == aCodFol[0054,1] // desconta faltas do Ganho para bater liquido.
					If PosSrv( aCodFol[0054,1],(cAliasQry)->RA_FILIAL,"RV_IR" ) == "S"
						nTotGanad -= (cAliasQry)->VALOR
						lReg      := .T.
					EndIf
					Case (cAliasQry)->PD == aCodFol[1237,1] // desconta domingos do Ganho para bater liquido.
					nTotGanad -= (cAliasQry)->VALOR
					lReg      := .T.
					Case (cAliasQry)->PD == aCodFol[728,1]
					nAfp    += (cAliasQry)->VALOR
					Case (cAliasQry)->PD == aCodFol[729,1]
					nAfp    += (cAliasQry)->VALOR
					Case (cAliasQry)->PD == aCodFol[730,1]
					nAfp    += (cAliasQry)->VALOR
					Case (cAliasQry)->PD == aCodFol[1228,1]
					nAfp    += (cAliasQry)->VALOR
					Case (cAliasQry)->PD == cCod1Sol
					nASol    += (cAliasQry)->VALOR
					Case (cAliasQry)->PD == cCod2Sol
					nASol    += (cAliasQry)->VALOR
					Case (cAliasQry)->PD == cCod3Sol
					nASol    += (cAliasQry)->VALOR
					Case (cAliasQry)->PD == aCodFol[072,1]
					nBVac    += (cAliasQry)->VALOR
					Case (cAliasQry)->PD == aCodFol[086,1]
					nBVac    += (cAliasQry)->VALOR
					Case (cAliasQry)->PD == aCodFol[087,1]
					nBVac    += (cAliasQry)->VALOR
					Case (cAliasQry)->PD == aCodFol[084,1]
					nBVac    += (cAliasQry)->VALOR
					Case (cAliasQry)->PD == aCodFol[066,1]
					nImpRetPag += (cAliasQry)->VALOR
					Case (cAliasQry)->PD == aCodFol[733,1]
					nSalMesSeg += (cAliasQry)->VNAOAPL
					Case (cAliasQry)->PD == aCodFol[015,1]
					nSuelNeto+= (cAliasQry)->VALOR
					lReg      := .T.
					Case (cAliasQry)->PD == aCodFol[746,1]
					nMinNoImp+= (cAliasQry)->VALOR
					nTotMin  += (cAliasQry)->VALOR //Totalizador Minimo no Imponible
					lReg      := .T.
					Case (cAliasQry)->PD == aCodFol[732,1]
					nIVAForm += ROUND((cAliasQry)->VALOR,0) //Arredonda de acordo com legislacao informada no chamado TELLL2
					nForm110 := (cAliasQry)->VALOR
					lReg     := .T.
					Case (cAliasQry)->PD == cCodMSeg
					nSalMesAnt+= (cAliasQry)->VALOR
					lReg	  := .T.
					Case (cAliasQry)->PD == aCodFol[1888,1]
						nColX+= (cAliasQry)->VALOR
					Case (cAliasQry)->PD == aCodFol[1889,1]
						nColY+= (cAliasQry)->VALOR
				EndCase

				(cAliasQry)->(DbSkip())

			EndDo

			nTotGanad:= nTotGanad - nBVac
			nIvaNoCot:= Round(nBVac * nPerIVA * 0.01,2)

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Se houver registros no SRC ou SRD calcula o q falta e imprime os dados do func. |
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If lReg
				nDifSuj   := IIF(nSuelNeto > nMinNoImp, nSuelNeto - nMinNoImp, 0)
				nTotDif	+= nDifSuj //totalizador DifSuj a impuesto

				//  Impuesto Del 13%
				nImp13	  := Round(nDifSuj*nPerIVA*0.01,0)
				nTot13 += nImp13 //Totalizador Impuesto del 13%

				//  13% Sobre 2 Suel Min
				if nImp13 > 0
					n13Suel	:= Round(nMinNoImp*nPerIVA*0.01,0)
				endIf

				if nImp13 > n13Suel
					nNetoIva:= nImp13 - n13Suel
				endIf

				nTot2Suel += n13Suel  //totalizador 13% sobre 2 Suel Min

				//Saldo a Favor Fisco / Dependiente
				nSaldoFis:=  nImp13 - (n13Suel + nIVAForm)   //Fisco
				If nSaldoFis < 0
					nSaldoFis:= 0
				Endif
				nTotFis+=nSaldoFis //totalizador Saldo Fisco

				if(nForm110 > nNetoIva)
					nAFavDep := nForm110 - nNetoIva
					nTotDep+=nAFavDep
				endIf

				//Actualizacion
				if((nFatUFV-1) > 0)
					nFavAct:= (nSalMesAnt*(nFatUFV-1))
				else
					nFavAct:= nSalMesAnt
				endIf
				nFavAct:= Round(nFavAct, 0)
				nTotAtu+=nFavAct //Totalizador Actualizacion

				//Saldo a favor del Dependiente Total
				nDepTot:= nSalMesAnt + nFavAct
				nTotSUtil+=nDepTot //Totalizador Saldo Actualizado

				//Saldo a favor del Dependiente
				nSalFavDep:= nDepTot+ nIVAForm
				nTotSFD+=nSalFavDep //totalizador Saldo a favor del Dependiente
				
				if(nDepTot <= nSaldoFis)
					nSalUtil := nDepTot  
				else
					nSalUtil := nSaldoFis
				endIf
				
				nTotSU+=nSalUtil      //Totalizador Saldo Utilizado
				nTotMSeg+=nSalMesSeg  //Totalizador Saldo Fav Mes Segte
				//Nuevas columnas RC-IVA V3
				If( nSaldoFis > nSalUtil)//Columna W: Saldo RC-IVA sujeto a retención
					nColW:= nSaldoFis - nSalUtil
				EndIf
				nColZ:= nColX + nColY//Columna Z: Total saldo pago a cuenta SIETE-RG del periodo

				If(nColW >= nColZ)//Columna AA: Pago a cuenta SIETE-RG utilizado
					nColAA:= nColZ
				Else
					nColAA:= nColW
				EndIf
				nImpRetPag := nColW - nColAA
				nColAD:= nColZ - nColAA//Columna AD: Saldo de pago a cuenta SIETE-RG a favor del Dependiente para el mes siguiente

				nTotColW +=nColW
				nTotColX +=nColX
				nTotColY +=nColY
				nTotColZ +=nColZ
				nTotColAA +=nColAA
				nTotColAD +=nColAD
				nTotIRP+=nImpRetPag   //Totalizador Imposto Retido a Pagar
			EndIf

			oSectLan:Cell("SUELNETO"):SetValue(nSuelNeto)
			oSectLan:Cell("2SM"):SetValue(n2SM)
			oSectLan:Cell("DIFSUJ"):SetValue(nDifSuj)
			oSectLan:Cell("IMP13"):SetValue(nImp13)
			oSectLan:Cell("IVAFORM"):SetValue(nForm110)  //Deve exibir o valor referente ID 0732	(Coluna 6 do arquivo)
			oSectLan:Cell("13SUEL"):SetValue(n13Suel)
			oSectLan:Cell("NETOIVA"):SetValue(nNetoIva)
			oSectLan:Cell("SALDOFIS"):SetValue(nSaldoFis)
			oSectLan:Cell("AFAVDEP"):SetValue(nAFavDep)
			oSectLan:Cell("SALMESANT"):SetValue(nSalMesAnt)
			oSectLan:Cell("FAVACT"):SetValue(nFavAct)
			oSectLan:Cell("DEPTOT"):SetValue(nDepTot)
			oSectLan:Cell("SALUTIL"):SetValue(nSalUtil)
			oSectLan:Cell("COL_W"):SetValue(nColW)
			oSectLan:Cell("COL_X"):SetValue(nColX)
			oSectLan:Cell("COL_Y"):SetValue(nColY)
			oSectLan:Cell("COL_Z"):SetValue(nColZ)
			oSectLan:Cell("COL_AA"):SetValue(nColAA)
			oSectLan:Cell("IMPRETPAG"):SetValue(nImpRetPag)
			oSectLan:Cell("SALMESSEG"):SetValue(nSalMesSeg)
			oSectLan:Cell("COL_AD"):SetValue(nColAD)

			//Armazena os totalizadores para ultima pagina
			nGTotGanad	+=nTotGanad
			nGAfp		+=nAfp
			nGAsol		+=nAsol
			nGSuelNeto	+=nSuelNeto
			nG2SM		+=n2SM
			nGForm110	+=nForm110
			nGDifSuj	+=nDifSuj
			nGImp13		+=nImp13
			nGBVac		+=nBVac
			nGIvaNoCot  +=nIvaNoCot
			nGIVAForm	+=nIVAForm
			nG13Suel	+=n13Suel
			nGSaldoFis	+=nSaldoFis
			nGAFavDep	+=nAFavDep
			nGSalMesAnt	+=nSalMesAnt
			nGFavAct	+=nFavAct
			nGDepTot	+=nDepTot
			nGSalFavDep	+=nSalFavDep
			nGSalUtil	+=nSalUtil
			nGImpRetPag	+=nImpRetPag
			nGSalMesSeg	+=nSalMesSeg
			nGNetoIva	+=nNetoIva

			nForm110  := 0

			oSectLan:PrintLine()
			oReport:IncMeter()

		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza impressao inicializada pelo metodo Init             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSectLan:Finish()
	EndIf
	oReport:EndPage()

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ GPER700R3  ³ Autor ³ Erika Kanamori        ³ Data ³03/19/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Geracao do relatorio RC-IVA  								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER700                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPER700R3()
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Variaveis Locais (Basicas)                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Local cDesc1 		:= STR0001		//"Planilla RC-IVA"
	Local cDesc2 		:= STR0002		//"Se imprimira de acuerdo con los parametros solicitados por el usuario."
	Local cDesc3 		:= STR0003		//""Obs.: Debe imprimirse un Formulario Mensual para cada Filial.""
	Local cString		:= "SRA"        // alias do arquivo principal (Base)
	Local aOrd      	:= {STR0004,STR0005,STR0006}	//"Sucursal + Matricula"###"Sucursal + C. Costo"###"Sucural + Nombre"

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Variaveis Private(Basicas)                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Private nomeprog	:= "GPER700"
	Private aReturn 	:= { , 1,, 2, 2, 1,"",1 }
	Private nLastKey 	:= 0
	Private cPerg   	:= "GPR700"

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Variaveis Utilizadas na funcao IMPR                          ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Private Titulo 		:= STR0001   //"Planilla RC-IVA"
	Private nTamanho	:= "M"
	Private nOrdem
	Private cFilialDe   := ""
	Private cFilialAte  := ""
	Private cMes		:= ""
	Private cAno		:= ""
	Private cMatDe      := ""
	Private cMatAte     := ""
	Private cCustoDe    := ""
	Private cCustoAte   := ""
	Private cNomeDe     := ""
	Private cNomeAte    := ""
	Private cSit        := ""
	Private cCat        := ""

	Private oPrint

	Private cProcessos	:= ""
	Private cProcedi	:= ""

	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Variaveis utilizadas para parametros                         ³
	³ mv_par01        //  Filial De						           ³
	³ mv_par02        //  Filial Ate					           ³
	³ mv_par03        //  Mes/Ano Competencia Inicial?             |
	³ mv_par04        //  Matricula De                             ³
	³ mv_par05        //  Matricula Ate                            ³
	³ mv_par06        //  Centro de Custo De                       ³
	³ mv_par07        //  Centro de Custo Ate                      ³
	³ mv_par08        //  Nome De                                  ³
	³ mv_par09        //  Nome Ate                                 ³
	³ mv_par10        //  Situacoes a Imp?                         ³
	³ mv_par11        //  Categorias a Imp?                        ³
	³ mv_par12        //  Ordem                                    ³
	³ mv_par13        //  Processos ?              				   ³
	³ mv_par14        //  Roteiro ?                          	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	//-- Objeto para impressao grafica
	oPrint 	:= TMSPrinter():New( STR0001 ) //"Planilla RC-IVA"

	oPrint:SetLandscape()	//Imprimir Somente Paisagem
	If Pergunte(cPerg,.T.,Titulo)

		If Empty(mv_par03)
			Help(" ",1,"XINVMESANO")
			Return (.F.)
		EndIf

		cFilialDe 	:= mv_par01
		cFilialAte  := mv_par02
		cMesAno		:= mv_par03
		cMes 		:= substr( mv_par03, 1, 2 )
		cAno 		:= substr( mv_par03, 3, 4 )
		cMatDe		:= mv_par04
		cMatAte     := mv_par05
		cCustoDe    := mv_par06
		cCustoAte   := mv_par07
		cNomeDe     := mv_par08
		cNomeAte    := mv_par09
		cSit        := mv_par10
		cCat        := mv_par11
		nOrdem		:= mv_par12
		cProcessos	:= If( Empty(mv_par13),"", ConvQry(alltrim(mv_par13),"RA_PROCES"))
		cProcedi	:= If( Empty(mv_par14),"", ConvQry(AllTrim(mv_par14),"RD_ROTEIR"))

		MsgRun(STR0051,"",{|| CursorWait(), IMPRCIVA() ,CursorArrow()}) //"Gerando relatorio, aguarde..."

		oPrint:Preview()	// Visualiza impressao grafica antes de imprimir

	Else
		Return()
	Endif

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPRCIVA  ºAutor  ³Erika Kanamori      º Data ³  03/19/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º	         ³ Obs.: O GPER700 e GPR705Proc() chamam esta mesma funcao,   º±±
±±º			 ³ porem, os mesmos tem perguntes distintos (GPR700 e GPR705).º±±
±±º		 	 ³	 	   Considerar esta inf. ao alterar o SX1. 			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ GPER700(ExpL1)                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpL1: = .T., indica se deve gerar apenas o arq. TXT  (OPC)º±±
±±º          ³        = .F.(Default) - imprime apenas o relatorio		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPER700 / GPR705Proc()                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IMPRCIVA(lTXT)

	Local cAcessaSRA	:= &( " { || " + ChkRH( "GPER700" , "SRA" , "2" ) + " } " )
	Local aPerAberto    := {}
	Local aPerFechado   := {}
	Local aPerTodos		:= {}
	Local aCodFol		:= {}
	Local aTabela		:= {}
	Local nAux:= 0
	Local nLin:= 0430
	Local lReg		:= .F.   //consiste se existem lancamentos para o funcionario na competencia selecionada
	Local cFilAnt
	Local lAux		:= .F.
	Local lMsgS001	:= .F.

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Variaveis para controle em ambientes TOP.                    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Local cAlias   := ""
	Local cQrySRC  := "SRC"
	Local cQrySRD  := "SRD"
	Local cQuery
	Local cQueryOrd:= ""
	Local aStruct  := {}
	Local lQuery   := .F.

	Local lAllProCs	:= .F.
	Local cMnProces	:= ""
	Local cMxProces	:= "ZZZZZ"

	Local aTabS009	:= {}
	Local nPos		:= 0
	Local nPosAnt	:= 0

	DEFAULT lTXT 	:= .F.

	//variaveis contendo valores para impressao
	Private aInfo     := {}     //armazena dados da filial
	Private nTotGanad := 0
	Private nSuelNeto := 0
	Private nMinNoImp := 0
	Private nDifSuj   := 0
	Private nImp13	  := 0
	Private nIVAForm  := 0
	Private nForm110  := 0		//Armazena valor referente ID 0732	(Coluna 6 do arquivo, coluna "IVA form 110" no relatório )
	Private n13Suel   := 0
	Private nNetoIva  := 0
	Private nSaldoFis := 0
	Private nAFavDep  := 0
	Private nSalMesAnt:= 0
	Private nFavAct   := 0
	Private nDepTot   := 0
	Private nSalFavDep:= 0
	Private nSalUtil  := 0
	Private nImpRetPag:= 0
	Private nSalMesSeg:= 0
	Private n2SM	  := 0
	Private nAfp      := 0
	Private nASol     := 0
	Private nBVac     := 0
	Private nIvaNoCot := 0
	Private nAuxMin	  := 0
	Private nColW	  := 0
	Private nColX	  := 0
	Private nColY	  := 0
	Private nColZ	  := 0
	Private nColAA	  := 0
	Private nColAD	  := 0
	Private cQrySRA   := "SRA"
	Private dDataRef
	Private dDataAnt

	Private n13SM     := 0
	Private cTime	  := Time()
	Private dData	  := dDataBase

	//Variaveis utilizadas na totalizacao
	Private nTotGan		:= 0
	Private nTotSuel	:= 0
	Private nTotMin		:= 0
	Private nTotDif		:= 0
	Private nTot13		:= 0
	Private nTotIVA		:= 0
	Private nTot2Suel	:= 0
	Private nTotFis		:= 0
	Private nTotDep		:= 0
	Private nTotAnt		:= 0
	Private nTotAtu		:= 0
	Private nTotSUtil	:= 0
	Private nTotSFD		:= 0
	Private NTotSU		:= 0
	Private nTotIRP		:= 0
	Private nTotMSeg	:= 0
	Private nTotAfp     := 0
	Private nTotASol    := 0
	Private nTotBVac    := 0

	Private nFatUFV 	:= 0
	Private nUFVAtu 	:= 0
	Private nUFVAnt 	:= 0
	Private nPerIVA 	:= 0
	Private nPage		:= 0


	Private oFont07, oFont07n, oFont09, oFont09n, oFont10, oFont12n
	oFont06	:= TFont():New("Courier New",06,06,,.F.,,,,.T.,.F.)
	oFont06n:= TFont():New("Courier New",06,06,,.T.,,,,.T.,.F.) //Negrito//
	oFont07	:= TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.)
	oFont07n:= TFont():New("Courier New",07,07,,.T.,,,,.T.,.F.) //Negrito//
	oFont09	:= TFont():New("Courier New",09,09,,.F.,,,,.T.,.F.)
	oFont09n:= TFont():New("Courier New",09,09,,.T.,,,,.T.,.F.) //Negrito//
	oFont10 := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
	oFont12n:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.) //Negrito//

	nEpoca:= SET(5,1910)
	//-- MUDAR ANO PARA 4 DIGITOS
	SET CENTURY ON

	#IFDEF TOP
	lQuery := .T.
	#ELSE
	cQrySRA:= "SRA"
	dbSelectArea("SRA")
	nSavRec   := RecNo()
	nSavOrdem := IndexOrd()
	#ENDIF

	If nOrdem == 1
		If lQuery
			cQueryOrd := "RA_FILIAL, RA_MAT"
		Else
			dbSetOrder(1)
			SRA->( dbSeek( cFilialDe + cMatDe, .T. ) )
		Endif
		cInicio  := "(cQrySRA)->RA_FILIAL + (cQrySRA)->RA_MAT"
		cFim     := cFilialAte + cMatAte
	Else
		If nOrdem == 2
			If lQuery
				cQueryOrd := "RA_FILIAL, RA_CC, RA_MAT"
			Else
				dbSetOrder(2)
				SRA->( dbSeek( cFilialDe + cCustoDe + cMatDe, .T. ) )
			Endif
			cInicio  := "(cQrySRA)->RA_FILIAL + (cQrySRA)->RA_CC + (cQrySRA)->RA_MAT"
			cFim     := cFilialAte + cCustoAte + cMatAte
		Elseif nOrdem == 3
			If lQuery
				cQueryOrd := "RA_FILIAL, RA_NOME, RA_MAT"
			Else
				dbSetOrder(3)
				SRA->( dbSeek( cFilialDe + cNomeDe + cMatDe, .T.) )
			Endif
			cInicio	:= "(cQrySRA)->RA_FILIAL + (cQrySRA)->RA_NOME + (cQrySRA)->RA_MAT"
			cFim	:= cFilialAte + cNomeAte + cMatAte
		Endif
	Endif


	If lQuery
		//Filtra do SRA: filial, matricula de/ate, centro de custo de/ate, categoria e situacoes
		cAlias := "SRA"
		cQrySRA := "QSRA"

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Buscar Situacao e Categoria em formato para SQL              ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cSitu   := "("
		For nAux := 1 To (Len( cSit )-1)
			cSitu += "'" + Substr( cSit, nAux, 1) + "',"
		Next nAux
		cSitu 	+= "'" + Substr( cSit, len(cSit), 1) + "')"

		cCateg   := "("
		For nAux := 1 To (Len( cCat )-1)
			cCateg += "'" + Substr( cCat, nAux, 1) + "',"
		Next nAux
		cCateg	+= "'" + Substr( cCat, len(cCat)-1, 1) + "')"

		// Verifica el Proceso
		lAllProCs 	:= Iif(AllTrim( cProcessos ) == "*" .Or. Empty(cProcessos), .F., .T.)

		//montagem da query
		cQuery := "SELECT "
		cQuery += "RA_FILIAL, RA_MAT, RA_CC, RA_CIC, RA_NOME, RA_NOMECMP, RA_ADMISSA, RA_PROCES "
		If lTXT
			cQuery +=", RA_CIC"
		EndIf
		cQuery += " FROM " + RetSqlName(cAlias)
		cQuery += " WHERE "
		cQuery += " RA_FILIAL BETWEEN '" + cFilialDe + "' AND '" + cFilialAte + "'"
		cQuery += "  AND "
		cQuery += " RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "'"
		cQuery += "  AND "
		cQuery += " RA_NOME BETWEEN '" + cNomeDe + "' AND '" + cNomeAte + "'"
		cQuery += "  AND "
		cQuery += " RA_CC BETWEEN '" + cCustoDe + "' AND '" + cCustoAte + "'"
		cQuery += "  AND "
		cQuery += " RA_SITFOLH IN " + cSitu
		cQuery += "  AND "
		cQuery += " RA_CATFUNC IN " + cCateg
		If !(lAllProCs)
			cQuery 	+= "AND RA_PROCES BETWEEN '" + cMnProces + "' AND '" + cMxProces + "'"
		Else
			cQuery	+= "AND   RA_PROCES  IN ("	+ cProcessos+") "
		Endif
		cQuery += "  AND "
		cQuery += " D_E_L_E_T_ <> '*'
		cQuery += " ORDER BY " + cQueryOrd

		cQuery := ChangeQuery(cQuery)
		aStruct := (cAlias)->(dbStruct())

		If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRA,.T.,.T.)
			For nAux := 1 To Len(aStruct)
				If ( aStruct[nAux][2] <> "C" )
					TcSetField(cQrySRA,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
				EndIf
			Next nAux
		Endif

		dbSelectArea(cQrySRA)
		(cQrySRA)->(dbGoTop())
	Endif

	//Carrega tabela S009
	fCarrTab(@aTabS009,"S009")

	If Len(aTabS009) > 0
		nPos 	:= aScan(aTabS009, { |x| x[1] == "S009" .And. cAno + cMes $ DTOS(x[5])})
	EndIf

	//carrega percentual do impoesto del 13% do mes correspondente e UFV
	dDataRef := If( nPos > 0, aTabS009[nPos][5], datavalida(ctod(Transform(f_UltDia(cToD("01/"+cMes+"/"+cAno)),"99")+"/"+cMes+"/"+cAno),.F.))

	If Len(aTabS009) > 0
		nPosAnt	:= aScan(aTabS009, { |x| x[1] == "S009" .And. ANOMES(MonthSub( dDataRef , 1 )) $ DTOS(x[5])})
	EndIf

	dDataAnt:= If(nPosAnt > 0, aTabS009[nPosAnt][5], datavalida(MonthSub( dDataRef , 1 ),.F.)) //subtrai um mes da data de referencia

	// Carrega codigos do Fondo Solidario
	cCod1Sol := FTABELA("S011",1,7)
	cCod2Sol := FTABELA("S011",2,7)
	cCod3Sol := FTABELA("S011",3,7)
	nPerIVA := IF( FTABELA("S001",1,4,dDataRef) <> NIL, FTABELA("S001",1,4,dDataRef),  0)
	If FTABELA("S001",1,4,dDataRef) == NIL .Or. Empty(FTABELA("S001",1,4,dDataRef))
		lMsgS001:=.T.
	EndIf
	If lMsgS001
		Help(" ",1,"GPR700S001")
		Return (.F.)
	EndIf

	//busca informacoes para gerar o nFatUFV
	nFatUFV:= nAux:= 0

	nAux:= FPosTab("S009", dDataRef, "=", 4)
	If nAux > 0
		nUFVAtu:= FTabela( "S009", nAux, 5 )
	Endif

	nAux2:= FPosTab("S009", dDataAnt, "=", 4)
	If nAux2 > 0
		nUFVAnt := FTabela("S009", nAux2, 5 )
	Endif

	If nUFVAtu > 0 .And. nUFVAnt > 0
		nFatUFV := nUFVAtu / nUFVAnt
	Endif

	//carrega periodo da competencia selecionada
	fRetPerComp( cMes , cAno , , , , @aPerAberto , @aPerFechado , @aPerTodos )

	While (cQrySRA)->( !Eof() .And. &cInicio <= cFim ) 


			If cFilAnt <> (cQrySRA)->RA_FILIAL//se a filial eh diferente da q acabou de imprimir, imprime rodape e
	
				/*If !lTXT     //If nLin <> 0380             // nao totaliza parcialmente por filial, e sim e consolidade por empresa.
				ImpRodape(nLin)
				nLin := 0380
				Endif
				*/
				fInfo(@aInfo,(cQrySRA)->RA_FILIAL)			// carrega dados da filial
	
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Carrega Variaveis Codigos Da Folha                           ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				If !fP_CodFol(@aCodFol,(cQrySRA)->RA_FILIAL)
					Return
				Endif
	
				cFilAnt := (cQrySRA)->RA_FILIAL
	
			Endif
	
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Consiste Parametrizacao do Intervalo de Impressao            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  !lQuery .And. (((cQrySRA)->RA_MAT < cMatDe)   .Or. ((cQrySRA)->RA_MAT > cMatAte)    .Or. ;
			((cQrySRA)->RA_CC  < cCustoDe) .Or. ((cQrySRA)->RA_CC  > cCustoAte)  .Or. ;
			((cQrySRA)->RA_NOME < cNomeDe) .Or. ((cQrySRA)->RA_NOME > cNomeAte)  .Or. ;
			!((cQrySRA)->RA_CATFUNC $ cCat) .Or. !((cQrySRA)->RA_SITFOLH $ cSit))
				(cQrySRA)->(dbSkip())
				Loop
			EndIf
	
			If (cQrySRA)->RA_ADMISSA > dDataRef  //se o funcionario foi admitido depois da competencia selecionada
				(cQrySRA)->(dbSkip())
				Loop
			Endif
	
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Consiste Filiais e Acessos                                             ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			IF !((cQrySRA)->RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA )
				dbSelectArea("SRA")
				(cQrySRA)->( dbSkip() )
				Loop
			Endif
			
			//zera as variaveis para cada funcionario
			nTotGanad := nSuelNeto := nMinNoImp := 0
			nIVAForm  := nDifSuj   := nImp13	 := 0
			n13Suel   := nSaldoFis := nAFavDep  := 0
			nNetoIva  := 0
			nSalMesAnt:= nFavAct   := nDepTot   := 0
			nSalUtil  := nImpRetPag:= nSalMesSeg:= 0
			nSalFavDep:= nAfp      := nASol     := 0
			nBVac     := nForm110  := 0
			nIvaNoCot := 0
	
			nColW	  := 0
			nColX	  := 0
			nColY	  := 0
			nColZ	  := 0
			nColAA	  := 0
			nColAD	  := 0
			lReg      := .F.
			nAuxMin:= 	IF( FTABELA("S005",1,2,cMesAno) <> NIL, FTABELA("S005",1,4,cMesAno), lMsgS001:= .T.)
	
			If lMsgS001
				Help(" ",1,"GPR700S005")
				Return (.F.)
			EndIf
	
			n2SM:= (2* (IIF(ValType(nAuxMin) == 'C',Val(nAuxMin),nAuxMin)))
			n13SM := Round(n2SM*nPerIVA*0.01,0)
	
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Procura no SRC registros do funcionario no periodo aberto, se houver   |
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If !(len(aPerAberto) < 1)
				If lQuery
					cAlias := "SRC"
					cQrySRC := "QSRC"
	
					//busca periodos para formato Query
					cPeriodos   := "("
					For nAux:= 1 to (len(aPerAberto)-1)
						cPeriodos += "'" + aPerAberto[nAux][1] + "',"
					Next nAux
					cPeriodos += "'" + aPerAberto[len(aPerAberto)][1]+"')"
	
					//montagem da query
					cQuery := "SELECT "
					cQuery += " RC_FILIAL, RC_MAT, RC_PROCES, RC_ROTEIR, RC_PERIODO,RC_SEMANA, RC_VALOR, RC_VNAOAPL, RC_PD "
					cQuery += " FROM " + RetSqlName(cAlias)
					cQuery += " WHERE "
					cQuery += " RC_FILIAL = '" + cFilAnt + "'"
					cQuery += " AND "
					cQuery += " RC_MAT = '" + (cQrySRA)->RA_MAT + "'"
					cQuery += " AND "
					cQuery += " RC_PERIODO IN " + cPeriodos
					cQuery += " AND "
					cQuery += " RC_ROTEIR	IN ("	+ cProcedi  +") "
					cQuery += " AND "
					cQuery += " D_E_L_E_T_ <> '*'
					cQuery += " ORDER BY RC_FILIAL, RC_MAT, RC_PROCES, RC_ROTEIR, RC_PERIODO,RC_SEMANA "
	
					cQuery := ChangeQuery(cQuery)
					aStruct := (cAlias)->(dbStruct())
	
					If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRC,.T.,.T.)
						For nAux := 1 To Len(aStruct)
							If ( aStruct[nAux][2] <> "C" )
								TcSetField(cQrySRC,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
							EndIf
						Next nAux
					Endif
				Else
					dbSelectArea(cQrySRC)
					dbSetOrder(6)
				Endif
	
				While (cQrySRC)->(!Eof()) .And. (cQrySRA)->(RA_FILIAL+RA_MAT) == (cQrySRC)->(RC_FILIAL+RC_MAT)
					Do Case
						Case (cQrySRC)->RC_PD == aCodFol[747,1]
						nTotGanad+= (cQrySRC)->RC_VALOR
						nTotGan	 += (cQrySRC)->RC_VALOR // Totalizador Total Ganado
						lReg      := .T.
						Case (cQrySRC)->RC_PD == aCodFol[0054,1] // desconta faltas do Ganho para bater liquido.
						If PosSrv( aCodFol[0054,1],(cQrySRC)->RC_FILIAL,"RV_IR" ) == "S"
							nTotGanad -= (cQrySRC)->RC_VALOR
							nTotGan   -= (cQrySRC)->RC_VALOR // totalizador Total Ganado
							lReg      := .T.
						EndIf
						Case (cQrySRC)->RC_PD == aCodFol[1237,1] // desconta domingos do Ganho para bater liquido.
							nTotGanad -= (cQrySRC)->RC_VALOR
							nTotGan   -= (cQrySRC)->RC_VALOR // totalizador Total Ganado
							lReg      := .T.
						Case (cQrySRC)->RC_PD == aCodFol[728,1]
							nAfp    += (cQrySRC)->RC_VALOR
							ntotAfp += (cQrySRC)->RC_VALOR
						Case (cQrySRC)->RC_PD == aCodFol[729,1]
							nAfp    += (cQrySRC)->RC_VALOR
							ntotAfp += (cQrySRC)->RC_VALOR
						Case (cQrySRC)->RC_PD == aCodFol[730,1]
							nAfp    += (cQrySRC)->RC_VALOR
							ntotAfp += (cQrySRC)->RC_VALOR
						Case (cQrySRC)->RC_PD == aCodFol[1228,1]
							nAfp    += (cQrySRC)->RC_VALOR
							ntotAfp += (cQrySRC)->RC_VALOR
						Case (cQrySRC)->RC_PD == cCod1Sol
							nASol    += (cQrySRC)->RC_VALOR
							nTotASol += (cQrySRC)->RC_VALOR
						Case (cQrySRC)->RC_PD == cCod2Sol
							nASol    += (cQrySRC)->RC_VALOR
							nTotASol += (cQrySRC)->RC_VALOR
						Case (cQrySRC)->RC_PD == cCod3Sol
							nASol    += (cQrySRC)->RC_VALOR
							nTotASol += (cQrySRC)->RC_VALOR
						Case (cQrySRC)->RC_PD == aCodFol[072,1]
							nBVac    += (cQrySRC)->RC_VALOR
							nTotBVac += (cQrySRC)->RC_VALOR
						Case (cQrySRC)->RC_PD == aCodFol[086,1]
							nBVac    += (cQrySRC)->RC_VALOR
							nTotBVac += (cQrySRC)->RC_VALOR
						Case (cQrySRC)->RC_PD == aCodFol[087,1]
							nBVac    += (cQrySRC)->RC_VALOR
							nTotBVac += (cQrySRC)->RC_VALOR
						Case (cQrySRC)->RC_PD == aCodFol[084,1]
							nBVac    += (cQrySRC)->RC_VALOR
							nTotBVac += (cQrySRC)->RC_VALOR
						Case (cQrySRC)->RC_PD == aCodFol[066,1]
							nImpRetPag += (cQrySRC)->RC_VALOR
						Case (cQrySRC)->RC_PD == aCodFol[733,1]
							nSalMesSeg += (cQrySRC)->RC_VNAOAPL
						Case (cQrySRC)->RC_PD == aCodFol[015,1]
							nSuelNeto+= (cQrySRC)->RC_VALOR
							nTotSuel += (cQrySRC)->RC_VALOR //Totalizador Sueldos Netos
							lReg      := .T.
						Case (cQrySRC)->RC_PD == aCodFol[746,1]
							nMinNoImp+= (cQrySRC)->RC_VALOR
							nTotMin  += (cQrySRC)->RC_VALOR //Totalizador Minimo no Imponible
							lReg      := .T.
						Case (cQrySRC)->RC_PD == aCodFol[732,1]
							nIVAForm += ROUND((cQrySRC)->RC_VALOR,0) //Arredonda de acordo com legislacao informada no chamado TELLL2
							nTotIVA  += ROUND((cQrySRC)->RC_VALOR,0)  //Totalizador IVA Form 110
							nForm110 := (cQrySRC)->RC_VALOR
							lReg     := .T.
						Case (cQrySRC)->RC_PD == PosSrv( FGetCodFol("0733"),SRA->RA_FILIAL,"RV_CODMSEG" )
							nSalMesAnt+= (cQrySRC)->RC_VALOR
							nTotAnt	  += (cQrySRC)->RC_VALOR  //Totalizador Saldo Mes Ant
							lReg	  := .T.
						Case (cQrySRC)->RC_PD == aCodFol[1888,1]
							nColX += (cQrySRC)->RC_VALOR
						Case (cQrySRC)->RC_PD == aCodFol[1889,1]
							nColY += (cQrySRC)->RC_VALOR
					EndCase
					(cQrySRC)->(dbSkip())
				End
				(cQrySRC)->(dbCloseArea())
			Endif
	
			nTotGan:= nTotGan - nBVac
			nTotGanad:= nTotGanad - nBVac
			nIvaNoCot:= Round(nBVac * nPerIVA * 0.01,2)
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Procura no SRD registros do funcionario no periodo fechado, se houver  |
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If	!(len(aPerFechado) < 1)
				If lQuery
					cAlias := "SRD"
					cQrySRD := "QSRD"
	
					//busca periodos para formato Query
					cPeriodos   := "("
					For nAux:= 1 to (len(aPerFechado)-1)
						cPeriodos += "'" + aPerFechado[nAux][1] + "',"
					Next nAux
					cPeriodos += "'" + aPerFechado[len(aPerFechado)][1]+"')"
	
					//montagem da query
					cQuery := "SELECT "
					cQuery += " RD_FILIAL, RD_MAT, RD_PROCES, RD_ROTEIR, RD_PERIODO, RD_SEMANA, RD_VALOR, RD_VNAOAPL, RD_PD "
					cQuery += " FROM " + RetSqlName(cAlias)
					cQuery += " WHERE "
					cQuery += " RD_FILIAL = '" + cFilAnt + "'"
					cQuery += " AND "
					cQuery += " RD_MAT = '" + (cQrySRA)->RA_MAT + "'"
					cQuery += " AND "
					cQuery += " RD_PERIODO IN " + cPeriodos
					cQuery += " AND "
					cQuery += " RD_ROTEIR	IN ("	+ cProcedi  +") "
					cQuery += " AND "
					cQuery += " D_E_L_E_T_ <> '*'
					cQuery += " ORDER BY RD_FILIAL, RD_MAT, RD_PROCES, RD_ROTEIR, RD_PERIODO, RD_SEMANA"
	
					cQuery := ChangeQuery(cQuery)
					aStruct := (cAlias)->(dbStruct())
					If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRD,.T.,.T.)
						For nAux := 1 To Len(aStruct)
							If ( aStruct[nAux][2] <> "C" )
								TcSetField(cQrySRD,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
							EndIf
						Next nAux
					Endif
				Else
					dbSelectArea(cQrySRD)
					dbSetOrder(5)
				Endif
	
				While (cQrySRD)->(!Eof()) .And.  (cQrySRA)->(RA_FILIAL+RA_MAT) == (cQrySRD)->(RD_FILIAL+RD_MAT)
					Do Case
						Case (cQrySRD)->RD_PD == aCodFol[747,1]
							nTotGanad += (cQrySRD)->RD_VALOR
							nTotGan   += (cQrySRD)->RD_VALOR // totalizador Total Ganado
							lReg      := .T.
						Case (cQrySRD)->RD_PD == aCodFol[0054,1] // desconta faltas do Ganho para bater liquido.
							nTotGanad -= (cQrySRD)->RD_VALOR
							nTotGan   -= (cQrySRD)->RD_VALOR // totalizador Total Ganado
							lReg      := .T.
						Case (cQrySRD)->RD_PD == aCodFol[1237,1] // desconta domingos do Ganho para bater liquido.
							nTotGanad -= (cQrySRD)->RD_VALOR
							nTotGan   -= (cQrySRD)->RD_VALOR // totalizador Total Ganado
							lReg      := .T.
						Case (cQrySRD)->RD_PD == aCodFol[728,1]
							nAfp    += (cQrySRD)->RD_VALOR
							ntotAfp += (cQrySRD)->RD_VALOR
						Case (cQrySRD)->RD_PD == aCodFol[729,1]
							nAfp    += (cQrySRD)->RD_VALOR
							ntotAfp += (cQrySRD)->RD_VALOR
						Case (cQrySRD)->RD_PD == aCodFol[730,1]
							nAfp    += (cQrySRD)->RD_VALOR
							ntotAfp += (cQrySRD)->RD_VALOR
						Case (cQrySRD)->RD_PD == aCodFol[1228,1]
							nAfp    += (cQrySRD)->RD_VALOR
							ntotAfp += (cQrySRD)->RD_VALOR
						Case (cQrySRD)->RD_PD == cCod1Sol
							nASol    += (cQrySRD)->RD_VALOR
							nTotASol += (cQrySRD)->RD_VALOR
						Case (cQrySRD)->RD_PD == cCod2Sol
							nASol    += (cQrySRD)->RD_VALOR
							nTotASol += (cQrySRD)->RD_VALOR
						Case (cQrySRD)->RD_PD == cCod3Sol
							nASol    += (cQrySRD)->RD_VALOR
							nTotASol += (cQrySRD)->RD_VALOR
						Case (cQrySRD)->RD_PD == aCodFol[072,1]
							nBVac    += (cQrySRD)->RD_VALOR
							nTotBVac += (cQrySRD)->RD_VALOR
						Case (cQrySRD)->RD_PD == aCodFol[086,1]
							nBVac    += (cQrySRD)->RD_VALOR
							nTotBVac += (cQrySRD)->RD_VALOR
						Case (cQrySRD)->RD_PD == aCodFol[087,1]
							nBVac    += (cQrySRD)->RD_VALOR
							nTotBVac += (cQrySRD)->RD_VALOR
						Case (cQrySRD)->RD_PD == aCodFol[084,1]
							nBVac    += (cQrySRD)->RD_VALOR
							nTotBVac += (cQrySRD)->RD_VALOR
						Case (cQrySRD)->RD_PD == aCodFol[066,1]
							nImpRetPag += (cQrySRD)->RD_VALOR
						Case (cQrySRD)->RD_PD == aCodFol[733,1]
							nSalMesSeg += (cQrySRD)->RD_VNAOAPL
						Case (cQrySRD)->RD_PD == aCodFol[015,1]
							nSuelNeto+= (cQrySRD)->RD_VALOR
							nTotSuel += (cQrySRD)->RD_VALOR //totalizador Sueldos Netos
							lReg      := .T.
						Case (cQrySRD)->RD_PD == aCodFol[746,1]
							nMinNoImp+= (cQrySRD)->RD_VALOR
							nTotMin  += (cQrySRD)->RD_VALOR //totalizador Minimo no Imponible
							lReg      := .T.
						Case (cQrySRD)->RD_PD == aCodFol[732,1]
							nIVAForm += ROUND((cQrySRD)->RD_VALOR,0) //Arredonda de acordo com legislacao informada no chamado TELLL2
							nTotIVA  += ROUND((cQrySRD)->RD_VALOR,0) //totalizador IVA Form 110
							nForm110 := (cQrySRD)->RD_VALOR
							lReg     := .T.
						Case (cQrySRD)->RD_PD == PosSrv( FGetCodFol("0733"),SRA->RA_FILIAL,"RV_CODMSEG" )
							nSalMesAnt+= (cQrySRD)->RD_VALOR
							nTotAnt	  += (cQrySRD)->RD_VALOR
							lReg	  := .T.
						Case (cQrySRD)->RD_PD == aCodFol[1888,1]
							nColX+= (cQrySRD)->RD_VALOR
						Case (cQrySRD)->RD_PD == aCodFol[1889,1]
							nColY+= (cQrySRD)->RD_VALOR
					EndCase
					(cQrySRD)->(dbSkip())
				End
				(cQrySRD)->(dbCloseArea())
			Endif
	
			nTotGan:= nTotGan - nBVac
			nTotGanad:= nTotGanad - nBVac
			nIvaNoCot:= Round(nBVac * nPerIVA * 0.01,2)
	
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Se houver registros no SRC ou SRD calcula o q falta e imprime os dados do func. |
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If lReg
				//  Dif Suj a Impuesto
				nDifSuj   := IIF(nSuelNeto > nMinNoImp, nSuelNeto - nMinNoImp, 0)
				nTotDif	+= nDifSuj //totalizador DifSuj a impuesto
	
				//  Impuesto Del 13%
				nImp13	  := Round(nDifSuj*nPerIVA*0.01,2)
				nTot13 += nImp13 //Totalizador Impuesto del 13%
	
				//  13% Sobre 2 Suel Min
				If nImp13 > 0
					n13Suel	:= Round(nMinNoImp*nPerIVA*0.01,2)
				EndIf
	
				If nImp13 > n13Suel
					nNetoIva:= nImp13 - n13Suel
				EndIf
	
				nTot2Suel += n13Suel  //totalizador 13% sobre 2 Suel Min
	
				//Saldo a Favor Fisco / Dependiente
				nSaldoFis:=  nImp13 - (n13Suel + nIVAForm)   //Fisco
				If nSaldoFis < 0
					nAFavDep := ABS(nSaldoFis) //Dependiente
					nTotDep+=nAFavDep
					nSaldoFis:= 0
				Endif
				nTotFis+=nSaldoFis //totalizador Saldo Fisco
	
				//Actualizacion
				If((nFatUFV-1) > 0)
					nFavAct:= (nSalMesAnt*(nFatUFV-1))
				Else
					nFavAct:= nSalMesAnt
				EndIf

				nFavAct:= Round(nFavAct, 0)
				nTotAtu+=nFavAct //Totalizador Actualizacion
	
				//Saldo a favor del Dependiente Total
				nDepTot:= nSalMesAnt + nFavAct
				nTotSUtil+=nDepTot //Totalizador Saldo Actualizado
	
				//Saldo a favor del Dependiente
				nSalFavDep:= nDepTot+ nAFavDep
				nTotSFD+=nSalFavDep //totalizador Saldo a favor del Dependiente
	
				If(nDepTot <= nSaldoFis)
					nSalUtil := nDepTot  
				Else
					nSalUtil := nSaldoFis
				EndIf
				
				//Saldo Utilizado  / Impuesto Ret Pagar
				nTotSU+=nSalUtil  //Totalizador Saldo Utilizado
				nTotMSeg+=nSalMesSeg  //Totalizador Saldo Fav Mes Segte

				//Nuevas columnas RC-IVA V3
				If( nSaldoFis > nSalUtil)//Columna W: Saldo RC-IVA sujeto a retención
					nColW:= nSaldoFis - nSalUtil
				EndIf
				nColZ:= nColX + nColY//Columna Z: Total saldo pago a cuenta SIETE-RG del periodo

				If(nColW >= nColZ)//Columna AA: Pago a cuenta SIETE-RG utilizado
					nColAA:= nColZ
				Else
					nColAA:= nColW
				EndIf
				nImpRetPag := nColW - nColAA
				nColAD:= nColZ - nColAA//Columna AD: Saldo de pago a cuenta SIETE-RG a favor del Dependiente para el mes siguiente

				nTotIRP+=nImpRetPag //Totalizador Imposto Retido a Pagar
	
				If lTXT
					G705Grava()	//Grava reg. arq. temporario
				Else
					//controle de impressao
					If nLin == 0430
						ImpCabec()
					Endif
	
					ImpInfFunc(@nLin)
					nLin+= 30
	
					If nLin > 2200
						oPrint:EndPage()
						//ImpRodape(@nLin)     // nao totaliza parcialmente por filial, e sim e consolidade por empresa.
						nLin := 0430
					Endif
				Endif
			Endif
		(cQrySRA)->(dbSkip())
	EndDo

	// imprime totalizador vertical
	If !lTXT

		// imprime totalizador horizontal
		If  nLin > 0430 .And. nLin < 2200
			ImpRodape(@nLin)
			nLin := 0430
		Endif

		fInfo(@aInfo,cFilialDe)			// carrega dados da filial

		If ( nLin >= 0430	 .Or.	nLin < 2200 )

			oPrint:StartPage() 			//Inicia uma nova pagina

			//linea 1
			oPrint:say ( 0050, 0055, "SIGA/GPER700" ,oFont09)    //wnrel
			oPrint:say ( 0050, 3100, "Pagina "+ltrim(str(++nPage)),oFont09)
			// linea 2
			oPrint:say ( 0080, 0055, STR0008 + cTime      , oFont09)	//"HORA: "
			oPrint:say ( 0080, 1550, STR0001			   , oFont09)	//"PLANILLA RC-IVA"
			oPrint:say ( 0080, 3030, STR0007 + DToC(dData), oFont09)   //"FECHA: "

			//linea 3
			oPrint:say ( 0125, 1350, STR0009+" "+Upper(ALLTrim(MesExtenso(cMes)))+" "+STR0010 +" "+cAno+".", oFont09  )   //"CORRESPONDIENTE AL MES DE "

			//linea 4
			oPrint:say ( 0185, 0055, STR0056 + aInfo[3],	oFont09)   // Empresa
			oPrint:say ( 0185, 2830, STR0058 + aInfo[8],	oFont09)   // No CNPJ

			//linea 4
			oPrint:say ( 0220, 0055, STR0057 + aInfo[4],	oFont09)   // Endereco

			ImpTotais(@nLin)
		Endif

	Endif

	If !lQuery
		dbSelectArea("SRA")
		dbSetOrder(nSavOrdem)
		dbGoTo(nSavRec)
	Endif

	If lQuery
		If Select(cQrySRA) > 0
			(cQrySRA)->(dbCloseArea())
		Endif
		If Select(cQrySRD) > 0
			(cQrySRD)->(dbCloseArea())
		Endif
	EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpCabec  ºAutor  ³Erika Kanamori      º Data ³  03/19/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do cabecalho.                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpCabec()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PLANILLA RC-IVA                                                             |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:StartPage() 			//Inicia uma nova pagina

	//linea 1
	oPrint:say ( 0050, 0055, "SIGA/GPER700" ,oFont09)    //wnrel

	// linea 2
	oPrint:say ( 0080, 0055, STR0008 + cTime      , oFont09)	//"HORA: "
	oPrint:say ( 0080, 1550, STR0001			   , oFont09)	//"PLANILLA RC-IVA"
	oPrint:say ( 0080, 3030, STR0007 + DToC(dData), oFont09)   //"FECHA: "

	//linea 3
	oPrint:say ( 0125, 1350, STR0009+" "+Upper(ALLTrim(MesExtenso(cMes)))+" "+STR0010 +" "+cAno+".", oFont09  )   //"CORRESPONDIENTE AL MES DE "

	//linea 4
	oPrint:say ( 0185, 0055, STR0056 + aInfo[3],	oFont09)   // Empresa
	oPrint:say ( 0185, 2830, STR0058 + aInfo[8],	oFont09)   // No CNPJ

	//linea 4
	oPrint:say ( 0220, 0055, STR0057 + aInfo[4],	oFont09)   // Endereco

	// imprime valor de UFV
	oPrint:say ( 0290, 0350, "UFV ACTUAL DE FECHA " +dtoc(dDataRef)+ ": " + Transform(nUfvAtu,"999.99"), oFont09)
	oPrint:say ( 0290, 1295, "UFV ANTERIOR DE FECHA " +dtoc(dDataAnt)+": "+ Transform(nUfvAnt,"999.99"), oFont09)
	oPrint:say ( 0290, 2300, "SMN DEL MES / "+ cAno + " : "+ Transform(nAuxMin,"9,999.99"), oFont09)

	//oPrint:say ( 0185, 1100, Replicate("-", 70), oFont09)
	//oPrint:say ( 0190, 1100, Replicate("-", 70), oFont09)

	oPrint:say ( 0340, 0010, Replicate("-", 230), oFont09)

	oPrint:say ( 0375, 0050, STR0011, oFont06)		//"COD.
	oPrint:say ( 0375, 0130, STR0012, oFont06)		//"APELLIDO Y NOMBRES"

	oPrint:say ( 0365, 0580, STR0013, oFont06)		//"TOTAL"
	oPrint:say ( 0395, 0572, STR0028, oFont06)		//"GANADO"

	oPrint:say ( 0365, 0715, STR0044, oFont06)		//"RETENC"
	oPrint:say ( 0395, 0728, STR0045, oFont06)		//"AFP"

	oPrint:say ( 0365, 0865, STR0046, oFont06)		//"APORTE"
	oPrint:say ( 0395, 0865, STR0047, oFont06)		//"SOLID"

	oPrint:say ( 0365, 1000, STR0014, oFont06)		//"SUELDOS"
	oPrint:say ( 0395, 1005, STR0029, oFont06)		//"NETOS"

	oPrint:say ( 0365, 1135, STR0015, oFont06)		//"MINIMO NO"
	oPrint:say ( 0395, 1135, STR0030, oFont06)		//"IMPONIBLE"

	oPrint:say ( 0365, 1305, STR0016, oFont06)		//"DIF. SUJ"
	oPrint:say ( 0395, 1310, STR0031, oFont06)		//"A IMPUE"

	oPrint:say ( 0365, 1465, STR0017, oFont06)		       					 //"IMPUESTO"
	oPrint:say ( 0395, 1470, STR0032 +alltrim(str(nPerIVA))+"%", oFont06)  //"DEL 13%"

	oPrint:say ( 0365, 1630, STR0048, oFont06)		//"OTROS B"
	oPrint:say ( 0395, 1635, STR0049, oFont06)		//"VACAC."

	oPrint:say ( 0365, 1815, STR0018, oFont06)		//"IVA"
	oPrint:say ( 0395, 1775, STR0033, oFont06)		//"FORM. 110"

	oPrint:say ( 0365, 1925, alltrim(str(nPerIVA))+STR0019, oFont06)		//"13% SOBRE"
	oPrint:say ( 0395, 1920, STR0034, oFont06)							    //"2 SAL. MIN"

	oPrint:say ( 0365, 2130, STR0020, oFont06)		//"SALDO"
	oPrint:say ( 0395, 2130, STR0035, oFont06)		//"FISCO"

	oPrint:say ( 0365, 2260, STR0021, oFont06)		//"A FAVOR"
	oPrint:say ( 0395, 2270, STR0036, oFont06)		//"DEPEND"

	oPrint:say ( 0365, 2420, STR0020, oFont06)		//"SALDO A"
	oPrint:say ( 0395, 2410, STR0037, oFont06)		//"MES ANT"

	oPrint:say ( 0375, 2530, "ACTUALIZ.", oFont06)	//"ACTUALIZACION"

	oPrint:say ( 0365, 2700, STR0020, oFont06)		//"SALDO"
	oPrint:say ( 0395, 2695, STR0050, oFont06)     //"ACTUAL."

	oPrint:say ( 0365, 2815, STR0025, oFont06)		//"SALDO FAV"
	oPrint:say ( 0395, 2815, STR0039, oFont06)		//"DEL DEPEND"

	oPrint:say ( 0365, 2980, STR0020, oFont06)		//"SALDO"
	oPrint:say ( 0395, 2980, STR0040, oFont06)		//"UTILIZADO"

	oPrint:say ( 0365, 3130, STR0026, oFont06)		//"IMPUESTOS"
	oPrint:say ( 0395, 3125, STR0041, oFont06)		//"RET. PAGAR"

	oPrint:say ( 0365, 3295, STR0027, oFont06)		//"SALD-FAV"
	oPrint:say ( 0395, 3295, STR0042, oFont06)		//"MES SGTE"


	oPrint:say ( 0405, 0010, Replicate("-", 230), oFont09)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpInfFuncºAutor  ³Erika Kanamori      º Data ³  03/19/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao das informacoes do funcionario.                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpInfFunc(nLin)

	Local cNome := If( !Empty((cQrySRA)->RA_NOMECMP), (cQrySRA)->RA_NOMECMP, (cQrySRA)->RA_NOME )

	oPrint:say ( nLin, 0047, (cQrySRA)->RA_MAT, oFont06)
	oPrint:say ( nLin, 0130, SubStr(cNome,1,28), oFont06)
	oPrint:say ( nLin, 0490, Transform(nTotGanad , "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 0635, Transform(nAfp      , "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 0785, Transform(nASol     , "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 0940, Transform(nSuelNeto , "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 1095, Transform(n2SM      , "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 1250, Transform(nDifSuj   , "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 1410, Transform(nImp13    , "9,999,999.99"), oFont06)//(9)
	oPrint:say ( nLin, 1570, Transform(nBVac     , "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 1720, Transform(nIVAForm  , "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 1890, Transform(n13Suel	  , "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 2040, Transform(nSaldoFis , "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 2190, Transform(nAFavDep  , "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 2310, Transform(nSalMesAnt, "9,999,999.99"), oFont06)//(15)
	oPrint:say ( nLin, 2490, Transform(nFavAct   , "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 2640, Transform(nDepTot   , "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 2790, Transform(nSalFavDep, "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 2940, Transform(nSalUtil  , "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 3090, Transform(nColW  	 , "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 3240, Transform(nColX  	 , "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 3390, Transform(nColY  	 , "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 3540, Transform(nColZ  	 , "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 3690, Transform(nColAA  	 , "9,999,999.99"), oFont06)

	oPrint:say ( nLin, 3840, Transform(nImpRetPag, "9,999,999.99"), oFont06)
	oPrint:say ( nLin, 3990, Transform(nSalMesSeg, "9,999,999.99"), oFont06)

	oPrint:say ( nLin, 4140, Transform(nColAD  	 , "9,999,999.99"), oFont06)

	oPrint:say ( nLin, 4290, Transform(nForm110,   "9,999,999.99"), oFont06)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpTotais ºAutor  ³Luciana Silveira    º Data ³  29/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao dos Totais da Planilha.                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpTotais(nLin)
	nLin:= 0430
	oPrint:say ( nLin, 0050, "TOTAL DE LA PLANILLA", oFont09n )
	nLin+= 80
	oPrint:say ( nLin, 0050, Left("TOTAL GANADO" 				+ Space(40),40)	+ Transform(nTotGan,	"999,999,999.99"), oFont07)
	nLin+= 40
	oPrint:say ( nLin, 0050, Left("RETENCION AFP" 				+ Space(40),40)	+ Transform(nTotAfp,	"999,999,999.99"), oFont07)
	nLin+= 40
	oPrint:say ( nLin, 0050, Left("APORTE SOLIDARIO"			+ Space(40),40)	+ Transform(nTotASol,	"999,999,999.99"), oFont07)
	nLin+= 40
	oPrint:say ( nLin, 0050, Left("SUELDOS NETOS" 				+ Space(40),40)	+ Transform(nTotSuel,	"999,999,999.99"), oFont07)
	nLin+= 40
	oPrint:say ( nLin, 0050, Left("MINIMO NO IMPONIBLE"			+ Space(40),40)	+ Transform(nTotMin,	"999,999,999.99"), oFont07)
	nLin+= 40
	oPrint:say ( nLin, 0050, Left("DIF SUJ. A IMPUESTO" 		+ Space(40),40)	+ Transform(nTotDif,	"999,999,999.99"), oFont07)
	nLin+= 40
	oPrint:say ( nLin, 0050, Left("IMPUESTO DEL 13%" 			+ Space(40),40)	+ Transform(nTot13,		"999,999,999.99"), oFont07)
	nLin+= 40
	oPrint:say ( nLin, 0050, Left("OTROS BONOS VACACIONES " 	+ Space(40),40)	+ Transform(nTotBVac,	"999,999,999.99"), oFont07)
	nLin+= 40
	oPrint:say ( nLin, 0050, Left("IVA FORM 110" 				+ Space(40),40)	+ Transform(nTotIVA,	"999,999,999.99"), oFont07)
	nLin+= 40
	oPrint:say ( nLin, 0050, Left("13% SOBRE 2 SUEL MIN" 		+ Space(40),40)	+ Transform(nTot2Suel,	"999,999,999.99"), oFont07)
	nLin+= 40
	oPrint:say ( nLin, 0050, Left("SALDO FISCO" 				+ Space(40),40)	+ Transform(nTotFis,	"999,999,999.99"), oFont07)
	nLin+= 40
	oPrint:say ( nLin, 0050, Left("A FAVOR DEPENDIENTE" 		+ Space(40),40)	+ Transform(nTotDep,	"999,999,999.99"), oFont07)
	nLin+= 40
	oPrint:say ( nLin, 0050, Left("SALDO MES ANT" 				+ Space(40),40)	+ Transform(nTotAnt,	"999,999,999.99"), oFont07)
	nLin+= 40
	oPrint:say ( nLin, 0050, Left("ACTUALIZACION" 				+ Space(40),40)	+ Transform(nTotAtu,	"999,999,999.99"), oFont07)
	nLin+= 40
	oPrint:say ( nLin, 0050, Left("SALDO ACTUALIZADO" 			+ Space(40),40)	+ Transform(nTotSUtil,	"999,999,999.99"), oFont07)
	nLin+= 40
	oPrint:say ( nLin, 0050, Left("SALDO FAV DEL DEPENDIENTE"	+ Space(40),40)+ Transform(nTotSFD,	"999,999,999.99"), oFont07)
	nLin+= 40
	oPrint:say ( nLin, 0050, Left("SALDO UTILIZADO" 			+ Space(40),40)	+ Transform(NTotSU,		"999,999,999.99"), oFont07)
	nLin+= 40
	oPrint:say ( nLin, 0050, Left("IMPUESTO RET. PAGAR" 		+ Space(40),40)	+ Transform(nTotIRP,	"999,999,999.99"), oFont07)
	nLin+= 40
	oPrint:say ( nLin, 0050, Left("SALDO FAV MES SEGTE" 		+ Space(40),40)	+ Transform(nTotMSeg,	"999,999,999.99"), oFont07)
	nLin+= 40
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpRodape ºAutor  ³Erika Kanamori      º Data ³  03/19/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do rodape.                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpRodape(nLin)

	// imprime n da pagina na pagina final
	oPrint:say ( 0050, 3100, "Pagina "+ltrim(str(++nPage)),oFont09)

	nLin+= 100
	// imprime totalizador da pagina colunas impares
	oPrint:say ( nLin, 0483, Transform(nTotGan  , "9,999,999.99"), oFont06)//01
	oPrint:say ( nLin, 0770, Transform(nTotASol , "9,999,999.99"), oFont06)//03
	oPrint:say ( nLin, 1080, Transform(nTotMin  , "9,999,999.99"), oFont06)//05
	oPrint:say ( nLin, 1408, Transform(nTot13   , "9,999,999.99"), oFont06)//07
	oPrint:say ( nLin, 1718, Transform(nTotIVA  , "9,999,999.99"), oFont06)//09
	oPrint:say ( nLin, 2038, Transform(nTotFis  , "9,999,999.99"), oFont06)//11
	oPrint:say ( nLin, 2328, Transform(nTotAnt  , "9,999,999.99"), oFont06)//13
	oPrint:say ( nLin, 2638, Transform(nTotSUtil, "9,999,999.99"), oFont06)//15
	oPrint:say ( nLin, 2938, Transform(NTotSU   , "9,999,999.99"), oFont06)//17
	oPrint:say ( nLin, 3240, Transform(nTotMSeg , "9,999,999.99"), oFont06)//19
	// imprime totalizador da pagina colunas pares
	nLin+= 25
	oPrint:say ( nLin, 0620, Transform(nTotAfp  , "9,999,999.99"), oFont06)//02
	oPrint:say ( nLin, 0936, Transform(nTotSuel , "9,999,999.99"), oFont06)//04
	oPrint:say ( nLin, 1248, Transform(nTotDif  , "9,999,999.99"), oFont06)//06
	oPrint:say ( nLin, 1568, Transform(nTotBVac , "9,999,999.99"), oFont06)//08
	oPrint:say ( nLin, 1888, Transform(nTot2Suel, "9,999,999.99"), oFont06)//10
	oPrint:say ( nLin, 2188, Transform(nTotDep  , "9,999,999.99"), oFont06)//12
	oPrint:say ( nLin, 2488, Transform(nTotAtu  , "9,999,999.99"), oFont06)//14
	oPrint:say ( nLin, 2788, Transform(nTotSFD  , "9,999,999.99"), oFont06)//16
	oPrint:say ( nLin, 3088, Transform(nTotIRP  , "9,999,999.99"), oFont06)//18

	oPrint:EndPage()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ GPR705Proc ³ Autor ³ Ricardo Berti	      ³ Data ³02/04/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Geracao do TXT RC-IVA  										³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER705                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPR705Proc()
	Private oTmpTable
	Private aOrder    := {}
	
	Pergunte("XGPR705",.F.)

	cFilialDe 	:= mv_par01
	cFilialAte  := mv_par02
	cMesAno		:= mv_par03
	cMes 		:= substr( mv_par03, 1, 2 )
	cAno 		:= substr( mv_par03, 3, 4 )
	cMatDe		:= mv_par04
	cMatAte     := mv_par05
	cCustoDe    := mv_par06
	cCustoAte   := mv_par07
	cNomeDe     := mv_par08
	cNomeAte    := mv_par09
	cSit        := mv_par10
	cCat        := mv_par11
	nOrdem		:= 1
	cArqNome	:= mv_par12				// Nome arquivo TXT
	cProcessos	:= If( Empty(mv_par13),"", ConvQry(alltrim(mv_par13),"RA_PROCES"))
	cProcedi	:= If( Empty(mv_par14),"", ConvQry(AllTrim(mv_par14),"RD_ROTEIR"))
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Variaveis utilizadas para parametros                         ³
	³ mv_par01        //  Filial De						           ³
	³ mv_par02        //  Filial Ate					           ³
	³ mv_par03        //  Mes/Ano Competencia ? 		           |
	³ mv_par04        //  Matricula De                             ³
	³ mv_par05        //  Matricula Ate                            ³
	³ mv_par06        //  Centro de Custo De                       ³
	³ mv_par07        //  Centro de Custo Ate                      ³
	³ mv_par08        //  Nome De                                  ³
	³ mv_par09        //  Nome Ate                                 ³
	³ mv_par10        //  Situacoes ?		                       ³
	³ mv_par11        //  Categorias ?      		               ³
	³ mv_par12        //  Path/Nome Arquivo TXT ?                  ³
	³ mv_par13        //  Processos ?              				   ³
	³ mv_par14        //  Roteiro ?                          	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	G705CriTMP()			//--- Cria arquivo temporario

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Processa os dados gravando arq. temporario   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IMPRCIVA(.T.)

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Gera o arquivo texto                         ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If Select(cAliasTMP) > 0 .And. (cAliasTMP)->(RecCount()) > 0

		G705GerTXT()

	Else
		MsgStop(STR0053+cArqNome)	// "Nao foi gerado o arquivo "
	Endif

	If Select(cAliasTMP) > 0
		dbSelectArea(cAliasTMP)
		dbCloseArea()
	EndIf

	If oTmpTable <> Nil   //JGR
		oTmpTable:Delete()  //JGR
		oTmpTable := Nil //JGR
	Endif //JGR

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ G705Grava  ³ Autor ³ Ricardo Berti	      ³ Data ³02/04/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Grava um registro no arq. temporario		                 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPR705Proc()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function G705Grava()

	RecLock(cAliasTMP,.T.)
	(cAliasTMP)->TMP_NIT	:= aInfo[8]
	(cAliasTMP)->TMP_ANO	:= cAno
	(cAliasTMP)->TMP_MES	:= cMes
	(cAliasTMP)->TMP_CI		:= (cQrySRA)->RA_CIC
	(cAliasTMP)->TMP_TGANAD	:= nTotGanad
	(cAliasTMP)->TMP_CREFIS	:= nForm110 //coluna 6 - IVA form 110
	(cAliasTMP)->TMP_RETENC	:= nImpRetPag
	(cAliasTMP)->TMP_SALSEG	:= nSalMesSeg
	(cAliasTMP)->(MsUnlock())

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³G705CriTMP³ Autor ³ Ricardo Berti	      	³ Data ³02/04/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria arquivo temporario                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³GPR705Proc()								  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function G705CriTMP()

	Local aArea		:= GetArea()
	Local aCampos   := {}
	Local cTrab

	cAliasTMP := GetNextAlias()

	aAdd( aCampos, { 'TMP_NIT'		, "C", 14	, 0 } )
	aAdd( aCampos, { 'TMP_ANO'		, "C",  4	, 0 } )
	aAdd( aCampos, { 'TMP_MES'		, "C",  2	, 0 } )
	aAdd( aCampos, { 'TMP_CI'		, "C", 12	, 0 } )
	aAdd( aCampos, { 'TMP_TGANAD'	, "N", 12	, 2 } )
	aAdd( aCampos, { 'TMP_CREFIS'	, "N", 12	, 2 } )
	aAdd( aCampos, { 'TMP_RETENC'	, "N", 12	, 2 } )
	aAdd( aCampos, { 'TMP_SALSEG'	, "N", 12	, 2 } )

	If Select(cAliasTMP) > 0
		dbSelectArea(cAliasTMP)
		dbCloseArea()
	EndIf

	//Efetua a criacao do arquivo temporario
	aOrder	:=	{"TMP_NIT"} //JGR
	oTmpTable := FWTemporaryTable():New(cAliasTMP) //JGR
	oTmpTable:SetFields( aCampos ) //JGR
	oTmpTable:AddIndex("I01", aOrder) //JGR
	oTmpTable:Create() //JGR

	RestArea( aArea )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ G705GerTXT   ³ Autor ³ Ricardo Berti	     ³ Data ³ 02/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que gera o arquivo texto                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPR705Proc()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function G705GerTXT()

	Local cLinDet	:= ""
	Local cSep	  	:= "|"
	Local nHandle 	:= MSFCREATE(cArqNome)

	If FERROR() # 0 .Or. nHandle < 0
		Help('',1, "OPENERROR",,STR0054+cArqNome,1)  // "Erro na criação do arquivo "
		FClose(nHandle)
		Return Nil
	EndIf

	dbSelectArea(cAliasTMP)
	dbGoTop()

	While !Eof()

		cLinDet	:=	AllTrim(TMP_NIT)			+cSep+;
		TMP_ANO						+cSep+;
		LTrim(Str(Val(TMP_MES)))	+cSep+;
		AllTrim(TMP_CI)	  			+cSep+;
		LTrim(Str(TMP_TGANAD,12,0))	+cSep+;
		LTrim(Str(TMP_CREFIS,12,0))	+cSep+;
		LTrim(Str(TMP_RETENC,12,0))	+cSep+;
		LTrim(Str(TMP_SALSEG,12,0))
		FWrite(nHandle,cLinDet+CRLF)

		dbSkip()
	EndDo
	FClose(nHandle)

	MsgInfo(STR0055) // "O arquivo foi gerado com sucesso."

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ConvQry   ºAutor  ³Microsiga           º Data ³  27/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³Convertir a expreción sql un campo informado con un listbox ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³   ConvQry(cExp,cExp1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³    cExp: Cadena de caracteres que retorna el litbox        ³±±
±±³          ³    cExp1: Campo del diccionario de datos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPEM005COS                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvQry(cLista,cCampo)
	Local cTxt:=''
	Local nTamReg := TamSX3(cCampo)[1]
	Local nCont:=0
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Genera texto para usar  para usar despues en Query             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	cLista:=alltrim(cLista)


	For nCont := 1 To Len( cLista ) Step nTamReg
		cTxt+="'"+SubStr( cLista , nCont , nTamReg )+"',"
	NEXT
	cTxt:=substr(cTxt,1,len(cTxt)-1)
Return ( cTxt )
