#Include 'Protheus.ch'
#Include 'TOPCONN.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIC130.CH"

/*/{Protheus.doc} VEIC130
Veículos/Máquinas em Estoque/Pedido x Bonus de Venda disponiveis

@author Andre Luis Almeida
@since 20/04/2021
/*/
Function VEIC130(aChaInts)

Local aSizeAut    := MsAdvSize(.t.)
Local cFiltro     := ""
Local cChaInts    := ""
Local nCntFor     := 0
Local cAuxCodMar  := FMX_RETMAR(GetNewPar("MV_MIL0006",""))
Local lVarios     := .f. // Apenas 1 CHAINT
Local aVeiBonus   := {} // Todos os possiveis Bonus do Veiculo posicionado
Private aRotina   := {}
Private cCadastro := STR0011 // Veículos/Máquinas em Estoque/Pedido x Bonus de Venda disponiveis
Default aChaInts  := {}

DbSelectArea("VV1")

If len(aChaInts) > 0
	For nCntFor := 1 to len(aChaInts)
		If !Empty(aChaInts[nCntFor]) .and. len(VC1300011_FiltroVQ1( aChaInts[nCntFor] , .f. , .t. , 0 )) > 0 // Buscar Bonus pelo Pedido VQ0 - Veiculo posicionado no VV1
			If !Empty(cChaInts)
				cChaInts += ","
				lVarios := .t. // Varios CHAINTs
			EndIf
			cChaInts += "'"+aChaInts[nCntFor]+"'"
		EndIf
	Next
	If Empty(cChaInts)
		Return .f. // Nenhum dos CHAINTs passados possuem Bonus de Venda ativos
	EndIf
	cCadastro := STR0002 // Bonus de Venda disponiveis para o Veículo/Máquina
	cFiltro := "@ VV1_FILIAL='"+xFilial("VV1")+"'"
	If lVarios // Varios CHAINTs
		cFiltro += " AND VV1_CHAINT IN ("+cChaInts+")" // Filtra todos Veiculos especificos passados para a função
	Else // Apenas 1 CHAINT
		cFiltro += " AND VV1_CHAINT="+cChaInts // Filtra o Veiculo especifico passado para a função
	EndIf
	cFiltro += " AND VV1_CODMAR='"+cAuxCodMar+"'" // Filtra Marca padrão
Else
	cFiltro := "@ VV1_CODMAR='"+cAuxCodMar+"'" // Filtra Marca padrão
EndIf
cFiltro += " AND VV1_ESTVEI='0'"
cFiltro += " AND ( VV1_SITVEI='0'" // Filtra Veiculo 0-Novo Em Estoque
cFiltro += "  OR ( VV1_SITVEI='8' AND VV1_CHASSI=' ' " // Pedido SEM CHASSI
cFiltro += " AND EXISTS" // Pedido NAO Cancelado
cFiltro += "   ( SELECT VQ0.R_E_C_N_O_"
cFiltro += "       FROM " + RetSqlName("VQ0") + " VQ0 "
cFiltro += "      WHERE VQ0.VQ0_FILIAL='"+xFilial("VQ0")+"'"
cFiltro += "        AND VQ0.VQ0_CHAINT = VV1_CHAINT"
cFiltro += "        AND VQ0.VQ0_STATUS <> '3'"
cFiltro += "        AND VQ0.D_E_L_E_T_ = ' '"
cFiltro += "   )"
cFiltro += "  )"
cFiltro += "  OR ( VV1_SITVEI='8'" // Pedido COM CHASSI
cFiltro += " AND EXISTS" // Pedido NAO Cancelado
cFiltro += "   ( SELECT VQ0.R_E_C_N_O_"
cFiltro += "       FROM " + RetSqlName("VQ0") + " VQ0 "
cFiltro += "      WHERE VQ0.VQ0_FILIAL='"+xFilial("VQ0")+"'"
cFiltro += "        AND VQ0.VQ0_CHAINT = VV1_CHAINT"
cFiltro += "        AND VQ0.VQ0_STATUS <> '3'"
cFiltro += "        AND VQ0.D_E_L_E_T_ = ' '"
cFiltro += "   )"
cFiltro += " AND NOT EXISTS" // Nao tem Compra
cFiltro += "   ( SELECT VVG.R_E_C_N_O_"
cFiltro += "       FROM "+RetSqlName("VVG")+" VVG"
cFiltro += "       JOIN "+RetSqlName("VVF")+" VVF ON ( VVF.VVF_FILIAL=VVG.VVG_FILIAL AND VVF.VVF_TRACPA=VVG.VVG_TRACPA AND VVF.VVF_OPEMOV='0' AND VVF.VVF_SITNFI<>'0' AND VVF.D_E_L_E_T_=' ' )"
cFiltro += "      WHERE VVG.VVG_CHASSI=VV1_CHASSI"
cFiltro += "        AND VVG.D_E_L_E_T_=' '"
cFiltro += "   )"
cFiltro += "  )"
cFiltro += "  OR ( VV1_SITVEI NOT IN ('0','1','8') " // olhar movimentacao de Compra e Venda
cFiltro += " AND EXISTS" // Tem Compra
cFiltro += "   ( SELECT VVG.R_E_C_N_O_"
cFiltro += "       FROM "+RetSqlName("VVG")+" VVG"
cFiltro += "       JOIN "+RetSqlName("VVF")+" VVF ON ( VVF.VVF_FILIAL=VVG.VVG_FILIAL AND VVF.VVF_TRACPA=VVG.VVG_TRACPA AND VVF.VVF_OPEMOV='0' AND VVF.VVF_SITNFI<>'0' AND VVF.D_E_L_E_T_=' ' )"
cFiltro += "      WHERE VVG.VVG_CHASSI=VV1_CHASSI"
cFiltro += "        AND VVG.D_E_L_E_T_=' '"
cFiltro += "   )
cFiltro += " AND NOT EXISTS" // Nao tem Venda
cFiltro += "   ( SELECT VVA.R_E_C_N_O_"
cFiltro += "       FROM "+RetSqlName("VVA")+" VVA"
cFiltro += "       JOIN "+RetSqlName("VV0")+" VV0 ON ( VV0.VV0_FILIAL=VVA.VVA_FILIAL AND VV0.VV0_NUMTRA=VVA.VVA_NUMTRA AND VV0.VV0_OPEMOV='0' AND VV0.VV0_SITNFI<>'0' AND VV0.D_E_L_E_T_=' ' )"
cFiltro += "      WHERE VVA.VVA_CHASSI=VV1_CHASSI"
cFiltro += "        AND VVA.D_E_L_E_T_=' '"
cFiltro += "   )"
cFiltro += "  )"
cFiltro += ")"

DEFINE MSDIALOG oVEIC130 FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS

	oTPanBonus := TPanel():New(0,0,"",oVEIC130,NIL,.T.,.F.,NIL,NIL,100,(oVEIC130:nClientHeight/4)-25,.T.,.F.)
	oTPanBonus:Align := CONTROL_ALIGN_BOTTOM

	oTPanVV1 := TPanel():New(0,0,"",oVEIC130,NIL,.T.,.F.,NIL,NIL,100,(oVEIC130:nClientHeight/4)-25,.T.,.F.)
	oTPanVV1:Align := CONTROL_ALIGN_BOTTOM

	oLbBonus := TWBrowse():New( 0,;
								0,;
								100,;
								100,;
								,,,oTPanBonus,,,,,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)
	oLbBonus:addColumn( TCColumn():New( STR0004 , { || aVeiBonus[oLbBonus:nAt,01]+" - "+aVeiBonus[oLbBonus:nAt,02] } ,,,, "LEFT" , 250 ,.F.,.F.,,,,.F.,) ) // Bonus
	oLbBonus:addColumn( TCColumn():New( "%"     , { || Transform(aVeiBonus[oLbBonus:nAt,07],"@EZ 99.9999") } ,,,, "RIGHT" , 40 ,.F.,.F.,,,,.F.,) ) // %
	oLbBonus:addColumn( TCColumn():New( STR0005 , { || aVeiBonus[oLbBonus:nAt,05] } ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) ) // Dt.Inicial
	oLbBonus:addColumn( TCColumn():New( STR0006 , { || aVeiBonus[oLbBonus:nAt,06] } ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) ) // Dt.Final
	oLbBonus:addColumn( TCColumn():New( STR0007 , { || Transform(aVeiBonus[oLbBonus:nAt,03],"@E 999,999") } ,,,, "RIGHT",  60 ,.F.,.F.,,,,.F.,) ) // Quantidade
	oLbBonus:addColumn( TCColumn():New( STR0008 , { || Transform(aVeiBonus[oLbBonus:nAt,04],"@E 999,999,999,999.99") } ,,,, "RIGHT",  60 ,.F.,.F.,,,,.F.,) ) // Vlr.Liquido
	oLbBonus:nAt := 1
	oLbBonus:SetArray(aVeiBonus)
	oLbBonus:Align := CONTROL_ALIGN_ALLCLIENT

	oBrwVV1 := FwMBrowse():New()
	oBrwVV1:SetOwner(oTPanVV1)
	oBrwVV1:SetDescription(STR0009) // Total de Bonus de Venda
	oBrwVV1:SetAlias('VV1')
	oBrwVV1:SetChgAll(.T.) //nao apresentar a tela para informar a filial
	If !Empty(cChaInts) // Fez Filtro por CHAINTs - Consulta chamada por outro fonte
		oBrwVV1:SetMenuDef("") // Não mostrar opçoes na TELA
		oBrwVV1:lOptionReport := .f. // Não mostrar botao de Impressao
	EndIf
	oBrwVV1:AddLegend( "VV1_SITVEI<>'8'" , "BR_BRANCO" , STR0012 )	// Estoque
	oBrwVV1:AddLegend( "VV1_SITVEI=='8'" , "BR_AZUL"   , STR0013 )	// Pedido
	oBrwVV1:SetFilterDefault( cFiltro )
	oBrwVV1:SetChange( { || aVeiBonus := VC1300011_FiltroVQ1(,.t.,.f.,0) , oLbBonus:SetArray(aVeiBonus) , oLbBonus:nAt := 1 , oLbBonus:Refresh() } )
	oBrwVV1:DisableDetails()
	oBrwVV1:Activate()

ACTIVATE MSDIALOG oVEIC130 ON INIT EnchoiceBar(oVEIC130,{ || oVEIC130:End() }, { || oVEIC130:End() })

Return .t.

/*/{Protheus.doc} VC1300011_FiltroVQ1
Retorna todos os possiveis Bonus para o Veiculo

@author Andre Luis Almeida
@since 22/04/2021
@return aRet, array com todos os bonus possiveis para o veiculo
/*/
Function VC1300011_FiltroVQ1( cChaInt , lTotaliza , lVldVeic , nRecVQ0 )
Local aAux    := {}
Local aRet    := {}
Local nCntFor := 0
Local nPosCod := 0
Local nPosVlr := 0
Local cFilVZQ := ""
Local cQuery  := ""
Default cChaInt   := ""
Default lTotaliza := .t.
Default lVldVeic  := .f.
Default nRecVQ0   := 0
//
If lVldVeic // Valida Movimentação do Veiculo
	If !Empty(cChaInt)
		VV1->(DbSetOrder(1)) // CHAINT
		VV1->(DbSeek( xFilial("VV1") + cChaInt ))
	EndIf
 	If !VC1300021_Valida_Mov_VeiculoMaquina() // Valida Movimentação do Veiculo posicionado VV1
		Return aClone(aRet)
	EndIf
EndIf
If nRecVQ0 == 0
	cQuery := "SELECT R_E_C_N_O_ FROM "+RetSQLName("VQ0")+" WHERE VQ0_FILIAL='"+xFilial("VQ0")+"' AND VQ0_CHAINT='"+VV1->VV1_CHAINT+"' AND D_E_L_E_T_=' '"
	nRecVQ0 := FM_SQL(cQuery)
EndIf
If nRecVQ0 > 0
	VQ0->(DbGoTo(nRecVQ0))
	aAux := VA1630015_LevantaBonus( "2" , .f. , .t. , dDatabase , dDatabase , "0" , .t. )
	If len(aAux) > 0 // Possui Bonus de Venda
		nPosCod := aScan(aAux[1,2],{|x| x[1] == "VQ1_CODBON" } )
		nPosVlr := aScan(aAux[1,2],{|x| x[1] == "VQ1_VLRLIQ" } )
		If lTotaliza // Totalizar na 1a.Linha
			aAdd(aRet,{ "" , STR0009 , 0 , 0 , "" , "" , 0 }) // Total de Bonus de Venda
		EndIf
		cFilVZQ := xFilial("VZQ")
		For nCntFor := 1 to len(aAux)
			VZQ->(DbSetOrder(1))
			VZQ->(DbSeek(cFilVZQ+aAux[nCntFor,2,nPosCod,2]))
			aAdd(aRet,{ aAux[nCntFor,2,nPosCod,2] , VZQ->VZQ_DESCRI , 1 , aAux[nCntFor,2,nPosVlr,2] , Transform(VZQ->VZQ_DATINI,"@D") , Transform(VZQ->VZQ_DATFIN,"@D") , VZQ->VZQ_PERBON })
			If lTotaliza // Totalizar na 1a.Linha
				aRet[1,3]++
				aRet[1,4]+= aAux[nCntFor,2,nPosVlr,2]
			EndIf
		Next
	EndIf
EndIf
Return aClone(aRet)

/*/{Protheus.doc} VC1300021_Valida_Mov_VeiculoMaquina
Verificar se o Veiculo/Máquina é NOVO e não esta vendido (Estoque)
Estoque => Verifica se teve ENTRADA por COMPRA e não teve ainda SAIDA por VENDA valida

@author Andre Luis Almeida
@since 26/04/2021
/*/
Static Function VC1300021_Valida_Mov_VeiculoMaquina()
Local lRet   := .f.
Local cQuery := ""
If VV1->VV1_ESTVEI == "0" .and. VV1->VV1_SITVEI <> "1" // Novo e diferente de 1-Vendido
	If VV1->VV1_SITVEI == "0" // 0-Estoque
		lRet := .t. // ok - nao precisa verificar as movimentacoes
	Else
		If VV1->VV1_SITVEI == '8' // 8-Pedido
			If Empty(VV1->VV1_CHASSI)
				lRet := .t. // Entra na Condicao para mostrar este Veiculo/Maquina em Pedido que NAO possui CHASSI
			Else
				cQuery := "SELECT VVG.R_E_C_N_O_"
				cQuery += "  FROM "+RetSqlName("VVG")+" VVG"
				cQuery += "  JOIN "+RetSqlName("VVF")+" VVF ON ( VVF.VVF_FILIAL=VVG.VVG_FILIAL AND VVF.VVF_TRACPA=VVG.VVG_TRACPA AND VVF.VVF_OPEMOV='0' AND VVF.VVF_SITNFI<>'0' AND VVF.D_E_L_E_T_=' ' )"
				cQuery += " WHERE VVG.VVG_CHASSI='"+VV1->VV1_CHASSI+"'"
				cQuery += "   AND VVG.D_E_L_E_T_=' '"
				If FM_SQL(cQuery) == 0 // NAO tem Entrada por Compra
					lRet := .t. // Entra na Condicao para mostrar este Veiculo/Maquina em Pedido
				EndIf
			EndIf
		Else
			If !Empty(VV1->VV1_CHASSI)
				cQuery := "SELECT VVG.R_E_C_N_O_"
				cQuery += "  FROM "+RetSqlName("VVG")+" VVG"
				cQuery += "  JOIN "+RetSqlName("VVF")+" VVF ON ( VVF.VVF_FILIAL=VVG.VVG_FILIAL AND VVF.VVF_TRACPA=VVG.VVG_TRACPA AND VVF.VVF_OPEMOV='0' AND VVF.VVF_SITNFI<>'0' AND VVF.D_E_L_E_T_=' ' )"
				cQuery += " WHERE VVG.VVG_CHASSI='"+VV1->VV1_CHASSI+"'"
				cQuery += "   AND VVG.D_E_L_E_T_=' '"
				cQuery += "   AND NOT EXISTS"
				cQuery += "     ( SELECT VVA.R_E_C_N_O_"
				cQuery += "         FROM "+RetSqlName("VVA")+" VVA"
				cquery += "         JOIN "+RetSqlName("VV0")+" VV0 ON ( VV0.VV0_FILIAL=VVA.VVA_FILIAL AND VV0.VV0_NUMTRA=VVA.VVA_NUMTRA AND VV0.VV0_OPEMOV='0' AND VV0.VV0_SITNFI<>'0' AND VV0.D_E_L_E_T_=' ' )"
				cQuery += "        WHERE VVA.VVA_CHASSI='"+VV1->VV1_CHASSI+"'"
				cQuery += "          AND VVA.D_E_L_E_T_=' '"
				cQuery += "     )"
				If FM_SQL(cQuery) > 0 // Tem Entrada por Compra e NAO tem Saida por Venda
					lRet := .t. // Entra na Condicao para mostrar este Veiculo/Maquina
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} VC1300031_Rastreamento
Chamada do Rastreamento do Veiculo

@author Andre Luis Almeida
@since 22/04/2021
/*/
Function VC1300031_Rastreamento()

	VEIVC140( VV1->VV1_CHASSI , IIf(Empty(VV1->VV1_CHASSI),VV1->VV1_CHAINT,"") )

Return

/*/{Protheus.doc} VC1300041_ImprimirVeiculo
Chamada do Rastreamento do Veiculo

@author Andre Luis Almeida
@since 26/08/2021
/*/
Function VC1300041_ImprimirVeiculo()
Local nCntFor   := 0
Local nPosVet   := 0
Local nPosTot   := 0
Local aALLBonus := {}
Local aVeiBonus := VC1300011_FiltroVQ1( VV1->VV1_CHAINT , .f. , .f. , 0 )
Local cFilVZQ   := xFilial("VZQ")
//
aAdd(aALLBonus,{ "" , STR0014 , 0 , 0 , {} , "" , "" , 0 }) // Total de Bonus de Venda
//
VQ0->(DbSetOrder(3))
VQ0->(DbSeek( xFilial("VQ0") + VV1->VV1_CHAINT ))
VV2->(DbSetOrder(1))
VV2->(DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI + VV1->VV1_SEGMOD ))
VVC->(DbSetOrder(1))
VVC->(DbSeek( xFilial("VVC") + VV1->VV1_CODMAR + VV1->VV1_CORVEI ))
//
// Criar mesma estrutura do VEIC131 para poder chamar a impressão do mesmo
//
For nCntFor := 1 to len(aVeiBonus)
	nPosVet := aScan(aALLBonus,{|x| x[1] == aVeiBonus[nCntFor,1] } )
	If nPosVet == 0
		VZQ->(DbSetOrder(1))
		VZQ->(DbSeek(cFilVZQ+aVeiBonus[nCntFor,1]))
		aAdd(aALLBonus,{ aVeiBonus[nCntFor,1] ,;
						 aVeiBonus[nCntFor,2] ,;
						 0 ,;
						 0 ,;
						 {} ,;
						 aVeiBonus[nCntFor,5] ,;
						 aVeiBonus[nCntFor,6] ,;
						 aVeiBonus[nCntFor,7] })
		nPosVet := len(aALLBonus)
	EndIf
	aALLBonus[nPosVet,3]++
	aALLBonus[nPosVet,4]+= aVeiBonus[nCntFor,4]
	// Adicionar o Veiculo desse Bonus
	aAdd(aALLBonus[nPosVet,5],{	VV1->(RecNo()) ,;
								VV1->VV1_CODMAR ,;
								Alltrim(VV1->VV1_MODVEI)+" - "+VV2->VV2_DESMOD ,;
								Alltrim(VV1->VV1_CORVEI)+" - "+VVC->VVC_DESCRI ,;
								VV1->VV1_CHASSI ,;
								1 ,;
								aVeiBonus[nCntFor,4] ,;
								VV1->VV1_CHAINT ,;
								IIf(!Empty(VQ0->VQ0_DATPED),Transform(VQ0->VQ0_DATPED,"@D"),"") ,;
								IIf(!Empty(VQ0->VQ0_DATVEN),Transform(VQ0->VQ0_DATVEN,"@D"),"") ,;
								VV1->VV1_SITVEI })
	// Totalizador
	aALLBonus[1,3]++
	aALLBonus[1,4]+= aVeiBonus[nCntFor,4]
	// Adicionar o Veiculo do Bonus
	nPosTot := aScan(aALLBonus[1,5],{|x| x[1] == VV1->(RecNo()) } )
	If nPosTot == 0
		aAdd(aALLBonus[1,5],aClone(aALLBonus[nPosVet,5,Len(aALLBonus[nPosVet,5])])) // Adicionar o Veiculo no TOTAL
	Else
		aALLBonus[1,5,nPosTot,6]++
		aALLBonus[1,5,nPosTot,7]+= aVeiBonus[nCntFor,4]
	EndIf
Next
//
If len(aALLBonus) > 1
	VC1310031_chama_TReport(aALLBonus,4)
Else
	Help(" ",1,"ARQVAZIO")
EndIf
//
Return

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 22/04/2021
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0010 ACTION 'VC1300031_Rastreamento()' OPERATION 2 ACCESS 0 // Rastreamento do Veiculo/Máquina
ADD OPTION aRotina TITLE STR0015 ACTION 'VC1300041_ImprimirVeiculo()' OPERATION 8 ACCESS 0 // Imprimir Veiculo/Máquina

Return aRotina