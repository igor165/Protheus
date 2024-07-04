#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA253.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Monta modelo de dados da Atualiza��o de Or�amentos

@return		oModel, objeto, Modelo de Dados

@author	 Cristina Cintra
@since   30/01/2018
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel      := Nil
Local oStructCQD  := FWFormStruct( 1, "CQD" )
Local oCommit     := JA253COMMIT():New()
Local aData       := TamSx3('CTG_DTINI')

	                  // Titulo , Descricao,  Campo      , Tipo do campo  , Tamanho   , Decimal ,  bValid ,  bWhen   , Lista , lObrigat,  bInicializador                                                                                            , � chave, � edit�vel , � virtual
	oStructCQD:AddField( STR0005, STR0005  , 'CQD__DTINI', aData[3]       , aData[1]  , aData[2] ,        ,  {||.F.} ,       ,         , {|| POSICIONE('CTG', 1, xFilial('CTG')+ CQD->CQD_CALEND + CQD->CQD_EXERC + CQD->CQD_PERIOD, 'CTG_DTINI') } ,        ,            , .T.       ) // 'Ano M�s Ini'
	oStructCQD:AddField( STR0006, STR0006  , 'CQD__DTFIM', aData[3]       , aData[1]  , aData[2] ,        ,  {||.F.} ,       ,         , {|| POSICIONE('CTG', 1, xFilial('CTG')+ CQD->CQD_CALEND + CQD->CQD_EXERC + CQD->CQD_PERIOD, 'CTG_DTFIM') } ,        ,            , .T.       ) // 'Ano M�s Fim'

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'JURA253',/*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields( 'CQDMASTER', /*cOwner*/, oStructCQD, /*bPre*/, /*bPost*/, /*bLoad*/ )

	oModel:SetPrimaryKey({'CQD_CALEND', 'CQD_EXERC', 'CQD_PERIOD', 'CQD_PROC'})

	oModel:SetDescription(STR0001) // "Modelo de Calend�rio Cont�bil"

	oModel:InstallEvent("JA253COMMIT", /*cOwner*/, oCommit)

	oModel:SetVldActivate( {|oModel| J253VldAct(oModel)} )

Return ( oModel )

//------------------------------------------------------------------------------
/*/{Protheus.doc} JA253COMMIT
Classe interna implementando o FWModelEvent, para execu��o de fun��o 
durante o commit.

@author	 Cristina Cintra
@since   30/01/2018
@version 1.0
/*/
//------------------------------------------------------------------------------
Class JA253COMMIT FROM FWModelEvent

	Method New()
	Method FieldPreVld()

End Class

//------------------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo construtor FWModelEvent

@author	 Cristina Cintra
@since   30/01/2018
@version 1.0
/*/
//------------------------------------------------------------------------------
Method New() Class JA253COMMIT
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FieldPreVld
M�todo que � chamado pelo MVC quando ocorrer a a��o de pr� valida��o dos campos

@param oModel  , Modelo principal
@param cModelId, Id do submodelo
@param nLine   , Linha do grid
@param cAction , A��o executada no grid, podendo ser: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE
@param cCamp   , nome do campo
@param xValue  , Novo valor do campo

@return lFldPre, Indica se o valor do campo � v�lido

@author Victor Massaru
@since  25/08/2021
/*/
//-------------------------------------------------------------------
Method FieldPreVld(oModel, cModelID, cAction, cId, xValue) Class JA253COMMIT
Local lFldPre := .T.

	If cAction == "SETVALUE" .And. cId <> "CQD_PFSREC"
		lFldPre := JurMsgErro(STR0003,, I18n(STR0007, {cId})) // Opera��o n�o permitida # O campo '#1' n�o pode ser alterado
	EndIf

Return lFldPre

//------------------------------------------------------------------------------
/*/{Protheus.doc} J253VldAct
Fun��o de valida��o da ativa��o do modelo.

@author Victor Hayashi
@since  30/08/2021
@obs    Valida��o criada para n�o permitir as opera��o de PUT e POST do REST
/*/
//------------------------------------------------------------------------------
Static Function J253VldAct(oModel)
Local nOperation := oModel:GetOperation()
Local lRet       := .T.

	If nOperation <> MODEL_OPERATION_VIEW .And. nOperation <> MODEL_OPERATION_UPDATE
		lRet := JurMsgErro(STR0003,, STR0004)// "Opera��o n�o permitida" # "Essa rotina s� permite as opera��es de visualiza��o ou altera��o!"
	EndIf

Return lRet