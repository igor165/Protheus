#Include "Protheus.ch"
#Include "MATR333.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATR333   � Autor � Marco A. Gonzalez  �Fecha �  06/05/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � Listado de Facturas de Venta NF/NDC/NCC + Impuesto (COL)   ���
�������������������������������������������������������������������������͹��
���Uso       � MATR333                                                    ���
�������������������������������������������������������������������������ĺ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������ĺ��
��� PROGRAMADOR� DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
�������������������������������������������������������������������������ĺ��
���Jonathan Glz�02/08/16�TVSOWI�Se realiza ajuste funcion MATR333SX1 para ���
���            �        �      �que cree 6 preguntas en total.            ���
���            �        �      �Cuando se selecciona una moneda diferente ���
���            �        �      �a la local se realiza la conversion de los���
���            �        �      �docuemntos de acuerdo la tasa de cambio.  ���
���Jonathan Glz�24/08/16�TVSOWI�Se agrega un autosize a las columnas, y se���
���            �        �      �soluciona problema con los totales que se ���
���            �        �      �repetian al final.                        ���
���Jonathan Glz�26/08/16�TVSOWI�Se elimina getArea a aAreaSM2, en al func.���
���            �        �      �MATR333Rep al momento de imprimir.        ���
���  Marco A.  �15/09/16�TWAUST�Replica del llamado TVSOWI. Cuando el     ���
���            �        �      �documento de compra fue emitido en dolares���
���            �        �      �el informe debe reflejar la equivalencia  ���
���            �        �      �de estos documentos en la moneda local    ���
���            �        �      �(pesos Colombianos) COL                   ���
���  Oscar G.  �23/02/21�DMINA-�Correcci�n de picture en ReportDef() para ���
���            �        � 10971�impresion opcion Planilla. (COL)          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function MATR333()

	Local oReport
	Private cPerg := "MATR333"

	//��������������������������Ŀ
	//�mv_par01 - De Fecha?      �
	//�mv_par02 - A Fecha?       �
	//�mv_par03 - De Sucursal?   �
	//�mv_par04 - A Sucursal?    �
	//�mv_par05 - Que Moneda?    �
	//�mv_par06 - Otras Monedas? �
	//����������������������������

	If TRepInUse()

		Pergunte(cPerg,.F.)

		oReport := ReportDef()
		oReport:PrintDialog()

	EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportDef � Autor � Marco A. Gonzalez  �Fecha �  06/05/16   ���
�������������������������������������������������������������������������͹��
���Descri��o � Definicion del Informe (COL)                               ���
�������������������������������������������������������������������������͹��
���Uso       � MATR333                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
	Local oReport
	Local oSection1
	Local oSection2
	Local cPicture := "@E 999,999,999,999,999,999.99"

		oReport := TReport():New("MATR333",STR0002,cPerg,{|oReport| MATR333Rep(oReport)},STR0003) //"LISTADO FACTURA VENTAS" - "Informe de Facturas de Venta"
			oReport:nFontBody := 5
			oReport:SetLandscape(.T.)

		//Secao 1 - Detalle
		oSection1 := TRSection():New(oReport,STR0004,,,,,,,,,,,,,,,,,,,) //"Listado de Facturas NF-NDC-NCC"
			oSection1:SetTotalInLine(.T.)
			oSection1:lHeaderVisible := .F.
			oSection1:SetHeaderPage(.F.)
			oSection1:SetHeaderBreak(.F.)

			TRCell():New( oSection1 ,"FILIAL"  , "" , ALLTRIM(STR0005) ,          , 10                         , .F. , /*bBlock*/ ,"LEFT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Sucursal "
			TRCell():New( oSection1 ,"EMISSAO" , "" , ALLTRIM(STR0006) ,          , 8                          , .F. , /*bBlock*/ ,"LEFT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Emision "
			TRCell():New( oSection1 ,"CLIENTE" , "" , ALLTRIM(STR0007) ,          , 12                         , .F. , /*bBlock*/ ,"LEFT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Cliente "
			TRCell():New( oSection1 ,"LOJA"    , "" , ALLTRIM(STR0008) ,          , 6                          , .F. , /*bBlock*/ ,"LEFT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Tienda "
			TRCell():New( oSection1 ,"NOME"    , "" , ALLTRIM(STR0009) ,          , 20                         , .F. , /*bBlock*/ ,"LEFT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Nombre "
			TRCell():New( oSection1 ,"ESPECIE" , "" , ALLTRIM(STR0010) ,          , 7                          , .F. , /*bBlock*/ ,"LEFT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Especie "
			TRCell():New( oSection1 ,"SERIE"   , "" , ALLTRIM(STR0011) ,          , 5                          , .F. , /*bBlock*/ ,"LEFT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Serie "
			TRCell():New( oSection1 ,"DOC"     , "" , ALLTRIM(STR0012) ,          , TamSx3("F2_DOC")[1]        , .F. , /*bBlock*/ ,"LEFT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Doc "
			TRCell():New( oSection1 ,"TXMOEDA" , "" , ALLTRIM(STR0025) , cPicture , TamSx3("F2_TXMOEDA")[1]    , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Tasa "
			TRCell():New( oSection1 ,"VALBRUT" , "" , ALLTRIM(STR0013) , cPicture , TamSx3("F2_VALBRUT")[1]+10 , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Val. Brut"
			TRCell():New( oSection1 ,"VALMERC" , "" , ALLTRIM(STR0014) , cPicture , TamSx3("F2_VALMERC")[1]+10 , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Val. Merc"
			TRCell():New( oSection1 ,"DESCONT" , "" , ALLTRIM(STR0015) , cPicture , TamSx3("F2_DESCONT")[1]+5  , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Descuento"
			TRCell():New( oSection1 ,"VALIMP1" , "" , ALLTRIM(STR0016) , cPicture , TamSx3("F2_VALIMP1")[1]+5  , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"IVA "
			TRCell():New( oSection1 ,"VALIMP2" , "" , ALLTRIM(STR0017) , cPicture , TamSx3("F2_VALIMP2")[1]+5  , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"RV0 "
			TRCell():New( oSection1 ,"VALIMP3" , "" , ALLTRIM(STR0018) , cPicture , TamSx3("F2_VALIMP3")[1]+5  , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"ICA "
			TRCell():New( oSection1 ,"VALIMP4" , "" , ALLTRIM(STR0019) , cPicture , TamSx3("F2_VALIMP4")[1]+5  , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"RF0 "
			TRCell():New( oSection1 ,"VALIMP6" , "" , ALLTRIM(STR0020) , cPicture , TamSx3("F2_VALIMP6")[1]+5  , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"IP8 "
			TRCell():New( oSection1 ,"VALIMP9" , "" , ALLTRIM(STR0021) , cPicture , TamSx3("F2_VALIMP9")[1]+5  , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"CREE "

		oSection2 := TRSection():New(oReport,STR0022,,,,,,,,,,,,,,,,,,,) //"Total"
			oSection2:SetTotalInLine(.T.)
			oSection2:lHeaderVisible := .F.
			oSection2:SetHeaderPage(.F.)
			oSection2:SetHeaderBreak(.F.)

			TRCell():New( oSection2 ,"FILIAL"  , "" , "" ,          , 16                         , .F. , /*bBlock*/ ,"LEFT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Sucursal "
			TRCell():New( oSection2 ,"EMISSAO" , "" , "" ,          , 2                          , .F. , /*bBlock*/ ,"LEFT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Emision "
			TRCell():New( oSection2 ,"CLIENTE" , "" , "" ,          , 12                         , .F. , /*bBlock*/ ,"LEFT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Cliente "
			TRCell():New( oSection2 ,"LOJA"    , "" , "" ,          , 6                          , .F. , /*bBlock*/ ,"LEFT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Tienda "
			TRCell():New( oSection2 ,"NOME"    , "" , "" ,          , 20                         , .F. , /*bBlock*/ ,"LEFT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Nombre "
			TRCell():New( oSection2 ,"ESPECIE" , "" , "" ,          , 7                          , .F. , /*bBlock*/ ,"LEFT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Especie "
			TRCell():New( oSection2 ,"SERIE"   , "" , "" ,          , 5                          , .F. , /*bBlock*/ ,"LEFT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Serie "
			TRCell():New( oSection2 ,"DOC"     , "" , "" ,          , TamSx3("F2_DOC")[1]        , .F. , /*bBlock*/ ,"LEFT"  ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Doc "
			TRCell():New( oSection2 ,"TXMOEDA" , "" , "" , cPicture , TamSx3("F2_TXMOEDA")[1]    , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Tasa "
			TRCell():New( oSection2 ,"VALBRUT" , "" , "" , cPicture , TamSx3("F2_VALBRUT")[1]+10 , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Val. Brut"
			TRCell():New( oSection2 ,"VALMERC" , "" , "" , cPicture , TamSx3("F2_VALMERC")[1]+10 , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Val. Merc"
			TRCell():New( oSection2 ,"DESCONT" , "" , "" , cPicture , TamSx3("F2_DESCONT")[1]+5  , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"Descuento"
			TRCell():New( oSection2 ,"VALIMP1" , "" , "" , cPicture , TamSx3("F2_VALIMP1")[1]+5  , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"IVA "
			TRCell():New( oSection2 ,"VALIMP2" , "" , "" , cPicture , TamSx3("F2_VALIMP2")[1]+5  , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"RV0 "
			TRCell():New( oSection2 ,"VALIMP3" , "" , "" , cPicture , TamSx3("F2_VALIMP3")[1]+5  , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"ICA "
			TRCell():New( oSection2 ,"VALIMP4" , "" , "" , cPicture , TamSx3("F2_VALIMP4")[1]+5  , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"RF0 "
			TRCell():New( oSection2 ,"VALIMP6" , "" , "" , cPicture , TamSx3("F2_VALIMP6")[1]+5  , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"IP8 "
			TRCell():New( oSection2 ,"VALIMP9" , "" , "" , cPicture , TamSx3("F2_VALIMP9")[1]+5  , .T. , /*bBlock*/ ,"RIGHT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //"CREE "

Return oReport

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATR333Rep� Autor � Marco A. Gonzalez  �Fecha �  06/05/16   ���
�������������������������������������������������������������������������͹��
���Descricao � Imprime el informe definido por el usuario de acuerdo con  ���
���          � las secc/celdas creadas en la funcion ReportDef() (COL)    ���
�������������������������������������������������������������������������͹��
���Uso       � MATR333                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MATR333Rep(oReport)
	
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local QRYSA3    := GetNextAlias()
	Local lRet      := .F.
	Local nTXMOEDA  := 0
	Local cFil      := ""
	Local cEspecie  := ""
	Local aTotEsp   := {0,0,0,0,0,0,0,0,0}
	Local aTotFil   := {0,0,0,0,0,0,0,0,0}
	Local aTotGrl   := {0,0,0,0,0,0,0,0,0}
	Local lConvert
	Local cFchIni
	Local cFchFin
	Local cFilIni
	Local cFilFin
	Local nMoneda
	Local nOtraMo

	Pergunte(cPerg,.F.)
	 cFchIni := Dtos(mv_par01)
	 cFchFin := Dtos(mv_par02)
	 cFilIni := mv_par03
	 cFilFin := mv_par04
	 nMoneda := mv_par05
	 nOtraMo := mv_par06

	#IFDEF TOP
		oSection1:BeginQuery()
			BeginSql alias QRYSA3
				SELECT F2_FILIAL FILIAL,F2_EMISSAO EMISSAO,F2_MOEDA MOEDA,F2_TXMOEDA TXMOEDA,F2_CLIENTE CLIENTE,F2_LOJA LOJA,A1_NOME NOME,F2_ESPECIE ESPECIE,F2_SERIE SERIE,F2_DOC DOC,F2_VALBRUT VALBRUT,F2_VALMERC VALMERC,F2_DESCONT DESCONT,F2_VALIMP1 VALIMP1,F2_VALIMP2 VALIMP2,F2_VALIMP3 VALIMP3,F2_VALIMP4 VALIMP4,F2_VALIMP6 VALIMP6,F2_VALIMP9 VALIMP9
				FROM (
				SELECT F2_FILIAL,F2_EMISSAO,F2_MOEDA,F2_TXMOEDA,F2_CLIENTE,F2_LOJA,A1_NOME,F2_ESPECIE,F2_SERIE,F2_DOC,F2_VALBRUT,F2_VALMERC,F2_DESCONT,F2_VALIMP1,F2_VALIMP2,F2_VALIMP3,F2_VALIMP4,F2_VALIMP6,F2_VALIMP9
				FROM %table:SF2% SF2
				LEFT OUTER JOIN %table:SA1% SA1
				ON  SA1.A1_COD = F2_CLIENTE AND SA1.A1_LOJA = F2_LOJA AND SA1.%notDel%
				WHERE F2_TIPODOC = '01'
				AND F2_EMISSAO BETWEEN %exp:cFchIni% AND %exp:cFchFin%
				AND F2_FILIAL BETWEEN %exp:cFilIni% AND %exp:cFilFin%
				AND SF2.%notDel%
				) TAB
				UNION

				SELECT F2_FILIAL FILIAL,F2_EMISSAO EMISSAO,F2_MOEDA MOEDA,F2_TXMOEDA TXMOEDA,F2_CLIENTE CLIENTE,F2_LOJA LOJA,A1_NOME NOME,F2_ESPECIE ESPECIE,F2_SERIE SERIE,F2_DOC DOC,F2_VALBRUT VALBRUT,F2_VALMERC VALMERC,F2_DESCONT DESCONT,F2_VALIMP1 VALIMP1,F2_VALIMP2 VALIMP2,F2_VALIMP3 VALIMP3,F2_VALIMP4 VALIMP4,F2_VALIMP6 VALIMP6,F2_VALIMP9 VALIMP9
				FROM (
				SELECT F2_FILIAL, F2_EMISSAO,F2_MOEDA,F2_TXMOEDA,F2_CLIENTE,F2_LOJA,A1_NOME,F2_ESPECIE,F2_SERIE,F2_DOC,F2_VALBRUT,F2_VALMERC,F2_DESCONT,F2_VALIMP1,F2_VALIMP2,F2_VALIMP3,F2_VALIMP4,F2_VALIMP6,F2_VALIMP9
				FROM %table:SF2% SF2
				LEFT OUTER JOIN %table:SA1% SA1
				ON  SA1.A1_COD = F2_CLIENTE AND SA1.A1_LOJA = F2_LOJA AND SA1.%notDel%
				WHERE F2_ESPECIE = 'NDC'
				AND F2_EMISSAO BETWEEN %exp:cFchIni% AND %exp:cFchFin%
				AND F2_FILIAL BETWEEN %exp:cFilIni% AND %exp:cFilFin%
				AND SF2.%notDel%
				) TAB
				UNION

				SELECT F1_FILIAL FILIAL,F1_EMISSAO EMISSAO,F1_MOEDA MOEDA,F1_TXMOEDA TXMOEDA,F1_FORNECE CLIENTE,F1_LOJA LOJA,A1_NOME NOME,F1_ESPECIE ESPECIE,F1_SERIE SERIE,F1_DOC DOC,F1_VALBRUT VALBRUT,F1_VALMERC VALMERC,F1_DESCONT DESCONT,F1_VALIMP1 VALIMP1,F1_VALIMP2 VALIMP2,F1_VALIMP3 VALIMP3,F1_VALIMP4 VALIMP4,F1_VALIMP6 VALIMP6,F1_VALIMP9 VALIMP9
				FROM (
				SELECT F1_FILIAL, F1_EMISSAO,F1_MOEDA, F1_TXMOEDA,F1_FORNECE,F1_LOJA,A1_NOME,F1_ESPECIE,F1_SERIE,F1_DOC,F1_VALBRUT,F1_VALMERC,F1_DESCONT,F1_VALIMP1,F1_VALIMP2,F1_VALIMP3,F1_VALIMP4,F1_VALIMP6,F1_VALIMP9
				FROM %table:SF1% SF1
				LEFT OUTER JOIN %table:SA1% SA1
				ON  SA1.A1_COD = F1_FORNECE AND SA1.A1_LOJA = F1_LOJA AND SA1.%notDel%
				WHERE F1_ESPECIE = 'NCC'
				AND F1_EMISSAO BETWEEN %exp:cFchIni% AND %exp:cFchFin%
				AND F1_FILIAL BETWEEN %exp:cFilIni% AND %exp:cFilFin%
				AND SF1.%notDel%
				)TAB
				ORDER BY FILIAL, ESPECIE, EMISSAO, SERIE, DOC
			EndSql
		oSection1:EndQuery()

		//Inicio da impressao do fluxo do relat�rio
		DbSelectArea(QRYSA3)
		(QRYSA3)->(dbGoTop())
		While !oReport:Cancel() .And. !(QRYSA3)->(Eof())

			cfil := (QRYSA3)->FILIAL
			While !oReport:Cancel() .And. !(QRYSA3)->(Eof()) .And. cfil == (QRYSA3)->FILIAL

				cEspecie := (QRYSA3)->ESPECIE
				While !oReport:Cancel() .And. !(QRYSA3)->(Eof()) .And. cfil == (QRYSA3)->FILIAL .And. cEspecie == (QRYSA3)->ESPECIE
					//solo imprime documentos en la moneda seleccionada
					if nOtraMo == 2 .AND. (QRYSA3)->MOEDA <> nMoneda
						(QRYSA3)->(dbSkip())
						lRet := .T.
						lConvert := .F.
					elseif nOtraMo == 2 .AND. (QRYSA3)->MOEDA == nMoneda
						lRet := .F.
						lConvert := .F.
					//Cuando cuando el documento es igual a la moneda seleccionada no se realiza conversion.
					elseif nOtraMo == 1  .AND.  (QRYSA3)->MOEDA == nMoneda
						lRet := .F.
						lConvert := .F.
					elseif nOtraMo == 1  .AND. (ALLTRIM(STR((QRYSA3)->MOEDA)) $ '|1|2|3|4|5|' .AND. (QRYSA3)->MOEDA <> nMoneda)
						if nMoneda == 1
							if !EMPTY((QRYSA3)->TXMOEDA)
								nTXMOEDA := (QRYSA3)->TXMOEDA
							else
								DbSelectArea("SM2")
								SM2->(DbSetOrder(1))
								If SM2->(DbSeek((QRYSA3)->EMISSAO))
									nTXMOEDA := &("M2_MOEDA" + ALLTRIM( STR( (QRYSA3)->MOEDA ) ) )
								EndIf
							endif
						else
							DbSelectArea("SM2")
							SM2->(DbSetOrder(1))
							If SM2->(DbSeek((QRYSA3)->EMISSAO))
								nTXMOEDA := &("M2_MOEDA" + ALLTRIM( STR( nMoneda ) ) )
							EndIf
						endif
						lConvert := .T.
					endif

					if lConvert
						oSection1:Init()
							oSection1:Cell("TXMOEDA"):SetValue( nTXMOEDA )
							oSection1:Cell("VALBRUT"):SetValue( IIF( nMoneda <> 1 , (QRYSA3)->VALBRUT / nTXMOEDA , (QRYSA3)->VALBRUT * nTXMOEDA ) )
							oSection1:Cell("VALMERC"):SetValue( IIF( nMoneda <> 1 , (QRYSA3)->VALMERC / nTXMOEDA , (QRYSA3)->VALMERC * nTXMOEDA ) )
							oSection1:Cell("DESCONT"):SetValue( IIF( nMoneda <> 1 , (QRYSA3)->DESCONT / nTXMOEDA , (QRYSA3)->DESCONT * nTXMOEDA ) )
							oSection1:Cell("VALIMP1"):SetValue( IIF( nMoneda <> 1 , (QRYSA3)->VALIMP1 / nTXMOEDA , (QRYSA3)->VALIMP1 * nTXMOEDA ) )
							oSection1:Cell("VALIMP2"):SetValue( IIF( nMoneda <> 1 , (QRYSA3)->VALIMP2 / nTXMOEDA , (QRYSA3)->VALIMP2 * nTXMOEDA ) )
							oSection1:Cell("VALIMP3"):SetValue( IIF( nMoneda <> 1 , (QRYSA3)->VALIMP3 / nTXMOEDA , (QRYSA3)->VALIMP3 * nTXMOEDA ) )
							oSection1:Cell("VALIMP4"):SetValue( IIF( nMoneda <> 1 , (QRYSA3)->VALIMP4 / nTXMOEDA , (QRYSA3)->VALIMP4 * nTXMOEDA ) )
							oSection1:Cell("VALIMP6"):SetValue( IIF( nMoneda <> 1 , (QRYSA3)->VALIMP6 / nTXMOEDA , (QRYSA3)->VALIMP6 * nTXMOEDA ) )
							oSection1:Cell("VALIMP9"):SetValue( IIF( nMoneda <> 1 , (QRYSA3)->VALIMP9 / nTXMOEDA , (QRYSA3)->VALIMP9 * nTXMOEDA ) )
						oSection1:PrintLine()
						(QRYSA3)->(dbSkip())
					else
						if !lRet
							oSection1:Init()
								oSection1:Cell("TXMOEDA"):SetValue( (QRYSA3)->TXMOEDA )
								oSection1:Cell("VALBRUT"):SetValue( (QRYSA3)->VALBRUT )
								oSection1:Cell("VALMERC"):SetValue( (QRYSA3)->VALMERC )
								oSection1:Cell("DESCONT"):SetValue( (QRYSA3)->DESCONT )
								oSection1:Cell("VALIMP1"):SetValue( (QRYSA3)->VALIMP1 )
								oSection1:Cell("VALIMP2"):SetValue( (QRYSA3)->VALIMP2 )
								oSection1:Cell("VALIMP3"):SetValue( (QRYSA3)->VALIMP3 )
								oSection1:Cell("VALIMP4"):SetValue( (QRYSA3)->VALIMP4 )
								oSection1:Cell("VALIMP6"):SetValue( (QRYSA3)->VALIMP6 )
								oSection1:Cell("VALIMP9"):SetValue( (QRYSA3)->VALIMP9 )
							oSection1:PrintLine()
							(QRYSA3)->(dbSkip())
						endif
					endif

					if !lRet .OR. lConvert
						aTotEsp[1] += oSection1:Cell("VALBRUT"):GetValue()
						aTotEsp[2] += oSection1:Cell("VALMERC"):GetValue()
						aTotEsp[3] += oSection1:Cell("DESCONT"):GetValue()
						aTotEsp[4] += oSection1:Cell("VALIMP1"):GetValue()
						aTotEsp[5] += oSection1:Cell("VALIMP2"):GetValue()
						aTotEsp[6] += oSection1:Cell("VALIMP3"):GetValue()
						aTotEsp[7] += oSection1:Cell("VALIMP4"):GetValue()
						aTotEsp[8] += oSection1:Cell("VALIMP6"):GetValue()
						aTotEsp[9] += oSection1:Cell("VALIMP9"):GetValue()
					endif

				EndDo

				aTotFil[1] += aTotEsp[1]
				aTotFil[2] += aTotEsp[2]
				aTotFil[3] += aTotEsp[3]
				aTotFil[4] += aTotEsp[4]
				aTotFil[5] += aTotEsp[5]
				aTotFil[6] += aTotEsp[6]
				aTotFil[7] += aTotEsp[7]
				aTotFil[8] += aTotEsp[8]
				aTotFil[9] += aTotEsp[9]

				oSection2:Init()
					oSection2:Cell("FILIAL" ):SetValue( UPPER(STR0023) )
					oSection2:Cell("VALBRUT"):SetValue( aTotEsp[1] )
					oSection2:Cell("VALMERC"):SetValue( aTotEsp[2] )
					oSection2:Cell("DESCONT"):SetValue( aTotEsp[3] )
					oSection2:Cell("VALIMP1"):SetValue( aTotEsp[4] )
					oSection2:Cell("VALIMP2"):SetValue( aTotEsp[5] )
					oSection2:Cell("VALIMP3"):SetValue( aTotEsp[6] )
					oSection2:Cell("VALIMP4"):SetValue( aTotEsp[7] )
					oSection2:Cell("VALIMP6"):SetValue( aTotEsp[8] )
					oSection2:Cell("VALIMP9"):SetValue( aTotEsp[9] )
				oSection2:PrintLine()
				oSection2:Finish()
				oReport:SkipLine(1)

				aTotEsp   := {0,0,0,0,0,0,0,0,0}
			EndDo

			aTotGrl[1] += aTotFil[1]
			aTotGrl[2] += aTotFil[2]
			aTotGrl[3] += aTotFil[3]
			aTotGrl[4] += aTotFil[4]
			aTotGrl[5] += aTotFil[5]
			aTotGrl[6] += aTotFil[6]
			aTotGrl[7] += aTotFil[7]
			aTotGrl[8] += aTotFil[8]
			aTotGrl[9] += aTotFil[9]

			oSection2:Init()
				oSection2:Cell("FILIAL" ):SetValue( UPPER(STR0024) )
				oSection2:Cell("VALBRUT"):SetValue( aTotFil[1] )
				oSection2:Cell("VALMERC"):SetValue( aTotFil[2] )
				oSection2:Cell("DESCONT"):SetValue( aTotFil[3] )
				oSection2:Cell("VALIMP1"):SetValue( aTotFil[4] )
				oSection2:Cell("VALIMP2"):SetValue( aTotFil[5] )
				oSection2:Cell("VALIMP3"):SetValue( aTotFil[6] )
				oSection2:Cell("VALIMP4"):SetValue( aTotFil[7] )
				oSection2:Cell("VALIMP6"):SetValue( aTotFil[8] )
				oSection2:Cell("VALIMP9"):SetValue( aTotFil[9] )
			oSection2:PrintLine()
			oSection2:Finish()
			oReport:SkipLine(1)

			aTotFil   := {0,0,0,0,0,0,0,0,0}

		EndDo

		oSection2:Init()
			oSection2:Cell("FILIAL" ):SetValue( UPPER( STR0022 + " " + STR0026 ) )
			oSection2:Cell("VALBRUT"):SetValue( aTotGrl[1] )
			oSection2:Cell("VALMERC"):SetValue( aTotGrl[2] )
			oSection2:Cell("DESCONT"):SetValue( aTotGrl[3] )
			oSection2:Cell("VALIMP1"):SetValue( aTotGrl[4] )
			oSection2:Cell("VALIMP2"):SetValue( aTotGrl[5] )
			oSection2:Cell("VALIMP3"):SetValue( aTotGrl[6] )
			oSection2:Cell("VALIMP4"):SetValue( aTotGrl[7] )
			oSection2:Cell("VALIMP6"):SetValue( aTotGrl[8] )
			oSection2:Cell("VALIMP9"):SetValue( aTotGrl[9] )
		oSection2:PrintLine()
		oSection2:Finish()

		aTotGrl   := {0,0,0,0,0,0,0,0,0}

		oSection1:Finish()
		(QRYSA3)->(dbCloseArea())
	#ENDIF
Return
