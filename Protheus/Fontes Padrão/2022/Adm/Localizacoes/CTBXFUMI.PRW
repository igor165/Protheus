#INCLUDE "PROTHEUS.CH"
#Include "TopConn.ch"

/*/{Protheus.doc} DtMoeAstMI
	Obtiene Fecha de conversión a mostrar en ventana de poliza
	@type  Function
	@author oscar.lopez
	@since 22/08/2022
	@version 1.0
	@param dFechaTx, fecha, Fecha a mostrar en campos CT2_DTTX** al cargar ventana de poliza
	@return lRet, logico, Verdadero/Falso si se debe actualizar la fecha
	@example
		DtMoeAstMI(@dFechaTx)
	/*/
Function DtMoeAstMI(dFechaTx)
	Local lRet		:= .F.
	Local aArea		:= GetArea()

	If FunName() $ "MATA101N"
		DbSelectArea("SF1")
		If SF1->(!EoF())
			dFechaTx := SF1->F1_EMISSAO
			lRet := .T.
		EndIf
	EndIf

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} DtMoeComMI
	Obtiene fecha de tasa para asiento complementario a partir de asiento origen en misma moneda.
	@type  Function
	@author oscar.lopez
	@since 22/08/2022
	@version 1.0
	@param cMoneda, caracter, Moneda del movimiento origen
	@param dFechaTx, fecha, Fecha de conversion de la moneda
	@param lActFch, logico, Verdadero/Falso si existe registro de asiento origen en moneda indicada
	@example
		DtMoeComMI(cMoneda, @dFechaTx, @lActFch)
	/*/
Function DtMoeComMI(cMoneda, dFechaTx, lActFch)
	Local aArea		:= GetArea()
	Local aAreaCT2	:= CT2->(GetArea())
	Local cChave	:= ""

	dFechaTx	:= CToD("  /  /  ")
	lActFch		:= .F.

	DbSelectArea("CT2")
	CT2->(DbSetOrder(1)) //CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC
	If CT2->(!EoF())
		cChave := CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI)+cMoneda
		If CT2->(MsSeek(cChave)) .And. !Empty(CT2_DATATX)
			dFechaTx	:= CT2->CT2_DATATX
			lActFch		:= .T.
		EndIf
	EndIf
	RestArea(aAreaCT2)
	RestArea(aArea)
Return Nil
