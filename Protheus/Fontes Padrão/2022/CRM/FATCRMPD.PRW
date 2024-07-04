#INCLUDE "PROTHEUS.CH"

#DEFINE FTPDLOADAUTO "FTPDLOADAUTO"
  
Static _aFieldsPDU      := {}
Static _cUserPD         := ""
Static _lPDActive       := Nil
Static _lFTPDUse        := Nil
Static _lFTPDLUse       := Nil
Static _aHashPD         := {}

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FTPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuário utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serão verificados.
    @param aFields, Array, Array com todos os Campos que serão verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FTPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Function FTPDLoad(cUser, aAlias, aFields, cSource)
    
    Local aAcFields     := {}
    Local aAuxFields    := {}    
    Local cAlias        := ""
    Local cField        := ""
    Local cPDUser       := ""
    Local cPDSource     := ""  
    Local nX            := 0
    Local nI            := 0
    Local nPosField     := 0
    Local oHashPD       := Nil
    Local lNewHashPD    := .F.
    Local lAchou        := .F.
    
    Default cUser       := __cUserId
    Default aAlias      := {}
    Default aFields     := {}
    Default cSource     := ProcName(1)
    
    If ( FTPDUse() .And. ( !Empty(aAlias) .Or. !Empty(aFields) ) ) .And. !Empty(cUser)

        /* Tratamento devido chamadas estatica.
           Retirar essa proteção quando limpar as chamadas estaticas nos fontes.
        */
        If AllTrim(Upper(cSource)) == "FATPDLOAD"
            cSource := ProcName(2)
        EndIf
        
        oHashPD := FTPDHashActive(cSource)

        If oHashPD != Nil
            oHashPD:Get("PD_USER",@cPDUser)
            If cPDUser != cUser
                While !Empty(_aHashPD)  
                    FTPDUnload() 
                End 
                oHashPD := Nil  
            EndIf
        EndIf     

        If oHashPD == Nil
            lNewHashPD  := .T.
            cSource     := AllTrim(Upper(cSource))
            oHashPD     := tHashMap():New()
            oHashPD:Set("PD_USER"   ,cUser) 
            oHashPD:Set("PD_SOURCE" ,cSource)  
            aAdd(_aHashPD,{cSource,oHashPD})
        Endif

        If lNewHashPD .Or. ( cSource == FTPDLOADAUTO .And. !oHashPD:Get(aFields[1],@lAchou) )                  
            If !Empty(aAlias)            
                For nX := 1 To Len(aAlias)
                    cAlias := aAlias[nX]
                    aAuxFields  := FwProtectedDataUtil():GetAliasFieldsInList(cAlias,.F.)
                    For nI := 1 To Len(aAuxFields)     
                        cField := Upper(AllTrim(aAuxFields[nI]:cField))            
                        oHashPD:Set(cField, .T.)   
                        aAdd(aFields,cField)
                    Next nI
                Next nX
            Else
                For nX := 1 To Len(aFields)
                    cField  := Upper(AllTrim(aFields[nX])) 
                    aFields[nX] := cField  
                    oHashPD:Set(cField, .T.)                
                Next nX
            EndIf     

            aAcFields   := FwProtectedDataUtil():UsrAccessPDField(cUser, aFields)
        
            For nX := 1 To Len(aFields)
                nPosField   := aScan(aACFields, {|cField| AllTrim(cField) == aFields[nX]})
                If nPosField > 0
                    oHashPD:Set(aFields[nX],.F.)    
                EndIf
            Next nX
        EndIf

        oHashPD:Get("PD_SOURCE",@cPDSource)  

        aSize(aAcFields , 0)
        aSize(aAuxFields, 0)  
        aAcFields   := Nil 
        aAuxFields  := Nil

    EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FTPDUnload
    @description
    Finaliza o gerenciamento dos campos com proteção de dados.

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FTPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Function FTPDUnload(cSource)    
    Local nPosSrc  := 0

    Default cSource := ""

    If FTPDUse()  
        If !Empty(cSource)
            cSource := AllTrim(Upper(cSource))            
            nPosSrc := Ascan(_aHashPD,{|x|x[1] == cSource})
            If nPosSrc > 0
                FTPDOHFree(nPosSrc)
            EndIf
        Else
            FTPDOHFree()
        EndIf
    EndIf

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FTPDOHFree
    @description
    Remove um elemento da pilha.

    @type  Function
    @author Squad CRM & Faturamento
    @since  11/12/2019
    @version P12.1.27
    @param nPosHash, Numerico, Posição do HashMap que sera removida da pilha
    @return return, Nulo
    @example FTPDOHFree(1) 
/*/
//-----------------------------------------------------------------------------------
Static Function FTPDOHFree(nPosHash)  

    Default nPosHash := Len(_aHashPD)  

    If nPosHash > 0
        _aHashPD[nPosHash][2]:Clean()
        FreeObj(_aHashPD[nPosHash][2]) 
        _aHashPD[nPosHash][2] := Nil
        aDel(_aHashPD,nPosHash)
        aSize(_aHashPD,Len(_aHashPD)-1)
    EndIf 

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FTPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FTPDLoad.

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FTPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Function FTPDIsObfuscate(cField, cSource, lLoad)
    Local lObfuscate    := .F.
    Local oHashPD       := Nil
    
    Default cSource     := ""
    Default lLoad       := .F.
    
    If FTPDUse()
        If lLoad .And. Empty(cSource)            
            cSource := FTPDLoad(Nil,Nil,{cField},FTPDLOADAUTO)
        Endif
        oHashPD     := FTPDHashActive(cSource)
        If oHashPD != Nil .And. !Empty(cField)
            oHashPD:Get(cField,@lObfuscate)  
        EndIf
    EndIf 

Return lObfuscate

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FTPDColObfuscate
    @description
    Verifica se a coluna de um grid deve ser ofuscado, tendo como base uma lista de
    campos, esta função deve utilizada somente após a inicialização das variaveis 
    atravez da função FTPDLoad.

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.

    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FTPDIsObfuscate({"A1_COD","A1_NOME","A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Function FTPDColObfuscate(aFields, cSource)  
    Local lObfuscate    := .F.    
    Local aPDColObf     := {}
    Local nX            := 0
    Local oHashPD       := Nil

    Default aFields     := {}
    Default cSource     := ""
    
    If FTPDUse()
        oHashPD := FTPDHashActive(cSource)
        If ( oHashPD != Nil .And. !Empty(aFields) )
            For nX := 1 To Len(aFields)
                lObfuscate   := .F.
                If !Empty(aFields[nX])
                    oHashPD:Get(aFields[nX],@lObfuscate)
                EndIf 
                aAdd(aPDColObf,lObfuscate)
            Next nX
        EndIf
    EndIf 

Return aPDColObf  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FTPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.

    @type  Function
    @sample FTPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Function FTPDObfuscate(xValue, cField, cSource, lLoad)
    Local aTamSx3       := {}
    Local lObfuscate    := .F.
    Local nSize         := 0
    Local nDecimal      := 0
    Local cTypeFld      := ""

    Default xValue      := Nil  
    Default cField      := ""
    Default cSource     := ""
    Default lLoad       := .F.
    
    If FTPDUse()        
        If !Empty(cField)
            If lLoad .And. Empty(cSource)
                cSource := FTPDLoad(Nil,Nil,{cField},FTPDLOADAUTO)
            Endif
            lObfuscate  := FTPDIsObfuscate(cField, cSource)
        Else
            lObfuscate  := .T.
        EndIf
       
        If lObfuscate
            aTamSx3     := FTPDTamFld(xValue, cField)
            nSize       := aTamSx3[1]
            nDecimal    := aTamSx3[2]
            cTypeFld    := aTamSx3[3]
            Do Case
                Case cTypeFld == "C"
                    xValue := "****"
                Case cTypeFld == "N"
                    xValue := Replicate("9",nSize)
                    If nDecimal > 0
                        xValue += "." + Replicate("9", nDecimal)
                    Endif
                Case cTypeFld == "D"
                    xValue := "01/01/1900"
            Endcase
        EndIf
    EndIf

    aSize(aTamSx3, 0)

Return xValue   

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FTPDHashActive
    @description
    Retornar o ultimo Objeto HashMap da pilha.

    @type  Function
    @sample FTPDHashActive()
    @author Squad CRM & Faturamento
    @since 11/12/2019
    @version P12    
    @param cSource, Caractere, Nome do recurso que buscar dados pidos.
    @return oHashPD, Objeto, retorna objeto hashmap ativo.
/*/
//-----------------------------------------------------------------------------

Static Function FTPDHashActive(cSource)

    Local oHashPD   := Nil     
    Local nPosSrc   := 0

    Default cSource := ""

    If !Empty(cSource)
        cSource := AllTrim(Upper(cSource))
        nPosSrc := AScan(_aHashPD, {|x| x[1] == Alltrim(Upper(cSource))})
    Else
        nPosSrc := Len(_aHashPD) 
    EndIf
    
    If nPosSrc > 0 
        oHashPD := _aHashPD[nPosSrc][2]
    EndIf

Return oHashPD     

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FTPDUserAcc
    @description
    Verifica se o usuario logado possui acesso a dados sensiveis e pessoais
    Exibindo mensagem de Help caso usuario não possua acesso.

    @type  Function
    @sample FTPDUserAcc()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Retorna se Usuario possui acesso a dados protegidos
/*/
//-----------------------------------------------------------------------------
Function FTPDUserAcc()

    Local lRet := .T.

    If FTPDUse() .And. !(VerSenha(192) .Or. VerSenha(193))
        lRet := .F.
        Help(,, "Dados Protegidos",,;//FTPDUSERACC
         "Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina.", 1,;
         1,,,,,,{"Contate o Administrador do sistema"})
    Endif

Return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FTPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada

   @type  Function
    @sample FTPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Function FTPDLogUser(cFunction, nOpc)

Local lRet := .F.

Default cFunction   := ""
Default nOpc        := 0

If _lFTPDLUse == Nil
    _lFTPDLUse   := FindFunction("FwPDLogUser")
Endif

If _lFTPDLUse
    lRet := FwPDLogUser(cFunction, nOpc)
EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FTPDUse
    @description
    Função que verifica se a melhoria de Dados Protegidos existe e esta sendo utilizada no sistema.

    @type  Function
    @sample FTPDUse(.T.)
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12
    @param lCanOfusca, Lógico, Verifica se a melhoria de dados protegidos e Ofuscação esta ativa
        Ou apenas a melhoria de dados protegidos    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Function FTPDUse(lCanOfusca)

    Local lRet := .F.
    
    Default lCanOfusca := .T.

    If _lFTPDUse == Nil
        _lFTPDUse := FindFunction("FwPDCanUse")
    Endif

    If _lFTPDUse
        lRet := FwPDCanUse(lCanOfusca)
    Endif

Return lRet

//-----------------------------------------------------------------------------
 /*/{Protheus.doc} FTPDTamFld
    @description
    Retorna Array com informações do campo (Tamanho, casas decimais e tipo)

    @type  Function
    @author Squad CRM & Faturamento
    @since 26/12/2019
    @version P12
    @param xValue, Caractere , Valor
    @param cField, Caractere , Campo
    @return aRet, Array, Array com Tamanho do campo, casa decimal e Tipo.
    @example FTPDTamFld("FTPDTAMFLD", "A1_COD")    
/*/
//-----------------------------------------------------------------------------
Static Function FTPDTamFld(xValue, cField)

    Local aRet  := {}
    Local cType := ""

    Default xValue := Nil
    Default cField := ""

    If !Empty(cField)
        aRet := TamSx3(cField)
    Endif 

    If Len(aRet) == 0
        aRet  := Array(3)
        cType := ValType(xValue)
        If cType == "N"
            aRet[1] := Len(StrTran(CValToChar(xValue),"."))
        Elseif cType == "D"
            aRet[1] := 8
        Else
            aRet[1] := Len(xValue)
        Endif
        aRet[2] := 0
        aRet[3] := cType
    Endif

Return aRet