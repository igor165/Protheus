#include "fisa800.ch"
#include "protheus.ch"
#include "rwmake.ch"
#include "shell.ch"
#include "xmlxfun.ch"
#include "fileio.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³ FISA800  ³ Autor ³ Laura Medina         ³ Data ³ 17/09/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Función para crear la pantalla de selección de Facturas de³±±
±±³           ³ Salida para obtener el timbre fiscal de CFDi.             ³±±
±±³           ³                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ MATAcfdi                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³29/06/17³MMI-6110³ Merge Main vs 12.1.17 se excluye la    ³±±
±±³            ³        ³      ³  func AjustaSx1                          ³±±
±±³L.Samaniego ³29/06/17³MMI-5844³ Se cambia grupo de preguntas a FISA800 ³±±
±±³LuisEnriquez³04/09/19³DMINA-7280³Se agrega funcionalidad para que si el³±±
±±³            ³        ³          ³parámetro MV_CFDUSO es 3, y no existe ³±±
±±³            ³        ³          ³el XML, sea generado (MEX)            ³±±
±±³Eduardo Prz ³18/03/20³DMINA-8324³Se agrega tratamiendo en la funcion   ³±±
±±³            ³        ³          ³AddTimbre para que el nodo Complemento³±±
±±³            ³        ³          ³ no aparezca duplicado al timbrar     ³±±
±±³            ³        ³          ³ facturas con CCE y PAC Tralix        ³±±
±±³Oscar G.    ³13/08/20³DMINA-9852³Se agrega tratamiendo para timbrado a ³±±
±±³            ³        ³          ³partir de JOB en TimbreCFDi().        ³±±
±±³Bibiana R.  ³01/08/22³DMINA-16413³Se agrega validación para que al leer³±±
±±³            ³        ³          ³el parámetro MV_CANAUT si el valor es ³±±
±±³            ³        ³          ³igual a 'N', desactive la cancelación ³±±
±±³            ³        ³          ³automática del doc. que se sustituye. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FISA800
Local aArea     := GetArea()
Local oDlgFat, oBusca, oLbx1, oMarTodos, oDesTodos, oInvSelec
Local aItems    := {}
Local aIndx		:= {OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006)}   //"Factura + Serie", "Sucursal + Cliente + Factura + Serie", "Fecha emisión"
Local cIndx	    := aIndx[1]
Local cBusca    := Space(TAMSX3("F2_LOJA")[1]+TAMSX3("F2_CLIENTE")[1]+TAMSX3("F2_DOC")[1]+TAMSX3("F2_SERIE")[1])
Local nPosLbx   := 0
Local nOpc   	:= 0
Local aButtons  := {{"S4WB011N", {|| Leyenda()},STR0014,STR0014}}//Leyenda
Local oOkS      := LoadBitmap(GetResources(),"br_verde")
Local oNoS      := LoadBitmap(GetResources(),"br_vermelho")
Local oOk	    := LoadBitmap(GetResources(),"LBOK")
Local oNo	    := LoadBitmap(GetResources(),"LBNO")
Local bSet15	:= {|| ValidGen(oLbx1,oDlgFat,@nOpc,aItems)}
Local bSet24	:= {|| nOpc:=0, oDlgFat:End()}
Local bDialogInit := { || EnchoiceBar(oDlgFat,bSet15,bSet24,nil,aButtons)}
Local cPerg		:= "FISA800"
Local aTamaho	:= MsAdvSize()

If SF2->(FieldPos( "F2_TIMBRE" )) == 0 .Or. SF2->(FieldPos( "F2_UUID" )) == 0 .Or. SF1->(FieldPos( "F1_TIMBRE" )) == 0 .Or. SF1->(FieldPos( "F1_UUID" )) == 0
	MsgStop(STR0028)
	Return Nil
Endif

If !Pergunte( cPerg , .T. )
   Return
Endif

	//Documentos a timbrar de clientes
aItems := SelecSF2()
//Documentos a timbrar de proveedores
// SelecSF1(aItems)

If Len(aItems) == 0
	Aviso(STR0015,STR0040,{STR0018})
	Return Nil
Endif

	DEFINE MSDIALOG oDlgFat FROM aTamaho[1],aTamaho[2] TO aTamaho[6],aTamaho[5] TITLE STR0003 PIXEL   //"Emisión de Timbres - Facturación -"

	@ c(30),c(05) MSCOMBOBOX oIndx VAR cIndx ITEMS aIndx SIZE c(90),c(10) PIXEL OF oDlgFat
	@ c(30),c(98) BUTTON oBoton PROMPT STR0039 SIZE c(35),c(10) ;
			 ACTION (oLbx1:nAT := BuscaCve(oLbx1,aItems,cBusca,oIndx:nAT), ;
					oLbx1:bLine := {|| {IF(aItems[oLbx1:nAt,1],oOkS,oNoS),IF(aItems[oLbx1:nAt,2],oOk,oNo),aItems[oLbx1:nAt,3],aItems[oLbx1:nAt,4],;
					aItems[oLbx1:nAt,9],aItems[oLbx1:nAt,5],aItems[oLbx1:nAt,6],aItems[oLbx1:nAt,7],aItems[oLbx1:nAt,8]}},;
					oLbx1:SetFocus()) PIXEL OF oDlgFat
	@ c(42),c(05)  MSGET oBusca VAR cBusca PICTURE "@!" SIZE c(130),c(10) PIXEL  OF oDlgFat
	@ c(58),c(05)  LISTBOX oLbx1 VAR nPosLbx FIELDS HEADER ;
					OemToAnsi(""),;    		//Status
					OemToAnsi(""),;    		//Check
					OemToAnsi(STR0008),;	//Factura
					OemToAnsi(STR0009),;	//Serie
					OemToAnsi(STR0033),;	//Especie
					OemToAnsi(STR0010),;	//Fecha de emision
					OemToAnsi(STR0011),;	//Loja
					OemToAnsi(STR0012),;	//Cliente
					OemToAnsi(STR0013);		//Nombre
	          SIZE aTamaho[6] * .875,Iif(aTamaho[6]>700,(aTamaho[4] * .775)-25,Iif(aTamaho[6]<500,aTamaho[4] * .6,aTamaho[4] * .7)) OF oDlgFat PIXEL ON DBLCLICK ( IIF(aItems[oLbx1:nAt,1],(MarcaItem(oLbx1,@aItems,@oDlgFat),;
	          oLbx1:nColPos:= 1,oLbx1:Refresh()),Aviso(STR0015,STR0020,{STR0018}) ) ) NOSCROLL
	oLbx1:SetArray(aItems)
	oLbx1:bLine := {|| {IF(aItems[oLbx1:nAt,1],oOkS,oNoS),IF(aItems[oLbx1:nAt,2],oOk,oNo),aItems[oLbx1:nAt,3],aItems[oLbx1:nAt,4],;
							aItems[oLbx1:nAt,9],aItems[oLbx1:nAt,5],aItems[oLbx1:nAt,6],aItems[oLbx1:nAt,7],aItems[oLbx1:nAt,8]}}
	oLbx1:Refresh()

	@ aTamaho[4] * .92,c(005) BUTTON oMarTodos PROMPT STR0036 SIZE c(45),c(10) ACTION MarcaItem( oLbx1 , @aItems , @oDlgFat , "M" ) PIXEL OF oDlgFat
	@ aTamaho[4] * .92,c(055) BUTTON oDesTodos PROMPT STR0037 SIZE c(45),c(10) ACTION MarcaItem( oLbx1 , @aItems , @oDlgFat , "D" ) PIXEL OF oDlgFat
	@ aTamaho[4] * .92,c(110) BUTTON oInvSelec PROMPT STR0038 SIZE c(45),c(10) ACTION MarcaItem( oLbx1 , @aItems , @oDlgFat , "I" ) PIXEL OF oDlgFat

	ACTIVATE MSDIALOG oDlgFat ON INIT Eval(bDialogInit) CENTERED

	CursorWait()

	If  nOpc == 1
		//msAguarde({||GenTimbre(aItems)},oemtoansi(STR0003)) // ... "Generando "
		Processa({||GenTimbre(aItems)},oemtoansi(STR0003)) // ... "Generando "
	Endif

	DeleteObject(oOk)
	DeleteObject(oNo)
	DeleteObject(oOkS)
	DeleteObject(oNoS)

	CursorArrow()
	RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BuscaCve    ºAutor  ³ Laura Medina       º Data ³  26/04/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Buscador...            							          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³          			 	                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function BuscaCve(oLbx1,aItems,cBusca,nIndx)
Local nPos := 0

cBusca := Upper(Alltrim(cBusca))
If  nIndx==1    //"Factura + Serie"
	nPos := ASCAN(aItems, {|aVal| aVal[3]+aVal[4]=Alltrim(cBusca)} ) // valor corto de lado derecho del '=' puede coincidir; es como softseek
Elseif nIndx==2	 //"Sucursal + Cliente + Factura + Serie"
	nPos := ASCAN(aItems, {|aVal| aVal[6]+aVal[7]+aVal[3]+aVal[4]=Alltrim(cBusca)} )
Elseif nIndx==3  //"Fecha emisión"
	nPos := ASCAN(aItems, {|aVal| aVal[5]=Alltrim(cBusca)} )
Endif
If  nPos == 0
	nPos := oLbx1:nAt
EndIf

Return nPos



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SelecSF2 ³ Autor ³ Laura Medina          ³ Data ³ 26/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion para seleccionar los registros de las facturas de  ³±±
±±³          ³ entrada de las tablas SF2/SD2.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SelecSF2()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³ BOPS ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SelecSF2()
Local cAliasTmp := CriaTrab(Nil,.F.)
Local cSF2Name  := InitSqlName("SF2")  //Encabezado de facturas salida (NF)
Local cSF1Name  := InitSqlName("SF1")  //Encabezado de facturas entrada (NCC)
Local cSA1Name  := InitSqlName("SA1")  //Clientes
Local cQuery    := ""
Local aFacturas := {}
Local nReg 		:= 0
Local MV_CFDiNFC := StrQryIn( SuperGetmv( "MV_CFDINFC" , .F. , "NF /NDC" ) )	// "NF /NDC/NCP" // NF, ND clientes
Local MV_CFDiNCC := StrQryIn( SuperGetmv( "MV_CFDINCC" , .F. , "NCC" ) )		// "NF /NDP/NCC" // NC clientes
Local dMVPar01	:= MV_PAR01 // De fecha
Local dMVPar02	:= MV_PAR02 // A fecha
Local cMVPar03	:= MV_PAR03 // De serie
Local cMVPar04	:= MV_PAR04 // A serie
Local cMVPar05	:= MV_PAR05 // De documento
Local cMVPar06	:= MV_PAR06 // A documento
Local cMVPar07	:= MV_PAR07 // De cliente
Local cMVPar08	:= MV_PAR08 // A cliente
Local cMVPar09	:= MV_PAR09 // De tienda
Local cMVPar10	:= MV_PAR10 // A tienda
Local nMVPar11	:= MV_PAR11 // Incluir timbrados?
Local nMVPar12	:= MV_PAR12 // Traer marcados?

cQuery := "(SELECT F2_CLIENTE, F2_LOJA, F2_DOC, F2_SERIE, F2_EMISSAO, A1_NOME, F2_TIMBRE, F2_ESPECIE, SF2.R_E_C_N_O_ F2RECNO "
cQuery += " FROM " + cSF2Name + " SF2, " + cSA1Name + " SA1 "
cQuery += " WHERE F2_FILIAL = '" + xFilial("SF2") + "'"
cQuery += " AND A1_FILIAL = '" + xFilial("SA1") + "'"
cQuery += " AND F2_CLIENTE = A1_COD "
cQuery += " AND F2_LOJA = A1_LOJA "
cQuery += " AND F2_ESPECIE IN (" + MV_CFDiNFC + ")"
cQuery += " AND F2_EMISSAO >= '" + DtoS(dMVPar01) + "'"
cQuery += " AND F2_EMISSAO <= '" + DtoS(dMVPar02) + "'"
cQuery += " AND F2_SERIE >= '" + cMVPar03 + "'"
cQuery += " AND F2_SERIE <= '" + cMVPar04 + "'"
cQuery += " AND F2_DOC >= '" + cMVPar05 + "'"
cQuery += " AND F2_DOC <= '" + cMVPar06 + "'"
cQuery += " AND F2_CLIENTE >= '" + cMVPar07 + "'"
cQuery += " AND F2_CLIENTE <= '" + cMVPar08 + "'"
cQuery += " AND F2_LOJA >= '" + cMVPar09 + "'"
cQuery += " AND F2_LOJA <= '" + cMVPar10 + "'"
If nMVPar11 == 2
	cQuery += " AND F2_TIMBRE = '' "
Endif
cQuery += " AND SF2.D_E_L_E_T_=' ' "
cQuery += " AND SA1.D_E_L_E_T_=' ') "
cQuery += " UNION ALL "
cQuery += "(SELECT F1_FORNECE F2_CLIENTE, F1_LOJA F2_LOJA, F1_DOC F2_DOC, F1_SERIE F2_SERIE, F1_EMISSAO F2_EMISSAO, A1_NOME, F1_TIMBRE F2_TIMBRE, F1_ESPECIE F2_ESPECIE, SF1.R_E_C_N_O_ F2RECNO "
cQuery += " FROM " + cSF1Name + " SF1, " + cSA1Name + " SA1 "
cQuery += " WHERE F1_FILIAL = '" + xFilial("SF1") + "'"
cQuery += " AND A1_FILIAL = '" + xFilial("SA1") + "'"
cQuery += " AND F1_FORNECE = A1_COD "
cQuery += " AND F1_LOJA = A1_LOJA "
cQuery += " AND F1_ESPECIE IN (" + MV_CFDiNCC + ")"
cQuery += " AND F1_EMISSAO >= '" + DtoS(dMVPar01) + "'"
cQuery += " AND F1_EMISSAO <= '" + DtoS(dMVPar02) + "'"
cQuery += " AND F1_SERIE >= '" + cMVPar03 + "'"
cQuery += " AND F1_SERIE <= '" + cMVPar04 + "'"
cQuery += " AND F1_DOC >= '" + cMVPar05 + "'"
cQuery += " AND F1_DOC <= '" + cMVPar06 + "'"
cQuery += " AND F1_FORNECE >= '" + cMVPar07 + "'"
cQuery += " AND F1_FORNECE <= '" + cMVPar08 + "'"
cQuery += " AND F1_LOJA >= '" + cMVPar09 + "'"
cQuery += " AND F1_LOJA <= '" + cMVPar10 + "'"
If nMVPar11 == 2
	cQuery += " AND F1_TIMBRE = '' "
Endif
cQuery += " AND SF1.D_E_L_E_T_=' ' "
cQuery += " AND SA1.D_E_L_E_T_=' ') "
cQuery += " ORDER BY 4, 3"

//cQuery += " ORDER BY F2_DOC,F2_SERIE"
//cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
Count to nReg
(cAliasTmp)->(dbGotop())

While  (cAliasTmp)->(!EOF())
	// NO TRUNCAR BLANCOS EN: DOC, SERIE, CLIENTE, LOJA
	aAdd(aFacturas,{If(Empty((cAliasTmp)->F2_TIMBRE),.T.,.F.),;
					(nMVPar12 == 1),;
					(cAliasTmp)->F2_DOC,;
					(cAliasTmp)->F2_SERIE,;
					DTOC(STOD((cAliasTmp)->F2_EMISSAO)),;
					(cAliasTmp)->F2_LOJA,;
					(cAliasTmp)->F2_CLIENTE,;
					ALLTRIM((cAliasTmp)->A1_NOME),;
					(cAliasTmp)->F2_ESPECIE,;
					(cAliasTmp)->F2RECNO,;
					If((cAliasTmp)->F2_ESPECIE $ MV_CFDiNFC, "SF2", "SF1")})
	(cAliasTmp)->(dbSkip())
