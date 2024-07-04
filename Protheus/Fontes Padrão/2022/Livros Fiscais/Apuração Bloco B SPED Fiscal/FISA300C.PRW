#Include "FISA300C.ch"
#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA300C()

Esta rotina tem objetivo de realizar os cadastros das deduções de ISS
constantes no blocoo B da EFD ICMS/IPI.

@author Erick G. Dias
@since 11/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function FISA300C()

Local oBrowse := Nil

//Verifico se a tabela de dedução existe antes de prosseguir
IF AliasIndic('F1Q')
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F1Q")
    oBrowse:SetDescription(STR0001) //"Cadastro de deduções de ISS"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) //"Dicionário desatualizado, favor verificar atualizações da apuração de ISS referente ao Bloco B da EFD ICMS/IPI."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erick G Dias
@since 11/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}	

IF x300BMODO() == 'EDT' //Edição
    //NA edição habilitará os demais botões
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA300C' OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.FISA300C' OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.FISA300C' OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.FISA300C' OPERATION 5 ACCESS 0 //"Excluir"

Else
    //Habilitará somente o botão de visualização
    ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA300C' OPERATION 2 ACCESS 0 //"Visualizar"
EndIF
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Criação do modelo para as deduções de ISS

@author Erick G Dias
@since 11/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil

//Estrutura da tabela F1Q
Local oDeducao := FWFormStruct(1, "F1Q" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA300C')

//Atribuindo cabeçalho para o modelo
oModel:AddFields("FISA300C",,oDeducao)

//Inicializador Padrão dos campos de Tipo de ajustes e do ID da apuração
oDeducao:SetProperty('F1Q_INDOBR' , MODEL_FIELD_INIT,{|| x300BTPDED() })
oDeducao:SetProperty('F1Q_IDAPUR' , MODEL_FIELD_INIT,{|| x300BIDAPU() })

//Não permite alteração do indicador de obrigação
oDeducao:SetProperty('F1Q_INDOBR' , MODEL_FIELD_WHEN, {|| .F. })

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Erick G Dias
@since 11/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA300C" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oDeducao := FWFormStruct(2, "F1Q")
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Retiro os IDs da view
oDeducao:RemoveField('F1Q_ID')
oDeducao:RemoveField('F1Q_IDAPUR')

//Atribuindo formulários para interface
oView:AddField( 'VIEW_ABA' , oDeducao , 'FISA300C' )

Return oView
 