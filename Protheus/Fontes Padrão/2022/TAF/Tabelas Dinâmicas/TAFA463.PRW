#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA463.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA463
Cadastro MVC dos Países do banco central/SISCOMEX

@author Marcos.Vecki	
@since 24/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA463()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Recipiente GLP
oBrw:SetAlias( 'T5E')
oBrw:SetMenuDef( 'TAFA463' )
oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcos.Vecki	
@since 24/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA463" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcos.Vecki	
@since 24/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruT5E 	:= 	FWFormStruct( 1, 'T5E' )
Local oModel 	:= 	MPFormModel():New( 'TAFA463' )

oModel:AddFields('MODEL_T5E', /*cOwner*/, oStruT5E)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcos.Vecki	
@since 24/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA463' )
Local 	oStruT5E 	:= 	FWFormStruct( 2, 'T5E' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_T5E', oStruT5E, 'MODEL_T5E' )

oView:EnableTitleView( 'VIEW_T5E', STR0001 ) //Cadastro de Recipiente GLP
oView:CreateHorizontalBox( 'FIELDST5E', 100 )
oView:SetOwnerView( 'VIEW_T5E', 'FIELDST5E' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@author Marcos.Vecki	
@since 24/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1012

If nVerEmp < nVerAtu
	aAdd( aHeader, "T5E_FILIAL" )
	aAdd( aHeader, "T5E_ID" )
	aAdd( aHeader, "T5E_CODIGO" )
	aAdd( aHeader, "T5E_VASILH" )
	aAdd( aHeader, "T5E_DATINI" )
	aAdd( aHeader, "T5E_DATFIN" )

	aAdd( aBody, { "", "066eef2a-c30a-42b1-133f-e28b9f45a694", "14", "A Granel"   		  , "200501", "" 		} )
	aAdd( aBody, { "", "222405ce-2529-a3d6-b9ab-7680ad6392f3", "11", "Acima de 190 kg"    , "200409", "" 		} )
	aAdd( aBody, { "", "62e74698-602a-d218-cac6-bef8f3063905", "12", "Vasilhame de 10 kg" , "200410", "" 		} )
	aAdd( aBody, { "", "4da05a45-d3d1-46bc-0a81-ba5643a22ef4", "15", "Vasilhame de 125 kg", "201512", "" 		} )
	aAdd( aBody, { "", "45cc30ff-035a-f917-ef3c-978d67106fe5", "06", "Vasilhame de 13 kg" , "200409", "" 		} )
	aAdd( aBody, { "", "e2ae6b31-2f94-a68d-4c09-2ba1f7fbd2d1", "13", "Vasilhame de 16 kg" , "200410", "" 		} )
	aAdd( aBody, { "", "540f7fa0-c45f-d7e0-fba9-0e68468e399d", "10", "Vasilhame de 190 kg", "200409", "" 		} )
	aAdd( aBody, { "", "7a9d2658-34b8-463f-653c-74a0b888c2f0", "01", "Vasilhame de 2 kg"  , "200409", "" 		} )
	aAdd( aBody, { "", "83b8a8ef-c470-c711-714b-3c89d3fd3b35", "07", "Vasilhame de 20 kg" , "200409", "" 		} )
	aAdd( aBody, { "", "95bd25ed-ee5e-516e-933f-7473ae080667", "16", "Vasilhame de 250 kg", "201606", "" 		} )
	aAdd( aBody, { "", "2de0d7c8-b785-2d96-fe06-356a1167f6f0", "08", "Vasilhame de 45 kg" , "200409", "" 		} )
	aAdd( aBody, { "", "0eda990a-d85f-799b-1398-798ed8386b37", "02", "Vasilhame de 5 kg"  , "200409", "" 		} )
	aAdd( aBody, { "", "3a94c5b9-def3-40ff-35fe-9e7d78faacff", "03", "Vasilhame de 7 kg"  , "200409", "" 		} )
	aAdd( aBody, { "", "ddb0d41d-6457-e390-615a-b17673bc99ab", "04", "Vasilhame de 8 kg"  , "200409", "" 		} )
	aAdd( aBody, { "", "8814698b-6d4e-5def-061f-9d0af07c6720", "05", "Vasilhame de 9 kg"  , "200409", "" 		} )
	aAdd( aBody, { "", "7d55413e-0144-96c1-822c-a21104f4a0d5", "09", "Vasilhame de 90 kg" , "200409", "" 		} )
	
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )