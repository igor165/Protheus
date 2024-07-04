#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA630A.CH"

/*/------------------------------------------------------------------------------
{Protheus.doc} ModelDef
Monta modelo de dados do Níveis do Agrupador Dinamico.
@sample		ModelDef()
@param		Nenhum
@return		ExpO - Modelo de Dados
@author		SI2901 - Cleyton F.Alves
@since		11/03/2015
@version	12
------------------------------------------------------------------------------/*/

Static Function ModelDef()

Local oStructCAB	:= FWFormModelStruct():New()
Local oStructAOL	:= FWFormStruct(1,"AOL",/*bAvalCampo*/,/*lViewUsado*/)
Local oModel 	 	:= Nil
Local bPosVldGrid	:= {|| }
Local bCarga        := {|| {xFilial("AOL")}}

//Monta estrutura do CABEC do Model
oStructCAB:AddField("","","CABEC_FILIAL","C",FwSizeFilial(),0)

//Monta estrutura do AOL
oStructAOL:AddField("","","AOL_MARK","L",1,0,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)
oStructAOL:SetProperty("AOL_CODAGR",MODEL_FIELD_INIT,{||})
oStructAOL:SetProperty("AOL_DSCENT",MODEL_FIELD_INIT,{||})

//Monta oModel 
oModel := MPFormModel():New("CRMA630A",/*bPreValidacao*/,/*bPosVldMdl*/,/*bCommitMdl*/,/*bCancel*/)

oModel:AddFields("CABMASTER",/*cOwner*/,oStructCAB,/*bPreValidacao*/,/*bPosVldMdl*/,bCarga)
oModel:SetPrimaryKey({""})

//Monta Grid do Model
oModel:AddGrid("AOLDETAIL","CABMASTER" ,oStructAOL,/*bLinPre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVldGrid*/,/*bLoad*/)
oModel:GetModel('AOLDETAIL'):SetLoadFilter({{'AOL_ENTIDA', "{'SA1','SB1','SC5','SC6','SF4'}",9},{'AOL_MSBLQL',"'2'"}}) //MVC_LOADFILTER_IS_CONTAINED é igual a 9, mas estava dando erro na execução

//Relaciona CABEC com AOL da Grid
oModel:SetRelation("AOLDETAIL",{{"AOL_FILIAL","xFilial('AOL')"}},AOL->(IndexKey(1)))

//Descricoes
oModel:GetModel("CABMASTER"):SetDescription("Agrupadores")
oModel:SetDescription(STR0001) //Agrupadores

//Permite criar a Grid vazia
oModel:GetModel("AOLDETAIL"):SetOptional(.T.)

Return oModel

/*/------------------------------------------------------------------------------
{Protheus.doc} ViewDef
Monta interface do Níveis do Agrupador Dinamico.
@sample		ViewDef()
@param		Nenhum
@return		ExpO - Interface do Agrupador de Registros
@author		SI2901 - Cleyton F.Alves
@since		11/03/2015
@version	12
------------------------------------------------------------------------------/*/

Static Function ViewDef()

Local oStructAOL	:= FWFormStruct(2,"AOL",{ |cCampo| CR630VldCpo(cCampo) },/*lViewUsado*/)
Local oModel   		:= FWLoadModel('CRMA630A')
Local oView	 		:= Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo de marca da tabela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructAOL:AddField("AOL_MARK","01","","",{},"L","@BMP",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)

oView:=FWFormView():New()
oView:SetModel(oModel)
oView:AddGrid("VIEW_AOL",oStructAOL,"AOLDETAIL")

oView:CreateHorizontalBox("SUPERIOR",100)
oView:SetOwnerView("VIEW_AOL","SUPERIOR")

Return oView

/*/------------------------------------------------------------------------------
{Protheus.doc} CR630VldCpo
Monta interface do Níveis do Agrupador Dinamico.
@sample		ViewDef()
@param		Nenhum
@return		ExpO - Interface do Agrupador de Registros
@author		SI2901 - Cleyton F.Alves
@since		11/03/2015
@version	12
------------------------------------------------------------------------------/*/
Static Function CR630VldCpo(cCampo) 

Local lRet := .T.  

//Filtra os campos que serão apresentados na tela
If AllTrim(cCampo) $ 'AOL_TIPO|AOL_MSBLQL|AOL_DSCENT' 
	lRet := .F. 
EndIf  

Return lRet

//Dummy Function
Function CR630ADummy()

Return Nil