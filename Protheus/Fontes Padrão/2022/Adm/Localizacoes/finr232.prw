#INCLUDE "FINR232.CH"
#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINR232   บ Autor ณMarcelo Akama       บ Data ณ  30/09/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Programa para imprimir os cheques emitidos                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function FINR232()
Local oReport

Private cPerg := "FIN232"

If TRepInUse()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInterface de impressao                                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oReport	:= ReportDef()
	oReport:PrintDialog()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณReportDef ณ Autor ณMarcelo Akama          ณ Data ณ30/09/2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณA funcao estatica ReportDef devera ser criada para todos os ณฑฑ
ฑฑณ          ณrelatorios que poderao ser agendados pelo usuario.          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณExpO1: Objeto do relat๓rio                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณNenhum                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ReportDef()
Local oReport
Local oSection1
Local cAliasQry1	:= GetNextAlias()
Local cAliasQry2    := cAliasQry1
Local nTamForn

Pergunte( cPerg , .F. )

oReport  := TReport():New( "FINR232", STR0001, cPerg , { |oReport| ReportPrint( oReport, @cAliasQry1, @cAliasQry2 ) }, STR0002, .T.) //"Relatorio de Cheques Emitidos"##"Este programa tem como objetivo imprimir os cheques emitidos"

oSection1 := TRSection():New(oReport,STR0003,{"SEF","FRF","SX5"}) //"Cheques"

nTamForn := TamSX3("EF_FORNECE")[1] + TamSX3("EF_LOJA")[1] + 1

TRCell():New(oSection1,"EF_TALAO"	,"SEF","Chequera"		,					,TamSX3("EF_TALAO")[1]		,.F.,{|| (cAliasQry1)->EF_TALAO }) // "No. Talao"
TRCell():New(oSection1,"EF_NUM"		,"SEF",STR0005			,					,TamSX3("EF_NUM")[1]		,.F.,{|| (cAliasQry1)->EF_NUM }) // "No. Cheque"
TRCell():New(oSection1,"EF_VALOR"	,"SEF",STR0006			,"@E 99,999,999.99"	,13							,.F.,{|| (cAliasQry1)->EF_VALOR }) // "Valor"
TRCell():New(oSection1,"EF_DATA"	,"SEF",STR0007			,					,18							,.F.,{|| (cAliasQry1)->EF_DATA }) // "Data Emissao"
TRCell():New(oSection1,"EF_VENCTO"	,"SEF",STR0008 			,					,18							,.F.,{|| (cAliasQry1)->EF_VENCTO }) // "Vencimento"
TRCell():New(oSection1,"EF_FORNECE"	,"SEF",STR0009			,					,25      					,.F.,{|| (cAliasQry1)->EF_FORNECE + " " + (cAliasQry1)->EF_LOJA }) // "Fornecedor"
TRCell():New(oSection1,"EF_BENEF"	,"SEF",STR0010			,					,TamSX3("EF_BENEF")[1]		,.F.,{|| (cAliasQry1)->EF_BENEF }) // "Beneficiario"
TRCell():New(oSection1,"EF_STATUS"	,"SEF",STR0011			,					,TamSX3("EF_STATUS")[1]		,.F.,{|| (cAliasQry1)->EF_STATUS }) // "Status"
TRCell():New(oSection1,"FRF_MOTIVO"	,"FRF",STR0012			,					,TamSX3("FRF_MOTIVO")[1]	,.F.,{|| (cAliasQry2)->FRF_MOTIVO }) // "Motivo"
TRCell():New(oSection1,"X5_DESCRI"	,"SX5",STR0016   		,					,TamSX3("X5_DESCRI")[1]		,.F.,{|| POSICIONE("SX5",1,XFILIAL("SX5")+ 'G0' + (cAliasQry2)->FRF_MOTIVO,"X5DESCRI()") }) //"Descripcion"
TRCell():New(oSection1,"EF_SUBSCHE"	,"SEF",STR0015			,					,TamSX3("EF_SUBSCHE")[1]		,.F.,{|| (cAliasQry1)->EF_SUBSCHE }) // "Substituido por"
TRCell():New(oSection1,"FRF_DATDEV"	,"FRF",STR0013			,					,							,.F.,{|| (cAliasQry2)->FRF_DATDEV }) // "Data Devolucao"
TRCell():New(oSection1,"FRF_DATPAG"	,"FRF",STR0014			,					,							,.F.,{|| (cAliasQry2)->FRF_DATPAG }) // "Data Pagamento"

#IFNDEF TOP
	TRPosition():New ( oSection1, "FRF" , 1 ,{|| xFilial("FRF")+SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_PREFIXO+EF_NUM) } , .T. )
	TRPosition():New ( oSection1, "SX5" , 1 ,{|| xFilial("SX5")+"G0"+FRF->FRF_MOTIVO } , .T. )
