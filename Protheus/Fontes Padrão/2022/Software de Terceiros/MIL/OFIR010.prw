#include "OFIR010.CH"
#Include "PROTHEUS.Ch"
#INCLUDE "REPORT.CH"

/*/{Protheus.doc} OFIR010 "Relat�rio de Requisi��es e Devolu��es de pe�as"

	Pontos de entrada:
		N/A
	Parametros:
		N/A

	@author Renato Vinicius
	@since  04/10/2018
/*/

Function OFIR010()

Local oReport

	//-- Interface de impressao
	oReport := OR0100015_ReportDef()
	oReport:PrintDialog()

Return

/*/{Protheus.doc} OR0100015_ReportDef
Motagem da interface de impressao
@author Renato Vinicius
@since 04/10/2018
@version 1.0
@return objeto
@param
@type function
/*/

Static Function OR0100015_ReportDef()

Local cAliasQry := GetNextAlias()

Local oReport	:= Nil
Local oSection1	:= Nil
Local oSection2	:= Nil

Private cPerg	:= "OFIR010"

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������

OR0100035_ValidPerg(cPerg)

Pergunte(cPerg,.f.)

oReport := TReport():New("OFIR010",;
	STR0001,; //"Relat�rio de requisi��es e devolu��es de oficina"
	cPerg,;
	{|oReport| OR0100025_ReportPrint(oReport,cAliasQry)},;
	STR0002) //"Este relat�rio ir� imprimir as requisi��es e devolu��es de oficina"
	
oReport:nFontBody := 7
oReport:SetPortrait() // Define orienta��o de p�gina do relat�rio como retrato.
oReport:SetTotalInLine(.F.) //Define se os totalizadores ser�o impressos em linha ou coluna.


//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������

oSection1 := TRSection():New(oReport,STR0003,{"VO1","SA1"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)	//"Ordem de Servi�o"
oReport:Section(1):SetLineStyle() //Define se imprime as c�lulas da se��o em linhas.
oReport:Section(1):SetCols(3) //Define a quantidade de colunas a serem impressas.

TRCell():New(oSection1,"VO1_NUMOSV"	,"VO1"	,RetTitle("VO1_NUMOSV")	,PesqPict("VO1","VO1_NUMOSV")	,TamSx3("VO1_NUMOSV")[1],/*lPixel*/,{|| (cAliasQry)->VO1_NUMOSV },,,,.t.)
TRCell():New(oSection1,"VO1_CHASSI"	,"VO1"	,RetTitle("VO1_CHASSI")	,PesqPict("VO1","VO1_CHASSI")	,TamSx3("VO1_CHASSI")[1],/*lPixel*/,{|| (cAliasQry)->VO1_CHASSI },,,,.t.)
TRCell():New(oSection1,"cCLILOJ"	,		,STR0004				,PesqPict("VO1","VO1_PROVEI")+PesqPict("VO1","VO1_LOJPRO"),(TamSx3("VO1_PROVEI")[1]+TamSx3("VO1_LOJPRO")[1])+1,/*lPixel*/,{|| (cAliasQry)->VO1_PROVEI+"/"+(cAliasQry)->VO1_LOJPRO},,,,) //"Cliente / Loja"
TRCell():New(oSection1,"A1_NOME"	,"SA1"	,RetTitle("A1_NOME")	,PesqPict("SA1","A1_NOME")		,TamSx3("A1_NOME")[1]	,/*lPixel*/,{|| SA1->A1_NOME  },,,,)

oSection2 := TRSection():New(oSection1,STR0005,{"VO2","VO3"}) //"Movimenta��es"
oSection2:SetLeftMargin(3)

TRCell():New(oSection2,"VO2_NOSNUM"	,"VO2"	,RetTitle("VO2_NOSNUM")	,PesqPict("VO2","VO2_NOSNUM")	,TamSx3("VO2_NOSNUM")[1]	,/*lPixel*/,{|| (cAliasQry)->VO2_NOSNUM },,,,)  //Sequencial
TRCell():New(oSection2,"VO2_DATREQ"	,"VO2"	,RetTitle("VO2_DATREQ")	,PesqPict("VO2","VO2_DATREQ")	,TamSx3("VO2_DATREQ")[1]	,/*lPixel*/,{|| (cAliasQry)->VO2_DATREQ },,,,)  //Grupo do Item
TRCell():New(oSection2,"cTipMov"	,""		,STR0015				,"@!"							,3							,/*lPixel*/,{|| cTipMov := OR0100055_TipoMov((cAliasQry)->VO2_DEVOLU) },,,,) // C�digo do Item
TRCell():New(oSection2,"VO3_TIPTEM"	,"VO3"	,RetTitle("VO3_TIPTEM")	,PesqPict("VO3","VO3_TIPTEM")	,TamSx3("VO3_TIPTEM")[1]	,/*lPixel*/,{|| (cAliasQry)->VO3_TIPTEM },,,,) 		    // "SubLote"
TRCell():New(oSection2,"VO3_GRUITE"	,"VO3"	,RetTitle("VO3_GRUITE")	,PesqPict("VO3","VO3_GRUITE")	,TamSx3("VO3_GRUITE")[1]	,/*lPixel*/,{|| (cAliasQry)->VO3_GRUITE },,,,)  //Descri��o do Item
TRCell():New(oSection2,"VO3_CODITE"	,"VO3"	,RetTitle("VO3_CODITE")	,PesqPict("VO3","VO3_CODITE")	,TamSx3("VO3_CODITE")[1]	,/*lPixel*/,{|| (cAliasQry)->VO3_CODITE },,,,)  // "Localiza��o"
TRCell():New(oSection2,"B1_DESC"	,"SB1"	,RetTitle("B1_DESC")	,PesqPict("SB1","B1_DESC")		,20							,/*lPixel*/,{|| SB1->B1_DESC  },,,,)  //Descri��o do Item
TRCell():New(oSection2,"VO3_QTDREQ"	,"VO3"	,RetTitle("VO3_QTDREQ")	,PesqPict("VO3","VO3_QTDREQ")	,TamSx3("VO3_QTDREQ")[1]	,/*lPixel*/,{|| (cAliasQry)->VO3_QTDREQ },,,,) 		    // "SubLote"
TRCell():New(oSection2,"VO2_FUNREQ"	,"VO3"	,RetTitle("VO2_FUNREQ")	,PesqPict("VO3","VO2_FUNREQ")	,TamSx3("VO2_FUNREQ")[1]	,/*lPixel*/,{|| (cAliasQry)->VO2_FUNREQ },,,"RIGHT",) 		    // "Quantidade"
TRCell():New(oSection2,"VAI_NOMTEC"	,"VAI"	,RetTitle("VAI_NOMTEC")	,PesqPict("VAI","VAI_NOMTEC")	,20							,/*lPixel*/,{|| VAI->VAI_NOMTEC  },,,,)


Return(oReport)

/*/{Protheus.doc} OR0100025_ReportPrint
Levantamento dos dados que ir�o compor o relat�rio
@author Renato Vinicius
@since 04/10/2018
@version 1.0
@return nulo
@param oReport, objeto, Objeto TReport
@param cAliasQry, caracter, Variavel que contem a query
@type function
/*/

Static Function OR0100025_ReportPrint(oReport,cAliasQry)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)

//������������������������������������������������������������������������Ŀ
//�Filtragem do relat�rio                                                  �
//��������������������������������������������������������������������������

cMVPAR02 :=""
If !Empty(mv_par02)
	cMVPAR02 := "VO1.VO1_NUMOSV BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "' AND "
EndIf

cMVPAR01 :=""
If !Empty(mv_par01)
	cMVPAR01 := "VO3.VO3_TIPTEM = '" + mv_par01 + "' AND "
EndIf

cMVPAR06 :=""
If !Empty(mv_par06)
	cMVPAR06 := "VO3.VO3_CODITE BETWEEN '" + mv_par06 + "' AND '" + mv_par07 + "' AND "
EndIf

cMVPAR09 :=""
If !Empty(mv_par09)
	cMVPAR09 := "VO2.VO2_FUNREQ = '" + mv_par09 + "' AND "
EndIf

cMVPAR08 :=""
If mv_par08 == 2
	cMVPAR08 := "VO2.VO2_DEVOLU = '1' AND "
ElseIf mv_par08 == 3
	cMVPAR08 := "VO2.VO2_DEVOLU = '0' AND "
EndIf

cWhere := "%"+cMVPAR02+cMVPAR01+cMVPAR06+cMVPAR09+cMVPAR08+"%"

//������������������������������������������������������������������������Ŀ
//�Query do relat�rio da secao 1                                           �
//��������������������������������������������������������������������������

oSection1:BeginQuery()

BeginSql Alias cAliasQry
	SELECT VO1_NUMOSV, VO1_PROVEI, VO1_LOJPRO, VO1_CHASSI, VO2_NOSNUM, VO2_DATREQ, VO2_DEVOLU,
			VO3_GRUITE, VO3_CODITE, VO3_QTDREQ, VO2_FUNREQ, VO3_TIPTEM
	FROM %Table:VO2% VO2
		INNER JOIN
			%Table:VO1% VO1
		ON 
			VO1.VO1_FILIAL = %xfilial:VO1% AND VO2.VO2_NUMOSV = VO1.VO1_NUMOSV AND 
			VO1.%NotDel%
		INNER JOIN
			%Table:VO3% VO3
		ON 
			VO3.VO3_FILIAL = %xfilial:VO3% AND VO2.VO2_NUMOSV = VO3.VO3_NUMOSV AND 
			VO2.VO2_NOSNUM = VO3.VO3_NOSNUM AND 
			VO3.%NotDel%
	WHERE VO2_FILIAL = %xFilial:VO2% AND 
		VO2_DATREQ BETWEEN %Exp:mv_par04% AND %Exp:mv_par05% AND
		VO2.VO2_TIPREQ = 'P' AND
		%Exp:cWhere%
		VO2.%NotDel%
	ORDER BY VO1_NUMOSV,VO3_GRUITE,VO3_CODITE,VO2_NOSNUM,VO2_DATREQ
EndSql 

oSection1:EndQuery(/*Array com os parametros do tipo Range*/)

//������������������������������������������������������������������������Ŀ
//�Metodo TrPosition()                                                     �
//�                                                                        �
//�Posiciona em um registro de uma outra tabela. O posicionamento ser�     �
//�realizado antes da impressao de cada linha do relat�rio.                �
//�                                                                        �
//�                                                                        �
//�ExpO1 : Objeto Report da Secao                                          �
//�ExpC2 : Alias da Tabela                                                 �
//�ExpX3 : Ordem ou NickName de pesquisa                                   �
//�ExpX4 : String ou Bloco de c�digo para pesquisa. A string ser� macroexe-�
//�        cutada.                                                         �
//�                                                                        �
//��������������������������������������������������������������������������

TRPosition():New(oReport:Section(1),"SA1",1,{|| xFilial("SA1")+(cAliasQry)->VO1_PROVEI+(cAliasQry)->VO1_LOJPRO})
TRPosition():New(oReport:Section(1):Section(1),"VAI",1,{|| xFilial("VAI")+(cAliasQry)->VO2_FUNREQ})
TRPosition():New(oReport:Section(1):Section(1),"SB1",7,{|| xFilial("SB1")+(cAliasQry)->VO3_GRUITE+(cAliasQry)->VO3_CODITE})

oSection2:SetParentQuery() // Define que a se��o filha utiliza a query da se��o pai na impress�o da se��o.

oBreak := TRBreak():New( oSection2, {|| (cAliasQry)->VO1_NUMOSV }, STR0003 )	// Quebra por ordem de servi�o
oBreak:OnPrintTotal({|| IIf(!(cAliasQry)->(EOF()),OR0100045_ExecPosBreak(oReport,oSection1,oSection2),"")})

oSection1:Print()

Return

/*/{Protheus.doc} OR0100035_ValidPerg
Cria��o dos parametros que ir�o compor o relat�rio
@author Renato Vinicius
@since 04/10/2018
@version 1.0
@return nulo
@param cPerg, caracter, Nome do grupo de pergunta do relat�rio
@type function
/*/

Static Function OR0100035_ValidPerg(cPerg)

Local aRegs := {}

AADD(aRegs,{STR0006, STR0006, STR0006, "mv_ch1", "C", TamSx3("VOI_TIPTEM")[1]	, 0, 0, "G", '' , "mv_par01", ""		, "" , "" , "" , "" , "" 			, "" , "" , "" , "" , "" 			, "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "VOI" , "" , "" , "" , {"Informe o tipo de tempo"},{},{}}) //"Tipo Tempo"
AADD(aRegs,{STR0007, STR0007, STR0007, "mv_ch2", "C", TamSx3("VO1_NUMOSV")[1]	, 0, 0, "G", '' , "mv_par02", ""		, "" , "" , "" , "" , ""			, "" , "" , "" , "" , ""			, "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "VO1" , "" , "" , "" , {"Informe o n�mero da ordem de servi�o"},{},{}}) //"OS Inicial"
AADD(aRegs,{STR0008, STR0008, STR0008, "mv_ch3", "C", TamSx3("VO1_NUMOSV")[1]	, 0, 0, "G", '' , "mv_par03", ""		, "" , "" , "" , "" , ""			, "" , "" , "" , "" , ""			, "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "VO1" , "" , "" , "" , {"Informe o n�mero da ordem de servi�o"},{},{}}) //"OS Final"
aAdd(aRegs,{STR0009, STR0009, STR0009, "mv_ch4", "D", 8							, 0, 0, "G", '' , "mv_par04", ""		, "" , "" , "" , "" , ""			, "" , "" , "" , "" , ""			, "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""    , "" , "" , "" , {"Informe a data inicial"},{},{}}) //"Data Inicial"
aAdd(aRegs,{STR0010, STR0010, STR0010, "mv_ch5", "D", 8							, 0, 0, "G", '' , "mv_par05", ""		, "" , "" , "" , "" , ""			, "" , "" , "" , "" , ""			, "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""    , "" , "" , "" , {"Informe a data final"},{},{}}) //"Data Final"
AADD(aRegs,{STR0011, STR0011, STR0011, "mv_ch6", "C", TamSx3("B1_COD")[1]		, 0, 0, "G", '' , "mv_par06", ""		, "" , "" , "" , "" , ""			, "" , "" , "" , "" , ""			, "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SB1" , "" , "" , "" , {"Informe o c�digo do item"},{},{}}) //"Item Inicial"
AADD(aRegs,{STR0012, STR0012, STR0012, "mv_ch7", "C", TamSx3("B1_COD")[1]		, 0, 0, "G", '' , "mv_par07", ""		, "" , "" , "" , "" , ""			, "" , "" , "" , "" , ""			, "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SB1" , "" , "" , "" , {"Informe o c�digo do item"},{},{}}) //"Item Final"
aAdd(aRegs,{STR0013, STR0013, STR0013, "mv_ch8", "C", 1							, 0, 0, "C", '' , "mv_par08", "Ambos"	, "" , "" , "" , "" , "Requisi��o"	, "" , "" , "" , "" , "Devolu��o"	, "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""    , "" , "" , "" , {"Informe o tipo de solicita��o"},{},{}}) //"Tipo"
AADD(aRegs,{STR0014, STR0014, STR0014, "mv_ch9", "C", TamSx3("VO3_PROREQ")[1]	, 0, 0, "G", '' , "mv_par09", ""		, "" , "" , "" , "" , ""			, "" , "" , "" , "" , ""			, "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "VAI" , "" , "" , "" , {"Informe o c�digo do produtivo"},{""},{}}) //"Produtivo"

FMX_AJSX1(cPerg,aRegs)

Return

/*/{Protheus.doc} OR0100045_ExecPosBreak
Execu��o dos comandos ap�s quebra de se��o
@author Renato Vinicius
@since 04/10/2018
@version 1.0
@return nulo
@param cPerg, caracter, Nome do grupo de pergunta do relat�rio
@type function
/*/

Static Function OR0100045_ExecPosBreak(oReport,oSection1,oSection2)
	oReport:SkipLine()
	oSection1:PrintLine()
	oSection2:PrintHeader()
Return

/*/{Protheus.doc} OR0100055_TipoMov
Tranforma��o de conteudo VO2_DEVOLU para impress�o
@author Renato Vinicius
@since 04/10/2018
@version 1.0
@return nulo
@param cPerg, caracter, Nome do grupo de pergunta do relat�rio
@type function
/*/

Static Function OR0100055_TipoMov(cDevolu)

Local cRetorno := ""

	If cDevolu == "1"
		cRetorno := "Req"
	ElseIf cDevolu == "0"
		cRetorno := "Dev"
	EndIf

Return cRetorno