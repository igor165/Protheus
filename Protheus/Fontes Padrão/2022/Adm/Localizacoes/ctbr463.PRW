#Include "PROTHEUS.Ch"
#Include "CTBR463.Ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBR463  ³ Autor ³Roberto Rogério Mezzalira ³ Data ³ 24.12.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 1- "PROVEEDORES (CUENTA 42)"                                  ³±±
±±³          ³ 2- "CUENTAS POR PAGAR DIVERSAS (CUENTA 46)"                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBR463(nOpca)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Generico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpca 4- Demonstrativo - Contas de Proveedores (CUENTA 42)    ³±±
±±³          ³ nOpca 5- Demonstrativo - Contas diversas por pagar (CUENTA 46)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctbr463(nOpca,cCta)
Local CREPORT		:= ""
Local CTITULO		:= ""
Local CDESC			:= ""
Local cPerg			:= "CTR461"
Local cPicture		:= ""
Local nDecimais		:= 2
Local aCtbMoeda		:= {}
Local lRet			:= .T.

Private cDescMoeda	:= ""
Private nOpca1		:= nOpca
Private aSelFil		:= {}
Private oReport
Private cConta1		:= ""
Private cConta2		:= ""

cCONTA1 := cCta
cCONTA2 := cCONTA1 + "zzz"

If CT1->(DbSeek(xFilial("CT1") + cConta1))
	CTITULO := STR0001		//livro de inventario e balancos
	CDESC := STR0002 + " " + cConta1 + " " + Lower(Alltrim(CT1->CT1_DESC01))		//detalhe do saldo da conta
	CREPORT := STR0001
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01  	      	   Data Inicial                          ³
//³ mv_par02               Data Final                            ³
//³ mv_par03               Moeda?                                ³
//| mv_par04               Seleciona Filiais?					 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !Pergunte( cperg , .T. )
	lRet := .F.
EndIf

IF lRet
 	// seta a moeda
 	aCtbMoeda	:= CtbMoeda(mv_par03)
 	If Empty(aCtbMoeda[1])
 		Help(" ",1,"NOMOEDA")
 		lRet := .F.
 	EndIf
Endif

If lRet .And. mv_par04 == 1 .And. Len( aSelFil ) <= 0 //SELECIONA FILIAIS
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		lRet := .F.
	EndIf
Else
	aSelFil := {cFilAnt}
EndIf

If !lRet
	Set Filter To
	Return
EndIf

cMoeda		:= mv_par03
cDescMoeda	:= aCtbMoeda[2]
nDecimais	:= aCtbMoeda[5] // DecimalCTB(",cMoeda)
cMascara	:= GetMv("MV_MASCARA")
cPicture	:= Ctb461Pic(nDecimais)

If cConta1 == "42"  // "DE LA CUENTA 42 - PROVEEDORES"
	aRelatorio := {{.06,.15,.44,.20,.15},{},{},{},{},{},{}}	//tamanho das celulas,detalhe,total,cabec1,cabec2
	//detalhe
	Aadd(aRelatorio[2],Nil)
	Aadd(aRelatorio[2],{"CTIPO",,"CENTER",,"14"})
	Aadd(aRelatorio[2],{"CNUMERO",,"CENTER",,"14"})
	Aadd(aRelatorio[2],{"CNOME",,"LEFT",,"14"})
	Aadd(aRelatorio[2],{"NVALOR",cPicture,"RIGHT",,"14"})
	Aadd(aRelatorio[2],{"DTPGTO",,"CENTER",,"134"})
	//total
	Aadd(aRelatorio[3],Nil)
	Aadd(aRelatorio[3],{"TOTFIL1",,"CENTER",,""})
	Aadd(aRelatorio[3],{"TOTFIL2",,"CENTER",,""})
	Aadd(aRelatorio[3],{"TOTFIL3",,"RIGHT",{|| STR0004},""})						//"saldo total"
	Aadd(aRelatorio[3],{"TOTVAL",cPicture,"RIGHT",,"14"})
	Aadd(aRelatorio[3],{"TOTFIL4",,"CENTER",,"1"})
	//Cabecalho 1
	Aadd(aRelatorio[4],Nil)
	Aadd(aRelatorio[4],{"CABFIL1",,"CENTER",,"124"})
 	Aadd(aRelatorio[4],{"CABFIL2",,"CENTER",,"24"})
 	Aadd(aRelatorio[4],{"CABTER",,"LEFT",{|| STR0003},"24"})						//"Informação do fornecedor"
	Aadd(aRelatorio[4],{"CABVAL",,"CENTER",{|| STR0010},"12"})						//"Total da conta"
	Aadd(aRelatorio[4],{"CABDAT",,"CENTER",{|| STR0009},"123"})					//"Data de Emissao do "
	/* Cabecalho 2 */
	Aadd(aRelatorio[5],Nil)
	Aadd(aRelatorio[5],{"CABTIPO",,"RIGHT",{|| ""},"14"})						//"Doc. de Identidade"
	Aadd(aRelatorio[5],{"CABNUM",,"LEFT",{|| STR0012},"4"})
	Aadd(aRelatorio[5],{"CABNOM",,"CENTER",{|| Alltrim(STR0019) + ", " + AllTrim(STR0013) + ","},"1"})	//"Apelidos e "Nomes"
	Aadd(aRelatorio[5],{"CABVAL",,"CENTER",{|| ""},"1"})
	Aadd(aRelatorio[5],{"CABDAT",,"CENTER",{|| ""},"13"})
	/* Cabecalho 3 */
	Aadd(aRelatorio[6],Nil)
	Aadd(aRelatorio[6],{"CABTIPO",,"CENTER",{|| STR0005},"14"})					//"Tipo"
	Aadd(aRelatorio[6],{"CABNUM",,"CENTER",{|| STR0006},"14"})						//"Número"
	Aadd(aRelatorio[6],{"CABNOM",,"CENTER",{|| AllTrim(STR0014) + ", " + STR0007},"14"})			//"Denominação", "razão social"
	Aadd(aRelatorio[6],{"CABVAL",,"CENTER",{|| STR0015},"14"})						//"a pagar"
	Aadd(aRelatorio[6],{"CABDAT",,"CENTER",{|| STR0016},"134"})					//"comprovante de pagto"
	/*conta+descricao*/
	Aadd(aRelatorio[7],Nil)
	Aadd(aRelatorio[7],{"CONTA","@X","LEFT",{|| ""},""})

ElseIf cConta1 $ "46|47"
	aRelatorio := {{.06,.12,.26,.22,.14,.20},{},{},{},{},{},{}}	//tamanho das celulas,detalhe,total,cabec1,cabec2
	/* Linha de detalhe */
	Aadd(aRelatorio[2],Nil)
	Aadd(aRelatorio[2],{"CTIPO",,"CENTER",,"14"})
	Aadd(aRelatorio[2],{"CNUMERO",,"CENTER",,"14"})
	Aadd(aRelatorio[2],{"CNOME",,"LEFT",,"14"})
	Aadd(aRelatorio[2],{"CDOCUM",,"LEFT",,"14"})
	Aadd(aRelatorio[2],{"DTPGTO",,"CENTER",,"14"})
	Aadd(aRelatorio[2],{"NVALOR",cPicture,"RIGHT",,"134"})
	/* Linha de total */
	Aadd(aRelatorio[3],Nil)
	Aadd(aRelatorio[3],{"TOTFIL1",,"CENTER",,""})
	Aadd(aRelatorio[3],{"TOTFIL2",,"CENTER",,""})
	Aadd(aRelatorio[3],{"TOTFIL3",,"CENTER",,""})
	Aadd(aRelatorio[3],{"TOTFIL4",,"RIGHT",{|| ""},""})
	Aadd(aRelatorio[3],{"TOTFIL5",,"RIGHT",{|| STR0004},""})				//"Saldo total"
	Aadd(aRelatorio[3],{"TOTVAL",cPicture,"RIGHT",,"134"})
	/* Linha de cabecalho 1 */
	Aadd(aRelatorio[4],Nil)
	Aadd(aRelatorio[4],{"CABFIL1",,"CENTER",,"124"})
	Aadd(aRelatorio[4],{"CABFIL2",,"CENTER",,"24"})
	Aadd(aRelatorio[4],{"CABTER",,"LEFT",{|| STR0017},"24"})				//"Informação sobre terceiros"
	Aadd(aRelatorio[4],{"CABDOC",,"RIGHT",{|| ""},"12"})
	Aadd(aRelatorio[4],{"CABDAT",,"CENTER",{|| STR0009},"12"})					//"Data de emissão"
	Aadd(aRelatorio[4],{"CABVAL",,"CENTER",{|| ""},"123"})
	/* Cabecalho 2 */
	Aadd(aRelatorio[5],Nil)
	Aadd(aRelatorio[5],{"CABTIPO",,"RIGHT",{|| ""},"14"})				//"Documento de Identidade"
	Aadd(aRelatorio[5],{"CABNUM",,"LEFT",{|| STR0012},"4"})
	Aadd(aRelatorio[5],{"CABNOM",,"CENTER",{|| AllTrim(STR0019) + ", " + AllTrim(STR0013) + ","},"1"})	//"Apelidos e "Nomes"
	Aadd(aRelatorio[5],{"CABDOC",,"CENTER",{|| ""},"1"})
	Aadd(aRelatorio[5],{"CABDAT",,"CENTER",{|| STR0016},"1"})					//"comprovante"
	Aadd(aRelatorio[5],{"CABVAL",,"CENTER",{|| STR0018},"13"})					//"valor"
	/* Linha de cabecalho 3 */
	Aadd(aRelatorio[6],Nil)
	Aadd(aRelatorio[6],{"CABTIPO",,"CENTER",{|| STR0005},"1"})						//"Tipo"
	Aadd(aRelatorio[6],{"CABNUM",,"CENTER",{|| STR0006},"1"})						//"Número"
	Aadd(aRelatorio[6],{"CABNOM",,"CENTER",{|| AllTrim(STR0014) + ", " + STR0007},"1"})				//"Denominação ou ""razão social"
	Aadd(aRelatorio[6],{"CABDOC",,"CENTER",{|| STR0008},"1"})						//"Descrição da obrigação"
	Aadd(aRelatorio[6],{"CABDAT",,"CENTER",{|| STR0020},"1"})  						//	"o Fecha de inicio"
	Aadd(aRelatorio[6],{"CABVAL",,"CENTER",{|| STR0011},"13"})						//"pendente de pagamento"
	/* Linha de cabecalho 4 */
	Aadd(aRelatorio[7],Nil)
	Aadd(aRelatorio[7],{"CABFIL1",,"CENTER",,"14"})
	Aadd(aRelatorio[7],{"CABFIL2",,"CENTER",,"14"})
	Aadd(aRelatorio[7],{"CABTER",,"CENTER",{||},"14"})
	Aadd(aRelatorio[7],{"CABDOC",,"LEFT",{|| ""},"14"})
	Aadd(aRelatorio[7],{"CABDAT",,"CENTER",{|| STR0021},"14"})  //	"de la Operacion"
	Aadd(aRelatorio[7],{"CABVAL",,"LEFT",,"134"})

EndIf

oReport := CTB461Def(CREPORT,CTITULO,CPERG,CDESC)
oReport:SetAction({|oReport| ReportPrint(oReport)})

IF Valtype( oReport ) == 'O'
	If !Empty( oReport:uParam )
		Pergunte( oReport:uParam, .F. )
	EndIf
	oReport:PrintDialog()
Endif

oReport := Nil

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³ Roberto Rogério Mezzalira ³ Data ³ 30/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime o relatorio definido pelo usuario de acordo com as       ³±±
±±³          ³secoes/celulas criadas na funcao ReportDef definida acima.       ³±±
±±³          ³Nesta funcao deve ser criada a query das secoes se SQL ou        ³±±
±±³          ³definido o relacionamento e filtros das tabelas em CodeBase.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportPrint(oReport)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³EXPO1: Objeto do relatório                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport)
Local oSection1		:= oReport:Section(1)
Local nToDiaD		:= 0
Local nToMesC		:= 0
Local nToMesD		:= 0
Local nK			:= 0
Local nSaldoFin		:= 0
Local cFilOld		:= cFilAnt
Local aArea			:= GetArea()
Local aAreaSM0		:= SM0->(GetArea())
Local nValor1		:= 0
Local cTitulo		:= ""
Local cSql003		:= ""
Local cQryCV3		:= ""

Public lPrintZero	:= .T.

CTB461Dim(oReport)

For nK := 1 to Len(aSelFil)
	cFilAnt := aSelFil[nK]
	SM0->(DbSeek(cEmpAnt+cFilAnt))
	nToDiaD		:= 0
	nToMesC		:= 0
	nToMesD		:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| titulo do relatorio                                          |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If CT1->(DbSeek(xFilial("CT1") + cConta1))
		cTitulo := STR0002 + " " + cConta1 + " " + Lower(Alltrim(CT1->CT1_DESC01))
	Else
		cTitulo := STR0002 + " " + cConta1
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| cabeçalho do relatorio                                       |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SetCustomText( {|| CTB461CabL(oReport,cTitulo,MV_PAR01,MV_PAR02,(MV_PAR04 == 1))} )
	cAliasqry := GetNextAlias()

	IF Select( cAliasqry ) > 0
		dbSelectArea( cAliasqry )
        dbCloseArea()
    EndIf

	cQryCV3 := BuscaConta(cConta1)

    cSql003 += " SELECT SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SA2.A2_CGC, SA2.A2_TIPDOC, SA2.A2_PFISICA, SE2.E2_EMISSAO, SE2.E2_NUM, SE2.E2_VALOR, SE2.E2_SALDO, SE2.E2_NODIA E2NODIA, SE2.R_E_C_N_O_ E2RECNO, SF1.F1_NODIA F1NODIA, SF1.R_E_C_N_O_ F1RECNO, CV3.CV3_CREDIT "
    cSql003 += " FROM " + RetSqlName("SE2") + " SE2 "
    cSql003 += "      JOIN " + RetSqlName("SA2") + " SA2 ON SE2.E2_FORNECE = SA2.A2_COD AND SE2.E2_LOJA = SA2.A2_LOJA AND SA2.D_E_L_E_T_ = ' ' "
    cSql003 += "      LEFT JOIN " + RetSqlName("SF1") + " SF1 ON SF1.F1_FORNECE = SE2.E2_FORNECE AND SE2.E2_LOJA = SF1.F1_LOJA AND SF1.F1_DOC = SE2.E2_NUM AND SF1.F1_DTDIGIT = SE2.E2_EMISSAO "
    cSql003 += "      JOIN " + RetSqlName("CV3") + " CV3 " + cQryCV3
    cSql003 += " WHERE E2_FILIAL = '" + xFilial('SE2') + "' "
    cSql003 += "     AND E2_EMISSAO >= '" + DTOS(MV_PAR01) + "' "
    cSql003 += "     AND E2_EMISSAO <= '" + DTOS(MV_PAR02) + "' "
    cSql003 += "     AND SE2.E2_SALDO <> 0  "
    cSql003 += "     AND SE2.D_E_L_E_T_ = ' ' "
    cSql003 += " UNION "
    cSql003 += " SELECT SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SA2.A2_CGC, SA2.A2_TIPDOC, SA2.A2_PFISICA, SE2.E2_EMISSAO, SE2.E2_NUM, SE2.E2_VALOR, SE2.E2_SALDO, SE2.E2_NODIA E2NODIA, SE2.R_E_C_N_O_ E2RECNO, SF1.F1_NODIA F1NODIA, SF1.R_E_C_N_O_ F1RECNO, CV3.CV3_CREDIT "
    cSql003 += " FROM " + RetSqlName("SE2") + " SE2 "
    cSql003 += "      JOIN " + RetSqlName("SA2") + " SA2 ON SE2.E2_FORNECE = SA2.A2_COD AND SE2.E2_LOJA = SA2.A2_LOJA AND SA2.D_E_L_E_T_ = ' ' "
    cSql003 += "      LEFT JOIN " + RetSqlName("SF1") + " SF1 ON SF1.F1_FORNECE = SE2.E2_FORNECE AND SE2.E2_LOJA = SF1.F1_LOJA AND SF1.F1_DOC = SE2.E2_NUM AND SF1.F1_DTDIGIT = SE2.E2_EMISSAO "
    cSql003 += "      JOIN " + RetSqlName("CV3") + " CV3 " + cQryCV3
    cSql003 += " WHERE E2_FILIAL = '" + xFilial('SE2') + "' "
    cSql003 += "     AND E2_EMISSAO >= '" + DTOS(MV_PAR01) + "' "
    cSql003 += "     AND E2_EMISSAO <= '" + DTOS(MV_PAR02) + "' "
    cSql003 += "     AND SE2.E2_SALDO <> 0  "
    cSql003 += "     AND SE2.D_E_L_E_T_ = ' ' "
    cSql003 += "     AND SE2.E2_BAIXA > '" + DTOS(MV_PAR02) + "' "
    cSql003 += "	ORDER BY A2_COD, A2_LOJA "

    cSql003	:= ChangeQuery(cSql003)
    cAliasqry := GetNextAlias()
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql003 ), cAliasqry,.T.,.T.)
    (cAliasqry)->(dBGotop())
	DBSelectArea(cAliasqry)
	DBGOTOP()

	oREPORT:SETMETER(RECCOUNT())
	nSaldoFin := 0

	oSection1:INIT()

	DO WHILE (cAliasqry)->(!Eof())
		IF oREPORT:CANCEL()
			EXIT
		ENDIF

		DBSELECTAREA('SE2')
		SE2->(DBGOTO((cAliasqry)->E2RECNO))
		nValor1 := 0

		IF SE2->E2_TIPO $ 'PA '
			nValor1 := -SE2->E2_SALDO
		ELSE
			nValor1 := SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE,VAL(MV_PAR03),MV_PAR02,MV_PAR02,SE2->E2_LOJA)
			IF SE2->E2_TIPO $ 'NDF'
				nValor1 := nValor1 * -1
			ENDIF
		ENDIF

		DBSELECTAREA(cAliasqry)
		oSection1:Cell("CTIPO"     ):SetBlock( { || (cAliasqry)->A2_TIPDOC } )
		oSection1:Cell("CNUMERO"   ):SetBlock( { || IIf((cAliasqry)->A2_TIPDOC == '06' .Or. Alltrim((cAliasqry)->A2_TIPDOC) == '6', (cAliasqry)->A2_CGC, (cAliasqry)->A2_PFISICA) } )
		oSection1:Cell("CNOME"	   ):SetBlock( { || (cAliasqry)->A2_NOME} )
		oSection1:Cell("NVALOR"    ):SetBlock( { || nValor1 } )
		oSection1:Cell("DTPGTO"    ):SetBlock( { || STOD((cAliasqry)->E2_EMISSAO) } )
		oSection1:PrintLine()
		nSaldoFin += nValor1

		DBSELECTAREA(cAliasqry)
		DBSKIP()
		oREPORT:INCMETER()
	ENDDO

	CTB461Tot({{"TOTVAL",nSaldoFin}})
	oReport:EndPage()
	oReport:SetPageNumber(1)
