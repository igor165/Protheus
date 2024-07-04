#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PLSMGER.CH"
#INCLUDE "hatActions.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA275
Cadastro de Transacoes Integracao PLS x HAT

@author  Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Function PLSA275()

Local oBrowse

oBrowse := FWMBrowse():New() //Instanciamento da Classe de Browse
oBrowse:SetAlias('BNN') //Definição da tabela do Browse 
oBrowse:SetDescription("Transações Integração PLS x HAT") //Titulo da Browse
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
ADD OPTION aRotina Title 'Visualizar'	Action 'VIEWDEF.PLSA275' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title 'Carregar Transações' 	Action 'PLS275LOAD' OPERATION 3 ACCESS 0 //'Carregar Padrão'     
ADD OPTION aRotina Title 'Alterar' 	Action 'VIEWDEF.PLSA275' OPERATION 4 ACCESS 0 //'Carregar Padrão'    

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
Local oStruBNN := FWFormStruct( 1, 'BNN' ) //Cria as estruturas a serem usadas no Modelo de Dados

Local oModel //Modelo de dados construído
Local aAux   := {}

oModel := MPFormModel():New('PLSA275') //Cria o objeto do Modelo de Dados

oModel:AddFields( 'BNNMASTER', /*cOwner*/, oStruBNN ) //Adiciona ao modelo um componente de formulário  
oModel:SetDescription( "Transações Integração PLS x HAT" ) //Adiciona a descrição do Modelo de Dados 
oModel:GetModel( 'BNNMASTER' ):SetDescription( "Solicitação" ) //Adiciona a descrição dos Componentes do Modelo de Dados 
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

Local oModel   := FWLoadModel( 'PLSA275' ) //Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oStruBNN := FWFormStruct( 2, 'BNN' ) // Cria as estruturas a serem usadas na View
Local oView //Interface de visualização construída

oView := FWFormView():New() //Cria o objeto de View
oView:SetModel( oModel ) //Define qual Modelo de dados será utilizado
oView:AddField( 'VIEW_BNN', oStruBNN, 'BNNMASTER' ) //Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS244GRV
Gravação da tabela BNN para rotinas de processamento   

@author  Renan Sakai
@version P12
@since   20/08/2018
/*/
//-------------------------------------------------------------------
Function PLS275GRV( nOpc, aCamposBNN )
local oAux		:= nil
local oStruct	:= nil
local oModel	:= nil
local aAux		:= {}
local aErro		:= {}
local cLoadModel:= 'PLSA275'
local nI		:= 0    
local nX        := 0
local nPos		:= 0
local lRet := .T.

oModel := FWLoadModel( cLoadModel )
oModel:setOperation( nOpc )
oModel:activate()

oAuxBNN	:= oModel:getModel( 'BNNMASTER' )
oStructBNN	:= oAuxBNN:getStruct()
aAuxBNN	:= oStructBNN:getFields()

if( nOpc <> MODEL_OPERATION_DELETE )
   begin Transaction
		//BNN
  		for nI := 1 to len( aCamposBNN )
			if( nPos := aScan( aAuxBNN,{| x | allTrim( x[ 3 ] ) == allTrim( aCamposBNN[ nI,1 ] ) } ) ) > 0
				if !( lRet := oModel:setValue( 'BNNMASTER',aCamposBNN[ nI,1 ],aCamposBNN[ nI,2 ] ) )
					aErro := oModel:getErrorMessage()
					
					PlsPtuLog("------------------------------------------------------------------", "PLSA275.log")
					PlsPtuLog("Id do campo de origem: " 	+ ' [' + AllToChar( aErro[ 2 ] ) + ']', "PLSA275.log")
					PlsPtuLog("Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']', "PLSA275.log")
					PlsPtuLog("Conteudo do erro: " 			+ ' [' + AllToChar( aErro[ 9 ] ) + ']', "PLSA275.log")						
					PlsPtuLog("------------------------------------------------------------------", "PLSA275.log")
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
	PlsPtuLog("------------------------------------------------------------------", "PLSA275.log")
	PlsPtuLog("Id do campo de origem: " 	+ ' [' + AllToChar( aErro[ 2 ] ) + ']', "PLSA275.log")
	PlsPtuLog("Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']', "PLSA275.log")
	PlsPtuLog("------------------------------------------------------------------", "PLSA275.log")
	disarmTransaction()
endif

oModel:deActivate()
oModel:destroy()
freeObj( oModel )
oModel := nil
delClassInf()

return lRet               


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS275GRV
Carrega os EndPoints padrao do HAT 

@author  Renan Sakai
@version P12
@since   20/08/2018
/*/
//-------------------------------------------------------------------
Function PLS275LOAD()
Local nX := 0 
Local aCampos := {}
Local aTransac := {}
Local lFind   := .F.

