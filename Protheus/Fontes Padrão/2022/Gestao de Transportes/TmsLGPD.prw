#Include "protheus.ch"

//-------------------------------------------------------------------
/*TMLGPDCpPr
Retorna campos sensÃ­veis e pessoais do Alias e utilizados na Rotina.
@author  Leandro Paulino
@since   09/12/2019
@version 1.0      
*/
//-------------------------------------------------------------------

Function TMLGPDCpPr(aCposRotin,cAlias)  //--Retorna campos SensÃ­veis     

Local aCposAlias 	:= {} //--Campos que sÃ£o sensiveis ou pessoais do Alias
Local nCountCpo		:= 0
Local aRetCpoUsa	:= {} //--Campos que sÃ£o sensÃ­veis ou pessoais e sÃ£o usados na rotina.  

Default aCposRotin 	:= {} //--Array com os campos que sÃ£o apresentados pela Rotina
Default cAlias		:= ''

If !Empty(cAlias) .And. Len(aCposRotin) > 0
	aCposAlias := FwProtectedDataUtil():GetAliasFieldsInList(cAlias)
	If Len(aCposRotin) > 0
		For nCountCpo := 1 To Len(aCposAlias)								
			If Ascan( aCposRotin, { |x|  AllTrim(x) == aCposAlias[nCountCpo]:CFIELD } ) > 0
				AADD(aRetCpoUsa,aCposAlias[nCountCpo]:CFIELD)
			EndIf
		Next nCountCpo
	EndIf
 EndIf

Return aRetCpoUsa


//-------------------------------------------------------------------
/*TMSMovMot
Pesquisa a ultima Viagem realizada pelo Motorista
@author  Katia
@since   25/06/2021
@version 12.1.33
@Função utilizada na regra de mapeamento do LGPD (XX..)     
*/
//-------------------------------------------------------------------
Function TMSMovMot(cCodMot)
Local lRet      := .F.
Local cQuery    := ""
Local cAliasQry := ""

Default cCodMot := ""

If !Empty(cCodMot)	
	cAliasQry := GetNextAlias()	
	cQuery := " SELECT MAX( CASE WHEN DTR.DTR_DATFIM <> ' ' THEN DTR.DTR_DATFIM  ELSE  DTQ.DTQ_DATGER END) AS DATAVGE  "  
	cQuery += " FROM " + RetSQLName('DUP') + " DUP "

	cQuery += "  INNER JOIN " + RetSqlName("DTQ") + "  DTQ "
	cQuery += "	ON  DTQ.DTQ_FILIAL     = '" + xFilial("DTQ") + "' "
	cQuery += "	AND DTQ.DTQ_FILORI     = DUP.DUP_FILORI "
	cQuery += "	AND DTQ.DTQ_VIAGEM     = DUP.DUP_VIAGEM "
	cQuery += "	AND DTQ.D_E_L_E_T_ = ' '  "

	cQuery += "  INNER JOIN " + RetSqlName("DTR") + "  DTR "
	cQuery += "	ON  DTR.DTR_FILIAL     = '" + xFilial("DTR") + "' "
	cQuery += "	AND DTR.DTR_FILORI     = DUP.DUP_FILORI "
	cQuery += "	AND DTR.DTR_VIAGEM     = DUP.DUP_VIAGEM "
	cQuery += "	AND DTR.D_E_L_E_T_ = ' '  "

	cQuery += " WHERE DUP.DUP_FILIAL = '" + xFilial('DUP') + "' "
	cQuery += " AND DUP.DUP_CODMOT = '" + cCodMot + "' "
	cQuery += " AND DUP.D_E_L_E_T_ = '' "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	TCSetField(cAliasQry,"DATAVGE","D",8,0)
	If (cAliasQry)->( !Eof() ) .And. !Empty((cAliasQry)->DATAVGE)
		lRet:= VldPrazo((cAliasQry)->DATAVGE)	 
	Else
		lRet := .T. //Para casos que não encontrou  viagem para o motorista
	EndIf

	(cAliasQry)->(DbCloseArea())
EndIf

Return lRet


//-------------------------------------------------------------------
/*TMSMovAju
Pesquisa a ultima Viagem realizada pelo Ajudante
@author  Katia
@since   25/06/2021
@version 1.0      
@Função utilizada na regra de mapeamento do LGPD (XX..)  
*/
//-------------------------------------------------------------------
Function TMSMovAju(cCodAju)
Local lRet      := .F.
Local cQuery    := ""
Local cAliasQry := ""

Default cCodAju := ""

If !Empty(cCodAju)		
	cAliasQry := GetNextAlias()
	cQuery := " SELECT MAX( CASE WHEN DTR.DTR_DATFIM <> ' ' THEN DTR.DTR_DATFIM  ELSE  DTQ.DTQ_DATGER END) AS DATAVGE  "  
	cQuery += " FROM " + RetSQLName('DUQ') + " DUQ "

	cQuery += "  INNER JOIN " + RetSqlName("DTQ") + "  DTQ "
	cQuery += "	ON  DTQ.DTQ_FILIAL     = '" + xFilial("DTQ") + "' "
	cQuery += "	AND DTQ.DTQ_FILORI     = DUQ.DUQ_FILORI "
	cQuery += "	AND DTQ.DTQ_VIAGEM     = DUQ.DUQ_VIAGEM "
	cQuery += "	AND DTQ.D_E_L_E_T_ = ' '  "

	cQuery += "  INNER JOIN " + RetSqlName("DTR") + "  DTR "
	cQuery += "	ON  DTR.DTR_FILIAL     = '" + xFilial("DTR") + "' "
	cQuery += "	AND DTR.DTR_FILORI     = DUQ.DUQ_FILORI "
	cQuery += "	AND DTR.DTR_VIAGEM     = DUQ.DUQ_VIAGEM "
	cQuery += "	AND DTR.D_E_L_E_T_ = ' '  "

	cQuery += " WHERE DUQ.DUQ_FILIAL = '" + xFilial('DUQ') + "' "
	cQuery += " AND DUQ.DUQ_CODAJU = '" + cCodAju + "' "
	cQuery += " AND DUQ.D_E_L_E_T_ = '' "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	TCSetField(cAliasQry,"DATAVGE","D",8,0)
	If (cAliasQry)->( !Eof() ) .And. !Empty((cAliasQry)->DATAVGE)
		lRet:= VldPrazo((cAliasQry)->DATAVGE) 
	Else
		lRet := .T. //Para casos que não encontrou  viagem para o ajudante
	EndIf

    (cAliasQry)->(DbCloseArea())
EndIf

Return lRet

//-------------------------------------------------------------------
/*VldPrazo
Valida o Prazo a partir da Ultima Movimentação do Motorista/Ajudante
@author  Katia
@since   25/06/2021
@version 1.0      
@Função utilizada na regra de mapeamento do LGPD (XX..)  
*/
//-------------------------------------------------------------------
Static Function VldPrazo(dDataVge)
Local lRet      := .F.
Local nPrazo    := 30 //Anos

Default dDataVge:= CtoD('')

If !Empty(dDataVge) 
	If DateDiffYear( Date() , dDataVge ) > nPrazo
		lRet:= .T.
	EndIf
EndIf

Return lRet
