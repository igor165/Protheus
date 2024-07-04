#INCLUDE 'PROTHEUS.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'TMSA156.ch'

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA156 
Estrutura da tela inclusão de grupo de regiões de demanda
@type function
@author Gustavo Henrique Baptista
@version 1.0
@since 01/06/2018
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA156()

Local oBrowse
	
	If !AliasInDic("DLC") .OR. !AliasInDic("DLJ") .OR. !AliasInDic("DLK") //SUAVIZAÇÃO DEMANDAS
		Help( ,, 'HELP',, STR0012, 1, 0 ) //Para acessar esta rotina é necessário atualizar o dicionário de dados com o pacote Gestão de Demandas.
		Return .F.
	EndIf
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DLC')
	oBrowse:SetDescription(STR0001) //'Cadastro de Grupo de Regiões de Demanda'
	oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
//TODO Descrição auto-gerada
@author  gustavo.baptista
@since   01/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002	ACTION 'VIEWDEF.TMSA156' OPERATION 2 ACCESS 0 //Visualizar
	ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.TMSA156' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.TMSA156' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.TMSA156' OPERATION 5 ACCESS 0 // Excluir
	ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.TMSA156' OPERATION 9 ACCESS 0 // Copiar

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
//Modelo de dados
@author  gustavo.baptista
@since   01/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local bPre := {|oModel|T156bPre(oModel)}
Local bCommit := {|oModel|T156Commit(oModel)}
Local bLinePre := {|oModel, nLine, cOpera, cCampo|T156LnPre(oModel, nLine, cOpera, cCampo)}

Local oStruDLC := FWFormStruct(1, 'DLC')
Local oStruDLJ := FWFormStruct(1, 'DLJ')
Local oStruDLK := FWFormStruct(1, 'DLK')
Local oModel	:= MPFormModel():New('TMSA156', bPre, /* bPost */, bCommit, /*bCancel*/) 
	
	oStruDLC:SetProperty('DLC_COD', MODEL_FIELD_WHEN,{||INCLUI})

	//Descricao
	oModel:SetDescription(STR0007)//"GRUPO DE REGIÕES DE DEMANDAS"

	//Field Master
	oModel:AddFields('MASTER_DLC',nil,oStruDLC)

	oModel:SetPrimaryKey( {'DLC_FILIAL','DLC_COD'} )

	//Adiciona grids de origem e destino
	oModel:AddGrid('GRID_ORI','MASTER_DLC',oStruDLJ, bLinePre,/* bLinePost */,/* bPre */, /* bPost */, /* bLoad */)
	oModel:AddGrid('GRID_DES','MASTER_DLC',oStruDLK, bLinePre,/* bLinePost */,/* bPre */, /* bPost */, /* bLoad */)

	oModel:GetModel('GRID_ORI'):SetOptional(.T.)
	oModel:GetModel('GRID_DES'):SetOptional(.T.)
	
	oModel:GetModel( 'GRID_ORI' ):SetUniqueLine( {'DLJ_CODREG'} )
	oModel:GetModel( 'GRID_DES' ):SetUniqueLine( {'DLK_CODREG'} )

	oModel:SetRelation( 'GRID_ORI', { { 'DLJ_FILIAL', 'xFilial( "DLC" )' }, { 'DLJ_CODGRD', 'DLC_COD' } }, DLJ->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'GRID_DES', { { 'DLK_FILIAL', 'xFilial( "DLC" )' }, { 'DLK_CODGRD', 'DLC_COD' } }, DLK->( IndexKey( 1 ) ) )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
//View
@author  gustavo.baptista
@since   01/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel('TMSA156')
Local oStruDLC := FWFormStruct(2,'DLC')
Local oStruDLJ := FWFormStruct(2,'DLJ')
Local oStruDLK := FWFormStruct(2,'DLK')
Local oView
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	//Seta o model para a view
	oView:SetModel(oModel)

	// Remove os Campos Grupo de regiao de Origem e Destino
	oStruDLJ:RemoveField('DLJ_CODGRD')
	oStruDLK:RemoveField('DLK_CODGRD')

	oView:AddField( 'VIEW_DLC', oStruDLC, 'MASTER_DLC' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox('BOX_MAIN', 20,,/*lPixel*/)
	oView:CreateHorizontalBox('BOX_DOWN', 80,,/*lPixel*/)

	oView:CreateVerticalBox('BOX_ORI',50,'BOX_DOWN')	
	oView:CreateVerticalBox('BOX_DES',50,'BOX_DOWN')

	oView:AddGrid('GRID_ORI', oStruDLJ, 'GRID_ORI')
	oView:AddGrid('GRID_DES', oStruDLK, 'GRID_DES')

	oView:EnableTitleView('GRID_ORI', STR0008 + STR0007) //Origem do Grupo de Regiões da Demanda
	oView:EnableTitleView('GRID_DES', STR0009 + STR0007) //Destino do Grupo de Regiões da Demanda

	// Desabilita alteração dos campos
	oStruDLJ:SetProperty( 'DLJ_SEQREG', MVC_VIEW_CANCHANGE, .F. )
	oStruDLJ:SetProperty( 'DLJ_NOMREG', MVC_VIEW_CANCHANGE, .F. )
	oStruDLK:SetProperty( 'DLK_SEQREG', MVC_VIEW_CANCHANGE, .F. )
	oStruDLK:SetProperty( 'DLK_NOMREG', MVC_VIEW_CANCHANGE, .F. )
	
	// Define que o campo Sequência de região será auto-incremental
	oView:AddIncrementField( 'GRID_ORI', 'DLJ_SEQREG' )
	oView:AddIncrementField( 'GRID_DES', 'DLK_SEQREG' )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_DLC', 'BOX_MAIN' )
	oView:SetOwnerView( 'GRID_ORI', 'BOX_ORI')
	oView:SetOwnerView( 'GRID_DES', 'BOX_DES')

	oView:SetViewCanActivate({|oModel|VldCanDel(oModel)})
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCanDel()
@description Valida se é possível excluir grupo de região.
Caso ele esteja vinculado a um Contrato de Demandas, sistema deve impedir operação.
@author  gustavo.baptista
@since   05/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function VldCanDel(oModel)
Local lRet:= .T.
Local cQuery  := ""
Local cAlias := GetNextAlias()
Local oModelDLC:= oModel:GetModel('MASTER_DLC')

	If oModel:GetOperation() == MODEL_OPERATION_DELETE
	
		cQuery  += " SELECT DLE.DLE_CRTDMD "
		cQuery  += "	FROM "+RetSqlName('DLE')+ " DLE "
		cQuery  += " WHERE DLE.DLE_FILIAL = '" + xFilial('DLE') + "'"
		cQuery 	+= "	AND DLE.DLE_CODGRD = '"+ DLC->DLC_COD + "'"
		cQuery  += "    AND DLE.D_E_L_E_T_ = ' '"
		
		cQuery := ChangeQuery(cQuery)
		
		DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAlias, .F., .T. )
	
		If !(cAlias)->( EOF() )
			Help( ,1, 'TMSA15601',, '', 1, 0 )
			lRet:= .F.
		EndIf
		
		(cAlias)->( DbCloseArea() )
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T156LnPre
Pré-validação das linhas dos grids de origem e destino
@author  Gustavo Krug
@since   22/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T156LnPre(oModelGrid, nLine, cOpera, cCampo)
Local lRet := .T.
Local oModelDLC := oModelGrid:GetModel('MASTER_DLC')
Local nOperation := oModelGrid:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT
		If cOpera == "SETVALUE" .And. (cCampo == 'DLJ_CODREG' .OR. cCampo == 'DLK_CODREG')
			If Empty(oModelDLC:GetModel('MASTER_DLC'):GetValue('DLC_COD'))
				Help( ,, 'HELP',, STR0010, 1, 0,,,,,, {STR0011} ) // 'Não é possível informar regiões antes de informar o código para o Grupo de Regiões' //'Preencha o campo Código do Grupo de Regiões (DLC_COD)'
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T156bPre
Pré-validação do Model
@author  Gustavo Krug
@since   21/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T156bPre(oModel)
Local lRet := .T.
Local oModelDLC := oModel:GetModel('MASTER_DLC')
Local oModelOri := oModel:GetModel('GRID_ORI')
Local oModelDes := oModel:GetModel('GRID_DES')
Local nOperation := oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		If !Empty(oModelDLC:GetValue('DLC_COD'))
			oModelOri:SetValue('DLJ_CODGRD', oModelDLC:GetValue('DLC_COD'))
			oModelDes:SetValue('DLK_CODGRD', oModelDLC:GetValue('DLC_COD'))
		EndIf
		
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T156Commit()
Função que efetua commit do Model
@author  Gustavo Krug
@since   21/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T156Commit(oModel)
Local lRet := .T.
Local nX := 0
Local oModelDLC := oModel:GetModel('MASTER_DLC')
Local oModelOri := oModel:GetModel('GRID_ORI')
Local oModelDes := oModel:GetModel('GRID_DES')
Local nOperation := oModel:GetOperation()
	
	Begin Transaction
		
		If lRet
			If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
				For nX := 1 to oModelOri:GetQtdLine()
					oModelOri:GoLine(nX)
					If !oModelOri:IsDeleted(nX) .AND. Empty(oModelOri:GetValue("DLJ_CODREG"))
						oModelOri:DeleteLine()
						Exit		
					EndIf
				Next nX

				For nX := 1 to oModelDes:GetQtdLine()
					oModelDes:GoLine(nX)
					If !oModelDes:IsDeleted(nX) .AND. Empty(oModelDes:GetValue("DLK_CODREG")) 
						oModelDes:DeleteLine()
						Exit		
					EndIf
				Next nX
			EndIf

			If oModel:GetOperation() == MODEL_OPERATION_INSERT
				If __lSX8
					ConfirmSX8()
				EndIf			
			EndIf

			lRet := FwFormCommit(oModel)
			If !lRet
				DisarmTransaction()
				Break
			EndIf
		EndIf	

	End Transaction

Return lRet 