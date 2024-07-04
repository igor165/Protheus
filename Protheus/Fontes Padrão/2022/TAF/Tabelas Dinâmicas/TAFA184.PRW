#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA184.CH"                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA184
Cadastro MVC da Classe de Enquadramento do IPI

@author Gustavo G. Rueda
@since 16/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA184()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001)	//"Classe de Enquadramento do IPI"
oBrw:SetAlias( 'C3T')
oBrw:SetMenuDef( 'TAFA184' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Gustavo G. Rueda
@since 16/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA184" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Gustavo G. Rueda
@since 16/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC3T 	:= 	FWFormStruct( 1, 'C3T' )
Local oModel 	:= 	MPFormModel():New( 'TAFA184' )

oModel:AddFields('MODEL_C3T', /*cOwner*/, oStruC3T)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Gustavo G. Rueda
@since 16/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA184' )
Local 	oStruC3T 	:= 	FWFormStruct( 2, 'C3T' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C3T', oStruC3T, 'MODEL_C3T' )

oView:EnableTitleView( 'VIEW_C3T', STR0001 )	//"Classe de Enquadramento do IPI"
oView:CreateHorizontalBox( 'FIELDSC3T', 100 )
oView:SetOwnerView( 'VIEW_C3T', 'FIELDSC3T' )

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
	aAdd( aHeader, "C3T_FILIAL" )
	aAdd( aHeader, "C3T_ID" )
	aAdd( aHeader, "C3T_CODIGO" )
	aAdd( aHeader, "C3T_DESCRI" )
	aAdd( aHeader, "C3T_VALIDA" )

	aAdd( aBody, { "", "000031", "99999", "Outros produtos", "" } )
	aAdd( aBody, { "", "000007", "A", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000008", "B", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000009", "C", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000010", "D", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000011", "E", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000012", "F", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000013", "G", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000014", "H", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000001", "I", 'Cigarros (TIPI 24022000) - Art. 153 do Decreto 4.544/2002 ou Bebidas "Quentes" (TIPI 2204 / 2205 / 2206 / 2208) - Art. 149 do Decreto 4.544/2002', "" } )
	aAdd( aBody, { "", "000002", "II", "Cigarros (TIPI 24022000) - Art. 153 do Decreto 4.544/2002", "" } )
	aAdd( aBody, { "", "000003", "III-M", "Cigarros (TIPI 24022000) - Art. 153 do Decreto 4.544/2002", "" } )
	aAdd( aBody, { "", "000004", "III-R", "Cigarros (TIPI 24022000) - Art. 153 do Decreto 4.544/2002", "" } )
	aAdd( aBody, { "", "000005", "IV-M", "Cigarros (TIPI 24022000) - Art. 153 do Decreto 4.544/2002", "" } )
	aAdd( aBody, { "", "000006", "IV-R", "Cigarros (TIPI 24022000) - Art. 153 do Decreto 4.544/2002", "" } )
	aAdd( aBody, { "", "000015", "J", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000016", "K", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000017", "L", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000018", "M", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000019", "N", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000020", "O", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000021", "P", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000022", "Q", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000023", "R", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000024", "S", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000025", "T", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000026", "U", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000027", "V", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000028", "X", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000029", "Y", 'Bebidas "Quentes"', "" } )
	aAdd( aBody, { "", "000030", "Z", 'Bebidas "Quentes"', "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )