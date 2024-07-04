#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PCPA116.CH'

//------------------------------------------------------------------
/*/{Protheus.doc} PCPA116
Tela de Cadastro de Campos para Revisão Automática da Estrutura

@author Renan Roeder
@since 12/03/2018
@version P12
/*/
//------------------------------------------------------------------
Function PCPA116()
	Local oBrowse
	Local lRevAut    := SuperGetMv("MV_REVAUT",.F.,.F.)
	
	If !AliasInDic("SOW")
		Help( ,, 'Help',, STR0006, 1, 0 ) //"Tabela inexistente"
		Return Nil
	EndIf
	If !lRevAut
		Help( ,, 'Help',, STR0005, 1, 0 ) //"Acesso não autorizado com o parâmetro MV_REVAUT inativo!"
		Return Nil
	EndIf
	CarregaSOW()
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SOW')
	oBrowse:SetDescription( STR0001 ) //"Controle de Revisões"
	oBrowse:Activate()
Return NIL

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Camada Model do MVC.

@author  Renan Roeder
@since   12/03/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruSOW := FWFormStruct( 1, 'SOW' )
	Local oModel
	oModel := MPFormModel():New( 'PCPA116', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'SOWMASTER', /*cOwner*/, oStruSOW )
	oModel:SetDescription( STR0001 ) //"Controle de Revisões"
	oModel:SetPrimaryKey({"OW_CODIGO"})
Return oModel

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Camada View do MVC.

@author  Renan Roeder
@since   12/03/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel( 'PCPA116' )
	Local oStruSOW := FWFormStruct( 2, 'SOW' )
	Local oView
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_SOW', oStruSOW, 'SOWMASTER' )
Return oView

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu de Operações MVC

@author  Renan Roeder
@since   12/03/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.PCPA116' OPERATION 2 ACCESS 0 //Visualizar
	ADD OPTION aRotina Title STR0003 Action 'PCPA116ALT()'    OPERATION 4 ACCESS 0 //Alterar
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.PCPA116' OPERATION 8 ACCESS 0 //Imprimir
Return aRotina

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA116ALT
Chamada da função alterar.

@author  Renan Roeder
@since   12/03/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA116ALT()
	(FWExecView (UPPER(STR0003), "PCPA116",  MODEL_OPERATION_UPDATE,,{||.T.},,,,,,,))
Return Nil

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaSOW
Carrega a tabela SOW com os campos da tabela SG1.

@author  Renan Roeder
@since   12/03/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function CarregaSOW()
Local lRet := .T.
Local aStrSG1 := {}
Local nI

aAdd(aStrSG1,"G1_TRT")
aAdd(aStrSG1,"G1_QUANT")
aAdd(aStrSG1,"G1_PERDA")
aAdd(aStrSG1,"G1_INI")
aAdd(aStrSG1,"G1_FIM")
aAdd(aStrSG1,"G1_OBSERV")
aAdd(aStrSG1,"G1_FIXVAR")
aAdd(aStrSG1,"G1_GROPC")
aAdd(aStrSG1,"G1_OPC")
aAdd(aStrSG1,"G1_POTENCI")
aAdd(aStrSG1,"G1_TIPVEC")
aAdd(aStrSG1,"G1_VECTOR")

//Proteção do fonte para não exibir campos novos nesta release
If FindFunction("RodaNewPCP") .And. RodaNewPCP()
	aAdd(aStrSG1,"G1_LOCCONS")
	aAdd(aStrSG1,"G1_FANTASM")
EndIf

dbSelectArea('SOW')
SOW->(dbSetOrder(1))
For nI := 1 to len( aStrSG1 )
	IF !SOW->(dbSeek(xFilial('SOW')+aStrSG1[nI]))
		RecLock('SOW',.T.)			
		SOW->OW_FILIAL := xFilial('SOW')
		SOW->OW_CODIGO := aStrSG1[nI]
		SOW->OW_REVISA := "1"
		SOW->(MsUnLock())
	Endif
Next

Return lRet
