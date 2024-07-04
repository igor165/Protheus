#INCLUDE "PROTHEUS.CH"

Function LOJXFUNL()
Return

//--------------------------------------------------------
/*{Protheus.doc}LjLogL1Sit
Efetua o Log quando o campo L1_SITUA for alterado
@author  	Julio Nery
@version 	12
@since   	06/11/2020
@return  	Nil
@sample
*/
//--------------------------------------------------------
Function LjLogL1Sit(cAlias,cValor)
Local cCTRL := Chr(10)+Chr(13)  //Pula linha
Local cTexto:= ""
Local aValores:= {}
Local nI    := 0

Default cAlias := "SL1"
Default cValor := ""

//SL1 ja esta posicionado
cTexto := "L1_SITUA alterado para " + Iif(Empty(cValor),(cAlias)->L1_SITUA,cValor) + ;
          " -> Está em Transação ? " + IIf(InTransaction(), "SIM", "NÃO") + ;
		  cCTRL + " Pilha de chamada (ultimas 4 chamadas)"

For nI:= 1 to 4
    AAdd(aValores, ProcName(nI) + " - Linha: " + cValToChar(ProcLine(nI)))
Next nI

LjGrvLog(ProcName(1),cTexto,aValores)
Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} LjGetPdvOn
Retornar se no cadastro de estação existe algum PDV setado 
para trabalhar Online

@type    	function
@author  	Bruno Almeida
@since   	17/05/2022
@version 	12.1.33
@return		Logico - Se existe ou nao um PDV para trabalhar Online
/*/
//-------------------------------------------------------------------
Function LjGetPdvOn()

Local lRet 		:= .F. 			//Variavel de retorno
Local cQuery 	:= ""			//Guarda a query a ser executada
Local aArea		:= GetArea()	//Guarda a area para ser restaurada
Local cAlias    := "" 			//Pega o proximo alias

DbSelectArea("SLG")

If SLG->(ColumnPos("LG_PDVON")) > 0
	cAlias := GetNextAlias()

	cQuery := "SELECT LG_PDVON"
	cQuery += "  FROM " + RetSqlName("SLG")
	cQuery += " WHERE LG_FILIAL = '" + xFilial("SLG") + "'"
	cQuery += "   AND LG_PDVON = '1'"
	cQuery += "   AND D_E_L_E_T_ <> '*'"

	DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)
	
	If !(cAlias)->( Eof() )
		lRet := .T.
	Else
		lRet := .F.
	EndIf

	(cAlias)->( DbCloseArea() )

EndIf

RestArea(aArea)

Return lRet
