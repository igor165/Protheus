#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GCPA003.CH'

Function GCPA003()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CO6')
oBrowse:SetDescription( STR0001 )	//--"Cadastro de Participantes"
oBrowse:AddLegend( "CO6_TIPO=='C'", "YELLOW"	, STR0002)	//--"Pré-cliente"
oBrowse:AddLegend( "CO6_TIPO=='F'", "GREEN"	, STR0003)	//--"Pré-fornecedor"
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.GCPA003' OPERATION 2 ACCESS 0		//--Visualizar
ADD OPTION aRotina TITLE STR0007	ACTION 'VIEWDEF.GCPA003' OPERATION 3 ACCESS 0		//--Incluir
ADD OPTION aRotina TITLE STR0008	ACTION 'VIEWDEF.GCPA003' OPERATION 4 ACCESS 0		//--Alterar
ADD OPTION aRotina TITLE STR0009	ACTION 'VIEWDEF.GCPA003' OPERATION 5 ACCESS 0		//--Excluir
ADD OPTION aRotina TITLE STR0011   ACTION 'VIEWDEF.GCPA003' OPERATION 8 ACCESS 0		//--Imprimir
ADD OPTION aRotina TITLE STR0012	ACTION 'VIEWDEF.GCPA003' OPERATION 9 ACCESS 0		//--Copiar
ADD OPTION aRotina TITLE STR0013	ACTION 'GP300SICAF' OPERATION 3 ACCESS 0			//--Integração SICAF
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCO6 := FWFormStruct( 1, 'CO6', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

oModel := MPFormModel():New('GCPA003M', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
oModel:AddFields( 'CO6MASTER', /*cOwner*/, oStruCO6, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetDescription( STR0001 )
oModel:GetModel( 'CO6MASTER' ):SetDescription( STR0001 )

//oModel:SetActivate({|oModel|GCPA03Ins(oModel)})

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel( 'GCPA003' )
Local oStruCO6 := FWFormStruct( 2, 'CO6' )
Local oView

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_CO6', oStruCO6, 'CO6MASTER' )
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_CO6', 'TELA' )

Return oView

Function GCPA03VAL(cCNPJ, cTipo)
Local lRet      := .T.
Local cAlias    := ""
Local cCampo    := ""
Local aArea		:= GetArea() 

If !Empty(cCNPJ) 
	
	BeginSQL Alias "GCPA03VAL"
	
	SELECT CO6.CO6_CNPJ CNPJ
	
	FROM %table:CO6% CO6
	
	WHERE CO6.CO6_CNPJ = %exp:cCnpj % 
		AND CO6.%NotDel%
	ORDER BY CNPJ
	
	EndSQL
	
	//dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqTmp)
	
	//Verifica se existe Pre-Fornecedor que ainda nao e' fornecedor
	If GCPA03VAL->(!Eof())
		Help(" ",1,"GCP03CGC")// "CNPJ já consta no cadastro de participantes"
		lRet := .F.
	Else
		If !Empty(cTipo)
			If cTipo == "C"
				cAlias    := "SA1"
			ElseIf cTipo == "F"
				cAlias   := "SA2"
			EndIf
			DbSelectArea(cAlias)
			DbSetOrder(3)
			If DbSeek(xFilial(cAlias)+cCnpj) .And. !Empty(cCnpj) 
				cCampo := SubStr(cAlias,2,2)+"_COD"
				Help(" ",1,"GCP03EXI")// "Participante já consta no cadastro" 
				lRet := .F.
			EndIf
		EndIf
	EndIf
		
	GCPA03VAL->(DbCloseArea())
EndIf

RestArea(aArea)
Return(lRet)           





//-------------------------------------------------------------------
/*/{Protheus.doc} GP300SICAF()
Rotina que realiza consulta aos dados de fornecedores no SICAF e permite inclusão de fornecedor / participante
@author Rogerio Melonio
@since 22/06/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GP300SICAF()

FWExecView ( STR0013 , "GCPA180",  MODEL_OPERATION_INSERT,,{||.T.},,,,,,,)					

Return Nil
