#Include "Protheus.ch"
#Include "Plsr707.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"
 

//---------------------------------------------------------------------------------
/*/{Protheus.doc} PLSR707
@author  Renan Martins	
@version P12
@since   10/2016
@Obs Relatório com os procedimentos permitidos de acordo com a RDA     
//---------------------------------------------------------------------------------
/*/
Function PLSR707()
Local aResult		:= {}
Local cCodRDA 	:= ""
Local cCodOpe		:= PlsIntPad()
Local cCodEsp		:= ""
Local cCodLoc		:= ""
Local cEndMail	:= ""
Local cCodTab		:= ""
Local lGerRel 	:= .T.
Local lEnvmail	:= .T.
Local lExbNel		:= .F.

B96->(DbSelectArea("B96"))
B96->(DbGoTop())

While !B96->(EOF())  
   
	IF(B96->B96_STATUS = "Aguardo") 
		cCodRda 	:= B96->B96_CODRDA
		cCodEsp 	:= B96->B96_CODESP
		cCodLoc 	:= B96->B96_LOCATE  
		cEndMail 	:= B96->B96_EMAIL 
		cCodTab	:= B96->B96_CODTAB
		cFormRel	:= B96->B96_FORMRE
  		//PlsChJRPr (cCodRDA, cCodOpe, cCodLoc, cCodEsp, .F., , lGerRel, lEnvmail, cEndMail, , "2")
  		aResult := PLSATBPR(cCodRDA, cCodOpe, cCodLoc, cCodEsp, lExbNel, , lGerRel, lEnvMail, cEndMail, , {}, "2", cCodTab, cFormRel)
  		If aResult[1]
  			PLSGRB96(aResult[3], cFormRel)
  		EndIf 
	ENDIF
      B96->(DbSkip())   
EndDo	
   
B96->(Dbclosearea())
Return  


//---------------------------------------------------------------------------------
/*/{Protheus.doc} PLSGRB96
@author  Renan Martins	
@version P12
@since   10/2016
@Obs Grava o resultado após processamento  e atualiza o status    
//---------------------------------------------------------------------------------
/*/
Function PLSGRB96(cName, cTipoRel)
  B96->(RecLock("B96", .F.))
    B96->B96_DTAPRO	:= date()
    B96->B96_ARQUP 	:= IIF (cTipoRel == "1", cName+".pdf", cName+".xls")
    B96->B96_STATUS	:= "Processado"
  B96->(MSunlock())
Return ()
 


//---------------------------------------------------------------------------------
/*/{Protheus.doc} PLSINB96
@author  Renan Martins	
@version P12
@since   10/2016
@Obs Inclui na B96 as solicitações de tabelas dos prestadores
//---------------------------------------------------------------------------------
/*/
Function PLSINB96(cCodTb, cCodRDA, cCodLoc, cCodEsp, UsuEmai, PLSCodUsr, cForRel, lBusca)  
Local lFlagIn		:= .F.
Local lSaiGr		:= .F.
Local aArea		:= GetArea()		
Local cRetS		:= ""
Local cpadBkp		:= ""
Local aTabDup 	:= PlsBusTerDup(SuperGetMv("MV_TISSCAB",.F.,"87"))
Local cCompl		:= ""
Default cCodTb	:= ""
Default cCodLoc	:= ""
Default cCodEsp	:= ""
Default cUsuEmai	:= ""
Default lBusca	:= .F.


//DE/PARA da tabela e procedimento ANS para código interno.
//cColuna, cAlias, lMsg, cCodTab , cVlrTiss, lPortal, aTabDup, cPadBkp )
cPadBkp	:= PLSGETVINC("BTU_VLRBUS", "BR4", .F., "87", cCodTb, .T.)
cCodTb		:= AllTrim(cPadBkp)
		
//Filtrar
B96->(DbSetorder(3))
If B96->(DbSeek((xFilial("B96")) + cCodRDA + "Aguardo   " + DtoS(date()) )) 
	If( Empty(cCodLoc) .AND. Empty(cCodEsp) )
		While !B96->(EOF()) //.AND. B96->B96_CODRDA == cCodRDA .AND. B96->B96_STATUS == "Aguardo   " 
			If (Empty(B96->B96_LOCATE) .AND. Empty(B96->B96_CODESP) .AND. B96->B96_FORMRE == cForRel) 
				cRetS := "false|"+STR0020  //Existe solicitação em andamento para este relatório. Não é possível solicitar enquanto o status não ficar como PROCESSADO!"
				lSaiGr := .T.
				Exit
			EndIf	
			B96->(DbSkip())
		EndDo
	
	ElseIf	(!Empty(cCodLoc) .AND. !Empty(cCodEsp))
		While !B96->(EOF()) //.AND. B96->B96_CODRDA == cCodRDA .AND. B96->B96_STATUS == "Aguardo   " 
			If (B96->B96_LOCATE == cCodLoc .AND. B96->B96_CODESP == cCodEsp .AND. B96->B96_FORMRE == cForRel)
				cRetS := "false|"+STR0020  //Existe solicitação em andamento para este relatório. Não é possível solicitar enquanto o status não ficar como PROCESSADO!"
				lSaiGr := .T.
				Exit
			EndIf	
			B96->(DbSkip())
		EndDo
		
	ElseIf	(!Empty(cCodLoc))
		While !B96->(EOF()) //.AND. B96->B96_CODRDA == cCodRDA .AND. B96->B96_STATUS == "Aguardo   " 
			If (B96->B96_LOCATE == cCodLoc .AND. B96->B96_FORMRE == cForRel .AND. Empty(B96->B96_CODESP) )
				cRetS := "false|"+STR0020  //Existe solicitação em andamento para este relatório. Não é possível solicitar enquanto o status não ficar como PROCESSADO!"
				lSaiGr := .T.
				Exit
			EndIf	
			B96->(DbSkip())
		EndDo
	Else
		lFlagIn := .T.
	ENDIF
Else
	lFlagIn := .T.
EndIf

IIF (!lSaiGr, lFlagIn := .T., "")
		
IF lFlagIn  //Se .T. em alguma condição, gravar dados na tabela 
	B96->(RecLock("B96", .T.)) 
		B96->B96_FILIAL 	:= xFilial("B96")
		B96->B96_CODRDA	:= cCodRDA
  		B96->B96_CODTAB 	:= cCodTb
  		B96->B96_LOCATE 	:= cCodLoc
  		B96->B96_CODESP	:= cCodEsp
  		B96->B96_USUARI	:= PLSCodUsr 
  		B96->B96_DTAREQ	:= date()
  		B96->B96_STATUS	:= "Aguardo" 
  		B96->B96_EMAIL	:= UsuEmai
  		B96->B96_FORMRE	:= cForRel
  	B96->(MsUnlock())
  	cRetS := "true|" + STR0019
ENDIF	

RestArea(aArea) 
//DbcloseArea() 

Return cRetS