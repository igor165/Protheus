#include 'Protheus.ch'
#include 'FWMVCDEF.ch'
#include 'Totvs.Ch'

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MDT135A
Classe de evento do MVC Medidas de Controle

@author  Luis Fellipy Bett
@since   24/08/2018
@type    Class
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Class MDT135A FROM FWModelEvent

    Method New()
	Method ModelPosVld() //Method de p�s valida��o do modelo

End Class

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Mehtod New para cria��o da estancia entre o evento e as classes.

@author  Luis Fellipy Bett
@since   24/08/2018
@type    Class
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Method New() Class MDT135A

Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Method para p�s-valida��o do Modelo.

@param oModel	- Objeto	- Modelo utilizado.
@param cModelId	- Caracter	- Id do modelo utilizado.

@class MDT135A - Classe origem

@author  Luis Fellipy Bett
@since   24/08/2018
@type    Class
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Method ModelPosVld( oModel , cModelId ) Class MDT135A

	Local lRet			:= .T.

	Local aAreaTO4		:= TO4->( GetArea() )

	Local nOperation	:= oModel:GetOperation() // Opera��o de a��o sobre o Modelo

	Private aCHKSQL 	:= {} // Vari�vel para consist�ncia na exclus�o (via SX9)
	Private aCHKDEL 	:= {} // Vari�vel para consist�ncia na exclus�o (via Cadastro)

	// Recebe SX9 - Formato:
	// 1 - Dom�nio (tabela)
	// 2 - Campo do Dom�nio
	// 3 - Contra-Dom�nio (tabela)
	// 4 - Campo do Contra-Dom�nio
	// 5 - Condi��o SQL
	// 6 - Compara��o da Filial do Dom�nio
	// 7 - Compara��o da Filial do Contra-Dom�nio
	aCHKSQL := NGRETSX9( "TO4" )

	// Recebe rela��o do Cadastro - Formato:
	// 1 - Chave
	// 2 - Alias
	// 3 - Ordem (�ndice)
	aAdd( aCHKDEL , { "TO4->TO4_CONTRO" , "TO3" , 2 } )
	If NGCADICBASE( "TJF_NUMRIS" , "A" , "TJF" , .F. )
		aAdd( aCHKDEL , { "TO4->TO4_CONTRO" , "TJF" , 2 } )
	Endif

	If nOperation == MODEL_OPERATION_DELETE //Exclus�o

		If !NGCHKDEL( "TO4" )
			lRet := .F.
		EndIf

		If lRet .And. !NGVALSX9( "TO4" , {} , .T. , .T. )
			lRet := .F.
		EndIf

	EndIf

	RestArea( aAreaTO4 )

Return lRet