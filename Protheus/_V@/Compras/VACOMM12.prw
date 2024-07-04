#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"
#include "colors.ch"
#INCLUDE "TBICONN.CH"
//#include "MATA235.CH"  

//Constantes // http://erikasarti.com/html/tabela-cores/
#Define CLR_VERMELHO  RGB(255,048,048)	// Cor Vermelha
#Define CLR_VERDE     RGB(119,255,083)	// Cor Verde
#Define CLR_BRANCO    RGB(254,254,254)	// Cor Branco
#Define CLR_CINZA     RGB(180,180,180)	// Cor Cinza
#Define CLR_AZUL      RGB(135,206,250)  // DeepSkyBlue - (058,074,119)	//Cor Azul

//Variaveis
Static _M12Codigo := ""

/*---------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                        |
 | Data:     07.12.2017                                                            |
 | Cliente:  V@                                                                    |
 | Desc:     Rotina de Contrato - Especifico para Milho;		                   |
 |           Este fonte � uma copia do fonte VACOMM12;				               |
 |           		                        									   |
 |---------------------------------------------------------------------------------|
 | Regras:   1- O campo ZBC_VERSAO possue funcao para contagem automatica;         |
 |           2- Preenchimento de campos a partir da selecao do pedido;             |
 |---------------------------------------------------------------------------------|
 | Obs.:     U_VACOMM12()                                                          |
 '---------------------------------------------------------------------------------*/
User Function VACOMM12()

Private cCadastro := "Configuracao Contratual-Milho" //"Configuracao Contratual - NOVO"
Private cAlias    := "ZCC"
Private aRotina   := MenuDef()
Private lRastro   := GetMV('MV_RASTRO') == 'S'

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( cAlias )
	oBrowse:SetMenuDef("VACOMM12")
	oBrowse:SetDescription( cCadastro )
	oBrowse:SetFilterDefault("ZCC->ZCC_TPCONT == 'M'")

	oBrowse:AddLegend( "ZCC->ZCC_STATUS == 'C'", "BLACK" , "Cancelado" )
	oBrowse:AddLegend( "!Empty(U_fVldVersao(ZCC->ZCC_CODIGO, ZCC->ZCC_VERSAO))", "YELLOW", "Versao Anterior" )
	oBrowse:AddLegend( "ZCC->ZCC_STATUS == 'A'", "GREEN" , "Aberto" )
	oBrowse:AddLegend( "ZCC->ZCC_STATUS == 'N'", "WHITE" , "Negocia��o Apta p/ Pedido" )
	oBrowse:AddLegend( "ZCC->ZCC_STATUS == 'P'", "ORANGE", "Finalizado Parcialmente" )
	oBrowse:AddLegend( "ZCC->ZCC_STATUS == 'F'", "RED"   , "Finalizado Totalmente" )

	GeraX1("COMM12VA")

	oBrowse:Activate()
Return nil

/* MJ: 07.12.2017 */
user function VAM12Leg()
local aLegenda := {}

//Monta as cores
AAdd(aLegenda, {"BR_PRETO"		, "Cancelado"})
AAdd(aLegenda, {"BR_AMARELO"	, "Versao Anterior"})
AAdd(aLegenda, {"BR_VERDE"		, "Aberto"  })
AAdd(aLegenda, {"BR_BRANCO"		, "Negocia��o Apta p/ Pedido"  })
AAdd(aLegenda, {"BR_LARANJA"	, "Finalizado Parcialmente"})
AAdd(aLegenda, {"BR_VERMELHO"	, "Finalizado Totalmente"})

BrwLegenda("Transfer�ncias", "Procedencia", aLegenda, 30)

Return nil

/* ------------------------------------------------------------------------------ */
Static Function MenuDef()
Local aRotina := {}
aAdd( aRotina, { 'Pesquisar'            , 'AxPesqui'  , 0, 1, 0, nil  } )
aAdd( aRotina, { 'Visualizar'           , 'U_COMM12VA', 0, 2, 0, nil  } )
aAdd( aRotina, { 'Incluir'              , 'U_COMM12VA', 0, 3, 0, nil  } )
aAdd( aRotina, { 'Alterar'              , 'U_COMM12VA', 0, 4, 0, nil  } )
aAdd( aRotina, { 'Excluir'              , 'U_COMM12VA', 0, 5, 0, nil  } )
aAdd( aRotina, { 'Gerar Vers�o'         , 'U_COMM12VA', 0, 6, 0, nil  } )
aAdd( aRotina, { 'Legenda'         		, 'U_VAM12Leg', 0, 7, 0, nil  } )
aAdd( aRotina, { 'Inf. Complementares'  , 'U_COMM12VA', 0, 4, 0, nil  } )
aAdd( aRotina, { 'Encerrar contrato'	, 'StaticCall(VACOMM12,xAltStatus,"F")', 0, 4, 0, nil  } )
aAdd( aRotina, { 'Cancelar contrato'	, 'StaticCall(VACOMM12,xAltStatus,"C")', 0, 4, 0, nil  } )
aAdd( aRotina, { 'Localiza Pedido'	    , 'U_xFiltroConsulta', 0, 4, 0, nil  } )

Return aRotina

/* ------------------------------------------------------------------
	MJ : 27.10.2017
   ----------------------------------------------------------------- */
Static Function fMenuAux(nOpc)

Local nAt      := o1ZBCGDad:oBrowse:nAt
Local cContrat := M->ZCC_CODIGO
Local cItem    := StrZero(nAt ,TamSX3('ZBC_ITEM')[01])
Local cFornec  := M->ZCC_CODFOR
Local cLojFor  := M->ZCC_LOJFOR

If nOpc == 1
	u_VAFINA02("P", xFilial('ZCC'), cContrat+cItem, cFornec, cLojFor)
Else
	u_VAFINA03("P", xFilial('ZCC'), cContrat+cItem, cFornec, cLojFor)
EndIf

Return nil


/*---------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                        |
 | Data:     06.11.2017                                                            |
 | Cliente:  V@                                                                    |
 | Desc:     Esta Func�o foi criada para validar se todos os campos do contrato    |
 |  estao preenchidos, caso estejam, entao a tabela ZCC sera gravada, liberando    |
 |  assim os quadros ZIC e ZBC;                                                    |
 |---------------------------------------------------------------------------------|
 | Regras:   1- Passar na Funcao: Obrigatorio;                                     |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.:     -                                                                     |
 '---------------------------------------------------------------------------------*/
Static Function M7SlvCrt()
	If Obrigatorio(aGets, aTela)
		DbSelectArea("ZCC")
		ZCC->( DbSetOrder(1) )
		If ZCC->( DbSeek( xFilial('ZCC') + M->ZCC_CODIGO + M->ZCC_VERSAO ))
			Aviso("Aviso", 'O Contrato/Versao: ' + M->ZCC_CODIGO +'/' + M->ZCC_VERSAO + ' j� se encontra salvo no sistema.', {"Sair"} )
		Else
			// Salvar contrato
			RecLock( "ZCC", .T. )
				U_GrvCpo("ZCC")
				ZCC->ZCC_TPCONT := "M"
			ZCC->(MsUnlock())

			// While __lSX8
				ZCC->( ConfirmSX8() )
			// EndDo

			// o1ZBCGDad:Enable()
			oGrpF1Q2:Enable()

			// Aviso("Aviso", 'O Contrato/Versao: ' + M->ZCC_CODIGO +'/' + M->ZCC_VERSAO + ' foi gravado com sucesso.', {"Ok"} )
			MsgInfo('O Contrato/Versao: <b>' + M->ZCC_CODIGO +'/' + M->ZCC_VERSAO + '</b> foi gravado com sucesso.', 'Aviso')
		EndIf
	EndIf
Return nil

// /* MJ : 20.11.2017 */
// Static Function findMark(oGD, nColuna)
// Local cRet 	:= ""
// Local nI	:= 0
// 	For nI := 1 to Len(oGD:aCols)
// 		If oGD:aCols[nI, nColuna] == 'LBTIK'
// 			cRet := oGD:aCols[ nI, nPZICITE ]
// 			Exit
// 		EndIf
// 	Next nI
// Return cRet


/*--------------------------------------------------------------------------------,
 | Principal: 					U_MBCOMR01()             	            	      |
 | Func:  GeraX1()  	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  11.03.2019	            	          	            	              |
 | Desc:  Cria��o de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |         	            	            										  |
 | Obs.:  -	            	            										  |
 '--------------------------------------------------------------------------------*/
Static Function GeraX1(cPerg)

Local _aArea := GetArea()
Local aRegs  := {}
Local nX     := 0
Local nPergs := 0
Local i      := 0, j:=0

//Conta quantas perguntas existem ualmente.
DbSelectArea('SX1')
DbSetOrder(1)
SX1->(DbGoTop())
If SX1->(DbSeek(cPerg))
	While !SX1->(Eof()) .And. X1_GRUPO = cPerg
		nPergs++
		SX1->(DbSkip())
	EndDo
EndIf

aAdd(aRegs,{cPerg, "01", "Executa Validacoes e Gatilhos?", "", "", "MV_CH1", "N", 1, 0, 2, "C", "", "MV_PAR01", "N�o", "", "", "", "", "Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})

//Se quantidade de perguntas for diferente, apago todas
SX1->(DbGoTop())
If nPergs <> Len(aRegs)
	For nX:=1 To nPergs
		If SX1->(DbSeek(cPerg))
			If RecLock('SX1',.F.)
				SX1->(DbDelete())
				SX1->(MsUnlock())
			EndIf
		EndIf
	Next nX
EndIf

// grava��o das perguntas na tabela SX1
If nPergs <> Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	For i := 1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
				For j := 1 to FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					EndIf
				Next j
			MsUnlock()
		EndIf
	Next i
EndIf

RestArea(_aArea)

Return nil
// FIM: GeraX1


/*---------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                        |
 | Data:     07.12.2017                                                            |
 | Cliente:  V@                                                                    |
 | Desc:     Esta rotina � responsavel por realizar as opera��es basicas de cadas- |
 |         tros;                                                                   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras:                                                                         |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.:     -                                                                     |
 '---------------------------------------------------------------------------------*/
User Function COMM12VA(cAlias, nReg, nOpc)
Local nGDOpc         := Iif( nOpc == 2, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
Local nOpcA          := 0
Local oDlg           := nil
Local aSize          := {}
Local aObjects       := {}
Local aInfo          := {}
Local aPObjs         := {}
Local lRecLock       := .T.
Local nPos2Aux       := 0
Local aButtons       := {}
Local cVersao        := ""
Local nI             := 0
Local lPauta         := .F.

// ABA 2 = Entrada
// Local oGrpF2Q1    := nil, oGrpF3Q1		:= nil
// Local oEnchF2Q1   := nil
// Local oEnchF3Q1   := nil, oEnchF3Q3 := nil
Local nF             := 0

Private oEnchF2Q3    := nil
Private aHeadEsp     := {}
Private aColsEsp     := {}
Private nUsadEsp     := 0

Private _cOrden      := "T", _nQtdNF := 0, _nTotNF := 0, _nQtdCpl := 0, _nTotCpl := 0, _nQtdFre := 0, _nTotFre := 0, _nQtdTotNF := 0, _nVlrTotNF := 0, _nMedXKM := 0, _nCstXKM := 0
Private _nQtdCon     := 0, _nTotCom := 0, _nQtdReb := 0

Private /* aFldF2Q1  := {},  *//* aFldF3Q1 	:= {}, */ aFldF2Q3  := {}
Private oTFoldeP     := nil, aFolderP := {}
Private oTFoldeG     := nil, aFolderG := {"Pedidos de Milhos"}, nFldOldG := 1

Private oMGet        := nil
// Private xMatZBC   := {}
Private oGZBCGDad    := nil, aGZBCHead  := {}, aGZBCCols  := {}, nGUZBC := 1
Private o1ZBCGDad    := nil, a1ZBCHead  := {}, a1ZBCCols  := {}// , n1UZBC := 1
// Private o2ZBCGDad := nil, a2ZBCHead  := {}, a2ZBCCols  := {}// , n2UZBC := 1
// Private o3ZBCGDad := nil, a3ZBCHead  := {}, a3ZBCCols  := {}// , n3UZBC := 1
// Private o4ZBCGDad := nil, a4ZBCHead  := {}, a4ZBCCols  := {}// , n4UZBC := 1
// Private o5ZBCGDad := nil, a5ZBCHead  := {}, a5ZBCCols  := {}// , n5UZBC := 1
// Private o6ZBCGDad := nil, a6ZBCHead  := {}, a6ZBCCols  := {}// , n6UZBC := 1
// Private o7ZBCGDad := nil, a7ZBCHead  := {}, a7ZBCCols  := {}// , n7UZBC := 1

Private nPZBCCOD     := 0
Private nPZBCVER     := 0

Private nPZBCITE     := 0, cPFoBCITE := "1"
Private nPZBCZIC     := 0, cPFoBCZIC := "1"
Private nPZBCPed     := 0, cPFoBCPed := "1"
Private nPZBCPIt     := 0, cPFoBCPIt := "1"
Private nPZBCPVs     := 0, cPFoBCPVs := "1"
Private nPZBCPRD     := 0, cPFoBCPRD := "1"
Private nPZBCDES     := 0, cPFoBCDES := "1"
// Private nPZBCPdP     := 0, cPFoBCPdP := "1"
Private nPZBCQtd     := 0, cPFoBCQtd := "1"
Private nPZBCPrc     := 0, cPFoBCPrc := "1"
Private nPZBCTot     := 0, cPFoBCTot := "1"
Private nPZBCArv     := 0, cPFoBCArv := "1"
Private nPZBCToP     := 0, cPFoBCToP := "1"
Private nPZBCVlU     := 0, cPFoBCVlU := "1"
Private nPZBCXTT     := 0, cPFoBCXTT := "1"
Private nPZBCVLI     := 0, cPFoBCVLI := "1"
Private nPZBCVPT     := 0, cPFoBCVPT := "1"
Private nPZBCAIC     := 0, cPFoBCAIC := "1"
Private nPZBCICP     := 0, cPFoBCICP := "1"
Private nPZBCDTE     := 0, cPFoBCDTE := "1"
Private nPZBCTFX     := 0, cPFoBCTFX := "1"
// Private nPZBCOBS     := 0, cPFoBCOBS := "1"
Private nPZBC1IC     := 0, cPFoBC1IC := "1"
Private nPZBCTPN     := 0, cPFoBCTPN := "1"
Private nPZBCCDP     := 0, cPFoBCCDP := "1"

Private nPTPNEGM     := 0, cPFoTPNEGM := "1"
Private nPDTIIND     := 0, cPFoDTIIND := "1"
Private nPDTFIND     := 0, cPFoDTFIND := "1"
Private nPINDFIN     := 0, nPFoINDFIN := "1"

Private nPZBCPNG     := 0, cPFoBCPNG := "1"
Private nPZBCTNG     := 0, cPFoBCTNG := "1"
Private nPZBCOTS     := 0, cPFoBCOTS := "1"
Private nPZBCTES     := 0, cPFoBCTES := "1"
Private nPZBCTPS     := 0, cPFoBCTPS := "1"
Private nPZBCAQS     := 0, cPFoBCAQS := "1"
Private nPZBCVLS     := 0, cPFoBCVLS := "1"
Private nPZBCOMU     := 0, cPFoBCOMU := "1"
Private nPZBCOMT     := 0, cPFoBCOMT := "1"
Private nPZBCOTA     := 0, cPFoBCOTA := "1"
Private nPZBCOFM     := 0, cPFoBCOFM := "1"
Private nPZBCJur     := 0, cPFoBCJur := "1"

Private _ZBC_VLRMED  := 0, nPVLRMED := 0, cPFoVLRMED := "1"
Private _ZBC_OUTACR  := 0, nPOUTACR := 0, nPFoOUTACR := "1"
Private _ZBC_OUTDES  := 0, nPOUTDES := 0, nPFoOUTDES := "1"
Private _ZBC_VLRSAC  := 0, nPVLRSAC := 0, nPFoVLRSAC := "1"


Private nPMrkZBC     := 0

Private aGets        := {}
Private aTela        := {}

Private nFldPant     := 0
// Private nF2Q2Ant  := 0, lF2Q2Cresc := .T. // , lF2Q2Ord := .F.
// Private nF2Q2Cont := 0

RegToMemory( cAlias, nOpc == 3 )

// Carregar em memoria parametro
Pergunte("COMM12VA", .F.)

If nOpc == 4 .and. !Empty(cVersao:= U_fVldVersao(ZCC->ZCC_CODIGO, ZCC->ZCC_VERSAO))
	// Se retornou CODIGO de versao, entao nao posso continuar
	Aviso("Aviso", 'A Versao selecionada: ' + ZCC->ZCC_VERSAO + ' nao pode ser alterada.' + CRLF+;
				   ' O contrato No.: ' + ZCC->ZCC_CODIGO + ' encontra-se autalmente na versao: ' + cVersao, ;
				   {"Sair"})
	Return nil

ElseIf (nOpc == 4 .or. nOpc == 5 .or. nOpc == 6) .and. ZCC->ZCC_STATUS == "C"
	// Se retornou CODIGO de versao, entao nao posso continuar
	Aviso("Aviso", 'O contrato selecionado encontra-se cancelado e n�o pode ser alterado.', {"Sair"})
	Return nil

// MJ : 21.06.2018 => alterado para permitir alteracao, depois da reuniao com CAmila, solicit. por Luana
ElseIf (nOpc == 4 .or. nOpc == 5/*  .or. nOpc == 6 */) .and. ZCC->ZCC_STATUS$"FP"

	If !(lPauta := U_TemPauta())
		// Se retornou CODIGO de versao, entao nao posso continuar
		Aviso("Aviso", 'O contrato selecionado encontra-se finalizado e n�o pode ser alterado.', {"Sair"})
		Return nil
	EndIf

// // MJ : 21.06.2018 => alterado para permitir alteracao, depois da reuniao com CAmila, solicit. por Luana
// ElseIf ( nOpc == 6 .and. ZCC->ZCC_STATUS$"FP" )
	// Alert( 'Agora pode alterar' )

ElseIf nOpc == 5 .and. !Empty(cVersao:= U_fVldVersao(ZCC->ZCC_CODIGO, ZCC->ZCC_VERSAO))
	// Se retornou CODIGO de versao, entao nao posso continuar
	Aviso("Aviso", 'A Versao selecionada: ' + ZCC->ZCC_VERSAO + ' nao pode ser excluida.' + CRLF+;
				   ' O contrato No.: ' + ZCC->ZCC_CODIGO + ' encontra-se autalmente na versao: ' + cVersao, ;
				   {"Sair"})
	Return nil

ElseIf nOpc == 5 .and. !U_fCanDel(ZCC->ZCC_CODIGO, ZCC->ZCC_VERSAO)
	Aviso("Aviso", 'O contrato No.: ' + ZCC->ZCC_CODIGO + ' na versao selecionada: ' + ZCC->ZCC_VERSAO + ' nao pode ser excluida.' + CRLF+;
				   'Existem pedidos de compra vinculados ja a este contrato.' , ;
				   {"Sair"})
	Return nil
EndIf

aSize := MsAdvSize( .T. )
AAdd( aObjects, { 100 , 50, .T. , .T. , .F. } )
AAdd( aObjects, { 100 , 50, .T. , .T. , .F. } )
aInfo  := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
aPObjs := MsObjSize(aInfo, aObjects, .T., .F.)

// os REGISTROS s� poderam ser alterados se o STATUS estiver com status aberto;
If nOpc < 6 .and. !M->ZCC_STATUS$"AN" .and.  nGDOpc <> 0
	If !lPauta
		nGDOpc := 0
	EndIf
EndIf

// Configura��o da Base Contratual
cLstCpo := GetMV("MB_COMM12A",,;
					 "ZBC_CODIGO,ZBC_VERSAO,ZBC_ITEM  ,ZBC_PEDIDO,ZBC_ITEMPC,ZBC_PRODUT,ZBC_PRDDES,ZBC_TPNEGM," +;
					 "ZBC_QUANT ,ZBC_PRECO ,ZBC_TOTAL ,ZBC_TES   ,ZBC_DTIIND,ZBC_DTFIND,ZBC_INDFIN,ZBC_VLRMED,ZBC_OUTACR,ZBC_OUTDES," +;
					 "ZBC_VLRSAC,ZBC_TABDESZBC_VERPED,ZBC_STATUS,ZBC_DTENTR")
// a1ZBCHead  := APBuildHeader("ZBC") // a1ZBCCols  := A610CriaCols( "ZBC", a1ZBCHead, , {|| .F.})
AAdd(aGZBCHead, { " ", Padr("ZBC_MARK", 10), "@BMP", 1, 0, .F., "", "C", "", "V", "", "", "", "V", "", "", "" } )
// BDados(cAlias, aHDados   , aCDados   , nUDados, nOrd, lFilial, cCond, lStatus, cCpoLeg, cLstCpo, cElimina, cCpoNao, cStaReg, cCpoMar, cMarDef, lLstCpo, aLeg, lEliSql, lOrderBy, cCposGrpBy, cGroupBy, aCposIni, aJoin, aCposCalc, cOrderBy, aCposVis, aCposAlt, cCpoFilial, nOpcX, lMostRecNo, lLinMax)
U_BDados( "ZBC" , @aGZBCHead, @aGZBCCols, @nGUZBC, 1   ,/* lFilial */,;
	IIf( nOpc != 3, "'" + M->ZCC_CODIGO + M->ZCC_VERSAO + "' == ZBC->ZBC_CODIGO + ZBC->ZBC_VERSAO", nil  ),; // cCond
	/* lStatus */, /* cCpoLeg */, /* cLstCpo */, /* cElimina */, /* cCpoNao */, /* cStaReg */, /* cCpoMar */,;
	/* cMarDef */, /* lLstCpo */, /* aLeg */, /* lEliSql */, /* lOrderBy */, /* cCposGrpBy */, /* cGroupBy */,; 
	StrToKarr(cLstCpo,",")/* aCposIni */, /* aJoin */, /* aCposCalc */, /* cOrderBy */, /* aCposVis */, /* aCposAlt */,;
	/* cCpoFilial */,/* nOpcX */, /* lMostRecNo */, /* lLinMax */)

// TIRAR OBRIGATORIEDADE - obrigatorio
For nI := 1 to Len(aGZBCHead)
	aGZBCHead[nI, 17] := .F.
Next nI

// AAdd(a1ZBCHead, { " ", Padr("ZBC_MARK", 10), "@BMP", 1, 0, .F., "", "C", "", "V", "", "", "", "V", "", "", "" } )
// U_BDados( "ZBC" , @a1ZBCHead, @a1ZBCCols, @nGUZBC, 1   ,/* lFilial */,;
// 	IIf( nOpc != 3, "'" + M->ZCC_CODIGO + M->ZCC_VERSAO + "' == ZBC->ZBC_CODIGO + ZBC->ZBC_VERSAO", nil  ),; // cCond
// 	/* lStatus */, /* cCpoLeg */, /* cLstCpo */, /* cElimina */, /* cCpoNao */, /* cStaReg */, /* cCpoMar */,;
// 	/* cMarDef */, /* lLstCpo */, /* aLeg */, /* lEliSql */, /* lOrderBy */, /* cCposGrpBy */, /* cGroupBy */,; 
// 	/* aCposIni */, /* aJoin */, /* aCposCalc */, /* cOrderBy */, /* aCposVis */, /* aCposAlt */, /* cCpoFilial */,;
// 	/* nOpcX */, /* lMostRecNo */, /* lLinMax */)

// // 1 = Valor Pedido / Pauta
a1ZBCHead   := aClone(aGZBCHead)
a1ZBCCols   := aClone(aGZBCCols)
// U_TiraDoGrp( @a1ZBCHead, @a1ZBCCols, "!Empty(SX3->X3_FOLDER) .AND. SX3->X3_FOLDER <> '1'",;
// 			 {"ZBC_SEXO",;
// 			  "ZBC_RACA",;
// 			  "ZBC_PRODUT",;
// 			  "ZBC_TEMDIA",;
// 			  "ZBC_VLRDIA",;
// 			  "ZBC_VLRPTA",;
// 			  })
//
nPMrkZBC    := aScan( a1ZBCHead, { |x| AllTrim(x[2]) == 'ZBC_MARK'})
nPZBCCOD    := aScan( a1ZBCHead, { |x| AllTrim(x[2]) == 'ZBC_CODIGO'})
nPZBCVER    := aScan( a1ZBCHead, { |x| AllTrim(x[2]) == 'ZBC_VERSAO'})
nPZBCITE    := RetPosCpoAba( "ZBC_ITEM"  , @cPFoBCITE )
nPZBCPed    := RetPosCpoAba( "ZBC_PEDIDO", @cPFoBCPed )
nPZBCPIt    := RetPosCpoAba( "ZBC_ITEMPC", @cPFoBCPIt )
nPZBCPRD    := RetPosCpoAba( "ZBC_PRODUT", @cPFoBCPRD )
nPZBCDES    := RetPosCpoAba( "ZBC_PRDDES", @cPFoBCDES )
// nPZBCPdP    := RetPosCpoAba( "ZBC_PEDPOR", @cPFoBCPdP )
nPZBCQtd    := RetPosCpoAba( "ZBC_QUANT" , @cPFoBCQtd )
nPZBCPrc    := RetPosCpoAba( "ZBC_PRECO" , @cPFoBCPrc )
nPZBCTot    := RetPosCpoAba( "ZBC_TOTAL" , @cPFoBCTot )
nPZBCVPT    := RetPosCpoAba( "ZBC_VLRPTA", @cPFoBCVPT )
nPZBCAIC    := RetPosCpoAba( "ZBC_ALIICM", @cPFoBCAIC )
nPZBCICP    := RetPosCpoAba( "ZBC_VICMPA", @cPFoBCICP )
nPZBCDTE    := RetPosCpoAba( "ZBC_DTENTR", @cPFoBCDTE )
nPZBC1IC    := RetPosCpoAba( "ZBC_SB1ZIC", @cPFoBC1IC )
nPZBCCDP    := RetPosCpoAba( "ZBC_CONDPA", @cPFoBCCDP )
nPTPNEGM    := aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_TPNEGM" } )
nPDTIIND    := aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_DTIIND" } )
nPDTFIND    := aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_DTFIND" } )
nPINDFIN    := aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_INDFIN" } )
nPVLRMED    := aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_VLRMED" } )
nPOUTACR    := aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_OUTACR" } ) // Outros Acrescimos
nPOUTDES    := aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_OUTDES" } ) // Outros Acrescimos
nPVLRSAC    := aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_VLRSAC" } ) // Valor final por saca
nPZBCTES    := aScan( a1ZBCHead, { |x| AllTrim(x[2]) == "ZBC_TES" } ) // Valor final por saca

// a1ZBCCols := aClone( a1ZBCCols[1] )

If nOpc == 3
	M->ZCC_CODIGO	:= GETSX8NUM('ZCC','ZCC_CODIGO')
	M->ZCC_VERSAO   := StrZero( 1, TamSX3('ZCC_VERSAO')[1])
Else

	// Processa/Atualiza campo Versao
	If nOpc == 6 // NOVA VERSAO

		M->ZCC_VERSAO := U_fChvITEM( "ZCC", "ZCC_CODIGO", "ZCC_VERSAO", "ZCC_CODIGO", ZCC->ZCC_CODIGO)
		M->ZCC_STATUS := "A"
		// Base Contratual
		nI := 1
		nPos2Aux := aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_VERPED"} )
		For nI := 1 to Len(a1ZBCCols)
			cChave := ZCC->ZCC_CODIGO + ZCC->ZCC_VERSAO + a1ZBCCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_PEDIDO"})] + a1ZBCCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEMPC"})]
			a1ZBCCols[ nI, nPos2Aux ] := U_fChvITEM('ZBC','ZBC_CODIGO, ZBC_VERSAO, ZBC_PEDIDO, ZBC_ITEMPC', 'ZBC_VERPED', 'ZBC_CODIGO+ZBC_VERSAO+ZBC_PEDIDO+ZBC_ITEMPC', cChave )
		Next nI
	EndIf

EndIf

// Desenhando todos os quadros
__cDescSB1 := Posicione("SB1", 1, xFilial("SB1")+GetMV("MB_COMM12B",,"020017"), "B1_DESC")
For nI := 1 to Len(a1ZBCCols)
	If Empty( a1ZBCCols[ nI, nPMrkZBC] )
		a1ZBCCols[ nI, nPMrkZBC] := "LBNO"
		a1ZBCCols[ nI, nPZBCCOD] := iIf(nOpc==4, ZCC->ZCC_CODIGO, M->ZCC_CODIGO)
		a1ZBCCols[ nI, nPZBCVER] := iIf(nOpc==4, ZCC->ZCC_VERSAO, M->ZCC_VERSAO)
		a1ZBCCols[ nI, nPZBCPRD] := SB1->B1_COD
		a1ZBCCols[ nI, nPZBCDES] := SB1->B1_DESC
		a1ZBCCols[ nI, nPINDFIN] := GETMV("MB_COMM12C",,"000003")
	EndIf
Next nI


DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From 0,0 to aSize[6],aSize[5] PIXEL STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )  // tirar o X da tela | tirar o botao X da tela |
oDlg:lMaximized := .T.

nDist := 3
aFolderP := {"Contrato", "Entrada", "Financeiro", "Estoque"} // Principal
// TFolder():New( [ nTop ], [ nLeft ], [ aPrompts ], [ aDialogs ], [ oWnd ], [ nOption ], [ nClrFore ], [ uParam8 ], [ lPixel ], [ uParam10 ],
//                [ nWidth ], [ nHeight ], [ cMsg ], [ uParam14 ] )
oTFoldeP := TFolder():New( 0, 0, aFolderP,,oDlg,,,,.T.,, 0, 0)
oTFoldeP:Align := CONTROL_ALIGN_ALLCLIENT
oTFoldeP:bChange   := { || FldChang(nOpc) }

// Contrato
nCut := 45
// TGroup():New( [ nTop ], [ nLeft ], [ nBottom ], [ nRight ], [ cCaption ], [ oWnd ], [ nClrText ], [ nClrPane ], [ lPixel ], [ uParam10 ] )
oGrpF1Q1  := TGroup():New( nDist, aPObjs[1,2]+nDist, aPObjs[1,3]-nDist-nCut, aPObjs[1,4]-nDist,;
						"Dados Gerais do Contrato",oTFoldeP:aDialogs[1],,, .T.,)
// MsmGet(): New ( [ cAlias], [ uPar2], < nOpc>, [ uPar4], [ uPar5], [ uPar6], [ aAcho], ;
//				   [ aPos]/*{"TOP","LEFT","BOTTOM","RIGHT"}*/, [ aCpos], [ nModelo], [ uPar11], [ uPar12], [ uPar13], [ oWnd], [ lF3], [ lMemoria], [ lColumn], [ caTela], [ lNoFolder], [ lProperty], [ aField], [ aFolder], [ lCreate], [ lNoMDIStretch], [ uPar25] )
oMGet  := MsMGet():New( cAlias, nReg, Iif(nGDOpc==0,2,nOpc),,,,, ;
				/* { aPObjs[1,1]-nDist, aPObjs[1,2], aPObjs[1,3], aPObjs[1,4] } */ aPObjs[1] ;
				,,,,,, oGrpF1Q1,/*lF3*/,/*lMemoria*/,/*lColumn*/,/*caTela*/,/*lNoFolder*/,/*lProperty*/,/* aField */,;
			/* aFolder */,/*lCreate*/, .T./*lNoMDIStretch*/,/*cTela*/)
oMGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT

if M->ZCC_STATUS == 'N'
	oMGet:Disable()
EndIf

// TGroup():New( [ nTop ], [ nLeft ], [ nBottom ], [ nRight ], [ cCaption ], [ oWnd ], [ nClrText ], [ nClrPane ], [ lPixel ], [ uParam10 ] )
oGrpF1Q2  := TGroup():New( aPObjs[2,1]-nCut, aPObjs[2,2]+nDist, aPObjs[2,3]-nDist-(nCut+10), aPObjs[2,4]-nDist, ;
						"Configura��o da Base Contratual", oTFoldeP:aDialogs[1],,, .T.,)
// TFolder():New( [ nTop ], [ nLeft ], [ aPrompts ], [ aDialogs ], [ oWnd ], [ nOption ], [ nClrFore ], [ uParam8 ]
// 				, [ lPixel ], [ uParam10 ], [ nWidth ], [ nHeight ], [ cMsg ], [ uParam14 ] )

// // quando tiver mais que 1 folder, leitura automatica na SX3
// SXA->(DbSetOrder(1))
// If SXA->(DbSeek( "ZBC" ))
// 	While !SXA->(Eof()) .and. SXA->XA_ALIAS == "ZBC"
//
// 		aAdd( aFolderG, SXA->XA_DESCRIC )
//
// 		SXA->(DbSkip())
// 	EndDo
// EndIf

oTFoldeG := TFolder():New( 0, 0, aFolderG,, oGrpF1Q2,,,,.T.,,0, 0 )
oTFoldeG:Align   := CONTROL_ALIGN_ALLCLIENT
// oTFoldeG:bChange := {|| Processa({ || ProcessMessages(), ;
// 									  ReLoadFolder( oTFoldeG:nOption ) }, ;
// 									  "Atualizando Tabela da Aba: " + cValToChar(oTFoldeG:nOption) ) }

oGZBCGDad := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , "+ZBC_ITEM" , , , , , , "u_ZBCDelOk(oGZBCGDad)", ;
				oDlg, aClone(aGZBCHead), aClone( aGZBCCols ) )

// 1 = Valores Pedido/Pauta
o1ZBCGDad := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , "+ZBC_ITEM" , , , , , , "u_ZBCDelOk(o1ZBCGDad)", ;
				oTFoldeG:aDialogs[1], aClone(a1ZBCHead), aClone( a1ZBCCols ) )
o1ZBCGDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
o1ZBCGDad:cFieldOK := "U_miZBCFieldOK()"
o1ZBCGDad:oBrowse:BlDblClick := { || If( o1ZBCGDad:oBrowse:nColPos == 1 .and. fCanSelBC(), SetMark(o1ZBCGDad, , nPMrkZBC), o1ZBCGDad:EditCell() ) }
// o1ZBCGDad:bChange  := {|| ZBCbChange() }
// o1ZBCGDad:bLinhaOK := {|| ZBCLinOK() }
// o1ZBCGDad:cDelOK := "u_ZBCDelOk()"
// o1ZBCGDad:oBrowse:BlDblClick := {|| DbClickZBC() }  // no campo X3_VLDUSER
// xVarM := ClassMethArr( o1ZBCGDad , .T. ) // Magica
// xVarD := ClassDataArr( o1ZBCGDad , .T. ) // Magica


// folder: ENTRADA ##########################################################################################
nF2_3x	  := aPObjs[2,3] / 3
// TGroup():New( [ nTop ], [ nLeft ], [ nBottom ], [ nRight ], [ cCaption ], [ oWnd ], [ nClrText ], [ nClrPane ], [ lPixel ], [ uParam10 ] )
// oGrpF2Q1  := TGroup():New( nDist, aPObjs[1,2]+nDist, nF2_3x*0.5, aPObjs[1,4]-nDist,;
//							"Parametros:",oTFoldeP:aDialogs[2],,, .T.,)
//                Titulo,      Campo,      Tipo, Tamanho, Decimal, Pict, Valid, Obrigat,  Nivel, Inic Padr,    F3, When, Visual, Chave,            CBox, Folder, N Alteravel, PictVar, Gatilho
// aAdd(aFldF2Q1, { "Ordenacao",  "_cOrden",   "C",       1,       0, "@!",      ,     .F.,     1,         "", "   ",   "",    .F.,   .F., "T=Tipo;D=Data",      1,         .F.,      "",      "N"} )
// oEnchF2Q1 := MsMGet():New(,, 3,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/, aPObjs[1],/*aAlterEnch*/,/*nModelo*/,;
// 					/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oGrpF2Q1,/*lF3*/,/*lMemoria*/, .F./*lColumn*/,;
// 					nil /*caTela*/,/*lNoFolder*/, .T./*lProperty*/,aFldF2Q1,/*aFolder*/,/*lCreate*/,/*lNoMDIStretch*/,/*cTela*/)
// oEnchF2Q1:oBox:Align := CONTROL_ALIGN_ALLCLIENT
//
// //SButton():New( [ nTop ], [ nLeft ], [ nType ], [ bAction ], [ oWnd ], [ lEnable ], [ cMsg ], [ bWhen ] )
// oSButton := SButton():New( nF2_3x*0.5-20, aPObjs[1,4]-60-nDist, 9, {|| LoadF2Q2() }, oGrpF2Q1/* oDlg */, .T.,"Ordena��o",)


oGrpF2Q2  := TGroup():New( /* nF2_3x*0.5+ */nDist, aPObjs[1,2]+nDist, nF2_3x*1.6, aPObjs[1,4]-nDist,;
							"Notas Fiscais de Entrada:",oTFoldeP:aDialogs[2],,, .T.,)
