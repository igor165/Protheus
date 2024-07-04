#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "LJSERVICESSETTINGS.CH"

Function LjServicesSettings ; Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjServicesSettings
Classe respons�vel por gerir todo os dados relacionados ao servi�o e suas configura��es.

@type       Class
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@return
/*/
//-------------------------------------------------------------------------------------
Class LjServicesSettings

    Data nId              as Numeric    //Recno
    Data cProduct         as Character  //Produto
	Data cPos             as Character  //C�digo da Esta��o
    Data cServiceCode     as Character  //Sigla que identifica o servi�o
    Data cService         as Character  //Descri��o do servi�o
	Data lEnable          as Logical    //Defini se o servi�o esta ativo
    Data jServiceSettings as Object     //Objeto json com as configura��es do servi�o

    Data oMessageError    as Object
    Data oJsonIntegrity   as Object
	
	Method New(nId, cProduct)

    Method GetService(lSeek)
    Method SetService()

    // -- Carga inicial 
    Method Services(cProduct, cPos)
    Method InitialTPD()
    Method InitialTFC()
    Method InitialCharge(cServiceSettings, cPos, cProduct, cServiceCode, cService, lEnable)
    Method InitialServiceSettings() 

EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@param nId, Numerico, Recno
@param cProduct, Caracter, Produto atual

@return LjServicesSettings, Objeto, Objeto construido.
/*/
//-------------------------------------------------------------------------------------
Method New(nId, cProduct) Class LjServicesSettings
    Default nId := 0
    
    Self:nId              := nId
    Self:cProduct         := cProduct
    Self:jServiceSettings := JsonObject():New()
    Self:oMessageError    := LjMessageError():New()
    Self:oJsonIntegrity   := LjJsonIntegrity():New()

Return Self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetService
Metodo responsavel por buscar e carregar as informa��os sobre o servi�o alvo

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@param lSeek, Logico, Indica se a busca dever� ser feita por Seek ou por recno

@return Logico, indica se o metodo foi executado com sucesso
/*/
//-------------------------------------------------------------------------------------
Method GetService(lSeek) Class LjServicesSettings
    
    Local cErro := ""

    Default lSeek := .F.

    If lSeek
        MIJ->( DbSetOrder(1) )  //MIJ_FILIAL+MIJ_PRODUT+MIJ_LGCOD+MIJ_SIGLA
        MIJ->( DbSeek( xFilial("MIJ") + self:cProduct + Self:cPos + Self:cServiceCode))
    Else
        MIJ->( DbGoTo(Self:nId) )
    EndIf 

    If MIJ->( Eof() )
        Self:oMessageError:SetError( GetClassName(Self), I18n(STR0001, {"MIJ", cValToChar(Self:nId)}) )     //"N�o foi encontrado o servi�o na tabela (#1), a partir do recno: #2"
    Else

        cErro := Self:jServiceSettings:FromJson(MIJ->MIJ_CONFIG)

        If ValType(cErro) == "C"

            Self:oMessageError:SetError( GetClassName(Self), I18n(STR0002, {"MIJ_CONFIG", cErro}) )     //"Erro ao carregar configura��o (#1): #2"
        Else
    
            Self:cProduct     := MIJ->MIJ_PRODUT
	        Self:cPos         := MIJ->MIJ_LGCOD
            Self:cServiceCode := MIJ->MIJ_SIGLA
            Self:cService     := MIJ->MIJ_SERVIC
	        Self:lEnable      := MIJ->MIJ_ATIVO
            Self:nId          := MIJ->(Recno())
        EndIf

    EndIf

Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetService
Metodo responsavel por persistir os dados do objeto no banco de dados

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@return Logico, indica se o metodo foi executado com sucesso
/*/
//-------------------------------------------------------------------------------------
Method SetService() Class LjServicesSettings
    DbSelectArea("MIJ")
    MIJ->( DbGoTo(Self:nId) ) 
    lInclude := MIJ->( Eof() )
        
    If RecLock("MIJ",lInclude)
        REPLACE MIJ->MIJ_FILIAL WITH xFilial("MIJ")
        REPLACE MIJ->MIJ_CONFIG WITH Self:jServiceSettings:toJSON()
        REPLACE MIJ->MIJ_PRODUT WITH Self:cProduct
        REPLACE MIJ->MIJ_LGCOD  WITH Self:cPos
        REPLACE MIJ->MIJ_SIGLA  WITH Self:cServiceCode
        REPLACE MIJ->MIJ_SERVIC WITH Self:cService
        REPLACE MIJ->MIJ_ATIVO  WITH Self:lEnable
        MsUnLock()  
        Self:nId := MIJ->(Recno())   
    Else
        Self:oMessageError:SetError(GetClassName(Self), STR0003)    //"N�o foi possivel efetuar a grava��o do servi�o"
    EndIf 
     
Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Services
Metodo responsavel por devolver os servi�os ativos (gravados no banco) ou devolver uma lista de servi�os padr�es

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@param cProduct, Caracter, se preenchido indica que dever� buscar no banco de dados uma lista de servi�os, se n�o a busca ser� no array de servi�os padr�es
@param cPos, Caracter, se preenchido indica que dever� buscar no banco de dados uma lista de servi�os, se n�o a busca ser� no array de servi�os padr�es

@return Array, Configura��es dos servi�os. Ex: {MIJ->MIJ_SIGLA, MIJ->MIJ_SERVIC, MIJ->MIJ_ATIVO, MIJ->(Recno()) }
/*/
//-------------------------------------------------------------------------------------
Method Services(cProduct, cPos) Class LjServicesSettings
    Local aServices  := {}
    Local cKey      := ""
   
    Default cProduct := ""
    Default cPos     := ""

    // -- Caso n�o tenha recebido os parametros de busca informo o conteudo padr�o para carga inicial
    If Empty(cProduct) .AND. Empty(cPos)
        //aadd(aServices,{"TPD","TOTVS Pagamento Digital",.F.,0})
        aadd(aServices,{"TFC","TOTVS Fidelity Core",.F.,0})
    Else

        cKey := xFilial("MIJ") + cProduct + cPos 

        DbSelectArea("MIJ")
        MIJ->( DbSetOrder(1) ) //MIJ_FILIAL+MIJ_PRODUT+MIJ_LGCOD+MIJ_SIGLA
        If MIJ->( DbSeek(cKey)) 
            While MIJ->(!Eof()) .AND. MIJ->MIJ_FILIAL == xFilial("MIJ") .AND. MIJ->MIJ_PRODUT == cProduct .AND. MIJ->MIJ_LGCOD == cPos
                aadd(aServices,{MIJ->MIJ_SIGLA,MIJ->MIJ_SERVIC,MIJ->MIJ_ATIVO,MIJ->(Recno())})
                MIJ->(dbSkip())
            End
        Else
            Self:oMessageError:SetError( GetClassName(Self), I18n(STR0004, {"MIJ", IndexKey( IndexOrd() ), cKey} ) )     //"N�o foi encontrado o servi�o na tabela #1, a partir do �ndice (#2) e Chave (#3)"
        EndIf 

    EndIf 
Return aServices

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} InitialTPD
Metodo responsavel por devolver o arquivo de configura��es para o servi�o TPD
@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@return Character, Devolve Json em caracter com configura��es iniciais do produto TPD
/*/
//-------------------------------------------------------------------------------------
Method InitialTPD() Class LjServicesSettings
    Local cJson := ""

    BeginContent var cJson
    {   
        "LayoutVersion":0.4,
        "Components":[
            {
                "IdComponent":"ClientId",
                "Component":{
                    "ComponentType":"Text",
                    "ComponentLabel":"Client. Id",
                    "Parameters":{

                    }
                },
                "ComponentContent":"",
                "ContentType":"String"
            },
            {
                "IdComponent":"ClientSecret",
                "Component":{
                    "ComponentType":"Text",
                    "ComponentLabel":"Client. Secret",
                    "Parameters":{

                    }
                },
                "ComponentContent":"",
                "ContentType":"String"
            },
            {
                "IdComponent":"EnableDigitalPayment",
                "Component":{
                    "ComponentType":"CheckBox",
                    "ComponentLabel":"Habilita Pagamento Digital?",
                    "Parameters":{
                    
                    }
                },
                "ComponentContent":"",
                "ContentType":"Logical"
            }
        ]
    }      
    EndContent
