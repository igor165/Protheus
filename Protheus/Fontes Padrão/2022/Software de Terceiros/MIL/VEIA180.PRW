#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIA180.CH"

/*/{Protheus.doc} VEIA180()
Conhecimento de Frete (substituicao do VEIVM006) - Chamadas do MATA116 

@author Andre Luis Almeida
@since 14/07/2020
@version 1.0
@return NIL
/*/
Function VEIA180()
Local oBrowse
//
DBSelectArea("VVF")
DBSetOrder(2) // VVF_OPEMOV e Data do Movimento
//
oBrowse := FWMBrowse():New()
oBrowse:SetAlias("VVF")
oBrowse:SetDescription(STR0001) // Conhecimento de Frete
oBrowse:SetUseFilter()
oBrowse:DisableDetails()
oBrowse:SetMenuDef("VEIA180")
oBrowse:SetFilterDefault("VVF_OPEMOV == '6'")
oBrowse:Activate()
//
Return NIL

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 14/07/2020
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}
aAdd(aRotina,{STR0002,"VA1800021_Visualizar",0,2}) // Visualizar
aAdd(aRotina,{STR0003,"VA1800011_Gerar",0,3}) // Conhec. Frete
Return aRotina

/*/{Protheus.doc} VA1800011_Gerar
Chamada da Funcao A116Inclui com nOpc 6

@author Andre Luis Almeida
@since 14/07/2020
@version 1.0
/*/
Function VA1800011_Gerar()
Private aRotina := StaticCall(MATA116,MENUDEF)
//
nOpc := 6
//
DBSelectArea("SF1")
SetFunName("MATA116")
nModulo := 2
MATA116()
nModulo := 11
DBSelectArea("VVF")
//
Return

/*/{Protheus.doc} VA1800021_Visualizar
Chamada da Funcao A103NFiscal para Visualizar a NF

@author Andre Luis Almeida
@since 14/07/2020
@version 1.0
/*/
Function VA1800021_Visualizar()
Private aRotina := StaticCall(MATA103,MENUDEF)
// Poscionar no SF1
DBSelectArea("SF1")
DBSetOrder(1)
If DBSeek(xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA)
	A103NFiscal("SF1",SF1->(RecNo()),2) // Visualizar NF Entrada - Conhecimento de Frete
EndIf
DBSelectArea("VVF")
Return

/*/{Protheus.doc} VA1800031_A116Inclui
Funcao para gravar os Arquivos do DMS, chamada pelo A116Inclui do MATA116

@author Andre Luis Almeida
@since 14/07/2020
@version 1.0
/*/
Function VA1800031_A116Inclui( nOpcDMS , nRecSF1 , aRecSF1Ori )
Local cTRACPA := ""
If FM_PILHA("VEIVM006")
	Return // Se chamar pelo VEIVM006 (antigo), não executar as funções novas
EndIf
If nOpcDMS == 3 .or. nOpcDMS == 5 // Incluir ou Excluir
	If VA1800091_NF_Veiculo( nRecSF1 ) // Verifica se a NF de Entrada corresponde a Veiculos/Maquinas
		If nOpcDMS == 3 // Incluindo Conhecimento de Frete
			cTRACPA := VA1800041_Incluir_VVF( nRecSF1 ) // Incluir VVF
			VA1800051_Atualiza_VVG( nRecSF1 , cTRACPA , aRecSF1Ori ) // Atualiza VVF/VVG relacionados
			VA1800061_Parcelas_VS9( .t. , cTRACPA ) // .T. = Incluir VS9
		Else // nOpcDMS == 5 // Excluindo Conhecimento de Frete
			cTRACPA := VA1800071_Cancelar_VVFVVG( nRecSF1 ) // Excluir VVF do Conhecimento de Frete e corrige VVF/VVG dos relacionados
			VA1800061_Parcelas_VS9( .f. , cTRACPA ) // .F. = Excluir VS9
		EndIf
		If ExistBlock("VA180OK") // Ponto de Entrada apos a Inclusao ou Exclusao do Conhecimento de Frete
			ExecBlock("VA180OK",.F.,.F.,{ nOpcDMS , nRecSF1 , aRecSF1Ori , cTRACPA })
		EndIf
	EndIf
EndIf
Return

