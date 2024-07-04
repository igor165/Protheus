#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "OGC150.ch"

/*{Protheus.doc} OGC150
Programa para exibição de Previsões Financeiras
@author jean.schulze
@since 25/05/2018
@version 1.0
@return ${return}, ${return_description}
@param cCodCtr, characters, descricao
@type function
*/
Function OGC150(cCodCtr)
	Local aCoors      := FWGetDialogSize( oMainWnd )
	Local oSize       := {}
	Local oDlg		  := Nil
	Local oFWL        := Nil
	Local oPnl1       := Nil		
	Local oPnlWnd1    := Nil
	Local oPnlWnd2    := Nil
	Local oPnlWnd3    := Nil
	Local oPnlWnd4    := Nil
	Local aVlrTotal   := {}
	Local nDecimFld   := TamSX3( "NN7_VALOR" )[2] //tamanho para round
	Local cPictFld    := PesqPict("NN7","NN7_VALOR") //pciture
	Local nTotAPg     := 0
	Local nX          := 0
			
	Private _oMBrwFat := Nil
	Private _oMBrwPag := Nil 
	Private _oMBrwPrv := Nil
	Private _cCodCtr  := cCodCtr
	
	Default cCodCtr   := ""
	
	//informa os valores totais
	aVlrTotal := fCalcTotal()
	nTotAFat  := iif(aVlrTotal[1]-aVlrTotal[2]+aVlrTotal[4] < 0, 0, aVlrTotal[1]-aVlrTotal[2]+aVlrTotal[4])	
	nTotAPg   := iif(aVlrTotal[1]-aVlrTotal[3] < 0, 0, aVlrTotal[1]-aVlrTotal[3])
	
	//tamanho da tela principal
	oSize := FWDefSize():New(.f.) //considerar o enchoice
	oSize:AddObject('DLG',100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.
	oSize:aMargins  := {0,0,0,0}
	oSize:Process()
	
	//monta um dialog
	oDlg := TDialog():New(oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //Consulta de Previsões

	oPnl1:= tPanel():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],,oDlg,,,,,,oSize:aPosObj[1,4],oSize:aPosObj[1,3]  /*enchoice bar*/)

	// Instancia o layer
	oFWL := FWLayer():New()

	// Inicia o Layer
	oFWL:init( oPnl1, .F. )

	// Topo - Previsões Financeiras
	oFWL:addLine( 'TOP'   , 35 , .F.)
	oFWL:addCollumn( 'CENTER' ,100,.F., 'TOP' )
	
	//Middle
	oFWL:addLine( 'MIDDLE'   , 50 , .F.)
	oFWL:addCollumn( 'LEFT' ,50,.F., 'MIDDLE' )
	oFWL:addCollumn( 'RIGHT' , 50,.F., 'MIDDLE' )
	
	//Bottom
	oFWL:addLine( 'BOTTOM'   , 15 , .F.)
	oFWL:addCollumn( 'CENTER' ,100,.F., 'BOTTOM' )
	
	//Cria column split
	oFWL:setColSplit ( 'LEFT', 1,  'MIDDLE' )
	oFWL:setColSplit ( 'RIGHT', 2,  'MIDDLE' )

	//cria as janelas
	oFWL:addWindow('CENTER', 'Wnd1', STR0002,  100 /*tamanho*/, .F., .T.,, 'TOP' )	
	oFWL:addWindow('LEFT'  , 'Wnd2', STR0003,  100 /*tamanho*/, .F., .T.,, 'MIDDLE' )
	oFWL:addWindow('RIGHT' , 'Wnd3', STR0004,  100 /*tamanho*/, .F., .T.,, 'MIDDLE' )
	oFWL:addWindow('CENTER', 'Wnd4', STR0005,  100 /*tamanho*/, .F., .T.,, 'BOTTOM' )	

	// Recupera os Paineis das divisões do Layer
	oPnlWnd1:= oFWL:getWinPanel( 'CENTER', 'Wnd1', 'TOP' )
	oPnlWnd2:= oFWL:getWinPanel( 'LEFT'  , 'Wnd2', 'MIDDLE' )
	oPnlWnd3:= oFWL:getWinPanel( 'RIGHT' , 'Wnd3', 'MIDDLE' )
	oPnlWnd4:= oFWL:getWinPanel( 'CENTER', 'Wnd4', 'BOTTOM' )
	
	
	/*****************Faturamentos **************/
	_oMBrwFat := FWMBrowse():New()
	_oMBrwFat:SetAlias( "N9K" )
	_oMBrwFat:SetFilterDefault( "N9K_CODCTR = '"+_cCodCtr+"'" )
	_oMBrwFat:SetSeeAll(.t.)
	_oMBrwFat:DisableDetails()
	_oMBrwFat:SetMenuDef("")
    _oMBrwFat:DisableReport(.T.) 
    _oMBrwFat:AddColumn( {"Filial", { || N9K->N9K_FILIAL } ,"C","@!",8,,,.f.,,,,,,,,,"FIL"} )
    _oMBrwFat:AddColumn( {"Cotação", { || Posicione ("N9J" , 1, N9K->N9K_FILORI+ N9K->N9K_CODCTR + N9K->N9K_ITEMPE + N9K->N9K_ITEMRF + N9K->N9K_SEQCP + N9K->N9K_SEQPF + N9K->N9K_SEQN9J,"N9J_VLRTAX" ) } ,"N","@E 999,999.99",9,,,.f.,,,,,,,,,"COT"} )    
	_oMBrwFat:Activate(oPnlWnd2)

	aColunas := _oMBrwFat:ACOLUMNS
	For nX := 1 To Len(aColunas)
		If "Cotação" $ aColunas[nX]:cTitle .And. aColunas[nX]:cId = "COT"
			oCOTAC := aColunas[nX]
		EndIf
		If "Filial" == aColunas[nX]:cTitle .And. aColunas[nX]:cId = NIl
			oFilN9K := aColunas[nX]
		EndIf
	Next Nx

	_oMBrwFat:ACOLUMNS[2] := oFilN9K
	_oMBrwFat:ACOLUMNS[3] := oCOTAC	
	_oMBrwFat:UpdateBrowse(.T.)
	
	/***************Pagamentos**************************/
	_oMBrwPag := FWMBrowse():New()
	_oMBrwPag:SetAlias( "N9G" )
	_oMBrwPag:DisableDetails()
	_oMBrwPag:SetFilterDefault( "N9G_CODCTR = '"+_cCodCtr+"'" )
	_oMBrwPag:SetMenuDef("")
    _oMBrwPag:DisableReport(.T.) 
	_oMBrwPag:Activate(oPnlWnd3)	
	
	/*****************Previsões Financeiras **************/
	_oMBrwPrv := FWMBrowse():New()
	_oMBrwPrv:SetAlias( "NN7" )
	_oMBrwPrv:DisableDetails()
	_oMBrwPrv:SetFilterDefault( "NN7_CODCTR = '"+_cCodCtr+"'" )
	_oMBrwPrv:SetChange({|| fChgLine(NN7->NN7_ITEM) })
	_oMBrwPrv:SetMenuDef("")
    _oMBrwPrv:DisableReport(.T.) 
	_oMBrwPrv:Activate(oPnlWnd1)	
	
	/*************** Totais **************************/
	//- Recupera coordenadas 
	oSize2 := FWDefSize():New(.F.)
	oSize2:AddObject("Total",oPnlWnd4:NWIDTH,oPnlWnd4:NHEIGHT,.t.,.t.)
	oSize2:SetWindowSize({0,0,oPnlWnd4:NHEIGHT,oPnlWnd4:NWIDTH})
	oSize2:lProp 	:= .T.
	oSize2:aMargins := {0,0,0,0}
	oSize2:Process()
	
	//cria os tamanhos máximos
	nSizeTot  := iif((oSize2:aWorkArea[3]/5) < 100, (oSize2:aWorkArea[3]/5), 100 ) //tamanho do campo
	
	//cria os campos de totais
	TSay():New(0,0,{||STR0006},oPnlWnd4,,,,,,.T.,,,50,10,,,,,,.f.)
	TGet():New(8,0,{|| round(aVlrTotal[1],nDecimFld )},oPnlWnd4,nSizeTot-7,010,cPictFld,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,,.t.,.f. )
	
	TSay():New(0,(oSize2:aWorkArea[3]/6),{||STR0007},oPnlWnd4,,,,,,.T.,,,50,10,,,,,,.f.)
	TGet():New(8,(oSize2:aWorkArea[3]/6),{|| round(aVlrTotal[2],nDecimFld) },oPnlWnd4,nSizeTot-7 ,010,cPictFld,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,,.t.,.f. )
	
	TSay():New(0,((oSize2:aWorkArea[3]/6)*2),{||STR0013},oPnlWnd4,,,,,,.T.,,,50,10,,,,,,.f.) //"Valor Devolvido"
	TGet():New(8,((oSize2:aWorkArea[3]/6)*2),{|| round(aVlrTotal[4],nDecimFld )},oPnlWnd4,nSizeTot-7,010,cPictFld,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,,.t.,.f. )

	TSay():New(0,((oSize2:aWorkArea[3]/6)*3),{||STR0008},oPnlWnd4,,,,,,.T.,,,50,10,,,,,,.f.) //Valor Total à Faturar (NN7 - N9K)
	TGet():New(8,((oSize2:aWorkArea[3]/6)*3),{|| round(nTotAFat,nDecimFld )},oPnlWnd4,nSizeTot-7,010,cPictFld,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,,.t.,.f. )

	TSay():New(0,((oSize2:aWorkArea[3]/6)*4),{||STR0009},oPnlWnd4,,,,,,.T.,,,50,10,,,,,,.f.) //Valor Total Pago
	TGet():New(8,((oSize2:aWorkArea[3]/6)*4),{|| round(aVlrTotal[3],nDecimFld )},oPnlWnd4,nSizeTot-7,010,cPictFld,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,,.t.,.f. )
	
	TSay():New(0,((oSize2:aWorkArea[3]/6)*5),{||STR0010},oPnlWnd4,,,,,,.T.,,,50,10,,,,,,.f.) //Valor Total à Pagar
	TGet():New(8,((oSize2:aWorkArea[3]/6)*5),{|| round(nTotAPg,nDecimFld )},oPnlWnd4,nSizeTot-7,010,cPictFld,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,,.t.,.f. )
	
	
	/********* Activate da tela ************************/
	oDlg:Activate( , , , .t., , ,  )
	