Return cJson

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} InitialTFC
Metodo responsavel por devolver o arquivo de configura��es para o servi�o TFC
@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@return Character, Devolve Json em caracter com configura��es iniciais do produto TFC
/*/
//-------------------------------------------------------------------------------------
Method InitialTFC() Class LjServicesSettings
    Local cJson := ""

    BeginContent var cJson
    {   
        "LayoutVersion":0.7,
        "Components":[
            {
                "IdComponent":"Environment",
                "Component":{
                    "ComponentType":"ListBox",
                    "ComponentLabel":"Ambiente",
                    "Parameters":{
                        "List":[
                        	"Produ��o",
                        	"Homologa��o",
                            "Desenvolvimento"
                        ]
                    }
                },
                "ComponentContent":"Produ��o",
                "ContentType":"String"
            },
            {
                "IdComponent":"SendAllSales",
                "Component":{
                    "ComponentType":"ListBox",
                    "ComponentLabel":"Envia todas as Vendas?",
                    "Parameters":{
                        "List":[
                        	"Sim",
                        	"N�o"
                        ]
                    }
                },
                "ComponentContent":"",
                "ContentType":"Logical"
            }
        ]
    }
    EndContent
Return cJson

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} InitialServiceSettings
Metodo responsavel por direcionar a carga dos servi�os e devolver o Json de configura��es 
@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@return Character, Devolve Json em caracter com configura��es iniciais do produto TFC
/*/
//-------------------------------------------------------------------------------------
Method InitialServiceSettings() Class LjServicesSettings
    Local cJson := ""
    
    DO CASE 
        CASE Self:cServiceCode == "TPD" // TOTVS Pagamento Digital
            cJson :=  Self:InitialTPD() 
        CASE Self:cServiceCode == "TFC" // TOTVS Fidelity Core
            cJson :=  Self:InitialTFC() 
    ENDCASE

Return cJson

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} InitialCharge
Metodo responsavel por realizar a carga inicial dos servi�os usando JSon padr�o ou recebendo por parametro

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@param cServiceSettings, Caracter, String contendo Json de configura��o
@param cPos, Caracter,  Codigo da esta��o
@param cProduct, Caracter,  Codigo de produto (Ex, RAAS, ETC..)
@param cServiceCode, Caracter, Codigo que identiica o servi�o (Ex: "TPD","TFC")
@param cService, Caracter, Descri��o do servi�o (Ex: TOTVS Pagamento Digital, TOTVS Fidelity Core)
@param lEnable, Logico, Indica se o servi�o esta ativo    

@return Logico, indica se o metodo foi executado com sucesso
/*/
//-------------------------------------------------------------------------------------
Method InitialCharge(cServiceSettings, cPos, cProduct, cServiceCode, cService, lEnable) Class LjServicesSettings
    Local cErro            := ""
    Local jServiceSettings := JsonObject():New()

    Self:nId            := 0
    Self:cPos           := cPos
    Self:cProduct       := cProduct  
    Self:cServiceCode   := cServiceCode
    Self:cService       := cService
    Self:lEnable        := lEnable

    If cServiceSettings == Nil
        cServiceSettings := Self:InitialServiceSettings()
    EndIf

    cErro := jServiceSettings:FromJson(cServiceSettings)
       
    If ValType(cErro) == "C"
        Self:oMessageError:SetError( GetClassName(Self), I18n(STR0005, {"cServiceSettings", cErro} ) )      //"Erro ao carregar configura��o (#1): #2"
    Else
        If Self:GetService(.T.)
            If !Self:oJsonIntegrity:check(jServiceSettings,Self:jServiceSettings)
                Self:jServiceSettings := Self:oJsonIntegrity:jJson
                Self:SetService()
            EndIf 
        Else
            Self:oMessageError:ClearError()
            Self:jServiceSettings := jServiceSettings
            Self:SetService()
        EndIf 
    EndIf 

Return Self:oMessageError:GetStatus()
