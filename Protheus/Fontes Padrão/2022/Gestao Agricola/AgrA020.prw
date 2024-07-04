#include 'protheus.ch'
#include 'AGRA020.CH'
#include "fwmvcdef.ch"

/** {Protheus.doc} AGRA020
Rotina para cadastro de mao de obra

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	26/06/2018
@Uso: 		SIGAAGR
*/
Function AGRA020()
	Local oMBrowse := Nil
		
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("NNA")
	oMBrowse:SetDescription(STR0001) //"Mao de Obra"	
	oMBrowse:Activate()

Return()

/** {Protheus.doc} MenuDef
Funcao que retorna os itens para construcao do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindustria
@since: 	26/06/2018
@Uso: 		AGRA020 - Cadastro de Mao de Obra
*/
Static Function MenuDef()
	Local aRotina := {}
	
	aAdd( aRotina, { STR0002, "PesqBrw"       ,  0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "ViewDef.AGRA020", 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "ViewDef.AGRA020", 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0005, "ViewDef.AGRA020", 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0006, "ViewDef.AGRA020", 0, 5, 0, Nil } ) //"Excluir"

Return(aRotina)

/** {Protheus.doc} ModelDef
Funcao que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindustria
@since: 	26/06/2018
@Uso: 		AGRA020 - Cadastro de Mao de Obra
*/
Static Function ModelDef()
	Local oStruNNA := FWFormStruct(1, "NNA")
	Local oModel   := MPFormModel():New("AGRA020",/*bPre*/,/*bPos*/, {|oModel| AGRA020GRV(oModel)})
	
	oModel:SetDescription(STR0001) //"Mao de Obra"
	oModel:AddFields("NNAUNICO", Nil, oStruNNA)	
	oModel:GetModel("NNAUNICO"):SetDescription(STR0007) //"Dados da Mao de Obra"

Return(oModel)

/** {Protheus.doc} ViewDef
Funcao que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since: 	26/06/2018
@Uso: 		AGRA020 - Cadastro de Mao de Obra
*/
Static Function ViewDef()
	Local oStruNNA := FWFormStruct(2, "NNA")
	Local oModel   := FWLoadModel("AGRA020")
	Local oView    := FWFormView():New()
		
	oStruNNA:RemoveField("NNA_DATINC")
	oStruNNA:RemoveField("NNA_HORINC")
	oStruNNA:RemoveField("NNA_DATATU")
	oStruNNA:RemoveField("NNA_HORATU")
		
	oView:SetModel(oModel)
	oView:AddField("VIEW_NNA", oStruNNA, "NNAUNICO")
	oView:CreateHorizontalBox("UM", 100)
	oView:SetOwnerView("VIEW_NNA", "UM")
		
Return(oView)


/*{Protheus.doc} AGRA020GRV
Gravacao dos dados da mao-de-obra

@author 	Equipe Agroindustria
@since: 	26/06/2018
@Uso: 		AGRA020 - Cadastro de Mao de Obra
@version 	1.0
*/
Static Function AGRA020GRV(oModel)
	Local nOperation := oModel:GetOperation()
	Local oModelNNA  := oModel:GetModel('NNAUNICO')
	Local aAreaNNA   := ""
	
	If nOperation = MODEL_OPERATION_INSERT
		oModelNNA:SetValue('NNA_DATINC', dDatabase)
		oModelNNA:SetValue('NNA_HORINC', Time())
		
	ElseIf nOperation = MODEL_OPERATION_UPDATE
		oModelNNA:SetValue('NNA_DATATU', dDatabase)
		oModelNNA:SetValue('NNA_HORATU', Time())
		
	ElseIf nOperation = MODEL_OPERATION_DELETE
		aAreaNNA := NNA->(GetArea())
		
		DbSelectArea("NNA")
		NNA->(DbSetOrder(1)) // NNA_FILIAL+NNA_CODIGO
		If NNA->(DbSeek(FWxFilial("NNA")+oModelNNA:GetValue("NNA_CODIGO")))
			If RecLock("NNA", .F.)
				NNA->NNA_DATATU := dDatabase
				NNA->NNA_HORATU := Time()
				NNA->(MsUnlock())
			EndIf
		EndIf
		
		RestArea(aAreaNNA)
	EndIf
		
	FWFormCommit(oModel)	

Return .T.

