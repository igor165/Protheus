#include "TOTVS.CH"
#include "protheus.ch"

#DEFINE SINGLE  "01"
#DEFINE ALL     "02"
#DEFINE INSERT  "03"
#DEFINE DELETE  "04"
#DEFINE UPDATE  "05"

Class MprCenArqSib 

	Method New() Constructor
	Method mapFromDao(oCenArqSib, oDaoCenArqSib)
    
EndClass

Method New() Class MprCenArqSib
Return self

Method mapFromDao(oCenArqSib, oDaoCenArqSib) Class MprCenArqSib

    oCenArqSib:setCodOpe(AllTrim((oDaoCenArqSib:cAliasTemp)->B3R_CODOPE))
    oCenArqSib:setCdObri(AllTrim((oDaoCenArqSib:cAliasTemp)->B3R_CDOBRI))
    oCenArqSib:setAno(AllTrim((oDaoCenArqSib:cAliasTemp)->B3R_ANO))
    oCenArqSib:setCdComp(AllTrim((oDaoCenArqSib:cAliasTemp)->B3R_CDCOMP))
    oCenArqSib:setArquiv(AllTrim((oDaoCenArqSib:cAliasTemp)->B3R_ARQUIV))
    oCenArqSib:setSeqArq(AllTrim((oDaoCenArqSib:cAliasTemp)->B3R_SEQARQ))

Return