Enddo

(cAliasTmp)->( dbCloseArea())
Return aFacturas


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MarcaItem ³ Autor ³ Laura Medina          ³ Data ³ 21/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marcar el empleado seleccionado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MarcaItem()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MarcaItem(oLbx1,aItems,oDlgRec,cMarckTip)
DEFAULT cMarckTip := ""

	IF Empty( cMarckTip )
		aItems[oLbx1:nAt,2]:= !aItems[oLbx1:nAt,2]
	ElseIF cMarckTip == "M"
		aEval( aItems , { |x,y| aItems[y,2] := .T. } )
	ElseIF cMarckTip == "D"
		aEval( aItems , { |x,y| aItems[y,2] := .F. } )
	ElseIF cMarckTip == "I"
		aEval( aItems , { |x,y| aItems[y,2] := !aItems[y,2] } )
	EndIF

Return NIL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Leyenda  ³ Autor ³ Laura Medina          ³ Data ³ 26/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Función para mostrar una pantalla con las leyendas.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Leyenda()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Leyenda()
Local aLegenda:= {	{"BR_VERDE",OemToAnsi(STR0017)},; //Pendiente
					{"BR_VERMELHO",OemToAnsi(STR0016) }}  //Generada
BrwLegenda(STR0015,STR0014,aLegenda)  //Emisión de Timbres,Leyenda

Return .T.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ValidGen ³ Autor ³ Laura Medina          ³ Data ³ 26/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Función validar que se haya seleccionado al menos una factu³±±
±±³          ³ ra para ser procesada.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ValidGen()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ValidGen(oLbx1,oDlgFat,nOpc,aItems)
Local lRet  := .F.
Local nPos  := 0

nPos := ASCAN(aItems, {|aVal| aVal[2]==.T.} )
If  nPos>0
	lRet := .T.
	nOpc := 1
	oDlgFat:End()
Else
	Aviso(STR0015,STR0021,{STR0018})
Endif

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GenTimbre ³ Autor ³ Laura Medina          ³ Data ³ 26/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Procesa facturas seleccionadas para generacion de timbre   ³±±
±±³          ³ fiscal a CFDi.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GenTimbre(aItems)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ARodriguez  ³08/12/11³TEDCQI³-Separar proceso para ejecutar timbrado   ³±±
±±³            ³        ³      ³ desde otra rutina o msExecAuto           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GenTimbre(aItems)
Local nloop    := 0
Local nTimbres := 0
Local nNoCancel:= 0
Local cResp    := ""
Local aMsj	   := {}
Local cAviso   := ""
Local cCRLF	   := (chr(13)+chr(10))
Local lCanOK   := .F.
/* aItems
	1- F2_TIMBRE
	2- MARCA?
	3- F2_DOC
	4- F2_SERIE
	5- F2_EMISSAO
	6- F2_LOJA
	7- F2_CLIENTE
	8- A1_NOME
	9- F2_ESPECIE
	10-F2RECNO
	11-Tabla ( SF2 / SF1 )
*/
ProcRegua (CuentaItems(aItems))

For nLoop := 1 to Len(aItems)
	If aItems[nLoop,2]
		lCanOK := .F.
		cResp := TimbreCFDi( aItems[nLoop,3] , aItems[nLoop,4] , aItems[nLoop,9] , aItems[nLoop,7] , aItems[nLoop,6],,@aMsj, @lCanOK ) //  , aItems[nLoop,11]
		If lCanOK
			nNoCancel += 1
		EndIf
		If Empty(cResp)
			nTimbres:= nTimbres+1
		ElseIf cResp == "XX"
			Return Nil
		Endif
		IncProc()
	Endif
Next nLoop

Do Case
	Case nTimbres == 0
		Aviso( OemToAnsi(STR0015), OemToAnsi(STR0027), {STR0018})  // No se generaron timbres fiscales
	Case nTimbres == 1
		Aviso( aMsj[1], aMsj[2], {aMsj[3]})
	Otherwise
		//"Se generó #nTimbres# Timbres Fiscales" //"Se cancelaron #NoCancel# Timbres Fiscales."
		cAviso := OemToAnsi( Strtran(STR0030, "#nTimbres#", lTrim(Str(nTimbres)))) + cCRLF +;
		          OemToAnsi( Strtran(STR0047, "#NoCancel#", lTrim(Str(nNoCancel))))
		Aviso( OemToAnsi(STR0015), cAviso, {STR0018})
End

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TimbreCFDi³ Autor ³ Alberto Rodriguez     ³ Data ³ 08/12/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Función ejecutar el proceso de envio de archivo, generacion³±±
±±³          ³ de timbre y retorno del mismo.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TimbreCFDi( cDoc , cSerie , cEspecie , cClieProv , cLoja , ³±±
±±³          ³              cTabla )                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TimbreCFDi( cDoc , cSerie , cEspecie , cClieProv , cLoja  , cTabla , aMsj, lCanOK)
Local cRUTASRV := &(SuperGetmv( "MV_CFDDOCS" , .F. , "\cfd\facturas\" )) // Ruta donde se encuentran las facturas.xml (servidor)
Local cRUTASMR := &(SuperGetmv( "MV_CFDSMAR" , .F. , "GetClientDir()" ))	// Ruta A donde se copiaran los archivos que vienen del servidor . . .  + "\TimbradoATEB\bin\Debug\"
Local cCfdUser := SuperGetmv( "MV_CFDI_US" , .F. , "0000000001" )			// Usuario del servicio web   (Ant: MV_CFDUSER)
Local cCfdPass := SuperGetmv( "MV_CFDI_CO" , .F. , "pwd" )					// Password del servicio web (Ant: MV_CFDPASS)
Local cCFDiPAC := SuperGetmv( "MV_CFDI_PA" , .F. , "ATEB" )					// Rutina a ejecutar (PAC) (Ant: MV_CFDIPAC)
Local cCFDiAmb := SuperGetmv( "MV_CFDI_AM" , .F. , "T" )					// Ambiente (Teste o Produccion) (Ant: MV_CFDIAMB)
Local cCFDiCer := SuperGetmv( "MV_CFDI_CE" , .F. , "." )					// Archivo de certificado (.cer) (Ant: MV_CFDICER)
Local cCFDiKey := SuperGetmv( "MV_CFDI_PR" , .F. , "." )					// Archivo de clave (.key) (Ant: MV_CFDIKEY)
Local cCFDiCve := SuperGetmv( "MV_CFDI_CL" , .F. , "." )					// Clave de certificado para autenticar WS
Local cCFDiNF  := SuperGetmv( "MV_CFDINF" , .F. , "" )						// Rutina de impresion del CFDi - NF; despues de timbrar
Local cCFDiNC  := SuperGetmv( "MV_CFDINC" , .F. , "" )						// Rutina de impresion del CFDi - NCC; despues de timbrar
Local nCFDiCmd := SuperGetmv( "MV_CFDICMD" , .F. , 0 )						// Mostrar ventana de comando del Shell: 0=no, 1=si
Local cCFDiSF1 := SuperGetmv( "MV_CFDNAF1" , .F. , "" )						// Nombre para archivo xml de SF1
Local cCFDiSF2 := SuperGetmv( "MV_CFDNAF2" , .F. , "" )						// Nombre para archivo xml de SF2
Local lProxySr := SuperGetmv( "MV_PROXYSR" , .F. , .F. )					// Emplear Proxy Server?
Local cProxyIP := SuperGetmv( "MV_PROXYIP" , .F. , "" )						// IP del Proxy Server
Local nProxyPt := SuperGetmv( "MV_PROXYPT" , .F. , 0 )						// Puerto del Proxy Server
Local lProxyAW := SuperGetmv( "MV_PROXYAW" , .F. , .F. )					// Autenticación en Proxy Server con credenciales de Windows?
Local cProxyUr := SuperGetmv( "MV_PROXYUR" , .F. , "" )						// Usuario para autenticar Proxy Server
Local cProxyPw := SuperGetmv( "MV_PROXYPW" , .F. , "" )						// Clave para autenticar Proxy Server
Local cProxyDm := SuperGetmv( "MV_PROXYDM" , .F. , "" )						// Dominio para autenticar Proxy Server
Local cLogWS   := SuperGetmv( "MV_CFDILOG" , .F. , "LOG" )					// Tipo de log en consumo del servicio web: LOG (default), LOGDET (detallado), NOLOG (ninguno)
Local cCFDUso  := SuperGetmv( "MV_CFDUSO" , .F. , "1" )						// Dominio para autenticar Proxy Server
Local nOpc     := 0
Local cNameCFDI:= ""
Local cNameORIG:= ""
Local cRutina  := "TimbradoCFDi.exe "
Local cParametros := cCFDiPAC + " "
Local aArea    := GetArea()
Local aAreaSF2 := SF2->(GetArea())
Local aAreaSF1 := SF1->(GetArea())
Local cRet     := "X"
Local lAddenda := .F.
Local cCancelac:= 'T'
Local cUUID    := "."
Local acCampos := { "RFCEmisor" , "Fecha" }
Local acDatos  := { "" , "" }
Local cBatch   := "Timbrado.bat"
Local nHandle  := 0
Local cProxy   := "[PROXY]"
Local lHTML    := GetRemoteType() == 5
Local lJob	   := GetRemoteType() < 0
Local cRutaExe := ""
Local lTimbWeb := .F.

Private cTimbre  := ""  //Contiene el timbre
Private cFecTimbre := "" //Contiene la fecha del timbrado
Private cFolioFisc := "" //Contiene el Folio Fiscal del Timbrado (UUID)
Private cError   := ""  //Contiene el numero de error
Private cDetalle := ""  //Contiene el detalle del error, cuando el timbre no es generado
Private lDeMenu  := ( ( Alltrim(FunName()) == "CFDFAT01" ) .Or. !( Alltrim(FunName()) == "RPC" ) )
Private cMsgTim  := ""

DEFAULT cTabla   := "SF2"
DEFAULT aMsj     := {}

cCFDUso := IIf(cCFDUso $ "0|1|2|3",cCFDUso,"1")

If Empty(cRUTASRV) .Or. Empty(cRUTASMR) .Or. Empty(cCfdUser) .Or. Empty(cCfdPass) .Or. Empty(cCFDiPAC)
	If lDeMenu
		Aviso( STR0015 , STR0034, {STR0018} )  //Faltan parámetros por definir para este proceso
		cRet := "XX"
	Else
		cRet := ProcName(0) + ": " + STR0034
	Endif
	Return cRet
Endif

// Valida ruta de alojamiento del ejecutable de timbrado
If !( cRUTASMR == Strtran( cRUTASMR , " " ) )
	If lDeMenu
		Aviso( STR0015 , STR0035, {STR0018} )  //La ruta del ejecutable de timbrado no es válida
		cRet := "XX"
	Else
		cRet := ProcName(0) + ": " + STR0035
	Endif
	Return cRet
Endif

// Verifica la existencia del EXE de WS para timbrado
If !File( cRUTASMR + cRutina )
	// Compatibilidad con versiones autónomas
	cRutina := "Timbrado" + Trim(cCFDiPAC) + ".exe "
	cParametros := ""

	// Validar si el ejecutable existe
	If !File( cRUTASMR + cRutina )
		If lDeMenu
			Aviso( STR0015 , STR0032 + cRUTASMR + cRutina + STR0026, {STR0018} )  //No existe el cliente de servicio web: ...exe, no es posible continuar con el timbrado.
			cRet := "XX"
		Else
			cRet := STR0032 + cRUTASMR + cRutina
		Endif
		Return cRet
	Endif
Endif

// Parámetros para el Proxy Server
cProxy += "[" + If( lProxySr , "1" , "0" ) + "]"
cProxy += "[" + cProxyIP + "]"
cProxy += "[" + lTrim( Str( nProxyPt ) ) + "]"
cProxy += "[" + If( lProxyAW , "1" , "0" ) + "]"
cProxy += "[" + If( lProxyAW , "" , cProxyUr ) + "]"
cProxy += "[" + If( lProxyAW , "" , cProxyPw ) + "]"
cProxy += "[" + If( lProxyAW , "" , cProxyDm ) + "]"

//Nombre de la factura
//cNameCFDI := Lower( Alltrim(cEspecie) + "_" + Alltrim(cSerie) + "_" + Alltrim(cDoc) + ".xml" )
If Trim(cEspecie) != "NCC" // cTabla == "SF2"
	// NF  - Nota fiscal clientes
	// NDC - Nota de debito clientes
	// NCP - Nota de credito proveedores
	SF2->(dbSetOrder(1))
	SF2->(dbSeek( xFilial( "SF2" )+cDoc+cSerie+cClieProv+cLoja ))
	cNameCFDI := &(cCFDiSF2)
	SF2->(RestArea(aAreaSF2))
Else
	// NF  - Nota fiscal proveedores
	// NDP - Nota de debito proveedores
	// NCC - Nota de credito clientes
	SF1->(dbSetOrder(1))
	SF1->(dbSeek( xFilial( "SF1" )+cDoc+cSerie+cClieProv+cLoja ))
	cNameCFDI := &(cCFDiSF1)
	SF1->(RestArea(aAreaSF1))
Endif

//Validar si el archivo xml existe
If !File(cRUTASRV+cNameCFDI)
	If cCFDUso == "3"
		CFDGerXml( cEspecie, cClieProv, cLoja, cDoc, cSerie, .F., .F., .T. )
	Else
		If lDeMenu
			Aviso( STR0015 , STR0025 + cRUTASRV + cNameCFDI + STR0026 , {STR0018} )  //No se encontro la Factura XXXX.xml, no es posible continuar con el timbrado.
		Else
			cRet := STR0025 + cRUTASRV + cNameCFDI
		EndIf
		Return cRet
	EndIf
EndIf

If lHTML //Tratamiento para timbrado en WEB
	COPY FILE (cRUTASRV+cNameCFDI) TO (cRUTASMR+cNameCFDI)
	COPY FILE (cRUTASRV+cNameCFDI+".out") TO (cRUTASMR+cNameCFDI+".out")
ElseIf lJob //Tratamiento para timbrado desde Job
	__CopyFile(cRUTASRV+cNameCFDI, cRUTASMR+cNameCFDI)
	__CopyFile(cRUTASRV+cNameCFDI+".out", cRUTASMR+cNameCFDI+".out")
Else
	//COPIAR la factura.xml del servidor a la ruta del smartclient (ROOTPATH...\CFD\FACTURAS\NF_UNI_000020.XML a x:\totvs\protheusroot\bin\smartclient)
	CpyS2T(cRUTASRV+cNameCFDI, cRUTASMR)
Endif

// Quitar provisionalmente la Addenda
lAddenda := AddendaCFDi(cRUTASMR, cNameCFDI, "1")

// Permitir hacer cambios al xml antes de timbrar
If ExistBlock( "FIS800T1" ) //Antes TIMCFDI1
	ExecBlock( "FIS800T1" , .F. , .F. , {cNameCFDI , cDoc , cSerie , cEspecie , cClieProv , cLoja} )
Endif

// parametros: PAC, Usuario, Password, Factura.xml, Ambiente,
cParametros += cCfdUser + " " + cCfdPass + " " + cNameCFDI + " " +cCFDiAmb +  " "
//             Archivo.cer, Archivo.key, ClaveAutenticacion, UUID, Timbrar/Cancelar
cParametros += cCFDiCer + " " + cCFDiKey + " " + cCFDiCve + " " + cUUID + " " + cCancelac + " "
//			   Proxy, log
cParametros += cProxy + " " + cLogWS

// otros parametros segun el PAC: (11)RFC emisor, (12)Fecha
/*
If Upper( cCFDiPAC ) $ "DAYSOFT,FORMASDIGITALES,TIMBREFISCAL"
	If LeeXML(cRUTASRV, cNameCFDI, @cError, @cDetalle, acCampos, acDatos)
		cParametros += acDatos[1] + " " + acDatos[2]
	Else
		cParametros += ". " + ". "
	Endif
Endif
*/
/* IMPORTANTE: En las versiones autónomas de ejecutables de WS, el parámetro (1)PAC no se envía */

If nCFDiCmd < 0 .Or. nCFDiCmd > 10
	nCFDiCmd := 0
Endif

If nCFDiCmd == 3 .Or. nCFDiCmd == 10
	nHandle	:= FCreate( cRUTASMR + cBatch )
	If nHandle == -1
		If lDeMenu
			Aviso( STR0015 , STR0041 + cRUTASMR, {STR0018} )  //"No es posible crear un archivo temporal en la ruta " + cRUTASMR
			cRet := "XX"
		Else
			cRet := ProcName(0) + ": " + STR0041 + cRUTASMR
		Endif
		Return cRet
	Endif

	FWrite( nHandle, cRUTASMR + cRutina + Trim(cParametros) + CRLF )
	FWrite( nHandle, "Pause" + CRLF )
	fClose( nHandle )
	nOpc := WAITRUN( cRUTASMR + cBatch, nCFDiCmd )

Else

	// Ejecuta cliente de servicio web
	If lHTML .Or. lJob //Tratamiento HTML o Job
		cRutaExe := GetSrvProfString('RootPath', '') + GetSrvProfString('StartPath', '')
		lTimbWeb := WaitRunSrv( cRutaExe + cRutina + Trim(cParametros), .T., cRutaExe )
		If !lTimbWeb
			nOpc := 1
		EndIf
	Else
		nOpc := WAITRUN( cRUTASMR + cRutina + Trim(cParametros), nCFDiCmd )	// SW_HIDE
	EndIf
EndIf

If nOpc > 0 .Or. !File( cRUTASMR + cNameCFDI + ".out" )
	If lDeMenu
		Aviso( STR0015 , STR0022 + cNameCFDI + ".out" , {STR0018} ) //"Emisión de timbres fiscales" //"No se encontró el archivo u ocurrió un error..." //"ok"
	Else
		cRet := STR0022 + cNameCFDI + ".out" //"No se encontró el archivo u ocurrió un error..."
	Endif
	Return cRet
Endif

If lHTML //Tratamiento para timbrado en WEB
	COPY FILE (cRUTASMR+cNameCFDI+".out") TO (cRUTASRV+cNameCFDI+".out")
ElseIf lJob //Tratamiento para timbrado desde Job
	__CopyFile(cRUTASMR+cNameCFDI+".out", cRUTASRV+cNameCFDI+".out")
Else
	//Copiar timbre al servidor
	CpyT2S(cRUTASMR + cNameCFDI + ".out" , cRUTASRV)
Endif



//Validar si se genero el timbre y si es asi se debe actualizar el campo F2_TIMBRE
If  LeeXMLOut(cRUTASRV, cNameCFDI, @cTimbre, @cError, @cDetalle, cRUTASMR, @cFecTimbre, @cFolioFisc)
	cFecTimbre := substr(cFecTimbre,1,4) + substr(cFecTimbre,6,2) + substr(cFecTimbre,9,2) //Se da formato a la cadena de fecha

	If Trim(cEspecie) != "NCC" // cTabla == "SF2"
		// NF  - Nota fiscal clientes
		// NDC - Nota de debito clientes
		// NCP - Nota de credito proveedores
		SF2->(dbSetOrder(1))
		If SF2->(dbSeek( xFilial( "SF2" )+cDoc+cSerie+cClieProv+cLoja ))
			If SF2->(RecLock( "SF2" , .F.))
				SF2->F2_TIMBRE := cTimbre
				SF2->F2_FECTIMB := STOD(cFecTimbre)
				SF2->F2_UUID := cFolioFisc
				SF2->(msUnlock())
			Endif
		Endif
		SF2->(RestArea(aAreaSF2))
	Else
		// NF  - Nota fiscal proveedores
		// NDP - Nota de debito proveedores
		// NCC - Nota de credito clientes
		SF1->(dbSetOrder(1))
		If SF1->(dbSeek( xFilial( "SF1" )+cDoc+cSerie+cClieProv+cLoja ))
			If SF1->(RecLock( "SF1" , .F.))
				SF1->F1_TIMBRE := cTimbre
				SF1->F1_FECTIMB := STOD(cFecTimbre)
				SF1->F1_UUID := cFolioFisc
				SF1->(msUnlock())
			Endif
		Endif
		SF1->(RestArea(aAreaSF1))
	Endif

	// Nuevo CFDi en el Remote
	Ferase( cRUTASMR + cNameCFDI )
	Frename( cRUTASMR + cNameCFDI + ".timbre" , cRUTASMR + cNameCFDI )

	If lAddenda
		// Restaurar Addenda en el xml ya timbrado
		AddendaCFDi(cRUTASMR, cNameCFDI, "2")
	Endif

	// Permitir hacer cambios al xml antes de enviar al servidor
	If ExistBlock( "FIS800T2" )  //Antes TIMCFDI2
		ExecBlock( "FIS800T2" , .F. , .F. , {cNameCFDI , cDoc , cSerie , cEspecie , cClieProv , cLoja} )
	Endif

	// Nuevo nombre de la factura (original)
	cNameORIG := Substr(cNameCFDI, 1, AT( "." , cNameCFDI)-1) + "_original.xml"
	// Respalda factura original en el servidor
	Frename( cRUTASRV + cNameCFDI, cRUTASRV + cNameORIG )

	If lHTML //Tratamiento para timbrado en WEB
		COPY FILE (cRUTASMR+cNameCFDI) TO (cRUTASRV+cNameCFDI)
	ElseIf lJob //Tratamiento para timbrado desde Job
		__CopyFile(cRUTASMR+cNameCFDI, cRUTASRV+cNameCFDI)
	Else
		// Copia factura timbrada al servidor
		CpyT2S( cRUTASMR + cNameCFDI, cRUTASRV )
	Endif

	// Borra temporal en el remote
	Ferase( cRUTASMR + cNameCFDI )
	// Flag de proceso correcto
	cRet := ""

	// Impresión del CFDi
	If Trim(cEspecie) == "NF" .And. !Empty(cCFDiNF) .And. ExistBlock(cCFDiNF)
		ExecBlock( cCFDiNF , .F. , .F. , {cDoc , cSerie , cEspecie , cClieProv , cLoja} )
	ElseIf Trim(cEspecie) == "NCC" .And. !Empty(cCFDiNC) .And. ExistBlock(cCFDiNC)
		ExecBlock( cCFDiNC , .F. , .F. , {cDoc , cSerie , cEspecie , cClieProv , cLoja} )
	Endif

Else
	If lDeMenu
		Aviso(STR0015, STR0023 + CRLF + cError + If( Empty(cDetalle), "", " - " ) + cDetalle, {STR0018})  //Se produjo el siguiente error: XXXXX, no se genero el timbre...
	Else
		cRet := STR0023 + cError + If( Empty(cDetalle), "", " - " ) + cDetalle
	Endif

	// Eliminar la factura.xml que se copio al Smartclient
	Ferase(cRUTASMR + cNameCFDI)

Endif

// Eliminar archivo recibido del WS (sea de error o de timbre fiscal)
Ferase( cRUTASMR + cNameCFDI + ".out" )

If  Empty(cRet) //Se pudo timbrar el documento
	cMsgTim  := STR0046 + Alltrim(cSerie) + "-" + Alltrim(cDoc) //"Se generó el Timbre Fiscal para el documento: "
	F800SolCan(cDoc , cSerie , cEspecie , cClieProv , cLoja, @cMsgTim, @lCanOK)
	 aMsj := {OemToAnsi(STR0015),cMsgTim,OemToAnsi(STR0018)}  //"Emisión de timbres fiscales" //"ok"
Endif

RestArea(aArea)

Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LeeXMLOut³ Autor ³ Laura Medina          ³ Data ³ 03/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Función para leer el archivo XML que regresa el servicio   ³±±
±±³          ³ Web al ejecutar el timbrado, con este archivo se va a      ³±±
±±³          ³ verificar si existe error o si genero correctamente el     ³±±
±±³          ³ timbre.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LeeXMLOut()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LeeXMLOut(cRuta, cNombre, cTimbre, cError, cDetalle, cRUTASMR, cFecTimbre, cFolioFisc)
Local oXML
Local lRet     := .F.
Local cArchiOUT:= Substr(cRuta,2) + cNombre + ".out"   //Archivo recibido del servicio web
Local cXML     := ""

oXml := XmlParserFile(cArchiOUT, "", @cError, @cDetalle )

If valType(oXml) == "O"				//Es un objeto
	SAVE oXml XMLSTRING cXML

	If AT( "ERROR" , Upper(cXML) ) > 0 .And. AT ("UUID=" , Upper(cXML)) = 0	// El archivo tiene errores
		If AT( "CFDI:ERROR" , Upper(cXML) ) > 0
			If 	ValType(oXml:_CFDI_ERROR) == "O"
				cError := oXml:_CFDI_ERROR:_CODIGO:TEXT
				cDetalle := oXml:_CFDI_ERROR:_CFDI_DESCRIPCIONERROR:TEXT
			Endif
		ElseIf AT( "<ERROR" , Upper(cXML) ) > 0
			If 	ValType(oXml:_ERROR) == "O"
				cError := oXml:_ERROR:_CODIGO:TEXT
				cDetalle := oXml:_ERROR:_DESCRIPCIONERROR:TEXT
			Endif
	    Endif
		If Empty(cError)
			cError := cXML
		Endif
	Else							// Obtener timbre
		// <ARL 14/11/2011> sefactura... <ARL 05/01/2011> Cambio (correccion) del PAC; v3.2 CFDi y v2.2 CFD
		If At( "CFDI:COMPROBANTE " , Upper(cXml) ) > 0
			// Se recibe todo el CFDi con el certificado del SAT (TFD)
			If At( "TFD:TIMBREFISCALDIGITAL " , Upper(cXml) ) > 0
				cTimbre := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
				cFecTimbre := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT
				cFolioFisc := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
			ElseIf At( "TIMBREFISCALDIGITAL:TIMBREFISCALDIGITAL " , Upper(cXml) ) > 0
				// Version anterior a 2012 de sefactura
				cTimbre := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TIMBREFISCALDIGITAL_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
				cFecTimbre := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TIMBREFISCALDIGITAL_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT
				cFolioFisc := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TIMBREFISCALDIGITAL_TIMBREFISCALDIGITAL:_UUID:TEXT
			Endif
			If !Empty( cTimbre )
				lRet := AddTimbre2(cRUTASMR, cNombre, oXml)
			Endif
		ElseIf At( "TFD:TIMBREFISCALDIGITAL " , Upper(cXml) ) > 0
			// Se recibe solo el certificado
			cTimbre := oXml:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
			cFecTimbre := oXml:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT
			cFolioFisc := oXml:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
			lRet := AddTimbre(cRUTASMR, cNombre, oXml)
		Endif

		//Si no se btuvo un error y existe el .out se visualiza
		If !lRet .And. Empty(cDetalle) .And. File(cRUTASMR + cNombre + ".out")
			cError := DecodeUTF8(MemoRead(cRUTASMR + cNombre + ".out"))
		EndIf
		// <\ARL>
	Endif
Else								// Regresar contenido del archivo como texto del error (sefactura no regresa formato xml)
	cError := MemoRead( cRUTASMR + cNombre + ".out")
Endif

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AddTimbre³ Autor ³ Laura Medina          ³ Data ³ 03/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Función para agregar el timbre al CFD que genero Protheus  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AddTimbre()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ARodriguez  ³08/12/11³TEDCQI³-Ejecución desde menú u otra UFD          ³±±
±±³            ³        ³      ³ Mensaje a consola si no es válido el xml ³±±
±±³            ³13/12/11³      ³-Cambio de MemoRead a fOpen/fReadStr      ³±±
±±³            ³06/02/14³TIGPVQ³-EncodeUTF8() --> Chr()                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AddTimbre(cRutaXML, cArchivo, oTimbre)
Local cFile		:= cRutaXML + cArchivo
Local nHandle	:= 0
Local aInfoFile	:= {}
Local nSize		:= 0
Local cXML		:= ""
Local cTimbre	:= ""
Local nIni		:= 0
Local cUTF8		:= Chr(239) + Chr(187) + Chr(191)
Local lRet		:= .F.

// Leer xml's como string
Begin Sequence

	// xml enviado a timbrar
	If !( File( cFile ) )
		Break
	EndIf

	nHandle 	:= fOpen( cFile )

	If nHandle <= 0
		Break
	EndIf

	aInfoFile	:= Directory( cFile )
	nSize		:= aInfoFile[ 1 , 2 ]
	cXML		:= fReadStr( nHandle , nSize )
	fClose( nHandle )

	// xml recibido con timbre
	If !( File( cFile + ".out" ) )
		Break
	EndIf

	nHandle 	:= fOpen( cFile + ".out" )

	If nHandle <= 0
		Break
	EndIf

	aInfoFile	:= Directory( cFile + ".out" )
	nSize		:= aInfoFile[ 1 , 2 ]
	cTimbre		:= fReadStr( nHandle , nSize )
	fClose( nHandle )

	nIni := At( "</cfdi:Complemento>" , cXML)

	If nIni ==0
		// Inserta nodo Complemento con TFD al final del CFDI
		nIni := At( "</cfdi:Comprobante>" , cXML)
		If nIni == 0
			If lDeMenu
				MsgAlert( OemToAnsi( STR0031 + CRLF + cArchivo ) ) // Archivo XML no válido
			Else
				Conout( ProcName(0) + " " + STR0031 + " " + cArchivo ) // Archivo XML no válido
			Endif
			Break
		EndIf

		// Inserta nodo del timbre fiscal
		cXML := Substr(cXML, 1, nIni-1) + ;
				Space(4) + "<cfdi:Complemento>" + CRLF + ;
				Space(8) + cTimbre + CRLF + ;
				Space(4) + "</cfdi:Complemento>" + CRLF + ;
				Substr(cXML, nIni)
	Else
		// Ya existe nodo Complemento en el CFDI, agregar sub-nodo TFD al final
		cXML := Substr(cXML, 1, nIni-1) + ;
		Space(4) + cTimbre + CRLF + Space(4) + ;
		Substr(cXML, nIni)
	EndIf

	// Codificacion UTF-8
	If Substr(cXML,1,1) == "<"
		cXML := Strtran( cXML , cUTF8 )
		cXML := cUTF8 + cXML // EncodeUTF8( cXML )
	Endif

	// Graba el xml actualizado
	If ( nHandle := fCreate( cFile + ".timbre" ) ) <> -1
		If fWrite( nHandle , cXML ) == Len(cXML)
			lRet := .T.
		Endif
		fClose( nHandle )
	Endif

End Sequence

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AddTimbre2³ Autor ³ Alberto Rodriguez     ³ Data ³ 14/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ WS de sefactura devuelve xml original + timbre             ³±±
±±³          ³ tfd <--> TimbreFiscalDigital       Copiar archivo completo ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AddTimbre2( cRutaXML, cArchivo, oTimbre )                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ARodriguez  ³08/12/11³TEDCQI³-Ejecución desde menú u otra UFD          ³±±
±±³            ³        ³      ³ Mensaje a consola si no es válido el xml ³±±
±±³            ³13/12/11³      ³-Cambio de MemoRead a fOpen/fReadStr      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AddTimbre2(cRutaXML, cArchivo, oTimbre)
Local cFile		:= cRutaXML + cArchivo + ".out"
Local nHandle	:= 0
Local aInfoFile	:= {}
Local nSize		:= 0
Local cXML		:= ""
Local nIni		:= 0
Local lRet		:= .F.

// Leer xml recibido como string
Begin Sequence

	If !( File( cFile ) )
		Break
	EndIf

	nHandle 	:= fOpen( cFile )

	If nHandle <= 0
		Break
	EndIf

	aInfoFile	:= Directory( cFile )
	nSize		:= aInfoFile[ 1 , 2 ]
	cXML		:= fReadStr( nHandle , nSize )
	fClose( nHandle )
	nIni		:= At( ":TimbreFiscalDigital " , cXML)

	If nIni == 0
		If lDeMenu
			MsgAlert( OemToAnsi( STR0031 + CRLF + cArchivo + ".out" ) ) // Archivo XML no válido
		Else
			Conout( ProcName(0) + " " + STR0031 + " " + cArchivo + ".out" )
		Endif
		Break
	EndIf

	// Graba copia del xml recibido
	lRet := __CopyFile( cFile , cRutaXML + cArchivo + ".timbre" )

End Sequence

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AddendaCFDi³Autor ³ Alberto Rodriguez     ³ Data ³ 09/12/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manejo de Addenda para timbrar xml			              ³±±
±±³          ³ Las funciones de tratamiento de xml alteran el formato!!!  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AddendaCFDi( cRutaSmartclient, cArchivoXML, cOpcion )      ³±±
±±³          ³ cOpcion 1-Elimina, 2-Restaura                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³File2Array³Autor  ³ Alberto Rodriguez     ³ Data ³ 12/12/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lee un archivo de texto y deja el contenido en un arreglo  ³±±
±±³          ³ Sin CR + LF                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ File2Array( cArchivo, aDatos )                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Extrai uma linha "FISICA" de texto (pode conter varias linhas³
	³ logicas)											           ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	cLine	:= fReadStr( nHandle , nSize )

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Gerar o Array para a GetDados       						   ³
	³ Verifica a Existencia de CHR(13)+CHR(10) //Carriage Return e ³
	³ Line Feed na linha extraida do texto Se ambos existirem, esta³
	³ mos trabalhando em ambiente Windows. Caso contrario, estamos ³
	³ em ambiente Linux e somente teremos o CHR(10) para indicar o ³
	³ final da linha 											   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
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


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Array2File³Autor  ³ Alberto Rodriguez     ³ Data ³ 12/12/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Graba un arreglo en un archivo de texto agregando CR + LF  ³±±
±±³          ³ al final de cada línea                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Array2File( cArchivo, aDatos )                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ StrQryIn ³ Autor ³ Alberto Rodriguez     ³ Data ³ 11/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Convierte un string de opciones a cadena para utilizar en  ³±±
±±³          ³ clausula IN de SQL                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ StrQryIn(cCadena) "NF /NCC/NDC"                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cCadena: 'NF ','NCC','NDC'                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function StrQryIn( cCadena )

If !Empty( cCadena )
	cCadena := StrTran( cCadena , "," , "','" )
	cCadena := StrTran( cCadena , ";" , "','" )
	cCadena := StrTran( cCadena , "/" , "','" )
	cCadena := StrTran( cCadena , "|" , "','" )
Endif

Return ( "'" + cCadena + "'" )





/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para tema "Flat"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If "MP8" $ oApp:cVersion .Or. oApp:cVersion $ "11"
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   CuentaItems()  ³ Autor   ³  Raul Ortiz            ³ Data ³02/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Cuenta el numero de items seleccionados para timbrar                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function CuentaItems(aItems)
Local nNumItems := 0
Local nLoop :=0

For nLoop := 1 to Len(aItems)
	If aItems[nLoop,2]
		nNumItems++
	Endif
Next nLoop

Return nNumItems

/*/{Protheus.doc} F800SolCan
//Realiza la solicitud de Cancelación ante el SAT del documento a sustituir.
@author luis.enriquez
@since 07/03/2022
@version 1.0
@return Nil
@param cDoc, characters, Folio del documento a sustituir.
@param cSerie, characters, Serie del documento a sustituir.
@param cEspecie, characters, Especie del documento a sustituir.
@param cCodigo, characters, Código de Cliente del documento a sustituir.
@param cLoja, characters, Código de Tienda del documento a sustituir.
@param cMsgTim, characters, Mensaje del proceso de cancelación del documento a sustituir.
@type function
/*/
Static Function F800SolCan(cDoc , cSerie , cEspecie , cCodigo , cLoja, cMsgTim, lCanOK)
	Local aAreaSF2 := SF2->(GetArea())
	Local aAreaSF3 := SF3->(GetArea())
	Local cFilSF1  := xFilial("SF1")
	Local cFilSF2  := xFilial("SF2")
	Local cFilSF3  := xFilial("SF3")
	Local cSerSus  := ""
	Local cDocSus  := ""
	Local UUIDSus  := ""
	Local lCanAut  := .F.
	Local cCRLF	   := (chr(13)+chr(10))
	Local cCanAut  := SuperGetmv(	"MV_CANAUT"  , .F. , "" ) 			    //Funcion de cancelacion automatica

	Private aRegs    := {}
	Private nCFDiCmd := SuperGetmv( "MV_CFDICMD" , .F. , 0 )					// Mostrar ventana de comando del Shell: 0=no, 1=si
	Private cRutaSmr := cRutaSmr := &(SuperGetmv( "MV_CFDSMAR" , .F. , "GetClientDir()" ))	// Ruta A donde se copiaran los archivos que vienen del servidor . . .  + "\TimbradoATEB\bin\Debug\"
	Private cRutaSrv := &(SuperGetmv( "MV_CFDDOCS" , .F. , "\cfd\facturas\" ))
	Private nTipo    := 0
	Private cCfdUser := SuperGetmv( "MV_CFDI_US" , .F. , "" )				// Usuario del servicio web (Ant: MV_CFDUSER)
	Private cCfdPass := SuperGetmv( "MV_CFDI_CO" , .F. , "" )				// Password del servicio web (Ant: MV_CFDPASS)
	Private cCFDiPAC := SuperGetmv( "MV_CFDI_PA" , .F. , "" )				// Rutina a ejecutar (PAC) (Ant: MV_CFDIPAC)
	Private cCFDiAmb := SuperGetmv( "MV_CFDI_AM" , .F. , "T" )				// Ambiente (Teste o Produccion) (Ant: MV_CFDIAMB)
	Private cCFDiCer := SuperGetmv( "MV_CFDI_CE" , .F. , "" )				// Archivo de llave pública (.cer) (Ant: MV_CFDICER)
	Private cCFDiKey := SuperGetmv( "MV_CFDI_PR" , .F. , "" )				// Archivo de llave privada (.key) (Ant: MV_CFDIKEY)
	Private cCFDiCve := SuperGetmv( "MV_CFDI_CL" , .F. , "" )				// Clave del certificado de llave privada
	Private cRutina := "Timbrado" + Trim(cCFDiPAC) + ".exe "
	
	//Proxy
	Private cProxy   := "[PROXY]"
	Private lProxySr := SuperGetmv( "MV_PROXYSR" , .F. , .F. )					// Emplear Proxy Server?
	Private cProxyIP := Trim(SuperGetmv( "MV_PROXYIP" , .F. , "" ))				// IP del Proxy Server
	Private nProxyPt := SuperGetmv( "MV_PROXYPT" , .F. , 0 )					// Puerto del Proxy Server
	Private lProxyAW := SuperGetmv( "MV_PROXYAW" , .F. , .F. )					// Autenticación en Proxy Server con credenciales de Windows?
	Private cProxyUr := Trim(SuperGetmv( "MV_PROXYUR" , .F. , "" ))				// Usuario para autenticar Proxy Server
	Private	cProxyPw := Trim(SuperGetmv( "MV_PROXYPW" , .F. , "" ))				// Clave para autenticar Proxy Server
	Private	cProxyDm := Trim(SuperGetmv( "MV_PROXYDM" , .F. , "" ))				// Dominio para autenticar Proxy Server
	Private cLogWS   := SuperGetmv( "MV_CFDILOG" , .F. , "LOG" )				// Tipo de log en consumo del servicio web: LOG (default), LOGDET (detallado), NOLOG (ninguno)

	Default lCanOK   := .F.
	// Parámetros para el Proxy Server
	cProxy += "[" + If( lProxySr , "1" , "0" ) + "]"
	cProxy += "[" + cProxyIP + "]"
	cProxy += "[" + lTrim( Str( nProxyPt ) ) + "]"
	cProxy += "[" + If( lProxyAW , "1" , "0" ) + "]"
	cProxy += "[" + If( lProxyAW , "" , cProxyUr ) + "]"
	cProxy += "[" + If( lProxyAW , "" , cProxyPw ) + "]"
	cProxy += "[" + If( lProxyAW , "" , cProxyDm ) + "]"

	If Alltrim(cEspecie) $ "NF|NDC" .And. SF2->(ColumnPos("F2_SERMAN")) > 0 .And. SF2->(ColumnPos("F2_DOCMAN")) > 0 //Factura de Venta - Nota de Débito
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

		If SF2->(MsSeek(cFilSF2 + cDoc + cSerie + cCodigo + cLoja))
			If !Empty(SF2->F2_SERMAN) .And. !Empty(SF2->F2_DOCMAN) .And. !Empty(SF2->F2_UUID) .And. !Empty(F2_FECTIMB)
				cSerSus := SF2->F2_SERMAN
				cDocSus := SF2->F2_DOCMAN
				UUIDSus := SF2->F2_UUID
				lCanAut := .T.
				If Alltrim(SF2->F2_ESPECIE) == "NF" //Factura de Venta
					nTipo := 1
				ElseIf Alltrim(SF2->F2_ESPECIE) == "NDC" //Nota de Débito
					nTipo := 2
				EndIf
			EndIf
		EndIf
	ElseIf Alltrim(cEspecie) $ "NCC" .And. SF1->(ColumnPos("F1_SERMAN")) > 0 .And. SF1->(ColumnPos("F1_DOCMAN")) > 0
		dbSelectArea("SF1")
		SF1->(dbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO

		If SF1->(MsSeek(cFilSF1 + cDoc + cSerie + cCodigo + cLoja))
			If !Empty(SF1->F1_SERMAN) .And. !Empty(SF1->F1_DOCMAN) .And. !Empty(SF1->F1_UUID) .And. !Empty(F1_FECTIMB)
				cSerSus := SF1->F1_SERMAN
				cDocSus := SF1->F1_DOCMAN
				UUIDSus := SF1->F1_UUID
				nTipo := 3
				lCanAut := .T.
			EndIf
		EndIf
	EndIf

	If lCanAut .And. nTipo > 0 .And. !Empty(UUIDSus) .And. cCanAut != "N"
		dbSelectArea("SF3")
		SF3->(dbSetOrder(6)) //F3_FILIAL+F3_NFISCAL+F3_SERIE
		If SF3->(MsSeek(cFilSF3 + cDocSus + cSerSus))
			If SF3->F3_STATUS == "S" //Documento anulado pero no Canelado ante el SAT
				aAdd( aRegs , Array(12))

				aRegs[Len(aRegs),4]  := fNombreXml(SF3->F3_CODNFE) //Nombre XML
				aRegs[Len(aRegs),10] := .T.
				aRegs[Len(aRegs),11] := SF3->F3_MOTIVO //Motivo
				aRegs[Len(aRegs),12] := UUIDSus //UUID que Sustituye

				Processa( {|| ProcesoWS("S",.T.) }, STR0042, STR0043, .F.) //"Solicitud de cancelación de CFDI" //"Procesando solicitud ante el SAT... Espere"
				If F800ResCan(fNombreXml(SF3->F3_CODNFE))
					//Soliciud de Cancelación ante el SAT exitosa
					If SF3->(RecLock( "SF3" , .F.))
						SF3->F3_STATUS := ""
						SF3->(MSUnlock())
					EndIf
					lCanOK := .T.
					cMsgTim += cCRLF + STR0044 + Alltrim(cSerSus) + "-" + Alltrim(cDocSus) //"Documento Cancelado ante el SAT: "
				Else
					//Soliciud de Cancelación ante el SAT SIN exito
					cMsgTim += cCRLF + STR0045 + Alltrim(cSerSus) + "-" + Alltrim(cDocSus) //"Documento NO Cancelado ante el SAT: "
				EndIf
			EndIf
		EndIf
	ElseIf lCanAut .And. cCanAut == "N"
		cMsgTim += cCRLF + Strtran(STR0048, "#cDocSus#", (Alltrim(cSerSus)+'-'+cDocSus)) //"El documento #cDocSus# quedo pendiente de cancelación ante el SAT, no olvide realizar dicha cancelación."
	EndIf
		

	RestArea(aAreaSF2)
	RestArea(aAreaSF3)
Return Nil

/*/{Protheus.doc} F800ResCan
//Obtiene atributos de la respuesta de WS de solicutud de cancelación.
@author luis.enriquez
@since 19/02/2022
@version 1.0
@return lCancel, array, .T. si la cancelación fue exitosa y .F. si no fue exitosa.
@param cNameCFDI, characters, Nombre del XML para lectura del archivo .out
@type function
/*/
Function F800ResCan(cNameCFDI)
	Local oXML     := Nil
	Local cError   := ""
	Local cDetalle := ""
	Local cCodigo  := ""
	Local lCancel  := .F.
	Local aResp    := {}
	Local cNomXML  := ""

	cNomXML := cRutaSrv + cNameCFDI + ".sol"
	oXml := XmlParserFile(cNomXML, "", @cError, @cDetalle )

	If XmlChildEx(oXml, "_CLSCANCELA") <> Nil
		// XML generado por el ejecutable de timbrado
		cCodigo := oXml:_CLSCANCELA:_CODESTATUS:Text

		If cCodigo == "0"
			If XmlChildEx(oXml:_CLSCANCELA, "_FOLIOS") <> Nil
				// Nodo de estado del UUID
				If ValType(oXml:_CLSCANCELA:_FOLIOS) == "A"
					cCodigo := oXml:_CLSCANCELA:_FOLIOS[1]:_FOLIO:_ESTATUSUUID:Text
				Else
					If XmlChildEx(oXml:_CLSCANCELA:_FOLIOS:_FOLIO,"_ESTATUSUUID") <> Nil
						cCodigo := oXml:_CLSCANCELA:_FOLIOS:_FOLIO:_ESTATUSUUID:Text
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If cCodigo == "201" .Or. cCodigo == "202"
		lCancel := .T.
	EndIf

	If !lCancel .And. UPPER(cCFDiPAC) == "SOLUCIONFACTIBLE"
		aResp := RespWS("E", cNameCFDI,, .T.)
		If aResp[1] $ "3|4|5" //Cancelado sin aceptación - Cancelado con aceptación - Plazo vencido
			lCancel := .T.
		EndIf
	EndIf
Return lCancel

/*/{Protheus.doc} fNombreXml
    Asegura que el nombre del archivo xml tenga la extensión completa
	@type    Function
	@author  ARodriguez
	@since   03/05/2022
	@version 1.0
	@param   cArchivo, string, nombre de archivo
	@return  cArchivo, string, nombre de archivo
	@example
	nf_fat_00000000000000000014.xm -> nf_fat_00000000000000000014.xml
/*/
Function fNombreXml(cArchivo)
Local nPunto := 0

cArchivo := Alltrim(cArchivo)

If Lower(Right(cArchivo,4)) <> ".xml"
	nPunto := Rat(".", cArchivo)
	cArchivo := Substr(cArchivo, 1, IIf(nPunto==0, Len(cArchivo), nPunto-1)) + ".xml"
EndIf

Return cArchivo
