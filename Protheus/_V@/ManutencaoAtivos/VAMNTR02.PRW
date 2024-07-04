/*
Relatório:

- Parametros
	- Fornecedor de até
	- Data do Fechamento de/Até: (Filtrar campo novo de data de fechamento na TQN)
	- Data Abastecimento (TQN_DTABAS)
	- Cod. Combustível
	- Veículo (TQN Frota)
	
	
	Sessão por Fornecedor 
	1º Sessão informações dos abastecimentos
	
	2ºSessão dados do título financeiro (SE2) SE HOUVER
*/

#include "fileio.ch"
#Include "Protheus.ch"
#include "Tbiconn.ch"
#include "TopConn.ch"
#include "Totvs.ch"
// ###############################################################################################
// Projeto: 
// Fonte  : VAMNTR02.prw
// ---------+------------------------------------+------------------------------------------------
// Data     | Autor                              | Descricao
// ---------+------------------------------------+------------------------------------------------
//  11/03/22|  Manoel Filho                      | Relatório dos Abastecimentos
// ---------+------------------------------------+------------------------------------------------
User Function VAMNTR02()

Local j  , i
Private aReturn   := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private cTitulo   := "Relacao de Abastecimentos"
Private cPerg	  := "VAMNTR02"

aRegs := {}

Aadd(aRegs,{cPerg,"01","Forcecedor de" ,"","","mv_ch1","C", 06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA2",""})
Aadd(aRegs,{cPerg,"02","Loja de"        ,"","","mv_ch2","C", 02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"03","Forcecedor até" ,"","","mv_ch3","C", 06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA2",""})
Aadd(aRegs,{cPerg,"04","Loja de"        ,"","","mv_ch4","C", 02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"05","Data Abast de"  ,"","","mv_ch5","D", 08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"06","Data Abast até" ,"","","mv_ch6","D", 08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"07","Data Fechamento","","","mv_ch7","D", 08,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"08","Combustivel"    ,"","","mv_ch8","C", 03,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","TQM",""})
Aadd(aRegs,{cPerg,"09","Veiculo(Frota)" ,"","","mv_ch9","C", 18,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","ST9",""})

For i:=1 to Len(aRegs)
	If !SX1->(dbSeek(cPerg+"  "+aRegs[i,2]))
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

PERGUNTE(cPerg,.F.) 

set century on  // Seta ano com 4 digitos

VAMNTR02_ImprimeTReport()

Return                                              

/*/{Protheus.doc} VAMNTR02_ImprimeTReport
Chamada do TReport
@author Manoel Filho
@since 11/03/2022
@version undefined
@param 
@type function
/*/
Static Function VAMNTR02_ImprimeTReport()
	Local oReport

	oReport := ReportDef() // Nesta função nós definimos a estrutura do relatório, por exemplo as seções, campos, totalizadores e etc.
	//oReport:SetPortrait()  // Define orientação de página do relatório como retrato.
	oReport:SetLandScape()  // Define orientação de página do relatório como paisagem.
	oReport:PrintDialog()  // Essa função serve para disparar a impressão do TReport, ela que faz com que seja exibida a tela de configuração de impressora e os botões de parâmetros.
Return


/*/{Protheus.doc} ReportDef
TReport
@author Manoel Filho
@since 11/03/2022
@version undefined
@param 
@type function
/*/
Static Function ReportDef()
	Local cDesc := ""
	Local oReport
	Local oSection1
	Local oSection2
	Local oSection3

	dDataAb := cTod('')
	cTransp := ""
	cNrAbas := ""
	cCombus := ""
	nQtdLit := 0
	nPreCom := 0
	nTotAba := 0
	cPlaca  := ""
	cMotori := ""
	cNroTit := ""
	cPrefix := ""
	cTipTit := ""
	dEmissa := cTod('')
	nValTit := 0
	dDatFec := cTod('')

	cQuebra := ""
	
	// Descrição
	cDesc := cTitulo

	// TReport
	oReport := TReport():New(           ;
		"VAMNTR02",                     ;
		cTitulo,                        ;
		cPerg,                          ;
		{|oReport| U_I_VAMNTR02(oReport)},;
		cDesc)


	// Cabeçalho
	oSection1 := TRSection():New(oReport, "oQuebra")
	oReport:Section(1):SetLineStyle() // Define se imprime as células da seção em linhas
	oSection1:SetLinesBefore(1)       // Define a quantidade de linhas que serão saltadas antes da impressão da seção
	TRCell():New(oSection1, "oQuebra",, "Transportadora", "@!", 30,, {|| cQuebra },,,,,,,,, .t.) // Transportadora

	// Abastecimentos
	oSection2 := TRSection():New(oReport, "oAbastecimentos")
	oSection2:SetLinesBefore(1) // Define a quantidade de linhas que serão saltadas antes da impressão da seção
	TRCell():New(oSection2, "oDataAb",, OEmToAnsi("Data Abastec")  , "@D"               ,  16,, {|| dDataAb },,,,,,,,,) 
	TRCell():New(oSection2, "oTransp",, OEmToAnsi("veículo")       , "@!"               ,  40,, {|| cVeiculo },,,,,,,,,)
	TRCell():New(oSection2, "oPlaca" ,, OEmToAnsi("Placa")         , "@!"               ,  12,, {|| cPlaca  },,,,,,,,,)  
	TRCell():New(oSection2, "oNrAbas",, OEmToAnsi("Nro Abast")     , "@!"               ,  15,, {|| cNrAbas },,,,,,,,,) 
	TRCell():New(oSection2, "oCombus",, OEmToAnsi("Combustivel")   , "@!"               ,  20,, {|| cCombus },,,,,,,,,) 
	TRCell():New(oSection2, "oQtdLit",, OEmToAnsi("Qtd Litros")    , "@E 99,999.999"    ,  20,, {|| nQtdLit },,,,,,,,,) 
	TRCell():New(oSection2, "oPreCom",, OEmToAnsi("Preço Litro")   , "@E 99,999.999"    ,  20,, {|| nPreCom },,,,,,,,,) 
	TRCell():New(oSection2, "oTotAba",, OEmToAnsi("Total Abastec") , "@E 9,999,999.999" ,  20,, {|| nTotAba },,,,,,,,,) 
	TRCell():New(oSection2, "oMotori",, OEmToAnsi("Motorista")     , "@!"               ,  30,, {|| cMotori },,,,,,,,,) 
	TRCell():New(oSection2, "oDatFec",, OEmToAnsi("DataFechamento"), "@D"               ,  30,, {|| dDatFec },,,,,,,,,) 

	// Dados Financeiros
	oSection3 := TRSection():New(oReport, "oFinanceiro")
	//oReport:Section(3):SetLineStyle() // Define se imprime as células da seção em linhas
	oSection3:SetLinesBefore(1) // Define a quantidade de linhas que serão saltadas antes da impressão da seção
	TRCell():New(oSection3, "oNroTit",, OEmToAnsi("Nro Titulo")  , "@!"               , 30,, {|| cNroTit },,,,,,,,,)
	TRCell():New(oSection3, "oPrefix",, OEmToAnsi("Prefixo")     , "@!"               , 20,, {|| cPrefix },,,,,,,,,)
	TRCell():New(oSection3, "oTipTit",, OEmToAnsi("Tipo")        , "@!"               , 20,, {|| cTipTit },,,,,,,,,)
	TRCell():New(oSection3, "oValTit",, OEmToAnsi("Valor Título"), "@E 99,999,999.999", 40,, {|| nValTit },,,,,,,,,)
	TRCell():New(oSection3, "oEmissa",, OEmToAnsi("Emissao")     , "@D"               , 30,, {|| dEmissa },,,,,,,,,)


Return(oReport)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³I_VAMNTR02ºAutor  ³Manoel Filho        º Data ³  11/13/22   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function I_VAMNTR02(oReport)
  
Local cQuery      := ""
Local oSection1   := oReport:Section(1)
Local oSection2   := oReport:Section(2)
Local oSection3   := oReport:Section(3)
static cPath      := "C:\totvs_relatorios\"
dDataAb := cTod("")
cTransp := ""
cNrAbas := ""
cCombus := ""
nQtdLit := 0
nPreCom := 0
nTotAba := 0
cPlaca  := ""
cMotori := ""
dDatFec := cTod("")
cNroTit := ""
cPrefix := ""
cTipTit := ""
dEmissa := cTod("")
nValTit := 0

Private oSqlHlp := DMS_SqlHelper():New()


// Le Abastecimentos do Periodo
If Select("TMPTQN") > 0
	TMPTQN->(dbCloseArea())
EndIf
	
cQuery := "SELECT TQN.TQN_FILIAL, TQN.TQN_FROTA, ST9.T9_NOME, TQN.TQN_DTABAS, TQN.TQN_FORST9, TQN.TQN_LOJST9, SA2.A2_NOME, TQN.TQN_CODCOM, TQM.TQM_NOMCOM, TQN.TQN_QUANT, TQN.TQN_NRABAS,TQN_VUNABA,TQN.TQN_VTTABA, TQN.TQN_DTFABA, ISNULL(TQN.TQN_PLACA, ST9.T9_PLACA) TQN_PLACA, DA4.DA4_NOME, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_TIPO, SE2.E2_VENCTO, SE2.E2_VALOR " +CRLF
cQuery += "  FROM "+RetSqlName("TQN")+" TQN " +CRLF
cQuery += "  JOIN "+RetSqlName('ST9')+" ST9 ON ( ST9.T9_FILIAL = '"+xFilial("ST9")+ "' " +CRLF
cQuery += "      AND ST9.T9_CODBEM = TQN.TQN_FROTA " +CRLF
cQuery += "      AND ST9.D_E_L_E_T_ = ' ' )" +CRLF
cQuery += "  JOIN "+RetSqlName("TQM")+" TQM ON ( TQM.TQM_FILIAL = '"+xFilial("TQM")+ "' " +CRLF
cQuery += "      AND TQM.TQM_CODCOM = TQN.TQN_CODCOM " +CRLF
cQuery += "  	 AND TQM.D_E_L_E_T_ = ' ' )" +CRLF
cQuery += "  JOIN "+RetSqlName("DA4")+" DA4 ON ( DA4.DA4_FILIAL = '"+xFilial("DA4")+ "' " +CRLF
cQuery += "      AND DA4.DA4_COD = TQN.TQN_CODMOT " +CRLF
cQuery += "  	 AND DA4.D_E_L_E_T_ = ' ' )" +CRLF
cQuery += "  LEFT JOIN "+RetSqlName("SA2")+" SA2 ON ( SA2.A2_FILIAL = '"+xFilial("SA2")+ "' " +CRLF
cQuery += "     AND SA2.A2_COD+SA2.A2_LOJA = TQN.TQN_FORST9+TQN.TQN_LOJST9 " +CRLF
cQuery += "  	AND SA2.D_E_L_E_T_= ' ' ) " +CRLF
cQuery += "  LEFT JOIN "+RetSqlName("SE2")+" SE2 ON ( SE2.E2_FILIAL = '"+xFilial("SE2")+ "' " +CRLF
cQuery += "     AND SE2.E2_FORNECE+SE2.E2_LOJA = TQN.TQN_FORST9+TQN.TQN_LOJST9 " +CRLF
cQuery += "     AND SE2.E2_FILIAL+SE2.E2_PREFIXO+SE2.E2_NUM+SE2.E2_PARCELA+SE2.E2_TIPO = TQN.TQN_TITABA " +CRLF
cQuery += "  	AND SE2.D_E_L_E_T_= ' ' ) " +CRLF
cQuery += "    WHERE TQN.TQN_FILIAL='"+xFilial("TQN")+"' AND ST9.T9_PROPRIE='2'" 

//If !Empty(Mv_Par01) .and. !Empty(Mv_Par02)
	cQuery += "      AND TQN.TQN_FORST9 >= '"+Mv_Par01+"'"
	cQuery += "      AND TQN.TQN_LOJST9 >= '"+Mv_Par02+"'"
//Endif

//If !Empty(Mv_Par03) .and. !Empty(Mv_Par04)
	cQuery += "      AND TQN.TQN_FORST9 <= '"+Mv_Par03+"'"
	cQuery += "      AND TQN.TQN_LOJST9 <= '"+Mv_Par04+"'"
//Endif

If !Empty(Mv_Par05) .and. !Empty(Mv_Par06)
	cQuery += "      AND TQN.TQN_DTABAS BETWEEN '"+Dtos(Mv_Par05)+"' AND '"+dTos(Mv_Par06) +"'"
Endif

If !Empty(Mv_Par07)
	cQuery += "      AND TQN.TQN_DTFABA = '"+Dtos(Mv_Par07)+"'"
Endif

If !Empty(Mv_Par08)
	cQuery += "      AND TQN.TQN_CODCOM = '"+Mv_Par08+"'"
Endif

If !Empty(Mv_Par09)
	cQuery += "      AND TQN.TQN_FROTA = '"+Mv_Par09+"'"
Endif

cQuery += " ORDER BY 1, 5, 2"

if lower(cUserName) $ 'mbernardo,atoshio,admin,administrador'
	MemoWrite(cPath + "Rel_Abast_Terceiros" + DtoS(dDataBase) + "_" + StrTran(SubS(Time(),1,5),":","") + ".sql", cQuery)
EndIf
DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TMPTQN", .f., .f.)

cQuebra := ""

While TMPTQN->( !Eof() )

	// Quebra
	if cQuebra <> TMPTQN->A2_NOME
		oSection1:Init()
		cQuebra := TMPTQN->A2_NOME
		oSection1:PrintLine()
		oSection1:Finish()
	Endif

	// Abastecimentos
	oSection2:Init()

	While TMPTQN->( !Eof() ) .and. cQuebra == TMPTQN->A2_NOME

		dDataAb := Stod(TMPTQN->TQN_DTABAS)
		cVeiculo := TMPTQN->T9_NOME
		cPlaca  := TMPTQN->TQN_PLACA
		cNrAbas := TMPTQN->TQN_NRABAS
		cCombus := TMPTQN->TQM_NOMCOM
		nQtdLit := TMPTQN->TQN_QUANT
		nPreCom := TMPTQN->TQN_VUNABA
		nTotAba := TMPTQN->TQN_VTTABA
		cMotori := TMPTQN->DA4_NOME
		dDatFec := Stod(TMPTQN->TQN_DTFABA)

		// Dados Financeiros
		cNroTit := TMPTQN->E2_NUM
		cPrefix := TMPTQN->E2_PREFIXO
		cTipTit := TMPTQN->E2_TIPO
		dEmissa := Stod(TMPTQN->E2_VENCTO)
		nValTit := TMPTQN->E2_VALOR

		oSection2:PrintLine()

		TMPTQN->(DbSkip())

	Enddo

	// Dados Financeiros
	oSection3:Init()
	oSection3:PrintLine()
	oSection3:Finish()
	
	oSection2:Finish()
	//oReport:ThinLine() // linha
	oReport:EndPage()

	TMPTQN->(DbSkip())
	
EndDo	

TMPTQN->( DbCloseArea() )

oReport:Finish()

Return

