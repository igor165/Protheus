////////////////
// Versao 001 //
////////////////
#include "protheus.ch"

Function VEICLSAO()
Return()

/*/{Protheus.doc} DMS_Oficina
	Classe com dados pertinentes a oficina

	@type class
	@author Rubens
	@since 02/05/2014
/*/
Class DMS_Oficina
	Data nHorasDispo AS Numeric 
	Data aProdutivos AS Array Init Array(0) // Array de Objetos do tipo Produtivo
	Data aPeriodo    AS Array Init Array(0) // Array de Periodos ...
	
	Method New() Constructor
	Method GetProdutivos()
	Method FindProdutivo()
	Method LoadProdutivo()
	Method LoadEscala()
	Method GetHoras()
	Method TipoTempoBloqueado()
EndClass

/*/{Protheus.doc} New
	Construtor simples DMS_Oficina
	@author       Rubens Takahashi
	@since        02/05/2014
	@version      1.0
/*/
Method New() Class DMS_Oficina
//	Self:SetFilial(cFilAnt)
	Self:aProdutivos := {}
Return Self

//Method SetFilial(pcFilial) Class DMS_Oficina
//	Self:cFilialCons := pcFilial
//Return 

//Method GetFilial() Class DMS_Oficina
//Return Self:cFilialCons

Method GetProdutivos() Class DMS_Oficina
Return Self:aProdutivos

Method FindProdutivo(pCodigo) Class DMS_Oficina
	Local oRetorno
	If aScan( Self:aProdutivos , { |x| x:cCodigo == pCodigo } ) > 0
		oRetorno := Self:aProdutivos[ aScan( Self:aProdutivos , { |x| x:cCodigo == pCodigo } ) ]
	Else
		AADD( Self:aProdutivos , DMS_Produtivo():New( pCodigo ) )
 		oRetorno := Self:aProdutivos[ Len(Self:aProdutivos) ]
	EndIf

Return oRetorno

/*/{Protheus.doc} LoadProdutivo
Carrega produtivos com escala da filial a ser processada
@author Rubens
@since 06/06/2018
@version 1.0
@param pdDataIni, data, Data inicial para processamento
@param pdDataFim, data, Data final para processamento
@type function
/*/
Method LoadProdutivo(pdDataIni, pdDataFim) Class DMS_Oficina
	Local cSQL
	Local TPROD := "TPROD"

	Local lVOEFILPRO := VOE->(FieldPos("VOE_FILPRO")) <> 0

	Default pdDataIni := CtoD(" ")
	Default pdDataFim := CtoD(" ")

	Self:aProdutivos := {}
	
	cSQL := "SELECT VAI.VAI_CODTEC "
	cSQL +=  " FROM " + RetSQLName("VAI") + " VAI "
	cSQL += " WHERE VAI.VAI_FILIAL = '" + xFilial("VAI") + "'"
	cSQL +=   " AND VAI.VAI_FILPRO = '" + cFilAnt + "'"
	cSQL +=   " AND VAI.VAI_FUNPRO = '1'" // Somente produtivos
	cSQL +=   " AND VAI.D_E_L_E_T_ = ' '"
	If lVOEFILPRO .and. !Empty(pdDataIni)
		cSQL += " UNION " +;
			"SELECT DISTINCT ESCALA.VOE_CODPRO " +;
			 " FROM ( SELECT VOE.VOE_CODPRO, VOE.VOE_FILPRO, VOE.VOE_DATESC " +;
			 			 " FROM " + RetSQLName("VOE") + " VOE " +;
								  " JOIN ( SELECT VOE.VOE_CODPRO, MAX(VOE.VOE_DATESC) ESCALA "  +;
											  " FROM " + RetSQLName("VOE") + " VOE " +;
											 " WHERE VOE.VOE_FILIAL = '" + xFilial("VOE") + "'" +;
											   " AND VOE.VOE_DATESC < '" + DtoS(pdDataIni) + "'" +;
												" AND VOE.D_E_L_E_T_ = ' '" +;
											 " GROUP BY VOE.VOE_CODPRO ) TEMP ON VOE.VOE_FILIAL = '" + xFilial("VOE") + "' " +;
											 										 " AND VOE.VOE_CODPRO = TEMP.VOE_CODPRO " +;
																					 " AND VOE.VOE_DATESC = TEMP.ESCALA " +;
																					 " AND VOE.D_E_L_E_T_ = ' ' " +;
						 " UNION ALL " +;
						 " SELECT VOE2.VOE_CODPRO, VOE2.VOE_FILPRO, VOE2.VOE_DATESC " +;
							" FROM " + RetSQLName("VOE") + " VOE2 " +;
						 " WHERE VOE2.VOE_FILIAL = '" + xFilial("VOE") + "' " +;
						 	" AND VOE2.VOE_DATESC BETWEEN '" + DtoS(pdDataIni) + "' AND '" + DtoS(pdDataFim) + "' " +;
							" AND VOE2.D_E_L_E_T_ = ' ' " +;
						" ) ESCALA " +;
			 " WHERE ESCALA.VOE_FILPRO = '" + cFilAnt + "' "
	EndIf
	cSQL +=  "ORDER BY 1"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), TPROD , .F., .T. )
	While !(TPROD)->(Eof())
		AADD( Self:aProdutivos , DMS_Produtivo():New( (TPROD)->VAI_CODTEC ) )
		(TPROD)->(dbSkip())
	End
	(TPROD)->(dbCloseArea())


Return

/*/{Protheus.doc} LoadEscala
	Carrega uma escala dado um periodo
	
	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
	@param pdDataIni, data, Data inicio
	@param pdDataFim, data, Data fim
/*/
Method LoadEscala(pdDataIni,pdDataFim) Class DMS_Oficina
	Local nPos
	Self:nHorasDispo := 0
	For nPos := 1 to Len(Self:aProdutivos)
		If nPos > 1
			Self:aProdutivos[nPos]:aPeriodo := Self:aPeriodo
		EndIf
		Self:aProdutivos[nPos]:LoadEscala(pdDataIni,pdDataFim)
		Self:nHorasDispo += Self:aProdutivos[nPos]:nHorasDispo
		If nPos == 1
			Self:aPeriodo := aClone(Self:aProdutivos[1]:aPeriodo)
		EndIf
	Next nPos
Return

/*/{Protheus.doc} GetHoras
	Retorna as horas disponiveis para a Oficina
	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
	@param pdDataIni, data, Data inicio
	@param pdDataFim, data, Data fim
/*/
Method GetHoras(pdDataIni,pdDataFim) Class DMS_Oficina
	If Self:GetProdutivo() == NIL .or. Len(Self:GetProdutivo()) == 0
		Self:LoadProdutivo(pdDataIni,pdDataFim)
	EndIf
	Self:LoadEscala(pdDataIni,pdDataFim)
Return Self:nHorasDispo

/*/{Protheus.doc} TipoTempoBloqueado
	Retorna se o Tipo de Tempo esta bloqueado (VOI_MSBLQL)
	@type method
	@author Andre Luis Almeida
	@since 13/08/2019
	@version 1.0
	@param cTpTempo, string, Tipo de Tempo
	@param lMsgHlp, logico, Mostra Mensagem de Help ?
/*/
Method TipoTempoBloqueado(cTpTempo,lMsgHlp) Class DMS_Oficina
Local cMensagem  := ""
Default lMsgHlp  := .t.
VOI->(DbSetOrder(1))
If !VOI->(MsSeek(xFilial("VOI")+cTpTempo))
	If lMsgHlp
		cMensagem := chr(13) + chr(10) + chr(13) + chr(10)
		cMensagem += "VOI - " + RetTitle("VOI_TIPTEM")  + ": " + cTpTempo
		Help(" ",1,"REGNOIS",,cMensagem,3,1)
	EndIf
	Return .t. // Tipo de Tempo NAO ENCONTRADO NO VOI - TEM PROBLEMA
EndIf
If VOI->(FieldPos("VOI_MSBLQL")) > 0 .and. VOI->VOI_MSBLQL=="1" // Registro Bloqueado VOI
	If lMsgHlp
		cMensagem := chr(13) + chr(10) + chr(13) + chr(10)
		cMensagem += "VOI - " + RetTitle("VOI_TIPTEM")  + ": " + cTpTempo
		HELP(" ",1,"REGBLOQ",,cMensagem,3,1)
	EndIf
	Return .t. // Tipo de Tempo BLOQUEADO - TEM PROBLEMA
EndIf
Return .f. // Tipo de Tempo NAO BLOQUEADO - NAO TEM PROBLEMA