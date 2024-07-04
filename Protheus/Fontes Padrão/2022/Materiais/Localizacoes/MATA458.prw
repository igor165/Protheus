
#Include "PROTHEUS.Ch"
#Include "MATA458.ch"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATA458  � Autor � Alfredo Medrano       � Data �21/02/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Permite modificar y borrar informaci�n de las pre-facturas ���
���          � que fueron cargadas por el proceso de Subir XM.            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACOM                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Alf. Medrano�12/01/15�TRHQRV�se cambia nombre de funcion de Leyenda    ���
���            �        �      �M458Leyen                                 ���
���L. Samaniego�02/03/15�TRQFXY�Usar Alltrim() para comparar RFC's        ���
���Alex Hdez   �07/10/15�TTQUVB�Al cargar el XML de la factura de entrada,��� 
���            �        �      �relacionar el c�digo de producto del prov-���
���            �        �      �eedor, con el c�digo de productos conteni-���
���            �        �      �do en protheus.                           ���
���Alf. Medrano�27/05/16�TVGZL6�Merge con V118 / mejoras pre-Factura      ���
���            �        �      �se valida que no se borraren todos los    ���
���            �        �      �Items de la Prefact. se agrega MaFisEnd   ���
���            �        �      �en fun M458Mtto.se agraga funcion MTA458UP���
���            �        �      � para actualiza valores en Fac cuando se  ���
���            �        �      �borra item. Se optimiza la Edici�n de dato���
���            �        �      �CPQ en fun. MT458Graba. Se agrega fun     ���
���            �        �      �MA458ENC Actualiza el gasto, flete y      ���
���            �        �      �y seguro del encabezado. se activa calculo���
���            �        �      �de impuesto para visualizacion Pre-Fact   ���
���            �        �      �en func M458INIMTO.Se agrega a la func    ���
���            �        �      �MA458ENC calculo de Descuento con valor   ���
���            �        �      �de campo CPQ_DESC. se actualiza oEnchCPP  ���
���            �        �      �en  MT458Refresh                          ���
���Alf. Medrano�11/08/16�TVGZL6�En la Func XMLProc dentro de la condici�n ���
���            �        �      �del RFC del proveedor se agrega Return .F.���
���            �        �      �cuando el RFC no existe                   ���
���            �        �      �Modificaci�n para tomar tabla de certifi- ���
���M.Camargo   �        �      �cados CSDSAT de la BD y hacer validaciones���
���LuisEnr�quez�03/03/20�DMINA-�Se agregan validaciones para que al leer  ���
���            �        �7887  �el XML se notifique al usuario si no exis-���
���            �        �      �ten datos necesarios. (MEX)               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function MATA458()
Local cAliasCPP:="CPP" 
Local aCores	:= {}
Private aLeyenda  := {{'BR_VERDE',OemToAnsi(STR0007)},{'BR_VERMELHO',OemToAnsi(STR0008)}}	//"Sin generar factura" ## "Genero factura"
Private aRotina:= {{ OemToAnsi(STR0002), "AxPesqui" , 0 , 01},; //"Buscar"
					{ OemToAnsi(STR0003), "M458Mtto" , 0 , 02},; //"Visualizar"
					{ OemToAnsi(STR0004), "M458XML"  , 0 , 03},; //"Subir XML"
					{ OemToAnsi(STR0005), "M458Mtto" , 0 , 04},; //"Modificar"
					{ OemToAnsi(STR0006), "M458Mtto" , 0 , 05},; //"Borrar"	
					{ OemToAnsi(STR0086), "M458Leyen" , 0 , 06},; //Leyenda 
					{ OemToAnsi(STR0108), "LXList69B" , 0 , 03}} //"Cargar Listado 69-B"
Private BREFRESH:={ || MT458Refresh()} //la usar matxref
//Cores da legenda das ocorr�ncias de apontamento
AADD(aCores,{"CPP_STATUS <> '1'"	,"BR_VERDE"		, 	OemToAnsi(STR0007)})	//"Sin generar factura"
AADD(aCores,{"CPP_STATUS == '1'"	,"BR_VERMELHO"	, 	OemToAnsi(STR0008)}) //"Genero factura"

									               
Private cCadastro := OemToAnsi(STR0001) + "-" + UPPER(OemToAnsi(STR0005)) // "Pre-Factura - MODIFICAR" 
				
 If !RETORDEM("SA5","A5_FILIAL+A5_FORNECE+A5_LOJA+A5_CODPRF") > 1
	MsgAlert(STR0094) //"Para ejecutar esta rutina, debe actualizar primero el ambiente ejecutando el update UPDCOMMI, para crear el indice de la tabla SA5"
	Return
EndIf

dbSelectArea("SX2")
SX2->(dbSetOrder(1))
If SX2->(dbSeek("CPP")) .AND. SX2->(dbSeek("CPQ"))
dbSelectArea(cAliasCPP)
dbSetOrder(1)
MsSeek(xFilial(cAliasCPP))

mBrowse( 6 , 1 , 22 , 75 , cAliasCPP, , , , , ,aCores) 
Else
	MsgAlert(STR0090) //"Para ejecutar esta rutina, debe actualizar primero el ambiente ejecutando el update UPDCOMMI seleccionando la opci�n �Interface NF-E XML M�xico"
EndIf

Return 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M458Mtto � Autor � Alfredo.Medrano       � Data �21/02/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Enchoice y Getdados de pre-facturas                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � M458Mtto(@ExpC1,@ExpN2,@ExpN3 )                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias de la tabla del MBrowse.                     ���
���          � ExpN2 : Numero del registro fisico DB.                     ���
���          � ExpN3 : Numero de opci�n del aRotina.                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA458                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
FUNCTION M458Mtto ( cAlias,nReg,nOpc  )
Local aArea		:= GetArea()
Local aSvKeys	:= GetKeys()
Local nOpcAcc1	:=0
Local nx:=0                        

//PARA EL DIALOG

Local aPosObj	:= {}
Local aObjects	:= {}
Local aSize		:= {}
Local aInfo		:= {}
//PARA EL MSGET

Local cAliasMsMGet:=calias
Local aCpoEnch		:={}
Local aAlterEnch	:={}// campos editables en encabezado
Local aPos			:= {}
Local nModelo		:= 3         
Local lF3 			:= .F.
Local lMemoria		:= .T.
Local lColumn		:= .F.   
Local caTela 		:= ""
Local lNoFolder		:= .F.            
Local lProperty		:= .F. 

//PARA MSNEWGETDADOS

Local cLinOk	:={|| MT458LINOK()}
Local cTodoOk	:={|| MT458TODOOK()}
Local aColsCPQ:={}
Local aAlterGDa	:= {}// campos alterables en GetDados

*/
//BOTONES
Local bGraba	:={||if (MT458TODOOK(aAlterEnch),(MT458Graba(aAlterEnch,nOpc),oDlg:End()),)}
Local bCancela	:={|| oDlg:End()}  

//Para bloqueo de registros
Local aCPPRecnos:={}
Local lLocks	:= .F.

//DETALLE
Local 	cLinea	:= space(40)
Local 	cGrupo 	:=""
Local	cSeek	:=""
Local aHeadTot3	:={}
Local aColsTot3	:={}

Local aButtons:={} 
Local lFirstFis  := .T.


Local nPosQtd	:= 0
Local nPosPU	:= 0
Local cFilCPQ:=XFILIAL("CPQ")
Local bDelOk:={ || MTA458UP()} 
//Variables para Pie de p�gina "Totales" y "Impuestos"
Private 	cOper	:=""  
Private 	cLoja	:=""
Private 	cDoc	:=""
Private 	cSerie	:=""
Private 	cUUID	:=""
Private 	aValores:= {}
Private	 	nSeguro :=0
Private 	nValMer :=0
Private 	nValBru :=0
Private 	nDescue :=0
Private 	nValGas :=0
Private	 	nValFle	:=0
Private 	oValMer
Private 	oValBru
Private 	oDescue 
Private 	oValGas
Private	oValFle
Private	oSeguro
Private   nMaxLin	:=0
//OBJETOS
Private oLbx
Private oSay
Private oDlg 
Private oGroupT
Private oGroupI
Private oEnchCPP 
Private aTELA[0][0]
Private aGETS[0] 
Private oGetCPQ 	
Private aHeaderCPQ :={}
Private nUsado:=0
Private nUsado2:=0
Private aColsIt	:= If(nOpc == 3,{""},{})
Private aRefImpCPQ	:= MaFisRelImp('MT100',{"CPQ"})
Private acols:={} 
Private aheader:={}
Private l1ervez:= .t.
aNfItem:=nil
DBSELECTAREA("CPP")
DBSELECTAREA("CPQ")

//Selecciona el tipo de acceso que habra en los getdados de acuerdo a la opcion seleccionada
if nopc==4 //alterar
   nOpcAcc1:=7 
else
   nOpcAcc1:=4
endif  

cOper	:=CPP->CPP_FORNEC
cLoja 	:=CPP->CPP_LOJA
cDoc	:=CPP->CPP_DOC
cSerie	:=CPP->CPP_SERIE
cUUID	:=CPP->CPP_UUID     
 
nValFle:=cpp->CPP_FRETE
nValGas:=cpp->CPP_DESPES
nSeguro:=cpp->CPP_SEGURO
nDescue:=cpp->CPP_DESCON 		
nValMer:=CPP->CPP_VALMER  
nValBru:=CPP->CPP_VALBRU  
	 
 //If nopc==4     
	If !MaFisFound("NF")
			MaFisIni(CPP->CPP_FORNEC,CPP->CPP_LOJA,"F","N",Nil,aRefImpCPQ,,.T.)     //Inicoia calculo de operaciones fiscales
	EndIf     
 //ENDIF
 If nopc==4 .or. nopc==5 //modificar o borrar
	If CPP->CPP_STATUS=='1' 	
		MsgInfo(OemToAnsi(STR0052)) // "Pre-factura con Factura Generada. No se permiten Cambios."
		return
	EndIf
 EndIf
 
/*
  �������������������������������������������������Ŀ
  �Prepara botones de la barra de herramientas
  ��������������������������������������������������� /*/
CURSORWAIT()
	/*/
	  ���������������������������������Ŀ
	  �Prepara informaci�n para el MsGet�
	  ����������������������������������� /*/
	
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cAliasMsMGet)
	While !Eof() .And. SX3->X3_ARQUIVO == cAliasMsMGet
		If !(SX3->X3_CAMPO $ "CPP_FILIAL") .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)
				//aCpoEnch = se agregan los campos a mostrar en el encabezado
				If  SX3->X3_CONTEXT !='V'
					AADD(aCpoEnch,SX3->X3_CAMPO)
					//aAlterEnch = se agregan los campos que se podran Modificar
					If SX3->X3_VISUAL =='A'
						AADD(aAlterEnch,SX3->X3_CAMPO)
					EndIf
				EndIf
		EndIf		 
		DbSkip()
	End
		
	//guardar numero de registro para bloqueo
	
	if nOpc==4 .or. nOpc==5 
	    aadd(aCPPRecnos,CPP->(RECNO()))
	endif
	 
	/*/
	  �������������������������������������Ŀ
	  �Prepara informaci�n para los GetDados�
	  ��������������������������������������� /*/
	
	dbSelectArea("SX3")
	dbsetorder(1)
	dbSeek("CPQ")
	aHeaderCPQ:={}  
	nUsado:=0
	Do while !eof() .and. X3_ARQUIVO=="CPQ"
		If X3USO(x3_usado).And.cNivel>=x3_nivel 
				If  X3_CONTEXT !='V' 
					nUsado++
					AADD(aHeaderCPQ,{ TRIM( X3Titulo()), x3_campo, x3_picture,x3_tamanho,;
						x3_decimal,x3_valid,x3_usado, x3_tipo, x3_f3, x3_context,X3Cbox(),SX3->X3_RELACAO } )
					//aAlterGDa = se agregan los campos que se podran Modificar en el getDados
					If SX3->X3_VISUAL =='A'
						AADD(aAlterGDa,SX3->X3_CAMPO)
					EndIf
				Endif 
		EndIf
		dbskip()
	enddo     
	
	//Prepara el acols 
	MsgRun(STR0106,STR0105,{|| M458INIMTO(NOPC,@aColsCPQ) }) // "Cargando informaci�n..."   "Espere"

	
	/*
	//���������������������������������������������8�
	//�Bloquea los registros s Modificar o a Borrar�
	//���������������������������������������������8�
	*/
	if nOpc==4 .or. nOpc==5	                         
		IF !( lLocks := WhileNoLock( "CPP" , aCPPRecnos , NIL , 1 , 1 , NIL , 1 ) )
			RestArea(aArea)
			RestKeys( aSvKeys , .T. ) // Restaura as Teclas de Atalho                				   
			Return
		EndIF
	 ENDIF
	
	//��������������������������������������������������������Ŀ
	//� Hace  calculo automatico de dimenciones de objetos     �
	//����������������������������������������������������������
	
		aSize := MsAdvSize()
		AAdd( aObjects, { 50 , 50, .T., .T. } )  //VENTANA DEL ENCABEZADO     
		AAdd( aObjects, { 80, 80, .T., .T. } )//VENTANA DEL GETDADOS 
		AAdd( aObjects, { 20, 40, .T., .T. } )//VENTANA DE TOTALES
		
		aInfo	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
		aPosObj	:= MsObjSize( aInfo, aObjects,.T.)                       
		aPOS	:={aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]}
		aPOSDet	:={aPosObj[3,1],aPosObj[3,2],aPosObj[3,3],aPosObj[3,4]}

	CURSORARROW()	                      


	DEFINE FONT oFont NAME "Arial" SIZE 0,-12 BOLD
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL

	RegToMemory(caliasMsMGet, If(nOpc==3,.T.,.F.))
	oEnchCPP := MsMGet():New(caliasMsMGet, nReg, nOpc, /*aCRA*/, /*cLetra*/,;
				/*cTexto*/, aCpoEnch, aPos, aAlterEnch, nModelo, /*nColMens*/,;
				/*cMensagem*/, /*cTudoOk*/,oDlg,lF3,lMemoria,lColumn, caTela,;
				lNoFolder, lProperty) 
					         
	oGroupT:= tGroup():New(aPosObj[3,1],aPosObj[3,2],aPosObj[3,3],aPosObj[3,4]/2,OemToAnsi(STR0060),oDlg,,,.T.)// "Total"
	oSay	:= tSay():New(aPosObj[3,1]+12,aPosObj[3,2]+5,{||OemToAnsi(STR0053)},oDlg,,,,,,.T.) 			// "Valor Gastos"
	@ aPosObj[3,1]+10,aPosObj[3,2]+40   GET oValGas Var nValGas	When .f. OF oDlg Picture PesqPict("CPP","CPP_DESPES")	SIZE 060,10  PIXEL 
	
	oSay	:= tSay():New(aPosObj[3,1]+28,aPosObj[3,2]+5,{||OemToAnsi(STR0054)},oDlg,,,,,,.T.) 			// "Valor Flete"
	@ aPosObj[3,1]+25,aPosObj[3,2]+40   GET oValFle Var nValFle	When .f. OF oDlg Picture PesqPict("CPP","CPP_FRETE")   SIZE 060,10  PIXEL	
	
	oSay	:= tSay():New(aPosObj[3,1]+42,aPosObj[3,2]+5,{||OemToAnsi(STR0055)},oDlg,,,,,,.T.) 				// "Seguro"
	@ aPosObj[3,1]+40,aPosObj[3,2]+40   GET oSeguro Var nSeguro	When .f. OF oDlg Picture PesqPict("CPP","CPP_SEGURO")	SIZE 060,10  PIXEL 				
	
	oSay	:= tSay():New(aPosObj[3,1]+12,aPosObj[3,2]+150,{||OemToAnsi(STR0056)},oDlg,,,,,,.T.) 			// "Descuento "
 	
	@ aPosObj[3,1]+10,aPosObj[3,2]+193  GET oDescue Var nDescue	 When .f. OF oDlg Picture PesqPict("CPP","CPP_DESCON")	SIZE 060,10  PIXEL
	
	oSay	:= tSay():New(aPosObj[3,1]+28,aPosObj[3,2]+150,{||OemToAnsi(STR0057)},oDlg,,,,,,.T.) 	// "Valor Mercanc�a"
	@ aPosObj[3,1]+25,aPosObj[3,2]+193  GET oValMer Var nValMer	When .f. OF oDlg Picture PesqPict("CPP","CPP_VALMER")  SIZE 060,10	 PIXEL  
		
	oSay	:= tSay():New(aPosObj[3,1]+40,aPosObj[3,2]+150,{||replace(cLinea," ","_")},oDlg,,,,,,.T.) 	// Linea
	
	oSay	:= tSay():New(aPosObj[3,1]+52,aPosObj[3,2]+150,{||OemToAnsi(STR0058)},oDlg,,,,,,.T.) 		// "Valor Bruto"
	@ aPosObj[3,1]+50,aPosObj[3,2]+193  GET	 oValBru Var nValBru   When .f.	 OF oDlg Picture PesqPict("CPP","CPP_VALBRU")   SIZE 060,10 PIXEL 		
			 		
   oGetCPQ:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nopcacc1,cLinOk ,cTodoOk ,nil,aAlterGDa, 0, nMaxLin,"AllwaysTrue" ,; 
        		                             "",bDelOk,  oDlg, aHeaderCPQ, aColsCPQ)
 
   oGroupI:= tGroup():New(aPosObj[3,1],aPosObj[3,4]/2+5,aPosObj[3,3],aPosObj[3,4],OemToAnsi(STR0059),oDlg,,,.T.)// "Impuestos"
   
 	IIF (nopc==4 .OR. nopc==2, aValores	:=  aClone(MaFisRet(,"NF_IMPOSTOS")),aadd(aValores,{"","","",0,0}))
 	 //aValores	:=  aClone(MaFisRet(,"NF_IMPOSTOS"))
 	
  
  @ aPosObj[3,1]+12,aPosObj[3,4]/2+12 LISTBOX oLbx FIELDS;
    HEADER OemToAnsi(STR0061), OemToAnsi(STR0062), OemToAnsi(STR0063), OemToAnsi(STR0064); //"Cod." / "Descripci�n" /"Base Impuesto"/"Vlr. Impuesto "
    SIZE 250,55 OF oGroupI PIXEL 
  	oLbx:SetArray(aValores)
	oLbx:bLine := {|| {aValores[oLbx:nAt,1],;
					   aValores[oLbx:nAt,2],; 
					   aValores[oLbx:nAt,3],; 
					   TRANSFORM(aValores[oLbx:nAt,5],PesqPict('CPQ','CPQ_BASIM1')),; 
					   aValores[oLbx:nAt,4]}}			   
	oLbx:Refresh()				   
	 		                             
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bGraba,bCancela)
	
	/*
	//���������������������������Ŀ
	//�Libera registros bloqueados�
	//�����������������������������
	*/
		    FreeLocks( "CPP" ,CPP->(RECNO()) , .T. )
	//finaliza el uso de las Funciones fiscales //limpia Mafis
	If MaFisFound()
		MaFisEnd()
	EndIf
	RestArea(aArea)
	RestKeys( aSvKeys , .T. ) // Restaura as Teclas de Atalho                				   
RETURN


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MAT458MOED� Autor � Alfredo Medrano       � Data �25/02/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Llena cadena con las monedas activas                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MAT458MOED()                                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oView                                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA091                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MAT458MOED()
Local nX 		:= 0
Local cMoeda 	:= ""

//������������������������������������������������������Ŀ
//� Carrega array com as moedas ativs para o Combo.      �
//��������������������������������������������������������
For nX   := 1  To MoedFin()
   If(!(Empty(GetMv("MV_MOEDA"+Alltrim(STR(nX))))))
		cMoeda += Alltrim(STR(nX)) + "=" + GetMV("MV_MOEDA"+Alltrim(STR(nX))) + ";"
   Else
      Exit
   Endif
Next
cMoeda := substr(cMoeda,1,Len(cMoeda)-1)

Return cMoeda
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �MAT458PRC  � Autor � Gpe Santacruz         � Data �13/03/2014���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao del precio    digitado.                           ���
��������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Precio                                              ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Dicionario de Dados - CPQ_vunit                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function MAT458PRC(nPrc)

Local aArea		:= GetArea()
Local nPosQtd	:= aScan(oGetCPQ:aHeader,{|x| AllTrim(x[2]) == "CPQ_QUANT"})
Local nPosTot	:= aScan(oGetCPQ:aHeader,{|x| AllTrim(x[2]) == "CPQ_TOTAL"})


MaFisAlt("IT_VALMERC" , NoRound(oGetCPQ:aCols[oGetCPQ:nat,nPosQtd] * M->CPQ_VUNIT,TamSx3("CPQ_TOTAL")[2]) , N )


RestArea(aArea)

Return .T.


/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �MAT458Quant� Autor � Alfredo Medrano       � Data �13/03/2014���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da quantidade digitada.                           ���
��������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Quantidade digitada                                 ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Dicionario de Dados - CPQ_QUANT                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function MAT458Quant(nQuant)

Local aArea		:= GetArea()
Local nPosPrc	:= aScan(oGetCPQ:aHeader,{|x| AllTrim(x[2]) == "CPQ_VUNIT"})
Local nPosTot	:= aScan(oGetCPQ:aHeader,{|x| AllTrim(x[2]) == "CPQ_TOTAL"})

//����������������������������������������������������Ŀ
//� Atualiza a quantidade da Segunda UM                �
//������������������������������������������������������
MAT458SegUm()
MaFisAlt("IT_VALMERC" , NoRound(oGetCPQ:aCols[oGetCPQ:nat][nPosPrc] * M->CPQ_QUANT,TamSx3("CPQ_TOTAL")[2]) , N )


RestArea(aArea)

Return .T.


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �MAT458SegUm� Autor �Gpe. Santacruz         �Data  �08/06/2011���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Trata UM y segunda UM                                        ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Importaciones para Mexico                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function MAT458SegUm()

Local lMudou   := .F.

Local cVarCod  := ""
Local cVarQtd  := ""
Local cVarQtd2 := ""
Local cVarTotal:= ""
Local cProduto := ""
Local cCampo   := Alltrim(ReadVar())
Local cAlias   := Alias()

Local nOrder   := IndexOrd()
Local nRecno   := Recno()
Local nOrdSB1  := SB1->(IndexOrd()),nRecSB1:=SB1->(Recno())
Local nValQDa  := 0 // quantidade anterior - Calculo do Desconto Devolucao
Local nValQDb  := 0 // quantidade atual    - Calculo do Desconto Devolucao
Local nPosCod  := 0
Local nPosQtd  := 0
Local nPosQtd2 := 0
Local nPosTotal:= 0
Local nPosDesc := 0
Local nQuant   := 0
Local nX       := 0
    
For nX := 1 To Len(oGetCPQ:aHeader)
	If Trim(Substr(oGetCPQ:aHeader[nX][2],4)) == "_COD"
		nPosCod   := nX
		cVarCod   := "M->"+AllTrim(oGetCPQ:aHeader[nX][2])
	ElseIf Trim(Substr(oGetCPQ:aHeader[nX][2],4)) == "_QUANT"
		nPosQtd   := nX
		cVarQtd   := "M->"+AllTrim(oGetCPQ:aHeader[nX][2])
	ElseIf Trim(Substr(oGetCPQ:aHeader[nX][2],4)) == "_QTSEGU"
		nPosQtd2  := nX
		cVarQtd2  := "M->"+AllTrim(oGetCPQ:aHeader[nX][2])
	ElseIf Trim(Substr(oGetCPQ:aHeader[nX][2],4)) == "_TOTAL"
		nPosTotal := nX
		cVarTotal := "M->"+AllTrim(oGetCPQ:aHeader[nX][2])
	ElseIf Trim(Substr(oGetCPQ:aHeader[nX][2],4)) == "_VALDES"
		nPosDesc:=nX
	EndIf
	// Caso j� achou todos, abandona o Loop
	If nPosCod > 0 .And. nPosQtd > 0 .And. nPosQtd2 > 0 .And. nPosTotal > 0 .And. nPosDesc > 0
		Exit
	EndIf
Next nX

// Caso esteja no codigo do produto, obtem o produto
If cCampo == cVarCod
	cProduto:=&(ReadVar())
Else
	nQuant:=&(ReadVar())
	cProduto:=oGetCPQ:aCols[oGetCPQ:nat][nPosCod]
EndIf

dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1")+cProduto)
	// Altera campo da Quantidade na Segunda UM
	If cCampo == cVarQtd
		If nPosQtd2 > 0
			nValQDa := oGetCPQ:aCols[oGetCPQ:nat][nPosQtd]
			oGetCPQ:aCols[oGetCPQ:nat][nPosQtd2]:=	ConvUm(SB1->B1_COD,nQuant,oGetCPQ:aCols[oGetCPQ:nat][nPosQtd2],2)
			nValQDb :=&(ReadVar())
			&(cVarQtd2):= oGetCPQ:aCols[oGetCPQ:nat][nPosQtd2]
			lMudou:=.T.
		EndIf
		// Altera campo da Quantidade na Primeira UM
	ElseIf cCampo == cVarQtd2
		If nPosQtd > 0 .and. (&(cVarQtd2) # oGetCPQ:aCols[oGetCPQ:nat][nPosQtd2])
			nValQDa   := oGetCPQ:aCols[oGetCPQ:nat][nPosQtd]
			oGetCPQ:aCols[oGetCPQ:nat][nPosQtd]:=	ConvUm(SB1->B1_COD,oGetCPQ:aCols[oGetCPQ:nat][nPosQtd],nQuant,1)
			nValQDb   := oGetCPQ:aCols[oGetCPQ:nat][nPosQtd]
			&(cVarQtd):= oGetCPQ:aCols[oGetCPQ:nat][nPosQtd]

			//�����������������������������������������������������������������Ŀ
			//� Tratamento para atualizacao do campo qtdsol no pedido de compra �
			//�������������������������������������������������������������������
			

			lMudou:=.T.
		EndIf
		// Altera campo da Quantidade na Segunda UM ou na Primeira UM
	ElseIf cCampo == cVarCod
		If nPosQtd > 0 .And. nPosQtd2 > 0
			If !Empty(oGetCPQ:aCols[oGetCPQ:nat][nPosQtd])
				oGetCPQ:aCols[oGetCPQ:nat][nPosQtd2]:=	ConvUm(SB1->B1_COD,oGetCPQ:aCols[oGetCPQ:nat][nPosQtd],oGetCPQ:aCols[oGetCPQ:nat][nPosQtd2],2)
				&(cVarQtd2):= oGetCPQ:aCols[oGetCPQ:nat][nPosQtd2]
			ElseIf !Empty(oGetCPQ:aCols[oGetCPQ:nat][nPosQtd2])
				oGetCPQ:aCols[oGetCPQ:nat][nPosQtd]:=	ConvUm(SB1->B1_COD,oGetCPQ:aCols[oGetCPQ:nat][nPosQtd],oGetCPQ:aCols[oGetCPQ:nat][nPosQtd2],1)
				&(cVarQtd):= oGetCPQ:aCols[oGetCPQ:nat][nPosQtd]
				lMudou:=.T.
			EndIf
		EndIf
	EndIf
	// Zera total qdo mudou quantidade
	If lMudou .And. nPosTotal > 0
		oGetCPQ:aCols[oGetCPQ:nat][nPosTotal]:= 0
		&(cVarTotal):= 0
		If Type("cTipo")=="C"
			If nPosDesc > 0
			oGetCPQ:	aCols[oGetCPQ:nat][nPosDesc] := (oGetCPQ:aCols[oGetCPQ:nat][nPosDesc]/nValQDa)*nValQDb
			EndIF
		EndIf
		//��������������������������������������������������������������Ŀ
		//� Compatibilizacao com programas que utilizam a Funcao Fiscal  �
		//����������������������������������������������������������������
		If MaFisFound("IT",n)
			MaFisAlt("IT_QUANT",&(cVarQtd),n)
			MaFisAlt("IT_VALMERC",0,n)
			If nPosDesc > 0
				MaFisAlt("IT_DESCONTO",oGetCPQ:aCols[n][nPosDesc],n)
			EndIf
		EndIf
	EndIf
EndIf

dbSelectArea(cAlias)
dbSetOrder(nOrder)
dbGoto(nRecno)
SB1->(dbSetOrder(nOrdSB1))
SB1->(dbGoto(nRecSB1))

Return .T.

  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MT458Refresh� Autor � Alfredo Medrano     � Data �10/02/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza un refresh cuando cambia de posici�n el Getdados   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MT458Refresh()                                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA458                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
static Function MT458Refresh(lBan)

Local aArea	    := GetArea()
Local nx:= 0
Local ny:= 0
Local cValid     := ""
Local cRefCols   := ""
Local cPosFor    := CPP->CPP_FORNEC 
Local cPosLoja   := CPP->CPP_LOJA                    
Local nPosQtd	:= 0
Local nPosPU	:= 0
Local nPosDel:=0

Default lBan:= .f.

IF oGetCPQ<>NIL
					cursorwait()
	 				 nPosQtd	:= aScan(oGetCPQ:aHeader,{|x| AllTrim(x[2]) == "CPQ_QUANT"})
					 nPosPU	:= aScan(oGetCPQ:aHeader,{|x| AllTrim(x[2]) == "CPQ_VUNIT"})
					 nPosDel:=GdFieldPos("GDDELETED",oGetCPQ:aHeader)
					
					
					
					oGetCPQ:REFRESH()
					
					
					nDescue:= MaFisRet(,"NF_DESCONTO")
					nValFle:= MaFisRet(,"NF_FRETE")
					nValGas:= MaFisRet(,"NF_DESPESA")
					nSeguro:= MaFisRet(,"NF_SEGURO")
					nValMer:= MaFisRet(,"NF_VALMERC")
					nValBru:= MaFisRet(,"NF_TOTAL")
					
					M->CPP_DESPES := nValGas
					M->CPP_FRETE	:= nValFle
					M->CPP_SEGURO	:= nSeguro
					M->CPP_DESCON	:= nDescue
					M->CPP_VALMER := nValMer
					M->CPP_VALBRU := nValBru
                                                                                   
					//Reasigna valores al listBox
					aValores:= {}               
					
					
					
					aValores	:= aClone(MaFisRet(,"NF_IMPOSTOS"))
					
					
					oLbx:SetArray(aValores)
					oLbx:bLine := {|| {	aValores[oLbx:nAt,1],;
										aValores[oLbx:nAt,2],; 
										aValores[oLbx:nAt,3],; 
										TRANSFORM(aValores[oLbx:nAt,5],PesqPict('CPQ','CPQ_BASIM1')),; 
										aValores[oLbx:nAt,4]}}	
					
						
					oValGas:refresh()
					oValFle:refresh()
					oSeguro:refresh()
					oDescue:refresh()
					oValMer:refresh()
					oValBru:refresh()
					oLbx:refresh()
					oEnchCPP:refresh()
					cursorarroW()
ENDIF
RestArea(aArea)

Return .T.   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MT458Graba� Autor � Alfredo Medrano       � Data �10/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Modifica los datos                                         ���
���          � 	                                                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MT458Graba(aAlterEnch,nOpc)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1:Arreglo de MsmGet                                    ���
���          � ExpN1:Opcion de aRotina                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MSDIALOG                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MT458Graba(aAlterEnch,nOpc)
Local aArea		:= GetArea()
Local nx:=0
Local ny:=0 
Local cEdit	:= ""
Local nPosDel:=GdFieldPos("GDDELETED",oGetCPQ:aHeader)     	
Local nPoItem:=GdFieldPos("CPQ_ITEM",oGetCPQ:aHeader)
Local nItem	:= aScan(oGetCPQ:aHeader,{|x| AllTrim(x[2]) == "CPQ_ITEM"}) // posici�n del Item
	
	/*
	//�����������������������������Ŀ
	//�Modifica Encabezado y Detalle�
	//�������������������������������
	*/                    
	IF NOPC==4 //Modificar
	   CURSORWAIT()
		//Graba Encabezado
	   
		RECLOCK("CPP",.F.) 
		cpp->CPP_FRETE  :=nValFle
		cpp->CPP_DESPES :=nValGas
		cpp->CPP_SEGURO :=nSeguro
		cpp->CPP_DESCON :=nDescue 		
		cpp->CPP_VALMER :=nValMer
		cpp->CPP_VALBRU :=nValBru
		   
		For Nx:=1 to Len(aAlterEnch)
		   &("CPP->"+aAlterEnch[NX]):=&("M->"+aAlterEnch[NX])
		Next                                         
		CPP->(MSUNLOCK())
	  
		CPQ->(DBsetorder(2)) //CPQ_FILIAL+CPQ_UUID+CPQ_ITEM
		For ny:=1 to Len(oGetCPQ:AlastEdit)
			cEdit:= cEdit + ALLTRIM(str(oGetCPQ:ALASTEDIT[ny]))+ "|" 
		next	
			
		For Nx:=1 to Len(oGetCPQ:aCols)  
		   	IF CPQ->(DBSEEK(XFILIAL("CPQ")+cUUID+oGetCPQ:aCols[Nx][nPoItem]))   
		   		IF !oGetCPQ:aCols[nx,nPosDel]
		      		If ALLTRIM(str(Nx)) $ cEdit
						RecLock("CPQ",.F.)           
					   CPQ->CPQ_FILIAL	:= XFILIAL("CPQ")
					  	CPQ->CPQ_FORNEC	:= CPP->CPP_FORNEC //cOper
					   CPQ->CPQ_LOJA	:= CPP->CPP_LOJA //cLoja
					   CPQ->CPQ_DOC	:= CPP->CPP_DOC //CDOC
					   CPQ->CPQ_SERIE	:= CPP->CPP_SERIE //cSerie
					   CPQ->CPQ_UUID	:= CPP->CPP_UUID	
					   CPQ->CPQ_VALFR	:= nValFle
						CPQ->CPQ_DESPES	:= nValGas
			  			CPQ->CPQ_SEGUR	:= nSeguro
					   For ny:=1 to Len(oGetCPQ:aHeader)
						   IF oGetCPQ:AHEADER[NY][10]<>'V' //Excluye los campos virtuales
						      &("CPQ->"+oGetCPQ:aHeader[NY,2]):=oGetCPQ:aCols[nx,ny] 
						   ENDIF    
					   Next    
		    	   		CPQ->(MSUNLOCK())
		    	  	EndIf
		    	 Else
		    	 	RecLock("CPQ",.F.)
		    	 	CPQ->(DBDelete()) 
		    	  	CPQ->(MSUNLOCK())
		    	EndIf 
		   EndIf  
		Next 
		 CURSORARROW()
	ENDIF 
	
	/*
	//����������������������������Ŀ
	//�Elimina encabezado y detalle�
	//������������������������������
	*/                         
	
	IF NOPC==5 //Borrar
		//"Estas seguro de Eliminar?"
	   if msgYesNo(oemtoansi(STR0066)) // "�Esta seguro de que desea eliminarlo?"
	       CPP->(DBSETORDER(1))
	       CURSORWAIT()
			RECLOCK("CPP",.F.) 
			CPP->(DBDelete()) 
			CPP->(MSUNLOCK())
					   
			//Borra Detalle
		   CPQ->(DBsetorder(2))
		
			   DO WHILE .T.     
						        
			   			IF CPQ->(DBSEEK(XFILIAL("CPQ")+cUUID)) //CPQ_FILIAL+CPQ_UUID
				   	   		RecLock("CPQ",.f.)           
					   		CPQ->(DBDelete()) 
					   		CPQ->(MSUNLOCK())           	
					   	ELSE
					   	    EXIT	
				   		 ENDIF 
				   		 
				ENDDO
			msgInfo(oemtoansi(STR0067))	 //"Pre-factura eliminada!"
			CURSORARROW()		  				
	      
		endif   
	ENDIF                
RestArea(aArea)
Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MT458LINOK� Autor � gSantacruz    o       � Data �18/01/2016���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida la linea del GetDados							        ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MT458LINOK()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Ninguno                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MsNewGetDados                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function MT458LINOK()

Local lRet := .T.
Local nx:=oGetCPQ:nat
Local nPosDel:=GdFieldPos("GDDELETED",oGetCPQ:aHeader)    
Local ny:=0


//Revisa los datos obligatorios del acols

if altera       
     for ny:=1 to len(oGetCPQ:aHeader)
       IF !oGetCPQ:aCols[nx,nPosDel]  
	       if  X3Obrigat(alltrim(oGetCPQ:aHeader[ny,2])) .and. empty(oGetCPQ:aCols[nx,ny])
           	        Help( ,, OemToAnsi(STR0041),,STR0098+oGetCPQ:aHeader[ny,2]+STR0099  ,1, 0 )	//"Atencion"
		   			lRet := .f.                                                                                                                                 
		   			exit
		   endif			 
       ENDIF                         
     next  
endif 

Return lRet


/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �MT458TODOOK� Autor � gsantacruz            � Data �18/01/2016���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Valida los campos obligatorios antes de guardar             ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � MT458TODOOK()                                               ���
��������������������������������������������������������������������������Ĵ��
���Parametros� Ninguno                                                     ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � MsNewGetDados                                               ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function MT458TODOOK(aAlterEnch)
Local lRet := .T.
Local nx:=0
Local uVar
Local nPosDel:=GdFieldPos("GDDELETED",oGetCPQ:aHeader)    
Local ny:=0
Local nAct:=0
if altera
//Revisa los datos obligatorios del encabezado
for nx:=1 to len(aAlterEnch)
    uVar:=&("m->"+alltrim(aAlterEnch[nx]))
    if  X3Obrigat(alltrim(aAlterEnch[nx])) .and. empty(uvar)
       
		 Help( ,, OemToAnsi(STR0041),, STR0098 +aAlterEnch[nx]+STR0099 ,1, 0 )	//"Atencion" "El campo " " es obligatorio"
		 lRet := .f.    
		 exit
		 	     
    endif
next      

			
//Revisa los datos obligatorios del acols

 For Nx:=1 to Len(oGetCPQ:aCols)      
     for ny:=1 to len(oGetCPQ:aHeader)
       IF !oGetCPQ:aCols[nx,nPosDel]  
	       if  X3Obrigat(alltrim(oGetCPQ:aHeader[ny,2])) .and. empty(oGetCPQ:aCols[nx,ny])
           	        Help( ,, OemToAnsi(STR0041),, STR0098+oGetCPQ:aHeader[ny,2]+ STR0100+oGetCPQ:aCols[nx,1]+STR0099 ,1, 0 )	//"Atencion" "El campo " " del item :" " es obligatorio"
		   			lRet := .f.                                                                                                                                 
		   			exit
		   endif			 
       ENDIF                         
     next  
 Next
endif

nAct := aScan(oGetCPQ:Acols,{|x| x[nPosDel] == .f. })
If nAct <= 0  
	msgInfo(OemToAnsi(STR0103))	 // 
	lRet := .f.         
EndIf

Return lRet   

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � MT458VLR  � Autor � Alfredo Medrano       � Data �11/03/2014���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Actualiza los valores del pie de paguina                    ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � MT458VLR()                                                  ���
��������������������������������������������������������������������������Ĵ��
���Parametros� Ninguno                                                     ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � X3_VALID: CPP_DESPES,CPP_SEGURO,CPP_FRETE,CPP_DESCON        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function MT458VLR(cReferencia,xValor,lRefre)

Local aArea	   := GetArea()
Local lRetorno := .T.
MsgRun(OemToAnsi(STR0104),OemToAnsi(STR0105),{|| m458caldes(cReferencia,xValor,lRefre) })

RestArea(aArea)

Return(lRetorno)

static Function m458caldes(cReferencia,xValor,lRefre)
Local lret:= .t.
Default  lRefre := .T.
if l1ervez
   
   If MaFisFound("NF")
	 	MaFisAlt(cReferencia,xValor)   
	 	if alltrim(cReferencia)<>"NF_FRETE"
			MaFisAlt("NF_FRETE",nValFle)
		endif	                           
	 	if alltrim(cReferencia)<>"NF_SEGURO"
			MaFisAlt("NF_SEGURO",nSeguro)
		endif	  
		if alltrim(cReferencia)<>"NF_DESPESA"
			MaFisAlt("NF_DESPESA",nValGas)   
		endif
		if alltrim(cReferencia)<>"NF_DESCONTO"	
			MaFisAlt("NF_DESCONTO",nDescue)
		endif
			
		If lRefre
			MaFisToCols(oGetCPQ:aHeader,oGetCPQ:aCols,,"MT100")
			
			Eval(BREFRESH)
			
		EndIf
		l1ervez:= .f.
	EndIf
else
	If MaFisFound("NF")
		MaFisAlt(cReferencia,xValor) 
		
		If lRefre
			MaFisToCols(oGetCPQ:aHeader,oGetCPQ:aCols,,"MT100")
			
			Eval(BREFRESH)
			
		EndIf
	EndIf
endif	
return lret

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �MAT458PRC  � Autor � Gpe Santacruz         � Data �13/03/2014���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao del importe descuento por item                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Precio                                              ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Dicionario de Dados - CPQ_valdes                            ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function MA458VDESC()

Local aArea		:= GetArea()
Local nx:=1 
Local nPosDes:=GdFieldPos("CPQ_VALDES",oGetCPQ:aHeader)

MaFisAlt("IT_DESCONTO" , NoRound ( M->CPQ_VALDES,TamSx3("CPQ_VALDES")[2]) , N )

//Actauliza el descuento del pie de �gina y del encabezado
nDescue:=0
for nx:=1 to len(oGetCPQ:aCols)
    IF N==NX
        nDescue+=M->CPQ_VALDES
    ELSE    
    	nDescue+=oGetCPQ:aCols[nx,nPosDes]
    ENDIF	
    
next
oDescue:refresh()
Eval(BREFRESH)

M->CPP_DESCON:=nDescue
oEnchCPP:refresh()
RestArea(aArea)

Return .T.

#Include "PROTHEUS.Ch"
#Include "MATA458.ch"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M458XML  � Autor � AMayra.Camargo        � Data �21/02/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Permite realizar la carga de pre-facturas mediante un ar-  ���
���          � chivo XML												           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACOM                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function M458XML()
	
	Local aArea := getArea()
	Local nOpca		:= 0
	Local aSays		:= {}
	Local aButtons	:= {}

	Local 	aAdvSize	:= {} 
   	Local 	aObjSize	:= {} 
   	Local 	aInfoAdvSize:= {}
   	Local 	aObjCoords	:= {}
   	Local lLog		:= .F.
   	
	Private cCadastro 	:= OemToAnsi(STR0004) 				// "Subir XML"
	Private cPathFile	:= ""
	Private cCodConfAd	:= ""
	Private cRFCProv	:= ""	
	Private cFornec		:=''
	Private cLoja  		:=''
	Private cUUID		:=""
	Private dDtFact		:=ctod("  /  /  ")
	Private dFecTim		:=ctod("  /  /  ")
	Private nTOTFAC		:=0
	Private nSubtot		:=0
	Private cDIRCSD		:= SuperGetMV("MV_DIRCSD",.F.," ")
	Private cDIRXML		:= SuperGetMV("MV_DIRXML",.F.," ")
	Private cXMLPro 		:= SuperGetMV("MV_XMLPRO",.F.," ")
	Private aLogErr		:= Array(3,0)
	Private oXML			:= NIL
	Private __aCPP		:= {}
	Private __aCPQ		:= {}
	Private cRutDoc		:= ""
	Private cFName		:= ""
	Private  lAdd			:= .F.
	
	
	dbSelectArea("CPO")
	dbSelectArea("CPR")
	dbSelectArea("CPQ")
	dbSelectArea("CPP")
	 
	aAdvSize:= MsAdvSize( NIL , .F. ) 
   	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
   	aAdd( aObjCoords , { 000 ,50 , .T. , .F. } )
	aAdd( aObjCoords , { 80 , 100 , .T. , .F. } ) 
   	aObjSize:= MsObjSize( aInfoAdvSize , aObjCoords ) 
   	
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( cCadastro ) From 0,0 TO 300,600 OF GetWndDefault() PIXEL 
	         			      
		@  10,10 	SAY 	STR0010   	pixel															//"Para realizar una carga con exito de las facturas, deben considerarse las siguientes configuraciones: "
		@  38,10 	SAY 	STR0011  	pixel															//"MV_DIRCSD, Directorio dentro del Protheus_Data, donde esta localizado el archivo de certificados." 
		@  48,41 	SAY 	OemToAnsi(STR0014) + cDirCsd  	pixel									// "Contenido actual: " 
    	@  65,10 	SAY 	STR0012  	pixel															// "MV_DIRXML, Directorio dentro del Protheus_Data, donde estan las facturas para cargar en el formato XML."
    	@  75,41 	SAY 	OemToAnsi(STR0014) + cDirXML pixel    			       			// "Contenido actual: "  
    	@  92,10 	SAY 	STR0013 + " " + STR0040   	pixel										// "MV_XMLPRO, Directorio dentro del Protheus_Data, donde se colocaran los archivos XML procesados" ## "con exito."	
    	@ 102,41 	SAY 	OemToAnsi(STR0014) + cXMLPro pixel									//"Contenido actual: "
	    
		oBoton1:=SButton():New(130,150,5,{||Pergunte("MATA458", .T.) 	},oDlg,.T.,STR0037,) // Par�metros				
		oBoton2:=SButton():New(130,190,1,{||M458XMLProc(),oDlg:End()	},oDlg,.T.,STR0038,) // Ok
		oBoton3:=SButton():New(130,230,2,{||oDlg:End()					},oDlg,.T.,STR0039 ,)// Anular 
		
	ACTIVATE MSDIALOG oDlg  CENTERED

	RestArea(aArea)

Return 


Static Function m458XMLProc()
	Local lRun := .F.
	Local aArea:= getArea()
	Local cMsg := STR0076		// "Proceso Cancelado "
	Local cPDFo:= ""				//Origen
	Local cPDFd:= ""				//Destino
	Local lret := .F. 
	
	Private aErrCod := {}
	
	Pergunte("MATA458", .F.) 
	cPathFile 	:= MV_PAR01
	//cRFCProv	:= MV_PAR02
	//Saca el codigo de adenda de acuerdo al proveedor
	
	lRun := fValParam()
	
	If lRun
		cFName := ALLTRIM(Substr(cPathFile,rat("\",cPathFile) + 1))
		Processa({|| xmlProc()  },) 
			
		If len(aLogErr[1]) > 0 .or. len(aLogErr[2]) > 0 .or. len(aLogErr[3]) > 0
			//Ver Log de Errores	
			lLog:= MsgYesNo(STR0016,STR0050)		// "Errores encontrados, �Desea verificar el Log?" "TOTVS"
			
			If lLog 
				
				//Generar Log Errores
				MsAguarde( { || fMakeLog( aLogErr,;
											 {STR0078,STR0083,STR0079} , ; //  "Errores del Certificado de la factura:" "Errores en la Configuraci�n de la Addenda:" "Errores encontrados en la Addenda:"
											 "MATA458" ,;
											  NIL ,;
											  FunName() ,;
											  STR0069 ) } ,; // "Log de Errores Carga de Factura"
											  STR0069 ) 		// "Log de Errores Carga de Factura"
				
			EndIf	
			lrun:=.f.
		Else
		
			cRutDoc := substr(cXMLPRO + "\" + cFName,1,rat(".xml",cXMLPRO + "\" + cFName)-1)	 
			Processa( {|lRet|GravaFac(@lRet)},,, .T. )
			
			//Copiar el archivo a la ubicaci�n definida en el par�metro		
			IF !(len(aLogErr[1]) >0 .or. len(aLogErr[2]) > 0)	
				cPDFo := cDirXML + "\" + Substr(cFName,1,rat(".",cFName)) +"pdf"
				cPDFd :=  cXMLPRO + "\" + Substr(cFName,1,rat(".",cFName)) +"pdf"
				IF FILE(cPDFo) // Si existe la factura en pdf, se mueve a la ruta definida junto con el xml
					If File(cPDFd)
						Ferase(cPDFd)
					EndIF
					__CopyFile(cPDFo,cPDFd )	
					Ferase(cPDFo)			
				EndIf
				
				If File(cXMLPRO + "\" + cFName)	
					fErase(cXMLPRO + "\" + cFName)
				EndIf
				//Guardamos el archivo en la ruta destino
				SAVE oXml XMLFILE (cXMLPRO + "\" + cFName)	
								
				//Borramos el archivo de la ruta de origen
				fErase(cPathFile)
				
			EndIf
			
		EndIF 
		
	EndIF // del lRun
	LogErrCod(lRun)   
	
	aLogErr:= Array(3,0)
	oXML := Nil
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �LogErrCod � Autor � Alex Hernandez        � Data �13/10/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o � AVISO para productos estan registrados o no en Protheus    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �LogErrCod()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA458                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/



Static Function LogErrCod(lrun)
	Local cErrCod  := ""
	Local oDlg
	Local oBtn 
	Local oMemo 
	Local nJ  := 0
	
	IF Len(aErrCod) > 0
	
		cErrCod += STR0091 + Chr(13) + Chr(10) + Chr(13) + Chr(10)    //"Los datos obligatorios de la factura fueron cargados con �xito. "
		cErrCod += STR0092 + Chr(13) + Chr(10) 						  //"AVISO: Algunos c�digos de producto de la factura no tienen sus"
		cErrCod += "             "  + STR0093 + Chr(13) + Chr(10) 			  // "equivalentes registrados en Protheus y se cargaron vac�os : "
		
		For nJ := 1 To Len(aErrCod)
			cErrCod += Chr(13) + Chr(10) + "             "  + aErrCod[nJ]    
		Next
      
		DEFINE MSDIALOG oDlg FROM 0,0 TO 223,400 PIXEL TITLE STR0041 // "Atencion"
		oMemo:= tMultiget():New(5,5,{|u|if(Pcount()>0,cErrCod:=u,cErrCod)},oDlg,192,87,,,,,,.T.)
		oMemo:EnableVScroll(.T.)
		@ 95,169 BUTTON oBtn PROMPT STR0038 OF oDlg PIXEL ACTION oDlg:End() //OK
		
		ACTIVATE MSDIALOG oDlg CENTERED
		
	Else
	   if lRun
	   		if !lAdd
				 MsgInfo(STR0101,STR0041)//"Factura sin addenda fu� cargada con exito. Complemente la informaci�n en la opci�n Modificar!"	
			else
				MsgInfo(STR0080,STR0041) // "Factura cargada con exito."	//"Atencion"
			endif	
		endif
		
	EndIf


Return 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fValPAram � Autor � mayra.camargo         � Data �24/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Evalua que se tenga la config, necesaria para el proceso.   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �fValPAram()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA458                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fValPAram()
	Local lRet := .T.

	Local aArea := getArea()
	/*//Validaci�n de Par�metro MV_DIRCSD
	If Empty(cDirCSD)
		Help( ,, OemToAnsi(STR0041),, OemToAnsi(STR0042) ,1, 0 )	//"Atencion" "Debe configurar parametro MV_DIRCSD."
		lRet := .F.
	Else
		//Verificar que exista ruta
		IF !(ExistDir(cDirCSD))
			Help( ,, OemToAnsi(STR0041),, OemToAnsi(STR0031) + cDirCSD + OemToAnsi(STR0032) ,1, 0 ) // "Atencion" "La ruta"  "para obtener los archivos de certificados vigentes no existe."
			lRet := .F.
		else
		
			If !File(cDIRCSD+"CSDSAT.DBF") .AND. !File(cDIRCSD+"CSDSAT.DTC")
				//"Atencion"  "Los archivos CSDSAT no existen en la carpeta "
				Help( ,, OemToAnsi(STR0041),, OemToAnsi(STR0102) + cDirCSD  ,1, 0 )
				lRet := .F.
			endif
		endif		
	EndIf*/
	// Valida que exista la tabla CSDSAT en la BD
	If !TCCanOpen("CSDSAT")
		Help( ,, OemToAnsi(STR0041),, OemToAnsi(STR0107)   ,1, 0 ) // "Ejecute rutina Archivo SAT(MATA029) para generar Archivo de Certificados Vigentes"
		lRet := .F.			
	EndIf	
	//Validaci�n de Par�metro MV_DIRXML
	If Empty(cDirXML)
		Help( ,, OemToAnsi(STR0041),, OemToAnsi(STR0043) ,1, 0 )  // "Atencion" "Debe configurar parametro MV_DIRXML."
		Return .F.
	Else
		//Verificar que exista ruta
		IF !(ExistDir(cDirXML))
			Help( ,, OemToAnsi(STR0041),, OemToAnsi(STR0034) + cDirXML + OemToAnsi(STR0045) ,1, 0 ) // "Atencion" "Directorio " "donde se encuentran las facturas XML no existe."
			Return .F.
		EndIF
	EndIF
	
	//Validaci�n de Par�metro MV_XMPPRO
	If Empty(cXMLPro)
		Help( ,, OemToAnsi(STR0041),, OemToAnsi(STR0044) ,1, 0 ) // "Atencion" "Debe configurar parametro MV_XMLPRO."
		lRet := .F.
	Else
		//Verificar que exista ruta
		IF !(ExistDir(cXMLPro))
			Help( ,, OemToAnsi(STR0041),, OemToAnsi(STR0034) + cXMLPro + OemToAnsi(STR0035) ,1, 0 ) //"Atencion"  "Directorio" "donde se encuentran las facturas XML no existe."
			lRet := .F.
		EndIF
	EndIF
	
	//Validar que exista Ruta del archivo
	If !Empty(cPathFile)
		If !(File(cPathFile))
			Help( ,, OemToAnsi(STR0041),, OemToAnsi(STR0030) ,1, 0 ) //"Atencion" "El archivo o la localizacion del archivo que subira no existen."
			lRet := .F.
		EndIF
	Else
		Help( ,, OemToAnsi(STR0041),, OemToAnsi(STR0048) ,1, 0 )//"Atencion" "Informe ruta del archivo XML que se procesara."	
		lRet := .F.
	EndIF

	
	RestArea(aArea)		
Return lRet
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �XMLProc   � Autor � mayra.camargo         � Data �24/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Realiza el proceso del xml.                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �XMLProc()                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA458                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function XMLProc()
	Local aArea	:= getArea()
	Local oAdden	:= Nil
	Local cAviso := ""
	Local cErro	:= ""
	Local cAlias	:= "CSDSAT"
	Local cNoFact	:= ""
	Local cFecha	:= ""	
	Local cRFC	:= ""
	Local aCposH	:= {}
	Local aCposD	:= {}
	Local dDTIni	
	Local dDtFim	
	Local lCFDI	:= .F.		//Indica si est� leyendo un CFDI, si es .F. significa que leee un CFD
	Local nI 		:= 0
	Local cPref	:= ""		
	Local cData	:= ""
	Local cRFCRec	:= "" 
	Local cElem	:= ""
	Local xNodo	:= ""
	Local nX		:= 0
	Local nTElem	:=0
	Local cTitulo	:= ""
	Local uEval	:= Nil
	Local aAux	:= {}
	Local aCposObr 	:= {}
	Local aCposADd 	:= {}
	Local cEvalCad 	:= ""
	Local cRutDet		:= "" 
	Local lCopy		:= .F.
	Local cFecTim		:= "" 		
	Local cDrive		:= ""
	Local cPDF		:= ""
	Local cCampo		:= ""
	Local cNumFac		:= ""
	Local cSerie		:= ""
	Local cProveedor	:= ""
	Local aFechas    := {}
	Local lValCerf	:= .f.

	ProcRegua(5)
		
	If !(Select(cAlias) > 0)	
		//Si no existe el alias, lo crea.
		dbUseArea(.F.,"TOPCONN",cAlias,cAlias,.T.,.F.) 
	EndIf
	
	dbSelectArea(cAlias)
	(cAlias)->(dbSetIndex("CSDSAT"))
	(cAlias)->(dbSetOrder(1))
			
	IncProc(STR0015)		// "Validando archivo..."
		
	SplitPath ( cPathFile, @cDrive, , ,  )
	cPDF := Substr(cPathFile,1,rat(".",cPathFile)) + "pdf"
	
	If !Empty(cDrive)
		//Copiar xml al server	
		lCopy := CpyT2S( cPathFile, cDirXML )
		
		If File(cPDF) // si existe el pdf en la ruta local, se mueve junto con le xml al servidor.
			CpyT2S(cPDF, cDirXML )	//Copiar el pdf
		EndIf
	Else
		lCopy := .T.
	EndIf
				
	If lCopy
		//Leer XML 	
		cPathFile := cDirXML + "\" + cFName
		oXML 	:= XmlParserFile( cPathFile, "_", @cAviso,@cErro )
		 
		IF Empty(cAviso) .and. Empty(cErro) .and. oXML <> NIL	
		
			If XmlChildEx(oXML, "_CFDI_COMPROBANTE") <> Nil			
				lCfdi := .T.	
				cPref := "_CFDI"		
			EndIf
			
			If ObtUidXML(oXML,"UUID")
				If lCfdi
					cUUID 	:= IIf(XmlChildEx(oXML:_CFDI_COMPROBANTE, cPref + "_COMPLEMENTO") <> Nil,oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT,"")
					cRFC 	:= IIf(XmlChildEx(oXML:_CFDI_COMPROBANTE:_CFDI_EMISOR, "_RFC") <> Nil,oXML:_CFDI_COMPROBANTE:_CFDI_EMISOR:_RFC:TEXT,"") 
					cRFCRec := IIf(XmlChildEx(oXML:_CFDI_COMPROBANTE:_CFDI_RECEPTOR, "_RFC") <> Nil,oXML:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_RFC:TEXT,"")
					cFecTim := IIf(XmlChildEx(oXML:_CFDI_COMPROBANTE, cPref + "_COMPLEMENTO") <> Nil,Substr(oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT,1,10),"") 
					nTOTFAC := oXML:_CFDI_COMPROBANTE:_TOTAL:TEXT
					nSubtot := oXML:_CFDI_COMPROBANTE:_SUBTOTAL:TEXT
				Else
					cUUID 	:= IIf(XmlChildEx(oXML:_CFDI_COMPROBANTE, cPref + "_COMPLEMENTO") <> Nil,oXML:_COMPROBANTE:_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT,"") 
					cRFC  	:= IIf(XmlChildEx(oXML:_CFDI_COMPROBANTE:_CFDI_EMISOR, "_RFC") <> Nil,oXML:_CFDI_COMPROBANTE:_CFDI_EMISOR:_RFC:TEXT,"")
					cRFCRec := IIf(XmlChildEx(oXML:_COMPROBANTE:_RECEPTOR, "_RFC") <> Nil,oXML:_COMPROBANTE:_RECEPTOR:_RFC:TEXT,"")
					cFecTim:= IIf(XmlChildEx(oXML:_CFDI_COMPROBANTE, cPref + "_COMPLEMENTO") <> Nil,Substr(oXML:_COMPROBANTE:_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT,1,10),"")
					nTOTFAC:=oXML:_COMPROBANTE:_TOTAL:TEXT
					nSubtot:=oXML:_COMPROBANTE:_SUBTOTAL:TEXT
				EndIf
				cFecTim := strTran(cFecTim,"-",,)                    
				dFecTim:= STOD(cFecTim)
				cRFCProv 	:= Alltrim(crfc)	
				//Validacion de proveedor en base a RFC
				dbSelectArea("SA2")
				SA2->(dbSetOrder(3)) //A2_FILIAL + A2_CGC		
				If !(SA2->(dbSeek(xFilial("SA2") + Alltrim(cRFCProv))))//ExistCpo("SA2", cRFCProv,nIndSA2)
					AAdd(aLogErr[1],STR0036) //"RFC inexistente en el catalogo de proveedores."
					Return .F.
				Else
				   cFornec :=SA2->A2_COD
			       cLoja   :=SA2->A2_LOJA
				   cCodConfAde	:= SA2->A2_ADDENDA  //Saca el codigo de addenda
	
					If len(cRFCProv) < 13
						cRFCProv:= alltrim(cRFCProv+"|")
					EndIF						
				
					//obtiene las vigencia del certificado del archivo CSD
					If (cAlias)->(DbSeek(cRFCProv))
						Do while !(cAlias)->(eof()) .and. (cRFCProv)==alltrim((cAlias)->rfc)//.and. alltrim(cRFCProv)==alltrim(substr((cAlias)->rfc,1,12))
							//Leer fecha de inicio y fin del RFC seg�n archivo del SAT
							dDtIni := STOD(strTran(Substr((cAlias)->FEC_INI,1,10)	,"-",,))
							dDtFim := STOD(strTran(Substr((cAlias)->FEC_FIN,1,10)	,"-",,))
							   
							aadd(afechas,{dDtIni,dDtFim})
							(cAlias)->(DbSkip())
						EndDo
					EndIf	
				EndIf					
				//Validar fecha de la factura y elemento uuid
				If ObtUidXML(oXML,"FECHA")
					If lCfdi
						cFecha := substr(oXML:_CFDI_COMPROBANTE:_FECHA:TEXT,1,10)							
					Else
						cFecha := substr(oXML:_COMPROBANTE:_FECHA:TEXT,1,10)
					EndIf		
					cFecha := strTran(cFecha,"-",,)                    
					dDtFact:= STOD(cFecha)
					
					lValCerf:= .f.
					For nx:=1 to len(aFechas)
					    If dDtFact >= aFechas[nx,1] .and. dDtFact<= aFechas[nx,2]
					    	lValCerf:= .t.
					       exit
					    EndIf
					Next nx
					
					If !lValCerf
						AAdd(aLogErr[1],STR0021)// "El certificado de la factura no es vigente."
						Return .F.				
					EndIf										
				Else
					AAdd(aLogErr[1],STR0049)// "La fecha de la factura no fue informada en el archivo xml."
					Return .F.								
				EndIf
				
				If Empty(cUUID)
					AAdd(aLogErr[1],STR0022)// "Factura sin Folio fiscal(UUID)."
					//Return .F.	
				Else
					If fFindUUID(cUUID)
						AAdd(aLogErr[1],STR0081)// "Esta factura ya fue procesada anteriormente."
					EndIf
				EndIf
				
				If Empty(dFecTim)
					AAdd(aLogErr[1],STR0089) // "Factura sin fecha de timbrado."
				EndIf
				
			Else
				AAdd(aLogErr[1],STR0028)// "Sin Folio Fiscal (UUID)"
				//Return .F.						
			EndIF
			
			If Empty(cRFC)
				AAdd(aLogErr[1],STR0072)// "El RFC no fue informado dentro de la factura."
			ElseIf !(Alltrim(cRFC) $ Alltrim(cRFCProv))
				// Debe coincidir el RFC del proveedor seleccionado con el RFC del a factura
				AAdd(aLogErr[1],STR0073)// "El RFC seleccionado no coincide con el RFC informado en la factura."
			EndIf
						
			If Empty(cRFCRec)
				AAdd(aLogErr[1],STR0074)// "El RCF del Receptor no fue informado en la factura."
			ElseIf Alltrim(SM0->M0_CGC) <> Alltrim(cRFCRec)
				// Debe coincidir el RFC del proveedor seleccionado con el RFC del a factura
				AAdd(aLogErr[1],STR0075 + SM0->M0_CGC)// "El RCF del Receptor informado en la factura no corresponde con el registrado para la empresa:  "
			EndIF
								
			// Traer los campos obligatorios de la addenda de la CPO
			IncProc(STR0015)	// "Validando archivo..."		
			lAdd := fGetCamposAdd(cCodConfAde,@aCposH,@ACposD,@cRutDet,@aCposAdd)
							
			//Verificar que hasta aqu� no haya errores
			If !(Len(aLogErr[2])  > 0 .or. Len(aLogErr[1]) > 0  )
				If lAdd	 // Si encontr� la configuraci�n seleccionada
					If Len(aCposH) > 0
						dbSelectArea("CPP")
						IncProc(STR0084) //"Validando el contenido del archivo XML..."
						For	 nI:=1 TO Len(aCposH)
							cCampo := allTrim(aCposH[nI,3])
									//cEvalCad := 	"oXML:" +cPref+"_COMPROBANTE:" + cPref + "_"+  ALLTRIM(aCposH[nI,4]) + ":TEXT"
									If 	("COMPROBANTE" $  ALLTRIM(aCposH[nI,4]))																	
										cEvalCad := 	"oXML:" +  ALLTRIM(aCposH[nI,4]) + ":TEXT"
									Else
										cEvalCad := 	"oXML:" +cPref+"_COMPROBANTE:" + cPref + "_"+  ALLTRIM(aCposH[nI,4]) + ":TEXT"
									EndIf																			
									If GenErro(cEvalCad,aCposH[nI,5],aCposH[nI,3])									
										uEval := &(cEvalCad)
										If aCposH[nI,5].and. Empty(uEval) 						//Verificamos que el campo si es obligatorio
											cTitulo := fgetTitle(aCposH[nI,3])					//en la conf de addenda, no est� vac�o
											//Si esta vac�o se agrega un mensaje al log de errores.
											AADD(aLogErr[3],STR0068 + cTitulo )				 //  "La factura no posee el campo"
										EndIf		
										AADD(__aCPP,{aCposH[nI,3],uEval})					// Si no hubo ning�n problema agregamos el campo al array																																											
									EndIf																		
						Next nI
					EndIf
					
					cEvalCad	:= ""
					cRutDet	:= "oXML:"+ cRutDet
					
					If Len(aCposD) > 0 .and. !Empty(cRutDet)
						IncProc(STR0084)							//"Validando el contenido del archivo XML..."
						If Valtype(&cRutDet) <> "O" 			// Verificar que el detalle sea array				
							//Se guardan los datos del detalle
							nTElem := len(&CRutDet)		
						Else										// Tratamiento como objeto
							nX := 1
							nTElem := 1
							cElem := ""
						EndIf	
					
						For nX :=1 to nTElem 
							If nTElem > 1
								cElem:= "["+ alltrim(STR(nX))+ "]"
							EndIf
																
							For nI:=1 to Len(aCposD)
								cCampo := alltrim(aCposD[nI,3])
								If 	("COMPROBANTE" $  ALLTRIM(aCposD[nI,4])	)																
									cEvalCad := 	"oXML:" +  ALLTRIM(aCposD[nI,4]) + ":TEXT"
								Else
									cEvalCad := 	"oXML:" +cPref+"_COMPROBANTE:" + cPref + "_"+  ALLTRIM(aCposD[nI,4]) + ":TEXT"
								EndIf
																																							
								cEvalCad := strTran(cEvalCad,cRutDet,cRutdet+cElem)
																																											
								If GenErro(cEvalCad,aCposD[nI,5],aCposD[nI,3])
									uEval := &(cEvalCad)
									If aCposD[nI,5].and. Empty(uEval)
										cTitulo := fgetTitle(aCposD[nI,3])
										AADD(aLogErr[3],STR0068 + cTitulo +STR0070 ) // "La factura no posee el campo" "- Obligatorio"
									EndIf
									AADD(aAux,{aCposD[nI,3],uEval})		// Agregamos campo y valor al array de detalle														
								EndIf																																																																			
							Next nI										
							AADD(__aCPQ,aAux)		//Agregamos array de detalle x campo a Array de detalle por item 
							aAux := {}																		
						Next nX					
					EndIf																	 													
				Else //cuando no hay adenda, obtiene  los datos que estan como requeridos de XML
				        cRutDet	:= "oXML:_CFDI_COMPROBANTE:_CFDI_CONCEPTOS:_CFDI_CONCEPTO"
						IncProc(STR0084) //"Validando el contenido del archivo XML..."	
						nTElem := 1  
						cElem := ""
						If Valtype(&cRutDet) <> "O" 			// Verificar que el detalle sea array				
								//Se guardan los datos del detalle
								nTElem := len(&CRutDet)		
						EndIf	
						
						For nX :=1 to nTElem 
							If nTElem > 1
									cElem:= "["+ alltrim(STR(nX))+ "]"
							EndIf               
							
							cEvalCad :=cRutDet+":_CANTIDAD:TEXT"											
							cEvalCad := strTran(cEvalCad,cRutDet,cRutdet+cElem)
							uEval    := &(cEvalCad)                             
							AADD(aAux,{"CPQ_QUANT",uEval})	
							
							cEvalCad :=cRutDet+":_VALORUNITARIO:TEXT"											
							cEvalCad := strTran(cEvalCad,cRutDet,cRutdet+cElem)
							uEval    := &(cEvalCad)         
							AADD(aAux,{"CPQ_VUNIT",uEval})	
						
							cEvalCad :=cRutDet+":_IMPORTE:TEXT"											
							cEvalCad := strTran(cEvalCad,cRutDet,cRutdet+cElem)
							uEval    := &(cEvalCad)         
							AADD(aAux,{"CPQ_TOTAL",uEval})	
							
							AADD(__aCPQ,aAux)		//Agregamos array de detalle x campo a Array de detalle por item 
							aAux := {}	
						Next nX
				EndIf
			EndIf						
		Else
			AAdd(aLogErr[1],OemToAnsi(STR0030)) //"El archivo o la ubicaci�n del archivo a subir no existen."
		EndIf	
	Else
		AAdd(aLogErr[1],OemToAnsi(STR0088)) //"Error al tratar de copiar archivo al servidor."
	EndIf	
	
 	(cAlias)->(dbCloseArea())
 
 	RestArea(aArea) 	
Return 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GenErro   � Autor � mayra.camargo         � Data �24/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o |Eval�a una expresi�n y returna si encuentra error.          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �GenErro(cEval,lOblig,CCAMPO)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Expresi�n a evaluar                                ���
���          � ExpN2 : Indica si el campo es obligatorio o no             ���
���          � ExpN3 : Campo a evaluar                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA458                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GenErro(cEval,lOblig,CCAMPO)
	
	Local lRet 	:= .T.
	Local xResul	
	Local cErro	
	
	Default cEval := .T.
	
	bBlock := ErrorBlock({|e| MT458ERR(e,lOblig,cCampo)  })//ErrorBlock( { |e| ChecErro(e) } )
	BEGIN SEQUENCE
		xResult := &cEval
	RECOVER
		lRet := .F.
	END SEQUENCE
	ErrorBlock(bBlock)

Return lRet

Static Function MT458ERR(oError,lOblig,cCampo)
	Local aArea	 := getArea()
	Local cTitulo
	If oError:gencode > 0
				
		cTitulo := fgetTitle(cCampo)
		
		If lOblig
			AADD(aLogErr[3],STR0068 + cTitulo + IIF(lOblig, STR0070,"")) //"La factura no posee el campo" "- Obligatorio"
		EndIf
		Break
		
	EndIF
	RestArea(aArea)
Return 



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fGetTitle � Autor � mayra.camargo         � Data �24/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o |Obtiene el t�tulo de un campo en la SX3.                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �fGetTitle(cCampo)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Nombre del campo                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA458                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static function fGetTitle(cCampo)
	Local cTitulo	:= ""
	Local aArea	:= getArea()
	
	dbSelectARea("SX3")
	SX3->(dbSetOrder(2)) //X3_CAMPO
	If SX3->(dbSeek(cCampo))	 
		cTitulo := SX3->X3_TITULO
	EndIf
	RestArea(aArea)
Return cTitulo
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fGetCamposCPO� Autor � mayra.camargo      � Data �24/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o |Obtener los campos de la configuraci�n de la Addenda        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �fGetCamposCPO(cCodAdd,aEnc,aDet,cDetalle)                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA458                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
// Obtener los campos de la configuraci�n de la Addenda
Static function fGetCamposAdd(cCodAdd,aEnc,aDet,cDetalle,aCposT)
	Local lRet 	:= .F.
	Local aArea 	:= getArea()
	Local lObliga := .F.
		
	Default aEnc := {}
	Default aDet := {}
	Default cCodAdd 	:= CPO->CPO_CONFIG
	Default cDetalle	:= ""
	Default aCposT	:= {}
	
	cDetalle := POSICIONE("CPR",1,XFILIAL("CPR")+cCodAdd,"CPR_DETADD")
	
	dbSelectArea("CPO")	
	CPO->(dbSetOrder(1)) // CPO_FILIAL+CPO_CONFIG+CPO_CAMPO
	lRet:= CPO->(dbSeek(XFILIAL("CPO")+cCodAdd))
	IF lRet 
		While (CPO->CPO_FILIAL + CPO->CPO_CONFIG) == XFILIAL("CPO")+cCodAdd
		
			lObliga := IIF(CPO->CPO_OBLIGA == '1',.T.,.F.)
					
			If "CPP" $ CPO->CPO_CAMPO
				aAdd(aEnc,{CPO->CPO_FILIAL,CPO->CPO_CONFIG,CPO->CPO_CAMPO,CPO->CPO_ELEMEN,lObliga})
			Else
				aAdd(aDet,{CPO->CPO_FILIAL,CPO->CPO_CONFIG,CPO->CPO_CAMPO,CPO->CPO_ELEMEN, lObliga})
			EndIF		
			aAdd(aCposT,{CPO->CPO_CAMPO,lObliga})
			CPO->(dbSkip())
		EndDo	
	EndIf			
	RestArea(aArea)

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ObtUidXML � Autor � mayra.camargo         � Data �24/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o |Busca un determinado nodo en un xml.                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �ObtUidXML(oXML,cNodo)                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA458                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ObtUidXML(oXML,cNodo)

	Local cXML     	:= ""     
	Local cError   	:= ""
	Local cDetalle	:= ""   
	Local lRet     	:= .F.
	
	If valType(oXml) == "O"				//Es un objeto
		SAVE oXml XMLSTRING cXML
	
		If AT( "ERROR" , Upper(cXML) ) > 0	// El archivo tiene errores
			If 	ValType(oXml:_ERROR) == "O"
				cError   := oXml:_ERROR:_CODIGO:TEXT
				cDetalle := oXml:_ERROR:_DESCRIPCIONERROR:TEXT   
		   Endif
		Else		//Obtener identificador del certificado 				
			If At( UPPER(cNodo) , Upper(cXml) ) > 0
				lRet := .T. 
			Endif
		Endif
	Endif
	
Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GravaFac  � Autor � mayra.camargo         � Data �24/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Realiza proceso de gravado de datos en sus respectivas tabla���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �GravaFac()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA458                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GravaFac(lRet)
	Local nI  := 0
	Local nX  := 0
	Local cTmpFil := ""
	
	Local nIndSA5 := RETORDEM("SA5","A5_FILIAL+A5_FORNECE+A5_LOJA+A5_CODPRF")
	
	Local nTamCOD := TamSX3( "CPQ_COD" )[1] 
	Local nTamIte := TamSX3( "CPQ_ITEM" )[1] 
	Local  nItem:=1
	Local  cItem:=''
	
	DEFAULT lRet := .F.
	
	ProcRegua(len(__aCPP)+len(__aCPQ))
	Begin Transaction
	RecLock("CPP",.T.)
	CPP->CPP_FILIAL:=XFILIAL("CPP")
	For nI:= 1 to len (__aCPP)
		IncProc(STR0085) //"Guardando datos de la factura..."
		GravaCpo("CPP",__aCPP[nI,1],__aCPP[nI,2])
		
	Next
	CPP->CPP_UUID:=cUUID			
	CPP->CPP_EMISSA:=dDtFact
	CPP->CPP_FECTIM:=dFecTim		
	
	CPP->CPP_FORNEC:=CFORNEC
	CPP->CPP_LOJA:=CLOJA
	CPP->CPP_RUTDOC := cRutDoc
	
	CPP->CPP_VALBRU :=IF (VALTYPE(NTOTFAC)="C",VAL(NTOTFAC),NTOTFAC)
	CPP->CPP_VALMER :=IF (VALTYPE(NSUBTOT )="C",VAL(NSUBTOT ),NSUBTOT )
	
	CPP->(MsUnlock())	
	nI:= 0
	
	dbSelectArea("SA5")
	
	SA5->(dbSetOrder(nIndSA5)) 
	cTmpFil := XFILIAL("SA5")
	
	For nI:= 1 to len(__aCPQ)
	   cItem:=strzero(nItem,nTamIte)
		RecLock("CPQ",.T.)
		CPQ->CPQ_FILIAL:=XFILIAL("CPQ")
		CPQ->CPQ_ITEM:=cItem
		For nX := 1 to Len(__aCPQ[nI])
			IncProc(STR0085) //"Guardando datos de la factura..."
			IF AllTrim(__aCPQ[nI,nX,1]) == "CPQ_COD"
			    
				If SA5->(dbSeek(cTmpFil + CFORNEC + CLOJA + PADR(__aCPQ[nI,nX,2],nTamCOD," "))) 
					GravaCpo("CPQ",__aCPQ[nI,nX,1],SA5->(A5_PRODUTO))
				ELSE
					GravaCpo("CPQ",__aCPQ[nI,nX,1],"")
					aadd(aErrCod,AllTrim(__aCPQ[nI,nX,2])) 
				EndIf
				
				
			ELSE
				GravaCpo("CPQ",__aCPQ[nI,nX,1],__aCPQ[nI,nX,2])
			ENDIF
		Next
		CPQ->CPQ_FORNEC:=CFORNEC
       CPQ->CPQ_LOJA:=CLOJA
       CPQ->CPQ_DOC:=CPP->CPP_DOC
       CPQ->CPQ_SERIE:=CPP->CPP_SERIE
       CPQ->CPQ_UUID:=CPP->CPP_UUID
       
            
		CPQ->(MSUnlock())
		nItem++
	Next
	End Transaction
	
	
Return 


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GravaCpo  � Autor � mayra.camargo         � Data �24/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Guarda el campo en la tabla indicada                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �GravaCpo(cTab,cCampo,cEvalCad)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Tabla de la BD                                     ���
���          � ExpN2 : Campo campo perteneciente a ctabla en la BD        ���
���          � ExpN3 : Ruta en el xml de donde se obtiene la inf a salvar.���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA458                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

//GUARDA EL CAMPO EN LA TABLA INDCICADA
Static function GravaCpo(cTab,cCampo,uContenido)
	Local cData := ""
	Do case
		Case TamSX3(cCampo)[3] $ "CM"
			(cTab)->(&(cCampo)) := uContenido
		Case TamSX3(cCampo)[3] $ "N"
			(cTab)->(&(cCampo)) := VAL(uContenido)
		Case TamSX3(cCampo)[3] $ "D"
			If ValType(uContenido) <> "D"
				cData := Substr(uContenido,1,10)
				cData := strTran(cData,"-",,)     
				(cTab)->(&(cCampo)) := STOD(cData)
			Else
				(cTab)->(&(cCampo)) := uContenido
			EndIf
	End Case	
	// Si es codigo de producto, obtiene la UM TES y Deposito del Codigo de producto
	IF  ALLTRIM(cCampo)=="CPQ_COD"
        if SB1->(DBSEEK(xfilial("SB1")+uContenido))
            CPQ->CPQ_TES:=SB1->B1_TE
            CPQ->CPQ_UM:=SB1->B1_UM
            CPQ->CPQ_LOCAL:=SB1->B1_LOCPAD
            
        endif	
	ENDIF
Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fFindUUID � Autor � mayra.camargo         � Data �24/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Busca una factura en la CPP con el uuid a cargar            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �fValidaObr(aCpoObr,aCpoAdd,aError)                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Elemento uuid a buscar.                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA458                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fFindUUID(cDato)
	Local aArea:= getArea()
	Local lRet := .F.
	dbSelectArea("CPP")
	CPP->(dbSetOrder(2))
	
	If CPP->(dbSeek(XFILIAL("CPP")+cDato))
		lRet := .T.
	EndIF
			
	RestArea(aArea)
Return lRet

/*
�����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �M458Leyen  �Autor � Alfredo Medrano       � Data �26/03/2014 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Descripcion de los colores de la leyenda de pedimentos.      ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ninguno                                                      ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �ninguno                                                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Importaciones para Mexico                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function M458Leyen()
//Leyenda
BrwLegenda(cCadastro,OemToAnsi(STR0081),aLeyenda) // "Esta factura ya fue procesada anteriormente."

Return(.T.)




static function M458INIMTO(NOPC,aColsCPQ)

 Local nPosQtd	:= aScan(aHeaderCPQ,{|x| AllTrim(x[2]) == "CPQ_QUANT"})
 Local nPosPU	:= aScan(aHeaderCPQ,{|x| AllTrim(x[2]) == "CPQ_VUNIT"})
 Local nPostes	:= aScan(aHeaderCPQ,{|x| AllTrim(x[2]) == "CPQ_TES"})
 Local nPosDto	:= aScan(aHeaderCPQ,{|x| AllTrim(x[2]) == "CPQ_VALDES"})	
 Local nx:=0
 Local cFilCPQ:=XFILIAL("CPQ")
 
	//genera informacion del getdados 
	aColsCPQ:={} 
	CPQ->(DBSETORDER(1)) //CPQ_FILIAL+CPQ_FORNEC+CPQ_LOJA+ CPQ_DOC+CPQ_SERIE+CPQ_ITEM+CPQ_COD
	IF CPQ->(DBSEEK(cFilCPQ+cOper+cLoja+cDoc+cSerie))
		DO WHILE !CPQ->(EOF()) .AND. ;
		 			CPQ->CPQ_FILIAL+CPQ->CPQ_FORNEC+CPQ->CPQ_LOJA+CPQ->CPQ_DOC+CPQ->CPQ_SERIE==cFilCPQ+cOper+cLoja+cDoc+cSerie
		 	//��������������������������������������������������������������Ŀ
			//� Llena el aCols para el getdados                              �
			//����������������������������������������������������������������	
				Aadd(aColsCPQ,Array(nUsado+1))
				nMaxLin ++
				For nX := 1 To nUsado
					IF aHeaderCPQ[NX][10]<>'V' 
						aColsCPQ[Len(aColsCPQ)][nX] := &("CPQ->"+aHeaderCPQ[nX,2]) 
					ELSE	                                      
						aColsCPQ[Len(aColsCPQ)][nX] := Eval(&( "{ || " + AllTrim( aHeaderCPQ[nX,12] ) + " }" ))
	
					ENDIF	
				Next nX
				aColsCPQ[Len(aColsCPQ)][nUsado+1] := .F.
				
			//��������������������������������������������������������������Ŀ
			//� Inicializa los arreglos de MATXFIX                           �
			//����������������������������������������������������������������
		
			if nOpc==4 .or. nOpc==2  //si altera
				If MaFisFound()
					MaFisIniLoad(Len(aColsCPQ))//inicializar a variavel aNFItem
					For nX := 1 To Len(aRefImpCPQ)
					Do Case
							Case aRefImpCPQ[nX][3] == "IT_QUANT"
								MaFisLoad(aRefImpCPQ[nX][3],cpq->cpq_quant,Len(aColsCPQ))
							Case aRefImpCPQ[nX][3] == "IT_PRCUNI"
								MaFisLoad(aRefImpCPQ[nX][3],cpq->cpq_vunit,Len(aColsCPQ))
							Case aRefImpCPQ[nX][3] == "IT_VALMERC"
								MaFisLoad(aRefImpCPQ[nX][3],NoRound(cpq->cpq_quant * cpq->cpq_vunit,TamSx3("CPQ_TOTAL")[2]),Len(aColsCPQ))
							Case aRefImpCPQ[nX][3] == "IT_DESCONTO"
								MaFisLoad(aRefImpCPQ[nX][3],cpq->cpq_valdes,Len(aColsCPQ))
							Case aRefImpCPQ[nX][3] == "IT_TES"
								MaFisLoad(aRefImpCPQ[nX][3],"",Len(aColsCPQ))
							OtherWise
								MaFisLoad(aRefImpCPQ[nX][3],CPQ->(FieldGet(FieldPos(aRefImpCPQ[nX][2]))),Len(aColsCPQ))
						ENDCase
								
					Next nX
				EndIf
				//if nOpc==4 //si altera
					N:=Len(aColsCPQ)
					AHEADER:= aHeaderCPQ
					ACOLS:=aColsCPQ
					MaFisRef("IT_TES","MT100",cpq->cpq_tes)
				//endif	
				
			EndIf	
	
		 	CPQ->(DBSKIP())
		 ENDDO
				
	ELSE
		Aadd(aColsCPQ,Array(nUsado+1))
		nMaxLin ++
		For nX := 1 To nUsado  
			IF aHeaderCPQ[NX][10]<>'V' 
				aColsCPQ[Len(aColsCPQ)][nX] := CriaVar("CPQ->"+aHeaderCPQ[nX,2],.T.)
			ELSE	                                                                  
				aColsCPQ[Len(aColsCPQ)][nX] := Eval(&( "{ || " + AllTrim( aHeaderCPQ[nX,12] ) + " }" ))
			ENDIF	
		Next nX
		aColsCPQ[Len(aColsCPQ)][nUsado+1] := .F. 
	ENDIF
	if nOpc==4
	 	MaFisEndLoad(Len(aColsCPQ))//1-(default) Executa o recalculo de todos os itens para efetuar a atualizacao do cabecalho/2-Executa a soma do item para atualizacao do cabeca /  3-Nao executa a atualizacao do cabecalho.
	endif 			
	/*
	//�������������������������������������������Ŀ
	//�Actualiza el pie de pagina                 �
	//���������������������������������������������
	*/
	
	nValFle	:= cpp->CPP_FRETE
	nValGas	:= cpp->CPP_DESPES
	nSeguro  	:= cpp->CPP_SEGURO
	nDescue	:= cpp->CPP_DESCON 		
	nValMer	:= cpp->CPP_VALMER
	nValBru	:= cpp->CPP_VALBRU
	
RETURN

/*
�����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �MTA458UP   �Autor � Alfredo Medrano       � Data �18/03/2016 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Actualiza los gastos cuando se elimina un item.              ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ninguno                                                      ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �ninguno                                                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Pre Factura para Mexico                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static function MTA458UP()

Local lBorro:=.f.

If !MaFisFound("IT",oGetCPQ:NAT)
      MaFisAdd("","",0,0,0,"","",,0,0,0,0,0)
EndIf
lBorro:=if (!oGetCPQ:aCols[oGetCPQ:NAT][Len(oGetCPQ:aCols[oGetCPQ:NAT])],.t.,.f.)
MaFisDel(oGetCPQ:NAT,lBorro)
Eval(bRefresh)   

Return .T.


/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �MA458ENC   � Autor � Alfredo Medrano       � Data �29/03/2016���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Actualiza el gasto, flete y seguro del encabezado           ���
��������������������������������������������������������������������������Ĵ��
���Parametros� N/A                                                         ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � X3_VALID ->  CPQ_SEGUR, CPQ_DESPES y CPQ_VALFR, CPQ_DESC    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function MA458ENC()

Local aArea	:= GetArea()
Local nx		:=1 
Local nPosVal:=0 
Local nValTot:=0
Local nPosTot	:=0
Local nPosVds:=0
Local cCampo:= readvar()	

If cCampo != NIL
	DO CASE
		CASE cCampo == "M->CPQ_VALFR"
			nValFle:=0
			nPosVal:=GdFieldPos("CPQ_VALFR",oGetCPQ:aHeader)
			MaFisAlt("IT_FRETE" , NoRound ( M->CPQ_VALFR,TamSx3("CPQ_VALFR")[2]) , N )
		CASE cCampo == "M->CPQ_DESPES"
			nValGas:=0
			nPosVal:=GdFieldPos("CPQ_DESPES",oGetCPQ:aHeader)
			MaFisAlt("IT_DESPESA" , NoRound ( M->CPQ_DESPES,TamSx3("CPQ_DESPES")[2]) , N )
		CASE cCampo == "M->CPQ_SEGUR"
			nSeguro:=0
			nPosVal:=GdFieldPos("CPQ_SEGUR",oGetCPQ:aHeader)
			MaFisAlt("IT_SEGURO" , NoRound ( M->CPQ_SEGUR,TamSx3("CPQ_SEGUR")[2]) , N )
		CASE cCampo == "M->CPQ_DESC"
			
			nPosVal:=GdFieldPos("CPQ_DESC",oGetCPQ:aHeader)
			nPosTot:=GdFieldPos("CPQ_TOTAL",oGetCPQ:aHeader)
			nPosVds:=GdFieldPos("CPQ_VALDES",oGetCPQ:aHeader)
			For nx:=1 to len(oGetCPQ:aCols)
				If N==NX
		    		nValTot+=NoRound(oGetCPQ:aCols[nx,nPosTot]*&(cCampo)/100,TamSx3("CPQ_VALDES")[2]) 
		    	Else  
		    		If oGetCPQ:aCols[nx,nPosVds] != 0
				   		nValTot+=NoRound(oGetCPQ:aCols[nx,nPosTot]*oGetCPQ:aCols[nx,nPosVal]/100,TamSx3("CPQ_VALDES")[2])
				   	EndIf
				EndIf
			Next
			
			M->CPP_DESCON:=nValTot
			oDescue:refresh()
			
	ENDCASE
	
	For nx:=1 to len(oGetCPQ:aCols)
	    If N==NX
	    	nValTot+=&(cCampo)
	    Else    
	    	nValTot+=oGetCPQ:aCols[nx,nPosVal]
	    EndIf	
	Next
	
	If cCampo == "M->CPQ_VALFR" 
		nValFle:=nValTot
		oValFle:refresh()
		M->CPP_FRETE:=nValFle
	EndIf
	If cCampo == "M->CPQ_DESPES"
		nValGas:=nValTot
		oValGas:refresh()
		M->CPP_DESPES:=nValGas
	EndIf
	If cCampo == "M->CPQ_SEGUR"
	 nSeguro:=nValTot
	 oSeguro:refresh()
	 M->CPP_SEGURO:=nSeguro
	 EndIf
	
	Eval(BREFRESH)

	oEnchCPP:refresh()
EndIf
RestArea(aArea)

Return .T.