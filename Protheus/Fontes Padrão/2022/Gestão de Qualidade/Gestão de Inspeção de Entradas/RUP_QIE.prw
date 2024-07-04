#INCLUDE "PROTHEUS.CH"
#INCLUDE "PRTOPDEF.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  RUP_QIE( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
@author thiago.rover
@version P12
@since   28/03/2022
@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execucao. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada  Ex: 005 
@param  cLocaliz   - Localizacao (pais). Ex: BRA 
*/
//-------------------------------------------------------------------
Function RUP_QIE( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

	//cVersion  - Execucao apenas na release 12
	//cRelStart - Execucao do ajuste apartir da 12.1.2210
	//cMode     - Execucao por grupo de empresas
	If cVersion >= "12"
			QIEPicture(cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
		If cRelStart >= "2210" .And. cMode == "1"
			QIEAjuX3Ti(cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
		EndIf
	EndIf
Return

/*{Protheus.doc} QDOAjuX3Ti
Renomeia o titulo para 'Lote Fornec' e tambem o descritivo para 'Lote do Fornecedor' dos Campos QEK_DOCENT e QEP_DOCENT.
@author thiago.rover
@version P12
@since   28/03/2022
@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada  Ex: 005 
@param  cLocaliz   - Localizacao (pais). Ex: BRA 
*/
Static Function QIEAjuX3Ti(cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

	Local aSaveArea	as Array
	Local cUpdate   as Character  

	aSaveArea  := GetArea()

	cUpdate := " UPDATE " + RetSqlName("SX3")
	cUpdate += " SET  "
	cUpdate += " X3_TITULO =  'Lote Fornec', "
	cUpdate += " X3_TITSPA =  'Lote provee', "
	cUpdate += " X3_TITENG =  'Suppl. lot', "
    cUpdate += " X3_DESCRIC = 'Lote do Fornecedor',
	cUpdate += " X3_DESCSPA = 'Lote de Proveedor', 
	cUpdate += " X3_DESCENG = 'Supplier Lot'  
	cUpdate += " WHERE (D_E_L_E_T_ = ' ') "
	cUpdate +=   " AND (X3_CAMPO = 'QEK_DOCENT' or X3_CAMPO = 'QEP_DOCENT') "
	cUpdate +=   " AND (X3_TITULO <> 'Lote Fornec') "

	If TcSqlExec( cUpdate ) <> 0
		UserException( RetSqlName("SX3") + " "+ TCSqlError() )
	Endif

	RestArea(aSaveArea)
Return


/*/{Protheus.doc} QIEPicture
	Atualiza o picture da tabela QE8_TEXTO
	@type  Function
	@author celio.pereira
	@since 26/09/2022
	@version P12
	/*/

Static Function QIEPicture(cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
	Local aSaveArea	as Array
	Local cUpdate   as Character  

	aSaveArea  := GetArea()

	cUpdate := " UPDATE " + RetSqlName("SX3")
	cUpdate += " SET  "
	cUpdate += " X3_PICTURE =  '@!' "
	cUpdate += " WHERE (D_E_L_E_T_ = ' ') "
	cUpdate +=   " AND (X3_CAMPO = 'QE8_TEXTO') "

	If TcSqlExec( cUpdate ) <> 0
		UserException( RetSqlName("SX3") + " "+ TCSqlError() )
	Endif

	RestArea(aSaveArea)
Return
