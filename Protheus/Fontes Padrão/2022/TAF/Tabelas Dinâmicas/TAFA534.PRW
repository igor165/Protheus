#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA534.CH" 

/*/{Protheus.doc} TAFA534
MVC DA TABELA AUTOCONTIDA "V3Q-RELAÇÃO DE DEPENDÊNCIA" 

@author Katielly Feitosa Rezende
@since 16/05/2019
@version 1.0
/*/

Function TAFA534()
Local	oBrw		:=	FWmBrowse():New()

If AliasIndic("V3Q")
    oBrw:SetDescription(STR0001)   //"Cadastros de Relação de Dependência"
    oBrw:SetAlias( 'V3Q')
    oBrw:SetMenuDef( 'TAFA534' )
    V3Q->(DbSetOrder(1))
    oBrw:Activate()
Else
	Alert(STR0003)  //"Tabela V3Q não existe." 
EndIF

Return

/*/{Protheus.doc} MenuDef
Funcao generica MVC para o menu

@author Katielly Feitosa Rezende
@since 16/05/2019
@version 1.0
/*/

Static Function MenuDef()
Return XFUNMnuTAF( "TAFA534" )

/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Katielly Feitosa Rezende
@since 16/05/2019
@version 1.0
/*/    

Static Function ModelDef()
Local oStrucV3Q := FWFormStruct(1, 'V3Q')
Local oModel    := MPFormModel():New('TAFA534')

oModel:AddFields('MODEL_V3Q', /*cOwner*/, oStrucV3Q)
oModel:GetModel('MODEL_V3Q'):SetPrimaryKey({'V3Q_FILIAL','V3Q_ID'})
Return oModel

/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Katielly Feitosa Rezende
@since 16/05/2019
@version 1.0
/*/

Static Function ViewDef()
Local oModel   := FWLoadModel('TAFA534')
Local oStruV3Q := FWFormStruct( 2, 'V3Q' )
Local oView    := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_V3Q', oStruV3Q, 'MODEL_V3Q' )

oView:EnableTitleView( 'VIEW_V3Q', STR0002 ) //"Relação de Dependência"  
oView:CreateHorizontalBox( 'FIELDSV3Q', 100 )
oView:SetOwnerView( 'VIEW_V3Q', 'FIELDSV3Q' )

Return oView	

/*/{Protheus.doc} FAtuCont
Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )
@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Autor Katielly Feitosa Rezende
@Since		16/05/2019
@Version	1.0
/*/

Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1028

If AliasIndic("V3Q")
	If nVerEmp < nVerAtu 
        aAdd( aHeader, "V3Q_FILIAL" )
        aAdd( aHeader, "V3Q_ID")  
        aAdd( aHeader, "V3Q_CODIGO")
        aAdd( aHeader, "V3Q_DESCRI")
        
        aAdd( aBody, {"", "000001", "1", "Neto, bisneto" })
        aAdd( aBody, {"", "000002", "2", "Irmão" })
        aAdd( aBody, {"", "000003", "3", "Cônjugue/companheiro" })
        aAdd( aBody, {"", "000004", "4", "Filho" })
        aAdd( aBody, {"", "000005", "5", "Pais, avós e bisavós" })
        aAdd( aBody, {"", "000006", "6", "Enteado" })
        aAdd( aBody, {"", "000007", "7", "Sogro" })
        aAdd( aBody, {"", "000008", "99", "Agregado/Outros" })

       aAdd( aRet, { aHeader, aBody } )
    EndIf  
EndIf  

Return( aRet )