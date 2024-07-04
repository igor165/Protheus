#Include "PROTHEUS.CH"
#Include "RPTDEF.CH"
#Include "TBICONN.CH"
#Include "GPER013COL.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n   � GPER013COL     � Autor � Alfredo Medrano � Data � 02/08/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprimir el Reporte de Novedades							    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � GPER013COL()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico                                                 ���
�������������������������������������������������������������������������Ĵ��
���         ACTUALIZACIONES SUFRIDAS DESDE LA CONSTRUCCION INICIAL        ���                
�������������������������������������������������������������������������Ĵ��
���Programador � Fecha  � BOPS �  Motivo de alteracion                    ���
�������������������������������������������������������������������������Ĵ��
���M.Camargo   �04/03/14�TIKXW1�Se modifica query para que considere      ���
���            �        �      �RA_SITFOLH vac�a y si esta vaci� este     ���
���            �        �      �par�metro entonces no tomarlo en cuenta en���
���            �        �      �el query.                                 ���
���Alex Hdez.  �23/02/16�PCREQ-�Merge 12.1.9 Col. Se modifica query para a���
���            �        �9393  �plique cuando el campo RCM_TPIMSS este va-���
���            �        �      �cio agrege el filtro diferente del valor N���
���            �        �      �y validar los campos vacios y obligatorios���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function GPER013COL()
Local oReport
Local aAreaL := getArea()
If FindFunction("TRepInUse") .And. TRepInUse()
//������������������������������������������������������������������������Ŀ
//�Interface de impresi�n                                                �
//��������������������������������������������������������������������������
	oReport:= ReportDef()
	oReport:PrintDialog()
EndIf
RestArea( aAreaL )
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Alfredo Medrano    � Data �12/08/2013    ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �funcion estatica ReportDef 									    ���
���          �														           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � ReportDef()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPER013COL                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
static Function ReportDef()
	Local cTitulo  := ""
	Local cDescrip := ""
	Local aOrdem 	 := {}
	
	cTitulo 		 := OemToAnsi(STR0001) // REPORTE DE NOVEDADES
	cDescrip 		 := OemToAnsi(STR0013) // El Reporte de Novedades muestra los movimientos de Trayectoria Laboral y los Ausentismos entre dos fechas
	Aadd(aOrdem, STR0014)  // Matricula 
	Aadd(aOrdem, STR0015)  // Centro de Trabajo
	Aadd(aOrdem, STR0016)  // Centro de Costos
	
//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
	oReport:= TReport():New("GPER013COL",cTitulo,"GPER013COL", {|oReport| ReportPrint(oReport)},cDescrip) 
	oReport:SetLandscape() 		//Define la orientaci�n de la p�gina del informe como Horizontal (paisaje).
	oReport:SetTotalInLine(.F.) //True = imprime totalizadores 
	oReport:nFontBody		:= 6 	//Tama�o fuente del documento
	oReport:nLineHeight	:= 40 	//Altura de linea 
	oReport:nColSpace		:= 3 	//Espacio entre las columnas de informaci�n
	oReport:ShowHeader()			//imprimir el encabezado del informe (por default)
	oReport:cFontBody		:= "COURIER NEW" // tipo de letra
	
//������������������������������������������������������������������������Ŀ
//� Preguntas selecionadas - GPER013COL                  					 �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//� Variable utilizadas para parametros                          			 �
//� mv_par01     // �Sucursal?                                   			 �
//� mv_par02     // �Matr�cula?				                       			 �
//� mv_par03     // �Centro de Trabajo?							  			 �
//� mv_par04     // �Centro de Costos?                           			 �
//� mv_par05     // �Fecha Inicial?                              			 �
//� mv_par06     // �Fecha Final?                                			 �
//� mv_par07     // �Tipo de Movimiento?                         			 �
//� mv_par08     // �Situaciones?                                			 �
//� mv_par09     // �Tipo de Ausentismos?                        			 �
//��������������������������������������������������������������������������
	pergunte("GPER013COL",.T.)
	
//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
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
//� Sessao 1  (oSection)                                          			 �
//��������������������������������������������������������������������������
	oSection1 := TRSection():New(oReport,,,aOrdem)
	oSection1 :SetHeaderPage() //Muestra el encabezado de la secci�n
	oSection1 :SetLinesBefore(0)       //Define a quantidade de linhas que ser�o saltadas antes da impress�o da se��o
	
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
	TRCell():New(oSection1,'RCP_MAT'	 ,'',STR0002,/*Picture*/,TamSx3("RCP_MAT")[1], /*lPixel*/,/*{|| code-block de impressao }*/) //MAT
	TRCell():New(oSection1,'RA_NOME'	 ,'',STR0003,/*Picture*/,TamSx3("RA_NOME")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //NOMBRE
	TRCell():New(oSection1,'RCP_CIC'	 ,'',STR0004,/*Picture*/,TamSx3("RCP_CIC")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //NO.ID
	TRCell():New(oSection1,'RCP_CODRPA' ,'',STR0005,/*Picture*/,TamSx3("RCP_CODRPA")[1], /*lPixel*/,/*{|| code-block de impressao }*/) //EPS
	TRCell():New(oSection1,'RCP_NITARL' ,'',STR0007,/*Picture*/,TamSx3("RCP_NITARL")[1], /*lPixel*/,/*{|| code-block de impressao }*/) //ARL
	TRCell():New(oSection1,'RCP_NITAFP' ,'',STR0006,/*Picture*/,TamSx3("RCP_NITAFP")[1], /*lPixel*/,/*{|| code-block de impressao }*/) //AFP
	TRCell():New(oSection1,'RCP_DTMOV'	 ,'',STR0008,/*Picture*/,TamSx3("RCP_DTMOV")[1] + 3,/*lPixel*/,/*{|| code-block de impressao }*/) //FECHA
	TRCell():New(oSection1,'R8_DATAFIM' ,'',STR0009,/*Picture*/,TamSx3("R8_DATAFIM")[1]+ 3,/*lPixel*/,/*{|| code-block de impressao }*/) //FECHA FIN
	TRCell():New(oSection1,'RCP_TPMOV'	 ,'',STR0010,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/) //TIPO
	TRCell():New(oSection1,'RCP_TPSAL'	 ,'',STR0011,/*Picture*/,8, /*lPixel*/,/*{|| code-block de impressao }*/)  //TP SAL
	TRCell():New(oSection1,'VALOR'	 	 ,'',STR0012,"999,999,999,999.99",15, /*lPixel*/,/*{|| code-block de impressao }*/) //VALOR

//������������������������������������������������������������������������Ŀ
//� Sessao 2  (oSection)                                          			 �
//��������������������������������������������������������������������������
	oSection2 := TRSection():New(oReport,,,)
	oSection2:SetHeaderPage()
	oSection2:SetLineBreak(.F.) //.T. imprime una o mas lineas - .F.= no imprime linea  
	TRCell():New(oSection2,OemToAnsi(STR0017),'','',/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) //Empresa
	TRCell():New(oSection2,OemToAnsi(STR0021),'','',/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) //Sucursal
	TRCell():New(oSection2,OemToAnsi(STR0022),'','',/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) //Centro

Return(oReport)

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �  ValCampos   � Autor �JR Briseno         � Data � 08/07/15 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validar los parametros que son obligatorios.               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpA1 := A610CriaHeader(ExpC1,ExpC2,ExpL1,ExpL2)           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .F. - Si alguno de los campos obligatorios esta vacio      ���
���          � .T. - Cuando todos los campos obligatorios tienen valor    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPER013COL                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ValCampos()
Local lRet := .T.
Local dFef := MV_PAR06
Local cTmo := MV_PAR07
Local cSit := MV_PAR08

    If Empty(dFef) .OR. Empty(cTmo) .OR. Empty(cSit)
        Aviso(OemToAnsi(STR0023), OemToAnsi(STR0025), {STR0024}) // llene los campos que son obligatorios
        lRet := .F.
    EndIf 

Return (lRet)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint  Autor �Alfredo Medrano    � Data �12/08/2013   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportPrint devera ser criada para todos  ���
���          �os relatorios que poderao ser agendados pelo usuario.       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relatorio                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPER013COL			                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport)

	Local oSection1	:= oReport:Section(1)
	Local oSection2	:= oReport:Section(2)
	Local cTipoAus		:= ""
	Local cCenCosL    := ""
	Local cCenTraL	    := ""
	Local cMat			:= ""
	Local cFil			:= ""
	Local cFilGrp		:= "" 
	Local cEmpresa		:= ""
	Local cCiudad		:= ""
	Local cCentro		:= ""
	Local cCenGral		:= ""
	Local cKeyloc		:= ""
	Local cCC			:= ""
	Local cTipoSal		:= ""
	Local nEncbzdo	    := 0
	Local dFeVac		:=  CTOD("  /  /  ") 
	Local aAreaLoc 	:= getArea()
	Local nCTT			:= RETORDEM("CTT","CTT_FILIAL+CTT_CUSTO") // regresa el �ndice
	Local nRGC			:= RETORDEM("RGC","RGC_FILIAL+RGC_KEYLOC") // regresa el �ndice
	Private nOrdem		:= oSection1:GetOrder() 
	Private cAliasQry	:= GetNextAlias() 
	
	// valida campos obligatorios
	If ( ValCampos() )
//������������������������������������������������Ŀ
//� Se genera la consulta y se recorren   		  �
//� los datos del array obtenidos en ( cAliasQry ) �
//��������������������������������������������������
	getDatos() // regresa el resultado de la consulta
	( cAliasQry )->(DBGOTOP()) // posiciona al primer registro del archivo de datos
	WHILE ( cAliasQry )->(!eof())
		oReport:IncMeter()
		If oReport:Cancel() //termina proceso si se cancela el reporte
			Exit
		EndIf
		
		If  ( cAliasQry )->RCP_FILIAL != cFilGrp  
			//Mostrar� en encabezado los Centros de Costos � de Trabajo, dependiendo el orden seleccionado
			If nOrdem == 2 
				cCenTraL := POSICIONE( "RGC", nRGC,XFILIAL("RGC") + ( cAliasQry )->RCP_KEYLOC, "RGC_DESLOC" ) //Retorna el centro de trabajo
				cCentro  := Alltrim(OemToAnsi(STR0015)) + " : " //Centro de Trabajo
				cCenGral := cCentro + Alltrim(cCenTraL)
			EndIf
			If nOrdem == 3 
				cCenCosL := POSICIONE( "CTT", nCTT,XFILIAL("CTT") + ( cAliasQry )->RCP_CC, "CTT_DESC01" ) //Retorna el centro de costos  
				cCentro  := Alltrim(OemToAnsi(STR0016)) + " : " //Centro de Costos
				cCenGral := cCentro + Alltrim(cCenCosL)
			EndIf
			nEncbzdo := 1
			
		ElseIF ( cAliasQry )->RCP_FILIAL == cFilGrp .AND.  ( cAliasQry )->RCP_KEYLOC != cKeyloc .AND. nOrdem == 2 // la misma filial pero diferente centro de trabajo
			//Mostrar� en encabezado los Centros de Trabajo
				cCenTraL := POSICIONE( "RGC", nRGC,XFILIAL("RGC") + ( cAliasQry )->RCP_KEYLOC, "RGC_DESLOC" ) //Retorna el centro de trabajo
				cCentro  := Alltrim(OemToAnsi(STR0015)) + " : " //Centro de Trabajo
				cCenGral := cCentro + Alltrim(cCenTraL)
				nEncbzdo := 1
		ElseIF ( cAliasQry )->RCP_FILIAL == cFilGrp .AND.  ( cAliasQry )->RCP_CC != cCC .AND. nOrdem == 3 // la misma filial pero diferente centro de costos
			//Mostrar� en encabezado los Centros de costo
				cCenCosL := POSICIONE( "CTT", nCTT,XFILIAL("CTT") + ( cAliasQry )->RCP_CC, "CTT_DESC01" ) //Retorna el centro de costos  
				cCentro  := Alltrim(OemToAnsi(STR0016)) + " : " //Centro de Trabajo
				cCenGral := cCentro + Alltrim(cCenCosL)
				nEncbzdo := 1
		EndIf

//���������������������������������������Ŀ 
//� obtiene la Filial, Ciudad, Empresa		�
//� y sucursal								�
//�����������������������������������������			
		If nEncbzdo == 1 
			cFil	  := POSICIONE( "SM0", 1,SM0->M0_CODIGO + ( cAliasQry )->RCP_FILIAL, "M0_FILIAL" ) //obtiene la filial 
			cEmpresa := POSICIONE( "SM0", 1,SM0->M0_CODIGO + ( cAliasQry )->RCP_FILIAL, "M0_NOMECOM" )//obtiene Empresa
			cCiudad  := POSICIONE( "SM0", 1,SM0->M0_CODIGO + ( cAliasQry )->RCP_FILIAL, "M0_CIDCOB" ) //obtiene la ciudad
			Sucursal :=Alltrim(( cAliasQry )->RCP_FILIAL) // Sucursal
			
			//���������������������������������������Ŀ 
			//� Impresion de la seguda seccion: Curso �
			//� Se crea el encabezado para el corte	�
			//� imprime la Empresa, Sucursal y Centro	�
			//�����������������������������������������	
			oSection2:Init() 
			oSection2:Cell(OemToAnsi(STR0017)):SetValue("") //Empresa
			oSection2:Cell(OemToAnsi(STR0021)):SetValue("") //Sucursal
			oSection2:Cell(OemToAnsi(STR0022)):SetValue("") //Centro
			oSection2:PrintLine() 
			oSection2:Cell(OemToAnsi(STR0017)):SetValue(STR0017 + " : " + Alltrim(cEmpresa) + " ( " + Alltrim(cCiudad) + " )" ) //Empresa
			oSection2:Cell(OemToAnsi(STR0021)):SetValue(STR0018 + " " + Alltrim(Sucursal) + " - " + Alltrim(cFil)) //Sucursal
			oSection2:Cell(OemToAnsi(STR0022)):SetValue(cCenGral) //Centro
			oSection2:PrintLine()
			oSection2:Finish()
		EndIf
		
//���������������������������������������Ŀ 
//� imprime 6 primeros campos solo       �
//� la primera vez que aparece el        �
//� empleado hasta que �ste cambie       �
//����������������������������������������	
		If ( cAliasQry )->RCP_MAT == cMat .And. nEncbzdo == 0  // compara la matricula actual con la anterior guardada en cMat
			oSection1:cell("RCP_MAT"):SetValue("")
			oSection1:cell("RA_NOME"):SetValue("")
			oSection1:cell("RCP_CIC"):SetValue("")
			oSection1:cell("RCP_CODRPA"):SetValue("")
			oSection1:cell("RCP_NITARL"):SetValue("")
			oSection1:cell("RCP_NITAFP"):SetValue("")
		Else       
			oReport:SkipLine() 
			oSection1:cell("RCP_MAT"):SetValue(( cAliasQry )->RCP_MAT )
			oSection1:cell("RA_NOME"):SetValue(( cAliasQry )->RA_NOME )
			oSection1:cell("RCP_CIC"):SetValue(( cAliasQry )->RCP_CIC )
			oSection1:cell("RCP_CODRPA"):SetValue(( cAliasQry )->RCP_CODRPA )
			oSection1:cell("RCP_NITARL"):SetValue(( cAliasQry )->RCP_NITARL )
			oSection1:cell("RCP_NITAFP"):SetValue(( cAliasQry )->RCP_NITAFP )	
		EndIf
		
		cTipoSal:= ''
		If ( cAliasQry )->RCP_TPSAL == '1'
			cTipoSal := OemToAnsi(STR0019) // B�sico
		ElseIf ( cAliasQry )->RCP_TPSAL == '2'
			cTipoSal := OemToAnsi(STR0020) // Integral
		EndIf
		//verifica si la fecha esta vacia ( / / )
		iF dFeVac != ( cAliasQry )->RCP_DTMOV
			oSection1:cell("RCP_DTMOV"):SetValue(( cAliasQry )->RCP_DTMOV)
		Else
			oSection1:cell("RCP_DTMOV"):SetValue("")
		End If
		iF dFeVac != ( cAliasQry )->R8_DATAFIM
			oSection1:cell("R8_DATAFIM"):SetValue(( cAliasQry )->R8_DATAFIM)
		Else
			oSection1:cell("R8_DATAFIM"):SetValue("")
		End If
		
		oSection1:cell("RCP_TPSAL"):SetValue(cTipoSal )	
		cTipoAus :=  ( cAliasQry )->TPOAU //si es ausentismo regresa SR8T, si es trayectoria regresa RCPT
		If cTipoAus == "RCPT"
			oSection1:cell("RCP_TPMOV"):SetValue(fDescRCC("S030",( cAliasQry )->RCP_TPMOV,1,2,3,30) )
			oSection1:cell("VALOR"):SetValue(( cAliasQry )->RCP_SALMES)
		Else
			oSection1:cell("RCP_TPMOV"):SetValue(fDescRCC("S031",( cAliasQry )->RCP_TPMOV,1,1,2,30) )
			oSection1:cell("VALOR"):SetValue(( cAliasQry )->R8_VALOR )
		EndIf
		
		cMat 	 := ( cAliasQry )->RCP_MAT // asignamos la matricula
		cFilGrp := ( cAliasQry )->RCP_FILIAL // asignamos la filial
		cKeyloc := ( cAliasQry )->RCP_KEYLOC // centro de trabajo
		cCC		 := ( cAliasQry )->RCP_CC//Centro de costos
		nEncbzdo:= 0
		
//���������������������������������������Ŀ
//� Impressao da Primeira Secao: Curso    �
//�����������������������������������������
		oSection1:Init()
		oSection1:PrintLine()
		oSection1:Finish()
		( cAliasQry )->(dbSkip())
	ENDDO
	
	( cAliasQry )->(dbCloseArea())
	EndIf
	restArea(aAreaLoc)
	
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �GetDatos � Autor �Alfredo Medrano    � Data �12/08/2013    ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �funcion estatica GetDatos, obtiene los datos de una consulta���
���          �														           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � GetDatos()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPER013COL                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static function GetDatos()

	Local cQuery 	  := "" 	
	Local cSqlOrd 	  := " RCP_FILIAL, RCP_MAT " // orden del query 
	Local cSuc   	  := ""   
	Local cMat   	  := ""
	Local cCet   	  := ""
	Local cCec   	  := ""
	Local dFei   	  := CTOD("  /  /  ")
	Local dFef   	  := CTOD("  /  /  ")
	Local cTmo   	  := ""
	Local cSit   	  := ""
	Local cTAu		  := ""
	Local nConta	  := 0	
	Local cCaract	  := ""
//����������������������Ŀ
//� Ordem do Relatorio   �
//������������������������
	If nOrdem == 2
		cSqlOrd := " RCP_FILIAL, RCP_KEYLOC, RCP_MAT "
	ElseIf nOrdem == 3
		cSqlOrd := " RCP_FILIAL, RCP_CC, RCP_MAT "
	EndIf
	//convierte parametros tipo Range a expresion sql
	//si esta separado por "-" agrega un BETWEEN,  si esta separado por ";" agrega un IN
	MakeSqlExpr("GPER013COL")
	cSuc := trim(MV_PAR01) //�Sucursal ?
	cMat := trim(MV_PAR02) //�Matricula ?
	cCet := trim(MV_PAR03) //�Centro de Trabajo ?
	cCec := trim(MV_PAR04) //�Centro de Costos ?
	dFei := MV_PAR05 		  //�Fecha Inicial?
	dFef := MV_PAR06 		  //�Fecha Final? 
	cTAu := MV_PAR09 
	cSuc :=Substr(cSuc,2,len(cSuc)-2)
	cMat :=Substr(cMat,2,len(cMat)-2)
	cCet :=Substr(cCet,2,len(cCet)-2)
	cCec :=Substr(cCec,2,len(cCec)-2) 
	cTmo :=Substr(MV_PAR07,2,len(MV_PAR07)-2) //�Tipo de Movimiento?
	cTAu :=Substr(MV_PAR09,2,len(MV_PAR09)-2) //�Tipo Ausentismos?
	//separa con comas los caracteres obtenidos de la cadena "situaciones"
	If !Empty(MV_PAR08)
	nConta	 := 1
	While nConta <= len(MV_PAR08)
	cCaract := SubStr(MV_PAR08,nConta,1)
		If cCaract != "*" //.And.  cCaract != " "
			cSit += "'"+ cCaract +"',"
		EndIf
		nConta++
	End	
	EndIf
	//si esta vac�} asigna un "*"
	/*If empty(cSit)
		cSit := "'*',"
	EndIf*/
	cSit := SubStr(cSit,1,len(cSit)-1) //�Situciones ?   
	// Seleccion de datos de la union de tablas
	cQuery := "SELECT  RCP_FILIAL, RCP_MAT, RCP_DTMOV,R8_DATAFIM,RCP_TPMOV, RCP_CODRPA, "
	cQuery += " RCP_NITAFP, RCP_NITARL, RCP_TPSAL, RCP_SALMES,R8_VALOR, RCP_CIC,"
	cQuery += " RCP_KEYLOC, RCP_CC, RA_NOME, TPOAU FROM ( "
	// inicia union de tablas
	cQuery += " SELECT RCP_FILIAL, RCP_MAT, RCP_DTMOV,' ' as R8_DATAFIM,RCP_TPMOV, "
	cQuery += " RCP_CODRPA, RCP_NITAFP, RCP_NITARL, RCP_TPSAL, RCP_SALMES, "
	cQuery += " 0 as R8_VALOR, RCP_CIC, RCP_KEYLOC, RCP_CC, RA_NOME, 'RCPT' AS TPOAU  "
	cQuery += " FROM " + RetSqlName( "RCP" ) + " RCP, " + RetSqlName( "SRA") + " SRA " 
	cQuery += " WHERE RCP_MAT=RA_MAT "
	If	!Empty( cSuc )
		cQuery +=   " AND " + cSuc 
	EndIf    
	If	!Empty( cMat )
		cQuery +=	 " AND " + cMat 
	EndIf
	If	!Empty( cCet )
		cQuery +=	 " AND " + cCet
	EndIf  
	If	!Empty( cCec )
		cQuery +=	 " AND " + cCec
	EndIf  

   cQuery += " AND RCP_DTMOV >= '" + DTOS(dFei) + "' "

   cQuery += " AND RCP_DTMOV <='" + DTOS(dFef) + "' "   

   If !Empty( cTmo )
      cQuery += " AND " + cTmo //RCP_TPMOV IN
   EndIf
   If!Empty(cSit)
   		cQuery += " AND RA_SITFOLH IN ( " + cSit + " )"
   	EndIF
   	
   	cQuery += " AND RCP.D_E_L_E_T_ = ' ' "
	cQuery += " AND SRA.D_E_L_E_T_ = ' ' "
	cQuery += " UNION ALL"
	cQuery += " SELECT R8_FILIAL, R8_MAT, R8_DATAINI, R8_DATAFIM,RCM_TPIMSS, "
	cQuery += " R8_CODRPAT, R8_NITAFP, R8_NITARL, ' ' as RCP_TPSAL  ,0, "
	cQuery += " R8_VALOR, RA_CIC, RA_KEYLOC, RA_CC, RA_NOME, 'SR8T' AS TPOAU  ""
	cQuery += " FROM " + RetSqlName( "SR8" ) + " SR8, " + RetSqlName( "RCM" ) + " RCM, " + RetSqlName( "SRA" ) + " SRA "	
	cQuery += " WHERE R8_MAT = RA_MAT "

   cQuery += " AND R8_DATAFIM>= '" + DTOS(dFei)+ "' "

   cQuery += " AND R8_DATAINI<= '" +  DTOS(dFef) + "' "

	If !Empty( cTAu )
	   cQuery += " AND  " + cTAu //RCM_TPIMSS IN
	Else
	   cQuery += " AND RCM_TPIMSS <> 'N' " 
	EndIf 
	cQuery += " AND R8_TIPOAFA=RCM_TIPO "
	cQuery += " AND R8_FILIAL=RA_FILIAL "
	If	!Empty( cSuc )
		cQuery +=   " AND " + replace( cSuc, "RCP_FILIAL", "R8_FILIAL") 
	EndIf    
	If	!Empty( cMat )
		cQuery +=	 " AND " + replace( cMat, "RCP_MAT", "R8_MAT")  
	EndIf
	If	!Empty( cCet )
		cQuery +=	 " AND " +  replace( cCet, "RCP_KEYLOC", "RA_KEYLOC")
	EndIf  
	If	!Empty( cCec )
		cQuery +=	 " AND " + replace( cCec, "RCP_CC", "RA_CC") 
	EndIf  
	
	If !Empty(cSit)
		cQuery += " AND RA_SITFOLH IN ( " + cSit + " )"
	EndIf
	cQuery += " AND SR8.D_E_L_E_T_ = ' ' "
	cQuery += " AND RCM.D_E_L_E_T_ = ' ' "
	cQuery += " AND SRA.D_E_L_E_T_ = ' ' "
	// termina union de tablas
	cQuery += " ) DBResult "  // asigna un identificador al Query Principal
	cQuery += " ORDER BY " + cSqlOrd
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F.)
	TCSetField(cAliasQry,"RCP_DTMOV","D") // Formato de fecha
    TCSetField(cAliasQry,"R8_DATAFIM","D") // Formato de fecha	
        
Return 
