// ษออออออออหออออออออป
// บ Versao บ 81     บ
// ศออออออออสออออออออผ

#Include "PROTHEUS.CH"
#Include "VEIXI002.CH"

Static cPrefVEI := GetNewPar("MV_PREFVEI","VEI")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ VEIXI002 บ Autor ณ Andre Luis / Rubens บ Data ณ  07/05/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Geracao de Pedido (SC5/SC6) / NF (SF2) / Titulos (SE1/SE2) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cNumAte   = Nro do Atendimento                             บฑฑ
ฑฑบ          ณ lPedido   = Cria Pedido  ? ( SC5 / SC6 )                   บฑฑ
ฑฑบ          ณ lNF       = Cria NF      ? ( SF2 / SD2 )                   บฑฑ
ฑฑบ          ณ lTitulos  = Cria Titulos ? ( SE1 / SE2 )                   บฑฑ
ฑฑบ          ณ cSerie    = Serie da Nota Utilizada para o Faturamento     บฑฑ
ฑฑบ          ณ lManutenc = Manutencao da Proposta? (Alteracao nos Titulos)บฑฑ
ฑฑบ          ณ cFaseAtu  = Fase Atual                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculos                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIXI002(cNumAte,lPedido,lNF,lTitulos,cSerie,lManutenc,cFaseAtu, lXI002Auto)
	Local lRetFat    := .f.

	Default lXI002Auto := .f.

	Private lIntLoja := ( Substr(GetNewPar("MV_LOJAVEI","NNN"),3,1) == "S" )
	Private cTitAten := IIf(lIntLoja,"2",left(GetNewPar("MV_TITATEN","0"),1))

	Processa( { || lRetFat := VXI002FAT(cNumAte,lPedido,lNF,lTitulos,cSerie,lManutenc,cFaseAtu, lXI002Auto) } )

Return lRetFat

Static Function VXI002FAT(cNumAte,lPedido,lNF,lTitulos,cSerie,lManutenc,cFaseAtu, lXI002Auto)
Local lRet        := .t.
Local nRecVV9     := 0
Local nRecVV0     := 0
Local nRecVV1     := 0
Local nRecSB1     := 0
Local ni          := 0
Local nParc       := 0
Local cParc       := ""
Local cQuery      := ""
Local cSQLAlias   := "SQLALIAS"
Local cPrograE1   := "MATA460"
Local aCamposE1   := {"E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO","E1_NATUREZ","E1_CLIENTE","E1_LOJA","E1_EMISSAO","E1_VENCTO","E1_VENCREA","E1_VALOR","E1_NUMBOR","E1_DATABOR","E1_PORTADO","E1_PREFORI","E1_SITUACA","E1_VEND1","E1_COMIS1","E1_BASCOM1","E1_PEDIDO","E1_NUMNOTA","E1_SERIE","E1_ORIGEM","E1_CCC","E1_DECRESC"}
Local aCamposE2   := {"E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_NATUREZ","E2_FORNECE","E2_LOJA","E2_EMISSAO","E2_VENCTO","E2_VALOR","E2_VLCRUZ","E2_NOMFOR","E2_NUMBOR","E2_PORTADO","E2_PREFORI"}
Local lBaixaAut   := ( left(Alltrim(GetMV("MV_BXVEI")),1) $ "S/1" ) // Fazer BAIXA AUTOMATICA
Local aCampoAut   := {"E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO","AUTOTBX","AUTMOTBX","AUTDTBAIXA","AUTDTCREDITO","AUTHIST","AUTVALREC"}
Local aBaixaAut   := {} // Titulos SE1 a serem Baixados automaticamente
Local aAtualVS9   := {} // Atualiza VS9
Local cNatureza   := ""
Local cNatTit     := ""
Local cCodCli     := ""
Local cLojCli     := ""
Local cPrefixo    := space(TamSX3("E1_PREFIXO")[1])
Local cPreTit     := ""
Local cNumTit     := ""
Local cParcela    := ""
Local cTipTit     := ""
Local cSituaca    := "0"
Local nVlrTit     := 0
Local cCodBco     := ""
Local cNumBord    := ""
Local dDatBord    := ctod("")
Local nVlrAux     := 0
Local dDtEmis     := dDataBase
Local dDtVenc     := dDataBase
Local cNumPed     := ""
Local cItemPed    := ""
Local cLocVei     := ""
Local aItePv      := {}
Local aPvlNfs     := {}
Local nIteLib     := 0
Local cNota       := ""
Local lCriaTit    := .f.
Local cGruVei     := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Local nVlConsor   := 0
Local nPos        := 0
Local cSE1CVend   := ""
Local nSE1Comis   := 0
Local nRecSA1     := 0
Local nVlrSC6     := 0
Local cChamada    := "1/2" // Titulos a serem gerados ( 1 = SE1 para cliente igual ao VV9_CODCLI / 2 = SE1/SE2 para cliente diferente do VV9_CODCLI )
Local lOrcLoja    := .f. // Controla se gera orcamento do loja 
Local cNCCNCF     := GetNewPar("MV_MIL0057","2") // Titulo de Troco NCC (1=SE1) ou NCF (2=SE2) + Codigo da Natureza do Titulo
Local nTamE1_TIPO := TamSX3("E1_TIPO")[1]
//
Local nQtdVeicu   := 0
Local nCntVeicu   := 0
Local nTotValVda  := 0
Local nSomValVda  := 0
Local aValVVA     := {}
//
Local cMsgSC9     := ""
//
Local oLogger     := DMS_Logger():New()
Local aLogVQL     := {}
//
Local lSD2_CHASSI := ( SD2->(FieldPos("D2_CHASSI"))  > 0 )
Local lVV0_CFFINA := ( VV0->(FieldPos("VV0_CFFINA")) > 0 )
Local lVV1_DTUVEN := ( VV1->(FieldPos("VV1_DTUVEN")) > 0 ) // Data da Ultima Venda
Local lVV0_GERFIN := ( VV0->(FieldPos("VV0_GERFIN")) > 0 ) // Campo que controla se gerou FINANCEIRO (Titulos)
Local lVS9_PARCVD := ( VS9->(FieldPos("VS9_PARCVD")) > 0 ) // Controla Parcela que vai para o Venda Direta ( somente quando estiver integrado com o Venda Direta )
//
Local lCPagPad    := ( GetNewPar("MV_MIL0016","0") == "1" ) //Utiliza no Atendimento de Veํculos, Condi็ใo de Pagamento da mesma forma que no Faturamento Padrใo do ERP? (0=Nใo / 1= Sim) - Chamado CI 001985
Local lVV0FPGPAD  := (VV0->(FieldPos("VV0_FPGPAD")) > 0) //Utiliza no Atendimento de Veํculos, Condi็ใo de Pagamento da mesma forma que no Faturamento Padrใo do ERP? (0=Nใo / 1= Sim)
Local l1DUPNATAlt := ( "C5_NATUREZ" $ Upper(SuperGetMv("MV_1DUPNAT",.F.,"")) ) .and. SC5->(FieldPos("C5_NATUREZ")) <> 0
//
Private lEntrada    := .f. // Verifica se existe titulos A VISTA a ser enviado ao loja - deixar Private para poder mudar de dentro do PE
Private aParcelE1   := {} // Titulos Contas a Receber - deixar Private para poder mudar de dentro do PE
Private aParcelE2   := {} // Titulos Contas a Pagar - deixar Private para poder mudar de dentro do PE
//
Default lXI002Auto := .f.
//
Private aCabPv    := {}
Private aIteTPv   := {}
Default lPedido   := .f.
Default lNF       := .f.
Default lTitulos  := .f.

ProcRegua(3)

If lCPagPad // Condi็ใo de Pagto Padrใo ERP (igual ao Faturamento)
	//
 	lIntLoja := .f.
	cTitAten := "0" // gera็ใo de Tํtulio na Finaliza็ใo do Atendimento
	//
EndIf

VV9->(DbSetOrder(1))
If !VV9->(DbSeek(xFilial("VV9")+cNumAte))
	MsgStop(STR0001+" "+cNumAte,STR0002) // Atendimento nao encontrado: / Atencao
	Return .f.
EndIf

VV0->(DbSetOrder(1))
If !VV0->(DbSeek(xFilial("VV0")+cNumAte))
	MsgStop(STR0001+" "+cNumAte,STR0002) // Atendimento nao encontrado: / Atencao
	Return .f.
EndIf

VVA->(DbSetOrder(1))
If !VVA->(DbSeek(xFilial("VVA")+cNumAte))
	MsgStop(STR0001+" "+cNumAte,STR0002) // Atendimento nao encontrado: / Atencao
	Return .f.
EndIf

If lCPagPad .or. (lVV0FPGPAD .and. VV0->VV0_FPGPAD == "1") // Condi็ใo de Pagto Padrใo (igual ao Faturamento)
	//
 	lIntLoja := .f.
	cTitAten := "0" // gera็ใo de Tํtulio na Finaliza็ใo do Atendimento
	//
EndIf

If lIntLoja .and. !VXX002DUPL(2) // Verifica se os TES utilizados geram ou nao duplicatas  ( .t. = Gerar Duplicatas )
 	lIntLoja := .f.
EndIf

SA1->(DbSetOrder(1))
SA1->(MsSeek(xFilial("SA1")+VV9->VV9_CODCLI+VV9->VV9_LOJA))
//
cNatureza := VXI02NAT("0","") // Natureza 0=Inicial
//
nRecSA1 := SA1->(RecNo())
//
lRet := VXI02VLD(nRecSA1) // Validacao antes de chamar os ExecAutos de NF e Titulos
If !lRet
	DisarmTransaction()
	RollbackSxe()
	Return .f.
EndIf
//
SA3->(DbSetOrder(1))
SA3->(MsSeek(xFilial("SA3")+VV0->VV0_CODVEN))
//
If lVV0_GERFIN // Existe o campo que controla a Geracao do Financeiro (Titulos)
	If !Empty(VV0->VV0_NUMNFI)
		SF2->(DbSetOrder(1))
		SF2->(MsSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI))
		cPreTit := SF2->F2_PREFIXO
	Else
		cPreTit := &(GetNewPar("MV_PTITVEI","''")) // Prefixo dos Titulos de Veiculos
	EndIf
Else // Nao existe o campo que controla a Geracao de Titulos
	If cTitAten <> "0" .or. ( cTitAten=="0" .and. !lPedido .and. !lNF .and. lTitulos ) // Geracao de Titulos na 1=Pre-Aprovacao ou 2=Aprovacao
		cPreTit := &(GetNewPar("MV_PTITVEI","''")) // Prefixo dos Titulos de Veiculos
	EndIf
EndIf
//
If !Empty(VVA->VVA_CHASSI)
	FGX_VV1SB1("CHASSI", VVA->VVA_CHASSI , /* cMVMIL0010 */ , cGruVei )	
Else
	VVR->(dbSetOrder(2))
	VVR->(MsSeek(xFilial("VVR")+VVA->VVA_CODMAR+VVA->VVA_GRUMOD))
	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1")+VVR->VVR_PROD))
EndIf

If cTitAten == "0" .and. !Empty(VV0->VV0_NUMNFI) // Nro do Titulo eh o Nro da NF
	cNumTit := VV0->VV0_NUMNFI
Else
	cNumTit := "V"+Right(VV9->VV9_NUMATE,TamSx3("E1_NUM")[1]-1) // Nro do Titulo eh " V + Nro do Atendimento "
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ LEASING -> Gerar NF para Cliente: Banco ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If VV0->VV0_CATVEN == "7" .and. !Empty(VV0->VV0_CLIALI+VV0->VV0_LOJALI)
	SA1->(DbSetOrder(1))
	SA1->(MsSeek(xFilial("SA1")+VV0->VV0_CLIALI+VV0->VV0_LOJALI))
EndIf

If lIntLoja // Veiculo integrado com o LOJA

	// Nao possui orcamento gerado 
	// Verifica se existe algum titulo a vista para ser enviado ao LOJA 
	If Empty(VV0->VV0_PESQLJ) .and. cFaseAtu == "L"
	
		lEntrada := .f.
		
		// Possui TAC e nao esta no financiamento 
		If VV0->VV0_VALTAC > 0 .and. VV0->VV0_TACFIN <> "1"
			lEntrada := .t.
		EndIf
		//
	
		If !lEntrada
			// Procura titulos de Entradas A VISTA
			cQuery := "SELECT COUNT(*) "
			cQuery += "  FROM " + RetSQLName("VS9") + " VS9 " 
			cQuery += "  JOIN " + RetSQLName("VSA") + " VSA ON VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG=VS9.VS9_TIPPAG AND VSA.VSA_TIPO='5' AND VSA.D_E_L_E_T_=' '"
			cQuery += " WHERE VS9.VS9_FILIAL = '" + xFilial("VS9") + "' "
			cQuery += "   AND VS9.VS9_NUMIDE = '" + PadR(VV9->VV9_NUMATE,TamSX3("VS9_NUMIDE")[1]," ") + "'"
			cQuery += "   AND VS9.VS9_TIPOPE = 'V'"
			If lVS9_PARCVD // Controla Parcela que vai para o Venda Direta
				cQuery += " AND VS9.VS9_PARCVD = '1'" // Titulos de Entrada que vao para o Venda Direta
			Else
				cQuery += " AND VS9.VS9_DATPAG <= '" + DtoS(dDataBase) + "'" // Titulos a Vista que vao para o Venda Direta ( tratamento antigo )
			EndIf
			cQuery += "   AND VS9.D_E_L_E_T_ = ' '"
			lEntrada := (FM_SQL(cQuery) > 0)
			//
		EndIf
		
		If !lEntrada
			// Procura venda agregada que sera paga no caixa 
			cQuery := "SELECT COUNT(*)"
			cQuery +=  " FROM " + RetSQLName("VZ7") + " VZ7 "
			cQuery += " WHERE VZ7.VZ7_FILIAL='" + xFilial("VZ7") + "'"
			cQuery +=   " AND VZ7.VZ7_NUMTRA='" + VV9->VV9_NUMATE + "'"
			cQuery +=   " AND VZ7.VZ7_AGRVLR='3'" // Venda Agregada
			cQuery +=   " AND VZ7.VZ7_COMPAG='1'" // Caixa
			cQuery +=   " AND VZ7.D_E_L_E_T_=' '"
			lEntrada := (FM_SQL(cQuery) > 0)
			//
		EndIf

		If ExistBlock("VXI02ALJ")
			If !ExecBlock("VXI02ALJ",.f.,.f.,{ VV9->VV9_NUMATE }) // Ponto de Entrada antes de geracao do Loja - utilizado para validacao
				DisarmTransaction()
				RollbackSxe()
				Return .f.
			EndIf
		EndIf

	EndIf
	
	// Se nao tiver orcamento do loja e a estiver finalizando, 
	// entao deve gerar pedido e todas os titulos 
	If Empty(VV0->VV0_PESQLJ) .and. cFaseAtu == "F"
		cChamada := "1/2"  // Titulos a serem gerados ( 1 = SE1 para cliente igual ao VV9_CODCLI / 2 = SE1/SE2 para cliente diferente do VV9_CODCLI )
		lPedido  := .t.
		lOrcLoja := .f.
	// Se nao tiver orcamento do loja e a estiver liberando, 
	// entao deve gerar orcamento do loja e titulos de entrada 
	ElseIf Empty(VV0->VV0_PESQLJ) .and. cFaseAtu == "L"
		If lEntrada
			cChamada := "1" // Titulos a serem gerados ( 1 = SE1 para cliente igual ao VV9->VV9_CODCLI+VV9->VV9_LOJA )
			lOrcLoja := .t.
			lPedido  := .f.
		// Se nao tem entrada, nao gera PEDIDO/NF
		Else
			lPedido  := .f.
			lOrcLoja := .f.
		EndIf
	Else
		lPedido := .f.
		cChamada := "2" // Titulos a serem gerados ( 2 = SE1 para cliente diferente de VV9->VV9_CODCLI+VV9->VV9_LOJA )
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ GERACAO DO PEDIDO ( SC5 / SC6 )                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lPedido .or. lOrcLoja
	
	IncProc(STR0006) // Gerando Pedido

	If lPedido

		If cTitAten == "0" // Gera titulo na finalizacao
			If lCPagPad .or. (lVV0FPGPAD .and. VV0->VV0_FPGPAD == "1") // utiliza condicao padrao para faturamento 
				cAuxCondPag := VV0->VV0_FORPAG
			Else
				cAuxCondPag := VXI002CondVei(VV0->VV0_FORPAG)
			EndIf
		Else
			cAuxCondPag := VXI002CondVei(VV0->VV0_FORPAG)
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ CABECALHO do Pedido de Venda ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cNumPed := CriaVar("C5_NUM")
		aAdd(aCabPV,{"C5_NUM"    ,cNumPed			,Nil})				// Numero do pedido
		aAdd(aCabPV,{"C5_TIPO"   ,"N"           	,Nil}) 				// Tipo de pedido
		aAdd(aCabPV,{"C5_CLIENTE",SA1->A1_COD  		,Nil})				// Codigo do cliente
		aAdd(aCabPV,{"C5_LOJACLI",SA1->A1_LOJA 		,Nil})				// Loja do cliente
		aAdd(aCabPV,{"C5_TABELA" ,space(TamSX3("C5_TABELA")[1]),Nil})	// Tabela de Preco
		aAdd(aCabPV,{"C5_CONDPAG",cAuxCondPag		,Nil}) 				// Codigo da condicao de pagamento
		aAdd(aCabPV,{"C5_VEND1"  ,VV0->VV0_CODVEN	,Nil}) 				// Codigo do vendedor
		aAdd(aCabPV,{"C5_EMISSAO",dDataBase     	,Nil})				// Data de emissao
		aAdd(aCabPV,{"C5_TRANSP" ,VV0->VV0_CODTRA	,Nil})				// Transportadora
		aAdd(aCabPV,{"C5_DESC1"  ,0             	,Nil}) 				// Percentual de Desconto
		aAdd(aCabPV,{"C5_BANCO"  ,VV0->VV0_CODBCO	,Nil})				// Banco
		aAdd(aCabPV,{"C5_TIPLIB" ,"2"           	,Nil})				// Liberacao por Pedido de Venda
		aAdd(aCabPV,{"C5_MOEDA"  ,1             	,Nil})				// Moeda
		aAdd(aCabPV,{"C5_LIBEROK","S"           	,Nil})				// Liberacao Total
		aAdd(aCabPV,{"C5_COMIS1" ,SA3->A3_COMIS 	,Nil}) 				// Percentual de Comissao
		aAdd(aCabPV,{"C5_DESPESA",VV0->VV0_DESACE	,Nil})				// Despesa Acessorio
		If !Empty(VV0->VV0_TPFRET)
			aAdd(aCabPV,{"C5_TPFRETE",Alltrim(VV0->VV0_TPFRET),NIL})	// Tipo do Frete
		EndIf
		aAdd(aCabPV,{"C5_FRETE"  ,VV0->VV0_VALFRE 	,Nil})				// Valor Frete
		If VV0->(FieldPos("VV0_PESOL")) > 0 .and. VV0->VV0_PESOL > 0
			aAdd(aCabPV,{"C5_PESOL",VV0->VV0_PESOL,Nil})				// Peso Liquido
		EndIf
		If VV0->(FieldPos("VV0_PBRUTO")) > 0 .and. VV0->VV0_PBRUTO > 0
			aAdd(aCabPV,{"C5_PBRUTO",VV0->VV0_PBRUTO,Nil})				// Peso Bruto
		EndIf
		If VV0->(FieldPos("VV0_VOLUME")) > 0 .and. VV0->VV0_VOLUME > 0
			aAdd(aCabPV,{"C5_VOLUME1",VV0->VV0_VOLUME,Nil})			// Volume
		EndIf
		If VV0->(FieldPos("VV0_ESPECI")) > 0 .and. !Empty(VV0->VV0_ESPECI)
			aAdd(aCabPV,{"C5_ESPECI1",VV0->VV0_ESPECI,Nil})			// Especie
		EndIf
		If VV0->(FieldPos("VV0_VEICUL")) > 0 .and. !Empty(VV0->VV0_VEICUL)
			aAdd(aCabPV,{"C5_VEICULO",VV0->VV0_VEICUL,Nil})			// Veiculo
		EndIf		
		If VV0->(FieldPos("VV0_SEGURO")) > 0 .and. VV0->VV0_SEGURO > 0
			aAdd(aCabPV,{"C5_SEGURO",VV0->VV0_SEGURO,Nil})				// Seguro
		EndIf
		If VV0->(FieldPos("VV0_TIPOCL")) > 0 .and. !Empty(VV0->VV0_TIPOCL) 
			aAdd(aCabPV,{"C5_TIPOCLI",VV0->VV0_TIPOCL ,Nil})			// Tipo de Cliente
		Else
			aAdd(aCabPV,{"C5_TIPOCLI",SA1->A1_TIPO    ,Nil})			// Tipo de Cliente
		EndIf
		If SC5->(FieldPos("C5_INDPRES")) > 0 .and. ( VV0->(FieldPos("VV0_INDPRE")) > 0 .and. !Empty(VV0->VV0_INDPRE) )
			aAdd(aCabPV,{"C5_INDPRES",VV0->VV0_INDPRE ,Nil})			// Presenca do Comprador
		EndIf
		If VV0->(FieldPos("VV0_MENNOT")) > 0 .and. !Empty(VV0->VV0_MENNOT)
			aAdd(aCabPV,{"C5_MENNOTA",VV0->VV0_MENNOT ,Nil})			// Mensagem da NF
		EndIf
		If VV0->(FieldPos("VV0_MENPAD")) > 0 .and. !Empty(VV0->VV0_MENPAD)
			aAdd(aCabPV,{"C5_MENPAD" ,VV0->VV0_MENPAD ,Nil})			// Mensagem Padrao NF
		EndIf                
		If VV0->(FieldPos("VV0_CLIENT")) > 0 .and. !Empty(VV0->VV0_CLIENT)
			aAdd(aCabPV,{"C5_CLIENT" ,VV0->VV0_CLIENT ,Nil})			// Cliente Entrega
		EndIf                
		If VV0->(FieldPos("VV0_LOJENT")) > 0 .and. !Empty(VV0->VV0_LOJENT)
			aAdd(aCabPV,{"C5_LOJAENT" ,VV0->VV0_LOJENT ,Nil})			// Loja do cliente de entraga
		EndIf                
		If VV0->(FieldPos("VV0_CLIRET")) > 0 .and. !Empty(VV0->VV0_CLIRET)
			aAdd(aCabPV,{"C5_CLIRET" ,VV0->VV0_CLIRET ,Nil})			// Cliente de Retirada
		EndIf                
		If VV0->(FieldPos("VV0_LOJRET")) > 0 .and. !Empty(VV0->VV0_LOJRET)
			aAdd(aCabPV,{"C5_LOJARET" ,VV0->VV0_LOJRET ,Nil})			// Loja do cliente de Retirada			
		EndIf                
		If SC5->(FieldPos("C5_CODA1U")) > 0 .and. ( VV0->(FieldPos("VV0_CODA1U")) > 0 .and. !Empty(VV0->VV0_CODA1U) )
			aAdd(aCabPV,{"C5_CODA1U",VV0->VV0_CODA1U ,Nil})
		EndIf
		If l1DUPNATAlt
			cNatTit := cNatureza
			If Empty(cNatTit)
				cNatTit := VXI02NAT("5",cNatureza) // Natureza de 5=Entradas
			EndIf
			aAdd(aCabPV,{"C5_NATUREZ" , cNatTit , Nil } ) // Natureza no Pedido
		EndIf
	EndIf
		
	cItemPed := "00"
	
	nQtdVeicu  := FM_SQL("SELECT COUNT(*) FROM " + RetSQLName("VVA") + " WHERE VVA_FILIAL = '" + xFilial("VVA") + "' AND VVA_NUMTRA = '" + VV0->VV0_NUMTRA + "' AND D_E_L_E_T_ = ' '")
	nTotValVda := FM_SQL("SELECT SUM(VVA_VALVDA) FROM " + RetSQLName("VVA") + " WHERE VVA_FILIAL = '" + xFilial("VVA") + "' AND VVA_NUMTRA = '" + VV0->VV0_NUMTRA + "' AND D_E_L_E_T_ = ' '")

	SA1->(DbSetOrder(1))
	SA1->(MsSeek(xFilial("SA1")+VV9->VV9_CODCLI+VV9->VV9_LOJA))

	VVA->(dbSetOrder(1))
	VVA->(MsSeek( xFilial("VVA") + VV0->VV0_NUMTRA ))
	While !VVA->(Eof()) .and. VVA->VVA_FILIAL == xFilial("VVA") .and. VVA->VVA_NUMTRA == VV0->VV0_NUMTRA

		If !Empty(VVA->VVA_CHASSI)
			FGX_VV1SB1("CHASSI", VVA->VVA_CHASSI , /* cMVMIL0010 */ , cGruVei )
		Else
			VVR->(dbSetOrder(2))
			VVR->(MsSeek(xFilial("VVR")+VVA->VVA_CODMAR+VVA->VVA_GRUMOD))
			SB1->(dbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1")+VVR->VVR_PROD))
		EndIf
			
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Almoxarifado de movimentacao do veiculo ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cLocVei := VV1->VV1_LOCPAD
		If Empty(VV1->VV1_LOCPAD)
			cLocVei := GETMV("MV_LOCVEIN") //Novo
			If VV1->VV1_ESTVEI == "1"
				cLocVei := GETMV("MV_LOCVEIU") //Usado
			EndIf
			If VV1->VV1_SITVEI == "4" //Consignado
				cLocVei := GETMV("MV_LOCVEIC")
			EndIf
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Levanta o Valor que sera enviado ao SC6 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nCntVeicu++
		nVlrSC6 := 0
		// Atendimento possui somente 1 veiculo 
		If nQtdVeicu == 1
			// Se o valor do financiamento for maior do que o valor do veiculo
			// a nota fiscal deve sair com o valor do financiamento
			If VV0->VV0_VALFIN > VVA->VVA_VALVDA
				nVlrSC6 := VV0->VV0_VALFIN + IIf(MaFisFound('NF'),MAFISRET(,"NF_DESCZF"),0)+VV0->VV0_VALDES // Valor do Financiamento
			Else
				nVlConsor := FM_SQL("SELECT SUM(VS9_VALPAG) VALPAG FROM "+RetSQLName("VS9")+" VS9 WHERE VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_NUMIDE='"+VV0->VV0_NUMTRA+"' AND VS9.VS9_TIPOPE='V' AND "+;
									"VS9.VS9_TIPPAG IN ( SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='3' AND VSA.D_E_L_E_T_=' ') AND VS9.VS9_REFPAG='0' AND VS9.D_E_L_E_T_=' '")
				// Se o valor do consorcio NAO QUITADO for maior do que o valor do veiculo
				// a nota fiscal deve sair com o valor do consorcio
				If nVlConsor > VVA->VVA_VALVDA
					nVlrSC6 :=  nVlConsor + IIf(MaFisFound('NF'),MAFISRET(,"NF_DESCZF"),0)+VV0->VV0_VALDES // Valor do Consorcio
				Else
					nVlrSC6 := VVA->VVA_VALVDA + IIf(MaFisFound('NF'),MAFISRET(,"NF_DESCZF"),0)+VV0->VV0_VALDES // Valor do Veiculo
				EndIf
			EndIf
		Else
			// Se o valor do financiamento for maior do que o valor do veiculo
			// a nota fiscal deve sair com o valor do financiamento
			If VV0->VV0_VALFIN > nTotValVda
				nVlrSC6 := VV0->VV0_VALFIN + IIf(MaFisFound('NF'),MAFISRET(,"NF_DESCZF"),0) // Valor do Financiamento
				nVlrSC6 := Int(nVlrSC6 * (VVA->VVA_VALVDA / nTotValVda))
				nSomValVda += nVlrSC6
				If nCntVeicu == nQtdVeicu
					nVlrSC6 += (VV0->VV0_VALFIN - nSomValVda)
				EndIf
			Else
				nVlConsor := FM_SQL("SELECT SUM(VS9_VALPAG) VALPAG FROM "+RetSQLName("VS9")+" VS9 WHERE VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_NUMIDE='"+VV0->VV0_NUMTRA+"' AND VS9.VS9_TIPOPE='V' AND "+;
									"VS9.VS9_TIPPAG IN ( SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='3' AND VSA.D_E_L_E_T_=' ') AND VS9.VS9_REFPAG='0' AND VS9.D_E_L_E_T_=' '")
				// Se o valor do consorcio NAO QUITADO for maior do que o valor do veiculo
				// a nota fiscal deve sair com o valor do consorcio
				If nVlConsor > nTotValVda
					nVlrSC6 := nVlConsor + IIf(MaFisFound('NF'),MAFISRET(,"NF_DESCZF"),0)+VV0->VV0_VALDES // Valor do Consorcio
					nVlrSC6 := Int(nVlrSC6 * (VVA->VVA_VALVDA / nTotValVda))
					nSomValVda += nVlrSC6
					If nCntVeicu == nQtdVeicu
						nVlrSC6 += (nVlConsor - nSomValVda)
					EndIf
				Else
					If nCntVeicu == 1
						nVlrSC6 := VVA->VVA_VALVDA + IIf(MaFisFound('NF'),MAFISRET(,"NF_DESCZF"),0) // Valor do Veiculo
					Else
						nVlrSC6 := VVA->VVA_VALVDA // Valor do Veiculo
					EndIf
				EndIf
			EndIf
		EndIf
		aadd(aValVVA,{VVA->(RecNo()),nVlrSC6,""})
		
		If lPedido
		
			nRecSB1 := SB1->(RecNo())
			If GetNewPar("MV_MIL0010","0") == "1" // Agrupa Itens por Modelo? ( 1-Sim / 0-Nao )
				If !FGX_VV2SB1(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)
					SB1->(DbGoTo(nRecSB1)) // Volta SB1 do veiculo
				EndIf
			EndIf
			
			SF4->(DbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+VVA->VVA_CODTES))
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ ITEM do Pedido de Venda ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cItemPed := Soma1( cItemPed , 2 )
			aAdd(aIteTPv,{"C6_NUM"    ,cNumPed			,Nil}) // Numero do Pedido
			aAdd(aIteTPv,{"C6_ITEM"   ,cItemPed			,Nil}) // Numero do Item no Pedido
			aAdd(aIteTPv,{"C6_PRODUTO",SB1->B1_COD		,Nil}) // Codigo do Produto
			aAdd(aIteTPv,{"C6_QTDVEN" ,1				,Nil}) // Quantidade Vendida
			aAdd(aIteTPv,{"C6_PRUNIT" , nVlrSC6			,Nil}) // Preco Unitario Liquido *
			aAdd(aIteTPv,{"C6_PRCVEN" , nVlrSC6			,Nil}) // Preco Unitario Liquido *
			aAdd(aIteTPv,{"C6_VALOR"  , nVlrSC6			,Nil}) // Valor Total do Item *
			aAdd(aIteTPv,{"C6_CLI"    ,SA1->A1_COD		,Nil}) // Cliente
			aAdd(aIteTPv,{"C6_LOJA"   ,SA1->A1_LOJA		,Nil}) // Loja do Cliente
			aAdd(aIteTPv,{"C6_ENTREG" ,dDataBase		,Nil}) // Data da Entrega
			aAdd(aIteTPv,{"C6_UM"     ,"UN"			   	,Nil}) // Unidade de Medida Primar.
			aAdd(aIteTPv,{"C6_TES"    ,VVA->VVA_CODTES	,Nil}) // Tipo de Entrada/Saida do Item
			aAdd(aIteTPv,{"C6_LOCAL"  ,cLocVei			,Nil}) // Almoxarifado
			aAdd(aIteTPv,{"C6_CLASFIS",SB1->B1_ORIGEM+SF4->F4_SITTRIB ,Nil}) // Classificacao Fiscal			
			aAdd(aIteTPv,{"C6_COMIS1" ,SA3->A3_COMIS	,Nil}) // Comissao Vendedor
			aAdd(aIteTPv,{"C6_DESCRI" ,SB1->B1_DESC		,Nil}) // Descricao do Produto
			If SC6->(FieldPos("C6_CHASSI")) > 0
				aAdd(aIteTPv,{"C6_CHASSI" ,VV1->VV1_CHASSI,Nil}) // Chassi do Veiculo -  Descricao do Produto
			Endif
			If SC6->(FieldPos("C6_CONTA"))>0 .and. VVA->(FieldPos("VVA_CONTA"))>0
				aAdd(aIteTPv,{"C6_CONTA" , VVA->VVA_CONTA , Nil})
			Endif
			If SC6->(FieldPos("C6_CC"))>0 .and. VVA->(FieldPos("VVA_CENCUS"))>0
				aAdd(aIteTPv,{"C6_CC" , VVA->VVA_CENCUS , Nil})
			Endif
			If SC6->(FieldPos("C6_ITEMCTA"))>0 .and. VVA->(FieldPos("VVA_ITEMCT"))>0
				aAdd(aIteTPv,{"C6_ITEMCTA" , VVA->VVA_ITEMCT , Nil})
			Endif
			If SC6->(FieldPos("C6_CLVL"))>0 .and. VVA->(FieldPos("VVA_CLVL"))>0
				aAdd(aIteTPv,{"C6_CLVL" , VVA->VVA_CLVL , Nil})
			Endif
			If SC6->(FieldPos("C6_FCICOD"))>0 .and. (VVA->(FieldPos("VVA_FCICOD"))>0 .and. !Empty(VVA->VVA_FCICOD) )
				aAdd(aIteTPv,{"C6_FCICOD" , VVA->VVA_FCICOD , Nil})
			Endif

			// NT 2021.004 v1.21 - Alecsandre Ferreira
			if SC6->(FieldPos("C6_OBSCONT")) > 0 .AND. (VVA->(FieldPos("VVA_OBSCON")) > 0 .and. !Empty(VVA->VVA_OBSCON) )
				aAdd(aIteTPv, {"C6_OBSCONT", VVA->VVA_OBSCON, Nil})
			endif          

			if SC6->(FieldPos("C6_OBSCCMP")) > 0 .AND. (VVA->(FieldPos("VVA_OBSCCM")) > 0 .and. !Empty(VVA->VVA_OBSCCM) )
				aAdd(aIteTPv, {"C6_OBSCCMP", VVA->VVA_OBSCCM, Nil})
			endif         

			if SC6->(FieldPos("C6_OBSFISC")) > 0 .AND. (VVA->(FieldPos("VVA_OBSFIS")) > 0 .and. !Empty(VVA->VVA_OBSFIS) )
				aAdd(aIteTPv, {"C6_OBSFISC", VVA->VVA_OBSFIS, Nil})
			endif         

			if SC6->(FieldPos("C6_OBSFCMP")) > 0 .AND. (VVA->(FieldPos("VVA_OBSFCP")) > 0 .and. !Empty(VVA->VVA_OBSFCP) )
				aAdd(aIteTPv, {"C6_OBSFCMP", VVA->VVA_OBSFCP, Nil})
			endif
			// NT 2021.004 v1.21        

			// Ticket: 2353361
			// ISSUE: MMIL-2867
			// O TES estแ sendo enviado novamente pois na base do cliente ocorria uma falha. O conte๚do do TES
			//   na aCols (MATA410) ficava com conte๚do VAZIO.
			// O problema nใo foi reproduzido em base teste, mas verificamos que passando o TES novamente
			//   a falha nใo ocorria novamente.
			// A mensagem de HELP disparada era A410VZ.
			aAdd(aIteTPv,{"C6_TES"    ,VVA->VVA_CODTES	,Nil}) // Tipo de Entrada/Saida do Item

			If VV0->VV0_TIPFAT == "1" // Usado

				aUltMov := FM_VEIMOVS( VV1->VV1_CHASSI , "E"  )			
				For ni := 1 to Len(aUltMov)                     
					If aUltMov[ni,5] == "0" // Entrada por Compra
						Dbselectarea("VVF")
						DbSetOrder(1)
						If DbSeek(aUltMov[ni,2]+aUltMov[ni,3])
							Dbselectarea("SD1")
							DbSetOrder(1)  
							If DbSeek(VVF->VVF_FILIAL+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD)
								aAdd(aIteTPv,{"C6_BASVEIC" ,SD1->D1_TOTAL,Nil})
								aAdd(aIteTPv,{"C6_NFORI" ,SD1->D1_DOC,Nil})
								aAdd(aIteTPv,{"C6_SERIORI" ,SD1->D1_SERIE,Nil})
								aAdd(aIteTPv,{"C6_ITEMORI" ,SD1->D1_ITEM,Nil})
							Endif
						EndIf
						Exit
					Endif
				Next
			Endif
			
			If ExistBlock("PEDVEI011")
				ExecBlock("PEDVEI011",.f.,.f.)
			EndIf
			
			aAdd(aItePv,aClone(aIteTPv))
			
			SB1->(DbGoTo(nRecSB1)) // Volta SB1 do veiculo
			aValVVA[len(aValVVA),3] := cNumPed + cItemPed // Salvar Nro/Item do Pedido para gravar o CHASSI no SD2
		
		EndIf
		
		VVA->(dbSkip())
	EndDo
	VVA->(DbSetOrder(1))
	VVA->(MsSeek( xFilial("VVA") + VV0->VV0_NUMTRA ))
	
	If lPedido

		//		cInteg := ;
		//			"aCabPV " + CHR(13) + CHR(10) + ;
		//			VarInfo("aCabPV",aCabPV,,.f.) + ;
		//			" " + CHR(13) + CHR(10) + ;
		//			"aItePv" + CHR(13) + CHR(10) + ;
		//			" " + CHR(13) + CHR(10) + ;
		//			varInfo("aItePv", aItePv,,.f.)
		//
		//		DEFINE MSDIALOG oDlgArrayInt TITLE "Array Integracao" FROM 02,04 TO 14,56 OF oMainWnd
		//DEFINE SBUTTON FROM 076,137 TYPE 1 ACTION oDlgArrayInt:End() ENABLE OF oDlgArrayInt
		//@ 01,011 GET oObserv VAR cInteg OF oDlgArrayInt MEMO SIZE 182,67 PIXEL
		//ACTIVATE MSDIALOG oDlgArrayInt CENTER
		//
		//Alert("Chamando CTB105MVC")
		CTB105MVC(.T.)

		lMsErroAuto := .f.
		MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItePv,3) //Faz Liberacao do Pedido se LiberOk = "S" e QtdLib = QtdEmp
		CTB105MVC(.f.)

		If lMsErroauto
			DisarmTransaction()
			RollbackSxe()
			MostraErro()
			Return .f.
		EndIf
	
		ConfirmSx8()
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Atualiza Atendimento ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("VV0")
		RecLock("VV0",.f.)
		VV0->VV0_NUMPED := cNumPed
		VV0->VV0_DATMOV := dDataBase
		MsUnLock()

	EndIf

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Reposiciona no SA1, pode ter sido desposicionado quando LEASING ( Cliente: Banco ) ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SA1->(DbGoTo(nRecSA1))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ GERACAO DA NF ( SF2 / SD2 )                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lNF
	
	IncProc(STR0007) // Gerando Nota Fiscal
	
	If lIntLoja .and. !Empty(VV0->VV0_PESQLJ)

		SL1->(DbSetOrder(1))
		If SL1->(MsSeek( xFilial("SL1") + VV0->VV0_PESQLJ ))
			cNumTit  := SL1->L1_DOCPED // Numero dos Titulos ja gerados pelo Loja
			cPreTit  := SL1->L1_SERPED // Serie/Prefixo dos Titulos ja gerados pelo Loja
			cNumPed  := FM_SQL("SELECT SL1.L1_PEDRES FROM "+RetSQLName("SL1")+" SL1 WHERE SL1.L1_FILIAL='"+xFilial("SL1")+"' AND SL1.L1_ORCRES='"+SL1->L1_NUM+"' AND SL1.D_E_L_E_T_=' '") // Pedido do Loja ( SC5/SC6/SC9 ja existentes )
			DbSelectArea("SC5")
			DbSetOrder(1)
			If MsSeek(xFilial("SC5")+cNumPed)
				RecLock("SC5",.f.)
					SC5->C5_CONDPAG := VV0->VV0_FORPAG		// Codigo da condicao de pagamento
				MsUnLock()
			EndIf
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Atualiza Nro.Pedido ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			DbSelectArea("VV0")
			RecLock("VV0",.f.)
			VV0->VV0_NUMPED := cNumPed
			MsUnLock()
			
		EndIf

	EndIf	

	// Verifica se existe item bloqueado por estoque ou credito 
	// Se tiver, estorna a liberacao...
	cQuery := "SELECT COUNT(*) "
	cQuery +=  " FROM " + RetSQLName("SC9") + " C9"
	cQuery += " WHERE C9_FILIAL = '" + xFilial("SC9") + "'" 
	cQuery += " AND C9_PEDIDO = '" + VV0->VV0_NUMPED + "'"
	cQuery +=   " AND ( C9_BLCRED <> ' ' OR C9_BLEST <> ' ' )"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	If FM_SQL(cQuery) <> 0
		// Posiciona tabela de pedido e item do pedido de venda para estornar liberacao 
		SC5->(dbSetOrder(1))
		SC5->(MsSeek(xFilial("SC5") + VV0->VV0_NUMPED))
		SC6->(dbSetOrder(1))
		SC6->(MsSeek(xFilial("SC6") + VV0->VV0_NUMPED + "01"))
		While !eof() .and. xFilial("SC6") + VV0->VV0_NUMPED == SC6->C6_FILIAL + SC6->C6_NUM
			If SC9->(MsSeek(xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM )) .and. ( SC9->C9_BLCRED <> ' ' .or. SC9->C9_BLEST <> ' ' )
				// Estorna liberacao de credito/estoque 
				MaAvalSC6("SC6",4,"SC5")
			Endif
			SC6->(DbSkip())
		Enddo
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ LIBERACAO do Pedido de Venda ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	lCredito := .t.
	lEstoque := .t.
	lLiber   := .t.
	lTransf  := .f.

	SC9->(dbSetOrder(1))
	SC6->(dbSetOrder(1))
	SC6->(MsSeek(xFilial("SC6") + VV0->VV0_NUMPED + "01"))
	While !SC6->(Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == VV0->VV0_NUMPED
		If !SC9->(MsSeek(xFilial("SC9")+VV0->VV0_NUMPED+SC6->C6_ITEM))
			nQtdLib := SC6->C6_QTDVEN
			nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,.F.,lLiber,lTransf)
		EndIf
		SC6->(dbSkip())
	Enddo

	SB1->(dbSetOrder(1))
	SC5->(dbSetOrder(1))
	SC6->(dbSetOrder(1))
	SB5->(dbSetOrder(1))
	SB2->(dbSetOrder(1))
	SF4->(dbSetOrder(1))
	SE4->(dbSetOrder(1))
	
	SC9->(MsSeek(xFilial("SC9") + VV0->VV0_NUMPED + "01" ))
	While !SC9->(Eof()) .and. xFilial("SC9") == SC9->C9_FILIAL .and. SC9->C9_PEDIDO == VV0->VV0_NUMPED
		If lIntLoja .or. ( Empty(SC9->C9_BLCRED) .and. Empty(SC9->C9_BLEST) )
		
			SC5->(MsSeek( xFilial("SC5") + SC9->C9_PEDIDO ))
			SC6->(MsSeek( xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM ))
			SB1->(MsSeek( xFilial("SB1") + SC9->C9_PRODUTO ))
			SB2->(MsSeek( xFilial("SB2") + SB1->B1_COD ))
			SB5->(MsSeek( xFilial("SB5") + SB1->B1_COD ))
			SF4->(MsSeek( xFilial("SF4") + SC6->C6_TES ))
			SE4->(MsSeek( xFilial("SE4") + SC5->C5_CONDPAG ))
			
			aAdd(aPvlNfs,{SC9->C9_PEDIDO,;
						  SC9->C9_ITEM,;
						  SC9->C9_SEQUEN,;
						  SC9->C9_QTDLIB,;
						  SC9->C9_PRCVEN,;
						  SC9->C9_PRODUTO,;
						  SF4->F4_ISS=="S",;
						  SC9->(RecNo()),;
						  SC5->(RecNo()),;
						  SC6->(RecNo()),;
						  SE4->(RecNo()),;
						  SB1->(RecNo()),;
						  SB2->(RecNo()),;
						  SF4->(RecNo())})
			nIteLib++
		Else
			If !Empty(SC9->C9_BLCRED)
				cMsgSC9 += AllTrim(RetTitle("C9_PRODUTO"))+": "+Alltrim(SC9->C9_PRODUTO)+" - "+AllTrim(RetTitle("C9_BLCRED"))+": "+SC9->C9_BLCRED+CHR(13)+CHR(10)
			EndIf
			If !Empty(SC9->C9_BLEST)
				cMsgSC9 += AllTrim(RetTitle("C9_PRODUTO"))+": "+Alltrim(SC9->C9_PRODUTO)+" - "+AllTrim(RetTitle("C9_BLEST"))+": "+SC9->C9_BLEST+CHR(13)+CHR(10)
			EndIf
		EndIf
		SC9->(dbSkip())
	Enddo
	
	If !Empty(cMsgSC9) // Problema!!!
		MsgStop(STR0008+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsgSC9,STR0002) // Pedido sem itens liberados! / Atencao
		DisarmTransaction()
		RollbackSxe()
		Return .f.
	EndIf

	If len(aPvlNfs) == 0 .and. !FGX_SC5BLQ(VV0->VV0_NUMPED,.t.) // Verifica SC5 bloqueado
		DisarmTransaction()
		RollbackSxe()
		Return .f.
	EndIf
	
	// Limpar NATUREZA apos integracoes //
//	If l1DUPNATAlt
//		SC5->(dbSetOrder(1))
//		If SC5->(MsSeek(xFilial("SC5") + VV0->VV0_NUMPED))
//			DbSelectArea("SC5")
//			RecLock("SC5",.f.)
//				SC5->C5_NATUREZ := ""
//			MsUnLock()
//		EndIf
//    EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Gera F2/D2, Atualiza Estoque, Financeiro, Contabilidade             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nIteLib > 0
		////////////////////////////////////////////////////////////////////
		// Salvar o RecNo do VV9/VV0/VV1 para voltar apos funcao MaPvlNfs //
		////////////////////////////////////////////////////////////////////
		nRecVV9 := VV9->(RecNo())
		nRecVV0 := VV0->(RecNo())
		nRecVV1 := VV1->(RecNo())
		////////////////////////////////////////////////////////////////////
		If nVerParFat == 1 // NAO mostrar os Parametros do Faturamento no momento da geracao da NF
			PERGUNTE("MT460A",.f.)
		Else // nVerParFat == 2 // Mostrar os Parametros do Faturamento no momento da geracao da NF
			While .t.
				If PERGUNTE("MT460A",.t.)
					Exit
				EndIf
			EndDo
		EndIf
		lMsErroAuto := .f.
		nBkpModulo := nModulo
		cBkpModulo := cModulo
		cModulo := "FAT" // Controle de geracao de Guia / Titulo de ICMSST esta verificando o Modulo conectado
		nModulo := 5
		cNota := MaPvlNfs(aPvlNfs,cSerie, (mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1), .F., 0, 0, .T., .F.)
		cModulo := cBkpModulo
		nModulo := nBkpModulo
		If lMsErroauto
			DisarmTransaction()
			RollbackSxe()
			MostraErro()
			Return .f.
		EndIf
		ConfirmSx8()
		// ------------------------------------------------------ // 
		// Rubens - 13/03/2019 - CAOA
		// Em alguns casos, a SF2 estava voltando desposicionada
		// ------------------------------------------------------ // 
		cNota := PadR(cNota,SF2->(TamSx3("F2_DOC")[1]))
		If SF2->F2_FILIAL <> FWxFilial("SF2") .or. SF2->F2_DOC <> cNota .or. SF2->F2_SERIE <> cSerie
			Conout(" ")
			Conout("    ###    ######## ######## ##    ##  ######     ###     #######  ")
			Conout("   ## ##      ##    ##       ###   ## ##    ##   ## ##   ##     ## ")
			Conout("  ##   ##     ##    ##       ####  ## ##        ##   ##  ##     ## ")
			Conout(" ##     ##    ##    ######   ## ## ## ##       ##     ## ##     ## ")
			Conout(" #########    ##    ##       ##  #### ##       ######### ##     ## ")
			Conout(" ##     ##    ##    ##       ##   ### ##    ## ##     ## ##     ## ")
			Conout(" ##     ##    ##    ######## ##    ##  ######  ##     ##  #######  ")
			Conout(" ")
			Conout(" ATENCAO - Tabela de Nota Fiscal estava desposicionada....")
			Conout("           Reposicionando tabela SF2 no registro correto ....")
			Conout(" ")
			SF2->(dbSetOrder(1))
			If ! SF2->(dbSeek(xFilial("SF2") + cNota + cSerie))
				DisarmTransaction()
				RollbackSxe()
				FMX_HELP("VXI002ERR01","Nota fiscal gerada nใo encontrada." + CRLF + CRLF + cNota + "-" + cSerie)
				Return .f.
			EndIf
		EndIf
		// ------------------------------------------------------ // 

		////////////////////////////////////////////////////////////////////
		// Voltar o RecNo do VV9/VV0/VV1 para voltar apos funcao MaPvlNfs //
		////////////////////////////////////////////////////////////////////
		If nRecVV9 > 0
			VV9->(DbGoTo(nRecVV9))
		EndIf
		If nRecVV0 > 0
			VV0->(DbGoTo(nRecVV0))
		EndIf
		If nRecVV1 > 0
			VV1->(DbGoTo(nRecVV1))
		EndIf
		////////////////////////////////////////////////////////////////////
	EndIf
	
	cPrefixo := &(GetNewPar("MV_1DUPREF","cSerie"))

 	If !lIntLoja .or. Empty(VV0->VV0_PESQLJ)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Cria Titulos com o Nro NF qdo geracao de Titulos for na Finalizacao ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If cTitAten == "0"
			cNumTit := SF2->F2_DOC
		EndIf
		If Empty(cPreTit)
			cPreTit := cPrefixo
		EndIf
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza Nota Fiscal         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If VXX002DUPL(2) // Verifica se os TES utilizados geram ou nao duplicatas  ( .t. = Gerar Duplicatas )
		dbSelectArea("SF2")
		RecLock("SF2",.f.)
		SF2->F2_DUPL    := cNumTit
		SF2->F2_PREFORI := cPrefVEI
		SF2->F2_PREFIXO := cPreTit
		SF2->F2_VALFAT  := SF2->F2_VALBRUT
		MsUnlock()
	Else
		dbSelectArea("SF2")
		RecLock("SF2",.f.)
		SF2->F2_PREFORI := cPrefVEI
		SF2->F2_PREFIXO := cPreTit
		SF2->F2_VALFAT  := SF2->F2_VALBRUT
		MsUnlock()
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza Atendimento         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectarea("VV9")
	RecLock("VV9",.f.)
	VV9->VV9_STATUS := "F"
	VV9->VV9_MOTIVO := ""
	VV9->VV9_DATCAN := ctod("")
	MsUnlock()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza ITEM do Atendimento ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectarea("VV0")
	RecLock("VV0",.f.)
	VV0->VV0_AUTFAT := "1"
	VV0->VV0_NUMNFI := cNota
	VV0->VV0_SERNFI := cSerie
	if FieldPos("VV0_SDOC") > 0
		VV0->VV0_SDOC := FGX_UFSNF(cSerie)
	endif
	VV0->VV0_MODVDA := VV1->VV1_ESTVEI
	If VV1->VV1_SITVEI == "4" //Consignado
		VV0->VV0_MODVDA := "4"
	EndIf
	VV0->VV0_STATUS := "F"
	VV0->VV0_DTHEMI := left(Dtoc(dDataBase),6) + right(Dtoc(dDataBase),2) + "/" + Time() // Dia/Mes/Ano(2 posicoes)/Hora:Minuto:Segundo 
	If Empty(VV0->VV0_DATAPR)
		VV0->VV0_DATAPR := dDataBase
		VV0->VV0_USRAPR := __CUSERID
	EndIf
	MsUnlock()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza Veiculos               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	VVA->(dbSetOrder(1))
	VVA->(MsSeek( xFilial("VVA") + VV0->VV0_NUMTRA ))
	While !VVA->(Eof()) .and. VVA->VVA_FILIAL == xFilial("VVA") .and. VVA->VVA_NUMTRA == VV0->VV0_NUMTRA
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Atualiza Chassi no Item da NF     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lSD2_CHASSI
			nPos := aScan(aValVVA,{|x| x[1] == VVA->(RecNo()) })
			If nPos > 0 .and. !Empty(aValVVA[nPos,3])
				DbSelectArea("SD2")
				DbSetOrder(8)
				If MsSeek(xFilial("SD2")+aValVVA[nPos,3])
					RecLock("SD2",.f.)
					SD2->D2_CHASSI := VVA->VVA_CHASSI
					MsUnlock()
				EndIf
				DbSetOrder(1)
			EndIf
		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Atualiza Data de Venda do Veiculo ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectarea("VV1")
		DbSetOrder(1)
		If MsSeek(xFilial("VV1")+VVA->VVA_CHAINT)
			If VV0->VV0_TIPFAT <> "1" // Novo
				RecLock("VV1",.f.)
				VV1->VV1_DATVEN := dDatabase // Primeira Venda
				If lVV1_DTUVEN // Data da Ultima Venda
					VV1->VV1_DTUVEN := dDatabase
				EndIf
				MsUnlock()
				DbSelectArea("VO5")
				DbSetOrder(1)
				If MsSeek(xFilial("VO5")+VV1->VV1_CHAINT)
					RecLock("VO5",.f.)
					VO5->VO5_DATVEN := dDatabase
					MsUnlock()
				EndIf
			Else
				If lVV1_DTUVEN // Data da Ultima Venda
					RecLock("VV1",.f.)
						VV1->VV1_DTUVEN := dDatabase
					MsUnlock()
				EndIf
			EndIf			
			FM_LOCVZL(2,VV1->VV1_CHAINT) // Debita VZL_QTDATU
		EndIf
		VVA->(dbSkip())
	EndDo
	VVA->(DbSetOrder(1))
	VVA->(MsSeek( xFilial("VVA") + VV0->VV0_NUMTRA ))

	If ! lXI002Auto
		FMX_TELAINF( "1" , { { Alltrim(cSerie) , Alltrim(cNota) , STR0009 } } ) // "EMITIDO"
	EndIf

