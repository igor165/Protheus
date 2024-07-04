#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER016COL.CH"
#INCLUDE "report.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funci�n   �GPER016COL� Autor � Alfredo Medrano       �  Data � 29/10/2013���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Imprimir el Reporte Retenci�n Contingente                    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe e � GPER016COL()                                                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Colombia                                                     ���
���������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
����������������������������������������������������������������������������ٱ�
���Programador   � Data   � BOPS/FNC  �  Motivo da Alteracao                ���
���������������������������������������������������������������������������Ĵ��
��� m.camargo    �25/03/12�TPAY99     �Se obtiene % de Val No Apl.          ���
��� m.camargo    �25/03/12�TPAY99     �Se modifican tama�os de celdas num.  ���
��� Alf. Medrano �16/02/16�TPAY99     �se alinean campos de Seccion 2 en fun���
���              �        �           �ReportDef                            ���
��� Alf. Medrano �07/09/16�PDR_SER_   �Merge 12.1.13                        ���
���              �        �MI002-56   �                                     ���
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function GPER016COL()
Local		oReport
Local		aArea 		:= GetArea()
Private 	cTitulo	:= OemToAnsi(STR0001)
Private 	aOrd    	:= {OemToAnsi(STR0007),OemToAnsi(STR0015)}	//"Matr�cula"###"Filial + Matr�cula"
Private 	cPerg   	:= "GPER016COL"

If FindFunction("TRepInUse") .And. TRepInUse()
	//������������������������������������������Ŀ
	//� Verifica las perguntas selecionadas      �
	//��������������������������������������������
	pergunte(cPerg,.F.)

    oReport := ReportDef()
    oReport:PrintDialog()
EndIF

RestArea( aArea )

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportDef  � Autor � Alfredo Medrano       � Data �29/10/2013���
���������������������������������������������������������������������������Ĵ��
���Descri�ao �  Relatorio Retenci�n Contingente                             ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER016COL                                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � GPER016COL - Colombia                                        ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2




		//�Crea los componentes de impresion
		DEFINE REPORT oReport NAME "GPER016COL" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| ReportPrint(oReport)} DESCRIPTION OemtoAnsi(STR0016)  TOTAL IN COLUMN
		oReport:nFontBody := 6 	//Tama�o fuente del documento
		oReport:SetLandscape() 	//Define la orientaci�n de la p�gina del informe como Horizontal (paisaje).


		DEFINE SECTION oSection OF oReport TITLE " " TABLES "SRD" TOTAL IN COLUMN ORDERS aOrd
		DEFINE CELL NAME "RD_FILIAL" 	OF oSection ALIAS " "	SIZE TamSX3("RD_FILIAL")[1] 	 TITLE OemToAnsi(STR0004) // "Sucursal"
		DEFINE CELL NAME "RD_MAT" 	 	OF oSection ALIAS " "	SIZE TamSX3("RD_MAT")[1]		 TITLE OemToAnsi(STR0007) // "Matr�cula"
		DEFINE FUNCTION FROM oSection:Cell("RD_MAT")		FUNCTION COUNT NO END SECTION

		DEFINE SECTION oSection1 OF oSection TITLE " "
		DEFINE CELL NAME "RD_FILIAL" 	OF oSection1 ALIAS " "	SIZE TamSX3("RD_FILIAL")[1] 	TITLE OemToAnsi(STR0004) ALIGN LEFT 			     					// "Sucursal"
		DEFINE CELL NAME "RD_CC" 	 	OF oSection1 ALIAS " "	SIZE TamSX3("RD_CC")[1] 		TITLE OemToAnsi(STR0005) ALIGN LEFT  									// "Centro Costo"
		DEFINE CELL NAME "CTT_DESC01"	OF oSection1 ALIAS " "	SIZE TamSX3("CTT_DESC01")[1]    TITLE " "                ALIGN LEFT										// "Descripci�n"
		DEFINE CELL NAME "RA_TPCIC"  	OF oSection1 ALIAS " "	SIZE TamSX3("RA_TPCIC")[1]		TITLE OemToAnsi(STR0021) ALIGN LEFT									// "Tipo ID"
		DEFINE CELL NAME "RA_CIC" 	 	OF oSection1 ALIAS " "	SIZE TamSX3("RA_CIC")[1]		TITLE OemToAnsi(STR0022) ALIGN LEFT									// "Num. ID"
		DEFINE CELL NAME "RD_MAT" 	 	OF oSection1 ALIAS " "	SIZE TamSX3("RD_MAT")[1]		TITLE OemToAnsi(STR0007) ALIGN LEFT										// "Matr�cula"
		DEFINE CELL NAME "RA_NOME" 	 	OF oSection1 ALIAS " "	SIZE TamSX3("RA_NOME")[1]   	TITLE OemToAnsi(STR0008) ALIGN LEFT										// "Nombre"
		DEFINE CELL NAME "APOVOLSI" 	OF oSection1 ALIAS " "	SIZE 21				 	 	 	TITLE OemToAnsi(STR0009) ALIGN RIGHT  HEADER ALIGN RIGHT	PICTURE "@E 99,999,999,999.99"  // "Apo Vol Si Aplico"
		DEFINE CELL NAME "APOVOLNO"	    OF oSection1 ALIAS " "	SIZE 21							TITLE OemToAnsi(STR0010) ALIGN RIGHT  HEADER ALIGN RIGHT	PICTURE "@E 99,999,999,999.99"  // "Apo Vol No Aplico"
		DEFINE CELL NAME "RRESTVOL"	    OF oSection1 ALIAS " "	SIZE 21							TITLE OemToAnsi(STR0023) ALIGN RIGHT  HEADER ALIGN RIGHT	PICTURE "@E 99,999,999,999.99"  // "Ret. Rest. Vol."
		DEFINE CELL NAME "RETSINAPO"	OF oSection1 ALIAS " "	SIZE 21							TITLE OemToAnsi(STR0011) ALIGN RIGHT  HEADER ALIGN RIGHT	PICTURE "@E 99,999,999,999.99"  // "Ret Fte sin Apo Vol"
		DEFINE CELL NAME "RETENCON"		OF oSection1 ALIAS " "	SIZE 21							TITLE OemToAnsi(STR0012) ALIGN RIGHT  HEADER ALIGN RIGHT	PICTURE "@E 99,999,999,999.99"  // "Retenci�n Contingente"
		DEFINE CELL NAME "ENTID" 		OF oSection1 ALIAS " "	SIZE TamSX3("RD_ENTIDAD")[1]	TITLE OemToAnsi(STR0014) ALIGN LEFT   HEADER ALIGN CENTER									// Entidad

		DEFINE SECTION oSection2 	OF oSection1 TITLE OemToAnsi(STR0020)  //"Aportacion Voluntaria"
		DEFINE CELL NAME "DET1" 	OF oSection2 ALIAS " " SIZE TamSX3("RD_FILIAL")[1]		TITLE ""  ALIGN LEFT
   		DEFINE CELL NAME "DET2"  	OF oSection2 ALIAS " " SIZE TamSX3("RD_CC")[1]	 		TITLE ""  ALIGN LEFT
   		DEFINE CELL NAME "DET3"   	OF oSection2 ALIAS " " SIZE TamSX3("CTT_DESC01")[1]		TITLE ""  ALIGN LEFT
		DEFINE CELL NAME "DET12"  	OF oSection2 ALIAS " " SIZE TamSX3("RA_TPCIC")[1]		TITLE ""  ALIGN LEFT
		DEFINE CELL NAME "DET13" 	OF oSection2 ALIAS " " SIZE TamSX3("RA_CIC")[1]			TITLE ""  ALIGN LEFT
		DEFINE CELL NAME "DET14" 	OF oSection2 ALIAS " " SIZE TamSX3("RD_MAT")[1]			TITLE ""  ALIGN LEFT
   		DEFINE CELL NAME "DET4" 	OF oSection2 ALIAS " " SIZE TamSX3("RA_NOME")[1]		TITLE ""  ALIGN RIGHT
   		DEFINE CELL NAME "DET6"   	OF oSection2 ALIAS " " SIZE 21							TITLE ""  ALIGN RIGHT
	   	DEFINE CELL NAME "DET7"   	OF oSection2 ALIAS " " SIZE 21							TITLE ""  ALIGN RIGHT
	   	DEFINE CELL NAME "DET11"   	OF oSection2 ALIAS " " SIZE 21							TITLE ""  ALIGN RIGHT
	   	DEFINE CELL NAME "DET8"   	OF oSection2 ALIAS " " SIZE 21							TITLE ""  ALIGN RIGHT
	   	DEFINE CELL NAME "DET9"   	OF oSection2 ALIAS " " SIZE 21							TITLE ""  ALIGN RIGHT
	   	DEFINE CELL NAME "DET10"	OF oSection2 ALIAS " " SIZE TamSX3("RD_ENTIDAD")[1] 	TITLE ""  ALIGN LEFT

		oSection:SetHeaderSection(.F.)	//Exibe Cabecalho da Secao
		oSection:SetHeaderPage(.F.)		//Exibe Cabecalho da Secao
		oSection2:SetHeaderSection(.F.)	//Exibe Cabecalho da Secao
		oSection2:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
		oSection1:SetAutoSize()
		oSection2:SetAutoSize()

Return(oReport)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint      Autor �Alfredo Medrano     � Data �29/10/2013���
���������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportPrint devera ser criada para todos    ���
���          �os relatorios que poderao ser agendados pelo usuario.         ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relatorio                             ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � GPER016COL			                                        ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport)

Local oSection 	:= oReport:Section(1)
Local oSection1	:= oReport:Section(1):Section(1)

Local cAliasQry	:= ""
Local cSitQuery	:= ""
Local cCatQuery	:= ""
Local cTitFil	:= ""
Local nReg		:= 0

Local cSitua  	:= MV_PAR05
Local cCateg	:= MV_PAR06
Local nConso	:= MV_PAR11
Local nSucPag	:= MV_PAR12

//��������������������������������������������������������������Ŀ
//�  Variaveis de Acesso do Usuario                              �
//����������������������������������������������������������������
Private cAcessaSRD	:= &( " { || " + ChkRH( "GPER016COL" , "SRD" , "2" ) + " } " )
Private nOrdem		:= oSection:GetOrder()

//��������������������������������������������������������������Ŀ
//� Carregando variaveis mv_par?? para Variaveis do Sistema.     �
//� mv_par01        //  �Sucursal?                               �
//� mv_par02        //  �Centro de Costo?                        �
//� mv_par03        //  �Matricula?                              �
//� mv_par04        //  �Nombre?                                 �
//� mv_par05        //  �Situaciones?                            �
//� mv_par06        //  �Categorias?                             �
//� mv_par07        //  �Proceso?                                �
//� mv_par08        //  �Procedimiento?                          �
//� mv_par09        //  �Periodo? 									  �
//� mv_par10        //  �No Pago?                                �
//� mv_par11        //  �Consolidado?                            �
//� mv_par12        //  �Suc en otra Pag?                        �
//����������������������������������������������������������������
Private aInfo		:= {}
Private cDESCRIP	:= ""   //Descripci�n del Centro de Costos
Private nVOLSI		:= 0   	//Apo Vol Si Aplico
Private nVOLNO		:= 0   	//Apo Vol No Aplico
Private nSINAPO	:= 0	//Ret Fte sin Apo Vol
Private nRETCON	:= 0	//Retenci�n Contingente
Private nRRETVOL := 0 // Ret. Rest. Voluntarios
Private cNombre	:= ""	//Nombre
Private nTotalR	:= 0   //total de registros generados por la consulta
Private cFilSRV    := xfilial("SRV")

//������������������������������������������������������Ŀ
//�	Por cada empleado totaliza las siguientes columnas:	 �
//�		Apo Vol Si Aplico										 �
//�		Apo Vol No Aplico 									 �
//�		Ret Fte sin Apo Vol 									 �
//�		Retenci�n Contingente 								 �
//�                                        				 �
//��������������������������������������������������������
	DEFINE BREAK oBreakPrj OF oSection1 WHEN oSection1:Cell("RD_MAT")  TITLE OemToAnsi(STR0019)  	// "TOTAL -> "
	DEFINE FUNCTION oTFil  NAME "oTFil"	 FROM oSection1:Cell("APOVOLSI") 	FUNCTION SUM BREAK oBreakPrj NO END SECTION
	DEFINE FUNCTION oTFil2 NAME "oTFil2" 	 FROM oSection1:Cell("APOVOLNO")	FUNCTION SUM BREAK oBreakPrj NO END SECTION

	DEFINE FUNCTION oTFil2 NAME "oTFil5" 	 FROM oSection1:Cell("RRESTVOL")	FUNCTION SUM BREAK oBreakPrj NO END SECTION

	DEFINE FUNCTION oTFil3 NAME "oTFil3" 	 FROM oSection1:Cell("RETSINAPO")	FUNCTION SUM BREAK oBreakPrj NO END SECTION
	DEFINE FUNCTION oTFil4 NAME "oTFil4" 	 FROM oSection1:Cell("RETENCON")	FUNCTION SUM BREAK oBreakPrj NO END SECTION

//reporte por sucursal (MV_PAR11=2) realizar un corte por cada RD_FILIAL diferente.
	If nConso==2 .And. nSucPag == 2
		//-- Quebrar e Totalizar por Sucursal
		DEFINE BREAK oBreakFil OF oSection WHEN oSection:Cell("RD_FILIAL")  TITLE OemToAnsi(STR0018)	  	// "TOTAL SUCURSAL -> "
		DEFINE FUNCTION FROM oSection:Cell("RD_MAT")		FUNCTION COUNT BREAK oBreakFil NO END REPORT
 		oBreakFil:OnBreak({|x,y|cTitFil:=OemToAnsi(STR0018)+x,fInfo(@aInfo,y)})	// "TOTAL FILIAL -> "
	   oBreakFil:SetTotalText({||cTitFil})

	ElseIf nConso == 2 .And. nSucPag == 1 //Realizar un salto de p�gina si MV_PAR12=1

		//-- Quebrar e Totalizar por Sucursal
		DEFINE BREAK oBreakFil OF oSection WHEN oSection:Cell("RD_FILIAL")  TITLE OemToAnsi(STR0018)	PAGE BREAK  // "TOTAL SUCURSAL -> " / Salto de p�gina
		DEFINE FUNCTION 	FROM oSection:Cell("RD_MAT")		FUNCTION COUNT BREAK oBreakFil NO END REPORT
 		oBreakFil:OnBreak({|x,y|cTitFil:=OemToAnsi(STR0018)+x,fInfo(@aInfo,y)})	// "TOTAL FILIAL -> "
	   oBreakFil:SetTotalText({||cTitFil})

	EndIF

#IFDEF TOP
	cAliasQry := GetNextAlias()

		//-- Modifica variaveis para a Query
	cSitQuery := ""
	For nReg:=1 to Len(cSitua)
		cSitQuery += "'"+Subs(cSitua,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cSitua)
			cSitQuery += ","
		Endif
	Next nReg
	cSitQuery := "%" + cSitQuery + "%"

	cCatQuery := ""
	For nReg:=1 to Len(cCateg)
		cCatQuery += "'"+Subs(cCateg,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cCateg)
			cCatQuery += ","
		Endif
	Next nReg
	cCatQuery := "%" + cCatQuery + "%"

	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr(cPerg)

	BEGIN REPORT QUERY oSection

	If nConso == 1
		cOrdem := "%SRD.RD_MAT%"
	ElseIf nConso == 2
		cOrdem := "%SRD.RD_FILIAL,SRD.RD_MAT%"
	Endif

//�identificadores de C�lculo de los conceptos:			�
//�								 ID_CALCULO				�
//�372	RET FTE AP VOL SI AP			?				�
//�375	RET FTE AP VOL NO AP			?				�
//�374	RET FTE SIN AP VOLUN			?				�
//�373	RET FTE R CONTINGENT			?				�
//�332	AFC APORT VOLUNTARIA			?				�
//�333	AFP APORT VOLUNTARIA			?				�
//�                                        				�
	BeginSql alias cAliasQry
		SELECT	SRD.RD_FILIAL, SRD.RD_CC, SRD.RD_MAT, SRD.RD_PD, SRA.RA_NOME ,RV_CODFOL, SUM(RD_VALOR)  Total
		FROM %table:SRA% SRA, %table:SRD% SRD, %table:SRV% SRV
		WHERE 	SRD.RD_MAT = SRA.RA_MAT 						AND
				SRD.RD_FILIAL = SRA.RA_FILIAL					AND
				SRA.RA_SITFOLH	IN	(%exp:Upper(cSitQuery)%)	AND
				SRA.RA_CATFUNC	IN	(%exp:Upper(cCatQuery)%)	AND
	 	    	(RD_PD IN (SELECT RV_COD FROM  %table:SRV% WHERE RV_CODFOL='1349' AND RV_FILIAL = %exp:cFilSRV% ) OR 		//Retencion en la Fuente Aportacion Vol SI Aplico
       			RD_PD IN (SELECT RV_COD FROM  %table:SRV% WHERE RV_CODFOL='1346' AND RV_FILIAL = %exp:cFilSRV% )  OR 		//RETENCION EN LA FUENTE APO VOL NO APLICO
       			RD_PD IN (SELECT RV_COD FROM  %table:SRV% WHERE RV_CODFOL='0066' AND RV_FILIAL = %exp:cFilSRV% )  OR 		//RET REST VOLUNTARIOS
       			RD_PD IN (SELECT RV_COD FROM  %table:SRV% WHERE RV_CODFOL='1347' AND RV_FILIAL = %exp:cFilSRV% )  OR 		//RETENCION EN LA FUENTE RETENCION CONTINGENTE
       			RD_PD IN (SELECT RV_COD FROM  %table:SRV% WHERE RV_CODFOL='1348' AND RV_FILIAL = %exp:cFilSRV% )) AND //Retencion en la Fuente Sin Aportacion Voluntaria
       			RD_PD=RV_COD 									AND
	 	    	SRD.D_E_L_E_T_ = ' '							AND
				SRA.D_E_L_E_T_ = ' '  							AND
				SRV.D_E_L_E_T_ = ' ' 							AND
				RV_FILIAL = %exp:cFilSRV%
      	GROUP BY RD_FILIAL,RD_CC, RD_MAT, RD_PD, RA_NOME, RV_CODFOL
		ORDER BY %exp:cOrdem%
	EndSql
	/*  Prepara relatorio para executar a query gerada pelo Embedded SQL passando como
	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados
	pela funcao MakeSqlExpr para serem adicionados a query 	*/
	END REPORT QUERY oSection PARAM mv_par01, mv_par02, mv_par03, mv_par04,mv_par07,mv_par08,mv_par09,mv_par10
	Count to nTotalR  	// obtiene el total de registros

#ENDIF

 //-- Condici�n de impresi�n del Empleado
fGP16COLCond(cAliasQry, oReport)
oReport:SetMeter(100)

//��������������������������������������������������������������Ŀ
//� Termino do Relatorio                                         �
//����������������������������������������������������������������
#IFNDEF TOP
	dbSelectArea( "SRD" )
	Set Filter to
	dbSetOrder(1)
	Set Device To Screen
#ENDIF

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fGP16COLCond  � Autor � Alfredo Medrano  � Data �30/10/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica condici�n para impresi�n de la l�nea del Reporte  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPER016COL - Colombia                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fGP16COLCond(cAliasQry, oReport)
Local lRet	   := .T.
Local nCTT		:= RETORDEM("CTT","CTT_FILIAL+CTT_CUSTO") // regresa el �ndice
Local aAreaLoc 	:= getArea()
Local oSection	:= oReport:Section(1)
Local oSection1	:= oReport:Section(1):Section(1)
Local oSection2	:= oReport:Section(1):Section(1):Section(1)
Local cMat		:= ""
Local cCC			:= ""
Local cFilGrp		:= ""
Local nX			:= 0
Private cFil		:= ""
Private cCenC	:= ""
Private cMatri	:= ""
Private cNombre	:= ""
Private cTipoID	:= ""
Private cNumID	:= ""
Default cAliasQry	:= "SRD"


	(cAliasQry )->(DBGOTOP()) // posiciona al primer registro del archivo de datos
	WHILE ( cAliasQry )->(!eof())
		oReport:IncMeter()
		If oReport:Cancel() //termina proceso si se cancela el reporte
			Exit
		EndIf

//����������������������������������������������������������������Ŀ
//�Si el empleado existe varias veces solo se imprimir� una vez 	�
//�	y sus totales por concepto se mostrar�n en la misma fila 		�
//� a menos que �ste cambie de Centro de Costos						�
//�                                        							�
//������������������������������������������������������������������

		nX := nX+1
		If ( cAliasQry )->RD_MAT != cMat .And. cMat!=""
			ImprimeLinea(oSection1,oSection) //imprime l�nea
			oSection1:Finish()//Fin de la seccion1
			oReport:SkipLine()// Salto de l�nea
			AportVol(oSection2,oSection1) //Imprime las portaciones voluntarias del empleado
			oReport:SkipLine()// Salto de l�nea
			//inicializa variables privadas
			nVOLSI		:= 0   	//Apo Vol Si Aplico
			nVOLNO		:= 0   	//Apo Vol No Aplico
			nSINAPO	:= 0	//Ret Fte sin Apo Vol
			nRETCON	:= 0	//Retenci�n Contingente
			nRRETVOL := 0 //Ret. Rest. Voluntarios

		ElseIf  ( cAliasQry )->RD_MAT == cMat .And. cCC!="" .And. ( cAliasQry )->RD_CC != cCC  //Imprime en otra l�nea mismo empleado - diferente Centro de costo
			ImprimeLinea(oSection1,oSection) // imprime L�nea
			//inicializa variables privadas
			nVOLSI		:= 0   	//Apo Vol Si Aplico
			nVOLNO		:= 0   	//Apo Vol No Aplico
			nSINAPO	:= 0	//Ret Fte sin Apo Vol
			nRETCON	:= 0	//Retenci�n Contingente
			nRRETVOL := 0 //Ret. Rest. Voluntarios
		EndIF

		If (cAliasQry)->RV_CODFOL =='1349'//Apo Vol Si Aplico
			nVOLSI := (cAliasQry)->Total
		ElseIf (cAliasQry)->RV_CODFOL =='1346'
			nVOLNO := (cAliasQry)->Total //Apo Vol No Aplico
		ElseIf (cAliasQry)->RV_CODFOL =='0066'
			nRRETVOL := (cAliasQry)->Total //Ret. Rest. Voluntarios
		ElseIf (cAliasQry)->RV_CODFOL =='1348'
			nSINAPO := (cAliasQry)->Total //Ret Fte sin Apo Vol
		ElseIf (cAliasQry)->RV_CODFOL =='1347'
			nRETCON := (cAliasQry)->Total //Retenci�n Contingente
		End
		cDESCRIP 	:= POSICIONE( "CTT", nCTT, XFILIAL("CTT") + (cAliasQry)->RD_CC, "CTT_DESC01" ) //Retorna el centro de costos
		cFil		:= ( cAliasQry )->RD_FILIAL  //Sucursal
		cCenC		:= ( cAliasQry )->RD_CC		//Centro de Costo
		cMatri		:= ( cAliasQry )->RD_MAT		//Matr�cula
		cNombre	:= ( cAliasQry )->RA_NOME	//Nombre
		cTipoID	:= POSICIONE( "SRA", 1, XFILIAL("SRA") + (cAliasQry)->RD_MAT, "RA_TPCIC" ) //Tipo ID
		cNumID	:= POSICIONE( "SRA", 1, XFILIAL("SRA") + (cAliasQry)->RD_MAT, "RA_CIC" )   // NUM ID

		cMat 	 := ( cAliasQry )->RD_MAT //asignamos la matricula
		cCC		 := ( cAliasQry )->RD_CC//asignameos Centro de costos
		cFilGrp := ( cAliasQry )->RD_FILIAL//asignameos Centro de costos

		If nX == nTotalR
			ImprimeLinea(oSection1,oSection)
			oSection1:Finish()
			oReport:SkipLine()
			AportVol(oSection2,oSection1)
			nVOLSI := 0
			nVOLNO := 0
			nSINAPO:= 0
			nRETCON:= 0
			nRRETVOL := 0 //Ret. Rest. Voluntarios
		EndIf

		( cAliasQry )->(dbSkip())
	ENDDO
	oSection:Finish()
	oSection2:Finish()

	( cAliasQry )->(dbCloseArea())
	restArea(aAreaLoc)

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ImprimeLinea()  � Autor � Alfredo Medrano �Data �01/10/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime L�nea para el Reporte                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPER016COL - Colombia                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ImprimeLinea(oSection1, oSection)

	If cFil != ""
		oSection:Init()
		oSection:cell("RD_FILIAL"):Hide()
		oSection:cell("RD_MAT"):Hide()
		oSection:cell("RD_FILIAL"):SetSize(0)
		oSection:cell("RD_MAT"):SetSize(0)
		oSection:cell("RD_FILIAL"):SetValue(cFil )
		oSection:cell("RD_MAT"):SetValue(cMatri )
		oSection:PrintLine()

		oSection1:cell("RD_FILIAL"):SetValue(cFil )
		oSection1:cell("RD_CC"):SetValue(cCenC )
		oSection1:cell("CTT_DESC01"):SetValue(cDESCRIP)
		oSection1:cell("RD_MAT"):SetValue(cMatri )
		oSection1:cell("RA_NOME"):SetValue(cNombre )
		oSection1:cell("RA_TPCIC"):SetValue(cTipoID )  //Tipo ID
		oSection1:cell("RA_CIC"):SetValue(cNumID )  //Num ID
		oSection1:cell("APOVOLSI"):SetValue(nVOLSI)	//Apo Vol Si Aplico
		oSection1:cell("APOVOLNO"):SetValue(nVOLNO)	//Apo Vol No Aplico
		oSection1:cell("RETSINAPO"):SetValue(nSINAPO)	//Ret Fte sin Apo Vol
		oSection1:cell("RETENCON"):SetValue(nRETCON)	//Retenci�n Contingente
		oSection1:cell("RRESTVOL"):SetValue(nRRETVOL) //Ret. Rest. Voluntarios
		oSection1:Init()
		oSection1:PrintLine()
	EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �AportVol � Autor � Alfredo Medrano     �  Data � 01/11/2013 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � �Obtiene Datos de Aportaciones Voluntarias del Empleado    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � AportVol()                                                 ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���			   �		�      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AportVol(oSection2,oSection1)
	Local aDatos  := {}
	Local aArea	   := getArea()
	Local cTmpPer := CriaTrab(Nil,.F.)
	Local cQuery  := ""
	Local nTotal1 := 0
	Local nTotal2 := 0
	Local nTotal3 := 0
	Local nTotal4 := 0
	Local nTotal5 := 0
	Local nValT	   := 0
	Local nValTT    := 0
	
	Local nTApoVol	:= 0
	Local nCoun	    := 0

	cQuery := " SELECT RD_FILIAL,RD_MAT, RD_PD, RD_VALOR, RD_ENTIDAD,RV_CODFOL, RV_DESC"
	CQuery += " FROM " + RetSqlName("SRD") +" SRD, " + RetSqlName("SRV") +" SRV "
 	cQuery += " WHERE "
 	cQuery += " RD_PD = RV_COD "
 	cQuery += " AND RD_FILIAL='"+ cFil +"' " 	//sucursal
    cQuery += " AND RD_MAT='"+ cMatri +"' " 	//Matricula

   	If	!Empty( mv_par07 )
   		cQuery += " AND " + mv_par07  		//Procesos
  	EndIf

  	If	!Empty( mv_par08 )
  		cQuery += " AND " + mv_par08  		//Procedimiento de C�lculo
  	EndIf

  	If	!Empty( mv_par09 )
  		cQuery += " AND " + mv_par09  		//Periodos
  	EndIf

  	If	!Empty( mv_par10 )
  		cQuery += " AND " + mv_par10  		//N�mero de Pago
  	EndIf

  	cQuery += " AND (RD_PD IN (SELECT RV_COD FROM " + RetSqlName("SRV") + " WHERE RV_CODFOL='1344' AND RV_FILIAL = '" + cFilSRV + "') " //Aportaci�n Voluntaria AFC
    cQuery += " OR RD_PD IN (SELECT RV_COD FROM " + RetSqlName("SRV") + " WHERE RV_CODFOL='1345' AND RV_FILIAL = '" + cFilSRV + "') "  //Aportaci�n Voluntaria AFP
    cQuery += " OR RD_PD IN (SELECT RV_COD FROM " + RetSqlName("SRV") + " WHERE RV_CODFOL='1356' AND RV_FILIAL = '" + cFilSRV + "')) "  //Aportaci�n Voluntaria Empresa

  	cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
  	cQuery += " AND SRV.D_E_L_E_T_ = ' ' "
  	cQuery += " AND RV_FILIAL = '" + cFilSRV + "'"

  	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpPer,.T.,.T.)
 	Count to nTApoVol
	(cTmpPer)->(dbgotop())//primer registro de tabla

	nValT := 0
	While  (cTmpPer)->(!EOF())

		IF (cTmpPer)-> RV_CODFOL =='1344'
			nValT += (cTmpPer)->RD_VALOR
		ElseIf  (cTmpPer)-> RV_CODFOL =='1345'
			nValT += (cTmpPer)->RD_VALOR
		ELseIf (cTmpPer)-> RV_CODFOL =='1356'
			nValT += (cTmpPer)->RD_VALOR
		EndIf

		(cTmpPer)-> (dbskip())
	EndDo

	(cTmpPer)->(dbgotop())//primer registro de tabla

	While  (cTmpPer)->(!EOF())
		nCoun := nCoun + 1

		//toma los totales para realizar el calculo de las aportaciones Voluntarias
		nVOLSI   :=oSection1:GetFunction("oTFil"):SectionValue()	//Apo Vol Si Aplico
		nVOLNO   :=oSection1:GetFunction("oTFil2"):SectionValue()	//Apo Vol No Aplico
		nSINAPO  :=oSection1:GetFunction("oTFil3"):SectionValue()	//Ret Fte sin Apo Vol
		nRETCON  :=oSection1:GetFunction("oTFil4"):SectionValue()	//Retenci�n Contingente
		nRRETVOL :=oSection1:GetFunction("oTFil5"):SectionValue()	//Ret. Rest. Voluntarios

		IF (cTmpPer)-> RV_CODFOL =='1344'
			nValTT := (cTmpPer)->RD_VALOR
		ElseIf  (cTmpPer)-> RV_CODFOL =='1345'
			nValTT := (cTmpPer)->RD_VALOR
		ELseIf (cTmpPer)-> RV_CODFOL =='1356'
			nValTT := (cTmpPer)->RD_VALOR
		EndIf

		nTotal1 := ( ( ( nValT ) / nVOLSI  ) * nValTT )
		nTotal2 := ( ( ( nValT ) / nVOLNO  ) * nValTT )
		nTotal3 := ( ( ( nValT ) / nSINAPO ) * nValTT )
		nTotal4 := ( ( ( nValT ) / nRETCON ) * nValTT )
		nTotal5 := ( ( ( nValT ) / nRRETVOL) * nValTT )

		oSection2:cell("DET1" ):SetValue( space(TamSX3("RD_FILIAL")[1]))
		oSection2:cell("DET2" ):SetValue( (cTmpPer)->RD_PD)
		oSection2:cell("DET3" ):SetValue( (cTmpPer)->RV_DESC )
		oSection2:cell("DET12"):SetValue( space(TamSX3("RA_TPCIC")[1]))
		oSection2:cell("DET13"):SetValue( space(TamSX3("RA_CIC")[1]	))
		oSection2:cell("DET14"):SetValue( space(TamSX3("RD_MAT")[1]	))
		oSection2:cell("DET4" ):SetValue( TRANSFORM((cTmpPer)->RD_VALOR, "@E 99,999,999,999.99")  )
		oSection2:cell("DET6" ):SetValue( TRANSFORM(nTotal1, "@E 99,999,999,999.99") )
		oSection2:cell("DET7" ):SetValue( TRANSFORM(nTotal2, "@E 99,999,999,999.99") )
		oSection2:cell("DET11"):SetValue( TRANSFORM(nTotal5, "@E 99,999,999,999.99") ) //Ret. Rest Voluntarios
		oSection2:cell("DET8" ):SetValue( TRANSFORM(nTotal3, "@E 99,999,999,999.99") )
		oSection2:cell("DET9" ):SetValue( TRANSFORM(nTotal4, "@E 99,999,999,999.99") )
		oSection2:cell("DET10"):SetValue( (cTmpPer)->RD_ENTIDAD)

		oSection2:Init()
		oSection2:PrintLine()

		(cTmpPer)-> (dbskip())
	EndDo
	(cTmpPer)->( dbCloseArea())
	restArea(aArea)

Return aDatos
