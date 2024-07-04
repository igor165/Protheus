#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA328.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA328
Cadastro MVC de Indicador de Projeto

@author Denis R de Oliveira
@since 15/05/2014
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA328()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001)    //"Cadastro de Indicador de Projeto"
oBrw:SetAlias( 'CFM')
oBrw:SetMenuDef( 'TAFA328' )
CFM->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Denis R de Oliveira
@since 15/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA328" ,,,,.T. )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis R de Oliveira
@since 15/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCFM  :=  FWFormStruct( 1, 'CFM' )
Local oModel    :=  MPFormModel():New( 'TAFA328' )

oModel:AddFields('MODEL_CFM', /*cOwner*/, oStruCFM)
oModel:GetModel('MODEL_CFM'):SetPrimaryKey({'CFM_FILIAL','CFM_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis R de Oliveira
@since 15/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA328' )
Local   oStruCFM    :=  FWFormStruct( 2, 'CFM' )
Local   oView       :=  FWFormView():New()

oStruCFM:RemoveField('CFM_ID')

oView:SetModel( oModel )
oView:AddField( 'VIEW_CFM', oStruCFM, 'MODEL_CFM' )

oView:EnableTitleView( 'VIEW_CFM', STR0001 )    //"Cadastro de Indicador de Projeto"
oView:CreateHorizontalBox( 'FIELDSCFM', 100 )
oView:SetOwnerView( 'VIEW_CFM', 'FIELDSCFM' )

Return oView 

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1003

If nVerEmp < nVerAtu
	aAdd( aHeader, "CFM_FILIAL" )
	aAdd( aHeader, "CFM_ID" )
	aAdd( aHeader, "CFM_CODIGO" )
	aAdd( aHeader, "CFM_DESCRI" )
	aAdd( aHeader, "CFM_DTINI" )
	aAdd( aHeader, "CFM_DTFIN" )

	aAdd( aBody, { "", "21d1ee7d-d255-8414-47ab-446bc0e82d9f", "00", "NAO PREENCHIDO", "20130101", "" } )
	aAdd( aBody, { "", "81bd589f-f9d3-9d7f-5826-d091ba29c006", "01", "NOVO EMPREENDIMENTO", "20130101", "" } )
	aAdd( aBody, { "", "63fe9a53-9ae1-c846-e263-811fcc497a01", "02", "MODERNIZACAO", "20130101", "" } )
	aAdd( aBody, { "", "729fd45f-69bb-6adf-3639-369ac38b4bc6", "03", "AMPLIACAO", "20130101", "" } )
	aAdd( aBody, { "", "985bf93d-3817-61b4-5bb6-03b76fcfe664", "04", "DIVERSIFICACAO", "20130101", "" } )
	aAdd( aBody, { "", "04c31407-9ead-1a14-1051-3bb7d946aa00", "05", "MANUTENCAO DO EMPREENDIMENTO", "20130101", "" } )
	aAdd( aBody, { "", "473b3167-affe-3925-4923-2e185cd41310", "06", "PROUNI", "20130101", "" } )
	aAdd( aBody, { "", "5b3080ab-04d9-d227-7f01-d0af81e246c0", "07", "PADIS", "20130101", "" } )
	aAdd( aBody, { "", "ffc6f69c-bedf-1b8b-301b-f194024e3ebd", "08", "EVENTOS FIFA", "20130101", "" } )
	aAdd( aBody, { "", "4468a47b-3be8-bbdd-e7ff-99c17e05a115", "09", "SERVICOS DA FIFA (SPE)", "20130101", "" } )
	aAdd( aBody, { "", "25fbe0d9-48e3-657f-b179-e1713abd19e5", "10", "EVENTOS CIO", "20130101", "" } )
	aAdd( aBody, { "", "84c2e69b-0c2e-e975-83da-b9adad71e851", "11", "SERVICOS DO CIO (SPE)", "20130101", "" } )
	aAdd( aBody, { "", "0f5aebea-223f-4989-dd25-f31509f33655", "99", "OUTROS", "20130101", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )