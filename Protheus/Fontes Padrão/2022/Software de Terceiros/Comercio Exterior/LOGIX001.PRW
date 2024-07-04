#Include 'Protheus.ch'
#Include "Average.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "LOGIX001.CH"
/*
Programa   : LOGIX001()
Objetivo   : Tela de Proforma
Retorno    : Nil
Autor      : Fabio Satoru Yamamoto
Data/Hora  : 07/05/2012 - 10:00
Obs.       : 
*/
Function LOGIX001()
Local oBrowse


//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse( ):New() //Instanciando a Classe
oBrowse:SetAlias("EJE") //Informando o Alias
oBrowse:SetMenuDef("LOGIX001") //Nome do fonte do MenuDef
oBrowse:SetDescription(TESX2Name("EJE")) //Descrição a ser apresentada no Browse
oBrowse:Activate()

Return Nil


*------------------------*
Static Function MenuDef()
*------------------------*                                   
Local aRotina := {}

//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE STR0001       ACTION "AxPesqui"              OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE STR0002       ACTION "VIEWDEF.LOGIX001"      OPERATION 2 ACCESS 0

Return aRotina
                  

*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel
Local oStruEJE := FWFormStruct(1,"EJE",,)
Local oStruEJG := FWFormStruct(1,"EJG",,) 
Local oStruEJH := FWFormStruct(1,"EJH",,)
Local oStruEJF := FWFormStruct(1,"EJF",,)
Local bCommit  := { |oMdl| .T./*CommitLink(oMdl)*/}

oModel := MPFormModel():New( "LOGIX001", /*bGridValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )                                                                               
oModel:AddFields( "EJEMASTER",/*nOwner*/,oStruEJE)

oModel:AddGrid("EJGDETAIL", "EJEMASTER", oStruEJG, /*bLinePre*/, /* bLinePos*/ , /*bPreVal*/,/*bPosVal*/,/*BLoad*/ )
oModel:AddGrid("EJHDETAIL", "EJEMASTER", oStruEJH, /*bLinePre*/, /* bLinePos*/ , /*bPreVal*/,/*bPosVal*/,/*BLoad*/ )
oModel:AddGrid("EJFDETAIL", "EJEMASTER", oStruEJF, /*bLinePre*/, /* bLinePos*/ , /*bPreVal*/,/*bPosVal*/,/*BLoad*/ )


oModel:SetRelation("EJGDETAIL",{{"EJG_FILIAL", "xFilial('EJG')"}, {"EJG_CODEMP", "EJE_CODEMP"}, {"EJG_NUMFAT" , "EJE_NUMFAT"},{"EJG_CODEMB" , "EJE_CODEMB"}} , EJG->(IndexKey(1)))
oModel:SetRelation("EJHDETAIL",{{"EJH_FILIAL", "xFilial('EJH')"}, {"EJH_CODEMP", "EJE_CODEMP"}, {"EJH_NUMFAT" , "EJE_NUMFAT"},{"EJH_CODEMB" , "EJE_CODEMB"}} , EJH->(IndexKey(1)))
oModel:SetRelation("EJFDETAIL",{{"EJF_FILIAL", "xFilial('EJF')"}, {"EJF_CODEMP", "EJE_CODEMP"}, {"EJF_NUMFAT" , "EJE_NUMFAT"},{"EJF_CODEMB" , "EJE_CODEMB"}} , EJF->(IndexKey(1)))

oModel:GetModel("EJGDETAIL"):SetUniqueLine({"EJG_FILIAL","EJG_CODEMP","EJG_NUMFAT","EJG_CODEMB","EJG_NUMPED","EJG_NSEQPD"})
oModel:GetModel("EJHDETAIL"):SetUniqueLine({"EJH_FILIAL","EJH_CODEMP","EJH_NUMFAT","EJH_CODEMB","EJH_NUMPED","EJH_NSEQPD"})
oModel:GetModel("EJFDETAIL"):SetUniqueLine({"EJF_FILIAL","EJF_CODEMP","EJF_NUMFAT","EJF_CODEMB"})

Return oModel


*------------------------*
Static Function ViewDef()
*------------------------*
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("LOGIX001")
// Cria a estrutura a ser usada na View
Local oStruEJE := FWFormStruct(2,"EJE",,)
Local oStruEJG := FWFormStruct(2,"EJG",,)
Local oStruEJH := FWFormStruct(2,"EJH",,)
Local oStruEJF := FWFormStruct(2,"EJF",,)
Local oView

  
oView := FWFormView():New()

oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_EJE", oStruEJE, "EJEMASTER") 

oView:AddGrid ("VIEW_EJG", oStruEJG, "EJGDETAIL")
oView:AddGrid ("VIEW_EJH", oStruEJH, "EJHDETAIL")
oView:AddGrid ("VIEW_EJF", oStruEJF, "EJFDETAIL")

oView:CreateFolder( 'PASTAS'   ) 

oView:AddSheet( 'PASTAS', 'ABA01', STR0003 ) 
oView:AddSheet( 'PASTAS', 'ABA02', STR0004 )
oView:AddSheet( 'PASTAS', 'ABA03', STR0005 )
oView:AddSheet( 'PASTAS', 'ABA04', STR0006 )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('CAPA'     ,100,,,'PASTAS','ABA01')
oView:CreateHorizontalBox('DETALHE01',100,,,'PASTAS','ABA02')
oView:CreateHorizontalBox('DETALHE02',100,,,'PASTAS','ABA03')
oView:CreateHorizontalBox('DETALHE03',100,,,'PASTAS','ABA04')

// Relaciona o ID da View com o "box" para exibição
oView:SetOwnerView( "VIEW_EJE" , 'CAPA'      )    
oView:SetOwnerView( "VIEW_EJG" , 'DETALHE01' )
oView:SetOwnerView( "VIEW_EJH" , 'DETALHE02' )
oView:SetOwnerView( "VIEW_EJF" , 'DETALHE03' )

//Remove Campo da View
oStruEJG:RemoveField("EJG_CODEMP")
oStruEJG:RemoveField("EJG_DSCEMP")
oStruEJG:RemoveField("EJG_NUMFAT")
oStruEJG:RemoveField("EJG_CODEMB")

oStruEJH:RemoveField("EJH_CODEMP")
oStruEJH:RemoveField("EJH_DSCEMP")
oStruEJH:RemoveField("EJH_NUMFAT")
oStruEJH:RemoveField("EJH_CODEMB")

oStruEJF:RemoveField("EJF_CODEMP")
oStruEJF:RemoveField("EJF_DSCEMP")
oStruEJF:RemoveField("EJF_NUMFAT")
oStruEJF:RemoveField("EJF_CODEMB")

// Liga a identificação do componente
oView:EnableTitleView( "VIEW_EJE",STR0003 , RGB(240, 248, 255 ))
oView:EnableTitleView( "VIEW_EJG",STR0004 , RGB(240, 248, 255 ))
oView:EnableTitleView( "VIEW_EJH",STR0005 , RGB(240, 248, 255 ))
oView:EnableTitleView( "VIEW_EJF",STR0006 , RGB(240, 248, 255 ))

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView