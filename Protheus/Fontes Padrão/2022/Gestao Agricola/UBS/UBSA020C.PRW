
#Include 'totvs.ch'
#Include 'FWMVCDEF.CH'

/*{Protheus.doc} UBSA020C
Função que Mostra os lotes direcionados por PV e item do PV
@param     cPedido = Pedido de vendas, cItemPV = Item do PV
@sample    UBSA020C
@return    Nil
@author    AgroIndustria
@since      Agosto/2020
@version    P12
*/

Function UBSA020C( cPedido, cItemPV)
    Local cAliasQRY		:= GetNextAlias()
	Local cAliasTMP		:= GetNextAlias()
	local cIndice 		:= ""
	Local aSeek 		:= {}
	Local aColumns		:= {}

	Local aCposTmp		:= {}
	Local aIndex		:= {}
	Local nPos			:= 0
	Local aFldfilter	:= {}
	Local nX            := 0
	Local nY 			:= 0
	Local cSqlFilter	:= 0

	Default cPedido =''
	Default cItemPV=''

    
	cSqlFilter :=''
	IF !Empty(cPedido)
		 cSqlFilter += " AND ND6.ND6_PEDIDO = '" 	+ cPedido 		+ "' "
	EndIF
	    
	IF !Empty(cItemPV)
		 cSqlFilter += " AND ND6.ND6_ITEMPV = '" 	+ cItemPV 		+ "' "
	EndIF

	If Empty(cSqlFilter)
		cSqlFilter := "%%"
	Else
		cSqlFilter := "% " + cSqlFilter + " %"
	Endif
	

	BeginSQL Alias cAliasQRY
		COLUMN ND5_DTDIR AS DATE
		SELECT ND6.ND6_PEDIDO, ND6.ND6_ITEMPV, ND5.ND5_DTDIR, ND6.ND6_LOTE, ND6.ND6_SUBLOT, ND6.ND6_QT,ND5_CODSAF, ND5.ND5_CTVAR, 
		       ND5.ND5_CULTRA,ND5.ND5_CATEG, ND5.ND5_PENE 
			FROM %Table:ND6% ND6
			INNER JOIN  %Table:ND5% ND5
     			ON ND5.%notDel%
				AND ND5.ND5_FILIAL = %xFilial:ND5% 
     			AND ND5.ND5_CODIGO = ND6.ND6_CODIGO
                AND  ND5.ND5_STATUS = '1'
		WHERE 	ND6.%notDel%
		AND 	ND6.ND6_FILIAL = %xFilial:ND6% 
				%exp:cSqlFilter%  
		
		ORDER BY ND6.ND6_PEDIDO,ND6.ND6_ITEMPV,ND6_LOTE
	EndSQL

	///EECVIEW(getLastQuery()[2],'XXX')
	

	// Array com os campos para criacao do arquivo de trabalho.
	aCposTmp   := {	{"ND6_PEDIDO",	TamSX3("ND6_PEDIDO")[3], 	TamSX3("ND6_PEDIDO")[1],	TamSX3("ND6_PEDIDO")[2]	},;
					{"ND6_ITEMPV",	TamSX3("ND6_ITEMPV")[3], 	TamSX3("ND6_ITEMPV")[1],	TamSX3("ND6_ITEMPV")[2] },;
					{"ND5_DTDIR",	TamSX3("ND5_DTDIR")[3], 	TamSX3("ND5_DTDIR")[1], 	TamSX3("ND5_DTDIR")[2]	},;
					{"ND6_LOTE",	TamSX3("ND6_LOTE")[3],		TamSX3("ND6_LOTE")[1],		TamSX3("ND6_LOTE")[2]	},;
					{"ND6_SUBLOT",	TamSX3("ND6_SUBLOT")[3], 	TamSX3("ND6_SUBLOT")[1],	TamSX3("ND6_SUBLOT")[2] },;
					{"ND6_QT",		TamSX3("ND6_QT")[3], 		TamSX3("ND6_QT")[1], 		TamSX3("ND6_QT")[2] 	},;
					{"ND5_CODSAF", 	TamSX3("ND5_CODSAF")[3], 	TamSX3("ND5_CODSAF")[1], 	TamSX3("ND5_CODSAF")[2] },;
					{"ND5_CTVAR", 	TamSX3("ND5_CTVAR")[3], 	TamSX3("ND5_CTVAR")[1], 	TamSX3("ND5_CTVAR")[2] 	},;
					{"ND5_CULTRA",	TamSX3("ND5_CULTRA")[3],	TamSX3("ND5_CULTRA")[1], 	TamSX3("ND5_CULTRA")[2] },;
					{"ND5_CATEG", 	TamSX3("ND5_CATEG")[3],		TamSX3("ND5_CATEG")[1], 	TamSX3("ND5_CATEG")[2] 	},;
					{"ND5_PENE",	TamSX3("ND5_PENE")[3], 		TamSX3("ND5_PENE")[1], 		TamSX3("ND5_PENE")[2] 	}}
				

	aIndex := {}
	
	aadd(aIndex,{'ND6_PEDIDO','ND6_ITEMPV','ND6_LOTE'})
	
	oTempTable:= FWTemporaryTable():New( cAliasTMP )	// Cria o objeto da tabela tempor?ia
	oTempTable:SetFields(aCposTmp)						// Informa a estrutura da tabela tempor?ia 
	For nx := 1 to Len (aIndex)
	   oTempTable:AddIndex( cValtochar(nX),aIndex[nX] )	// Atribui o ?dice ?tabela tempor?ia
	nExt nX
	oTempTable:Create()										// Cria a tabela tempor?ia
				
	( cAliasQRY )->( dbGoTop() )

	aTmpStruct := (cAliasTMP )->( DbStruct() )   //Pego Strutura do arquivo temporario
	
	While (cAliasQRY)->( !Eof() )
		
		DbSelectArea(cAliasTMP)
		///(cAliasTMP)->( dbSetOrder(1) )

		IF  RecLock(cAliasTMP, .t.)
			DbSelectArea(cAliasQRY)
			For nx := 1 To Fcount()
				nPos := aScan(aCposTMP,{|x| AllTrim(x[1]) == Fieldname(nx)})
				If nPos > 0
					x := (cAliasQRY )+"->"+Fieldname(nx)
					y := (cAliasTMP)+"->"+Fieldname(nx)
					&y. := &x.
				EndIf
			Next nx
			(cAliasTMP)->( Msunlock() )
		EndIF
		(cAliasQRY)->(dbSkip())		
	EndDo
	

	//Campos a aparecer no browse.
	acPosBRW:={"ND6_PEDIDO","ND6_ITEMPV","ND5_DTDIR","ND6_LOTE","ND6_SUBLOT","ND6_QT","ND5_CODSAF","ND5_CTVAR","ND5_CULTRA","ND5_CATEG","ND5_PENE"}  
	
	oDlg := FWDialogModal():New()
	oDlg:SetBackground(.F.)
	oDlg:SetTitle('Lotes direcionados e suas quantidades')
	//oDlg:SetEscClose(.f.)
	oDlg:setSize(260,600)
	oDlg:EnableFormBar(.T.)
	oDlg:SetEscClose(.T.)
	///oDlg:EnableAllClient()
	//oDlg:EnableFormBar(.F.) 
	oDlg:CreateDialog() 
	oDlg:AddButton( "Sair",{||oDlg:Deactivate(),}, "Sair", , .T., .F., .T., )//"Sair"
	oDlg:createFormBar()//cria barra de botoes

    oLayer := FWLayer():new()
	oPanel := oDlg:getPanelMain()
    oLayer:Init(oPanel,.F.)
    oLayer:addLine('LinhaSuperior',100,.F.,)
    
    oLayer:addColumn('ColSuperior',100,.F.,'LinhaSuperior')
    
    oLayer:addWindow('ColSuperior','C1_Win01',"Lotes Direcionados do PV : " + cPedido + '-' + cItemPV  ,100,.F.,.F.,,'LinhaSuperior',)
    
    oPanel   := oLayer:getwinpanel('ColSuperior','C1_Win01','LinhaSuperior')
    

     //adicionando os cpos que devem aparecer no browse
     For nx := 1 To Len(acPosBRW)

		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+acPosBRW[ nX ]+"}"))
		aColumns[Len(aColumns)]:SetTitle(AllTrim(RetTitle(acPosBRW[nX])))
		aColumns[Len(aColumns)]:SetSize(TamSx3(acPosBRW[nX])[1])
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(acPosBRW[nX])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(acPosBRW[nX]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(acPosBRW[nX])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento
	Next nx
		
	(cAliasTMP)->( dbGoTop() )
	
	
	//-------------------------------------------------------------------
	// Estrutura do aFields
	//				[n][1] Campo
	//				[n][2] Título
	//				[n][3] Tipo
	//				[n][4] Tamanho
	//				[n][5] Decimal
	//				[n][6] Picture
	//-------------------------------------------------------------------
	
	aFldfilter:= {}
	
	For nX:= 1 to len(aCposBRW)
	   aAdd(aFldfilter, {ALLTRIM(aCposBRW[1]), Alltrim(RetTitle(acPosBRW[nX])),TamSX3(aCposBRW[Nx])[3], TamSX3(aCposBRW[Nx])[2],TamSX3(aCposBRW[Nx])[2],X3PICTURE(acPosBRW[nX] )})
	nExt nX
			


	DEFINE FWFORMBROWSE oBrowsX DATA TABLE ALIAS cAliasTMP OF oPanel
	oBrowsX:SetTemporary(.T.)
	oBrowsX:SetColumns(aColumns)
	oBrowsX:SetDBFFilter(.T.)
	oBrowsX:SetUseFilter(.T.)
	oBrowsX:SetFieldFilter( aFldfilter )
	oBrowsX:SetProfileID( 'UBSA020C'	) 
	oBrowsX:DisableDetails(.F.)
	oBrowsX:DisableSeek(.t.)
	//oBrowsX:DisableConfig()
	ACTIVATE FWFORMBROWSE oBrowsX
    odlg:activate()
	
	oTempTable:Delete()
	( cAliasQRY )->( DbCloseArea() )
	
Return .T.
