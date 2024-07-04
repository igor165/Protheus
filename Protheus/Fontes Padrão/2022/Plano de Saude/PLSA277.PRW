#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PLSMGER.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA277

Gestao de Pedidos da Integracao PLS x HAT 
@author  Renan Sakai
@version P12
@since   09/10/18
/*/
//-------------------------------------------------------------------
Function PLSA277()

Local oBrowse

oBrowse := FWMBrowse():New() //Instanciamento da Classe de Browse
oBrowse:SetAlias('BWB') //Definição da tabela do Browse  
oBrowse:SetDescription("Erros Pedidos HAT") //Titulo da Browse
oBrowse:Activate() //Ativação da Classe

Return Nil
  
 
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define o menu da aplicação 

@author  Renan Sakai
@version P12
@since   09/10/18
/*/
//------------------------------------------------------------------- 
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina Title 'Visualizar'	Action 'VIEWDEF.PLSA277' OPERATION 2 ACCESS 0 //'Visualizar'
//ADD OPTION aRotina Title 'Incluir' 	Action 'VIEWDEF.PLSA277' OPERATION 3 ACCESS 0 //'Incluir'

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
Local oStruBWB := FWFormStruct( 1, 'BWB' ) //Cria as estruturas a serem usadas no Modelo de Dados
Local oModel // Modelo de dados construído
Local aAux   := {}

oModel := MPFormModel():New('PLSA277') //Cria o objeto do Modelo de Dados
oModel:AddFields( 'BWBMASTER', /*cOwner*/, oStruBWB ) //Adiciona ao modelo um componente de formulário
oModel:SetDescription( "Erros Pedidos HAT" ) //Adiciona a descrição do Modelo de Dados
oModel:GetModel( 'BWBMASTER' ):SetDescription( "Erros" ) //Adiciona a descrição dos Componentes do Modelo de Dados
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
Local oModel := FWLoadModel( 'PLSA277' ) //Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oStruBWB := FWFormStruct( 2, 'BWB' ) //Cria as estruturas a serem usadas na View
Local oView //Interface de visualização construída
		
//oStruBNR:RemoveField('BNR_CODIGO') //Retira o campo código da tela
oView := FWFormView():New() //Cria o objeto de View
oView:SetModel( oModel ) //Define qual Modelo de dados será utilizado
oView:AddField( 'VIEW_BWB', oStruBWB, 'BWBMASTER' ) //Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)


Return oView                


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS244GRV
Gravação da tabela BWB para rotinas de processamento   

@author  Renan Sakai
@version P12
@since   20/08/2018
/*/
//-------------------------------------------------------------------
Function PLS277GRV( nOpc, aCamposBWB )
local oAux		:= nil
local oStruct	:= nil
local oModel	:= nil
local aAux		:= {}
local aErro		:= {}
local cLoadModel:= 'PLSA277'
local nI		:= 0    
local nX        := 0
local nPos		:= 0
local lRet := .T.

oModel := FWLoadModel( cLoadModel )
oModel:setOperation( nOpc )
oModel:activate()

oAuxBWB	:= oModel:getModel( 'BWBMASTER' )
oStructBWB	:= oAuxBWB:getStruct()
aAuxBWB	:= oStructBWB:getFields()   

if( nOpc <> MODEL_OPERATION_DELETE )
	begin Transaction
		//BWB
  		for nI := 1 to len( aCamposBWB )
			if( nPos := aScan( aAuxBWB,{| x | allTrim( x[ 3 ] ) == allTrim( aCamposBWB[ nI,1 ] ) } ) ) > 0
				if !( lRet := oModel:setValue( 'BWBMASTER',aCamposBWB[ nI,1 ],aCamposBWB[ nI,2 ] ) )
					aErro := oModel:getErrorMessage()				
					 
					PlsPtuLog("------------------------------------------------------------------", "PLSA277.log")
					PlsPtuLog("Id do campo de origem: " 	+ ' [' + AllToChar( aErro[ 2 ] ) + ']', "PLSA277.log")
					PlsPtuLog("Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']', "PLSA277.log")
					PlsPtuLog("Conteudo do erro: " 			+ ' [' + AllToChar( aErro[ 9 ] ) + ']', "PLSA277.log")
					PlsPtuLog("------------------------------------------------------------------", "PLSA277.log")
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
	PlsPtuLog("------------------------------------------------------------------", "PLSA277.log")
	PlsPtuLog("Id do campo de origem: " 	+ ' [' + AllToChar( aErro[ 2 ] ) + ']', "PLSA277.log")
	PlsPtuLog("Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']', "PLSA277.log")	
	PlsPtuLog("------------------------------------------------------------------", "PLSA277.log")
	disarmTransaction()
endif

oModel:deActivate()
oModel:destroy()
freeObj( oModel )
oModel := nil
delClassInf()

return lRet
