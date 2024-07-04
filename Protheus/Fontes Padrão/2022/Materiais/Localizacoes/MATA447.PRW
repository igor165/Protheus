#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA447.CH"
#INCLUDE "FWLIBVERSION.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATA447  ³ Autor ³  Gpe. Santacruz           ³ Data ³ 14/03/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Registro de Pedimentos                              (Mexico)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MATA447()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³   BOPS   ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Dora Vega   ³30/08/17³DMINA-    ³Se elimina CTREE de la rutina MATA447.    ³±±
±±³            ³        ³   166    ³Se agrega la version de 12.1.14 MI.(MEX)  ³±±
±±³ Marco A    ³29/09/17³TSSERMI01-³Se realiza replica para V12.1.17, de la   ³±±
±±³            ³        ³151       ³funcionalidad de Pedimentos de Importacion³±±
±±³            ³        ³          ³para el Pais Mexico.                      ³±±
±±³ Jose Gles  ³28/02/18³DMINA-2097³ Se Ajusta Mata447 para Script de         ³±±
±±³            ³        ³          ³ Automatización                           ³±±
±±³ Marco A    ³04/07/18³DMANSIST-6³Se agrega la eliminacion de la tabla tem- ³±±
±±³            ³        ³          ³poral oTmp.                               ³±±
±±³ Marco A    ³17/07/18³DMANSISTE-³Se agrega validacion para el uso correcto,³±±
±±³            ³        ³27        ³de la TES, al crear un Pedimento. Se modi-³±±
±±³            ³        ³          ³fica funcion MT447A1TES().                ³±±
±±³ gSantacruz ³17/09/18³DMINA-3952³Se agrega validacion para evitar repetir  ³±±
±±³            ³        ³          ³codigo de producto en los items de la     ³±±
±±³            ³        ³          ³factura.								  ³±±
±±³ gSantacruz ³08/08/19³          ³Adecuaciones para automatizacion de testes³±±
±±³            ³        ³          ³evitando uso de objetos visuales.         ³±±
±±³ Oscar G.   ³29/10/19³DMINA-7586³Ajuste de centavos al realizar prorrateo  ³±±
±±³            ³        ³          ³en factura de Gastos.(MEX)                ³±±
±±³ Jose Glez  ³21/01/20³DMINA-7940³Se agrega actualización de objeto oGetFact³±±
±±³            ³        ³          ³con el contenido del arreglo aCoGetFacts. ³±±
±±³            ³        ³DMINA-8379³Se agrega Validación para el Num de Dcto  ³±±
±±³            ³        ³          ³no se repita en la tabla en RSE (RSE_FACT)³±±
±±³            ³        ³          ³que no sea un pedimento Rectificado       ³±±
±±³ Jose Glez  ³03/04/20³DMINA-8604³Se agrega tratamiento para los items que  ³±±
±±³            ³        ³          ³provienen de un Pedido de Compra. y se 	  ³±±
±±³            ³        ³          ³validen cuando de eliminen en el pedimento³±±
±±³ Jose Glez  ³11/11/20³DMINA-    ³Se agrega  MT447OC2() se agrega las       ³±±
±±³            ³        ³    10218 ³funciones MAFISRET para los campos        ³±±
±±³            ³        ³          ³IT_PRCUNI  y IT_VALMERC (MEX)             ³±±
±±³  Marco A.  ³25/08/21³DMINA-    ³Se agrega el uso de métricas, para llevar ³±±
±±³            ³        ³    13342 ³el registro de pedimentos por tipo.       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MATA447(nOpcAuto,xAutCabPed,xAutCabTra,xAutGetIN,xAutGetIP,xAutGetEF,xAutGetIm1)

	Local aCores		:= 	{{"RSC_STATUS == ' '"	, "BR_VERDE"	},;	//Sin facturas generadas
							{"RSC_STATUS == '1'"	, "BR_AMARELO"	},;	//Facturas parcialmente generadas
							{"RSC_STATUS == '2'"	, "BR_VERMELHO"}}	//Todas las facturas generadas

	Local cAliasPed		:= "RSC"

	Local   cCodIVA		:= GetMV("MV_MXIVAIM")	//Codigo de IVA de importaciones dela tabla SFB ///METER A LA ESPEC Y REGISTRAR EN ATUSX
	Private cLisDep		:= GetMV("MV_MXDEPFI")	//Lista de codigos de Claves de pedimento, que ingresan a Deposito fiscal
	Private cLisExt		:= GetMV("MV_MXEXTRA")	//Lista de codigos de Claves de pedimento, que son para extracción de Deposito Fiscal
	Private cLisRec		:= GetMV("MV_MXRECTI")	//Lista de codigos de Claves de pedimento, que son para Rectificaciones
	Private lProdDup	:= GetMV("MV_MXPRODD",.T.,.F.)	//Permite duplicar productos?
	Private cCadastro	:= OemToAnsi(STR0004)	//"Pedimentos"

	Private cDocTipo	:= '' //Se usa en la funcion de la generacion de la factura de impuestos

	Private nP_PORIVA	:= 0  //% de IVA

	Private aLeyenda	:= {{'BR_VERDE',STR0001},{'BR_AMARELO',STR0002},{'BR_VERMELHO',STR0003}}//"No ha generado facturas" ## "Con facturas parcialmente generadas" ##"Con todas las facturas generadas"

	Private aRotina		:=	{{OemToAnsi(STR0005), "AxPesqui"	, 0, 01},;	//"Buscar"
							{ OemToAnsi(STR0006), "MT447Mtto"	, 0, 02},;	//"Visualizar"
							{ OemToAnsi(STR0007), "MT447Mtto"	, 0, 03},;	//"Incluir"
							{ OemToAnsi(STR0008), "MT447Mtto"	, 0, 04},;	//"Modificar"
							{ OemToAnsi(STR0009), "MT447Mtto"	, 0, 05},;	//"Borrar"
							{ OemToAnsi(STR0010), "MATR448"		, 0, 06},;	//"Informe Validacion"
							{ OemToAnsi(STR0011), "MATA447B(3)"	, 0, 07},;	//"Generar Doctos."
							{ OemToAnsi(STR0012), "MATA447B(5)"	, 0, 08},;	//"Eliminar Doctos."
							{ OemToAnsi(STR0013), "MT447Leyen"	, 0, 09}}	//"Leyenda"

	Private aAutoCab   	:= {}
	Private aAutCabTra 	:= {}
	Private aAutGetIN	:= {}
	Private aAutGetIP	:= {}
	Private aAutGetEF	:= {}
	Private aAutGetIF	:= {}
	Private aAutGetIm1	:= {}
	Private aAutGetIm2	:= {}

	Private LMT447Ext	:= .F.  //Si es una extraccion de pedimento
	Private LMT447Dep	:= .F.  //Si es un Pedimento que va a Deposito Fiscal
	Private LMT447Rec	:= .F.  //Si es un Pedimento de Rectificacion
	Private lPVez		:= .T.

	Private lX001Auto	:= xAutCabPed <> Nil  //si es ejecutado por rutina automatica
	Private lAutoTeste	:= IsBlind()//se ejecutra por teste Atomatizado

	/*Variables utilizadas para Métricas de promedio*/
	Private nConMetImp  := 0
	Private nUsoBtnRes	:= 0

	DBSelectArea("RSC")
	DBSelectArea("SFB")
	DBSetOrder(1)
	If SFB->(DBSeek(xFilial("SFB")+cCodIVA))
		nP_PORIVA := SFB->FB_ALIQ
		DBSelectArea("RSE")
		DBSelectArea(cAliasPed)
		DBSetOrder(1)
		MsSeek(xFilial(cAliasPed))
		If  lX001Auto
			aAutoCab := xAutCabPed
			If xAutCabTra <> Nil
				aAutCabTra := xAutCabTra
			EndIf
			If xAutGetIn <> Nil
				aAutGetIn := ReDimensiona(xAutGetIn)
			EndIf
			If xAutGetIP <> Nil
				aAutGetIP := ReDimensiona(xAutGetIP)
			EndIf
			If xAutGetEF <> Nil
				aAutGetEF := ReDimensiona(xAutGetEF)
			EndIf
			If xAutGetIm1 <> Nil
				If xAutGetIm1[1] <> Nil
					aAutGetIF := ReDimensiona(xAutGetIm1[1])
				EndIf
			EndIf
			If xAutGetIm1 <> Nil
				If xAutGetIm1[2] <> Nil
					aAutGetIm1 := ReDimensiona(xAutGetIm1[2])
				EndIf
			EndIf
			If xAutGetIm1 <> Nil
				If xAutGetIm1[3] <> Nil
					aAutGetIm2 := ReDimensiona(xAutGetIm1[3])
				EndIf
			EndIf
			MBrowseAuto(nOpcAuto,xAutCabPed,cAliasPed)
		Else
			mBrowse(6, 1, 22, 75, cAliasPed,,,,,,aCores)
		EndIf
	Else
		Help(" ", 1, "Help",,STR0014, 1, 0) //"El codigo de impuesto del parametro MV_MXIVAIM, no existe en el catalogo de impuestos variables, verifíquelo."
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MT447Leyen³Autor ³  Gpe. Santacruz       ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Descripcion de los colores de la leyenda de pedimentos.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Ninguno                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447Leyen()
	BrwLegenda(cCadastro,STR0013,aLeyenda)//Leyenda
Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447Mtto  ³Autor ³  Gpe. Santacruz       ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Inicio de pantallas para registro.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447Mtto(cAlias,nReg,nOpc)

	Local aArea		:= GetArea()
	Local aSvKeys	:= GetKeys()
	Local aButtons	:= {}
	Local oSize		:= Nil
	Local oSize2	:= Nil
	Local oSize3	:= Nil
	Local aSize		:= {}
	Local aPosObj	:= {}
	Local aCamRSC	:= {}
	Local aAlterRSC	:= {}
	Local aCamRSO	:= {}
	Local aAlterRSO	:= {}

	Local aHeadRSK	:= {}
	Local aColsRSK	:= {}

	Local aHeadRSD	:= {}
	Local aColsRSD	:= {}
	Local aHeadRSE	:= {}
	Local aColsRSE	:= {}
	Local aHeadRSF	:= {}
	Local aColsRSF	:= {}
	Local aHeadRSI	:= {}
	Local aColsRSI	:= {}

	Local aHeadTot3	:= {}
	Local aColsTot3	:= {}

	Local aHeadTot2	:=	{}
	Local aColsTot2	:= {}

	Local aHeadTot1	:= {}
	Local aColsTot1	:= {}

	Local aFolder		:= {STR0015,STR0016,STR0017,STR0018,STR0019,STR0020,STR0022}//"Registro","Transporte","Incrementables","Impuesto a Nivel Pedimento","Facturas","Items","Costos de Mercancia M.N."

	Local bCalcula		:= {|| If (VldAntCal(nopc),(If (!LMT447EXT,MT447CALCULO(.T.),CALCOSEXT())),)}
	Local bSelProductos	:= {|| If (NOPC == 3 .Or. NOPC == 4,(If (LMT447EXT,   MT447SelPr(), If (!LMT447REC,(If (oFoldMT447:nOption==6,MT447AFACTS(),MsgInfo("Debe posicionarse en la pestaña de items"))),MsgInfo("Botón sin uso para Pedimentos de Rectificacion"))                    )   ),)}
	Local bCancela		:= {|| oDlg:End()}
	Local bGraba		:= {|| If(MT447Graba(nOpc,aAlterRSC,aAlterRSO),oDlg:End(),)}
	Local bDelFactsOk	:= {|| .T. }

	Local nHay		:= 0
	Local nx		:= 0
	Local ny	 	:= 0
	Local nz	 	:= 0
	Local nOpcGet	:= 0
	Local nz2		:= 0
	Local nz1		:= 0
	Local nl 		:= 0
	Local nPosFor	:= 0
	Local nPosLoja	:= 0

	Local cTmpPed	:= ''
	Local cNumPed	:= ''
	Local cAliasRSC	:= "RSC"
	Local cAliasRSO	:= "RSO"

	Local cAliasRSK	:= "RSK"
	Local cAliasRSD	:= "RSD"
	Local cAliasRSE	:= "RSE"
	Local cAliasRSF	:= "RSF"
	Local cAliasRSG	:= "RSG"
	Local cAliasRSH	:= "RSH"
	Local cAliasRSI	:= "RSI"

	Local oTotales
	Local oImpuestos

	Private cMarca		:= '6j' //hace uso para el markbrowse de seleccion de facturas para las extracciones por pedimento

	Private aRefImpos	:= MaFisRelImp('MT100',{"SC7"})
	Private aRefImpRSF	:= MaFisRelImp('MT100',{"RSF"})

	Private oDlg
	Private oFoldMT447
	Private oEnchRSC	//Registro (datos grales. del pedimento)
	Private oEnchRSO	//Transportista

	Private oGetIncrem	//Incrementables
	Private oGetImpPed	//Impuestos por pedmiento
	Private oGetFacts	//encabezado de factura
	Private oGetItemF	// items por factura

	Private oGetCosto	//Costos

	Private oGetTot1	//Pie de pagina.- Total pedimentos y total de gastos extranjeros
	Private oGetTot2	//Pie de Pagina.- Total de gastos nacionales
	Private oGetTot3	//Total de impuestos

	Private oLeyen
	Private oSeriItem
	Private oFactItem
	Private oPrvItem
	Private oTdaItem
	Private oNomProv
	Private cLeyen		:= ''
	Private cFactItem
	Private cSeriItem
	Private cPrvItem
	Private cTdaItem
	Private cNomPItem

	Private aSvAtela	:= {{},{},{}}
	Private aSvAGets	:= {{},{},{}}
	Private aTela		:= {}
	Private aGets		:= {}

	Private aColsIt		:= If(nOpc == 3,{""},{})
	Private aAlterRSE	:= {}
	Private aAlterRSF	:= {}
	Private nOrigem		:= 0

	Private bFolderRefresh		:= {|| MT447Refresh() }
	Private bRefresh			:= {|| (Eval(bFolderRefresh)) }
	Private bGDRefresh  	  	:= {|| (oGetFacts:oBrowse:Refresh()),(oGetItemF:oBrowse:Refresh()) }
	Private bDatosImportacion 	:= {|| MT447DATIMPOR(nopc)  }

	Private aColsIm2		:= {} //Control del aCols de items de encabezado de impuestos de importacion
	private aResIm2			:= {} //Control del aCols de items de encabezado de impuestos de importacion
	Private lUsoRSG			:= .F.
	Private lUsoFAC			:= .F.

	Private lEditaItem		:= .T.
	Private lP_Activa		:= .F. //Si se activo o no la pestaña de encabezados e factura
	Private aGastos			:= {} //Contiene los gastos prorrateados por cada factura de gastos

	Private aCols			:= {}
	Private aHeader			:= {}
	Private cCodFracc		:= ''
	Private _nPosNatF		:= 0
	Private oTmp			:= Nil

	// Varibles para sustituir los objetos en todo el uso del fuente. Causa:Automatizacion

	Private aCoGetIncrem:={}	//aCols de Incrementables
	Private aCoGetImpPed:={}	//aCols de Impuestos por pedmiento
	Private aCoGetFacts	:={}	//aCols de encabezado de factura
	Private aCoGetItemF	:={}	// aCols de items por factura
	Private aCoGetCosto	:={}	//aCols de Costos
	Private aCoGetTot1	:={}	//aCols de Pie de pagina.- Total pedimentos y total de gastos extranjeros
	Private aCoGetTot2	:={}	//aCols de Pie de Pagina.- Total de gastos nacionales
	Private aCoGetTot3	:={}	//aCols de Total de impuestos

	Private aHoGetIncrem:={}	//aHeader de Incrementables
	Private aHoGetImpPed:={}	//aHeader de Impuestos por pedmiento
	Private aHoGetFacts	:={}	//aHeader de encabezado de factura
	Private aHoGetItemF	:={}	// aHeader de items por factura
	Private aHoGetCosto	:={}	//aHeader de Costos
	Private aHoGetTot1	:={}	//aHeader de Pie de pagina.- Total pedimentos y total de gastos extranjeros
	Private aHoGetTot2	:={}	//aHeader de Pie de Pagina.- Total de gastos nacionales
	Private aHoGetTot3	:={}	//aHeader de Total de impuestos

	Private nNoGetIncrem:=0		//Posicion del renglon de Incrementables
	Private nNoGetImpPed:=0		//Posicion del renglon de Impuestos por pedmiento
	Private nNoGetFacts	:=0		//Posicion del renglon de encabezado de factura
	Private nNoGetItemF	:=0		//Posicion del renglon de items por factura
	Private nNoGetCosto	:=0		//Posicion del renglon de Costos
	Private nNoGetTot1	:=0		//Posicion del renglon de Pie de pagina.- Total pedimentos y total de gastos extranjeros
	Private nNoGetTot2	:=0		//Posicion del renglon de Pie de Pagina.- Total de gastos nacionales
	Private nNoGetTot3	:=0		//Posicion del renglon de Total de impuestos

	Private nPoGetIncrem:=0		//Posicion del renglon de Incrementables
	Private nPoGetImpPed:=0		//Posicion del renglon de Impuestos por pedmiento
	Private nPoGetFacts	:=0		//Posicion del renglon de encabezado de factura
	Private nPoGetItemF	:=0		//Posicion del renglon de items por factura
	Private nPoGetCosto	:=0		//Posicion del renglon de Costos
	Private nPoGetTot1	:=0		//Posicion del renglon de Pie de pagina.- Total pedimentos y total de gastos extranjeros
	Private nPoGetTot2	:=0		//Posicion del renglon de Pie de Pagina.- Total de gastos nacionales
	Private nPoGetTot3	:=0		//Posicion del renglon de Total de impuestos

	Private	aCoGetIm1 :={}	 //acols getdados de encabezado de impuestos
	Private	aCoGetIm2 :={}	// acols getdados de items de impuestos

	Private	aHoGetIm1:={} //aheader del getdados de encabezado de impuestos
	Private	aHoGetIm2:={} //aheader del getdados de items de impuestos

	Private	nNoGetIm1:=0 //Nat del getdados de encabezado de impuestos
	Private	nNoGetIm2:=0 //Nat del getdados de items de impuestos
	Private	nPoGetIm1:=0 //Colpos del getdados de encabezado de impuestos
	Private	nPoGetIm2:=0 //Colpos del getdados de items de impuestos
	//--Finaliza declaracion de varibles para sustituir los objetos en todo el uso del fuente. Causa:Automatizacion------

	LMT447Ext := .F.

	DBSelectArea("RSA")
	DBSelectArea("RSB")

	If NOPC > 3 //No es Visualizar y no es incluir
		If !FreeForUse("RSC",xFilial("RSC")+RSC->RSC_NUMPED)   //Verifica que no este siendo usado por otro usuario
			Return
		EndIf
	EndIf

	If nopc == 4 .Or. nopc == 5 //Modificar o Borrar
		nP_PORIVA := RSC->RSC_IVA
		If !Empty(RSC->RSC_STATUS)
			Alert(STR0024)//"Aviso","Este Pedimento tiene Facturas Generadas y no permite modificaciones, ni puede ser eliminado."
			Return
		EndIf
		If AllTrim(RSC->RSC_CVEPED) $ cLisExt
			LMT447EXT	:= .T.
			LMT447Dep	:= .F.
			LMT447Rec	:= .F.
		Else
			If AllTrim(RSC->RSC_CVEPED) $ cLisDep
				LMT447Dep	:= .T.
				LMT447EXT	:= .F.
				LMT447Rec	:= .F.
			Else
				If AllTrim(RSC->RSC_CVEPED) $ cLisRec
					LMT447Rec	:= .T.
					LMT447EXT	:= .F.
					LMT447Dep	:= .F.
				EndIf
			EndIf
		EndIf
	EndIf

	cNumPed := RSC->RSC_NUMPED
	RSO->(DBSetOrder(1)) //RSC_FILIAL+RSC_PEDORI
	RSO->(DBSeek(xFilial("RSO")+cNumPed))

	If nOpc == 3 .Or. nopc == 4
		nOpcGet := 7
		RSA->(DBSetOrder(3))//RSA_FILIAL+RSA_USOFRA
		If RSA->(DBSeek(xFilial("RSA")+"1"))
			cCodFracc :=RSA->RSA_CODIGO
		Else
			Help( " ", 1, STR0025,,STR0028, 1, 0 ) //"Help","El Código de Impuesto para Fracciones Arancelarias, no existe verifique la tabla de Impuestos de Importacion (RSB)."
		EndIf
	EndIf

	If NOPC == 5 .Or. nOpc == 4 //Si es Borrar o Modificar, verifica que no haya extracciones del pedimento seleccionado
		cTmpPed := RSC->RSC_NUMPED
		nReg := RSC->(Recno())
		RSC->(DBSetOrder(2)) //RSC_FILIAL+RSC_PEDORI
		If RSC->(DBSeek(xFilial("RSC")+cTmpPed))
			Help( " ", 1, STR0025,,STR0029, 1, 0 ) //"Help","Existen Extracciones o Rectificaciones Asociadas, deberá eliminarlas antes de modificar o borrar este Pedimento."
			Return
		EndIf
		RSC->(DBSetOrder(1))
		RSC->(DBGoTo(nReg))

		RSO->(DBSetOrder(1)) //RSC_FILIAL+RSC_PEDORI
		RSO->(DBSeek(xFilial("RSO")+cNumPed))

	EndIf

	DBSelectArea(cAliasRSC)
	DBSelectArea(cAliasRSO)
	DBSelectArea(cAliasRSK)
	DBSelectArea(cAliasRSE)
	DBSelectArea(cAliasRSF)
	DBSelectArea(cAliasRSG)
	DBSelectArea(cAliasRSH)
	DBSelectArea(cAliasRSI)
	DBSelectArea("RSM")
	DBSelectArea("RSN")

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Genera la Informacion en los Header y Acols para los GetDados y MSMGET³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	HeadAcols(cAliasRSC,@aCamRSC,@aAlterRSC,1) //Datos generales
	HeadAcols(cAliasRSO,@aCamRSO,@aAlterRSO,1) //Transportista

	HeadAcols(cAliasRSK,@aHeadRSK,@aColsRSK,2)  //Incrementables
	HeadAcols(cAliasRSD,@aHeadRSD,@aColsRSD,2)  //Impuestos por pedimento
	HeadAcols(cAliasRSE,@aHeadRSE,@aColsRSE,2,,@aAlterRSE)  //Facturas
	HeadAcols(cAliasRSF,@aHeadRSF,@aColsRSF,2,.T.,@aAlterRSF)  //Items por factura
	HeadAcols(cAliasRSI,@aHeadRSI,@aColsRSI,2)  //Costos por producto

	Tot1HeadAcols(@aHeadTot1,@aColsTot1)
	Tot2HeadAcols(@aHeadTot2,@aColsTot2)
	Tot3HeadAcols(@aHeadTot3,@aColsTot3)

	If !Inclui
		LlenaGetDados(cAliasRSK, aHeadRSK, @aColsRSK, "RSC->RSC_NUMPED", "RSC->RSC_FILIAL+RSC->RSC_NUMPED==RSK->RSK_FILIAL+RSK->RSK_NUMPED", 1)
		LlenaGetDados(cAliasRSD, aHeadRSD, @aColsRSD, "RSC->RSC_NUMPED", "RSC->RSC_FILIAL+RSC->RSC_NUMPED==RSD->RSD_FILIAL+RSD->RSD_NUMPED", 1)
		LlenaGetDados(cAliasRSE, aHeadRSE, @aColsRSE, "RSC->RSC_NUMPED", "RSC->RSC_FILIAL+RSC->RSC_NUMPED==RSE->RSE_FILIAL+RSE->RSE_NUMPED", 2)
		LlenaItems(aHeadRSF,@aColsRSF)

		LlenaCostos(cAliasRSI, aHeadRSI, @aColsRSI, "RSC->RSC_NUMPED","RSC->RSC_FILIAL+RSC->RSC_NUMPED==RSI->RSI_FILIAL+RSI->RSI_NUMPED", 1)
		LlenaTMP() //Coloca en tablas temporales la informacion de RSG y RSH
	Else   //Si Inclui
		aColsRSE[1][aScan(aHeadRSE, {|x| Trim(x[2]) == "RSE_ITEM"	})] := StrZero(1,Len(RSE->RSE_ITEM))
		aColsRSF[1][aScan(aHeadRSF, {|x| Trim(x[2]) == "RSF_ITEDOC"	})] := StrZero(1,Len(RSF->RSF_ITEDOC))
		aColsRSF[1][aScan(aHeadRSF, {|x| Trim(x[2]) == "RSF_ITEM" 	})] := StrZero(1,Len(RSF->RSF_ITEM))
	EndIf

	If LMT447Ext
		MT447PRODEXT(RSC->RSC_NUMPED,RSC->RSC_PEDORI) //CREA TABLA TEMPORAL CON LOS PRODUCTOS DE LA EXTRACCION AL PEDIMENTO
	EndIf

	aAdd(aButtons, {'RECALC'			, bCalcula						, STR0030				, STR0031})				//"Calculo de impuestos y costos","Calculo"
	aAdd(aButtons, {'SELECTALL'			, bSelProductos					, STR0032				, STR0033})				//"Seleccione los productos a extraer","Extraer Productos"
	aAdd(aButtons, {'SDUIMPORT'			, {|| If (!LMT447Rec,MT447OC2()	, MsgInfo(STR0034))}	, STR0035, STR0036})	//"Botón sin uso para Pedimentos de Rectificacion","Seleccione Items de ordenes de compra","Items por Orden de Compra"
	aAdd(aButtons, {'UPDINFORMATION'	, {|| MATA447A()}				, STR0037				, STR0038})				//"Visualiza resumen por secciones","Resumen del Pedimento"

	If !lAutoTeste
		oSize := FwDefSize():New( .T. ) // Com enchoicebar
		aSize := {oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4]}

		DEFINE FONT oFont	NAME "Arial" SIZE 0,-12 // BOLD
		DEFINE FONT oFont2	NAME "Arial" SIZE 0,-11  BOLD
		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[1],aSize[2] To aSize[3],aSize[4] of oMainWnd PIXEL

		oSize2 := FwDefSize():New(.T.,,,oDlg)
		oSize2:AddObject('DET',0,(aSize[3]-aSize[1])/3*2,.T.,.T.,.T.)
		oSize2:AddObject('TOT',0,(aSize[3]-aSize[1])/3,.T.,.T.,.T.)
		oSize2:lProp := .T.
		oSize2:Process()

		aAdd(aPosObj, {oSize2:GetDimension('DET', 'LININI')   ,oSize2:GetDimension('DET', 'COLINI'),oSize2:GetDimension('DET', 'LINEND')-15,oSize2:GetDimension('DET', 'COLEND')})
		aAdd(aPosObj, {oSize2:GetDimension('TOT', 'LININI')+15,oSize2:GetDimension('TOT', 'COLINI'),oSize2:GetDimension('TOT', 'LINEND')   ,oSize2:GetDimension('TOT', 'COLEND')})

		oFoldMT447 := TFolder():New( aPosObj[1,1],aPosObj[1,2], aFolder, {'','','','','','','',''}, oDlg,,,, .T., , aPosObj[1,4], aPosObj[1,3])

		//Datos generales del Pedimento RSC
		aTela	:= {}; aGets := {}
		RegToMemory(cAliasRSC, If(nOpc==3,.T.,.F.))

		oEnchRSC	:= MsMGet():New(cAliasRSC, nReg, nOpc, /*aCRA*/, /*cLetra*/,/*cTexto*/, aCamRSC,{0,0,aPosObj[1,3]-20,aPosObj[1,4]-6}, aAlterRSC,3, /*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oFoldMT447:aDialogs[1],.F.,.T.,.F., "aSvATela[1]",.F.,.F.)

		aSvATela[1]	:= aClone(aTela)
		aSvAGets[1]	:= aClone(aGets)

		//Datos del Transportista
		aTela	:= {}; aGets := {}

		RegToMemory(cAliasRSO, If(nOpc == 3,.T.,.F.))

		oEnchRSO	:= MsMGet():New(cAliasRSO, nReg, nOpc, /*aCRA*/, /*cLetra*/,/*cTexto*/, aCamRSO,{0,0,aPosObj[1,3]-20,aPosObj[1,4]-6}, aAlterRSO,3, /*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oFoldMT447:aDialogs[2],.F.,.T.,.F., "aSvATela[2]",.F.,.F.)

		aSvATela[2]	:= aClone(aTela)
		aSvAGets[2]	:= aClone(aGets)

		If LMT447Ext
			LlenaMgmGet("RSC",cNumPed,ACAMRSC,aAlterRSC)
			LlenaMgmGet("RSO",cNumPed,ACAMRSO,aAlterRSO)
		EndIf

		//Incrementables
		oGetIncrem := MsNewGetDados():New(0,0,aPosObj[1,3]-20,aPosObj[1,4]-6,nOpcGet,"MT447LOkRSK()" ,"MT447TOkRSK()" ,Nil,Nil, 0, 999,"AllwaysTrue" ,;
						"",Nil ,  oFoldMT447:aDialogs[3], aHeadRSK, aColsRSK)

		//Impuestos a Nivel Pedimento
		oGetImpPed := MsNewGetDados():New(0,0,aPosObj[1,3]-20,aPosObj[1,4]-6,nOpcGet,"MT447LOk5()" ,"MT447TOk5()" ,Nil,Nil, 0, 999,"AllwaysTrue" ,;
						"",Nil ,  oFoldMT447:aDialogs[4], aHeadRSD, aColsRSD)

		//Items de la factura
		@ 005, 020 SAY STR0039 SIZE 060,07 OF oFoldMT447:aDialogs[6] PIXEL	//"Factura : "
		@ 005, 105 SAY STR0040 SIZE 060,07 OF oFoldMT447:aDialogs[6] PIXEL	//"Serie : "
		@ 005, 195 SAY STR0041 SIZE 060,07 OF oFoldMT447:aDialogs[6] PIXEL	//"Proveedor : "
		@ 005, 265 SAY STR0042 SIZE 060,07 OF oFoldMT447:aDialogs[6] PIXEL	//"Tienda : "

		@ 006, 475 SAY STR0043 SIZE 150,07 OF oFoldMT447:aDialogs[6] PIXEL FONT oFont2 //" <F9> Datos de Importacion e Impuestos"
		@ 014, 020 SAY STR0044 SIZE 060,07 OF oFoldMT447:aDialogs[6] PIXEL  //"Observ. : "
		@ 015, 045 GET oLeyen Var cLeyen	when .F. OF oFoldMT447:aDialogs[6]	SIZE  200,007  PIXEL FONT oFont2

		@ 003, 045 GET oFactItem	VAR cFactItem	WHEN .F. OF oFoldMT447:aDialogs[6]	SIZE 050,06 PIXEL
		@ 003, 125 GET oSeriItem	VAR cSeriItem	WHEN .F. OF oFoldMT447:aDialogs[6]	SIZE 020,06 PIXEL
		@ 003, 225 GET oPrvItem		VAR cPrvItem	WHEN .F. OF oFoldMT447:aDialogs[6]	SIZE 030,06 PIXEL
		@ 003, 290 GET oTdaItem		VAR cTdaItem	WHEN .F. OF oFoldMT447:aDialogs[6]	SIZE 020,06 PIXEL
		@ 003, 312 GET oNomProv		VAR cNomPItem	WHEN .F. OF oFoldMT447:aDialogs[6]	SIZE 100,06 PIXEL

		oGetItemF := MsNewGetDados():New(28,0,aPosObj[1,3]-20,aPosObj[1,4]-6,nOpcGet,"MT447LOk2" ,"MT447TOk2" ,"+RSF_ITEM",Nil, 4, 999,"AllwaysTrue" ,;
						"AllwaysTrue","MT447DEL2()" ,  oFoldMT447:aDialogs[6], aHeadRSF, aColsRSF)

		oGetFacts := MsNewGetDados():New(0,0,aPosObj[1,3]-20,aPosObj[1,4]-6,nOpcGet,"MT447LOk1" ,"MT447TOk1" ,"+RSE_ITEM",Nil, 0, 999, "AllwaysTrue" ,;
						"AllwaysTrue","MT447Del()" ,  oFoldMT447:aDialogs[5], aHeadRSE, aColsRSE)

		oGetFacts:oBrowse:bChange := {|| MT447IniFis() }

		oFoldMT447:bSetOption := {|nAtu| MT447Folder(nAtu,oFoldMT447:nOption,oFoldMT447,{oEnchRSC,oEnchRSO,oGetIncrem,oGetImpPed,oGetFacts,oGetItemF}) }
		oFoldMT447:BWHEN := {|| MT447WhenFol(oFoldMT447:nOption) }

		//Costos de Mercancia
		oGetCosto := MsNewGetDados():New(0,0,aPosObj[1,3]-20,aPosObj[1,4]-6,0,"AllwaysTrue" ,"AllwaysTrue" ,Nil,Nil, 0, 999,"AllwaysTrue" ,;
						"",Nil ,  oFoldMT447:aDialogs[7], aHeadRSI, aColsRSI)

		//Pie de Pagina
		oSize3 := FwDefSize():New(.T.,,,oDlg)
		oSize3:AddObject('PED',Int((aSize[4]-aSize[2])*.5),0,.T.,.T.)
		oSize3:AddObject('NAL',Int((aSize[4]-aSize[2])*.2),0,.T.,.T.)
		oSize3:AddObject('IMP',Int((aSize[4]-aSize[2])*.3),0,.T.,.T.)
		oSize3:lLateral := .T.
		oSize3:Process()

		aAdd(aPosObj, {aPosObj[2,1],oSize3:GetDimension('PED', 'COLINI'),aPosObj[2,3],oSize3:GetDimension('PED', 'COLEND')})
		aAdd(aPosObj, {aPosObj[2,1],oSize3:GetDimension('NAL', 'COLINI'),aPosObj[2,3],oSize3:GetDimension('NAL', 'COLEND')})
		aAdd(aPosObj, {aPosObj[2,1],oSize3:GetDimension('IMP', 'COLINI'),aPosObj[2,3],oSize3:GetDimension('IMP', 'COLEND')})

		oGpoTot1 := tGroup():New(aPosObj[3,1],aPosObj[3,2],aPosObj[3,3],aPosObj[3,4],'Total Pedimento',oDlg,,,.T.)
		oGpoTot2 := tGroup():New(aPosObj[4,1],aPosObj[4,2],aPosObj[4,3],aPosObj[4,4],'Gastos Nacionales',oDlg,,,.T.)
		oImpuestos := tGroup():New(aPosObj[5,1],aPosObj[5,2],aPosObj[5,3],aPosObj[5,4],'Impuestos',oDlg,,,.T.)

		oGetTot1 := MsNewGetDados():New(aPosObj[3,1]+8,aPosObj[3,2]+3,aPosObj[3,3]-3,aPosObj[3,4]-3,0,"AllwaysTrue" ,"AllwaysTrue" ,Nil,Nil, 0, 999,"AllwaysTrue" ,;
						"",Nil ,  oGpoTot1, aHeadTot1, aColsTot1)

		oGetTot2 := MsNewGetDados():New(aPosObj[4,1]+8,aPosObj[4,2]+3,aPosObj[4,3]-3,aPosObj[4,4]-3,0,"AllwaysTrue" ,"AllwaysTrue" ,Nil,Nil, 0, 999,"AllwaysTrue" ,;
						"",Nil ,  oGpoTot2, aHeadTot2, aColsTot2)

		oGetTot3 := MsNewGetDados():New(aPosObj[5,1]+8,aPosObj[5,2]+3,aPosObj[5,3]-3,aPosObj[5,4]-3,0,"AllwaysTrue" ,"AllwaysTrue" ,Nil,Nil, 0, 999,"AllwaysTrue" ,;
						"",Nil ,  oImpuestos, aHeadTot3, aColsTot3)

		MT447TotPie(.F.)
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bGraba,bCancela,,aButtons)
	Else

		aHoGetCosto:=aclone(aHeadRSI)//Inicia header de la pestaña de Costos

	    //Inicializa los totales del pie de pagina, ya que son de tamaño fijo.

	    Tot1HeadAcols(@aHoGetTot1,@aCoGetTot1)
		Tot2HeadAcols(@aHoGetTot2,@aCoGetTot2)
		Tot3HeadAcols(@aHoGetTot3,@aCoGetTot3)

    	//Inicaliza los objetos  de los getdados de fracciones arancelaria e impuestos (accion de la tecla F9)

		aHeadRSG	:= {};aColsRSG	:= {};aHeadRSH	:= {};aColsRSH	:= {}
		HeadAcols("RSG",@aHeadRSG,@aColsRSG,2)
		HeadAcols("RSH",@aHeadRSH,@aColsRSH,2)

		lb		:= .T. //Indicador de qu no hubo errores en la creacion de MsGetDAuto

		If EnchAuto("RSC",aAutoCab,Nil,nOpc) //Datos del generales del pedimento
			If Len(aAutCabTra) > 0
				EnchAuto("RSO",aAutCabTra,Nil,nOpc) //Datos del transportista
			EndIf

			//Inicializan las variables de memoria las pantalla del enchoice; a este nivel para que queden como variables privadas
			For nx:=1 To Len(ACAMRSC)
				If (np := aScan(aAutoCab,{|x| Trim(x[1]) == AllTrim(ACAMRSC[NX]) }))  <> 0
					&("M->"+ACAMRSC[NX]):=aAutoCab[np,2]
				EndIf
			Next
			For nx:=1 To Len(ACAMRSO)
				If (np := aScan(aAutCabTra,{|x| Trim(x[1]) == AllTrim(ACAMRSO[NX]) }))  <> 0
					&("M->"+ACAMRSO[NX]):=aAutCabTra[np,2]
				EndIf
			Next

			If Len(aAutGetIn) > 0 //Incrementables
				aHeader:= aClone(aHeadRSK)
				MT447PREPACOLS(aAutGetIN,aColsRSK)
				aCoGetIncrem := aClone(aCols)
				aHoGetIncrem := aClone(aHeader)
				lB:= MsGetDAuto(aAutGetIN,"MT447LOkRSK()","MT447TOkRSK()",/*aAutoCab*/,arotina[nopc,4],.T.)
			EndIf
			If Len(aAutGetIP) > 0 .And. lb //Impuestos a nivel pedimento
				aHeader := aClone(aHeadRSD)
				MT447PREPACOLS(aAutGetIP,aColsRSD)
				aCoGetImpPed := aClone(aCols)
				aHoGetImpPed := aClone(aHeader)
				lB:= MsGetDAuto(aAutGetIP,"MT447LOk5()","MT447TOk5()",/*aAutoCab*/,arotina[nopc,4],.T.)
			EndIf
			//Encabezado de Facturas
			If Len(aAutGetEF) > 0 .And. lb

				aHeader := aClone(aHeadRSE)
				MT447PREPACOLS(aAutGetEF,aColsRSE)
				aCoGetFacts := aClone(aCols)
				aHoGetFacts := aClone(aHeader)


				aHoGetItemF := aClone(aHeadRSF)

				nPosItf:=GdFieldPos("RSE_ITEM",aHoGetFacts)

				lB := MsGetDAuto(aAutGetEF,"MT447LOk1" ,"MT447TOk1" ,/*aAutoCab*/,arotina[nopc,4],.T.)

				If Len(aAutGetIF) > 0  .And. lb //Items de cada factura

					aColsIt	:= {}
					aHeader	:= aClone(aHeadRSF)
					nPosItD	:= aScan(aAutGetIF[1],{|x| Trim(x[1])=="RSF_ITEDOC"})
					ny		:= 1

					Do While ny <= Len(aAutGetIF)
						aAux	:= {}
						cTmpItD	:= aAutGetIF[ny,nPosItD,2]
						Do While ny <= Len(aAutGetIF) .And. cTmpItD == aAutGetIF[ny,nPosItD,2]
							aAdd(aAux,{})
							aAux[Len(aAux)]:=aAutGetIF[ny]
							ny++
						EndDo
						//Items de cada factura
						nPFac			:= aScan(aCoGetFacts,{|x| Trim(x[nPosItf]) == cTmpItD})
						nNoGetFacts		:= nPFac
						_nPosNatF		:= nPFac

						aHeader			:= aClone(aHeadRSF)
						MT447PREPACOLS(aAux,aColsRSF)
					    aCoGetItemF := aClone(aCols)
						aHoGetItemF := aClone(aHeader)

						If !MaFisFound("NF")
							nPosFor    := GdFieldPos("RSE_PROV",	aHoGetFacts)
							nPosLoja   := GdFieldPos("RSE_TDA",	aHoGetFacts)
							MaFisIni(aCoGetFacts[nNoGetFacts][nPosFor],aCoGetFacts[nNoGetFacts][nPosLoja],"F","N",Nil,MaFisRelImp('MT120',{"SF1","SD1"}),,.T.)
						EndIf

						lB := MsGetDAuto(aAux,"MT447LOk2" ,"MT447TOk2" ,/*aAutoCab*/,arotina[nopc,4],.T.)

						aAdd(aColsIt,{""})
						aColsIt[Len(aColsIt)] := aClone(aCoGetItemF)
						nNoGetFacts	:= nPFac
						MT447IniFis()
						MT447Refresh()
						nNoGetFacts		:= nPFac
						_nPosNatF		:= nPFac
						nPosTip			:= aScan(aHoGetFacts,{|x| Trim(x[2])=="RSE_TIPO"})
						lMerca			:= If (aCoGetFacts[nPFac,nPosTip] == '1',.T.,.F.)

						//Impuestos de cada factura
						If Len(aAutGetIm1)>0     .And. lMerca .And. lb

							nPos2Fac	:= aScan(aAutGetIm1[1],{|x| Trim(x[1])=="RSG_FACT"})
							nPos2Ser	:= aScan(aAutGetIm1[1],{|x| Trim(x[1])=="RSG_SERIE"})
							nPos2Prov	:= aScan(aAutGetIm1[1],{|x| Trim(x[1])=="RSG_PROV"})
							nPos2Tda	:= aScan(aAutGetIm1[1],{|x| Trim(x[1])=="RSG_TDA"})
							nPos2ite	:= aScan(aAutGetIm1[1],{|x| Trim(x[1])=="RSG_ITEM"})

							nPosFac		:= aScan(aHoGetFacts,{|x| Trim(x[2])=="RSE_FACT"})
							nPosSer		:= aScan(aHoGetFacts,{|x| Trim(x[2])=="RSE_SERIE"})
							nPosProv	:= aScan(aHoGetFacts,{|x| Trim(x[2])=="RSE_PROV"})
							nPosTda		:= aScan(aHoGetFacts,{|x| Trim(x[2])=="RSE_TDA"})
							nPosiTF		:= aScan(aHoGetFacts,{|x| Trim(x[2])=="RSE_ITEM"})

							nl := 1

							aColsIm2		:= {}

							cFact 			:= aCoGetFacts[nPFac,nPosfac]
							cSerie			:= aCoGetFacts[nPFac,nPosSer]
							cProv			:= aCoGetFacts[nPFac,nPosProv]
							cTda			:= aCoGetFacts[nPFac,nPosTda]

							nNoGetFacts	:= nPFac

							For nl := 1 To Len(aAutGetIm1)
								If aAutGetIm1[nl,nPos2Fac,2]+aAutGetIm1[nl,nPos2Ser,2]+aAutGetIm1[nl,nPos2Prov,2]+aAutGetIm1[nl,nPos2tda,2] == cFact+cSerie+cProv+cTda
									Exit
								EndIf
							Next
							If nl <= Len(aAutGetIm1) //Considera que este arreglo esta en el mismo orden de los encabezados de las factura (RSE)
								aAux	:= {}
								nYtmp	:= nl
								Do While nl <= Len(aAutGetIm1) .And. cFact+cSerie+cProv+cTda==aAutGetIm1[nl,nPos2Fac,2]+aAutGetIm1[nl,nPos2Ser,2]+aAutGetIm1[nl,nPos2Prov,2]+aAutGetIm1[nl,nPos2Tda,2]
									aAdd(aAux,{})
									aAux[Len(aAux)]:=aAutGetIm1[nl]
									nl++
								EndDo



								aHoGetIm2 := aClone(aHeadRSH) //seran usado al detonar el trigguer de aColsRSG
								aCoGetIm2 := aClone(aColsRSH)


								aHeader	:= aClone(aHeadRSG)
								MT447PREPACOLS(aAux,aColsRSG)
								aCoGetIm1 := aClone(aCols)
								aHoGetIm1 := aClone(aHeader)

								lB := MsGetDAuto(aAux,"MT447LOk3()" ,"MT447TOk3()" ,/**/,arotina[nopc,4],.T.) //Fracciones arancelarias

			  					//Si hay impuestos adicionales a la fraccion arancelaria
								If Len(aAutGetIm2) > 0   .And. lb
									nPos3Fac	:= aScan(aAutGetIm2[1],{|x| Trim(x[1])=="RSH_FACT"})
									nPos3Ser	:= aScan(aAutGetIm2[1],{|x| Trim(x[1])=="RSH_SERIE"})
									nPos3Prov	:= aScan(aAutGetIm2[1],{|x| Trim(x[1])=="RSH_PROV"})
									nPos3Tda	:= aScan(aAutGetIm2[1],{|x| Trim(x[1])=="RSH_TDA"})
									nPos3ite	:= aScan(aAutGetIm2[1],{|x| Trim(x[1])=="RSH_ITEM"})
									For nz := 1 To Len(aCoGetIm1)  //Verifica si hay un impuesto mas para ese tiem de esa fraccion
										If (nz1 := aScan(aAutGetIm2,{|x| x[nPos3Fac,2]+x[nPos3ser,2]+x[nPos3prov,2]+x[nPos3tda,2]+x[nPos3ite,2]==cFact+cSerie+cProv+cTda+aAutGetIm1[nz,npos2ite,2]}))>0
											aAux := {}
											Do While nz1 <= Len(aAutGetIm2) .And. cFact+cSerie+cProv+cTda+aAutGetIm1[nYtmp,nPos2iTE,2]==aAutGetIm2[nz1,nPos3Fac,2]+aAutGetIm2[nz1,nPos3Ser,2]+aAutGetIm2[nz1,nPos3Prov,2]+aAutGetIm2[nz1,nPos3Tda,2]+aAutGetIm2[nz1,nPos3ite,2]
												aAdd(aAux,{})
												aAux[Len(aAux)]:=aAutGetIm2[nz1]
												nz1++
											EndDo
											nNoGetIm1	:= nz

											aHeader		:= aClone(aHeadRSH)
											MT447PREPACOLS(aAux,aColsRSH)
											ResAcol		:= aClone(aCoGetIm2)
											aCoGetIm2	:= aClone(aCols) //Lleva el impuestos generado por la fraccion y el nuevo impuesto al item
											aHoGetIm2	:= aClone(aHeader)

											lb			:= MsGetDAuto(aAux,"MT447LOk4()" ,"MT447TOk4()" ,/*aAutoCab*/,arotina[nopc,4],.T.) //impuestos adicionales por item

					  						//Acomodo los items de los impuestos en el aCols
											aCoGetIm2	:= {}

											For nz2 := 1 To Len(ResAcol)
												aAdd(aCoGetIm2,{})
												aCoGetIm2[Len(aCoGetIm2)] := ResAcol[nz2]
											Next
											aColsIm2[nz] := {}
											aColsIm2[nz] := aCoGetIm2
										EndIf
									Next
								EndIf
							EndIf
							ArrImpuesto("P",cFact,cSerie,cProv,cTda)
						EndIf
					EndDo
				EndIf
				For NX := 1 To Len(aCoGetFacts)
					nNoGetFacts := NX
					MT447IniFis() //Inicial valores del aNFini utitlizado en la funcion MAFISRET
					MT447Refresh()
				Next
			EndIf //Del encabezado de facturas
		  	If lb
				MT447Graba(nOpc,aAlterRSC,aAlterRSO)
		  	EndIf
		EndIf //De datos generales del pedimento
	EndIf //Si fue rutina automatica

	If lUsoRSG
		TMPRSG->(DbCloseArea())
		TMPRSH->(DbCloseArea())
	EndIf
	If lUsoFac
		TRB->(DbCloseArea())
	EndIf

	RestArea(aArea)
	RestKeys( aSvKeys , .T. ) // Restaura teclas de atajo

	/*Variable utilizada para Métrica para sacar el promedio de uso del botón Resumen del Pedimento*/
	If Type("nUsoBtnRes") <> "U"
		nUsoBtnRes := 0
	EndIf

	If oTmp <> Nil
		oTmp:Delete()
		FreeObj(oTmp)
		oTmp:= Nil
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447PREPACOLS³Autor³Gpe. Santacruz       ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Prepara ACOLS para MsGetDAuto  Rutina automatica             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447PREPACOLS(aExp1,aExp2 )                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aExp1.- Arreglo con los datos a subir                        ³±±
±±³          ³aExp2.- Arreglo con el aCols inicializado                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MsGetDAuto					                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MT447PREPACOLS(aItens,aColsCpy)

	Local nx	:= 0
	Local ny	:= 0
	Local nz	:= 0
	aCols		:= {}

	For nx := 1 To Len(aItens)
		aAdd(aCols,{})
		aCols[Len(aCols)] := aClone(aColsCpy[1])
		For ny := 1 To Len(aHeader)
			If (nz := aScan(aItens[nx],{|x| Trim(x[1]) == AllTrim(aHeader[ny,2])})) > 0
				aCols[Len(aCols),ny] := aItens[nx,nz,2]
			EndIf
		Next
	Next

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³HeadAcols  ³Autor ³     Gpe. Santacruz    ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Genera la informacion necesaria en los Header y aCols        ³±±
±±³          ³de la pantalla principal de registro.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³HeadAcols(cExp1,@aExp1,@aExp2,nExp1,lExp1,aExp3)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1.- Alias                                                ³±±
±±³          ³aExp1.- Ahaader                                              ³±±
±±³          ³aExp2.- Acols                                                ³±±
±±³          ³nExp1.- 1 si formara un MDMGET diferente, es getdados        ³±±
±±³          ³lExp1.- Si inicililiza campos para numero de item            ³±±
±±³          ³aExp3.-Campos a alterar                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Ninguno                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function HeadAcols(cAli,aH,aC,nTp,lItems,aAlt)

	Local nUsado	:= 0
	Local nx		:= 0

	Default lITems	:= .F.
	Default aAlt	:= {}

	DbSelectArea("SX3")
	DbSetOrder(1)

	If nTp == 1 //Informacion para MSMGET
		SX3->(DbSeek(cAli))
		While !Eof() .And. SX3->X3_ARQUIVO == cAli
			If !(SX3->X3_CAMPO $ cAli+"_FILIAL") .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)
				aAdd(aH,SX3->X3_CAMPO)
			EndIf
			SX3->(DbSkip())
		EndDo
		aC := aClone(aH)
	Else //Informacion para GETDADOS
		SX3->(dbSeek(cAli))
		Do while !Eof() .And. X3_ARQUIVO == cAli
			If X3USO(X3_USADO).And.cNivel >= x3_nivel
				nUsado ++

				aAdd(aH,{ Trim( X3Titulo()), X3_CAMPO, x3_picture,x3_tamanho,;
					x3_decimal,SX3->X3_VALID,X3_USADO, x3_tipo, x3_f3, x3_context,X3Cbox(),SX3->X3_RELACAO } )

				If SX3->X3_CONTEXT <> "V"
					aAdd(aAlt, Trim(SX3->X3_CAMPO) )
				EndIf
			EndIf
			SX3->(DBSkip())
		EndDo

		aC:={}
		aAdd(aC,Array(nUsado+1))
		For nX := 1 To nUsado
			aC[Len(aC)][nX] := CriaVar(cAli+"->"+aH[nX,2],.T.)
		Next nX
		aC[Len(aC)][nUsado+1] := .F.
	EndIf

	If lItems
		aC[1][aScan(aH,{|x| Trim(x[2])=="RSF_ITEDOC"})]:= StrZero(1,Len(RSF->RSF_ITEDOC))
		aC[1][aScan(aH,{|x| Trim(x[2])=="RSF_ITEM" })]:= StrZero(1,Len(RSF->RSF_ITEM))
		aColsIt :={""}
		aColsIt[1] := aClone(aC)
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tot1HeadAcols³Autor ³   Gpe. Santacruz    ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Genera la informacion necesaria en los Header y aCols        ³±±
±±³          ³de la pantalla del total del gastos y valores de aduana.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³Tot1HeadAcols(@aExp1,@aExp2)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aExp1.- aHaader                                              ³±±
±±³          ³aExp2.- aCols                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tot1HeadAcols(aH,aC)

	Local nUsado    := 0
	Local NX        := 0
	Local aEtiquetas:= {STR0045,STR0046,STR0047,STR0048} //"Fletes","Seguros","Embalajes","Otros"
	Local aEtiTot   := {STR0049,STR0050,STR0051,STR0052} //"Valor Dolares","Valor en Aduana","Precio Pagado/Val. Comercial","Incrementables"
	DbSelectArea("SX3")
	SX3->(DBSetOrder(2))
	If SX3->(DBSeek("RSD_CODIMP"))
		aAdd(aH,{ "        ", SX3->X3_CAMPO, SX3->X3_PICTURE, 15, ;
			X3_DECIMAL, SX3->X3_VALID, X3_USADO, X3_TIPO, X3_F3, SX3->X3_CONTEXT, X3Cbox(), SX3->X3_RELACAO } )
	EndIf
	If SX3->(DBSeek("RSJ_OTROE"))
		aAdd(aH,{ " ", X3_CAMPO, X3_PICTURE, X3_TAMANHO, ;
			X3_DECIMAL, SX3->X3_VALID,X3_USADO, X3_TIPO, X3_F3, X3_CONTEXT, X3Cbox(), SX3->X3_RELACAO } )
	EndIf
	SX3->(DBSetOrder(2))
	If SX3->(DBSeek("RSD_CODIMP"))
		aAdd(aH,{ "Gastos", X3_CAMPO, X3_PICTURE, 8, ;
			X3_DECIMAL, SX3->X3_VALID, X3_USADO, X3_TIPO, X3_F3, X3_CONTEXT, X3Cbox(), SX3->X3_RELACAO } )
	EndIf
	If SX3->(DBSeek("RSJ_OTROE"))
		aAdd(aH,{ "Importes", X3_CAMPO, X3_PICTURE, X3_TAMANHO, ;
			X3_DECIMAL, SX3->X3_VALID, X3_USADO, X3_TIPO, X3_F3, X3_CONTEXT, X3Cbox(), SX3->X3_RELACAO } )
	EndIf

	nUsado := Len(ah)

	aC := {}
	For NX := 1 To Len(aEtiquetas)
		aAdd(aC,Array(nUsado + 1))
		aC[Len(aC)][1] := aEtiTot[nx]
		aC[Len(aC)][2] := 0
		aC[Len(aC)][3] := aEtiquetas[nx]
		aC[Len(aC)][4] := 0
		aC[Len(aC)][nUsado + 1] := .F.
	Next

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tot2HeadAcols³Autor ³    Gpe. Santacruz   ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Genera la informacion necesaria en los Header y aCols        ³±±
±±³          ³de la ventana del Total de Gastos nacioales                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³Tot2HeadAcols(@aExp1,@aExp2)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aExp1.- aHaader                                              ³±±
±±³          ³aExp2.- aCols                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tot2HeadAcols(aH,aC)

	Local nUsado 		:= 0
	Local NX     		:= 0
	Local aEtiquetas	:= {STR0045,STR0046,STR0053,STR0048}  //"Fletes","Seguros","Almacenajes","Otros"

	SX3->(DBSetOrder(2))
	If SX3->(dbSeek("RSD_CODIMP"))
		aAdd(aH,{ "Tipo", X3_CAMPO, X3_PICTURE, 15, ;
			X3_DECIMAL, SX3->X3_VALID, X3_USADO, X3_TIPO, X3_F3, X3_CONTEXT, X3Cbox(), SX3->X3_RELACAO } )
	EndIf
	If SX3->(dbSeek("RSJ_OTRON"))
		aAdd(aH,{ "Importe", X3_CAMPO, X3_PICTURE, X3_TAMANHO, ;
			X3_DECIMAL, SX3->X3_VALID, X3_USADO, X3_TIPO, X3_F3, X3_CONTEXT, X3Cbox(), SX3->X3_RELACAO } )
	EndIf

	nUsado	:= Len(ah)
	aC		:= {}

	For NX:=1 To Len(aEtiquetas)
		aAdd(aC,Array(nUsado+1))
		aC[Len(aC)][1] :=aEtiquetas[nx]
		aC[Len(aC)][2] := 0
		aC[Len(aC)][nUsado+1] := .F.
	Next

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tot3HeadAcols³Autor³    Gpe. Santacruz    ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Genera la informacion necesaria en los Header y aCols        ³±±
±±³          ³de la pantalla del total del Impuestos.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³Tot3HeadAcols(@aExp1,@aExp2)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±³          ³aExp1.- Ahaader                                              ³±±
±±³          ³aExp2.- Acols                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tot3HeadAcols(aH,aC)

	Local nUsado := 0

	SX3->(DBSetOrder(2))
	If SX3->(DBSeek("RSL_CODIMP"))
		aAdd(aH,{ "Codigo", X3_CAMPO, X3_PICTURE, X3_TAMANHO,;
			X3_DECIMAL, SX3->X3_VALID, X3_USADO, X3_TIPO, X3_F3, X3_CONTEXT, X3Cbox(), SX3->X3_RELACAO } )
	EndIf
	If SX3->(DBSeek("RSL_DESC"))
		aAdd(aH,{ "Descripcion", X3_CAMPO, X3_PICTURE, X3_TAMANHO,;
			X3_DECIMAL, SX3->X3_VALID, X3_USADO, X3_TIPO, X3_F3, X3_CONTEXT, X3Cbox(), SX3->X3_RELACAO } )
	EndIf
	If SX3->(DBSeek("RSL_IMPORT"))
		aAdd(aH,{ "Importe", X3_CAMPO, X3_PICTURE, X3_TAMANHO,;
			X3_DECIMAL, SX3->X3_VALID, X3_USADO, X3_TIPO, X3_F3, X3_CONTEXT, X3Cbox(), SX3->X3_RELACAO } )
	EndIf

	nUsado	:= Len(ah)
	aC		:= {}
	aAdd(aC,Array(nUsado+1))
	aC[Len(aC)][1] := SPACE(TAMSX3("RSL_CODIMP")[1])
	aC[Len(aC)][2] := SPACE(TAMSX3("RSL_DESC")[1])
	aC[Len(aC)][3] := 0
	aC[Len(aC)][nUsado+1] := .F.

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447Graba ³Autor ³     Gpe. Santacruz    ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Ejecuta esta rutina al dar OK en la pantalla principal       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447Graba(nExp1,aExp1,aExp2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExp1.- Numero de opcion seleccionada nOpc                   ³±±
±±³          ³aExp1.- Campos que permiten alteraciones de la tabla RSC     ³±±
±±³          ³aExp2.- Campos que permiten alteraciones de la tabla RSO     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MT447Graba(nOpc,aAltRSC,aAltRSO)

	Local lRet			:= .T.
	Local nx			:= 0
	Local lGraba		:= .F.
	Local cSubRutina	:= ""
	Local cTxtAuto      := IIf(isBlind() .Or. (GetRemoteType() == 5), "_auto", "") //Variable que determina si es automatizado por Advpr o TIR

	If nOPC == 3 .Or. nOpc == 4  //Incluir /modificar
		If !obrigatorio(	aSvAGets[1],	aSvATela[1])  .Or. !obrigatorio(	aSvAGets[2],	aSvATela[2])
			Return .F.
		EndIf
		If (LMT447Ext .Or. LMT447Rec) .And. Empty(M->RSC_PEDORI)
			Help( " ", 1, STR0023,,STR0054, 1, 0 ) // "Aviso", "Pedimento origen  vacio!"
			Return .F.
		EndIf
		If !MT447TudOk(nOpc)
			Return .F.
		EndIf
		If LMT447EXT
			CALCOSEXT()
		Else
			MT447CALCULO()
		EndIf
	EndIf

	If nOpc == 5 //Borrar
		If !msgYesNo(STR0055) //"¿Estas seguro de eliminar?"
			Return .T.
		EndIf
	EndIf

	CursorWait()

	If nOpc == 3
		Begin TRANSACTION
		    //Datos del pedimento
			RecLock("RSC",.T.)
			RSC->RSC_FILIAL := xFilial("RSC")
			RSC->RSC_NUMPED := M->RSC_NUMPED

			For nX := 1 To Len(aAltRSC)
				RSC->&(aAltRSC[nX]) := M->&(aAltRSC[nX])
			Next
			RSC->(MsUnLock())

		    //Datos del transportista
			lGraba:= .F.
			For nX := 1 To Len(aAltRSO)
				If !Empty( M->&(aAltRSO[nX]))
					lGraba:= .T.
					Exit
				EndIf
			Next
			If lGraba .And. !LMT447EXT
				RecLock("RSO",.T.)
				RSO->RSO_FILIAL := xFilial("RSO")
				RSO->RSO_NUMPED := M->RSC_NUMPED

				For nX := 1 To Len(aAltRSO)
					RSO->&(aAltRSO[nX]) := M->&(aAltRSO[nX])
				Next
				RSO->(MsUnLock())
			EndIf
			MT447Altas(nOpc)

			If LibMetric()	//Valida la fecha de la LIB para utilizacion en Telemetria

				// Metrica de control de tipo de pedimento
				cSubRutina := "Tipo_" + AllTrim(RSC->RSC_CVEPED) + cTxtAuto
				FwCustomMetrics():setSumMetric(cSubRutina, "compras-protheus_cantidad-pedimentos-registrados-por-tipo_total", 1, /*dDateSend*/, /*nLapTime*/, "MATA447")

				// Métrica de Cantidad promedio de veces que se usa el botón de calculo de impuestos por pedimento
				cSubRutina := "media-calculo-impuestos-por-pedimento" + cTxtAuto
				FwCustomMetrics():setAverageMetric(cSubRutina, "compras-protheus_cantidad-de-veces-de-calculo-de-impuestos-por-pedimento_average", nConMetImp, /*dDateSend*/, /*nLapTime*/, "MATA447D")
				nConMetImp := 0

				// Métrica de Cantidad promedio de veces que se usa el botón "Resumen del Pedimento"
				cSubRutina := "media-uso-boton-resumen" + cTxtAuto
				FwCustomMetrics():setAverageMetric(cSubRutina, "compras-protheus_cantidad-de-consultas-de-resumen-del-pedimento_average", nUsoBtnRes, /*dDateSend*/, /*nLapTime*/, "MATA447A")
				nUsoBtnRes := 0

			EndIf

			If (ExistBlock("MT447INS"))
				ExecBlock("MT447INS",.F.,.F.)
			EndIf
		End transaction
	EndIf

	If nOpc == 4 //Modificar
		Begin transaction
			//Datos del pedimento
			RSC->(DBSetOrder(1))
			If RSC->(DBSeek(xFilial("RSC")+M->RSC_NUMPED))
				RecLock("RSC",.F.)
				For nX := 1 To Len(aAltRSC)
					RSC->&(aAltRSC[nX]) := M->&(aAltRSC[nX])
				Next
				RSC->(MsUnLock())
			EndIf
    		//Datos del transportista
			If !LMT447EXT
				RSO->(DBSetOrder(1))
				If RSO->(DBSeek(xFilial("RSO")+M->RSC_NUMPED ))
					RecLock("RSO",.F.)
				Else
					RecLock("RSO",.T.)
					RSO->RSO_FILIAL:=xFilial("RSO")
					RSO->RSO_NUMPED := M->RSC_NUMPED
				EndIf
				For nX := 1 To Len(aAltRSO)
					RSO->&(aAltRSO[nX]) := M->&(aAltRSO[nX])
				Next
				RSO->(MsUnLock())
			EndIf

			MT447Bajas(nOpc,"RSD")
			MT447Bajas(nOpc,"RSE")
			MT447Bajas(nOpc,"RSF")
			MT447Bajas(nOpc,"RSG")
			MT447Bajas(nOpc,"RSH")
			MT447Bajas(nOpc,"RSI")

			MT447Bajas(nOpc,"RSK")
			MT447Bajas(nOpc,"RSL")
			MT447Bajas(nOpc,"RSM")
			MT447Bajas(nOpc,"RSN")

			MT447Altas(nOpc)

			If LibMetric()	//Valida la fecha de la LIB para utilizacion en Telemetría

				// Métrica de Cantidad promedio de veces que se usa el botón de calculo de impuestos por pedimento
				cSubRutina := "media-calculo-impuestos-por-pedimento" + cTxtAuto
				FwCustomMetrics():setAverageMetric(cSubRutina, "compras-protheus_cantidad-de-veces-de-calculo-de-impuestos-por-pedimento_average", nConMetImp, /*dDateSend*/, /*nLapTime*/, "MATA447D")
				nConMetImp := 0

				// Métrica de Cantidad promedio de veces que se usa el botón "Resumen del Pedimento"
				cSubRutina := "media-uso-boton-resumen" + cTxtAuto
				FwCustomMetrics():setAverageMetric(cSubRutina, "compras-protheus_cantidad-de-consultas-de-resumen-del-pedimento_average", nUsoBtnRes, /*dDateSend*/, /*nLapTime*/, "MATA447A")
				nUsoBtnRes := 0

			EndIf
		End transaction
	EndIf

	If nOpc == 5 //Borrar

		RSC->(DBSetOrder(2))//RSC_FILIAL+RSC_PEDORI
		If RSC->(DBSeek(xFilial("RSC")+M->RSC_NUMPED))
	        //MSGALERT("Este pedimento tiene pedimentos asociados, no permite eliminar")
			Help( "", 1, STR0056,STR0057,STR0058, 1, 0 ) //"Help","Solución", "Este pedimento tiene pedimentos asociados, no permite Eliminar."
			Return .F.
		EndIf
		//Begin transaction
			RSC->(DBSetOrder(1))
			If RSC->(DBSeek(xFilial("RSC")+M->RSC_NUMPED))
				RecLock("RSC",.F.)
				RSC->(DBDelete())
				RSC->(MsUnLock())
			EndIf
		    //Datos del transportista
			RSO->(DBSetOrder(1))
			If RSO->(DBSeek(xFilial("RSO")+M->RSC_NUMPED ))
				RecLock("RSO",.F.)
				RSO->(DBDelete())
				RSO->(MsUnLock())
			EndIf
	  		//	End trasaction
			MT447Bajas(nOpc,"RSD")
			MT447Bajas(nOpc,"RSE")
			MT447Bajas(nOpc,"RSF")
			MT447Bajas(nOpc,"RSG")
			MT447Bajas(nOpc,"RSH")
			MT447Bajas(nOpc,"RSI")

			MT447Bajas(nOpc,"RSK")
			MT447Bajas(nOpc,"RSL")
			MT447Bajas(nOpc,"RSM")
			MT447Bajas(nOpc,"RSN")
			//Begin transaction
	     	//Datos del TOTAL DE GASTOS
			RSJ->(DBSetOrder(1))
			If RSJ->(DBSeek(xFilial("RSJ")+M->RSC_NUMPED ))
				RecLock("RSJ",.F.)
				RSJ->(DBDelete())
				RSJ->(MsUnLock())
			EndIf
		//End trasaction
		If (ExistBlock("MT447ELI"))
			ExecBlock("MT447ELI",.F.,.F.)
		EndIf

	EndIf

	CursorArrow()

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447Bajas ³Autor ³     Gpe. Santacruz    ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Elimina todos los registros de una tabla de acuerdo al       ³±±
±±³          ³pedimento.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447Bajas(nExp1,cExp1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExp1.- Numero de opcion seleccionada nOpc                   ³±±
±±³          ³cExp1.- Alias de la tabla                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MT447Bajas(nOpc,cAliasx)

	Local cFilXX := xFilial(cAliasx)
	Local nPosSta,nPosiTF,nPFac := 0

	(caliasx)->(DBSetOrder(1))

	Do While .T.
		If (cAliasx)->(DBSeek(cFilXX+M->RSC_NUMPED))
			If CALIASX=='RSF'

				//-- Actualiza la orden de compra -----------


				If !Empty(RSF->(RSF_PEDIDO+RSF_ITEMPC))
					nPosSta := GdFieldPos( "RSE_EXTFAC", aHoGetFacts) //Extraccion de factura

					nPosiTF	:= aScan(aHoGetFacts,{|x| Trim(x[2])=="RSE_ITEM"})

					nPFac	:= aScan(aCoGetFacts,{|x| Trim(x[nPosItf]) == RSF->RSF_ITEDOC})

					if 	empty(aCoGetFacts[nPFac,nPosSta])
						DBSelectArea("SC7")
						DBSetOrder(1)
						If SC7->(dbSeek(xFilial("SC7")+RSF->(RSF_PEDIDO+RSF_ITEMPC)))
							RecLock("SC7",.F.)
							SC7->C7_QTDACLA -= RSF->RSF_CANT
							SC7->(MsUnLock())
						EndIf
					EndIf
				endif
			EndIf
			RecLock(cAliasx,.F.)
			(caliasx)->(DBDelete())
			(caliasx)->(MsUnlock())
		Else
			Exit
		EndIf
	EndDo

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447Altas ³Autor ³     Gpe. Santacruz    ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Inserta registros en todas las tablas utilizadas en el regis-³±±
±±³          ³tro de pedimento.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447Altas(nOpc)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExp1.- Numero de opcion seleccionada nOpc                   ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MT447Altas(nOpc)

	Local nx      := 0
	Local ny      := 0
	Local cFilRSD := xFilial("RSD")
	Local cFilRSE := xFilial("RSE")
	Local cFilRSF := xFilial("RSF")
	Local cFilRSG := xFilial("RSG")
	Local cFilRSH := xFilial("RSH")
	Local cFilRSI := xFilial("RSI")

	Local cFilRSK := xFilial("RSK")
	Local cFilRSL := xFilial("RSL")
	Local cFilRSM := xFilial("RSM")
	Local cFilRSN := xFilial("RSN")
	Local cFilSF1 := xFilial("SF1")
	Local nPosFac := 0
	Local nPosSer := 0
	Local nPosPrv := 0
	Local nPosTda := 0
	Local nDeleted:= 0
	Local nLlave  := 0
	Local nz      := 0
	Local aCampos := {}
	Local lExiste := .F.
	Local nPosRSC	:=0

	//Datos de los incrementables. Adecuacion por causa de teste automatizado
	CpyResGetDad(.t.,"oGetIncrem")
	nDeleted	:= GdFieldPos("GDDELETED",aHoGetIncrem)
	nLlave		:= GdFieldPos("RSK_FOLIO",aHoGetIncrem)


	For nx:=1 To Len(aCoGetIncrem)
		If !aCoGetIncrem[nx, nDeleted] .And. !Empty(aCoGetIncrem[nx, nLlave])
			RecLock("RSK",.T.)
			RSK->RSK_FILIAL := cFilRSK
			RSK->RSK_NUMPED := M->RSC_NUMPED

			For ny:=1 To Len( aHoGetIncrem)
				If aHoGetIncrem[ny,10]<>'V' //Excluye los campos virtuales
					&("RSK->"+aHoGetIncrem[ny,2]):=aCoGetIncrem[nx,ny]
				EndIf
			Next
			RSK->(MsUnLock())
		EndIf
	Next

    //Datos de Impuestos del pedimento
    CpyResGetDad(.t.,"oGetImpPed")
	nDeleted	:= GdFieldPos("GDDELETED",aHoGetImpPed)
	nLlave		:= GdFieldPos("RSD_CODIMP",aHoGetImpPed)


	For nx:=1 To Len(aCoGetImpPed)
		If !aCoGetImpPed[nx, nDeleted] .And. !Empty(aCoGetImpPed[nx, nLlave])
			RecLock("RSD",.T.)
			RSD->RSD_FILIAL := cFilRSD
			RSD->RSD_NUMPED := M->RSC_NUMPED

			For ny:=1 To Len( aHoGetImpPed)
				If aHoGetImpPed[ny,10]<>'V' //Excluye los campos virtuales
					&("RSD->"+aHoGetImpPed[ny,2]):=aCoGetImpPed[nx,ny]
				EndIf
			Next
			RSD->(MsUnLock())
		EndIf
	Next

	//Datos de l facturas
	CpyResGetDad(.t.,"oGetFacts")
	CpyResGetDad(.t.,"oGetItemF")

	nDeleted	:= GdFieldPos("GDDELETED"	, aHoGetFacts)
	nLlave		:= GdFieldPos("RSE_FACT"	, aHoGetFacts)
	nPosIte		:= GdFieldPos("RSE_ITEM"	, aHoGetFacts)

	nPosSer		:= GdFieldPos("RSE_SERIE"	, aHoGetFacts)
	nPosPrv		:= GdFieldPos("RSE_PROV"	, aHoGetFacts)
	nPosTda		:= GdFieldPos("RSE_TDA"		, aHoGetFacts)

	nDelRSF		:= GdFieldPos("GDDELETED"	, aHoGetItemF)
	nLlave6		:= GdFieldPos("RSF_PRODUC"	, aHoGetItemF)
	nPosFac		:= GdFieldPos("RSF_ITEDOC"	, aHoGetItemF)
	nPosI		:= GdFieldPos("RSF_ITEM"	, aHoGetItemF)

	If lUsoRSG
		SX3->(DBSetOrder(1))
		SX3->(DBSeek("RSG"))
		aCampos := {}
		Do While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "RSG"
			If SX3->X3_CONTEXT <> "V" .And. !(SX3->X3_CAMPO  $ "RSG_NUMPED,RSG_FILIAL")
				aAdd(acampos,SX3->X3_CAMPO)
			EndIf
			SX3->(DBSkip())
		EndDo
		SX3->(DBSetOrder(1))
		SX3->(DBSeek("RSH"))
		aCampRSH := {}
		Do While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "RSH"
			If SX3->X3_CONTEXT <> "V" .And. !(SX3->X3_CAMPO  $ "RSH_NUMPED,RSH_FILIAL")
				aAdd(aCampRSH,SX3->X3_CAMPO)
			EndIf
			SX3->(DBSkip())
		EndDo
	EndIf

	SF1->(DBSetOrder(1))

	For nx := 1 To Len(	aCoGetFacts)
		If !aCoGetFacts[nx, nDeleted] .And. !Empty(aCoGetFacts[nx, nLlave])
			/*
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida que el encabezado de la factura tenga items, sino, no graba el encabezado³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			*/
			lGraba:= .F.
			nPos:= aScan(aColsIt,{|x| Trim(x[1,nPosFac])==AllTrim(aCoGetFacts[nx, nPosIte])  })
			If nPos>0
				npos:=aScan(aColsIt[npos],{|x|  !x[nDelRSF] .And. !Empty(x[nLlave6]) })   //con que exista un item, es valido
				If npos > 0
					lGraba := .T.
				EndIf
			EndIf
			If lGraba

				lExiste := .F.
				If SF1->(DBSeek(CFILSF1+ aCoGetFacts[nx,nLlave]+ aCoGetFacts[nx,nPosSer]+aCoGetFacts[nx,nPosPrv]+ aCoGetFacts[nx,nPosTda]))
					lExiste:= .T.
				EndIf

				RecLock("RSE",.T.)
				RSE->RSE_FILIAL := cFilRSE
				RSE->RSE_NUMPED := M->RSC_NUMPED

				For ny:=1 To Len( 	aHoGetFacts)
					If aHoGetFacts[ny,10]<>'V' //Excluye los campos virtuales
						&("RSE->"+	aHoGetFacts[ny,2]):=	aCoGetFacts[nx,ny]
					EndIf
				Next
				//Si la factura ya existe en SF1 la graba con status de que ya fue pasada a compras
				If lExiste
					RSE->RSE_OK:='S'
				Else
					RSE->RSE_OK:=''
				EndIf
				RSE->(MsUnLock())

				//Datos del item de la factura
				nPos:= aScan(aColsIt,{|x| Trim(x[1,nPosFac])==AllTrim(aCoGetFacts[nx, nPosIte])  })
				If nPos>0
					For ny:=1 To Len(aColsIt[nPos])

						If !aColsIt[npos,ny, nDelRSF] .And. !Empty(aColsIt[npos,ny, nLlave6])
							RecLock("RSF",.T.)
							RSF->RSF_FILIAL := cFilRSF
							RSF->RSF_NUMPED := M->RSC_NUMPED

							For nZ:=1 To Len( 	aHoGetItemF)
								If aHoGetItemF[nZ,10]<>'V' //Excluye los campos virtuales
									&("RSF->"+	aHoGetItemF[nz,2]):=	aColsIt[npos,ny,nz]
								EndIf
							Next

							RSF->(MsUnLock())
							//-- Actualiza la orden de compra ----
							if !lExiste
								If !Empty(RSF->(RSF_PEDIDO+RSF_ITEMPC))
									DBSelectArea("SC7")
									DBSetOrder(1)
									If SC7->(dbSeek(xFilial("SC7")+RSF->(RSF_PEDIDO+RSF_ITEMPC)))
										RecLock("SC7",.F.)
										SC7->C7_QTDACLA += RSF->RSF_CANT
										SC7->(MsUnLock())
									EndIf
								EndIf
							endif
						EndIf

					Next
					If lUsoRSG
						GrabaRSG(aCampos,aCampRSH,aCoGetFacts[nx,nLlave], aCoGetFacts[nx,nPosSer],aCoGetFacts[nx,nPosPrv], aCoGetFacts[nx,nPosTda],aCoGetFacts[nx, nPosIte])
					EndIf
				EndIf
			EndIf  //de lGraba

		EndIf
	Next
	If LMT447EXT  //Graba los impuestos de solo la extraeecion realizada
		If lUsoRSG
			GrabaRSG(aCampos,aCampRSH)
		EndIf
	EndIf

    //Datos de Costos
    CpyResGetDad(.t.,"oGetCosto")
	nDeleted:= GdFieldPos("GDDELETED",	aHoGetCosto)
	nLlave:= GdFieldPos("RSI_FACT",aHoGetCosto)
	For nx:=1 To Len(	aCoGetCosto)
		If !aCoGetCosto[nx, nDeleted] .And. !Empty(aCoGetCosto[nx, nLlave])
			RecLock("RSI",.T.)
			RSI->RSI_FILIAL := cFilRSI
			RSI->RSI_NUMPED := M->RSC_NUMPED

			For ny:=1 To Len( 	aHoGetCosto)
				If aHoGetCosto[ny,10]<>'V' //Excluye los campos virtuales
					&("RSI->"+	aHoGetCosto[ny,2]):=	aCoGetCosto[nx,ny]
				EndIf
			Next
			RSI->(MsUnLock())
		EndIf
	Next

	//Datos del Total de Gastos
	RSJ->(DBSetOrder(1))
	If RSJ->(DBSeek(xFilial("RSJ")+M->RSC_NUMPED))
		RecLock("RSJ",.F.)
	Else
		RecLock("RSJ",.T.)
		RSJ->RSJ_FILIAL:=xFilial("RSJ")

		RSJ->RSJ_NUMPED := M->RSC_NUMPED

	EndIf
	CpyResGetDad(.t.,"oGetTot1")
	RSJ->RSJ_FLETEE	:= aCoGetTot1[1,4]
	RSJ->RSJ_SEGE	:= aCoGetTot1[2,4]
	RSJ->RSJ_ALME	:= aCoGetTot1[3,4] //EMBALAJE
	RSJ->RSJ_OTROE	:= aCoGetTot1[4,4]
	CpyResGetDad(.t.,"oGetTot2")
	RSJ->RSJ_FLETEN	:= aCoGetTot2[1,2]
	RSJ->RSJ_SEGN	:= aCoGetTot2[2,2]
	RSJ->RSJ_ALMN	:= aCoGetTot2[3,2]
	RSJ->RSJ_OTRON	:= aCoGetTot2[4,2]

	RSJ->RSJ_VALDOL	:= aCoGetTot1[1,2]
	RSJ->RSJ_VALADU	:= aCoGetTot1[2,2]
	RSJ->RSJ_VALPES	:= aCoGetTot1[3,2]
	RSJ->RSJ_VALINC	:= aCoGetTot1[4,2]
	RSJ->(MSUnlock())

	//Datos del Resumen de impuestos
	CpyResGetDad(.t.,"oGetTot3")
	For nx := 1 To Len(aCoGetTot3) - 1
		If  !Empty(aCoGetTot3[nx,2])
			RecLock("RSL",.T.)
			RSL->RSL_FILIAL	:= cFilRSK
			RSL->RSL_NUMPED	:= M->RSC_NUMPED
			RSL->RSL_CODIMP	:= aCoGetTot3[nx,1]
			RSL->RSL_DESC	:= aCoGetTot3[nx,2]
			RSL->RSL_IMPORT	:= aCoGetTot3[nx,3]
			RSL->(MsUnLock())
		EndIf
	Next

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Actualiza la cantidad pendiente de la extraccion³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	If LMT447ext .And.  lUsoFac
		SX3->(DBSetOrder(1))
		TRB->(DBGoTop())
		Do While !TRB->(Eof())
			If !Empty(TRB->TRB_OK)
				RECLOCK("RSM",.T.)
				RSM->RSM_FILIAL := CFILRSM
				RSM->RSM_NUMPED := M->RSC_NUMPED
				RSM->RSM_PEDORI := M->RSC_PEDORI
				SX3->(DBSeek("RSM"))
				Do While !SX3->(Eof()) .And. SX3->X3_ARQUIVO=='RSM'
					If SX3->X3_CONTEXT== "V" .Or. AllTrim(SX3->X3_CAMPO)=='RSM_FILIAL' .Or. AllTrim(SX3->X3_CAMPO)=='RSM_NUMPED' .Or. AllTrim(SX3->X3_CAMPO)=='RSM_PEDORI' .Or. AllTrim(SX3->X3_CAMPO)=='RSM_OKT'
					Else
						&("RSM->RSM"+SubSTR(SX3->X3_CAMPO,4,7)):=&("TRB->TRB"+SubSTR(SX3->X3_CAMPO,4,7))
					EndIf
					SX3->(DBSkip())
				EndDo
				RSM->(MSUnlock())
			EndIf
			TRB->(DBSkip())
		EndDo
	EndIf

	//Datos de los gastos desglosados
	For nx:=1 To Len(aGastos)
		RecLock("RSN",.T.)
		RSN->RSN_FILIAL	:= cFilRSN
		RSN->RSN_NUMPED := M->RSC_NUMPED
		RSN->RSN_FACT	:= aGastos[nx,1]
		RSN->RSN_SERIE	:= aGastos[nx,2]
		RSN->RSN_PROV	:= aGastos[nx,3]
		RSN->RSN_TDA	:= aGastos[nx,4]
		RSN->RSN_ITEM	:= aGastos[nx,5]
		RSN->RSN_PROD	:= aGastos[nx,6]
		RSN->RSN_GASTOS	:= aGastos[nx,7]
		RSN->RSN_FACORI	:= aGastos[nx,9]
		RSN->RSN_SERORI	:= aGastos[nx,10]
		RSN->RSN_PROORI	:= aGastos[nx,11]
		RSN->RSN_TDAORI	:= aGastos[nx,12]
		RSN->RSN_TES	:= aGastos[nx,13]
		RSN->(MsUnLock())
	Next

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GrabaRSG   ³Autor ³  Gpe. Santacruz       ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Actualiza los registro de la tabla RSG y RSH de acuerdo a la ³±±
±±³          ³factura que se este procesando                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³GrabaRSG(aExp1,aExp2,cExp1,cExp2,cExp3,cExp4)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aExp1.- Header de la tabla RSG                               ³±±
±±³          ³aExp2.- Header de la tabla RSH                               ³±±
±±³          ³cExp1.- Numero de factura                                    ³±±
±±³          ³cExp2.- Numero de serie                                      ³±±
±±³          ³cExp3.- Codigo de proveedor                                  ³±±
±±³          ³cExp4.- Codigo de tienda del proveedor                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GrabaRSG(aCamRSG,aCamRSH,cFac,cSer,cPrv,cTda,CITEDOC)

	Local ny      := 0
	Local cFilRSG := xFilial("RSG")
	Local cFilRSH := xFilial("RSH")
	Local cFilRSF := xFilial("RSF")
	Local nTamPed := TAMSX3("RSF_NUMPED")[1]


	RSF->(DBSetOrder(1))

	//Datos de Impuestos (Secciones)
	TMPRSH->(DBSetOrder(1))
	TMPRSG->(DBSetOrder(1))

	If !Empty(CFAC)
		TMPRSG->(DBgotop())
		TMPRSG->(DBSeek(cFac+cSer+cPrv+cTda))
		Do While !TMPRSG->(Eof()) .And. TMPRSG->RSG_FACT+TMPRSG->RSG_SERIE+TMPRSG->RSG_PROV+TMPRSG->RSG_TDA==cFac+cSer+cPrv+cTda
			If RSF->(DBSeek(CFILRSF+PADR(M->RSC_NUMPED,nTamPed," ")+CITEDOC+TMPRSG->RSG_ITEM))
				RECLOCK("RSG",.T.)
				RSG->RSG_FILIAL := cFilRSG
				RSG->RSG_NUMPED := M->RSC_NUMPED

				For ny := 1 To Len(aCamRSG)
					&("RSG->"+	aCamRSG[ny]):= &("TMPRSG->"+aCamRSG[ny])
				Next
				RSG->(MSUnlock())

				//Datos de Impuestos por seccion
				TMPRSH->(DBgotop())
				TMPRSH->(DBSeek(cFac+cSer+cPrv+cTda+ TMPRSG->RSG_ITEM))
				Do While !TMPRSH->(Eof()) .And. TMPRSH->RSH_FACT+TMPRSH->RSH_SERIE+TMPRSH->RSH_PROV+TMPRSH->RSH_TDA+TMPRSH->RSH_ITEM == cFac+cSer+cPrv+cTda+ TMPRSG->RSG_ITEM
					RECLOCK("RSH",.T.)
					RSH->RSH_FILIAL := cFilRSH
					RSH->RSH_NUMPED := M->RSC_NUMPED

					For ny := 1 To Len(aCamRSH)
						&("RSH->"+	aCamRSH[ny]):= &("TMPRSH->"+aCamRSH[ny])
					Next
					RSH->(MSUnlock())
					TMPRSH->(DBSkip())
				EndDo
			EndIf
			TMPRSG->(DBSkip())
		EndDo
	Else //ES UNA EXTRACCION
		TMPRSG->(DBGoTop())
		Do While !TMPRSG->(Eof())
			RecLock("RSG",.T.)
			RSG->RSG_FILIAL := cFilRSG
			RSG->RSG_NUMPED := M->RSC_NUMPED

			For ny := 1 To Len(aCamRSG)
				&("RSG->"+	aCamRSG[ny]):= &("TMPRSG->"+aCamRSG[ny])
			Next

			RSG->(MSUnlock())
			TMPRSG->(DBSkip())
		EndDo

		//Datos de Impuestos por seccion
		TMPRSH->(DBGoTop())
		Do While !TMPRSH->(Eof())
			RecLock("RSH",.T.)
			RSH->RSH_FILIAL := cFilRSH
			RSH->RSH_NUMPED := M->RSC_NUMPED
			For ny := 1 To Len(aCamRSH)
				&("RSH->"+	aCamRSH[ny]):= &("TMPRSH->"+aCamRSH[ny])
			Next
			RSH->(MSUnlock())
			TMPRSH->(DBSkip())
		EndDo
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447IMPUES³Autor ³  Gpe. Santacruz       ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacion del codigo de impuestos, para los campos:         ³±±
±±³          ³RSD_CODIMP  y RSH_IMPUES                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447IMPUES(nExp1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExp1.- 1 si es llamada  la validaciOn del campo RSD_CODIMP  ³±±
±±³          ³        2 Si es llamada la validacion del campo RSH_IMPUES   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_VALID, campo RSD_CODIMP y RSH_IMPUES                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447IMPUES(nQuien)

	Local nPosCont := 0
	Local nPosTT   := 0
	Local nPosTas  := 0
	Local nPosImp  := 0
	Local nPos     := 0
	RSA->(DBSetOrder(1))



	If nQuien==1 //SI VALIDACION DE RSD_CODIMP
		If !ExistCpo("RSA",M->RSD_CODIMP)
			Return .F.
		EndIf
		RSA->(DBSetOrder(1))
		RSA->(DBSeek(xFilial("RSA")+M->RSD_CODIMP))

		If RSA->RSA_USOFRA == '1'
	   		//MsgInfo("El tipo de impuestos es incorrecto")
			Help( " ", 1,STR0023,,STR0059, 1, 0 )  //	"Aviso",, "El tipo de impuestos es incorrecto"
			Return .F.
		EndIf
		CpyResGetDad(.t.,"oGetImpPed")//Copia getdados
		If lX001Auto .or. lAutoTeste
			nPos := N
		Else
			nPos := nNoGetImpPed
		EndIf

		nPosCont	:= GdFieldPos("RSD_CONTR"	, aHoGetImpPed)
		nPosTT		:= GdFieldPos("RSD_TT"		, aHoGetImpPed)
		nPosTas		:= GdFieldPos("RSD_TASA"	, aHoGetImpPed)
		nPosImp		:= GdFieldPos("RSD_IMPORT"	, aHoGetImpPed)
		nPosPIVA	:= GdFieldPos("RSD_PORIVA"	, aHoGetImpPed)
		nPosIIVA	:= GdFieldPos("RSD_IMPIVA"	, aHoGetImpPed)

		aCoGetImpPed[nPos,nPosCont]	:= RSA->RSA_DESC
		aCoGetImpPed[nPos,nPosTT]	:= RSA->RSA_TIPO
		aCoGetImpPed[nPos,nPosTas]	:= RSA->RSA_TASIMP
		aCoGetImpPed[nPos,nPosImp]	:= RSA->RSA_IMPORT

		If RSA->RSA_APLIVA == '1'
			aCoGetImpPed[nPos,nPosPIVA] := nP_PORIVA
		Else
			aCoGetImpPed[nPos,nPosPIVA] := 0
			aCoGetImpPed[nPos,nPosIIVA] := 0
		EndIf
		CpyResGetDad(.f.,"oGetImpPed")//Restaura GetDados
	Else
		If !ExistCpo("RSA",M->RSH_IMPUES)
			Return .F.
		EndIf
		RSA->(DBSetOrder(1))
		RSA->(DBSeek(xFilial("RSA")+M->RSH_IMPUES))

		If RSA->RSA_USOFRA=='1'
	   		//MsgInfo("El tipo de impuestos es incorrecto")
			Help( " ", 1, STR0056,,STR0059, 1, 0 ) //"Help",, "El tipo de impuestos es incorrecto"
			Return .F.
		EndIf
		CpyResGetDad(.t.,"oGetIm2") //Copia getdados
		nPos		:= nNoGetIm2 //:nat
		nPosCont	:= GdFieldPos("RSH_DESIMP"	, oGetIm2:aHeader)
		nPosTT		:= GdFieldPos("RSH_TIPTAS"	, oGetIm2:aHeader)
		nPosTas		:= GdFieldPos("RSH_TASA"	, oGetIm2:aHeader)
		nPosImp		:= GdFieldPos("RSH_IMPORT"	, oGetIm2:aHeader)
		nPosPIVA	:= GdFieldPos("RSH_PORIVA"	, oGetIm2:aHeader)
		nPosIIVA	:= GdFieldPos("RSH_IMPIVA"	, oGetIm2:aHeader)

		aCoGetIm2[nPos,nPosCont]	:= RSA->RSA_DESC
		aCoGetIm2[nPos,nPosTT]		:= RSA->RSA_TIPO
		aCoGetIm2[nPos,nPosTas]		:= RSA->RSA_TASIMP
		aCoGetIm2[nPos,nPosImp]		:= RSA->RSA_IMPORT

		If RSA->RSA_APLIVA == '1'
			aCoGetIm2[nPos,nPosPIVA] := nP_PORIVA
		Else
			aCoGetIm2[nPos,nPosPIVA] := 0
			aCoGetIm2[nPos,nPosIIVA] := 0
		EndIf

		CpyResGetDad(.f.,"oGetIm2") //Retaura los getdados

	EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LlenaMgmGet³Autor ³  Gpe. Santacruz       ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Llena informacion de los enchoice, cuando se trata de una    ³±±
±±³          ³extraccion.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³LlenaMgmGet(cExp1,cExp2,aExp1,aExp2)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1.- Alias.                                               ³±±
±±³          ³cExp2.- Numero de pedimento.                                 ³±±
±±³          ³aExp1.- Campos de la tabla.                                  ³±±
±±³          ³aExp2.- Campos que permite alteraciones.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LlenaMgmGet(cAliasG,cNumPed,aCamTab,aAlt)

	Local nx      := 0
	Local nRegTmp := (cAliasG)->(Recno())
	Default cNumPed:=''
if !empty(cNumPed)
	(cAliasG)->(DBSetOrder(1))
	If (cAliasG)->(DBSeek(xFilial(cAliasG)+cNumPed))
		For NX:=1 To Len(aCamTab)
			If (aScan(aAlt,{|x| Trim(x) == AllTrim(aCamTab[NX]) })) == 0
				&("M->"+aCamTab[NX]):=&(cAliasG+"->"+aCamTab[NX])
			EndIf
		Next
	EndIf
else
	For NX:=1 To Len(aCamTab)
			If (aScan(aAlt,{|x| Trim(x) == AllTrim(aCamTab[NX]) })) == 0
				&("M->"+aCamTab[NX]):=&(cAliasG+"->"+aCamTab[NX])
			EndIf
		Next
endif
	(cAliasG)->(Recno()) := nRegTmp

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LlenaGetDa ³Autor ³  Gpe. Santacruz          ³ Data ³14/03/16³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Llena informacion de la BD  al aCols                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³LlenaMgmGet(cExp1,aExp1,aExp2,cExp2,cExp3,nExp1)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1.- Alias.                                               ³±±
±±³          ³aExp1.- aHeader                                              ³±±
±±³          ³aExp2.- aCols                                                ³±±
±±³          ³cExp2.- Llave de busqueda                                    ³±±
±±³          ³cExp3.- Codicion del while                                   ³±±
±±³          ³nExp1.- Orden del indice                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LlenaGetDados(cAliasx,aH,aC,cSeek,cWhile,nOrden)

	Local nUsado := Len(aH)
	Local nx     := 0
	Local cFil   := xFilial(cAliasx)

	aC := {}

	(cAliasx)->(DBSetOrder(nOrden))

	If (caliasx)->(DBSeek(cFil+&(cSeek)))
		Do While !(caliasx)->(Eof())
			If  &(cWhile)
				aAdd(aC,Array(nUsado+1))
				For nX := 1 To nUsado
					lPasa:= .T.
					If lpasa
						If ( aH[nX,10] <>  "V" )
							aC[Len(aC)][nX] := &(caliasx+"->"+aH[nX,2])
						Else
							aC[Len(aC)][nX] := CriaVar(aH[nX,2],.T.)
						EndIf
					EndIf
				Next nX
				aC[Len(aC)][nUsado+1] := .F.
				(cAliasx)->(dbSkip())
			Else
				Exit
			EndIf
		EndDo
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LlenaCostos³      ³     Gpe. Santacruz    ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Llena informacion de la pestaña de Costos                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³LlenaMgmGet(cExp1,aExp1,aExp2,cExp2,cExp3,nExp1)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1.- Alias.                                               ³±±
±±³          ³aExp1.- aHeader                                              ³±±
±±³          ³aExp2.- aCols                                                ³±±
±±³          ³cExp2.- Llave de busqueda                                    ³±±
±±³          ³cExp3.- Codicion del while                                   ³±±
±±³          ³nExp1.- Orden del indice                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LlenaCostos(cAliasx,aH,aC,cSeek,cWhile,nOrden)

	Local nUsado  := Len(aH)
	Local nx      := 0
	Local cFil    := xFilial(cAliasx)
	Local nTotImp := 0
	Local nTotPrr := 0
	Local nTotInc := 0
	Local nTotCif := 0
	Local nTotTax := 0
	Local nTTotGas:= 0
	Local nTTotGiN:= 0

	Local nPosImp := GdFieldPos("RSI_IMPOR"	, aH)
	Local nPosPrr := GdFieldPos("RSI_PRORR"	, aH)
	Local nPosInc := GdFieldPos("RSI_INCREM", aH)
	Local nPoscif := GdFieldPos("RSI_CIF"	, aH)
	Local nPosTax := GdFieldPos("RSI_IMPUES", aH)
	Local nPosGas := GdFieldPos("RSI_GASTOS", aH)
	Local nPosGI  := GdFieldPos("RSI_GASINT", aH)
	aC := {}

	(cAliasx)->(DBSetOrder(nOrden))

	If (caliasx)->(DBSeek(cFil+&(cSeek)))
		Do While !(caliasx)->(Eof())
			If  &(cWhile)
				aAdd(aC,Array(nUsado+1))
				For nX := 1 To nUsado
					If ( aH[nX,10] <>  "V" )
						aC[Len(aC)][nX] := &(caliasx+"->"+aH[nX,2])
						If nx == nPosImp
							nTotImp += &(caliasx+"->"+aH[nX,2])
						EndIf
						If nx == nPosPrr
							nTotPrr += &(caliasx+"->"+aH[nX,2])
						EndIf
						If nx == nPosInc
							nTotInc += &(caliasx+"->"+aH[nX,2])
						EndIf
						If nx == nPosGI
							nTTotGiN += &(caliasx+"->"+aH[nX,2])
						EndIf
						If nx == nPosCif
							nTotCif += &(caliasx+"->"+aH[nX,2])
						EndIf
						If nx == nPosTax
							nTotTax += &(caliasx+"->"+aH[nX,2])
						EndIf
						If nx == nPosGas
							nTTotGas += &(caliasx+"->"+aH[nX,2])
						EndIf
					Else
						aC[Len(aC)][nX] := CriaVar(aH[nX,2],.T.)
					EndIf
				Next nX
				aC[Len(aC)][nUsado+1] := .F.
				(cAliasx)->(dbSkip())
			Else
				Exit
			EndIf
		EndDo
		TotCostos(@aC,aH,nUsado,nTotImp,nTotPrr,nTotInc,nTotCif ,nTotTax,nTTotGas,nTTotGiN)
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TotCostos  ³Autor ³     Gpe. Santacruz    ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Total de la pestaña de Costos de Producto.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³TotCostos(aExp1,@aExp2)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Importaciones para Mexico                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TotCostos(aC,aH,nUsado,nTotImp,nTotPrr,nTotInc,nTotCif ,nTotTax,nTTotGas,nTTotGiN)

	Local nPosDes := GdFieldPos("RSI_DESC"		, aH)
	Local nPosImp := GdFieldPos("RSI_IMPOR"		, aH)
	Local nPosPrr := GdFieldPos("RSI_PRORR"		, aH)
	Local nPosInc := GdFieldPos("RSI_INCREM"	, aH)
	Local nPoscif := GdFieldPos("RSI_CIF"		, aH)
	Local nPosTax := GdFieldPos("RSI_IMPUES"	, aH)
	Local nPosGas := GdFieldPos("RSI_GASTOS"	, aH)
	Local nPosGI  := GdFieldPos("RSI_GASINT"	, aH)

	aAdd(aC,Array(nUsado+1))
	aC[Len(aC), nPosDes]	:= STR0060 //"Totales --->"
	aC[Len(aC), nPosImp]	:= nTotImp
	aC[Len(aC), nPosPrr]	:= nTotPrr
	aC[Len(aC), nPosGI]		:= nTTotGiN
	aC[Len(aC), nPosInc]	:= nTotInc
	aC[Len(aC), nPosCif]	:= nTotCif
	aC[Len(aC), nPosTax]	:= nTotTax
	aC[Len(aC), nPosGas]	:= nTTotGas
	aC[Len(aC)][nUsado+1]	:= .F.

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LlenaItems ³Autor ³     Gpe. Santacruz    ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Llena informacion con los items de las facturas del pedimento³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³LlenaItems(aExp1,@aExp2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aExp1.- Header del RSF.                                      ³±±
±±³          ³aExp2.- aCols de RSF.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LlenaItems(AHeader,aColsRSF)

	Local lFirstFis := .T.
	Local nCntFor   := 0
	Local nx,nz,ny  := 0
	Local nConsec   := 1
	Local cFilRSF   := xFilial("RSF")
	Local cIteTmp   := ''
	Local nPProduto		:= aScan(AHeader,{|x| AllTrim(x[2]) == "RSF_PRODUC"})
	Local cCod			:=''

	RSF->(DBSetOrder(1))
	If RSF->(DBSeek(CFILRSF+RSC->RSC_NUMPED))
		aColsIt:={}

		While !RSF->(Eof()) .And. CFILRSF+RSC->RSC_NUMPED == RSF->RSF_FILIAL+RSF->RSF_NUMPED
			cIteTmp		:= RSF->RSF_ITEDOC
			aColsRSF	:= {}

			While !RSF->(Eof()) .And. CFILRSF+RSC->RSC_NUMPED == RSF->RSF_FILIAL+RSF->RSF_NUMPED .And. cIteTmp == RSF->RSF_ITEDOC
				aAdd(aColsRSF,Array(Len(aHeader)+1))
				For nCntFor	:= 1 To Len(aHeader)
					If IsHeadRec(aHeader[nCntFor][2])
						aColsRSF[Len(aColsRSF)][nCntFor] :=  RSF->(Recno())
					ElseIf IsHeadAlias(aHeader[nCntFor][2])
						aColsRSF[Len(aColsRSF)][nCntFor] := "RSF"
					ElseIf ( aHeader[nCntFor][10] != "V" )
						aColsRSF[Len(aColsRSF)][nCntFor] :=  &("RSF->"+aHeader[nCntFor,2])
					Else
						aColsRSF[Len(aColsRSF)][nCntFor] := CriaVar(aHeader[nCntFor][2])
						IF ALLTRIM(aHeader[nCntFor,2]) == "RSF_DESC"
								    IF !EMPTY(aColsRSF[Len(aColsRSF),nPProduto])
								    	cCod:=aColsRSF[Len(aColsRSF),nPProduto]
								    	aColsRSF[Len(aColsRSF)][nCntFor] := Posicione("SB1",1,xFilial("SB1")+cCod,"B1_DESC")
								    ENDIF
						ENDIF

					EndIf
				Next nCntFor

				aColsRSF[Len(aColsRSF)][Len(aHeader)+1] := .F.

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega os impostos da primeira Invoice para Matxfis         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lFirstFis
					If MaFisFound()
						MaFisIniLoad(Len(aColsRSF))
						For nX := 1 To Len(aRefImpRSF)
							MaFisLoad(aRefImpRSF[nX][3],RSF->(FieldGet(FieldPos(aRefImpRSF[nX][2]))),Len(aColsRSF))
						Next nX
						MaFisEndLoad(Len(aColsRSF))
					EndIf
				EndIf

				RSF->(dbSkip())
			EndDo
			//Genera aCols en blanco para las facturas que no que no tienen items
			aAdd(aColsIt,aClone(aColsRSF))

			nConsec		:= Len(aColsIt)+1
			lFirstFis	:= .F.
		EndDo
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LlenaTMP   ³Autor ³     Gpe. Santacruz    ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Coloca en tablas temporales la informacion de RSG y RSH	   ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³LlenaTMP()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LlenaTMP()

	Local cFilRSG	:= xFilial("RSG")
	Local cFilRSH	:= xFilial("RSH")
	Local aCampos	:= {}
	Local ny		:= 0

	If lUsoRSG
		Return
	EndIf

	SX3->(DBSetOrder(1))
	RSG->(DBSetOrder(1))
	If RSG->(DBSeek(cFilRSG+RSC->RSC_NUMPED))

		CriaTMP("TMPRSG","{'RSG_FACT','RSG_SERIE','RSG_PROV','RSG_TDA','RSG_ITEM'}","RSG")

		SX3->(DBSeek("RSG"))
		aCampos := {}

		Do While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "RSG"
			If SX3->X3_CONTEXT<> "V"
				aAdd(acampos,SX3->X3_CAMPO)
			EndIf
			SX3->(DBSkip())
		EndDo

		Do While !RSG->(Eof()) .And. cFilRSG+RSC->RSC_NUMPED == RSG->RSG_FILIAL+RSG->RSG_NUMPED
			RecLock("TMPRSG",.T.)
			For ny := 1 To Len(acampos)
				&("TMPRSG->"+	aCampos[ny]):= &("RSG->"+aCampos[ny])
			Next
			TMPRSG->(MSUnlock())
			RSG->(DBSkip())
		EndDo

		CriaTMP("TMPRSH","{'RSH_FACT','RSH_SERIE','RSH_PROV','RSH_TDA','RSH_ITEM','RSH_IMPUES'}","RSH")
		SX3->(DBSeek("RSH"))
		aCampos := {}
		Do While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "RSH"
			If SX3->X3_CONTEXT <> "V"
				aAdd(acampos,SX3->X3_CAMPO)
			EndIf
			SX3->(DBSkip())
		EndDo
		RSH->(DBSetOrder(1))
		RSH->(DBSeek(cFilRSH+RSC->RSC_NUMPED))
		Do While !RSH->(Eof()) .And. cFilRSH+RSC->RSC_NUMPED == RSH->RSH_FILIAL+RSH->RSH_NUMPED
			RecLock("TMPRSH",.T.)
			For ny := 1 To Len(acampos)
				&("TMPRSH->"+	aCampos[ny]):= &("RSH->"+aCampos[ny])
			Next
			TMPRSH->(MSUnlock())
			RSH->(DBSkip())
		EndDo
		lUsoRSG := .T.
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447Lok1  ³Autor ³ Gpe. Santacruz        ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacion de linea OK, del getdados Encabezados de factura  ³±±
±±³          ³oGetFacts                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447Lok1()   			    				               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1- .T. Si correcto, .F. Si incorrecto                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447Lok1()



	Local nPosFornec	:= 0
	Local nPLoja		:= 0
	Local nPSerie		:= 0
	Local nPNota		:= 0
	Local nPCond		:= 0
	Local nPEmissao		:=0

	Local nPosTip		:= 0
	Local nDelFact		:= 0
	Local nPosSta		:= 0
	Local nX			:= 0

	Local lValidNFs		:= .T. // If ((aCoGetFacts[nNoGetFacts,nPosOri] <> 'P' .And. LMT447Ext) .Or. !LMT447Ext,.T.,.F.)

	Local lRetorno		:= .T.
	Local lBan			:= .T.




	if !lAutoTeste
		If !oGetFacts:LMODIFIED .And. !lX001Auto
			Return .T.
		EndIf
	endif
CursorWait()
	CpyResGetDad(.T.,"oGetFacts")//Copia GetDados
	nPosFornec	:= GdFieldPos("RSE_PROV",	 aHoGetFacts)
	nPLoja		:= GdFieldPos("RSE_TDA",	 aHoGetFacts)
	nPSerie		:= GdFieldPos("RSE_SERIE",	 aHoGetFacts)
	nPNota		:= GdFieldPos("RSE_FACT",	 aHoGetFacts)
	nPCond		:= GdFieldPos("RSE_CONPGO",	 aHoGetFacts)
	nPEmissao	:= GdFieldPos("RSE_EMISIO",	 aHoGetFacts)

	nPosTip		:= GdFieldPos( "RSE_TIPO" ,  aHoGetFacts)
	nDelFact	:= GdFieldPos("GDDELETED",   aHoGetFacts)
	nPosSta		:= GdFieldPos( "RSE_EXTFAC", aHoGetFacts) //Extraccion de factura


if lAutoTeste
	nNoGetFacts:=n
endif
If !aCoGetFacts[nNoGetFacts,nDelFact]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida campos obligatorios                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(aCoGetFacts[nNoGetFacts][nPNota]).Or. Empty(aCoGetFacts[nNoGetFacts][nPosFornec]) .Or. Empty(aCoGetFacts[nNoGetFacts][nPLoja]) .Or. Empty(aCoGetFacts[nNoGetFacts][nPCond]) .Or. Empty(aCoGetFacts[nNoGetFacts][nPEmissao])
			Help( " ", 1, STR0023,,STR0061, 1, 0 ) //"Aviso" ## "Verifique el contenido de los campos Numero de Factura, Fecha de emisión, Proveedor, Tienda y Condicioón de Pago!"
			lRetorno := .F.
		EndIf

		If lValidNFs
			If !LMT447Rec  //Si no es una rectificacion
				DBSelectArea("SD1")
				DBSetOrder(1)
				If dbSeek(xFilial("SD1")+aCoGetFacts[nNoGetFacts][nPNota]+aCoGetFacts[nNoGetFacts][nPSerie]+aCoGetFacts[nNoGetFacts][nPosFornec]+aCoGetFacts[nNoGetFacts][nPLoja])
					If aCoGetFacts[nNoGetFacts][nPosTip]=='1'
						If Empty(aCoGetFacts[nNoGetFacts,nPosSta])
							lBan := .T.
							If  !lX001Auto .and.  !lAutoTeste
								If !MsgYesNo(STR0062) //"La Factura y Proveedor ya existen en el archivo de facturas en compras. Si continua, la factura se cosiderará como una Extracción de Factura. ¿Desea continuar?"
									lBan := .F.
								EndIf
							EndIf
							If lBan
								aCoGetFacts[nNoGetFacts,nPosSta] := "EF"
								if !lAutoTeste
								cLeyen := STR0063  //" Extraccion de Factura. Adicione items por el botón de extracciones.."
								oLeyen:Refresh()
								endif
							Else
								aCoGetFacts[nNoGetFacts,nPosSta] := ""
								if !lAutoTeste
								cLeyen := ""
								oLeyen:Refresh()
								endif
								lRetorno := .F.
							EndIf
						EndIf
					Else
						aCoGetFacts[nNoGetFacts,nPosSta] := ""
						Help(" ",1,"EXISTNF")
						lRetorno := .F.
					EndIf
				Else
					aCoGetFacts[nNoGetFacts,nPosSta] := ""
				EndIf

				DBSelectArea("RSE")  //Valida el Num de Dcto no exista en RSE
				DBSetOrder(3) //RSE_FILIAL+RSE_FACT+RSE_SERIE+RSE_PROV+RSE_TDA
				If RSE->(dbSeek(xFilial("RSE")+aCoGetFacts[nNoGetFacts][nPNota]+aCoGetFacts[nNoGetFacts][nPSerie]+aCoGetFacts[nNoGetFacts][nPosFornec]+aCoGetFacts[nNoGetFacts][nPLoja]))
					IF RSE->RSE_NUMPED != aSvATela[1][1][2]
						Help(" ",1,"EXISTNF")
						lRetorno := .F.
					EndIf
				EndIf
			EndIf
	    	//Valida que en todo el getdado no existan factura repetidas
			For nX := 1 To Len(aCoGetFacts)
				If nX <> nNoGetFacts .And. !aCoGetFacts[nX,nDelFact]
					If aCoGetFacts[nX,nPNota]  == aCoGetFacts[nNoGetFacts,nPNota] .And. ;
							aCoGetFacts[nX,nPSerie]    ==  aCoGetFacts[nNoGetFacts,nPSerie] .And. ;
							aCoGetFacts[nX,nPosFornec] == aCoGetFacts[nNoGetFacts,nPosFornec] .And. ;
							aCoGetFacts[nX,nPLoja]     == aCoGetFacts[nNoGetFacts,nPLoja]

						Help(" ",1,"EXISTNF")
						lRetorno := .F.
					EndIf
				EndIf
			Next nX
		EndIf

		CpyResGetDad(.f.,"oGetFacts")//Restaura  GetDados
EndIf

CursorArrow()

Return(lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447TOk1  ³Autor ³     Gpe. Santacruz    ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacion de todo el Getdados del Encabezado de factura     ³±±
±±³          ³oGetFacts                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447TOk1()   			    				               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1- .T. Si correcto, .F. Si incorrecto                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447TOk1()

Local lRetorno:= .T.
Local nPDoc   := 0
Local nUsado  := 0
Local nX      := 0

CpyResGetDad(.T.,"oGetFacts")//Copia GetDados

nPDoc   := GdFieldPos( "RSE_FACT" , aHoGetFacts)

nUsado  := Len(aHoGetFacts)
lRetorno := MT447LoK1()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclui os itens nao informados                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nX := 1 To Len(aCoGetFacts)
	If ( Empty(aCoGetFacts[nX][nPDoc]) )
		aCoGetFacts[nX][nUsado+1] := .T.
	EndIf
Next nX

CpyResGetDad(.f.,"oGetFacts")//Copia GetDados

Return (lRetorno)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447DEL   ³Autor ³     Gpe. Santacruz    ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacion del borrado o activacion un renglon del  Getdados ³±±
±±³          ³del Encabezado de factura oGetFacts                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447DEL()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno.  				                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1- .T. Si correcto, .F. Si incorrecto                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447DEL()

	Local nPosDoc	:= 0
	Local nPItDoc	:= 0
	Local nDeleted	:= 0
	Local nX		:= 0
	Local nY		:= 0

	Local cItDoc	:= ""

	Local lExiste	:= .F.
	Local lBorrado	:= .T.

CpyResGetDad(.T.,"oGetFacts")//Copia GetDados

nPosDoc	:= GdFieldPos("RSE_ITEM", aHoGetFacts)
nDeleted:= GdFieldPos("GDDELETED",aHoGetFacts)
nPItDoc	:= GdFieldPos("RSF_ITEDOC",aHoGetItemF)


If aCoGetFacts[nNoGetFacts,nDeleted]
	lBorrado	:= .F.
	lP_Activa	:= .T.
Else
	lP_Activa	:= .F.
EndIf

cItDoc := aCoGetFacts[nNoGetFacts,nPosDoc]
For nx:=1 To Len(aColsIt)
		If (aScan(aColsIt[nx] , { |x| x[nPItDoc] == cItDoc } )) > 0
			lExiste := .T.
			For nY := 1 To Len(aColsIt[nX])
				aColsIt[nX,nY,Len(aHoGetItemF)+1] := lBorrado //Los borra o los activa segun sea el caso
			Next nY
			Exit

		EndIf
Next


Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447IniFis³Autor ³     Gpe. Santacruz    ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Se ejecuta al cambiar de renglon entre el getdados del       ³±±
±±³          ³   Encabezado de factura oGetFacts                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447IniFis()     		     			                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1- .T. Si correcto, .F. Si incorrecto                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447IniFis()

Local cValid     := ""
Local cRefCols   := ""

Local nPosFor	:= 0
Local nPosLoja	:= 0
Local nPosIted	:= 0
Local nPosItem	:= 0

Local nDelItm	:= 0

Local nPosInvoice	:= 0
Local nX	:= 0
Local nY	:= 0
Local nPos	:=	0

CpyResGetDad(.T.,"oGetFacts")//Copia GetDados
CpyResGetDad(.T.,"oGetItemF")//Copia GetDados


nPosFor		:= GdFieldPos("RSE_PROV"	, aHoGetFacts)
nPosLoja	:= GdFieldPos("RSE_TDA"		, aHoGetFacts)
nPosIted	:= GdFieldPos("RSE_ITEM"	, aHoGetFacts)
nPosItem	:= GdFieldPos("RSF_ITEDOC"	, aHoGetItemF)
nDelItm		:= GdFieldPos("GDDELETED"	, aHoGetItemF)

	If !Empty(aCoGetFacts[nNoGetFacts][nPosFor]) .And.!Empty(aCoGetFacts[nNoGetFacts][nPosLoja])

		MaFisEnd(.F.)

		MaFisIni(aCoGetFacts[nNoGetFacts][nPosFor],aCoGetFacts[nNoGetFacts][nPosLoja],"F","N",Nil,aRefImpos,,.T.)

		nPosInvoice := nNoGetFacts

		nPos := aScan(aColsIt,{|x| Trim(x[1,nPosItem])==AllTrim(aCoGetFacts[nPosInvoice, nPosIteD])  })

		If nPos > 0
			For nX := 1 To Len(aColsIt[nPos])

				MaFisIniLoad(nX,,.T.)
				For nY	:= 1 To Len(aHoGetItemF)
					cValid		:= AllTrim(Upper(aHoGetItemF[nY][6]))
					cRefCols	:= MaFisGetRf(cValid)[1]
					If !Empty(cRefCols) .And. MaFisFound("IT",nX)
						MaFisLoad(cRefCols,aColsIt[nPos][nX][nY],nX)
					EndIf
				Next nY
				MaFisEndLoad(nX,1)

				If aColsIt[nPos][nX][Len(aColsIt[nPos][nX])] //Si esta eliminado el item
					MaFisDel(nX, aColsIt[nPos][nX][Len(aColsIt[nPos][nX])] )
				EndIf
			Next nX
		EndIf
	Else
		MaFisEnd()
	EndIf
CpyResGetDad(.f.,"oGetFacts")//Restaura GetDados
CpyResGetDad(.f.,"oGetItemF")//Restaura GetDados
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447LOk2  ³Autor ³    Gpe. Santacruz     ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida el renglon del getdados de ITems de las facturas      ³±±
±±³          ³ oGetItemF                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447LOk2 ()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1- .T. Si correcto, .F. Si incorrecto                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447LOk2()

	Local lRetorno:= .T.
	Local nPItDoc := 0
	Local nCodPro := 0
	Local nQuant  := 0
	Local nUnit   := 0
	Local nTotal  := 0
	Local nPosTES := 0
	Local nPosIte := 0
	Local nPosLoc := 0
	Local nPosTip := 0
	Local nPosTipf:= 0

	Local nPosEF  := 0
	Local nPosFac := 0
	Local nPosSer := 0
	Local nPosPrv := 0
	Local nPosTda := 0
	Local nPosDoc := 0
	Local nPosNumPO  := 0

	Local nUsado  := 0
	Local nLin    := 0
	Local nj:=0

	If !lP_Activa
		Return .T.
	EndIf

CpyResGetDad(.T.,"oGetFacts")//Copia GetDados
CpyResGetDad(.T.,"oGetItemF")//Copia GetDados

nPItDoc := aScan(aHoGetItemF, {|x| AllTrim(x[2])=="RSF_ITEDOC" })
nCodPro := aScan(aHoGetItemF, {|x| AllTrim(x[2])=="RSF_PRODUC"})
nQuant  := aScan(aHoGetItemF, {|x| AllTrim(x[2])=="RSF_CANT" })
nUnit   := aScan(aHoGetItemF, {|x| AllTrim(x[2])=="RSF_PRECIO" })
nTotal  := aScan(aHoGetItemF, {|x| AllTrim(x[2])=="RSF_TOTAL" })
nPosTES := aScan(aHoGetItemF, {|x| AllTrim(x[2])=="RSF_TES"   })
nPosIte := aScan(aHoGetItemF, {|x| AllTrim(x[2])=="RSF_ITEM"   })
nPosLoc := aScan(aHoGetItemF, {|x| AllTrim(x[2])=="RSF_ALMACE"   })
nPosTip := aScan(aHoGetItemF, {|x| AllTrim(x[2])=="RSF_TIPO"   })
nPosTipf:= aScan(aHoGetFacts, {|x| AllTrim(x[2])=="RSE_TIPO"   })
nPosEF  := aScan(aHoGetFacts, {|x| AllTrim(x[2])=="RSE_EXTFAC"   })
nPosFac := aScan(aHoGetFacts, {|x| AllTrim(x[2])=="RSE_FACT"   })
nPosSer := aScan(aHoGetFacts, {|x| AllTrim(x[2])=="RSE_SERIE"   })
nPosPrv := aScan(aHoGetFacts, {|x| AllTrim(x[2])=="RSE_PROV"   })
nPosTda := aScan(aHoGetFacts, {|x| AllTrim(x[2])=="RSE_TDA"   })
nPosDoc := aScan(aHoGetFacts, {|x| AllTrim(x[2])=="RSE_ITEM"   })
nPosNumPO:= aScan(aHoGetItemF, {|x| AllTrim(x[2]) == "RSF_PEDIDO"})

nUsado  := Len(aHoGetItemF)
nLin    := nNoGetItemF //:nat

if !lAutoTeste
	//SI es una extraccion de factura, limita el numero de items para que por getdados no agregue mas items, solo por el boton de extraccion
	If  aCoGetFacts[nNoGetFacts,nPosEF] == "EF"
		oGetItemF:NMAX := 0
	Else
		oGetItemF:NMAX := 999
	EndIf
endif

	If ( !aCoGetItemF[nLin][nUsado+1] )
		If !lProdDup
			for nj:=1 to len(aCoGetItemF) //No permite repetir codigo de producto
			    if nj<>nLin .and. !aCoGetItemF[nj][nUsado+1]
					if aCoGetItemF[nNoGetItemF,nCodPro]==aCoGetItemF[nj,nCodPro]
						Help( " ", 1, STR0023,,  STR0160, 1, 0 )  //"Codigo de producto ya existe"
						lRetorno := .F.
					endif
				endif
			next
		EndIf

		If aCoGetFacts[nNoGetFacts,nPostipF] == "1" .And. aCoGetItemF[nLin,nPostip] <> '1'

			Help( " ", 1, STR0023,, STR0064, 1, 0 )  //"Help",, "La factura es de mercancia y solo puede insertar items del mismo tipo!"
			lRetorno := .F.
		EndIf

		If aCoGetFacts[nNoGetFacts,nPostipF]$"23" .And. aCoGetItemF[nLin,nPostip] == '1'

			Help( " ", 1, STR0023,, STR0065, 1, 0 ) 	//"Help",, "La Factura es de Gastos y no debe insertar items con tipo Mercancia."
			lRetorno := .F.
		EndIf

		If aCoGetFacts[nNoGetFacts,nPostip] $ "2" .And. cVar $ '2349' //Si factura de gastos nacionales y el item no es alguno de gastos nacional

			Help( " ", 1, STR0023,, STR0066, 1, 0 ) //"Help",,"La Factura es de Gastos Nacionales."
			lRetorno := .F.
		EndIf

		If aCoGetFacts[nNoGetFacts,nPostip] $ "3" .And. cVar $ '5678' //Si factura de gastos extranjeros y el item no es alguno de gastos extranjero

			Help( " ", 1, STR0023,, STR0067, 1, 0 )  //"Help",, "La Factura es de Gastos Extranjeros."
			lRetorno := .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica si no hay Campos obligatorios vacios                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aCoGetItemF[nLin][nCodPro]) .And. (Empty(aCoGetItemF[nLin][nQuant]) .Or. Empty(aCoGetItemF[nLin][nUnit]) .Or. Empty(aCoGetItemF[nLin][nPosTes]))
			Help( " ", 1, STR0023,, STR0068, 1, 0 ) //"Help",,"Problema: Faltan datos que son obligatorios. Solución: Verifique el contenido de los campos Código de Producto, Cantidad, Precio y TES. "
			lRetorno := .F.
		EndIf

		If !empty(aCoGetItemF[nLin][nPosNumPO]) .and. empty(aCoGetFacts[nNoGetFacts,nPosEF]) //So tiene OP y no es extraccion de factura
				IF !MT447VLDCOC(aCoGetItemF[nLin][nQuant])
					lRetorno := .F.
				EndIf
		EndIf

		If !Empty(aCoGetItemF[nLin][nQuant]) .And. !Empty(aCoGetItemF[nLin][nUnit]) .And. !Empty(aCoGetItemF[nLin][nTotal])
			If QtdComp(NoRound(aCoGetItemF[nLin][nTotal])) > QtdComp(NoRound(aCoGetItemF[nLin][nQuant] * aCoGetItemF[nLin][nUnit]))+0.49 .Or.;
					QtdComp(NoRound(aCoGetItemF[nLin][nTotal])) < QtdComp(NoRound(aCoGetItemF[nLin][nQuant] * aCoGetItemF[nLin][nUnit]))-0.49
				Help(" ",1,STR0069) //"TOTAL"
				lRetorno := .F.
			EndIf
		EndIf

		If Empty(aCoGetItemF[nLin,nPosLoc]) .And. aCoGetItemF[nLin,nPosTip]=='1' .And.    !Empty(aCoGetItemF[nLin,nCodPro])
			Help( " ", 1, STR0023,,STR0070, 1, 0 ) //"Aviso",,"Si el tipo de Item es Mercancia, debe registrar un almacen"
			lRetorno:= .F.
		EndIf

		If !Empty(aCoGetItemF[nLin,nPosLoc]) .And. aCoGetItemF[nLin,nPosTip]<>'1'	//Limpia el almacen si el tipo no es Mercancia
			aCoGetItemF[nLin,nPosLoc]:=space(TAMSX3("RSF_ALMACE")[1])
		EndIf

		If aCoGetFacts[nNoGetFacts,nPosEF] == "EF" .And. !Empty(AllTrim(aCoGetItemF[nLin,nCodPro]))    //extraccion de factura
			SD1->(DBSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			If !SD1->(DBSeek(SD1->(xFilial("SD1")+ aCoGetFacts[nNoGetFacts,nPosFac]+aCoGetFacts[nNoGetFacts,nPosser]+aCoGetFacts[nNoGetFacts,nPosPrv]+aCoGetFacts[nNoGetFacts,nPosTda]+aCoGetItemF[nLin,nCodPro]+aCoGetItemF[nLin,nPosIte]	)))

				Help( " ", 1, STR0056,, STR0071, 1, 0 ) //"Help",, "El Ítem y el Producto no existen en la Factura original."
				lretorno:= .F.
			EndIf
		EndIf

		If nPItDoc != 0 .And. nLin > 1
			If Empty(aCoGetItemF[nLin,nPItDoc])
				If nPosDoc > 0
					If !lAutoTeste
						oGetItemF:aCols[nLin,nPItDoc] := oGetFacts:aCols[nNoGetFact][nPosDoc]
					Else
						aCoGetItemF[nLin,nPItDoc] :=  aCoGetItemF[nNoGetFact,nPosDoc]
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf



Return (lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447TOk2  ³Autor ³   Gpe. Santacruz      ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida todo el Getdados de los  Items de las facturas        ³±±
±±³          ³ oGetItemF                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447TOk2()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1- .T. Si correcto, .F. Si incorrecto                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447TOk2()

	Local nPosIt2	:= 0
	Local nPosItD	:= 0
	Local nX		:= 0
	Local nSave		:= 0
	Local lRetorno	:= .T.
	Local nPosTES	:= 0
	Local nPosTipf	:= 0
	Local cTES		:= ''
	Local lVez		:= .F.
	Local nUsado	:= 0

CpyResGetDad(.T.,"oGetFacts")
CpyResGetDad(.T.,"oGetItemF")


nPosIt2	:= aScan(aHoGetItemF, {|x| AllTrim(x[2]) == "RSF_ITEDOC"})
nPosItD	:= aScan(aHoGetFacts, {|x| AllTrim(x[2]) == "RSE_ITEM"})
nSave	:= nNoGetItemF
nPosTES	:= aScan(aHoGetItemF, {|x| AllTrim(x[2]) == "RSF_TES"})
nPosTipf:= aScan(aHoGetFacts, {|x| AllTrim(x[2]) == "RSE_TIPO"})
nUsado	:= Len(aHoGetItemF)

	If !lP_Activa
		Return .T.
	EndIf

	If oFoldMT447:nOption == 6

		For nX := 1 To Len(aCoGetItemF)
			N := nX
			If !(lRetorno:=MT447LOk2())
				Exit
			EndIf
		Next nX
		N := nSave

		//Verifica que no se repita la TES para facturas de gastos
		If 	aCoGetFacts[nNoGetFacts,nPosTipf]<>'1'
			lVez:=.F.
			For nX := 1 To Len(aCoGetItemF)
				If ( !aCoGetItemF[nX][nUsado+1] )
					If !lVez
						cTES:=aCoGetItemF[NX,nPosTES]
						lVez:=.T.

					EndIf
				EndIf
			Next nX
		EndIf
		If lRetorno .And. norigem<>0
			nPosIt:=aScan(aColsIt,{|x| Trim(x[1,nPosIt2])==	aCoGetFacts[norigem,nPosItD]})
			If nPosit == 0
				aColsIt[Len(aColsIt)] := aClone(aCoGetItemF)
			Else
				aColsIt[nPosIt] := aClone(aCoGetItemF)
			EndIf
		EndIf
	EndIf

Return(lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447DEL2  ³Autor ³ Gpe. Santacruz        ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida al eliminar un renglon de Items de las facturas       ³±±
±±³          ³ oGetItemF                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447DEL2 ()      			    		                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1- .T. Si correcto, .F. Si incorrecto                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447DEL2()

Local lBorro := .F.
local nDeleted := GdFieldPos("GDDELETED",aHoGetItemF)

CpyResGetDad(.t.,"oGetFacts")
CpyResGetDad(.t.,"oGetItemF")

If !MaFisFound("IT",nNoGetItemF)
	MaFisAdd("","",0,0,0,"","",,0,0,0,0,0)
EndIf

lBorro := If (!aCoGetItemF[nNoGetItemF,nDeleted],.T.,.F.)

MaFisDel(nNoGetItemF,lBorro)

aCoGetItemF[nNoGetItemF,nDeleted] := IIF (lBorro,.T.,.F.)

CpyResGetDad(.f.,"oGetFacts")
CpyResGetDad(.f.,"oGetItemF")
Eval(bRefresh)


Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447LOkRSK ³Autor³     Gpe Santacruz.    ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida el renglon del getdados de Incrementables             ³±±
±±³          ³ oGetIncrem                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447LOkRSK()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno.  				                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1- .T. Si correcto, .F. Si incorrecto                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447LOkRSK()
	Local lRet := .T.
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447TOkRSK³Autor ³     Gpe Santacruz.    ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida todl el getdados de Incrementables                    ³±±
±±³          ³ oGetIncrem                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447TOkRSK()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno.  				                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1- .T. Si correcto, .F. Si incorrecto                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447TOkRSK()
	Local lRet := MT447LOkRSK()
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447TOk5  ³Autor ³    Gpe Santacruz.     ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida el getdatos de Impuestos a Nivel pedimento            ³±±
±±³          ³ oGetImpPed                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447TOk5()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno.  				                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1- .T. Si correcto, .F. Si incorrecto                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447TOk5()
	Local lRet := MT447LOk5()
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447LOk5  ³Autor ³    Gpe Santacruz.     ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida el renglon del getdatos de Impuestos a Nivel pedimento³±±
±±³          ³ oGetImpPed                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447LOk5()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1- .T. Si correcto, .F. Si incorrecto                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447LOk5()

	Local lRet     := .T.
	Local nPos     := 0
	Local nPosAct  := 0

	Local nDeleted := 0
	Local nPosImp  := 0

CpyResGetDad(.t.,"oGetImpPed")
if !lAutoTeste
	nPosAct  := nNoGetImpPed
else
	nPosAct  := N
endif
nDeleted := GdFieldPos("GDDELETED" ,aHoGetImpPed)
nPosImp  := GdFieldPos("RSD_CODIMP",aHoGetImpPed)


	For npos := 1 To Len(aCoGetImpPed)
		If !aCoGetImpPed[nPos,nDeleted]
			If nPosAct <> nPos
				If aCoGetImpPed[nPos,nPosImp]==aCoGetImpPed[nPosAct,nPosImp] //quitar .And. !aCoGetImpPed[nPosAct,nDeleted]
					Help( " ", 1, STR0056,, STR0073, 1, 0 )  //"Help",, "No debe repetirse el Código de Impuesto."
					lRet := .F.
				EndIf
			EndIf
		EndIf
	Next

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447WhenFol³Autor³     Gpe Santacruz.    ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida la previa edicion de cada folder                     ³±±
±±³          ³ oFoldMT447:BWHEN, para las extracciones algunos deben ser de³±±
±±³          ³ solo lectura.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447WhenFol()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExp1.- Numero de folder                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1- .T.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MT447WhenFol(nFldAtu)

	If LMT447Ext
		If nFldatu == 2 .Or. nFldatu == 3
			oFoldMT447:ADIALOGS[nFldAtu]:LREADONLY := .T.
		EndIf
	EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MT447Folder³ Autor ³ Gpe Santacruz           ³Data  ³10/09/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de Tratamento dos Folders                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Folder de Destino                                      ³±±
±±³          ³ExpN2: Folder Atual                                           ³±±
±±³          ³ExpO3: Objeto do Folder                                       ³±±
±±³          ³ExpA4: Array com as getdados.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM Internacional Processo de Importacao de Produtos     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MT447Folder(nFldDst,nFldAtu,oFldInv,aGetDad,nopc)

	Local lRetorno:= .T.
	Local lFldDesp:= .T.

	Local nPosIt1 :=0
	Local nPosCF  :=0
	Local nPosLoj := 0
	Local nDeleted:= 0
	Local nPosTipo:= 0

	Local nPosIt2 := 0
	Local nPosIte := 0
	Local nPosDesc:= 0
	Local nPosFac := 0
	Local nPosSer := 0
	Local nPosEF  := 0
	Local nx      := 0
	Local nY      := 1
CURSORWAIT()
CpyResGetDad(.t.,"oGetFacts")
CpyResGetDad(.t.,"oGetItemF")

nPosIt1 := GdFieldPos("RSE_ITEM"		, aHoGetFacts)
nPosCF  := GdFieldPos("RSE_PROV"		, aHoGetFacts)
nPosLoj := GdFieldPos("RSE_TDA"			, aHoGetFacts)
nDeleted:= GdFieldPos("GDDELETED"		, aHoGetFacts)
nPosTipo:= GdFieldPos("RSE_TIPO"		, aHoGetFacts)

nPosIt2 := GdFieldPos("RSF_ITEDOC"		, aHoGetItemF)
nPosIte := GdFieldPos("RSF_ITEM"		, aHoGetItemF)
nPosDesc:= GdFieldPos("RSF_DESC"		, aHoGetItemF)
nPosFac := GdFieldPos("RSE_FACT"		, aHoGetFacts)
nPosSer := GdFieldPos("RSE_SERIE"		, aHoGetFacts)
nPosEF  := GdFieldPos("RSE_EXTFAC"		, aHoGetFacts)

	If nFldDst == 6
		//SI es una extraccion de factura, limita el numero de items para que por getdados no agregue mas items, solo por el boton de extraccion
		If  aCoGetFacts[nNoGetFacts,nPosEF] =="EF"
			cLeyen := STR0063 //" Extraccion de Factura. Adicione items por el botón de extracciones.."
		Else
			cLeyen := ""
		EndIf
		if !lAutoTeste
			oLeyen:Refresh()
		endif
	Else
		cLeyen := ""
	EndIf
	if !lAutoTeste
		oLeyen:Refresh()
	endif

	If  nFldATU == 5  //Si es folder de Encabezado de factura
		If !Empty(aCoGetFacts[nNoGetFacts ,nPosfac]) .And.;
				!Empty(aCoGetFacts[nNoGetFacts ,nPosCF]) .And. !aCoGetFacts[nNoGetFacts ,nDeleted]
			lP_Activa:= .T.
		Else
			lP_Activa:= .F.
		EndIf
	EndIf

	If !lP_Activa .And. nFldDst == 6
		Help( " ", 1, STR0056,, STR0075, 1, 0 )  //"Help",, "Debe seleccionar primero una factura, antes de seleccionar el folder de items"
		Return .F.
	EndIf

	If nFldAtu == 1   //Si esta saliendo del folder de Registro, valida los campos del mismo
		If !obrigatorio(aSvAGets[1],aSvATela[1])
			lRetorno := .F.
		EndIf
	EndIf

	If nFldAtu == 2 //Si esta saliendo del folder de Transportista, valida los campos del mismo
		If !obrigatorio(	aSvAGets[2],	aSvATela[2])
			lRetorno := .F.
		EndIf
	EndIf

	If nFldAtu > 3 .And. nFldAtu < 7//Si esta saliendo de algun folder que usa GetDados, valida que todo sea correcto antes de salir
		If  !aGetDad[nFldAtu]:TudoOk()
			lRetorno:=.F.
		Else
			If nFldAtu == 6
				MT447Refresh()
			EndIf
		EndIf
	EndIf

	If  nFldDst == 5 .And. lRetorno //Si es folder de Encabezado de factura
		If !Empty(aCoGetFacts[nNoGetFacts ,nPosfac]) .And.;
				!Empty(aCoGetFacts[nNoGetFacts ,nPosCF]) .And. !aCoGetFacts[nNoGetFacts ,nDeleted]
			lP_Activa := .T.
		EndIf
	EndIf

	If nFldAtu == 6 //Si sale del folder de Item de facturas desactiva la tecla F9
		SetKey(VK_F9,{ || .T. })  //desactiva tecla F9
		/*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Elimina los impuestos que ya no esten relacionados a la factura³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/
		If LUSORSG
			aRec := {}
			If TMPRSG->(DBSeek(aCoGetFacts[nNoGetFacts ,nPosFac]+aCoGetFacts[nNoGetFacts ,nPosser]+aCoGetFacts[nNoGetFacts ,nPosCF]+aCoGetFacts[nNoGetFacts ,nPosLoj]))
				Do While !TMPRSG->(Eof()) .And. aCoGetFacts[nNoGetFacts ,nPosFac]+aCoGetFacts[nNoGetFacts ,nPosser]+aCoGetFacts[nNoGetFacts ,nPosCF]+aCoGetFacts[nNoGetFacts ,nPosLoj]==TMPRSG->RSG_FACT+TMPRSG->RSG_SERIE+TMPRSG->RSG_PROV+TMPRSG->RSG_TDA
					If aScan(aCoGetItemF,{|x| x[NPOSITE] == TMPRSG->RSG_ITEM  })==0
						aAdd( aRec , TMPRSG->(Recno()) )
					EndIf
					TMPRSG->(DBSkip())
				EndDo
			EndIf
			aRec2 := {}
			For nx := 1 To Len(aRec)
				TMPRSG->(DbGoTo(aRec[nx]))
				If !TMPRSG->(Eof())
					If TMPRSH->(DBSeek(aCoGetFacts[nNoGetFacts ,nPosFac]+aCoGetFacts[nNoGetFacts ,nPosser]+aCoGetFacts[nNoGetFacts ,nPosCF]+aCoGetFacts[nNoGetFacts ,nPosLOJ]+TMPRSG->RSG_ITEM))
						aAdd(aRec2,TMPRSH->(Recno()))
					EndIf
					RecLock("TMPRSG",.F.)
					TMPRSG->(DBDelete())
					TMPRSG->(MSUnlock())
				EndIf
			Next
			For nx := 1 To Len(aRec2)
				TMPRSH->(DbGoTo(aRec2[nx]))
				If !TMPRSH->(Eof())
					RecLock("TMPRSH",.F.)
					TMPRSH->(DBDelete())
					TMPRSH->(MSUnlock())
				EndIf
			Next
		EndIf
	EndIf

	If lRetorno
		//Validaciones sobre folders de Items de Facturas (5) y Encabezad de factura (5)
		If (nFldAtu == 5 .And. nFldDst == 6) .Or. (nFldAtu == 6 .And. nFldDst == 5) .Or. nFldDst == 6 //210912

			Do Case
			Case ( nFldAtu == 6 )//Folder de items
				lEditaDesp	:= .F.
				nPosIt		:= aScan(aColsIt,{|x| Trim(x[1,nPosIt2])==	aCoGetFacts[nNoGetFacts,nPosIt1]})
				If nPosIt == 0
					aColsIt[Len(aColsIt)] := aClone(aCoGetItemF)
				Else
					If lP_Activa
						aColsIt[nPosIt] := aClone(aCoGetItemF)
					EndIf
				EndIf
			Case ( nFldAtu == 5 )//folder de encabezados de facturas
				lEditaItem := .T.
			EndCase
			Do Case
			Case ( nFldDst == 6 )
				If aCoGetFacts[nNoGetFacts ,nPosTipo]	=="1" .And. !aCoGetFacts[nNoGetFacts ,nDeleted] //Si es factura de Mercancia
					if !lAutoTeste
						SetKey( VK_F9	, bDatosImportacion)
					endif
				EndIf

				nPosFac		:= GdFieldPos( "RSE_FACT"	, aHoGetFacts)
				nPosSer		:= GdFieldPos( "RSE_SERIE"	, aHoGetFacts)

				cFactItem	:= aCoGetFacts[nNoGetFacts, nPosfac]
				cSeriItem	:= aCoGetFacts[nNoGetFacts, nPosSer]
				cPrvItem	:= aCoGetFacts[nNoGetFacts, nPosCF]
				cTdaItem	:= aCoGetFacts[nNoGetFacts, nPosLoj]

				SA2->(DBSetOrder(1))
				If SA2->(DBSeek(xFilial("SA2")+cPrvItem+cTdaItem))
					cNomPItem := SA2->A2_NOME
				Else
					cNomPItem := space(TAMSX3("A2_NOME")[1])
				EndIf
				if !lAutoTeste
					oSeriItem:Refresh()
					oFactItem:Refresh()
					oPrvItem:Refresh()
					oTdaItem:Refresh()
					oNomProv:Refresh()

					oFoldMT447:ADIALOGS[nFldDst]:LREADONLY := .F.

					aGetdad[6]:aAlter := aAlterRSF
					aGetdad[6]:oBrowse:aAlter := aAlterRSF
					aGetdad[6]:nMax := 900
				endif
				If !MaFisFound("NF")
					If !Empty(aCoGetFacts[nNoGetFacts][nPosCF]) .And. !Empty(aCoGetFacts[nNoGetFacts][nPosLoj])
						MaFisIni(aCoGetFacts[nNoGetFacts][nPosCF],aCoGetFacts[nNoGetFacts][nPosLoj],"F","N",Nil,aRefImpos,,.T.)
					EndIf
				EndIf
				nPos := aScan(aColsIt,{|x| Trim(x[1,nPosIt2]) == AllTrim(aCoGetFacts[nNoGetFacts, nPosIt1])  })
				If nPos == 0
					aAdd(aColsIt,{Array(Len(aHoGetItemF) + 1)})
					DBSelectArea("RSF")
					For nY := 1 To Len(aHoGetItemF)
						If IsHeadRec(aHoGetItemF[nY][2])
							aColsIt[Len(aColsIt)][1][nY] := 0
						ElseIf IsHeadAlias(aHoGetItemF[nY][2])
							aColsIt[Len(aColsIt)][1][nY] := "RSF"
						ElseIf Trim(aHoGetItemF[nY][2]) == "RSF_ITDOC"
							aColsIt[Len(aColsIt)][1][nY] := "001"
						ElseIf Trim(aHoGetItemF[nY][2]) == "RSF_ITEM"
							aColsIt[Len(aColsIt)][1][nY] := "0001"
						ElseIf Trim(aHoGetItemF[nY][2]) != "RSF_NUMPED"
							aColsIt[Len(aColsIt)][1][nY] := CriaVar(aHoGetItemF[nY][2])
						EndIf
						aColsIt[Len(aColsIt)][1][Len(aHoGetItemF)+1] := .F.
					Next nY
				EndIf
				cCliFor := aCoGetFacts[nNoGetFacts][nPosCF]
				cLoja   := aCoGetFacts[nNoGetFacts][nPosLoj]
				If npos == 0
					aCoGetItemF := aClone(aColsIt[Len(aColsIt)])
				Else
					aCoGetItemF := aClone(aColsIt[npos])
				EndIf
				aHeader := aClone(aHoGetItemF)
				aCoGetItemF[1][nPosIt2] := aCoGetFacts[nNoGetFacts][nPosIt1]

				CpyResGetDad(.f.,"oGetItemF")

				Iif(!lAutoTeste,oGetItemF:ForceRefresh(),)


			EndCase
			nOrigem := nNoGetFacts
			if (!lAutoTeste,aGetDad[nFldDst]:oBrowse:Refresh(.T.),)
			CpyResGetDad(.f.,"oGetFacts")
		EndIf
	EndIf
CURSORARROW()
Return (lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447TudOk ³Autor ³   Gpe Santacruz.      ³ Data ³           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida todo el getdados de las facturas (encabezado/items)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447TudOk(nExp1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExp1.- Numero de opcion                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1- .T. Correcto .F. Falso                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447TudOk(nOpc)

Local lRet	:= .T.
Local lAtT	:= IsBlind()

if !lAtT
	If oFoldMT447:nOption == 5
		lRet := MT447TOk1()
	elseif  oFoldMT447:nOption == 6
		lRet := MT447TOk2()
	EndIf
	If lRet
		If (nopc == 3 .Or. nOpc == 4)
			lRet := VldFactItem(nopc)
		EndIf
	EndIf
endif
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MT447SegUm³ Autor ³Gpe. Santacruz         ³Data  ³08/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Trata UM y segunda UM                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447SegUm()

	Local lMudou	:= .F.

	Local cVarCod	:= ""
	Local cVarQtd	:= ""
	Local cVarQtd2	:= ""
	Local cVarTotal	:= ""
	Local cProduto	:= ""
	Local cCampo	:= Alltrim(ReadVar())
	Local cAlias	:= Alias()

	Local nOrder	:= IndexOrd()
	Local nRecno	:= Recno()
	Local nOrdSB1	:= SB1->(IndexOrd()),nRecSB1:=SB1->(Recno())
	Local nValQDa	:= 0 // quantidade anterior - Calculo do Desconto Devolucao
	Local nValQDb	:= 0 // quantidade atual    - Calculo do Desconto Devolucao
	Local nPosCod	:= 0
	Local nPosQtd	:= 0
	Local nPosQtd2	:= 0
	Local nPosTotal	:= 0
	Local nPosDesc	:= 0
	Local nQuant	:= 0
	Local nX		:= 0

iIf (lX001Auto,nNoGetItemF := n,)

	For nX := 1 To Len(aHoGetItemF)
		If Trim(SubSTR(aHoGetItemF[nX][2],4)) == "_PRODUC"
			nPosCod   := nX
			cVarCod   := "M->"+AllTrim(aHoGetItemF[nX][2])
		ElseIf Trim(SubSTR(aHoGetItemF[nX][2],4)) == "_CANT"
			nPosQtd   := nX
			cVarQtd   := "M->"+AllTrim(aHoGetItemF[nX][2])
		ElseIf Trim(SubSTR(aHoGetItemF[nX][2],4)) == "_CANUM2"
			nPosQtd2  := nX
			cVarQtd2  := "M->"+AllTrim(aHoGetItemF[nX][2])
		ElseIf Trim(SubSTR(aHoGetItemF[nX][2],4)) == "_TOTAL"
			nPosTotal := nX
			cVarTotal := "M->"+AllTrim(aHoGetItemF[nX][2])
		ElseIf Trim(SubSTR(aHoGetItemF[nX][2],4)) == "_VLDESC"
			nPosDesc := nX
		EndIf
		// Caso j  achou todos, abandona o Loop
		If nPosCod > 0 .And. nPosQtd > 0 .And. nPosQtd2 > 0 .And. nPosTotal > 0 .And. nPosDesc > 0
			Exit
		EndIf
	Next nX

	// Caso esteja no codigo do produto, obtem o produto
	If cCampo == cVarCod
		cProduto := &(ReadVar())
	Else
		nQuant := &(ReadVar())
		cProduto := aCoGetItemF[nNoGetItemF][nPosCod]
	EndIf

	DBSelectArea("SB1")
	DBSetOrder(1)
	If dbSeek(xFilial("SB1")+cProduto)
		// Altera campo da Quantidade na Segunda UM
		If cCampo == cVarQtd
			If nPosQtd2 > 0
				nValQDa := aCoGetItemF[nNoGetItemF][nPosQtd]
				aCoGetItemF[nNoGetItemF][nPosQtd2] := ConvUm(SB1->B1_COD,nQuant,aCoGetItemF[nNoGetItemF][nPosQtd2],2)
				nValQDb := &(ReadVar())
				&(cVarQtd2) := aCoGetItemF[nNoGetItemF][nPosQtd2]
				lMudou := .T.
			EndIf
		// Altera campo da Quantidade na Primeira UM
		ElseIf cCampo == cVarQtd2
			If nPosQtd > 0 .And. (&(cVarQtd2) # aCoGetItemF[nNoGetItemF][nPosQtd2])
				nValQDa   := aCoGetItemF[nNoGetItemF][nPosQtd]
				aCoGetItemF[nNoGetItemF][nPosQtd]:=	ConvUm(SB1->B1_COD,aCoGetItemF[nNoGetItemF][nPosQtd],nQuant,1)
				nValQDb   := aCoGetItemF[nNoGetItemF][nPosQtd]
				&(cVarQtd):= aCoGetItemF[nNoGetItemF][nPosQtd]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Tratamento para atualizacao do campo qtdsol no pedido de compra ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Right( AllTrim( ReadVar() ), 10 ) == "C7_QTSEGUM"
					If !Empty( GDFieldPos( "C7_QTDSOL" ) )
						A120QtdSol( aCoGetItemF[nNoGetItemF,nPosQtd] )
					EndIf
				EndIf
				lMudou:=.T.
			EndIf
		// Altera campo da Quantidade na Segunda UM ou na Primeira UM
		ElseIf cCampo == cVarCod
			If nPosQtd > 0 .And. nPosQtd2 > 0
				If !Empty(aCoGetItemF[nNoGetItemF][nPosQtd])
					aCoGetItemF[nNoGetItemF][nPosQtd2] := ConvUm(SB1->B1_COD,aCoGetItemF[nNoGetItemF][nPosQtd],aCoGetItemF[nNoGetItemF][nPosQtd2],2)
					&(cVarQtd2) := aCoGetItemF[nNoGetItemF][nPosQtd2]
				ElseIf !Empty(aCoGetItemF[nNoGetItemF][nPosQtd2])
					aCoGetItemF[nNoGetItemF][nPosQtd]:=	ConvUm(SB1->B1_COD,aCoGetItemF[nNoGetItemF][nPosQtd],aCoGetItemF[nNoGetItemF][nPosQtd2],1)
					&(cVarQtd) := aCoGetItemF[nNoGetItemF][nPosQtd]
					lMudou:=.T.
				EndIf
			EndIf
		EndIf
		// Zera total qdo mudou quantidade
		If lMudou .And. nPosTotal > 0
			aCoGetItemF[nNoGetItemF][nPosTotal] := 0
			&(cVarTotal) := 0
			If Type("cTipo") == "C"
				If nPosDesc > 0
					aCoGetItemF[nNoGetItemF][nPosDesc] := (aCoGetItemF[nNoGetItemF][nPosDesc]/nValQDa)*nValQDb
				EndIF
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Compatibilizacao com programas que utilizam a Funcao Fiscal  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If MaFisFound("IT",n)
				MaFisAlt("IT_QUANT",&(cVarQtd),n)
				MaFisAlt("IT_VALMERC",0,n)
				If nPosDesc > 0
					MaFisAlt("IT_DESCONTO",aCoGetItemF[n][nPosDesc],n)
				EndIf
			EndIf
		EndIf
	EndIf

	DBSelectArea(cAlias)
	DBSetOrder(nOrder)
	dbGoto(nRecno)
	SB1->(DBSetOrder(nOrdSB1))
	SB1->(dbGoto(nRecSB1))


Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MT447Produto³Autor³Alexandre Inacio Lemes ³ Data ³25/04/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do Produto digitado.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Codigo do Produto                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Dicionario de Dados - RSF_CODPRO                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447Produto(cProduto)

	Local aArea			:= GetArea()
	Local nPosDoc		:= 0
	Local nPosTipo		:= 0
	Local nPosItDoc		:= 0
	Local nPProduto		:= 0
	Local nPosUM		:= 0
	Local nPosSegum		:= 0
	Local nPosLocal		:= 0
	Local nPosDesc		:= 0
	Local nPosNumPO		:= 0
	Local nPosItemPO	:= 0
	Local nPosCC		:= 0
	Local nPosConta		:= 0
	Local nPosCLVL		:= 0
	Local nPosItCta		:= 0
	Local nPosTES		:= 0
	Local nScan			:= 0
	Local nPosQTD2      := aScan(aHoGetItemF, {|x| Alltrim(x[2]) == "RSF_CANUM2" })
	Local cFilEnt		:= ''
	Local lRet			:= .T.

CpyResGetDad(.t.,"oGetItemF")

nPosDoc		:= aScan(aHoGetFacts,{|x| AllTrim(x[2]) == "RSE_ITEM"  })
nPosTipo	:= aScan(aHoGetFacts,{|x| AllTrim(x[2]) == "RSE_TIPO"})
nPosItDoc	:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_ITEDOC" })
nPProduto	:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_PRODUC"})
nPosUM		:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_UM"    })
nPosSegum	:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_UM2" })
nPosLocal	:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_ALMACE" })
nPosDesc	:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_DESC"})
nPosNumPO	:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_PEDIDO"})
nPosItemPO	:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_ITEMPC"})
nPosCC		:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_CC"    })
nPosConta	:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_CONTA" })
nPosCLVL	:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_CLVL"  })
nPosItCta	:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_ITCTA" })
nPosTES		:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_TES"   })

IIf (lX001Auto,		nNoGetItemF := n,)

	DBSelectArea("SB1")
	DBSetOrder(1) //B1_FILIAL+B1_COD
	If MsSeek(xFilial("SB1")+cProduto,.F.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Registro esta Bloqueado.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If RegistroOk("SB1")

			nScan := nNoGetFacts //aScan(aCoGetFacts , { |x| x[Len(aHoGetFacts)+1] == .F. .And. x[nPosDoc]== aCoGetItemF[1][nPosItDoc] } )
            aCoGetItemF[nNoGetItemF][nPosQtd2] := 0 //Cantidad UM 2
           	aCoGetItemF[nNoGetItemF][nPosUM]    := SB1->B1_UM        // Unidade de medida
           	aCoGetItemF[nNoGetItemF][nPosSegum] := SB1->B1_SEGUM     // Segunda Unidade
			aCoGetItemF[nNoGetItemF][nPosDesc]  := SB1->B1_DESC      // Descricao do Produto

			If nScan > 0 .And. aCoGetFacts[nScan][nPosTipo] $ "1" // FOB // CIF

				If Empty(aCoGetItemF[nNoGetItemF][nPosNumPO]) .And. Empty(aCoGetItemF[nNoGetItemF][nPosItemPO])
					aCoGetItemF[nNoGetItemF][nPosLocal] := If(Empty(aCoGetItemF[nNoGetItemF][nPosLocal]), RetFldProd(SB1->B1_COD,"B1_LOCPAD"),aCoGetItemF[nNoGetItemF][nPosLocal] )
					aCoGetItemF[nNoGetItemF][nPosTES]   := If(Empty(aCoGetItemF[nNoGetItemF][nPosTES]),RetFldProd(SB1->B1_COD,"B1_TE"),aCoGetItemF[nNoGetItemF][nPosTES])

					If !Empty(aCoGetItemF[nNoGetItemF][nPosTES])
						MaFisAlt("IT_TES",aCols[nNoGetItemF][nPosTES],nNoGetItemF)
					EndIf

					If nPosCC <> 0 .And. nPosCLVL <> 0 .And. nPosConta <> 0 .And. nPosItCta <> 0
						aCoGetItemF[nNoGetItemF][nPosCC]    := If( Empty(aCoGetItemF[n][nPosCC])   , SB1->B1_CC    , aCoGetItemF[nNoGetItemF][nPosCC]   )
						aCoGetItemF[nNoGetItemF][nPosCLVL]  := If( Empty(aCoGetItemF[n][nPosCLVL]) , SB1->B1_CLVL  , aCoGetItemF[nNoGetItemF][nPosCLVL] )
						aCoGetItemF[nNoGetItemF][nPosConta] := If( Empty(aCoGetItemF[n][nPosConta]), SB1->B1_CONTA , aCoGetItemF[nNoGetItemF][nPosConta])
						aCoGetItemF[nNoGetItemF][nPosItCta] := If( Empty(aCoGetItemF[n][nPosItCta]), SB1->B1_ITEMCC, aCoGetItemF[nNoGetItemF][nPosItCta])
					EndIf

					MT447SegUm()
				Else
					SC7->(DBSetOrder(14)) //C7_FILENT+C7_NUM+C7_ITEM
					cFilEnt := xFilEnt(xFilial("SC7"))
					If SC7->(DBSeek(cFilEnt+aCoGetItemF[nNoGetItemF][nPosNumPO]+aCoGetItemF[nNoGetItemF][nPosItemPO]))
						If AllTrim(aCoGetItemF[nNoGetItemF,nPProduto])<>AllTrim(SC7->C7_PRODUTO)
							Help( " ", 1, STR0056,, STR0076, 1, 0 ) //"Help",, "Problema: Orden de compra erronea. Solución: Coloque el número de Orden de Compra que pertenece al Producto o Elimine la partida."
							lRet := .F.
						EndIf
					EndIf
				EndIf
			ElseIf nScan > 0 .And. aCoGetFacts[nScan][nPosTipo] $ "23" // Gastos
				aCoGetItemF[nNoGetItemF][nPosLocal] := If(Empty(aCoGetItemF[nNoGetItemF][nPosLocal]), RetFldProd(SB1->B1_COD,"B1_LOCPAD"),aCoGetItemF[nNoGetItemF][nPosLocal] )
				aCoGetItemF[nNoGetItemF][nPosTES]   := If(Empty(aCoGetItemF[nNoGetItemF][nPosTES]),RetFldProd(SB1->B1_COD,"B1_TE"),aCoGetItemF[nNoGetItemF][nPosTES])

				If !Empty(aCoGetItemF[nNoGetItemF][nPosTES])
					MaFisAlt("IT_TES",aCoGetItemF[nNoGetItemF][nPosTES],nNoGetItemF)
				EndIf
				MT447SegUm()
			EndIf
		Else
			lRet := .F.
		EndIf
	Else
		Help(" ",1,"REGNOIS")
		lRet := .F.
	EndIf

CpyResGetDad(.f.,"oGetItemF")
RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MT447Quant³ Autor ³Gpe Santacruz          ³ Data ³25/04/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da quantidade digitada.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Quantidade digitada                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Dicionario de Dados - RSF_CANT                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447Quant(nQuant)

	Local aArea		:= GetArea()
	Local nPosPrc	:= 0
	Local nPosTot	:= 0

	CpyResGetDad(.t.,"oGetItemF")
	nPosPrc	:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_PRECIO"})
	nPosTot	:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_TOTAL"})

	Iif (lX001Auto,		nNoGetItemF := n,)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza a quantidade da Segunda UM                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MT447SegUm()
	MaFisAlt("IT_VALMERC" , NoRound(aCoGetItemF[nNoGetItemF][nPosPrc] * M->RSF_CANT,TamSx3("RSF_TOTAL")[2]) , N )
	If lX001Auto .Or. !lAutoTeste
		aCoGetItemF[nNoGetItemF,nPosTot]:=NoRound(aCoGetItemF[nNoGetItemF][nPosPrc] * M->RSF_CANT,TamSx3("RSF_TOTAL")[2])
	EndIf

	CpyResGetDad(.f.,"oGetItemF")
	If !lAutoTeste
		ACOLS:= aclone(oGetItemF:aCols)
	Else
		ACOLS:= aclone(aCoGetItemF)
	EndIf
	RestArea(aArea)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MT447VLDFAC³ Autor ³Gpe. Santacruz         ³Data  ³05/12/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida que los datos del encabezado de la factura correspon³±±
±±³          ³ dan a los items.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MT447VLDFAC()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ X3_VALID de RSE_TDA, RSE_PROV, RSE_MONED, RSE_TIPO         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447VLDFAC()
Local lRetorno := .T.

Return (lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MT447Refresh³ Autor ³Gpe Sanatcruz         ³ Data ³14/03/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ejecuta el Refresh del Folder del encabezado de facturas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ningno                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Importaciones para Mexico                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447Refresh()

Local aArea      := GetArea()
Local nPosDesc   := 0

Local nPosVMer   := 0
Local nPosVBru   := 0

Local nPosItDoc  := 0
Local aResAcols	 :=aclone(Acols)

CpyResGetDad(.t.,"oGetFacts")
CpyResGetDad(.t.,"oGetItemF")

nPosDesc   := aScan(aHoGetFacts,{|x| Alltrim(x[2]) == "RSE_DESCTO"})
nPosVMer   := aScan(aHoGetFacts,{|x| Alltrim(x[2]) == "RSE_VALMER"})
nPosVBru   := aScan(aHoGetFacts,{|x| Alltrim(x[2]) == "RSE_VALBRU"})
nPosItDoc  := aScan(aHoGetItemF,{|x| Alltrim(x[2]) == "RSF_ITEDOC" })

if !lAutoTeste
	IF READVAR()=="M->RSE_DESCTO"
		oGetFacts:aCols[oGetFacts:nat][nPosDesc] :=M->RSE_DESCTO

		oGetFacts:aCols[oGetFacts:nat][nPosVBru] :=oGetFacts:aCols[oGetFacts:nat][nPosVMer]- oGetFacts:aCols[oGetFacts:nat][nPosDesc]

    ELSE
	    oGetFacts:aCols[oGetFacts:nat][nPosDesc] := MaFisRet(,"NF_DESCONTO")
		oGetFacts:aCols[oGetFacts:nat][nPosVMer] := MaFisRet(,"NF_VALMERC")
		oGetFacts:aCols[oGetFacts:nat][nPosVBru] := MaFisRet(,"NF_TOTAL")- MaFisRet(,"NF_DESCONTO")
	ENDIF
	oGetFacts:Refresh()
else
		aCols:=aclone(aCoGetFacts)//para usar dentro de las MAFIS
		aCoGetFacts[nNoGetFacts][nPosDesc] := MaFisRet(,"NF_DESCONTO")
		aCoGetFacts[nNoGetFacts][nPosVMer] := MaFisRet(,"NF_VALMERC")
		aCoGetFacts[nNoGetFacts][nPosVBru] := MaFisRet(,"NF_TOTAL")
		Acols:= aclone( aResAcols)
endif

RestArea(aArea)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MT447Trigger³ Autor ³Alexandre Inacio Leme ³ Data ³15/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Simula a validacao da GetDados para campos alterados pelo    ³±±
±±³          ³gatilho                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Campo alterado pelo gatilho                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Gatillo de RSF_CANT y  RSF_PRECIO                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447Trigger(cCampo)

	Local aArea		:= GetArea()
	Local aRefer	:= {}
	Local nPosCpo	:= 0
	Local lRetorno	:= .T.
	Local nPosFac	:= 0
	Local nPosSer	:= 0
	Local nPosPro	:= 0
	Local nPosTda	:= 0
	Local nPosIte	:= 0
	Local nPosTc	:= 0
	Local nPosUni	:= 0
	Local nPosUM1	:= 0
	Local nPosUM2	:= 0
	Local nPosCan1	:= 0
	Local nPosCan2	:= 0
	Local nPosfItD	:= 0
	Local nPosItD	:= 0
	Local cUmc		:= ''

	CpyResGetDad(.t.,"oGetFacts")
	CpyResGetDad(.t.,"oGetItemF")
	nPosCpo	:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == AllTrim(cCampo)})

	nPosfItD:= GdFieldPos("RSE_ITEM"  ,aHoGetFacts)
	nPosItD	:= GdFieldPos("RSF_ITEDOC",aHoGetItemF)

	If lX001Auto
			nNoGetItemF := n
			nPFac:=aScan(aCoGetFacts,{|x| x[nPosfItD] == aCoGetItemF[nNoGetItemF,nPosItD]})
			nNoGetFacts := nPFac
	EndIf
	If nPosCpo > 0
		aRefer := MaFisGetRF(aHoGetItemF[nPosCpo][6])
		If !Empty(aRefer[1])
			MaFisRef(aRefer[1],aRefer[2],aCoGetItemF[nNoGetItemF,nPosCpo])

			ModxAtuObj()

		EndIf
		//ACTUALIZA LA INFORMACION DE LAS FRACCIONES ARANCELARIA
		If lUsoRSG
			nPosFac := GdFieldPos("RSE_FACT",aHoGetFacts)
			nPosSer := GdFieldPos("RSE_SERIE",aHoGetFacts)
			nPosPro := GdFieldPos("RSE_PROV",aHoGetFacts)
			nPosTda := GdFieldPos("RSE_TDA",aHoGetFacts)
			nPosTc  := GdFieldPos("RSE_TC",aHoGetFacts)
			nPosIte := GdFieldPos("RSF_ITEM",aHoGetItemF)
			nPosPUNI:= GdFieldPos("RSF_PRECIO",aHoGetItemF)
			nPosUM1 := GdFieldPos("RSF_UM",aHoGetItemF)
			nPosUM2 := GdFieldPos("RSF_UM2",aHoGetItemF)
			nPosCan1:= GdFieldPos("RSF_CANT",aHoGetItemF)
			nPosCan2:= GdFieldPos("RSF_CANUM2",aHoGetItemF)
			nPosTot := GdFieldPos("RSF_TOTAL",aHoGetItemF)
			If lX001Auto
				nPFac := aScan(aCoGetFacts,{|x| x[nPosfItD] == aCoGetItemF[nNoGetItemF,nPosItD]})
				nNoGetFacts := nPFac
			EndIf

			If TMPRSG->(DBSeek(aCoGetFacts[nNoGetFacts,nPosFac]+aCoGetFacts[nNoGetFacts,nPosSer]+aCoGetFacts[nNoGetFacts,nPosPro]+aCoGetFacts[nNoGetFacts,nPosTda]+aCoGetItemF[nNoGetItemF,nPosIte]))
				RSB->(DBSetOrder(1))
				If RSB->(DBSeek(xFilial("RSB")+TMPRSG->RSG_FRACAR+TMPRSG->RSG_PAIVTA))

					cUmc := TMPRSG->RSG_UMC

					If cUmc == aCoGetItemF[nNoGetItemF,nPosUM1]
						TMPRSG->RSG_CANUMC := aCoGetItemF[nNoGetItemF,nPosCan1]
						TMPRSG->RSG_PRECIO := aCoGetItemF[nNoGetItemF,nPosPUNI]*aCoGetFacts[nNoGetFacts,nPostc]*M->RSC_TC
					Else
						If cUmc==aCoGetItemF[nNoGetItemF,nPosUM2]
							TMPRSG->RSG_CANUMC := aCoGetItemF[nNoGetItemF,nPosCan2]
							TMPRSG->RSG_PRECIO := Round((aCoGetItemF[nNoGetItemF,nPosTot]/aCoGetItemF[nNoGetItemF,nPosCan2]),5)*aCoGetFacts[nNoGetFacts,nPostc]*M->RSC_TC

						Else
							Help( " ", 1, STR0056,, STR0083, 1, 0 )  //"Help", "No hay unidad de medida para este producto, igual a la que maneja la fracción arancelaria que seleccionó, verifique si es correcto!"
							TMPRSG->RSG_CANUMC := 0
							TMPRSG->RSG_PRECIO := 0
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

	Else
		lRetorno := .F.
	EndIf

	RestArea(aArea)

Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447DATIMPOR³Autor ³    Gpe Santacruz.     ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pantalla de registro de fracciones arancelarias               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447DATIMPOR()	        			                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExp1.- Numero de opcion                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones para Mexico                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MT447DATIMPOR(nOpc)

	Local aArea     := GetArea()
	Local oItemImp
	Local oDlg2
	Local cAliasRSG := "RSG"
	Local cAliasRSH := "RSH"

	Local aHeadRSG  := {}
	Local aColsRSG  := {}
	Local aHeadRSH  := {}
	Local aColsRSH  := {}
	Local nOpcGet1  := 0
	Local nOpcGet2  := 0
	Local bGraba2   := {||If (MT447TOk3(),(ArrImpuesto("P",cFactItem,cSeriItem,cPrvItem,cTdaItem),oDlg2:End()),)}

	Local bCance2   := {|| oDlg2:End()}
	Local nx        := 0
	Local ny        := 0
	Local nPosIte2  := 0
	Local nPosprd2  := 0
	Local nPosDes2  := 0
	Local nUsado    := 0
	Local aPosResp  := {}
	Local nPosFraA  := 0
	Local aAreaSB1  := SB1->(GetArea())
	Local cFilSB1   := xFilial("SB1")
	Local lCodice   := (SB1->(ColumnPos("B1_CODICE")) > 0)	// Fracción arancelaria en productos

	Private	oGetIm1 //getdados de encabezado de impuestos
	Private	oGetIm2 //getdados de items de impuestos

	Private cItemIm1	:= ''
	Private cContIm1	:= ''
	Private oItemIm1	:= ''
	Private oContIm1	:= ''
	Private oPrdIm1
	Private cPrdIm1		:= ''
	Private oSecIm1
	Private cSecIm1		:= ''
	Private oFraIm1
	Private cFraIm1		:= ''

	Private oValAdu
	Private nValAdu		:= 0
	Private oValCom
	Private nValCom		:= 0

	lPVez := .T.
	If !MT447TOk2()
		MsgInfo(STR0084) //"Hay errores en los Items de la factura, corrija y vuelva a intentar con F9"
		Return
	EndIf

	If !LMT447EXT
		MT447CALCULO()
	Else
		CALCOSEXT()
	EndIf
	if !lAutoTeste
		SetKey(VK_F9,{ || .T. })  //desactiva tecla F9
	endif

	HeadAcols(cAliasRSG,@aHeadRSG,@aColsRSG,2)
	HeadAcols(cAliasRSH,@aHeadRSH,@aColsRSH,2)
	aResIm2:=aClone(aColsRSH)

	If nOpc == 3 .Or. nopc == 4
		nOpcGet1 := 2
		nOpcGet2 := 7

	EndIf

	nUsado		:= Len(aHeadRSG)

	nPosIte		:= GdFieldPos("RSG_ITEM"		, aHeadRSG)
	nPosprd		:= GdFieldPos("RSG_PRODUC"	, aHeadRSG)
	nPosDes		:= GdFieldPos("RSG_DESC"		, aHeadRSG)

	nPosIte2	:= GdFieldPos("RSF_ITEM"		, aHoGetItemF)
	nPosprd2	:= GdFieldPos("RSF_PRODUC"	, aHoGetItemF)
	nPosDes2	:= GdFieldPos("RSF_DESC"		, aHoGetItemF)
	nDeleted	:= GdFieldPos("GDDELETED"	, aHoGetItemF)

	nPosTC		:= GdFieldPos("RSE_TC"		, aHoGetFacts)
	nPosMon		:= GdFieldPos("RSE_MONED"	, aHoGetFacts)
	nPosTot		:= GdFieldPos("RSF_TOTAL"	, aHoGetItemF)
	nPosUM		:= GdFieldPos("RSF_UM"		, aHoGetItemF)
	nPosCan		:= GdFieldPos("RSF_CANT"	, aHoGetItemF)

	nPosVDol	:= GdFieldPos("RSG_DOLARE"	, aHeadRSG)
	nPosVCom	:= GdFieldPos("RSG_VALCOM"	, aHeadRSG)
	nPosVAdu	:= GdFieldPos("RSG_VALADU"	, aHeadRSG)
	nPosPre7	:= GdFieldPos("RSG_PRECIO"	, aHeadRSG)
	nPosFraA	:= GdFieldPos("RSG_FRACAR"	, aHeadRSG)

	aColsRSG	:= {}

	If lUsoRSG
		TMPRSG->(DBGoTop())
	EndIf

	aPosResp := {nPosIte,nPosPrd,nPosDes} //Columnas que no se tocaran si ya tenian guardada informaicon en tmpRSG

	SB1->(DBSetOrder(1))	// B1_FILIAL+B1_COD

	For nx := 1 To Len(aCoGetItemF)
		If !aCoGetItemF[nx,nDeleted]
			aAdd(aColsRSG,Array(nUsado+1))

			For ny := 1 To nUsado
				aColsRSG[Len(aColsRSG),ny] := CriaVar("RSG->"+aHeadRSG[ny,2],.T.)
			Next
			aColsRSG[Len(aColsRSG),nPosIte] := aCoGetItemF[nx,nPosIte2]
			aColsRSG[Len(aColsRSG),nPosPrd] := aCoGetItemF[nx,nPosPrd2]
			aColsRSG[Len(aColsRSG),nPosDes] := aCoGetItemF[nx,nPosDes2]
			aColsRSG[Len(aColsRSG)][nUsado+1] := .F.

			If lCodice
				If SB1->(dbSeek(cFilSB1+aCoGetItemF[nx,nPosPrd2]))
					aColsRSG[Len(aColsRSG),nPosFraA] := SB1->B1_CODICE
				EndIf
			EndIf

			If lUsoRSG //si ya hay informcion guardada de tmpRSG
				TMPRSG->(DBGoTop())
				If TMPRSG->(DBSeek(cFactItem+cSeriItem+cPrvItem+cTdaItem+aColsRSG[Len(aColsRSG),nPosIte]))
					For ny := 1 To nUsado
						If (aScan(aPosResp,{|x| x==ny}))==0
							aColsRSG[Len(aColsRSG),ny] := &("TMPRSG->"+aHeadRSG[nY,2])
						EndIf
					Next
				EndIf
			EndIf
		 	//totales para el aCols de encabezado de impuestos
			nValAdu += aColsRSG[Len(aColsRSG),nPosVAdu]
			nValCom += aColsRSG[Len(aColsRSG),nPosVCom]
		EndIf
	Next

	SB1->(RestArea(aAreaSB1))

	cItemIm1	:= aColsRSG[1,nPosIte]
	cPrdIm1		:= aColsRSG[1,nPosprd]
	cDesIm1		:= aColsRSG[1,nPosDes]
if !lAutoTeste
	DEFINE MSDIALOG oDlg2 TITLE STR0086 From 100,50 To 675,1200 of odlg PIXEL   //"Datos de Importacion por Item "

	oItemImp := tGroup():New(180,2,265,610,STR0087,oDlg2,,,.T.) //'Impuestos'

	//Items de Impuestos
	@ 17, 020 SAY  STR0039 SIZE  060,07 OF odlg2	PIXEL  //"Factura : "
	@ 17, 105 SAY  STR0040 SIZE  060,07 OF odlg2	PIXEL  //"Serie : "
	@ 17, 195 SAY  STR0041 SIZE  060,07 OF odlg2	PIXEL  //"Proveedor : "
	@ 17, 265 SAY  STR0042 SIZE  060,07 OF odlg2	PIXEL  //"Tienda : "

	@ 15, 045  GET	cFactItem 	when .F. OF odlg2	SIZE  050,06  PIXEL
	@ 15, 125  GET	cSeriItem	when .F. OF odlg2	SIZE  020,06  PIXEL
	@ 15, 225  GET	cPrvItem	when .F. OF odlg2	SIZE  030,06  PIXEL
	@ 15, 290  GET	cTdaItem	when .F. OF odlg2	SIZE  020,06  PIXEL
	@ 15, 312  GET	cNomPItem	when .F. OF odlg2	SIZE  100,06  PIXEL
	oGetIm1 := MsNewGetDados():New(30,3,165,570,nOpcGet1,"MT447LOk3()" ,"MT447TOk3()" ,Nil,Nil, 9, 999,"AllwaysTrue" ,;
									"AllwaysTrue","AllwaysTrue" ,  odlg2, aHeadRSG, aColsRSG)

	@ 170, 330 SAY STR0088 SIZE  060, 07 OF odlg2	PIXEL 	//"Valor Adu/Dls : "
	@ 170, 440 SAY STR0089 SIZE  060, 07 OF odlg2	PIXEL 	//"Valor Comercial : "
	@ 170, 370 GET oValAdu VAR nValAdu	picture "99,999,999" when .F. OF odlg2	SIZE  050,06  PIXEL
	@ 170, 485 GET oValCom VAR nValCom picture "99,999,999" when .F. OF odlg2	SIZE  050,06  PIXEL

	@ 189, 060 SAY  STR0090  SIZE  060,07    OF odlg2	PIXEL  //"Item : "
	@ 189, 135 SAY  STR0091  SIZE  060,07    OF odlg2	PIXEL  //"Producto : "
	@ 189, 330 SAY  STR0092  SIZE  060,07    OF odlg2	PIXEL 	//"Sección : "
	@ 189, 440 SAY  STR0093  SIZE  060,07    OF odlg2	PIXEL  // "Fracción : "

	@ 187, 075  GET   oItemIm1	VAR cItemIm1	when .F. OF odlg2	SIZE  030,06  PIXEL
	@ 187, 170  GET   oPrdIm1	VAR cPrdIm1	when .F. OF odlg2	SIZE  060,06  PIXEL
	@ 187, 230  GET   oDesIm1	VAR cDesIm1	when .F. OF odlg2	SIZE  090,06  PIXEL
	@ 187, 360  GET   oSecIm1	VAR cSecIm1	when .F. OF odlg2	SIZE  050,06  PIXEL
	@ 187, 475  GET   oFraIm1	VAR cFraIm1	when .F. OF odlg2	SIZE  050,06  PIXEL

	oGetIm2:= MsNewGetDados():New(203,3,260,570,nOpcGet2,"MT447LOk4()" ,"MT447TOk4()" ,Nil,Nil, 0, 999,"AllwaysTrue" ,;
									"AllwaysTrue","MT447DEL4()" ,  oItemImp, aHeadRSH, aColsRSH)

	oGetIm1:oBrowse:bChange := {|| MT447bChangeImp1(aColsRSH)}

	oGetIm2:oBrowse:lUseDefaultColors := .F.	//PERMITE EL USO DE COLOR
	oGetIm2:oBrowse:SetBlkBackColor({|| GETDCLR(oGetIm2:aCols,oGetIm2:Nat,oGetIm2:aHeader)})

	ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,bGraba2,bCance2)

	SetKey( VK_F9	, bDatosImportacion)
endif
RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447FRACAR³Autor ³      Gpe Santacruz.   ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacion del codigo de Fraccion arancelaria               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³ MT447FRACAR()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_VALID del campo RSG_FRACAR                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447FRACAR()

	Local nPosUM1	:= 0
	Local nPosUM2	:= 0
	Local nPosCan1	:= 0
	Local nPosCan2	:= 0
	Local nPosCUMC	:= 0
	Local nPosPre	:= 0
	Local nPosUMC	:= 0

	Local nPosPUNI	:= 0
	Local nPosVCom	:= 0
	Local nPosVAdu	:= 0
	Local nPosFrac	:= 0
	Local nPosPai	:= 0
	Local nPosTot	:= 0
	Local nPosTC	:= 0
	Local nPosIte   := 0
	Local nPosIte2  := 0
	Local nPosNIT   :=0

	Local nx	:= 0
	Local lRet	:= .T.

	Local cPais		:= ''
	Local cFracc	:= ''
	Local cUmc		:= ''
	Local nTamFrac:=TAMSX3("RSG_FRACAR")[1]

	Iif(lX001Auto,	nNoGetIm1 := n,)

	CpyResGetDad(.t.,"oGetItemF")
	CpyResGetDad(.t.,"oGetIm1")

	 nPosIte	:= GdFieldPos("RSF_ITEM"	, aHoGetItemF)
	 nPosUM1	:= GdFieldPos("RSF_UM"		, aHoGetItemF)
	 nPosUM2	:= GdFieldPos("RSF_UM2"		, aHoGetItemF)
	 nPosCan1	:= GdFieldPos("RSF_CANT"	, aHoGetItemF)
	 nPosCan2	:= GdFieldPos("RSF_CANUM2"	, aHoGetItemF)
	 nPosPUNI	:= GdFieldPos("RSF_PRECIO"	, aHoGetItemF)
	 nPosTot	:= GdFieldPos("RSF_TOTAL"	, aHoGetItemF)
	 nPosCUMC	:= GdFieldPos("RSG_CANUMC"	, aHoGetIm1)
	 nPosPre	:= GdFieldPos("RSG_PRECIO"	, aHoGetIm1)
	 nPosUMC	:= GdFieldPos("RSG_UMC"		, aHoGetIm1)
	 nPosIte2	:= GdFieldPos("RSG_ITEM"	, aHoGetIm1)
	 nPosVCom	:= GdFieldPos("RSG_VALCOM"	, aHoGetIm1)
	 nPosVAdu	:= GdFieldPos("RSG_VALADU"	, aHoGetIm1)
	 nPosFrac	:= GdFieldPos("RSG_FRACAR"	, aHoGetIm1)
	 nPosPai	:= GdFieldPos("RSG_PAIVTA"	, aHoGetIm1)

	 nPosTC		:= GdFieldPos("RSE_TC"		, aHoGetFacts) //Factor de coversion a dolares

	RSB->(DBSetOrder(1)) //RSB_FILIAL + RSB_FRACC + RSB_PAIS
	If READVAR() == "M->RSG_FRACAR"
		cFracc := &(readvar())
		If !Empty(cFracc)
			If !RSB->(DBSeek(xFilial("RSB")+cFracc   ))
				Help( " ", 1, STR0023,, STR0094+cFracc+"!", 1, 0 )  //"Aviso",, "No existe fraccion arancelaria:"
				Return .F.
			EndIf
		Else
			MT447Trig2("RSG_UMC","RSB->RSB_UMT") //Extrae el impuesto y coloca en el getdados inferior
		EndIf
		cPais	:= aCoGetIm1[nNoGetIm1,nPosPAI]
	Else
		If  READVAR()=="M->RSG_UMC"
			Cfracc	:= aCoGetIm1[nNoGetIm1,nPosFRAC]
			cPais	:= aCoGetIm1[nNoGetIm1,nPosPai]
		Else
			Cfracc	:= aCoGetIm1[nNoGetIm1,nPosFRAC]
			cPais	:= &(readvar())
		EndIf
	EndIf

	If Empty (Cfracc) .Or.  Empty(cPais)
		Return .T.
	EndIf

	If RSB->(DBSeek(xFilial("RSB")+cFracc+cPais))

		If  READVAR() == "M->RSG_UMC"
			aCoGetIm1[nNoGetIm1,nPosUMC] := &(readvar())
			cUmc := aCoGetIm1[nNoGetIm1,nPosUMC]
		Else
			aCoGetIm1[nNoGetIm1,nPosUMC] := RSB->RSB_UMT
			cUmc := RSB->RSB_UMT
		EndIf

        nPosNIT := aScan(aCoGetItemF,{|x| AllTrim(x[nPosIte]) == aCoGetIm1[nNoGetIm1,nPosIte2]})

		If cUmc == aCoGetItemF[nPosNIT,nPosUM1]
			aCoGetIm1[nNoGetIm1,nPosCUMC]	:= aCoGetItemF[nPosNIT,nPosCan1]
			aCoGetIm1[nNoGetIm1,nPosPre]	:= aCoGetItemF[nPosNIT,nPosPUNI]*aCoGetFacts[nNoGetFacts,nPostc]*M->RSC_TC
		Else
			If cUmc == aCoGetItemF[nPosNIT,nPosUM2]
				aCoGetIm1[nNoGetIm1,nPosCUMC] := aCoGetItemF[nPosNIT,nPosCan2]
				aCoGetIm1[nNoGetIm1,nPosPre]  := Round((aCoGetItemF[nPosNIT,nPosTot]/aCoGetItemF[nPosNIT,nPosCan2]),4)*aCoGetFacts[nNoGetFacts,nPostc]*M->RSC_TC
			Else
				Help( " ", 1, STR0056,, STR0083, 1, 0 ) //"Help",, "No hay unidad de medida para este producto, igual a la que maneja la fracción arancelaria que seleccionó, verifique si es correcto!"
				aCoGetIm1[nNoGetIm1,nPosCUMC] := 0
				aCoGetIm1[nNoGetIm1,nPosPre]  := 0
			EndIf
		EndIf
		ValorSecci(aCoGetIm1[nNoGetIm1,nPosPre], aCoGetIm1[nNoGetIm1,nPosCUMC])

		CpyResGetDad(.f.,"oGetIm1")

		if !lAutoTeste
			oGetIm1:Refresh()
		endif
		MT447Trig2("RSG_UMC","RSB->RSB_UMT") //Extrae el impuesto y coloca en el getdados inferior
	Else
		Help( " ", 1, STR0056,,STR0096, 1, 0 ) //"Help",, "No existe fracción arancelaria!"
		lRet := .F.
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ValorSecci ³Autor ³     Gpe Santacruz.    ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula el Importe aduana, Comercial y a pagar de la seccion³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³ValorSecci(nExp1,nExp2)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExp1.-Precio  nExp2.- Cantidad                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones Mexico                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ValorSecci(nPrecio,nCant)

Local nPosVDol	:= 0
Local nPosVCom	:= 0
Local nPosVAdu	:= 0
Local nx		:= 0

	CpyResGetDad(.t.,"oGetTot1")

	nPosVDol	:= GdFieldPos("RSG_DOLARE",aHoGetIm1)
	nPosVCom	:= GdFieldPos("RSG_VALCOM",aHoGetIm1)
	nPosVAdu	:= GdFieldPos("RSG_VALADU",aHoGetIm1)

	M->RSC_FACINC 	:= Round(aCoGetTot1[2,2]/aCoGetTot1[3,2],6)

	If lX001Auto .or.  lAutoTeste
		nNoGetIm1	:= n
	EndIf

	aCoGetIm1[nNoGetIm1,nPosVCom] := nPrecio*nCant	//Valor en mooneda nacional
	aCoGetIm1[nNoGetIm1,nPosVAdu] := aCoGetIm1[nNoGetIm1,nPosVCom]*M->RSC_FACINC	//Valor aduana  en moneda nacional
	aCoGetIm1[nNoGetIm1,nPosVDol] := aCoGetIm1[nNoGetIm1,nPosVAdu]/M->RSC_TC		//Valor en dolares del valor comercial
	//Refresca el total del pie de pagina
	nValAdu := 0
	nValCom := 0
	For nx := 1 To Len(aCoGetIm1)
		nValAdu += aCoGetIm1[nx,nPosVAdu]
		nValCom += aCoGetIm1[nx,nPosVCom]
	Next

	If !lX001Auto .and. !lAutoTeste
		oValAdu:Refresh()
		oValCom:Refresh()
	EndIf


Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447VALADU³Autor ³    Gpe Santacruz.     ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Para las Extracciones, a partir de la cantidad tecleadas,   ³±±
±±³          ³ calculara el valor aduana comercial y  en dolares           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447VALADU(nExp1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExp1.-1, Se detona al salir del campo RSG_CANUMC            ³±±
±±³          ³       2, Se detona al salir del campo RSG_PRECIO            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_VALID del campo RSG_CANUMC y RSG_PRECIO                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//SIN USO
Function MT447VALADU(nDe)

	Local nPosPre	:= 0
	Local nPosCUMC	:= 0
	Local nValor	:= &(readvar())

	If  lX001Auto .or.  lAutoTeste
		nNoGetIm1 := n
	EndIf

	CpyResGetDad(.t.,"oGetIm1")
	if !lAutoTeste

		nPosPre	:= GdFieldPos("RSG_PRECIO", aHoGetIm1)
		nPosCUMC:= GdFieldPos("RSG_CANUMC", oHGetIm1)
	endif

	If nDe == 1 //Cantidad
		ValorSecci(aCoGetIm1[nNoGetIm1, nPosPre], nValor)
	Else //Precio
		ValorSecci(nValor, aCoGetIm1[nNoGetIm1, nPosCUMC])
	EndIf
	CpyResGetDad(.f.,"oGetIm1")
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447bChangeImp1³   Gpe Santacruz.        ³ Data ³ 14/03/16   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Al salir o cambiar del renglon del getdados de Fracciones    ³±±
±±³          ³arancelarias, genera un nuevo elemento en el getdados inferior³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447bChangeImp1(aExp1)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aExp1.- aCols RSH                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MT447bChangeImp1(aColsRSH)

	Local lRet	:= .T.
	Local nx	:= 0
	Local ny	:= 0
	Local nz	:= 0

	Local nPosIte	:= 0
	Local nPosprd	:= 0
	Local nPosDes	:= 0
	Local nPosSec	:= 0
	Local nPosFra	:= 0

	Local nUsado	:= 0


	CpyResGetDad(.t.,"oGetIm1")
	CpyResGetDad(.t.,"oGetIm2")

	nPosIte	:= GdFieldPos("RSG_ITEM"	, aHoGetIm1)
	nPosprd	:= GdFieldPos("RSG_PRODUC"	, aHoGetIm1)
	nPosDes	:= GdFieldPos("RSG_DESC"	,aHoGetIm1)
	nPosSec	:= GdFieldPos("RSG_SECC"	, aHoGetIm1)
	nPosFra	:= GdFieldPos("RSG_FRACAR"	, aHoGetIm1)

	cItemIm1	:= aCoGetIm1[nNoGetIm1, nPosITE]
	cPrdIm1		:= aCoGetIm1[nNoGetIm1, nPosPrd]
	cDesIm1		:= aCoGetIm1[nNoGetIm1, nPosDes]
	cSecIm1		:= aCoGetIm1[nNoGetIm1, nPosSec]
	cFraIm1		:= aCoGetIm1[nNoGetIm1, nPosFra]

	If  !lX001Auto .and.  !lAutoTeste
		oItemIm1:Refresh()
		oPrdIm1:Refresh()
		oDesIm1:Refresh()
		oSecIm1:Refresh()
		oFraIm1:Refresh()
	Else
		nNoGetIm1 := n
	EndIf

	If lPVez //crea un elemento en el arreglo inferior, por cada item del getdados superior
		aColsIm2 := {}
		For nx := 1 To Len(aCoGetIm1)
			aAdd(aColsIm2,{})
			aColsIm2[nx] := {}

			If lUsoRSG
				nUsado := Len(aHoGetIm2)
				TMPRSH->(DBGoTop())
				If TMPRSH->(DBSeek(cFactItem+cSeriItem+cPrvItem+cTdaItem+aCoGetIm1[nx,nPosIte]))
					nEle:=1
					Do While !TMPRSH->(Eof()) .And. cFactItem+cSeriItem+cPrvItem+cTdaItem+aCoGetIm1[nx,nPosIte]==TMPRSH->RSH_FACT+TMPRSH->RSH_SERIE+TMPRSH->RSH_PROV+TMPRSH->RSH_TDA+TMPRSH->RSH_ITEM
						aAdd(aColsIm2[nx],{})
						aResIm2 := aClone(aColsRSH)
						aColsIm2[nx,nele] :=	aResIm2[1]
						nz := Len(aColsIm2[nx])
						For ny := 1 To nUsado
							If aHoGetIm2[nY,10]<>"V"
								aColsIm2[NX,nz,ny] := &("TMPRSH->"+aHoGetIm2[nY,2])
							Else
								aColsIm2[NX,nz,ny] := CriaVar(aHoGetIm2[ny,2],.T.)
							EndIf
						Next
						nEle++
						TMPRSH->(DBskip())
					EndDo
				Else
					aAdd(aColsIm2[nx],{})
					aResIm2 := aClone(aColsRSH)
					aColsIm2[nx,1] := aResIm2[1]
				EndIf
			Else
				aAdd(aColsIm2[nx],{})
				aResIm2 := aClone(aColsRSH)
				aColsIm2[nx,1] := aResIm2[1]
			EndIf
		Next
		aCoGetIm2 := aClone(aColsIm2[nNoGetIm1])
		CpyResGetDad(.F.,"oGetIm2")
		if !lAutoTeste
			oGetIm2:Refresh()
		endif
	EndIf
	If !lPVez
		If Len(aColsIm2[nNoGetIm1]) > 0
			aCoGetIm2 := {}
			For nx := 1 To Len(aColsIm2[nNoGetIm1])
				aAdd(aCoGetIm2,Array(Len(oGetIm2:aHeader) + 1))
				aResIm2 := aClone(aColsRSH)
				aCoGetIm2[nx] := aResIm2[1]
				If !Empty(AllTrim(aColsIm2[nNoGetIm1,nx,1])) .And. aColsIm2[nNoGetIm1,nx,1] <> Nil
					aCoGetIm2[nx] := aColsIm2[nNoGetIm1,nx]
				EndIf
			Next
			CpyResGetDad(.F.,"oGetIm2")
			if !lAutoTeste
				oGetIm2:Refresh()
			endif
		EndIf
	EndIf

	lPvez := .F.

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GenImpFrac ³Autor ³Gpe Santacruz.         ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Despliega el impuesto de acuerdo a la fraccion arancelaria   ³±±
±±³          ³como parte del encabezado de impuestos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³GenImpFrac()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³   Importaciones Mexico                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GenImpFrac()

	Local nPosCod	:= 0
	Local nPosSec	:= 0
	Local nPosFra	:= 0
	Local nPosTT	:= 0
	Local nPosTas	:= 0
	Local nPosDes	:= 0
	Local nPosImp	:= 0
	Local nPosVAdu	:= 0
	Local nPosPai	:= 0

	Local nSigLin	:= 0
	Local nDeleted	:= 0
	Local nPos		:= 0
	Local cCodIm1	:= ''
	Local cContIm1	:= ''
	Local cTTIm1	:= ''
	Local nTasIm1	:= 0
	Local cPais		:= ''
	Local cFraIm1	:= ''


	CpyResGetDad(.t.,"oGetIm1")
	CpyResGetDad(.t.,"oGetIm2")
 	 nPosCod	:= GdFieldPos("RSH_IMPUES",aHoGetIm2)
	 nPosSec	:= GdFieldPos("RSG_SECC",aHoGetIm1)
	 nPosFra	:= GdFieldPos("RSG_FRACAR",aHoGetIm1)
	 nPosTT		:= GdFieldPos("RSH_TIPTAS",aHoGetIm2)
	 nPosTas	:= GdFieldPos("RSH_TASA",aHoGetIm2)
	 nPosDes	:= GdFieldPos("RSH_DESIMP",aHoGetIm2)
	 nPosImp	:= GdFieldPos("RSH_IMPPAG",aHoGetIm2)
	 nPosVAdu	:= GdFieldPos("RSG_VALADU",aHoGetIm1)
	 nPosPai	:= GdFieldPos("RSG_PAIVTA",aHoGetIm1)
	 nDeleted	:= GdFieldPos("GDDELETED",aHoGetIm2)

	If  lX001Auto .or.  lAutoTeste
		nNoGetIm1 := n
	EndIf

	cSecIm1 := aCoGetIm1[nNoGetIm1,nPosSec]
	If READVAR() == "M->RSG_FRACAR"
		cFraIm1 := M->RSG_FRACAR
		cPais   := aCoGetIm1[nNoGetIm1,nPosPai]
	Else
		If READVAR() == "M->RSG_UMC"
			cFraIm1 := aCoGetIm1[nNoGetIm1,nPosFra]
			cPais   := aCoGetIm1[nNoGetIm1,nPosPai]
		Else
			cFraIm1 := aCoGetIm1[nNoGetIm1,nPosFra]
			cPais   := M->RSG_PAIVTA
		EndIf
	EndIf

	If !Empty(AllTrim(cFraIm1))
		RSA->(DBSetOrder(3))//RSA_FILIAL+RSA_USOFRA
		If RSA->(DBSeek(xFilial("RSA")+"1"))
			cCodIm1		:= RSA->RSA_CODIGO
			cContIm1	:= RSA->RSA_DESC
			cTTIm1  	:= RSA->RSA_TIPO
			nTasIm1		:= 0
			If !Empty(cFraIm1)
				RSB->(DBSetOrder(1))
				If RSB->(DBSeek(xFilial("RSB")+cFraIm1+CpAIS))
					nTasIm1 := RSB->RSB_TASA
				EndIf
			EndIf
		EndIf
	EndIf

	If Empty(AllTrim(cFraIm1))
		If (nPos := aScan(aCoGetIm2,{|x| AllTrim(x[nPosCod]) == AllTrim(cCodFracc)}))>0
			aCoGetIm2[nPos,nDeleted] := .T.
		EndIf
	Else
		If (nPos := aScan(aCoGetIm2,{|x| AllTrim(x[nPosCod]) == AllTrim(cCodFracc)}))>0
			nSigLin := nPos
			If aCoGetIm2[nPos,nDeleted] //si estaba borrada recupera el registro
				aCoGetIm2[nPos,nDeleted] := .F.
			EndIf
		Else
			If Empty(AllTrim(aCoGetIm2[1,nPosCod]))
				nSigLin := 1
			Else
				aAdd(aCoGetIm2,{})
				nSigLin := Len(aCoGetIm2)
				aCoGetIm2[nSigLin] := aResIm2[1]
				nSigLin := Len(aCoGetIm2)
			EndIf
		EndIf
		aCoGetIm2[nSigLin,nPosCod]	:= cCodIm1
		aCoGetIm2[nSigLin,nPosDes]	:= cContIm1
		aCoGetIm2[nSigLin,nPosTT]	:= cTTIm1
		aCoGetIm2[nSigLin,nPosTas]	:= nTasIm1
	EndIf

	CpyResGetDad(.F.,"oGetIm1")
	CpyResGetDad(.F.,"oGetIm2")

	If !lX001Auto .and. !lAutoTeste
		oGetIm2:Refresh()
		oSecIm1:Refresh()
		oFraIm1:Refresh()
		oItemIm1:Refresh()
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ArrImpuesto³ Autor³    Gpe Santacruz.     ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Pasa el contenido del aCols de RSG y RSH a tablas temporales ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³ArrImpuesto(aExp1,aExp2,cExp1,cExp2,cExp3,cExp4)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aExp1.- Hader de RSG.                                        ³±±
±±³          ³aExp2.- Hader de RSH.                                        ³±±
±±³          ³cExp1.- Numero de factura                                    ³±±
±±³          ³cExp2.- Serie                                                ³±±
±±³          ³cExp1.- codigo de Proveedor  		                          ³±±
±±³          ³cExp2.- Codigo de tienda del proveedor                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³   Importaciones Mexico                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ArrImpuesto(cTipo,cFac,cSer,cPro,cTda)

	Local ny := 0
	Local nx := 0
	Local nz := 0

	Local nUsado	:= 0
	Local nPosIte	:= 0
	Local nPosSec	:= 0
	Local nPosFra	:= 0
	Local nPos   	:= 0
	Local aCamRSG	:= {}
	Local aCamRSH	:= {}


CursorWait()
	If cTipo == 'P'
		If !lUsoRSG
			CriaTMP("TMPRSG", '{"RSG_FACT","RSG_SERIE","RSG_PROV","RSG_TDA","RSG_ITEM","RSG_SECC"}'	, "RSG")
			CriaTMP("TMPRSH", '{"RSH_FACT","RSH_SERIE","RSH_PROV","RSH_TDA","RSH_ITEM","RSH_IMPUES"}'	, "RSH")
		Else
			TMPRSG->(DBGoTop())
			Do While .T.
				If TMPRSG->(DBSeek(cFac+cSer+cPro+cTda))
					RecLock("TMPRSG",.F.)
					TMPRSG->(DBDelete())
					TMPRSG->(MSUnlock())
				Else
					Exit
				EndIf
			EndDo

			TMPRSH->(DBGoTop())
			Do While .T.
				If TMPRSH->(DBSeek(cFac+cSer+cPro+cTda))
					RecLock("TMPRSH",.F.)
					TMPRSH->(DBDelete())
					TMPRSH->(MSUnlock())
				Else
					Exit
				EndIf
			EndDo
		EndIf
		lUsoRSG	:= .T.
		CpyResGetDad(.t.,"oGetIm1")
		nPosIte	:= GdFieldPos("RSG_ITEM",aHoGetIm1)
		nPosSec	:= GdFieldPos("RSG_SECC",aHoGetIm1)
		nPosFra	:= GdFieldPos("RSG_FRACAR",aHoGetIm1)

		nUsado		:= Len(aHoGetIm1)

		For NX := 1 To Len(aCoGetIm1)
			If !(aCoGetIm1[NX,nUSado+1]) .And.  !Empty(AllTrim(aCoGetIm1[NX,nPosFra]))
				RecLock("TMPRSG",.T.)
				TMPRSG->RSG_FACT	:= cFac
				TMPRSG->RSG_SERIE	:= cSer
				TMPRSG->RSG_PROV	:= cPro
				TMPRSG->RSG_TDA		:= cTda

				For ny:=1 To Len( aHoGetIm1)
					If aHoGetIm1[ny,10]<>'V' //Excluye los campos virtuales
						&("TMPRSG->"+aHoGetIm1[ny,2]) := aCoGetIm1[nx,ny]
					EndIf
				Next
				TMPRSG->(MsUnLock())
			EndIf
		Next
	    CpyResGetDad(.t.,"oGetIm2")
		nUsado := Len(aHoGetIm2)

		For NX := 1 To Len(aColsIm2)
			For nz := 1 To Len(aColsIm2[nx])
				If !Empty(AllTrim(aColsIm2[NX,NZ,1]))
					If  !(aColsIm2[NX,NZ,nUSado+1])
						RecLock("TMPRSH",.T.)
						TMPRSH->RSH_FACT	:= cFac
						TMPRSH->RSH_SERIE	:= cSer
						TMPRSH->RSH_PROV	:= cPro
						TMPRSH->RSH_TDA		:= cTda
						TMPRSH->RSH_SECC	:= aCoGetIm1[NX,nposSec]

						TMPRSH->RSH_ITEM :=aCoGetIm1[NX,nposIte]
						For ny:=1 To Len( aHoGetIm2)
							If aHoGetIm2[ny,10]<>'V' //Excluye los campos virtuales
								&("TMPRSH->"+aHoGetIm2[ny,2]):=aColsIm2[nx,nz,ny]
							EndIf
						Next
						TMPRSH->(MsUnLock())
					EndIf
				EndIf
			Next
		Next
	Else
		If lUsoRSG
			TMPRSG->(DBCloseArea())
			TMPRSH->(DBCloseArea())
		EndIf

		CriaTMP("TMPRSG",'{"RSG_FACT","RSG_SERIE","RSG_PROV","RSG_TDA","RSG_ITEM","RSG_SECC"}',"RSG")
		CriaTMP("TMPRSH",'{"RSH_FACT","RSH_SERIE","RSH_PROV","RSH_TDA","RSH_ITEM","RSH_IMPUES"}',"RSH")

		lUsoRSG	:= .T.
		CFILRSG	:= xFilial("RSG")
		CFILRSH	:= xFilial("RSH")
		CFILRSD	:= xFilial("RSD")

		SX3->(DBSetOrder(1))
		RSG->(DBSetOrder(1))
		RSH->(DBSetOrder(1))
		RSD->(DBSetOrder(1))

		aCamRSG := {"RSG_CANUMC",,"RSG_DOLARE","RSG_VALCOM","RSG_VALADU","RSG_IMPIVA"}//Campos a calcular
		aCamRSH := {"RSH_IMPPAG","RSH_IMPIVA"}//Campos a calcular

		TRB->(DBGoTop())
		Do While !TRB->(Eof())
			If Empty(TRB->TRB_OK)
				TRB->(DBSkip())
				Loop
			EndIf

			cFac	:= TRB->TRB_FACT
			cSer	:= TRB->TRB_SERIE
			cPro	:= TRB->TRB_PROV
			cTda	:= TRB->TRB_TDA

			If	RSG->(DBSeek(CFILRSG+M->RSC_PEDORI+cFac+cSer+cPro+cTda+TRB->TRB_ITEM))
				Do While !RSG->(Eof()) .And. CFILRSG + M->RSC_PEDORI + cFac + cSer + cPro +cTda+TRB->TRB_ITEM == RSG->RSG_FILIAL+RSG->RSG_NUMPED+RSG->RSG_FACT+RSG->RSG_SERIE+RSG->RSG_PROV+RSG->RSG_TDA+RSG->RSG_ITEM
					RecLock("TMPRSG",.T.)
					If SX3->(DBSeek("RSG"))
						Do While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == 'RSG'
							If SX3->X3_CONTEXT <> "V"
								nPos := aScan(aCamRSG,{|x| AllTrim(x) == AllTrim(SX3->X3_CAMPO)})
								If npos == 0
									&("TMPRSG->"+SX3->X3_CAMPO):= &("RSG->"+SX3->X3_CAMPO)
								EndIf
							EndIf
							SX3->(DBSkip())
						EndDo
					EndIf

					TMPRSG->RSG_CANUMC	:= TRB->TRB_CANT
					TMPRSG->RSG_DOLARE	:= RSG->RSG_DOLARE / RSG->RSG_CANUMC * TMPRSG->RSG_CANUMC
					TMPRSG->RSG_VALCOM	:= Round(RSG->RSG_VALCOM / RSG->RSG_CANUMC * TMPRSG->RSG_CANUMC,0)
					TMPRSG->RSG_VALADU	:= Round(RSG->RSG_VALADU / RSG->RSG_CANUMC * TMPRSG->RSG_CANUMC,0)

					TMPRSG->(MsUnLock())

					If	RSH->(DBSeek(CFILRSH+M->RSC_PEDORI+cFac+cSer+cPro+cTda+RSG->RSG_ITEM+RSG->RSG_SECC))
						Do While !RSH->(Eof()) .And. CFILRSG+M->RSC_PEDORI+cFac+cSer+cPro+cTda+RSG->RSG_ITEM+RSG->RSG_SECC == RSH->RSH_FILIAL+RSH->RSH_NUMPED+RSH->RSH_FACT+RSH->RSH_SERIE+RSH->RSH_PROV+RSH->RSH_TDA+RSH->RSH_ITEM+RSH->RSH_SECC
							If	!RSD->(DBSeek(CFILRSD+M->RSC_PEDORI+RSH->RSH_IMPUES)) //No pasa los impuestos a nivel pedimento, del pedimento origen
								RecLock("TMPRSH",.T.)
								If SX3->(DBSeek("RSH"))
									Do While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == 'RSH'
										If SX3->X3_CONTEXT <> "V"
											nPos:= aScan(aCamRSH,{|x| AllTrim(x) == AllTrim(SX3->X3_CAMPO)})
											If npos == 0
												&("TMPRSH->"+SX3->X3_CAMPO) := &("RSH->"+SX3->X3_CAMPO)
											EndIf
										EndIf
										SX3->(DBSkip())
									EndDo
								EndIf
								TMPRSH->(MsUnLock())
							EndIf
							RSH->(DBSkip())
						EndDo
					EndIf
					RSG->(DBSkip())
				EndDo
			EndIf
			TRB->(DBSkip())
		EndDo
		MT447TotPie(.T.)
	EndIf

	CursorArrow()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447Trig2 ³ Autor³Gpe Santacruz.         ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Extrae el impuesto y coloca en el getdados inferior          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447Trig2(cExp1,cExp2)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1.-"RSG_UMC"                                             ³±±
±±³          ³cExp2.-"RSB->RSB_UMT"                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³     RSG_umc                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³   MT447FRACAR() y Gatillo de RSG_FRACAR                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447Trig2(cCampo,cCamsal)

	Local aArea		:= GetArea()
	Local aRefer	:= {}
	Local nPosCpo	:= aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim(cCampo)})
	Local cRetorno	:= "  "
	Local ny		:= 0

	Local 	nUsado := 0
	If nPosCpo > 0
		aCols[n,nPosCpo] := &(cCamSal)
		cRetorno := aCols[n,nPosCpo]

	EndIf

	GenImpFrac()
	RestArea(aArea)

Return cRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447LOk3  ³ Autor³    Gpe Santacruz.     ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida renglon del getdados de Fracciones Arancelarias       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447LOk3()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. Si todo ok                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ oGetIm1                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447LOk3()

	Local lRet		:= .T.

	Local nPosFra	:= 0
	Local nDeleted	:= 0
	Local nPosUMC	:= 0
	Local nPosSta	:= 0
	Local nPosPai	:= 0

	CursorWait()

	CpyResGetDad(.t.,"oGetIm1")
	CpyResGetDad(.t.,"oGetFacts")

	 nPosFra	:= aScan(aHoGetIm1,{|x| AllTrim(x[2]) == "RSG_FRACAR"})
	 nDeleted	:= GdFieldPos("GDDELETED"	,aHoGetIm1)
	 nPosUMC	:= GdFieldPos("RSG_CANUMC"	,aHoGetIm1)
	 nPosSta	:= GdFieldPos("RSE_EXTFAC"	,aHoGetFacts) //Extraccion de factura
	 nPosPai	:= GdFieldPos("RSG_PAIORI"	,aHoGetIm1)
	If lX001Auto
		nNoGetIm1 := n
	EndIf
	If !aCoGetIm1[	nNoGetIm1,nDeleted]

		If !Empty(aCoGetIm1[nNoGetIm1][nPosFra])  .And. Empty(aCoGetIm1[nNoGetIm1][nPosPai])
			Aviso(OemToAnsi(STR0023),OemToAnsi(STR0097),{STR0082})  //"Aviso",OemToAnsi("El pais de origen es necesario para el calculo de impuestos!!"),{'Ok'}
			lRet := .F.
		EndIf
		If !Empty(aCoGetIm1[	nNoGetIm1][nPosFra])  .And. (aCoGetIm1[	nNoGetIm1][nPosUMC]==0 )
			Aviso(OemToAnsi(STR0023),OemToAnsi(STR0098),{STR0082}) //(OemToAnsi("Aviso"),OemToAnsi("La cantidad a Extraer esta en ceros!"),{'Ok'})
			lRet := .F.
		Else
		       //actualiza getdado inferior
			MT447LOk4(1)
		EndIf
	EndIf

	CursorArrow()

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447TOk3  ³ Autor³    Gpe Santacruz.     ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida todo del getdados de Fracciones Arancelarias          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447TOk3()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. Si todo ok                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ oGetIm1                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447TOk3()

	Local lRet		:= .T.
	Local nPosFra	:= 0
	Local nDeleted	:= 0
	Local nPosUMC	:= 0
	Local nX		:= 0

	CursorWait()
	CpyResGetDad(.t.,"oGetIm1")

	nPosFra	:= aScan(aHoGetIm1,{|x| AllTrim(x[2]) == "RSG_FRACAR"})
	nDeleted:= GdFieldPos("GDDELETED" ,aHoGetIm1)
	nPosUMC	:= GdFieldPos("RSG_CANUMC",aHoGetIm1)
	If MT447LOk3()
	    if !lAutoTeste
	    	MT447TOk4()
	    endif
		For NX:=1 To Len(aCoGetIm1)
			If !aCoGetIm1[NX,nDeleted]
				If !Empty(aCoGetIm1[NX][nPosFra]) .And. (aCoGetIm1[NX][nPosUMC] == 0)
					Aviso(OemToAnsi(STR0023),OemToAnsi(STR0098),{STR0082})  //(OemToAnsi("Aviso"),OemToAnsi("La cantidad a extraer esta en ceros!"),{'Ok'})
					lRet := .F.
				EndIf
			EndIf
		Next
	Else
		lRet := .F.
	EndIf

	CursorArrow()

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447TOk4  ³ Autor³   Gpe Santacruz.      ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida todo del getdados de Impuestos de Fracciones araccela-³±±
±±³          ³rias.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447TOk4()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. Si todo ok                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ oGetIm2                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447TOk4()
	Local lRet := MT447LOk4()

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447LOk4  ³ Autor³    Gpe Santacruz.     ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida el renglon del getdados de Impuestos de Fracciones    ³±±
±±³          ³Arancealrias                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447LOk4()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. Si todo ok                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ oGetIm2                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447LOk4(nPIm2)

	Local lRet		:= .T.
	Local nX		:= 0
	Local nPos		:= 0
	Local nPosAct	:=0
	Local nDeleted	:=0
	Local nPosImp	:= 0
	Default nPIm2   :=0

	CpyResGetDad(.t.,"oGetIm2")
	CpyResGetDad(.t.,"oGetIm1")

	if lAutoTeste
	    if nPIm2==0
	    	nNoGetIm2:= n
	    else
	    	nNoGetIm2:= nPIm2
	    endif
	endif
	nPosAct	:= nNoGetIm2
	nDeleted:= GdFieldPos("GDDELETED",aHoGetIm2)
	nPosImp	:= GdFieldPos("RSH_IMPUES",aHoGetIm2)

	For npos := 1 To Len(aCoGetIm2)
		If !aCoGetIm2[nPos,nDeleted]
			If nPosAct<>nPos
				If aCoGetIm2[nPos,nPosImp] == aCoGetIm2[nPosAct,nPosImp] .And. !aCoGetIm2[nPosAct,nDeleted]
					Help( " ", 1, STR0056,,STR0099, 1, 0 )  //"Help",, "No debe repetirse el codigo de impuesto!"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	Next
	If lRet
		//actualiza getdado inferior
		If Len(aColsIm2) >= nNoGetIm1
			aColsIm2[nNoGetIm1] := {}
		Else
			aAdd(aColsIm2,{})
		EndIf
		For nx := 1 To Len(aCoGetIm2)
			aAdd(aColsIm2[nNoGetIm1],{})
			aColsIm2[nNoGetIm1,nx] :=	aCoGetIm2[nx]
		Next
	EndIf
CpyResGetDad(.F.,"oGetIm2")
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CriaTMP    ³ Autor³    Gpe Santacruz.     ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Genera estructura de la tabla temporal                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³CriaTMP(cExp1,cExp2,cExp3)					               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1.- Nombre de la tabla temporal                          ³±±
±±³          ³cExp2.- Expresion del indice que tendra la tabla temporal    ³±±
±±³          ³cExp3.- Tabla fuente                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CriaTMP(cNomTab,cChave,cTabla)

	Local nx		:= 0
	Local cArqTrb	:= ''
	Local aCamStr	:= {}
	Local aCampos	:= {}
	Local aChave	:= &cChave

	SX3->(DBSetOrder(1))
	If SX3->(DBSeek(cTabla))
		Do While !SX3->(Eof()) .And. AllTrim(cTabla) == AllTrim(SX3->X3_ARQUIVO)
			aAdd(aCamStr,SX3->X3_CAMPO)
			SX3->(DBSkip())
		EndDo
	EndIf

	aCampos := {}
	For nx := 1 To Len(aCamStr)
		GenCampos(@aCampos,Upper(aCamStr[nx]))
	Next

	oTmp := FWTemporaryTable():New(cNomTab)
	oTmp:SetFields( aCampos )
	oTmp:AddIndex("I1", aChave)
	oTmp:Create()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GenCampos    Autor³  Gpe Santacruz.       ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Crea registro del arreglo para las tablas temporales		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³GenCampos(@aExp1,cExp1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aExp1.- Arreglo vacio para  los campos                       ³±±
±±³          ³cExp1.- Nombre del campo                                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CriaTMP                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GenCampos(aCampos,cCampo)

	SX3->(DBSetOrder(2))
	SX3->(DBSeek(cCampo))
	aAdd(aCampos,{cCampo,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447DEL4  ³ Autor³  Gpe Santacruz.       ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida el borrado de un renglon del getdados de impuestos    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447DEL4()									               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³     oGetIm2                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function MT447DEL4()

Local lRet    := .T.
Local nPosCod :=0

CpyResGetDad(.t.,"oGetIm2")
nPosCod := GdFieldPos("RSH_IMPUES", aHoGetIm2)

If AllTrim(aCoGetIm2[nNoGetIm2,nPosCod]) == AllTrim(cCodFracc)
	MsgInfo(STR0085) //"Este item depende de la fraccion arancelaria, si requiere eliminarlo, borre el contenido de la la Fraccion"
	lRet:= .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GETDCLR    ³ Autor³  Gpe Santacruz.       ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Define el color del renglon del getdados de impuestos, para  ³±±
±±³          ³impuestos que vienen de fraccion arancelaria                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³GETDCLR(aExp1,nExp1,aExp2)					               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp1.- Acols                                               ³±±
±±³          ³ nExp1.- Renglon actual en el getdados                       ³±±
±±³          ³ aExp2.- aHeader                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Codigo del color                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³     oGetIm2                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GETDCLR(aLinha,nLinha,aHeader)
	/*
	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
	//                High Intensity Colors
	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
	#define CLR_GRAY        8421504	// RGB( 128, 128, 128 )
	#define CLR_HBLUE      16711680	// RGB(   0,   0, 255 )
	#define CLR_HGREEN        65280	// RGB(   0, 255,   0 )
	#define CLR_HCYAN      16776960	// RGB(   0, 255, 255 )
	#define CLR_HRED            255	// RGB( 255,   0,   0 )
	#define CLR_HMAGENTA   16711935	// RGB( 255,   0, 255 )
	#define CLR_YELLOW        65535	// RGB( 255, 255,   0 )
	#define CLR_WHITE      16777215	// RGB( 255, 255, 255 )
	*/

	Local nCor2		:= 65535 //16711680  //16776960 // Ciano - RGB(0,255,255)
	Local nCor3 	:= 16777215 // Branco - RGB(255,255,255)
	Local nPosPro	:= aScan(aHeader,{|x| Alltrim(x[2]) == "RSH_IMPUES"})
	Local nUsado 	:= Len(aHeader)+1
	Local nRet		:= nCor3
	RSA->(DBSetOrder(1))//RSA_FILIAL+RSA_USOFRA
	If RSA->(DBSeek(xFilial("RSA")+aLinha[nLinha][nPosPro]))
		If RSA->RSA_USOFRA == '1'
			nRet := nCor2
		EndIf
	Else
		nRet := nCor3
	EndIf

Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447CALCULO³ Autor³   Gpe Santacruz.      ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calculo de los Costos de la Mercancia                         ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447CALCULO()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp1.- Acols                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Codigo del color                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importaciones Mexico.                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MT447CALCULO(lMetCal)

	Local nPosTot	:= 0
	Local nPosCod	:= 0
	Local nPosDEs	:= 0
	Local nPosImp	:= 0
	Local nUsado	:= 0
	Local nx		:= 0
	Local ny		:= 0
	Local nValImp	:= 0
	Local nTotIncr	:= 0
	Local nTotGas	:= 0
	Local nTotMer	:= 0
	Local ntotimp	:= 0
	Local nTotVlI	:= 0
	Local nPosFac	:= 0
	Local nPosSer	:= 0
	Local nPosPro	:= 0
	Local nPosTda	:= 0
	Local nPosIte	:= 0
	Local nPosPrd	:= 0
	Local nPosUM	:= 0
	Local nPosUM2	:= 0
	Local nPosCan	:= 0
	Local nPosCan2	:= 0
	Local nPosCos	:= 0
	Local nPosPrr	:= 0
	Local nPosGIN	:= 0
	Local nPosInc	:= 0
	Local nPoscif	:= 0
	Local nPosTax	:= 0
	Local nPosGas	:= 0
	Local nPosCT	:= 0
	Local nPosCUn	:= 0
	Local nPosExt	:= 0
	Local nPosUMC	:= 0
	Local nPosUNC	:= 0
	Local nPosFacF	:= 0
	Local nPosSerF	:= 0
	Local nPosProF	:= 0
	Local nPosTdaF	:= 0
	Local nPosTc	:= 0
	Local nPosMon	:= 0
	Local nPosIteI	:= 0
	Local nPosPrdI	:= 0
	Local nPosDesI	:= 0
	Local nPosCanI	:= 0
	Local nPosCa2I	:= 0
	Local nPosUMI	:= 0
	Local nPosUM2I	:= 0
	Local nDelRSF	:= 0
	Local nPosPrvI	:= 0
	Local nPosTotI	:= 0
	Local nPosTip	:= 0
	Local nPosIteF	:= 0
	Local nPosIte2	:= 0
	Local nPosVlI	:= 0
	Local cFunc		:= ''
	Local cFilRSA	:= xFilial("RSA")
	Local nPosImp1	:= 0
	Local aTax		:= {}
	Local nPos		:= 0
	Local aGetDad	:= {oEnchRSC,oEnchRSO,oGetIncrem,oGetImpPed,oGetFacts,oGetItemF,oGetCosto}
	Local nDelRSE	:= GdFieldPos("GDDELETED",	aHoGetFacts)
	Local nPosTes	:= 0
	Local _ny		:= 0
	Local nA		:= 0
	Local aGasTES	:= {}
	Local aGasUni	:= {}
	Local aGasUniE	:= {}
	Local nPosGU	:= 0
	Local aProUni	:= {}
	Local nImpPes	:= 0
	Local cUmc		:= ''
	Local nPosTa	:= 0
	Local nPTC		:= 0
	Local nTotal	:= 0
	Local nTotFac	:= 0

	Private aImpPar	:= {} //Impuestos calculados de todas las partidas excepto de IVA
	Private aImpIVA	:= {} //Iva calculado por impuesto

	Default lMetCal := .F.

	If lMetCal
		nConMetImp += 1
	EndIf

	CpyResGetDad(.t.,"oGetItemF")
	CpyResGetDad(.t.,"oGetFacts")
	/*IF oGetIm1<> NIL
		CpyResGetDad(.t.,"oGetIm1")
		CpyResGetDad(.t.,"oGetIm2")
	ENDIF*/
	CpyResGetDad(.t.,"oGetCosto")
	CpyResGetDad(.t.,"oGetImpped")
	if !lAutoTeste
		If oFoldMT447:NOPTION > 2 .And. oFoldMT447:NOPTION < 8
			If !aGetDad[oFoldMT447:NOPTION]:tudook()
				Return
			EndIf
		EndIf
	EndIf

	CursorWait()

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Refresca el grid de Importes aduanales de acuerdo a la fraccion arancelaria³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	If lUsoRSG
		//ACTUALIZA LA INFORMACION DE LAS FRACCIONES ARANCELARIA
		nDelRSF := GdFieldPos("GDDELETED"	, aHoGetItemF)
		nPosFac := GdFieldPos("RSE_FACT"	, aHoGetFacts)
		nPosSer := GdFieldPos("RSE_SERIE"	, aHoGetFacts)
		nPosPro := GdFieldPos("RSE_PROV"	, aHoGetFacts)
		nPosTda := GdFieldPos("RSE_TDA"		, aHoGetFacts)
		nPosTc  := GdFieldPos("RSE_TC"		, aHoGetFacts)
		nPosIte := GdFieldPos("RSF_ITEM"	, aHoGetItemF)
		nPosPUNI:= GdFieldPos("RSF_PRECIO"	, aHoGetItemF)
		nPosTot := GdFieldPos("RSF_TOTAL"	, aHoGetItemF)
		nPosCan2:= GdFieldPos("RSF_CANUM2"	, aHoGetItemF)
		nPosUM1 := GdFieldPos("RSF_UM"		, aHoGetItemF)
		nPosUM2 := GdFieldPos("RSF_UM2"		, aHoGetItemF)
		nPosCan1:= GdFieldPos("RSF_CANT"	, aHoGetItemF)
		nPosIt2 := GdFieldPos("RSF_ITEDOC"	, aHoGetItemF)
		nPosIt1 := GdFieldPos("RSE_ITEM"	, aHoGetFacts)

		RSB->(DBSetOrder(1))
		For nx := 1 To Len(aCoGetFacts)
			If !aCoGetFacts[NX,nDelRSE]
				nPos := aScan(aColsIt,{|x| Trim(x[1,nPosIt2]) == AllTrim(aCoGetFacts[NX, nPosIt1])  })
				For ny := 1 To Len(aColsIt[npos])
					If !aColsIt[npos,ny,nDelRSF]
						If TMPRSG->(DBSeek(aCoGetFacts[nx,nPosFac]+aCoGetFacts[nx,nPosSer]+aCoGetFacts[nx,nPosPro]+aCoGetFacts[nx,nPosTda]+aColsIT[npos,NY,nPosIte]))
							RecLock("TMPRSG",.F.)
							If RSB->(DBSeek(xFilial("RSB")+TMPRSG->RSG_FRACAR+TMPRSG->RSG_PAIVTA))
								If TMPRSG->RSG_UMC == aColsIT[npos,ny,nPosUM1]
									TMPRSG->RSG_CANUMC := aColsIT[npos,ny,nPosCan1]
									TMPRSG->RSG_PRECIO := Round(aColsIT[npos,ny,nPosPUNI]*aCoGetFacts[npos,nPostc]*M->RSC_TC,5)	  //180612
								Else
									If TMPRSG->RSG_UMC == aColsIT[npos,ny,nPosUM2]
										TMPRSG->RSG_CANUMC := aColsIT[npos,ny,nPosCan2]
										TMPRSG->RSG_PRECIO := Round((aColsIT[npos,ny,nPosTot]/aColsIT[npos,ny,nPosCan2]),5)*aCoGetFacts[npos,nPostc]*M->RSC_TC
									Else
										MsgInfo(STR0083 + CRLF + CRLF + STR0140 + AllTrim(TMPRSG->RSG_UMC) + CRLF + STR0141 + AllTrim(aColsIT[npos,ny,nPosUM2])) //"La Unidad de Medida para este producto, no coincide con la Unidad que maneja la Fracción Arancelaria seleccionada, verifique que sea correcta." / "UM en Fracción Arancelaria ( Tabla RSB): " / "UM en Producto (Tabla RSF): "
										TMPRSG->RSG_CANUMC := 0
										TMPRSG->RSG_PRECIO := 0
									EndIf
								EndIf
							Else
								Help( " ", 1, STR0056,,STR0095, 1, 0 ) //"Help",,"No existe Fraccion Arancelaria de algun Producto y el cálculo puede tener inconsistencias."
							EndIf
							TMPRSG->(MSUnlock())
						EndIf
					EndIf
				Next
			EndIf
		Next

	EndIf
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Genera Totales ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	MT447TotPie(.T.)
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ejecuta las funciones de cada tipo de Impuesto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	CalcImpuestos()
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Actualiza Pestaña de costos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	aCoGetCosto := {}
	If ExistBlock('MT447COSTOS') //COSTEO PERSONALIZADO
		Execblock('MT447COSTO',.F.,.F.)
	Else
		nUsado		:= Len(aHoGetCosto)
		nPosFac		:= GdFieldPos("RSI_FACT"	, aHoGetCosto)
		nPosSer		:= GdFieldPos("RSI_SERIE"	, aHoGetCosto)
		nPosPro		:= GdFieldPos("RSI_PROV"	, aHoGetCosto)
		nPosTda		:= GdFieldPos("RSI_TDA"		, aHoGetCosto)
		nPosIte		:= GdFieldPos("RSI_ITEM"	, aHoGetCosto)
		nPosPrd		:= GdFieldPos("RSI_PROD"	, aHoGetCosto)
		nPosDes		:= GdFieldPos("RSI_DESC"	, aHoGetCosto)
		nPosUM		:= GdFieldPos("RSI_UM"		, aHoGetCosto)
		nPosUM2		:= GdFieldPos("RSI_UM2"		, aHoGetCosto)
		nPosCan		:= GdFieldPos("RSI_CANT"	, aHoGetCosto)
		nPosCan2	:= GdFieldPos("RSI_CANT2"	, aHoGetCosto)
		nPosCos		:= GdFieldPos("RSI_COSTO"	, aHoGetCosto)
		nPosImp		:= GdFieldPos("RSI_IMPOR"	, aHoGetCosto)
		nPosPrr		:= GdFieldPos("RSI_PRORR"	, aHoGetCosto)
		nPosGIN		:= GdFieldPos("RSI_GASINT"	, aHoGetCosto)
		nPosInc		:= GdFieldPos("RSI_INCREM"	, aHoGetCosto)
		nPoscif		:= GdFieldPos("RSI_CIF"		, aHoGetCosto)
		nPosTax		:= GdFieldPos("RSI_IMPUES"	, aHoGetCosto)
		nPosGas		:= GdFieldPos("RSI_GASTOS"	, aHoGetCosto)
		nPosCT		:= GdFieldPos("RSI_COSTOT"	, aHoGetCosto)
		nPosCUn		:= GdFieldPos("RSI_COSUNI"	, aHoGetCosto)
		nPosExt		:= GdFieldPos("RSI_CANEXT"	, aHoGetCosto)
		nPosUMC		:= GdFieldPos("RSI_UMC"		, aHoGetCosto)
		nPosUNC		:= GdFieldPos("RSI_UNICIF"	, aHoGetCosto)
		nPosVlI		:= GdFieldPos("RSI_VALIMP"	, aHoGetCosto)
		nPosFacF	:= GdFieldPos("RSE_FACT"	, aHoGetFacts)
		nPosSerF	:= GdFieldPos("RSE_SERIE"	, aHoGetFacts)
		nPosProF	:= GdFieldPos("RSE_PROV"	, aHoGetFacts)
		nPosTdaF	:= GdFieldPos("RSE_TDA"		, aHoGetFacts)
		nPosTc		:= GdFieldPos("RSE_TC"		, aHoGetFacts)  //Factor para dols
		nPosTA		:= GdFieldPos("RSE_TASA"	, aHoGetFacts)
		nPosMon		:= GdFieldPos("RSE_MONED"	, aHoGetFacts)

		nPosIteI	:= GdFieldPos("RSF_ITEM"	, aHoGetItemF)
		nPosPrdI	:= GdFieldPos("RSF_PRODUC"	, aHoGetItemF)
		nPosDesI	:= GdFieldPos("RSF_DESC"	, aHoGetItemF)
		nPosCanI	:= GdFieldPos("RSF_CANT"	, aHoGetItemF)
		nPosCa2I	:= GdFieldPos("RSF_CANUM2"	, aHoGetItemF)
		nPosUMI		:= GdFieldPos("RSF_UM"		, aHoGetItemF)
		nPosUM2I	:= GdFieldPos("RSF_UM2"		, aHoGetItemF)
		nDelRSF		:= GdFieldPos("GDDELETED"	, aHoGetItemF)

		nPosPrvI	:= GdFieldPos("RSF_PRECIO"	, aHoGetItemF)
		nPosTotI	:= GdFieldPos("RSF_TOTAL"	, aHoGetItemF)
		nPosTip		:= GdFieldPos("RSF_TIPO"	, aHoGetItemF)
		nPosTES		:= GdFieldPos("RSF_TES"		, aHoGetItemF)

		nPosIteF	:= GdFieldPos("RSE_ITEM"	, aHoGetFacts)
		nPosIte2	:= GdFieldPos("RSF_ITEDOC"	, aHoGetItemF)
		nPosImp1	:= GdFieldPos("RSF_VLIMP1"	, aHoGetItemF)

		nTotMer		:= 0
		nTotIncr	:= 0
		nTotGas		:= 0
		nTotVlI		:= 0
		nTotGasI	:= 0
		aGasUni		:= {}
		aGasUniE	:= {}
		aProUni		:= {}


		For nx := 1 To Len(aColsIt)
			For ny := 1 To Len(aColsIt[nx])
				If !aColsIt[nx,ny,nDelRSF]
					nPosFX := aScan(aCoGetFacts,{|x| x[NPOSITEF] == aColsIt[NX,ny,NPOSITE2]})
					If aColsIt[nx,ny,nPosTip] == '1' //solo Mercancia
						aAdd(aCoGetCosto,Array(nUsado+1))

						aCoGetCosto[Len(aCoGetCosto), nPosFac]	:= aCoGetFacts[nPosFX,nPosFacF]
						aCoGetCosto[Len(aCoGetCosto), nPosSer]	:= aCoGetFacts[nPosFX,nPosSerF]
						aCoGetCosto[Len(aCoGetCosto), nPosPro]	:= aCoGetFacts[nPosFX,nPosProF]
						aCoGetCosto[Len(aCoGetCosto), nPosTda]	:= aCoGetFacts[nPosFX,nPosTdaF]
						aCoGetCosto[Len(aCoGetCosto), nPosIte]	:= aColsIt[nx,ny,nPosIteI]
						aCoGetCosto[Len(aCoGetCosto), nPosPrd]	:= aColsIt[nx,ny,nPosPrdI]
						aCoGetCosto[Len(aCoGetCosto), nPosDes]	:= aColsIt[nx,ny,nPosDesI]
						aCoGetCosto[Len(aCoGetCosto), nPosUM]	:= aColsIt[nx,ny,nPosUMI]
						aCoGetCosto[Len(aCoGetCosto), nPosCan]	:= aColsIt[nx,ny,nPosCanI]
						aCoGetCosto[Len(aCoGetCosto), nPosUM2]	:= aColsIt[nx,ny,nPosUM2I]
						aCoGetCosto[Len(aCoGetCosto), nPosCan2]	:= aColsIt[nx,ny,nPosCa2I]

						//importe de la mercancia en pesos
						nImpPes := 0
						If 	aCoGetFacts[nPosFX,nPosMon] <> 1
							aCoGetCosto[Len(aCoGetCosto),nPosImp] := aColsIt[nx,ny,nPosTotI]*aCoGetFacts[nPosFX,nPostc]*M->RSC_TC
							nImpPes := aColsIt[nx,ny,nPosTotI] * aCoGetFacts[nPosFX,nPostc] * M->RSC_TC
						Else
							aCoGetCosto[Len(aCoGetCosto),nPosImp] := aColsIt[nx,ny,nPosTotI]
							nImpPes := aColsIt[nx,ny,nPosTotI]
						EndIf
						aCoGetCosto[Len(aCoGetCosto),nPosCos] := aCoGetCosto[Len(aCoGetCosto),nPosImp]/aCoGetCosto[Len(aCoGetCosto),nPosCan]

						aCoGetCosto[Len(aCoGetCosto),nPosExt] := 0
						nTotMer +=	aCoGetCosto[Len(aCoGetCosto),nPosImp]

						aCoGetCosto[Len(aCoGetCosto)][nUsado+1] := .F.
						aAdd(aProUni,{aCoGetFacts[nPosFX,nPosFacF],aCoGetFacts[nPosFX,nPosSerF],aCoGetFacts[nPosFX,nPosProF],;
							aCoGetFacts[nPosFX,nPosTdaF],aColsIt[nx,ny,nPosIteI],nImpPes}	)
					EndIf

					/*
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Gastos En el extranjero³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					*/
					If  aColsIt[nx,ny,nPosTip] $ '234A'
						//Define importes de acuerdo a Moneda Nacional
						If aCoGetFacts[nPosFX,nPosMon] == 1
							nGasMon := aColsIt[nx,ny,nPosTotI]
							nImpMon := aColsIt[nx,ny,nPosImp1]
						Else
							nGasMon := (aColsIt[nx,ny,nPosTotI]) * aCoGetFacts[nPosFX,nPostc] * M->RSC_TC
							nImpMon := aColsIt[nx,ny,nPosImp1] * aCoGetFacts[nPosFX,nPostc] * M->RSC_TC
						EndIf

						//Si es una factura que solo afecte a una factuta de mercancia en particular
						If "FLETE" $ Upper(aCoGetFacts[nPosFX,nPosFacF]) .Or. "GASTOS" $ Upper(aCoGetFacts[nPosFX,nPosFacF])//Solo afecta el costo de la factura que contiene el gastos
							nPosGU := aScan(aGasUniE,{|x| x[1] == aCoGetFacts[nPosFX,nPosFacF]+aCoGetFacts[nPosFX,nPosSerF]  })//Localiza los items de la factura
							If nPosGU == 0
								aAdd(aGasUniE,{aCoGetFacts[nPosFX,nPosFacF]+aCoGetFacts[nPosFX,nPosSerF],nGasMon })
							Else
								aGasUniE[nPosGU,2] += nGasMon
							EndIf
						Else
							nTotGasI += nGasMon
						EndIf

					EndIf

					/*
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Gastos Nacionales³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					*/
					If  aColsIt[nx,ny,nPosTip] $ '5678' //Todos los nacionales
						//Define importes de acuerdo a Moneda Nacional
						If aCoGetFacts[nPosFX,nPosMon] == 1
							nGasMon := aColsIt[nx,ny,nPosTotI]
							nImpMon := aColsIt[nx,ny,nPosImp1]
						Else
							nGasMon := (aColsIt[nx,ny,nPosTotI])*aCoGetFacts[nPosFX,nPostc]*aCoGetFacts[nPosFX,nPostA]
							nImpMon := aColsIt[nx,ny,nPosImp1]*aCoGetFacts[nPosFX,nPostc]*aCoGetFacts[nPosFX,nPostA]
						EndIf
						//Si es una factura que solo afecte a una factuta de mercancia en particular
						If "FLETE" $ Upper(aCoGetFacts[nPosFX,nPosFacF]) .Or. "GASTOS" $ Upper(aCoGetFacts[nPosFX,nPosFacF])//Solo afecta el costo de la factura que contiene el gastos
							nPosGU:= aScan(aGasUni,{|x| x[1] == aCoGetFacts[nPosFX,nPosFacF]+aCoGetFacts[nPosFX,nPosSerF]  })//Localiza los items de la factura
							If nPosGU == 0
								aAdd(aGasUni,{aCoGetFacts[nPosFX,nPosFacF]+aCoGetFacts[nPosFX,nPosSerF],nGasMon })
							Else
								aGasUni[nPosGU,2] += nGasMon
							EndIf
						Else
							nTotGas += nGasMon
							nTotVlI += nImpMon
						EndIf

					EndIf
				EndIf
			Next
		Next

		//Suma mercancia, solo la extraida
		nTotMer2 := 0
		If !LMT447Dep //Si NO es un pedimento que va a deposito fiscal
			If lUsoRSG
				TMPRSG->(DBGoTop())
				Do While !TMPRSG->(Eof())
					nPos := aScan(aCoGetCosto,{|x| x[nPosFac]+ x[nPosSer]+ x[nPosPro]+x[nPosTda]+ x[nPosIte] == ;
									TMPRSG->RSG_FACT+TMPRSG->RSG_SERIE+TMPRSG->RSG_PROV+TMPRSG->RSG_TDA+TMPRSG->RSG_ITEM})
					If NPOS>0
						aCoGetCosto[NPOS,nPosExt] := TMPRSG->RSG_CANUMC
						aCoGetCosto[NPOS,nPosumC] := TMPRSG->RSG_UMC
						nTotMer2 += aCoGetCosto[NPOS,nPosImp]/aCoGetCosto[NPOS,nPosExt]
					EndIf
					TMPRSG->(DBSkip())
				EndDo
			EndIf
		EndIf

		nTotImp		:= 0
		nTotPrr		:= 0
		nTotInc		:= 0
		nTotCif		:= 0
		nTotTax		:= 0
		nTTotGas	:= 0
		nTTotGIn	:= 0
		nTotIncr	:= aCoGetTot1[4,2]

		For nx := 1 To Len(aCoGetCosto)
		  	//SI HAY FACTURA DE FLETE O GASTOS INCLUIDO SOLO DEBE AFECTAR A LA FACTURA QUE LO INCLUYE///
			aCoGetCosto[nx,nPosPrr] := aCoGetCosto[nx,nPosImp] * 100 / nTotMer  //Prorrateo

			aCoGetCosto[nx,nPosGIN] := aCoGetCosto[nx,nPosPrr] / 100 * nTotGasI	//Gastos internacionales
			//Verifica si hay alguna factura de gastos que solo apliqeu a la factura de mercancia en cuestiom
			nPosGU := aScan(aGasUniE,{|x|  (AllTrim(aCoGetCosto[nx,nPosFac])$AllTrim(x[1]) .And. "FLETE" $ x[1]) .Or. (AllTrim(aCoGetCosto[nx,nPosFac])$AllTrim(x[1])  .And. "GASTOS" $ x[1])})//Localiza los items de la factura
			If nPosgu <> 0
				nProrUni := MT447PRORR(aProUni,aCoGetCosto[nx,nPosFac],aCoGetCosto[nx,nPosSer],aCoGetCosto[nx,nPosPro],aCoGetCosto[nx,nPosTda],;
					aCoGetCosto[nx,nPosIte])
				aCoGetCosto[nx,nPosGIN] += nProrUni * aGasUniE[nposgu,2]
			EndIf

			aCoGetCosto[nx,nPosInc] := aCoGetCosto[nx,nPosPrr] / 100 * nTotIncr	//Incrementables
			aCoGetCosto[nx,nPosCif] := aCoGetCosto[nx,nPosImp] + aCoGetCosto[nx,nPosInc] + aCoGetCosto[nx,nPosGIN]	//Costo CIF
			aCoGetCosto[nx,nPosUNC] := aCoGetCosto[nx,nPosCif] / aCoGetCosto[nx,nPosCan]	//Costo unitario CIF
			aCoGetCosto[nx,nPosTax] := 0
			aCoGetCosto[nx,nPosGas] := 0

			If !LMT447Dep //Si NO es un pedimento que va a deposito fiscal
				//impuestos
				aCoGetCosto[nx,nPosTax] := Round(SumTaxIte(aCoGetCosto[nx,nPosFac], aCoGetCosto[nx,nPosSer],	aCoGetCosto[nx,nPosPro],aCoGetCosto[nx,npostda],aCoGetCosto[nx,nPosIte],aCoGetCosto[nx,nPosPrr]),2)   //aTax[1]
				nCanCal := 0
				If aCoGetCosto[nx,nPosUM ] == aCoGetCosto[nx,nPosUMC ]
					nCanCal := aCoGetCosto[nx,nPosCan]
				EndIf
				If  aCoGetCosto[nx,nPosUM2 ] == aCoGetCosto[nx,nPosUMC ]
					nCanCal := aCoGetCosto[nx,nPosCan2]
				EndIf

				aCoGetCosto[nx,nPosGas]:=aCoGetCosto[nx,nPosPrr]/100*nTotGas //Gastos nacionales
				//Verifica si hay alguna factura de gastos que solo apliqeu a la factura de mercancia en cuestiom
				nPosGU := aScan(aGasUni,{|x|  (AllTrim(aCoGetCosto[nx,nPosFac])$AllTrim(x[1])  .And. "FLETE" $ x[1]) .Or. (AllTrim(aCoGetCosto[nx,nPosFac])$AllTrim(x[1])  .And. "GASTOS" $ x[1])})//Localiza los items de la factura
				If nPosgu <> 0
					nProrUni := MT447PRORR(aProUni,aCoGetCosto[nx,nPosFac],aCoGetCosto[nx,nPosSer],aCoGetCosto[nx,nPosPro],aCoGetCosto[nx,nPosTda],;
					aCoGetCosto[nx,nPosIte])
					aCoGetCosto[nx,nPosGas] += nProrUni * aGasUni[nposgu,2]
				EndIf
				aCoGetCosto[nx,nPosCT ] := aCoGetCosto[nx,nPosCif] + aCoGetCosto[nx,nPosTax]+aCoGetCosto[nx,nPosGas] 	///costo total
				aCoGetCosto[nx,nPosCUn] := aCoGetCosto[nx,nPosCT ] / nCanCal	//Costo Unitario
				aCoGetCosto[nx,nPosVlI] := aCoGetCosto[nx,nPosPrr] / 100 * nTotVlI	//Impuestos
			EndIf
			nTotImp	+= aCoGetCosto[nx,nPosImp]
			nTotPrr	+= aCoGetCosto[nx,nPosPrr]
			nTotInc	+= aCoGetCosto[nx,nPosInc]
			nTotCif	+= aCoGetCosto[nx,nPosCif]
			nTotTax	+= aCoGetCosto[nx,nPosTax]
			nTTotGas+= aCoGetCosto[nx,nPosGas]
			nTTotGIn+= aCoGetCosto[nx,nPosGIN]
		Next

		//Totaliza
		TotCostos(@aCoGetCosto,aHoGetCosto,nUsado,nTotImp,nTotPrr,nTotInc,nTotCif ,nTotTax,nTTotGas,nTTotGIn)

		/*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Guarda en Arreglo, los gastos prorrateados desglosados por factura³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/
		nPosTip		:= GdFieldPos("RSE_TIPO"	, aHoGetFacts)
		nPosTot		:= GdFieldPos("RSE_VALMER"	, aHoGetFacts)
		nPosFacT	:= GdFieldPos("RSE_TC"		, aHoGetFacts)

		aGastos := {}
		For nx := 1 To Len(aCoGetFacts)
			If aCoGetFacts[nx,npostip] <> '1' //Si es de gastos
				lFleInc := .F.
				If "FLETE" $ Upper(aCoGetFacts[nx,nPosFacF]) .Or. "GASTOS" $ Upper(aCoGetFacts[nx,nPosFacF])//Solo afecta el costo de la factura que contiene el gastos
					nP := at("FLETE",Upper(aCoGetFacts[nx,nPosFacF]) )
					If NP == 0
						nP := at("GASTOS",Upper(aCoGetFacts[nx,nPosFacF]) )
					EndIf
					cFacFte := SubSTR(aCoGetFacts[nx,nPosFacF],1,nP-1)
					lFleInc := .T.
					nSumMer := 0
					For ny := 1 To Len(aCoGetCosto) - 1
						If AllTrim(cFacFte) == AllTrim(aCoGetCosto[ny,nPosFac])
							nSumMer += aCoGetCosto[ny,nPosImp]
						EndIf
					Next
				EndIf

				/*
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Genera arreglo con items por factura y por codigo de TES³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				*/
				nPosIt2 := GdFieldPos("RSF_ITEDOC",aHoGetItemF)

				nPos := aScan(aColsIt,{|x| Trim(x[1,nPosIt2]) == AllTrim(aCoGetFacts[NX, nPosIteF])  })//Localiza los items de la factura
				aGasTES := {}
				If npos > 0
					For _ny := 1 To Len(aColsIt[nPos])  //Acumula total por Numero de factura y TES
						_nPos := aScan(aGasTES,{|x| x[1]==aCoGetFacts[nx,nPosIteF].And. x[2]==aColsIt[npos,_ny,npostes]})
						If _nPos == 0
							aAdd(aGasTES,{aCoGetFacts[nx,nPosIteF],aColsIt[npos,_ny,npostes],aColsIt[npos,_ny,npostoti]})
						Else
							aGasTES[_nPos,3] += aColsIt[npos,_ny,npostoti]
						EndIf
					Next
				EndIf

				/*
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Genera arreglo con los gastos prorrateado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				*/
				nTotal := 0
				For ny := 1 To Len(aCoGetCosto)-1
					If  lFleInc
						lAfecta := .T.
						If AllTrim(cFacFte) == AllTrim(aCoGetCosto[ny,nPosFac])
							nProrr := 100 * aCoGetCosto[ny,nPosImp] / nSumMer
						Else
							lAfecta := .F.
						EndIf
					Else
						lAfecta := .T.
					EndIf

					If lAfecta
						For _ny := 1 To Len(aGasTES)
							If !lFleInc
								nGasto := aCoGetCosto[nY,nPosPrr] / 100 * aGasTES[_ny,3]
							Else
								nGasto := nProrr / 100 * aGasTES[_ny,3]
							EndIf
							nGasto := Round(nGasto, 2) //Redondeo a 2 decimales.
							aAdd(aGastos,{ aCoGetFacts[nx,nPosFacF],;
								aCoGetFacts[nx,nPosSerF],;
								aCoGetFacts[nx,nPosProF],;
								aCoGetFacts[nx,nPosTdaF],;
								aCoGetCosto[nY,nPosIte],;
								aCoGetCosto[nY,nPosPrd],;
								NGASTO,;
								aCoGetFacts[nx,nposmon],;
								aCoGetCosto[ny,nPosFac],;
								aCoGetCosto[ny,nPosSer],;
								aCoGetCosto[ny,nPosPro],;
								aCoGetCosto[ny,nPosTda],;
								aGasTES[_ny,2]  })
							nTotal += nGasto
						Next
					EndIf
				Next
				nTotFac := 0
				For nA := 1 To Len(aGasTES)
					nTotFac += aGasTES[nA][3]
				Next nA
				aGastos[Len(aGastos)][7] += (nTotFac - nTotal)
				aCoGetCosto[Len(aCoGetCosto)-1][nPosGas] += (nTotFac - nTotal)
			EndIf
		Next
	EndIf
	CpyResGetDad(.f.,"oGetCosto")
	if !lAutoTeste
		oGetCosto:Refresh()
	endif
	CursorArrow()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447TotPie³ Autor³  Gpe Santacruz.       ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Actualiza el Pie de Pagina                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447TotPie(lExp1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lExp1.- .T. Calcula los totales                             ³±±
±±³          ³         .F. Pasa a los totales el contenido en tablas       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_VALID de RSC_TC, RSC_FACINC MT447CALCULO()               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447TotPie(lCalcula)

	Local nPosTC   := 0
	Local nPosTa   := 0
	Local nPosTot  := 0
	Local nPosTip  := 0
	Local nPosMon  := 0
	Local nPosIte  := 0
	Local nPosIte2 := 0
	Local nDeleted := 0

	Local nPosFTip := 0

	Local nDelInc  := 0
	Local nPosI    := 0

	Local nx			:= 0
	Local ny			:= 0
	Local nPosl			:= 0
	Local nPosc			:= 0
	Local nMonPes		:= 1
	Local nPosFac		:= 0
	Local ntotincr		:= 0

	Local nTc			:=0


	Default lCalcula	:= .F.


	CpyResGetDad(.t.,"oGetFacts")
	CpyResGetDad(.t.,"oGetItemF")


	nPosTC   := GdFieldPos("RSE_TC"		, aHoGetFacts)
	nPosTa   := GdFieldPos("RSE_TASA"	, aHoGetFacts)
	nPosTot  := GdFieldPos("RSF_TOTAL"	, aHoGetItemF)
	nPosTip  := GdFieldPos("RSF_TIPO"	, aHoGetItemF)
	nPosMon  := GdFieldPos("RSE_MONED"	, aHoGetFacts)
	nPosIte  := GdFieldPos("RSE_ITEM"	, aHoGetFacts)
	nPosIte2 := GdFieldPos("RSF_ITEDOC"	, aHoGetItemF)
	nDeleted := GdFieldPos("GDDELETED"	, aHoGetItemF)

	nPosFTip := GdFieldPos("RSE_TIPO"	, aHoGetFacts)

	CpyResGetDad(.t.,"oGetIncrem")

	nDelInc  := GdFieldPos("GDDELETED"	, aHoGetIncrem)
	nPosI    := GdFieldPos("RSK_VALOR"	, aHoGetIncrem)


	CpyResGetDad(.t.,"oGetTot1")
	CpyResGetDad(.t.,"oGetTot2")
	CpyResGetDad(.t.,"oGetTot3")


	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpia el total del pedimento y el total de gastos nacionales³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	For nx := 1 To Len(aCoGetTot1)
		aCoGetTot1[nx,2] := 0
		aCoGetTot1[nx,4] := 0
	Next

	For nx := 1 To Len(aCoGetTot2)
		aCoGetTot2[nx,2] := 0.00
	Next

	If lCalcula .Or. lX001Auto .and. len(aHoGetFacts)>0 .and. len(aHoGetItemF)>0 .and. len(aCoGetItemF)>0 .and. len(aCoGetFacts)>0 //gsa
		For nx := 1 To Len(aColsIt)
			For ny := 1 To Len(aColsIt[nx])
		If !aColsIt[nx,ny,nDeleted]
					nPosFac := aScan(aCoGetFacts,{|x| x[NPOSITE] == aColsIt[NX,ny,NPOSITE2]})
					If NPOSFAC == 0

						Help( " ", 1, STR0056,,STR0100, 1, 0 ) //"Help",,"No encontro factura "
					Else
						If aColsIt[nx,ny,nPosTip] == '1' //Mercancia
							If aCoGetFacts[nPOSFAC,nPosMon]<>2
								aCoGetTot1[1,2] += aCoGetFacts[nPOSFAC,nPosTC] * aColsIt[nx,ny,nPosTOT]	//Cambia valor de la mercancia a dolares
							Else
								aCoGetTot1[1,2] += aColsIt[nx,ny,nPosTOT]	//Valor original en dolares
							EndIf
						EndIf

						nPosL := 0
						nPosC := 0

						Do case
							case aColsIt[nx,ny,nPosTip] == '2' //Fletes Extranjeros
								nPosL := 1
								nPosC := 4
							Case aColsIt[nx,ny,nPosTip] == '5' //Fletes Nacionales
								nPosL := 1
								nPosC := 2
							Case aColsIt[nx,ny,nPosTip] == '3' //Seguros Extranjeros
								nPosL := 2
								nPosC := 4
							Case aColsIt[nx,ny,nPosTip] == '6' //Seguros Nacionales
								nPosL := 2
								nPosC := 2
							Case aColsIt[nx,ny,nPosTip] == '8' //Almacenajes Nacional
								nPosL := 3
								nPosC := 2
							Case aColsIt[nx,ny,nPosTip] == '4' //Embalajes Extranjeros
								nPosL := 3
								nPosC := 4
							Case aColsIt[nx,ny,nPosTip] == '7' //Otros Nacionales
								nPosL := 4
								nPosC := 2
							Case aColsIt[nx,ny,nPosTip] == 'A' //Otros Extranjeros
								nPosL := 4
								nPosC := 4
						EndCase
						If nPosL <> 0 .And. nPosC <> 0
							If aColsIt[nx,ny,nPosTip] $ '234A' //Gastos extranjeros
								If (aCoGetFacts[nPOSFAC,nPosMon] <> nMonPes, Round(aCoGetTot1[nPosL,nPosC]+=aColsIt[nx,ny,nPosTOT]*aCoGetFacts[nPOSFAC,nPosTC]*M->RSC_TC,0),aCoGetTot1[nPosL,nPosC]+=aColsIt[nx,ny,nPosTOT])
							Else //Gastos nacionales
								If (aCoGetFacts[nPOSFAC,nPosMon] <> nMonPes, Round(aCoGetTot2[nPosL,nPosC]+=aColsIt[nx,ny,nPosTOT]*aCoGetFacts[nPOSFAC,nPosTA],0),aCoGetTot2[nPosL,nPosC]+=aColsIt[nx,ny,nPosTOT])
							EndIf
						EndIf
					EndIf
          		EndIf
			Next
		Next

		If !LMT447Ext
			//Totaliza los gastos extranjeros e incrmentables
			ntotincr := 0
			For nx := 1 To Len(aCoGetIncrem)
				If !aCoGetIncrem[nx,nDelInc]
					ntotincr += aCoGetIncrem[nx,nPosI]
				EndIf
			Next

			aCoGetTot1[4,2] := ntotincr
			aCoGetTot1[1,4] := Round(aCoGetTot1[1,4],0)
			aCoGetTot1[2,4] := Round(aCoGetTot1[2,4],0)
			aCoGetTot1[3,4] := Round(aCoGetTot1[3,4],0)
			aCoGetTot1[4,4] := Round(aCoGetTot1[4,4],0)

			ntotincr += aCoGetTot1[1,4]+aCoGetTot1[2,4]+aCoGetTot1[3,4]+aCoGetTot1[4,4]

			//SI HAY INFORMACION DE FRACCIONES ARANCELARIAS, RECTIFICA LOS VALORES, YA QUE AHI SE INTERPRETA CORRECTAMENTE LA UNIDAD DE MEDIDA
			If LUSORSG
				nTotValCom := 0
				TMPRSG->(DBGoTop())

				Do While !TMPRSG->(Eof())
					RecLock("TMPRSG",.F.)
					TMPRSG->RSG_VALCOM := Round(TMPRSG->RSG_PRECIO *	TMPRSG->RSG_CANUMC,0)
					RSG->(MSUnlock())
					nTotValCom += TMPRSG->RSG_VALCOM
					TMPRSG->(DBSkip())
				EndDo

				nSumAdu := 0
				nSumDol := 0
				TMPRSG->(DBGoTop())

				Do While !TMPRSG->(Eof())
					nMul	:= TMPRSG->RSG_VALCOM * ntotincr
					nIncr	:= nMul / nTotValCom
					RecLock("TMPRSG",.F.)

					TMPRSG->RSG_VALADU := Round( TMPRSG->RSG_PRECIO *	TMPRSG->RSG_CANUMC + nIncr,0)
					TMPRSG->RSG_DOLARE := Round((TMPRSG->RSG_PRECIO *	TMPRSG->RSG_CANUMC + nIncr ) / M->RSC_TC,2)
					RSG->(MSUnlock())
					nSumAdu += TMPRSG->RSG_VALADU
					nSumDol += TMPRSG->RSG_DOLARE
					TMPRSG->(DBSkip())
				EndDo
				aCoGetTot1[1,2] := nSumDol
				aCoGetTot1[3,2] := nTotValCom
				aCoGetTot1[2,2] := nSumAdu
			Else

				aCoGetTot1[3,2] := Round(aCoGetTot1[1,2] *M->RSC_TC,0) //180612  //PRECIO PAGADO o comercial
				aCoGetTot1[2,2] := Round(aCoGetTot1[3,2] + ntotincr,2)  //180612   //Valor aduana
				aCoGetTot1[1,2] := aCoGetTot1[1,2] +(ntotincr / M->RSC_TC)  //Valor Dolares
			EndIf

		Else //Si es extraccion
			If LUSORSG
				TMPRSG->(DBGoTop())
				Do While !TMPRSG->(Eof())
					aCoGetTot1[1,2] += TMPRSG->RSG_DOLARE
					aCoGetTot1[3,2] += TMPRSG->RSG_VALCOM
					aCoGetTot1[2,2] += TMPRSG->RSG_VALADU
					TMPRSG->(DBSkip())
				EndDo
					aCoGetTot1[4,2] := aCoGetTot1[2,2] - aCoGetTot1[3,2]
			EndIf
		EndIf
		M->RSC_FACINC := Round(aCoGetTot1[2,2] / aCoGetTot1[3,2], 6)
	Else
		RSJ->(DBSetOrder(1))
		If RSJ->(DBSeek(xFilial("RSJ")+M->RSC_NUMPED  ))
			aCoGetTot1[1,4]	:= RSJ->RSJ_FLETEE
			aCoGetTot1[2,4]	:= RSJ->RSJ_SEGE
			aCoGetTot1[3,4]	:= RSJ->RSJ_ALME
			aCoGetTot1[4,4]	:= RSJ->RSJ_OTROE

			aCoGetTot2[1,2]	:= RSJ->RSJ_FLETEN
			aCoGetTot2[2,2]	:= RSJ->RSJ_SEGN
			aCoGetTot2[3,2]	:= RSJ->RSJ_ALMN
			aCoGetTot2[4,2]	:= RSJ->RSJ_OTRON

			aCoGetTot1[1,2]	:= RSJ->RSJ_VALDOL
			aCoGetTot1[2,2]	:= RSJ->RSJ_VALADU
			aCoGetTot1[3,2]	:= RSJ->RSJ_VALPES
			aCoGetTot1[4,2]	:= RSJ->RSJ_VALINC
		EndIf
   		//Resumen de impuestos
		nUsado		:= Len(aHoGetTot3)
		aImpuesto	:= {}; nTotImp := 0

		RSA->(DBSetOrder(1))
		RSL->(DBSetOrder(1))
		If RSL->(DBSeek(xFilial("RSL")+M->RSC_NUMPED  ))
			Do While !RSL->(Eof()) .And. xFilial("RSL")+M->RSC_NUMPED == RSL->RSL_FILIAL+RSL->RSL_NUMPED
				aAdd(aImpuesto,Array(nUsado+1))
				aImpuesto[Len(aImpuesto),1] := RSL->RSL_CODIMP
				If RSA->(DBSeek(xFilial("RSA")+RSL->RSL_CODIMP))
					aImpuesto[Len(aImpuesto),2] := RSA->RSA_DESC
				Else
					aImpuesto[Len(aImpuesto),2] := RSL->RSL_DESC
				EndIf
				aImpuesto[Len(aImpuesto),3] := RSL->RSL_IMPORT
				ntotimp += RSL->RSL_IMPORT
				aImpuesto[Len(aImpuesto),nusado+1] := .F.
				RSL->(DBSkip())
			EndDo
			aAdd(aImpuesto,Array(nUsado+1))
			aImpuesto[Len(aImpuesto), 2] := STR0101   //" Total  ---->"
			aImpuesto[Len(aImpuesto), 3] := ntotimp
			aImpuesto[Len(aImpuesto), nusado+1] := .F.
			aCoGetTot3 := aClone(aImpuesto)

			CpyResGetDad(.f.,"oGetTot3")

			if !lAutoTeste
				oGetTot3:aCols := aClone(aImpuesto)
				oGetTot3:Refresh()
			endif
		EndIf
	EndIf

	CpyResGetDad(.f.,"oGetTot1")
	CpyResGetDad(.f.,"oGetTot2")

	If !lX001Auto .and. !lAutoTeste
		oGetTot1:FORCERefresh()
		oGetTot2:FORCERefresh()
	EndIf



Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SumTaxIte  ³ Autor³    Gpe Santacruz.     ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Suma los impuestos calculados de cada item, separando        ³±±
±±³          ³ el iva del resto delos impuestos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³SumTaxIte(cExp1,cExp2,cExp3,cExp4,cExp5,nExp1)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Numero de factura                                   ³±±
±±³          ³ cExp2.- Serie de factura                                    ³±±
±±³          ³ cExp3.- Codigo de proveedor                                 ³±±
±±³          ³ cExp4.- Codigo de tienda                                    ³±±
±±³          ³ cExp5.- Numero de item                                      ³±±
±±³          ³ nExp1.- % Prorrateo del item                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ El valor del impuesto para el item                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MT447CALCULO                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SumTaxIte(cFac,cSer,cPro,cTda,cIte,nProrr)

	Local nPos		:= aScan(aImpPar,{|x| x[2]+ x[3]+x[4]+ x[5]+x[6]==cFac+cSer+cPro+cTda+cIte})
	Local nDeleted	:= GdFieldPos("GDDELETED"	, aHoGetImpPed)
	Local nPosImp	:= GdFieldPos("RSD_IMPPAG"	, aHoGetImpPed)
	Local nPosCod	:= GdFieldPos("RSD_CODIMP"	, aHoGetImpPed)
	Local nValor	:= 0
	Local nx		:= 0
	Local aExiste	:= {}

	If lUsoRSG
		If TMPRSH->(DBSeek(cFac+cSer+cPro+cTda+cIte))
			Do While !TMPRSH->(Eof()) .And. cFac+cSer+cPro+cTda+cIte == TMPRSH->RSH_FACT+TMPRSH->RSH_SERIE+TMPRSH->RSH_PROV+TMPRSH->RSH_TDA+TMPRSH->RSH_ITEM
				nValor +=	TMPRSH->RSH_IMPpag
				aAdd(aExiste,TMPRSH->RSH_IMPUES)
				TMPRSH->(DBSkip())
			EndDo
		EndIf
	EndIf
	RSA->(DBSetOrder(1))
	For nx := 1 To Len(aCoGetImpPed)
		If !aCoGetImpPed[nx,nDeleted]
			//si esta en la pestaña de Impuestos a nivel pedimento,  Y es un impuesto que aplica a nivel  pedimento
			If RSA->(DBSeek(xFilial("RSA")+aCoGetImpPed[NX,nPosCod])) .And. RSA->RSA_TIPAPL == '1' //.And. (aScan(aExiste,{|x| x==aCoGetImpPed[nx,nPosCod]}))==0
				nValor += aCoGetImpPed[nx,nPosImp] * (nprorr / 100)
			EndIf
		EndIf
	Next

Return nValor

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447A1WHEN³ Autor³     Gpe Santacruz.    ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³NO PERMITE EDICION DEL IMPUESTO SI ES DE IGI                 ³±±
±±³          ³ (Fraccion arancelaria)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447A1WHEN()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lExp1                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_WHEN  de RSH_IMPUES                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447A1WHEN()

	Local lRet    := .T.
	Local nPosImp := 0

	CpyResGetDad(.t.,"oGetImpPed")
	If AllTrim(M->RSH_IMPUES) == AllTrim(cCodFracc)
		lRet := .F.
	EndIf

	//Si es un impuesto que fue colocado a nivel pedimento y aplica a todos los items
	nPosImp := GdFieldPos("RSD_CODIMP",aHoGetImpPed)
	If (aScan(aCoGetImpPed,{|x| x[nPosImp]==M->RSH_IMPUES}))>0 .AND. !EMPTY(M->RSH_IMPUES)
		lRet := .F.
	EndIf

Return  lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447VLDT  ³ Autor³   Gpe Santacruz.      ³ Data ³ 14/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida que el tipo de item corresponda al tipo de factura    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447VLDT()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lExp1                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_VALID  de  RSF_TIPO                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447VLDT()

	Local cVar    := &(readvar())
	Local nPosTip := 0
	Local lRet    := .T.

	CpyResGetDad(.t.,"oGetFacts")
	nPosTip := GdFieldPos("RSE_TIPO",aHoGetFacts)

	If !Pertence("123456789A")
		lRet:= .F.
	EndIf

	If lX001Auto
		nNoGetFacts:=_nPosNatF
	EndIf

	If aCoGetFacts[nNoGetFacts,nPostip]=="1" .And. cVar<>'1'
		Help( " ", 1, STR0056,,STR0102, 1, 0 ) //"Help",,"La factura es de mercancia y solo puede insertar items del mismo tipo!"
		lRet:= .F.
	EndIf

	If aCoGetFacts[nNoGetFacts,nPostip] $ "23" .And. cVar=='1'
		Help( " ", 1, STR0056,,STR0103, 1, 0 )  //"Help",,"La factura es de Gastos y no debe insertar items con tipo Mercancia!"
		lRet:= .F.
	EndIf

	If aCoGetFacts[nNoGetFacts,nPostip] $ "2" .And. cVar $ '234A' //Si factura de gastos nacionales y el item no es alguno de gastos nacional
		Help( " ", 1, STR0056,,STR0104, 1, 0 ) //"Help",,"La factura es de Gastos Nacionales!"
		lRet:= .F.
	EndIf

	If aCoGetFacts[nNoGetFacts,nPostip] $ "3" .And. cVar $ '5678' //Si factura de gastos extranjeros y el item no es alguno de gastos extranjero
		Help( " ", 1, STR0056,,STR0105, 1, 0 ) //"Help",,"La factura es de Gastos Extranjeros!"
		lRet:= .F.
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MT447A1TES ³ Autor ³ Gpe Santacruz         ³ Data ³ 19/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida la TES seleccionada para facturas de Gastos de        ³±±
±±³          | importacion.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Null                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Usado em: ³ x3_valid de RSF_tes                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447A1TES()

	Local aArea		:= GetArea()
	Local cTes		:= &(ReadVar())
	Local lRet		:= .T.
	Local nPosTipf	:= 0
	local nPosPrc	:= 0
	Local nPosTot	:= 0
	Local lVldTes	:= M447VLDTes(cTes)



	If !lVldTes
		Return lRet := .F.
	EndIf

	If ExistCpo("SF4") .And. cTes <= "500"
		CpyResGetDad(.t.,"oGetFacts")
		CpyResGetDad(.t.,"oGetItemF")
		nPosTipf:= aScan(aHoGetFacts,{|x| AllTrim(x[2]) == "RSE_TIPO"   })
		nPosPrc	:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_PRECIO"})
		nPosTot	:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_TOTAL"})
		If aCoGetFacts[nNoGetFacts,nPosTipf]<>'1'
			DbSelectArea("SFC")
			DbSetOrder(1)
			If DBSeek(xFilial("SFC")+cTes)
				While !Eof() .And. FC_FILIAL == xFilial("SFC") .And.;
						FC_TES == cTes
					If Empty(FC_INCDUPL) .Or. Empty(FC_INCNOTA) .Or. Empty(FC_CREDITA) .Or. Empty(FC_CALCULO)
						lRet := .F.
						Exit
					EndIf
					DbSkip()
				End
			EndIf
			SF4->(DBSetOrder(1))
			If SF4->(MsSeek(xFilial("SF4")+cTes))
				If SF4->F4_ESTOQUE <> "S"
					If !lX001Auto
						Help( " ", 1, STR0023,,RetTitle("RSF_TES")+" "+CTES+" - "+STR0106, 1, 0 ) //"La TES seleccionada no actualiza stock, lo que significa que tampoco actualizara costos, verifique si esto es correcto"
						lRet:= .F.
					EndIf
				EndIf
			EndIf
		EndIf

	EndIf
	RestArea(aArea)

	If !lRet
		Help("","1","TESINV")
	Else
		If lX001Auto //220113
			MaFisAlt("IT_VALMERC", NoRound(aCoGetItemF[nNoGetItemF][nPosPrc] * M->RSF_CANT,TamSx3("RSF_TOTAL")[2]) , N )
			aCols := aClone(aCoGetItemF)
			MaFisRef("IT_TES","MT120",cTes)
			aCoGetItemF := aClone(ACOLS)
		EndIf
	EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447TRIG3 ³ Autor³    Gpe Santacruz.     ³ Data ³ 19/08/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula el valor en pesos del getdados de Incrementables     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447TRIG3(nExp1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp1.- 1 Si debe validar el campo RSK_VALMON, 2 Si RSK_TC  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_VALID  de  RSK_VALMON, RSK_TC					           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447TRIG3(nPosCpo)


	Local nPosImp := 0
	Local nPosTC  := 0
	Local nPosVal := 0

	If lX001Auto .or. lAutoTeste
		nNoGetIncrem := n
	EndIf
	CpyResGetDad(.t.,"oGetIncrem")
	nPosImp := GdFieldPos("RSK_VALMON"	, aHoGetIncrem)
	nPosTC  := GdFieldPos("RSK_TC"		, aHoGetIncrem)
	nPosVal := GdFieldPos("RSK_VALOR"	, aHoGetIncrem)

	If nPosCpo == 1
		aCoGetIncrem[nNoGetIncrem,nPosVal] := &(readvar())*aCoGetIncrem[nNoGetIncrem,nPosTC]
	EndIf

	If nPosCpo == 2
		aCoGetIncrem[nNoGetIncrem,nPosVal] := &(readvar())*aCoGetIncrem[nNoGetIncrem,nPosImp]

	EndIf
	IIF(!lAutoTeste, oGetIncrem:ACOLS[nNoGetIncrem,nPosVal]:=aCoGetIncrem[nNoGetIncrem,nPosVal],)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447WHEN2 ³ Autor³ Gpe Santacruz.        ³ Data ³ 19/08/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica si edita o no el campo de Almacen del getdados de   ³±±
±±³          ³Fracciones Arancelarias                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447WHEN2()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lExp1                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_WHEN  de  RSG_ALMACE                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447WHEN2()

	Local lRet    := .F.
	Local nPosSta :=0
	CpyResGetDad(.t.,"oGetFacts")
	nPosSta := GdFieldPos( "RSE_EXTFAC", aHoGetFacts) //Extraccion de factura

	If aCoGetFacts[nNoGetFacts,nPosSta] == 'EF'  .Or. LMT447Ext //Si es extraccion de factura o extraccion de pedimento
		lRet := .T.
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447VAL2  ³ Autor³    Gpe Santacruz.     ³ Data ³ 19/08/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida que el campo de almacen del getdados de Fracciones    ³±±
±±³          ³Arancelarias no quede vacio para las Extracciones            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447VAL2()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lExp1                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_VALID  de  RSG_ALMACE                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447VAL2()

	Local lRet    := .T.
	Local nPosSta := 0
	CpyResGetDad(.t.,"oGetItemF")
	nPosSta := GdFieldPos( "RSE_EXTFAC", aHoGetFacts) //Extraccion de factura

	If aCoGetFacts[nNoGetFacts,nPosSta] == 'EF'   .Or.  LMT447EXT  //Si es extraccion de factura o extraccion de pedimento
		If Empty(&(readvar()))
			lRet := .F.
		EndIf
	EndIf
CpyResGetDad(.f.,"oGetItemF")
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447CVEPED ³ Autor³    Gpe Santacruz.     ³ Data ³ 21/10/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447CVEPED()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ningno                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_VALID  de  RSC_CVEPED (Clave del pedimento)               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447CVEPED()

	Local cCvePed		:= &(readvar())
	Local lRet			:= .T.
	LMT447Dep			:= .F.
	LMT447EXT			:= .F.
	LMT447Rec			:= .F.
	if !lAutoTeste
		oGetFacts:LInsert	:= .T.
		oGetItemF:LInsert	:= .T.
	endif

	If AllTrim(cCvePed) $ cLisExt
		LMT447EXT := .T.
		LMT447Dep := .F.
		LMT447Rec := .F.
	Else
		If AllTrim(cCvePed) $ cLisDep
			LMT447Dep := .T.
			LMT447EXT := .F.
			LMT447Rec := .F.
		Else
			If AllTrim(cCvePed) $ cLisRec
				LMT447Rec := .T.
				LMT447EXT := .F.
				LMT447Dep := .F.
				if !lAutoTeste
					// No permitira insertar mas lineas en GetDados de Facturas o Partidas (Items) de la Factura
					oGetFacts:lInsert := .F.
					oGetItemF:lInsert := .F.
				endif
			EndIf
		EndIf
	EndIf

	If  (AllTrim(cCvePed) $ cLisExt) .And. (AllTrim(cCvePed) $ cLisDep)
		Help( " ", 1, STR0023,,STR0074, 1, 0 ) //"Aviso",,"Verifique los parametros MV_MXCTASA y MV_MXDEPFI, no puede haber codigos repetidos entre ellos!"
		lRet := .F.
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447SelPr    ³Aut   ³Gpe Santacruz.         ³ Data ³ 21/10/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pantalla para seleccionar los productos del pedimento origen.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³ MT447SelPr           	  							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ningno                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Ningno                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Extraccion por Pedimento                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MT447SelPr()

	Local aArea		:= {}
	Local aSvKeys	:= {}
	Local nX		:= 0
	Local nOpca		:= 0
	Local nPos		:= 0
	Local nMarcados	:= 0
	Local aStru		:= {}
	Local aCpos		:= {}
	Local aPosEnch	:= {}
	Local lRet		:= .T.
	Local aCanExt	:= {}
	Local oDlg1

	Private cAlmDef		:= '  '  //Almacen de entrada por default
	Private oMark
	Private oPrd
	Private cCodPrd
	Private oCanPen
	Private nCanpen
	Private oAlmEnt
	Private cAlmEnt		:= '  '
	Private lInverte	:= .F.
	Private cItDoc

	Private  oTmpTable := NIL

	If !LMT447EXT
		Help( " ", 1, STR0023,,STR0107, 1, 0 ) //"Aviso",,"Esta rutina es solo para pedimentos, con Clave de Pedimento para Extracción"
		Return
	EndIf
	If Empty(M->RSC_PEDORI)
		Help( " ", 1, STR0023,,STR0108, 1, 0 ) //"Aviso",,"Seleccione primero el pedimento Origen"
		Return
	EndIf
	aArea	:= GetArea()
	aSvKeys	:= GetKeys()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Redefinicao do aCpos para utilizar no MarkBrow ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCpos := {	{"TRB_OK"		, "", "Sel"},;
				{"TRB_STATUS"	, "", "Sta"},;
				{"TRB_ITEM"		, "", "Item"},;
				{"TRB_PRODUC"	, "", "Codigo"},;
				{"TRB_DESC"		, "", "Producto"},;
				{"TRB_UM"		, "", "UM"},;
				{"TRB_CANTOT"	, "", "Cant Tot"		, X3PICT("RSF_CANT"		)},;
				{"TRB_UM2"		, "", "UM2"},;
				{"TRB_CANUM2"	, "", "Cant UM2"		, X3PICT("RSF_CANUM2"	)},;
				{"TRB_PRECIO"	, "", "Precio"			, X3Pict("RSF_PRECIO"	)},;
				{"TRB_TOTAL"	, "", "Total"			, X3Pict("RSF_TOTAL"	)},;
				{"TRB_CANPEN"	, "", "Cnt Pendiente"	, X3Pict("RSF_CANT"	 	)},;
				{"TRB_CANT"		, "", "Cnt Extaer"		, X3Pict("RSF_CANT"		)},;
				{"TRB_ALMACE"	, "", "Alm Entrada"		, X3Pict("RSF_ALMACE"	)},;
				{"TRB_FACT"		, "", "Factura"},;
				{"TRB_SERIE"	, "", "Serie"},;
				{"TRB_PROV"		, "", "Cod. Prv."},;
				{"TRB_TDA"		, "", "Tienda"},;
				{"TRB_NOME"		, "", "Proveedor"},;
				{"TRB_ITEDOC"	, "", "Item Doc"},;
				{"TRB_ALMORI"	, "", "Alm Origen", X3Pict("RSF_ALMACE"	)}}

	If !lUsoFac
		MT447PRODEXT(M->RSC_NUMPED,M->RSC_PEDORI) //CREA TABLA TEMPORAL
	EndIf

	TRB->(DBGoTop())
	cCodPrd	:= TRB->TRB_PRODUC + "      " + TRB->TRB_DESC + "       " + TRB->TRB_UM
	nCanPen	:= TRB->TRB_CANT
if !lAutoTeste
	DEFINE FONT oFont2 NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg1 TITLE (STR0109) FROM 010,010 TO 355,900 OF oMainWnd PIXEL  //"Seleccione los productos"

	aPosEnch := {60, 0, 150, 449}

	@003,002 SAY oPrd VAR cCodPrd OF odlg1 FONT oFont2
	@003,025 SAY STR0110 OF odlg1 FONT oFont2	//"Cantidad a Extraer:"
	@003,032 GET oCanPen VAR nCanPen PICTURE "999,999.99" VALID VldCanExt(cMarca) OF odlg1 SIZE 60,2

	@003,041 SAY STR0111 OF odlg1 FONT oFont2	//"Almacen de Entrada:"
	@003,049 msGET oAlmEnt VAR cAlmEnt  OF odlg1 SIZE 20,2  F3 "NNR" VALID VldalmEnt()

	oMark := MsSelect():New("TRB", "TRB_OK", "TRB_STATUS", aCpos, lInverte, cMarca, aPosEnch)
	oMark:oBrowse:lCanAllMark	:= .T.
	oMark:oBrowse:lHasMark		:= .T.
	oMark:bMark              	:= {||MarcaItem(cMarca, lInverte, oDlg1)}

	oMark:oBrowse:bAllMark   	:= {||MarcaTudo(cMarca, oDlg1)}

	oMark:oBrowse:BCHANGE    	:= {||RefCant()}

	ACTIVATE MSDIALOG oDlg1 CENTERED ON INIT EnchoiceBar(oDlg1, {|| iif (ValAlmAll(), (nOpcA := 1, lUsoFac := .T., oDlg1:End()),(nOpcA:=0) )}, {|| If (!lUsoFac, TRB->(DBCloseArea()), ), nOpcA := 0, oDlg1:End()})
endif
	If nOpcA == 1
		Return .T.
	EndIf

	If oTmpTable <> Nil
		oTmpTable:Delete()
		FreeObj(oTmpTable)
		oTmpTable := Nil
	EndIf

	RestArea(aArea)
	RestKeys(aSvKeys, .T.)

Return

//
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ValAlmAll  ³ Autor ³ Gpe Santacruz       ³ Data ³ 02/12/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ valida que todo el marckbrowse que este seleccionado       ³±±
±±³          ³ tenga almacen y no sea el mismo que el de salida           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Extraccion por Pedimento    MT447SelPr()                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function ValAlmAll

Local lRet:= .t.
Local nFila:=0
Local nRecno := TRB->(Recno())
TRB->(DBGoTop())
DO while !TRB->(EOF())
    nFila++
	if !empty(TRB->TRB_OK) .and. empty(TRB->TRB_ALMACE)
		lRet:= .f.
		msginfo(STR0157+alltrim(str(nFila))+STR0158) //"El renglón " ##  " no tienen almacen asignado!!"
		EXIT

	endif
	if TRB->TRB_ALMORI== TRB->TRB_ALMACE
			msginfo(STR0157+alltrim(str(nFila))+STR0158) //"El renglón " ##   " tiene el mismo almacen para entrada y salida de mercancia!!"
		lRet:= .f.
		EXIT
	ENDIF
	TRB->(DBSKIP())
ENDDO
TRB->(DBGOTO(nRecno))
Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RefCant    ³ Autor ³ Gpe Santacruz       ³ Data ³ 03/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Refresca la cantidad extraida en el encabezado, cuando     ³±±
±±³          ³ cambia de linea                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Extraccion por Pedimento    MT447SelPr()                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RefCant()

	CCodPrd	:= TRB->TRB_PRODUC + "      " + TRB->TRB_DESC + "       " + TRB->TRB_UM
	nCanPen	:= TRB->TRB_CANT
	cAlmEnt	:= TRB->TRB_ALMACE
if !lAutoTeste
	oCanPen:Refresh()
	oAlmEnt:Refresh()
	oPrd:Refresh()
endif
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MarcaItem  ³ Autor ³ Gpe Santacruz       ³ Data ³ 21/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca un item del MarkBrowse                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Extraccion por Pedimento    MT447SelPr()                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MarcaItem(cMarca,lInverte,oDlg1)
	RecLock("TRB",.F.)

	If TRB->(IsMark("TRB_OK",cMarca,lInverte))  //cuando no esta marcado
			TRB->TRB_OK		:= cMarca
			TRB->TRB_CANT		:= TRB->TRB_CANPEN
			TRB->TRB_ALMACE	:= "  "
			TRB->TRB_CANPEN	:= 0
	Else
			TRB->TRB_CANPEN   := TRB->TRB_CANPEN + nCanPen //TRB->TRB_CANT
			TRB->TRB_OK		:= "  "
			TRB->TRB_CANT		:= 0
			TRB->TRB_ALMACE	:= '  '

	EndIf
	TRB->(MsUnlock())
	nCanPen := TRB->TRB_CANT
	cAlmEnt:= TRB->TRB_ALMACE
if !lAutoTeste
	oCanPen:Refresh()
	oAlmEnt:Refresh()
	oDlg1:Refresh() //QUITAR
endif
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MarcaTudo  ³ Autor ³ Gpe Santacruz       ³ Data ³ 21/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Seleciona todos los items del MarkBrowse                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Extraccion por Pedimento    MT447SelPr()                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MarcaTudo(cMarca,oDlg1)

	Local nRecno := TRB->(Recno())

	While ! TRB->(Eof())
		RecLock("TRB",.F.)
		If Empty(TRB->TRB_OK)
			TRB->TRB_OK		:= cMarca
			TRB->TRB_CANT	:= TRB->TRB_CANTOT
			TRB->TRB_ALMACE	:= cAlmDef
			TRB->TRB_CANPEN	:= TRB->TRB_CANTOT- TRB->TRB_CANT
		Else
			TRB->TRB_OK		:= " "
			TRB->TRB_CANT	:= 0
			TRB->TRB_ALMACE	:= ' '
			TRB->TRB_CANPEN	:= TRB->TRB_CANTOT
		EndIf
		TRB->(MsUnlock())
		TRB->(DbSkip())
	EndDo
	TRB->(DbGoto(nRecno))
	if !lAutoTeste
	 oDlg1:Refresh() //QUITAR
	endif
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VldCanExt  ³Autor ³Gpe Santacruz.         ³ Data ³ 21/10/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida el get de la cantidad a extraer                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³VldCanExt()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ningno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Ningno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Extraccion por Pedimento    MT447SelPr()                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VldCanExt()

	Local lRet := .T.

	If nCanPen > TRB->TRB_CANTOT
		MsgInfo(STR0112)   //"La cantidad a extraer es mayor a la cantidad que tiene el deposito"
		lRet:= .F.
	Else
		RecLock("TRB",.F.)
		TRB->TRB_CANPEN	:= TRB->TRB_CANTOT- nCanPen
		TRB->TRB_CANT	:= nCanPen
		TRB->TRB_ALMACE	:= cAlmEnt

		If nCanPen>0
			If Empty(TRB->TRB_OK)
				TRB->TRB_OK := cMarca
			EndIf
		Else
			TRB->TRB_OK := "  "
		EndIf
		TRB->(MSUnlock())
		if !lAutoTeste
			 oMark:obrowse:Refresh() //QUITAR
		endif
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VldAlmEnt  ³Autor ³    Gpe Santacruz.     ³ Data ³ 03/11/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida el get del almacen de entrada de la extraccion        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³VldAlnEnt()     	  	   								       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ningno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Ningno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Extraccion por Pedimento    MT447SelPr()                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VldalmEnt()

	Local lRet := .T.

	If Empty(cAlmEnt) .And. nCanPen>0
		MsgInfo(STR0113) //"Debe seleccionar un almacen o cambie la cantidad a extraer a cero!"
		lRet:= .F.
	Else
	 	DBSELECTAREA("NNR")
	    NNR->(DBSETORDER(1))
	    IF !NNR->(DBSEEK(XFILIAL("NNR")+cAlmEnt))
	   		 msgInfo("Almacen inexistente")
			 lRet := .f.
	    ELSE
			cAlmDef := cAlmEnt
			RecLock("TRB",.F.)
			TRB->TRB_CANPEN	:= TRB->TRB_CANTOT- nCanPen
			TRB->TRB_CANT	:= nCanPen
			TRB->TRB_ALMACE	:= cAlmEnt

			If nCanPen>0
				If Empty(TRB->TRB_OK)
					TRB->TRB_OK := cMarca
				EndIf
			Else
				TRB->TRB_OK		:= "  "
				TRB->TRB_ALMACE	:= '  '
			EndIf
			TRB->(MSUnlock())
			 oMark:obrowse:Refresh() //QUITAR
		endif
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³X3PICT     ³Autor ³  Gpe Santacruz.       ³ Data ³ 21/10/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Extrae el formato del campo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³X3PICT(cExp1)    	  	   						               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Nombre del campo                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cExp1.- Fomato del campo                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Extraccion por Pedimento    MT447SelPr()                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function X3PICT(cCampo)

	Local cPic := ''

	DBSelectArea("SX3")
	SX3->(DBSetOrder(2))
	If SX3->(DBSeek(cCampo))
		cPic := x3Picture(cCampo)
	EndIf

Return cPic

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447PEDORI³Autor ³    Gpe Santacruz.     ³ Data ³ 21/10/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valide el Pedimento Origen, y extrae información del mismo   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447PEDORI(cExp1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Numero del pedimento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lExp1.- Si existe el pedimento en RSC                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_VALID de RSC_PEDORI                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447PEDORI(cPed)

	Local lRet := .T.
	Local nReg := RSC->(Recno())

	If (LMT447EXT .Or. LMT447REC) .And. !Empty(M->RSC_PEDORI)
		RSC->(DBSetOrder(1))
		If !RSC->(DBSeek(xFilial("RSC")+cPed))
			Help( " ", 1, STR0056,, STR0114+cPed+" !", 1, 0 )   //"Help",, "No existe  pedimento "
			lRet:= .F.
		Else
			If !(AllTrim(RSC->RSC_CVEPED) $   cLisDep)   .And. LMT447EXT
				Help( " ", 1, STR0056,, STR0115, 1, 0 ) //"Help",, "El pedimento origen no es de ingreso a  Deposito Fiscal!"
				lRet:= .F.
			Else
				If  RSC->RSC_STATUS<>'2' .And. (LMT447EXT .or. LMT447REC)
					Help( " ", 1, STR0056,, STR0116, 1, 0 ) //"Help",, "El pedimento origen, no tiene status de haber generado documentación en compras!"
					lRet:= .F.
				Else
					M->RSC_TC		:= RSC->RSC_TC
					M->RSC_PESO		:= RSC->RSC_PESO
					M->RSC_ADUANA	:= RSC->RSC_ADUANA
					M->RSC_TRANSE	:= RSC->RSC_TRANSE
					M->RSC_TRANSA	:= RSC->RSC_TRANSA
					M->RSC_TRANSS	:= RSC->RSC_TRANSS
					M->RSC_FECENT	:= RSC->RSC_FECENT
					M->RSC_AGENTE	:= RSC->RSC_AGENTE
					M->RSC_DESORI	:= RSC->RSC_DESORI
					If LMT447REC
						MT447CPYPED(cPed)
					EndIf
				EndIf
			EndIf
		EndIf
		RSC->(DBSetOrder(1))
		RSC->(DBGoTo(NREG))
	EndIf

	If !lRet .Or. (LMT447EXT .And. Empty(M->RSC_PEDORI)) .Or. (LMT447REC .And. Empty(M->RSC_PEDORI))
		M->RSC_TC		:= 0
		M->RSC_PESO		:= 0
		M->RSC_ADUANA	:= SPACE(TAMSX3("RSC_ADUANA")[1])
		M->RSC_TRANSE	:= SPACE(TAMSX3("RSC_TRANSE")[1])
		M->RSC_TRANSA	:= SPACE(TAMSX3("RSC_TRANSA")[1])
		M->RSC_TRANSS	:= SPACE(TAMSX3("RSC_TRANSS")[1])
		M->RSC_FECENT	:= ctod("  /  /  ")
		M->RSC_AGENTE	:= SPACE(TAMSX3("RSC_AGENTE")[1])
		M->RSC_DESORI	:= SPACE(TAMSX3("RSC_DESORI")[1])
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CALCOSEXT  ³Autor ³     Gpe Santacruz.    ³ Data ³ 31/10/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calculo del Costo de una Extraccion por Pedimento            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³CALCOSEXT()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Niguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Niguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Extraccion por Pedimento                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CALCOSEXT()

	Local NX      	:= 0
	Local NY      	:= 0
	Local aGetDad 	:= {oEnchRSC,oEnchRSO,oGetIncrem,oGetImpPed,oGetFacts,oGetItemF,oGetCosto}
	Local nGasNac 	:= 0 //Total de gastos nacionales del pedimento origen
	Local cFilRSI 	:= xFilial("RSI")
	Local cTes    	:= ''
	Private aImpPar	:= {} //Impuestos calculados de todas las partidas excepto de IVA
	Private aImpIVA	:= {} //Iva calculado por impuesto

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida la salida del getdados en que este³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	IF !lAutoTeste
	If oFoldMT447:NOPTION > 2 .And. oFoldMT447:NOPTION < 7
		If !aGetDad[oFoldMT447:NOPTION]:tudook()
			Return
		EndIf
	EndIf
	ENDIF
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Actualiza Pestaña de costos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	If !lUsoFac
		MSGALERT(STR0117) //"No ha seleccionado ningun producto para extraer. Haga uso del botón de Extracción"
		Return
	EndIf

	CursorWait()
	CpyResGetDad(.t.,"oGetFacts")
	CpyResGetDad(.t.,"oGetItemF")
	CpyResGetDad(.t.,"oGetImpPed")
	CpyResGetDad(.t.,"oGetCosto")


	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rellena aCols de Fracciones arancelarias e Impuestos  (RSG/RSH)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	ArrImpuesto("E")

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ejecuta las funciones de cada tipo de Impuesto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	CalcImpuestos()
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Genera Totales ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	MT447TotPie(.T.)
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Actualiza Pestaña de costos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	aCoGetCosto := {}
	If ExistBlock('MT447EXTCOS') //COSTEO PERSONALIZADO
		Execblock('MT447EXTCOS',.F.,.F.)
	Else
		nUsado		:= Len(aHoGetCosto)
		nPosFac		:= GdFieldPos("RSI_FACT"	, aHoGetCosto)
		nPosSer		:= GdFieldPos("RSI_SERIE"	, aHoGetCosto)
		nPosPro		:= GdFieldPos("RSI_PROV"	, aHoGetCosto)
		nPosTda		:= GdFieldPos("RSI_TDA"		, aHoGetCosto)
		nPosIte		:= GdFieldPos("RSI_ITEM"	, aHoGetCosto)
		nPosPrd		:= GdFieldPos("RSI_PROD"	, aHoGetCosto)
		nPosDes		:= GdFieldPos("RSI_DESC"	, aHoGetCosto)
		nPosUM		:= GdFieldPos("RSI_UM"		, aHoGetCosto)
		nPosUM2		:= GdFieldPos("RSI_UM2"		, aHoGetCosto)
		nPosCan		:= GdFieldPos("RSI_CANT"	, aHoGetCosto)
		nPosCan2	:= GdFieldPos("RSI_CANT2"	, aHoGetCosto)
		nPosCos		:= GdFieldPos("RSI_COSTO"	, aHoGetCosto)
		nPosImp		:= GdFieldPos("RSI_IMPOR"	, aHoGetCosto)
		nPosPrr		:= GdFieldPos("RSI_PRORR"	, aHoGetCosto)
		nPosGIN		:= GdFieldPos("RSI_GASINT"	, aHoGetCosto)
		nPosInc		:= GdFieldPos("RSI_INCREM"	, aHoGetCosto)
		nPoscif		:= GdFieldPos("RSI_CIF"		, aHoGetCosto)
		nPosTax		:= GdFieldPos("RSI_IMPUES"	, aHoGetCosto)
		nPosGas		:= GdFieldPos("RSI_GASTOS"	, aHoGetCosto)
		nPosCT		:= GdFieldPos("RSI_COSTOT"	, aHoGetCosto)
		nPosCUn		:= GdFieldPos("RSI_COSUNI"	, aHoGetCosto)
		nPosExt		:= GdFieldPos("RSI_CANEXT"	, aHoGetCosto)
		nPosUMC		:= GdFieldPos("RSI_UMC"		, aHoGetCosto)
		nPosUNC		:= GdFieldPos("RSI_UNICIF"	, aHoGetCosto)

		nTTotImp	:= 0
		nTTotPrr	:= 0
		nTTotInc	:= 0
		nTTotCif	:= 0
		nTTotTa		:= 0
		nTTotGIn	:= 0
		nTTotTax	:= 0

		cAliasRSI	:= CriaTrab(Nil,.F.)

		cQrySum	:= "SELECT SUM(RSI_IMPOR) nTotImp, SUM(RSI_INCREM) nTotInc,SUM(RSI_GASINT)nTotGasI,SUM(RSI_GASTOS)nTotGas FROM "+RetSqlName("RSI") +" RSI WHERE "
		cQrySum	+= "RSI_NUMPED='"+M->RSC_PEDORI+"' AND RSI_FILIAL='"+xFilial("RSI")+"' AND  RSI.D_E_L_E_T_  = ' '"
		cQrySum	:= ChangeQuery(cQrySum)
		DbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQrySum), cAliasRSI, .T., .T. )

		RSI->(DBSetOrder(1))

		TRB->(DBGoTop())
		Do While !TRB->(Eof())
			If Empty(TRB->TRB_OK)
				TRB->(DBSkip())
				Loop
			EndIf
			RSI->(DBSetOrder(1))
			If !RSI->(DBSeek(cFilRSI+M->RSC_PEDORI+TRB->TRB_FACT+TRB->TRB_SERIE+TRB->TRB_PROV+TRB->TRB_TDA+TRB->TRB_ITEM))
				TRB->(DBSkip())
				Loop
			EndIf



			aAdd(aCoGetCosto,Array(nUsado+1))
			NX := Len(aCoGetCosto)
			aCoGetCosto[NX,nPosFac]		:= TRB->TRB_FACT
			aCoGetCosto[NX,nPosSer]		:= TRB->TRB_SERIE
			aCoGetCosto[NX,nPosPro]		:= TRB->TRB_PROV
			aCoGetCosto[NX,nPosTda]		:= TRB->TRB_TDA
			aCoGetCosto[NX,nPosIte]		:= TRB->TRB_ITEM
			aCoGetCosto[NX,nPosPrd]		:= TRB->TRB_PRODUC
			aCoGetCosto[NX,nPosDes]		:= TRB->TRB_DESC
			aCoGetCosto[NX,nPosUM]		:= TRB->TRB_UM
			aCoGetCosto[NX,nPosCan]		:= TRB->TRB_CANT
			aCoGetCosto[NX,nPosUM2]		:= RSI->RSI_UM2
			aCoGetCosto[NX,nPosCan2]	:= RSI->RSI_CANT2
			aCoGetCosto[NX,nPosCos]		:= RSI->RSI_COSTO
			aCoGetCosto[NX,nPosImp]		:= RSI->RSI_COSTO * TRB->TRB_CANT



			aCoGetCosto[NX,nPosPrr]		:= aCoGetCosto[NX,nPosImp]	/ (cAliasRSI)->nTotImp
			aCoGetCosto[NX,nPosGIN]		:= aCoGetCosto[NX,nPosPrr] * (cAliasRSI)->nTotGasI

			nTTotGIn += aCoGetCosto[NX,nPosGIN]

			aCoGetCosto[NX,nPosInc]		:= aCoGetCosto[NX,nPosPrr] * (cAliasRSI)->nTotInc  //Incrementables
			aCoGetCosto[NX,nPosCif]		:= aCoGetCosto[NX,nPosImp] + aCoGetCosto[NX,nPosInc] + aCoGetCosto[NX,nPosGIN]		//Costo CIF
			aCoGetCosto[NX,nPosUNC]		:= aCoGetCosto[NX,nPosCif] / aCoGetCosto[NX,nPosCan]		//Costo unitario CIF

			RSG->(DBSetOrder(1))
			If RSG->(DBSeek(xFilial("RSG")+M->RSC_PEDORI+TRB->TRB_FACT+TRB->TRB_SERIE+TRB->TRB_PROV+TRB->TRB_TDA+TRB->TRB_ITEM))
				If aCoGetCosto[nx,nPosUM] == RSG->RSG_UMC
					aCoGetCosto[nx,nPosUMC] :=	aCoGetCosto[NX,nPosUM]
					aCoGetCosto[nx,nPosExt] :=	aCoGetCosto[NX,nPosCan]
				EndIf
				If  aCoGetCosto[nx,nPosUM2] == RSG->RSG_UMC
					aCoGetCosto[nx,nPosUMC] :=	aCoGetCosto[NX,nPosUM2]
					aCoGetCosto[nx,nPosExt] :=	aCoGetCosto[NX,nPosCan2]
				EndIf
			EndIf

			aCoGetCosto[NX,nPosTax] := SumTaxIte(aCoGetCosto[nx,nPosFac],aCoGetCosto[nx,nPosSer],	aCoGetCosto[nx,nPosPro],aCoGetCosto[nx,npostda],aCoGetCosto[nx,nPosIte],aCoGetCosto[nx,nPosPrr])   //aTax[1]
			aCoGetCosto[Len(aCoGetCosto)][nUsado+1] := .F.

			nTTotImp += aCoGetCosto[nx,nPosImp]
			nTTotPrr += aCoGetCosto[nx,nPosPrr]
			nTTotInc += aCoGetCosto[nx,nPosInc]
			nTTotCif += aCoGetCosto[nx,nPosCif]
			nTTotTax += aCoGetCosto[nx,nPosTax]

			TRB->(DBSkip())
		EndDo
		//Gastos nacionales ocasionados en el pedimento origen
		RSI->(DBSetOrder(1))
		If RSI->(DBSeek(cFilRSI+M->RSC_PEDORI))
			Do While !RSI->(Eof()) .And.  RSI->RSI_FILIAL+RSI->RSI_NUMPED == cFilRSI+M->RSC_PEDORI
				nGasNac += RSI->(RSI_GASTOS)
				RSI->(DBSkip())
			EndDo
		EndIf
		//Gastos nacionales ocasionados por la extraccion
		nTTotGasN := nGasNac

		For NX:=1 To Len(aCoGetTot2)
			nTTotGasN += aCoGetTot2[nx,2]
		NExt
		//Prorrateo de gastos nacionales sobre el costo CIF	 y Calcula el costo final
		For NX := 1 To Len(aCoGetCosto)
			aCoGetCosto[NX,nPosGas] := nTTotGasN * aCoGetCosto[NX,nPosCif] / nTTotCif
			aCoGetCosto[NX,nPosCT ] := aCoGetCosto[NX,nPosCif] + aCoGetCosto[NX,nPosTax]+aCoGetCosto[NX,nPosGas] //GSA 121115 -aCoGetCosto[nx,nPosInc]
			aCoGetCosto[NX,nPosCUn] := aCoGetCosto[NX,nPosCT ] / aCoGetCosto[nx,nPosExt]
		Next

		(cAliasRSI)->(DBCloseArea())
		//Totaliza
		TotCostos(@aCoGetCosto,aHoGetCosto,nUsado,ntTotImp,nTTotPrr,nTTotInc,nTTotCif ,nTTotTax,nTTotGasn,nTTotGIn)

		/*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Guarda en Arreglo, los gastos nacionales prorrateados desglosados por factura³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/
		nPosTip	:= GdFieldPos("RSE_TIPO"	, aHoGetFacts)
		nPosTot	:= GdFieldPos("RSE_VALMER"	, aHoGetFacts)
		nPosFacT	:= GdFieldPos("RSE_TC"		, aHoGetFacts)
		nPosFacF	:= GdFieldPos("RSE_FACT"	, aHoGetFacts)
		nPosSerF	:= GdFieldPos("RSE_SERIE"	, aHoGetFacts)
		nPosProF	:= GdFieldPos("RSE_PROV"	, aHoGetFacts)
		nPosTdaF	:= GdFieldPos("RSE_TDA"		, aHoGetFacts)
		nDeleted	:= GdFieldPos("GDDELETED"	, aHoGetFacts)
		nPosMon	:= GdFieldPos("RSE_MONED"	, aHoGetFacts)

		RSE->(DBSetOrder(1))
		RSF->(DBSetOrder(1))

		aGastos := {}
		For nx := 1 To Len(aCoGetFacts)
			If !aCoGetFacts[Nx,nDeleted]
				If aCoGetFacts[nx,npostip]<>'1' //Si es de gastos
					For ny := 1 To Len(aCoGetCosto)-1
						cTes := ''
						If RSE->(DBSeek(xFilial("RSE")+M->RSC_NUMPED+aCoGetFacts[Nx,nposfacf]+aCoGetFacts[Nx,nposserf]+aCoGetFacts[Nx,nposprof]+aCoGetFacts[Nx,npostdaf]))
							If  RSF->(DBSeek(xFilial("RSF")+M->RSC_NUMPED+RSE->RSE_ITEM))
								cTes := RSF->RSF_TES
							EndIf
						EndIf

						nGasto := aCoGetCosto[NY,nPosGas]

						aAdd(aGastos,{ aCoGetFacts[nx,nPosFacF],;
							aCoGetFacts[nx,nPosSerF],;
							aCoGetFacts[nx,nPosProF],;
							aCoGetFacts[nx,nPosTdaF],;
							aCoGetCosto[nY,nPosIte],;
							aCoGetCosto[nY,nPosPrd],;
							NGASTO,;
							aCoGetFacts[nx,nposmon],;
							aCoGetCosto[ny,nPosFac],;
							aCoGetCosto[ny,nPosSer],;
							aCoGetCosto[ny,nPosPro],;
							aCoGetCosto[ny,nPosTda] ,;
							cTes })
					Next
				EndIf
			EndIf
		Next
	EndIf
	CpyResGetDad(.f.,"oGetCosto")
	if !lAutoTeste
		oGetCosto:Refresh()
	endif

	CursorArrow()

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CalcImpuestos ³Autor ³   Gpe Santacruz.   ³ Data ³ 21/10/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calculo de todos los impuestos del pedimento                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³CalcImpuestos                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Ninguno                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Extraccion por Pedimento                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CalcImpuestos()

	Local nPosCod	:= GdFieldPos("RSD_CODIMP"	, aHoGetImpPed)
	Local nPosImp	:= GdFieldPos("RSD_IMPPAG"	, aHoGetImpPed)

	Local nPosPIVA	:= GdFieldPos("RSD_PORIVA"	, aHoGetImpPed)
	Local nPosIIVA	:= GdFieldPos("RSD_IMPIVA"	, aHoGetImpPed)
	Local nDeleted	:= GdFieldPos("GDDELETED"	, aHoGetImpPed)
	Local nx		:= 0
	Local nTot		:= 0
	Local ntot2		:= 0
	Local nValImp	:= 0
	Local nTotIMP	:= 0
	Local nTotIva	:= 0
	Local cConIva	:= ''
	Local CFILRSA	:= xFilial("RSA")
	Local aBorra	:= {}
	Local cTmp		:= ''
	Local nIVA		:= 16

	Private nPAplDTA := 0	//Numero de partidas del pedimento que aplican DTA
	Private aTNivPed := {}	//Impuestos que se registrraon a nivel pedimento pero afactan, con Su impuesto a cada item
	Private aImpItem := {}	//Impuestos por partida

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Extrae el numero de fracciones que hay en el pedimento, ³
	//³puede ser de uso para calculo de impuestos como DTA     ³
	//³ por extraccion                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	CursorWait()

	If lUsoRSG
		RSB->(DBSetOrder(1))
		TMPRSG->(DBGoTop())
		Do While !TMPRSG->(Eof())
			If RSB->(DBSeek(xFilial("RSB")+TMPRSG->RSG_FRACAR))
				//Si tasa IGI mayor a cero, o si en el pedimento dice que aplica DTA, o si de acuerdo al pais de origen aplica DTA
				If TMPRSG->RSG_APLDTA <> '1'
					nPAplDTA++
				EndIf
			EndIf
			TMPRSG->(DBSkip())
		EndDo
	EndIf

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpia impuestos de RSH, que son iguales a los del pedimento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	If lUsoRSG
		aBorra	:= {}
		nPosCod	:= GdFieldPos("RSD_CODIMP",aHoGetImpPed)

		TMPRSH->(DBGoTop())
		RSA->(DBSetOrder(1))
		Do While !TMPRSH->(Eof())
			If RSA->(DBSeek(xFilial("RSA")+TMPRSH->RSH_IMPUES))
				If RSA->RSA_USOFRA<>'1'
					If aScan(aCoGetImpPed,{|x| AllTrim(x[nPosCod])==AllTrim(TMPRSH->RSH_IMPUES)})>0
						aAdd(aBorra,TMPRSH->(Recno()))
					EndIf
				EndIf
			EndIf
			TMPRSH->(DBSkip())
		EndDo
		For nx := 1 To Len(aBorra)
			TMPRSH->(DbGoTo(aBorra[nx]))
			RecLock("TMPRSH",.F.)
			TMPRSH->(DBDelete())
			TMPRSH->(MSUnlock())
		Next
	EndIf

	//CALCULO DE LOS IMPUESTOS REGISTRADOS EN LA PESTAÑA DE "IMPUESTOS A NIVEL PEDIMENTO"
	For nx := 1 To Len(aCoGetImpPed)
		If !aCoGetImpPed[nx,nDeleted]
			RSA->(DBSetOrder(1))
			If RSA->(DBSeek(xFilial("RSA")+aCoGetImpPed[NX,nPosCod])) .And. !Empty(RSA->RSA_FUNC)
				cFunc	:= AllTrim(RSA->RSA_FUNC) + "()"
				cConIva:= RSA->RSA_APLIVA
				If lUsoRSG .And. RSA->RSA_TIPAPL == '2'  //SI APLICA PARA CADA ITEM DE MERCANCIA
					nTot := 0; ntot2 := 0
					TMPRSG->(DBGoTop())
					Do While !TMPRSG->(Eof())
						nValImp := &cFunc //Execblock(cFunc,.F.,.F.) //LA FUNCION DEBE SER DE USUARIO, SOLO ASI SE PUEDE EJECUTAR POR EXECBLOCK
						If nValImp>0
							RecLock("TMPRSH",.T.)
							TMPRSH->RSH_FACT	:= TMPRSG->RSG_FACT
							TMPRSH->RSH_SERIE	:= TMPRSG->RSG_SERIE
							TMPRSH->RSH_PROV	:= TMPRSG->RSG_PROV
							TMPRSH->RSH_TDA		:= TMPRSG->RSG_TDA
							TMPRSH->RSH_SECC	:= TMPRSG->RSG_SECC
							TMPRSH->RSH_ITEM	:= TMPRSG->RSG_ITEM
							TMPRSH->RSH_IMPUES	:= aCoGetImpPed[NX,nPosCod]
							TMPRSH->RSH_TIPTAS	:= RSA->RSA_TIPO
							TMPRSH->RSH_TASA	:= RSA->RSA_TASIMP
							TMPRSH->RSH_IMPPAG	:= nValImp

							If cConIva == '1' //si grava IVA
								If RSB->(FieldPos("RSB_IVA")) == 0
									TMPRSH->RSH_PORIVA := nP_PORIVA
									TMPRSH->RSH_IMPIVA := nP_PORIVA / 100 * nValImp    //060213
								Else
									If RSA->RSA_USOFRA == '1' //de acuerdo a la fraccion arancelaria asigna el iva   18/09/14
										RSB->(DBSetOrder(1))//RSA_FILIAL+RSA_USOFRA
										If RSB->(DBSeek(xFilial("RSB")+TMPRSG->RSG_FRACAR+TMPRSG->RSG_PAIVTA))
											If  RSB->RSB_IVA=='1' //16%
												TMPRSH->RSH_PORIVA := nIVA
												TMPRSH->RSH_IMPIVA := nIVA / 100 * nValImp
											Else
												TMPRSH->RSH_PORIVA := 0
												TMPRSH->RSH_IMPIVA := 0
											EndIf
										Else
											TMPRSH->RSH_PORIVA := 0
											TMPRSH->RSH_IMPIVA := 0
										EndIf
									Else
										//Inicio Se valida si la fraccion arancelaria aplica IVA
										RSB->(DBSetOrder(1))//RSA_FILIAL+RSA_USOFRA
										If RSB->(DBSeek(xFilial("RSB")+TMPRSG->RSG_FRACAR+TMPRSG->RSG_PAIVTA))
											If  RSB->RSB_IVA=='1' //16%
												TMPRSH->RSH_PORIVA := nP_PORIVA
												TMPRSH->RSH_IMPIVA := nP_PORIVA / 100 * nValImp
											Else
												TMPRSH->RSH_PORIVA := 0
												TMPRSH->RSH_IMPIVA := 0
											EndIf
										EndIf
										//Fin Se valida si la fraccion arancelaria aplica IVA
									EndIf
								EndIf
							EndIf
							TMPRSH->(MSUnlock())
							nTot	+= nValImp
							nTot2	+= TMPRSH->RSH_IMPIVA
							aAdd(aTNivPed,{TMPRSH->RSH_FACT,TMPRSH->RSH_SERIE,TMPRSH->RSH_PROV,TMPRSH->RSH_TDA,TMPRSH->RSH_ITEM,	TMPRSH->RSH_IMPUES,TMPRSH->RSH_IMPPAG,TMPRSH->RSH_IMPIVA})
						EndIf
						TMPRSG->(DBSkip())
					EndDo
					aCoGetImpPed[NX,nPosImp] := ntot
					If cConIva=='1' //si grava IVA
						aCoGetImpPed[NX,nPosPIVA]:= nP_PORIVA
						aCoGetImpPed[NX,nPosIIVA]:= ntot2
					Else
						aCoGetImpPed[NX,nPosPIVA]:= 0
						aCoGetImpPed[NX,nPosIIVA]:= 0
					EndIf
				EndIf
				If RSA->RSA_TIPAPL == '1' //APLICA AL PEDIMENTO
					nValImp := &cFunc //Execblock(cFunc,.F.,.F.) //LA FUNCION DEBE SER DE USUARIO, SOLO ASI SE PUEDE EJECUTAR POR EXECBLOCK
					aCoGetImpPed[NX,nPosImp] := nValImp
					If cConIva == '1' //si grava IVA
						aCoGetImpPed[NX,nPosPIVA] := nP_PORIVA
						aCoGetImpPed[NX,nPosIIVA] := nP_PORIVA / 100 * nValImp //060213
					Else
						aCoGetImpPed[NX,nPosPIVA] := 0
						aCoGetImpPed[NX,nPosIIVA] := 0
					EndIf
				EndIf
			EndIf
		EndIf
	Next

	//Calcula impuestos y Aplic IVA  de los impuestos por item que no se hayan calculado en los impuestos por pedimento
	If lUsoRSG
		RSB->(DBSetOrder(1))//RSA_FILIAL+RSA_USOFRA
		TMPRSH->(DBGoTop())
		Do While !TMPRSH->(Eof())
			If RSA->(DBSeek(xFilial("RSA")+TMPRSH->RSH_IMPUES))
				cFunc		:= AllTrim(RSA->RSA_FUNC)+"()"
				cConIva	:= RSA->RSA_APLIVA
				TMPRSG->(DBSeek(TMPRSH->RSH_FACT+TMPRSH->RSH_SERIE+TMPRSH->RSH_PROV+TMPRSH->RSH_Tda+TMPRSH->RSH_ITEM))
				nValImp := &cFunc //Execblock(cFunc,.F.,.F.) //LA FUNCION DEBE SER DE USUARIO, SOLO ASI SE PUEDE EJECUTAR POR EXECBLOCK

				RecLock("TMPRSH",.F.)
				TMPRSH->RSH_IMPPAG := nValImp

				If RSA->RSA_USOFRA == '1' //Si es impuesto TIGI   18/09/14
					If RSB->(DBSeek(xFilial("RSB")+TMPRSG->RSG_FRACAR+TMPRSG->RSG_PAIVTA))
						If  RSB->RSB_IVA == '1' //16% //Verifica si la fraccion arancelaria aplica IVA
							TMPRSH->RSH_PORIVA := nIVA
							TMPRSH->RSH_IMPIVA := nIVA/100*	nValImp
						Else
							TMPRSH->RSH_PORIVA := 0
							TMPRSH->RSH_IMPIVA := 0
						EndIf
					Else
						TMPRSH->RSH_PORIVA := 0
						TMPRSH->RSH_IMPIVA := 0
					EndIf
				Else   //Si es cualquier otro impuesto queno sea TIGI
					If cConIva == '1' //si grava IVA
						TMPRSH->RSH_PORIVA := nP_PORIVA
						TMPRSH->RSH_IMPIVA := nP_PORIVA/100*TMPRSH->RSH_IMPPAG //060213
					Else
						TMPRSH->RSH_PORIVA := 0
						TMPRSH->RSH_IMPIVA := 0
					EndIf
				EndIf
				TMPRSH->(MSUnlock())
				aAdd(aImpItem,{TMPRSH->RSH_FACT,TMPRSH->RSH_SERIE,TMPRSH->RSH_PROV,TMPRSH->RSH_TDA,TMPRSH->RSH_ITEM,TMPRSH->RSH_IMPUES,TMPRSH->RSH_IMPPAG,TMPRSH->RSH_IMPIVA})
			EndIf
			TMPRSH->(DBSkip())
		EndDo
	EndIf
	CpyResGetDad(.f.,"oGetImpped")
	IF !lAutoTeste
		oGetImpPed:Refresh()
	ENDIF

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Agrupa y totaliza impuestos de importacion³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	nPosDEs	:= GdFieldPos("RSD_CONTR"	, aHoGetImpPed)
	nPosIiva	:= GdFieldPos("RSD_IMPIVA"	, aHoGetImpPed)
	nPosCod	:= GdFieldPos("RSD_CODIMP"	, aHoGetImpPed)
	nDeleted	:= GdFieldPos("GDDELETED"	, aHoGetImpPed)
	CpyResGetDad(.t.,"oGetTot3")
	nUsado		:= Len(aHoGetTot3)
	aImpuesto	:= {}
	nTotImp		:= 0
	nTotIVA		:= 0

	For nx := 1 To Len(aCoGetImpPed)
		If !aCoGetImpPed[nx,nDeleted] .And. !Empty(aCoGetImpPed[nx,nPosCod])
			If (nPos := aScan(aImpuesto,{|x| AllTrim(x[nPosCod]) == AllTrim(aCoGetImpPed[nx,nPosCod])})) > 0
				aImpuesto[nPos,3] += aCoGetImpPed[nx,nPosImp]
			Else
				aAdd(aImpuesto,Array(nUsado+1))
				aImpuesto[Len(aImpuesto), 1			] := aCoGetImpPed[nx,nPosCod]
				aImpuesto[Len(aImpuesto), 2			] := aCoGetImpPed[nx,nPosDes]
				aImpuesto[Len(aImpuesto), 3			] := aCoGetImpPed[nx,nPosImp]
				aImpuesto[Len(aImpuesto), nusado+1	] := .F.
			EndIf
			nTotImp += aCoGetImpPed[nx,nPosImp]
			nTotIVA += aCoGetImpPed[nx,nPosIiva]
		EndIf
	Next

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Agrupa y totaliza impuestos por ITEM ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	RSA->(DBSetOrder(1))
	If lUsoRSG
		TMPRSH->(DBGoTop())
		Do While !TMPRSH->(Eof())
			nEnImpPed := (aScan(aCoGetImpPed,{|x| AllTrim(x[nPosCod]) == AllTrim(TMPRSH->RSH_IMPUES)}))
			If  nEnImpPed == 0
				If (nPos := aScan(aImpuesto,{|x| AllTrim(x[nPosCod]) == AllTrim(TMPRSH->RSH_IMPUES)}))>0
					aImpuesto[nPos,3]+=TMPRSH->RSH_IMPPAG
				Else
					aAdd(aImpuesto,Array(nUsado+1))
					aImpuesto[Len(aImpuesto),1] := TMPRSH->RSH_IMPUES
					If RSA->(DBSeek(CFILRSA+TMPRSH->RSH_IMPUES))
						aImpuesto[Len(aImpuesto),2] := RSA->RSA_DESC
					EndIf
					aImpuesto[Len(aImpuesto),3] := TMPRSH->RSH_IMPPAG
					aImpuesto[Len(aImpuesto),nusado+1] := .F.
				EndIf
				nTotImp += TMPRSH->RSH_IMPPAG
				nTotIVA += TMPRSH->RSH_IMPIVA
			EndIf
			TMPRSH->(DBSkip())
		EndDo
	EndIf

	//Saca y reactualiza los  ivas de cada item
	If lUsoRSG
		TMPRSG->(DBGoTop())
		Do While !TMPRSG->(Eof())
			RecLock("TMPRSG",.F.)
			If  RSB->(FieldPos("RSB_IVA")) == 0
				TMPRSG->RSG_IMPiva := Round(nP_PORIVA / 100 * TMPRSG->RSG_VALADU, 0) //180612
				TMPRSG->RSG_PORIVA := nP_PORIVA
			Else
				If TMPRSH->(DBSeek(TMPRSG->RSG_FACT+TMPRSG->RSG_SERIE+TMPRSG->RSG_PROV+TMPRSG->RSG_Tda+TMPRSG->RSG_ITEM))
					TMPRSG->RSG_IMPiva := Round(TMPRSH->RSH_PORIVA / 100 * TMPRSG->RSG_VALADU, 0) //180612
					TMPRSG->RSG_PORIVA := TMPRSH->RSH_PORIVA
				EndIf

			EndIf
			TMPRSG->(MSUnlock())
			nTotIVA += TMPRSG->RSG_IMPIVA
			TMPRSG->(DBSkip())
		EndDo
	EndIf

	ntotimp += nTotIVA

	If ntotiva > 0
		aAdd(aImpuesto,Array(nUsado+1))
		aImpuesto[Len(aImpuesto), 2			] := " IVA "
		aImpuesto[Len(aImpuesto), 3			] := ntotiVA
		aImpuesto[Len(aImpuesto), nusado+1	] := .F.

	EndIf

	ntotimp := 0
	For nx := 1 To Len(aImpuesto)
		ntotimp += aImpuesto[NX,3]
	Next

	aImpuesto := aSort(aImpuesto,,,{|x,y| x[2] < y[2]})
	aAdd(aImpuesto,Array(nUsado+1))
	aImpuesto[Len(aImpuesto),2] := STR0101 //" Total  ---->"
	aImpuesto[Len(aImpuesto),3] := ntotimp
	aImpuesto[Len(aImpuesto),nusado+1] := .F.

	//Agregar el iva al total del pie de pagina
	aCoGetTot3 := aClone(aImpuesto)
	CpyResGetDad(.F.,"oGetTot3")
	if !lAutoTeste
		oGetTot3:Refresh()
	endif
	CursorArrow()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447CANEXT³Autor ³    Gpe Santacruz.     ³ Data ³ 01/11/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Extrae la cantidad total extraida por pedimento              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447CANEXT(cExp1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.-Numero de Pedimento Origen                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Ninguno                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Extraccion por Pedimento                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MT447CANEXT(CPEDORI)

	Local aCanExt :={}
	Local cQrySum := ""

	cQrySum := "SELECT RSM_NUMPED,RSM_ITEDOC,RSM_ITEM, SUM(RSM_CANT) nTot FROM "+RetSqlName("RSM") +" RSM WHERE "
	cQrySum += "RSM_PEDORI='"+CPEDORI+"' AND RSM_FILIAL='"+xFilial("RSM")+"' AND  RSM.D_E_L_E_T_  = ' '"
	cQrySum += " GROUP BY RSM_NUMPED,RSM_ITEDOC,RSM_ITEM"
	cQrySum := ChangeQuery(cQrySum)
	DbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQrySum), "SUMCAN", .T., .T. )

	Do while  !SUMCAN->(Eof())
		aAdd(aCanExt,{SUMCAN->RSM_ITEDOC,SUMCAN->RSM_ITEM,SUMCAN->nTot})
		SUMCAN->(DBskip())
	EndDo

	SUMCAN->(DBCloseArea())

Return aCanExt

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447PRODEXT³Autor ³    Gpe Santacruz.     ³ Data ³ 01/11/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Crea tabla temporal, para los items de la extraccion por ped. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447PRODEXT(cExp1cExp2)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.-Numero de Pedimento                                   ³±±
±±³          ³ cExp2.-Numero de Pedimento Origen                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Extraccion por Pedimento                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MT447PRODEXT(cNumPed,CPEDORI)

	Local aStru		:= {}
	Local cAliasRSE	:= ''
	Local nPos		:= 0
	Local aCanExt	:= {}
	Local cQryCond	:= ''
	Local cQry		:= ''

	Local aOrdem	:=	{}

	CursorWait()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Arquivo de Trabalho para a escolha dos ensaios ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aStru,{ "TRB_OK"		, "C", 02						, 0})
	aAdd( aStru,{ "TRB_STATUS"	, "C", 1						, 0})
	aAdd( aStru,{ "TRB_ITEM"	, "C", TamSx3("RSF_ITEM")[1]	, 0})
	aAdd( aStru,{ "TRB_PRODUC"	, "C", TamSx3("RSF_PRODUC")[1]	, 0})
	aAdd( aStru,{ "TRB_DESC"	, "C", TamSx3("B1_DESC")[1]		, 0})
	aAdd( aStru,{ "TRB_UM"		, "C", TamSx3("RSF_UM")[1]		, 0})
	aAdd( aStru,{ "TRB_CANTOT"	, "N", TamSx3("RSF_CANT")[1]	, TamSx3("RSF_CANT")[2]})
	aAdd( aStru,{ "TRB_PRECIO"	, "N", TamSx3("RSF_PRECIO")[1]	, TamSx3("RSF_PRECIO")[2]})
	aAdd( aStru,{ "TRB_TOTAL"	, "N", TamSx3("RSF_TOTAL")[1]	, TamSx3("RSF_TOTAL")[2]})
	aAdd( aStru,{ "TRB_CANPEN"	, "N", TamSx3("RSF_CANT")[1]	, TamSx3("RSF_CANT")[2]})
	aAdd( aStru,{ "TRB_CANT"	, "N", TamSx3("RSF_CANT")[1]	, TamSx3("RSF_CANT")[2]})
	aAdd( aStru,{ "TRB_UM2"		, "C", TamSx3("RSF_UM2")[1]		, 0})
	aAdd( aStru,{ "TRB_CANUM2"	, "N", TamSx3("RSF_CANUM2")[1]	, TamSx3("RSF_CANUM2")[2]})
	aAdd( aStru,{ "TRB_ALMACE"	, "C", TamSx3("RSF_ALMACE")[1]	, 0})
	aAdd( aStru,{ "TRB_FACT"	, "C", TamSx3("RSE_FACT")[1]	, 0})
	aAdd( aStru,{ "TRB_SERIE"	, "C", TamSx3("RSE_SERIE")[1]	, 0})
	aAdd( aStru,{ "TRB_PROV"	, "C", TamSx3("RSE_PROV")[1]	, 0})
	aAdd( aStru,{ "TRB_TDA"		, "C", TamSx3("RSE_TDA")[1]		, 0})
	aAdd( aStru,{ "TRB_NOME"	, "C", 30						, 0})
	aAdd( aStru,{ "TRB_ITEDOC"	, "C", TamSx3("RSF_ITEDOC")[1]	, 0})
	aAdd( aStru,{ "TRB_ALMORI"	, "C", TamSx3("RSF_ALMACE")[1]	, 0})

	aOrdem	:=	{"TRB_ITEDOC","TRB_ITEM"}

	oTmpTable := FWTemporaryTable():New("TRB")
	oTmpTable:SetFields(aStru)
	oTmpTable:AddIndex("I2", aOrdem)
	oTmpTable:Create()

    DBSELECTAREA("TRB")

	cAliasRSE	:= CriaTrab(Nil,.F.)
	cQryCond	:= "SELECT RSF_PRODUC, RSF_UM, RSF_CANT, RSF_UM2, RSF_CANUM2, RSF_PRECIO, RSF_TOTAL,   RSF_ITEM,RSF_ITEDOC, RSF_ALMACE, RSE_FACT, RSE_SERIE, RSE_PROV, RSE_TDA, RSE_EMISIO,A2_NOME, B1_DESC, RSM.* "
	cQryCond	+= " FROM "+RetSqlName("RSE") +" RSE, "+RetSqlName("SA2") +" SA2, "+RetSqlName("SB1") +" SB1, " +RetSqlName("RSF") +" RSF "

	cQryCond	+= " LEFT OUTER JOIN " + RetSqlName("RSM") + " RSM"
	cQryCond	+= " ON  RSM_NUMPED ='"+cNumPed+"' AND RSF_NUMPED= RSM_PEDORI AND RSF_ITEDOC= RSM_ITEDOC AND RSF_ITEM =RSM_ITEM AND  RSM_FILIAL='"+xFilial("RSM")+"' AND RSM.D_E_L_E_T_ = ' ' "

	cQryCond	+= " WHERE RSE_NUMPED=RSF_NUMPED  AND RSE_ITEM =RSF_ITEDOC AND RSE_PROV= A2_COD AND RSE_TDA = A2_LOJA AND RSF_PRODUC =B1_COD AND RSF_TIPO='1'  "
	cQryCond	+= " AND RSE_FILIAL='"+xFilial("RSE")+"' AND RSF_FILIAL='"+xFilial("RSF")+"' AND B1_FILIAL='"+xFilial("SB1")+"' AND A2_FILIAL='"+xFilial("SA2")+"' "
	cQryCond	+= " AND RSE_NUMPED='"+CPEDORI+"' "

	cQryCond	+= " AND RSE.D_E_L_E_T_  = ' ' "
	cQryCond	+= " AND RSF.D_E_L_E_T_  = ' ' "
	cQryCond	+= " AND SA2.D_E_L_E_T_  = ' ' "
	cQryCond	+= " AND SB1.D_E_L_E_T_  = ' ' "

	cQry := cQryCond + "   ORDER BY RSF_PRODUC "
	cQry := ChangeQuery(cQry)

	DbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQry), cAliasRSE, .T., .T. )
	TCSetField(cAliasRSE,"RSE_EMISIO","D")

	If !(cAliasRSE)->(Eof())
		aCanExt := MT447CANEXT(CPEDORI) //Suma de todas extracciones que se han realizado al pedimento origen
	EndIf

	Do While !(cAliasRSE)->(Eof())
		RecLock("TRB",.T.)
		TRB->TRB_PRODUC	:= (cAliasRSE)->RSF_PRODUC
		TRB->TRB_DESC	:= (cAliasRSE)->B1_DESC
		TRB->TRB_UM		:= (cAliasRSE)->RSF_UM
		TRB->TRB_UM2	:= (cAliasRSE)->RSF_UM2
		TRB->TRB_CANUM2 :=(cAliasRSE)->RSF_CANUM2
		TRB->TRB_PRECIO :=(cAliasRSE)->RSF_PRECIO
		TRB->TRB_TOTAL  :=(cAliasRSE)->RSF_TOTAL

		If !Empty((cAliasRSE)->RSM_ITEM)
			TRB->TRB_CANT	:= (cAliasRSE)->RSM_CANT
			TRB->TRB_OK		:= CMARCA
			TRB->TRB_ALMACE	:= (cAliasRSE)->RSM_ALMACE
		EndIf

		nPos:=aScan(aCanExt,{|x| AllTrim(x[1])+AllTrim(x[2])==AllTrim((cAliasRSE)->RSF_ITEDOC)+AllTrim((cAliasRSE)->RSF_ITEM)})
		If npos>0
			TRB->TRB_CANPEN	:= (cAliasRSE)->RSF_CANT-aCanExt[npos,3]

		Else
			TRB->TRB_CANPEN	:= (cAliasRSE)->RSF_CANT
		EndIf
		TRB->TRB_ALMORI	:= (cAliasRSE)->RSF_ALMACE
		TRB->TRB_CANTOT	:= TRB->TRB_CANPEN //GSA

		TRB->TRB_FACT  	:= (cAliasRSE)->RSE_FACT
		TRB->TRB_SERIE 	:= (cAliasRSE)->RSE_SERIE
		TRB->TRB_PROV  	:= (cAliasRSE)->RSE_PROV
		TRB->TRB_TDA   	:= (cAliasRSE)->RSE_TDA
		TRB->TRB_NOME  	:= (cAliasRSE)->A2_NOME
		TRB->TRB_ITEM  	:= (cAliasRSE)->RSF_ITEM
		TRB->TRB_ITEDOC	:= (cAliasRSE)->RSF_ITEDOC

		TRB->(MSUnlock())
		(cAliasRSE)->(DBSkip())
	EndDo

	(cAliasRSE)->(DBCloseArea())
	lUsoFac:= .T.

	CursorArrow()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MT447VLDIVA³ Autor ³    Gpe Santacruz.     ³ Data ³29/11/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Actualiza el valor del para el calculo de impuetos          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MT447VLDIVA()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³.T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_VALID del campo RSC_IVA                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447VLDIVA()
	nP_PORIVA := M->RSC_IVA
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MT447OC2 ³ Autor ³     Gpe Santacruz.    ³ Data ³29/11/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pantalla de importacion de Items de Pedidos de Compra      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MT447OC2()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ Ninguno                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA447                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447OC2()

	Local aArea      := GetArea()
	Local aAreaSB1   := SB1->(GetArea())
	Local aCab       := {}
	Local aArrSldo   := {}
	Local aArrayF4   := {}
	Local aNewArray  := {}
	Local aButtons   := {}
	Local nPosPrd    := aScan(aHoGetItemF, {|x| Alltrim(x[2]) == "RSF_PRODUC"})
	Local nPosNumPo  := aScan(aHoGetItemF, {|x| Alltrim(x[2]) == "RSF_PEDIDO"})
	Local nPosItemPo := aScan(aHoGetItemF, {|x| Alltrim(x[2]) == "RSF_ITEMPC"})
	Local nPosQTD    := aScan(aHoGetItemF, {|x| Alltrim(x[2]) == "RSF_CANT" })
	Local nPosItDoc  := aScan(aHoGetFacts, {|x| AllTrim(x[2]) == "RSE_ITEM"})
	Local nPosItem   := aScan(aHoGetItemF, {|x| Alltrim(x[2]) == "RSF_ITEM"  })
	Local nPosCF     := aScan(aHoGetFacts, {|x| Alltrim(x[2]) == "RSE_PROV"})
	Local nPosLoja   := aScan(aHoGetFacts, {|x| Alltrim(x[2]) == "RSE_TDA"  })
	Local nPosMoeda  := aScan(aHoGetFacts, {|x| Alltrim(x[2]) == "RSE_MONED" })
	Local nPosTipo   := aScan(aHoGetFacts, {|x| AllTrim(x[2]) == "RSE_TIPO"})
	Local nPosDesc   := GdFieldPos("RSF_DESC  ", aHoGetItemF)
	Local nFreeQt    := 0
	Local nSavQual   := 0
	Local nX         := 0
	Local nY         := 0
	Local nZ     	   := 0
	Local nOpca      := 0
	Local nSalPed    := 0
	Local nMoeda     := aCoGetFacts[nNoGetFacts,nPosMoeda]

	Local cTipoNFe   := aCoGetFacts[nNoGetFacts,nPosTipo]
	Local cSeek      := ''
	Local cItDoc     := ""
	Local cItem      := ""

	Local oQual
	Local oDlg

	Local lAllPC     := .T.
	Local lExiste    := .F.
	Local oOk        := LoadBitMap(GetResources(), "LBOK")
	Local oNo        := LoadBitMap(GetResources(), "LBNO")
	Local aSelItem   := {}
	Local nitem      := 0
	Local cVar       := ''
	Local oObj       := Nil //Objeto de Grupo de Preguntas
	Local aX1Pre     := {}
	Local lFilPre    := .F.

	Local CFILRSF    := ''
	Local nCanReg    := 0
	Local nCanAct    := 0
	local lDel2 	 := .F.
	local nDeleted   := 0
	Local nTamRows	 := 0

	Local bActiva	:={||lActiva := (if((len(oQual:aarray) > 0 .and. !empty(oQual:aarray[1,2]) ), .t.,.f.))}
	Local bMarcTod 	:={||(MarcProd(oQual , @aArrayF4 , @oDlg , "M" ),oQual:nColPos := 1,oQual:Refresh())}
	Local bDesmTod 	:={||(MarcProd(oQual , @aArrayF4 , @oDlg , "D" ),oQual:nColPos := 1,oQual:Refresh())}
	Local bInverte 	:={||(MarcProd(oQual , @aArrayF4 , @oDlg , "I" ),oQual:nColPos := 1,oQual:Refresh())}

	Private N := 0

	If oFoldMT447:nOption <> 6
		MsgInfo(STR0118) //"Para seleccionar Item por Orden de Compra, debe estar en la pestaña de Items de factura, y que sean facturas de Mercancia"
		Return
	EndIf
	CpyResGetDad(.T.,"oGetItemF")
	nDeleted := GdFieldPos("GDDELETED",aHoGetItemF)

	If cTipoNFe == "1"//Mercancia

		If !Empty(aCoGetItemF[nNoGetItemF])
			If aCoGetItemF[nNoGetItemF,nDeleted] == .T.
				lDel2 = .T.
				CpyResGetDad(.f.,"oGetItemF")
			EndIF
		EndIF

		DBSelectArea("SC7")
		If Empty(aCoGetItemF[nNoGetItemF,nPosPrd])
			DBSetOrder(9)
			cSeek:=aCoGetFacts[nNoGetFacts,nPosCF] + aCoGetFacts[nNoGetFacts,nPosLoja]
			oObj := FWSX1Util():New()
			oObj:AddGroup("MT447PRG")
			oObj:SearchGroup()
			aX1Pre := oObj:GetGroup("MT447PRG")
			If Len(oObj:AGRUPO[1][2]) > 0
				If !Pergunte("MT447PRG",.T.)
					Return Nil
				EndIf
				lFilPre := .T.
			EndIf
		Else
			DBSetOrder(6)
			cSeek := aCoGetItemF[nNoGetItemF,nPosPrd] + aCoGetFacts[nNoGetFacts,nPosCF] + aCoGetFacts[nNoGetFacts,nPosLoja]
			cVar:=AllTrim(aCoGetItemF[nNoGetItemF,nPosPrd])+"  "+aCoGetItemF[nNoGetItemF,nPosDesc]
		EndIf
		CfIL:=xFilEnt(xFilial("SC7"))
		MsSeek(CfIL+cSeek)

		If !Eof()
			If Empty(aCoGetItemF[nNoGetItemF,nPosPrd])
				cCond := "C7_FILENT+C7_FORNECE+C7_LOJA"
			Else
				cCond := "C7_FILENT+C7_PRODUTO+C7_FORNECE+C7_LOJA"
			EndIf

			While !Eof() .And. CFIL+cSeek == &(cCond)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Filtra las ordenes de compra                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (GetMV("MV_RESTNFE") == "S" .And. C7_CONAPRO == "B") .Or. C7_TPOP == "P" .Or. SC7->C7_MOEDA <> nMoeda
					dbSkip()
					Loop
				EndIf
				If lFilPre
					If !(SC7->C7_NUM >= MV_PAR01 .AND. SC7->C7_NUM <= MV_PAR02 .AND. SC7->C7_EMISSAO >= MV_PAR03 .AND. SC7->C7_EMISSAO <= MV_PAR04) .And. Empty(aCoGetItemF[nNoGetItemF,nPosPrd])
						SC7->(dbSkip())
						Loop
					EndIf
				EndIf
				If Empty(SC7->C7_RESIDUO)
					lExiste := .F.
					ExtrCantOC(@nCanReg,@nFreeQT,SC7->c7_filent,SC7->c7_num,SC7->c7_item,SC7->c7_produto,SC7->C7_QTDACLA)

					If ((nFreeQT := (SC7->C7_QUANT-SC7->C7_QUJE-nCanReg-nFreeQT)) > 0)
						AAdd( aArrayF4,{ .F.,SC7->C7_LOJA,;
							SC7->C7_NUM,;
							SC7->C7_ITEM,;
							TransForm(nFreeQT,PesqPict("SC7","C7_QUANT")),;
							DTOC(SC7->C7_DATPRF),;
							SubSTR(SC7->C7_PRODUTO,1,15),;
							SubSTR(SC7->C7_DESCRI,1,20),;
							"PO",;
							TransForm(SC7->C7_PRECO,PesqPict("SC7","C7_PRECO")) ,;
							DTOC(SC7->C7_EMISSAO) ,;
							SC7->C7_Local ,;
							SC7->C7_OBS } )
						AAdd( aArrSldo,{nFreeQT,Recno()} )
					EndIf
				EndIf
				SC7->(dbSkip())
			EndDo

			If !Empty(aArrayF4)
				aCab	:= {STR0144,STR0145,STR0146,STR0147,STR0148,STR0149,STR0150,STR0151,STR0152,STR0153,STR0154,STR0155,STR0156} //"Sel","Tienda","Orden","Ítem","Saldo","Entrega","Producto","Descripción","Tipo","Prc. Unit.","Emisión","Local","Obser."
				cLine	:= "{If(aArrayF4[oQual:nAt,1],oOk,oNo),aArrayF4[oQual:nAT][2],aArrayF4[oQual:nAT][3],aArrayF4[oQual:nAT][4],aArrayF4[oQual:nAT][5],aArrayF4[oQual:nAT][6],  "
				cLine	+= " aArrayF4[oQual:nAT][7],aArrayF4[oQual:nAT][8],aArrayF4[oQual:nAT][9],aArrayF4[oQual:nAT][10],aArrayF4[oQual:nAT][11],aArrayF4[oQual:nAT][12],aArrayF4[oQual:nAT][13] } "
				if !lAutoTeste
					DEFINE FONT oFont NAME "Arial" SIZE 0,-11  BOLD

					DEFINE MSDIALOG oDlg TITLE (STR0119) FROM 010,010 TO 630,1300 OF oMainWnd PIXEL //"Seleccione la Orden de Compra"
					oQual := TWBrowse():New(45,2,642,240,,aCab,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

					oQual:SetArray(aArrayF4)
					oQual:bLDblClick	:= {|| aArrayF4[oQual:nAt,1] := !aArrayF4[oQual:nAt,1] }
					oQual:bLine			:= &("{ || " + cLine + " }" )

					oBtnMarcTod	:= tButton():New(290,240, STR0161 ,, bMarcTod, 58, 13.50  ,,,.F.,.T.,.F.,,.F.,bActiva,,.F. )	 //"Marca todo"
					oBtnDesmTod	:= tButton():New(290,305, STR0162 ,, bDesmTod, 58, 13.50  ,,,.F.,.T.,.F.,,.F.,bActiva,,.F. )	 //"Desmarca todo"
					oBtnInverte	:= tButton():New(290,370, STR0163 ,, bInverte, 58, 13.50  ,,,.F.,.T.,.F.,,.F.,bActiva,,.F. ) 	//"Inv. seleccion"

					If !Empty(aCoGetItemF[nNoGetItemF,nPosPrd])
						@ 035,002 SAY STR0091 + cVar Of oDlg PIXEL SIZE 150,009  FONT oFont //"Producto : "
					EndIf

					ACTIVATE MSDIALOG oDlg centered ON INIT EnchoiceBar(oDlg,{|| aSelItem:=oQual:AARRAY,nSavQual:=oQual:nAT,nOpca:=1,oDlg:End()},{||oDlg:End()},,aButtons)
				endif
				If nOpca == 1
					If !MsgYesNo(STR0120) //"Se agregaran los ítems seleccionados a los ítems de la factura seleccionada. ¿Continuar?"
						MsgInfo(STR0121)  //"Proceso Cancelado"
					Else
						If lDel2
							MT447DEL2()
						EndIf
						CursorWait()
						cItDoc	:= aCoGetFacts[nNoGetFacts,nPosItDoc]
						nTamRows:= Len(aCoGetItemF)
						cItem	:= aCoGetItemF[nTamRows,npositem]
						If !Empty(aCoGetItemF[nTamRows,nposprd])
							cItem := soma1(citem)
							nTamRows += 1 
						EndIf
						//Inserta los items seleccionados
						For nx := 1 To Len(aSelItem)
							If aSelItem[nx,1]
								DBSelectArea("SC7")
								SC7->(DBGoTo(aArrSldo[nx][2]))
								nSalPed := aArrSldo[Nx][1]
								If AllTrim(aCoGetItemF[nNoGetItemF,nPosNumPo])== AllTrim(aSelItem[nx,3]) .And.;
										AllTrim(aCoGetItemF[nNoGetItemF,nPosItemPo])== AllTrim(aSelItem[nx,4])
									cItem := aCoGetItemF[nNoGetItemF,nPosItem]
									Po2Acols(SC7->(RecNo()),nNoGetItemF,nSalPed,cItem,cItDoc,.F.)
								Else
									Po2Acols(SC7->(RecNo()),nTamRows,nSalPed,cItem,cItDoc,.T.)
									cItem  :=  Soma1(citem)
									nTamRows += 1 
								EndIf
								N += 1
								aAdd(aCols,aCoGetItemF[N])
								MaFisRef("IT_PRCUNI","MT120",SC7->C7_PRECO)
								MaFisRef("IT_VALMERC","MT120",SC7->C7_TOTAL)
							EndIf
						Next
						CursorArrow()
					EndIf
				EndIf
			Else
				Help(" ", 1, STR0023,,STR0122, 1, 0) // "Aviso",,"No existe orden de compras para ese proveedor y tipo de moneda!"
			EndIf
		Else
			Help(" ", 1, STR0023,,STR0123, 1, 0)  // "Aviso",  "No existe orden de compras para ese proveedor!"
		EndIf
	Else
		Help(" ", 1, STR0023,,STR0124, 1, 0) //"Aviso",  "La carga de Ordenes de Compras solo puede ser realizada sobre las facturas de Mercancía"
	EndIf

	RestArea(aAreaSB1)
	RestArea(aArea)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Po2Acols  ³Autor  ³Gpe Santacruz          ³Data  ³05/12/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Pasa la informacion del Pedido de Compra al Acols de los     ³±±
±±³          ³items                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nxpN1 : Numero de registro de SC7                            ³±±
±±³          ³nxpN2 : Numero de Item                                       ³±±
±±³          ³nxpN3 : Saldo de la cantidad del pedido de compra            ³±±
±±³          ³cExp1 : Numero de item a sercargadoi en el aCols             ³±±
±±³          ³cExp2 : Numero de item del encabezado de la factura          ³±±
±±³          ³lExp1 : .T. Nuevo item, .F. Item creado                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Po2Acols(nRecSC7,nItem,nSalPed,cItem,cItDoc,laColsAdd)

	Local nPosTxMoed:= aScan(aHoGetFacts,{|x| Alltrim(x[2]) == "RSE_TASA" })
	Local nPosTES   := aScan(aHoGetItemF,{|x| Alltrim(x[2]) == "RSF_TES" })
	Local nPosItDoc := aScan(aHoGetItemF,{|x| Alltrim(x[2]) == "RSF_ITEDOC"  })
	Local nPosCan	:= aScan(aHoGetItemF,{|x| Alltrim(x[2]) == "RSF_CANT"  })
	Local nX        := 0
	Local nPosC     := 0
	Local nPosPrd	:= aScan(aHoGetItemF,{|x| Alltrim(x[2]) == "RSF_PRODUC"})
	Local cImp      := ''
	CpyResGetDad(.t.,"oGetItemF")//copia a GetDados
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona nueno registro en el aCols                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nItem > Len(aCoGetItemF)
		If laColsAdd
			aAdd(aCoGetItemF,Array(Len(aHoGetItemF)+1))
		EndIf
		For nX := 1 To Len(aHoGetItemF)
			Do Case
			Case Trim(aHoGetItemF[nX][2]) == "RSF_ITEM"
				aCoGetItemF[nItem][nX] :=cItem

			Case Trim(aHoGetItemF[nX][2]) == "RSF_ITEDOC"
				aCoGetItemF[nItem][nX] := cItDoc
			EndCase

		Next nX
		aCoGetItemF[Len(aCoGetItemF)][Len(aHoGetItemF)+1] := .F.

	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona registro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DBSelectArea("SC7")
	MsGoto(nRecSC7)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Actualiza el aCols con la informacion de SC7³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aHoGetItemF)
		Do Case
		Case Trim(aHoGetItemF[nX][2]) == "RSF_ITEDOC"
			aCoGetItemF[nItem][nX] := cItDoc
		Case Trim(aHoGetItemF[nX][2]) == "RSF_PRODUC"
			aCoGetItemF[nItem][nX] := SC7->C7_PRODUTO
		Case Trim(aHoGetItemF[nX][2]) == "RSF_TOTAL"
			aCoGetItemF[nItem][nX] :=  nSalPed * SC7->C7_PRECO
		Case Trim(aHoGetItemF[nX][2]) == "RSF_CANT"
			aCoGetItemF[nItem][nX] := nSalPed
		Case Trim(aHoGetItemF[nX][2]) == "RSF_PRECIO"
			aCoGetItemF[nItem][nX] := SC7->C7_PRECO
		Case Trim(aHoGetItemF[nX][2]) == "RSF_PEDIDO"
			aCoGetItemF[nItem][nX] := SC7->C7_NUM
		Case Trim(aHoGetItemF[nX][2]) == "RSF_ITEMPC"
			aCoGetItemF[nItem][nX] := SC7->C7_ITEM
		Case Trim(aHoGetItemF[nX][2]) == "RSF_DESC"
			aCoGetItemF[nItem][nX] := SC7->C7_DESCRI
		Case Trim(aHoGetItemF[nX][2]) == "RSF_TES"
			aCoGetItemF[nItem][nX] := SC7->C7_TES
		Case Trim(aHoGetItemF[nX][2]) == "RSF_ALMACE"
			aCoGetItemF[nItem][nX] := SC7->C7_LOCAL
		Case Trim(aHoGetItemF[nX][2]) == "RSF_UM"
			aCoGetItemF[nItem][nX] := SC7->C7_UM
		Case Trim(aHoGetItemF[nX][2]) == "RSF_UM2"
			aCoGetItemF[nItem][nX] := SC7->C7_SEGUM
		Case Trim(aHoGetItemF[nX][2]) == "RSF_CC"
			aCoGetItemF[nItem][nX] := SC7->C7_CC
		Case Trim(aHoGetItemF[nX][2]) == "RSF_CLVL"
			aCoGetItemF[nItem][nX] := SC7->C7_CLVL
		Case Trim(aHoGetItemF[nX][2]) == "RSF_CONTA"
			aCoGetItemF[nItem][nX] := SC7->C7_CONTA
		Case Trim(aHoGetItemF[nX][2]) == "RSF_ITCTA"
			aCoGetItemF[nItem][nX] := SC7->C7_ITEMCTA
		Case Trim(aHoGetItemF[nX][2]) == "RSF_CANUM2"
			aCoGetItemF[nItem][nX] := nSalPed*SC7->C7_QTSEGUM/SC7->C7_QUANT
		Case SubSTR(Trim(aHoGetItemF[nX][2]),1,9) $ "RSF_ALIMP"
			cImp := SubSTR(Trim(aHoGetItemF[nX][2]),10,1)
			aCoGetItemF[nItem][nX] := &("SC7->C7_ALQIMP"+cImp)
		Case SubSTR(Trim(aHoGetItemF[nX][2]),1,9) $ "RSF_VLIMP"
			cImp := SubSTR(Trim(aHoGetItemF[nX][2]),10,1)
			If &("SC7->C7_VALIMP"+cImp)>0
				aCoGetItemF[nItem][nX] := &("SC7->C7_VALIMP"+cImp)*nSalPed/SC7->C7_QUANT
			EndIf
		Case SubSTR(Trim(aHoGetItemF[nX][2]),1,9) $ "RSF_BSIMP"
			cImp := SubSTR(Trim(aHoGetItemF[nX][2]),10,1)
			If &("SC7->C7_BASIMP"+cImp)>0
				aCoGetItemF[nItem][nX] := &("SC7->C7_BASIMP"+cImp)*nSalPed/SC7->C7_QUANT
			EndIf
		OtherWise
			If Empty(aCoGetItemF[nItem,nX])
				aCoGetItemF[nItem,nX] := CriaVar(aHoGetItemF[nX][2])
			EndIf
		EndCase
	Next nX

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Crea arreglo para poder hacer uso de la funcion MAFISREF, que es ejecutada³
	//³en casi todos los campos (x3_valid), de RSF                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	If MaFisFound()
		MaFisIniLoad(nItem) //inicia la estructura del arreglo aNfItem
		For nX := 1 To Len(aRefImpRSF)
			nPosC := GdFieldPos(aRefImpRSF[nX][2],aHoGetItemF)
			If nPosC == 0
				Help( " ", 1, STR0023,,STR0125+aRefImpRSF[nX][2] +STR0126, 1, 0 ) //"Aviso",,"Error Función Po2Acols(): No encontro campo "+aRefImpRSF[nX][2] +" en el encabezado del oGetItemF"
			EndIf
			MaFisLoad(aRefImpRSF[nX][3],aCoGetItemF[nItem,nPosC],nItem)  //Carga valores a aNfItem
		Next nX
		MaFisEndLoad(nItem)
	EndIf
	CpyResGetDad(.f.,"oGetItemF")//Restaura GetDados
	//Valida que la linea tenga todo lo necesario
	lRetorno := MT447LOk2()

	//Refresca el getdados ya con el acosl incluido
	if !lAutoTeste
		nPos := oGetItemF:OBROWSE:NROWPOS
		oGetItemF:ForceRefresh()
		oGetItemF:GoTo(nPos)
	endif

Return .T.

/*ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MT447VLDCOC³Autor  ³Gpe Santacruz          ³Data  ³05/12/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida que la cantidad no exceda a la contenida en el         ³±±
±±³          ³pedido de compra                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExp1 : Cantidad                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. .- Si no excede; .F. .- Si excede                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³   X3_VALIDA del campo RSF_CANT                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447VLDCOC(NCant)

	Local aArea      := GetArea()
	Local lRet       := .T.
	Local nPosOC     :=0
	Local nPosItemOC := 0
	Local cQuery     := ''
	Local cNumOc     := ''
	Local cItemOc    := ''
	Local cFilEnt    := ''
	Local cAliasSC7  := ''

	CpyResGetDad(.t.,"oGetItemF")

 	nPosOC     := aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_PEDIDO"})
	If !Empty(aCoGetItemF[nNoGetItemF,nposOc])
		//Saca el total de productos distribuido en las diferentes facturas
		nPosItemOC	:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_ITEMPC"})
		nPosPrd		:= aScan(aHoGetItemF,{|x| AllTrim(x[2]) == "RSF_PRODUC"})
		cNumOc		:= aCoGetItemF[nNoGetItemF,nPosOC]
		cItemOc		:= aCoGetItemF[nNoGetItemF,nPosItemOC]

		cFilEnt := xFilEnt(xFilial("SC7"))
		SC7->(DBSetOrder(14))
		If SC7->(DBSeek(cFilEnt+cNumOc+cItemOc))
			ncanreg := 0
			nFreeQT := 0
			If AllTrim(SC7->c7_produto) <> AllTrim(aCoGetItemF[nNoGetItemF, nPosPrd]     )
				Help(" ", 1, STR0023, , STR0127 + cNumOc + " " + cItemOc, 1, 0) //"Aviso",,"El producto, no corresponde al contenido en la orden e item "
				lRet := .F.
			Else
				ExtrCantOC(@nCanReg,@nFreeQT,SC7->c7_filent,SC7->c7_num,SC7->c7_item,SC7->c7_produto,SC7->C7_QTDACLA)
				If (NCant > (nFreeQT := (SC7->C7_QUANT-SC7->C7_QUJE-nCanReg-nFreeQT)))
					MsgInfo(STR0128+cNumOc+" "+cItemOc+STR0129+AllTrim(Str(nFreeQT))+STR0130) //"En la orden de compra "+cNumOc+" "+cItemOc+", solo hay "+AllTrim(Str(nFreeQT))+" !, cambie la orden de compra o la cantidad."
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ExtrCantOC³Autor  ³Gpe Santacruz          ³Data  ³06/12/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Extrae la cantidad de producto aun existente en el pedido de ³±±
±±³          ³compra.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³@nExp1 : Cantidad de producto del OC ya clasificada          ³±±
±±³          ³@nExp2 : Cantidad utilizada en el pedimento actual           ³±±
±±³          ³cExp1  : Codigo de filial de entrega.                        ³±±
±±³          ³cExp2  : Numero de orden de compra.                          ³±±
±±³          ³cExp3  : Item de orden de compra                             ³±±
±±³          ³cExp4  : Codigo de producto                                  ³±±
±±³          ³cExp5  : SC7->c7_qtdacla                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nExp1, nExp2                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA447                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ExtrCantOC(nCanReg,nFreeQT,cFil,cOc,cItemOc,cPrd,nQtdacla)

	Local nPosItDoc  := aScan(aHoGetFacts, {|x| AllTrim(x[2]) == "RSE_ITEM"})
	Local nPosPrd    := aScan(aHoGetItemF, {|x| Alltrim(x[2]) == "RSF_PRODUC"})
	Local nPosNumPo  := aScan(aHoGetItemF, {|x| Alltrim(x[2]) == "RSF_PEDIDO"})
	Local nPosItemPo := aScan(aHoGetItemF, {|x| Alltrim(x[2]) == "RSF_ITEMPC"})
	Local nPosQTD    := aScan(aHoGetItemF, {|x| Alltrim(x[2]) == "RSF_CANT" })
	Local nPosItem   := aScan(aHoGetItemF, {|x| Alltrim(x[2]) == "RSF_ITEM"  })
	Local nCanAct    := 0
	Local nz         := 0
	Local nx         := 0
	Local ny         := 0
	Local CFILRSF    := xFilial("RSF")

	RSF->(DBSetOrder(RETORDEM("RSF","RSF_FILIAL+RSF_PEDIDO+RSF_ITEMPC+RSF_PRODUC")))

	//Extrae todo lo registrado de la OC del pedimento actual
	nCanReg := 0

	If RSF->(DBSeek(CFILRSF+cOc+cItemOc+cPrd ))
		Do While !RSF->(Eof()) .And. cFil+cOc+cItemOc+cPrd == CFILRSF+RSF->RSF_PEDIDO+RSF->RSF_ITEMPC+RSF->RSF_PRODUC
			If RSF->RSF_NUMPED == M->RSC_NUMPED
				nCanReg += RSF->RSF_CANT
			EndIf
			RSF->(DBSkip())
		EndDo
	EndIf

	nCanReg := nQtdacla - nCanReg

	//Extrae lo que hay en el pedimento actual  sin considerar el getdados actual
	nCanAct := 0
	For nZ := 1 To Len(aColsIt)
		For nY := 1 To Len(aColsIt[nZ])
			If !aColsIt[nZ][nY][Len(aColsIt[nZ][nY])] .And. nZ <> Val(aCoGetFacts[nNoGetFacts,nPosItDoc])
				If aColsIt[nZ][nY][nPosNumPo] == cOc .And. aColsIt[nZ][nY][nPosItemPo] == cItemOc .And. aColsIt[nZ][nY][nPosPrd] == cPrd
					nCanAct+=aColsIt[nZ][nY][nPosQTD]
				EndIf
			EndIf
		Next nY
	Next nZ

	//Extrae las cantidades del getdados actual sin considerar la linea actual
	nFreeQT := 0
	For nX := 1 To Len( aCoGetItemF )
		If nX # nNoGetItemF .And. !ATail(aCoGetItemF[nX]) .And.  aCoGetItemF[nX,nPosPRD] ==cPrd.And. aCoGetItemF[nX,nPosNumPo] ==cOc.And. aCoGetItemF[nX,nPosItemPo] == cItemOc
			nFreeQT += aCoGetItemF[ nX,nPosQTD ]
		EndIf
	Next

	nFreeQT += nCanAct

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447FILTRO³Autor ³    Gpe Santacruz.     ³ Data ³ 08/03/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Para la consulta std RSC filtra los pedidos origen, si el    ³±±
±±³          ³pedimento a registrar es de Extraccion                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447FILTRO                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Filtro                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Consulta std RSC                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447FILTRO()

Local cFiltro := '.T.'

If LMT447EXT
	cFiltro := "ALLTRIM(RSC->RSC_CVEPED) $ cLisDep .AND. RSC->RSC_STATUS=='2'"
EndIf
If LMT447Rec
	cFiltro := " RSC->RSC_STATUS=='2'"
EndIf

Return &cFiltro

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447CPYPED³Autor ³    Gpe Santacruz.     ³ Data ³ 08/03/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Copia pedido original al pedido de rectificacion             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447CPYPED(cExp1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Numero del pedimento origen                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lExp1.- Si existe el pedimento en RSC                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Dentro de la funcio MT447PEDORI                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447CPYPED(cPedOri)

	Local nx       := 0
	Local nY       := 0
	Local nz       := 0
	Local nPosItem := aScan(aHoGetItemF,{|x| Alltrim(x[2]) == "RSF_ITEM"  })
	Local lCopia   := .T.
	Local nz2      := 0

	If !lX001Auto
		If !msgYesNo(STR0131)  //"Copiar los datos del pedimento origen?"
			lCopia := .F.
		EndIf
	EndIf
	If lCopia
		CursorWait()
		RSO->(DBSetOrder(1))  //Datos del transporte

		If RSO->(DBSeek(xFilial("RSO")+RSC->RSC_NUMPED))
			For NX:=1 To Len(oEnchRSO:AGETS)
				&("M->"+SubSTR(oEnchRSO:AGETS[NX],9,10)):=&("RSO->"+SubSTR(oEnchRSO:AGETS[NX],9,10))
			Next
		EndIf
		CpyResGetDad(.t.,"oGetIncrem")
		CpyResGetDad(.t.,"oGetImpPed")
		CpyResGetDad(.t.,"oGetFacts")
		CpyResGetDad(.t.,"oGetItemF")
		CpyResGetDad(.t.,"oGetCosto")

		LlenaGetDados("RSK", aHoGetIncrem	, @aCoGetIncrem	, "RSC->RSC_NUMPED","RSC->RSC_FILIAL+RSC->RSC_NUMPED==RSK->RSK_FILIAL+RSK->RSK_NUMPED",1)
		LlenaGetDados("RSD", aHoGetImpPed	, @aCoGetImpPed	, "RSC->RSC_NUMPED","RSC->RSC_FILIAL+RSC->RSC_NUMPED==RSD->RSD_FILIAL+RSD->RSD_NUMPED",1)
		LlenaGetDados("RSE", aHoGetFacts		, @aCoGetFacts	, "RSC->RSC_NUMPED","RSC->RSC_FILIAL+RSC->RSC_NUMPED==RSE->RSE_FILIAL+RSE->RSE_NUMPED",2)
		CpyResGetDad(.F.,"oGetIncrem")
		CpyResGetDad(.F.,"oGetImpPed")
		CpyResGetDad(.F.,"oGetFacts")



		LlenaItems(aHoGetItemF,@aCoGetItemF)
		CpyResGetDad(.F.,"oGetItemF")
		LlenaCostos("RSI",aHoGetCosto,@aCoGetCosto,"RSC->RSC_NUMPED","RSC->RSC_FILIAL+RSC->RSC_NUMPED==RSI->RSI_FILIAL+RSI->RSI_NUMPED",1)
		CpyResGetDad(.F.,"oGetCosto")
		LlenaTMP() //Coloca en tablas temporales la informacion de RSG y RSH
		IF !lAutoTeste
			oEnchRSO:Refresh()

			oGetIncrem:ForceRefresh()
			oGetImpPed:ForceRefresh()
			oGetFacts:ForceRefresh()
			oGetItemF:ForceRefresh()
			oGetCosto:ForceRefresh()
        ENDIF
		If Len(aCoGetFacts) > 0
			IF (!lAutoTeste, oGetFacts:LMODIFIED := .T.,)
			For NX := 1 To Len(aCoGetFacts)
				nNoGetFacts := NX
				MT447IniFis() //Inicial valores del aNFini utitlizado en la funcion MAFISRET
				MT447Refresh()
			Next
		EndIf

		MT447TotPie(.T.)
		MT447IniFis() //aCTIVA EL EVENTO DE MOVIMIENTO DE RENGLON PARA QUE SE REACTUALICE aNFini
		CursorArrow()

	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447PRORR ³Autor ³Gpe Santacruz.         ³ Data ³ 11/03/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Saca el % de prorrateo de una sola factura                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447PRORR(aExp1,cExp1,cExp2,cExp3,cExp4,cExp5)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp1.- Arreglo de los importes por factura                 ³±±
±±³          ³ cExp1.- Factura                                             ³±±
±±³          ³ cExp2.- Serie                                               ³±±
±±³          ³ cExp3.- Proveedor                                           ³±±
±±³          ³ cExp4.- Tienda                                              ³±±
±±³          ³ cExp5.- Item                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nExp1.- Parte proporcional del prorrateo                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA447                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MT447PRORR(aProUni,cFac,cSer,cProv,cTda,cItem)

	Local nProrr := 0
	Local nPFac  := aScan(aProUni,{|x| x[1]+x[2]+x[3]+x[4]==cFac+cSer+cProv+cTda })
	Local nsum   := 0
	Local nSel   := 0
	Local nValPar:= 0

	Do While npfac <= Len(aProUni) .And. aProUni[npfac,1]+aProUni[npfac,2]+aProUni[npfac,3]+aProUni[npfac,4] == cFac+cSer+cProv+cTda
		nSum += aProUni[npfac,6]
		If aProUni[npfac,5] == cItem
			nValPar := aProUni[npfac,6]
		EndIf
		npfac++
	EndDo

	nProrr := nValPar/nsum

Return nProrr

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VldFactItem³Autor ³Gpe Santacruz.         ³ Data ³ 11/03/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida que todas las facturas tengas sus respectivas partidas³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³VldFactItem(nExp1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp1.-                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA447                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VldFactItem(nopc)

	Local lRet		:= .T.
	Local nLlave	:= 0
	Local nPosIte	:= 0
	Local nDelRSF	:= 0
	Local nLlave6	:= 0
	Local nPosFac	:= 0
	Local nPosI		:= 0
	Local nDelRSE	:= 0

	Local nx := 0
	Local ny := 0

	CpyResGetDad(.T.,"oGetFactS")
	CpyResGetDad(.T.,"oGetItemF")

	 nLlave		:= GdFieldPos("RSE_FACT"	, aHoGetFacts)
	 nPosIte	:= GdFieldPos("RSE_ITEM"	, aHoGetFacts)
	 nDelRSF	:= GdFieldPos("GDDELETED"	, aHoGetItemF)
	 nLlave6	:= GdFieldPos("RSF_PRODUC"	, aHoGetItemF)
	 nPosFac	:= GdFieldPos("RSF_ITEDOC"	, aHoGetItemF)
	 nPosI		:= GdFieldPos("RSF_ITEM"	, aHoGetItemF)
	 nDelRSE	:= GdFieldPos("GDDELETED"	, aHoGetFacts)

	For nx:=1 To Len(aCoGetFacts)
		If !aCoGetFacts[NX,nDelRSE]  .And. !Empty(aCoGetFacts[nx, nLlave])
			nPos:= aScan(aColsIt,{|x| Trim(x[1,nPosFac])==AllTrim(aCoGetFacts[nx, nPosIte])   })
			If npos <> 0
				npos := aScan(aColsIt[npos],{|x|  !x[nDelRSF] .And. !Empty(x[nLlave6]) })   //con que exista un item, es valido
			EndIf
			If npos == 0
				Help( " ", 1, STR0056,, STR0137, 1, 0 )  //"Help",, "Existen facturas sin partidas, verifique!"
				lRet := .F.
			EndIf
		EndIf
	Next

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VldAntCal  ³Autor ³    Gpe Santacruz.     ³ Data ³ 11/03/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida el calculo anterior                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³VldAntCal(nExp1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp1.-                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA447                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VldAntCal(nopc)

	Local lRet := .F.

	If NOPC == 3 .Or. NOPC == 4
		lRet := .T.
		If Empty(M->RSC_CVEPED)
			MSGALERT(STR0138) //"Para calcular debe colocar la clave de pedimento!"
			lRet := .F.
		Else
			If oFoldMT447:nOption == 6
				lRet := MT447TOk2()
			EndIf
			lRet := VldFactItem(nopc)
		EndIf
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447PAIS  ³Autor ³gSantacruz             ³ Data ³           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacion de Pais de Origen                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447PAIS()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_VALID del campo RSG_PAIORI                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447PAIS()

	Local lRet  := .T.
	Local cPais := &(readvar())

	If !Empty(cPais)
		SYA->(DBSetOrder(1))
		If !SYA->(DBSeek(xFilial("SYA")+cPais))
			Help( " ", 1, STR0056,, STR0139, 1, 0 ) 	//"Help",, "No existe pais de origen!"
			lRet := .F.
		EndIf
	EndIf

Return lRet

//Refresca el tipo de cambio del encabezado de la factura
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447TC    ³Autor ³  Gpe. Santacruz       ³ Data ³ 24/05/17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Refresca el tipo de cambio de los encabezados de la facturas ³±±
±±³          ³cada que se hace cambio en el tipo de cambio del  registro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447TC                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nVal.- Valor del tipo de cambio del Registro                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_VALID, de RSC_TC                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function MT447TC
Local nPosTasa	:=0
Local nx:=0
CpyResGetDad(.T.,"oGetFacts")
IF  oGetFacts<> NIL
	nPosTasa	:= GdFieldPos("RSE_TASA"	, aHoGetFacts)
	for nx:=1 to len(aCoGetFacts)
		aCoGetFacts[nx,nPosTasa]:=M->RSC_TC //TC del pedimento
	next
	CpyResGetDad(.F.,"oGetFacts")
	if !lAutoTeste
		oGetFacts:Refresh()
	endif
ENDIF
Return .T.
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT447TCINI ³Autor ³  Gpe. Santacruz       ³ Data ³ 24/04/17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Inicia el tipo de cambio del encabezado de la factura con el ³±±
±±³          ³valor de TC del Registro.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³MT447TCINI                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nVal.- Valor del tipo de cambio del Registro                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_RELACAO, de RSE_TASA                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function MT447TCINI
Local nPosTasa:=0
Local nVal		:=0

IF  oGetFacts<> NIL
	CpyResGetDad(.T.,"oGetFacts")
	nPosTasa := GdFieldPos("RSE_TASA"	, aHoGetFacts)
	aCoGetFacts[nNoGetFacts,nPosTasa]:=M->RSC_TC //TC del pedimento
	nVal:=M->RSC_TC
	CpyResGetDad(.F.,"oGetFacts")
ENDIF
Return nVal



Static function ReDimensiona (aTmp)
Local nX:=1
Local nY:=1
Local nTam:=0
For nX:=1 to len(aTmp)
	For nY:=1 to len(aTmp[nx])
    	If valtype(aTmp[nX,nY,2])=="C"
	       nTam:=TAMSX3(aTmp[nX,nY,1])[1]
	       aTmp[nX,nY,2]:=padr(aTmp[nX,nY,2],nTam)
    	endif
    next
Next

Return aTmp
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CpyResGetDad³Autor³Gpe. Santacruz        ³ Data ³ 23/07/19   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Copia en contenidos de los getdados para Arreglos            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³CpyResGetDad( )                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lExp1 = .t. Copia del getdados para arreglos                ³±±
±±³          ³         .F. Copia del arreglos para Getdados                ³±±
±±³         s³ cExp2 = Nombre del objeto                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ninguno                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ En funciones de validacion                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
static Function CpyResGetDad(lCopia,cObjeto)
if !lAutoTeste
    if lCopia //pasa el contenido del objeto al os arreglos
		&("aC"+cObjeto):= aclone(&(cObjeto+":acols"))
		&("aH"+cObjeto):= aclone(&(cObjeto+":aHeader"))
		&("nN"+cObjeto):= &(cObjeto+":nat")
		&("nP"+cObjeto):= &(cObjeto+":oBrowse:ColPos")
	else //Pasa el contenido de los arreglos al objeto
		&(cObjeto+":acols")  := aclone(&("aC"+cObjeto))
		&(cObjeto+":aHeader"):= aclone(&("aH"+cObjeto))
		&(cObjeto+":nat")    := &("nN"+cObjeto)
		&(cObjeto+":oBrowse:ColPos"):=&("nP"+cObjeto)
		&(cObjeto+":Refresh()")
	endif
endif
Return

/*/{Protheus.doc} LibMetric
Funcion utilizada para validar la fecha de la LIB para ser utilizada en Telemetria

@type       Function
@author     Marco Augusto González Rivera
@since      19/08/2021
@version    1.0
@return     lMetric, lógico, Retorna .T. si la LIB puede ser utilizada para Telemetria
/*/
Static Function LibMetric()
	Local lMetric := .F.

	lMetric := (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')

Return lMetric

/*/{Protheus.doc} MarcProd
Funcion utilizada para marcar o desmarcar las lineas del browse

@type       Function
@author     Filiberto Pérez Barrera
@since      11/02/2022
@version    1.0
@return
/*/
Static Function MarcProd(oListBox, aListBox, oDlg, cMarckTip)
Local nPos := 1
DEFAULT cMarckTip := "M"

IF cMarckTip == "M"
	aEval( aListBox , { |x,y| aListBox[y,nPos] := .T. } )
ElseIF cMarckTip == "D"
	aEval( aListBox , { |x,y| aListBox[y,nPos] := .F. } )
ElseIF cMarckTip == "I"
	aEval( aListBox , { |x,y| aListBox[y,nPos] := !aListBox[y,nPos] } )
EndIF

Return (NIL)