aHeadEsp := {}
aColsEsp := {}
/*01*/ aAdd(aHeadEsp,{ "Tipo"			, "TIPO"		, "@!"		                   , 020, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*02*/ aAdd(aHeadEsp,{ "Nota Fiscal" 	, "NOTA_FISCAL"	, "@!"		                   , 015, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*02*/ aAdd(aHeadEsp,{ "Cod Fornecedor" , "COD_FORNECE"	, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*03*/ aAdd(aHeadEsp,{ "Fornecedor"     , "A2_NOME"	    , "@!"		                   , 030, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*04*/ aAdd(aHeadEsp,{ "Dt Emissao"		, "D1_EMISSAO"	, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "D", "", "R","","","","A","","",""})
/*05*/ aAdd(aHeadEsp,{ "Cod. Produto"   , "D1_COD"	    , "@!"		                   , 015, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*06*/ aAdd(aHeadEsp,{ "Unid. Med."     , "D1_UM"	    , "@!"		                   , 005, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*07*/ aAdd(aHeadEsp,{ "Quant."	    	, "D1_QUANT"	, PesqPict("SD1", "D1_QUANT")  , TamSX3("D1_QUANT")[1]  , TamSX3("D1_QUANT")[2] ,"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
/*08*/ aAdd(aHeadEsp,{ "R$ Unit."	    , "D1_VUNIT"	, PesqPict("SD1", "D1_VUNIT")  , TamSX3("D1_VUNIT")[1]  , TamSX3("D1_VUNIT")[2] ,"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
/*09*/ aAdd(aHeadEsp,{ "R$ Total"	    , "D1_TOTAL"	, PesqPict("SD1", "D1_TOTAL")  , TamSX3("D1_TOTAL")[1]  , TamSX3("D1_TOTAL")[2] ,"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
/*10*/ aAdd(aHeadEsp,{ "R$ ICMS"	    , "D1_VALICM"	, PesqPict("SD1", "D1_VALICM") , TamSX3("D1_VALICM")[1] , TamSX3("D1_VALICM")[2],"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
/*11*/ aAdd(aHeadEsp,{ "Cod. Fiscal"    , "D1_CF"		, "@!"		                   , 004, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*12*/ aAdd(aHeadEsp,{ "Km"   			, "D1_X_KM"		, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*13*/ aAdd(aHeadEsp,{ "Peso Chegada"	, "D1_X_PESCH"	, PesqPict("SD1", "D1_X_PESCH"), TamSX3("D1_X_PESCH")[1], TamSX3("D1_X_PESCH")[2],"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
/*14*/ aAdd(aHeadEsp,{ "Dt Embarque"	, "D1_X_EMBDT"	, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "D", "", "R","","","","A","","",""})
/*15*/ aAdd(aHeadEsp,{ "Hr Embarque"    , "D1_X_EMBHR"	, "@!"		                   , 004, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
/*16*/ aAdd(aHeadEsp,{ "Dt Chegada"		, "D1_X_CHEDT"	, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "D", "", "R","","","","A","","",""})
/*17*/ aAdd(aHeadEsp,{ "Hr Chegada"     , "D1_X_CHEHR"	, "@!"		                   , 004, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
nUsadEsp := len(aHeadEsp)

// 										   GD_INSERT + GD_UPDATE + GD_DELETE
oGetF2Q2:= MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE,,,,,,,,,,oGrpF2Q2, aHeadEsp, aColsEsp)
oGetF2Q2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetF2Q2:oBrowse:lUseDefaultColors := .F.
oGetF2Q2:oBrowse:SetBlkBackColor({|| GETDCLR( oGetF2Q2 )})
// oGetF2Q2:lCanEditLine := .F.
// {|oBrw,nCol,aDim| If( Self:lCanEditLine, (oBrw:nColPos := nCol,GetCellRect(oBrw,@aDim),GetDEditMenu(Self,aDim)),)} // original
oGetF2Q2:oBrowse:bHeaderClick := { |oGetF2Q2,nCol| OrdenaF2Q2(nCol) }


oGrpF2Q3  := TGroup():New( nF2_3x*1.6+nDist, aPObjs[1,2]+nDist, aPObjs[2,3]-nDist-(nCut+10), aPObjs[1,4]-nDist,;
							"Resumos:",oTFoldeP:aDialogs[2],,, .T.,)
aAdd(aFldF2Q3, { "Qtd Notas: "       		, "_nQtdNF"   , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Total Notas: "     		, "_nTotNF"   , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Qtd NF Compl:"     		, "_nQtdCpl"  , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Total Complemento:"		, "_nTotCpl"  , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Qtd NF Frete:"     		, "_nQtdFre"  , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Total Frete:"      		, "_nTotFre"  , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "M�dia KM:"	 	 		, "_nMedXKM"  , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Custo por KM:"	 		, "_nCstXKM"  , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Quant Total Notas:"		, "_nQtdTotNF", "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "R$ Total Notas:"	 		, "_nVlrTotNF", "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Total Comiss�o:"	 		, "_nTotCom"  , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Qtd Animais no Contrato:"	, "_nQtdCon"  , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )
aAdd(aFldF2Q3, { "Qtd Animais Receb. em NF:", "_nQtdReb"  , "N", TamSX3("D1_TOTAL")[1], TamSX3("D1_TOTAL")[2], X3Picture('D1_TOTAL'), /* { || VldCpo(2) } */,     .F.,     1, /* GetSX8Num('ZAD','ZAD_CODIGO') */, "",  "" ,    .T.,   .F.,   "",     "",         .F.,      "",    "N"} )

oEnchF2Q3 := MsMGet():New(,, 3,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/, aPObjs[1],/*aAlterEnch*/,/*nModelo*/,;
					/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oGrpF2Q3,/*lF3*/,/*lMemoria*/, .F./*lColumn*/,;
					nil /*caTela*/,/*lNoFolder*/, .T./*lProperty*/,aFldF2Q3,/*aFolder*/,/*lCreate*/,/*lNoMDIStretch*/,/*cTela*/)
oEnchF2Q3:oBox:Align := CONTROL_ALIGN_ALLCLIENT

// folder: ENTRADA ##########################################################################################


// folder: FINANCEIRO ##########################################################################################

nF3_3x	  := aPObjs[2,3] / 3
// TGroup():New( [ nTop ], [ nLeft ], [ nBottom ], [ nRight ], [ cCaption ], [ oWnd ], [ nClrText ], [ nClrPane ], [ lPixel ], [ uParam10 ] )
// oGrpF3Q1  := TGroup():New( nDist, aPObjs[1,2]+nDist, nF3_3x*0.5, aPObjs[1,4]-nDist,;
// 							"Parametros:",oTFoldeP:aDialogs[3],,, .T.,)
//
// //                Titulo,      Campo,      Tipo, Tamanho, Decimal, Pict, Valid, Obrigat,  Nivel, Inic Padr,    F3, When, Visual, Chave,            CBox, Folder, N Alteravel, PictVar, Gatilho
// aAdd(aFldF3Q1, { "Ordenacao",  "_cOrden",   "C",       1,       0, "@!",      ,     .F.,     1,         "", "   ",   "",    .F.,   .F., "T=Tipo;D=Data",      1,         .F.,      "",      "N"} )
// oEnchF3Q1 := MsMGet():New(,, 3,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/, aPObjs[1],/*aAlterEnch*/,/*nModelo*/,;
// 					/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oGrpF3Q1,/*lF3*/,/*lMemoria*/, .F./*lColumn*/,;
// 					nil /*caTela*/,/*lNoFolder*/, .T./*lProperty*/,aFldF3Q1,/*aFolder*/,/*lCreate*/,/*lNoMDIStretch*/,/*cTela*/)
// oEnchF3Q1:oBox:Align := CONTROL_ALIGN_ALLCLIENT
//
// //SButton():New( [ nTop ], [ nLeft ], [ nType ], [ bAction ], [ oWnd ], [ lEnable ], [ cMsg ], [ bWhen ] )
// oSButton := SButton():New( nF3_3x*0.5-20, aPObjs[1,4]-60-nDist, 9, {|| Iif(_cOrden=="T",aSort( oGetF3aQ2:aCols ,,, {|x,y| x[3] < y[3] } ),aSort( oGetF3aQ2:aCols ,,, {|x,y| x[7] < y[7] } )), oGetF3aQ2:Refresh() }, oGrpF3Q1/* oDlg */, .T.,"Ordena��o",)


oGrpF3Q2  := TGroup():New( /* nF3_3x*0.5+ */nDist, aPObjs[1,2]+nDist, nF3_3x*1.6, aPObjs[1,4]-nDist,;
							"Titulos Financeiros:",oTFoldeP:aDialogs[3],,, .T.,)
oTFldF3Q2 := TFolder():New( 0, 0, {"Contas a Pagar", "Movimenta��o Banc�ria"},, oGrpF3Q2,,,,.T.,,0, 0 )
oTFldF3Q2:Align   := CONTROL_ALIGN_ALLCLIENT

aHeadEsp := {}
aColsEsp := {}
aAdd(aHeadEsp,{ "Fornecedor"	, "FORNECEDOR"	, "@!"		                   , 030, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Numero"   	 	, "E2_NUM"	    , "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Prefixo" 		, "E2_PREFIXO"	, "@!"		                   , 003, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Tipo"			, "E2_TIPO"		, "@!"		                   , 003, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Parcela"    	, "E2_PARCELA"	, "@!"		                   , 002, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Dt Emissao"	, "E2_EMISSAO"	, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "D", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Dt Vcto Real"	, "E2_VENCREA"	, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "D", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "R$ Titulo"		, "E2_VALOR"	, PesqPict("SE2", "E2_VALOR")  , TamSX3("E2_VALOR")[1]  , TamSX3("E2_VALOR")[2] ,"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "R$ Saldo"		, "E2_SALDO"	, PesqPict("SE2", "E2_SALDO")  , TamSX3("E2_SALDO")[1]  , TamSX3("E2_SALDO")[2] ,"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Hist�rico"    	, "E2_HIST"		, "@!"		                   , 255, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Natureza"    	, "NATUREZA"	, "@!"		                   , 030, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
nUsadEsp := len(aHeadEsp)

// LoadNewGDados("oGetF3aQ2", aHeadEsp, @aColsEsp, nUsadEsp) => LoadGrids()

oGetF3aQ2:= MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE,,,,,,,,,,oTFldF3Q2:aDialogs[1], aHeadEsp, aColsEsp)
oGetF3aQ2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetF3aQ2:oBrowse:bHeaderClick := { |oGetF3aQ2,nCol| OrdenaF3aQ2(nCol) }

// oGetF3aQ2:oBrowse:lUseDefaultColors := .F.
// oGetF3aQ2:oBrowse:SetBlkBackColor({|| GETDCLR( oGetF3aQ2 )})

// ABA 2 - Quadro 2

aHeadEsp := {}
aColsEsp := {}
aAdd(aHeadEsp,{ "Filial"		, "E5_FILIAL"	, "@!"		                   , 002, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Tipo"   	 	, "E5_TIPO"	    , "@!"		                   , 002, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Prefixo"		, "E5_PREFIXO"	, "@!"		                   , 003, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Mot. Baixa" 	, "E5_MOTBX"	, "@!"		                   , 003, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Natureza"    	, "E5_NATUREZ"	, "@!"		                   , 002, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Beneficiado"   , "E5_BENEF"	, "@!"		                   , 030, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Hist�rico"   	, "E5_HISTOR"	, "@!"		                   , 030, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "R$ Titulo"		, "E5_VALOR"	, PesqPict("SE5", "E5_VALOR")  , TamSX3("E5_VALOR")[1]  , TamSX3("E5_VALOR")[2] ,"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Documento"   	, "E5_DOCUMEN"	, "@!"		                   , 030, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Banco"   		, "BANCO"		, "@!"		                   , 030, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
nUsadEsp := len(aHeadEsp)

// LoadNewGDados("oGetF3bQ2", aHeadEsp, @aColsEsp, nUsadEsp)

oGetF3bQ2:= MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE,,,,,,,,,,oTFldF3Q2:aDialogs[2], aHeadEsp, aColsEsp)
oGetF3bQ2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetF3bQ2:oBrowse:bHeaderClick := { |oGetF3bQ2,nCol| OrdenaF3bQ2(nCol) }

oGrpF3Q3  := TGroup():New( nF3_3x*1.6+nDist, aPObjs[1,2]+nDist, aPObjs[2,3]-nDist-(nCut+10), aPObjs[1,4]-nDist,;
							"Resumos Financeiros:",oTFoldeP:aDialogs[3],,, .T.,)
aHeadEsp := {}
aColsEsp := {}
aAdd(aHeadEsp,{ "Fornecedor"    , "FORNECEDOR"		, "@!"		                   , 030, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Prefixo"   	, "E2_PREFIXO"		, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Tipo"   		, "E2_TIPO"			, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "R$ Valor"		, "E2_VALOR"		, PesqPict("SE2", "E2_VALOR")  , TamSX3("E2_VALOR")[1]  , TamSX3("E2_VALOR")[2] ,"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "R$ Saldo"		, "SALDO"			, PesqPict("SE2", "E2_SALDO")  , TamSX3("E2_SALDO")[1]  , TamSX3("E2_SALDO")[2] ,"AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Natureza"   	, "NATUREZA"		, "@!"		                   , 050, 0,"AllwaysTrue()" , "" , "C", "", "R","","","","A","","",""})
nUsadEsp := len(aHeadEsp)

// LoadNewGDados("oGetF3Q3", aHeadEsp, @aColsEsp, nUsadEsp)

oGetF3Q3:= MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE,,,,,,,,,,oGrpF3Q3, aHeadEsp, aColsEsp)
oGetF3Q3:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetF3Q3:oBrowse:bHeaderClick := { |oGetF3Q3,nCol| OrdenaF3Q3(nCol) }

// folder: FINANCEIRO ##########################################################################################


// folder: ESTOQUE ##########################################################################################
nF4_3x	  := (aPObjs[2,3]-65) / 3
nF4C2 	  := aPObjs[1,4] / 2

oGrpF4Q4E := TGroup():New( nDist, aPObjs[1,2]+nDist, nF4_3x, nF4C2-nDist,;
							"Estoque:",oTFoldeP:aDialogs[4],,, .T.,)
aHeadEsp := {}
aColsEsp := {}
aAdd(aHeadEsp,{ "Cod. Prod.", "B8_PRODUTO"	, "@!"		                   , 17                     , 0                      , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Descri��o" , "B1_DESC"		, "@!"		                   , 15                     , 0                      , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Saldo" 	, "B8_SALDO"	, PesqPict("SB8", "B8_SALDO")  , TamSX3("B8_SALDO")[1]  , TamSX3("B8_SALDO")[2]  , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Lote" 		, "B8_LOTECTL"	, "@!"		                   , TamSX3("B8_LOTECTL")[1], TamSX3("B8_LOTECTL")[2], "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Curral" 	, "B8_X_CURRA"	, "@!"		                   , TamSX3("B8_X_CURRA")[1], TamSX3("B8_X_CURRA")[2], "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Dt Confina", "B8_XDATACO"	, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "D", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Peso Conf" , "B8_XPESOCO"	, PesqPict("SB8", "B8_XPESOCO"), TamSX3("B8_XPESOCO")[1], TamSX3("B8_XPESOCO")[2], "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
nUsadEsp := len(aHeadEsp)

// LoadNewGDados("oGetF4Q4E", aHeadEsp, @aColsEsp, nUsadEsp)

oGetF4Q4E:= MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE,,,,,,,,,, oGrpF4Q4E, aHeadEsp, aColsEsp)
oGetF4Q4E:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGrpF4Q5D := TGroup():New( nDist, nF4C2+nDist, nF4_3x, aPObjs[1,4]-nDist,;
							"Faturamento:",oTFoldeP:aDialogs[4],,, .T.,)
aHeadEsp := {}
aColsEsp := {}
aAdd(aHeadEsp,{ "Cod. Prod.", "D2_COD"	    , "@!"		                   , 17                     , 0                      , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Descri��o" , "B1_DESC"		, "@!"		                   , 15                     , 0                      , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Quant" 	, "D2_QUANT"	, PesqPict("SD2", "D2_QUANT")  , TamSX3("D2_QUANT")[1]  , TamSX3("D2_QUANT")[2]  , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Lote" 		, "D2_LOTECTL"	, "@!"		                   , TamSX3("D2_LOTECTL")[1], TamSX3("D2_LOTECTL")[2], "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Dt Emissao", "D2_EMISSAO"	, "@!"		                   , 010, 0,"AllwaysTrue()" , "" , "D", "", "R","","","","A","","",""})
nUsadEsp := len(aHeadEsp)

// LoadNewGDados("oGetF4Q5D", aHeadEsp, @aColsEsp, nUsadEsp)

oGetF4Q5D:= MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE,,,,,,,,,, oGrpF4Q5D, aHeadEsp, aColsEsp)
oGetF4Q5D:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGrpF4Q2E := TGroup():New( nF4_3x+nDist, aPObjs[1,2]+nDist, nF4_3x*2+nDist, nF4C2-nDist,;
							"Morte:",oTFoldeP:aDialogs[4],,, .T.,)
aHeadEsp := {}
aColsEsp := {}
aAdd(aHeadEsp,{ "Cod. Prod.", "D3_COD"		, "@!"		                 , 17                     , 0                      , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Descri��o" , "B1_DESC"		, "@!"		                 , 15                     , 0                      , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Quant."	, "D3_QUANT"	, PesqPict("SD3", "D3_QUANT"), TamSX3("D3_QUANT")[1]  , TamSX3("D3_QUANT")[2]  , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Dt Emissao", "D3_EMISSAO"	, "@!"		                 , 010, 0,"AllwaysTrue()" , "" , "D", "", "R","","","","A","","",""})
// aAdd(aHeadEsp,{ "Observa��o", "D3_OBSERVA"	, "@!"		                 , TamSX3("D3_OBSERVA")[1], TamSX3("D3_OBSERVA")[2], "AllwaysTrue()", "" , "M", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Observa��o", "D3_X_OBS"	, "@!"		                 , TamSX3("D3_X_OBS")[1]  , TamSX3("D3_X_OBS")[2]  , "AllwaysTrue()", "" , "M", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Usuario"   , "D3_USUARIO"	, "@!"		                 , TamSX3("D3_USUARIO")[1], TamSX3("D3_USUARIO")[2], "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
nUsadEsp := len(aHeadEsp)

// LoadNewGDados("oGetF4Q2E", aHeadEsp, @aColsEsp, nUsadEsp)

oGetF4Q2E:= MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE,,,,,,,,,, oGrpF4Q2E, aHeadEsp, aColsEsp)
oGetF4Q2E:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGrpF4Q3D := TGroup():New( nF4_3x+nDist, nF4C2+nDist, nF4_3x*2+nDist, aPObjs[1,4]-nDist,;
							"Nascimento:",oTFoldeP:aDialogs[4],,, .T.,)
aHeadEsp := {}
aColsEsp := {}
aAdd(aHeadEsp,{ "Cod. Prod.", "D3_COD"		, "@!"		                 , 17                     , 0                      , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Descri��o" , "B1_DESC"		, "@!"		                 , 15                     , 0                      , "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Quant."	, "D3_QUANT"	, PesqPict("SD3", "D3_QUANT"), TamSX3("D3_QUANT")[1]  , TamSX3("D3_QUANT")[2]  , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Dt Emissao", "D3_EMISSAO"	, "@!"		                 , 010, 0,"AllwaysTrue()" , "" , "D", "", "R","","","","A","","",""})
// aAdd(aHeadEsp,{ "Observa��o", "D3_OBSERVA"	, "@!"		                 , TamSX3("D3_OBSERVA")[1], TamSX3("D3_OBSERVA")[2], "AllwaysTrue()", "" , "M", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Observa��o", "D3_X_OBS"	, "@!"		                 , TamSX3("D3_X_OBS")[1]  , TamSX3("D3_X_OBS")[2]  , "AllwaysTrue()", "" , "M", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Usuario"   , "D3_USUARIO"	, "@!"		                 , TamSX3("D3_USUARIO")[1], TamSX3("D3_USUARIO")[2], "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
nUsadEsp := len(aHeadEsp)

// LoadNewGDados("oGetF4Q3D", aHeadEsp, @aColsEsp, nUsadEsp)

oGetF4Q3D:= MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE,,,,,,,,,, oGrpF4Q3D, aHeadEsp, aColsEsp)
oGetF4Q3D:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGrpF4Q1  := TGroup():New( nF4_3x*2+nDist, aPObjs[1,2]+nDist, nF4_3x*3+nDist, aPObjs[1,4]-nDist,;
							"Resumo:",oTFoldeP:aDialogs[4],,, .T.,)
aHeadEsp := {}
aColsEsp := {}
aAdd(aHeadEsp,{ "Nro Lote"	, "NUMERO_LOTE"	, "@!"		                 , 012				  , 					 0, "AllwaysTrue()", "" , "C", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Compra"	, "ZBC_COMPRA"	, PesqPict("SB8", "B8_SALDO"), TamSX3("B8_SALDO")[1], TamSX3("B8_SALDO")[2] , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Sld Lote"	, "SALDO_B8"	, PesqPict("SB8", "B8_SALDO"), TamSX3("B8_SALDO")[1], TamSX3("B8_SALDO")[2] , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Faturado"	, "FATURADO"	, PesqPict("SB8", "B8_SALDO"), TamSX3("B8_SALDO")[1], TamSX3("B8_SALDO")[2] , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Morte"		, "MORTE"		, PesqPict("SB8", "B8_SALDO"), TamSX3("B8_SALDO")[1], TamSX3("B8_SALDO")[2] , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Nascimento", "NASCIMENTO"	, PesqPict("SB8", "B8_SALDO"), TamSX3("B8_SALDO")[1], TamSX3("B8_SALDO")[2] , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Total"		, "TOTAL"		, PesqPict("SB8", "B8_SALDO"), TamSX3("B8_SALDO")[1], TamSX3("B8_SALDO")[2] , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
aAdd(aHeadEsp,{ "Diferen�a"	, "DIFERE"		, PesqPict("SB8", "B8_SALDO"), TamSX3("B8_SALDO")[1], TamSX3("B8_SALDO")[2] , "AllwaysTrue()", "" , "N", "", "R","","","","A","","",""})
nUsadEsp := len(aHeadEsp)

// LoadNewGDados("oGetF4Q1", aHeadEsp, @aColsEsp, nUsadEsp)

oGetF4Q1:= MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE,,,,,,,,,, oGrpF4Q1, aHeadEsp, aColsEsp)
oGetF4Q1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

// folder: ESTOQUE ##########################################################################################

If nOpc == 3
// 	o1ZBCGDad:Disable()
	oGrpF1Q2:Disable()
EndIf

Aadd( aButtons, { "AUTOM", { || u_BaseConh()  }, "Base de Conhecimento" } )
AAdd( aButtons, { "AUTOM", { ||  fMenuAux(1)  }, "Antecipacao"  		   } )
AAdd( aButtons, { "AUTOM", { ||  fMenuAux(2)  }, "Gerar Titulo" 	   } )
AAdd( aButtons, { "AUTOM", { ||  U_COMM11JR( &( "o" + cValToChar( oTFoldeG:nOption ) + "ZBCGDad"):oBrowse:nAt) }, "Informar Juros (F6)" } )
AAdd( aButtons, { "AUTOM", { ||  U_COMM11PE( &( "o" + cValToChar( oTFoldeG:nOption ) + "ZBCGDad"):oBrowse:nAt) }, "Informar Peso (F7)" } )
AAdd( aButtons, { "AUTOM", { ||  M7SlvCrt( )  }, "Salvar Contrato (F8)" } )
// AAdd( aButtons, { "AUTOM", { ||  M7GerarPrd() }, "Gerar Produto"    } )
AAdd( aButtons, { "AUTOM", { ||  xAutoSC7()   }, "Gerar Pedido (F10)"   } )
// AAdd( aButtons, { "AUTOM", { || fGerarCompl() }, "Gerar ComplementoPedido (F11)"  } )
AAdd( aButtons, { "AUTOM", { || ReajusteResiduo() }, "Reajuste de Residuo"  } )
AAdd( aButtons, { "AUTOM", { || Pergunte("COMM11VA", .T.) }, "Configura��o (F12)"  } )

Set Key VK_F5  To F5FldChang(nOpc)
Set Key VK_F6  To U_COMM11JR()
Set Key VK_F7  To U_COMM11PE()
Set Key VK_F8  To M7SlvCrt()
Set Key VK_F10 To xAutoSC7()
// Set Key VK_F11 To fGerarCompl()
Set Key VK_F12 To ConfigPergunte()

ACTIVATE MSDIALOG oDlg ;
          ON INIT EnchoiceBar(oDlg,;
						{ || nOpcA := 1, Iif( /* VldOk(nOpc) .and. */ Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0)},;
						{ || nOpcA := 0, oDlg:End() },, aButtons )

If nOpc == 3 .or. nOpc == 4 .or. nOpc == 6 .or. nOpc == 7 .or. nOpc == 8
 	If nOpcA == 1
		Begin Transaction

			DbSelectArea(cAlias)
			DbSetOrder(1) // Z2_FILIAL+Z2_ASSUNTO+Z2_OCORREN+Z2_SOLUCAO+Z2_RESULTA
			RecLock( cAlias, !DbSeek( xFilial('ZCC') + M->ZCC_CODIGO + M->ZCC_VERSAO ))
				U_GrvCpo(cAlias)
				ZCC->ZCC_TPCONT := "M"
			(cAlias)->(MsUnlock())

			DbSelectArea( "ZBC" )
			ZBC->( DbSetOrder( 1 ) )
			/// Tabela 2 - Rodap�
			For nI := 1 to Len(o1ZBCGDad:aCols)
				If !o1ZBCGDad:aCols[ nI, Len(o1ZBCGDad:aCols[nI]) ] ; // .AND. !Empty( oGZBCGDad:aCols[ nI, 3] )
						.AND. !Empty( o1ZBCGDad:aCols[ nI, nPZBCITE ] ) // ;
						// .AND. !Empty( oGZBCGDad:aCols[ nI, nPZBCZIC ] )
					// ZBC_FILIAL+ZBC_CODIGO+ZBC_VERSAO+ZBC_ITEM+ZBC_ITEZIC+ZBC_PEDIDO+ZBC_ITEMPC+ZBC_VERPED

					ZBC->( DbSetOrder( 1 ) )
					RecLock( "ZBC", lRecLock := !DbSeek( xFilial("ZBC") + M->ZCC_CODIGO + M->ZCC_VERSAO + &( "o" + cPFoBCITE + "ZBCGDad"):aCols[ nI, nPZBCITE ] /* + oGZBCGDad:aCols[nI, nPZBCZIC] + oGZBCGDad:aCols[nI, nPZBCPed] + oGZBCGDad:aCols[nI, nPZBCPIt] + oGZBCGDad:aCols[nI, nPZBCPVs] */ ) )

						For nF := 1 to len(aFolderG)
							U_GrvCpo( "ZBC", ;
									  &( "o" + cValToChar(nF) + "ZBCGDad" ):aCols, ;
									  &( "o" + cValToChar(nF) + "ZBCGDad" ):aHeader, nI )
						Next nF

						If lRecLock
							ZBC->ZBC_FILIAL := xFilial("ZBC")
							ZBC->ZBC_CODIGO := M->ZCC_CODIGO
							ZBC->ZBC_VERSAO := M->ZCC_VERSAO
							ZBC->ZBC_CODFOR := M->ZCC_CODFOR
							ZBC->ZBC_LOJFOR := M->ZCC_LOJFOR
							ZBC->ZBC_USUARI := cUserName
							ZBC->ZBC_DTALT  := MsDate()
						EndIf
					ZBC->( MsUnlock() )
					// lAtuX8 := .T.

				Else // Se o registro foi excluido e existe no banco apaga
					DbSelectArea( "ZBC" )
					ZBC->( DbSetOrder( 1 ) )
					If ZBC->( DbSeek( xFilial("ZBC") + M->ZCC_CODIGO + M->ZCC_VERSAO + oGZBCGDad:aCols[nI, nPZBCITE] ) )
						RecLock( "ZBC", .F.)
							ZBC->( dbDelete() )
						ZBC->( MsUnLock() )
					EndIf
				EndIf
			Next i

			// If lAtuX8
				While __lSX8
					ConfirmSX8()
				EndDo
			/* Else
				While __lSX8
					RollBackSX8()
				EndDo
			EndIf
			*/
			If nOpc == 6 // Compia
				// Fechar STATUS de contratros em versao anterior
				FechaContrato(ZCC->ZCC_CODIGO, ZCC->ZCC_VERSAO, nOpc )
			EndIf

		End Transaction

	Else
		While __lSX8
			RollBackSX8()
		EndDo
	EndIf

ElseIf nOpc == 5

	DbSelectArea(cAlias)
	DbSetOrder(1) // Z2_FILIAL+Z2_ASSUNTO+Z2_OCORREN+Z2_SOLUCAO+Z2_RESULTA
	If DbSeek( xFilial('ZCC') + M->ZCC_CODIGO + M->ZCC_VERSAO )
		RecLock( cAlias, .F.)
			ZCC->( DbDelete() )
		(cAlias)->(MsUnlock())
	EndIf

	For nI := 1 to Len(o1ZBCGDad:aCols)
		DbSelectArea( "ZBC" )
		ZBC->( DbSetOrder( 1 ) )
		// If DbSeek( xFilial("ZBC") + M->ZCC_CODIGO + M->ZCC_VERSAO + oGZBCGDad:aCols[nI, nPZBCITE] + oGZBCGDad:aCols[nI, nPZBCZIC] + oGZBCGDad:aCols[nI, nPZBCPed] + oGZBCGDad:aCols[nI, nPZBCPIt] + oGZBCGDad:aCols[nI, nPZBCPVs] )
		If DbSeek( xFilial("ZBC") + M->ZCC_CODIGO + M->ZCC_VERSAO + o1ZBCGDad:aCols[nI, nPZBCITE] + "XX" /* oGZBCGDad:aCols[nI, nPZBCZIC] */ + o1ZBCGDad:aCols[nI, nPZBCPed] + o1ZBCGDad:aCols[nI, nPZBCPIt] /* + o1ZBCGDad:aCols[nI, nPZBCPVs] */ )
			RecLock( "ZBC", .F.)
				ZBC->( DbDelete() )
			MsUnlock()
		EndIf
	Next i

EndIf

_M11Codigo := ""

if Select("QTMP") > 0
	QTMP->( dbCloseArea() )
EndIf

Return nil


/* MJ : 25.01.2019
	-> chamar atualizacao das grids, pelo atalho F5;
*/
Static Function F5FldChang(nOpc)
	// Alert('atalho')
	FWMsgRun(, {|| FldChang(nOpc, .F.) }, 'Realizando consulta ao banco de dados','Atualizando tabelas, Por Favor Aguarde...')
Return nil

/* MJ : 18.01.2019
	-> Ao Trocar a ABA, carregar Grids.
*/
Static Function FldChang(nOpc, lVld)

Default lVld := .T.
Default nOpc := 3

	// Alert( 'nOpc: ' + cValToChar(nOpc) + ', tamanho: ' + cValToChar(Len( oGetF2Q2:aCols)) )

	// If nOpc <> 3
	If Len( oGetF2Q2:aCols ) > 0

		If lVld
			lVld := Empty( oGetF2Q2:aCols[ 1, 1] )
		Else
			nFldPant := 0
			lVld 	 := .T.
			If oTFoldeP:nOption == 2
				oGetF2Q2:aCols[ 1, 1] := ""
			ElseIf oTFoldeP:nOption == 3
				If Len(oGetF3aQ2:aCols)>0
					oGetF3aQ2:aCols[ 1, 1] := ""
				EndIf
				If Len(oGetF3bQ2:aCols)>0
					oGetF3bQ2:aCols[ 1, 1] := ""
				EndIf
				If Len(oGetF3Q3:aCols)>0
					oGetF3Q3:aCols[ 1, 1] := ""
				EndIf
			ElseIf oTFoldeP:nOption == 4
				if Len(oGetF4Q4E:aCols)>0
					oGetF4Q4E:aCols[ 1, 1] := ""
				EndIf
				if Len(oGetF4Q5D:aCols)>0
					oGetF4Q5D:aCols[ 1, 1] := ""
				EndIf
				If Len(oGetF4Q2E:aCols)>0
					oGetF4Q2E:aCols[ 1, 1] := ""
				EndIf
				If Len(oGetF4Q3D:aCols)>0
					oGetF4Q3D:aCols[ 1, 1] := ""
				EndIf
				If Len(oGetF4Q1:aCols)>0
					oGetF4Q1:aCols [ 1, 1] := ""
				EndIf
			EndIf
		EndIf

		If nFldPant <> oTFoldeP:nOption
			If oTFoldeP:nOption == 2 .and. lVld
				LoadGrids('fld2') 	// LoadF2Q2('F2Q2')
				// Alert('carregou abas 2')

			ElseIf oTFoldeP:nOption == 3
				LoadGrids('fld3')

			ElseIf oTFoldeP:nOption == 4
				LoadGrids('fld4')

			EndIf
		EndIf

	EndIf

	nFldPant := oTFoldeP:nOption
	// Alert('nFolder: ' + cValToChar(oTFoldeP:nOption))
Return .T.

/* MJ : 18.01.2019
	-> Ordena Notas de Entrada - Aba 2;*/
Static Function LoadGrids(cTipo) // LoadF2Q2()
Local nI        := 0

	If cTipo == 'fld2'
		If Len(oGetF2Q2:aCols)>0 .and. Empty( oGetF2Q2:aCols[ 1, 1] )

			LoadNewGDados( "NFEntrada", oGetF2Q2:aHeader, @oGetF2Q2:aCols, Len(oGetF2Q2:aHeader) )
			oGetF2Q2:Refresh()
			/*
			aColsEsp := {}
			_nMedXKM := 0
			while !QTMP->(Eof())
				aAdd(aColsEsp, array(nUsadEsp+1))
				for nX := 1 to nUsadEsp
					if aHeadEsp[nX,8]=='D'
						aColsEsp[Len(aColsEsp),nX]:=STOD( QTMP->( FieldGet(FieldPos(aHeadEsp[nX,2])) ) )
					else
						aColsEsp[Len(aColsEsp),nX]:=QTMP->( FieldGet(FieldPos(aHeadEsp[nX,2])) )
					EndIf
				next
				do case
					case AllTrim( QTMP->( FieldGet(FieldPos( aHeadEsp[ 1, 2] )) ) ) == "1-NF ENTRADA"
						_nQtdNF += 1
						_nTotNF += QTMP->( FieldGet(FieldPos( "D1_TOTAL" )) )

						_nMedXKM += QTMP->( FieldGet(FieldPos( "D1_X_KM" )) )

					case AllTrim( QTMP->( FieldGet(FieldPos( aHeadEsp[ 1, 2] )) ) ) == "2-NF COMPLEMENTO"
						_nQtdCpl += 1
						_nTotCpl += QTMP->( FieldGet(FieldPos( "D1_TOTAL" )) )
					case AllTrim( QTMP->( FieldGet(FieldPos( aHeadEsp[ 1, 2] )) ) ) == "3-NF FRETE"
						_nQtdFre += 1
						_nTotFre += QTMP->( FieldGet(FieldPos( "D1_TOTAL" )) )
				endCase
				_nVlrTotNF += QTMP->( FieldGet(FieldPos( "D1_TOTAL" )) )
				aColsEsp[len(aColsEsp), nUsadEsp+1] := .F.

				QTMP->(dbSkip())
			EndDo */
			For nI := 1 to Len( oGetF2Q2:aCols )

				do case
					case AllTrim(oGetF2Q2:aCols[ nI, 01]) == "1-NF ENTRADA"
						_nQtdNF += 1
						_nTotNF += oGetF2Q2:aCols[ nI, aScan( oGetF2Q2:aHeader, { |x| x[2] == "D1_TOTAL"} )]  // QTMP->( FieldGet(FieldPos( "D1_TOTAL" )) )

						if ValType(oGetF2Q2:aCols[ nI, aScan( oGetF2Q2:aHeader, { |x| x[2] == "D1_X_KM"} )])=="C"
							_nMedXKM += Val(oGetF2Q2:aCols[ nI, aScan( oGetF2Q2:aHeader, { |x| x[2] == "D1_X_KM"} )]) // QTMP->( FieldGet(FieldPos( "D1_X_KM" )) )
						Else
							_nMedXKM += oGetF2Q2:aCols[ nI, aScan( oGetF2Q2:aHeader, { |x| x[2] == "D1_X_KM"} )] // QTMP->( FieldGet(FieldPos( "D1_X_KM" )) )
						EndIf
					case AllTrim(oGetF2Q2:aCols[ nI, 1]) == "2-NF COMPLEMENTO"
						_nQtdCpl += 1
						_nTotCpl += oGetF2Q2:aCols[ nI, aScan( oGetF2Q2:aHeader, { |x| x[2] == "D1_TOTAL"} )]  // QTMP->( FieldGet(FieldPos( "D1_TOTAL" )) )

					case AllTrim(oGetF2Q2:aCols[ nI, 1]) == "3-NF FRETE"
						_nQtdFre += 1
						_nTotFre += oGetF2Q2:aCols[ nI, aScan( oGetF2Q2:aHeader, { |x| x[2] == "D1_TOTAL"} )]  // QTMP->( FieldGet(FieldPos( "D1_TOTAL" )) )
				endCase

				_nQtdReb   += oGetF2Q2:aCols[ nI, 08] // D1_QUANT
			Next nI
			_nQtdTotNF := Len(oGetF2Q2:aCols)
			_nMedXKM   := _nMedXKM / _nQtdNF
			_nCstXKM   := _nTotFre / _nMedXKM / _nQtdFre
			oEnchF2Q3:EnchRefreshAll()
		EndIf

	ElseIf cTipo == 'fld3'

		If Len(oGetF3aQ2:aCols)>0 .and. Empty( oGetF3aQ2:aCols[ 1, 1] )
			LoadNewGDados("oGetF3aQ2", oGetF3aQ2:aHeader, @oGetF3aQ2:aCols, Len(oGetF3aQ2:aHeader) )
			oGetF3aQ2:Refresh()
		EndIf

		If Len(oGetF3bQ2:aCols)>0 .and. Empty( oGetF3bQ2:aCols[ 1, 1] )
			LoadNewGDados("oGetF3bQ2", oGetF3bQ2:aHeader, @oGetF3bQ2:aCols, Len(oGetF3bQ2:aHeader) )
			oGetF3bQ2:Refresh()
		EndIf

		If Len(oGetF3Q3:aCols)>0 .and. Empty( oGetF3Q3:aCols[ 1, 1] )
			LoadNewGDados("oGetF3Q3", oGetF3Q3:aHeader, @oGetF3Q3:aCols, Len(oGetF3Q3:aHeader) )
			oGetF3Q3:Refresh()
		EndIf

	ElseIf cTipo == 'fld4'

		If Len(oGetF4Q4E:aCols)>0 .and. Empty( oGetF4Q4E:aCols[ 1, 1] )
			LoadNewGDados("oGetF4Q4E", oGetF4Q4E:aHeader, @oGetF4Q4E:aCols, Len(oGetF4Q4E:aHeader) )
			oGetF4Q4E:Refresh()
		EndIf

		If Len(oGetF4Q5D:aCols)>0 .and. Empty( oGetF4Q5D:aCols[ 1, 1] )
			LoadNewGDados("oGetF4Q5D", oGetF4Q5D:aHeader, @oGetF4Q5D:aCols, Len(oGetF4Q5D:aHeader) )
			oGetF4Q5D:Refresh()
		EndIf

		If Len(oGetF4Q2E:aCols)>0 .and. Empty( oGetF4Q2E:aCols[ 1, 1] )
			LoadNewGDados("oGetF4Q2E", oGetF4Q2E:aHeader, @oGetF4Q2E:aCols, Len(oGetF4Q2E:aHeader) )
			oGetF4Q2E:Refresh()
		EndIf

		If Len(oGetF4Q3D:aCols)>0 .and. Empty( oGetF4Q3D:aCols[ 1, 1] )
			LoadNewGDados("oGetF4Q3D", oGetF4Q3D:aHeader, @oGetF4Q3D:aCols, Len(oGetF4Q3D:aHeader) )
			oGetF4Q3D:Refresh()
		EndIf

		If Len(oGetF4Q1:aCols)>0 .and. Empty( oGetF4Q1:aCols[ 1, 1] )
			LoadNewGDados("oGetF4Q1", oGetF4Q1:aHeader, @oGetF4Q1:aCols, Len(oGetF4Q1:aHeader) )
			oGetF4Q1:Refresh()
		EndIf

	EndIf
	// Iif(_cOrden=="T", aSort( oGetF2Q2:aCols ,,, {|x,y| x[1] < y[1] } ), aSort( oGetF2Q2:aCols ,,, {|x,y| x[4] < y[4] } ))
	// aSort( oGetF2Q2:aCols ,,, {|x,y| x[1] < y[1] } )
	// oGetF2Q2:Refresh()
	// Alert('Load Aba 2')
Return


Static Function OrdenaF2Q2( nCol )
// Local aCoBrw1    := {}
// Local xVar 		 := ClassMethArr( oGetF2Q2, .T. ) // M�gica
// Local xVar2 	 := ClassDataArr( oGetF2Q2, .T. ) // Magica

// Alert('nF2Q2Cont: ' + cValToChar(+nF2Q2Cont))

If Len( oGetF2Q2:aCols ) > 1
	// .and. nF2Q2Cont%2==0
	// .and. !lF2Q2Ord

	// Alert('nF2Q2Ant: ' + cValToChar(nF2Q2Ant) + ' - nCol: ' + cValToChar(nCol) )
    //
	// If nF2Q2Ant == nCol // .and. ( oGetF2Q2:aCols[1,nCol] < oGetF2Q2:aCols[ Len(oGetF2Q2:aCols),nCol] )
	// 	lF2Q2Cresc := !lF2Q2Cresc
	// Else
	// 	lF2Q2Cresc := .T.
	// EndIf

	// If lF2Q2Cresc
		// aCoBrw1 :=
		aSort( oGetF2Q2:aCols,,,{|x,y| x[nCol] < y[nCol]})
		// Alert('Crescente')
	// Else
	// 	// aCoBrw1 :=
	// 	aSort( oGetF2Q2:aCols,,,{|x,y| x[nCol] > y[nCol]})
	// 	Alert('De-Crescente')
	// EndIf

	// oGetF2Q2:setArray(aCoBrw1)
	// oGetF2Q2:aCols := aCoBrw1
	// nF2Q2Ant := nCol
	// lF2Q2Ord := .T.
	// oGetF2Q2:oBrowse:Refresh()
	oGetF2Q2:Refresh()
EndIf

Return Nil

/* MJ : 22.01.2019 */
Static Function OrdenaF3aQ2( nCol )
	If Len( oGetF3aQ2:aCols ) > 1
		aSort( oGetF3aQ2:aCols,,,{|x,y| x[nCol] < y[nCol]})
		oGetF3aQ2:Refresh()
	EndIf
Return Nil

/* MJ : 22.01.2019 */
Static Function OrdenaF3bQ2( nCol )
	If Len( oGetF3bQ2:aCols ) > 1
		aSort( oGetF3bQ2:aCols,,,{|x,y| x[nCol] < y[nCol]})
		oGetF3bQ2:Refresh()
	EndIf
Return Nil

/* MJ : 22.01.2019 */
Static Function OrdenaF3Q3( nCol )
	If Len( oGetF3Q3:aCols ) > 1
		aSort( oGetF3Q3:aCols,,,{|x,y| x[nCol] < y[nCol]})
		oGetF3Q3:Refresh()
	EndIf
Return Nil



/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     27.12.2018                                                             |
 | Cliente:  V@                                                                     |
 | Desc:                                                                            |
 |                                                                                  |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
// Static Function ZBCLinOK()
// Local lRet := .T.
// Alert("Linha OK")
// Return lRet

/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     19.12.2018                                                             |
 | Cliente:  V@                                                                     |
 | Desc:     Fun��o utilizada para atualizar os campos comuns em todas as abas;     |
 |                                                                                  |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
Static Function RepeatFolder( cCampo, _cInfo, nFolder, nAt  )
Local nI		:= 0
// Local nPosOrig  := 0
Local nPosDest  := 0

For nI := 1 to Len(aFolderG)
	if nI <> nFolder
		// nPosOrig := aScan( &( "o" + cValToChar( nFolder ) + "ZBCGDad"):aHeader, { |x| AllTrim(x[2]) == AllTrim(SX3->X3_CAMPO) } )
		nPosDest := aScan( &( "o" + cValToChar( nI ) + "ZBCGDad"):aHeader, { |x| AllTrim(x[2]) == AllTrim( cCampo ) } )
		If nPosDest > 0
			If Len( &( "o" + cValToChar( nFolder ) + "ZBCGDad"):aCols ) > Len( &( "o" + cValToChar( nI ) + "ZBCGDad"):aCols )
				&( "o" + cValToChar( nI ) + "ZBCGDad"):AddLine(.T., .T.)
				&( "o" + cValToChar( nI ) + "ZBCGDad"):ForceRefresh()
			EndIf
			&( "o" + cValToChar( nI ) + "ZBCGDad"):aCols[ nAt, nPosDest ] := _cInfo // &( "o" + cValToChar( nFolder ) + "ZBCGDad"):aCols[ nAt, nPosOrig]
			&( "o" + cValToChar( nI ) + "ZBCGDad"):Refresh()
		EndIf
	EndIf
Next nI

Return nil


/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     18.12.2018                                                             |
 | Cliente:  V@                                                                     |
 | Desc:     Fun��o utilizada para atualizar os campos comuns em todas as abas;     |
 |                                                                                  |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
Static Function ReLoadFolder( nFolder )
// Alert( "Folder: " + cValToChar(nFolder) )

/* por hora nao estou mais usando a funcao ao dar reload na aba,
mas na alteracao individual de cada campo */
Local nPosCpo := 0
Local nI	  := 1, nL:=0

If nFolder > 0
	dbSelectArea("SX3")
	SX3->( dbSetOrder( 4 ) )

	// While nI <= Len( &( "o" + cValToChar(nFolder) + "ZBCGDad"):aHeader )
	While nI <= Len( &( "o" + cValToChar(nFolder) + "ZBCGDad"):aHeader )

		If SX3->(DbSeek( "ZBC" + cValToChar( nFolder ) + &( "o" + cValToChar(nFolder) + "ZBCGDad"):aHeader[ 1, 2 ] ))

			If X3Uso(SX3->X3_USADO) .and. Empty(X3_FOLDER) // VAZIO ent�o TODAS as grid

				// nPosCpo := aScan( &( "o" + cValToChar(nFolder) + "ZBCGDad"):aHeader, { |x| AllTrim(x[2]) == SX3->X3_CAMPO } )
				nPosCpo := aScan( &( "o" + cValToChar( 1 ) + "ZBCGDad"):aHeader, { |x| AllTrim(x[2]) == SX3->X3_CAMPO } )

				// linha do aCols
				For nL := 1 to Len(&( "o" + cValToChar( 1 ) + "ZBCGDad"):aCols)
					&( "o" + cValToChar(nFolder) + "ZBCGDad"):aCols[ nL, nI ] := ;
						&( "o" + cValToChar( 1 ) + "ZBCGDad"):aCols[ nL, nPosCpo]
				Next nL

				/*
				// Abas
				For nF := 1 to Len(aFolderG)

					// linha do aCols
					For nL := 1 to Len()

						nPosCpo := aScan( &( "o" + cValToChar(nF) + "ZBCGDad"):aHeader, { |x| AllTrim(x[2]) == SX3->X3_CAMPO } )

						&( "o" + cValToChar(nF) + "ZBCGDad"):aCols[ nL, nPosCpo ]

					Next nL

				Next nF
				*/

			EndIf
		EndIf

		nI++
	EndDo

	nFldOldG := nFolder
EndIf
Return nil


Static Function GETDCLR(oObj) // aLinha,nLinha,aHeader)
Local nCor		:= CLR_BRANCO 
// Local aHeadAux	:= oObj:aHeader
Local aColsAux  := oObj:aCols
Local nAt		:= oObj:nAt

do case
	// case AllTrim( QTMP->( FieldGet(FieldPos( aHeadEsp[ 1, 2] )) ) ) == "1-NF ENTRADA"
		// _nTotNF += QTMP->( FieldGet(FieldPos( "D1_TOTAL" )) )
	case AllTrim( aColsAux[ nAt, 1] ) == "2-NF COMPLEMENTO"
		nCor := CLR_AZUL
	case AllTrim( aColsAux[ nAt, 1] ) == "3-NF FRETE"
		nCor := CLR_VERDE
endCase

Return nCor



/*---------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                        |
 | Data:     30.10.2017                                                            |
 | Cliente:  V@                                                                    |
 | Desc:     Validar Ultima REVISAO para o CONTRATO                                |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras:                                                                         |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.:     -                                                                     |
 '---------------------------------------------------------------------------------*/
// Static Function ZBCbChange()
// 	Local nAt 		:= o1ZBCGDad:oBrowse:nAt
// 
// 	If Empty( o1ZBCGDad:aCols[ nAt, 1] )
// 		o1ZBCGDad:aCols[ nAt, 1] := "LBNO"
// 		o1ZBCGDad:Refresh()
// 	EndIf
// 
// 	_M12Codigo := o1ZBCGDad:aCols[ nAt, nPZBCFaxa ]
// 
// 	// Alert('ZBCbChange: ' + AllTrim(Str( nAt )))
// Return .T.


/* MJ : 11.03.2019*/
Static Function ConfigPergunte()
	Pergunte("COMM12VA", .T.)
Return .T.


/* MJ : 11.03.2019
	-> funcao auxiliar para ajudar no processo de validacao dos campos;
*/	
Static Function AUX_miZBCFieldOK(nOpc, cCampo, _cInfo, nAt, /* lVld, */ nFolder )
Local lRet      := .T.
Local nI := 0
Default nFolder := 1

	if nOpc == 1 // preenchimento de campos automaticamente
		If nAt <= 0 .or. nAt > Len( &( "o" + cValToChar(nFolder) + "ZBCGDad"):aCols)
			// Erro de posicionamento da Grid. Fechar Validacao para nao dar erro.
			Return .F.
		EndIf

		If Empty( &( "o" + cValToChar(nFolder) + "ZBCGDad"):aCols[nAt, 1] )
			&( "o" + cValToChar(nFolder) + "ZBCGDad"):aCols[nAt, 1] := "LBNO"
		EndIf

		If Empty( &( "o" + cValToChar(nFolder) + "ZBCGDad"):aCols[ nAt, nPZBCITE ] ) // ZBC_ITEM
			&( "o" + cValToChar(nFolder) + "ZBCGDad"):aCols[ nAt, nPZBCITE ] := StrZero( nAt, TamSX3('ZBC_ITEM')[1] )
			RepeatFolder( 'ZBC_ITEM', StrZero( nAt, TamSX3('ZBC_ITEM')[1] ), nFolder, nAt )
		EndIf

		If !Empty( cCampo ) .and. Empty( Posicione('SX3', 2, cCampo, 'X3_FOLDER') )
			RepeatFolder( cCampo, _cInfo, nFolder, nAt )
		EndIf

	ElseIf nOpc == 2
		nTotQtde 	:= 0
		nQtdTotal	:= 0

		For nI := 1 to len(o1ZBCGDad:aCols) //nAt
			If !o1ZBCGDad:aCols[ nI, Len( o1ZBCGDad:aCols[ 1 ] ) ]
				nQtdTotal += Iif(nI==nAt .and. !IsInCallStack( "REAJUSTERESIDUO")/* .and. lVld */,;
								&(ReadVar()),;
								&( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nI, nPZBCQtd ] )
			EndIf
		Next nI

		if nQtdTotal > M->ZCC_QTTTAN
			Alert('Quantidade de animais ultrapassou o configurado no Cabe�alho do Contrato.')
			Return .F.
		EndIf

		M->ZCC_QTDRES := M->ZCC_QTTTAN - nQtdTotal
		oMGet:Refresh()
	EndIf

Return lRet

/* ####################################################################### */
/* MJ : 06.11.2017

	Alt. 13.11.18
		Param : lVLd : Define se ir realizar a validacao ou nao;
   ####################################################################### */
User Function miZBCFieldOK(cCampo, _cInfo, nAt, /* lVld, */ nFolder )

Local lRet          := .T.
// Local nI         := 0
Local nTotQtde      := 0
Local cItemZIC      := ""
Local lTodos        := .F.
Local nPZIC         := 0
Local nAux          := 0
Local lMark         := .T.
Local nF            := 0

Local _ZBC_QUANT    := 0
Local _ZBC_PRECO    := 0
Local _ZBC_TOTAL    := 0
// Local _ZBC_TPNEG := 0
Local _ZBC_REND     := 0
Local _ZBC_TOTICM   := 0
Local _ZBC_ALIICM   := 0
Local _ZBC_VLAROB   := 0
Local _ZBC_VLUSIC   := 0
Local _ZBC_TES      := 0
Local _ZBC_PRENEG   := 0
Local _ZBC_TOTNEG   := 0

Local _ZBC_TPmNEG   := " "
Local _ZBC_DTIIND   := sToD("")
Local _ZBC_DTFIND   := sToD("")
Local _ZBC_INDFIN   := Space(TamSX3("ZBC_INDFIN")[1])

Default cCampo      := Substr( ReadVar(), At('->', ReadVar())+2 )
Default _cInfo      := &( ReadVar() )
// Default lVld     := .T.
Default nFolder     := oTFoldeG:nOption
Default nAt         := &("o" + cValToChar(nFolder) + "ZBCGDad"):oBrowse:nAt // o1ZBCGDad:oBrowse:nAt

	If MV_PAR01 == 1 // NAO
		// Alert('N�o')
		Return .T.
	EndIf
	// mi = milho
	if !AUX_miZBCFieldOK(1, cCampo, _cInfo, nAt, /* lVld, */ nFolder )
		// Alert('Gatilhos cancelados. Erro durante execu��o da funcao: [AUX_miZBCFieldOK-1 ]')
		Return .F.
	EndIf

	ConOut(ProcName() + ": Data: " + dToC(dDataBase) + "-" + Time())
	/* ------------------------------------ _P_A_R_A_M_E_T_R_O_S_ ------------------------------------ */
	// 1 = PRINCIPAL
	// ## nPZBCQtd > "ZBC_QUANT" < cPFoBCQtd  ## Qtde Pedido
	_ZBC_QUANT  := Iif(ReadVar()=='M->ZBC_QUANT', &(ReadVar()), &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nAt, nPZBCQtd ] )
	// ## nPZBCPrc > ZBC_PRECO < cPFoBCPrc ## R$ Unit Ped 		// _ZBC_PRECO  := &( "o" + cPFoBCPrc + "ZBCGDad"):aCols[ nAt, nPZBCPrc ]
	_ZBC_PRECO  := Round( Iif(ReadVar()=='M->ZBC_PRECO', &(ReadVar()), &( "o" + cPFoBCPrc + "ZBCGDad"):aCols[ nAt, nPZBCPrc ] ), 4) // toshio pediu pra colocar round 4
	// ## nPZBCTot > ZBC_TOTAL < cPFoBCTot ## R$ Total Ped
	_ZBC_TOTAL  := Iif(ReadVar()=='M->ZBC_TOTAL', &(ReadVar()), &( "o" + cPFoBCTot + "ZBCGDad"):aCols[ nAt, nPZBCTot ] )
	_ZBC_TPmNEG  := Iif(ReadVar()=='M->ZBC_TPNEGM', &(ReadVar()), &( "o" + cPFoTPNEGM + "ZBCGDad"):aCols[ nAt, nPTPNEGM ] )
	_ZBC_DTIIND  := Iif(ReadVar()=='M->ZBC_DTIIND', &(ReadVar()), &( "o" + cPFoDTIIND + "ZBCGDad"):aCols[ nAt, nPDTIIND ] )
	_ZBC_DTFIND  := Iif(ReadVar()=='M->ZBC_DTFIND', &(ReadVar()), &( "o" + cPFoDTFIND + "ZBCGDad"):aCols[ nAt, nPDTFIND ] )
	_ZBC_INDFIN  := Iif(ReadVar()=='M->ZBC_INDFIN', &(ReadVar()), &( "o" + nPFoINDFIN + "ZBCGDad"):aCols[ nAt, nPINDFIN ] )
	_ZBC_VLRMED  := Iif(ReadVar()=='M->ZBC_VLRMED', &(ReadVar()), &( "o" + cPFoVLRMED + "ZBCGDad"):aCols[ nAt, nPVLRMED ] )
	
	_ZBC_OUTACR  := Iif(ReadVar()=='M->ZBC_OUTACR', &(ReadVar()), &( "o" + nPFoOUTACR + "ZBCGDad"):aCols[ nAt, nPOUTACR ] )
	_ZBC_OUTDES  := Iif(ReadVar()=='M->ZBC_OUTDES', &(ReadVar()), &( "o" + nPFoOUTDES + "ZBCGDad"):aCols[ nAt, nPOUTDES ] )

	/* ------------------------------------ _P_A_R_A_M_E_T_R_O_S_ ------------------------------------ */
	// If nFolder == 1 // entao valores pedido/pauta
	// 	If Empty( _ZBC_PEDPOR )
	// 		Aviso("Aviso", ;
	// 			  "O campo [Pedido Por], localizado na ABA 1, n�o foi informado." + CRLF +;
	// 			  "Esta Opera��o sera cancelada.", ;
	// 			  {"Sair"} )
	// 		Return .F.
	// 	EndIf
	// Else // demais abas
	// 	If Empty( _ZBC_TPNEG )
	// 		Aviso("Aviso", ;
	// 			  "O campo [Tipo Negocia��o], localizado na ABA 2, n�o foi informado." + CRLF +;
	// 			  "Esta Opera��o sera cancelada.", ;
	// 			  {"Sair"} )
	// 		Return .F.
	// 	EndIf
	// EndIf

	// ## ZBC_SB1ZIC  ##
	If cCampo == 'ZBC_SB1ZIC'
		RepeatFolder( "ZBC_PRDDES", Posicione( "SB1", 1, xFilial("SB1")+_cInfo, "B1_DESC"), nFolder, nAt )

		&( "o" + cPFoBCDES + "ZBCGDad"):aCols[ nAt, nPZBCDES ] := SB1->B1_DESC

	// ## nPZBCQtd > "ZBC_QUANT" < cPFoBCQtd  ## Qtde Pedido
	ElseIf cCampo == 'ZBC_QUANT'

		if !AUX_miZBCFieldOK(2, cCampo, _cInfo, nAt, /* lVld, */ nFolder )
			// Alert('Gatilhos cancelados. Erro durante execu��o da funcao: [AUX_miZBCFieldOK-2]')
			Return .F.
		EndIf

		// ## nPZBCQtd > "ZBC_QUANT" < cPFoBCQtd  ## Qtde Pedido
		&( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nAt, nPZBCQtd ] := _ZBC_QUANT := _cInfo

		U_miZBCFieldOK('ZBC_PRECO', _ZBC_PRECO, nAt )
	
	// ## nPZBCPrc > ZBC_PRECO < cPFoBCPrc ## R$ Unit Ped
	ElseIf cCampo == 'ZBC_PRECO'

		// ## nPZBCQtd > "ZBC_QUANT" < cPFoBCQtd  ## Qtde Pedido
		// If !Empty( _ZBC_QUANT )

			// ## nPZBCTot > ZBC_TOTAL < cPFoBCTot ## R$ Total Ped
			&( "o" + cPFoBCTot + "ZBCGDad"):aCols[ nAt, nPZBCTot ] := _ZBC_QUANT * _ZBC_PRECO

		// EndIf
		 
	ElseIf cCampo == 'ZBC_TPNEGM' // Tipo Negociacao

		If _ZBC_TPmNEG == "1"
			&( "o" + cPFoDTIIND + "ZBCGDad"):aCols[ nAt, nPDTIIND ] := _ZBC_DTIIND := U_ChegaNaData(dDataBase-7, '-', 2) // cToD('01\08\2020')
			&( "o" + cPFoDTFIND + "ZBCGDad"):aCols[ nAt, nPDTFIND ] := _ZBC_DTFIND := U_ChegaNaData(dDataBase-7, '+', 6) // cToD('30\08\2020')
			// If Empty(_ZBC_DTIIND) .or. Empty(_ZBC_DTFIND)
			// 	MsgInfo("Os campos: <b>Dt Ini Indices e Dt Fim Indices</b>, precisam estar preenchidos para o calculo da m�dia ESALQ.")
			// EndIf
		ElseIf _ZBC_TPmNEG == "2"
			&( "o" + cPFoDTIIND + "ZBCGDad"):aCols[ nAt, nPDTIIND ] := _ZBC_DTIIND := dDataBase-1
			&( "o" + cPFoDTFIND + "ZBCGDad"):aCols[ nAt, nPDTFIND ] := _ZBC_DTFIND := dDataBase-1
		EndIf

		U_miZBCFieldOK('ZBC_INDFIN', _ZBC_INDFIN, nAt )

	ElseIf cCampo == 'ZBC_DTIIND' .OR. cCampo == 'ZBC_DTFIND'
		
		U_miZBCFieldOK('ZBC_INDFIN', _ZBC_INDFIN, nAt )

	ElseIf cCampo == 'ZBC_INDFIN' 

		If _ZBC_TPmNEG $ ("12")  .AND.;
			 !Empty(_ZBC_INDFIN) .AND.;
			 !Empty(_ZBC_DTIIND) .AND. !Empty(_ZBC_DTFIND)
			beginSQL alias "QTMP"
				%noParser%
				SELECT  ROUND(AVG(ZSI_VALOR),2) MEDIA
				FROM    ZSI010
				WHERE	ZSI_FILIAL=%xFilial:ZSI%
					AND ZSI_CODIGO=%exp:_ZBC_INDFIN%
					AND ZSI_DATA BETWEEN %exp:_ZBC_DTIIND% AND %exp:_ZBC_DTFIND%
					AND %notDel%
			endSQL
			if !QTMP->(Eof())
				&( "o" + cPFoVLRMED + "ZBCGDad"):aCols[ nAt, nPVLRMED ] := _ZBC_VLRMED := QTMP->MEDIA

				U_miZBCFieldOK('ZBC_VLRMED', _ZBC_VLRMED, nAt )

			EndIf
			QTMP->(DbCloseArea())
		EndIf

	ElseIf cCampo == 'ZBC_VLRMED' // Valor M�dio

		&( "o" + nPFoVLRSAC + "ZBCGDad"):aCols[ nAt, nPVLRSAC ] := _ZBC_VLRMED + _ZBC_OUTACR - _ZBC_OUTDES
	    &( "o" + cPFoBCPrc + "ZBCGDad"):aCols[ nAt, nPZBCPrc ] := Round( (_ZBC_VLRMED + _ZBC_OUTACR - _ZBC_OUTDES)/60, 4)

		U_miZBCFieldOK('ZBC_PRECO', _ZBC_PRECO, nAt )

	ElseIf cCampo == 'ZBC_OUTACR' // Outros Acrescimos

		// &( "o" + nPFoVLRSAC + "ZBCGDad"):aCols[ nAt, nPVLRSAC ] := _ZBC_VLRMED + _ZBC_OUTACR - _ZBC_OUTDES
	    // &( "o" + cPFoBCPrc + "ZBCGDad"):aCols[ nAt, nPZBCPrc ] := (_ZBC_VLRMED + _ZBC_OUTACR - _ZBC_OUTDES)/60
		U_miZBCFieldOK('ZBC_VLRMED', _ZBC_VLRMED, nAt )

	ElseIf cCampo == 'ZBC_OUTDES' // Outros Descontos
		
		// &( "o" + nPFoVLRSAC + "ZBCGDad"):aCols[ nAt, nPVLRSAC ] := _ZBC_VLRMED + _ZBC_OUTACR - _ZBC_OUTDES
	    // &( "o" + cPFoBCPrc + "ZBCGDad"):aCols[ nAt, nPZBCPrc ] := (_ZBC_VLRMED + _ZBC_OUTACR - _ZBC_OUTDES)/60
		U_miZBCFieldOK('ZBC_VLRMED', _ZBC_VLRMED, nAt )

	EndIf

	// REFRESH ABAS - ATUALIZA ABAS
	For nF := 1 to len(aFolderG)
		&( "o" + cValToChar(nF) + "ZBCGDad" ):Refresh()
	Next nF
Return lRet
// Fim: miZBCFieldOK


/* ########################################################################################################## */
User Function ChegaNaData(_dData, cOperacao, nDestino, nVezes)
Local lRet          := .T.
Local dRetorno      := _dData
Local __nVezes      := 0

Default nVezes      := 0

While lRet
	If Dow(dRetorno) <> nDestino
		If cOperacao == "+"
			dRetorno += 1
		ElseIf cOperacao == "-"
			dRetorno -= 1
		EndIf
	Else // If Dow(dRetorno) == nDestino
		If __nVezes < nVezes
			__nVezes += 1
		Else
			lRet := .F.
		EndIf
	EndIf
EndDo

Return dRetorno
/* ########################################################################################################## */

/* MJ : 17.12.2018 */
Static Function RetPosCpoAba( cCampo, cAba )
Local nRet := 1

cAba      := Posicione( 'SX3', 2, cCampo, "X3_FOLDER" )
If Empty(cAba)
	cAba := "1"
EndIf
nRet := aScan( &("a" + cAba + "ZBCHead"), { |x| AllTrim(x[2]) == cCampo } )

Return nRet

/* MJ : 09.11.2017 */
/*
Static Function VldOk(nOpc)
Local lRet 	:= .T.
Local nI	:= 0

	If M->ZCC_PAGFUT == "N"
		For nI:=1 to Len(oZICGDad:aCols)
			If Empty( oZICGDad:aCols[ nI, aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_VLAROB"}) ] ) .and. ;
				!Empty( oZICGDad:aCols[ nI, aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_QUANT"}) ] )
					Exit
			EndIf
		Next nI
		If nI <= Len(oZICGDad:aCols)
			Aviso("Aviso", ;
				  "Valor de @ nao informado na linha: " + AllTrim(Str(nI)) + ;
				  " na tabela dos ITENS DO CONTRATO / COMISS�O.", ;
				  {"Sair"} )
			lRet 	:= .F.
		EndIf
		If lRet
			For nI:=1 to Len(o1ZBCGDad:aCols)
				If !Empty( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEM"}) ] )
					If !Empty( &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nI, nPZBCQtd ] )
						Exit
					EndIf
				EndIf
			Next nI
			If nI <= Len(o1ZBCGDad:aCols)
				Aviso("Aviso", ;
					  "Valor de @ nao informado na linha: " + AllTrim(Str(nI)) + ;
					  " na tabela da CONFIGURA��O DA BASE CONTRATUAL.", ;
					  {"Sair"} )
				lRet 	:= .F.
			EndIf
		EndIf
	EndIf

Return lRet
*/

/* MJ : 13.11.2017 */
Static Function xAutoSC7()
Local aArea			:= GetArea()
local nI            := 0
Local lOk

if ZCC_STATUS=="A"
	if !msgYesNo("Esta opera��o bloquear� a edi��o do cabe�alho e itens, deseja continuar?")
		RestArea(aArea)
		return nil
	else
		M->ZCC_STATUS := "N"

		recLock("ZCC")
		ZCC->ZCC_STATUS := "N"
		msUnlock()

		oMGet:Disable()
	EndIf
EndIf

If M->ZCC_VERSAO != ZCC->ZCC_VERSAO // NOVA VERSAO
	Aviso("Aviso", "N�o � permitido gerar pedidos durante o processo de gera��o de nova vers�o. Salve a edi��o e clique em Alterar para gerar pedidos.", {"Sair"} )
	RestArea(aArea)
	return nil
EndIf

lOk := .T.
For nI := 1 to Len(o1ZBCGDad:aCols)
	If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
		if &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nI, nPZBCQtd ] == 0 .or. &( "o" + cPFoBCTot + "ZBCGDad"):aCols[ nI, nPZBCTot ] == 0  .or. empty( &( "o" + cPFoBCCDP + "ZBCGDad"):aCols[ nI, nPZBCCDP ] )
			Alert("Existem campos obrigat�rios n�o informados. Preencha-os antes de gerar o pedido.")
			RestArea(aArea)
			return nil
		EndIf
	EndIf
Next nI

// validar se existe pedido de compra ja existente na linha selecionada;
For nI:=1 to Len(o1ZBCGDad:aCols)
	If !Empty( o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEM"}) ] )
		If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK' .and. ;
			!Empty( &( "o" + cPFoBCPed + "ZBCGDad"):aCols[ nI, nPZBCPed ] )

				Exit
		EndIf
	EndIf
Next nI
If nI <= Len(o1ZBCGDad:aCols)
	MsgInfo( "O Pedido de Compra: <b>" + AllTrim( o1ZBCGDad:aCols[ nI, nPZBCPed]) + ;
		   "</b> ja se encontra vinculada na linha: <b>" + AllTrim(Str( nI )) + "</b>." + CRLF + "Esta opera��o ser� cancelada.", "Aten��o")

	RestArea(aArea)
	return nil
EndIf

// If Obrigatorio(aGets, aTela)
	Processa( { || xGeraSC7() }, 'Gerando Pedido de Compras', 'Aguarde ...', .F. )
// EndIf

RestArea(aArea)
Return nil


/* MJ : 08.11.2017
	Alt. 31.01.2018
		* Alterado formato do processamento do ExecAuto;
		* Permiss�o para varios produtos por pedido;
	*/
Static Function xGeraSC7()
Local aArea			:= GetArea()
Local nI            := 0
Local nF            := 0
Local nJ            := 0
Local aCab          := {}
Local aItem         := {}
Local aItens        := {}
Local cNumPc 		:= ""
Local lErro			:= .F.
Local dDtEntrega	:= sToD("")
Local nI, nItem		:= 0
Local ZBCCONDPA		:= ""
Local cErro			:= ""

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

If SM0->M0_CODFIL <> xFilial('SC7')
	SM0->(DbSeek(SM0->M0_CODIGO +  xFilial('SC7') ))
EndIf

Begin Transaction
	For nI := 1 to Len(o1ZBCGDad:aCols)
		If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'

			If Empty(ZBCCONDPA)
				// ZBCCONDPA := o1ZBCGDad:aCols[ nI, aScan( a1ZBCHead, {|x| AllTrim(x[2])=="ZBC_CONDPA"}) ]
				ZBCCONDPA := &( "o" + cPFoBCCDP + "ZBCGDad"):aCols[ nI, nPZBCCDP ]
			EndIf

			aItem := {}
			aAdd( aItem, { "C7_ITEM"   		, StrZero(Len(aItens)+1,TamSX3('C7_ITEM')[1]), nil } )

			aAdd( aItem, { "C7_PRODUTO"		, SB1->B1_COD				                 , nil } ) // aAdd( aItem, {	"C7_DESCRI"		, cDescrPrd		 			, nil  } )
			&( "o" + cPFoBCPRD + "ZBCGDad"):aCols[ nI, nPZBCPRD ] := SB1->B1_COD
			RepeatFolder( 'ZBC_PRODUT', SB1->B1_COD, Val(cPFoBCPRD), nI)
			//&( "o" + cPFoBCDES + "ZBCGDad"):aCols[ nI, nPZBCDES ] := SB1->B1_DESC
			//RepeatFolder( 'ZBC_PRDDES', SB1->B1_DESC, Val(cPFoBCDES), nI)

			aAdd( aItem, { "C7_UM"		, SB1->B1_UM				                 , nil } )
			aAdd( aItem, { "C7_LOCAL" 	, "01"   					                 , nil } )
			aAdd( aItem, { "C7_QUANT" 	, &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nI, nPZBCQtd ], nil } )
			aAdd( aItem, { "C7_PRECO" 	, &( "o" + cPFoBCPrc + "ZBCGDad"):aCols[ nI, nPZBCPrc ], nil } )
			aAdd( aItem, { "C7_TOTAL" 	, &( "o" + cPFoBCTot + "ZBCGDad"):aCols[ nI, nPZBCTot ], nil } )

			If Empty( &( "o" + cPFoBCTES + "ZBCGDad"):aCols[ nI, nPZBCTES ] )
				_cC7TES	:= GetMV("MB_COMM12D",,"005")
			Else
				_cC7TES := &( "o" + cPFoBCTES + "ZBCGDad"):aCols[ nI, nPZBCTES ]
			EndIf
			aAdd( aItem, { "C7_TES" 		, _cC7TES					                 , nil } )
			aAdd( aItem, { "C7_IPI" 		, 0  	   					                 , nil } )
			aAdd( aItem, { "C7_CC"   		, "" 						                 , nil } )
			// aAdd( aItem, { "C7_OBS" 		, &( "o" + cPFoBCOBS + "ZBCGDad"):aCols[ nI, nPZBCOBS ], nil } )
			// aAdd( aItem, { "C7_OBSM" 		, &( "o" + cPFoBCOBS + "ZBCGDad"):aCols[ nI, nPZBCOBS ], nil } )
			aAdd( aItem, { "C7_CONTATO" 	, ""   						                 , nil } )
			aAdd( aItem, { "C7_EMISSAO"		, dDataBase              	                 , nil } )
			aAdd( aItem, { "C7_CONTA" 		, GetMV("JR_M12CNTA",,"1140200001")	         , nil } )
			aAdd( aItem, { "C7_MSG"   		, ""						                 , nil } )
			aAdd( aItem, { "C7_PICM"   		, 0							                 , nil } )
			aAdd( aItem, { "C7_SEGURO"   	, 0							                 , nil } )
			aAdd( aItem, { "C7_DESPESA"   	, 0							                 , nil } )
			aAdd( aItem, { "C7_TXMOEDA"   	, 0							                 , nil } )
			aAdd( aItem, { "C7_VALFRE"   	, 0							                 , nil } )
			aAdd( aItem, { "C7_BASESOL"   	, 0							                 , nil } )
			aAdd( aItem, { "C7_MOEDA"    	, 1							                 , nil } )
			// aAdd( aItem, { "C7_TPFRETE"    	, "F" 						                 , nil } )

			// adicionais
			// If !Empty(&( "o" + cPFoBCPes + "ZBCGDad"):aCols[ nI, nPZBCPes ])
			// 	aAdd( aItem, { "C7_X_PESO"    	, &( "o" + cPFoBCPes + "ZBCGDad"):aCols[ nI, nPZBCPes ], nil  } )
			// EndIf
			// If !Empty(&( "o" + cPFoBCRen + "ZBCGDad"):aCols[ nI, nPZBCRen ])
			// 	aAdd( aItem, { "C7_X_REND"    	, &( "o" + cPFoBCRen + "ZBCGDad"):aCols[ nI, nPZBCRen ], nil  } )
			// EndIf
			// If !Empty(&( "o" + cPFoBCArv + "ZBCGDad"):aCols[ nI, nPZBCArv ])
			// 	aAdd( aItem, { "C7_X_ARROV"     , &( "o" + cPFoBCArv + "ZBCGDad"):aCols[ nI, nPZBCArv ], nil  } )
			// EndIf
			// If !Empty(&( "o" + cPFoBCToI + "ZBCGDad"):aCols[ nI, nPZBCToI ])
			// 	aAdd( aItem, { "C7_X_TOICM"     , &( "o" + cPFoBCToI + "ZBCGDad"):aCols[ nI, nPZBCToI ], nil  } )
			// EndIf
			// If !Empty(&( "o" + cPFoBCCor + "ZBCGDad"):aCols[ nI, nPZBCCor ])
			// 	aAdd( aItem, { "C7_X_CORRE"     , &( "o" + cPFoBCCor + "ZBCGDad"):aCols[ nI, nPZBCCor ], nil  } )
			// EndIf
			// If !Empty(&( "o" + cPFoBCVCM + "ZBCGDad"):aCols[ nI, nPZBCVCM ])
			// 	aAdd( aItem, { "C7_X_COMIS"     , &( "o" + cPFoBCVCM + "ZBCGDad"):aCols[ nI, nPZBCVCM ], nil  } )
			// EndIf
			// If !Empty(&( "o" + cPFoBCXTT + "ZBCGDad"):aCols[ nI, nPZBCXTT ])
			// 	aAdd( aItem, { "C7_X_TOTAL"    	, &( "o" + cPFoBCXTT + "ZBCGDad"):aCols[ nI, nPZBCXTT ], nil  } )
			// EndIf

			If Empty( dDtEntrega := &( "o" + cPFoBCDTE + "ZBCGDad"):aCols[ nI, nPZBCDTE ] )
				dDtEntrega := dDataBase
			EndIf
			aAdd( aItem, { "C7_DATPRF"      , dDtEntrega, nil  } )

			aAdd( aItens, aItem)
		EndIf
	Next nI

	If Len(aItens) == 0
		Alert('N�o foi localizado Item selecionado na Base Contratual.')

	Else

		cNumPc := U_ProxSC7_SC8()
		aAdd( aCab, { "C7_NUM"          , cNumPc					, nil  } )
		aAdd( aCab, { "C7_EMISSAO"      , dDataBase					, nil  } )
		aAdd( aCab, { "C7_FORNECE"      , M->ZCC_CODFOR				, nil  } )
		aAdd( aCab, { "C7_LOJA"         , M->ZCC_LOJFOR				, nil  } )
		aAdd( aCab, { "C7_COND"         , ZBCCONDPA 				, nil  } )
		aAdd( aCab, { "C7_FILENT"       , xFilial('SC7') 			, nil  } )
		aAdd( aCab, { "C7_TXMOEDA"      , 0		   					, nil  } )
		aAdd( aCab, { "C7_CONTATO"      , " "    					, nil  } )
		aAdd( aCab, { "C7_MOEDA"        , 1   						, nil  } )

		// FG_X3ORD("C", , aCab   )
		// FG_X3ORD("I", , aItens )

		lMsErroAuto := .F.
		MSExecAuto({|u,v,x,y| MATA120(u,v,x,y)}, 1, aCab, aItens, 3)

		If lErro := lMsErroAuto

			cErro := MostraErro()
			If lErro := !At("Deseja enviar email de aprova��o para o aprovador?", cErro) > 0

				// lErro := .T.
				RollbackSX8()
				DisarmTransaction()

				For nI := 1 to Len(o1ZBCGDad:aCols)
					If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
						&( "o" + cPFoBCPRD + "ZBCGDad"):aCols[ nI, nPZBCPRD ] := CriaVar('ZBC_PRODUT', .F.)
						// oZBCGDad:aCols[ nI, nPZBCDES ] := CriaVar('ZBC_PRDDES', .F.)
					EndIf
				Next nI
			EndIf
		Else
			RecLock('SC7', .F.)
				SC7->C7_TPFRETE := "F"
			SX7->(MsUnLock())
		EndIf
		If !lErro

			For nI := 1 to Len(o1ZBCGDad:aCols)
				If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
					// nPZIC := aScan( oZICGDad:aCols, {|x| AllTrim(x[nPZICIte])== o1ZBCGDad:aCols[ nI, nPZBCZIC] })
					nPZIC := nI

					SB1->( DbSetOrder(1) )
					If SB1->( DbSeek( xFilial('SB1')+ &( "o" + cPFoBCPRD + "ZBCGDad"):aCols[ nI, nPZBCPRD ] ) )
						RecLock('SB1', .F.)
							SB1->B1_XLOTCOM := xFilial('SC7')+SC7->C7_NUM
						SB1->( MsUnlock() )
					EndIf

					//Atualizando ZIC
					// oZICGDad:aCols[ nPZIC, nPZICQFc ] += o1ZBCGDad:aCols[ nI, nPZBCQtd ]

					// Atualizando ZBC
					&( "o" + cPFoBCPed + "ZBCGDad"):aCols[ nI, nPZBCPed ] := SC7->C7_NUM
					RepeatFolder( 'ZBC_PEDIDO', SC7->C7_NUM, 1, nI)

					nItem++
					&( "o" + cPFoBCPIt + "ZBCGDad"):aCols[ nI, nPZBCPIt ] := StrZero( nItem, TamSX3('C7_ITEM')[1] ) // SC7->C7_ITEM
					RepeatFolder( 'ZBC_ITEMPC', StrZero( nItem, TamSX3('C7_ITEM')[1] ), 1, nI)
					// &( "o" + cPFoBCPVs + "ZBCGDad"):aCols[ nI, nPZBCPVs ] := "01"

					o1ZBCGDad:aCols[ nI, nPMrkZBC] := "LBNO"
				EndIf
			Next nI

			// Enviar Email somente qdo executado do ambiente de PRODU��O
			If GetServerIP() == "192.168.0.243"
				U_ExecAutoOK( xFilial('SC7') + SC7->C7_NUM )
			EndIf

			//Adicionado por Renato de Bianchi
			//Verifica se j� atendeu ao contrato completamente
			if M->ZCC_QTDRES == 0
				nQtdAberto := 0
				For nJ := 1 to Len(o1ZBCGDad:aCols)
					If !o1ZBCGDad:aCols[nJ, Len(o1ZBCGDad:aCols[1]) ] .and. Empty( &( "o" + cPFoBCPed + "ZBCGDad"):aCols[ &( "o" + cPFoBCPed + "ZBCGDad"):nAt, nPZBCPed ])
						nQtdAberto++
					EndIf
				Next i
				if nQtdAberto == 0
					if msgYesNo("A quantidade de animais foi atendida totalmente, deseja encerrar este contrato?")
						cTxt := " "
						if !empty(AllTrim(M->ZCC_OBS))
							cTxt += AllTrim(M->ZCC_OBS) +chr(10)+chr(13)+chr(10)+chr(13)
						EndIf
						cTxt += "***** FECHAMENTO DO CONTRATO *****" +chr(10)+chr(13)
						cTxt += "*DATA: "+dToC(date()) +chr(10)+chr(13)
						cTxt += "*OPERADOR: "+AllTrim(__cUserId) + " - " + AllTrim(UsrRetName(__cUserId)) +chr(10)+chr(13)
						cTxt += padr('*',50,'*')+chr(10)+chr(13)
						cTxt += " FECHAMENTO POR ATENDIMENTO A QUANTIDADE DE ANIMAIS"

						M->ZCC_STATUS := "F"
						M->ZCC_OBS := cTxt

						RecLock('ZCC', .F.)
							ZCC->ZCC_STATUS := "F"
							ZCC->ZCC_OBS := cTxt
							ZCC->ZCC_TPCONT := "M"
						ZCC->( MsUnLock() )
					EndIf
				EndIf
			EndIf
			// Fim das altera��es
			GrvTable()

			SC7->( ConfirmSX8() )
			// DisarmTransaction() // esta funcao precisa ser retirada daqui, somente para DESENVOLVIMENTO;
								// ambiente de desenvolvimento INOPERANTE;

			For nF := 1 to len(aFolderG) // REFRESH ABAS - ATUALIZA ABAS
				&( "o" + cValToChar(nF) + "ZBCGDad" ):Refresh()
			Next nF

		EndIf
	EndIf
End Transaction

RestArea(aArea)

Return lErro

/* MJ : 17.11.2017
	# Separei em Funcao, para chamar para gravar as tabelas ap�s oBrowse
		ExecAuto
	*/
Static Function GrvTable()
Local nI 		:= 0
Local nF 		:= 0
Local lRecLock	:= .T.

	// Salvar contrato
	RecLock( "ZCC", .F. )
		U_GrvCpo("ZCC")
		ZCC->ZCC_TPCONT := "M"
	ZCC->(MsUnlock())

	/// Tabela 2 - Rodap�
	For nI := 1 to Len(o1ZBCGDad:aCols)
		If !o1ZBCGDad:aCols[nI, Len(o1ZBCGDad:aCols[1]) ] ;
				.AND. !Empty( &( "o" + cPFoBCITE + "ZBCGDad"):aCols[ nI, nPZBCITE ] ) // ;
				// .AND. !Empty( &( "o" + cPFoBCZIC + "ZBCGDad"):aCols[ nI, nPZBCZIC ] )

			DbSelectArea( "ZBC" )
			ZBC->( DbSetOrder( 1 ) )
			RecLock( "ZBC", lRecLock := !DbSeek( xFilial("ZBC") + M->ZCC_CODIGO + M->ZCC_VERSAO + &( "o" + cPFoBCITE + "ZBCGDad"):aCols[nI, nPZBCITE] /* + o1ZBCGDad:aCols[nI, nPZBCZIC] + o1ZBCGDad:aCols[nI, nPZBCPed] + o1ZBCGDad:aCols[nI, nPZBCPIt] + o1ZBCGDad:aCols[nI, nPZBCPVs] */ ) )

				For nF := 1 to len(aFolderG)
					U_GrvCpo( "ZBC", ;
							  &( "o" + cValToChar(nF) + "ZBCGDad" ):aCols, ;
							  &( "o" + cValToChar(nF) + "ZBCGDad" ):aHeader, nI )
				Next nF

				If lRecLock
					ZBC->ZBC_FILIAL := xFilial("ZBC")
					ZBC->ZBC_CODIGO := M->ZCC_CODIGO
					ZBC->ZBC_VERSAO := M->ZCC_VERSAO
					ZBC->ZBC_CODFOR := M->ZCC_CODFOR
					ZBC->ZBC_LOJFOR := M->ZCC_LOJFOR
					ZBC->ZBC_VERPED := '01'
					ZBC->ZBC_USUARI := cUserName
					ZBC->ZBC_DTALT  := Date()
				EndIf
			ZBC->( MsUnlock() )
		EndIf
	Next i

Return nil


/* MJ : 17.11.2017
	Funcao para Fechar Contrato em Versoes anteriores
 */
Static Function FechaContrato( cContrato, cVersao, nOpc )
Local aArea 	:= GetArea()
Local nI 		:= 1
Default nOpc	:= 4
	ZCC->(DbSetOrder(1))
	for nI := 1 to Val(cVersao)-1
		If ZCC->(DbSeek( xFilial('ZCC')+cContrato+StrZero( nI, TamSX3('ZCC_VERSAO')[1] )  ))
			RecLock('ZCC',.F.)
				ZCC->ZCC_STATUS := iif(nOpc == 6, "V", "F")
				ZCC->ZCC_TPCONT := "M"
			ZCC->(MsUnlock())
		EndIf
	next nI
RestArea(aArea)
Return nil


// -------------------------------------------------------------------------------------------
Static Function xAltStatus(cStatus)
Local lRet := .T.
Local oDlgTmp	:= nil
Local oMonoAs 	:= TFont():New( "Courier New",6,0) 	// Fonte para o campo Memo
Local nI := 0

Default cStatus := "F"

Private cMotivo := " "
Private cTitDlg := iif(cStatus=="F", "Fechamento do contrato", "Cancelamento do contrato")
Private aPeds := {}

if !ZCC->ZCC_STATUS$'AN'
	Alert('N�o � poss�vel alterar contratos cancelados ou fechados.')
	return .F.
EndIf

//Valida se tem pedido atendido
beginSQL alias "QRYTMP"
	%noParser%
	select *
	  from %table:ZBC% ZBC
	  join %table:SC7% SC7 on (C7_FILIAL=%xFilial:SC7% and SC7.%notDel% and C7_NUM=ZBC_PEDIDO and C7_ITEM=ZBC_ITEMPC and C7_RESIDUO=' ')
	 where ZBC_FILIAL=%xFilial:ZBC% and ZBC.%notDel%
	   and ZBC_CODIGO=%exp:ZCC->ZCC_CODIGO% and ZBC_VERSAO=%exp:ZCC->ZCC_VERSAO%
	   and ZBC_PEDIDO <> '      '
endSQL
if !QRYTMP->(Eof())
	while !QRYTMP->(Eof())
		nSldPed := QRYTMP->C7_QUANT - QRYTMP->C7_QUJE
		if nSldPed > 0
			aAdd(aPeds, QRYTMP->C7_NUM)
		EndIf

		QRYTMP->(dbSkip())
	endDo
EndIf
QRYTMP->(dbCloseArea())

lConfExc := .F.

if len(aPeds) > 0
	if !msgYesNo("O contrato atual possui pedidos de compra gerados em aberto, deseja continuar?")
		return .F.
	else
		lConfExc := .T.
	EndIf
EndIf

	DEFINE MSDIALOG oDlgTmp TITLE OemToAnsi(cTitDlg) From 05,10 TO 262,620	PIXEL STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )
   		oDlgTmp:lEscClose := .F.

		@  2,4 TO 25,302 LABEL "Informa��es do Contrato" OF oDlgTmp PIXEL

		@ 10,07 SAY "Contrato: "+ZCC->ZCC_CODIGO  SIZE  150,8 OF oDlgTmp PIXEL
		@ 10,90 SAY "Vers�o: "+ZCC->ZCC_VERSAO  SIZE  150,8 OF oDlgTmp PIXEL
		@ 16,07 SAY "Fornecedor: "+ZCC->ZCC_CODFOR+ "/"+ZCC->ZCC_LOJFOR+ " - "+ZCC->ZCC_NOMFOR SIZE  250,8 OF oDlgTmp PIXEL

		@ 26,4 TO 111,302 LABEL "Motivo do " + cTitDlg OF oDlgTmp PIXEL //"Descri�ao do Encerramento"
		@ 35,8 GET oMotivo VAR cMotivo OF oDlgTmp MEMO SIZE 290,70 PIXEL //When lHabil
		oMotivo:oFont := oMonoAs

	DEFINE SBUTTON FROM 115,230 TYPE 2 ACTION (lRet:=.F., oDlgTmp:End()) ENABLE OF oDlgTmp
	DEFINE SBUTTON FROM 115,270 TYPE 1 ACTION (lRet:=.T., oDlgTmp:End()) ENABLE OF oDlgTmp

	ACTIVATE MSDIALOG oDlgTmp CENTER

	if lRet
		if msgYesNo("O contrato n�o poder� ser alterado ap�s esta opera��o, deseja continuar?")
			cTxt := " "
			if !empty(AllTrim(ZCC->ZCC_OBS))
				cTxt += AllTrim(ZCC->ZCC_OBS) +chr(10)+chr(13)+chr(10)+chr(13)
			EndIf
			cTxt += "**********"+upper(cTitDlg)+ "**********" +chr(10)+chr(13)
			cTxt += "*DATA: "+dToC(date()) +chr(10)+chr(13)
			cTxt += "*OPERADOR: "+AllTrim(__cUserId) + " - " + AllTrim(UsrRetName(__cUserId)) +chr(10)+chr(13)
			if lConfExc .and. cStatus="C"
				cTxt += "**EXCLUSAO DE PEDIDOS - Usuario confirmou a exclusao dos pedidos em aberto**" +chr(10)+chr(13)
			EndIf
			if lConfExc .and. cStatus="F"
				cTxt += "**Usuario confirmou o encerramento parcial do contrato que possui pedidos em aberto**" +chr(10)+chr(13)
			EndIf
			cTxt += padr('*',60,'*')+chr(10)+chr(13)
			cTxt += cMotivo

			if cStatus="F" .and. (lConfExc .or. ZCC->ZCC_QTDRES > 0)
				cStatus := "P"
			EndIf

			RecLock('ZCC', .F.)
			ZCC->ZCC_STATUS := cStatus
			ZCC->ZCC_OBS := cTxt
			msUnLock()

			if cStatus="C" .and. len(aPeds) > 0 .and. lConfExc
				for nI := 1 to len(aPeds)
					u_xElResPC(aPeds[nI])
				next
			EndIf
		EndIf
	EndIf

Return nil

//Valida��o da exclus�o da linha da base contratual (Pedido)
user function miZBCDelOk(oObj)
Local lRet     := .T.
Local nI 	   :=  0
Local nAt      := oObj:oBrowse:nAt
Local nTotQtde := 0
Local lTodos   := .F.
Local nPZIC    := 0
Local nAux	   := 0
Local lMark

if !empty(oObj:aCols[ nAt, nPZBCPed])
	Alert("N�o � poss�vel deletar um registro com pedido j� gerado")
	return .F.
EndIf

return lRet

/* MJ : 24.01.2018 */
Static Function fCanSelBC()
Local lRet := .T.

	If !( lRet := !Empty( &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ o1ZBCGDad:oBrowse:nAt, nPZBCQtd ] ) )
		Alert('Quantidade n�o informada, por isso o item nao poder� ser selecionado.')

	// Esta validacao foi retirada no dia 02/04; sera permitido selecionar pois tbm sera utilizado para gerar o complemento duplo,
	// esta validacao de pedido existente esta agora na geracao do pedido.

	//		ElseIf !( lRet := Empty( o1ZBCGDad:aCols[ o1ZBCGDad:oBrowse:nAt, nPZBCPed ] ) )
	//			MsgInfo("O Pedido de Compra: <b>" + AllTrim( o1ZBCGDad:aCols[ o1ZBCGDad:oBrowse:nAt, nPZBCPed]) + ;
	//				  "</b> ja se encontra vinculada na linha: <b>" + AllTrim(Str( o1ZBCGDad:oBrowse:nAt)) + "</b>", 'Aviso')
	EndIf

return lRet


/*
Desenver Tela para levantar Nro do pedido;
e retornar para o filtro;
Filtro customizado, por Funcao customizada

ZCC_CODIGO == POSICIONE('ZBC', 2, XFILIAL('ZBC')+ '%ZBC_PEDIDO0%', 'ZBC_CODIGO')
POSICIONE('ZBC', 2, XFILIAL('ZBC')+'%ZBC_PEDIDO0%', 'ZBC_CODIGO') $ ZCC->ZCC_CODIGO
*/


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMM12()                                      |
 | Func:  COMM12PE()                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  12.11.2018                                                              |
 | Desc:  Tela para cadastro dos Pesos individualmente dos animais;               |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function COMM12PE(nLZBC)

Local aArea		  := GetArea()
Local nOpcA
Local nI          := 0
Local nGDOpc	  := GD_INSERT + GD_UPDATE + GD_DELETE
Local oDlgP		  := nil
Local oGrpP1 	  := nil
Local aZPEHead 	  := {}, aZPECols := {}, nUZPE := 1, oGrpP2 := nil
Local oGrpP3 	  := nil
Local aField  	  := {}
Local aButtons    := {}
Local cTitulo	  := "Cadastro de Pesos Individualmente - Linha: "
Local oObj		  := &( "o" + cValToChar( oTFoldeG:nOption ) + "ZBCGDad")

Private oMGetP	  := nil
Private oZPEGDad  := nil, oMGetE	  := nil

// Local cCpoNao    := "|ZAD_FILIAL|ZAD_CODIGO|ZAD_ITEM  |ZAD_EQUIPA| "
// Local cLstCpo    := "|ZAD_DATA  |ZAD_INICIO|ZAD_FINAL |ZAD_CC    |ZAD_CCDESC|ZAD_OPERAD|ZAD_NOMEOP| "

Private aGets     := {}
Private aTela     := {}

Private _cCodSB1  := CriaVar('ZBC_PRODUT', .F.)
Private _cDesSB1  := CriaVar('ZBC_PRDDES', .F.)
Private _cQuaZBC  := CriaVar('ZBC_QUANT' , .F.)
Private _cTotZBC  := CriaVar('ZBC_TOTAL' , .F.)
Private _cPesoZPE := CriaVar('ZPE_PESO'  , .F.)

// Grupo 3
Private _cQuaZPE  := CriaVar('ZBC_QUANT' , .F.)
Private _cTotZPE  := CriaVar('ZBC_QUANT' , .F.)
Private _cMedZPE  := CriaVar('ZBC_QUANT' , .F.)

Default nLZBC	  := oObj:oBrowse:nAt

cTitulo	+= cValToChar(nLZBC)

_cCodSB1  := oObj:aCols[ nLZBC, aScan( oObj:aHeader, { |x| AllTrim(x[2]) == "ZBC_PRODUT" }) ]
_cDesSB1  := AllTrim(_cCodSB1) + '-' + oObj:aCols[ nLZBC, aScan( oObj:aHeader, { |x| AllTrim(x[2]) == "ZBC_PRDDES" }) ]
_cQuaZBC  := o1ZBCGDad:aCols[ nLZBC, aScan( o1ZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_QUANT"  }) ]
_cTotZBC  := o1ZBCGDad:aCols[ nLZBC, aScan( o1ZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_TOTAL"  }) ]

DEFINE MSDIALOG oDlgP TITLE OemToAnsi(cTitulo) From 0,0 to 600,500 PIXEL STYLE ; // 565,360
				nOR( WS_VISIBLE ,DS_MODALFRAME )  // tirar o X da tela | tirar o botao X da tela |

//                       Titulo,     Campo  , Tipo,                 Tamanho,                 Decimal,                 Pict,                                Valid, Obrigat, Nivel,                     Inic Padr, F3,   When, Visual, Chave, CBox, Folder, N Alteravel, PictVar, Gatilho
//aAdd(aField, { "Cod. Produto" , "_cCodSB1", "C", TamSX3("ZBC_PRODUT")[1], TamSX3("ZBC_PRODUT")[2], PesqPict("ZBC", "ZBC_PRODUT"), /* { || VldCpo(2) } */	,     .F.,     1, GetSX8Num('ZAD','ZBC_PRODUT'), ""   , "" ,    .F.,   .F.,   "",      2,     .F.,          "",      "N"} )
aAdd(aField, { "Produto"        , "_cDesSB1" , "C", TamSX3("ZBC_PRDDES")[1], TamSX3("ZBC_PRDDES")[2], PesqPict("ZBC", "ZBC_PRDDES"), /* { || U_Vd1MNT01() } */   ,     .F.,     1,                            "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
aAdd(aField, { "Quant."	       , "_cQuaZBC" , "N", TamSX3("ZBC_QUANT" )[1], TamSX3("ZBC_QUANT")[2] , PesqPict("ZBC", "ZBC_QUANT" ), /* { || VldCpo(2) }    */   ,     .F.,     1,                            "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
aAdd(aField, { "Total"	       , "_cTotZBC" , "N", TamSX3("ZBC_TOTAL" )[1], TamSX3("ZBC_TOTAL")[2] , PesqPict("ZBC", "ZBC_TOTAL" ), /* { || VldCpo(2) }    */   ,     .F.,     1,                            "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
aAdd(aField, { "Digite o Peso:", "_cPesoZPE", "N", TamSX3("ZPE_PESO" )[1] , TamSX3("ZPE_PESO")[2]  , PesqPict("ZPE", "ZPE_PESO" ) , { || VldCpo(4) }            ,     .F.,     1,                            "", ""   , "" ,    .F.,   .F.,   "",      1,         .F.,      "",      "N"} )

nDist := 2
nL1 := 32; nC1 := nDist
nL2 := nL1 + 78 /* 110 */; nC2 := 250 /* 180 */
oGrpP1 := TGroup():New( nL1, nC1, nL2, nC2, "Dados Gerais do Contrato",oDlgP,,, .T.,)
	oMGetP := MsMGet():New(,, 3/* nOpc */,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,{0,0,0,0}/* aPObjs[1] */,/*aAlterEnch*/,/*nModelo*/,;
						/*nColMens*/,/*cMensagem*/, /*cTudoOk*/, oGrpP1,/*lF3*/,/*lMemoria*/, .F. /*lColumn*/,;
						nil /*caTela*/,/*lNoFolder*/, .T. /*lProperty*/,aField,/* aFolder */,/*lCreate*/,/*lNoMDIStretch*/,;
						/*cTela*/)
oMGetP:oBox:Align := CONTROL_ALIGN_ALLCLIENT

U_BDados( "ZPE", @aZPEHead, @aZPECols, @nUZPE, 1 /* nOrd */, /* lFilial */, ;
					"ZPE->ZPE_FILIAL + ZPE->ZPE_CODIGO + ZPE->ZPE_VERSAO + ZPE->ZPE_ITEZBC == '" + xFilial("ZPE") + M->ZCC_CODIGO + M->ZCC_VERSAO + StrZero(nLZBC ,TamSX3('ZBC_ITEM')[1]) + "'", ;
					/* lStatus */, /* cCpoLeg */, /* cLstCpo */, /* cElimina */, /* cCpoNao */, /* cStaReg */, ;
					/* cCpoMar */, /* cMarDef */, /* lLstCpo */, /* aLeg */, /* lEliSql */, /* lOrderBy */, ;
					/* cCposGrpBy */, /* cGroupBy */, /* aCposIni */, /* aJoin */, /* aCposCalc */, /* cOrderBy */, ;
					/* aCposVis */, /* aCposAlt */, /* cCpoFilial */, /* nOpcX */ )

If Len(aZPECols) == 1 .and. Empty(aZPECols[1,4])
	aZPECols[ 1, /* nPZPEIt:= */aScan( aZPEHead, { |x| AllTrim(x[2]) == "ZPE_ITEM" })] :=  StrZero( 1, TamSX3('ZPE_ITEM')[1])
Else
	For nI:=1 to _cQuaZPE:=len(aZPECols)
		_cTotZPE += aZPECols[ nI, 2]
	Next nI
	_cMedZPE := Round(_cTotZPE / _cQuaZPE,2)
EndIf

nL3 := nL2 + 135 // 245
oGrpP2 := TGroup():New( nL2+nDist, nC1, nL3,nC2, "Tabela de Pesos",oDlgP,,, .T.,)
oZPEGDad := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , "+ZPE_ITEM", , , 99999, , , "u_ZPEDelOk()" , oGrpP2, ;
									aClone(aZPEHead), aClone( aZPECols ) )
oZPEGDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oZPEGDad:cFieldOK      := "U_ZPEFieldOK()"
oZPEGDad:bChange       := {|| U_ZPEbChange() }
// oZPEGDad:bLinhaOK      := {|| U_ZPELinOK() }
// oZPEGDad:bBeforeEdit   := {|| U_ZPEbBeforeEdit() }
oZPEGDad:oBrowse:nColPos := 2
oZPEGDad:Refresh()
oZPEGDad:oBrowse:SetFocus()
// 0	Nenhum			CONTORL_ALIGN_NONE
// 1	Esquerda		CONTROL_ALIGN_LEFT
// 2	Direita			CONTROL_ALIGN_RIGHT
// 3	Topo			CONTROL_ALIGN_TOP
// 4	Abaixo			CONTROL_ALIGN_BOTTOM
// 5	Todo o espa�o	CONTROL_ALIGN_ALLCLIENT
// 6	Centro			CONTROL_ALIGN_CENTER

nL4 := nL3 + 50 // 295
oGrpP3 := TGroup():New( nL3+nDist, nC1, nL4,nC2, "Totalizadores",oDlgP,,, .T.,)
aField := {}

//                   Titulo,     Campo, Tipo,                 Tamanho,                 Decimal,                 Pict,                           Valid, Obrigat, Nivel,                     Inic Padr, F3,   When, Visual, Chave, CBox, Folder, N Alteravel, PictVar, Gatilho
aAdd(aField, { "Qtd Cad."  , "_cQuaZPE", "N", TamSX3("ZBC_QUANT" )[1], TamSX3("ZBC_QUANT")[2] , PesqPict("ZBC", "ZBC_QUANT" ), /* { || VldCpo(2) } */	,     .F.,     1,                            "", ""   , "" ,    .F.,   .F.,   "",   2,     .F.,          "",      "N"} )
aAdd(aField, { "Total Peso", "_cTotZPE", "N", TamSX3("ZBC_QUANT" )[1], TamSX3("ZBC_QUANT")[2] , PesqPict("ZBC", "ZBC_QUANT" ), /* { || VldCpo(2) } */	,     .F.,     1,                            "", ""   , "" ,    .F.,   .F.,   "",   2,     .F.,          "",      "N"} )
aAdd(aField, { "M�dia Peso", "_cMedZPE", "N", TamSX3("ZBC_QUANT" )[1], TamSX3("ZBC_QUANT")[2] , PesqPict("ZBC", "ZBC_QUANT" ), /* { || VldCpo(2) } */	,     .F.,     1,                            "", ""   , "" ,    .F.,   .F.,   "",   2,     .F.,          "",      "N"} )
oMGetE := MsMGet():New(,, 2/* nOpc */,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,{0,0,0,0}/* aPObjs[1] */,/*aAlterEnch*/,/*nModelo*/,;
						/*nColMens*/,/*cMensagem*/, /*cTudoOk*/, oGrpP3,/*lF3*/,/*lMemoria*/, .F. /*lColumn*/,;
						nil /*caTela*/,/*lNoFolder*/, .T. /*lProperty*/,aField,/* aFolder */,/*lCreate*/,/*lNoMDIStretch*/,;
						/*cTela*/)
oMGetE:oBox:Align := CONTROL_ALIGN_ALLCLIENT

AAdd( aButtons, { "AUTOM", { || ZPEPrint(nLZBC)  }, "Imprimir" } )
Set Key K_CTRL_P To ZPEPrint(nLZBC)

ACTIVATE MSDIALOG oDlgP ;
          ON INIT EnchoiceBar(oDlgP,;
                              { || nOpcA := 1, Iif( VldCpo(5) .and. Obrigatorio(aGets, aTela), oDlgP:End(), nOpcA := 0)},;
                              { || nOpcA := 0, oDlgP:End() },, aButtons)

If nOpcA == 1
	Begin Transaction
		For nI := 1 to Len(oZPEGDad:aCols)
			If !oZPEGDad:aCols[nI][ Len(oZPEGDad:aCols[1]) ] .AND. !Empty( oZPEGDad:aCols[ nI, 2] )
				DbSelectArea( "ZPE" )
				ZPE->( DbSetOrder( 1 ) )
				RecLock( "ZPE", lRecLock := !DbSeek( xFilial("ZPE") + M->ZCC_CODIGO + M->ZCC_VERSAO + StrZero(nLZBC ,TamSX3('ZBC_ITEM')[1]) + oZPEGDad:aCols[ nI, 1 ]  ) )
					U_GrvCpo( "ZPE", oZPEGDad:aCols, oZPEGDad:aHeader, nI )
					If lRecLock
						ZPE->ZPE_FILIAL := xFilial("ZPE")
						ZPE->ZPE_CODIGO := M->ZCC_CODIGO
						ZPE->ZPE_VERSAO := M->ZCC_VERSAO
						ZPE->ZPE_ITEZBC := StrZero(nLZBC ,TamSX3('ZPE_ITEZBC')[1])
					EndIf
				ZPE->( MsUnlock() )
				// lAtuX8 := .T.
			Else // Se o registro foi excluido e existe no banco apaga
				DbSelectArea( "ZPE" )
				ZPE->( DbSetOrder( 1 ) )
				If ZPE->( DbSeek( xFilial("ZPE") + M->ZCC_CODIGO + M->ZCC_VERSAO + StrZero(nLZBC ,TamSX3('ZBC_ITEM')[1]) + oZPEGDad:aCols[ nI, 1 ] ) )
					RecLock("ZPE", .F.)
						ZPE->( DbDelete() )
					ZPE->( MsUnlock() )
				EndIf
			EndIf
		Next i

	End Transaction
EndIf

RestArea(aArea)
Return nil



/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMM12()                                      |
 | Func:  COMM12PE()                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  17.05.2019                                                              |
 | Desc:  Tela para cadastro dos Juros;                                           |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function COMM12JR(nLZJC) // Juros

Local aArea		  := GetArea()
Local nOpcA
Local nI          := 0
Local nGDOpc	  := GD_INSERT + GD_UPDATE + GD_DELETE
Local oDlgJ		  := nil
Local aZJCHead 	  := {}, aZJCCols := {}, nUZJC := 1
Local cTitulo	  := "Cadastro de Juros - Linha: "
Local oObj		  := &( "o" + cValToChar( oTFoldeG:nOption ) + "ZBCGDad")
Local oGrpP1 	  := nil, oGrpP2 := nil
Local aField	  := {}
Private aGets     := {}
Private aTela     := {}

Private _cTotZJC  := CriaVar('ZJC_VLRBAS', .F.)

Default nLZJC	  := oObj:oBrowse:nAt

cTitulo	+= cValToChar(nLZJC)

DEFINE MSDIALOG oDlgJ TITLE OemToAnsi(cTitulo) From 0,0 to 400,700 PIXEL STYLE ; // 565,360
										nOR( WS_VISIBLE ,DS_MODALFRAME )  // tirar o X da tela | tirar o botao X da tela |

U_BDados( "ZJC", @aZJCHead, @aZJCCols, @nUZJC, 1 /* nOrd */, /* lFilial */, ;
					"ZJC->ZJC_FILIAL + ZJC->ZJC_CODIGO + ZJC->ZJC_VERSAO + ZJC->ZJC_ITEM == '" + xFilial("ZJC") + M->ZCC_CODIGO + M->ZCC_VERSAO + StrZero(nLZJC ,TamSX3('ZJC_ITEM')[1]) + "'", ;
					/* lStatus */, /* cCpoLeg */, /* cLstCpo */, /* cElimina */, /* cCpoNao */, /* cStaReg */, ;
					/* cCpoMar */, /* cMarDef */, /* lLstCpo */, /* aLeg */, /* lEliSql */, /* lOrderBy */, ;
					/* cCposGrpBy */, /* cGroupBy */, /* aCposIni */, /* aJoin */, /* aCposCalc */, /* cOrderBy */, ;
					/* aCposVis */, /* aCposAlt */, /* cCpoFilial */, /* nOpcX */ )
If Len(aZJCCols) == 1 .and. Empty(aZJCCols[1,aScan( aZJCHead, { |x| AllTrim(x[2]) == "ZJC_VLRBAS" })])
	aZJCCols[ 1, /* nPZJCIt:= */aScan( aZJCHead, { |x| AllTrim(x[2]) == "ZJC_SEQUEN" })] :=  StrZero( 1, TamSX3('ZJC_SEQUEN')[1])
EndIf

oGrpP1 := TGroup():New( 32, nDist:=3, LFa:=150, CFa:=350, "Tabela de Juros", oDlgJ,,, .T.,)
oZJCGDad := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , "+ZJC_SEQUEN" , , , 99999, , , "u_ZJCDelOk()", oGrpP1, ;
									aClone(aZJCHead), aClone( aZJCCols ) )
oZJCGDad:cFieldOK      := "U_M12JRTot()"
oZJCGDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGrpP2 := TGroup():New( LIb:=LFa+nDist, nDist, LIb+45, CFa, "Totalizadores", oDlgJ,,, .T.,)
aAdd(aField, { "Total"	       , "_cTotZJC" , "N", TamSX3("ZJC_VLRBAS" )[1], TamSX3("ZJC_VLRBAS")[2] , PesqPict("ZJC", "ZJC_VLRBAS" ), /* { || VldCpo(2) }    */   ,     .F.,     1,                            "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
oMGetP := MsMGet():New(,, 3/* nOpc */,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,{0,0,0,0}/* aPObjs[1] */,/*aAlterEnch*/,/*nModelo*/,;
						/*nColMens*/,/*cMensagem*/, /*cTudoOk*/, oGrpP2,/*lF3*/,/*lMemoria*/, .F. /*lColumn*/,;
						nil /*caTela*/,/*lNoFolder*/, .T. /*lProperty*/,aField,/* aFolder */,/*lCreate*/,/*lNoMDIStretch*/,;
						/*cTela*/)
oMGetP:oBox:Align := CONTROL_ALIGN_ALLCLIENT

// Atualizando Campo Total
For nI:=1 to len(oZJCGDad:aCols)
	_cTotZJC += oZJCGDad:aCols[nI,aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_VLRJUR" })]
Next nI
// oMGetP:Refresh()

ACTIVATE MSDIALOG oDlgJ ;
          ON INIT EnchoiceBar(oDlgJ,;
                              { || nOpcA := 1, Iif( /*VldCpo(5) .and.*/Obrigatorio(aGets, aTela), oDlgJ:End(), nOpcA := 0)},;
                              { || nOpcA := 0, oDlgJ:End() },, /* aButtons */ )

If nOpcA == 1

	Begin Transaction
		For nI := 1 to Len(oZJCGDad:aCols)
			If !oZJCGDad:aCols[nI][ Len(oZJCGDad:aCols[1]) ] .AND. !Empty( oZJCGDad:aCols[ nI, 2] )
				DbSelectArea( "ZJC" )
				ZJC->( DbSetOrder( 1 ) )
				RecLock( "ZJC", lRecLock := !DbSeek( xFilial("ZJC") + M->ZCC_CODIGO + M->ZCC_VERSAO + StrZero(nLZJC ,TamSX3('ZBC_ITEM')[1]) + oZJCGDad:aCols[ nI, 1 ] ) )
					U_GrvCpo( "ZJC", oZJCGDad:aCols, oZJCGDad:aHeader, nI )
					If lRecLock
						ZJC->ZJC_FILIAL := xFilial("ZJC")
						ZJC->ZJC_CODIGO := M->ZCC_CODIGO
						ZJC->ZJC_VERSAO := M->ZCC_VERSAO
						ZJC->ZJC_ITEM   := StrZero(nLZJC ,TamSX3('ZJC_ITEM')[1])
					EndIf
				ZJC->( MsUnlock() )
				// lAtuX8 := .T.
			Else // Se o registro foi excluido e existe no banco apaga
				DbSelectArea( "ZJC" )
				ZJC->( DbSetOrder( 1 ) )
				If ZJC->( DbSeek( xFilial("ZJC") + M->ZCC_CODIGO + M->ZCC_VERSAO + StrZero(nLZJC ,TamSX3('ZJC_ITEM')[1]) + oZJCGDad:aCols[ nI, 1 ] ) )
					RecLock("ZJC", .F.)
						ZJC->( DbDelete() )
					ZJC->( MsUnlock() )
				EndIf
			EndIf
		Next i

		If _cTotZJC > 0
			// &( "o" + cPFoBCJur + "ZBCGDad"):aCols[ nLZJC, nPZBCJur ] := _cTotZJC

			U_miZBCFieldOK('ZBC_JUROS', _cTotZJC, nLZJC /* , oTFoldeG:nOption */ )
		EndIf
	End Transaction

EndIf

RestArea(aArea)

Return nil


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMM12()                                      |
 | Func:  VldCpo()		                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  28.12.2018                                                              |
 | Desc:  Valida��o dos Campos MsMGet;                                            |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function M12JRTot(_cCampo)
Local nI		:= 0
Local nAt		:= oZJCGDad:oBrowse:nAt
Local _nAux		:= 0

Default _cCampo	:= ReadVar()

If _cCampo=='M->ZJC_VLRBAS'

	If Len(oZJCGDad:aCols) > 1 .and. nAt == Len(oZJCGDad:aCols)
		oZJCGDad:aCols[ len(oZJCGDad:aCols), aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTINIC" })] := oZJCGDad:aCols[ len(oZJCGDad:aCols)-1, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTFINA" })]
	EndIf

ElseIf _cCampo=='M->ZJC_DTINIC'

	// If !Empty(oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTINIC" })]) .and. !Empty(oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTFINA" })])
	If !Empty(&(ReadVar())) .and. !Empty(oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTFINA" })])
		// oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_QTDIAS" })] := oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTFINA" })] - oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTINIC" })]
		oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_QTDIAS" })] := oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTFINA" })] - &(ReadVar())
	EndIf

ElseIf _cCampo=='M->ZJC_DTFINA'

	// If !Empty(oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTINIC" })]) .and. !Empty(oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTFINA" })])
	If !Empty(oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTINIC" })]) .and. !Empty(&(ReadVar()))
		// oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_QTDIAS" })] := oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTFINA" })] - oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTINIC" })]
		oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_QTDIAS" })] := &(ReadVar()) - oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_DTINIC" })]
	EndIf

ElseIf _cCampo=='M->ZJC_TXMENS'

	// oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_VLRJUR" })] := oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_VLRBAS" })]*oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_TXMENS" })]/100

	_nAux := oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_VLRBAS" })]*&(ReadVar())/100
	oZJCGDad:aCols[ nAt, aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_VLRJUR" })] := _nAux

	_cTotZJC := 0
	For nI:=1 to len(oZJCGDad:aCols)
		If !oZJCGDad:aCols[ nI, Len(oZJCGDad:aCols[nI]) ]
			If nI==nAt
				_cTotZJC += _nAux
			Else
				_cTotZJC += oZJCGDad:aCols[nI,aScan( oZJCGDad:aHeader, { |x| AllTrim(x[2]) == "ZJC_VLRJUR" })]
			EndIf
		EndIf
	Next nI
	oMGetP:Refresh()
EndIf

Return .T.


Static nPosPESO	:= 2
/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMM12()                                      |
 | Func:  VldCpo()		                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  28.12.2018                                                              |
 | Desc:  Valida��o dos Campos MsMGet;                                            |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function VldCpo(nOpc)
Local lRet := .T.
Local nAux := 0
Local lVld := .F.

	If nOpc == 4
		If !Empty(_cPesoZPE)
			lVld := .T.
		EndIf
	ElseIf nOpc == 5 // ZPE_PESO''
		lVld := .T.
		nAux := -1
		// oZPEGDad:ForceRefresh()
	EndIf
	If lVld
		If ( lRet := (_cQuaZPE+nAux) < _cQuaZBC )
			If nOpc == 4
				If (oZPEGDad:aCols[ Len(oZPEGDad:aCols) , Len(oZPEGDad:aCols[ Len(oZPEGDad:aCols) ]) ] .OR. ;
					!Empty( oZPEGDad:aCols[ Len(oZPEGDad:aCols) , nPosPESO ] ))

						oZPEGDad:AddLine(.T., .T.)
						oZPEGDad:ForceRefresh()
				EndIf

				oZPEGDad:aCols[ Len(oZPEGDad:aCols) , nPosPESO ] := _cPesoZPE

				//oMGetP:aGets[4]:SetFocus() // ZPE_PESO
				oMGetP:SetFocus()
				oZPEGDad:Refresh()
			EndIf
			U_ZPEFieldOK()
		Else
			MsgInfo( "O limite de " + cValToChar(_cQuaZBC) + " registros foi alcan�ado.", "Aviso" )
		EndIf
		_cPesoZPE := CriaVar('ZPE_PESO'  , .F.)
		oMGetP:Refresh()
	EndIf

Return lRet


Static Function ZPEPrint(nLZBC)

Local cTimeIni	 	:= Time()
Local lTemDados		:= .T.

Private cPerg		:= "COMM12ZPE"
Private cTitulo  	:= "Relatorio Lotes de Compra"

Private cPath 	 	:= "C:\totvs_relatorios\"
Private cArquivo   	:= cPath + cPerg +; // __cUserID+ "_"+;
								DtoS(dDataBase)+;
								"_"+;
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
Private oExcelApp   := nil
Private _cAliasG	:= GetNextAlias()

Private nHandle    	:= 0

Default nLZBC	    := &( "o" + cValToChar( oTFoldeG:nOption ) + "ZBCGDad"):oBrowse:nAt  // Default nLZBC := o1ZBCGDad:oBrowse:nAt

If Len( Directory(cPath + "*.*","D") ) == 0
	If Makedir(cPath) == 0
		ConOut('Diretorio Criado com Sucesso.')
	Else
		ConOut( "N�o foi possivel criar o diret�rio. Erro: " + cValToChar( FError() ) )
	EndIf
EndIf

nHandle := FCreate(cArquivo)
if nHandle = -1
	conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
else

	cStyle := U_defStyle()

	// Processar SQL
	FWMsgRun(, {|| lTemDados := VASqlM12("Geral", @_cAliasG, nLZBC ) },'Por Favor Aguarde...' , 'Processando Banco de Dados')
	If lTemDados
		cXML := U_CabXMLExcel(cStyle)

		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
			cXML := ""
		EndIf

		// Gerar primeira planilha
		FWMsgRun(, {|| fQuadro1(nLZBC) },'Gerando excel, Por Favor Aguarde...', 'Gera��o do quadro de Lotes Analitico')

		// Final - encerramento do arquivo
		FWrite(nHandle, EncodeUTF8( '</Workbook>' ) )

		FClose(nHandle)

		If ApOleClient("MSExcel")				//	 U_VARELM01()
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open( cArquivo )
			oExcelApp:SetVisible(.T.)
			oExcelApp:Destroy()
			// ou >  ShellExecute( "Open", cNameFile , '', '', 1 ) //Abre o arquivo na tela ap�s salvar
		Else
			MsgAlert("O Excel n�o foi encontrado. Arquivo " + cArquivo + " gerado em " + cPath + ".", "MsExcel n�o encontrado" )
		EndIf

	Else
		MsgAlert("Os parametros informados n�o retornou nenhuma informa��o do banco de dados." + CRLF + ;
				 "Por isso o excel n�o sera aberto automaticamente.", "Dados n�o localizados")
	EndIf

	(_cAliasG)->(DbCloseArea())

	If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
		Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
	EndIf

	ConOut('Activate: ' + Time())
EndIf

Return nil

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMM12()                                      |
 | Func:  VASqlM12()	                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  14.05.2018                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function VASqlM12(cTipo, _cAlias, nLZBC)
Local _cQry 		:= ""

Default nLZBC	    := o1ZBCGDad:oBrowse:nAt

If cTipo == "Geral"

	_cQry := " SELECT ZPE_ITEM, ZPE_PESO " + CRLF
	_cQry += " FROM ZPE010" + CRLF
	_cQry += " WHERE" + CRLF
	_cQry += " 	    ZPE_FILIAL='"+ xFilial("ZPE") + "' " + CRLF
	_cQry += " 	AND ZPE_CODIGO='"+ M->ZCC_CODIGO + "' " + CRLF
	_cQry += " 	AND ZPE_VERSAO='"+ M->ZCC_VERSAO + "' " + CRLF
	_cQry += " 	AND ZPE_ITEZBC='"+ StrZero(nLZBC ,TamSX3('ZBC_ITEM')[1]) + "' " + CRLF
	_cQry += " 	AND D_E_L_E_T_=' '" + CRLF
	_cQry += " ORDER BY ZPE_ITEM " + CRLF

EndIf

If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+ "_Quadro_" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.)

// TcSetField(_cAlias, "ZBC_DTENTR", "D")

Return !(_cAlias)->(Eof())


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMM12()                                      |
 | Func:  fQuadro1()	                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  14.05.2018                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro1(nLZBC)

Local cXML 			:= ""
Local cWorkSheet 	:= "Pesos"
Local nLin			:= 0
Local cAux		  	:= ""

(_cAliasG)->(DbGoTop())
If !(_cAliasG)->(Eof())

	     cXML := '<Worksheet ss:Name="' + U_FrmtVlrExcel(cWorkSheet) + '">' + CRLF
	     cXML += ' <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="16">' + CRLF
	     cXML += '   <Column ss:Width="61.5"/>   ' + CRLF
		 cXML += '   <Column ss:Width="113.25"/> ' + CRLF
		 cXML += '   <Column ss:Width="105"/>    ' + CRLF
		 cXML += '   <Column ss:Width="96"/>     ' + CRLF
		 cXML += '   <Column ss:Width="63.75"/>  ' + CRLF
		 cXML += '   <Column ss:Width="146.25"/> ' + CRLF
		 cXML += '   <Column ss:Width="48.75"/>  ' + CRLF
		 cXML += '   <Column ss:Width="72.75"/>  ' + CRLF
		 cXML += '   <Column ss:Width="62.75"/>  ' + CRLF
         cXML += ' <Row ss:AutoFitHeight="0" ss:Height="36">' + CRLF
         cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Numero Contrato:</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Fornecedor:</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Municipio/Est</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Corretor:</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Numero do Pedido:</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Produto:</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Quant.</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Pre�o Total</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">M�dia Pre�o</Data></Cell>' + CRLF
		 cXML += '</Row>' + CRLF
		 cXML += '<Row>' + CRLF
         cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( M->ZCC_CODIGO ) + '</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( M->ZCC_CODFOR + "-" + M->ZCC_NOMFOR ) + '</Data></Cell>' + CRLF
		 cAux := Posicione("SA2", 1, xFilial("SA2")+M->ZCC_CODFOR+M->ZCC_LOJFOR, "A2_MUN") + "/" + SA2->A2_EST
         cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'+U_FrmtVlrExcel( cAux )+'</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( AllTrim(M->ZCC_CODCOR) + "-" + M->ZCC_NOMCOR ) + '</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( o1ZBCGDad:aCols[ nLZBC, aScan( o1ZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_PEDIDO" })] + "-" + o1ZBCGDad:aCols[ nLZBC, aScan( o1ZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_ITEMPC" })] ) + '</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( AllTrim(o1ZBCGDad:aCols[ nLZBC, aScan( o1ZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_PRODUT" })]) + "-" + AllTrim(o1ZBCGDad:aCols[ nLZBC, aScan( o1ZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_PRDDES" })]) ) + '</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( o1ZBCGDad:aCols[ nLZBC, aScan( o1ZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_QUANT" })] ) + '</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="sReal"><Data ss:Type="Number">' + U_FrmtVlrExcel( o1ZBCGDad:aCols[ nLZBC, aScan( o1ZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_TOTAL" })] ) + '</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=RC[-1]/RC[-2]"><Data ss:Type="Number"></Data></Cell>' + CRLF
		 cXML += '</Row>' + CRLF

		 cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF // PULAR LINHA

		 cXML += '<Row ss:AutoFitHeight="0">
		 cXML += '	<Cell ss:StyleID="s65"><Data ss:Type="String">Negocia��o</Data></Cell>
		 cXML += '</Row>

		 // P=Peso/Rend;K=Kilo;Q=Qtde
		 cXML += '<Row ss:AutoFitHeight="0">
		 // cAux := oZICGDad:aCols[ Val(o1ZBCGDad:aCols[ nLZBC, aScan( o1ZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_ITEZIC" })]), ;
		 // 						 aScan( oZICGDad:aHeader, { |x| AllTrim(x[2]) == "ZIC_TPNEG" })]
		 cAux := o1ZBCGDad:aCols[ nLZBC, nPZBCTPN ]
		 if cAux=="P"
			cAux:="Peso/Rendimento"
		 ElseIf cAux=="K"
			cAux:="Kilo"
		 ElseIf cAux=="Q"
		 	cAux:="Quantidade"
		 Else
		 	cAux := "N�o Identificado"
		 EndIf
         cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">' + U_FrmtVlrExcel( cAux ) + '</Data></Cell>' + CRLF
		 cXML += '</Row>

		 cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF // PULAR LINHA

	     cXML += ' <Row>' + CRLF
         cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Item</Data></Cell>' + CRLF
         cXML += '   <Cell ss:StyleID="s65"><Data ss:Type="String">Peso</Data></Cell>' + CRLF
		 cXML += ' </Row>' + CRLF

	//fQuadro1
	While !(_cAliasG)->(Eof())	 // U_VACOMR07()
		 nLin += 1

		 cXML += '<Row>' + CRLF
         cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( (_cAliasG)->ZPE_ITEM ) + '</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( (_cAliasG)->ZPE_PESO ) + '</Data></Cell>' + CRLF
		 cXML += '</Row>' + CRLF

		(_cAliasG)->(DbSkip())
	EndDo

	cXML += ' <Row>' + CRLF
    cXML += ' 	<Cell ss:StyleID="sTextoN"><Data ss:Type="String">Total Peso</Data></Cell>' + CRLF
	cXML += ' 	<Cell ss:Index="2" ss:StyleID="sComDigN" ss:Formula="=SUM(R[-'+cValToChar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
	cXML += ' </Row>' + CRLF

	cXML += ' <Row>' + CRLF
    cXML += ' 	<Cell ss:StyleID="sTextoN"><Data ss:Type="String">M�dia Peso</Data></Cell>' + CRLF
	cXML += ' 	<Cell ss:Index="2" ss:StyleID="sComDigN" ss:Formula="=AVERAGE(R[-'+cValToChar(nLin+1)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
	cXML += ' </Row>' + CRLF

	cXML += '  </Table> ' + CRLF
	cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel"> ' + CRLF
	cXML += '   <PageSetup> ' + CRLF
	cXML += '    <Header x:Margin="0.31496062000000002"/> ' + CRLF
	cXML += '    <Footer x:Margin="0.31496062000000002"/> ' + CRLF
	cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024" ' + CRLF
	cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/> ' + CRLF
	cXML += '   </PageSetup> ' + CRLF
	cXML += '   <TabColorIndex>13</TabColorIndex> ' + CRLF
	cXML += '   <Selected/> ' + CRLF
	cXML += '   <Panes> ' + CRLF
	cXML += '    <Pane> ' + CRLF
	cXML += '     <Number>3</Number> ' + CRLF
	cXML += '     <ActiveRow>17</ActiveRow> ' + CRLF
	cXML += '     <ActiveCol>9</ActiveCol> ' + CRLF
	cXML += '    </Pane> ' + CRLF
	cXML += '   </Panes> ' + CRLF
	cXML += '   <ProtectObjects>False</ProtectObjects> ' + CRLF
	cXML += '   <ProtectScenarios>False</ProtectScenarios> ' + CRLF
	cXML += '  </WorksheetOptions> ' + CRLF
	cXML += ' </Worksheet> ' + CRLF

	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""

EndIf

Return nil
// fQuadro1

/* MJ : 16.01.2019
	-> Gerar Pr� Notas de Entrada, como complemento;

	-> Inicialmente sera gerado uma tela com informacoes necessarias para a geracao da pr� nota de entrada.
*/
Static Function fGerarCompl()

Local oDlgC		    := nil
Local aSize		    := {}
Local aObjects      := {}
Local aInfo		    := {}
Local aPObjs        := {}
Local nDist 		:= 3
Local nOpcA			:= 0
Local nI			:= 0
Local aField		:= {}
Local aColsEsp := {}, nUsadEsp := 0

Local nContTIK		:= 0, nTotQtdTIK := 0, nI := 0
Local lErro			:= .F.
Local lTemTIK		:= .F.
Local _cDoc			:= ""
Local aButtons		:= {}
Local lContinua		:= .T.
Local nSB1TTComp	:= 0
Local cCodigo		:= ""

// posicao grids
Private aHeadEsp 	:= {}
Private oGDQ2		:= nil
Private nPMrkNFC	:= 0

Private aGets       := {}
Private aTela       := {}

Private nAtZBC		:= &( "o" + cValToChar( oTFoldeG:nOption ) + "ZBCGDad"):oBrowse:nAt
// ==============================================
Private _cPedido    := &( "o" + cPFoBCPed + "ZBCGDad"):aCols[ nAtZBC, nPZBCPed ] // CriaVar('ZBC_PEDIDO', .F.)
Private _cFornec    := M->ZCC_CODFOR+M->ZCC_LOJFOR+"-"+M->ZCC_NOMFOR // Space(20)
Private _cQuaZBC    := 0	// &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nAtZBC, nPZBCQtd ] // CriaVar('ZBC_QUANT' , .F.)
Private _cTotalNeg  := 0 	// Iif( Empty( &( "o" + cPFoBCTNG + "ZBCGDad"):aCols[ nAtZBC, nPZBCTNG ] ), &( "o" + cPFoBCTot + "ZBCGDad"):aCols[ nAtZBC, nPZBCTot ], &( "o" + cPFoBCTNG + "ZBCGDad"):aCols[ nAtZBC, nPZBCTNG ] ) // CriaVar('ZBC_TOTAL' , .F.)
Private _cMENPAD    := Space(3)
Private _cCndPag    := Space(3)
// Private _cTotalNeg     := &( "o" + cPFoBCXTT + "ZBCGDad"):aCols[ nAtZBC, nPZBCXTT ] + ;
Private _cProdut	:= ""
Private _cTpSenar	:= ""
// ==============================================
Private _cQuaNF     := CriaVar('ZBC_QUANT', .F.)
Private _cVlrNF     := CriaVar('ZBC_TOTAL', .F.)
Private _cSohNF     := CriaVar('ZBC_TOTAL', .F.)
Private _cTotNF     := CriaVar('ZBC_TOTAL', .F.)
// ==============================================
Private _TES        := Space(15)
//Private _cMENPAD    := Space(15)
Private _cMENNOTA   := Space(100)
// ==============================================

Private aTitSE2		:= {}

// _cProdut  := AllTrim(oGDQ2:aCols[ 1, nPCodSB1 ]) + "-" + Posicione('SB1', 1, xFilial('SB1')+oGDQ2:aCols[ 1, nPCodSB1 ], 'B1_DESC')
_cTpSenar := &( "o" + cPFoBCTPS + "ZBCGDad"):aCols[ nAtZBC, nPZBCTPS ]
if _cTpSenar=="F"
	_cTpSenar:="Folha"
ElseIf _cTpSenar=="D"
	_cTpSenar:="Desconta"
Else // If _cTpSenar=="V"
	_cTpSenar:="V@ Paga"
EndIf

// _V_A_L_I_D_A_�_�_O_
_cPedido := ""
For nI := 1 to Len(o1ZBCGDad:aCols)
	If o1ZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
		lTemTIK := .T.

		If !Empty(_cPedido) .and. _cPedido <> &( "o" + cPFoBCPed + "ZBCGDad"):aCols[ nI, nPZBCPed ]
			Aviso("Aviso", "N�o � permitido criar complemento para diferentes pedidos. O pedido da linha: " + AllTrim(Str(nI)) +;
			 				", pedido: " + &( "o" + cPFoBCPed + "ZBCGDad"):aCols[ nI, nPZBCPed ] + ;
			 				", difere do pedido: " + _cPedido + ". Esta Opera��o sera cancelada.", {"Sair"} )
			lContinua := .F.
			Exit

		Else

			_cPedido := &( "o" + cPFoBCPed + "ZBCGDad"):aCols[ nI, nPZBCPed ]

			If Empty( &( "o" + cPFoBCTNG + "ZBCGDad"):aCols[ nI, nPZBCTNG ] )

				Aviso("Aviso", "Dados da negocia��o final n�o foram preenchidos na linha: " + AllTrim(Str(nI)) +;
			 				", pedido: " + &( "o" + cPFoBCPed + "ZBCGDad"):aCols[ nI, nPZBCPed ] + ;
			 				". Esta Opera��o sera cancelada.", {"Sair"} )
				lContinua := .F.
				Exit

			Else

				_cDoc := Posicione('SD1', 22, xFilial('SD1')+;
											&( "o" + cPFoBCPed + "ZBCGDad"):aCols[ nI /*nAtZBC*/, nPZBCPed ]+;
											&( "o" + cPFoBCPIt + "ZBCGDad"):aCols[ nI /*nAtZBC*/, nPZBCPIt ], 'D1_DOC' )
				If Empty(_cPedido) .or. Empty( _cDoc )
					Aviso("Aviso", ;
							'N�o � possivel gerar complemento para este item. Nota Fiscal n�o localizada.' + CRLF + 'Este processo sera cancelado. ', ;
							  {"Sair"} )
					lContinua := .F.  // Return nil
					Exit
					// Else
					// 	MsgInfo('NF: ' + SD1->D1_FILIAL + '-' + SD1->D1_DOC + '-' + SD1->D1_SERIE )
				EndIf

				// _T_O_T_A_L_I_Z_A_D_O_R_E_S_
				_cQuaZBC  += &( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nI, nPZBCQtd ]
				_cTotalNeg+= Iif( Empty( &( "o" + cPFoBCTNG + "ZBCGDad"):aCols[ nI, nPZBCTNG ] ), ;
											&( "o" + cPFoBCTot + "ZBCGDad"):aCols[ nI, nPZBCTot ], ;
									&( "o" + cPFoBCTNG + "ZBCGDad"):aCols[ nI, nPZBCTNG ] )
				_cProdut += iIf(Empty(_cProdut),"",",") + &( "o" + cPFoBCPRD + "ZBCGDad"):aCols[ nI, nPZBCPRD ]
			EndIf
		EndIf
	EndIf
Next nI
If !lContinua // nI <= Len(o1ZBCGDad:aCols)
	return nil
EndIf

// Validar se Tem algum item Tikado;
If !lTemTIK
	Aviso("Aviso", "N�o foi localizado nenhum pedido marcado para complemento.", {"Sair"} )
	Return nil
EndIf

aSize := MsAdvSize( .T. )
For nI := 1 to Len(aSize)
	aSize[nI] := Iif( aSize[nI]==0, 0, aSize[nI]*0.75)
Next nI

AAdd( aObjects, { 100 , 070, .T. , .T. , .F. } )
AAdd( aObjects, { 100 , 100, .T. , .T. , .F. } )
AAdd( aObjects, { 100 , 060, .T. , .T. , .F. } )
aInfo  := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
aPObjs := MsObjSize(aInfo, aObjects, .T., .F.)

DEFINE MSDIALOG oDlgC TITLE OemToAnsi("Gera��o da Pr� Nota de Entrada") From 0,0 to aSize[6],aSize[5] PIXEL // STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )  // tirar o X da tela | tirar o botao X da tela |
// oDlgC:lMaximized := .T.

// ================================================================================================================
oGrpQ1 := TGroup():New( aPObjs[1,1]+nDist*3+nDist, aPObjs[1,2]+nDist, aPObjs[1,3]-nDist, aPObjs[1,4]-nDist,;
						  "Dados da Negocia��o", oDlgC,,, .T.,)
//                   Titulo,       Campo, Tipo,                 Tamanho,                 Decimal,                          Pict,                     Valid, Obrigat, Nivel, Inic Padr, F3,   When, Visual, Chave, CBox, Folder, N Alteravel, PictVar, Gatilho
aAdd(aField, { "Pedido"    , "_cPedido"  ,  "C", TamSX3("ZBC_PEDIDO")[1], TamSX3("ZBC_PEDIDO")[2], PesqPict("ZBC", "ZBC_PEDIDO"), /* { || U_Vd1MNT01() } */,     .F.,     1,        "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
aAdd(aField, { "Fornecedor", "_cFornec"  ,  "C",                      20,                       0,                          "@!", /* { || U_Vd1MNT01() } */,     .F.,     1,        "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
aAdd(aField, { "Quant."	   , "_cQuaZBC"  ,  "N", TamSX3("ZBC_QUANT" )[1], TamSX3("ZBC_QUANT")[2] , PesqPict("ZBC", "ZBC_QUANT" ), /* { || VldCpo(2) }    */,     .F.,     1,        "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
aAdd(aField, { "R$ Negoc." , "_cTotalNeg",  "N", TamSX3("D1_TOTAL" )[1] , TamSX3("D1_TOTAL")[2]  , PesqPict("SD1", "D1_TOTAL" ) , /* { || VldCpo(2) }    */,     .F.,     1,        "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
aAdd(aField, { "Tipo Senar", "_cTpSenar" ,  "C",                      08,                       0,                          "@!", /* { || U_Vd1MNT01() } */,     .F.,     1,        "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )

aAdd(aField, { "Msg Padrao"  , "_cMENPAD"  ,  "C",                      03,                       0,                          "@!", /* { || U_Vd1MNT01() } */,     .F.,     1,        "", "SM4", "" ,    .F.,   .F.,   "",      1,         .F.,      "",      "N"} )
aAdd(aField, { "Condi��o Pag", "_cCndPag"  ,  "C",                      03,                       0,                          "@!", { || ExistCpo("SE4") },     .F.,     1,        "", "SE4", "" ,    .F.,   .F.,   "",      1,         .F.,      "",      "N"} )
								// aTitSE2

oMGetQ1 := MsMGet():New(,, 3/* nOpc */,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,{0,0,0,0}/* aPObjs[1] */,/*aAlterEnch*/,/*nModelo*/,;
						/*nColMens*/,/*cMensagem*/, /*cTudoOk*/, oGrpQ1,/*lF3*/,/*lMemoria*/, .F. /*lColumn*/,;
						nil /*caTela*/,/*lNoFolder*/, .T. /*lProperty*/,aField,/* aFolder */,/*lCreate*/,/*lNoMDIStretch*/,;
						/*cTela*/)
oMGetQ1:oBox:Align := CONTROL_ALIGN_ALLCLIENT

// ================================================================================================================
oGrpQ3 := TGroup():New( aPObjs[2,3]+nDist, aPObjs[3,2]+nDist, aPObjs[3,3]-nDist, aPObjs[3,4]-nDist,;
						  "Valor Final da Nota Fiscal", oDlgC,,, .T.,)
aField := {}
//                       Titulo,     Campo, Tipo,                Tamanho,                Decimal,                          Pict,                         Valid, Obrigat, Nivel, Inic Padr, F3,   When, Visual, Chave, CBox, Folder, N Alteravel, PictVar, Gatilho
aAdd(aField, { "Quant. NF"     , "_cQuaNF",  "N", TamSX3("ZBC_QUANT")[1], TamSX3("ZBC_QUANT")[2], PesqPict("ZBC", "ZBC_QUANT" ), /* { || VldCpo(2) }    */ ,     .F.,     1,        "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
aAdd(aField, { "R$ NF Total"   , "_cVlrNF",  "N", TamSX3("ZBC_TOTAL")[1], TamSX3("ZBC_TOTAL")[2], PesqPict("ZBC", "ZBC_TOTAL" ), /* { || VldCpo(2) }    */ ,     .F.,     1,        "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )
aAdd(aField, { "Total Compl NF", "_cTotNF",  "N", TamSX3("ZBC_TOTAL")[1], TamSX3("ZBC_TOTAL")[2], PesqPict("ZBC", "ZBC_TOTAL" ), /* { || VldCpo(2) }    */ ,     .F.,     1,        "", ""   , "" ,    .T.,   .F.,   "",      1,         .F.,      "",      "N"} )

oMGetQ3 := MsMGet():New(,, 3/* nOpc */,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,{0,0,0,0}/* aPObjs[1] */,/*aAlterEnch*/,/*nModelo*/,;
						/*nColMens*/,/*cMensagem*/, /*cTudoOk*/, oGrpQ3,/*lF3*/,/*lMemoria*/, .F. /*lColumn*/,;
						nil /*caTela*/,/*lNoFolder*/, .T. /*lProperty*/,aField,/* aFolder */,/*lCreate*/,/*lNoMDIStretch*/,;
						/*cTela*/)
oMGetQ3:oBox:Align := CONTROL_ALIGN_ALLCLIENT
// ================================================================================================================

_cTotNF := 0
// _cTotNF := _cTotalNeg // - _cVlrNF
// Desenhando todos os quadros e somando os campos
For nI := 1 to Len(oGDQ2:aCols)
	// If Empty( oGDQ2:aCols[ nI, nPMrkNFC] )
		oGDQ2:aCols[ nI, nPMrkNFC] := "LBNO"
	// EndIf

	// Colocar Descricao do BOV
	_cCodBOV := AllTrim( oGDQ2:aCols[ nI, nPCodSB1 ] )
	oGDQ2:aCols[ nI, nPCodSB1 ] := AllTrim(_cCodBOV) + "-" + Posicione('SB1', 1, xFilial('SB1')+_cCodBOV, 'B1_DESC')

	// _P_R_E_E_N_C_H_E_R_
	If AllTrim( oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="TIPO" } ) ] ) == '1-NF ENTRADA'
		_cQuaNF += oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="QUANT" } ) ] // D1_QUANT
		// _cVlrNF += oGDQ2:aCols[ nI, 12 ] // VLR_S_ICMS // Luana no dia 28.03.19-> pediu para nao incluir o ICMS
		_cVlrNF += oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="D1_TOTAL" } ) ] // R$ NF

		//	nSB1TTComp := 0
		//	For nJ := 1 to Len(oGDQ2:aCols)
		//
		//		If AllTrim( oGDQ2:aCols[ nJ, aScan( aHeadEsp, { |x|x[2]=="TIPO" } ) ] ) <> '1-NF ENTRADA' .or. ;
		//			AllTrim(_cCodBOV) <> SubStr(oGDQ2:aCols[ nJ, nPCodSB1 ], 1, Len(_cCodBOV))
		//			Loop
		//		EndIf
		//
		//	 	nSB1TTComp += oGDQ2:aCols[ nJ, aScan( aHeadEsp, { |x|x[2]=="D1_TOTAL" } ) ]
		//	Next nJ

		nPos 	 := aScan( &( "o" + cPFoBCPRD + "ZBCGDad"):aCols, { |x| AllTrim(x[nPZBCPRD])== AllTrim(_cCodBOV)} )
		_nVlrNeg := Iif( Empty( &( "o" + cPFoBCTNG + "ZBCGDad"):aCols[ nPos, nPZBCTNG ] ), ;
											&( "o" + cPFoBCTot + "ZBCGDad"):aCols[ nPos, nPZBCTot ], ;
									&( "o" + cPFoBCTNG + "ZBCGDad"):aCols[ nPos, nPZBCTNG ] )

		// Tot Neg Contrato
		oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="TotNegZBC" } ) ] := _nVlrNeg

		_cTotNF += oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="VlrCompl" } ) ]

		// oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="VlrCompl" } ) ] := ; /*oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="D1_TOTAL" } ) ]*/
		// 																	nSB1TTComp - _nVlrNeg

	EndIf

	//	If AllTrim( oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="TIPO" } ) ] ) == '1-NF ENTRADA' ;
	//		.AND. &( "o" + cPFoBCTPS + "ZBCGDad"):aCols[ nAtZBC, nPZBCTPS ] == "V"
	//		_cSohNF += oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="D1_TOTAL" } ) ]
	//	EndIf
Next nI

// Calcular Senar no complemento
// If &( "o" + cPFoBCTPS + "ZBCGDad"):aCols[ nAtZBC, nPZBCTPS ] == "V"
//	_cTotNF := _cTotalNeg - _cVlrNF +( _cSohNF / ((100-&( "o" + cPFoBCAQS + "ZBCGDad"):aCols[ nAtZBC, nPZBCAQS ])/100) )
//Else
// 	_cTotNF := _cTotalNeg - _cVlrNF
//EndIf

AAdd( aButtons, { "AUTOM", { || fTitPagar() }, "Alterar Vencimentos (F11)" } )
Set Key VK_F11 To fTitPagar()

ACTIVATE MSDIALOG oDlgC ;
          ON INIT EnchoiceBar(oDlgC,;
                              { || nOpcA := 1, Iif( VldOkNFE() .and. Obrigatorio(aGets, aTela),;
														oDlgC:End(),;
														nOpcA := 0)},;
                              { || nOpcA := 0, oDlgC:End() },, aButtons )
If nOpcA == 1

	For nI := 1 to Len(oGDQ2:aCols)
		If oGDQ2:aCols[ nI, nPMrkNFC] == 'LBTIK'
			nContTIK   += 1
			// nTotQtdTIK += oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="QUANT" } ) ] // D1_QUANT
		EndIf
	Next nI

	If nContTIK == 0
		MsgInfo("N�o foi selecionada nenhuma Nota Fiscal de Entrada.", "Aviso")
	Else

		lErro := ExecAutoCompl(@cCodigo)
		If !lErro
			// Atualizar contador na SX5
			cUpd := " UPDATE " + RetSqlName('SX5') + CRLF
			cUpd += " 	SET X5_DESCRI ='"+cCodigo+"', " + CRLF
			cUpd += " 		X5_DESCSPA='"+cCodigo+"', " + CRLF
			cUpd += " 		X5_DESCENG='"+cCodigo+"'" + CRLF
			cUpd += " WHERE X5_FILIAL='"+ M->ZCC_FILIAL +"'" + CRLF
			cUpd += "   AND X5_TABELA='01'" + CRLF
			cUpd += "   AND X5_CHAVE='2'" + CRLF
			cUpd += "   AND D_E_L_E_T_=' '" + CRLF

			if (TCSqlExec(cUpd) < 0)
				conout("TCSQLError() " + TCSQLError())
			//else
				// MsgInfo("Codigo de chave atualizado com sucesso! ", "Aviso")
			EndIf
		EndIf
	EndIf

Else
	Alert('A Gera��o da Nota Complementar de Entrada ser� cancelada.')
EndIf

// Voltar Atalho, pois esta sendo finalizado a tela;
Set Key VK_F11 To fGerarCompl()
Return nil

/* MJ : 25.01.2019
	-> Pode salvar  - gerar pedido ????*/
Static Function VldOkNFE()
Local lRet	:= .T.
Local nI	:= 0
	For nI := 1 to Len(oGDQ2:aCols)
		If oGDQ2:aCols[ nI, nPMrkNFC] == 'LBTIK'
			If Empty( oGDQ2:aCols[ nI, aScan( oGDQ2:aHeader, { |x|x[2]=="_TES" } ) ] )
				MsgInfo("TES nao preenchida na linha: " + cValToChar(nI), "Aviso")
				lRet := .F.
				exit
			EndIf
		EndIf
	Next nI

	If lRet
		If (_cTotNF + _cVlrNF) > _cTotalNeg
			lRet := MsgYesNo("O valor Informado para nota complementar: ["+AllTrim(Transform(_cTotNF+_cVlrNF,X3Picture("D1_TOTAL")))+"] ultrapassa o configurado no contrato: ["+AllTrim(Transform(_cTotalNeg,X3Picture("D1_TOTAL")))+"]."+CRLF+"Deseja continuar ?")
		EndIf
	EndIf
Return lRet


/* MJ : 23.04.2019 */
Static Function fTitPagar()

Local nGDOpc        := GD_UPDATE // GD_INSERT + GD_DELETE
Local oDlgSE2		:= nil
Local nOpcA			:= 0
Local oGrp			:= nil, oGdDad := nil

Local _aHead 		:= {}
Local _aCols 		:= {}
Local VlrTotal		:= 0
Local lModif		:= .F.
Local nI := 0
Private aGets		:= {}
Private aTela		:= {}

DEFINE MSDIALOG oDlgSE2 TITLE OemToAnsi("Titulos a Pagar") From 0,0 to 250, 350 PIXEL // STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )  // tirar o X da tela | tirar o botao X da tela |

For nI := 1 to Len(oGDQ2:aCols)
	If oGDQ2:aCols[ nI, nPMrkNFC] == 'LBTIK'
		VlrTotal += oGDQ2:aCols[ nI, aScan( aHeadEsp, { |x|x[2]=="VlrCompl" } ) ]
	EndIf
Next nI

If Empty( VlrTotal )
	MsgInfo( "Valor a complementar n�o localizado, ou nao foi informado, ou nenhuma NF Entrada foi selecionada." + CRLF + ;
			 "Esta Opera��o ser� cancelada.", "Aviso" )
	Return nil
ElseIf Empty( _cCndPag )
	MsgInfo( "Condi��o de pagamento nao informada nas tela anterior." + CRLF + ;
			 "Esta Opera��o ser� cancelada.", "Aviso" )
	Return nil
EndIf

aAdd(_aHead,{ "Parcela"   , "E2_PARCELA", PesqPict("SE2", "E2_PARCELA"), TamSX3("E2_PARCELA")[1], TamSX3("E2_PARCELA")[2], "AllwaysTrue()", "" , "C", "", "R","","","","V","","",""})
aAdd(_aHead,{ "Valor Tit.", "E2_VALOR"  , PesqPict("SE2", "E2_VALOR")  , TamSX3("E2_VALOR" )[1] , TamSX3("E2_VALOR")[2]  , "AllwaysTrue()", "" , "N", "", "R","","","","V","","",""})
aAdd(_aHead,{ "Vencimento", "E2_VENCREA", "@!"                         , 10                     , 0                      , "AllwaysTrue()", "" , "D", "", "R","","","","A","","",""})

aTitSE2 := Condicao( VlrTotal, _cCndPag )

// Carregar vetor
_aCols := {}
For nI := 1 to Len(aTitSE2)
	aAdd( _aCols , { StrZero( nI, 2), aTitSE2[nI, 2], aTitSE2[nI, 1], .F. } )
Next nI

oGrp := TGroup():New( 0, 0, 0, 0, "Parcelas", oDlgSE2,,, .T.,)
oGrp:Align   := CONTROL_ALIGN_ALLCLIENT
oGdDad:= MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , /* "+ZPE_ITEM" */, , , 99, , , /* "u_ZPEDelOk()" */, oGrp, ;
									aClone(_aHead), aClone( _aCols ) )
oGdDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlgSE2 ;
          ON INIT EnchoiceBar(oDlgSE2,;
                              { || nOpcA := 1, Iif( /* VldOkNFE() .and. */Obrigatorio(aGets, aTela),;
														oDlgSE2:End(),;
														nOpcA := 0)},;
                              { || nOpcA := 0, oDlgSE2:End() },, /* aButtons */ )
If nOpcA == 1

	If lModif := oGdDad:lModified
		For nI:=1 to Len( oGdDad:aCols )
			if lModif := oGdDad:aCols[nI, 3] <> _aCols[nI, 3]
				Exit
			EndIf
		Next nI
	EndIf

	If lModif
		// Alert('Foi Modificado')
		aTitSE2 := oGdDad:aCols
	Else
		// Alert('N�O Modificado')
		aTitSE2 := {}
	EndIf

EndIf

Return nil


/* MJ : 23.01.2019
	-> Criar Pr� Nota de Entrada;
*/
// Static Function ExecAutoCompl(nI, cCodigo, nTotQtdTIK)
Static Function ExecAutoCompl(cCodigo)
Local aArea			:= GetArea()
Local aAreaSF1		:= SF1->(GetArea())
Local aAreaSE2		:= SE2->(GetArea())
Local nOpc 			:= 3
Local nI            := 0

Local aCabec      	:= {}
Local aItens      	:= {}
Local aLinha      	:= {}
LocaL _cMSG			:= ""

Private lMsHelpAuto := .F.
Private lMsErroAuto := .F.

BeginSQL alias "TMP"
	%noParser%
	SELECT X5_DESCRI
	FROM %table:SX5% SX5
	WHERE X5_FILIAL		= %exp:M->ZCC_FILIAL%
	  AND X5_TABELA		= '01'
	  AND X5_CHAVE		= '2'
	  AND SX5.%NotDel%
EndSQL

If !TMP->(Eof())
	cCodigo := TMP->X5_DESCRI
EndIf
TMP->( DbCloseArea() )

aAdd( aCabec, { 'F1_TIPO'		, 'C'								 , Nil } ) // C = COMPLEMENTO
aAdd( aCabec, { 'F1_TPCOMPL'	, '1'								 , Nil } ) // 1 = PRECO
aAdd( aCabec, { 'F1_FORMUL'		, 'S'								 , Nil } )
aAdd( aCabec, { 'F1_DOC'		, cCodigo							 , Nil } )
aAdd( aCabec, { "F1_SERIE"		, "2"								 , Nil } ) // PARA COMPLEMENTO DE PRECO = SERIE 2
aAdd( aCabec, { "F1_EMISSAO"	, dDataBase							 , Nil } )
aAdd( aCabec, { "F1_X_DTINC"	, dDataBase							 , Nil } )
aAdd( aCabec, { 'F1_FORNECE'	, M->ZCC_CODFOR						 , Nil } )
aAdd( aCabec, { 'F1_LOJA'		, M->ZCC_LOJFOR						 , Nil } )
aAdd( aCabec, { "F1_ESPECIE"	, "SPED"							 , Nil } )
aAdd( aCabec, { "F1_STATUS"		, 'A'								 , Nil } )
// aAdd( aCabec, { "F1_MENPAD"		, SubS(oGDQ2:aCols[ 1, aScan( oGDQ2:aHeader, { |x|x[2]=="_cMENPAD" } ) ],1,3)	 , Nil } )
// aAdd( aCabec, { "F1_COND"		, '001'								 , Nil } )
aAdd( aCabec, { "F1_MENPAD"		, _cMENPAD 							 , Nil } )
aAdd( aCabec, { "F1_COND"		, _cCndPag							 , Nil } )

For nI := 1 to Len(oGDQ2:aCols)
	If oGDQ2:aCols[ nI, nPMrkNFC] == 'LBTIK'

		_cMSG += Iif(Empty(_cMSG),"",CRLF) + AllTrim(oGDQ2:aCols[ nI, aScan( oGDQ2:aHeader, { |x|x[2]=="_cMENNOTA" } ) ])

		aLinha := {}
		aAdd( aLinha, { 'D1_COD'	 , SubS(oGDQ2:aCols[ nI, aScan( oGDQ2:aHeader, { |x|x[2]=="D1_COD" } ) ],1,15)	     , Nil } ) // aAdd( aItens, { "D1_QUANT"		, 1				, Nil } )
		aAdd( aLinha, { "D1_VUNIT"	 , oGDQ2:aCols[ nI, aScan( oGDQ2:aHeader, { |x|x[2]=="VlrCompl" } ) ]     , Nil } )
		aAdd( aLinha, { "D1_TOTAL"	 , oGDQ2:aCols[ nI, aScan( oGDQ2:aHeader, { |x|x[2]=="VlrCompl" } ) ]     , Nil } )
		aAdd( aLinha, { "D1_TES"	 , SubS(oGDQ2:aCols[ nI, aScan( oGDQ2:aHeader, { |x|x[2]=="_TES" } ) ],1,3), Nil } )
		aAdd( aLinha, { "D1_NFORI"	 , oGDQ2:aCols[ nI, aScan( oGDQ2:aHeader, { |x|x[2]=="D1_DOC" } ) ]       , Nil } ) // 000005890
		aAdd( aLinha, { "D1_SERIORI" , oGDQ2:aCols[ nI, aScan( oGDQ2:aHeader, { |x|x[2]=="D1_SERIE" } ) ]     , Nil } ) // 2
		aAdd( aLinha, { "D1_ITEMORI" , oGDQ2:aCols[ nI, aScan( oGDQ2:aHeader, { |x|x[2]=="D1_ITEM" } ) ]      , Nil } ) // 0001

		aAdd(aItens,aLinha)
	EndIf
Next nI
aAdd( aCabec, { "F1_MENNOTA"	, _cMSG			 , Nil } )


// MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)}, aCabec, aLinha, nOpc,,)
	MsgRun("Aguarde, gerando Pr�-Nota de Entrada..." + AllTrim(cCodigo),, ;
			{|| MSExecAuto ( {|x,y,z| MATA103(x,y,z) }, aCabec, aItens, nOpc )})

If lMsErroAuto
	MostraErro()
	DisarmTransaction()
Else
	// MsgInfo("Cria��o da NF de Complemento: " + AllTrim(cCodigo) + CRLF + "Gerada com sucesso!", "Aviso")
	cCodigo := Soma1(AllTrim(cCodigo))
EndIf


RestArea(aAreaSE2)
RestArea(aAreaSF1)
RestArea(aArea)
Return lMsErroAuto


/* MJ : 24.01.2019 */
Static Function fCanSelNFC()
Local lRet	:= .T.
Local nAt 	:= oGDQ2:oBrowse:nAt
	If AllTrim( oGDQ2:aCols[ nAt, 02 ] ) <> '1-NF ENTRADA'
		lRet := .F.
		Alert("Somente Notas Fiscais de entrada podem ser selecionada")
	EndIf
Return lRet


/* MJ : 18.01.2019
	-> Processamento/Carregamento da NewGetDados;

	ex: LoadNewGDados("NFEntrada", aHeadEsp, @aColsEsp, nUsadEsp)
	*/
Static Function LoadNewGDados(cTipo, aHeadEsp, aColsEsp, nUsadEsp, _cProdut )
Local cSql			:= ""
Local nX			:= 0

Default _cProdut	:= ""

If cTipo == "NFEntrada"

	cSql := " WITH ENTRADA AS ( " + CRLF
	cSql += " 		SELECT '1-NF ENTRADA' AS TIPO, " + RetSQLName('SD1') + ".R_E_C_N_O_, D1_FILIAL+D1_DOC+D1_SERIE NOTA_FISCAL, D1_FORNECE+D1_LOJA COD_FORNECE, RTRIM(" + RetSQLName('SA2') + ".A2_NOME) A2_NOME, D1_EMISSAO, D1_COD, D1_UM, D1_QUANT, D1_VUNIT, D1_TOTAL, D1_VALICM, D1_CF, D1_X_KM, D1_X_PESCH, D1_X_EMBDT, D1_X_EMBHR, D1_X_CHEDT, D1_X_CHEHR" + CRLF
	cSql += " 		  FROM " + RetSQLName('SD1') + "" + CRLF
	cSql += " 		  JOIN " + RetSQLName('SA2') + " ON " + CRLF
	cSql += " 			   D1_FORNECE = A2_COD " + CRLF
	cSql += " 		   AND D1_LOJA = A2_LOJA " + CRLF
	cSql += " 		   AND " + RetSQLName('SA2') + ".D_E_L_E_T_ = ' '" + CRLF
	cSql += " 		  WHERE D1_QUANT > 0" + CRLF
	cSql += " 				AND " + RetSQLName('SD1') + ".D_E_L_E_T_ = ' '" + CRLF
	cSql += " 				AND D1_TIPO = 'N' " + CRLF
	cSql += " 		        AND D1_FILIAL+RTRIM(D1_COD)+D1_FORNECE+D1_LOJA+D1_PEDIDO IN" + CRLF
	cSql += " 					(" + CRLF
	cSql += " 						SELECT DISTINCT ZBC_FILIAL+RTRIM(ZBC_PRODUT)+ZBC_CODFOR+ZBC_LOJFOR+ZBC_PEDIDO" + CRLF
	cSql += " 						  FROM " + RetSQLName('ZBC') + "" + CRLF
	cSql += " 						 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "'" + CRLF
	cSql += " 						   AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
	cSql += " 					) " + CRLF
	cSql += " 		), " + CRLF
	cSql += " COMPLEMENTO AS ( " + CRLF
	cSql += " 		SELECT '2-NF COMPLEMENTO' AS TIPO, D.R_E_C_N_O_, D1_FILIAL+D1_DOC+D1_SERIE NOTA_FISCAL, D1_FORNECE+D1_LOJA COD_FORNECE, RTRIM(" + RetSQLName('SA2') + ".A2_NOME) A2_NOME, D.D1_EMISSAO, D.D1_COD, D.D1_UM, D.D1_QUANT, D.D1_VUNIT, D.D1_TOTAL, D.D1_VALICM, D.D1_CF, D.D1_X_KM, D.D1_X_PESCH, D.D1_X_EMBDT, D.D1_X_EMBHR, D.D1_X_CHEDT, D.D1_X_CHEHR " + CRLF
	cSql += "  FROM SF1010 F" + CRLF
	cSql += " 	  JOIN " + RetSQLName('SD1') + " D	 ON F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_FORNECE=D1_FORNECE " + CRLF
	cSql += " 							AND F1_LOJA=D1_LOJA AND F.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' '" + CRLF
 	cSql += " 	  JOIN " + RetSQLName('SA2') + "	 ON A2_FILIAL=' ' AND D.D1_FORNECE = A2_COD AND D.D1_LOJA = A2_LOJA AND " + RetSQLName('SA2') + ".D_E_L_E_T_ = ' '  " + CRLF
 	cSql += " 	  JOIN ENTRADA E ON E.D1_COD = D.D1_COD " + CRLF
 	cSql += " 	 WHERE F.F1_TIPO = 'C'" + CRLF
	cSql += " 	   AND F.F1_TPCOMPL='1'" + CRLF
	cSql += " 	   AND D.D1_QUANT = 0  " + CRLF
	cSql += "    	      AND D.D1_FILIAL+RTRIM(D.D1_COD)+D.D1_FORNECE+D.D1_LOJA IN" + CRLF
	cSql += "    				(" + CRLF
	cSql += "    					SELECT DISTINCT ZBC_FILIAL+RTRIM(ZBC_PRODUT)+ZBC_CODFOR+ZBC_LOJFOR" + CRLF
	cSql += "    					  FROM " + RetSQLName('ZBC') + "" + CRLF
	cSql += "    					 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "'" + CRLF
	cSql += "    					   AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
	cSql += " 				) " + CRLF
	cSql += " 		), " + CRLF
	cSql += " FRETE AS ( " + CRLF
	cSql += " 		SELECT '3-NF FRETE' AS TIPO, D.R_E_C_N_O_, D1_FILIAL+D1_DOC+D1_SERIE NOTA_FISCAL, D1_FORNECE+D1_LOJA COD_FORNECE, RTRIM(" + RetSQLName('SA2') + ".A2_NOME) A2_NOME, D.D1_EMISSAO, D.D1_COD, D.D1_UM, D.D1_QUANT, D.D1_VUNIT, D.D1_TOTAL, D.D1_VALICM, D.D1_CF, D.D1_X_KM, D.D1_X_PESCH, D.D1_X_EMBDT, D.D1_X_EMBHR, D.D1_X_CHEDT, D.D1_X_CHEHR  " + CRLF
	cSql += "  FROM SF1010 F" + CRLF
	cSql += " 	  JOIN " + RetSQLName('SD1') + " D	 ON F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_FORNECE=D1_FORNECE " + CRLF
	cSql += " 							AND F1_LOJA=D1_LOJA AND F.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' '" + CRLF
 	cSql += " 	  JOIN " + RetSQLName('SA2') + "	 ON A2_FILIAL=' ' AND D.D1_FORNECE = A2_COD AND D.D1_LOJA = A2_LOJA AND " + RetSQLName('SA2') + ".D_E_L_E_T_ = ' '  " + CRLF
 	cSql += " 	  JOIN ENTRADA E ON E.D1_COD = D.D1_COD " + CRLF
 	// cSql += " 	   -- AND E.COD_FORNECE <> F.D1_FORNECE+F.D1_LOJA
 	cSql += " 	 WHERE F.F1_TIPO = 'C'" + CRLF
	cSql += " 	   AND F.F1_TPCOMPL='3'" + CRLF
	cSql += " 	   AND D.D1_QUANT = 0  " + CRLF
 	cSql += " 	   AND D.D1_FILIAL+RTRIM(D.D1_COD) IN (" + CRLF
	cSql += " 				SELECT DISTINCT ZBC_FILIAL+RTRIM(ZBC_PRODUT) " + CRLF
	cSql += " 				  FROM " + RetSQLName('ZBC') + "" + CRLF
	cSql += " 				 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "'" + CRLF
	cSql += " 				   AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
	cSql += " 				) " + CRLF
	cSql += " 		) " + CRLF
	cSql += "" + CRLF
	cSql += " SELECT * FROM ENTRADA " + CRLF
	cSql += " UNION " + CRLF
	cSql += " SELECT * FROM COMPLEMENTO " + CRLF
	cSql += " UNION " + CRLF
	cSql += " SELECT * FROM FRETE " + CRLF
	cSql += "" + CRLF
	cSql += " ORDER BY TIPO, D1_COD, D1_EMISSAO, 2" + CRLF

ElseIf cTipo == "oGetF3aQ2"

	cSql := " SELECT E2_FORNECE+E2_LOJA+' - '+E2_NOMFOR FORNECEDOR,E2_NUM, E2_TIPO, E2_PREFIXO, E2_PARCELA, E2_EMISSAO, E2_VENCREA, E2_VALOR, E2_SALDO, E2_HIST, RTRIM(E2_NATUREZ)+' - '+ED.ED_DESCRIC NATUREZA, E2.R_E_C_N_O_ " + CRLF
	cSql += " FROM " + RetSQLName('SE2') + " E2 " + CRLF
	cSql += " JOIN " + RetSQLName('SED') + " ED ON " + CRLF
	cSql += " 	 ED_FILIAL = ' '" + CRLF
	cSql += "  AND ED_CODIGO = E2_NATUREZ" + CRLF
	cSql += "  AND ED.D_E_L_E_T_ = ' '" + CRLF
	cSql += "   WHERE ( " + CRLF
	cSql += " 	  E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
	cSql += " 		  						    SELECT DISTINCT ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_CODIGO)" + CRLF
	cSql += " 		  						      FROM " + RetSQLName('ZBC') + "" + CRLF
	cSql += " 		  							 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "' " + CRLF
	cSql += " 									   AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
	cSql += " 									) " + CRLF
	cSql += " 	 OR " + CRLF
	cSql += " 	 E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
	cSql += " 		  						    SELECT DISTINCT ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_PEDIDO)" + CRLF
	cSql += " 		  						      FROM " + RetSQLName('ZBC') + "" + CRLF
	cSql += " 		  							 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "' " + CRLF
	cSql += " 									   AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
	cSql += " 									) " + CRLF
	cSql += " 	OR " + CRLF
	cSql += " 	E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
	cSql += " 								  SELECT D1_FORNECE+D1_LOJA+RTRIM(D1_DOC)" + CRLF
	cSql += " 								    FROM " + RetSQLName('SD1') + "" + CRLF
	cSql += " 									WHERE D1_FORNECE+D1_LOJA+D1_PEDIDO  IN ( " + CRLF
	cSql += " 																		 SELECT DISTINCT ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_PEDIDO)" + CRLF
	cSql += " 		  																   FROM " + RetSQLName('ZBC') + "" + CRLF
	cSql += " 		  																  WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "'" + CRLF
	cSql += " 																		    AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
	cSql += " 																		  ) " + CRLF
	cSql += " 								 " + CRLF
	cSql += " 								) " + CRLF
	cSql += " 	OR " + CRLF
	cSql += " 	E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
	cSql += " 								  SELECT D1_FORNECE+D1_LOJA+RTRIM(D1_DOC)" + CRLF
	cSql += " 								    FROM " + RetSQLName('SD1') + "" + CRLF
	cSql += " 									WHERE D1_FORNECE+D1_LOJA+D1_COD IN ( " + CRLF
	cSql += " 																		 SELECT DISTINCT ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_PRODUT)" + CRLF
	cSql += " 		  																   FROM " + RetSQLName('ZBC') + "" + CRLF
	cSql += " 		  																  WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "'" + CRLF
	cSql += " 																		    AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
	cSql += " 																		  ) " + CRLF
	cSql += " 								 " + CRLF
	cSql += " 								) " + CRLF
	cSql += "" + CRLF
	cSql += " ) " + CRLF
	cSql += " AND E2.D_E_L_E_T_ = ' '" + CRLF
	//cSql += " ORDER BY E2_EMISSAO, E2_TIPO, E2.R_E_C_N_O_ " + CRLF

ElseIf cTipo == "oGetF3bQ2"

	cSql := " SELECT E5_FILIAL, E5_TIPO, E5_PREFIXO, E5_MOTBX,  E5_NATUREZ, E5_BENEF, E5_HISTOR, E5_VALOR, E5_DOCUMEN, E5_BANCO+ ' - '+E5_AGENCIA+' - '+E5_CONTA BANCO " + CRLF
	cSql += " FROM SE5010 WHERE E5_FILIAL+E5_NUMERO+E5_FORNECE+E5_LOJA IN ( " + CRLF
	cSql += " SELECT E2_FILIAL+E2_NUM+E2_FORNECE+E2_LOJA  -- E2_FORNECE+E2_LOJA+' - '+E2_NOMFOR FORNECEDOR,E2_NUM, E2_TIPO, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_EMISSAO, E2_VENCREA, E2_VALOR, E2_SALDO, E2_HIST, RTRIM(E2_NATUREZ)+' - '+ED.ED_DESCRIC NATUREZA " + CRLF
	cSql += " FROM " + RetSQLName('SE2') + " E2 " + CRLF
	cSql += " JOIN " + RetSQLName('SED') + " ED ON " + CRLF
	cSql += " 	 ED_FILIAL = ' '" + CRLF
	cSql += "  AND ED_CODIGO = E2_NATUREZ" + CRLF
	cSql += "  AND ED.D_E_L_E_T_ = ' '" + CRLF
	cSql += "   WHERE ( " + CRLF
	cSql += " 	  E2_FILIAL+E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
	cSql += " 		  						    SELECT ZBC_FILIAL+ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_CODIGO)" + CRLF
	cSql += " 		  						      FROM " + RetSQLName('ZBC') + "" + CRLF
	cSql += " 		  							 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "' " + CRLF
	cSql += " 									   AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
	cSql += "     								   AND D_E_L_E_T_ = ' '" + CRLF
	cSql += " 									) " + CRLF
	cSql += " 	 OR " + CRLF
	cSql += " 	 E2_FILIAL+E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
	cSql += " 		  						    SELECT ZBC_FILIAL+ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_PEDIDO)" + CRLF
	cSql += " 		  						      FROM " + RetSQLName('ZBC') + "" + CRLF
	cSql += " 		  							 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "' " + CRLF
	cSql += " 									   AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
	cSql += "     								   AND D_E_L_E_T_ = ' '" + CRLF
	cSql += " 									) " + CRLF
	cSql += " 	OR " + CRLF
	cSql += " 	E2_FILIAL+E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
	cSql += " 								  SELECT D1_FILIAL+D1_FORNECE+D1_LOJA+RTRIM(D1_DOC)" + CRLF
	cSql += " 								    FROM " + RetSQLName('SD1') + "" + CRLF
	cSql += " 									WHERE D1_FORNECE+D1_LOJA+D1_PEDIDO  IN ( " + CRLF
	cSql += " 																		 SELECT ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_PEDIDO)" + CRLF
	cSql += " 		  																   FROM " + RetSQLName('ZBC') + "" + CRLF
	cSql += " 		  																  WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "'" + CRLF
	cSql += " 																		    AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
	cSql += "     								   										AND D_E_L_E_T_ = ' '" + CRLF
	cSql += " 																		  ) " + CRLF
	cSql += " 								      AND D_E_L_E_T_ = ' '" + CRLF
	cSql += " 								) " + CRLF
	cSql += "" + CRLF
	cSql += " ) " + CRLF
	cSql += " AND E2.D_E_L_E_T_ = ' '" + CRLF
	cSql += " ) " + CRLF

ElseIf cTipo == "oGetF3Q3"

	cSql := " SELECT E2_FORNECE+E2_LOJA+' - '+E2_NOMFOR FORNECEDOR, E2_PREFIXO, E2_TIPO, SUM(E2_VALOR) E2_VALOR, SUM (E2_SALDO) SALDO, RTRIM(E2_NATUREZ)+' - '+ED.ED_DESCRIC NATUREZA " + CRLF
	cSql += " FROM " + RetSQLName('SE2') + " E2 " + CRLF
	cSql += " JOIN " + RetSQLName('SED') + " ED ON " + CRLF
	cSql += " 	 ED_FILIAL = ' '" + CRLF
	cSql += "  AND ED_CODIGO = E2_NATUREZ" + CRLF
	cSql += "  AND ED.D_E_L_E_T_ = ' '" + CRLF
	cSql += "   WHERE ( " + CRLF
	cSql += " 	  E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
	cSql += " 		  						    SELECT DISTINCT ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_CODIGO)" + CRLF
	cSql += " 		  						      FROM " + RetSQLName('ZBC') + "" + CRLF
	cSql += " 		  							 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "' " + CRLF
	cSql += " 									   AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
	cSql += " 									) " + CRLF
	cSql += " 	 OR " + CRLF
	cSql += " 	 E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
	cSql += " 		  						    SELECT DISTINCT ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_PEDIDO)" + CRLF
	cSql += " 		  						      FROM " + RetSQLName('ZBC') + "" + CRLF
	cSql += " 		  							 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "' " + CRLF
	cSql += " 									   AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
	cSql += " 									) " + CRLF
	cSql += " 	OR " + CRLF
	cSql += " 	E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
	cSql += " 								  SELECT D1_FORNECE+D1_LOJA+RTRIM(D1_DOC)" + CRLF
	cSql += " 								    FROM " + RetSQLName('SD1') + "" + CRLF
	cSql += " 									WHERE D1_FORNECE+D1_LOJA+RTRIM(D1_PEDIDO)  IN ( " + CRLF
	cSql += " 																		 SELECT DISTINCT ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_PEDIDO)" + CRLF
	cSql += " 		  																   FROM " + RetSQLName('ZBC') + "" + CRLF
	cSql += " 		  																  WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "'" + CRLF
	cSql += " 																		    AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
	cSql += " 																		  ) " + CRLF
	cSql += " 								 " + CRLF
	cSql += " 								) " + CRLF
	cSql += " 	OR " + CRLF
	cSql += " 	E2_FORNECE+E2_LOJA+RTRIM(E2_NUM) IN ( " + CRLF
	cSql += " 								  SELECT D1_FORNECE+D1_LOJA+RTRIM(D1_DOC)" + CRLF
	cSql += " 								    FROM " + RetSQLName('SD1') + "" + CRLF
	cSql += " 									WHERE D1_FORNECE+D1_LOJA+RTRIM(D1_COD) IN ( " + CRLF
	cSql += " 																		 SELECT DISTINCT ZBC_CODFOR+ZBC_LOJFOR+RTRIM(ZBC_PRODUT)" + CRLF
	cSql += " 		  																   FROM " + RetSQLName('ZBC') + "" + CRLF
	cSql += " 		  																  WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "'" + CRLF
	cSql += " 																		    AND ZBC_CODIGO = '" + M->ZCC_CODIGO + "' " + CRLF
	cSql += " 																		  ) " + CRLF
	cSql += " 								 " + CRLF
	cSql += " 								) " + CRLF
	cSql += "" + CRLF
	cSql += " ) " + CRLF
	cSql += " AND E2.D_E_L_E_T_ = ' '" + CRLF
	cSql += " GROUP BY E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_PREFIXO, E2_TIPO, E2_NATUREZ, ED_DESCRIC " + CRLF
	//cSql += " ORDER BY E2_PREFIXO " + CRLF

ElseIf cTipo == "oGetF4Q4E"

	cSql := " SELECT B8_PRODUTO, B1_DESC, B8_SALDO, B8_LOTECTL, B8_X_CURRA, B8_XDATACO, B8_XPESOCO " + CRLF
	cSql += " FROM " + RetSQLName('SB8') + " B8 " + CRLF
	cSql += " JOIN " + RetSQLName('SB1') + " B1 ON  B1_FILIAL=' ' AND B8_FILIAL='" + M->ZCC_FILIAL + "' AND B1.B1_COD = B8.B8_PRODUTO AND B1.D_E_L_E_T_ = ' ' AND B8.D_E_L_E_T_ = ' '" + CRLF
	cSql += " WHERE B8_PRODUTO IN ( " + CRLF
	cSql += " 	SELECT DISTINCT ZBC_PRODUT FROM " + RetSQLName('ZBC') + " WHERE ZBC_FILIAL='" + M->ZCC_FILIAL + "' AND ZBC_CODIGO='" + M->ZCC_CODIGO + "' AND D_E_L_E_T_ = ' ' " + CRLF
	cSql += " ) " + CRLF
	cSql += " AND B8_SALDO > 0 " + CRLF

ElseIf cTipo == "oGetF4Q5D"

	cSql := " SELECT D2_COD, B1_DESC, SUM(D2_QUANT) D2_QUANT, D2_LOTECTL, D2_EMISSAO " + CRLF
	cSql += " FROM " + RetSQLName('SD2') + " D2 " + CRLF
	cSql += " JOIN " + RetSQLName('SB1') + " B1 ON B1_FILIAL=' ' AND D2_FILIAL='" + M->ZCC_FILIAL + "' AND B1_COD = D2_COD AND B1.D_E_L_E_T_ = ' ' AND D2.D_E_L_E_T_ = ' ' " + CRLF
	cSql += " WHERE D2_COD IN ( " + CRLF
	cSql += " 	SELECT DISTINCT ZBC_PRODUT FROM " + RetSQLName('ZBC') + " WHERE ZBC_FILIAL='" + M->ZCC_FILIAL + "' AND ZBC_CODIGO='" + M->ZCC_CODIGO + "' AND D_E_L_E_T_ = ' ' " + CRLF
	cSql += " ) " + CRLF
	cSql += " AND D2_QUANT > 0 " + CRLF
	cSql += " GROUP BY D2_EMISSAO, D2_COD, B1_DESC, D2_LOTECTL " + CRLF

ElseIf cTipo == "oGetF4Q2E"

	cSql := " SELECT D3_COD, B1_DESC, D3_QUANT, D3_EMISSAO, D3_OBSERVA, D3_X_OBS, D3_USUARIO " + CRLF
	cSql += "  FROM " + RetSQLName('SD3') + " D3 " + CRLF
	cSql += "  JOIN " + RetSQLName('SB1') + " B1 ON B1_FILIAL=' ' AND D3_FILIAL='" + M->ZCC_FILIAL + "' AND B1_COD = D3_COD AND " + CRLF
	cSql += " 	  B1.D_E_L_E_T_ = ' ' AND" + CRLF
	cSql += " 	  D3.D_E_L_E_T_ = ' ' " + CRLF
	cSql += " WHERE D3_COD IN (" + CRLF
	cSql += " 	SELECT DISTINCT ZBC_PRODUT FROM " + RetSQLName('ZBC') + " WHERE ZBC_FILIAL='" + M->ZCC_FILIAL + "' AND ZBC_CODIGO='" + M->ZCC_CODIGO + "' AND D_E_L_E_T_ = ' ' " + CRLF
	cSql += "   ) " + CRLF
	cSql += "   AND D3_TM = '511' " + CRLF
	cSql += "   AND D3_ESTORNO = ' ' " + CRLF

ElseIf cTipo == "oGetF4Q3D"

	cSql := " SELECT D3_COD, B1_DESC, D3_QUANT, D3_EMISSAO, D3_OBSERVA, D3_X_OBS, D3_USUARIO " + CRLF
	cSql += "  FROM " + RetSQLName('SD3') + " D3 " + CRLF
	cSql += "  JOIN " + RetSQLName('SB1') + " B1 ON B1_FILIAL=' ' AND D3_FILIAL='" + M->ZCC_FILIAL + "' AND B1_COD = D3_COD AND " + CRLF
	cSql += " 	  B1.D_E_L_E_T_ = ' ' AND" + CRLF
	cSql += " 	  D3.D_E_L_E_T_ = ' ' " + CRLF
	cSql += " WHERE D3_COD IN (" + CRLF
	cSql += " 	SELECT DISTINCT ZBC_PRODUT FROM " + RetSQLName('ZBC') + " WHERE ZBC_FILIAL='" + M->ZCC_FILIAL + "' AND ZBC_CODIGO='" + M->ZCC_CODIGO + "' AND D_E_L_E_T_ = ' ' " + CRLF
	cSql += "   ) " + CRLF
	cSql += "   AND D3_TM = '011' " + CRLF
	cSql += "   AND D3_ESTORNO = ' ' " + CRLF

ElseIf cTipo == "oGetF4Q1"

	cSql := " WITH CONTRATO AS" + CRLF
	cSql += " (" + CRLF
	cSql += "       SELECT ZBC_FILIAL					   FILIAL," + CRLF
	cSql += " 			 ZBC_CODIGO						   COD_CONTRATO," + CRLF
	cSql += " 			 ZBC_PEDIDO					       NUMERO_LOTE," + CRLF
	cSql += "			 ZBC_ITEMPC," + CRLF
	cSql += " 			 ZBC_CODFOR					       CODIGO_FORNEC," + CRLF
	cSql += " 			 ZBC_LOJFOR						   LOJA_FORNEC," + CRLF
	cSql += " 			 A2.A2_NOME					       VENDEDOR," + CRLF
	cSql += " 			 A2_MUN						       ORIGEM," + CRLF
	cSql += " 			 A2_EST						       ESTADO," + CRLF
	cSql += " 			 ZBC_X_CORR					       COD_CORRETOR," + CRLF
	cSql += " 			 A3_NOME					       CORRETOR," + CRLF
	cSql += " 			 ZBC_PRODUT					       CODIGO_BOV," + CRLF
	cSql += " 			 ZBC_PRDDES					       DESCRICAO," + CRLF
	cSql += " 			 BC.ZBC_QUANT				       QTD_COMPRA," + CRLF
	cSql += " 			 CASE WHEN BC.ZBC_RACA = 'N' THEN 'NELORE'" + CRLF
	cSql += " 				  WHEN BC.ZBC_RACA = 'A' THEN 'ANGUS'" + CRLF
	cSql += " 				  WHEN BC.ZBC_RACA = 'M' THEN 'MESTICO'" + CRLF
	cSql += " 										 ELSE 'VERIFICAR'" + CRLF
	cSql += " 									     END AS RACA," + CRLF
	cSql += " 			 CASE WHEN BC.ZBC_SEXO = 'M' THEN 'MACHO'" + CRLF
	cSql += " 				  WHEN BC.ZBC_SEXO = 'F' THEN 'FEMEA'" + CRLF
	cSql += " 									     ELSE 'VERIFICAR'" + CRLF
	cSql += " 										 END AS SEXO," + CRLF
	cSql += "			CASE WHEN ZCC_PAGFUT = 'S'   THEN 'SIM'" + CRLF
	cSql += "										 ELSE 'N�O'" + CRLF
	cSql += "										 END AS PGTO_FUTURO," + CRLF
	cSql += " 			 CASE WHEN BC.ZBC_TPNEG	= 'P' THEN 'PESO'" + CRLF
	cSql += " 				  WHEN BC.ZBC_TPNEG	= 'K' THEN 'KG'" + CRLF
	cSql += " 				  WHEN BC.ZBC_TPNEG	= 'Q' THEN 'CABECA'" + CRLF
	cSql += " 										  ELSE 'VERIFICAR'" + CRLF
	cSql += " 									      END AS TIPO_NEGOCIA," + CRLF
	cSql += " 			 CASE WHEN ZBC_PEDPOR = 'P'   THEN 'PAUTA'" + CRLF
	cSql += " 			 							  ELSE 'NEGOCIACAO'" + CRLF
	cSql += " 			 							  END AS PEDIDO_POR," + CRLF
	cSql += " 			 CASE WHEN ZBC_TEMFXA = 'S'   THEN 'SIM'" + CRLF
	cSql += " 			  						      ELSE 'N�O'" + CRLF
	cSql += " 			  						      END AS TEM_FAIXA, ZBC_FAIXA," + CRLF
	cSql += " 			 ZBC_PESO			                PESO_COMPRA," + CRLF
	cSql += " 			 ZBC_ARROV			                VALOR_ARROB," + CRLF
	cSql += " 			 ZBC_REND			                RENDIMENTO," + CRLF
	cSql += " 			 ZBC_TTSICM			                TOTAL_SEM_ICMS," + CRLF
	cSql += " 			 ZBC_TOTICM			                TOTAL_ICMS," + CRLF
	cSql += " 			 ZBC_TTSICM+ZBC_TOTICM				GADO_ICMS_TOTAL_CONTRATO," + CRLF
	cSql += " 			 ZBC_VLFRPG, ZBC_ICFRVL," + CRLF
	cSql += " 			 ZBC_VLRCOM							VLR_COM" + CRLF
	cSql += "         FROM " + RetSQLName('ZBC') + " BC" + CRLF
	cSql += "         JOIN " + RetSQLName('ZCC') + " CC ON ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO" + CRLF
	cSql += " " + CRLF
	cSql += "AND ZCC_FILIAL=ZBC_FILIAL AND ZCC_CODIGO=ZBC_CODIGO AND ZCC_VERSAO=ZBC_VERSAO" + CRLF
	cSql += "			AND ( ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN (" + CRLF
	cSql += "					SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED)" + CRLF
	cSql += "					FROM " + RetSQLName('ZBC') + "" + CRLF
	cSql += "					WHERE D_E_L_E_T_=' '" + CRLF
	cSql += "					GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC" + CRLF
	cSql += "				)" + CRLF
	cSql += "		AND CC.D_E_L_E_T_=' '" + CRLF
	cSql += "		AND BC.D_E_L_E_T_=' '" + CRLF
	cSql += "	" + CRLF
	cSql += "   INNER JOIN " + RetSQLName('SA2') + " A2 ON" + CRLF
	cSql += "   		 A2.A2_FILIAL =	' '" + CRLF
	cSql += " 		 AND A2.A2_COD					=		ZBC_CODFOR" + CRLF
	cSql += " 		 AND A2.A2_LOJA					=		ZBC_LOJFOR" + CRLF
	cSql += " 		 AND A2.D_E_L_E_T_ = ' '" + CRLF
	// cSql += "   INNER JOIN ZIC010	IC ON" + CRLF
	// cSql += " 			 IC.ZIC_FILIAL				=		ZBC_FILIAL" + CRLF
	// cSql += " 		 AND IC.ZIC_CODIGO				=		BC.ZBC_CODIGO" + CRLF
	// cSql += " 		 AND IC.ZIC_ITEM				=		BC.ZBC_ITEZIC" + CRLF
	// cSql += " " + CRLF
	//cSql += "       AND ZIC_FILIAL=ZBC_FILIAL AND ZIC_CODIGO=ZBC_CODIGO AND ZIC_VERSAO=ZBC_VERSAO" + CRLF
	cSql += "       			AND (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN" + CRLF
	cSql += "       				(" + CRLF
	cSql += "       					SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED)" + CRLF
	cSql += "       					FROM " + RetSQLName('ZBC') + "" + CRLF
	cSql += "       					WHERE D_E_L_E_T_=' '" + CRLF
	cSql += "       					GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC" + CRLF
	cSql += "       				)" + CRLF
	cSql += "       			" + CRLF
	// cSql += " 	     AND IC.D_E_L_E_T_ = ' '" + CRLF
	cSql += " " + CRLF
	cSql += "    INNER JOIN SA3010 A3 ON" + CRLF
	cSql += "			 A3_FILIAL=' '" + CRLF
	cSql += " 		 AND A3.A3_COD					=		ZBC_X_CORR" + CRLF
	cSql += " 		 AND A3.D_E_L_E_T_=' '" + CRLF
	cSql += "	-- ALTERADO" + CRLF
	cSql += "	INNER JOIN " + RetSQLName('SB1') + " B1 ON" + CRLF
	cSql += "					B1_FILIAL					= ' '" + CRLF
	cSql += "				AND B1_COD 						= ZBC_PRODUT" + CRLF
	cSql += "				AND B1_RASTRO = 'L'" + CRLF
	cSql += "				AND B1.D_E_L_E_T_ = ' '" + CRLF
	cSql += "        WHERE" + CRLF
	// cSql += " 			 ZBC_FILIAL BETWEEN '  ' AND 'ZZ'" + CRLF
	// cSql += " 		 AND ZBC_CODIGO BETWEEN '      ' AND 'ZZZZZZ'" + CRLF
	// cSql += " 		 AND ZBC_PEDIDO BETWEEN '      ' AND 'ZZZZZZ'" + CRLF
	// cSql += " AND ZBC_PEDIDO IN (" + CRLF
	// cSql += "		SELECT DISTINCT ZBC_PEDIDO FROM " + RetSQLName('ZBC') + "" + CRLF
	// cSql += "      WHERE ZBC_PRODUT IN (" + CRLF
	// cSql += " 		       SELECT DISTINCT D2_COD FROM " + RetSQLName('SD2') + " D2 " + CRLF
	// cSql += "				JOIN SF4010 F4 ON D2_TES = F4.F4_CODIGO AND F4.D_E_L_E_T_ = ' ' AND D2.D_E_L_E_T_=' '" + CRLF
	// cSql += "		   								AND F4_TRANFIL <> '1'" + CRLF
	// cSql += " 		       WHERE 	D2_TIPO='N'" + CRLF
	// cSql += " 	 		-- AND D2_EMISSAO BETWEEN '20190102' AND '20190110'" + CRLF
	// cSql += "				AND D2_LOTECTL <> ' '" + CRLF
	// cSql += " 	 ) )" + CRLF
	// cSql += " 		 AND ZBC_CODFOR BETWEEN '      ' AND 'ZZZZZZ'" + CRLF
	// cSql += "       AND
	cSql += " (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN" + CRLF
	cSql += "              (" + CRLF
	cSql += "           		SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED)" + CRLF
	cSql += "           		FROM " + RetSQLName('ZBC') + "" + CRLF
	cSql += "           		WHERE D_E_L_E_T_=' '" + CRLF
	cSql += "           		GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC" + CRLF
	cSql += "              )" + CRLF
	cSql += " 		 AND A2.D_E_L_E_T_				=		' '" + CRLF
	cSql += " " + CRLF
	cSql += " 		 AND A3.D_E_L_E_T_				=		' '" + CRLF
	cSql += "  GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_PEDIDO, ZBC_ITEMPC, ZBC_CODFOR, ZBC_LOJFOR, A2.A2_NOME, A2_MUN, A2_EST, ZBC_X_CORR, A3_NOME, ZBC_PRODUT," + CRLF
	cSql += "   			 ZBC_PRDDES, ZBC_QUANT, BC.ZBC_RACA, BC.ZBC_SEXO, ZCC_PAGFUT, BC.ZBC_TPNEG, ZBC_PEDPOR, ZBC_TEMFXA, ZBC_FAIXA, ZBC_PESO," + CRLF
	cSql += "   			 ZBC_ARROV, ZBC_PESO, ZBC_REND, ZBC_TTSICM, ZBC_TOTICM, ZBC_VLFRPG, ZBC_ICFRVL, ZBC_VLRCOM," + CRLF
	cSql += "  			 A2.A2_NOME" + CRLF
	cSql += " 		)" + CRLF
	cSql += " " + CRLF
	cSql += " , CONTRATO_DISTINCT AS (" + CRLF
	cSql += " 		SELECT FILIAL, COD_CONTRATO, CODIGO_BOV, NUMERO_LOTE, SUM(QTD_COMPRA) QTD_COMPRA" + CRLF
	cSql += " 		FROM CONTRATO" + CRLF
	cSql += " 		GROUP BY FILIAL, COD_CONTRATO, CODIGO_BOV, NUMERO_LOTE" + CRLF
	cSql += " )" + CRLF
	cSql += " " + CRLF
	cSql += ", ESTOQUE AS (" + CRLF
	cSql += " 	SELECT DISTINCT B8_FILIAL, B8.B8_PRODUTO, SUM(B8.B8_SALDO) SALDO" + CRLF
	cSql += " 	FROM " + RetSQLName('SB8') + " B8" + CRLF
	cSql += " 	JOIN CONTRATO_DISTINCT C ON C.FILIAL=B8_FILIAL AND C.CODIGO_BOV = B8_PRODUTO AND B8.D_E_L_E_T_ = ' '" + CRLF
	cSql += " 	GROUP BY B8_FILIAL, B8.B8_PRODUTO" + CRLF
	cSql += "	HAVING SUM(B8.B8_SALDO) > 0" + CRLF
	cSql += " )," + CRLF
	cSql += " " + CRLF
	cSql += " " + CRLF
	cSql += " FATURAMENTO AS (" + CRLF
	cSql += " 	SELECT D2_FILIAL, D2_COD, SUM(D2_QUANT) SALDO" + CRLF
	cSql += " 	  FROM " + RetSQLName('SD2') + " D2" + CRLF
	cSql += " 	  JOIN CONTRATO_DISTINCT C ON D2_FILIAL=C.FILIAL AND D2_COD = C.CODIGO_BOV AND  D2.D_E_L_E_T_ = ' '" + CRLF
	cSql += " 	  WHERE  D2_QUANT > 0" + CRLF
	cSql += "		 AND D2_TIPO='N'" + CRLF
	// cSql += "		 AND SUBSTRING(D2_LOTECTL,1,4) <> 'AUTO'" + CRLF
	cSql += " 	  GROUP BY D2_FILIAL, D2_COD" + CRLF
	cSql += " )," + CRLF
	cSql += " " + CRLF
	cSql += " MORTE AS (" + CRLF
	cSql += " 	SELECT D3M.D3_FILIAL, D3M.D3_COD, SUM(D3M.D3_QUANT) MORTE" + CRLF
	cSql += " 	FROM " + RetSQLName('SD3') + " D3M" + CRLF
	cSql += " 	JOIN CONTRATO_DISTINCT C ON	C.FILIAL=D3_FILIAL AND C.CODIGO_BOV = D3_COD AND D3M.D_E_L_E_T_ = ' '" + CRLF
	cSql += " 	WHERE D3M.D3_ESTORNO <> 'S'" + CRLF
	cSql += " 	  AND D3M.D3_TM IN ('511')" + CRLF
	cSql += " 	GROUP BY D3M.D3_FILIAL, D3M.D3_COD" + CRLF
	cSql += " )," + CRLF
	cSql += " " + CRLF
	cSql += " NASCIMENTO AS (" + CRLF
	cSql += " 	SELECT D3M.D3_FILIAL, D3M.D3_COD, SUM(D3M.D3_QUANT) NASCIMENTO" + CRLF
	cSql += " 	FROM " + RetSQLName('SD3') + " D3M" + CRLF
	cSql += " 	JOIN CONTRATO_DISTINCT C ON FILIAL=D3_FILIAL AND C.CODIGO_BOV = D3_COD AND D3M.D_E_L_E_T_ = ' '" + CRLF
	cSql += " 	WHERE D3M.D3_ESTORNO <> 'S'" + CRLF
	cSql += " 	  AND D3M.D3_TM IN ('011')" + CRLF
	cSql += " 	GROUP BY D3M.D3_FILIAL, D3M.D3_COD" + CRLF
	cSql += " )," + CRLF
	cSql += " " + CRLF
	cSql += " MOVBOIA AS ( " + CRLF
	cSql += " 	SELECT D3_FILIAL, D3_COD, SUM(D3.D3_QUANT) QTD_TRANSF " + CRLF
	cSql += " 	FROM " + RetSQLName('SD3') + " D3 " + CRLF
	cSql += " 	JOIN CONTRATO C ON FILIAL = D3.D3_FILIAL AND CODIGO_BOV = D3.D3_COD " + CRLF
	cSql += " 	WHERE  D3_TM IN ('499') -- D3_FILIAL = '01' " + CRLF
	cSql += " 		AND D3_CF = 'DE4' " + CRLF
	cSql += " 		AND D3_GRUPO = 'BOV' " + CRLF
	cSql += " 		AND D3_NUMSEQ IN (SELECT D3_NUMSEQ FROM " + RetSQLName('SD3') + " X WHERE D3_CF = 'RE4' AND D3_COD <> D3.D3_COD AND X.D_E_L_E_T_= ' ') " + CRLF
	cSql += " 		AND D_E_L_E_T_ = ' ' " + CRLF
	cSql += " 	 GROUP BY D3_FILIAL, D3_COD " + CRLF
	cSql += "  ), " + CRLF
	cSql += "" + CRLF
	cSql += " MOVBOIB AS ( " + CRLF
	cSql += " 	SELECT D3_FILIAL, D3_COD, SUM(D3.D3_QUANT) QTD_TRANSF " + CRLF
	cSql += " 	FROM " + RetSQLName('SD3') + " D3 " + CRLF
	cSql += " 	JOIN CONTRATO C ON FILIAL = D3.D3_FILIAL AND CODIGO_BOV = D3.D3_COD " + CRLF
	cSql += " 	WHERE  D3_TM IN ('999') -- D3_FILIAL = '01' " + CRLF
	cSql += " 	   AND D3_CF = 'RE4' " + CRLF
	cSql += " 	   AND D3_GRUPO = 'BOV' " + CRLF
	cSql += " 	   AND D3_NUMSEQ IN (SELECT D3_NUMSEQ FROM " + RetSQLName('SD3') + " X WHERE FILIAL=X.D3_FILIAL AND D3_CF = 'DE4' AND D3_COD <> D3.D3_COD AND X.D_E_L_E_T_= ' ') " + CRLF
	cSql += " 	   AND D_E_L_E_T_ = ' ' " + CRLF
	cSql += " 	 GROUP BY D3_FILIAL, D3_COD " + CRLF
	cSql += "  )," + CRLF
	cSql += "" + CRLF
	cSql += " MOVBOI AS ( " + CRLF
	cSql += "  SELECT A.D3_FILIAL, A.D3_COD, ISNULL(A.QTD_TRANSF,0)-ISNULL(B.QTD_TRANSF,0) QTD_TRANSF" + CRLF
	cSql += " 	FROM MOVBOIA A" + CRLF
	cSql += "	LEFT JOIN MOVBOIB B ON " + CRLF
	cSql += "		A.D3_FILIAL = B.D3_FILIAL AND " + CRLF
	cSql += "		A.D3_COD = B.D3_COD " + CRLF
	cSql += "	WHERE (ISNULL(A.QTD_TRANSF,0)-ISNULL(B.QTD_TRANSF,0)) <> 0" + CRLF
	cSql += "" + CRLF
	cSql += "), " + CRLF
	cSql += " DADOS AS (" + CRLF
	cSql += "	 	SELECT  C.FILIAL, COD_CONTRATO, C.NUMERO_LOTE
	cSql += "	 		  , C.CODIGO_BOV
	cSql += "	 		  , ISNULL(QTD_COMPRA,0) ZBC_COMPRA, ISNULL(E.SALDO,0) SALDO_B8," + CRLF
	cSql += "				CASE WHEN ISNULL(SUM(MOV.QTD_TRANSF),0)> 0" + CRLF
	cSql += "					THEN ISNULL(F.SALDO,0)-ISNULL(SUM(MOV.QTD_TRANSF),0)" + CRLF
	cSql += "					ELSE ISNULL(F.SALDO,0)" + CRLF
	cSql += "				END AS FATURADO," + CRLF
	cSql += "				ISNULL(M.MORTE,0) MORTE, ISNULL(N.NASCIMENTO,0) NASCIMENTO," + CRLF
	cSql += "				ISNULL(E.SALDO,0)+ISNULL(F.SALDO,0)+ISNULL(M.MORTE,0)+ISNULL(N.NASCIMENTO,0) TOTAL," + CRLF
	cSql += "				CASE WHEN SUM(MOV.QTD_TRANSF) > 0 AND ISNULL(QTD_COMPRA,0)-(ISNULL(E.SALDO,0)+ISNULL(F.SALDO,0)+ISNULL(M.MORTE,0)+ISNULL(N.NASCIMENTO,0)) < 0" + CRLF
	cSql += "					THEN ISNULL(QTD_COMPRA,0)-(ISNULL(E.SALDO,0)+ISNULL(F.SALDO,0)+ISNULL(M.MORTE,0)+ISNULL(N.NASCIMENTO,0))+ISNULL(SUM(MOV.QTD_TRANSF),0)" + CRLF
	cSql += "							ELSE ISNULL(QTD_COMPRA,0)-(ISNULL(E.SALDO,0)+ISNULL(F.SALDO,0)+ISNULL(M.MORTE,0)+ISNULL(N.NASCIMENTO,0))" + CRLF
	cSql += "				END AS DIFERE" + CRLF
	cSql += "		FROM CONTRATO_DISTINCT C" + CRLF
	cSql += "		LEFT JOIN ESTOQUE 	  E	  ON C.FILIAL=E.B8_FILIAL AND C.CODIGO_BOV = E.B8_PRODUTO" + CRLF
	cSql += "		LEFT JOIN FATURAMENTO F	  ON C.FILIAL=D2_FILIAL   AND C.CODIGO_BOV = D2_COD" + CRLF
	cSql += "		LEFT JOIN MORTE 	  M	  ON C.FILIAL=M.D3_FILIAL AND C.CODIGO_BOV = M.D3_COD" + CRLF
	cSql += "		LEFT JOIN NASCIMENTO  N	  ON C.FILIAL=N.D3_FILIAL AND C.CODIGO_BOV = N.D3_COD" + CRLF
	cSql += "		LEFT JOIN MOVBOI      MOV ON C.FILIAL=MOV.D3_FILIAL AND C.CODIGO_BOV = MOV.D3_COD" + CRLF
	cSql += "		GROUP BY C.FILIAL, COD_CONTRATO, C.NUMERO_LOTE
	cSql += "				, C.CODIGO_BOV
	cSql += "				, QTD_COMPRA, E.SALDO, F.SALDO, M.MORTE, N.NASCIMENTO" + CRLF
	cSql += "		-- HAVING ISNULL(QTD_COMPRA,0)-(ISNULL(E.SALDO,0)+ISNULL(F.SALDO,0)+ISNULL(M.MORTE,0)+ISNULL(N.NASCIMENTO,0)) <> 0" + CRLF
	cSql += " )" + CRLF
	cSql += " " + CRLF
	cSql += " " + CRLF
	cSql += " SELECT		FILIAL, " + CRLF
	cSql += "			CASE WHEN NUMERO_LOTE IS NULL THEN 'SEM CONTRATO' ELSE NUMERO_LOTE END NUMERO_LOTE," + CRLF
	cSql += " 			SUM(ZBC_COMPRA) ZBC_COMPRA," + CRLF
	cSql += " 			SUM(SALDO_B8) SALDO_B8," + CRLF
	cSql += " 			SUM(FATURADO) FATURADO," + CRLF
	cSql += " 			SUM(MORTE) MORTE," + CRLF
	cSql += " 			SUM(NASCIMENTO) NASCIMENTO," + CRLF
	cSql += " 			SUM(TOTAL) TOTAL," + CRLF
	cSql += " 			SUM(DIFERE) DIFERE" + CRLF
	cSql += " FROM		DADOS" + CRLF
	cSql += " WHERE COD_CONTRATO = '" + M->ZCC_CODIGO + "' " + CRLF
	cSql += " GROUP BY	FILIAL, NUMERO_LOTE " + CRLF
	cSql += " ORDER BY	FILIAL, NUMERO_LOTE " + CRLF

ElseIf cTipo == "PreNF"

	cSql := " WITH ENTRADA AS (" + CRLF
	cSql += "  		SELECT '1-NF ENTRADA' AS TIPO, D.R_E_C_N_O_, " + CRLF
    cSQl += "       		D.D1_FILIAL, D.D1_DOC, D.D1_SERIE, D.D1_ITEM, " + CRLF
    cSQl += "       		D.D1_FORNECE+D.D1_LOJA COD_FORNECE, RTRIM(" + RetSQLName('SA2') + ".A2_NOME) A2_NOME, D.D1_EMISSAO, D.D1_COD, D.D1_UM, D.D1_QUANT, D.D1_VUNIT," + CRLF
    cSQl += "       		D.D1_TOTAL, D.D1_VALICM, D.D1_CF, D.D1_X_KM, D.D1_X_PESCH, D.D1_X_EMBDT, D.D1_X_EMBHR, D.D1_X_CHEDT, D.D1_X_CHEHR, D.D1_VLSENAR " + CRLF
    cSQl += "       		, CP.D1_TOTAL TOT_COMPL" + CRLF
	cSQl += "       		, ZBC_CODIGO" + CRLF
	cSQl += "       		, ZBC_TOTNEG" + CRLF
	cSql += "  		  FROM " + RetSQLName('SD1') + " D " + CRLF
	cSql += "  		  JOIN " + RetSQLName('SA2') + " ON" + CRLF
	cSql += "  			   D1_FORNECE = A2_COD" + CRLF
	cSql += "  		   AND D1_LOJA = A2_LOJA" + CRLF
	cSql += "  		   AND " + RetSQLName('SA2') + ".D_E_L_E_T_ = ' ' AND D.D_E_L_E_T_=' '" + CRLF
	cSql += "    LEFT JOIN " + RetSQLName('SD1') + " CP ON D.D1_FILIAL=CP.D1_FILIAL AND D.D1_DOC=CP.D1_NFORI AND D.D1_SERIE=CP.D1_SERIORI AND D.D1_ITEM=CP.D1_ITEMORI AND D.D_E_L_E_T_=' ' AND CP.D_E_L_E_T_=' '" + CRLF
	cSQl += " 	 JOIN " + RetSQLName('ZBC') + " C ON ZBC_FILIAL=D.D1_FILIAL" + CRLF
	cSQl += " 	 				   AND RTRIM(ZBC_PRODUT)=RTRIM(D.D1_COD)" + CRLF
	cSQl += " 	 				   AND ZBC_CODFOR=D.D1_FORNECE" + CRLF
	cSQl += " 	 				   AND ZBC_LOJFOR=D.D1_LOJA" + CRLF
	cSQl += " 	 				   AND ZBC_PEDIDO=D.D1_PEDIDO" + CRLF
	cSQl += " 	 				   AND C.D_E_L_E_T_=' '" + CRLF
  	cSql += "    	  WHERE D.D1_QUANT > 0 " + CRLF
	cSql += "  				AND D.D1_TIPO = 'N'" + CRLF
	cSql += "  		        AND D.D1_FILIAL+RTRIM(D.D1_COD)+D.D1_FORNECE+D.D1_LOJA+D.D1_PEDIDO IN " + CRLF
	cSql += "  					( " + CRLF
	cSql += "  						SELECT DISTINCT ZBC_FILIAL+RTRIM(ZBC_PRODUT)+ZBC_CODFOR+ZBC_LOJFOR+ZBC_PEDIDO " + CRLF
	cSql += "  						  FROM " + RetSQLName('ZBC') + " " + CRLF
	cSql += "  						 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "' " + CRLF
	cSql += "  						   AND ZBC_CODIGO = '"+M->ZCC_CODIGO+"'" + CRLF
	// cSql += "     					   AND ZBC_PRODUT = '" + &( "o" + cPFoBCPRD + "ZBCGDad"):aCols[ nAtZBC, nPZBCPRD ] + "' " + CRLF
	cSql += "     					   AND ZBC_PRODUT IN (" + U_cValToSQL(_cProdut,",") + ") " + CRLF
	cSql += "  					)" + CRLF
	cSql += "  		)," + CRLF
	cSql += "  COMPLEMENTO AS (" + CRLF
	cSql += "  		SELECT '2-NF COMPLEMENTO' AS TIPO, D.R_E_C_N_O_, " + CRLF
	cSql += " 		D.D1_FILIAL, D.D1_DOC, D.D1_SERIE, D.D1_ITEM, " + CRLF
	cSql += " 		D.D1_FORNECE+D.D1_LOJA COD_FORNECE, RTRIM(" + RetSQLName('SA2') + ".A2_NOME) A2_NOME, D.D1_EMISSAO, D.D1_COD, D.D1_UM," + CRLF
	cSql += " 		D.D1_QUANT, D.D1_VUNIT, D.D1_TOTAL, D.D1_VALICM, D.D1_CF, D.D1_X_KM, D.D1_X_PESCH, D.D1_X_EMBDT, D.D1_X_EMBHR," + CRLF
	cSql += " 		D.D1_X_CHEDT, D.D1_X_CHEHR, D.D1_VLSENAR" + CRLF
	cSql += "  FROM SF1010 F" + CRLF
	cSql += " 	  JOIN " + RetSQLName('SD1') + " D	 ON F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_FORNECE=D1_FORNECE " + CRLF
	cSql += " 							AND F1_LOJA=D1_LOJA AND F.D_E_L_E_T_=' ' AND D.D_E_L_E_T_=' '" + CRLF
 	cSql += " 	  JOIN " + RetSQLName('SA2') + "	 ON A2_FILIAL=' ' AND D.D1_FORNECE = A2_COD AND D.D1_LOJA = A2_LOJA AND " + RetSQLName('SA2') + ".D_E_L_E_T_ = ' '  " + CRLF
 	cSql += " 	  JOIN ENTRADA E ON E.D1_COD = D.D1_COD " + CRLF
 	// cSql += " 	   -- AND E.COD_FORNECE <> F.D1_FORNECE+F.D1_LOJA
 	cSql += " 	 WHERE F.F1_TIPO = 'C'" + CRLF
	cSql += " 	   		  AND F.F1_TPCOMPL='1'" + CRLF
	cSql += " 	   		  AND D.D1_QUANT = 0  " + CRLF
	cSql += "    	      AND D.D1_FILIAL+RTRIM(D.D1_COD)+D.D1_FORNECE+D.D1_LOJA IN" + CRLF
	cSql += "     				( " + CRLF
	cSql += "     					SELECT DISTINCT ZBC_FILIAL+RTRIM(ZBC_PRODUT)+ZBC_CODFOR+ZBC_LOJFOR " + CRLF
	cSql += "     					  FROM " + RetSQLName('ZBC') + " " + CRLF
	cSql += "     					 WHERE ZBC_FILIAL = '" + M->ZCC_FILIAL + "' " + CRLF
	cSql += "     					   AND ZBC_CODIGO = '"+M->ZCC_CODIGO+"'" + CRLF
	cSql += "     					   AND ZBC_PRODUT IN (" + U_cValToSQL(_cProdut,",") + ") " + CRLF
	cSql += "  				)" + CRLF
	cSql += " ) " + CRLF
	cSql += "" + CRLF
	cSql += ", DADOS AS ( " + CRLF
	cSql += " 	SELECT TIPO, R_E_C_N_O_, D1_FILIAL, D1_DOC, D1_SERIE, D1_ITEM, D1_EMISSAO, D1_COD, D1_QUANT, D1_TOTAL, D1_VALICM, D1_VLSENAR, ISNULL(TOT_COMPL,0) TOT_COMPL " + CRLF
	cSQl += " 			, ZBC_TOTNEG" + CRLF
	cSQl += " 			, ZBC_CODIGO" + CRLF
	cSql += " 	FROM ENTRADA" + CRLF
	cSql += "" + CRLF
	cSql += " 	UNION" + CRLF
	cSql += "" + CRLF
	cSql += " 	SELECT TIPO, R_E_C_N_O_, D1_FILIAL, D1_DOC, D1_SERIE, D1_ITEM, D1_EMISSAO, D1_COD, D1_QUANT, D1_TOTAL, D1_VALICM, D1_VLSENAR, 0 " + CRLF
	cSQl += " 			, 0" + CRLF
	cSQl += " 			,''" + CRLF
	cSql += " 	FROM COMPLEMENTO" + CRLF
	cSql += " ) " + CRLF
	cSql += "" + CRLF
	cSql += " , TOTAIS_TIPO_BOV AS (" + CRLF
	cSql += "	SELECT TIPO, D1_COD, SUM(D1_TOTAL) D1_TOTAL1" + CRLF
	cSql += "	FROM DADOS" + CRLF
	cSql += "	GROUP BY TIPO, D1_COD" + CRLF
	cSql += " )" + CRLF
	cSql += " " + CRLF
	cSql += " , TOTAIS_BOV AS (" + CRLF
	cSql += "	 SELECT D1_COD, SUM(D1_TOTAL1) D1_TOTAL2" + CRLF
	cSql += "	 FROM TOTAIS_TIPO_BOV" + CRLF
	cSql += "	 GROUP BY D1_COD" + CRLF
	cSql += " )" + CRLF
	cSql += " " + CRLF
	cSql += " , TOTAIS_FINAIS AS (" + CRLF
	cSql += "	 SELECT A.*, B.D1_TOTAL2" + CRLF
	cSql += "	 FROM TOTAIS_TIPO_BOV A" + CRLF
	cSql += "	 JOIN TOTAIS_BOV	  B ON A.D1_COD=B.D1_COD" + CRLF
	cSql += " )" + CRLF
	cSql += " SELECT 'LBNO' MARK, A.D1_COD, D1_FILIAL, D1_DOC, D1_SERIE, D1_ITEM, D1_EMISSAO, A.TIPO, '   ' TES, " + CRLF
 	cSql += "	 	  SUM(D1_QUANT) QUANT, SUM(D1_TOTAL) D1_TOTAL, SUM(D1_VALICM) D1_VALICM, SUM(D1_TOTAL) - SUM(D1_VALICM) VLR_S_ICMS, D1_VLSENAR " + CRLF
 	cSql += "	 	  , SUM(TOT_COMPL) TOT_COMPL " + CRLF
	cSql += "	 	  , D1_TOTAL1" + CRLF
	cSql += "	 	  , D1_TOTAL2" + CRLF
	cSql += "	 	  , ZBC_CODIGO" + CRLF
	cSql += "	 	  , ZBC_TOTNEG" + CRLF
	cSql += "	 	  , CASE WHEN (ZBC_TOTNEG - D1_TOTAL2 - SUM(TOT_COMPL)) < 0" + CRLF
	cSql += "	 	  		THEN 0" + CRLF
	cSql += "	 	  		ELSE ZBC_TOTNEG - D1_TOTAL2 - SUM(TOT_COMPL) " + CRLF
	cSql += "	 	    END VlrCompl" + CRLF
	cSql += "	 	  -- , CASE WHEN A.TIPO='1-NF ENTRADA' THEN ZBC_TOTNEG - D1_TOTAL2 ELSE 0 END VlrCompl2" + CRLF
	cSql += " FROM DADOS A" + CRLF
	cSQl += " JOIN TOTAIS_FINAIS B ON A.TIPO=B.TIPO AND A.D1_COD=B.D1_COD" + CRLF
	cSQl += " GROUP BY A.D1_COD, D1_FILIAL, D1_DOC, D1_SERIE, D1_ITEM, D1_EMISSAO, A.TIPO, R_E_C_N_O_, D1_VLSENAR " + CRLF
	cSQl += " , D1_TOTAL1, D1_TOTAL2, ZBC_CODIGO, ZBC_TOTNEG" + CRLF
	cSQl += " ORDER BY D1_COD, D1_FILIAL, D1_DOC, D1_SERIE, D1_ITEM, D1_EMISSAO, A.TIPO, R_E_C_N_O_ " + CRLF

EndIf

if Select("QTMP") > 0
	QTMP->( dbCloseArea() )
EndIf

MemoWrite( "C:\totvs_relatorios\VACOMM12_" + cTipo + ".sql", cSql )

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),"QTMP",.F.,.T.)

aColsEsp := {}
while !QTMP->(Eof())
	aAdd(aColsEsp, array(nUsadEsp+1))
	for nX := 1 to nUsadEsp
		if aHeadEsp[nX,8]=='D'
			aColsEsp[Len(aColsEsp),nX]:=STOD( QTMP->( FieldGet(FieldPos(aHeadEsp[nX,2])) ) )
		else
			aColsEsp[Len(aColsEsp),nX]:=QTMP->( FieldGet(FieldPos(aHeadEsp[nX,2])) )
		EndIf
	next
	aColsEsp[len(aColsEsp), nUsadEsp+1] := .F.

	// Preencher com Zero, qdo nao tiver no SQL o campo
	For nX := 1 to nUsadEsp
		if Empty( aColsEsp[ Len(aColsEsp), nX ] )
			If aHeadEsp[nX,8]=='C'
				aColsEsp[ Len(aColsEsp), nX ] := Space( aHeadEsp[ nX, 4] )
			ElseIf aHeadEsp[nX,8]=='N'
				aColsEsp[ Len(aColsEsp), nX ] := 0
			ElseIf aHeadEsp[nX,8]=='N'
				aColsEsp[ Len(aColsEsp), nX ] := sToD("")
			EndIf

		EndIf
	Next nX

	QTMP->(dbSkip())
endDo
QTMP->(DbCloseArea())

Return nil


/* MJ : 08.11.2017 */
Static Function SetMark(oGD, nLinha, nColuna)
	Local lMark
	Local i
	Local nLen  	:= Len(oGD:aCols)
	
	Default nLinha  := oGD:nAt
	
	lMark := oGD:aCols[nLinha, nColuna] == 'LBNO'
	
	// If SubS( oGd:aHeader[2,2], 1, 3 ) == "ZBC"
	// 	if Empty( oGD:aCols[nLinha, nPZBCPed] )
	// 		oGD:aCols[nLinha, nColuna] := Iif(lMark, 'LBTIK', 'LBNO')
	// 	EndIf
	// Else
		oGD:aCols[nLinha, nColuna] := Iif(lMark, 'LBTIK', 'LBNO')
	// EndIf
	
	oGD:Refresh()

Return .T.


/* MB : 18.08.2020
	# Reajuste de Residuo;
*/
Static Function ReajusteResiduo()
Local aArea      := GetArea()
Local lRet       := .T.
Local aRecSC7    := {}
Local aNumSC7    := {}
Local lIntegDef  := .F.
Local n1Cnt      := 0
Local nI         := 0
Local aRet       := {}
Local cMsgRet    := ""
Local lConsEIC   := SuperGetMV("MV_ELREIC",.F.,.T.)
Local cPerg      := "MTA235"
Local nUltimo    := len(o1ZBCGDad:aCols)
Local cPedido	 := o1ZBCGDad:aCols[ nUltimo, aScan( o1ZBCGDad:aHeader, { |x| x[2] == "ZBC_PEDIDO"} ) ]
Local _cQry	     := ""
Local _cAlias	 := GetNextAlias()
Local xNovo		 := .F.

PRIVATE lMT235G1 := existblock("MT235G1")

	If Empty(cPedido)
		ShowHelpDlg("VACOMM1201",;
					 {"A linha: " + cValtoChar(nUltimo) + " n�o possue pedido gerado para ELIMINIAR RESIDUO."}, 1,;
					 {"Esta opera��o sera cancelada !"}, 1)
	Else

		If msgYesNo("Esta opera��o ira fechar o pedido: "+xFilial('ZCC') + "-" + cPedido +;
				    ". Deseja continuar?")
			
			pergunte(cPerg, .F.) // pergunte("MTA235",.F.)
			
			/*
			U_PosSX1({ { cPerg, "01", 100 },; // 01-Percentual Maximo ?           
					{ cPerg, "02", ZCC->ZCC_DTCONT },; //02-Data de Emissao de ?          
					{ cPerg, "03", dDataBase },; // 03-Data de Emissao ate ?         
					{ cPerg, "04", cPedido },; // 04-Solic/Pedido de ?             
					{ cPerg, "05", cPedido },; // 05-Solic/Pedido ate' ?           
					{ cPerg, "11", ZCC->ZCC_DTCONT },; // 11-Data de Entrega de ?          
					{ cPerg, "12", dDataBase } } ) // 12-Data de entrega ate ?         
			*/
			MV_PAR01 := 100
			MV_PAR02 := ZCC->ZCC_DTCONT
			MV_PAR03 := dDataBase
			MV_PAR04 := cPedido
			MV_PAR05 := cPedido
			MV_PAR06 := "                                                            "
			MV_PAR07 := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
			MV_PAR08 := 1
			MV_PAR09 := "                                                            "
			MV_PAR10 := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
			MV_PAR11 := ZCC->ZCC_DTCONT
			MV_PAR12 := dDataBase
			MV_PAR13 := "                                                            "
			MV_PAR14 := "                                                            "
			MV_PAR15 := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
			MV_PAR16 := "                                                            "
			MV_PAR17 := "                                                            "
		
			//Verifica se existe bloqueio cont�bil
			If lRet
				lRet := CtbValiDt(Nil,dDataBase,/*.T.*/ ,Nil ,Nil ,{"COM001"}/*,"Data de apura��o bloqueada pelo calend�rio cont�bil."*/) 
			EndIf  
			
			If lRet
				Begin Transaction
				
					Processa({|lEnd| MA235PC(mv_par01,mv_par08,mv_par02,mv_par03,mv_par04,mv_par05,;
												mv_par06,mv_par07,mv_par09,mv_par10,mv_par11,mv_par12,;
												mv_par14,mv_par15,lConsEIC,aRecSC7)})
					/*If mv_par08 == 1 //Pedido de compra
						lIntegDef	:=  FWHasEAI("MATA120",.T.,,.T.)
						If	lIntegDef
							If Len(aRecSC7) > 0
								//-- Somente PC processada pela funcao MA235PC
								For n1Cnt := 1 To Len(aRecSC7)
									SC7->(DbGoTo(aRecSC7[n1Cnt]))
									
									lIntReg := INTREG("SC7",SC7->C7_NUM)
									If Ascan(aNumSC7,SC7->C7_NUM) == 0 .And. lIntReg
										AAdd(aNumSC7,SC7->C7_NUM)
										Inclui := .T.
										Altera := .T.
										aRet := FwIntegDef( 'MATA120' )
										
										If Valtype(aRet) == "A"
											If Len(aRet) == 2
												If !aRet[1]
													If Empty(AllTrim(aRet[2]))
														cMsgRet := STR0011
													Else
														cMsgRet := AllTrim(aRet[2])
													Endif
													Aviso(STR0010,cMsgRet,{STR0013},3)
													DisarmTransaction()
													Return .F.
												Endif
											Endif
										Endif
									EndIf
								Next n1Cnt
							Endif
						EndIf
					Endif*/

					_cQry := " SELECT  SUM(D1_QUANT) QUANT" + CRLF
					_cQry += " FROM    SD1010" + CRLF
					_cQry += " WHERE	D1_FILIAL+D1_PEDIDO+D1_ITEMPC = '" + xFilial('ZBC')+&( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nUltimo, nPZBCPed ]+&( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nUltimo, nPZBCPIt ] + "'" + CRLF
					_cQry += " 	AND D_E_L_E_T_=' '"

					If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
						MemoWrite("C:\totvs_relatorios\ReajusteResiduo1.sql" , _cQry)
					EndIf

					dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.)
					// _D1QUANT := 0
					If !(_cAlias)->(Eof())
						// _D1QUANT := Posicione('SD1', 22, "010284590001", "D1_QUANT")
						&( "o" + cPFoBCQtd + "ZBCGDad"):aCols[ nUltimo, nPZBCQtd ] := (_cAlias)->QUANT //_D1QUANT
						U_miZBCFieldOK('ZBC_QUANT', (_cAlias)->QUANT, nUltimo )
					EndIf
					(_cAlias)->(DbCloseArea())

					_cQry := " WITH " + CRLF
					_cQry += " CONTRATO AS (" + CRLF
					_cQry += " 	SELECT  ZBC_FILIAL+ZBC_PEDIDO+ZBC_ITEMPC CHAVE, ZCC_QTTTAN, SUM(ZBC_QUANT) TOTAL" + CRLF
					_cQry += " 	FROM    ZCC010 CC" + CRLF
					_cQry += " 	JOIN ZBC010 BC ON ZCC_FILIAL+ZCC_CODIGO=ZBC_FILIAL+ZBC_CODIGO" + CRLF
					_cQry += " 					AND CC.D_E_L_E_T_=' ' AND BC.D_E_L_E_T_=' '" + CRLF
					_cQry += " 	WHERE	ZBC_FILIAL+ZBC_CODIGO='" + xFilial('ZCC') + ZCC->ZCC_CODIGO + "'" + CRLF
					_cQry += " 	GROUP BY ZBC_FILIAL+ZBC_PEDIDO+ZBC_ITEMPC, ZCC_QTTTAN" + CRLF
					_cQry += " )," + CRLF
					_cQry += " " + CRLF
					_cQry += " PEDIDOS AS (" + CRLF
					_cQry += " 	SELECT  C7_FILIAL+C7_NUM+C7_ITEM CHAVE," + CRLF
					_cQry += " 			SUM(CASE C7_ENCER" + CRLF
					_cQry += " 				WHEN 'E'" + CRLF
					_cQry += " 					THEN C7_QUJE" + CRLF
					_cQry += " 					ELSE C7_QUANT" + CRLF
					_cQry += " 			END) TOTAL" + CRLF
					_cQry += " 	FROM	SC7010" + CRLF
					_cQry += " 	WHERE	C7_FILIAL+C7_NUM+C7_ITEM IN (" + CRLF
					_cQry += " 		SELECT ZBC_FILIAL+ZBC_PEDIDO+ZBC_ITEMPC" + CRLF
					_cQry += " 		FROM    ZBC010" + CRLF
					_cQry += " 		WHERE	ZBC_FILIAL+ZBC_CODIGO='" + xFilial('ZCC') + ZCC->ZCC_CODIGO + "'" + CRLF
					_cQry += " 			AND D_E_L_E_T_=' '" + CRLF
					_cQry += " 		)" + CRLF
					_cQry += " 		AND D_E_L_E_T_=' '" + CRLF
					_cQry += " 	GROUP BY C7_FILIAL+C7_NUM+C7_ITEM" + CRLF
					_cQry += " )" + CRLF
					_cQry += " " + CRLF
					_cQry += " SELECT  -- C.CHAVE, " + CRLF
					_cQry += " 		ZCC_QTTTAN - " + CRLF
					_cQry += " 		-- , C.TOTAL" + CRLF
					_cQry += " 		sum(P.TOTAL) RESTANTE" + CRLF
					_cQry += " FROM	CONTRATO C" + CRLF
					_cQry += " JOIN PEDIDOS  P ON C.CHAVE=P.CHAVE" + CRLF
					_cQry += " GROUP BY ZCC_QTTTAN" + CRLF

					If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
						MemoWrite("C:\totvs_relatorios\ReajusteResiduo2.sql" , _cQry)
					EndIf

					dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.)

					If (xNovo := o1ZBCGDad:AddLine())
						For nI := 1 to Len(o1ZBCGDad:aHeader)
							If AllTrim(o1ZBCGDad:aHeader[ nI, 2 ]) == 'ZBC_QUANT'
								If !(_cAlias)->(Eof())
									o1ZBCGDad:aCols[ nUltimo+1, nI] := (_cAlias)->RESTANTE
								EndIf
							ElseIf !AllTrim(o1ZBCGDad:aHeader[ nI, 2 ]) $ ('ZBC_PEDIDO,ZBC_ITEMPC')
								o1ZBCGDad:aCols[ nUltimo+1, nI] := o1ZBCGDad:aCols[ nUltimo, nI]
							EndIf
						Next nI
						o1ZBCGDad:ForceRefresh()

						M->ZCC_QTDRES := (_cAlias)->RESTANTE
						oMGet:Refresh()
						U_miZBCFieldOK('ZBC_QUANT', (_cAlias)->RESTANTE, nUltimo+1 )
					EndIf
					(_cAlias)->(DbCloseArea())
					
					Aviso("Aviso", ;
						  "Elimina��o realizada com sucesso !!!", ;
						  {"Sair"} )

				End Transaction

				If xNovo
					GrvTable()
				EndIf
			EndIf
		// Else			
		EndIf
	EndIf

RestArea(aArea)
Return nil
// FIM: ReajusteResiduo()


/*
https://advplconsulting.wordpress.com/2016/11/03/funcoes-de-datas/

fConvHr(aCodAbono[nX,2],'D')
DescPDPon(aTotSpc[nPass,1], cFilSP9 )
__TimeSum(nEfetAbono, aJustifica[nX,2] )
__TimeSub(nQUANTC,nEfetAbono)
DiaSemana(aImp[nX,1],8)
CDOW(CTOD("02/06/12"))               // Resulta: S�bado
 */

/* DICIONARIO - DICION�RIO

	X3_ARQUIVO $ ('ZCC,ZBC,   ')
 */
