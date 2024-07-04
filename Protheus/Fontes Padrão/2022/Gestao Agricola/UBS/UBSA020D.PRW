#Include 'totvs.ch'


/*{Protheus.doc} UBSA020C
Função que Mostra os lotes direcionados por PV e item do PV , que ainda nã se encontram em Sel. Lote
@param     nil
@sample    UBSA020D
@return    Nil
@author    AgroIndustria
@since      Agosto/2020
@version    P12
*/

Function UBSA020D()
	
	Local aColumns		:= {}
	Local aFldfilter	:= {}
	Local nX            := 0

	Private cAliasTMP		:= GetNextAlias()
	Private oTempTable		:= nIl
	//Private oBrowsX			

	If !PERGUNTE('UBSA020D',.t.)
		Return .F.
	EndIf

	FWMsgRun(/*oComponent*/,{|| FMontaTMP() },'Aguarde','Selecionando os dados') // "Aguarde" "Montando a Estrutura de Negócio..."
	

	//Campos a aparecer no browse.
	acPosBRW:={/*"STATUS",*/"ND6_PEDIDO","ND6_ITEMPV","C5_CLIENTE","C5_LOJACLI", "A1_NOME","ND5_DTDIR","ND6_LOTE","ND6_SUBLOT","ND6_QT","ND5_UM","ND5_CODSAF","ND5_CTVAR","NP4_DESCRI", "ND5_CULTRA","NP3_DESCRI","ND5_CATEG","ND5_PENE"}  
	
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
	oDlg:AddButton( "Sair",{||oDlg:Deactivate()}, "Sair", , .T., .F., .T., )//"Sair"
	oDlg:createFormBar()//cria barra de botoes

    oLayer := FWLayer():new()
	oPanel := oDlg:getPanelMain()
    oLayer:Init(oPanel,.F.)
    oLayer:addLine('LinhaSuperior',100,.F.,)
    
    oLayer:addColumn('ColSuperior',100,.F.,'LinhaSuperior')
    
    oLayer:addWindow('ColSuperior','C1_Win01',"Lotes Direcionados para os PVs" ,100,.F.,.F.,,'LinhaSuperior',)
    
    oPanel   := oLayer:getwinpanel('ColSuperior','C1_Win01','LinhaSuperior')
    
     //adicionando os cpos que devem aparecer no browse
     For nx := 1 To Len(acPosBRW)
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+acPosBRW[ nX ]+"}"))
        IF acPosBRW[ nX ] == 'STATUS'
			aColumns[Len(aColumns)]:SetTitle("STATUS")
			aColumns[Len(aColumns)]:SetSize(1)
			aColumns[Len(aColumns)]:SetDecimal(0)
			aColumns[Len(aColumns)]:SetPicture('@!')
		Else
			aColumns[Len(aColumns)]:SetTitle(AllTrim(RetTitle(acPosBRW[nX])))
			aColumns[Len(aColumns)]:SetSize(TamSx3(acPosBRW[nX])[1])
			aColumns[Len(aColumns)]:SetDecimal(TamSx3(acPosBRW[nX])[2])
			aColumns[Len(aColumns)]:SetPicture(X3PICTURE(acPosBRW[nX]))
			aColumns[Len(aColumns)]:SetAlign( If(TamSx3(acPosBRW[nX])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento

		EndIF



		//Ajusta titulo da descrição da Cultura e da Cultivar

		IF ALLTRIM(aCposBRW[nX]) == 'NP3_DESCRI'
			aColumns[Len(aColumns)]:SetTitle(AllTrim( "Desc.Cultra" ))  
	   	ElseIF ALLTRIM(aCposBRW[nX]) == 'NP4_DESCRI'
			aColumns[Len(aColumns)]:SetTitle(AllTrim( "Desc.Ctvar" ))
		EndIF


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
	    IF ALLTRIM(aCposBRW[nX]) == 'STATUS'
		  aAdd(aFldfilter, {ALLTRIM(aCposBRW[1]), 'STATUS','C', 1,0,'@!'})
	   	Else
			aAdd(aFldfilter, {ALLTRIM(aCposBRW[1]), Alltrim(RetTitle(acPosBRW[nX])),TamSX3(aCposBRW[Nx])[3], TamSX3(aCposBRW[Nx])[2],TamSX3(aCposBRW[Nx])[2],X3PICTURE(acPosBRW[nX] )})
		   	IF ALLTRIM(aCposBRW[nX]) == 'NP3_DESCRI'
			  aFldfilter[LEN(aFldfilter), 2 ] := "Desc.Cultra"
	   		ElseIF ALLTRIM(aCposBRW[nX]) == 'NP4_DESCRI'
	   		  aFldfilter[LEN(aFldfilter), 2 ] := "Desc.Ctvar"
			EndIF
		EndIF
	   
	nExt nX
			

	///DEFINE FWFORMBROWSE oBrowsX DATA TABLE ALIAS cAliasTMP OF oPanel

	oBrowsX:= FWFORMBROWSE():New() 
	oBrowsX:SetDataTable()
	oBrowsX:SetAlias(cAliasTMP)
	oBrowsX:SetOwner(oPanel)

	oBrowsX:AddLegend( "STATUS=='1'"  , "BR_VERMELHO", "Direcionamento C/Ped. Encerrado"   ) //"Direcionamento C/Ped. Encerrado"
	oBrowsX:AddLegend( "STATUS=='2'"  , "BR_VERDE"   , "Direcionamento C/Ped.Em Aberto "   ) //"Direcionamento C/Ped.Em Aberto "

    //oBrowsX:AddStatusColumns({||ATStatus(oBrowsX)},{||ATLegend()})	//Define os status
	oBrowsX:SetTemporary(.T.)
	oBrowsX:SetColumns(aColumns)
	oBrowsX:SetDBFFilter(.T.)
	oBrowsX:SetUseFilter(.T.)
	oBrowsX:SetFieldFilter( aFldfilter )
	oBrowsX:SetProfileID( 'UBSA020D' )
	oBrowsX:DisableDetails(.F.)
	oBrowsX:DisableSeek(.t.)
	///oBrowsX:DisableConfig()
	oBrowsX:AddButton("Filtrar Dados",{|| UBSA020DPG() },,3,,.F.)
	oBrowsX:Activate()
    odlg:activate()
	oTempTable:Delete()
		
Return .T.


/*
FMontaTMP()
Função  responsavel por montar a query e o TMP do Browser
@param:  nil
@description: Função  responsavel por montar a query e o TMP do Browser
@author: AgroIndustria
@since: 16/07/2020
@return: empty
*/
Static Function FMontaTMP()
    Local cAliasQRY		:= GetNextAlias()
	Local aCposTmp		:= {}
	Local aIndex		:= {}
	Local nPos			:= 0
	Local nX            := 0
	Local cFiltro		:=''

	MakeSqlExpr('UBSA020D')  // Ajusta os parametros range para formato sql

	IF !Empty(MV_PAR01)   //Safra
   		cFiltro += " AND " + MV_PAR01
	EndIF

	IF !Empty(MV_PAR02)   //Pedido
   		cFiltro += " AND " + MV_PAR02
	EndIF
	
	IF !Empty(MV_PAR03)   //Cultivar
   		cFiltro += " AND " + MV_PAR03
	EndIF

	IF !Empty(MV_PAR04)   //Categoria
   		cFiltro += " AND " + MV_PAR04
	EndIF


	If Empty(cFiltro)
		cFiltro := "%%"
	Else
		cFiltro := "% " + cFiltro + " %"
	Endif

	BeginSQL Alias cAliasQRY
		COLUMN ND5_DTDIR AS DATE
		SELECT 
			 	CASE 
				WHEN ( (SC5.C5_NOTA <> ' ' OR C5_LIBEROK = 'E') AND C5_BLQ = ' ') THEN '1'
   				ELSE '2' //Direcionamento com pedido em aberto
			   END STATUS,
			   ND6.ND6_PEDIDO, ND6.ND6_ITEMPV, SC5.C5_CLIENTE,SC5.C5_LOJACLI, SA1.A1_NOME, ND5.ND5_DTDIR, ND6.ND6_LOTE, ND6.ND6_SUBLOT, ND6.ND6_QT,ND5_UM,ND5_CODSAF, ND5.ND5_CTVAR,NP4.NP4_DESCRI, 
		       ND5.ND5_CULTRA,NP3.NP3_DESCRI,ND5.ND5_CATEG, ND5.ND5_PENE 
			FROM %Table:ND6% ND6
			INNER JOIN  %Table:ND5% ND5
     			ON ND5.%notDel%
				AND ND5.ND5_FILIAL = %xFilial:ND5% 
     			AND ND5.ND5_CODIGO = ND6.ND6_CODIGO
                AND  ND5.ND5_STATUS = '1'
			INNER JOIN %Table:SC5% SC5    //Para identificar se pedido esta encerrado ou não
    			ON SC5.%notDel%
    			AND SC5.C5_FILIAL = %xFilial:SC5%
    			AND SC5.C5_NUM = ND6.ND6_PEDIDO  
////				AND ( SC5.C5_LIBEROK != ' ' AND C5_NOTA = ' ' AND C5_BLQ = ' ' )
   			INNER JOIN  %Table:SA1% SA1
     			ON SA1.%notDel%
				AND SA1.A1_FILIAL = %xFilial:SA1% 
     			AND SA1.A1_COD = SC5.C5_CLIENTE 
				AND SA1.A1_LOJA = SC5.C5_LOJACLI 
			LEFT JOIN %Table:NP4%  NP4
				ON  NP4.NP4_CODIGO = ND5.ND5_CTVAR
				AND NP4.NP4_FILIal = %xFilial:NP4% 
				AND NP4.%notDel%
			LEFT JOIN %Table:NP3%  NP3
				ON  NP3.NP3_CODIGO = ND5.ND5_CULTRA
				AND NP3.NP3_FILIal = %xFilial:NP3% 
				AND NP3.%notDel%

		WHERE 	ND6.%notDel%
		AND 	ND6.ND6_FILIAL = %xFilial:ND6% 
		%exp:cFiltro%  
		ORDER BY ND6.ND6_PEDIDO,ND6.ND6_ITEMPV,ND6_LOTE
	EndSQL

	///EECVIEW(getLastQuery()[2],'XXX')
	

	// Array com os campos para criacao do arquivo de trabalho.
	aCposTmp   := {	{"STATUS",	    'C', 						1,							0						},;
					{"ND6_PEDIDO",	TamSX3("ND6_PEDIDO")[3], 	TamSX3("ND6_PEDIDO")[1],	TamSX3("ND6_PEDIDO")[2]	},;
					{"ND6_ITEMPV",	TamSX3("ND6_ITEMPV")[3], 	TamSX3("ND6_ITEMPV")[1],	TamSX3("ND6_ITEMPV")[2] },;
					{"C5_CLIENTE", 	TamSX3("C5_CLIENTE")[3], 	TamSX3("C5_CLIENTE")[1], 	TamSX3("C5_CLIENTE")[2] },;
					{"C5_LOJACLI",	TamSX3("C5_LOJACLI")[3],	TamSX3("C5_LOJACLI")[1], 	TamSX3("C5_LOJACLI")[2] },;
					{"A1_NOME", 	TamSX3("A1_NOME")[3],		TamSX3("A1_NOME")[1], 		TamSX3("A1_NOME")[2] 	},;
					{"ND5_DTDIR",	TamSX3("ND5_DTDIR")[3], 	TamSX3("ND5_DTDIR")[1], 	TamSX3("ND5_DTDIR")[2]	},;
					{"ND6_LOTE",	TamSX3("ND6_LOTE")[3],		TamSX3("ND6_LOTE")[1],		TamSX3("ND6_LOTE")[2]	},;
					{"ND6_SUBLOT",	TamSX3("ND6_SUBLOT")[3], 	TamSX3("ND6_SUBLOT")[1],	TamSX3("ND6_SUBLOT")[2] },;
					{"ND6_QT",		TamSX3("ND6_QT")[3], 		TamSX3("ND6_QT")[1], 		TamSX3("ND6_QT")[2] 	},;
					{"ND5_UM",		TamSX3("ND5_UM")[3], 		TamSX3("ND5_UM")[1], 		TamSX3("ND5_UM")[2] 	},;
					{"ND5_CODSAF", 	TamSX3("ND5_CODSAF")[3], 	TamSX3("ND5_CODSAF")[1], 	TamSX3("ND5_CODSAF")[2] },;
					{"ND5_CTVAR", 	TamSX3("ND5_CTVAR")[3], 	TamSX3("ND5_CTVAR")[1], 	TamSX3("ND5_CTVAR")[2] 	},;
					{"NP4_DESCRI",	TamSX3("NP4_DESCRI")[3],	TamSX3("NP4_DESCRI")[1], 	TamSX3("NP4_DESCRI")[2] },;
					{"ND5_CULTRA",	TamSX3("ND5_CULTRA")[3],	TamSX3("ND5_CULTRA")[1], 	TamSX3("ND5_CULTRA")[2] },;
					{"NP3_DESCRI", 	TamSX3("NP3_DESCRI")[3], 	TamSX3("NP3_DESCRI")[1], 	TamSX3("NP3_DESCRI")[2] },;
					{"ND5_CATEG", 	TamSX3("ND5_CATEG")[3],		TamSX3("ND5_CATEG")[1], 	TamSX3("ND5_CATEG")[2] 	},;
					{"ND5_PENE",	TamSX3("ND5_PENE")[3], 		TamSX3("ND5_PENE")[1], 		TamSX3("ND5_PENE")[2] 	}}
				
	aIndex := {}
	
	aadd(aIndex,{'ND6_PEDIDO','ND6_ITEMPV','ND6_LOTE'})

	IF ! oTempTable = nil 
		oTempTable:Delete()
	EndIf
	
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

	( cAliasQRY )->( DbCloseArea() )

Return()

/*
@Funcao : UBSA020PG
@description: Chamada para mostrar os parametros de filtro iniciais do browse
@author: AgroIndustria
@since: 16/07/2020
@return: empty
*/

function UBSA020DPG(  )

	Pergunte('UBSA020D')


	FWMsgRun(/*oComponent*/,{|| FMontaTMP() },'Aguarde','Selecionando os dados') // "Aguarde" "Montando a Estrutura de Negócio..."

	oBrowsX:Data():DeActivate()
	oBrowsX:SetAlias(cAliasTMP)
	oBrowsX:Data():DeActivate()
	oBrowsX:Data():Activate()
	oBrowsX:UpdateBrowse(.T.)
	oBrowsX:Refresh()	
Return
