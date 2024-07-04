#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OGAX001.CH"

Function OGAX001()
    Local lRet := .T.
    
	If MsgYesNo(STR0001) //"Deseja fazer acerto da tabela de vínculo pedido/ nota (N8H/ N8I)?"
	   lRet := OGAX001N8()
	EndIf
	
	If lRet
	   ApMsgAlert(STR0002) //"Acerto realizado com sucesso."
	EndIf	
	
Return 

Static Function OGAX001N8()
	Local aArea      := GetArea()
	Local lRet 		 := .T.
	Local cAliasSC5  := GetNextAlias()	
	Local cAliasSC6  := Nil
	
	BeginSql Alias cAliasSC5
	SELECT *
	  FROM %Table:SC5% SC5
	 WHERE SC5.%NotDel%
	   AND (SC5.C5_CODROM <> ' ' 
	    OR SC5.C5_CODSAF <> ' '
	    OR SC5.C5_TRCNUM <> ' ')
	EndSQL

    (cAliasSC5)->(dbGoTop())
    If (cAliasSC5)->(!Eof())
	    While (cAliasSC5)->(!Eof())
		  
		   DbSelectArea("N8H")
		   N8H->(dbSetOrder(1)) //N8H_FILIAL+N8H_NUMPV
		   If .Not. (N8H->(MsSeek((cAliasSC5)->C5_FILIAL+(cAliasSC5)->C5_NUM))) 
		   	  If RecLock("N8H",.T.)
		         N8H->N8H_FILIAL := (cAliasSC5)->C5_FILIAL 
		         N8H->N8H_NUMPV  := (cAliasSC5)->C5_NUM
		         N8H->N8H_CODCTR := (cAliasSC5)->C5_CONTRA
		         N8H->N8H_CODROM := (cAliasSC5)->C5_CODROM
		         N8H->N8H_ORIGEM := "OGAX001"
		         N8H->N8H_HISTOR := STR0003 //"Incluído via acerto - OGAX001."
		         MsUnLock()
		      EndIf  
		   EndIf	  
		   N8H->( DbCloseArea())
		   
		   cAliasSC6  := GetNextAlias()
		   BeginSql Alias cAliasSC6
		   SELECT *
			 FROM %Table:SC6% SC6
			WHERE SC6.%NotDel%
			  AND SC6.C6_FILIAL = %exp:(cAliasSC5)->C5_FILIAL%  
			  AND SC6.C6_NUM    = %exp:(cAliasSC5)->C5_NUM%
		   EndSQL
		
		   (cAliasSC6)->(dbGoTop())
		   If (cAliasSC6)->(!Eof())
		   	  While (cAliasSC6)->(!Eof())
				 
				 DbSelectArea("N8I")
				 N8I->(dbSetOrder(1)) //N8I_FILIAL+N8I_NUMPV+N8I_ITEMPV
				 If .Not. (N8I->(MsSeek((cAliasSC6)->C6_FILIAL+(cAliasSC6)->C6_NUM+(cAliasSC6)->C6_ITEM))) 
				 	  If RecLock("N8I",.T.)
				         N8I->N8I_FILIAL := (cAliasSC6)->C6_FILIAL 
				         N8I->N8I_NUMPV  := (cAliasSC6)->C6_NUM
				         N8I->N8I_ITEMPV := (cAliasSC6)->C6_ITEM   
				         N8I->N8I_PRODUT := (cAliasSC6)->C6_PRODUTO
				         N8I->N8I_CODCTR := (cAliasSC6)->C6_CTROG  
				         N8I->N8I_SAFRA  := (cAliasSC6)->C6_CODSAF 
				         N8I->N8I_CODROM := (cAliasSC6)->C6_CODROM
				         N8I->N8I_ITEROM := (cAliasSC6)->C6_ITEROM
				         N8I->N8I_ORIGEM := "OGAX001"
				         N8I->N8I_HISTOR := STR0003 //"Incluído via acerto - OGAX001." 
				         MsUnLock()
				      EndIf  
				 EndIf	  
				 N8I->( DbCloseArea())
		   	  	
		   	     (cAliasSC6)->(dbSkip())
		   	  EndDo
		   	  (cAliasSC6)->(dbCloseArea())
		   EndIf
	    	
	       (cAliasSC5)->(dbSkip())
	    EndDo
	    (cAliasSC5)->(dbCloseArea())
	EndIf
		
	RestArea(aArea)
	
Return lRet 
