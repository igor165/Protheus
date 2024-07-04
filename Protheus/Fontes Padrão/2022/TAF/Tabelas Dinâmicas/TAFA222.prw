#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA222.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA222
Cadastro MVC de Códigos X Siglas X Alíquotas de Outras Entidades e Fundos

@author Anderson Costa
@since 08/08/2013
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA222()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001)    //"Cadastro de Códigos X Siglas X Alíquotas de Outras Entidades e Fundos"
oBrw:SetAlias( 'C8G')
oBrw:SetMenuDef( 'TAFA222' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Anderson Costa
@since 08/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA222" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Anderson Costa
@since 08/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC8G  :=  FWFormStruct( 1, 'C8G' )
Local oModel    :=  MPFormModel():New( 'TAFA222' )

oModel:AddFields('MODEL_C8G', /*cOwner*/, oStruC8G)
oModel:GetModel('MODEL_C8G'):SetPrimaryKey({'C8G_FILIAL', 'C8G_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Anderson Costa
@since 08/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA222' )
Local   oStruC8G    :=  FWFormStruct( 2, 'C8G' )
Local   oView       :=  FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C8G', oStruC8G, 'MODEL_C8G' )

oView:EnableTitleView( 'VIEW_C8G', STR0001 )    //"Cadastro de Códigos X Siglas X Alíquotas de Outras Entidades e Fundos"
oView:CreateHorizontalBox( 'FIELDSC8G', 100 )
oView:SetOwnerView( 'VIEW_C8G', 'FIELDSC8G' )

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

nVerAtu := 1005.03

If nVerEmp < nVerAtu
	aAdd( aHeader, "C8G_FILIAL" )
	aAdd( aHeader, "C8G_ID" )
	aAdd( aHeader, "C8G_CODIGO" )
	aAdd( aHeader, "C8G_SIGLA" )
	aAdd( aHeader, "C8G_ALIQ" )
	aAdd( aHeader, "C8G_VALIDA" )

	aAdd( aBody, { "", "000001", "0001", "SAL_EDUC", "2.5", "" } )
	aAdd( aBody, { "", "000002", "0002", "INCRA", "0.2", "" } )
	aAdd( aBody, { "", "000003", "0002", "INCRA", "2.7", "" } )
	aAdd( aBody, { "", "000004", "0004", "SENAI", "1", "" } )
	aAdd( aBody, { "", "000005", "0008", "SESI", "1.5", "" } )
	aAdd( aBody, { "", "000006", "0016", "SENAC", "1", "" } )
	aAdd( aBody, { "", "000007", "0032", "SESC", "1.5", "" } )
	aAdd( aBody, { "", "000008", "0064", "SEBRAE", "0.6", "" } )
	aAdd( aBody, { "", "000009", "0064", "SEBRAE", "0.3", "" } )
	aAdd( aBody, { "", "000010", "0128", "DPC", "2.5", "" } )
	aAdd( aBody, { "", "000011", "0256", "AERO", "2.5", "" } )
	aAdd( aBody, { "", "000012", "0512", "SENAR_PF", "0.2", "" } )
	aAdd( aBody, { "", "000013", "0512", "SENAR_PJ", "0.25", "" } )
	aAdd( aBody, { "", "000014", "0512", "SENAR_FP", "2.5", "" } )
	aAdd( aBody, { "", "000015", "1024", "SEST", "1.5", "" } )
	aAdd( aBody, { "", "000016", "2048", "SENAT", "1", "" } )
	aAdd( aBody, { "", "000017", "4096", "SESCOOP", "2.5", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )