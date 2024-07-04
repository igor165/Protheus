#Include 'TOTVS.CH'
#Include 'FWMVCDEF.CH'
#Include 'TOPCONN.CH'
/*{Protheus.doc} UBSA020H
Rotina Responsalve por listar pedidos aptos a direcionar
@param     nil.
@return    nil
@author    AgroIndustria
@since      Agosto/2020
@version    P11
*/
Function UBSA020H( oMDUBA020 )

	Private _oBrw		:= nil
	Private _cAliasTMP	:= GetNextAlias()
	private _oTmpTable	:= nil	 
	Private oMdlUBA020  := oMDUBA020

	GenBrw(  )


RETURN (.T.)

/*{Protheus.doc} GenBrw
Criando o Browser
@param     Panel -> Onde o Browse deve Ancorar
@sample    GenBrwUP( oPnC01_L01 )
@return    // Objeto FwBrowse foi Criado
@author    AgroIndustria
@since      Agosto/2020
@version    P12
*/
Static Function GenBrw( oPanel )
	Local 	aCposBrowse	:= {}
	Local   aCposTMP	:= {}
	Local   aColumns	:= {}
	Local   nX         	:= 0
	Local   aCposFiltr	:= {}//Campos Para gerar filtros na consulta....
	Local   lTemPVs     := .f.	
	
	// Prepara o TMP que sera utilizado no browser
	FWMsgRun(/*oComponent*/,{|| lTemPvs := FMontaTMP() },'Aguarde','Selecionando os dados') // "Aguarde" "Montando a Estrutura de Negócio..."
	IF ! lTemPVs = .t.
	   Return(.f.)
	EndIF

	//Define as colunas do Browse de Acordo com SX3 Para Buscar Tamanho,decimais Etc;
	aCposBrowse := {"C6_NUM","C6_ITEM","C6_PRODUTO","B1_DESC","C6_UM","C6_QTDVEN","C6_CULTRA","NP3_DESCRI","C6_CTVAR","NP4_DESCRI","C6_CATEG","C6_PENE","C5_CLIENTE", "C5_LOJACLI", "A1_NOME"}
	//Define as colunas do Browse de Acordo com a Qry para Identificar os Dados
	aCposTMP 	:= {"C6_NUM","C6_ITEM","C6_PRODUTO","B1_DESC","C6_UM","C6_QTDVEN","C6_CULTRA","NP3_DESCRI","C6_CTVAR","NP4_DESCRI","C6_CATEG","C6_PENE","C5_CLIENTE", "C5_LOJACLI", "A1_NOME"}

	For nX := 1 to Len(aCposTMP)
	  //Nome,Titulo,Tp. dado, tamanho,decimais,picture
	   aAdd(aCposFiltr,{aCposTMP[nX],FWX3Titulo(aCposTMP[nX]),TamSX3(aCposTMP[nX])[3],TamSX3(aCposTMP[nX])[1],TamSX3(aCposTMP[nX])[2],X3PICTURE(aCposTMP[nX]) } )

	   	IF ALLTRIM(aCposTMP[nX]) == 'NP3_DESCRI'
		  aCposFiltr[LEN(aCposFiltr), 2 ] := "Desc.Cultra"
	   	ElseIF ALLTRIM(aCposTMP[nX]) == 'NP4_DESCRI'
	   	  aCposFiltr[LEN(aCposFiltr), 2 ] := "Desc.Ctvar"
		EndIF
	nExt nX

	//Criando Dialog
	aSize := MsAdvSize()
	aCoors := FWGetDialogSize( oMainWnd )
	
	//tamanho da tela principal
	oSize := FWDefSize():New(.T.)
	oSize:AddObject('DLG',100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.
	oSize:aMargins := {0,0,0,0}
	oSize:Process()
	
	oDlgSubs := TDialog():New(  oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3]/1.25, oSize:aWindSize[4]/1.1, 'Pedidos de Venda aptos a serem utilizados na substituição', , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //Consulta
	
	// Desabilita o fechamento da tela através da tela ESC.
	oDlgSubs:lEscClose := .F.

	// Instancia o layer
	oFWL_F := FWLayer():New()
	// Inicia o Layer
	oFWL_F:init( oDlgSubs,.F.)
	// Cria uma linha unica para o Layer
	oFWL_F:addLine( 'LINHA1', 100 , .F.)
	//oFWL_F:addLine( 'INF', 90 , .F.)
	// Cria colunas
	oFWL_F:addCollumn('COL1',100,.T.,'LINHA1' )
	
	cTitleBrw := "PV(s) que estão aptos a substituir o PV : " 
	cTitleBrw += ND5->ND5_PEDIDO + '-' + ND5->ND5_ITEM
	cTitleBrw += " no direcionamento : " + ND5->ND5_CODIGO

	oFWL_F:addWindow( 'COL1', 'Wnd1', cTitleBrw	, 100 /*tamanho*/, .F., .T.,, 'LINHA1' )	//"Blocos"
   
    oPnlWnd_F:= oFWL_F:getWinPanel( 'COL1' 	, 'Wnd1', 'LINHA1' )

	//Definindo as colunas do Browse
	
	For nX:= 1 to Len ( aCposBrowse )
	
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aCposBrowse[ nX ]+"}"))
		aColumns[Len(aColumns)]:SetTitle( AllTrim(RetTitle( aCposBrowse[nX]) )) 
		aColumns[Len(aColumns)]:SetSize(TamSx3(aCposBrowse[nX])[1])
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(aCposBrowse[nX])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(aCposBrowse[nX]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(aCposBrowse[nX])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento

		IF ALLTRIM(aCposBrowse[nX]) == 'NP3_DESCRI'
			aColumns[Len(aColumns)]:SetTitle(AllTrim( "Desc.Cultra" ))  
	   	ElseIF ALLTRIM(aCposBrowse[nX]) == 'NP4_DESCRI'
			aColumns[Len(aColumns)]:SetTitle(AllTrim( "Desc.Ctvar" ))
		EndIF
	
	nExt nX
	
	//Montando o seek

	aseek := {}
	    //Para melhor entendimento aAdd( aSeek, { 'Pedido+itemPedido+Lote' , { {"AquiConsultaF3Setitver","C",'2',0,'filial',"@!"} ,{"","C",6,0,'codctr','@!'}  ,1  } )
	//aAdd( aSeek, {;
	//	Alltrim( RetTitle( "C6_NUM" )) + '+' + Alltrim( RetTitle( "C6_ITEM" )),;
	//	{;
	//		{"",TAMSX3('C6_NUM' )[3],TAMSX3('C6_NUM' )[1],TAMSX3('C6_NUM' )[2],"C6_NUM", X3PICTURE("C6_NUM")},;
	//		{"",TAMSX3('C6_ITEM')[3],TAMSX3('C6_ITEM')[1],TAMSX3('C6_ITEM')[2],"C6_ITEM",X3PICTURE("C6_ITEM")}},1})

    //Segue os indices que forma definidos no TMP.
	aAdd( aSeek, {	Alltrim( RetTitle( "C6_NUM" )),{	{"",TAMSX3('C6_NUM' )[3],TAMSX3('C6_NUM' )[1],TAMSX3('C6_NUM' )[2],"C6_NUM", X3PICTURE("C6_NUM")	}	},1})

	_oBrw:= fwmBrowse():New() //fwBrowse():New()
	///_oBrw:SetOwner(oDlg)
	_oBrw:SetAlias(_cAliasTMP)
	_oBrw:SetTemporary(.T.)
	_oBrw:SetColumns(aColumns)
	_oBrw:SetDBFFilter(.T.)
	_oBrw:SetUseFilter(.T.)
	_oBrw:SetFieldFilter( aCposFiltr )
	_oBrw:SetOwner( oPnlWnd_F )
	_oBrw:SetProfileID( 'UBSA020H')
	_oBrw:DisableDetails(.F.)
	_oBrw:DisableSeek(.t.)
	_oBrw:SetSeek(,aSeek)
	//_oBrw:DisableConfig()
	_oBrw:AddButton("Substituir",{|| fUpdModel( oMdlUBA020 ),oDlgSubs:End() },,4,,.F.)
	_oBrw:Activate()
    oDlgSubs:Activate( , , , .t., { || .t. }, , { || } )

	_oTmpTable:Delete()
	FreeObj(_oTmpTable)
	
Return (.t.)

/** {Protheus.doc} MenuDef
Funï¿½ï¿½o que retorna os itens para construï¿½ï¿½o do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Emerson Coelho
@since: 	01/07/2016
@version    P11
*/
Static Function MenuDef()
	Local aRotina 	:= {}
Return( aRotina )



/** {Protheus.doc} fUpdModel
Substitui o Lote do direcionamento

@param: 	Nil
@return:	nil
@author: 	Emerson Coelho
@since: 	13/07/2016
@Uso: 		SIGAAGR
*/

static function fUpdModel( oMdlUBA020 )

Local oView
Local OMDL_ND6
Local OMDL_ND5

Local nX			:= 0
Local aSaveLines	:={}

	IF  oMdlUBA020 != nil
	    
		OMDL_ND5	:=  oMdlUBA020:GetModel( "OMDL_ND5" ) 
		OMDL_ND6	:=  oMdlUBA020:GetModel( "OMDL_ND6" )

		OMDL_ND5:SetValue( "ND5_PEDIDO", 	(_oBrw:Alias())->C6_NUM	    )
		OMDL_ND5:SetValue( "ND5_ITEM", 		(_oBrw:Alias())->C6_ITEM    )
		OMDL_ND5:SetValue( "ND5_PRODUT", 	(_oBrw:Alias())->C6_PRODUTO )
		OMDL_ND5:SetValue( "ND5_UM", 		(_oBrw:Alias())->C6_UM      )
		OMDL_ND5:SetValue( "ND5_QT", 		(_oBrw:Alias())->C6_QTDVEN	)
		OMDL_ND5:SetValue( "ND5_CULTRA", 	(_oBrw:Alias())->C6_CULTRA  )
		OMDL_ND5:SetValue( "ND5_PENE", 		(_oBrw:Alias())->C6_PENE    )
		OMDL_ND5:SetValue( "ND5_CTVAR", 	(_oBrw:Alias())->C6_CTVAR   )
		OMDL_ND5:SetValue( "ND5_CODSAF",	(_oBrw:Alias())->C5_CODSAF  )
		OMDL_ND5:SetValue( "ND5_CATEG", 	(_oBrw:Alias())->C6_CATEG   )
		OMDL_ND5:SetValue( "ND5_CLI",		(_oBrw:Alias())->C5_CLIENTE )
		OMDL_ND5:SetValue( "ND5_LOJA", 		(_oBrw:Alias())->C5_LOJACLI )


		aSaveLines	:= FWSaveRows()

		For nX := 1 to OMDL_ND6:Length() // Verificando se ja existe o lote no array
			OMDL_ND6:GoLine( nX )

			OMDL_ND6:SetValue( 'ND6_PEDIDO', (_oBrw:Alias())->C6_NUM )
			OMDL_ND6:SetValue( "ND6_ITEMPV", (_oBrw:Alias())->C6_ITEM )
		nExt nX
		FWRestRows( aSaveLines )

		OMDL_ND6:GoLine( 1 )
		oViewUBSA020		:= FwViewActive()
		
		IF ! oViewUBSA020= nIl 
		   oViewUBSA020:Refresh('VIEW_ND6')
		EndIF

	EndIF
Return( .t. )

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
Local cquery
Local cFiltro		:= ''
Local cAliasQRY		:= GetNextAlias()
Local aTmpStruct	:={}
Local nX 			:= 0

Local cCodSaf		:= ''
Local cCultura		:= ''
Local cCtvar		:= ''
Local cCategoria	:= ''
Local cPeneira		:= ''
Local CPV			:= ''
Local cUm			:= ''
Local cProdutoPV	:= ''
Local cCodCli		:= ''
Local CLjaCli		:= ''
Local cMsg			:= ''
Local nRegTotal		:= 0

///IF  oMdlUBA020 != NIL

    /*
	OMDL_ND5 := oMdlUBA020:GetModel( "OMDL_ND5" )

	cCodSaf		:=	OMDL_ND5:GetValue( "ND5_CODSAF" )
	cCultura	:= 	OMDL_ND5:GetValue( "ND5_CULTRA" )
	cCtvar 		:= 	OMDL_ND5:GetValue( "ND5_CTVAR"  )
	cCategoria	:=  OMDL_ND5:GetValue( "ND5_CATEG"  )
	cPeneira	:=  OMDL_ND5:GetValue( "ND5_PENE"   ) 
	CPV			:=  OMDL_ND5:GetValue( "ND5_PEDIDO" ) 
	CItemPV		:=	OMDL_ND5:GetValue( "ND5_ITEM  " ) 
	cUm         :=  OMDL_ND5:GetValue( "ND5_UM    " ) 
	cProdutoPV  :=  OMDL_ND5:GetValue( "ND5_PRODUT" ) 
	cCodCli		:= OMDL_ND5:GetValue( "ND5_CLI"  ) 
	C5_LjaCli   := OMDL_ND5:GetValue( "ND5_LOJA" ) 
	*/

	cCodSaf		:=	ND5->ND5_CODSAF
	cCultura	:= 	ND5->ND5_CULTRA
	cCtvar 		:= 	ND5->ND5_CTVAR
	cCategoria	:=  ND5->ND5_CATEG
	cPeneira	:=  ND5->ND5_PENE
	CPV			:=  ND5->ND5_PEDIDO
	CItemPV		:=	ND5->ND5_ITEM
	cUm         :=  ND5->ND5_UM
	cProdutoPV  :=  ND5->ND5_PRODUT
	cCodCli		:=  ND5->ND5_CLI
	C5_LjaCli   :=  ND5->ND5_LOJA

	
	If !Empty(cCodSaf)
    	cFiltro += " AND C5_CODSAF = '" 	+ cCodSaf 		+ "' "
	EndIF
	
	If !Empty(cCultura)
    	cFiltro += " AND C6_CULTRA = '" 	+ cCultura 		+ "' "
	EndIF

	If !Empty(cCtvar)
    	cFiltro += " AND C6_CTVAR = '" 	+ cCtvar 		+ "' "
	EndIF

	If !Empty(cCategoria)
    	cFiltro += " AND C6_CATEG = '" 	+ cCategoria 		+ "' "
	EndIF

	If !Empty(cPeneira)
    	cFiltro += " AND C6_PENE = '" 	+ cPeneira 		+ "' "
	EndIF

	If !Empty(cUm)
    	cFiltro += " AND C6_UM = '" 	+ cUm 		+ "' "
	EndIF

	If !Empty(cProdutoPV)
    	cFiltro += " AND C6_PRODUTO = '" 	+ cProdutoPV 		+ "' "
	EndIF

	If !Empty(cCodCli)
    	cFiltro += " AND C5_CLIENTE = '" 	+ cCodCli 		+ "' "
	EndIF

	If !Empty(C5_LjaCli)
    	cFiltro += " AND C5_LOJACLI = '" 	+ C5_LjaCli 		+ "' "
	EndIF

	If !Empty( CPV )
    	cFiltro += " AND (C6_NUM != '" + CPV + "' OR C6_ITEM != '" + CItemPV + "') "
	EndIF
	
	/*
	If Empty(cFiltro)
		cFiltro := "%%"
	Else
		cFiltro := "% " + cFiltro + " %"
	Endif
	*/


	cQuery := " SELECT C6_NUM , C6_ITEM, SC6.R_E_C_N_O_ AS C6_RECNO, C6_PRODUTO, C6_UM, C6_QTDVEN, C5_CODSAF, C6_CULTRA,NP3_DESCRI, C6_CTVAR, NP4_DESCRI, C6_CATEG, C6_PENE,B1_DESC, "
    cQuery += " 	SC5.C5_CLIENTE, SC5.C5_LOJACLI, SA1.A1_NOME, SC5.C5_LIBEROK, SC5.C5_NOTA, SC5.C5_BLQ "
	cQuery += " FROM " + RetSqlName( "SC6" ) + " SC6 "
	cQuery += " 	INNER JOIN " + RetSqlName( "SB1" )  + " SB1 "
	cQuery += " 		ON SB1.D_E_L_E_T_ = ' '"
    cQuery += " 		AND SB1.B1_FILIAL = '" + xFilial('SB1')  + "'"
	cQuery += " 		AND SB1.B1_COD = SC6.C6_PRODUTO "
    cQuery += " 	INNER JOIN " + RetSqlName( "SB5" )  + " SB5 "
    cQuery += " 		ON SB5.D_E_L_E_T_  = ' ' 
    cQuery += " 		AND SB5.B5_FILIAL = '" + xFilial('SB5')  + "'"
    cQuery += " 		AND C6_PRODUTO = SB5.B5_COD "
	cQuery += " 	INNER JOIN " + RetSqlName( "SC5" )  + " SC5 "
    cQuery += " 		ON SC5.D_E_L_E_T_ = ' ' "
    cQuery += " 		AND SC5.C5_FILIAL = SC6.C6_FILIAL "
    cQuery += " 		AND SC5.C5_NUM = SC6.C6_NUM "
    cQuery += " 		AND SC5.C5_CLIENTE = SC6.C6_CLI "
    cQuery += " 		AND SC5.C5_LOJACLI = SC6.C6_LOJA "
    cQuery += " 	INNER JOIN "  + RetSqlName( "SA1" )  + " SA1 "
    cQuery += " 		ON SA1.D_E_L_E_T_ = ' ' "
    cQuery += " 		AND SA1.A1_FILIAL =  '" + xFilial('SA1')  + "'"
    cQuery += " 		AND SA1.A1_COD = SC5.C5_CLIENTE "
    cQuery += " 		AND SA1.A1_LOJA = SC5.C5_LOJACLI "

    //Descrição Cultivar
	cQuery += " 	LEFT JOIN " + RetSqlName( "NP4" )  + " NP4 "
	cQuery += " 				ON  NP4.NP4_CODIGO = SC6.C6_CTVAR
	cQuery += " 				AND NP4.NP4_FILIal =  '" + xFilial('NP4')  + "'"
	cQuery += " 				AND NP4.D_E_L_E_T_ = ' ' "

	//Descrição Cultura
	cQuery += " 	LEFT JOIN " + RetSqlName( "NP3" )  + " NP3 "
	cQuery += " 				ON  NP3.NP3_CODIGO = SC6.C6_CULTRA
	cQuery += " 				AND NP3.NP3_FILIal =  '" + xFilial('NP3')  + "'"
	cQuery += " 				AND NP3.D_E_L_E_T_ = ' ' "


	cQuery += " WHERE SC6.C6_FILIAL = '" + xFilial('SC6') + "'"
	cQuery += " 	AND B5_SEMENTE = '1' "  		// Produto tem que ser semente
	cQuery += " 	AND C6_QTDENT < C6_QTDVEN "  	// Pedidos que ainda possui algo a faturar
	cQuery += " 	AND ( C5_LIBEROK != ' ' AND C5_NOTA = ' ' AND C5_BLQ = ' ' ) "  	// Somente pedidos liberados
	cQuery += " 	AND NOT EXISTS (SELECT ND5.ND5_PEDIDO FROM " + RetSqlName( "ND5" )  + " ND5 "
	cQuery += " 					WHERE ND5.ND5_PEDIDO = SC6.C6_NUM "
  	cQuery += " 					AND ND5.ND5_ITEM  = SC6.C6_ITEM   "
	cQuery += " 					AND ND5.ND5_STATUS = '1' "    //Somente considera os que estï¿½o ativos
  	cQuery += " 					AND ND5.D_E_L_E_T_ = ' ' "
  	cQuery += " 					AND ND5.ND5_FILIAL = '" + xFilial('ND5')  + "')"
	cQuery += " 					AND SC6.D_E_L_E_T_ = ' '" 
	cQuery += cFiltro
	cQuery += " ORDER BY C6_NUM, C6_ITEM ASC"
	cQuery := Changequery(cquery)

	///EECVIEW(cQuery,'XXX')


	//Abrindo a query
	If select(cAliasQry) <> 0
		(cAliasQry)->( dbCloseArea() )
	endif

	TCQUERY cQuery  ALIAS ( cAliasQry ) NEW


	( cAliasQry)->( dBGotop() )

	Count to nRegTotal

    IF nRegTotal == 0

		cMsg := ''
		cMsg += ' Não foram encontrados pedidos aptos a direcionar Com os dados abaixo : ' + CRLF + CRLF
		cMsg += ' Safra:	' + cCodSaf + CRLF
		cMsg += ' Cultura:	' + cCultura + " - " + Alltrim( POSICIONE("NP3",1,FwXfilial('NP3') + cCultura, 'NP3_DESCRI')  ) + CRLF
		cMsg += ' Cultivar:	' + cCtvar + " - " + Alltrim( POSICIONE("NP4",1,FwXfilial('NP4') + cCtvar, 'NP4_DESCRI')  ) + CRLF
		cMsg += ' Categoria:' + Alltrim(cCategoria) + CRLF
		cMsg += ' Peneira:	' + cPeneira + CRLF
		cMsg += ' Produto:	' + cProdutoPV  +  '-' + Alltrim( POSICIONE("SB1",1,FwXfilial('SB1') + cProdutoPV, 'B1_DESC')  ) + " - UM : " + cUM + CRLF
		cMsg += ' Cliente:	' + cCodCli + '/' + CLjaCli + '-' +  Alltrim( POSICIONE("SA1",1,FwXfilial('SA1') + cCodCli + CLjaCli, 'A1_NOME')  )  + CRLF

		FWAlertWarning ( cMSG,'Atenção')

		return(.f.)

	EndIF


	// Array com os campos para criacao do arquivo de trabalho.
	aCposTmp   := {	{"C6_NUM",		TamSX3("C6_NUM")[3],		TamSX3("C6_NUM")[1],		TamSX3("C6_NUM")[2]		},;
					{"C6_ITEM",		TamSX3("C6_ITEM")[3], 		TamSX3("C6_ITEM")[1],		TamSX3("C6_ITEM")[2] 	},;
					{"C6_PRODUTO",	TamSX3("C6_PRODUTO")[3], 	TamSX3("C6_PRODUTO")[1], 	TamSX3("C6_PRODUTO")[2]	},;
					{"C6_UM",		TamSX3("C6_UM")[3],			TamSX3("C6_UM")[1],			TamSX3("C6_UM")[2]		},;
					{"C6_QTDVEN",	TamSX3("C6_QTDVEN")[3], 	TamSX3("C6_QTDVEN")[1],		TamSX3("C6_QTDVEN")[2] 	},;
					{"C5_CODSAF", 	TamSX3("C5_CODSAF")[3], 	TamSX3("C5_CODSAF")[1], 	TamSX3("C5_CODSAF")[2] 	},;
					{"C6_CULTRA", 	TamSX3("C6_CULTRA")[3], 	TamSX3("C6_CULTRA")[1], 	TamSX3("C6_CULTRA")[2] 	},;
					{"NP3_DESCRI", 	TamSX3("NP3_DESCRI")[3], 	TamSX3("NP3_DESCRI")[1], 	TamSX3("NP3_DESCRI")[2] },;
					{"C6_CTVAR",	TamSX3("C6_CTVAR")[3],		TamSX3("C6_CTVAR")[1], 		TamSX3("C6_CTVAR")[2] 	},;
					{"NP4_DESCRI",	TamSX3("NP4_DESCRI")[3],	TamSX3("NP4_DESCRI")[1], 	TamSX3("NP4_DESCRI")[2] },;
					{"C6_CATEG", 	TamSX3("C6_CATEG")[3],		TamSX3("C6_CATEG")[1], 		TamSX3("C6_CATEG")[2] 	},;
					{"C6_PENE",		TamSX3("C6_PENE")[3], 		TamSX3("C6_PENE")[1], 		TamSX3("C6_PENE")[2] 	},;
					{"B1_DESC", 	TamSX3("B1_DESC")[3], 		TamSX3("B1_DESC")[1], 		TamSX3("B1_DESC")[2] 	},;
					{"C5_CLIENTE", 	TamSX3("C5_CLIENTE")[3], 	TamSX3("C5_CLIENTE")[1], 	TamSX3("C5_CLIENTE")[2] },;
					{"C5_LOJACLI",	TamSX3("C5_LOJACLI")[3],	TamSX3("C5_LOJACLI")[1], 	TamSX3("C5_LOJACLI")[2] },;
					{"A1_NOME", 	TamSX3("A1_NOME")[3],		TamSX3("A1_NOME")[1], 		TamSX3("A1_NOME")[2] 	},;
					{"C5_LIBEROK",	TamSX3("C5_LIBEROK")[3], 	TamSX3("C5_LIBEROK")[1], 	TamSX3("C5_LIBEROK")[2] },;
					{"C5_NOTA",		TamSX3("C5_NOTA")[3], 		TamSX3("C5_NOTA")[1], 		TamSX3("C5_NOTA")[2] 	},;
					{"C5_BLQ",		TamSX3("C5_BLQ")[3], 		TamSX3("C5_BLQ")[1], 		TamSX3("C5_BLQ")[2] 	}}
	aIndex := {}

	IF ! _oTmpTable = nil 
		_oTmpTable:Delete()
	EndIf

	aadd(aIndex,{'C6_NUM'})
	aadd(aIndex,{'C5_CLIENTE','C5_LOJACLI'})
	aadd(aIndex,{'C6_NUM','C6_ITEM'})

	
	_oTmpTable:= FWTemporaryTable():New( _cAliasTMP )	// Cria o objeto da tabela tempor?ia
	_oTmpTable:SetFields(aCposTmp)						// Informa a estrutura da tabela tempor?ia 
	For nx := 1 to Len (aIndex)
	   _oTmpTable:AddIndex( cValtochar(nX),aIndex[nX] )	// Atribui o ?dice ?tabela tempor?ia
	nExt nX
	_oTmpTable:Create()										// Cria a tabela tempor?ia
				
	( cAliasQRY )->( dbGoTop() )

	aTmpStruct := (_cAliasTMP )->( DbStruct() )   //Pego Strutura do arquivo temporario
	
	While (cAliasQRY)->( !Eof() )
		
		DbSelectArea(_cAliasTMP)
		IF  RecLock(_cAliasTMP, .t.)
			DbSelectArea(cAliasQRY)
			For nx := 1 To Fcount()
				nPos := aScan(aCposTMP,{|x| AllTrim(x[1]) == Fieldname(nx)})
				If nPos > 0
					x := (cAliasQRY )+"->"+Fieldname(nx)
					y := (_cAliasTMP)+"->"+Fieldname(nx)
					&y. := &x.
				EndIf
			Next nx
			(_cAliasTMP)->( Msunlock() )
		EndIF
		(cAliasQRY)->(dbSkip())		
	EndDo

	(cAliasQry)->( DBCloseArea() )

Return (  .T. )

