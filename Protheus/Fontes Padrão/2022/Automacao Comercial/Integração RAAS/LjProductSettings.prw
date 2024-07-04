#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "LJPRODUCTSETTINGS.CH"

Function LjProductSettings ; Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjProductSettings
Classe responsável por gerir todo os dados relacionados ao produto e suas configurações.

@type       Class
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@return
/*/
//-------------------------------------------------------------------------------------
Class LjProductSettings

    Data nId              as Numeric
    Data cProduct         as Character
    Data jProductSettings as Object
    Data oMessageError    as Object
    Data oJsonIntegrity   as Object

    Method New(cProduct)
    Method GetProduct()
    Method SetProduct()
    Method InitialCharge(cProductSettings)
    Method InitialProductSettings() 

EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@param cProduct, Caracter, Produto atual

@return LjProductSettings, Objeto, Objeto construido.
/*/
//-------------------------------------------------------------------------------------
Method New(cProduct) Class LjProductSettings
    Local nTamProd      := TamSX3("MIJ_PRODUT")[1]
    
    Self:nId              := 0
    Self:cProduct         := PadR(cProduct, nTamProd)
    Self:jProductSettings := JsonObject():New()
    Self:oMessageError    := LjMessageError():New()
    Self:oJsonIntegrity   := LjJsonIntegrity():New()

Return self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetProduct
Metodo responsavel por buscar e carregar as informaçãos sobre o produto alvo

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@return Logico, indica se o metodo foi executado com sucesso
/*/
//-------------------------------------------------------------------------------------
Method GetProduct() Class LjProductSettings
    Local cErro := ""
    DbSelectArea("MII")
    MII->( DbSetOrder(1) )  //MII_FILIAL + MII_PRODUT
    
    If MII->( DbSeek( xFilial("MII") + self:cProduct) ) 
        cErro := Self:jProductSettings:FromJson(MII->MII_CONFIG)
       
        If ValType(cErro) == "C"
            Self:oMessageError:SetError(GetClassName(Self), STR0001 + cErro )   //"Erro ao carregar configuração (MII_CONFIG): "
        Else
            Self:nId := MII->(Recno())
        EndIf 
    Else
        Self:oMessageError:SetError( GetClassName(Self), I18n(STR0002, { AllTrim(Self:cProduct), "MII" } ) )    //"Produto #1 não foi encontrado na tabela #2"
    EndIf 

Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetProduct
Metodo responsavel por persistir os dados do objeto no banco de dados

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@return Logico, indica se o metodo foi executado com sucesso
/*/
//-------------------------------------------------------------------------------------
Method SetProduct() Class LjProductSettings
    Local lInclude := Nil
    
    DbSelectArea("MII")
    MII->( DbGoTo(Self:nId) )
    lInclude := MII->( Eof() )
    If RecLock("MII",lInclude)
        REPLACE MII->MII_FILIAL WITH xFilial("MII")
        REPLACE MII->MII_PRODUT WITH Self:cProduct
        REPLACE MII->MII_CONFIG WITH Self:jProductSettings:toJSON()
        MsUnLock()
        Self:nId := MII->(Recno())    
    Else
        Self:oMessageError:SetError(GetClassName(Self), STR0003)    //"Não foi possivel atualizar o registro."
    EndIf 

Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} InitialCharge
Metodo responsavel por realizar a carga inicial do produto ou atualizar o arquivo de configurações atual.

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@param cProductSettings, Caracter, String contendo Json de configuração   

@return Logico, indica se o metodo foi executado com sucesso
/*/
//-------------------------------------------------------------------------------------
Method InitialCharge(cProductSettings) Class LjProductSettings
    Local jProductSettings := JsonObject():New()
    Default cProductSettings := Self:InitialProductSettings()
    
    cErro := jProductSettings:FromJson(cProductSettings)
       
    If ValType(cErro) == "C"
        Self:oMessageError:SetError(GetClassName(Self), I18n(STR0004, {"cProductSettings", cErro}) )    //"Erro ao carregar configuração (#1): #2"
    Else
        If Self:GetProduct()
            If !Self:oJsonIntegrity:check(jProductSettings,Self:jProductSettings)
                Self:jProductSettings := Self:oJsonIntegrity:jJson
                Self:SetProduct()
            EndIf 
        Else
            Self:oMessageError:ClearError()
            Self:jProductSettings := jProductSettings
            Self:SetProduct()
        EndIf 
    EndIf 

Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} InitialProductSettings
Metodo responsavel por devolver o arquivo de configurações para o produto RAAS
@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33


@return Character, Devolve Json em caracter com configurações iniciais do produto TFC
/*/
//-------------------------------------------------------------------------------------
Method InitialProductSettings() Class LjProductSettings
    Local cJson := ""

    BeginContent var cJson
    {
        "Protocol":"OAuth2.0",
        "AuthenticationService":"RAC",
        "LayoutVersion":0.3,
        "Components":[
            {
                "IdComponent":"Tenent",
                "Component":{
                    "ComponentType":"Text",
                    "ComponentLabel":"Tenant",
                    "Parameters":{
                    
                    }
                },
                "ComponentContent":"",
                "ContentType":"String"
            },
            {
                "IdComponent":"User",
                "Component":{
                    "ComponentType":"Text",
                    "ComponentLabel":"Usuario",
                    "Parameters":{
                    
                    }
                },
                "ComponentContent":"",
                "ContentType":"String"
            },
            {
                "IdComponent":"Password",
                "Component":{
                    "ComponentType":"Text",
                    "ComponentLabel":"Senha",
                    "Parameters":{
                        "Picture":"@*"
                    }
                },
                "ComponentContent":"",
                "ContentType":"String"
            }
        ]
    }
    EndContent
Return cJson
