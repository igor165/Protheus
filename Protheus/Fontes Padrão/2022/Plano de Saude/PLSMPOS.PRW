#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "FOLDER.CH"

STATIC cPathIn   := 'M:\LINUX\'   // Path dos arquivos de entrada
STATIC cPathProc := '\POS_PROC\' // Path dos arquivos em processamento
STATIC cPathOut  := '\POS_OUT\'  // Path dos arquivos de saida
STATIC cDriveProc := 'M:\AP6'
STATIC cStartPath  := '\SIGAADV'

/*
Sugestão de INI

[ONSTART]
JOBS=UNI_VERFILES,UNI_PROCFILES
REfreshRate=30 ;; a cada 30 segundos o protheus verifica se os jobs estão no ar.
;; se não estiver , o proprio protheus coloca no ar de novo
c
[UNI_VERFILES]
Environment=STRESS
main=PlsPosRout

[UNI_PROCFILES]
Environment=STRESS
main=PlsPosProc
instances=10

*/

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsPOSGet

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//------------------------------------------------------------------- 
Function PlsPOSGet(cVar,aDad,uDef)
Local cVal:=""
Local nPos
Local aDadBase := {}
DEFAULT uDef := ""
If aDad # NIL
	aDadBase := aClone(aDad)
Else
	If Type("aDadosPOS")=="A"
		aDadBase := aClone(aDadosPOS)
	EndIf
EndIf
nPos := aScan(aDadBase,{|x|AllTrim(x[1])==AllTrim(cVar)})
If nPos > 0
	cVal := aDadBase[nPos,2]
ElseIf uDef # NIL
	cVal := uDef
EndIf
Return cVal
 
 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} PlsPOSPut

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//------------------------------------------------------------------- 
Function PlsPOSPut(cVar,uVal,aDadBase)
Local cVal:=""
Local nPos
nPos := aScan(aDadBase,{|x|AllTrim(x[1])==AllTrim(cVar)})
If nPos > 0
	aDadBase[nPos,2] := uVal
Else
	aadd(aDadBase,{cVar,uVal})
EndIf
Return
            


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsPosUlt

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//------------------------------------------------------------------- 
Function PlsPosUlt()
Return lUltimo



//-------------------------------------------------------------------
/*/{Protheus.doc} PlsGetBSA
Carrega aCab e aIte de acordo com BSA

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//------------------------------------------------------------------- 
Function PlsGetBSA(cNumSeq,cOpeSol)
Local aCab  := {}
Local aIte  := {}
Local aItem := {}
Local cItem := ""     
LOCAL nTam  := TamSX3("BSA_NUMSEQ")[1]
DEFAULT cOpeSol := ''

If Len(cNumSeq) < nTam
   cNumSeq := cNumSeq + Space( nTam - Len(cNumSeq) )
EndIf

//Procuro primeiramente com o codigo da operadora
BSA->(DbSetOrder(1))
If BSA->(MsSeek(xFilial()+cNumSeq+"CAB"+cOpeSol))
	While !BSA->(Eof()) .and. xFilial("BSA")+cNumSeq+"CAB" == BSA->(BSA_FILIAL+BSA_NUMSEQ+BSA_IDENT)
	   If Alltrim(BSA->BSA_CONTEU) == ".T."
	       aadd(aCab,{BSA->BSA_VARIAV,.T.}) 
	   ElseIf Alltrim(BSA->BSA_CONTEU) == ".F."
	  	   aadd(aCab,{BSA->BSA_VARIAV,.F.})
	   Else
	       aadd(aCab,{BSA->BSA_VARIAV,RTrim(BSA->BSA_CONTEU)})      
	   EndIf     
	   BSA->(DbSkip())
	EndDo
	
	BSA->(DbSetOrder(1))
	BSA->(MsSeek(xFilial()+cNumSeq))
	While !BSA->(Eof()) .and. xFilial("BSA")+cNumSeq == BSA->(BSA_FILIAL+BSA_NUMSEQ)
	   If BSA->BSA_IDENT#"CAB"
	      cItem := BSA->BSA_IDENT
	      aItem := {}
	      BSA->(MsSeek(xFilial()+cNumSeq+cItem))
	      While !BSA->(Eof()) .and. xFilial("BSA")+cNumSeq+cItem == BSA->(BSA_FILIAL+BSA_NUMSEQ+BSA_IDENT)
	         aadd(aItem,{BSA->BSA_VARIAV,RTrim(BSA->BSA_CONTEU)})
	         BSA->(DbSkip())
	      EndDo      
	      If Len(aItem) > 0
	         aadd(aIte,aClone(aItem))
	      EndIf
	   Else
	      BSA->(DbSkip())   
	   EndIf   
	EndDo   

//Se nao achou, busco com espacos (manter legado)
ElseIf BSA->(MsSeek(xFilial()+cNumSeq+"CAB"+Space(4)))
	While !BSA->(Eof()) .and. xFilial("BSA")+cNumSeq+"CAB" == BSA->(BSA_FILIAL+BSA_NUMSEQ+BSA_IDENT)
	   If Alltrim(BSA->BSA_CONTEU) == ".T."
	       aadd(aCab,{BSA->BSA_VARIAV,.T.}) 
	   ElseIf Alltrim(BSA->BSA_CONTEU) == ".F."
	  	   aadd(aCab,{BSA->BSA_VARIAV,.F.})
	   Else
	       aadd(aCab,{BSA->BSA_VARIAV,RTrim(BSA->BSA_CONTEU)})      
	   EndIf     
	   BSA->(DbSkip())
	EndDo

	BSA->(DbSetOrder(1))
	BSA->(MsSeek(xFilial()+cNumSeq))
	While !BSA->(Eof()) .and. xFilial("BSA")+cNumSeq == BSA->(BSA_FILIAL+BSA_NUMSEQ)
	   If BSA->BSA_IDENT#"CAB"
	      cItem := BSA->BSA_IDENT
	      aItem := {}
	      BSA->(MsSeek(xFilial()+cNumSeq+cItem))
	      While !BSA->(Eof()) .and. xFilial("BSA")+cNumSeq+cItem == BSA->(BSA_FILIAL+BSA_NUMSEQ+BSA_IDENT)
	         aadd(aItem,{BSA->BSA_VARIAV,RTrim(BSA->BSA_CONTEU)})
	         BSA->(DbSkip())
	      EndDo      
	      If Len(aItem) > 0
	         aadd(aIte,aClone(aItem))
	      EndIf
	   Else
	      BSA->(DbSkip())   
	   EndIf   
	EndDo
EndIf

Return {aCab,aIte}


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsFilePos

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//------------------------------------------------------------------- 
Function PlsFilePos(cFile)
Static cFileLog 

cFileLog := "PLSXMOV_"+DToS(Date())+"_"+AllTrim(Str(ThReadID()))+"_"+ALLTRIM(GetComputerName())+".LOG"

If ValType(cFile) == "C"
   cFileLog := cFile   
   FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "LOG redefinido para "+cFileLog , 0, 0, {})
EndIf
Return cFileLog