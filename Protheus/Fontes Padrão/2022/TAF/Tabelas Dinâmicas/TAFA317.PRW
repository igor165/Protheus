#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA317.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA317
Cadastro MVC de Qualificação do Assinante 

@author Denis R de Oliveira
@since 03/04/2014
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA317()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001)    //"Cadastro da Qualificação do Assinante"
oBrw:SetAlias( 'CW4')
oBrw:SetMenuDef( 'TAFA317' )
CW4->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Denis R de Oliveira
@since 03/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA317" ,,,,.T. )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis R de Oliveira
@since 03/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCW4  :=  FWFormStruct( 1, 'CW4' )
Local oModel    :=  MPFormModel():New( 'TAFA317' )

oModel:AddFields('MODEL_CW4', /*cOwner*/, oStruCW4)
oModel:GetModel('MODEL_CW4'):SetPrimaryKey({'CW4_FILIAL','CW4_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis R de Oliveira
@since 03/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA317' )
Local   oStruCW4    :=  FWFormStruct( 2, 'CW4' )
Local   oView       :=  FWFormView():New() 

oStruCW4:RemoveField('CW4_ID')

oView:SetModel( oModel )
oView:AddField( 'VIEW_CW4', oStruCW4, 'MODEL_CW4' )

oView:EnableTitleView( 'VIEW_CW4', STR0001 )    //"Cadastro da Qualificação do Assinante"
oView:CreateHorizontalBox( 'FIELDSCW4', 100 )
oView:SetOwnerView( 'VIEW_CW4', 'FIELDSCW4' )

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
	aAdd( aHeader, "CW4_FILIAL" )
	aAdd( aHeader, "CW4_ID" )
	aAdd( aHeader, "CW4_CODIGO" )
	aAdd( aHeader, "CW4_DESCRI" )
	aAdd( aHeader, "CW4_DTINI" )
	aAdd( aHeader, "CW4_DTFIN" )

	aAdd( aBody, { "", "d289f370-5443-bfe9-2c35-31d24b4dab8f", "203", "DIRETOR", "20130101", "" } )
	aAdd( aBody, { "", "7ef1b008-41b6-cb13-dc82-289e6e68fd4a", "204", "CONSELHEIRO DE ADMINISTRACAO", "20130101", "" } )
	aAdd( aBody, { "", "f67f103d-b699-511b-857e-75ee6a24cdeb", "205", "ADMINISTRADOR", "20130101", "" } )
	aAdd( aBody, { "", "7c8c5e05-fcc5-823f-f1b2-aad015cdabfb", "206", "ADMINISTRADOR DO GRUPO", "20130101", "" } )
	aAdd( aBody, { "", "66163fca-d5ff-6c7d-cffa-671929157274", "207", "ADMINISTRADOR DE SOCIEDADE FILIADA", "20130101", "" } )
	aAdd( aBody, { "", "f828bf8a-d16b-32b8-9553-6a88404e00c1", "220", "ADMINISTRADOR JUDICIAL - PESSOA FISICA", "20130101", "" } )
	aAdd( aBody, { "", "6ecf9221-b205-4b69-da2a-78b8782d0216", "222", "ADMINISTRADOR JUDICIAL - PESSOA JURIDICA - PROFISSIONAL RESPONSAVEL", "20130101", "" } )
	aAdd( aBody, { "", "057e9e5b-f9b2-17b6-b00a-27d88a135c02", "223", "ADMINISTRADOR JUDICIAL/GESTOR", "20130101", "" } )
	aAdd( aBody, { "", "eeaa1951-a83c-5605-9d9e-061a539aef71", "226", "GESTOR JUDICIAL", "20130101", "" } )
	aAdd( aBody, { "", "23eb26b3-ce0a-9d37-5218-0e664e747ce2", "309", "PROCURADOR", "20130101", "" } )
	aAdd( aBody, { "", "868e40e1-56c6-218a-4353-975f6b4493c0", "312", "INVENTARIANTE", "20130101", "" } )
	aAdd( aBody, { "", "3f72fe44-2c37-207e-2be2-b3e55519ca26", "313", "LIQUIDANTE", "20130101", "" } )
	aAdd( aBody, { "", "b0cfd793-1113-51eb-1c87-0609c037e390", "315", "INTERVENTOR", "20130101", "" } )
	aAdd( aBody, { "", "35a58a79-ef21-fa78-2682-6daa47c334bb", "401", "TITULAR PESSOA FISICA", "20130101", "" } )
	aAdd( aBody, { "", "b2c3e0dd-2c5c-8ed2-22fb-50f470fb0108", "801", "EMPRESARIO", "20130101", "" } )
	aAdd( aBody, { "", "4c66032c-404c-d097-f799-54efcea132d5", "900", "CONTADOR / CONTABILISTA", "20130101", "" } )
	aAdd( aBody, { "", "374581c5-d57f-5c6a-7790-74a78dfb1da3", "999", "OUTROS", "20130101", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )