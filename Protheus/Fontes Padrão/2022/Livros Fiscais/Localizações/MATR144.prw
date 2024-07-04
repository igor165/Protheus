#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATR144.CH"
#INCLUDE "TOPCONN.CH"
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  � MATR144   �Autor  � FSW Argentina      � Data �  11/02/11   ���
��������������������������������������������������������������������������͹��
���Desc.     � Reporte Lista de embarques arribados detalle                ���
��������������������������������������������������������������������������͹��
���Uso       � Arimex                                 �Modulo � Facturacion���
��������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.              ���
��������������������������������������������������������������������������Ĵ��
���Programador �Data    �BOPS      �Motivo da Alteracao                    ���
��������������������������������������������������������������������������Ĵ��
���Jonathan Glz�6/07/15 �PCREQ-4256�Se elimina la funcion AjustaSX1() que  ���
���            �        �          �hace modificacion a SX1 por motivo de  ���
���            �        �          �adecuacion a fuentes a nuevas estruc-  ���
���            �        �          �turas SX para Version 12.              ���
���M.Camargo   �09.11.15�PCREQ-4262�Merge sistemico v12.1.8		           ���
���M.Camargo   �21/04/18�DMINA-2463�Se modifica picture de campos precio y ���
���            �        �          �valor total. Se realiza ajuste para que���
���            �        �          �se tome la tasa del d�a o de la fecha  ���
���            �        �          �del movimiento segun par�metro MV_PAR10���
���            �        �          �y se realice correctamente la conver-  ���
���            �        �          �si�n entre monedas.                    ���
���M.Camargo   �22/04/18�DMINA-2463�Se toma fecha del movimiento dbb_emissa���
���            �        �          �y tasa del campo dbb_txmoeda para tomar���
���            �        �          �correctamente la tasa de conversi�n    ���
���            �        �          �cuando mv_par09 = 1.                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function MATR144()
Local oReport

oReport := ReportDef()
oReport:PrintDialog()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   � ReportDef� Autor �                       � Data � 05/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descrip.  �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef
Local oReport
Local oSection1

Private cPerg  := "MTR144"
Private cTit	:= OemToAnsi(STR0001) // "Despachos (Anal�tico)"

//������������������������������������������������������������������������Ŀ
//�Creaci�n del componente de impresion                                    �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nombre del Informe                                              �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pregunta                                                        �
//�ExpB4 : Bloque de codigo que ser� ejecutado al confirmar la impresion   �
//�ExpC5 : Descripcion                                                     �
//��������������������������������������������������������������������������

oReport:= TReport():New('MATR144',OemToAnsi(STR0001),cPerg, ; // "Despachos (Anal�tico)"
                        {|oReport| ReportPrint(oReport)}, cTit)

oReport:SetLandScape()
oReport:SetTotalInLine(.F.)

Pergunte(cPerg,.F.)

oSection1 := TRSection():New(oReport," ")
oSection1:SetHeaderPage() //El titulo de la seccion se imprime al principio

TRCell():New(oSection1,'PROCESO'   	,,STR0002 , /*Picture */    				, TamSx3("DBB_HAWB")[1], /*lPixel */, /*{|| code-block de impressao } */ ) 	//"Proceso"
TRCell():New(oSection1,'INVOICE'   	,,STR0003 , /*Picture */    				, 12, /*lPixel */, /*{|| code-block de impressao } */ )						//"Invoice"
TRCell():New(oSection1,'ITEM'		,,STR0004 , /*Picture */    				,  4, /*lPixel */, /*{|| code-block de impressao } */ )						//"Item"
TRCell():New(oSection1,'PRODUCTO'  	,,STR0005 , /*Picture */    				, 15, /*lPixel */, /*{|| code-block de impressao } */ )						//"Producto"
TRCell():New(oSection1,'DESCRIPCION',,STR0006 , /*Picture */    				, 30, /*lPixel */, /*{|| code-block de impressao } */ )						//"Descripcion"
TRCell():New(oSection1,'UNIDAD'    	,,STR0007 , /*Picture */    				,  2, /*lPixel */, /*{|| code-block de impressao } */ )						//"Unidad"
TRCell():New(oSection1,'CANTIDAD'  	,,STR0008 ,"@E 999,999"     				, 12, /*lPixel */, /*{|| code-block de impressao } */ )						//"Cantidad"
TRCell():New(oSection1,'PRECIO'    	,,STR0009 ,"@E 999,999,999,999,999,999.99"	, 21, /*lPixel */, /*{|| code-block de impressao } */ )						//"Prc Unitario"
TRCell():New(oSection1,'TOTAL'     	,,STR0010 ,"@E 999,999,999,999,999,999.99"	, 21, /*lPixel */, /*{|| code-block de impressao } */ )						//"Val.Total"

Return( oReport )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   � ReportDef� Autor �                       � Data � 05/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descrip.  �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport)
Local cAliasTRB	:= GetNextAlias()
#IFDEF TOP
	Local oSection1  := oReport:Section(1)
	Local nTxMoeda   := 0
	Local nVlrUnit   := 0
	Local nVlrTot    := 0
	Local cQuery     := ""
	Local cAntProc   := ""
	Local nTasa      := fGetTasa(dDatabase)
	
	oReport:SetTitle(oReport:Title() + Iif(MV_PAR09 == 1,' - Pesos',' - Dolar'))
	
	//������������������������������������������������������������������������Ŀ
	//�Filtragem do relatorio                                                  �
	//��������������������������������������������������������������������������
	
	cQuery := "SELECT A.DBB_HAWB AS PROCESO,A.DBB_DOC AS INVOICE,A.DBB_TXMOED AS TXMOEDA, " + CRLF
	cQuery +=         "A.DBB_MOEDA AS MONEDA,A.DBB_EMISSA AS EMISSA,B.DBC_ITEM AS ITEM,B.DBC_ITDOC AS ITEN,B.DBC_CODPRO AS PRODUCTO, " + CRLF
	cQuery +=         "B.DBC_DESCRI AS DESCRIPCION, B.DBC_UM AS UNIDAD,B.DBC_QUANT AS CANTIDAD, " + CRLF
	cQuery +=         "B.DBC_PRECO AS PRECIO,B.DBC_TOTAL AS TOTAL, A.DBB_TIPONF TIPO, C.DBA_DTHAWB AS FECMOV " + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "    " + RetSqlName("DBB") + " A, " + RetSqlName("DBC") + " B, " + RetSqlName("DBA") + " C " + CRLF
	cQuery += "WHERE A.DBB_HAWB >= '"+MV_PAR01+"' AND " + CRLF
	cQuery +=       "A.DBB_HAWB <= '"+MV_PAR02+"' AND " + CRLF
	cQuery +=       "C.DBA_DTHAWB>='"+Dtos(MV_PAR03)+"' AND " + CRLF
	cQuery +=       "C.DBA_DTHAWB<='"+Dtos(MV_PAR04)+"' AND "	 + CRLF
	cQuery +=       "(C.DBA_DT_DTA=' ' OR (C.DBA_DT_DTA >= '"+Dtos(MV_PAR05)+"' AND C.DBA_DT_DTA <= '"+Dtos(MV_PAR06)+"' )) AND " + CRLF
	cQuery +=       "(C.DBA_DT_ENC=' ' OR (C.DBA_DT_ENC >= '"+Dtos(MV_PAR07)+"' AND C.DBA_DT_ENC <= '"+Dtos(MV_PAR08)+"' )) AND " + CRLF
	cQuery +=       "A.DBB_HAWB = C.DBA_HAWB AND " + CRLF
	cQuery +=       "A.DBB_HAWB = B.DBC_HAWB AND " + CRLF
	cQuery +=       "A.DBB_ITEM = B.DBC_ITDOC AND " + CRLF
	cQuery +=       "A.D_E_L_E_T_ <> '*' AND " + CRLF
	cQuery +=       "B.D_E_L_E_T_ <> '*' AND " + CRLF
	cQuery +=       "C.D_E_L_E_T_ <> '*' " + CRLF
	cQuery +=       "ORDER BY PROCESO, ITEN, TIPO, ITEM " + CRLF
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasTRB, .F., .T.)
	TCSetField(cAliasTRB,"EMISSA","D",8,0)
	TCSetField(cAliasTRB,"FECMOV","D",8,0)
	DbSelectArea(cAliasTRB)
	
	DbGoTop()
	oSection1:Init()
	oSection1:Cell("PROCESO"):SetBlock({|| allTrim((cAliasTRB)->PROCESO)} )
	oSection1:Cell("INVOICE"):SetBlock( {||  allTrim((cAliasTRB)->INVOICE)  }  )
	oSection1:Cell("ITEM"):SetBlock({|| allTrim((cAliasTRB)->ITEM) })
	oSection1:Cell("PRODUCTO"):SetBlock({||  allTrim((cAliasTRB)->PRODUCTO)})
	oSection1:Cell("DESCRIPCION"):SetBlock({|| allTrim((cAliasTRB)->DESCRIPCION) })
	oSection1:Cell("UNIDAD"):SetBlock({|| allTrim((cAliasTRB)->UNIDAD) })
	oSection1:Cell("CANTIDAD"):SetBlock({|| (cAliasTRB)->CANTIDAD })
	
	cAntProc:= allTrim((cAliasTRB)->PROCESO)
	
	(cAliasTRB)->(DbGoTop())
	While !oReport:Cancel() .And. !(cAliasTRB)->(Eof())
	
		oReport:IncMeter()
		If oReport:Cancel()
			Exit
		EndIf
	
		While !(cAliasTRB)->(EOF())
	
			If MV_PAR10 == 1     //Del Movimiento
				nTxMoeda := IIF((cAliasTRB)->TXMOEDA > 0,(cAliasTRB)->TXMOEDA,1)
			Else
				nTxMoeda := nTasa
			EndIf
	
			Do Case
				Case (MV_PAR09 == 1 .And. (cAliasTRB)->MONEDA == 1) .Or. (MV_PAR09 == 2 .And. (cAliasTRB)->MONEDA == 2)
					nVlrUnit := (cAliasTRB)->PRECIO
					nVlrTot  := (cAliasTRB)->TOTAL
				Case MV_PAR09 == 1 .And. (cAliasTRB)->MONEDA == 2
					nVlrUnit := ((cAliasTRB)->PRECIO * nTxMoeda)
					nVlrTot  := ((cAliasTRB)->TOTAL * nTxMoeda)
				Case MV_PAR09 == 2 .And. (cAliasTRB)->MONEDA == 1					
					nVlrUnit := ((cAliasTRB)->PRECIO / nTxMoeda)
					nVlrTot  := ((cAliasTRB)->TOTAL / nTxMoeda)
			EndCase
	
			oSection1:Cell("PRECIO"):SetBlock({|| nVlrUnit})
			oSection1:Cell("TOTAL"):SetBlock({|| nVlrTot})
	
			If allTrim((cAliasTRB)->PROCESO)<> cAntProc
				cAntProc:= allTrim((cAliasTRB)->PROCESO)
				oReport:SkipLine()
			EndIf
			oSection1:PrintLine()
			(cAliasTRB)->(dbSkip())
	
		EndDo
	
	EndDo
	
	oSection1:Finish()
	//Cierra tabla temporal
	DbSelectArea(cAliasTRB)
	(cAliasTRB)->(DbCloseArea())

#ELSE
	Aviso(STR0001,STR0011,{STR0012})//"Despachos (Anal�tico)" "Relat�rio dispon�vel apenas para ambiente TopConnect."  "Ok"
#ENDIF   

Return NIL
/*/{Protheus.doc} fGetTasa(dtTasa)
Obtiene la tasa para conversi�n a moneda 2 dada una fecha
@type function
@author mayra.camargo
@since 21/04/2018
@version 1.0
@param dtTasa, Date,Fecha en la que se bsucar� la tasa
/*/
Static Function fGetTasa(dtTasa)
	Local nRet := 1
	Default dtTasa := dDatabase
	dbSelectArea("SM2")
	SM2->(dbSetOrder(1)) // M2_DATA
	If SM2->(dbSeek(dtTasa))
		nRet := SM2->M2_MOEDA2
	EndIF
Return nRet 
