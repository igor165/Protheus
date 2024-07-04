#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA252.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} JURA252
Atualização de Orçamentos.

@author		Jonatas Martins
@since		26/01/2018
@version	12.1.20
@Obs		Criado modelo de dados MVC da rotina FINA020 do SIGAFIN
/*/
//------------------------------------------------------------------------------
Function JURA252()

	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()	
	oBrowse:SetAlias("SE7")
	oBrowse:SetDescription(STR0001) //"Atualização de Orçamentos"
	oBrowse:DisableDetails()
	oBrowse:Activate()
	
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Monta estrutura de funções do Browse

@return		aRotina, array, Array de Rotinas

@author		Jonatas Martins
@since		26/01/2018
@version	12.1.20
@obs		Modelo apenas para sincronização dos dados portanto é apenas Visulizar
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.JURA252" OPERATION 2 ACCESS 0 //"Visualizar"

Return ( aRotina )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Monta modelo de dados da Atualização de Orçamentos

@return		oModel, objeto, Modelo de Dados

@author		Jonatas Martins
@since		26/01/2018
@version	12.1.20
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
	
	Local oStructSE7  := FWFormStruct(1, "SE7")
	Local oCommit     := JA252COMMIT():New()
	Local oModel      := Nil
		
	oModel := MPFormModel():New("JURA252")
	
	oModel:AddFields("SE7MASTER",, oStructSE7)
	oModel:InstallEvent("JA252COMMIT",, oCommit)
	oModel:SetPrimaryKey({"E7_NATUREZ", "E7_ANO", "E7_CMOEDA", "E7_CESCR", "E7_CCUSTO", "E7_CPART", "E7_CRATEIO"})
	
	oModel:SetDescription(STR0001) //"Atualização de Orçamentos"
 
Return ( oModel )

//------------------------------------------------------------------------------
/*/{Protheus.doc} JA252COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author		Jonatas Martins
@since		26/01/2018
@version	12.1.20
/*/
//------------------------------------------------------------------------------
Class JA252COMMIT FROM FWModelEvent

	Method New()
	Method ModelPosVld()
	
End Class

//------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor FWModelEvent

@author		Jonatas Martins
@since		26/01/2018
@version	12.1.20
/*/
//------------------------------------------------------------------------------
Method New() Class JA252COMMIT
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model

@author		Jonatas Martins
@since		26/01/2018
@version	12.1.20
@Obs		Validação criada para não permitir as operação de PUT e POST do REST
/*/
//------------------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class JA252COMMIT

	Local nOperation := oModel:GetOperation()
	Local lPosVld    := .T.
	
	If nOperation <> MODEL_OPERATION_VIEW
		oModel:SetErrorMessage(,, oModel:GetId(),, "ModelPosVld", STR0006, STR0007,, ) // "Operação não permitida" # "Essa rotina só permite a operação de visualização!"
		lPosVld := .F.
	EndIf
	
Return ( lPosVld )