EndIf

If !lIntLoja .or. Empty(VV0->VV0_PESQLJ)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria Titulos com o Nro NF qdo geracao de Titulos for na Finalizacao ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If cTitAten == "0" .and. lNF 
		If !Empty(VV0->VV0_NUMNFI)
			cNumTit := VV0->VV0_NUMNFI
		EndIf
		cPreTit := cPrefixo
	EndIf
EndIf

cPreTit := PadR(cPreTit,TamSx3("E1_PREFIXO")[1]," ")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ GERACAO DOS TITULOS ( SE1 / SE2 )                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lTitulos

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Gravar o Numero do Titulo referente ao Atendimento    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("VV0")
	If !lIntLoja .or. !Empty(VV0->VV0_PESQLJ)
		If VV0->(FieldPos("VV0_NUMTIT")) > 0
			If VXX002DUPL(2) // Verifica se os TES utilizados geram ou nao duplicatas  ( .t. = Gerar Duplicatas )
				DbSelectArea("VV0")
			  	RecLock("VV0",.f.)
				VV0->VV0_NUMTIT := cNumTit
	    		MsUnlock()
	   		EndIf
		EndIf
	EndIf
		
	cSE1CVend := SA3->A3_COD
	nSE1Comis := SA3->A3_COMIS
	If !Empty(VV0->VV0_NUMPED)
		SC5->(DbSetOrder(1))
		SC5->(MsSeek(xFilial("SC5")+VV0->VV0_NUMPED))
		cSE1CVend := SC5->C5_VEND1
		nSE1Comis := SC5->C5_COMIS1
	EndIf
	
	IncProc(STR0012) // Gerando Financeiro

	// So cria titulos quando tiver entrada, do contrario, segue fluxo normal 
	If lIntLoja .and. lEntrada
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Veiculo integrado com o LOJA                          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		lCriaTit := .t.
	EndIf
	
	If lManutenc
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Manutencao da Proposta ( Atendimento de Veiculos )    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		lCriaTit := .t.
		
	Else
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Atualiza Nro da NF / Serie no Contas a Receber ( SE1 )ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cQuery := "SELECT SE1.R_E_C_N_O_ AS RECSE1 "
		cQuery +=  " FROM " + RetSQLName("SE1") + " SE1 "
		cQuery += " WHERE SE1.E1_FILIAL='" + xFilial("SE1") + "'"
		cQuery +=   " AND SE1.E1_NUM='"+cNumTit+"'"
		cQuery +=   " AND SE1.E1_PREFIXO='"+cPreTit+"'"
		cQuery +=   " AND SE1.E1_PREFORI='"+cPrefVEI+"'"
		cQuery +=   " AND SE1.E1_FILORIG='"+xFilial("VV9")+"'" // Filial referente ao Titulo
		cQuery +=   " AND SE1.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
		If !(cSQLAlias)->(Eof())
			If lNF
				While !(cSQLAlias)->(Eof())
					DbSelectArea("SE1")
					DbGoTo((cSQLAlias)->RECSE1)
					RecLock("SE1",.f.)
					SE1->E1_PEDIDO  := VV0->VV0_NUMPED // Pedido
					SE1->E1_NUMNOTA := VV0->VV0_NUMNFI // NF
					SE1->E1_SERIE   := VV0->VV0_SERNFI // Serie
					if FieldPos("E1_SDOC") > 0
						SE1->E1_SDOC := FGX_UFSNF(VV0->VV0_SERNFI)
					endif
					MsUnLock()
					(cSQLAlias)->(dbSkip())
				EndDo
			EndIf
		Else
			lCriaTit := .t.
		EndIf
		(cSQLAlias)->(dbCloseArea())
		
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Criacao dos Titulos CReceber ( SE1 ) e CPagar ( SE2 ) ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lCriaTit
		
		cQuery := "SELECT VS9.VS9_TIPPAG , VS9.VS9_DATPAG , VS9.VS9_VALPAG , VS9.VS9_REFPAG ,"
		cQuery += "       VS9.VS9_SEQUEN , VS9.VS9_NATURE , VS9.R_E_C_N_O_ AS RECVS9 , "
		cQuery += "       VSA.VSA_DESPAG , VSA.VSA_TIPO   , VSA.VSA_CODCLI , VSA.VSA_LOJA "
 		If lIntLoja .and. lVS9_PARCVD // Veiculo integrado com o LOJA - Controla Parcela que vai para o Venda Direta
			cQuery += " , VS9.VS9_PARCVD"
		EndIf
		cQuery += " FROM "+RetSQLName("VS9")+" VS9 "
		cQuery +=        " INNER JOIN "+RetSQLName("VSA")+" VSA ON ( VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG=VS9.VS9_TIPPAG AND VSA.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VS9.VS9_FILIAL='"+xFilial("VS9")+"'"
		cQuery +=  " AND VS9.VS9_NUMIDE='"+VV9->VV9_NUMATE+"'"
		cQuery +=  " AND VS9.VS9_TIPOPE='V'"
		cQuery +=  " AND VS9.VS9_PARCEL=' '"
		cQuery +=  " AND VS9.VS9_VALPAG > 0 "
		cQuery +=  " AND VS9.D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
		While !(cSQLAlias)->( Eof() )
			cCodCli := VV9->VV9_CODCLI
			cLojCli := VV9->VV9_LOJA
			cTipTit := Padr((cSQLAlias)->( VS9_TIPPAG ),nTamE1_TIPO)
			nVlrTit := (cSQLAlias)->( VS9_VALPAG )
			//
			If !Empty( (cSQLAlias)->( VS9_NATURE ) )
				cNatTit := VXI02NAT("X",(cSQLAlias)->( VS9_NATURE )) // X - Chamada da funcao apenas para atribuir conteudo para a Natureza
			Else
				cNatTit := VXI02NAT("X",cNatureza) // X - Chamada da funcao apenas para atribuir conteudo para a Natureza
			EndIf
			//
			dDtVenc := stod((cSQLAlias)->( VS9_DATPAG ))
			dDtEmis := dDataBase
			If dDtVenc < dDtEmis
				dDtEmis := dDtVenc
			EndIf
			If (cSQLAlias)->( VSA_TIPO ) $ "3/4" // 3=Consorcio / 4=Veiculo Usado
				If dDtVenc < dDataBase
					aAdd(aAtualVS9,{(cSQLAlias)->( RECVS9 ),1,dDataBase}) // Atualiza Data de Emissao do Titulo no VS9
					dDtVenc := dDataBase
					dDtEmis := dDataBase
				EndIf
			EndIf
			
			Do Case
				
				
				//////////////////////////////////////////////////////////////////////////
				Case (cSQLAlias)->( VSA_TIPO ) == "1"   //   Financiamento / Leasing    //
				//////////////////////////////////////////////////////////////////////////
					
					cCodCli := (cSQLAlias)->( VSA_CODCLI )
					cLojCli := (cSQLAlias)->( VSA_LOJA )
					SA1->(DbSetOrder(1))
					SA1->(MsSeek(xFilial("SA1")+cCodCli+cLojCli))

					If ("2"$cChamada) // Titulos a serem gerados ( 1 = SE1 para cliente igual ao VV9_CODCLI / 2 = SE1/SE2 para cliente diferente do VV9_CODCLI )
						//////////////////////////////
						// TITULO NORMAL            //
						//////////////////////////////
						If VV0->VV0_VALFIN > 0
							If VV0->VV0_TACSUB == "0" // Nao somar a TAC no subsidio
								nVlrAux := VV0->VV0_VALFIN
							Else//If VV0->VV0_TACSUB == "1" // Somar a TAC no subsidio
								nVlrAux := ( VV0->VV0_VALFIN + VV0->VV0_VALTAC )
							EndIf
							nVlrDec := ( nVlrAux * ( VV0->VV0_SUBFIN / 100 ) )
							nVlrTit := VV0->VV0_VALFIN
							//
							cNatTit := VXI02NAT("1A",cNatureza) // Natureza de 1=Financiamento - A=Titulo Normal
							//
							// Nใo mudar ORDEM das colunas na matriz aParcelE1 pois ela sera enviada ao PE VXI02CR
							aAdd(aParcelE1,{;
								cPreTit,; // "E1_PREFIXO"
								cNumTit,; // "E1_NUM"
								cParcela,; // "E1_PARCELA"
								cTipTit,; // "E1_TIPO"
								cNatTit,; // "E1_NATUREZ"
								cCodCli,; // "E1_CLIENTE"
								cLojCli,; // "E1_LOJA"
								dDtEmis,; // "E1_EMISSAO"
								dDtVenc,; // "E1_VENCTO"
								DataValida(dDtVenc),; // "E1_VENCREA"
								nVlrTit,; // "E1_VALOR"
								cNumBord,; // "E1_NUMBOR"
								dDatBord,; // "E1_DATABOR"
								cCodBco,; // "E1_PORTADO"
								cPrefVEI,; // "E1_PREFORI"
								cSituaca,; // "E1_SITUACA"
								cSE1CVend,; // "E1_VEND1"
								nSE1Comis,; // "E1_COMIS1"
								nVlrTit,; // "E1_BASCOM1"
								VV0->VV0_NUMPED,; // "E1_PEDIDO"
								VV0->VV0_NUMNFI,; // "E1_NUMNOTA"
								VV0->VV0_SERNFI,; // "E1_SERIE"
								cPrograE1,; // "E1_ORIGEM"
								VV0->VV0_CCUSTO,; // "E1_CCC"
								nVlrDec,; // "E1_DECRESC"
								.t.,;
								(cSQLAlias)->( RECVS9 )})
						EndIf
						//////////////////////////////
						// RETORNO DO FINANCIAMENTO //
						//////////////////////////////
						If VV0->VV0_VTXRET > 0
							cTipTit := Padr("RF",nTamE1_TIPO)
							nVlrTit := ( VV0->VV0_VTXRET / ((100-VV0->VV0_PCUSFN)/100) )
							//
							cNatTit := VXI02NAT("1B",cNatureza) // Natureza de 1=Financiamento - B=Titulo Retorno
							//
							// Nใo mudar ORDEM das colunas na matriz aParcelE1 pois ela sera enviada ao PE VXI02CR
							aAdd(aParcelE1,{;
								cPreTit,; // "E1_PREFIXO"
								cNumTit,; // "E1_NUM"
								cParcela,; // "E1_PARCELA"
								cTipTit,; // "E1_TIPO"
								cNatTit,; // "E1_NATUREZ"
								cCodCli,; // "E1_CLIENTE"
								cLojCli,; // "E1_LOJA"
								dDtEmis,; // "E1_EMISSAO"
								dDtVenc,; // "E1_VENCTO"
								DataValida(dDtVenc),; // "E1_VENCREA"
								nVlrTit,; // "E1_VALOR"
								cNumBord,; // "E1_NUMBOR"
								dDatBord,; // "E1_DATABOR"
								cCodBco,; // "E1_PORTADO"
								cPrefVEI,; // "E1_PREFORI"
								cSituaca,; // "E1_SITUACA"
								cSE1CVend,; // "E1_VEND1"
								nSE1Comis,; // "E1_COMIS1"
								nVlrTit,; // "E1_BASCOM1"
								VV0->VV0_NUMPED,; // "E1_PEDIDO"
								VV0->VV0_NUMNFI,; // "E1_NUMNOTA"
								VV0->VV0_SERNFI,; // "E1_SERIE"
								cPrograE1,; // "E1_ORIGEM"
								VV0->VV0_CCUSTO,; // "E1_CCC"
								,; // "E1_DECRESC"
								.f.,;
								(cSQLAlias)->( RECVS9 )})
						EndIf
					EndIf
					
					//////////////////////////////
					// TAC                      //
					//////////////////////////////
					If VV0->VV0_VALTAC > 0
						cTipTit := Padr("TC",nTamE1_TIPO)
						If VV0->VV0_TACFIN == "1" // TAC esta no Financiamento, gerar Titulo CR contra Financeira
							If ("2"$cChamada) // Titulos a serem gerados ( 1 = SE1 para cliente igual ao VV9_CODCLI / 2 = SE1/SE2 para cliente diferente do VV9_CODCLI )
								nVlrTit  := ( VV0->VV0_TACLIQ / ((100-VV0->VV0_PCUSFN)/100) )
								//
								cNatTit := VXI02NAT("1C",SA1->A1_NATUREZ) // Natureza de 1=Financiamento - C=Titulo TAC
								//
								// Nใo mudar ORDEM das colunas na matriz aParcelE1 pois ela sera enviada ao PE VXI02CR
								aAdd(aParcelE1,{;
									cPreTit,; // "E1_PREFIXO"
									cNumTit,; // "E1_NUM"
									cParcela,; // "E1_PARCELA"
									cTipTit,; // "E1_TIPO"
									cNatTit,; // "E1_NATUREZ"
									cCodCli,; // "E1_CLIENTE"
									cLojCli,; // "E1_LOJA"
									dDtEmis,; // "E1_EMISSAO"
									dDtVenc,; // "E1_VENCTO"
									DataValida(dDtVenc),; // "E1_VENCREA"
									nVlrTit,; // "E1_VALOR"
									cNumBord,; // "E1_NUMBOR"
									dDatBord,; // "E1_DATABOR"
									cCodBco,; // "E1_PORTADO"
									cPrefVEI,; // "E1_PREFORI"
									cSituaca,; // "E1_SITUACA"
									cSE1CVend,; // "E1_VEND1"
									nSE1Comis,; // "E1_COMIS1"
									nVlrTit,; // "E1_BASCOM1"
									VV0->VV0_NUMPED,; // "E1_PEDIDO"
									VV0->VV0_NUMNFI,; // "E1_NUMNOTA"
									VV0->VV0_SERNFI,; // "E1_SERIE"
									cPrograE1,; // "E1_ORIGEM"
									VV0->VV0_CCUSTO,; // "E1_CCC"
									,; // "E1_DECRESC"
									.f.,;
									(cSQLAlias)->( RECVS9 )})
							EndIf
						Else // VV0->VV0_TACFIN == "0" // TAC nao esta no Financiamento, gerar Titulo CR contra Cliente e Titulo CP da diferenca a favor da Financeira
							nVlrTit := VV0->VV0_VALTAC
							cCodCli := VV9->VV9_CODCLI
							cLojCli := VV9->VV9_LOJA
							//
							cNatTit := VXI02NAT("1C",cNatureza) // Natureza de 1=Financiamento - C=Titulo TAC
							//
							If ("1"$cChamada) // Titulos a serem gerados ( 1 = SE1 para cliente igual ao VV9_CODCLI / 2 = SE1/SE2 para cliente diferente do VV9_CODCLI )
								// Nใo mudar ORDEM das colunas na matriz aParcelE1 pois ela sera enviada ao PE VXI02CR
								aAdd(aParcelE1,{;
									cPreTit,; // "E1_PREFIXO"
									cNumTit,; // "E1_NUM"
									cParcela,; // "E1_PARCELA"
									cTipTit,; // "E1_TIPO"
									cNatTit,; // "E1_NATUREZ"
									cCodCli,; // "E1_CLIENTE"
									cLojCli,; // "E1_LOJA"
									dDtEmis,; // "E1_EMISSAO"
									dDtVenc,; // "E1_VENCTO"
									DataValida(dDtVenc),; // "E1_VENCREA"
									nVlrTit,; // "E1_VALOR"
									cNumBord,; // "E1_NUMBOR"
									dDatBord,; // "E1_DATABOR"
									cCodBco,; // "E1_PORTADO"
									cPrefVEI,; // "E1_PREFORI"
									cSituaca,; // "E1_SITUACA"
									cSE1CVend,; // "E1_VEND1"
									nSE1Comis,; // "E1_COMIS1"
									nVlrTit,; // "E1_BASCOM1"
									VV0->VV0_NUMPED,; // "E1_PEDIDO"
									VV0->VV0_NUMNFI,; // "E1_NUMNOTA"
									VV0->VV0_SERNFI,; // "E1_SERIE"
									cPrograE1,; // "E1_ORIGEM"
									VV0->VV0_CCUSTO,; // "E1_CCC"
									,; // "E1_DECRESC"
									.f.,;
									(cSQLAlias)->( RECVS9 )})
							EndIf
							//
							If ("2"$cChamada) // Titulos a serem gerados ( 1 = SE1 para cliente igual ao VV9_CODCLI / 2 = SE1/SE2 para cliente diferente do VV9_CODCLI )
								nVlrTit := ( VV0->VV0_VALTAC - VV0->VV0_TACLIQ )
								If nVlrTit > 0
									If !Empty((cSQLAlias)->( VSA_CODCLI ))
										cCodCli := (cSQLAlias)->( VSA_CODCLI )
										cLojCli := (cSQLAlias)->( VSA_LOJA )
									EndIf
									If FGX_SA1SA2(cCodCli,cLojCli,.t.) // Posiciona ou Cria SA2 (Fornecedor) atraves do SA1 (Cliente)
										//
										cNatTit := VXI02NAT("X",SA2->A2_NATUREZ) // X - Chamada da funcao apenas para atribuir conteudo para a Natureza
										//
										aAdd(aParcelE2,{cPreTit,cNumTit,cParcela,cTipTit,cNatTit,SA2->A2_COD,SA2->A2_LOJA,dDataBase,dDataBase,nVlrTit,nVlrTit,SA2->A2_NREDUZ,cNumBord,cCodBco,cPrefVEI})
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					
					If ("2"$cChamada) // Titulos a serem gerados ( 1 = SE1 para cliente igual ao VV9_CODCLI / 2 = SE1/SE2 para cliente diferente do VV9_CODCLI )
						//////////////////////////////
						// PLUS                     //
						//////////////////////////////
						If VV0->VV0_VCOMFN > 0
							cTipTit := Padr("CMF",nTamE1_TIPO)
							nVlrTit := ( VV0->VV0_VCOMFN / ((100-VV0->VV0_PCUSFN)/100) )
							//
							cNatTit := VXI02NAT("1D",cNatureza) // Natureza de 1=Financiamento - D=Titulo Plus
							//
							// Nใo mudar ORDEM das colunas na matriz aParcelE1 pois ela sera enviada ao PE VXI02CR
							aAdd(aParcelE1,{;
								cPreTit,; // "E1_PREFIXO"
								cNumTit,; // "E1_NUM"
								cParcela,; // "E1_PARCELA"
								cTipTit,; // "E1_TIPO"
								cNatTit,; // "E1_NATUREZ"
								cCodCli,; // "E1_CLIENTE"
								cLojCli,; // "E1_LOJA"
								dDtEmis,; // "E1_EMISSAO"
								dDtVenc,; // "E1_VENCTO"
								DataValida(dDtVenc),; // "E1_VENCREA"
								nVlrTit,; // "E1_VALOR"
								cNumBord,; // "E1_NUMBOR"
								dDatBord,; // "E1_DATABOR"
								cCodBco,; // "E1_PORTADO"
								cPrefVEI,; // "E1_PREFORI"
								cSituaca,; // "E1_SITUACA"
								cSE1CVend,; // "E1_VEND1"
								nSE1Comis,; // "E1_COMIS1"
								nVlrTit,; // "E1_BASCOM1"
								VV0->VV0_NUMPED,; // "E1_PEDIDO"
								VV0->VV0_NUMNFI,; // "E1_NUMNOTA"
								VV0->VV0_SERNFI,; // "E1_SERIE"
								cPrograE1,; // "E1_ORIGEM"
								VV0->VV0_CCUSTO,; // "E1_CCC"
								,; // "E1_DECRESC"
								.f.,;
								(cSQLAlias)->( RECVS9 )})
						EndIf
						//////////////////////////////
						// REBATE                   //
						//////////////////////////////
						If VV0->VV0_VALREB > 0
							If FGX_SA1SA2(,,.t.) // Posiciona ou Cria SA2 (Fornecedor) atraves do SA1 (Cliente)
								cTipTit := Padr("RBT",nTamE1_TIPO)
								nVlrTit := VV0->VV0_VALREB
								//
								cNatTit := VXI02NAT("X",SA2->A2_NATUREZ) // X - Chamada da funcao apenas para atribuir conteudo para a Natureza
								//
								aAdd(aParcelE2,{cPreTit,cNumTit,cParcela,cTipTit,cNatTit,SA2->A2_COD,SA2->A2_LOJA,dDataBase,dDataBase,nVlrTit,nVlrTit,SA2->A2_NREDUZ,cNumBord,cCodBco,cPrefVEI})
							EndIf
						EndIf
					EndIf


				//////////////////////////////////////////////////////////////////////////
				Case (cSQLAlias)->( VSA_TIPO ) == "2"   //   Financiamento Proprio     //
				//////////////////////////////////////////////////////////////////////////
					If ("2"$cChamada) // Titulos a serem gerados ( 1 = SE1 para cliente igual ao VV9_CODCLI / 2 = SE1/SE2 para cliente diferente do VV9_CODCLI )
						//
						cNatTit := VXI02NAT("2",cNatureza) // Natureza de 2=Financiamento Proprio
						//
						aAdd(aParcelE1,{cPreTit,cNumTit,cParcela,cTipTit,cNatTit,cCodCli,cLojCli,dDtEmis,dDtVenc,DataValida(dDtVenc),nVlrTit,cNumBord,dDatBord,cCodBco,cPrefVEI,cSituaca,cSE1CVend,nSE1Comis,nVlrTit,VV0->VV0_NUMPED,VV0->VV0_NUMNFI,VV0->VV0_SERNFI,cPrograE1,VV0->VV0_CCUSTO,,.t.,(cSQLAlias)->( RECVS9 )})
					EndIf


				//////////////////////////////////////////////////////////////////////////
				Case (cSQLAlias)->( VSA_TIPO ) == "3"   //   Consorcio                 //
				//////////////////////////////////////////////////////////////////////////
					If ("2"$cChamada) // Titulos a serem gerados ( 1 = SE1 para cliente igual ao VV9_CODCLI / 2 = SE1/SE2 para cliente diferente do VV9_CODCLI )
						//
						cNatTit := VXI02NAT("3",cNatureza) // Natureza de 3=Consorcio
						//
						// Nใo mudar ORDEM das colunas na matriz aParcelE1 pois ela sera enviada ao PE VXI02CR
						aAdd(aParcelE1,{;
							cPreTit,; // "E1_PREFIXO"
							cNumTit,; // "E1_NUM"
							cParcela,; // "E1_PARCELA"
							cTipTit,; // "E1_TIPO"
							cNatTit,; // "E1_NATUREZ"
							cCodCli,; // "E1_CLIENTE"
							cLojCli,; // "E1_LOJA"
							dDtEmis,; // "E1_EMISSAO"
							dDtVenc,; // "E1_VENCTO"
							DataValida(dDtVenc),; // "E1_VENCREA"
							nVlrTit,; // "E1_VALOR"
							cNumBord,; // "E1_NUMBOR"
							dDatBord,; // "E1_DATABOR"
							cCodBco,; // "E1_PORTADO"
							cPrefVEI,; // "E1_PREFORI"
							cSituaca,; // "E1_SITUACA"
							cSE1CVend,; // "E1_VEND1"
							nSE1Comis,; // "E1_COMIS1"
							nVlrTit,; // "E1_BASCOM1"
							VV0->VV0_NUMPED,; // "E1_PEDIDO"
							VV0->VV0_NUMNFI,; // "E1_NUMNOTA"
							VV0->VV0_SERNFI,; // "E1_SERIE"
							cPrograE1,; // "E1_ORIGEM"
							VV0->VV0_CCUSTO,; // "E1_CCC"
							,; // "E1_DECRESC"
							.t.,;
							(cSQLAlias)->( RECVS9 )})
					EndIf
					
					
				//////////////////////////////////////////////////////////////////////////
				Case (cSQLAlias)->( VSA_TIPO ) == "4"   //   Veiculo Usado na Troca    //
				//////////////////////////////////////////////////////////////////////////
					If ("2"$cChamada) // Titulos a serem gerados ( 1 = SE1 para cliente igual ao VV9_CODCLI / 2 = SE1/SE2 para cliente diferente do VV9_CODCLI )
						//
						cNatTit := VXI02NAT("4",cNatureza) // Natureza de 4=Veiculo Usado na Troca
						//
						// Nใo mudar ORDEM das colunas na matriz aParcelE1 pois ela sera enviada ao PE VXI02CR
						aAdd(aParcelE1,{;
							cPreTit,; // "E1_PREFIXO"
							cNumTit,; // "E1_NUM"
							cParcela,; // "E1_PARCELA"
							cTipTit,; // "E1_TIPO"
							cNatTit,; // "E1_NATUREZ"
							cCodCli,; // "E1_CLIENTE"
							cLojCli,; // "E1_LOJA"
							dDtEmis,; // "E1_EMISSAO"
							dDtVenc,; // "E1_VENCTO"
							DataValida(dDtVenc),; // "E1_VENCREA"
							nVlrTit,; // "E1_VALOR"
							cNumBord,; // "E1_NUMBOR"
							dDatBord,; // "E1_DATABOR"
							cCodBco,; // "E1_PORTADO"
							cPrefVEI,; // "E1_PREFORI"
							cSituaca,; // "E1_SITUACA"
							cSE1CVend,; // "E1_VEND1"
							nSE1Comis,; // "E1_COMIS1"
							nVlrTit,; // "E1_BASCOM1"
							VV0->VV0_NUMPED,; // "E1_PEDIDO"
							VV0->VV0_NUMNFI,; // "E1_NUMNOTA"
							VV0->VV0_SERNFI,; // "E1_SERIE"
							cPrograE1,; // "E1_ORIGEM"
							VV0->VV0_CCUSTO,; // "E1_CCC"
							,; // "E1_DECRESC"
							.t.,;
							(cSQLAlias)->( RECVS9 )})
					EndIf

					
				//////////////////////////////////////////////////////////////////////////
				Case (cSQLAlias)->( VSA_TIPO ) == "5"   //   Entradas                  //
				//////////////////////////////////////////////////////////////////////////
					//
					If !Empty( (cSQLAlias)->( VS9_NATURE ) )
						cNatTit := VXI02NAT("X",(cSQLAlias)->( VS9_NATURE )) // X - Chamada da funcao apenas para atribuir conteudo para a Natureza
					Else
						cNatTit := VXI02NAT("5",cNatureza) // Natureza de 5=Entradas
					EndIf
					//
					// Titulos a serem gerados ( 1 = SE1 para cliente igual ao VV9_CODCLI / 2 = SE1/SE2 para cliente diferente do VV9_CODCLI )
					If ("1"$cChamada)
						If lIntLoja .and. lVS9_PARCVD // Veiculo integrado com o LOJA - Controla Parcela que vai para o Venda Direta
							If (cSQLAlias)->( VS9_PARCVD ) == "1" // 1=Sim ( Parcela ENVIADA ao Venda Direta )
								aAdd(aParcelE1,{cPreTit,cNumTit,cParcela,cTipTit,cNatTit,cCodCli,cLojCli,dDtEmis,dDtVenc,DataValida(dDtVenc),nVlrTit,cNumBord,dDatBord,cCodBco,cPrefVEI,cSituaca,cSE1CVend,nSE1Comis,nVlrTit,VV0->VV0_NUMPED,VV0->VV0_NUMNFI,VV0->VV0_SERNFI,cPrograE1,VV0->VV0_CCUSTO,,.t.,(cSQLAlias)->( RECVS9 )})
							EndIf
						Else
							If dDtVenc <= dDataBase // Titulo a Vista 
								aAdd(aParcelE1,{cPreTit,cNumTit,cParcela,cTipTit,cNatTit,cCodCli,cLojCli,dDtEmis,dDtVenc,DataValida(dDtVenc),nVlrTit,cNumBord,dDatBord,cCodBco,cPrefVEI,cSituaca,cSE1CVend,nSE1Comis,nVlrTit,VV0->VV0_NUMPED,VV0->VV0_NUMNFI,VV0->VV0_SERNFI,cPrograE1,VV0->VV0_CCUSTO,,.t.,(cSQLAlias)->( RECVS9 )})
							EndIf
						EndIf
					EndIf
					If ("2"$cChamada) // Titulos a serem gerados ( 1 = SE1 para cliente igual ao VV9_CODCLI / 2 = SE1/SE2 para cliente diferente do VV9_CODCLI )
						If lIntLoja .and. lVS9_PARCVD // Veiculo integrado com o LOJA - Controla Parcela que vai para o Venda Direta
							If (cSQLAlias)->( VS9_PARCVD ) <> "1" // diferente de 1=Sim ( Parcela ENVIADA ao Venda Direta )
								aAdd(aParcelE1,{cPreTit,cNumTit,cParcela,cTipTit,cNatTit,cCodCli,cLojCli,dDtEmis,dDtVenc,DataValida(dDtVenc),nVlrTit,cNumBord,dDatBord,cCodBco,cPrefVEI,cSituaca,cSE1CVend,nSE1Comis,nVlrTit,VV0->VV0_NUMPED,VV0->VV0_NUMNFI,VV0->VV0_SERNFI,cPrograE1,VV0->VV0_CCUSTO,,.t.,(cSQLAlias)->( RECVS9 )})
							EndIf
						Else
							If dDtVenc > dDataBase // Titulo a prazo 
								aAdd(aParcelE1,{cPreTit,cNumTit,cParcela,cTipTit,cNatTit,cCodCli,cLojCli,dDtEmis,dDtVenc,DataValida(dDtVenc),nVlrTit,cNumBord,dDatBord,cCodBco,cPrefVEI,cSituaca,cSE1CVend,nSE1Comis,nVlrTit,VV0->VV0_NUMPED,VV0->VV0_NUMNFI,VV0->VV0_SERNFI,cPrograE1,VV0->VV0_CCUSTO,,.t.,(cSQLAlias)->( RECVS9 )})
							EndIf
						EndIf
						If lBaixaAut .and. dDtVenc <= dDataBase
							aAdd(aBaixaAut,{cPreTit,cNumTit,cParcela,cTipTit,"NOR","NOR",dDataBase,dDataBase,STR0014,nVlrTit,(cSQLAlias)->( RECVS9 )}) // Baixa Automatica
							aAdd(aAtualVS9,{(cSQLAlias)->( RECVS9 ),2,dDataBase}) // Atualiza Data de Baixa do Titulo no VS9
						EndIf
					EndIf
					
					
					
				//////////////////////////////////////////////////////////////////////////
				Case (cSQLAlias)->( VSA_TIPO ) == "6"   //   Finame                    //
				//////////////////////////////////////////////////////////////////////////
					If ("2"$cChamada) // Titulos a serem gerados ( 1 = SE1 para cliente igual ao VV9_CODCLI / 2 = SE1/SE2 para cliente diferente do VV9_CODCLI )
						//////////////////////////////
						// TITULO NORMAL            //
						//////////////////////////////
						//
						cNatTit := VXI02NAT("6R",cNatureza) // Natureza de 6=Finame (R - Receber)
						//
						If !lVV0_CFFINA .or. VV0->VV0_CFFINA == "1" // Cliente
							// Nใo mudar ORDEM das colunas na matriz aParcelE1 pois ela sera enviada ao PE VXI02CR
							aAdd(aParcelE1,{;
								cPreTit,; // "E1_PREFIXO"
								cNumTit,; // "E1_NUM"
								cParcela,; // "E1_PARCELA"
								cTipTit,; // "E1_TIPO"
								cNatTit,; // "E1_NATUREZ"
								cCodCli,; // "E1_CLIENTE"
								cLojCli,; // "E1_LOJA"
								dDtEmis,; // "E1_EMISSAO"
								dDtVenc,; // "E1_VENCTO"
								DataValida(dDtVenc),; // "E1_VENCREA"
								nVlrTit,; // "E1_VALOR"
								cNumBord,; // "E1_NUMBOR"
								dDatBord,; // "E1_DATABOR"
								cCodBco,; // "E1_PORTADO"
								cPrefVEI,; // "E1_PREFORI"
								cSituaca,; // "E1_SITUACA"
								cSE1CVend,; // "E1_VEND1"
								nSE1Comis,; // "E1_COMIS1"
								nVlrTit,; // "E1_BASCOM1"
								VV0->VV0_NUMPED,; // "E1_PEDIDO"
								VV0->VV0_NUMNFI,; // "E1_NUMNOTA"
								VV0->VV0_SERNFI,; // "E1_SERIE"
								cPrograE1,; // "E1_ORIGEM"
								VV0->VV0_CCUSTO,; // "E1_CCC"
								,; // "E1_DECRESC"
								.t.,;
								(cSQLAlias)->( RECVS9 )})
						Else //  VV0->VV0_CFFINA == "2" // Financeira/Banco
							cCodCli := VV0->VV0_CLFINA
							cLojCli := VV0->VV0_LJFINA
							// Nใo mudar ORDEM das colunas na matriz aParcelE1 pois ela sera enviada ao PE VXI02CR
							aAdd(aParcelE1,{;
								cPreTit,; // "E1_PREFIXO"
								cNumTit,; // "E1_NUM"
								cParcela,; // "E1_PARCELA"
								cTipTit,; // "E1_TIPO"
								cNatTit,; // "E1_NATUREZ"
								cCodCli,; // "E1_CLIENTE"
								cLojCli,; // "E1_LOJA"
								dDtEmis,; // "E1_EMISSAO"
								dDtVenc,; // "E1_VENCTO"
								DataValida(dDtVenc),; // "E1_VENCREA"
								nVlrTit,; // "E1_VALOR"
								cNumBord,; // "E1_NUMBOR"
								dDatBord,; // "E1_DATABOR"
								cCodBco,; // "E1_PORTADO"
								cPrefVEI,; // "E1_PREFORI"
								cSituaca,; // "E1_SITUACA"
								cSE1CVend,; // "E1_VEND1"
								nSE1Comis,; // "E1_COMIS1"
								nVlrTit,; // "E1_BASCOM1"
								VV0->VV0_NUMPED,; // "E1_PEDIDO"
								VV0->VV0_NUMNFI,; // "E1_NUMNOTA"
								VV0->VV0_SERNFI,; // "E1_SERIE"
								cPrograE1,; // "E1_ORIGEM"
								VV0->VV0_CCUSTO,; // "E1_CCC"
								,; // "E1_DECRESC"
								.t.,;
								(cSQLAlias)->( RECVS9 )})

							//////////////////////////////
							// FINAME FLAT / RISCO      //
							//////////////////////////////
							If VV0->VV0_VFFINA > 0 .or. VV0->VV0_VRFINA > 0 // Valor Flat Finame ou  Valor Risco Finame
								If FGX_SA1SA2(cCodCli,cLojCli,.t.) // Posiciona ou Cria SA2 (Fornecedor) atraves do SA1 (Cliente)								
									//
									If VV0->VV0_VFFINA > 0 // Valor Flat Finame
										cNatTit := VXI02NAT("6PF",cNatureza) // Natureza de 6=Finame (P - Pagar)
										nVlrTit := VV0->VV0_VFFINA
										cTipTit := Padr("FF",nTamE1_TIPO)
										aAdd(aParcelE2,{cPreTit,cNumTit,cParcela,cTipTit,cNatTit,SA2->A2_COD,SA2->A2_LOJA,dDataBase,DataValida(VV0->VV0_DFFINA),nVlrTit,nVlrTit,SA2->A2_NREDUZ,cNumBord,cCodBco,cPrefVEI})
									EndIf
									If VV0->VV0_VRFINA > 0 // Valor Risco Finame
										cNatTit := VXI02NAT("6PR",cNatureza) // Natureza de 6=Finame (P - Pagar)									
										nVlrTit := VV0->VV0_VRFINA
										cTipTit := Padr("FR",nTamE1_TIPO)
										aAdd(aParcelE2,{cPreTit,cNumTit,cParcela,cTipTit,cNatTit,SA2->A2_COD,SA2->A2_LOJA,dDataBase,DataValida(VV0->VV0_DRFINA),nVlrTit,nVlrTit,SA2->A2_NREDUZ,cNumBord,cCodBco,cPrefVEI})
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					
			EndCase
			
			
			(cSQLAlias)->(dbSkip())
		EndDo
		(cSQLAlias)->(dbCloseArea())
		
		If ("2"$cChamada) // Titulos a serem gerados ( 1 = SE1 para cliente igual ao VV9_CODCLI / 2 = SE1/SE2 para cliente diferente do VV9_CODCLI )
			//////////////////////////////
			//   TROCO PARA O CLIENTE   //
			//////////////////////////////
			If VV0->VV0_VALTRO > 0
				///////////////////////////////////////////////////////////////////////////////
				// Titulo de Troco NCC (1=SE1) ou NCF (2=SE2) + Codigo da Natureza do Titulo //
				///////////////////////////////////////////////////////////////////////////////
				cCodCli := VV9->VV9_CODCLI
				cLojCli := VV9->VV9_LOJA
				SA1->(DbSetOrder(1))
				SA1->(MsSeek(xFilial("SA1")+cCodCli+cLojCli))
				nVlrTit := VV0->VV0_VALTRO
				//
				cNatTit := VXI02NAT("X",substr(cNCCNCF,2,TamSX3("A1_NATUREZ")[1])) // X - Chamada da funcao apenas para atribuir conteudo para a Natureza
				//
				If left(cNCCNCF,1) == "1"
					cTipTit := Padr("NCC",nTamE1_TIPO)
					// Nใo mudar ORDEM das colunas na matriz aParcelE1 pois ela sera enviada ao PE VXI02CR
					aAdd(aParcelE1,{;
						cPreTit,; // "E1_PREFIXO"
						cNumTit,; // "E1_NUM"
						cParcela,; // "E1_PARCELA"
						cTipTit,; // "E1_TIPO"
						cNatTit,; // "E1_NATUREZ"
						cCodCli,; // "E1_CLIENTE"
						cLojCli,; // "E1_LOJA"
						dDtEmis,; // "E1_EMISSAO"
						dDtVenc,; // "E1_VENCTO"
						DataValida(dDtVenc),; // "E1_VENCREA"
						nVlrTit,; // "E1_VALOR"
						cNumBord,; // "E1_NUMBOR"
						dDatBord,; // "E1_DATABOR"
						cCodBco,; // "E1_PORTADO"
						cPrefVEI,; // "E1_PREFORI"
						cSituaca,; // "E1_SITUACA"
						cSE1CVend,; // "E1_VEND1"
						nSE1Comis,; // "E1_COMIS1"
						nVlrTit,; // "E1_BASCOM1"
						VV0->VV0_NUMPED,; // "E1_PEDIDO"
						VV0->VV0_NUMNFI,; // "E1_NUMNOTA"
						VV0->VV0_SERNFI,; // "E1_SERIE"
						cPrograE1,; // "E1_ORIGEM"
						VV0->VV0_CCUSTO,; // "E1_CCC"
						,; // "E1_DECRESC"
						.f.,;
						0})
				Else
					If FGX_SA1SA2(,,.t.) // Posiciona ou Cria SA2 (Fornecedor) atraves do SA1 (Cliente)
						cTipTit := Padr("NCF",nTamE1_TIPO)
						aAdd(aParcelE2,{cPreTit,cNumTit,cParcela,cTipTit,cNatTit,SA2->A2_COD,SA2->A2_LOJA,dDataBase,DataValida(dDataBase),nVlrTit,nVlrTit,SA2->A2_NREDUZ,cNumBord,cCodBco,cPrefVEI})
					EndIf
				EndIf
			EndIf
		EndIf
			
		If ("1"$cChamada) // Titulos a serem gerados ( 1 = SE1 para cliente igual ao VV9_CODCLI / 2 = SE1/SE2 para cliente diferente do VV9_CODCLI )
			//////////////////////////////////////////////////////////////////
			// Cria Titulo do VZ7 ( Acoes de Venda -> Como Pagar = Caixa )  //
			//////////////////////////////////////////////////////////////////
			//
			cNatTit := VXI02NAT("VZ7",cNatureza) // VZ7
			//
			cQuery := "SELECT VZ7.VZ7_TIPTIT , SUM(VZ7.VZ7_VALITE) AS VLR FROM " + RetSQLName("VZ7") + " VZ7 "
			cQuery += "WHERE VZ7.VZ7_FILIAL='" + xFilial("VZ7") + "' AND VZ7.VZ7_NUMTRA='"+VV9->VV9_NUMATE+"' AND "
			cQuery += "VZ7.VZ7_AGRVLR='3' AND VZ7.VZ7_COMPAG='1' AND VZ7.D_E_L_E_T_=' ' "
			cQuery += "GROUP BY VZ7.VZ7_TIPTIT"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
			While !(cSQLAlias)->( Eof() )
				cCodCli := VV9->VV9_CODCLI
				cLojCli := VV9->VV9_LOJA
				cTipTit := Padr(( cSQLAlias )->( VZ7_TIPTIT ),nTamE1_TIPO)
				nVlrTit := ( cSQLAlias )->( VLR )
				dDtVenc := dDataBase
				dDtEmis := dDataBase

				// Nใo mudar ORDEM das colunas na matriz aParcelE1 pois ela sera enviada ao PE VXI02CR
				aAdd(aParcelE1,{;
					cPreTit,; // "E1_PREFIXO"
					cNumTit,; // "E1_NUM"
					cParcela,; // "E1_PARCELA"
					cTipTit,; // "E1_TIPO"
					cNatTit,; // "E1_NATUREZ"
					cCodCli,; // "E1_CLIENTE"
					cLojCli,; // "E1_LOJA"
					dDtEmis,; // "E1_EMISSAO"
					dDtVenc,; // "E1_VENCTO"
					DataValida(dDtVenc),; // "E1_VENCREA"
					nVlrTit,; // "E1_VALOR"
					cNumBord,; // "E1_NUMBOR"
					dDatBord,; // "E1_DATABOR"
					cCodBco,; // "E1_PORTADO"
					cPrefVEI,; // "E1_PREFORI"
					cSituaca,; // "E1_SITUACA"
					cSE1CVend,; // "E1_VEND1"
					nSE1Comis,; // "E1_COMIS1"
					nVlrTit,; // "E1_BASCOM1"
					VV0->VV0_NUMPED,; // "E1_PEDIDO"
					VV0->VV0_NUMNFI,; // "E1_NUMNOTA"
					VV0->VV0_SERNFI,; // "E1_SERIE"
					cPrograE1,; // "E1_ORIGEM"
					VV0->VV0_CCUSTO,; // "E1_CCC"
					,; // "E1_DECRESC"
					.f.,;
					0})

				(cSQLAlias)->(dbSkip())
			EndDo
			(cSQLAlias)->(dbCloseArea())
		EndIf
		
		If len(aParcelE1) > 0
			//////////////////////////////////////////////////////////////////
			// Ordena Vetor: Prefixo + NroTitulo + DataTitulo + TipoTitulo  //
			//////////////////////////////////////////////////////////////////
			Asort(aParcelE1,,,{|x,y| x[1]+x[2]+dtos(x[10])+x[4] < y[1]+y[2]+dtos(y[10])+y[4] })
			If ("2"$cChamada) // Titulos a serem gerados ( 1 = SE1 para cliente igual ao VV9_CODCLI / 2 = SE1/SE2 para cliente diferente do VV9_CODCLI )
				//////////////////////////////////////////////////////////////////
				// Atualizar o Numero das Parcelas dos Titulos no Vetor do SE1  //
				//////////////////////////////////////////////////////////////////
				nParc   := 0
				For ni := 1 to len(aParcelE1)
					While .t.
						nParc++
						cParc := FS_SOMAPARC("E1_PARCELA",nParc)
						If cParc <> FM_SQL("SELECT SE1.E1_PARCELA FROM " + RetSQLName("SE1") + " SE1 WHERE SE1.E1_FILIAL='" + xFilial("SE1") + "' AND SE1.E1_PREFIXO='"+aParcelE1[ni,1]+"' AND SE1.E1_NUM='"+aParcelE1[ni,2]+"' AND SE1.E1_PARCELA='"+cParc+"' AND SE1.E1_FILORIG='"+xFilial("VV9")+"' AND SE1.D_E_L_E_T_=' '")
							Exit
						EndIf
					EndDo
					aParcelE1[ni,3] := cParc
					If aParcelE1[ni,len(aParcelE1[ni])] > 0
						If aParcelE1[ni,len(aParcelE1[ni])-1] // Alterar o VS9_PARCEL ?
							//////////////////////////////////////////
							// Atualiza Parcela do Titulo no VS9    //
							//////////////////////////////////////////
							aAdd(aAtualVS9,{aParcelE1[ni,len(aParcelE1[ni])],3,cParc})
						EndIf
						//////////////////////////////////////////
						// Atualiza Parcela na Baixa Automatica //
						//////////////////////////////////////////
						nPos := aScan(aBaixaAut,{|x| x[Len(aCampoAut)+1] == aParcelE1[ni,len(aParcelE1[ni])] })
						If nPos > 0
							aBaixaAut[nPos,3] := cParc
						EndIf
					EndIf
				Next
				//////////////////////////////////////////////////////////////
				// Gerar/Baixar Titulos SE1 - Contas a Receber              //
				//////////////////////////////////////////////////////////////
				If lCPagPad .OR. (lVV0FPGPAD .and. VV0->VV0_FPGPAD == "1") // Condi็ใo de Pagto DIFERENTE do Padrใo
				Else
					If !VEIXI002CR(aCamposE1,aParcelE1,aCampoAut,aBaixaAut,@aLogVQL)
						DisarmTransaction()
						RollbackSxe()
						For ni := 1 to len(aLogVQL)
							oLogger:LogToTable(aLogVQL[ni])
						Next
						Return .f.
					EndIf
				EndIf
			EndIf
			If lIntLoja .and. (lOrcLoja .or. !Empty(VV0->VV0_PESQLJ))
				//////////////////////////////////////////////////////////////
				// Gerar Orcamento no LOJA - SL1 / SL2 / SL4                //
				//////////////////////////////////////////////////////////////
				If !VEIXI002LJ(aParcelE1,cChamada,aValVVA)
					DisarmTransaction()
					RollbackSxe()
					Return .f.
				EndIf
			EndIf
		EndIf
		
		If VXX002DUPL(2) // Verifica se os TES utilizados geram ou nao duplicatas  ( .t. = Gerar Duplicatas )
			//////////////////////////////////////////////////////////////////
			// Atualizar os dados nos Titulos do VS9                        //
			//////////////////////////////////////////////////////////////////
			For ni := 1 to len(aAtualVS9)
				DbSelectArea("VS9")
				If aAtualVS9[ni,1] > 0
					DbGoTo(aAtualVS9[ni,1])
					RecLock("VS9",.f.)
					If aAtualVS9[ni,2] == 1 // Atualiza Data de Emissao do Titulo no VS9
						VS9->VS9_DATPAG := aAtualVS9[ni,3]
					ElseIf aAtualVS9[ni,2] == 2 // Atualiza Data de Baixa do Titulo no VS9
						VS9->VS9_DATBAI := aAtualVS9[ni,3]
					ElseIf aAtualVS9[ni,2] == 3 // Atualiza Parcela do Titulo no VS9
						VS9->VS9_PARCEL := aAtualVS9[ni,3]
					EndIf
					MsUnLock()
				EndIf
			Next
		EndIf
		
		If ("2"$cChamada) // Titulos a serem gerados ( 1 = SE1 para cliente igual ao VV9_CODCLI / 2 = SE1/SE2 para cliente diferente do VV9_CODCLI )
			If len(aParcelE2) > 0
				//////////////////////////////////////////////////////////////////
				// Ordena Vetor: Prefixo + NroTitulo + DataTitulo + TipoTitulo  //
				//////////////////////////////////////////////////////////////////
				Asort(aParcelE2,,,{|x,y| x[1]+x[2]+dtos(x[9])+x[4] < y[1]+y[2]+dtos(y[9])+y[4] })
				//////////////////////////////////////////////////////////////////
				// Atualizar o Numero das Parcelas dos Titulos no Vetor do SE2  //
				//////////////////////////////////////////////////////////////////
				nParc   := 0
				For ni := 1 to len(aParcelE2)
					nParc++
					aParcelE2[ni,3] := FS_SOMAPARC("E2_PARCELA",nParc)
				Next
				//////////////////////////////////////////////////////////////////
				// Gerar Titulos SE2 - Contas a Pagar                           //
				//////////////////////////////////////////////////////////////////
				If !VEIXI002CP(aCamposE2,aParcelE2)
					DisarmTransaction()
					RollbackSxe()
					Return .f.
				EndIf
			EndIf
		EndIf
		
	EndIf
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SOMAPARCบ Autor ณ Andre Luis Almeida บ Data ณ  07/05/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Soma 1 na Parcela ( E1_PARCELA / E2_PARCELA )              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_SOMAPARC(cCampo,nParc)
Local cParcela := ""
If TamSx3(cCampo)[1] == 1
	cParcela := ConvPN2PC(nParc)
