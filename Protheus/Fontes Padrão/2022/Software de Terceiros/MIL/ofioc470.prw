#Include "PROTHEUS.CH"
#Include "OFIOC470.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWBROWSE.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOTVS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OFIOC470 บ Autor ณ Andre Luis Almeida บ Data ณ  28/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Consulta de Pecas (Balcao/Oficina)                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Balcao / Oficina                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOC470()
Local   aObjects     := {} , aInfo := {}, aPos := {}
Local   aSizeHalf    := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local   aFilAtu      := FWArrFilAtu()
Local   oTecData     := TecData():New()
Local   i            := 0

Private cPrefBAL     := Alltrim(GetNewPar("MV_PREFBAL","BAL")) // Prefixo de Origem ( F2_PREFORI )
Private cPrefOFI     := Alltrim(GetNewPar("MV_PREFOFI","OFI")) // Prefixo de Origem ( F2_PREFORI )
Private aPMVDataSai  := {} // Prazo Medio de venda
Private aPMVDataEnt  := {} // Prazo Medio de venda
Private nPilha       := 0
Private cCadastro    := STR0001 // Consulta de Pecas ( Balcao + Oficina )
Private aNewBotA     := {{"FILTRO" ,{|| FS_FILTRO(.t.,".t.") },STR0023},{"ANALITICO",{|| FS_TPTT() },STR0049},{"BMPGROUP",{|| FS_VENDED() },STR0050},{"GRAF2D",{|| FS_GRAFIC() },STR0051}} // Filtro Alterar / Oficina - Tipo de Publico / Tipo de Tempo / Ranking Vendedor / Graficos
Private aNewBotV1    := {{"FILTRO" ,{|| FS_FILTRO(.f.,".f.") },STR0023},{"ANALITICO",{|| FS_TPTT() },STR0049},{"BMPGROUP",{|| FS_VENDED() },STR0050},{"GRAF2D",{|| FS_GRAFIC() },STR0051}} // Filtro Visualizar / Oficina - Tipo de Publico / Tipo de Tempo / Ranking Vendedor / Graficos
Private aNewBotV2    := {{"FILTRO" ,{|| FS_FILTRO(.f.,".f.") },STR0023},{"ANALITICO",{|| FS_TPTT() },STR0049},{"BMPGROUP",{|| FS_VENDED() },STR0050}} // Filtro Visualizar / Oficina - Tipo de Publico / Tipo de Tempo / Ranking Vendedor
Private aNewBotV3    := {{"FILTRO" ,{|| FS_FILTRO(.f.,".f.") },STR0023}} // Filtro Visualizar
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ LISTBOX - Vetores                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private aVetFilT := {} // Filiais - Total
Private aVetFilB := {} // Filiais - Balcao
Private aVetFilO := {} // Filiais - Oficina

Private aVetDiaT := {} // Dias - Total
Private aVetDiaB := {} // Dias - Balcao
Private aVetDiaO := {} // Dias - Oficina

Private aVetVenT := {} // Vendedores - Total
Private aVetVenB := {} // Vendedores - Balcao
Private aVetVenO := {} // Vendedores - Oficina

Private aVetMarT := {} // Marcas - Total
Private aVetMarB := {} // Marcas - Balcao
Private aVetMarO := {} // Marcas - Oficina

Private aVetGrpT := {} // Grupos - Total
Private aVetGrpB := {} // Grupos - Balcao
Private aVetGrpO := {} // Grupos - Oficina

Private aVetIteT := {} // Itens - Total
Private aVetIteB := {} // Itens - Balcao
Private aVetIteO := {} // Itens - Oficina

Private aVetAnaB := {} // Analitico - Balcao (Orcamento)
Private aVetAnaO := {} // Analitico - Oficina (Ordem de Servico)

Private aVetTPTT := {} // Oficina - ( Tipo de Publico / Tipo de Tempo )
Private aVetVEND := {} // Ranking Vendedores

/////////////////////////
// Colunas dos Vetores //
/////////////////////////
// 01 - Tipo ( Filial / Dia / Grupo / Item / Orcamento/OS / TipoPublico/TipoTempo )
// 02 - Descricao
// 03 - Vlr Venda
// 04 - Vlr Produtos
// 05 - ICMS D/C
// 06 - ICMS ST
// 07 - PIS
// 08 - Cofins
// 09 - Ressarc ICMS ST
// 10 - Ressarc ICMS OP
// 11 - ICMS Comple.
// 12 - ICMS Difal
// 13 - Desconto
// 14 - Frete + Desp
// 15 - Vlr Liquido
// 16 - Custo
// 17 - Lucro Bruto

Private aNFsDev  := {} // Notas Fiscais que serao pesquisadas as devolucoes respectivas

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ FILTRO - Parametros                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private aFiltro  := {}
aAdd(aFiltro,( ( dDataBase - day(dDataBase) ) + 1 ))   // 01 - Data Inical
aAdd(aFiltro, dDataBase )                              // 02 - Data Final
aAdd(aFiltro, space(TamSx3("VAM_REGIAO")[1]) )         // 03 - Regiao Cliente
aAdd(aFiltro, space(TamSx3("A1_PESSOA")[1]) )          // 04 - Pessoa
aAdd(aFiltro, space(TamSx3("A1_TIPO")[1]) )            // 05 - Tipo
aAdd(aFiltro, space(TamSx3("A1_TIPOCLI")[1]) )         // 06 - Tipo Cliente
aAdd(aFiltro, space(TamSx3("VZN_TIPO")[1]) )           // 07 - Tipo de Negocio Cliente
aAdd(aFiltro, space(TamSx3("A1_COD")[1]) )             // 08 - Codigo Cliente
aAdd(aFiltro, space(TamSx3("A1_LOJA")[1]) )            // 09 - Loja Cliente
aAdd(aFiltro, space(255) )                             // 10 - Grupo do Item
aAdd(aFiltro, space(TamSx3("B1_CODITE")[1]) )          // 11 - Codigo do Item

If(oTecData:VeOutrosVendedores())
	aAdd(aFiltro, space(TamSx3("F2_VEND1")[1]) )       // 12 - Vendedor
Else
	aAdd(aFiltro, oTecData:cCodVendedor)
EndIf


aAdd(aFiltro, STR0020 )                                // 13 - Devolucoes - nao considerar
aAdd(aFiltro, "" )                                     // 14 - Filial
aAdd(aFiltro, "T" )                                    // 15 - Total/Balcao/Oficina
aAdd(aFiltro, "" )                                     // 16 - Vendedor
aAdd(aFiltro, "" )                                     // 17 - Marca
aAdd(aFiltro, "" )                                     // 18 - Dia
aAdd(aFiltro, "" )                                     // 19 - Grupo
aAdd(aFiltro, "" )                                     // 20 - Item
aAdd(aFiltro, "FIL" )                                  // 21 - Tela Atual

If(oTecData:VeOutrasFiliais())
	aAdd(aFiltro, space(100) )                         // 22 - Filiais desejadas ( contido )
Else
	aAdd(aFiltro, xFilial('SD2') )                     // 22 - Filiais desejadas ( contido )
EndIf

aAdd(aFiltro, 0)                                       // 23 - % de despesas variaveis de pe็as
aAdd(aFiltro, 'N')                                     // 24 - calcularแ PMV - Lento
aAdd(aFiltro, "")                                      // 25 - Grupo Considerar
aAdd(aFiltro, "")                                      // 26 - Grupo Nใo Considerar

Private aSM0EMP := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Private aSM0TOT := FWLoadSM0()

Private oFilHelp := DMS_FilialHelper():New()
Private aSM0 := oFilHelp:GetAllFilEmpresa(.t.)

Private cFiltGrupo := ""
Private cFiltGrNAO := ""

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Total
aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Balcao
aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Oficina

aPos := MsObjSize( aInfo, aObjects )

If FS_FILTRO(.f.,".t.") // Levantar Pecas por Filiais

	DEFINE MSDIALOG oConPecFil FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (cCadastro+" - "+STR0002) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Filiais
	oConPecFil:lEscClose := .F.

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oConPecFil,.F.)
	oFWLayer:AddLine('LINE_TOP',30,.F.)
	oFWLayer:AddLine('LINE_MIDDLE',30,.F.)
	oFWLayer:AddLine('LINE_BOTTOM',30,.F.)
	oWIN_TOP := oFWLayer:GetLinePanel('LINE_TOP')
	oWIN_MID := oFWLayer:GetLinePanel('LINE_MIDDLE')
	oWIN_BOT := oFWLayer:GetLinePanel('LINE_BOTTOM')

//Configura็๕es dos campos da tela *Todos os grids utilizใo esse vetor
//{Descri็ใo,Tipo,Tamanho,Picture,Posi็ใo}
	aBrowse := {}
	aADD(aBrowse, {" "    ,"C", 30,"",1})
	aADD(aBrowse, {STR0024,"N", 10,"",2})  // Vlr Venda
	aADD(aBrowse, {STR0025,"N", 10,"",3})  // % Venda
	aADD(aBrowse, {STR0056,"N", 10,"",4})  // Vlr Produtos
	aADD(aBrowse, {STR0057,"N", 10,"",5})  // ICMS OpProp
	aADD(aBrowse, {STR0058,"N", 10,"",6})  // ICMS ST
	aADD(aBrowse, {STR0059,"N", 10,"",7})  // PIS
	aADD(aBrowse, {STR0060,"N", 10,"",8})  // COFINS
	aADD(aBrowse, {STR0061,"N", 10,"",9})  // ICMS ST(Ress)
	aADD(aBrowse, {STR0062,"N", 10,"",10}) // ICMS OP(Ress)
	aADD(aBrowse, {STR0080,"N", 10,"",11}) // ICMS Comple.
	aADD(aBrowse, {STR0081,"N", 10,"",12}) // ICMS Difal
	aADD(aBrowse, {STR0027,"N", 10,"",13}) // Desconto
	aADD(aBrowse, {STR0026,"N", 10,"",14}) // Frete+Desp
	aADD(aBrowse, {STR0028,"N", 10,"",15}) // Vlr Liquido
	aADD(aBrowse, {STR0029,"N", 10,"",16}) // Custo
	aADD(aBrowse, {STR0030,"N", 10,"",17}) // Lucro Bruto
	aADD(aBrowse, {STR0031,"N", 10,"",18}) // % Lucro
	aADD(aBrowse, {STR0063,"N", 10,"",19}) // % Lucro Liq.
	aADD(aBrowse, {STR0064,"N", 10,"",20}) // Desp. Variแvel
	aADD(aBrowse, {STR0065,"N", 10,"",21}) // Res. Final
	aADD(aBrowse, {STR0067,"N", 10,"",22}) // PMV
	aADD(aBrowse, {STR0071,"N", 10,"",23}) // % Resultado

	////////////////////////////////
	// TOTAL ( BALCAO + OFICINA ) //
	////////////////////////////////
	aTelaTot := {}
	For i := 1 to Len(aVetFilt)
		aAdd(aTelaTot,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetFilT[i,01])+IIf(!Empty(aVetFilT[i,02])," - "+aVetFilT[i,02],"") ,; //Filial
			Transform(aVetFilT[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetFilT[i,03]/aVetFilT[1,03])*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetFilT[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetFilT[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetFilT[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetFilT[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetFilT[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetFilT[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetFilT[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetFilT[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetFilT[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetFilT[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetFilT[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetFilT[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetFilT[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetFilT[i]) - OC47DespCompra(aVetFilT[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetFilT[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetFilT[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetFilT[i],"FatLiq"), OC47DespCompra(aVetFilT[i]), aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetFilT[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( 'Todos', aVetFilT, i ),; //PMV
			Transform(OC47PercResult( aVetFilT[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseTot := FWBrowse():New()
	oBrowseTot:SetOwner(oWIN_TOP)
	oBrowseTot:SetProfileID("T")
	oBrowseTot:SetDataArray()
		//oBrowseTot:SetDescription("Filial")
	oBrowseTot:SetColumns(MontCol("oBrowseTot",aBrowse,STR0032))
	oBrowseTot:SetArray(aTelaTot)
	oBrowseTot:Activate() // Ativa็ใo do Browse
	oBrowseTot:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseTot:SetDoubleClick( { || FS_VNDE(aVetFilT[oBrowseTot:At(),01],"T",oBrowseTot:At(),Alltrim(aVetFilT[oBrowseTot:At(),01])+IIf(!Empty(aVetFilT[oBrowseTot:At(),02])," - "+Alltrim(aVetFilT[oBrowseTot:At(),02]),"")) } )
	oBrowseTot:Refresh()
	oBrowseTot:GoTop()

	////////////////////////////////
	// BALCAO                     //
	////////////////////////////////
	aTelaBal := {}
	For i := 1 to Len(aVetFilB)
		aAdd(aTelaBal,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetFilB[i,01])+IIf(!Empty(aVetFilB[i,02])," - "+aVetFilB[i,02],"") ,; //Filial
			Transform(aVetFilB[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetFilB[i,03]/IIf(i==1,aVetFilB[1,03],aVetFilB[1,03]))*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetFilB[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetFilB[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetFilB[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetFilB[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetFilB[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetFilB[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetFilB[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetFilB[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetFilB[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetFilB[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetFilB[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetFilB[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetFilB[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetFilB[i]) - OC47DespCompra(aVetFilB[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetFilB[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetFilB[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetFilB[i],"FatLiq"), OC47DespCompra(aVetFilB[i]), aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetFilB[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( cPrefBAL, aVetFilB, i ),; //PMV
			Transform(OC47PercResult( aVetFilB[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseBal := FWBrowse():New()
	oBrowseBal:SetOwner(oWIN_MID)
	oBrowseBal:SetDataArray()
	oBrowseBal:SetProfileID("B")
		//oBrowseBal:SetDescription("Balcao")
	oBrowseBal:SetColumns(MontCol("oBrowseBal",aBrowse,STR0033))
	oBrowseBal:SetArray(aTelaBal)
	oBrowseBal:Activate() // Ativa็ใo do Browse
	oBrowseBal:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseBal:SetDoubleClick( { || FS_VNDE(aVetFilB[oBrowseBal:At(),01],"B",oBrowseBal:At(),Alltrim(aVetFilB[oBrowseBal:At(),01])+IIf(!Empty(aVetFilB[oBrowseBal:At(),02])," - "+Alltrim(aVetFilB[oBrowseBal:At(),02]),"")) } )
	oBrowseBal:Refresh()
	oBrowseBal:GoTop()

	////////////////////////////////
	// OFICINA                    //
	////////////////////////////////
	aTelaOfi := {}
	For i := 1 to Len(aVetFilO)
		aAdd(aTelaOfi,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetFilO[i,01])+IIf(!Empty(aVetFilO[i,02])," - "+aVetFilO[i,02],"") ,; //Filial
			Transform(aVetFilO[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetFilO[i,03]/IIf(i==1,aVetFilO[1,03],aVetFilO[1,03]))*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetFilO[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetFilO[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetFilO[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetFilO[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetFilO[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetFilO[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetFilO[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetFilO[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetFilO[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetFilO[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetFilO[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetFilO[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetFilO[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetFilO[i]) - OC47DespCompra(aVetFilO[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetFilO[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetFilO[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetFilO[i],"FatLiq") , OC47DespCompra(aVetFilO[i]), aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetFilO[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( cPrefOFI, aVetFilO, i ),; //PMV
			Transform(OC47PercResult( aVetFilO[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseOfi := FWBrowse():New()
	oBrowseOfi:SetOwner(oWIN_BOT)
	oBrowseOfi:SetProfileID("O")
	oBrowseOfi:SetDataArray()
	//oBrowseOfi:SetDescription("Oficina")
	oBrowseOfi:SetColumns(MontCol("oBrowseOfi",aBrowse,STR0034))
	oBrowseOfi:SetArray(aTelaOfi)
	oBrowseOfi:Activate() // Ativa็ใo do Browse
	oBrowseOfi:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseOfi:SetDoubleClick( { || FS_VNDE(aVetFilO[oBrowseOfi:At(),01],"O",oBrowseOfi:At(),Alltrim(aVetFilO[oBrowseOfi:At(),01])+IIf(!Empty(aVetFilO[oBrowseOfi:At(),02])," - "+Alltrim(aVetFilO[oBrowseOfi:At(),02]),"")) } )
	oBrowseOfi:Refresh()
	oBrowseOfi:GoTop()

	ACTIVATE MSDIALOG oConPecFil ON INIT EnchoiceBar(oConPecFil,{ || oConPecFil:End() }, { || oConPecFil:End() },,aNewBotA)
	OC47RetPilha()
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑ Function  OC47Pmv      Autor ณ Vinicius Gati      บ Data ณ  31/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑ Descricao ณ Calcula o PMV e retorna o valor                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OC47Pmv(cGrid, aData, nAt)
	Local oFiltro    := Nil
	Local oPMV       := Nil
	Local aFiltros   := Nil
	Local cFiltroEst := Nil

	If aFiltro[24] == STR0069
		// As notas que estใo nos arrays jแ foram filtradas na pr๓pria tela
		oPMV       := Mil_PMV():New(aPMVDataEnt[nPilha], aPMVDataSai[nPilha])
		aFiltros   := {}
		// Filtro realizado no estagio, primeira coluna do grid, sera usada
		//   pra filtrar as notas e calcular o PMV
		cFiltroEst := aData[nAt, 01]

		If nAt == 1 .AND. !Empty(aData[nAt, 01])
			AADD(aFiltros, {'Quebra', 'Todos'})
		ElseIf !Empty( cFiltroEst )
			AADD(aFiltros, {'Quebra', cFiltroEst})
		EndIf

		If cGrid == 'Balcao'
			AADD(aFiltros, {'F2_PREFORI', cPrefBAL})
		ElseIf cGrid == 'Oficina'
			AADD(aFiltros, {'F2_PREFORI', cPrefOFI})
		Else
			AADD(aFiltros, {'F2_PREFORI', 'Todos'})
		EndIf

		oFiltro := Mil_DataContainer():New(aFiltros)
		nPMV    := oPMV:Calcular(oFiltro)
	Else
		Return " - "
	EndIf
Return FG_AlinVlrs(Transform(nPMV,"@E 99.99"))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ ออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑ Function  OC47PcDspVar Autor ณ Vinicius Gati      บ Data ณ  31/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑ Descricao ณ Percentual de despesa variavel de pe็as                    บฑฑ
ฑฑ descrita na INT do CI 002688                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OC47PcDspVar(nLucro, nDespesa, nPercDespesa)
	Local nRet := 0.0
	nDespesa   := iif( nDespesa < 0, nDespesa*(-1), nDespesa ) // Inverte-se o sinal quando negativo, pois o valor do percentual de despesa sempre ้ positiva, pois abate do resultado.
	nRet       := ( nLucro - nDespesa ) * (nPercDespesa/100.0)
	nRet       := iif(nRet < 0, nRet*(-1), nRet) // inverte-se o sinal caso negativo pois despesa ้ sempre despesa ou seja negativo.
Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ ออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑ Function  OC47ResFinal Autor ณ Vinicius Gati      บ Data ณ  31/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑ Descricao ณ Resultado final que consiste no valor da despesa variavel  บฑฑ
ฑฑ sendo removida do lucro bruto de venda das pe็as                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OC47ResFinal(aData, nPercDespesa)
	nLucroBruto  := OC47VlrLucro(aData) - OC47DespCompra(aData)
	nDespesasVar := OC47PcDspVar( OC47VlrLucro(aData,"FatLiq"), OC47DespCompra(aData), nPercDespesa )
Return nLucroBruto - nDespesasVar


// As fun็๕es a seguir foram feitas seguindo recomenda็ใo do Adriano(Maqnelson)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ ออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑ Function  OC47MrgLiq   Autor ณ Vinicius Gati      บ Data ณ  13/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑ Descricao ณ Calcula margem da venda liquida de acordo com Adriano      บฑฑ
ฑฑ Maqnelson                                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OC47MrgLiq(aRowData)
	Local nMargemLiq := OC47VlrLucro(aRowData) / OC47VlLiqVenda(aRowData) * 100
Return nMargemLiq

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ ออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑ Function  OC47MrgBrut   Autor ณ Vinicius Gati      บ Data ณ  13/05/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑ Descricao ณ Calcula margem bruta de acordo com Adriano Maqnelson       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OC47MrgBrut(aRowData)
	Local nMargemLiq := OC47VlrLucro(aRowData) / aRowData[3] * 100
Return nMargemLiq

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ ออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑ Function  OC47Impostos Autor ณ Vinicius Gati     บ Data ณ  13/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑ Descricao ณ Retorna a soma de todos os impostos da nota                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OC47Impostos(aRowData)
Return aRowData[05] + aRowData[06] + aRowData[07] + aRowData[08] + aRowData[11] + aRowData[12] // ICMS OP / ICMS ST / PIS / COFINS / ICMS Comple. / ICMS Difal

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ ออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑ Function  OC47Custos  Autor ณ Vinicius Gati      บ Data ณ  13/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna a soma de todos os custos   da nota                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OC47Custos(aRowData)
Return aRowData[16] // D1_CUSTO1 E D2_CUSTO1

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ ออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑ Function  OC47Ressar  Autor ณ Vinicius Gati      บ Data ณ  13/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna a soma de todos os ressarcimentos ou retornosda NF บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OC47Ressar(aRowData)
Return aRowData[09] + aRowData[10] // ICMS ST Ress / ICMS OP Ress

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑ Function : OC47VlLiqVenda  Autor: Vinicius Gati      Data:   13/05/14   บฑฑ
ฑฑออออออออออุออออออออออสอออออออฯออออออออออออออออออออสอออออออฯอออออออออออออนฑฑ
ฑฑ Descricao: Retorna o valor liquido da venda                            บฑฑ
ฑฑอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OC47VlLiqVenda(aRowData)
	Local nVlrLiqVenda := (aRowData[03] - OC47Impostos(aRowData)) + OC47Ressar(aRowData) //03 - Vlr Venda
Return nVlrLiqVenda

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑ Function:  OC47VlrLucro   Autor: Vinicius Gati        Data: 13/05/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑ Descricao: Retorna o valor do Lucro                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OC47VlrLucro(aRowData,cFatLiq)
	Local nVlrLucro := 0
	Default cFatLiq := ""
	nVlrLucro := Iif(cFatLiq=="FatLiq",OC47VlLiqVenda(aRowData), OC47VlLiqVenda(aRowData) - OC47Custos(aRowData))
Return nVlrLucro

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑ Function:  OC47DespCompra   Autor: Vinicius Gati     Data:   13/05/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑ Descricao: Retorna o valor do Frete + Despesas extras                  นฑฑ
ฑฑ  (despesas de compra)บฑฑ                                               นฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OC47DespCompra(aRowData)
Return aRowData[14]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑ Function:  OC47PercResult   Autor: Vinicius Gati     Data:   30/03/15  นฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ Percentual do resultado final                                          นฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OC47PercResult(aRowData)
Return ( ( OC47ResFinal(aRowData, aFiltro[23]) ) / aRowData[03] ) * 100

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FILTRO บ Autor ณ Andre Luis Almeida บ Data ณ  28/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Filtra Pecas (Balcao/Oficina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_FILTRO(lRefresh,cModif)
Local oTecData := TecData():New()
Local lRet     := .F.
Local aRet     := {}
Local aParamBox:= {}
Local aPPESSOA := X3CBOXAVET("A1_PESSOA","1")
Local aPTIPO   := X3CBOXAVET("A1_TIPO","1")
Local aDevoluc := {STR0020,STR0021,STR0022} // nao considerar / do periodo / referente as Vendas
Local ni       := 0
Local i        := 0

AADD(aParamBox,{1,STR0007,aFiltro[01],"@D","","",cModif,50,.t.}) // Data Inicial
AADD(aParamBox,{1,STR0008,aFiltro[02],"@D","MV_PAR02>=MV_PAR01","",cModif,50,.t.}) // Data Final
AADD(aParamBox,{1,STR0009,aFiltro[03],"@!",'VAZIO() .or. FG_Seek("VCB","MV_PAR03",1,.f.)',"VCB",cModif,40,.f.}) // Regiao de Atuacao
If cModif == ".t." // Modifica a ParamBox
	AADD(aParamBox,{2,STR0010,aFiltro[04],aPPESSOA,70,"",.f.}) // Pessoa
	AADD(aParamBox,{2,STR0011,aFiltro[05],aPTIPO,70,"",.f.}) // Tipo
Else
	AADD(aParamBox,{1,STR0010,IIf(!Empty(aFiltro[04]),X3CBOXDESC("A1_PESSOA",aFiltro[04]),""),"","","",cModif,70,.f.}) // Pessoa
	AADD(aParamBox,{1,STR0011,IIf(!Empty(aFiltro[05]),X3CBOXDESC("A1_TIPO",aFiltro[05]),""),"","","",cModif,70,.f.}) // Tipo
EndIf
AADD(aParamBox,{1,STR0012,aFiltro[06],"@!",'VAZIO() .or. EXISTCPO("SX5","TC"+MV_PAR06)',"TC",cModif,20,.f.}) // Tipo Cliente
AADD(aParamBox,{1,STR0013,aFiltro[07],"@!",'VAZIO() .or. FG_Seek("VZN","MV_PAR07",1,.f.)',"VZN",cModif,40,.f.}) // Tipo de Necocio Cliente
AADD(aParamBox,{1,STR0014,aFiltro[08],"@!",'VAZIO() .or. FG_Seek("SA1","MV_PAR08",1,.f.)',"SA1",cModif,40,.f.}) // Codigo do Cliente
AADD(aParamBox,{1,STR0015,aFiltro[09],"@!",'',"",cModif,20,.f.}) // Loja do Cliente
AADD(aParamBox,{1,STR0016,aFiltro[10],"@!",'','',cModif,99,.f.}) // Grupo do Item
AADD(aParamBox,{1,STR0017,aFiltro[11],"@!",'VAZIO() .or. FG_POSSB1("MV_PAR11","SB1->B1_CODITE","MV_PAR10")',"SB1",cModif,70,.f.}) // Codigo do Item

cEnabled := If(oTecData:VeOutrosVendedores(), '.T.', '.F.')
AADD(aParamBox,{1,STR0018,aFiltro[12],"@!",'VAZIO() .or. FG_Seek("SA3","MV_PAR12",1,.f.)',"SA3",cEnabled,40,.f.}) // Vendedor

//Combo de devolu็๕es
If cModif == ".t." // Modifica a ParamBox
	AADD(aParamBox, {2, STR0019, aFiltro[13], aDevoluc, 70, "", .F., .T.})
Else
	AADD(aParamBox, {1,STR0019,aFiltro[13],"","","",cModif,70,.f.})
EndIf

cEnabled := If(oTecData:VeOutrasFiliais(), '.T.', '.F.')
AADD(aParamBox,{1,STR0002,aFiltro[22],"@!",'',"",cEnabled,110,.F.}) // Filiais


AADD(aParamBox,{1, STR0066,        0, "@E 99.99", "MV_PAR15 >= 0 .AND. MV_PAR15 < 100", , ".T.", 40, .F.})
AADD(aParamBox,{2, STR0068, STR0070, {STR0069, STR0070}, 30, '.T.', .F.}) // str69 = ~sim e str70 = ~nao
AADD(aParamBox,{1, STR0072, space(100), "@!", "", "", cModif, 99, .F.} ) // "Grupos Considerar"
AADD(aParamBox,{1, STR0079, space(100), "@!", "", "", cModif, 99, .F.} ) // "Grupos Nใo Considerar"

// Ponto de entrada criado para travar a porcentagem de despesas
if ExistBlock("PEOC4701")
	aParamBox := ExecBlock("PEOC4701",.f.,.f., {aParamBox})
EndIf



If ParamBox(aParamBox,STR0023,@aRet,,,,,,,,.f.) // Filtro
	If cModif == ".t." // Modifica a ParamBox
		lRet    := .t.
		aFiltro := {}
		For ni := 1 to 13
			aAdd(aFiltro, aRet[ni] )  // 01 a 13
		Next
		aAdd(aFiltro, "" )          // 14 - Filial
		aAdd(aFiltro, "T" )         // 15 - Total/Balcao/Oficina
		aAdd(aFiltro, "" )          // 16 - Vendedor
		aAdd(aFiltro, "" )          // 17 - Marca
		aAdd(aFiltro, "" )          // 18 - Dia
		aAdd(aFiltro, "" )          // 19 - Grupo
		aAdd(aFiltro, "" )          // 20 - Item
		aAdd(aFiltro, "FIL" )       // 21 - Tela Atual
		aAdd(aFiltro, aRet[14])     // 22 - Filiais
		aAdd(aFiltro, aRet[15])     // 23 - % desp variavel itens
		aAdd(aFiltro, aRet[16])     // 24 - Motra PMV ou nใo
		aAdd(aFiltro, aRet[17])     // 25 - Grupo Considerar
		aAdd(aFiltro, aRet[18])     // 26 - Grupo Nใo Considerar

		// Grupo do Item e Grupos Considerar
		cFiltGrupo := ""
		If !Empty(aFiltro[10]) .Or. !Empty(aFiltro[25])
			cFiltGrupo := Alltrim(aFiltro[10]) + If(!Empty(aFiltro[10]) .And. !Empty(aFiltro[25]), "/", "") + Alltrim(aFiltro[25])
			While AT("/", cFiltGrupo) > 0
				nChar := AT("/", cFiltGrupo)
				cFiltGrupo := Left(cFiltGrupo, nChar - 1) + "','" + Subs(cFiltGrupo, nChar + 1)
			EndDo
			cFiltGrupo := "('" + cFiltGrupo + "')"
		EndIf

		// Grupos Nใo Considerar
		cFiltGrNAO := ""
		If !Empty(aFiltro[26])
			cFiltGrNAO := Alltrim(aFiltro[26])
			While AT("/", cFiltGrNAO) > 0
				nChar := AT("/", cFiltGrNAO)
				cFiltGrNAO := Left(cFiltGrNAO, nChar - 1) + "','" + Subs(cFiltGrNAO, nChar + 1)
			EndDo
			cFiltGrNAO := "('" + cFiltGrNAO + "')"
		EndIf

		FS_MONTAVET("FIL",STR0035)  // Monta Vetores das Filiais
	EndIf
EndIf
If lRefresh .AND. cModif == ".t."
	////////////////////////////////
	// TOTAL ( BALCAO + OFICINA ) //
	////////////////////////////////
	aTelaTot := {}
	For i := 1 to Len(aVetFilt)
		aAdd(aTelaTot,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetFilT[i,01])+IIf(!Empty(aVetFilT[i,02])," - "+aVetFilT[i,02],"") ,; //Filial
			FG_AlinVlrs(Transform(aVetFilT[i,03],"@E 999,999,999.99")) ,; //Vlr Venda
			FG_AlinVlrs(Transform((aVetFilT[i,03]/aVetFilT[1,03])*100,"@E 9999.99")+"%") ,; //% Venda
			FG_AlinVlrs(Transform(aVetFilT[i,04],"@E 999,999,999.99")) ,; //Vlr Produtos
			FG_AlinVlrs(Transform(aVetFilT[i,05],"@E 999,999,999.99")) ,; //ICMS OpProp
			FG_AlinVlrs(Transform(aVetFilT[i,06],"@E 999,999,999.99")) ,; //ICMS ST
			FG_AlinVlrs(Transform(aVetFilT[i,07],"@E 999,999,999.99")) ,; //PIS
			FG_AlinVlrs(Transform(aVetFilT[i,08],"@E 999,999,999.99")) ,; //Filial //Vlr Venda //% Venda //Vlr Produtos //ICMS OpProp //ICMS ST //PIS //COFINS
			FG_AlinVlrs(Transform(aVetFilT[i,09],"@E 999,999,999.99")) ,; //Filial //Vlr Venda //% Venda //Vlr Produtos //ICMS OpProp //ICMS ST //PIS //COFINS //ICMS ST(RESS)
			FG_AlinVlrs(Transform(aVetFilT[i,10],"@E 999,999,999.99")) ,; //ICMS OP(RESS)
			FG_AlinVlrs(Transform(aVetFilT[i,11],"@E 999,999,999.99")) ,; //ICMS Comple.
			FG_AlinVlrs(Transform(aVetFilT[i,12],"@E 999,999,999.99")) ,; //ICMS Difal
			FG_AlinVlrs(Transform(aVetFilT[i,13],"@E 999,999,999.99")) ,; //DESCONTO
			FG_AlinVlrs(Transform(aVetFilT[i,14],"@E 999,999,999.99")) ,; //Frete+Desp
			FG_AlinVlrs(Transform(OC47VlLiqVenda(aVetFilT[i]),"@E 999,999,999.99")) ,; //Vlr Liquido
			FG_AlinVlrs(Transform(aVetFilT[i,16],"@E 999,999,999.99")) ,; //Custo
			FG_AlinVlrs(Transform(OC47VlrLucro(aVetFilT[i]) - OC47DespCompra(aVetFilT[i]),"@E 999,999,999.99")) ,; //Lucro Bruto
			FG_AlinVlrs(Transform(OC47MrgBrut(aVetFilT[i]),"@E 9999.99")+'%'),; //%Lucro
			FG_AlinVlrs(Transform(OC47MrgLiq(aVetFilT[i]),"@E 9999.99")+'%'),; //%Lucro Liq
			FG_AlinVlrs(Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetFilT[i],"FatLiq"), OC47DespCompra(aVetFilT[i]), aFiltro[23]), 0),"@E 999,999,999.99")),; //Desp. Variavel
			FG_AlinVlrs(Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetFilT[i], aFiltro[23]), 0),"@E 999,999,999.99")),; //Res. Final
			OC47Pmv( 'Todos', aVetFilT, i ),; //PMV
			FG_AlinVlrs(Transform(OC47PercResult( aVetFilT[i]), "@E 9999.99") + "%")}) //%Resultado
	Next
	oBrowseTot:SetArray(aTelaTot)
	oBrowseTot:Refresh()
	oBrowseTot:GoTop()
	////////////////////////////////
	// BALCAO                     //
	////////////////////////////////
	aTelaBal := {}
	For i := 1 to Len(aVetFilB)
		aAdd(aTelaBal,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetFilB[i,01])+IIf(!Empty(aVetFilB[i,02])," - "+aVetFilB[i,02],"") ,; //Filial
			FG_AlinVlrs(Transform(aVetFilB[i,03],"@E 999,999,999.99")) ,; //Vlr Venda
			FG_AlinVlrs(Transform((aVetFilB[i,03]/IIf(i==1,aVetFilB[1,03],aVetFilB[1,03]))*100,"@E 9999.99")+"%") ,; //% Venda
			FG_AlinVlrs(Transform(aVetFilB[i,04],"@E 999,999,999.99")) ,; //Vlr Produtos
			FG_AlinVlrs(Transform(aVetFilB[i,05],"@E 999,999,999.99")) ,; //ICMS OpProp
			FG_AlinVlrs(Transform(aVetFilB[i,06],"@E 999,999,999.99")) ,; //ICMS ST
			FG_AlinVlrs(Transform(aVetFilB[i,07],"@E 999,999,999.99")) ,; //PIS
			FG_AlinVlrs(Transform(aVetFilB[i,08],"@E 999,999,999.99")) ,; //COFINS
			FG_AlinVlrs(Transform(aVetFilB[i,09],"@E 999,999,999.99")) ,; //ICMS ST(RESS)
			FG_AlinVlrs(Transform(aVetFilB[i,10],"@E 999,999,999.99")) ,; //ICMS OP(RESS)
			FG_AlinVlrs(Transform(aVetFilB[i,11],"@E 999,999,999.99")) ,; //ICMS Comple.
			FG_AlinVlrs(Transform(aVetFilB[i,12],"@E 999,999,999.99")) ,; //ICMS Difal
			FG_AlinVlrs(Transform(aVetFilB[i,13],"@E 999,999,999.99")) ,; //DESCONTO
			FG_AlinVlrs(Transform(aVetFilB[i,14],"@E 999,999,999.99")) ,; //Frete+Desp
			FG_AlinVlrs(Transform(OC47VlLiqVenda(aVetFilB[i]),"@E 999,999,999.99")) ,; //Vlr Liquido
			FG_AlinVlrs(Transform(aVetFilB[i,16],"@E 999,999,999.99")) ,; //Custo
			FG_AlinVlrs(Transform(OC47VlrLucro(aVetFilB[i]) - OC47DespCompra(aVetFilB[i]),"@E 999,999,999.99")) ,; //Lucro Bruto
			FG_AlinVlrs(Transform(OC47MrgBrut(aVetFilB[i]),"@E 9999.99")+'%'),; //%Lucro
			FG_AlinVlrs(Transform(OC47MrgLiq(aVetFilB[i]),"@E 9999.99")+'%'),; //%Lucro Liq
			FG_AlinVlrs(Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetFilB[i],"FatLiq"), OC47DespCompra(aVetFilB[i]), aFiltro[23]), 0),"@E 999,999,999.99")),; //Desp. Variavel
			FG_AlinVlrs(Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetFilB[i], aFiltro[23]), 0),"@E 999,999,999.99")),; //Res. Final
			OC47Pmv( cPrefBAL, aVetFilB, i ),; //PMV
			FG_AlinVlrs(Transform(OC47PercResult( aVetFilB[i]), "@E 9999.99") + "%")}) //%Resultado
	Next
	oBrowseBal:SetArray(aTelaBal)
	oBrowseBal:Refresh()
	oBrowseBal:GoTop()
	////////////////////////////////
	// OFICINA                    //
	////////////////////////////////
	aTelaOfi := {}
	For i := 1 to Len(aVetFilO)
		aAdd(aTelaOfi,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetFilO[i,01])+IIf(!Empty(aVetFilO[i,02])," - "+aVetFilO[i,02],"") ,; //Filial
			FG_AlinVlrs(Transform(aVetFilO[i,03],"@E 999,999,999.99")) ,; //Vlr Venda
			FG_AlinVlrs(Transform((aVetFilO[i,03]/IIf(i==1,aVetFilO[1,03],aVetFilO[1,03]))*100,"@E 9999.99")+"%") ,; //% Venda
			FG_AlinVlrs(Transform(aVetFilO[i,04],"@E 999,999,999.99")) ,; //Vlr Produtos
			FG_AlinVlrs(Transform(aVetFilO[i,05],"@E 999,999,999.99")) ,; //ICMS OpProp
			FG_AlinVlrs(Transform(aVetFilO[i,06],"@E 999,999,999.99")) ,; //ICMS ST
			FG_AlinVlrs(Transform(aVetFilO[i,07],"@E 999,999,999.99")) ,; //PIS
			FG_AlinVlrs(Transform(aVetFilO[i,08],"@E 999,999,999.99")) ,; //COFINS
			FG_AlinVlrs(Transform(aVetFilO[i,09],"@E 999,999,999.99")) ,; //ICMS ST(RESS)
			FG_AlinVlrs(Transform(aVetFilO[i,10],"@E 999,999,999.99")) ,; //ICMS OP(RESS)
			FG_AlinVlrs(Transform(aVetFilO[i,11],"@E 999,999,999.99")) ,; //ICMS Comple.
			FG_AlinVlrs(Transform(aVetFilO[i,12],"@E 999,999,999.99")) ,; //ICMS Difal
			FG_AlinVlrs(Transform(aVetFilO[i,13],"@E 999,999,999.99")) ,; //DESCONTO
			FG_AlinVlrs(Transform(aVetFilO[i,14],"@E 999,999,999.99")) ,; //Frete+Desp
			FG_AlinVlrs(Transform(OC47VlLiqVenda(aVetFilO[i]),"@E 999,999,999.99")) ,; //Vlr Liquido
			FG_AlinVlrs(Transform(aVetFilO[i,16],"@E 999,999,999.99")) ,; //Custo
			FG_AlinVlrs(Transform(OC47VlrLucro(aVetFilO[i]) - OC47DespCompra(aVetFilO[i]),"@E 999,999,999.99")) ,; //Lucro Bruto
			FG_AlinVlrs(Transform(OC47MrgBrut(aVetFilO[i]),"@E 9999.99")+'%'),; //%Lucro
			FG_AlinVlrs(Transform(OC47MrgLiq(aVetFilO[i]),"@E 9999.99")+'%'),; //%Lucro Liq
			FG_AlinVlrs(Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetFilO[i],"FatLiq") , OC47DespCompra(aVetFilO[i]), aFiltro[23]), 0),"@E 999,999,999.99")),; //Desp. Variavel
			FG_AlinVlrs(Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetFilO[i], aFiltro[23]), 0),"@E 999,999,999.99")),; //Res. Final
			OC47Pmv( cPrefOFI, aVetFilO, i ),; //PMV
			FG_AlinVlrs(Transform(OC47PercResult( aVetFilO[i]), "@E 9999.99") + "%")}) //%Resultado
	Next
	oBrowseOfi:SetArray(aTelaOfi)
	oBrowseOfi:Refresh()
	oBrowseOfi:GoTop()
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_MONTAVET บAutor ณ Andre Luis Almeida บ Dataณ  28/06/11  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Monta vetores (Filiais/Dias/)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MONTAVET(cTipo,cTitTotal)
Local nPos1    := 0
Local nPos2    := 0
Local cQuebra  := ""
Local cQuebra1 := ""
Local nSlvPos1 := 0
Local ni       := 0
Local ny       := 0
Local nDev     := 0
Local cDescri  := "" // Descricao

Local aAux     := {}
Local cQuery   := ""
Local nCont    := 0
Local cBkpFilAnt  := cFilAnt
Local cSQLAlias   := "SQLALIAS"
Local cSQLAlSD1   := "SQLALSD1"
Local oNFHlp      := OC470NFHlp():New()
Local oDevNFHlp   := OC470NFHlp():New()
//
Local cNamSD2     := RetSQLName("SD2")
Local cNamSF2     := RetSQLName("SF2")
Local cNamSD1     := RetSQLName("SD1")
Local cNamSF4     := RetSQLName("SF4")
Local cNamSB1     := RetSQLName("SB1")
Local cNamSBM     := RetSQLName("SBM")
Local cNamSA1     := RetSQLName("SA1")
Local cNamVAM     := RetSQLName("VAM")
Local cNamVZO     := RetSQLName("VZO")
Local cNamVS1     := RetSQLName("VS1")
Local cNamVS3     := RetSQLName("VS3")
Local cNamVOO     := RetSQLName("VOO")
Local cNamVOI     := RetSQLName("VOI")
Local cNamVE1     := RetSQLName("VE1")
//
Local cFilSD2     := ""
Local cFilSD1     := ""
Local cFilSF4     := ""
Local cFilSB1     := ""
Local cFilSBM     := ""
Local cFilSA1     := ""
Local cFilVAM     := ""
Local cFilVZO     := ""
Local cFilVS1     := ""
Local cFilVOO     := ""
Local cFilVOI     := ""
Local cFilSA3     := ""
Local cFilSE1     := ""
Local cFilSE2     := ""
Local cFilVE1     := ""
//
Local cEstEmp     := "" // Estado da Empresa/Filial
Local cEstResST := ""
Local cEstResOP := ""
//Local cGruVei     := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
//Local cGruSrv     := PadR(AllTrim(GetMv("MV_GRUSRV")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
//
Private nVlr03    := 0
Private nVlr04    := 0
Private nVlr05    := 0
Private nVlr06    := 0
Private nVlr07    := 0
Private nVlr08    := 0
Private nVlr09    := 0
Private nVlr10    := 0
Private nVlr11    := 0
Private nVlr12    := 0
Private nVlr13    := 0
Private nVlr14    := 0
Private nVlr15    := 0
Private nVlr16    := 0
Private nVlr17    := 0
//

Default cTipo     := "FIL"
Default cTitTotal := STR0035 // Total Geral

nPilha += 1
AADD(aPMVDataSai, {})
AADD(aPMVDataEnt, {})
Do Case
	Case cTipo == "FIL" // Filiais
		aVetFilT := {}
		aVetFilB := {}
		aVetFilO := {}
		aAdd( aVetFilT , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
		aAdd( aVetFilB , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
		aAdd( aVetFilO , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
	Case cTipo == "VNDE" // Vendedores
		aVetVenT := {}
		aVetVenB := {}
		aVetVenO := {}
		aAdd( aVetVenT , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
		aAdd( aVetVenB , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
		aAdd( aVetVenO , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
	Case cTipo == "MARCA" // Marcas
		aVetMarT := {}
		aVetMarB := {}
		aVetMarO := {}
		aAdd( aVetMarT , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
		aAdd( aVetMarB , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
		aAdd( aVetMarO , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
	Case cTipo == "DIA" // Dias
		aVetDiaT := {}
		aVetDiaB := {}
		aVetDiaO := {}
		aAdd( aVetDiaT , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
		aAdd( aVetDiaB , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
		aAdd( aVetDiaO , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
	Case cTipo == "GRP" // Grupos
		aVetGrpT := {}
		aVetGrpB := {}
		aVetGrpO := {}
		aAdd( aVetGrpT , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
		aAdd( aVetGrpB , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
		aAdd( aVetGrpO , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
	Case cTipo == "ITE" // Itens
		aVetIteT := {}
		aVetIteB := {}
		aVetIteO := {}
		aAdd( aVetIteT , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
		aAdd( aVetIteB , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
		aAdd( aVetIteO , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
	Case cTipo == "ANA" // Analitico
		aVetAnaB := {}
		aVetAnaO := {}
		aAdd( aVetAnaB , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , "" , 0 } )
		aAdd( aVetAnaO , { cTitTotal , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , "" , 0 } )
	Case cTipo == "TPTT" // Oficina - Tipo de Publico / Tipo de Tempo
		aVetTPTT := {}
		aAdd( aVetTPTT , { cTitTotal , cTitTotal , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
	Case cTipo == "VEND" // Ranking Vendedores
		aVetVEND := {}
		aAdd( aVetVEND , { cTitTotal , "9" , 0 , "" } )
EndCase

For nCont := 1 to Len(aSM0TOT)
	//
	If aSM0TOT[nCont,SM0_GRPEMP] <> cEmpAnt // Mesmo Grupo de Empresa - NAO MUDAR cEmpAnt
		Loop
	EndIf
	//
	If Empty(aFiltro[22])
		// Quando Filiais em Branco
		// Pular se nao for da mesma Empresa - Trazer somente as Filiais da Empresa Logada
		If aScan(aSM0EMP,aSM0TOT[nCont,SM0_CODFIL]) == 0
			Loop
		EndIf
	EndIf
	//
	cFilAnt := aSM0TOT[nCont,SM0_CODFIL]
	//
	If !Empty(aFiltro[14]) .and. aFiltro[14]<>cFilAnt
		Loop
	EndIf
	//
	If !Empty(aFiltro[22])
		If !( cFilAnt $ aFiltro[22] ) // Filiais desejadas
			Loop
		EndIf
	EndIf

	aNFsDev := {} // Notas Fiscais que serao pesquisadas as devolucoes respectivas

	cFilSD2 := xFilial("SD2")
	cFilSD1 := xFilial("SD1")
	cFilSF4 := xFilial("SF4")
	cFilSB1 := xFilial("SB1")
	cFilSBM := xFilial("SBM")
	cFilSA1 := xFilial("SA1")
	cFilSE1 := xFilial("SE1")
	cFilSE2 := xFilial("SE2")

	If !Empty(aFiltro[03])
		cFilVAM := xFilial("VAM")
	EndIf
	If !Empty(aFiltro[07])
		cFilVZO := xFilial("VZO")
	EndIf
	If cTipo == "ANA" // Analitico
		cFilVS1 := xFilial("VS1")
		cFilVOO := xFilial("VOO")
	ElseIf cTipo == "TPTT" // Tipo de Tempo
		cFilVOI := xFilial("VOI")
		cFilVOO := xFilial("VOO")
	ElseIf cTipo == "VEND" // Ranking Vendedor
		cFilSA3 := xFilial("SA3")
	ElseIf cTipo == "VNDE" // Vendedores
		cFilSA3 := xFilial("SA3")
	ElseIf cTipo == "MARCA" // MARCA
		cFilVE1 := xFilial("VE1")
	EndIf
	//
	cQuebra1 := ""
	//

	cEstEmp := GetMv("MV_ESTADO")  // Estado da Empresa/Filial
	If GetMv("MV_MIL0025",.T.,) // Verifica a existencia do parametro
	   cEstResST := GetMv("MV_MIL0025") // Estados com Ressarcimento ST
	Endif
	If GetMv("MV_MIL0042",.T.,) // Verifica a existencia do parametro
	   cEstResOP := GetMv("MV_MIL0042") // Estados com Ressarcimento OP
	Endif

	//
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ SQL VENDAS - SELECT ( Filiais / Dias / Grupos / Itens )     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	///////////////////
	// CAMPOS  SQL   //
	///////////////////
	cQuery := "SELECT SD2.D2_LOJA, SD2.D2_ITEM, SD2.D2_CLIENTE, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_FILIAL, SD2.D2_VALBRUT, SF4.F4_SITTRIB , SD2.D2_TOTAL , SD2.D2_COD , SD2.D2_QUANT , "
	cQuery += "SD2.D2_VALICM , SD2.D2_ICMSRET , SD2.D2_VALFRE , SD2.D2_DESPESA , SD2.D2_VALIMP6 , SD2.D2_VALIMP5 , "
	cQuery += "SD2.D2_DESCON , SD2.D2_CUSTO1 , SF2.F2_PREFORI , SF2.F2_EMISSAO , SD2.D2_ICMSCOM , SD2.D2_DIFAL , SA1.A1_EST "
	If aFiltro[13] == STR0022 // Devolucoes referente as Vendas no Periodo ( referente as Vendas )
		cQuery += ", SD2.D2_FILIAL , SD2.D2_DOC , SD2.D2_SERIE "
	EndIf
	Do Case
		Case cTipo == "FIL"
			If aFiltro[13] <> STR0022 // diferente de ( referente as Vendas )
				cQuery += ", SD2.D2_FILIAL "
			EndIf
		Case cTipo == "GRP" // Grupos
			cQuery += ", SD2.D2_GRUPO , SBM.BM_DESC "
		Case cTipo == "ITE" // Itens
			cQuery += ", SD2.D2_GRUPO , SB1.B1_CODITE , SB1.B1_DESC "
		Case cTipo == "ANA" // Analitico
			If aFiltro[13] <> STR0022 // diferente de ( referente as Vendas )
				cQuery += ", SD2.D2_FILIAL , SD2.D2_DOC , SD2.D2_SERIE "
			EndIf
			cQuery += ", VS3.VS3_NUMORC, VS3.VS3_SEQUEN, VS3.VS3_QTDITE, VS1.VS1_NUMORC , VEC_NUMOSV VOO_NUMOSV , VEC_TIPTEM VOO_TIPTEM, VEC.VEC_QTDITE, VEC.VEC_VALBRU "
		Case cTipo == "TPTT" // Oficina - Tipo de Publico / Tipo de Tempo
			If aFiltro[13] <> STR0022 // diferente de ( referente as Vendas )
				cQuery += ", SD2.D2_FILIAL , SD2.D2_DOC , SD2.D2_SERIE "
			EndIf
			cQuery += ", VOI.VOI_SITTPO , VOI.VOI_DESTTE, VEC.VEC_VALBRU , VEC_TIPTEM VOO_TIPTEM "
		Case cTipo == "VEND" // Ranking Vendedores
			cQuery += " , CASE WHEN coalesce(SF2.F2_VEND1, '') = '' then '-' else F2_VEND1 end F2_VEND1 "
		Case cTipo == "VNDE" // Vendedores
			cQuery += " , CASE WHEN coalesce(SF2.F2_VEND1, '') = '' then '-' else F2_VEND1 end F2_VEND1 "
		Case cTipo == "MARCA" // MARCAS
			cQuery += ", COALESCE(VE1.VE1_CODMAR,'-') AS VE1_CODMAR, VE1.VE1_DESMAR "
	EndCase
	///////////////////
	// FROM SD2      //
	///////////////////
	cQuery += "FROM "+cNamSD2+" SD2 "
	///////////////////
	// JOIN SF2      //
	///////////////////
	cQuery += "JOIN "+cNamSF2+" SF2 ON "
	cQuery += "( SF2.F2_FILIAL=SD2.D2_FILIAL AND SF2.F2_DOC=SD2.D2_DOC AND SF2.F2_SERIE=SD2.D2_SERIE AND "
	If cTipo == "TPTT" // Oficina - Tipo de Publico / Tipo de Tempo
		cQuery += "SF2.F2_PREFORI='"+cPrefOFI+"' AND "
	Else
		If aFiltro[15] == "T" // Todos (Balcao/Oficina)
			cQuery += "SF2.F2_PREFORI IN ('"+cPrefBAL+"','"+cPrefOFI+"') AND "
		ElseIf aFiltro[15] == "B" // Balcao
			cQuery += "SF2.F2_PREFORI='"+cPrefBAL+"' AND "
		ElseIf aFiltro[15] == "O" // Oficina
			cQuery += "SF2.F2_PREFORI='"+cPrefOFI+"' AND "
		EndIf
	EndIf
	If !Empty(aFiltro[12]) // Filtra Vendedor
		cQuery += "SF2.F2_VEND1='"+aFiltro[12]+"' AND "
	EndIf
	cQuery += "SF2.D_E_L_E_T_=' ' ) "
	///////////////////
	// JOIN SF4      //
	///////////////////
	cQuery += "JOIN "+cNamSF4+" SF4 ON ( "
	cQuery += "SF4.F4_FILIAL='"+cFilSF4+"' AND "
	cQuery += "SF4.F4_CODIGO=SD2.D2_TES AND SF4.F4_OPEMOV='05' AND SF4.D_E_L_E_T_=' ' ) " // F4_OPEMOV='05' -> Venda
	///////////////////
	// JOIN SBM      //
	///////////////////
	cQuery += "JOIN "+cNamSBM+" SBM ON ( "
	cQuery += "SBM.BM_FILIAL='"+cFilSBM+"' AND "
	cQuery += "SBM.BM_GRUPO=SD2.D2_GRUPO AND SBM.BM_TIPGRU NOT IN ('7','4') AND SBM.D_E_L_E_T_=' ' ) "
	///////////////////
	// JOIN SB1      //
	///////////////////
	cQuery += "JOIN "+cNamSB1+" SB1 ON ( "
	cQuery += "SB1.B1_FILIAL='"+cFilSB1+"' AND "
	cQuery += "SB1.B1_COD=SD2.D2_COD AND SB1.D_E_L_E_T_=' ' ) "
	///////////////////
	// JOIN SA1      //
	///////////////////
	cQuery += "JOIN "+cNamSA1+" SA1 ON ( "
	cQuery += "SA1.A1_FILIAL='"+cFilSA1+"' AND "
	cQuery += "SA1.A1_COD=SF2.F2_CLIENTE AND SA1.A1_LOJA=SF2.F2_LOJA AND "
	If !Empty(aFiltro[04]) // 04 - Pessoa
		cQuery += "SA1.A1_PESSOA='"+aFiltro[04]+"' AND "
	EndIf
	If !Empty(aFiltro[05]) // 05 - Tipo
		cQuery += "SA1.A1_TIPO='"+aFiltro[05]+"' AND "
	EndIf
	If !Empty(aFiltro[06]) // 06 - Tipo Cliente
		cQuery += "SA1.A1_TIPOCLI='"+aFiltro[06]+"' AND "
	EndIf
	cQuery += "SA1.D_E_L_E_T_=' ' ) "
	If !Empty(aFiltro[03]) // 03 - Regiao de Atuacao
		///////////////////
		// LEFT JOIN VAM //
		///////////////////
		cQuery += "LEFT JOIN "+cNamVAM+" VAM ON ( "
		cQuery += "VAM.VAM_FILIAL='"+cFilVAM+"' AND "
		cQuery += "VAM.VAM_IBGE=SA1.A1_IBGE AND VAM.VAM_REGIAO='"+aFiltro[03]+"' AND VAM.D_E_L_E_T_=' ' ) "
	EndIf
	/////////////////////////////////////
	// Filtro                          //
	// 07 - Tipo de Negocio do Cliente //
	/////////////////////////////////////
	If !Empty(aFiltro[07])
		///////////////////
		// JOIN VZO      //
		///////////////////
		cQuery += "JOIN "+cNamVZO+" VZO ON ( "
		cQuery += "VZO.VZO_FILIAL='"+cFilVZO+"' AND "
		cQuery += "VZO.VZO_CLIENT=SF2.F2_CLIENTE AND VZO.VZO_LOJA=SF2.F2_LOJA AND "
		cQuery += "VZO.VZO_TIPO='"+aFiltro[07]+"' AND VZO.D_E_L_E_T_=' ' )"
	EndIf
	If cTipo == "ANA" // Analitico
		///////////////////
		// LEFT JOIN VS1 //
		///////////////////
		cQuery += "LEFT JOIN "+cNamVS1+" VS1 ON VS1.VS1_FILIAL='"+cFilVS1+"' AND SF2.F2_PREFORI='"+cPrefBAL+"'   AND VS1.VS1_NUMNFI=SD2.D2_DOC AND VS1.VS1_SERNFI=SD2.D2_SERIE AND VS1.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN "+cNamVS3+" VS3 ON VS3.VS3_FILIAL='"+cFilVS1+"' AND VS3.VS3_NUMORC = VS1.VS1_NUMORC AND VS3_CODITE = B1_CODITE AND VS3_GRUITE = B1_GRUPO  AND VS3.D_E_L_E_T_ = ' ' "
		///////////////////
		// LEFT JOIN VEC //
		///////////////////
		cQuery += "LEFT JOIN "+RetSQLName("VEC")+" VEC ON VEC_FILIAL='"+xFilial("VEC")+"' AND VEC_NUMNFI = D2_DOC AND VEC_SERNFI = D2_SERIE AND D2_ITEM = VEC_ITENFI AND VEC.D_E_L_E_T_=' ' "
	EndIf
	If cTipo == "TPTT" // Oficina - Tipo de Publico / Tipo de Tempo
		///////////////////
		// LEFT JOIN VEC //
		///////////////////
		cQuery += "LEFT JOIN "+RetSQLName("VEC")+" VEC ON VEC_FILIAL='"+xFilial("VEC")+"' AND VEC_NUMNFI = D2_DOC AND VEC_SERNFI = D2_SERIE AND D2_ITEM = VEC_ITENFI AND VEC.D_E_L_E_T_=' ' "
		cQuery += "LEFT JOIN "+cNamVOI+" VOI ON VOI.VOI_FILIAL='"+cFilVOI+"' AND VOI.VOI_TIPTEM = VEC.VEC_TIPTEM AND VOI.D_E_L_E_T_=' ' "
	EndIf

	///////////////////
	// LEFT JOIN VE1 //
	///////////////////
	cQuery += "LEFT JOIN "+cNamVE1+" VE1 ON ( "
	cQuery += "VE1.VE1_FILIAL='"+cFilVE1+"' AND "
	cQuery += "VE1.VE1_CODMAR=SBM.BM_CODMAR AND VE1.D_E_L_E_T_=' ' ) "

	///////////////////
	// WHERE         //
	///////////////////
	cQuery += "WHERE "
	cQuery += "SD2.D2_FILIAL='"+cFilSD2+"' AND "
	If Empty(aFiltro[18]) // Todas os Dias do Periodo
		cQuery += "SD2.D2_EMISSAO>='"+dtos(aFiltro[01])+"' AND SD2.D2_EMISSAO<='"+dtos(aFiltro[02])+"' AND "
	Else // Dia selecionado
		cQuery += "SD2.D2_EMISSAO='"+dtos(ctod(aFiltro[18]))+"' AND "
	EndIf

	If !Empty(aFiltro[10]) .Or. !Empty(aFiltro[25]) // Grupo do Item do Filtro e Grupo Considerar
		cQuery += "SD2.D2_GRUPO IN "+cFiltGrupo+" AND "
	Else
		If !Empty(aFiltro[19]) // Grupo do Item selecionado
			cQuery += "SD2.D2_GRUPO='"+aFiltro[19]+"' AND "
		EndIf
	EndIf

	If !Empty(aFiltro[26]) // Grupo Nใo Considerar
		cQuery += "SD2.D2_GRUPO NOT IN "+cFiltGrNAO+" AND "
	EndIf

	If !Empty(aFiltro[11]) // Codigo do Item do Filtro
		cQuery += "SB1.B1_CODITE='"+aFiltro[11]+"' AND "
	Else
		If !Empty(aFiltro[20]) // Grupo + Codigo do Item selecionado
			cQuery += "SD2.D2_GRUPO='"+left(aFiltro[20],TamSx3("D2_GRUPO")[1])+"' AND "
			cQuery += "SB1.B1_CODITE='"+substr(aFiltro[20],(TamSx3("D2_GRUPO")[1]+1))+"' AND "
		EndIf
	EndIf

	If !Empty(aFiltro[08]) // Codigo do Cliente
		cQuery += "SD2.D2_CLIENTE='"+aFiltro[08]+"' AND "
	EndIf

	If !Empty(aFiltro[09]) // Loja do Cliente
		cQuery += "SD2.D2_LOJA='"+aFiltro[09]+"' AND "
	EndIf

	If ! Empty(aFiltro[16]) .or. "-" $ aFiltro[16] // Vendedor
		if "-" $ aFiltro[16]
			cQuery += "SF2.F2_VEND1 = '"+space( GetSx3Cache("VAI_CODVEN","X3_TAMANHO") )+"' AND "
		else
			cQuery += "SF2.F2_VEND1 = '"+aFiltro[16]+"' AND "
		endif
	EndIf

	If !Empty(aFiltro[17]) // Marca
		If Alltrim(aFiltro[17]) == "-"
			cQuery += "VE1.VE1_CODMAR IS NULL AND "
		Else
			cQuery += "VE1.VE1_CODMAR = '"+aFiltro[17]+"' AND "
		EndIf
	EndIf

	//Este ponto de entrada deverแ possibilitar a altera็ใo da clausula 'WHERE' no levantamento das vendas.
	if ExistBlock("OFC470FIL")
		cQuery := ExecBlock("OFC470FIL",.f.,.f., {cQuery})
	EndIf

	cQuery += "SD2.D_E_L_E_T_=' ' ORDER BY "
	///////////////////
	// ORDER BY      //
	///////////////////
	Do Case
		Case cTipo == "FIL" // Filiais
			cQuery += "SD2.D2_FILIAL "
		Case cTipo == "DIA" // Dias
			cQuery += "SF2.F2_EMISSAO "
		Case cTipo == "GRP" // Grupos
			cQuery += "SD2.D2_GRUPO "
		Case cTipo == "ITE" // Itens
			cQuery += "SD2.D2_GRUPO , SB1.B1_CODITE "
		Case cTipo == "ANA" // Analitico
			cQuery += "SD2.D2_FILIAL , SD2.D2_DOC , SD2.D2_SERIE , SD2.D2_COD "
		Case cTipo == "TPTT" // Oficina - Tipo de Publico / Tipo de Tempo
			cQuery += "VOI.VOI_SITTPO , VOO_TIPTEM , SD2.D2_DOC , SD2.D2_SERIE , SD2.D2_COD , SD2.D2_FILIAL "
		Case cTipo == "VEND" // Ranking Vendedores
			cQuery += "F2_VEND1 "
		Case cTipo == "VNDE" // Vendedores
			cQuery += "F2_VEND1 "
		Case cTipo == "MARCA" // MARCAS
			cQuery += "VE1.VE1_CODMAR, VE1.VE1_DESMAR "
	EndCase
	//
	cQuebra := ""
	//
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
	While !(cSQLAlias)->(Eof())
		If (cSQLAlias)->( F2_PREFORI ) == cPrefOFI // Oficina
			If cTipo == "TPTT" // utilizam VOO -> Oficina - Tipo de Publico / Tipo de Tempo
				If cQuebra == ( (cSQLAlias)->( D2_DOC ) + (cSQLAlias)->( D2_SERIE ) + (cSQLAlias)->( D2_COD ) + (cSQLAlias)->( D2_ITEM ) + (cSQLAlias)->( D2_FILIAL ) )
					(cSQLAlias)->(dbSkip()) // Desconsiderar quando Fechamento Agrupado ( mesmo ITEM da NF )
					Loop
				Else
					cQuebra := ( (cSQLAlias)->( D2_DOC ) + (cSQLAlias)->( D2_SERIE ) + (cSQLAlias)->( D2_COD ) + (cSQLAlias)->( D2_ITEM ) + (cSQLAlias)->( D2_FILIAL ) )
				EndIf
			EndIf
		EndIf

		If (cSQLAlias)->( F2_PREFORI ) == cPrefBAL .and. cTipo == "TPTT" .or. cTipo == "ANA"
			lAbateu := oNFHlp:Abater(cFilAnt, (cSQLAlias)->(D2_ITEM), (cSQLAlias)->(D2_DOC), (cSQLAlias)->(D2_SERIE), (cSQLAlias)->(D2_COD), (cSQLAlias)->(VS3_SEQUEN), (cSQLAlias)->(D2_TOTAL))
			if ! lAbateu
				(cSQLAlias)->(dbSkip()) // Desconsiderar quando Fechamento Agrupado ( mesmo ITEM da NF )
				loop
			endif
		endif

		Do Case
			Case cTipo == "FIL" // Filiais
				If cQuebra1 <> cFilAnt
					nPos1 := aScan(aVetFilT,{|x| x[1] == cFilAnt })
					If nPos1 <= 0
						cDescri := FWFilialName(cEmpAnt,cFilAnt,1)
						aAdd( aVetFilT , { cFilAnt , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
						aAdd( aVetFilB , { cFilAnt , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
						aAdd( aVetFilO , { cFilAnt , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
						nPos1 := len(aVetFilT)
					EndIf
					cQuebra1 := cFilAnt
					nSlvPos1 := nPos1
				Else
					nPos1 := nSlvPos1
				EndIf
			Case cTipo == "VNDE" // Vendedores
				If cQuebra1 <> (cSQLAlias)->( F2_VEND1 )
					nPos1 := aScan(aVetVenT,{|x| x[1] == (cSQLAlias)->( F2_VEND1 ) })
					If nPos1 <= 0
						SA3->(DbSetOrder(1))
						SA3->(MsSeek(cFilSA3+(cSQLAlias)->( F2_VEND1 )))
						cDescri := SA3->A3_NOME
						aAdd( aVetVenT , { IIF(empty((cSQLAlias)->( F2_VEND1 )), "-", (cSQLAlias)->( F2_VEND1 )) , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
						aAdd( aVetVenB , { IIF(empty((cSQLAlias)->( F2_VEND1 )), "-", (cSQLAlias)->( F2_VEND1 )) , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
						aAdd( aVetVenO , { IIF(empty((cSQLAlias)->( F2_VEND1 )), "-", (cSQLAlias)->( F2_VEND1 )) , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
						nPos1 := len(aVetVenT)
					EndIf
					cQuebra1 := (cSQLAlias)->( F2_VEND1 )
					nSlvPos1 := nPos1
				Else
					nPos1 := nSlvPos1
				EndIf
			Case cTipo == "MARCA" // Marca
				If cQuebra1 <> (cSQLAlias)->( VE1_CODMAR )
					nPos1 := aScan(aVetMarT,{|x| x[1] == (cSQLAlias)->( VE1_CODMAR ) })
					If nPos1 <= 0
						cDescri := (cSQLAlias)->( VE1_DESMAR )
						aAdd( aVetMarT , { (cSQLAlias)->( VE1_CODMAR ) , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
						aAdd( aVetMarB , { (cSQLAlias)->( VE1_CODMAR ) , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
						aAdd( aVetMarO , { (cSQLAlias)->( VE1_CODMAR ) , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
						nPos1 := len(aVetMarT)
					EndIf
					cQuebra1 := (cSQLAlias)->( VE1_CODMAR )
					nSlvPos1 := nPos1
				Else
					nPos1 := nSlvPos1
				EndIf
			Case cTipo == "DIA" // Dias
				If cQuebra1 <> (cSQLAlias)->( F2_EMISSAO )
					nPos1 := aScan(aVetDiaT,{|x| x[1] == Transform(stod((cSQLAlias)->( F2_EMISSAO )),"@D") })
					If nPos1 <= 0
						cDescri := DIASEMANA(stod((cSQLAlias)->( F2_EMISSAO )))
						aAdd( aVetDiaT , { Transform(stod((cSQLAlias)->( F2_EMISSAO )),"@D") , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
						aAdd( aVetDiaB , { Transform(stod((cSQLAlias)->( F2_EMISSAO )),"@D") , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
						aAdd( aVetDiaO , { Transform(stod((cSQLAlias)->( F2_EMISSAO )),"@D") , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
						nPos1 := len(aVetDiaT)
					EndIf
					cQuebra1 := (cSQLAlias)->( F2_EMISSAO )
					nSlvPos1 := nPos1
				Else
					nPos1 := nSlvPos1
				EndIf
			Case cTipo == "GRP" // Grupos
				If cQuebra1 <> (cSQLAlias)->( D2_GRUPO )
					nPos1 := aScan(aVetGrpT,{|x| x[1] == (cSQLAlias)->( D2_GRUPO ) })
					If nPos1 <= 0
						aAdd( aVetGrpT , { (cSQLAlias)->( D2_GRUPO ) , (cSQLAlias)->( BM_DESC ) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
						aAdd( aVetGrpB , { (cSQLAlias)->( D2_GRUPO ) , (cSQLAlias)->( BM_DESC ) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
						aAdd( aVetGrpO , { (cSQLAlias)->( D2_GRUPO ) , (cSQLAlias)->( BM_DESC ) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
						nPos1 := len(aVetGrpT)
					EndIf
					cQuebra1 := (cSQLAlias)->( D2_GRUPO )
					nSlvPos1 := nPos1
				Else
					nPos1 := nSlvPos1
				EndIf
			Case cTipo == "ITE" // Itens
				If cQuebra1 <> (cSQLAlias)->( D2_GRUPO )+(cSQLAlias)->( B1_CODITE )
					nPos1 := aScan(aVetIteT,{|x| x[1] == (cSQLAlias)->( D2_GRUPO )+(cSQLAlias)->( B1_CODITE ) })
					If nPos1 <= 0
						aAdd( aVetIteT , { (cSQLAlias)->( D2_GRUPO )+(cSQLAlias)->( B1_CODITE ) , (cSQLAlias)->( B1_DESC ) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
						aAdd( aVetIteB , { (cSQLAlias)->( D2_GRUPO )+(cSQLAlias)->( B1_CODITE ) , (cSQLAlias)->( B1_DESC ) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
						aAdd( aVetIteO , { (cSQLAlias)->( D2_GRUPO )+(cSQLAlias)->( B1_CODITE ) , (cSQLAlias)->( B1_DESC ) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
						nPos1 := len(aVetIteT)
					EndIf
					cQuebra1 := (cSQLAlias)->( D2_GRUPO )+(cSQLAlias)->( B1_CODITE )
					nSlvPos1 := nPos1
				Else
					nPos1 := nSlvPos1
				EndIf
			Case cTipo == "ANA" // Analitico
				if (cSQLAlias)->( F2_PREFORI ) == cPrefOFI
					cIndice := (cSQLAlias)->( D2_FILIAL )+(cSQLAlias)->( D2_DOC )+(cSQLAlias)->( D2_SERIE )
				else
					cIndice := (cSQLAlias)->( D2_FILIAL )+(cSQLAlias)->( D2_DOC )+(cSQLAlias)->( D2_SERIE )+(cSQLAlias)->(VS1_NUMORC)
				endif
				If cQuebra1 <> cIndice
					If (cSQLAlias)->( F2_PREFORI ) == cPrefBAL // Balcao
						nPos1 := aScan(aVetAnaB,{|x| x[1] == cIndice })
						If nPos1 <= 0
							cDescri := (cSQLAlias)->( D2_FILIAL )+" / "+(cSQLAlias)->( D2_DOC )+"-"+(cSQLAlias)->( D2_SERIE )+" / "+(cSQLAlias)->( VS1_NUMORC )
							aAdd( aVetAnaB , { cIndice , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , cFilAnt , 0 } )
							nPos1 := len(aVetAnaB)
						EndIf
					Else //(cSQLAlias)->( F2_PREFORI ) == cPrefOFI // Oficina
						nPos1 := aScan(aVetAnaO,{|x| x[1] == cIndice })
						If nPos1 <= 0
							cDescri := (cSQLAlias)->( D2_FILIAL )+" / "+(cSQLAlias)->( D2_DOC )+"-"+(cSQLAlias)->( D2_SERIE )+" / "+(cSQLAlias)->( VOO_NUMOSV )+" - "+(cSQLAlias)->( VOO_TIPTEM )
							aAdd( aVetAnaO , { cIndice , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , cFilAnt , 0 } )
							nPos1 := len(aVetAnaO)
						EndIf
					EndIf
					cQuebra1 := cIndice
					nSlvPos1 := nPos1
				Else
					nPos1 := nSlvPos1
				EndIf
			Case cTipo == "TPTT" // Oficina - Tipo de Publico / Tipo de Tempo
				If cQuebra1 <> cFilAnt + (cSQLAlias)->( VOI_SITTPO )
					nPos1 := aScan(aVetTPTT,{|x| x[1] == cFilAnt + (cSQLAlias)->( VOI_SITTPO )+space(10) })
					If nPos1 <= 0
						cDescri := FWFilialName(cEmpAnt,cFilAnt,1) + space(5)+UPPER(X3CBOXDESC("VOI_SITTPO",(cSQLAlias)->( VOI_SITTPO )))
						aAdd( aVetTPTT , {cFilAnt + (cSQLAlias)->( VOI_SITTPO )+space(10) , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
						nPos1 := len(aVetTPTT)
					EndIf
					cQuebra1 := cFilAnt + (cSQLAlias)->( VOI_SITTPO )
					nSlvPos1 := nPos1
				Else
					nPos1 := nSlvPos1
				EndIf
				nPos2 := aScan(aVetTPTT,{|x| x[1] == cFilAnt + (cSQLAlias)->( VOI_SITTPO )+(cSQLAlias)->( VOO_TIPTEM ) })
				If nPos2 <= 0
					cDescri := space(10)+(cSQLAlias)->( VOO_TIPTEM )+" - "+(cSQLAlias)->( VOI_DESTTE )
					aAdd( aVetTPTT , { cFilAnt + (cSQLAlias)->( VOI_SITTPO )+(cSQLAlias)->( VOO_TIPTEM ) , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
					nPos2 := len(aVetTPTT)
				EndIf
			Case cTipo == "VEND" // Ranking Vendedores
				If cQuebra1 <> (cSQLAlias)->( F2_VEND1 )
					nPos1 := aScan(aVetVEND,{|x| x[2]+x[1] == "1"+(cSQLAlias)->( F2_VEND1 ) })
					If nPos1 <= 0
						SA3->(DbSetOrder(1))
						SA3->(MsSeek(cFilSA3+(cSQLAlias)->( F2_VEND1 )))
						cDescri := " - "+SA3->A3_NOME
						aAdd( aVetVEND , { IIF(empty((cSQLAlias)->( F2_VEND1 )), "-", (cSQLAlias)->( F2_VEND1 )) , "1" , 0 , cDescri } )
						nPos1 := len(aVetVEND)
					EndIf
					cQuebra1 := (cSQLAlias)->( F2_VEND1 )
					nSlvPos1 := nPos1
				Else
					nPos1 := nSlvPos1
				EndIf
		EndCase

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Valores                     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nVlr03 := (cSQLAlias)->( D2_VALBRUT )   // Valor Venda
		if cTipo == "TPTT" .or. cTipo == "ANA"
			if (cSQLAlias)->(F2_PREFORI) == cPrefOFI
				nVlr03 := (cSQLAlias)->VEC_VALBRU   // Valor Venda que estแ correto com fechamento agrupado // oficina somente, pe็as ainda pensando em solu็ใo
			endif
		endif

		nVlr04 := (cSQLAlias)->( D2_TOTAL   )   // Produtos
		nVlr05 := (cSQLAlias)->( D2_VALICM  )   // ICMS Op
		if (cSQLAlias)->F4_SITTRIB  == "10" .OR. (cSQLAlias)->F4_SITTRIB  == "30" .OR. (cSQLAlias)->F4_SITTRIB  == "70"
			nVlr06 := (cSQLAlias)->( D2_ICMSRET )   // ICMS ST
		Else
			nVlr06 := 0
		Endif
		nVlr07 := (cSQLAlias)->( D2_VALIMP6 )   // PIS
		nVlr08 := (cSQLAlias)->( D2_VALIMP5 )   // COFINS
		nVlr09 := 0                             // ICMS ST (Ressar)
		nVlr10 := 0                             // ICMS OP (Ressar)
		nVlr11 := (cSQLAlias)->( D2_ICMSCOM )   // ICMS Comple.
		nVlr12 := (cSQLAlias)->( D2_DIFAL )     // ICMS Difal
		//

		If cEstEmp $ cEstResST+cEstResOP .and. (nVlr05+nVlr06) > 0 // Estado da Empresa/Filial esta entre os Estados com Ressarcimentos
		   cQuery := "  SELECT SD1.D1_ICMSRET , SD1.D1_VALICM , SD1.D1_QUANT FROM "+cNamSD1+" SD1 "
		   cQuery += "    JOIN "+cNamSF4+" SF4 ON ( SF4.F4_FILIAL = '"+cFilSF4+"' AND SF4.F4_CODIGO = SD1.D1_TES AND ( SF4.F4_OPEMOV = '01' OR SF4.F4_OPEMOV = '03' ) AND SF4.D_E_L_E_T_=' ' ) "
		   cQuery += "   WHERE SD1.D1_FILIAL='"+cFilSD1+"' AND SD1.D1_COD='"+(cSQLAlias)->( D2_COD )+"' AND SD1.D1_DTDIGIT<='"+(cSQLAlias)->( F2_EMISSAO )+"' AND SD1.D1_ICMSRET > 0 AND SD1.D_E_L_E_T_=' ' "
		   cQuery += "ORDER BY SD1.D1_DTDIGIT DESC "
		   dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlSD1, .F., .T. )
		   If !(cSQLAlSD1)->(Eof())
		   	  If cEstEmp $ cEstResST
		         nVlr09 := ( ( (cSQLAlSD1)->( D1_ICMSRET ) / (cSQLAlSD1)->( D1_QUANT ) ) * (cSQLAlias)->( D2_QUANT ) ) // ICMS ST (Ressar)
 			  Endif
		   	  If cEstEmp $ cEstResOP
		      	 nVlr10 := ( ( (cSQLAlSD1)->( D1_VALICM  ) / (cSQLAlSD1)->( D1_QUANT ) ) * (cSQLAlias)->( D2_QUANT ) ) // ICMS OP (Ressar)
		   	  EndIf
		   Endif
	      (cSQLAlSD1)->(dbCloseArea())

		EndIf

		//
		nVlr13 := (cSQLAlias)->( D2_DESCON )                                  // Desconto
		nVlr14 := (cSQLAlias)->( D2_VALFRE ) + (cSQLAlias)->( D2_DESPESA )    // Frete + Desp
		nVlr16 := (cSQLAlias)->( D2_CUSTO1 )                                  // Valor Custo

		//////////////////////////////////////////////////////////////////////////////////////////////////
		//                                                                                              //
		// Os valores 15 e 17 foram trocados e sใo feitos atrav้s de fun็oes estaticas                  //
		// Tamb้m foi removido um bloco contendo valida็ใo de estado com via de ressarcimento.          //
		//                                                                                              //
		//////////////////////////////////////////////////////////////////////////////////////////////////

		For ni := 1 to 2
			If ni == 2
				nPos1 := 1 // Total Geral dos Vetores
			EndIf
			Do Case
				Case cTipo == "FIL" // Filiais
					For ny := 3 to 17
						aVetFilT[nPos1,ny] += &("nVlr"+strzero(ny,2))
						If (cSQLAlias)->( F2_PREFORI ) == cPrefBAL // Balcao
							aVetFilB[nPos1,ny] += &("nVlr"+strzero(ny,2))
						Else //(cSQLAlias)->( F2_PREFORI ) == cPrefOFI // Oficina
							aVetFilO[nPos1,ny] += &("nVlr"+strzero(ny,2))
						EndIf
					Next
				Case cTipo == "VNDE" // Vendedores
					For ny := 3 to 17
						aVetVenT[nPos1,ny] += &("nVlr"+strzero(ny,2))
						If (cSQLAlias)->( F2_PREFORI ) == cPrefBAL // Balcao
							aVetVenB[nPos1,ny] += &("nVlr"+strzero(ny,2))
						Else //(cSQLAlias)->( F2_PREFORI ) == cPrefOFI // Oficina
							aVetVenO[nPos1,ny] += &("nVlr"+strzero(ny,2))
						EndIf
					Next
				Case cTipo == "MARCA" // Marcas
					For ny := 3 to 17
						aVetMarT[nPos1,ny] += &("nVlr"+strzero(ny,2))
						If (cSQLAlias)->( F2_PREFORI ) == cPrefBAL // Balcao
							aVetMarB[nPos1,ny] += &("nVlr"+strzero(ny,2))
						Else //(cSQLAlias)->( F2_PREFORI ) == cPrefOFI // Oficina
							aVetMarO[nPos1,ny] += &("nVlr"+strzero(ny,2))
						EndIf
					Next
				Case cTipo == "DIA" // Dias
					For ny := 3 to 17
						aVetDiaT[nPos1,ny] += &("nVlr"+strzero(ny,2))
						If (cSQLAlias)->( F2_PREFORI ) == cPrefBAL // Balcao
							aVetDiaB[nPos1,ny] += &("nVlr"+strzero(ny,2))
						Else //(cSQLAlias)->( F2_PREFORI ) == cPrefOFI // Oficina
							aVetDiaO[nPos1,ny] += &("nVlr"+strzero(ny,2))
						EndIf
					Next
				Case cTipo == "GRP" // Grupos
					For ny := 3 to 17
						aVetGrpT[nPos1,ny] += &("nVlr"+strzero(ny,2))
						If (cSQLAlias)->( F2_PREFORI ) == cPrefBAL // Balcao
							aVetGrpB[nPos1,ny] += &("nVlr"+strzero(ny,2))
						Else //(cSQLAlias)->( F2_PREFORI ) == cPrefOFI // Oficina
							aVetGrpO[nPos1,ny] += &("nVlr"+strzero(ny,2))
						EndIf
					Next
				Case cTipo == "ITE" // Itens
					For ny := 3 to 17
						aVetIteT[nPos1,ny] += &("nVlr"+strzero(ny,2))
						If (cSQLAlias)->( F2_PREFORI ) == cPrefBAL // Balcao
							aVetIteB[nPos1,ny] += &("nVlr"+strzero(ny,2))
						Else //(cSQLAlias)->( F2_PREFORI ) == cPrefOFI // Oficina
							aVetIteO[nPos1,ny] += &("nVlr"+strzero(ny,2))
						EndIf
					Next
				Case cTipo == "ANA" // Analitico
					For ny := 3 to 17
						If (cSQLAlias)->( F2_PREFORI ) == cPrefBAL // Balcao
							aVetAnaB[nPos1,ny] += &("nVlr"+strzero(ny,2))
						Else //(cSQLAlias)->( F2_PREFORI ) == cPrefOFI // Oficina
							aVetAnaO[nPos1,ny] += &("nVlr"+strzero(ny,2))
						EndIf
					Next
				Case cTipo == "TPTT" // Oficina - Tipo de Publico / Tipo de Tempo
					For ny := 3 to 17
						aVetTPTT[nPos1,ny] += &("nVlr"+strzero(ny,2))
						If nPos1 <> 1 // Total por Tipo de Publico / Tipo de Tempo
							aVetTPTT[nPos2,ny] += &("nVlr"+strzero(ny,2))
						EndIf
					Next
				Case cTipo == "VEND" // Ranking Vendedores
					aVetVEND[nPos1,3] += nVlr03 // Valor Venda
			EndCase
		Next
		If aFiltro[13] == STR0022 // Devolucoes referente as Vendas no Periodo
			nPos1 := aScan(aNFsDev,{|x| x[1]+x[2]+x[3] == (cSQLAlias)->( D2_FILIAL )+(cSQLAlias)->( D2_DOC )+(cSQLAlias)->( D2_SERIE ) })
			If nPos1 <= 0
				aAdd( aNFsDev , { (cSQLAlias)->( D2_FILIAL ) , (cSQLAlias)->( D2_DOC ) , (cSQLAlias)->( D2_SERIE ) } )
			EndIf
		EndIf

		////////////////////////////////////////////////////////////////////
		//                                                                //
		// Adi็ใo das informa็๕es a respeito do prazo m้dio de vendas PMV //
		//                                                                //
		////////////////////////////////////////////////////////////////////
		If aFiltro[24] == STR0069
			cLbl := IIF(!Empty( STOD(cQuebra1) ), DTOC(STOD(cQuebra1)), cQuebra1)// Se for data, sera mostrada quebra como uma data formato br
			If aScan(aPMVDataSai[nPilha],{|x| x:GetValue('Quebra') + x:GetValue('D2_DOC') + x:GetValue('D2_SERIE') + x:GetValue('E1_FILIAL') == cLbl + (cSQLAlias)->(D2_DOC) + (cSQLAlias)->(D2_SERIE) + cFilSE1 }) == 0
				AADD( aPMVDataSai[nPilha], Mil_DataContainer():New({ ;
					{'Quebra'     , cLbl                      },;
					{'D2_LOJA'    , (cSQLAlias)->(D2_LOJA   ) },;
					{'D2_CLIENTE' , (cSQLAlias)->(D2_CLIENTE) },;
					{'D2_DOC'     , (cSQLAlias)->(D2_DOC)     },;
					{'D2_SERIE'   , (cSQLAlias)->(D2_SERIE)   },;
					{'F2_PREFORI' , (cSQLAlias)->(F2_PREFORI) },;
					{'E1_FILIAL'  , cFilSE1                 } ;
				}))
			Endif
		Endif
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ SQL DEVOLUCOES - SELECT ( Filiais / Dias / Grupos / Itens ) ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If aFiltro[13] <> STR0020 // devolucoes diferente de ( nao considerar )
		If aFiltro[13] == STR0021 // Devolucoes referente ao Periodo ( do Periodo )
			aNFsDev := {}
			aAdd(aNFsDev,{"","",""}) // Considerar Todas as devolucoes dentro do Periodo
		EndIf
		For nDev := 1 to len(aNFsDev)
			///////////////////
			// CAMPOS  SQL   //
			///////////////////
			cQuery := "SELECT SD2.D2_LOJA, SD2.D2_ITEM,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_COD,D2_TOTAL,SD1.D1_LOJA, SD1.D1_FORNECE, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FILIAL , SF4.F4_SITTRIB , SD1.D1_TOTAL , SD1.D1_VALIPI , SD1.D1_DESPESA , SD1.D1_SEGURO , "
			cQuery += "SD1.D1_QUANT , SD1.D1_ICMSRET , SD1.D1_VALFRE , SD1.D1_VALICM , SD1.D1_VALIMP5 , SD1.D1_VALIMP6 , SD1.D1_VALDESC , SD1.D1_ITEM, "
			cQuery += "SD1.D1_CUSTO , SD1.D1_ICMSCOM , SD1.D1_DIFAL  , SF2.F2_PREFORI , SF2.F2_EMISSAO , SD2.D2_ICMSRET, SD2.D2_COD , SD2.D2_VALICM, SD2.D2_QUANT , SA1.A1_EST "
			Do Case
				Case cTipo == "FIL"
					cQuery += ", SD1.D1_FILIAL "
				Case cTipo == "DIA"
					cQuery += ", SD1.D1_DTDIGIT "
				Case cTipo == "GRP" // Grupos
					cQuery += ", SD1.D1_GRUPO , SBM.BM_DESC "
				Case cTipo == "ITE" // Itens
					cQuery += ", SD1.D1_GRUPO , SB1.B1_CODITE , SB1.B1_DESC "
				Case cTipo == "ANA" // Analitico
					cQuery += ", SD1.D1_FILIAL , SD1.D1_NFORI , SD1.D1_SERIORI , SD1.D1_COD , VS1.VS1_NUMORC , VEC_NUMOSV VOO_NUMOSV , VEC_TIPTEM VOO_TIPTEM, VEC.VEC_QTDITE, VEC.VEC_VALBRU "
					cQuery += ", VS3_SEQUEN "
				Case cTipo == "TPTT" // Oficina - Tipo de Publico / Tipo de Tempo
					cQuery += ", SD1.D1_FILIAL , SD1.D1_NFORI , SD1.D1_SERIORI , SD1.D1_COD , VOI.VOI_SITTPO , VOI.VOI_DESTTE , VEC_TIPTEM VOO_TIPTEM "
				Case cTipo == "VEND" // Ranking Vendedores
					cQuery += " , CASE WHEN coalesce(SF2.F2_VEND1, '') = '' then '-' else F2_VEND1 end F2_VEND1 "
				Case cTipo == "VNDE" // Vendedores
					cQuery += " , CASE WHEN coalesce(SF2.F2_VEND1, '') = '' then '-' else F2_VEND1 end F2_VEND1 "
				Case cTipo == "MARCA" // MARCAS
					cQuery += ", COALESCE(VE1.VE1_CODMAR,'-') AS VE1_CODMAR, VE1.VE1_DESMAR "
			EndCase
			///////////////////
			// FROM SD1      //
			///////////////////
			cQuery += "FROM "+cNamSD1+" SD1 "
			///////////////////
			// JOIN SF2      //
			///////////////////
			cQuery += "JOIN "+cNamSF2+" SF2 ON "
			cQuery += "( SF2.F2_FILIAL=SD1.D1_FILIAL AND SF2.F2_DOC=SD1.D1_NFORI AND SF2.F2_SERIE=SD1.D1_SERIORI AND "
			If cTipo == "TPTT" // Oficina - Tipo de Publico / Tipo de Tempo
				cQuery += "SF2.F2_PREFORI='"+cPrefOFI+"' AND "
			Else
				If aFiltro[15] == "T" // Todos (Balcao/Oficina)
					cQuery += "SF2.F2_PREFORI IN ('"+cPrefBAL+"','"+cPrefOFI+"') AND "
				ElseIf aFiltro[15] == "B" // Balcao
					cQuery += "SF2.F2_PREFORI='"+cPrefBAL+"' AND "
				ElseIf aFiltro[15] == "O" // Oficina
					cQuery += "SF2.F2_PREFORI='"+cPrefOFI+"' AND "
				EndIf
			EndIf
			If !Empty(aFiltro[12]) // Filtra Vendedor
				cQuery += "SF2.F2_VEND1='"+aFiltro[12]+"' AND "
			EndIf
			cQuery += "SF2.D_E_L_E_T_=' ' ) "
			///////////////////
			// JOIN SD2      //
			///////////////////
			cQuery += "JOIN "+cNamSD2+" SD2 ON "
			cQuery += "( SD2.D2_FILIAL=SF2.F2_FILIAL AND SD2.D2_DOC=SF2.F2_DOC AND SD2.D2_SERIE=SF2.F2_SERIE AND SD2.D2_COD=SD1.D1_COD AND SD1.D1_ITEMORI = SD2.D2_ITEM AND SD2.D_E_L_E_T_=' ' ) "
			//////////////////////
			// JOIN SF4 ENTRADA //
			//////////////////////
			cQuery += "JOIN "+cNamSF4+" SF4 ON ( "
			cQuery += "SF4.F4_FILIAL='"+cFilSF4+"' AND "
			cQuery += "SF4.F4_CODIGO=SD1.D1_TES AND SF4.F4_OPEMOV='09' AND SF4.D_E_L_E_T_=' ' ) " // F4_OPEMOV='09' -> Devolucao

			////////////////////
			// JOIN SF4 SAIDA //
			////////////////////
			cQuery += "JOIN "+cNamSF4+" SF4SAI ON ( "
			cQuery += "SF4SAI.F4_FILIAL='"+cFilSF4+"' AND "
			cQuery += "SF4SAI.F4_CODIGO=SD2.D2_TES AND SF4SAI.F4_OPEMOV='05' AND SF4SAI.D_E_L_E_T_=' ' ) " // Devolu็ใo de Venda

			///////////////////
			// JOIN SBM      //
			///////////////////
			cQuery += "JOIN "+cNamSBM+" SBM ON ( "
			cQuery += "SBM.BM_FILIAL='"+cFilSBM+"' AND "
			cQuery += "SBM.BM_GRUPO=SD1.D1_GRUPO AND SBM.BM_TIPGRU NOT IN ('7','4') AND SBM.D_E_L_E_T_=' ' ) "
			///////////////////
			// JOIN SB1      //
			///////////////////
			cQuery += "JOIN "+cNamSB1+" SB1 ON ( "
			cQuery += "SB1.B1_FILIAL='"+cFilSB1+"' AND "
			cQuery += "SB1.B1_COD=SD1.D1_COD AND SB1.D_E_L_E_T_=' ' ) "
			///////////////////
			// JOIN SA1      //
			///////////////////
			cQuery += "JOIN "+cNamSA1+" SA1 ON ( "
			cQuery += "SA1.A1_FILIAL='"+cFilSA1+"' AND "
			cQuery += "SA1.A1_COD=SF2.F2_CLIENTE AND SA1.A1_LOJA=SF2.F2_LOJA AND "
			If !Empty(aFiltro[04]) // 04 - Pessoa
				cQuery += "SA1.A1_PESSOA='"+aFiltro[04]+"' AND "
			EndIf
			If !Empty(aFiltro[05]) // 05 - Tipo
				cQuery += "SA1.A1_TIPO='"+aFiltro[05]+"' AND "
			EndIf
			If !Empty(aFiltro[06]) // 06 - Tipo Cliente
				cQuery += "SA1.A1_TIPOCLI='"+aFiltro[06]+"' AND "
			EndIf
			cQuery += "SA1.D_E_L_E_T_=' ' ) "
			If !Empty(aFiltro[03]) // 03 - Regiao de Atuacao
				///////////////////
				// LEFT JOIN VAM //
				///////////////////
				cQuery += "LEFT JOIN "+cNamVAM+" VAM ON ( "
				cQuery += "VAM.VAM_FILIAL='"+cFilVAM+"' AND "
				cQuery += "VAM.VAM_IBGE=SA1.A1_IBGE AND VAM.VAM_REGIAO='"+aFiltro[03]+"' AND VAM.D_E_L_E_T_=' ' ) "
			EndIf
			/////////////////////////////////////
			// Filtro                          //
			// 07 - Tipo de Negocio do Cliente //
			/////////////////////////////////////
			If !Empty(aFiltro[07])
				///////////////////
				// JOIN VZO      //
				///////////////////
				cQuery += "JOIN "+cNamVZO+" VZO ON ( "
				cQuery += "VZO.VZO_FILIAL='"+cFilVZO+"' AND "
				cQuery += "VZO.VZO_CLIENT=SF2.F2_CLIENTE AND VZO.VZO_LOJA=SF2.F2_LOJA AND "
				cQuery += "VZO.VZO_TIPO='"+aFiltro[07]+"' AND VZO.D_E_L_E_T_=' ' )"
			EndIf

			If cTipo == "ANA" // Analitico
				///////////////////
				// LEFT JOIN VS1 //
				///////////////////
				cQuery += "LEFT JOIN "+cNamVS1+" VS1 ON VS1.VS1_FILIAL='"+cFilVS1+"' AND SF2.F2_PREFORI='"+cPrefBAL+"'   AND VS1.VS1_NUMNFI=SD2.D2_DOC AND VS1.VS1_SERNFI=SD2.D2_SERIE AND VS1.D_E_L_E_T_ = ' ' "
				cQuery += "LEFT JOIN "+cNamVS3+" VS3 ON VS3.VS3_FILIAL='"+cFilVS1+"' AND VS3.VS3_NUMORC = VS1.VS1_NUMORC AND VS3_CODITE = B1_CODITE AND VS3_GRUITE = B1_GRUPO  AND VS3.D_E_L_E_T_ = ' ' "
				///////////////////
				// LEFT JOIN VEC //
				///////////////////
				cQuery += "LEFT JOIN "+RetSQLName("VEC")+" VEC ON VEC_FILIAL='"+xFilial("VEC")+"' AND VEC_NUMNFI = D2_DOC AND VEC_SERNFI = D2_SERIE AND D2_ITEM = VEC_ITENFI AND VEC.D_E_L_E_T_=' ' "
			EndIf
			If cTipo == "TPTT" // Oficina - Tipo de Publico / Tipo de Tempo
				///////////////////
				// LEFT JOIN VEC //
				///////////////////
				cQuery += "LEFT JOIN "+RetSQLName("VEC")+" VEC ON VEC_FILIAL='"+xFilial("VEC")+"' AND VEC_NUMNFI = D2_DOC AND VEC_SERNFI = D2_SERIE AND D2_ITEM = VEC_ITENFI AND VEC.D_E_L_E_T_=' ' "
				cQuery += "LEFT JOIN "+cNamVOI+" VOI ON VOI.VOI_FILIAL='"+cFilVOI+"' AND VOI.VOI_TIPTEM = VEC.VEC_TIPTEM AND VOI.D_E_L_E_T_=' ' "
			EndIf

			///////////////////
			// LEFT JOIN VE1 //
			///////////////////
			cQuery += "LEFT JOIN "+cNamVE1+" VE1 ON ( "
			cQuery += "VE1.VE1_FILIAL='"+cFilVE1+"' AND "
			cQuery += "VE1.VE1_CODMAR=SBM.BM_CODMAR AND VE1.D_E_L_E_T_=' ' ) "

			///////////////////
			// WHERE         //
			///////////////////
			cQuery += "WHERE "
			If Empty(aNFsDev[nDev,2]) // Considerar Todas as devolucoes dentro do Periodo
				cQuery += "SD1.D1_FILIAL='"+cFilSD1+"' AND "
				If Empty(aFiltro[18]) // Todas os Dias do Periodo
					cQuery += "SD1.D1_DTDIGIT>='"+dtos(aFiltro[01])+"' AND SD1.D1_DTDIGIT<='"+dtos(aFiltro[02])+"' AND "
				Else // Dia selecionado
					cQuery += "SD1.D1_DTDIGIT='"+dtos(ctod(aFiltro[18]))+"' AND "
				EndIf
			Else // Somente a Devolucao referente a venda NF+SERIE
				cQuery += "SD1.D1_FILIAL='"+aNFsDev[nDev,1]+"' AND SD1.D1_NFORI='"+aNFsDev[nDev,2]+"' AND SD1.D1_SERIORI='"+aNFsDev[nDev,3]+"' AND "
			EndIf

			If !Empty(aFiltro[10]) .Or. !Empty(aFiltro[25]) // Grupo do Item do Filtro e Grupo Considerar
				cQuery += "SD1.D1_GRUPO IN "+cFiltGrupo+" AND "
			Else
				If !Empty(aFiltro[19]) // Grupo do Item selecionado
					cQuery += "SD1.D1_GRUPO='"+aFiltro[19]+"' AND "
				EndIf
			EndIf

			If !Empty(aFiltro[26]) // Grupo Nใo Considerar
				cQuery += "SD1.D1_GRUPO NOT IN "+cFiltGrNAO+" AND "
			EndIf

			If !Empty(aFiltro[11]) // Codigo do Item do Filtro
				cQuery += "SB1.B1_CODITE='"+aFiltro[11]+"' AND "
			Else
				If !Empty(aFiltro[20]) // Grupo + Codigo do Item selecionado
					cQuery += "SD1.D1_GRUPO='"+left(aFiltro[20],TamSx3("D1_GRUPO")[1])+"' AND "
					cQuery += "SB1.B1_CODITE='"+substr(aFiltro[20],(TamSx3("D1_GRUPO")[1]+1))+"' AND "
				EndIf
			EndIf

			If !Empty(aFiltro[08]) // Codigo do Cliente
				cQuery += "SD1.D1_FORNECE='"+aFiltro[08]+"' AND "
			EndIf

			If !Empty(aFiltro[09]) // Loja do Cliente
				cQuery += "SD1.D1_LOJA='"+aFiltro[09]+"' AND "
			EndIf

			If ! Empty(aFiltro[16]) .or. "-" $ aFiltro[16] // Vendedor
				if "-" $ aFiltro[16]
					cQuery += "SF2.F2_VEND1 = '"+space( GetSx3Cache("VAI_CODVEN","X3_TAMANHO") )+"' AND "
				else
					cQuery += "SF2.F2_VEND1 = '"+aFiltro[16]+"' AND "
				endif
			EndIf

			If !Empty(aFiltro[17]) // Marca
				If aFiltro[17] == "-"
					cQuery += "VE1.VE1_CODMAR IS NULL AND "
				Else
					cQuery += "VE1.VE1_CODMAR = '"+aFiltro[17]+"' AND "
				EndIf
			EndIf
			//
			//Este ponto de entrada deverแ possibilitar a altera็ใo da clausula 'WHERE' no levantamento das devolu็๕es.
			if ExistBlock("OFC470FDV")
				cQuery := ExecBlock("OFC470FDV",.f.,.f., {cQuery})
			EndIf
			//
			cQuery += "SD1.D_E_L_E_T_=' ' ORDER BY "
			///////////////////
			// ORDER BY      //
			///////////////////
			Do Case
				Case cTipo == "FIL" // Filiais
					cQuery += "SD1.D1_FILIAL "
				Case cTipo == "DIA" // Dias
					cQuery += "SD1.D1_DTDIGIT "
				Case cTipo == "GRP" // Grupos
					cQuery += "SD1.D1_GRUPO "
				Case cTipo == "ITE" // Itens
					cQuery += "SD1.D1_GRUPO , SB1.B1_CODITE "
				Case cTipo == "ANA" // Analitico
					cQuery += "SD1.D1_FILIAL , SD1.D1_NFORI , SD1.D1_SERIORI , SD1.D1_COD "
				Case cTipo == "TPTT" // Oficina - Tipo de Publico / Tipo de Tempo
					cQuery += "VOI.VOI_SITTPO , VOO_TIPTEM , SD1.D1_NFORI , SD1.D1_SERIORI , SD1.D1_COD , SD1.D1_FILIAL "
				Case cTipo == "VEND" // Ranking Vendedores
					cQuery += "SF2.F2_VEND1 "
				Case cTipo == "VNDE" // Vendedores
					cQuery += "SF2.F2_VEND1 "
				Case cTipo == "MARCA" // MARCAS
					cQuery += "VE1.VE1_CODMAR, VE1.VE1_DESMAR "
			EndCase
			//
			cQuebra := ""
			//
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
			While !(cSQLAlias)->(Eof())
				If (cSQLAlias)->( F2_PREFORI ) == cPrefOFI // Oficina
					If cTipo == "TPTT" // utilizam VOO -> Oficina - Tipo de Publico / Tipo de Tempo
						If cQuebra == ( (cSQLAlias)->( D1_NFORI ) + (cSQLAlias)->( D1_SERIORI ) + (cSQLAlias)->( D1_COD ) + (cSQLAlias)->( D1_ITEM ) + (cSQLAlias)->( D1_FILIAL ) )
							(cSQLAlias)->(dbSkip()) // Desconsiderar quando Fechamento Agrupado ( mesmo ITEM da NF )
							Loop
						Else
							cQuebra := ( (cSQLAlias)->( D1_NFORI ) + (cSQLAlias)->( D1_SERIORI ) + (cSQLAlias)->( D1_COD ) + (cSQLAlias)->( D1_ITEM ) + (cSQLAlias)->( D1_FILIAL ) )
						EndIf
					EndIf
				EndIf
				Do Case
					Case cTipo == "FIL" // Filiais
						If cQuebra1 <> cFilAnt
							nPos1 := aScan(aVetFilT,{|x| x[1] == cFilAnt })
							If nPos1 <= 0
								cDescri := FWFilialName(cEmpAnt,cFilAnt,1)
								aAdd( aVetFilT , { cFilAnt , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
								aAdd( aVetFilB , { cFilAnt , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
								aAdd( aVetFilO , { cFilAnt , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
								nPos1 := len(aVetFilT)
							EndIf
							cQuebra1 := cFilAnt
							nSlvPos1 := nPos1
						Else
							nPos1 := nSlvPos1
						EndIf
					Case cTipo == "VNDE" // Vendedores
						If cQuebra1 <> (cSQLAlias)->( F2_VEND1 )
							nPos1 := aScan(aVetVenT,{|x| x[1] == (cSQLAlias)->( F2_VEND1 ) })
							If nPos1 <= 0
								SA3->(DbSetOrder(1))
								SA3->(MsSeek(cFilSA3+(cSQLAlias)->( F2_VEND1 )))
								cDescri := SA3->A3_NOME
								aAdd( aVetVenT , { IIF(empty((cSQLAlias)->( F2_VEND1 )), "-", (cSQLAlias)->( F2_VEND1 )) , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
								aAdd( aVetVenB , { IIF(empty((cSQLAlias)->( F2_VEND1 )), "-", (cSQLAlias)->( F2_VEND1 )) , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
								aAdd( aVetVenO , { IIF(empty((cSQLAlias)->( F2_VEND1 )), "-", (cSQLAlias)->( F2_VEND1 )) , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
								nPos1 := len(aVetVenT)
							EndIf
							cQuebra1 := (cSQLAlias)->( F2_VEND1 )
							nSlvPos1 := nPos1
						Else
							nPos1 := nSlvPos1
						EndIf
					Case cTipo == "MARCA" // Marcas
						If cQuebra1 <> (cSQLAlias)->( VE1_CODMAR )
							nPos1 := aScan(aVetMarT,{|x| x[1] == (cSQLAlias)->( VE1_CODMAR ) })
							If nPos1 <= 0
								cDescri := (cSQLAlias)->( VE1_DESMAR )
								aAdd( aVetMarT , { (cSQLAlias)->( VE1_CODMAR ) , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
								aAdd( aVetMarB , { (cSQLAlias)->( VE1_CODMAR ) , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
								aAdd( aVetMarO , { (cSQLAlias)->( VE1_CODMAR ) , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
								nPos1 := len(aVetMarT)
							EndIf
							cQuebra1 := (cSQLAlias)->( VE1_CODMAR )
							nSlvPos1 := nPos1
						Else
							nPos1 := nSlvPos1
						EndIf
					Case cTipo == "DIA" // Dias
						If cQuebra1 <> (cSQLAlias)->( D1_DTDIGIT )
							nPos1 := aScan(aVetDiaT,{|x| x[1] == Transform(stod((cSQLAlias)->( D1_DTDIGIT )),"@D") })
							If nPos1 <= 0
								cDescri := DIASEMANA(stod((cSQLAlias)->( D1_DTDIGIT )))
								aAdd( aVetDiaT , { Transform(stod((cSQLAlias)->( D1_DTDIGIT )),"@D") , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
								aAdd( aVetDiaB , { Transform(stod((cSQLAlias)->( D1_DTDIGIT )),"@D") , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
								aAdd( aVetDiaO , { Transform(stod((cSQLAlias)->( D1_DTDIGIT )),"@D") , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
								nPos1 := len(aVetDiaT)
							EndIf
							cQuebra1 := (cSQLAlias)->( D1_DTDIGIT )
							nSlvPos1 := nPos1
						Else
							nPos1 := nSlvPos1
						EndIf
					Case cTipo == "GRP" // Grupos
						If cQuebra1 <> (cSQLAlias)->( D1_GRUPO )
							nPos1 := aScan(aVetGrpT,{|x| x[1] == (cSQLAlias)->( D1_GRUPO ) })
							If nPos1 <= 0
								aAdd( aVetGrpT , { (cSQLAlias)->( D1_GRUPO ) , (cSQLAlias)->( BM_DESC ) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
								aAdd( aVetGrpB , { (cSQLAlias)->( D1_GRUPO ) , (cSQLAlias)->( BM_DESC ) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
								aAdd( aVetGrpO , { (cSQLAlias)->( D1_GRUPO ) , (cSQLAlias)->( BM_DESC ) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
								nPos1 := len(aVetGrpT)
							EndIf
							cQuebra1 := (cSQLAlias)->( D1_GRUPO )
							nSlvPos1 := nPos1
						Else
							nPos1 := nSlvPos1
						EndIf
					Case cTipo == "ITE" // Itens
						If cQuebra1 <> (cSQLAlias)->( D1_GRUPO )+(cSQLAlias)->( B1_CODITE )
							nPos1 := aScan(aVetIteT,{|x| x[1] == (cSQLAlias)->( D1_GRUPO )+(cSQLAlias)->( B1_CODITE ) })
							If nPos1 <= 0
								aAdd( aVetIteT , { (cSQLAlias)->( D1_GRUPO )+(cSQLAlias)->( B1_CODITE ) , (cSQLAlias)->( B1_DESC ) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
								aAdd( aVetIteB , { (cSQLAlias)->( D1_GRUPO )+(cSQLAlias)->( B1_CODITE ) , (cSQLAlias)->( B1_DESC ) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
								aAdd( aVetIteO , { (cSQLAlias)->( D1_GRUPO )+(cSQLAlias)->( B1_CODITE ) , (cSQLAlias)->( B1_DESC ) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
								nPos1 := len(aVetIteT)
							EndIf
							cQuebra1 := (cSQLAlias)->( D1_GRUPO )+(cSQLAlias)->( B1_CODITE )
							nSlvPos1 := nPos1
						Else
							nPos1 := nSlvPos1
						EndIf
					Case cTipo == "ANA" // Analitico
						if (cSQLAlias)->( F2_PREFORI ) == cPrefOFI
							cIndice := (cSQLAlias)->( D1_FILIAL )+(cSQLAlias)->( D1_NFORI )+(cSQLAlias)->( D1_SERIORI )
						else
							cIndice := (cSQLAlias)->( D1_FILIAL )+(cSQLAlias)->( D1_NFORI )+(cSQLAlias)->( D1_SERIORI )+(cSQLAlias)->(VS1_NUMORC)
						endif
						If cQuebra1 <> cIndice
							If (cSQLAlias)->( F2_PREFORI ) == cPrefBAL // Balcao
								nPos1 := aScan(aVetAnaB,{|x| x[1] == cIndice })
								If nPos1 <= 0
									cDescri := (cSQLAlias)->( D1_FILIAL )+" / "+(cSQLAlias)->( D1_NFORI )+"-"+(cSQLAlias)->( D1_SERIORI )+" / "+(cSQLAlias)->( VS1_NUMORC )
									aAdd( aVetAnaB , { cIndice , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , cFilAnt } )
									nPos1 := len(aVetAnaB)
								EndIf
							Else
								nPos1 := aScan(aVetAnaO,{|x| x[1] == cIndice })
								If nPos1 <= 0
									cDescri := (cSQLAlias)->( D1_FILIAL )+" / "+(cSQLAlias)->( D1_NFORI )+"-"+(cSQLAlias)->( D1_SERIORI )+" / "+(cSQLAlias)->( VOO_NUMOSV )+" - "+(cSQLAlias)->( VOO_TIPTEM )
									aAdd( aVetAnaO , { cIndice , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , cFilAnt } )
									nPos1 := len(aVetAnaO)
								EndIf
							EndIf
							cQuebra1 := cIndice
							nSlvPos1 := nPos1
						Else
							nPos1 := nSlvPos1
						EndIf
					Case cTipo == "TPTT" // Oficina - Tipo de Publico / Tipo de Tempo
						If cQuebra1 <> (cSQLAlias)->( VOI_SITTPO )
							nPos1 := aScan(aVetTPTT,{|x| x[1] == (cSQLAlias)->( VOI_SITTPO )+space(10) })
							If nPos1 <= 0
								cDescri := space(5)+UPPER(X3CBOXDESC("VOI_SITTPO",(cSQLAlias)->( VOI_SITTPO )))
								aAdd( aVetTPTT , { (cSQLAlias)->( VOI_SITTPO )+space(10) , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
								nPos1 := len(aVetTPTT)
							EndIf
							cQuebra1 := (cSQLAlias)->( VOI_SITTPO )
							nSlvPos1 := nPos1
						Else
							nPos1 := nSlvPos1
						EndIf
						nPos2 := aScan(aVetTPTT,{|x| x[1] == (cSQLAlias)->( VOI_SITTPO )+(cSQLAlias)->( VOO_TIPTEM ) })
						If nPos2 <= 0
							cDescri := space(10)+(cSQLAlias)->( VOO_TIPTEM )+" - "+(cSQLAlias)->( VOI_DESTTE )
							aAdd( aVetTPTT , { (cSQLAlias)->( VOI_SITTPO )+(cSQLAlias)->( VOO_TIPTEM ) , cDescri , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
							nPos2 := len(aVetTPTT)
						EndIf
					Case cTipo == "VEND" // Ranking Vendedores
						If cQuebra1 <> (cSQLAlias)->( F2_VEND1 )
							nPos1 := aScan(aVetVEND,{|x| x[2]+x[1] == "1"+(cSQLAlias)->( F2_VEND1 ) })
							If nPos1 <= 0
								SA3->(DbSetOrder(1))
								SA3->(MsSeek(cFilSA3+(cSQLAlias)->( F2_VEND1 )))
								cDescri := " - "+SA3->A3_NOME
								aAdd( aVetVEND , { IIF(empty((cSQLAlias)->( F2_VEND1 )), "-", (cSQLAlias)->( F2_VEND1 )) , "1" , 0 , cDescri } )
								nPos1 := len(aVetVEND)
							EndIf
							cQuebra1 := (cSQLAlias)->( F2_VEND1 )
							nSlvPos1 := nPos1
						Else
							nPos1 := nSlvPos1
						EndIf
				EndCase

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Valores                     ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nVlr03 := (cSQLAlias)->( D1_TOTAL ) - (cSQLAlias)->( D1_VALDESC ) + (cSQLAlias)->( D2_ICMSRET ) // + (cSQLAlias)->( D1_VALDESC ) + (cSQLAlias)->( D1_VALIPI ) + (cSQLAlias)->( D1_DESPESA ) + (cSQLAlias)->( D1_SEGURO ) + (cSQLAlias)->( D1_VALFRE ) + (cSQLAlias)->( D2_ICMSRET ) // Valor Devolucao
				nVlr04 := (cSQLAlias)->( D1_TOTAL ) - (cSQLAlias)->( D1_VALDESC ) // Produtos
				nVlr05 := (cSQLAlias)->( D1_VALICM )    // ICMS Op
				if (cSQLAlias)->F4_SITTRIB  == "10" .OR. (cSQLAlias)->F4_SITTRIB  == "30" .OR. (cSQLAlias)->F4_SITTRIB  == "70"
					nVlr06 := (cSQLAlias)->( D1_ICMSRET )   // ICMS ST
				Else
					nVlr06 := 0
				Endif
				nVlr07 := (cSQLAlias)->( D1_VALIMP6 )   // PIS
				nVlr08 := (cSQLAlias)->( D1_VALIMP5 )   // COFINS
				nVlr09 := 0                             // ICMS ST (Ressar)
				nVlr10 := 0                             // ICMS OP (Ressar)
				nVlr11 := (cSQLAlias)->( D1_ICMSCOM )   // ICMS Comple.
				nVlr12 := (cSQLAlias)->( D1_DIFAL )     // ICMS Difal
				//

				If cEstEmp $ cEstResST+cEstResOP .and. (nVlr05+nVlr06) > 0 // Estado da Empresa/Filial esta entre os Estados com Ressarcimentos
				   cQuery := "  SELECT SD1.D1_ICMSRET , SD1.D1_VALICM , SD1.D1_QUANT FROM "+cNamSD1+" SD1 "
				   cQuery += "    JOIN "+cNamSF4+" SF4 ON ( SF4.F4_FILIAL = '"+cFilSF4+"' AND SF4.F4_CODIGO = SD1.D1_TES AND ( SF4.F4_OPEMOV = '01' OR SF4.F4_OPEMOV = '03' ) AND SF4.D_E_L_E_T_=' ' ) "
				   cQuery += "   WHERE SD1.D1_FILIAL='"+cFilSD1+"' AND SD1.D1_COD='"+(cSQLAlias)->( D2_COD )+"' AND SD1.D1_DTDIGIT<='"+(cSQLAlias)->( F2_EMISSAO )+"' AND SD1.D1_ICMSRET > 0 AND SD1.D_E_L_E_T_=' ' "
				   cQuery += "ORDER BY SD1.D1_DTDIGIT DESC "
				   dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlSD1, .F., .T. )
					 conout(cQuery)
				   If !(cSQLAlSD1)->(Eof())
				   	  If cEstEmp $ cEstResST
				         nVlr09 := ( ( (cSQLAlSD1)->( D1_ICMSRET ) / (cSQLAlSD1)->( D1_QUANT ) ) * (cSQLAlias)->( D2_QUANT ) ) // ICMS ST (Ressar)
		 			  Endif
				   	  If cEstEmp $ cEstResOP
				      	 nVlr10 := ( ( (cSQLAlSD1)->( D1_VALICM  ) / (cSQLAlSD1)->( D1_QUANT ) ) * (cSQLAlias)->( D2_QUANT ) ) // ICMS OP (Ressar)
				   	  EndIf
				   Endif
			       (cSQLAlSD1)->(dbCloseArea())
				EndIf

				//
				nVlr13 := (cSQLAlias)->( D1_VALDESC )   // Desconto
				nVlr14 := (cSQLAlias)->( D1_VALFRE ) + (cSQLAlias)->( D1_DESPESA )    // Frete + Desp
				nVlr16 := (cSQLAlias)->( D1_CUSTO )   // Valor Custo

				//////////////////////////////////////////////////////////////////////////////////////
				//                                                                                  //
				// Os valores 15 e 17 foram trocados e sใo feitos atrav้s de fun็๕es estแticas      //
				//                                                                                  //
				//////////////////////////////////////////////////////////////////////////////////////

				if cTipo == "ANA"
					lAbateu := oDevNFHlp:Abater(cFilAnt, (cSQLAlias)->(D2_ITEM), (cSQLAlias)->(D2_DOC), (cSQLAlias)->(D2_SERIE), (cSQLAlias)->(D2_COD), (cSQLAlias)->(VS3_SEQUEN), (cSQLAlias)->(D2_TOTAL))
					if ! lAbateu
						(cSQLAlias)->(dbSkip())
						loop
					endif
				endif
				
				For ni := 1 to 2
					If ni == 2
						nPos1 := 1 // Total Geral dos Vetores
					EndIf
					Do Case
						Case cTipo == "FIL" // Filiais
							For ny := 3 to 17
								aVetFilT[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								If (cSQLAlias)->( F2_PREFORI ) == cPrefBAL // Balcao
									aVetFilB[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								Else //(cSQLAlias)->( F2_PREFORI ) == cPrefOFI // Oficina
									aVetFilO[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								EndIf
							Next
						Case cTipo == "VNDE" // Vendedores
							For ny := 3 to 17
								aVetVenT[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								If (cSQLAlias)->( F2_PREFORI ) == cPrefBAL // Balcao
									aVetVenB[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								Else //(cSQLAlias)->( F2_PREFORI ) == cPrefOFI // Oficina
									aVetVenO[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								EndIf
							Next
						Case cTipo == "MARCA" // Marcas
							For ny := 3 to 17
								aVetMarT[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								If (cSQLAlias)->( F2_PREFORI ) == cPrefBAL // Balcao
									aVetMarB[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								Else //(cSQLAlias)->( F2_PREFORI ) == cPrefOFI // Oficina
									aVetMarO[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								EndIf
							Next
						Case cTipo == "DIA" // Dias
							For ny := 3 to 17
								aVetDiaT[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								If (cSQLAlias)->( F2_PREFORI ) == cPrefBAL // Balcao
									aVetDiaB[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								Else //(cSQLAlias)->( F2_PREFORI ) == cPrefOFI // Oficina
									aVetDiaO[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								EndIf
							Next
						Case cTipo == "GRP" // Grupos
							For ny := 3 to 17
								aVetGrpT[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								If (cSQLAlias)->( F2_PREFORI ) == cPrefBAL // Balcao
									aVetGrpB[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								Else //(cSQLAlias)->( F2_PREFORI ) == cPrefOFI // Oficina
									aVetGrpO[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								EndIf
							Next
						Case cTipo == "ITE" // Itens
							For ny := 3 to 17
								aVetIteT[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								If (cSQLAlias)->( F2_PREFORI ) == cPrefBAL // Balcao
									aVetIteB[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								Else //(cSQLAlias)->( F2_PREFORI ) == cPrefOFI // Oficina
									aVetIteO[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								EndIf
							Next
						Case cTipo == "ANA" // Analitico
							For ny := 3 to 17
								If (cSQLAlias)->( F2_PREFORI ) == cPrefBAL // Balcao
									aVetAnaB[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								Else //(cSQLAlias)->( F2_PREFORI ) == cPrefOFI // Oficina
									aVetAnaO[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								EndIf
							Next
						Case cTipo == "TPTT" // Oficina - Tipo de Publico / Tipo de Tempo
							For ny := 3 to 17
								aVetTPTT[nPos1,ny] -= &("nVlr"+strzero(ny,2))
								If nPos1 <> 1 // Total por Tipo de Publico / Tipo de Tempo
									aVetTPTT[nPos2,ny] -= &("nVlr"+strzero(ny,2))
								EndIf
							Next
						Case cTipo == "VEND" // Ranking Vendedores
							aVetVEND[nPos1,3] -= nVlr03 // Valor Devolucao
					EndCase
				Next

				////////////////////////////////////////////////////////////////////
				//                                                                //
				// Adi็ใo das informa็๕es a respeito do prazo m้dio de vendas PMV //
				//                                                                //
				////////////////////////////////////////////////////////////////////

				If aFiltro[24] == STR0069
					cLbl := IIF(!Empty( STOD(cQuebra1) ), DTOC(STOD(cQuebra1)), cQuebra1)// Se for data, sera mostrada quebra como uma data formato br
					If aScan(aPMVDataEnt[nPilha],{|x| x:GetValue('Quebra')+ x:GetValue('D1_LOJA')  + x:GetValue('D1_FORNECE')  + x:GetValue('D1_DOC')  + x:GetValue('D1_SERIE')  + x:GetValue('E2_FILIAL') == ;
																					  cLbl                + (cSQLAlias)->(D1_LOJA) + (cSQLAlias)->(D1_FORNECE) + (cSQLAlias)->(D1_DOC) + (cSQLAlias)->(D1_SERIE) + cFilSE2}) == 0
						AADD( aPMVDataEnt[nPilha], Mil_DataContainer():New({ ;
							{'Quebra'     , cLbl                      },;
							{'D1_LOJA'    , (cSQLAlias)->(D1_LOJA)    },;
							{'D1_FORNECE' , (cSQLAlias)->(D1_FORNECE) },;
							{'D1_DOC'     , (cSQLAlias)->(D1_DOC)     },;
							{'D1_SERIE'   , (cSQLAlias)->(D1_SERIE)   },;
							{'D1_PREFORI' , (cSQLAlias)->(F2_PREFORI) },;
							{'E2_FILIAL'  , cFilSE2                   } ;
						}))
	    			Endif
	    			Endif
				(cSQLAlias)->(dbSkip())
			EndDo
			(cSQLAlias)->(dbCloseArea())
		Next
	EndIf
Next
cFilAnt := cBkpFilAnt // Volta Empresa/Filial
Do Case
	Case cTipo == "FIL" // Filiais
		If len(aVetFilT) <= 1
			aAdd( aVetFilT , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			aAdd( aVetFilB , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			aAdd( aVetFilO , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
		Else
			aAux := {}
			For ni := 1 to len(aVetFilB)
				If aVetFilB[ni,3] <> 0
					aAdd(aAux,aClone(aVetFilB[ni]))
				EndIf
			Next
			aVetFilB := aClone(aAux)
			If len(aVetFilB) == 0
				aAdd( aVetFilB , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			EndIf
			aAux := {}
			For ni := 1 to len(aVetFilO)
				If aVetFilO[ni,3] <> 0
					aAdd(aAux,aClone(aVetFilO[ni]))
				EndIf
			Next
			aVetFilO := aClone(aAux)
			If len(aVetFilO) == 0
				aAdd( aVetFilO , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			EndIf
		EndIf
	Case cTipo == "VNDE" // Vendedores
		If len(aVetVenT) <= 1
			aAdd( aVetVenT , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			aAdd( aVetVenB , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			aAdd( aVetVenO , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
		Else
			aAux := {}
			For ni := 1 to len(aVetVenB)
				If aVetVenB[ni,3] <> 0
					aAdd(aAux,aClone(aVetVenB[ni]))
				EndIf
			Next
			aVetVenB := aClone(aAux)
			If len(aVetVenB) == 0
				aAdd( aVetVenB , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			EndIf
			aAux := {}
			For ni := 1 to len(aVetVenO)
				If aVetVenO[ni,3] <> 0
					aAdd(aAux,aClone(aVetVenO[ni]))
				EndIf
			Next
			aVetVenO := aClone(aAux)
			If len(aVetVenO) == 0
				aAdd( aVetVenO , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			EndIf
		EndIf
	Case cTipo == "MARCA" // Marcas
		If len(aVetMarT) <= 1
			aAdd( aVetMarT , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			aAdd( aVetMarB , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			aAdd( aVetMarO , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
		Else
			aAux := {}
			For ni := 1 to len(aVetMarB)
				If aVetMarB[ni,3] <> 0
					aAdd(aAux,aClone(aVetMarB[ni]))
				EndIf
			Next
			aVetMarB := aClone(aAux)
			If len(aVetMarB) == 0
				aAdd( aVetMarB , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			EndIf
			aAux := {}
			For ni := 1 to len(aVetMarO)
				If aVetMarO[ni,3] <> 0
					aAdd(aAux,aClone(aVetMarO[ni]))
				EndIf
			Next
			aVetMarO := aClone(aAux)
			If len(aVetMarO) == 0
				aAdd( aVetMarO , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			EndIf
		EndIf
	Case cTipo == "DIA" // Dias
		If len(aVetDiaT) <= 1
			aAdd( aVetDiaT , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			aAdd( aVetDiaB , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			aAdd( aVetDiaO , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
		Else
			aAux := {}
			For ni := 1 to len(aVetDiaB)
				If aVetDiaB[ni,3] <> 0
					aAdd(aAux,aClone(aVetDiaB[ni]))
				EndIf
			Next
			aVetDiaB := aClone(aAux)
			If len(aVetDiaB) == 0
				aAdd( aVetDiaB , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			EndIf
			aAux := {}
			For ni := 1 to len(aVetDiaO)
				If aVetDiaO[ni,3] <> 0
					aAdd(aAux,aClone(aVetDiaO[ni]))
				EndIf
			Next
			aVetDiaO := aClone(aAux)
			If len(aVetDiaO) == 0
				aAdd( aVetDiaO , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			EndIf
		EndIf
	Case cTipo == "GRP" // Grupos
		If len(aVetGrpT) <= 1
			aAdd( aVetGrpT , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			aAdd( aVetGrpB , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			aAdd( aVetGrpO , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
		Else
			aAux := {}
			For ni := 1 to len(aVetGrpB)
				If aVetGrpB[ni,3] <> 0
					aAdd(aAux,aClone(aVetGrpB[ni]))
				EndIf
			Next
			aVetGrpB := aClone(aAux)
			If len(aVetGrpB) == 0
				aAdd( aVetGrpB , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			EndIf
			aAux := {}
			For ni := 1 to len(aVetGrpO)
				If aVetGrpO[ni,3] <> 0
					aAdd(aAux,aClone(aVetGrpO[ni]))
				EndIf
			Next
			aVetGrpO := aClone(aAux)
			If len(aVetGrpO) == 0
				aAdd( aVetGrpO , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			EndIf
		EndIf
	Case cTipo == "ITE" // Itens
		If len(aVetIteT) <= 1
			aAdd( aVetIteT , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			aAdd( aVetIteB , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			aAdd( aVetIteO , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
		Else
			aAux := {}
			For ni := 1 to len(aVetIteB)
				If aVetIteB[ni,3] <> 0
					aAdd(aAux,aClone(aVetIteB[ni]))
				EndIf
			Next
			aVetIteB := aClone(aAux)
			If len(aVetIteB) == 0
				aAdd( aVetIteB , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			EndIf
			aAux := {}
			For ni := 1 to len(aVetIteO)
				If aVetIteO[ni,3] <> 0
					aAdd(aAux,aClone(aVetIteO[ni]))
				EndIf
			Next
			aVetIteO := aClone(aAux)
			If len(aVetIteO) == 0
				aAdd( aVetIteO , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )
			EndIf
		EndIf
	Case cTipo == "ANA" // Analitico
		If len(aVetAnaB) <= 1
			aAdd( aVetAnaB , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , "" , 0 } )
		EndIf
		If len(aVetAnaO) <= 1
			aAdd( aVetAnaO , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , "" , 0 } )
		EndIf
	Case cTipo == "TPTT" // Oficina - Tipo de Publico / Tipo de Tempo
		If len(aVetTPTT) <= 1
			aAdd( aVetTPTT , { "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 03 } )
		EndIf
	Case cTipo == "VEND" // Ranking Vendedores
		If len(aVetVEND) <= 1
			aAdd( aVetVEND , { "" , "1" , 0 , "" } )
		EndIf
EndCase
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_DIA   บ Autor ณ Andre Luis Almeida บ Data ณ  28/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Lista Dia - Pecas (Balcao/Oficina)                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DIA(cMar,cBalOfi,nLinha,cTitTotal)
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nListBox  := 1
Local i         := 0
Default cBalOfi   := "T"
Default nLinha    := 1
Default cTitTotal := STR0035 // Total Geral
If nLinha == 1 // Total
	cMar := ""
EndIf
FS_GRVFILTR(aFiltro[14],cBalOfi,aFiltro[16],cMar,"","","","DIA") // Filial / TotalBalcaoOficina / Vendedor / Marca / Dia / Grupo / Item / TelaAtual
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Total
If aFiltro[15] == "T" // Total ( mostra todos os Listbox )
	aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Balcao
	aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Oficina
EndIf
aPos := MsObjSize( aInfo, aObjects )
FS_MONTAVET("DIA",cTitTotal) // Monta Vetores dos Dias
DEFINE MSDIALOG oConPecDia FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (cCadastro+" - "+STR0003) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Dias

	oFWLayDia := FWLayer():New()
	oFWLayDia:Init(oConPecDia,.F.)

	If aFiltro[15] == "T"
		oFWLayDia:AddLine('LINE_TOP',30,.F.)
		oFWLayDia:AddLine('LINE_MIDDLE',30,.F.)
		oFWLayDia:AddLine('LINE_BOTTOM',30,.F.)
		oWINDia_TOP := oFWLayDia:GetLinePanel('LINE_TOP')
		oWINDia_MID := oFWLayDia:GetLinePanel('LINE_MIDDLE')
		oWINDia_BOT := oFWLayDia:GetLinePanel('LINE_BOTTOM')
	ElseIf aFiltro[15] == "B"
		oFWLayDia:AddLine('LINE_MIDDLE',100,.F.)
		oWINDia_MID := oFWLayDia:GetLinePanel('LINE_MIDDLE')
	ElseIf aFiltro[15] == "O"
		oFWLayDia:AddLine('LINE_BOTTOM',100,.F.)
		oWINDia_BOT := oFWLayDia:GetLinePanel('LINE_BOTTOM')
	EndIf

////////////////////////////////
// TOTAL ( BALCAO + OFICINA ) //
////////////////////////////////
If aFiltro[15] == "T" // Total ( mostra todos os Listbox )

	aTelaTDia := {}
	For i := 1 to Len(aVetDiaT)
		aAdd(aTelaTDia,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetDiaT[i,01])+IIf(!Empty(aVetDiaT[i,02])," - "+aVetDiaT[i,02],"") ,; //Filial
			Transform(aVetDiaT[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetDiaT[i,03]/aVetDiaT[1,03])*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetDiaT[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetDiaT[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetDiaT[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetDiaT[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetDiaT[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetDiaT[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetDiaT[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetDiaT[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetDiaT[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetDiaT[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetDiaT[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetDiaT[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetDiaT[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetDiaT[i]) - OC47DespCompra(aVetDiaT[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetDiaT[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetDiaT[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetDiaT[i],"FatLiq"), OC47DespCompra(aVetDiaT[i]), aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetDiaT[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( 'Todos', aVetDiaT, i ),; //PMV
			Transform(OC47PercResult( aVetDiaT[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseTDia := FWBrowse():New()
	oBrowseTDia:SetOwner(oWINDia_TOP)
	oBrowseTDia:SetProfileID(oBrowseTot:GetProfileID()) //Utiliza a configura็ใo do primeiro browse
	oBrowseTDia:SetDataArray()
	//oBrowseTDia:SetDescription("Dia")
	oBrowseTDia:SetColumns(MontCol("oBrowseTDia",aBrowse,STR0036))
	oBrowseTDia:SetArray(aTelaTDia)
	oBrowseTDia:Activate() // Ativa็ใo do Browse
	oBrowseTDia:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseTDia:SetDoubleClick( { || FS_GRP(aVetDiaT[oBrowseTDia:At(),01],"T",oBrowseTDia:At(),Alltrim(cTitTotal)+IIf(Alltrim(cTitTotal)<>Alltrim(aVetDiaT[oBrowseTDia:At(),01])," - "+Alltrim(aVetDiaT[oBrowseTDia:At(),01])+IIf(!Empty(aVetDiaT[oBrowseTDia:At(),02])," - "+Alltrim(aVetDiaT[oBrowseTDia:At(),02]),""),"")) } )
	oBrowseTDia:Refresh()
	oBrowseTDia:GoTop()

EndIf
////////////////////////////////
// BALCAO                     //
////////////////////////////////
If aFiltro[15] == "T" .or. aFiltro[15] == "B" // Total ( mostra todos os Listbox ) ou Balcao
	If aFiltro[15] == "T"
		nListBox := 2 // 2o.ListBox
	Else
		nListBox := 1 // Somente 1 ListBox
	EndIf
	aTelaBDia := {}
	For i := 1 to Len(aVetDiaB)
		aAdd(aTelaBDia,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetDiaB[i,01])+IIf(!Empty(aVetDiaB[i,02])," - "+aVetDiaB[i,02],"") ,; //Filial
			Transform(aVetDiaB[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetDiaB[i,03]/IIf(nListBox<>1.and.i==1,aVetDiaB[1,03],aVetDiaB[1,03]))*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetDiaB[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetDiaB[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetDiaB[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetDiaB[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetDiaB[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetDiaB[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetDiaB[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetDiaB[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetDiaB[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetDiaB[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetDiaB[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetDiaB[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetDiaB[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetDiaB[i]) - OC47DespCompra(aVetDiaB[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetDiaB[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetDiaB[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetDiaB[i],"FatLiq"), OC47DespCompra(aVetDiaB[i]), aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetDiaB[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( cPrefBAL, aVetDiaB, i ),; //PMV
			Transform(OC47PercResult( aVetDiaB[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseBDia := FWBrowse():New()
	oBrowseBDia:SetOwner(oWINDia_MID)
	oBrowseBDia:SetProfileID(oBrowseBal:GetProfileID())
	oBrowseBDia:SetDataArray()
	//oBrowseBDia:SetDescription("Dia")
	oBrowseBDia:SetColumns(MontCol("oBrowseBDia",aBrowse,STR0037))
	oBrowseBDia:SetArray(aTelaBDia)
	oBrowseBDia:Activate() // Ativa็ใo do Browse
	oBrowseBDia:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseBDia:SetDoubleClick( { || FS_GRP(aVetDiaB[oBrowseBdia:At(),01],"B",oBrowseBdia:At(),Alltrim(cTitTotal)+IIf(Alltrim(cTitTotal)<>Alltrim(aVetDiaB[oBrowseBdia:At(),01])," - "+Alltrim(aVetDiaB[oBrowseBdia:At(),01])+IIf(!Empty(aVetDiaB[oBrowseBdia:At(),02])," - "+Alltrim(aVetDiaB[oBrowseBdia:At(),02]),""),"")) } )
	oBrowseBDia:Refresh()
	oBrowseBDia:GoTop()

EndIf
////////////////////////////////
// OFICINA                    //
////////////////////////////////
If aFiltro[15] == "T" .or. aFiltro[15] == "O" // Total ( mostra todos os Listbox ) ou Oficina
	If aFiltro[15] == "T"
		nListBox := 3 // 3o.ListBox
	Else
		nListBox := 1 // Somente 1 ListBox
	EndIf
	aTelaODia := {}
	For i := 1 to Len(aVetDiaO)
		aAdd(aTelaODia,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetDiaO[i,01])+IIf(!Empty(aVetDiaO[i,02])," - "+aVetDiaO[i,02],"") ,; //Filial
			Transform(aVetDiaO[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetDiaO[i,03]/IIf(nListBox<>1.and.i==1,aVetDiaO[1,03],aVetDiaO[1,03]))*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetDiaO[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetDiaO[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetDiaO[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetDiaO[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetDiaO[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetDiaO[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetDiaO[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetDiaO[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetDiaO[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetDiaO[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetDiaO[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetDiaO[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetDiaO[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetDiaO[i]) - OC47DespCompra(aVetDiaO[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetDiaO[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetDiaO[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetDiaO[i],"FatLiq"), OC47DespCompra(aVetDiaO[i]), aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetDiaO[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( cPrefOFI, aVetDiaO, i ),; //PMV
			Transform(OC47PercResult( aVetDiaO[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseODia := FWBrowse():New()
	oBrowseODia:SetOwner(oWINDia_BOT)
	oBrowseODia:SetProfileID(oBrowseOfi:GetProfileID())
	oBrowseODia:SetDataArray()
	//oBrowseODia:SetDescription("Dia")
	oBrowseODia:SetColumns(MontCol("oBrowseODia",aBrowse,STR0038))
	oBrowseODia:SetArray(aTelaODia)
	oBrowseODia:Activate() // Ativa็ใo do Browse
	oBrowseODia:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseODia:SetDoubleClick( { || FS_GRP(aVetDiaO[oBrowseODia:At(),01],"O",oBrowseODia:At(),Alltrim(cTitTotal)+IIf(Alltrim(cTitTotal)<>Alltrim(aVetDiaO[oBrowseODia:At(),01])," - "+Alltrim(aVetDiaO[oBrowseODia:At(),01])+IIf(!Empty(aVetDiaO[oBrowseODia:At(),02])," - "+Alltrim(aVetDiaO[oBrowseODia:At(),02]),""),"")) } )
	oBrowseODia:Refresh()
	oBrowseODia:GoTop()

EndIf
ACTIVATE MSDIALOG oConPecDia ON INIT EnchoiceBar(oConPecDia,{ || oConPecDia:End() }, { || oConPecDia:End() },,aNewBotV1)
FS_GRVFILTR(aFiltro[14],cBalOfi,aFiltro[16],"","","","","MARCA", .T.) // Filial / TotalBalcaoOficina / Vendedor / Marca / Dia / Grupo / Item / TelaAtual
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_GRP   บ Autor ณ Andre Luis Almeida บ Data ณ  29/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Lista Grupos - Pecas (Balcao/Oficina)                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GRP(cDia,cBalOfi,nLinha,cTitTotal)
Local aObjects    := {} , aInfo := {}, aPos := {}
Local aSizeHalf   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nListBox    := 1
Local i           := 0
Default cBalOfi   := "T"
Default nLinha    := 1
Default cTitTotal := STR0035 // Total Geral
If nLinha == 1 // Total
	cDia := ""
EndIf
FS_GRVFILTR(aFiltro[14],cBalOfi,aFiltro[16],aFiltro[17],cDia,"","","GRP") // Filial / TotalBalcaoOficina / Vendedor / Marca / Dia / Grupo / Item / TelaAtual
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Total
If aFiltro[15] == "T" // Total ( mostra todos os Listbox )
	aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Balcao
	aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Oficina
EndIf
aPos := MsObjSize( aInfo, aObjects )
FS_MONTAVET("GRP",cTitTotal) // Monta Vetores dos Grupos
DEFINE MSDIALOG oConPecGrp FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (cCadastro+" - "+STR0004) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Grupos

	oFWLayGRP := FWLayer():New()
	oFWLayGRP:Init(oConPecGrp,.F.)

	If aFiltro[15] == "T"
		oFWLayGRP:AddLine('LINE_TOP',30,.F.)
		oFWLayGRP:AddLine('LINE_MIDDLE',30,.F.)
		oFWLayGRP:AddLine('LINE_BOTTOM',30,.F.)
		oWINGRP_TOP := oFWLayGRP:GetLinePanel('LINE_TOP')
		oWINGRP_MID := oFWLayGRP:GetLinePanel('LINE_MIDDLE')
		oWINGRP_BOT := oFWLayGRP:GetLinePanel('LINE_BOTTOM')
	ElseIf aFiltro[15] == "B"
		oFWLayGRP:AddLine('LINE_MIDDLE',100,.F.)
		oWINGRP_MID := oFWLayGRP:GetLinePanel('LINE_MIDDLE')
	ElseIf aFiltro[15] == "O"
		oFWLayGRP:AddLine('LINE_BOTTOM',100,.F.)
		oWINGRP_BOT := oFWLayGRP:GetLinePanel('LINE_BOTTOM')
	EndIf

////////////////////////////////
// TOTAL ( BALCAO + OFICINA ) //
////////////////////////////////
If aFiltro[15] == "T" // Total ( mostra todos os Listbox )
	aTelaTGRP := {}
	For i := 1 to Len(aVetGrpT)
		aAdd(aTelaTGRP,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetGrpT[i,01])+IIf(!Empty(aVetGrpT[i,02])," - "+aVetGrpT[i,02],"") ,; //Filial
			Transform(aVetGrpT[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetGrpT[i,03]/aVetGrpT[1,03])*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetGrpT[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetGrpT[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetGrpT[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetGrpT[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetGrpT[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetGrpT[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetGrpT[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetGrpT[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetGrpT[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetGrpT[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetGrpT[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetGrpT[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetGrpT[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetGrpT[i]) - OC47DespCompra(aVetGrpT[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetGrpT[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetGrpT[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetGrpT[i],"FatLiq"), OC47DespCompra(aVetGrpT[i]), aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetGrpT[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( 'Todos', aVetGrpT, i ),; //PMV
			Transform(OC47PercResult( aVetGrpT[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseTGRP := FWBrowse():New()
	oBrowseTGRP:SetOwner(oWINGRP_TOP)
	oBrowseTGRP:SetProfileID(oBrowseTot:GetProfileID()) //Utiliza a configura็ใo do primeiro browse
	oBrowseTGRP:SetDataArray()
	//oBrowseTGRP:SetDescription("Grupo")
	oBrowseTGRP:SetColumns(MontCol("oBrowseTGRP",aBrowse,STR0039))
	oBrowseTGRP:SetArray(aTelaTGRP)
	oBrowseTGRP:Activate() // Ativa็ใo do Browse
	oBrowseTGRP:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseTGRP:SetDoubleClick( { || FS_ITE(aVetGrpT[oBrowseTGRP:At(),01],"T",oBrowseTGRP:At(),Alltrim(cTitTotal)+IIf(Alltrim(cTitTotal)<>Alltrim(aVetGrpT[oBrowseTGRP:At(),01])," - "+Alltrim(aVetGrpT[oBrowseTGRP:At(),01])+IIf(!Empty(aVetGrpT[oBrowseTGRP:At(),02])," - "+Alltrim(aVetGrpT[oBrowseTGRP:At(),02]),""),"")) } )
	oBrowseTGRP:Refresh()
	oBrowseTGRP:GoTop()

EndIf
////////////////////////////////
// BALCAO                     //
////////////////////////////////
If aFiltro[15] == "T" .or. aFiltro[15] == "B" // Total ( mostra todos os Listbox ) ou Balcao
	If aFiltro[15] == "T"
		nListBox := 2 // 2o.ListBox
	Else
		nListBox := 1 // Somente 1 ListBox
	EndIf
	aTelaBGRP := {}
	For i := 1 to Len(aVetGrpB)
		aAdd(aTelaBGRP,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetGrpB[i,01])+IIf(!Empty(aVetGrpB[i,02])," - "+aVetGrpB[i,02],"") ,; //Filial
			Transform(aVetGrpB[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetGrpB[i,03]/IIf(nListBox<>1.and.i==1,aVetGrpB[1,03],aVetGrpB[1,03]))*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetGrpB[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetGrpB[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetGrpB[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetGrpB[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetGrpB[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetGrpB[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetGrpB[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetGrpB[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetGrpB[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetGrpB[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetGrpB[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetGrpB[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetGrpB[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetGrpB[i]) - OC47DespCompra(aVetGrpB[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetGrpB[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetGrpB[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetGrpB[i],"FatLiq"), OC47DespCompra(aVetGrpB[i]), aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetGrpB[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( cPrefBAL, aVetGrpB, i ),; //PMV
			Transform(OC47PercResult( aVetGrpB[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseBGRP := FWBrowse():New()
	oBrowseBGRP:SetOwner(oWINGRP_MID)
	oBrowseBGRP:SetProfileID(oBrowseBal:GetProfileID()) //Utiliza a configura็ใo do primeiro browse
	oBrowseBGRP:SetDataArray()
//	oBrowseBGRP:SetDescription("Grupo")
	oBrowseBGRP:SetColumns(MontCol("oBrowseBGRP",aBrowse,STR0040))
	oBrowseBGRP:SetArray(aTelaBGRP)
	oBrowseBGRP:Activate() // Ativa็ใo do Browse
	oBrowseBGRP:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseBGRP:SetDoubleClick( { || FS_ITE(aVetGrpB[oBrowseBGRP:At(),01],"B",oBrowseBGRP:At(),Alltrim(cTitTotal)+IIf(Alltrim(cTitTotal)<>Alltrim(aVetGrpB[oBrowseBGRP:At(),01])," - "+Alltrim(aVetGrpB[oBrowseBGRP:At(),01])+IIf(!Empty(aVetGrpB[oBrowseBGRP:At(),08])," - "+Alltrim(aVetGrpB[oBrowseBGRP:At(),08]),""),"")) } )
	oBrowseBGRP:Refresh()
	oBrowseBGRP:GoTop()

EndIf
////////////////////////////////
// OFICINA                    //
////////////////////////////////
If aFiltro[15] == "T" .or. aFiltro[15] == "O" // Total ( mostra todos os Listbox ) ou Oficina
	If aFiltro[15] == "T"
		nListBox := 3 // 3o.ListBox
	Else
		nListBox := 1 // Somente 1 ListBox
	EndIf

	aTelaOGRP := {}
	For i := 1 to Len(aVetGrpO)
		aAdd(aTelaOGRP,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetGrpO[i,01])+IIf(!Empty(aVetGrpO[i,02])," - "+aVetGrpO[i,02],"") ,; //Filial
			Transform(aVetGrpO[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetGrpO[i,03]/IIf(nListBox<>1.and.i==1,aVetGrpO[1,03],aVetGrpO[1,03]))*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetGrpO[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetGrpO[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetGrpO[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetGrpO[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetGrpO[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetGrpO[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetGrpO[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetGrpO[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetGrpO[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetGrpO[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetGrpO[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetGrpO[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetGrpO[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetGrpO[i]) - OC47DespCompra(aVetGrpO[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetGrpO[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetGrpO[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetGrpO[i],"FatLiq"), OC47DespCompra(aVetGrpO[i]), aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetGrpO[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( cPrefOFI, aVetGrpO, i ),; //PMV
			Transform(OC47PercResult( aVetGrpO[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseOGRP := FWBrowse():New()
	oBrowseOGRP:SetOwner(oWINGRP_BOT)
	oBrowseOGRP:SetProfileID(oBrowseOfi:GetProfileID()) //Utiliza a configura็ใo do primeiro browse
	oBrowseOGRP:SetDataArray()
//	oBrowseBGRP:SetDescription("Grupo")
	oBrowseOGRP:SetColumns(MontCol("oBrowseOGRP",aBrowse,STR0041))
	oBrowseOGRP:SetArray(aTelaOGRP)
	oBrowseOGRP:Activate() // Ativa็ใo do Browse
	oBrowseOGRP:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseOGRP:SetDoubleClick( { || FS_ITE(aVetGrpO[oBrowseOGRP:At(),01],"O",oBrowseOGRP:At(),Alltrim(cTitTotal)+IIf(Alltrim(cTitTotal)<>Alltrim(aVetGrpO[oBrowseOGRP:At(),01])," - "+Alltrim(aVetGrpO[oBrowseOGRP:At(),01])+IIf(!Empty(aVetGrpO[oBrowseOGRP:At(),02])," - "+Alltrim(aVetGrpO[oBrowseOGRP:At(),02]),""),"")) } )
	oBrowseOGRP:Refresh()
	oBrowseOGRP:GoTop()

EndIf
ACTIVATE MSDIALOG oConPecGrp ON INIT EnchoiceBar(oConPecGrp,{ || oConPecGrp:End() }, { || oConPecGrp:End() },,aNewBotV1)
FS_GRVFILTR(aFiltro[14],cBalOfi,aFiltro[16],aFiltro[17],"","","","DIA", .T.) // Filial / TotalBalcaoOficina / Vendedor / Marca / Dia / Grupo / Item / TelaAtual
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_ITE   บ Autor ณ Andre Luis Almeida บ Data ณ  29/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Lista Itens - Pecas (Balcao/Oficina)                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ITE(cGrp,cBalOfi,nLinha,cTitTotal)
Local aObjects    := {} , aInfo := {}, aPos := {}
Local aSizeHalf   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nListBox    := 1
Local i           := 0
Default cBalOfi   := "T"
Default nLinha    := 1
Default cTitTotal := STR0035 // Total Geral
If nLinha == 1 // Total
	cGrp := ""
EndIf
FS_GRVFILTR(aFiltro[14],cBalOfi,aFiltro[16],aFiltro[17],aFiltro[18],cGrp,"","ITE") // Filial / TotalBalcaoOficina / Vendedor / Marca / Dia / Grupo / Item / TelaAtual
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Total
If aFiltro[15] == "T" // Total ( mostra todos os Listbox )
	aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Balcao
	aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Oficina
EndIf
aPos := MsObjSize( aInfo, aObjects )
FS_MONTAVET("ITE",cTitTotal) // Monta Vetores dos Itens
DEFINE MSDIALOG oConPecIte FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (cCadastro+" - "+STR0005) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Itens

	oFWLayITE := FWLayer():New()
	oFWLayITE:Init(oConPecIte,.F.)

	If aFiltro[15] == "T"
		oFWLayITE:AddLine('LINE_TOP',30,.F.)
		oFWLayITE:AddLine('LINE_MIDDLE',30,.F.)
		oFWLayITE:AddLine('LINE_BOTTOM',30,.F.)
		oWINITE_TOP := oFWLayITE:GetLinePanel('LINE_TOP')
		oWINITE_MID := oFWLayITE:GetLinePanel('LINE_MIDDLE')
		oWINITE_BOT := oFWLayITE:GetLinePanel('LINE_BOTTOM')
	ElseIf aFiltro[15] == "B"
		oFWLayITE:AddLine('LINE_MIDDLE',100,.F.)
		oWINITE_MID := oFWLayITE:GetLinePanel('LINE_MIDDLE')
	ElseIf aFiltro[15] == "O"
		oFWLayITE:AddLine('LINE_BOTTOM',100,.F.)
		oWINITE_BOT := oFWLayITE:GetLinePanel('LINE_BOTTOM')
	EndIf
////////////////////////////////
// TOTAL ( BALCAO + OFICINA ) //
////////////////////////////////
If aFiltro[15] == "T" // Total ( mostra todos os Listbox )
	aTelaTIte := {}
	For i := 1 to Len(aVetIteT)
		aAdd(aTelaTIte,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetIteT[i,01])+IIf(!Empty(aVetIteT[i,02])," - "+aVetIteT[i,02],"") ,; //Filial
			Transform(aVetIteT[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetIteT[i,03]/aVetIteT[1,03])*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetIteT[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetIteT[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetIteT[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetIteT[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetIteT[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetIteT[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetIteT[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetIteT[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetIteT[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetIteT[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetIteT[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetIteT[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetIteT[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetIteT[i]) - OC47DespCompra(aVetIteT[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetIteT[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetIteT[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetIteT[i],"FatLiq"), OC47DespCompra(aVetIteT[i]), aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetIteT[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( 'Todos', aVetIteT, i ),; //PMV
			Transform(OC47PercResult( aVetIteT[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseTITE := FWBrowse():New()
	oBrowseTITE:SetOwner(oWINITE_TOP)
	oBrowseTITE:SetProfileID(oBrowseTot:GetProfileID()) //Utiliza a configura็ใo do primeiro browse
	oBrowseTITE:SetDataArray()
	//oBrowseTITE:SetDescription("Item")
	oBrowseTITE:SetColumns(MontCol("oBrowseTITE",aBrowse,STR0042))
	oBrowseTITE:SetArray(aTelaTIte)
	oBrowseTITE:Activate() // Ativa็ใo do Browse
	oBrowseTITE:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseTITE:SetDoubleClick( { || FS_ANA(aVetIteT[oBrowseTITE:At(),01],"T",oBrowseTITE:At(),Alltrim(cTitTotal)+IIf(Alltrim(cTitTotal)<>Alltrim(aVetIteT[oBrowseTITE:At(),01])," - "+Alltrim(aVetIteT[oBrowseTITE:At(),01])+IIf(!Empty(aVetIteT[oBrowseTITE:At(),02])," - "+Alltrim(aVetIteT[oBrowseTITE:At(),02]),""),"")) } )
	oBrowseTITE:Refresh()
	oBrowseTITE:GoTop()

EndIf
////////////////////////////////
// BALCAO                     //
////////////////////////////////
If aFiltro[15] == "T" .or. aFiltro[15] == "B" // Total ( mostra todos os Listbox ) ou Balcao
	If aFiltro[15] == "T"
		nListBox := 2 // 2o.ListBox
	Else
		nListBox := 1 // Somente 1 ListBox
	EndIf
	aTelaBIte := {}
	For i := 1 to Len(aVetIteB)
		aAdd(aTelaBIte,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetIteB[i,01])+IIf(!Empty(aVetIteB[i,02])," - "+aVetIteB[i,02],"") ,; //Filial
			Transform(aVetIteB[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetIteB[i,03]/IIf(nListBox<>1.and.i==1,aVetIteB[1,03],aVetIteB[1,03]))*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetIteB[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetIteB[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetIteB[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetIteB[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetIteB[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetIteB[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetIteB[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetIteB[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetIteB[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetIteB[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetIteB[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetIteB[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetIteB[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetIteB[i]) - OC47DespCompra(aVetIteB[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetIteB[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetIteB[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetIteB[i],"FatLiq"), OC47DespCompra(aVetIteB[i]), aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetIteB[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( cPrefBAL, aVetIteB, i ),; //PMV
			Transform(OC47PercResult( aVetIteB[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseBITE := FWBrowse():New()
	oBrowseBITE:SetOwner(oWINITE_MID)
	oBrowseBITE:SetProfileID(oBrowseBal:GetProfileID()) //Utiliza a configura็ใo do primeiro browse
	oBrowseBITE:SetDataArray()
//	oBrowseBITE:SetDescription("Item")
	oBrowseBITE:SetColumns(MontCol("oBrowseBITE",aBrowse,STR0043))
	oBrowseBITE:SetArray(aTelaBIte)
	oBrowseBITE:Activate() // Ativa็ใo do Browse
	oBrowseBITE:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseBITE:SetDoubleClick( { || FS_ANA(aVetIteB[oBrowseBITE:At(),01],"B",oBrowseBITE:At(),Alltrim(cTitTotal)+IIf(Alltrim(cTitTotal)<>Alltrim(aVetIteB[oBrowseBITE:At(),01])," - "+Alltrim(aVetIteB[oBrowseBITE:At(),01])+IIf(!Empty(aVetIteB[oBrowseBITE:At(),08])," - "+Alltrim(aVetIteB[oBrowseBITE:At(),08]),""),"")) } )
	oBrowseBITE:Refresh()
	oBrowseBITE:GoTop()

EndIf
////////////////////////////////
// OFICINA                    //
////////////////////////////////
If aFiltro[15] == "T" .or. aFiltro[15] == "O" // Total ( mostra todos os Listbox ) ou Oficina
	If aFiltro[15] == "T"
		nListBox := 3 // 3o.ListBox
	Else
		nListBox := 1 // Somente 1 ListBox
	EndIf
	aTelaOIte := {}
	For i := 1 to Len(aVetIteO)
		aAdd(aTelaOIte,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetIteO[i,01])+IIf(!Empty(aVetIteO[i,02])," - "+aVetIteO[i,02],"") ,; //Filial
			Transform(aVetIteO[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetIteO[i,03]/IIf(nListBox<>1.and.i==1,aVetIteO[1,03],aVetIteO[1,03]))*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetIteO[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetIteO[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetIteO[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetIteO[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetIteO[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetIteO[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetIteO[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetIteO[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetIteO[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetIteO[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetIteO[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetIteO[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetIteO[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetIteO[i]) - OC47DespCompra(aVetIteO[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetIteO[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetIteO[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetIteO[i],"FatLiq"), OC47DespCompra(aVetIteO[i]), aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetIteO[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( cPrefOFI, aVetIteO, i ),; //PMV
			Transform(OC47PercResult( aVetIteO[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseOITE := FWBrowse():New()
	oBrowseOITE:SetOwner(oWINITE_BOT)
	oBrowseOITE:SetProfileID(oBrowseOfi:GetProfileID()) //Utiliza a configura็ใo do primeiro browse
	oBrowseOITE:SetDataArray()
//	oBrowseBITE:SetDescription("Item")
	oBrowseOITE:SetColumns(MontCol("oBrowseOITE",aBrowse,STR0044))
	oBrowseOITE:SetArray(aTelaOIte)
	oBrowseOITE:Activate() // Ativa็ใo do Browse
	oBrowseOITE:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseOITE:SetDoubleClick( { || FS_ANA(aVetIteO[oBrowseOITE:At(),01],"O",oBrowseOITE:At(),Alltrim(cTitTotal)+IIf(Alltrim(cTitTotal)<>Alltrim(aVetIteO[oBrowseOITE:At(),01])," - "+Alltrim(aVetIteO[oBrowseOITE:At(),01])+IIf(!Empty(aVetIteO[oBrowseOITE:At(),02])," - "+Alltrim(aVetIteO[oBrowseOITE:At(),02]),""),"")) } )
	oBrowseOITE:Refresh()
	oBrowseOITE:GoTop()

EndIf
ACTIVATE MSDIALOG oConPecIte ON INIT EnchoiceBar(oConPecIte,{ || oConPecIte:End() }, { || oConPecIte:End() },,aNewBotV2)
FS_GRVFILTR(aFiltro[14],cBalOfi,aFiltro[16],aFiltro[17],aFiltro[18],"","","GRP", .T.) // Filial / TotalBalcaoOficina / Vendedor / Marca / Dia / Grupo / Item / TelaAtual
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_ANA   บ Autor ณ Andre Luis Almeida บ Data ณ  30/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Lista Analiticamente (Orcamento/OS)- Pecas (Balcao/Oficina)บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ANA(cIte,cBalOfi,nLinha,cTitTotal)
Local   aObjects  := {} , aInfo := {}, aPos := {}
Local   aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local i           := 0
Default cBalOfi   := "T"
Default nLinha    := 1
Default cTitTotal := STR0035 // Total Geral
If nLinha == 1 // Total
	cIte := ""
EndIf
FS_GRVFILTR(aFiltro[14],cBalOfi,aFiltro[16],aFiltro[17],aFiltro[18],aFiltro[19],cIte,"ANA") // Filial / TotalBalcaoOficina / Vendedor / Marca / Dia / Grupo / Item / TelaAtual
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
If aFiltro[15] == "T" // Total ( mostra todos os Listbox )
	aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Balcao     50%
	aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Oficina    50%
ElseIf aFiltro[15] == "B" // Total ( mostra o Listbox Balcao )
	aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Balcao    100%
	aAdd( aObjects, { 0 , 0 , .T. , .F. } ) // ListBox Oficina     0%
ElseIf aFiltro[15] == "O" // Total ( mostra o Listbox Oficina )
	aAdd( aObjects, { 0 , 0 , .T. , .F. } ) // ListBox Balcao      0%
	aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Oficina   100%
EndIf
aPos := MsObjSize( aInfo, aObjects )
FS_MONTAVET("ANA",cTitTotal) // Monta Vetores Analitico ( Orcamentos / OSs )
DEFINE MSDIALOG oConPecAna FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (cCadastro+" - "+STR0006) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Analitico

	oFWLayANA := FWLayer():New()
	oFWLayANA:Init(oConPecAna,.F.)
	If aFiltro[15] == "T"
		oFWLayANA:AddLine('LINE_TOP',50,.F.)
		oFWLayANA:AddLine('LINE_MIDDLE',50,.F.)
		oWINANA_TOP := oFWLayANA:GetLinePanel('LINE_TOP')
		oWINANA_MID := oFWLayANA:GetLinePanel('LINE_MIDDLE')
	ElseIf aFiltro[15] == "B"
		oFWLayANA:AddLine('LINE_TOP',100,.F.)
		oWINANA_TOP := oFWLayANA:GetLinePanel('LINE_TOP')
	ElseIf aFiltro[15] == "O"
		oFWLayANA:AddLine('LINE_MIDDLE',100,.F.)
		oWINANA_MID := oFWLayANA:GetLinePanel('LINE_MIDDLE')
	EndIf

////////////////////////////////
// BALCAO       // 1o.ListBox //
////////////////////////////////
If aFiltro[15] == "T" .or. aFiltro[15] == "B"
	aTelaBANA := {}
	For i := 1 to Len(aVetAnaB)
		aAdd(aTelaBANA,{;
			IIf(i<>1,space(3),aVetAnaB[i,01])+aVetAnaB[i,02] ,; //Filial
			Transform(aVetAnaB[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetAnaB[i,03]/aVetAnaB[1,03])*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetAnaB[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetAnaB[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetAnaB[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetAnaB[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetAnaB[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetAnaB[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetAnaB[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetAnaB[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetAnaB[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetAnaB[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetAnaB[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetAnaB[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetAnaB[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetAnaB[i]) - OC47DespCompra(aVetAnaB[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetAnaB[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetAnaB[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetAnaB[i],"FatLiq"), OC47DespCompra(aVetAnaB[i]), aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetAnaB[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( cPrefBAL, aVetAnaB, i ),; //PMV
			Transform(OC47PercResult( aVetAnaB[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseBANA := FWBrowse():New()
	oBrowseBANA:SetOwner(oWINANA_TOP)
	oBrowseBANA:SetProfileID(oBrowseBal:GetProfileID()) //Utiliza a configura็ใo do primeiro browse
	oBrowseBANA:SetDataArray()
	//oBrowseBANA:SetDescription("Analitico")
	oBrowseBANA:SetColumns(MontCol("oBrowseBANA",aBrowse,STR0045))
	oBrowseBANA:SetArray(aTelaBANA)
	oBrowseBANA:Activate() // Ativa็ใo do Browse
	oBrowseBANA:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseBANA:SetDoubleClick( { || FS_VISUAL(aVetAnaB[oBrowseBANA:At(),01],"B",oBrowseBANA:At(),aVetAnaB[oBrowseBANA:At(),18]) } )
	oBrowseBANA:Refresh()
	oBrowseBANA:GoTop()

EndIf
////////////////////////////////
// OFICINA      // 2o.ListBox //
////////////////////////////////
If aFiltro[15] == "T" .or. aFiltro[15] == "O"
	aTelaOANA := {}
	For i := 1 to Len(aVetAnaO)
		aAdd(aTelaOANA,{;
			IIf(i<>1,space(3),aVetAnaO[i,01])+aVetAnaO[i,02] ,; //Filial
			Transform(aVetAnaO[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetAnaO[i,03]/aVetAnaO[1,03])*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetAnaO[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetAnaO[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetAnaO[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetAnaO[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetAnaO[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetAnaO[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetAnaO[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetAnaO[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetAnaO[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetAnaO[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetAnaO[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetAnaO[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetAnaO[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetAnaO[i]) - OC47DespCompra(aVetAnaO[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetAnaO[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetAnaO[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetAnaO[i],"FatLiq"), OC47DespCompra(aVetAnaO[i]), aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetAnaO[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( cPrefOFI, aVetAnaO, i ),; //PMV
			Transform(OC47PercResult( aVetAnaO[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseOANA := FWBrowse():New()
	oBrowseOANA:SetOwner(oWINANA_MID)
	oBrowseOANA:SetProfileID(oBrowseOfi:GetProfileID()) //Utiliza a configura็ใo do primeiro browse
	oBrowseOANA:SetDataArray()
	//oBrowseOANA:SetDescription("Analitico")
	oBrowseOANA:SetColumns(MontCol("oBrowseOANA",aBrowse,STR0046))
	oBrowseOANA:SetArray(aTelaOANA)
	oBrowseOANA:Activate() // Ativa็ใo do Browse
	oBrowseOANA:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseOANA:SetDoubleClick( { || FS_VISUAL(aVetAnaO[oBrowseOANA:At(),01],"O",oBrowseOANA:At(),aVetAnaO[oBrowseOANA:At(),18]) } )
	oBrowseOANA:Refresh()
	oBrowseOANA:GoTop()

EndIf
ACTIVATE MSDIALOG oConPecAna ON INIT EnchoiceBar(oConPecAna,{ || oConPecAna:End() }, { || oConPecAna:End() },,aNewBotV2)
FS_GRVFILTR(aFiltro[14],cBalOfi,aFiltro[16],aFiltro[17],aFiltro[18],aFiltro[19],"","ITE", .T.) // Filial / TotalBalcaoOficina / Vendedor / Marca / Dia / Grupo / Item / TelaAtual
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_VNDE  บ Autor ณ Renato Vinicius    บ Data ณ  16/06/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Lista Vendedores - Pecas (Balcao/Oficina)                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VNDE(cFil,cBalOfi,nLinha,cTitTotal)
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)

Local i         := 0
Default cBalOfi   := "T"
Default nLinha    := 1
Default cTitTotal := STR0035 // Total Geral
If nLinha == 1 // Total
	cFil := ""
EndIf
FS_GRVFILTR(cFil,cBalOfi,"","","","","","VNDE") // Filial / TotalBalcaoOficina / Vendedor / Marca / Dia / Grupo / Item / TelaAtual
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Total
If aFiltro[15] == "T" // Total ( mostra todos os Listbox )
	aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Balcao
	aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Oficina
EndIf
aPos := MsObjSize( aInfo, aObjects )
FS_MONTAVET("VNDE",cTitTotal) // Monta Vetores dos Vendedores
DEFINE MSDIALOG oConPecVen FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (cCadastro+" - "+STR0003) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Vendedores

	oFWLayVen := FWLayer():New()
	oFWLayVen:Init(oConPecVen,.F.)
	If aFiltro[15] == "T"
		oFWLayVen:AddLine('LINE_TOP',30,.F.)
		oFWLayVen:AddLine('LINE_MIDDLE',30,.F.)
		oFWLayVen:AddLine('LINE_BOTTOM',30,.F.)
		oWINVen_TOP := oFWLayVen:GetLinePanel('LINE_TOP')
		oWINVen_MID := oFWLayVen:GetLinePanel('LINE_MIDDLE')
		oWINVen_BOT := oFWLayVen:GetLinePanel('LINE_BOTTOM')
	ElseIf aFiltro[15] == "B"
		oFWLayVen:AddLine('LINE_MIDDLE',100,.F.)
		oWINVen_MID := oFWLayVen:GetLinePanel('LINE_MIDDLE')
	ElseIf aFiltro[15] == "O"
		oFWLayVen:AddLine('LINE_BOTTOM',100,.F.)
		oWINVen_BOT := oFWLayVen:GetLinePanel('LINE_BOTTOM')
	EndIf

////////////////////////////////
// TOTAL ( BALCAO + OFICINA ) //
////////////////////////////////
If aFiltro[15] == "T" // Total ( mostra todos os Listbox )
	aTelaTVen := {}
	For i := 1 to Len(aVetVenT)
		aAdd(aTelaTVen,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetVenT[i,01])+IIf(!Empty(aVetVenT[i,02])," - "+aVetVenT[i,02],"") ,; //Filial
			Transform(aVetVenT[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetVenT[i,03]/aVetVenT[1,03])*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetVenT[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetVenT[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetVenT[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetVenT[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetVenT[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetVenT[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetVenT[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetVenT[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetVenT[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetVenT[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetVenT[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetVenT[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetVenT[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetVenT[i]) - OC47DespCompra(aVetVenT[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetVenT[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetVenT[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetVenT[i],"FatLiq") , OC47DespCompra(aVetVenT[i]) , aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetVenT[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( 'Todos', aVetVenT, i ),; //PMV
			Transform(OC47PercResult( aVetVenT[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseTVen := FWBrowse():New()
	oBrowseTVen:SetOwner(oWINVen_TOP)
	oBrowseTVen:SetProfileID(oBrowseTot:GetProfileID()) //Utiliza a configura็ใo do primeiro browse
	oBrowseTVen:SetDataArray()
	//oBrowseTVen:SetDescription("Vendedor")
	oBrowseTVen:SetColumns(MontCol("oBrowseTVen",aBrowse,STR0073))
	oBrowseTVen:SetArray(aTelaTVen)
	oBrowseTVen:Activate() // Ativa็ใo do Browse
	oBrowseTVen:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseTVen:SetDoubleClick( { || FS_MARCA(aVetVenT[oBrowseTVen:At(),01],"T",oBrowseTVen:At(),Alltrim(cTitTotal)+IIf(Alltrim(cTitTotal)<>Alltrim(aVetVenT[oBrowseTVen:At(),01])," - "+Alltrim(aVetVenT[oBrowseTVen:At(),01])+IIf(!Empty(aVetVenT[oBrowseTVen:At(),02])," - "+Alltrim(aVetVenT[oBrowseTVen:At(),02]),""),"")) } )
	oBrowseTVen:Refresh()
	oBrowseTVen:GoTop()

EndIf
////////////////////////////////
// BALCAO                     //
////////////////////////////////
If aFiltro[15] == "T" .or. aFiltro[15] == "B" // Total ( mostra todos os Listbox ) ou Balcao
	aTelaBVen := {}
	For i := 1 to Len(aVetVenB)
		aAdd(aTelaBVen,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetVenB[i,01])+IIf(!Empty(aVetVenB[i,02])," - "+aVetVenB[i,02],"") ,; //Filial
			Transform(aVetVenB[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetVenB[i,03]/IIf(aFiltro[15] == "T".and.i==1,aVetVenB[1,03],aVetVenB[1,03]))*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetVenB[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetVenB[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetVenB[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetVenB[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetVenB[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetVenB[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetVenB[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetVenB[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetVenB[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetVenB[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetVenB[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetVenB[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetVenB[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetVenB[i]) - OC47DespCompra(aVetVenB[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetVenB[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetVenB[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetVenB[i],"FatLiq"), OC47DespCompra(aVetVenB[i]), aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetVenB[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( cPrefBAL, aVetVenB, i ),; //PMV
			Transform(OC47PercResult( aVetVenB[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseBVen := FWBrowse():New()
	oBrowseBVen:SetOwner(oWINVen_MID)
	oBrowseBVen:SetProfileID(oBrowseBal:GetProfileID()) //Utiliza a configura็ใo do primeiro browse
	oBrowseBVen:SetDataArray()
	//oBrowseBVen:SetDescription("Vendedor")
	oBrowseBVen:SetColumns(MontCol("oBrowseBVen",aBrowse,STR0074))
	oBrowseBVen:SetArray(aTelaBVen)
	oBrowseBVen:Activate() // Ativa็ใo do Browse
	oBrowseBVen:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseBVen:SetDoubleClick( { || FS_MARCA(aVetVenB[oBrowseBVen:At(),01],"B",oBrowseBVen:At(),Alltrim(cTitTotal)+IIf(Alltrim(cTitTotal)<>Alltrim(aVetVenB[oBrowseBVen:At(),01])," - "+Alltrim(aVetVenB[oBrowseBVen:At(),01])+IIf(!Empty(aVetVenB[oBrowseBVen:At(),02])," - "+Alltrim(aVetVenB[oBrowseBVen:At(),02]),""),"")) } )
	oBrowseBVen:Refresh()
	oBrowseBVen:GoTop()

EndIf
////////////////////////////////
// OFICINA                    //
////////////////////////////////
If aFiltro[15] == "T" .or. aFiltro[15] == "O" // Total ( mostra todos os Listbox ) ou Oficina
	aTelaOVen := {}
	For i := 1 to Len(aVetVenO)
		aAdd(aTelaOVen,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetVenO[i,01])+IIf(!Empty(aVetVenO[i,02])," - "+aVetVenO[i,02],"") ,; //Filial
			Transform(aVetVenO[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetVenO[i,03]/IIf(aFiltro[15] == "T".and.i==1,aVetVenO[1,03],aVetVenO[1,03]))*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetVenO[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetVenO[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetVenO[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetVenO[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetVenO[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetVenO[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetVenO[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetVenO[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetVenO[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetVenO[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetVenO[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetVenO[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetVenO[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetVenO[i]) - OC47DespCompra(aVetVenO[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetVenO[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetVenO[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetVenO[i],"FatLiq"), OC47DespCompra(aVetVenO[i]), aFiltro[23]),0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetVenO[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( cPrefOFI, aVetVenO, i ),; //PMV
			Transform(OC47PercResult( aVetVenO[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseOVen := FWBrowse():New()
	oBrowseOVen:SetOwner(oWINVen_BOT)
	oBrowseOVen:SetProfileID(oBrowseOfi:GetProfileID()) //Utiliza a configura็ใo do primeiro browse
	oBrowseOVen:SetDataArray()
	//oBrowseOVen:SetDescription("Vendedor")
	oBrowseOVen:SetColumns(MontCol("oBrowseOVen",aBrowse,STR0075))
	oBrowseOVen:SetArray(aTelaOVen)
	oBrowseOVen:Activate() // Ativa็ใo do Browse
	oBrowseOVen:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseOVen:SetDoubleClick( { || FS_MARCA(aVetVenO[oBrowseOVen:At(),01],"O",oBrowseOVen:At(),Alltrim(cTitTotal)+IIf(Alltrim(cTitTotal)<>Alltrim(aVetVenO[oBrowseOVen:At(),01])," - "+Alltrim(aVetVenO[oBrowseOVen:At(),01])+IIf(!Empty(aVetVenO[oBrowseOVen:At(),02])," - "+Alltrim(aVetVenO[oBrowseOVen:At(),02]),""),"")) } )
	oBrowseOVen:Refresh()
	oBrowseOVen:GoTop()

EndIf

ACTIVATE MSDIALOG oConPecVen ON INIT EnchoiceBar(oConPecVen,{ || oConPecVen:End() }, { || oConPecVen:End() },,aNewBotV1)
FS_GRVFILTR(cFil,"T","","","","","","FIL", .T.) // Filial / TotalBalcaoOficina / Vendedor / Marca / Dia / Grupo / Item / TelaAtual
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_MARCA บ Autor ณ Renato Vinicius    บ Data ณ  16/06/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Lista Marcas - Pecas (Balcao/Oficina)                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MARCA(cVen,cBalOfi,nLinha,cTitTotal)
Local aObjects    := {} , aInfo := {}, aPos := {}
Local aSizeHalf   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nListBox    := 1
Local i           := 0
Default cBalOfi   := "T"
Default nLinha    := 1
Default cTitTotal := STR0035 // Total Geral
If nLinha == 1 // Total
	cVen := ""
EndIf
FS_GRVFILTR(aFiltro[14],cBalOfi,cVen,"","","","","MARCA") // Filial / TotalBalcaoOficina / Vendedor / Marca / Dia / Grupo / Item / TelaAtual
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Total
If aFiltro[15] == "T" // Total ( mostra todos os Listbox )
	aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Balcao
	aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Oficina
EndIf
aPos := MsObjSize( aInfo, aObjects )
FS_MONTAVET("MARCA",cTitTotal) // Monta Vetores das Marcas
DEFINE MSDIALOG oConPecMar FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (cCadastro+" - "+STR0004) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Grupos

	oFWLayMar := FWLayer():New()
	oFWLayMar:Init(oConPecMar,.F.)

	If aFiltro[15] == "T"
		oFWLayMar:AddLine('LINE_TOP',30,.F.)
		oFWLayMar:AddLine('LINE_MIDDLE',30,.F.)
		oFWLayMar:AddLine('LINE_BOTTOM',30,.F.)
		oWINMar_TOP := oFWLayMar:GetLinePanel('LINE_TOP')
		oWINMar_MID := oFWLayMar:GetLinePanel('LINE_MIDDLE')
		oWINMar_BOT := oFWLayMar:GetLinePanel('LINE_BOTTOM')
	ElseIf aFiltro[15] == "B"
		oFWLayMar:AddLine('LINE_MIDDLE',100,.F.)
		oWINMar_MID := oFWLayMar:GetLinePanel('LINE_MIDDLE')
	ElseIf aFiltro[15] == "O"
		oFWLayMar:AddLine('LINE_BOTTOM',100,.F.)
		oWINMar_BOT := oFWLayMar:GetLinePanel('LINE_BOTTOM')
	EndIf

////////////////////////////////
// TOTAL ( BALCAO + OFICINA ) //
////////////////////////////////
If aFiltro[15] == "T" // Total ( mostra todos os Listbox )

	aTelaTMar := {}
	For i := 1 to Len(aVetMarT)
		aAdd(aTelaTMar,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetMarT[i,01])+IIf(!Empty(aVetMarT[i,02])," - "+aVetMarT[i,02],"") ,; //Filial
			Transform(aVetMarT[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetMarT[i,03]/aVetMarT[1,03])*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetMarT[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetMarT[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetMarT[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetMarT[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetMarT[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetMarT[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetMarT[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetMarT[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetMarT[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetMarT[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetMarT[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetMarT[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetMarT[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetMarT[i]) - OC47DespCompra(aVetMarT[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetMarT[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetMarT[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetMarT[i],"FatLiq"), OC47DespCompra(aVetMarT[i]), aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetMarT[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( 'Todos', aVetMarT, i ),; //PMV
			Transform(OC47PercResult( aVetMarT[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseTMar := FWBrowse():New()
	oBrowseTMar:SetOwner(oWINMar_TOP)
	oBrowseTMar:SetProfileID(oBrowseTot:GetProfileID()) //Utiliza a configura็ใo do primeiro browse
	oBrowseTMar:SetDataArray()
	//oBrowseTMar:SetDescription("Marca")
	oBrowseTMar:SetColumns(MontCol("oBrowseTMar",aBrowse,STR0076))
	oBrowseTMar:SetArray(aTelaTMar)
	oBrowseTMar:Activate() // Ativa็ใo do Browse
	oBrowseTMar:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseTMar:SetDoubleClick( { || FS_DIA(aVetMarT[oBrowseTMar:At(),01],"T",oBrowseTMar:At(),Alltrim(aVetMarT[oBrowseTMar:At(),01])+IIf(!Empty(aVetMarT[oBrowseTMar:At(),02])," - "+Alltrim(aVetMarT[oBrowseTMar:At(),02]),"")) } )
	oBrowseTMar:Refresh()
	oBrowseTMar:GoTop()

EndIf
////////////////////////////////
// BALCAO                     //
////////////////////////////////
If aFiltro[15] == "T" .or. aFiltro[15] == "B" // Total ( mostra todos os Listbox ) ou Balcao
	If aFiltro[15] == "T"
		nListBox := 2 // 2o.ListBox
	Else
		nListBox := 1 // Somente 1 ListBox
	EndIf

	aTelaBMar := {}
	For i := 1 to Len(aVetMarB)
		aAdd(aTelaBMar,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetMarB[i,01])+IIf(!Empty(aVetMarB[i,02])," - "+aVetMarB[i,02],"") ,; //Filial
			Transform(aVetMarB[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetMarB[i,03]/IIf(i==1,aVetMarB[1,03],aVetMarB[1,03]))*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetMarB[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetMarB[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetMarB[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetMarB[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetMarB[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetMarB[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetMarB[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetMarB[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetMarB[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetMarB[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetMarB[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetMarB[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetMarB[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetMarB[i]) - OC47DespCompra(aVetMarB[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetMarB[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetMarB[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetMarB[i],"FatLiq"), OC47DespCompra(aVetMarB[i]), aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetMarB[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( cPrefBAL, aVetMarB, i ),; //PMV
			Transform(OC47PercResult( aVetMarB[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseBMar := FWBrowse():New()
	oBrowseBMar:SetOwner(oWINMar_MID)
	oBrowseBMar:SetProfileID(oBrowseBal:GetProfileID()) //Utiliza a configura็ใo do primeiro browse
	oBrowseBMar:SetDataArray()
	//oBrowseBVen:SetDescription("Vendedor")
	oBrowseBMar:SetColumns(MontCol("oBrowseBMar",aBrowse,STR0077))
	oBrowseBMar:SetArray(aTelaBMar)
	oBrowseBMar:Activate() // Ativa็ใo do Browse
	oBrowseBMar:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseBMar:SetDoubleClick( { || FS_DIA(aVetMarB[oBrowseBMar:At(),01],"B",oBrowseBMar:At(),Alltrim(aVetMarB[oBrowseBMar:At(),01])+IIf(!Empty(aVetMarB[oBrowseBMar:At(),02])," - "+Alltrim(aVetMarB[oBrowseBMar:At(),02]),"")) } )
	oBrowseBMar:Refresh()
	oBrowseBMar:GoTop()

EndIf
////////////////////////////////
// OFICINA                    //
////////////////////////////////
If aFiltro[15] == "T" .or. aFiltro[15] == "O" // Total ( mostra todos os Listbox ) ou Oficina
	If aFiltro[15] == "T"
		nListBox := 3 // 3o.ListBox
	Else
		nListBox := 1 // Somente 1 ListBox
	EndIf

	aTelaOMar := {}
	For i := 1 to Len(aVetMarO)
		aAdd(aTelaOMar,{;
			IIf(i<>1,space(5),"")+Alltrim(aVetMarO[i,01])+IIf(!Empty(aVetMarO[i,02])," - "+aVetMarO[i,02],"") ,; //Filial
			Transform(aVetMarO[i,03],"@E 999,999,999.99") ,; //Vlr Venda
			Transform((aVetMarO[i,03]/IIf(i==1,aVetMarO[1,03],aVetMarO[1,03]))*100,"@E 9999.99")+"%" ,; //% Venda
			Transform(aVetMarO[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
			Transform(aVetMarO[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
			Transform(aVetMarO[i,06],"@E 999,999,999.99") ,; //ICMS ST
			Transform(aVetMarO[i,07],"@E 999,999,999.99") ,; //PIS
			Transform(aVetMarO[i,08],"@E 999,999,999.99") ,; //COFINS
			Transform(aVetMarO[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
			Transform(aVetMarO[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
			Transform(aVetMarO[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
			Transform(aVetMarO[i,12],"@E 999,999,999.99") ,; //ICMS Difal
			Transform(aVetMarO[i,13],"@E 999,999,999.99") ,; //DESCONTO
			Transform(aVetMarO[i,14],"@E 999,999,999.99") ,; //Frete+Desp
			Transform(OC47VlLiqVenda(aVetMarO[i]),"@E 999,999,999.99") ,; //Vlr Liquido
			Transform(aVetMarO[i,16],"@E 999,999,999.99") ,; //Custo
			Transform(OC47VlrLucro(aVetMarO[i]) - OC47DespCompra(aVetMarO[i]),"@E 999,999,999.99") ,; //Lucro Bruto
			Transform(OC47MrgBrut(aVetMarO[i]),"@E 9999.99")+'%',; //%Lucro
			Transform(OC47MrgLiq(aVetMarO[i]),"@E 9999.99")+'%',; //%Lucro Liq
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetMarO[i],"FatLiq") , OC47DespCompra(aVetMarO[i]), aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
			Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetMarO[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
			OC47Pmv( cPrefOFI, aVetMarO, i ),; //PMV
			Transform(OC47PercResult( aVetMarO[i]), "@E 9999.99") + "%"}) //%Resultado
	Next
	oBrowseOMar := FWBrowse():New()
	oBrowseOMar:SetOwner(oWINMar_BOT)
	oBrowseOMar:SetProfileID(oBrowseOfi:GetProfileID()) //Utiliza a configura็ใo do primeiro browse
	oBrowseOMar:SetDataArray()
	//oBrowseBVen:SetDescription("Vendedor")
	oBrowseOMar:SetColumns(MontCol("oBrowseOMar",aBrowse,STR0078))
	oBrowseOMar:SetArray(aTelaOMar)
	oBrowseOMar:Activate() // Ativa็ใo do Browse
	oBrowseOMar:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseOMar:SetDoubleClick( { || FS_DIA(aVetMarO[oBrowseOMar:At(),01],"O",oBrowseOMar:At(),Alltrim(aVetMarO[oBrowseOMar:At(),01])+IIf(!Empty(aVetMarO[oBrowseOMar:At(),02])," - "+Alltrim(aVetMarO[oBrowseOMar:At(),02]),"")) } )
	oBrowseOMar:Refresh()
	oBrowseOMar:GoTop()

EndIf
ACTIVATE MSDIALOG oConPecMar ON INIT EnchoiceBar(oConPecMar,{ || oConPecMar:End() }, { || oConPecMar:End() },,aNewBotV1)
FS_GRVFILTR(aFiltro[14],cBalOfi,"","","","","","VNDE", .T.) // Filial / TotalBalcaoOficina / Vendedor / Marca / Dia / Grupo / Item / TelaAtual
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VISUAL บ Autor ณ Andre Luis Almeida บ Data ณ  30/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Visualiza Orcamento (Balcao) e OS (Oficina)                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VISUAL(cSeek,cBalOfi,nLinha,cFilVisual)
Local   cFilSALVA := cFilAnt
Local   cCadSALVA := cCadastro
Private cCampo, nOpc := 2 , inclui := .f. // variaveis utilizadas na Consulta de OS
Default cSeek     := ""
Default cBalOfi   := ""
Default nLinha    := 0
If nLinha > 1 .and. !Empty(cSeek)
	cFilAnt := cFilVisual // Filial para visualizacao
	If cBalOfi == "B" // Balcao (Orcamento)
		cCadastro := STR0047 // Orcamento
		DbSelectArea("VS1")
		DbSetOrder(3)
		If DbSeek( xFilial("VS1") + substr(cSeek,TamSx3("D2_FILIAL")[1]+1) )
			OFIC170( VS1->VS1_FILIAL , VS1->VS1_NUMORC )
		EndIf
	ElseIf cBalOfi == "O" // Oficina (OS)
		aRotina := { { "" ,"axPesqui", 0 , 1},; // Pesquisar
		{ "" , "OC060" , 0 , 2 }} // Visualizar
		cCadastro := STR0048 // Consulta OS
		VOO->(dbSetOrder(4))
		VOO->(DbSeek( xFilial("VOO") + substr(cSeek,TamSx3("D2_FILIAL")[1]+1) ))
		DbSelectArea("VO1")
		DbSetOrder(1)
		If DbSeek( VOO->VOO_FILIAL + VOO->VOO_NUMOSV )
			OC060("VO1",VO1->(RECNO()),2)
		EndIf
	EndIf
EndIf
cCadastro := cCadSALVA
cFilAnt := cFilSALVA
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRVFILTRบ Autor ณ Andre Luis Almeida บ Data ณ  29/06/11  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณGrava parametros do Filtro (Filial/Tipo/Dia/Grupo/Item/Tela)บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GRVFILTR(cFil,cTBO,cVen,cMar,cDia,cGrp,cIte,cTla, lFechaTela)
Default lFechaTela := .F.

aFiltro[14] := cFil // Filial
aFiltro[15] := cTBO // T-otal / B-alcao / O-ficina
aFiltro[16] := cVen // Vendedor
aFiltro[17] := cMar // Marca
aFiltro[18] := cDia // Dia
aFiltro[19] := cGrp // Grupo
aFiltro[20] := cIte // Item
aFiltro[21] := cTla // Tela Atual

If lFechaTela
	OC47RetPilha()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณOC47RetPilha Autor ณ Andre Luis Almeida บ Data ณ  29/06/11  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Controle de pilha de dados do PMV                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OC47RetPilha()
	nPilha := nPilha - 1
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_TPTT  บ Autor ณ Andre Luis Almeida บ Data ณ  06/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Lista Oficina Analiticamente por Tipo Publico / Tipo Tempo บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TPTT()
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cSlvTela  := aFiltro[21] // Tela Atual
Local cTitTela  := ""
Local lOk       := .f.
Local i         := 0
If aFiltro[21] <> "TPTT" // diferente de ( Oficina - Tipo de Publico / Tipo de Tempo )
	Do Case
		Case aFiltro[21] == "FIL" // Filiais - Oficina
			If len(aVetFilO) > 1
				lOk := .t.
				cTitTela := Alltrim(aVetFilO[1,01])+IIf(!Empty(aVetFilO[1,02])," - "+aVetFilO[1,02],"")
			EndIf
		Case aFiltro[21] == "VNDE" // Vendedores - Oficina
			If len(aVetVenO) > 1
				lOk := .t.
				cTitTela := Alltrim(aVetVenO[1,01])+IIf(!Empty(aVetVenO[1,02])," - "+aVetVenO[1,02],"")
			EndIf
		Case aFiltro[21] == "MARCA" // Marcas - Oficina
			If len(aVetMarO) > 1
				lOk := .t.
				cTitTela := Alltrim(aVetMarO[1,01])+IIf(!Empty(aVetMarO[1,02])," - "+aVetMarO[1,02],"")
			EndIf
		Case aFiltro[21] == "DIA" // Dias - Oficina
			If len(aVetDiaO) > 1
				lOk := .t.
				cTitTela := Alltrim(aVetDiaO[1,01])+IIf(!Empty(aVetDiaO[1,02])," - "+aVetDiaO[1,02],"")
			EndIf
		Case aFiltro[21] == "GRP" // Grupos - Oficina
			If len(aVetGrpO) > 1
				lOk := .t.
				cTitTela := Alltrim(aVetGrpO[1,01])+IIf(!Empty(aVetGrpO[1,02])," - "+aVetGrpO[1,02],"")
			EndIf
		Case aFiltro[21] == "ITE" // Itens - Oficina
			If len(aVetIteO) > 1
				lOk := .t.
				cTitTela := Alltrim(aVetIteO[1,01])+IIf(!Empty(aVetIteO[1,02])," - "+aVetIteO[1,02],"")
			EndIf
		Case aFiltro[21] == "ANA" // Analitico - Oficina (Ordem de Servico)
			If len(aVetAnaO) > 1
				lOk := .t.
				cTitTela := aVetAnaO[1,01]
			EndIf
	EndCase
	If lOk
		aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
		aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Oficina   100%
		aPos := MsObjSize( aInfo, aObjects )
		FS_MONTAVET("TPTT",cTitTela) // Monta Vetores Analitico ( Tipo de Publico / Tipo de Tempo )
		aFiltro[21] := "TPTT" // Tela Atual
		DEFINE MSDIALOG oConPecTPTT FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0049 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Oficina - Tipo de Publico / Tipo de Tempo
			oFWLayTPT := FWLayer():New()
			oFWLayTPT:Init(oConPecTPTT,.F.)
			oFWLayTPT:AddLine('LINE_TOP',100,.F.)
			oWINTPT_TOP := oFWLayTPT:GetLinePanel('LINE_TOP')

			aTelaTTPT := {}
			For i := 1 to Len(aVetTPTT)
				aAdd(aTelaTTPT,{;
					aVetTPTT[i,02] ,; //Filial
					Transform(aVetTPTT[i,03]-aVetTPTT[i,13],"@E 999,999,999.99") ,; //Vlr Venda
					Transform((aVetTPTT[i,03]/aVetTPTT[1,03])*100,"@E 9999.99")+"%" ,; //% Venda
					Transform(aVetTPTT[i,04],"@E 999,999,999.99") ,; //Vlr Produtos
					Transform(aVetTPTT[i,05],"@E 999,999,999.99") ,; //ICMS OpProp
					Transform(aVetTPTT[i,06],"@E 999,999,999.99") ,; //ICMS ST
					Transform(aVetTPTT[i,07],"@E 999,999,999.99") ,; //PIS
					Transform(aVetTPTT[i,08],"@E 999,999,999.99") ,; //COFINS
					Transform(aVetTPTT[i,09],"@E 999,999,999.99") ,; //ICMS ST(RESS)
					Transform(aVetTPTT[i,10],"@E 999,999,999.99") ,; //ICMS OP(RESS)
					Transform(aVetTPTT[i,11],"@E 999,999,999.99") ,; //ICMS Comple.
					Transform(aVetTPTT[i,12],"@E 999,999,999.99") ,; //ICMS Difal
					Transform(aVetTPTT[i,13],"@E 999,999,999.99") ,; //DESCONTO
					Transform(aVetTPTT[i,14],"@E 999,999,999.99") ,; //Frete+Desp
					Transform(OC47VlLiqVenda(aVetTPTT[i]),"@E 999,999,999.99") ,; //Vlr Liquido
					Transform(aVetTPTT[i,16],"@E 999,999,999.99") ,; //Custo
					Transform(OC47VlrLucro(aVetTPTT[i]) - OC47DespCompra(aVetTPTT[i]),"@E 999,999,999.99") ,; //Lucro Bruto
					Transform(OC47MrgBrut(aVetTPTT[i]),"@E 9999.99")+'%',; //%Lucro
					Transform(OC47MrgLiq(aVetTPTT[i]),"@E 9999.99")+'%',; //%Lucro Liq
					Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47PcDspVar( OC47VlrLucro(aVetTPTT[i],"FatLiq"), OC47DespCompra(aVetTPTT[i]), aFiltro[23]), 0),"@E 999,999,999.99"),; //Desp. Variavel
					Transform(IIf(!Empty(aFiltro[23]) .AND. aFiltro[23] > 0, OC47ResFinal( aVetTPTT[i], aFiltro[23]), 0),"@E 999,999,999.99"),; //Res. Final
					OC47Pmv( 'Todos', aVetTPTT, i ),; //PMV
					Transform(OC47PercResult( aVetTPTT[i] ),"@E 9999.99") + "%"}) //%Resultado
			Next
			oBrowseTTPT := FWBrowse():New()
			oBrowseTTPT:SetOwner(oWINTPT_TOP)
			oBrowseTTPT:SetProfileID(oBrowseTot:GetProfileID()) //Utiliza a configura็ใo do primeiro browse
			oBrowseTTPT:SetDataArray()
			oBrowseTTPT:SetColumns(MontCol("oBrowseTTPT",aBrowse,STR0049))
			oBrowseTTPT:SetArray(aTelaTTPT)
			oBrowseTTPT:Activate() // Ativa็ใo do Browse
			oBrowseTTPT:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oBrowseTTPT:Refresh()
			oBrowseTTPT:GoTop()

		ACTIVATE MSDIALOG oConPecTPTT ON INIT EnchoiceBar(oConPecTPTT,{ || oConPecTPTT:End() }, { || oConPecTPTT:End() },,aNewBotV3)
		OC47RetPilha()
	EndIf
EndIf
aFiltro[21] := cSlvTela // Tela Atual
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_VENDEDบ Autor ณ Andre Luis Almeida บ Data ณ  17/02/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Lista Ranking dos Vendedores                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VENDED()
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cSlvTela  := aFiltro[21] // Tela Atual
Local cTitTela  := STR0035 // Total Geral
Local lOk       := .f.
If aFiltro[21] <> "VEND" // diferente de ( Ranking Vendedores )
	Do Case
		Case aFiltro[21] == "FIL" // Filiais - Oficina
			lOk := .t.
			If aFiltro[15] == "T" // Total
				cTitTela := Alltrim(aVetFilT[1,01])+IIf(!Empty(aVetFilT[1,02])," - "+aVetFilT[1,02],"")
			ElseIf aFiltro[15] == "B" // Balcao
				cTitTela := Alltrim(aVetFilB[1,01])+IIf(!Empty(aVetFilB[1,02])," - "+aVetFilB[1,02],"")
			ElseIf aFiltro[15] == "O" // Oficina
				cTitTela := Alltrim(aVetFilO[1,01])+IIf(!Empty(aVetFilO[1,02])," - "+aVetFilO[1,02],"")
			EndIf
		Case aFiltro[21] == "VNDE" // Vendedores - Oficina
			lOk := .t.
			If aFiltro[15] == "T" // Total
				cTitTela := Alltrim(aVetVenT[1,01])+IIf(!Empty(aVetVenT[1,02])," - "+aVetVenT[1,02],"")
			ElseIf aFiltro[15] == "B" // Balcao
				cTitTela := Alltrim(aVetVenB[1,01])+IIf(!Empty(aVetVenB[1,02])," - "+aVetVenB[1,02],"")
			ElseIf aFiltro[15] == "O" // Oficina
				cTitTela := Alltrim(aVetVenO[1,01])+IIf(!Empty(aVetVenO[1,02])," - "+aVetVenO[1,02],"")
			EndIf
		Case aFiltro[21] == "MARCA" // Marcas - Oficina
			lOk := .t.
			If aFiltro[15] == "T" // Total
				cTitTela := Alltrim(aVetMarT[1,01])+IIf(!Empty(aVetMarT[1,02])," - "+aVetMarT[1,02],"")
			ElseIf aFiltro[15] == "B" // Balcao
				cTitTela := Alltrim(aVetMarB[1,01])+IIf(!Empty(aVetMarB[1,02])," - "+aVetMarB[1,02],"")
			ElseIf aFiltro[15] == "O" // Oficina
				cTitTela := Alltrim(aVetMarO[1,01])+IIf(!Empty(aVetMarO[1,02])," - "+aVetMarO[1,02],"")
			EndIf
		Case aFiltro[21] == "DIA" // Dias - Oficina
			lOk := .t.
			If aFiltro[15] == "T" // Total
				cTitTela := Alltrim(aVetDiaT[1,01])+IIf(!Empty(aVetDiaT[1,02])," - "+aVetDiaT[1,02],"")
			ElseIf aFiltro[15] == "B" // Balcao
				cTitTela := Alltrim(aVetDiaB[1,01])+IIf(!Empty(aVetDiaB[1,02])," - "+aVetDiaB[1,02],"")
			ElseIf aFiltro[15] == "O" // Oficina
				cTitTela := Alltrim(aVetDiaO[1,01])+IIf(!Empty(aVetDiaO[1,02])," - "+aVetDiaO[1,02],"")
			EndIf
		Case aFiltro[21] == "GRP" // Grupos - Oficina
			lOk := .t.
			If aFiltro[15] == "T" // Total
				cTitTela := Alltrim(aVetGrpT[1,01])+IIf(!Empty(aVetGrpT[1,02])," - "+aVetGrpT[1,02],"")
			ElseIf aFiltro[15] == "B" // Balcao
				cTitTela := Alltrim(aVetGrpB[1,01])+IIf(!Empty(aVetGrpB[1,02])," - "+aVetGrpB[1,02],"")
			ElseIf aFiltro[15] == "O" // Oficina
				cTitTela := Alltrim(aVetGrpO[1,01])+IIf(!Empty(aVetGrpO[1,02])," - "+aVetGrpO[1,02],"")
			EndIf
		Case aFiltro[21] == "ITE" // Itens - Oficina
			lOk := .t.
			If aFiltro[15] == "T" // Total
				cTitTela := Alltrim(aVetIteT[1,01])+IIf(!Empty(aVetIteT[1,02])," - "+aVetIteT[1,02],"")
			ElseIf aFiltro[15] == "B" // Balcao
				cTitTela := Alltrim(aVetIteB[1,01])+IIf(!Empty(aVetIteB[1,02])," - "+aVetIteB[1,02],"")
			ElseIf aFiltro[15] == "O" // Oficina
				cTitTela := Alltrim(aVetIteO[1,01])+IIf(!Empty(aVetIteO[1,02])," - "+aVetIteO[1,02],"")
			EndIf
		Case aFiltro[21] == "ANA" // Analitico - Oficina (Ordem de Servico)
			lOk := .t.
	EndCase
	If lOk
		aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
		aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Oficina   100%
		aPos := MsObjSize( aInfo, aObjects )
		FS_MONTAVET("VEND",cTitTela) // Monta Vetores Analitico ( Ranking Vendedores )
		aFiltro[21] := "VEND" // Tela Atual
		Asort(aVetVEND,,,{|x,y| x[2]+str(x[3],10) > y[2]+str(y[3],10) })
		DEFINE MSDIALOG oConPecRV FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0050 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Ranking Vendedores
		@ aPos[1,1],aPos[1,2] LISTBOX oLbVEND FIELDS HEADER STR0050,STR0024,STR0025 ; // Ranking Vendedores / Vlr Venda / % Venda
		COLSIZES aPos[1,4]-200,53,35 SIZE aPos[1,4]-2,aPos[1,3]-aPos[1,1]-3 OF oConPecRV PIXEL
		oLbVEND:SetArray(aVetVEND)
		oLbVEND:bLine := { || { aVetVEND[oLbVEND:nAt,01]+aVetVEND[oLbVEND:nAt,04] ,;
		FG_AlinVlrs(Transform(aVetVEND[oLbVEND:nAt,03],"@E 999,999,999.99")) ,;
		FG_AlinVlrs(Transform((aVetVEND[oLbVEND:nAt,03]/aVetVEND[1,03])*100,"@E 9999.99")+"%") }}
		ACTIVATE MSDIALOG oConPecRV ON INIT EnchoiceBar(oConPecRV,{ || oConPecRV:End() }, { || oConPecRV:End() },,aNewBotV3)
		OC47RetPilha()
	EndIf
EndIf
aFiltro[21] := cSlvTela // Tela Atual
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_GRAFICบ Autor ณ Andre Luis Almeida บ Data ณ  17/02/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Graficos                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GRAFIC()
Local cTitGraf  := ""
Local nTam      := 20
Local nPos      := 1
Local ni        := 0
Local aGrafico  := {}
Local aTotal    := {}
Local aRet      := {}
Local aParamBox := {}
Local aCombo1   := {}
Local aCombo2   := {"0="+STR0024,"1="+STR0025} // Vlr Venda / % Venda
Do Case
	Case aFiltro[21] == "FIL" // Filiais
		nTam := 20 // Tamanho
		nPos := 2 // Filial
		If aFiltro[15] == "T" // Total
			aAdd(aCombo1,"0="+STR0032) // Filiais ( Balcao + Oficina )
			aAdd(aCombo1,"1="+STR0033) // Filiais ( Balcao )
			aAdd(aCombo1,"2="+STR0034) // Filiais ( Oficina )
		ElseIf aFiltro[15] == "B" // Balcao
			aAdd(aCombo1,"1="+STR0033) // Filiais ( Balcao )
		ElseIf aFiltro[15] == "O" // Oficina
			aAdd(aCombo1,"2="+STR0034) // Filiais ( Oficina )
		EndIf
		AADD(aParamBox,{2,STR0054,"",aCombo1,100,"len(aCombo1)>1",.t.}) // Grafico
		AADD(aParamBox,{2,STR0055,("0="+STR0024),aCombo2,100,".t.",.t.}) // Valor ou % / Vlr Venda
		If ParamBox(aParamBox,STR0051,@aRet,,,,,,,,.f.) // Graficos
			If aRet[1] == "0" // ( Balcao + Oficina )
				aTotal := aClone(aVetFilT)
				cTitGraf := STR0032 // Filiais ( Balcao + Oficina )
			ElseIf aRet[1] == "1" // ( Balcao )
				aTotal := aClone(aVetFilB)
				cTitGraf := STR0033 // Filiais ( Balcao )
			ElseIf aRet[1] == "2" // ( Oficina )
				aTotal := aClone(aVetFilO)
				cTitGraf := STR0034 // Filiais ( Oficina )
			EndIf
		Else
			Return()
		EndIf
	Case aFiltro[21] == "VNDE" // Vendedores
		nTam := 12 // Tamanho
		nPos := 1 // Data
		If aFiltro[15] == "T" // Total
			aAdd(aCombo1,"0="+STR0036) // Dias ( Balcao + Oficina )
			aAdd(aCombo1,"1="+STR0037) // Dias ( Balcao )
			aAdd(aCombo1,"2="+STR0038) // Dias ( Oficina )
		ElseIf aFiltro[15] == "B" // Balcao
			aAdd(aCombo1,"1="+STR0037) // Dias ( Balcao )
		ElseIf aFiltro[15] == "O" // Oficina
			aAdd(aCombo1,"2="+STR0038) // Dias ( Oficina )
		EndIf
		AADD(aParamBox,{2,STR0054,"",aCombo1,100,"len(aCombo1)>1",.t.}) // Grafico
		AADD(aParamBox,{2,STR0055,("0="+STR0024),aCombo2,100,".t.",.t.}) // Valor ou % / Vlr Venda
		If ParamBox(aParamBox,STR0051,@aRet,,,,,,,,.f.) // Graficos
			If aRet[1] == "0" // ( Balcao + Oficina )
				aTotal := aClone(aVetVenT)
				cTitGraf := STR0036 // Dias ( Balcao + Oficina )
			ElseIf aRet[1] == "1" // ( Balcao )
				aTotal := aClone(aVetVenB)
				cTitGraf := STR0037 // Dias ( Balcao )
			ElseIf aRet[1] == "2" // ( Oficina )
				aTotal := aClone(aVetVenO)
				cTitGraf := STR0038 // Dias ( Oficina )
			EndIf
		Else
			Return()
		EndIf
	Case aFiltro[21] == "MARCA" // Vendedores
		nTam := 12 // Tamanho
		nPos := 1 // Data
		If aFiltro[15] == "T" // Total
			aAdd(aCombo1,"0="+STR0036) // Dias ( Balcao + Oficina )
			aAdd(aCombo1,"1="+STR0037) // Dias ( Balcao )
			aAdd(aCombo1,"2="+STR0038) // Dias ( Oficina )
		ElseIf aFiltro[15] == "B" // Balcao
			aAdd(aCombo1,"1="+STR0037) // Dias ( Balcao )
		ElseIf aFiltro[15] == "O" // Oficina
			aAdd(aCombo1,"2="+STR0038) // Dias ( Oficina )
		EndIf
		AADD(aParamBox,{2,STR0054,"",aCombo1,100,"len(aCombo1)>1",.t.}) // Grafico
		AADD(aParamBox,{2,STR0055,("0="+STR0024),aCombo2,100,".t.",.t.}) // Valor ou % / Vlr Venda
		If ParamBox(aParamBox,STR0051,@aRet,,,,,,,,.f.) // Graficos
			If aRet[1] == "0" // ( Balcao + Oficina )
				aTotal := aClone(aVetMarT)
				cTitGraf := STR0036 // Dias ( Balcao + Oficina )
			ElseIf aRet[1] == "1" // ( Balcao )
				aTotal := aClone(aVetMarB)
				cTitGraf := STR0037 // Dias ( Balcao )
			ElseIf aRet[1] == "2" // ( Oficina )
				aTotal := aClone(aVetMarO)
				cTitGraf := STR0038 // Dias ( Oficina )
			EndIf
		Else
			Return()
		EndIf
	Case aFiltro[21] == "DIA" // Dias
		nTam := 12 // Tamanho
		nPos := 1 // Data
		If aFiltro[15] == "T" // Total
			aAdd(aCombo1,"0="+STR0036) // Dias ( Balcao + Oficina )
			aAdd(aCombo1,"1="+STR0037) // Dias ( Balcao )
			aAdd(aCombo1,"2="+STR0038) // Dias ( Oficina )
		ElseIf aFiltro[15] == "B" // Balcao
			aAdd(aCombo1,"1="+STR0037) // Dias ( Balcao )
		ElseIf aFiltro[15] == "O" // Oficina
			aAdd(aCombo1,"2="+STR0038) // Dias ( Oficina )
		EndIf
		AADD(aParamBox,{2,STR0054,"",aCombo1,100,"len(aCombo1)>1",.t.}) // Grafico
		AADD(aParamBox,{2,STR0055,("0="+STR0024),aCombo2,100,".t.",.t.}) // Valor ou % / Vlr Venda
		If ParamBox(aParamBox,STR0051,@aRet,,,,,,,,.f.) // Graficos
			If aRet[1] == "0" // ( Balcao + Oficina )
				aTotal := aClone(aVetDiaT)
				cTitGraf := STR0036 // Dias ( Balcao + Oficina )
			ElseIf aRet[1] == "1" // ( Balcao )
				aTotal := aClone(aVetDiaB)
				cTitGraf := STR0037 // Dias ( Balcao )
			ElseIf aRet[1] == "2" // ( Oficina )
				aTotal := aClone(aVetDiaO)
				cTitGraf := STR0038 // Dias ( Oficina )
			EndIf
		Else
			Return()
		EndIf
	Case aFiltro[21] == "GRP"      // Grupos
		nTam := 4                    // Tamanho
		nPos := 1                    // Grupo
		If aFiltro[15] == "T"        // Total
			aAdd(aCombo1, "0="+STR0039) // Grupos ( Balcao + Oficina )
			aAdd(aCombo1, "1="+STR0040) // Grupos ( Balcao )
			aAdd(aCombo1, "2="+STR0041) // Grupos ( Oficina )
		ElseIf aFiltro[15] == "B"    // Balcao
			aAdd(aCombo1, "1="+STR0040) // Grupos ( Balcao )
		ElseIf aFiltro[15] == "O"    // Oficina
			aAdd(aCombo1, "2="+STR0041) // Grupos ( Oficina )
		EndIf
		AADD(aParamBox,{2,STR0054,"",aCombo1,100,"len(aCombo1)>1",.t.})   // Grafico
		AADD(aParamBox,{2,STR0055,("0="+STR0024),aCombo2,100,".t.",.t.})  // Valor ou % / Vlr Venda
		If ParamBox(aParamBox,STR0051,@aRet,,,,,,,,.f.) // Graficos
			If aRet[1] == "0"             // ( Balcao + Oficina )
				aTotal := aClone(aVetGrpT)
				cTitGraf := STR0039         // Grupos ( Balcao + Oficina )
			ElseIf aRet[1] == "1"         // ( Balcao )
				aTotal := aClone(aVetGrpB)
				cTitGraf := STR0040         // Grupos ( Balcao )
			ElseIf aRet[1] == "2"         // ( Oficina )
				aTotal := aClone(aVetGrpO)
				cTitGraf := STR0041         // Grupos ( Oficina )
			EndIf
		Else
			Return()
		EndIf
EndCase
If len(aTotal) > 1
	For ni := 2 to len(aTotal)
		If aTotal[ni,3] > 0
			If aRet[02] == "0" // Valor
				Aadd(aGrafico,{aTotal[ni,3],Alltrim(left(aTotal[ni,nPos],nTam)),})
			Else // Percentual
				Aadd(aGrafico,{round((aTotal[ni,3]/aTotal[1,3])*100,2),Alltrim(left(aTotal[ni,nPos],nTam)),})
			EndIf
		EndIf
	Next
	If len(aGrafico) > 0
		FG_GRAFICO(,cTitGraf+" - "+substr(aCombo2[val(aRet[02])+1],3),,,,,aGrafico,4)
	Else
		MsgStop(STR0053,STR0052) // Nao existem dados para o Grafico! / Atencao
	EndIf
Else
	MsgStop(STR0053,STR0052)   // Nao existem dados para o Grafico! / Atencao
EndIf
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณ TecData    Autor ณ Vinicius Gati      บ Data ณ  15/04/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe para manipular dados de usuario logado              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class TecData
	Data cCodUsrLogado
	Data cNomUsrLogado
	Data blVenVerDados // pode ver dados de outros vendedores?
	Data blFilVerDados // pode ver dados da filial?
	Data cCodVendedor

	Method New() Constructor
	Method VeOutrosVendedores()
	Method VeOutrasFiliais()
EndClass

//Pega dados do usuario logado e os dados de tecnico(VAI) dele
Method New() Class TecData
	DbSelectArea("VAI")
	::cCodUsrLogado := RetCodUsr() // cUsuario ้ uma variavel padrao que sempre contem dados do usuario logado
	::cNomUsrLogado := UsrFullName(::cCodUsrLogado)

	DbSetOrder(4)
	If(DbSeek( xFilial("VAI")+::cCodUsrLogado ))
		::blVenVerDados := ( VAI->VAI_OUTVEN == '1' )
		::blFilVerDados := ( VAI->VAI_OUTFIL == '1' )
		::cCodVendedor  := VAI->VAI_CODVEN
	Else
		::blVenVerDados := .F.
		::blFilVerDados := .F.
	EndIf
Return SELF

// Se pode ver dados de outros vendedores
Method VeOutrosVendedores() Class TecData
Return SELF:blVenVerDados

// Se pode ver dados de outras filiais
Method VeOutrasFiliais() Class TecData
Return SELF:blFilVerDados

/*/{Protheus.doc} MontCol
	Constroi o objeto com as colunas que serใo apresentadas no browse

	@author Renato Vinicius
	@since  15/06/2017
	@param cNomBrw, aHeader, cNomCol1
	@return array, objeto FWBrwColumn com os dados das colunas
/*/

Static Function MontCol(cNomBrw,aHeader,cNomCol1)

	Local aColunas, oColuna
	Local cSetData
	Local nHeader := 0

	Default aHeader := {}
	Default cNomBrw := ""
	Default cNomCol1   := ""

	aColunas := {}

	For nHeader := 1 To Len(aHeader)
		// Instancia a Classe
		oColuna := FWBrwColumn():New()

		// Defini็๕es Bแsicas do Objeto
		oColuna:SetAlign(If(aHeader[nHeader][2] == "N", CONTROL_ALIGN_RIGHT, If(aHeader[nHeader][2] == "X", CONTROL_ALIGN_NONE, CONTROL_ALIGN_LEFT)))
		oColuna:SetEdit(.F.)

		// Defini็๕es do Dado apresentado
		oColuna:SetSize(aHeader[nHeader][3])
		oColuna:SetTitle( IIF( nHeader = 1 , cNomCol1 , aHeader[nHeader][1] ) )
		oColuna:SetType(aHeader[nHeader][2])
		oColuna:SetPicture(aHeader[nHeader][4])

		cSetData := "{|| "+cNomBrw+":Data():GetArray()["+cNomBrw+":AT()][" + cValToChar(aHeader[nHeader][5]) + "] }"
		oColuna:SetData(&(cSetData))

		aAdd(aColunas, oColuna)
	Next nHeader
Return aColunas


#include 'protheus.ch'

/*/{Protheus.doc} OC470NFHlp
	Classe para ajudar com fechamento agrupado de pe็as, onde preciso abater do total
	para evitar erro de valores quando feito join pois pe็as nใo tem liga็ใo com item no D2
	
	@type function
	@author Vinicius Gati
	@since 13/04/2020
/*/
Class OC470NFHlp
	Data oData
	Data oIndices // indices que ja foram abatidos ou testados

	Method New() CONSTRUCTOR
	Method Abater()
	Method _insert()
EndClass

/*/{Protheus.doc} New
	Construtor Simples

	@type function
	@author Vinicius Gati
	@since 13/04/2020
/*/
Method New() Class OC470NFHlp
	::oData := JsonObject():New()
	::oIndices := JsonObject():New()
Return SELF

/*/{Protheus.doc} Abater
	adiciona a nota nos dados caso nเo tenha ainda sido adicionada

	@type function
	@author Vinicius Gati
	@since 13/04/2020
/*/
Method Abater(cFilNf, cD2Item, cNumDoc, cSerie, cD2COD, cVS3SEQUEN, nTotal)  class OC470NFHlp
	local cIndex := cFilNf + alltrim(cD2COD) + alltrim(cD2Item) + alltrim(cNumDoc) + alltrim(cSerie)
	local cTry   := cFilNf + alltrim(cD2COD) + alltrim(cVS3SEQUEN) // identifica o vs3

	self:_insert(cIndex, cTry, nTotal)

	nVal := self:oData[cIndex]
	// valor pode ser abatido e o indice nใo foi utilizado pra abater ainda
	// ้ fogo entender , mas esse indice == .f. ้ o que "resolve" o problema
	// visto que como vem uma dizima do banco nao tenho como saber qual foi e qual nใo foi abatido

	if nVal >= nTotal // .and. self:oIndices[cTry] == .f.
		self:oData[cIndex]  -= nTotal
		// self:oIndices[cTry] := .t.
		return .t.
	endif
Return .f.

/*/{Protheus.doc} _insert
	adiciona a nota nos dados caso nเo tenha ainda sido adicionada

	@type function
	@author Vinicius Gati
	@since 13/04/2020
/*/
Method _insert(cIndex, cTry, nTotal) Class OC470NFHlp
	local oValue := self:oData[cIndex]
	// self:oIndices[cTry] := iif( ValType(self:oIndices[cTry]) == "U", .f., self:oIndices[cTry] )
	if ValType(oValue) == "U"
		self:oData[cIndex] := nTotal
		return .t.
	endif
Return .f.