Next nK

cFilAnt := cFilOld
RestArea(aAreaSM0)
RestArea(aArea)

If cConta1 == "42" .And. MV_PAR05 == 2
	If MSGYESNO(STR0030,"")//"¿Generar archivo TXT?")
	   Processa({|| GerArq(AllTrim(MV_PAR06),cAliasqry)},,STR0031) //Generando archivo...
	Endif
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBR463   ºAutor  ³Microsiga           º Data ³  17/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao da Conta + Descricao                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CTB463Cta(aValores)
Local nX	:= 0

Default aValores	:= {}

If !Empty(aValores)
	If Type("aRelatorio") <> "A"
		aRelatorio := {}
	Endif
	aRelatorio[7,1]:Init()
	For nX := 1 To Len(aValores)
		aRelatorio[7,1]:Cell(aValores[nX,1]):SetValue(aValores[nX,2])
	Next
	aRelatorio[7,1]:PrintLine()
	aRelatorio[7,1]:Finish()
Endif

Return()


Static Function BuscaConta(cDigConta)

Local lMSSQL  := "MSSQL"   $ Alltrim(Upper(TCGetDB()))
Local cSql003 := ""

cSql003 += "  ON CV3.CV3_FILIAL = '" + xFilial('CV3') + "' "
cSql003 += " AND ((CV3.CV3_TABORI = 'SE2' AND CV3.CV3_RECORI = SE2.R_E_C_N_O_) "
cSql003 += "  OR  (CV3.CV3_TABORI = 'SF1' AND CV3.CV3_RECORI = SF1.R_E_C_N_O_)) "

If lMSSQL
	If cDigConta == "42"
		cSql003 += " AND SUBSTRING(CV3_CREDIT,1,2) IN ('42','43') "
	Else
		cSql003 += " AND SUBSTRING(CV3_CREDIT,1,2)='" + cDigConta + "' "
	EndIf
Else
	If cDigConta == "42"
		cSql003 += " AND SUBSTR(CV3_CREDIT,1,2) IN ('42','43') "
	Else
		cSql003 += " AND SUBSTR(CV3_CREDIT,1,2)='" + cDigConta + "' "
	EndIf
EndIF