Else
	cParcela := strzero(nParc,TamSx3(cCampo)[1])
EndIf
Return cParcela

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณVEIXI002CRบ Autor ณ Andre Luis Almeida  บ Data ณ  07/05/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Criacao dos Titulos no Contas a Receber e Baixa Automatica บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aCamposE1 = Campos utilizados na criacao do SE1            บฑฑ
ฑฑบ          ณ aParcelE1 = Titulos a serem gerados obdecendo o aCamposE1  บฑฑ
ฑฑบ          ณ aCampoAut = Campos utilizados para dar baixa automatica SE1บฑฑ
ฑฑบ          ณ aBaixaAut = Titulos a serem baixados automaticamente no SE1บฑฑ
ฑฑบ          ณ aLogVQL = Vetor com o LOG dos problemas na gera็ใo do SE1  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIXI002CR(aCamposE1,aParcelE1,aCampoAut,aBaixaAut,aLogVQL)
Local nLinha  := 0
Local nColuna := 0
Local aParcela := {}
Local lExistPE := (ExistBlock("VXI02CR"))
Local aAuxParc := {}
Local aBancoBxa:= {} // Caixa Geral do Financeiro (MV_CXFIN)
Local aLog     := {}
Local cMsgErr  := ""
If VXX002DUPL(2) // Verifica se os TES utilizados geram ou nao duplicatas  ( .t. = Gerar Duplicatas )
	DbSelectArea("SE1")
	aBancoBxa   := xCxFina() // Caixa Geral do Financeiro (MV_CXFIN)
	//////////////////////
	// Criacao do SE1   //
	//////////////////////
	For nLinha := 1 to len(aParcelE1)
		aParcela := {}
		For nColuna := 1 to len(aCamposE1)
			If aParcelE1[nLinha,nColuna] <> NIL
				aAdd(aParcela,{aCamposE1[nColuna],aParcelE1[nLinha,nColuna],nil})
			EndIf
		Next
		/////////////////////////////////////////////////////////////////
		// Verificar/Incluir o Tipo do Titulo na tabela 24 e 05 do SX5 //
		/////////////////////////////////////////////////////////////////
		DbSelectArea("SX5")
		dbSetOrder(1)
		If !MsSeek(xFilial("SX5")+"24"+aParcelE1[nLinha,04]) // Tabela 24 - Loja (SL4)
			RecLock("SX5",.t.)
			SX5->X5_FILIAL := xFilial("SX5")
			SX5->X5_TABELA := "24"
			SX5->X5_CHAVE  := aParcelE1[nLinha,04]
			SX5->X5_DESCRI := aParcelE1[nLinha,04]
			MsUnlock()
		EndIf
		If !MsSeek(xFilial("SX5")+"05"+aParcelE1[nLinha,04]) // Tabela 05 - Faturamento/Financeiro (SE1/SE2)
			RecLock("SX5",.t.)
			SX5->X5_FILIAL := xFilial("SX5")
			SX5->X5_TABELA := "05"
			SX5->X5_CHAVE  := aParcelE1[nLinha,04]
			SX5->X5_DESCRI := aParcelE1[nLinha,04]
			MsUnlock()
		EndIf
		If len(aParcela) > 0
			cMsgErr := VXI020011_LogArrayExecAuto(aParcela)
		EndIf
		if lExistPE
			aAuxParc := ExecBlock("VXI02CR",.f.,.f.,{ aClone(aParcela) , aParcelE1[nLinha] })
			if ValType(aAuxParc) == "A"
				aParcela := aClone(aAuxParc)
				cMsgErr +=  CRLF + CRLF + "VXI02CR" + CRLF + VXI020011_LogArrayExecAuto(aParcela)
			endif
		endif
		If len(aParcela) > 0
			Pergunte("FIN040",.f.)
			lMsErroAuto := .f.
			MSExecAuto({|x| FINA040(x)},aParcela)
			If lMsErroAuto
				MostraErro()
				cMsgErr +=  CRLF + CRLF + "lMsErroAuto" + CRLF + MostraErro()
				aLog := {}
				//Gerar log de execu็ใo no VQL
				aAdd(aLog,{'VQL_AGROUP'     , 'VEIXI002'                })
				aAdd(aLog,{'VQL_TIPO'       , 'VV0-' + VV0->VV0_NUMTRA  })
				aAdd(aLog,{'VQL_FILORI'     , VV0->VV0_FILIAL           })
				aAdd(aLog,{'VQL_DADOS'      , STR0017 }) // PROBLEMA NA GERAวรO DAS PARCELAS
				If VQL->(FieldPos("VQL_MSGLOG")) > 0
					aAdd(aLog,{'VQL_MSGLOG'     , cMsgErr })
				EndIf
				aAdd(aLogVQL,aLog)
				Return .f.
			EndIf
		EndIf
	Next
	//////////////////////
	// Baixa Automatica //
	//////////////////////
	For nLinha := 1 to len(aBaixaAut)
		If !Empty(aBaixaAut[nLinha,3]) // Possui nro da parcela
			aParcela := {}
			For nColuna := 1 to len(aCampoAut)
				If aBaixaAut[nLinha,nColuna] <> NIL
					aAdd(aParcela,{aCampoAut[nColuna],aBaixaAut[nLinha,nColuna],nil})
				EndIf
			Next
			If len(aParcela) > 0
				lMsErroAuto := .f.          
				DbSelectArea("SE1")
				DbSetOrder(1)
				If DbSeek(xfilial("SE1")+aParcela[1,2]+aParcela[2,2]+aParcela[3,2]+aParcela[4,2])
					aAdd(aParcela,{"AUTBANCO",IIF(SE1->E1_SITUACA $ "0FG", aBancoBxa[1] ,SE1->E1_PORTADO),nil})
					aAdd(aParcela,{"AUTAGENCIA",IIF(SE1->E1_SITUACA $ "0FG", aBancoBxa[2] ,SE1->E1_AGEDEP),nil})
					aAdd(aParcela,{"AUTCONTA",IIF(SE1->E1_SITUACA $ "0FG", aBancoBxa[3] ,SE1->E1_CONTA),nil})
				Endif

				//PE criado para passagem de parโmetros customizados no ExecAuto do FINA070, seguindo o parโmetro MV_BXVEI
				If ExistBlock("VXI02BXF")
					aParcela := ExecBlock("VXI02BXF", .F., .F., aParcela)
				Endif

				MSExecAuto({|x| FINA070(x)},aParcela)
				If lMsErroAuto
					MostraErro()
					cMsgErr := VarInfo("",aParcela,NIL,.F.,.F.)
					cMsgErr +=   CRLF + CRLF + "lMsErroAuto" + CRLF + MostraErro()
					aLog := {}
					//Gerar log de execu็ใo no VQL
					aAdd(aLog,{'VQL_AGROUP'     , 'VEIXI002'         })
					aAdd(aLog,{'VQL_TIPO'       , 'VV0-' + VV0->VV0_NUMTRA })
					aAdd(aLog,{'VQL_FILORI'     , VV0->VV0_FILIAL           })
					aAdd(aLog,{'VQL_DADOS'      , STR0018 }) // PROBLEMA NA BAIXA AUTOMมTICA DAS PARCELAS A VISTA
					If VQL->(FieldPos("VQL_MSGLOG")) > 0
						aAdd(aLog,{'VQL_MSGLOG'     , cMsgErr })
					EndIf
					aAdd(aLogVQL,aLog)
					Return .f.
				EndIf
			EndIf
		EndIf
	Next
EndIf
DbSelectArea("SE1")
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณVEIXI002CPบ Autor ณ Andre Luis Almeida  บ Data ณ  07/05/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Criacao dos Titulos no Contas a Pagar                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aCamposE2 = Campos utilizados na criacao do SE2            บฑฑ
ฑฑบ          ณ aParcelE2 = Titulos a serem gerados obdecendo o aCamposE2  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIXI002CP(aCamposE2,aParcelE2)
Local nLinha  := 0
Local nColuna := 0
Local aParcela := {}
Local lExistPE := (ExistBlock("VXI02CP"))
Local aAuxParc := {}
If VXX002DUPL(2) // Verifica se os TES utilizados geram ou nao duplicatas  ( .t. = Gerar Duplicatas )
	DbSelectArea("SE2")
	//////////////////////
	// Criacao do SE2   //
	//////////////////////
	For nLinha := 1 to len(aParcelE2)
		aParcela := {}
		For nColuna := 1 to len(aCamposE2)
			If aParcelE2[nLinha,nColuna] <> NIL
				aAdd(aParcela,{aCamposE2[nColuna],aParcelE2[nLinha,nColuna],nil})
			EndIf
		Next
		/////////////////////////////////////////////////////////////////
		// Verificar/Incluir o Tipo do Titulo na tabela 24 e 05 do SX5 //
		/////////////////////////////////////////////////////////////////
		DbSelectArea("SX5")
		dbSetOrder(1)
		If !MsSeek(xFilial("SX5")+"24"+aParcelE2[nLinha,04]) // Tabela 24 - Loja (SL4)
	  	    RecLock("SX5",.t.)
			SX5->X5_FILIAL := xFilial("SX5")
			SX5->X5_TABELA := "24"
	    	SX5->X5_CHAVE  := aParcelE2[nLinha,04]
		    SX5->X5_DESCRI := aParcelE2[nLinha,04]
	    	MsUnlock()
		EndIf
		If !MsSeek(xFilial("SX5")+"05"+aParcelE2[nLinha,04]) // Tabela 05 - Faturamento/Financeiro (SE1/SE2)
	  	    RecLock("SX5",.t.)
			SX5->X5_FILIAL := xFilial("SX5")
			SX5->X5_TABELA := "05"
	    	SX5->X5_CHAVE  := aParcelE2[nLinha,04]
		    SX5->X5_DESCRI := aParcelE2[nLinha,04]
	    	MsUnlock()
		EndIf
		If lExistPE
			aAuxParc := ExecBlock("VXI02CP",.f.,.f.,{ aClone(aParcela) })
			If ValType(aAuxParc) == "A"
				aParcela := aClone(aAuxParc)
			EndIf
		EndIf
		If len(aParcela) > 0
			Pergunte("FIN050",.f.)
			lMsErroAuto := .f.
			MsExecAuto({|x,y,z| FINA050(x,y,z)},aParcela)
			If lMsErroAuto
				MostraErro()
				Return .f.
			EndIf
		EndIf
	Next
EndIf
DbSelectArea("SE2")
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณVEIXI002LJบ Autor ณ Andre Luis Almeida  บ Data ณ  03/01/12  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Criacao do Orcamento no Loja ( SL1/SLQ / SL2/SLR / SL4 )   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aParcelE1 = Titulos a serem gerados SL4                    บฑฑ
ฑฑบ          ณ cChamada  = 1 - Gera SL1/SLQ / SL2/SLR / SL4               บฑฑ
ฑฑบ          ณ           = 2 - Finaliza Pedido no Loja                    บฑฑ
ฑฑบ          ณ aValVVA   = Valores dos Produtos que vao para o LOJA       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIXI002LJ(aParcelE1,cChamada,aValVVA)
Local lRet      	:= .t.
Local ni        	:= 0
Local cSFunName 	:= ""
Local oFont1    	:= TFont():New(,11,24,,.F.,,,,,,,,,,,)
Local oFont2    	:= TFont():New(,14,28,,.T.,,,,,,,,,,,)
Local cGruVei   	:= PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Local cVenVDi   	:= VV0->VV0_CODVEN // Vendedor Venda Direta
Local cAutReser 	:= "000001"
Local cMVTABPAD  	:= GetNewPar("MV_TABPAD","1")
Local lMVLJCNVDA 	:= GetNewPar("MV_LJCNVDA",.f.)
Local cFormaID		:= ""
Private _aParcela   := {}
Private _aCab       := {}
Private _aItem      := {}
Private lMsHelpAuto := .T.	// Variavel de controle interno do ExecAuto
Private lMsErroAuto := .F.	// Variavel que informa a ocorrencia de erros no ExecAuto
Private INCLUI      := .T.	// Variavel necessaria para o ExecAuto identificar que se trata de uma inclusao
Private ALTERA      := .F.	// Variavel necessaria para o ExecAuto identificar que se trata de uma inclusao
Default aValVVA     := {}
Private lFormaID 	:= VS9->(FieldPos("VS9_FORMID")) > 0 .and. GetNewPar("MV_TEFMULT","F") == .t.

SA1->(DbSetOrder(1))
SA1->(MsSeek(xFilial("SA1")+VV9->VV9_CODCLI+VV9->VV9_LOJA))

If VV0->(FieldPos("VV0_VENVDI")) > 0
	cVenVDi := VV0->VV0_VENVDI // Vendedor Venda Direta
	SA3->(DbSetOrder(1))
	SA3->(MsSeek(xFilial("SA3")+cVenVDi))
EndIf

If cChamada == "1" // 1 - Gera ( SL1/SLQ / SL2/SLR / SL4 )

	/////////////////////////////////////////////////////////////////
	// Pegar o Codigo do Cad.Lojas para passar no SLQ 'AUTRESERVA' //
	/////////////////////////////////////////////////////////////////
	dbSelectArea("SLJ")
	dbSetOrder(2)	// filial + nome + codigo
	MsSeek(xFilial("SLJ"))
	While !Eof() .And. SLJ->LJ_FILIAL == xFilial("SLJ")
		If SLJ->LJ_RESERVA == "1" .and. SM0->M0_CODIGO == SLJ->LJ_RPCEMP
			cAutReser := SLJ->LJ_CODIGO
			Exit
		Endif
		dbSkip()
	EndDo
    
	If VXX002DUPL(2) // Verifica se os TES utilizados geram ou nao duplicatas  ( .t. = Gerar Duplicatas )
		/////////////////////////////////////////////////////////////////
		// Verificar/Incluir o Tipo do Titulo na tabela 24 e 05 do SX5 //
		/////////////////////////////////////////////////////////////////
		DbSelectArea("SX5")
		dbSetOrder(1)
		For ni := 1 to len(aParcelE1)
			If !MsSeek(xFilial("SX5")+"24"+aParcelE1[ni,04]) // Tabela 24 - Loja (SL4)
		  	    RecLock("SX5",.t.)
				SX5->X5_FILIAL := xFilial("SX5")
				SX5->X5_TABELA := "24"
		    	SX5->X5_CHAVE  := aParcelE1[ni,04]
			    SX5->X5_DESCRI := aParcelE1[ni,04]
		    	MsUnlock()
			EndIf
			If !MsSeek(xFilial("SX5")+"05"+aParcelE1[ni,04]) // Tabela 05 - Faturamento/Financeiro (SE1/SE2)
		  	    RecLock("SX5",.t.)
				SX5->X5_FILIAL := xFilial("SX5")
				SX5->X5_TABELA := "05"
		    	SX5->X5_CHAVE  := aParcelE1[ni,04]
			    SX5->X5_DESCRI := aParcelE1[ni,04]
		    	MsUnlock()
			EndIf
	    Next
		/////////////////////////////////
		// Gerar Pedido/Venda no Loja  //
		/////////////////////////////////
		For ni := 1 to len(aParcelE1)

			If lFormaID
				dbSelectArea("VS9")
				VS9->(dbGoTo(aParcelE1[ni,27]))
				cFormaID := VS9->VS9_FORMID
			EndIf

			If Empty(cFormaID)
				cFormaID := " "
			EndIf

			aAdd(_aParcela,{{"L4_DATA"	, aParcelE1[ni,10]	,NIL},;
						{"L4_VALOR"		, aParcelE1[ni,11]	,NIL},;
						{"L4_FORMA"		, Padr(aParcelE1[ni,04],TamSX3("L4_FORMA")[1])	,NIL},;
						{"L4_ADMINIS"	, " "				,NIL},;
						{"L4_FORMAID"   , cFormaID			,NIL},;
						{"L4_MOEDA"		, 0					,NIL}})  
		Next
    EndIf
    
	/////////////////////////////////////////////////////////////////////////////////
	// Carregar Vetores para Integracao SLQ ( SL1 - CABECALHO )                    //
	/////////////////////////////////////////////////////////////////////////////////
	_aCab:= {    	{"LQ_VEND"		, cVenVDi			,NIL},;
	                {"LQ_COMIS"		, 0  				,NIL},;    
	                {"LQ_CLIENTE"	, SA1->A1_COD		,NIL},;
	                {"LQ_LOJA"		, SA1->A1_LOJA		,NIL},;
	                {"LQ_TIPOCLI"	, SA1->A1_TIPO		,NIL},;
	                {"LQ_DESCONT"	, 0					,NIL},;
	                {"LQ_NROPCLI"	, "         "		,NIL},;
	                {"LQ_DTLIM"		, dDatabase+30		,NIL},;
	                {"LQ_DOC"		, ""				,NIL},;
	                {"LQ_SERIE"		, ""				,NIL},;
	                {"LQ_PDV"		, "0001      "		,NIL},;
	                {"LQ_EMISNF"	, dDatabase			,NIL},;
	                {"LQ_TIPO"		, "V"				,NIL},;
	                {"LQ_DESCNF"	, 0					,NIL},;
	                {"LQ_OPERADO"	, xNumCaixa()		,NIL},;
	                {"LQ_PARCELA"	, 1					,NIL},;
	                {"LQ_FORMPG"	, "R$"				,NIL},;
	                {"LQ_EMISSAO"	, dDatabase			,NIL},;
	                {"LQ_NUMCFIS"	, ""				,NIL},;
	                {"LQ_IMPRIME"	, "1S        "		,NIL},;
	                {"LQ_VLRDEBI"	, 0					,NIL},;
	                {"LQ_HORA"		, ""				,NIL},;
	                {"LQ_NUMMOV"	,"1 "				,NIL},;         
	                {"LQ_ORIGEM"	, "V"				,NIL},;
	                {"LQ_VEICTIP"	, "3"				,NIL},;
	                {"LQ_VEIPESQ"	, VV9->VV9_NUMATE	,NIL},;
	                {"AUTRESERVA"   ,cAutReser			,NIL}}

	/////////////////////////////////////////////////////////////////////////////////
	// Carregar Vetor para Integracao SLR ( SL2 - ITENS )  N veiculos              //
	/////////////////////////////////////////////////////////////////////////////////
	For ni := 1 to len(aValVVA)
		VVA->(dbGoTo(aValVVA[ni,1]))
		FGX_VV1SB1("CHASSI", VVA->VVA_CHASSI , /* cMVMIL0010 */ , cGruVei )
		/////////////////////////////////////////////////////////////////////////////////
		// Atualizar SB0 - Precos por Produto ( Veiculo ) - Tabela OBRIGATORIA no Loja //
		/////////////////////////////////////////////////////////////////////////////////
		If !lMVLJCNVDA // Quando o parametro MV_LJCNVDA for .T. o LOJA utilizara a tabela de preco da totvs (DA0)
			SB0->(DbSetOrder(1))
			SB0->(MsSeek(xFilial("SB0")+SB1->B1_COD))
			RecLock("SB0",!SB0->(Found()))
				SB0->B0_FILIAL := xFilial("SB0")
				SB0->B0_COD    := SB1->B1_COD
				&("SB0->B0_PRV"+Alltrim(cMVTABPAD)) := aValVVA[ni,2]
			MsUnLock()
		EndIf
    	//
		aAdd(_aItem,{	{"LR_FILIAL" 	, xFilial("SL2")	,NIL},;
						{"LR_ITEM"      , strzero(ni,2)		,NIL},;
						{"LR_PRODUTO"	, SB1->B1_COD		,NIL},;
						{"LR_TABELA" 	, IIf( lMVLJCNVDA , "1" , Alltrim(cMVTABPAD) )	,NIL},;           
						{"LR_QUANT"  	, 1					,NIL},;
						{"LR_UM"     	, "UN"				,NIL},;
						{"LR_VRUNIT" 	, aValVVA[ni,2]		,NIL},;
						{"LR_DESC"   	, 0					,NIL},;
						{"LR_VALDESC"	, 0					,NIL},;
						{"LR_TES"		, VVA->VVA_CODTES	,NIL},;
						{"LR_DOC"    	, ""				,NIL},;
						{"LR_SERIE"  	, ""				,NIL},;
						{"LR_PDV"    	, "0001"			,NIL},;
						{"LR_DESCPRO"	, 0					,NIL},;
						{"LR_ENTREGA"	, "3"				,NIL},;
						{"LR_VEND"		, cVenVDi			,NIL}})
	Next
	VVA->(DbSetOrder(1))
	VVA->(MsSeek( xFilial("VVA") + VV0->VV0_NUMTRA ))
	FGX_VV1SB1("CHASSI", VVA->VVA_CHASSI , /* cMVMIL0010 */ , cGruVei )	
	/////////////////////////////////////////////////////////////////////////////////////
	// Ponto de Entrada que possibilita alterar os vetores: _aCab , _aItem , _aParcela //
	/////////////////////////////////////////////////////////////////////////////////////
	If ExistBlock("VXI02ILJ")
		ExecBlock("VXI02ILJ",.f.,.f.)
	EndIf
	////////////////////////////////////////////////
	// Salvar FUNNAME                             //
	////////////////////////////////////////////////
	cSFunName := FunName()
	////////////////////////////////////////////////
	// Mudar para Modulo 12 - SigaLoja            //
	////////////////////////////////////////////////
	nModulo := 12
	////////////////////////////////////////////////
	// Setar FunName LOJA701, para chamar LOJA701 //
	////////////////////////////////////////////////
	SetFunName("LOJA701") 
	MSExecAuto({|a,b,c,d,e,f,g,h| LOJA701(a,b,c,d,e,f,g,h)},.F.,3,"","",{},_aCab,_aItem,_aParcela)
	////////////////////////////////////////////////
	// Voltar FunName salvo                       //
	////////////////////////////////////////////////
	SetFunName(cSFunName)
	////////////////////////////////////////////////
	// Voltar Modulo 11 - Veiculos                //
	////////////////////////////////////////////////
	nModulo := 11
	If lMsErroAuto
		lRet := .f.
		MostraErro()
		DisarmTransaction()
		RollbackSxe()
	Else
		lRet := .t.
		If !Empty(SL1->L1_NUM)
			DbSelectArea("VV0")
			RecLock("VV0",.f.)
				VV0->VV0_PESQLJ := SL1->L1_NUM // Pedido de Venda no Loja
			MsUnLock()	
			oDlgLoja := MSDIALOG():New(0,0,129,360,STR0009,,,,130,,,,oMainWnd,.t.) // Documento gerado com sucesso!
			oDlgLoja:lEscClose := .F.
			TGroup():New( 02,04,42,180,,oDlgLoja,,,.t.,)
			@ 008,20 Say (STR0005) OF oDlgLoja PIXEL FONT oFont1 SIZE 150,20 // Orcamento de Venda Direta
			@ 025,67 Say VV0->VV0_PESQLJ OF oDlgLoja PIXEL FONT oFont2 SIZE 105,20
			DEFINE SBUTTON FROM 049,150 TYPE 1 ACTION oDlgLoja:End() ENABLE OF oDlgLoja
			ACTIVATE MSDIALOG oDlgLoja CENTER
	    Else
	    	lRet := .f. // Problema na geracao do Orcamento no Venda Direta
	    EndIf
	EndIf

