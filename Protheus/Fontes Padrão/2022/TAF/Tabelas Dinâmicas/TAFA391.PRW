#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA391.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA391
Cadastro MVC de Obriga��es Fiscais

@author Paulo S. Vilas B.Santana
@since 15/06/2015
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA391()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001)    //"C�digo de Subitem"
oBrw:SetAlias( 'T13')
oBrw:SetMenuDef( 'TAFA391' )
T13->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Paulo S. Vilas B.Santana
@since 10/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA391" ,,,,.T. )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Paulo S. Vilas B.Santana
@since 10/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruT13  :=  FWFormStruct( 1, 'T13' )
Local oModel    :=  MPFormModel():New( 'TAFA391' )

oModel:AddFields('MODEL_T13', /*cOwner*/, oStruT13)
oModel:GetModel('MODEL_T13'):SetPrimaryKey({'T13_FILIAL','T13_CODIGO'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Paulo S. Vilas B.Santana
@since 10/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA391' )
Local   oStruT13    :=  FWFormStruct( 2, 'T13' )
Local   oView       :=  FWFormView():New()  

oView:SetModel( oModel )
oView:AddField( 'VIEW_T13', oStruT13, 'MODEL_T13' )

oView:EnableTitleView( 'VIEW_T13', STR0001 )    //"Classif. da Condi��o Trabalhador Estrangeiro"
oView:CreateHorizontalBox( 'FIELDST13', 100 )
oView:SetOwnerView( 'VIEW_T13', 'FIELDST13' )

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

nVerAtu := 1020.04

If nVerEmp < nVerAtu
	aAdd( aHeader, "T13_FILIAL" )
	aAdd( aHeader, "T13_ID" )
	aAdd( aHeader, "T13_CODIGO" )
	aAdd( aHeader, "T13_DESCRI" )
	aAdd( aHeader, "T13_VALIDA" )

	aAdd( aBody, { "", "000001", "1", "VISTO PERMANENTE", "" } )
	aAdd( aBody, { "", "000002", "2", "VISTO TEMPOR�RIO", "" } )
	aAdd( aBody, { "", "000003", "3", "ASILADO", "" } )
	aAdd( aBody, { "", "000004", "4", "REFUGIADO", "" } )
	aAdd( aBody, { "", "000005", "5", "SOLICITANTE DE REF�GIO", "" } )
	aAdd( aBody, { "", "000006", "6", "RESIDENTE FORA DO BRASIL", "" } )  
	aAdd( aBody, { "", "000007", "7", "DEFICIENTE F�SICO E COM MAIS DE 51 ANOS", "" } )
	aAdd( aBody, { "", "000008", "8", "COM RESID�NCIA PROVIS�RIA E ANISTIADO, EM SITUA��O IRREGULAR", "" } )
	aAdd( aBody, { "", "000009", "9", "PERMAN�NCIA NO BRASIL EM RAZ�O DE FILHOS OU C�NJUGE BRASILEIROS", "" } )
	aAdd( aBody, { "", "000010", "10", "BENEFICIADO PELO ACORDO ENTRE PA�SES DO MERCOSUL", "" } )
	aAdd( aBody, { "", "000011", "11", "DEPENDENTE DE AGENTE DIPLOM�TICO E/OU CONSULAR DE PA�SES QUE MANT�M CONV�NIO DE RECIPROCIDADE PARA O EXERC�CIO DE ATIVIDADE REMUNERADA NO BRASIL", "" } )
	aAdd( aBody, { "", "000012", "12", "BENEFICIADO PELO TRATADO DE AMIZADE, COOPERA��O E CONSULTA ENTRE A REP�BLICA FEDERATIVA DO BRASIL E A REP�BLICA PORTUGUESA", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )