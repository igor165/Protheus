/* 
X2_CHAVE $ ('ZBC,ZCC,ZFX,ZIC,Z0C,Z0D,Z0E,ZCI,ZSI') .OR. EMPTY(X2_CHAVE)
X3_ARQUIVO $ ('ZBC,ZCC,ZFX,ZIC,Z0C,Z0D,Z0E,ZCI,ZSI') .OR. EMPTY(X3_ARQUIVO)
X3_ARQUIVO $ ('ZBC,ZCC,ZIC') .OR. EMPTY(X3_ARQUIVO)
* X3_CAMPO $ ('B1_XPARCER,B8_DIASCO,B8_GMD,B8_XDATACO,B8_XPESOCO,B8_XPFRIGO,B8_XPVISTA,B8_XRENESP,B8_XRFID,B8_X_COMIS,B8_X_CURRA,B8_X_OBS')

INDICE $ ('ZBC,ZCC,ZFX,ZIC,Z0C,Z0D,Z0E,ZCI,ZSI') .OR. EMPTY(INDICE)

\DATA\VIRADA-LOTE\SX2_20180130

=> INDICES
ZBC_FILIAL+ZBC_CODIGO+ZBC_VERSAO+ZBC_ITEM+ZBC_ITEZIC+ZBC_PEDIDO+ZBC_ITEMPC+ZBC_VERPED

auxilio no sql server

DECLARE @CODIGO VARCHAR(6) = '000081';
SELECT * FROM ZCC010 WHERE ZCC_CODIGO=@CODIGO AND D_E_L_E_T_=' ' ORDER BY R_E_C_N_O_ DESC
SELECT * FROM ZIC010 WHERE ZIC_CODIGO=@CODIGO AND D_E_L_E_T_=' ' ORDER BY R_E_C_N_O_
SELECT * FROM ZBC010 WHERE ZBC_CODIGO=@CODIGO AND D_E_L_E_T_=' ' ORDER BY R_E_C_N_O_
SELECT * FROM ZFX010 WHERE D_E_L_E_T_=' ' ORDER BY R_E_C_N_O_

SELECT * FROM ZCC010 WHERE D_E_L_E_T_=' ' ORDER BY R_E_C_N_O_
SELECT * FROM ZIC010 WHERE D_E_L_E_T_=' ' ORDER BY R_E_C_N_O_
SELECT * FROM ZBC010 WHERE D_E_L_E_T_=' ' ORDER BY R_E_C_N_O_
SELECT * FROM ZFX010 WHERE D_E_L_E_T_=' ' ORDER BY R_E_C_N_O_

UPDATE ZIC010 SET ZIC_FILIAL='01' 
UPDATE ZBC010 SET ZBC_FILIAL='01' 
UPDATE ZFX010 SET ZFX_FILIAL='01' 

DELETE FROM ZIC010 
DELETE FROM ZCC010 
DELETE FROM ZFX010 
DELETE FROM ZBC010 

POSICIONE('SB1',1,XFILIAL('SB1')+&(READVAR()),'B1_X_SEXO')==oZICGDad:aCols[oZICGDad:nAt,2]                                      
*/
#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"

Static _M7Codigo := ""

/*---------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                        |
 | Data:     23.10.2017                                                            |
 | Cliente:  V@                                                                    |
 | Desc:     Esta rotina é responsavel por realizar a manutenção dos contratos, com|
 |         as seguintes tabelas relacionadas:                                      |
 |           ZCC: Cabeçalho do Contrato;                                           |
 |           ZCC: Cabeçalho do Contrato;                                           |
 |           ZIC: Itens do Cabeçalho do Contrato;                                  |
 |           ZBC: Cadastro da Base Contratural;                                    |
 |           ZFX: Cadastro da Faixas;                                              |
 |---------------------------------------------------------------------------------|
 | Regras:   1- O campo ZBC_VERSAO possue funcao para contagem automatica;         |
 |           2- Preenchimento de campos a partir da selecao do pedido;             |
 |---------------------------------------------------------------------------------|
 | Obs.:     U_VACOMM07()                                                          |
 '---------------------------------------------------------------------------------*/
User Function VACOMM07()

Private cCadastro  := "Configuracao Contratual"
Private cAlias     := "ZCC" 
Private aRotina    := MenuDef()
Private lRastro	   := GetMV('MV_RASTRO') == 'S'

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( cAlias )   
	oBrowse:SetMenuDef("VACOMM07")
	oBrowse:SetDescription( cCadastro )
	//oBrowse:SetFilterDefault(cFiltro)
	
	oBrowse:AddLegend( "ZCC->ZCC_STATUS == 'C'", "BLACK" , "Cancelado" )
	oBrowse:AddLegend( "!Empty(U_fVldVersao(ZCC->ZCC_CODIGO, ZCC->ZCC_VERSAO))", "YELLOW", "Versao Anterior" )
	oBrowse:AddLegend( "ZCC->ZCC_STATUS == 'A'", "GREEN" , "Aberto" )
	oBrowse:AddLegend( "ZCC->ZCC_STATUS == 'N'", "WHITE" , "Negociação Apta p/ Pedido" )
	oBrowse:AddLegend( "ZCC->ZCC_STATUS == 'P'", "ORANGE", "Finalizado Parcialmente" )
	oBrowse:AddLegend( "ZCC->ZCC_STATUS == 'F'", "RED"   , "Finalizado Totalmente" )
	
	oBrowse:Activate()
Return nil 

/* MJ: 03.11.2017 */
user function VAM07Leg()
local aLegenda := {}

//Monta as cores
AAdd(aLegenda, {"BR_PRETO"		, "Cancelado"})
AAdd(aLegenda, {"BR_AMARELO"	, "Versao Anterior"})
AAdd(aLegenda, {"BR_VERDE"		, "Aberto"  })
AAdd(aLegenda, {"BR_BRANCO"		, "Negociação Apta p/ Pedido"  })
AAdd(aLegenda, {"BR_LARANJA"	, "Finalizado Parcialmente"})
AAdd(aLegenda, {"BR_VERMELHO"	, "Finalizado Totalmente"})

BrwLegenda("Transferências", "Procedencia", aLegenda, 30)

Return nil 

/* ------------------------------------------------------------------------------ */
Static Function MenuDef()
Local aRotina := {}
aAdd( aRotina, { 'Pesquisar'            , 'AxPesqui', 0, 1, 0, nil  } )
aAdd( aRotina, { 'Visualizar'           , 'U_COMM07VA', 0, 2, 0, nil  } )
aAdd( aRotina, { 'Incluir'              , 'U_COMM07VA', 0, 3, 0, nil  } )
aAdd( aRotina, { 'Alterar'              , 'U_COMM07VA', 0, 4, 0, nil  } )
aAdd( aRotina, { 'Excluir'              , 'U_COMM07VA', 0, 5, 0, nil  } )
aAdd( aRotina, { 'Gerar Versão'         , 'U_COMM07VA', 0, 6, 0, nil  } )
aAdd( aRotina, { 'Legenda'         		, 'U_VAM07Leg', 0, 7, 0, nil  } )
aAdd( aRotina, { 'Inf. Complementares'  , 'U_COMM07VA', 0, 4, 0, nil  } )
aAdd( aRotina, { 'Encerrar contrato'	, 'StaticCall(VACOMM07,xAltStatus,"F")', 0, 4, 0, nil  } )
aAdd( aRotina, { 'Cancelar contrato'	, 'StaticCall(VACOMM07,xAltStatus,"C")', 0, 4, 0, nil  } )
aAdd( aRotina, { 'Localiza Pedido'	    , 'U_xFiltroConsulta', 0, 4, 0, nil  } )

Return aRotina

/*---------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                        |
 | Data:     25.10.2017                                                            |
 | Cliente:  V@                                                                    |
 | Desc:     Função GENERICA para processar e retornar GRID com dados conforme de- |
 |         finido no vertor Header e aCols;                                        |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras:                                                                         |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.:     -                                                                     |
 '---------------------------------------------------------------------------------*/
/* 
Usando a Funcao BDados para carregar dados

Static Function LoadGrid(xAlias, xAHead, xACols, cCpos, cChave)
Local aArea := GetArea()
Local nLin	:= 0
Local aRet	:= {}

(xAlias)->(DbSetOrder(1))
If ( lRet := (xAlias)->(DbSeek( xFilial( (xAlias) ) + cChave )))
	While !(xAlias)->(Eof()) .and. &(cCpos) == cChave
		aAdd(aRet, aTail(aClone(xACols)) )
		nLin+=1
		For nI := 1 to Len(xAHead)
			aRet[nLin, nI] := (xAlias)->&(xAHead[ nI, 2 ])   
		Next nI 
		(xAlias)->(DbSkip())
	EndDo
Else
	aAdd(aRet, aClone(xACols) ) 
EndIf
RestArea(aArea)
Return aRet
 */

/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     31.07.2017                                                             |
 | Cliente:  V@                                                                     |
 | Desc:     Processar a inicializacao do campo ZFX_CODIGO; Configurado do campo:   |
 |          X3_RELACAO;                                                             |
 |----------------------------------------------------------------------------------|
 | Obs.:     Esta Funcao esta desativada por uma alteracao de definicao do processo.|
 |         o mesmo passará a ser definido a partir do Duplo-Clique;                 |
 '----------------------------------------------------------------------------------*/
User Function M07nit() // U_M07nit()                                                                                                                      
Local cRet 		   := _M7Codigo
/* Processo em definição - DESENVOLVIMENTO em execusão. */
// If Empty(_M7Codigo) .and. !ALTERA
	// cRet := _M7Codigo := GETSX8NUM('ZFX','ZFX_CODIGO')	
// EndIf
Return cRet // Iif(INCLUI, U_M07nit(), ZFX->ZFX_CODIGO )

/* MJ : 27.10.2017 */
User Function BaseConh()
Private cCadastro 	:= "Base de Conhecimento"
	MsDocument("ZCC", ZCC->(RecNo()) , 1 )     
Return nil 

/* ------------------------------------------------------------------
	MJ : 27.10.2017 
   ----------------------------------------------------------------- */
Static Function fMenuAux(nOpc)

Local nAt 		  := oZBCGDad:oBrowse:nAt
Local cContrat    := M->ZCC_CODIGO
Local cItem       := StrZero(nAt ,TamSX3('ZBC_ITEM')[01])
Local cFornec	  := M->ZCC_CODFOR
Local cLojFor     := M->ZCC_LOJFOR

If nOpc == 1
	u_VAFINA02("P", xFilial('ZCC'), cContrat+cItem, cFornec, cLojFor)
Else
	u_VAFINA03("P", xFilial('ZCC'), cContrat+cItem, cFornec, cLojFor)
EndIf

Return


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
User Function fVldVersao(cContrato, cVersao)
Local cRet := U_fChvITEM( "ZCC", "ZCC_CODIGO", "ZCC_VERSAO", "ZCC_CODIGO", cContrato)

If ( Val(cVersao) < Val(cRet)-1 ) 
	cRet := StrZero( Val(cRet)-1, TamSX3('ZCC_VERSAO')[1] )
Else
	cRet := ""
EndIf

Return cRet

`/*---------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                        |
 | Data:     26.10.2017                                                            |
 | Cliente:  V@                                                                    |
 | Desc:     Processamento do Quadro da TABELA DE PREMIAÇÃO; Registrando vinculo   |
 |         da tabela ZFX x ZBC_FAIXA;                                              |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras:                                                                         |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.:     -                                                                     |
 '---------------------------------------------------------------------------------*/
User Function DbClickZBC()

Local cRet		   := _M7Codigo
Local nAt      := oZBCGDad:oBrowse:nAt
Local lAux 		   := .F.

// oZFXGDad:Disable()

// Alert('Linha: ' + StrZero(oZBCGDad:oBrowse:nAt, 2) )
If Empty( oZBCGDad:aCols[ nAt, nPZBCFaxa ] ) .and. &(ReadVar())=='S'
	// Entao Criar codigo
	// oZBCGDad:aCols[ nAt, nPZBCFaxa ] := 
	cRet := _M7Codigo := GETSX8NUM('ZFX','ZFX_CODIGO')
	// oZBCGDad:ForceRefresh()		
EndIf

// Verificar a necessidade de recarregar a DRID,
// se codigo diferente

// Parce da programacao abaixo foi para a funcao: ZFXFieldOK
If oZFXGDad:aCols[ 1, nPZFXCod ] <> _M7Codigo
	// // RecarregarGrid
	// /*
	// aZFXCols := LoadGrid( "ZFX", aZFXHead, aZFXCols, "ZFX->ZFX_CODIGO", _M7Codigo )
	// oZFXGDad:aCols := aZFXCols[1]
	// */
	
	// // Guardando GRID ZFX em MEMORIA
	// //If Len( oZFXGDad:aCols ) > 1 .or. 
	// lAux := !Empty( oZFXGDad:aCols[1, nPZFXCod] )
	// If lAux
		// // .and. Len ( aZFXAUX ) == 0
		// //If aZFXMEM[Len(aZFXMEM), nPZFXCod] <> oZFXGDad:aCols[1,nPZFXCod]		
		// lAux := (Len(aZFXMEM) > 0)
		// If lAux
			// Alert('Programar processamento para tratar repetidos')
		// EndIf
		
		// For nI := 1 to Len( oZFXGDad:aCols )
			// aAdd( aZFXMEM , oZFXGDad:aCols[nI] )
		// Next nI
	// EndIf
	
	// U_BDados( "ZFX", @aZFXHead, @aZFXCols, @nUZFX, 1, , "'" + _M7Codigo + "' == ZFX->ZFX_CODIGO" )
	// oZFXGDad:aCols := aZFXCols
	
	If Empty( oZFXGDad:aCols[ 1, nPZFXCod ] ) .or. oZFXGDad:aCols[ 1, nPZFXCod ] <> _M7Codigo
		oZFXGDad:aCols[ 1, nPZFXCod ] := _M7Codigo
		oZFXGDad:aCols[ 1, aScan( aZFXHead, {|x| AllTrim(x[2])=="ZFX_ITEM"}) ] := StrZero( 1, TamSX3('ZFX_ITEM')[1])
	EndIf
	oZFXGDad:Enable()
	// oZFXGDad:ForceRefresh() 
	oZFXGDad:Refresh() 
EndIf
	
Return cRet
/*
Static Function ZFXbChange()
	// esta funcao é chamada ao entrar na linha, antes de qualquer alteracao
	Alert('bChange: ' + AllTrim(Str(oZFXGDad:oBrowse:nAt)) )
Return .T.
*/
Static Function ZFXbBeforeEdit()
	Alert('bBeforeEdit: ' + AllTrim(Str(oZFXGDad:oBrowse:nAt)) )
Return .T.

/* MJ: 03.11.2017 */
/* 
Esta funcao só foi chamada quado a linha estava apagada,
ao voltar alinha, a funcao nao foi chamada.
Static Function ZFXbLinhaOK()
Local nRecno := 0
Local nAt    := oZFXGDad:oBrowse:nAt

	//Alert('bLinhaOK: ' + AllTrim(Str(oZFXGDad:oBrowse:nAt)) )
	If ( nRecno := oZFXGDad:aCols[ nAt, Len(oZFXGDad:aCols[1])-1] ) > 0 
		ZFX->(DbGoTo(nRecno))
		RecLock( "ZFX", .F. )
			ZFX->( DbDelete() )
		MsUnlock()
	EndIf
Return .T.
 */
/* MJ: 03.11.2017 */
User Function ZFXFieldOK()
	Local nRecno := 0
	Local nAt    := oZFXGDad:oBrowse:nAt
	
	// // Alert('FieldOK: ' + AllTrim(Str(nAt)) + ': ' + AllTrim(Str(&(ReadVar()))) )
	// If ( nRecno := oZFXGDad:aCols[ nAt, Len(oZFXGDad:aCols[1])-1] ) > 0 
		// ZFX->(DbGoTo(nRecno))
	DbSelectArea( "ZFX" )
	ZFX->( DbSetOrder( 1 ) )
	If ZFX->( DbSeek( xFilial("ZFX") + oZFXGDad:aCols[ nAt, nPZFXCod] + oZFXGDad:aCols[ nAt, nPZFXItem] ) )
		RecLock( "ZFX", .F. )
			ZFX->&(Substr( ReadVar(), At('->', ReadVar())+2 )) := &(ReadVar())
		MsUnlock()
	Else
		RecLock( "ZFX", .T. )
			ZFX->ZFX_FILIAL := xFilial('ZFX')
			ZFX->ZFX_CODIGO := oZFXGDad:aCols[ nAt, nPZFXCod]
			ZFX->ZFX_ITEM	:= oZFXGDad:aCols[ nAt, nPZFXItem]
			ZFX->&(Substr( ReadVar(), At('->', ReadVar())+2 )) := &(ReadVar())
		MsUnlock()
		// oZFXGDad:aCols[ nAt, Len(oZFXGDad:aCols[1])-2] := "ZFX"
		// oZFXGDad:aCols[ nAt, Len(oZFXGDad:aCols[1])-1] := ZFX->(Recno())
		// oZFXGDad:ForceRefresh() 
		oZFXGDad:Refresh() 
	EndIf
Return .T.


/* ######################################################################### */
/* MJ: 03.11.2017 */
/* ######################################################################### */
User Function fCanDel(cContrato, cVersao)
Local lRet 	 := .T.
Local _cQry  := ""
Local cAlias := GetNextAlias()

	_cQry := " SELECT ZBC_FILIAL, ZBC_CODIGO, MAX(ZBC_VERSAO) ZBC_VERSAO, ZBC_PEDIDO, ZBC_ITEMPC, MAX(ZBC_VERPED) ZBC_VERPED " + CRLF
	_cQry += " FROM " + RetSQLName("ZBC") + CRLF
	_cQry += " WHERE" + CRLF
	_cQry += " 	   ZBC_FILIAL='"+xFilial('ZBC')+"' " + CRLF
	_cQry += " AND ZBC_CODIGO='"+cContrato+"' " + CRLF
	_cQry += " AND ZBC_VERSAO='"+cVersao+"' " + CRLF
	_cQry += " AND ZBC_PEDIDO<>' ' " + CRLF
	_cQry += " AND D_E_L_E_T_=' '" + CRLF
	_cQry += " GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_PEDIDO, ZBC_ITEMPC "

	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(_cQry)),(cAlias), .F., .F.)

	If !(cAlias)->(Eof())
		lRet := .F.
	EndIf

Return lRet

/*---------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                        |
 | Data:     06.11.2017                                                            |
 | Cliente:  V@                                                                    |
 | Desc:     Esta Funcão foi criada para validar se todos os campos do contrato    |
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
			Aviso("Aviso", 'O Contrato/Versao: ' + M->ZCC_CODIGO +'/' + M->ZCC_VERSAO + ' já se encontra salvo no sistema.', {"Sair"} )
		Else
			// Salvar contrato
			RecLock( "ZCC", .T. )
				U_GrvCpo("ZCC")				
			ZCC->(MsUnlock())
			
			// While __lSX8
				ZCC->( ConfirmSX8() )
			// EndDo

			oZICGDad:Enable()
			oZBCGDad:Enable()
			
			// Aviso("Aviso", 'O Contrato/Versao: ' + M->ZCC_CODIGO +'/' + M->ZCC_VERSAO + ' foi gravado com sucesso.', {"Ok"} )
			MsgInfo('O Contrato/Versao: <b>' + M->ZCC_CODIGO +'/' + M->ZCC_VERSAO + '</b> foi gravado com sucesso.', 'Aviso')
		EndIf
	EndIf
Return nil 

/* MJ : 20.11.2017 */
Static Function findMark(oGD, nColuna)
Local cRet 	:= ""
Local nI	:= 0
	For nI := 1 to Len(oGD:aCols)
		If oGD:aCols[nI, nColuna] == 'LBTIK'
			cRet := oGD:aCols[ nI, nPZICITE ]
			Exit
		EndIf
	Next nI
Return cRet

/* MJ : 20.11.2017 */
User Function CanEdit(lCanEdit, lSupremo)

Default lCanEdit 	:= .T.
Default lSupremo	:= .F.

Return Iif( Empty(oZBCGDad:aCols[oZBCGDad:nAt,nPZBCPed]), .T., lSupremo .or. (lCanEdit .and. oZBCGDad:aCols[oZBCGDad:nAt,nPZBCPdP]=="P" ) )
// Empty(&(ReadVar()))

/* MJ : 08.11.2017 */
Static Function SetMark(oGD, nLinha, nColuna)
	Local lMark
	Local i
	Local nLen  	:= Len(oGD:aCols)
	
	Default nLinha  := oGD:nAt
	//Default nColuna	:= 0
	
	lMark := oGD:aCols[nLinha, nColuna] == 'LBNO'
	
	If SubS( oGd:aHeader[2,2], 1, 3 ) == "ZIC"

		oGD:aCols[nLinha, nColuna] := Iif(lMark, 'LBTIK', 'LBNO')
		If lMark
			For i := 1 To nLen
				If i != nLinha .and. oGD:aCols[i, nColuna] == 'LBTIK'
					oGD:aCols[i, nColuna] := 'LBNO'
				EndIf
			Next
		EndIf
	
	Else // ZBC
	
		if Empty( oGD:aCols[nLinha, nPZBCPed] )
			oGD:aCols[nLinha, nColuna] := Iif(lMark, 'LBTIK', 'LBNO')
		EndIf
	
	EndIf
	
	
	oGD:Refresh()

Return .T.


/*---------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                        |
 | Data:     23.10.2017                                                            |
 | Cliente:  V@                                                                    |
 | Desc:     Esta rotina é responsavel por realizar as operações basicas de cadas- |
 |         tros;                                                                   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras:                                                                         |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.:     -                                                                     |
 '---------------------------------------------------------------------------------*/
User Function COMM07VA(cAlias, nReg, nOpc)
Local nGDOpc        := Iif( nOpc == 2, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
Local nOpcA		    := 0
Local oDlg		    := nil 
Local aSize		    := {}
Local aObjects      := {}
Local aInfo		    := {}
Local aPObjs        := {}
// Local lAtuX8	    := .F.
Local lRecLock	    := .T.
Local nPosAux	    := 0 
Local nPos2Aux	    := 0 
Local aButtons      := {}
Local cVersao	    := ""
Local nI		    := 0
// mj : 16.02.2018      
Local lPauta 	    := .F.

Private oMGet		:= nil 
Private oZICGDad    := nil , aZICHead  := {}, aZICCols  := {}, nUZIC := 1
Private oZBCGDad    := nil , aZBCHead  := {}, aZBCCols  := {}, nUZBC := 1
Private oZFXGDad    := nil , aZFXHead  := {}, aZFXCols  := {}, nUZFX := 0, aZFXMEM := {}

Private nPZICIte	:= 0
Private nPMrkZIC	:= 0
Private nPZICPrd	:= 0
Private nPZICQtd	:= 0
Private nPZICRsN	:= 0
Private nPZICQFc	:= 0
Private nPZICSxo	:= 0
Private nPMrkZBC	:= 0
Private nPZBCFaxa	:= 0
Private nPZBCITE	:= 0
Private nPZBCZIC	:= 0
Private nPZBCPed	:= 0
Private nPZBCPIt	:= 0
Private nPZBCPVs	:= 0
Private nPZBCPRD	:= 0
Private nPZBCDES	:= 0
Private nPZBCQtd	:= 0
Private nPZBCPrc	:= 0
Private nPZBCTot	:= 0
Private nPZBCPes	:= 0
Private nPZBCRen	:= 0
Private nPZBCReP	:= 0
Private nPZBCArv    := 0
Private nPZBCToI    := 0
Private nPZBCCor    := 0
Private nPZBCToP    := 0
Private nPZBCVlU    := 0
Private nPZBCXTT    := 0
Private nPZBCVLI    := 0
Private nPZBCVPT 	:= 0
Private nPZBCAIC 	:= 0
Private nPZBCICP 	:= 0
Private nPZBCVCM	:= 0
Private nPZBCTFX	:= 0
Private nPZBCDTE	:= 0
Private nPZFXCod    := 0
Private nPZFXItem	:= 0
Private aGets       := {}
Private aTela       := {}

RegToMemory( cAlias, nOpc == 3 )

If nOpc == 4 .and. !Empty(cVersao:= U_fVldVersao(ZCC->ZCC_CODIGO, ZCC->ZCC_VERSAO))
	// Se retornou CODIGO de versao, entao nao posso continuar
	Aviso("Aviso", 'A Versao selecionada: ' + ZCC->ZCC_VERSAO + ' nao pode ser alterada.' + CRLF+;
				   ' O contrato No.: ' + ZCC->ZCC_CODIGO + ' encontra-se autalmente na versao: ' + cVersao, ;
				   {"Sair"})
	Return nil 
ElseIf (nOpc == 4 .or. nOpc == 5 .or. nOpc == 6) .and. ZCC->ZCC_STATUS == "C"
	// Se retornou CODIGO de versao, entao nao posso continuar
	Aviso("Aviso", 'O contrato selecionado encontra-se cancelado e não pode ser alterado.', {"Sair"})
	Return nil 

// MJ : 21.06.2018 => alterado para permitir alteracao, depois da reuniao com CAmila, solicit. por Luana
ElseIf (nOpc == 4 .or. nOpc == 5/*  .or. nOpc == 6 */) .and. ZCC->ZCC_STATUS$"FP"
		
	If !(lPauta := U_TemPauta())
		// Se retornou CODIGO de versao, entao nao posso continuar
		Aviso("Aviso", 'O contrato selecionado encontra-se finalizado e não pode ser alterado.', {"Sair"})
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
AAdd( aObjects, { 100 , 100, .T. , .T. , .F. } )
AAdd( aObjects, { 100 ,  80, .T. , .T. , .F. } )
AAdd( aObjects, { 100 , 120, .T. , .T. , .F. } )
aInfo  := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
aPObjs := MsObjSize(aInfo, aObjects, .T., .F.) 

// os REGISTROS só poderam ser alterados se o STATUS estiver com status aberto;
If nOpc < 6 .and. !M->ZCC_STATUS$"AN" .and.  nGDOpc <> 0
	If !lPauta
		nGDOpc := 0
	EndIf
EndIf

// Itens do Contrato
//aZICHead := APBuildHeader("ZIC") //aZICCols := A610CriaCols( "ZIC", aZICHead, , {|| .F.})
AAdd(aZICHead, { " ", Padr("ZIC_MARK", 10), "@BMP", 1, 0, .F., "", "C", "", "V", "", "", "", "V", "", "", "" } )	
U_BDados( "ZIC", @aZICHead, @aZICCols, @nUZIC, 1, , IIf( nOpc != 3, "'" + M->ZCC_CODIGO + M->ZCC_VERSAO + "' == ZIC->ZIC_CODIGO + ZIC->ZIC_VERSAO", nil  ) )
nPZICIte   := aScan( aZICHead,  {|x| AllTrim(x[2])=="ZIC_ITEM"  }) 
nPZICPrd   := aScan( aZICHead,  {|x| AllTrim(x[2])=="ZIC_PRODUT"}) 
nPZICQtd   := aScan( aZICHead,  {|x| AllTrim(x[2])=="ZIC_QUANT" }) 
nPZICRsN   := aScan( aZICHead,  {|x| AllTrim(x[2])=="ZIC_VLAROB"}) // Vl R$ Negociado
nPZICQFc   := aScan( aZICHead,  {|x| AllTrim(x[2])=="ZIC_QTDFEC"}) 
nPZICSxo   := aScan( aZICHead,  {|x| AllTrim(x[2])=="ZIC_SEXO"  }) 
// aZICCols[ 1, 1, nPZICIte ] := StrZero( 1, TamSX3('ZIC_ITEM')[1])
//aZICCols := aClone( aZICCols[1] )

nPMrkZIC  := aScan( aZICHead, { |x| AllTrim(x[2]) == 'ZIC_MARK'})
// Desenhando todos os quadros
For nI := 1 to Len(aZICCols)
	If Empty( aZICCols[ nI, nPMrkZIC] )
		aZICCols[ nI, nPMrkZIC] := "LBNO"
	EndIf
Next nI

If nOpc == 3
	aZICCols[ 1, nPZICIte ] := StrZero( 1, TamSX3('ZIC_ITEM')[1])
EndIf

// Configuração da Base Contratual
// aZBCHead  := APBuildHeader("ZBC") // aZBCCols  := A610CriaCols( "ZBC", aZBCHead, , {|| .F.})
AAdd(aZBCHead, { " ", Padr("ZBC_MARK", 10), "@BMP", 1, 0, .F., "", "C", "", "V", "", "", "", "V", "", "", "" } )	
U_BDados( "ZBC", @aZBCHead, @aZBCCols, @nUZBC, 1, , IIf( nOpc != 3, "'" + M->ZCC_CODIGO + M->ZCC_VERSAO + "' == ZBC->ZBC_CODIGO + ZBC->ZBC_VERSAO", nil  ) )

nPMrkZBC  := aScan( aZBCHead, { |x| AllTrim(x[2]) == 'ZBC_MARK'})
// Desenhando todos os quadros
For nI := 1 to Len(aZBCCols)
	If Empty( aZBCCols[ nI, nPMrkZBC] )
		aZBCCols[ nI, nPMrkZBC] := "LBNO"
	EndIf
Next nI

nPZBCFaxa := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_FAIXA"  })
nPZBCITE  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_ITEM"   })
nPZBCZIC  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_ITEZIC" })
nPZBCPed  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_PEDIDO" })
nPZBCPIt  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_ITEMPC" })
nPZBCPVs  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_VERPED" })
nPZBCPRD  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_PRODUT" })
nPZBCDES  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_PRDDES" })
nPZBCPdP  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_PEDPOR" }) 
nPZBCQtd  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_QUANT"  }) 
nPZBCPrc  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_PRECO"  }) 
nPZBCTot  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_TOTAL"  }) 
nPZBCPes  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_PESO"   }) 
nPZBCPeA  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_PESOAN" }) 
nPZBCRen  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_REND"   }) 
nPZBCReP  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_RENDP"  }) 
nPZBCArv  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_ARROV"  }) 
nPZBCArQ  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_ARROQ"  }) 
nPZBCToI  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_TOTICM" }) 
nPZBCCor  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_X_CORR" }) 
nPZBCToP  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_ICMSVL" }) 
nPZBCVlU  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_VLUSIC" }) 
nPZBCXTT  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_TTSICM" }) 
nPZBCVLI  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_VLICM"  }) 
nPZBCVPT  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_VLRPTA" }) 
nPZBCAIC  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_ALIICM" }) 
nPZBCICP  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_VICMPA" }) 
nPZBCVCM  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_VLRCOM" }) 
nPZBCDTE  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_DTENTR" })
nPZBCTFX  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_TEMFXA" })
nPZBCOBS  := aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_OBS"    })
// aZBCCols := aClone( aZBCCols[1] )

// Tabela de premiação
// aZFXHead   := APBuildHeader("ZFX") // aZFXCols   := A610CriaCols( "ZFX", aZFXHead, , {|| .F.})
U_BDados( "ZFX", @aZFXHead, @aZFXCols, @nUZFX, 1, , IIf( nOpc != 3, "'" + aZBCCols[ 1, nPZBCFaxa ] + "' == ZFX->ZFX_CODIGO", nil  ) )
nPZFXCod   := aScan( aZFXHead, {|x| AllTrim(x[2])=="ZFX_CODIGO"})
nPZFXItem  := aScan( aZFXHead, {|x| AllTrim(x[2])=="ZFX_ITEM"})
// aZFXCols[ 1, 1, nPZFXItem ] := StrZero( 1, TamSX3('ZFX_ITEM')[1])
// aZFXCols := aClone( aZFXCols[1] )

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
		nPos2Aux := aScan( aZBCHead, {|x| AllTrim(x[2])=="ZBC_VERPED"} )
		For nI := 1 to Len(aZBCCols)
			cChave := ZCC->ZCC_CODIGO + ZCC->ZCC_VERSAO + aZBCCols[ nI, aScan( aZBCHead, {|x| AllTrim(x[2])=="ZBC_PEDIDO"})] + aZBCCols[ nI, aScan( aZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEMPC"})]
			aZBCCols[ nI, nPos2Aux ] := U_fChvITEM('ZBC','ZBC_CODIGO, ZBC_VERSAO, ZBC_PEDIDO, ZBC_ITEMPC', 'ZBC_VERPED', 'ZBC_CODIGO+ZBC_VERSAO+ZBC_PEDIDO+ZBC_ITEMPC', cChave )
		Next nI
	EndIf
	
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From 0,0 to aSize[6],aSize[5] PIXEL STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )  // tirar o X da tela | tirar o botao X da tela |
// oDlg:lMaximized := .T.

oGrp1  := TGroup():New(aPObjs[1,1],aPObjs[1,2],aPObjs[1,3],aPObjs[1,4],"Dados Gerais do Contrato",oDlg,,, .T.,)
oMGet  := MsMGet():New( cAlias, nReg, Iif(nGDOpc==0,2,nOpc),,,,, aPObjs[1],,,,,, oGrp1 )

if M->ZCC_STATUS == 'N'
	oMGet:Disable()
endIf

nPosAux := Round(aPObjs[2,4]/3*2,0)
oGrp2a := TGroup():New(aPObjs[2,1],aPObjs[2,2],aPObjs[2,3], nPosAux,"Itens do Contrato / Comissão",oDlg,,, .T.,)
oZICGDad := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , "+ZIC_ITEM", , , , , , "u_ZICDelOk()", oGrp2a, aClone(aZICHead), aClone( aZICCols ) )
oZICGDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oZICGDad:bChange    := {|| ZICbChange() }
// oZICGDad:bLinhaOK    := {|| ZICLinOK() }
oZICGDad:cFieldOK    := "U_ZICFieldOK()"
oZICGDad:oBrowse:BlDblClick := { || If( oZICGDad:oBrowse:nColPos == 1 .and. fCanSelIC(), SetMark(oZICGDad, , nPMrkZIC), oZICGDad:EditCell() ) }

If nOpc == 3 .or. M->ZCC_STATUS == 'N'
	oZICGDad:Disable()
EndIf

oGrp2b := TGroup():New(aPObjs[2,1],nPosAux+2,aPObjs[2,3],aPObjs[2,4],"Tabela de Premiação",oDlg,,, .T.,)
oZFXGDad := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , "+ZFX_ITEM", , , , , , , oGrp2b, aClone(aZFXHead), aClone( aZFXCols ) )
oZFXGDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
//oZFXGDad:bChange 	 := {|| ZFXbChange() }
oZFXGDad:bBeforeEdit := {|| ZFXbBeforeEdit() }
// oZFXGDad:bLinhaOK    := {|| ZFXbLinhaOK() }
oZFXGDad:cFieldOK    := "U_ZFXFieldOK()"
oZFXGDad:Disable()

oGrp3  := TGroup():New(aPObjs[3,1],aPObjs[3,2],aPObjs[3,3],aPObjs[3,4],"Configuração da Base Contratual",oDlg,,, .T.,)
oZBCGDad := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , "+ZBC_ITEM" , , , , , , "u_ZBCDelOk()", oGrp3, aClone(aZBCHead), aClone( aZBCCols ) )
oZBCGDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oZBCGDad:bChange  := {|| ZBCbChange() }
// oZBCGDad:bLinhaOK := {|| ZBCLinOK() }
oZBCGDad:cFieldOK    := "U_ZBCFieldOK()"
//oZBCGDad:cDelOK := "u_ZBCDelOk()"
oZBCGDad:oBrowse:BlDblClick := { || If( oZBCGDad:oBrowse:nColPos == 1 .and. fCanSelBC(), SetMark(oZBCGDad, , nPMrkZBC), oZBCGDad:EditCell() ) }
// oZBCGDad:oBrowse:BlDblClick := {|| DbClickZBC() }  // no campo X3_VLDUSER
If nOpc == 3
	oZBCGDad:Disable()
EndIf

Aadd( aButtons, { "AUTOM", { || u_BaseConh() }, "Base de Conhecimento" } )
AAdd( aButtons, { "AUTOM", { ||  fMenuAux(1) }, "Antecipacao"  		   } )
AAdd( aButtons, { "AUTOM", { ||  fMenuAux(2) }, "Gerar Titulo" 		   } )
AAdd( aButtons, { "AUTOM", { ||  M7SlvCrt( ) }, "Salvar Contrato"      } )
// AAdd( aButtons, { "AUTOM", { ||  M7GerarPrd() }, "Gerar Produto"        } )
AAdd( aButtons, { "AUTOM", { ||  xAutoSC7()  }, "Gerar Pedido"         } )

AAdd( aButtons, { "AUTOM", { ||  U_COMM07PE(oZBCGDad:oBrowse:nAt)  }, "Informar Peso"         } )

Set Key VK_F7  To U_COMM07PE(oZBCGDad:oBrowse:nAt)
Set Key VK_F8  To M7SlvCrt()
Set Key VK_F10 To xAutoSC7()

ACTIVATE MSDIALOG oDlg ;
          ON INIT EnchoiceBar(oDlg,;
                              { || nOpcA := 1, Iif( VldOk(nOpc) .and. Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0)},;
                              { || nOpcA := 0, oDlg:End() },, aButtons )

If nOpc == 3 .or. nOpc == 4 .or. nOpc == 6 .or. nOpc == 7 .or. nOpc == 8
 	If nOpcA == 1
		Begin Transaction
			
			DbSelectArea(cAlias)
			DbSetOrder(1) // Z2_FILIAL+Z2_ASSUNTO+Z2_OCORREN+Z2_SOLUCAO+Z2_RESULTA
			RecLock( cAlias, !DbSeek( xFilial('ZCC') + M->ZCC_CODIGO + M->ZCC_VERSAO ))
				U_GrvCpo(cAlias)
			(cAlias)->(MsUnlock())
			
			/// Tabela 1 - Meio Esquerda
			For nI := 1 to Len(oZICGDad:aCols)
				If !oZICGDad:aCols[nI][ Len(oZICGDad:aCols[1]) ] .AND. !Empty( oZICGDad:aCols[ nI,2] )
					DbSelectArea( "ZIC" )
					ZIC->( DbSetOrder( 1 ) )
					RecLock( "ZIC", lRecLock := !DbSeek( xFilial("ZIC") + M->ZCC_CODIGO + M->ZCC_VERSAO + oZICGDad:aCols[nI, nPZICIte] ) )
						U_GrvCpo( "ZIC", oZICGDad:aCols, oZICGDad:aHeader, nI )
						If lRecLock
							ZIC->ZIC_FILIAL := xFilial("ZIC")
							ZIC->ZIC_CODIGO := M->ZCC_CODIGO
							ZIC->ZIC_VERSAO := M->ZCC_VERSAO
						EndIf
					ZIC->( MsUnlock() )
					// lAtuX8 := .T.
				Else // Se o registro foi excluido e existe no banco apaga
					DbSelectArea( "ZIC" )
					ZIC->( DbSetOrder( 1 ) )
					If ZIC->( DbSeek( xFilial("ZIC") + M->ZCC_CODIGO + M->ZCC_VERSAO + oZICGDad:aCols[nI, nPZICIte] ) )
						RecLock("ZIC", .F.)
							ZIC->( DbDelete() )
						ZIC->( MsUnlock() )
					EndIf
				EndIf
			Next i
			
			DbSelectArea( "ZBC" )
			ZBC->( DbSetOrder( 1 ) )
			/// Tabela 2 - Rodapé
			For nI := 1 to Len(oZBCGDad:aCols)
				If !oZBCGDad:aCols[nI][ Len(oZBCGDad:aCols[nI]) ] ; // .AND. !Empty( oZBCGDad:aCols[ nI, 3] )
						.AND. !Empty( oZBCGDad:aCols[ nI, nPZBCITE ] ) ;
						.AND. !Empty( oZBCGDad:aCols[ nI, nPZBCZIC ] ) 
													  // ZBC_FILIAL+ZBC_CODIGO+ZBC_VERSAO+ZBC_ITEM+ZBC_ITEZIC+ZBC_PEDIDO+ZBC_ITEMPC+ZBC_VERPED

					ZBC->( DbSetOrder( 1 ) )
					RecLock( "ZBC", lRecLock := !DbSeek( xFilial("ZBC") + M->ZCC_CODIGO + M->ZCC_VERSAO + oZBCGDad:aCols[nI, nPZBCITE] /* + oZBCGDad:aCols[nI, nPZBCZIC] + oZBCGDad:aCols[nI, nPZBCPed] + oZBCGDad:aCols[nI, nPZBCPIt] + oZBCGDad:aCols[nI, nPZBCPVs] */ ) )
						U_GrvCpo( "ZBC", oZBCGDad:aCols, oZBCGDad:aHeader, nI )
						If lRecLock
							ZBC->ZBC_FILIAL := xFilial("ZBC")
							ZBC->ZBC_CODIGO := M->ZCC_CODIGO
							ZBC->ZBC_VERSAO := M->ZCC_VERSAO
							ZBC->ZBC_CODFOR := M->ZCC_CODFOR
							ZBC->ZBC_LOJFOR := M->ZCC_LOJFOR
							ZBC->ZBC_USUARI := cUserName
							ZBC->ZBC_DTALT  := Date()
						EndIf
					ZBC->( MsUnlock() )
					// lAtuX8 := .T.
				Else // Se o registro foi excluido e existe no banco apaga
					DbSelectArea( "ZBC" )
					ZBC->( DbSetOrder( 1 ) )
					If ZBC->( DbSeek( xFilial("ZBC") + M->ZCC_CODIGO + M->ZCC_VERSAO + oZBCGDad:aCols[nI, nPZBCITE] ) )
						RecLock( "ZBC", .F.)
							ZBC->( dbDelete() )
						ZBC->( MsUnLock() )
					EndIf
				EndIf
			Next i

			/// Tabela 3 - Meio Direita
			DbSelectArea( "ZFX" )
			For nI := 1 to Len(oZFXGDad:aCols)
				If oZFXGDad:aCols[ nI, Len(oZFXGDad:aCols[nI]) ] .AND. !Empty( oZFXGDad:aCols[ nI, nPZFXItem] )
					ZFX->( DbSetOrder( 1 ) )
					If ZFX->( DbSeek( xFilial("ZFX") + oZFXGDad:aCols[ nI, nPZFXCod] + oZFXGDad:aCols[ nI, nPZFXItem] ) )
						RecLock( "ZFX", .F.)
							ZFX->( DbDelete() )
						ZFX->( MsUnlock() )
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
	
	For nI := 1 to Len(oZICGDad:aCols)
		DbSelectArea( "ZIC" )
		ZIC->( DbSetOrder( 1 ) )
		If DbSeek( xFilial("ZIC") + M->ZCC_CODIGO + M->ZCC_VERSAO + oZICGDad:aCols[nI, nPZICIte]  )
			RecLock( "ZIC", .F.)
				ZIC->( DbDelete() )
			MsUnlock()
		EndIf
	Next i
	
	For nI := 1 to Len(oZBCGDad:aCols)
		DbSelectArea( "ZBC" )
		ZBC->( DbSetOrder( 1 ) )
		If DbSeek( xFilial("ZBC") + M->ZCC_CODIGO + M->ZCC_VERSAO + oZBCGDad:aCols[nI, nPZBCITE] + oZBCGDad:aCols[nI, nPZBCZIC] + oZBCGDad:aCols[nI, nPZBCPed] + oZBCGDad:aCols[nI, nPZBCPIt] + oZBCGDad:aCols[nI, nPZBCPVs] ) 
			RecLock( "ZBC", .F.)
				ZBC->( DbDelete() )
			MsUnlock()
		EndIf
	Next i

	// ZFX: Nao vou excluir, pois a mesma pode estar vinculada a outra versao do contrado
EndIf

_M7Codigo := ""
Return nil 



/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     27.07.2017                                                             |
 | Cliente:  V@                                                                     |
 | Desc:     Funcao: X3_VLDUSER, chamada no campo ZBC_PEDIDO, ZBC_ITEMPC, responsa- |
 |         vel por validar o pedido e preenchiar alguns campos automaticamente;     |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
User Function M7LoadCpo()
Local aArea   := GetArea()	
Local lRet    := .F.	

Local cCampo  := ""
Local cPedido := ""
Local cItemPC := ""

	If Empty( M->ZCC_CODFOR ) .or. Empty( M->ZCC_LOJFOR )
		Alert('Fornecedor/Loja não informado, portanto, o Pedido de Compras não pode ser validado.')
	ElseIf Empty( M->ZCC_CODCOR )
		Alert('Corretor não informado, portanto, o Pedido de Compras não pode ser validado.')
	Else
		
		lRet 	:= .T.
		cCampo  := Substr( ReadVar(), At('->', ReadVar())+2 )
		
		If cCampo == "ZBC_PEDIDO"
			cPedido := &(ReadVar())
			cItemPC := GdFieldGet('ZBC_ITEMPC')
			
		Else // ZBC_ITEMPC
			cPedido := GdFieldGet('ZBC_PEDIDO')
			cItemPC := &(ReadVar())
			
		EndIf

		If !Empty(cPedido) .and. !Empty(cItemPC) 
			
			If SC7->C7_NUM+SC7->C7_ITEM <> cPedido + cItemPC
				SC7->(DbSetOrder(1))
				SC7->(DbSeek( xFilial('SC7')+ cPedido + cItemPC))
			EndIf

			If (lRet := ExistCpo( "SC7", cPedido + cItemPC ))
				If SC7->C7_FORNECE + SC7->C7_LOJA == M->ZCC_CODFOR + M->ZCC_LOJFOR
					cChave := M->ZCC_CODIGO+M->ZCC_VERSAO+cPedido+cItemPC
					cAux := U_fChvITEM('ZBC','ZBC_CODIGO, ZBC_VERSAO, ZBC_PEDIDO, ZBC_ITEMPC', 'ZBC_VERPED', 'ZBC_CODIGO+ZBC_VERSAO+ZBC_PEDIDO+ZBC_ITEMPC', cChave )
					GdFieldPut( 'ZBC_VERPED' , cAux )

					GdFieldPut( 'ZBC_CONDPA' , SC7->C7_COND    )
					GdFieldPut( 'ZBC_PRODUT' , SC7->C7_PRODUTO )
					GdFieldPut( 'ZBC_PRDDES' , Posicione('SB1',1, xFilial('SB1') + SC7->C7_PRODUTO, 'B1_DESC' ) )
					GdFieldPut( 'ZBC_QUANT'  , SC7->C7_QUANT   )
					GdFieldPut( 'ZBC_PESO'   , SC7->C7_X_PESO  )
					GdFieldPut( 'ZBC_REND'   , SC7->C7_X_REND  )
					GdFieldPut( 'ZBC_RENDP'  , SC7->C7_X_RENDP )
					GdFieldPut( 'ZBC_ARROV'  , SC7->C7_X_ARROV )
					GdFieldPut( 'ZBC_ARROQ'  , SC7->C7_X_ARROQ )
					GdFieldPut( 'ZBC_VLICM'  , SC7->C7_X_VLICM )
					GdFieldPut( 'ZBC_VLUSIC' , SC7->C7_X_VLUNI )
					GdFieldPut( 'ZBC_TOTICM' , SC7->C7_X_TOICM )
					GdFieldPut( 'ZBC_X_CORR' , SC7->C7_X_CORRE )
					GdFieldPut( 'ZBC_TTSICM' , SC7->C7_X_TOTAL )
					GdFieldPut( 'ZBC_PRECO'  , SC7->C7_PRECO   )
					GdFieldPut( 'ZBC_TOTAL'  , SC7->C7_TOTAL   )

					// GdFieldPut( 'ZBC_CODFOR' , SC7->C7_FORNECE )
					// GdFieldPut( 'ZBC_LOJFOR' , SC7->C7_LOJA    )
					// SA2->(DbSetOrder(1))
					// If SA2->(DbSeek( xFilial('SA2')+ SC7->C7_FORNECE + SC7->C7_LOJA ))
						// GdFieldPut( 'ZBC_NOMFOR' , SA2->A2_NOME    )	
					// EndIf
					
				Else
					Alert('Pedido selecionado não pertence ao fornecedor informado no contrato.')
					lRet := .F.
				EndIf
			Else
				Alert('Pedido de Compra: ' + cPedido + '-' + cItemPC + ' não localizado.')
			EndIf
		EndIf
	EndIf
RestArea(aArea)
Return lRet

/* MJ : 23.11.2017 */
Static Function ZICbChange()
	Local nAt 		:= oZICGDad:oBrowse:nAt
	If Empty( oZICGDad:aCols[ nAt, 1] ) 
		oZICGDad:aCols[ nAt, 1] := "LBNO"
		oZICGDad:Refresh()
	EndIf
Return .T.

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
Static Function ZBCbChange()
	Local lAux 		:= .F.
	Local nAt 		:= oZBCGDad:oBrowse:nAt

	If Empty( oZBCGDad:aCols[ nAt, 1] ) 
		oZBCGDad:aCols[ nAt, 1] := "LBNO"
		oZBCGDad:Refresh()
	EndIf
	
	_M7Codigo := oZBCGDad:aCols[ nAt, nPZBCFaxa ] // oZFXGDad:aCols[1, nPZFXCod]
	
	// lAux := Empty( oZBCGDad:aCols[ nAt, nPZBCFaxa ] ) .and. !Empty(oZFXGDad:aCols[1, nPZFXCod])
	lAux := ( oZBCGDad:aCols[ nAt, nPZBCFaxa ] <> oZFXGDad:aCols[1, nPZFXCod] )
	If lAux
		//oZFXGDad:aCols := {}
		aZFXHead := {}
		aZFXCols := {}
		U_BDados( "ZFX", @aZFXHead, @aZFXCols, @nUZFX, 1, , "'" + oZBCGDad:aCols[ nAt, nPZBCFaxa ] + "' == ZFX->ZFX_CODIGO" )
		oZFXGDad:aCols := aZFXCols
		oZFXGDad:Refresh()
	EndIf
	
	If Empty(oZFXGDad:aCols[1, nPZFXCod])
 		oZFXGDad:Disable()
	Else
		oZFXGDad:Enable()
	EndIf
	
	// Alert('ZBCbChange: ' + AllTrim(Str( nAt )))
Return .T.

/* ####################################################################### */
/* MJ : 06.11.2017 */
/* ####################################################################### */
/* Static Function ZBCLinOK()
Local lRet     := .T.
Local nI 	   :=  0
Local nAt      := oZBCGDad:oBrowse:nAt
Local nTotQtde := 0

	// Validar Quantidade digitada
	//Alert('ZBCLinOK: ' + AllTrim(Str( nAt )))
	oZBCGDad:aCols[ nAt, 1] := "LBNO"

Return lRet

 */ 
/* ####################################################################### */
/* MJ : 06.11.2017 */
/* ####################################################################### */
User Function ZICFieldOK()
Local lRet     := .T.
Local nI 	   :=  0
Local nAt      := oZICGDad:oBrowse:nAt
Local nTotQtde := 0
Local cCampo   := Substr( ReadVar(), At('->', ReadVar())+2 )
Local _cInfo   := &( ReadVar() )

	// Esta validacao só é necessaria qdo somente o cabeçalho foi salvo, mas nenhum dos quadros forem;
	If Empty( GdFieldGet( 'ZIC_ITEM') )
		GdFieldPut( 'ZIC_ITEM', StrZero( nAt, TamSX3('ZIC_ITEM')[1] ) )
	EndIf

	If cCampo == 'ZIC_QUANT'

		/*Editado por Renato de Bianchi*/
		//Valida a quantidade em relacao ao cabeçalho
		nTotQtde := 0
		For nI := 1 to Len(oZICGDad:aCols)
			If !oZICGDad:aCols[nI][ Len(oZICGDad:aCols[1]) ] .AND. !Empty( oZICGDad:aCols[ 1, 2] )
				if nAt == nI
					nTotQtde += M->ZIC_QUANT
				else
					nTotQtde += oZICGDad:aCols[nI, nPZICQtd]
				endIf
			EndIf
		Next i	
		if M->ZCC_QTTTAN < nTotQtde
			lRet := .F.
			Alert("Quantidade informada é maior que o saldo informado no cabeçalho.")
		endIf
		
		//Valida a quantidade em relacao aos pedidos
	    if lRet
			nTotQtde := 0
			For nI := 1 to Len(oZBCGDad:aCols)
				If !oZBCGDad:aCols[nI][Len(oZBCGDad:aCols[1])] .and. oZBCGDad:aCols[nI][nPZBCZIC] == oZICGDad:aCols[oZICGDad:oBrowse:nAt][nPZBCITE]
					nTotQtde += oZBCGDad:aCols[nI, nPZBCQtd]
				EndIf
			Next i
			if M->ZIC_QUANT < nTotQtde
				lRet := .F.
				Alert("Quantidade informada é menor que a quantidade informada na base contratural.")
			endIf
		endIf
	
	ElseIf cCampo == 'ZIC_TPNEG'
		
		// programar que soh pode escolher o tipo de negociacao por KILO, qdo pagamento futuro for igual a NAO
		If M->ZCC_PAGFUT == "S"
			If _cInfo == "K" // Kilo
				lRet := .F.
				Alert("O tipo de negociação KILO não pode ser selecionado quando o contrato estiver configurado para Pagamento Futuro.")
			ElseIf _cInfo == "P" // Peso
				lRet := .F.
				Alert("O tipo de negociação PESO não pode ser selecionado quando o contrato estiver configurado para Pagamento Futuro.")
			EndIf
		EndIf
	
	ElseIf cCampo == 'ZIC_VLAROB'	
	
		For nI := 1 to Len(oZBCGDad:aCols)		
			If oZBCGDad:aCols[ nI, nPZBCZIC] == oZICGDad:aCols[ nAt, nPZICIte] .and. ;
				!Empty( oZBCGDad:aCols[ nI, nPZBCPed ] ) .and. ;
				oZBCGDad:aCols[ nI, nPZBCQtd ] > 0 
				
				U_ZBCFieldOK('ZBC_RENDP' , oZBCGDad:aCols[ nI, nPZBCReP], nI )
				U_ZBCFieldOK('ZBC_PESO'  , oZBCGDad:aCols[ nI, nPZBCPes], nI )
				U_ZBCFieldOK('ZBC_TOTICM', oZBCGDad:aCols[ nI, nPZBCToI], nI )
			EndIf
		Next nI
		// C02V5PYPHV22 // https://checkcoverage.apple.com/br/pt/?sn=C02V5PYPHV22.22MN
	EndIf
	
Return lRet

/* ####################################################################### */
/* MJ : 06.11.2017 
	
	Alt. 13.11.18
		Param : lVLd : Define se ir realizar a validacao ou nao;
   ####################################################################### */
User Function ZBCFieldOK(cCampo, _cInfo, nAt, lVld )
Local lRet     := .T.
Local nI 	   := 0
Local nTotQtde := 0
Local cItemZIC := ""
Local lTodos   := .F. 
Local nPZIC    := 0
Local nAux	   := 0
Local lMark

Default nAt    := oZBCGDad:oBrowse:nAt
Default cCampo := Substr( ReadVar(), At('->', ReadVar())+2 )
Default _cInfo := &( ReadVar() )
Default lVld   := .T.

	If lVld
		// If Empty( GdFieldGet( 'ZBC_ITEM' ) )
		If Empty( oZBCGDad:aCols[ nAt, nPZBCITE] ) // ZBC_ITEM
			GdFieldPut( 'ZBC_ITEM', StrZero( nAt, TamSX3('ZBC_ITEM')[1] ) )
		EndIf
	// Alert('ZBCFieldOK: ' + AllTrim(Str( nAt )))
	EndIf
	
	// Validar preenchimento do campo: ZBC_ITEZIC
	If Empty( cItemZIC := Iif(cCampo == 'ZBC_ITEZIC', &(ReadVar()), oZBCGDad:aCols[ nAt, nPZBCZIC] ) )
		// programar funcao para pesquisa no quadro ZIC
		// em buscar de selecionado
		If Empty( cItemZIC := oZBCGDad:aCols[ nAt, nPZBCZIC] := findMark(oZICGDad, nPMrkZIC) )
			
			Alert('Item do contrato não vinculado.')
			
			If lVld
				GdFieldPut( 'ZBC_ITEZIC', Space(TamSX3('ZBC_ITEZIC')[1]) )
				GdFieldPut( 'ZBC_ITEMPC', Space(TamSX3('ZBC_ITEMPC')[1]) )
				GdFieldPut( 'ZBC_VERPED', Space(TamSX3('ZBC_VERPED')[1]) )
			EndIf
			/*
			GdFieldPut( 'ZBC_CONDPA', Space(TamSX3('ZBC_CONDPA')[1]) )
			GdFieldPut( 'ZBC_PRODUT', Space(TamSX3('ZBC_PRODUT')[1]) )
			GdFieldPut( 'ZBC_PRDDES', Space(TamSX3('ZBC_PRDDES')[1]) )
			GdFieldPut( 'ZBC_QUANT' , 0 )
			GdFieldPut( 'ZBC_PESO'  , 0 )
			GdFieldPut( 'ZBC_REND'  , 0 )
			GdFieldPut( 'ZBC_RENDP' , 0 )
			GdFieldPut( 'ZBC_ARROV' , 0 )
			GdFieldPut( 'ZBC_ARROQ' , 0 )
			GdFieldPut( 'ZBC_VLICM' , 0 )
			GdFieldPut( 'ZBC_VLUSIC', 0 )
			GdFieldPut( 'ZBC_TOTICM', 0 )
			GdFieldPut( 'ZBC_X_CORR', Space(TamSX3('ZBC_X_CORR')[1]) )mbe
			GdFieldPut( 'ZBC_TTSICM', 0 )
			GdFieldPut( 'ZBC_PRECO' , 0 )
			GdFieldPut( 'ZBC_TOTAL' , 0 )
			*/
			Return .F.
		EndIf
	EndIf

	If cCampo == 'ZBC_ITEZIC'
		if (nPZIC := aScan( oZICGDad:aCols, {|x| AllTrim(x[nPZICIte]) == cItemZIC })) == 0
			Alert('Item do contrato não Localizado.' + CRLF + 'Esta operação será cancelada' )
			Return .F.
		EndIf

		SetMark(oZICGDad, nPZIC, nPMrkZIC) // setar Marca POSICIONADO no quado ZIC
		
	ElseIf cCampo == 'ZBC_PEDIDO'
		
		GdFieldPut( 'ZBC_PEDIDO', PadL( AllTrim( _cInfo ), TamSX3('C7_NUM')[1], '0') )
	
	ElseIf cCampo == 'ZBC_ITEMPC'
	
		GdFieldPut( 'ZBC_ITEMPC', PadL( AllTrim( _cInfo ), TamSX3('C7_ITEM')[1], '0') )
	
	ElseIf cCampo == 'ZBC_QUANT'
		
		nTotQtde 	:= 0
		nQtdTotal	:= 0
		// 1) Regra um
		For nI := 1 to len(oZBCGDad:aCols) //nAt
			If !oZBCGDad:aCols[ nI, Len( oZBCGDad:aCols[ 1 ] ) ]
				nQtdTotal += Iif(nI==nAt, &(ReadVar()), oZBCGDad:aCols[ nI, nPZBCQtd ])
				if oZBCGDad:aCols[ nI, nPZBCZIC ] == cItemZIC
					nTotQtde += Iif(nI==nAt, &(ReadVar()), oZBCGDad:aCols[ nI, nPZBCQtd ])
				EndIf
			EndIf
		Next nI
		
		if nQtdTotal > M->ZCC_QTTTAN
			Alert('Quantidade de animais ultrapassou o configurado no Cabeçalho do Contrato.')
			Return .F.
		EndIf
		
		M->ZCC_QTDRES := M->ZCC_QTTTAN - nQtdTotal
		oMGet:Refresh()
		
		If nTotQtde > oZICGDad:aCols[ aScan( oZICGDad:aCols, {|x| AllTrim(x[nPZICIte])==cItemZIC }), nPZICQtd ] // M->ZCC_QTTTAN
			Alert('Quantidade de animais ultrapassou o configurado no Cabeçalho do Contrato.')
			Return .F.
		EndIf
		
		// 2) Regra dois
		If lRet
		
			lTodos := (_cInfo > 0 .and. oZBCGDad:aCols[nAt,nPZBCPes] > 0 .and. oZBCGDad:aCols[nAt,nPZBCRen] > 0 .and. oZBCGDad:aCols[nAt,nPZBCArv] > 0 .and. oZBCGDad:aCols[nAt,nPZBCToI] > 0)
			If lTodos
				// ZBC_VLUSIC
				oZBCGDad:aCols[nAt,nPZBCVlU]	:= NoRound( oZBCGDad:aCols[nAt,nPZBCXTT] / _cInfo , TamSX3("ZBC_VLUSIC")[2])
			
				// ZBC_VLICM: Calcula Valor ICMS Unit?rio (ZBC_VLICM)
				oZBCGDad:aCols[nAt,nPZBCVLI] :=	NoRound( oZBCGDad:aCols[nAt,nPZBCToI]/ _cInfo , TamSX3("ZBC_VLICM")[2])
				
				// ZBC_PRECO
				//oZBCGDad:aCols[nAt,nPZBCPrc]	:= NoRound( oZBCGDad:aCols[nAt,nPZBCVlU] + oZBCGDad:aCols[nAt,nPZBCVLI], TamSX3("ZBC_PRECO")[2])
				
				If U_CanEdit(.F.)
					oZBCGDad:aCols[nAt,nPZBCPrc]	:= NoRound( Iif(Type("M->ZBC_VLUSIC")<>"U", M->ZBC_VLUSIC, oZBCGDad:aCols[nAt,nPZBCVlU]) + Iif(Type("M->ZBC_VLICM")<>"U", M->ZBC_VLICM, oZBCGDad:aCols[nAt,nPZBCVLI]), TamSX3("ZBC_PRECO")[2])
					
					// ZBC_TOTAL
					oZBCGDad:aCols[nAt,nPZBCTot]	:= NoRound( oZBCGDad:aCols[nAt,nPZBCPrc] * oZBCGDad:aCols[nAt,nPZBCQtd], TamSX3("ZBC_TOTAL")[2])
				EndIf
			EndIf
			
			if (nPZIC := aScan( oZICGDad:aCols, {|x| AllTrim(x[nPZICIte])== cItemZIC })) > 0
				
				nAux := ( oZICGDad:aCols[ nPZIC, aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_TOTVLR"}) ] / ;
						  oZICGDad:aCols[ nPZIC, aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_QUANT" }) ] ) ;
						  * _cInfo
				
				GdFieldPut( 'ZBC_VLRCOM', nAux )
			EndIf
			
			U_ZBCFieldOK('ZBC_PESO'  , oZBCGDad:aCols[nAt,nPZBCPes] )

		EndIf

	ElseIf cCampo == 'ZBC_VLRPTA' // nPZBCVPT
		
		// ZBC_VICMPA
		oZBCGDad:aCols[nAt,nPZBCICP] := NoRound( _cInfo * oZBCGDad:aCols[nAt,nPZBCAIC] /100, TamSX3("ZBC_VICMPA")[2])
		
		If M->ZCC_PAGFUT == "S" .or. oZBCGDad:aCols[ nAt, nPZBCPdP ] == "P"
			
			If U_CanEdit(.F.)
				// ZBC_PRECO									toshio mandou tirar esse Aliq. ICMS, 14.02.18 
				oZBCGDad:aCols[nAt,nPZBCPrc] := NoRound( _cInfo /*+ oZBCGDad:aCols[nAt,nPZBCICP]*/, TamSX3("ZBC_PRECO")[2])
				// ZBC_TOTAL
				oZBCGDad:aCols[nAt,nPZBCTot]	:= NoRound( oZBCGDad:aCols[nAt,nPZBCPrc] * oZBCGDad:aCols[nAt,nPZBCQtd], TamSX3("ZBC_TOTAL")[2])
			EndIf
			
			//ZBC_TTSICM: Calcula Valor Total (ZBC_TTSICM)
			oZBCGDad:aCols[nAt,nPZBCXTT] := NoRound( oZBCGDad:aCols[nAt,nPZBCPrc] * oZBCGDad:aCols[nAt,nPZBCQtd], TamSX3("ZBC_TOTAL")[2])
			// ZBC_VLUSIC
			oZBCGDad:aCols[nAt,nPZBCVlU]	:= NoRound( _cInfo + oZBCGDad:aCols[nAt,nPZBCICP], TamSX3("ZBC_PRECO")[2])
		EndIf
	
	ElseIf cCampo == 'ZBC_ALIICM' // nPZBCAIC	
		
		// ZBC_VICMPA
		oZBCGDad:aCols[nAt,nPZBCICP] := NoRound( _cInfo * oZBCGDad:aCols[nAt,nPZBCVPT] /100, TamSX3("ZBC_VICMPA")[2])
		
	ElseIf cCampo == 'ZBC_PESO' // nPZBCPes

		If _cInfo > 0 .and. Empty(oZBCGDad:aCols[nAt,nPZBCRen])
			oZBCGDad:aCols[nAt,nPZBCRen] := 50
			
			oZBCGDad:aCols[nAt,nPZBCReP] := NoRound( _cInfo * 0.50 , TamSX3("ZBC_RENDP")[2])
		EndIf
		
		//ZBC_PESOAN
		oZBCGDad:aCols[nAt,nPZBCPeA] := NoRound( _cInfo / oZBCGDad:aCols[nAt,nPZBCQtd], TamSX3("ZBC_PESOAN")[2])
		
		If oZICGDad:aCols[ Val(cItemZIC), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_TPNEG"}) ] == "K"
			oZBCGDad:aCols[nAt,nPZBCArv] := NoRound( ((_cInfo * oZICGDad:aCols[ Val(cItemZIC), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_VLAROB" }) ])/ oZBCGDad:aCols[nAt,nPZBCQtd] ) / (_cInfo/oZBCGDad:aCols[nAt,nPZBCQtd]) * 30 , TamSX3("ZBC_ARROV")[2])
		EndIf
		
		If M->ZCC_PAGFUT == "N"
			lTodos := oZBCGDad:aCols[nAt,nPZBCQtd] > 0 
			
					// esta parte abaixo foi comentada para processar todos os campos a partir
					// da digitacao do peso
					// .and. _cInfo > 0 .and. oZBCGDad:aCols[nAt,nPZBCRen] > 0 .and. oZBCGDad:aCols[nAt,nPZBCArv] > 0	.and. oZBCGDad:aCols[nAt,nPZBCToI] > 0 
			If lTodos .or. ;
				oZICGDad:aCols[ Val(cItemZIC), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_TPNEG"}) ] $ ("KQ")
				
				//ZBC_RENDP: Calcula Rendimento em Peso (ZBC_RENDP)
				oZBCGDad:aCols[nAt,nPZBCReP] := NoRound(_cInfo * oZBCGDad:aCols[nAt,nPZBCRen] / 100, TamSX3("ZBC_RENDP")[2])
			
				U_ZBCFieldOK('ZBC_ARROV', oZBCGDad:aCols[nAt,nPZBCArv] )
			EndIf
		EndIf

	ElseIf cCampo == 'ZBC_REND' // nPZBCRen  

		//ZBC_RENDP: Calcula Rendimento em Peso (ZBC_RENDP)
		oZBCGDad:aCols[nAt,nPZBCReP] := NoRound(oZBCGDad:aCols[nAt,nPZBCPes] * (_cInfo / 100) , TamSX3("ZBC_RENDP")[2])

		// lTodos := (oZBCGDad:aCols[nAt,nPZBCQtd] > 0 .and. oZBCGDad:aCols[nAt,nPZBCPes] > 0 .and. _cInfo > 0 .and. oZBCGDad:aCols[nAt,nPZBCArv] > 0 .and. oZBCGDad:aCols[nAt,nPZBCToI] > 0)
		// If lTodos
			U_ZBCFieldOK('ZBC_ARROV', oZBCGDad:aCols[nAt,nPZBCArv] )
		// EndIf
		
	ElseIf cCampo == 'ZBC_RENDP' // nPZBCReP

		//ZBC_REND: Calcula Rendimento em Peso (ZBC_RENDP)
		oZBCGDad:aCols[nAt,nPZBCRen] := NoRound(_cInfo/oZBCGDad:aCols[nAt,nPZBCPes] * 100	, TamSX3("ZBC_REND")[2])
		
		If oZICGDad:aCols[ Val(cItemZIC), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_TPNEG"}) ] == "K"		
			If U_CanEdit(.F.)
				oZBCGDad:aCols[nAt,nPZBCTot] := _cInfo * oZICGDad:aCols[ Val(cItemZIC), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_VLAROB" }) ]
				oZBCGDad:aCols[nAt,nPZBCPrc] := oZBCGDad:aCols[nAt,nPZBCTot] / oZBCGDad:aCols[nAt,nPZBCQtd]
			EndIf
		EndIf
		
		lTodos := (oZBCGDad:aCols[nAt,nPZBCQtd] > 0 .and. oZBCGDad:aCols[nAt,nPZBCPes] > 0 .and. oZBCGDad:aCols[nAt,nPZBCRen] > 0 .and. oZBCGDad:aCols[nAt,nPZBCArv] > 0 .and. oZBCGDad:aCols[nAt,nPZBCToI] > 0)
		If lTodos
			U_ZBCFieldOK('ZBC_ARROV', oZBCGDad:aCols[nAt,nPZBCArv] )
		EndIf
		
	ElseIf cCampo == 'ZBC_ARROV' // nPZBCArv

		// ZBC_ARROQ: [CALCULADO] Quantidade de Arrobas
		oZBCGDad:aCols[nAt,nPZBCArQ]	:= Round( oZBCGDad:aCols[nAt,nPZBCReP] / 15, TamSX3("ZBC_ARROQ")[2])

		//ZBC_TTSICM: Calcula Valor Total (ZBC_TTSICM)
		oZBCGDad:aCols[nAt,nPZBCXTT] :=  Round( oZBCGDad:aCols[nAt,nPZBCArQ] * _cInfo, TamSX3("ZBC_TTSICM")[2])

		If M->ZCC_PAGFUT == "N"
			
			If oZICGDad:aCols[ Val(cItemZIC), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_TPNEG"}) ] == "Q" ;
				.and. Empty(oZBCGDad:aCols[nAt,nPZBCXTT])
				
				_cInfo := oZICGDad:aCols[ Val(cItemZIC), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_VLAROB" }) ] * ;			
							Iif(ReadVar()=='M->ZBC_QUANT', &(ReadVar()), oZBCGDad:aCols[nAt,nPZBCQtd])
			Else
				_cInfo := oZBCGDad:aCols[nAt,nPZBCXTT]
			EndIf
			
			U_ZBCFieldOK('ZBC_TTSICM', _cInfo )
		EndIf
		
	ElseIf cCampo == 'ZBC_TTSICM' // nPZBCXTT

		// ZBC_VLUSIC
		oZBCGDad:aCols[nAt,nPZBCVlU]	:= NoRound( _cInfo / Iif(ReadVar()=='M->ZBC_QUANT', &(ReadVar()), oZBCGDad:aCols[nAt,nPZBCQtd]) , TamSX3("ZBC_VLUSIC")[2])
		
		// ZBC_TTSICM
		oZBCGDad:aCols[nAt,nPZBCxTT]    := _cInfo
		
		If U_CanEdit(.F.)
			/*
			// ZBC_PRECO
			oZBCGDad:aCols[nAt,nPZBCPrc]	:= NoRound( oZBCGDad:aCols[nAt,nPZBCVlU] + oZBCGDad:aCols[nAt,nPZBCVLI], TamSX3("ZBC_PRECO")[2])
			
			// ZBC_TOTAL
			oZBCGDad:aCols[nAt,nPZBCTot]	:= NoRound( oZBCGDad:aCols[nAt,nPZBCPrc] * Iif(ReadVar()=='M->ZBC_QUANT', &(ReadVar()), oZBCGDad:aCols[nAt,nPZBCQtd]), TamSX3("ZBC_TOTAL")[2])
			*/
			
			// MJ : 09.03.2018 => problemas com arredondamento
			// ZBC_TOTAL
			oZBCGDad:aCols[nAt,nPZBCTot] := NoRound( oZBCGDad:aCols[nAt,nPZBCxTT]+oZBCGDad:aCols[nAt,nPZBCToI], TamSX3("ZBC_TOTAL")[2])
			// ZBC_PRECO
			oZBCGDad:aCols[nAt,nPZBCPrc] := NoRound( oZBCGDad:aCols[nAt,nPZBCTot] / Iif(ReadVar()=='M->ZBC_QUANT', &(ReadVar()), oZBCGDad:aCols[nAt,nPZBCQtd]) , TamSX3("ZBC_PRECO")[2])			
			
		EndIf
		
		// preencher automaticamente valor de pauta
		If oZBCGDad:aCols[ nAt, nPZBCPdP ] == "P"
			oZBCGDad:aCols[nAt,nPZBCVPT] := oZICGDad:aCols[ Val(cItemZIC), nPZICRsN ]
		EndIf
		
	ElseIf cCampo == 'ZBC_TOTICM' // nPZBCToI

		// ZBC_VLICM: Calcula Valor ICMS Unit?rio (ZBC_VLICM)
		oZBCGDad:aCols[nAt,nPZBCVLI] :=	NoRound( _cInfo / oZBCGDad:aCols[nAt,nPZBCQtd] , TamSX3("ZBC_VLICM")[2])

		// VAlor a Ser pago pela V@ de ICMS
		oZBCGDad:aCols[nAt,nPZBCToP] := _cInfo

		If U_CanEdit(.F.)
			// ZBC_TOTAL
			oZBCGDad:aCols[nAt,nPZBCTot]	:= NoRound( oZBCGDad:aCols[nAt,nPZBCxTT] + _cInfo , TamSX3("ZBC_TOTAL")[2])
			 // NoRound( oZBCGDad:aCols[nAt,nPZBCPrc] * oZBCGDad:aCols[nAt,nPZBCQtd] , TamSX3("ZBC_TOTAL")[2])
			
			// ZBC_PRECO
			oZBCGDad:aCols[nAt,nPZBCPrc]	:= NoRound( oZBCGDad:aCols[nAt,nPZBCTot] / oZBCGDad:aCols[nAt,nPZBCQtd] , TamSX3("ZBC_PRECO")[2])
			// NoRound( oZBCGDad:aCols[nAt,nPZBCVlU] + oZBCGDad:aCols[nAt,nPZBCVLI] , TamSX3("ZBC_PRECO")[2])
		EndIf
		
		/*
		lTodos := (oZBCGDad:aCols[nAt,nPZBCQtd] > 0 .and. oZBCGDad:aCols[nAt,nPZBCPes] > 0 .and. oZBCGDad:aCols[nAt,nPZBCRen] > 0 .and. oZBCGDad:aCols[nAt,nPZBCArv] > 0 .and. _cInfo > 0)
		este nao testado ainda
		If lTodos
			U_ZBCFieldOK('ZBC_ARROV', oZBCGDad:aCols[nAt,nPZBCArv] )
		EndIf
		*/
	ElseIf cCampo == 'ZBC_VLICM' // nPZBCVLI

		// ZBC_TOTICM
		oZBCGDad:aCols[nAt,nPZBCToI] := NoRound(  _cInfo * oZBCGDad:aCols[nAt,nPZBCQtd] , TamSX3("ZBC_TOTICM")[2])
		
		// VAlor a Ser pago pela V@ de ICMS
		oZBCGDad:aCols[nAt,nPZBCToP] := oZBCGDad:aCols[nAt,nPZBCToI]
		
		If U_CanEdit(.F.)
			// ZBC_PRECO
			oZBCGDad:aCols[nAt,nPZBCPrc]	:= NoRound( _cInfo + oZBCGDad:aCols[nAt,nPZBCVlU] , TamSX3("ZBC_PRECO")[2])
				
			// ZBC_TOTAL
			oZBCGDad:aCols[nAt,nPZBCTot]	:= NoRound( oZBCGDad:aCols[nAt,nPZBCPrc] * oZBCGDad:aCols[nAt,nPZBCQtd] , TamSX3("ZBC_TOTAL")[2])
		EndIf
		// lTodos := (oZBCGDad:aCols[nAt,nPZBCQtd] > 0 .and. oZBCGDad:aCols[nAt,nPZBCPes] > 0 .and. oZBCGDad:aCols[nAt,nPZBCRen] > 0 .and. oZBCGDad:aCols[nAt,nPZBCArv] > 0 .and. oZBCGDad:aCols[nAt,nPZBCToI] > 0)
		
	ElseIf cCampo == 'ZBC_TEMFXA' // nPZBCTFX
		
		// ZBC_TEMFXA
		if M->ZCC_PAGFUT = 'N' .and. _cInfo = 'S'
			Alert('Registro não pode ter premiação quando o tipo de contrato não for pagamento futuro.')
			lRet := .F.
		endIf
		
	EndIf

	If lVld	
		// Preenchimento automatico de alguns campos
		// GdFieldPut( 'ZBC_X_CORR', M->ZCC_CODCOR )
		oZBCGDad:aCols[ nAt, nPZBCCor] := M->ZCC_CODCOR
		
		If M->ZCC_PAGFUT == "N" .AND. oZICGDad:aCols[ aScan( oZICGDad:aCols, {|x| AllTrim(x[nPZICIte])== cItemZIC }), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_TPNEG"}) ] == "P"
			// GdFieldPut( 'ZBC_ARROV', oZICGDad:aCols[ aScan( oZICGDad:aCols, {|x| AllTrim(x[nPZICIte])== cItemZIC }), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_VLAROB"}) ] )
			oZBCGDad:aCols[ nAt, nPZBCArv] := oZICGDad:aCols[ aScan( oZICGDad:aCols, {|x| AllTrim(x[nPZICIte])== cItemZIC }), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_VLAROB"}) ]
		EndIf
	EndIf
	oZBCGDad:Refresh()

Return lRet

/* MJ : 09.11.2017 */
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
				  " na tabela dos ITENS DO CONTRATO / COMISSÃO.", ;
				  {"Sair"} )
			lRet 	:= .F.
		EndIf
		
		If lRet
			For nI:=1 to Len(oZBCGDad:aCols)
				If !Empty( oZBCGDad:aCols[ nI, aScan( aZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEM"}) ] )
					If !oZICGDad:aCols[ Val( oZBCGDad:aCols[ nI, aScan( aZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEZIC"}) ] ), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_TPNEG"}) ] $ ("KQ") .and. ; 
						Empty( oZBCGDad:aCols[ nI, aScan( aZBCHead, {|x| AllTrim(x[2])=="ZBC_ARROV"}) ] ) .and. ;
						!Empty( oZBCGDad:aCols[ nI, aScan( aZBCHead, {|x| AllTrim(x[2])=="ZBC_QUANT"}) ] )
						
							Exit
					EndIf
				EndIf
			Next nI
			If nI <= Len(oZBCGDad:aCols)
				Aviso("Aviso", ;
					  "Valor de @ nao informado na linha: " + AllTrim(Str(nI)) + ;
					  " na tabela da CONFIGURAÇÃO DA BASE CONTRATUAL.", ;
					  {"Sair"} )
				lRet 	:= .F.
			EndIf
		EndIf
	EndIf
Return lRet

/* MJ : 13.11.2017 */
Static Function xAutoSC7()
Local aArea			:= GetArea()
Local lOk

if ZCC_STATUS=="A"
	if !msgYesNo("Esta operação bloqueará a edição do cabeçalho e itens, deseja continuar?")
		RestArea(aArea)
		return nil 
	else
		M->ZCC_STATUS := "N"
		
		recLock("ZCC")
		ZCC->ZCC_STATUS := "N"
		msUnlock()
		
		oMGet:Disable()
		oZICGDad:Disable()
	endIf
endIf

If M->ZCC_VERSAO != ZCC->ZCC_VERSAO // NOVA VERSAO
	Aviso("Aviso", "Não é permitido gerar pedidos durante o processo de geração de nova versão. Salve a edição e clique em Alterar para gerar pedidos.", {"Sair"} )
	RestArea(aArea)
	return nil 
EndIf

lOk := .T.
For nI := 1 to Len(oZBCGDad:aCols)
	If oZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
		if oZBCGDad:aCols[ nI, nPZBCQtd] = 0 .or. oZBCGDad:aCols[ nI, nPZBCTot] = 0  .or. empty(oZBCGDad:aCols[ nI, aScan( aZBCHead, { |x| AllTrim(x[2]) == "ZBC_CONDPA"  }) ])
			Alert("Existem campos obrigatórios não informados. Preencha-os antes de gerar o pedido.")
			RestArea(aArea)
			return nil 
		endIf
	EndIf
Next nI

// A parte abaixo foi copiada da funcao VldOk, foi retirado a parte que valida o tipo do Item na ZIC
For nI:=1 to Len(oZBCGDad:aCols)
	If !Empty( oZBCGDad:aCols[ nI, aScan( aZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEM"}) ] )
		If !oZICGDad:aCols[ Val( oZBCGDad:aCols[ nI, aScan( aZBCHead, {|x| AllTrim(x[2])=="ZBC_ITEZIC"}) ] ), aScan( aZICHead, {|x| AllTrim(x[2])=="ZIC_TPNEG"}) ] $ ("KQ") .and. ; 
		    Empty( oZBCGDad:aCols[ nI, aScan( aZBCHead, {|x| AllTrim(x[2])=="ZBC_ARROV"}) ] ) .and. ;
			!Empty( oZBCGDad:aCols[ nI, aScan( aZBCHead, {|x| AllTrim(x[2])=="ZBC_QUANT"}) ] )
			
				Exit
		EndIf
	EndIf
Next nI
If nI <= Len(oZBCGDad:aCols)
	Aviso("Aviso", ;
		  "Valor de @ nao informado na linha: " + AllTrim(Str(nI)) + ;
		  " na tabela da CONFIGURAÇÃO DA BASE CONTRATUAL." + CRLF + "Esta Operação sera cancelada.", ;
		  {"Sair"} )
	
	RestArea(aArea)
	return nil 
EndIf


// If Obrigatorio(aGets, aTela)
	Processa( { || xGeraSC7() }, 'Gerando Pedido de Compras', 'Aguarde ...', .F. )
// EndIf

RestArea(aArea)
Return nil 


/* MJ : 08.11.2017 */
Static Function M7GerarPrd(nPZIC, nPZBC)
Local aProd 		:= {} 
Local lRet			:= .T.
Local nI			:= nPZBC

// Local nPZIC		:= 0
// Local cCodigo 	:= "100007604" 

Private lMsErroAuto := .F. 

//Adicionado por Renato de Bianchi para identificar se deve gerar o BOV ou usar o produto da ZIC
if !(cFilAnt $ SuperGetMv("VA_FILGBOV",,"01"))
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+oZICGDad:aCols[ nPZIC, nPZICPrd])
	
	return .T.
endIf

/* For nI := 1 to Len(oZBCGDad:aCols)
	If oZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
		nPZIC := aScan( oZICGDad:aCols, {|x| AllTrim(x[nPZBCIte])== oZBCGDad:aCols[ nI, nPZBCZIC] })
		Exit
	EndIf
Next nI

If nI > Len(oZBCGDad:aCols)
	Alert('Não foi localizado Item selecionado na Base Contratual.')
	
Else */
	aAdd( aProd, {"B1_FILIAL"	, xFilial("SB1")	, nil }) 
	aAdd( aProd, {"B1_GRUPO"	, "BOV"				, nil }) 

	_cCodPrd	:= U_PROXSB1( "BOV" )
	aAdd( aProd, {"B1_COD"		, _cCodPrd			, nil }) 
	
	//_cPrdto := /* "[AUTO]: "+ */ 
	_cPrdto := RetField('SB1',1,xFilial('SB1')+oZICGDad:aCols[ nPZIC, nPZICPrd],'B1_DESC')
	aAdd( aProd, {"B1_DESC"		, _cPrdto			, nil }) 
	aAdd( aProd, {"B1_TIPO"		, "PA"				, nil }) 
	aAdd( aProd, {"B1_UM"		, "UN"				, nil }) 
	aAdd( aProd, {"B1_LOCPAD"	, "01"				, nil })
	aAdd( aProd, {"B1_CONTA"	, "1140200001"      , nil })
	aAdd( aProd, {"B1_POSIPI"	, GetMV("JR_POSIPI",,"01022919")        , nil })
	aAdd( aProd, {"B1_ORIGEM"	, "0"				, nil }) 
	aAdd( aProd, {"B1_X_TRATO"	, "2"				, nil }) 
	aAdd( aProd, {"B1_X_PRDES"	, "1"				, nil }) 
	aAdd( aProd, {"B1_PICM"		, 0					, nil }) 
	aAdd( aProd, {"B1_IPI"		, 0					, nil }) 
	aAdd( aProd, {"B1_CONTRAT"	, "N"				, nil }) 
	aAdd( aProd, {"B1_LOCALIZ"	, "N"				, nil }) 
	aAdd( aProd, {"B1_TE"		, GetMV("JR_M07TESC",,"005"), nil }) 
	// aAdd( aProd, {"B1_APROPRI"	, "D"				, nil }) 
	aAdd( aProd, {"B1_GRTRIB"	, "001"				, nil }) 
	aAdd( aProd, {"B1_CODBAR"	, "SEM GTIN" /* oZICGDad:aCols[ nPZIC, nPZICPrd] */, nil }) // SEM GTIN => layout 4.0
	aAdd( aProd, {"B1_TIPCAR"	, "005"				, nil }) 
	aAdd( aProd, {"B1_TPREG"	, "2"				, nil }) 

	//Encontra o B1_XANIMAL
	xAnimal := SB1->B1_XANIMAL
	
	aSexoX := { {"M", "MACHO"}, {"F", "FEMEA"} }
	aRacaX := { {"N", "NELORE"}, {"C", "CRUZAMENTO"}, {"M", "MESTICO"}, {"A", "ANGUS"} }	
	nPSexo   := aScan( aZICHead,  {|x| AllTrim(x[2])=="ZIC_SEXO"}) 
	nPRaca   := aScan( aZICHead,  {|x| AllTrim(x[2])=="ZIC_RACA"}) 
	cSexoX := AllTrim(aSexoX[aScan(aSexoX, {|x| x[1]==oZICGDad:aCols[ nPZIC, nPSexo]}),2])
	cRacaX := AllTrim(aRacaX[aScan(aRacaX, {|x| x[1]==oZICGDad:aCols[ nPZIC, nPRaca]}),2])
	cIdadX := AllTrim(SB1->B1_XIDADE) 
	
	//A=Angus;C=Cruzamento;M=Mestico;N=Nelore
	beginSQL alias "QRYA"
		%noParser%
		select Z09_CODIGO
		  from %table:Z09% Z09
		 where Z09_FILIAL=%xFilial:Z09% and Z09.%notDel%
		   and Z09_SEXO=%exp:cSexoX%
		   and Z09_RACA=%exp:cRacaX%
		   and %exp:cIdadX% between Z09_IDAINI and Z09_IDAFIM
	endSQL
	if !QRYA->(Eof())
		xAnimal := QRYA->Z09_CODIGO
	endIf
	QRYA->(dbCloseArea())
	
	// adicionais
	aAdd( aProd, {"B1_XPARCER"	, M->ZCC_PARCER					, nil })
	aAdd( aProd, {"B1_X_PESOC"	, oZBCGDad:aCols[ nI, nPZBCPes ], nil }) 
	aAdd( aProd, {"B1_X_RENDP"	, oZBCGDad:aCols[ nI, nPZBCReP ], nil }) 
	aAdd( aProd, {"B1_X_ARRON"	, oZBCGDad:aCols[ nI, nPZBCArv ], nil }) 
	aAdd( aProd, {"B1_X_TOICM"	, oZBCGDad:aCols[ nI, nPZBCToI ], nil }) 
	aAdd( aProd, {"B1_X_VLICM"	, oZBCGDad:aCols[ nI, nPZBCVLI ], nil }) 
	aAdd( aProd, {"B1_XIDADE"	, SB1->B1_XIDADE 			    , nil })
	aAdd( aProd, {"B1_CUSTD"	, SB1->B1_CUSTD 			    , nil }) 
	aAdd( aProd, {"B1_MCUSTD"	, "1"						    , nil }) 
	// MJ : 08.03.18
	aAdd( aProd, {"B1_X_CRED"	, SB1->B1_X_CRED 			    , nil }) 
	aAdd( aProd, {"B1_X_CUSTO"	, SB1->B1_X_CUSTO 			    , nil }) 
	aAdd( aProd, {"B1_X_DEBIT"	, SB1->B1_X_DEBIT 			    , nil }) 
	// -------------------------------------------------------------------------------------
	aAdd( aProd, {"B1_XANIMAL"	, xAnimal						, nil }) 
	aAdd( aProd, {"B1_X_COMIS"	, oZBCGDad:aCols[ nI, nPZBCVCM ], nil }) 
	aAdd( aProd, {"B1_XVLRPTA"	, oZBCGDad:aCols[ nI, nPZBCVPT ], nil }) 
	aAdd( aProd, {"B1_XALIICM"	, oZBCGDad:aCols[ nI, nPZBCAIC ], nil }) 
	aAdd( aProd, {"B1_XVICMPA"	, oZBCGDad:aCols[ nI, nPZBCICP ], nil }) 
	aAdd( aProd, {"B1_XCONTRA"	, M->ZCC_CODIGO					, nil })
	aAdd( aProd, {"B1_CONTSOC"	, 'S'							, nil }) 
	aAdd( aProd, {"B1_MSBLQL"	, "2"							, nil }) 

	if lRastro
		aAdd( aProd, {"B1_RASTRO"	, 'L'						, nil })
	endIf
	
	//FG_X3ORD("C", , aProd )

	lMsErroAuto := .F. 
	MSExecAuto({|x, y| MATA010(x, y)}, aProd, 3) 

	If lMsErroAuto
		MostraErro() 
		DisarmTransaction()
		lRet := .F.
	//Else 
		//Alert("Produto Incluido com sucesso!!!!") 
	EndIf
	
// EndIf
Return lRet

/* MJ : 08.11.2017 
	Alt. 31.01.2018 
		* Alterado formato do processamento do ExecAuto; 
		* Permissão para varios produtos por pedido;
	*/
Static Function xGeraSC7()
Local aArea			:= GetArea()

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
	For nI := 1 to Len(oZBCGDad:aCols)
		If oZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
			
			If Empty(ZBCCONDPA)
				ZBCCONDPA := oZBCGDad:aCols[ nI, aScan( aZBCHead, {|x| AllTrim(x[2])=="ZBC_CONDPA"}) ]
			EndIf
			
			// Criar Produto
			nPZIC := aScan( oZICGDad:aCols, {|x| AllTrim(x[nPZICIte])== oZBCGDad:aCols[ nI, nPZBCZIC] })
			If M7GerarPrd(nPZIC, nI)
				aItem := {}
				aAdd( aItem, { "C7_ITEM"   		, StrZero(Len(aItens)+1,TamSX3('C7_ITEM')[1]), nil } )
				
				aAdd( aItem, { "C7_PRODUTO"		, SB1->B1_COD				                 , nil } ) // aAdd( aItem, {	"C7_DESCRI"		, cDescrPrd		 			, nil  } )
				oZBCGDad:aCols[ nI, nPZBCPRD ] := SB1->B1_COD
				oZBCGDad:aCols[ nI, nPZBCDES ] := SB1->B1_DESC
				
				aAdd( aItem, { "C7_UM"			, "UN" 						                 , nil } )    
				aAdd( aItem, { "C7_LOCAL" 		, "01"   					                 , nil } )
				aAdd( aItem, { "C7_QUANT" 		, oZBCGDad:aCols[ nI, nPZBCQtd ]             , nil } )
				
				/* 
					* decido fazer a programacao para calcular na digitacao e atualizar o campo Preco Unit e Preco Total
					If oZBCGDad:aCols[ nI, nPZBCPdP ] == "P" // PESO
					aAdd( aItem, { "C7_PRECO" 		, oZBCGDad:aCols[ nI, nPZBCVPT ]             , nil } )
					aAdd( aItem, { "C7_TOTAL" 		, NoRound( oZBCGDad:aCols[ nI, nPZBCQtd ]*oZBCGDad:aCols[ nI, nPZBCVPT ], TamSX3("C7_TOTAL")[2] ), nil } )
				Else // NEGOCIAÇÃO */
					aAdd( aItem, { "C7_PRECO" 		, oZBCGDad:aCols[ nI, nPZBCPrc ]             , nil } )
					aAdd( aItem, { "C7_TOTAL" 		, oZBCGDad:aCols[ nI, nPZBCTot ]             , nil } )
				// EndIf

				aAdd( aItem, { "C7_TES" 		, GetMV("JR_M07TESC",,"005")                 , nil } )
				aAdd( aItem, { "C7_IPI" 		, 0  	   					                 , nil } )
				aAdd( aItem, { "C7_CC"   		, "" 						                 , nil } )         
				aAdd( aItem, { "C7_OBS" 		, oZBCGDad:aCols[ nI, nPZBCOBS ]             , nil } )
				aAdd( aItem, { "C7_OBSM" 		, oZBCGDad:aCols[ nI, nPZBCOBS ]             , nil } )
				aAdd( aItem, { "C7_CONTATO" 	, ""   						                 , nil } )
				aAdd( aItem, { "C7_EMISSAO"		, dDataBase              	                 , nil } )
				aAdd( aItem, { "C7_CONTA" 		, GetMV("JR_M07CNTA",,"1140200001")	         , nil } )
				aAdd( aItem, { "C7_MSG"   		, ""						                 , nil } )
				aAdd( aItem, { "C7_PICM"   		, 0							                 , nil } )     
				aAdd( aItem, { "C7_SEGURO"   	, 0							                 , nil } )
				aAdd( aItem, { "C7_DESPESA"   	, 0							                 , nil } )
				aAdd( aItem, { "C7_TXMOEDA"   	, 0							                 , nil } )     
				aAdd( aItem, { "C7_VALFRE"   	, 0							                 , nil } )
				aAdd( aItem, { "C7_BASESOL"   	, 0							                 , nil } )
				aAdd( aItem, { "C7_MOEDA"    	, 1							                 , nil } )         
				aAdd( aItem, { "C7_CONAPRO"    	, 'B'						                 , nil } )         
				
				// adicionais
				If !Empty(oZBCGDad:aCols[ nI, nPZBCPes ])
					aAdd( aItem, { "C7_X_PESO"    	, oZBCGDad:aCols[ nI, nPZBCPes ], nil  } )
				EndIf
				If !Empty(oZBCGDad:aCols[ nI, nPZBCRen ])
					aAdd( aItem, { "C7_X_REND"    	, oZBCGDad:aCols[ nI, nPZBCRen ], nil  } )
				EndIf
				If !Empty(oZBCGDad:aCols[ nI, nPZBCArv ])
					aAdd( aItem, { "C7_X_ARROV"     , oZBCGDad:aCols[ nI, nPZBCArv ], nil  } )
				EndIf
				If !Empty(oZBCGDad:aCols[ nI, nPZBCToI ])
					aAdd( aItem, { "C7_X_TOICM"     , oZBCGDad:aCols[ nI, nPZBCToI ], nil  } )
				EndIf
				If !Empty(oZBCGDad:aCols[ nI, nPZBCCor ])
					aAdd( aItem, { "C7_X_CORRE"     , oZBCGDad:aCols[ nI, nPZBCCor ], nil  } )
				EndIf
				If !Empty(oZBCGDad:aCols[ nI, nPZBCVCM ])
					aAdd( aItem, { "C7_X_COMIS"     , oZBCGDad:aCols[ nI, nPZBCVCM ], nil  } )			
				EndIf
				If !Empty(oZBCGDad:aCols[ nI, nPZBCXTT ])
					aAdd( aItem, { "C7_X_TOTAL"    	, oZBCGDad:aCols[ nI, nPZBCXTT ], nil  } )
				EndIf
				
				If Empty( dDtEntrega := oZBCGDad:aCols[ nI, nPZBCDTE ] )
					dDtEntrega := dDataBase
				EndIf
				aAdd( aItem, { "C7_DATPRF"      , dDtEntrega, nil  } )
				
				aAdd( aItens, aItem)
			Else
				aItens := {}
				Exit
			EndIf
		EndIf
	Next nI

	If Len(aItens) == 0
		Alert('Não foi localizado Item selecionado na Base Contratual.')
		
	Else
	
		cNumPc := U_ProxSC7_SC8()

		aAdd( aCab, { "C7_NUM"          , cNumPc					, nil  } )
		aAdd( aCab, { "C7_EMISSAO"      , dDataBase					, nil  } )
		aAdd( aCab, { "C7_FORNECE"      , M->ZCC_CODFOR				, nil  } )
		aAdd( aCab, { "C7_LOJA"         , M->ZCC_LOJFOR				, nil  } )
		aAdd( aCab, { "C7_COND"         , ZBCCONDPA 				, nil  } )
		aAdd( aCab, { "C7_FILENT"       , xFilial('SC7') 			, nil  } )     
		aAdd( aCab, { "C7_TXMOEDA"      , 0		   					, nil  } )
		aAdd( aCab, { "C7_CONTATO"      , "CONTRATO"				, nil  } )
		aAdd( aCab, { "C7_MOEDA"        , 1   						, nil  } )

		// FG_X3ORD("C", , aCab   )
		// FG_X3ORD("I", , aItens )

		lMsErroAuto := .F.                    
		MSExecAuto({|u,v,x,y| MATA120(u,v,x,y)}, 1, aCab, aItens, 3)
		If lErro := lMsErroAuto
			
			cErro := MostraErro()
			If lErro := !At("Deseja enviar email de aprovação para o aprovador?", cErro) > 0
		
				// lErro := .T.
				RollbackSX8()
				DisarmTransaction()
				
				For nI := 1 to Len(oZBCGDad:aCols) 
					If oZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
						oZBCGDad:aCols[ nI, nPZBCPRD ] := CriaVar('ZBC_PRODUT', .F.)
						oZBCGDad:aCols[ nI, nPZBCDES ] := CriaVar('ZBC_PRDDES', .F.)				
					EndIf
				Next nI
			EndIf
			
		EndIf
		If !lErro
			
			For nI := 1 to Len(oZBCGDad:aCols)
				If oZBCGDad:aCols[ nI, nPMrkZBC] == 'LBTIK'
					nPZIC := aScan( oZICGDad:aCols, {|x| AllTrim(x[nPZICIte])== oZBCGDad:aCols[ nI, nPZBCZIC] })
					
					SB1->( DbSetOrder(1) )
					If SB1->( DbSeek( xFilial('SB1')+oZBCGDad:aCols[ nI, nPZBCPRD ] ) )
						RecLock('SB1', .F.)
							SB1->B1_XLOTCOM := xFilial('SC7')+SC7->C7_NUM
						SB1->( MsUnlock() )
					EndIf
					
					//Atualizando ZIC
					oZICGDad:aCols[ nPZIC, nPZICQFc ] += oZBCGDad:aCols[ nI, nPZBCQtd ]
			
					// Atualizando ZBC
					oZBCGDad:aCols[ nI, nPZBCPed ] := SC7->C7_NUM
					
					nItem++
					oZBCGDad:aCols[ nI, nPZBCPIt ] := StrZero( nItem, TamSX3('C7_ITEM')[1] ) // SC7->C7_ITEM
					oZBCGDad:aCols[ nI, nPZBCPVs ] := "01"
					
					oZBCGDad:aCols[ nI, nPMrkZBC] := "LBNO"
				EndIf
			Next nI
	
			// Enviar Email somente qdo executado do ambiente de PRODUÇÃO
			If GetServerIP() == "192.168.0.243"
				U_ExecAutoOK( xFilial('SC7') + SC7->C7_NUM )
			EndIf
			
			//Adicionado por Renato de Bianchi
			//Verifica se já atendeu ao contrato completamente 
			if M->ZCC_QTDRES == 0
				nQtdAberto := 0
				For nJ := 1 to Len(oZBCGDad:aCols)
					If !oZBCGDad:aCols[nJ][ Len(oZBCGDad:aCols[1]) ] .and. Empty(oZBCGDad:aCols[ oZBCGDad:nAt, nPZBCPed ])
						nQtdAberto++
					EndIf
				Next i
				if nQtdAberto == 0
					if msgYesNo("A quantidade de animais foi atendida totalmente, deseja encerrar este contrato?")
						cTxt := " "
						if !empty(AllTrim(M->ZCC_OBS))
							cTxt += AllTrim(M->ZCC_OBS) +chr(10)+chr(13)+chr(10)+chr(13)
						endIf
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
						msUnLock()
					endIf
				endIf
			endIf
			// Fim das alterações
			GrvTable()
			
			SC7->( ConfirmSX8() )
			// DisarmTransaction() // esta funcao precisa ser retirada daqui, somente para DESENVOLVIMENTO;
								// ambiente de desenvolvimento INOPERANTE;
			
			oZBCGDad:Refresh()
		
		EndIf
	EndIf
End Transaction

RestArea(aArea)

Return lErro

/* MJ : 17.11.2017
	# Separei em Funcao, para chamar para gravar as tabelas após oBrowse
		ExecAuto
	*/
Static Function GrvTable()
Local nI 		:= 0
Local lRecLock	:= .T.
    
	// Salvar contrato
	RecLock( "ZCC", .F. )
		U_GrvCpo("ZCC")				
	ZCC->(MsUnlock())

	/// Tabela 1 - Meio Esquerda
	For nI := 1 to Len(oZICGDad:aCols)
		If !oZICGDad:aCols[nI][ Len(oZICGDad:aCols[1]) ] .AND. !Empty( oZICGDad:aCols[ 1,2] )
			DbSelectArea( "ZIC" )
			ZIC->( DbSetOrder( 1 ) )
			RecLock( "ZIC", lRecLock := !DbSeek( xFilial("ZIC") + M->ZCC_CODIGO + M->ZCC_VERSAO + oZICGDad:aCols[nI, nPZICIte] ) )
				U_GrvCpo( "ZIC", oZICGDad:aCols, oZICGDad:aHeader, nI )
				If lRecLock
					ZIC->ZIC_FILIAL := xFilial("ZIC")
					ZIC->ZIC_CODIGO := M->ZCC_CODIGO
					ZIC->ZIC_VERSAO := M->ZCC_VERSAO
				EndIf
			ZIC->( MsUnlock() )
		EndIf
	Next i
	
	/// Tabela 2 - Rodapé
	For nI := 1 to Len(oZBCGDad:aCols)
		If !oZBCGDad:aCols[nI][ Len(oZBCGDad:aCols[1]) ] ;
				.AND. !Empty( oZBCGDad:aCols[ nI, nPZBCITE ] ) ;
				.AND. !Empty( oZBCGDad:aCols[ nI, nPZBCZIC ] ) 
				
			DbSelectArea( "ZBC" )
			ZBC->( DbSetOrder( 1 ) )
			RecLock( "ZBC", lRecLock := !DbSeek( xFilial("ZBC") + M->ZCC_CODIGO + M->ZCC_VERSAO + oZBCGDad:aCols[nI, nPZBCITE] /* + oZBCGDad:aCols[nI, nPZBCZIC] + oZBCGDad:aCols[nI, nPZBCPed] + oZBCGDad:aCols[nI, nPZBCPIt] + oZBCGDad:aCols[nI, nPZBCPVs] */ ) )
				U_GrvCpo( "ZBC", oZBCGDad:aCols, oZBCGDad:aHeader, nI )
				If lRecLock
					ZBC->ZBC_FILIAL := xFilial("ZBC")
					ZBC->ZBC_CODIGO := M->ZCC_CODIGO
					ZBC->ZBC_VERSAO := M->ZCC_VERSAO
					ZBC->ZBC_CODFOR := M->ZCC_CODFOR
					ZBC->ZBC_LOJFOR := M->ZCC_LOJFOR
					ZBC->ZBC_USUARI := cUserName
					ZBC->ZBC_DTALT  := Date()
				EndIf
			ZBC->( MsUnlock() )
		EndIf
	Next i

	// /// Tabela 3 - Meio Direita
	// For nI := 1 to Len(oZFXGDad:aCols)
		// If oZFXGDad:aCols[nI][ Len(oZFXGDad:aCols[1]) ] .AND. !Empty( oZFXGDad:aCols[ 1,2] )
			// DbSelectArea( "ZFX" )
			// ZFX->( DbSetOrder( 1 ) )
			// If ZFX->( DbSeek( xFilial("ZFX") + oZFXGDad:aCols[nI, nPZFXCod] + StrZero( nI, TamSX3('ZFX_ITEM')[1]) ) )
				// RecLock( "ZFX", .F.)
					// ZFX->( DbDelete() )
				// ZFX->( MsUnlock() )
			// EndIf
		// EndIf
	// Next i
	
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
			ZCC->(MsUnlock())
		EndIf
	next nI
RestArea(aArea)
Return nil 


/* MJ : 20.11.2017
	Validar Sexo informado x selecionado na tabela ZIC;
	*/
User Function icProdVld()
Local lRet := .F.

SB1->(DbSetOrder(1))
If SB1->(DbSeek( xFilial('SB1')+ &(ReadVar()) ))
	If SubS(SB1->B1_X_SEXO,1,1) == oZICGDad:aCols[oZICGDad:nAt, nPZICSxo]
		lRet := .T.
	Else
		Aviso("Aviso", ;
			  "O Produto informado: " + AllTrim(&(READVAR())) +": "+ AllTrim(SB1->B1_DESC)+ ;
			  " não é do sexo informado nesta configuração.", ;
			  {"Sair"} )
	EndIf
EndIf
Return lRet


/* ===================================================================== */
/* MJ : 27.11.2017 */
/* ===================================================================== */
User Function ExecAutoOK( cChave )
Local aAnexo    := {}
Local aPara	    := {}
Local cPara     := ""
Local cQuery	:= ""
Local xHTM 	  	:= ""
Local cTelEmp 	:= "("+Substr(SM0->M0_TEL,4,2)  +;
				   ") "+Substr(SM0->M0_TEL,7,4) +;
				   "-"+Substr(SM0->M0_TEL,11,4)

Local cJobChv	:= 'JOB03' 	// codigo da chave na tabela da sx5, pra incluir emails para envio do job
Local cJobSX5	:= 'Z2'		// tabela da SX5 onde serao selecionados os emails para envio

Local C7XCOMIS  := 0
Local C7QUANT   := 0
Local C7XPESO   := 0
Local C7XTOTAL  := 0
Local C7XTOICM  := 0
Local C7TOTGERAL := 0

Local JOBMAIL   := CriaTrab(,.F.)   

DbSelectArea('SC7')
SC7->(DbSetOrder(1))

if xFilial('SC7')+SC7->C7_NUM+SC7->C7_ITEM <> cChave + StrZero( 1, TamSX3('C7_ITEM')[1] )
	SC7->(DbSeek(cChave))
Endif

xHTM := '<HTML><BODY>' + CRLF
xHTM += '<hr>' + CRLF
xHTM += '<p  style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">' + CRLF
xHTM += '<b><font face="Verdana" SIZE=3>' + SM0->M0_NOMECOM + '</b></p>' + CRLF
xHTM += '<br>' + CRLF
xHTM += '<font face="Verdana" SIZE=3>' + AllTrim( SM0->M0_ENDENT )+" - "+AllTrim(SM0->M0_BAIRENT)+" - CEP: "+AllTrim(SM0->M0_CEPENT)+" - Fone/Fax: "+ cTelEmp + '</p>' + CRLF
xHTM += '<hr>' + CRLF
xHTM += '<b><font face="Verdana" SIZE=3>Inclusao de Pedido de Compra: ' + SC7->C7_FILIAL+"-"+SC7->C7_NUM +'</b></p>' + CRLF
xHTM += '<hr>' + CRLF
xHTM += '<font face="Verdana" SIZE=1>* * *  com base no campo data de entrega no item do pedido de compras (somente liberados) * * *</p>' + CRLF
xHTM += '<br>' + CRLF
xHTM += '<font face="Verdana" SIZE=3>Data: ' + dtoc(date()) + ' Hora: ' + time() + '</p>' + CRLF
xHTM += '<br>' + CRLF
xHTM += '<br>' + CRLF
xHTM += '<b><font face="Verdana" SIZE=1>' + CRLF
// Cabecalho Pedido
xHTM += '<table BORDER=1>' + CRLF
xHTM += '<tr BGCOLOR=#2F4F4F >' + CRLF
xHTM += '<td><b><font color=#F5F5F5>Filial</b></font></td>' + CRLF
xHTM += '<td><b><font color=#F5F5F5>Pedido</b></font></td>' + CRLF
xHTM += '<td><b><font color=#F5F5F5>Emissao</b></font></td>' + CRLF
xHTM += '<td><b><font color=#F5F5F5>Fornecedor</b></font></td>' + CRLF
xHTM += '<td><b><font color=#F5F5F5>Municipio/UF</b></font></td>' + CRLF
xHTM += '<td><b><font color=#F5F5F5>Corretor</b></font></td>' + CRLF
xHTM += '</tr>'	 + CRLF

xHTM += '<tr>' + CRLF
xHTM += '<td>' + SC7->C7_FILIAL+'</td>' + CRLF
xHTM += '<td>' + SC7->C7_NUM+'</td>' + CRLF
xHTM += '<td>' + DtoC(SC7->C7_EMISSAO)+'</td>' + CRLF
xHTM += '<td align=left>' + SC7->C7_FORNECE+"-"+SC7->C7_LOJA+": "+AllTrim(Posicione('SA2',1, xFilial('SA2')+SC7->C7_FORNECE+SC7->C7_LOJA, 'A2_NOME' )) + '</td>' + CRLF
xHTM += '<td align=left>' + AllTrim(SA2->A2_MUN) + "-" + SA2->A2_EST + '</td>' + CRLF
xHTM += '<td align=left>' + AllTrim(Posicione('SA3',1, xFilial('SA3')+SC7->C7_X_CORRE, 'A3_NOME' )) + '</td>' + CRLF
xHTM += '</tr>'	 + CRLF
// cC7Obs		:= 	u_SC7OBS(SC7->C7_FILIAL, SC7->C7_NUM)

cC7Obs		:= 	M->ZCC_OBS
If !Empty(cC7Obs)
	xHTM += '<tr>' + CRLF
	xHTM += '<font face="Arial" SIZE=3> <td colspan=6><br>' + cC7Obs+'<br><br> </td>' + CRLF
	xHTM += '</tr>'	 + CRLF
Endif

xHTM += '</table>' + CRLF

xHTM += '<b><font face="Verdana" SIZE=1>' + CRLF
xHTM += '<table BORDER=1>' + CRLF
xHTM += '<tr BGCOLOR=#778899 >' + CRLF
xHTM += '<td><b><font color=#F5F5F5>Item/Produto</b></font></td>' + CRLF
xHTM += '<td><b><font color=#F5F5F5>Valor Comissao</b></font></td>' + CRLF
xHTM += '<td><b><font color=#F5F5F5>Quantidade</b></font></td>' + CRLF
xHTM += '<td><b><font color=#F5F5F5>Peso Negociação</b></font></td>' + CRLF
xHTM += '<td><b><font color=#F5F5F5>Peso Médio</b></font></td>' + CRLF
xHTM += '<td><b><font color=#F5F5F5>R$ / @</b></font></td>' + CRLF
xHTM += '<td><b><font color=#F5F5F5>% Rendimento</b></font></td>' + CRLF
xHTM += '<td><b><font color=#F5F5F5>Total sem Icms</b></font></td>' + CRLF
xHTM += '<td><b><font color=#F5F5F5>Total ICMS</b></font></td>' + CRLF
xHTM += '<td><b><font color=#F5F5F5>Total com ICMS + Comissao</b></font></td>' + CRLF
xHTM += '<td><b><font color=#F5F5F5>Previsao Entrega</b></font></td>' + CRLF
xHTM += '<td><b><font color=#F5F5F5>Dias</b></font></td>' + CRLF
xHTM += '<td><b><font color=#F5F5F5>Obs</b></font></td>' + CRLF
xHTM += '</tr>'	 + CRLF


While !SC7->(Eof()) .and. xFilial('SC7')+SC7->C7_NUM == cChave
	
	xHTM += '<tr>' + CRLF
	xHTM += '<td>' + AllTrim(SC7->C7_DESCRI)+'</td>' + CRLF
	C7XCOMIS 	+= SC7->C7_X_COMIS
	xHTM += '<td align=right>' + Transform(SC7->C7_X_COMIS,"@E 999,999,999.999")+'</td>' + CRLF
	C7QUANT		+= SC7->C7_QUANT
	xHTM += '<td align=right>' + Transform(SC7->C7_QUANT,"@E 999,999,999.999")+'</td>' + CRLF
	C7XPESO		+= SC7->C7_X_PESO
	xHTM += '<td align=right>' + Transform(SC7->C7_X_PESO,"@E 999,999,999.999")+'</td>' + CRLF
	xHTM += '<td align=right>' + Transform(Round( SC7->C7_X_PESO/SC7->C7_QUANT, TamSX3("C7_X_PESO")[2]),"@E 999,999.999")+'</td>' + CRLF
	xHTM += '<td align=right>' + Transform(SC7->C7_X_ARROV,"@E 999,999,999.999")+'</td>' + CRLF
	xHTM += '<td align=right>' + Transform(SC7->C7_X_REND,"@E 999,999,999.999")+'</td>' + CRLF
	C7XTOTAL 	+= SC7->C7_X_TOTAL
	xHTM += '<td align=right>' + Transform(SC7->C7_X_TOTAL,"@E 999,999,999.99")+'</td>' + CRLF
	C7XTOICM	+= SC7->C7_X_TOICM
	xHTM += '<td align=right>' + Transform(SC7->C7_X_TOICM,"@E 999,999,999.99")+'</td>' + CRLF
	C7TOTGERAL	+= SC7->C7_X_TOTAL + SC7->C7_X_TOICM + SC7->C7_X_COMIS
	xHTM += '<td  align=right>' + Transform(SC7->C7_X_TOTAL+SC7->C7_X_TOICM+SC7->C7_X_COMIS,"@E 999,999,999.99")+'</td>'	 + CRLF
	xHTM += '<td>' + dToC(SC7->C7_DATPRF)+'</td>' + CRLF
	xHTM += '<td align=right>' + Transform((SC7->C7_DATPRF - DATE()) ,"@E 999,999")+'</td>' + CRLF
	xHTM += '<td align=right>' + SC7->C7_OBS +'</td>' + CRLF
	xHTM += '</tr>'	 + CRLF
	
	SC7->( DbSkip())
EndDo

xHTM += '<tr BGCOLOR=#CFCFCF >' + CRLF // gray 81
xHTM += '<td><b>Sub-Total Pedido: ' + cChave +'</b></td>' + CRLF
xHTM += '<td align=right><b>' + Transform( C7XCOMIS, "@E 999,999,999.99")+'</b></td>' + CRLF
xHTM += '<td align=right><b>' + Transform( C7QUANT , "@E 999,999,999.99")+'</b></td>' + CRLF
xHTM += '<td align=right><b>' + Transform( C7XPESO , "@E 999,999,999")+'</b></td>' + CRLF
xHTM += '<td align=right><b> </b></td>' + CRLF
xHTM += '<td align=right><b> </b></td>' + CRLF
xHTM += '<td align=right><b> </b></td>' + CRLF
xHTM += '<td align=right><b>' + Transform( C7XTOTAL, "@E 999,999,999.99")+'</b></td>' + CRLF
xHTM += '<td align=right><b>' + Transform( C7XTOICM,"@E 999,999,999.99")+'</b></td>' + CRLF
xHTM += '<td align=right><b>' + Transform( C7TOTGERAL,"@E 999,999,999.99")+'</b></td>' + CRLF
xHTM += '<td colspan="3" align=left>_</td>' + CRLF
xHTM += '</tr>'	 + CRLF

xHTM += '</table>' + CRLF// fim da tabela de pedidos 
xHTM += '<br>' + CRLF
xHTM += '<br>' + CRLF
xHTM += '<br>' + CRLF
xHTM += '</BODY></HTML>' + CRLF

MemoWrite( "C:\totvs_relatorios\VACOMM07_" + cChave + ".html", xHTM )

cAssunto := "Contrato: " + M->ZCC_CODIGO + " - Pedido de compra: " + cChave
aAdd( aAnexo, { "LogoTipo", "\workflow\images\logoM.jpg" } )

// cCopia  := "financeiro@vistaalegre.agr.br"
cQuery := " SELECT X5_CHAVE, X5_DESCRI "
cQuery += " FROM "+RetSqlName('SX5')+" SX5 "
cQuery += " WHERE X5_TABELA = '"+cJobSX5+"' "
cQuery += " AND SUBSTRING(X5_CHAVE,1,5)  = '"+cJobChv+"'  "
cQuery += " AND D_E_L_E_T_<>'*' "  
cQuery += " ORDER BY X5_CHAVE "  

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, cQuery ),(JOBMAIL),.F.,.F.)

xEmail := ""
While !(JOBMAIL)->(Eof())
	
	xEmail  += Iif(Empty(xEmail),"",", ") + alltrim(lower( (JOBMAIL)->X5_DESCRI)) 
	
	(JOBMAIL)->(dbSkip())
EndDo

If !Empty(xEmail)
	ConOut("VACOMM07: Para: "+ xEmail )
	Processa({ || u_EnvMail( Lower(xEmail)	   ,;			
		             /* cCopia */ 	           ,;			
		             ""				           ,;			
		             cAssunto			       ,;			
		             aAnexo 		           ,;		
		             xHTM			           ,;			
		             .T.)},"Enviando e-mail...")	
EndIf

(JOBMAIL)->(dbCloseArea())

Return nil 


/* ===================================================================== */
/* MJ : 21.11.2017 */
/* ===================================================================== */
// User Function V1ExecAutoOK( cChave )
// Local aAnexo := {}
// Local aPara	 := {}
// Local cPara  := ""
// 
// DbSelectArea('SC7')
// SC7->(DbSetOrder(1))
// 
// if xFilial('SC7')+SC7->C7_NUM+SC7->C7_ITEM <> cChave
// 	SC7->(DbSeek(cChave))
// Endif
// 
// xHTM := MemoRead("\workflow\template\PedidoCompraOK.htm")
// xHTM := StrTran(xHTM, "{%NUMPDC%}"			, SC7->C7_NUM )
// xHTM := StrTran(xHTM, "{%M0_NOMECOM%}"		, SM0->M0_NOMECOM )
// xHTM := StrTran(xHTM, "{%M0_ENDENT%}"		, AllTrim( SM0->M0_ENDENT ) )
// xHTM := StrTran(xHTM, "{%M0_BAIRENT%}"		, AllTrim(SM0->M0_BAIRENT) )
// xHTM := StrTran(xHTM, "{%M0_CEPENT%}"		, AllTrim(SM0->M0_CEPENT) )
// xHTM := StrTran(xHTM, "{%M0_TEL%}"			, "("+Substr(SM0->M0_TEL,4,2)  +;
// 													  ") "+Substr(SM0->M0_TEL,7,4) +;
// 													  "-"+Substr(SM0->M0_TEL,11,4) )
// xHTM := StrTran(xHTM, "{%DATAATUAL%}"		, dtoc(date()) )
// xHTM := StrTran(xHTM, "{%HORAATUAL%}"		, time() )
// 
// xHTM := StrTran(xHTM, "{%DATAENTREGA%}"		, dToC(SC7->C7_DATPRF) )
// 
// xHTM := StrTran(xHTM, "{%FORNECEDOR%}"	    , SC7->C7_FORNECE+"-"+SC7->C7_LOJA+": "+Posicione('SA2',1, xFilial('SA2')+SC7->C7_FORNECE+SC7->C7_LOJA, 'A2_NOME' ) )
// xHTM := StrTran(xHTM, "{%CIDADEFORNECEDOR%}", AllTrim(SA2->A2_MUN)+"/"+SA2->A2_EST )
// xHTM := StrTran(xHTM, "{%CORRETOR%}"		, AllTrim(M->ZCC_CODCOR)+": "+M->ZCC_NOMCOR )
// 
// xHTM := StrTran(xHTM, "{%FILIAL%}"			, SC7->C7_FILIAL+"-"+SC7->C7_NUM )
// xHTM := StrTran(xHTM, "{%ITEM%}"			, SC7->C7_ITEM 					 )
// xHTM := StrTran(xHTM, "{%PRODUTO%}"			, SC7->C7_PRODUTO+": "+Posicione('SB1',1, xFilial('SB1') + SC7->C7_PRODUTO, 'B1_DESC' ) )
// xHTM := StrTran(xHTM, "{%QUANT%}"			, Transform( SC7->C7_QUANT , X3Picture('C7_QUANT') ) )
// xHTM := StrTran(xHTM, "{%PRECO%}"			, Transform( SC7->C7_PRECO , X3Picture('C7_PRECO') ) )
// xHTM := StrTran(xHTM, "{%TOTAL%}"			, Transform( SC7->C7_TOTAL , X3Picture('C7_TOTAL') ) )
// 
// xHTM := StrTran(xHTM, "{%C7_X_TOICM%}"		, Transform( SC7->C7_X_TOICM , X3Picture('C7_X_TOICM') ) )
// xHTM := StrTran(xHTM, "{%C7_X_TOTAL%}"		, Transform( SC7->C7_X_TOTAL , X3Picture('C7_X_TOTAL') ) )
// 
// xHTM := StrTran(xHTM, "{%PESO%}"			, Transform( SC7->C7_X_PESO, X3Picture('C7_X_PESO') ) )
// xHTM := StrTran(xHTM, "{%RENDIMENTO%}"		, Transform( SC7->C7_X_REND, X3Picture('C7_X_REND') ) )
// 
// cAssunto := "Pedido de compra: " + SC7->C7_FILIAL+"-"+SC7->C7_NUM
// 
// // cCopia  := "financeiro@vistaalegre.agr.br"
// cPara := ""
// aPara := StrTokArr( GetMV("MV_MAILPED",,  "arthur.toshio@vistaalegre.agr.br" ), ";")
// For nI := 1 to Len(aPara)
// 	If !Empty(cMail := Posicione( 'SX5', 1, xFilial('SX5')+'Z2' + aPara[nI], 'X5_DESCRI' ))
// 		cPara += Iif(Empty(cPara), "", ", ") + AllTrim(cMail)
// 	EndIf
// Next nI
// // cPara := "miguel@martinsbernardo.com.br"
// aAdd( aAnexo, { "logo.jpg", "\workflow\images\logo.jpg" } )
// ConOut("Para: "+ xEmail )
// MemoWrite( "D:\_TMP_\VACOMM07.html", xHTM )
// 				
// Processa({ || u_EnvMail( Lower(cPara)	           ,;			
// 			             /* cCopia */ 	           ,;			
// 			             ""				           ,;			
// 			             cAssunto			       ,;			
// 			             aAnexo 		           ,;		
// 			             xHTM			       ,;			
// 			             .T.)},"Enviando e-mail...")	
// 	
// Return nil 


/*
Função adicionada por Renato de Bianchi
Valida a quantidade de animais para não permitir reduzir seu valor abaixo da somatória de pedidos gerados
*/
user function vlZCCQtA()
local lRet := .T.
local nQtdUsada := 0

	//Valida a quantidade em relacao aos itens
	For nI := 1 to Len(oZICGDad:aCols)
		If !oZICGDad:aCols[nI][ Len(oZICGDad:aCols[1]) ] .AND. !Empty( oZICGDad:aCols[ 1,2] )
			nQtdUsada += oZICGDad:aCols[nI, nPZICQtd]
		EndIf
	Next i	
	if M->ZCC_QTTTAN < nQtdUsada
		lRet := .F.
		Alert("Quantidade informada é menor que a quantidade dos itens.")
	endIf
	
	//Define a quantidade restante (ZCC_QTDRES)
	if lRet
		nQtdUsada := 0
		For nI := 1 to Len(oZBCGDad:aCols)
			If !oZBCGDad:aCols[nI][ Len(oZBCGDad:aCols[1]) ]
				nQtdUsada += oZBCGDad:aCols[nI, nPZBCQtd]
			EndIf
		Next i
		M->ZCC_QTDRES := M->ZCC_QTTTAN - nQtdUsada
	endIf
	
return lRet


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
	Alert('Não é possível alterar contratos cancelados ou fechados.')
	return .F.
endIf

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
		endIf
		
		QRYTMP->(dbSkip())
	endDo
endIf
QRYTMP->(dbCloseArea())

lConfExc := .F.

if len(aPeds) > 0
	if !msgYesNo("O contrato atual possui pedidos de compra gerados em aberto, deseja continuar?")
		return .F.
	else
		lConfExc := .T.
	endIf
endIf

	DEFINE MSDIALOG oDlgTmp TITLE OemToAnsi(cTitDlg) From 05,10 TO 262,620	PIXEL STYLE nOR( WS_VISIBLE ,DS_MODALFRAME ) 
   		oDlgTmp:lEscClose := .F.
	
		@  2,4 TO 25,302 LABEL "Informações do Contrato" OF oDlgTmp PIXEL
	
		@ 10,07 SAY "Contrato: "+ZCC->ZCC_CODIGO  SIZE  150,8 OF oDlgTmp PIXEL 
		@ 10,90 SAY "Versão: "+ZCC->ZCC_VERSAO  SIZE  150,8 OF oDlgTmp PIXEL
		@ 16,07 SAY "Fornecedor: "+ZCC->ZCC_CODFOR+"/"+ZCC->ZCC_LOJFOR+" - "+ZCC->ZCC_NOMFOR SIZE  250,8 OF oDlgTmp PIXEL
	
		@ 26,4 TO 111,302 LABEL "Motivo do " + cTitDlg OF oDlgTmp PIXEL //"Descri‡ao do Encerramento" 
		@ 35,8 GET oMotivo VAR cMotivo OF oDlgTmp MEMO SIZE 290,70 PIXEL //When lHabil
		oMotivo:oFont := oMonoAs
	
	DEFINE SBUTTON FROM 115,230 TYPE 2 ACTION (lRet:=.F., oDlgTmp:End()) ENABLE OF oDlgTmp
	DEFINE SBUTTON FROM 115,270 TYPE 1 ACTION (lRet:=.T., oDlgTmp:End()) ENABLE OF oDlgTmp
	
	ACTIVATE MSDIALOG oDlgTmp CENTER
	
	if lRet
		if msgYesNo("O contrato não poderá ser alterado após esta operação, deseja continuar?")
			cTxt := " "
			if !empty(AllTrim(ZCC->ZCC_OBS))
				cTxt += AllTrim(ZCC->ZCC_OBS) +chr(10)+chr(13)+chr(10)+chr(13)
			endIf
			cTxt += "**********"+upper(cTitDlg)+"**********" +chr(10)+chr(13)
			cTxt += "*DATA: "+dToC(date()) +chr(10)+chr(13)
			cTxt += "*OPERADOR: "+AllTrim(__cUserId) + " - " + AllTrim(UsrRetName(__cUserId)) +chr(10)+chr(13)
			if lConfExc .and. cStatus="C"
				cTxt += "**EXCLUSAO DE PEDIDOS - Usuario confirmou a exclusao dos pedidos em aberto**" +chr(10)+chr(13)
			endIf
			if lConfExc .and. cStatus="F"
				cTxt += "**Usuario confirmou o encerramento parcial do contrato que possui pedidos em aberto**" +chr(10)+chr(13)
			endIf
			cTxt += padr('*',60,'*')+chr(10)+chr(13)
			cTxt += cMotivo
			
			if cStatus="F" .and. (lConfExc .or. ZCC->ZCC_QTDRES > 0)
				cStatus := "P"
			endIf
			
			RecLock('ZCC', .F.)
			ZCC->ZCC_STATUS := cStatus
			ZCC->ZCC_OBS := cTxt
			msUnLock()
			
			if cStatus="C" .and. len(aPeds) > 0 .and. lConfExc
				for nI := 1 to len(aPeds)
					u_xElResPC(aPeds[nI])
				next
			endIf
		endIf
	endIf
	
Return nil 

//Validação da exclusão da linha da base contratual (Pedido)
user function ZBCDelOk()
Local lRet     := .T.
Local nI 	   :=  0
Local nAt      := oZBCGDad:oBrowse:nAt
Local nTotQtde := 0
Local lTodos   := .F. 
Local nPZIC    := 0
Local nAux	   := 0
Local lMark

if !empty(oZBCGDad:aCols[nAt, nPZBCPed])
	Alert("Não é possível deletar um registro com pedido já gerado")
	return .F.
endIf

return lRet

//Validação da exclusão da linha da base contratual (Pedido)
user function ZICDelOk()
Local lRet     := .T.
Local nI 	   :=  0
Local nAt      := oZICGDad:oBrowse:nAt
Local nTotQtde := 0
Local lTodos   := .F. 
Local nPZIC    := 0
Local nAux	   := 0
Local lMark
Local nInd := Len(oZICGDad:aCols[1])
Local nInd2 := Len(oZBCGDad:aCols[1])

if valtype(oZICGDad:aCols[nAt][ nInd ]) != "L"
	nInd++
endIf

if valtype(oZBCGDad:aCols[1][nInd2]) != "L"
	nInd2++
endIf

if oZICGDad:aCols[nAt][nInd]
	return .T.
endIf

For nI := 1 to Len(oZBCGDad:aCols)
	If !oZBCGDad:aCols[nI][nInd2] .and. oZBCGDad:aCols[nI, nPZBCZIC] = oZICGDad:aCols[nAt, nPZICITE]
		Alert("Não é possível deletar um registro que possua bases contratuais informadas.")
		return .F.
	EndIf
Next i

return lRet

/* MJ : 24.01.2018 */
Static Function fCanSelIC()
Local lRet := .T.

	If !( lRet := !Empty( oZICGDad:aCols[ oZICGDad:oBrowse:nAt, nPZICSxo] ) )
		Alert('O campo sexo não informado, por isso o item nao poderá ser selecionado.')

	ElseIf !( lRet := !Empty( oZICGDad:aCols[ oZICGDad:oBrowse:nAt, nPZICPrd] ) )
		Alert('Produto não informada, por isso o item nao poderá ser selecionado.')
	
	ElseIf !( lRet := !Empty( oZICGDad:aCols[ oZICGDad:oBrowse:nAt, nPZICQtd] ) )
		Alert('Quantidade não informada, por isso o item nao poderá ser selecionado.')
		
	EndIf
	
return lRet

/* MJ : 24.01.2018 */
Static Function fCanSelBC()
Local lRet := .T.

	If !( lRet := !Empty( oZBCGDad:aCols[ oZBCGDad:oBrowse:nAt, nPZBCQtd ] ) )
		Alert('Quantidade não informada, por isso o item nao poderá ser selecionado.')
	
	ElseIf !( lRet := Empty( oZBCGDad:aCols[ oZBCGDad:oBrowse:nAt, nPZBCPed ] ) )
		MsgInfo("O Pedido de Compra: <b>" + AllTrim( oZBCGDad:aCols[ oZBCGDad:oBrowse:nAt, nPZBCPed]) + ;
			  "</b> ja se encontra vinculada na linha: <b>" + AllTrim(Str( oZBCGDad:oBrowse:nAt)) + "</b>", 'Aviso')
	EndIf
	
return lRet


/* 
	MJ : 06.02.2018
		# Processar codigo do pedido de compra. 
	
	* // http://www.blacktdn.com.br/2012/05/para-quem-precisar-desenvolver-uma.html
*/
User Function xFiltroConsulta() // U_xFiltroConsulta()
Local lRet 		:= .F.
Local cLoad     := ProcName(1) // Nome do perfil se caso for carregar
Local lCanSave  := .T. // Salvar os dados informados nos parâmetros por perfil
Local lUserSave := .T. // Configuração por usuário
Local aParamBox := {}
Local aRet 		:= {}
Local nOpc		:= 4

aAdd(aParamBox,{9 , "Informe o número do pedido de compras: ",150,7,.T.})
aAdd(aParamBox,{1 , "Pedido de Compra", Space(TamSX3("C7_NUM")[1]), "","","SC7","",0,.T.}) // Tipo caractere

If ParamBox(aParamBox,"Parâmetros...",@aRet, /* [ bOk ] */, /* [ aButtons ] */, /* [ lCentered ] */, /* [ nPosX ] */, /* [ nPosy ] */, /* [ oDlgWizard ] */,  cLoad, lCanSave, lUserSave )
	if !Empty(aRet[2])

		ZCC->(DbSetOrder(1))
		If ZCC->(DbSeek( xFilial('ZCC') + Posicione('ZBC',2,xFilial('ZBC')+aRet[2], 'ZBC_CODIGO') ))
		
			If ZCC->ZCC_STATUS == "C"
				Aviso("Aviso", 'O contrato encontra-se cancelado e por esse motivo sera aberto como visualização.', {"Sair"})
				nOpc := 2
			ElseIf ZCC->ZCC_STATUS$"FP"
				Aviso("Aviso", 'O contrato encontra-se finalizado e por esse motivo sera aberto como visualização.', {"Sair"})
				nOpc := 2
			EndIf
		
			FWMsgRun(, {|| U_COMM07VA( 'ZCC', ZCC->(Recno()), nOpc) }, 'Processando Filtro','Abrindo contrato, Por Favor Aguarde...')	
		EndIf
	
	EndIf
EndIf
Return lRet

/*
Desenver Tela para levantar Nro do pedido;
e retornar para o filtro;
Filtro customizado, por Funcao customizada

ZCC_CODIGO == POSICIONE('ZBC', 2, XFILIAL('ZBC')+ '%ZBC_PEDIDO0%', 'ZBC_CODIGO')
POSICIONE('ZBC', 2, XFILIAL('ZBC')+'%ZBC_PEDIDO0%', 'ZBC_CODIGO') $ ZCC->ZCC_CODIGO
*/


// MJ : 16.02.2018
User Function TemPauta()
Local aArea  := GetArea()
Local lPauta := .F.
ZBC->( DbSetOrder(1) )
If ZBC->( DBSeek( xFilial('ZBC') + M->ZCC_CODIGO + M->ZCC_VERSAO ))
	While !ZBC->(Eof()) .and. ( ZBC->( ZBC_CODIGO + ZBC_VERSAO ) == M->ZCC_CODIGO + M->ZCC_VERSAO )
		if ZBC->ZBC_PEDPOR == "P"
			lPauta := .T.
			Exit
		EndIf
		ZBC->(DbSkip())
	EndDo
EndIf
RestArea(aArea)
Return lPauta


/* MJ : 16.05.2018 */
User Function ProxSC7_SC8() // U_ProxSC7_SC8()
Local cNumPc    := ""
Local cQry 	    := ""
Local cAliasQry := GetNextAlias()

cQry := " SELECT C7_FILIAL, MAX(C7_NUM) C7_NUM" + CRLF
cQry += " FROM " + RetSQLName('SC7') + CRLF
cQry += " WHERE C7_FILIAL = '"+ xFilial('SC7') +"'" + CRLF
cQry += " GROUP BY C7_FILIAL" + CRLF

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, cQry ),(cAliasQry),.F.,.F.)
if !(cAliasQry)->(Eof())
	cNumPc := Soma1( (cAliasQry)->C7_NUM )
Else
	cNumPc := StrZero( 1, TamSX3('C7_NUM')[1])
EndIf
(cAliasQry)->(DbCloseArea())

Return cNumPc



/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAFINM02()                                      |
 | Func:  COMM07PE()                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  12.11.2018                                                              |
 | Desc:  Tela para cadastro dos Pesos individualmente dos animais;               |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function COMM07PE(nLZBC)

Local aArea		  := GetArea()
Local nOpcA
Local nGDOpc	  := GD_INSERT + GD_UPDATE + GD_DELETE
Local oDlgP		  := nil 
Local oMGetP	  := nil, oGrpP1 := nil
Local aZPEHead 	  := {}, aZPECols := {}, nUZPE := 1, oGrpP2 := nil
Local oGrpP3 	  := nil
Local aField  	  := {}
Local aButtons    := {}
Local cTitulo	  := "Cadastro de Pesos Individualmente - Linha: "

Private oZPEGDad    := nil, oMGetE	  := nil

// Local cCpoNao    := "|ZAD_FILIAL|ZAD_CODIGO|ZAD_ITEM  |ZAD_EQUIPA| "
// Local cLstCpo    := "|ZAD_DATA  |ZAD_INICIO|ZAD_FINAL |ZAD_CC    |ZAD_CCDESC|ZAD_OPERAD|ZAD_NOMEOP| "

Private aGets     := {}
Private aTela     := {}

Private _cCodSB1  := CriaVar('ZBC_PRODUT', .F.)
Private _cDesSB1  := CriaVar('ZBC_PRDDES', .F.)
Private _cQuaZBC  := CriaVar('ZBC_QUANT' , .F.)
Private _cTotZBC  := CriaVar('ZBC_TOTAL' , .F.)

// Grupo 3
Private _cQuaZPE  := CriaVar('ZBC_QUANT' , .F.)
Private _cTotZPE  := CriaVar('ZBC_QUANT' , .F.)
Private _cMedZPE  := CriaVar('ZBC_QUANT' , .F.)

Default nLZBC	  := oZBCGDad:oBrowse:nAt

cTitulo	+= cValToChar(nLZBC)

_cCodSB1  := oZBCGDad:aCols[ nLZBC, aScan( oZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_PRODUT" }) ]
_cDesSB1  := AllTrim(_cCodSB1) + '-' + oZBCGDad:aCols[ nLZBC, aScan( oZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_PRDDES" }) ]
_cQuaZBC  := oZBCGDad:aCols[ nLZBC, aScan( oZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_QUANT"  }) ]
_cTotZBC  := oZBCGDad:aCols[ nLZBC, aScan( oZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_TOTAL"  }) ]

DEFINE MSDIALOG oDlgP TITLE OemToAnsi(cTitulo) From 0,0 to 600,500 PIXEL STYLE ; // 565,360
				nOR( WS_VISIBLE ,DS_MODALFRAME )  // tirar o X da tela | tirar o botao X da tela |

//                      Titulo,     Campo, Tipo,                 Tamanho,                 Decimal,                 Pict,                           Valid, Obrigat, Nivel,                     Inic Padr, F3,   When, Visual, Chave, CBox, Folder, N Alteravel, PictVar, Gatilho
//aAdd(aField, { "Cod. Produto" , "_cCodSB1", "C", TamSX3("ZBC_PRODUT")[1], TamSX3("ZBC_PRODUT")[2], PesqPict("ZBC", "ZBC_PRODUT"), /* { || VldCpo(2) } */	,     .F.,     1, GetSX8Num('ZAD','ZBC_PRODUT'), ""   , "" ,    .F.,   .F.,   "",      2,     .F.,          "",      "N"} )
aAdd(aField, { "Prouto"  , "_cDesSB1", "C", TamSX3("ZBC_PRDDES")[1], TamSX3("ZBC_PRDDES")[2], PesqPict("ZBC", "ZBC_PRDDES"), /* { || U_Vd1MNT01() } */ ,     .F.,     1,                            "", ""   , "" ,    .F.,   .F.,   "",      2,     .F.,          "",      "N"} )
aAdd(aField, { "Quant."	 , "_cQuaZBC", "N", TamSX3("ZBC_QUANT" )[1], TamSX3("ZBC_QUANT")[2] , PesqPict("ZBC", "ZBC_QUANT" ), /* { || VldCpo(2) }    */ ,     .F.,     1,                            "", ""   , "" ,    .F.,   .F.,   "",      2,     .F.,          "",      "N"} )
aAdd(aField, { "Total"	 , "_cTotZBC", "N", TamSX3("ZBC_TOTAL" )[1], TamSX3("ZBC_TOTAL")[2] , PesqPict("ZBC", "ZBC_TOTAL" ), /* { || VldCpo(2) }    */ ,     .F.,     1,                            "", ""   , "" ,    .F.,   .F.,   "",      2,     .F.,          "",      "N"} )

nDist := 2
nL1 := 32; nC1 := nDist
nL2 := nL1 + 78 /* 110 */; nC2 := 250 /* 180 */
oGrpP1 := TGroup():New( nL1, nC1, nL2, nC2, "Dados Gerais do Contrato",oDlgP,,, .T.,)
oMGetP := MsMGet():New(,, 3/* nOpc */,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,{0,0,0,0}/* aPObjs[1] */,/*aAlterEnch*/,/*nModelo*/,;
						/*nColMens*/,/*cMensagem*/, /*cTudoOk*/, oGrpP1,/*lF3*/,/*lMemoria*/, .F. /*lColumn*/,;
						nil /*caTela*/,/*lNoFolder*/, .T. /*lProperty*/,aField,/* aFolder */,/*lCreate*/,/*lNoMDIStretch*/,;
						/*cTela*/)
oMGetP:oBox:Align := CONTROL_ALIGN_ALLCLIENT

U_BDados( "ZPE", @aZPEHead, @aZPECols, @nUZPE, 1 /* nOrd */, /* lFilial */, "ZPE->ZPE_FILIAL + ZPE->ZPE_CODIGO + ZPE->ZPE_VERSAO + ZPE->ZPE_ITEZBC == '" + xFilial("ZPE") + M->ZCC_CODIGO + M->ZCC_VERSAO + StrZero(nLZBC ,TamSX3('ZBC_ITEM')[1]) + "'", /* lStatus */, /* cCpoLeg */, ;
					/* cLstCpo */, /* cElimina */, /* cCpoNao */, /* cStaReg */, /* cCpoMar */, /* cMarDef */, /* lLstCpo */, ;
					/* aLeg */, /* lEliSql */, /* lOrderBy */, /* cCposGrpBy */, /* cGroupBy */, /* aCposIni */, ;
					/* aJoin */, /* aCposCalc */, /* cOrderBy */, /* aCposVis */, /* aCposAlt */, /* cCpoFilial */, ;
					/* nOpcX */ )

If Len(aZPECols) == 1 .and. Empty(aZPECols[1,4])
	aZPECols[ 1, nPZPEIt:=aScan( aZPEHead, { |x| AllTrim(x[2]) == "ZPE_ITEM" })] :=  StrZero( 1, TamSX3('ZPE_ITEM')[1])
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
// 5	Todo o espaço	CONTROL_ALIGN_ALLCLIENT
// 6	Centro			CONTROL_ALIGN_CENTER

nL4 := nL3 + 50 // 295
oGrpP3 := TGroup():New( nL3+nDist, nC1, nL4,nC2, "Totalizadores",oDlgP,,, .T.,)
aField := {}

//                   Titulo,     Campo, Tipo,                 Tamanho,                 Decimal,                 Pict,                           Valid, Obrigat, Nivel,                     Inic Padr, F3,   When, Visual, Chave, CBox, Folder, N Alteravel, PictVar, Gatilho
aAdd(aField, { "Qtd Cad."  , "_cQuaZPE", "N", TamSX3("ZBC_QUANT" )[1], TamSX3("ZBC_QUANT")[2] , PesqPict("ZBC", "ZBC_QUANT" ), /* { || VldCpo(2) } */	,     .F.,     1,                            "", ""   , "" ,    .F.,   .F.,   "",   2,     .F.,          "",      "N"} )
aAdd(aField, { "Total Peso", "_cTotZPE", "N", TamSX3("ZBC_QUANT" )[1], TamSX3("ZBC_QUANT")[2] , PesqPict("ZBC", "ZBC_QUANT" ), /* { || VldCpo(2) } */	,     .F.,     1,                            "", ""   , "" ,    .F.,   .F.,   "",   2,     .F.,          "",      "N"} )
aAdd(aField, { "Média Peso", "_cMedZPE", "N", TamSX3("ZBC_QUANT" )[1], TamSX3("ZBC_QUANT")[2] , PesqPict("ZBC", "ZBC_QUANT" ), /* { || VldCpo(2) } */	,     .F.,     1,                            "", ""   , "" ,    .F.,   .F.,   "",   2,     .F.,          "",      "N"} )
oMGetE := MsMGet():New(,, 2/* nOpc */,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,{0,0,0,0}/* aPObjs[1] */,/*aAlterEnch*/,/*nModelo*/,;
						/*nColMens*/,/*cMensagem*/, /*cTudoOk*/, oGrpP3,/*lF3*/,/*lMemoria*/, .F. /*lColumn*/,;
						nil /*caTela*/,/*lNoFolder*/, .T. /*lProperty*/,aField,/* aFolder */,/*lCreate*/,/*lNoMDIStretch*/,;
						/*cTela*/)
oMGetE:oBox:Align := CONTROL_ALIGN_ALLCLIENT

AAdd( aButtons, { "AUTOM", { ||  ZPEPrint(nLZBC)  }, "Imprimir" } )
Set Key K_CTRL_P To ZPEPrint(nLZBC)

ACTIVATE MSDIALOG oDlgP ;
          ON INIT EnchoiceBar(oDlgP,;
                              { || nOpcA := 1, Iif( /* VldOk(nOpcE).and. */ Obrigatorio(aGets, aTela), oDlgP:End(), nOpcA := 0)},;
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
		
		oZBCGDad:aCols[ nLZBC, aScan( oZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_PESREA" }) ] := _cTotZPE
		If Empty(oZBCGDad:aCols[ nLZBC, aScan( oZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_PESO" }) ])
			oZBCGDad:aCols[ nLZBC, aScan( oZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_PESO" })   ] := _cTotZPE
			U_ZBCFieldOK('ZBC_PESO', _cTotZPE, nLZBC, .F. )
		EndIf
	End Transaction
EndIf

RestArea(aArea)
Return nil



/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMR07()                                      |
 | Func:  VldPesoM7()	                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  14.05.2018                                                              |
 | Desc:  Criação de planilha em excel. Define COLUNAS e imprime DADOS;           |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
/*
// -> Esta funcao estava no campo X3_VALID do campo ZPE_PESO  
User Function VldPesoM7()

tentando reposionar a posicao do cursor,
ir pra linha de baixo sozinho, sem precisar apertar o botao SETA para BAIXO;

// ClassMethArr( oZPEGDad, .T. )
 oZPEGDad:AddLine(.F., .F.)
//oZPEGDad:GoBottom()

//oZPEGDad:oBrowse:nColPos := 2
oZPEGDad:oBrowse:nAt 	 := Len(oZPEGDad:aCols)
// oZPEGDad:GoTo( Len(oZPEGDad:aCols) )
//oZPEGDad:ForceRefresh()
oZPEGDad:Refresh()

Alert('nColPos: ' + cValTochar(oZPEGDad:oBrowse:nColPos ) )
Alert('nAt: ' + cValToChar(oZPEGDad:oBrowse:nAt))
Return .T.
*/

/* 
	MJ : 13.11.2018
		-> Preencher linha de baixo, com copia da de cima * ctrl c + ctrl v;
		-> Setar focus no campo PESO;
*/
User Function ZPEFieldOK()
Local nI
Local nValor := 0

	// Alert('ZPEFieldOK - Linha: ' + AllTrim(Str(oZPEGDad:oBrowse:nAt)))
	// oZPEGDad:oBrowse:SetFocus()
	
	// nao da pra separar em funcao, tem particularidadeds 
	_cQuaZPE := 0
	_cTotZPE := 0
	
	For nI := 1 to Len(oZPEGDad:aCols)
		If !oZPEGDad:aCols[ nI, Len(oZPEGDad:aCols[nI]) ] // .and. nValor > 0 // oZPEGDad:aCols[ nI, 02 ] > 0
			nValor := iIf(nI == oZPEGDad:oBrowse:nAt, &(ReadVar()), oZPEGDad:aCols[ nI, 02 ])
		
			If nValor > 0
				_cQuaZPE += 1
				_cTotZPE += nValor
			EndIf
		EndIf
	Next nI
	_cMedZPE := Round(_cTotZPE / _cQuaZPE,2)
	
	// oZPEGDad:oBrowse:nColPos := 2
	// oZPEGDad:Refresh()
	oMGetE:Refresh()
	
Return .T.

// #########################################################################################################
User Function ZPEDelOk()
Local nI 
Local lSoma	 := .F.

	// Alert('ZPEDelOk - Linha: ' + AllTrim(Str(oZPEGDad:oBrowse:nAt)))
	// oZPEGDad:oBrowse:SetFocus()
	
	// nao da pra separar em funcao, tem particularidadeds 
	_cQuaZPE := 0
	_cTotZPE := 0
	For nI := 1 to Len(oZPEGDad:aCols)
	
		If nI == oZPEGDad:oBrowse:nAt
			lSoma := oZPEGDad:aCols[ nI, Len(oZPEGDad:aCols[nI]) ]
		Else
			lSoma := !oZPEGDad:aCols[ nI, Len(oZPEGDad:aCols[nI]) ]
		EndIf
	
		
		If lSoma
		// If !(oZPEGDad:oBrowse:nAt == nI .and. !oZPEGDad:aCols[ nI, Len(oZPEGDad:aCols[nI]) ]) ;
		// 
		// 	.and. !oZPEGDad:aCols[ nI, Len(oZPEGDad:aCols[nI]) ] .and. oZPEGDad:aCols[ nI, 02 ] > 0
			
			_cQuaZPE += 1
		
			// If nI == oZPEGDad:oBrowse:nAt
			// 	_cTotZPE += &(ReadVar())
			// Else
				_cTotZPE += oZPEGDad:aCols[ nI, 02 ]
			// EndIf
		EndIf
	Next nI
	
	_cMedZPE := Round(_cTotZPE / _cQuaZPE,2)
	// oZPEGDad:oBrowse:nColPos := 2
	// oZPEGDad:Refresh()
	oMGetE:Refresh()
	
Return .T.


User Function ZPEbChange()
Local lRet	:= .T.
	// Alert('ZPEbChange - Linha: ' + AllTrim(Str(oZPEGDad:oBrowse:nAt)))
	// oZPEGDad:oBrowse:SetFocus()
	oZPEGDad:oBrowse:nColPos := 2
	oZPEGDad:Refresh()
	oMGetE:Refresh()
Return lRet
/* 
User Function ZPELinOK()
Local lRet	:= .T.
	Alert('ZPELinOK - Linha: ' + AllTrim(Str(oZPEGDad:oBrowse:nAt)))
	// oZPEGDad:oBrowse:SetFocus()
	oZPEGDad:oBrowse:nColPos := 2
	oZPEGDad:Refresh()
Return lRet


User Function ZPEbBeforeEdit()
Local lRet	:= .T.
	Alert('ZPEbBeforeEdit - Linha: ' + AllTrim(Str(oZPEGDad:oBrowse:nAt)))
	// oZPEGDad:oBrowse:SetFocus()
	ReLoadTotalizadores()
Return lRet
*/


Static Function ZPEPrint(nLZBC)

Local cTimeIni	 	:= Time()
Local lTemDados		:= .T.

Private cPerg		:= "COMM07ZPE"
Private cTitulo  	:= "Relatorio Lotes de Compra"

Private cPath 	 	:= "C:\totvs_relatorios\"
Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
Private oExcelApp   := nil
Private _cAliasG	:= GetNextAlias()   

Private nHandle    	:= 0

Default nLZBC	    := oZBCGDad:oBrowse:nAt

If Len( Directory(cPath + "*.*","D") ) == 0
	If Makedir(cPath) == 0
		ConOut('Diretorio Criado com Sucesso.')
	Else	
		ConOut( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ) )
	EndIf
EndIf

nHandle := FCreate(cArquivo)
if nHandle = -1
	conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
else
	
	cStyle := U_defStyle()
	
	// Processar SQL
	FWMsgRun(, {|| lTemDados := VASqlM07("Geral", @_cAliasG, nLZBC ) },'Por Favor Aguarde...' , 'Processando Banco de Dados')
	If lTemDados
		cXML := U_CabXMLExcel(cStyle)

		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
			cXML := ""
		EndIf
		
		// Gerar primeira planilha
		FWMsgRun(, {|| fQuadro1(nLZBC) },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro de Lotes Analitico')
		
		// Final - encerramento do arquivo
		FWrite(nHandle, EncodeUTF8( '</Workbook>' ) )
		
		FClose(nHandle)

		If ApOleClient("MSExcel")				//	 U_VARELM01()
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open( cArquivo )
			oExcelApp:SetVisible(.T.)
			oExcelApp:Destroy()	
			// ou >  ShellExecute( "Open", cNameFile , '', '', 1 ) //Abre o arquivo na tela após salvar 
		Else
			MsgAlert("O Excel não foi encontrado. Arquivo " + cArquivo + " gerado em " + cPath + ".", "MsExcel não encontrado" )
		EndIf
		
	Else
		MsgAlert("Os parametros informados não retornou nenhuma informação do banco de dados." + CRLF + ;
				 "Por isso o excel não sera aberto automaticamente.", "Dados não localizados")
	EndIf
		
	(_cAliasG)->(DbCloseArea())
	
	If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
		Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
	EndIf
	
	ConOut('Activate: ' + Time())
EndIf

Return nil

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMM07()                                      |
 | Func:  VASqlM07()	                                                          |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  14.05.2018                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function VASqlM07(cTipo, _cAlias, nLZBC)
Local _cQry 		:= ""

Default nLZBC	    := oZBCGDad:oBrowse:nAt

If cTipo == "Geral"

	_cQry := " SELECT ZPE_ITEM, ZPE_PESO " + CRLF
	_cQry += " FROM ZPE010" + CRLF
	_cQry += " WHERE" + CRLF
	_cQry += " 	    ZPE_FILIAL='"+ xFilial("ZPE") +"' " + CRLF
	_cQry += " 	AND ZPE_CODIGO='"+ M->ZCC_CODIGO +"' " + CRLF
	_cQry += " 	AND ZPE_VERSAO='"+ M->ZCC_VERSAO +"' " + CRLF
	_cQry += " 	AND ZPE_ITEZBC='"+ StrZero(nLZBC ,TamSX3('ZBC_ITEM')[1]) +"' " + CRLF
	_cQry += " 	AND D_E_L_E_T_=' '" + CRLF
	_cQry += " ORDER BY ZPE_ITEM " + CRLF

EndIf

If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
	MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

// TcSetField(_cAlias, "ZBC_DTENTR", "D")

Return !(_cAlias)->(Eof())


/*--------------------------------------------------------------------------------,
 | Principal: 					U_VACOMM07()                                      |
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
	     cXML += '   <Column ss:Width="61.5"/>
		 cXML += '   <Column ss:Width="113.25"/>
		 cXML += '   <Column ss:Width="105"/>
		 cXML += '   <Column ss:Width="96"/>
		 cXML += '   <Column ss:Width="63.75"/>
		 cXML += '   <Column ss:Width="146.25"/>
		 cXML += '   <Column ss:Width="48.75"/>
		 cXML += '   <Column ss:Width="72.75"/>
         cXML += ' <Row ss:AutoFitHeight="0" ss:Height="36">' + CRLF
         cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Numero Contrato:</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Fornecedor:</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Municipio/Est</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Corretor:</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Numero do Pedido:</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Produto:</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Quant.</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Preço Total</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="s65"><Data ss:Type="String">Média Preço</Data></Cell>' + CRLF
		 cXML += '</Row>' + CRLF
		 cXML += '<Row>' + CRLF
         cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( M->ZCC_CODIGO ) + '</Data></Cell>' + CRLF	
         cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( M->ZCC_CODFOR + "-" + M->ZCC_NOMFOR ) + '</Data></Cell>' + CRLF	
		 cAux := Posicione("SA2", 1, xFilial("SA2")+M->ZCC_CODFOR+M->ZCC_LOJFOR, "A2_MUN") + "/" + SA2->A2_EST
         cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'+U_FrmtVlrExcel( cAux )+'</Data></Cell>' + CRLF	
         cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( AllTrim(M->ZCC_CODCOR) + "-" + M->ZCC_NOMCOR ) + '</Data></Cell>' + CRLF	
         cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( oZBCGDad:aCols[ nLZBC, aScan( oZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_PEDIDO" })] + "-" + oZBCGDad:aCols[ nLZBC, aScan( oZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_ITEMPC" })] ) + '</Data></Cell>' + CRLF	
         cXML += '  <Cell ss:StyleID="sTexto"><Data ss:Type="String">'  + U_FrmtVlrExcel( oZBCGDad:aCols[ nLZBC, aScan( oZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_PRODUT" })] + "-" + oZBCGDad:aCols[ nLZBC, aScan( oZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_PRDDES" })] ) + '</Data></Cell>' + CRLF	
         cXML += '  <Cell ss:StyleID="sComDig"><Data ss:Type="Number">' + U_FrmtVlrExcel( oZBCGDad:aCols[ nLZBC, aScan( oZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_QUANT" })] ) + '</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="sReal"><Data ss:Type="Number">' + U_FrmtVlrExcel( oZBCGDad:aCols[ nLZBC, aScan( oZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_TOTAL" })] ) + '</Data></Cell>' + CRLF
         cXML += '  <Cell ss:StyleID="sReal" ss:Formula="=RC[-1]/RC[-2]"><Data ss:Type="Number"></Data></Cell>' + CRLF
		 cXML += '</Row>' + CRLF
		 
		 cXML += '<Row ss:AutoFitHeight="0"></Row>' + CRLF // PULAR LINHA
	
		 cXML += '<Row ss:AutoFitHeight="0">
		 cXML += '	<Cell ss:StyleID="s65"><Data ss:Type="String">Negociação</Data></Cell>
		 cXML += '</Row>
	
		 // P=Peso/Rend;K=Kilo;Q=Qtde
		 cXML += '<Row ss:AutoFitHeight="0">
		 cAux := oZICGDad:aCols[ Val(oZBCGDad:aCols[ nLZBC, aScan( oZBCGDad:aHeader, { |x| AllTrim(x[2]) == "ZBC_ITEZIC" })]), aScan( oZICGDad:aHeader, { |x| AllTrim(x[2]) == "ZIC_TPNEG" })]
		 if cAux=="P"
			cAux:="Peso/Rendimento"
		 ElseIf cAux=="K"
			cAux:="Kilo"
		 ElseIf cAux=="Q"
		 	cAux:="Quantidade"
		 Else
		 	cAux := "Não Identificado"
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
    cXML += '  <Cell ss:StyleID="sTextoN"><Data ss:Type="String">Total Peso</Data></Cell>' + CRLF	
	cXML += ' 	<Cell ss:Index="2" ss:StyleID="sComDigN" ss:Formula="=SUM(R[-'+cValToChar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
	cXML += ' </Row>' + CRLF	
	
	cXML += ' <Row>' + CRLF
    cXML += '  <Cell ss:StyleID="sTextoN"><Data ss:Type="String">Média Peso</Data></Cell>' + CRLF	
	cXML += ' 	<Cell ss:Index="2" ss:StyleID="sComDigN" ss:Formula="=AVERAGE(R[-'+cValToChar(nLin+1)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>' + CRLF
	cXML += ' </Row>' + CRLF	
	
	cXML += '  </Table>
	cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
	cXML += '   <PageSetup>
	cXML += '    <Header x:Margin="0.31496062000000002"/>
	cXML += '    <Footer x:Margin="0.31496062000000002"/>
	cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"
	cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>
	cXML += '   </PageSetup>
	cXML += '   <TabColorIndex>13</TabColorIndex>
	cXML += '   <Selected/>
	cXML += '   <Panes>
	cXML += '    <Pane>
	cXML += '     <Number>3</Number>
	cXML += '     <ActiveRow>17</ActiveRow>
	cXML += '     <ActiveCol>9</ActiveCol>
	cXML += '    </Pane>
	cXML += '   </Panes>
	cXML += '   <ProtectObjects>False</ProtectObjects>
	cXML += '   <ProtectScenarios>False</ProtectScenarios>
	cXML += '  </WorksheetOptions>
	cXML += ' </Worksheet>
 
	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""	
	
EndIf	

Return nil
// fQuadro1
