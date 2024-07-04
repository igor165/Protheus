#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "LJINTEGRATIONCONFIGURATION.CH"

Function LjIntegrationConfiguration ; Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe LjIntegrationConfiguration
Classe orquestradora, responsável por organizar os dados e direcionar o fluxo

@type    class
@since   11/05/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Class LjIntegrationConfiguration 

    Data cProduct            as Character
    Data cPos                as Character
	Data oLjAuthentication   as Object      //Objeto do tipo LjAuthentication
    Data oMessageError       as Object
	
	Method New(cProduct, cPos, cEnvironment)   
	Method StartInterface()
    Method GetProductComponents()
    Method GetaServicesComponents()
    Method GetToken()
    Method GetEnvironment(cServiceCode)
    Method GetMessage()
    Method GetComponent(cIdComponent)

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@type    method
@param   cProduct, Caractere, Produto que será integrado
@param   cPos, Caractere, Código da estação
@return  LjIntegrationConfiguration, Objeto, Objeto instanciado
@author  Rafael Tenorio da Costa
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method New(cProduct, cPos) Class LjIntegrationConfiguration

    Self:cProduct            := cProduct
    Self:cPos                := cPos
    Self:oLjAuthentication   := LjAuthentication():New(Self:cProduct, Self:cPos)
    Self:oMessageError       := LjMessageError():New()
    
Return self

//-------------------------------------------------------------------
/*/{Protheus.doc} StartInterface
Interação com a interface de configuração

@type    method
@param   lExclusao, Lógico, Define se é exclusão
@return  Lógico, Define se interação foi feita corretamente
@author  Rafael Tenorio da Costa
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method StartInterface(lExclusao) Class LjIntegrationConfiguration

    Local lRetorno  := .T.
    Local oModelMVC := Nil
    Local oModelDet := Nil
    Local aBotoes   := {{.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.T.,STR0001}, {.T.,STR0002}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}}    //"Confirmar"   //"Cancelar"
    Local oProduto  := self:GetProductComponents()
    Local aServicos := self:GetaServicesComponents()
    Local nServ     := 0
    Local nQtdServ  := Len(aServicos)
    Local nOperacao := IIF(lExclusao, MODEL_OPERATION_DELETE, MODEL_OPERATION_UPDATE)

    //Seta estação que será utilizada para filtrar a tabela MIJ
    LjCfInSEst(self:cPos)

    oModelMVC := FWLoadModel("LJCFGINTEG")
    oModelMVC:SetOperation(nOperacao)

    If lExclusao

        MII->( DbSetOrder(1) )  //MII_FILIAL + MII_PRODUT
        If MII->( DbSeek( xFilial("MII") + self:cProduct) )

            MIJ->( DbSetOrder(1) )  //MIJ_FILIAL + MIJ_PRODUT + MIJ_LGCOD + MIJ_SIGLA                           //TENORIO
            If MIJ->( DbSeek( xFilial("MIJ") + Padr(self:cProduct, TamSx3("MIJ_PRODUT")[1]) + self:cPos) )      //TENORIO

                oModelMVC:Activate()

                If oModelMVC:VldData() .And. oModelMVC:CommitData()
                    lRetorno := .T.
                Else
                    lRetorno := .F.
                    LjxjMsgErr(STR0003 + AllTrim( oModelMVC:GetErrorMessage() ), /*cSolucao*/, "LjIntegrationConfiguration")    //"Não foi possível efetuar a exclusão dos dados da Integração RAAS: "
                EndIf
            EndIf
        EndIf
	
    Else

        oModelMVC:Activate()

        oModelMVC:SetValue("MIIMASTER", "MII_FILIAL", xFilial("MII")   )
        oModelMVC:SetValue("MIIMASTER", "MII_PRODUT", self:cProduct    )
        oModelMVC:SetValue("MIIMASTER", "MII_CONFIG", oProduto:ToJson())

        oModelDet := oModelMVC:GetModel("MIJDETAIL")

        For nServ:=1 To nQtdServ

            If nServ > oModelDet:Length()
                oModelDet:AddLine()
            Else
                oModelDet:GoLine(nServ)
            EndIf

            oModelMVC:SetValue("MIJDETAIL", "MIJ_FILIAL", xFilial("MIJ")                )
            oModelMVC:SetValue("MIJDETAIL", "MIJ_PRODUT", self:cProduct                 )
            oModelMVC:SetValue("MIJDETAIL", "MIJ_LGCOD" , self:cPos                     )
            oModelMVC:SetValue("MIJDETAIL", "MIJ_SIGLA" , aServicos[nServ][1]           )        
            oModelMVC:SetValue("MIJDETAIL", "MIJ_SERVIC", aServicos[nServ][2]           )
            oModelMVC:SetValue("MIJDETAIL", "MIJ_ATIVO" , aServicos[nServ][3]           )        
            oModelMVC:SetValue("MIJDETAIL", "MIJ_CONFIG", aServicos[nServ][4]:ToJson()  )
        Next nServ

        oModelMVC:GetModel("MIJDETAIL"):SetNoDeleteLine(.T.)
        oModelMVC:GetModel("MIJDETAIL"):SetNoInsertLine(.T.)
        
        FWExecView( self:cProduct/*cTitulo*/, "LJCFGINTEG"/*cPrograma*/ , MODEL_OPERATION_UPDATE/*nOperation*/, /*oDlg*/           , {|| .T.}/*bCloseOnOK*/,;
                    {|| .T.}/*bOk*/     	, /*nPercReducao*/          , aBotoes/*aEnableButtons*/           , {|| .T.}/*bCancel*/, /*cOperatId*/         ,;
                    /*cToolBar*/        	, oModelMVC/*oModelAct*/    )
    EndIf

    oModelMVC:Deactivate()
	oModelMVC:Destroy()
	oModelMVC := Nil

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GetProductComponents
Retorna o objeto json do produto com os componentes

@type    method
@return  JsonObject, Objeto contendo configurações do produto
@author  Rafael Tenorio da Costa
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method GetProductComponents() Class LjIntegrationConfiguration
Return Self:oLjAuthentication:GetProductComponents()

//-------------------------------------------------------------------
/*/{Protheus.doc} GetaServicesComponents
Retorna um array com o objeto json de componentes do serviço

@type    method
@return  Array, Array contendo as configurações dos serviços ou serviço selecionado
@author  Rafael Tenorio da Costa
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method GetaServicesComponents() Class LjIntegrationConfiguration
Return Self:oLjAuthentication:GetaServicesComponents()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetToken
Metodo responsavel retorna o token do serviço informado

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2020
@version    12.1.33

@param cServiceCode, Caracter, Codigo que indica o serviço (Ex: TPD, TFC)
@param lForce, Logico, Indica se controi novamente o objeto de autenticação (em caso de alteração dos dados de comunicação)

@return Character, Token
/*/
//------------------------------------------------------------------------------------
Method GetToken(cServiceCode, lForce) Class LjIntegrationConfiguration 
    Local cToken := ""
    Self:oMessageError:ClearError()
    
    cToken := Self:oLjAuthentication:GetToken(cServiceCode,lForce)
    
    If Empty(cToken)
        Self:oMessageError:SetError(GetClassName(Self),Self:oLjAuthentication:oMessageError:GetMessage())
    EndIf 
Return cToken

// -- Metodo deverá ser utilizado apos a solicitação de um token, com isso a informação do ambiente estará em cache.
Method GetEnvironment(cServiceCode) Class LjIntegrationConfiguration 
return Self:oLjAuthentication:GetEnvironment(,cServiceCode)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetComponent
Retorna o conteúdo de um componente referente a um serviço

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2020
@version    12.1.33

@param cIdComponent, Caracter, Identificador do componente
@param cServiceCode, Caracter, Código que indica o serviço (Ex: TPD, TFC)

@return Indefinido, Conteúdo do componente consultado
/*/
//------------------------------------------------------------------------------------
Method GetComponent(cIdComponent, cServiceCode) Class LjIntegrationConfiguration 
    Local nX         := 0
    Local xContent   := ""
    Local nPos       := 0
    Local cPrtComp   := Self:GetProductComponents()
    Local cServcComp := Self:GetaServicesComponents()

    Default cServiceCode := ""
    
    cIdComponent := Alltrim(Upper(cIdComponent))

    If Empty(cServiceCode)
        For nX := 1 To Len(cPrtComp["Components"])
            If Alltrim(Upper(cPrtComp["Components"][nX]["IdComponent"])) == cIdComponent
                xContent := cPrtComp["Components"][nX]["ComponentContent"]
                cType    := Alltrim(Upper(cPrtComp["Components"][nX]["ContentType"]))
                Exit
            EndIf
        Next
    Else
        nPos := aScan(cServcComp,{|x| Alltrim(Upper(x[1])) == Alltrim(Upper(cServiceCode))})
        For nX := 1 To Len(cServcComp[nPos][4]["Components"])
            If Alltrim(Upper(cServcComp[nPos][4]["Components"][nX]["IdComponent"])) == cIdComponent
                xContent := cServcComp[nPos][4]["Components"][nX]["ComponentContent"]
                cType    := Alltrim(Upper(cServcComp[nPos][4]["Components"][nX]["ContentType"]))
                Exit
            EndIf 
        Next
    EndIf 

    // -- Trata conteudo salvo para tipagem correta.
    Do Case
        Case cType == "LOGICAL"
            If xContent $ "Sim|True|Yes"
                xContent := .T.
            Else
                xContent := .F.
            EndIf 
        Case cType == "STRING"
            xContent := Alltrim(xContent)
        Case cType == "DATA"
            xContent := CToD(xContent)
        Case cType == "INTEGER"
            xContent := Val(xContent)
    EndCase

return xContent