#INCLUDE 'MNTA950.ch'
#Include 'TOTVS.ch'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA951
Cria uma nova rotina chamada Servi�os/Fornecedor

@type Function

@author Jo�o Ricardo Santini Zandon�
@since 10/09/2021

@return Nil
/*/
//-------------------------------------------------------------------
Function MNTA951()

	Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias( 'TST' )          // Alias da tabela utilizada
	oBrowse:SetMenuDef( 'MNTA951' )    // Nome do fonte onde esta a fun��o MenuDef
	oBrowse:SetDescription(	STR0006	)  // 'Registo De Servi�os X Fornecedor'		
	oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Inicializa o MenuDef com as suas op��es

@type Function

@author Jo�o Ricardo Santini Zandon�
@since 10/09/2021

@return FWMVCMenu() Vai retornar as op��es padr�o do menu, como 'Incluir', 'Alterar', e 'Excluir'
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Return FWMVCMenu( 'MNTA951' )

/*/{Protheus.doc} ModelDef
Inicializa o ModelDef com as suas op��es
 
@type Function

@author Jo�o Ricardo Santini Zandon�
@since 10/09/2021

@return Objeto, Vai retornar tudo o que foi carregado no oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStructTST := FWFormStruct( 1, 'TST', /*bAvalCampo*/, /*lViewUsado*/)
	Local oStructTS6 := FWFormStruct( 1, 'TS6', /*bAvalCampo*/, /*lViewUsado*/)
	Local oModel

	//Remove o campo repetido em tela
	oStructTS6:RemoveField('TS6_FORNEC')
	oStructTS6:RemoveField('TS6_LOJA')

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'MNTA951', /*{|oModel| PreValida(oModel) }*/, /*Pos*/, /*{|oModel| CommitInfo(oModel) }*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de Formul�rio de edi��o por campo
	oModel:AddFields( 'MNTA951_TST', Nil, oStructTST,/*bPre*/,/*bPost*/,/*bLoad*/)

	// Adiciona ao modelo uma estrutura de Formul�rio de edi��o por grid
	oModel:AddGrid( 'MNTA951_TS6', 'MNTA951_TST', oStructTS6, /*bLinePre*/, /*Post*/ , /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'MNTA951_TS6', { { 'TS6_FILIAL', 'xFilial( "TS6" )' }, ;
										 { 'TS6_FORNEC', 'TST_FORNEC' },;
										 { 'TS6_LOJA', 'TST_LOJA' } }, ;
										 TS6->( IndexKey(1)) )

	oModel:SetPrimaryKey( { 'TST_FILIAL', 'TST_CODFAM' , 'TST_TIPMOD' , 'TST_SEQFAM' } ) //TST_FILIAL+TST_CODFAM+TST_TIPMOD+TST_SEQFAM

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0006 ) // 'Registo De Servi�os X Fornecedor'

	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'MNTA951_TS6' ):SetUniqueLine( { 'TS6_SERVIC'} )
    
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Inicializa o ViewDef com as suas op��es

@type Function

@author Jo�o Ricardo Santini Zandon�
@since 10/09/2021

@return Objeto, Essa vari�vel vai ser respons�vel pela constru��o da View.
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel	  := FWLoadModel( 'MNTA951' ) // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte inFormado
	Local oStructTS6  := FWFormStruct( 2, 'TS6' ) // Cria a estrutura a ser usada na View
	Local oView		  := FWFormView():New()       // Cria o objeto de View

	oView:SetModel(oModel) // Objeto do model a se associar a view.

	//Remove o campo repetido em tela
	oStructTS6:RemoveField('TS6_FORNEC')
	oStructTS6:RemoveField('TS6_LOJA')

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'MNTA951_TST', FWFormStruct( 2, 'TST' ), /*cLinkID*/ )

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid( 'MNTA951_TS6', oStructTS6, 'MNTA951_TS6' )

	// Criar um 'box' horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 40,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:CreateHorizontalBox( 'INFERIOR', 60,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

	// Relaciona o ID da View com o 'box' para exibicao
	oView:SetOwnerView( 'MNTA951_TST', 'SUPERIOR' )
	oView:SetOwnerView( 'MNTA951_TS6', 'INFERIOR' )

	//Inclus�o de itens no A��es Relacionadas de acordo com o NGRightClick
	NGMVCUserBtn(oView)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA951VLD
Reconhece qual o campo que est� sendo validado, e chama a fun��o da sua valida��o

@type Function

@author Jo�o Ricardo Santini Zandon�
@since 15/09/2021
@Param cCampo, caractere, traz o nome do campo que vai ser validado

@return Logica, carrega o retorno da valida��o requisitada.
/*/
//-------------------------------------------------------------------
Function MNTA951VLD(cCampo)

	Local lReturn  := .T.
	Local oModel   := FWModelActive()
	Local cServico := Nil
	Local cValor   := Nil
	Local cFornec  := Nil
	Local cLoja    := Nil

	If cCampo == 'TS6_SERVIC'
		cServico  := oModel:GetValue('MNTA951_TS6', 'TS6_SERVIC')
		lReturn   := NaoVazio() .And. EXISTCPO('TS4',cServico)
	ElseIf cCampo == 'TS6_DOCTO'
	    lReturn   := NaoVazio() .And. MNTA951ANO()
	ElseIf cCampo == 'TS6_VALOR'
		cValor    := oModel:GetValue('MNTA951_TS6', 'TS6_VALOR')
		lReturn   := NGMAQUEZERO(cValor,'TS6_VALOR',.t.)
	ElseIf cCampo == 'TST_FORNEC'
		cFornec   := oModel:GetValue('MNTA951_TST', 'TST_FORNEC')
		lReturn   := NaoVazio() .And. EXISTCPO('SA2',cFornec)
	ElseIf cCampo == 'TST_LOJA'
		cLoja     := oModel:GetValue('MNTA951_TST', 'TST_LOJA')
		cFornec   := oModel:GetValue('MNTA951_TST', 'TST_FORNEC')
		lReturn   := EXISTCPO('SA2',cFornec+cLoja) .And. EXISTCHAV('TST',cFornec+cLoja )
	EndIf

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA951ANO
Respon�vel por fazer a valida��o do ano

@type Function

@author Jo�o Ricardo Santini Zandon�
@since 13/09/2021

@return Logica, retorna uma vari�vel l�gica, indicando se a valida��o foi um sucesso, ou n�o
/*/
//-------------------------------------------------------------------
Function MNTA951ANO()

	Local lReturn  := .T.
	Local oModel   := FWModelActive()
			
	If Len(AllTrim(oModel:GetValue('MNTA951_TS6', 'TS6_DOCTO'))) != 4
		Help(STR0009,STR0007) //'Ano dever� conter 4 d�gitos!'###'ATEN��O'
		lReturn := .F.
	EndIf
	If lReturn .And. allTrim(oModel:GetValue('MNTA951_TS6', 'TS6_DOCTO')) == '0000'
		Help(STR0010,STR0007) //'Ano n�o poder� ser igual a 0000!'###'ATEN��O'
		lReturn := .F.
	EndIf
                   
Return lReturn