Else // 2 - Finaliza Pedido no Loja

	////////////////////////////////////////////////////////////
	// Baixar Pedido/Venda no Loja                            //
	////////////////////////////////////////////////////////////
	A410BxGc(VV9->VV9_CODCLI,VV9->VV9_LOJA,VV0->VV0_NUMPED,VV0->VV0_NUMNFI,VV0->VV0_SERNFI)

	////////////////////////////////////////////////////////////
	// Venda Futura -> trocar produto para veiculo definitivo //
	////////////////////////////////////////////////////////////
	If VV0->VV0_VDAFUT == "1" // Venda Futura
		VVR->(dbSetOrder(2))
		VVR->(MsSeek(xFilial("VVR")+VVA->VVA_CODMAR+VVA->VVA_GRUMOD))
		FGX_VV1SB1("CHASSI", VVA->VVA_CHASSI , /* cMVMIL0010 */ , cGruVei )
		LjVDVProg(VV0->VV0_PESQLJ,'01',VVR->VVR_PROD,SB1->B1_COD,SB1->B1_LOCPAD) // Orcamento, Item, Produto Velho, Produto Novo, Local Padrao
	EndIf

EndIf

SA3->(DbSetOrder(1))
SA3->(MsSeek(xFilial("SA3")+VV0->VV0_CODVEN))

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ VXI02NAT  บ Autor ณ Andre Luis Almeida บ Data ณ  03/05/17  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna a Natureza por Tipo de Titulo                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VXI02NAT(cTpTitulo,cNatureza)
Local cRetNat := ""
//
Do Case

	Case cTpTitulo == "0" // 0 = Inicializando Natureza
		cRetNat := VV0->VV0_NATFIN
		If Empty(cRetNat)
			cRetNat := SA1->A1_NATUREZ
		EndIf

	Case cTpTitulo == "1A" // 1 = Financiamento - A = Titulo Normal
		If VV0->VV0_TIPFAT == "1" // Veiculo Usado
			cRetNat := GetNewPar("MV_NATFIVU",cNatureza)
		Else // Veiculo Novo
			cRetNat := GetNewPar("MV_NATFIVN",cNatureza)
		EndIf

	Case cTpTitulo == "1B" // 1 = Financiamento - B = Titulo Retorno
		If VV0->VV0_TIPFAT == "1" // Veiculo Usado
			cRetNat := GetNewPar("MV_NATRFVU",cNatureza)
		Else // Veiculo Novo
			cRetNat := GetNewPar("MV_NATRFVN",cNatureza)
		EndIf

	Case cTpTitulo == "1C" // 1 = Financiamento - C = Titulo TAC
		If VV0->VV0_TIPFAT == "1" // Veiculo Usado
			cRetNat := GetNewPar("MV_NATTCVU",cNatureza)
		Else // Veiculo Novo
			cRetNat := GetNewPar("MV_NATTCVN",cNatureza)
		EndIf
		
	Case cTpTitulo == "1D" // 1 = Financiamento - D = Titulo Plus
		If VV0->VV0_TIPFAT == "1" // Veiculo Usado
			cRetNat := GetNewPar("MV_NATCFVU",cNatureza)
		Else // Veiculo Novo
			cRetNat := GetNewPar("MV_NATCFVN",cNatureza)
		EndIf		

	Case cTpTitulo == "2" // 2 = Financiamento Proprio
		If VV0->VV0_TIPFAT == "1" // Veiculo Usado
			cRetNat := GetNewPar("MV_NATFPRU",cNatureza)
		Else // Veiculo Novo
			cRetNat := GetNewPar("MV_NATFPRN",cNatureza)
		EndIf

	Case cTpTitulo == "3" // 3 = Consorcio
		If VV0->VV0_TIPFAT == "1" // Veiculo Usado
			cRetNat := GetNewPar("MV_NATCONU",cNatureza)
		Else // Veiculo Novo
			cRetNat := GetNewPar("MV_NATCONN",cNatureza)
		EndIf

	Case cTpTitulo == "4" // 4 = Veiculo Usado na Troca
		If VV0->VV0_TIPFAT == "1" // Veiculo Usado
			cRetNat := GetNewPar("MV_NATVEIU",cNatureza)
		Else // Veiculo Novo
			cRetNat := GetNewPar("MV_NATVEIN",cNatureza)
		EndIf

	Case cTpTitulo == "5" // 5 = Entradas
		If VV0->VV0_TIPFAT == "1" // Veiculo Usado
			cRetNat := GetNewPar("MV_NATENTU",cNatureza)
		Else // Veiculo Novo
			cRetNat := GetNewPar("MV_NATENTN",cNatureza)
		EndIf
	
	Case cTpTitulo == "6R" // 6 = Finame - R = Receber
		If VV0->VV0_TIPFAT == "1" // Veiculo Usado
			cRetNat := GetNewPar("MV_NATFINU",cNatureza)
		Else // Veiculo Novo
			cRetNat := GetNewPar("MV_NATFINN",cNatureza)
		EndIf
	
	Case cTpTitulo == "6PF" // 6 = Finame - P = Pagar - F = Flat
		// Novos parโmetros de Finame a Pagar MV_NATFIPU e MV_NATFIPN
		// Caso nใo existam ou sejam vazios, manter o legado: MV_NATFINU e MV_NATFINN
		If VV0->VV0_TIPFAT == "1" // Veiculo Usado
			cRetNat := GetNewPar("MV_NATFIPU","")
			If Empty(cRetNat)
				cRetNat := GetNewPar("MV_NATFINU",cNatureza)
			EndIf
		Else // Veiculo Novo
			cRetNat := GetNewPar("MV_NATFIPN","")
			If Empty(cRetNat)
				cRetNat := GetNewPar("MV_NATFINN",cNatureza)
			EndIf
		EndIf

	Case cTpTitulo == "6PR" // 6 = Finame - P = Pagar - R = Risco
		// Novos parโmetros de Finame a Pagar MV_NATFIRU e MV_NATFIRN
		// Caso nใo exista ou esteja vazio, primeiro verifica o informado no Finame FLAT
		// Se nใo, mat้m o legado: MV_NATFINU e MV_NATFINN
		If VV0->VV0_TIPFAT == "1" // Veiculo Usado
			cRetNat := GetNewPar("MV_NATFIRU","")
			If Empty(cRetNat)
				cRetNat := GetNewPar("MV_NATFIPU",cNatureza)
			EndIf		
			If Empty(cRetNat)
				cRetNat := GetNewPar("MV_NATFINU",cNatureza)
			EndIf
		Else // Veiculo Novo
			cRetNat := GetNewPar("MV_NATFIRN","")
			If Empty(cRetNat)
				cRetNat := GetNewPar("MV_NATFIPN",cNatureza)
			EndIf
			If Empty(cRetNat)
				cRetNat := GetNewPar("MV_NATFINN",cNatureza)
			EndIf
		EndIf

	Case cTpTitulo == "VZ7" // VZ7 = Titulos da Venda Agregada
		If VV0->VV0_TIPFAT == "1" // Veiculo Usado
			cRetNat := GetNewPar("MV_NATVZ7U",cNatureza)
		Else // Veiculo Novo
			cRetNat := GetNewPar("MV_NATVZ7N",cNatureza)
		EndIf

EndCase
//
If cTpTitulo <> "0" // Diferente de 0 - Inicializando Natureza
	If Empty(cRetNat)
		cRetNat := cNatureza // Retornar Natureza Default
	EndIf
	If Empty(cRetNat)
		cRetNat := NIL // Se NAO existir a Natureza Default, passar NIL na integracao do FINA040/FINA050
	EndIf
EndIf
//
Return cRetNat

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ VXI02VLD  บ Autor ณ Andre Luis Almeida บ Data ณ  10/11/17  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao antes de chamar os ExecAutos de NF e Titulos     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VXI02VLD(nRecSA1)
Local xAux
Local lRet      := .t.
Local cQuery    := ""
Local cSQLAlias := "SQLVS9VSA"
Local ni        := 0
Local aVetNat   := {}
Local cNCCNCF   := GetNewPar("MV_MIL0057","2") // Titulo de Troco NCC (1=SE1) ou NCF (2=SE2) + Codigo da Natureza do Titulo
Local cFilSX5   := xFilial("SX5")
Default nRecSA1 := SA1->(RecNo())
//
aVetNat := {"MV_NATFIVU","MV_NATFIVN",;
			"MV_NATRFVU","MV_NATRFVN",;
			"MV_NATTCVU","MV_NATTCVN",;
			"MV_NATCFVU","MV_NATCFVN",;
			"MV_NATFPRU","MV_NATFPRN",;
			"MV_NATCONU","MV_NATCONN",;
			"MV_NATVEIU","MV_NATVEIN",;
			"MV_NATENTU","MV_NATENTN",;
			"MV_NATFINU","MV_NATFINN",;
			"MV_NATVZ7U","MV_NATVZ7N"}
For ni := 1 to len(aVetNat)
	xAux := GetNewPar(aVetNat[ni],"")
	If ValType(xAux) <> "C" // Validar se o SX6 das NATUREZAS nใo sใo do Tipo CARACTER 
		MsgStop(STR0016+CHR(13)+CHR(10)+CHR(13)+CHR(10)+aVetNat[ni],STR0002) // Impossivel continuar! Natureza invalida! / Atencao
		lRet :=  .f.
		Exit
	EndIf
Next
//
If lRet
 	// Caso tenha TROCO - verificar se o Cliente ้ encontrado como Fornecedor
	If VV0->VV0_VALTRO > 0
		If left(cNCCNCF,1) <> "1" // Gerar Contas a Pagar ( SE2 )
			If !FGX_SA1SA2(VV9->VV9_CODCLI,VV9->VV9_LOJA,.t.) // Posiciona ou Cria SA2 (Fornecedor) atraves do SA1 (Cliente)
				MsgStop(STR0003+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0004+" "+VV9->VV9_CODCLI+"-"+VV9->VV9_LOJA+" "+left(SA1->A1_NOME,20),STR0002) // Impossivel criar o Cliente como Fornecedor! / Favor verificar o cadastro do Cliente / Atencao
				lRet :=  .f.
			EndIf
		EndIf
	EndIf
EndIf
//
If lRet
 	// Caso tenha FINAME - verificar se o Cliente da Empresa Finame ้ encontrado como Fornecedor
	If VV0->VV0_VFFINA > 0 .or. VV0->VV0_VRFINA > 0 // Valor Flat Finame ou Valor Risco Finame
		If !Empty(VV0->VV0_CLFINA+VV0->VV0_LJFINA)
			If !FGX_SA1SA2(VV0->VV0_CLFINA,VV0->VV0_LJFINA,.t.) // Posiciona ou Cria SA2 (Fornecedor) atraves do SA1 (Cliente)
				MsgStop(STR0003+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0004+" "+VV0->VV0_CLFINA+"-"+VV0->VV0_LJFINA+" "+left(SA1->A1_NOME,20),STR0002) // Impossivel criar o Cliente como Fornecedor! / Favor verificar o cadastro do Cliente / Atencao
				lRet := .f.
			EndIf
		EndIf
	EndIf
EndIf
If lRet
	cQuery := "SELECT VS9.VS9_TIPPAG , VSA.VSA_CODCLI , VSA.VSA_LOJA , VSA.VSA_TIPO "
	cQuery += " FROM "+RetSQLName("VS9")+" VS9 "
	cQuery += " JOIN "+RetSQLName("VSA")+" VSA ON ( VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG=VS9.VS9_TIPPAG AND VSA.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VS9.VS9_FILIAL='"+xFilial("VS9")+"'"
	cQuery +=  " AND VS9.VS9_NUMIDE='"+VV9->VV9_NUMATE+"'"
	cQuery +=  " AND VS9.VS9_TIPOPE='V'"
	cQuery +=  " AND VS9.VS9_PARCEL=' '"
	cQuery +=  " AND VS9.VS9_VALPAG > 0 "
	cQuery +=  " AND VS9.D_E_L_E_T_=' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->( Eof() )
		/////////////////////////////////////////////////////////////////
		// Verificar/Incluir o Tipo do Titulo na tabela 24 e 05 do SX5 //
		/////////////////////////////////////////////////////////////////
		DbSelectArea("SX5")
		dbSetOrder(1)
		If !MsSeek(cFilSX5+"24"+(cSQLAlias)->( VS9_TIPPAG )) // Tabela 24 - Loja (SL4)
	  	    RecLock("SX5",.t.)
			SX5->X5_FILIAL := cFilSX5
			SX5->X5_TABELA := "24"
	    	SX5->X5_CHAVE  := (cSQLAlias)->( VS9_TIPPAG )
		    SX5->X5_DESCRI := (cSQLAlias)->( VS9_TIPPAG )
	    	MsUnlock()
		EndIf
		If !MsSeek(cFilSX5+"05"+(cSQLAlias)->( VS9_TIPPAG )) // Tabela 05 - Faturamento/Financeiro (SE1/SE2)
	  	    RecLock("SX5",.t.)
			SX5->X5_FILIAL := cFilSX5
			SX5->X5_TABELA := "05"
	    	SX5->X5_CHAVE  := (cSQLAlias)->( VS9_TIPPAG )
		    SX5->X5_DESCRI := (cSQLAlias)->( VS9_TIPPAG )
	    	MsUnlock()
		EndIf
		If (cSQLAlias)->( VSA_TIPO ) == "1" // Financiamento / Leasing
			// Necessario ter Codigo do Cliente da Financeira
			If Empty((cSQLAlias)->( VSA_CODCLI ))
				MsgStop(STR0013+" ("+(cSQLAlias)->( VS9_TIPPAG )+")",STR0002) // Nao existe Cliente/Loja relacionado ao Tipo de Pagamento de Entrada / Atencao
				lRet := .f.
				Exit
			Else
			 	// Caso tenha FINANCIAMENTO/LEASING - verificar se o Cliente da Financiadora ้ encontrado como Fornecedor
				If !FGX_SA1SA2((cSQLAlias)->( VSA_CODCLI ),(cSQLAlias)->( VSA_LOJA ),.t.) // Posiciona ou Cria SA2 (Fornecedor) atraves do SA1 (Cliente)
					MsgStop(STR0003+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0004+" "+(cSQLAlias)->( VSA_CODCLI )+"-"+(cSQLAlias)->( VSA_LOJA )+" "+left(SA1->A1_NOME,20),STR0002) // Impossivel criar o Cliente como Fornecedor! / Favor verificar o cadastro do Cliente / Atencao
					lRet := .f.
					Exit
				EndIf
			EndIf
		EndIf
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
EndIf
If nRecSA1 > 0
	SA1->(DbGoTo(nRecSA1))
EndIf
Return lRet


Static Function VXI002CondVei(cCondPag)
	Local cAuxCondPag

	SE4->(dbSetOrder(1))
	If SE4->(MsSeek(xFilial("SE4") + cCondPag )) .AND. SE4->E4_TIPO $ "9/A"
		cAuxCondPag := cCondPag 
	Else
		cAuxCondPag := RetCondVei()
	EndIf
Return cAuxCondPag

// Monta String com os campos e valores existentes no vetor de integra็ใo
Static Function VXI020011_LogArrayExecAuto(aParExecAuto)
	Local nPosArray
	Local cLog := ""

	For nPosArray := 1 to Len(aParExecAuto)
		cLog += PadR(aParExecAuto[nPosArray,1],12) + " -> " + AllTrim(cValToChar(aParExecAuto[nPosArray,2])) + CRLF
	Next nPosArray

Return cLog