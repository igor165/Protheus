#include "Protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"
#Include "RPTDEF.CH"
#include "FISA816.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³FISA816   ³ Autor ³ Ivan Gomez Azp      ³ Fecha ³02/10/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Asignar transportadora, vehículo y acoplado                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ FISA816                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                         ACTUALIZACIONES                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha    ³ Comentario                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISA816()
	Local cPerg := "FISA816"
	
	Private oBrowse := Nil
	Private cDFecha := ""
	Private cAFecha := ""
	Private cDRemito := ""
	Private cARemito := ""
	Private cDCliente := ""
	Private cACliente := ""
	Private cDSucursal := ""
	Private cASucursal := ""
	Private cTranspor := ""
	Private cVehiculo := ""
	Private cAcoplado := ""
	Private cEspecDoc := "RFN"
	Private aTmpArea :={}
	Private cArqTmp := GetNextAlias()
	Private oTabTmp := FWTemporaryTable():New(cArqTmp)

	Pergunte( cPerg, .T. )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas           							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros						 ³
	//³ mv_par01	  // De fecha?		 ³
	//³ mv_par02 	  // Hasta Fecha?		 ³
	//³ mv_par03	  // ¿De Remito?									 ³
	//³ mv_par04	  // A Remito?								 ³
	//³ mv_par05	  // De	Cliente									 ³
	//³ mv_par06	  // Ate Cliente								 ³
	//³ mv_par07	  // De Filial 									 ³
	//³ mv_par08	  // A Filial								 ³
	//³ mv_par09	  // ¿Con Transportadora?							 ³
	//³ mv_par10	  // ¿Con Vehículo?									 ³
	//³ mv_par11	  // ¿Con Acoplado?								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDFecha := DToS(mv_par01)
	cAFecha := DToS(mv_par02)
	cDRemito := mv_par03
	cARemito := mv_par04
	cDCliente := mv_par05
	cACliente := mv_par06
	cDSucursal := mv_par07
	cASucursal := mv_par08
	cTranspor := mv_par09 == 1
	cVehiculo := mv_par10 == 1
	cAcoplado := mv_par11 == 1
	
	MsAguarde({ | | AsigVehi()}, OemToAnsi(STR0005) )	
	DelAreabSF2()
	DbCloseArea() 			
	oTabTmp:Delete()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³AsigVehi  ³ Autor ³ Juan Roberto Glez   ³ Fecha ³01/11/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Monta pantalla con los Remitos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIS                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AsigVehi()
	Local cQuery     := ""
	Local aCampos    := {} // Crea estructura
	Local aCpos      := {} // Crea encabezado
	
	Private cMarcaF2	:= ""
	Private cCadastro	:= ""
	Private lInverte	:= .F.
	Private aRotina	:= ""
	
	// Estructura tabla temporal
	AADD(aCampos,{ "MARK",		"C", 2,  							0,							'@!'	})
	AADD(aCampos,{ "FILIAL",		"C", TamSX3("F2_FILIAL")[1],	TamSX3("F2_FILIAL")[2] 			})
	AADD(aCampos,{ "CLIENTE",	"C", TamSX3("F2_CLIENTE")[1],	TamSX3("F2_CLIENTE")[2]			})
	AADD(aCampos,{ "SUCURSAL",	"C", TamSX3("F2_LOJA")[1],		TamSX3("F2_LOJA")[2]				})
	AADD(aCampos,{ "DOCUMENTO",	"C", TamSX3("F2_DOC")[1],		TamSX3("F2_DOC")[2]				})
	AADD(aCampos,{ "SERIE",		"C", TamSX3("F2_SERIE")[1],		TamSX3("F2_SERIE")[2]			})
	AADD(aCampos,{ "EMISION",	"D", TamSX3("F2_EMISSAO")[1],	TamSX3("F2_EMISSAO")[2]			})
	AADD(aCampos,{ "TRANSP",		"C", TamSX3("F2_TRANSP")[1],	TamSX3("F2_TRANSP")[2]			})
	AADD(aCampos,{ "VEHICULO",	"C", TamSX3("F2_VEHICL")[1],	TamSX3("F2_VEHICL")[2]			})
	AADD(aCampos,{ "ACOPLADO",	"C", TamSX3("F2_ACOPLA")[1],	TamSX3("F2_ACOPLA")[2]			})
	AADD(aCampos,{ "RECNO",		"N", 10,							0									})
	
	oTabTmp:SetFields(aCampos)
	oTabTmp:Create()
		
	cQuery := "SELECT F2_OK MARK, F2_FILIAL FILIAL, F2_CLIENTE CLIENTE, F2_LOJA SUCURSAL, F2_DOC DOCUMENTO, F2_SERIE SERIE, F2_EMISSAO EMISION, F2_TRANSP TRANSP, F2_VEHICL VEHICULO, F2_ACOPLA ACOPLADO, SF2.R_E_C_N_O_ RECNO "
	cQuery += "FROM " +	RetSqlName("SF2") + " SF2 "
	cQuery += "WHERE F2_EMISSAO BETWEEN '" + cDFecha + "' AND '" + cAFecha + "' "
	cQuery += "AND F2_CLIENTE BETWEEN '" + cDCliente + "' AND '" + cACliente + "' "
	cQuery += "AND F2_LOJA BETWEEN '" + AllTrim(cDSucursal) + "' AND '" + AllTrim(cASucursal)+"' "
	cQuery += "AND F2_DOC BETWEEN '" + cDRemito + "' AND '" + cARemito + "' "
	cQuery += "AND F2_FILIAL = '" + xFilial("SF2") + "' "
	If SF2->(ColumnPos("F2_REGCOT")) > 0
		cQuery += "AND F2_REGCOT != '3' "
	EndIf
	cQuery += "AND F2_ESPECIE = '" + cEspecDoc + "' "
	If cTranspor 
		cQuery += "AND F2_TRANSP != '      ' "
	End
	If cVehiculo 
		cQuery += "AND F2_VEHICL != '        ' "
	End
	If cAcoplado 
		cQuery += "AND F2_ACOPLA != '        ' "
	End
		
	cQuery += "AND SF2.D_E_L_E_T_ != '*' "
	cQuery += "ORDER BY F2_FILIAL, F2_CLIENTE, F2_LOJA, F2_DOC, F2_SERIE"
	
	cQuery := ChangeQuery(cQuery)
	SqlToTrb(cQuery,aCampos,cArqTmp)
	
	dbSelectArea(cArqTmp)
	(cArqTmp)->(dbGoTop())
	
	// Estructura encabezado
	AADD(aCpos,{ "MARK",			"", "" })
	AADD(aCpos,{ "FILIAL",		"", OemToAnsi(STR0002) }) //"Sucursal"
	AADD(aCpos,{ "CLIENTE",		"", OemToAnsi(STR0007) }) //"Cliente"
	AADD(aCpos,{ "SUCURSAL",		"", OemToAnsi(STR0008) }) //"Sucursal"
	AADD(aCpos,{ "DOCUMENTO",	"", OemToAnsi(STR0006) }) //"Documento"
	AADD(aCpos,{ "SERIE",		"", OemToAnsi(STR0009) }) //"Serie"
	AADD(aCpos,{ "EMISION",		"", OemToAnsi(STR0016) }) //"Fecha de Emision"
	AADD(aCpos,{ "TRANSP",		"", OemToAnsi(STR0010) }) //"Transportadora"
	AADD(aCpos,{ "VEHICULO",		"", OemToAnsi(STR0011) }) //"Vehiculo"
	AADD(aCpos,{ "ACOPLADO",		"", OemToAnsi(STR0012) }) //"Acoplado"

	aRotina := MenuDef()
	cMarcaF2 := GetMark()
	MarkBrow(cArqTmp, "MARK", "", aCpos, , cMarcaF2, , , , , Nil)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³MenuDef   ³ Autor ³ Ivan Gomez Azp      ³ Fecha ³02/10/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Menu de opciones                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIS                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
	Local aRotina := {}

	aRotina :=	{{OemToAnsi(STR0010), "A816Trans()", 0 , 1 , 0 , NIL},; //"Asignar Transportadora"
				{OemToAnsi(STR0011),"A816Vehicl()", 0 , 2 , 0 , NIL},; //"Asignar Vehiculo"
				{(OemToAnsi(STR0012)),"A816Acopla()", 0 , 3 , 0 , NIL}} //"Asignar Acoplado"
Return(aRotina)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³A816Trans   ³ Autor ³ Ivan Gomez Azp    ³ Fecha ³02/10/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Muestra Transportadora                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIS                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A816Trans()
Local nOpca := 0
Local cCampo := SPACE(TamSX3("F2_TRANSP")[1])
Local lExiste := .T.

	DEFINE MSDIALOG oDlg FROM 5, 5 TO 14, 30 TITLE OemToAnsi(STR0013) //"Asignar Transportadora"
	@ 010, 010 SAY STR0010 SIZE 100, 50 OF oDlg PIXEL //"Transportadora"
	@ 020, 010 MSGET cCampo SIZE 60, 10 OF oDlg PIXEL F3 "SA4"
	DEFINE SBUTTON FROM 040, 010 TYPE 1 ACTION (nOpca := 1, oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 040, 040 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED
	If nOpca == 1
		DbSelectArea("SF2")
		SF2->(DbSetOrder(2))
		DbSelectArea(cArqTmp)
		(cArqTmp)->(DbGoTop())	
		ProcRegua(Reccount())
		If !Empty (cCampo)
			Do While !(cArqTmp)->(EOF())
				IncProc()
				If IsMArk("MARK", cMarcaF2, lInverte)
					RecLock(cArqTmp, .F.)
					Replace MARK With ""
					MsUnLock()
					
					If SF2->(MsSeek(xFilial("SF2") + (cArqTmp)->CLIENTE + (cArqTmp)->SUCURSAL + (cArqTmp)->DOCUMENTO))
						RecLock("SF2",.F.)
						SF2->F2_TRANSP := cCampo
						MsUnlock()
						RecLock(cArqTmp,.F.)
						(cArqTmp)->TRANSP := cCampo
						MsUnlock()
						LExiste := .F.
					EndIf
				EndIf
				(cArqTmp)->(dbSkip())	
			EndDo
		Else
			Alert (STR0018) //"No se informó registro."
		EndIf
		If lExiste
			Alert (STR0017) //"No se realizó ninguna asignación."
		EndIf
	EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³A816Vehicl  ³ Autor ³ Ivan Gomez Azp    ³ Fecha ³02/10/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Muestra Vehiculos                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIS                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A816Vehicl()

Local nOpca := 0
Local cCampo := SPACE(TamSX3("F2_VEHICL")[1])
Local lExiste := .T.
Local lExisTra := .T.
Local nTransp := 0
Local lVehicl := .F.
Local cTipVehi := ""

	DEFINE MSDIALOG oDlg FROM 5, 5 TO 14, 30 TITLE OemToAnsi(STR0014) //"Asignar Vehiculo" 
	@ 010, 010 SAY STR0011 SIZE 100, 50 OF oDlg PIXEL //"Vehiculo"
	@ 020, 010 MSGET cCampo SIZE 60, 10 OF oDlg PIXEL F3 "DA3"
	DEFINE SBUTTON FROM 040, 010 TYPE 1 ACTION (nOpca := 1, oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 040, 040 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED
	If nOpca == 1
		DbSelectArea("SF2")
		SF2->(DbSetOrder(2))
		DbSelectArea(cArqTmp)
		(cArqTmp)->(dbGoTop())	
		ProcRegua(Reccount())
		If !Empty (cCampo)
			Do While !(cArqTmp)->(EOF())
				IncProc()
				If IsMArk("MARK", cMarcaF2, lInverte)
					RecLock(cArqTmp, .F.)
					Replace MARK With ""
					MsUnLock()
					aArea    := GetArea()
					DbSelectArea('DA3')
					DbSetorder(1)
					
					If MsSeek(xFilial("DA3") + cCampo)
						cTipVehi := DA3->DA3_TIPVEI
						DbSelectArea('DUT')
						DBSetOrder(1)
						If MsSeek(xFilial("DUT") + cTipVehi)
							If DUT_CATVEI == '6'
								Alert(STR0021) //"El Tipo de Vehículo debe de ser diferente de Acoplado"
								lVehicl := .T.
							EndIf
						EndIF
					Else
						lVehicl := .T.
					EndIf
					
					If !lVehicl
						If SF2->(MsSeek(xFilial("SF2") + (cArqTmp)->CLIENTE + (cArqTmp)->SUCURSAL + (cArqTmp)->DOCUMENTO))
							RecLock("SF2", .F.)
							SF2->F2_VEHICL := cCampo
							MsUnlock()
							RecLock(cArqTmp, .F.)
							(cArqTmp)->VEHICULO := cCampo
							MsUnlock()
							LExiste := .F.
							If empty(SF2->F2_TRANSP)
								lExisTra := .F.
							EndIf
						EndIf
					EndIf
				EndIf
				(cArqTmp)->(dbSkip())	
			EndDO
		Else
			Alert (STR0018) //"No se informó resgitro"
		EndIf
		If lExiste
			Alert (STR0017) //"No se realizó ninguna asignación"
		EndIf
		If !lExiste .And. !lExisTra
			Alert (STR0019) //"Existen registros sin Asignar Transportadora"
		EndIf
		If !lExiste .And. lVehicl
			Alert (STR0022) //"No existe el Tipo de Vehículo"
		EndIf
	EndIf
	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³A816Acopla  ³ Autor ³ Ivan Gomez Azp    ³ Fecha ³02/10/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Muestra Acoplados                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIS                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A816Acopla()	

Local nOpca := 0
Local cCampo := SPACE(TamSX3("F2_ACOPLA")[1])
Local lExiste := .T.
Local lExisTra := .T.
Local nTransp := 0
Local lVehicl := .F.
Local cTipVehi := ""
Local lExisVe := .T.

	DEFINE MSDIALOG oDlg FROM 5, 5 TO 14, 30 TITLE OemToAnsi(STR0015) //"Asignar Acoplado"
	@ 010, 010 SAY STR0012 SIZE 100, 50 OF oDlg PIXEL //"Acoplado"
	@ 020, 010 MSGET cCampo SIZE 60, 10 OF oDlg PIXEL F3 "DA3"
	DEFINE SBUTTON FROM 040, 010 TYPE 1 ACTION (nOpca := 1, oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 040, 040 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED
	If nOpca == 1
		DbSelectArea("SF2")
		SF2->(DbSetOrder(2))
		DbSelectArea(cArqTmp)
		(cArqTmp)->(dbGoTop())	
		ProcRegua(Reccount())
		If !Empty (cCampo)
			Do While !(cArqTmp)->(EOF())
				IncProc()
				If IsMArk("MARK", cMarcaF2, lInverte)
					RecLock(cArqTmp, .F.)
					Replace MARK With ""
					MsUnLock()
					aArea := GetArea()
					DbSelectArea('DA3')
					DbSetorder(1)
					
					If MsSeek(xFilial("DA3") + cCampo)
						cTipVehi := DA3->DA3_TIPVEI
						DbSelectArea('DUT')
						DbSetOrder(1)
						If MsSeek(xFilial("DUT") + cTipVehi)
							If DUT_CATVEI != '6'
								Alert(STR0020) //"El Tipo de Vehículo debe de ser Acoplado"
								lVehicl := .T.
							EndIf						
						EndIf
					Else
						lVehicl := .T.	
					EndIf
					
					If !lVehicl
						If SF2->(MsSeek(xFilial("SF2") + (cArqTmp)->CLIENTE + (cArqTmp)->SUCURSAL + (cArqTmp)->DOCUMENTO))
							RecLock("SF2", .F.)
							SF2->F2_ACOPLA := cCampo
							MsUnlock()
							RecLock(cArqTmp, .F.)
							(cArqTmp)->ACOPLADO := cCampo
							MsUnlock()
							LExiste := .F.
							If empty(SF2->F2_TRANSP)
								lExisTra := .F.
							EndIf
							If empty(SF2->F2_VEHICL)
								lExisVe := .F.
							EndIf
						EndIf
					EndIf
				EndIf
				(cArqTmp)->(dbSkip())	
			EndDo
		Else
			Alert (STR0018) //"No se informó resgitro"
		EndIf
		If lExiste
			Alert (STR0017) //"No se realizó ninguna asignación"
		EndIf
		If !lExiste .And. !lExisTra
			Alert (STR0019) //"Existen registros sin Asignar Transportadora"	
		EndIf
		If !lExiste .And. !lExisVe
			Alert (STR0003) //"Existen registros sin Asignar Vehiculo"
		EndIf
		If !lExiste .And. lVehicl
			Alert (STR0022) //"No existe el Tipo de Vehículo"
		EndIf
	EndIf
Return

/*                                                                                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DelAreaTrab³ Autor ³ Laura Medina Prado   ³ Data ³ 18/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Borra los archivos de trabajo.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DelAreabSF2() 
Local nI := 0
	For nI := 1 To Len(aTmpArea)
		If Select(aTmpArea[nI,1]) > 0
			DbSelectArea(aTmpArea[nI])
			&(aTmpArea[nI,1])->(dbCloseArea())
			FErase(aTmpArea[nI,2] + GetDBExtension())
			FErase(aTmpArea[nI,2] + IndexExt())
		EndIf		
	Next nI
Return 