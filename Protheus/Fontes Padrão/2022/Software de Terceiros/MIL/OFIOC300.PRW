// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 8      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "tbiconn.ch"
#Include "Protheus.ch"
#Include "OFIOC300.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOC300 ³ Autor ³  Luis Delorme         ³ Data ³ 27/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Criacao dos PAINEIS OFF-LINE                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC300(aEmpresa, aDatas)
#IFDEF TOP
Local lAutomatico
Local i, nEmp, nNeg
Private cEmpr := "  "
Private cFil  := "  "
Private nTXTVdaNG:= nTXTLucNG:= 0
Private dDataIni, dDataFim
Private aVetRes:= {}
Private nPis
Private nCof
Private aTXTCli := {} //vetor de Clientes para gerar TXT
Private aTXTCliA:= {} //vetor de Clientes para gerar TXT Mes a Mes
Private aTXTIte := {} //vetor de Itens para gerar TXT
Private aTXTIteA:= {} //vetor de Itens para gerar TXT Mes a Mes
Private aTXTMes := {} //vetor de Meses para gerar TXT
Private nTXTVda := nTXTLuc := nTXTAux1 := nTXTAux2 := 0
Private ni := 0 , cCliente , cGrupo , nMes := 0 , nAno := 0 , cMes := ""
Private nVfattot := 0 , nVtotimp := 0 , nVicmven := 0 , nVpisven := 0 , nVcofven := 0 , nVtotcus := 0 , nVjurest := 0 , nVlucbru := 0 , nVtotdes := 0 , nVcomvde := 0 , nVluclq1 := 0 , nVdesfix := 0 , nVdesadm := 0 , nVluclq2 := 0, nVdescon := 0
Private nPvalvda := 0 , nPtotimp := 0 , nPvalicm := 0 , nPvalpis := 0 , nPvalcof := 0 , nPcustot := 0 , nPjurest := 0 , nPlucbru := 0 , nPdesvar := 0 , nPcomven := 0 , nPlucliq := 0 , nPdesfix := 0 , nPdesdep := 0 , nPresfin := 0, nPdescon := 0
Private nSvalser := 0 , nStotimp := 0 , nSvaliss := 0 , nSvalpis := 0 , nSvalcof := 0 , nScusser := 0 , nSlucbru := 0 , nSdesvar := 0 , nScomven := 0 , nSlucliq := 0 , nSdesfix := 0 , nSdesadm := 0 , nSresfin := 0 , nSdescon := 0
// Vetores que poderao ser usados posteriormente (data atual 04/07/2006)
Private aDpto     := {} //vetor de Departamentos no Balcao/Oficina
Private aTotal    := {} //vetor de Totais
Private aGrpPag   := {} //vetor de Grupos de Condicoes de Pagamento
Private aTotPag   := {} //vetor de Condicoes de Pagamento por Vendedor
Private aPecSrvOfi:= {} //vetor de Pecas Balcao, Pecas Oficina e Servicos Oficina
Private aConPagNF := {} //vetor de NF's de Condicoes de Pagamento
Private aCCVend   := {} //vetor de Vendas por Centro de Custo / Vendedor
Private aTotCCV   := {} //vetor de Totais de Vendas por Centro de Custo
Private aTotCon   := {}
// Vetores de Pecas
Private aAnaPec   := {} //vetor analitico de Pecas
//  1o Elemento - Empresa
//  2o Elemento - Filial
//  3o Elemento - Docto
//  4o Elemento - Serie
//  5o Elemento - Tipo -> PB-pecas balcao / PO - pecas oficina
//  6o Elemento - Cliente
//  7o Elemento - Grupo
//  8o Elemento - Codigo Produto
//  9o Elemento - Descricao Produto
// 10o Elemento - Valor Venda
// 11o Elemento - Valor Imposto
// 12o Elemento - Valor Custo
// 13o Elemento - Data
Private aNumPec   := {} //vetor de Pecas
Private aTotPec   := {} //vetor do Total de Pecas
Private aGrpPec   := {} //vetor de Grupos de Pecas
Private aGrpPBO   := {} //vetor de Grupos de Pecas (Balcao ou Oficina)
// Vetores de Servicos
Private aAnaSrv   := {} //vetor analitico de Servicos
//  1o Elemento - Empresa
//  2o Elemento - Filial
//  3o Elemento - Docto
//  4o Elemento - Serie
//  5o Elemento - Tipo -> SV-servicos
//  6o Elemento - Cliente
//  7o Elemento - Grupo
//  8o Elemento - Codigo Produto
//  9o Elemento - Descricao Produto
// 10o Elemento - Valor Venda
// 11o Elemento - Valor Imposto
// 12o Elemento - Valor Custo
// 13o Elemento - Data
Private aNumSrv   := {} //vetor de Servicos
Private aTotSrv   := {} //vetor do Total de Servicos
Private aGrpSrv   := {} //vetor de Grupos de Servicos
// Vetores de Veiculos
Private aAnaVei   := {} //vetor analitico de Veiculos
//  1o Elemento - Empresa
//  2o Elemento - Filial
//  3o Elemento - Docto
//  4o Elemento - Serie
//  5o Elemento - Tipo -> VN-veiculos novos / VU-veiculos usados / VF - veiculos faturamento direto
//  6o Elemento - Cliente
//  7o Elemento - Grupo
//  8o Elemento - Codigo Produto
//  9o Elemento - Descricao Produto
// 10o Elemento - Valor Venda
// 11o Elemento - Valor Imposto
// 12o Elemento - Valor Custo
// 13o Elemento - Data
Private aNumVei   := {} //vetor de Veiculos
Private aTotVei   := {} //vetor Total de Veiculos por tipo de tempo
Private aGrpVei   := {} //vetor Grupos de Veiculos
// Vetores de Outras Vendas
Private aAnaOOpe  := {} //vetor analitico de Outras Vendas
//  1o Elemento - Empresa
//  2o Elemento - Filial
//  3o Elemento - Docto
//  4o Elemento - Serie
//  5o Elemento - Tipo -> OV-outras vendas
//  6o Elemento - Cliente
//  7o Elemento - Grupo
//  8o Elemento - Codigo Produto
//  9o Elemento - Descricao Produto
// 10o Elemento - Valor Venda
// 11o Elemento - Valor Imposto
// 12o Elemento - Valor Custo
// 13o Elemento - Data
Private aTotOOpe  := {} //vetor de Outras Vendas
Private aOOpeSrv  := {} //vetor de Outras Vendas - Servicos
Private aOOpeOut  := {} //vetor de Outras Vendas - Outros
// Vetores de Devolucoes
Private aAnaDev   := {} //vetor analitico de Devolucoes
//  1o Elemento - Empresa
//  2o Elemento - Filial
//  3o Elemento - Docto
//  4o Elemento - Serie
//  5o Elemento - Tipo -> DV-devolucoes
//  6o Elemento - Cliente
//  7o Elemento - Grupo
//  8o Elemento - Codigo Produto
//  9o Elemento - Descricao Produto
// 10o Elemento - Valor Venda
// 11o Elemento - Valor Imposto
// 12o Elemento - Valor Custo
// 13o Elemento - Data
Private aNumDev   := {} //vetor de Devolucoes
Private aTotDev   := {} //vetor do Total de Devolucoes
// Vetores de Despesas Acessorias
Private aAnaAce   := {} //vetor analitico de Despesas Acessorias
//  1o Elemento - Empresa
//  2o Elemento - Filial
//  3o Elemento - Docto
//  4o Elemento - Serie
//  5o Elemento - Tipo -> DA-despesas acessorias
//  6o Elemento - Cliente
//  7o Elemento - Grupo
//  8o Elemento - Codigo Produto
//  9o Elemento - Descricao Produto
// 10o Elemento - Valor Venda
// 11o Elemento - Valor Imposto
// 12o Elemento - Valor Custo
// 13o Elemento - Data
Private aDesAce   := {} //vetor de Despesas Acessorias
// Vetores de Ativo Imobilizado
Private aAnaAtiMob:= {} //vetor analitico do Ativo Imobilizado
//  1o Elemento - Empresa
//  2o Elemento - Filial
//  3o Elemento - Docto
//  4o Elemento - Serie
//  5o Elemento - Tipo -> AI-ativo imobilizado
//  6o Elemento - Cliente
//  7o Elemento - Grupo
//  8o Elemento - Codigo Produto
//  9o Elemento - Descricao Produto
// 10o Elemento - Valor Venda
// 11o Elemento - Valor Imposto
// 12o Elemento - Valor Custo
// 13o Elemento - Data
Private aTotAtiMob:= {} //vetor de Total de Ativo Imobilizado
Private aNumAtiMob:= {} //vetor de Ativo Imobilizado
Private aIcmRet   := {} //vetor de ICMS Retido

// ENTRADAS (PAGAMENTO)
aNumEnt  := {} //zera vetor de Entradas
aGrpEnt  := {} //zera vetor de Grupos de Entradas
aEntrad  := {} //zera vetor de Total de Entrada por Tipo de Pagamento
aTotEnt  := {} //zera vetor de Total de Entrada
aAdd(aTotEnt,{ 0 })
aAdd(aGrpEnt,{ "V" , left(STR0001+repl(".",37),37) , 0 })   // Veiculos
aAdd(aGrpEnt,{ "O" , left(STR0002+repl(".",37),37) , 0 })   // Oficina
aAdd(aGrpEnt,{ "B" , left(STR0003+repl(".",37),37) , 0 })   // Balcao

// DESPESAS ACESSORIAS
aDesAce  := {} //zera vetor de Despesas Acessorias
aAdd(aDesAce,{ "T" , 0 , 0 , 0 })
aAdd(aDesAce,{ left(STR0001+repl(".",22),22) , 0 , 0 , 0 })
aAdd(aDesAce,{ left(STR0003+repl(".",22),22) , 0 , 0 , 0 })
aAdd(aDesAce,{ left(STR0002+repl(".",22),22) , 0 , 0 , 0 })

// ICMS RETIDO
aAdd(aIcmRet,{ "T" , 0 , 0 , 0 }) 
aAdd(aIcmRet,{ "V" , 0 , 0 , 0 }) 
aAdd(aIcmRet,{ "B" , 0 , 0 , 0 }) 
aAdd(aIcmRet,{ "O" , 0 , 0 , 0 }) 

//
// PREPARA TABELAS PARA WORKFLOW
//
	If Type("cFOPENed") == "U"
		Set Deleted On
		Set Date British
		Set EPOCH to 1950
		__TTSInUse := .f.
		__TTSPush  := {}
		__cLogSiga := space(10)
		cEmpr := aEmpresa[1,1]
		cFil  := aEmpresa[1,2]
		FS_OPENARQ()
	Else
		cEmpr := SM0->M0_CODIGO
		cFil  := SM0->M0_CODFIL
	EndIf

	nPis := ( GetMv("MV_TXPIS")   / 100 )
	nCof := ( GetMv("MV_TXCOFIN") / 100 )

	If ValType(aDatas) == "A"
		dDataIni := aDatas[1]
		dDataFim := aDatas[2]
	Else
		dDataIni := stod(substr(dtos(date()),1,6)+"01") // dDataBase
		dDataFim := date() // dDataBase
	endif
	Mv_Par01 :=dDataIni
	Mv_Par02 :=dDataFim
	Mv_Par03 := 1 // 1-Moeda Corrente
	Mv_Par04 := 3 // Tipo de Relatorio: 1-Resumido / 2-Sintetico / 3-Analitico
	Mv_Par05 := 1 // Totaliza por: 1-Grupo / 2-Cliente
	Mv_Par06 := 1 // Resume Vendas por: 1-Nao Mostrar / 2-CPgto.Vend. / 3-CPgto.CCusto / 4-CCusto.Vend.
	Mv_Par07 := 2 // Totais Entrada Pgto.: 1-Sim / 2-Nao
	Mv_Par08 := 2 // Mostrar Custo por: 1-Gerencial / 2-Contabil
	Mv_Par09 := 1 // Deduz Devolucao: 1-Sim / 2-Nao
	//
	DBSelectArea("VJI")
	DBSetOrder(2)
	dbSeek(xFilial("VJI")+dtos(Mv_Par01),.t.)
	while VJI_DATVEN <= Mv_Par02 .and. !EOF()
		reclock("VJI",.f.)
		VJI_FILIAL := "ZZ"
		msunlock()
		DBSkip()
	enddo
	
	DBSelectArea("VJC")
	DBSetOrder(2)
	dbSeek(xFilial("VJC")+dtos(Mv_Par01),.t.)
	while VJC_DATVEN <= Mv_Par02 .and. !EOF()
		reclock("VJC",.f.)
		VJC_FILIAL := "ZZ"
		msunlock()
		DBSkip()
	enddo
	
	aTXTCli := {} //vetor de Clientes para gerar TXT
	aTXTCliA:= {} //vetor de Clientes para gerar TXT Mes a Mes
	aTXTIte := {} //vetor de Itens para gerar TXT
	aTXTIteA:= {} //vetor de Itens para gerar TXT Mes a Mes
	aTXTMes := {} //vetor de Meses para gerar TXT
	nTXTVda := nTXTLuc := nTXTAux1 := nTXTAux2 := 0
	ni := 0
	cCliente := ""
	cGrupo := ""
	nMes := 0
	nAno := 0
	cMes := ""
	nVfattot := nVtotimp :=  nVicmven :=  nVpisven :=  nVcofven :=  nVtotcus :=  nVjurest :=  nVlucbru := 0
	nVtotdes := nVcomvde :=  nVluclq1 :=  nVdesfix :=  nVdesadm :=  nVluclq2 :=  nVdescon := 0
	nPvalvda :=  nPtotimp :=  nPvalicm :=  nPvalpis :=  nPvalcof :=  nPcustot :=  nPjurest := 0
	nPlucbru :=  nPdesvar :=  nPcomven :=  nPlucliq :=  nPdesfix :=  nPdesdep :=  nPresfin := 0
	nPdescon := nSvalser :=  nStotimp :=  nSvaliss :=  nSvalpis :=  nSvalcof :=  nScusser :=  0
	nSlucbru :=  nSdesvar :=  nScomven :=  nSlucliq :=  nSdesfix :=  nSdesadm :=  nSresfin :=  nSdescon := 0
	
	// Vetores que poderao ser usados posteriormente (data atual 04/07/2006)
	aDpto     := {} //vetor de Departamentos no Balcao/Oficina
	aTotal    := {} //vetor de Totais
	aGrpPag   := {} //vetor de Grupos de Condicoes de Pagamento
	aTotPag   := {} //vetor de Condicoes de Pagamento por Vendedor
	aPecSrvOfi:= {} //vetor de Pecas Balcao, Pecas Oficina e Servicos Oficina
	aConPagNF := {} //vetor de NF's de Condicoes de Pagamento
	aCCVend   := {} //vetor de Vendas por Centro de Custo / Vendedor
	aTotCCV   := {} //vetor de Totais de Vendas por Centro de Custo
	aTotCon   := {}
	// Vetores de Pecas
	aAnaPec   := {} //vetor analitico de Pecas
	aNumPec   := {} //vetor de Pecas
	aTotPec   := {} //vetor do Total de Pecas
	aGrpPec   := {} //vetor de Grupos de Pecas
	aGrpPBO   := {} //vetor de Grupos de Pecas (Balcao ou Oficina)
	// Vetores de Servicos
	aAnaSrv   := {} //vetor analitico de Servicos
	aNumSrv   := {} //vetor de Servicos
	aTotSrv   := {} //vetor do Total de Servicos
	aGrpSrv   := {} //vetor de Grupos de Servicos
	// Vetores de Veiculos
	aAnaVei   := {} //vetor analitico de Veiculos
	aNumVei   := {} //vetor de Veiculos
	aTotVei   := {} //vetor Total de Veiculos por tipo de tempo
	aGrpVei   := {} //vetor Grupos de Veiculos
	// Vetores de Outras Vendas
	aAnaOOpe  := {} //vetor analitico de Outras Vendas
	aTotOOpe  := {} //vetor de Outras Vendas
	aOOpeSrv  := {} //vetor de Outras Vendas - Servicos
	aOOpeOut  := {} //vetor de Outras Vendas - Outros
	// Vetores de Devolucoes
	aAnaDev   := {} //vetor analitico de Devolucoes
	aNumDev   := {} //vetor de Devolucoes
	aTotDev   := {} //vetor do Total de Devolucoes
	// Vetores de Despesas Acessorias
	aAnaAce   := {} //vetor analitico de Despesas Acessorias
	aDesAce   := {} //vetor de Despesas Acessorias
	// Vetores de Ativo Imobilizado
	aAnaAtiMob:= {} //vetor analitico do Ativo Imobilizado
	aTotAtiMob:= {} //vetor de Total de Ativo Imobilizado
	aNumAtiMob:= {} //vetor de Ativo Imobilizado
	//
	aTotal:= {}
	aTotAtiMob := {}
	aTotCon := {}
	aAdd(aTotal,{ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })
	aAdd(aTotAtiMob,{ "T" , "T" , 0 , 0 , 0 , 0 , 0 , 0 })
	aAdd(aTotAtiMob,{ "V" , left(STR0001+repl(".",22),22) , 0 , 0 , 0 , 0 , 0 , 0 })
	aAdd(aTotAtiMob,{ "O" , left(STR0004+repl(".",22),22) , 0 , 0 , 0 , 0 , 0 , 0 })
	aAdd(aTotCon,{ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0, 0 , 0 , 0 })

	// ENTRADAS (PAGAMENTO)
	aNumEnt  := {} //zera vetor de Entradas
	aGrpEnt  := {} //zera vetor de Grupos de Entradas
	aEntrad  := {} //zera vetor de Total de Entrada por Tipo de Pagamento
	aTotEnt  := {} //zera vetor de Total de Entrada
	aAdd(aTotEnt,{ 0 })
	aAdd(aGrpEnt,{ "V" , left(STR0001+repl(".",37),37) , 0 })   // Veiculos
	aAdd(aGrpEnt,{ "O" , left(STR0002+repl(".",37),37) , 0 })   // Oficina
	aAdd(aGrpEnt,{ "B" , left(STR0003+repl(".",37),37) , 0 })   // Balcao
	
	// DESPESAS ACESSORIAS
	aDesAce  := {} //zera vetor de Despesas Acessorias
	aAdd(aDesAce,{ "T" , 0 , 0 , 0 })
	aAdd(aDesAce,{ left(STR0001+repl(".",22),22) , 0 , 0 , 0 })
	aAdd(aDesAce,{ left(STR0003+repl(".",22),22) , 0 , 0 , 0 })
	aAdd(aDesAce,{ left(STR0002+repl(".",22),22) , 0 , 0 , 0 })
    
	// Chamadas para levantamento de valores no OFIOR250 //
	OR250CHFUN("FS_M_OR25B()") // Levantamento de Veiculos
	OR250CHFUN("FS_M_OR25C()") // Levantamento de Pecas
	OR250CHFUN("FS_M_OR25D()") // Levantamento de Servicos
	OR250CHFUN("FS_M_OR250()") // Demais Levantamentos

	////////////////////////////// PECAS
	aSort(aAnaPec,,,{|x,z| x[3]+x[4] < z[3]+z[4] })
	cNFAnt := ""
	aPecNeg := {}
	DbSelectArea("VJI")
	for i := 1 to Len(aAnaPec)
		lFound := DBSeek("ZZ")
		RecLock("VJI",!lFound)
		VJI_FILIAL   := aAnaPec[i,2]
		VJI_NUMNFI   := aAnaPec[i,3]
		VJI_SERNFI   := aAnaPec[i,4]
		VJI_TIPO     := aAnaPec[i,5]
		VJI_GRUITE   := aAnaPec[i,7]
		VJI_CODITE   := aAnaPec[i,8]
		VJI_DATVEN   := aAnaPec[i,13]
		VJI_PERIOD   := "D"             
		VJI_VALVDA   := round(aAnaPec[i,10],2)
		VJI_VALIMP   := round(aAnaPec[i,11],2)
		VJI_VALCUS   := round(aAnaPec[i,12],2)
		VJI_QUANT    := iif(round(aAnaPec[i,10],2) < 0,-aAnaPec[i,14],aAnaPec[i,14])
		MsUnlock()
	next
	DbSelectArea("VJC")       
	for i := 1 to Len(aAnaPec)
		if aAnaPec[i,10] >= 0
			if cNFAnt <> aAnaPec[i,3]+aAnaPec[i,4] 
				lFound := DBSeek("ZZ")
				RecLock("VJC",!lFound)
				VJC_FILIAL  := aAnaPec[i,02]
				VJC_NUMNFI  := aAnaPec[i,03]
				VJC_SERNFI  := aAnaPec[i,04]
				VJC_TIPO    := aAnaPec[i,05]
				VJC_PERIOD  := "D"
				VJC_DATVEN  := aAnaPec[i,13]
				VJC_CLIFAT  := Left(aAnaPec[i,06],6)
				VJC_LOJA    := Subs(aAnaPec[i,06],7,2)				
				VJC_VALVDA  := round(aAnaPec[i,10],2)
				VJC_VALIMP  := round(aAnaPec[i,11],2)
				VJC_VALCUS  := round(aAnaPec[i,12],2)
				MsUnlock()         
			else
				RecLock("VJC",.f.)
				VJC_VALVDA  += round(aAnaPec[i,10],2)
				VJC_VALIMP  += round(aAnaPec[i,11],2)
				VJC_VALCUS  += round(aAnaPec[i,12],2)
				MsUnlock()
			endif
		else
			nPos := aScan(aPecNeg,{|x| x[2]+x[3]+x[4] == aAnaPec[i,02]+aAnaPec[i,03]+aAnaPec[i,04]})
			if nPos == 0
				aAdd(aPecNeg,{aAnaPec[i,02],aAnaPec[i,03],aAnaPec[i,04],aAnaPec[i,05],;
				     "D",aAnaPec[i,13],Left(aAnaPec[i,06],8),round(aAnaPec[i,10],2),;
				     round(aAnaPec[i,11],2),round(aAnaPec[i,12],2)})
			else
				aPecNeg[nPos,8]  += round(aAnaPec[i,10],2)
				aPecNeg[nPos,9]  += round(aAnaPec[i,11],2)
				aPecNeg[nPos,10]  += round(aAnaPec[i,12],2)
			endif
		endif
		cNFAnt := aAnaPec[i,3]+aAnaPec[i,4]
	next
	for nNeg := 1 to Len(aPecNeg)
		lFound := DBSeek("ZZ")
		RecLock("VJC",!lFound)
		VJC_FILIAL  := aPecNeg[nNeg,01]
		VJC_NUMNFI  := aPecNeg[nNeg,02]
		VJC_SERNFI  := aPecNeg[nNeg,03]
		VJC_TIPO    := aPecNeg[nNeg,04]
		VJC_PERIOD  := aPecNeg[nNeg,05]
		VJC_DATVEN  := aPecNeg[nNeg,06]
		VJC_CLIFAT  := Left(aPecNeg[nNeg,07],6)
		VJC_LOJA    := Subs(aPecNeg[nNeg,07],7,2)		
		VJC_VALVDA  := aPecNeg[nNeg,08]
		VJC_VALIMP  := aPecNeg[nNeg,09]
		VJC_VALCUS  := aPecNeg[nNeg,10]
		MsUnlock()         
	next
	
	////////////////////////////// SERVICOS
	aSort(aAnaSrv,,,{|x,z| x[3]+x[4] < z[3]+z[4] })
	cNFAnt := ""
   DBSelectArea("VJI")
	for i := 1 to Len(aAnaSrv)
		lFound := DBSeek("ZZ")
		RecLock("VJI",!lFound)
		VJI_FILIAL  := aAnaSrv[i,2]
		VJI_NUMNFI   := aAnaSrv[i,3]
		VJI_SERNFI   := aAnaSrv[i,4]
		VJI_TIPO    := aAnaSrv[i,5]
		VJI_GRUITE   := aAnaSrv[i,7]
		VJI_PERIOD   := "D"             
		VJI_CODITE  := aAnaSrv[i,8]
		VJI_DATVEN   := aAnaSrv[i,13]
		VJI_VALVDA  := round(aAnaSrv[i,10],2)
		VJI_VALIMP  := round(aAnaSrv[i,11],2)
		VJI_VALCUS  := round(aAnaSrv[i,12],2)
		MsUnlock()
	next
	DbSelectArea("VJC")
	for i := 1 to Len(aAnaSrv)
		if cNFAnt <> aAnaSrv[i,3]+aAnaSrv[i,4]
			lFound := DBSeek("ZZ")
			RecLock("VJC",!lFound)
			VJC_FILIAL  := aAnaSrv[i,02]
			VJC_NUMNFI   := aAnaSrv[i,03]
			VJC_SERNFI   := aAnaSrv[i,04]
			VJC_TIPO    := aAnaSrv[i,05]
			VJC_PERIOD  := "D"
			VJC_DATVEN   := aAnaSrv[i,13]
			VJC_CLIFAT := Left(aAnaSrv[i,06],6)
			VJC_LOJA    := Subs(aAnaSrv[i,06],7,2)		
			VJC_VALVDA  := round(aAnaSrv[i,10],2)
			VJC_VALIMP  := round(aAnaSrv[i,11],2)
			VJC_VALCUS  := round(aAnaSrv[i,12],2)
			MsUnlock()
		else
			RecLock("VJC",.f.)
			VJC_VALVDA  += round(aAnaSrv[i,10],2)
			VJC_VALIMP  += round(aAnaSrv[i,11],2)
			VJC_VALCUS  += round(aAnaSrv[i,12],2)
			msunlock()
		endif
		cNFAnt := aAnaSrv[i,3]+aAnaSrv[i,4]
	Next
	////////////////////////////// VEICULOS
	nTVeiDev := 0
	DbSelectArea("VJI")
	for i := 1 to Len(aAnaVei)
		lFound := DBSeek("ZZ")
		RecLock("VJI",!lFound)
		VJI_FILIAL  := aAnaVei[i,2]
		VJI_NUMNFI   := aAnaVei[i,3]
		VJI_SERNFI   := aAnaVei[i,4]
		VJI_TIPO    := aAnaVei[i,5]
		VJI_GRUITE   := aAnaVei[i,7]
		VJI_CODITE  := aAnaVei[i,8]
		VJI_DATVEN   := aAnaVei[i,13]
		VJI_PERIOD   := "D"             		
		VJI_VALVDA  := round(aAnaVei[i,10],2)
		VJI_VALIMP  := round(aAnaVei[i,11],2)
		VJI_VALCUS  := round(aAnaVei[i,12],2)
		VJI_QUANT := iif(round(aAnaVei[i,10],2) < 0, -1,1)		
		MsUnlock()
	next
	DbSelectArea("VJC")
	for i := 1 to Len(aAnaVei)
		lFound := DBSeek("ZZ")
		RecLock("VJC",!lFound)
		VJC_FILIAL  := aAnaVei[i,02]
		VJC_NUMNFI   := aAnaVei[i,03]
		VJC_SERNFI   := aAnaVei[i,04]
		VJC_TIPO    := aAnaVei[i,05]
		VJC_PERIOD  := "D"
		VJC_DATVEN   := aAnaVei[i,13]
		VJC_CLIFAT := Left(aAnaVei[i,06],6)
		VJC_LOJA    := Subs(aAnaVei[i,07],7,2)		
		VJC_VALVDA  := round(aAnaVei[i,10],2)
		VJC_VALIMP  := round(aAnaVei[i,11],2)
		VJC_VALCUS  := round(aAnaVei[i,12],2)
		VJC_QUANT := iif(round(aAnaVei[i,10],2) < 0, -1,1)
		MsUnlock()
	Next
	cQAlVJC := "SQLVJC"
	cQuery := "SELECT VJC.VJC_FILIAL FIL , VJC.VJC_TIPO TIPO , sum(VJC.VJC_QUANT) CONT , sum(VJC.VJC_VALVDA) VALVDA , sum(VJC.VJC_VALIMP) VALIMP , sum(VJC.VJC_VALCUS) VALCUS FROM "+RetSqlName("VJC")+" VJC "
	cQuery += "WHERE VJC.VJC_FILIAL='"+xFilial("VJC")+"' AND VJC.VJC_DATVEN>='"+dtos(MV_PAR01)+"' AND VJC.VJC_DATVEN<='"+dtos(MV_PAR02)+"' AND VJC.VJC_PERIOD='D' AND VJC.D_E_L_E_T_=' ' GROUP BY VJC.VJC_FILIAL , VJC.VJC_TIPO"

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVJC, .F., .T. )
	(cQAlVJC)->( DBGoTop())
	DBSelectArea("VJC")
	while !((cQAlVJC)->(eof()))
		reclock("VJC",.t.)
		VJC_FILIAL  := (cQAlVJC)->(FIL)
		VJC_NUMNFI   := ""
		VJC_SERNFI   := ""
		VJC_TIPO    := (cQAlVJC)->(TIPO)
		VJC_PERIOD  := "R"
		VJC_DATVEN   := MV_PAR02
		VJC_CLIFAT := ""
		VJC_LOJA := ""		
		VJC_VALVDA  := (cQAlVJC)->(VALVDA)
		VJC_VALIMP  := (cQAlVJC)->(VALIMP)
		VJC_VALCUS  := (cQAlVJC)->(VALCUS)
		VJC_QUANT   := (cQAlVJC)->(CONT)
		MsUnlock()
		(cQAlVJC)->( DBSkip())
	enddo
	( cQAlVJC )->( dbCloseArea() )
#ENDIF
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_OPENARQ Autor ³ Andre Luis Almeida    ³ Data ³ 26/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Posicao das Vendas & Resultados - AUTOMATICO pelo WORKFLOW ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#IFDEF TOP

Static Function FS_OPENARQ()

Local cOpenArq:= "'SF2'," , nOpem:=0
Local cStr:=""
DBCloseAll()
Prepare Environment Empresa cEmpr Filial cFil Tables 'SF2' Modulo "OFI"
if (nHandle:= FT_FUse( "SIGAOFI.MNU" )) == -1
Return
endif
FT_FGotop()
While ! FT_FEof()
	cStr := FT_FReadLN()
	If Substr(cStr,31,1) == "T"	
		For nOpem := 32 to 90 step 3
			If !Empty(Substr(cStr,nOpem,3)) .And. !( "." $ Substr(cStr,nOpem,3) );
				.And. At(Substr(cStr,nOpem,3),cOpenArq)==0 .And. At(Substr(cStr,nOpem,3),cFOPENed)==0;
				.And. SX2->(DbSeek(Substr(cStr,nOpem,3)))
				cOpenArq += "'"+Substr(cStr,nOpem,3)+"',"		
				DbSelectArea(Substr(cStr,nOpem,3))
			EndIf	
		Next
	EndIf
FT_FSkip()
End
FT_FUse()
Return

#ENDIF