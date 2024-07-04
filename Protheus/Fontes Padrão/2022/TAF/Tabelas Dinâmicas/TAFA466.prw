#INCLUDE "Protheus.CH"
#INCLUDE "FwMVCDef.CH"
#INCLUDE "TAFA466.CH"

Static lLaySimplif := taflayEsoc("S_01_00_00")
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA466

e-Social: Layout 1.0: Motivos de Cessação de Benefícios - Tabela 26
Layout 2.5: Motivos de Cessação de Benefícios Previdenciários
@Author	Paulo V.B. Santana
@Since		05/01/2017
@Version	1.0
 
/*/
//------------------------------------------------------------------
Function TAFA466()

Local oBrw := FWmBrowse():New()

If lLaySimplif
	oBrw:SetDescription( STR0002 ) //" Motivos de Cessação de Benefícios"
Else
	oBrw:SetDescription( STR0001 ) //" Motivos de Cessação de Benefícios Previdenciários"
EndIf 

oBrw:SetAlias( "T5H" )
oBrw:SetMenuDef( "TAFA466" )
T5H->( DBSetOrder( 1 ) )
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@Author	Paulo V.B. Santana
@Since		05/01/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return xFunMnuTAF( "TAFA466",,,, .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@Return oModel - Objeto do Modelo MVC

@Author	Paulo V.B. Santana
@Since		05/01/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruT5H := FwFormStruct( 1, "T5H" )
Local oModel   := MpFormModel():New( "TAFA466" )

oModel:AddFields( "MODEL_T5H", /*cOwner*/, oStruT5H )
oModel:GetModel ( "MODEL_T5H" ):SetPrimaryKey( { "T5H_FILIAL", "T5H_ID" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@Return oView - Objeto da View MVC

@Author	Paulo V.B. Santana
@Since		05/01/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel( "TAFA466" )
Local oStruT5H := FwFormStruct( 2, "T5H" )
Local oView    := FwFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_T5H", oStruT5H, "MODEL_T5H" )

If lLaySimplif
	oView:EnableTitleView( "VIEW_T5H", STR0002 ) //" Motivos de Cessação de Benefícios"
Else
	oView:EnableTitleView( "VIEW_T5H", STR0001 ) //" Motivos de Cessação de Benefícios Previdenciários"
EndIf 

oView:CreateHorizontalBox( "FIELDST5H", 100 )
oView:SetOwnerView( "VIEW_T5H", "FIELDST5H" )

Return( oView )


//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida:
T5H - (Tipos Benef. Previdenciários  ) 
Tipos de Benefícios Previdenciários dos Regimes Próprios de Previdência

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Paulo Vilas Boas Santana
@Since		05/01/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1031.26

If nVerEmp < nVerAtu
	aAdd( aHeader, "T5H_FILIAL" )
	aAdd( aHeader, "T5H_ID" )
	aAdd( aHeader, "T5H_CODIGO" )
	aAdd( aHeader, "T5H_DESCRI" )
	aAdd( aHeader, "T5H_VALIDA" )

	aAdd( aBody, { " ", "000001","01","ÓBITO", " " } )
	aAdd( aBody, { " ", "000002","02","REVERSÃO", " " } )
	aAdd( aBody, { " ", "000003","03","POR DECISÃO JUDICIAL", " " } )
	aAdd( aBody, { " ", "000004","04","CASSAÇÃO", " " } )
	aAdd( aBody, { " ", "000005","05","TÉRMINO DO PRAZO DO BENEFÍCIO", " " } )
	aAdd( aBody, { " ", "000006","06","EXTINÇÃO DE QUOTA", " " } )
	aAdd( aBody, { " ", "000007","07","NÃO HOMOLOGADO PELO TRIBUNAL DE CONTAS", " " } )
	aAdd( aBody, { " ", "000008","08","RENÚNCIA EXPRESSA", " " } )

	//1.0

	aAdd( aBody, { " ", "000009","09","TRANSFERÊNCIA DE ÓRGÃO ADMINISTRADOR", " " } )
	aAdd( aBody, { " ", "000010","10","MUDANÇA DE CPF DO BENEFICIÁRIO", " " } )
	aAdd( aBody, { " ", "000011","11","NÃO RECADASTRAMENTO", " " } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )