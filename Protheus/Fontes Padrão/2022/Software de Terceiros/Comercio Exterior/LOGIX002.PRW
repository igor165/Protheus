#Include 'Protheus.ch'
#Include "Average.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "LOGIX002.CH"
/*
Programa   : LOGIX002
Objetivo   : Tela de Embarque
Retorno    : Nil
Autor      : Fabio Satoru Yamamoto
Data/Hora  : 07/05/2012 - 10:00
Obs.       : 
*/
Function LOGIX002()
Local oBrowse

//CRIAÇÃO DA MBROWSE
oBrowse:= FWMBrowse( ):New() //Instanciando a Classe
oBrowse:SetAlias("EJF") //Informando o Alias
oBrowse:SetMenuDef("LOGIX002") //Nome do fonte do MenuDef
oBrowse:SetDescription(TESX2Name("EJF")) //Descrição a ser apresentada no Browse
oBrowse:Activate()

Return Nil


*------------------------*
Static Function MenuDef()
*------------------------*                                   
Local aRotina := {}
//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE STR0001       ACTION "AxPesqui"              OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE STR0002       ACTION "VIEWDEF.LOGIX002"      OPERATION 2 ACCESS 0

Return aRotina
                  

*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel
Local oStruEJF := FWFormStruct(1,"EJF",,)//Capa
Local oStruEJI := FWFormStruct(1,"EJI",,) 
Local oStruEJJ := FWFormStruct(1,"EJJ",,) 
Local oStruEJK := FWFormStruct(1,"EJK",,) 
Local oStruEJT := FWFormStruct(1,"EJT",,)
Local oStruEJV := FWFormStruct(1,"EJV",,)

Local bCommit  := { |oMdl| .T./*CommitLink(oMdl)*/}

oModel := MPFormModel():New( "LOGIX002", /*bGridValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )                                                                               
oModel:AddFields( "EJFMASTER",/*nOwner*/,oStruEJF)

oModel:AddGrid("EJIDETAIL", "EJFMASTER", oStruEJI, /*bLinePre*/, /* bLinePos*/ , /*bPreVal*/,/*bPosVal*/,/*BLoad*/ )
oModel:AddGrid("EJJDETAIL", "EJFMASTER", oStruEJJ, /*bLinePre*/, /* bLinePos*/ , /*bPreVal*/,/*bPosVal*/,/*BLoad*/ )
oModel:AddGrid("EJKDETAIL", "EJFMASTER", oStruEJK, /*bLinePre*/, /* bLinePos*/ , /*bPreVal*/,/*bPosVal*/,/*BLoad*/ )
oModel:AddGrid("EJTDETAIL", "EJFMASTER", oStruEJT, /*bLinePre*/, /* bLinePos*/ , /*bPreVal*/,/*bPosVal*/,/*BLoad*/ )
oModel:AddGrid("EJVDETAIL", "EJFMASTER", oStruEJV, /*bLinePre*/, /* bLinePos*/ , /*bPreVal*/,/*bPosVal*/,/*BLoad*/ ) 

oModel:SetRelation("EJIDETAIL",{{"EJI_FILIAL", "xFilial('EJI')"}, {"EJI_CODEMP", "EJF_CODEMP"}, {"EJI_NUMFAT" , "EJF_NUMFAT"},{"EJI_CODEMB" , "EJF_CODEMB"}} , EJI->(IndexKey(2)))
oModel:SetRelation("EJJDETAIL",{{"EJJ_FILIAL", "xFilial('EJJ')"}, {"EJJ_CODEMP", "EJF_CODEMP"}, {"EJJ_NUMFAT" , "EJF_NUMFAT"},{"EJJ_CODEMB" , "EJF_CODEMB"}} , EJJ->(IndexKey(1)))
oModel:SetRelation("EJKDETAIL",{{"EJK_FILIAL", "xFilial('EJK')"}, {"EJK_CODEMP", "EJF_CODEMP"}, {"EJK_NUMFAT" , "EJF_NUMFAT"},{"EJK_CODEMB" , "EJF_CODEMB"}} , EJK->(IndexKey(1)))
oModel:SetRelation("EJTDETAIL",{{"EJT_FILIAL", "xFilial('EJT')"}, {"EJT_CODEMP", "EJF_CODEMP"}, {"EJT_NUMFAT" , "EJF_NUMFAT"},{"EJT_CODEMB" , "EJF_CODEMB"}} , EJT->(IndexKey(1)))
oModel:SetRelation("EJVDETAIL",{{"EJV_FILIAL", "xFilial('EJV')"}, {"EJV_CODEMP", "EJF_CODEMP"}, {"EJV_NUMFAT" , "EJF_NUMFAT"},{"EJV_CODEMB" , "EJF_CODEMB"}} , EJV->(IndexKey(1)))

oModel:GetModel("EJIDETAIL"):SetUniqueLine({"EJI_CODEMP","EJI_NUMFAT","EJI_CODEMB","EJI_NUMNOT","EJI_NSEQNF"})
oModel:GetModel("EJJDETAIL"):SetUniqueLine({"EJJ_CODEMP","EJJ_NUMFAT","EJJ_CODEMB","EJJ_CODSEQ"})
oModel:GetModel("EJKDETAIL"):SetUniqueLine({"EJK_CODEMP","EJK_NUMFAT","EJK_CODEMB","EJK_CODAGE","EJK_CODTIP"})
oModel:GetModel("EJTDETAIL"):SetUniqueLine({"EJT_CODEMP","EJT_NUMFAT","EJT_CODEMB","EJT_NUMPAR"})
oModel:GetModel("EJVDETAIL"):SetUniqueLine({"EJV_CODEMP","EJV_NUMFAT","EJV_CODEMB","EJV_NUMPAR","EJV_CODPAG"})
 
//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(TESX2Name("EJF") ) //"Vendas para Exportadores"
oModel:GetModel("EJFMASTER"):SetDescription( "MATERIA" ) //##'Dados da Capa'    
oModel:GetModel("EJIDETAIL"):SetDescription(TESX2Name("EJI")) //Título do Detalhe  
oModel:GetModel("EJJDETAIL"):SetDescription(TESX2Name("EJJ")) //Título do Detalhe  
oModel:GetModel("EJKDETAIL"):SetDescription(TESX2Name("EJK")) //Título do Detalhe  
oModel:GetModel("EJTDETAIL"):SetDescription(TESX2Name("EJT")) //Título do Detalhe  
oModel:GetModel("EJVDETAIL"):SetDescription(TESX2Name("EJV")) //Título do Detalhe  

Return oModel


*------------------------*
Static Function ViewDef()
*------------------------*
Local oModel   := FWLoadModel("LOGIX002")
Local oStruEJF := FWFormStruct(2,"EJF",,) 
Local oStruEJI := FWFormStruct(2,"EJI",,)
Local oStruEJJ := FWFormStruct(2,"EJJ",,)
Local oStruEJK := FWFormStruct(2,"EJK",,)
Local oStruEJT := FWFormStruct(2,"EJT",,)
Local oStruEJV := FWFormStruct(2,"EJV",,)

Local oView

oView := FWFormView():New()
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_EJF", oStruEJF, "EJFMASTER")

oView:AddGrid ("VIEW_EJI", oStruEJI, "EJIDETAIL")
oView:AddGrid ("VIEW_EJJ", oStruEJJ, "EJJDETAIL")
oView:AddGrid ("VIEW_EJK", oStruEJK, "EJKDETAIL")
oView:AddGrid ("VIEW_EJT", oStruEJT, "EJTDETAIL")
oView:AddGrid ("VIEW_EJV", oStruEJV, "EJVDETAIL")

oView:CreateFolder( 'PASTAS'   )
oView:CreateFolder( 'PASTAS01' )

oView:AddSheet( 'PASTAS', 'ABA01', STR0003  ) 
oView:AddSheet( 'PASTAS', 'ABA02', STR0004  )
oView:AddSheet( 'PASTAS', 'ABA03', STR0005  )
oView:AddSheet( 'PASTAS', 'ABA04', STR0006  )
oView:AddSheet( 'PASTAS', 'ABA05', STR0007  )
oView:AddSheet( 'PASTAS', 'ABA06', STR0008  )

oView:CreateHorizontalBox('CAPA'     ,100,,,'PASTAS','ABA01')
oView:CreateHorizontalBox('DETALHE01',100,,,'PASTAS','ABA02')
oView:CreateHorizontalBox('DETALHE02',100,,,'PASTAS','ABA03')
oView:CreateHorizontalBox('DETALHE03',100,,,'PASTAS','ABA04')
oView:CreateHorizontalBox('DETALHE04',100,,,'PASTAS','ABA05')
oView:CreateHorizontalBox('DETALHE05',100,,,'PASTAS','ABA06')


oView:SetOwnerView( "VIEW_EJF" , 'CAPA'      )    
oView:SetOwnerView( "VIEW_EJI" , 'DETALHE01' )
oView:SetOwnerView( "VIEW_EJJ" , 'DETALHE02' )
oView:SetOwnerView( "VIEW_EJK" , 'DETALHE03' )
oView:SetOwnerView( "VIEW_EJT" , 'DETALHE04' )
oView:SetOwnerView( "VIEW_EJV" , 'DETALHE05' )

//Remove Campo da View
oStruEJI:RemoveField("EJI_CODEMP")
oStruEJI:RemoveField("EJI_DSCEMP")
oStruEJI:RemoveField("EJI_NUMFAT")
oStruEJI:RemoveField("EJI_CODEMB")

oStruEJJ:RemoveField("EJJ_CODEMP")
oStruEJJ:RemoveField("EJJ_DSCEMP")
oStruEJJ:RemoveField("EJJ_NUMFAT")
oStruEJJ:RemoveField("EJJ_CODEMB")

oStruEJK:RemoveField("EJK_CODEMP")
oStruEJK:RemoveField("EJK_DSCEMP")
oStruEJK:RemoveField("EJK_NUMFAT")
oStruEJK:RemoveField("EJK_CODEMB")

oStruEJT:RemoveField("EJT_CODEMP")
oStruEJT:RemoveField("EJT_DSCEMP")
oStruEJT:RemoveField("EJT_NUMFAT")
oStruEJT:RemoveField("EJT_CODEMB")

oStruEJV:RemoveField("EJV_CODEMP")
oStruEJV:RemoveField("EJV_DSCEMP")
oStruEJV:RemoveField("EJV_NUMFAT")
oStruEJV:RemoveField("EJV_CODEMB")

// Liga a identificação do componente
oView:EnableTitleView( "VIEW_EJF",STR0003 , RGB(240, 248, 255 ))
oView:EnableTitleView( "VIEW_EJI",STR0004 , RGB(240, 248, 255 ))
oView:EnableTitleView( "VIEW_EJJ",STR0005 , RGB(240, 248, 255 ))
oView:EnableTitleView( "VIEW_EJK",STR0006 , RGB(240, 248, 255 ))
oView:EnableTitleView( "VIEW_EJT",STR0007 , RGB(240, 248, 255 ))
oView:EnableTitleView( "VIEW_EJV",STR0008 , RGB(240, 248, 255 ))

oView:EnableControlBar(.T.) //Habilita ButtonsBar

Return oView