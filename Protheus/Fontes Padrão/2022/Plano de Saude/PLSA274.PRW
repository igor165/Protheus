#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PLSMGER.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA274

Gestao de Pedidos da Integracao PLS x HAT
@author  Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Function PLSA274()

	Local oBrowse

	oBrowse := FWMBrowse():New() //Instanciamento da Classe de Browse
	oBrowse:SetAlias('BNV') //Definição da tabela do Browse
	oBrowse:SetDescription("Gestão de Pedidos PLS x HAT") //Titulo da Browse
	oBrowse:Activate() //Ativação da Classe

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define o menu da aplicação

@author  Renan Sakai
@version P12
@since   20/08/2018
/*/
//-------------------------------------------------------------------

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title 'Visualizar'	Action 'VIEWDEF.PLSA274' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina Title 'Incluir' 	Action 'VIEWDEF.PLSA274' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina Title 'Mudar Status' 	Action 'PLS274MF(.T.)' OPERATION 4 ACCESS 0 //''

Return aRotina



//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o modelo de dados da aplicação

@author  Renan Sakai
@version P12
@since   20/08/2018
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
	Local oStruBNV := FWFormStruct( 1, 'BNV' ) //Cria as estruturas a serem usadas no Modelo de Dados
	Local oModel // Modelo de dados construído

	oModel := MPFormModel():New('PLSA274') //Cria o objeto do Modelo de Dados
	oModel:AddFields( 'BNVMASTER', /*cOwner*/, oStruBNV ) //Adiciona ao modelo um componente de formulário
	oModel:SetDescription( "Gestão de Pedidos PLS x HAT" ) //Adiciona a descrição do Modelo de Dados
	oModel:GetModel( 'BNVMASTER' ):SetDescription( "Solicitação" ) //Adiciona a descrição dos Componentes do Modelo de Dados
	oModel:SetPrimaryKey({}) //Seta Chaves primarias

	// Retorna o Modelo de dados
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação

@author  Renan Sakai
@version P12
@since   20/08/2018
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
	Local oModel := FWLoadModel( 'PLSA274' ) //Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
	Local oStruBNV := FWFormStruct( 2, 'BNV' ) //Cria as estruturas a serem usadas na View
	Local oView //Interface de visualização construída

	//oStruBNR:RemoveField('BNR_CODIGO') //Retira o campo código da tela
	oView := FWFormView():New() //Cria o objeto de View
	oView:SetModel( oModel ) //Define qual Modelo de dados será utilizado
	oView:AddField( 'VIEW_BNV', oStruBNV, 'BNVMASTER' ) //Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS244GRV
Gravação da tabela BNV para rotinas de processamento

@author  Renan Sakai
@version P12
@since   20/08/2018
/*/
//-------------------------------------------------------------------
Function PLS274GRV( nOpc, aCamposBNV )
	local oModel	:= nil
	local aErro		:= {}
	local cLoadModel:= 'PLSA274'
	local nI		:= 0
	local nPos		:= 0
	local lRet := .T.

	oModel := FWLoadModel( cLoadModel )
	oModel:setOperation( nOpc )
	oModel:activate()

	oAuxBNV	:= oModel:getModel( 'BNVMASTER' )
	oStructBNV	:= oAuxBNV:getStruct()
	aAuxBNV	:= oStructBNV:getFields()

	if( nOpc <> MODEL_OPERATION_DELETE )
		begin Transaction
			//BNV
			for nI := 1 to len( aCamposBNV )
				if( nPos := aScan( aAuxBNV,{| x | allTrim( x[ 3 ] ) == allTrim( aCamposBNV[ nI,1 ] ) } ) ) > 0
					if !( lRet := oModel:setValue( 'BNVMASTER',aCamposBNV[ nI,1 ],aCamposBNV[ nI,2 ] ) )
						aErro := oModel:getErrorMessage()

						PlsPtuLog("------------------------------------------------------------------", "PLSA274.log")
						PlsPtuLog("Id do campo de origem: " 	+ ' [' + AllToChar( aErro[ 2 ] ) + ']', "PLSA274.log")
						PlsPtuLog("Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']', "PLSA274.log")
						PlsPtuLog("Conteudo do erro: " 			+ ' [' + AllToChar( aErro[ 9 ] ) + ']', "PLSA274.log")
						PlsPtuLog("------------------------------------------------------------------", "PLSA274.log")
						disarmTransaction()
						exit
					endif
				endIf
			next nI
		end Transaction
	endIf

	if( lRet := oModel:vldData() )
		oModel:commitData()
	else
		aErro := oModel:getErrorMessage()
		PlsPtuLog("------------------------------------------------------------------", "PLSA274.log")
		PlsPtuLog("Id do campo de origem: " 	+ ' [' + AllToChar( aErro[ 2 ] ) + ']', "PLSA274.log")
		PlsPtuLog("Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']', "PLSA274.log")
		PlsPtuLog("------------------------------------------------------------------", "PLSA274.log")
		disarmTransaction()
	endif

	oModel:deActivate()
	oModel:destroy()
	freeObj( oModel )
	oModel := nil
	delClassInf()

return lRet

Function PLS274MF(lManual, cStatus)
	Local lRet			:= .F.
	Local aArea			:= GetArea()
	Local aButtons		:= {}
	Local aItens		:= {"0=Pdte Envio",;
		"1=Erro criacao do pedido",;
		"2=Erro de envio",;
		"3=Pdte Proc HAT",;
		"4=Erro Proc Hat",;
		"5=Proc concluído"}
	Local oCmbStatus	:= Nil
	Local oDlg			:= Nil
	Local nOpca			:= 0
	Local bOK			:= { || nOpca := 1, oDlg:End() }
	Local bCancel		:= { || oDlg:End() }
	Local aCamposBNV	:= {}

	Default lManual		:= .T.
	Default cStatus	:= ""

	If lManual
		DEFINE MSDIALOG oDlg TITLE "Mudança de Status" FROM 000, 000  TO 200, 300 COLORS 0, 16777215 PIXEL

		@ 048, 029 MSCOMBOBOX oCmbStatus VAR cStatus ITEMS aItens SIZE 090, 010 OF oDlg COLORS 0, 16777215 PIXEL
		EnchoiceBar(oDlg,bOK,bCancel,,aButtons)

		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		nOpca := 1
	EndIf

	If nOpca == 1 .and. cStatus != ""
		If !lManual .OR. ApMsgNoYes ("Confirma a alteração do status?" ,"Plano de Saúde")
			aadd( aCamposBNV,{ "BNV_STATUS", cStatus })
			PLS274GRV( K_Alterar, aCamposBNV )
		EndIf
	Else
		lRet := .F.
		If lManual
			If cStatus == ""
				cMensagem := "Informe o status"
				Help( ,, 'HELP',,  cMensagem, 1, 0,,,,,,{'Esta alteração quando permitida será executada automaticamente pelo sistema.'})
			EndIf
		EndIf
	EndIf
	RestArea(aArea)

Return lRet