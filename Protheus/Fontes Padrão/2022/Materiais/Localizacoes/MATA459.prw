#Include "PROTHEUS.Ch"
#Include "MATA459.ch"
#DEFINE  nPosForn 5  //PROVEEDOR
#DEFINE  nPosLoja 6  //TIENDA
#DEFINE  nPosDoc 2  //DOCTO
#DEFINE  nPosSeri 3  //SERIE
#DEFINE  nPosSeID 11 //Serie+id, adicionado em 27/04/15 Tiago Silva PRJ Chave Unica
#DEFINE  nPosFolF 10 //FOLIO FISCAL  


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n   � MATA459  � Autor � alfredo.medrano     � Data �  20/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Generar Facturas                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATA459()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Pasar las Facturas en validaci�n a Facturas de entrada     ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador   � Data   � BOPS/FNC  �  Motivo da Alteracao              ���
�������������������������������������������������������������������������Ĵ��
���Alfred Medrano�28/01/15�  TRMLLG   �Se Modifica comentario se agrega   ���
���              �        �           �F1_FECTIMB en la funcion GenFacEnt ���
���Luis Enr�quez �03/03/20�DMINA-7887 �Se realiza modificaci�n para que al���
���              �        �           �Fact. a partir de Prefactura si el ���
���              �        �           �RFC de Prov. existe en tabla MB0   ���
���              �        �           �muestre msj de opci�n para confir- ���
���              �        �           �mar generaci�n. (MEX)              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function MATA459()

Private aRotina	:= {	{ OemToAnsi(STR0003), "AxPesqui" , 0 , 01}} //"Buscar" 
	 						
/*/	
��������������������������Ŀ
�Grupo de Preguntas MATA459�
�						   �
��De Numero?   	MV_PAR01   �  
��A Numero?    	MV_PAR02   �             
��De Serie?    	MV_PAR03   �         
��A Serie?    	MV_PAR04   �          
��De Proveedor?	MV_PAR05   �      
��A Proveedor?  MV_PAR06   �     
��De Tienda?  	MV_PAR07   �    
��A Tienda?    	MV_PAR08   �
��De Fecha?   	MV_PAR09   �
��A Fecha?   	MV_PAR10   �         
����������������������������
/*/

If pergunte("MATA459",.T.)
	MT459CON()
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MT459CON  � Autor � Alfredo Medrano       � Data �20/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Activa o desactiva grupo                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MT459CON()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA459                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MT459CON()
Private	 	 cDNume   	:= ""   
Private 	 cANume   	:= ""
Private 	 cDSeri   	:= ""
Private 	 cASeri   	:= ""
Private 	 cDProv		:= ""
Private 	 cAProv   	:= ""
Private 	 cDTien   	:= ""
Private 	 cATien   	:= ""
Private 	 cDFech   	:= ""
Private 	 cAFech   	:= ""
Private 	 aListBox 	:={}
Private 	lMSHelpAuto := .F. //Variable para las rutina automatica
Private lAutoErrNoFile := .T.//Variable para las rutina automatica
//PARA EL DIALOG
Private 	 aPosObj   	:= {}
Private 	 aObjects  	:= {}
Private 	 aSize     := {}
Private 	 aInfo     := {}
Private 	 oDlg 
Private 	aLogErro	:= {}
Private		 cSDoc		:= SerieNFID("CPP", 3, "CPP_SERIE")//incluido em 27/04/2015 projeto chave unica
Private		 aSDoc 		:={}	
cDNume := trim(MV_PAR01)	//�De Numero?
cANume := trim(MV_PAR02)	//�A Numero?
cDSeri := trim(MV_PAR03)	//�De Serie? 
cASeri := trim(MV_PAR04)	//�A Serie?
cDProv := trim(MV_PAR05)	//�De Proveedor?
cAProv := trim(MV_PAR06)	//�A Proveedor?
cDTien := trim(MV_PAR07) 	//�De Tienda?
cATien := trim(MV_PAR08) 	//�A Tienda?
cDFech := MV_PAR09 			//�De Fecha? 
cAFech := MV_PAR10 			//�A Fecha?    

Processa( {|| IIF(MTA459CON(),MTA459DOC(),.F.)}, OemToAnsi(STR0037),OemToAnsi(STR0039), .T. ) //"Favor de Aguardar....." "Generando Facturas."
	
Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MTA459DOC � Autor � Alfredo Medrano       � Data �20/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Muestra preguntas y ejecuta pantalla para                  ���
���          � selecciona de Pre-factura.                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MTA459DOC()                                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MT459CON                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MTA459DOC()   
 
Local cNom     := ""  
Local oBtnMarcTod  //Marcar, desmarcar, invertir
Local oBtnDesmTod
Local oBtnInverte
Local bOk1
Local bCan1
Local lEnd 		:= .T.
Local bActiva  :={||lActiva:=(if 	((len(oListBox:aarray )>0 .and. !empty(oListBox:aarray[1,2]) ), .t.,.f.))} 
Local bMarcTod 	:={||(MarcProd( oListBox , @aListBox , @oDlg , "M" ),oListBox:nColPos := 1,oListBox:Refresh())}
Local bDesmTod 	:={||(MarcProd( oListBox , @aListBox , @oDlg , "D" ),oListBox:nColPos := 1,oListBox:Refresh())}
Local bInverte 	:={||(MarcProd( oListBox , @aListBox , @oDlg , "I" ),oListBox:nColPos := 1,oListBox:Refresh())}
Local bOrdenLst	:={||if 	((len(oListBox:aarray )>0 .and. !empty(oListBox:aarray[1,2]) ),MT459Ordena(),OemToAnsi(STR0012))} //"Para usar esta opci�n debe haber datos en la lista"
Local bBuscar	:={||MT459Busca()}
Local aOrdenBuscar:={OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008),OemToAnsi(STR0009),OemToAnsi(STR0010),OemToAnsi(STR0011)} //"Num Docto","Serie","Fecha","Prveedor","Tienda","Descripci�n","Importe Total","Moneda"
//BOTONES

Local bAsigna	:={||Processa( {|lEnd| MT459ASIG(@lEnd)}, OemToAnsi(STR0037),OemToAnsi(STR0038), .T. ), IIF(!lEnd,,oDlg:End())}
Local bCancela	:={|| oDlg:End()} 

Private aHeaderCPP :=aClone(aOrdenBuscar)//"Num Docto","Serie","Fecha","Prveedor","Tienda","Descripci�n","Importe Total","Moneda"
Private cDatBus	:=space(15)
Private oOk    	:= LoadBitmap( GetResources(), "LBOK" ) //cargar imagenes del repositiorio
Private oNo		:= LoadBitmap( GetResources(), "LBNO" ) 
Private oDlg2  
Private aButtons	:={} 
Private oLbx  
Private cOrden		:=''  
//posici�n en el LISTBOX
/* alterado para DEFINE
Private nPosForn	:=5  //PROVEEDOR
Private nPosLoja	:=6  //TIENDA
Private nPosDoc	:=2  //DOCTO
Private nPosSeri	:=3  //SERIE
Private nPosSeID	:=11 //Serie+id, adicionado em 27/04/15 Tiago Silva PRJ Chave Unica
Private nPosFolF	:=10 //FOLIO FISCAL  
*/

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

                        
CURSORARROW()	 
                
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0002) From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL

@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox FIELDS HEADER "",aHeaderCPP[1],aHeaderCPP[2],aHeaderCPP[3],aHeaderCPP[4],aHeaderCPP[5],aHeaderCPP[6],aHeaderCPP[7],aHeaderCPP[8];
  SIZE aPosObj[2][4], aPosObj[2][3]-20 PIXEL ON DBLCLICK (MarcProd(oListBox,@aListBox,@oDlg),oListBox:nColPos := 1,oListBox:Refresh())  //NOSCROLL 

oListBox:SetArray( aListBox )
oListBox:bLine := { || {IF(	aListBox[oListBox:nAt,1],oOk,oNo),;
							aListBox[oListBox:nAt,2],;	
							aListBox[oListBox:nAt,3],;
							aListBox[oListBox:nAt,4],;
							aListBox[oListBox:nAt,5],;
							aListBox[oListBox:nAt,6],;
							aListBox[oListBox:nAt,7],;
							aListBox[oListBox:nAt,8],;
							aListBox[oListBox:nAt,9]}}  

oGroup2:= tGroup():New(aPosObj[3,1],aPosObj[3,2],aPosObj[3,3],aPosObj[3,4],,oDlg,,CLR_WHITE,.T.)        		
aEval:= bActiva		
oBtnMarcTod:=tButton():New( aPosObj[3][1]+16,318, OemToAnsi(STR0013) ,oGroup2,bMarcTod,58,13.50  ,,,.F.,.T.,.F.,,.F.,bActiva,,.F. )	 //"Marca todo - <F4>"
oBtnDesmTod:=tButton():New( aPosObj[3][1]+16,379, OemToAnsi(STR0014) ,oGroup2,bDesmTod,58,13.50  ,,,.F.,.T.,.F.,,.F.,bActiva,,.F. )	 //"Desmarca todo - <F5>"
oBtnInverte:=tButton():New( aPosObj[3][1]+16,440 ,OemToAnsi(STR0015) ,oGroup2,bInverte,58,13.50  ,,,.F.,.T.,.F.,,.F.,bActiva,,.F. ) //"Inv. seleccion - <F6>"
oComboBus:= tComboBox():New(aPosObj[3,1]+16,10,{|u|if(PCount()>0,cOrden:=u,cOrden)},;
			          aOrdenBuscar,50,24,oGroup2,,nil,,,,.T.,,,,bActiva,,,,,'cOrden')  
@ aPosObj[3,1]+16,60  msGET cDatBus 	  when lActiva	SIZE  60,09  OF oGroup2 PIXEL 		
oSButton2 := tButton():New(aPosObj[3,1]+16,130,OemToAnsi(STR0003),oGroup2,bBuscar,54.50,13.50 ,,,.F.,.T.,.F.,,.F.,bActiva,,.F. )	//"Buscar"

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bAsigna,bCancela,,aButtons)

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MTA459CON � Autor � Alfredo Medrano       � Data �21/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Filtra los registros de la tabla CPP y llena Array que     ���
���          � ser� cargado en el ListBox.                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MTA459DOC()                                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MTA459DOC                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MTA459CON()
 
