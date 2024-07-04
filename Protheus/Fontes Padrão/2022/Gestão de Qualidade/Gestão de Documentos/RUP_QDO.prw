//-------------------------------------------------------------------
/*{Protheus.doc}  RUP_QDO( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
@author brunno.costa
@version P12
@since   15/12/2021
@param  cVersion   - Vers�o do Protheus
@param  cMode      - Modo de execu��o. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada  Ex: 005 
@param  cLocaliz   - Localiza��o (pa�s). Ex: BRA 
*/
//-------------------------------------------------------------------
Function Rup_QDO( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
	//cVersion  - Execucao apenas na release 12
	//cRelStart - Execucao do ajuste apartir da 12.1.2210
	//cMode     - Execucao por grupo de empresas
	If cVersion >= "12"
		If cRelStart >= "2210" .And. cMode == "1"
			QDOAjuX3Ti(cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
		EndIf
	EndIf
Return

/*{Protheus.doc} QDOAjuX3Ti
Renomeia o T�tulo do Campo QAA_TPWORD para 'Tipo Exibi��o'.
@author brunno.costa
@version P12
@since   15/12/2021
@param  cVersion   - Vers�o do Protheus
@param  cMode      - Modo de execu��o. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada  Ex: 005 
@param  cLocaliz   - Localiza��o (pa�s). Ex: BRA 
*/
Static Function QDOAjuX3Ti(cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

	Local aSaveArea	as Array
	Local cUpdate   as Character  

	aSaveArea := GetArea()

	cUpdate := " UPDATE " + RetSqlName("SX3")
	cUpdate += " SET  "
	cUpdate +=   " X3_TITULO = 'Tipo Exib.', "
	cUpdate +=   " X3_TITSPA = 'Tipo Visu.', "
	cUpdate +=   " X3_TITENG = 'Display Tp' "
	cUpdate += " WHERE (D_E_L_E_T_ = ' ') "
	cUpdate +=   " AND (X3_CAMPO = 'QAA_TPWORD') "
	cUpdate +=   " AND (X3_TITULO <> 'Tipo Exib.') "

	If TcSqlExec( cUpdate ) <> 0
		UserException( RetSqlName("SX3") + " "+ TCSqlError() )
	Endif

	RestArea(aSaveArea)
Return
