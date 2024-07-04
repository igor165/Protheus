#Include "OGA010.ch"
#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"
#Include "TOPCONN.CH"

Static lAutCli := .F.
Static lAutFor  := .F.
STATIC lAutomato   := IiF(IsBlind(),.T.,.F.)

/** {Protheus.doc} OGA010
Rotina para cadastro de entidades (produtores de grãos PF ou PJ)

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
@type function
*/
Function OGA010()
	Local oMBrowse	:= Nil

	If ( (SuperGetMV('MV_AGRO012',,'1') == '2') .Or. (SuperGetMV('MV_AGRO013',,'1') == '2') ) .And.;
		     !IsInCallStack("MATA030") .And. !IsInCallStack("MATA020")
	     OGA010EAUT(.T.)
    EndIf

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NJ0" )
	oMBrowse:SetDescription( STR0001 ) //"Entidades"
	oMBrowse:AddLegend( "NJ0_ATIVO='2'",  "BLACK"		, STR0028 ) //"Cadastro inativo"
	oMBrowse:AddLegend( "NJ0_CLASSE='1'", "WHITE"		, STR0002 ) //"Proprio"
	oMBrowse:AddLegend( "NJ0_CLASSE='2'", "GREEN"		, STR0003 ) //"Cooperado"
	oMBrowse:AddLegend( "NJ0_CLASSE='3'", "ORANGE"	, STR0004 ) //"Terceiro"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()
Return( )

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA010 - Entidades
*/
Static Function MenuDef()
	Local aRotina	:= {}

	aAdd( aRotina, { STR0005	, "PesqBrw"			, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0006	, "ViewDef.OGA010"	, 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0007	, "ViewDef.OGA010"	, 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0008	, "ViewDef.OGA010"	, 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0009	, "ViewDef.OGA010"	, 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0010	, "ViewDef.OGA010"	, 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0011	, "ViewDef.OGA010"	, 0, 9, 0, Nil } ) //"Copiar"
	aAdd( aRotina, { STR0040	, "OGA010EAUT(.F.)"	    , 0, 11, 0, Nil } ) //"Carga Entidade"
	aAdd( aRotina, { STR0056	, "OGAA970POR()"	    , 0, 11, 0, Nil } ) //"Regras de Qualidade por Clientes"
	If FindFunction("OGA010PROD")
	   aAdd( aRotina, {STR0035 , 'OGA010PROD', 0, 10, 0, Nil } ) //'Importar Produtor'
	EndIf

Return( aRotina )

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA010 - Entidades
*/
Static Function ModelDef()
	Local oStruNJ0	:= FWFormStruct( 1, "NJ0" )
	Local oStruNN0	:= FWFormStruct( 1, "NN0" )
	Local oModel

	//oStruNJ0:AddField( "Tipo Pessoa", "Tipo de pessoa", 'TMP_TIPO', 'C' , 1 , 0 , /*bValid*/, /*bWhen*/, /*aValues*/{"F=Fisica","J=Juridica"}, /*lObrigat*/.T. , /*bInit*/, .F./*lKey*/, /*lNoUpd*/, /*lVirtual*/) 	//"Serie NF Tr."##"Série da NF de Transito"
	oStruNN0:RemoveField( "NN0_CODENT" )

	//oStruNJ0:SetProperty( "NJ0_CGC" 	, MODEL_FIELD_VALID, {| oField | fVldCGCIE( oField ) } )
	oStruNJ0:SetProperty( "NJ0_INSCR" 	, MODEL_FIELD_VALID, {| oField | fVldCGCIE( oField ) } )
	oStruNJ0:SetProperty( "NJ0_LOJENT" , MODEL_FIELD_VALID, {| oField | fVaLojEnt( oField ) } )

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New( "OGA010", /*bPre*/ , {| oModel | PosModelo( oModel ) } , {| oModel | GrvModelo( oModel ) } , /*bCancel*/  )

	oModel:SetDescription( STR0012 ) //"Entidade"
	oModel:AddFields( "NJ0UNICO", Nil, oStruNJ0 )
	oModel:GetModel( "NJ0UNICO" ):SetDescription( STR0013 ) //"Dados da Entidade"

	oModel:AddGrid( "NN0UNICO", "NJ0UNICO", oStruNN0, , , , , {|oGrid,lCopia| fLoadGdNN0(oGrid,lCopia)})
	oModel:GetModel( "NN0UNICO" ):SetDescription( STR0014 ) //"Dados Bancarios"
	oModel:GetModel( "NN0UNICO" ):SetUniqueLine( { "NN0_CODBCO", "NN0_CODAGE", "NN0_CODCTA" } )
	oModel:GetModel( "NN0UNICO" ):SetOptional( .t. )
	oModel:SetRelation( "NN0UNICO", { { "NN0_FILIAL", "NJ0_FILIAL" }, { "NN0_CODENT", "NJ0_CODENT" } }, NN0->( IndexKey( 1 ) ) )

	//oModel:GetModel( 'NN0UNICO' ):SetLoadFilter( { { 'NN0_CODENT', "'000001'" } } )
	oModel:GetModel( "NN0UNICO" ):SetUseOldGrid( .f. ) //correção ponto de entrada - cadastro de fornecedores.

	//oModel:SetVldActivate( { | oModel | OGA010A( oModel, oModel:GetOperation() ) } )
	oModel:SetActivate({|oModel| fValCPOSNJ0(oModel:GetOperation() ,oModel)})

Return( oModel )

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA010 - Entidades
*/
Static Function ViewDef()
	Local oStruNJ0	:= FWFormStruct( 2, "NJ0" )
	Local oStruNN0	:= FWFormStruct( 2, "NN0" )
	Local oModel		:= FWLoadModel( "OGA010" )
	Local oView		:= FWFormView():New()

	//// O Trecho abaixo foi deixado em comentário porque não está funcionando como deveria, está deixando o campo com ***.*******-** para o CPF
	//// e 00.0000000/0000-00 para o CNPJ.
	//// Será liberado sem a funcionalidade de Picture Variável, porém estamos abrindo um chamado no framework para analisar o problema.
	//// Quando estiver ok, basta tirar o comentário abaixo, e comentar o trecho que fixa a picture como CNPJ
	//
	//	oStruNJ0:AddField("TMP_TIPO", "01", "Tipo Pessoa", "Tipo de pessoa", {},"C","@!",Nil,Nil,.T.,"1",Nil,{"F=Fisica","J=Juridica"},Nil,Nil,.T.)	 //"Serie NF Tr."##"Série da NF de Transito"
	//
	//	// Ajusta a picture do campo de acordo com o valor digitado
	//	oStruNJ0:SetProperty( "NJ0_CGC", MVC_VIEW_PVAR, FwBuildFeature( STRUCT_FEATURE_PICTVAR, "OGA010Pi()" ) )

	//	If Len( AllTrim( NJ0->NJ0_CGC ) ) == 11
	//		oStruNJ0:SetProperty( "NJ0_CGC", MVC_VIEW_PICT, "@R 999.999.999-99" )
	//	Else
	If cPaisLoc = "BRA" //DAGROGAP-519
		oStruNJ0:SetProperty( "NJ0_CGC", MVC_VIEW_PICT, "@R 99.999.999/9999-99" )
	EndIf

	oStruNN0:RemoveField( "NN0_CODENT" )
	oView:SetModel( oModel )
	oView:AddField( "VIEW_NJ0", oStruNJ0, "NJ0UNICO" )
	oView:AddGrid( "VIEW_NN0", oStruNN0, "NN0UNICO" )

	oView:AddIncrementField( "VIEW_NN0", "NN0_ITEM" )
	oView:CreateVerticallBox( "TELANOVA" , 100 )
	oView:CreateHorizontalBox( "SUPERIOR" , 70, "TELANOVA" )
	oView:CreateHorizontalBox( "INFERIOR" , 30, "TELANOVA" )

	oView:SetOwnerView( "VIEW_NJ0", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_NN0", "INFERIOR" )

	oView:EnableTitleView( "VIEW_NJ0" )
	oView:EnableTitleView( "VIEW_NN0" )

	//--					Adicionando Grupos na view						--//
	oStruNJ0:AddGroup( 'GRUPOA', '', '', 1 )
	oStruNJ0:AddGroup( 'GRUPOB', 'Cadastro de Fornecedor vinculado', '', 2 )
	oStruNJ0:AddGroup( 'GRUPOC', 'Cadastro de Cliente vinculado', '', 3 )

	//-- Atribuindo Todos os Campos ao Grupo A --//
	oStruNJ0:SetProperty( '*' , MVC_VIEW_GROUP_NUMBER, 'GRUPOA' )

	//-- Atribuindo os Campos de Fornecedor ao Grupo B--//
	oStruNJ0:SetProperty( 'NJ0_CODFOR' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJ0:SetProperty( 'NJ0_LOJFOR' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJ0:SetProperty( 'NJ0_NOMFOR' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	oStruNJ0:SetProperty( 'NJ0_NLJFOR' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	If ColumnPos("NJ0_DEPALF") > 0
		oStruNJ0:SetProperty( 'NJ0_DEPALF' , MVC_VIEW_GROUP_NUMBER, 'GRUPOB' )
	EndIf
	//-- Atribuindo os Campos de Cliente ao Grupo C --//
	oStruNJ0:SetProperty( 'NJ0_CODCLI' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJ0:SetProperty( 'NJ0_LOJCLI' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJ0:SetProperty( 'NJ0_NOMCLI' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )
	oStruNJ0:SetProperty( 'NJ0_NLJCLI' , MVC_VIEW_GROUP_NUMBER, 'GRUPOC' )

	oView:SetCloseOnOk( {||.t.} )

Return( oView )

/** {Protheus.doc} OGA010Pi
Formata a picture do campo CGC para pessoa fisica (CPF) ou juridica (CNPJ) das entidades.

@return:	cPict - Picture para pessoa fisica ou juridica.
@author:	Marlon Richard Trettin
@since:	03/03/2015
@Uso: 		OGA010 - Entidades
*/
Function OGA010Pi()
	Local oModel	:= FwModelActive()
	Local cTipo	:= oModel:GetValue( "NJ0UNICO", "TMP_TIPO" )
	Local cPict	:= ""

	//	If Len( AllTrim( cCGC ) ) == 11
	If cTipo == "F"
		cPict := "@R 999.999.999-99"
	Else
		cPict := "@R 99.999.999/9999-99"
	Endif

Return( cPict )

/** {Protheus.doc} PosModelo
Função que valida o modelo de dados após a confirmação

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA010 - Entidades
*/
Static Function PosModelo( oModel )
	Local lRetorno	:= .t.
	Local aAreaAtu	:= GetArea()
	Local nOperation	:= oModel:GetOperation()
	Local cCodEnt		:= oModel:GetValue( "NJ0UNICO", "NJ0_CODENT" )
	Local cLojEnt		:= oModel:GetValue( "NJ0UNICO", "NJ0_LOJENT" )
	Local cCodCRP		:= oModel:GetValue( "NJ0UNICO", "NJ0_CODCRP" )
	Local cCodFor		:= oModel:GetValue( "NJ0UNICO", "NJ0_CODFOR" )
	Local cLojFor		:= oModel:GetValue( "NJ0UNICO", "NJ0_LOJFOR" )
	Local cCodCli		:= oModel:GetValue( "NJ0UNICO", "NJ0_CODCLI" )
	Local cLojCli		:= oModel:GetValue( "NJ0UNICO", "NJ0_LOJCLI" )
	Local cCGC			:= oModel:GetValue( "NJ0UNICO", "NJ0_CGC" )
	Local cInscr		:= oModel:GetValue( "NJ0UNICO", "NJ0_INSCR" )

	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE

		If lRetorno .And. .Not. Empty( cCodCRP )

			BeginSql Alias 'QryNJ0'
			Select Count( NJ0.NJ0_CODENT ) As Total
			From %table:NJ0% NJ0
			Where NJ0.NJ0_FILIAL = %xFilial:NJ0% And NJ0.NJ0_CODCRP = %exp:cCodCRP% 
			And (NJ0.NJ0_CODENT <> %exp:cCodEnt% Or NJ0.NJ0_LOJENT <> %exp:cLojEnt%)
			And NJ0.%NotDel%
			EndSql
			If .Not. QryNJ0->( Eof() ) .And. QryNJ0->( Total ) > 0
				Alert( STR0015 ) //"Não pode haver duas entidades representando a mesma empresa, unidade de negocio e filial!"
				lRetorno := .f.
			EndIf
			QryNJ0->( dbCloseArea( ) )

		EndIf

		If lRetorno .and. .Not. Empty( AllTrim( cCodFor + cLojFor ) )
			BeginSql Alias 'QryNJ0F'
			Select
			Count( * ) As Total
			From
			%table:NJ0% NJ0
			Where
			NJ0.NJ0_FILIAL = %xFilial:NJ0% And
			( NJ0.NJ0_CODENT <> %exp:cCodEnt% OR NJ0.NJ0_LOJENT <> %exp:cLojEnt% ) And
			( NJ0.NJ0_CODFOR = %exp:cCodFor% And NJ0.NJ0_LOJFOR = %exp:cLojFor% ) And
			NJ0.%NotDel%
			EndSql
			If .Not. QryNJ0F->( Eof() ) .And. QryNJ0F->( Total ) > 0
	        	If !lAutomato		
					Help(, , STR0016, , STR0017, 1, 0 ) //"Ajuda"###"Não pode haver duas entidades representando o mesmo fornecedor!"
				ENDIF	
				lRetorno := .f.
			EndIf
			QryNJ0F->( dbCloseArea( ) )

			// Verifica se o fornecedor escolhido possui o mesmo CNPJ/CPF + IE da Entidade
			If !IsInCallStack("IntegrEnt")
				BeginSql Alias "QrySA2"
				Select * From %table:SA2% SA2
				Where SA2.A2_FILIAL = %xFilial:SA2%
				And SA2.A2_COD    = %Exp:cCodFor%
				And SA2.A2_LOJA   = %Exp:cLojFor%
				And SA2.A2_MSBLQL <> '1'
				And SA2.%NotDel%
				EndSql
				QrySA2->( dbGoTop() )
				If .Not. QrySA2->( Eof() )
					If AllTrim( cCGC ) <> AllTrim( QrySA2->( A2_CGC ) )
						If cPaisLoc = "PAR" //DAGROGAP-532
							Help( ,, STR0001,, STR0032 + QrySA2->( A2_CGC ), 1, 0) //'HELP'###"O RUC da Entidade difere do RUC do Fornecedor associado: "
						Else
							Help( ,, STR0001,, STR0021 + QrySA2->( A2_CGC ), 1, 0) //'HELP'###"O CNPJ/CPF da Entidade difere do CNPJ/CPF do Fornecedor associado: "
						EndIf
						lRetorno := .f.
					EndIf
					If AllTrim( cInscr ) <> AllTrim( QrySA2->( A2_INSCR ) )
						Help( ,, STR0001,, STR0022 + QrySA2->( A2_INSCR ), 1, 0) //'HELP'###"A Ins.Estad. da Entidade difere da Ins.Estad. do Fornecedor associado: "
						lRetorno := .f.
					EndIf
				Else
					Help( ,, STR0001,, STR0023 + cCodFor+" - "+cLojFor, 1, 0) //'HELP'###"Fornecedor não localizado no cadastro de Fornecedor (SA2): "
					lRetorno := .f.
				EndIf
				QrySA2->( dbCloseArea( ) )
			EndIf
		EndIf

		If lRetorno .and. .Not. Empty( AllTrim( cCodCli + cLojCli ) ) .AND. !IsInCallStack("IntegrEnt")
			BeginSql Alias 'QryNJ0C'
			Select
			Count( * ) As Total
			From
			%table:NJ0% NJ0
			Where
			NJ0.NJ0_FILIAL = %xFilial:NJ0% And
			( NJ0.NJ0_CODENT <> %exp:cCodEnt% OR NJ0.NJ0_LOJENT <> %exp:cLojEnt% ) And
			( NJ0.NJ0_CODCLI = %exp:cCodCli% And NJ0.NJ0_LOJCLI = %exp:cLojCli% ) And
			NJ0.%NotDel%
			EndSql
			If .Not. QryNJ0C->( Eof() ) .And. QryNJ0C->( Total ) > 0
				Help(, , STR0016, , STR0018, 1, 0 ) //"Ajuda"###"Não pode haver duas entidades representando o mesmo cliente!"
				lRetorno := .f.
			EndIf
			QryNJ0C->( dbCloseArea( ) )

			// Verifica se o cliente escolhido possui o mesmo CNPJ/CPF + IE da Entidade
			BeginSql Alias "QrySA1"
			Select * From %table:SA1% SA1
			Where SA1.A1_FILIAL = %xFilial:SA1%
			And SA1.A1_COD    = %Exp:cCodCli%
			And SA1.A1_LOJA   = %Exp:cLojCli%
			And SA1.A1_MSBLQL <> '1'
			And SA1.%NotDel%
			EndSql
			QrySA1->( dbGoTop() )
			If .Not. QrySA1->( Eof() )
				If AllTrim( cCGC ) <> AllTrim( QrySA1->( A1_CGC ) )
					If cPaisLoc = "PAR" //DAGROGAP-532
						Help( ,, STR0001,, STR0031 + QrySA1->( A1_CGC ), 1, 0) //'HELP'###"O RUC da Entidade difere do RUC do Cliente associado: "
					Else
						Help( ,, STR0001,, STR0025 + QrySA1->( A1_CGC ), 1, 0) //'HELP'###"O CNPJ/CPF da Entidade difere do CNPJ/CPF do Cliente associado: "
					EndIf

					lRetorno := .f.
				EndIf
				If AllTrim( cInscr ) <> AllTrim( QrySA1->( A1_INSCR ) )
					Help( ,, STR0001,, STR0026 + QrySA1->( A1_INSCR ), 1, 0) //'HELP'###"A Ins.Estad. da Entidade difere da Ins.Estad. do Cliente associado: "
					lRetorno := .f.
				EndIf
			Else
				Help( ,, STR0001,, STR0027 + cCodFor+" - "+cLojFor, 1, 0) //'HELP'###"Cliente não localizado no cadastro de Cliente (SA1): "
				QrySA1->( dbCloseArea( ) )
				Return( .F. )
			Endif
			QrySA1->( dbCloseArea( ) )

		Endif
	EndIf

	If lRetorno .and. nOperation == MODEL_OPERATION_INSERT

		//Busca o registro com a chave primária
		BeginSql Alias 'QryNJ0UNQ'
		Select Count( * ) As Total
		From %table:NJ0% NJ0
		Where NJ0.NJ0_FILIAL = %xFilial:NJ0%
		And NJ0.NJ0_CODENT = %exp:cCodEnt%
		And NJ0.NJ0_LOJENT = %exp:cLojEnt%
		And NJ0.%NotDel%
		EndSql
		If QryNJ0UNQ->( Total ) > 0

			Help( ,, STR0001,, STR0030, 1, 0) //'HELP'###"Entidade informada já está cadastrada"

			QryNJ0UNQ->( dbCloseArea( ) )
			Return( .F. )
		EndIf
		QryNJ0UNQ->( dbCloseArea( ) )

	EndIf

	If lRetorno .and. nOperation == MODEL_OPERATION_DELETE

		BeginSql Alias 'QryNJM'
		Select Count( * ) As Total
		From %table:NJM% NJM
		Where NJM.NJM_CODENT = %exp:cCodEnt% And NJM.NJM_LOJENT = %exp:cLojEnt% And NJM.NJM_FILIAL = %xFilial:NJM% And NJM.%NotDel%
		EndSql
		If QryNJM->( Total ) > 0
			Help(, , STR0016, , STR0024, 1, 0 ) //"Ajuda"###"Entidade ja utilizada na tabela de -Romaneios-!"
			lRetorno := .f.
		EndIf
		QryNJM->( dbCloseArea( ) )	

	EndIf

	// Ponto de entrada para o usuário poder adicionar alguma validação antes da gravação dos dados da entidade
	If lRetorno .And. (ExistBlock("OGA010OK"))
		lRetorno := ExecBlock("OGA010OK",.F.,.F.,{oModel,"PosModelo","OGA010"})
	EndIf

	RestArea( aAreaAtu )

Return( lRetorno )

//-------------------------------------------------------------------
	/*/{Protheus.doc} fValCposNJ0(nOperation, oStruct)
	Rotina para bloquear alguns campos de serem Alterados na NJ0, Qdo ja existirem
	ctratos confirmados para os mesmos.

	@author Emerson
	@since 02/12/2014
	@version 1.0
	@return lRet
	/*/
//-------------------------------------------------------------------
Function fValCposNJ0(nOperation, oModelo )
	Local cQuery := ''
	Local lAlterar := .t.
	Local lClieNI  := .f.
	Local lFornNI  := .f.

	IF nOperation == MODEL_OPERATION_UPDATE

		cquery:=''
		cquery += " SELECT COUNT(NJR.R_E_C_N_O_) AS NR_CTRATOS FROM " + RetSqlName('NJR')+ " NJR "
		cQuery += " WHERE NJR.D_E_L_E_T_ = ' ' "
		cQuery+=  " AND NJR.NJR_CODENT = '" + NJ0->NJ0_CODENT + "'"
		cQuery+=  " AND NJR.NJR_LOJENT = '" + NJ0->NJ0_LOJENT + "'"
		cquery+=  " AND NJR_FILIAL = '" + xFilial('NJR') + "'"
		cQuery+=  " AND NJR_STATUS IN( 'A' , 'I')"  //Ctrato Aberto / iniciado


		cQuery:= ChangeQuery(cQuery)

		If select("QryNJR") <> 0
			QryNJR->( dbCloseArea() )
		endif

		TCQUERY cQuery NEW ALIAS "QryNJR"

		QryNJR->( DbGotop() )

		lAlterar:=iIf(QryNJR->NR_CTRATOS > 0 , .f. ,.t.) //SeExistem ctratos iniciados ou abertos n. pode alterar forn.cliente.
		QryNJR->( dbCloseArea() )
		lClieNI := Empty(NJ0->NJ0_CODCLI) .or. Empty(NJ0->NJ0_LOJCLI)
		lFornNI := Empty(NJ0->NJ0_CODFOR) .or. Empty(NJ0->NJ0_LOJFOR)
	EndIF

	lAutCli := SuperGetMV('MV_AGRO012',,'1') $ '2,3' .And. !IsInCallStack("MATA030") .And. !IsInCallStack("IntegrEnt")
	lAutFor := SuperGetMV('MV_AGRO013',,'1') $ '2,3' .And. !IsInCallStack("MATA020") .And. !IsInCallStack("IntegrEnt")

	oModelO:GetModel("NJ0UNICO"):GetStruct():SetProperty( 'NJ0_CODCLI' , MODEL_FIELD_WHEN, {||(lAlterar .And. !lAutCli) .or. lClieNI} )
	oModelO:GetModel("NJ0UNICO"):GetStruct():SetProperty( 'NJ0_LOJCLI' , MODEL_FIELD_WHEN, {||(lAlterar .And. !lAutCli) .or. lClieNI} )
	oModelO:GetModel("NJ0UNICO"):GetStruct():SetProperty( 'NJ0_CODFOR' , MODEL_FIELD_WHEN, {||(lAlterar .And. !lAutFor) .or. lFornNI} )
	oModelO:GetModel("NJ0UNICO"):GetStruct():SetProperty( 'NJ0_LOJFOR' , MODEL_FIELD_WHEN, {||(lAlterar .And. !lAutFor) .or. lFornNI} )

	IF nOperation == MODEL_OPERATION_INSERT
		oModelo:GetModel( "NN0UNICO" ):SetOnlyQuery(.T.) //<<--Somente Consulta não Grava nada no Modelo, Farei a gravação Via Codigo >>--
	Else
		oModelo:GetModel( "NN0UNICO" ):SetOnlyQuery(.F.) //<<--Somente Consulta não Grava nada no Modelo, Farei a gravação Via Codigo >>--
	EndIF


Return (.t.)


Static Function fVaLojEnt( oField )
	Local oModel		:= oField:GetModel()
	fLoadNN0( oModel )
Return (.t.)

Static Function fLoadNN0 ( oModel )
	Local oView		:= FwViewActive()
	Local oModelNJ0	:= oModel:GetModel( "NJ0UNICO" )
	Local oModelNN0	:= oModel:GetModel( "NN0UNICO" )
	Local cCodent    	:= oModelNJ0:GetValue("NJ0_CODENT")
	Local nI			:=0
	Local nIdx      	:=0
	Local aCposModel 	:= oModelNN0:GetStruct():GetFields()

	oModelNN0:cleardata() // Limpa o Grid
	omodelnn0:InitLine()

	NN0->( dbSetOrder( 1 ) ) //NN0_FILIAL+NN0_CODENT+NN0_ITEM
	NN0->( dbSeek( xFilial( "NN0" ) + cCodEnt ) )
	nI := 0

	While NN0->NN0_FILIAL == xFilial( "NN0" ) .and. NN0->NN0_CODENT == cCodEnt
		nI+=1
		IF nI > 1
			oModelNN0:AddLine()
		EndIF
		oModelNN0:GoLine( nI )

		for nIdx:=1 to len( aCposModel) Step 1
			lRet:= oModelNN0:LoadValue( acposmodel[ nIdx ,3 ] , 	NN0->&( acposmodel[ nIdx ,3 ] ) )
		nExt nIdx

		NN0->(	dbSkip()	)
	EndDo


	oModelNN0:GoLine( 1 )
    If !lAutomato
        If !IsInCallStack("MATA030") .And. !IsInCallStack("MATA020") .And. !IsInCallStack("IntegrEnt") .AND. !IsInCallStack("INCLUDEENTITY")
            If valType(oView) == 'O' .AND. (oView:ACURRENTSELECT[1] == "VIEW_NN0" .OR. oView:ACURRENTSELECT[1] == "VIEW_NJ0")
            	oView:Refresh('VIEW_NN0')
            EndIf
        EndIf   
    EndIf

Return (.t.)

/** {Protheus.doc} fLoadGdNN0
Função para realizar a tratativa de carregamento da grid secundária
@param: 	oModelNN0 - Modelo de dados NN0
@return:	Array com os dados do grid.
@author: 	Equipe Agroindustria
@since: 	27/12/2016
@Uso: 		OGA010
*/
Static Function fLoadGdNN0(oModelNN0, lCopy )
	Local nOperation 	:= oModelNN0:GetModel():GetOperation()
	Local aDadosNN0     := {}
	Local lLoadDados    := .t. //sempre deve carregar os dados, salvo exclusão.
	Local cCodent    	:= oModelNN0:GetModel():GetModel( "NJ0UNICO" ):GetValue("NJ0_CODENT")

	if nOperation == MODEL_OPERATION_DELETE /*Verificar a limpeza do grid secundário*/

		//Busca o registro com a chave primária
		BeginSql Alias 'QryNJ0CTN'
		Select Count( * ) As Total
		From %table:NJ0% NJ0
		Where NJ0.NJ0_FILIAL = %xFilial:NJ0%
		And NJ0.NJ0_CODENT = %exp:cCodEnt%
		And NJ0.%NotDel%
		EndSql

		If QryNJ0CTN->( Total ) > 1
			lLoadDados := .f.	//não carrega os dados cadastrados no BD
		EndIf

		QryNJ0CTN->( dbCloseArea( ) )

	endIf

	if lLoadDados
		aDadosNN0  := FormLoadGrid(oModelNN0) //carga padrão do model
	endIf

return aDadosNN0

/** {Protheus.doc} GrvModelo
Função que grava o modelo de dados após a confirmação

@param: 	oModel - Modelo de dados
@return:	.t. - sempre verdadeiro
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA010
*/
Static Function GrvModelo( oModel )
	Local nOperation 	:= oModel:GetOperation()
	Local oModelNN0	:= oModel:GetModel( "NN0UNICO" )
	Local oModelNJ0	:= oModel:GetModel( "NJ0UNICO" )
	Local aCposModel 	:= oModelNN0:GetStruct():GetFields()
	Local cCodent    	:= oModelNJ0:GetValue("NJ0_CODENT")
	Local nLinha		:= 0
	Local nx			:= 0
	Local nIdx			:= 0
	Local lGrava     	:= .F.
	Local lRetorno		:= .T.
    Local aAreaSA1      := SA1->(GetArea())
    Local aAreaSA2      := SA2->(GetArea())
    Local aAreaNJ0      := nil
    Local cErro         := ""

	Begin Transaction
		If nOperation == MODEL_OPERATION_INSERT


			nLinha := oModelNN0:GetLine()
			For nX := 1 to oModelNN0:Length()
				oModelNN0:GoLine( nX )
				NN0->( dbSetOrder( 1 ) ) //NN0_FILIAL+NN0_CODENT+NN0_ITEM
				lGrava := NN0->( dbSeek( xFilial( "NN0" ) + cCodEnt + oModelNN0:GetValue("NN0_ITEM") ) )

				/*Verifica se deve fazer as alterações  -  se informado os campos de banco*/
				if (!empty(oModelNN0:GetValue("NN0_CODBCO")) .or. !empty(oModelNN0:GetValue("NN0_CODAGE")) .or. !empty(oModelNN0:GetValue("NN0_CODCTA"))) /*Gravação execauto*/ .or. ( oModelNN0:IsDeleted() .and. lGrava) /*delete*/

					RecLock("NN0", !lGrava )

					If oModelNN0:IsDeleted() .and. lGrava  //Foi deletado e existe no Banco Deleto do Banco
						NN0->( DbDelete())
						NN0->(MsUnLock())
						Loop
					EndIF

					for nIdx:=1 to len( aCposModel) Step 1
						NN0->&( acposmodel[ nIdx ,3 ] ) := oModelNN0:GetValue( acposmodel[ nIdx ,3 ] )
					nExt nIdx

					NN0->NN0_CODENT:= cCodEnt  // Abasteço a Entidade separado pq ela foi removida do modelo
                    NN0->NN0_FILIAL:= xFilial("NN0")  // Abasteço a Entidade separado pq ela foi removida do modelo

					NN0->(MsUnLock())
				endif
			nExt nX

			oModelNN0:cleardata() // Limpa o Grid

		EndIF
		//--<< Fim    Tratamento Composição de Preço >>--

		If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
			//PONTO DE ENTRADA
			If (ExistBlock("OG010GRV"))
				lRetorno := ExecBlock("OG010GRV",.F.,.F., {oModel})
			EndIf
		EndIf

		//--GRAVA MODELO
		lRetorno := FWFormCommit( oModel )

        If lRetorno .and. nOperation == MODEL_OPERATION_DELETE
            //MV_AGRO012 - Entidade Automática Cliente  1–Cadastro Independente,2- Efetuar Carga,3 – Integração Cadastros
            //MV_AGRO013 - Entidade Automática Fornecedor  1–Cadastro Independente,2- Efetuar Carga,3 – Integração Cadastros            
            If ( ( SuperGetMV('MV_AGRO013',,'1')  $ '2,3' .And. !Empty(NJ0->NJ0_CODFOR) ) .Or. ;
                ( SuperGetMV('MV_AGRO012',,'1')  $ '2,3' .And. !Empty(NJ0->NJ0_CODCLI) ) ) .And.;
                !IsInCallStack("MATA030") .And. !IsInCallStack("MATA020")
                
                If !Empty(NJ0->NJ0_CODFOR) .and. SuperGetMV('MV_AGRO013',,'1')  $ '2,3'
                    aAreaNJ0 := NJ0->(GetArea())
                    SA2->(dbSetOrder(1))
                    If SA2->(dbSeek(xFilial("SA2") + NJ0->NJ0_CODFOR + NJ0->NJ0_LOJFOR))
                        lRetorno := fDelForCli("MATA020",  @cErro)
                    EndIf
                    RestArea(aAreaNJ0)
                EndIf

                If !Empty(NJ0->NJ0_CODCLI) .and. SuperGetMV('MV_AGRO012',,'1')  $ '2,3'
                    aAreaNJ0 := NJ0->(GetArea())
                    SA1->(dbSetOrder(1))
                    If SA1->(dbSeek(xFilial("SA1") + NJ0->NJ0_CODCLI + NJ0->NJ0_LOJCLI))
                        lRetorno := fDelForCli("MATA030", @cErro)
                    EndIf
                    RestArea(aAreaNJ0)
                EndIf
            EndIf
        EndIf

        If !lRetorno
            If !Empty(cErro)
                oModel:SetErrorMessage( , , oModel:GetId() , "", "", cErro,, "", "")	
            EndIf
            
            DisarmTransaction()
            break
        EndIf

	End Transaction    

    RestArea(aAreaSA1)
    RestArea(aAreaSA2)

Return lRetorno


/** {Protheus.doc} fVldCGCIE
Função que valida os campos de CNJP/CPF + IE, e retorna o cadastro de Fornecedor e Cliente associado.

@param: 	oView - Modelo de dados
@return:	.T. ou .F.
@author: 	Marlon Richard Trettin
@since: 	26/02/2015
@Uso: 		OGA010
*/
Static Function fVldCGCIE( oField )
	Local oModel	:= oField:GetModel()
	Local cCGC		:= oModel:GetValue( "NJ0UNICO", "NJ0_CGC" )
	Local cInscr	:= oModel:GetValue( "NJ0UNICO", "NJ0_INSCR" )
	Local cQuery := ''
	Local cAliasQry := ''
	Local cFiltSA1 	:= ''
	Local cFiltSA2 	:= ''

	If !Empty( cCGC ) .Or. !Empty( cInscr )

		If Empty( cCGC ) .and. AT('ISENT',UPPER(cInscr)) > 0
			If IsInCallStack("IntegrEnt") .AND. IsInCallStack("MATA030")
				cFiltSA1 += " And SA1.A1_COD = '"+ SA1->A1_COD +"' And SA1.A1_LOJA = '"+ SA1->A1_LOJA +"' "
				cFiltSA2 += " And SA2.A2_COD = '"+ SA1->A1_COD +"' And SA2.A2_LOJA = '"+ SA1->A1_LOJA +"' "
			ElseIf IsInCallStack("IntegrEnt") .AND. IsInCallStack("MATA020")
				cFiltSA1 += " And SA1.A1_COD = '"+ SA2->A2_COD +"' And SA1.A1_LOJA = '"+ SA2->A2_LOJA +"' "
				cFiltSA2 += " And SA2.A2_COD = '"+ SA2->A2_COD +"' And SA2.A2_LOJA = '"+ SA2->A2_LOJA +"' "
			Else
				cFiltSA1 += " And SA1.A1_COD = '"+ oModel:GetValue( "NJ0UNICO", "NJ0_CODENT" ) +"' And SA1.A1_LOJA = '"+ oModel:GetValue( "NJ0UNICO", "NJ0_LOJENT" ) +"' "
				cFiltSA2 += " And SA2.A2_COD = '"+ oModel:GetValue( "NJ0UNICO", "NJ0_CODENT" ) +"' And SA2.A2_LOJA = '"+ oModel:GetValue( "NJ0UNICO", "NJ0_LOJENT" ) +"' "
			EndIf
		EndIf

		// Verifica se existe Cliente com CNPJ/CPF + IE informado
		cAliasQry := GetNextAlias()
		cQuery := "SELECT * FROM " + RetSqlName('SA1') + " SA1 "
		cQuery += " Where SA1.A1_FILIAL = '" + xFilial('SA1') + "' "
		cQuery += cFiltSA1
		cQuery += " And SA1.A1_CGC    = '" + cCGC + "' "
		cQuery += " And SA1.A1_INSCR  = '" + cInscr + "' "
		cQuery += " And SA1.A1_MSBLQL <> '1' "
		cQuery += " And D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)

		DbSelectArea( cAliasQry )
		(cAliasQry)->( dbGoTop() )
		If .Not. (cAliasQry)->( Eof() )
			oModel:SetValue("NJ0UNICO", "NJ0_CODCLI", (cAliasQry)->( A1_COD ) )
			oModel:SetValue("NJ0UNICO", "NJ0_LOJCLI", (cAliasQry)->( A1_LOJA ) )
			oModel:SetValue("NJ0UNICO", "NJ0_NOME"  , (cAliasQry)->( A1_NOME ) )
			oModel:SetValue("NJ0UNICO", "NJ0_NOMLOJ", (cAliasQry)->( A1_NREDUZ ) )
		Else
			If !IsInCallStack("MATA030") .And. !IsInCallStack("MATA020") .And. !IsInCallStack("IntegrEnt")
				If .Not. MsgYesNo(IIf(cPaisLoc = "PAR",STR0033,STR0019) + cCGC + " + " + cInscr + chr(13) + STR0029, STR0001) //'HELP'###"Cliente associado ao CNPJ/CPF + Inscrição Estadual não localizado no cadastro de Cliente (SA1): Deseja continuar?"
					(cAliasQry)->( dbCloseArea( ) )
					Return( .F. )
				EndIf
			EndIF
		EndIf
		(cAliasQry)->( dbCloseArea( ) )

		// Verifica se existe Fornecedor com CNPJ/CPF + IE informado
		cAliasQry := GetNextAlias()
		cQuery := "SELECT * FROM " + RetSqlName('SA2') + " SA2 "
		cQuery += " Where SA2.A2_FILIAL = '" + xFilial('SA2') + "' "
		cQuery += cFiltSA2
		cQuery += " And SA2.A2_CGC    = '" + cCGC + "' "
		cQuery += " And SA2.A2_INSCR  = '" + cInscr + "' "
		cQuery += " And SA2.A2_MSBLQL <> '1' "
		cQuery += " And SA2.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)

		DbSelectArea( cAliasQry )
		( cAliasQry )->( dbGoTop() )
		If .Not. ( cAliasQry )->( Eof() )
			oModel:SetValue("NJ0UNICO", "NJ0_CODFOR", ( cAliasQry )->( A2_COD ) )
			oModel:SetValue("NJ0UNICO", "NJ0_LOJFOR", ( cAliasQry )->( A2_LOJA ) )
			oModel:SetValue("NJ0UNICO", "NJ0_NOME"  , ( cAliasQry )->( A2_NOME ) )
			oModel:SetValue("NJ0UNICO", "NJ0_NOMLOJ", ( cAliasQry )->( A2_NREDUZ ) )
		Else
			If !IsInCallStack("MATA030") .And. !IsInCallStack("MATA020") .And. !IsInCallStack("IntegrEnt")
				If .Not. MsgYesNo(IIf(cPaisLoc = "PAR",STR0034,STR0020) + cCGC + " + " + cInscr + chr(13) + STR0029,STR0001) //'HELP'###"Fornecedor associado ao CNPJ/CPF + Inscrição Estadual não localizado no cadastro de Fornecedor (SA2): Deseja continuar?"
					( cAliasQry )->( dbCloseArea( ) )
					Return( .F. )
				EndIf
			EndIF
		EndIf
		( cAliasQry )->( dbCloseArea( ) )
	EndIf
Return .T.


/*/{Protheus.doc} OGA010PROD
//Acerto de base inclui os produtores (DX8) na tabela de entidades (NJ0)
@author marina.muller
@since 22/12/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OGA010PROD()
	Local aArea     := GetArea()
	Local oDlg	    := Nil
	Local oFwLayer  := Nil	
	Local oPnDown   := Nil
	Local oSize     := Nil	
	Local oBrwMrk := Nil

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )
	oSize:lLateral	:= .F.  // Calculo vertical
	oSize:Process() //executa os calculos

	oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4],;
	STR0036 , , , , , CLR_BLACK, CLR_WHITE, , , .t. )

	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlg, .f., .t. )

	oFWLayer:AddLine( 'UP', 10, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
	oPnTOP := oFWLayer:GetColPanel( 'ALL', 'UP' )

	oFWLayer:AddLine( 'DOWN', 90, .F. )
	oFWLayer:AddCollumn( 'ALL' , 100, .T., 'DOWN' )
	oPnDown := oFWLayer:GetColPanel( 'ALL', 'DOWN' )

	oBrwMrk:=FWMarkBrowse():NEW()   // Cria o objeto oMark - MarkBrowse
	oBrwMrk:SetDescription(STR0036) // Define o titulo do MarkBrowse
	oBrwMrk:SetFilterDefault("@"+FiltraMark())
	oBrwMrk:SetAlias("DX8")
	oBrwMrk:SetFieldMark("DX8_OK")	// Define o campo utilizado para a marcacao
	oBrwMrk:SetUseFilter(.F.)	//Desabilita uso do filtro
	oBrwMrk:SetSemaphore(.F.)	// Define se utiliza marcacao exclusiva
	oBrwMrk:DisableConfig()	// Desabilita a opcao de configuracao do MarkBrowse
	oBrwMrk:DisableDetails()	// Desabilita a exibicao dos detalhes do MarkBrowse
	oBrwMrk:DisableReport()	// Desabilita a opcao de imprimir
	oBrwMrk:SetMenuDef("")	// Desabilita a opcao de imprimir
	oBrwMrk:Activate(oPnDown)	// Ativa o MarkBrowse
	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar(oDlg,{|| IIf(MsgRun(STR0037,STR0038,;
	{|| GeraProdut( oBrwMrk )}), oDlg:End(), NIL)},{||oDlg:End()},,) } )

	RestArea(aArea)
Return .T.


/*/{Protheus.doc} FiltraMark
//Filtro para trazer apenas os registros que existam na DX8 e NÃO existam na NJ0
@author marina.muller
@since 27/12/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function FiltraMark()
	Local cQuery := ""

	cQuery :=  "NOT EXISTS ( "+;
	"SELECT NJ0_CODENT "+;
	"FROM "+RetSqlName('NJ0')+" NJ0 "+;
	"WHERE "+;
	"NJ0.D_E_L_E_T_ = ' ' AND "+;
	"NJ0.NJ0_FILIAL = '"+ FwxFilial("NJ0")+"' AND "+;
	"NJ0.NJ0_CODENT  = DX8_CODIGO AND  "+;
	"NJ0.NJ0_LOJENT  = DX8_LOJA )"

Return cQuery


/*/{Protheus.doc} GeraProdut
//Acerto de base inclui os produtores (DX8) na tabela de entidades (NJ0)
@author marina.muller
@since 22/12/2017
@version 1.0
@return ${return}, ${return_description}
@param oBrwMrk, object, descricao
@type function
/*/
Static Function GeraProdut(oBrwMrk)
	Local lRet   := .T.	

	//Inicia transação
	Begin Transaction

		//Posiciona no topo da lista
		DX8->(dbGoTop())
		While DX8->( !Eof() )

			//Verifica se produtor foi selecionado
			If oBrwMrk:IsMark()

				//Verifica se já existe produtor
				dbSelectArea('NJ0')
				dbSetOrder(1)
				If !dbSeek(FwxFilial('NJ0')+DX8->DX8_CODIGO+DX8->DX8_LOJA)

					//Trava registro e cria entidade
					If RecLock('NJ0', .T.)
						NJ0->NJ0_FILIAL := FwxFilial('NJ0')
						NJ0->NJ0_CODENT := DX8->DX8_CODIGO
						NJ0->NJ0_LOJENT := DX8->DX8_LOJA
						NJ0->NJ0_NOME   := DX8->DX8_NOME
						NJ0->NJ0_NOMLOJ := DX8->DX8_NMREDU
						NJ0->NJ0_CGC    := DX8->DX8_CGC
						NJ0->NJ0_INSCR  := DX8->DX8_INSCR
						NJ0->NJ0_CODFOR := DX8->DX8_FORNEC
						NJ0->NJ0_LOJFOR := DX8->DX8_LJFOR
						NJ0->NJ0_CODCLI := DX8->DX8_CLIENT
						NJ0->NJ0_LOJCLI := DX8->DX8_LJCLI
						NJ0->NJ0_ATIVO  := DX8->DX8_ATIVO
						NJ0->NJ0_CLASSE := "1"
						MsUnlock()
					Endif
				Endif
			Endif
			DX8->(dbSkip())
		EndDo
		NJ0->(dbCloseArea())
	End Transaction

	oBrwMrk:Refresh()
Return lRet

/*/{Protheus.doc} OGA010WHEN
//Função When chamada pelo dicionário de dados
//Não habilita os campos quando há integração automática com cliente e/ou fornecedor e estes estão informados
@author tamyris.ganzenmueller
@since 07/02/2017
@version 1.0
@return lRet [L] - T/F
@param
@type function
/*/
Function OGA010WHEN()
	Local lRet := .T.

	//MV_AGRO012 - Entidade Automática Cliente  1–Cadastro Independente,2- Efetuar Carga,3 – Integração Cadastros
	//MV_AGRO013 - Entidade Automática Fornecedor  1–Cadastro Independente,2- Efetuar Carga,3 – Integração Cadastros
	If !Inclui .And. !IsInCallStack("MATA020") .And. !IsInCallStack("MATA030") .And. !IsInCallStack("IntegrEnt") .And. ;
	( ( SuperGetMV('MV_AGRO013',,'1')  $ '2,3' .And. !Empty(NJ0->NJ0_CODFOR) ) .Or. ;
	  ( SuperGetMV('MV_AGRO012',,'1')  $ '2,3' .And. !Empty(NJ0->NJ0_CODCLI) ) )
	  lRet := .F.
  EndIf

Return lRet

/*/{Protheus.doc} OGA010InFo (M030Inc)
//Ponto de Integração - Inclusão cliente chamado a partir do MATA030
@author tamyris.ganzenmueller
@since 08/02/2017
/*/
Function OGA010InFo()
	If SuperGetMV('MV_AGRO012',,'1')  $ '2,3'
		IntegrEnt("SA1",MODEL_OPERATION_INSERT)
	EndIF
Return .t.

/*/{Protheus.doc} OGA010AlFo (MALTCLI)
//Ponto de Integração - Alteração cliente chamado a partir do MATA030
@author tamyris.ganzenmueller
@since 08/02/2017
/*/
Function OGA010AlFo()
	If SuperGetMV('MV_AGRO012',,'1')  $ '2,3'
		IntegrEnt("SA1",MODEL_OPERATION_UPDATE)
	EndIF
Return .t.

/*/{Protheus.doc} OGA010VaFo (M030DEL)
//Ponto de Integração - Validação da Exclusão cliente chamado a partir do MATA030
@author tamyris.ganzenmueller
@since 08/02/2017
/*/
Function OGA010VaFo()
	Local lRet := .T.
	Local lExt := Empty(SA1->A1_CGC) .And. SA1->A1_PAIS <> '105'

	If SuperGetMV('MV_AGRO012',,'1')  $ '2,3'
		cquery:=''
		cquery += " SELECT COUNT(NJR.R_E_C_N_O_) AS NR_CTRATOS FROM " + RetSqlName('NJR')+ " NJR "

		cQuery += " INNER JOIN " + RetSqlName("NJ0") + " NJ0 "
		cQuery += "   ON NJ0.NJ0_FILIAL = '" + xFilial('NJ0') + "'"
		If lExt
			cQuery += "  AND NJ0.NJ0_CODCLI = '" + SA1->A1_COD + "' "
			cQuery += "  AND NJ0.NJ0_LOJCLI = '" + SA1->A1_LOJA + "' "
		Else
			cQuery += "  AND NJ0.NJ0_CGC =   '" + SA1->A1_CGC + "' "
		EndIF
		cQuery += "  AND NJ0.D_E_L_E_T_ = ' ' "

		cQuery += " WHERE NJR.D_E_L_E_T_ = ' ' "
		cQuery+=  " AND NJR.NJR_CODENT = NJ0.NJ0_CODENT "
		cQuery+=  " AND NJR.NJR_LOJENT = NJ0.NJ0_LOJENT "
		cquery+=  " AND NJR_FILIAL = '" + xFilial('NJR') + "'"
		cQuery+=  " AND NJR_STATUS IN( 'A' , 'I')"  //Ctrato Aberto / iniciado


		cQuery:= ChangeQuery(cQuery)

		If select("QryNJR") <> 0
			QryNJR->( dbCloseArea() )
		endif

		TCQUERY cQuery NEW ALIAS "QryNJR"

		QryNJR->( DbGotop() )

		lRet:=iIf(QryNJR->NR_CTRATOS > 0 , .f. ,.t.) //SeExistem ctratos iniciados ou abertos n. pode excluir
		QryNJR->( dbCloseArea() )
	EndIf

	If !lRet
		Help(, , STR0016, , STR0042, 1, 0 ) //"Ajuda"###"Entidade relacionada ao cliente possui Contrato aberto ou iniciado
	EndIf

Return lRet

/*/{Protheus.doc} OGA010ExFo (M030EXC)
//Ponto de Integração - Exclusão cliente chamado a partir do MATA030
@author tamyris.ganzenmueller
@since 08/02/2017
/*/
Function OGA010ExFo()
	If SuperGetMV('MV_AGRO012',,'1')  $ '2,3'
		IntegrEnt("SA1",MODEL_OPERATION_DELETE)
	EndIF
Return .t.

/*/{Protheus.doc} OGA010InCl (M020INC)
//Ponto de Integração - Inclusão Fornecedor chamado a partir do MATA020
@author tamyris.ganzenmueller
@since 08/02/2017
/*/
Function OGA010InCl()
	If SuperGetMV('MV_AGRO013',,'1')  $ '2,3'
		IntegrEnt("SA2",MODEL_OPERATION_INSERT)
	EndIF
Return .t.

/*/{Protheus.doc} OGA010AlCl (M020ALT)
//Ponto de Integração - Alteração Fornecedor chamado a partir do MATA020
@author tamyris.ganzenmueller
@since 08/02/2017
/*/
Function OGA010AlCl()
	If SuperGetMV('MV_AGRO013',,'1')  $ '2,3'
		IntegrEnt("SA2",MODEL_OPERATION_UPDATE)
	EndIF
Return .t.

/*/{Protheus.doc} OGA010VaCl (A020DELE)
//Ponto de Integração - Validação Exclusão Fornecedor chamado a partir do MATA020
@author tamyris.ganzenmueller
@since 08/02/2017
/*/
Function OGA010VaCl()
	Local lRet := .T.
	Local lExt := Empty(SA2->A2_CGC) .And. SA2->A2_PAIS <> '105'

	If SuperGetMV('MV_AGRO013',,'1')  $ '2,3'
		cquery:=''
		cquery += " SELECT COUNT(NJR.R_E_C_N_O_) AS NR_CTRATOS FROM " + RetSqlName('NJR')+ " NJR "

		cQuery += " INNER JOIN " + RetSqlName("NJ0") + " NJ0 "
		cQuery += "   ON NJ0.NJ0_FILIAL = '" + xFilial('NJ0') + "'"
		If lExt
			cQuery += "  AND NJ0.NJ0_CODCLI = '" + SA2->A2_COD + "' "
			cQuery += "  AND NJ0.NJ0_LOJCLI = '" + SA2->A2_LOJA + "' "
		Else
			cQuery += "  AND NJ0.NJ0_CGC =   '" + SA2->A2_CGC + "' "
		EndIF
		cQuery += "  AND NJ0.D_E_L_E_T_ = ' ' "

		cQuery += " WHERE NJR.D_E_L_E_T_ = ' ' "
		cQuery+=  " AND NJR.NJR_CODENT = NJ0.NJ0_CODENT "
		cQuery+=  " AND NJR.NJR_LOJENT = NJ0.NJ0_LOJENT "
		cquery+=  " AND NJR_FILIAL = '" + xFilial('NJR') + "'"
		cQuery+=  " AND NJR_STATUS IN( 'A' , 'I')"  //Ctrato Aberto / iniciado


		cQuery:= ChangeQuery(cQuery)

		If select("QryNJR") <> 0
			QryNJR->( dbCloseArea() )
		endif

		TCQUERY cQuery NEW ALIAS "QryNJR"

		QryNJR->( DbGotop() )

		lRet:=iIf(QryNJR->NR_CTRATOS > 0 , .f. ,.t.) //SeExistem ctratos iniciados ou abertos n. pode excluir
		QryNJR->( dbCloseArea() )
	EndIf

	If !lRet
		Help(, , STR0016, , STR0041, 1, 0 ) //"Ajuda"###"Entidade relacionada ao fornecedor possui Contrato aberto ou iniciado"
	EndIf

Return lRet

/*/{Protheus.doc} OGA010ExCl (M020EXC)
//Ponto de Integração - Exclusão Fornecedor chamado a partir do MATA020
@author tamyris.ganzenmueller
@since 08/02/2017
/*/
Function OGA010ExCl()
	If SuperGetMV('MV_AGRO013',,'1')  $ '2,3'
		IntegrEnt("SA2",MODEL_OPERATION_DELETE)
	EndIF
Return .t.

/*/{Protheus.doc} IntegrEnt
//Criação automática da Entidade a partir do Cadastro de Cliente / Fornecedor
@author tamyris.ganzenmueller
@since 08/02/2017
@version 1.0
@return lRet [L] - T/F
@param
@type function
/*/
Static Function IntegrEnt(cAli,nOpcao)
	Local aArea   := GetArea()
	Local aAreaSA := If(cAli = "SA1", SA1->(GetArea()), SA2->(GetArea()))
	Local oModelAct := FwModelActive()
	Local oMdlNJ0 := Nil
	Local oNJ0    := Nil
	Local cCgc    := IIf(cAli=="SA1",SA1->A1_CGC,SA2->A2_CGC)
	Local cCodSA  := IIf(cAli=="SA1",SA1->A1_COD,SA2->A2_COD)
	Local cLojaSA := IIf(cAli=="SA1",SA1->A1_LOJA,SA2->A2_LOJA)
	Local cPais   := IIf(cAli=="SA1",SA1->A1_PAIS,SA2->A2_PAIS)
	Local cNome   := IIf(cAli=="SA1",SA1->A1_NOME,SA2->A2_NOME)
	Local cInscr  := IIf(cAli=="SA1",SA1->A1_INSCR,SA2->A2_INSCR)
	Local cNomeFtsia := IIf(cAli=="SA1",SA1->A1_NREDUZ,SA2->A2_NREDUZ)
	Local lExt  := .F.
	Local cCodEnt := ''
	Local cLojEnt := ''
	Local lAlterar := .T.	
	Local nIdx := 0	
	Local aFldNN0 := {}
	LOCAL aAreaAnt
	Local aErro:= {}
	
	If lAutomato .and. IsInCallStack("OGA010EAUT") .AND.  ( (cAli == "SA1" .and. A1_MSBLQL=='1') .OR. (cAli == "SA2" .and. A2_MSBLQL=='1') )
		Return .T. //sai para não quebrar cenario automação devido help em tela cliente/fornecedor estar bloqueado - MV_AGRO012/13 = 2 - carga inicial
	EndIf

	If Empty(cNomeFtsia)
		cNomeFtsia := SubStr(cNome,1,TamSX3(IIf(cAli=="SA1",'A1_NREDUZ','A2_NREDUZ'))[1])
	EndIf

	If Empty(cCgc)
		If cPais = '105' .Or. Empty(cPais)
			Return .F.
		Else
			lExt := .T.
		EndIF
	EndIf

	If cAli = "SA2"
		aAdd(aFldNN0, {'NN0_FILIAL', SA2->A2_FILIAL})
		aAdd(aFldNN0, {'NN0_ITEM'  , StrZero(1,2)})
		aAdd(aFldNN0, {'NN0_CODBCO', SA2->A2_BANCO  })
		aAdd(aFldNN0, {'NN0_CODAGE', SA2->A2_AGENCIA})
		aAdd(aFldNN0, {'NN0_DVAGE' , SA2->A2_DVAGE  })
		aAdd(aFldNN0, {'NN0_CODCTA', SA2->A2_NUMCON })
		aAdd(aFldNN0, {'NN0_DVCTA' , SUBSTR(AllTrim(SA2->A2_DVCTA), 1, TamSX3('NN0_DVCTA')[1]) })
	EndIF

	cAliasNJ0 := GetNextAlias()
	cQry := " SELECT NJ0_CODENT, NJ0_LOJENT "
	cQry += " FROM " + RetSqlName("NJ0") + " NJ0 "
	cQry += " WHERE NJ0_FILIAL = '" + xFilial("NJ0") + "' "
	If !lExt
		cQry += " AND NJ0_CGC =   '" + cCgc + "' "
	Else
		If cAli=="SA1"
			cQry += " AND NJ0_CODCLI = '" + cCodSA + "' "
			cQry += " AND NJ0_LOJCLI = '" + cLojaSA + "' "
		Else
			cQry += " AND NJ0_CODFOR = '" + cCodSA + "' "
			cQry += " AND NJ0_LOJFOR = '" + cLojaSA + "' "
		EndIF
	EndIF
	cQry += " AND NJ0.D_E_L_E_T_ = ' ' "
	cQry := ChangeQuery(cQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasNJ0, .F., .T.)

	DbselectArea( cAliasNJ0 )
	(cAliasNJ0)->(DbGoTop())
	While (cAliasNJ0)->( !Eof() )
		cCodEnt := (cAliasNJ0)->NJ0_CODENT
		cLojEnt := cLojaSA
		(cAliasNJ0)->(DbSkip())
	EndDo
	(cAliasNJ0)->(DbCloseArea())

	//Posiciona tabela NJ0
	dbSelectArea('NJ0')
	NJ0->(dbSetOrder(1))	//Filial + CODENT + LOJENT
	If NJ0->(dbSeek(FWxFilial('NJ0') + cCodEnt + cLojEnt)) .And. !Empty(cCodEnt)
		If nOpcao <> MODEL_OPERATION_DELETE
			nOpcao := MODEL_OPERATION_UPDATE

			cquery := " SELECT COUNT(NJR.R_E_C_N_O_) AS NR_CTRATOS FROM " + RetSqlName('NJR')+ " NJR "
			cQuery += " WHERE NJR.D_E_L_E_T_ = ' ' "
			cQuery+=  " AND NJR.NJR_CODENT = '" + cCodEnt + "'"
			cQuery+=  " AND NJR.NJR_LOJENT = '" + cLojEnt + "'"
			cquery+=  " AND NJR_FILIAL = '" + xFilial('NJR') + "'"
			cQuery+=  " AND NJR_STATUS IN( 'A' , 'I')"  //Ctrato Aberto / iniciado
			cQuery:= ChangeQuery(cQuery)
			If select("QryNJR") <> 0
				QryNJR->( dbCloseArea() )
			endif
			TCQUERY cQuery NEW ALIAS "QryNJR"
			QryNJR->( DbGotop() )
			lAlterar:=iIf(QryNJR->NR_CTRATOS > 0 , .f. ,.t.) //SeExistem ctratos iniciados ou abertos n. pode alterar forn.cliente.
			QryNJR->( dbCloseArea() )
		Else
			//Se exclusão de cliente e registro possui fornecedor relacionado ou vice-versa, não realiza a exclusão, apenas limpa os campos
			If ( cAli=="SA1" .And. !Empty(NJ0->NJ0_CODFOR) ) .Or. ;
			   ( cAli=="SA2" .And. !Empty(NJ0->NJ0_CODCLI) )

			   If RecLock( "NJ0", .f. )
				   If cAli=="SA1"
				   		NJ0->NJ0_CODCLI := ''
				   		NJ0->NJ0_LOJCLI := ''
					Else
						NJ0->NJ0_CODFOR := ''
				   		NJ0->NJ0_LOJFOR := ''
					EndIf
				NJ0->( MsUnLock() )
				EndIf
				lAlterar := .F.
		    EndIf
		EndIf
	Else
		If nOpcao <> MODEL_OPERATION_DELETE
			nOpcao := MODEL_OPERATION_INSERT
			cLojEnt := cLojaSA

			dbSelectArea('NJ0')
			NJ0->(dbSetOrder(1))	//Filial + CODENT + LOJENT
			If !(NJ0->(dbSeek(FWxFilial('NJ0') + cCodSA + cLojaSA)))
				cCodEnt := cCodSA
			Else
				lRaiz := IIf(lExt,"ENX","ENT")
				cCodEnt := PADR( lRaiz, TamSX3('NJ0_CODENT')[1],'0')

				cAliasNJ0 := GetNextAlias()
				cQry := " SELECT NJ0_CODENT from " + RetSqlName('NJ0')+ " NJ0 "
				cQry += " WHERE NJ0_CODENT = (SELECT MAX(NJ0_CODENT) from " + RetSqlName('NJ0')+ " NJ0A WHERE NJ0A.NJ0_CODENT LIKE '" + lRaiz + "%' AND NJ0A.D_E_L_E_T_ = ' ') "
				cQry := ChangeQuery(cQry)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasNJ0, .F., .T.)
				DbselectArea( cAliasNJ0 )
				(cAliasNJ0)->(DbGoTop())
				While (cAliasNJ0)->( !Eof() )
					cCodEnt := (cAliasNJ0)->NJ0_CODENT
					(cAliasNJ0)->(DbSkip())
				EndDo
				(cAliasNJ0)->(DbCloseArea())

				cCodEnt := Soma1(cCodEnt,1)
			EndIf
		Else
			Return .F. //Não encontrou registro para eliminar
		EndIf
	EndIF

	If lAlterar
		aAreaAnt := GETAREA()
		oMdlNJ0 := FWLoadModel( "OGA010" )
		oMdlNJ0:SetOperation( nOpcao )
		oMdlNJ0:Activate()
		oNJ0:= oMdlNJ0:GetModel( "NJ0UNICO" )

		If nOpcao == MODEL_OPERATION_INSERT
			oNJ0:SetValue( "NJ0_FILIAL" , fwXfilial("NJ0") )
			oNJ0:SetValue( "NJ0_CGC"    , cCgc)
		EndIF

		If nOpcao <> MODEL_OPERATION_DELETE
			oNJ0:SetValue( "NJ0_CODENT" , cCodEnt)
			oNJ0:SetValue( "NJ0_LOJENT" , cLojEnt)
			oNJ0:SetValue( "NJ0_NOME"   , cNome  )
			oNJ0:SetValue( "NJ0_NOMLOJ" , cNomeFtsia )
			oNJ0:SetValue( "NJ0_INSCR"  , cInscr)

			If cAli=="SA1"
				oNJ0:SetValue( "NJ0_CODCLI" , cCodSA )
				oNJ0:SetValue( "NJ0_LOJCLI" , cLojaSA)
			Else
				oNJ0:SetValue( "NJ0_CODFOR" , cCodSA )
				oNJ0:SetValue( "NJ0_LOJFOR" , cLojaSA)
			EndIf
		EndIf

		/*Dados Bancários*/
		dbSelectArea('NN0')
		NN0->( dbSetOrder( 1 ) ) //NN0_FILIAL+NN0_CODENT+NN0_ITEM
		lGrava := NN0->( dbSeek( xFilial( "NN0" ) + cCodEnt + StrZero(1,2) ) )

		If ( oMdlNJ0:VldData() )
			oMdlNJ0:CommitData()

			/*Dados Bancários - Verifica se deve fazer as alterações  -  se informado os campos de banco*/
			if  cAli='SA2' .And.( (!empty(aFldNN0[3,2]) .or. !empty(aFldNN0[4,2]) .or. !empty(aFldNN0[6,2]))  .or. ( nOpcao == MODEL_OPERATION_DELETE .and. lGrava ) ) /*delete*/

				oMdlNN0    := oMdlNJ0:GetModel( "NN0UNICO" )
				aCposModel := oMdlNN0:GetStruct():GetFields()

				oMdlNN0:GoLine( 1 )

				RecLock("NN0", !lGrava )

				If nOpcao == MODEL_OPERATION_DELETE .and. lGrava  //Foi deletado e existe no Banco Deleto do Banco
					NN0->( DbDelete())
				Else
					If nOpcao <> MODEL_OPERATION_DELETE
						if !Empty(aFldNN0)
							for nIdx:=1 to len( aCposModel) Step 1

								nPos := aScan( aFldNN0, { |x| AllTrim( x[1] ) == acposmodel[ nIdx ,3 ] } )
								if nPos > 0
									NN0->&( acposmodel[ nIdx ,3 ] ) :=  aFldNN0[nPos,2]
								EndIf
							nExt nIdx

							NN0->NN0_CODENT:= cCodEnt  // Abasteço a Entidade separado pq ela foi removida do modelo
						EndIF
					EndIF
				EndIf
				NN0->(MsUnLock())
			endif

		Else

			aErro := oMdlNJ0:GetErrorMessage()
			// A estrutura do vetor com erro é:
			// [1] identificador (ID) do formulário de origem
			// [2] identificador (ID) do campo de origem
			// [3] identificador (ID) do formulário de erro
			// [4] identificador (ID) do campo de erro
			// [5] identificador (ID) do erro
			// [6] mensagem do erro
			// [7] mensagem da solução
			// [8] Valor atribuído
			// [9] Valor anterior
			 cMsg := IIF(cAli=='SA2',STR0046, STR0047) + STR0048          + ' [' + cCodEnt + ']' + CRLF	//"Fornecedor" / "CLiente" /" com Erro: "
			 cMsg += STR0049 + ' [' + AllToChar( aErro[1] ) + ']' + CRLF		//"Id do formulário de origem: "
			 cMsg += STR0050 + ' [' + AllToChar( aErro[2] ) + ']' + CRLF		//"Id do campo de origem.....: "
			 cMsg += STR0051 + ' [' + AllToChar( aErro[3] ) + ']' + CRLF		//"Id do formulário de erro..: "
			 cMsg += STR0052 + ' [' + AllToChar( aErro[4] ) + ']' + CRLF		//"Id do campo de erro.......: "
			 cMsg += STR0053 + ' [' + AllToChar( aErro[5] ) + ']' + CRLF		//"Id do erro................: "
			 cMsg += STR0054 + ' [' + AllToChar( aErro[6] ) + ']' + CRLF		//"Mensagem do erro..........: "
			 cMsg += STR0055 + ' [' + AllToChar( aErro[7] ) + ']' + CRLF		//"Mensagem da solução.......: "

			//cMsg := oMdlNJ0:GetErrorMessage()[3] + oMdlNJ0:GetErrorMessage()[6]
			Help( ,,STR0016,,cMsg, 1, 0 ) //"Ajuda"
		EndIf
		oMdlNJ0:DeActivate()
		oMdlNJ0:Destroy()
		oMdlNJ0 := Nil
		RESTAREA( aAreaAnt )
	EndIF

	FwModelActive(oModelAct)
	RestArea(aAreaSA)
	RestArea(aArea)

Return .T.

/*{Protheus.doc} OGA010EAUT
//Função criada para fazer carga automática do cliente e fornecedor na Entidade
@author tamyris.ganzenmueller
@since 08/02/2018
@version 1.0
@return lRet [L] - T/F
@param
@type function
*/

Function OGA010EAUT(lAut)
	Local lRet := .T.
    Local lRetMsg := .T.	
	Local aAreaAnt := {}
    Local cFilBkp  := cFilAnt

	If !lAutomato
        lRetMsg := MsgYesNo(STR0043) //"Deseja realizar a carga automática de dados de Clientes/Fornecedores?"
    Else
        lRetMsg := .t.
    EndIf

    If lRetMsg

		//Integração Clientes
		If (lAut  .And. SuperGetMV('MV_AGRO012',,'1')  == '2' ) .Or.;
		   (!lAut .And. SuperGetMV('MV_AGRO012',,'1')  $ '2,3' )

			dbSelectArea('SA1')
			dbSetOrder(1)
			dbGotop()
			While  SA1->(!Eof())
				aAreaAnt := SA1->(GETAREA())
                If cFilAnt  != SA1->A1_FILIAL
                    cFilAnt  := SA1->A1_FILIAL
                EndIf

				If !lAutomato
                    MsAguarde({|| IntegrEnt("SA1",MODEL_OPERATION_INSERT)},STR0044,STR0045 + ": " + SA1->A1_COD )
                Else
                    IntegrEnt("SA1",MODEL_OPERATION_INSERT)                    
                EndIf

				RESTAREA( aAreaAnt )
				SA1->(dbSkip())
			EndDo

			If lAut
				PutMv("MV_AGRO012",'3')
			EndIF
		EndIf

		If (lAut  .And. SuperGetMV('MV_AGRO013',,'1')  == '2' ) .Or.;
		   (!lAut .And. SuperGetMV('MV_AGRO013',,'1')  $ '2,3' )
			dbSelectArea('SA2')
			dbSetOrder(1)
			dbGotop()

			While  SA2->(!Eof())
				aAreaAnt := SA2->(GETAREA())
                If cFilAnt  != SA2->A2_FILIAL
                    cFilAnt  := SA2->A2_FILIAL
                EndIf

				If !lAutomato
                    MsAguarde({|| IntegrEnt("SA2",MODEL_OPERATION_INSERT)},STR0044,STR0045 + ": " + SA2->A2_COD)
                Else
                    IntegrEnt("SA2",MODEL_OPERATION_INSERT)
                EndIf
				RESTAREA( aAreaAnt )
				SA2->(dbSkip())
			EndDo

			If lAut
				PutMv("MV_AGRO013",'3') //AO FINAL DA CARGA INICIAL AJUSTA PARAMETRO 
			EndIF
		EndIf
	EndIf

    cFilAnt := cFilBkp

Return lRet


/*/{Protheus.doc} IntegDef
//Adapter Entidade
@author carlos.augusto
@since 16/06/2018
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
	Local aRet := {}

	if ExistFunc("OGI010")
		aRet:= OGI010( cXml, nTypeTrans, cTypeMessage )
	endIf

Return aRet

/*/{Protheus.doc} fDelForCli
    Função para excluir o fornecedor e cliente 
    @type  Static Function
    @author user
    @since 01/10/2020
    @version version
    @param cRotina, char, Código da Rotina (MATA020 ou MATA030)
    @return cErro, char, Variável passada como referência para registrar o erro do modelo    
    /*/
Static Function fDelForCli(cRotina, cErro)
    
    Local oModel    := FWLoadModel(cRotina)
    Local lRet      := .T.    
    
    oModel:SetOperation(5)
    
    oModel:Activate()
    
    If oModel:VldData()
        oModel:CommitData()
    Else
        cErro := oModel:GetErrorMessage()[6]
        lRet  := .F.
    EndIf
    
    oModel:DeActivate()    
    oModel:Destroy()
Return lRet
