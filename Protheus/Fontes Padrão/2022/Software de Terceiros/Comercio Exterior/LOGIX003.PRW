#Include 'Protheus.ch'
#Include "Average.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "LOGIX003.CH"
/*
Programa   : LOGIX003
Objetivo   : Tela de Contrato de Cambio
Retorno    : Nil
Autor      : Fabio Satoru Yamamoto
Data/Hora  : 07/05/2012 - 10:00
Obs.       : 
*/
Function LOGIX003()
Local oBrowse

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse( ):New() //Instanciando a Classe
oBrowse:SetAlias("EJO") //Informando o Alias
oBrowse:SetMenuDef("LOGIX003") //Nome do fonte do MenuDef
oBrowse:SetDescription(TESX2Name("EJO")) //Descrição a ser apresentada no Browse
oBrowse:Activate()

Return Nil


*------------------------*
Static Function MenuDef()
*------------------------*                                   
Local aRotina := {}

//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE STR0001        ACTION "AxPesqui"         OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE STR0002        ACTION "VIEWDEF.LOGIX003" OPERATION 2 ACCESS 0

Return aRotina
                  

*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel
Local oStruEJO := FWFormStruct( 1 , "EJO",,)

Local oStruEJU := FWFormStruct(1,"EJU",,) 
Local oStruEJQ := FWFormStruct(1,"EJQ",,) 
Local oStruEJP := FWFormStruct(1,"EJP",,) 
Local oStruEJL := FWFormStruct(1,"EJL",,)
Local oStruEJR := FWFormStruct(1,"EJR",,)
Local oStruEJS := FWFormStruct(1,"EJS",,)

Local bCommit  := { |oMdl| .T./*CommitLink(oMdl)*/}

oModel := MPFormModel():New( "LOGIX003", /*bGridValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )                                                                               
oModel:AddFields( "EJOMASTER",/*nOwner*/,oStruEJO)

oModel:AddGrid("EJUDETAIL", "EJOMASTER", oStruEJU, /*bLinePre*/, /* bLinePos*/ , /*bPreVal*/,/*bPosVal*/,/*BLoad*/ )
oModel:AddGrid("EJQDETAIL", "EJOMASTER", oStruEJQ, /*bLinePre*/, /* bLinePos*/ , /*bPreVal*/,/*bPosVal*/,/*BLoad*/ )
oModel:AddGrid("EJPDETAIL", "EJOMASTER", oStruEJP, /*bLinePre*/, /* bLinePos*/ , /*bPreVal*/,/*bPosVal*/,/*BLoad*/ )
oModel:AddGrid("EJLDETAIL", "EJOMASTER", oStruEJL, /*bLinePre*/, /* bLinePos*/ , /*bPreVal*/,/*bPosVal*/,/*BLoad*/ )
oModel:AddGrid("EJRDETAIL", "EJOMASTER", oStruEJR, /*bLinePre*/, /* bLinePos*/ , /*bPreVal*/,/*bPosVal*/,/*BLoad*/ )
oModel:AddGrid("EJSDETAIL", "EJOMASTER", oStruEJS, /*bLinePre*/, /* bLinePos*/ , /*bPreVal*/,/*bPosVal*/,/*BLoad*/ )  

oModel:SetRelation("EJUDETAIL",{{"EJU_FILIAL", "xFilial('EJU')"}, {"EJU_CODEMP", "EJO_CODEMP"}, {"EJU_CODCON" , "EJO_CODCON"},{"EJU_CODBAN" , "EJO_CODBAN"}} , EJU->(IndexKey(2)))
oModel:SetRelation("EJQDETAIL",{{"EJQ_FILIAL", "xFilial('EJQ')"}, {"EJQ_CODEMP", "EJO_CODEMP"}, {"EJQ_CODCON" , "EJO_CODCON"},{"EJQ_CODBAN" , "EJO_CODBAN"}} , EJQ->(IndexKey(1)))
oModel:SetRelation("EJPDETAIL",{{"EJP_FILIAL", "xFilial('EJP')"}, {"EJP_CODEMP", "EJO_CODEMP"}, {"EJP_CODCON" , "EJO_CODCON"},{"EJP_CODBAN" , "EJO_CODBAN"}} , EJP->(IndexKey(1)))
oModel:SetRelation("EJLDETAIL",{{"EJL_FILIAL", "xFilial('EJL')"}, {"EJL_CODEMP", "EJO_CODEMP"}, {"EJL_CODCON" , "EJO_CODCON"},{"EJL_CODBAN" , "EJO_CODBAN"}} , EJL->(IndexKey(2)))
oModel:SetRelation("EJRDETAIL",{{"EJR_FILIAL", "xFilial('EJR')"}, {"EJR_CODEMP", "EJO_CODEMP"}, {"EJR_CODCON" , "EJO_CODCON"},{"EJR_CODBAN" , "EJO_CODBAN"}} , EJR->(IndexKey(1)))
oModel:SetRelation("EJSDETAIL",{{"EJS_FILIAL", "xFilial('EJS')"}, {"EJS_CODEMP", "EJO_CODEMP"}, {"EJS_CODCON" , "EJO_CODCON"},{"EJS_CODBAN" , "EJO_CODBAN"}} , EJS->(IndexKey(1)))

oModel:GetModel("EJUDETAIL"):SetUniqueLine({"EJU_CODEMP","EJU_NUMFAT","EJU_CODEMB","EJU_NUMPAR","EJU_DATAPL","EJU_CODCON","EJU_CODBAN","EJU_FLGAPL"})
oModel:GetModel("EJQDETAIL"):SetUniqueLine({"EJQ_CODEMP","EJQ_CODCON","EJQ_CODBAN","EJQ_NUMDES"})
oModel:GetModel("EJPDETAIL"):SetUniqueLine({"EJP_CODEMP","EJP_CODCON","EJP_CODBAN","EJP_DATINI"})
oModel:GetModel("EJLDETAIL"):SetUniqueLine({"EJL_CODEMP","EJL_NUMFAT","EJL_CODEMB","EJL_DSCAGE","EJL_CODCON","EJL_CODBAN","EJL_DATPAG"})
oModel:GetModel("EJRDETAIL"):SetUniqueLine({"EJR_CODEMP","EJR_CODCON","EJR_CODBAN","EJR_NUMFAT","EJR_CODEMB","EJR_NUMPAR"})
oModel:GetModel("EJSDETAIL"):SetUniqueLine({"EJS_CODEMP","EJS_CODCON","EJS_CODBAN","EJS_NUMFAT","EJS_CODEMB","EJS_NUMPAR","EJS_DATPAG"})
 
Return oModel


*------------------------*
Static Function ViewDef()
*------------------------*
Local oModel := FWLoadModel("LOGIX003")
Local oStruEJO := FWFormStruct(2,"EJO",,) 
Local oStruEJU := FWFormStruct(2,"EJU",,)
Local oStruEJQ := FWFormStruct(2,"EJQ",,)
Local oStruEJP := FWFormStruct(2,"EJP",,)
Local oStruEJL := FWFormStruct(2,"EJL",,)
Local oStruEJR := FWFormStruct(2,"EJR",,)
Local oStruEJS := FWFormStruct(2,"EJS",,)
Local oView

oView := FWFormView():New()
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_EJO", oStruEJO, "EJOMASTER")

oView:AddGrid ("VIEW_EJU", oStruEJU, "EJUDETAIL")
oView:AddGrid ("VIEW_EJQ", oStruEJQ, "EJQDETAIL")
oView:AddGrid ("VIEW_EJP", oStruEJP, "EJPDETAIL")
oView:AddGrid ("VIEW_EJL", oStruEJL, "EJLDETAIL")
oView:AddGrid ("VIEW_EJR", oStruEJR, "EJRDETAIL")
oView:AddGrid ("VIEW_EJS", oStruEJS, "EJSDETAIL")

oView:CreateFolder( 'PASTAS'   )
oView:CreateFolder( 'PASTAS01' )

oView:AddSheet( 'PASTAS', 'ABA01', STR0003 ) //'Contrato de Cambio'   ) 
oView:AddSheet( 'PASTAS', 'ABA02', STR0004 )//'Aplicações'           )
oView:AddSheet( 'PASTAS', 'ABA03', STR0005 )//'Despesas Contrato'    )
oView:AddSheet( 'PASTAS', 'ABA04', STR0006 )//'Adiantamento Contrato')
oView:AddSheet( 'PASTAS', 'ABA05', STR0007 )//'Pagamento Comissões'  )
oView:AddSheet( 'PASTAS', 'ABA06', STR0008 )//'Juros'                )
oView:AddSheet( 'PASTAS', 'ABA07', STR0009 )//'Pagamento Juros'      )

oView:CreateHorizontalBox('CAPA'     ,100,,,'PASTAS','ABA01')
oView:CreateHorizontalBox('DETALHE01',100,,,'PASTAS','ABA02')
oView:CreateHorizontalBox('DETALHE02',100,,,'PASTAS','ABA03')
oView:CreateHorizontalBox('DETALHE03',100,,,'PASTAS','ABA04')
oView:CreateHorizontalBox('DETALHE04',100,,,'PASTAS','ABA05')
oView:CreateHorizontalBox('DETALHE05',100,,,'PASTAS','ABA06')
oView:CreateHorizontalBox('DETALHE06',100,,,'PASTAS','ABA07')

oView:SetOwnerView( "VIEW_EJO" , 'CAPA'      )    
oView:SetOwnerView( "VIEW_EJU" , 'DETALHE01' )
oView:SetOwnerView( "VIEW_EJQ" , 'DETALHE02' )
oView:SetOwnerView( "VIEW_EJP" , 'DETALHE03' )
oView:SetOwnerView( "VIEW_EJL" , 'DETALHE04' )
oView:SetOwnerView( "VIEW_EJR" , 'DETALHE05' )
oView:SetOwnerView( "VIEW_EJS" , 'DETALHE06' )

oStruEJU:RemoveField("EJU_CODEMP")
oStruEJU:RemoveField("EJU_DSCEMP")
oStruEJU:RemoveField("EJU_CODCON")
oStruEJU:RemoveField("EJU_CODBAN")
oStruEJU:RemoveField("EJU_DSCBAN")

oStruEJQ:RemoveField("EJQ_CODEMP")
oStruEJQ:RemoveField("EJQ_DSCEMP")
oStruEJQ:RemoveField("EJQ_CODCON")
oStruEJQ:RemoveField("EJQ_CODBAN")
oStruEJQ:RemoveField("EJQ_DSCBAN")

oStruEJP:RemoveField("EJP_CODEMP")
oStruEJP:RemoveField("EJP_DSCEMP")
oStruEJP:RemoveField("EJP_CODCON")
oStruEJP:RemoveField("EJP_CODBAN")
oStruEJP:RemoveField("EJP_DSCBAN")

oStruEJL:RemoveField("EJL_CODEMP")
oStruEJL:RemoveField("EJL_DSCEMP")
oStruEJL:RemoveField("EJL_CODBAN")
oStruEJL:RemoveField("EJL_DSCBAN")

oStruEJR:RemoveField("EJR_CODEMP")
oStruEJR:RemoveField("EJR_DSCEMP")
oStruEJR:RemoveField("EJR_CODBAN")
oStruEJR:RemoveField("EJR_DSCBAN")

oStruEJS:RemoveField("EJS_CODEMP")
oStruEJS:RemoveField("EJS_DSCEMP")
oStruEJS:RemoveField("EJS_CODBAN")
oStruEJS:RemoveField("EJS_DSCBAN")

// Liga a identificação do componente
oView:EnableTitleView( "VIEW_EJO", STR0003 , RGB(240, 248, 255 ))
oView:EnableTitleView( "VIEW_EJU", STR0004 , RGB(240, 248, 255 ))
oView:EnableTitleView( "VIEW_EJQ", STR0005 , RGB(240, 248, 255 ))
oView:EnableTitleView( "VIEW_EJP", STR0006 , RGB(240, 248, 255 ))
oView:EnableTitleView( "VIEW_EJL", STR0007 , RGB(240, 248, 255 ))
oView:EnableTitleView( "VIEW_EJR", STR0008 , RGB(240, 248, 255 ))
oView:EnableTitleView( "VIEW_EJS", STR0009 , RGB(240, 248, 255 ))

oView:EnableControlBar(.T.) //Habilita ButtonsBar

Return oView 