Aadd(aTransac,{_beneficiaries_inc,"Inclusao Beneficiarios","v1","beneficiaries"})
Aadd(aTransac,{_beneficiaries_alt,"Alteracao Beneficiarios","v1","beneficiaries"})
Aadd(aTransac,{_healthProviders_inc ,"Inclusao Prestadores","v1","healthProviders"})
Aadd(aTransac,{_healthProviders_alt ,"Alteracao Prestadores","v1","healthProviders"})
Aadd(aTransac,{_clinicalStaff_BC1_inc ,"Inc Corpo Clinico - BC1","v1","clinicalStaff"})
Aadd(aTransac,{_clinicalStaff_BC1_alt ,"Alt Corpo Clinico - BC1","v1","clinicalStaff"})
Aadd(aTransac,{_persons_inc,"Inclusao Vidas","v1","persons"})    
Aadd(aTransac,{_persons_alt,"Alteracao Vidas","v1","persons"})   
Aadd(aTransac,{_preExistingDiseases_inc,"Inclusao Doencas Pre Existentes","v1","preExistingDiseases"})
Aadd(aTransac,{_preExistingDiseases_alt,"Alteracao Doencas Pre Existentes","v1","preExistingDiseases"})
Aadd(aTransac,{_beneficiaryStatus_blo,"Bloqueio Beneficiarios","v1","beneficiaryStatus"})
Aadd(aTransac,{_beneficiaryStatus_desblo ,"Desbloqueio Beneficiarios","v1","beneficiaryStatus"})
Aadd(aTransac,{_healthProviderStatus_blo,"Bloqueio Prestadores","v1","healthProviderStatus"})
Aadd(aTransac,{_healthProviderStatus_desblo,"Desbloqueio Prestadores","v1","healthProviderStatus"})
Aadd(aTransac,{_attendanceLocations_inc,"Inclusao Locais de Atendimento","v1","attendanceLocations"})
Aadd(aTransac,{_attendanceLocations_alt,"Alteracao Locais de Atendimento","v1","attendanceLocations"})
Aadd(aTransac,{_healthProviderSpecialties_inc,"Inclusao de Especialidades/Locais de Atend","v1","healthProviderSpecialties"})
Aadd(aTransac,{_healthProviderSpecialties_alt,"Alteracao de Especialidades/Locais de Atend","v1","healthProviderSpecialties"})
Aadd(aTransac,{_coverageProcedureLevel_BFG_inc ,"Inclusao Cobertura Beneficiarios - BFG","v1","coverages/procedureLevel"})
Aadd(aTransac,{_coverageProcedureLevel_BFG_alt ,"Alteracao Cobertura Beneficiarios - BFG","v1","coverages/procedureLevel"})
Aadd(aTransac,{_coverageProcedureLevel_BFD_inc ,"Inc Cobert Procedimento Familia - BFD","v1","coverages/procedureLevel"})
Aadd(aTransac,{_coverageProcedureLevel_BFD_alt ,"Alt Cobert Procedimento Familia - BFD","v1","coverages/procedureLevel"})
Aadd(aTransac,{_coverageGroupLevel_BFC_inc ,"Inc Cobert Grupo Cobert Familia - BFC","v1","coverages/level"})
Aadd(aTransac,{_coverageGroupLevel_BFC_alt ,"Alt Cobert Grupo Cobert Familia - BFC","v1","coverages/level"})
Aadd(aTransac,{_coverageProcedureLevel_BT8_inc ,"Inc Cobert Procedimento Contrato - BT8","v1","coverages/procedureLevel"})
Aadd(aTransac,{_coverageProcedureLevel_BT8_alt ,"Alt Cobert Procedimento Contrato - BT8","v1","coverages/procedureLevel"})
Aadd(aTransac,{_coverageGroupLevel_BT7_inc,"Inc Cobert Grupo Cobert Contrato - BT7","v1","coverages/level"})
Aadd(aTransac,{_coverageGroupLevel_BT7_alt,"Alt Cobert Grupo Cobert Contrato - BT7","v1","coverages/level"})
Aadd(aTransac,{_coverageProcedureLevel_BB2_inc ,"Inc Cobert Procedimento Produto - BB2","v1","coverages/procedureLevel"})
Aadd(aTransac,{_coverageProcedureLevel_BB2_alt ,"Alt Cobert Procedimento Produto - BB2","v1","coverages/procedureLevel"})
Aadd(aTransac,{_coverageGroupLevel_BRV_inc,"Inc Cobert Grupo Cobert Produto - BRV","v1","coverages/level"})
Aadd(aTransac,{_coverageGroupLevel_BRV_alt,"Alt Cobert Grupo Cobert Produto - BRV","v1","coverages/level"})
Aadd(aTransac,{_billing_BCI_alt,"Alt Status do Lote de faturamento - BCI","v1","batchesAuthorization/integration"})
Aadd(aTransac,{_coverageGroupLevel_BG8_inc,"Inc Eventos Grupos Cobertura - BG8","v1","coverages/group"})
Aadd(aTransac,{_coverageGroupLevel_BG8_alt,"Alt Eventos Grupos Cobertura - BG8","v1","coverages/group"})
Aadd(aTransac,{_cancel_BEA_atu,"Altualiza cancelamento - BEA","v1","authorizations"})

BNN->(DbSetOrder(1))//BNN_FILIAL+BNN_CODTRA
for nX := 1 to len(aTransac)
	lFind   := .F.
	aCampos := {}	
	
	IIF(BNN->(MsSeek(xFilial("BNN")+aTransac[nX][1] )),lFind := .T.,lFind := .F.)  
	aadd( aCampos,{ "BNN_FILIAL", xFilial("BNN")} )
	aadd( aCampos,{ "BNN_CODTRA", aTransac[nX][1]} )
	aadd( aCampos,{ "BNN_DESTRA", aTransac[nX][2]} )
	aadd( aCampos,{ "BNN_VERSAO", aTransac[nX][3]} )
	aadd( aCampos,{ "BNN_ENDPOI", aTransac[nX][4]} )
	aadd( aCampos,{ "BNN_PRIORI", iif(lFind,BNN->BNN_PRIORI,"0")} )

	PLS275GRV( iif(lFind,K_Alterar,K_Incluir), aCampos )
	
next

MsgInfo("Inclusao realizada com sucesso.")

Return
//