#Include "PROTHEUS.CH"
#Include "RPTDEF.CH"
#Include "TBICONN.CH"
#INCLUDE "report.ch"
#Include "GPER029CHI.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n   �GPER029CHI� Autor � alfredo.medrano     � Data � 19/09/2014 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Comparativo de Nomina (Chile)                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER029CHI()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generar un comparativo por concepto entre el periodo actual���
���          � y un periodo de n�mina ya efectuado y cerrado.             ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador   � Data   � BOPS/FNC  �  Motivo da Alteracao              ���
�������������������������������������������������������������������������Ĵ��
���Jonathan G.   �18/03/15�    TRXEFB �Se cambia laformula para el calculo���
���              �        �           �del % Variacion y la diferencia,   ���
���              �        �           �aplica para teportes tipo sintetico���
���              �        �           �y analitico. Se agrega la seccion  ���
���              �        �           �de totales por cocepto para los    ���
���              �        �           �reportes analiticos.               ���
���Jonathan Glez �30/11/15�PCREQ-7944 �Localizacion GPE CHI p/v12         ���
���              �        �           �-Se agrega la funcion gpr029ValP la���
���              �        �           �cual valida que se seleccione un   ���
���              �        �           �periodo arbierto o Cerrado en el   ���
���              �        �           �grupo de preguntas                 ���
���              �03.05.21�           �cOMENTARIO PARA CHECK IN 12.1.27   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function GPER029CHI()
Local		oReport
Local		aArea 		:= GetArea()
Private 	cTitulo	:= OemToAnsi(STR0001)
Private 	aOrdem    := {}
Private 	cPerg   	:= "GPER029CHI"
Aadd(aOrdem, STR0027)  // POR CENTRO DE COSTOS
Aadd(aOrdem, STR0024)  // POR PECESO

If FindFunction("TRepInUse") .And. TRepInUse()
	//������������������������������������������Ŀ
	//� Verifica las perguntas selecionadas      �
	//� Proceso?                      MV_PAR01   �
	//� Tipo de Nomina?               MV_PAR02   �
	//� Periodo Actual?               MV_PAR03   �
	//� No de Pago Actual?            MV_PAR04   �
	//� Periodo a Comparar?           MV_PAR05   �
	//� No Pago a Comparar?           MV_PAR06   �
	//� Tipo de Informe?              MV_PAR07   �
	//� Centro de Costos?             MV_PAR08   �
	//� Conceptos a Listar?           MV_PAR09   �
	//� Cont. Conceptos a Listar?     MV_PAR10   �
	//� Todos los Conceptos?          MV_PAR11   �
	//��������������������������������������������
	 pergunte(cPerg,.F.)
    oReport := ReportDef()
    oReport:PrintDialog()
EndIF

RestArea( aArea )

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ReportDef � Autor � Alfredo Medrano       � Data �22/09/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao � Crea la estructura del reporte y sus secciones.            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oReport                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �GPER029CHI                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oSection4
Local oSection5
Local cTipo     := ""

//������������������������������������������������������������������������Ŀ
//�Crea componente de impresi�n                                            �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
	oReport:= TReport():New("GPER029CHI",cTitulo ,cPerg, {|oReport| ReportPrint(oReport)},"")  //"REPORTE COMPARATIVO DE PERIODOS"
	oReport:SetLandscape()
	oReport:ShowHeader()			//imprimir el encabezado del informe (por default)
	oReport:SetTotalInLine(.F.) //True = imprime totalizadores
	oReport:nFontBody		:= 6 	//Tama�o fuente del documento
	oReport:nLineHeight	:= 25 	//Altura de linea
	oReport:nColSpace		:= 5 	//Espacio entre las columnas de informaci�n
	oReport:cFontBody		:= "COURIER NEW" // tipo de letra

//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//� Seccion 1  (oSection1) Encabezado con los datos del Filtro             �
//�          --> Proceso, Tipo Nomina,Periodo Anterior y Periodo Actual    �
//��������������������������������������������������������������������������
	oSection1 :=TRSection():New(oReport,OemToAnsi(STR0020),"",aOrdem) //Encabezado Proceso
	oSection1 :SetHeaderPage()
	oSection1 :SetLineBreak(.f.) //.T. imprime una o mas lineas - .F.= no imprime linea
	oSection1 :SetHeaderSection(.T.) 	//Define si imprime encabezado de las celdas cada de que cambia de secci�n
	oSection1 :SetHeaderBreak(.F.) 		//Muestra el encabezado de la secci�n

//������������������������������������������������������������������������Ŀ
//�Cria��o da celulas da se��o do relat�rio									 �
//� 																				 �
//� TRCell():New 																	 �
//� ExpO1 : Objeto TSection que a secao pertence                     		 �
//� ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado     		 �
//� ExpC3 : Nome da tabela de referencia da celula              			 �
//� ExpC4 : Titulo da celula                                     			 �
//� Default : X3Titulo() 														 �
//� ExpC5 : Picture 																 �
//� Default : X3_PICTURE															 �
//� ExpC6 : Tamanho																 �
//� Default : X3_TAMANHO															 �
//� ExpL7 : Informe se o tamanho esta em pixel								 �
//� Default : False																 �
//� ExpB8 : Bloco de c�digo para impressao.									 �
//� Default : ExpC2																 �
//��������������������������������������������������������������������������

//������������������������������������������������������������������������Ŀ
//� Seccion 2  (oSection2) Encabezado Centro de Costos                     �
//��������������������������������������������������������������������������
	oSection2 :=TRSection():New(oSection1,OemToAnsi(STR0023),{"SRC","CTT","SRV"}) //Encabezado Centro de Costos
	oSection2 :SetHeaderBreak(.F.) 		//Muestra el encabezado de la secci�n
	oSection2 :SetHeaderSection(.F.) 	//Define si imprime encabezado de las celdas cada de que cambia de secci�n
	oSection2 :SetLineBreak(.F.) 		//.T. imprime una o mas lineas - .F.= no imprime linea

	TRCell():New(oSection2,'CCT'		, ''	 , '' , /*Picture*/ , 20                                           , /*lPixel*/ , /*{|| code-block de impressao }*/ )
	TRCell():New(oSection2,'RC_CC'		, 'SRC' , '' , /*Picture*/ , TamSx3("RC_CC")[1] + TamSx3("CTT_DESC01")[1] , /*lPixel*/ , /*{|| code-block de impressao }*/ )
	TRCell():New(oSection2,'CONS'		, ''	 , '' , /*Picture*/ , 20                                           , /*lPixel*/ , /*{|| code-block de impressao }*/ )
	TRCell():New(oSection2,'RV_COD'		, 'SRV' , '' , /*Picture*/ , TamSx3("RV_COD")[1] + TamSx3("RV_DESCDET")[1], /*lPixel*/ , /*{|| code-block de impressao }*/ )

//������������������������������������������������������������������������Ŀ
//� Seccion 3  (oSection3) Encabezado Concepto                             �
//��������������������������������������������������������������������������
	oSection3 :=TRSection():New(oSection2,OemToAnsi(STR0026),{"SRC","CTT"}) //Encabezado Concepto
	oSection3 :SetHeaderBreak(.F.) 		//Muestra el encabezado de la secci�n
	oSection3 :SetHeaderSection(.F.) 	//Define si imprime encabezado de las celdas cada de que cambia de secci�n
	oSection3 :SetLineBreak(.F.) 		//.T. imprime una o mas lineas - .F.= no imprime linea

	TRCell():New(oSection3,'SPACE'			,	''		,	'',	/*Picture*/,3								,	/*lPixel*/,/*{|| code-block de impressao }*/) //agrega espacio
	TRCell():New(oSection3,'CONCP'			,	''		,	'',	/*Picture*/,TamSx3("CTT_DESC01")[1]	,	/*lPixel*/,/*{|| code-block de impressao }*/)

//������������������������������������������������������������������������Ŀ
//� Seccion 4  (oSection4) Encabezado de los datos de Reporte Sint�tico    �
//��������������������������������������������������������������������������
	oSection4 :=TRSection():New(oSection3,OemToAnsi(STR0021),{"SRD","SRC","SRV", "SRA"}) // Comparativo Sint�tico
	oSection4 :SetHeaderPage()
	oSection4 :SetLineBreak(.F.) //.T. imprime una o mas lineas - .F.= no imprime linea
	oSection4 :SetHeaderSection(.T.) 	//Define si imprime encabezado de las celdas cada de que cambia de secci�n
	oSection4 :SetHeaderBreak(.F.) 		//Muestra el encabezado de la secci�n

	TRCell():New(oSection4,'SPACE'	   ,''		,'' 					,/*Picture*/			,3							, /*lPixel*/,/*{|| code-block de impressao }*/) //agrega espacio
	TRCell():New(oSection4,'RA_MAT'	   ,'SRA'	,OemToAnsi(STR0017)  ,/*Picture*/			,TamSx3("RA_MAT")[1]		, /*lPixel*/,/*{|| code-block de impressao }*/) //"Matr�cula"
	TRCell():New(oSection4,'RA_NOME'	,'SRA'	,OemToAnsi(STR0018)	,/*Picture*/			,TamSx3("RA_NOME")[1]	, /*lPixel*/,/*{|| code-block de impressao }*/) //"Nombre"
	TRCell():New(oSection4,'RC_PD'	   ,'SRC'	,OemToAnsi(STR0007)  ,/*Picture*/			,TamSx3("RF_MAT")[1]		, /*lPixel*/,/*{|| code-block de impressao }*/) //"Clave de Concepto"
	TRCell():New(oSection4,'RV_DESCDET','SRV'	,OemToAnsi(STR0008)	,/*Picture*/			,TamSx3("RV_DESCDET")[1]	, /*lPixel*/,/*{|| code-block de impressao }*/) //"Descripci�n"
	TRCell():New(oSection4,'IANT'		,''		,OemToAnsi(STR0009)	,"9,999,999,999.99"	,15							, /*lPixel*/,/*{|| code-block de impressao }*/) //"Importe Anterior"
	TRCell():New(oSection4,'IACT'		,''		,OemToAnsi(STR0010)	,"9,999,999,999.99"	,15							, /*lPixel*/,/*{|| code-block de impressao }*/) //"Importe Actual"
	TRCell():New(oSection4,'VAR01'		,''		,OemToAnsi(STR0011)	,"9,999,999,999.99"	,15							, /*lPixel*/,/*{|| code-block de impressao }*/) //"% Variaci�n"
	TRCell():New(oSection4,'DIF01'		,''		,OemToAnsi(STR0012)	,"9,999,999,999.99"	,15							, /*lPixel*/,/*{|| code-block de impressao }*/) //"Diferencia"

//������������������������������������Ŀ
//� Seccion 5  (oSection5) Totales     �
//��������������������������������������
	oSection5 :=TRSection():New(oSection4,OemToAnsi(STR0021)) // Comparativo Sint�tico
	oSection5 :SetLineBreak(.F.)     // .T. imprime una o mas lineas - .F.= no imprime linea
	oSection5 :SetHeaderSection(.F.) // Define si imprime encabezado de las celdas cada de que cambia de secci�n
	oSection5 :SetHeaderBreak(.F.)   // Muestra el encabezado de la secci�n

	TRCell():New(oSection5,'SPACE'  , '' , '' , /*Picture*/			, 18                     , /*lPixel*/ , /*{|| code-block de impressao }*/ ) //agrega espacio
	TRCell():New(oSection5,'TOTAL'  , '' , '' , /*Picture*/			, TamSx3("RA_NOME")[1]   , /*lPixel*/ , /*{|| code-block de impressao }*/ ) //agrega espacio
	TRCell():New(oSection5,'TOTAN'  , '' , '' , "9,999,999,999.99"	, 15                     , /*lPixel*/ , /*{|| code-block de impressao }*/ ) //"Importe Anterior"
	TRCell():New(oSection5,'TOTAC'  , '' , '' , "9,999,999,999.99"	, 15                     , /*lPixel*/ , /*{|| code-block de impressao }*/ ) //"Importe Actual"
	TRCell():New(oSection5,'TOTVA'  , '' , '' , "9,999,999,999.99"	, 15                     , /*lPixel*/ , /*{|| code-block de impressao }*/ ) //"% Variaci�n"
	TRCell():New(oSection5,'TOTDI'  , '' , '' , "9,999,999,999.99"	, 15                     , /*lPixel*/ , /*{|| code-block de impressao }*/ ) //"Diferencia"

Return(oReport)
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint � Autor �Alfredo Medrano      � Data �23/09/2014  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportPrint devera ser criada para todos    ���
���          �os relatorios que poderao ser agendados pelo usuario.         ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relatorio                             ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � ReportDef                                                    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport)
	Local oSection1		:= oReport:Section(1) // Encabezado Filtros
	Local oSection2		:= oReport:Section(1):Section(1) // Encabezado Centro Costos
	Local oSection3		:= oReport:Section(1):Section(1):Section(1) // Encabezado Concepto
	Local oSection4		:= oReport:Section(1):Section(1):Section(1):Section(1) // Encabezado Reporte
	Local oSection5		:= oReport:Section(1):Section(1):Section(1):Section(1):Section(1) // Totales
	Local cPerDec			:= ""
	Local cProc			:= ""
	Local cTopCod			:= ""
	Local cPrCod	 		:= ""
	Local cDesTp	 		:= ""
	Local cCent			:= ""
	Local nRCJ				:= RETORDEM("RCJ","RCJ_FILIAL+RCJ_CODIGO") // regresa el �ndice
	Local nSRY				:= RETORDEM("SRY","RY_FILIAL+RY_CALCULO") //  regresa el �ndice
	Local cTipo 			:= ""
	Local cConc			:= ""
	Local 	nCont			:= 0
	Local 	nTot			:= 0
	Local cPeAc			:= ""
	Local cPeAn			:= ""
	//suma totales
	Local nTotAct			:= 0
	Local nTotAnt			:= 0
	Local cConcep			:= ""
	//
	Private nOrdem		:= oSection1:GetOrder()
	Private cAliasBus		:= criatrab( nil, .f. )
	Private nTotalR		:= 0

//������������������������������������������������Ŀ
//� Valida que el periodo seleccionado en los para-�
//� metros MV_PAR04 y MV_PAR05 sean  periodos      �
//�Cerrados y Abiertos                             �
//��������������������������������������������������
	Pergunte(oReport:GetParam(),.F.)

	if gpr029ValP()

		//������������������������������������������������Ŀ
		//� Se genera la consulta y se recorren   		  �
		//� los datos del array obtenidos en ( cAliasBus ) �
		//��������������������������������������������������
		GPER029GT1()

		If MV_PAR07 == 2 //SINT�TICO
			cTipo := OemToAnsi(STR0003)
			oSection4:Cell("RA_MAT"):Disable()
			oSection4:Cell("RA_NOME"):Disable()

			oSection2:Cell("CONS"):Disable()
			oSection2:Cell("RV_COD"):Disable()

		Else
			cTipo := OemToAnsi(STR0002) //ANAL�TICO
			oSection4:Cell("RC_PD"):Disable()
			oSection4:Cell("RV_DESCDET"):Disable()

			oSection2:Cell("CCT"):Disable()
			oSection2:Cell("RC_CC"):Disable()

		End If

		//--- T�tulo a imprimir en el reporte
	   	oReport:CTITLE := cTitulo + OemToAnsi(STR0025) + cTipo
		oReport:SetMeter(nTotalR)

		cPrCod	:= POSICIONE( "RCJ", nRCJ,XFILIAL("RGC") + MV_PAR01, "RCJ_DESCRI" )	//Descripci�n de Proceso
		cDesTp	:= POSICIONE( "SRY", nSRY,XFILIAL("SRY") + MV_PAR02, "RY_DESC" ) 		//Descripci�n Tipo Nomina

		If(!Empty(MV_PAR03),cPeAc := substr(MV_PAR03,1,4) + substr(MV_PAR03,5,6),"")
		If(!Empty(MV_PAR05),cPeAn := substr(MV_PAR05,1,4) + substr(MV_PAR05,5,6),"")

		TRCell():New(oSection1,'RCJ_DESCRI', 'RCJ' , OemToAnsi(STR0004) + OemToAnsi(STR0028) + MV_PAR01 + space(1) + cPrCod		      , /*Picture*/ , TamSx3("RCJ_CODIGO")[1]	+ TamSx3("RCJ_DESCRI")[1] + 2	, /*lPixel*/ , /*{|| code-block de impressao }*/ ) //proceso
		TRCell():New(oSection1,'RY_DESC'   , 'SRY' , OemToAnsi(STR0021) + OemToAnsi(STR0028) + MV_PAR02 + space(1) + cDesTp		      , /*Picture*/ , TamSx3("RY_CALCULO")[1]	+ TamSx3("RY_DESC")[1] + 2 		, /*lPixel*/ , /*{|| code-block de impressao }*/ ) //T. N�mina
		TRCell():New(oSection1,'PRDOANT'   , ''	 , OemToAnsi(STR0005) + OemToAnsi(STR0028) + cPeAn + OemToAnsi(STR0025) + MV_PAR06 , /*Picture*/ , TamSx3("RC_PERIODO")[1]	+ 5  								, /*lPixel*/ , /*{|| code-block de impressao }*/ ) //Periodo Anterior
		TRCell():New(oSection1,'PRDOACT'   , ''	 , OemToAnsi(STR0006) + OemToAnsi(STR0028) + cPeAc + OemToAnsi(STR0025) + MV_PAR04 , /*Picture*/ , TamSx3("RC_PERIODO")[1]	+ 5									, /*lPixel*/ , /*{|| code-block de impressao }*/ ) //Periodo Actual


		WHILE ( cAliasBus )->(!eof())

		cConcep := ( cAliasBus )->RC_PD

			oReport:IncMeter()
			If oReport:Cancel() //termina proceso si se cancela el reporte
				Exit
			EndIf
			nTot++

			If ( cAliasBus )->RV_TIPOCOD == '1'
				cPerDec := OemToAnsi(STR0013) // 1= P E R C E P C I O N E S
			Else
				cPerDec := OemToAnsi(STR0014) // 2= D E D U C C I O N E S
			EndIf

			If cProc == ( cAliasBus )->RC_PROCES

				If nOrdem == 2 .AND. MV_PAR07 == 2  // Con desglose por Cento de Costos y si es Sint�tico
					If cCent !=  ( cAliasBus )->RC_CC
						oSection4:Finish()
						oSection2:Init()
						oSection2:cell("CCT"):SetValue(OemToAnsi(STR0015) + OemToAnsi(STR0028))
						oSection2:cell("RC_CC"):SetValue(AllTrim(( cAliasBus )->RC_CC) + space(2) + AllTrim(( cAliasBus )->CTT_DESC01))
						//Alinea campos a la Izquierda
						oSection2:cell("RC_CC"):SetAlign("LEFT")
						oSection2:PrintLine()
						oSection2:Finish()
						nCont := 1
					EndIf
				EndIf

				If MV_PAR07 == 1  //  si es Anal�tico con desglose por Concepto
					If cConc !=  ( cAliasBus )->RC_PD
						oSection4:Finish()

						If MV_PAR07 == 1 .AND. cConcep == ( cAliasBus )->RC_PD	// si es Anal�tico
							oSection5:Init()
							oSection5:cell("SPACE"):SetValue(Space(19))
							oSection5:cell("TOTAL"):SetValue("TOTALES")
							oSection5:cell("TOTAL"):SetAlign("LEFT")
							oSection5:cell('TOTAN'):SetValue(nTotAnt)
							oSection5:cell('TOTAC'):SetValue(nTotAct)
							oSection5:cell('TOTVA'):SetValue(((nTotAct - nTotAnt)/nTotAct)*100)
							oSection5:cell('TOTDI'):SetValue(nTotAct - nTotAnt)
							oSection5:PrintLine()
							oSection5:Finish()
						nTotAct := 0
						nTotAnt := 0
						EndIf
						oSection2:Init()
						oSection2:cell("CONS"):SetValue(OemToAnsi(STR0029) + OemToAnsi(STR0028))
						oSection2:cell("RV_COD"):SetValue(AllTrim(( cAliasBus )->RC_PD) + space(2) + AllTrim(( cAliasBus )->RV_DESCDET))
						//Alinea campos a la Izquierda
						oSection2:cell("RV_COD"):SetAlign("LEFT")
						oSection2:PrintLine()
						oSection2:Finish()
						nCont := 1
					EndIf
				EndIf

				If cTopCod != ( cAliasBus )->RV_TIPOCOD .OR. (cTopCod == ( cAliasBus )->RV_TIPOCOD .AND. nCont==1 )
					oSection4:Finish()
					oSection3:Init()
					oSection3:cell("SPACE"):SetValue(Space(5))
					oSection3:cell("CONCP"):SetValue(cPerDec)
					oSection3:PrintLine()
					oSection3:Finish()
				EndIf

				oSection4:Init()
				oSection4:cell("SPACE"):SetValue(Space(5))

				If MV_PAR07 == 1 // si es Anal�tico
					oSection4:cell("RA_MAT"):SetValue(( cAliasBus )->RC_MAT) // Matr�cula
					oSection4:cell('RA_NOME'):SetValue(( cAliasBus )->RA_NOME) // Nombre
				Else
					oSection4:cell('RC_PD'):SetValue(( cAliasBus )->RC_PD)				//"Clave de Concepto"
					oSection4:cell('RV_DESCDET'):SetValue(( cAliasBus )->RV_DESCDET) 	//"Descripci�n"
				EndIf
				oSection4:cell('IANT'):SetValue(( cAliasBus )->IANT)							//"Importe Anterior"
				oSection4:cell('IACT'):SetValue(( cAliasBus )->IACT)							//"Importe Actual"
				oSection4:cell('VAR01'):SetValue((((cAliasBus)->IACT - (cAliasBus)->IANT)/(cAliasBus)->IACT)*100)	 //"% Variaci�n"
				oSection4:cell('DIF01'):SetValue((cAliasBus)->IACT - (cAliasBus)->IANT)	 //"Diferencia"
				oSection4:PrintLine()

			Else

				If nOrdem == 2 .AND. MV_PAR07 == 2  // Con desglose por Cento de Costos y si es Sint�tico
					oSection2:Init()
					oSection2:cell("CCT"):SetValue(OemToAnsi(STR0015) + OemToAnsi(STR0028))
					oSection2:cell("RC_CC"):SetValue(AllTrim(( cAliasBus )->RC_CC) + space(2) + AllTrim(( cAliasBus )->CTT_DESC01))
					//Alinea campos a la Izquierda
					oSection2:cell("RC_CC"):SetAlign("LEFT")
					oSection2:PrintLine()
					oSection2:Finish()
				EndIf

				If MV_PAR07 == 1  //  si es Anal�tico con desglose por Concepto
					If cConc !=  ( cAliasBus )->RC_PD
						oSection2:Init()
						oSection2:cell("CONS"):SetValue(OemToAnsi(STR0029) + OemToAnsi(STR0028))
						oSection2:cell("RV_COD"):SetValue(AllTrim(( cAliasBus )->RC_PD) + space(2) + AllTrim(( cAliasBus )->RV_DESCDET))
						//Alinea campos a la Izquierda
						oSection2:cell("RV_COD"):SetAlign("LEFT")
						oSection2:PrintLine()
						oSection2:Finish()
					EndIf
				EndIf
				oSection3:Init()
				oSection3:cell("SPACE"):SetValue(Space(5))
				oSection3:cell("CONCP"):SetValue(cPerDec)
				oSection3:PrintLine()
				oSection3:Finish()

				oSection4:Init()
				oSection4:cell("SPACE"):SetValue(Space(5))
				If MV_PAR07 == 1 // si es Anal�tico
					oSection4:cell("RA_MAT"):SetValue(( cAliasBus )->RC_MAT) // Matr�cula
					oSection4:cell('RA_NOME'):SetValue(( cAliasBus )->RA_NOME) // Nombre
				Else
					oSection4:cell('RC_PD'):SetValue(( cAliasBus )->RC_PD)				//"Clave de Concepto"
					oSection4:cell('RV_DESCDET'):SetValue(( cAliasBus )->RV_DESCDET) 	//"Descripci�n"
				EndIf
				oSection4:cell('IANT'):SetValue(( cAliasBus )->IANT)							//"Importe Anterior"
				oSection4:cell('IACT'):SetValue(( cAliasBus )->IACT)							//"Importe Actual"
				oSection4:cell('VAR01'):SetValue((((cAliasBus)->IACT - (cAliasBus)->IANT)/(cAliasBus)->IACT)*100)	 //"% Variaci�n"
				oSection4:cell('DIF01'):SetValue((cAliasBus)->IACT - (cAliasBus)->IANT)	 //"Diferencia"
				oSection4:PrintLine()

			EndIf

			nTotAct += (cAliasBus)->IACT
			nTotAnt += (cAliasBus)->IANT

			If nTot == nTotalR
				If MV_PAR07 == 1 .AND. cConcep == ( cAliasBus )->RC_PD // si es Anal�tico
					oSection5:Init()
					oSection5:cell("SPACE"):SetValue(Space(19))
					oSection5:cell("TOTAL"):SetValue("TOTALES")
					oSection5:cell("TOTAL"):SetAlign("LEFT")
					oSection5:cell('TOTAN'):SetValue(nTotAnt)
					oSection5:cell('TOTAC'):SetValue(nTotAct)
					oSection5:cell('TOTVA'):SetValue(((nTotAct - nTotAnt)/nTotAct)*100)
					oSection5:cell('TOTDI'):SetValue(nTotAct - nTotAnt)
					oSection5:PrintLine()
					oSection5:Finish()
				nTotAct := 0
				nTotAnt := 0
				EndIf

				oSection4:Finish()
			EndIF

			cProc 	:= ( cAliasBus )->RC_PROCES
			cTopCod:= ( cAliasBus )->RV_TIPOCOD
			cConc	:= ( cAliasBus )->RC_PD
			nCont 	:= 0

			If MV_PAR07 == 2  // si es Sint�tico
				cCent	:= ( cAliasBus )->RC_CC
			EndIf
			( cAliasBus )->(dbSkip())
		ENDDO

		nTotalR:= 0
		oSection1:Finish()
	( cAliasBus )->(dbCloseArea())

	else
		oReport:CancelPrint()

	endif

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  �GPER029GT1  � Autor �Alfredo Medrano      � Data �24/09/2014  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � query para Reporte                                           ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � ReportPrint                                                  ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function GPER029GT1()
	Local cQuery 		:= ""
	Local nCont		:= 0
	Local cCaract		:= ""
	Local cCncp		:= ""
	Local cCptos		:= ""
	Local cCtrCs		:= ""
	Local nTamCd		:= 3 // tama�o de c�digo de concepto
	Local cCodPD		:= ""
	Local cSRCQr		:= ""
	Local cSRDQr		:= ""
	Local cQrGrp		:= ""
	Local cQSlRC		:= ""
	Local cQSlRD		:= ""
	Local cFilDel		:= ""

	//���������������������������������������������Ŀ
	//� Verifica las perguntas selecionadas         �
   //� Proceso?                      MV_PAR01      �
   //� Tipo de Nomina?               MV_PAR02      �
   //� Periodo Actual?               MV_PAR03      �
   //� No de Pago Actual?            MV_PAR04      �
   //� Periodo a Comparar?           MV_PAR05      �
   //� No Pago a Comparar?           MV_PAR06      �
   //� Tipo de Informe?              MV_PAR07      �
   //� Centro de Costos?             MV_PAR08 RANGO�
   //� Conceptos a Listar?           MV_PAR09 STR  �
   //� Cont. Conceptos a Listar?     MV_PAR10 STR  �
   //� Todos los Conceptos?          MV_PAR11      �
	//�����������������������������������������������

	//Se arman las agrupaciones, la selecciona de registros y los filtros para  el Query
	//��������������������������������������������������������������Ŀ
	//� Se arman las agrupaciones, la selecciona de registros  		  �
	//� y los filtros para  el Query                                 �
	//����������������������������������������������������������������

	//1.- Verifica si el reporte es Sint�tico o Anal�tico
	If MV_PAR07 == 2  // Sint�tico
		If nOrdem == 2    // Con desglose por Cento de Costos
			cQrGrp := " GROUP BY R.RC_PROCES,RC_CC,R.RC_PD,R.RV_TIPOCOD,R.RV_DESCDET,CTT_DESC01"
		Else
			cQrGrp := " GROUP BY R.RC_PROCES,R.RC_PD,R.RV_TIPOCOD,RC_CC,R.RV_DESCDET,CTT_DESC01"
		EndIf
		cQSlRC := " INNER JOIN " + RetSqlName("CTT") +  " CTT ON RC_CC = CTT_CUSTO "
		cQSlRD := " INNER JOIN " + RetSqlName("CTT") +  " CTT ON RD_CC = CTT_CUSTO "
		cSRCQr := " RC_PROCES,RC_PD,RC_CC,RV_TIPOCOD,RV_DESCDET,CTT_DESC01 "
		cSRDQr	:= " RD_PROCES,RD_PD,RD_CC,RV_TIPOCOD,RV_DESCDET,CTT_DESC01 "
		cFilDel:= " 	AND CTT_FILIAL	= '" + XFILIAL('CTT') + "' "
		cFilDel+= " 	AND CTT.D_E_L_E_T_ 	= ' ' "
	Else
	// Anal�tico
		cSRCQr := " RC_PROCES,RC_PD,RC_MAT,RA_NOME,RV_TIPOCOD,RV_DESCDET "
		cSRDQr := " RD_PROCES,RD_PD,RD_MAT,RA_NOME,RV_TIPOCOD,RV_DESCDET "
		cQrGrp := " GROUP BY R.RC_PROCES,R.RC_PD,R.RC_MAT,R.RA_NOME,R.RV_TIPOCOD,R.RV_DESCDET "
		cQSlRC	:= " INNER JOIN  " + RetSqlName("SRA") + " SRA ON RC_MAT = RA_MAT  "
		cQSlRD	:= " INNER JOIN  " + RetSqlName("SRA") + " SRA ON RD_MAT = RA_MAT  "
		cFilDel:= " 	AND RA_FILIAL	= '" + XFILIAL('SRA') + "' "
		cFilDel+= " 	AND SRA.D_E_L_E_T_ 	= ' ' "
	EndIf

	//convierte parametros tipo Range a expresion sql
	//si esta separa por "-" agrega un BETWEEN,  si esta separado por ";" agrega un IN
	MakeSqlExpr("GPER029CHI")
	cCncp	:= TRIM(MV_PAR09) + TRIM(MV_PAR10) // Conceptos a listar y Cont. de conceptos
	cCtrCs := trim(MV_PAR08) //Centro de costos

	//-- Filtro para Conceptos
	cCodPD := ""
	For nCont:= 1 to Len(Alltrim(cCncp)) Step nTamCd
		cCodPD += "'" + Substr(cCncp, nCont, nTamCd) + "',"
	Next
	//si esta vac�a asigna un "*"
	If empty(cCodPD)
		cCodPD := "'*',"
	EndIf
	cCodPD := Substr( cCodPD, 1, Len(cCodPD)-1)


	cQuery := "SELECT " + cSRCQr + ", sum(ImpAnte) IANT, Sum(ImpAct) IACT
	cQuery += " FROM (
	cQuery += " 	SELECT " + cSRCQr + ", 0 ImpAnte, sum(RC_VALOR) ImpAct "
	cQuery += " 	FROM " + RetSqlName("SRC") + " SRC
	cQuery += " 	INNER JOIN  " + RetSqlName("SRV") + " SRV ON RC_PD = RV_COD "
	cQuery += cQSlRC
	cQuery += " 	WHERE   RV_TIPOCOD IN ('1','2')  "  //percepci�n y deducci�n
	If(!Empty(MV_PAR01), cQuery += " 	AND RC_PROCES	=	'" + MV_PAR01 + "' ","") //Proceso
	If(!Empty(MV_PAR02), cQuery += "	AND RC_ROTEIR	=	'" + MV_PAR02 + "' ","") //Tipo de Nomina
	If(!Empty(MV_PAR03), cQuery += "	AND RC_PERIODO=	'" + MV_PAR03 + "' ","") //Periodo Actual
	If(!Empty(MV_PAR04), cQuery += "	AND RC_SEMANA	= 	'" + MV_PAR04 + "' ","") //No de Pago Actual
	If	!Empty( cCtrCs ) //Centro de costos
		cQuery += " AND " + cCtrCs
	EndIf
	//�����������������������������������������������������������������������������Ŀ
	//� el filtro de concepto solo se utiliza si --> 		                        �
	//� el Tipo de Informe es Anal�tico y  Todos los conceptos MV_PAR11 = NO = 2    �
	//� solo conciderados conceptos indicados en las preguntas MV_PAR09 y MV_PAR10  �
	//�                                                                             �
	//� si Tipo de Informe es Sint�tico se concideran todos los conceptos sin filtro�
	//�������������������������������������������������������������������������������
	If MV_PAR07==1
		If MV_PAR11==2
			cQuery += "AND RC_PD IN (" + cCodPD + ")  "
		EndIF
		cQuery += " 	AND RC_FILIAL 	= '" + XFILIAL('SRC', XFILIAL('SRA')) + "' "
	Else
		cQuery += " 	AND RC_FILIAL 	= '" + XFILIAL('SRC') + "' "
	EndIf
	cQuery += " 	AND RV_FILIAL 	= '" + XFILIAL('SRV') + "' "
	cQuery +=	cFilDel
	cQuery += " 	AND SRC.D_E_L_E_T_ 	= ' ' "
	cQuery += " 	AND SRV.D_E_L_E_T_ 	= ' ' "
	cQuery += "	GROUP BY " +  cSRCQr

	cQuery += " UNION "

	cQuery += " 	SELECT " + cSRDQr + ", sum(RD_VALOR) ImpAnte, 0 ImpAct "
	cQuery += " 	FROM " + RetSqlName("SRD") + " SRD
	cQuery += " 	INNER JOIN  " + RetSqlName("SRV") + " SRV ON RD_PD = RV_COD "
	cQuery += cQSlRD
	cQuery += " 	WHERE   RV_TIPOCOD IN ('1','2')  "  	//percepci�n y deducci�n
	If(!Empty(MV_PAR01), cQuery += " 	AND RD_PROCES	=	'" + MV_PAR01 + "' ","") //Proceso
	If(!Empty(MV_PAR02), cQuery += "	AND RD_ROTEIR	=	'" + MV_PAR02 + "' ","") //Tipo de Nomina
	If(!Empty(MV_PAR05), cQuery += "	AND RD_PERIODO=	'" + MV_PAR05 + "' ","") //Periodo  a comparar
	If(!Empty(MV_PAR06), cQuery += "	AND RD_SEMANA	= 	'" + MV_PAR06 + "' ","") //No. de Pago a comparar
	If	!Empty( cCtrCs ) //Centro de costos
		cQuery +=   " AND " + replace( cCtrCs, "RC_CC", "RD_CC")
	EndIf
	//�����������������������������������������������������������������������������Ŀ
	//� el filtro de concepto solo se utiliza si --> 		                        �
	//� el Tipo de Informe es Anal�tico y  Todos los conceptos MV_PAR11 = NO = 2    �
	//� solo conciderados conceptos indicados en las preguntas MV_PAR09 y MV_PAR10  �
	//�                                                                             �
	//� si Tipo de Informe es Sint�tico se concideran todos los conceptos sin filtro�
	//�������������������������������������������������������������������������������
	If MV_PAR07==1
		If MV_PAR11==2
			cQuery += "AND RD_PD IN (" + cCodPD + ")  "
		EndIf
	 	cQuery += " 	AND RD_FILIAL 	= '" + XFILIAL('SRD', XFILIAL('SRA')) + "' "
	Else
	 	cQuery += " 	AND RD_FILIAL 	= '" + XFILIAL('SRD') + "' "
	EndIf
	cQuery += " 	AND RV_FILIAL 	= '" + XFILIAL('SRV') + "' "
	cQuery +=	cFilDel
	cQuery += " 	AND SRD.D_E_L_E_T_ 	= ' ' "
	cQuery += " 	AND SRV.D_E_L_E_T_ 	= ' ' "
	cQuery += "	group by " + cSRDQr + "  ) R "
	cQuery += cQrGrp //Grupo

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasBus,.T.,.T.)
	Count to nTotalR
	(cAliasBus)->(dbgotop())//primer registro de tabla

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  �GPER029ACT  � Autor �Alfredo Medrano      � Data �19/09/2014  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Llena las preguntas Periodo Actual y No. Pago Actual mediante���
���          � el Proceso y Tipo de n�mina                                  ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � X3_VALID: PERGUNTE GPER029CHI MV_PAR02                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function GPER029ACT()
	Local aArea		:= GetArea()
	Local cFil 	 	:= XFILIAL("RCH")
	Local cProc		:= "" // Proceso
	Local cTpNom		:= "" // Tipo de N�mina
	Local cPerSel		:= "1" // Periodo Seleccionado
	Local cReadVar	:= Upper( AllTrim( ReadVar() ) )

	If Substr(cReadVar, 1, 3) == "M->"
		cReadVar := Substr(cReadVar,4)
	EndIf

	If cReadVar == "MV_PAR02"

		cProc := MV_PAR01
		cTpNom:= MV_PAR02
		DbSelectArea("RCH")
		RCH ->(DBSETORDER(8))
		RCH ->( dbSeek(cFil+cProc+cTpNom+cPerSel) )
		While  RCH->(!Eof()) .And. (RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PERSEL == cFil+cProc+cTpNom+cPerSel )
			If EMPTY(DTOS(RCH->RCH_DTFECH))
				MV_PAR03 := RCH->RCH_PER
				MV_PAR04 := RCH->RCH_NUMPAG
			End If
		RCH->(dbskip())
		EndDo
		RCH->( dbCloseArea())

	End If
