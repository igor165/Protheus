#Include "PROTHEUS.Ch"
#Include "FATA750.ch"                                                                                                                                                       
#include "TbiConn.ch" 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n   � FATA750  � Autor � alfredo.medrano     � Data �  22/04/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � env�a documentos de salida                                 ���
���          �(facturas, notas de cargo y cr�dito), de forma masiva.      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FATA750()                                                  ���
�������������������������������������������������������������������������Ĵ��	
��� Uso      � Filtrar y seleccionar los documentos de salida             ���
���          � para imprimir en PDF o enviar por correo.                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��	
���Programador   �   Data   � BOPS/FNC  �  Motivo da Alteracao            ���
�������������������������������������������������������������������������Ĵ��
���Oscar Garcia  �28/05/2018�DMINA-2961 �Se realizan cambio de validaci�n ���
���              �          �           �antes de env�o masivo de CFDi    ���
���gSantacruz    �23/10/2018�DMINA-4638 �El codigo de tienda a visualizar ���
���              �          �           �segun el cliente seleeccionado   ���
���              �          �           �en la consulta estandar	      ���
���Marco A. Glez.�18/05/2021�DMINA-12136�Se modifica la funcion FT750MAIL,���
���              �          �           �para el uso correcto de la clase ���
���              �          �           �TMailManager. (MEX)              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function FATA750()

//PARA EL DIALOG
Private 	 aPosObj   	:= {}
Private 	 aObjects  	:= {}
Private 	 aSize     	:= {}
Private 	 aInfo      := {}
Private 	 aLogErro	:= {}
Private 	 aListBox 	:= {}
Private 	 lChk01		:= .F.
Private 	 lChk02		:= .F.
Private 	 oListBox 	
Private 	 oDlg 

FTA750DOC()

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � FTA750DC � Autor � Alfredo Medrano       � Data �22/04/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Muestra Pantalla para la selecci�nn y envio del CFID       ���
���          � por correo.                                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FTA750DC()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FTA750DC                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FTA750DOC()   

Local oDatBus 
Local oBtnMarcTod  //Marcar, desmarcar, invertir
Local oBtnDesmTod
Local oBtnInverte
Local oChk01
Local oChk02
Local oBtnEjec
Local oCmbTip
Local lEnd 		:= .T.
// Visualiza un mensaje de Espera para el llenado de los campos
Local bBtnEjec	:={|| MsgRun(OemToAnsi(STR0012), OemToAnsi(STR0020),{|| CursorWait(),FTA750CON(@lEnd,cCmbTip) ,CursorArrow()})} //"Favor de Aguardar....." // "Filtrando Documentos"
Local bActiva	:={||lActiva:=(if 	((len(oListBox:aarray )>0 .and. !empty(oListBox:aarray[1,2]) ), .t.,.f.))} 
Local bMarcTod 	:={||(MarcProd( oListBox , @aListBox , @oDlg , "M" ),oListBox:nColPos := 1,oListBox:Refresh())}
Local bDesmTod 	:={||(MarcProd( oListBox , @aListBox , @oDlg , "D" ),oListBox:nColPos := 1,oListBox:Refresh())}
Local bInverte 	:={||(MarcProd( oListBox , @aListBox , @oDlg , "I" ),oListBox:nColPos := 1,oListBox:Refresh())}
Local bOrdenLst	:={||if 	((len(oListBox:aarray )>0 .and. !empty(oListBox:aarray[1,2]) ),FT750Ordena(),OemToAnsi(STR0002))} //"Para usar esta opci�n debe haber datos en la lista"
Local bBuscar	:={||FT750Busca()}
Local cTClient	:= "SA1" 
Local iSA1		:= 1 //A1_FILIAL+A1_COD+A1_LOJA  
Local aOrdenBuscar:={OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008),OemToAnsi(STR0009),OemToAnsi(STR0010)} //"Factura","Serie","Especie","Fecha Emis","Loja","Cliente","Nombre"
Local aTipDc 	:= {} 
//BOTONES
Local	 bAsigna	:= {||Processa( {|lEnd| FTA750ASG(@lEnd)},  OemToAnsi(STR0012),OemToAnsi(STR0021), .T. )} //"Favor de Aguardar....." //"Procesando."
Local 	 bCancela	:= {|| oDlg:End()} 
Local 	 aObjects 	:= {}
Local 	 oSButton2

Private aHeader		:= aClone(aOrdenBuscar)//"Factura","Serie","Especie","Fecha Emis","Loja","Cliente","Nombre"
Private cDatBus		:= space(15)
Private oOk    		:= LoadBitmap( GetResources(), "LBOK" ) //cargar imagenes del repositiorio
Private oNo			:= LoadBitmap( GetResources(), "LBNO" ) 
Private aButtons	:= {} 
Private cOrden		:=''   
Private cDClient	:= space(TamSX3("A1_COD")[1])
Private cAClient	:= space(TamSX3("A1_COD")[1])
Private cLoja1		:= space(TamSX3("A1_LOJA")[1])
Private cLoja2 		:= space(TamSX3("A1_LOJA")[1])
Private dFechaI		:= Ctod(" / / ")
Private dFechaF		:= Ctod(" / / ")
Private cCmbTip		:= ""

AADD(aListBox,{.F. , "","","","","","","",""})
CURSORWAIT()
/*
  �������������������������������������������������Ŀ
  �Prepara botones de la barra de herramientas      �
  ��������������������������������������������������� /*/
aAdd(aButtons, {'PMSRRFSH' , bOrdenLst,OemToAnsi(STR0017),OemToAnsi(STR0018)}) //"Ordenar los datos","Ordenar"

//��������������������������������������������������������Ŀ
//� Hace  calculo automatico de dimenciones de objetos     �
//����������������������������������������������������������
aSize :=MsAdvSize()
		aSize := MsAdvSize()
		AAdd( aObjects, { 20, 20, .T., .T. } )      
		AAdd( aObjects, { 70, 70, .T., .T. } )//VENTANA DEL LISTBOX
		AAdd( aObjects, { 10,10, .T., .T. } )
aInfo	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj	:= MsObjSize( aInfo, aObjects,.T.)  
//genera un registro en blanco en oListBox                          
 
aTipDc := {"",OemToAnsi(STR0022), OemToAnsi(STR0023), OemToAnsi(STR0024)}// "Facturas o NCA", "Notas de Cr�dito", "Ambas"
                 
CURSORARROW()	 
                
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL //"Env�o masivo de CFDI"

	oGroup2	:= tGroup():New( aPosObj[1,1], aPosObj[1,2], aPosObj[1,3] + 17, aPosObj[1,4], OemToAnsi(STR0025), oDlg,, CLR_WHITE, .T.)	//"Filtro"
	 
	oSay	:= tSay():New(aPosObj[1,1]	 + 18, aPosObj[1,2] + 10,	{||OemToAnsi(STR0026)},oDlg,,,,,,.T.		) 			// "Del Cliente"		
	@ aPosObj[1,1] + 15, aPosObj[1,2]	 + 45   MSGET	cDClient	  SIZE 060,10 OF oDlg  F3 cTClient  PIXEL HASBUTTON	
	
	oSay	:= tSay():New(	aPosObj[1,1] + 18, aPosObj[1,2] + 145,	{||OemToAnsi(STR0027)},oDlg,,,,,,.T.	) 			// "De Tienda"		
	@ aPosObj[1,1] + 15, 	aPosObj[1,2] + 180	MSGET	cLoja1  SIZE 060,10 WHEN .f. OF oDlg   PIXEL 	// Llena el MSGET con el Codigo de la Tienda
	@ aPosObj[1,1] + 15, 	aPosObj[1,2] + 250	MSGET	IIF(!Empty(cDClient),POSICIONE("SA1",iSA1,XFILIAL("SA1")+cDClient+cLoja1,"A1_NOME"),"")  SIZE 180,10 WHEN .f. OF oDlg   PIXEL 	// Llena el MSGET con la descripci�n de la Cliente
	
	oSay	:= tSay():New(	aPosObj[1,1] + 40, aPosObj[1,2] + 10,	{||OemToAnsi(STR0028)},oDlg,,,,,,.T.	) 			// "Al Cliente"		
	@ aPosObj[1,1] + 37, 	aPosObj[1,2] + 45	MSGET	cAClient	  SIZE 060,10 OF oDlg  F3 cTClient  PIXEL HASBUTTON
	
	oSay	:= tSay():New(	aPosObj[1,1] + 40, aPosObj[1,2] + 145,	{||OemToAnsi(STR0029)},oDlg,,,,,,.T.	) 			// "De Tienda"		
	@ aPosObj[1,1] + 37, 	aPosObj[1,2] + 180  	MSGET	cLoja2  SIZE 060,10 WHEN .f. OF oDlg   PIXEL 	// Llena el MSGET con el Codigo de la Tienda
	@ aPosObj[1,1] + 37, 	aPosObj[1,2] + 250  	MSGET	IIF(!Empty(cAClient),POSICIONE("SA1",iSA1,XFILIAL("SA1")+cAClient+cLoja2,"A1_NOME"),"")  SIZE 180,10 WHEN .f. OF oDlg   PIXEL 	// Llena el MSGET con la descripci�n de la Cliente
	
	oSay	:= tSay():New(	aPosObj[1,1] + 62, aPosObj[1,2] + 10,	{||OemToAnsi(STR0030)},oDlg,,,,,,.T.) 			// "Fecha Inicial"	
	@ aPosObj[1,1] + 59, 	aPosObj[1,2] + 45	MSGET 	 dFechaI  PICTURE "@D" WHEN .T. SIZE 060,10 OF oDlg  PIXEL HASBUTTON	
	
	oSay	:= tSay():New(	aPosObj[1,1] + 62, aPosObj[1,2] + 140,	{||OemToAnsi(STR0031)},oDlg,,,,,,.T.	) 			// "Fecha Final"				
	@ aPosObj[1,1] + 59, 	aPosObj[1,2] + 180	MSGET 	 dFechaF  PICTURE "@D" WHEN .T. SIZE 060,10 OF oDlg  PIXEL HASBUTTON	

	oSay	:= tSay():New(	aPosObj[1,1] + 62, aPosObj[1,2] + 250,	{||OemToAnsi(STR0032)},oDlg,,,,,,.T.	) 			// "Tipo de docto"	
	oCmbTip:= tComboBox():New(aPosObj[1,1] + 62, aPosObj[1,2] + 295,{|u|if(PCount()>0,cCmbTip:=u,cCmbTip)},aTipDc ,80,20,oDlg,,/*{||obtFuncion(cCmbTip, @oCmbFun:aitems)}*/,,,,.T.,,,,,,,,,'cCmbTip')  //"Tipo de docto"
	
	oChk01 := TCheckBox():New(aPosObj[1,1] + 62, aPosObj[1,2] + 390, OemToAnsi(STR0033),{|| lChk01 },oDlg,50,10,,,,,,,,.T.,,,) // "Generar PDF"
	oChk01:bLClicked := {|| ChgChk(1) }
	oChk02 := TCheckBox():New(aPosObj[1,1] + 62, aPosObj[1,2] + 450, OemToAnsi(STR0034),{|| lChk02 },oDlg,50,10,,,,,,,,.T.,,,) //"Enviar PDF"
	oChk02:bLClicked := {|| ChgChk(2) }
	
	oBtnEjec :=	tButton():New( 	aPosObj[1,1] + 15, 	aPosObj[1,2] + 480, OemToAnsi(STR0035) ,oGroup2, bBtnEjec, 58, 13.50  ,,,.F.,.T.,.F.,,.F.,,,.F. )	 //"Ejecutar Filtro"
		
	aEval:= bActiva		
	oBtnMarcTod	:=	tButton():New( 	aPosObj[1,1]+100,368, OemToAnsi(STR0013) ,, bMarcTod, 58, 13.50  ,,,.F.,.T.,.F.,,.F.,bActiva,,.F. )	 //"Marca todo - <F4>"
	oBtnDesmTod	:=	tButton():New( 	aPosObj[1,1]+100,432, OemToAnsi(STR0014) ,, bDesmTod, 58, 13.50  ,,,.F.,.T.,.F.,,.F.,bActiva,,.F. )	 //"Desmarca todo - <F5>"
	oBtnInverte	:=	tButton():New( 	aPosObj[1,1]+100,497, OemToAnsi(STR0015) ,, bInverte, 58, 13.50  ,,,.F.,.T.,.F.,,.F.,bActiva,,.F. ) 	//"Inv. seleccion - <F6>"
	oComboBus	:=	tComboBox():New(aPosObj[1,1] + 85,05,{|u|if(PCount()>0,cOrden:=u,cOrden)},;
				          aOrdenBuscar,98,09,NIL,,NIL,,,,.T.,,,,bActiva,,,,,OemToAnsi(STR0011))  //"Ordenar"
	@ aPosObj[1,1] + 100, 	aPosObj[1,2]  MSGET cDatBus 	 WHEN lActiva	SIZE  150,09  OF oDatBus PIXEL 		
	oSButton2 := tButton():New(aPosObj[1,1] + 85, 105, OemToAnsi(STR0003), Nil, bBuscar, 48, 12.05 ,,,.F.,.T.,.F.,,.F.,bActiva,,.F. )	//"Buscar"
	
	@ aPosObj[1,1]+120,aPosObj[1,2] LISTBOX oListBox FIELDS HEADER "",aHeader[1],aHeader[2],aHeader[3],aHeader[4],aHeader[5],aHeader[6],aHeader[7];
	  SIZE aPosObj[2][4], aPosObj[2][3]-90 PIXEL ON DBLCLICK (MarcProd(oListBox,@aListBox,@oDlg),oListBox:nColPos := 1,oListBox:Refresh())  //NOSCROLL 
	
	oListBox:SetArray( aListBox )
	oListBox:bLine := { || {IF(	aListBox[oListBox:nAt,1],oOk,oNo),;	
								aListBox[oListBox:nAt,2],;
								aListBox[oListBox:nAt,3],;
								aListBox[oListBox:nAt,4],;
								aListBox[oListBox:nAt,5],;
								aListBox[oListBox:nAt,6],;
								aListBox[oListBox:nAt,7],;
								aListBox[oListBox:nAt,8]}}
    oListBox:Refresh()
    
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bAsigna,bCancela,,aButtons)

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �FTA750CON � Autor � Alfredo Medrano       � Data �24/04/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica Tipo de Documento y filtra los datos              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FTA750CON(@lExp01, cExp02)                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FTA750DC                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� @lExp01 = Retorno notifica errores						  ���
���          � @cExp02 = Tipo de documento        						  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FTA750CON(lRet,cTip)
Default lRet := .T.

IF Empty(cAClient)
	Aviso( OemToAnsi(STR0036),OemToAnsi(STR0037), {OemToAnsi(STR0038)} ) //--- Aviso // "No se encontraron archivos con los Filtros seleccionados" // "Ok" 
	Return .F.
EndIf
IF Empty(dFechaF)
	Aviso( OemToAnsi(STR0036),OemToAnsi(STR0039), {OemToAnsi(STR0038)} ) //--- Aviso // "Seleccione la Fecha Final" // "Ok"
	Return .F.
Else
	If dFechaI > dFechaF
		Aviso( OemToAnsi(STR0036),OemToAnsi(STR0040), {OemToAnsi(STR0038)} ) //--- Aviso // "La Fecha Final debe ser Mayor o Igual a la Fecha Inicial" // "Ok"
	Return .F.
	EndIf
EndIf
If Empty(cCmbTip)
	Aviso( OemToAnsi(STR0036),OemToAnsi(STR0041), {OemToAnsi(STR0038)} ) //--- Aviso // "Seleccione el Tipo de Docto." // "Ok"
	Return .F.
EndIf

	aListBox:= {} 					// limpia el Array
	If cTip == OemToAnsi(STR0022)	//"Facturas o NCA"
		FTA750CF2() 				//Filtra los registros de la tabla SF2
	ElseIf cTip==OemToAnsi(STR0023)//"Notas de Cr�dito"
		FTA750CF1()					//Filtra los registros de la tabla SF1
	ElseIf cTip==OemToAnsi(STR0024)	//"Ambas"
									//Filtra ambas tablas SF1 y SF2
		FTA750CF1()
		FTA750CF2()
	EndIf

If Len(aListBox) == 0
	Aviso( OemToAnsi(STR0036),OemToAnsi(STR0042), {OemToAnsi(STR0038)} ) //--- Aviso // "No se encontraron archivos con los Filtros seleccionados" // "Ok" 
	
	aListBox:= {} 	// limpia el Array
	AADD(aListBox,{.F. , "","","","","","","",""})
	oListBox:SetArray( aListBox )
	oListBox:bLine := { || {IF(	aListBox[oListBox:nAt,1],oOk,oNo),;	
								aListBox[oListBox:nAt,2],;	
								aListBox[oListBox:nAt,3],;
								aListBox[oListBox:nAt,4],;
								aListBox[oListBox:nAt,5],;
								aListBox[oListBox:nAt,6],;
								aListBox[oListBox:nAt,7],;
								aListBox[oListBox:nAt,8]}}  
    oListBox:Refresh() 	
	Return .F.
	
Else
	
	oListBox:SetArray( aListBox )
	oListBox:bLine := { || {IF(	aListBox[oListBox:nAt,1],oOk,oNo),;	
								aListBox[oListBox:nAt,2],;	
								aListBox[oListBox:nAt,3],;
								aListBox[oListBox:nAt,4],;
								aListBox[oListBox:nAt,5],;
								aListBox[oListBox:nAt,6],;
								aListBox[oListBox:nAt,7],;
								aListBox[oListBox:nAt,8]}}  
    oListBox:Refresh() 	
	
EndIf

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �FTA750CF1 � Autor � Alfredo Medrano       � Data �23/04/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Filtra los registros de la tabla SF1 llena Array que       ���
���          � ser� cargado en el ListBox.                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FTA750CF1()                                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FTA750DOC                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FTA750CF1()

Local 	aArea		:= getArea() 
Local	cTmpPer		:= CriaTrab(Nil,.F.)
Local 	lBan		:= .T.    
Local   cQuery		:= ""
Local   cSDoc		:= SerieNFID("SF1", 3, "F1_SERIE")
Local	cSerRea		:= ""	 
Local   cFilSF1		:= XFILIAL("SF1")
Local 	cFilSA1		:= XFILIAL("SA1")
Local 	cMVCFDiNCC	:= StrQryIn( SuperGetmv( "MV_CFDINCC" , .F. , "NCC" ) )	// "NDP/NCC" // NCC clientes

	//Bruno Cremaschi - Projeto chave �nica.
	cQuery := " SELECT 	F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,F1_ESPECIE,F1_EMISSAO, A1_NOME, A1_EMAIL "
	if !(cSDoc == "F1_SERIE")
		cQuery += ", " + cSDoc
	endIf
	cQuery += " FROM 	" + RetSqlName("SF1") + " SF1 , " + RetSqlName("SA1") + " SA1"
	cQuery += " WHERE	F1_FORNECE = A1_COD AND F1_LOJA=A1_LOJA"
	cQuery += " AND 	F1_ESPECIE IN (" + cMVCFDiNCC + ")" 		//Codigos de Especie
	cQuery += " AND 	F1_FORNECE BETWEEN 	'"+ cDClient +"' AND '"+ cAClient +"' " 	//De Cliente 
	cQuery += " AND 	F1_LOJA BETWEEN 	'"+ cLoja1 +"' AND '"+ cLoja2 +"' "
	cQuery += " AND 	F1_EMISSAO BETWEEN 	'"+ DTOS(dFechaI) +"' AND '"+ DTOS(dFechaF) +"' " 	//De Fecha
	cQuery += " AND 	F1_TIMBRE  		<> ''"
	cQuery += " AND 	F1_FILIAL 		= 	'" + cFilSF1 + "'"
	cQuery += " AND 	A1_FILIAL  		= 	'" + cFilSA1 +"'"
	cQuery += " AND 	SF1.D_E_L_E_T_ 	= ' ' "
	cQuery += " AND 	SA1.D_E_L_E_T_ 	= ' ' "

  	cQuery := ChangeQuery(cQuery)   	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpPer,.T.,.T.)
	TCSetField(cTmpPer,"F1_EMISSAO","D",8,0) // Formato de fecha 
	(cTmpPer)->(dbgotop())//primer registro de tabla

	If (cTmpPer)->(!EOF())
	    While  (cTmpPer)->(!EOF())	
	    	
	    	cSerRea := (cTmpPer)->&cSDOC
	    
			AADD(aListBox,{lBan,;	
	      		(cTmpPer)->F1_DOC,;  
	         	cSerRea,;   
	          	(cTmpPer)->F1_ESPECIE,;                         
	          	(cTmpPer)->F1_EMISSAO,;
	          	(cTmpPer)->F1_LOJA,;
	         	(cTmpPer)->F1_FORNECE,;
	         	(cTmpPer)->A1_NOME,;
	         	(cTmpPer)->A1_EMAIL,;
	         	(cTmpPer)->F1_SERIE})
			(cTmpPer)-> (dbskip())	 		
		EndDo
	EndIf
	(cTmpPer)->( dbCloseArea())
	restArea(aArea)
	 
return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �FTA750CF2 � Autor � Alfredo Medrano       � Data �24/04/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Filtra los registros de la tabla SF2 llena Array que       ���
���          � ser� cargado en el ListBox.                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FTA750CF2()                                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FTA750DOC                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FTA750CF2()

Local 	aArea		:= getArea()        
Local	cTmpPer		:= CriaTrab(Nil,.F.)
Local	cQuery		:= ""
Local	cSDoc		:= SerieNFID("SF2", 3, "F2_SERIE")
Local	cSerRea		:= ""
Local	cFilSF2		:= XFILIAL("SF2")
Local	cFilSA1		:= XFILIAL("SA1")  
Local	lBan		:= .T.
Local   cMVCFDiNFC  := StrQryIn( SuperGetmv( "MV_CFDINFC" , .F. , "NF /NDC" ) )	// "NF /NDC/NCP" // NF, ND clientes

	//Bruno Cremaschi
	cQuery := " SELECT 	F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA,F2_ESPECIE,F2_EMISSAO, A1_NOME, A1_EMAIL " 
	if !(cSDoc == "F2_SERIE")
		cQuery += ", " + cSDoc
	endIf
	cQuery += " FROM 	" + RetSqlName("SF2") + " SF2 , " + RetSqlName("SA1") + " SA1"
	cQuery += " WHERE	F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA"
	cQuery += " AND 	F2_ESPECIE IN (" + cMVCFDiNFC + ")" 		//Codigos de Especie
	cQuery += " AND 	F2_CLIENTE BETWEEN 	'"+ cDClient +"' AND '"+ cAClient +"' " 			//De Cliente
	cQuery += " AND 	F2_LOJA BETWEEN 	'"+ cLoja1 +"' AND '"+ cLoja2 +"' " 			
	cQuery += " AND 	F2_EMISSAO BETWEEN 	'"+ DTOS(dFechaI) +"' AND '"+ DTOS(dFechaF) +"' " //De Fecha
	cQuery += " AND 	F2_TIMBRE  		<> ''"
	cQuery += " AND 	F2_FILIAL 		= 	'" + cFilSF2 + "'"
	cQuery += " AND 	A1_FILIAL  		= 	'" + cFilSA1 +"'"
	cQuery += " AND 	SF2.D_E_L_E_T_ 	= ' ' "
	cQuery += " AND 	SA1.D_E_L_E_T_ 	= ' ' "

  	cQuery := ChangeQuery(cQuery)   	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpPer,.T.,.T.)
	TCSetField(cTmpPer,"F2_EMISSAO","D",8,0) // Formato de fecha 
	(cTmpPer)->(dbgotop())//primer registro de tabla

	If (cTmpPer)->(!EOF())
	    While  (cTmpPer)->(!EOF())	
	    
	    	cSerRea := (cTmpPer)->&cSDOC
	    	
			AADD(aListBox,{lBan,;	
	      		(cTmpPer)->F2_DOC,;  
	         	cSerRea,;   
	          	(cTmpPer)->F2_ESPECIE,;                         
	          	(cTmpPer)->F2_EMISSAO,;
	          	(cTmpPer)->F2_LOJA,;
	         	(cTmpPer)->F2_CLIENTE,;
	         	(cTmpPer)->A1_NOME,;
	         	(cTmpPer)->A1_EMAIL,;
	         	(cTmpPer)->F2_SERIE })
			(cTmpPer)-> (dbskip())	 		
		EndDo
	EndIf
	(cTmpPer)->( dbCloseArea())
	restArea(aArea)
	 
return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � FTA750ASG� Autor � Alfredo Medrano       � Data �25/04/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Proceso de Generacion de PDF y envio por Email de Doctos.  ���
���          � de salida (facturas, notas de cargo y cr�dito).            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FTA750ASG()                                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FTA750DOC                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FTA750ASG()
Local aArea		:= getArea()  
Local lRet 		:= .T.
Local nVacio 	:= 0
Local nI		:= 0
Local cNameCFDI	:= ""
Local cCliente	:= ""
Local cLoja		:= ""
Local cNumFac	:= ""
Local cSerie	:= ""
Local cEspecie	:= ""
Local cEmail	:= ""
Local cNCFDIpdf	:= ""
Local aAttach	:= {}
Local nNumReg	:= Len(oListBox:aarray)
Local cRUTASRV 	:= &(SuperGetmv( "MV_CFDDOCS" , .F. , "cfd\facturas\" ))	// Ruta donde se encuentran las facturas.xml (servidor)
Local cCFDiNF	:= SuperGetmv( "MV_CFDINF" , .F. , "" )						// Rutina de impresion del CFDi - NF 
Local cCFDiNC 	:= SuperGetmv( "MV_CFDINC" , .F. , "" )						// Rutina de impresion del CFDi - NCC 
Local lErr		:= .T.
Local ctrErr	:= ""
Local nEnv		:= 0
Local nGePDF	:= 0
Local cMsgErr	:= ""
Local nCont		:= 0

DbSelectArea("SA1") // catalogo de Clientes
aLogErro := {}
//Valida que el ListBox contenga datos
If nNumReg > 0 
	//Si solo es un rengl�n valida que no este vac�o 
	If  nNumReg == 1 .AND. empty(oListBox:aarray[1,2]) .AND. empty(oListBox:aarray[1,3]) .AND.;
		empty(oListBox:aarray[1,4]) .AND. empty(oListBox:aarray[1,5]) .AND. empty(oListBox:aarray[1,6]) .AND. empty(oListBox:aarray[1,7])
	
		Aviso( OemToAnsi(STR0036),OemToAnsi(STR0043), {OemToAnsi(STR0038)} ) //--- Aviso // "No hay Documentos para procesar" // "Ok"
		Return .F.
	EndIf
	// valida que por lo menos haya un documento seleccionado.
	nVacio := aScan(oListBox:aarray,{|x| x[1] == .T.})
	If nVacio == 0
		Aviso( OemToAnsi(STR0036),OemToAnsi(STR0044), {OemToAnsi(STR0038)} ) //--- Aviso // "Seleccione por lo menos un documento." // "Ok"
		Return  .F.
	EndIf
	
	//Env�a mensaje si no esta seleccionado alguno de los CheckBox
	If !lChk01 .AND. !lChk02
		Aviso( OemToAnsi(STR0036),OemToAnsi(STR0053) + OemToAnsi(STR0033) + OemToAnsi(STR0054) + OemToAnsi(STR0034)  , {OemToAnsi(STR0038)} ) //--- Aviso // "Seleccione una de las opciones: " // "Generar PDF" + "o" + "Enviar PDF" // "Ok"
		Return  .F.
	EndIF
		
	For nI := 1 To nNumReg
		If !empty(oListBox:aarray[nI,1]) //si esta seleccionado
			nCont = nCont + 1
			IncProc() 	
			cNumFac		:= oListBox:aarray[nI,2]// Numero Factura 	
			cSerie		:= oListBox:aarray[nI,10]// Serie
			cEspecie	:= oListBox:aarray[nI,4]// especie
			cLoja		:= oListBox:aarray[nI,6]// Loja
			cCliente	:= oListBox:aarray[nI,7]// Cliente
			//Nombre de la factura
			cNameCFDI := Lower( Alltrim(cEspecie) + "_" + Alltrim(SubStr(cSerie,1,3)) + "_" + Alltrim(cNumFac) + ".xml" )	//Nombre documento XML
			cNCFDIpdf := Lower( Alltrim(cEspecie) + "_" + Alltrim(SubStr(cSerie,1,3)) + "_" + Alltrim(cNumFac) + ".pdf" )	//Nombre documento PDF
			//Validar si el archivo xml existe
			If !File(cRUTASRV+cNameCFDI)
				aAdd(aLogErro, {OemToAnsi(STR0045) + cNameCFDI + OemToAnsi(STR0046)}) //"Archivo XML " + cNameCFDI + " no encontrado... "		
			Else
				//Impresi�n del CFDi en PDF por cada documento seleccionado
				If Trim(cEspecie) == "NF" .And. !Empty(cCFDiNF) .And. ExistBlock(cCFDiNF)	//Formato de impresion para Facturas
					ExecBlock( cCFDiNF , .F. , .F. , {cNumFac , cSerie , cEspecie , cCliente , cLoja, Lower( Alltrim(cEspecie) + "_" + Alltrim(SubStr(cSerie,1,3)) + "_" + Alltrim(cNumFac)), cRUTASRV} )
				ElseIf Trim(cEspecie) == "NCC" .And. !Empty(cCFDiNC) .And. ExistBlock(cCFDiNC)	//Formato de impresion para Notas de Credito
					ExecBlock( cCFDiNC, .F. , .F. , {cNumFac , cSerie , cEspecie , cCliente , cLoja, Lower( Alltrim(cEspecie) + "_" + Alltrim(SubStr(cSerie,1,3)) + "_" + Alltrim(cNumFac)), cRUTASRV} )
				Endif
				
				If lChk02
					//Envia Email, aplicara solo si el cliente cuenta con correo electr�nico
					SA1->(DBSETORDER(1))//A1_FILIAL+A1_COD+A1_LOJA	
					If SA1->(MsSeek(XFILIAL('SA1') + cCliente + cLoja ))//Verifica si el cliente cuenta con correo electr�nico
						If 	!EMPTY(SA1->A1_EMAIL)
							cEmail := SA1->A1_EMAIL 
							aAttach	:= {}
							AADD(aAttach, cRUTASRV+cNameCFDI) // Agrega el la ruta y nombre del xml al array
							If File(cRUTASRV+cNCFDIpdf) // verifica que exista PDF y lo agrega al Array
								AADD(aAttach, cRUTASRV+cNCFDIpdf)
							Else// si no encuentra pdf env�a notificaci�n al log
								aAdd(aLogErro, {OemToAnsi(STR0047) + cNCFDIpdf + OemToAnsi(STR0063)  + cCliente + OemToAnsi(STR0065) + cNumFac +  OemToAnsi(STR0062)}) //"El Archivo PDF " + cNCFDIpdf + " del Cliente " cCliente + " para la Factura " + cNumFac " no existe." 
							EndIf
							///ENVIAR CORREO
							If !FT750MAIL(OemToAnsi(STR0055),OemToAnsi(STR0056),cEmail,aAttach,@lErr,@ctrErr)//"Documentos CFDI"//"Se anexan los documentos CFDI"
								// envia mensaje a log si no se envio el correo 
								IF !Empty(ctrErr)
									aAdd(aLogErro, {OemToAnsi(STR0059) + SPACE(1) + ctrErr }) // "Error en el Envio del Email"
								EndIf
								
								aAdd(aLogErro, {OemToAnsi(STR0064) + cEmail + OemToAnsi(STR0063)  + cCliente + OemToAnsi(STR0065) + cNumFac}) //"No se pudo enviar la informaci�n al siguiente Email: " //" del Cliente " + cCliente + " para la Factura " + cNumFac
								If !lErr // hay problemas de conexi�n. termina el proceso.
									EXIT
								EndIf
							Else
								nEnv:= nEnv + 1
							EndIF
						Else
							//si no hay correo env�a notificaci�n al log
				  			 aAdd(aLogErro, {OemToAnsi(STR0060) + space(1) +  cNameCFDI + OemToAnsi(STR0061) + cNCFDIpdf + OemToAnsi(STR0065) + cNumFac + OemToAnsi(STR0048) + CRLF + OemToAnsi(STR0049) + cCliente + OemToAnsi(STR0050)}) //"Los archivos " + cNameCFDI +  " y " + cNCFDIpdf + " para la factura " + cNumFac + " no se pudieron enviar. " + "El Cliente " + cCliente + "no cuenta con un correo electr�nico."
				   		EndIf
				   	EndIf
				Else
				//Solo se genera el PDF
				nGePDF := nGePDF + 1
				EndIF
				
			Endif
		EndIf
	Next
EndIF	

If len(aLogErro)>0
	If lChk02
		cMsgErr += cValToChar(nEnv)+ OemToAnsi(STR0077) + cValToChar(nCont) + CRLF + CRLF //" documentos enviados de "
	End if
	cMsgErr += OemToAnsi(STR0051)//"Factura sin procesar por errores encontrados. �Quiere verificar el LOG?"
	If msgyesno(cMsgErr) 
		ImprimeLog()
	EndIf
ElseIf nEnv > 0
	Aviso( OemToAnsi(STR0036),OemToAnsi(STR0066) + CRLF + cValToChar(nEnv)+ OemToAnsi(STR0077) + cValToChar(nCont), {OemToAnsi(STR0038)} ) //--- Aviso // "Los documentos fueron enviados con �xito!" //" documentos enviados de " // ok
ElseIf nGePDF > 0
	Aviso( OemToAnsi(STR0036),OemToAnsi(STR0068), {OemToAnsi(STR0038)} ) //--- Aviso // "Documentos procesados con �xito!" // ok
EndIf
	
restArea(aArea)
Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FT750MAIL �       � Alfredo.Medrano       � Data �25/04/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envio de correo                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FT750MAIL(cPar01,cPar02,cPar03,aPar04,lPar05,cPar06)        ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �cPar01: Descripci�n del asunto                              ���
���          �cPar02: Descripci�n del contenido                           ���
���          �cPar03: Direccion de mail de quien envia                    ���
���          �aPar04: Array con el nombre de los archivos				  ���
���          �lPar05: Notifica error de conexi�n        				  ���
���          �cPar06: Notifica el error                  				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �FTA750ASG                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������/*/     

Static Function FT750MAIL(cAssunto,cMensaje,cEmail,aAttach,lError,cTrErr)
Local oMailServer 	:= Nil
Local cEmailTo   	:= ""
Local cEmailBcc		:= ""
Local cError    	:= ""  
Local cEMailAst 	:= cAssunto
Local oMessage
Local lResult
Local aAnexo		:= {}

// Verifica se serao utilizados os valores padrao.
Local cAccount		:= GetMV( "MV_RELACNT",,"" ) //cuenta dominio
Local cPassword		:= GetMV( "MV_RELPSW",,""  ) //Pass de la cuenta dominio
Local cServer		:= AllTrim(GetMV("MV_RELSERV", , ""))  //smtp del dominio
Local cAttach     	:= ""
Local cFrom   		:= cAccount              
Local lUseSSL     	:= GetMv("MV_RELSSL")        //Define se o envio e recebimento de E-Mail na rotina SPED utilizara conexao segura (SSL);
Local lAuth      	:= GetMv("MV_RELAUTH")       //Servidor de E-Mail necessita de Autenticacao? Determina se o Servidor necessita de Autenticacao;
Local lTls			:= GetMV("MV_RELTLS", , "") //Informe si el servidor de SMTP tiene conexion del tipo segura ( SSL/TLS ).    
Local nX        	:= 0
Local nPort			:= GetMV("MV_RELPORT", , 25) //Define el Puerto que ser� utilizado para el envi� del Email
Local cPortParam	:= ""
Local cSubUrlSrv	:= ""

Default aAttach		:= {} 
Default lError		:= .T.
Default cTrErr		:= ""

cEmailTo	:= cEmail
aAnexo		:= Aclone(aAttach)

IncProc(OemToAnsi(STR0075)) //"Conectando al servidor de correo..."               

If !lAuth
                               
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult
	//Valida si se pudo realizar la conexion a servidor antes de realizar el env�o de correos
	If lResult
		//Se crea una lista de los documentos a adjuntar en el coreo
		For nX:= 1 to Len(aAnexo)
			cAttach += aAnexo[nX] + "; "
		Next nX
		
		SEND MAIL FROM cFrom ;
		TO          	cEmailTo;
		BCC        		cEmailBcc;
		SUBJECT     	Txt2Htm( cEMailAst, cEmail );
		BODY    		Txt2Htm( cMensaje, cEmail );
		ATTACHMENT  	cAttach  ;
		RESULT 			lResult
                                               
       If !lResult
       		//Erro no envio do email
      	 	GET MAIL ERROR cError
       		Help(" ",1,STR0036,,cError,4,5) //--- Aviso
       EndIf

       DISCONNECT SMTP SERVER

    Else
    	//Erro na conexao com o SMTP Server
    	GET MAIL ERROR cError                                       
    	Help(" ",1,STR0036,,cError,4,5) //--- Aviso                                                                              
	EndIf
		DISCONNECT SMTP SERVER
Else

	cPortParam	:= SubStr(cServer, At(":", cServer) + 1, Len(cServer)) //Substrae el puerto del parametro MV_RELSERV
	cSubUrlSrv	:= SubStr(cServer, 1, Len(cServer) - (Len(cPortParam) + 1)) //Substrae la URL del parametro MV_RELSERV
	
	If At(":", cServer) > 0 .And. !(Empty(cPortParam)) //Si hay puerto en el parametro MV_RELSERV
		nPort := Val(cPortParam)
		cServer := cSubUrlSrv
	EndIf
	
     //Instancia o objeto do MailServer
     oMailServer:= TMailManager():New()
     oMailServer:SetUseSSL(lUseSSL)    //Obs: Apenas se servidor de e-mail utiliza autenticacao SSL para envio
     oMailServer:SetUseTLS(lTls)       //Obs: Apenas se servidor de e-mail utiliza autenticacao TLS para recebimento
     oMailServer:Init("",cServer,cAccount,cPassword,0,nPort)  
                               
        //Defini��o do timeout do servidor
     If oMailServer:SetSmtpTimeOut(120) != 0
     	Help(" ",1,STR0036,,OemToAnsi(STR0057) ,4,5) //"Aviso" ## "Tiempo de Servidor"
     	Return .F.
     EndIf

     //Conex�o com servidor
     nErr := oMailServer:smtpConnect()
     If nErr <> 0
     	cTrErr:= oMailServer:getErrorString(nErr)
     	Help(" ",1,STR0036,,ctrErr,4,5) //"Aviso"
     	oMailServer:smtpDisconnect()
     	lError := .F. // Especifica que no hay conexion para parar el proceso de env�o
     	Return .F.
     EndIf
     IncProc(OemToAnsi(STR0067)) //"Enviando Email..."  
                               
     //Autentica��o com servidor smtp
     nErr := oMailServer:smtpAuth(cAccount, cPassword)
     If nErr <> 0
     	cTrErr := oMailServer:getErrorString(nErr)
     	Help(" ",1,STR0036,,OemToAnsi(STR0058) + cTrErr ,4,5)//"Aviso" ## "Autenticaci�n con servidor smtp"
     	oMailServer:smtpDisconnect()
     	return .F.
     EndIf
                               
     //Cria objeto da mensagem+
     oMessage := tMailMessage():new()
     oMessage:clear()
     oMessage:cFrom := cFrom 
     oMessage:cTo := cEmailTo 
     oMessage:cCc := cEmailBcc
     oMessage:cSubject :=  cEMailAst
                
     oMessage:cBody := cEMailAst
     //oMessage:AttachFile(_CAnexo)       						 //Adiciona um anexo, nesse caso a imagem esta no root
                               
     For nX := 1 to Len(aAnexo)
     	oMessage:AddAttHTag("Content-ID: <" + aAnexo[nX] + ">") //Essa tag, � a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
     	oMessage:AttachFile(aAnexo[nX])                       //Adiciona um anexo, nesse caso a imagem esta no root
     Next nX
                               
     //Dispara o email          
     nErr := oMessage:send(oMailServer)
     If nErr <> 0
     	cTrErr := oMailServer:getErrorString(nErr)
     	Help(" ",1,STR0036,,OemToAnsi(STR0059) + cTrErr ,4,5)//"Aviso" ## "Error en el Envio del Email"
     	oMailServer:smtpDisconnect()
     	Return .F.
     Else
     	lResult := .T.
     EndIf

      //Desconecta do servidor
    oMailServer:smtpDisconnect()

EndIf

Return(lResult)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ImprimeLog  � Autor �Alfredo Medrano   � Data � 24/04/2014 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ejecuta rutina para Visualizar/Imprimir log del proceso.   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �      													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 

Static Function ImprimeLog()

Local aReturn	:= {"xxxx", 1, "yyy", 2, 2, 1, "",1 }	//"Zebrado"###"Administra��o"
Local cTamanho	:= "M"
Local cTitulo	:= OemToAnsi(STR0052)   //"Log de Proceso de Documentos de Salida (Facturas, Notas de Cargo y Credito)" 
Local nX		:= 1
Local aNewLog	:= {}
Local nTamLog	:= 0
Local aLogTitle	:={}  
Local aLog		:={}

For nX:=1 to len(aLogErro)                                            
	aadd(aLog,aLogErro[nX,1])
Next

aNewLog		:= aClone(aLog)
nTamLog		:= Len( aLog)
aLog		:= {}

If !Empty( aNewLog )
	aAdd( aLog , aClone( aNewLog ) )
Endif

AADD(aLogTitle,"                                                    ")

MsAguarde( { ||fMakeLog( aLog ,aLogTitle , , .T. , FunName() , cTitulo , cTamanho , "P" , aReturn, .F. )},STR0076) //"Generando Log..."

Return 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MarcProd  � Autor � Alfredo Medrano       � Data �24/04/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funci�n para marcar documentos en el ListBox.              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MarcProd(oExp01,aExp02,oExp03,cExp04)                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FTA750DOC                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� oExp01 = Objeto del ListBox						          ���
���          � aExp02 = Array con los dato del ListBox				      ���
���          � oExp03 = Objeto del Dialog						          ���
���          � cExp04 = Marca "M" "D" "I"						          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MarcProd( oListBox , aListBox , oDlg , cMarckTip )
Local nPos			:= 1 //columa del check
DEFAULT cMarckTip := ""	
IF Empty( cMarckTip )  
	aListBox[ oListBox:nAt , nPos ] := !aListBox[ oListBox:nAt , nPos ]
ElseIF cMarckTip              == "M"
	aEval( aListBox , { |x,y| aListBox[y,nPos] := .T. } )
ElseIF cMarckTip == "D"
	aEval( aListBox , { |x,y| aListBox[y,nPos] := .F. } )
ElseIF cMarckTip == "I"
	aEval( aListBox , { |x,y| aListBox[y,nPos] := !aListBox[y,nPos] } )
EndIF

Return( NIL )

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �FT750Ordena� Autor � Alfredo MEdrano       � Data �25/05/2014���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Selecciona las columnas a ordenar                           ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � FT750Ordena(ExpC1)                                          ���
��������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Numero da opcion selecionada                        ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � MTA459DOC                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static function FT750Ordena(nOpc)  
Local cLinOrdOk		:= "AllwaysTrue()"
Local cTodOrdOk		:= "AllwaysTrue()"
Local odlg3  		:= "AllwaysTrue()"
Local oGetOrdena
Local cFielOrdOk	:= "AllwaysTrue()"     
Local aColsOrdena	:= {}
Local aHeaderOrdena	:= {}
Local oCombo		:= Nil
Local cCombo		:= ''
Local aItems		:= {}
Local nI			:= 0
Local nUsado		:= 3
Local aSelAlt		:= {"COLUM"}  //Columna que permitir� alteraciones

//aHeader del getdados de ORDENAR
Aadd(aHeaderOrdena, { OemToAnsi(STR0069),"ITEM","99",2,0,"AllwaysTrue()" ,CHR(251),"N",'','','' } ) //"Item"
Aadd(aHeaderOrdena, { OemToAnsi(STR0070),"COLUM","999",3,0,"AllwaysTrue()" ,CHR(251),"N",'','','' } )  //"Columna"
Aadd(aHeaderOrdena, { OemToAnsi(STR0071),"CAMPOS","",11,0,"AllwaysTrue()",CHR(251),"C",'','',''} )   //"Campos"

//aCols del getdados ORDENAR
for nI:=1 to len(oListBox:aheaderS)
	Aadd(aColsOrdena,Array(nUsado+1))
	aColsOrdena[Len(aColsOrdena)][1] := nI
	aColsOrdena[Len(aColsOrdena)][2] := 0			
	aColsOrdena[Len(aColsOrdena)][3] :=oListBox:aheaderS[NI]
	aColsOrdena[Len(aColsOrdena)][nUsado+1] := .F.
next

//Items del combobox
aItems:= {OemToAnsi(STR0072),OemToAnsi(STR0073)} //'Descendente','Ascendente'
cCombo:= aItems[1] //Opci�n def<ault del  combobox

DEFINE MSDIALOG oDlg3 TITLE OemToAnsi(STR0074) From c(40),c(10) To c(235),c(300) PIXEL //"Ordenar OP's" 

    oGetOrdena:= MsNewGetDados():New(c(13),c(05),c(85),c(145), 2,cLinOrdOk,cTodOrdOk,nil,aSelAlt, 0, 999,cFielOrdOk,;
                                     "",nil,  oDlg3, aHeaderOrdena, aColsOrdena)   
	oCombo:= tComboBox():New(c(88),c(05),{|u|if(PCount()>0,cCombo:=u,cCombo)},;
	                          aItems,50,20,oDlg3,,nil,,,,.T.,,,,,,,,,'cCombo')     
		                          
ACTIVATE MSDIALOG oDlg3 centered ON INIT EnchoiceBar(oDlg3,{||OrdenaArray(oGetOrdena,oCombo:nat),oDlg3:End()},{||oDlg3:End()},,)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �OrdenaArray       � Alfredo Medrano       � Data �25/04/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ordena las columnas del getdados principal                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � OrdenaArray(ExpO1,ExpN1)                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto, del getdados que indica el orden           ���
���          � ExpN1 = Numerico, indica si el orden es 2-ascen o 1-desc   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FT750Ordena                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������/*/

static function OrdenaArray(oGetOrdena,nSelOrd)  

Local nI	:= 0
Local ctipo	:= ''
Local cStrX	:= ''
Local cStrY	:= ''    
Local cOper	:= ''

Cursorwait()                
	oGetOrdena:acols :=aSort(oGetOrdena:acols,,,{|x,y| x[2] <= y[2]})
	if nSelOrd==1 //descendente
	   cOper:=' >= '
	else          
	   cOper:=' <= '
	endif
	
	for nI:= 1 to len(oGetOrdena:acols)
	    if oGetOrdena:acols[nI,2]<>0   
	           cTipo:=valtype(oListBox:aarray[1,oGetOrdena:acols[nI,1]])
	           if ctipo=='N'
	               cStrX+="str(x["+alltrim(str(oGetOrdena:acols[nI,1]))+"])+"
	               cStrY+="str(y["+alltrim(str(oGetOrdena:acols[nI,1]))+"])+"
	           else        
	               if cTipo=='D'
					  cStrX+="dtos(x["+alltrim(str(oGetOrdena:acols[nI,1]))+"])+"
	                  cStrY+="dtos(y["+alltrim(str(oGetOrdena:acols[nI,1]))+"])+"		                  
	               else       
	               	  cStrX+="x["+alltrim(str(oGetOrdena:acols[nI,1]))+"]+"
				      cStrY+="y["+alltrim(str(oGetOrdena:acols[nI,1]))+"]+"		                  
	               endif   
	           endif    
	     endif    
	next               
	cStrX:=substr(cStrX,1,len(cStrX)-1)
	cStrY:=substr(cStrY,1,len(cStrY)-1)
	if !empty(cStrX)
	      &("oListBox:aarray := aSort(oListBox:aarray,,,{|x,y| "+cStrX+cOper+cStrY+"})")      
	endif
CursorArrow()
Return    

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FT750Busca � Autor � Alfredo Medrano      � Data �21/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Busca en el ListBox                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FT750Busca		      			                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Ninguno					                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MTA459DOC                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
static function FT750Busca()                   
Local nPosBus:=0     
Local nPos:=oComboBus:nat+1 // posici�n de la columna, indica en d�nde iniciara la busqueda

If valtype(oListBox:aarray[1,nPos])=="C"
	nPosBus:=aScan(oListBox:aarray,{|x| upper(ALLTRIM(x[nPos])) == upper(ALLTRIM(cDatBus))} )
Else
	If !Empty(ctod(cDatBus))
		nPosBus:=aScan(oListBox:aarray,{|x| x[nPos] == ctod(cDatBus)} )
	Else
		nPosBus:=aScan(oListBox:aarray,{|x| x[nPos] == Val(cDatBus) })
	EndIf
EndIf   

If nPosBus >0
	oListBox:nat:=nPosBus
Else 
    msgInfo(OemToAnsi(STR0016)) //"No encontro!"
EndIf	

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � StrQryIn � Autor � Alfredo Medrano       �Data �21/03/2014 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Convierte un string de opciones a cadena para utilizar en  ���
���          � clausula IN de SQL                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � StrQryIn(cCadena) "NF /NCC/NDC"                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � cCadena: 'NF ','NCC','NDC'                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function StrQryIn( cCadena )

If !Empty( cCadena )
	cCadena := StrTran( cCadena , "," , "','" )
	cCadena := StrTran( cCadena , ";" , "','" )
	cCadena := StrTran( cCadena , "/" , "','" )
	cCadena := StrTran( cCadena , "|" , "','" )
Endif

Return ( "'" + cCadena + "'" )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Txt2Htm   �       � Alfredo Medrano       � Data �21/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Convierte a HTML el contenido del correo                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �PN9EnvMail(cPar01)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �cPar01: Descripci�n del contenido del mail                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �PN9EnvMail                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������/*/     
STATIC Function Txt2Htm( cText )

// ::: CRASE
// aA (acento crase)
cText := STRTRAN(cText,CHR(224), "&agrave;")
cText := STRTRAN(cText,CHR(192), "&Agrave;")

// ::: ACENTO CIRCUNFLEXO
// aA (acento circunflexo)
cText := STRTRAN(cText,CHR(226), "&acirc;")
cText := STRTRAN(cText,CHR(194), "&Acirc;")
// eE (acento circunflexo)
cText := STRTRAN(cText,CHR(234), "&ecirc;")
cText := STRTRAN(cText,CHR(202), "&Ecirc;")
// oO (acento circunflexo)
cText := STRTRAN(cText,CHR(244), "&ocirc;")
cText := STRTRAN(cText,CHR(212), "&Ocirc;")

// ::: TIL
// aA (til)
cText := STRTRAN(cText,CHR(227), "&atilde;")
cText := STRTRAN(cText,CHR(195), "&Atilde;")
// oO (til)
cText := STRTRAN(cText,CHR(245), "&otilde;")
cText := STRTRAN(cText,CHR(213), "&Otilde;")

// ::: CEDILHA
cText := STRTRAN(cText,CHR(231), "&ccedil;")
cText := STRTRAN(cText,CHR(199), "&Ccedil;")

// ::: ACENTO AGUDO
// aA (acento agudo)
cText := STRTRAN(cText,CHR(225), "&aacute;")
cText := STRTRAN(cText,CHR(193), "&Aacute;")

// eE (acento agudo)
cText := STRTRAN(cText,CHR(233), "&eacute;")
cText := STRTRAN(cText,CHR(201), "&Eacute;")

// iI (acento agudo)
cText := STRTRAN(cText,CHR(237), "&iacute;")
cText := STRTRAN(cText,CHR(205), "&Iacute;")

// oO (acento agudo)
cText := STRTRAN(cText,CHR(243), "&oacute;")
cText := STRTRAN(cText,CHR(211), "&Oacute;")

// uU (acento agudo)
cText := STRTRAN(cText,CHR(250), "&uacute;")
cText := STRTRAN(cText,CHR(218), "&Uacute;")

// ::: ENTER
cText := STRTRAN(cText,CHR(13)+CHR(10), "<br>")
cText := STRTRAN(cText,CHR(13), "<br>")
cText := STRTRAN(cText,CHR(10), "<br>")

Return cText
  
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ChgChk   � Autor � Alfredo Medrano     � Data � 28/04/2014 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Para selecci�n del Check, checado = .T.  vacio = .F.       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nPar01 - Numero da opcao escolhida                         ���
���          �          1 = PDF                                           ���
���          �          2 = Enviar Archivos                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � FTA750ASG                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ChgChk(nChk)

	lChk01 := .F.
	lChk02 := .F.
	If nChk == 1
		lChk01 := .T.
	ElseIf nChk == 2
		lChk02 := .T.
	EndIf

Return Nil