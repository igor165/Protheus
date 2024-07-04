#INCLUDE "Protheus.CH"
#INCLUDE "FwMVCDef.CH"
#INCLUDE "TAFA440.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA440
Cadastro MVC de Indicativo da matéria do processo ou alvará judicial

@Author	Evandro dos Santos Oliviera
@Since		23/05/2016
@Version	1.0

/*/
//------------------------------------------------------------------
Function TAFA440()

Local oBrw := FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Indicativo da matéria do processo ou alvará judicial"
oBrw:SetAlias( "LE7" )
oBrw:SetMenuDef( "TAFA440" )
LE7->( DBSetOrder( 2 ) )
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Cadastro MVC de Indicativo da matéria do processo ou alvará judicial

@Author	Evandro dos Santos Oliviera
@Since		23/05/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return xFunMnuTAF( "TAFA440",,,, .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@Return oModel - Objeto do Modelo MVC

@Author	Evandro dos Santos Oliviera
@Since		23/05/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruLE7 := FwFormStruct( 1, "LE7" )
Local oModel   := MpFormModel():New( "TAFA440" )

oModel:AddFields( "MODEL_LE7", /*cOwner*/, oStruLE7 )
oModel:GetModel ( "MODEL_LE7" ):SetPrimaryKey( { "LE7_FILIAL", "LE7_ID" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@Return oView - Objeto da View MVC

@Author	Evandro dos Santos Oliviera
@Since		23/05/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel( "TAFA440" )
Local oStruLE7 := FwFormStruct( 2, "LE7" )
Local oView    := FwFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_LE7", oStruLE7, "MODEL_LE7" )
oView:EnableTitleView( "VIEW_LE7", STR0001 ) //"Informações de identificação do registrador da CAT"
oView:CreateHorizontalBox( "FIELDSLE7", 100 )
oView:SetOwnerView( "VIEW_LE7", "FIELDSLE7" )

oStruLE7:RemoveField( "LE7_ID" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida:
LE7 -  Indicativo da matéria do processo ou alvará judicial

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Evandro dos Santos Oliviera
@Since		23/05/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1031.24

If nVerEmp < nVerAtu
	aAdd( aHeader, "LE7_FILIAL" )
	aAdd( aHeader, "LE7_ID" )
	aAdd( aHeader, "LE7_CODIGO" )
	aAdd( aHeader, "LE7_DESCRI" )
	aAdd( aHeader, "LE7_VALIDA" )

	aAdd( aBody, { "", "000001", "1" , "EXCLUSIVAMENTE TRIBUTÁRIA OU TRIBUTÁRIA E FGTS", "" } )
	aAdd( aBody, { "", "000002", "2" , "AUTORIZAÇÃO DE TRABALHO DE MENOR", "20211109" } )
	aAdd( aBody, { "", "000003", "3" , "DISPENSA, AINDA QUE PARCIAL, DE CONTRATAÇÃO DE PESSOA COM DEFICIÊNCIA (PCD)", "20211109" } )
	aAdd( aBody, { "", "000004", "4" , "DISPENSA, AINDA QUE PARCIAL, DE CONTRATAÇÃO DE APRENDIZ", "20211109" } )
	aAdd( aBody, { "", "000005", "99", "OUTROS ASSUNTOS", "20211109" } )
	aAdd( aBody, { "", "000006", "5" , "SEGURANÇA E SAÚDE DO TRABALHO", "20211109" } )
	aAdd( aBody, { "", "000007", "6" , "CONVERSÃO DE LICENÇA SAÚDE EM ACIDENTE DE TRABALHO", "20211109" } )
	aAdd( aBody, { "", "000008", "7" , "EXCLUSIVAMENTE FGTS E/OU CONTRIBUIÇÃO SOCIAL RESCISÓRIA (LEI COMPLEMENTAR 110/2001)", "" } )
	aAdd( aBody, { "", "000009", "8" , "CONTRIBUIÇÃO SINDICAL", "20211109" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
