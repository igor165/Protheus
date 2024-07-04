#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA221.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA221
Cadastro MVC de Tipos de Lota��o

@author Leandro Prado
@since 09/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA221()
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Tipos de Lota��o
oBrw:SetAlias( 'C8F')
oBrw:SetMenuDef( 'TAFA221' )
oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Leandro Prado
@since 09/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA221" )                                                                          

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Leandro Prado
@since 09/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	
Local oStruC8F := FWFormStruct( 1, 'C8F' )// Cria a estrutura a ser usada no Modelo de Dados
Local oModel := MPFormModel():New('TAFA221' )

// Adiciona ao modelo um componente de formul�rio
oModel:AddFields( 'MODEL_C8F', /*cOwner*/, oStruC8F)
oModel:GetModel( 'MODEL_C8F' ):SetPrimaryKey( { 'C8F_FILIAL' , 'C8F_ID' } )

Return oModel             


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Leandro Prado
@since 09/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel		:= FWLoadModel( 'TAFA221' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruC8F		:= FWFormStruct( 2, 'C8F' )// Cria a estrutura a ser usada na View
Local oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C8F', oStruC8F, 'MODEL_C8F' )

oView:EnableTitleView( 'VIEW_C8F',  STR0001 ) //Tipos de Lota��o

oView:CreateHorizontalBox( 'FIELDSC8F', 100 )

oView:SetOwnerView( 'VIEW_C8F', 'FIELDSC8F' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1013

If nVerEmp < nVerAtu
	aAdd( aHeader, "C8F_FILIAL" )
	aAdd( aHeader, "C8F_ID" )
	aAdd( aHeader, "C8F_CODIGO" )
	aAdd( aHeader, "C8F_DESCRI" )
	aAdd( aHeader, "C8F_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "CLASSIFICA��O DA ATIVIDADE ECON�MICA EXERCIDA PELA PESSOA JUR�DICA PARA FINS DE ATRIBUI��O DE C�DIGO FPAS, INCLUSIVE OBRAS DE CONSTRU��O CIVIL PR�PRIA", "" } )
	aAdd( aBody, { "", "000002", "02", "OBRA DE CONSTRU��O CIVIL - EMPREITADA PARCIAL OU SUB-EMPREITADA ", "" } )
	aAdd( aBody, { "", "000003", "03", "PESSOA F�SICA TOMADORA DE SERVI�OS PRESTADOS MEDIANTE CESS�O DE M�O DE OBRA, EXCETO CONTRATANTE DE COOPERATIVA", "" } )
	aAdd( aBody, { "", "000004", "04", "PESSOA JUR�DICA TOMADORA DE SERVI�OS PRESTADOS MEDIANTE CESS�O DE M�O DE OBRA, EXCETO CONTRATANTE DE COOPERATIVA, NOS TERMOS DA LEI 8.212/1991", "" } )
	aAdd( aBody, { "", "000005", "05", "PESSOA JUR�DICA TOMADORA DE SERVI�OS PRESTADOS POR COOPERADOS POR INTERM�DIO DE COOPERATIVA DE TRABALHO, EXCETO AQUELES PRESTADOS A ENTIDADE BENEFICENTE/ISENTA", "" } )
	aAdd( aBody, { "", "000006", "06", "ENTIDADE BENEFICENTE/ISENTA TOMADORA DE SERVI�OS PRESTADOS POR COOPERADOS POR INTERM�DIO DE COOPERATIVA DE TRABALHO", "" } )
	aAdd( aBody, { "", "000007", "07", "PESSOA F�SICA TOMADORA DE SERVI�OS PRESTADOS POR COOPERADOS POR INTERM�DIO DE COOPERATIVA DE TRABALHO", "" } )
	aAdd( aBody, { "", "000008", "08", "OPERADOR PORTU�RIO TOMADOR DE SERVI�OS DE TRABALHADORES AVULSOS", "" } )
	aAdd( aBody, { "", "000009", "09", "CONTRATANTE DE TRABALHADORES AVULSOS N�O PORTU�RIOS POR INTERM�DIO DE SINDICATO", "" } )
	aAdd( aBody, { "", "000010", "10", "EMBARCA��O INSCRITA NO REGISTRO ESPECIAL BRASILEIRO - REB", "" } )
	aAdd( aBody, { "", "000011", "21", "CLASSIFICA��O DA ATIVIDADE ECON�MICA OU OBRA PR�PRIA DE CONSTRU��O CIVIL DA PESSOA F�SICA", "" } )
	aAdd( aBody, { "", "000012", "24", "EMPREGADOR DOM�STICO", "" } )
	aAdd( aBody, { "", "000013", "90", "ATIVIDADES DESENVOLVIDAS NO EXTERIOR POR TRABALHADOR VINCULADO AO REGIME GERAL DE PREVID�NCIA SOCIAL (EXPATRIADOS)", "" } )
	aAdd( aBody, { "", "000014", "91", "ATIVIDADES DESENVOLVIDAS POR TRABALHADOR ESTRANGEIRO VINCULADO A REGIME DE PREVID�NCIA SOCIAL ESTRANGEIRO", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
