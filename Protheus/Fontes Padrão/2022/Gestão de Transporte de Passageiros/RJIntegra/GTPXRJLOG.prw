#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static aRJLogFun    := {}

/*/{Protheus.doc} GTPRJLog
    Classe para a geração de logs de erros que possam vir a acontecer na integração
    entre as plataformas TotalBus (empresa RJ) e o SIGAGTP 
    @type  Classe
    @author user
    @since 05/08/2021
    @version version
/*/
CLASS GTPRJLog //From FWSerialize
		
    Data cClassName     as Character
    Data cFunName       as Character
    Data cModelType     as Character
    Data cCurrentURL    as Character
    Data cParams        as Character
    
    Data lHasModel      as Logical
    Data lSingle        as Logical
    Data lIsActive      as Logical

    Data oMdlSingle     as Object
    Data oMdlFull       as Object

    Data aDesc          as Array    
    Data aParams        as Array    

	METHOD New(cFunName,lSingle) CONSTRUCTOR
	METHOD Destroy()
    
    METHOD InitModel()
    METHOD FinishModel()
	
    METHOD ClassName()
    
    METHOD GetModel()
    METHOD GetSubModel()
    METHOD GetValue(cField,nLine)
    METHOD GetDescription()
    METHOD GetService()
    METHOD GetParams(lInArray)
    
    METHOD IsActive()
    METHOD Activate()
    METHOD ExistLog()

    METHOD SetOperation(nOperation)
	METHOD SetValue(cField,xValue,nLine)
    METHOD SetFunName(cFunName)
    METHOD SetURL(cUrl)

    METHOD AddLine()
    METHOD CommitData(lValid)
    METHOD FillData(aData)

ENDCLASS

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD New(cFunName,lSingle,cUrl) Class GTPRJLog
        
    Default cFunName    := FunName()
    Default lSingle     := .T.
    Default cUrl        := ""

    InitAtrib(Self,lSingle,cFunName,cUrl)

    Self:InitModel()

Return Self

/*/{Protheus.doc} Destroy
    Método responsável por destruir um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @return nil
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD Destroy() Class GTPRJLog

    If ( Self:lHasModel )
        
        Self:FinishModel()
        
        If ( ValType(Self:oMdlSingle) == "O" .And. Self:oMdlSingle:IsActive() )
            Self:oMdlSingle:DeActivate()
        EndIf
        
        If ( ValType(Self:oMdlFull) == "O" .And. Self:oMdlFull:IsActive() )
            Self:oMdlFull:DeActivate()
        EndIf

        GtpDestroy(Self:oMdlSingle)
        GtpDestroy(Self:oMdlFull)
        GtpDestroy(Self:aDesc)

    EndIf

Return()

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD InitModel() Class GTPRJLog

    Self:lHasModel  := .F.

    If ( Self:lSingle )
    
        Self:oMdlSingle := FwLoadModel("GTPRJMODA")
        Self:cModelType := "Simples"        

    Else
    
        Self:oMdlFull  := FwLoadModel("GTPRJMODB")
        Self:cModelType := "Relacional"
    
    EndIf

    If (Valtype(Self:oMdlSingle) == "O" .Or. Valtype(Self:oMdlFull) == "O")
        Self:lHasModel := .T.
    EndIf

Return()

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD FinishModel() Class GTPRJLog

    Local oModel

    If ( Self:lIsActive )
        
        oModel := Self:GetModel()
        
        oModel:DeActivate()
        Self:lIsActive := .F.

    EndIf

Return()

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD ClassName() Class GTPRJLog

Return(Self:cClassName)

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD GetModel() Class GTPRJLog

    Local oModel
    
    If ( Self:lSingle )
        oModel := Self:oMdlSingle
    Else
        oModel := Self:oMdlFull
    EndIf

Return(oModel)

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD GetSubModel() Class GTPRJLog

    Local oModel
    Local oSubModel

    oModel := Self:GetModel()
    
    If ( Self:lSingle )
        oSubModel := oModel:GetModel("GYSMASTER")
    Else
        oSubModel := oModel:GetModel("GYSDETAIL")
    EndIf

Return(oSubModel)

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD GetValue(cField,nLine) Class GTPRJLog
    
    Local nIntLine  := 0

    Local oSubModel
    
    Local xValue
    
    Default nLine   := 0
    
    If ( Self:lIsActive )
        
        oSubModel    := Self:GetSubModel()
        
        If (oSubModel:GetId() == "GYSDETAIL")

            If ( nLine == 0 )
                nIntLine := oSubModel:GetLine()
            Else
                nIntLine := nLine
            EndIf

            xValue := oSubModel:GetValue(cField,nIntLine)
        
        Else
            xValue := oSubModel:GetValue(cField)
        EndIf
    
    EndIf

Return(xValue)

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD GetDescription() Class GTPRJLog 
        
Return(GTPRJLogData(Self:cFunName,"DESCRICAO"))

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD GetService() Class GTPRJLog 
    
Return(GTPRJLogData(Self:cFunName,"SERVICO"))

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD GetParams(lInArray) Class GTPRJLog
    
    Local xRet
        
    Default lInArray := .F.

    If ( lInArray )
        xRet := Self:aParams
    Else
        xRet := Self:cParams
    EndIf

    If ( Empty(xRet) .And. !Empty(Self:cCurrentURL) .And. At("?",Self:cCurrentURL) > 0 )
        
        xRet := RJGetPars(Self:cCurrentURL,lInArray)

        If ( lInArray )
            
            If ( Empty(Self:cParams) )
                Self:cParams := RJGetPars(Self:cCurrentURL)
            EndIf

        Else

            xRet := RJGetPars(Self:cCurrentURL)  
        
            Self:cParams := xRet
        
            If ( Empty(Self:aParams) )
                Self:aParams := RJGetPars(Self:cCurrentURL,.t.)
            EndIf    

        EndIf

    EndIf

Return(xRet)

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD IsActive() Class GTPRJLog

    Local oModel := Self:GetModel()
    
    If ( Self:lIsActive .And. (Valtype(oModel) == "O" .And. !oModel:IsActive()) )
        Self:lIsActive := .F.
    ElseIf ( Valtype(oModel) == "O"  .And. !Self:lIsActive )
        Self:lIsActive := oModel:IsActive()
    EndIf

Return(Self:lIsActive)

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD Activate() Class GTPRJLog

    Local oModel := Self:GetModel()
    
    If ( Self:lHasModel .And. !Self:lIsActive )        
        Self:lIsActive := oModel:Activate()
    EndIf

Return()

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD ExistLog() Class GTPRJLog

    Local lRet  := .F. 
    
    Local oSubModel

    If ( Self:lIsActive )
        oSubModel := Self:GetSubModel()
        lRet := oSubModel:IsModified()
    EndIf

Return(lRet)

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD SetOperation(nOperation) Class GTPRJLog

DEFAULT nOperation := 3
    
    If ( !Self:IsActive() )

        oModel := Self:GetModel()
        If ValType(oModel) != "O"
            oModel := MPFormModel():New("GTPRJMODA")
        EndIf
        oModel:SetOperation(nOperation)
        
    EndIf

Return()

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD SetValue(cField,xValue,nLine) Class GTPRJLog
    
    Local lRet      := .T.

    Local oSubModel 
    Local oModelHead
    
    Default nLine   := 0
    
    If ( Self:lIsActive )
        
        oSubModel    := Self:GetSubModel()
    
        If ( oSubModel:GetId() == "GYSDETAIL" )

            If ( nLine > 0 )
                oSubModel:GoLine(nLine)
            EndIf

        EndIf

        lRet := oSubModel:LoadValue(cField,xValue)
        
        If ( !Self:lSingle )

            oModelHead := oSubModel:GetModel():GetModel("GYSMASTER")

            If ( oModelHead:HasField(cField) .And.;
                oModelHead:GetValue(cField) <> oSubModel:GetValue(cField) ) 
                
                lRet := oModelHead:LoadValue(cField,oSubModel:GetValue(cField))
            
            EndIf
        
        EndIf

    EndIf

Return(lRet)

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD SetFunName(cFunName) Class GTPRJLog

    Self:cFunName := cFunName

Return()

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD SetURL(cUrl) Class GTPRJLog

    Self:cCurrentURL    := cUrl
    Self:aParams        := {}
    Self:cParams        := ""

Return()

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD AddLine() Class GTPRJLog

    Local lAdd := .F.

    Local oSubModel

    If ( !Self:lSingle .And. Self:lIsActive ) 
        
        oSubModel := Self:GetSubModel()

        lAdd := !Empty(Self:GetValue("GYS_CODIGO")) .And.; 
                !Empty(Self:GetValue("GYS_DESCRI")) .And.;
                !Empty(Self:GetValue("GYS_USUARI")) .And.;
                !Empty(Self:GetValue("GYS_DATA")) .And.;
                !Empty(Self:GetValue("GYS_SERVIC"))

        If ( lAdd )
            lAdd := oSubModel:Length() < oSubModel:AddLine()
        EndIf

    EndIf

Return(lAdd)

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD CommitData(lValid) Class GTPRJLog
    
    Local lOK := .F.

    Local oModel
    
    Default lValid := .T.

    If ( Self:lIsActive )

        oModel := Self:GetModel()
        
        If ( lValid )
            lOk := oModel:VldData()
        Else
            lOk := .T.
        EndIf    
        If ( lOk )
            lOk := oModel:CommitData()
        EndIf
    EndIf

Return()

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
METHOD FillData(aData,lInModel) Class GTPRJLog

    Local aUntouch  := {}
    Local aComplem  := {}
    Local aAux      := {}

    Local nI        := 0
    Local nP        := 0

    Local lRet      := .T.

    Local xValue

    Default aData       := {}
    Default lInModel    := .F.

    AAdd(aUntouch,{"GYS_FILIAL",xFilial("GYS_FILIAL")})
    AAdd(aUntouch,{"GYS_CODIGO",GtpXeNum("GYS","GYS_CODIGO",1,.t.)}) //    AAdd(aUntouch,{"GYS_CODIGO",GetSXENum("GYS","GYS_CODIGO")})
    AAdd(aUntouch,{"GYS_DATA",Date()})
    AAdd(aUntouch,{"GYS_HORA",Time()})
    AAdd(aUntouch,{"GYS_URL",Self:cCurrentURL})
    AAdd(aUntouch,{"GYS_ROTINA",Self:cFunName})
    AAdd(aUntouch,{"GYS_PARAMS",Self:GetParams()})
    
    AAdd(aComplem,{"GYS_USUARI",cUserName})
    AAdd(aComplem,{"GYS_DESCRI",Self:GetDescription()})
    AAdd(aComplem,{"GYS_SERVIC",Self:GetService()})
    AAdd(aComplem,{"GYS_REPORT",""})
    AAdd(aComplem,{"GYS_JSON",""})

    aAux := aClone(aUntouch)    

    For nI := 1 to Len(aComplem)
        
        If ( (nP := aScan(aData,{|x| x[1] == aComplem[nI,1]})) == 0 )
            aAdd(aAux,{aComplem[nI,1],aComplem[nI,2]})
        Else
            aAdd(aAux,{aData[nP,1],aData[nP,2]})
        EndIf

    Next nI

    aData := aClone(aAux)

    If ( lInModel )
        
        For nI := 1 to Len(aData)
            
            If (aData[nI,1] == "GYS_HORA")
                
                xValue := StrTran(aData[nI,2],":","")

                If ( Len(xValue) == 5 )
                    xValue := xValue + "0"
                ElseIf ( Len(xValue) == 4 )
                    xValue := xValue + "00"
                EndIf                        
            
            Else
                xValue :=  aData[nI,2]
            EndIf

            If ( !Self:SetValue(aData[nI,1],xValue) )
                lRet := .f.
                Exit
            EndIf    

        Next nI

    EndIf

Return(lRet)

//----- Funções -------
/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function InitAtrib(oObject,lSingle,cCalledFunction,cUrl)
    
    oObject:cFunName   := cCalledFunction
    oObject:cClassName := "GTPRJLOG"
    oObject:cModelType := "Not_Initialized"
    oObject:cCurrentURL:= cUrl
    oObject:cParams    := ""
    
    oObject:lIsActive  := .F.
    oObject:lHasModel  := .F.
    oObject:lSingle    := lSingle

    oObject:aDesc       := GtpRJFunc()
    oObject:aParams     := {}

    
Return()

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
Function GtpRJFunc()

    If ( Len(aRJLogFun) == 0 )

        AAdd(aRJLogFun,{"GTPIRJ000",    "Orgão"                       ,"/orgao/todos"})
        AAdd(aRJLogFun,{"GTPIRJ035",    "Tipos de localidade"         ,"/tipoLocalidade/todas"})
        AAdd(aRJLogFun,{"GTPIRJ001A", 	"Estado"                      ,"/estado/todos "})
        AAdd(aRJLogFun,{"GTPIRJ001B", 	"Cidade"                      ,"/cidade/todas"})
        AAdd(aRJLogFun,{"GTPIRJ001 ", 	"Localidade"                  ,"/localidade/todas"})
        AAdd(aRJLogFun,{"GTPIRJ011 ", 	"Categoria linha"             ,"/classe/todas"})
        AAdd(aRJLogFun,{"GTPIRJ002 ", 	"Linhas"                      ,"/linha/todas"})
        AAdd(aRJLogFun,{"GTPIRJ003 ", 	"Trechos da linha"            ,"/preco"})
        AAdd(aRJLogFun,{"GTPIRJ004 ", 	"Horarios/Serviços"           ,"/servico"})
        AAdd(aRJLogFun,{"GTPIRJ005 ", 	"Vias"                        ,"/tipoVia/todas"})
        AAdd(aRJLogFun,{"GTPIRJ008 ", 	"Colaboradores"               ,"/usuarios/todas"})
        AAdd(aRJLogFun,{"GTPIRJ711 ", 	"Tipo de agência"             ,"/tipoAgencia/todas"})
        AAdd(aRJLogFun,{"GTPIRJ006 ", 	"Agência"                     ,"/agencia"})
        AAdd(aRJLogFun,{"GTPIRJ118 ", 	"Categoria bilhetes"          ,"/categoriapassagem/todas"})
        AAdd(aRJLogFun,{"GTPIRJ120 ", 	"Trechos (pedágio)"           ,"/trecho/todos"})
        AAdd(aRJLogFun,{"GTPIRJ420 ", 	"Tipos de documentos"         ,"/TipoReceitaDespesa/todas"})
        AAdd(aRJLogFun,{"GTPIRJ050 ", 	"Tipos de venda"              ,"/tipoVenda/todas"})
        AAdd(aRJLogFun,{"GTPIRJ051 ", 	"Motivos de cancelamento"     ,"/tipoCancelamento/todos"})
        AAdd(aRJLogFun,{"GTPIRJ115 ", 	"Bilhetes"                    ,"/bilhete/venda2"})
        AAdd(aRJLogFun,{"GTPIRJ121 ", 	"Impressoras (ECF)"           ,"/impressora/todas"})
        AAdd(aRJLogFun,{"GTPIRJ427 ", 	"Receitas e despesas"         ,"/receitaDespesa"})

    EndIf
    
Return(aClone(aRJLogFun))

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPRJLogData(cFunction,cDataGet)

    Local cRetData := "" 
    
    Local nP        := 0
    Local nRet      := 0      
    
    If ( Valtype(aRJLogFun) <> "A" .Or. Len(aRJLogFun) == 0 )
        GtpRJFunc()
    EndIf
        
    If ( Upper(cDataGet) $ "DESCRICAO" )
        nRet := 2
    ElseIf ( Upper(cDataGet) $ "SERVICO" )
        nRet := 3
    EndIf

    nP := aScan(aRJLogFun,{|z| Alltrim(Upper(z[1])) == Alltrim(Upper(cFunction)) })

    If ( nP > 0 )
        cRetData := aRJLogFun[nP,nRet]
    EndIf
    

Return(cRetData)

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
Function RJLogData(oGtpLog,cService,cError,cJSon)

    Local aLogRJ    := {}
    
    Default cJson   := ""
    
    If ( ValType(oGtpLog) == "O"  .And. Valtype(cError) == "C" .and. !Empty(cError) )

        AAdd(aLogRJ,{"GYS_SERVIC",  Alltrim(cService)})
        AAdd(aLogRJ,{"GYS_REPORT",  cError})
        AAdd(aLogRJ,{"GYS_JSON",    cJSon})
        
        If ( Upper(oGtpLog:ClassName()) == "GTPLOG" )
            
            oGTPLog:Attach(aLogRJ)
            
        
        ElseIf ( Upper(oGtpLog:ClassName()) == "GTPRJLOG" )

            If ( !oGtpLog:IsActive() )
                oGtpLog:SetOperation(MODEL_OPERATION_INSERT)
                oGtpLog:Activate()
            EndIf	

            oGtpLog:AddLine()
            oGtpLog:FillData(aData,.T.)
        
        EndIf
    
    EndIf

Return()

/*/{Protheus.doc} New
    Método responsável por instanciar um objeto da classe GTPRJLog
    @type  Método de Classe
    @author user
    @since 05/08/2021
    @version version
    @param  cFunName, caractere, Identificador da rotina
            lSingle, lógico, .t. objeto instanciado utilizará o modelo de dados 
            de GYS somente com Fields. .F. o objeto instanciado utilizará o modelo
            de dados com Fields e Grid.
            cUrl, caractere, Endereço url do Serviço que gera o log de erro
    @return Self, objeto, objeto instanciado
    @example
    (examples)
    @see (links_or_references)
/*/
Function RJGetPars(cUrl,lInArray)

    Local xRet 
    
    Local aAux1  := {}
    Local aAux2  := {}

    Local nI    := 0

    Default lInArray := .F.

    If ( !Empty(cURL) .And. At("?",cURL) > 0 )
        
        xRet := Alltrim(SubStr(cURL,At("?",cURL)+1))

        If ( lInArray )
            
            aAux1 := Separa(xRet,"&")
            
            If ( Len(aAux1) > 0 )
            
                xRet := {}

                For nI := 1 to Len(aAux1)
                    aAux2 := Separa(aAux1[nI],"=")
                    aAdd(xRet,{aAux1[nI],aClone(aAux2)})
                Next nI
            
            EndIf
            
        Else

            xRet := StrTran(xRet,"&","|")            
        
        EndIf

    EndIf

Return(xRet)


//--------------------------- DUMMY------------------------------
/*/{Protheus.doc} d_gtpirj000
	(long_description)
	@type  Function
	@author user
	@since 20/07/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Main Function Main_NewLog()
	
	Local cEmp      := "T1"
	Local cFil      := "D MG 01 "
	Local cFuncao   := "GTPIRJ008()"
	
    RpcSetType(3)
	RpcClearEnv()
	
    RpcSetEnv(cEmp,cFil,,,'GTP',,)

    cUserName := "administrador"
    __cUserId := "000000"
	
    &(cFuncao)

Return()
