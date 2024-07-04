#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATR141.CH"
#INCLUDE "TopConn.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MATR141  �Autor  � FSW Argentina      � Data �  11/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Informe costeo de �tems de invoices de importacion          ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador �Data    � BOPS     � Motivo da Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���Jonathan Glz�06/07/15�PCREQ-4256�Se elimina la funcion AjustaSX1() que ���
���            �        �          �hace modificacion a SX1 por motivo de ���
���            �        �          �adecuacion a fuentes a nuevas estruc- ���
���            �        �          �turas SX para Version 12.             ���
���M.Camargo   �09.11.15�PCREQ-4262�Merge sistemico v12.1.8		          ���
���Jonathan Glz�19/12/16�SERINN001-�Se elimina ajuste a SX, por motivo de ���
���            �        �       510�limpieza de CTREE y SX.               ���
���LuisEnr�quez�30/05/18�DMINA-2906�Se modifica qry para generar reporte  ���
���            �        �          �para pa�s Colombia.                   ���
���Eduardo Prz �28/10/20�DMINA-9662�Se agregan bifurcaciones para pais PER���
���            �        �          �para que el reporte se genere correcta���
���            �        �          �mente usando la tasa del movimiento   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATR141()
Local oReport

oReport := ReportDef()
oReport:PrintDialog()

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportDef �Autor  � FSW Argentina      � Data �  11/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �RerpotDef del TReport                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()

Local oReport
Local oProces
Local cNomeRel  := "MATR141"
Local cTitulo	:= STR0001
Local cPerg		:= "MTR141"
Local aArea     := {}
Local cPicture  := "9,999,999,999,999.99"

Private dDateConv	:= CTOD(" / / ")

oReport := TReport():New(cNomeRel,cTitulo,cPerg,{|oReport| ReportPrint(oReport,oProces)},STR0002)
oReport:SetLandscape() 
oReport:SetTotalInLine(.F.)

Pergunte("MTR141",.F.)

oProces := TRSection():New(oReport,STR0003,{"DBA","SF1","SD1","SB1"},{STR0003})
oProces:SetTotalInLine(.F.)

TRCell():New(oProces,"DBA_HAWB"     ,,STR0003 ,PesqPict("DBA","DBA_HAWB")   ,TamSx3("DBA_HAWB")[1]  ,,{|| TRBPRC->DBA_HAWB   }) //"Proceso"
TRCell():New(oProces,"D1_COD"       ,,STR0005 ,PesqPict("SD1","D1_COD")     ,TamSx3("D1_COD")[1]    ,,{|| TRBPRC->D1_COD     }) //"Producto"
TRCell():New(oProces,"D1_UM"        ,,STR0006 ,PesqPict("SD1","D1_UM")      ,TamSx3("D1_UM")[1]     ,,{|| TRBPRC->D1_UM      }) //"Unidad"
TRCell():New(oProces,"D1_QUANT"     ,,STR0007 ,PesqPict("SD1","D1_QUANT")   ,TamSx3("D1_QUANT")[1]  ,,{|| TRBPRC->D1_QUANT   }) //"Cant."
TRCell():New(oProces,"D1_CUSTO"     ,,STR0008 ,cPicture                     ,TamSx3("D1_CUSTO")[1]  ,,{|| TRBPRC->CUSTOUN1   }) //"Costo Unit. Moneda 1"
TRCell():New(oProces,"D1_CUSTO1"    ,,STR0009 ,cPicture                     ,TamSx3("D1_CUSTO")[1]  ,,{|| TRBPRC->CUSTOT1    }) //"Costo Total Moneda 1"
TRCell():New(oProces,"B1_CUSTD"     ,,IIf(cPaisLoc$"COL|PER",STR0014,STR0010) ,cPicture   ,TamSx3("B1_CUSTD")[1]  ,,{|| TRBPRC->B1_CUSTD   }) //"Costo Est�ndar Unitario" "Costo promedio Unitario"
TRCell():New(oProces,"B1_CUSTD1"    ,,IIf(cPaisLoc$"COL|PER",STR0015,STR0011) ,cPicture   ,TamSx3("B1_CUSTD")[1]  ,,{|| TRBPRC->CUSTOSTDT  }) //"Costo Est�ndar Total" "Costo promedio Total"
Return(oReport)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �ReportPrint�Autor  � FSW Argentina      � Data �  11/02/11   ���
��������������������������������������������������������������������������͹��
���Desc.     �Impresion del Report                                         ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function ReportPrint(oReport,oProces)
	Local cQry     := ""
	Local cCust:= IIF(MV_PAR05==1,"D1_CUSTO","D1_CUSTO2")
	Local nTasa    := fGetTasa(dDatabase)
	Local nX       := 0	
	Local CostoEst := 0
	Local cCodPod  := ""
	Local lRet     := .T.
	Local aDatos := {}
	
	If Select("TRBPRC") > 0
		TRBPRC->(DbCloseArea())
	Endif

	If cPaisLoc $ "COL|PER"
		cQry := " SELECT DBA_HAWB, D1_COD, D1_UM, (D1_QUANT) AS D1_QUANT, B1_CUSTD, B1_MCUSTD, F1_TXMOEDA, " + CRLF
		//Costo Unitario
		If MV_PAR05 == 1 .And. MV_PAR06 == 1
			cQry += " Round(((D1_CUSTO+D1_DESPESA+D1_SEGURO+D1_VALFRE)),2) AS CUSTOT1 "
		ElseIf MV_PAR05 == 2 .And. MV_PAR06 == 1	
			cQry += " Round(((D1_CUSTO2+D1_DESPESA+D1_SEGURO+D1_VALFRE)),2) AS CUSTOT1 "	
		ElseIf MV_PAR05 == 2 .And. MV_PAR06 == 2
			cQry += " Round(((D1_CUSTO+D1_DESPESA+D1_SEGURO+D1_VALFRE)/" + Alltrim(Str(nTasa)) + "),2) AS CUSTOT1 "
		ElseIf MV_PAR05 == 1 .And. MV_PAR06 == 2
			cQry += " Round(((D1_CUSTO2+D1_DESPESA+D1_SEGURO+D1_VALFRE)*" + Alltrim(Str(nTasa)) + "),2) AS CUSTOT1 "		
		EndIf
	Else
		cQry := " SELECT DBA_HAWB, D1_COD, D1_UM, SUM(D1_QUANT) As D1_QUANT, 0 As CUSTOUN, 0 AS CUSTOT, " + CRLF
		cQry += " SUM(B1_CUSTD*D1_QUANT)/SUM(D1_QUANT) as B1_CUSTD, " + CRLF
		cQry += " SUM(B1_CUSTD*D1_QUANT) AS CUSTOSTDT, "	
		cQry += " Round(SUM(("+cCust+"+D1_DESPESA+D1_SEGURO+D1_VALFRE)*" + CvalToChar(IIf(MV_PAR06 == 1,"F1_TXMOEDA",RecMoeda(dDataBase,MV_PAR05))) + ")/SUM(D1_QUANT),2) AS CUSTOUN1, "
		cQry += " Round(SUM(("+cCust+"+D1_DESPESA+D1_SEGURO+D1_VALFRE)*" + CvalToChar(IIf(MV_PAR06 == 1,"F1_TXMOEDA",RecMoeda(dDataBase,MV_PAR05))) + "),2) AS CUSTOT1 "	
	EndIf
	cQry += " FROM " + RetSqlName("DBA") + " DBA " + CRLF
	cQry += " INNER JOIN " + RetSqlName("SF1") + " SF1 ON F1_FILIAL = '" + xFilial("SF1")+ "' AND F1_HAWB = DBA_HAWB AND SF1.D_E_L_E_T_ = '' " + CRLF
	cQry += " INNER JOIN " + RetSqlName("SD1") + " SD1 ON D1_FILIAL = '" + xFilial("SD1")+ "' AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND " + CRLF
	cQry += " D1_ESPECIE = F1_ESPECIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA AND SD1.D_E_L_E_T_ = '' " + CRLF
	cQry += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = D1_COD AND SB1.D_E_L_E_T_ = '' " + CRLF
	cQry += " WHERE " + CRLF
	cQry += " DBA_FILIAL = '" + xFilial("DBA") + "' AND " + CRLF
	cQry += " DBA_HAWB BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND " + CRLF
	cQry += " DBA_DT_ENC BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' AND " + CRLF

	cQry += " DBA_OK = '3' AND " + CRLF
	cQry += " DBA.D_E_L_E_T_ = '' " + CRLF
	If cPaisLoc $ "COL|PER"
		cQry += " ORDER BY DBA_HAWB, D1_COD, D1_UM, B1_CUSTD, B1_MCUSTD, F1_TXMOEDA "
	Else
		cQry += " GROUP BY DBA_HAWB, D1_COD, D1_UM  " + CRLF
		cQry += " ORDER BY DBA_HAWB, D1_COD, D1_UM "	
	EndIf

	cQry := ChangeQuery(cQry)
	TcQuery cQry New Alias "TRBPRC"
	
	If cPaisLoc $"COL|PER"	
		DbSelectArea("TRBPRC")
		DbGoTop()	
		
		While TRBPRC->(!EOF())
			CostoEst := 0
			If TRBPRC->D1_QUANT > 0
				If MV_PAR05 <> VAL(TRBPRC->B1_MCUSTD) 
					If (MV_PAR05 == 1 .And. TRBPRC->B1_MCUSTD == "2") .And. MV_PAR06 == 1 //Movimiento
						CostoEst := Round((TRBPRC->D1_QUANT * B1_CUSTD) *  TRBPRC->F1_TXMOEDA, 2)
					ElseIf (MV_PAR05 == 1 .And. TRBPRC->B1_MCUSTD == "2") .And. MV_PAR06 == 2 //D�a
						CostoEst := Round((TRBPRC->D1_QUANT * TRBPRC->B1_CUSTD) * nTasa, 2)
					ElseIf (MV_PAR05 == 2 .And. TRBPRC->B1_MCUSTD == "1") .And. MV_PAR06 == 1 //Movimiento
						CostoEst := Round((TRBPRC->D1_QUANT * B1_CUSTD) /  TRBPRC->F1_TXMOEDA, 2)
					ElseIf (MV_PAR05 == 2 .And. TRBPRC->B1_MCUSTD == "1") .And. MV_PAR06 == 2 //D�a
						CostoEst := Round((TRBPRC->D1_QUANT * B1_CUSTD) /  nTasa, 2)
					EndIf
				Else
					CostoEst := TRBPRC->D1_QUANT * TRBPRC->B1_CUSTD
				EndIf
			EndIf
		
			If cCodPod <> TRBPRC->D1_COD
				aAdd(aDatos,{TRBPRC->DBA_HAWB,; //"Proceso"
				             TRBPRC->D1_COD,  ; //"Producto"
				             TRBPRC->D1_UM,   ; //"Unidad"
				             TRBPRC->D1_QUANT,; //"Cant."
				             TRBPRC->CUSTOT1,  ; //"Costo Total Moneda 1"
				             CostoEst})         //"Costo Est�ndar Total"
				cCodPod := TRBPRC->D1_COD
			Else
				aDatos[Len(aDatos)][4] += TRBPRC->D1_QUANT //"Cant."
				aDatos[Len(aDatos)][5] += TRBPRC->CUSTOT1   //"Costo Total Moneda 1"
				aDatos[Len(aDatos)][6] += CostoEst         //"Costo Est�ndar Total"
			EndIf
			TRBPRC->(DbSkip())
		EndDo
		
		If Len(aDatos) > 0
			oReport:SetMeter(Len(aDatos))
			
			For nX:=1 To Len(aDatos)
				oReport:IncMeter(1)
			
				oProces:Init()
				
				oProces:Cell("DBA_HAWB"):SetValue(aDatos[nX][1])	            //"Proceso"
				oProces:Cell("D1_COD"):SetValue(aDatos[nX][2])	                //"Producto"
				oProces:Cell("D1_UM"):SetValue(aDatos[nX][3])	                //"Unidad"
				oProces:Cell("D1_QUANT"):SetValue(aDatos[nX][4])	            //"Cant."
				oProces:Cell("D1_CUSTO"):SetValue(aDatos[nX][5]/aDatos[nX][4])	//"Costo Unit. Moneda 1"
				oProces:Cell("D1_CUSTO1"):SetValue(aDatos[nX][5])	            //"Costo Total Moneda 1"
				oProces:Cell("B1_CUSTD"):SetValue(aDatos[nX][6]/aDatos[nX][4])	//"Costo Est�ndar Unitario"
				oProces:Cell("B1_CUSTD1"):SetValue(aDatos[nX][6])	            //"Costo Est�ndar Total"
		
				oProces:PrintLine()
			Next nX
		EndIf
	Else
		oReport:SetMeter(TRBPRC->(RecCount()))
		
		While TRBPRC->(!EOF())
		
			oReport:IncMeter(1)
		
			oProces:Init()
		
			oProces:PrintLine()
		
			TRBPRC->(DbSkip())
		EndDo	
	EndIf
Return

/*/{Protheus.doc} fGetTasa(dtTasa)
Obtiene la tasa para conversi�n a dada una fecha
@type function
@author Luis.Enr�quez
@since 28/05/2018
@version 1.0
@param dtTasa, Fecha en la que se bsucar� la tasa
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
