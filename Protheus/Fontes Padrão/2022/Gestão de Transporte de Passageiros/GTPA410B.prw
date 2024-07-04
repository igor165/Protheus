#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	Flavio Martins -  Inovação
@since		25/05/2018
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= nil
Local oStruGZO	:= FWFormStruct(1,'GZO')
oModel := MPFormModel():New('GTPA410B', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('GZOMASTER',/*cOwner*/,oStruGZO)
oModel:SetDescription(GTPSx2Name( "GZO" ))
oModel:GetModel('GZOMASTER'):SetDescription(GTPSx2Name( "GZO" ))	//
oModel:SetPrimaryKey({"GZO_FILIAL","GZO_CODGQ6"})

Return ( oModel )
