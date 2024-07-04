#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OGAX002.CH"

/*/{Protheus.doc} OGAX002
//Programa de acerto de vinculo do título a receber (N8L)
@author marina.muller
@since 30/01/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OGAX002()
    Local lRet := .T.
    
	If MsgYesNo(STR0001) //"Deseja fazer acerto da tabela de vínculo do título a receber (N8L)?"
	   lRet := OGAX002N8L()
	EndIf
	
	If lRet
	   ApMsgAlert(STR0002) //"Acerto realizado com sucesso."
	EndIf	
	
Return 

/*/{Protheus.doc} OGAX002N8L
//Função busca os títulos na SE1 que tenham safra/ contrato e inclui caso não exista na N8L
@author marina.muller
@since 30/01/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OGAX002N8L()
	Local aArea      := GetArea()
	Local lRet 		 := .T.
	Local cAliasSE1  := GetNextAlias()	
	
	BeginSql Alias cAliasSE1
	SELECT *
	  FROM %Table:SE1% SE1
	 WHERE SE1.%NotDel%
	   AND (SE1.E1_CODSAF <> ' '
	    OR SE1.E1_CTROG <> ' ')
	EndSQL

    (cAliasSE1)->(dbGoTop())
    If (cAliasSE1)->(!Eof())
	    While (cAliasSE1)->(!Eof())
		  
		   DbSelectArea("N8L")
		   N8L->(dbSetOrder(1)) //N8L_FILIAL+N8L_PREFIX+N8L_NUM+N8L_PARCEL+N8L_TIPO
		   If .Not. (N8L->(MsSeek((cAliasSE1)->E1_FILIAL+(cAliasSE1)->E1_PREFIXO+(cAliasSE1)->E1_NUM+(cAliasSE1)->E1_PARCELA+(cAliasSE1)->E1_TIPO))) 
		   	  If RecLock("N8L",.T.)
		         N8L->N8L_FILIAL := (cAliasSE1)->E1_FILIAL
		         N8L->N8L_FILORI := (cAliasSE1)->E1_FILIAL
		         N8L->N8L_PREFIX := (cAliasSE1)->E1_PREFIXO
		         N8L->N8L_NUM    := (cAliasSE1)->E1_NUM    
		         N8L->N8L_PARCEL := (cAliasSE1)->E1_PARCELA
		         N8L->N8L_TIPO   := (cAliasSE1)->E1_TIPO   
		         N8L->N8L_CODCTR := (cAliasSE1)->E1_CTROG
		         N8L->N8L_SAFRA  := (cAliasSE1)->E1_CODSAF 
		         N8L->N8L_ORIGEM := "OGAX002"
		         N8L->N8L_HISTOR := STR0003  //"Incluído via acerto - OGAX002." 
		         MsUnLock()
		      EndIf  
		   EndIf	  
		   N8L->( DbCloseArea())
	    	
	       (cAliasSE1)->(dbSkip())
	    EndDo
	    (cAliasSE1)->(dbCloseArea())
	EndIf
		
	RestArea(aArea)
	
Return lRet 