Local 	 aArea		:= getArea()        
Local	 cTmpPer	:= CriaTrab(Nil,.F.)
Local   cQuery		:= "" 
Local   cFilCPP	:= XFILIAL("CPP")   
Local 	 lBan		:= .T.
Local 	 cFilSA2	:= XFILIAL("SA2")

	cQuery := " SELECT CPP_DOC,CPP_SERIE,CPP_EMISSA,CPP_FORNEC,CPP_LOJA,  "
	if !(cSDoc=="CPP_SERIE")
		CQuery +=cSDoc+", " 
	endif
	CQuery += " CPP_VALBRU,CPP_MOEDA,CPP_CONPGO,CPP_TXMOED,CPP_FILIAL,CPP_DESCON,"
	CQuery += " CPP_ITEM,CPP_TIPO,A2_NOME,CPP_UUID " 
	CQuery += " FROM " + RetSqlName("CPP") + " CPP, " + RetSqlName("SA2") + " SA2" 
 	cQuery += " WHERE CPP_DOC  BETWEEN '"+ cDNume +"' AND '"+ cANume +"' " 	//De N�mero
 	cQuery += " AND "+cSDoc+"  BETWEEN '"+ cDSeri +"' AND '"+ cASeri +"' " 	//De Serie , modificada por Tiago Silva PRJ Chave unica 27/04/15
 	cQuery += " AND CPP_FORNEC BETWEEN '"+ cDProv +"' AND '"+ cAProv +"' " 	//De Proveedor
 	cQuery += " AND CPP_LOJA   BETWEEN '"+ cDTien +"' AND '"+ cATien +"' " 	//De Tienda
 	cQuery += " AND CPP_EMISSA BETWEEN '"+ DTOS(cDFech) +"' AND '"+ DTOS(cAFech) +"' " 	//De Fecha
 	cQuery += " AND CPP_STATUS 	= ''"
 	cQuery += " AND CPP_FILIAL 	= '" + cFilCPP + "'"
  	cQuery += " AND CPP.D_E_L_E_T_ 	= ' ' "
  	cQuery += " AND A2_FILIAL  	= '" + cFilSA2 +"'"
  	cQuery += " AND A2_COD	= CPP_FORNEC "
  	cQuery += " AND A2_LOJA	= CPP_LOJA "
  	cQuery += " AND SA2.D_E_L_E_T_ 	= ' ' "
  	cQuery := ChangeQuery(cQuery)   	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpPer,.T.,.T.)
	TCSetField(cTmpPer,"CPP_EMISSA","D",8,0) // Formato de fecha 
	(cTmpPer)->(dbgotop())//primer registro de tabla
	aListBox:= {}
	aSDoc:= {}
	If (cTmpPer)->(EOF())
	   //genera un registro en blanco en oListBox                          
		aListBox:={}
		AADD(aListBox,{ .F. , "","","","","","","","",""})  
       MsgInfo(OemToAnsi(STR0019)) //"No hay pre-facturas con esos rangos!"
       Return .F.
    Else
    
	    While  (cTmpPer)->(!EOF())	
			AADD(aListBox,{lBan,;	
	      		(cTmpPer)->CPP_DOC,;  
	         	(cTmpPer)->&cSDoc,; //Alterado para mostrar o cSDOC na tela, Projeto Chave unica
	          	(cTmpPer)->CPP_EMISSA,;                         
	          	(cTmpPer)->CPP_FORNEC,;
	          	(cTmpPer)->CPP_LOJA,;
	         	(cTmpPer)->A2_NOME,;
	         	(cTmpPer)->CPP_VALBRU,;
	          	(cTmpPer)->CPP_MOEDA,;
	          	(cTmpPer)->CPP_UUID,;
	         	(cTmpPer)->CPP_SERIE}) 	
			(cTmpPer)-> (dbskip())	 		
		EndDo
         
	EndIf
	(cTmpPer)->( dbCloseArea())
	restArea(aArea)
	 
return .T.

/*                                                                               
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao     � MarcProd � Autor � Laura Medina         � Data � 26/09/08 ���
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Funci�n para marcar productos.                            ��� 
���           � 			                                              ��� 
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���                
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �  /  /  �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function MarcProd( oListBox , aListBox , oDlg , cMarckTip )

DEFAULT cMarckTip := ""
IF Empty( cMarckTip )  
	aListBox[ oListBox:nAt , 1 ] := !aListBox[ oListBox:nAt , 1 ]
ElseIF cMarckTip              == "M"
	aEval( aListBox , { |x,y| aListBox[y,1] := .T. } )
ElseIF cMarckTip == "D"
	aEval( aListBox , { |x,y| aListBox[y,1] := .F. } )
ElseIF cMarckTip == "I"
	aEval( aListBox , { |x,y| aListBox[y,1] := !aListBox[y,1] } )
EndIF

Return( NIL )
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MT459Busca � Autor � Alfredo Medrano      � Data �21/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Busca en el ListBox                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MT459Busca		      			                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Ninguno					                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MTA459DOC                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
static function MT459Busca()                   
Local nPosBus:=0     
Local nPos:=oComboBus:nat+1

If valtype(oListBox:aarray[1,npos])=="C"
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

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �MT459Ordena� Autor � Gpe Santacruz         � Data �09/10/2009���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Selecciona las columnas a ordenar                           ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � MT459Ordena(ExpC1)                                          ���
��������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Numero da opcion selecionada                        ���
���          �                                                             ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � MTA459DOC                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static function MT459Ordena(nOpc)  
Local cLinOrdOk:="AllwaysTrue()"  
Local cTodOrdOk:="AllwaysTrue()" 
Local odlg3  :="AllwaysTrue()" 
Local oGetOrdena
Local cFielOrdOk:="AllwaysTrue()"    
Local nOpcOrdena:=0     
Local aColsOrdena:={}
Local aHeaderOrdena:={} 
Local oCombo:=Nil   
Local cCombo:=''
Local aItems:={}
Local nx:=0
Local ni:=0                  
Local nUsado:=3
Local aSelAlt:={"COLUM"}  //Columna que permitir� alteraciones

//aHeader del getdados de ORDENAR
Aadd(aHeaderOrdena, { OemToAnsi(STR0020),"ITEM","99",2,0,"AllwaysTrue()" ,CHR(251),"N",'','','' } ) //"Item"
Aadd(aHeaderOrdena, { OemToAnsi(STR0021),"COLUM","999",3,0,"AllwaysTrue()" ,CHR(251),"N",'','','' } )  //"Columna"
Aadd(aHeaderOrdena, { OemToAnsi(STR0022),"CAMPOS","",11,0,"AllwaysTrue()",CHR(251),"C",'','',''} )   //"Campos"

//aCols del getdados ORDENAR
for ni:=1 to len(oListBox:aheaderS)
		Aadd(aColsOrdena,Array(nUsado+1))
		aColsOrdena[Len(aColsOrdena)][1] := ni
		aColsOrdena[Len(aColsOrdena)][2] := 0			
		aColsOrdena[Len(aColsOrdena)][3] :=oListbox:aheaderS[NI]
		aColsOrdena[Len(aColsOrdena)][nUsado+1] := .F.
next

//Items del combobox
aItems:= {OemToAnsi(STR0023),OemToAnsi(STR0024)} //'Descendente','Ascendente'
cCombo:= aItems[1] //Opci�n def<ault del  combobox

DEFINE MSDIALOG oDlg3 TITLE OemToAnsi(STR0025) From c(40),c(10) To c(235),c(300) PIXEL //"Ordenar OP's" 
 	
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
���Fun��o    �OrdenaArray       � Gpe Santacruz         � Data �14/07/2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ordena las columnas del getdados principal                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � OrdenaArray(ExpO1,ExpN1)                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto, del getdados que indica el orden           ���
���          � ExpN1 = Numerico, indica si el orden es 2-ascen o 1-desc   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MT459Ordena                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������/*/

static function OrdenaArray(oGetOrdena,nSelOrd)  

Local ni:=0
Local ctipo:=''
Local cStrX:=''
Local cStrY:=''    
Local cOper:=''

Cursorwait()                
	oGetOrdena:acols :=aSort(oGetOrdena:acols,,,{|x,y| x[2] <= y[2]})
	if nSelOrd==1 //descendente
	   cOper:=' >= '
	else          
	   cOper:=' <= '
	endif
	
	for ni:= 1 to len(oGetOrdena:acols)
	    if oGetOrdena:acols[ni,2]<>0   
	           cTipo:=valtype(oListBox:aarray[1,oGetOrdena:acols[ni,1]])
	           if ctipo=='N'
	              cStrX+="str(x["+alltrim(str(oGetOrdena:acols[ni,1]))+"])+"
	              cStrY+="str(y["+alltrim(str(oGetOrdena:acols[ni,1]))+"])+"
	            else        
	               if cTipo=='D'
					  cStrX+="dtos(x["+alltrim(str(oGetOrdena:acols[ni,1]))+"])+"
	                  cStrY+="dtos(y["+alltrim(str(oGetOrdena:acols[ni,1]))+"])+"		                  
	               else       
						  cStrX+="x["+alltrim(str(oGetOrdena:acols[ni,1]))+"]+"
				          cStrY+="y["+alltrim(str(oGetOrdena:acols[ni,1]))+"]+"		                  
	                endif   
	             endif    
	     endif    
	next               
	cStrX:=substr(cStrX,1,len(cStrX)-1)  
	cStrY:=substr(cStry,1,len(cStrY)-1)                                            
	if !empty(cStrX)
	      &("oListBox:aarray := aSort(oListBox:aarray,,,{|x,y| "+cStrX+cOper+cStrY+"})")      
	endif
CursorArrow()
Return    

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MT459ASIG � Autor � Alfredo Medrano       � Data �24/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Env�a Facturas Seleccionadas a la generaci�n Automatica    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MT459ASIG( )      			                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  						                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MTA459DOC                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function MT459ASIG(lRet)

Local aArea		:= GetArea()
Local nx:=0  
Local cFORNEC	:="" 
Local cLOJA		:="" 
Local cDOC		:=""
Local cSERIE	:= Space(TamSx3("CPP_SERIE")[1])
Local cUUID   	:=""          
Local cfilCPP	:=xfilial("CPP")
Local lGenFac	:= .T.
Local nSelct	:= 0  
Local nRech		:= 0 
Local nProc		:= 0  
Local nVacio	:= 0
Local cMsg		:=''
Local nNumSel	:= 0
Local cAreaCPP	:= 'CPP'
Local cRFC      := ""
Local cFilMB0   := xFilial("MB0")
Local cFilSA2   := xFilial("SA2")
Local lContinua := .T.
Local cCRLF     := (chr(13)+chr(10))
Local cAviso    := ""

Default lRet	:= .T.

nVacio := aScan(oListBox:aarray,{|x| x[1] == .F. .And.;
	 x[2] == "" .And. x[3] == "" .And. x[4] == "" .And. x[5] == "" .And. x[6] == "";
	 .And. x[7] == "" .And. x[8] == "" .And. x[9] == "" } )

If Len(oListBox:aarray) == 1 .and. nVacio > 0
	Return  lRet
EndIf

dbSelectArea("SA2")
SA2->(dbSetOrder(1)) //A2_FILIAL + A2_COD + A2_LOJA	

dbSelectArea("MB0")
MB0->(dbSetOrder(1)) //MB0_FILIAL + MB0_CGC	

CPP->(DBsetorder(1)) //CPP_FILIAL+CPP_FORNEC+CPP_LOJA+CPP_DOC+CPP_SERIE        										
nSelct:=aScan(oListBox:aarray,{|x| x[1] == .T.} )

If nSelct > 0
 
	For Nx:=1 to Len(oListBox:aarray)   
		If !empty(oListBox:aarray[nx,1]) //si esta seleccionado	
			nNumSel++
			cFORNEC	:=oListBox:aarray[nx,nPosForn]
			cLOJA	:=oListBox:aarray[nx,nPosLoja]
			cDOC	:=oListBox:aarray[nx,nPosDoc]
			cSERIE	:=oListBox:aarray[nx,nPosSeID]//Modificado para usar id da serie - Projeto Chave Unica
			cUUID	:=oListBox:aarray[nx,nPosFolF]
			cRFC    := ""
			lContinua := .T.
			DbSelectArea("SF1")
			SF1->(dbSetOrder(9)) //F1_FILIAL + F1_UUID 	
			If !SF1->(DbSeek(XFILIAL('SF1') + cUUID))//verifica que la Pre-Factura no exista en la tabal SF1
				CPP->(DBGOTOP())
				If CPP->(DBSEEK(cfilCPP+cFORNEC+cLOJA+cDOC+cSERIE))
					If SA2->(dbSeek(cFilSA2 + cFORNEC + cLOJA))
						cRFC := SA2->A2_CGC
					EndIf

					If MB0->(DbSeek(cFilMB0 + cRFC))
						Do While MB0->(!Eof()) .And. MB0->MB0_FILIAL + MB0->MB0_CGC == cFilMB0 + cRFC
							cAviso += STR0070 + Upper(Alltrim(MB0->MB0_STATUS)) + cCRLF + ; //"Situaci�n: "
							   	      STR0071 + IIf(!Empty(MB0->MB0_FECPRE),Dtoc(MB0->MB0_FECPRE),"") + ;     //" Fec. Pres.: "
							   	      STR0072 + IIf(!Empty(MB0->MB0_FECDES),Dtoc(MB0->MB0_FECDES),"") + ;     //" Fec. Desv.: "
							   	      STR0073 + IIf(!Empty(MB0->MB0_FECDEF),Dtoc(MB0->MB0_FECDEF),"") + ;     //" Fec. Def.: "
							   	      STR0074 + IIf(!Empty(MB0->MB0_FECSFA),Dtoc(MB0->MB0_FECSFA),"") + cCRLF //" Fec. Sent. Fav.: "
							MB0->(DbSkip())
						EndDo
						lContinua := MsgYesNo(StrTran( STR0075, '###', cRFC ) + cCRLF + cAviso + cCRLF + STR0076) //"El RFC del Emisor (###) existe en el listado de contribuyentes que desvirtuaron la presunci�n de inexistencia de operaciones ante el SAT: " //"�Desea continuar?"
					EndIf		
				
					lGenFac:= IIf(lContinua,GenFacEnt(cAreaCPP) ,.F.)

					If lGenFac
						nProc++
					Else
						nRech++
					EndIf
				EndIF
			Else
					aAdd(aLogErro, {OemToAnsi(STR0035) + alltrim(cDOC) + " " + cSERIE + OemToAnsi(STR0040)}) //"La Pre-Factura "  alltrim(cfac) + " " + cSer +" ya existe en la Factura de Entrada" 
			EndIf
		EndIf   
	Next  
	If len(aLogErro)>0
		If msgyesno(OemToAnsi(STR0026)) //"Errores encotrados, �Quiere verificar el LOG?"
			ImprimeLog()
		EndIf	 
	Else
		cMsg := OemToAnsi(STR0027) + chr(10) + chr(13)//"Proceso finalizado sin Errores!" 
		cMsg += OemToAnsi(STR0056) + OemToAnsi(STR0057)	+ STR(nNumSel) + chr(10) + chr(13) // "Cantidad de Facturas" + "Seleccionadas: "
		cMsg += OemToAnsi(STR0056) + OemToAnsi(STR0058)+ STR(nProc) + chr(10) + chr(13) // "Cantidad de Facturas" + "Procesadas: " 
		cMsg += OemToAnsi(STR0056) + OemToAnsi(STR0059)+ STR(nRech) + chr(10) + chr(13) // "Cantidad de Facturas" + "Rechazadas: " 
		MSGINFO(cMsg) 
	Endif
Else
	MSGINFO(OemToAnsi(STR0028)) //"No hay Pre-Facturas Seleccionadas!!" 
	lRet := .F.
EndIf

RestArea(aArea)
Return lRet

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Programa  �GenFacEnt       �Autor  � Alfredo Medrano    �Fecha �  24/03/2014 ���
�������������������������������������������������������������������������������͹��
���Desc.     � Genera facturas de enetrada con la Rutina automatica             ���
���          �                                                                  ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   � ProcFacturas(cExp1)				                                ���
�������������������������������������������������������������������������������Ĵ��
���Parametros� cExp1.- Alias del archivo fuente                                 ���
�������������������������������������������������������������������������������Ĵ��
���Uso       � MT459ASIG                                                	    ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
                      
Static Function GenFacEnt(cAliasCPP)
Local lRet		:= .f.
Local nValDesp	:=0
Local cAlmacen	:=''
Local aCabs		:={}        
Local aItens	:={}                                          
Local CFILCPQ	:= xfilial("CPQ")
Local nTotCif	:=0        
Local lGrabo	:= .t.
Local nj		:=0    
Local nx		:=0
Local cAliasCPQ	:= "CPQ"
Local cTipGas	:=''
Local cTip13	:='13'
Local cTip14	:='14'
Local cTipSD1	:=''
Local nTipoAcc := 3 //Incluir Facturas
Local cFechaTim	:=''
Local cRutaDoc	:='' 
Local cFac	 	:=''
Local cSer 		:= Space(TamSx3("CPP_SERIE")[1]) 
Local cPrv		:=''	
Local cTda		:=''
Local cFilTMP	:=''
Local cIteDoc	:=''
Local cTipTmp	:=''

DBSELECTAREA("CPQ")
DBSELECTAREA("CPP")
DBSETORDER(1)

aAdd(aCabs, {"F1_FILIAL "	, xFilial('SF1') 			,  Nil})
aAdd(aCabs, {"F1_TIPO"    	, "1"           			,  Nil})
aAdd(aCabs, {"F1_FORMUL"  	, "N"             			,  Nil})
aAdd(aCabs, {"F1_DOC"     	, (cAliasCPP)->CPP_DOC		,  Nil})
aAdd(aCabs, {"F1_SERIE"   	, (cAliasCPP)->&cSDoc		,  Nil})
aAdd(aCabs, {"F1_EMISSAO" 	, (cAliasCPP)->CPP_EMISSA	,  Nil})
aAdd(aCabs, {"F1_FORNECE" 	, (cAliasCPP)->CPP_FORNEC  	,  Nil})
aAdd(aCabs, {"F1_LOJA"    	, (cAliasCPP)->CPP_LOJA   	,  Nil})
aAdd(aCabs, {"F1_ESPECIE" 	, "NF"            			,  Nil})
aAdd(aCabs, {"F1_COND"    	, (cAliasCPP)->CPP_CONPGO  	,  Nil})
aAdd(aCabs, {"F1_MOEDA"   	, Val((cAliasCPP)->CPP_MOEDA), Nil})
aAdd(aCabs, {"F1_TXMOEDA" 	, (cAliasCPP)->CPP_TXMOED	,  Nil}) 
aAdd(aCabs, {"F1_DTDIGIT" 	, dDataBase       			,  Nil}) 
aAdd(aCabs, {"F1_DESCONT" 	, (cAliasCPP)->CPP_DESCON 	,  Nil})

//�����������������������������������������������������������Ŀ
//�Datos asignados desde el LocxNF Rutina GravaNfGeral()	  �
//�F1_UUID	-> se carga con la info de (cAliasCPP)->CPP_UUID  �
//�F1_FECTIMB-> se carga con la info de (cAliasCPP)->CPP_FECTIM�
//�F1_RUTDOC-> se carga con la info de (cAliasCPP)->CPP_RUTDOC�
//�������������������������������������������������������������

cFac:=(cAliasCPP)->CPP_DOC
cSer:=(cAliasCPP)->CPP_SERIE 
cPrv:=(cAliasCPP)->CPP_FORNEC			
cTda:=(cAliasCPP)->CPP_LOJA
dEmis:=(cAliasCPP)->CPP_EMISSA 

cFilTMP:=(cAliasCPP)->CPP_FILIAL
cIteDoc:=(cAliasCPP)->CPP_ITEM
cTipTmp:=(cAliasCPP)->CPP_TIPO
aAdd(aCabs, {"F1_TIPODOC" , "10" ,  Nil})

(cAliasCPQ)->(DBSETORDER(1)) //CPQ_FILIAL+CPQ_FORNEC+CPQ_LOJA+ CPQ_DOC+CPQ_SERIE+CPQ_ITEM+CPQ_COD
(cAliasCPQ) ->( dbSeek(CFILCPQ+cPrv+cTda+cFac+cSer) )
	While (cAliasCPQ)->(!Eof()) .And. ;
	((cAliasCPQ)->CPQ_FILIAL+(cAliasCPQ)->CPQ_FORNEC+(cAliasCPQ)->CPQ_LOJA+(cAliasCPQ)->CPQ_DOC+(cAliasCPQ)->CPQ_SERIE == CFILCPQ+cPrv+cTda+cFac+cSer ) 											
		   		
		cCF := IIF(!EMPTY((cAliasCPQ)->CPQ_UUID),(cAliasCPQ)->CPQ_UUID,"")				                 
		aAdd(aItens, {})
		aAdd(aItens[Len(aItens)] , {"D1_FILIAL"  	, CFILCPQ  					, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_DOC"		, cFac          			, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_SERIE"   	, (cAliasCPP)->&cSDoc    	, Nil}) 
		aAdd(aItens[Len(aItens)] , {"D1_FORNECE"  	, (cAliasCPQ)->CPQ_FORNEC 	, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_LOJA"    	, (cAliasCPQ)->CPQ_LOJA   	, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_EMISSAO" 	, (cAliasCPP)->CPP_EMISSA 	, Nil})
		AAdd(aItens[Len(aItens)] , {"D1_DTDIGIT" 	, dDataBase       			, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_ESPECIE" 	, "NF"            			, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_TIPODOC" 	, "10"            			, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_TIPO"    	, "N"             			, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_FORMUL"  	, "N"             			, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_ITEM"    	, (cAliasCPQ)->CPQ_ITEM   	, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_COD"     	, (cAliasCPQ)->CPQ_COD 		, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_UM"      	, (cAliasCPQ)->CPQ_UM     	, Nil})
		if !empty((cAliasCPQ)->CPQ_PEDIDO)
			aAdd(aItens[Len(aItens)] , {"D1_PEDIDO"	, (cAliasCPQ)->CPQ_PEDIDO 	, Nil})
			aAdd(aItens[Len(aItens)] , {"D1_ITEMPC"	, (cAliasCPQ)->CPQ_ITEMPC 	, Nil})
		EndIf
		aAdd(aItens[Len(aItens)] , {"D1_QUANT"   	, (cAliasCPQ)->CPQ_QUANT  	, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_VUNIT"   	, (cAliasCPQ)->CPQ_VUNIT  	, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_TOTAL"   	, (cAliasCPQ)->CPQ_TOTAL   	, Nil}) 			
		aAdd(aItens[Len(aItens)] , {"D1_LOCAL"   	, (cAliasCPQ)->CPQ_LOCAL  	, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_TES"     	, (cAliasCPQ)->CPQ_TES    	, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_UUID"      , cCF             			, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_CC"      	, (cAliasCPQ)->CPQ_CC     	, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_CONTA"   	, (cAliasCPQ)->CPQ_CONTA  	, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_ITEMCT" 	, (cAliasCPQ)->CPQ_ITEMCT  	, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_CLVL"    	, (cAliasCPQ)->CPQ_CLVL   	, Nil})
		aAdd(aItens[Len(aItens)] , {"D1_VALDES" 	, (cAliasCPQ)->CPQ_VALDES	, Nil})			
				
		IncProc(OemToAnsi(STR0029) + cFac + cSer) //"Procesando factura "					
		  		
		dbSelectArea((cAliasCPQ))
		(cAliasCPQ)->(dbSkip())
	EndDo

If Len(aItens) == 0
	aAdd(aLogErro, {OemToAnsi(STR0035) + alltrim(cfac) + " " + cSer + OemToAnsi(STR0036)}) //"La Pre-Factura "  alltrim(cfac) + " " + cSer +" no tiene detalle"							
EndIf

If  (Len(aCabs)>0 .And. Len(aItens)>0)
	 	BeginTran()
				lMSErroAuto := .F.
				MaFisEnd()
				cDocTipo:='FE' //Factura de entrada               
		
				MSExecAuto({|x,y,z,a| MATA101N(x,y,z,a)},aCabs,aItens,nTipoAcc)

				If lMSErroAuto 
					DisarmTransaction()
					//MostraErro()                                                                               
					aAdd(aLogErro, {OemToAnsi(STR0030) + alltrim(cfac) + " " + cSer + OemToAnsi(STR0031)}) //"Rutina automatica, al generar la Factura "+alltrim(cfac)+" "+cSer+" encontro los errores : "							
					aAutoErro := GETAUTOGRLOG()
					for nx:=1 to len(aAutoErro)
						aAdd(aLogErro, {aAutoErro[nx]})							
					next
				Else     				    
				    lGrabo:= .F.
					SF1->(DBSETORDER(1))
					IF SF1->(DBSEEK(XFILIAL("SF1")+cFac+cSer+cPrv+cTda)) //ASEGURA QUE REALMENTE HAYA GRABADO  LA FACTURA 
					    lGrabo:= .t.
					ENDIF
					IF lGrabo    
					    CPP->(DBsetorder(1)) //CPP_FILIAL+CPP_FORNEC+CPP_LOJA+CPP_DOC+CPP_SERIE  
						IF CPP->(DBSEEK(XFILIAL("CPP")+cPrv+cTda+cFac+cSer))
							RecLock("CPP", .F.)
							CPP->CPP_STATUS:= "1" //Marca la factura como generada en compras
							CPP->(MsUnlock())
						ENDIF   
						lRet:= .t.
					ENDIF	
					EndTran()
				EndIf
		MsUnlockAll()	
EndIf
Return lRet             
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ImprimeLog  � Autor �GSANTACRUZ          � Data � 11/05/11 ���
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
Local cTitulo	:= OemToAnsi(STR0032)   //"LOG  de Generacion de Facturas "
Local cDet		:= ""
Local nX		:= 1
Local aNewLog	:= {}
Local nTamLog	:= 0
Local aLogTitle	:={}  
Local aLog		:={}

for nx:=1 to len(ALOGERRO)                                            
   	    aadd(aLog,aLogErro[nx,1])
next

aNewLog		:= aClone(aLog)
nTamLog		:= Len( aLog)
aLog := {}

If !Empty( aNewLog )

	aAdd( aLog , aClone( aNewLog ) )
Endif

AADD(aLogTitle,"                                                    ")

MsAguarde( { ||fMakeLog( aLog ,aLogTitle , , .T. , FunName() , cTitulo , cTamanho , "P" , aReturn, .F. )},OemToAnsi(STR0034)) //"Generando Log del Pedimento..."

Return 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MT459VDOC	 � Autor � Alfredo Medrano      � Data � 01/04/14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa para visualizar arquivo anexo                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MT459VDOC(ExpC1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Ruta del archivo SF1->F1_RUTDOC		              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � LOCXNF - Function MenuDef()                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MT459VDOC(cFile)

Local aSize   	:= MsAdvSize()
Local aObjects	:= {{ 100, 100, .T., .T., .T. }}
Local aInfo  	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 4, 4 } 
Local aPosObj2	:= {}
Local cFileTrm	:= ""
Local cParam  	:= ""
Local cDir    	:= ""
Local cDrive  	:= ""
Local lPreview	:= GetMV("MV_QANEVPR", .F., .T.)
Local aQPath  	:= QDOPATH()
Local cQPathTrm	:= aQPath[3]
Local bCancela	:={|| oDlg:End()}
Local bConfirma	:={|| oDlg:End()}  
Local nPos		:= 0 
Local nLen		:= 0
Local cNomeFile	:=''
Local cAliasSF1	:= 'SF1'
Local cDoc 		:=''
Local cSer		:=''
Local oDlg
Private oOle
Private aListBoxDoc := {}
Private cFilePrev   := ""
Private aPosObj :=   MsObjSize( aInfo, aObjects, .T. , .T. )
Private oScroll

cDoc:=(cAliasSF1)->F1_DOC
cSer:=(cAliasSF1)->F1_SERIE 

If !Empty(cFile) 
	aListBoxDoc:={}
	nSin:= 0
	nPos := Rat("\",cFile)
	cNomeFile := SubStr(cFile,nPos+1,Len(cFile))

	If File(cFile+".pdf")
		AADD(aListBoxDoc,{cNomeFile, cFile+".pdf", OemToAnsi(STR0054), cAliasSF1, SF1->(Recno()) } )//"No"
	Else
		nSin ++
	EndIf
	If File(cFile+".xml")
		AADD(aListBoxDoc,{cNomeFile,cFile+".xml", OemToAnsi(STR0054), cAliasSF1, SF1->(Recno()) })//"No"
	Else
		nSin ++
	EndIf
	If nSin == 2
		MSGINFO( OemToAnsi(STR0043) + alltrim(cDoc) + " " + cSer + OemToAnsi(STR0044) + " : " + cFile ) //"En la Factura de Entrada "  alltrim(cDoc) + " " + cSer +" No fueron encontrados los archivos especificados en la Ruta del documento anexo." 
		Return Nil
	EndIf
Else
	MSGINFO( OemToAnsi(STR0041) + alltrim(cDoc) + " " + cSer + OemToAnsi(STR0042)) //"La Factura de Entrada " + alltrim(cDoc) + " " + cSer +" no tiene definida la Ruta del documento anexo" 
	Return Nil
Endif

//������������������������������������������������������������������������Ŀ
//� Resolve os objetos da parte esquerda                                   �
//��������������������������������������������������������������������������
aInfo    := { aPosObj[1,2], aPosObj[1,1], aPosObj[1,4], aPosObj[1,3], 0, 4, 0, 0 }
aObjects := {}
AAdd( aObjects, { 50, 50, .T., .T., .T. } )
aPosObj2 := MsObjSize( aInfo, aObjects )     

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0045) FROM aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL // "Documento Anexo"
	
	@ aPosObj[1,1]+55,aPosObj[1,2]+5 LISTBOX oListBox FIELDS HEADER OemToAnsi(STR0046), OemToAnsi(STR0047), OemToAnsi(STR0048),OemToAnsi(STR0049), OemToAnsi(STR0050); // "Objeto","Descripci�n","Preview","Alias WT", "Recno WT"
	SIZE aPosObj[1][4]+60, aPosObj[1][3]-450 PIXEL
	oListBox:SetArray( aListBoxDoc )
	oListBox:bLine := { || {aListBoxDoc[oListBox:nAt,1],;	
							aListBoxDoc[oListBox:nAt,2],;
							aListBoxDoc[oListBox:nAt,3],;
							aListBoxDoc[oListBox:nAt,4],;
							aListBoxDoc[oListBox:nAt,5]}}  
	oListBox:Refresh()
	
	//������������������������������������������������������������������������Ŀ
	//� A classe scrollbox esta com o size invertido...                        �
	//��������������������������������������������������������������������������
	oScroll := TScrollBox():New( oDlg, aPosObj[1,1]+5, aPosObj[1,2]+400, aPosObj[1,3]-400,aPosObj[1,3]-400)
	
	
	oOle:= TOleContainer():New( 2, 2,aPosObj[1,3]-2 ,aPosObj[1,4]-2 ,oScroll,.T.,cFilePrev )
	If !oOle:OpenFromFile(Alltrim(cFilePrev),.F.)
		If File(cFilePrev)
			oOle:DoVerbDefault()
		Endif
	Endif
	
	@ 40,305 BUTTON oBut1 PROMPT OemToAnsi(STR0051) SIZE 045,010 FONT oDlg:oFont ; // "Abrir"
	ACTION MsgRun(OemToAnsi(STR0037), OemToAnsi(STR0055),{|| CursorWait(),MT459ARCH(oListBox:nAt,1) ,CursorArrow()}) OF oDlg PIXEL  //"Favor de Aguardar....." "Cargando Archivo."
	
	@ 40,355 BUTTON oBut2 PROMPT OemToAnsi(STR0052) SIZE 045,010 FONT oDlg:oFont ; // "Preview"
	ACTION MsgRun(OemToAnsi(STR0037), OemToAnsi(STR0055),{|| CursorWait(),MT459ARCH(oListBox:nAt,2) ,CursorArrow()}) OF oDlg PIXEL //"Favor de Aguardar....." "Cargando Archivo."
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bConfirma,bCancela,,)
	
Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MT459ARCH � Autor � Alfredo Medrano       � Data �01/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Abre o pre visualiza el archivo seleccionado.              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MT459ARCH(@ExpN1,@ExpN2 )      			                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = N�mero de L�nea en la que se esta posicionado      ���
���          � ExpN2 = (1=abrir Archivo, 2= Previsualizar)		          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MT459VDOC                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function MT459ARCH(nLine,nTip)

Local cFileTrm	:= ""
Local cDir		:= ""
Local cDirLocal	:= ""
Local nPos 		:= 0
Local nx		:= 0
Local nRet		:= 0
default nTip 	:= 0
default nLine 	:= 0

If !Empty(nLine) .and. nLine > 0 
	cFile := AllTrim(aListBoxDoc[nLine,2])
	nPos := Rat("\",cFile)
	cFileTrm := SubStr(cFile,nPos+1,Len(cFile))
	cDir	:=  SubStr(cFile,1,nPos)  
	cRutaSrv := cDir                                                                                                                                                                                                
	cDirLocal := GetTempPath() //obtiene direcci�nn de carpeta termporal en el Cliente
	If nTip == 1 //Abrir el archivo
	//������������������������������������������������������������������������Ŀ
	//� Preparaci�n para  la apertura del archivo desde una carpeta local      �
	//��������������������������������������������������������������������������
		//Copia un archivo del servidor para el cliente
		//CpyS2T ( < cOrigem>, < cDestino>, [ lCompacta] ) --> lRet
		If CpyS2T( cRutaSrv + cFileTrm , cDirLocal )
		//abre el archivo  
			nRet:= ShellExecute("Open", AllTrim(cFileTrm),"",cDirLocal,1)
			If nRet <= 32
					Do Case
						Case nRet == 2
							Help(" ",1,STR0060,,STR0067 + STR0061 + STR0062)//"No se pudo abrir el archivo "  + "porque no existe." + "Aseg�rese de que el nombre del archivo es el correcto."
						Case nRet == 3	
							Help(" ",1,STR0060,,STR0067 + STR0063 + STR0064)//"No se pudo abrir el archivo "  + "porque el directorio no existe." + "Compruebe el nombre del directorio."
						OtherWise
							Help(" ",1,STR0060,,STR0067 + STR0065 + STR0066)//"No se pudo abrir el archivo "  + ", el archivo est� asociado a un programa o archivo que no existe." + "Compruebe las asociaciones con el programa de Windows o si el nombre del archivo es correcto."
					EndCase
				lReturn:= .F.
			EndIf
		Else
			Help(" ",1,STR0060,,STR0068)// "No se pudo generar el archivo temporal, compruebe que �ste existe en el servidor."			
		EndIf
	ElseIf nTip==2 
	//������������������������������������������������������������������������Ŀ
	//� Preparaci�n para el Preview                                            �
	//��������������������������������������������������������������������������
		//Copia un archivo del servidor para el cliente
		//CpyS2T ( < cOrigem>, < cDestino>, [ lCompacta] ) --> lRet
		If !CpyS2T( cRutaSrv + cFileTrm , cDirLocal )
			Help(" ",1,STR0060,,STR0068)// "No se pudo generar el archivo temporal, compruebe que �ste existe en el servidor."
		EndIf
		oOle:= TOleContainer():New( 2, 2,aPosObj[1,3]-2 ,aPosObj[1,4]-2 ,oScroll,.F., cDirLocal + AllTrim(cFileTrm))
		If !oOle:OpenFromFile(cDirLocal + AllTrim(cFileTrm),.F.)
			If File(cDirLocal + AllTrim(cFileTrm))
				oOle:DoVerbDefault()
			Endif
		Endif
		oOle:Refresh()
		For nx:= 1 to Len(aListBoxDoc)
			aListBoxDoc[nx,3]:= OemToAnsi(STR0054) //"No"
		Next
		aListBoxDoc[nLine,3]:= OemToAnsi(STR0053) //"Si"
	EndIf
EndIf

Return .T.