/*/{Protheus.doc} VA1800041_Incluir_VVF
Incluir VVF partindo do SF1

@author Andre Luis Almeida
@since 15/07/2020
@version 1.0
/*/
Static Function VA1800041_Incluir_VVF( nRecSF1 )
Local nCntFor   := 0 
Local aDePara   := {}
Local cTRACPA   := ""
Local cQueryNat := ""
Local cQueryTES := ""
//
SF1->(DbGoTo(nRecSF1)) // Posiciona na NF gerada
//
cQueryNat := "SELECT SE2.E2_NATUREZ"
cQueryNat += "  FROM " + RetSQLName("SE2") + " SE2 "
cQueryNat += " WHERE SE2.E2_FILIAL='"+xFilial("SE2")+"'"
cQueryNat += "   AND SE2.E2_PREFIXO='"+SF1->F1_PREFIXO+"'"
cQueryNat += "   AND SE2.E2_NUM='"+SF1->F1_DUPL+"'"
cQueryNat += "   AND SE2.D_E_L_E_T_=' '"
//
cQueryTES := "SELECT SD1.D1_TES"
cQueryTES += "  FROM " + RetSQLName("SD1") + " SD1 "
cQueryTES += " WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"'"
cQueryTES += "   AND SD1.D1_DOC='"+SF1->F1_DOC+"'"
cQueryTES += "   AND SD1.D1_SERIE='"+SF1->F1_SERIE+"'"
cQueryTES += "   AND SD1.D1_FORNECE='"+SF1->F1_FORNECE+"'"
cQueryTES += "   AND SD1.D1_LOJA='"+SF1->F1_LOJA+"'"
cQueryTES += "   AND SD1.D_E_L_E_T_=' '"
//
cTRACPA := GetSxENum("VVF","VVF_TRACPA")
ConfirmSx8()
//
aAdd(aDePara,{"VVF_FILIAL",xFilial("VVF")})					// Filial
aAdd(aDePara,{"VVF_TRACPA",cTRACPA})						// TRACPA
aAdd(aDePara,{"VVF_FORPRO","0"})							// Formulario Proprio
aAdd(aDePara,{"VVF_OPEMOV","6"})							// Conhecimento de Frete
aAdd(aDePara,{"VVF_DATMOV",SF1->F1_EMISSAO})				// Data Movimento
aAdd(aDePara,{"VVF_DATEMI",SF1->F1_EMISSAO})				// Data Emissao
aAdd(aDePara,{"VVF_DATFAB",SF1->F1_EMISSAO})				// Data Fab
aAdd(aDePara,{"VVF_CODFOR",SF1->F1_FORNECE})				// Codigo Fornecedor
aAdd(aDePara,{"VVF_LOJA"  ,SF1->F1_LOJA})					// Loja Fornecedor
aAdd(aDePara,{"VVF_FORPAG",SF1->F1_COND})					// Cond.Pagamento
aAdd(aDePara,{"VVF_NATURE",FM_SQL(cQueryNat)})				// Natureza dos titulos SE2
aAdd(aDePara,{"VVF_TESFRE",FM_SQL(cQueryTES)})				// TES dos itens SD1
aAdd(aDePara,{"VVF_NUMNFI",SF1->F1_DOC})					// Nro. NF
aAdd(aDePara,{"VVF_SERNFI",SF1->F1_SERIE})					// Serie NF
aAdd(aDePara,{"VVF_VALMOV",SF1->F1_VALBRUT})				// Valor Movimento
aAdd(aDePara,{"VVF_TOTFRE",SF1->F1_FRETE})					// Valor Frete
aAdd(aDePara,{"VVF_DESACE",SF1->F1_DESPESA})				// Valor Despesa
aAdd(aDePara,{"VVF_VBAIPI",SF1->F1_BASEIPI})				// Base IPI
aAdd(aDePara,{"VVF_VALIPI",SF1->F1_VALIPI})					// Valor IPI
aAdd(aDePara,{"VVF_ALIIPI",((SF1->F1_VALIPI/SF1->F1_BASEIPI)*100)}) // Aliquota IPI
aAdd(aDePara,{"VVF_VBAICM",SF1->F1_BASEICM})				// Base ICMS
aAdd(aDePara,{"VVF_TOTICM",SF1->F1_VALICM})					// Valor ICMS
aAdd(aDePara,{"VVF_ALIICM",((SF1->F1_VALICM/SF1->F1_BASEICM)*100)}) // Aliquota ICMS
aAdd(aDePara,{"VVF_ICMRET",SF1->F1_ICMSRET})				// ICMS RET
aAdd(aDePara,{"VVF_SITNFI","1"})							// NF Valida
aAdd(aDePara,{"VVF_RECSF1",SF1->(RecNo())})					// RecNo SF1
aAdd(aDePara,{"VVF_DTHEMI",left(Dtoc(dDataBase),6)+right(Dtoc(dDataBase),2)+"/"+Time()}) // Dia/Mes/Ano(2 posicoes)/Hora:Minuto:Segundo
aAdd(aDePara,{"VVF_SDOC"  ,SF1->F1_SDOC})
aAdd(aDePara,{"VVF_CHVNFE",SF1->F1_CHVNFE})
aAdd(aDePara,{"VVF_PLIQUI",SF1->F1_PLIQUI})
aAdd(aDePara,{"VVF_PBRUTO",SF1->F1_PBRUTO})
aAdd(aDePara,{"VVF_TRANSP",SF1->F1_TRANSP})
aAdd(aDePara,{"VVF_ESPEC1",SF1->F1_ESPECI1})
aAdd(aDePara,{"VVF_VOLUM1",SF1->F1_VOLUME1})
aAdd(aDePara,{"VVF_ESPEC2",SF1->F1_ESPECI2})
aAdd(aDePara,{"VVF_VOLUM2",SF1->F1_VOLUME2})
aAdd(aDePara,{"VVF_ESPEC3",SF1->F1_ESPECI3})
aAdd(aDePara,{"VVF_VOLUM3",SF1->F1_VOLUME3})
aAdd(aDePara,{"VVF_ESPEC4",SF1->F1_ESPECI4})
aAdd(aDePara,{"VVF_VOLUM4",SF1->F1_VOLUME4})
//
aAdd(aDePara,{"VVF_ESPECI",SF1->F1_ESPECIE})
aAdd(aDePara,{"VVF_UFORIT",SF1->F1_UFORITR})
aAdd(aDePara,{"VVF_MUORIT",SF1->F1_MUORITR})
aAdd(aDePara,{"VVF_UFDEST",SF1->F1_UFDESTR})
aAdd(aDePara,{"VVF_MUDEST",SF1->F1_MUDESTR})
//

dBSelectArea("VVF")
RegToMemory("VVF",.t.,.t.) // Inicializa M->VVF_...
RecLock("VVF",.t.)
	FG_GRAVAR("VVF")
	For nCntFor := 1 to len(aDePara)
		&("VVF->"+aDePara[nCntFor,1]) := aDePara[nCntFor,2]
	Next
MsUnLock()
//
Return cTRACPA

/*/{Protheus.doc} VA1800051_Atualiza_VVG
Alteracao nos VVG originais partindo do SD1

@author Andre Luis Almeida
@since 15/07/2020
@version 1.0
/*/
Static Function VA1800051_Atualiza_VVG( nRecSF1 , cTRACPA , aRecSF1Ori )
Local nCntFor     := 0
Local nPosVet     := 0
Local nValorFre   := 0
Local aNFsTodas   := {}
Local aNFCFrete   := {}
Local cQuery      := ""
Local cQAlias     := "SQLAUX"
Local cMV_MIL0157 := GetNewPar("MV_MIL0157","1") // Corrige Custo da NF de Origem
Local cMV_GRUVEI  := PadR(GetMv("MV_GRUVEI"),GeTSX3Cache("BM_GRUPO","X3_TAMANHO"))
Local lVA180CT    := ExistBlock("VA180CT") // Ponto de Entrada no momento que Altera o Custo do VVG
//
If len(aRecSF1Ori) > 0 // Dar manutencao nos VVFs Origens
	//
	SB1->(DBSetOrder(1))
	//
	SF1->(DbGoTo(nRecSF1)) // SF1 NF Conhecimento de Frete
	//
	aNFsTodas := VA1800111_LevantaTodasNFsFretes( SF1->F1_FILIAL , SF1->F1_DOC , SF1->F1_SERIE , SF1->F1_FORNECE , SF1->F1_LOJA ) // TODAS as NFs de Fretes relacionadas
	//
	// Soma todos os D1_CUSTO de todas as NFs de Frete relacionadas a NF de Origem
	For nCntFor := 1 to len(aNFsTodas)
		cQuery := "SELECT D1_COD , D1_CUSTO"
		cQuery += "  FROM " + RetSQLName("SD1")
		cQuery += " WHERE D1_FILIAL  = '"+aNFsTodas[nCntFor,1]+"'"
		cQuery += "   AND D1_DOC     = '"+aNFsTodas[nCntFor,2]+"'"
		cQuery += "   AND D1_SERIE   = '"+aNFsTodas[nCntFor,3]+"'"
		cQuery += "   AND D1_FORNECE = '"+aNFsTodas[nCntFor,4]+"'"
		cQuery += "   AND D1_LOJA    = '"+aNFsTodas[nCntFor,5]+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
		While !( cQAlias )->(Eof())
			nPosVet := Ascan(aNFCFrete,{|x| x[1] == ( cQAlias )->( D1_COD ) })
			If nPosVet == 0
				aAdd(aNFCFrete,{ ( cQAlias )->( D1_COD ) , 0 })
				nPosVet := len(aNFCFrete)
			EndIf
			aNFCFrete[nPosVet,2] += ( cQAlias )->( D1_CUSTO )
			( cQAlias )->(dbSkip())
		EndDo
		( cQAlias )->( dbCloseArea() )
	Next
	//
	DbSelectArea("SF1")
	//
	For nCntFor := 1 to len(aRecSF1Ori)
		//
		SF1->(DbGoTo(aRecSF1Ori[nCntFor]))
		//
		cQuery := "SELECT VVF.R_E_C_N_O_ AS RECVVF,"
		cQuery += "       VVG.R_E_C_N_O_ AS RECVVG,"
		cQuery += "       SD1.R_E_C_N_O_ AS RECSD1,"
		cQuery += "       SB1.R_E_C_N_O_ AS RECSB1 "
		cQuery += "  FROM " + RetSQLName("VVF")+" VVF "
		cQuery += "  JOIN " + RetSQLName("VVG")+" VVG ON VVG.VVG_FILIAL=VVF.VVF_FILIAL AND VVG.VVG_TRACPA=VVF.VVF_TRACPA AND VVG.D_E_L_E_T_=' '"
		cQuery += "  JOIN " + RetSQLName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cMV_GRUVEI+"' AND SB1.B1_CODITE=VVG.VVG_CHAINT AND SB1.D_E_L_E_T_=' '"
		cQuery += "  JOIN " + RetSQLName("SD1")+" SD1 ON SD1.D1_FILIAL='"+SF1->F1_FILIAL+"' AND SD1.D1_DOC='"+SF1->F1_DOC+"' AND SD1.D1_SERIE='"+SF1->F1_SERIE+"' AND SD1.D1_FORNECE='"+SF1->F1_FORNECE+"' AND SD1.D1_LOJA='"+SF1->F1_LOJA+"' AND SD1.D1_COD=SB1.B1_COD AND SD1.D_E_L_E_T_=' '"
		cQuery += " WHERE VVF.VVF_FILIAL='"+xFilial("VVF")+"'"
		cQuery += "   AND VVF.VVF_NUMNFI='"+SF1->F1_DOC+"'"
		cQuery += "   AND VVF.VVF_SERNFI='"+SF1->F1_SERIE+"'"
		cQuery += "   AND VVF.VVF_CODFOR='"+SF1->F1_FORNECE+"'"
		cQuery += "   AND VVF.VVF_LOJA='"+SF1->F1_LOJA+"'"
		cQuery += "   AND VVF.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
		If !( cQAlias )->(Eof())
			nValorFre := 0
			VVF->(DbGoTo( ( cQAlias )->( RECVVF ) ))
			While !( cQAlias )->(Eof())
				//
				SD1->(DbGoTo( ( cQAlias )->( RECSD1 ) ))
				//
				nPosVet := Ascan(aNFCFrete,{|x| x[1] == SD1->D1_COD })
				If nPosVet > 0
					//
					DBSelectArea("VVG")
					VVG->(DbGoTo( ( cQAlias )->( RECVVG ) ))
					RecLock("VVG",.f.)
						VVG->VVG_VALFRE := aNFCFrete[nPosVet,2] // Valor correspondente ao D1_TOTAL da NF de Conhecimento de Frete
					MsUnlock()
					nValorFre += aNFCFrete[nPosVet,2]
					//
					If cMV_MIL0157 == "1" // Corrige Custo da NF de Origem
						SB1->(DbGoTo( ( cQAlias )->( RECSB1 ) ))
						VA1800081_Corrigir_CustoVVG( 3 , SD1->D1_CUSTO , lVA180CT )
					EndIf
					//
				EndIf
				//
				( cQAlias )->(dbSkip())
			EndDo
			DBSelectArea("VVF")
			RecLock("VVF",.f.)
				VVF->VVF_CONFRE := nValorFre	// Total de Frete (Soma dos Itens)
				VVF->VVF_NUMTRA := cTRACPA		// Novo TRACPA - NF do Conhecimento de Frete
			MsUnLock()
		EndIf
		( cQAlias )->( dbCloseArea() )
	Next
EndIf
SF1->(DbGoTo(nRecSF1)) // SF1 NF Conhecimento de Frete
VVF->(DBSetOrder(1)) // VVF_TRACPA
VVF->(DBSeek(xFilial("VVF")+cTRACPA)) // Voltar para o VVF do Conhecimento de Frete
VVF->(DBSetOrder(2)) // VVF_OPEMOV e Data do Movimento - Ordem Padrao Browse
Return

/*/{Protheus.doc} VA1800061_Parcelas_VS9
VS9 partindo do SE2

@author Andre Luis Almeida
@since 15/07/2020
@version 1.0
/*/
Static Function VA1800061_Parcelas_VS9( lIncVS9 , cTRACPA )
Local nCont   := 1
Local cQAlSE2 := "SQLSE2"
Local cQuery  := ""
Local cNumIde := ""
If lIncVS9 // Incluir VS9
	cQuery := "SELECT SE2.E2_VENCREA , SE2.E2_VALOR"
	cQuery += "  FROM " + RetSQLName("SE2") + " SE2 "
	cQuery += " WHERE SE2.E2_FILIAL='"+xFilial("SE2")+"'"
	cQuery += "   AND SE2.E2_PREFIXO='"+SF1->F1_PREFIXO+"'"
	cQuery += "   AND SE2.E2_NUM='"+SF1->F1_DUPL+"'"
	cQuery += "   AND SE2.E2_FORNECE='"+SF1->F1_FORNECE+"'"
	cQuery += "   AND SE2.E2_LOJA='"+SF1->F1_LOJA+"'"
	cQuery += "   AND SE2.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSE2, .F., .T. )
	While !( cQAlSE2 )->(Eof())
		dBSelectArea("VS9")
		RecLock("VS9",.t.)
			VS9->VS9_FILIAL := xFilial("VS9")
			VS9->VS9_NUMIDE := cTRACPA
			VS9->VS9_TIPOPE := "F"
			VS9->VS9_SEQUEN := StrZero(nCont,2)
			VS9->VS9_TIPPAG := "DP"
			VS9->VS9_DATPAG := stod(( cQAlSE2 )->( E2_VENCREA ))
			VS9->VS9_VALPAG := ( cQAlSE2 )->( E2_VALOR )
		MsUnlock()
		nCont++
		( cQAlSE2 )->(dbSkip())
	EndDo
	( cQAlSE2 )->( dbCloseArea() )
Else // Excluir VS9
	cNumIde := padr(cTRACPA,GeTSX3Cache("VS9_NUMIDE","X3_TAMANHO"))
	DBSelectArea("VS9")
	DBSetOrder(1)
	DBSeek( xFilial("VS9") + cNumIde + "F" )
	While !Eof() .and. VS9->VS9_FILIAL == xFilial("VS9") .and. VS9->VS9_NUMIDE == cNumIde .and. VS9->VS9_TIPOPE == "F"
		RecLock("VS9",.f.,.t.)
		DbDelete()
		MsUnlock()
		VS9->(dbSkip())
	Enddo
EndIf
Return

/*/{Protheus.doc} VA1800071_Cancelar_VVFVVG
Cancelamento - Excluir VVF do Conhecimento de Frete e corrige VVF/VVG relacionados

@author Andre Luis Almeida
@since 16/07/2020
@version 1.0
/*/
Static Function VA1800071_Cancelar_VVFVVG( nRecSF1 )
Local cTRACPA     := ""
Local cQuery      := ""
Local cQAlSF1     := "SQLSF1"
Local cQAlVVF     := "SQLVVF"
Local cMV_MIL0157 := GetNewPar("MV_MIL0157","1") // Corrige Custo da NF de Origem
Local cMV_GRUVEI  := PadR(GetMv("MV_GRUVEI"),GeTSX3Cache("BM_GRUPO","X3_TAMANHO"))
Local lVA180CT    := ExistBlock("VA180CT") // Ponto de Entrada no momento que Altera o Custo do VVG
//
cQuery := "SELECT VVF.R_E_C_N_O_ AS RECVVF "
cQuery += "  FROM " + RetSQLName("SF1") + " SF1 "
cQuery += "  JOIN " + RetSQLName("VVF") + " VVF ON VVF.VVF_FILIAL='"+xFilial("VVF")+"' AND VVF.VVF_NUMNFI=SF1.F1_DOC AND VVF.VVF_SERNFI=SF1.F1_SERIE AND VVF.VVF_CODFOR=SF1.F1_FORNECE AND VVF.VVF_LOJA=SF1.F1_LOJA AND VVF.VVF_SITNFI='1' AND VVF.D_E_L_E_T_=' '"
cQuery += " WHERE SF1.R_E_C_N_O_="+str(nRecSF1) // Posicionar pelo RECNO no SF1 deletado (NF ja foi CANCELADA)
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSF1, .F., .T. )
If !( cQAlSF1 )->(Eof())
	//
	VVF->(DbGoTo( ( cQAlSF1 )->( RECVVF ) ))
	cTRACPA := VVF->VVF_TRACPA
	//
	DbSelectArea("VVF")
	RecLock("VVF",.f.,.t.)
	DbDelete() // Exclui o VVF do Conhecimento de Frete
	MsUnlock()
	//
	cQuery := "SELECT VVF.R_E_C_N_O_ AS RECVVF,"
	cQuery += "       VVG.R_E_C_N_O_ AS RECVVG,"
	cQuery += "       SD1.R_E_C_N_O_ AS RECSD1,"
	cQuery += "       SB1.R_E_C_N_O_ AS RECSB1 "
	cQuery += "  FROM " + RetSQLName("VVF") + " VVF "
	cQuery += "  JOIN " + RetSQLName("VVG")+" VVG ON VVG.VVG_FILIAL=VVF.VVF_FILIAL AND VVG.VVG_TRACPA=VVF.VVF_TRACPA AND VVG.D_E_L_E_T_=' '"
	cQuery += "  JOIN " + RetSQLName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cMV_GRUVEI+"' AND SB1.B1_CODITE=VVG.VVG_CHAINT AND SB1.D_E_L_E_T_=' '"
	cQuery += "  JOIN " + RetSQLName("SD1")+" SD1 ON SD1.D1_FILIAL='"+xFilial("VVG")+"' AND SD1.D1_DOC=VVF.VVF_NUMNFI AND SD1.D1_SERIE=VVF.VVF_SERNFI AND SD1.D1_FORNECE=VVF.VVF_CODFOR AND SD1.D1_LOJA=VVF.VVF_LOJA AND SD1.D1_COD=SB1.B1_COD"
	cQuery += " WHERE VVF.VVF_FILIAL='"+xFilial("VVF")+"'"
	cQuery += "   AND VVF.VVF_NUMTRA='"+cTRACPA+"'"
	cQuery += "   AND VVF.VVF_SITNFI='1'"
	cQuery += "   AND VVF.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVVF, .F., .T. )
	If !( cQAlVVF )->(Eof())
		VVF->(DbGoto( ( cQAlVVF )->( RECVVF ) )) // Necessário posicionar pois utiliza o VVF para carregar os M-> utilizados nas formulas do CUSTO
		While !( cQAlVVF )->(Eof())
			DBSelectArea("VVG")
			VVG->(DbGoTo( ( cQAlVVF )->( RECVVG ) ))
			RecLock("VVG",.f.)
				VVG->VVG_VALFRE := 0
			MsUnlock()
			//
			If cMV_MIL0157 == "1" // Corrige Custo da NF de Origem
				SD1->(DbGoTo( ( cQAlVVF )->( RECSD1 ) ))
				SB1->(DbGoTo( ( cQAlVVF )->( RECSB1 ) ))
				VA1800081_Corrigir_CustoVVG( 5 , SD1->D1_CUSTO , lVA180CT )
			EndIf
			//
			( cQAlVVF )->(dbSkip())
		EndDo
		DBSelectArea("VVF")
		RecLock("VVF",.f.)
			VVF->VVF_CONFRE := 0
			VVF->VVF_NUMTRA := "" // Limpar vinculo com a NF de Conhecimento de Frete
		MsUnLock()
	EndIf
	( cQAlVVF )->( dbCloseArea() )
EndIf
( cQAlSF1 )->( dbCloseArea() )
DBSelectArea("VVF")
VVF->(DBSetOrder(2)) // VVF_OPEMOV e Data do Movimento - Ordem Padrao Browse
Return cTRACPA

/*/{Protheus.doc} VA1800081_Corrigir_CustoVVG
Corrigir Custo do Veiculo no VVG relacionado

@author Andre Luis Almeida
@since 17/07/2020
@version 1.0
/*/
Static Function VA1800081_Corrigir_CustoVVG( nOpcDMS , nCustoDef , lVA180CT )
Local cFormCusto  := ""
Local nCustoVeic  := 0
Default nOpcDMS   := 3
Default nCustoDef := 0
Default lVA180CT  := .f.
//
RegToMemory("VVF",.f.) // Carregar M->VVF_... com o VVF posicionado para poder utilizar na Formula
RegToMemory("VVG",.f.) // Carregar M->VVG_... com o VVG posicionado para poder utilizar na Formula
//
VV1->(DBSetOrder(1))
VV1->(dBSeek(xFilial("VV1")+VVG->VVG_CHAINT))
VV2->(DBSetOrder(1))
VV2->(dBSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD))
VE4->(DBSetOrder(1))
VE4->(dBSeek(xFilial("VE4")+VV1->VV1_CODMAR))
//
If VVG->VVG_ESTVEI == "0" //Novo
	If !Empty(VV2->VV2_FORCUS)       //Modelo do Veiculo
		cFormCusto := VV2->VV2_FORCUS
	ElseIf !Empty(VE4->VE4_FORCTB)   //Parametros da Montadora do Custo Contabil
		cFormCusto := VE4->VE4_FORCTB
	EndIf
Else
	cFormCusto := GetMv("MV_VUCCTB")
EndIf
If !Empty(cFormCusto)
	nCustoVeic := FG_FORMULA(cFormCusto)
EndIf
If nCustoVeic == Nil .or. nCustoVeic <= 0
	nCustoVeic := nCustoDef
EndIf
dBSelectArea("VVG")
RecLock("VVG",.f.)
	VVG->VVG_VCNVEI := nCustoVeic
MsUnlock()
If lVA180CT
	ExecBlock("VA180CT",.F.,.F.,{ nOpcDMS })
EndIf
//
Return

/*/{Protheus.doc} VA1800091_NF_Veiculo
Verifica se a NF de Entrada corresponde a Veiculos/Maquinas

@author Andre Luis Almeida
@since 17/07/2020
@version 1.0
/*/
Static Function VA1800091_NF_Veiculo( nRecSF1 )
Local cMV_GRUVEI := PadR(GetMv("MV_GRUVEI"),GeTSX3Cache("BM_GRUPO","X3_TAMANHO"))
//
cQuery := "SELECT COUNT(*) AS QTDE "
cQuery += "  FROM " + RetSQLName("SF1") + " SF1 "
cQuery += "  JOIN " + RetSQLName("SD1") + " SD1 "
cQuery += "    ON SD1.D1_FILIAL = SF1.F1_FILIAL"
cQuery += "   AND SD1.D1_DOC = SF1.F1_DOC"
cQuery += "   AND SD1.D1_SERIE = SF1.F1_SERIE"
cQuery += "   AND SD1.D1_FORNECE = SF1.F1_FORNECE"
cQuery += "   AND SD1.D1_LOJA = SF1.F1_LOJA"
cQuery += "   AND SD1.D1_GRUPO = '"+cMV_GRUVEI+"'"
cQuery += " WHERE SF1.R_E_C_N_O_ = "+str(nRecSF1) // Posicionar no SF1 deletado pelo RECNO
//
Return ( FM_SQL(cQuery) > 0 )

/*/{Protheus.doc} VA1800101_ValidarA116Inclui
Validar se eh possivel realizar a Inclusao ou Exclusao da NF de Conhecimento de Frete

@author Andre Luis Almeida
@since 11/08/2020
@version 1.0
/*/
Function VA1800101_ValidarA116Inclui( nOpcDMS , nRecSF1 , aRecSF1Ori )
Local lRet        := .t.
Local cTRACPA     := ""
Local cQuery      := ""
Local cQAlVVF     := "SQLVVF"
Local cMV_GRUVEI  := PadR(GetMv("MV_GRUVEI"),GeTSX3Cache("BM_GRUPO","X3_TAMANHO"))
//
If nOpcDMS == 5 // Excluir
	//
	cQuery := "SELECT VVF.R_E_C_N_O_ AS RECVVF "
	cQuery += "  FROM " + RetSQLName("SF1") + " SF1 "
	cQuery += "  JOIN " + RetSQLName("VVF") + " VVF ON VVF.VVF_FILIAL='"+xFilial("VVF")+"' AND VVF.VVF_NUMNFI=SF1.F1_DOC AND VVF.VVF_SERNFI=SF1.F1_SERIE AND VVF.VVF_CODFOR=SF1.F1_FORNECE AND VVF.VVF_LOJA=SF1.F1_LOJA AND VVF.D_E_L_E_T_=' '"
	cQuery += " WHERE SF1.R_E_C_N_O_="+str(nRecSF1) // Posicionar pelo RECNO no SF1 deletado (NF ja foi CANCELADA)
	//
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVVF, .F., .T. )
	If !( cQAlVVF )->(Eof())
		//
		VVF->(DbGoTo( ( cQAlVVF )->( RECVVF ) ))
		cTRACPA := VVF->VVF_TRACPA
		If VVF->VVF_SITNFI <> "1" // NAO é Valida ?
			Help(" ",1,"NFINVCANCE")
			lRet := .f.
		Else
			//
			cQuery := "SELECT VVF.R_E_C_N_O_ AS RECVVF "
			cQuery += "  FROM "+RetSQLName("VVF")+" VVF "
			cQuery += "  JOIN "+RetSQLName("VVG")+" VVG ON VVG.VVG_FILIAL=VVF.VVF_FILIAL AND VVG.VVG_TRACPA=VVF.VVF_TRACPA AND VVG.D_E_L_E_T_=' '"
			cQuery += "  JOIN "+RetSQLName("VV1")+" VV1 ON VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=VVG.VVG_CHAINT AND VV1.VV1_SITVEI<>'0' AND VV1.D_E_L_E_T_=' '"
			cQuery += "  JOIN "+RetSQLName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cMV_GRUVEI+"' AND SB1.B1_CODITE=VVG.VVG_CHAINT AND SB1.D_E_L_E_T_=' '"
			cQuery += "  JOIN "+RetSQLName("SD1")+" SD1 ON SD1.D1_FILIAL='"+xFilial("VVG")+"' AND SD1.D1_DOC=VVF.VVF_NUMNFI AND SD1.D1_SERIE=VVF.VVF_SERNFI AND SD1.D1_FORNECE=VVF.VVF_CODFOR AND SD1.D1_LOJA=VVF.VVF_LOJA AND SD1.D1_COD=SB1.B1_COD"
			cQuery += " WHERE VVF.VVF_FILIAL='"+xFilial("VVF")+"'"
			cQuery += "   AND VVF.VVF_NUMTRA='"+cTRACPA+"'"
			cQuery += "   AND VVF.VVF_SITNFI='1'"
			cQuery += "   AND VVF.D_E_L_E_T_=' '"
			If FM_SQL(cQuery) > 0
				Help(" ",1,"VEICSNESTQ") // VV1.VV1_SITVEI<>'0' -> Veiculo nao esta em estoque
				lRet := .f.
			EndIf
			//
		Endif
		//
	EndIf
	( cQAlVVF )->( dbCloseArea() )
	DBSelectArea("VVF")
	VVF->(DBSetOrder(2)) // VVF_OPEMOV e Data do Movimento - Ordem Padrao Browse
EndIf
//
Return lRet

/*/{Protheus.doc} VA1800111_LevantaTodasNFsFretes
Levanta TODAS as NFs de Fretes relacionadas a um SF1

@author Andre Luis Almeida
@since 29/07/2022
/*/
Function VA1800111_LevantaTodasNFsFretes( cFILIAL , cDOC , cSERIE , cFORNECE , cLOJA )
Local aNFOrigem := {}
Local aNFsTodas := {}
Local lContinua := .f.
Local nCntFor   := 0
Local nTotVet   := 0
//
// Levanta a NF de Origem da NF de Conhecimento de Frete que esta sendo realizada
lContinua := VA1800121_LevantaPossiveisNFs( cFILIAL , cDOC , cSERIE , cFORNECE , cLOJA , @aNFOrigem )
While lContinua
	lContinua  := .t.
	nTotVet    := len(aNFOrigem)
	For nCntFor := 1 to nTotVet // Necessário levantar a Origem da Origem ( produto cartesiano )
		If !aNFOrigem[nCntFor,6]
			lContinua := VA1800121_LevantaPossiveisNFs( aNFOrigem[nCntFor,1] , aNFOrigem[nCntFor,2] , aNFOrigem[nCntFor,3] , aNFOrigem[nCntFor,4] , aNFOrigem[nCntFor,5] , @aNFOrigem )
			aNFOrigem[nCntFor,6] := .t.
		EndIf
	Next
Enddo
// Levanta todas as NFs de Frete relacionadas a possivel NF de Origem
For nCntFor := 1 to len(aNFOrigem)
	VA1800131_LevantaNFFrete( aNFOrigem[nCntFor,1] , aNFOrigem[nCntFor,2] , aNFOrigem[nCntFor,3] , aNFOrigem[nCntFor,4] , aNFOrigem[nCntFor,5] , @aNFsTodas )
Next
//
Return aClone(aNFsTodas)

/*/{Protheus.doc} VA1800121_LevantaPossiveisNFs
Levanta todas as Notas Fiscais relacionadas ( produto cartesiano )

@author Andre Luis Almeida
@since 29/07/2022
/*/
Static Function VA1800121_LevantaPossiveisNFs( cFil , cDoc , cSer , cFor , cLoj , aNFOrigem )
Local lAddVet := .f.
Local cQuery  := ""
Local cQAlias := "SQLAUX"
cQuery := "SELECT F8_NFORIG  AS NRODOC ,"
cQuery += "       F8_SERORIG AS SERDOC ,"
cQuery += "       F8_FORNECE AS CODFOR ,"
cQuery += "       F8_LOJA    AS LOJFOR  "
cQuery += "  FROM " + RetSQLName("SF8")
cQuery += " WHERE F8_FILIAL  = '"+cFil+"'"
cQuery += "   AND F8_NFDIFRE = '"+cDoc+"'"
cQuery += "   AND F8_SEDIFRE = '"+cSer+"'"
cQuery += "   AND F8_TRANSP  = '"+cFor+"'"
cQuery += "   AND F8_LOJTRAN = '"+cLoj+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
//
cQuery += " UNION "
//
cQuery += "SELECT F8_NFDIFRE AS NRODOC ,"
cQuery += "       F8_SEDIFRE AS SERDOC ,"
cQuery += "       F8_TRANSP  AS CODFOR ,"
cQuery += "       F8_LOJTRAN AS LOJFOR  "
cQuery += "  FROM " + RetSQLName("SF8")
cQuery += " WHERE F8_FILIAL  = '"+cFil+"'"
cQuery += "   AND F8_NFORIG  = '"+cDoc+"'"
cQuery += "   AND F8_SERORIG = '"+cSer+"'"
cQuery += "   AND F8_FORNECE = '"+cFor+"'"
cQuery += "   AND F8_LOJA    = '"+cLoj+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
While !( cQAlias )->(Eof())
	If Ascan(aNFOrigem,{|x| x[1] + x[2] + x[3] + x[4] + x[5] == cFil + ( cQAlias )->( NRODOC ) + ( cQAlias )->( SERDOC ) + ( cQAlias )->( CODFOR ) + ( cQAlias )->( LOJFOR ) }) == 0
		aAdd(aNFOrigem,{ cFil , ( cQAlias )->( NRODOC ) , ( cQAlias )->( SERDOC ) , ( cQAlias )->( CODFOR ) , ( cQAlias )->( LOJFOR ) , .f. })
		lAddVet := .t.
	EndIf
	( cQAlias )->(dbSkip())
EndDo
( cQAlias )->( dbCloseArea() )
Return lAddVet

/*/{Protheus.doc} VA1800131_LevantaNFFrete
Levanta NF Frete de uma possivel NF de Origem

@author Andre Luis Almeida
@since 29/07/2022
/*/
Static Function VA1800131_LevantaNFFrete( cFil , cDoc , cSer , cFor , cLoj , aNFsTodas )
Local cQuery  := ""
Local cQAlias := "SQLAUX"
cQuery := "SELECT F8_NFDIFRE AS NRODOC ,"
cQuery += "       F8_SEDIFRE AS SERDOC ,"
cQuery += "       F8_TRANSP  AS CODFOR ,"
cQuery += "       F8_LOJTRAN AS LOJFOR  "
cQuery += "  FROM " + RetSQLName("SF8")
cQuery += " WHERE F8_FILIAL  = '"+cFil+"'"
cQuery += "   AND F8_NFORIG  = '"+cDoc+"'"
cQuery += "   AND F8_SERORIG = '"+cSer+"'"
cQuery += "   AND F8_FORNECE = '"+cFor+"'"
cQuery += "   AND F8_LOJA    = '"+cLoj+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
While !( cQAlias )->(Eof())
	If Ascan(aNFsTodas,{|x| x[1] + x[2] + x[3] + x[4] + x[5] == cFil + ( cQAlias )->( NRODOC ) + ( cQAlias )->( SERDOC ) + ( cQAlias )->( CODFOR ) + ( cQAlias )->( LOJFOR ) }) == 0
		aAdd(aNFsTodas,{ cFil , ( cQAlias )->( NRODOC ) , ( cQAlias )->( SERDOC ) , ( cQAlias )->( CODFOR ) , ( cQAlias )->( LOJFOR ) })
	EndIf
	( cQAlias )->(dbSkip())
EndDo
( cQAlias )->( dbCloseArea() )
Return