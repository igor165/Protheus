#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA158.CH"                         
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA158
Cadastro MVC - Cadastro do Grupo de Classificacao do Item

@author Mauro A. Goncalves
@since 10/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA158()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Cadastro do Grupo de Cassificação do Item de Energia Elétrica e Comunicação/Telecomunicação"
oBrw:SetAlias( 'C0I')
oBrw:SetMenuDef( 'TAFA158' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 10/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA158" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 10/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC0I 	:= 	FWFormStruct( 1, 'C0I' )
Local oModel 	:= 	MPFormModel():New( 'TAFA158' )

oModel:AddFields('MODEL_C0I', /*cOwner*/, oStruC0I)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 10/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA158' )
Local 	oStruC0I 	:= 	FWFormStruct( 2, 'C0I' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0I', oStruC0I, 'MODEL_C0I' )

oView:EnableTitleView( 'VIEW_C0I', STR0001 ) //"Cadastro do Grupo de Cassificação do Item de Energia Elétrica e Comunicação/Telecomunicação"
oView:CreateHorizontalBox( 'FIELDSC0I', 100 )
oView:SetOwnerView( 'VIEW_C0I', 'FIELDSC0I' )

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
	aAdd( aHeader, "C0I_FILIAL" )
	aAdd( aHeader, "C0I_ID" )
	aAdd( aHeader, "C0I_CODIGO" )
	aAdd( aHeader, "C0I_DESCRI" )
	aAdd( aHeader, "C0I_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "Assinatura", "" } )
	aAdd( aBody, { "", "000002", "02", "Habilitacao", "" } )
	aAdd( aBody, { "", "000003", "03", "Servico Medido", "" } )
	aAdd( aBody, { "", "000004", "04", "Servico pre-pago", "" } )
	aAdd( aBody, { "", "000005", "05", "Outros Servicos", "" } )
	aAdd( aBody, { "", "000006", "06", "Energia Eletrica", "" } )
	aAdd( aBody, { "", "000007", "07", "Disponibilizacao de meios ou equipamentos", "" } )
	aAdd( aBody, { "", "000008", "08", "Cobrancas", "" } )
	aAdd( aBody, { "", "000009", "09", "Deducaes", "" } )
	aAdd( aBody, { "", "000010", "10", "Servico nao medido", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )