#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"
#Include "TOPCONN.CH"
#Include "OGAA760.ch"

/** {Protheus.doc} OGAA760
Rotina para alteração e consulta de Processos de Aprovação

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	19/12/2017
@Uso: 		SIGAAGR - Originação de Grãos
@Autor:     Felipe Rafael Mendes
*/
Function OGAA760()
	Local oMBrowse	:= Nil

	//Proteç?o
	If !TableInDic('N98')
		Help( , , STR0009, , STR0010, 1, 0 ) //"Ajuda" //"Para acessar esta funcionalidade é necessario atualizar o dicionario do Protheus."
		Return(Nil)
	EndIf 

	OGA710LoadN98() //carrega a tabela com os dados da SX5 

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "N98" )
	oMBrowse:SetDescription( STR0001 ) //"Processos de Aprovação"
	oMBrowse:Activate()
Return( )

/** {Protheus.doc} MenuDef

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@since: 	19/12/2017
@Uso: 		SIGAAGR - Originação de Grãos
@Autor:     Felipe Rafael Mendes
*/
Static Function MenuDef()
	Local aRotina	:= {}

	aAdd( aRotina, { STR0002	, "PesqBrw"			, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003	, "ViewDef.OGAA760"	, 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0004	, "ViewDef.OGAA760"	, 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0005	, "ViewDef.OGAA760"	, 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0006	, "ViewDef.OGAA760"	, 0, 9, 0, Nil } ) //"Copiar"	
Return( aRotina )

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindustria
@since: 	19/12/2017
*/
Static Function ModelDef()
	Local oStruN98	:= FWFormStruct( 1, "N98" )
	Local oStruN99	:= FWFormStruct( 1, "N99" )	
	Local oModel

	oStruN99:SetProperty( "N99_CODUSU"  , MODEL_FIELD_WHEN  , {||OGA760WHEN('N99_CODUSU', oModel)} )
	oStruN99:SetProperty( "N99_GRPUSU"  , MODEL_FIELD_WHEN  , {||OGA760WHEN('N99_GRPUSU', oModel)} )
	
	oStruN99:SetProperty( "N99_COPROD"  , MODEL_FIELD_WHEN  , {||OGA760WHEN('N99_COPROD', oModel)} )
	oStruN99:SetProperty( "N99_GRPROD"  , MODEL_FIELD_WHEN  , {||OGA760WHEN('N99_GRPROD', oModel)} )

	oStruN99:SetProperty( "N99_GRPUSU"  , MODEL_FIELD_VALID , {||OGA760ValGr( oModel )} )
	
	oStruN99:AddTrigger( "N99_CODUSU", "N99_NOMUSU", { || .t. }, { | x | fTrgNomUsu( x ) } )
	oStruN99:AddTrigger( "N99_GRPUSU", "N99_DGRUSU", { || .t. }, { | x | fTrgNomGrp( x ) } )
	
	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New( "OGAA760", , {||OGA760VALD(oModel)} , /*bCOmmit*/ , /*bCancel*/  )

	oModel:SetDescription( STR0007 ) //"Processos de Aprovação"
	oModel:AddFields( "N98UNICO", Nil, oStruN98 )
  //MPFORMMODEL():AddGrid(< cId >, < cOwner >, < oModelStruct >, < bLinePre >, < bLinePost >, < bPre >, < bLinePost >, < bLoad >)-> NIL
	oModel:AddGrid( "N99UNICO", "N98UNICO", oStruN99           ,             ,                                  ,         ,  ,  )
	oModel:GetModel( "N99UNICO" ):SetDescription( STR0008 ) //"Aprovadores do Processo"
//	oModel:GetModel( "N99UNICO" ):SetUniqueLine( {"N99_CODPRO","N99_CODUSU","N99_GRPUSU","N99_COPROD","N99_GRPROD"} )
	oModel:GetModel( "N99UNICO" ):SetOptional( .t. )
	oModel:SetRelation( "N99UNICO", { { "N99_FILIAL", "xFilial( 'N99' )" }, { "N99_CODPRO", "N98_CODPRO" } }, N99->( IndexKey( 1 ) ) )

	oModel:GetModel( "N99UNICO" ):SetUseOldGrid( .f. ) //correção ponto de entrada - cadastro de fornecedores.	

Return( oModel )

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since: 	13/12/2017
@Uso: 		OGAA760 - tipos de remessas 
*/
Static Function ViewDef()
	Local oStruN98	:= FWFormStruct( 2, "N98" )
	Local oStruN99	:= FWFormStruct( 2, "N99" )
	Local oModel	:= FWLoadModel( "OGAA760" )
	Local oView		:= FWFormView():New()

	oStruN99:RemoveField( "N99_CODPRO" )
	
	oView:SetModel( oModel )	
	oView:AddField( "VIEW_N98", oStruN98, "N98UNICO" )
	oView:SetOnlyView("VIEW_N98")
	
	oView:AddGrid( "VIEW_N99", oStruN99, "N99UNICO" )
	
	
	oView:CreateVerticallBox( "TELANOVA" , 100 )
	oView:CreateHorizontalBox( "SUPERIOR" , 15, "TELANOVA" )
	oView:CreateHorizontalBox( "INFERIOR" , 85, "TELANOVA" )

	oView:SetOwnerView( "VIEW_N98", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_N99", "INFERIOR" )

	oView:EnableTitleView( "VIEW_N98" )
	oView:EnableTitleView( "VIEW_N99" )


	oView:SetCloseOnOk( {||.t.} )

Return( oView )

/** {Protheus.doc} OGA710LoadN98
Função que varre SX5 comparando com N98, caso não haja o registro na
N98, o mesmo é criado

@author:    Felipe Rafael Mendes
@since:     19/12/2017
@Uso:       OGAA760
*/
Static Function OGA710LoadN98(  )

    DbSelectArea('SX5')
    SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
    SX5->(DbSeek(xFilial("SX5") + "K8")) // k8 = "Processos de Aprovação" 
    while SX5->( !Eof() ) .AND. ( SX5->X5_FILIAL+SX5->X5_TABELA == xFilial("SX5") + "K8" ) //compara os registros da SX5 com a N98, caso não haja o registro, o mesmo é criado
    	
    	DbSelectArea("N98")
    	N98->(DbSetOrder(1))
    	If !( N98->(DbSeek(xFilial("N98") + SX5->X5_CHAVE)) ) //verifica se o registro da SX5 existe na N98
		
			RecLock('N98',.T.)
			N98->N98_FILIAL 	:= xFilial("N98") 
			N98->N98_CODPRO   	:= SX5->X5_CHAVE 
			N98->N98_DESPRO		:= SX5->X5_DESCRI
			MsUnlock('N98')
			
		ElseIf N98->N98_DESPRO != SX5->X5_DESCRI  //Verifica se a descrição na N98 é igual a descrição da SX5
			RecLock('N98',.F.)
			N98->N98_DESPRO		:= SX5->X5_DESCRI
			MsUnlock('N98')	
    	EndIf
		SX5->( dbSkip() )
	endDo
	
	DbSelectArea('N98')
    N98->(DbSetOrder(1)) 
    N98->(dbgotop()) 
    while N98->( !Eof() ) //varre a N98 
    	
    	//Verifica se o registro existe na N98 mas não existe na SX5, caso sim, excluir registro na N98
    	DbSelectArea('SX5')
	    SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
	    If !( SX5->(DbSeek(xFilial("SX5") + "K8" + N98->N98_CODPRO )) )// k8 = "Processos de Aprovação" 
	    	
	    	DbSelectArea('N99')
	    	N99->(DbSetOrder(1)) 
	    	N99->(DbSeek(xFilial("N99") + N98->N98_CODPRO) )  //verifica se o registro Pai(N98) possui filhos(N99)
	    	while N99->( !Eof() ) .AND. N99->N99_FILIAL + N99->N99_CODPRO == xFilial("N99") + N98->N98_CODPRO
	    		
				RecLock('N99',.F.)
				N99->(dbDelete())
				MsUnlock('N99')		    		
	    		
	    		N99->( dbSkip() )
			EndDo
			
			RecLock('N98',.F.)
			N98->(dbDelete())
			MsUnlock('N98')	    	
	    	
	    EndIf
    	N98->( dbSkip() )
	EndDo
    
Return( .T. ) 

/** {Protheus.doc} OGA760WHEN()                                                                                         
Função que limpa o campo grupo caso usuario informado e vice-versa

@author:    Felipe Rafael Mendes
@since:     19/12/2017
@Uso:       OGAA760
*/
Static Function OGA760WHEN(cCampo,oModel)
	Local oModelN99 := oModel:GetModel( "N99UNICO" )
	
	If     cCampo == "N99_CODUSU" .AND. !Empty( oModelN99:GetValue("N99_GRPUSU") ) //Campo N99_CODUSU só pode ser habilitado caso o campo N99_GRPUSU esteja vazio
		Return .F.
	ElseIF cCampo == "N99_GRPUSU" .AND. !Empty( oModelN99:GetValue("N99_CODUSU") ) //Campo N99_GRPUSU só pode ser habilitado caso o campo N99_GRPUSU esteja vazio
		Return .F.
	EndIf
	
	If     cCampo == "N99_COPROD" .AND. !Empty( oModelN99:GetValue("N99_GRPROD") )//Campo N99_COPROD só pode ser habilitado caso o campo N99_GRPROD esteja vazio
		Return .F.
	ElseIF cCampo == "N99_GRPROD" .AND. !Empty( oModelN99:GetValue("N99_COPROD") )//Campo N99_GRPROD só pode ser habilitado caso o campo N99_COPROD esteja vazio
		Return .F.
	EndIf 	
	
Return( .T. )
/** {Protheus.doc} OGA760ValGr()                                                                                         
Função que valida se o grupode usuario informado é valido ou vazio

@author:    Felipe Rafael Mendes
@since:     19/12/2017
@Uso:       OGAA760
*/
Static Function OGA760ValGr(oModel)
	Local oModelN99 := oModel:GetModel( "N99UNICO" )
	Local aParam := {} // array que recebe os valores da função FWGrpParam
	
	If !Empty( oModelN99:GetValue("N99_GRPUSU") )
		
		aParam := FWGrpParam( oModelN99:GetValue("N99_GRPUSU") )
		If Empty(aParam[1][2]) 
	
			Return( .F. )
		EndIf
	Else
		oModelN99:SetValue("N99_DGRUSU","")
	EndIf
Return( .T. ) 
/** {Protheus.doc} OGA760VALD()                                                                                         
Função que valida o Model antes do commit

@author:    Felipe Rafael Mendes
@since:     19/12/2017
@Uso:       OGAA760
*/
Static Function OGA760VALD(oModel)
	Local oModelN99 := oModel:GetModel( "N99UNICO" )
	Local nX
	
	//valida se existe registros no grid sem Codigo ou grupo preenchido
	For nX := 1 To oModelN99:Length()
		oModelN99:Goline(nX)
		
		If Empty( oModelN99:GetValue("N99_GRPUSU") ) .AND. Empty( oModelN99:GetValue("N99_CODUSU") ) .and. !oModelN99:IsDeleted( nX )
			Help(" ", 1, "OGAA760VLDGRI1") //##Problema: Não foi informado código do usuário e o grupo de usuário.  ## Solução: É necessario informar o código do usuário ou o grupo de usuário.     
			Return .F.
		EndIf
		
		If Empty( oModelN99:GetValue("N99_GRPROD") ) .AND. Empty( oModelN99:GetValue("N99_COPROD") ) .and. !oModelN99:IsDeleted( nX )
			Help(" ", 1, "OGAA760VLDGRI2")//##Problema: Não foi informado código do produto e o grupo de produto.  ## Solução: É necessario informar o código do produto ou o grupo de produto.
			Return .F.
		EndIf
		
	Next nX

Return( .T. ) 


/*{Protheus.doc} OGA760ValUser()
(Função de pos-validação da Grid N99)
@type function
@author thiago.rover
@since 23/01/2018
@version 1.0
@return ${return}, ${.T. - Validado, .F. - Não Validado}
*/
Function OGA760ValUser() //Projeto SLC
	Local oModel      := FwModelActive()
	Local oModelN99	  := oModel:GetModel( "N99UNICO" )
	Local nX          := 0
	Local aGrid       := {}
	Local lRet        := .T.
	Local cCodUser    := ""
	Local cCodGrUser  := ""
	Local cCodPro     := ""
	Local cCodGrPro     := ""

	For nX := 1 to oModelN99:Length()

		cCodUser   := ALLTRIM(oModelN99:GetValue('N99_CODUSU' , nX) )
		cCodGrUser := ALLTRIM(oModelN99:GetValue('N99_GRPUSU' , nX) )
		cCodPro    := ALLTRIM(oModelN99:GetValue('N99_COPROD' , nX) )
		cCodGrPro  := ALLTRIM(oModelN99:GetValue('N99_GRPROD' , nX) )
		
		If ASCAN(aGrid, { |x| x[1] == cCodUser .and. x[2] == cCodGrUser .and. x[3] == cCodPro .and. x[4] == cCodGrPro })		
			Help("" ,1 ,"OGA760ValUser") //"OGA760ValUser"###"Operação não permitida pois usuário/grupo de usuário e produto/grupo de produto já foi inserido"	
		    lRet := .F.
		    Exit
		EndIf

		//considera todas as linhas, ate mesmo as deletadas. Caso delete uma linha e tente informar uma linha igual a deletada não irá permitir, pois basta remover o delete.
		aAdd(aGrid, {cCodUser,;
					 cCodGrUser,;
					 cCodPro,;
					 cCodGrPro}) 	

	Next nX
	
Return lRet


/*/{Protheus.doc} fTrgNomUsu( x )
Gatilho para retornar o nome do usuario
@type  Function
@author rafael.kleestadt
@since 20/12/2017
@version 10
@param oParModel, object, objeto do modelo
@return cNomUser, caracter, nome completo do usuário
@example
(examples)
@see (links_or_references)
/*/
Static Function fTrgNomUsu( oParModel )
	Local oModel   := oParModel:GetModel()
	Local oN99	   := oModel:GetModel( "N99UNICO" )
	Local cNomUser := ""

	cNomUser := UsrFullName( oN99:GetValue( "N99_CODUSU" ) )

Return cNomUser

/*/{Protheus.doc} fTrgNomGrp( x )
Gatilho para retornar o nome do grupo de usuario
@type  Function
@author claudineia.reinert
@since 06/02/2018
@version 10
@param oParModel, object, objeto do modelo
@return cNomGrp, caracter, nome completo do grupo de usuário
@example
(examples)
@see (links_or_references)
/*/
Static Function fTrgNomGrp( oParModel )
	Local oModel   := oParModel:GetModel()
	Local oN99	   := oModel:GetModel( "N99UNICO" )
	Local cNomGrp := ""

	cNomGrp := IIf(!Empty(oN99:GetValue( "N99_GRPUSU" )),GrpRetName( oN99:GetValue( "N99_GRPUSU" ) ),"")

Return cNomGrp