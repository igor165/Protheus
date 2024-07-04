#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PLSMGER.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA99D

Gestao de Pedidos da Integracao PLS x HAT 
@author  Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Function PLSA99D()

    Local oBrowse

    oBrowse := FWMBrowse():New() //Instanciamento da Classe de Browse
    oBrowse:SetAlias('B7X') //Definição da tabela do Browse  
    oBrowse:SetDescription("Funcionalidades Mobile Saúde") //Titulo da Browse
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
    ADD OPTION aRotina Title 'Visualizar'	Action 'VIEWDEF.PLSA99D' OPERATION 2 ACCESS 0 //'Visualizar'
    ADD OPTION aRotina Title 'Incluir' 	Action 'VIEWDEF.PLSA99D' OPERATION 3 ACCESS 0 //'Incluir'
    ADD OPTION aRotina Title 'Alterar'  Action 'VIEWDEF.PLSA99D' OPERATION 4 ACCESS 0 //'Alterar'
    ADD OPTION aRotina Title 'Excluir'  Action 'VIEWDEF.PLSA99D' OPERATION 5 ACCESS 0 //'Excluir'
    ADD OPTION aRotina Title 'Carregar Funcionalidades' Action 'PLS99DLOAD(.F.)' OPERATION 3 ACCESS 0 //'Carregar Funcionalidades'

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

    Local oStruB7X := FWFormStruct( 1, 'B7X' ) //Cria as estruturas a serem usadas no Modelo de Dados
    Local oModel // Modelo de dados construído
    Local aAux   := {}

    oModel := MPFormModel():New('PLSA99D') //Cria o objeto do Modelo de Dados
    oModel:AddFields( 'B7XMASTER', /*cOwner*/, oStruB7X ) //Adiciona ao modelo um componente de formulário
    oModel:SetDescription( "Funcionalidades Mobile Saúde" ) //Adiciona a descrição do Modelo de Dados
    oModel:GetModel( 'B7XMASTER' ):SetDescription( "Funcionalidades" ) //Adiciona a descrição dos Componentes do Modelo de Dados
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

    Local oModel := FWLoadModel( 'PLSA99D' ) //Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
    Local oStruB7X := FWFormStruct( 2, 'B7X' ) //Cria as estruturas a serem usadas na View
    Local oView //Interface de visualização construída
            
    //oStruBNR:RemoveField('BNR_CODIGO') //Retira o campo código da tela
    oView := FWFormView():New() //Cria o objeto de View
    oView:SetModel( oModel ) //Define qual Modelo de dados será utilizado
    oView:AddField( 'VIEW_B7X', oStruB7X, 'B7XMASTER' ) //Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)

Return oView                


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS244GRV
Gravação da tabela B7X para rotinas de processamento   

@author  Renan Sakai
@version P12
@since   20/08/2018
/*/
//-------------------------------------------------------------------
Function PLS99DGRV( nOpc, aCamposB7X )

    local oAuxB7X    := nil
    local oStructB7X := nil
    local oModel	 := nil
    local aAuxB7X	 := {}
    local aErro		 := {}
    local cLoadModel := 'PLSA99D'
    local nI		 := 0    
    local nPos		 := 0
    local lRet       := .T.

    oModel := FWLoadModel( cLoadModel )
    oModel:setOperation( nOpc )
    oModel:activate()

    oAuxB7X	:= oModel:getModel( 'B7XMASTER' )
    oStructB7X	:= oAuxB7X:getStruct()
    aAuxB7X	:= oStructB7X:getFields()   

    if( nOpc <> MODEL_OPERATION_DELETE )
        begin Transaction
            for nI := 1 to len( aCamposB7X )
                if( nPos := aScan( aAuxB7X,{| x | allTrim( x[ 3 ] ) == allTrim( aCamposB7X[ nI,1 ] ) } ) ) > 0
                    if !( lRet := oModel:setValue( 'B7XMASTER',aCamposB7X[ nI,1 ],aCamposB7X[ nI,2 ] ) )
                        aErro := oModel:getErrorMessage()				
                        
                        PlsPtuLog("------------------------------------------------------------------", "PLSA99D.log")
                        PlsPtuLog("Id do campo de origem: " 	+ ' [' + AllToChar( aErro[ 2 ] ) + ']', "PLSA99D.log")
                        PlsPtuLog("Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']', "PLSA99D.log")
                        PlsPtuLog("Conteudo do erro: " 			+ ' [' + AllToChar( aErro[ 9 ] ) + ']', "PLSA99D.log")
                        PlsPtuLog("------------------------------------------------------------------", "PLSA99D.log")
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
        PlsPtuLog("------------------------------------------------------------------", "PLSA99D.log")
        PlsPtuLog("Id do campo de origem: " 	+ ' [' + AllToChar( aErro[ 2 ] ) + ']', "PLSA99D.log")
        PlsPtuLog("Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']', "PLSA99D.log")
        PlsPtuLog("------------------------------------------------------------------", "PLSA99D.log")
        disarmTransaction()
    endIf

    oModel:deActivate()
    oModel:destroy()
    freeObj( oModel )
    oModel := nil
    delClassInf()

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS99DLOAD

@author  Renan Sakai
@version P12
@since   20/08/2018
/*/
//-------------------------------------------------------------------
Function PLS99DLOAD(lAuto)

    Local nX      := 0
    Local cMsg    := ''
    Local aCampos := {}
    Local aFunc   := {}
    Local lFind   := .F.
    Local lOk     := .F.
    Local lRet    := .F.
    Local cCodOpe := PlsIntPad()
    Default lAuto := .F.

    if lAuto
        lOk := .T.
    elseIf MsgYesNo("Deseja (re)carregar o cadastro de funcionalidades?")
        lOk := .T.
    endIf
        
    if lOk
        Aadd(aFunc,{cCodOpe,"11","EXTRATO DE UTILIZACAO E COPARTICIPACAO","1","0"})
        Aadd(aFunc,{cCodOpe,"13","EXTRATO DE AUTORIZACOES"               ,"1","0"})
        Aadd(aFunc,{cCodOpe,"14","DEBITOS (BOLETOS)"                     ,"1","0"})
        Aadd(aFunc,{cCodOpe,"20","DECLARACOES"                           ,"1","0"})
    
        B7X->(DbSetOrder(1)) //B7X_FILIAL+B7X_CODIGO

        for nX := 1 to len(aFunc)
            lFind   := .F.
            aCampos := {}	
            
            lFind := B7X->(DbSeek(xFilial("B7X")+aFunc[nX,1]+aFunc[nX,2] ))
            aadd( aCampos,{ "B7X_FILIAL", xFilial("B7X")} )
            aadd( aCampos,{ "B7X_CODOPE", aFunc[nX,1]} )
            aadd( aCampos,{ "B7X_CODIGO", aFunc[nX,2]} )
            aadd( aCampos,{ "B7X_DESCRI", aFunc[nX,3]} )
            aadd( aCampos,{ "B7X_ATIVO" , aFunc[nX,4]} )
            aadd( aCampos,{ "B7X_OCULTO", aFunc[nX,5]} )
            
            lRet := PLS99DGRV( iif(lFind,K_Alterar,K_Incluir), aCampos )
        next

        if lRet
            cMsg := "Carregamento realizado com sucesso."
            iif(lAuto,Conout(cMsg),MsgInfo(cMsg))
        else
            cMsg := "Não possível realizar o carregamento das funcionalidades. Consulte o arquivo plsa99d.log"
            iif(lAuto,Conout(cMsg),MsgInfo(cMsg))
        endIf
        
    endIf

Return