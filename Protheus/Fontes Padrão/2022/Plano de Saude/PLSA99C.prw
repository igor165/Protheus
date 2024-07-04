#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PLSMGER.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA99C

Cadastro de usuários da API Mobile Saúde
@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Function PLSA99C(lAuto)

    Local oBrowse
    Default lAuto := .F.

    oBrowse := FWMBrowse():New() //Instanciamento da Classe de Browse
    oBrowse:SetAlias('B7Y') //Definição da tabela do Browse  
    oBrowse:SetDescription("Cadastro de usuários da API Mobile Saúde") //Titulo da Browse

    oBrowse:AddLegend( "B7Y_STATUS=='1'", "GREEN", "Ativo"  ) 
    oBrowse:AddLegend( "B7Y_STATUS=='0'", "RED"  , "Bloqueado"  ) 
    iif(!lAuto,oBrowse:Activate(),nil)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
DEFINE o menu da aplicação 

@author  Renan Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.PLSA99C' OPERATION 2 ACCESS 0 //'Visualizar'
    ADD OPTION aRotina Title 'Incluir' 	  Action 'VIEWDEF.PLSA99C' OPERATION 3 ACCESS 0 //'Incluir'
    ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.PLSA99C' OPERATION 4 ACCESS 0 //'Alterar'
    ADD OPTION aRotina Title 'Excluir'    Action 'VIEWDEF.PLSA99C' OPERATION 5 ACCESS 0 //'Excluir'
    ADD OPTION aRotina Title 'Redefinir Chaves'    Action 'P99CKeyGen(.T.)' OPERATION 4 ACCESS 0 //'Redefinir Chaves'

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
DEFINE o modelo de dados da aplicação   

@author  Renan Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Static Function ModelDef()

    Local oStruB7Y := FWFormStruct( 1, 'B7Y' ) //Cria as estruturas a serem usadas no Modelo de Dados
    Local oModel // Modelo de dados construído
    
    oModel := MPFormModel():New('PLSA99C',,{|oModel| P99CVldVie( oModel ) } ) //Cria o objeto do Modelo de Dados  //oModel := MPFormModel():New('PLSA99C')
    oModel:AddFields( 'B7YMASTER', /*cOwner*/, oStruB7Y ) //Adiciona ao modelo um componente de formulário
    oModel:SetDescription( "Cadastro de usuários da API Mobile Saúde" ) //Adiciona a descrição do Modelo de Dados
    oModel:GetModel( 'B7YMASTER' ):SetDescription( "Cadastro Usuários" ) //Adiciona a descrição dos Componentes do Modelo de Dados
    oModel:SetPrimaryKey({}) //Seta Chaves primarias


// Retorna o Modelo de dados
Return oModel   
        

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
DEFINE o modelo de dados da aplicação 

@author  Renan Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Static Function ViewDef()

    Local oModel   := FWLoadModel( 'PLSA99C' ) //Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
    Local oStruB7Y := FWFormStruct( 2, 'B7Y' ) //Cria as estruturas a serem usadas na View
    Local oView //Interface de visualização construída
            
    //oStruBNR:RemoveField('BNR_CODIGO') //Retira o campo código da tela
    oView := FWFormView():New() //Cria o objeto de View
    oView:SetModel( oModel ) //DEFINE qual Modelo de dados será utilizado
    oView:AddField( 'VIEW_B7Y', oStruB7Y, 'B7YMASTER' ) //Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)

Return oView                


//-------------------------------------------------------------------
/*/{Protheus.doc} P99CVldVie
Faz a validacao do modelo 

@author  Renan Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Function P99CVldVie( oModel )
   
    Local lRet := .T.
    Local nOperation := oModel:GetOperation() 
    Local oModelB7Y  := oModel:GetModel( 'B7YMASTER' ) 

	//Inativa todos os tokens vinculados ao client ID / chave que está sendo inativada 
	if nOperation == MODEL_OPERATION_DELETE .Or. (nOperation == MODEL_OPERATION_UPDATE .And. oModelB7Y:GetValue('B7Y_STATUS') == '0')
		DelTokens(oModelB7Y:GetValue('B7Y_CLIID'), oModelB7Y:GetValue('B7Y_SECRET'))
    endIf

	/*if !lRet
        Help( ,,'Erro na validacao',,cMsgRet, 1, 0 )
    endIf*/

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} DelTokens
DelTokens

@author  Renan Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Static Function DelTokens(cClientId, cSecret)
	
    Local cSql := "" 

	cSql := " UPDATE "+RetSqlName("BJZ")+" SET BJZ_ATIVO = '0', BJZ_DATBLO = '"+dtos(date())+"' "
	cSql += " WHERE BJZ_FILIAL = '"+xFilial("BJZ")+"' "
    cSql += " AND BJZ_CODOPE = '"+PlsIntPad()+"' "
	cSql += " AND BJZ_CLIID = '"+cClientId+"' "
	cSql += " AND BJZ_SECRET = '"+cSecret+"' "
	cSql += " AND D_E_L_E_T_ = ' ' "		
	TcSqlExec(cSql)		

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} P99CGerCli
DEFINE o modelo de dados da aplicação 

@author  Renan Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Function P99CGerCli()

	Local nX := Randomize( 1, 1750 )
	Local nY := Randomize( nX, 100000 )
	Local aTime  := {}
	Local cChave := ""
	
	GetTimeStamp(Date() , aTime)
	cChave := Alltrim(Str(nX)) + aTime[1] + cValToChar(nY)
	cChave := Md5(cChave)

Return(Encode64(cChave))


//-------------------------------------------------------------------
/*/{Protheus.doc} P99CKeyGen
DEFINE o modelo de dados da aplicação 

@author  Renan Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Function P99CKeyGen(lAltera)

    Local cSecret    := ''
	Local lOk        := .T.
    Local aTime      := {}
	Local aB7YFields := {}
    Local nX         := Randomize( 50, 100 )
	Local nY         := Randomize( nX, 100000 )
    Default lAltera  := .F.

	if lAltera .And. !MsgYesNo("Deseja gerar uma nova chave? As integrações que utilizam a chave anterior serão desativadas.")
		lOk := .F.
	endIf

    if lOk
        GetTimeStamp(Date() , aTime)
        nY      := (Randomize( 5, 100 )*Val(aTime[1]))/(Val(aTime[1])/2)
        cSecret := Md5(Alltrim(Str(nY)))

        if lAltera
            aadd(aB7YFields,{ "B7Y_FILIAL", xFilial("B7Y") })
            aadd(aB7YFields,{ "B7Y_USRID" , B7Y->B7Y_USRID  })
            aadd(aB7YFields,{ "B7Y_NOME"  , B7Y->B7Y_NOME   })
            aadd(aB7YFields,{ "B7Y_DESCRI", B7Y->B7Y_DESCRI })
            aadd(aB7YFields,{ "B7Y_STATUS", B7Y->B7Y_STATUS })
            aadd(aB7YFields,{ "B7Y_CLIID" , B7Y->B7Y_CLIID  })
            aadd(aB7YFields,{ "B7Y_SECRET", cSecret })
 
            PLS99CGRV( MODEL_OPERATION_UPDATE, aB7YFields )
        endIf
    endIf

Return cSecret


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS99CGRV
Gravação da tabela B7Y para rotinas de processamento   

@author  Renan Sakai
@version P12
@since   20/08/2018
/*/
//-------------------------------------------------------------------
Function PLS99CGRV( nOpc, aB7YFields )
    
    Local oAux		 := nil
    Local oStructB7Y := nil
    Local oModel	 := nil
    Local aAuxB7Y    := {}
    Local aErro		 := {}
    Local cLoadModel := 'PLSA99C'
    Local nI		 := 0    
    Local nX         := 0
    Local nPos		 := 0
    Local lRet       := .T.

    oModel := FWLoadModel( cLoadModel )
    oModel:setOperation( nOpc )
    oModel:activate()

    oAuxB7Y	:= oModel:getModel( 'B7YMASTER' )
    oStructB7Y	:= oAuxB7Y:getStruct()
    aAuxB7Y	:= oStructB7Y:getFields()   

    if( nOpc <> MODEL_OPERATION_DELETE )
        begin Transaction
          
            for nI := 1 to len( aB7YFields )
                if( nPos := aScan( aAuxB7Y,{| x | allTrim( x[ 3 ] ) == allTrim( aB7YFields[ nI,1 ] ) } ) ) > 0
                    if !( lRet := oModel:setValue( 'B7YMASTER',aB7YFields[ nI,1 ],aB7YFields[ nI,2 ] ) )
                        aErro := oModel:getErrorMessage()				
                        
                        PlsPtuLog("------------------------------------------------------------------", "PLSA99C.log")
                        PlsPtuLog("Id do campo de origem: " 	+ ' [' + AllToChar( aErro[ 2 ] ) + ']', "PLSA99C.log")
                        PlsPtuLog("Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']', "PLSA99C.log")
                        PlsPtuLog("Conteudo do erro: " 			+ ' [' + AllToChar( aErro[ 9 ] ) + ']', "PLSA99C.log")
                        PlsPtuLog("------------------------------------------------------------------", "PLSA99C.log")
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
        PlsPtuLog("------------------------------------------------------------------", "PLSA99C.log")
        PlsPtuLog("Id do campo de origem: " 	+ ' [' + AllToChar( aErro[ 2 ] ) + ']', "PLSA99C.log")
        PlsPtuLog("Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']', "PLSA99C.log")	
        PlsPtuLog("------------------------------------------------------------------", "PLSA99C.log")
        disarmTransaction()
    endif

    oModel:deActivate()
    oModel:destroy()
    freeObj( oModel )
    oModel := nil
    delClassInf()

Return lRet