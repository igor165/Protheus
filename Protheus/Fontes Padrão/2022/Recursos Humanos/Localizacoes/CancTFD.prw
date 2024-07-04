#include "CancTFD.ch"
#include "protheus.ch"
#include "rwmake.ch"
#include "shell.ch"
#include "xmlxfun.ch"
#include "fileio.ch"

/*/
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o    � CancTFD  � Autor � Alberto Rodriguez         � Data �  14/08/14  ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o � Cancelaci�n de timbres fiscales d�gitales CFDi con complemento   ���
���          � de n�mina.                                                       ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   � CancTFD                                                          ���
�������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                   ���
�������������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS     �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������������Ĵ��
���Jonathan Glz� 27/04/15 �PCREQ-4256� Se elimina la funcion AjustaSX1() y se   ���
���            �          �          � registra la preguntas CANCTFD en ATUSX.  ���
���            �          �          � Se actualizan los comentarios.           ���
���Gsantacruz  � 14/07/15 �          � Merge 12 vs 12.1.6                       ���
���  Marco A.  � 30/07/19 �DMINA-7088� Se modifica el comando para cancelacion  ���
���            �          �          � de Recibos de Nomina para que utilice el ���
���            �          �          � nuevo esquema de cancelacion. (MEX)      ���
��� Veronica F � 20/11/19 �DMINA-7666� Se modifica la funci�n CancTimbreRN      ���
���            �          �          � se a�ade la actualizaci�n de la Fecha de ���
���            �          �          �  Cancelaci�n                             ���
��� Veronica F � 16/12/20 �DMINA-    � Se modifica la funci�n CancTimbreRN      ���
���            �          �     10662� cuando realiza la cancelaci�n del XML    ���
���            �          �          � renombra/mueve los archivos a la carpeta ���
���            �          �          � de cancelados.                           ���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
/*/
Function CancTFD()
	
	Local aArea			:= GetArea()
	Local oDlgCanc		:= Nil
	Local oBusca		:= Nil
	Local oLbx1			:= Nil
	Local oMarTodos		:= Nil
	Local oDesTodos		:= Nil
	Local oInvSelec		:= Nil
	Local oParam		:= Nil
	Local oBoton		:= Nil
	Local aItems		:= {}
	Local aIndx			:= {OemToAnsi(STR0002),OemToAnsi(STR0003)}   // "Matrícula", "Nombre"
	Local cIndx			:= aIndx[1]
	Local cBusca		:= Space(TAMSX3("RA_NOME")[1])
	Local nPosLbx		:= 0
	Local nOpc			:= 0
	Local oOk			:= LoadBitmap(GetResources(),"LBOK")
	Local oNo			:= LoadBitmap(GetResources(),"LBNO")
	Local bSet15		:= { || ValidaCanc(oLbx1,oDlgCanc,@nOpc,aItems) }
	Local bSet24		:= { || nOpc:=0 , oDlgCanc:End() }
	Local bDialogInit	:= { || EnchoiceBar(oDlgCanc,bSet15,bSet24,nil,nil)}
	Local cPerg			:= "CANCTFD"
	Local aTamanho		:= MsAdvSize(.F.)
	
	Private cParMotCan	:= ""

	Do While .T.
		If !Pergunte( cPerg , .T. )
		   Return
		Endif

		// Lee recibos timbrados
		SelecXML( aItems )

		If Len(aItems) > 0 .And. !Empty(aItems[1,2])
			Exit
		Endif
	Enddo

	cParMotCan := StrZero(MV_PAR10, 2) //Contiene el Motivo de Cancelaci�n seteado en la preguntas

	DEFINE MSDIALOG oDlgCanc FROM aTamanho[1],aTamanho[2] TO aTamanho[6]-40,aTamanho[5]-350 TITLE OemToAnsi(STR0001) PIXEL   // "Anulaci�n de timbres fiscales de Recibos de N�mina"

	@ c(30),c(05) MSCOMBOBOX oIndx VAR cIndx ITEMS aIndx SIZE c(90),c(10) PIXEL OF oDlgCanc
	@ c(30),c(98) BUTTON oBoton PROMPT OemToAnsi(STR0004) SIZE c(35),c(10) ; //"Buscar"
			 ACTION (oLbx1:nAT := BuscaXML(oLbx1,aItems,cBusca,oIndx:nAT), ;
			 		oLbx1:bLine := {|| {IF(aItems[oLbx1:nAt,1],oOk,oNo),aItems[oLbx1:nAt,2],aItems[oLbx1:nAt,3],aItems[oLbx1:nAt,4],aItems[oLbx1:nAt,5],;
					 						aItems[oLbx1:nAt,8], aItems[oLbx1:nAt,6]} }, ;
					oLbx1:SetFocus()) PIXEL OF oDlgCanc
	@ c(45),c(05)  MSGET oBusca VAR cBusca PICTURE "@!" SIZE c(130),c(10) PIXEL OF oDlgCanc
	@ c(60),c(05)  LISTBOX oLbx1 VAR nPosLbx FIELDS HEADER ;
					OemToAnsi(""),;    		// Check
					OemToAnsi(STR0002),;	// Matricula
					OemToAnsi(STR0003),;	// Nombre
					OemToAnsi(STR0005),;	// UUID
					OemToAnsi(STR0020),;	// Sucursal
					OemToAnsi(STR0031),;	//"Fecha/Hora Timbre"
					OemToAnsi(STR0032);	//"Archivo"
	          SIZE aTamanho[6] - 200, aTamanho[4] - 120 OF oDlgCanc PIXEL ON DBLCLICK (MarcaXML(oLbx1,@aItems,@oDlgCanc),;
	          oLbx1:nColPos:= 1,oLbx1:Refresh()) NOSCROLL
	oLbx1:SetArray(aItems)
	oLbx1:bLine := {|| {IF(aItems[oLbx1:nAt,1],oOk,oNo),aItems[oLbx1:nAt,2],aItems[oLbx1:nAt,3],aItems[oLbx1:nAt,4],aItems[oLbx1:nAt,5],;
							aItems[oLbx1:nAt,8], aItems[oLbx1:nAt,6]} }
	oLbx1:Refresh()

	@ aTamanho[4] - 40,c(005) BUTTON oMarTodos PROMPT OemToAnsi(STR0006) SIZE c(45),c(10) ACTION MarcaXML( oLbx1 , @aItems , @oDlgCanc , "M" ) PIXEL OF oDlgCanc //"Marcar Todos"
	@ aTamanho[4] - 40,c(055) BUTTON oDesTodos PROMPT OemToAnsi(STR0007) SIZE c(45),c(10) ACTION MarcaXML( oLbx1 , @aItems , @oDlgCanc , "D" ) PIXEL OF oDlgCanc //"Desmarcar Todos"
	@ aTamanho[4] - 40,c(105) BUTTON oInvSelec PROMPT OemToAnsi(STR0008) SIZE c(45),c(10) ACTION MarcaXML( oLbx1 , @aItems , @oDlgCanc , "I" ) PIXEL OF oDlgCanc //"Invertir seleccion"
	@ aTamanho[4] - 40,c(155) BUTTON oParam    PROMPT OemToAnsi(STR0009) SIZE c(45),c(10) ACTION CambiaParam( cPerg, @oLbx1 , @aItems , oOk , oNo ) PIXEL OF oDlgCanc //"Parametros"

	ACTIVATE MSDIALOG oDlgCanc ON INIT Eval(bDialogInit) CENTERED

	CursorWait()

	If nOpc == 1
		Processa( { || CancelaTimbre(aItems) } , OemToAnsi(STR0013) ) // "Procesando cancelación de timbres fiscales de los recibos seleccionados..."
	Endif

	DeleteObject(oOk)
	DeleteObject(oNo)

	CursorArrow()
	RestArea(aArea)
	
Return

/*/
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o    � BuscaXML � Autor � Alberto Rodriguez         � Data �  18/08/14  ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o �  Buscador...                                                     ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   � BuscaXML()                                                       ���
�������������������������������������������������������������������������������Ĵ��
���Uso       � CancTFD()                                                        ���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
/*/
Static Function BuscaXML( oLbx1 , aItems , cBusca , nIndx )
Local nPos := 0

cBusca := Upper(Alltrim(cBusca))

If nIndx==1		// Matricula
	nPos := aScan(aItems, {|aVal| aVal[2]=cBusca} )
Elseif nIndx==2	// Nombre
	nPos := aScan(aItems, {|aVal| aVal[3]=cBusca} )  // valor corto de lado derecho del '=' puede coincidir; es como softseek
Endif

If nPos == 0
	nPos := oLbx1:nAt
EndIf

Return nPos

/*/
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o    � SelecXML � Autor � Alberto Rodriguez         � Data �  18/08/14  ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o � Lee recibos XML en la carpeta indicada...                        ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   � SelecXML()                                                       ���
�������������������������������������������������������������������������������Ĵ��
���Uso       � CancTFD()                                                        ���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
/*/
Static Function SelecXML( aItems )
	MSAguarde( { || GeneraLista( aItems ) } , OemToAnsi(STR0014) ) //"Obteniendo lista de recibos con timbre fiscal. Por favor, espere..."
Return Nil

/*/
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o    �GeneraLista � Autor � Alberto Rodriguez         � Data �  18/08/14  ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o � Genera lista de recibos XML en la carpeta indicada...              ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GeneraLista()                                                      ���
���������������������������������������������������������������������������������Ĵ��
���Uso       � SelecXML()                                                         ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
/*/
Static Function GeneraLista( aItems )
Local cRutaXML := ALLTRIM(MV_PAR09)
Local cPatron  := ""
Local cDeFil   := ""
Local cAFil    := ""
Local cDeMat   := ""
Local cAMat    := ""
Local cFilRec  := ""
Local cMatRec  := ""
Local cDiag    := IIf( IsSrvUnix() , "/" , "\" )
Local nLenPat  := 0
Local nLenFil  := Len( xFilial("SRA") ) // Trim( If( cVersao == 'P10', xFilial("SRA") , FWFilial("SRA") ) )
Local nLenMat  := TamSX3("RC_MAT")[1]
Local nLoop    := 0
Local aRecibos := {}
Local aRecCanc := {}
Local aRecXML	:= {}
Local nTamRecno		:= 9 //Tama�o del campo recno + "_"
Local nTamRecInd	:= 6 //Tama�o de el string "_indem"

CursorWait()

If !( Right( cRutaXML , 1 ) == cDiag )
	cRutaXML += cDiag
Endif

cPatron := Trim(MV_PAR01)	// Proceso
cPatron += Trim(MV_PAR02)	// Procedimiento
cPatron += Trim(MV_PAR03)	// Periodo
cPatron += Trim(MV_PAR04)	// Numero de pago
cPatron += "_"
cDeFil  := Trim(MV_PAR05)	// De filial
cAFil   := Trim(MV_PAR06)	// A filial
cDeMat  := Trim(MV_PAR07)	// De matricula
cAMat   := Trim(MV_PAR08)	// A matricula
nLenPat := Len(cPatron)
cPatron += Replicate( "?" , nLenFil + nLenMat + nTamRecInd + nTamRecno)
aRecibos := Directory( cRutaXML + cPatron + ".xml" )
aSize( aItems , 0 )

If Len( aRecibos ) == 0
	CursorArrow()
	Aviso( OemToAnsi(STR0010), OemToAnsi(STR0011), {STR0012} )  //"No se encontraron recibos con timbre fiscal."
	aAdd( aItems , { .F. , "" , "" , "" , "" , "" , .F., "" } )
Else
	aRecCanc := Directory( cRutaXML + cPatron + ".xml.canc" )
	aEval( aRecCanc , { | x,i | aRecCanc[ i , 1 ] := Substr( x[1] , 1 , Len(x[1]) - 5 ) } )

	For nLoop := 1 to Len(aRecibos)
		cFilRec := Substr(aRecibos[nLoop,1], nLenPat + 1 , nLenFil)
		cMatRec := Substr(aRecibos[nLoop,1], nLenPat + 1 + nLenFil , nLenMat)
		If ( cFilRec >= cDeFil .And. cFilRec <= cAFil ) .And. ( cMatRec >= cDeMat .And. cMatRec <= cAMat ) .And. ;
		   !("_original" $ Lower(aRecibos[nLoop,1])) .And. aScan( aRecCanc, { |x| , x[1] == aRecibos[nLoop,1] } ) == 0
			If ValidaRecibo( cRutaXML + aRecibos[nLoop,1], aRecXML )
				//aItems := {Marca, Matricula, Nombre, UUID, Sucursal, Archivo, Logico, Fecha Timbrado }
				aAdd( aItems , { .F., cMatRec, aRecXML[1], aRecXML[2], cFilRec, aRecibos[nLoop,1], .F., aRecXML[3] } )
			Endif
		Endif
	Next nLoop

	CursorArrow()

	If Len(aItems) == 0
		Aviso( OemToAnsi(STR0010), OemToAnsi(STR0015), {STR0012} )  // "Atencion" - "No se encontraron recibos para cancelar." - "OK"
		aAdd( aItems , { .F. , "" , "" , "" , "" , "" , .F., "" } )
	Endif

Endif

Return Nil

/*/
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o    �MarcaXML    � Autor � Alberto Rodriguez         � Data �  18/08/14  ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o � Marca recibo(s) XML cancelar                                       ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe   � MarcaXML()                                                         ���
���������������������������������������������������������������������������������Ĵ��
���Uso       � CancTFD()                                                          ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
/*/
Static Function MarcaXML( oLbx1 , aItems , oDlgCanc , cMarca )
Default cMarca := ""

If !Empty(aItems[1,2])
	IF Empty( cMarca )
		aItems[oLbx1:nAt,1] := !aItems[oLbx1:nAt,1]
	ElseIF cMarca == "M"
		aEval( aItems , { |x,y| aItems[y,1] := .T. } )
	ElseIF cMarca == "D"
		aEval( aItems , { |x,y| aItems[y,1] := .F. } )
	ElseIF cMarca == "I"
		aEval( aItems , { |x,y| aItems[y,1] := !aItems[y,1] } )
	EndIF
Endif

Return NIL

/*/
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o    �CambiaParam � Autor � Alberto Rodriguez         � Data �  18/08/14  ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o � Cambia par�metros del proceso                                      ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe   � CambiaParam()                                                      ���
���������������������������������������������������������������������������������Ĵ��
���Uso       � CancTFD()                                                          ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
/*/
Static Function CambiaParam( cPerg, oLbx1 , aItems , oOk , oNo )

If Pergunte( cPerg , .T. )
	SelecXML( aItems )
	oLbx1:SetArray(aItems)
	oLbx1:bLine := {|| {IF(aItems[oLbx1:nAt,1],oOk,oNo),aItems[oLbx1:nAt,2],aItems[oLbx1:nAt,3],aItems[oLbx1:nAt,4],aItems[oLbx1:nAt,5],;
							aItems[oLbx1:nAt,8],aItems[oLbx1:nAt,6]} }
	oLbx1:Refresh()
Endif

Return Nil

/*/
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o    �ValidaCanc  � Autor � Alberto Rodriguez         � Data �  14/08/14  ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o � Valida el proceso de cancelaci�n.                                  ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe   � ValidaCanc( oBrowse, oDialogo, nOpcion, aRecibos )                 ���
���������������������������������������������������������������������������������Ĵ��
���Uso       � CancTFD()                                                          ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
/*/
Static Function ValidaCanc( oLbx1 , oDlgCanc , nOpc , aItems )
Local lRet  := .F.
Local nPos  := 0

nPos := aScan(aItems, {|x| x[1]==.T.} )

If nPos > 0
	lRet := .T.
	nOpc := 1
	oDlgCanc:End()

Else
	Aviso( OemToAnsi(STR0010) , OemToAnsi(STR0016) , {STR0012} ) // "Atencion" - "No se seleccion� ning�n recibo para anular." - "OK"
Endif

Return lRet

/*/
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    �CancelaTimbre� Autor � Alberto Rodriguez         � Data �  19/08/14  ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Cancela CFDi de recibos timbrados                                   ���
����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � CancelaTimbre( aItems )                                             ���
����������������������������������������������������������������������������������Ĵ��
���Uso       � CancTFD()                                                           ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
/*/
Static Function CancelaTimbre( aItems )
Local cRutaSmr := &(SuperGetmv( "MV_CFDSMAR" , .F. , "GetClientDir()" )) + "Errores\"
Local cRutaXML := ALLTRIM(MV_PAR09)
Local cDiag    := IIf( IsSrvUnix() , "/" , "\" )
Local aRecCanc := {}
Local nTimbres := 0
Local nErrores := 0
Local cMensaje := " "

If !( Right( cRutaXML , 1 ) == cDiag )
	cRutaXML += cDiag
Endif

/* aItems
	1- cancelar?
	2- Matrícula
	3- Nombre
	4- UUID
	5- Sucursal
	6- Archivo
	7- Cancelado/Error
	8- Fecha/Hora Timbre
*/

aEval( aItems , { |x| If( x[1] , aAdd(aRecCanc, {x[6], x[4], ""}) , ) } )

// Ejecuta cliente de servicio web para cancelación de TFD
CancTimbreRN( cRutaXML , aRecCanc )

aEval( aRecCanc , { |x| If( Empty(x[3]) , nTimbres++ , ) } )
nErrores := Len(aRecCanc) - nTimbres

If nTimbres == 0
	cMensaje := STR0017  // No se cancelaron timbres fiscales
ElseIf nTimbres == 1
	cMensaje := STR0018  // Se canceló 1 timbre fiscal
Else
	cMensaje := Strtran(STR0019, "#nTimbres#", lTrim(Str(nTimbres)))  // Se cancelaron # timbres fiscales
Endif

If nErrores > 0
	cMensaje += IIf( Empty(cMensaje) , "" , CRLF )
	cMensaje += STR0028 + CRLF + cRutaSmr // Hubo errores en la cancelación de timbres fiscales. + CRLF + Revise el log en la ruta ###
Endif

MsgInfo(cMensaje, STR0010) //"Atenci�n"

Return Nil

/*/
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    �CancTimbreRN � Autor � Alberto Rodriguez         � Data �  26/08/14  ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Cancelaci�n de timbre fiscal digital de recibo de nomina.           ���
����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � CancTimbreRN( cRutaSrv , aRecibos )                                 ���
����������������������������������������������������������������������������������Ĵ��
���Uso       � CancelaTimbre()                                                     ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
/*/
Function CancTimbreRN( cRutaSrv , aRecibos )
Local aArea			:= GetArea()
Local cRutaSmr		:= &(SuperGetmv( "MV_CFDSMAR" , .F. , "GetClientDir()" ))	// Ruta donde reside el ejecutable de timbrado
Local cCFDiUsr		:= SuperGetmv( "MV_CFDI_US" , .F. , "" )						// Usuario del servicio web
Local cCFDiCon		:= SuperGetmv( "MV_CFDI_CO" , .F. , "" )						// Contraseña del servicio web
Local cCFDiPAC		:= SuperGetmv( "MV_CFDI_PA" , .F. , "" )						// Rutina a ejecutar (PAC)
Local cCFDiAmb		:= SuperGetmv( "MV_CFDI_AM" , .F. , "T" )					// Ambiente (Teste o Produccion)
Local cCFDiPub		:= SuperGetmv( "MV_CFDI_CE" , .F. , "" )						// Archivo de llave pública (.cer)
Local cCFDiPri		:= SuperGetmv( "MV_CFDI_PR" , .F. , "" )						// Archivo de llave privada (.key)
Local cCFDiCve		:= SuperGetmv( "MV_CFDI_CL" , .F. , "" )						// Clave de llave privada para autenticar WS
Local nCFDiCmd		:= SuperGetmv( "MV_CFDICMD" , .F. , 0 )						// Mostrar ventana de comando del Shell: 0=no, 1=si
Local lProxySr		:= SuperGetmv( "MV_PROXYSR" , .F. , .F. )					// Emplear Proxy Server?
Local cProxyIP		:= SuperGetmv( "MV_PROXYIP" , .F. , "" )						// IP del Proxy Server
Local nProxyPt		:= SuperGetmv( "MV_PROXYPT" , .F. , 0 )						// Puerto del Proxy Server
Local lProxyAW		:= SuperGetmv( "MV_PROXYAW" , .F. , .F. )					// Autenticación en Proxy Server con credenciales de Windows?
Local cProxyUr		:= SuperGetmv( "MV_PROXYUR" , .F. , "" )						// Usuario para autenticar Proxy Server
Local cProxyPw		:= SuperGetmv( "MV_PROXYPW" , .F. , "" )						// Clave para autenticar Proxy Server
Local cProxyDm		:= SuperGetmv( "MV_PROXYDM" , .F. , "" )						// Dominio para autenticar Proxy Server
Local cLogWS		:= SuperGetmv( "MV_CFDILOG" , .F. , "LOG" )					// Tipo de log en consumo del servicio web: LOG (default), LOGDET (detallado), NOLOG (ninguno)
Local cDirArch		:= &(SuperGetmv( "MV_CFDRECN" , .F. , "'cfd\recibos\'" ))
Local cRutaCFDI		:= cRutaSmr + "Recibos\"
Local cNameCFDI		:= ""
Local cRutina		:= "TimbradoCFDi.exe "
Local cParametros	:= cCFDiPAC + " "
Local cPatron		:= ""
Local cIniFile		:= "" // "TimbradoCFDi_" + cPatron + ".ini"
Local cBatch		:= "" // "Timbrado_" + cPatron + ".bat"
Local nHandle		:= 0
Local cProxy		:= "[PROXY]"
Local nLoop			:= 0
Local nOpc			:= 0
Local lDeMenu		:= ( ( Alltrim(FunName()) == "CANCTFD" ) .Or. !( Alltrim(FunName()) == "RPC" ) )
Local aVacio		:= {}
Local cResultado	:= ""
Local cUUID			:= ""
Local cDirCan		:= cDirArch + "cancelados\"
Local cRutaXML		:= AllTrim(MV_PAR09)
Local nRetDir		:= 0
Local cNewNom		:= ""
Local cFunName		:= FunName()

//Variables utilizadas en el nuevo proceso de Cancelaci�n
Local cLinCmdIni	:= ""
Local cIDASustit	:= ""
Local cMotivo		:= ""
Local cIDSustito	:= ""

If cFunName == "GPER884" //Se valida que la rutina sea la GPER884 y se setea la direcci�n de los recibos a cancelar
	cRutaXML := cDirArch + "cancelar\"
EndIf

If Len( aRecibos ) < 1 .Or. Len( aRecibos[1] ) < 3
	Return aVacio
Endif

If Empty(cRutaSrv) .Or. Empty(cRutaSmr) .Or. Empty(cCFDiUsr) .Or. Empty(cCFDiCon) .Or. Empty(cCFDiPAC) .Or. ;
   Empty(cCFDiPub) .Or. Empty(cCFDiPri) .Or. Empty(cCFDiCve)
	If lDeMenu
		Aviso( STR0010 , STR0021, {STR0012} )  //"Atencion" - "Existen parámetros sin definir del proceso de timbrado." - "OK"
	Else
		Conout( ProcName(0) + ": " + STR0021 ) //"Hay par�metros sin definir para el proceso de timbrado."
	Endif
	Return aVacio
Endif

// Valida ruta de alojamiento del ejecutable de timbrado
If !( cRutaSmr == Strtran( cRutaSmr , " " ) )
	If lDeMenu
		Aviso( STR0010 , STR0022, {STR0012} ) //"Atencion" - "La ruta del ejecutable de timbrado no es válida" - "OK"
	Else
		Conout( ProcName(0) + ": " + STR0022 ) //"La ruta del ejecutable de timbrado no es v�lida."
	Endif
	Return aVacio
Endif

// Verifica la existencia del EXE de WS para timbrado
If !File( cRutaSmr + cRutina )
	// Compatibilidad con versiones autónomas
	cRutina := "Timbrado" + Trim(cCFDiPAC) + ".exe "
	cParametros := ""

	// Validar si el ejecutable existe
	If !File( cRutaSmr + cRutina )
		If lDeMenu
			Aviso( STR0010 , STR0023 + " " + cRutaSmr + cRutina, {STR0012} )  //"Atencion" - "No hay el ejecutable para acceder al servicio web:" - "OK"
		Else
			Conout( ProcName(0) + ": " + STR0023 + " " + cRutaSmr + cRutina ) //"No hay el ejecutable para acceder al servicio web:"
		Endif
		Return aVacio
	Endif
Endif

// Archivo .ini con la lista de CFDi a timbrar
cPatron  := Substr( aRecibos[1,1] , 1 , At( "_" , aRecibos[1,1] ) - 1 )
cIniFile := "TimbradoCFDi_" + cPatron + ".ini"
cBatch   := "Timbrado_" + cPatron + ".bat"
nHandle	:= FCreate( cRutaSmr + cIniFile )

If nHandle == -1
	If lDeMenu
		Aviso( STR0010 , STR0024 + cRutaSmr, {STR0012} ) //"Atencion" - "No se puede crear el archivo temporal en el directorio." - "OK"
	Else
		Conout( ProcName(0) + ": " + STR0024 + cRutaSmr ) //"No se puede crear el archivo temporal en el directorio."
	Endif
	Return aVacio
Endif

If lDeMenu
	ProcRegua( Len(aRecibos) )
Endif

FWrite( nHandle, "[RECIBOS]" + CRLF )

// Copiar archivos .xml del servidor a la ruta del smartclient o la establecida (StartPath...\CFD\RECIBOS\xxx...xxx.XML a x:\totvs\protheusroot\bin\smartclient)
MakeDir( cRutaCFDI )

For nLoop := 1 to Len( aRecibos )
	cNameCFDI := aRecibos[nLoop , 1 ]
	cIDASustit := aRecibos[nLoop , 2 ] //UUID a sustituir

	If File( cRutaCFDI + cNameCFDI )
		FErase( cRutaCFDI + cNameCFDI )
	Endif

	If File( cRutaCFDI + cNameCFDI + ".out" )
		FErase( cRutaCFDI + cNameCFDI + ".out" )
	Endif

	If File( cRutaCFDI + cNameCFDI + ".canc" )
		FErase( cRutaCFDI + cNameCFDI + ".canc" )
	Endif

	CpyS2T( cRutaSrv + cNameCFDI , cRutaCFDI )
	// Quitar la Addenda para realizar el timbrado
	AddendaCFDi( cRutaCFDI , cNameCFDI , "1" )

	cLinCmdIni := cNameCFDI

	If fDetIDSust(cIDASustit, @cMotivo, @cIDSustito) //Valida si el UUID del recibo a sustituir existe asociado en RIW
		cLinCmdIni += " " + AllTrim(cMotivo) + IIf(AllTrim(cMotivo) == "01", " " + cIDSustito, "")
	Else
		cLinCmdIni += " " + IIf(cFunName == "CANCTFD", cParMotCan, "02")
	EndIf

	FWrite( nHandle, cLinCmdIni + CRLF )

	If lDeMenu
		IncProc()
	Endif
Next nLoop

fClose( nHandle )

// Parámetros para el Proxy Server
cProxy += "[" + If( lProxySr , "1" , "0" ) + "]"
cProxy += "[" + cProxyIP + "]"
cProxy += "[" + lTrim( Str( nProxyPt ) ) + "]"
cProxy += "[" + If( lProxyAW , "1" , "0" ) + "]"
cProxy += "[" + If( lProxyAW , "" , cProxyUr ) + "]"
cProxy += "[" + If( lProxyAW , "" , cProxyPw ) + "]"
cProxy += "[" + If( lProxyAW , "" , cProxyDm ) + "]"

// parametros: PAC, Usuario, Password, Factura.xml, Ambiente,
cParametros += cCFDiUsr + " " + cCFDiCon + " " + cIniFile + " " + cCFDiAmb +  " "
//             Archivo.cer, Archivo.key, ClaveAutenticacion, UUID, Timbrar/Cancelar
cParametros += cCFDiPub + " " + cCFDiPri + " " + cCFDiCve + " . S "
//			   Proxy, log
cParametros += cProxy + " " + cLogWS

If nCFDiCmd < 0 .Or. nCFDiCmd > 10
	nCFDiCmd := 0
Endif

If nCFDiCmd == 3 .Or. nCFDiCmd == 10
	nHandle	:= FCreate( cRutaSmr + cBatch )
	If nHandle == -1
		If lDeMenu
			Aviso( STR0010 , STR0024 + cRutaSmr, {STR0012} ) //"Atencion" - "No se puede crear el archivo temporal en el directorio." - "OK"
		Else
			Conout( ProcName(0) + ": " + STR0024 + cRutaSmr ) //"No se puede crear el archivo temporal en el directorio."
		Endif
		Return aVacio
	Endif

	FWrite( nHandle, cRutaSmr + cRutina + Trim(cParametros) + CRLF )
	FWrite( nHandle, "Pause" + CRLF )
	fClose( nHandle )
	nOpc := WAITRUN( cRutaSmr + cBatch, nCFDiCmd )
Else
	// Ejecuta cliente de servicio web
	nOpc := WAITRUN( cRutaSmr + cRutina + Trim(cParametros), nCFDiCmd )	// SW_HIDE
Endif

If lDeMenu
	ProcRegua(Len(aRecibos))
Endif

cRutaXML := StrTran(cRutaXML,"/","\")
cRutaXML += IIf(Right(cRutaXML,1)=="\", "", "\")

For nLoop := 1 to Len( aRecibos )
	If lDeMenu
		IncProc( STR0025 + Alltrim(Str(nLoop)) + "/" + Alltrim(Str(Len(aRecibos))) ) // Verificando cancelación de timbres fiscales de recibos...
	Endif

	cNameCFDI := aRecibos[nLoop , 1 ]
	cUUID     := aRecibos[nLoop , 2 ]

	If !ExistDir(cDirCan)
		nRetDir := MakeDir(cDirCan)
		If nRetDir != 0
			MsgInfo(STR0029 + cValToChar(FError())) //No fue posible crear el archivo. Error: 
	    Endif
    EndIf

	If nOpc == 0 .And. File( cRutaCFDI + cNameCFDI + ".out" )
		cResultado := ""
		If ChecaCancTF(cRutaCFDI + cNameCFDI + ".out", @cResultado)
			cMensaje := ""
			DBSelectArea("RIW")
			RIW->(dbSetOrder(2)) //RIW_FILIAL + RIW_UUID
			IF RIW->(dbSeek(xFilial("RIW")+cUUID)) 
				RIW->(RecLock("RIW", .F.))
				RIW->RIW_FECANT := dDataBase
				If cFunName == "CANCTFD" .And. RIW->(ColumnPos("RIW_MOTIVO")) > 0 .And. Empty(RIW->RIW_MOTIVO)
					RIW->RIW_MOTIVO := cParMotCan
				EndIf
				RIW->(MSUnlock())
			EndIf
			//Copiar respuesta del WS al servidor
			cNewNom := Substr(cNameCFDI,1,len(cNameCFDI)-4) + "_" + dtos(ddatabase) + "-" +  StrTran( Time(), ":", "_" ) + ".xml"
			
			Frename(cRutaCFDI + cNameCFDI + ".out" , cRutaCFDI + cNewNom + ".canc")

			If File(cRutaCFDI + cNewNom + ".canc")
				/*Copia xml.out del servidor a Smartclient*/
				CpyS2T(cRutaSrv + cNameCFDI + ".out", cRutaCFDI)

				Frename(cRutaCFDI + cNameCFDI,  cRutaCFDI + cNewNom) //Renombra xml
				Frename(cRutaCFDI + cNameCFDI + ".out",  cRutaCFDI + cNewNom + ".out") //Renombra xml.out

				/*Copia respuesta de cancelaci�n a carpeta "Cancelados"*/
				If CpyT2S(cRutaCFDI + cNewNom + ".canc", cDirCan)
					Ferase(cRutaCFDI + cNewNom + ".canc")
				Else
					Conout(STR0030 + cRutaCFDI + cNewNom + ".canc")
				EndIf

				/*Elimina archivos del servidor solo si realiz� la copia a carpeta "Cancelados"*/
				If CpyT2S(cRutaCFDI + cNewNom, cDirCan)
					Ferase(cRutaXML + cNameCFDI)
				Else
					Conout(STR0030 + cRutaCFDI + cNewNom)
				EndIf
				If CpyT2S(cRutaCFDI + cNewNom + ".out", cDirCan)
					Ferase(cRutaXML + cNameCFDI + ".out")
				Else
					Conout(STR0030 + cRutaCFDI + cNewNom + ".out")
				EndIf
			EndIF
		Else
			cMensaje := If( Empty(cResultado) , STR0027 , cResultado ) //"No se pudo anular el folio fiscal del recibo"
		Endif
	Else
		cMensaje := STR0026 //"No se encuentra respuesta de cancelaci�n del recibo"
	Endif

	aRecibos[ nLoop , 3 ] := cMensaje

	If !lDeMenu .And. !Empty( cMensaje )
		Conout( ProcName(0) + ": " + cMensaje + " " + cNameCFDI )
	Endif

	// Eliminar temporales
	Ferase( cRutaCFDI + cNewNom )
	Ferase( cRutaCFDI + cNewNom + ".out" )
Next nLoop

GrabaLog( cRutaSmr + "Errores\", aRecibos )

RestArea(aArea)

Return aRecibos

/*/
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    �ChecaCancTF  � Autor � Alberto Rodriguez         � Data �  18/08/14  ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Valida si el timbre fiscal se cancel�                               ���
����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � ChecaCancTF( cArchivo , @cMensaje)                                  ���
����������������������������������������������������������������������������������Ĵ��
���Uso       � CancTimbreRN()                                                      ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
/*/
Static Function ChecaCancTF( cFile , cResultado )
Local nHandle 	:= 0
Local aInfoFile	:= {}
Local nSize		:= 0
Local nRegs		:= 0
Local nFor		:= 0
Local cBuffer	:= ""
Local cLine		:= ""
Local cString	:= ""
Local lRet      := .F.

Begin Sequence
   	nHandle := fOpen(cFile)

	If  nHandle <= 0
		cResultado := STR0026  //"No fue posible abrir el archivo .out"
		Break
	EndIf

	aInfoFile := Directory(cFile)
	nSize := aInfoFile[ 1 , 2 ]
	nRegs := Int(nSize/2048)

	For nFor := 1 to nRegs
		fRead( nHandle , @cBuffer , 2048 )
		cLine += cBuffer
	Next

	If nSize > nRegs * 2048
		fRead( nHandle , @cBuffer , (nSize - nRegs * 2048) )
		cLine += cBuffer
	Endif

	fClose(nHandle)
End Sequence

If Substr(cLine,1,1) == "("
	cLine := Substr(cLine,2)
	cLine := Strtran( cLine , ")" , " " , 1 , 1 )
EndIF

cBuffer := Upper(cLine)

If ( "UUID CANCELADO" $ cBuffer ) .Or. ( "STATUSUUID>201" $ cBuffer ) .Or. ( "STATUSUUID>202" $ cBuffer ) .Or. ;
	( "SE REPORTARA" $ cBuffer .And. "CANCELADO" $ cBuffer) .Or. ( "PREVIAMENTE" $ cBuffer .And. "CANCELADO" $ cBuffer) .Or. ;
	( "ESTATUSUUID>201" $ cBuffer ) .Or. ( "ESTATUSUUID>202" $ cBuffer ) .Or. ("EL ARCHIVO SE PROCESO CON EXITO" $ cBuffer)
	lRet := .T.
Else
	cString	:= Substr( cLine , 1 , 4 )
	If Empty(cLine) .Or. ( "ERROR" $ cBuffer ) .Or. ( "FAILED" $ cBuffer ) .Or. ( "FAIL " $ cBuffer ) .Or. ( "EXCEPTION" $ cBuffer ) .Or. ;
	( "EXCEPCION" $ cBuffer ) .Or. ( "EXCEPCIóN" $ cBuffer ) .Or. ( "EXCEPCIÓN" $ cBuffer )  .Or. ( Val(cString) > 0 ) .Or. ;
	( "CANCELED" $ cBuffer .And. "FALSE" $ cBuffer ) .Or. ("NO EXISTE" $ cBuffer) .Or. ("STATUSUUID>205" $ cBuffer) .Or.;
	("EL FOLIO SUSTITUCION DEL UUID" $ cBuffer .And. "ES REQUERIDO" $ cBuffer)
		lRet := .F. // Error
	Else
		lRet := .T.
	Endif
Endif

cResultado := Alltrim(cLine)

Return 	lRet

/*/
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    �AddendaCFDi  � Autor � Alberto Rodriguez         � Data �  09/12/11  ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Manejo de Addenda para timbrar xml. Las funciones de tratamiento    ���
���          � de xml alteran el formato!!!                                        ���
����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � AddendaCFDi( cRutaSmartclient, cArchivoXML, cOpcion )               ���
���Sintaxe   � cOpcion 1-Elimina, 2-Restaura                                       ���
����������������������������������������������������������������������������������Ĵ��
���Uso       �                                                                     ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
/*/
Static Function AddendaCFDi(cRutaXML, cArchivo, cOpcion)
Local aXML	:= {}
Local cEtiq1:= "<cfdi:Addenda"
Local cEtiq2:= "</cfdi:Addenda>"
Local cFin	:= "</cfdi:Comprobante>"
Local nIni	:= 0
Local nFin	:= 0
Local nLoop	:= 0
Local lRet	:= .F.

Static aAddenda := {}

// Leer xml recibido como string
aXML := File2Array( cRutaXML + cArchivo )

If Len(aXML) > 0
	If cOpcion == "1"
		// Extrae la Addenda y la elimina del xml
		aSize( aAddenda , 0 )
		nIni := aScan( aXML , {|x| cEtiq1 $ x } )

		If nIni > 0
			// Hace copia de la Addenda
			For nLoop := nIni To Len(aXML)
				aAdd( aAddenda , aXML[nLoop] )
				If cEtiq2 $ aXML[nLoop]
					nFin := nLoop
					Exit
				Endif
			Next

			If nFin == 0
				// Indica que el elemento Addenda termina en la misma línea del xml: "... />" puede haber espacios los caracteres
				nFin := nIni
			Endif

			// Elimina la Addenda
			For nLoop := nFin To nIni Step -1
				aDel( aXML , nLoop )
				aSize( aXML , Len(aXML)-1 )
			Next

			// Codificacion UTF-8
			If Substr(aXML[1], 1, 1) == "<"
				aXML[1] := EncodeUTF8( aXML[1] )
			Endif

			// Graba el xml actualizado
			lRet := Array2File( cRutaXML + cArchivo , aXML )
		Endif

	ElseIf Len(aAddenda) > 0
		// Restaura la Addenda en el xml timbrado
		For nLoop := Len(aXML) To 1 Step -1
			If cFin $ aXML[nLoop]
				nIni := nLoop
				Exit
			Endif
		Next

		// Como viene el xml? formateado o todo seguido
		If !( cFin == Alltrim( aXML[nIni] ) )
			// La línea donde se encuentra la etiqueta de cierre de documento contiene más definiciones ==> partirla
			aSize( aXML , Len(aXML) + 1 )
			nFin := At( cFin , aXML[nIni] )
			aXML[nIni + 1] := Substr( aXML[nIni] , nFin )
			aXML[nIni] := Substr( aXML[nIni] , 1 , nFin - 1 )
			++nIni
		Endif

		// Reinserta la Addenda
		For nLoop := 1 To Len(aAddenda)
			aSize( aXML , Len(aXML)+1 )
			aIns( aXML , nIni + nLoop - 1 )
			aXML[nIni + nLoop - 1] := aAddenda[nLoop]
		Next

		// Graba el xml final
		lRet := Array2File( cRutaXML + cArchivo , aXML )

	Endif
Endif

Return lRet

/*/
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    �File2Array   � Autor � Alberto Rodriguez         � Data �  12/12/11  ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Lee un archivo de texto y deja el contenido en un arreglo Sin CR+LF ���
���          �                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � File2Array( cArchivo, aDatos )                                      ���
���Sintaxe   �                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Uso       �                                                                     ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
/*/
Static Function File2Array( cFile )
Local nHandle		:= 0
Local aInfoFile		:= {}
Local nSize			:= 0
Local nTamChr		:= 0
Local nPosFimLinha	:= 0
Local aFile 		:= {}
Local cLine			:= ""
Local cImpLine		:= ""
Local cAuxLine		:= ""

Begin Sequence

	IF !( File( cFile ) )
		Break
	EndIF

	nHandle 	:= fOpen( cFile )
	If nHandle <= 0
		Break
	EndIf
	aInfoFile	:= Directory( cFile )
	nSize		:= aInfoFile[ 1 , 2 ]

	/*/
	�������������������������������������������������������������������
	�� Extrai uma linha "FISICA" de texto (pode conter varias linhas ��
	�� logicas)                                                      ��
	�������������������������������������������������������������������
	/*/
	cLine	:= fReadStr( nHandle , nSize )

	/*/
	���������������������������������������������������������������������
	�� Gerar o Array para a GetDados                                   ��
	�� Verifica a Existencia de CHR(13)+CHR(10) //Carriage Return e    ��
	�� Line Feed na linha extraida do texto Se ambos existirem, esta   ��
	�� mos trabalhando em ambiente Windows. Caso contrario, estamos    ��
	�� em ambiente Linux e somente teremos o CHR(10) para indicar o    ��
	�� final da linha                                                  ��
	���������������������������������������������������������������������
	/*/
	If (nPosFimLinha	:=	At( CRLF , cLine ) ) == 0
		nPosFimLinha	:=	At( Chr(10) , cLine )
		nTamChr := 1
	Else
		nTamChr := 2
	EndIf

	cImpLine := Substr( cLine, 1, nPosFimLinha - 1 )
	cAuxLine := Substr( cLine, nPosFimLinha+nTamChr, nSize )

	If Len( cImpLine ) > 0
		aAdd( aFile, cImpLine )
	Else
		aAdd( aFile, cLine )
	EndIf

	While nPosFimLinha <> 0
		If nTamChr == 1
			nPosFimLinha	:=	At( Chr(10) , cAuxLine )
		Else
			nPosFimLinha	:=	At( CRLF , cAuxLine )
		EndIf

		If nPosFimLinha <> 0
			cImpLine := Substr( cAuxLine, 1, nPosFimLinha - 1 )
			cAuxLine := Substr( cAuxLine, nPosFimLinha+nTamChr, nSize )
			aAdd( aFile, cImpLine )
		ElseIf Len( cAuxLine ) > 0
			aAdd( aFile, cAuxLine )
		EndIf
	EndDo

	fClose( nHandle )

End Sequence

Return( aFile )

/*/
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    �Array2File   � Autor � Alberto Rodriguez         � Data �  12/12/11  ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Graba un arreglo en un archivo de texto agregando CR + LF           ���
���          � al final de cada l�nea                                              ���
����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � Array2File( cArchivo, aDatos )                                      ���
���Sintaxe   �                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Uso       �                                                                     ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
/*/
Static Function Array2File(cArchivo, aDatos)
Local nHandle	:= FCreate(cArchivo)
Local nLoop		:= 0
Local lRet		:= .F.

If !(nHandle == -1)
	For nLoop := 1 to Len(aDatos)
		FWrite(nHandle, aDatos[nLoop] + CRLF)
	Next
   FClose(nHandle)
   lRet := .T.
EndIf

Return lRet

/*/
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    �C()          � Autor � Alberto Rodriguez         � Data � 10/05/2005 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao responsavel por manter o Layout independente da resolucao    ���
���          � horizontal do Monitor do Usuario.                                   ���
����������������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                                     ���
����������������������������������������������������������������������������������Ĵ��
���Uso       �                                                                     ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
/*/
Static Function C(nTam)
	Local nHRes	:= oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	
	If nHRes == 640 // Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800) // Resolucao 800x600
		nTam *= 1
	Else // Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf

	//Tratamento para tema "Flat"
	If "MP8" $ oApp:cVersion .Or. oApp:cVersion $ "11"
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)

/*/
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    �GrabaLog     � Autor � Alberto Rodriguez         � Data � 09/09/14   ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Graba log de recibos no timbrados                                   ���
����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GrabaLog( cRuta , aRecibos )                                        ���
���          � [x,1] - Nombre del archivo xml                                      ���
���          � [x,3] - mensaje de error                                            ���
����������������������������������������������������������������������������������Ĵ��
���Uso       � CFDiRecNom                                                          ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
/*/
Static Function GrabaLog(cRuta , aRecibos)
Local cArchivo  := DtoS(dDataBase) + Strtran(Time(), ":") + ".log"
Local nHandle	:= FCreate(cRuta + cArchivo)
Local nLoop		:= 0
Local lRet		:= .F.

If !(nHandle == -1)
	For nLoop := 1 to Len(aRecibos)
		If !Empty( aRecibos[nLoop,3] )
			FWrite(nHandle, aRecibos[nLoop,1] + " " + aRecibos[nLoop,3] + CRLF)
		Endif
	Next

	FClose(nHandle)
	lRet := .T.
EndIf
Return lRet

/*/{Protheus.doc} fDetIDSust
	Funci�n utilizada para obtener informaci�n de Motivo y UUID a sustituir.
	en la tabla RIW.
	@type  Static Function
	@author marco.rivera
	@since 13/03/2022
	@version 1.0
	@param cUUID, Character, UUID de recibo a cancelar
	@param cMotivo, Character, Par�metro por referencia para obtener Motivo.
	@param cIDSustito, Character, Parametro por referencia para obtener UUID a sustituir.
	@return lRet, L�gico, True si existe el registro en RIW.
	@example
	fDetIDSust(cUUID, cMotivo, cIDSustito)
/*/
Static Function fDetIDSust(cUUID, cMotivo, cIDSustito)

	Local aAreaRIW		:= GetArea()
	Local cTmpRIW		:= GetNextAlias()
	Local lRet			:= .F.
	Local cFilRIW		:= xFilial("RIW")

	Default cUUID		:= ""
	Default cMotivo		:= ""
	Default cIDSustito	:= ""

	BeginSql Alias cTmpRIW
		SELECT RIW_MOTIVO, RIW_IDSUST
		FROM %table:RIW%
		WHERE RIW_FILIAL = %exp:cFilRIW% AND
			RIW_UUID = %exp:cUUID% AND
			RIW_FECANT = '' AND
			%NotDel%
	EndSql

	While (cTmpRIW)->(!Eof())
		cMotivo		:= (cTmpRIW)->RIW_MOTIVO
		cIDSustito	:= (cTmpRIW)->RIW_IDSUST
		(cTmpRIW)->(DBSkip())
	EndDo

	(cTmpRIW)->(DbCloseArea())
	RestArea(aAreaRIW)

	If !Empty(cMotivo)
		lRet := .T.
	EndIf
	
Return lRet
