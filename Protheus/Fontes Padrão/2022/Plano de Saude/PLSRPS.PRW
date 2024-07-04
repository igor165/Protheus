#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRPS
Abre a tela de manutenção RPS
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PLSRPS(lAutoma)

Local oBrowse
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	 //Para fins de automação

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('BAU')
oBrowse:SetDescription('Prestador x RPS')
obrowse:AddLegend( "BAU_GERRPS == '1' .AND. BAU_ENVRPS $ ' ,0'", "YELLOW" , "Pendente de envio de inclusão no RPS")
obrowse:AddLegend( "BAU_GERRPS == '1' .AND. BAU_ENVRPS == '1'" , "GREEN"  , "Já enviado no RPS") 
obrowse:AddLegend( "BAU_GERRPS == '1' .AND. BAU_ENVRPS == '2'" , "BLACK"  , "Excluído no RPS") 
obrowse:AddLegend( "BAU_GERRPS == '1' .AND. BAU_ENVRPS == '3'" , "BLUE"   , "Pendente de envio de alteração no RPS") 
obrowse:AddLegend( "BAU_GERRPS == '1' .AND. BAU_ENVRPS == '4'" , "GRAY"   , "Pendente de envio de exclusão no RPS") 
obrowse:AddLegend( "BAU_GERRPS != '1'"                         , "RED"    , "Não gera RPS") 
iif(!lAutoma, oBrowse:Activate(), '')

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

Add Option aRotina Title 'Visualizar' Action 'VIEWDEF.PLSRPS' Operation 2 Access 0
Add Option aRotina Title 'Alterar'    Action 'VIEWDEF.PLSRPS' Operation 4 Access 0
Add Option aRotina Title 'Selecionar' Action 'PLSARPS2(BAU->BAU_CODIGO)' Operation 4 Access 0

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel // Modelo de dados construído
Local oStrBAU:= FWFormStruct(1,'BAU', { |cCampo| PLSRPSFI(cCampo)} )// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que iráconsiderar

oModel := MPFormModel():New( 'PLSRPS', , , {|oModel| PGRVRPSLAU(oModel) } ) // Cria o objeto do Modelo de Dados e insere a funçao de pós-validação

oModel:addFields('MasterBAU',/*cOwner*/,oStrBAU)  // Adiciona ao modelo um componente de formulário
oStrBAU:SetProperty( 'BAU_ANSOPI' , MODEL_FIELD_WHEN, {|| .T.})

oModel:GetModel('MasterBAU'):SetDescription('RdA x RPS') // Adiciona a descrição do Modelo de Dados

Return oModel // Retorna o Modelo de dados


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() // Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oView  // Interface de visualização construída
Local oModel := FWLoadModel( 'PLSRPS' ) // Cria as estruturas a serem usadas na View
Local oStrBAU:= FWFormStruct(2, 'BAU', { |cCampo| PLSRPSFI(cCampo) } )

oView := FWFormView():New() // Cria o objeto de View

oView:SetModel(oModel)		// Define qual Modelo de dados será utilizado

oView:AddField('ViewBAU' , oStrBAU,'MasterBAU' ) // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)

oView:CreateHorizontalBox( 'SUPERIOR' , 100 ) // Cria um "box" horizontal para receber cada elemento da view e Associa à Aba Correspondente

oStrBAU:SetProperty( 'BAU_ENVRPS', MVC_VIEW_CANCHANGE, .F.)
oStrBAU:SetProperty( 'BAU_ANSOPI', MVC_VIEW_CANCHANGE, .T.)

oStrBAU:SetNoFolder()

oView:SetOwnerView('ViewBAU','SUPERIOR') // Relaciona o identificador (ID) da View com o "box" para exibição

Return oView // Retorna o objeto de View criado


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRPSFI
Tratamento para ajustar os campos a ser utilizados da tabela B9Q.
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PLSRPSFI(cCampo)

Local lRet	:= .F.

If cCampo == "BAU_CODIGO" 
	lRet := .T.
EndIf

If cCampo == "BAU_NOME  " 
	lRet := .T.
EndIf

If cCampo == "BAU_ENVRPS" 
	lRet := .T.
EndIf

If cCampo == "BAU_RECPRO" 
	lRet := .T.
EndIf

If cCampo == "BAU_CLAEST" 
	lRet := .T.
EndIf

If cCampo == "BAU_DTINCT" 
	lRet := .T.
EndIf

If cCampo == "BAU_DTINSE" 
	lRet := .T.
EndIf

If cCampo == "BAU_TIPDIS" 
	lRet := .T.
EndIf

If cCampo == "BAU_URGEME" 
	lRet := .T.
EndIf

If cCampo == "BAU_TIPDIS" 
	lRet := .T.
EndIf

If cCampo == "BAU_GERRPS" 
	lRet := .T.
EndIf

If cCampo == "BAU_CONTRA" 
	lRet := .T.
EndIf

If cCampo == "BAU_ANSOPI" 
	lRet := .T.
EndIf

If cCampo == "BAU_TIPPRE" 
	lRet := .T.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PGRVRPSLAU
Função de commit do Model. (Tabela BAU)
Grava o modelo e verifica se deve gravar as tabelas de geração de RPS, caso
deva gravar, realiza a gravação
@author Oscar Zanin
@since 04/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PGRVRPSLAU(oModel)

Local aAlt	:= {}
Local cTpArq	:= ""
Local oBAU	:= oModel:getModel("MasterBAU")
Local aVerifica := {"BAU_NOME", "BAU_RECPRO", "BAU_CLAEST", "BAU_DTINCT", "BAU_DTINSE", "BAU_TIPDIS", "BAU_URGEME", "BAU_TIPDIS", "BAU_ANSOPI", "BAU_CONTRA" }
Local nI	:= 1
Local aChvAnt	  := { "DEFAULT", "DEFAULT", "DEFAULT" }
Local aB84RPS := {}
Local nRPSZ := 0

FWFormCommit(oModel)

If oBAU:GetValue("BAU_GERRPS") == "1"
	For nI := 1 To Len(aVerifica)
		If oBAU:IsFieldUpdated(aVerifica[nI])
			aadd(aAlt, aVerifica[nI])
		EndIf
	Next
	
	If Len(aAlt) > 0
		If oBAU:GetValue("BAU_ENVRPS") $ "1,3"
			cTpArq := "1"
		Elseif oBAU:GetValue("BAU_ENVRPS") $ " ,0"
			cTpArq := "0"
		EndIf
		aB84RPS := buscaB84(BAU->BAU_CODIGO)
		If Len(aB84RPS) > 0
			for nRPSZ := 1 to Len(aB84RPS)
				PLSRPSALT(PLSINTPAD(), BAU->(Recno()), 0, aB84RPS[nRPSZ], aAlt, cTpArq, aChvAnt, /*aIncLoc*/, /*ldestroy*/, /*lExclRda*/, .T.)
			next
		else
			PLSRPSALT(PLSINTPAD(), BAU->(Recno()), 0, 0, aAlt, cTpArq, aChvAnt)
		endIf
	EndIf
	
	If cTpArq == "1" .AND. BAU->BAU_ENVRPS == "1"
		BAU->(RecLock("BAU", .F.))
			BAU->BAU_NREDUZ := Left(allTrim(BAU->BAU_NOME), TamSX3("BAU_NREDUZ")[1])
			BAU->BAU_ENVRPS := "3"
		BAU->(MsUnLock())
	endIf
	
	PLRP5clr()
EndIf

return .T.
