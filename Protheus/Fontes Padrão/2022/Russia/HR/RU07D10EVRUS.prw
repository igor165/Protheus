#include 'totvs.ch'
#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RU07D10.ch"



CLASS RU07D10EVRUS FROM FwModelEvent
	

	METHOD New() 
	METHOD ModelPosVld()

	
END CLASS

METHOD New() CLASS RU07D10EVRUS

Return

/*/{Protheus.doc} ModelPos
Model post validation method.
@author Marina Dubovaya
@since 03/August/2018
@version 1.0
/*/
Method ModelPosVld(oModel, cModelId) Class RU07D10EVRUS
Local lRet  		as logical 
Local cQuery 		as character
Local aArea 		as array
Local cAliasDT 	    as char
Local oDetail := oModel:GetModel('RU07D10_MAGA')
Local cFull		    as char
Local cEst			as char

cAliasDT := ""
cFull := ""
aArea 		:= getArea()

lRet := .T.

If !CR360Cep(M->AGA_CEP)
	lRet := .F.
EndIf

If  lRet
	//DataBase validation
	If Empty(cAliasDT)
		cAliasDT := CriaTrab(,.F.)
	Endif
    If Empty(oDetail:GetValue("AGA_TO"))
       oDetail:LoadValue("AGA_TO",CTOD("31/12/9999"))
    EndIf

    If oDetail:GetValue("AGA_PAIS") == "643"

	   dbSelectArea("SX5")
	   dbSetOrder(1)
	   If dbSeek( XFILIAL("SX5") + "12" + M->AGA_EST)
	     cEst := X5Descri()
	   EndIf
	   If Empty(cEst)
	     cEst := POSICIONE("SX5", 1, XFILIAL("SX5") + "12" + M->AGA_EST, "X5_DESCRI")
	   EndIf
	   cFull += AllTrim(M->AGA_CEP) 	+ IIF(Empty(M->AGA_CEP),"",", ") 
	   cFull += AllTrim(cEst)  			+ IIF(Empty(cEst),"",", ")
	   cFull += AllTrim(M->AGA_BAIRRO)	+ IIF(Empty(M->AGA_BAIRRO),"",", ")
	   cFull += AllTrim(M->AGA_MUNDES)	 + IIF(Empty(M->AGA_MUNDES),"",", ")
	   cFull += AllTrim(M->AGA_COMP)	 + IIF(Empty(M->AGA_COMP),"",", ")
	   cFull += AllTrim(M->AGA_END)		 + IIF(Empty(M->AGA_END),"",", ")
	   cFull += AllTrim(M->AGA_HOUSE)	 + IIF(Empty(M->AGA_HOUSE),"",", ")
	   cFull += AllTrim(M->AGA_BLDNG)	 + IIF(Empty(M->AGA_BLDNG),"",", ")
	   cFull += AllTrim(M->AGA_APARTM)	 + IIF(Empty(M->AGA_APARTM),"",", ")
       cFull := SubStr(AllTrim(cFull),1,Len(AllTrim(cFull))-1)                                
	   oDetail:LoadValue("AGA_FULL",cFull + ".")
    EndIf
    If (oDetail:GetValue("AGA_TO") < oDetail:GetValue("AGA_FROM"))
       lRet := .F.
       Help("",1,"RU07D10EVRUS_ModelPosVld",,STR0003,1,0,,,,,,{STR0016})
   else 
        //check if exist one register with the same interval of dates
       cQuery := "SELECT R_E_C_N_O_, '''AGA_FROM''', AGA_TO FROM " + RetSqlName("AGA") + CRLF
       cQuery += " WHERE AGA_FILIAL = 	'" + xFilial("AGA")+ "'" + CRLF
       cQuery += " AND 	AGA_CODIGO <> 	'" + oDetail:GetValue("AGA_CODIGO") 	+	"'" + CRLF
	   cQuery += " AND 	AGA_TIPO 	= 	'" + oDetail:GetValue("AGA_TIPO") 	+	"'" + CRLF
	   cQuery += " AND 	AGA_ENTIDA 	= 	'" + oDetail:GetValue("AGA_ENTIDA") 	+	"'" + CRLF
       cQuery += " AND 	AGA_CODENT = 	'" + oDetail:GetValue("AGA_CODENT") 	+	"'" + CRLF
       cQuery += " AND 	((('"+ dTOs(oDetail:GetValue("AGA_FROM")) +	"' <= AGA_TO)" + CRLF     
	   cQuery += " AND 	('"+ dTOs(oDetail:GetValue("AGA_FROM")) +	"' >= '''AGA_FROM'''))" + CRLF
       cQuery += " OR 	(('"+ dTOs(oDetail:GetValue("AGA_FROM")) +	"' <= '''AGA_FROM''')" + CRLF
	   cQuery += " AND 	('"+ dTOs(oDetail:GetValue("AGA_TO")) +	"' >= AGA_TO))" + CRLF
	   cQuery += " OR 	(('"+ dTOs(oDetail:GetValue("AGA_TO")) +	"' >= '''AGA_FROM''')" + CRLF
	   cQuery += " AND 	('"+ dTOs(oDetail:GetValue("AGA_TO")) +	"' <= AGA_TO)))" + CRLF
	   cQuery += " AND D_E_L_E_T_ = ' ' "
	   
	   cQuery := ChangeQuery(cQuery) 
	   
	   dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQuery ) , cAliasDT )
	
	   (cAliasDT)->( dbGoTop() )
		
	   If (cAliasDT)->(!EOF())
		   lRet := .F.
		   Help("",1,"RU07D10EVRUS_ModelPosVld",,STR0017,1,0,,,,,,{STR0016})
	    EndIf  
		(cAliasDT)->( dbCloseArea() )  
	EndIf 

EndIf

RestArea(aArea)
Return lRet







// Russia_R5
