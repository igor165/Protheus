#Include 'TOTVS.CH'
#Include 'FWMVCDEF.CH'
#Include 'TOPCONN.CH'
/*{Protheus.doc} UBSA020B
Rotina Responsalve por listar pedidos aptos a direcionar
@param     nil.
@return    nil
@author    AgroIndustria
@since      Agosto/2020
@version    P11
*/
Function UBSA020B()

	Private _oBrw		:= nil
	Private _cAliasTMP	:= GetNextAlias()
	private _oTmpTable	:= nil

	//---------------------------------------------------
	// Carrega em um array os fardos vinculados a reserva
	//---------------------------------------------------
	////SetKey( VK_F12, { || UBSA020BPG() } ) 		// Setanto F12 Para efetuar o pergunte
	If !PERGUNTE('UBSA020B',.t.)
		Return .F.
	EndIf

     GenBrw( )

	_oBrw:Activate()

	_oTmpTable:Delete()
	FreeObj(_oTmpTable)
	 
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
	Local   aCposFiltr	:= {}	:= {}  //Campos Para gerar filtros na consulta....	
	
	// Prepara o TMP que sera utilizado no browser
	///FMontaTMP()

	FWMsgRun(/*oComponent*/,{|| FMontaTMP() },'Aguarde','Selecionando os dados') // "Aguarde" "Montando a Estrutura de Negócio..."


	//Define as colunas do Browse de Acordo com SX3 Para Buscar Tamanho,decimais Etc;
	aCposBrowse := {"C6_NUM","C6_ITEM","C6_PRODUTO","B1_DESC","C6_UM","C6_QTDVEN","C6_CULTRA","NP3_DESCRI","C6_CTVAR","NP4_DESCRI","C6_CATEG","C6_PENE","C5_CLIENTE", "C5_LOJACLI", "A1_NOME"}
	//Define as colunas do Browse de Acordo com a Qry para Identificar os Dados
	aCposTMP 	:= {"C6_NUM","C6_ITEM","C6_PRODUTO","B1_DESC","C6_UM","C6_QTDVEN","C6_CULTRA","NP3_DESCRI","C6_CTVAR","NP4_DESCRI","C6_CATEG","C6_PENE","C5_CLIENTE", "C5_LOJACLI", "A1_NOME"}

	for nX := 1 to Len(aCposTMP)
	  //Nome,Titulo,Tp. dado, tamanho,decimais,picture
	   aAdd(aCposFiltr,{aCposTMP[nX],FWX3Titulo(aCposTMP[nX]),TamSX3(aCposTMP[nX])[3],TamSX3(aCposTMP[nX])[1],TamSX3(aCposTMP[nX])[2],X3PICTURE(aCposTMP[nX]) } )

	   	IF ALLTRIM(aCposTMP[nX]) == 'NP3_DESCRI'
		  aCposFiltr[LEN(aCposFiltr), 2 ] := "Desc.Cultra"
	   	ElseIF ALLTRIM(aCposTMP[nX]) == 'NP4_DESCRI'
	   	  aCposFiltr[LEN(aCposFiltr), 2 ] := "Desc.Ctvar"
		EndIF
	nExt nX

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

/*
		AAdd(aSeeks, {; // Armazém + Endereço + Produto
		AllTrim(aColsBrw[1][1])+' + '+AllTrim(aColsBrw[2][1])+' + '+AllTrim(aColsBrw[5][1]),;
		{;
			{'NNR',aColsBrw[1][3],aColsBrw[1][4],aColsBrw[1][5],aColsBrw[1][1],Nil},;
			{'SBE',aColsBrw[2][3],aColsBrw[2][4],aColsBrw[2][5],aColsBrw[2][1],Nil},;
			{'SB1',aColsBrw[5][3],aColsBrw[5][4],aColsBrw[5][5],aColsBrw[5][1],Nil} ;
		}})
		
*/	

	_oBrw:= fwmBrowse():New() //fwBrowse():New()
	///_oBrw:SetOwner(oDlg)
	_oBrw:SetAlias(_cAliasTMP)
	_oBrw:SetTemporary(.T.)
	_oBrw:SetColumns(aColumns)
	_oBrw:SetDBFFilter(.T.)
	_oBrw:SetUseFilter(.T.)
	_oBrw:SetFieldFilter( aCposFiltr )
	_oBrw:SetProfileID( 'UBSA020B')
	_oBrw:DisableDetails(.F.)
	_oBrw:DisableSeek(.t.)
	_oBrw:SetSeek(,aSeek)
	//_oBrw:DisableConfig()
	_oBrw:AddButton("Direcionar Lotes",{|| UBSA020BLT() },,3,,.F.)
	_oBrw:AddButton("Filtrar Dados",{|| UBSA020BPG() },,3,,.F.)
	
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


/** {Protheus.doc} fdirLotes
Funï¿½ï¿½o de direcionamento de Lotes
relacionadas a fixaï¿½ï¿½o

@param: 	Nil
@return:	nil
@author: 	Emerson Coelho
@since: 	13/07/2016
@Uso: 		SIGAAGR
*/
//Static function fDirLotes()
function UBSA020BLT()
Local lConfirmou := .f.
Local cAliasQRY		:= GetNextAlias()
Local nRet 			:= 1

	Local nOperation 	:= MODEL_OPERATION_INSERT
	Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil}/*Salvar*/,{.T.,Nil/*"Cancelar"*/},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	
    IF Empty ( (_oBrw:Alias())->C6_NUM	    )
		Help(NIL, NIL, 'Ajuda', NIL, 'Direcionamento invalido.', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Selecione um pedido de vendas para efetuar o direcionamento.'})                  
		_oBrw:Refresh()
		Return()
	Else
		 //Verificando se O PV não possui lotes selecionados
		 //Se Possuir não deixa direcionar

		BeginSql Alias cAliasQRY
			SELECT SUM(NJ6.NJ6_QTDE) QTSELECIONADA FROM %Table:NJ6%  NJ6
			WHERE NJ6.D_E_L_E_T_ = ' '
			AND NJ6.NJ6_FILIAL = %xFilial:NJ6%
			AND NJ6.NJ6_NUMPV  = %exp:(_oBrw:Alias())->C6_NUM%
			AND NJ6.NJ6_ITEM   = %exp:(_oBrw:Alias())->C6_ITEM%
		EndSql

		IF (cAliasQRY)->QTSELECIONADA > 0

			( cAliasQRY )-> ( dBclosearea() )

			Help(NIL, NIL, 'Ajuda', NIL, 'Pedido  já possui lote(s) selecionado.', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Selecione um pedido de vendas que não tenha lote(s) Selecionado.'})                  
			_oBrw:Refresh()
			Return()
		Else
		  ( cAliasQRY )-> ( dBclosearea() )
		EndIF
		 
	EndIF

Begin Sequence
  nRet := FWExecView('Direcionamento de Lotes',"UBSA020",nOperation,,{ || lConfirmou := .T. },,,aButtons)
  IF nRet == 0
	//Se confirmou o direcionamento , Deleto o Pedido do browse
	RecLock( _oBrw:Alias(),.f.)
	(_oBrw:Alias() )->( dbDelete() ) 
	(_oBrw:Alias() )->( MsUnLock() )
  EndIF

End Sequence

IF nRet == 0

  	_oBrw:Data():DeActivate()
	_oBrw:UpdateBrowse(.T.)

	_oBrw:SetAlias(_cAliasTMP)
    _oBrw:Data():Activate()
	_oBrw:UpdateBrowse(.T.)
	_oBrw:Refresh()	
EndIf

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

MakeSqlExpr('UBSA020B')  // Ajusta os parametros range para formato sql

IF !Empty(MV_PAR01)   //Safra
   cFiltro += " AND " + MV_PAR01
EndIF


IF !Empty(MV_PAR02) // PV
   cFiltro += " AND " + MV_PAR02
EndIF

IF !Empty(MV_PAR03) //Cultivar
   cFiltro += " AND " + MV_PAR03
EndIF

IF !Empty(MV_PAR04) //Categoria
   cFiltro += " AND " + MV_PAR04
EndIF

IF !Empty(MV_PAR05)
   cFiltro += " AND " + MV_PAR05
EndIF

IF !Empty(MV_PAR06)
   cFiltro += " AND " + MV_PAR06
EndIF

IF !Empty(MV_PAR07)
   cFiltro += " AND C5_EMISSAO >= '" + DTOS( MV_PAR07 ) + "'"
EndIF

IF !Empty(MV_PAR08)
   cFiltro += " AND C5_EMISSAO <= '" + DTOS( MV_PAR08)  + "'"
EndIF

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

	/// EECVIEW(cQuery,'XXX')

	//Abrindo a query
	If select(cAliasQry) <> 0
		(cAliasQry)->( dbCloseArea() )
	endif

	TCQUERY cQuery  ALIAS ( cAliasQry ) NEW

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

Return (  )

/*
@Funcao : UBSA020PG
@description: Chamada para mostrar os parametros de filtro iniciais do browse
@author: AgroIndustria
@since: 16/07/2020
@return: empty
*/

function UBSA020BPG(  )

Pergunte('UBSA020B')

///FMontaTMP() //Refaz o Arq. temporario

FWMsgRun(/*oComponent*/,{|| FMontaTMP() },'Aguarde','Selecionando os dados') // "Aguarde" "Montando a Estrutura de Negócio..."

	_oBrw:Data():DeActivate()
	_oBrw:SetAlias(_cAliasTMP)
	_oBrw:Data():Activate()
	_oBrw:UpdateBrowse(.T.)
	_oBrw:Refresh()	
Return



