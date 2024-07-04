#INCLUDE "Protheus.CH"
#INCLUDE "FwMVCDef.CH"
#INCLUDE "TAFA427.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA427 

Cadastro MVC de Informações de identificação do registrador da CAT

@Author	Mick William da Silva
@Since		25/02/2016
@Version	1.0
 
/*/
//------------------------------------------------------------------
Function TAFA427()

Local oBrw := FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Informações de identificação do registrador da CAT"
oBrw:SetAlias( "T0I" )
oBrw:SetMenuDef( "TAFA427" )
T0I->( DBSetOrder( 2 ) )
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@Author	Mick William da Silva
@Since		25/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return xFunMnuTAF( "TAFA427",,,, .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@Return oModel - Objeto do Modelo MVC

@Author	Mick William da Silva
@Since		25/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruT0I := FwFormStruct( 1, "T0I" )
Local oModel   := MpFormModel():New( "TAFA427" )

oModel:AddFields( "MODEL_T0I", /*cOwner*/, oStruT0I )
oModel:GetModel ( "MODEL_T0I" ):SetPrimaryKey( { "T0I_FILIAL", "T0I_ID" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@Return oView - Objeto da View MVC

@Author	Mick William da Silva
@Since		25/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel( "TAFA427" )
Local oStruT0I := FwFormStruct( 2, "T0I" )
Local oView    := FwFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_T0I", oStruT0I, "MODEL_T0I" )
oView:EnableTitleView( "VIEW_T0I", STR0001 ) //"Informações de identificação do registrador da CAT"
oView:CreateHorizontalBox( "FIELDST0I", 100 )
oView:SetOwnerView( "VIEW_T0I", "FIELDST0I" )

oStruT0I:RemoveField( "T0I_ID" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida:
T0I - (Info. iden. registrador da CAT) 
Informações de identificação do registrador da CAT

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Mick William da Silva
@Since		25/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1015

If nVerEmp < nVerAtu
	aAdd( aHeader, "T0I_FILIAL" )
	aAdd( aHeader, "T0I_ID" )
	aAdd( aHeader, "T0I_CODIGO" )
	aAdd( aHeader, "T0I_DESCRI" )
	aAdd( aHeader, "T0I_VALIDA" )

	aAdd( aBody, { "", "000001", "1", "EMPREGADOR", "" } )
	aAdd( aBody, { "", "000002", "2", "COOPERATIVA", "" } )
	aAdd( aBody, { "", "000003", "3", "SINDICATO DE TRABALHADORES AVULSOS NÃO PORTUÁRIOS", "" } )
	aAdd( aBody, { "", "000004", "4", "ÓRGÃO GESTOR DE MÃO DE OBRA", "" } )
	aAdd( aBody, { "", "000005", "5", "EMPREGADO", "" } )
	aAdd( aBody, { "", "000006", "6", "DEPENDENTE DO EMPREGADO", "" } )
	aAdd( aBody, { "", "000007", "7", "ENTIDADE SINDICAL COMPETENTE", "" } )
	aAdd( aBody, { "", "000008", "8", "MÉDICO ASSISTENTE", "" } )
	aAdd( aBody, { "", "000009", "9", "AUTORIDADE PÚBLICA", "" } )


	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )