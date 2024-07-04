#include 'protheus.ch'
#include 'parmtype.ch'
#include 'totvs.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "GTPJ001.CH"

Function GTPP001(aParam)

local lJob			:= Iif(Select("SX6")==0,.T.,.F.)  //Rotina automatica (schedule)
Local cFilOk 		:= ""
//---Inicio Ambiente

If lJob // Schedule
	RPCSetType(3)
	PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] MODULO "FAT"
EndIf   

/*ConOut( Replicate("R",80) )
ConOut('['+DtoC(dDataBase)+' - '+Time()+'] '+STR0001) //'INICIO DA ROTINA ==> (GTPJ001) Geracao de NF do bilhete '
ConOut( Replicate("R",80) )*/

cFilOk := cfilant

GTPJ001(ljob,'0')

/*ConOut( Replicate("R",80) )
ConOut('['+DtoC(dDataBase)+' - '+Time()+'] '+STR0002) //'FIM DA ROTINA ==> (GTPJ001) Geracao de NF do bilhete'
ConOut( Replicate("R",80) )*/

cFilAnt	:= cFilOk

Return()

Function GTPX001(aParam) //GTPX001('20180401','20180431')

local lJob		:= Iif(Select("SX6")==0,.T.,.F.)  //Rotina automatica (schedule)
Local cFilOk 	:= ""
Local cEmpJob	:= ""
Local cFilJob	:= ""
Local cDtIni	:= ""
Local cDtFim	:= ""
Local lConf		:= .T.
Local lManual	:= .F.
Local cAgencia	:= ""

cDtIni		:= aParam[1]
cDtFim		:= aParam[2]
cAgencia	:= aParam[3]

lConf 	:= IIf (ValType(aParam[4]) == 'L',aParam[4],.T.)
lManual	:= IIf (ValType(aParam[5]) == 'L',aParam[5],.F.)

cEmpJob := aParam[Len(aParam)-3]
cFilJob := aParam[Len(aParam)-2]

//---Inicio Ambiente

If lJob // Schedule
	RPCSetType(3)
	PREPARE ENVIRONMENT EMPRESA cEmpJob FILIAL cFilJob MODULO "FAT"
EndIf   

/*ConOut( Replicate("R",80) )
ConOut('['+DtoC(dDataBase)+' - '+Time()+'] '+STR0001) //'INICIO DA ROTINA ==> (GTPJ001) Geracao de NF do bilhete '
ConOut( Replicate("R",80) )*/

cFilOk := cfilant

If !Empty(cFilOk)
	GTPJ001(ljob,'0',cDtIni,cDtFim, lConf, lManual, cAgencia)
Endif

/*ConOut( Replicate("R",80) )
ConOut('['+DtoC(dDataBase)+' - '+Time()+'] '+STR0002) //'FIM DA ROTINA ==> (GTPJ001) Geracao de NF do bilhete'
ConOut( Replicate("R",80) )*/

cFilAnt	:= cFilOk

Return()

Function GTPJ001(ljob, cTpStatus, cDtini, cDtFim, lConf, lManual, cAgencia)
Default ljob			:= .F.
Default lManual			:= .F.
Default lConf			:= .T.
Default cTpStatus		:= '0'
	
If cTpStatus == '0'
	cTpStatus := GTPGetRules("GERNFSTAT",.F.,'','0')
Endif


GTPJBPE(ljob, cTpStatus, cDtini, cDtFim, cAgencia)
GTPJBPR(ljob, cTpStatus, cDtini, cDtFim, lConf, lManual, cAgencia)

Return .T.
