#INCLUDE "SGAA780.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE _nVersao 1 //Versao do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} SGAA780
Programa de C�digos do IBAMA

@source SGAA780.prw

@return Nill, Sempre Nulo

@sample SGAA780()

@author Jackson Machado
@since 16/11/2016
/*/
//---------------------------------------------------------------------
Function SGAA780()
	
	// Armazena as vari�veis
	Local aNGBEGINPRM := NGBEGINPRM( _nVersao )
	
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( "TFC" )			// Alias da tabela utilizada
		oBrowse:SetMenuDef( "SGAA780" )	// Nome do fonte onde esta a fun��o MenuDef
		oBrowse:SetDescription( STR0001 )	// Descri��o do browse 
	oBrowse:Activate()
	
	// Devolve as vari�veis armazenadas
	NGRETURNPRM(aNGBEGINPRM)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do Menu (padr�o MVC).

@source SGAA780.prw

@author Jackson Machado
@since 16/11/2016

@return aRotina, Array com o Menu MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()
//Inicializa MenuDef com todas as op��es
Return FWMVCMenu( "SGAA780" )
//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do Modelo (padr�o MVC).

@source SGAA780.prw

@author Jackson Machado
@since 16/11/2016

@return oModel, Objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()
    
    // Cria a estrutura a ser usada no Modelo de Dados
	Local oStructTFC := FWFormStruct( 1 ,"TFC" , /*bAvalCampo*/ , /*lViewUsado*/ )
	
	// Modelo de dados que ser� constru�do
	Local oModel
	
	// Cria o objeto do Modelo de Dados
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost   Code-Block de valida��o do formul�rio de edi��o
	// bCommit Code-Block de persist�ncia do formul�rio de edi��o
	// bCancel Code-Block de cancelamento do formul�rio de edi��o
	oModel := MPFormModel():New( "SGAA780" , /*bPre*/ , { | oModel | fMPosValid( oModel ) } /*bPos*/ , /*bCommit*/ , /*bCancel*/ )
		//--------------------------------------------------
		// Componentes do Modelo
		//--------------------------------------------------

		// Adiciona ao modelo um componente de Formul�rio Principal
		// cId          Identificador do modelo
		// cOwner       Identificador superior do modelo
		// oModelStruct Objeto com  a estrutura de dados
		// bPre         Code-Block de pr�-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
		// bPost        Code-Block de valida��o do formul�rio de edi��o
		// bLoad        Code-Block de carga dos dados do formul�rio de edi��o
		oModel:AddFields( "TFCMASTER" , Nil , oStructTFC , /*bPre*/ , /*bPost*/ , /*bLoad*/ )
			// Adiciona a descri��o do Modelo de Dados (Geral)
			oModel:SetDescription( STR0001 /*cDescricao*/ ) //"IBAMA" 
			// Adiciona a descricao do Componente do Modelo de Dados
			oModel:GetModel( "TFCMASTER" ):SetDescription( STR0001 )
			
Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o da View (padr�o MVC).

@source SGAA780.prw

@author Jackson Machado
@since 16/11/2016

@return oView, Objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()
	
	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel( "SGAA780" )
	
	// Cria a estrutura a ser usada na View
	Local oStructTFC := FWFormStruct( 2 , "TFC" , /*bAvalCampo*/ , /*lViewUsado*/ )
	
	// Interface de visualiza��o constru�da
	Local oView
	
	// Cria o objeto de View
	oView := FWFormView():New()
		// Objeto do model a se associar a view.
		oView:SetModel( oModel )
		// Adiciona no View um controle do tipo formul�rio (antiga Enchoice)
		// cFormModelID - Representa o ID criado no Model que essa FormField ir� representar
		// oStruct - Objeto do model a se associar a view.
		// cLinkID - Representa o ID criado no Model ,S� � necess�ri o caso estamos mundando o ID no View.
		oView:AddField( "VIEW_TFC" , oStructTFC , "TFCMASTER" )
			//Adiciona um titulo para o formul�rio
			oView:EnableTitleView( "VIEW_TFC" , STR0001 )	// Descri��o do browse
			// Cria os componentes "box" horizontais para receberem elementos da View
			// cID		  	Id do Box a ser utilizado 
			// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
			// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
			// lFixPixel	Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
			// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
			// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
			oView:CreateHorizontalBox( "TELATFC" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
		// Associa um View a um box
		oView:SetOwnerView( "VIEW_TFC" , "TELATFC" )

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fMPosValid
P�s-valida��o do modelo de dados.

@source SGAA780.prw

@author Jackson Machado
@since 16/11/2016

@param oModel, Objeto, Objeto do modelo de dados (Obrigat�rio)

@return L�gico, Retorna verdadeiro caso validacoes estejam corretas
/*/
//---------------------------------------------------------------------
Static Function fMPosValid( oModel )
    
	Local lRet			:= .T.
	
	Local aAreaTFC		:= TFC->( GetArea() )

	Local nOperation	:= oModel:GetOperation() // Opera��o de a��o sobre o Modelo
	Local oModelTFC	:= oModel:GetModel( "TFCMASTER" )

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
	aCHKSQL := NGRETSX9( "TFC" )

	// Recebe rela��o do Cadastro - Formato:
	// 1 - Chave
	// 2 - Alias
	// 3 - Ordem (�ndice)
	//aAdd(aCHKDEL, { "TFC->TFC_CODRES" , "XXX" , 1 } )

	If nOperation == MODEL_OPERATION_DELETE //Exclus�o

		If !NGCHKDEL( "TFC" )
			lRet := .F.
		EndIf

		If lRet .And. !NGVALSX9( "TFC" , {} , .T. , .T. )
			lRet := .F.
		EndIf

	EndIf

	RestArea( aAreaTFC )

Return lRet