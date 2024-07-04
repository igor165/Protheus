#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA023.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA023
Cadastro de Grupos de Tensão (Energia Elétrica)

@author Marcio Nunes
@since 10/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA023()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Grupos de Tensão (Energia Elétrica)
oBrw:SetAlias( 'C0N')
oBrw:SetMenuDef( 'TAFA023' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcio Nunes
@since 05/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA023" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 10/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC0N 	:= 	FWFormStruct( 1, 'C0N' )
Local oModel 	:= 	MPFormModel():New( 'TAFA023' )

oModel:AddFields('MODEL_C0N', /*cOwner*/, oStruC0N)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcio Nunes
@since 10/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA023' )
Local 	oStruC0N 	:= 	FWFormStruct( 2, 'C0N' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0N', oStruC0N, 'MODEL_C0N' )

oView:EnableTitleView( 'VIEW_C0N', STR0001 ) //Cadastro de Grupos de Tensão (Energia Elétrica)
oView:CreateHorizontalBox( 'FIELDSC0N', 100 )
oView:SetOwnerView( 'VIEW_C0N', 'FIELDSC0N' )

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
	aAdd( aHeader, "C0N_FILIAL" )
	aAdd( aHeader, "C0N_ID" )
	aAdd( aHeader, "C0N_CODIGO" )
	aAdd( aHeader, "C0N_DESCRI" )
	aAdd( aHeader, "C0N_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "A1 - ALTA TENSAO (230KV OU MAIS)", "" } )
	aAdd( aBody, { "", "000002", "02", "A2 - ALTA TENSAO (88 A 138KV)", "" } )
	aAdd( aBody, { "", "000003", "03", "A3 - ALTA TENSAO (69KV)", "" } )
	aAdd( aBody, { "", "000004", "04", "A3A - ALTA TENSAO (30KV A 44KV)", "" } )
	aAdd( aBody, { "", "000005", "05", "A4 - ALTA TENSAO (2,3KV A 25KV)", "" } )
	aAdd( aBody, { "", "000006", "06", "AS - ALTA TENSAO SUBTERR.NEO 06", "" } )
	aAdd( aBody, { "", "000007", "07", "B1 - RESIDENCIAL 07", "" } )
	aAdd( aBody, { "", "000008", "08", "B1 - RESIDENCIAL BAIXA RENDA 08", "" } )
	aAdd( aBody, { "", "000009", "09", "B2 - RURAL 09", "" } )
	aAdd( aBody, { "", "000010", "10", "B2 - COOPERATIVA DE ELETRIFICACAO RURAL", "" } )
	aAdd( aBody, { "", "000011", "11", "B2 - SERVICO P.BLICO DE IRRIGACAO", "" } )
	aAdd( aBody, { "", "000012", "12", "B3 - DEMAIS CLASSES", "" } )
	aAdd( aBody, { "", "000013", "13", "B4A - ILUMINACAO P.BLICA - REDE DE DISTRIBUICAO", "" } )
	aAdd( aBody, { "", "000014", "14", "B4B - ILUMINACAO P.BLICA - BULBO DE L.MPADA", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )