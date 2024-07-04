#INCLUDE 'DPRC323.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'MSGRAPHI.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRC323
Tela de Comparar Produto Concorrente

@author Samantha Preima
@since 25/01/2013
@version P11
/*/
//-------------------------------------------------------------------
Function DPRC323()
Local aCoors   := FWGetDialogSize( oMainWnd )
Local oFWLayer
Local cProduto := Criavar("DG0_CDACDV",.F.)
Local cVersao  := '0000000000'
Local cDesc    := Criavar("DG0_DSVR",.F.)
Local cArquiv  := ''
Local aValidaDPR := {}
Private oBrowse
Private cTabBrw
Private oFWChart
Private aDados := {cProduto,cVersao,cDesc,date(),date()}
Private oTabBrw
Default lAutoMacao := .F.

IF !lAutoMacao

	aValidaDPR := ValidaDPR()

	// Valida se o programa pode ser aberto
	If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
		Final(aValidaDPR[2])
	ElseIf !Empty( aValidaDPR[2] )
		DPRXError( 'DPRC323', aValidaDPR[2], 3 )
	EndIf

	IF DPRC323FIL()

		Define MsDialog oDlgPrincDet Title STR0001  FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel // Comparar Produto Concorrente
		
			// Layer Principal
			oFWLayer := FWLayer():New()
			oFWLayer:Init( oDlgPrincDet, .F.)
			oFWLayer:AddLine('PRODUTO', 20, .T. )
			oFWLayer:AddLine('DETALHE', 75, .T. )
			oFWLayer:AddCollumn('PRODUTO_COL', 100, .T. ,'PRODUTO')
			oFWLayer:AddCollumn('DETALHE1_COL', 70, .T. ,'DETALHE')
			oFWLayer:AddCollumn('DETALHE2_COL', 30, .T. ,'DETALHE')
			oFWLayer:AddWindow('PRODUTO_COL' , 'PRODUTO_WINDOW' , '', 100, .T., .T.,, 'PRODUTO',)
			oFWLayer:AddWindow('DETALHE1_COL', 'DETALHE1_WINDOW', '', 100, .T., .T.,, 'DETALHE',)
			oFWLayer:AddWindow('DETALHE2_COL', 'DETALHE2_WINDOW', '', 100, .T., .T.,, 'DETALHE',)
		
			oLayerProduto := oFWLayer:GetWinPanel ( 'PRODUTO_COL' , 'PRODUTO_WINDOW' , 'PRODUTO' )
			oLayerBrowse  := oFWLayer:GetWinPanel ( 'DETALHE1_COL', 'DETALHE1_WINDOW', 'DETALHE' )
			oLayerGrafico := oFWLayer:GetWinPanel ( 'DETALHE2_COL', 'DETALHE2_WINDOW', 'DETALHE' )
			
			TSay():New( 06, 08  , {|| STR0011 }, oLayerProduto,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Produto Desenvolvido
			TSay():New( 06, 108 , {|| STR0012 }, oLayerProduto,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Versão
			TSay():New( 06, 180 , {|| STR0013 }, oLayerProduto,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Descrição
			
			@ 15,08  MsGet oCDACDV Var aDados[1] Size  90, 10 Of oLayerProduto Pixel HasButton WHEN .F. 
			@ 15,108 MsGet oVERSAO Var aDados[2] Size  60, 10 Of oLayerProduto Pixel HasButton WHEN .F.
			@ 15,180 MsGet oDesc   Var aDados[3] Size 200, 10 Of oLayerProduto Pixel HasButton WHEN .F.
			
			oFWLayerBTS := FWLayer():New()
			oFWLayerBTS:Init( oLayerGrafico, .F.)
			oFWLayerBTS:addCollumn( 'GRAFICO', 100, .T.)
		
			oFWChart := FWChartFactory():New()
			oFWChart := oFWChart:getInstance( BARCOMPCHART )
			oFWChart:Init( oFWLayerBTS:GetColPanel('GRAFICO'), .T. )
			oFWChart:setLegend( CONTROL_ALIGN_TOP )
			
			DPRC323CAL()
		
		Activate MsDialog oDlgPrincDet Centered On Init EnchoiceBar( oDlgPrincDet, { || oDlgPrincDet:End() }, { || oDlgPrincDet:End() },,{{,{ || IF(DPRC323FIL(), DPRC323CAL(),.F.)}, STR0002}},,,,,, .F. ) // Filtro

		if oTabBrw != nil
			oTabBrw:Delete()
		Endif
	Endif
ENDIF

Return NIL

//-------------------------------------------------------------------
// MenuDef
//-------------------------------------------------------------------
Static Function MenuDef()

Return {}

//-------------------------------------------------------------------
// DPRC323FIL - Filtro
//-------------------------------------------------------------------
Static Function DPRC323FIL()
Local lRet := .T.

if Pergunte('DPRC323A')

	aDados[1] := MV_PAR01 // Produto
	aDados[2] := MV_PAR02 // Versão
	aDados[4] := MV_PAR03 // Data Inicial
	aDados[5] := MV_PAR04 // Data Corte

Else
	lRet := .F.
Endif

Return lRet

//-------------------------------------------------------------------
// DPRC323CAL - Calcula com base no item informado
//-------------------------------------------------------------------
Static Function DPRC323CAL()
Local lRet     := .T.
Local nTotal   := 0
Local aTabela
Local aCri     := {}
Local aResult  := {}
Local nNota    := 0
Local nI       := 0
Local cQuery   := ''
Local cTmp

if oBrowse <> nil
	oBrowse:DeActivate(.T.)
	oFWChart:Reset()
Endif

dbSelectArea('DG0')
DG0->(dbSetOrder(1))
DG0->(dbSeek(xFilial('DG0')+aDados[1]+aDados[2]))

aDados[3] := DG0->DG0_DSVR

dbSelectArea('DGF')
DGF->(dbSetOrder(1))
if DGF->(dbSeek(xFilial('DGF')+aDados[1]))
	While DGF->(!EOF()) .AND. DGF->DGF_CDACDV == aDados[1]
		nTotal += DGF->DGF_VLPSJZ

		aadd(aCri, {DGF->DGF_CDJZ, DGF->DGF_VLPSJZ})

		DGF->(dbSkip())
	End
Else
	DPRXError( 'DPRC323', 'DPRC323_CRIT', 3 ) // Não há critério de qualidade para este Produto Desenvolvido.
	lRet := .F.
Endif

aTabela := DPRC323TAB(aCri)
oTabBrw := SFCCriFWTa(aTabela)
cTabBrw := oTabBrw:GetAlias()

if lRet

	dbSelectArea('DGA')
	DGA->(dbSetOrder(4))
	if DGA->(dbSeek(xFilial('DGA')+aDados[1]))

		cQuery := ""
		cQuery += "SELECT * FROM " + RetSQLName( 'DGA' ) + " DGA WHERE "
		cQuery += "		DGA_FILIAL  = '" + xFilial('DGA') + "' AND "
		cQuery += "		DGA_CDACDV  = '" + aDados[1] + "' AND "
		cQuery += "     DGA_DTPR   <= '" + DTOS(aDados[5]) + "' AND "
		cQuery += "     DGA_DTPR   >= '" + DTOS(aDados[4]) + "' AND "
		cQuery += "     D_E_L_E_T_  = ' ' ORDER BY DGA_DTPR DESC"

		cTmp := GetNextAlias()

		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. )

		While (cTmp)->(!EOF())

			// Verifica se já existe registro para o concorrente
			dbSelectArea(cTabBrw)
			if !(cTabBrw)->(dbSeek((cTmp)->DGA_NMAS))

				aResult := {}
			 	nNota   := 0

				dbSelectArea('DGF')
				DGF->(dbSetOrder(1))
				if DGF->(dbSeek(xFilial('DGF')+aDados[1]))

					While DGF->(!EOF()) .AND. DGF->DGF_CDACDV == aDados[1]
						dbSelectArea('DGI')
						DGI->(dbSetOrder(1))
						if DGI->(dbSeek(xFilial('DGI')+aDados[1]+(cTmp)->DGA_NRSQ+DGF->DGF_CDJZ))
							If aDados[5] >= DGI->DGI_DTJZ .AND.;
							   aDados[4] <= DGI->DGI_DTJZ

								nNota += DGI->DGI_VLJZ * DGF->DGF_VLPSJZ / nTotal
							Endif
						Endif

						aadd(aResult, {DGI->DGI_CDJZ, DGI->DGI_VLJZ})

						DGF->(dbSkip())
					End
				Endif

				RecLock(cTabBrw, .T.)
				(cTabBrw)->NMCONC := (cTmp)->DGA_NMAS
			   	(cTabBrw)->DSPROD := (cTmp)->DGA_DSACAS
				(cTabBrw)->DTCRI  := STOD((cTmp)->DGA_DTPR)
				(cTabBrw)->PRECO  := (cTmp)->DGA_VLPR
				(cTabBrw)->VLCALC := nNota

				For nI := 1 to len(aResult)
					(cTabBrw)->&("VLCRI" + ALLTRIM(STR(nI))) := aResult[nI][2]
				Next

				MsUnlock()
			Endif

			(cTmp)->(dbSkip())
		End
	Else
		DPRXError( 'DPRC323', 'DPRC323_CONCOR', 3 ) // Não há produtos concorrentes relacionados a este Produto Desenvolvido.
		lRet := .F.
	Endif
Endif

if lRet
	dbSelectArea('DGJ')
	DGJ->(dbSetOrder(1))
	IF DGJ->(dbSeek(xFilial('DGJ')+aDados[1]+aDados[2]))
	
		nNota   := 0
		aResult := {}
		
		dbSelectArea('DGF')
		DGF->(dbSetOrder(1))
		if DGF->(dbSeek(xFilial('DGF')+aDados[1]))
			While DGF->(!EOF()) .AND. DGF->DGF_CDACDV == aDados[1]
			
				dbSelectArea('DGJ')
				DGJ->(dbSetOrder(1))
				if DGJ->(dbSeek(xFilial('DGJ')+aDados[1]+aDados[2]+DGF->DGF_CDJZ))
					nNota += DGJ->DGJ_VLJZ * DGF->DGF_VLPSJZ / nTotal
				Endif
				
				aadd(aResult, {DGJ->DGJ_CDJZ, DGJ->DGJ_VLJZ})
			
				DGF->(dbSkip())
	        End
		Endif
		
		// Incluir uma linha com o produto DP
		RecLock(cTabBrw, .T.)
		(cTabBrw)->NMCONC := ''
		(cTabBrw)->DSPROD := ALLTRIM(aDados[1]) + ' - ' + ALLTRIM(aDados[2])
		(cTabBrw)->DTCRI  := DATE()
		(cTabBrw)->PRECO  := DG0->DG0_VLPR
		(cTabBrw)->VLCALC := nNota
		
		For nI := 1 to len(aResult)
			(cTabBrw)->&("VLCRI" + ALLTRIM(STR(nI))) := aResult[nI][2]
		Next
	
		MsUnlock()
	Endif
	
	oBrowse := FWBrowse():New( oLayerBrowse )
	oBrowse:SetDataTable( .T. )
	oBrowse:SetAlias( cTabBrw )
	oBrowse:DisableConfig()
	oBrowse:SetColumns( DPRC323COL( "cTabBrw", aTabela, .F. ) )
	oBrowse:ACOLUMNS[4]:NALIGN := 2
	oBrowse:ACOLUMNS[5]:NALIGN := 2
	
	For nI := 6 to Len(aCri) + 5
		oBrowse:ACOLUMNS[nI]:NALIGN := 2
	Next
	
	oBrowse:Activate()
	
	aValor := {}
	aPreco := {}
	
	(cTabBrw)->(dbGoTop())
	While (cTabBrw)->(!EOF())
		aadd(aValor,{(cTabBrw)->NMCONC, (cTabBrw)->VLCALC})
		aadd(aPreco,{(cTabBrw)->NMCONC, (cTabBrw)->PRECO})
		
		(cTabBrw)->(dbSkip())
	End	
	
	oFWChart:addSerie( STR0010, aValor ) // Nota Valor
	oFWChart:addSerie( STR0006, aPreco ) // Preço
	
	oFWChart:Build()
	
	oBrowse:CleanFilter()
Endif

Return lRet

//-------------------------------------------------------------------
// DPRC323TAB - Define a tabela a ser utilizada no browsw
//-------------------------------------------------------------------
Static Function DPRC323TAB(aCri)
Local nI   := 0
Local aDBF := {}
Local aRes := {}

aDBF := { { "NMCONC", "C", 0, 0, STR0007 , .T. , "@!" , "DGA_NMAS"   } , ; // Concorrente
		  { "DSPROD", "C", 0, 0, STR0008 , .T. , "@!" , "DGA_DSACAS" } , ; // Descrição Produto
		  { "DTCRI" , "C", 0, 0, STR0009 , .T. , "@!" , "DGI_DTJZ"   } , ; // Data
		  { "PRECO" , "C", 0, 0, STR0006 , .T. , "@!" , "DGA_VLPR"   } , ; // Preço
		  { "VLCALC", "C", 0, 0, STR0010 , .T. , "@!" , "DGI_VLJZ"   } }   // Nota Valor

For nI := 1 to len(aDBF)
	aRes := TamSx3(aDBF[nI][8])
	aDBF[nI][3] := aRes[1] // Tamanho
	aDBF[nI][4] := aRes[2] // Decimais
	aDBF[nI][2] := aRes[3] // Tipo
	aDBF[nI][7] := x3picture(aDBF[nI][8]) // Picture
Next

aRes     := TamSx3("DGI_VLJZ")
cPicture := x3picture("DGI_VLJZ")

For nI := 6 to len(aCri) + 5
	aadd(aDBF, {"VLCRI" + ALLTRIM(STR(nI - 5)), aRes[3], aRes[1], aRes[2], aCri[nI - 5][1] + " (" + ALLTRIM(STR(aCri[nI - 5][2])) + ")" , .T., cPicture })
Next

Return { aDBF , {"NMCONC"} }

//-------------------------------------------------------------------
// DPRC323COL - Monta o browse de acordo com a tabela
//-------------------------------------------------------------------
Static Function DPRC323COL( cName, cTab, lShow )
	Local aColumn := {}
	Local aFields := cTab[1]
	Local nCount
	Default lShow := .T.

	For nCount := 1 To Len(aFields)
		If (lShow = .T.) .Or. (aFields[nCount,6] = .T. .And. lShow = .F.)
	   		oColumn := FWBrwColumn():New()
			oColumn:SetData( &( '{ || ( ' + cName + ' )->' + aFields[nCount,1]+ ' }' ) )
			oColumn:SetTitle( aFields[nCount,5] )
			oColumn:SetSize( aFields[nCount,3] )
			oColumn:SetDecimal( aFields[nCount,4] )
			oColumn:SetPicture( aFields[nCount,7] )
			aAdd(aColumn, oColumn)
		EndIf
	Next nCount

Return aColumn
