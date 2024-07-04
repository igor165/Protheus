#Include 'MDTA056.ch'
#Include 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"

#DEFINE _nVersao 2

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA056
Question�rio de Produto Qu�mico

@author Taina Alberto Cardoso - Refeito por: Gabriel Augusto Werlich
@since 19/04/13 - Revis�o: 20/08/15
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA056()

	// Armazena as vari�veis
	Local aNGBEGINPRM := NGBEGINPRM( _nVersao )
	Local oBrowse
	
	//Valida acesso a rotina
	If !AliasInDic("TIB")
		If !NGINCOMPDIC("UPDMDT78","THFTE6",.T.)
	  		Return .F.
		EndIf
	EndIf
	
	oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( "TIB" )			// Alias da tabela utilizada
		oBrowse:SetMenuDef( "MDTA056" )	// Nome do fonte onde esta a fun��o MenuDef
		oBrowse:SetDescription( STR0001 )	// Descri��o do browse ###"Cadastro de Questionario Quimico"
	oBrowse:Activate()
	
	// Devolve as vari�veis armazenadas
	NGRETURNPRM(aNGBEGINPRM)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do Modelo (padr�o MVC).

@author Gabriel Augusto Werlich
@since 20/08/15

@return oModel objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStructTIB := FWFormStruct( 1 ,"TIB" , /*bAvalCampo*/ , /*lViewUsado*/ )
	Local oStructTIC := FWFormStruct( 1 ,"TIC" , /*bAvalCampo*/ , /*lViewUsado*/ )

	// Modelo de dados que ser� constru�do
	Local oModel
	
	// Cria o objeto do Modelo de Dados
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost   Code-Block de valida��o do formul�rio de edi��o
	// bCommit Code-Block de persist�ncia do formul�rio de edi��o
	// bCancel Code-Block de cancelamento do formul�rio de edi��o
	oModel := MPFormModel():New( "MDTA056" , /*bPre*/ , { | oModel | fMPosValid( oModel ) } /*bPost*/ , /*bCommit*/ , /*bCancel*/ )
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
		oModel:AddFields( "TIBMASTER" , Nil , oStructTIB , /*bPre*/ , /*bPost*/ , /*bLoad*/ )

		oModel:AddGrid( "TICDETAIL" , "TIBMASTER" ,oStructTIC , /*bPre*/ , , /*bLoad*/ )
		
		oModel:SetRelation( 'TICDETAIL', { { 'TIC_FILIAL', 'xFilial( "TIC" )' },{ 'TIC_CODIGO', 'TIB_CODIGO' }},TIC->( IndexKey( 1 ) ) )
				
			// Adiciona a descri��o do Modelo de Dados (Geral)
			oModel:SetDescription( STR0001 /*cDescricao*/ ) // "Cadastro de Questionario Quimico"
			
			// Adiciona a descricao do Componente do Modelo de Dados
			oModel:GetModel( "TIBMASTER" ):SetDescription( STR0001 ) //"Cadastro de Questionario Quimico"
			oModel:GetModel( "TICDETAIL" ):SetDescription( STR0001 ) //"Cadastro de Questionario Quimico"
			
			//N�o copia os campos do array
			oModel:GetModel( 'TIBMASTER' ):SetFldNoCopy( {/*'TIB_CODPRO',*/'TIB_DESPRO', 'TIB_GRUPRO'} )
			
			oModel:GetModel( "TICDETAIL" ):SetOptional( .T. )
			
			//"Valida chave duplicada em uma linha da getdados
			oModel:GetModel( "TICDETAIL" ):SetUniqueLine( {"TIC_CODGRU", "TIC_ORDEM"} ) 

Return oModel
//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o da View (padr�o MVC).

@author Gabriel Augusto Werlich
@since 20/08/15

@return oView objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()
	
	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel( "MDTA056" )
	
	// Cria a estrutura a ser usada na View
	Local oStructTIB := FWFormStruct( 2 , "TIB" , /*bAvalCampo*/ , /*lViewUsado*/ )
	Local oStructTIC := FWFormStruct( 2 , "TIC" , /*bAvalCampo*/ , /*lViewUsado*/ )
	
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
		oView:AddField( "TIBMASTER" , oStructTIB )
		oView:AddGrid( "TICDETAIL" , oStructTIC )
		
			//Adiciona um titulo para o formul�rio
			oView:EnableTitleView( "TIBMASTER" , STR0001 )	// Descri��o do browse ###"Cadastro de Questionario Quimico"
			// Cria os componentes "box" horizontais para receberem elementos da View
			// cID		  	Id do Box a ser utilizado 
			// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
			// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
			// lFixPixel	Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
			// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
			// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
			oView:CreateHorizontalBox( "SUPERIOR" , 30,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
			oView:CreateHorizontalBox( "INFERIOR" , 70,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
		
		// Associa um View a um box
		oView:SetOwnerView( "TIBMASTER" , "SUPERIOR" )
		oView:SetOwnerView( "TICDETAIL" , "INFERIOR" )

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do Menu (padr�o MVC).

@author Gabriel Augusto Werlich
@since 20/08/15

@return aRotina array com o Menu MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()
//Inicializa MenuDef com todas as op��es
Return FWMVCMenu( "MDTA056" )
//---------------------------------------------------------------------
/*/{Protheus.doc} fMPosValid
Valida��o da tela (Antigo TudoOk)

@author Gabriel Augusto Werlich
@since 20/08/15

@return lRet - .T. / .F. 
/*/
//---------------------------------------------------------------------
Static Function fMPosValid( oModel )
    
	Local lRet			:= .T.
	Local aAreaTIB	:= TIB->( GetArea() )
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
	aCHKSQL := NGRETSX9( "TIB" )

	// Recebe rela��o do Cadastro - Formato:
	// 1 - Chave
	// 2 - Alias
	// 3 - Ordem (�ndice)
	aAdd(aCHKDEL, { "TIB->TIB_CODIGO" , "TID" , 1 } )

	If nOperation == MODEL_OPERATION_DELETE //Exclus�o

		If !NGCHKDEL( "TIB" )
			lRet := .F.
		EndIf

		If lRet .And. !NGVALSX9( "TIB" , {} , .T. , .T. )
			lRet := .F.
		EndIf

	EndIf

	RestArea( aAreaTIB )

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT056TIPO
Valida��o da tela (Antigo TudoOk)

@author Gabriel Augusto Werlich
@since 20/08/15

@return lRet - .T. / .F. 
/*/
//---------------------------------------------------------------------
Function MDT056VAL(nParam)
	Local lRet := .T.
	
	If nParam == 1 .And. Empty(M->TIC_TIPO)
		lRet := .F.
		Help( , , "ATEN��O" , , STR0011 , 4 , 0 )//###"O campo 'Tipo' n�o pode estar vazio!"
	ElseIf nParam == 2 .And. Empty(M->TIC_OBRIG)
		lRet := .F.
		Help( , , "ATEN��O" , , STR0012 , 4 , 0 )//###"O campo 'Obrigat�rio' n�o pode estar vazio!"
	EndIf
Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT056TIPO
Busca o X3_RELACAO dos respectivos campos, se n�o for inclus�o ou c�pia.

@author Gabriel Augusto Werlich
@since 20/08/15
@param nParam - 1/2

@return cDesc - Descri��o do Relacao
/*/
//---------------------------------------------------------------------
Function MDTREL056(nParam)
Local cDesc := "", cExec := ""
Local oModel := FWModelActive()
Local nOperation := oModel:GetOperation()

cExec := If( nParam == 1 , "SB1->(VDISP(TIB->TIB_CODPRO,'B1_DESC'))" , "SB1->(VDISP(TIB->TIB_CODPRO,'B1_GRUPO'))" )

If OMODEL:ACONTROLS[4] <> 6 .Or. nOperation == 3	
	cDesc := &( cExec )	
EndIf 

Return cDesc     