#Include 'Protheus.ch'
#Include "Average.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "LOGIX004.CH"
/*
Programa   : LOGIX004
Objetivo   : Tela Carta de Credito
Retorno    : Nil
Autor      : Fabio Satoru Yamamoto
Data/Hora  : 07/05/2012 - 10:00
Obs.       : 
*/
Function  LOGIX004()
Local oBrowse

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse( ):New() //Instanciando a Classe
oBrowse:SetAlias("EJM") //Informando o Alias
oBrowse:SetMenuDef(" LOGIX004") //Nome do fonte do MenuDef
oBrowse:SetDescription(TESX2Name("EJM")) //Descrição a ser apresentada no Browse
oBrowse:Activate()

Return Nil


*------------------------*
Static Function MenuDef()
*------------------------*                                   
Local aRotina := {}

//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE STR0001        ACTION "AxPesqui"         OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE STR0002       ACTION "VIEWDEF. LOGIX004" OPERATION 2 ACCESS 0

Return aRotina
                  

*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel
Local oStruEJM := FWFormStruct( 1 , "EJM",,)
Local oStruEJN := FWFormStruct(1,"EJN",,) 
Local bCommit  := { |oMdl| .T./*CommitLink(oMdl)*/}

oModel := MPFormModel():New( " LOGIX004", /*bGridValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )                                                                               
oModel:AddFields( "EJMMASTER",/*nOwner*/,oStruEJM)
oModel:AddGrid("EJNDETAIL", "EJMMASTER", oStruEJN, /*bLinePre*/, /* bLinePos*/ , /*bPreVal*/,/*bPosVal*/,/*BLoad*/ )
oModel:SetRelation("EJNDETAIL",{{"EJN_FILIAL", "xFilial('EJN')"}, {"EJN_NUMCAR", "EJM_NUMCAR"}/*, {"EJN_NUMFAT" , "EJM_NUMFAT"},{"EJN_CODEMB" , "EJM_CODEMB"}*/} , EJN->(IndexKey(1)))
oModel:GetModel("EJNDETAIL"):SetUniqueLine({"EJN_NUMCAR","EJN_CODEMP","EJN_NUMFAT","EJN_CODEMB"})

Return oModel

*------------------------*
Static Function ViewDef()
*------------------------*
Local oModel := FWLoadModel(" LOGIX004")
Local oStruEJM := FWFormStruct(2,"EJM",,) 
Local oStruEJN := FWFormStruct(2,"EJN",,)

Local oView

oView := FWFormView():New()
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_EJM", oStruEJM, "EJMMASTER")
oView:AddGrid ("VIEW_EJN", oStruEJN, "EJNDETAIL")

oView:CreateFolder( 'PASTAS'   )
oView:CreateFolder( 'PASTAS01' )

oView:AddSheet( 'PASTAS', 'ABA01', STR0003 ) 
oView:AddSheet( 'PASTAS', 'ABA02', STR0004 )

oView:CreateHorizontalBox('CAPA'     ,100,,,'PASTAS','ABA01')
oView:CreateHorizontalBox('DETALHE01',100,,,'PASTAS','ABA02')

oView:SetOwnerView( "VIEW_EJM" , 'CAPA'      )    
oView:SetOwnerView( "VIEW_EJN" , 'DETALHE01' )

oStruEJN:RemoveField("EJN_NUMCAR")
oStruEJN:RemoveField("EJN_CODEMP")
oStruEJN:RemoveField("EJN_DSCEMP")


// Liga a identificação do componente
oView:EnableTitleView( "VIEW_EJM", STR0003 , RGB(240, 248, 255 ))
oView:EnableTitleView( "VIEW_EJN", STR0004 , RGB(240, 248, 255 ))

oView:EnableControlBar(.T.) //Habilita ButtonsBar

Return oView