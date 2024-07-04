#INCLUDE "PWSF090.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/**************************************************************************************************/
//Tela de selecao de Fornecedores
Web Function PWSF090()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWSF020FOR := GetUserFor()
HttpSession->PWSF020APH := { STR0001, "W_PWSF091.APW", "" }//"Ficha de Crédito"

If Len( HttpPost->PWSF020FOR ) <= 1
	HttpSession->PWSF020APH[3] := STR0002		//"Não há fornecedores a consultar."

	cHtml += ExecInPage( "PWSF020" )
ElseIf Len(HttpPost->PWSF020FOR) = 2
	//Apenas 1 cliente. Define a navegação para pular a tela de seleção de cliente
	HttpPost->CODFORERP	:= HttpPost->PWSF020FOR[2][2]

	cHtml += W_PWSF091()
Else
	//Mais de 1 cliente? Chama tela de seleção de CLientes
	cHtml += ExecInPage( "PWSF020" )
EndIf

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para escolha de CGC
Web Function PWSF091()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSFINANCEREGFORM"), WSFINANCEREGFORM():New())
WsChgURL( @oObj, "FINANCEREGFORM.APW" )

If !Empty( HttpPost->CODFORERP )
	HttpSession->CODFORERP := HttpPost->CODFORERP
EndIf

If Empty( HttpSession->PWSF091HEADER )
	HttpSession->PWSF091HEADER := {}
	
	If oObj:GETHEADER( "REGFORMSTRUCT" )
		HttpSession->PWSF091HEADER := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSF090.APW" )//"Erro"
	EndIf
EndIf

HttpSession->PWSF091APH := { STR0001, "W_PWSF092.APW" }//"Ficha de Crédito"

cHtml += ExecInPage( "PWSF091" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para escolha de ordem de producao
Web Function PWSF092()

Local cHtml 	:= ""
Local oObj
Local aWebCols 	:= {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSFINANCEREGFORM"), WSFINANCEREGFORM():New())
WsChgURL( @oObj, "FINANCEREGFORM.APW" )

HttpSession->PWSF092APH := { STR0001 }//"Ficha de Crédito"

oObj:cUSERCODE	:= GetUsrCode()
oObj:cFEDERALID	:= HttpPost->cFEDERALID

//cUSERCODE,cFEDERALID
If oObj:GETREGFORM()
	HttpSession->PWSF092RESULT := { oObj:oWSGETREGFORMRESULT }
	HttpSession->PWSF092INFO := {}

	If ExistBlock( "PEC152" )
		aWebCols := ExecBlock( "PEC152", .F., .F., {} )
	EndIf

	GridLinesEx( { HttpSession->PWSF092INFO, ;
					HttpSession->PWSF091HEADER[1], ;
					HttpSession->PWSF092RESULT[1], ;
					aWebCols, .F., "H",, 0 } )
Else
	Return PWSHTMLALERT( "", STR0003, "", "W_PWSF090.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSF092" )

WEB EXTENDED END

Return cHtml