RestArea(aArea)
Return


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  �gpr029ValP  � Autor �Jonathan Gonzalez    � Data �04/12/2015  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � valida las preguntas Periodo Actual y No Pago Actual mediante���
���          � el Proceso y Tipo de n�mina                                  ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �lRet = Validacion de periodo abierto o Cerrado                ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �ReportPrint()                                                 ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
static function gpr029ValP()
	Local aArea	 := GetArea()
	Local lRet     := .F.
	Local cFil 	 := XFILIAL("RCH")
	Local cProc	 := "" // Proceso
	Local cTpNom	 := "" // Tipo de N�mina

		cProc := MV_PAR01
		cTpNom:= MV_PAR02

		//Valida periodo actual
		If !empty(MV_PAR03) .and. !lRet
			DbSelectArea("RCH")
			RCH ->(DBSETORDER(4)) //Proceso + Proced Calc + Cod. Periodo + Numero Pago
				If RCH ->( dbSeek(cFil + cProc + cTpNom + MV_PAR03 + MV_PAR04) )
					if RCH_PERSEL == "1"
						lRet := .T.
					else
						lRet := .F.
						MSGALERT (STR0031,STR0030)
					endif
				EndIf
			RCH->( dbCloseArea())
		EndIf

		//Valida periodo Cerrado
		If !empty(MV_PAR05) .and. lRet
			DbSelectArea("RCH")
			RCH ->(DBSETORDER(4)) //Proceso + Proced Calc + Cod. Periodo + Numero Pago
				If RCH ->( dbSeek(cFil + cProc + cTpNom + MV_PAR05 + MV_PAR06) )
					if RCH_PERSEL == "2"
						lRet := .T.
					else
						lRet := .F.
						MSGALERT (STR0033,STR0032)
					endif
				EndIf
			RCH->( dbCloseArea())
		EndIf

	RestArea(aArea)
return lRet