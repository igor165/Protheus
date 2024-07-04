#include 'totvs.ch'
#include 'FINR242.ch'

// #########################################################################################
// Projeto: 11.7
// Modulo : Financeiro
// Fonte  : FINR242.prw
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 03/09/12 | Marcos Berto	    | Impressão de Lotes Financeiros
// ---------+-------------------+-----------------------------------------------------------

Function FINR242()

Local oReport

If TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

Definição do relatório

@author    Marcos Berto
@version   11.7
@since     13/09/2012
/*/
//------------------------------------------------------------------------------------------
Static Function ReportDef()

Local oReport
Local oSecCab
Local oSecTit
Local oSecPag

oReport := TReport():New("FINR242",STR0001,"FIN242R",{|oReport| ReportPrint(oReport)},STR0001)//"Impressão de Lotes Financeiros"
oReport:SetLandscape(.T.)

//Sessão do cabeçalho
oSecCab := TRSection():New(oReport,STR0002,{"FJB"}) //Cab. de Lote

dbSelectArea("FJB")
TRCell():New(oSecCab,"BANCO"	,,RetTitle("FJB_BANCO")	,PesqPict("FJB","FJB_BANCO")	,TamSX3("FJB_BANCO")[1],.F.,,,,,,,.F.)
TRCell():New(oSecCab,"AGENCIA"	,,RetTitle("FJB_AGENCI")	,PesqPict("FJB","FJB_AGENCI")	,TamSX3("FJB_AGENCI")[1],.F.,,,,,,,.F.)
TRCell():New(oSecCab,"CONTA"	,,RetTitle("FJB_CONTA")	,PesqPict("FJB","FJB_CONTA")	,TamSX3("FJB_CONTA")[1],.F.,,,,,,,.F.)
TRCell():New(oSecCab,"LOTE"		,,RetTitle("FJB_NUMLOT")	,PesqPict("FJB","FJB_NUMLOT")	,TamSX3("FJB_NUMLOT")[1],.F.,,,,,,,.F.)
TRCell():New(oSecCab,"BCORET"	,,RetTitle("FJB_BCORET")	,									,10,.F.,,,,,,,.F.)
TRCell():New(oSecCab,"DATLOT"	,,RetTitle("FJB_DATLOT")	,									,TamSX3("FJB_DATLOT")[1]+2,.F.,,,,,,,.F.)
TRCell():New(oSecCab,"STATUS"	,,RetTitle("FJB_STATUS")	,									,20,.F.,,,,,,,.F.)
TRCell():New(oSecCab,"VALLOT"	,,STR0003 /*Valor Lote*/	,PesqPict("SEK","EK_VALOR")		,TamSX3("EK_VALOR")[1],.F.,,,,,,,.F.)

oSecPag := TRSection():New(oReport,STR0004 /*Pgtos. Lote*/,{"SEK"})

dbSelectArea("SEK")
TRCell():New(oSecPag,"ORDPAGO"	,,RetTitle("EK_ORDPAGO")	,PesqPict("SEK","EK_ORDPAGO")	,TamSX3("EK_ORDPAGO")[1],.F.,,,,,,,.F.)
TRCell():New(oSecPag,"TIPO"		,,RetTitle("EK_TIPO")	,PesqPict("SEK","EK_TIPO")		,TamSX3("EK_TIPO")[1],.F.,,,,,,,.F.)
TRCell():New(oSecPag,"NUMERO"	,,RetTitle("EK_NUM")		,PesqPict("SEK","EK_NUM")		,TamSX3("EK_NUM")[1],.F.,,,,,,,.F.)
TRCell():New(oSecPag,"FORNECE"	,,RetTitle("EK_FORNECE")	,PesqPict("SEK","EK_FORNECE")	,TamSX3("EK_FORNECE")[1],.F.,,,,,,,.F.)
TRCell():New(oSecPag,"LOJA"		,,RetTitle("EK_LOJA")	,PesqPict("SEK","EK_LOJA")		,TamSX3("EK_LOJA")[1],.F.,,,,,,,.F.)
TRCell():New(oSecPag,"VALOR"	,,RetTitle("EK_VALOR")	,PesqPict("SEK","EK_VALOR")		,TamSX3("EK_VALOR")[1],.F.,,,,,,,.F.)
TRCell():New(oSecPag,"MOEDA"	,,RetTitle("EK_MOEDA")	,PesqPict("SEK","EK_MOEDA")		,TamSX3("EK_MOEDA")[1],.F.,,,,,,,.F.)
TRCell():New(oSecPag,"EMISSAO"	,,RetTitle("EK_EMISSAO")	,									,TamSX3("EK_EMISSAO")[1]+2,.F.,,,,,,,.F.)
TRCell():New(oSecPag,"VENCTO"	,,RetTitle("EK_VENCTO")	,									,TamSX3("EK_VENCTO")[1]+2,.F.,,,,,,,.F.)
TRCell():New(oSecPag,"STATUS"	,,RetTitle("FJC_STATUS")	,,20,.F.,,,,,,,.F.)

oSecTit := TRSection():New(oReport,STR0005 /*Títulos do Lote*/,{"SEK"})

TRCell():New(oSecTit,"PREFIXO"	,,RetTitle("EK_PREFIXO")	,PesqPict("SEK","EK_PREFIXO")	,TamSX3("EK_PREFIXO")[1],.F.,,,,,,,.F.)
TRCell():New(oSecTit,"NUMERO"	,,RetTitle("EK_NUM")		,PesqPict("SEK","EK_NUM")		,TamSX3("EK_NUM")[1],.F.,,,,,,,.F.)
TRCell():New(oSecTit,"PARCELA"	,,RetTitle("EK_PARCELA")	,PesqPict("SEK","EK_PARCELA")	,TamSX3("EK_PARCELA")[1],.F.,,,,,,,.F.)
TRCell():New(oSecTit,"TIPO"		,,RetTitle("EK_TIPO")	,PesqPict("SEK","EK_TIPO")		,TamSX3("EK_TIPO")[1],.F.,,,,,,,.F.)
TRCell():New(oSecTit,"FORNECE"	,,RetTitle("EK_FORNECE")	,PesqPict("SEK","EK_FORNECE")	,TamSX3("EK_FORNECE")[1],.F.,,,,,,,.F.)
TRCell():New(oSecTit,"LOJA"		,,RetTitle("EK_LOJA")	,PesqPict("SEK","EK_LOJA")		,TamSX3("EK_LOJA")[1],.F.,,,,,,,.F.)
TRCell():New(oSecTit,"VALOR"	,,RetTitle("EK_VALOR")	,PesqPict("SEK","EK_VALOR")		,TamSX3("EK_VALOR")[1],.F.,,,,,,,.F.)
TRCell():New(oSecTit,"MOEDA"	,,RetTitle("EK_MOEDA")	,PesqPict("SEK","EK_MOEDA")		,TamSX3("EK_MOEDA")[1],.F.,,,,,,,.F.)
TRCell():New(oSecTit,"EMISSAO"	,,RetTitle("EK_EMISSAO")	,									,TamSX3("EK_EMISSAO")[1]+2,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"VENCTO"	,,RetTitle("EK_VENCTO")	,									,TamSX3("EK_VENCTO")[1]+2,.F.,,,,,,,.F.)

Return oReport

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Definição do relatório

@author    Marcos Berto
@version   11.7
@since     13/09/2012

@param oReport	Objeto do Relatório

/*/
//------------------------------------------------------------------------------------------
Static Function ReportPrint(oReport)

Local aDados 		:= {}

Local nImpress	:= 1

Local nLinha 		:= 0
Local nPgto		:= 0
Local nTit			:= 0

Local oSecCab 	:= oReport:Section(1)
Local oSecPag 	:= oReport:Section(2)
Local oSecTit 	:= oReport:Section(3)

Pergunte("FIN242R",.F.)

nImpress := MV_PAR05 //1- Sintético/ 2- Analítico

oSecCab:Cell("BANCO"):SetBlock({|| aDados[nLinha][1]})
oSecCab:Cell("AGENCIA"):SetBlock({|| aDados[nLinha][2]})
oSecCab:Cell("CONTA"):SetBlock({|| aDados[nLinha][3]})
oSecCab:Cell("LOTE"):SetBlock({|| aDados[nLinha][4]})
oSecCab:Cell("BCORET"):SetBlock({|| aDados[nLinha][5]})
oSecCab:Cell("STATUS"):SetBlock({|| aDados[nLinha][6]})
oSecCab:Cell("DATLOT"):SetBlock({|| aDados[nLinha][7]})
oSecCab:Cell("VALLOT"):SetBlock({|| aDados[nLinha][8]})

If nImpress = 2 //Analítico
	oSecPag:Cell("ORDPAGO"):SetBlock({|| aDados[nLinha][9][nPgto][1]})
	oSecPag:Cell("TIPO"):SetBlock({|| aDados[nLinha][9][nPgto][2]})
	oSecPag:Cell("NUMERO"):SetBlock({|| aDados[nLinha][9][nPgto][3]})
	oSecPag:Cell("FORNECE"):SetBlock({|| aDados[nLinha][9][nPgto][4]})
	oSecPag:Cell("LOJA"):SetBlock({|| aDados[nLinha][9][nPgto][5]})
	oSecPag:Cell("VALOR"):SetBlock({|| aDados[nLinha][9][nPgto][6]})
	oSecPag:Cell("MOEDA"):SetBlock({|| aDados[nLinha][9][nPgto][7]})
	oSecPag:Cell("EMISSAO"):SetBlock({|| aDados[nLinha][9][nPgto][8]})
	oSecPag:Cell("VENCTO"):SetBlock({|| aDados[nLinha][9][nPgto][9]})
	oSecPag:Cell("STATUS"):SetBlock({|| aDados[nLinha][9][nPgto][10]})

	oSecTit:Cell("PREFIXO"):SetBlock({|| aDados[nLinha][10][nTit][1]})
	oSecTit:Cell("NUMERO"):SetBlock({|| aDados[nLinha][10][nTit][2]})
	oSecTit:Cell("PARCELA"):SetBlock({|| aDados[nLinha][10][nTit][3]})
	oSecTit:Cell("TIPO"):SetBlock({|| aDados[nLinha][10][nTit][4]})
	oSecTit:Cell("FORNECE"):SetBlock({|| aDados[nLinha][10][nTit][5]})
	oSecTit:Cell("LOJA"):SetBlock({|| aDados[nLinha][10][nTit][6]})
	oSecTit:Cell("VALOR"):SetBlock({|| aDados[nLinha][10][nTit][7]})
	oSecTit:Cell("MOEDA"):SetBlock({|| aDados[nLinha][10][nTit][8]})
	oSecTit:Cell("EMISSAO"):SetBlock({|| aDados[nLinha][10][nTit][9]})
	oSecTit:Cell("VENCTO"):SetBlock({|| aDados[nLinha][10][nTit][10]})
EndIf

aDados := F242LotBco()

If nImpress = 1

	oSecCab:Init()
	For nLinha := 1 to Len(aDados)
		oSecCab:PrintLine()
	Next nX
	oSecCab:Finish()

Else
	For nLinha := 1 to Len(aDados)

		oSecCab:Init()
		oSecCab:PrintLine()

		oSecPag:Init()
		For nPgto := 1 to Len(aDados[nLinha][9])
				oSecPag:PrintLine()
		Next nPgto
		oSecPag:Finish()

		oSecTit:Init()
		For nTit := 1 to Len(aDados[nLinha][10])
			oSecTit:PrintLine()
		Next nTit
		oSecTit:Finish()

		oSecCab:Finish()
		oReport:IncMeter()
		oReport:SkipLine(2)

	Next nLinha
EndIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242LotBco

Processa os dados de um Lote para impressao

@author    Marcos Berto
@version   11.7
@since     13/09/2012

@return aDados	Dados do lote

/*/
//------------------------------------------------------------------------------------------
Function F242LotBco()

