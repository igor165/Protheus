#include 'PROTHEUS.CH'


/*/{Protheus.doc} RU99SIGNER
(Function to get signers for reports)
@type function
@author Andrey Filatov
@since 30/03/2017
@version 1.0
@return ${cEmployee}, ${Employee}

/*/

Function RU99SIGNER(cReport as character, dDate as date,cCargo as character)
Local cQuery as character
Local cEmployee as character
Local lRet as logical
Local aArea as array
Local cAliasF42 as character

lRet := .T.
aArea := getArea()

If lRet
	If Empty(cAliasF42)
		cAliasF42 := CriaTrab(,.F.)
	Endif
	cQuery := "SELECT F42_NAME FROM " + RetSqlName("F42") + CRLF
	cQuery += " WHERE F42_FILIAL = 	'" + xFilial("F42")+ "'" + CRLF
	cQuery += " AND 	F42_REPORT = 	'" + cReport 	+	"'" + CRLF
	cQuery += " AND 	F42_CARGO = 	'" + cCargo 	+	"'" + CRLF
	cQuery += " AND 	(F42_DFROM <= 	'" + dTOs(dDate) 	+	"'" + CRLF
	cQuery += " AND 	F42_DATETO >= 	'" + dtos(dDate) 	+	"')" + CRLF
	cQuery += " AND D_E_L_E_T_ = ' ' "
	
	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQuery ) , cAliasF42 )
	(cAliasF42)->( dbGoTop() )
	lRet := (cAliasF42)->(!EOF())
	If lRet
		cEmployee := AllTrim((cAliasF42)->(F42_NAME))
	Else
		cEmployee := ''
	EndIf
	(cAliasF42)->( dbCloseArea() )
EndIf

RestArea(aArea)

Return cEmployee

//merge branch 12.1.19
// Russia_R5
