#INCLUDE "PROTHEUS.CH"  
#INCLUDE "GPER002DOM.CH"

/*�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������Ŀ��
���Fun��o    �GPER002DOM � Autor �  FMonroy                       � Data � 05/07/11 ���
�����������������������������������������������������������������������������������Ĵ��
���Descri��o � Reporte DGT 4                                                        ���
�����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER002DOM()                                                         ���
�����������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                       ���
�����������������������������������������������������������������������������������Ĵ��
���Programador � Data   �      FNC      �  Motivo da Alteracao                      ���
�����������������������������������������������������������������������������������Ĵ��
���Christiane V�02/02/12�0000018889/2011� Corre��o do error log                     ���
���Christiane V�07/02/12�0000018889/2011� Corre��o para gera��o em ambiente DB2     ���
���Raquel Hager�22/06/12�0000016148/2012� Correcao na query devido a alteracao do   ���
���            �        �         TFFTV5� campo RA_DATAALT para virtual.            ���
���  Marco A.  �22/09/16�     TW8100    � Replica V12.1.7 a partir del llamado      ���
���            �        �               � TVRBWJ para Republica Dominicana.         ���
���  Marco A.  �27/10/16�    TWJZLB     � Se modifica la impresion de la columna    ���
���            �        �               � Salario Cotizable (RV_CODFOL = 0019) para ���
���            �        �               � que se imprima en su lugar el valor del   ���
���            �        �               � RA_SALARIO por empleado. (DOM)            ���
���Alf. Medrano�14/07/17�    MMI-6365   � Replica MMI-5778 Se asigna RG7_RA_ACUMXX  ���
���            �        �               � al Salario Cotizable donde XX es el mes   ���
���            �        �               � seleccionado en el periodo cuando         ���
���            �        �               � RV_CODFOL = 0019                          ���
���Alf. Medrano�04/08/17�    DMINA-4    �Se Modifica func PrintReport se quita query���
���            �        �               �y se asigna en func GPR002DQ. Se incluye   ���
���            �        �               �filtro de RA_CIC + RA_PASSPOR+ RA_NUMINSC  ���
���            �        �               �se elimina func ObtIngresoy crea GPR002DI  ���
������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/
Function GPER002DOM()

	Local cPerg		:= "GPR002DOM"
	Local oReport	:= Nil 
	Local aGetArea	:= GetArea()

	Private cNomeProg	:= "GPER002DOM"
	Private cAliasTmp	:= CriaTrab(Nil, .F.)
	Private cSucI		:= ""
	Private cSucF		:= ""
	Private cProI		:= ""
	Private cProF		:= ""
	Private cMatI		:= ""
	Private cMatF		:= ""
	Private cMes		:= ""
	Private cAnio		:= ""
	Private nMesA		:= 0
	Private cPerAut		:= ""	//Periodo de autodeterminacion
	
	//������������������������������������Ŀ
	//�mv_par01 - �De Filial?              �
	//�mv_par02 - �A Filial?               �
	//�mv_par03 - �De Proceso?             �
	//�mv_par04 - �A Proceso?              �
	//�mv_par05 - �De Matricula?           �
	//�mv_par06 - �A Matricula?            �
	//�mv_par07 - �Mes/A�o Reportado       �
	//�mv_par08 - �Tipo Autodeterminacion? �
	//��������������������������������������
	Pergunte(cPerg, .F.)

	oReport := ReportDef(cPerg)  
	oReport:PrintDialog() 

	RestArea(aGetArea)	

Return (Nil)
   
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef � Autor � FMonroy               � Data �29/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Def. Reporte de citas pendientes.                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �ReportDef(cExp1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cExp1.-Nombre de la pregunta                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �GPER862                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef(cPerg) 

	Local aArea	:= GetArea() 

	Local oReport	:= Nil
	Local oSection1	:= Nil
	Local oSection2	:= Nil
	Local oSection3	:= Nil
	Local oSection4	:= Nil

	Private cTitulo := OemToAnsi(STR0078)//"Reporte DGT 4" 
	
	cTitulo := Trim(cTitulo)

	//������������������������������������������������������������������������Ŀ
	//�Criacao do componente de impressao                                      �
	//�TReport():New                                                           �
	//�ExpC1 : Nome do relatorio                                               �
	//�ExpC2 : Titulo                                                          �
	//�ExpC3 : Pergunte                                                        �
	//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
	//�ExpC5 : Descricao                                                       �
	//��������������������������������������������������������������������������
	oReport := TReport():New(cNomeProg, OemToAnsi(cTitulo), cPerg, {|oReport| PrintReport(oReport)})	
	oReport:nColSpace	:= 0
	oReport:nFontBody	:= 7 // Define o tamanho da fonte.
	oReport:cFontBody	:= "COURIER NEW"
	oReport:SetLandScape(.T.)//Pag Horizontal  
	oReport:lHeaderVisible	:= .F.

	//����������������������������������������������������������Ŀ
	//�Criacao da celulas da secao do relatorio                  �
	//�TRCell():New                                              �
	//�ExpO1 : Objeto TSection que a secao pertence              �
	//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado�
	//�ExpC3 : Nome da tabela de referencia da celula            �
	//�ExpC4 : Titulo da celula                                  �
	//�        Default : X3Titulo()                              �
	//�ExpC5 : Picture                                           �
	//�        Default : X3_PICTURE                              �
	//�ExpC6 : Tamanho                                           �
	//�        Default : X3_TAMANHO                              �
	//�ExpL7 : Informe se o tamanho esta em pixel                �
	//�        Default : False                                   �
	//�ExpB8 : Bloco de c�digo para impressao.                   �
	//�        Default : ExpC2                                   �
	//������������������������������������������������������������
	
	//�����������������������������������������������Ŀ
	//� Creaci�n de la Primera Secci�n:  Encabezado 1 �
	//������������������������������������������������� 
	oSection1 := TRSection():New(oReport, /*"Enc"*/, , , /*Campos do SX3*/, /*Campos do SIX*/)
	oSection1:SetHeaderSection(.F.) //Exibe Cabecalho da Secao
	oSection1:SetHeaderPage(.F.) //Exibe Cabecalho da Secao
	oSection1:SetLeftMargin(3)

	TRCell():New(oSection1, "TITLE1", , , , )

	//�����������������������������������������������Ŀ
	//� Creaci�n de la Segunda Secci�n:  Encabezado 2 �
	//������������������������������������������������� 
	oSection2 := TRSection():New(oReport, /*"Enc"*/, , , /*Campos do SX3*/, /*Campos do SIX*/)
	oSection2:SetHeaderSection(.F.)	//Exibe Cabecalho da Secao
	oSection2:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
	oSection2:SetLeftMargin(3)

	TRCell():New(oSection2, "Clave"			, , , , 7	)
	TRCell():New(oSection2, "TipDoc"		, , , , 4	)
	TRCell():New(oSection2, "NumDoc"		, , , , 12	)		
	TRCell():New(oSection2, "Nombre"		, , , , 30	)
	TRCell():New(oSection2, "1erApellido"	, , , , 20	)
	TRCell():New(oSection2, "2doApellido"	, , , , 20	)
	TRCell():New(oSection2, "Sexo"			, , , , 5	)
	TRCell():New(oSection2, "FecNac"		, , , , 11	)
	TRCell():New(oSection2, "SalCot"		, , , , 14	)
	TRCell():New(oSection2, "AportVol"		, , , , 14	)
	TRCell():New(oSection2, "SalISR"		, , , , 14	)
	TRCell():New(oSection2, "OtrosRem"		, , , , 14	)
	TRCell():New(oSection2, "Remunerac"		, , , , 14	)
	TRCell():New(oSection2, "IngresosEx"	, , , , 14	)
	TRCell():New(oSection2, "SaldoFavor"	, , , , 14	)
	TRCell():New(oSection2, "SalInfotep"	, , , , 14	)
	TRCell():New(oSection2, "TipoIngr"		, , , , 5	)

	//�����������������������������������������Ŀ
	//� Creaci�n de la Tercer Secci�n: Detalle  �
	//������������������������������������������� 
	oSection3 := TRSection():New(oReport, /*"Enc"*/, , , /*Campos do SX3*/, /*Campos do SIX*/)
	oSection3:SetHeaderSection(.F.)	//Exibe Cabecalho da Secao
	oSection3:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
	oSection3:SetLeftMargin(3)
	oSection3:SetLineStyle(.F.)		//Pone titulo del campo y aun lado el y valor

	TRCell():New(oSection3, "Clave"			, cAliasTmp, , 						, 7		)
	TRCell():New(oSection3, "TipDoc"		, cAliasTmp, , 						, 4		)
	TRCell():New(oSection3, "NumDoc"		, cAliasTmp, , 						, 12	)
	TRCell():New(oSection3, "Nombre"		, cAliasTmp, , 						, 30	) //Nombre
	TRCell():New(oSection3, "1erApellido"	, cAliasTmp, , 						, 20	) //1er Apellido
	TRCell():New(oSection3, "2doApellido"	, cAliasTmp, , 						, 20	) //2do Apellido
	TRCell():New(oSection3, "Sexo"			, cAliasTmp, , 						, 5		) //Sexo
	TRCell():New(oSection3, "FecNac"		, cAliasTmp, , 						, 11	) //Fecha Nacimiento
	TRCell():New(oSection3, "SalCot"		, cAliasTmp, , "999,999,999.99"		, 14	) //Salario Cotizable
	TRCell():New(oSection3, "AportVol"		, cAliasTmp, , "999,999,999.99"		, 14	) //Aporte Volinaro
	TRCell():New(oSection3, "SalISR"		, cAliasTmp, , "999,999,999.99"		, 14	) //Salario ISR
	TRCell():New(oSection3, "OtrosRem"		, cAliasTmp, , "999,999,999.99"		, 14	) //Otras Remuneraciones
	TRCell():New(oSection3, "Remunerac"		, cAliasTmp, , "999,999,999.99"		, 14	) //Remuneraciones de Otros Empleados
	TRCell():New(oSection3, "IngresosEx"	, cAliasTmp, , "999,999,999.99"		, 14	) //Ingresos Exentos
	TRCell():New(oSection3, "SaldoFavor"	, cAliasTmp, , "999,999,999.99"		, 14	) //Saldo Favor
	TRCell():New(oSection3, "SalInfotep"	, cAliasTmp, , "999,999,999.99"		, 14	) //Salario Infotep
	TRCell():New(oSection3, "TipoIngr"		, cAliasTmp, , 						, 5		) //Tipo Ingreso
	
	//�����������������������������������������������Ŀ
	//� Creaci�n de la Cuarta Secci�n:  Pie de Pagina �
	//������������������������������������������������� 
	oSection4 := TRSection():New(oReport, /*"Enc"*/, , , /*Campos do SX3*/, /*Campos do SIX*/)
	oSection4:SetHeaderSection(.F.)	//Exibe Cabecalho da Secao
	oSection4:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
	oSection4:SetLeftMargin(3)

	TRCell():New(oSection4, "TITLE", , , , /*Tama�ano de la hoja*/) //"Atenci�n"

	oSection1:nLinesBefore	:= 0	
	oSection2:nLinesBefore	:= 0	
	oSection3:nLinesBefore	:= 0
	oSection4:nLinesBefore	:= 0

Return (oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PrintReport�Autor � FMonroy               � Data �29/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impresion del Informe                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �PrintReport(oExp1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�oExp1.-Objeto del reporte                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �GPER862                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function PrintReport(oReport) 

	Local oSection3		:= oReport:Section(3)
	
	Local cSucActu		:= ""
	Local cTipoDoc		:= ""
	Local nTotal		:= 0
	Local nI			:= 0
	Local nConta		:= 0
	Local cLlaveUn		:= ""
	
	Private nSalCoti	:= 0
	Private nFol1040	:= 0
	Private nFol0015	:= 0
	Private nFol0084	:= 0
	Private nFol1118	:= 0
	Private nFol0544	:= 0
	Private nFol0477	:= 0
	Private nFol1179	:= 0

	TodoOk()
	Pergunte(oReport:GetParam(), .F.)
	
	GPR002DQ() //OBTIENE VALORES DE BASE DE DATOS
	
	Begin Sequence  
		DBSelectArea(cAliasTmp)
		Count To nTotal
		(cAliasTmp)->(DbGoTop()) 
		oReport:SetMeter(nTotal)  
		If (cAliasTmp)->(!Eof())
			//Imprime Encabezado  
			oReport:OnPageBreak({|| Gper862En2(oReport,1,(cAliasTmp)->RA_FILIAL), Gper862En3(oReport), oReport:FatLine()}, .F.)
			oReport:SkipLine(2)
			While (cAliasTmp)->(!Eof())
				nConta++	
				If nConta == 1 .Or. cSucActu != (cAliasTmp)->RA_FILIAL
					oReport:EndPage(.T.) //termina y salta p�gina
				EndIf
				cSucActu := (cAliasTmp)->RA_FILIAL
				nI := 0
				//Imprime Detalle 
				cLlaveUn := ""
				
				oSection3:Init() 
				While (cAliasTmp)->(!Eof()) .And. cSucActu == (cAliasTmp)->RA_FILIAL
					IF cLlaveUn != (cAliasTmp)->RA_CIC + (cAliasTmp)->RA_PASSPOR + (cAliasTmp)->RA_NUMINSC
						nI++

						If !Empty(cLlaveUn)
							oSection3:PrintLine()
							oReport:IncMeter()
							nSalCoti := 0
							nFol1040 := 0
							nFol0015 := 0
							nFol0084 := 0
							nFol1118 := 0
							nFol0544 := 0
							nFol0477 := 0
							nFol1179 := 0
						EndIf 
						
						//Clave Nomina
						oSection3:Cell("Clave"):SetValue((cAliasTmp)->RA_NUMINSC)
						//Tipo Documento
						If !Empty((cAliasTmp)->RA_CIC)
							oSection3:Cell("TipDoc"):SetValue("C")
							cTipoDoc := "C"
						ElseIf !Empty((cAliasTmp)->RA_PASSPOR)
							oSection3:Cell("TipDoc"):SetValue("P")
							cTipoDoc := "P"
						Else
							oSection3:Cell("TipDoc"):SetValue("           ")
						EndIf
						//Numero de Documento
						If cTipoDoc == "C"
							oSection3:Cell("NumDoc"):SetValue((cAliasTmp)->RA_CIC)
						ElseIf cTipoDoc == "P"
							oSection3:Cell("NumDoc"):SetValue((cAliasTmp)->RA_PASSPOR)
						Else
							oSection3:Cell("NumDoc"):SetValue("")
						EndIf
						//Nombre Empleado
						oSection3:Cell("Nombre"):SetValue(AllTrim((cAliasTmp)->RA_PRINOME) + " " + AllTrim((cAliasTmp)->RA_SECNOME))
						//Primer Apellido Empleado
						oSection3:Cell("1erApellido"):SetValue((cAliasTmp)->RA_PRISOBR)
						//Segundo Apellido Empleado
						oSection3:Cell("2doApellido"):SetValue((cAliasTmp)->RA_SECSOBR)
						//Sexo del Empleado
						If (cAliasTmp)->RA_SEXO == "M"
							oSection3:Cell("Sexo"):SetValue("M")
						Else
							oSection3:Cell("Sexo"):SetValue("F")
						EndIf
						//Fecha de Nacimiento del Empleado
						oSection3:Cell("FecNac"):SetValue(STOD((cAliasTmp)->RA_NASC))
						oSection3:Cell("TipoIngr"):SetValue(IIf(GPR002DI((cAliasTmp)->RA_CIC, (cAliasTmp)->RA_PASSPOR, (cAliasTmp)->RA_NUMINSC ), "0004", (cAliasTmp)->RA_TIPOADM))
				
					EndIf
					obtValSal((cAliasTmp)->RV_CODFOL, (cAliasTmp)->RA_ACUMXX, oSection3 )
					cLlaveUn := (cAliasTmp)->RA_CIC + (cAliasTmp)->RA_PASSPOR + (cAliasTmp)->RA_NUMINSC 
		
				(cAliasTmp)->(DBSkip())	  

				EndDo //Fin de archivo
				
				oSection3:PrintLine()
				oReport:IncMeter()
				
				//�������������������������Ŀ
				//� Imprime Total Registros �
				//��������������������������� 
				Gper862Ob(oReport, nI)
				oReport:EndPage()
			EndDo
		EndIf //If fin de archivo 
	End Sequence
	(cAliasTmp)->(DBCloseArea()) 

Return (Nil)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �obtValSal � Autor � Alf Medrano           � Data �18/07/2017���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Obtiene los montos de RG7                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �obtValSal(oExp1,nExp2,oExp3)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cExp1: Codigo de Concepto                                   ���
���          �nExp:  Valor Monetario                                      ���
���          �oExp3: Objeto Treport                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PrintReport                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function obtValSal(cCodFol, nAcum, oSection3 )
						
	IIf(cCodFol == "0019", nSalCoti := nAcum,)//Salario Cotizable						
	IIf(cCodFol == "1040", nFol1040 := nAcum,)//Aporte Volinaro
	IIf(cCodFol == "0015", nFol0015 := nAcum,)//Salario ISR
	IIf(cCodFol == "0084", nFol0084 := nAcum,)	//Otras Remuneraciones						
	IIf(cCodFol == "1118", nFol1118 := nAcum,)	//Remuneraciones de Otros Empleadores		
	IIf(cCodFol == "0544", nFol0544 := nAcum,)	//Ingresos Exentos			
	IIf(cCodFol == "0477", nFol0477 := nAcum,)	//Saldo a Favor
	IIf(cCodFol == "1179", nFol1179 := nAcum,)	//Salario Infotep
					
	oSection3:Cell("SalCot"		):SetValue(nSalCoti)
	oSection3:Cell("AportVol"	):SetValue(nFol1040)
	oSection3:Cell("SalISR"		):SetValue(nFol0015)
	oSection3:Cell("OtrosRem"	):SetValue(nFol0084)
	oSection3:Cell("Remunerac"	):SetValue(nFol1118)
	oSection3:Cell("IngresosEx"	):SetValue(nFol0544)
	oSection3:Cell("SaldoFavor"	):SetValue(nFol0477)
	oSection3:Cell("SalInfotep"	):SetValue(nFol1179)

Return


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Gper862En2� Autor � FMonroy               � Data �05/07/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Encabezado                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Gper862En2(oExp1,nExp1)     	     					      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�oExp1: Objeto Treport   		     					      ���
���          �nExp1: Bandera(1 Imprime Encabezado 2 Imprime Pie de Pag.)  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPER862                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function Gper862En2(oReport, nT, cFilialRa)

	Local oSection1	:= oReport:Section(1)
	
	Local nPosS012	:= 0
	Local nPosS112	:= 0
	Local nPosS001	:= 0
	Local nIdx		:= 1

	Local cFilOri	:= SM0->M0_CODFIL
	Local cCedula	:= "" 
		
	cCedula	:= If(nIdx > 0, fTabela("S012", nIdx, 5), "")

	DBSelectArea("SM0")
	SM0->(DBSeek(cEmpAnt+cFilialRa,.T.))

	nPosS001 := FPosTab("S001", Val(ALLTRIM(SM0->M0_CEPENT)), "=", 4)
	nPosS012 := FPosTab("S012", cFilialRa, "=", 1)
	
	If nPosS012 == 0
		nPosS012 := FPosTab("S012", Space(Len(xFilial("RCB"))), "=", 1)
	Endif

	nPosS112 := FPosTab("S112", cFilialRa, "=", 1)
	If nPosS112 == 0
		nPosS112 := FPosTab("S112", Space(Len(xFilial("RCB"))), "=", 1)
	Endif

	IF nT == 1
		oSection1:Init()
		
		oSection1:Cell("TITLE1"):SetSize((oReport:GetWidth() / 3) / 14)
		
		oSection1:Cell("TITLE1"):SetValue(" ")
		oSection1:PrintLine()
		oSection1:Cell("TITLE1"):SetValue(STR0080) //"Plantilla de Archivo AutoDeterminaci�n"
		oSection1:PrintLine()
		oSection1:Cell("TITLE1"):SetValue(STR0081 + IIf(MV_PAR08 == 1, "AM", "AR")) //"Tipo de Archivo: "
		oSection1:PrintLine()
		oSection1:Cell("TITLE1"):SetValue(STR0082 + PADR(cCedula, 11)) //"RNC o C�dula: 
		oSection1:PrintLine()
		oSection1:Cell("TITLE1"):SetValue(STR0083 + AllTrim(STR(MV_PAR07))) //"Per�odo: "
		oSection1:PrintLine()
		oSection1:Cell("TITLE1"):SetValue(" ")
		oSection1:PrintLine()

		oSection1:Finish()
	EndIf
	
	//������������������������������������������Ŀ
	//�Volta a empresa anteriormente selecionada.�
	//��������������������������������������������
	DBSelectArea("SM0")
	SM0->(DBSeek(cEmpAnt+cFilOri, .T.))
	cFilAnt := SM0->M0_CODFIL
	
Return (Nil)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Gper862En3� Autor � FMonroy               � Data �05/07/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Encabezado  2                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Gper862En3(oExp1)    			     					      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�oExp1: Objeto Treport   		     	                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPER862                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function Gper862En3(oReport)

	Local oSection2	:= oReport:Section(2)
	
	oSection2:Init()	

	oSection2:Cell("Clave"			):SetValue(STR0084) //"Clave"
	oSection2:Cell("TipDoc"			):SetValue(STR0085) //"Tipo"
	oSection2:Cell("NumDoc"			):SetValue(STR0086) //"N�mero"			
	oSection2:Cell("Nombre"			):SetValue(STR0087) //"Nombres"
	oSection2:Cell("1erApellido"	):SetValue(STR0088) //"1er. Apellido"
	oSection2:Cell("2doApellido"	):SetValue(STR0089) //"2do. Apellido"   
	oSection2:Cell("Sexo"			):SetValue(STR0090) //"Sexo"
	oSection2:Cell("FecNac"			):SetValue(STR0091) //"Fecha"
	oSection2:Cell("SalCot"			):SetValue(STR0092) //"Salario"
	oSection2:Cell("AportVol"		):SetValue(STR0093) //"Aporte"
	oSection2:Cell("SalISR"			):SetValue(STR0092) //"Salario"
	oSection2:Cell("OtrosRem"		):SetValue(STR0094) //"Otros"
	oSection2:Cell("Remunerac"		):SetValue(STR0110) //"Remune"
	oSection2:Cell("IngresosEx"		):SetValue(STR0095) //"Ingresos"
	oSection2:Cell("SaldoFavor"		):SetValue(STR0096) //"Saldo"
	oSection2:Cell("SalInfotep"		):SetValue(STR0092) //"Salario"
	oSection2:Cell("TipoIngr"		):SetValue(STR0085) //"Tipo"
	oSection2:PrintLine()

	oSection2:Cell("Clave"			):SetValue(STR0097) //"N�mina"
	oSection2:Cell("TipDoc"			):SetValue(STR0098) //"Doc."
	oSection2:Cell("NumDoc"			):SetValue(STR0099)	//"Documento"	
	oSection2:Cell("Nombre"			):SetValue(Space(1))
	oSection2:Cell("1erApellido"	):SetValue(Space(1))
	oSection2:Cell("2doApellido"	):SetValue(Space(1))  
	oSection2:Cell("Sexo"			):SetValue(Space(1))	
	oSection2:Cell("FecNac"			):SetValue(STR0100) //"Nacim"
	oSection2:Cell("SalCot"			):SetValue(STR0101) //"Cotizable"
	oSection2:Cell("AportVol"		):SetValue(STR0102) //"Volinaro"
	oSection2:Cell("SalISR"			):SetValue(STR0103) //"ISR"
	oSection2:Cell("OtrosRem"		):SetValue(STR0104) //"Resume"
	oSection2:Cell("Remunerac"		):SetValue(STR0111) //"Otros Emp"
	oSection2:Cell("IngresosEx"		):SetValue(STR0105) //"Exentos"
	oSection2:Cell("SaldoFavor"		):SetValue(STR0106) //"Favor"
	oSection2:Cell("SalInfotep"		):SetValue(STR0107) //"Infotep"
	oSection2:Cell("TipoIngr"		):SetValue(STR0108) //"Ingreso"
	oSection2:PrintLine()

	oSection2:Finish()

Return (Nil)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Gper862Ob � Autor � FMonroy               � Data �05/07/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Pie de Reporte                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Gper862Ob(oExp1, nExp1)		     					      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�oExp1: Objeto Treport   		     	                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPER862                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function Gper862Ob(oReport, nI)

	Local oSection4	:= oReport:Section(4)
	Default nI		:= 0
	
	oSection4:Init()	
	oReport:SkipLine(1)
	
	oSection4:Cell("TITLE"):SetSize(oReport:GetWidth(), .T.)
	oSection4:Cell("TITLE"):SetValue(STR0109 + AllTrim(STR(nI))) //"Numero de Registros: "
	oSection4:PrintLine()

	oSection4:Finish()

Return (Nil)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GPR02DOM01� Autor � FMonroy               � Data �05/07/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacion de las preguntas                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPR02DOM01()											      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Ninguno						                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � X1_VALID - GPER862 En X1_ORDEM = 7                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function GPR02DOM01() 

	Local cMes := SubStr(StrZero(MV_PAR07, 6), 1, 2)

	IF Val(cMes) < 1 .Or. Val(cMes) > 12
		MsgInfo(STR0077) //"El mes debe ser de 1 a 12!"
		Return .F.
	EndIf                  

Return (.T.)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �TodoOK    �Autor  �Microsiga           � Data �  05/07/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacion de los datos antes de Ejecutar el proceso        ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TodoOK(cPerg)

	Pergunte(cPerg, .F.)
	
	cSucI	:= MV_PAR01
	cSucF	:= MV_PAR02
	cProI	:= MV_PAR03
	cProF	:= MV_PAR04
	cMatI	:= MV_PAR05
	cMatF	:= MV_PAR06
	cMes	:= SubStr(StrZero(MV_PAR07, 6), 1, 2)
	cAnio	:= SubStr(StrZero(MV_PAR07, 6), 3, 4)
	nMesA	:= MV_PAR07
	cTipArch:= MV_PAR08
	cPerAut	:= StrZero(MV_PAR07,6)   //Periodo de autodeterminacion
	
Return (.T.)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �GPR002DI  � Autor � Marco Augusto         � Data � 28/07/16 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion que valida el tipo de ingreso del Empleado. (DOM)  ���   
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ObtAusen(cExp1, cExp2)                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  cExp1.- CIC del empleado.                                 ���
���          �  cExp2.- Num Pasaporte.                                    ���
���          �  cExp3.- tipo Nomina .                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPER002DOM - Reporte Archivo DGT-4                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/ 
Function GPR002DI(cCICEmp, cPaspor, cNumins)
	
	Local cAliasAus	:= CriaTrab(Nil,.F.)
	Local cAliasEmp	:= ""	   
	Local cSR8Name	:= InitSqlName("SR8")     
	Local cSRAName	:= InitSqlName("SRA") 
	Local cQuery	:= ""      
	Local nRegSR8	:= 0
	Local nRegSRA	:= 0    
	Local lRet		:= .F.                                                                               
	Local cUltDia	:= SubStr(DTOC(LastDay(CTOD('01/' + StrZero(Val(SubStr(cPerAut, 1, 2)), 2) + '/' + SubStr(cPerAut, 3, 6)))), 1, 2)
	Local cIniMes	:= DTOS(CTOD('01/' + StrZero(Val(SubStr(cPerAut, 1, 2)), 2) + '/' + SubStr(cPerAut, 3, 6)))
	Local cFinMes	:= DTOS(CTOD(cUltDia + '/' + StrZero(Val(SubStr(cPerAut, 1, 2)), 2) + '/' + SubStr(cPerAut, 3, 6)))      

	cQuery := "SELECT R8_FILIAL, R8_MAT"
	cQuery += " FROM " + cSR8Name + " SR8, " + cSRAName + " SRA"
	cQuery += " WHERE"
	cQuery += "	RA_CIC = '" + cCICEmp + "'"
	cQuery += "	AND RA_PASSPOR = '" + cPaspor + "'"
	cQuery += "	AND RA_NUMINSC = '" + cNumins + "'"
	cQuery += " AND R8_FILIAL = '" + xFilial("SR8", SRA->RA_FILIAL) + "'"
	cQuery += "	AND R8_FILIAL = RA_FILIAL"
	cQuery += "	AND R8_MAT = RA_MAT"
	cQuery += "	AND ((R8_DATAINI BETWEEN '" + cIniMes + "' AND '" + cFinMes + "')"
	cQuery += "	OR (R8_DATAFIM BETWEEN '" + cIniMes + "' AND '" + cFinMes + "'))"
	cQuery += "	AND R8_STATUS  = 'C'"
	cQuery += " AND SRA.D_E_L_E_T_= ' '"
	cQuery += " AND SR8.D_E_L_E_T_= ' '"
	cQuery := ChangeQuery(cQuery)      

	DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAus,.T.,.T.)  
	Count To nRegSR8        

	//Hubo algun ausentismo 
	If nRegSR8 > 0
		lRet := .T.
		(cAliasAus)->(DbCloseArea())
	Else
		(cAliasAus)->(DbCloseArea())
		cAliasEmp := CriaTrab(Nil,.F.)
		
		cQuerySRA := "SELECT RA_MAT, RA_CIC, RA_PASSPOR"
		cQuerySRA += " FROM " + cSRAName + " SRA"
		cQuerySRA += " WHERE"
		cQuerySRA += " RA_CIC = '" + cCICEmp + "'" 
		cQuerySRA 	+= " AND RA_PASSPOR = '" + cPaspor + "'"
		cQuerySRA	+= " AND RA_NUMINSC = '" + cNumins + "'"
		cQuerySRA += " AND ((RA_ADMISSA BETWEEN '" + cIniMes + "' AND '" + cFinMes + "')"
		cQuerySRA += " OR (RA_FECREI BETWEEN '" + cIniMes + "' AND '" + cFinMes + "')"
		cQuerySRA += " OR (RA_DEMISSA BETWEEN '" + cIniMes + "' AND '" + cFinMes + "'))"
		cQuerySRA += " AND SRA.D_E_L_E_T_= ' '"
		cQuerySRA := ChangeQuery(cQuerySRA)      
	
		DBUseArea(.T., "TOPCONN", TcGenQry( , , cQuerySRA), cAliasEmp, .T., .T.)  
		Count To nRegSRA
		        
	  If nRegSRA > 0
	  	lRet := .T.
	  EndIf
	  
	  (cAliasEmp)->(DbCloseArea())
	  
	EndIf

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GPR002DQ  � Autor � Alf Medrano           � Data �18/07/2017���
�������������������������������������������������������������������������Ĵ��
���Descri��o � obtiene valores de la base de datos                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �GPR002DQ()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PrintReport                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function GPR002DQ()

	Local cSRAName	:= InitSqlName("SRA")
	Local cRG7Name	:= InitSqlName("RG7")
	Local cSRVName	:= InitSqlName("SRV")
	Local cQuery	:= ""     
	Local cCriterio	:= '01'
	Local cCodFol	:= "'1040', '0015', '0084', '1118', '0544', '0477', '1179', '0019'"
	
	cQuery := " SELECT RA_FILIAL, RA_PRINOME, RA_SECNOME, RA_PRISOBR, RA_SECSOBR, RA_CIC, RA_NACIONA, RA_SEXO, RA_NASC, "
	cQuery += " RA_PASSPOR, RA_TIPOADM, RA_NUMINSC, RA_PROCES, RV_CODFOL, SUM(RG7_ACUM" + cMes + ") RA_ACUMXX" 
	cQuery += " FROM " + cSRAName + " SRA," + cRG7Name + " RG7," + cSRVName + " SRV"
	cQuery += " WHERE"
	cQuery += "	RG7_FILIAL BETWEEN '" + cSucI + "' AND '" + cSucF + "'"  
	cQuery += "	AND RA_MAT BETWEEN '" + cMatI + "' AND '" + cMatF + "'"
	cQuery += "	AND RG7_PROCES BETWEEN '" + cProI + "' AND '" + cProF + "'"
	cQuery += "	AND RA_MAT = RG7_MAT AND RA_FILIAL = RG7_Filial "
	cQuery += "	AND RG7_ANOINI = '" + cAnio + "'" 
	cQuery += "	AND RG7_CODCRI = '" + cCriterio + "'" 
	cQuery += "	AND RG7_PD = RV_COD" 
	cQuery += "	AND RV_CODFOL IN (" + cCodFol + ")" 
	cQuery += " 	AND SRA.D_E_L_E_T_ = ' '"   
	cQuery += " 	AND SRV.D_E_L_E_T_ = ' '"   
	cQuery += " 	AND RG7.D_E_L_E_T_ = ' '"   
	cQuery += " Group by RA_FILIAL,RA_CIC,RA_PASSPOR,RV_CODFOL,RA_NUMINSC,RA_PRINOME, RA_SECNOME, RA_PRISOBR, "   
	cQuery += " RA_SECSOBR, RA_NACIONA, RA_SEXO, RA_NASC, RA_TIPOADM, RA_PROCES " 
	cQuery += " ORDER BY RA_FILIAL, RA_CIC,RA_PASSPOR, RA_NUMINSC "
	cQuery := ChangeQuery(cQuery)	
	DBUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasTmp, .T., .T.)

Return .T.