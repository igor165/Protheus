#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"    
#INCLUDE "TAFA186.CH"                                     

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA186
Cadastro MVC - Cadastro de Dispositivo Autorizado

@author Rodrigo Aguilar
@since 22/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA186
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Cadastro de Dispositivo Autorizado"
oBrw:SetAlias( 'C6C' )
oBrw:SetMenuDef( 'TAFA186' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu                                                                                        

@author Rodrigo Aguilar
@since 22/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA186" )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 22/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()             

Local oStruC6C := FWFormStruct( 1, 'C6C' )

Local oModel 	:= 	MPFormModel():New( 'TAFA186' )
      
oModel:AddFields( 'MODEL_C6C', /*cOwner*/, oStruC6C )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 22/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA186' )
Local oStruC6C 	:= 	FWFormStruct( 2, 'C6C' ) //Dispositivos Autorizados

Local oView 	:= 	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C6C', oStruC6C, 'MODEL_C6C' )       
oView:EnableTitleView( 'VIEW_C6C', STR0001) //"Cadastro de Dispositivo Autorizado"

oView:CreateHorizontalBox( 'FIELDSC6C', 100 )          

oView:SetOwnerView( 'VIEW_C6C', 'FIELDSC6C' )

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

//Verifica se o dicionario aplicado é o da DIEF-CE e da Declan-RJ
If(AliasInDic("T30") .And. AliasInDic("T39"))
	nVerAtu := 1007
Else
	nVerAtu := 1003
EndIf

If nVerEmp < nVerAtu
	aAdd( aHeader, "C6C_FILIAL" )
	aAdd( aHeader, "C6C_ID" )
	aAdd( aHeader, "C6C_CODIGO" )
	aAdd( aHeader, "C6C_DESCRI" )
	aAdd( aHeader, "C6C_VALIDA" )

	aAdd( aBody, { "", "000001", "00", "FORMULARIO DE SEGURANCA – IMPRESSOR AUTONOMO", "" } )
	aAdd( aBody, { "", "000002", "01", "FS-DA – FORMULARIO DE SEGURANCA PARA IMPRESSAO DE DANFE", "" } )
	aAdd( aBody, { "", "000003", "02", "FORMULARIO DE SEGURANCA - NF-E", "" } )
	aAdd( aBody, { "", "000004", "03", "FORMULARIO CONTINUO", "" } )
	aAdd( aBody, { "", "000005", "04", "BLOCOS", "" } )
	aAdd( aBody, { "", "000006", "05", "JOGOS SOLTOS", "" } )
	
	//Verifica se o dicionario aplicado é o da DIEF-CE e da Declan-RJ
	If(AliasInDic("T30") .And. AliasInDic("T39"))
		aAdd( aBody, { "", "000007", "06", "ECF", "" } )
		aAdd( aBody, { "", "000008", "07", "CONHECIMENTO DE TRANSPORTE ELETRÔNICO", "" } )
	EndIf

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )