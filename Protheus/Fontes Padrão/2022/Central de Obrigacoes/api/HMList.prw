#include "TOTVS.CH"
#include 'FWMVCDEF.CH'

/*/ Atendimento | Autorizador | HMList
Retorna uma colecao de dados em HashMap 
@author Victor Silva
@since 11/2017
/*/

Class HMList

    Data hMap
    Data nPush
    Data nCurentRec

    Method New() Constructor
    Method push()
    Method hasNext()
    Method getNext()
    Method goTop()
    Method goLast()
    Method fromArray()
    Method destroy(hasDestroy)

EndClass

Method New() Class HMList
    self:hMap       := THashMap():New()
    self:nPush      := 0
    self:nCurentRec := 0
Return self

Method push(xValue) Class HMList
    self:hMap:set(self:nPush,xValue)
    self:nPush++
return

Method hasNext() Class HMList
return self:hMap:get(self:nCurentRec)

Method getNext() Class HMList
    Local xValue := ""
    self:hMap:get(self:nCurentRec,xValue)
    self:nCurentRec++
return xValue

Method goTop() Class HMList
    self:nCurentRec := 0
return

Method goLast() Class HMList
    self:nCurentRec := self:nPush-1
return

Method fromArray(aArray) Class HMList
    Local nLen   := len(aArray)
    Local nArray := 1

    For nArray:= 1 to nLen
        self:push(aArray[nArray])
    Next nArray
    
return

Method destroy(hasDestroy) Class HMList
    Local oObjAux      := nil
    Default hasDestroy := .F.
    
    if hasDestroy
        while self:hasNext()
            oObjAux := self:getNext()
            if !empty(oObjAux)
                oObjAux:destroy()
                FreeObj(oObjAux)
                oObjAux := nil
            endif
        enddo
    endif

    self:hMap:clean()
    FreeObj(self:hMap)
    self:hMap := nil

return