Local aAux
Local aDados 		:= {}
Local aTitulos	:= {}
Local aPgtos		:= {}

Local cNumLotAnt	:= ""
Local cTipo		:= ""

Local cQuery 		:= ""
Local cAliasLot 	:= GetNextAlias()

Local cStatus
Local cDataIni	:= MV_PAR01
Local cDataFim	:= MV_PAR02

Local nImpress	:= MV_PAR05 //1- Sintético/ 2- Analítico

If nImpress = 1
	cTipo := "CP"
Else
	cTipo := "CP|TB"
EndIf

If MV_PAR03 = 1 //Considera Status
	Do Case
		Case MV_PAR04 = 1
			cStatus := "1" //Ativo
		Case MV_PAR04 = 2
			cStatus := "2|5" //Inativo
		Case MV_PAR04 = 3
			cStatus := "3" //Arquivo Gerado
		Case MV_PAR04 = 4
			cStatus := "4" //Retorno do Banco
		Case MV_PAR04 = 5
			cStatus := "6" //Baixado
	EndCase
Else
	cStatus := "1|2|3|4|5|6"
EndIf

cQuery := "SELECT "

cQuery += 	"	FJB_BANCO,"
cQuery +=	"	FJB_AGENCI,"
cQuery +=	"	FJB_CONTA,"
cQuery +=	"	FJB_CONTA,"
cQuery +=	"	FJB_NUMLOT,"
cQuery +=	"	FJB_BCORET,"
cQuery +=	"	FJB_DATLOT,"
cQuery +=	"	FJB_STATUS,"
cQuery +=	"	FJC_NUMFIN,"
cQuery +=	"	FJC_STATUS,"
cQuery +=	"	EK_ORDPAGO,"
cQuery +=	"	EK_TIPODOC,"
cQuery +=	"	EK_PREFIXO,"
cQuery +=	"	EK_NUM,"
cQuery +=	"	EK_PARCELA,"
cQuery +=	"	EK_TIPO,"
cQuery +=	"	EK_FORNECE,"
cQuery +=	"	EK_LOJA,"
cQuery +=	"	EK_VALOR,"
cQuery +=	"	EK_MOEDA,"
cQuery +=	"	EK_EMISSAO,"
cQuery +=	"	EK_DTDIGIT,"
cQuery +=	"	EK_VENCTO"

cQuery += "	FROM "+RetSqlName("FJB")+" FJB, "
cQuery += 				RetSqlName("FJC")+" FJC, "
cQuery += 				RetSqlName("SEK")+" SEK, "
cQuery += "	WHERE "
cQuery += "		FJB_FILIAL = '"+xFilial("FJB")+"' AND "
cQuery += "		FJC_FILIAL = '"+xFilial("FJC")+"' AND "
cQuery += "		EK_FILIAL = '"+xFilial("SEK")+"' AND "

cQuery += "		FJB_BANCO = FJC_BANCO AND "
cQuery += "		FJB_AGENCI = FJC_AGENCI AND "
cQuery += "		FJB_CONTA = FJC_CONTA AND "
cQuery += "		FJB_NUMLOT = FJC_NUMLOT AND "
cQuery += "		FJC_NUMFIN = EK_ORDPAGO AND "

cQuery += "		FJB_STATUS IN "+FormatIn(cStatus,"|")+" AND "
cQuery += "		FJB_DATLOT BETWEEN '"+Dtos(cDataIni)+"' AND '"+Dtos(cDataFim)+"' AND "

cQuery += "		EK_TIPODOC IN "+FormatIn(cTipo,"|")+" AND "

cQuery += "		FJB.D_E_L_E_T_ = '' AND "
cQuery += "		FJC.D_E_L_E_T_ = '' AND "
cQuery += "		SEK.D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasLot,.F.,.T.)

dbSelectArea(cAliasLot)
(cAliasLot)->(dbGoTop())

While !(cAliasLot)->(Eof())

	//Inicia um novo lote
	If 	(cAliasLot)->FJB_NUMLOT <> cNumLotAnt
		aAux := Array(10)

		aAux[1] := (cAliasLot)->FJB_BANCO
		aAux[2] := (cAliasLot)->FJB_AGENCI
		aAux[3] := (cAliasLot)->FJB_CONTA
		aAux[4] := (cAliasLot)->FJB_NUMLOT
		If (cAliasLot)->FJB_BCORET == "1"
			aAux[5] := STR0012 //"Sim"
		Else
			aAux[5] :=	 STR0013 //"Não"
		EndIf

		Do Case
			Case (cAliasLot)->FJB_STATUS == "1"
				aAux[6] := STR0006 //"ATIVO"
			Case (cAliasLot)->FJB_STATUS == "2"
				aAux[6] := STR0007 //"INATIVO"
			Case (cAliasLot)->FJB_STATUS == "3"
				aAux[6] := STR0009 //"ARQUIVO GERADO"
			Case (cAliasLot)->FJB_STATUS == "4"
				aAux[6] := STR0008 //"RETORNO DO BANCO"
			Case (cAliasLot)->FJB_STATUS == "5"
				aAux[6] := STR0010 //"INATIVO POR ERRO"
			Case (cAliasLot)->FJB_STATUS == "6"
				aAux[6] := STR0011 //"BAIXADO"
		EndCase
		aAux[7] := Stod((cAliasLot)->FJB_DATLOT)
		aAux[8] := 0
		aAux[9] := {}
		aAux[10]:= {}
	EndIf

	//Pagamento da OP
	If (cAliasLot)->EK_TIPODOC == "CP"

		aAux[8] += (cAliasLot)->EK_VALOR

		If nImpress = 2
			aPgtos := Array(10)

			aPgtos[1] :=  (cAliasLot)->EK_ORDPAGO
			aPgtos[2] :=	(cAliasLot)->EK_TIPO
			aPgtos[3] :=	(cAliasLot)->EK_NUM
			aPgtos[4] :=	(cAliasLot)->EK_FORNECE
			aPgtos[5] :=	(cAliasLot)->EK_LOJA
			aPgtos[6] :=	(cAliasLot)->EK_VALOR
			aPgtos[7] :=	(cAliasLot)->EK_MOEDA
			aPgtos[8] :=	Stod((cAliasLot)->EK_EMISSAO)
			aPgtos[9] :=	Stod((cAliasLot)->EK_VENCTO)
			Do Case
				Case (cAliasLot)->FJC_STATUS == "1"
					aPgtos[10] := STR0006 //"ATIVO"
				Case (cAliasLot)->FJC_STATUS == "2"
					aPgtos[10] :=	STR0007 //"INATIVO"
			EndCase

			aAdd(aAux[9],aPgtos)

		EndIf

	//Títulos pagos na OP
	ElseIf (cAliasLot)->EK_TIPODOC == "TB" .And. nImpress = 2

		aTitulos 	:= Array(10)

		aTitulos[1] :=  (cAliasLot)->EK_PREFIXO
		aTitulos[2] :=  (cAliasLot)->EK_NUM
		aTitulos[3] :=  (cAliasLot)->EK_PARCELA
		aTitulos[4] :=  (cAliasLot)->EK_TIPO
		aTitulos[5] :=  (cAliasLot)->EK_FORNECE
		aTitulos[6] :=  (cAliasLot)->EK_LOJA
		aTitulos[7] :=  (cAliasLot)->EK_VALOR
		aTitulos[8] :=  (cAliasLot)->EK_MOEDA
		aTitulos[9] :=  Stod((cAliasLot)->EK_EMISSAO)
		aTitulos[10] :=  Stod((cAliasLot)->EK_VENCTO)

		aAdd(aAux[10],aTitulos)

	EndIf

	cNumLotAnt := (cAliasLot)->FJB_NUMLOT
	(cAliasLot)->(dbSkip())

	//Efetiva gravação dos dados no array que contem a estrutura do relatório
	If (cAliasLot)->FJB_NUMLOT <> cNumLotAnt
		aAdd(aDados,aAux)
	EndIf

EndDo

(cAliasLot)->(dbCloseArea())

Return aDados
