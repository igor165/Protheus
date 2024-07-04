#INCLUDE "AGRA035D.ch"
#INCLUDE "protheus.ch"
#INCLUDE "fwmvcdef.ch"

Static _cCod  := ""
Static _lRPO17 := GetRPOrelease() < "12.1.023"

/** {Protheus.doc} ARMA035D
Rotina para Cadastro de Tabelas de Descontos Agricolas

@param: 	Nil
@author: 	Fabiane Schulze
@since: 	05/11/2013 
@Uso: 		SIGAAGR - Originação de Grãos
**/
Function AGRA035D( cCodigo )
	Local aAreaAtu	
	Local oMBrowse	:= Nil
	
	_cCod := cCodigo 
	
	dbselectarea("NNI")
	aAreaAtu	:= GetArea()		
	
	dbSelectArea( "NNI" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "NNI" ) + _cCod)
		
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NNJ" )
	oMBrowse:SetMenuDef( "AGRA035D" )
	oMBrowse:SetDescription( STR0001 ) //"Itens das Tabelas de Descontos"
	oMBrowse:SetFilterDefault( "NNJ_FILIAL == '" + FWxFilial( "NNJ" ) + "'" + " .And. NNJ_CODTAB == '" + _cCod+ "'" )
	oMBrowse:Activate()

	if !_lRPO17
		OrdenNivel(_cCod)
	endIf

	RestArea( aAreaAtu )

Return( Nil )


/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		AGRA035D - Espécies
**/
Static Function MenuDef()
	Local aRetM		:= {}
	Local aRotina 	:= {}
	Local nx		:= 0

	aAdd( aRotina, { STR0002	, "PesqBrw"				, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003	, "ViewDef.AGRA035D"	, 0, 2, 0, .T. } ) //"Visualizar"
	aAdd( aRotina, { STR0004 	, "ViewDef.AGRA035D"	, 0, 3, 0, .T. } ) //"Incluir"
	aAdd( aRotina, { STR0005   	, "ViewDef.AGRA035D"	, 0, 4, 0, .T. } ) //"Alterar"
	aAdd( aRotina, { STR0006   	, "ViewDef.AGRA035D"	, 0, 5, 0, .T. } ) //"Excluir"
	aAdd( aRotina, { STR0007    , "AGRA035E"			, 0, 4, 0, .F. } ) //"Matriz"
	aAdd( aRotina, { STR0009  	, "ViewDef.AGRA035D"	, 0, 8, 0, .T. } ) //"Imprimir"
	aAdd( aRotina, { STR0010    , "ViewDef.AGRA035D"	, 0, 9, 0, .F. } ) //"Copiar"

	//PONTO DE ENTRADA PARA AÇÕES RELACIONADAS
    If ExistBlock('AG35DMNU')
        aRetM := ExecBlock('AG35DMNU',.F.,.F.)
        If Type("aRetM") == 'A'
            For nx := 1 To Len(aRetM)
            	Aadd(aRotina,aRetM[nx])
            Next nx 
        EndIf
    EndIf 
Return( aRotina )


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		AGRA035D - Espécies
*/
Static Function ModelDef()

	Local oStruNNJ 	:= FWFormStruct( 1, "NNJ" )
	Local oStruNNK 	:= FWFormStruct( 1, "NNK" )
	Local oStruDES 	:= FwFormStruct( 1, "NNJ" , { |x| ALLTRIM(x)  $ 'NNJ_DESREL,NNJ_DESCRI' })		
	Local oModel 	:= MPFormModel():New( "AGRA035D", /*< bPre >*/, {| oModel | TudoOk( oModel ) }, {| oModel | GrvModelo( oModel ) }, /*< bCancel >*/ )

	if !_lRPO17
		oStruNNJ:RemoveField( "NNJ_DESREL" )
		oStruNNJ:RemoveField( "NNJ_SEQUEN" )
		oStruNNJ:RemoveField( "NNJ_NIVEL" )
	endIf
	oStruNNK:RemoveField( "NNK_CODTAB" )
	oStruNNK:RemoveField( "NNK_CODDES" )

	oStruNNJ:SetProperty( "NNJ_CODTAB"   , MODEL_FIELD_INIT , {| x | x := _cCod}  )
	if NNJ->(ColumnPos('NNJ_GRUPO')) > 0
		oStruNNJ:SetProperty( "NNJ_GRUPO"    , MODEL_FIELD_VALID , {|| AGRA035GRP(oModel) })
	endIf
  					   
  	oStruDES:AddField( STR0037, STR0037, 'NNJ_DESCRI', 'C' , 25 , 0 , /*bValid*/, /*bWhen*/, /*aValues*/, /*lObrigat*/.F. , /*bInit*//*{ | oField | AGRA35TRIG( oField, "NNJ_DESCRI" ) }*/, .F./*lKey*/, /*lNoUpd*/, /*lVirtual*/) //"Descrição" ### "Descrição"
  	if NNJ->(ColumnPos('NNJ_DESREL')) > 0
  		oStruDES:AddTrigger( "NNJ_DESREL", "NNJ_DESCRI", { || .T. }, { | oField | AGRA35TRIG( oField, "NNJ_DESCRI" ) } )
	endIf

	oModel:SetDescription( STR0011 ) //"Itens da Tabela de Desconto"

	oModel:AddFields( "NNJUNICO", Nil, oStruNNJ )
	oModel:AddGrid( "NNKUNICO", "NNJUNICO",   oStruNNK, /*bLinePre*/, /*bLinePost*/{|oModelGrid| PreValLin(oModelGrid)} , /*bPre*/, /*bPost*/, /*bLoad*/ )
	if NNJ->(ColumnPos('NNJ_DESREL')) > 0
	oModel:AddGrid( "DESUNICO", "NNJUNICO",   oStruDES, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oGrid| IniModelo(oGrid)} )
	endIf 
	oModel:SetRelation( "NNKUNICO", { { "NNK_FILIAL", "FWxFilial( 'NNJ' )" }, { "NNK_CODTAB", "NNJ_CODTAB" }, { "NNK_CODDES", "NNJ_CODDES" } }, "NNK_SEQ" )
	oModel:SetPrimaryKey( {"NNJ_FILIAL", "NNJ_CODTAB" , "NNJ_CODDES"} )

	oModel:SetOptional( "NNKUNICO", .t. )
	oModel:GetModel( "NNKUNICO" ):SetDelAllLine( .t. )
	oModel:GetModel( "NNKUNICO" ):SetUniqueLine( { "NNK_SEQ" } )

	if NNJ->(ColumnPos('NNJ_DESREL')) > 0
		oModel:SetOptional( "DESUNICO", .t. )
		oModel:GetModel( "DESUNICO" ):SetDelAllLine( .t. )
		oModel:GetModel( "DESUNICO" ):SetUniqueLine( { "NNJ_DESREL" } )
		oModel:GetModel( "DESUNICO" ):SetOnlyQuery(.t.) //<<--Somente Consulta não Grava nada no Modelo, Os dados são gravado no OGA300 >>
		//devido aos debitos tecnico, é necessario adicionar o SetRelation conforme https://jiraproducao.totvs.com.br/browse/DAGROOGD-11879
		if  FWSIXUtil():ExistIndex( "NNJ" , "7" )
			oModel:SetRelation( "DESUNICO", { { "NNJ_FILIAL", "FWxFilial( 'NNJ' )" }, { "NNJ_DESREL", "NNJ_CODDES" } }, NNJ->( IndexKey( 7 )))
		endIf
	endIf
	
	oModel:GetModel( "NNJUNICO" ):SetDescription( STR0012 ) //"Dados do Item da Tabela"
	oModel:GetModel( "NNKUNICO" ):SetDescription( STR0013 ) //"Dados dos Sub-Itens da Tabela"
	if NNJ->(ColumnPos('NNJ_DESREL')) > 0
		oModel:GetModel( "DESUNICO" ):SetDescription( STR0038 ) //"Itens"
	endIf

	oModel:SetActivate()

Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		AGRA035D - Modelo de Contratos
*/
Static Function ViewDef()
	Local oStruNNJ	:= FWFormStruct( 2, "NNJ" )
	Local oStruNNK 	:= FWFormStruct( 2, "NNK" )
	Local oStruDES 	:= FwFormStruct( 2, "NNJ" , { |x| ALLTRIM(x)  $ 'NNJ_DESREL,NNJ_DESCRI' })
	Local oModel   	:= FWLoadModel( "AGRA035D" )
	Local oView    	:= FWFormView():New()
	
	if NNJ->(ColumnPos('NNJ_DESREL')) > 0
		oStruNNJ:RemoveField( "NNJ_DESREL" )
		oStruNNJ:RemoveField( "NNJ_SEQUEN" )
		oStruNNJ:RemoveField( "NNJ_NIVEL" )
	endIf
	oStruNNK:RemoveField( "NNK_CODTAB" )
	oStruNNK:RemoveField( "NNK_CODDES" )

	if NNJ->(ColumnPos('NNJ_DESCRI')) > 0
		oStruDES:AddField( "NNJ_DESCRI" ,'25' , STR0037, STR0037 , {} , 'C' ,'@!', NIL, NIL, .F., NIL, NIL, NIL, NIL, NIL, .T. ) //"Descrição" ### "Descrição"
	endIf
	oView:SetModel( oModel )
	oView:AddField( "VIEW_NNJ", oStruNNJ, "NNJUNICO" )
	oView:AddGrid( "VIEW_NNK", oStruNNK, "NNKUNICO" )
	if NNJ->(ColumnPos('NNJ_DESREL')) > 0
		oView:AddGrid( "VIEW_DES", oStruDES, "DESUNICO" )
    endIf
	oView:CreateVerticallBox( "TELANOVA" , 100 )
	oView:CreateHorizontalBox( "SUPERIOR" , 50, "TELANOVA" )
	oView:CreateHorizontalBox( "INFERIOR" , 50, "TELANOVA" )

	oView:CreateFolder( "GRADES", "INFERIOR")
	oView:AddSheet( "GRADES", "PASTA01", STR0014) //"Classificação"
	if NNJ->(ColumnPos('NNJ_DESREL')) > 0
		oView:AddSheet( "GRADES", "PASTA02", STR0039, {|| SelFolder()}) //"Itens do Grupo"
	endIf
	oView:CreateHorizontalBox( "PASTA_NNK", 100, , , "GRADES", "PASTA01" )
	if NNJ->(ColumnPos('NNJ_DESREL')) > 0
		oView:CreateHorizontalBox( "PASTA_DES", 100, , , "GRADES", "PASTA02" )
	endIf
	oView:SetOwnerView( "VIEW_NNJ", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_NNK", "PASTA_NNK" )
	if NNJ->(ColumnPos('NNJ_DESREL')) > 0
		oView:SetOwnerView( "VIEW_DES", "PASTA_DES" )
	endIf

	oView:EnableTitleView( "VIEW_NNJ" )
	oView:EnableTitleView( "VIEW_NNK" )
	if NNJ->(ColumnPos('NNJ_DESREL')) > 0
		oView:EnableTitleView( "VIEW_DES" )
	endIf

	oView:AddIncrementField('VIEW_NNK','NNK_SEQ')

	oView:AddUserButton( STR0034 ,''       , { |oView| AGRA035FAC(oView) } ) //"Facilitador" 

	oView:SetCloseOnOk( {||.t.} )
Return( oView )


/** {Protheus.doc} AGRA035G
Função para gatilho

@param: 	Nil
@author: 	Ana Laura Olegini
@since: 	02/09/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function AGRA035GAT()
	Local oModel	:= FwModelActive()
	Local oGrdNNK	:= oModel:GetModel("NNKUNICO")
	Local aAreaNNI  := NNI->(GetArea())
	Local aAreaNNJ  := NNJ->(GetArea())
	Local cTabAlt	:= oGrdNNK:GetValue( "NNK_TABALT")
	
	//variavel logica no campo NNK_PROALT (X3_WHEN) 
	lNNKPROALT := .T.
	
	//procura tabela informada no campo NNK_TABALT
	If AGRIFDBSEEK("NNI",cTabAlt,1,.F.)
		//se campo cod. produto estiver preenchido
		If !Empty(NNI->NNI_CODPRO)
			//gatilha o cod. do produto para o campo de produto alternativo
			oGrdNNK:SetValue( "NNK_PROALT", NNI->NNI_CODPRO )
			//trava o campo NNK_PROALT para edição
			lNNKPROALT 	:= .F.	
		Else //se campo cod. produto estiver vazio
			//gatilha campo produto alternativo para branco, deixando alterar para um produto valido
			oGrdNNK:SetValue( "NNK_PROALT", "" )
			//habilita o campo NNK_PROALT para edição
			lNNKPROALT 	:= .T.
		EndIf		
	Else
		oGrdNNK:SetValue( "NNK_PROALT", "" )
		//habilita o campo NNK_PROALT para edição
		lNNKPROALT 	:= .T.
	EndIf 
	
	RestArea(aAreaNNI)
	RestArea(aAreaNNJ)
Return .T.

/** {Protheus.doc} AGRA035G
Função para validação do campo produto alternativo

@param: 	Nil
@author: 	Ana Laura Olegini
@since: 	27/11/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function AGRA035PRAT()
	Local oModel	:= FwModelActive()
	Local oGrdNNK	:= oModel:GetModel("NNKUNICO")
	Local aAreaNNI  := NNI->(GetArea())
	Local aAreaNNJ  := NNJ->(GetArea())
	Local cTabAlt	:= oGrdNNK:GetValue( "NNK_TABALT")
	Local lRet		:= .T.	
	
	//procura tabela informada no campo NNK_TABALT
	If AGRIFDBSEEK("NNI",cTabAlt,1,.F.)
		//para o campo de cod. do produto vazio
		If Empty(NNI->NNI_CODPRO)
			//verifica na tabela de produto pelo grupo se o grupo é existente
			//se grupo não existir apresenta mensagem para informar o grupo
			If !AGRIFDBSEEK("SB1",NNI->NNI_PRODGR,4,.F.)
				AGRHELPNC(STR0020,STR0021,STR0015) //"Produto não faz parte do grupo informado."##"Favor informar um produto do grupo."##"AJUDA"
				lRet := .F.
			EndIf
		
			//verifica na tabela de produto se o produto informado possui grupo
			If AGRIFDBSEEK("SB1",M->NNK_PROALT,1,.F.)
				IF Empty(SB1->B1_GRUPO)
					Help(, , STR0015, STR0022, , 1, 0 ) //"Ajuda"###"Produto não possui grupo!  Favor informar um produto com grupo válido."
					Return .F.
				ElseIf SB1->B1_GRUPO <> NNI->NNI_PRODGR
					Help(, , STR0015, , STR0023, 1, 0 ) //"Ajuda"###"Grupo do produto é diferente do grupo da tabela!  Favor informar um produto com grupo válido."
					Return .F.
				EndIf
			EndIf
		EndIf 
	EndIf 
	
	RestArea(aAreaNNI)
	RestArea(aAreaNNJ)
Return lRet

/** {Protheus.doc} ARMA035E
Rotina para Cadastro de Tabelas de Descontos Agricolas

@param: 	Nil
@author: 	Equipe Agroindustria
@author: 	Fabiane Schulze
@since: 	05/11/2013
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function AGRA035E( )
	Local nX			:= 0
	Local nY			:= 0
	Local nZ			:= 0
	Local nOpcao		:= 0
	Local cNomeL		:= ""
	Local cNomeC		:= ""
	Local cTexto		:= ""
	Local cPictNNK1	:= ""
	Local cPictNNK2	:= ""
	Local oDlg			:= Nil
	Local oSize		:= Nil
	Local aButtons		:= {}

	Private oDbMtz		:= Nil
	Private aHMtz		:= {}
	Private aCMtz		:= {}
	Private aLinha		:= {}
	Private aColuna	:= {}
	
	//Itens da Tabela de Descontos - Tabela Padrao				 									
	dbSelectArea( "NNJ" )
	dbSetOrder( 1 )
	dbGoTop()					   
	If dbSeek( FWxFilial( "NNJ" ) + _cCod) //NNJ_FILIAL + NNJ_CODTAB + NNJ_CODDES

		While .Not. NNJ->( Eof() ) .And. NNJ->( NNJ_FILIAL ) == FWxFilial("NNJ") .And. NNJ->( NNJ_CODTAB ) == _cCod

			/** Se o Desconto da Tabela se referir a uma matriz busca referencias de linhas/colunas */
			If NNJ->( NNJ_MATRIZ ) $ "1|2"

				dbSelectArea( "NNK" )
				dbSetOrder( 1 )
				If dbSeek( FWxFilial( "NNK" ) + NNJ->( NNJ_CODTAB ) + NNJ->( NNJ_CODDES ) )

					cPictNNK1 := PesqPict( "NNK", "NNK_PERINI" )
					cPictNNK2 := PesqPict( "NNK", "NNK_PERFIM" )

					While .Not. NNK->( Eof() ) .And. NNK->( NNK_FILIAL ) == FWxFilial("NNK") .And. NNK->( NNK_CODTAB ) == NNJ->( NNJ_CODTAB ) .And. NNK->( NNK_CODDES ) == NNJ->( NNJ_CODDES )
					
						cTexto := "[" + AllTrim( Transform( NNK->( NNK_PERINI ), cPictNNK1 ) ) + "|-|" + AllTrim( Transform( NNK->( NNK_PERFIM ), cPictNNK2 ) ) + "]"

						If NNJ->( NNJ_MATRIZ ) == "1"
							cNomeL := NNJ->( NNJ_DESDES )
							aAdd( aLinha, { NNK->NNK_SEQ, cTexto, NNK->NNK_CODTAB, NNK->NNK_CODDES } )
						EndIf

						If NNJ->( NNJ_MATRIZ ) == "2"
							cNomeC := NNJ->( NNJ_DESDES )
							aAdd( aColuna, { NNK->NNK_SEQ, cTexto, NNK->NNK_CODTAB, NNK->NNK_CODDES } )
						EndIf

						NNK->( dbSkip() )
					EndDo
				EndIf

			EndIf

			NNJ->( dbSkip() )
		EndDo

	EndIf

	If Len( aLinha ) <= 0 .Or. Len( aColuna ) <= 0
		Help(, , STR0015, , STR0016, 1, 0 ) //"Ajuda"###"Nenhuma referencia a Linha e ou Coluna encontrados!"
	Return( Nil )
	EndIf

	/** Carrega aHeader conforme colunas */
	aAdd( aHMtz, { AllTrim( cNomeL ), "LINHA", "@!", 20, 0, "AllWaysTrue()", , "C" } )
	For nX := 1 to Len( aColuna )
		aAdd( aHMtz, { aColuna[ nX, 2 ], "COL" + cValtoChar( nX ), "@E 999", 3, 0, "AllWaysTrue()", , "N" } )
	Next nX

	/** Carrega aCols conforme linhas e dados da tabela de indices */
	For nX := 1 to Len( aLinha )

		aAdd( aCMtz, Array( Len( aHMtz ) + 1 ) )
		aCMtz[ nX, 1 ] := aLinha[ nX, 2 ]

		For nZ := 2 to Len( aHMtz )
		
			dbSelectArea( "NJZ" )
			dbSetOrder( 1 )
			If dbSeek( FWxFilial( "NJZ" ) + aLinha[ nX, 3 ] + aLinha[ nX, 4 ] + aLinha[ nX, 1 ] + aColuna[ ( nZ - 1), 4 ] + aColuna[ ( nZ - 1 ), 1 ] )
				aCMtz[ nX, nZ ] := NJZ->( NJZ_VALOR )
			Else
				aCMtz[ nX, nZ ] := 0
			EndIf

		Next nZ

		aCMtz[ nX, Len( aHMtz ) + 1 ] := .f.

	Next nX

	/** Cria e exibe o dialogo com a matriz para edição */
	oSize := FwDefSize():New()
	oSize:AddObject( "P1", 100, 100, .t., .t., .t. )
	oSize:lProp := .t.
	oSize:aMargins := { 3, 3, 3, 3 }
	oSize:Process()
	
	Aadd( aButtons, {STR0006, {|| Iif(DelMatriz(), oDlg:End(), nil)}, STR0006, STR0006 , {|| .T.}} ) 
	
	oDlg := TDialog():New( oSize:aWindSize[ 1 ], oSize:aWindSize[ 2 ], oSize:aWindSize[ 3 ], oSize:aWindSize[ 4 ], STR0017 + AllTrim( cNomeC ), , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Matriz do: "
	oDbMtz := MsNewGetDados():New( oSize:GetDimension( "P1", "LININI" ), oSize:GetDimension( "P1", "COLINI" ), oSize:GetDimension( "P1", "YSIZE" ), oSize:GetDimension( "P1", "XSIZE" ), GD_UPDATE, "AllwaysTrue", "AllwaysFalse", "LINHA", , 1, 999, , , , oDlg, aHMtz, aCMtz )
	oDlg:Activate( , , , .t., {|| .t. }, , { || EnchoiceBar( oDlg, {|| nOpcao := 1, oDlg:End() },{|| nOpcao := 0, oDlg:End() },, @aButtons ) } )

	/** Grava os dados informados na matriz pelo usuario se o mesmo confirmou a operacao */
	If nOpcao == 1

		dbSelectArea( "NJZ" )
		dbSetOrder( 1 )

		For nX := 1 to Len( oDbMtz:aCols )
 
			For nY := 2 to Len( aHMtz )

				If dbSeek( FWxFilial( "NJZ" ) + aLinha[ nX, 3 ] + aLinha[ nX, 4 ] + aLinha[ nX, 1 ] + aColuna[ ( nY - 1), 4 ] + aColuna[ ( nY - 1 ), 1 ] )

					If RecLock( "NJZ" )
						NJZ->( NJZ_VALOR ) := oDbMtz:aCols[ nX, nY ]
						NJZ->( msUnLock() )
					EndIf

				Else

					If RecLock( "NJZ", .t. )

						NJZ->NJZ_FILIAL := FWxFilial( "NJZ" )
						NJZ->NJZ_CODTAB := _cCod
						NJZ->NJZ_CODDEL := aLinha[ nX, 4 ]
						NJZ->NJZ_ITEML  := aLinha[ nX, 1 ]
						NJZ->NJZ_CODDEC := aColuna[ ( nY - 1 ), 4 ]
						NJZ->NJZ_ITEMC  := aColuna[ ( nY - 1 ), 1 ]
						NJZ->NJZ_VALOR  := oDbMtz:aCols[ nX, nY ]
						NJZ->( msUnLock() )

					EndIf

				EndIf

			Next nY

		Next nX

	EndIf

Return( Nil )


/*{Protheus.doc} AGRA035DES
Função para tratar quando o tipo for Faixa ou Percentual.
- validação dos campos NNK_PERINI e NNK_PERFIM

@author 	ana.olegini
@since 		22/06/2016
@version 	1.0
@return 	lContinua	- Retorna True ou False
*/
Function AGRA035DES()
	Local lContinua := .T.
	Local oModel	:= FwModelActive()
	Local oNNJ		:= oModel:GetModel("NNJUNICO")	
	Local oNNK		:= oModel:GetModel("NNKUNICO")

	//-- Se o Tipo do Resultado for Percentual [P]
	If oNNJ:GetValue("NNJ_TIPRES") == "P"
		//-- Se o Percentual Inicial OU Final for maior que 99.99 - retorna Falso
		If oNNK:GetValue("NNK_PERINI") > 99.99 .OR. oNNK:GetValue("NNK_PERFIM") > 99.99
			lContinua := .F.
			oModel:GetModel():SetErrorMessage( oNNJ:GetId(), , oNNJ:GetId(), "", "", STR0024, STR0025, "", "")	//"O tipo de resultado é percentual."#"Por Favor, informe um valor até 99,99"	
		EndIf 				
	//-- Se o Tipo do Resultado for Faixa [F]
	ElseIf oNNJ:GetValue("NNJ_TIPRES") == "F"
		//-- Se a Faixa Inicial OU Final for maior que 99999.99 - retorna Falso
		If oNNK:GetValue("NNK_PERINI") > 99999.99 .OR. oNNK:GetValue("NNK_PERFIM") > 99999.99
			lContinua := .F.
			oModel:GetModel():SetErrorMessage( oNNJ:GetId(), , oNNJ:GetId(), "", "", STR0026, STR0027, "", "")	//"O tipo de resultado é faixa."#"Por Favor, informe um valor até 99999,99"
		EndIf 				
	EndIf
Return(lContinua)


/*{Protheus.doc} PreValLin(oNNK, nLinha)
Rotina de Pre-Validação do Modelo da Grid NNK 
- realiza a validação na inserção de linha e ao confirmar

@author 	Ana L. Olegini
@since 		28/06/2016
@param 		oNNK 		- Modelo da Grid
@return 	lContinua	- Retorna True ou False
*/
Static Function PreValLin(oNNK)
	Local lContinua := .T.
	Local oModel	:= FwModelActive()
	Local oNNJ		:= oModel:GetModel("NNJUNICO")	
	Local nLinha	:= 0
	Local nX		:= 0
	Local nY        := 0
	Local nPerIni   := ""
	Local nPerFim   := ""
	Local aSaveRows	:= FWSaveRows()
	
	//-- Se o Tipo do Resultado for Percentual [P]
	If oNNJ:GetValue("NNJ_TIPRES") == "P"
		//-- Se o Percentual Final for maior que o Inicial 
		If oNNK:GetValue("NNK_PERINI") > oNNK:GetValue("NNK_PERFIM") 
			lContinua := .F.
			oModel:GetModel():SetErrorMessage( oNNJ:GetId(), , oNNJ:GetId(), "", "", STR0028, STR0029, "", "")	//"Percentual Final maior que o Percentual Inicial."#"Por Favor, informe um valor válido."	
		EndIf
				
		//-- Se o Percentual Inicial OU Final for maior que 99.99 - retorna Falso
		If oNNK:GetValue("NNK_PERINI") > 99.99 .OR. oNNK:GetValue("NNK_PERFIM") > 99.99
			lContinua := .F.
			oModel:GetModel():SetErrorMessage( oNNJ:GetId(), , oNNJ:GetId(), "", "", STR0024, STR0025, "", "")	//"O tipo de resultado é percentual."#"Por Favor, informe um valor até 99,99"	
		EndIf 

		//-- Se o Percentual Inicial OU Final for maior que 99.99 - retorna Falso
		If oNNK:GetValue("NNK_PERDES") > 100.00
			lContinua := .F.
			oModel:GetModel():SetErrorMessage( oNNJ:GetId(), , oNNJ:GetId(), "", "", STR0024, STR0032, "", "")	//"O tipo de resultado é percentual."#"Por Favor, informe um valor até 100,00"	
		EndIf 

	//-- Se o Tipo do Resultado for Faixa [F]
	ElseIf oNNJ:GetValue("NNJ_TIPRES") == "F"
		//-- Se a Faixa Final for maior que o Inicial 
		If oNNK:GetValue("NNK_PERINI") > oNNK:GetValue("NNK_PERFIM") 
			lContinua := .F.
			oModel:GetModel():SetErrorMessage( oNNJ:GetId(), , oNNJ:GetId(), "", "", STR0030, STR0029, "", "")	//"Faixa Final maior que a Faixa Inicial."#"Por Favor, informe um valor válido."	
		EndIf
					
		//-- Se a Faixa Inicial OU Final for maior que 99999.99 - retorna Falso
		If oNNK:GetValue("NNK_PERINI") > 99999.99 .OR. oNNK:GetValue("NNK_PERFIM") > 99999.99
			lContinua := .F.
			oModel:GetModel():SetErrorMessage( oNNJ:GetId(), , oNNJ:GetId(), "", "", STR0026, STR0027, "", "")	//"O tipo de resultado é faixa."#"Por Favor, informe um valor até 99999,99"
		EndIf
		
	EndIf
	
	//-- Salva linha posicionada
	nLinha := oNNK:GetLine()
	//-- Verifica se o valor final não é maior que um valor inicial
	For nX := 1 to oNNK:Length()
		//-- Posiciona na linha de nX
		oNNK:GoLine( nX )
		//-- Se a linha não for deletada E linha maior que 1 OU linha menor que a qtde da grid [Ex: 1 < 2]
		If .Not. oNNK:IsDeleted() .AND. nLinha > 1 .OR. nLinha < oNNK:Length()
			nPerIni := oNNK:GetValue("NNK_PERINI")
			nPerFim := oNNK:GetValue("NNK_PERFIM")
			
			For nY := 1 To oNNK:Length()
				oNNK:GoLine( nY )
				If .Not. oNNK:IsDeleted() .and. nX != nY
					If   (nPerIni >= oNNK:GetValue("NNK_PERINI") .and. nPerFim <= oNNK:GetValue("NNK_PERFIM")) ;   //valida interno
					.or.  (oNNK:GetValue("NNK_PERFIM")  >= nPerIni .and. oNNK:GetValue("NNK_PERFIM") <= nPerFim) ; //valida extremos
					.or.  (oNNK:GetValue("NNK_PERINI")  >= nPerIni .and. oNNK:GetValue("NNK_PERINI") <= nPerFim)   //valida extremos
						lContinua := .F.	
						oModel:GetModel():SetErrorMessage( oNNJ:GetId(), , oNNJ:GetId(), "", "", STR0031, STR0029, "", "")	//"Valor Inicial/Final divergente."#"Por Favor, informe um valor válido."					
						Exit
					EndIf
				EndIf
			Next nY 
			If !lContinua
				Exit
			EndIf
			oNNK:GoLine( nX )
		EndIf
	Next nX	
	oNNK:GoLine( nLinha )
	
	FWRestRows(aSaveRows)
Return (lContinua)

/** {Protheus.doc} AGRA35XX
Validação Código do Terceiro na reserva automática a partir do romaneio.
@param: 	Nil
@return:	lRet
@author: 	Equipe Agroindustria
@since: 	30/11/2017
@Uso: 		AGRA035 - Tabela de Classificação
*/

Function AGRA035XX()
	Local lRet 		:= .T.
	Local aOldarea 	:= GetArea()
	
	If ! Empty (M->NNK_TIPRES)
		dbSelectArea( "NJ2" )
		dbSetOrder( 1 )
		If MsSeek( xFilial( "NJ2" ) + M->NNK_TIPRES)
			If Empty(NJ2->NJ2_CODTER)
			 	AgrHelp(STR0015, STR0047, STR0052) //"#AJUDA# Para reservas automáticas o campo 'Cod.Ter.' localizado no Tipo de Reserva deve ser preenchido." "Altere o tipo da reserva."
			 	lRet := .F.
			EndIf
		EndIf
	EndIf
	RestArea(aOldarea)
Return lRet
	
/** {Protheus.doc} AGRA035FAC
Abre a tela de loading enquanto cria as faixas
@param: 	oView - view para pegar o NNKUNICO
@return:	lRet
@author: 	Equipe Agroindustria
@since: 	30/11/2017
@Uso: 		AGRA035 - Tabela de Classifição**/		
Function AGRA035FAC(oView)

	Local lRet   := .T.
	Local lPergt := .F.	

	lPergt := Pergunte("AGRA035001",.T.)

	If lPergt	
		Processa({|| AGRA035GFX(oView)  }, STR0035 ) //"Cadastrando"
	Else
	   lRet := .F.	   
	Endif

Return lRet


/** {Protheus.doc} AGRA035GFX
Abre o facilitador(Pergunte) para informar os valores da faixa.
@param: 	oView - view para pegar o NNKUNICO
@return:	lRet
@author: 	Equipe Agroindustria
@since: 	30/11/2017
@Uso: 		AGRA035 - Tabela de Classificao**/
Function AGRA035GFX(oView) 

Local lRet   	:= .T.
Local lExluiu   := .F.
Local lPrimeiro := .F.
Local nFaixaIni := 0
Local nFaixaFim := 0
Local nVaria    := 0
Local nSobresc  := 0
Local nPercent  := 0
Local nPercVar  := 0
Local nSomaIni  := 0
Local nSomaFim  := 0
Local Nx        := 0
Local nDivisao  := 1
Local nAdd      := ""
Local cSomaIni  := ""
Local oNNK2		:= oView:GetModel():GetModel("NNKUNICO")
		
	nFaixaIni := MV_PAR01
	nFaixaFim := MV_PAR02
	nVaria    := MV_PAR03
	nPercent  := MV_PAR04
	nPercVar  := MV_PAR05
	nSobresc  := MV_PAR06 

	nSomaIni  := nFaixaIni
	nSomaFim  := nFaixaIni + nVaria

	nDivisao  := nFaixaFim / nVaria
	
	//Divido mais uma vez para a regua ficar mais exata quando o valor ? menor que 0.05
	If nVaria < 0.05
		nDivisao := nDivisao / 1.5
	Endif

	ProcRegua(nDivisao)

	oNNK2:SetMaxLine(10000)

	oNNK2:GoLine(1)

	If oNNK2:GetValue("NNK_PERFIM") == 0
		lPrimeiro := .T.
	Endif

	//Sobrescreve ?
	If nSobresc = 1	
		oNNK2:SetNoDeleteLine(.F.)		 		 
		oNNK2:DelAllLine() //Deleta todas as linhas	
		lExluiu := .T.					
	Endif	

	//Se sobrescreveu o sequencial come?a do 001, se n?o pega o ?ltimo e soma + 1
	If lExluiu
		nAdd := 0		
	Else
		//Caso n?o possuir nenhum registro 
		If lPrimeiro
			nAdd := 0		
		Else
			nAdd := oNNK2:Length()								
		Endif
	Endif

	nAdd   := StrZero(nAdd,6)	
	cSomaIni := "0." + StrZero(1,TamSX3( "NNK_PERINI" )[ 2 ])

	For Nx := nFaixaIni to nFaixaFim Step nVaria									
		
		//Tratamento quando for substituir tudo e n?o tiver nenhum registro
		If !lPrimeiro
			oNNK2:AddLine()							
			
		Endif

		//Soma em character do SEQ 			
		nAdd := Soma1(nAdd)		

		IncProc(STR0036 + nAdd) //"Adicionando Registro:"
	
		oNNK2:LoadValue( "NNK_SEQ", nAdd )		
		oNNK2:LoadValue( "NNK_PERINI", nSomaIni )
		oNNK2:LoadValue( "NNK_PERFIM", nSomaFim )
		oNNK2:LoadValue( "NNK_PERDES", nPercent )

		//Se a soma final for maior que a faixa, insiro o valor da faixa no PERFIM.			
		If nSomaFim >= nFaixaFim 
			oNNK2:LoadValue( "NNK_PERFIM", nFaixaFim )
		Endif

		nSomaIni := VAL(cSomaIni) + nSomaFim
		nSomaFim := nSomaIni + nVaria 
		nPercent += nPercVar  				
		
		If nSomaIni >= nFaixaFim 				 			
			Exit
		Endif

		lPrimeiro := .F.
	Next

	oView:Refresh()

Return lRet

/** {Protheus.doc} AGRA035VLDFX
Verifica se o valor da faixa inicial é maior do que último registro e não sobrescreve.
@param: 	nFxIni  - Faixa Inicial do Pergunte
			nSobres - Se sobrescreve ou não do Pergunte
@return:	lRet
@author: 	Equipe Agroindustria
@since: 	30/11/2017
@Uso: 		AGRA035 - Tabela de Classificação
*/

Function AGRA035VLDFX(nFxIni,nSobres)

Local oModel	:= FwModelActive()
Local oNNK2		:= oModel:GetModel("NNKUNICO")
Local lRet      := .T.

	nLine := oNNK2:Length()
	oNNK2:GoLine(nLine)

	If nFxIni < oNNK2:GetValue("NNK_PERFIM") .And. nSobres = 2
		 MsgAlert(STR0033 + cValtoChar(oNNK2:GetValue("NNK_PERFIM")))   //"Valor inicial não pode ser menor que o último valor final:"
		 lRet := .F.   
	EndIf
	
Return lRet

/*{Protheus.doc} AGRA035DSC
Valida se o Desconto informado é valido
@author marcos.wagner
@since 16/07/2018
@version 1.0
@param
@return ${return}, ${.T. - Validado, .F. - Falso}
@type function
*/
Function AGRA035DSC()
	Local lRet := .t.
	Local oModel 	 := FWModelActive()
	Local cNNJCODTAB := oModel:GetValue( "NNJUNICO", "NNJ_CODTAB" )
	Local cNNJDESREL := oModel:GetValue( "DESUNICO", "NNJ_DESREL" )

	lRet := ExistCpo('NNH')

	If lRet
		cAliasQry := GetNextAlias()
		
		cQry := " SELECT 1 " 
		cQry += " FROM " + RetSqlName('NNJ')
		cQry += " WHERE NNJ_CODTAB =  '" + cNNJCODTAB + "' "
		cQry += "   AND NNJ_FILIAL =  '" + xFilial('NNJ') + "' "
		cQry += "   AND ((NNJ_CODDES = '" + cNNJDESREL + "' AND NNJ_GRUPO = '1')  "
		cQry += "    OR  (NNJ_CODDES = '" + cNNJDESREL + "' AND NNJ_DESREL <> ' ')) "
		//cQry += "    OR  (NNJ_CODDES = '" + cNNJDESREL + "' AND NNJ_GRUPO = '3')) "
		cQry += "   AND D_E_L_E_T_ =  ' ' "
		cQry := ChangeQuery( cQry )	
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
		dbSelectArea(cAliasQry)
		dbGoTop()
		If (cAliasQry)->(!Eof())
			lRet := .f.
		EndIf
		
		(cAliasQry)->(DbCloseArea())
	EndIf

Return lRet

/*{Protheus.doc} AGRA035FIL
Função de filtro da consulta padrão NNJ
@author marcos.wagner
@since 16/07/2018
@version 1.0
@param
@return ${return}, ${.T. - Validado, .F. - Falso}
@type function
*/
Function AGRA035FIL()
	Local lRet := .f.
	Local oModel 	 := FWModelActive()
	Local cNNJCODTAB := oModel:GetValue( "NNJUNICO", "NNJ_CODTAB" )
	Local cNNJCODDES := oModel:GetValue( "NNJUNICO", "NNJ_CODDES" )	

	If NNJ->NNJ_GRUPO <> '1' .AND. NNJ->NNJ_CODTAB == cNNJCODTAB .AND. NNJ->NNJ_CODDES <> cNNJCODDES .AND. Empty(NNJ->NNJ_DESREL)
		lRet := .t.
	EndIf

Return lRet

/*{Protheus.doc} IniModelo
Inicialização do modelo, faz a carga da Grid dos Descontos
@author marcos.wagner
@since 17/07/2018
@version 1.0
@param
@return ${return}
@type function
*/
Static Function IniModelo(oGrid)
	Local nX  := 1
	Local aLoadGrid	:= FormLoadGrid(oGrid, .T.)
	
	cAliasQry := GetNextAlias()
	cQry := " SELECT NNJ_CODDES " 
	cQry += " FROM " + RetSqlName('NNJ')
	cQry += " WHERE NNJ_FILIAL =  '" + xFilial('NNJ') + "' "
	cQry += "   AND NNJ_DESREL =  '" + NNJ->NNJ_CODDES + "' "
	cQry += "   AND NNJ_CODDES <> '" + NNJ->NNJ_CODDES + "' "
	cQry += "   AND NNJ_CODTAB =  '" + NNJ->NNJ_CODTAB + "' "
	cQry += "   AND D_E_L_E_T_ =  ' ' "
	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	
	dbSelectArea(cAliasQry)
	dbGoTop()
	If (cAliasQry)->(!Eof())
		While (cAliasQry)->(!Eof())
				
			aAdd(aLoadGrid, {nX,{ (cAliasQry)->NNJ_CODDES, Posicione("NNH",1,xFilial("NNH")+(cAliasQry)->NNJ_CODDES,"NNH_DESCRI")}})
			nX ++

			(cAliasQry)->(dbSkip())
		EndDo
	EndIf
			
	(cAliasQry)->(DbCloseArea())

Return aLoadGrid

/*{Protheus.doc} TudoOk
Função chamada na validação do model, utilizada para 
gravação dos dados inseridos na Grid de Descontos
@author marcos.wagner
@since 17/07/2018
@version 1.0
@param oModel - Model
@return ${return}
@type function
*/
Static Function TudoOk( oModel )	
	Local aAreaNNJ   := NNJ->(GetArea())	
	Local oModelNNJ  := oModel:GetModel("NNJUNICO")		
	
	if NNJ->(ColumnPos('NNJ_GRUPO')) > 0
		If oModelNNJ:GetValue("NNJ_GRUPO") $ '1|2' .AND. Empty(oModelNNJ:GetValue("NNJ_FORMUL"))
			oModel:GetModel():SetErrorMessage( oModelNNJ:GetId(), , oModelNNJ:GetId(), "", "", STR0040, STR0041, "", "") //"Para 'Grupo ?' = 'Sim' o campo 'Fórmula' deverá ser informado!" ### "Informe o campo 'Fórmula'!"
			Return .f.
		EndIf
	endIf	

	RestArea(aAreaNNJ)

Return .T.

/*{Protheus.doc} AGRA035GRP
Validação do campo NNJ_GRUPO (Grupo?)
@author marcos.wagner
@since 17/07/2018
@version 1.0
@param
@return ${return}
@type function
*/
Static Function AGRA035GRP()

	SelFolder()

Return .t.

/*{Protheus.doc} SelFolder
Função disparada na seleção do Folder de Descontos
@author marcos.wagner
@since 18/07/2018
@version 1.0
@param
@return ${return}
@type function
*/
Static Function SelFolder(oModel)
	//Local oModel 	:= FwModelActive()
	Local cNNJGRUPO 	:= ""
	Local oModelDES 	:= nil
	Local nOperation	:= 0

	Default oModel 	:= FwModelActive()  

	nOperation	:= oModel:GetOperation()

	cNNJGRUPO := oModel:GetValue("NNJUNICO", "NNJ_GRUPO")
	oModelDES := oModel:GetModel("DESUNICO")

	If cNNJGRUPO $ '1|2' .OR. nOperation == MODEL_OPERATION_VIEW //Grupo / SubGrupo 
		oModelDES:SetNoUpdateLine(.F.)
		oModelDES:SetNoInsertLine(.F.)
		oModelDES:SetNoDeleteLine(.F.)
	Else
		oModelDES:SetNoUpdateLine(.T.)
		oModelDES:SetNoInsertLine(.T.)
		oModelDES:SetNoDeleteLine(.F.)		 		 
		oModelDES:DelAllLine() //Deleta todas as linhas
		oModelDES:SetNoDeleteLine(.T.)				
	EndIf
	
Return .f.

/*{Protheus.doc} AGRA35TRIG
Gatilho do campo Descrição
@author marcos.wagner
@since 17/07/2018
@version undefined
@param oField, object, descricao
@type function
*/
Static Function AGRA35TRIG(oField, cFieldRet)
	Local oModel    	:= oField:GetModel()
	Local oModelDES 	:= oModel:GetModel("DESUNICO")
	Local cRetorno      := ''
	Local aAreaNNH      := NNH->(GetArea())

	dbSelectArea("NNH")
	dbSetOrder(1)
	If dbSeek(xFilial("NNH")+oModelDES:GetValue("NNJ_DESREL"))
		cRetorno := NNH->NNH_DESCRI
	EndIf

	RestArea(aAreaNNH)

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRA35VLFL
Validação da função
@author  rafael.voltz
@since   20/07/2018
@version version
/*/
//-------------------------------------------------------------------
Function AGRA35VLFL()
	Local oModel := FWModelActive()
	Local cFormula := alltrim(oModel:GetModel("NNJUNICO"):GetValue("NNJ_FORMUL"))
	Local oLastError := ErrorBlock({|e| cError := e:Description + e:ErrorStack})

	cFormula := StrTran( cFormula, "D", "0") //desconto
	cFormula := StrTran( cFormula, "R", "0") //resultado
	
	If !Empty(cFormula)
		Begin Sequence			
			xTeste := Eval({|| &cFormula})			
		Recover
			ErrorBlock(oLastError)			
		End Sequence
	EndIf	

	If ValType(xTeste) == "N"
		Return .T.
	EndIf
Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} AtualNivel
Atualiza o nivel dos descontos
@author  marcos.wagner
@since   29/08/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function AtualNivel() 
	Local c1Nivel	 := "0"
	Local c2nivel	 := "1"
	Local c3Nivel	 := "1"
	Local cUltGru	 := ""
	Local cUltSbG	 := ""
	Local cGrupoPai  := ""
	Local aAreaNNJ   := NNJ->(GetArea())
	Local aAreaNNJ2  := NNJ->(GetArea())
	Local oModel 	 := FWModelActive()
	Local cNNJCODTAB := oModel:GetValue( "NNJUNICO", "NNJ_CODTAB" )	

	dbSelectArea("NNJ")
	dbSetOrder(4)
	If dbSeek(xFilial("NNJ")+cNNJCODTAB)
		While .Not. NNJ->( Eof() ) .And. NNJ->( NNJ_FILIAL ) == xFilial("NNJ") .And. NNJ->( NNJ_CODTAB ) == cNNJCODTAB

			If !Empty(NNJ->NNJ_DESREL)

				aAreaNNJ2 := NNJ->(GetArea())
				dbSelectArea("NNJ")
				dbSetOrder(1)
				If dbSeek(xFilial("NNJ")+cNNJCODTAB+NNJ->NNJ_DESREL)
					c1Nivel   := StrTran(AllTrim(NNJ->NNJ_NIVEL)," >","")
					cGrupoPai := NNJ->NNJ_GRUPO
					If NNJ->(NNJ_GRUPO) == "1"
						cUltGru := NNJ->NNJ_CODDES
					ElseIf NNJ->(NNJ_GRUPO) == "2"
						cUltSbG := NNJ->NNJ_CODDES //para controlar os filhos de subgrupo
					EndIf
				EndIf

				RestArea(aAreaNNJ2)
			EndIf

			//regra para montar o campo de virtual de nivel
			If NNJ->(NNJ_GRUPO) == "1"
				c1Nivel  := Soma1(c1Nivel) //incrementa mais 1 no grupo
				__cGrava := c1Nivel
				cUltGru := NNJ->NNJ_CODDES //para controlar os filhos de grupo
				c3Nivel := "1"
				c2nivel := "1"
			ElseIf NNJ->(NNJ_GRUPO) == "2" .AND. Empty(NNJ->(NNJ_DESREL))
				c1Nivel  := Soma1(c1Nivel) //incrementa mais 1 no grupo
				If Empty(NNJ->(NNJ_DESREL))
					__cGrava := c1Nivel
				Else
					__cGrava := c1Nivel + "." + c3Nivel
				EndIf	
				cUltSbG := NNJ->NNJ_CODDES //para controlar os filhos de subgrupo
				c2nivel	:= "1"
			Else
			    If !Empty(NNJ->(NNJ_DESREL)) .and. (NNJ->(NNJ_GRUPO) <> "1" .or. Empty(NNJ->(NNJ_GRUPO)))
					If cUltGru == NNJ->NNJ_DESREL //quer dizer que é filho do grupo
						//__cGrava := c1Nivel + "." + c3Nivel + " >"
						If cGrupoPai == "1"
							__cGrava := c1Nivel + "." + c2Nivel + " >"
							c2Nivel  := Soma1(c2Nivel)
						ElseIf cGrupoPai == "2"
							__cGrava := c1Nivel + "." + c3Nivel + " >"
							c3Nivel  := Soma1(c3Nivel)
						EndIf						
					ElseIf cUltSbG == NNJ->NNJ_DESREL //quer dizer que é filho do SubGrupo
						If cGrupoPai == "1"
							__cGrava := c1Nivel + "." + c3Nivel + "." + c2nivel + " >"
						ElseIf cGrupoPai == "2"
							__cGrava := c1Nivel + "." + c3Nivel + " >"
							c3Nivel  := Soma1(c3Nivel)
						EndIf
						c2nivel  := Soma1(c2nivel) //incrementa mais 1 no subgrupo
					Else ///não é filho de ninguem
						__cGrava := c3Nivel + " >"
						c3Nivel  := Soma1(c3Nivel)
					EndIf
				Else
					c1Nivel  := Soma1(c1Nivel) //se nao for filho de ninguem soma o primeiro nivel, como grupo
					__cGrava := c1Nivel + " >"
					c3Nivel  := "1" //sempre que nao entrar em nenhuma opção, zera o nivel e subgrupo
					c2nivel	 := "1"
				EndIf
			EndIf

			If NNJ->NNJ_GRUPO <> "3"
				__cGrava := StrTran(__cGrava," >","")
			EndIf

			Reclock("NNJ",.f.)
			NNJ->NNJ_NIVEL  := __cGrava
			NNJ->(MsUnLock())	

			NNJ->(dbSkip())
		End
	EndIf

	RestArea(aAreaNNJ)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OrdenNivel
Ordena e recria os níveis da tabela de descontos.
@author  thiago.avila
@since   18/09/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function OrdenNivel(cTabela as Char)
	Local cAliasNNJ		as char
	Local cAliasNNJ2	as char
	Local cNivel1		as char //primeiro nivel 1
	Local cNivel2		as char //segundo  nivel 1.1
	Local cNivel3		as char //terceiro nivel 1.1.1
	Local cNivelFim		as char //nivel do registro
	Local aNiveis		as array
	
	if NNJ->(ColumnPos('NNJ_GRUPO')) > 0
		//inicializa os niveis
		cNivel1		:= "0"
		cNivel2		:= "0"
		cNivel3		:= "0"
		cNivelFim	:= ""
	
		cAliasNNJ	:= GetNextAlias() //alias principal
		cAliasNNJ2	:= GetNextAlias() //alias secundário
	
		If Select(cAliasNNJ) <> 0
			(cAliasNNJ)->(dbCloseArea())
		EndIf 
		
		BeginSQL Alias cAliasNNJ 
		  SELECT NNJ_GRUPO, NNJ_DESREL, R_E_C_N_O_ AS RECNO
		    FROM %Table:NNJ%
	       WHERE %notDel%
		   	 AND NNJ_FILIAL = %xFilial:NNJ%
	         AND NNJ_CODTAB = %Exp:cTabela%
	       ORDER BY NNJ_DESREL
		EndSQL
		
		While (cAliasNNJ)->(!Eof())
	
			//busca primeiro os niveis sem grupo
			If ((cAliasNNJ)->NNJ_GRUPO == "3" .OR.;
			    Empty((cAliasNNJ)->NNJ_GRUPO) ) .AND.;
				Empty((cAliasNNJ)->NNJ_DESREL)
				cNivel1		:= Soma1(cNivel1)
				cNivel2		:= "0"
				cNivel3		:= "0"
				cNivelFim	:= cNivel1 + ">"
			
			//busca os grupos
			ElseIf (cAliasNNJ)->NNJ_GRUPO == "1"
				cNivel1		:= Soma1(cNivel1)
				cNivel2		:= "0"
				cNivel3		:= "0"
				cNivelFim	:= cNivel1
			
			//busca os filhos dos grupos e subgrupos
			ElseIf ((cAliasNNJ)->NNJ_GRUPO == "3" .OR.;
			    Empty((cAliasNNJ)->NNJ_GRUPO) ) .AND.;
				!Empty((cAliasNNJ)->NNJ_DESREL)
	
				If Select(cAliasNNJ2) <> 0
					(cAliasNNJ2)->(dbCloseArea())
				EndIf 
	
				//busca o nivel do pai, devido a falta de ordem da tabela
				BeginSQL Alias cAliasNNJ2 
				  SELECT NNJ_NIVEL, NNJ_GRUPO
				    FROM %Table:NNJ%
	    		   WHERE %notDel%
				   	 AND NNJ_FILIAL = %xFilial:NNJ%
	    		     AND NNJ_CODTAB = %Exp:cTabela%
					 AND NNJ_CODDES = %Exp:(cAliasNNJ)->NNJ_DESREL%
	    		   ORDER BY NNJ_DESREL
				EndSQL
		
				If (cAliasNNJ2)->(!Eof())
					aNiveis		:= StrTokArr((cAliasNNJ2)->NNJ_NIVEL, ".")
					If (cAliasNNJ2)->NNJ_GRUPO == '1' //monta para filho do grupo
						If Len(aNiveis) == 1
							cNivel1		:= AllTrim(aNiveis[1])
							cNivel2		:= Soma1(cNivel2)
							cNivelFim	:= cNivel1 + "." + cNivel2 + ">"
						ElseIf Len(aNiveis) == 2
							cNivel1		:= AllTrim(aNiveis[1])
							cNivel2		:= Soma1(AllTrim(aNiveis[2]))
							cNivelFim	:= cNivel1 + "." + cNivel2 + ">"
						EndIf
					Else //monta para filho do subgrupo
						If Len(aNiveis) == 1
							cNivel1		:= AllTrim(aNiveis[1])
							cNivel2		:= Soma1(cNivel2)
							cNivelFim	:= cNivel1 + "." + cNivel2 + ">"
						ElseIf Len(aNiveis) == 2
							cNivel1		:= AllTrim(aNiveis[1])
							cNivel2		:= AllTrim(aNiveis[2])
							cNivel3		:= Soma1(cNivel3)
							cNivelFim	:= cNivel1 + "." + cNivel2 + "." + cNivel3 + ">"
						EndIf
					EndIf
					
				EndIf
				(cAliasNNJ2)->(dbCloseArea())
			
			//busca os subgrupos
			ElseIf (cAliasNNJ)->NNJ_GRUPO == "2" .AND. !Empty((cAliasNNJ)->NNJ_DESREL)
	
				If Select(cAliasNNJ2) <> 0
					(cAliasNNJ2)->(dbCloseArea())
				EndIf 
	
				//busca o nivel do pai, devido a falta de ordem da tabela
				BeginSQL Alias cAliasNNJ2 
				  SELECT NNJ_NIVEL
				    FROM %Table:NNJ%
	    		   WHERE %notDel%
				   	 AND NNJ_FILIAL = %xFilial:NNJ%
	    		     AND NNJ_CODTAB = %Exp:cTabela%
					 AND NNJ_CODDES = %Exp:(cAliasNNJ)->NNJ_DESREL%
	    		   ORDER BY NNJ_DESREL
				EndSQL
		
				If (cAliasNNJ2)->(!Eof())
					aNiveis		:= StrTokArr((cAliasNNJ2)->NNJ_NIVEL, ".")
					If Len(aNiveis) == 1
						cNivel1		:= AllTrim(aNiveis[1])
						cNivel2		:= Soma1(cNivel2)
						cNivelFim	:= cNivel1 + "." + cNivel2
					ElseIf Len(aNiveis) == 2
						cNivel1		:= AllTrim(aNiveis[1])
						cNivel2		:= AllTrim(aNiveis[2])
						cNivel3		:= Soma1(cNivel3)
						cNivelFim	:= cNivel1 + "." + cNivel2 + "." + cNivel3
					EndIf 
					
				EndIf
				(cAliasNNJ2)->(dbCloseArea())
			EndIf
	
			NNJ->(dbGoto((cAliasNNJ)->RECNO))
			If RecLock('NNJ',.F.) 
				NNJ->NNJ_NIVEL := cNivelFim
				NNJ->(MsUnLock())
			EndIf
	
			(cAliasNNJ)->(dbSkip())
		EndDo
		(cAliasNNJ)->(dbCloseArea())
	
		FWFreeObj(aNiveis)
	endIf

Return

/*{Protheus.doc} AGRA35DVLD
Função disparada no valid do campo NNJ_CODDES
@author marcos.wagner
@since 21/11/2018
@version undefined
@param oField, object, descricao
@type function
*/
Function AGRA35DVLD()
	Local lPrimeiro := .t.
	Local oModel	:= FwModelActive()
	Local oView	    := FwViewActive()
	Local oModelDES := oModel:GetModel("DESUNICO")
	Local cAliasQry := GetNextAlias()

	cQry := " SELECT NNH_CODIGO, NNH_DESCRI " 
	cQry += " FROM " + RetSqlName('NNH')
	cQry += " WHERE NNH_FILIAL = '" + FWxFilial('NNH') + "' "
	cQry += "   AND NNH_GRUPO  = '" + M->NNJ_CODDES + "'"
	cQry += "   AND D_E_L_E_T_ = ' ' "
	cQry += "   AND NNH_CODIGO IN ("
	cQry += "      SELECT DISTINCT(NNJ_CODDES) "
	cQry += "             FROM " + RetSqlName('NNJ')
	cQry += "             WHERE NNJ_FILIAL = '" + FWxFilial('NNJ') + "'"
	cQry += "               AND NNJ_CODTAB = '" + NNJ->NNJ_CODTAB + "'"
	cQry += "               AND D_E_L_E_T_ = ' ' )"
	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	dbSelectArea(cAliasQry)
	dbGoTop()
	If (cAliasQry)->(!Eof())

		oModelDES:SetNoUpdateLine(.F.)
		oModelDES:SetNoInsertLine(.F.)
		//oModelDES:SetMaxLine(10000)
		oModelDES:GoLine(1)

		While (cAliasQry)->(!Eof())

			If !lPrimeiro
				oModelDES:AddLine()							
			Endif
			oModelDES:LoadValue( "NNJ_DESREL", (cAliasQry)->NNH_CODIGO )		
			oModelDES:LoadValue( "NNJ_DESCRI", (cAliasQry)->NNH_DESCRI )

			lPrimeiro := .F.

			(cAliasQry)->(dbSkip())
		End

		oModelDES:GoLine(1)
		oView:Refresh()

	EndIf

	(cAliasQry)->(DbCloseArea())

Return .t.

/*/{Protheus.doc} DelMatriz
	Função para excluir toda a matriz de descontos da tabela.
	@type  Static Function
	@author user
	@since 07/04/2020
	@version version	
	/*/
Static Function DelMatriz()
	Local aAreaNJZ := NJZ->(GetArea())
	Local lRet     := .f.

	If MsgYesNo(STR0048)	//"Confirma a exclusão de toda a matriz?"
		Begin Transaction 
			NJZ->(dbSetOrder(1))
			If NJZ->(dbSeek(xFilial("NJZ") + _cCod))
				While NJZ->(NJZ_FILIAL + NJZ_CODTAB) == xFilial("NJZ") + _cCod
					If RecLock("NJZ", .F.)
						NJZ->(dbdelete())
						NJZ->(msUnLock())
						lRet := .t.
					Else
						lRet := .F.
						DisarmTransaction()
					EndIf
					NJZ->(dbSkip())
				EndDo
			Else
				MsgInfo(STR0051, STR0049)
			EndIf
		End Transaction
		
		If lRet
			MsgInfo(STR0050, STR0049) //##"Matriz excluída com sucesso." #Aviso 
		EndIf
	EndIf
	
	RestArea(aAreaNJZ)

Return lRet

/*/{Protheus.doc} GrvModelo
Função para gravar o modelo
@type function
@version 
@author rafael.voltz
@since 07/04/2020
/*/
Static Function GrvModelo(oModel)
	Local aAreaNNJ   := NNJ->(GetArea())	
	Local oModelNNJ  := oModel:GetModel("NNJUNICO")
	Local oModelDES  := oModel:GetModel("DESUNICO")
	Local cNNJCODTAB := oModelNNJ:GetValue("NNJ_CODTAB")
	Local cNNJCODDES := oModelNNJ:GetValue("NNJ_CODDES")	
	Local cNNJGRUPO  := ""
	Local cNNJFORMUL := ""
	Local cNNJSEQ    := ""
	Local nX         := 0
	Local nCont      := 0	

	If FWFormCommit( oModel )
		if NNJ->(ColumnPos('NNJ_GRUPO')) > 0
			cNNJGRUPO  := oModelNNJ:GetValue("NNJ_GRUPO")
			cNNJFORMUL :=  oModelNNJ:GetValue("NNJ_FORMUL")
			cNNJSEQ    := oModelNNJ:GetValue("NNJ_SEQ")		
		endIF

		if NNJ->(ColumnPos('NNJ_DESREL')) > 0
			For nX := 1 to oModelDES:Length()
		
				oModelDES:GoLine( nX )
				If !oModelDES:IsDeleted()
					nCont ++
		
					cNNJDESREL := oModelDES:GetValue("NNJ_DESREL")
			
					dbSelectArea("NNJ")
					dbSetOrder(1)
					If dbSeek(xFilial("NNJ")+cNNJCODTAB+cNNJDESREL)
						Reclock("NNJ",.f.)
						NNJ->NNJ_DESREL := cNNJCODDES
						NNJ->NNJ_SEQ    := cNNJSEQ
						NNJ->NNJ_SEQUEN := StrZero(nCont,3)
						NNJ->(MsUnLock())		
					EndIf
				EndIf
			Next
			
		endIf

		AtualNivel()
	EndIf 

	RestArea(aAreaNNJ)
Return .T.
