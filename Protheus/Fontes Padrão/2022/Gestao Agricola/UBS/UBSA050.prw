#include 'totvs.ch'
#include 'UBSA050.ch'
#include 'fwmvcdef.ch'
/*/{Protheus.doc} UBSA050(aTmpHeader,aTmpCols,cCodProd,cCodLocal,cItem)  
	Rotina para reservar lotes e vincular ao contrato
	@type Function
	@author gustavo.hbaptista
	@since 01/2021
	@return nil
/*/
Function UBSA050(aTmpHeader,aTmpCols,cCodProd,cCodLocal,cItem)  
	Local aCoors  := FWGetDialogSize( oMainWnd ) 
	Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseUp, oRelacZA4, oRelacZA5 
	Local nPosPro
	Local nPosLoc
	Local nPosItem
	
	Private oDlgPrinc
	Private oLeftBrw,oRightBrw

	if !Empty(aTmpHeader)
		nPosPro := aScan(aTmpHeader,{|x| Alltrim(x[2])=='ADB_CODPRO'})
		nPosLoc := aScan(aTmpHeader,{|x| Alltrim(x[2])=='ADB_LOCAL'})
		nPosItem := aScan(aTmpHeader,{|x| Alltrim(x[2])=='ADB_ITEM'})

		cCodProd := aTmpCols[n][nPosPro]
		cCodLocal := aTmpCols[n][nPosLoc]
		cItem := aTmpCols[n][nPosItem]
		
		xcNumCtr:= M->ADA_NUMCTR
		_cCodCli:= M->ADA_CODCLI
		_cLoja:= M->ADA_LOJCLI
	//	_cCliente:= M->ADA_NOMCLI
		_cSafra:= M->ADA_CODSAF
	else
		xcNumCtr:= ADA->ADA_NUMCTR
		_cCodCli:= ADA->ADA_CODCLI
		_cLoja:= ADA->ADA_LOJCLI
		//_cCliente:= ADA->ADA_NOMCLI
		_cSafra:= ADA->ADA_CODSAF
	endif

	If !TableInDic('NLP')
        // necessário a atualização do sistema para a expedição mais recente
        MsgNextRel()
	else
		dbSelectArea("NLP")
		if !Empty(cCodProd) .AND. !Empty(cCodLocal)
			Define MsDialog oDlgPrinc Title STR0008 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] pixel
				aSize := MsAdvSize()

				oFWLayer := FWLayer():New() 
				oFWLayer:Init( oDlgPrinc, .F., .T. )
				// 
				// Define Painel Superior 
				oFWLayer:AddLine( 'UP', 20, .F. )                        
				oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )             
				oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )
				// 
				// Painel Inferior 
				oFWLayer:AddLine( 'DOWN', 80, .F. )
				oFWLayer:AddCollumn( 'LEFT' ,  45, .T., 'DOWN' )
				oFWLayer:AddCollumn( 'MID' ,  10, .T., 'DOWN' )
				oFWLayer:AddCollumn( 'RIGHT',  45, .T., 'DOWN' )			
				oLeftPanel  := oFWLayer:GetColPanel( 'LEFT' , 'DOWN' )  // Pego o objeto do pedaço esquerdo 
				oRightPanel := oFWLayer:GetColPanel( 'RIGHT', 'DOWN' )  // Pego o objeto do pedaço direito 
				// FWmBrowse Superior Albuns 
				oGroupHeader := TGroup():New(00 , 00, 70, aSize[3] - 5,STR0011,oPanelUp,CLR_BLACK,CLR_WHITE,.T.)
				oHeader := LoadHeader(oPanelUP, aSize, aTmpCols, cCodProd,cItem,aTmpHeader)
				// Lado Esquerdo
				oGroupLeft := TGroup():New(0,0, oFWLayer:GETLAYERHEIGHT()/2.6, oFWLayer:GETLAYERHEIGHT()/2.2,STR0009,oLeftPanel,CLR_BLACK,CLR_WHITE,.T.)
				cAliasLft:= getLeftBrw(oGroupLeft,cCodProd,cCodLocal,cItem,xcNumCtr,_cCodCli,_cLoja,_cSafra)
				// Lado Direito Autores/Interpretes 
				oGroupRight := TGroup():New(01, 01, oFWLayer:GETLAYERHEIGHT()/2.6, oFWLayer:GETLAYERHEIGHT()/2.2,STR0010,oRightPanel,CLR_BLACK,CLR_WHITE,.T.)
				cAliasRgt:= getRightBrw(oGroupRight,cCodProd,cCodLocal,cItem,xcNumCtr,_cCodCli,_cLoja,_cSafra)
				oBtAdd := TBtnBmp2():New(aSize[6]/2  ,aSize[5]/2,26,26,'PMSSETADIR',,,,{||addItem(cAliasLft,cAliasRgt)},oDlgPrinc,,,.T.)
   				oBtRmv := TBtnBmp2():New(aSize[6]/1.5,aSize[5]/2,26,26,'PMSSETAESQ',,,,{||rmvItem(cAliasLft,cAliasRgt)},oDlgPrinc,,,.T.)
				oBtSave:= TButton():New( aSize[8], aSize[6],STR0012,oDlgPrinc,{||saveAll(oDlgPrinc,cAliasRgt,cItem,cCodProd,cCodLocal,xcNumCtr,_cCodCli,_cLoja,_cSafra)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			Activate MsDialog oDlgPrinc Center
		else
			msginfo(STR0015)
		EndIf
	endif
	
Return NIL

/*/{Protheus.doc} LoadHeader(oPanelUP, aSize, aTmpCols, aTmpHeader)
	Monta cabeçalho
	@type  Static Function
	@author gustavo.hbaptista
	@since 01/2021
	@return nil
/*/
Static Function LoadHeader(oPanelUP, aSize, aTmpCols, cCodProd,cItem,aTmpHeader)

    Local aFields as array
    Local nX as numeric
    Local nRow as numeric
    Local nColumn as numeric
    Local nFieldSize as numeric
    Local bCodeBlock as codeblock
    Local oGet as object
	Local cItem
	Local cCodProd
	Local cDesProd
	Local nQuant
	Local cNumCtr
	Local cCodCli
	Local cLoja
	Local cCliente
	Local cSafra

    aFields := {'ADA_NUMCTR', 'ADB_ITEM', 'ADA_CODCLI', 'ADA_LOJCLI', 'ADA_NOMCLI', 'ADA_SAFRA','ADB_CODPRO', 'ADB_DESPRO', 'ADB_QUANT'} 
    nRow := 10
    nColumn := 10

	if !Empty(aTmpHeader)
		nPosPro := aScan(aTmpHeader,{|x| Alltrim(x[2])=='ADB_CODPRO'})
		nPosDesPro := aScan(aTmpHeader,{|x| Alltrim(x[2])=='ADB_DESPRO'})
		nPosItem := aScan(aTmpHeader,{|x| Alltrim(x[2])=='ADB_ITEM'})
		nPosQnt := aScan(aTmpHeader,{|x| Alltrim(x[2])=='ADB_QUANT'})

		cCodProd := aTmpCols[n][nPosPro]
		cDesProd := aTmpCols[n][nPosDesPro]
		cItem := aTmpCols[n][nPosItem]
		nQuant := aTmpCols[n][nPosQnt]
		cNumCtr:= M->ADA_NUMCTR
		cCodCli:= M->ADA_CODCLI
		cLoja:= M->ADA_LOJCLI
		cCliente:= M->ADA_NOMCLI
		cSafra:= M->ADA_CODSAF
	else
		dbSelectArea("ADB")
		dbSetOrder(1)
		if dbSeek(fwxFilial("ADB")+ADA->ADA_NUMCTR+cItem)
			cDesProd := ADB->ADB_DESPRO
			nQuant :=ADB->ADB_QUANT
		endIf
		cNumCtr:= ADA->ADA_NUMCTR
		cCodCli:= ADA->ADA_CODCLI
		cLoja:= ADA->ADA_LOJCLI
		cCliente:= Posicione("SA1",1,fwxFilial("SA1")+ADA->(ADA_CODCLI+ADA_LOJCLI),"A1_NOME")
		cSafra:= ADA->ADA_CODSAF

	endif

    For nX := 1 To Len(aFields)

        nFieldSize := (TamSX3(aFields[nX])[1] + 10) * 2

        If nColumn + nFieldSize > aSize[3]
            nColumn := 10
            nRow += 30
        EndIf

        if aFields[nX] == 'ADA_NUMCTR'
			//bCodeBlock := {||cNumCtr}
			oGet := TGet():New( nRow, nColumn, {||cNumCtr}, /*oPanelUP*/ , nFieldSize,015,/*PesqPict('NLP',aFields[nX])*/,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,,,,,,,FWX3Titulo(aFields[nX]), 1)
		elseif aFields[nX] == 'ADB_ITEM'
			//bCodeBlock := {||cItem}
			oGet := TGet():New( nRow, nColumn, {||cItem}, /*oPanelUP*/, nFieldSize,015,/*PesqPict('NLP',aFields[nX])*/,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,,,,,,,FWX3Titulo(aFields[nX]), 1)
		elseif aFields[nX] == 'ADA_CODCLI'
			//bCodeBlock := {||cCodCli}
			oGet := TGet():New( nRow, nColumn, {||cCodCli},/*oPanelUP*/, nFieldSize,015,/*PesqPict('NLP',aFields[nX])*/,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,,,,,,,FWX3Titulo(aFields[nX]), 1)
		elseif aFields[nX] == 'ADA_LOJCLI'
			//bCodeBlock := {||cLoja}
			oGet := TGet():New( nRow, nColumn, {||cLoja}, /*oPanelUP*/, nFieldSize,015,/*PesqPict('NLP',aFields[nX])*/,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,,,,,,,FWX3Titulo(aFields[nX]), 1)
		elseif aFields[nX] == 'ADA_NOMCLI'
			//bCodeBlock := {||cCliente}
			oGet := TGet():New( nRow, nColumn, {||cCliente}, /*oPanelUP*/, nFieldSize,015,/*PesqPict('NLP',aFields[nX])*/,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,,,,,,,FWX3Titulo(aFields[nX]), 1)
		elseif aFields[nX] == 'ADA_SAFRA'
			//bCodeBlock := {||cSafra}
			oGet := TGet():New( nRow, nColumn, {||cSafra}, /*oPanelUP*/, nFieldSize,015,/*PesqPict('NLP',aFields[nX])*/,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,,,,,,,FWX3Titulo(aFields[nX]), 1)
		elseif aFields[nX] == 'ADB_CODPRO'
			//bCodeBlock := {||cCodProd}
			oGet := TGet():New( nRow, nColumn, {||cCodProd}, /*oPanelUP*/, nFieldSize,015,/*PesqPict('NLP',aFields[nX])*/,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,,,,,,,FWX3Titulo(aFields[nX]), 1)
		elseif aFields[nX] == 'ADB_DESPRO'
			//bCodeBlock := {||cDesProd}
			oGet := TGet():New( nRow, nColumn, {||cDesProd}, /*oPanelUP*/, nFieldSize,015,/*PesqPict('NLP',aFields[nX])*/,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,,,,,,,FWX3Titulo(aFields[nX]), 1)
		elseif aFields[nX] == 'ADB_QUANT'
			//bCodeBlock := {||nQuant}
			oGet := TGet():New( nRow, nColumn, {||nQuant}, /*oPanelUP*/, nFieldSize,015,/*PesqPict('NLP',aFields[nX])*/,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,,,,,,,FWX3Titulo(aFields[nX]), 1)
		endIf
        nColumn += nFieldSize + 10
    Next

Return oGet

/*/{Protheus.doc} getLeftBrw(oLeftPanel,cCodProd,cCodLocal,cItem)
	Monta browser da esquerda
	@type  Static Function
	@author gustavo.hbaptista
	@since 01/2021
	@return nil
/*/
Static Function getLeftBrw(oLeftPanel,cCodProd,cCodLocal,cItem)
	Local cAliasLote:= GetNextAlias()
	Local aFields :={}
	Local nCol := 0
	Local aCols := {}
	Local nX := 1
	Local lMarkAll := .F.

	aFields:=LeftField()
	//Monta as colunas desconsiderando os campos abaixo
	For nX := 1 to Len(aFields)
		if aFields[nX,1] != 'MARK' .AND. aFields[nX,1] != 'NLP_CODSAF' .AND. aFields[nX,1] != 'NLP_CODPRO'
			aAdd(aCols,FWBrwColumn():New())
			aCols[Len(aCols)]:SetData(&("{||"+aFields[nX,1]+"}"))
			aCols[Len(aCols)]:SetTitle(aFields[nX,5])
			aCols[Len(aCols)]:SetPicture(aFields[nX,6])
			aCols[Len(aCols)]:SetType(aFields[nX,2])
			aCols[Len(aCols)]:SetSize(aFields[nX,3])
			aCols[Len(aCols)]:SetReadVar(aFields[nX,1])
		endif
	Next nX

	cAliasLote:= getLeftTmpTb(cAliasLote,aFields)

	LeftData(cAliasLote,cCodProd,cCodLocal,cItem,xcNumCtr,_cCodCli,_cLoja,_cSafra)

	oLeftBrw:= FWMarkBrowse():New("oLeftModel")
	oLeftBrw:SetOwner( oLeftPanel )
	oLeftBrw:SetMenuDef( '' )
	oLeftBrw:SetAlias( cAliasLote )
	oLeftBrw:SetFieldMark( 'MARK' )
	oLeftBrw:SetColumns(aCols)
	oLeftBrw:SetTemporary(.T.)	
	oLeftBrw:SetProfileID( '2' )
	oLeftBrw:AddButton('Rastreio de lote',{||visRastro(cAliasLote)},,1)
	oLeftBrw:bAllMark := { ||SetMarkAll(oLeftBrw, lMarkAll := !lMarkAll ), oLeftBrw:Refresh(.T.)}
	oLeftBrw:Activate()
Return cAliasLote

/*/{Protheus.doc} LeftField()
	Lista campos para serem usados no mark da esquerda
	@type  Static Function
	@author gustavo.hbaptista
	@since 01/2021
	@return nil
/*/
Static Function LeftField()
	Local aFields := {}

	aAdd(aFields,{ "MARK","C",1,0,"X","@!"})
	aAdd(aFields,{"NLP_LOTE",TamSX3("NPN_LOTE")[3],TamSX3("NPN_LOTE")[1],TamSX3("NPN_LOTE")[2],AGRTITULO("N92_CODIGO"),PesqPict("NPN", "NPN_LOTE")})
	aAdd(aFields,{"NLP_QUANT",TamSX3("ADB_QUANT")[3],TamSX3("ADB_QUANT")[1],TamSX3("ADB_QUANT")[2],AGRTITULO("ADB_QUANT"),PesqPict("ADB", "ADB_QUANT")})
	aAdd(aFields,{"NLP_TSI","C",3,0,"TSI","@!"})
	aAdd(aFields,{"NLP_CODSAF",TamSX3("NLP_CODSAF")[3],TamSX3("NLP_CODSAF")[1],TamSX3("NLP_CODSAF")[2],AGRTITULO("NLP_CODSAF"),PesqPict("NLP", "NLP_CODSAF")})
	aAdd(aFields,{"NLP_CODPRO",TamSX3("NLP_CODPRO")[3],TamSX3("NLP_CODPRO")[1],TamSX3("NLP_CODPRO")[2],AGRTITULO("NLP_CODPRO"),PesqPict("NLP", "NLP_CODPRO")})
Return aFields

/*/{Protheus.doc} getLeftTmpTb(cAlias,aFields)
	Gera a temp table da direita
	@type  Static Function
	@author gustavo.hbaptista
	@since 01/2021
	@return nil
/*/
Static Function getLeftTmpTb(cAlias,aFields)
	tLeftTbl:= FwTemporaryTable():New(cAlias,aFields)
	tLeftTbl:Create()
Return cAlias

/*/{Protheus.doc} LeftData
	@type  Static Function
	@author gustavo.hbaptista
	@since 01/2021
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Static Function LeftData(cAlias,cCodProd,cCodLocal,cItem,xcNumCtr,_cCodCli,_cLoja,_cSafra)

	Local nX := 0
	Local cAliasNP9:= GetNextAlias()

	//para o NP9 ser um cara selecionável, ele deve ter o B8_SALDO > 0.. B8_FILIAL - B8_PRODUTO = ADB_CODPRO - B8_LOCAL = ADB_LOCAL - B8_DTVALID <= dDataBase
	//não estar em outra NLP... having count NPL = 0 
	//não estar em nenhuma NPH ( ordem de carregamento )
	//AND NP9_PROD = %Exp:cCodProd%
	BeginSql Alias cAliasNP9
		SELECT NP9_LOTE, NP9_PROD, NP9_LOCAL, NP9_DATA, NP9_QUANT, NP9_TRATO
			FROM %table:NP9%
		WHERE NP9_FILIAL = %xFilial:NP9%
			AND NP9_LOCAL = %Exp:cCodLocal%
			AND NP9_CODSAF = %Exp:_cSafra%
			AND %notDel%
	EndSql
	while (cAliasNP9)->(!Eof())

		If (cAliasNP9)->NP9_TRATO == '1'
			cTsi := STR0013
		Else
			cTsi := STR0014
		EndIf

		cAliasNLP := GetNextAlias()
		BeginSql Alias cAliasNLP
			SELECT NLP_NUMCTR
				FROM %table:NLP%
			WHERE NLP_FILIAL = %xFilial:NLP%
				AND NLP_LOTE = %Exp:(cAliasNP9)->NP9_LOTE%
				AND NLP_TSI = %Exp:(cAliasNP9)->NP9_TRATO%
				AND %notDel%
		EndSql
		//Se não encontrou este produto/item/lote em nenhum outro contrato, então pode listar
		if (cAliasNLP)->(EOF())
		//buscar na NPH(item de autorização na ordem de carregamento), se achar, verifica na NPN (item da ordem de carregamento), se achar, não apresenta na lista de lotes disponíveis
			cAliasNPN := GetNextAlias()
			BeginSql Alias cAliasNPN
				Select NPN_ITEMAC
					FROM %table:NPN%
				WHERE NPN_FILIAL = %xFilial:NPN%
					and NPN_LOTE = %Exp:(cAliasNP9)->(NP9_LOTE)%
					and NPN_CODPRO = %Exp:cCodProd%
					and NPN_LOCAL  = %Exp:cCodLocal%
					AND %notDel%
			EndSql

			if (cAliasNPN)->(EOF())
				If RecLock(cAlias,.T.)
					(cAlias)->NLP_LOTE  := (cAliasNP9)->(NP9_LOTE)
					(cAlias)->NLP_QUANT := (cAliasNP9)->(NP9_QUANT)
					(cAlias)->NLP_TSI := cTsi
					(cAlias)->NLP_CODSAF := _cSafra
					(cAlias)->NLP_CODPRO := cCodProd
					(cAlias)->(MsUnlock())
				EndIf
			endif
			(cAliasNPN)->(DBCloseArea())
		endif
		(cAliasNLP)->(DBCloseArea())
		(cAliasNP9)->(dbSkip())
	endDo
Return

/*/{Protheus.doc} getRightBrw(oRightPanel,cCodProd,cCodLocal,cItem)
	Gera o browser da direita
	@type  Static Function
	@author gustavo.hbaptista
	@since 01/2021
	@return nil
/*/
Static Function getRightBrw(oRightPanel,cCodProd,cCodLocal,cItem,xcNumCtr,_cCodCli,_cLoja,_cSafra)
	Local cAlias:= GetNextAlias()
	Local aFields :={}
	Local nCol := 0
	Local aCols := {}
	Local nX := 1
	Local lMarkAll := .F.

	aFields:=rightField()
	//Monta as colunas desconsiderando os campos abaixo
	For nX := 1 to Len(aFields)
		if aFields[nX,1] != 'MARK' .AND. aFields[nX,1] != 'NLP_CODSAF' .AND. aFields[nX,1] != 'NLP_CODPRO'
			aAdd(aCols,FWBrwColumn():New())
			aCols[Len(aCols)]:SetData(&("{||"+aFields[nX,1]+"}"))
			aCols[Len(aCols)]:SetTitle(aFields[nX,5])
			aCols[Len(aCols)]:SetPicture(aFields[nX,6])
			aCols[Len(aCols)]:SetType(aFields[nX,2])
			aCols[Len(aCols)]:SetSize(aFields[nX,3])
			aCols[Len(aCols)]:SetReadVar(aFields[nX,1])
		endif
	Next nX

	cAlias:= rightTmp(cAlias,aFields)

	rightData(cAlias,cCodProd,cCodLocal,cItem,xcNumCtr,_cCodCli,_cLoja,_cSafra)

	oRightBrw:= FWMarkBrowse():New("oRightModel")
	oRightBrw:SetOwner( oRightPanel )
	oRightBrw:SetMenuDef( '' )
	oRightBrw:SetAlias( cAlias )
	oRightBrw:SetFieldMark( 'MARK' )
	oRightBrw:SetColumns(aCols)
	oRightBrw:SetTemporary(.T.)	
	oRightBrw:SetProfileID( '2' )
	oRightBrw:bAllMark := { ||SetMarkAll(oRightBrw, lMarkAll := !lMarkAll ), oRightBrw:Refresh(.T.)}
	oRightBrw:AddButton('Rastreio de lote',{||visRastro(cAlias)},,1)
	oRightBrw:Activate()
Return cAlias

/*/{Protheus.doc} rightField()
	Lista campos para serem usados no mark da direita
	@type  Static Function
	@author gustavo.hbaptista
	@since 01/2021
	@return nil
/*/
Static Function rightField()

	Local aFields := {}

	aAdd(aFields,{ "MARK","C",1,0,"X","@!"})
	aAdd(aFields,{"NLP_LOTE",TamSX3("NPN_LOTE")[3],TamSX3("NPN_LOTE")[1],TamSX3("NPN_LOTE")[2],AGRTITULO("N92_CODIGO"),PesqPict("NPN", "NPN_LOTE")})
	aAdd(aFields,{"NLP_QUANT",TamSX3("ADB_QUANT")[3],TamSX3("ADB_QUANT")[1],TamSX3("ADB_QUANT")[2],AGRTITULO("ADB_QUANT"),PesqPict("ADB", "ADB_QUANT")})
	aAdd(aFields,{"NLP_TSI","C",3,0,"TSI","@!"})
	aAdd(aFields,{"NLP_CODSAF",TamSX3("NLP_CODSAF")[3],TamSX3("NLP_CODSAF")[1],TamSX3("NLP_CODSAF")[2],AGRTITULO("NLP_CODSAF"),PesqPict("NLP", "NLP_CODSAF")})
	aAdd(aFields,{"NLP_CODPRO",TamSX3("NLP_CODPRO")[3],TamSX3("NLP_CODPRO")[1],TamSX3("NLP_CODPRO")[2],AGRTITULO("NLP_CODPRO"),PesqPict("NLP", "NLP_CODPRO")})

Return aFields

/*/{Protheus.doc} rightTmp(cAlias,aFields)
	Carrega os dados do browser da esquerda
	@type  Static Function
	@author gustavo.hbaptista
	@since 01/2021
	@return nil
/*/
Static Function rightTmp(cAlias,aFields)
	tRightTbl:= FwTemporaryTable():New(cAlias,aFields)
	tRightTbl:AddIndex( "01", {"NLP_LOTE","NLP_TSI"} )
	tRightTbl:Create()
	
Return cAlias

/*/{Protheus.doc} rightData(cAlias,cCodProd,cCodLocal,cItem)
	Carrega os dados do browser da esquerda
	@type  Static Function
	@author gustavo.hbaptista
	@since 01/2021
	@return nil
/*/
Static Function rightData(cAlias,cCodProd,cCodLocal,cItem,xcNumCtr,_cCodCli,_cLoja,_cSafra)
	Local cAliasNLP := GetNextAlias()

	BeginSql Alias cAliasNLP
		SELECT NLP_LOTE, NLP_QUANT, NLP_CODPRO, NLP_NUMCTR, NLP_ITEM, NLP_TSI, NLP_CODSAF
			FROM %table:NLP%
		WHERE NLP_FILIAL = %xFilial:NLP%
			and NLP_NUMCTR = %Exp:xcNumCtr%
			and NLP_ITEM = %Exp:cItem%	
			AND %notDel%
	EndSql

	(cAliasNLP)->(DbGotop())
	while (cAliasNLP)->(!Eof())
		if (cAliasNLP)->(NLP_TSI) == '1'
			cTsi:= STR0013
		else
			cTsi:= STR0014
		endif
		If RecLock(cAlias,.T.)
			(cAlias)->NLP_LOTE  := (cAliasNLP)->(NLP_LOTE)
			(cAlias)->NLP_QUANT := (cAliasNLP)->(NLP_QUANT)
			(cAlias)->NLP_TSI := cTsi
			(cAlias)->NLP_CODSAF :=(cAliasNLP)->(NLP_CODSAF)
			(cAlias)->NLP_CODPRO :=(cAliasNLP)->(NLP_CODPRO)
			(cAlias)->(MsUnlock())
		EndIf
		(cAliasNLP)->(dbSkip())
	endDo
Return

/*/{Protheus.doc} addItem(cAliasLft,cAliasRgt)
	Move todas as linhas marcadas do markBrowser da esquerda para o mark da direita
	@type  Static Function
	@author gustavo.hbaptista
	@since 01/2021
	@return nil
/*/
Static Function addItem(cAliasLft,cAliasRgt)
	
	(cAliasLft)->(DBGoTop())
	while (cAliasLft)->(!EOF())
		if Alltrim((cAliasLft)->(MARK)) != ''
			if RecLock(cAliasRgt,.T.)
				(cAliasRgt)->NLP_LOTE := (cAliasLft)->NLP_LOTE
				(cAliasRgt)->NLP_QUANT := (cAliasLft)->NLP_QUANT
				(cAliasRgt)->NLP_TSI := (cAliasLft)->NLP_TSI
				(cAliasRgt)->NLP_CODSAF := (cAliasLft)->NLP_CODSAF
				(cAliasRgt)->NLP_CODPRO := (cAliasLft)->NLP_CODPRO
			endif
			if RecLock(cAliasLft,.F.)
				(cAliasLft)->(dbDelete())
			endif
		endIf
		(cAliasLft)->(dbSkip())
	endDo

	oRightBrw:Refresh(.T.)
	oLeftBrw:Refresh(.T.)

Return

/*/{Protheus.doc} rmvItem(cAliasLft,cAliasRgt)
	Move todas as linhas marcadas do markBrowser da direita para o mark da esquerda
	@type  Static Function
	@author gustavo.hbaptista
	@since 01/2021
	@return nil
/*/
Static Function rmvItem(cAliasLft,cAliasRgt)
	
	(cAliasRgt)->(DBGoTop())
	while (cAliasRgt)->(!EOF())
		if Alltrim((cAliasRgt)->(MARK)) != ''
			if RecLock(cAliasLft,.T.)
				(cAliasLft)->NLP_LOTE := (cAliasRgt)->NLP_LOTE
				(cAliasLft)->NLP_QUANT := (cAliasRgt)->NLP_QUANT
				(cAliasLft)->NLP_TSI := (cAliasRgt)->NLP_TSI
				(cAliasLft)->NLP_CODSAF := (cAliasRgt)->NLP_CODSAF
				(cAliasLft)->NLP_CODPRO := (cAliasRgt)->NLP_CODPRO
			endif
			if RecLock(cAliasRgt,.F.)
				(cAliasRgt)->(dbDelete())
			endif
		endIf
		(cAliasRgt)->(dbSkip())
	endDo

	oRightBrw:Refresh(.T.)
	oLeftBrw:Refresh(.T.)

Return

/*/{Protheus.doc} SetMarkAll(oMrkBrowse,lMarcar )
	Marca todas as linhas do markBrowser
	@type  Static Function
	@author gustavo.hbaptista
	@since 01/2021
	@return nil
/*/
Static Function SetMarkAll(oMrkBrowse,lMarcar )

	(oMrkBrowse:Alias())->( DbGotop() )
	While !( oMrkBrowse:Alias() )->( Eof() )
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->MARK  :=  IIf( lMarcar, oMrkBrowse:Mark(), "" )
		(oMrkBrowse:Alias())->(MsUnLock())
		(oMrkBrowse:Alias())->(DbSkip() )
	EndDo

Return .T.

/*/{Protheus.doc} SaveAll(oDlg,cAliasRgt,cItem,cCodProd)
	Salva os dados na NLP
	@type  Static Function
	@author gustavo.hbaptista
	@since 01/2021
	@return nil
	/*/
 Static Function saveAll(oDlg,cAliasRgt,cItem,cCodProd,cCodLocal,xcNumCtr,_cCodCli,_cLoja,_cSafra)
	Local cAliasNlp := GetNextAlias()
	Local cNlpTsi   := '1'

	BeginSql Alias cAliasNLP
		SELECT NLP_LOTE, NLP_QUANT, NLP_TSI
			FROM %table:NLP%
		WHERE NLP_FILIAL = %xFilial:NLP%
			and NLP_NUMCTR = %Exp:xcNumCtr%
			and NLP_CODPRO = %Exp:cCodProd%
			and NLP_ITEM = %Exp:cItem%
			AND %notDel%
	EndSql

	if (cAliasNLP)->(Eof())
		(cAliasRgt)->(DbGotop())
		while (cAliasRgt)->(!Eof())
			if (cAliasRgt)->NLP_TSI == STR0013
				cNlpTsi:= '1'
			else
				cNlpTsi:= '2'
			endif
			if RecLock("NLP",.T.)
				NLP->NLP_FILIAL := fwxFilial("NLP")
				NLP->NLP_NUMCTR := xcNumCtr
				NLP->NLP_CODPRO := cCodProd
				NLP->NLP_ITEM 	:= cItem
				NLP->NLP_LOTE 	:= (cAliasRgt)->NLP_LOTE
				NLP->NLP_QUANT  := (cAliasRgt)->NLP_QUANT
				NLP->NLP_TSI	:= cNlpTsi
				NLP->NLP_LOCAL  := cCodLocal
				NLP->NLP_CODSAF := _cSafra
				NLP->(MSUNLOCK())
			endif
			(cAliasRgt)->(dbSkip())
		endDo
	else
		while (cAliasNLP)->(!Eof())
			
			(cAliasRgt)->(dbSetOrder(1))
			if (cAliasRgt)->(dbSeek((cAliasNLP)->(NLP_LOTE+NLP_TSI)))
				RecLock(cAliasRgt,.F.)
				(cAliasRgt)->(dbDelete())
			else
				dbSelectArea('NLP')
				dbSetOrder(1)
				if dbSeek(fwxFilial('NLP')+xcNumCtr+cItem+(cAliasNLP)->(NLP_LOTE+NLP_TSI))
					RecLock('NLP',.F.)
					NLP->(dbDelete())
					RecLock(cAliasRgt,.F.)
					(cAliasRgt)->(dbDelete())
				endif
			endif
			(cAliasNLP)->(dbSkip())			
		endDo

		//depois de eliminar da temporária tudo o que já havia em banco, agora inclui tudo o que restou no array faltava
		(cAliasRgt)->(DbGotop())
		while (cAliasRgt)->(!Eof())
			dbSelectArea("NLP")
			dbSetOrder(1)
			if !dbSeek(fwxFilial("NLP")+xcNumCtr+cItem+(cAliasRgt)->(NLP_LOTE+NLP_TSI))
				if (cAliasRgt)->NLP_TSI == STR0013
					cNlpTsi:= '1'
				else
					cNlpTsi:= '2'
				endif
				if RecLock("NLP",.T.)
					NLP->NLP_FILIAL := fwxFilial("NLP")
					NLP->NLP_NUMCTR := xcNumCtr
					NLP->NLP_CODPRO := cCodProd
					NLP->NLP_ITEM 	:= cItem
					NLP->NLP_LOTE 	:= (cAliasRgt)->NLP_LOTE
					NLP->NLP_QUANT  := (cAliasRgt)->NLP_QUANT
					NLP->NLP_TSI	:= cNlpTsi 
					NLP->NLP_LOCAL  := cCodLocal
					NLP->NLP_CODSAF := _cSafra
					NLP->(MSUNLOCK())
				endif
			endIf
			(cAliasRgt)->(dbSkip())
		endDo
	endif
	oDlg:End()
Return

/*/{Protheus.doc} visRastro(cAlias)
	Visualiza rastreabilidade de lote
	@type  Static Function
	@author gustavo.hbaptista
	@since 01/2021
	@param cAlias, GetNextAlias, Alias que tem a safra e lote posicionados
	@return nil
	/*/
Static Function visRastro(cAlias)
	dbSelectArea("NP9")
	dbSetOrder(3)
	if dbSeek(fwxFilial("NP9")+(cAlias)->(NLP_CODSAF+NLP_LOTE))
		UBS040VIS()
	endIf
Return

Function del400nlp( cNumCtr, cCodPro, cItem )

	If TableInDic('NLP')
		dbSelectArea("NLP")
		NLP->(dbSetOrder(1))
		while dbSeek(xFilial("NLP")+cNumCtr+cItem)
			RecLock("NLP",.F.)
			NLP->(dbDelete())
			NLP->(MsUnlock())
			NLP->(DbSkip())
		endDo
	endIf
Return