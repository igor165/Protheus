#Include "protheus.ch"
#Include "DIRMEX.ch"

Static oTmpTable

/*�������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Programa   �TempDIRMex� Autor � Cleber Stenio           � Fecha �31/10/2008���
�����������������������������������������������������������������������������Ĵ��
���Descripcion� Funcao que monta e alimenta o arquivo de trabalho             ���  
�����������������������������������������������������������������������������Ĵ��
���Uso        � Nenhum                                                        ���
�����������������������������������������������������������������������������Ĵ��
���Parametros � dDataDe    - Data inicial a ser considerada para a operacao   ���
���           � dDataAte   - Data final   a ser considerada para a operacao   ���
���           � cForDe     - Fornecedor inicial                               ���
���           � cLojaDe    - Loja inicial                                     ���
���           � cForAte    - Fornecedor Final                                 ���
���           � cLojaAte   - Loja Final                                       ���
���           � cFilDe     - Filial Inicial                                   ���
���           � cFilAte    - Filial Final                                     ���
�����������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                 ���
�����������������������������������������������������������������������������Ĵ��
���Programador �Data    � BOPS     � Motivo da Alteracao                      ���
�����������������������������������������������������������������������������Ĵ��
��� ARodriguez �03/10/11�   ----   �Filtrar pagos sin IVA y sin impto retenido���
���Antonio Trej�28/06/13�   ----   �Llamado THEVGL se comento la linea 146    ���
���            �        �          �debido a reasignacion no imprimia los     ���
���            �        �          �datos de las Personas Morales.            ���
���  Marco A.  �03/01/17�SERINN001 �Se aplica CTREE para evitar la creacion   ���
���            �        �-534      �de tablas temporales de manera fisica     ���
���            �        �          �en system.                                ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function TempDIRMex(dDataDe, dDataAte, cForDe, cLojaDe, cForAte, cLojaAte, cFilDe, cFilAte)

	Local nX		:= 0
	Local nY		:= 0
	Local nI		:= 0
	Local nPosRI	:= 0
	Local nPosIR	:= 0
	Local aStr		:= {}
	Local aDetPag	:= {} //Detalhe das ordens de pagamento / titulos (funcao Marcello Gabriel)
	Local lNotOk	:= .F.
	Local aTMP		:= {}
	Local aOrdem	:= {}
	
	Private aTotRel		:= {}
	Private nOpRelMex	:= 0

	Default cForDe		:= ""
	Default cForAte		:= "zzzzzz"
	Default cLojaDe		:= ""
	Default cLojaAte	:= "zz"
	Default dDataDe		:= Ctod("01/01/" + StrZero(Year(dDataBase), 4), "DDMMYYYY")
	Default dDataAte	:= Ctod("31/12/" + StrZero(Year(dDataBase), 4), "DDMMYYYY")

	//���������������������������Ŀ
	//�Monto o TRB para impressao.�
	//�����������������������������
	aAdd(aStr, {"TRB_CGC"		, "C", 14, 0})
	aAdd(aStr, {"TRB_CURP"		, "C", 18, 0})
	aAdd(aStr, {"TRB_NOME"		, "C", 60, 0})
	aAdd(aStr, {"TRB_CLAVPG"	, "C", 02, 0})
	aAdd(aStr, {"TRB_MONISR"	, "N", 18, 0})
	aAdd(aStr, {"TRB_MONIVA"	, "N", 18, 0})
	aAdd(aStr, {"TRB_EXISR"		, "N", 18, 0})
	aAdd(aStr, {"TRB_EXIVA"		, "N", 18, 0})
	aAdd(aStr, {"TRB_RETISR"	, "N", 18, 0})
	aAdd(aStr, {"TRB_RETIVA"	, "N", 18, 0})
	
	aOrdem := {"TRB_CGC", "TRB_CURP", "TRB_CLAVPG"}
	
	oTmpTable := FWTemporaryTable():New("TRB")
	oTmpTable:SetFields(aStr)
	oTmpTable:AddIndex("IN1", aOrdem)
	
	oTmpTable:Create()

	aAdd(aTMP, {'oTmpTable', "TRB"})

	//Busca las informaciones sobre Ordens de pago / titulos
	aDetPag:= RETPGTOS(cForDe, cLojaDe, cForAte, cLojaAte, dDataDe, dDataAte, cFilDe, cFilAte)

	/*
	���������������������������������������������Ŀ
	�Estrutura do retorno do array aDetPag        �
	�1 - Fornecedor								  �
	�2 - Loja									  �
	�3 - RFC									  �
	�4 - CURP									  �
	�5 - Notas									  �
	�	5.01 - nota								  �
	�	5.02 - Serie							  �
	�	5.03 - valbrut (moeda 1)				  �
	�	5.04 - valmerc (moeda 1)				  �
	�	5.05 - moeda							  �
	�	5.06 - taxa moeda						  �
	�	5.07 - tipo pagamento (SF4->F4_CLAVPG)	  �
	�	5.08 - emissao							  �
	�	5.09 - especie							  �
	�	5.10 - valor pago (moeda 1)				  �
	�	5.11 - compensacao(moeda 1)				  �
	�	5.12 - impostos							  �
	�		5.12.1 - codigo do imposto			  �
	�		5.12.2 - aliquota					  �
	�		5.12.3 - base (moeda 1)				  �
	�		5.12.4 - valor (moeda 1)			  �
	�6 - Filial									  �
	�����������������������������������������������
	*/
	For nX := 1 to Len(aDetPag)

		SA2->(DbSetOrder(1))
		SA2->(DbSeek(Iif(!Empty(xFilial("SA2")), aDetPag[nX][6], xFilial("SA2")) + aDetPag[nX][1] + aDetPag[nX][2]))

		If  !Empty(SA2->A2_CURP) .Or. !Empty(SA2->A2_CGC)
			//�������������������������������������������������������Ŀ
			//�Alimento a tabela TRB - para o arquivo magnetico       �
			//���������������������������������������������������������
			For nI := 1 to Len(aDetPag[nX][5])
				lNotOk := .F.
				nPosRI := Ascan(aDetPag[nX][5][nI][12],{|imp| Substr(imp[1],1,2) == "RI" .Or. imp[1] == "REF"})
				nPosIR := Ascan(aDetPag[nX][5][nI][12],{|imp| Substr(imp[1],1,2) == "IR"})
				For nY := 1 to Len(aDetPag[nX][5][nI][12])
					//Se for IVA e exento ou IR = Iva Retido ou IRS Monto Tabela Temporaria
					If nPosRI <> 0 .Or. nPosIR <> 0
						//�������������������������������������������������������Ŀ
						//�Alimento a tabela TRB - para o arquivo magnetico       �
						//���������������������������������������������������������
						DbSelectArea("TRB")
						If !(TRB->(DbSeek(SA2->A2_CGC+SA2->A2_CURP+aDetPag[nX][5][nI][7])))
							lNotOk := .T.
							RecLock("TRB",.T.)
							If SA2->A2_TIPO == "F"
								TRB->TRB_NOME   := AllTrim(SA2->A2_NOMEPAT) +" "+ AllTrim(SA2->A2_NOMEMAT) +" "+ AllTrim(SA2->A2_NOMEPES)
							Else
								TRB->TRB_NOME   := AllTrim(SA2->A2_NOME)
							EndIf
							TRB->TRB_CGC    := SA2->A2_CGC
							TRB->TRB_CLAVPG := aDetPag[nX][5][nI][7]
							//TRB->TRB_NOME   := AllTrim(SA2->A2_NOMEPAT) +" "+ AllTrim(SA2->A2_NOMEMAT) +" "+ AllTrim(SA2->A2_NOMEPES)
							TRB->TRB_CURP   := SA2->A2_CURP
						Else
							RecLock("TRB",.F.)
						EndIf

						//Se for IVA e for exento gravo no campo Exento da tabela tempor�ria
						If Subs(aDetPag[nX][5][nI][12][nY][1],1,2)=="IV"
							nPropor := (aDetPag[nX][5][nI][10]/aDetPag[nX][5][nI][4])
							If aDetPag[nX][5][nI][12][nY][3] == 0 //base zerada - isento
								TRB->TRB_EXIVA += (aDetPag[nX][5][nI][12][nY][3]*nPropor)
							Else
								TRB->TRB_MONIVA += (aDetPag[nX][5][nI][12][nY][3]*nPropor)
							EndIf
							//Se for IVA Retenido
						Else
							If Subs(aDetPag[nX][5][nI][12][nY][1],1,2) == "RI" .Or. aDetPag[nX][5][nI][12][nY][1] == "REF"
								nPropor			:= (aDetPag[nX][5][nI][10] / aDetPag[nX][5][nI][4])
								TRB->TRB_RETIVA	+= (aDetPag[nX][5][nI][12][nY][4] * nPropor)
								//Gravando totais dos impostos por tipo de pagamento
								nPos := Ascan(aTotRel, {|X| X[1] == aDetPag[nX][5][nI][12][nY][1] .And. X[2] == aDetPag[nX][5][nI][7]})
								If nPos == 0
									Aadd(aTotRel, {aDetPag[nX][5][nI][12][nY][1], aDetPag[nX][5][nI][7], (aDetPag[nX][5][nI][12][nY][4] * nPropor), STR0021})//"Total de Iva Retenido y Enterado por "
								Else
									aTotRel[nPos][3] += (aDetPag[nX][5][nI][12][nY][4] * nPropor)
								EndIf
							Else
								//Se for ISR
								If Subs(aDetPag[nX][5][nI][12][nY][1],1,3) == "IRS"
									//Se for exento gravo no campo Exento da tabela tempor�ria
									If aDetPag[nX][5][nI][12][nY][2] == 0  .And. aDetPag[nX][5][nI][12][nY][3] == 0 //aliquota zerada e base zerada - isento
										nPropor			:= (aDetPag[nX][5][nI][10] / aDetPag[nX][5][nI][4])
										TRB->TRB_EXISR	+= (aDetPag[nX][5][nI][12][nY][3] * nPropor)
									Else
										nPropor			:= (aDetPag[nX][5][nI][10] / aDetPag[nX][5][nI][4])
										TRB->TRB_MONISR	+= (aDetPag[nX][5][nI][12][nY][3] * nPropor)
										TRB->TRB_RETISR	+= (aDetPag[nX][5][nI][12][nY][4] * nPropor)
										//Gravando totais dos impostos por tipo de pagamento
										nPos := Ascan(aTotRel, {|X| X[1] == aDetPag[nX][5][nI][12][nY][1] .And. X[2] == aDetPag[nX][5][nI][7]})
										If nPos == 0
											Aadd(aTotRel, {aDetPag[nX][5][nI][12][nY][1], aDetPag[nX][5][nI][7], (aDetPag[nX][5][nI][12][nY][4] * nPropor), STR0022})//"Total de Isr Retenido y Enterado por "
										Else
											aTotRel[nPos][3] += (aDetPag[nX][5][nI][12][nY][4] * nPropor)
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
						TRB->(MsUnLock())
					EndIf
				Next
				//Se encontrou algum imposto somo uma opera��o
				If lNotOk
					nOpRelMex++
				EndIf
			Next
		EndIF
	Next

	//Chamada Relat�rios
	DIRMEXRES()
	DIRMexVal()

Return (aTMP)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIRMEXRES�Autor  �Cleber Stenio       �Fecha � 31/10/2008   ���
�������������������������������������������������������������������������͹��
���Desc.     �Impresion del resumen de las informaciones da DIR           ���
�������������������������������������������������������������������������͹��
���Uso       � DIR - Mexico                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function DIRMEXRES()

	Local aArea		:= {}
	Local oReport	:= Nil

	If MsgYesNo(STR0002, STR0001)//"� Desea imprimir el resumen de las informaciones ?" "DIR"
		aArea := GetArea()
		oReport := TReport():New(STR0001, STR0003, , {|oReport| DIRIMPRES(oReport)}, STR0004) //"Resumen Global" "Resumen Global de Operaciones"
		oReport:SetPortrait()
		oReport:SetTotalInLine(.F.)
		oReport:Print(.F.)
		RestArea(aArea)
	EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIRIMPRES �Autor  �Cleber Stenio       �Fecha � 31/10/2008  ���
�������������������������������������������������������������������������͹��
���Desc.     �Impresion del resumen de las informaciones da DIR           ���
�������������������������������������������������������������������������͹��
���Uso       � DIR - Mexico                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function DIRIMPRES(oReport)
	
	Local aRect		:= {}
	Local oBrush	:= Nil
	Local oFont		:= Nil
	Local nX		:= 0
	Local cTipo		:= ""
	Local nTotIva	:= 0
	Local nTotIsr	:= 0

	oReport:SetTitle(STR0004 + "  -  " + Dtoc(_aTotal[1]) + " - " + Dtoc(_aTotal[2]))
	oDetalhe := TRSection():New(oReport, STR0004, )
	TRCell():New(oDetalhe, "DET_TXT", , "", , 100, .F.)
	TRCell():New(oDetalhe, "DET_VLR", , "", , 20 , .F.)
	
	oFont := TFont():New(oReport:cFontBody, , , , .T., , .T., , .F., , , , , , , )
	oBrush := TBrush():New( , RGB(0, 0, 0))
	oReport:SetMeter(11)
	oDetalhe:SetHeaderSection(.F.)
	oDetalhe:Init()
	oDetalhe:Cell("DET_TXT"):Hide()
	oDetalhe:Cell("DET_VLR"):Hide()
	oDetalhe:PrintLine()
	oReport:IncRow()
	oReport:IncRow()
	oDetalhe:Cell("DET_TXT"):Show()
	oDetalhe:Cell("DET_VLR"):Show()
	
	//Resumen de informaciones
	oReport:Say(oReport:Row(), oDetalhe:Cell("DET_TXT"):ColPos(), STR0005, oFont, 100)//"Descripcion"
	oReport:IncRow()
	oReport:IncRow()
	aRect := {oReport:Row(), oDetalhe:Cell("DET_TXT"):ColPos(), oReport:Row() + 2, oReport:PageWidth() - 2}
	oReport:FillRect(aRect, oBrush)
	oReport:IncRow()
	//N�mero de Operaciones que relaciona
	oDetalhe:Cell("DET_TXT"):SetValue(STR0006)//"N�mero de Operaciones que relaciona"
	oDetalhe:Cell("DET_VLR"):SetValue(Transform(nOpRelMex,"@E 9,999,999,999,999"))
	oDetalhe:PrintLine()
	oReport:IncRow()
	oReport:IncMeter()

	For nX := 1 to Len(aTotRel)
		//Descricao
		dbSelectArea("SX5")
		dbSetOrder(1)
		If dbSeek(xFilial("SX5") + PadR("ZH", Len(SX5->X5_TABELA)) + aTotRel[nX][2])
			cTipo := aTotRel[nX][4] + X5Descri()
		EndIf

		//Totais
		oDetalhe:Cell("DET_TXT"):SetValue(cTipo)
		oDetalhe:Cell("DET_VLR"):SetValue(Transform(aTotRel[nX][3], "@E 9,999,999,999,999"))
		oDetalhe:PrintLine()
		oReport:IncRow()
		oReport:IncMeter()

		If Subs(aTotRel[nX][1], 1, 2) $ "RI|REF"
			nTotIva += aTotRel[nX][3]
		Else
			nTotIsr += aTotRel[nX][3]
		EndIf
	Next

	//Total Iva
	oDetalhe:Cell("DET_TXT"):SetValue(STR0007)//"Total de Iva Retenido"
	oDetalhe:Cell("DET_VLR"):SetValue(Transform(nTotIva, "@E 9,999,999,999,999"))
	oDetalhe:PrintLine()
	oReport:IncRow()
	oReport:IncMeter()

	//Total Isr
	oDetalhe:Cell("DET_TXT"):SetValue(STR0008)//"Total de Isr Retenido"
	oDetalhe:Cell("DET_VLR"):SetValue(Transform(nTotIsr, "@E 9,999,999,999,999"))
	oDetalhe:PrintLine()
	oReport:IncRow()
	oReport:IncMeter()
	
	oReport:IncMeter()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIRMEXVAL �Autor  �Cleber Stenio       �Fecha � 31/10/2008  ���
�������������������������������������������������������������������������͹��
���Desc.     �Impresion del report para validacion de la generacion del   ���
���          �archivo para DIR                                            ���
�������������������������������������������������������������������������͹��
���Uso       � DIR - Mexico                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function DIRMexVal()

	Local aArea		:= {}
	Local oReport	:= Nil

	If MsgYesNo(STR0009,STR0001)//"� Desea imprimir el reporte para validaci�n de las informaciones ?" "DIR"
		aArea := GetArea()
		oReport := TReport():New(STR0001, STR0010, , {|oReport| DIRImpVal(oReport)}, STR0011) //"Reporte de validaci�n de las Informaciones" "Reporte para validaci�n de las informaciones generadas"
		oReport:SetLandscape()
		oReport:SetTotalInLine(.F.)
		oReport:PrintDialog()
		RestArea(aArea)
	EndIf
	
Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIRIMPVAL �Autor  �Cleber Stenio       �Fecha � 31/10/2008  ���
�������������������������������������������������������������������������͹��
���Desc.     �Impresion del report para validacion de la generacion del   ���
���          �archivo para DIR                                            ���
�������������������������������������������������������������������������͹��
���Uso       � DIR - Mexico                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function DIRImpVal(oReport)

	oReport:SetTitle(STR0012 + "  -  " + Dtoc(_aTotal[1]) + " - " + Dtoc(_aTotal[2])) //"Reporte de las informaciones generadas para DIR"
	oDetalhe := TRSection():New(oReport, STR0013, ) //"Informa��es da DIR"
	TRCell():New(oDetalhe, "DET_TIPO"			, , STR0014				, 						, 15, .F.)//"Tipo"
	TRCell():New(oDetalhe, "DET_RFC"			, , RetTitle("A1_CGC")	, 						, 25, .F.)
	TRCell():New(oDetalhe, "DET_CURP"			, , RetTitle("A1_CURP")	, 						, 35, .F.)
	TRCell():New(oDetalhe, "DET_RAZON"			, , RetTitle("A1_NOME")	, 						, 27, .F.)
	TRCell():New(oDetalhe, "DET_MESINI"			, , STR0015				, 						, 8 , .F.)//"Mes_Inicial"
	TRCell():New(oDetalhe, "DET_MESFIM"			, , STR0016				, 						, 8 , .F.)//"Mes_Final"
	TRCell():New(oDetalhe, "DET_OPERACION"		, , STR0017				, 						, 5 , .F.)//"Oper."
	TRCell():New(oDetalhe, "DET_MONTGRAVISR"	, , "ISR " + STR0018	, "@E 9,999,999,999,999", 18, .F.)//"gravada"
	TRCell():New(oDetalhe, "DET_MONTGRAVIVA"	, , "IVA " + STR0018	, "@E 9,999,999,999,999", 18, .F.)
	TRCell():New(oDetalhe, "DET_MONTEXEISR"		, , "ISR " + STR0019	, "@E 9,999,999,999,999", 18, .F.)//EXENTA
	TRCell():New(oDetalhe, "DET_MONTEXEIVA"		, , "IVA " + STR0019	, "@E 9,999,999,999,999", 18, .F.)
	TRCell():New(oDetalhe, "DET_RETISR"			, , "ISR " + STR0020	, "@E 9,999,999,999,999", 18, .F.)//retenido
	TRCell():New(oDetalhe, "DET_RETIVA"			, , "IVA " + STR0020	, "@E 9,999,999,999,999", 18, .F.)
	
	oReport:SetMeter(TRB->(RecCount()) + 1)
	oDetalhe:Init()
	//Informaciones
	TRB->(DbGoTop())
	While !oReport:Cancel() .And. !TRB->(Eof())
		oDetalhe:Cell("DET_TIPO"		):SetValue("1")
		oDetalhe:Cell("DET_RFC"			):SetValue(TRB->TRB_CGC)
		oDetalhe:Cell("DET_CURP"		):SetValue(TRB->TRB_CURP)
		oDetalhe:Cell("DET_RAZON"		):SetValue(TRB->TRB_NOME)
		oDetalhe:Cell("DET_MESINI"		):SetValue(StrZero(Month(_aTotal[1]), 2))
		oDetalhe:Cell("DET_MESFIM"		):SetValue(StrZero(Month(_aTotal[2]), 2))
		oDetalhe:Cell("DET_OPERACION"	):SetValue(TRB->TRB_CLAVPG)
		oDetalhe:Cell("DET_MONTGRAVISR"	):SetValue(TRB->TRB_MONISR)
		oDetalhe:Cell("DET_MONTGRAVIVA"	):SetValue(TRB->TRB_MONIVA)
		oDetalhe:Cell("DET_MONTEXEISR"	):SetValue(TRB->TRB_EXISR)
		oDetalhe:Cell("DET_MONTEXEIVA"	):SetValue(TRB->TRB_EXIVA)
		oDetalhe:Cell("DET_RETISR"		):SetValue(TRB->TRB_RETISR)
		oDetalhe:Cell("DET_RETIVA"		):SetValue(TRB->TRB_RETIVA)
		oReport:IncMeter()
		oDetalhe:PrintLine()
		TRB->(DbSkip())
	Enddo
	
	oReport:SkipLine()
	oReport:ThinLine()
	oReport:IncMeter()
	
Return

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �DIRDelMex   �Autor  �Cleber Stenio Alves � Data � 01.11.2008  ���
���������������������������������������������������������������������������͹��
���Desc.     �Deleta os arquivos temporarios processados                    ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       �DMESA                                                         ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function DIRDelMex(aDelArqs)

	Local aAreaDel	:= GetArea()
	Local nI		:= 0
	
	For nI := 1 To Len(aDelArqs)
		dbSelectArea(aDelArqs[nI, 2])
		dbCloseArea()
		&(aDelArqs[nI, 1]):Delete()
		&(aDelArqs[nI, 1]) := Nil
	Next

	RestArea(aAreaDel)
	
Return