Return .t.

/*{Protheus.doc} fChgLine
Filtra os pagamentos e faturamentos conforme a Previsão Selecionada
@author jean.schulze
@since 25/05/2018
@version 1.0
@return ${return}, ${return_description}
@param cCodPrev, characters, descricao
@type function
*/
Static Function fChgLine(cCodPrev)
	_oMBrwFat:SetFilterDefault("N9K_FILORI = '"+FwxFilial("NJR")+"'.AND. N9K_CODCTR = '"+_cCodCtr+"' .AND. N9K_SEQPF  = '"+cCodPrev+"'" )
	_oMBrwPag:SetFilterDefault("N9G_CODCTR = '"+_cCodCtr+"' .AND. N9G_ITEMPV = '"+cCodPrev+"'" )
return .t.

/*{Protheus.doc} fCalcTotal
Calcula os valores totais do Contrato
@author jean.schulze
@since 25/05/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/
Static Function fCalcTotal()
	Local cAliasN9K	 := GetNextAlias()
	Local cAliasN9G	 := GetNextAlias()
	Local nTotalNN7  := 0 //quantidade total das NN7
	Local nTotalDev  := 0 //quantidade devolvida das NN7	
	Local nTotalN9K  := 0 //quantidade total das N9K
	Local nTotalN9G  := 0 //quantidade total das N9G
	
	//monta a quantidade total das NN7
	dbSelectArea( "NN7" )
	NN7->(dbSetOrder(1)) 	
	
	if NN7->(dbSeek(xFilial("NN7")+_cCodCtr))
		//soma os valores das NN7
		While NN7->(!EOF()) .And. alltrim(NN7->(NN7_FILIAL+NN7_CODCTR) ) == alltrim(xFilial("NN7")+_cCodCtr)
			nTotalNN7 += NN7->(NN7_VALOR)
			nTotalDev += NN7->(NN7_VLDEVL)	
			NN7->(dbSkip())
		EndDo
				
		//busca os faturamentos 
		BeginSql Alias cAliasN9K
	
			SELECT SUM(N9K_VALOR) VALOR
			  FROM %Table:N9K% N9K			 
			WHERE N9K.%notDel%
			  AND N9K.N9K_FILORI = %exp:xFilial("NJR")%
			  AND N9K.N9K_CODCTR = %exp:_cCodCtr%
			GROUP BY N9K.N9K_CODCTR
				
		EndSQL
		
		DbselectArea( cAliasN9K )
		( cAliasN9K )->(DbGoTop())
		if ( cAliasN9K )->( !Eof() )
			nTotalN9K := ( cAliasN9K )->VALOR
		endif
		
		//busca os pagamentos
		BeginSql Alias cAliasN9G
	
			SELECT SUM(N9G_VALOR) VALOR
			  FROM %Table:N9G% N9G		 
			WHERE N9G.%notDel%
			  AND N9G.N9G_FILIAL = %exp:xFilial("N9G")%
			  AND N9G.N9G_CODCTR = %exp:_cCodCtr%
			GROUP BY N9G.N9G_CODCTR
				
		EndSQL
		
		DbselectArea( cAliasN9G )
		( cAliasN9G )->(DbGoTop())
		if ( cAliasN9G )->( !Eof() )
			nTotalN9G := ( cAliasN9G )->VALOR
		endif
		
	endif
return {nTotalNN7,nTotalN9K,nTotalN9G,nTotalDev }