cSql003 += " AND CV3.D_E_L_E_T_ = ' ' "
Return cSql003

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ GerArq   ³ Autor ³ Verónica Flores     ³ Data ³ 27.03.2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ 3.12 LIBRO DE INVENTARIOS Y BALANCES SALDO CTA 42 Y 43 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cDir - Directorio de creación de archivo.                  ³±±
±±³            ³ cArq - Nome do arquivo com extensao do arquivo.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Peru                  - Arquivo Magnetico           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GerArq(cDir,cAliasqry)

Local nHdl		:= 0
Local cLin		:= ""
Local cSep		:= "|"
Local nCont		:= 0
Local cArq		:= ""
Local nMes		:= Month(MV_PAR02)
Local cCampo3	:= ""

FOR nCont:=LEN(ALLTRIM(cDir)) TO 1 STEP -1
	IF SUBSTR(cDir,nCont,1)=='\'
		cDir := Substr(cDir,1,nCont)
		EXIT
	ENDIF
NEXT

DBSelectArea(cAliasqry)
DBGOTOP()

cArq += "LE"                                  // Fixo  'LE'
cArq += AllTrim(SM0->M0_CGC)                 // Ruc
cArq += AllTrim(Str(Year(MV_PAR02)))         // Ano
cArq += AllTrim(Strzero(Month(MV_PAR02),2))  // Mes
cArq += AllTrim(Strzero(Day(MV_PAR02),2))    // Dia
cArq += "031200" 						  // Fixo '031200'
//Código de Oportunidad
If nMes == 12
	cArq += "01"
ElseIf nMes == 1
	cArq += "02"
ElseIf nMes == 6
	cArq += "04"
Else
	cArq += "07"
EndIf

cArq += "1"
cArq += "1"
cArq += "1"
cArq += "1"
cArq += ".TXT" // Extensao

nHdl := fCreate(cDir+cArq)

If nHdl <= 0
	ApMsgStop(STR0028,"")//"Ocurrió un error al crear el archivo Txt."

Else
	DO WHILE (cAliasqry)->(!Eof())
		cLin := ""
		//01 - Periodo
		cLin += DTOS(mv_par02)
		cLin += cSep

		//02 - Código Único de la Operación (CUO)
		If ALLTRIM(F1NODIA) != ""
			cLin += AllTrim(F1NODIA)
		Else
			cLin += AllTrim(E2NODIA)
		EndIf
		cLin += cSep

		//03 - Número correlativo del asiento contable identificado en el campo 2.
		If (cAliasqry)->F1NODIA != ""
			cCampo3 := Right(AllTrim(F1NODIA),9)
		Else
			cCampo3 := Right(AllTrim(E2NODIA),9)
		EndIf
		cCampo3 := Strtran( PadL(cCampo3,9), Space(1), "0")
		cLin += "M" + cCampo3
		cLin += cSep

		//04 - Tipo de Documento de Identidad del Proveedor
		If AllTrim(A2_TIPDOC) == ""
			If AllTrim(A2_CGC) != ""
				cLin += "6"
			Else
				cLin += "0"
			EndIf
		Else
			cLin += Right(AllTrim(A2_TIPDOC),1)
		EndIf
		cLin += cSep

		//05- Número de Docuemnto de Identidad del Proveedor.
		If Right(AllTrim(A2_TIPDOC),1) == '6'
			cLin += AllTrim(A2_CGC)
		Else
			cLin += AllTrim(A2_PFISICA)
		EndIf
		cLin += cSep

		//06 - Fecha de emisión de Comprobante de Pago
		cData := IIf(Empty(E2_EMISSAO), MV_PAR02, STOD(E2_EMISSAO))
		cLin += StrZero(Day(cData),2) + "/" + StrZero(Month(cData),2) + "/" + StrZero(Year(cData),4)
		cLin += cSep

		//07 - Apellidos y Nombres, Denominación o Razón Social del Proveedor.
		cLin += AllTrim(A2_NOME)
		cLin += cSep

		//08 - Monto de cada cuenta por pagar al proveedor
		cLin += IIF(AllTrim(STR(E2_SALDO)) == "0" , "0.00", AllTrim(STR(E2_SALDO,15,2)))
		cLin += cSep

		//09 - Indica el estado de la Operación
		cLin += "1"
		cLin += cSep

		cLin += chr(13)+chr(10)
		fWrite(nHdl,cLin)
		dbSelectArea(cAliasqry)
		dbSkip()
	EndDo

	fClose(nHdl)
	MsgAlert(STR0029,"")//"Archivo Txt generado con éxito."

EndIf

Return Nil
