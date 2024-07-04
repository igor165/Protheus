#INCLUDE "MDTA021.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA021
Programa para cadastro dos grupos da Terminologia Unificada da Sa�de Suplementar

@sample MDTA021()

@author Jackson Machado
@since 02/10/13
/*/
//---------------------------------------------------------------------
Function MDTA021()

	// Armazena as vari�veis
	Local aNGBEGINPRM := NGBEGINPRM()

	Local oBrowse

	oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( "TY0" )			// Alias da tabela utilizada
		oBrowse:SetMenuDef( "MDTA021" )	// Nome do fonte onde esta a fun��o MenuDef
		oBrowse:SetDescription( STR0001 )	// Descri��o do browse ###"Grupos da TUSS"
	oBrowse:Activate()

	// Devolve as vari�veis armazenadas
	NGRETURNPRM( aNGBEGINPRM )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do Menu (padr�o MVC).

@author Jackson Machado
@since 02/10/13

@return Array aRotina array com o Menu MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title "Visualizar"	Action "VIEWDEF.MDTA021"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Incluir"		Action "VIEWDEF.MDTA021"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title "Alterar"		Action "VIEWDEF.MDTA021"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Excluir"		Action "VIEWDEF.MDTA021"	OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title "Copiar"		Action "VIEWDEF.MDTA021"	OPERATION 9 ACCESS 0

Return aRotina
//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do Modelo (padr�o MVC).

@author Jackson Machado
@since 02/10/13

@return Objeto oModel objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

    // Cria a estrutura a ser usada no Modelo de Dados
	Local oStructTY0 := FWFormStruct( 1 , "TY0" , /*bAvalCampo*/ , /*lViewUsado*/ )

	// Modelo de dados que ser� constru�do
	Local oModel

	// Cria o objeto do Modelo de Dados
	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost   Code-Block de valida��o do formul�rio de edi��o
	// bCommit Code-Block de persist�ncia do formul�rio de edi��o
	// bCancel Code-Block de cancelamento do formul�rio de edi��o
	oModel := MPFormModel():New( "MDTA021" , /*bPre*/ , { | oModel | fMPosValid( oModel ) } /*bPos*/ , /*bCommit*/ , /*bCancel*/ )
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
		oModel:AddFields( "TY0MASTER" , Nil , oStructTY0 , /*bPre*/ , /*bPost*/ , /*bLoad*/ )
			// Adiciona a descri��o do Modelo de Dados (Geral)
			oModel:SetDescription( STR0001 /*cDescricao*/ ) //"Grupos da TUSS"
			// Adiciona a descricao do Componente do Modelo de Dados
			oModel:GetModel( "TY0MASTER" ):SetDescription( STR0001 ) //"Grupos da TUSS"

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o da View (padr�o MVC).

@author Jackson Machado
@since 02/10/13

@return Objeto oView objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel( "MDTA021" )

	// Cria a estrutura a ser usada na View
	Local oStructTY0 := FWFormStruct( 2 , "TY0" , /*bAvalCampo*/ , /*lViewUsado*/ )

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
		oView:AddField( "VIEW_TY0" , oStructTY0 , "TY0MASTER" )
			//Adiciona um titulo para o formul�rio
			oView:EnableTitleView( "VIEW_TY0" , STR0001 )	// Descri��o do browse ###"Grupos da TUSS"
			// Cria os componentes "box" horizontais para receberem elementos da View
			// cID		  	Id do Box a ser utilizado
			// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
			// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
			// lFixPixel	Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
			// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
			// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
			oView:CreateHorizontalBox( "TELATY0" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
		// Associa um View a um box
		oView:SetOwnerView( "VIEW_TY0" , "TELATY0" )

		//Inclus�o de itens no A��es Relacionadas de acordo com o NGRightClick
   		NGMVCUserBtn( oView )

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fMPosValid
P�s-valida��o do modelo de dados.

@author Jackson Machado
@since 02/10/13

@param oModel, Objeto, Objeto do modelo de dados (Obrigat�rio)

@return Logico Retorna verdadeiro caso validacoes estejam corretas
/*/
//---------------------------------------------------------------------
Static Function fMPosValid( oModel )

	Local lRet			:= .T.

	Local aAreaTY0		:= TY0->( GetArea() )

	Local nOperation	:= oModel:GetOperation() // Opera��o de a��o sobre o Modelo
	Local oModelTY0		:= oModel:GetModel( "TY0MASTER" )

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
	aCHKSQL := NGRETSX9( "TY0" )

	// Recebe rela��o do Cadastro - Formato:
	// 1 - Chave
	// 2 - Alias
	// 3 - Ordem (�ndice)
	aAdd(aCHKDEL, { "TY0->TY0_GRUPO" , "TY1" , 3 } )
	aAdd(aCHKDEL, { "TY0->TY0_GRUPO" , "TY2" , 3 } )

	If nOperation == MODEL_OPERATION_DELETE //Exclus�o

		If !NGCHKDEL( "TY0" )
			lRet := .F.
		EndIf

		If lRet .And. !NGVALSX9( "TY0" , {} , .T. , .T. )
			lRet := .F.
		EndIf

	EndIf

	RestArea( aAreaTY0 )

Return lRet