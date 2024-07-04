// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 19     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch"
#include "VEIXX040.CH"

Static cSiglaAMS := GetNewPar("MV_MIL0106","AMS") // Sigla da Solucao Agregada. Exemplos: AMS ou AFS ou SAG. Default: AMS

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  19/10/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "006248_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIXX040 ³ Autor ³ Andre Luis Almeida                ³ Data ³ 19/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela/Gravacao para (1)Agregar/(2)Desagregar                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXX040(nOperacao)
Local oCliente   := DMS_Cliente():New()
Local oFornece   := OFFornecedor():New()
Local aObjects   := {} , aPos := {} , aInfo := {}
Local aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lOKTela    := .f.
Local ni         := 0
Local cTitulo    := IIf(nOperacao==1,STR0001,STR0002) // Agregar no Equipamento / Desagregar no Equipamento
Local cB1_COD    := ""
Local cGTr       := ""
Local cNCM       := ""
Local cLocAux    := ""
Local nRecVV1    := VV1->(Recno())
Local nRecVDV    := 0
Local cChaInt    := VV1->VV1_CHAINT
Local cChassi    := VV1->VV1_CHASSI
Local cEstVei    := VV1->VV1_ESTVEI
Local cCODORI    := VV1->VV1_CODORI
Local cProvei    := VV1->VV1_PROVEI
Local cDesVei    := Alltrim(VV1->VV1_CODMAR)
Local cTESAux    := ""
Local nTamCol    := 0
Local xEAutoCab  := {}
Local xAutoIt    := {}
Local xEAutoItens:= {}
//
Local cF1_SDOC   := ""
Local cF1_SDOCP  := ""
Local cF1_FORNECP:= ""
Local cF1_LOJAP  := ""
Local cF2_SDOC   := ""
Local cF2_SDOCP  := ""
//
Local aVetVV1    := {}
Local lVV1_MSBLQL := VV1->(ColumnPos("VV1_MSBLQL")) > 0
//
Local aRetTip     := {}
Local aParamBox   := {}
//
Local aSB1SD3     := {}
Local cMV_MIL0113 := GetNewPar("MV_MIL0113","1") // Agrega/Desagrega - Gerar? ( 1=Sempre NF (default) / 2=Sempre Mov.Interna / 3=Usuário seleciona o tipo )
Local aGerar      := {}
Local aSM0        := ""
//
Local aSPComp     := ""
Local aPSPComp    := ""
//
Local cCodVDV    := ""
//
Local nPosCC     := 0
//
Local aTelaInf := {}
//
Private xSAutoCab  := {}
Private xSAutoItens:= {}

Private cSerie   := ""
Private cNumero  := ""
Private aNumNFSF2:= {}
Private aNumNFSF1:= {}
Private aIteNFSF2:= {}
Private aIteNFSF1:= {}
Private nCusAtu  := 0 // Custo Atual do Equipamento
Private nCusFut  := 0 // Custo Futuro do Equipamento (apos Agregar/Desagregar)
Private cGruVei  := left(GetMv("MV_GRUVEI")+space(10),len(SB1->B1_GRUPO))
//
Private M->VV1_CODMAR := "" // variavel utilizada no filtro do SXB do Modelo VV2
Private aVltFilDes := {}
//
Private cMarMod := space(10)
//
//////////////////////////////////
// Dados NF Saida Equipamento   //
//////////////////////////////////
Private cSCdCli  := space(TamSX3("F2_CLIENTE")[1])
Private cSLjCli  := space(TamSX3("F2_LOJA")[1])
Private cSTpOpe  := space(TamSX3("C6_OPER")[1])
Private cSCdTES  := space(TamSX3("F4_CODIGO")[1])
Private cSCdVen  := space(TamSX3("A3_COD")[1])
Private cSConPg  := space(TamSX3("E4_CODIGO")[1])
Private cSNatur  := space(TamSX3("ED_CODIGO")[1])
Private cSCdBan  := space(TamSX3("A6_COD")[1])
Private cSMenPd  := space(TamSX3("VV0_MENPAD")[1])
Private cSMenNt  := space(TamSX3("VV0_MENNOT")[1])
Private cSObsNF  := ""
Private cSCC     := space(TamSX3("B1_CC")[1])
Private cSCONTA  := space(TamSX3("B1_CONTA")[1])
Private cSITEMCC := space(TamSX3("B1_ITEMCC")[1])
Private cSCLVL   := space(TamSX3("B1_CLVL")[1])
Private cSPComp  := ""
//
//////////////////////////////////
// Dados NF Saida Pecas         //
//////////////////////////////////
Private cPSTpOpe := space(TamSX3("C6_OPER")[1])
Private cPSCdTES := space(TamSX3("F4_CODIGO")[1])
Private cPSCdVen := space(TamSX3("A3_COD")[1])
Private cPSConPg := space(TamSX3("E4_CODIGO")[1])
Private cPSNatur := space(TamSX3("ED_CODIGO")[1])
Private cPSCdBan := space(TamSX3("A6_COD")[1])
Private cPSMenPd := space(TamSX3("C5_MENPAD")[1])
Private cPSMenNt := space(TamSX3("C5_MENNOTA")[1])
Private cPSPComp := ""
//
//////////////////////////////////
// Dados NF Entrada Equipamento //
//////////////////////////////////
Private cECdFor  := space(TamSX3("F1_FORNECE")[1])
Private cELjFor  := space(TamSX3("F1_LOJA")[1])
Private cETpOpe  := space(TamSX3("C6_OPER")[1])
Private cECdTES  := space(TamSX3("F4_CODIGO")[1])
Private cEConPg  := space(TamSX3("E4_CODIGO")[1])
Private cENatur  := space(TamSX3("ED_CODIGO")[1])
Private cEMenPd  := space(TamSX3("VVF_MENPAD")[1])
Private cEMenNt  := space(TamSX3("VVF_MENNOT")[1])
Private cEEspec  := space(TamSX3("VVF_ESPECI")[1])
Private cEObsNF  := ""
Private cECC     := space(TamSX3("B1_CC")[1])
Private cECONTA  := space(TamSX3("B1_CONTA")[1])
Private cEITEMCC := space(TamSX3("B1_ITEMCC")[1])
Private cECLVL   := space(TamSX3("B1_CLVL")[1])
//
//////////////////////////////////
// Dados NF Entrada Pecas       //
//////////////////////////////////
Private cPETpOpe := space(TamSX3("C6_OPER")[1])
Private cPECdTES := space(TamSX3("F4_CODIGO")[1])
Private cPEConPg := space(TamSX3("E4_CODIGO")[1])
Private cPENatur := space(TamSX3("ED_CODIGO")[1])
Private cPEEspec := space(TamSX3("VVF_ESPECI")[1])
Private cPEMenPd := space(TamSX3("VVF_MENPAD")[1])
Private cPEMenNt := space(TamSX3("VVF_MENNOT")[1])
//
Private aAMS     := {}
Private aFiltAMS := {}
Private cFiltAMS := ""
//
Private aITE     := {}
//
Private oOkTik   := LoadBitmap( GetResources() , "LBTIK" )
Private oNoTik   := LoadBitmap( GetResources() , "LBNO" )
Private nTipOper := 0
Private cTipDoc  := "1" // Gerar ? ( 1=NF / 2=SD3 (Mov.Internas) )

Private lMSHelpAuto := .t. , lMSErroAuto := .f. , lMsFinalAuto := .f.
//
Do Case
	Case cMV_MIL0113 == "1" // Sempre NF
		aGerar := { STR0089 } // Notas Fiscais
	Case cMV_MIL0113 == "2" // Sempre Mov.Interna
		aGerar := { STR0090 } // Movimentações Internas
	Case cMV_MIL0113 == "3" // Usuario escolhe o tipo
		aGerar := { STR0089 , STR0090 } // Notas Fiscais / Movimentações Internas
EndCase
//
AADD(aParamBox,{2,IIf(nOperacao==1,STR0063,STR0064),"",{ cSiglaAMS , STR0062 },90,"",.f.,".t."}) // Tipo a Agregar / Tipo a Desagregar / Peça
AADD(aParamBox,{2,STR0091,"",aGerar,90,"",.f.,".t."}) // Gerar
For ni := 1 to len(aParambox)
	aAdd(aRetTip,aParambox[ni,3]) // Carregando conteudo Default
Next
If ParamBox(aParamBox,"",@aRetTip,,,,,,,,.f.)
	nTipOper := IIf(aRetTip[1]==cSiglaAMS,1,2)
	cTipDoc  := IIf(aRetTip[2]==STR0089,"1","2") // 1=NF / 2=SD3 (Mov.Internas)     /     Notas Fiscais
EndIf
If nTipOper == 0
	Return .f.
EndIf
//
FS_ADD_ITE() // Cria registro em branco no aITE
//
If cTipDoc == "2" // Gerar 2=SD3 (Mov.Internas)
	If Empty(GetNewPar("MV_MIL0114","")) .or. Empty(GetNewPar("MV_MIL0115",""))
		MsgStop(STR0092,STR0025) // Antes de iniciar o processo de Agrega/Desagrega, é necessário configurar os parametros MV_MIL0114 e MV_MIL0115, que correspondem aos Tipos de Movimentações Internas de Entrada e Saida. / Atencao
		Return .f.
	EndIf
	aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt)
	SA1->(DbSetOrder(3))
	If SA1->(DbSeek(xFilial("SA1")+aSM0[SM0_CGC])) .or. SA1->(DbSeek(xFilial("SA1")+left(aSM0[SM0_CGC],8)))
		If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
			Return .f.
		EndIf
		cSCdCli := SA1->A1_COD
		cSLjCli := SA1->A1_LOJA
	EndIf
	SA2->(DbSetOrder(3))
	If SA2->(DbSeek(xFilial("SA2")+aSM0[SM0_CGC])) .or. SA2->(DbSeek(xFilial("SA2")+left(aSM0[SM0_CGC],8)))
		If oFornece:Bloqueado( SA2->A2_COD , SA2->A2_LOJA , .T. ) // Fornecedor Bloqueado ?
			Return .f.
		EndIf
		cECdFor := SA2->A2_COD
		cELjFor := SA2->A2_LOJA
	EndIf
EndIf
//
cTitulo := IIf(nTipOper==1,cSiglaAMS,STR0062)+" - "+cTitulo // XXX / Peca
//
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0 ,  24 , .T. , .F. } ) // Equipamento
AAdd( aObjects, { 0 ,   0 , .T. , .T. } ) // ListBox AMS/PECAS
If cTipDoc == "1" // Gerar 1=NF
	AAdd( aObjects, { 0 , 133 , .T. , .F. } ) // Campos NFs de SAIDA/ENTRADA do EQUIPAMENTO
Else // cTipDoc == "2" // Gerar 2=SD3 (Mov.Internas)
	AAdd( aObjects, { 0 ,  35 , .T. , .F. } ) // Campos Mov.Interna SAIDA/ENTRADA
EndIf
aPos := MsObjSize( aInfo, aObjects )
//
If FS_VALIDVEI(cChaInt)
	//
	cDesVei += " - "+Alltrim(FM_SQL("SELECT VV2_DESMOD FROM "+RetSqlName("VV2")+" WHERE VV2_FILIAL='"+xFilial("VV2")+"' AND VV2_CODMAR='"+VV1->VV1_CODMAR+"' AND VV2_MODVEI='"+VV1->VV1_MODVEI+"' AND D_E_L_E_T_=' ' "))
	cDesVei += " ( "+Alltrim(FM_SQL("SELECT VVC_DESCRI FROM "+RetSqlName("VVC")+" WHERE VVC_FILIAL='"+xFilial("VVC")+"' AND VVC_CODMAR='"+VV1->VV1_CODMAR+"' AND VVC_CORVEI='"+VV1->VV1_CORVEI+"' AND D_E_L_E_T_=' ' "))+" )"
    //
	cLocAux := VV1->VV1_LOCPAD
	If Empty(cLocAux)
		cLocAux := GETMV("MV_LOCVEIN") //Novo
		If VV1->VV1_ESTVEI == '1'
			cLocAux := GETMV("MV_LOCVEIU") //Usado
		EndIf
	EndIf
	FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
	SB1->(dbSetOrder(1))
	If Empty(cLocAux)
		cLocAux := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
	EndIf
	SB2->(dbSetOrder(1))
	If SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+cLocAux))
		nCusAtu := round(SB2->B2_CM1,2) // Custo Atual do Equipamento
		nCusFut := round(SB2->B2_CM1,2) // Custo Futuro do Equipamento (apos Agregar/Desagregar)
	EndIf
	cB1_COD := SB1->B1_COD
	//
	DEFINE MSDIALOG oTelaAGRDES TITLE cTitulo FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL
		//
		oTelaAGRDES:lEscClose := .F.
		//
		@ aPos[1,1] + 000 , aPos[1,2] + 001 TO aPos[1,3],aPos[1,4]-150 LABEL STR0003 OF oTelaAGRDES PIXEL // Equipamento
		@ aPos[1,1] + 010 , aPos[1,2] + 006 SAY (STR0004+":") OF oTelaAGRDES PIXEL
		@ aPos[1,1] + 009 , aPos[1,2] + 026 MSGET oChassi VAR cChassi PICTURE "@!" SIZE 73,08 OF oTelaAGRDES WHEN .f. PIXEL HASBUTTON
		@ aPos[1,1] + 009 , aPos[1,2] + 100 MSGET oDesVei VAR cDesVei PICTURE "@!" SIZE (aPos[1,4]-257),08 OF oTelaAGRDES WHEN .f. PIXEL HASBUTTON
		@ aPos[1,1] + 000 , aPos[1,4] - 145 TO aPos[1,3],aPos[1,4] - 075 LABEL STR0009 OF oTelaAGRDES PIXEL // Custo atual
		@ aPos[1,1] + 009 , aPos[1,4] - 140 MSGET oCusAtu VAR nCusAtu PICTURE "@E 999,999,999.99" SIZE 61,08 OF oTelaAGRDES WHEN .f. PIXEL HASBUTTON
		@ aPos[1,1] + 000 , aPos[1,4] - 070 TO aPos[1,3],aPos[1,4] - 000 LABEL STR0010 OF oTelaAGRDES PIXEL // Custo futuro
		@ aPos[1,1] + 009 , aPos[1,4] - 065 MSGET oCusFut VAR nCusFut PICTURE "@E 999,999,999.99" SIZE 61,08 OF oTelaAGRDES WHEN .f. PIXEL HASBUTTON
		//
			nTamCol := ( aPos[3,4] / 2 )
		//
		If nTipOper == 1 // AMS
			FS_LEVAMS(.t.,nOperacao)
			@ aPos[2,1],aPos[2,2]+1 TO aPos[2,3],aPos[2,4] LABEL cTitulo OF oTelaAGRDES PIXEL
			If nOperacao == 1 // Agregar
				@ aPos[2,1]+010,aPos[2,2]+006 SAY (STR0008+":") OF oTelaAGRDES PIXEL
				@ aPos[2,1]+009,aPos[2,2]+026 MSCOMBOBOX oFiltAMS VAR cFiltAMS SIZE 200,08 COLOR CLR_BLACK ITEMS aFiltAMS OF oTelaAGRDES ON CHANGE FS_LEVAMS(.f.,nOperacao) PIXEL COLOR CLR_BLUE
			ElseIf nOperacao == 2 // Desagregar
				DEFINE SBUTTON FROM @ aPos[2,1]+009,aPos[2,2]+006 TYPE  4 ACTION FS_IAEAMS(nOperacao,oLboxAMS:nAt,"I",1) ENABLE ONSTOP STR0005 OF oTelaAGRDES // Incluir
				DEFINE SBUTTON FROM @ aPos[2,1]+009,aPos[2,2]+041 TYPE 11 ACTION FS_IAEAMS(nOperacao,oLboxAMS:nAt,"A",1) ENABLE ONSTOP STR0006 OF oTelaAGRDES WHEN !Empty(aAMS[oLboxAMS:nAt,3]) // Editar
				DEFINE SBUTTON FROM @ aPos[2,1]+009,aPos[2,2]+076 TYPE  3 ACTION FS_IAEAMS(nOperacao,oLboxAMS:nAt,"E",1) ENABLE ONSTOP STR0007 OF oTelaAGRDES WHEN !Empty(aAMS[oLboxAMS:nAt,3]) // Excluir
			EndIf
			@ aPos[2,1]+024,aPos[2,2]+005 LISTBOX oLboxAMS FIELDS HEADER "",STR0011,cSiglaAMS,STR0013,STR0084,STR0085,STR0086,STR0087 ;
														 COLSIZES 10,50,200,63,63,63,63,63 SIZE aPos[2,4]-12,aPos[2,3]-aPos[2,1]-29 OF oTelaAGRDES PIXEL ;
														 ON DBLCLICK IIf(!Empty(aAMS[oLboxAMS:nAt,3]),FS_IAEAMS(nOperacao,oLboxAMS:nAt,"A",oLboxAMS:nColPos),.t.)
			oLboxAMS:SetArray(aAMS)
			oLboxAMS:bLine := { || { IIf(aAMS[oLboxAMS:nAt,1],oOkTik,oNoTik) , aAMS[oLboxAMS:nAt,2] , aAMS[oLboxAMS:nAt,3] , FG_AlinVlrs(Transform(aAMS[oLboxAMS:nAt,04],"@E 999,999,999.99")) , aAMS[oLboxAMS:nAt,18] , aAMS[oLboxAMS:nAt,19] , aAMS[oLboxAMS:nAt,20] , aAMS[oLboxAMS:nAt,21] }}
		ElseIf nTipOper == 2 // PECA SB1
			DEFINE SBUTTON FROM @ aPos[2,1]+009,aPos[2,2]+006 TYPE  4 ACTION FS_IAEITE(nOperacao,oLboxITE:nAt,"I") ENABLE ONSTOP STR0005 OF oTelaAGRDES // Incluir
			DEFINE SBUTTON FROM @ aPos[2,1]+009,aPos[2,2]+041 TYPE 11 ACTION FS_IAEITE(nOperacao,oLboxITE:nAt,"A") ENABLE ONSTOP STR0006 OF oTelaAGRDES // Editar
			DEFINE SBUTTON FROM @ aPos[2,1]+009,aPos[2,2]+076 TYPE  3 ACTION FS_IAEITE(nOperacao,oLboxITE:nAt,"E") ENABLE ONSTOP STR0007 OF oTelaAGRDES // Excluir
			@ aPos[2,1],aPos[2,2]+1 TO aPos[2,3],aPos[2,4] LABEL cTitulo OF oTelaAGRDES PIXEL
			@ aPos[2,1]+024,aPos[2,2]+005 LISTBOX oLboxITE FIELDS HEADER "",STR0065,STR0066,STR0067,STR0068,STR0069 ;
														 COLSIZES 10,40,80,150,40,63 SIZE aPos[2,4]-12,aPos[2,3]-aPos[2,1]-29 OF oTelaAGRDES PIXEL ;
														 ON DBLCLICK FS_IAEITE(nOperacao,oLboxITE:nAt,"A")
			oLboxITE:SetArray(aITE)
			oLboxITE:bLine := { || { IIf(aITE[oLboxITE:nAt,1],oOkTik,oNoTik) , aITE[oLboxITE:nAt,2] , aITE[oLboxITE:nAt,3] , aITE[oLboxITE:nAt,4] , FG_AlinVlrs(Transform(aITE[oLboxITE:nAt,5],"@E 9,999")) , FG_AlinVlrs(Transform(aITE[oLboxITE:nAt,6],"@E 9,999,999.99")) }}
		EndIf
		//
		If cTipDoc == "1" // Gerar 1=NF
			//
			nTamCol := ( aPos[3,4] / 2 )
			//
			@ aPos[3,1],aPos[3,2]+1 TO aPos[3,3],(nTamCol-3) LABEL STR0014 OF oTelaAGRDES PIXEL // Dados adicionais para emissao da NF de Saida do Equipamento
			@ aPos[3,1] + 011 , aPos[3,2] + ( nTamCol * 0 ) + 005 SAY (STR0016+":") OF oTelaAGRDES PIXEL COLOR CLR_HBLUE // Cliente
			@ aPos[3,1] + 010 , aPos[3,2] + ( nTamCol * 0 ) + 050 MSGET oSCdCli VAR cSCdCli F3 "SA1" VALID ( vazio() .or. FS_CLIFOR(1) ) PICTURE "@!" SIZE 36,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 010 , aPos[3,2] + ( nTamCol * 0 ) + 087 MSGET oSLjCli VAR cSLjCli VALID ( vazio() .or. FS_CLIFOR(1) ) PICTURE "@!" SIZE 10,08 OF oTelaAGRDES PIXEL COLOR CLR_BLACK
			@ aPos[3,1] + 023 , aPos[3,2] + ( nTamCol * 0 ) + 005 SAY (STR0017+":") OF oTelaAGRDES PIXEL
			@ aPos[3,1] + 022 , aPos[3,2] + ( nTamCol * 0 ) + 050 MSGET oSTpOpe VAR cSTpOpe F3 "DJ" VALID ( vazio() .or. FG_Seek("SX5","'DJ'+cSTpOpe",1) ) PICTURE "@!" SIZE 30,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 035 , aPos[3,2] + ( nTamCol * 0 ) + 005 SAY (STR0018+":") OF oTelaAGRDES PIXEL COLOR CLR_BLACK
			@ aPos[3,1] + 034 , aPos[3,2] + ( nTamCol * 0 ) + 050 MSGET oSCdTES VAR cSCdTES F3 "SF4" VALID ( vazio() .or. ( FG_Seek("SF4","cSCdTES",1) .and. MaAvalTes("S",cSCdTES) ) ) PICTURE "@!" SIZE 30,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 047 , aPos[3,2] + ( nTamCol * 0 ) + 005 SAY (STR0019+":") OF oTelaAGRDES PIXEL COLOR CLR_HBLUE
			@ aPos[3,1] + 046 , aPos[3,2] + ( nTamCol * 0 ) + 050 MSGET oSCdVen VAR cSCdVen F3 "SA3" VALID ( vazio() .or. FG_Seek("SA3","cSCdVen",1) ) PICTURE "@!" SIZE 40,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 059 , aPos[3,2] + ( nTamCol * 0 ) + 005 SAY (STR0020+":") OF oTelaAGRDES PIXEL
			@ aPos[3,1] + 058 , aPos[3,2] + ( nTamCol * 0 ) + 050 MSGET oSConPg VAR cSConPg F3 "SE4" VALID ( vazio() .or. ( FG_Seek("SE4","cSConPg",1) .and. !(SE4->E4_TIPO $ "A.9") ) ) PICTURE "@!" SIZE 30,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 071 , aPos[3,2] + ( nTamCol * 0 ) + 005 SAY (STR0021+":") OF oTelaAGRDES PIXEL
			@ aPos[3,1] + 070 , aPos[3,2] + ( nTamCol * 0 ) + 050 MSGET oSNatur VAR cSNatur F3 "SED" VALID ( vazio() .or. FG_Seek("SED","cSNatur",1) ) PICTURE "@!" SIZE 50,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 071 , aPos[3,2] + ( nTamCol * 0 ) + 115 SAY (STR0022+":") OF oTelaAGRDES PIXEL
			@ aPos[3,1] + 070 , aPos[3,2] + ( nTamCol * 0 ) + 150 MSGET oSCdBan VAR cSCdBan F3 "SA6" VALID ( vazio() .or. FG_Seek("SA6","cSCdBan",1) ) PICTURE "@!" SIZE 30,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 083 , aPos[3,2] + ( nTamCol * 0 ) + 005 SAY (RetTitle("VV0_MENPAD")+":") OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Mensagem NF
			@ aPos[3,1] + 082 , aPos[3,2] + ( nTamCol * 0 ) + 050 MSGET oSMenPd VAR cSMenPd F3 "SM4" VALID (texto().Or.Vazio()) PICTURE "@!" SIZE 50,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 083 , aPos[3,2] + ( nTamCol * 0 ) + 115 SAY (RetTitle("VV0_MENNOT")+":") OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Mensagem NF
			@ aPos[3,1] + 082 , aPos[3,2] + ( nTamCol * 0 ) + 150 MSGET oSMenNt VAR cSMenNt PICTURE "@!" SIZE (nTamCol-161),08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 011 , aPos[3,2] + ( nTamCol * 0 ) + 115 SAY (STR0058+":") OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Observacao da NF de Saida
			@ aPos[3,1] + 022 , aPos[3,2] + ( nTamCol * 0 ) + 115 GET oSObsNF VAR cSObsNF OF oTelaAGRDES MEMO SIZE (nTamCol-127),045 PIXEL

			nPosCC := 0
			If nTipOper <> 2 .or. nOperacao <> 1
				nPosCC := 9 // Pular espaco para separar bloco
			EndIf
			@ aPos[3,1] + 095 + nPosCC , aPos[3,2] + ( nTamCol * 0 ) + 005 SAY STR0084 OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Centro de Custo
			@ aPos[3,1] + 103 + nPosCC , aPos[3,2] + ( nTamCol * 0 ) + 005 MSGET oSCC VAR cSCC F3 "CTT" VALID (Vazio() .or. Ctb105CC()) PICTURE "@!" SIZE 45,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 095 + nPosCC , aPos[3,2] + ( nTamCol * 0 ) + 055 SAY STR0085 OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Conta Contabil
			@ aPos[3,1] + 103 + nPosCC , aPos[3,2] + ( nTamCol * 0 ) + 055 MSGET oSCONTA VAR cSCONTA F3 "CT1" VALID (Vazio() .or. Ctb105Cta()) PICTURE "@!" SIZE 80,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 095 + nPosCC , aPos[3,2] + ( nTamCol * 0 ) + 140 SAY STR0086 OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Item Conta Contabil
			@ aPos[3,1] + 103 + nPosCC , aPos[3,2] + ( nTamCol * 0 ) + 140 MSGET oSITEMCC VAR cSITEMCC F3 "CTD" VALID (Vazio() .or. Ctb105Item()) PICTURE "@!" SIZE 50,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 095 + nPosCC , aPos[3,2] + ( nTamCol * 0 ) + 195 SAY STR0087 OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Classe Valor
			@ aPos[3,1] + 103 + nPosCC , aPos[3,2] + ( nTamCol * 0 ) + 195 MSGET oSCLVL VAR cSCLVL F3 "CTH" VALID (Vazio() .or. Ctb105ClVl()) PICTURE "@!" SIZE 45,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			If VV0->(ColumnPos("VV0_INDPRE")) > 0
				cSPComp := criavar("VV0_INDPRE")
				aSPComp := X3CBOXAVET("VV0_INDPRE","0")
				@ aPos[3,1] + 095 + nPosCC , aPos[3,2] + ( nTamCol * 0 ) + 245 SAY RetTitle("VV0_INDPRE") OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Pres.Comprador
				@ aPos[3,1] + 103 + nPosCC , aPos[3,2] + ( nTamCol * 0 ) + 245 MSCOMBOBOX oSPComp VAR cSPComp SIZE 100,08 COLOR CLR_BLACK ITEMS aSPComp OF oTelaAGRDES PIXEL
			EndIf

			If nTipOper == 2 // PECA SB1
				If nOperacao == 1 // Agregar
					@ aPos[3,1] + 117 , aPos[3,2] + 1 TO aPos[3,3],(nTamCol-3) LABEL "" OF oTelaAGRDES PIXEL
					@ aPos[3,1] + 121 , aPos[3,2] + ( nTamCol * 0 ) + 005 SAY (STR0070) OF oTelaAGRDES PIXEL COLOR CLR_HBLUE // NF de Saida da(s) Peca(s)
					@ aPos[3,1] + 121 , aPos[3,2] + ( nTamCol * 0 ) + 080 SAY (STR0017+":") OF oTelaAGRDES PIXEL
					@ aPos[3,1] + 120 , aPos[3,2] + ( nTamCol * 0 ) + 115 MSGET oPSTpOpe VAR cPSTpOpe F3 "DJ" VALID ( vazio() .or. FG_Seek("SX5","'DJ'+cPSTpOpe",1) ) PICTURE "@!" SIZE 30,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
					@ aPos[3,1] + 121 , aPos[3,2] + ( nTamCol * 0 ) + 150 SAY (STR0018+":") OF oTelaAGRDES PIXEL COLOR CLR_BLACK
					@ aPos[3,1] + 120 , aPos[3,2] + ( nTamCol * 0 ) + 165 MSGET oPSCdTES VAR cPSCdTES F3 "SF4" VALID ( vazio() .or. ( FG_Seek("SF4","cPSCdTES",1) .and. MaAvalTes("S",cPSCdTES) ) ) PICTURE "@!" SIZE 30,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
					If SC5->(ColumnPos("C5_INDPRES")) > 0
						cPSPComp := criavar("C5_INDPRES")
						aPSPComp := X3CBOXAVET("C5_INDPRES","0")
						@ aPos[3,1] + 121 , aPos[3,2] + ( nTamCol * 0 ) + 203 SAY (RetTitle("C5_INDPRES")+":") OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Pres.Comprador
						@ aPos[3,1] + 120 , aPos[3,2] + ( nTamCol * 0 ) + 245 MSCOMBOBOX oPSPComp VAR cPSPComp SIZE 100,08 COLOR CLR_BLACK ITEMS aPSPComp OF oTelaAGRDES PIXEL
					EndIf
				EndIf
			EndIf
			//
			@ aPos[3,1],nTamCol+1 TO aPos[3,3],aPos[3,4] LABEL STR0015 OF oTelaAGRDES PIXEL // Dados adicionais para emissao da NF de Entrada do Equipamento
			@ aPos[3,1] + 011 , aPos[3,2] + ( nTamCol * 1 ) + 005 SAY (STR0023+":") OF oTelaAGRDES PIXEL COLOR CLR_HBLUE // Fornecedor
			@ aPos[3,1] + 010 , aPos[3,2] + ( nTamCol * 1 ) + 050 MSGET oECdFor VAR cECdFor F3 "SAA2" VALID ( vazio() .or. FS_CLIFOR(2) ) PICTURE "@!" SIZE 36,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 010 , aPos[3,2] + ( nTamCol * 1 ) + 087 MSGET oELjFor VAR cELjFor VALID ( vazio() .or. FS_CLIFOR(2) ) PICTURE "@!" SIZE 10,08 OF oTelaAGRDES PIXEL COLOR CLR_BLACK
			@ aPos[3,1] + 023 , aPos[3,2] + ( nTamCol * 1 ) + 005 SAY (STR0017+":") OF oTelaAGRDES PIXEL
			@ aPos[3,1] + 022 , aPos[3,2] + ( nTamCol * 1 ) + 050 MSGET oETpOpe VAR cETpOpe F3 "DJ" VALID ( vazio() .or. FG_Seek("SX5","'DJ'+cETpOpe",1) ) PICTURE "@!" SIZE 30,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 035 , aPos[3,2] + ( nTamCol * 1 ) + 005 SAY (STR0018+":") OF oTelaAGRDES PIXEL COLOR CLR_BLACK
			@ aPos[3,1] + 034 , aPos[3,2] + ( nTamCol * 1 ) + 050 MSGET oECdTES VAR cECdTES F3 "SF4" VALID ( vazio() .or. ( FG_Seek("SF4","cECdTES",1) .and. MaAvalTes("E",cECdTES) ) ) PICTURE "@!" SIZE 30,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 047 , aPos[3,2] + ( nTamCol * 1 ) + 005 SAY (STR0024+":") OF oTelaAGRDES PIXEL
			@ aPos[3,1] + 046 , aPos[3,2] + ( nTamCol * 1 ) + 050 MSGET oEEspec VAR cEEspec F3 "42" VALID ( vazio() .or. FG_Seek("SX5","'42'+cEEspec",1) ) PICTURE "@!" SIZE 40,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 059 , aPos[3,2] + ( nTamCol * 1 ) + 005 SAY (STR0020+":") OF oTelaAGRDES PIXEL
			@ aPos[3,1] + 058 , aPos[3,2] + ( nTamCol * 1 ) + 050 MSGET oEConPg VAR cEConPg F3 "SE4" VALID ( vazio() .or. ( FG_Seek("SE4","cEConPg",1) .and. !(SE4->E4_TIPO $ "A.9") ) ) PICTURE "@!" SIZE 30,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 071 , aPos[3,2] + ( nTamCol * 1 ) + 005 SAY (STR0021+":") OF oTelaAGRDES PIXEL
			@ aPos[3,1] + 070 , aPos[3,2] + ( nTamCol * 1 ) + 050 MSGET oENatur VAR cENatur F3 "SED" VALID ( vazio() .or. FG_Seek("SED","cENatur",1) ) PICTURE "@!" SIZE 50,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 083 , aPos[3,2] + ( nTamCol * 1 ) + 005 SAY (RetTitle("VVF_MENPAD")+":") OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Mensagem NF
			@ aPos[3,1] + 082 , aPos[3,2] + ( nTamCol * 1 ) + 050 MSGET oEMenPd VAR cEMenPd F3 "SM4" VALID (texto().Or.Vazio()) PICTURE "@!" SIZE 50,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 083 , aPos[3,2] + ( nTamCol * 1 ) + 115 SAY (RetTitle("VVF_MENNOT")+":") OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Mensagem NF
			@ aPos[3,1] + 082 , aPos[3,2] + ( nTamCol * 1 ) + 150 MSGET oEMenNt VAR cEMenNt PICTURE "@!" SIZE (nTamCol-158),08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 011 , aPos[3,2] + ( nTamCol * 1 ) + 115 SAY (STR0059+":") OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Observacao da NF de Entrada
			@ aPos[3,1] + 022 , aPos[3,2] + ( nTamCol * 1 ) + 115 GET oEObsNF VAR cEObsNF OF oTelaAGRDES MEMO SIZE (nTamCol-124),045 PIXEL

			nPosCC := 0
			If nTipOper <> 2 .or. nOperacao <> 2
				nPosCC := 9 // Pular espaco para separar bloco
			EndIf
			@ aPos[3,1] + 095 + nPosCC , aPos[3,2] + ( nTamCol * 1 ) + 005 SAY STR0084 OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Centro de Custo
			@ aPos[3,1] + 103 + nPosCC , aPos[3,2] + ( nTamCol * 1 ) + 005 MSGET oECC VAR cECC F3 "CTT" VALID (Vazio() .or. Ctb105CC()) PICTURE "@!" SIZE 45,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 095 + nPosCC , aPos[3,2] + ( nTamCol * 1 ) + 055 SAY STR0085 OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Conta Contabil
			@ aPos[3,1] + 103 + nPosCC , aPos[3,2] + ( nTamCol * 1 ) + 055 MSGET oECONTA VAR cECONTA F3 "CT1" VALID (Vazio() .or. Ctb105Cta()) PICTURE "@!" SIZE 80,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 095 + nPosCC , aPos[3,2] + ( nTamCol * 1 ) + 140 SAY STR0086 OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Item Conta Contabil
			@ aPos[3,1] + 103 + nPosCC , aPos[3,2] + ( nTamCol * 1 ) + 140 MSGET oEITEMCC VAR cEITEMCC F3 "CTD" VALID (Vazio() .or. Ctb105Item()) PICTURE "@!" SIZE 50,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 095 + nPosCC , aPos[3,2] + ( nTamCol * 1 ) + 195 SAY STR0087 OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Classe Valor
			@ aPos[3,1] + 103 + nPosCC , aPos[3,2] + ( nTamCol * 1 ) + 195 MSGET oECLVL VAR cECLVL F3 "CTH" VALID (Vazio() .or. Ctb105ClVl()) PICTURE "@!" SIZE 45,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK

			If nTipOper == 2 // PECA SB1
				If nOperacao == 2 // Desagregar
					@ aPos[3,1] + 117 , nTamCol+1 TO aPos[3,3],aPos[3,4] LABEL "" OF oTelaAGRDES PIXEL
					@ aPos[3,1] + 121 , aPos[3,2] + ( nTamCol * 1 ) + 005 SAY (STR0071) OF oTelaAGRDES PIXEL COLOR CLR_HBLUE // NF de Entrada da(s) Peca(s)
					@ aPos[3,1] + 121 , aPos[3,2] + ( nTamCol * 1 ) + 085 SAY (STR0017+":") OF oTelaAGRDES PIXEL
					@ aPos[3,1] + 120 , aPos[3,2] + ( nTamCol * 1 ) + 120 MSGET oPETpOpe VAR cPETpOpe F3 "DJ" VALID ( vazio() .or. FG_Seek("SX5","'DJ'+cPETpOpe",1) ) PICTURE "@!" SIZE 30,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
					@ aPos[3,1] + 121 , aPos[3,2] + ( nTamCol * 1 ) + 155 SAY (STR0018+":") OF oTelaAGRDES PIXEL COLOR CLR_BLACK
					@ aPos[3,1] + 120 , aPos[3,2] + ( nTamCol * 1 ) + 170 MSGET oPECdTES VAR cPECdTES F3 "SF4" VALID ( vazio() .or. ( FG_Seek("SF4","cPECdTES",1) .and. MaAvalTes("E",cPECdTES) ) ) PICTURE "@!" SIZE 30,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
				EndIf
				//
			EndIf
			//
		Else // cTipDoc == "2" // Gerar 2=SD3 (Mov.Interna)
			//
			nTamCol := ( aPos[3,4] / 2 )
			//
			@ aPos[3,1],aPos[3,2]+1 TO aPos[3,3],(nTamCol-3) LABEL STR0098 OF oTelaAGRDES PIXEL // Dados adicionais para Mov.Interna de Saida do Equipamento
			@ aPos[3,1] + 011 , aPos[3,2] + ( nTamCol * 0 ) + 005 SAY STR0084 OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Centro de Custo
			@ aPos[3,1] + 019 , aPos[3,2] + ( nTamCol * 0 ) + 005 MSGET oSCC VAR cSCC F3 "CTT" VALID (Vazio() .or. Ctb105CC()) PICTURE "@!" SIZE 50,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 011 , aPos[3,2] + ( nTamCol * 0 ) + 060 SAY STR0085 OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Conta Contabil
			@ aPos[3,1] + 019 , aPos[3,2] + ( nTamCol * 0 ) + 060 MSGET oSCONTA VAR cSCONTA F3 "CT1" VALID (Vazio() .or. Ctb105Cta()) PICTURE "@!" SIZE 85,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 011 , aPos[3,2] + ( nTamCol * 0 ) + 150 SAY STR0086 OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Item Conta Contabil
			@ aPos[3,1] + 019 , aPos[3,2] + ( nTamCol * 0 ) + 150 MSGET oSITEMCC VAR cSITEMCC F3 "CTD" VALID (Vazio() .or. Ctb105Item()) PICTURE "@!" SIZE 50,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 011 , aPos[3,2] + ( nTamCol * 0 ) + 205 SAY STR0087 OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Classe Valor
			@ aPos[3,1] + 019 , aPos[3,2] + ( nTamCol * 0 ) + 205 MSGET oSCLVL VAR cSCLVL F3 "CTH" VALID (Vazio() .or. Ctb105ClVl()) PICTURE "@!" SIZE 50,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK

			@ aPos[3,1],nTamCol+1 TO aPos[3,3],aPos[3,4] LABEL STR0099 OF oTelaAGRDES PIXEL // Dados adicionais para Mov.Interna de Entrada do Equipamento
			@ aPos[3,1] + 011 , aPos[3,2] + ( nTamCol * 1 ) + 005 SAY STR0084 OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Centro de Custo
			@ aPos[3,1] + 019 , aPos[3,2] + ( nTamCol * 1 ) + 005 MSGET oECC VAR cECC F3 "CTT" VALID (Vazio() .or. Ctb105CC()) PICTURE "@!" SIZE 50,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 011 , aPos[3,2] + ( nTamCol * 1 ) + 060 SAY STR0085 OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Conta Contabil
			@ aPos[3,1] + 019 , aPos[3,2] + ( nTamCol * 1 ) + 060 MSGET oECONTA VAR cECONTA F3 "CT1" VALID (Vazio() .or. Ctb105Cta()) PICTURE "@!" SIZE 85,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 011 , aPos[3,2] + ( nTamCol * 1 ) + 150 SAY STR0086 OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Item Conta Contabil
			@ aPos[3,1] + 019 , aPos[3,2] + ( nTamCol * 1 ) + 150 MSGET oEITEMCC VAR cEITEMCC F3 "CTD" VALID (Vazio() .or. Ctb105Item()) PICTURE "@!" SIZE 50,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
			@ aPos[3,1] + 011 , aPos[3,2] + ( nTamCol * 1 ) + 205 SAY STR0087 OF oTelaAGRDES PIXEL COLOR CLR_BLACK // Classe Valor
			@ aPos[3,1] + 019 , aPos[3,2] + ( nTamCol * 1 ) + 205 MSGET oECLVL VAR cECLVL F3 "CTH" VALID (Vazio() .or. Ctb105ClVl()) PICTURE "@!" SIZE 50,08 OF oTelaAGRDES PIXEL HASBUTTON COLOR CLR_BLACK
	
		EndIf
		//
	ACTIVATE MSDIALOG oTelaAGRDES ON INIT (EnchoiceBar(oTelaAGRDES,{|| IIf( FS_VALIDVEI(cChaInt) .and. FS_VALIDOK(nOperacao) , ( lOKTela:=.t. , oTelaAGRDES:End() ) , .t. ) },{ || oTelaAGRDES:End()},,))
	//
	If lOKTela // OK Tela
		aTelaInf := {}
		BEGIN TRANSACTION

		INLCUI := .t.
		nOpc   := 3

		If Empty(cSConPg)
			cSConPg := RetCondVei()
		EndIf
		If Empty(cEConPg)
			cEConPg := RetCondVei()
		EndIf

		If nOperacao == 2 .and. nTipOper == 1 // DESAGREGAR AMS ( Necessario criar a COR, GRUPO DO MODELO e SB1 para os AMS's )

			For ni := 1 to len(aAMS)
				If aAMS[ni,01]
					cGTr := ""
					cNCM := ""
					VV2->(DbSetOrder(1))
					If VV2->(DbSeek(xFilial("VV2")+aAMS[ni,08]+aAMS[ni,09]))
						SB1->(DbSetOrder(1))
						If SB1->(DbSeek(xFilial("SB1")+VV2->VV2_PRODUT))
							cGTr := SB1->B1_GRTRIB
							cNCM := SB1->B1_POSIPI
						EndIf
					EndIf
					DbSelectArea("VV1")
					//
					lExistVV1 := .f.
					cChaIntAMS := ""
					If !Empty(aAMS[ni,2])
						cChaIntAMS := FM_SQL("SELECT VV1_CHAINT FROM "+RetSQLName("VV1")+" WHERE VV1_FILIAL='"+xFilial("VV1")+"' AND VV1_CHASSI='"+aAMS[ni,2]+"' AND D_E_L_E_T_=' '")
						If !Empty(cChaIntAMS)
							lExistVV1 := .t.
						EndIf
					EndIf
					//
					aVetVV1 := {}
					//
					If !lExistVV1 // NAO existe VV1 com o CHASSI
						//
						cChaIntAMS := GetSXENum("VV1","VV1_CHAINT")
						ConfirmSx8()
						aAdd(aVetVV1,{"VV1_FILIAL", xFilial("VV1")	, Nil})
						aAdd(aVetVV1,{"VV1_CHAINT", cChaIntAMS		, Nil})
						//
						If !Empty(aAMS[ni,2])
							aAdd(aVetVV1,{"VV1_CHASSI", aAMS[ni,2], Nil})
						Else
							aAdd(aVetVV1,{"VV1_CHASSI", cSiglaAMS+"_"+cChaIntAMS, Nil})
						EndIf
						//
						aAdd(aVetVV1,{"VV1_CODMAR", aAMS[ni,08], Nil})
						aAdd(aVetVV1,{"VV1_MODVEI", aAMS[ni,09], Nil})
						aAdd(aVetVV1,{"VV1_CORVEI", aAMS[ni,17], Nil})
						aAdd(aVetVV1,{"VV1_SITVEI", "0"		   , Nil})
						aAdd(aVetVV1,{"VV1_ESTVEI", "0"		   , Nil})
						aAdd(aVetVV1,{"VV1_LOCPAD", aAMS[ni,06], Nil})
						aAdd(aVetVV1,{"VV1_SUGVDA", aAMS[ni,10], Nil})
						aAdd(aVetVV1,{"VV1_GRASEV", "6"		   , Nil}) // SEM CHASSI ( AMS )
						aAdd(aVetVV1,{"VV1_DTHEMI", dToc(Date())+" "+Time(), Nil})
						aAdd(aVetVV1,{"VV1_FABMOD", StrZero(Year(dDataBase),4)+StrZero(Year(dDataBase),4), Nil})
						aAdd(aVetVV1,{"VV1_COMVEI", "9"		   , Nil})
						aAdd(aVetVV1,{"VV1_CODORI", IIf(!Empty(aAMS[ni,13]),aAMS[ni,13],"2"), Nil})
						aAdd(aVetVV1,{"VV1_PROVEI", IIf(!Empty(aAMS[ni,16]),aAMS[ni,16],"1"), Nil})
						aAdd(aVetVV1,{"VV1_INDCAL", "0"		   , Nil})
						aAdd(aVetVV1,{"VV1_VEIACO", "0"		   , Nil})
						aAdd(aVetVV1,{"VV1_TIPVEI", "1"		   , Nil})
						aAdd(aVetVV1,{"VV1_PROMOC", "0"		   , Nil})
						aAdd(aVetVV1,{"VV1_BLQPRO", "0"		   , Nil})
						aAdd(aVetVV1,{"VV1_FOTOS" , "0"		   , Nil})
						aAdd(aVetVV1,{"VV1_GRTRIB", IIf(!Empty(aAMS[ni,14]),aAMS[ni,14],cGTr), Nil})
						aAdd(aVetVV1,{"VV1_POSIPI", IIf(!Empty(aAMS[ni,15]),aAMS[ni,15],cNCM), Nil})
						aAdd(aVetVV1,{"VV1_CC"    , aAMS[ni,18], Nil})
						aAdd(aVetVV1,{"VV1_CONTA" , aAMS[ni,19], Nil})
						aAdd(aVetVV1,{"VV1_ITEMCC", aAMS[ni,20], Nil})
						aAdd(aVetVV1,{"VV1_CLVL"  , aAMS[ni,21], Nil})
						If lVV1_MSBLQL
							aAdd(aVetVV1,{"VV1_MSBLQL", "2"	   , Nil})
						EndIf
					EndIf

					DBSelectArea("VV1")
					DbSetOrder(1)
					lMsErroAuto := .f.
					If !DbSeek(xFilial("VV1")+cChaIntAMS)
						MSExecAuto({|x,y| VEIXA010(x,y)},aVetVV1,3) 
						if lMsErroAuto
							DisarmTransaction()
							MostraErro()
							return
						endif	
					endif
					
					aAMS[ni,02] := VV1->VV1_CHASSI
					aAMS[ni,05] := VV1->(RecNo())
					aAMS[ni,07] := SB1->B1_COD
					aAMS[ni,12] := VV1->VV1_CHAINT

					// Neste ponto de entrada poderá ser chamada uma tela para digitação de quaisquer campos que se deseja e
					// logo depois gravá-los, pois a tabela VV1 e SB1 estão posicionadas neste momento.
					If ExistBlock("VXX040DG")
						ExecBlock("VXX040DG",.f.,.f.)
					EndIf

				EndIf
			Next
		EndIf

		cCodVDV := GetSXENum("VDV","VDV_CODIGO") // Batizar o Codigo Sequencial do VDV
		ConfirmSx8()
		DbSelectArea("VDV")
		RecLock("VDV",.t.)
		VDV->VDV_FILIAL := xFilial("VDV")                             // Filial
		VDV->VDV_CODIGO := cCodVDV                                    // Codigo Sequencial do VDV
		VDV->VDV_STATUS := "1"                                        // 1=Ativo / 0=Cancelado
		VDV->VDV_AGRDES := strzero(nOperacao,1)                       // 1=Agrega / 2=Desagrega
		VDV->VDV_DATMOV := dDataBase                                  // Data do Movimento
		VDV->VDV_HORMOV := val(substr(time(),1,2)+substr(time(),4,2)) // Hora Movimento
		VDV->VDV_CODUSR := __cUserID                                  // Codigo do Usuário
		VDV->VDV_CHAINT := cChaInt                                    // Chassi Interno
		MsUnLock()
		nRecVDV := VDV->(RecNo())

		//////////////////////////////////////////
		// NF SAIDA   ( 1 Equipamento )         //
		//////////////////////////////////////////
		aAdd(xSAutoCab,{"VV0_FILIAL"  ,xFilial("VV0")		,Nil})
		aAdd(xSAutoCab,{"VV0_FORPRO"  ,"1"   		 		,Nil})
		aAdd(xSAutoCab,{"VV0_DATMOV"  ,dDataBase			,Nil})
		aAdd(xSAutoCab,{"VV0_CLIFOR"  ,"C"					,Nil})
		aAdd(xSAutoCab,{"VV0_CODCLI"  ,cSCdCli 				,Nil})
		aAdd(xSAutoCab,{"VV0_LOJA"    ,cSLjCli	 			,Nil})
		If cTipDoc == "1" // Gerar 1=NF
			If !Empty(cSCdBan)
				aAdd(xSAutoCab,{"VV0_CODBCO"  ,cSCdBan			,Nil})
			EndIf
			aAdd(xSAutoCab,{"VV0_FORPAG"  ,cSConPg		  		,Nil})
			If !Empty(cSNatur)
				aAdd(xSAutoCab,{"VV0_NATFIN"  ,cSNatur			,Nil})
			EndIf
			aAdd(xSAutoCab,{"VV0_CODVEN"  ,cSCdVen				,Nil})
			if VV0->(ColumnPos("VV0_MENPAD")) > 0
				aAdd(xSAutoCab,{"VV0_MENPAD" ,cSMenPd   		,Nil})
			Endif
			if VV0->(ColumnPos("VV0_MENNOT")) > 0
				aAdd(xSAutoCab,{"VV0_MENNOT" ,cSMenNt   		,Nil})
			Endif
		EndIf
		If VV0->(ColumnPos("VV0_INDPRE")) > 0 .and. !Empty(cSPComp)
			aAdd(xSAutoCab,{"VV0_INDPRE" ,cSPComp	,Nil})	// Presenca do Comprador
		Endif
		//
		xAutoIt := {}
		aAdd(xAutoIt,{"VVA_FILIAL"  ,xFilial("VVA")			,Nil})
		aAdd(xAutoIt,{"VVA_CHASSI"  ,cChassi  				,Nil})
		If cTipDoc == "1" // Gerar 1=NF
			cTESAux := cSCdTES
			If Empty(cTESAux)
				cTESAux := MaTesInt(2,cSTpOpe,cSCdCli,cSLjCli,"C",cB1_COD) // TES inteligente
			EndIf
			aAdd(xAutoIt,{"VVA_CODTES"  ,cTESAux				,Nil})
		EndIf
		DbSelectArea("VV1")
		DbGoTo(nRecVV1)
		VVG->(DbSetOrder(1)) // VVG_FILIAL+VVG_TRACPA+VVG_CHAINT
		VVG->(DbSeek( VV1->VV1_FILENT + VV1->VV1_TRACPA + VV1->VV1_CHAINT ))
		aAdd(xAutoIt,{"VVA_VALVDA"  ,VVG->VVG_VALUNI		,Nil})
		aAdd(xAutoIt,{"VVA_VALMOV"  ,nCusAtu				,Nil})
		aAdd(xAutoIt,{"VVA_CENCUS"  ,cSCC					,Nil})
		aAdd(xAutoIt,{"VVA_CONTA"   ,cSCONTA				,Nil})
		aAdd(xAutoIt,{"VVA_ITEMCT"  ,cSITEMCC				,Nil})
		aAdd(xAutoIt,{"VVA_CLVL"    ,cSCLVL					,Nil})
		aAdd(xSAutoItens,aClone(xAutoIt))
		//
		If nOperacao == 1 .and. nTipOper == 1 //  AGREGAR AMS
			//////////////////////////////////////////
			// NF SAIDA   ( + n AMS )               //
			//////////////////////////////////////////
			For ni := 1 to len(aAMS)
				If aAMS[ni,01]
					xAutoIt := {}
					aAdd(xAutoIt,{"VVA_FILIAL"  ,xFilial("VVA")	,Nil})
					aAdd(xAutoIt,{"VVA_CHASSI"  ,aAMS[ni,02] 	,Nil})
					If cTipDoc == "1" // Gerar 1=NF
						cTESAux := cSCdTES
						If Empty(cTESAux)
							cTESAux := MaTesInt(2,cSTpOpe,cSCdCli,cSLjCli,"C",aAMS[ni,07]) // TES inteligente
						EndIf
						aAdd(xAutoIt,{"VVA_CODTES"  ,cTESAux		,Nil})
					EndIf
					DbSelectArea("VV1")
					DbGoTo(aAMS[ni,05])

					// adicionado para voltar o FILENT após integração que está zerando o campo por motivos que não  vamos alterar a função gerla para não ocasionar maiores problemas e esforço.
					if ! Empty(VV1->VV1_FILENT)
						AADD(aVltFilDes, {aAMS[ni,05], VV1->VV1_FILENT})
					end

					VVG->(DbSetOrder(1)) // VVG_FILIAL+VVG_TRACPA+VVG_CHAINT
					VVG->(DbSeek( VV1->VV1_FILENT + VV1->VV1_TRACPA + VV1->VV1_CHAINT ))
					aAdd(xAutoIt,{"VVA_VALVDA" ,VVG->VVG_VALUNI	,Nil})
					aAdd(xAutoIt,{"VVA_VALMOV" ,aAMS[ni,04]		,Nil})
					aAdd(xAutoIt,{"VVA_CENCUS" ,aAMS[ni,18]		,Nil})
					aAdd(xAutoIt,{"VVA_CONTA"  ,aAMS[ni,19]		,Nil})
					aAdd(xAutoIt,{"VVA_ITEMCT" ,aAMS[ni,20]		,Nil})
					aAdd(xAutoIt,{"VVA_CLVL"   ,aAMS[ni,21]		,Nil})
					aAdd(xSAutoItens,aClone(xAutoIt))
				EndIf
			Next
		EndIf

		//////////////////////////////////////////
		// NF ENTRADA ( 1 Equipamento )         //
		//////////////////////////////////////////
		aAdd(xEAutoCab,{"VVF_FILIAL"  ,xFilial("VVF")  		,Nil})
		aAdd(xEAutoCab,{"VVF_FORPRO"  ,"1"   		  		,Nil})
		aAdd(xEAutoCab,{"VVF_CLIFOR"  ,"F"   		  		,Nil})
		aAdd(xEAutoCab,{"VVF_CODFOR"  ,cECdFor		  		,Nil})
		aAdd(xEAutoCab,{"VVF_LOJA "   ,cELjFor		 		,Nil})
		aAdd(xEAutoCab,{"VVF_DATEMI"  ,dDataBase			,Nil})
		If cTipDoc == "1" // Gerar 1=NF
			aAdd(xEAutoCab,{"VVF_FORPAG"  ,cEConPg			,Nil})
			If !Empty(cENatur)
				aAdd(xEAutoCab,{"VVF_NATURE"  ,cENatur		,Nil})
			EndIf
			If !Empty(cEEspec)
				aAdd(xEAutoCab,{"VVF_ESPECI"  ,cEEspec		,Nil})
			EndIf
			if VVF->(ColumnPos("VVF_MENPAD")) > 0
				aAdd(xEAutoCab,{"VVF_MENPAD" ,cEMenPd		,Nil})
			Endif
			if VVF->(ColumnPos("VVF_MENNOT")) > 0
				aAdd(xEAutoCab,{"VVF_MENNOT" ,cEMenNt		,Nil})
			Endif
		EndIf
		//
		xAutoIt := {}
		aAdd(xAutoIt,{"VVG_FILIAL"  ,xFilial("VVG")			,Nil})
		aAdd(xAutoIt,{"VVG_CHASSI"  ,cChassi				,Nil})
		aAdd(xAutoIt,{"VVG_CHAINT"  ,cChaInt				,Nil})
		If cTipDoc == "1" // Gerar 1=NF
			cTESAux := cECdTES
			If Empty(cTESAux)
				cTESAux := MaTesInt(1,cETpOpe,cECdFor,cELjFor,"F",cB1_COD) // TES inteligente
			EndIf
			aAdd(xAutoIt,{"VVG_CODTES"  ,cTESAux			,Nil})
		EndIf			
		aAdd(xAutoIt,{"VVG_LOCPAD"  ,cLocAux				,Nil})
		aAdd(xAutoIt,{"VVG_VALUNI"  ,nCusFut				,Nil})
		aAdd(xAutoIt,{"VVG_ESTVEI"  ,cEstVei				,Nil})
		aAdd(xAutoIt,{"VVG_CODORI"  ,cCODORI				,Nil})
		aAdd(xAutoIt,{"VVG_SITTRI"  ,cProvei				,Nil})
		aAdd(xAutoIt,{"VVG_CENCUS"  ,cECC					,Nil})
		aAdd(xAutoIt,{"VVG_CONTA"   ,cECONTA				,Nil})
		aAdd(xAutoIt,{"VVG_ITEMCT"  ,cEITEMCC				,Nil})
		aAdd(xAutoIt,{"VVG_CLVL"    ,cECLVL					,Nil})
		aAdd(xEAutoItens,aClone(xAutoIt))
		//
		If nOperacao == 2 .and. nTipOper == 1    //   DESAGREGAR AMS
			//////////////////////////////////////////
			// NF ENTRADA ( + n AMS )               //
			//////////////////////////////////////////
			For ni := 1 to len(aAMS)
				If aAMS[ni,01]
					xAutoIt := {}
					aAdd(xAutoIt,{"VVG_FILIAL"  ,xFilial("VVG")	,Nil})
					aAdd(xAutoIt,{"VVG_CHASSI"  ,aAMS[ni,02]	,Nil})
					aAdd(xAutoIt,{"VVG_CHAINT"  ,aAMS[ni,12]	,Nil})
					If cTipDoc == "1" // Gerar 1=NF
						cTESAux := cECdTES
						If Empty(cTESAux)
							cTESAux := MaTesInt(1,cETpOpe,cECdFor,cELjFor,"F",aAMS[ni,07]) // TES inteligente
						EndIf
						aAdd(xAutoIt,{"VVG_CODTES"  ,cTESAux		,Nil})
					EndIf
					aAdd(xAutoIt,{"VVG_LOCPAD"  ,aAMS[ni,06]	,Nil})
					aAdd(xAutoIt,{"VVG_VALUNI"  ,aAMS[ni,04]	,Nil})
					aAdd(xAutoIt,{"VVG_ESTVEI"  ,aAMS[ni,11]	,Nil})
					aAdd(xAutoIt,{"VVG_CODORI"  ,aAMS[ni,13]	,Nil})
					aAdd(xAutoIt,{"VVG_SITTRI"  ,aAMS[ni,16]	,Nil})
					aAdd(xAutoIt,{"VVG_CENCUS"  ,aAMS[ni,18]	,Nil})
					aAdd(xAutoIt,{"VVG_CONTA"   ,aAMS[ni,19]	,Nil})
					aAdd(xAutoIt,{"VVG_ITEMCT"  ,aAMS[ni,20]	,Nil})
					aAdd(xAutoIt,{"VVG_CLVL"    ,aAMS[ni,21]	,Nil})
					aAdd(xEAutoItens,aClone(xAutoIt))
				EndIf
			Next
		EndIf
		//
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+cB1_COD)
		//
		DbSelectArea("VV1")
		DbGoTo(nRecVV1)
		//
		lMsErroAuto := .f.
		//
		MSExecAuto({|x,y,w,z,k,l,m,n,o| VEIXX001(x,y,w,z,k,l,m,n,o)},xSAutoCab,xSAutoItens,{},3,"0",NIL,,aNumNFSF2,cTipDoc) // SAIDA POR VENDA
		//
		If lMsErroAuto
			DisarmTransaction()
			MostraErro()
			Return
		else
			For ni := 1 to LEN(aVltFilDes)
				VV1->(dbSelectArea('VV1'))
				VV1->(dbGoTo(aVltFilDes[ni, 1]))
				RecLock("VV1",.F.)
				VV1->VV1_FILENT := aVltFilDes[ni, 2]
				VV1->(MsUnLock())
			end
			aVltFilDes := {}
		EndIf
		ConfirmSx8() // Confirm do Nro NF

		If cTipDoc == "1" // Gerar 1=NF

			If SF2->(ColumnPos("F2_SDOC")) > 0
				cF2_SDOC := SF2->F2_SDOC
			EndIf
			aNumNFSF2[2] := SF2->F2_DOC
			aNumNFSF2[3] := SF2->F2_SERIE

		EndIf
		//
		cVDV_NUMTRA := VV0->VV0_NUMTRA
		//
		DbSelectArea("VV0")
		RecLock("VV0",.f.)
		VV0->VV0_TIPMOV := strzero(nOperacao,1) // Agregacao/Desagregacao
		MsUnLock()
		If !Empty(cSObsNF)
			MSMM(VV0->VV0_OBSMNF,TamSx3("VV0_OBSENF")[1],,cSObsNF,1,,,"VV0","VV0_OBSMNF")
		EndIf
		//
		If nOperacao == 1 .and. nTipOper == 2 // AGREGAR PECA
			//
			If cTipDoc == "1" // Gerar 1=NF
				//
				xSAutoCab   := {}
				xSAutoItens := {}
				xAutoIt     := {}
				//
				aAdd(xSAutoCab,{"C5_TIPO"   ,"N"		,Nil})
				aAdd(xSAutoCab,{"C5_CLIENTE",cSCdCli	,Nil})
				aAdd(xSAutoCab,{"C5_LOJACLI",cSLjCli	,Nil})
				aAdd(xSAutoCab,{"C5_VEND1"  ,cPSCdVen	,Nil})
				aAdd(xSAutoCab,{"C5_CONDPAG",cPSConPg	,Nil})
				aAdd(xSAutoCab,{"C5_COMIS1" ,0			,Nil})
				aAdd(xSAutoCab,{"C5_EMISSAO",ddatabase	,Nil})
				aAdd(xSAutoCab,{"C5_MENPAD" , cPSMenPd	,Nil})
				aAdd(xSAutoCab,{"C5_MENNOTA", cPSMenNt	,Nil})
				If !Empty(cPSCdBan)
					aAdd(xSAutoCab,{"C5_BANCO",cPSCdBan	,Nil})
				EndIf
				If !Empty(cPSNatur) .and. SC5->(ColumnPos("C5_NATUREZ")) > 0
					aAdd(xSAutoCab,{"C5_NATUREZ",cPSNatur,Nil})
				EndIf
				aAdd(xSAutoCab,{"C5_TIPOCLI",FM_SQL("SELECT A1_TIPO FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+cSCdCli+"' AND A1_LOJA='"+cSLjCli+"' AND D_E_L_E_T_=' '"),Nil})
				If SC5->(ColumnPos("C5_INDPRES")) > 0 .and. !Empty(cPSPComp)
					aAdd(xSAutoCab,{"C5_INDPRES", cPSPComp	,Nil})	// Presenca do Comprador
				EndIf
				//
				DBSelectArea("SB1")
				DBSetOrder(1)
				cNumIte := strzero(0,TamSX3("C6_ITEM")[1])
				For ni := 1 to len(aITE)
					SB1->(DbGoTo(aITE[ni,7]))
					xAutoIt := {}
					cNumIte := SOMA1(cNumIte)
					aAdd(xAutoIt,{"C6_ITEM"   ,cNumIte						,nil})
					aAdd(xAutoIt,{"C6_PRODUTO",SB1->B1_COD  				,nil})
					aAdd(xAutoIt,{"C6_QTDVEN" ,aITE[ni,5]					,nil})
					aAdd(xAutoIt,{"C6_ENTREG" ,dDataBase  					,nil})
					aAdd(xAutoIt,{"C6_UM"     ,SB1->B1_UM      				,nil})
					aAdd(xAutoIt,{"C6_TES"    ,aITE[ni,8]  					,nil})
					aAdd(xAutoIt,{"C6_LOCAL"  ,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"),nil})
					aAdd(xAutoIt,{"C6_PRUNIT" ,Round(aITE[ni,6]/aITE[ni,5],2),nil})
					aAdd(xAutoIt,{"C6_PRCVEN" ,Round(aITE[ni,6]/aITE[ni,5],2),nil})
					aAdd(xAutoIt,{"C6_VALOR"  ,Round(aITE[ni,6],2)			,nil})
					aAdd(xAutoIt,{"C6_VALDESC",0							,nil})
					aAdd(xAutoIt,{"C6_COMIS1" ,0           				   	,nil})
					aAdd(xAutoIt,{"C6_CLI"    ,cSCdCli						,nil})
					aAdd(xAutoIt,{"C6_LOJA"   ,cSLjCli						,nil})
					aAdd(xAutoIt,{"C6_CC"     ,aITE[ni,9]					,nil})
					aAdd(xAutoIt,{"C6_CONTA"  ,aITE[ni,10]					,nil})
					aAdd(xAutoIt,{"C6_ITEMCTA",aITE[ni,11]					,nil})
					aAdd(xAutoIt,{"C6_CLVL"   ,aITE[ni,12]					,nil})
					aAdd(xSAutoItens,aClone(xAutoIt))
				Next
				lMsErroAuto := .f.

				//
				// Ponto de Entrada antes do Pedido de Venda
				// 
				If ExistBlock("VXX040PV")
					ExecBlock("VXX040PV",.f.,.f.)
				Endif

				MSExecAuto({|x,y,z|Mata410(x,y,z)},xSAutoCab,xSAutoItens,3)
				//
				If lMsErroAuto
					DisarmTransaction()
					MostraErro()
					Return
				EndIf
				//
				cNumPed := SC5->C5_NUM
				//
				// Geração da NF
				//
				lCredito := .t.
				lEstoque := .t.
				lLiber   := .t.
				lTransf  := .f.
				//
				SC9->(dbSetOrder(1))
				SC6->(dbSetOrder(1))
				SC6->(dbSeek(xFilial("SC6") + cNumPed + "01"))
				While !SC6->(Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cNumPed
					//
					If !SC9->(dbSeek(xFilial("SC9")+cNumPed+SC6->C6_ITEM))
						nQtdLib := SC6->C6_QTDVEN
						nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,.t.,lLiber,lTransf)
					EndIf
					//
					SC6->(dbSkip())
				Enddo
				//
				aPvlNfs := {}
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Selecionando Itens para Faturamento ... ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cMsgSC9 := ""
				SB1->(dbSetOrder(1))
				SC5->(dbSetOrder(1))
				SC6->(dbSetOrder(1))
				SB5->(dbSetOrder(1))
				SB2->(dbSetOrder(1))
				SF4->(dbSetOrder(1))
				SE4->(dbSetOrder(1))
				SC9->(dbSeek(xFilial("SC9") + cNumPed + "01"))
				While !SC9->(Eof()) .and. xFilial("SC9") == SC9->C9_FILIAL .and. SC9->C9_PEDIDO == cNumPed
					If Empty(SC9->C9_BLCRED) .and. Empty(SC9->C9_BLEST)
						SC5->(dbSeek( xFilial("SC5") + SC9->C9_PEDIDO ))
						SC6->(dbSeek( xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM ))
						SB1->(dbSeek( xFilial("SB1") + SC9->C9_PRODUTO ))
						SB2->(dbSeek( xFilial("SB2") + SB1->B1_COD ))
						SB5->(dbSeek( xFilial("SB5") + SB1->B1_COD ))
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
				If !Empty(cMsgSC9)
					MsgStop(STR0093+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsgSC9,STR0025) // Pedido sem itens liberados! / Atencao
					DisarmTransaction()
					Return
				EndIf
				If len(aPvlNfs) == 0 .and. !FGX_SC5BLQ(cNumPed,.t.) // Verifica SC5 bloqueado
					DisarmTransaction()
					Return
				EndIf
				//
				ConfirmSx8()
				//
				cNumero := aIteNFSF2[2]
				cSerie  := aIteNFSF2[3]
				If Len(aPvlNfs) > 0
					PERGUNTE("MT460A",.f.)
					cNota := MaPvlNfs(aPvlNfs,cSerie,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1), .F., 0, 0, .T., .F.)
					If lMsErroauto
						DisarmTransaction()
						MostraErro()
						Return
					EndIf
				EndIf
				//
				if lMsErroAuto
					DisarmTransaction()
					MostraErro()
					Return
				Endif
				//
				ConfirmSx8() // Confirm do Nro NF
				//
				cNumero := aIteNFSF2[2] := SF2->F2_DOC
				//
				If SF2->(ColumnPos("F2_SDOC")) > 0
					cF2_SDOCP := SF2->F2_SDOC
				EndIf
				If Empty(SF2->F2_PREFORI) .or. Empty(SF2->F2_DUPL)
					DbSelectArea("SF2")
					RecLock("SF2",.f.)
						If Empty(SF2->F2_PREFORI)
							SF2->F2_PREFORI  := GetNewPar("MV_PREFBAL","BAL")
						EndIf
						If Empty(SF2->F2_DUPL) .and. FMX_VALFIN( SF2->F2_PREFIXO , SF2->F2_DOC , SF2->F2_CLIENTE , SF2->F2_LOJA ) <> 0
							SF2->F2_DUPL := SF2->F2_DOC
						EndIf
					MsUnLock()
				EndIf
				//
				DbSelectArea("SE1")
				DbSetOrder(1)
				DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL)
				While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1") .and. SE1->E1_PREFIXO==SF2->F2_PREFIXO .and. SE1->E1_NUM==SF2->F2_DUPL
					If !( SE1->E1_TIPO $ MVABATIM+"|"+MVIRABT+"|"+MVINABT+"|"+MVCFABT+"|"+MVCSABT+"|"+MVPIABT )
						RecLock("SE1",.f.)
						If Empty(SE1->E1_PORTADO) .and. !Empty(cPSCdBan)
							SE1->E1_PORTADO := cPSCdBan
						EndIf
						If Empty(SE1->E1_PREFORI) .and. !Empty(SF2->F2_PREFORI)
							SE1->E1_PREFORI := SF2->F2_PREFORI
						EndIf
						MsUnLock()
					EndIf
					DbSkip()
				EndDo
				aTelaInf := {SF2->F2_SERIE,SF2->F2_DOC,STR0072} // EMITIDO

			Else // cTipDoc == "2" // Gerar 2=SD3 (Mov.Interna)

				aSB1SD3 := {}
				For ni := 1 to len(aITE)
					SB1->(DbGoTo(aITE[ni,7]))
					// ( Codigo SB1 , Qtde , Valor , Centro de Custo , Conta Contab , Item Conta , Class.Valor )
					aAdd(aSB1SD3,{	SB1->B1_COD ,;
									aITE[ni,5] ,;
									aITE[ni,6] ,;
									aITE[ni,9] ,;
									aITE[ni,10] ,;
									aITE[ni,11] ,;
									aITE[ni,12] })
				Next

				If !VXX040SD3( "2" , "1" , cCodVDV , aSB1SD3 ) // Mov.Interna Peça ( 2=Saida , 1=Tp.Normal , Codigo VDV , aSB1 )
					DisarmTransaction()
					MostraErro()
					Return
				EndIf
			
			EndIf

		EndIf
		//
		If cTipDoc == "1" // Gerar 1=NF
			cSerie  := aNumNFSF1[3]
			cNumero := NxtSX5Nota(cSerie, NIL, GetNewPar("MV_TPNRNFS","1"))
			aNumNFSF1[2] := cNumero
		EndIf
		//
		DbSelectArea("VV1")
		DbGoTo(nRecVV1)
		RecLock("VV1",.f.)
			VV1->VV1_ULTMOV := "S" // Gravar S = SAIDA para nao bloquear ENTRADA
		MsUnLock()
		//
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+cB1_COD)
		//
		MSExecAuto({|x,y,w,z,k,l,m,n,o| VEIXX000(x,y,w,z,k,l,m,n,o)},xEAutoCab,xEAutoItens,{},3,"0",NIL,,aNumNFSF1,cTipDoc) // ENTRADA POR COMPRA
		//
		If lMsErroAuto
			DisarmTransaction()
			MostraErro()
			Return
		EndIf
		//
		ConfirmSx8() // Confirm do Nro NF
		//
		If cTipDoc == "1" // Gerar 1=NF
		
			If SF1->(ColumnPos("F1_SDOC")) > 0
				cF1_SDOC := SF1->F1_SDOC
			EndIf
			aNumNFSF1[2] := SF1->F1_DOC
			aNumNFSF1[3] := SF1->F1_SERIE
			cF1_FORNECE  := SF1->F1_FORNECE // Codigo do Fornecedor
			cF1_LOJA     := SF1->F1_LOJA    // Loja do Fornecedor
		
		EndIf
		//
		cVDV_TRACPA  := VVF->VVF_TRACPA
		//
		DbSelectArea("VVF")
		RecLock("VVF",.f.)
		VVF->VVF_TIPMOV := strzero(nOperacao,1) // Agregacao/Desagregacao
		MsUnLock()
		If !Empty(cEObsNF)
			MSMM(VVF->VVF_OBSMNF,TamSx3("VVF_OBSENF")[1],,cEObsNF,1,,,"VVF","VVF_OBSMNF")
		EndIf
		//
		If nOperacao == 2 .and. nTipOper == 2 // DESAGREGAR PECA
			//
			If cTipDoc == "1" // Gerar 1=NF
				//
				xEAutoCab   := {}
				xEAutoItens := {}
				xAutoIt     := {}
				//
				DBSelectArea("SA2")
				DBSetOrder(1)
				DBSeek(xFilial("SA2")+cECdFor+cELjFor)
				//
				cSerie  := aIteNFSF1[3]
				cNumero := NxtSX5Nota(cSerie, NIL, GetNewPar("MV_TPNRNFS","1"))
				aIteNFSF1[2] := cNumero
				//
				aAdd(xEAutoCab,{"F1_TIPO"	,"N"		,Nil})
				aAdd(xEAutoCab,{"F1_FORMUL"	,"S"    	,Nil})
				aAdd(xEAutoCab,{"F1_DOC"	,cNumero    ,Nil})
				aAdd(xEAutoCab,{"F1_SERIE"	,cSerie    	,Nil})
				aAdd(xEAutoCab,{"F1_EMISSAO",ddatabase	,Nil})
				aAdd(xEAutoCab,{"F1_FORNECE",cECdFor	,Nil})
				aAdd(xEAutoCab,{"F1_LOJA"	,cELjFor	,Nil})
				aadd(xEAutoCab,{"F1_ESPECIE",cPEEspec   ,Nil})
				aadd(xEAutoCab,{"F1_COND"	,cPEConPg	,Nil})
				aadd(xEAutoCab,{"F1_EST"	,SA2->A2_EST,Nil})
				aAdd(xEAutoCab,{"F1_MENPAD" ,cPEMenPd	,Nil})
				aAdd(xEAutoCab,{"F1_MENNOTA",cPEMenNt	,Nil})
				DBSelectArea("SB1")
				DBSetOrder(1)
				cNumIte := strzero(0,TamSX3("D1_ITEM")[1])
				For ni := 1 to len(aITE) // TES INTELIGENTE
					SB1->(DbGoTo(aITE[ni,7]))
					xAutoIt := {}
					cNumIte := SOMA1(cNumIte)
					aadd(xAutoIt,{"D1_ITEM"	,cNumIte	 					,Nil})
					aadd(xAutoIt,{"D1_COD"	,SB1->B1_COD 					,Nil})
					aAdd(xAutoIt,{"D1_UM"   ,SB1->B1_UM						,Nil})
					aadd(xAutoIt,{"D1_QUANT",aITE[ni,5]  					,Nil})
					aadd(xAutoIt,{"D1_VUNIT",Round(aITE[ni,6]/aITE[ni,5],2)	,Nil})
					aadd(xAutoIt,{"D1_TOTAL",Round(aITE[ni,6],2)			,Nil})
					aAdd(xAutoIt,{"D1_EMISSAO",dDataBase					,Nil})
					aadd(xAutoIt,{"D1_LOCAL",FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"),Nil})
					aadd(xAutoIt,{"D1_TES"	,aITE[ni,8]	  					,Nil})
					aAdd(xAutoIt,{"D1_CC"   ,aITE[ni,9]						,Nil})
					aAdd(xAutoIt,{"D1_CONTA",aITE[ni,10]					,Nil})
					aAdd(xAutoIt,{"D1_ITEMCTA",aITE[ni,11]					,Nil})
					aAdd(xAutoIt,{"D1_CLVL" ,aITE[ni,12]					,Nil})
					aadd(xEAutoItens,aClone(xAutoIt))
				Next
				//
				lMSHelpAuto := .t.
				lMsErroAuto := .f.
				MSExecAuto({|x,y,z| MATA103(x,y,z)},xEAutoCab,xEAutoItens,3)
				//
				If lMsErroAuto
					lMostraErro	:=.T.
					RollBAckSx8()
					DisarmTransaction()
				EndIf

				ConfirmSx8() // Confirm do Nro NF

				FMX_TELAINF( "1" , { { Alltrim(SF1->F1_SERIE) , Alltrim(SF1->F1_DOC) , STR0072 } } ) // EMITIDO
				aIteNFSF1[2] := SF1->F1_DOC
				aIteNFSF1[3] := SF1->F1_SERIE
				If SF1->(ColumnPos("F1_SDOC")) > 0
					cF1_SDOCP := SF1->F1_SDOC
				EndIf
				cF1_FORNECP  := SF1->F1_FORNECE // Codigo do  Fornecedor
				cF1_LOJAP    := SF1->F1_LOJA    // Loja do Fornecedor

			Else // cTipDoc == "2" // Gerar 2=SD3 (Mov.Interna)

				aSB1SD3 := {}
				For ni := 1 to len(aITE)
					SB1->(DbGoTo(aITE[ni,7]))
					// ( Codigo SB1 , Qtde , Valor , Centro de Custo , Conta Contab , Item Conta , Class.Valor )
					aAdd(aSB1SD3,{	SB1->B1_COD ,;
									aITE[ni,5] ,;
									aITE[ni,6] ,;
									aITE[ni,9] ,;
									aITE[ni,10] ,;
									aITE[ni,11] ,;
									aITE[ni,12] })
				Next

				If !VXX040SD3( "1" , "1" , cCodVDV , aSB1SD3 ) // Mov.Interna Peça ( 1=Entrada , 1=Tp.Normal , Codigo VDV , aSB1 )
					DisarmTransaction()
					MostraErro()
					Return
				EndIf
			
			EndIf
		
		EndIf
		//
		DbSelectArea("VV1")
		DbGoTo(nRecVV1)
		RecLock("VV1",.f.)
			VV1->VV1_ULTMOV := "E" // Gravar E = ENTRADA
		MsUnLock()
		//
		DbSelectArea("VDV")
		DbGoTo(nRecVDV)
		RecLock("VDV",.f.)
		If cTipDoc == "1" // Gerar 1=NF
			VDV->VDV_SFILNF := xFilial("SF2")   // Filial da NF Saida
			VDV->VDV_SNUMNF := aNumNFSF2[2]     // Nro da NF Saida
			VDV->VDV_SSERNF := aNumNFSF2[3]     // Serie da NF Saida
			If VDV->(ColumnPos("VDV_SDOCS")) > 0
				VDV->VDV_SDOCS := cF2_SDOC
			EndIf
			If VDV->(ColumnPos("VDV_SNUMNP")) > 0 .and. len(aIteNFSF2) > 0 // Agregar PECAS
				VDV->VDV_SNUMNP := aIteNFSF2[2] // Nro da NF Saida de Pecas
				VDV->VDV_SSERNP := aIteNFSF2[3] // Serie da NF Saida de Pecas
			EndIf
			If VDV->(ColumnPos("VDV_SDOCSP")) > 0
				VDV->VDV_SDOCSP := cF2_SDOCP
			EndIf
			VDV->VDV_EFILNF := xFilial("SF1")   // Filial da NF Entrada
			VDV->VDV_ENUMNF := aNumNFSF1[2]     // Nro da NF Entrada
			VDV->VDV_ESERNF := aNumNFSF1[3]     // Serie da NF Entrada
			If VDV->(ColumnPos("VDV_SDOCE")) > 0
				VDV->VDV_SDOCE := cF1_SDOC
			Endif
			VDV->VDV_ECDFOR := cF1_FORNECE      // Codigo do  Fornecedor
			VDV->VDV_ELJFOR := cF1_LOJA         // Loja do Fornecedor
			If VDV->(ColumnPos("VDV_ENUMNP")) > 0 .and. len(aIteNFSF1) > 0 // Desagregar PECAS
				VDV->VDV_ENUMNP := aIteNFSF1[2] // Nro da NF Saida de Pecas
				VDV->VDV_ESERNP := aIteNFSF1[3] // Serie da NF Saida de Pecas
				VDV->VDV_ECDFOP := cF1_FORNECP
				VDV->VDV_ELJFOP := cF1_LOJAP
			EndIf
			If VDV->(ColumnPos("VDV_SDOCEP")) > 0
				VDV->VDV_SDOCEP := cF1_SDOCP
			EndIf
		EndIf
		If VDV->(ColumnPos("VDV_TIPDOC")) > 0
			VDV->VDV_TIPDOC := cTipDoc    // Tipo Documento ( 1=NF / 2=SD3 (Mov.Interna) )
			VDV->VDV_FILVV0 := xFilial("VV0")
			VDV->VDV_NUMTRA := cVDV_NUMTRA
			VDV->VDV_FILVVF := xFilial("VVF")
			VDV->VDV_TRACPA := cVDV_TRACPA
		EndIf
		MsUnLock()
		//
		FGX_AMOVVEI(xFilial("VV1"),cChassi)
		//
		END TRANSACTION
		// Vetor para tela de Mensagem 
		If Len(aTelaInf) > 0
			FMX_TELAINF( "1" , { { Alltrim(aTelaInf[1]) , Alltrim(aTelaInf[2]) , aTelaInf[3] } } )
		Endif

	EndIf
EndIf

DbSelectArea("VV1")
DbSetOrder(1)

aRotina := StaticCall(VEIXA040,MENUDEF)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CLIFOR   ³ Autor ³ Andre Luis Almeida             ³ Data ³ 23/09/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Posicionamento no Cliente/Fornecedor das NFs a serem geradas           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CLIFOR(nTp)
Local oCliente := DMS_Cliente():New()
Local oFornece := OFFornecedor():New()
Local lRet := .f.
If nTp == 1 // Cliente
	SA1->(DbSetOrder(1))
	If !Empty(cSCdCli) .and. !Empty(cSLjCli)
		If SA1->(DbSeek(xFilial("SA1")+cSCdCli+cSLjCli))
			If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
				Return .f.
			EndIf
			lRet := .t.
		EndIf
	ElseIf !Empty(cSCdCli)
		If SA1->(DbSeek(xFilial("SA1")+cSCdCli))
			If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
				Return .f.
			EndIf
			lRet := .t.
			cSLjCli := SA1->A1_LOJA
			oSLjCli:Refresh()
		EndIf
	Else
		cSLjCli := space(TamSX3("F2_LOJA")[1])
		lRet := .t.
	EndIf
	
	if !VX00101_ClienteValido(SA1->A1_COD, SA1->A1_LOJA, "C", SM0->M0_CGC,.t.)
		MsgStop( STR0088,STR0025) // Informe um cliente com o CNPJ igual ao da filial logada. / Atenção
		Return .f.
	Endif

	If lRet
		SA2->(DbSetOrder(3))
		If SA2->(DbSeek(xFilial("SA2")+SA1->A1_CGC))
			If Empty(cECdFor+cELjFor)
				If !oFornece:Bloqueado( SA2->A2_COD , SA2->A2_LOJA , .f. ) // Fornecedor Bloqueado ?
					cECdFor := SA2->A2_COD
					cELjFor := SA2->A2_LOJA
					oECdFor:Refresh()
					oELjFor:Refresh()
				EndIf
			ElseIf ( cECdFor+cELjFor ) <> ( SA2->A2_COD+SA2->A2_LOJA )
				If MsgYesNo(STR0073,STR0025) // O Cliente selecionado é diferente do Fornecedor já informado. Deseja Continuar? / Atencao
					lRet := .t.
					SA2->(DbSetOrder(1))
					SA2->(DbSeek(xFilial("SA2")+cECdFor+cELjFor))
					oSTpOpe:SetFocus()
				Else
					Return .f.
				EndIf
			EndIf
		Else
			MsgAlert(STR0074,STR0025) // O Cliente não encontrado como Fornecedor. / Atencao
			oSTpOpe:SetFocus()
		EndIf
		SA2->(DbSetOrder(1))
	EndIf
ElseIf nTp == 2 // Fornecedor
	SA2->(DbSetOrder(1))
	If !Empty(cECdFor) .and. !Empty(cELjFor)
		If SA2->(DbSeek(xFilial("SA2")+cECdFor+cELjFor))
			If oFornece:Bloqueado( SA2->A2_COD , SA2->A2_LOJA , .T. ) // Fornecedor Bloqueado ?
				Return .f.
			EndIf
			lRet := .t.
		EndIf
	ElseIf !Empty(cECdFor)
		If SA2->(DbSeek(xFilial("SA2")+cECdFor))
			If oFornece:Bloqueado( SA2->A2_COD , SA2->A2_LOJA , .T. ) // Fornecedor Bloqueado ?
				Return .f.
			EndIf
			lRet := .t.
			cELjFor := SA2->A2_LOJA
			oELjFor:Refresh()
		EndIf
	Else
		cELjFor := space(TamSX3("F1_LOJA")[1])
		lRet := .t.
	EndIf
	If lRet
		SA1->(DbSetOrder(3))
		If SA1->(DbSeek(xFilial("SA1")+SA2->A2_CGC))
			If Empty(cSCdCli+cSLjCli)
				If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
					Return .f.
				EndIf
				cSCdCli := SA1->A1_COD
				cSLjCli := SA1->A1_LOJA
				oSCdCli:Refresh()
				oSLjCli:Refresh()
			ElseIf ( cSCdCli+cSLjCli ) <> ( SA1->A1_COD+SA1->A1_LOJA )
				If MsgYesNo(STR0075,STR0025) // O Fornecedor selecionado é diferente do Cliente já informado. Deseja Continuar? / Atencao
					lRet := .t.
					SA1->(DbSetOrder(1))
					SA1->(DbSeek(xFilial("SA1")+cSCdCli+cSLjCli))
					oETpOpe:SetFocus()
				Else
					Return .f.
				EndIf
			EndIf
		Else
			MsgAlert(STR0076,STR0025) // O Fornecedor não encontrado como Cliente. / Atencao
			oETpOpe:SetFocus()
		EndIf
		SA1->(DbSetOrder(1))
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LEVAMS   ³ Autor ³ Andre Luis Almeida             ³ Data ³ 20/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ LEVANTA AMS                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVAMS(lIni,nOperacao)
Local cGruVei   := left(GetMv("MV_GRUVEI")+space(10),len(SB1->B1_GRUPO))
Local cQuery    := ""
Local cSQLAlias := "SQLAMS"
Local cLinhaAMS := ""
Local cLocPad   := ""
Local nTCodMar  := TamSX3("VV1_CODMAR")[1]
Local nTModVei  := TamSX3("VV1_MODVEI")[1]
Local nTCorVei  := TamSX3("VV1_CORVEI")[1]
//
aAMS := {}
If lIni // Inicial - Carrega Filtro
	aFiltAMS := {""}
EndIf
nCusFut := nCusAtu // Custo Atual do Equipamento
//
If nOperacao == 1 // Agregar
	cQuery := "SELECT VV1.R_E_C_N_O_ RECVV1 , VV1.VV1_CODMAR , VV2.VV2_DESMOD , VV1.VV1_CHASSI , VV1.VV1_CHAINT , "
	cQuery += "VV1.VV1_LOCPAD , VV1.VV1_ESTVEI , VV1.VV1_CODORI , VV1.VV1_GRTRIB , VV1.VV1_POSIPI , VV1.VV1_PROVEI "
	cQuery += "FROM "+RetSQLName("VV1")+" VV1 "
	cQuery += "LEFT JOIN "+RetSQLName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_SITVEI='0' AND VV1.VV1_GRASEV='6' AND VV1.VV1_FILENT='"+xFilial("VVF")+"' AND VV1.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->(Eof())
		//
		cLocPad := (cSQLAlias)->( VV1_LOCPAD )
		If Empty(cLocPad)
			cLocPad := GETMV("MV_LOCVEIN") //Novo
			If (cSQLAlias)->( VV1_ESTVEI ) == '1'
				cLocPad := GETMV("MV_LOCVEIU") //Usado
			EndIf
		EndIf
		FGX_VV1SB1("CHAINT", (cSQLAlias)->( VV1_CHAINT ) , /* cMVMIL0010 */ , cGruVei )
		If Empty(cLocPad)
			cLocPad := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
		EndIf
		SB2->(dbSetOrder(1))
		SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+cLocPad))
		//
		cLinhaAMS := Alltrim((cSQLAlias)->( VV1_CODMAR ))+" - "+Alltrim((cSQLAlias)->( VV2_DESMOD ))
		If lIni // Inicial - Carrega Filtro
			If aScan(aFiltAMS,cLinhaAMS) == 0
				aAdd(aFiltAMS,cLinhaAMS)
			EndIf
		EndIf
		If Empty(cFiltAMS) .or. ( cFiltAMS == cLinhaAMS )
			aadd(aAMS,{ .f. ,;																			// 01
						(cSQLAlias)->( VV1_CHASSI ) ,;													// 02
						cLinhaAMS ,;																	// 03
						round(SB2->B2_CM1,2) ,;															// 04
						(cSQLAlias)->( RECVV1 ) ,;														// 05
						cLocPad ,;																		// 06
						SB1->B1_COD ,;																	// 07
						space(nTCodMar) ,;																// 08
						space(nTModVei) ,;																// 09
						0 ,;																			// 10
						IIf(!Empty((cSQLAlias)->( VV1_ESTVEI )),(cSQLAlias)->( VV1_ESTVEI ),"0") ,;		// 11
						"" ,;																			// 12
						(cSQLAlias)->( VV1_CODORI ) ,;													// 13
						(cSQLAlias)->( VV1_GRTRIB ) ,;													// 14
						(cSQLAlias)->( VV1_POSIPI ) ,;													// 15
						(cSQLAlias)->( VV1_PROVEI ) ,;													// 16
						space(nTCorVei) ,;																// 17
						SB1->B1_CC ,;																	// 18
						SB1->B1_CONTA ,;																// 19
						SB1->B1_ITEMCC ,; 																// 20
						SB1->B1_CLVL })																	// 21
		EndIf
		//
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
	SB1->(dbSetOrder(1))
EndIf
If len(aAMS) <= 0
	FS_ADD_AMS( .f. , space(nTCodMar) , space(nTModVei) , space(nTCorVei) ) // Cria registro em branco no aAMS
EndIf
If !lIni // Atualizar ListBox
	oLboxAMS:nAt := 1
	oLboxAMS:SetArray(aAMS)
	oLboxAMS:bLine := { || { IIf(aAMS[oLboxAMS:nAt,1],oOkTik,oNoTik) , aAMS[oLboxAMS:nAt,2] , aAMS[oLboxAMS:nAt,3] , FG_AlinVlrs(Transform(aAMS[oLboxAMS:nAt,04],"@E 9,999,999.99")) , aAMS[oLboxAMS:nAt,18] , aAMS[oLboxAMS:nAt,19] , aAMS[oLboxAMS:nAt,20] , aAMS[oLboxAMS:nAt,21] }}
	oLboxAMS:Refresh()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_IAEAMS   ³ Autor ³ Andre Luis Almeida             ³ Data ³ 20/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Vetor de AMS - TIK no ListBox e Botoes I-nclusao/A-lteracao/E-xclusao  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IAEAMS(nOperacao,nLinha,cTp,nColuna)
Local ni        := 0
Local aRetAMS   := {}
Local aParamBox := {}
Local clMod     := ".t."
Local clQtd     := ".t."
Local cMar      := space(TamSX3("VV1_CODMAR")[1])
Local cMod      := space(TamSX3("VV1_MODVEI")[1])
Local cCor      := space(TamSX3("VV1_CORVEI")[1])
Local nQtd      := 1
Local nCus      := 0
Local nVda      := 0
Local cCHASSI   := space(TamSX3("VV1_CHASSI")[1])
Local cCODORI   := "2"
Local aCODORI   := X3CBOXAVET("VV1_CODORI","0")
Local cGRTRIB   := space(TamSX3("B1_GRTRIB")[1])
Local cPOSIPI   := space(TamSX3("B1_POSIPI")[1])
Local cProvei   := space(TamSX3("VV1_PROVEI")[1])
Local nTCodMar  := TamSX3("VV1_CODMAR")[1]
Local nTModVei  := TamSX3("VV1_MODVEI")[1]
Local nTCorVei  := TamSX3("VV1_CORVEI")[1]
Local cLocPad   := space(TamSX3("VV1_LOCPAD")[1])
Local cCC       := space(TamSX3("B1_CC")[1])
Local cConta    := space(TamSX3("B1_CONTA")[1])
Local cItemCC   := space(TamSX3("B1_ITEMCC")[1])
Local cClVl     := space(TamSX3("B1_CLVL")[1])
Local nPriLinha := 0
If nOperacao == 1 // Agregar ( Tik no ListBox )
	If aAMS[nLinha,05] > 0
		If nColuna < 5
			aAMS[nLinha,01] := !aAMS[nLinha,01]
		Else // Alterar Centro de Custo, Conta Contabil, Item Conta Contabil, Classe Valor
			AADD(aParamBox,{1,STR0011,aAMS[oLboxAMS:nAt,2],"@!",'',"",".F.",50,.f.})
			AADD(aParamBox,{1,cSiglaAMS,aAMS[oLboxAMS:nAt,3],"@!",'',"",".F.",90,.f.})
			AADD(aParamBox,{1,STR0013,aAMS[oLboxAMS:nAt,04],"@E 999,999,999.99",'',"",".F.",60,.f.})
			AADD(aParamBox,{1,STR0084,aAMS[nLinha,18],"@!",'Vazio() .or. Ctb105CC()',"CTT",".T.",50,.f.}) // Centro de Custo
			AADD(aParamBox,{1,STR0085,aAMS[nLinha,19],"@!",'Vazio() .or. Ctb105Cta()',"CT1",".T.",90,.f.}) // Conta Contabil
			AADD(aParamBox,{1,STR0086,aAMS[nLinha,20],"@!",'Vazio() .or. Ctb105Item()',"CTD",".T.",50,.f.}) // Item Conta Contabil
			AADD(aParamBox,{1,STR0087,aAMS[nLinha,21],"@!",'Vazio() .or. Ctb105ClVl()',"CTH",".T.",50,.f.}) // Classe Valor
			For ni := 1 to len(aParambox)
				aAdd(aRetAMS,aParambox[ni,3]) // Carregando conteudo Default
			Next
			If ParamBox(aParamBox,cSiglaAMS,@aRetAMS,,,,,,,,.f.) // XXX
				aAMS[nLinha,18] := aRetAMS[4]
				aAMS[nLinha,19] := aRetAMS[5]
				aAMS[nLinha,20] := aRetAMS[6]
				aAMS[nLinha,21] := aRetAMS[7]
				If !aAMS[nLinha,01]
					aAMS[nLinha,01] := .t. // selecionar
				EndIf
			EndIf
		EndIf
	EndIf
Else // Desagrega
	If cTp == "E" // Excluir
		If !aAMS[nLinha,01]
			Return
		EndIf
	EndIf
	If cTp <> "I"
		cMar := aAMS[nLinha,08]
		cMod := aAMS[nLinha,09]
		cCor := aAMS[nLinha,17]
		nCus := aAMS[nLinha,04]
		nVda := aAMS[nLinha,10]
		cCHASSI := aAMS[nLinha,02]
		cCODORI := aAMS[nLinha,13]
		cGRTRIB := aAMS[nLinha,14]
		cPOSIPI := aAMS[nLinha,15]
		cProvei := aAMS[nLinha,16]
		cMarMod := ( cMar + cMod )
		cLocPad := aAMS[nLinha,06]
		cCC     := aAMS[nLinha,18]
		cConta  := aAMS[nLinha,19]
		cItemCC := aAMS[nLinha,20]
		cClVl   := aAMS[nLinha,21]
		If cTp == "E" // Excluir
			clMod := ".f."
			aCODORI := {cCODORI+"="+X3CBOXDESC("VV1_CODORI",cCODORI)}
		EndIf
		If !aAMS[nLinha,01]
			cTp := "I"
		Else
			clQtd := ".f."
		EndIf
	Else
		cLocPad := padr(GetNewPar("MV_MIL0107",""),TamSX3("VV1_LOCPAD")[1]) // Local Padrao para criacao do VV1 quando Desagregar AMS
	EndIf
	AADD(aParamBox,{1,STR0028,cMar,"@!",'VX040MARMD("'+cTp+'",1)',"VE1",clMod,30,.t.})
	AADD(aParamBox,{1,STR0029,cMod,"@!",'VX040MARMD("'+cTp+'",2)',"MCV",clMod,100,.t.})
	AADD(aParamBox,{1,RetTitle("VV1_CORVEI"),cCor,"@!",'VX040MARMD("'+cTp+'",3)',"VVC",clMod,50,.t.})
	AADD(aParamBox,{1,STR0032,nQtd,"@E 9999","MV_PAR04>0","",clQtd,50,.t.})
	AADD(aParamBox,{1,STR0030,nCus,"@E 9,999,999.99","MV_PAR05>=0","",clMod,80,.t.})
	AADD(aParamBox,{1,STR0031,nVda,"@E 9,999,999.99","MV_PAR06>=0","",clMod,80,.f.})
	AADD(aParamBox,{1,RetTitle("VV1_CHASSI"),cCHASSI,"@!",'vazio() .or. VX040CHASSI('+Alltrim(str(nLinha))+',"'+cTp+'")',"",clMod+".and.MV_PAR04==1",100,.f.})
	AADD(aParamBox,{1,RetTitle("VV1_LOCPAD"),cLocPad,"@!",'',"NNR",clMod,30,.t.})
	AADD(aParamBox,{2,RetTitle("VV1_CODORI"),cCODORI,aCODORI,70,"",.f.,clMod})
	AADD(aParamBox,{1,RetTitle("VV1_GRTRIB"),cGRTRIB,"@!",'vazio() .or. FG_Seek("SX5","'+"'21'"+'+MV_PAR10",1,.f.)',"21",clMod,80,.f.})
	AADD(aParamBox,{1,RetTitle("VV1_POSIPI"),cPOSIPI,"@!",'vazio() .or. FG_Seek("SYD","MV_PAR11",1,.f.)',"SYD",clMod,80,.f.})
	AADD(aParamBox,{1,RetTitle("VV1_PROVEI"),cProvei,"@!",'vazio() .or. FG_Seek("SX5","'+"'S0'"+'+MV_PAR12",1,.f.)',"S0",clMod,30,.f.})
	AADD(aParamBox,{1,STR0084,cCC    ,"@!",'Vazio() .or. Ctb105CC()',"CTT",clMod,50,.f.}) // Centro de Custo
	AADD(aParamBox,{1,STR0085,cConta ,"@!",'Vazio() .or. Ctb105Cta()',"CT1",clMod,90,.f.}) // Conta Contabil
	AADD(aParamBox,{1,STR0086,cItemCC,"@!",'Vazio() .or. Ctb105Item()',"CTD",clMod,50,.f.}) // Item Conta Contabil
	AADD(aParamBox,{1,STR0087,cClVl  ,"@!",'Vazio() .or. Ctb105ClVl()',"CTH",clMod,50,.f.}) // Classe Valor
	For ni := 1 to len(aParambox)
		aAdd(aRetAMS,aParambox[ni,3]) // Carregando conteudo Default
	Next
	If ParamBox(aParamBox,cSiglaAMS,@aRetAMS,,,,,,,,.f.) // XXX
		If cTp == "E" // Excluir
			aDel(aAMS,nLinha)
			aSize(aAMS,Len(aAMS)-1)
		Else
			nPriLinha := 0
			For ni := 1 to aRetAMS[4]
				If cTp == "I" // Incluir
					If len(aAMS) == 1 .and. !aAMS[01,01]
						nLinha := 1
					Else
						FS_ADD_AMS( .t. , space(nTCodMar) , space(nTModVei) , space(nTCorVei) ) // Cria registro em branco no aAMS
						nLinha := len(aAMS)
					EndIf
				EndIf
				If nPriLinha == 0
					nPriLinha := nLinha // Posicionar na primeira linha incluida
				EndIf
				VV2->(DbSetOrder(1))
				VV2->(DbSeek(xFilial("VV2")+aRetAMS[1]+aRetAMS[2]))
				aAMS[nLinha,01] := .t.
				aAMS[nLinha,02] := IIf(aRetAMS[4]==1,aRetAMS[7],space(TamSX3("VV1_CHASSI")[1]))
				aAMS[nLinha,03] := Alltrim(aRetAMS[1])+" - "+Alltrim(VV2->VV2_DESMOD)
				aAMS[nLinha,04] := aRetAMS[5]
				aAMS[nLinha,05] := 0
				aAMS[nLinha,06] := aRetAMS[8]
				aAMS[nLinha,07] := ""
				aAMS[nLinha,08] := aRetAMS[1]
				aAMS[nLinha,09] := aRetAMS[2]
				aAMS[nLinha,10] := aRetAMS[6]
				aAMS[nLinha,13] := aRetAMS[9]
				aAMS[nLinha,14] := aRetAMS[10]
				aAMS[nLinha,15] := aRetAMS[11]
				aAMS[nLinha,16] := aRetAMS[12]
				aAMS[nLinha,17] := aRetAMS[3]
				aAMS[nLinha,18] := aRetAMS[13]
				aAMS[nLinha,19] := aRetAMS[14]
				aAMS[nLinha,20] := aRetAMS[15]
				aAMS[nLinha,21] := aRetAMS[16]
			Next
		EndIf
	EndIf
EndIf
If len(aAMS) <= 0
	FS_ADD_AMS( .f. , space(nTCodMar) , space(nTModVei) , space(nTCorVei) ) // Cria registro em branco no aAMS
EndIf
nCusFut := nCusAtu // Custo Futuro do Equipamento (apos Agregar/Desagregar AMS)
For ni := 1 to len(aAMS)
	If aAMS[ni,01]
		If nOperacao == 1 // Agregar
			nCusFut += aAMS[ni,04]
		ElseIf nOperacao == 2 // Desagregar
			nCusFut -= aAMS[ni,04]
		EndIf
	EndIf
Next
oCusFut:Refresh()
If nOperacao == 2 // Desagrega
	oLboxAMS:nAt := nLinha
	If cTp == "I"
		If nPriLinha == 0
			nPriLinha := 1 // Posicionar na primeira linha incluida
		EndIf
		oLboxAMS:nAt := nPriLinha // Posicionar na primeira linha incluida
	ElseIf cTp == "E"
		oLboxAMS:nAt -= IIf(nLinha>1,1,0)
	EndIf
	oLboxAMS:SetArray(aAMS)
	oLboxAMS:bLine := { || { IIf(aAMS[oLboxAMS:nAt,1],oOkTik,oNoTik) , aAMS[oLboxAMS:nAt,2] , aAMS[oLboxAMS:nAt,3] , FG_AlinVlrs(Transform(aAMS[oLboxAMS:nAt,04],"@E 9,999,999.99")) , aAMS[oLboxAMS:nAt,18] , aAMS[oLboxAMS:nAt,19] , aAMS[oLboxAMS:nAt,20] , aAMS[oLboxAMS:nAt,21] }}
	oLboxAMS:Refresh()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_IAEITE   ³ Autor ³ Andre Luis Almeida             ³ Data ³ 06/09/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Vetor de ITEM - TIK no ListBox e Botoes I-nclusao/A-lteracao/E-xclusao ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IAEITE(nOperacao,nLinha,cTp)
Local ni        := 0
Local aRetIte   := {}
Local aParamBox := {}
Local clMod     := ".t."
Local nQtd      := 1
Local nCus      := 0
Local lVXX040IT := ExistBlock("VXX040IT") // Ponto de Entrada da Tela de Item - Tudo Ok da Tela
Local aVRelacao := { space(TamSX3("B1_GRUPO")[1]) , space(TamSX3("B1_CODITE")[1]) , 1 , 0 }
Private cGruIte := aVRelacao[1]
Private cCodIte := aVRelacao[2]
If cTp == "E" // Excluir
	clMod := ".f."
	If !aITE[nLinha,01]
		Return
	EndIf
EndIf
If cTp <> "I"
	cGruIte := aITE[nLinha,02]
	cCodIte := aITE[nLinha,03]
	nQtd    := aITE[nLinha,05]
	nCus    := Round(aITE[nLinha,06]/nQtd,2)
	If !aITE[nLinha,01]
		cTp := "I"
	EndIf
Else // Inclusao - Possibilita inserir conteudo ( inicializador / relacao nos campos ) na tela de Item ( SB1 )
	If ExistBlock("VXX040RL") // Relacao dos Campos da tela de Item ( SB1 )
		aVRelacao := ExecBlock("VXX040RL",.f.,.f.,{ nOperacao , aClone(aVRelacao) })
		cGruIte := aVRelacao[1]
		cCodIte := aVRelacao[2]
		nQtd    := aVRelacao[3]
		nCus    := aVRelacao[4]
	EndIf
EndIf
AADD(aParamBox,{1,STR0065,cGruIte,"@!",'vazio().or.(FG_Seek("SBM","MV_PAR01",1,.f.).and.(cGruIte:=MV_PAR01))',"BM5",clMod,30,.t.})
AADD(aParamBox,{1,STR0066,cCodIte,"@!",'vazio().or.(FG_POSSB1("MV_PAR02","SB1->B1_CODITE","MV_PAR01").and.(cCodIte:=MV_PAR02))',"SB1V40",clMod,100,.t.})
AADD(aParamBox,{1,STR0032,nQtd,"@E 9999","MV_PAR03>0","",clMod,50,.t.})
If nOperacao == 2 // Desagregar
	AADD(aParamBox,{1,STR0077,nCus,"@E 9,999,999.99","MV_PAR04>=0","",clMod,80,.t.}) // Valor
EndIf
For ni := 1 to len(aParambox)
	aAdd(aRetIte,aParambox[ni,3]) // Carregando conteudo Default
Next
If ParamBox(aParamBox,STR0062,@aRetIte,,,,,,,,.f.) .and. ( !lVXX040IT .or. ExecBlock("VXX040IT",.f.,.f.,{ cTp , nOperacao , aClone(aRetIte) }) ) // Peca
	If cTp == "E" // Excluir
		aDel(aITE,nLinha)
		aSize(aITE,Len(aITE)-1)
	Else
		SB1->(DbSetOrder(7))
		SB1->(DbSeek(xFilial("SB1")+aRetIte[1]+aRetIte[2]))
		SB1->(DbSetOrder(1))
		If nOperacao == 1 // Agregar
			SB2->(DbSetOrder(1))
			SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")))
			If SALDOSB2() < aRetIte[3]
				MsgStop(STR0078+CHR(10)+CHR(13)+CHR(10)+CHR(13)+Alltrim(SB1->B1_GRUPO)+" "+Alltrim(SB1->B1_CODITE)+" - "+SB1->B1_DESC,STR0025) // Saldo insuficiente! / Atencao
				Return
			EndIf
			nCus := round(SB2->B2_CM1,2)
		ElseIf nOperacao == 2 // Desagregar
			nCus := aRetIte[4]
		EndIf
		If cTp == "I" // Incluir
			If len(aITE) == 1 .and. !aITE[01,01]
				nLinha := 1
			Else
				FS_ADD_ITE() // Cria registro em branco no aITE
				nLinha := len(aITE)
			EndIf
		EndIf
		aITE[nLinha,01] := .t.
		aITE[nLinha,02] := aRetIte[1]
		aITE[nLinha,03] := aRetIte[2]
		aITE[nLinha,04] := SB1->B1_DESC
		aITE[nLinha,05] := aRetIte[3]
		aITE[nLinha,06] := round(aRetIte[3]*nCus,2)
		aITE[nLinha,07] := SB1->(RecNo())
		aITE[nLinha,09] := SB1->B1_CC
		aITE[nLinha,10] := SB1->B1_CONTA
		aITE[nLinha,11] := SB1->B1_ITEMCC
		aITE[nLinha,12] := SB1->B1_CLVL
	EndIf
EndIf
If len(aITE) <= 0
	FS_ADD_ITE() // Cria registro em branco no aITE
EndIf
nCusFut := nCusAtu // Custo Futuro do Equipamento (apos Agregar/Desagregar Peca)
For ni := 1 to len(aITE)
	If aITE[ni,01]
		If nOperacao == 1 // Agregar
			nCusFut += aITE[ni,06]
		ElseIf nOperacao == 2 // Desagregar
			nCusFut -= aITE[ni,06]
		EndIf
	EndIf
Next
oCusFut:Refresh()
If nOperacao == 2 // Desagrega
	oLboxITE:nAt := nLinha
	If cTp == "E"
		oLboxITE:nAt -= IIf(nLinha>1,1,0)
	EndIf
	oLboxITE:SetArray(aITE)
	oLboxITE:bLine := { || { IIf(aITE[oLboxITE:nAt,1],oOkTik,oNoTik) , aITE[oLboxITE:nAt,2] , aITE[oLboxITE:nAt,3] , aITE[oLboxITE:nAt,4] , FG_AlinVlrs(Transform(aITE[oLboxITE:nAt,5],"@E 9,999")) , FG_AlinVlrs(Transform(aITE[oLboxITE:nAt,6],"@E 9,999,999.99")) }}
	oLboxITE:Refresh()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALIDVEI ³ Autor ³ Andre Luis Almeida             ³ Data ³ 20/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do Veiculo                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALIDVEI(cChaInt)
Local lRet      := .t.
Local oVeiculos := DMS_Veiculo():New()
Local nCntFor   := 0

DbSelectArea("VV1")
DbSetOrder(1)
If MsSeek( xFilial("VV1") + cChaInt )
	// Chassi Bloqueado
	If oVeiculos:Bloqueado(VV1->VV1_CHAINT)
		lRet := .f. // A mensagem já é exibida dentro da função Bloqueado()
	EndIf

	If lRet
		If VV1->VV1_SITVEI <> '0' .or. VV1->VV1_GRASEV == '6'
			MsgStop(STR0033+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0004+": "+VV1->VV1_CHASSI,STR0025) // Equipamento nao esta no Estoque! / Chassi / Atencao
			lRet := .f.
		EndIf
	EndIf
	
	If lRet
		If oVeiculos:DtUltimaMovimentacao(VV1->VV1_CHASSI) > dDataBase // Valida referente a DataBase
			MsgStop(STR0102+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0004+": "+VV1->VV1_CHASSI ) // Chassi com movimentacao posterior a data atual. / Chassi:
			lRet := .f.
		EndIf
	EndIf

Else
	MsgStop(STR0034,STR0025) // Equipamento nao encontrado! / Atencao
	lRet := .f.
EndIf

If lRet .and. len(aAMS) > 0 // Se Agrega/Desagrega com AMS, verificar DATAS dos VV1 correspondentes
	For nCntFor := 1 to len(aAMS)
		If aAMS[nCntFor,1]
			If oVeiculos:DtUltimaMovimentacao(aAMS[nCntFor,2]) > dDataBase // Valida referente a DataBase
				MsgStop(STR0102+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0004+": "+aAMS[nCntFor,2] ) // Chassi com movimentacao posterior a data atual. / Chassi:
				lRet := .f.
				Exit
			EndIf
		EndIf
	Next
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALIDOK  ³ Autor ³ Andre Luis Almeida             ³ Data ³ 20/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do OK na Tela                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALIDOK(nOperacao)
Local oCliente   := DMS_Cliente():New()
Local oFornece   := OFFornecedor():New()
Local lRet       := .t.
Local ni         := 0
Local cAux       := ""
Local nRecVV1    := VV1->(RecNo())
Local cTitTela   := ""
Local aObjects   := {} , aPos := {} , aInfo := {}
Local aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
/////////////
// CUSTO   //
/////////////
If nCusFut <= 0
	MsgStop(STR0057,STR0025) // Impossivel continuar. Custo futuro menor ou igual a zero! / Atencao
	lRet := .f.
EndIf
If cTipDoc == "1" // Gerar 1=NF
	/////////////
	// SAIDA   //
	/////////////
	If lRet
		SA1->(DbSetOrder(1))
		If Empty(cSCdCli+cSLjCli) .or. !SA1->(DbSeek(xFilial("SA1")+cSCdCli+cSLjCli))
			MsgStop(STR0035,STR0025) // Impossivel continuar. Cliente nao encontrado! / Atencao
			lRet := .f.
		Else
			If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
				Return .f.
			EndIf
			if !VX00101_ClienteValido(SA1->A1_COD, SA1->A1_LOJA, "C", SM0->M0_CGC,.t.)
				MsgStop( STR0088,STR0025) // Informe um cliente com o CNPJ igual ao da filial logada. / Atenção
				lRet := .f.
			Endif
		EndIf
	Endif
	If lRet
		SF4->(DbSetOrder(1))
		If !Empty(cSCdTES) .and. !SF4->(DbSeek(xFilial("SF4")+cSCdTES))
			MsgStop(STR0036,STR0025) // Impossivel continuar. TES de saida nao encontrado! / Atencao
			lRet := .f.
		EndIf
	EndIf
	If lRet
		SA3->(DbSetOrder(1))
		If Empty(cSCdVen) .or. !SA3->(DbSeek(xFilial("SA3")+cSCdVen))
			MsgStop(STR0037,STR0025) // Impossivel continuar. Vendedor nao encontrado! / Atencao
			lRet := .f.
		EndIf
	EndIf
	/////////////
	// ENTRADA //
	/////////////
	If lRet
		SA2->(DbSetOrder(1))
		If Empty(cECdFor+cELjFor) .or. !SA2->(DbSeek(xFilial("SA2")+cECdFor+cELjFor))
			MsgStop(STR0038,STR0025) // Impossivel continuar. Fornecedor nao encontrado! / Atencao
			lRet := .f.
		EndIf
		If oFornece:Bloqueado( SA2->A2_COD , SA2->A2_LOJA , .T. ) // Fornecedor Bloqueado ?
			Return .f.
		EndIf
	EndIf
	If lRet
		SF4->(DbSetOrder(1))
		If !Empty(cECdTES) .and. !SF4->(DbSeek(xFilial("SF4")+cECdTES))
			MsgStop(STR0039,STR0025) // Impossivel continuar. TES de entrada nao encontrado! / Atencao
			lRet := .f.
		EndIf
	EndIf
EndIf
If lRet
	If nTipOper == 1 // AMS
		/////////////
		// AMS     //
		/////////////
		lRet := .f.
		For ni := 1 to len(aAMS)
			If aAMS[ni,01] .and. aAMS[ni,04] > 0
				lRet := .t.
				Exit
			EndIf
		Next
		If !lRet
			MsgStop(STR0040,STR0025) // Impossivel continuar. Necessario selecionar um ou mais itens com valor de custo! / Atencao
		Else
			If nOperacao == 1 // Agregar
				For ni := 1 to len(aAMS)
					If aAMS[ni,01]
						VV1->(dbGoTo(aAMS[ni,05]))
						If VV1->VV1_SITVEI <> '0'
							MsgStop(STR0041+CHR(13)+CHR(10)+CHR(13)+CHR(10)+aAMS[ni,02]+CHR(13)+CHR(10)+aAMS[ni,03],STR0025) // Impossivel continuar. Item nao esta no estoque! / Atencao
							lRet := .f.
							Exit
						EndIf
					EndIf
				Next
				VV1->(dbGoTo(nRecVV1))
			EndIf
		EndIf
	ElseIf nTipOper == 2 // PECA SB1
		If len(aITE) == 1 .and. aITE[1,07] == 0 // Linha em branco
			MsgStop(STR0040,STR0025) // Impossivel continuar. Necessario selecionar um ou mais itens com valor de custo! / Atencao
			lRet := .f.
		EndIf
		If lRet
			cTitTela := ""
			If cTipDoc == "1" // Gerar 1=NF
				If nOperacao == 1 // Agregar
					SA1->(DbSetOrder(1))
					If Empty(cSCdCli+cSLjCli) .or. !SA1->(DbSeek(xFilial("SA1")+cSCdCli+cSLjCli))
						MsgStop(STR0035,STR0025) // Impossivel continuar. Cliente nao encontrado! / Atencao
						lRet := .f.
					EndIf
					If lRet
						cTitTela := STR0079 // Dados adicionais para emissão da NF de Saida da(s) Peça(s)
						cPSCdVen := cSCdVen
						cPSConPg := cSConPg
						cPSNatur := cSNatur
						cPSCdBan := cSCdBan
						cPSMenPd := cSMenPd
						cPSMenNt := cSMenNt
						For ni := 1 to len(aITE) // TES INTELIGENTE
							SB1->(DbGoTo(aITE[ni,7]))
							cAux := MaTesInt(2,cPSTpOpe,SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD,,SA1->A1_TIPO)
							If Empty(cAux)
								cAux := cPSCdTES
							EndIf
							aITE[ni,8] := cAux
							SB2->(DbSetOrder(1))
							SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")))
							If SALDOSB2() < aIte[ni,5]
								MsgStop(STR0078+CHR(10)+CHR(13)+CHR(10)+CHR(13)+Alltrim(SB1->B1_GRUPO)+" "+Alltrim(SB1->B1_CODITE)+" - "+SB1->B1_DESC,STR0025) // Saldo insuficiente! / Atencao
								lRet := .f.
								Exit
							EndIf
						Next
					EndIf
				ElseIf nOperacao == 2 // Desagregar
					SA2->(DbSetOrder(1))
					If Empty(cECdFor+cELjFor) .or. !SA2->(DbSeek(xFilial("SA2")+cECdFor+cELjFor))
						MsgStop(STR0038,STR0025) // Impossivel continuar. Fornecedor nao encontrado! / Atencao
						lRet := .f.
					EndIf
					If lRet
						cTitTela := STR0080 // Dados adicionais para emissão da NF de Entrada da(s) Peça(s)
						cPEEspec := cEEspec
						cPEConPg := cEConPg
						cPENatur := cENatur
						cPEMenPd := cEMenPd
						cPEMenNt := cEMenNt
						For ni := 1 to len(aITE) // TES INTELIGENTE
							SB1->(DbGoTo(aITE[ni,7]))
							cAux := MaTesInt(1,cPETpOpe,SA2->A2_COD,SA2->A2_LOJA,"F",SB1->B1_COD,,SA2->A2_TIPO)
							If Empty(cAux)
								cAux := cPECdTES
							EndIf
							aITE[ni,8] := cAux
						Next
					EndIf
				EndIf
			Else // Mov.Interna
				cTitTela := STR0100 // Dados adicionais para Mov.Interna da(s) Peça(s)
			EndIf
			
			If lRet
				lRet := .f.
				// Configura os tamanhos dos objetos
				aObjects := {}
				If cTipDoc == "1" // Gerar 1=NF
					AAdd( aObjects, { 0, 67, .T. , .F. } ) // Campos NFs de SAIDA/ENTRADA de PECAS
				Else // Mov.Interna
					AAdd( aObjects, { 0,  0, .T. , .F. } ) // Mov.Interna nao tem Campos relacionados a NF
				EndIf
				AAdd( aObjects, { 0,  0, .T. , .T. } ) // ListBox PECAS
				//
				aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
				aPos := MsObjSize( aInfo, aObjects )
				DEFINE MSDIALOG oTelaTES TITLE cTitTela FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL
					If cTipDoc == "1" // Gerar 1=NF
						If nOperacao == 1 // Agregar
							@ aPos[1,1] + 006 , aPos[1,2] + 005 SAY (STR0019+":") OF oTelaTES PIXEL COLOR CLR_HBLUE
							@ aPos[1,1] + 005 , aPos[1,2] + 050 MSGET oPSCdVen VAR cPSCdVen F3 "SA3" VALID ( vazio() .or. FG_Seek("SA3","cPSCdVen",1) ) PICTURE "@!" SIZE 40,08 OF oTelaTES PIXEL HASBUTTON COLOR CLR_BLACK
							@ aPos[1,1] + 018 , aPos[1,2] + 005 SAY (STR0020+":") OF oTelaTES PIXEL
							@ aPos[1,1] + 017 , aPos[1,2] + 050 MSGET oPSConPg VAR cPSConPg F3 "SE4" VALID ( vazio() .or. ( FG_Seek("SE4","cPSConPg",1) .and. !(SE4->E4_TIPO $ "A.9") ) ) PICTURE "@!" SIZE 30,08 OF oTelaTES PIXEL HASBUTTON COLOR CLR_BLACK
							@ aPos[1,1] + 030 , aPos[1,2] + 005 SAY (STR0021+":") OF oTelaTES PIXEL
							@ aPos[1,1] + 029 , aPos[1,2] + 050 MSGET oPSNatur VAR cPSNatur F3 "SED" VALID ( vazio() .or. FG_Seek("SED","cPSNatur",1) ) PICTURE "@!" SIZE 50,08 OF oTelaTES PIXEL HASBUTTON COLOR CLR_BLACK
							@ aPos[1,1] + 042 , aPos[1,2] + 005 SAY (STR0022+":") OF oTelaTES PIXEL
							@ aPos[1,1] + 041 , aPos[1,2] + 050 MSGET oPSCdBan VAR cPSCdBan F3 "SA6" VALID ( vazio() .or. FG_Seek("SA6","cPSCdBan",1) ) PICTURE "@!" SIZE 30,08 OF oTelaTES PIXEL HASBUTTON COLOR CLR_BLACK
							@ aPos[1,1] + 042 , aPos[1,2] + 105 SAY (RetTitle("C5_MENPAD")+":") OF oTelaTES PIXEL COLOR CLR_BLACK // Mensagem NF
							@ aPos[1,1] + 041 , aPos[1,2] + 150 MSGET oPSMenPd VAR cPSMenPd F3 "SM4" VALID (texto().Or.Vazio()) PICTURE "@!" SIZE 50,08 OF oTelaTES PIXEL HASBUTTON COLOR CLR_BLACK
							@ aPos[1,1] + 054 , aPos[1,2] + 005 SAY (RetTitle("C5_MENNOTA")+":") OF oTelaTES PIXEL COLOR CLR_BLACK // Mensagem NF
							@ aPos[1,1] + 053 , aPos[1,2] + 050 MSGET oPSMenNt VAR cPSMenNt PICTURE "@!" SIZE 200,08 OF oTelaTES PIXEL HASBUTTON COLOR CLR_BLACK
						ElseIf nOperacao == 2 // Desagregar
							@ aPos[1,1] + 006 , aPos[1,2] + 005 SAY (STR0024+":") OF oTelaTES PIXEL
							@ aPos[1,1] + 005 , aPos[1,2] + 050 MSGET oPEEspec VAR cPEEspec F3 "42" VALID ( vazio() .or. FG_Seek("SX5","'42'+cPEEspec",1) ) PICTURE "@!" SIZE 40,08 OF oTelaTES PIXEL HASBUTTON COLOR CLR_BLACK
							@ aPos[1,1] + 018 , aPos[1,2] + 005 SAY (STR0020+":") OF oTelaTES PIXEL
							@ aPos[1,1] + 017 , aPos[1,2] + 050 MSGET oPEConPg VAR cPEConPg F3 "SE4" VALID ( vazio() .or. ( FG_Seek("SE4","cPEConPg",1) .and. !(SE4->E4_TIPO $ "A.9") ) ) PICTURE "@!" SIZE 30,08 OF oTelaTES PIXEL HASBUTTON COLOR CLR_BLACK
							@ aPos[1,1] + 030 , aPos[1,2] + 005 SAY (STR0021+":") OF oTelaTES PIXEL
							@ aPos[1,1] + 029 , aPos[1,2] + 050 MSGET oPENatur VAR cPENatur F3 "SED" VALID ( vazio() .or. FG_Seek("SED","cPENatur",1) ) PICTURE "@!" SIZE 50,08 OF oTelaTES PIXEL HASBUTTON COLOR CLR_BLACK
							@ aPos[1,1] + 042 , aPos[1,2] + 005 SAY (RetTitle("VVF_MENPAD")+":") OF oTelaTES PIXEL COLOR CLR_BLACK // Mensagem NF
							@ aPos[1,1] + 041 , aPos[1,2] + 050 MSGET oPEMenPd VAR cPEMenPd F3 "SM4" VALID (texto().Or.Vazio()) PICTURE "@!" SIZE 50,08 OF oTelaTES PIXEL HASBUTTON COLOR CLR_BLACK
							@ aPos[1,1] + 054 , aPos[1,2] + 005 SAY (RetTitle("VVF_MENNOT")+":") OF oTelaTES PIXEL COLOR CLR_BLACK // Mensagem NF
							@ aPos[1,1] + 053 , aPos[1,2] + 050 MSGET oPEMenNt VAR cPEMenNt PICTURE "@!" SIZE 200,08 OF oTelaTES PIXEL HASBUTTON COLOR CLR_BLACK
						EndIf
						@ aPos[2,1]+000,aPos[2,2]+002 LISTBOX oLboxPITE FIELDS ;
											HEADER STR0065,STR0066,STR0067,STR0081,STR0068,STR0069,STR0084,STR0085,STR0086,STR0087 ;
											COLSIZES 40,80,140,40,40,63,63,63,63,63 SIZE aPos[2,4]-4,aPos[2,3]-aPos[2,1]-4 OF oTelaTES PIXEL ;
											ON DBLCLICK FS_TES_CC(oLboxPITE:nAt,nOperacao,.t.)
						oLboxPITE:SetArray(aITE)
						oLboxPITE:bLine := { || { aITE[oLboxPITE:nAt,2] , aITE[oLboxPITE:nAt,3] , aITE[oLboxPITE:nAt,4] , aITE[oLboxPITE:nAt,8] , FG_AlinVlrs(Transform(aITE[oLboxPITE:nAt,5],"@E 9,999")) , FG_AlinVlrs(Transform(aITE[oLboxPITE:nAt,6],"@E 9,999,999.99")) , aITE[oLboxPITE:nAt,9] , aITE[oLboxPITE:nAt,10] , aITE[oLboxPITE:nAt,11] , aITE[oLboxPITE:nAt,12] }}
					Else
						@ aPos[2,1]+000,aPos[2,2]+002 LISTBOX oLboxPITE FIELDS ;
											HEADER STR0065,STR0066,STR0067,STR0068,STR0069,STR0084,STR0085,STR0086,STR0087 ;
											COLSIZES 40,80,140,40,63,63,63,63,63 SIZE aPos[2,4]-4,aPos[2,3]-aPos[2,1]-4 OF oTelaTES PIXEL ;
											ON DBLCLICK FS_TES_CC(oLboxPITE:nAt,nOperacao,.f.)
						oLboxPITE:SetArray(aITE)
						oLboxPITE:bLine := { || { aITE[oLboxPITE:nAt,2] , aITE[oLboxPITE:nAt,3] , aITE[oLboxPITE:nAt,4] , FG_AlinVlrs(Transform(aITE[oLboxPITE:nAt,5],"@E 9,999")) , FG_AlinVlrs(Transform(aITE[oLboxPITE:nAt,6],"@E 9,999,999.99")) , aITE[oLboxPITE:nAt,9] , aITE[oLboxPITE:nAt,10] , aITE[oLboxPITE:nAt,11] , aITE[oLboxPITE:nAt,12] }}
					EndIf
				ACTIVATE MSDIALOG oTelaTES ON INIT (EnchoiceBar(oTelaTES,{|| ( lRet := .t. , oTelaTES:End() ) },{ || oTelaTES:End()},,))
				If lRet .and. cTipDoc == "1" // Gerar 1=NF
					If nOperacao == 1 // Agregar
						SA3->(DbSetOrder(1))
						If Empty(cPSCdVen) .or. !SA3->(DbSeek(xFilial("SA3")+cPSCdVen))
							MsgStop(STR0037,STR0025) // Impossivel continuar. Vendedor nao encontrado! / Atencao
							lRet := .f.
						EndIf
					EndIf
					If lRet
						For ni := 1 to len(aITE) // Verificar se informou o TES
							If Empty(aITE[ni,8])
								lRet := .f.
								MsgStop(STR0082,STR0025) // TES não informado. Impossivel continuar. / Atencao
								Exit
							EndIf
						Next
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
If cTipDoc == "1" // Gerar NF
	If lRet        
		lRet := .f.
		If MsgYesNo(STR0026,STR0025) // Deseja selecionar a SERIE da NF de SAIDA do Equipamento? / Atencao
			lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1")) // Formulario Proprio SAIDA
			If GetNewPar("MV_TPNRNFS","1") == "3" // SD9
				cNumero := ""
			Endif
			aNumNFSF2 := {.f.,cNumero,cSerie}
		EndIf
	EndIf
	If lRet
		If nTipOper == 2 .and. nOperacao == 1 // AGREGAR PECA
			lRet := .f.
			If MsgYesNo(STR0060,STR0025) // Deseja selecionar a SERIE da NF de SAIDA da(s) Peca(s)? / Atencao
				lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1")) // Formulario Proprio SAIDA
				If GetNewPar("MV_TPNRNFS","1") == "3" // SD9
					cNumero := ""
				Endif
				aIteNFSF2 := {.f.,cNumero,cSerie}
				cNumero := aNumNFSF2[2]
				cSerie  := aNumNFSF2[3]
			EndIf
		EndIf
	EndIf
	If lRet
		lRet := .f.
		If MsgYesNo(STR0027,STR0025) // Deseja selecionar a SERIE da NF de ENTRADA do Equipamento? / Atencao
			lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1")) // Formulario Proprio ENTRADA
			If GetNewPar("MV_TPNRNFS","1") == "3" // SD9
				cNumero := ""
			Endif
			aNumNFSF1 := {.f.,cNumero,cSerie}
		EndIf
	EndIf
	If lRet
		If nTipOper == 2 .and. nOperacao == 2 // DESAGREGAR PECA
			lRet := .f.
			If MsgYesNo(STR0061,STR0025) // Deseja selecionar a SERIE da NF de ENTRADA da(s) Peca(s)? / Atencao
				lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1")) // Formulario Proprio ENTRADA
				If GetNewPar("MV_TPNRNFS","1") == "3" // SD9
					cNumero := ""
				Endif
				aIteNFSF1 := {.f.,cNumero,cSerie}
				cNumero := aNumNFSF1[2]
				cSerie  := aNumNFSF1[3]
			EndIf
		EndIf
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TES_CC³ Autor ³ Andre Luis Almeida                ³ Data ³ 16/09/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Alterar o TES, CC, Conta,... dos Itens                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TES_CC(nLinha,nOperacao,lNF)
Local ni        := 0
Local aRetTES   := {}
Local aParamBox := {}
Default lNF     := .t.
AADD(aParamBox,{1,STR0065,aITE[nLinha,02],"@!",'',"",".F.",30,.f.})
AADD(aParamBox,{1,STR0066,aITE[nLinha,03],"@!",'',"",".F.",60,.f.})
AADD(aParamBox,{1,STR0067,aITE[nLinha,04],"@!",'',"",".F.",100,.f.})
AADD(aParamBox,{1,STR0068,aITE[nLinha,05],"@E 9999",'',"",".F.",60,.f.})
If lNF
	AADD(aParamBox,{1,STR0081,aITE[nLinha,08],"@!",'vazio() .or. ( FG_Seek("SF4","MV_PAR05",1) .and. MaAvalTes("'+IIf(nOperacao==1,"S","E")+'",MV_PAR05) )',"SF4",".T.",30,.t.})
EndIf
AADD(aParamBox,{1,STR0084,aITE[nLinha,09],"@!",'Vazio() .or. Ctb105CC()',"CTT",".T.",50,.f.}) // Centro de Custo
AADD(aParamBox,{1,STR0085,aITE[nLinha,10],"@!",'Vazio() .or. Ctb105Cta()',"CT1",".T.",90,.f.}) // Conta Contabil
AADD(aParamBox,{1,STR0086,aITE[nLinha,11],"@!",'Vazio() .Or. Ctb105Item()',"CTD",".T.",50,.f.}) // Item Conta Contabil
AADD(aParamBox,{1,STR0087,aITE[nLinha,12],"@!",'Vazio() .Or. Ctb105ClVl()',"CTH",".T.",50,.f.}) // Classe Valor
For ni := 1 to len(aParambox)
	aAdd(aRetTES,aParambox[ni,3]) // Carregando conteudo Default
Next
If ParamBox(aParamBox,IIf(lNF,STR0089,STR0097) ,@aRetTES,,,,,,,,.f.) // Notas Fiscais / Mov.Interna
	If lNF // NF
		aITE[nLinha,08] := aRetTES[5]
		aITE[nLinha,09] := aRetTES[6]
		aITE[nLinha,10] := aRetTES[7]
		aITE[nLinha,11] := aRetTES[8]
		aITE[nLinha,12] := aRetTES[9]
	Else // Mov.Interna
		aITE[nLinha,09] := aRetTES[5]
		aITE[nLinha,10] := aRetTES[6]
		aITE[nLinha,11] := aRetTES[7]
		aITE[nLinha,12] := aRetTES[8]
	EndIf
	oLboxPITE:Refresh()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VX040CANC ³ Autor ³ Andre Luis Almeida                ³ Data ³ 06/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cancelar NFs/Movimentacoes de Agregacao/Desagregacao                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX040CANC()
Local ni          := 0
Local aObjects    := {} , aPos := {} , aInfo := {} 
Local aSizeHalf   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lOkTela     := .f.
Local nLin        := 0
Local aTipAD      := X3CBOXAVET("VDV_AGRDES","1") 
Local aTemp       := {}
Local aCabNFE     := {}
Local aIteNFE     := {}
Local lNFeCancel  := SuperGetMV('MV_CANCNFE',.F.,.F.) .AND. SF2->(ColumnPos("F2_STATUS")) > 0
Local cNumPed     := ""
Local lVDV_SNUMNP := ( VDV->(ColumnPos("VDV_SNUMNP")) > 0 ) // Nro. NF Saida Peças
Local lVDV_ENUMNP := ( VDV->(ColumnPos("VDV_ENUMNP")) > 0 ) // Nro. NF Entrada Peças
Local lVDV_TIPDOC := ( VDV->(ColumnPos("VDV_TIPDOC")) > 0 ) // Gerar ? ( 1=NF / 2=SD3 (Mov.Internas) )
Local aSB1SD3     := {}
Local aTotVV1     := {}
Private aVDV      := {}
Private cTipAD    := ""
Private dDtIni    := ctod("")
Private dDtFin    := dDataBase
Private cChaInt   := VV1->VV1_CHAINT
Private cChassi   := VV1->VV1_CHASSI
//
nOpc := 5 // Setar nOpc com 5 para chamar as funcoes padrao de Cancelamento.
//
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0, 20, .T. , .F. } ) // Filtro
AAdd( aObjects, { 0,  0, .T. , .T. } ) // ListBox VDV
aPos := MsObjSize( aInfo, aObjects )
//
FS_LEVVDV(0,cChaInt)
//
DEFINE MSDIALOG oTelaVDV TITLE (STR0042) FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Cancelar
//
oTelaVDV:lEscClose := .F.
//
@ aPos[1,1] + 000 , aPos[1,2] + 001 TO aPos[1,3],aPos[1,4] LABEL "" OF oTelaVDV PIXEL
@ aPos[1,1] + 006 , aPos[1,2] + 006 SAY (STR0004+":") OF oTelaVDV PIXEL // Chassi
@ aPos[1,1] + 005 , aPos[1,2] + 026 MSGET oChassi VAR cChassi PICTURE "@!" VALID FG_POSVEI("cChassi",) F3 "VV1" SIZE 85,08 OF oTelaVDV PIXEL HASBUTTON
@ aPos[1,1] + 006 , aPos[1,2] + 117 SAY (STR0044+":") OF oTelaVDV PIXEL // Periodo
@ aPos[1,1] + 005 , aPos[1,2] + 139 MSGET oDtIni VAR dDtIni PICTURE "@D" SIZE 43,08 OF oTelaVDV PIXEL HASBUTTON
@ aPos[1,1] + 006 , aPos[1,2] + 184 SAY (STR0045) OF oTelaVDV PIXEL // a
@ aPos[1,1] + 005 , aPos[1,2] + 190 MSGET oDtFin VAR dDtFin PICTURE "@D" SIZE 43,08 OF oTelaVDV PIXEL HASBUTTON
@ aPos[1,1] + 006 , aPos[1,2] + 240 SAY (STR0043+":") OF oTelaVDV PIXEL // Tipo
@ aPos[1,1] + 005 , aPos[1,2] + 255 MSCOMBOBOX oTipAD VAR cTipAD SIZE 55,08 COLOR CLR_BLACK ITEMS aTipAD OF oTelaVDV PIXEL
@ aPos[1,1] + 005 , aPos[1,2] + 320 BUTTON oBFiltr PROMPT STR0052 OF oTelaVDV SIZE 40,10 PIXEL ACTION FS_LEVVDV(1,cChaInt) // Filtrar
//
@ aPos[2,1]+001,aPos[2,2]+001 LISTBOX oLboxVDV 	FIELDS HEADER STR0043,STR0046,STR0047,STR0048,STR0004,STR0049,STR0050,"NF Saida Peça",STR0049,STR0051,"NF Entrada Peça" ;
												COLSIZES 40,40,25,65,80,60,50,50,60,50,50 SIZE aPos[2,4]-004,aPos[2,3]-aPos[2,1] OF oTelaVDV PIXEL ;
												ON DBLCLICK IIf(FS_CONFCAN(),( nLin := oLboxVDV:nAt , lOkTela := .t. , oTelaVDV:End() ) , .t. )
oLboxVDV:SetArray(aVDV)
oLboxVDV:bLine := { || {	IIf(!Empty(aVDV[oLboxVDV:nAt,2]),X3CBOXDESC("VDV_AGRDES",aVDV[oLboxVDV:nAt,2]),"") ,;
							Transform(aVDV[oLboxVDV:nAt,3],"@D") ,;
							Transform(aVDV[oLboxVDV:nAt,04],"@R 99:99") ,;
							aVDV[oLboxVDV:nAt,5] ,;
							aVDV[oLboxVDV:nAt,6] ,;
							aVDV[oLboxVDV:nAt,7] ,;
							aVDV[oLboxVDV:nAt,8] ,;
							aVDV[oLboxVDV:nAt,11] ,;
							aVDV[oLboxVDV:nAt,9] ,;
							aVDV[oLboxVDV:nAt,10] ,;
							aVDV[oLboxVDV:nAt,12] }}
//
ACTIVATE MSDIALOG oTelaVDV ON INIT (EnchoiceBar(oTelaVDV,{|| IIf( FS_CONFCAN() , ( nLin := oLboxVDV:nAt , lOkTela := .t. , oTelaVDV:End() ) , .t. ) },{ || oTelaVDV:End()},,))
//
If lOkTela
	DbSelectArea("VDV")
	DbGoTo(aVDV[nLin,1])
	//
	If !lVDV_TIPDOC .or. VDV->VDV_TIPDOC <> '2' // Gerar ? ( 1=NF / 2=SD3 (Mov.Internas) )
	//
		If lVDV_SNUMNP .and. !Empty(VDV->VDV_SNUMNP) // Possui NF de Saida de Pecas
			DBSelectArea("SF2")
			DBSetOrder(1)
			dbSeek( VDV->VDV_SFILNF + VDV->VDV_SNUMNP + VDV->VDV_SSERNP )
			dbSelectArea("SD2")
			dbSetOrder(3)
			dbSeek( VDV->VDV_SFILNF + VDV->VDV_SNUMNP + VDV->VDV_SSERNP )
			If lNFeCancel
				cNumPed := SD2->D2_PEDIDO
				aRegSD2 := {}
				aRegSE1 := {}
				aRegSE2 := {}
				If !FGX_STATF2("D",VDV->VDV_SSERNP,VDV->VDV_SNUMNP,SF2->F2_CLIENTE,SF2->F2_LOJA,"S") // verifica se NF foi Deletada
					If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
						PERGUNTE("MTA521",.f.)
						If !SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1)))
							Return
						Endif
					Else
						Return
					EndIf
					If !FGX_STATF2("V",VDV->VDV_SSERNP,VDV->VDV_SNUMNP,SF2->F2_CLIENTE,SF2->F2_LOJA,"S") /// Verifica STATUS da NF no SEFAZ
						Return
					EndIf
				Endif
			Endif
		EndIf
	//
	EndIf
	//
	BEGIN TRANSACTION
	//
	DbSelectArea("VDV")
	RecLock("VDV",.f.)
		VDV->VDV_STATUS := "0" // 1=Ativo / 0=Cancelado
	MsUnLock()
	//
	If !lVDV_TIPDOC .or. VDV->VDV_TIPDOC <> '2' // Gerar ? ( 1=NF / 2=SD3 (Mov.Internas) )
	//
		//////////////////
		// NF ENTRADA   //
		//////////////////
		lMsErroAuto := .t.
		DbSelectArea("VVF")
		DbSetOrder(6) // VVF_FILIAL+VVF_NUMNFI+VVF_SERNFI+VVF_CODFOR+VVF_LOJA
		If DbSeek( VDV->VDV_EFILNF + VDV->VDV_ENUMNF + VDV->VDV_ESERNF + VDV->VDV_ECDFOR + VDV->VDV_ELJFOR )
			VVF->(DbSetOrder(1))
			//
			DbSelectArea("VVG")
			DbSetOrder(1) // VVG_FILIAL+VVG_TRACPA
			DbSeek( VVF->VVF_FILIAL + VVF->VVF_TRACPA )
			//
			lMsErroAuto := .f.
			//
			If !VEIXX000(NIL,NIL,NIL,5,"0")
				DisarmTransaction()
				Return
			EndIf
			//
		EndIf
		If lMsErroAuto
			DisarmTransaction()
			MostraErro()
			Return
		EndIf
		//
		If lVDV_ENUMNP .and. !Empty(VDV->VDV_ENUMNP) // Possui NF de Entrada de Pecas
			DBSelectArea("SF1")
			DBSetOrder(1)
			dbSeek( VDV->VDV_EFILNF + VDV->VDV_ENUMNP + VDV->VDV_ESERNP + VDV->VDV_ECDFOP + VDV->VDV_ELJFOP )
			dbSelectArea("SD1")
			dbSetOrder(1)
			dbSeek( VDV->VDV_EFILNF + VDV->VDV_ENUMNP + VDV->VDV_ESERNP + VDV->VDV_ECDFOP + VDV->VDV_ELJFOP )
			While !Eof() .and. SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == VDV->VDV_EFILNF + VDV->VDV_ENUMNP + VDV->VDV_ESERNP + VDV->VDV_ECDFOP + VDV->VDV_ELJFOP
				aTemp := {}
				aAdd(aTemp,{"D1_DOC"   	,SD1->D1_DOC	,Nil})
				aAdd(aTemp,{"D1_SERIE" 	,SD1->D1_SERIE	,Nil})
				aAdd(aTemp,{"D1_FORNECE",SD1->D1_FORNECE,Nil})
				aAdd(aTemp,{"D1_LOJA"	,SD1->D1_LOJA	,Nil})
				aAdd(aTemp,{"D1_COD"    ,SD1->D1_COD	,Nil})
				aAdd(aTemp,{"D1_ITEM"   ,SD1->D1_ITEM	,Nil})
				aAdd(aIteNFE,aClone(aTemp))
				DBSelectArea("SD1")
				DbSkip()
			EndDo
			//#############################################################################
			//# Montagem do cabecalho para integracao MATA103                             #
			//#############################################################################
			aCabNFE := {}
			aAdd(aCabNFE,{"F1_DOC"	  ,SF1->F1_DOC    ,Nil})
			aAdd(aCabNFE,{"F1_SERIE"  ,SF1->F1_SERIE  ,Nil})
			aAdd(aCabNFE,{"F1_FORNECE",SF1->F1_FORNECE,Nil})
			aAdd(aCabNFE,{"F1_LOJA"   ,SF1->F1_LOJA   ,Nil})
			aAdd(aCabNFE,{"F1_TIPO"	  ,SF1->F1_TIPO   ,Nil})
			aAdd(aCabNFE,{"F1_FORMUL" ,SF1->F1_FORMUL ,Nil})
			aAdd(aCabNFE,{"F1_EMISSAO",SF1->F1_EMISSAO,Nil})
			aAdd(aCabNFE,{"F1_ESPECIE",SF1->F1_ESPECIE,Nil})
			aAdd(aCabNFE,{"F1_COND"	  ,SF1->F1_COND   ,Nil})
			aAdd(aCabNFE,{"F1_EST"	  ,SF1->F1_EST    ,Nil})
			If !Empty(SF1->F1_TRANSP)
				aAdd(aCabNFE,{"F1_TRANSP"  ,SF1->F1_TRANSP  ,Nil})
				aAdd(aCabNFE,{"F1_ESPECIE1",SF1->F1_ESPECIE1,Nil})
				aAdd(aCabNFE,{"F1_VOLUME1" ,SF1->F1_VOLUME1 ,Nil})
				aAdd(aCabNFE,{"F1_ESPECIE2",SF1->F1_ESPECIE2,Nil})
				aAdd(aCabNFE,{"F1_VOLUME2" ,SF1->F1_VOLUME2 ,Nil})
				aAdd(aCabNFE,{"F1_ESPECIE3",SF1->F1_ESPECIE3,Nil})
				aAdd(aCabNFE,{"F1_VOLUME3" ,SF1->F1_VOLUME3 ,Nil})
				aAdd(aCabNFE,{"F1_ESPECIE4",SF1->ESPECIE4   ,Nil})
				aAdd(aCabNFE,{"F1_VOLUME4" ,SF1->VOLUME4    ,Nil})
			EndIf
			lMsErroAuto := .f.
			MSExecAuto({|x,y,z|Mata103(x,y,z)},aCabNFE,aIteNFE,5)
			If lMsErroAuto
				DisarmTransaction()
				Return
			EndIf
			FMX_TELAINF( "1" , { { Alltrim(VDV->VDV_ESERNP) , Alltrim(VDV->VDV_ENUMNP) , STR0083 } } ) // CANCELADO
		EndIf
		//
		//////////////////
		// NF SAIDA	    //
		//////////////////
		lMsErroAuto := .t.
		DbSelectArea("VV0")
		DbSetOrder(4) // VV0_FILIAL+VV0_NUMNFI+VV0_SERNFI
		If DbSeek( VDV->VDV_SFILNF + VDV->VDV_SNUMNF + VDV->VDV_SSERNF )
			VV0->(DbSetOrder(1))
			//
			DbSelectArea("VVA")
			DbSetOrder(1) // VVA_FILIAL+VVA_NUMTRA
			DbSeek( VV0->VV0_FILIAL + VV0->VV0_NUMTRA )
			//
			lMsErroAuto := .f.
			//
			If !VEIXX001(NIL,NIL,NIL,5,"0")
				DisarmTransaction()
				Return
			EndIf
			//
		EndIf
		If lMsErroAuto
			DisarmTransaction()
			MostraErro()
			Return
		EndIf
		//
		If lVDV_SNUMNP .and. !Empty(VDV->VDV_SNUMNP) // Possui NF de Saida de Pecas
			DBSelectArea("SF2")
			DBSetOrder(1)
			dbSeek( VDV->VDV_SFILNF + VDV->VDV_SNUMNP + VDV->VDV_SSERNP )
			dbSelectArea("SD2")
			dbSetOrder(3)
			dbSeek( VDV->VDV_SFILNF + VDV->VDV_SNUMNP + VDV->VDV_SSERNP )
			If !lNFeCancel
				cNumPed := SD2->D2_PEDIDO
				aRegSD2 := {}
				aRegSE1 := {}
				aRegSE2 := {}
				If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
					PERGUNTE("MTA521",.f.)
					SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1)))
				Else
					DisarmTransaction()
					MostraErro()
					Return
				EndIf
			Endif
			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
				Return
			EndIf
			dbSelectArea("SC5")
			dbSetOrder(1)
			if dbSeek(xFilial("SC5")+cNumPed)
				aMata410Cab   := {{"C5_NUM",cNumPed,Nil}} // Numero do Pedido SC5
				aMata410Itens := {{"C6_NUM",cNumPed,Nil}} // Numero do Pedido SC6
				//Exclui Pedido
				SC9->(dbSetOrder(1))
				SC9->(dbSeek(xFilial("SC9")+cNumPed))
				While !SC9->(Eof()) .And. xFilial('SC9') == SC9->C9_FILIAL .and. cNumPed == SC9->C9_PEDIDO
					SC9->(a460Estorna())
					SC9->(dbSkip())
				EndDo
				MSExecAuto({|x,y,z|Mata410(x,y,z)},aMata410Cab,{aMata410Itens},5)
			Endif
			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
				Return
			EndIf
			FMX_TELAINF( "1" , { { Alltrim(VDV->VDV_SSERNP) , Alltrim(VDV->VDV_SNUMNP) , STR0083 } } ) // CANCELADO
		EndIf
		//
	Else // Movimentacao Interna
		//
		/////////////////////////////////////////////////////////////////////////////////////////////////////////
		// CRIAR MOVIMENTACAO INTERNA SD3 para reverter a Mov.Interna de Saida/Entrada realizada anteriormente //
		/////////////////////////////////////////////////////////////////////////////////////////////////////////
		aSB1SD3 := FS_ADD_SD3( "1" , "1" , VDV->VDV_CODIGO , @aTotVV1 ) // Carregar Vetores dos SD3 para Cancela-los
		If len(aSB1SD3) > 0
			If !VXX040SD3( "2" , "0" , VDV->VDV_CODIGO , aSB1SD3 ) // Mov.Interna Peça ( 2=Saida , 0=Tp.Cancelamento , Codigo VDV , aSB1 )
				Return
			EndIf
		EndIf
		aSB1SD3 := FS_ADD_SD3( "2" , "1" , VDV->VDV_CODIGO , @aTotVV1 ) // Carregar Vetores dos SD3 para Cancela-los
		If len(aSB1SD3) > 0
			If !VXX040SD3( "1" , "0" , VDV->VDV_CODIGO , aSB1SD3 ) // Mov.Interna Peça ( 1=Entrada , 0=Tp.Cancelamento , Codigo VDV , aSB1 )
				Return
			EndIf
		EndIf
		//
		DbSelectArea("VV0")
		DbSetOrder(1) // VV0_FILIAL+VV0_NUMTRA
		If DbSeek( VDV->VDV_FILVV0 + VDV->VDV_NUMTRA )
			RecLock("VV0",.f.)
				VV0->VV0_SITNFI := "0" // Cancelada
				VV0->VV0_STATUS := "C"
			MsUnLock()
		EndIf
		DbSelectArea("VVF")
		DbSetOrder(1) // VVF_FILIAL+VVF_TRACPA
		If DbSeek( VDV->VDV_FILVVF + VDV->VDV_TRACPA )
			RecLock("VVF",.f.)
				VVF->VVF_SITNFI := "0" // Cancelada
			MsUnLock()
		EndIf
	EndIf
	//
	END TRANSACTION
	//
	If lVDV_TIPDOC .and. VDV->VDV_TIPDOC == '2' // Gerar ? ( 1=NF / 2=SD3 (Mov.Internas) )
		//
		For ni := 1 to len(aTotVV1)
			FGX_AMOVVEI(xFilial("VV1"),aTotVV1[ni]) // VV1_CHASSI - Corrigir campos utilizados nas Movimentações
		Next	
		//
		FMX_TELAINF( "4" , { { STR0097 , STR0083 } } ) // Mov.Interna / CANCELADO
		//
	EndIf
	//
EndIf

DbSelectArea("VV1")
DbSetOrder(1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ADD_SD3  ³ Autor ³ Andre Luis Almeida             ³ Data ³ 07/02/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Adiciona os SD3 no Vetor para reverter as movimentacoes internas       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ADD_SD3( cSaiEnt , cTipMov , cCodVDV , aTotVV1 )
Local cGruVei   := left(GetMv("MV_GRUVEI")+space(10),len(SB1->B1_GRUPO))
Local aRetSD3   := {}
Local cQuery    := ""
Local cSQLAlias := "SQLSD3"
cQuery := "SELECT SB1.B1_COD , SB1.B1_DESC , SB1.B1_GRUPO , "
cQuery += "       SD3.D3_QUANT , SD3.D3_CUSTO1 , "
cQuery += "       SD3.D3_CC , SD3.D3_CONTA , SD3.D3_ITEMCTA , SD3.D3_CLVL "
cQuery += " FROM " + RetSqlName("VBH") + " VBH "
cQuery += " JOIN " + RetSqlName("SB1") + " SB1 "
cQuery += "   ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += "  AND SB1.B1_COD = VBH.VBH_CODSB1 "
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " JOIN " + RetSqlName("SD3") + " SD3 "
cQuery += "   ON SD3.D3_FILIAL = '" + xFilial("SD3") + "' "
cQuery += "  AND SD3.D3_DOC    = VBH.VBH_DOCSD3 "
cQuery += "  AND SD3.D3_NUMSEQ = VBH.VBH_NUMSEQ "
cQuery += "  AND SD3.D3_COD    = VBH.VBH_CODSB1 "
cQuery += "  AND SD3.D_E_L_E_T_ = ' ' "
cQuery += "WHERE VBH.VBH_FILIAL = '" + xFilial("VBH") + "' "
cQuery += "  AND VBH.VBH_CODVDV = '" + cCodVDV + "' " 
cQuery += "  AND VBH.VBH_SAIENT = '" + cSaiEnt + "' "
cQuery += "  AND VBH.VBH_TIPMOV = '" + cTipMov + "' "
cQuery += "  AND VBH.D_E_L_E_T_ = ' ' "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
While !(cSQLAlias)->(Eof())
	// ( Codigo SB1 , Qtde , Valor , Centro de Custo , Conta Contab , Item Conta , Class.Valor )
	aAdd(aRetSD3,{	(cSQLAlias)->( B1_COD ) ,;
					(cSQLAlias)->( D3_QUANT ) ,;
					Round((cSQLAlias)->( D3_CUSTO1 ),2) ,;
					(cSQLAlias)->( D3_CC ) ,;
					(cSQLAlias)->( D3_CONTA ) ,;
					(cSQLAlias)->( D3_ITEMCTA ) ,;
					(cSQLAlias)->( D3_CLVL ) })
	If (cSQLAlias)->( B1_GRUPO ) == cGruVei // somente Veiculos e AMS
		aAdd(aTotVV1,(cSQLAlias)->( B1_DESC )) // VV1_CHASSI
	EndIf
	(cSQLAlias)->(dbSkip())
EndDo
(cSQLAlias)->(dbCloseArea())
DbSelectArea("SD3")
Return aClone(aRetSD3)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LEVVDV   ³ Autor ³ Andre Luis Almeida             ³ Data ³ 09/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta registros VDV para cancelar                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVVDV(nTp,cChaInt)
Local cQuery    := ""
Local cSQLAlias := "SQLVDV"
Local cNFSai    := ""
Local cNFEnt    := ""
Local cNFPSai   := ""
Local cNFPEnt   := ""
Local lVDV_TIPDOC := ( VDV->(ColumnPos("VDV_TIPDOC")) > 0 ) // Gerar ? ( 1=NF / 2=SD3 (Mov.Internas) )
Local lVDV_SNUMNP := ( VDV->(ColumnPos("VDV_SNUMNP")) > 0 ) // Nro. NF Saida Peças
Local lVDV_ENUMNP := ( VDV->(ColumnPos("VDV_ENUMNP")) > 0 ) // Nro. NF Entrada Peças
Default cChaInt := ""
If nTp > 0
	If !Empty(cChassi)
		cChaInt := FM_SQL("SELECT VV1_CHAINT FROM "+RetSQLName("VV1")+" WHERE VV1_FILIAL='"+xFilial("VV1")+"' AND VV1_CHASSI='"+cChassi+"' AND D_E_L_E_T_=' '")
	EndIf
EndIf
aVDV   := {}
cQuery := "SELECT VDV.R_E_C_N_O_ RECVDV , VDV.VDV_AGRDES "
cQuery += "     , VDV.VDV_DATMOV , VDV.VDV_HORMOV , VDV.VDV_CODUSR , VV1.VV1_CHASSI "
cQuery += "     , VDV.VDV_SFILNF , VDV.VDV_SNUMNF , VDV.VDV_SSERNF "
cQuery += "     , VDV.VDV_EFILNF , VDV.VDV_ENUMNF , VDV.VDV_ESERNF "
If lVDV_TIPDOC
	cQuery += " , VDV.VDV_TIPDOC "
EndIf
If lVDV_SNUMNP
	cQuery += " , VDV.VDV_SNUMNP , VDV.VDV_SSERNP " // NF Saida Peca
EndIf
If lVDV_ENUMNP
	cQuery += " , VDV.VDV_ENUMNP , VDV.VDV_ESERNP " // NF Entrada Peca
EndIf
cQuery += "FROM "+RetSQLName("VDV")+" VDV "
cQuery += "JOIN "+RetSQLName("VV1")+" VV1 ON ( VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=VDV.VDV_CHAINT AND VV1.D_E_L_E_T_=' ' ) "
cQuery += "WHERE VDV.VDV_FILIAL='"+xFilial("VDV")+"' AND "
If !Empty(cChaInt)
	cQuery += "VDV.VDV_CHAINT='"+cChaInt+"' AND "
EndIf
If !Empty(cTipAD)
	cQuery += "VDV.VDV_AGRDES='"+cTipAD+"' AND "
EndIf
cQuery += "VDV.VDV_DATMOV >= '"+dtos(dDtIni)+"' AND VDV.VDV_DATMOV <= '"+dtos(dDtFin)+"' AND "
cQuery += "VDV.VDV_STATUS IN (' ','1') AND "
cQuery += "VDV.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
While !(cSQLAlias)->(Eof())
	cNFSai  := ""
	cNFEnt  := ""
	cNFPSai := ""
	cNFPEnt := ""
	If lVDV_TIPDOC .and. (cSQLAlias)->( VDV_TIPDOC ) == "2" // Gerar ? ( 1=NF / 2=SD3 (Mov.Internas) )
		cNFSai := STR0097 // Mov.Interna
		cNFEnt := STR0097 // Mov.Interna
	Else
		cNFSai  := (cSQLAlias)->( VDV_SNUMNF )+"-"+(cSQLAlias)->( VDV_SSERNF ) // NF Saida
		cNFEnt  := (cSQLAlias)->( VDV_ENUMNF )+"-"+(cSQLAlias)->( VDV_ESERNF ) // NF Entrada
		If lVDV_SNUMNP .and. !Empty( (cSQLAlias)->( VDV_SNUMNP ) )
			cNFPSai := (cSQLAlias)->( VDV_SNUMNP )+"-"+(cSQLAlias)->( VDV_SSERNP ) // NF Saida Peca
		EndIf
		If lVDV_ENUMNP .and. !Empty( (cSQLAlias)->( VDV_ENUMNP ) )
			cNFPEnt := (cSQLAlias)->( VDV_ENUMNP )+"-"+(cSQLAlias)->( VDV_ESERNP ) // NF Entrada Peca
		EndIf
	EndIf
	aAdd(aVDV,{	(cSQLAlias)->( RECVDV ),;
				(cSQLAlias)->( VDV_AGRDES ),;
				stod((cSQLAlias)->( VDV_DATMOV )),;
				(cSQLAlias)->( VDV_HORMOV ),;
				left(Alltrim(UsrRetName((cSQLAlias)->( VDV_CODUSR ))),15),;
				(cSQLAlias)->( VV1_CHASSI ),;
				(cSQLAlias)->( VDV_SFILNF ),;
				cNFSai,;
				(cSQLAlias)->( VDV_EFILNF ),;
				cNFEnt,;
				cNFPSai,;
				cNFPEnt })
	(cSQLAlias)->(dbSkip())
EndDo
(cSQLAlias)->(dbCloseArea())
If len(aVDV) <= 0
	aAdd(aVDV,{0,"",stod(""),0,"","","","","","","",""})
EndIf
If nTp > 0
	oLboxVDV:nAt := 1
	oLboxVDV:SetArray(aVDV)
	oLboxVDV:bLine := { || {	IIf(!Empty(aVDV[oLboxVDV:nAt,2]),X3CBOXDESC("VDV_AGRDES",aVDV[oLboxVDV:nAt,2]),"") ,;
								Transform(aVDV[oLboxVDV:nAt,3],"@D") ,;
								Transform(aVDV[oLboxVDV:nAt,04],"@R 99:99") ,;
								aVDV[oLboxVDV:nAt,5] ,;
								aVDV[oLboxVDV:nAt,6] ,;
								aVDV[oLboxVDV:nAt,7] ,;
								aVDV[oLboxVDV:nAt,8] ,;
								aVDV[oLboxVDV:nAt,11] ,;
								aVDV[oLboxVDV:nAt,9] ,;
								aVDV[oLboxVDV:nAt,10] ,;
								aVDV[oLboxVDV:nAt,12] }}
	oLboxVDV:Refresh()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CONFCAN  ³ Autor ³ Andre Luis Almeida             ³ Data ³ 09/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Confirma cancelamento dos registros VDV ( NF de Saida / NF de Entrada )³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CONFCAN()
Local lRet    := .f.
Local lOk     := .t.
Local aUltMov := {}
Local cMsg    := ""
Local cQuery  := ""
Local cPictQtd   := x3Picture("B2_QATU")
Local nSaldoSB2  := 0
Local cPulaLinha := CHR(13)+CHR(10) // Pula linha
Local lVDV_SNUMNP := ( VDV->(ColumnPos("VDV_SNUMNP")) > 0 ) // Nro. NF Saida Peças
Local lVDV_ENUMNP := ( VDV->(ColumnPos("VDV_ENUMNP")) > 0 ) // Nro. NF Entrada Peças
Local lVDV_TIPDOC := ( VDV->(ColumnPos("VDV_TIPDOC")) > 0 ) // Gerar ? ( 1=NF / 2=SD3 (Mov.Internas) )
Local lVDV_NUMTRA := ( VDV->(ColumnPos("VDV_NUMTRA")) > 0 ) // Nro.Transação Saida - VV0
Local lVDV_TRACPA := ( VDV->(ColumnPos("VDV_TRACPA")) > 0 ) // Nro.Transação Entrada - VVF
Local lSeekOK := .f.
//
If aVDV[oLboxVDV:nAt,1] > 0
	//
	cQuery := "SELECT VDV.R_E_C_N_O_ "
	cQuery += "FROM "+RetSQLName("VDV")+" VDV "
	cQuery += "JOIN "+RetSQLName("VV1")+" VV1 ON ( VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=VDV.VDV_CHAINT AND VV1.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VDV.VDV_FILIAL = '"+xFilial("VDV")+"'"
	cQuery += "  AND VDV.VDV_STATUS IN (' ','1') "
	cQuery += "  AND VDV.R_E_C_N_O_ > "+str(aVDV[oLboxVDV:nAt,1])
	cQuery += "  AND VDV.D_E_L_E_T_ = ' '"
	cQuery += "  AND VV1.VV1_CHASSI = '"+aVDV[oLboxVDV:nAt,6]+"'"
	If FM_SQL(cQuery) > 0
		MsgStop(STR0053+cPulaLinha+cPulaLinha+STR0004+": "+aVDV[oLboxVDV:nAt,6],STR0025) // Para cancelar este movimento, sera necessário cancelar todos os movimentos posteriores! / Chassi / Atencao
		lOk := .f.
	EndIf
	//
	If lOk
		//
		DbSelectArea("VDV")
		DbGoTo(aVDV[oLboxVDV:nAt,1])
		//
		lSeekOK := .f.
		If lVDV_TRACPA .and. !Empty(VDV->VDV_TRACPA)
			DbSelectArea("VVF")
			DbSetOrder(1) // VVF_FILIAL+VVF_TRACPA
			If DbSeek( VDV->VDV_EFILNF + VDV->VDV_TRACPA )
				lSeekOK := .t.
			EndIf
		ElseIf !lVDV_TIPDOC .or. VDV->VDV_TIPDOC <> '2' // Gerar ? ( 1=NF / 2=SD3 (Mov.Internas) )
			DbSelectArea("VVF")
			DbSetOrder(6) // VVF_FILIAL+VVF_NUMNFI+VVF_SERNFI+VVF_CODFOR+VVF_LOJA
			If DbSeek( VDV->VDV_EFILNF + VDV->VDV_ENUMNF + VDV->VDV_ESERNF + VDV->VDV_ECDFOR + VDV->VDV_ELJFOR )
				lSeekOK := .t.
			EndIf
		EndIf
		If lSeekOK
			DbSelectArea("VVG")
			DbSetOrder(1) // VVG_FILIAL+VVG_TRACPA
			If DbSeek( VVF->VVF_FILIAL + VVF->VVF_TRACPA )
				While !Eof() .and. VVG->VVG_FILIAL + VVG->VVG_TRACPA == VVF->VVF_FILIAL + VVF->VVF_TRACPA
					DbSelectArea("VV1")
					DbSetOrder(1) // VV1_FILIAL+VV1_CHAINT
					DbSeek( xFilial("VV1") + VVG->VVG_CHAINT )
					If VV1->VV1_SITVEI<>"0"
						MsgStop(STR0033+cPulaLinha+cPulaLinha+STR0004+": "+VV1->VV1_CHASSI,STR0025) // Equipamento nao esta no Estoque! / Atencao
						lOk := .f.
						Exit
					EndIf
					aUltMov := FM_VEIUMOV( VV1->VV1_CHASSI , "E" , )
					If len(aUltMov) > 0
						If aUltMov[3] > VVF->VVF_TRACPA
							MsgStop(STR0054+cPulaLinha+cPulaLinha+STR0004+": "+VV1->VV1_CHASSI,STR0025) // Impossivel cancelar movimentacao anterior a ultima entrada! / Atencao
							lOk := .f.
							Exit
						EndIf
					EndIf
					DbSelectArea("VVG")
					DbSkip()
				EndDo
			EndIf
		EndIf
		//
		lSeekOK := .f.
		If lOk 
			If lVDV_NUMTRA .and. !Empty(VDV->VDV_NUMTRA)
				DbSelectArea("VV0")
				DbSetOrder(1) // VV0_FILIAL+VV0_NUMTRA
				If DbSeek( VDV->VDV_FILVV0 + VDV->VDV_NUMTRA )
					lSeekOK := .t.
				EndIf
			ElseIf !lVDV_TIPDOC .or. VDV->VDV_TIPDOC <> '2' // Gerar ? ( 1=NF / 2=SD3 (Mov.Internas) )
				DbSelectArea("VV0")
				DbSetOrder(4) // VV0_FILIAL+VV0_NUMNFI+VV0_SERNFI
				If DbSeek( VDV->VDV_SFILNF + VDV->VDV_SNUMNF + VDV->VDV_SSERNF )
					lSeekOK := .t.
				EndIf
			EndIf
		EndIf
		If lSeekOK
			DbSelectArea("VVA")
			DbSetOrder(1) // VVA_FILIAL+VVA_NUMTRA
			If DbSeek( VV0->VV0_FILIAL + VV0->VV0_NUMTRA )
				While !Eof() .and. VVA->VVA_FILIAL + VVA->VVA_NUMTRA == VV0->VV0_FILIAL + VV0->VV0_NUMTRA
					DbSelectArea("VV1")
					DbSetOrder(1) // VV1_FILIAL+VV1_CHAINT
					DbSeek( xFilial("VV1") + VVA->VVA_CHAINT )
					aUltMov := FM_VEIUMOV( VV1->VV1_CHASSI , "S" , )
					If len(aUltMov) > 0
						If aUltMov[3] > VV0->VV0_NUMTRA
							MsgStop(STR0055+cPulaLinha+cPulaLinha+STR0004+": "+VV1->VV1_CHASSI,STR0025) // Impossivel cancelar movimentacao anterior a ultima saida! / Atencao
							lOk := .f.
							Exit
						EndIf
					EndIf
					DbSelectArea("VVA")
					DbSkip()
				EndDo
			EndIf
		EndIf
		//
		If lOk .and. VDV->VDV_AGRDES == "2" // 2=Desagrega
			If lVDV_SNUMNP .and. !Empty(VDV->VDV_SNUMNP) // Possui NF de Saida de Pecas
				lOk := .f.
				DbSelectArea("SD1")
				DbSetOrder(1) // D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA
				If DbSeek( VDV->VDV_EFILNF + VDV->VDV_ENUMNP + VDV->VDV_ESERNP + VDV->VDV_ECDFOP + VDV->VDV_ELJFOP )
					lOk := .t.
					While !Eof() .and. SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == VDV->VDV_EFILNF + VDV->VDV_ENUMNP + VDV->VDV_ESERNP + VDV->VDV_ECDFOP + VDV->VDV_ELJFOP
						SB1->(DbSetOrder(1))
						SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))
						SB2->(DbSetOrder(1))
						SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+SD1->D1_LOCAL))
						nSaldoSB2 := SALDOSB2()
						If nSaldoSB2 < SD1->D1_QUANT
							MsgStop(STR0094+cPulaLinha+cPulaLinha+;
									SB1->B1_GRUPO+" "+Alltrim(SB1->B1_CODITE)+" - "+left(SB1->B1_DESC,20)+cPulaLinha+;
									STR0032+": "+Transform(SD1->D1_QUANT,cPictQtd)+cPulaLinha+;
									STR0101+": "+Transform(nSaldoSB2,cPictQtd),STR0025) // Impossivel cancelar movimentacao. Item com saldo insuficiente! / Qtde: / Saldo: / Atencao 
							lOk := .f.
							DbSelectArea("SD1")
							Exit
						EndIf
						DbSelectArea("SD1")
						DbSkip()
					EndDo
				EndIf
			ElseIf lVDV_TIPDOC .and. VDV->VDV_TIPDOC == '2' // Gerar ? ( 1=NF / 2=SD3 (Mov.Internas) )
				lOk := .f.
				DbSelectArea("VBH")
				DbSetOrder(2) // VBH_FILIAL + VBH_CODVDV + VBH_SAIENT
				If DbSeek( xFilial("VBH") + VDV->VDV_CODIGO + "1" ) // 1=Entrada
					lOk := .t.
					While !Eof() .and. VBH->VBH_FILIAL + VBH->VBH_CODVDV + VBH->VBH_SAIENT == xFilial("VBH") + VDV->VDV_CODIGO + "1" // 1=Entrada
						SD3->(DbSetOrder(2))
						SD3->(DbSeek(xFilial("SD3")+VBH->VBH_DOCSD3))
						SB1->(DbSetOrder(1))
						SB1->(DbSeek(xFilial("SB1")+VBH->VBH_CODSB1))
						SB2->(DbSetOrder(1))
						SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+SD3->D3_LOCAL))
						nSaldoSB2 := SALDOSB2()
						If nSaldoSB2 < SD3->D3_QUANT
							MsgStop(STR0094+cPulaLinha+cPulaLinha+;
									SB1->B1_GRUPO+" "+Alltrim(SB1->B1_CODITE)+" - "+left(SB1->B1_DESC,20)+cPulaLinha+;
									STR0032+": "+Transform(SD3->D3_QUANT,cPictQtd)+cPulaLinha+;
									STR0101+": "+Transform(nSaldoSB2,cPictQtd),STR0025) // Impossivel cancelar movimentacao. Item com saldo insuficiente! / Qtde: / Saldo: / Atencao 
							lOk := .f.
							DbSelectArea("VBH")
							Exit
						EndIf
						DbSelectArea("VBH")
						DbSkip()
					EndDo
				EndIf
			EndIf
		EndIf
		//
		If lOk // OK - Perguntar ao usuario se pode Cancelar o Movimento de NF ou SD3
			//
			cMsg := X3CBOXDESC("VDV_AGRDES",aVDV[oLboxVDV:nAt,2])
			//
			cMsg += cPulaLinha // Pula linha
			If !lVDV_TIPDOC .or. VDV->VDV_TIPDOC <> '2' // Gerar ? ( 1=NF / 2=SD3 (Mov.Internas) )
				cMsg += cPulaLinha // Pula linha
				cMsg += "  - "+STR0050+": "+aVDV[oLboxVDV:nAt,08]+" ( "+STR0003+" )"				// NF Saida - ( Equipamento )
				If lVDV_SNUMNP .and. !Empty(VDV->VDV_SNUMNP)
					cMsg += cPulaLinha // Pula linha
					cMsg += "  - "+STR0050+": "+VDV->VDV_SNUMNP+"-"+VDV->VDV_SSERNP+" ( "+STR0062+" )"	// NF Saida - ( Peça )
				EndIf
				cMsg += cPulaLinha // Pula linha
				cMsg += cPulaLinha // Pula linha
				cMsg += "  - "+STR0051+": "+aVDV[oLboxVDV:nAt,10]+" ( "+STR0003+" )"				// NF Entrada - ( Equipamento )
				If lVDV_ENUMNP .and. !Empty(VDV->VDV_ENUMNP)
					cMsg += cPulaLinha // Pula linha
					cMsg += "  - "+STR0051+": "+VDV->VDV_ENUMNP+"-"+VDV->VDV_ESERNP+" ( "+STR0062+" )"	// NF Entrada - ( Peça )
				EndIf
			Else // Mov.Internas ( SD3 )
				cMsg += cPulaLinha // Pula linha
				cMsg += "  - "+STR0095	// Mov.Interna Saida
				cMsg += cPulaLinha // Pula linha
				cMsg += "  - "+STR0096	// Mov.Interna Entrada
			EndIf
			//
			If MsgYesNo(STR0056+cPulaLinha+cPulaLinha+cMsg,STR0025) // Confirma o CANCELAMENTO? / Atencao
				lRet := .t.
			EndIf
			//
		EndIf
		//
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VX040CHASSI ³ Autor ³ Andre Luis Almeida             ³ Data ³ 19/05/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao da digitacao do Chassi                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX040CHASSI(nLinha,cTp)
Local lRet := .t.
Local ni   := 0
If VX0400011_VerificaMovimentacaoValida(MV_PAR07)
	lRet := .f.
	Help("",1,"EXICHASSI") // Existe CHASSI
Else
	For ni := 1 to len(aAMS)
		If ( cTp == "I" .or. ni <> nLinha ) .and. Alltrim(aAMS[ni,2]) == Alltrim(MV_PAR07)
			lRet := .f.
			Help("",1,"EXICHASSI") // Existe CHASSI
			Exit
		EndIf
	Next
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VX040MARMD  ³ Autor ³ Andre Luis Almeida             ³ Data ³ 19/05/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao da Marca/Modelo - Preenche o Grp.Tributacao e NCM            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX040MARMD(cTp,nTp)
Local lRet := .f.
M->VV1_CODMAR := MV_PAR01 // variavel utilizada no filtro do SXB do Modelo VV2
Do Case 
	Case nTp == 1 // Marca
		VE1->(DbSetOrder(1))
		If Empty(MV_PAR01) .or. VE1->(DbSeek(xFilial("VE1")+MV_PAR01))
			VV2->(DbSetOrder(1))
			VV2->(DbSeek(xFilial("VV2")+MV_PAR01))
			lRet := .t.
			If !Empty(MV_PAR02) .and. !VV2->(DbSeek(xFilial("VV2")+MV_PAR01+MV_PAR02))
				MV_PAR02 := space(TamSX3("VV2_MODVEI")[1])
				MV_PAR03 := space(TamSX3("VV1_CORVEI")[1])
			EndIf
		EndIf
	Case nTp == 2 // Modelo
		VV2->(DbSetOrder(1))
		If Empty(MV_PAR02) .or. VV2->(DbSeek(xFilial("VV2")+MV_PAR01+MV_PAR02))
			lRet := .t.
		EndIf
	Case nTp == 3 // Cor
		VVC->(DbSetOrder(1))
		If Empty(MV_PAR03) .or. VVC->(DbSeek(xFilial("VVC")+MV_PAR01+MV_PAR03))
			lRet := .t.
		EndIf
EndCase
If !Empty(MV_PAR01) .and. !Empty(MV_PAR02)
	If cTp == "I" .or. ( "[" + cMarMod + "]" ) <> ( "[" + MV_PAR01 + MV_PAR02 + "]" )
		VV2->(DbSetOrder(1))
		If VV2->(DbSeek(xFilial("VV2")+MV_PAR01+MV_PAR02))
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+VV2->VV2_PRODUT))
				If !Empty(SB1->B1_GRTRIB)
					MV_PAR10 := SB1->B1_GRTRIB // Grp.Tributacao Padrao para o Modelo
				EndIf
				If !Empty(SB1->B1_POSIPI)
					MV_PAR11 := SB1->B1_POSIPI // NCM Padrao para o Modelo
				EndIf
			EndIf
		EndIf
		cMarMod := ( MV_PAR01 + MV_PAR02 )
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ADD_AMS  ³ Autor ³ Andre Luis Almeida             ³ Data ³ 21/07/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Adiciona linha em branco no vetor aAMS                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ADD_AMS(lSelect,cCodMar,cModVei,cCorVei)
aadd(aAMS,{ lSelect , ;															// 01
			"" , ;																// 02
			"" , ;																// 03
			0 , ;																// 04
			0 , ;																// 05
			"" , ;																// 06
			"" , ;																// 07
			cCodMar , ;															// 08
			cModVei , ;															// 09
			0 , ;																// 10
			"0" , ;																// 11
			"" , ;																// 12
			"2" , ;																// 13
			"" , ;																// 14
			"" , ;																// 15
			"" , ;																// 16
			cCorVei , ;															// 17
			space(TamSX3("B1_CC")[1]) , ;										// 18
			space(TamSX3("B1_CONTA")[1]) , ;									// 19
			space(TamSX3("B1_ITEMCC")[1]) , ;									// 20
			space(TamSX3("B1_CLVL")[1]) })										// 21
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ADD_ITE  ³ Autor ³ Andre Luis Almeida             ³ Data ³ 25/01/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Adiciona linha em branco no vetor aITE                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ADD_ITE()
aAdd(aITE,{ .f. , ;																// 01
			space(TamSX3("B1_GRUPO")[1]) , ;									// 02
			space(TamSX3("B1_CODITE")[1]) , ;									// 03
			"" , ;																// 04
			0 , ;																// 05
			0 , ;																// 06
			0 , ;																// 07
			space(TamSX3("F4_CODIGO")[1]) , ;									// 08
			space(TamSX3("B1_CC")[1]) , ;										// 09
			space(TamSX3("B1_CONTA")[1]) , ;									// 10
			space(TamSX3("B1_ITEMCC")[1]) , ;									// 11
			space(TamSX3("B1_CLVL")[1]) })										// 12
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXX040SD3   ³ Autor ³ Andre Luis Almeida             ³ Data ³ 05/02/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera SD3 ( Mov.Internas ) para Agrega/Desagrega                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXX040SD3( cSaiEnt , cTipMov , cCodVDV , aSB1SD3 )
Local lRet          := .t.
Local ni            := 0
Local aItem         := {}
Local cD3_DOC       := ""
Local cD3_TM        := ""
Local nCusto        := 0
Local cCC           := ""
Local cConta        := ""
Local cItemCC       := ""
Local cClVl         := ""
Local cLocPad       := ""
Private lMsHelpAuto := .t. // se .t. direciona as mensagens de help
Private lMsErroAuto := .f. // necessario a criacao
Default cSaiEnt     := ""
Default cTipMov     := "1"
Default cCodVDV     := VDV->VDV_CODIGO // VDV posicionado
Default aSB1SD3     := {}
//
If cSaiEnt == "1" // Tipo Movimentacao de Entrada - Agrega/Desagrega
	cD3_TM := GetNewPar("MV_MIL0114","") // MV_MIL0114
	If Empty(cD3_TM)
		cD3_TM := GetMv("MV_ENTRADA")    // MV_ENTRADA
	EndIf
Else // cSaiEnt == "2" // Tipo Movimentacao de Saida - Agrega/Desagrega
	cD3_TM := GetNewPar("MV_MIL0115","") // MV_MIL0115
	If Empty(cD3_TM)
		cD3_TM := GetMv("MV_SAIDA")      // MV_SAIDA
	EndIf
EndIf
//
SB1->(DbSetOrder(1))
SB2->(DbSetOrder(1))	
For ni := 1 to len(aSB1SD3)
	//
	cD3_DOC  := Criavar("D3_DOC")
	cD3_DOC	:= IIf(Empty(cD3_DOC),NextNumero("SD3",2,"D3_DOC",.T.),cD3_DOC)
	cD3_DOC	:= A261RetINV(cD3_DOC)
	//
	SB1->( DbSeek( xFilial("SB1") + aSB1SD3[ni,1] ) )
	cLocPad := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
	nCusto  := aSB1SD3[ni,3] // Custo Total
	If nCusto == 0
		SB2->( DbSeek( xFilial("SB2") + SB1->B1_COD + cLocPad ) )
		nCusto := ( SB2->B2_CM1 * aSB1SD3[ni,2] ) // Custo Total ( Unitario * Qtde )
	EndIf
	cCC     := IIf(!Empty(aSB1SD3[ni,4]),aSB1SD3[ni,4],SB1->B1_CC)
	cConta  := IIf(!Empty(aSB1SD3[ni,5]),aSB1SD3[ni,5],SB1->B1_CONTA)
	cItemCC := IIf(!Empty(aSB1SD3[ni,6]),aSB1SD3[ni,6],SB1->B1_ITEMCC)
	cClVl   := IIf(!Empty(aSB1SD3[ni,7]),aSB1SD3[ni,7],SB1->B1_CLVL)
	//
	aItem := {}
	aadd(aItem,{"D3_DOC"    , cD3_DOC        , NIL })
	aadd(aItem,{"D3_TM"     , cD3_TM         , NIL })
	aadd(aItem,{"D3_COD"    , SB1->B1_COD    , NIL })
	aadd(aItem,{"D3_UM"     , SB1->B1_UM     , NIL })
	aadd(aItem,{"D3_QUANT"  , aSB1SD3[ni,2]  , NIL })
	aadd(aItem,{"D3_LOCAL"  , cLocPad        , NIL })
	aadd(aItem,{"D3_CC"     , cCC            , NIL })
	aadd(aItem,{"D3_CONTA"  , cConta         , NIL })
	aadd(aItem,{"D3_ITEMCTA", cItemCC        , NIL })
	aadd(aItem,{"D3_CLVL"   , cClVl          , NIL })
	aadd(aItem,{"D3_EMISSAO", dDataBase      , NIL })
	aadd(aItem,{"D3_CUSTO1" , nCusto         , NIL })
	lMsHelpAuto := .t.
	lMsErroAuto := .f.
	MSExecAuto({|x| MATA240(x)},aItem)
	If lMsErroAuto 
		lRet := .f.
		Exit
	EndIf
	//
	DbSelectArea("VBH")
	RecLock("VBH",.t.)
		VBH->VBH_FILIAL := xFilial("VBH")
		VBH->VBH_CODIGO := GetSXENum("VBH","VBH_CODIGO") // Codigo
		VBH->VBH_CODVDV := cCodVDV
		VBH->VBH_DOCSD3 := SD3->D3_DOC
		VBH->VBH_NUMSEQ := SD3->D3_NUMSEQ
		VBH->VBH_SAIENT := cSaiEnt
		VBH->VBH_TIPMOV := cTipMov
		VBH->VBH_CODSB1 := SB1->B1_COD
		VBH->VBH_CC     := cCC
		VBH->VBH_CONTA  := cConta
		VBH->VBH_ITEMCT := cItemCC
		VBH->VBH_CLVL   := cClVl
	MsUnLock()
	ConfirmSX8()
	//
Next
//
Return lRet

/*/{Protheus.doc} VX0400011_VerificaMovimentacaoValida
Verifica se o Veiculo/Maquina ja possui Movimentações Validas/Devolvidas

@author Andre Luis Almeida
@since 28/07/2020
@version undefined
@type function
/*/
Static Function VX0400011_VerificaMovimentacaoValida(cChassi)
Local lRet     := .f.
Local aQUltMov := FM_VEIUMOV( cChassi , , )
If len(aQUltMov) > 0
	lRet := .t. // Possui Movimentacoes Validas/Devolvidas
EndIf
Return lRet
