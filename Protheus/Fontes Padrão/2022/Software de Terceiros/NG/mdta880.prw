#INCLUDE "MDTA880.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE _nVersao 2 //Versao do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA880
Programa de Cadastro Nacional dos Estabelecimentos de Sa�de

@return

@sample MDTA880()  

@author Guilherme Benkendorf
@since 03/01/14
/*/
//---------------------------------------------------------------------
Function MDTA880()
	
	// Armazena as vari�veis
	Local aNGBEGINPRM := NGBEGINPRM( _nVersao )  
	Local oBrowse
	
	If !NGCADICBASE("TOI_ESOC","A","TOI",.F.)
		If !NGINCOMPDIC("UPDMDT84","TPMUF0",.F.)
			//  Devolve variaveis armazenadas (NGRIGHTCLICK)
			NGRETURNPRM(aNGBEGINPRM)   
	  		Return .F.
		EndIf
	EndIf	
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "TIL" )			// Alias da tabela utilizada
	oBrowse:SetMenuDef( "MDTA880" )	// Nome do fonte onde esta a fun��o MenuDef
	// Descri��o do browse
	oBrowse:SetDescription( STR0001 )	//"Cadastro Nacional de Estabelecimento de Sa�de (CNES)"
	oBrowse:Activate()
	
	// Devolve as vari�veis armazenadas  
	NGRETURNPRM(aNGBEGINPRM)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do Menu (padr�o MVC).

@author Jackson Machado
@since 13/09/13

@return aRotina array com o Menu MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()
//Inicializa MenuDef com todas as op��es
Return FWMVCMenu( "MDTA880" )
//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do Modelo (padr�o MVC).

@author Guilherme Benkendorf
@since 03/01/14

@return oModel objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()
    
    // Cria a estrutura a ser usada no Modelo de Dados
	Local oStructTIL := FWFormStruct( 1 ,"TIL" , /*bAvalCampo*/ , /*lViewUsado*/ )
	
	// Modelo de dados que ser� constru�do
	Local oModel
	
	// Cria o objeto do Modelo de Dados
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost   Code-Block de valida��o do formul�rio de edi��o
	// bCommit Code-Block de persist�ncia do formul�rio de edi��o
	// bCancel Code-Block de cancelamento do formul�rio de edi��o
	oModel := MPFormModel():New( "MDTA880" , /*bPre*/ , { | oModel | fMPosValid( oModel ) } /*bPos*/ , /*bCommit*/ , /*bCancel*/ )
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
		oModel:AddFields( "TILMASTER" , Nil , oStructTIL , /*bPre*/ , /*bPost*/ , /*bLoad*/ )
		// Adiciona a descri��o do Modelo de Dados (Geral)
		oModel:SetDescription( STR0001 )	//"Cadastro Nacional de Estabelecimento de Sa�de (CNES)" /*cDescricao*/ )
		// Adiciona a descricao do Componente do Modelo de Dados
		oModel:GetModel( "TILMASTER" ):SetDescription( STR0001 )//"Cadastro Nacional de Estabelecimento de Sa�de (CNES)"
			
Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o da View (padr�o MVC).

@author Guilherme Benkendorf
@since 03/01/14

@return oView objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()
	
	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel( "MDTA880" )
	
	// Cria a estrutura a ser usada na View
	Local oStructTIL := FWFormStruct( 2 , "TIL" , /*bAvalCampo*/ , /*lViewUsado*/ )
	
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
		oView:AddField( "VIEW_TIL" , oStructTIL , "TILMASTER" )
		//Adiciona um titulo para o formul�rio
		// Descri��o do browse
		oView:EnableTitleView( "VIEW_TIL" , STR0001 )//"Cadastro Nacional de Estabelecimento de Sa�de (CNES)"
		// Cria os componentes "box" horizontais para receberem elementos da View
		// cID		  	Id do Box a ser utilizado 
		// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
		// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
		// lFixPixel	Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
		// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
		// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
		oView:CreateHorizontalBox( "TELATIL" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
		// Associa um View a um box
		oView:SetOwnerView( "VIEW_TIL" , "TELATIL" )
		
		//Inclus�o de itens no A��es Relacionadas de acordo com o NGRightClick
		NGMVCUserBtn(oView)

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fMPosValid
P�s-valida��o do modelo de dados.

@author Guilherme Benkendorf
@since 03/01/14

@param oModel - Objeto do modelo de dados (Obrigat�rio)

@return L�gico - Retorna verdadeiro caso validacoes estejam corretas
/*/
//---------------------------------------------------------------------
Static Function fMPosValid( oModel )
    
	Local lRet			:= .T.
	
	Local aAreaTIL		:= TIL->( GetArea() )

	Local nOperation	:= oModel:GetOperation() // Opera��o de a��o sobre o Modelo
	Local oModelTIL	:= oModel:GetModel( "TILMASTER" )

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
	aCHKSQL := NGRETSX9( "TIL" )

	// Recebe rela��o do Cadastro - Formato:
	// 1 - Chave
	// 2 - Alias
	// 3 - Ordem (�ndice)
	//aAdd(aCHKDEL, { "TIL->TIL_CODRES" , TABELA , IDX } )

	If nOperation == MODEL_OPERATION_DELETE //Exclus�o

		If !NGCHKDEL( "TIL" )
			lRet := .F.
		EndIf

		If lRet .And. !NGVALSX9( "TIL" , {} , .T. , .T. )
			lRet := .F.
		EndIf

	EndIf

	RestArea( aAreaTIL )

Return lRet