#ENDIF

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportPrintบAutor  ณMarcelo Akama       บ Data ณ  30/09/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณQuery de impressao do relatorio                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ReportPrint( oReport, cAliasQry1, cAliasQry2 )
Local oSection1 := oReport:Section(1)
#IFDEF TOP
Local cQuery	:= ""
Local cTrim		:= IIf( Alltrim(Upper(TcGetDB()))=='INFORMIX', 'TRIM', 'LTRIM' )
#ELSE
Local cFiltro	:= ""
#ENDIF

dbSelectArea("SEF")
dbSetorder(1)

#IFDEF TOP

	cAliasQry2 := cAliasQry1
	
	oSection1:BeginQuery()

	If !Empty(mv_par01)
		cQuery += " AND EF_BANCO = '" + mv_par01 + "' "
	EndIf
	If !Empty(mv_par02)
		cQuery += " AND EF_AGENCIA = '" + mv_par02 + "' "
	EndIf
	If !Empty(mv_par03)
		cQuery += " AND EF_CONTA = '" + mv_par03 + "' "
	EndIf
	cQuery += " AND ( EF_DATA BETWEEN '" + DTOS(mv_par04) + "' AND '" + DTOS(mv_par05) + "' OR " + cTrim + "(EF_DATA) = '' )"
	cQuery += " AND ( EF_VENCTO BETWEEN '" + DTOS(mv_par06) + "' AND '" + DTOS(mv_par07) + "' OR " + cTrim + "(EF_VENCTO) = '' )"
	If mv_par08=2
		cQuery += " AND " + cTrim + "(EF_DATA) <> ''"
	EndIf
	cQuery += " ORDER BY " + SqlOrder(IndexKey())
	cQuery := "%" + cQuery + "%"
	If TcGetDb() $ "ORACLE"
		cQuery:=StrTran(cQuery,"= ''","is null")
		cQuery:=StrTran(cQuery,"<> ''","is not null")
	Endif
	BeginSql Alias cAliasQry1

		SELECT EF_CART, SEF.EF_TALAO, SEF.EF_NUM, SEF.EF_VALOR, SEF.EF_DATA, SEF.EF_VENCTO,
			SEF.EF_FORNECE, SEF.EF_LOJA, SEF.EF_BENEF, SEF.EF_STATUS,SEF.EF_SUBSCHE, FRF.FRF_MOTIVO,
			FRF.FRF_DATDEV, FRF.FRF_DATPAG
		FROM %table:SEF% SEF
		LEFT OUTER JOIN %table:FRF% FRF
			ON	(	FRF_FILIAL = %xFilial:FRF% AND
					EF_BANCO   = FRF.FRF_BANCO AND
					EF_AGENCIA = FRF_AGENCI AND
					EF_CONTA   = FRF_CONTA AND
					EF_PREFIXO = FRF_PREFIX AND
					EF_NUM     = FRF_NUM AND
					EF_CART    = FRF_CART AND
					FRF.%NotDel% )
		LEFT OUTER JOIN %table:SX5% SX5
			ON	(	X5_FILIAL  = %xFilial:SX5% AND
					X5_TABELA  = 'G0' AND
					X5_CHAVE   = FRF_MOTIVO AND
					SX5.%NotDel% )
		WHERE EF_FILIAL = %xFilial:SEF% AND
				EF_CART = 'P' AND
				SEF.%NotDel%
				%Exp:cQuery%

	EndSql

	oSection1:EndQuery()

#ELSE

	cAliasQry1 := "SEF"
	cAliasQry2 := "FRF"
	
	cFiltro := '!Eof() .And. SEF->EF_FILIAL == "'+ xFilial("SEF")+'" EF_CART = "P"'
	If !Empty(mv_par01)
		cFiltro += ' .And. SEF->EF_BANCO = "' + mv_par01 + '"'
	EndIf
	If !Empty(mv_par02)
		cFiltro += ' .And. SEF->EF_AGENCIA = "' + mv_par02 + '"'
	EndIf
	If !Empty(mv_par03)
		cFiltro += ' .And. SEF->EF_CONTA = "' + mv_par03 + '"'
	EndIf
	cFiltro += ' .And. DTOS(SEF->EF_DATA) >= "' + DTOS(mv_par04) + '"'
	cFiltro += ' .And. DTOS(SEF->EF_DATA) <= "' + DTOS(mv_par05) + '"'
	cFiltro += ' .And. DTOS(SEF->EF_VENCTO) >= "' + DTOS(mv_par06) + '"'
	cFiltro += ' .And. DTOS(SEF->EF_VENCTO) <= "' + DTOS(mv_par07) + '"'
	If mv_par08=2
		cQuery += ' .And. !Empty(SEF->EF_DATA)'
	EndIf

	oSection1:SetFilter(cFiltro,(cAliasQry1)->(IndexKey()))

#ENDIF

oSection1:Print()

Return Nil
