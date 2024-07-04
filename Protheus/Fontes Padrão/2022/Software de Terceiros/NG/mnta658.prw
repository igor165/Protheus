#INCLUDE 'MNTA658.ch'
#INCLUDE 'TOTVS.ch'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA658
Cria uma nova rotina chamada Registo de Motivos de Sa�da de Combust�vel

@type Function

@author Jo�o Ricardo Santini Zandon�
@since 15/09/2021

@return Nil  
/*/ 
//-------------------------------------------------------------------
Function MNTA658()

	Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias( 'TTX' )          // Alias da tabela utilizada
	oBrowse:SetMenuDef( 'MNTA658' )    // Nome do fonte onde esta a fun��o MenuDef
	oBrowse:SetDescription(	STR0001	)  // 'Registo de Motivos de Sa�da de Combust�vel'	

	oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Inicializa o MenuDef com as suas op��es

@type Function

@author Jo�o Ricardo Santini Zandon�
@since 15/09/2021

@return FWMVCMenu() Vai retornar as op��es padr�o do menu, como 'Incluir', 'Alterar', e 'Excluir'
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Return FWMVCMenu( 'MNTA658' )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Inicializa o ModelDef com as suas op��es
 
@type Function

@author Jo�o Ricardo Santini Zandon�
@since 15/09/2021

@return Objeto, leva as op��es que Foram carregadas do ModelDef
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStructTTX := FWFormStruct( 1,'TTX' )

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'MNTA658', /*bPre*/, /*Pos*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oModel:AddFields( 'MNTA658_TTX', Nil, oStructTTX,/*bPre*/,/*bPost*/,/*bLoad*/ )

	oModel:SetDescription( STR0001 ) // Registo de Motivos de Sa�da de Combust�vel

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Inicializa o ViewDef com as suas op��es

@type Function

@author Jo�o Ricardo Santini Zandon�
@since 15/09/2021

@return Object, Essa vari�vel vai ser respons�vel pela constru��o da View.
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel( 'MNTA658' )
	Local oView  := FWFormView():New()

	// Objeto do model a se associar a view.
	oView:SetModel( oModel )

	// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'MNTA658_TTX' , FWFormStruct( 2,'TTX' ), /*cLinkID*/ )	//

	// Criar um 'box' horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'MASTER' , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

	// Associa um View a um box
	oView:SetOwnerView( 'MNTA658_TTX' , 'MASTER' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA658VLD
Reconhece qual o campo que est� sendo validado, e chama a fun��o da sua valida��o

@type Function

@author Jo�o Ricardo Santini Zandon�
@since 15/09/2021
@Params cCampo, campo, traz o nome do campo que vai ser validado

@return Logica, carrega o retorno da valida��o requisitada.
/*/
//-------------------------------------------------------------------
Function MNTA658VLD(cCampo)

	Local lRet     := .T.
	Local oModel   := FWModelActive()
	Local cMotivo 

	If cCampo   == 'TTX_MOTIVO'
		cMotivo := oModel:GetValue('MNTA658_TTX', 'TTX_MOTIVO')
		lRet    := ExistChav('TTX',cMotivo)
	ElseIf cCampo == 'TTX_ATUEST'
		lRet := PERTENCE('12')
	ElseIf cCampo == 'TTX_MOTTTH'
		lRet := PERTENCE('123456') .And. MNTA658TPL()
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA658TPL
Valida��o do campo Tipo de lan�amento

@type Function

@author Jo�o Ricardo Santini Zandon�
@since 15/09/2021

@return Logica, carrega o retorno da valida��o requisitada.
/*/
//-------------------------------------------------------------------
Function MNTA658TPL()
	
	Local lRet      := .T.
	Local cAliasQry := GetNextAlias()
	Local oModel	:= FWModelActive()
	Local cMotivo   := ''

	// Tratamento para quando a inclus�o vem do F3( Chamado atrav�s da rotina MNTA657 -> Outras a��es -> Saidas de combustiveis, incluir via F3 )
	If Type( 'oModel' ) == 'O'

		// Recebe valor do campo TTX_MOTTTH
		cMotivo := oModel:GetValue( 'MNTA658_TTX', 'TTX_MOTTTH' )

		If oModel:getOperation() == 4 .And. TTX->TTX_MOTTTH != cMotivo

			//Busca registros da TTH, para validar se o Tipo Lancam j� est� sendo usado
			BeginSQL Alias cAliasQry
				SELECT COUNT(TTH_FILIAL) as TTHCONT
					FROM %table:TTH% TTH
				WHERE	TTH.TTH_MOTIV2 = %exp:cMotivo%
					AND TTH.%NotDel%
			EndSQL

			If (cAliasQry)->( !Eof() ) .And. (cAliasQry)->TTHCONT > 0
				Help(STR0007,STR0008) //'ATEN��O' ## 'O 'Tipo Lancam.' selecionado j� est� cadastrado em uma sa�da de combust�vel.'	 
				lRet := .F.
			EndIf	
			
			(cAliasQry)->(dbCloseArea())
				
		EndIf

	EndIf

Return lRet
