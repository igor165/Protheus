#include "TOTVS.CH"
#include 'FWMVCDEF.CH'

/*/ AutJsonControl
Encapsula objeto da TEC JsonObject para controlar os filtros

@type   class
@author victor.silva
@since  20180523
/*/

Class AutJsonControl

    Data hmFields
    Data hmExpand
    Data lFiltered
    Data lExpanding
    
    Method New()
    
    Method prepFields(cFields)
    Method prepExpand(cExpand)
    Method getExpandables(aExpandables)

    Method notFiltered()
    Method expand(oJson,cProp)
    Method fillExpandable(oJson,cProp,oValue)
    Method fillArray(oJson,cProp,oValue)
    Method newArray(oJson,cProp)
    Method newObj(oJson,cProp)
    Method printProp(cProp)
    Method setProp(oJson,cProp,cValue)
    Method setPropObj(oJson,cObj,cProp,cValue)
    Method oBjArray(oJson,cProp, oObj)

EndClass

Method New() Class AutJsonControl
    self:lFiltered     := .F.
    self:lExpanding    := .F.
    self:hmFields      := THashMap():New()
    self:hmExpand      := THashMap():New()
Return self

Method prepFields(cFields) Class AutJsonControl
    Local aFields     := {}
    Local nFields     := 1
    Local nLenFields  := 0

    if !empty(cFields)
        self:lFiltered := .T.
        aFields := StrTokArr2(cFields, ",")
        nLenFields := Len(aFields)
        self:hmFields:set("nLenFields",nLenFields)
        for nFields := 1 to nLenFields
            self:hmFields:set(aFields[nFields],aFields[nFields])
        next nFields
    endif
    
return

Method prepExpand(cExpand) Class AutJsonControl
    Local nExpand    := 0
    Local nLenExpand := 0
    Local aExpand    := {}
    Local aExpChild  := {}
    Local nExpChild  := 1
    Local nLenChild  := 0

    if !empty(cExpand)
        aExpand := StrTokArr2(cExpand, ",")
        nLenExpand := Len(aExpand)
        for nExpand := 1 to nLenExpand
            if At(".",aExpand[nExpand]) > 0
                aExpChild := StrTokArr2(aExpand[nExpand], ".")
                nLenChild := Len(aExpChild)
                if self:printProp(aExpChild[nExpChild])
                    for nExpChild := 1 to nLenChild
                        self:hmExpand:set(aExpChild[nExpChild],aExpChild[nExpChild])
                    next
                endif 
            elseif self:printProp(aExpand[nExpand])
                self:hmExpand:set(aExpand[nExpand],aExpand[nExpand])
            endif
        next nExpand
    endif

    aExpand := Nil
    aExpChild := Nil

return

Method getExpandables(aExpandables) Class AutJsonControl
    Local nExpand    := 1
    Local nLenExpand := Len(aExpandables)

    while nExpand <= nLenExpand
        if self:hmExpand:get(aExpandables[nExpand])
            ArrayPop(@aExpandables,nExpand)
            nLenExpand--
        else
            nExpand++
        endif
    enddo

return aExpandables

Method notFiltered() Class AutJsonControl
Return !self:lFiltered .Or. self:lExpanding

Method expand(oJson,cProp,lList) Class AutJsonControl
    Local lExpand := self:hmExpand:get(cProp)
    Default lList := .F.
         
    if !lExpand
        iif(!lList,self:newObj(oJson,cProp),self:newArray(oJson,cProp))
    endif

return lExpand

Method fillExpandable(oJson,cProp,oValue) Class AutJsonControl
    
    if !empty(oValue)
        // TODO - instanciar novo jSonControl pro expandable
        self:lExpanding := .T.
        self:setProp(oJson,cProp,oValue:serialize(self))
        self:lExpanding := .F.
    else
        self:setProp(oJson,cProp,JsonObject():New())
    endif
return

Method fillArray(oJson,cProp,oValue) Class AutJsonControl
    
    if !empty(oValue)
        aAdd(oJson[cProp],oValue:serialize(self))
    else
        aAdd(oJson[cProp],JsonObject():New())
    endif
return

//Everton -- Criada para adicionar objetos ao array sem serialize
Method oBjArray(oJson,cProp, oObj) Class AutJsonControl
    
    if !empty(oObj:toJson())
        aAdd(oJson[cProp], oObj)
    else
        aAdd(oJson[cProp],JsonObject():New())
    endif

return

Method newArray(oJson,cProp) Class AutJsonControl
    oJson[cProp] := {}
return

Method newObj(oJson,cProp) Class AutJsonControl
    oJson[cProp] := JsonObject():New()
return

Method printProp(cProp) Class AutJsonControl
return !self:lFiltered .Or. (self:lFiltered .And. self:hmFields:get(cProp))

Method setProp(oJson,cProp,cValue) Class AutJsonControl
    if self:printProp(cProp) .Or. self:lExpanding
        oJson[cProp] := cValue
    endif
return

Method setPropObj(oJson,cObj,cProp,cValue) Class AutJsonControl
    if self:printProp(cProp) .Or. self:lExpanding
        oJson[cObj][cProp] := cValue
    endif
return
