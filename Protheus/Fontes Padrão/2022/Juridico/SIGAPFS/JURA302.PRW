#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'JURA302.CH'


Static __cContrato := ""
//------------------------------------------------------------------------------
/*/{Protheus.doc} JURA302
Rotina responsavel pelo cadastro do faturamento de ocorrência
@since 13/09/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
Function JURA302(cFilAux,cContrato)
Local oBrowse := FWMBrowse():New()

Default cFilAux   := xFilial('OI4')
Default cContrato := NT0->NT0_COD

	__cContrato := cContrato

	oBrowse:SetAlias('OI4')

	oBrowse:SetMenuDef('JURA302')
	oBrowse:SetDescription(STR0001)//'Faturamento de ocorrências'

	oBrowse:SetFilterDefault( "OI4_FILIAL == '" + cFilAux + "' .AND. OI4_CCONTR == '" + __cContrato + "'" )

	oBrowse:Activate()
	oBrowse:Destroy()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author 
@since 13/09/2022
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.JURA302' OPERATION OP_VISUALIZAR ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.JURA302' OPERATION OP_INCLUIR    ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.JURA302' OPERATION OP_ALTERAR    ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.JURA302' OPERATION OP_EXCLUIR    ACCESS 0 // Excluir

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author jacomo.fernandes
@since 13/09/2022
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local oStrOI4	:= FWFormStruct(1,'OI4')
Local oStrOI5	:= FWFormStruct(1,'OI5')
Local bPosValid := {|oMdl| ModelPosValid(oMdl)}
Local bLinePost := {|oMdl| JA125VLFX( oMdl , 'OI5DETAIL' ,.F.) }
Local bFldVld   := {|oMdl,cField,uNewValue,uOldValue| FieldValid(oMdl,cField,uNewValue,uOldValue) }

	oStrOI4:SetProperty('OI4_CCONTR', MODEL_FIELD_INIT, {|oMdl| __cContrato})
	oStrOI4:SetProperty('OI4_TPCALC', MODEL_FIELD_VALID, bFldVld)
	oStrOI4:SetProperty('OI4_COCORR', MODEL_FIELD_VALID, bFldVld)

	oModel := MPFormModel():New('JURA302', /*bPreValidacao*/, bPosValid, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields('OI4MASTER',/*cOwner*/,oStrOI4,/*bPre*/,/*bPos*/,/*bLoad*/)
	oModel:AddGrid('OI5DETAIL','OI4MASTER',oStrOI5,/*bLinePre*/,bLinePost, /*bPreVal*/,/*bPosVld*/,/*bLoad*/)

	oModel:SetRelation('OI5DETAIL',{{ 'OI5_FILIAL','OI4_FILIAL'},{'OI5_CCONTR','OI4_CCONTR' },{'OI5_COCORR','OI4_COCORR' }},OI5->(IndexKey(1)))

	oModel:SetDescription(STR0001) //'Faturamento de ocorrência'

	oModel:GetModel('OI4MASTER'):SetDescription(STR0001) //'Faturamento de ocorrência'
	oModel:GetModel('OI5DETAIL'):SetDescription(STR0006) //'Faixas de ocorrências'

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@since 13/09/2022
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView    := FWFormView():New()
Local oModel   := FwLoadModel('JURA302')
Local oStrOI4  := FWFormStruct(2, 'OI4')
Local oStrOI5  := FWFormStruct(2, 'OI5')
	
	oStrOI4:RemoveField('OI4_CCONTR')

	oView:SetModel(oModel)

	oView:AddField('VIEW_OI4' ,oStrOI4,'OI4MASTER')
	oView:AddGrid('VIEW_OI5'  ,oStrOI5,'OI5DETAIL')

	oView:CreateHorizontalBox('UPPER',  30)
	oView:CreateHorizontalBox('BOTTOM', 70)

	oView:SetOwnerView('VIEW_OI4','UPPER')
	oView:SetOwnerView('VIEW_OI5','BOTTOM')

	oView:AddIncrementField( 'VIEW_OI5', 'OI5_SEQ' )

	oView:SetDescription(STR0001) //'Faturamento de ocorrência'

	oView:EnableTitleView('VIEW_OI5',STR0006) //'Faixas de ocorrências'

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosValid
Função responsavel pela validação final do modelo de dados
@since 13/09/2022
@version 1.0
@return lRet, retorna se está valido ou não
/*/
//------------------------------------------------------------------------------
Static Function ModelPosValid(oModel)
Local lRet    := .T.
Local oMdlOI4 := oModel:GetModel('OI4MASTER')
Local oMdlOI5 := oModel:GetModel('OI5DETAIL')
Local lQtdCas := oMdlOI4:GetValue('OI4_TPCALC') == '1'

	//Faz a validação das faixas para não ficarem sobrepostas
	If !JA125VLFX(oMdlOI5, 'OI5DETAIL', .F.)
		lRet := .F.
	EndIf

	// Valida se há faixa iniciada em 0 e uma terminada em 99999.
	If lRet .And. !JVldPerFx(oMdlOI5, "OI5_VLRINI", "OI5_VLRFIN", lQtdCas )
		lRet := .F.
	EndIf

	// Valida se há lacunas entre as faixas
	If lRet .And. !JVldLacFx(oMdlOI5, "OI5_VLRINI", "OI5_VLRFIN", lQtdCas )
		lRet := .F.
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldValid(oMdl,cField,uNewValue,uOldValue)
Função responsavel pela validação dos campos
@since  18/11/2020
@version 1.0
@param oMdl, character, SubModelo posicionado
@param cField, character, Campo posicionado
@param uNewValue, character, novo valor do campo
@param uOldValue, character, valor anterior do campo
@return lRet, retorno booleano, retorna se o campo está valido ou não
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue)
Local lRet     := .T.
Local oModel   := oMdl:GetModel()
Local cMdlId   := oMdl:GetId()
	Do Case
		Case Empty(uNewValue)
			lRet := .T.
		Case (cField == "OI4_COCORR" .or. cField == 'OI4_TPCALC') 
			If cField == "OI4_COCORR" ;
				.and. JurGetDados('OI2',1,xFilial('OI2')+oMdl:GetValue('OI4_COCORR'),'OI2_COD') <> uNewValue
				lRet := .F.
				cMsgErro := STR0009 //"Registro não encontrado"
				cMsgSol  := STR0010 //"Selecione um registro válido"

			ElseIf cField == "OI4_COCORR" ;
				.and. JurGetDados('OI4',1,xFilial('OI4')+oMdl:GetValue('OI4_CCONTR')+oMdl:GetValue('OI4_COCORR'),'OI4_COCORR') == oMdl:GetValue('OI4_COCORR')
				lRet     := .F.
				cMsgErro := STR0011 //"Ocorrência previamente selecionada em outro registro"
				cMsgSol  := STR0012 //"Selecione uma nova ocorrência ou verifique o cadastro!"

			ElseIf oMdl:GetValue('OI4_TPCALC') == '2' .and. !Empty(oMdl:GetValue('OI4_COCORR'))
				If Empty( JurGetDados('OI2',1,xFilial('OI2')+oMdl:GetValue('OI4_COCORR'),'OI2_RETORN') )
					lRet     := .F.
					cMsgErro := STR0007 //"Ocorrência selecionada não possui valor de retorno (OI2_RETORN)!"
					cMsgSol  := STR0008 //"Acerte o cadastro ou selecione outra ocorrência"
				Endif
			Endif
	EndCase

	If !lRet 
		oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
	Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} J302Delete(cFilCon, cContrato )
Função responsavel pela exclusão das faixas de faturamento
@version 1.0
@param cFilCon, character, Filial do contrato
@param cContrato, character, Código do contrato
/*/
//------------------------------------------------------------------------------
Function J302Delete( cFilCon, cContrato )
Local cQuery    := ""
Local cTmpAlias := GetNextAlias()
Local oModel    := FwLoadModel('JURA302')
	oModel:SetOperation(MODEL_OPERATION_DELETE)

	cQuery := " Select R_E_C_N_O_ RECNO "
	cQuery += " From " + RetSqlName('OI4') + " OI4 "
	cQuery += " Where "
	cQuery +=     " OI4.D_E_L_E_T_ = ' '"
	cQuery +=     " AND OI4.OI4_FILIAL = '"+cFilCon+"' "
	cQuery +=     " AND OI4.OI4_CCONTR = '"+cContrato+"' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery ), cTmpAlias,.T.,.T.)

	dbSelectArea(cTmpAlias)
	(cTmpAlias)->(dbGoTop())
	While (cTmpAlias)->(!Eof())
		OI4->(DbGoTo((cTmpAlias)->RECNO))
		If oModel:Activate()
			oModel:VldData()
			oModel:CommitData()
		Endif
		oModel:DeActivate()
		(cTmpAlias)->(DbSkip())
	End
	(cTmpAlias)->(DbCloseArea())
Return
