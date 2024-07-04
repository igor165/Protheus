#include "TOTVS.CH"

#DEFINE SINGLE  "01"
#DEFINE ALL     "02"
#DEFINE INSERT  "03"
#DEFINE DELETE  "04"
#DEFINE UPDATE  "05"

Class MprCenProd 

	Method New() Constructor
	Method mapFromDao(oCenProd, oDaoCenProd)
    Method mapFromJson(oCenProd, oJson, nType)
    
EndClass

Method New() Class MprCenProd
Return self

Method mapFromDao(oCenProd, oDaoCenProd) Class MprCenProd
    
    oCenProd:setCodOpe(AllTrim((oDaoCenProd:cAliasTemp)->B3J_CODOPE))
    oCenProd:setCodigo(AllTrim((oDaoCenProd:cAliasTemp)->B3J_CODIGO))
    oCenProd:setDescri(AllTrim((oDaoCenProd:cAliasTemp)->B3J_DESCRI))
    oCenProd:setForCon(AllTrim((oDaoCenProd:cAliasTemp)->B3J_FORCON))
    oCenProd:setSegmen(AllTrim((oDaoCenProd:cAliasTemp)->B3J_SEGMEN))
    oCenProd:setStatus(AllTrim((oDaoCenProd:cAliasTemp)->B3J_STATUS))
    oCenProd:setDtiNvl(STOD(AllTrim((oDaoCenProd:cAliasTemp)->B3J_DTINVL)))
    oCenProd:setHriNvl(AllTrim((oDaoCenProd:cAliasTemp)->B3J_HRINVL))
    oCenProd:setDttEvl(STOD(AllTrim((oDaoCenProd:cAliasTemp)->B3J_DTTEVL)))
    oCenProd:setHrtEvl(AllTrim((oDaoCenProd:cAliasTemp)->B3J_HRTEVL))
    oCenProd:setAbrang(AllTrim((oDaoCenProd:cAliasTemp)->B3J_ABRANG)) 
	
Return 

Method mapFromJson(oCenProd, oJson, nType) Class MprCenProd

    If nType == UPDATE

        oCenProd:setCodigo(oJson["code"])
        oCenProd:setCodOpe(oJson["healthInsurerCode"])

        If AttIsMemberOf( oJson, "description", .T.)
            oCenProd:setDescri(oJson["description"])
        EndIf
        If AttIsMemberOf( oJson, "wayOfHiring", .T.)
            oCenProd:setForCon(oJson["wayOfHiring"])
        EndIf
        If AttIsMemberOf( oJson, "marketSegmentation", .T.)
            oCenProd:setSegmen(oJson["marketSegmentation"])
        EndIf
        If AttIsMemberOf( oJson, "coverageArea", .T.)
            oCenProd:setAbrang(oJson["coverageArea"]) 
        EndIf
        
    EndIf
    
    If nType == INSERT

        oCenProd:setCodigo(oJson[1]["code"])
        oCenProd:setCodOpe(oJson[1]["healthInsurerCode"])
            
        If AttIsMemberOf( oJson[1], "description", .T.)
            oCenProd:setDescri(oJson[1]["description"])
        EndIf
        If AttIsMemberOf( oJson[1], "wayOfHiring", .T.)
            oCenProd:setForCon(oJson[1]["wayOfHiring"])
        EndIf
        If AttIsMemberOf( oJson[1], "marketSegmentation", .T.)
            oCenProd:setSegmen(oJson[1]["marketSegmentation"])
        EndIf
        If AttIsMemberOf( oJson[1], "coverageArea", .T.)
            oCenProd:setAbrang(oJson[1]["coverageArea"]) 
        EndIf
        
    EndIf

Return

