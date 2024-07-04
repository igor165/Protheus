#INCLUDE "AGRA035.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

//Se o parametro não existir considerar como "1"
Static _VDAPLICAR := SuperGetMV("MV_AGRDES",.F.,'1')
Static __SXBCdNNI
/** {Protheus.doc} ARMA035
Rotina para Cadastro de Tabelas de Descontos Agricolas
@param: 	Nil
@author: 	Fabiane Schulze
@since: 	05/11/2013
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function AGRA035()
	Local oMBrowse	:= Nil
	Private lCopy := .f.
	
	//Variavel Utilizada no dicionário de dados no campo NNK_PROALT 
	//Função WHEN - If(type('lNNKPROALT')!='U',lNNKPROALT,.T.)
	Private lNNKPROALT := .t.	
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NNI" )
	oMBrowse:SetMenuDef( "AGRA035" )
	oMBrowse:SetDescription( STR0001 ) //"Tabelas de Descontos"
	oMBrowse:AddLegend( "dDataBase >  NNI->NNI_DATFIM", "RED"	, STR0009 ) //"Fora da Validade"
	oMBrowse:AddLegend( "dDataBase <  NNI->NNI_DATINI", "BLUE"	, STR0010 ) //"Antes da Validade"
	oMBrowse:AddLegend( "dDataBase >= NNI->NNI_DATINI .And. dDataBase <= NNI->NNI_DATFIM", "GREEN"	, STR0011 ) //"Dentro da Validade"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()
Return( Nil )

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil .
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		AGRA035 - Espécies
*/
Static Function MenuDef()
	Local aRetM		:= {}
	Local aRotina 	:= {}
	Local nx		:= 0

	aAdd( aRotina, { STR0002   , "PesqBrw"        			, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003   , "ViewDef.AGRA035"			, 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0004   , "ViewDef.AGRA035"			, 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0005   , "ViewDef.AGRA035"			, 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0006   , "ViewDef.AGRA035"			, 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0007   , "AGRA035D(NNI->NNI_CODIGO)", 0, 3, 0, Nil } ) //"Descontos"
	aAdd( aRotina, { STR0008   , "AGRA035P(NNI->NNI_CODIGO)", 0, 3, 0, Nil } ) //"Permissoes"
	aAdd( aRotina, { STR0012   , "ViewDef.AGRA035"			, 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0019   , "AGRA35COPY"				, 0, 9, 0, NIL } ) //Copiar

	//PONTO DE ENTRADA PARA AÇÕES RELACIONADAS
    If ExistBlock('AGR35MNU')
        aRetM := ExecBlock('AGR35MNU',.F.,.F.)
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
@Uso: 		AGRA035 - Espécies
*/
Static Function ModelDef()
	Local oStruNNI := FWFormStruct( 1, "NNI" )
	Local oStruDXX := FWFormStruct( 1, "DXX" )
	Local oStruNNJ := FWFormStruct(1, 'NNJ')
	Local oStruNNK := FWFormStruct(1, 'NNK')
	Local oModel := MPFormModel():New( "AGRA035", , {| oModel | PosModelo( oModel ) })
	Local lCopia := FWIsInCallStack("AGRA35COPY")

	If lCopia

		oStruNNJ:RemoveField( "NNJ_CODTAB" )

		oStruNNK:RemoveField( "NNK_CODTAB" )
		oStruNNK:RemoveField( "NNK_CODDES" )

		cValid := 'ExistCpo("NNH")'
		bValid := FWBuildFeature( STRUCT_FEATURE_VALID, cValid )
		oStruNNJ:SetProperty('NNJ_CODDES',MODEL_FIELD_VALID,bValid)

	    //Criando o modelo e os relacionamentos
	    oModel := MPFormModel():New('AGRA035')
	    oModel:AddFields('NNIUNICO',/*cOwner*/,oStruNNI)
	    oModel:AddGrid('DXXUNICO','NNIUNICO',oStruDXX,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence

	    oModel:AddGrid('NNJUNICO','NNIUNICO',oStruNNJ,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	    oModel:AddGrid('NNKUNICO','NNJUNICO',oStruNNK,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence

	    oModel:SetRelation('DXXUNICO', { { "DXX_FILIAL", "xFilial( 'DXX' )" }, { "DXX_CODTAB", "NNI_CODIGO" } }, DXX->(IndexKey(2))) //IndexKey -> quero a ordenação e depois filtrado
	    oModel:SetRelation('NNJUNICO', { { "NNJ_FILIAL", "xFilial( 'NNJ' )" }, { "NNJ_CODTAB", "NNI_CODIGO" } }, NNJ->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
	    oModel:SetRelation('NNKUNICO', { { "NNK_FILIAL", "xFilial( 'NNK' )" }, { "NNK_CODTAB", "NNI_CODIGO" }, { "NNK_CODDES", "NNJ_CODDES" } }, NNK->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado

	    oModel:SetPrimaryKey( {"NNI_FILIAL", "NNI_CODIGO"} )
	     
	    //Setando as descrições
	    oModel:SetDescription(STR0013 ) //"Tabela de Descontos"
	    oModel:GetModel('NNIUNICO'):SetDescription(STR0014) //"Dados da Tabela"

	    oModel:GetModel('DXXUNICO'):SetDescription(STR0015) //"Tabela x Usuarios"
	    oModel:GetModel('DXXUNICO'):SetUniqueLine( { "DXX_CODUSU" } )
	    oModel:GetModel('DXXUNICO'):SetOptional( .t. )

	    oModel:GetModel('NNJUNICO'):SetDescription(STR0024) //"Dados do Item da Tabela"
	    oModel:GetModel('NNJUNICO'):SetUniqueLine( { "NNJ_CODDES" } )
	    oModel:GetModel('NNJUNICO'):SetOptional( .t. )

	    oModel:GetModel('NNKUNICO'):SetDescription(STR0025) //"Dados dos Sub-Itens da Tabela"
	    oModel:GetModel('NNKUNICO'):SetUniqueLine( { "NNK_SEQ" } ) //"NNK_CODDES",
	    oModel:GetModel('NNKUNICO'):SetOptional( .t. )

	Else
		If _VDAPLICAR == "1"		//retira a obrigatoriedade e trava campo NNI_PRODGR
			oStruNNI:SetProperty("NNI_PRODGR",MODEL_FIELD_OBRIGAT, .F.)					//tira obrigatoriedade do campo
			oStruNNI:SetProperty("NNI_PRODGR",MODEL_FIELD_WHEN, {|| AGRRETFALSO()})		//trava como .F.
		ElseIf _VDAPLICAR == "2" 	//retira a obrigatoriedade e trava campo NNI_CODPRO
			oStruNNI:SetProperty("NNI_CODPRO",MODEL_FIELD_OBRIGAT, .F.)					//tira obrigatoriedade do campo
			oStruNNI:SetProperty("NNI_PRODGR",MODEL_FIELD_OBRIGAT, .F.)					//tira obrigatoriedade do campo
		EndIf
		
		oStruDXX:RemoveField( "DXX_CODTAB" )
	
		oModel:SetDescription( STR0013 ) //"Tabela de Descontos"
	
		oModel:AddFields( "NNIUNICO", Nil, oStruNNI )
		oModel:GetModel( "NNIUNICO" ):SetDescription( STR0014 ) //"Dados da Tabela"
		oModel:SetPrimaryKey( {"NNI_FILIAL", "NNI_CODIGO"} )
		oModel:GetModel( "NNIUNICO" ):SetFldNoCopy( {'NNI_CODPRO','NNI_DESPRO'} ) // Na função Copiar nao copia os campos de retornados em array
	
		oModel:AddGrid( "DXXUNICO", "NNIUNICO", oStruDXX )
		oModel:GetModel( "DXXUNICO" ):SetDescription(STR0015) //"Tabela x Usuarios"
		oModel:GetModel( "DXXUNICO" ):SetUniqueLine( { "DXX_CODUSU" } )
		oModel:GetModel( "DXXUNICO" ):SetOptional( .t. )
	
		oModel:SetRelation( "DXXUNICO", { { "DXX_FILIAL", "xFilial( 'DXX' )" }, { "DXX_CODTAB", "NNI_CODIGO" } }, DXX->( IndexKey( 2 ) ) )
	EndIf

Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		AGRA035 - Modelo de Contratos
*/
Static Function ViewDef()
	Local oStruNNI := FWFormStruct( 2, "NNI" )
	Local oStruDXX := FWFormStruct( 2, "DXX" )
	Local oStruNNJ := FWFormStruct( 2, "NNJ" )
	Local oStruNNK := FWFormStruct( 2, "NNK" )
	Local oModel   := FWLoadModel( "AGRA035" )
	Local oView    := FWFormView():New()
	Local lCopia := FWIsInCallStack("AGRA35COPY")

	If lCopia

		oStruNNJ:RemoveField( "NNJ_CODTAB" )

		oStruNNK:RemoveField( "NNK_CODTAB" )
		oStruNNK:RemoveField( "NNK_CODDES" )

	    oView:SetModel(oModel)

		oView:CreateFolder( "CTRFOLDER")

		//Criação das 2 abas
		oView:AddSheet('CTRFOLDER', 'PRINCIPAL' , STR0023) //"Principal"
		oView:AddSheet('CTRFOLDER', 'ENTREGAS'  , STR0007) //"Descontos"

		//1a Aba do Folder
		oView:AddField('VIEW_NNI', oStruNNI, "NNIUNICO")
		oView:AddGrid( "VIEW_DXX", oStruDXX, "DXXUNICO" )
		oView:AddIncrementField( "VIEW_DXX", "DXX_ITEM" )

		oView:CreateHorizontalBox( "BOX-ABA1-TOP" , 50, , , "CTRFOLDER", "PRINCIPAL" )
		oView:CreateHorizontalBox( "BOX-ABA1-BOT" , 50, , , "CTRFOLDER", "PRINCIPAL" )
		oView:SetOwnerView( "VIEW_NNI", "BOX-ABA1-TOP" )
		oView:EnableTitleView( "VIEW_NNI" )
		oView:SetOwnerView( "VIEW_DXX", "BOX-ABA1-BOT" )
		oView:EnableTitleView( "VIEW_DXX" )

		//2a Aba do Folder
		oView:AddGrid( "VIEW_NNJ", oStruNNJ, "NNJUNICO" )
		oView:AddGrid( "VIEW_NNK", oStruNNK, "NNKUNICO" )

		oView:CreateHorizontalBox( "BOX-ABA2-TOP" , 50, , , "CTRFOLDER", "ENTREGAS" )
		oView:CreateHorizontalBox( "BOX-ABA2-BOT" , 50, , , "CTRFOLDER", "ENTREGAS" )
	
		oView:SetOwnerView( "VIEW_NNJ", "BOX-ABA2-TOP" )
		oView:SetOwnerView( "VIEW_NNK", "BOX-ABA2-BOT" )

		oView:EnableTitleView( "VIEW_NNJ" )
		oView:EnableTitleView( "VIEW_NNK" )

		oView:AddIncrementField("VIEW_NNJ",'NNJ_SEQ')
		oView:AddIncrementField("VIEW_NNK",'NNK_SEQ')

 		oView:SetCloseOnOk( {||.t.} )
	Else
		oStruDXX:RemoveField( "DXX_CODTAB" )
	
		oView:SetModel( oModel )
	
		oView:AddField( "VIEW_NNI", oStruNNI, "NNIUNICO" )
		oView:AddGrid( "VIEW_DXX", oStruDXX, "DXXUNICO" )
	
		oView:AddIncrementField( "VIEW_DXX", "DXX_ITEM" )
	
		oView:CreateVerticallBox( "TELANOVA" , 100 )
		oView:CreateHorizontalBox( "SUPERIOR" , 50, "TELANOVA" )
		oView:CreateHorizontalBox( "INFERIOR" , 50, "TELANOVA" )
	
		oView:SetOwnerView( "VIEW_NNI", "SUPERIOR" )
		oView:SetOwnerView( "VIEW_DXX", "INFERIOR" )
	
		oView:EnableTitleView( "VIEW_NNI" )
		oView:EnableTitleView( "VIEW_DXX" )
	
		oView:SetCloseOnOk( {||.t.} )
	EndIf

Return( oView )

/** {Protheus.doc} PosModelo
Função que valida o modelo de dados após a confirmação

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Bruna Rocio
@since: 	14/09/2014
@Uso: 		AGRA035 - Tabela de Classificação
*/
Static Function PosModelo( oModel )
	Local lRetorno		:= .t.
	Local aAreaAtu		:= GetArea()
	Local cTabPDR		:= oModel:GetValue( "NNIUNICO", "NNI_TABPDR" )
	Local cProduto		:= oModel:GetValue( "NNIUNICO", "NNI_CODPRO" )
	Local cGpProd		:= oModel:GetValue( "NNIUNICO", "NNI_PRODGR" )
	Local cPadrao		:= '1'
	Local cTabela		:= oModel:GetValue( "NNIUNICO", "NNI_CODIGO")	
	Local nOperation	:= oModel:GetOperation()
	
	If _VDAPLICAR == "1"		//retira a obrigatoriedade e trava campo NNI_CODPRO
		If !Empty(cGpProd) 
			Help( , , STR0016, , STR0020, 1, 0 ) //"A tabela de descontos não pode considerar Cod.Produto e Grp.Produto. Favor informar somente Cod.Produto ou Grp.Produto para a tabela."
			lRetorno := .f.
		Endif
	ElseIf _VDAPLICAR == "2"	//retira a obrigatoriedade e trava campo NNI_PRODGR/NNI_CODPRO
		If !Empty(cGpProd) .AND. !Empty(cProduto) 
			Help( , , STR0016, , STR0020, 1, 0 ) //"A tabela de descontos não pode considerar Cod.Produto e Grp.Produto. Favor informar somente Cod.Produto ou Grp.Produto para a tabela."##ajuda
			lRetorno := .F.
		Endif
		If Empty(cGpProd) .AND. Empty(cProduto) 
			Help( , , STR0016, , STR0021, 1, 0 ) //"Informar Cod.Produto ou Grp.Produto para a tabela."##Ajuda
			lRetorno := .F.
		Endif
	EndIf	
	
	If nOperation != MODEL_OPERATION_DELETE	
		If cTabPDR == "1" //.And. cTabPDR != NNI->( NNI_TABPDR)
			
			If !Empty(cProduto) 
				dbSelectArea( "NNI" )
				NNI->( DbSetOrder( 3 ) )
				NNI->( DbSeek( xFilial( "NNI" ) + cProduto) ) 
				While !NNI->(EOF()) .And. NNI->(NNI_FILIAL) == xFilial( "NNI" ) .And. NNI->(NNI_CODPRO) == cProduto
		
					If ( NNI->( NNI_CODIGO ) <> cTabela ) .And. .Not. Empty(NNI->( NNI_CODIGO )) .And. NNI->( NNI_TABPDR ) == cPadrao
						Help( , , STR0016, , (STR0017 + NNI->( NNI_CODIGO )), 1, 0 ) //Já existe tabela padrão informada para o produto. Tabela: 
						lRetorno := .f.
						Exit
					Endif
		
					NNI->( dBSkip() )
				EndDo
			ElseIf !Empty(cGpProd) 
				dbSelectArea( "NNI" )
				NNI->( DbSetOrder( 4 ) )
				NNI->( DbSeek( xFilial( "NNI" ) + cGpProd) ) 
				While !NNI->(EOF()) .And. NNI->(NNI_FILIAL) == xFilial( "NNI" ) .And. NNI->(NNI_PRODGR) == cGpProd
		
					If ( NNI->( NNI_CODIGO ) <> cTabela ) .And. .Not. Empty(NNI->( NNI_CODIGO )) .And. NNI->( NNI_TABPDR ) == cPadrao
						Help( , , STR0016, , (STR0017 + NNI->( NNI_CODIGO )), 1, 0 ) //Já existe tabela padrão informada para o produto. Tabela: 
						lRetorno := .f.
						Exit
					Endif
		
					NNI->( dBSkip() )
				EndDo		
			EndIf
		Endif
	Endif
	

	If nOperation == MODEL_OPERATION_DELETE
		dbSelectArea("NNJ")
		NNJ->( dbSetOrder( 1 ) )  //NNJ_FILIAL+NNJ_CODTAB+NNJ_CODDES
		IF NNJ->(DbSeek(xFilial("NNJ") + NNI->NNI_CODIGO  ))
			Help( , , "STR0016", , STR0018, 1, 0 ) //#aJUDA#'Tabela não pode ser excluida pois existe tabela de descontos, vinculados a esta tabela'
			lRetorno := .f.
		EndIF
	EndIF
	
	RestArea( aAreaAtu )

Return( lRetorno )


/** {Protheus.doc} AGRA35COPY
Função de cópia do modelo 

@param: 	Nil
@return:	Nil
@author: 	Equipe Agroindustria
@since: 	30/06/2016
@Uso: 		AGRA035 - Tabela de Classificação
*/
Function AGRA35COPY()
	lCopy := .t.

	FWExecView('STR0009',"AGRA035",9,,{|| .T.}) //"Cópia"
Return

/*{Protheus.doc} AGRA035SXB
Consulta Especifica da Tabela de Descontos
@author jean.schulze
@since 31/07/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/
Function AGRA035SXB()
	Local aArea     := GetArea()
	Local oDlg	    := Nil
	Local oFwLayer  := Nil
	Local oPnDown   := Nil
	Local oSize     := Nil
	Local oMBrowse	:= Nil
	Local oModel    := FwModelActive()
	Local oModelNJR	:= nil
	Local oModelN79	:= nil
	Local cFiltro	:= ""
	 
	Private lCopy       := .f.
	Private lNNKPROALT  := .t.	
	Private _lRet 	    := .f.
	
	//reset
	__SXBCdNNI := ""
	
	//valida o modelo
	if valtype(oModel) == "O" .and. oModel:GetId() $ "OGA290|OGA280|OGA270|OGA260"
		__SXBCdNNI := oModel:GetValue("NJRUNICO", "NJR_TABELA")
	elseif valtype(oModel) == "O" .and. oModel:GetId() $ "OGA700" 
		__SXBCdNNI := oModel:GetValue("N79UNICO", "N79_TABELA")
	endif

	//Filtro
	If FWIsInCallStack("OGA290") .OR. FWIsInCallStack("OGA270")
		oModelNJR := oModel:GetModel("NJRUNICO")
		If !Empty(oModelNJR:GetValue("NJR_CODPRO"))
			cFiltro := " NNI_CODPRO = '"+ AllTrim(oModelNJR:GetValue("NJR_CODPRO")) + "' "
		EndIf
	Elseif FWIsInCallStack("OGA700")
		oModelN79 := oModel:GetModel("N79UNICO")
		If !Empty(oModelN79:GetValue("N79_CODPRO"))
			cFiltro := " NNI_CODPRO = '"+ AllTrim(oModelN79:GetValue("N79_CODPRO")) + "' "
		EndIf
	endif


	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3] *0.8, oSize:aWindSize[4]*0.8, "Consulta Tabela de Desconto" , , , , , CLR_BLACK, CLR_WHITE, , , .t. ) 

	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlg, .f., .t. )

	oFWLayer:AddLine( 'UP', 10, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )

	oFWLayer:AddLine( 'DOWN', 90, .F. )
	oFWLayer:AddCollumn( 'ALL' , 100, .T., 'DOWN' )
	
	oPnDown := TPanel():New( oSize:GetDimension("ALL","LININI"), oSize:GetDimension("ALL","COLINI"), ,oDlg, , , , , ,oSize:GetDimension("ALL","COLEND")/1.26, oSize:GetDimension("ALL","LINEND") * 0.72)

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NNI" )
	oMBrowse:SetMenuDef( "AGRA035" )
	oMBrowse:SetDescription( STR0001 ) //"Tabelas de Descontos"
	oMBrowse:AddLegend( "dDataBase >  NNI->NNI_DATFIM", "RED"	, STR0009 ) //"Fora da Validade"
	oMBrowse:AddLegend( "dDataBase <  NNI->NNI_DATINI", "BLUE"	, STR0010 ) //"Antes da Validade"
	oMBrowse:AddLegend( "dDataBase >= NNI->NNI_DATINI .And. dDataBase <= NNI->NNI_DATFIM", "GREEN"	, STR0011 ) //"Dentro da Validade"
	oMBrowse:DisableDetails()
	oMBrowse:SetExecuteDef(99)
	oMBrowse:SetFilterDefault(cFiltro)
	oMBrowse:SetDoubleClick( {|| __SXBCdNNI := NNI->NNI_CODIGO, oDlg:End() })
	oMBrowse:Activate(oPnDown)
		
	oDlg:Activate( , , , .t., { || .t.,  }, , { || EnchoiceBar(oDlg,{|| _lRet := .t. ,oDlg:End()},{||  oDlg:End() },,/* @aButtons */,,,.f.,.f.,.f.,.t.,.f.) } )
	 
	if _lRet
		__SXBCdNNI := NNI->NNI_CODIGO
	endif 
	
	RestArea(aArea)
 
return .t.


/*{Protheus.doc} AGRA035RET
Retorno da consulta Padrão
@author jean.schulze
@since 31/07/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/
Function AGRA035RET()
	Local lRetorno  := ""
	
	lRetorno := __SXBCdNNI
	
return lRetorno                                                                                                                                                                                                                                          