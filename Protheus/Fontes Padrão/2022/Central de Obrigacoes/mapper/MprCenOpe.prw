#include "TOTVS.CH"

#DEFINE SINGLE  "01"
#DEFINE ALL     "02"
#DEFINE INSERT  "03"
#DEFINE DELETE  "04"
#DEFINE UPDATE  "05"

Class MprCenOpe 
	Method New() Constructor
	Method mapFromDao(oCenOpe, oDaoCenOpe)
EndClass

Method New() Class MprCenOpe
Return self

Method mapFromDao(oCenOpe, oDaoCenOpe) Class MprCenOpe
    
    oCenOpe:setCodOpe(AllTrim((oDaoCenOpe:cAliasTemp)->B8M_CODOPE))
    oCenOpe:setCnpjOp(AllTrim((oDaoCenOpe:cAliasTemp)->B8M_CNPJOP))
    oCenOpe:setRazSoc(AllTrim((oDaoCenOpe:cAliasTemp)->B8M_RAZSOC))
    oCenOpe:setNomFan(AllTrim((oDaoCenOpe:cAliasTemp)->B8M_NOMFAN))
    oCenOpe:setNatJur(AllTrim((oDaoCenOpe:cAliasTemp)->B8M_NATJUR))
    oCenOpe:setModali(AllTrim((oDaoCenOpe:cAliasTemp)->B8M_MODALI))
    oCenOpe:setSegmen(AllTrim((oDaoCenOpe:cAliasTemp)->B8M_SEGMEN))

Return 