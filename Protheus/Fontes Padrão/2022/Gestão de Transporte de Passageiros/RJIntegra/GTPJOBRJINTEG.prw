#Include 'Protheus.ch'
#include "fwmvcdef.ch"

/*/{Protheus.doc} GTPJobRjInteg
    
    @type  Function
    @author Fernando Radu Muscalu
    @since 16/08/2021
    @version version
    @param
    @return lRet, .t. password recuperado com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPJobRjInteg(aParam)

    Default aParam := {}
    
    If ( Len(aParam) > 0 )
    
        RPCSetType(3)
        RpcSetEnv(aParam[1], aParam[2])

        RpcClearEnv()

    EndIf 

Return()

/*/{Protheus.doc} GTPSchedGet
    
    @type  Function
    @author Fernando Radu Muscalu
    @since 16/08/2021
    @version version
    @param
    @return lRet, .t. password recuperado com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPSchedGet(cJobName)

    Local cRet      := ""
    
    Local nI        := 0

    Local aInfo     := {}
    Local aAux      := {}

    Local oClient
  
    Default cJobName    := ""

    If ( !Empty(cJobName) )
    
        oClient:= GTPRestClass():New('api/framework/v1',.t.)
        oClient:setPath("/jobScheduler?processid=" + cJobName)

        If ( oClient:Get() )
            
            cRet := oClient:getJsonValue("items[0].status") + "|" + oClient:getJsonValue("items[0].lastmodified")
            aInfo := Separa(cRet,"|")
            
            If ( Len(aInfo) > 1 )
                
                aAux := Separa(aInfo[2],"-")
                
                If ( Len(aAux) > 0 )
                    
                    aInfo[2]  := ""

                    For nI := 1 to Len(aAux)

                        If ( Len(aAux[nI]) == 1 )        
                            aInfo[2] += "0" + aAux[nI]
                        Else
                            aInfo[2] += aAux[nI]
                        EndIf

                    Next nI

                EndIf
                
                aInfo[2] := SToD(aInfo[2])

            EndIf    

            If ( !Empty(cRet) .and. Len(aInfo) > 1 )
              
                If ( lower(aInfo[1]) $ "active" .Or.; 
                    (lower(aInfo[1]) $ "completed" .And. aInfo[2] >= dDatabase-1 ) )
                    cRet := "(Schedule ativo)"
                ElseIf ( lower(aInfo[1]) $ "inactive" .Or.; 
                        (lower(aInfo[1]) $ "completed" .And. aInfo[2] < dDataBase-1) )
                    cRet := "(Schedule inativo)"
                Else
                    cRet := "(Sem schedule)"    
                EndIf

            EndIf

        Else
            cRet := Substr(oClient:GetLastError(),1,14) + " - Token de autorização incorreto"
        EndIf

    EndIf

Return(cRet)
