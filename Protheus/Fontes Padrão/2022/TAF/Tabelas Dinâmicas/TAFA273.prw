#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA273.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA273
Cadastro MVC de Motivo de Desligamento do Diretor Sem Vínculo

@author Leandro Prado
@since 19/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA273()
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Motivo de Desligamento do Diretor Sem Vínculo
oBrw:SetAlias( 'CML')
oBrw:SetMenuDef( 'TAFA273' )
oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Leandro Prado
@since 19/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA273" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Leandro Prado
@since 19/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCML := FWFormStruct( 1, 'CML' )// Cria a estrutura a ser usada no Modelo de Dados
Local oModel := MPFormModel():New('TAFA273' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_CML', /*cOwner*/, oStruCML)
oModel:GetModel( 'MODEL_CML' ):SetPrimaryKey( { 'CML_FILIAL' , 'CML_ID' } )


Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Leandro Prado
@since 19/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel		:= FWLoadModel( 'TAFA273' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruCML		:= FWFormStruct( 2, 'CML' )// Cria a estrutura a ser usada na View
Local oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_CML', oStruCML, 'MODEL_CML' )

oView:EnableTitleView( 'VIEW_CML',  STR0001 ) //Motivo de Desligamento do Diretor Sem Vínculo

oView:CreateHorizontalBox( 'FIELDSCML', 100 )

oView:SetOwnerView( 'VIEW_CML', 'FIELDSCML' )

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

nVerAtu := 1028.15

If nVerEmp < nVerAtu
	aAdd( aHeader, "CML_FILIAL" )
	aAdd( aHeader, "CML_ID" )
	aAdd( aHeader, "CML_CODIGO" )
	aAdd( aHeader, "CML_DESCRI" )
	aAdd( aHeader, "CML_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "Exoneração do Diretor Não Empregado sem justa causa, por deliberação da assembléia, dos sócios cotistas ou da autoridade competente.", "" } )
	aAdd( aBody, { "", "000002", "02", "Término de Mandato do Diretor Não Empregado que não tenha sido reconduzido ao cargo.", "" } )
	aAdd( aBody, { "", "000003", "03", "Exoneração a pedido de Diretor Não Empregado.", "" } )
	aAdd( aBody, { "", "000004", "04", "Exoneração do Diretor Não Empregado por culpa recíproca ou força maior.", "" } )
	aAdd( aBody, { "", "000005", "05", "Morte do Diretor Não Empregado.", "" } )
	aAdd( aBody, { "", "000006", "06", "Exoneração do Diretor Não Empregado por falência, encerramento ou supressão de parte da empresa.", "" } )
    aAdd( aBody, { "", "000007", "99", "Outros.", "" } )
    aAdd( aBody, { "", "000008", "07", "Mudança de CPF.", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )