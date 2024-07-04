#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WWIS0008

Rotina para controle de numeração customizado.

@author  Allan Constantino Bonfim
@since   03/08/2018
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------  
User Function WWIS0008(cTab, cCampo, lSoma1, lDelete)

Local aArea    	:= GetArea()
Local cCodFull  	:= ""
Local cCodAux  	:= "1"
Local cQuery   	:= ""
Local nTamCampo	:= 0
Local nTamCamp2	:= 0
Local cNextTmp	:= GetNextAlias()
Local cCampo2		:= "" 
Local cTab2		:= ""

Default cTab		:= ""
Default cCampo	:= ""
Default lSoma1	:= .T.
Default lDelete	:= .F.
      
If !EMPTY(cTab) .AND. !EMPTY(cCampo)

	//Definindo o código atual
	nTamCampo := TamSX3(cCampo)[01]
	cCodAux   := PADL(cCodAux, nTamCampo, "0")   //StrTran(cCodAux, ' ', '0')
    
    If cTab == "ZWK"
 		cCampo2 	:= "ZWI_CODIGO" 
		cTab2		:= "ZWI"
		nTamCamp2	:= TamSX3(cCampo2)[01]
	ElseIf cTab == "ZWI"	
 		cCampo2 	:= "ZWK_CODIGO" 
		cTab2		:= "ZWK"
		nTamCamp2	:= TamSX3(cCampo2)[01]		
	EndIf

	//Faço a consulta para pegar as informações	
 	If Empty(cTab2) .And. Empty(cCampo2)   	 
		cQuery := "SELECT ISNULL(MAX(SUBSTRING("+cCampo+", 2, "+cValtoChar(nTamCampo)+")), '"+cCodAux+"') AS CODMAX "+CHR(13)+CHR(10)
		cQuery += "FROM "+RetSQLName(cTab)+" TAB "+CHR(13)+CHR(10)
		cQuery += "WHERE LEN("+cCampo+") = "+cValtoChar(nTamCampo)+" "+CHR(13)+CHR(10)
		//Allan Constantino Bonfim  - 02/11/2018 - CM Solutions - WMS 100% - Ajuste para considerar itens deletados no controle de numeração
		If lDelete
			cQuery += "AND D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
		EndIf
	Else
		cQuery := "SELECT MAX(MAXIMO) AS CODMAX "+CHR(13)+CHR(10)
		cQuery += "FROM (
		cQuery += "		SELECT ISNULL(MAX(SUBSTRING("+cCampo+", 2, "+cValtoChar(nTamCampo)+")), '"+cCodAux+"') AS MAXIMO "+CHR(13)+CHR(10)
		cQuery += "		FROM "+RetSQLName(cTab)+" TAB "+CHR(13)+CHR(10)
		cQuery += "		WHERE LEN("+cCampo+") = "+cValtoChar(nTamCampo)+" "+CHR(13)+CHR(10)
		//Allan Constantino Bonfim  - 02/11/2018 - CM Solutions - WMS 100% - Ajuste para considerar itens deletados no controle de numeração
		If lDelete
			cQuery += "		AND D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
		EndIf
		
		cQuery += "		UNION ALL "+CHR(13)+CHR(10)		
		
		cQuery += "		SELECT ISNULL(MAX(SUBSTRING("+cCampo2+", 2, "+cValtoChar(nTamCamp2)+")), '"+cCodAux+"') AS MAXIMO "+CHR(13)+CHR(10)
		cQuery += "		FROM "+RetSQLName(cTab2)+" TAB "+CHR(13)+CHR(10)
		cQuery += "		WHERE LEN("+cCampo2+") = "+cValtoChar(nTamCamp2)+" "+CHR(13)+CHR(10)
		//Allan Constantino Bonfim  - 02/11/2018 - CM Solutions - WMS 100% - Ajuste para considerar itens deletados no controle de numeração
		If lDelete
			cQuery += "		AND D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
		EndIf	
		cQuery += "		) TMP "+CHR(13)+CHR(10)
	EndIf
    
    cQuery := ChangeQuery(cQuery)
    
    dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cNextTmp)
      
    //Se não tiver em branco
    If !EMPTY((cNextTmp)->CODMAX)
        cCodAux := PADL(ALLTRIM((cNextTmp)->CODMAX), nTamCampo, "0") //ALLTRIM((cNextTmp)->CODMAX)
    EndIf
      
    //Se for para atualizar, soma 1 na variável
    If lSoma1
        cCodAux := Soma1(cCodAux)
    EndIf

	//Allan Constantino Bonfim - 11/09/2018 - WMS 100 % - Ajuste no controle da numeração da tabela integradora WIS.
    //Definindo o código de retorno
	//If FWCodEmp() == '01'
	//	cCodFull := STUFF(cCodAux, 1, 1, "Z")
	//Else      
    	cCodFull := cCodAux
    //EndIf
	
	If Select(cNextTmp) > 0      
   		(cNextTmp)->(DbCloseArea())
   	EndIf
EndIf
   	
RestArea(aArea)

Return cCodFull