#include "rwmake.ch"
#include "protheus.ch"
#include "UPDFINMI.ch"               

//Fecha de la ultima actualizacion realizada
#define CMP_LAST_UPDATED "25/11/2013"  // "Actualización del campo F2_CLIENTE, anexo de consulta estándar SA1 en el diccionario de datos. "

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³LdLtFINMI³ Autor ³ Mayra Camargo        ³ Fecha ³ 15/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³Carga la lista de actualizaciones para Mercado Int.        ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ UPDMODMI                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                        ACTUALIZACIONES                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ Fecha  ³ Comentario                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ A. Rodriguez³22/11/13³THJRBP: Selección de empresa                    ³±±
±±³ Laura Medina³28/11/13³THJRBP: Se quito las etiquetas fijas            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LdLtFINMI()
	Local aCpySM0   := {}
	Local nChoice   := 1
	Local cExcEmp   := ""
	Local lEjecuta  := .T.

	If  LoadEmp(@aCpySM0) //Diferentes paises, debe seleccionar la empresa
		If  MontaEmp(@nChoice,aCpySM0)
			cPaisLoc:= aCpySM0[nChoice,3] //Se obtiene el pais de eleccion de la empresa
			cExcEmp := aCpySM0[nChoice,1] //Empresa que se va a ejecutar
		Else
			lEjecuta  := .F.
		Endif
	Endif

	If  lEjecuta
		Do Case
			Case cPaisLoc == "ARG"
				aAdd(aLista, { .F., "01", OemToAnsi(STR0001), Ctod("25/11/2013"), Ctod('/ /') }) 		
			Case cPaisLoc == "COL"
				aADD(aLista,{.F.,"01", OemToAnsi(STR0002),CTod("05/06/2013"),CtOD('/ /')})	
			Case cPaisLoc == "PER"
				aAdd(aLista, { .F., "01", OemToAnsi(STR0003), Ctod("15/10/2013"), Ctod('/ /') })  //"Creacion del campo ED_OPERADT y actualización del grupo de preguntas MT101N."
		End Case
	End IF
Return (Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ProxOrdem ºAutor  ³Laura Medina        º Data ³  24/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica a proxima orden en la SX3 para la creación de nue- º±±
±±º          ³vos campos.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Sigafis                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ProxOrdem(cTabla,cOrden)

Local nProxOrdem:= 0
Local aAreaSX3  := SX3->(GetArea())     
Local nOrden    := 0

Default cOrden	:= ""

// Verificando a ultima ordem utilizada
If  Empty(cOrden)
	dbSelectArea("SX3")
	dbSetOrder(1)
	If MsSeek(cTabla)
		Do While SX3->X3_ARQUIVO == cTabla  .And. !SX3->(Eof())
			cOrden := SX3->X3_ORDEM
			SX3->(dbSkip())
		Enddo
	Else
		cOrden := "00"
	EndIf
Endif

SX3->(RestArea(aAreaSX3))

nOrden    := RetAsc(cOrden,3,.F.)   //A0 -> 100
nProxOrdem:= VAL(nOrden)+ 1

Return nProxOrdem


/*
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--+-----------+----------+-------+---------------------+-------+----------+--
--|Programa   | LoadEmp  | Autor | Laura Medina        | Fecha |25/10/2013|--
--+-----------+----------+-------+---------------------+-------+----------+--
--|Descripcion|Carga laa posibles empresas.                               |--   
--+-----------+-----------------------------------------------------------+--
--|Uso        | LoadEmp                                                   |--
--+-----------+-----------------------------------------------------------+--
--|                        ACTUALIZACIONES                                |--
--+-------------+--------+------------------------------------------------+--
--| Programador | Fecha  | Comentario                                     |--
--+-------------+--------+------------------------------------------------+--
--|             |        |                                                |--
--+-------------+--------+------------------------------------------------+--
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
*/
Static Function LoadEmp(aCpySM0)
Local aSM0		:= FWLoadSM0()
Local nloop     := 0
Local nloop1    := 0
Local lNoExiste := .T.
Local lVarPais  := .F.
Default aCpySM0 := {}

For nloop:=1 to Len(aSM0)
	If  nloop==1
		aAdd(aCpySM0,{aSM0[nloop,1],aSM0[nloop,6],""})
	Else
		lNoExiste := .T.
		For nloop1:=1 to len(aCpySM0)
		    If  aSM0[nloop,1] == aCpySM0[nloop1,1]
		    	lNoExiste := .F.
		    Endif
		Next nloop1
		If  lNoExiste
			aAdd(aCpySM0,{aSM0[nloop,1],aSM0[nloop,6],""})
		Endif
	Endif
Next nloop

For nloop1:=1 to len(aCpySM0)
	RpcSetType(3) //3=Nao consome licenca de uso
	RpcSetEnv(aCpySM0[nloop1,1], FWGETCODFILIAL)

	aCpySM0[nloop1,3] :=  cPaisLoc
	
	RpcClearEnv()
	OpenSm0Excl()
Next nloop1

For nloop:=1 to Len(aCpySM0)
	For nloop1:=1 to len(aCpySM0)
	    If  aCpySM0[nloop,3] != aCpySM0[nloop1,3]
	    	lVarPais := .T.
	    	Exit
	    Endif
	Next nloop1
	If  lVarPais
		Exit
	Endif
Next nloop

Return (lVarPais)       


/*
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--+-----------+----------+-------+---------------------+-------+----------+--
--|Programa   | MontaEmp | Autor | Laura Medina        | Fecha |25/10/2013|--
--+-----------+----------+-------+---------------------+-------+----------+--
--|Descripcion| Funcion que monta las empresas-Pais (solo diferentes).    |--   
--+-----------+-----------------------------------------------------------+--
--|Uso        | LoadEmp                                                   |--
--+-----------+-----------------------------------------------------------+--
--|                        ACTUALIZACIONES                                |--
--+-------------+--------+------------------------------------------------+--
--| Programador | Fecha  | Comentario                                     |--
--+-------------+--------+------------------------------------------------+--
--|             |        |                                                |--
--+-------------+--------+------------------------------------------------+--
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
*/
Static Function MontaEmp(nChoice,aCpySM0)
	Local lRet 		:= .F.
	Local cOrd 		:= "1"
	Local aModulo 	:= {}
	Local oDlg		:= Nil
	Local oCombo	:= Nil
	Local oBtnOk	:= Nil
	Local oBtnCl	:= Nil
	Local nloop     := 0
	Local aListSM0  := {}
	
	For nloop:=1 to len(aCpySM0)
		aAdd( aListSM0, aCpySM0[nloop,1]+" - "+aCpySM0[nloop,2] )
	Next nloop
	
	nChoice 		:= 1

	//Monta array com os modulos
	
	DEFINE MSDIALOG oDlg FROM 00,00 TO 120,440 PIXEL TITLE OemToAnsi(STR0004) //"Seleccion Empresa..."
	
	@ 20,05 BUTTON oBtnOk Prompt STR0005 SIZE 45 ,10   FONT oDlg:oFont ACTION (lRet := .T., oDlg:End()) OF oDlg PIXEL //"OK"
	@ 20,60 BUTTON oBtnCl Prompt STR0006 SIZE 45 ,10   FONT oDlg:oFont ACTION (oDlg:End()) OF oDlg PIXEL 				  //"Cancelar"
	
	@05,05 COMBOBOX oCombo VAR cOrd ITEMS aListSM0 SIZE 206,36 PIXEL OF oDlg FONT oDlg:oFont
	
	oCombo:bChange := {|| nChoice := oCombo:nAt }
	oDlg:lEscClose := .F.
	
	ACTIVATE MSDIALOG oDlg CENTERED

Return ( lRet )
