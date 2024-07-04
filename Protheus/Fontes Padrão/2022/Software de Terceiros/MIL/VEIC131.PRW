#Include 'Protheus.ch'
#Include 'TOPCONN.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIC131.CH"

/*/{Protheus.doc} VEIC131
Potencial de Bonus de Venda em relação ao Estoque/Pedido atual

@author Andre Luis Almeida
@since 22/04/2021
/*/
Function VEIC131( lTela )
Local aALLBonus   := {} // Todos os Bonus de Venda disponiveis (Retorno da Funcao)
Private cCadastro := STR0026 // Potencial de Bonus de Venda em relação ao Estoque/Pedido atual
Default lTela     := .t. // Mostra Tela para o usuario?
If lTela // Mostra Tela para o usuario?
	Processa({|| aALLBonus := VC1310011_Levanta_Potencial_Bonus( lTela ) })
Else
	aALLBonus := VC1310011_Levanta_Potencial_Bonus( lTela )
EndIf 
Return aALLBonus

/*/{Protheus.doc} VC1310011_Levanta_Potencial_Bonus
Levanta o Potencial de Bonus de Venda em relação ao Estoque atual

@author Andre Luis Almeida
@since 22/04/2021
/*/
Function VC1310011_Levanta_Potencial_Bonus( lTela )
Local aSizeAut   := MsAdvSize(.t.)
Local cQuery     := ""
Local cQAlSQL    := "SQLVV1"
Local aALLBonus  := {} // Todos os Bonus de Venda disponiveis
Local aALLVeic   := {} // Todos os veiculos que fazem parte do Bonus posicionado
Local aVeiBonus  := {} // Bonus do Veiculo selecionado
Local nCntFor    := 0
Local nPosVet    := 0
Local nPosTot    := 0
Local cFilVZQ    := xFilial("VZQ")
Local oVendSIM   := LoadBitmap( GetResources() , "BR_VERDE" )
Local oVendNAO   := LoadBitmap( GetResources() , "BR_VERMELHO" )
Local oAZUL      := LoadBitmap( GetResources() , "BR_AZUL" )
Local oBRANCO    := LoadBitmap( GetResources() , "BR_BRANCO" )
Local cAuxCodMar := FMX_RETMAR(GetNewPar("MV_MIL0006",""))
Local aBotEnch   := {}
Default lTela    := .t. // Mostra Tela para o usuario?

If lTela // Mostra Tela para o usuario?
	ProcRegua(0)
EndIf

aAdd(aALLBonus,{ "" , STR0002 , 0 , 0 , {} , "" , "" , 0 }) // Total de Bonus de Venda

cQuery := "SELECT VV1.R_E_C_N_O_ AS RECVV1 ,"
cQuery += "       VV1.VV1_CHAINT ,"
cQuery += "       VV1.VV1_CODMAR ,"
cQuery += "       VV1.VV1_MODVEI ,"
cQuery += "       VV2.VV2_DESMOD ,"
cQuery += "       VV1.VV1_CORVEI ,"
cQuery += "       VVC.VVC_DESCRI ,"
cQuery += "       VV1.VV1_CHASSI ,"
cQuery += "       VV1.VV1_SITVEI ,"
cQuery += "       VQ0.VQ0_DATPED ,"
cQuery += "       VQ0.VQ0_DATVEN ,"
cQuery += "       VQ0.R_E_C_N_O_ AS RECVQ0 "
cQuery += "  FROM " + RetSqlName("VV1") + " VV1 "
cQuery += "  JOIN " + RetSqlName("VQ0") + " VQ0 "
cQuery += "        ON VQ0.VQ0_FILIAL='"+xFilial("VQ0")+"'"
cQuery += "       AND VQ0.VQ0_CHAINT = VV1.VV1_CHAINT"
cQuery += "       AND VQ0.D_E_L_E_T_ = ' ' "
cQuery += "  JOIN " + RetSqlName("VV2") + " VV2 "
cQuery += "        ON VV2.VV2_FILIAL='"+xFilial("VV2")+"'"
cQuery += "       AND VV2.VV2_CODMAR = VV1.VV1_CODMAR"
cQuery += "       AND VV2.VV2_MODVEI = VV1.VV1_MODVEI"
cQuery += "       AND VV2.VV2_SEGMOD = VV1.VV1_SEGMOD"
cQuery += "       AND VV2.D_E_L_E_T_ = ' ' "
cQuery += "  JOIN " + RetSqlName("VVC") + " VVC "
cQuery += "        ON VVC.VVC_FILIAL='"+xFilial("VVC")+"'"
cQuery += "       AND VVC.VVC_CODMAR = VV1.VV1_CODMAR"
cQuery += "       AND VVC.VVC_CORVEI = VV1.VV1_CORVEI"
cQuery += "       AND VVC.D_E_L_E_T_ = ' ' "
cQuery += " WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"'"
cQuery += "   AND VV1.VV1_CODMAR='"+cAuxCodMar+"'"
cQuery += "   AND VV1.VV1_ESTVEI='0'" // 0-Novo
cQuery += "   AND VV1.D_E_L_E_T_ = ' ' "
cQuery += "   AND ( VV1.VV1_SITVEI='0'" // Estoque
cQuery += "  OR ( VV1.VV1_SITVEI='8' AND VV1.VV1_CHASSI=' ' AND VQ0.VQ0_STATUS<>'3' ) " // Pedido SEM CHASSI NAO Cancelado
cQuery += "  OR ( VV1.VV1_SITVEI='8' AND VQ0.VQ0_STATUS<>'3' " // Pedido COM CHASSI NAO Cancelado
cQuery += " AND NOT EXISTS"// Nao tem Compra
cQuery += "   ( SELECT VVG.R_E_C_N_O_"
cQuery += "       FROM "+RetSqlName("VVG")+" VVG"
cQuery += "       JOIN "+RetSqlName("VVF")+" VVF ON ( VVF.VVF_FILIAL=VVG.VVG_FILIAL AND VVF.VVF_TRACPA=VVG.VVG_TRACPA AND VVF.VVF_OPEMOV='0' AND VVF.VVF_SITNFI<>'0' AND VVF.D_E_L_E_T_=' ' )"
cQuery += "      WHERE VVG.VVG_CHASSI=VV1.VV1_CHASSI"
cQuery += "        AND VVG.D_E_L_E_T_=' '"
cQuery += "   ) "
cQuery += "  ) "
cQuery += "  OR ( VV1.VV1_SITVEI NOT IN ('0','1','8') " // olhar movimentacao de Compra e Venda
cQuery += " AND EXISTS" // Tem Compra
cQuery += "   ( SELECT VVG.R_E_C_N_O_"
cQuery += "       FROM "+RetSqlName("VVG")+" VVG"
cQuery += "       JOIN "+RetSqlName("VVF")+" VVF ON ( VVF.VVF_FILIAL=VVG.VVG_FILIAL AND VVF.VVF_TRACPA=VVG.VVG_TRACPA AND VVF.VVF_OPEMOV='0' AND VVF.VVF_SITNFI<>'0' AND VVF.D_E_L_E_T_=' ' )"
cQuery += "      WHERE VVG.VVG_CHASSI=VV1.VV1_CHASSI"
cQuery += "        AND VVG.D_E_L_E_T_=' '"
cQuery += "   )
cQuery += " AND NOT EXISTS" // Nao tem Venda
cQuery += "   ( SELECT VVA.R_E_C_N_O_"
cQuery += "       FROM "+RetSqlName("VVA")+" VVA"
cQuery += "       JOIN "+RetSqlName("VV0")+" VV0 ON ( VV0.VV0_FILIAL=VVA.VVA_FILIAL AND VV0.VV0_NUMTRA=VVA.VVA_NUMTRA AND VV0.VV0_OPEMOV='0' AND VV0.VV0_SITNFI<>'0' AND VV0.D_E_L_E_T_=' ' )"
cQuery += "      WHERE VVA.VVA_CHASSI=VV1.VV1_CHASSI"
cQuery += "        AND VVA.D_E_L_E_T_=' '"
cQuery += "   )"
cQuery += "  )"
cQuery += ")"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	aVeiBonus := VC1300011_FiltroVQ1( ( cQAlSQL )->( VV1_CHAINT ) , .f. , .f. , ( cQAlSQL )->( RECVQ0 ) )
	For nCntFor := 1 to len(aVeiBonus)
		// Individual
		nPosVet := aScan(aALLBonus,{|x| x[1] == aVeiBonus[nCntFor,1] } )
		If nPosVet == 0
			VZQ->(DbSetOrder(1))
			VZQ->(DbSeek(cFilVZQ+aVeiBonus[nCntFor,1]))
			aAdd(aALLBonus,{ aVeiBonus[nCntFor,1] ,;
							 aVeiBonus[nCntFor,2] ,;
							 0 ,;
							 0 ,;
							 {} ,;
							 Transform(VZQ->VZQ_DATINI,"@D") ,;
							 Transform(VZQ->VZQ_DATFIN,"@D") ,;
							 VZQ->VZQ_PERBON })
			nPosVet := len(aALLBonus)
		EndIf
		aALLBonus[nPosVet,3]++
		aALLBonus[nPosVet,4]+= aVeiBonus[nCntFor,4]
		// Adicionar os Veiculos que fazem parte desse Bonus
		aAdd(aALLBonus[nPosVet,5],{	( cQAlSQL )->( RECVV1 ) ,;
									( cQAlSQL )->( VV1_CODMAR ) ,;
									Alltrim(( cQAlSQL )->( VV1_MODVEI ))+" - "+( cQAlSQL )->( VV2_DESMOD ) ,;
									Alltrim(( cQAlSQL )->( VV1_CORVEI ))+" - "+( cQAlSQL )->( VVC_DESCRI ) ,;
									( cQAlSQL )->( VV1_CHASSI ) ,;
									1 ,;
									aVeiBonus[nCntFor,4] ,;
									( cQAlSQL )->( VV1_CHAINT ) ,;
									IIf(!Empty(( cQAlSQL )->( VQ0_DATPED )),Transform(stod(( cQAlSQL )->( VQ0_DATPED )),"@D"),"") ,;
									IIf(!Empty(( cQAlSQL )->( VQ0_DATVEN )),Transform(stod(( cQAlSQL )->( VQ0_DATVEN )),"@D"),"") ,;
									( cQAlSQL )->( VV1_SITVEI ) })
		// Totalizador
		aALLBonus[1,3]++
		aALLBonus[1,4]+= aVeiBonus[nCntFor,4]
		// Adicionar os Veiculos que fazem parte do TOTAL de Bonus
		nPosTot := aScan(aALLBonus[1,5],{|x| x[1] == ( cQAlSQL )->( RECVV1 ) } )
		If nPosTot == 0
			aAdd(aALLBonus[1,5],aClone(aALLBonus[nPosVet,5,Len(aALLBonus[nPosVet,5])])) // Adicionar o Veiculo no TOTAL
		Else
			aALLBonus[1,5,nPosTot,6]++
			aALLBonus[1,5,nPosTot,7]+= aVeiBonus[nCntFor,4]
		EndIf
	Next
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( dbCloseArea() )
DbSelectArea("VV1")

aSort(aALLBonus,1,,{|x,y| x[1] < y[1] })

If lTela // Mostra Tela para o usuario?

	AADD(aBotEnch, {"ANALITIC" ,{|| VEIVC140( aALLVeic[oLbVeic:nAt,05] , IIf(Empty(aALLVeic[oLbVeic:nAt,05]),aALLVeic[oLbVeic:nAt,08],"") ) }, STR0006 } ) // Rastreamento do Veiculo/Máquina
	AADD(aBotEnch, {"PMSCOLOR" ,{|| VC1310021_Legenda() }, STR0005 } ) // Legenda
	AADD(aBotEnch, {"IMPRESSAO",{|| VC1310031_chama_TReport(aALLBonus) }, STR0004 } ) // Imprimir

	DEFINE MSDIALOG oVEIC131 FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS

	oTPanVeic := TPanel():New(0,0,"",oVEIC131,NIL,.T.,.F.,NIL,NIL,100,(oVEIC131:nClientHeight/4)-25,.T.,.F.)
	oTPanVeic:Align := CONTROL_ALIGN_BOTTOM

	oTPanBonus := TPanel():New(0,0,"",oVEIC131,NIL,.T.,.F.,NIL,NIL,100,(oVEIC131:nClientHeight/4)-25,.T.,.F.)
	oTPanBonus:Align := CONTROL_ALIGN_BOTTOM

	oLbBonus := TWBrowse():New( 0,0,100,100,,,,oTPanBonus,,,,;
				{ || aALLVeic := aClone(aALLBonus[oLbBonus:nAt,05]) , oLbVeic:SetArray(aALLVeic) , oLbVeic:nAt := 1 , oLbVeic:Refresh() } ,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)
	oLbBonus:addColumn( TCColumn():New( STR0007 , { || aALLBonus[oLbBonus:nAt,01]+" - "+aALLBonus[oLbBonus:nAt,02]   } ,,,, "LEFT" , 320 ,.F.,.F.,,,,.F.,) ) // Bonus
	oLbBonus:addColumn( TCColumn():New( "%"     , { || Transform(aALLBonus[oLbBonus:nAt,08],"@EZ 99.9999") } ,,,, "RIGHT" , 40 ,.F.,.F.,,,,.F.,) ) // %
	oLbBonus:addColumn( TCColumn():New( STR0008 , { || aALLBonus[oLbBonus:nAt,06]                                    } ,,,, "LEFT" ,  40 ,.F.,.F.,,,,.F.,) ) // Dt.Inicial
	oLbBonus:addColumn( TCColumn():New( STR0009 , { || aALLBonus[oLbBonus:nAt,07]                                    } ,,,, "LEFT" ,  40 ,.F.,.F.,,,,.F.,) ) // Dt.Final
	oLbBonus:addColumn( TCColumn():New( STR0010 , { || Transform(aALLBonus[oLbBonus:nAt,03],"@E 999,999")            } ,,,, "RIGHT",  40 ,.F.,.F.,,,,.F.,) ) // Quantidade
	oLbBonus:addColumn( TCColumn():New( STR0011 , { || Transform(aALLBonus[oLbBonus:nAt,04],"@E 999,999,999,999.99") } ,,,, "RIGHT",  60 ,.F.,.F.,,,,.F.,) ) // Vlr.Liquido
	oLbBonus:nAt := 1
	oLbBonus:SetArray(aALLBonus)
	oLbBonus:Align := CONTROL_ALIGN_ALLCLIENT

	oLbVeic := TWBrowse():New( 0,0,100,100,,,,oTPanVeic,,,,,;
				{ || IIf( oLbVeic:nColPos<=2 , VC1310021_Legenda() , VEIVC140( aALLVeic[oLbVeic:nAt,05] , IIf(Empty(aALLVeic[oLbVeic:nAt,05]),aALLVeic[oLbVeic:nAt,08],"") ) ) },,,,,,,.F.,,.T.,,.F.,,,)
	oLbVeic:addColumn( TCColumn():New( ""      , { || IIf(aALLVeic[oLbVeic:nAt,11]=="8",oAZUL,oBRANCO)            } ,,,, "LEFT" ,  05 ,.T.,.F.,,,,.F.,) )
	oLbVeic:addColumn( TCColumn():New( ""      , { || IIf(!Empty(aALLVeic[oLbVeic:nAt,10]),oVendSIM,oVendNAO)     } ,,,, "LEFT" ,  05 ,.T.,.F.,,,,.F.,) )
	oLbVeic:addColumn( TCColumn():New( STR0012 , { || aALLVeic[oLbVeic:nAt,09]                                    } ,,,, "LEFT" ,  40 ,.F.,.F.,,,,.F.,) ) // Dt.Pedido
	oLbVeic:addColumn( TCColumn():New( STR0013 , { || aALLVeic[oLbVeic:nAt,10]                                    } ,,,, "LEFT" ,  40 ,.F.,.F.,,,,.F.,) ) // Marcado Vendido
	oLbVeic:addColumn( TCColumn():New( STR0014 , { || aALLVeic[oLbVeic:nAt,02]                                    } ,,,, "LEFT" ,  25 ,.F.,.F.,,,,.F.,) ) // Marca
	oLbVeic:addColumn( TCColumn():New( STR0015 , { || aALLVeic[oLbVeic:nAt,03]                                    } ,,,, "LEFT" , 130 ,.F.,.F.,,,,.F.,) ) // Modelo
	oLbVeic:addColumn( TCColumn():New( STR0016 , { || aALLVeic[oLbVeic:nAt,04]                                    } ,,,, "LEFT" ,  80 ,.F.,.F.,,,,.F.,) ) // Cor
	oLbVeic:addColumn( TCColumn():New( STR0017 , { || aALLVeic[oLbVeic:nAt,05]                                    } ,,,, "LEFT" ,  80 ,.F.,.F.,,,,.F.,) ) // Chassi
	oLbVeic:addColumn( TCColumn():New( STR0010 , { || Transform(aALLVeic[oLbVeic:nAt,06],"@E 999,999")            } ,,,, "RIGHT",  40 ,.F.,.F.,,,,.F.,) ) // Quantidade
	oLbVeic:addColumn( TCColumn():New( STR0011 , { || Transform(aALLVeic[oLbVeic:nAt,07],"@E 999,999,999,999.99") } ,,,, "RIGHT",  60 ,.F.,.F.,,,,.F.,) ) // Vlr.Liquido
	oLbVeic:nAt := 1
	oLbVeic:SetArray(aALLVeic)
	oLbVeic:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oVEIC131 ON INIT EnchoiceBar(oVEIC131,{ || oVEIC131:End() }, { || oVEIC131:End() },,aBotEnch) 

EndIf

Return aALLBonus

/*/{Protheus.doc} VC1310021_Legenda
Legenda - Veiculo/Máquina - Marcado Vendido? 

@author Andre Luis Almeida
@since 26/04/2021
/*/
Static Function VC1310021_Legenda()
Local aLegenda := {}
aAdd(aLegenda,{'BR_BRANCO'  , STR0028 }) // Estoque
aAdd(aLegenda,{'BR_AZUL'    , STR0029 }) // Pedido
aAdd(aLegenda,{'BR_VERDE'   , STR0018 }) // Marcado como Vendido
aAdd(aLegenda,{'BR_VERMELHO', STR0019 }) // Não marcado como Vendido
BrwLegenda(STR0020,STR0005,aLegenda) // Veiculo/Máquina / Legenda
Return

/*/{Protheus.doc} VC1310031_chama_TReport
Chamada do TReport para Impressao dos Dados da Consulta

@author Andre Luis Almeida
@since 28/04/2021
/*/
Function VC1310031_chama_TReport(aALLBonus,nOpcRel)
Local oReport
Local cMsgOpc := cCadastro+CHR(13)+CHR(10)+CHR(13)+CHR(10) // 
Default nOpcRel := 0
If nOpcRel == 0
	cMsgOpc += "1 - "+STR0021+CHR(13)+CHR(10) // Resumido totalizando por Bonus de Venda
	cMsgOpc += "2 - "+STR0022+CHR(13)+CHR(10) // Analitico por Bonus de Venda relacionando os Veiculos/Máquinas
	cMsgOpc += "3 - "+STR0023 // Analitico por Veiculo/Máquina totalizando os Bonus de Venda
	nOpcRel := Aviso(STR0024,cMsgOpc,{ "1","2","3",STR0025},3) // Tipo de Impressão / Cacnelar
EndIf
If nOpcRel > 0 .and. nOpcRel < 5
	oReport := ReportDef(aALLBonus,nOpcRel)
	oReport:PrintDialog()
EndIf
Return

/*/{Protheus.doc} ReportDef
	ReportDef

	@author Andre Luis Almeida
	@since 28/04/2021
/*/
Static Function ReportDef( aALLBonus , nOpcRel )
Local oReport
Local oSection1
Local oSection2
//
oReport := TReport():New("VEIC131",alltrim(cCadastro),Nil,{|oReport| VC1310041_Impressao( oReport , aALLBonus , nOpcRel )})
//
oSection1 := TRSection():New(oReport,STR0007,{}) // Bonus
TRCell():New(oSection1,"CodBon",,STR0007,"@!",150,,{|| cCodBon } ) // Bonus
TRCell():New(oSection1,"PerBon",,"%","@EZ 99.9999",40,,{|| nPerBon } ) // %
If nOpcRel <> 3 // Diferente de Analitico por Veiculos/Maquinas -> Mostrar Datas Inicial e Final
	TRCell():New(oSection1,"DatIni",,STR0008,"@D",40,,{|| dDatIni } ) // Dt.Inicial
	TRCell():New(oSection1,"DatFin",,STR0009,"@D",40,,{|| dDatFin } ) // Dt.Final
EndIf
TRCell():New(oSection1,"QtdBon",,STR0010,"@E 999,999"           ,40,,{|| nQtdBon } ) // Quantidade
TRCell():New(oSection1,"VlrLiq",,STR0011,"@E 999,999,999,999.99",60,,{|| nVlrLiq } ) // Vlr.Liquido

If nOpcRel > 1 // Analiticos
	oSection2 := TRSection():New(oReport,STR0020,{}) // Veiculo/Máquina
	TRCell():New(oSection2,"DatPed",,STR0012,"@!", 40,,{|| dDatPed } ) // Dt.Pedido
	TRCell():New(oSection2,"DatVen",,STR0013,"@D", 40,,{|| dDatVen } ) // Marcado Vendido
	TRCell():New(oSection2,"MarVei",,STR0014,"@D", 25,,{|| cMarVei } ) // Marca
	TRCell():New(oSection2,"ModVei",,STR0015,"@!",130,,{|| cModVei } ) // Modelo
	TRCell():New(oSection2,"CorVei",,STR0016,"@!", 80,,{|| cCorVei } ) // Cor
	TRCell():New(oSection2,"ChaVei",,STR0017,"@!", 80,,{|| cChaVei } ) // Chassi
	TRCell():New(oSection2,"SitVei",,STR0027,"@!", 40,,{|| cSitVei } ) // Situação
	TRCell():New(oSection2,"QtdBon",,STR0010,"@E 999,999"           ,40,,{|| nQtdVei } ) // Quantidade
	TRCell():New(oSection2,"VlrLiq",,STR0011,"@E 999,999,999,999.99",60,,{|| nVlrVei } ) // Vlr.Liquido
EndIf

Return oReport

/*/{Protheus.doc} VC1310041_Impressao
	Carrega variaveis e Imprime com os dados da Consulta

	@author Andre Luis Almeida
	@since 28/04/2021
/*/
Static Function VC1310041_Impressao( oReport , aALLBonus , nOpcRel )
Local oSection1
Local oSection2
Local nCntFor   := 0
Local nCntVei   := 0
Local aALLVeic  := {}
Do Case
	Case nOpcRel == 1 // Resumido totalizando por Bonus de Venda
		oSection1 := oReport:Section(1)
		oReport:SetMeter(len(aALLBonus))
		oSection1:Init()
		For nCntFor := 1 to len(aALLBonus)
			oReport:IncMeter()
			cCodBon := aALLBonus[nCntFor,1] + " - " + aALLBonus[nCntFor,2]
			nPerBon := aALLBonus[nCntFor,8]
			dDatIni := aALLBonus[nCntFor,6]
			dDatFin := aALLBonus[nCntFor,7]
			nQtdBon := aALLBonus[nCntFor,3]
			nVlrLiq := aALLBonus[nCntFor,4]
			oSection1:PrintLine()
		Next
		oSection1:Finish()

	Case nOpcRel == 2 // Analitico por Bonus de Venda relacionando os Veiculos/Máquinas
		oSection1 := oReport:Section(1)
		oSection2 := oReport:Section(2)
		oReport:SetMeter(len(aALLBonus))
		For nCntFor := 1 to len(aALLBonus)
			oReport:IncMeter()
			cCodBon := aALLBonus[nCntFor,1] + " - " + aALLBonus[nCntFor,2]
			nPerBon := aALLBonus[nCntFor,8]
			dDatIni := aALLBonus[nCntFor,6]
			dDatFin := aALLBonus[nCntFor,7]
			nQtdBon := aALLBonus[nCntFor,3]
			nVlrLiq := aALLBonus[nCntFor,4]
			oSection1:Init()
			oSection1:PrintLine()
			If nCntFor > 1
				oSection2:Init()
				aALLVeic := aClone(aALLBonus[nCntFor,05])
				For nCntVei := 1 to len(aALLVeic)
					dDatPed := aALLVeic[nCntVei,09]
					dDatVen := aALLVeic[nCntVei,10]
					cMarVei := aALLVeic[nCntVei,02]
					cModVei := aALLVeic[nCntVei,03]
					cCorVei := aALLVeic[nCntVei,04]
					cChaVei := aALLVeic[nCntVei,05]
					cSitVei := IIf(aALLVeic[nCntVei,11]=="8",STR0029,STR0028) // Pedido / Estoque
					nQtdVei := aALLVeic[nCntVei,06]
					nVlrVei := aALLVeic[nCntVei,07]
					oSection2:PrintLine()
				Next
				oSection2:Finish()
			EndIf
			oSection1:Finish()
		Next

	Case nOpcRel == 3 // Analitico por Veiculo/Máquina totalizando os Bonus de Venda
		oSection1 := oReport:Section(1)
		oSection2 := oReport:Section(2)
		oReport:SetMeter(len(aALLBonus[01,05]))
		cCodBon := aALLBonus[01,1] + " - " + aALLBonus[01,2]
		nPerBon := aALLBonus[01,8]
		nQtdBon := aALLBonus[01,3]
		nVlrLiq := aALLBonus[01,4]
		oSection1:Init()
		oSection1:PrintLine()
		oSection2:Init()
		aALLVeic := aClone(aALLBonus[01,05])
		For nCntVei := 1 to len(aALLVeic)
			oReport:IncMeter()
			dDatPed := aALLVeic[nCntVei,09]
			dDatVen := aALLVeic[nCntVei,10]
			cMarVei := aALLVeic[nCntVei,02]
			cModVei := aALLVeic[nCntVei,03]
			cCorVei := aALLVeic[nCntVei,04]
			cChaVei := aALLVeic[nCntVei,05]
			cSitVei := IIf(aALLVeic[nCntVei,11]=="8",STR0029,STR0028) // Pedido / Estoque
			nQtdVei := aALLVeic[nCntVei,06]
			nVlrVei := aALLVeic[nCntVei,07]
			oSection2:PrintLine()
		Next
		oSection2:Finish()
		oSection1:Finish()

	Case nOpcRel == 4 // Todos os Bonus de Venda de um determinado Veiculo (chamado pelo VEIC130)
		oSection1 := oReport:Section(1)
		oSection2 := oReport:Section(2)
		oReport:SetMeter(len(aALLBonus))
		oSection2:Init()
		aALLVeic := aClone(aALLBonus[01,05])
		dDatPed := aALLVeic[01,09]
		dDatVen := aALLVeic[01,10]
		cMarVei := aALLVeic[01,02]
		cModVei := aALLVeic[01,03]
		cCorVei := aALLVeic[01,04]
		cChaVei := aALLVeic[01,05]
		cSitVei := IIf(aALLVeic[01,11]=="8",STR0029,STR0028) // Pedido / Estoque
		nQtdVei := aALLVeic[01,06]
		nVlrVei := aALLVeic[01,07]
		oSection2:PrintLine()
		oSection2:Finish()
		oSection1:Init()
		For nCntFor := 1 to len(aALLBonus)
			oReport:IncMeter()
			cCodBon := aALLBonus[nCntFor,1] + " - " + aALLBonus[nCntFor,2]
			nPerBon := aALLBonus[nCntFor,8]
			dDatIni := aALLBonus[nCntFor,6]
			dDatFin := aALLBonus[nCntFor,7]
			nQtdBon := aALLBonus[nCntFor,3]
			nVlrLiq := aALLBonus[nCntFor,4]
			oSection1:PrintLine()
		Next
		oSection1:Finish()

EndCase
Return Nil