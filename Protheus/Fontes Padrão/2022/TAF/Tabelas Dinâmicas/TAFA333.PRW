#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA333.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA333
Cadastro MVC de Tipo de Registros - Bloco X 

@author Denis R de Oliveira
@since 14/05/2014
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA333()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001)    //"Cadastro de Tipo de Registros - Bloco X"
oBrw:SetAlias( 'CFU')
oBrw:SetMenuDef( 'TAFA333' )
CFU->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Denis R de Oliveira
@since 14/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA333" ,,,,.T. )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis R de Oliveira
@since 14/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCFU  :=  FWFormStruct( 1, 'CFU' )
Local oModel    :=  MPFormModel():New( 'TAFA333' )

oModel:AddFields('MODEL_CFU', /*cOwner*/, oStruCFU)
oModel:GetModel('MODEL_CFU'):SetPrimaryKey({'CFU_FILIAL','CFU_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis R de Oliveira
@since 14/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA333' )
Local   oStruCFU    :=  FWFormStruct( 2, 'CFU' )
Local   oView       :=  FWFormView():New()  

oStruCFU:RemoveField('CFU_ID')

oView:SetModel( oModel )
oView:AddField( 'VIEW_CFU', oStruCFU, 'MODEL_CFU' )

oView:EnableTitleView( 'VIEW_CFU', STR0001 )    //"Cadastro de Tipo de Registros - Bloco X"
oView:CreateHorizontalBox( 'FIELDSCFU', 100 )
oView:SetOwnerView( 'VIEW_CFU', 'FIELDSCFU' )

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
	aAdd( aHeader, "CFU_FILIAL" )
	aAdd( aHeader, "CFU_ID" )
	aAdd( aHeader, "CFU_CODIGO" )
	aAdd( aHeader, "CFU_DESCRI" )
	aAdd( aHeader, "CFU_DTINI" )
	aAdd( aHeader, "CFU_DTFIN" )

	aAdd( aBody, { "", "029c92f0-f514-12eb-fda9-216423b74316", "X390", "ORIGEM E APLICACAO DE RECURSOS - IMUNES E ISENTAS", "20130101", "" } )
	aAdd( aBody, { "", "1a865869-138a-3087-4c0e-d0ba67db3f17", "X291", "OPERACOES COM O EXTERIOR - PESSOA VINCULADA/INTERPOSTA/PAIS COM TRIBUTACAO FAVORECIDA", "20130101", "" } )
	aAdd( aBody, { "", "22aabc94-fb91-8d61-b089-7a6b1044540d", "X400", "COMERCIO ELETRONICO E TECNOLOGIA DA INFORMACAO", "20130101", "" } )
	aAdd( aBody, { "", "332134ff-2491-c940-2d08-b7645e95b022", "X490", "POLO INDUSTRIAL DE MANAUS E AMAZONIA OCIDENTAL", "20130101", "" } )
	aAdd( aBody, { "", "50e3b133-65e6-4c54-6648-5fc03603ece1", "X480", "REPES, RECAP, PADIS, PATVD, REIDI, REPENEC, REICOMP, RETAERO, RECINE, RESIDUOS SOLIDOS, RECOPA, COPA DO MUNDO, RETID, REPNBL-REDES, REIF E OLIMPIADAS", "20130101", "" } )
	aAdd( aBody, { "", "6fdd4fee-6005-885e-f689-1fcf2ed17a03", "X460", "INOVACAO TECNOLOGICA E DESENVOLVIMENTO TECNOLOGICO", "20130101", "" } )
	aAdd( aBody, { "", "77b6c472-05aa-a11c-8b28-16b0f25d2008", "X470", "CAPACITACAO DE INFORMATICA E INCLUSAO DIGITAL", "20130101", "" } )
	aAdd( aBody, { "", "83c2500a-150e-a4c8-43eb-c8064fc52e3c", "X510", "AREAS DE LIVRE COMERCIO (ALC)", "20130101", "" } )
	aAdd( aBody, { "", "8a53c053-3403-3335-de15-07395172961b", "X292", "OPERACOES COM O EXTERIOR - PESSOA NAO VINCULADA/NAO INTERPOSTA/PAIS SEM TRIBUTACAO FAVORECIDA", "20130101", "" } )
	aAdd( aBody, { "", "c18f309c-caa2-7a99-6f23-d1604b23a881", "X500", "ZONAS DE PROCESSAMENTO DE EXPORTACAO (ZPE)", "20130101", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )