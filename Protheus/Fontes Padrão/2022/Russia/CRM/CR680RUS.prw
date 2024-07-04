#include 'totvs.ch'
#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

CLASS CR680RUS FROM FwModelEvent
	
	DATA _lChang as Logical
	DATA _cRecnoC as char
	DATA _cDateF as char
	
	METHOD New() 
	METHOD ModelPosVld()
	METHOD After()
	
	
END CLASS

METHOD New() CLASS CR680RUS

::_lChang := .F.
::_cRecnoC := ""
::_cDateF := ""
Return

/*/{Protheus.doc} ModelPos
Metodo de pos validacao do modelo.
Model post validation method.
@author Andrews.Egas
@since 06/09/2016
@version 1.0
/*/
Method ModelPosVld(oModel, cModelId) Class CR680RUS
Local lRet  		as logical 
Local cQuery 		as character
Local aArea 		as array
Local cAliasDT 	as char
Local oDetail := oModel:GetModel('AGAMASTER')
Local cFull		as char
Local cEst			as char
Local lDeleta		:= oModel:GetOperation() == MODEL_OPERATION_DELETE

cAliasDT := ""
cFull := ""
aArea 		:= getArea()

lRet := .T.

If !CR360Cep(M->AGA_CEP)
	lRet := .F.
EndIf
If !lDeleta .And. lRet
	//DataBase validation
	If Empty(cAliasDT)
		cAliasDT := CriaTrab(,.F.)
	Endif	
	//check if there is the same date from
	cQuery := "SELECT AGA_CODIGO FROM " + RetSqlName("AGA") + CRLF
	cQuery += " WHERE AGA_FILIAL = 	'" + xFilial("AGA")+ "'" + CRLF
	cQuery += " AND 	AGA_CODIGO <> 	'" + oDetail:GetValue("AGA_CODIGO") 	+	"'" + CRLF
	cQuery += " AND 	AGA_TIPO 	= 	'" + oDetail:GetValue("AGA_TIPO") 	+	"'" + CRLF
	cQuery += " AND 	AGA_ENTIDA 	= 	'" + oDetail:GetValue("AGA_ENTIDA") 	+	"'" + CRLF
	cQuery += " AND 	AGA_CODENT = 	'" + oDetail:GetValue("AGA_CODENT") 	+	"'" + CRLF
	cQuery += " AND 	AGA_FROM 	= 	'" + dTOs(oDetail:GetValue("AGA_FROM")) 	+	"'" + CRLF
	cQuery += " AND D_E_L_E_T_ = ' ' "
		
	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQuery ) , cAliasDT )
	
	(cAliasDT)->( dbGoTop() )
	
	If (cAliasDT)->(!EOF())
		lRet := .F.
		Help(" ",1,"CR680DTUSED") // A data selecionada ja esta sendo utilizada 
	EndIf
	(cAliasDT)->( dbCloseArea() )
	
	If lRet
		//check if exist one register with the same interval of dates
		cQuery := "SELECT R_E_C_N_O_, AGA_FROM, AGA_TO FROM " + RetSqlName("AGA") + CRLF
		cQuery += " WHERE AGA_FILIAL = 	'" + xFilial("AGA")+ "'" + CRLF
		cQuery += " AND 	AGA_CODIGO <> 	'" + oDetail:GetValue("AGA_CODIGO") 	+	"'" + CRLF
		cQuery += " AND 	AGA_TIPO 	= 	'" + oDetail:GetValue("AGA_TIPO") 	+	"'" + CRLF
		cQuery += " AND 	AGA_ENTIDA 	= 	'" + oDetail:GetValue("AGA_ENTIDA") 	+	"'" + CRLF
		cQuery += " AND 	AGA_CODENT = 	'" + oDetail:GetValue("AGA_CODENT") 	+	"'" + CRLF
		cQuery += " AND 	('"+ dTOs(oDetail:GetValue("AGA_FROM")) +	"' <= AGA_TO" + CRLF
		cQuery += " AND 	'"+ dTOs(oDetail:GetValue("AGA_FROM")) +	"' > AGA_FROM)" + CRLF
		cQuery += " AND D_E_L_E_T_ = ' ' "
		
		dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQuery ) , cAliasDT )
	
		(cAliasDT)->( dbGoTop() )
		
		If (cAliasDT)->(!EOF())
			oDetail:LoadValue("AGA_TO",(cAliasDT)->AGA_TO)
			::_lChang := .T.
			::_cRecnoC := (cAliasDT)->(R_E_C_N_O_)
			::_cDateF	:= dTOs(oDetail:GetValue("AGA_FROM"))
			(cAliasDT)->( dbCloseArea() )
			//take date_FROM by current register in browse to put in date TO  
		Else
			(cAliasDT)->( dbCloseArea() )
			
			cQuery := "SELECT AGA_FROM, AGA_TO FROM " + RetSqlName("AGA") + CRLF
			cQuery += " WHERE AGA_FILIAL = 	'" + xFilial("AGA")+ "'" + CRLF
			cQuery += " AND 	AGA_CODIGO <> 	'" + oDetail:GetValue("AGA_CODIGO") 	+	"'" + CRLF
			cQuery += " AND 	AGA_TIPO 	= 	'" + oDetail:GetValue("AGA_TIPO") 	+	"'" + CRLF
			cQuery += " AND 	AGA_ENTIDA 	= 	'" + oDetail:GetValue("AGA_ENTIDA") 	+	"'" + CRLF
			cQuery += " AND 	AGA_CODENT = 	'" + oDetail:GetValue("AGA_CODENT") 	+	"'" + CRLF
			cQuery += " AND 	'"+ dTOs(oDetail:GetValue("AGA_FROM")) +	"' < AGA_FROM" + CRLF
			cQuery += " AND D_E_L_E_T_ = ' ' "
		
			dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQuery ) , cAliasDT )
	
			(cAliasDT)->( dbGoTop() )
			
			If (cAliasDT)->(!EOF())
				oDetail:LoadValue("AGA_TO",STOD((cAliasDT)->AGA_FROM)-1)
			Else
			
				(cAliasDT)->( dbCloseArea() )
				//check if there is no register, to fill AGA_FROM with initial date
				cQuery := "SELECT AGA_FROM, AGA_TO FROM " + RetSqlName("AGA") + CRLF
				cQuery += " WHERE AGA_FILIAL = 	'" + xFilial("AGA")+ "'" + CRLF
				cQuery += " AND 	AGA_CODIGO <> 	'" + oDetail:GetValue("AGA_CODIGO") 	+	"'" + CRLF
				cQuery += " AND 	AGA_TIPO 	= 	'" + oDetail:GetValue("AGA_TIPO") 	+	"'" + CRLF
				cQuery += " AND 	AGA_ENTIDA 	= 	'" + oDetail:GetValue("AGA_ENTIDA") 	+	"'" + CRLF
				cQuery += " AND 	AGA_CODENT = 	'" + oDetail:GetValue("AGA_CODENT") 	+	"'" + CRLF
				cQuery += " AND D_E_L_E_T_ = ' ' "
			
				dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQuery ) , cAliasDT )
		
				(cAliasDT)->( dbGoTop() )
				
				If (cAliasDT)->(EOF())
					oDetail:LoadValue("AGA_FROM",CTOD("01/01/1900"))
				EndIf
				
				oDetail:LoadValue("AGA_TO",CTOD("31/12/9999"))
			EndIf
			(cAliasDT)->( dbCloseArea() )
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
	EndIF
	
	//force to dont save without date
	If Empty(oDetail:GetValue("AGA_TO"))
		oDetail:LoadValue("AGA_TO",CTOD("31/12/9999"))
	EndIf
	
EndIf
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} After
After commit
@author Andrews.Egas
@since 06/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Method After(oModel, cModelId, cAlias, lNewRecord) class CR680RUS
Local aArea 		:= getArea()

	If ::_lChang
		dbSelectArea("AGA")
		AGA->(DbSetOrder(0))
		
		AGA->(dbGoTo(::_cRecnoC))
		
		RecLock("AGA",.F.)
		AGA->AGA_TO := STOD(::_cDateF) - 1
		AGA->(MsUnLock())
		
	EndIf
	
RestArea(aArea)	
Return
//merge branch 12.1.19
// Russia_R5
