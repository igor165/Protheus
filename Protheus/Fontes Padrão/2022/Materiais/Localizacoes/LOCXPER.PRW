#Include 'PROTHEUS.CH'
#Include 'LOCXPER.CH'
#Define SnTipo      1
#Define SlFormProp  3
#Define ScEspecie   8
#Define ScTipoDoc  10
#Define SlRemito   18
/*/{Protheus.doc} fCposNfPer
Funcion utilizada para agregar campos al encabezado de
Notas Fiscales para Peru.
@type Function
@author Marco Augusto Gonzalez Rivera
@since 17/07/2020
@version 1.0
@param aCposNF, Array, Array con campos del encabezado de NF
@param cFunName, Character, Codigo de rutina
@param cTablaEnc, Character, Alias del encabezado de Notas Fiscales
@example fCposNfPer(aCposNF, cFunName, cTablaEnc)
@return aCposNF, Array, Campos para el Encabezado de Notas Fiscales.
@see (links_or_references)
/*/
Function fCposNfPer(aCposNF, cFunName, cTablaEnc)
	Local aSX3 := {}
	
	If cTablaEnc == "SF1" .And. cFunName $ "MATA101N"
		If SF1->(ColumnPos("F1_TIPOPE")) > 0
			aAdd(aCposNF, {Nil, "F1_TIPOPE", Nil, Nil, Nil, GetSX3Cache("F1_TIPOPE", "X3_VALID"), Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil})
		EndIf
    ElseIf cTablaEnc == "SF2"
    	If SF2->(ColumnPos("F2_CODDOC")) > 0 //Código del bien o servicio sujeto a detracción (Catálogo 54)
    		aSX3 := LxSX3Cache("F2_CODDOC")
			AAdd(aCposNF,{FWX3Titulo("F2_CODDOC"),"F2_CODDOC",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
		EndIf
    	If SF2->(ColumnPos("F2_MODCONS")) > 0 //Medio de Pago (Catálogo 59)
    	    aSX3 := LxSX3Cache("F2_MODCONS")
			AAdd(aCposNF,{FWX3Titulo("F2_MODCONS"),"F2_MODCONS",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
		EndIf
	EndIf
Return aCposNF

/*/{Protheus.doc} X3CachePer
Función para obtener datos del SX3 para campos usando la función GetSX3Cache
@type
@author luis.enriquez
@since 18/03/2020
@version 1.0
@param cCampo, caracter, Nombre del campo.
@return aSX3Cpos, array, Arreglo con contenido de la tabla SX3 para el campo.
@see (links_or_references)
/*/
Function X3CachePer(cCampo)
	Local aSX3Cpos := {}
	
	Default cCampo := "" 
	
	If !Empty(cCampo)
		aSX3Cpos := {GetSX3Cache(cCampo,"X3_PICTURE"), ; //1
		GetSX3Cache(cCampo,"X3_TAMANHO"), ; //2
		GetSX3Cache(cCampo,"X3_DECIMAL"), ; //3
		GetSX3Cache(cCampo,"X3_VALID"), ;   //4
		GetSX3Cache(cCampo,"X3_USADO"), ;   //5
		GetSX3Cache(cCampo,"X3_TIPO"), ;    //6
		GetSX3Cache(cCampo,"X3_CONTEXT"), ; //7
		GetSX3Cache(cCampo,"X3_F3")}        //8
	EndIf
Return aSX3Cpos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LxVldPer   ºAutor  ³Luis Enríquez Mata º Data ³  06/09/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida campos para el país Colombia. (Encabezado).          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL : True o False no se cumple validación                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOCXNF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxVldPer(aCfgNf,cFunName)	
	Local lRetVld	:= .T.
	Local cProvFE	:= SuperGetMV("MV_PROVFE",,"")
	
	Default aCfgNf   := {}
	Default cFunName := ""
	
	If cFunName == "MATA467N" .And. aCfgNf[SnTipo] == 1 .And. !Empty(cProvFE) //Factura de tipo Normal
		If SF2->(ColumnPos("F2_TIPONF")) > 0
			If M->F2_TIPONF $ "1001|1002|1003|1004" //Operación sujeta a Detracción
				If SF2->(ColumnPos("F2_CODDOC")) > 0
					lRetVld := VldCpoFEPe(M->F2_CODDOC, "F2_CODDOC",cFunName)
				EndIf
				If lRetVld .And. SF2->(ColumnPos("F2_MODCONS")) > 0
					lRetVld := VldCpoFEPe(M->F2_MODCONS, "F2_MODCONS",cFunName)
				EndIf
			EndIf
		EndIf
	EndIf
Return lRetVld

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldCpoFEPe ºAutor  ³Luis Enríquez Mata º Data ³  06/09/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida campos para Factura Electrónica de Peru (Encabezado).º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL : True o False cuando esta vacio o no cumple condicion º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOCXPER                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldCpoFEPe(cTpRel,cCpo,cFunName)
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local cCampo    := ""

	Default cCpo	 := ""
	Default cTpRel	 := ""
	Default cFunName := ""

	If cCpo $ "F2_CODDOC|F2_MODCONS"
		If Empty(cTpRel)
			cCampo := FWX3Titulo(cCpo) + " (" + cCpo + ")"
			Aviso(STR0001,StrTran(STR0002, '###', cCampo),{STR0003}) //Atención //"El campo ###, debe ser informado." //"OK"
			lRet := .F.
		EndIf
	EndIf
	RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103DetCon³ Prog. ³ TOTVS                 ³Data  ³24/11/2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta listbox com dados da conferencia do produto          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103DetCon(oList,aListBox)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do list box                                 ³±±
±±³          ³ ExpA2 = Array com o contudo da list box                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOCXNF2                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103DetCon(oList,aListBox)
Local cCodPro 	:= aListBox[oList:nAt,1]
Local aListDet 	:= {}
Local oListDet
Local oDlgDet
Local aArea 	:= sGetArea()
Local oTimer
Local oIndice
Local aIndice 	:= {}
Local cIndice
Local aIndOrd 	:= {}
Local cKeyCBE  	:= "CBE_FILIAL+CBE_NOTA+CBE_SERIE+CBE_FORNEC+CBE_LOJA+CBE_CODPRO"
Local aColunas 	:= {}
Local aCpoCBE  	:= {}
Local nI
Local aCampos 	:= FWSX3Util():GetAllFields("CBE",.T.)
Local nX 	  	:= 0
Local cX3Nivel  :=""
Local cUsado  	:= ""
Local cX3Conte  := ""

sGetArea(aArea,"CBE")
sGetArea(aArea,"SB1")
sGetArea(aArea,"SIX")

SIX->(DbSetOrder(1))
SIX->(MsSeek("CBE"))
While !SIX->(Eof()) .and. SIX->INDICE == "CBE"
	If SubStr(SIX->CHAVE,1,Len(cKeyCBE)) == cKeyCBE
		aadd(aIndice,SIX->(SixDescricao()))
		If IsDigit(SIX->ORDEM)     // se for numerico o conteudo do ORDEM assume ele mesmo, senao calcula o numero do indice (ex: "A" => 10, "B" => 11, "C" => 12, etc)
			aadd(aIndOrd,Val(SIX->ORDEM))
		Else
			aadd(aIndOrd,Asc(SIX->ORDEM)-55)
		EndIf
	EndIf
	SIX->(DbSkip())
EndDo


For nX:=1 to Len(aCampos)
	cUsado := GetSx3Cache(aCampos[nX],"X3_USADO")
	cX3Nivel := GetSx3Cache(aCampos[nX],"X3_NIVEL")
	cX3Conte := GetSx3Cache(aCampos[nX],"X3_CONTEXT")
	If ( x3uso(cUsado) .And. cNivel >= cX3Nivel .and. !(AllTrim(aCampos[nX]) $ cKeyCBE))
		aadd(aCpoCBE,{aCampos[nX],cX3Conte})
	Endif
Next nX

SB1->(DbSetOrder(1))
SB1->(MsSeek(xFilial("SB1")+cCodPro))

cIndice := aIndice[1]

For nI := 1 to Len(aCpoCBE)
	aadd(aColunas,FWX3Titulo(aCpoCBE[nI,1]))
Next

CBE->(dbsetOrder(2))

DEFINE MSDIALOG oDlgDet TITLE OemToAnsi(STR0004+cCodPro+" "+SB1->B1_DESC) From 0, 0 To 25, 67 OF oMainWnd //"Detalles de verificación del producto"
oListDet := TWBrowse():New( 02, 2, (oDlgDet:nRight/2)-5, (oDlgDet:nBottom/2)-30,,aColunas,, oDlgDet,,,,,,,,,,,, .F.,, .T.,, .F.,,, )

A103AtuDet(cCodPro,oListDet,aListDet,,aCpoCBE)

@ (oDlgDet:nBottom/2)-25, 005 Say STR0005 PIXEL OF oDlgDet //Orden 
@ (oDlgDet:nBottom/2)-25, 025 MSCOMBOBOX oIndice VAR cIndice    ITEMS aIndice    SIZE 180,09 PIXEL OF oDlgDet
oIndice:bChange := {||CBE->(DbSetOrder(aIndOrd[oIndice:nAt])),A103AtuDet(cCodPro,oListDet,aListDet,oTimer,aCpoCBE)}
@  (oDlgDet:nBottom/2)-25, (oDlgDet:nRight/2)-50 BUTTON STR0006 SIZE 40,10 ACTION ( oDlgDet:End() ) Of oDlgDet PIXEL //Retorna

DEFINE TIMER oTimer INTERVAL 1000 ACTION (A103AtuDet(cCodPro,oListDet,aListDet,oTimer,aCpoCBE)) OF oDlgDet
oTimer:Activate()

ACTIVATE MSDIALOG oDlgDet CENTERED

sRestArea(aArea)
Return .T.

/*

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RetDetLine³ Prog. ³ TOTVS                 ³Data  ³24/11/2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para retornar campos para o bLine do listbox        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RetDetLine(aListDet,nAt)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aListDet - Array com dados do listbox                      ³±±
±±³          ³ nAt      - Linha do listbox                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ A103AtuDet                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetDetLine( aListDet,nAt)
Local aRet := {}
Local nX:= 0
For nX:= 1 to len(aListDet[nAt])
	aadd(aRet,aListDet[nAt,nx])
Next nX
Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103AtuDet³ Prog. ³ TOTVS                 ³Data  ³24/11/2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza array para listbox dos detalhes de conferencia    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103AtuDet(cCodPro,oListDet,aListDet,oTimer)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodPro  - Codigo do produto a procurar no CBE             ³±±
±±³          ³ oListDet - Objeto listbox a atualizar                      ³±±
±±³          ³ aListDet - Array do listbox                                ³±±
±±³          ³ oTimer   - Objeto timer a desativar para o processo        ³±±
±±³          ³ aCpoCBE  - Campos do LISTBOX                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOCXNF2                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103AtuDet(cCodPro,oListDet,aListDet,oTimer,aCpoCBE)
Local aLine := {},nI
Local uConteudo

If ValType(oTimer) == "O"
	oTimer:Deactivate()
EndIf

aListDet := {}

CBE->(MsSeek(xFilial("CBE")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+cCodPro))

While !CBE->(eof()) .and. CBE->CBE_NOTA+CBE->CBE_SERIE == SF1->F1_DOC+SF1->F1_SERIE .and.;
		CBE->CBE_FORNEC+CBE->CBE_LOJA == SF1->F1_FORNECE+SF1->F1_LOJA .and. CBE->CBE_CODPRO == cCodPro

	aLine := {}
	For nI := 1 to Len(aCpoCBE)
		If (aCpoCBE[nI,2]) <> 'V'
			uConteudo := CBE->&(aCpoCBE[nI,1])
		Else
			uConteudo := CriaVar(aCpoCBE[nI,1])
		EndIf
		aadd(aLine,uConteudo)
	Next
	aadd(aListDet,aLine)

	CBE->(DbSkip())
EndDo
If Empty(aListDet)
	aLine := {}
	For nI := 1 To Len(aCpoCBE)
		aadd(aLine,CriaVar(aCpoCBE[nI,1],.f.))
	Next
	aadd(aListDet,aLine)
EndIf

oListDet:SetArray( aListDet )
oListDet:bLine := { || RetDetLine(aListDet,oListDet:nAT)  }

oListDet:Refresh()

If ValType(oTimer) == "O"
	oTimer:Activate()
EndIf

Return

/*/{Protheus.doc} GrvSer2Per
	Tratamiento para grabado de serie 2
	La función es llamada desde LOCXNF, función GravaNfGeral.
	@type  Function
	@author Arturo Samaniego
	@since 02/09/2022
	@version version
	@param cPrefC: Prefijo de la tabla (SF1 / SF2).
	@return Nil
	/*/
Function GrvSer2Per(cPrefC)
Local cCompSF3 := ""

Default cPrefC := ""

	If !Empty(cPrefC)
		If 	( !Empty(&(cPrefC+"_SERIE2")) .or. !Empty(&(cPrefC+"_SERORI")) )
			If cPrefC=="SF1->F1"
				cCompSF3:=SF1->(F1_FILIAL+F1_FORNECE+F1_LOJA+F1_DOC+F1_SERIE)
			Else
				cCompSF3:=SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE)
			EndIf
			DbSelectArea("SF3")
			DbSetOrder(4)
			DbSeek(cCompSF3)
			Do While !Eof() .And. SF3->(F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE)==cCompSF3
				RecLock("SF3",.F.)
					SF3->F3_SERIE2 := &(cPrefC+"_SERIE2")
					SerieNfId("SF3",1,"F3_SERORI",,,,&(cPrefC+"_SERORI"))
				MsUnLock()
				DbSkip()
			EndDo
		EndIf
	EndIf

Return

/*/{Protheus.doc} CposSerPer
	La función es llamada desde LOCXNF, función GravaCabNF
	@type  Function
	@author Arturo Samaniego
	@since 02/09/2022
	@version version
	@param  cAlias: Alias de tabla (SF1 / SF2)
			aCabNota: Campos de SF1 / SF2
			nPosSERIE: Posición del campo SERIE
			nPosSERIE2: Posición del campo SERIE2
			***Las variables aCabNota, nPosSERIE y nPosSERIE2 se pasan por referencia***
	@return Nil
	/*/
Function CposSerPer(cAlias, aCabNota, nPosSERIE, nPosSERIE2)
Local cCpSer2 := ""
Local cPrefC  := ""

Default cAlias := ""
Default aCabNota := {}
Default nPosSERIE := 0
Default nPosSERIE2 := 0

	If !Empty(cAlias) .And. Len(aCabNota) > 0
		cPrefC  := PrefixoCpo(cAlias)

		nPosSERIE2:=Ascan(aCabNota[1], cPrefC+"_SERIE2")
		If nPosSERIE2>0
			cCpSer2:=aCabNota[1][nPosSERIE2]
			aCabNota[1][nPosSERIE2]:="SERIE2"
			nPosSERIE:=Ascan(aCabNota[1], cPrefC+"_SERIE")
			aCabNota[1][nPosSERIE2]:=cCpSer2
		Else
			nPosSERIE:=Ascan(aCabNota[1], cPrefC+"_SERIE")
		Endif
	EndIf

Return

/*/{Protheus.doc} LxSer2Per
	Validación campos de serie para el país Perú
	La función es ejecutada desde LOCXNF, función NfTudOk.
	@type  Function
	@author Arturo Samaniego
	@since 02/09/2022
	@param	cAliasC: Alias tabla SF1/SF2.
			aCabNota: Campos del encabezado (SF1/SF2)
			cSerie: Serie del documento
			lSerie2: .T. Si utiliza serie 2.
	@return cSerie: Serie del documento fiscal.
	/*/
Function LxSer2Per(cAliasC, aCabNota, cSerie, lSerie2)
Local cPrefixSF := ""
Local nPos      := 0

Default cAliasC  := ""
Default aCabNota := {}
Default cSerie   := ""
Default lSerie2  := .F.

	If !Empty(cAliasC) .And. Len(aCabNota) > 0
		cPrefixSF := PrefixoCpo(cAliasC)
		
		If lSerie2
			nPos := Ascan(aCabNota[1],  cPrefixSF+"_SERIE2")
			If nPos > 0 .And. Empty(cSerie)
				cSerie := aCabNota[2][nPos]
			EndIf
			If Empty(cSerie)
				nPos := Ascan(aCabNota[1], cPrefixSF+"_SERIE", ++nPos)
				If ( nPos > 0 )
					cSerie:=aCabNota[2][nPos]
				EndIf
			EndIf
		EndIf
	EndIf
Return cSerie

/*/{Protheus.doc} CondNatPer
	Valida si el tipo de condición de pago y naturaleza/modalida son validos para el tipo de documento.
	La función es ejecutada en LOCXNF2, función LxTudOkPer.
	@type  Function
	@author Arturo Samaniego
	@since 02/09/2022
	@param 	cTipoDoc: Tipo de documento.
			cAliasI: Alias de tabla (SD1 / SD2).
			aCpItens: Array con campos de ítems.
			aCItens: Ítems de documento fiscal.
			cNatureza: Código de naturaleza/modalidad.
			cCondicao: Código de condición de pago.
			aRecnoSE1: Array con ítem de anticipo.
	@return lRet: .T. si la condición de pago y naturaleza son validos.
	/*/
Function CondNatPer(cTipoDoc,cAliasI,aCpItens,aCItens,cNatureza,cCondicao,aRecnoSE1)
Local lRet			:= .T.
Local cMsg			:= ""
Local aRecnoAux	:= {}

Default cTipoDoc  := ""
Default cAliasI   := ""
Default aCpItens  := {}
Default aCItens   := {}
Default cNatureza := ""
Default cCondicao := ""
Default aRecnoSE1 := {}

	//Valida cond de pagto e natureza de oper. conforme tipo de nota
	//"A" - Adiantamento "N" - Normal
	// ED_OPERADT = 1 - Operacao de Adiantamento
	// E4_CTRADT = 1 - Compensa Adiantamentos

	If Trim(cNatureza) <> ""
		DbSelectArea("SED")
		DbSetOrder(1)
		MsSeek(XFilial("SED")+cNatureza)
		If cTipoDoc == "A" .AND. SED->ED_OPERADT <> "1"
			cMsg += STR0013+CRLF //"Na Nota Fiscal de Adiantamento é necessário escolher uma Natureza que seja Operação de Adiantamento."
		ElseIf cTipoDoc <> "A" .AND. SED->ED_OPERADT == "1"
			cMsg += STR0014+CRLF //"Escolher uma Natureza que seja Operação de Adiantamento somente é permitido para Nota Fiscal de Adiantamento."
		EndIf
	ElseIf cTipoDoc == "A"
		cMsg += STR0015+CRLF //"Na Nota Fiscal de Adiantamento é necessário escolher uma Natureza que seja Operação de Adiantamento."
	EndIf

	If Trim(cCondicao) <> ""
		DbSelectArea("SE4")
		DbSetOrder(1)
		MsSeek(XFilial("SE4")+cCondicao)
		If cTipoDoc == "A" .AND. SE4->E4_CTRADT == "1"
			cMsg += STR0016+CRLF //"Na Nota Fiscal de Adiantamento não é possível utilizar uma condição de pagamento que compense adiantamentos."
		ElseIf cTipoDoc == "N" .AND. SE4->E4_CTRADT == "1" .AND. Len(aRecnoSE1) == 0
			cMsg += STR0017+CRLF //"Quando for utilizada condição de pagamento de compensação de adiantamentos devem ser vinculados adiantamentos aos itens através do botão ações relacionadas."
		ElseIf cTipoDoc == "N" .AND. SE4->E4_CTRADT <> "1" .AND. Len(aRecnoSE1) > 0
			cMsg += STR0018+CRLF //"Quando forem vinculados adiantamentos é necessário utilizar uma condição de pagamento que compense adiantamentos."
		EndIf
	EndIf

	If cMsg <> ""
		lRet := .F.
		Aviso(STR0019,cMsg,{STR0020}) //Atenção#OK
	EndIf

	aRecnoAux := aRecnoSE1

Return lRet

/*/{Protheus.doc} NfTudOkPer
	Función de validaciones generales de nota fiscal - Perú
	La función es ejecutada desde LOCXNF, función NfTudOk.
	@type  Function
	@author Arturo Samaniego
	@since 02/09/2022
	@param  cFunName: Nombre de función
			aCfgNf: Array de configuración de nota fiscal.
			cAliasC: Alias de tabla de encabezado (SF1 / SF2).
			cAliasI: Alias de tabla de ítems (SD1 / SD2).
			aCpItens: Array con campos de ítems.
			aCItens: Ítems de documento fiscal.
			cNatureza: Código de modalidad o naturaleza. (Pasar el valor por referencia: @cNatureza)
			cCondicao: Código de condición de pago.
			aRecnoSE1: Array con ítem de anticipo.
			cnFiscal: Número de nota fiscal.
			cSerie: Código de serie.
			cEspecie: Código de especie del documento.
			cTipDoc: Código de tipo de documento.
			cFilAnt: Código de filial.
	@return lRet: .T. Si cumple con las condiciones.
	/*/
Function NfTudOkPer(cFunName, aCfgNf, cAliasC, cAliasI, aCpItens, aCItens, cNatureza, cCondicao, aRecnoSE1, cnFiscal, cSerie, cEspecie, cTipDoc, cFilAnt)
Local cSF  := ""
Local nI   := 0
Local lRet := .T.
Local nSerie := 0
Local nNF    := 0

Default cFunName  := Funname()
Default aCfgNf    := {}
Default cAliasC   := ""
Default cAliasI   := ""
Default aCpItens  := {}
Default aCItens   := {}
Default cNatureza := CriaVar("F1_NATUREZ")
Default cCondicao := ""
Default aRecnoSE1 := {}
Default cnFiscal  := ""
Default cSerie    := ""
Default cEspecie  := ""
Default cTipDoc   := ""
Default cFilAnt   := ""

	cSF := IIf(cAliasC == "SF2", "F2", "F1")

	If SF1->(ColumnPos("F1_TPRENTA")) > 0 .AND. SF2->(ColumnPos("F2_TPRENTA")) > 0 .and.  StrZero(aCfgNf[SnTipo],2)$"06|07|08|09|10|12|13|14|20"  //NDI compras/NCP/NCI compras/NDP/NF compras/NF benef/NF import/NF fletes/NF Anticipos
		SA2->(dbSeek(xFilial("SA2") +  &("M->" + cSF + IIf(cSF == "F2", "_CLIENTE", "_FORNECE")) + &("M->" + cSF + "_LOJA")))
		If(Alltrim(SA2->A2_DOMICIL)) == "2" .And. Empty(Alltrim(&("M->" + cSF + "_TPRENTA")))  // 1- Domiciliado 2- não Domiciliado
			MsgAlert(STR0007 + "TpRen.N Do.") //"Complete el campo del encabezado: "
			lRet := .F.
		Else
			lRet := .T.
		EndIf
	EndIf

	If  &("M->" + cSF + "_TPDOC") == "05" .And. !(((Val( &("M->" + cSF + "_SERIE")) >= 1 .And. Val(&("M->" + cSF + "_SERIE")) <= 5)) .Or. ((Val(&("M->" + cSF + "_SERIE2")) >= 1 .AND. Val(&("M->" + cSF + "_SERIE2")) <= 5)))
		MsgAlert(STR0008, STR0009) //"Si el campo Tp. Comprob = 05, el Campo Serie debe tener una de las siguientes informaciones: 1=Boleta manual;2=Boleta automático;3=Boleta electrónica;4=Otros;5=Anulado" //"íATENCION!"
		lRet := .F.
	EndIf

	If lRet
		lRet := LxVldPer(aCfgNf,cFunName)
	EndIf

	If lRet .AND. (aCfgNf[SnTipo] == 1 .OR. aCfgNf[SnTipo] == 19)
		lRet := LxTudOkPer(aCfgNf[ScTipoDoc],cAliasI,aCpItens,aCItens,cNatureza,cCondicao,aRecnoSE1)
	EndIf

	If lRet .And. Valtype(aCfgNF[SlFormProp]) == "L" .And. aCfgNF[SlFormProp] .And. (!Str(aCfgNF[SnTipo],2)$"54|64|50|60") .And. GetNewPar("MV_CTRLFOL",.F.)
		lRet := CtrFolios(cFilAnt,cSerie,cEspecie,cnFiscal)
	EndIf

	If lRet .AND. MaFisRet(,"NF_BASEDUP") > 0 .AND. Empty(MaFisRet(,"NF_NATUREZA")) .AND. cTipDoc <> "D"  .AND. cAliasC == "SF1" .And. !aCfgNf[SlRemito]
		
		If !Empty(M->F1_NATUREZ)
			MaFisAlt("NF_NATUREZA",M->F1_NATUREZ)
			cNatureza:=M->F1_NATUREZ
		EndIf

		If GetNewPar("MV_NFENAT",.F.) .And. Empty(MaFisRet(,"NF_NATUREZA"))
			Aviso(STR0010,STR0011,{STR0003}) //"Preencha o codigo da natureza!"###"OK"
			lRet := .F.
		EndIf
		If lRet //Validacoes de Adiantament
			If lRet .AND. aCfgNf[SnTipo] == 20
				lRet := LxTudOkPer(aCfgNf[ScTipoDoc],cAliasI,aCpItens,aCItens,cNatureza,cCondicao,aRecnoSE1)
			endif
		Endif
	EndIf

	If lRet .And. cFunName <> "MATA447"
		if cAliasC == "SF1" .And. (aCfgNf[SnTipo] == 10 .OR. aCfgNf[SnTipo] == 20 )
			If Empty(cNatureza)
				cNatureza := M->F1_NATUREZ
			EndIf
			lRet := LxTudOkPer(aCfgNf[ScTipoDoc],cAliasI,aCpItens,aCItens,cNatureza,cCondicao,aRecnoSE1)
		Endif
	Endif

	If (( Len(cSerie) <= TamSX3(PrefixoCpo(cAliasI)+"_SERIE")[1] ))
		//³Verificando numeracao da NF em todos os itens
		nSerie	:= Ascan(aCpItens, {|x| Trim(x) == PrefixoCpo(cAliasI)+"_SERIE"})
		nNF		:= Ascan(aCpItens, {|x| Trim(x) == PrefixoCpo(cAliasI)+"_DOC"})
		For nI := 1 to Len(aCitens)
			If !aCitens[nI][Len(aCitens[nI])] .AND. aCitens[nI][nNF] != cNFiscal .OR. aCitens[nI][nSerie] != cSerie
				Aviso(STR0010,STR0012+"("+cnFiscal+"-"+cSerie+"/"+aCitens[nI][nNF]+"-"+aCitens[nI][nSerie]+")",{STR0003})					    			 //"ATENCAO"###"Inconsistencias com a numeracao da NF em relacao a seus itens"###"OK"
				lRet := .F.
				Loop
			EndIf
		Next nI
	EndIf

Return lRet

/*/{Protheus.doc} LxLinOkPer
	Función para realizar validaciones por ítem de documento fiscal.
	La función es ejecutada en LOCXNF2, función LxLOkPer.
	@type  Function
	@author Arturo Samaniego
	@since 03/09/2022
	@param 	cAliasI: Alias de tabla de items (SD1 / SD2).
			aCposIOri: Campos de ítems.
			aDadosIOri: Linea de ítems a validar.
			cTipDoc: Tipo de documento.
			nLinha: Número de ítem.
			lFormP: Indicia si es formulario propio (.T.).
			aCfgNF: Array con configuración de nota fiscal.
			cEspecie: Código de especie del documento fiscal.
			cCondicao: Código de condición de pago.
			nSalvaN: Número de ítem a validar.
			aHeader: Array con campos de ítems.
			aCols: Array de ítems.
			cFunname: Nombre de función.
	@return lRet: .T. si cumple con las condiciones.
	/*/
Function LxLinOkPer(cAliasI,aCposIOri,aDadosIOri,cTipDoc,nLinha,lFormP, aCfgNF, cEspecie, cCondicao, nSalvaN, aHeader, aCols, cFunname)
Local cTes 		:= ""
Local lRet 		:= .T.
Local nPos 		:= 0
Local nX   		:= 0
Local nAdt 		:= 0
Local nTot 		:= 0
Local cFilSF4   := xFilial("SF4")
Local cF2TipoNF := ""
Local cCpoExp   := ""
Local cAvisoE   := ""
Local cOpeExp   := ""
Local cProvFE   := GetMv( "MV_PROVFE",.T.,"")
local lAnticip  := .F.
Local nI        := 0
Local aAux      := {}
Local lFactElec	:= !Empty(SuperGetMV("MV_PROVFE", .F., "")) //Facturacion Electronica Activa

Default cAliasI    := ""
Default aCposIOri  := {}
Default aDadosIOri := {}
Default cTipDoc    := ""
Default nLinha     := 0
Default lFormP     := .F.
Default aCfgNF     := {}
Default cEspecie   := ""
Default cCondicao  := ""
Default nSalvaN    := 0
Default aHeader    := {}
Default aCols      := {}
Default cFunname   := Funname()

	nPosNFOri  := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_NFORI'})
	nPosSerOri := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_SERIORI'})
	nPosRemito := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_REMITO'})
	nPosCod    := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_COD'})
	nPosTes    := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_TES'})
	nAdt       := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_VALADI'})
	nTot       := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_TOTAL'})
	cCpoExp  := IIf(Alltrim(cEspecie) == "NF",Alltrim(FWX3Titulo("F2_TIPONF")) + " (F2_TIPONF)",IIf(Alltrim(cEspecie) == "NDC",Alltrim(FWX3Titulo("F2_TIPREF")) + " (F2_TIPREF)",Alltrim(FWX3Titulo("F1_TIPREF")) + " (F1_TIPREF)"))
	lAnticip := A410UsaAdi( cCondicao )

	If lRet .And. nSalvaN > 0 .And. aCols[nSalvaN][Len(aHeader)+1] == .F. .And. !(Alltrim(aCfgNF[ScEspecie]) $ "NCC|NDC")
		lRet := VldNFOrig(aCfgNF[SnTipo],nSalvaN,aDadosIOri,nPosNFOri,nPosSerOri)
	EndIf

	If cAliasI $ "|SD2|SD1|"
		If cTipDoc == "A"
			nPos = Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_TES'})
			If nPos > 0
				For nX := 1 To Len(aDadosIOri)
					If !aDadosIOri[nX][Len(aDadosIOri[nX])]
						If cTes == ""
							cTes := aDadosIOri[nX][nPos]
							//Verificar se a tes gera duplicata e nao movimenta estoque
							DbSelectArea("SF4")
							DbSetOrder(1)
							If MsSeek(cFilSF4+cTes) .AND. (SF4->F4_ESTOQUE == "S" .OR. SF4->F4_DUPLIC == "N")
								If cAliasI == "SD1"
									Aviso(STR0021,STR0022,{STR0020}) //Atenção#"En la operacion de anticipo el TES utilizado debe afectar financiero y no movilizar stock."#OK
								Else
									Aviso(STR0021,STR0023,{STR0020}) //Atenção#"Na operação de adiantamento o TES utilizado deve gerar duplicata e não movimentar estoque."#OK
								EndIf
								lRet := .F.
								Exit
							EndIf
						ElseIf aDadosIOri[nX][nPos] <> cTes
							If cAliasI == "SD1"
								Aviso(STR0021,STR0024,{STR0020}) //Atenção#"En la operacion de anticipo los items de la Nota de Entrada deben poseer el mismo TES."#OK
							Else
								Aviso(STR0021,STR0033,{STR0020}) //Atenção#"Na operação de adiantamento os itens da Nota de Saída devem possuir o mesmo TES."#OK
							EndIf
							lRet := .F.
							Exit
						EndIf
					EndIf
				Next nX
			EndIf
		EndIf

		If cTipDoc == "N" .AND. nAdt > 0 .AND. !aDadosIOri[nLinha][Len(aDadosIOri[nLinha])] .AND. aDadosIOri[nLinha][nAdt] > aDadosIOri[nLinha][nTot] .and. lAnticip
			Aviso(STR0021,STR0025,{STR0020}) //Atenção#"O Valor de adiantamento relacionado não deve ser superior ao valor do item."#OK
			lRet := .F.
		EndIf

		If lRet .And. !Empty(cProvFE) .And. !aDadosIOri[nLinha][Len(aDadosIOri[nLinha])] .And. nPosTes > 0 .And. FindFunction("M486TIPIGV")
			If cFunname == "MATA467N" .And. Alltrim(cEspecie) == "NF" .And. SF2->(ColumnPos("F2_TIPONF")) > 0 .And. SF2->(ColumnPos("F2_SERIE2")) > 0 .and. cTipDoc == "N"
				cOpeExp   := IIf(cAliasI =="SD2",IIf(Substr(M->F2_SERIE2,1,1) $ 'B',"0200|0201|0203|0204|0206|0207|0208","0200|0201|0202|0203|0204|0205|0206|0207|0208"),"")
				If M->F2_TIPONF $ cOpeExp .And. M486TIPIGV(aDadosIOri[nLinha][nPosTes],'IGV') <> "40"
					cAvisoE   := StrTran(STR0026, '###',aDadosIOri[nLinha][nPosTes]) //"Para el Tipo de Entrada/Salida ###, el tipo de Afectación del IGV debe ser 40-Exportación de Bienes o Servicios ya que el campo #Exp es de exportación."
					MsgAlert(StrTran(cAvisoE, '#Exp',cCpoExp),STR0021) //"¡Atencion!"
					lRet := .F.
				ElseIf !(M->F2_TIPONF $ cOpeExp) .And. M486TIPIGV(aDadosIOri[nLinha][nPosTes],'IGV') == "40"
					cAvisoE   := StrTran(STR0027, '###',aDadosIOri[nLinha][nPosTes]) //"Para el Tipo de Entrada/Salida ###, el tipo de Afectación del IGV debe ser diferente de 40-Exportación de Bienes o Servicios ya que el campo #Exp es no es de exportación."
					MsgAlert(StrTran(cAvisoE, '#Exp',cCpoExp),STR0021)  //"¡Atencion!"
					lRet := .F.
				EndIf
			ElseIf cFunname == "MATA465N" .And. ((Alltrim(cEspecie) == "NDC" .And. SF2->(ColumnPos("F2_TIPREF")) > 0) .Or. (Alltrim(cEspecie) == "NCC" .And. SF1->(ColumnPos("F1_TIPREF")) > 0))
				cF2TipoNF := IIf(Alltrim(cEspecie) == "NDC", M->F2_TIPREF, M->F1_TIPREF)
				If cF2TipoNF $ "11" .And. M486TIPIGV(aDadosIOri[nLinha][nPosTes],'IGV') <> "40"
					cAvisoE   := StrTran(STR0026, '###',aDadosIOri[nLinha][nPosTes]) //"Para el Tipo de Entrada/Salida ###, el tipo de Afectación del IGV debe ser 40-Exportación de Bienes o Servicios ya que el campo #Exp es de exportación."
					MsgAlert(StrTran(cAvisoE, '#Exp',cCpoExp),STR0021) //"¡Atencion!"
					lRet := .F.
				ElseIf !(cF2TipoNF $ "11") .And. M486TIPIGV(aDadosIOri[nLinha][nPosTes],'IGV') == "40"
					cAvisoE   := StrTran(STR0027, '###',aDadosIOri[nLinha][nPosTes]) //"Para el Tipo de Entrada/Salida ###, el tipo de Afectación del IGV debe ser diferente de 40-Exportación de Bienes o Servicios ya que el campo #Exp es no es de exportación."
					MsgAlert(StrTran(cAvisoE, '#Exp',cCpoExp),STR0021) //"¡Atencion!"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	//Validacao notas fiscais
	If lRet.And. nLinha > 0
		aAux := {}
		For nI:=1 To Len(aDadosIOri)
			aAdd(aAux,{ aDadosIOri[nI][nPosCod], aDadosIOri[nI,nPosTes] , aDadosIOri[nI,Len(aDadosIOri[nI])] })
		Next nI
		If !Empty(aDadosIOri[nLinha,nPosTes])
			lRet := ValImpPer(nLinha,aAux,"PIV",cFunname)
			If lRet
				lRet := ValImpPer(nLinha,aAux,"DIG",cFunname)
			EndIf
		EndIf
	EndIf

	If lRet .And. nLinha > 0 .And.  cFunname == "MATA465N" .And. cEspecie $ "NDC|NCC" .And. lFormP .And. (aCols[nSalvaN][Len(aHeader)+1] == .F.) .And. (lFactElec) .And. Empty(aCols[nSalvaN][nPosRemito])
		lRet := LxVldDocIt(aCols[nSalvaN][nPosNFOri], aCols[nSalvaN][nPosSerOri], cEspecie)
	EndIf

Return lRet


/*/{Protheus.doc} LxDelNFPer
	Validaciones generales en el borrado de documento fiscal.
	La función es ejecutada en LOCXNF, función LocxDelNF.
	@type  Function
	@author Arturo Samaniego
	@since 03/09/2022
	@param 	cAlias: Alias de tabla (SF1 / SF2).
			lLocxAuto: Indica si es rutina automatica (.T.).
			cFunName: Nombre de rutina
	@return lRet: .T. Si cumple con las condiciones para anular/borrar el documento.
	/*/
Function LxDelNFPer(cAlias, lLocxAuto, cFunName)
Local cAliCampo := ""
Local lRet      := .T.

Default cAlias      := ""
Default lLocxAuto   := .F.
Default cFunName    := Funname()

	cAliCampo := Right(cAlias, 2)

	If (Empty(SuperGetMV("MV_SIGNAWS",.F.,""))) .And. cFunName $ "MATA467N|MATA465N|" .And. !lLocxAuto
		If IIf (cAlias $ "SF2|SF1" , !Empty((cAlias)->(ColumnPos(cAliCampo+"_FLFTEX"))) .Or. !( (cAlias)->&(cAliCampo+"_FLFTEX") $ "0|3|5|8" ), .F.)
			If (cAlias)->&(cAliCampo+"_FLFTEX") $ "1|4|6"
				MsgAlert( STR0028 + (cAlias)->&(cAliCampo+"_SERIE") + (cAlias)->&(cAliCampo+"_DOC") + STR0029 )//"El documento " ## " no puede ser borrado/anulado pues ya fue Transmitido. Utilice funcionalidad de comunicado de baja de la rutina Documentos Electrónicos."
				Return .F.
			ElseIf (cAlias)->&(cAliCampo+"_FLFTEX") $ "7"
				MsgAlert( STR0028 + (cAlias)->&(cAliCampo+"_SERIE") + (cAlias)->&(cAliCampo+"_DOC") + STR0030 )//"El documento " ## " se encuentra en proceso de baja. Utilice funcionalidad de comunicado de baja de la rutina Documentos Electrónicos."
				Return .F.
			EndIf
		EndIf
	EndIf

	If cAlias =="SF1"
		If AliasInDic("FR3") .AND. AliasInDic("FIE") .AND. A410UsaAdi(SF1->F1_COND)
			If !BaixaAdt()
				If IsBlind()
					Conout(STR0031)
				Else
					Aviso(STR0001,STR0031 + CRLF + STR0032,{STR0020}) //"Atenção"#"Não foi possível excluir a baixa do adiantamento associado ao Documento de Saída."#"Não será possível excluir o Documento de Saída."#OK
				EndIf
				DisarmTransaction()
				Return(.F.)
			Endif
		Endif
	EndIf
Return lRet

/*/{Protheus.doc} xVldCxaPer
	Genera asiento contable integración caja chica.
	La función es llamada de LOCXNF, función NFVldCxa.
	@type  Function
	@author Arturo Samaniego
	@since 03/09/2022
	@param 	lUsaFlag: Flag de contabilización (MV_CTBFLAG).
			nRecSEU: Número de registro de SEU a contabilizar.
			cUsuario: Código de Usuario
			cFunName: Nombre de función.
			lCtbOnLin: Indica si la contabilidad es on-line (.T.).
			lVisual572: Indica si visualiza los asientos contables.
	@return Nil
	/*/
Function xVldCxaPer(lUsaFlag, nRecSEU, cUsuario, cFunName, lCtbOnLin, lVisual572)
Local nTotal := 0
Local aTmpSEU       := {}
Local aDiario		:= {}
Local aFlagCTB		:= {}
Local cArquivo		:= ""
Local lPad572		:= VerPadrao("572")

Private nHdlPrv   	:= 0	//Guarda a evolucao da funcao HeadProva
Private cLote		:= ""  	//Lote utilizado nas rotinas contabeis

Default lUsaFlag   := SuperGetMV("MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Default nRecSEU    := 0
Default cUsuario   := ""
Default cFunName   := Funname()
Default lCtbOnLin  := .F.
Default lVisual572 := .T.

	If lPad572 .And. nRecSEU <> 0 .And. lCtbOnLin
		nTotal	:= 0
		aTmpSEU := SEU->(GetArea())
		SEU->(DBGoTo(nRecSEU))
		If UsaSeqCor()
			AADD(aDiario,{"SEU",nRecSEU,SEU->EU_DIACTB,"EU_NODIA","EU_DIACTB"})
		EndIf
		If nHdlPrv <= 0
			LoteCont("FIN")
			//Inicializa lanzamiento contable
			nHdlPrv := HeadProva( cLote, cFunName /*cPrograma*/, Substr( cUsuario, 7, 6 ), @cArquivo)
		EndIf
		If  nHdlPrv > 0 .And. Empty(SEU->EU_LA)
			//Prepara lanzamiento contable
				If lUsaFlag  //Almacenar en aFlagCTB para actualizar en el módulo de Contabilidad
					aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
				EndIf
				nTotal += DetProva( nHdlPrv			, "572" /*cPadrao*/	, cFunName /*cPrograma*/, cLote			,;
									/*nLinha*/		, /*lExecuta*/		, /*cCriterio*/			, /*lRateio*/	,;
									/*cChaveBusca*/	, /*aCT5*/			, /*lPosiciona*/		, @aFlagCTB		,;
									/*aTabRecOri*/	, /*aDadosProva*/ )
		EndIf

		If nHdlPrv > 0 .And. nTotal > 0
			//Realiza lanzamiento de Asto Contable
				RodaProva(nHdlPrv, nTotal)
				If cA100Incl( cArquivo						, nHdlPrv			, 3 /*nOpcx*/		, cLote		,;
							lVisual572 /*Visualiza*/	, .F. /*lAglut*/	, /*cOnLine*/		, /*dData*/	,;
							/*dReproc*/						, @aFlagCTB			, /*aDadosProva*/	, aDiario )
						If !lUsaflag
							Reclock("SEU",.F.)
							Replace EU_LA	With "S"
							MsUnLock()
						EndIf
						//Grava los lanzamientos de SIGAPCO
						PcoDetLan("000359","02",cFunName)
				EndIf
				// nHdlPrv := 0
				// nTotal	:= 0
				aFlagCTB:= {}  // Limpia contenido despues de realizar lanzamiento contable
		EndIf
		Restarea(aTmpSEU)
	EndIf

Return

/*/{Protheus.doc} LxDelCCPer
	Función para revertir los asientos contable de caja chica.
	La función es llamada en LOCXNF, función LocXDelCC.
	@type  Function
	@author Arturo Samaniego
	@since 03/09/2022
	@param 	lUsaFlag: Flag de contabilización (MV_CTBFLAG).
			lVisual579: Indica si visualiza los asientos contables (.T.).
			cFunName: Nombre de función
			cUsuario: Código de usuario.
	@return Nil
	/*/
Function LxDelCCPer(lUsaFlag, lVisual579, cFunName, cUsuario)
Local lPad579	:= VerPadrao("579")
Local aFlagCTB	:= {}
Local aCtbDia	:= {}
Local nTotal	:= 0
Local cArquivo	:= ""

Private nHdlPrv := 0
Private cLote	:= ""

Default lUsaFlag   := SuperGetMV("MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Default lVisual579 := .T.
Default cFunName   := Funname()
Default cUsuario   := ""

	If lPad579 .And. !Empty(SEU->EU_LA)
		If lUsaFlag
			aAdd(aFlagCTB, {"EU_LA", "S", "SEU", SEU->(Recno()), 0, 0, 0})
		EndIf
		If Empty(nHdlPrv) .Or. nHdlPrv <= 0
			LoteCont("FIN")
			nHdlPrv := HeadProva(cLote,cFunName,Subs(cUsuario,7,6),@cArquivo)
		EndIf
		If nHdlPrv > 0
			nTotal	+=	DetProva(nHdlPrv,"579",cFunName,cLote)
		EndIf
		RodaProva(nHdlPrv,nTotal)
		If nTotal > 0
			If UsaSeqCor()
				aCtbDia := {{"SEU",SEU->(Recno()),SEU->EU_DIACTB,"EU_NODIA","EU_DIACTB"}}
			EndIf
			If cA100Incl(	cArquivo						, nHdlPrv			, 3				, cLote		,;
							lVisual579 /*Visualiza*/	, .F./*Aglutina*/	,/*cOnLine*/	, /*dData*/	,;
							/*dReproc*/						, @aFlagCTB			,/*aDadosProva*/, aCtbDia)
					If !lUsaflag
						Reclock("SEU",.F.)
						SEU->EU_LA := "S"
						MsUnLock()
					EndIf
			EndIf
		EndIf
		nHdlPrv := 0
		nTotal := 0
		aFlagCTB := {}
	EndIf

Return

/*/{Protheus.doc} VencImpPer
	Función para obtener fecha de vencimiento de título de impuesto.
	La función es llamada en LOCXNF, función LocVencImp.
	@type  Function
	@author Arturo Samaniego
	@since 04/09/2022
	@param 	dDatabase: Fecha base del sistema
			aTitPai: Array con información de títulos.
	@return dVencto: Fecha de vencimiento.
	/*/
Function VencImpPer(dDatabase, aTitPai)
Local dVencto := CTOD("//")

	If dDatabase == aTitPai[1][9]
		dVencto := aTitPai[1][9]
	ElseIf dDatabase < aTitPai[1][9]
		If (Month(dDatabase) == Month(aTitPai[1][9]))
			dVencto := aTitPai[1][9]-1
		Else
			If (aTitPai[1][9] > RetDiaUtil(Str(Month(dDatabase)),Str(Year(dDatabase))))
				dVencto := RetDiaUtil(Str(Month(dDatabase)),Str(Year(dDatabase)))
			Else
				dVencto := aTitPai[1][9]-1
			EndIf
		EndIF
	EndIf

Return dVencto


/*/{Protheus.doc} LxVdImpPer
	Función para validación de impuesto - Perú.
	La función es llamada en LOCXNF2, función ValImpPer.
	@type  Function
	@author Arturo Samaniego
	@since 04/09/2022
	@param 	nLinha: Número de linea de ítems.
			aItens: Array de ítems
			clImp: Código de impuesto
			cFunName: Nombre de función.
	@return lRet. .T. si cumple con las condiciones.
	/*/
Function LxVdImpPer(nLinha, aItens, clImp, cFunName)
Local nlI     := 0
Local nlAliq  := 0
Local alAreaX := {}
Local lRet    := .T.
Local cFilSB1	:= xFilial("SB1")
Local cFilSFB	:= xFilial("SFB")
Local cFilSFC	:= xFilial("SFC")
Local cFilSYD	:= xFilial("SYD")

Default nLinha := 0
Default aItens := {}
Default clImp  := ""
Default cFunName := Funname()

	If cFunName $ "MATA465N/MATA466N/MATA467N/MATA101N"

		alAreaX := GetArea()

		If !aItens[nLinha,3]

			dbSelectArea("SFC")
			dbSetOrder(2)
			If SFC->(MsSeek(cFilSFC+aItens[nLinha,2]+clImp))

				dbSelectArea("SB1")
				dbSetOrder(1)
				SB1->(MsSeek(cFilSB1+aItens[nLinha,1]))

				If !Empty(SB1->B1_POSIPI)
					dbSelectArea("SYD")
					dbSetOrder(1)
					If SYD->(MsSeek(cFilSYD+SB1->B1_POSIPI))
						If clImp == "DIG"
							nlAliq := SYD->YD_ALQDIG
						Else
							nlAliq := SYD->YD_ALQPIV
						EndIf
					EndIf
				ElseIf !Empty(SB1->B1_ALQPIGV) .And. !Empty(SB1->B1_ALQPDIG)
					If clImp == "DIG"
						nlAliq := SB1->B1_ALQPDIG
					Else
						nlAliq := SB1->B1_ALQPIGV
					EndIf
				Else
					If SFB->(MsSeek(cFilSFB+clImp))
						nlAliq := SFB->FB_ALIQ
					EndIf
				EndIf

				SB1->(dbCloseArea())
				SYD->(dbCloseArea())

				For nlI := 1 To Len(aItens)
					If nlI <> nLinha .And. !aItens[nlI,3]
						SFC->(dbGoTop())
						If SFC->(MsSeek(cFilSFC+aItens[nlI,2]+clImp))

							dbSelectArea("SB1")
							dbSetOrder(1)
							SB1->(MsSeek(cFilSB1+aItens[nlI,1]))

							If !Empty(SB1->B1_POSIPI)
								dbSelectArea("SYD")
								dbSetOrder(1)
								If SYD->(MsSeek(cFilSYD+SB1->B1_POSIPI))
									If clImp == "DIG"
										If nlAliq <> SYD->YD_ALQDIG
											lRet := .F.
											Exit
										EndIf
									Else
										If nlAliq <> SYD->YD_ALQPIV
											lRet := .F.
											Exit
										EndIf
									EndIf
								EndIf
							ElseIf !Empty(SB1->B1_ALQPIGV) .And. !Empty(SB1->B1_ALQPDIG)
								If clImp == "DIG"
									If nlAliq <> SB1->B1_ALQPDIG
										lRet := .F.
										Exit
									EndIf
								Else
									If nlAliq <> SB1->B1_ALQPIGV
										lRet := .F.
										Exit
									EndIf
								EndIf
							Else
								If SFB->(MsSeek(cFilSFB+clImp))
									If nlAliq <> SFB->FB_ALIQ
										lRet := .F.
										Exit
									EndIf
								EndIf
							EndIf

							SB1->(dbCloseArea())
							SYD->(dbCloseArea())

						Else
							If !Empty(aItens[nlI,2])
								lRet := .F.
								Exit
							EndiF
						EndIf
					EndIf
				Next nlI

			Else

				For nlI := 1 To Len(aItens)
					If nlI <> nLinha .And. !aItens[nlI,3]
						SFC->(dbGoTop())
						If SFC->(msSeek(cFilSFC+aItens[nlI,2]+clImp))
							lRet := .F.
							Exit
						EndIf
					EndIf
				Next nlI

			EndIf

			If !lRet
				If clImp == "DIG"
			   		Aviso(STR0019,STR0034,{STR0020})
				Else
					Aviso(STR0019,STR0035,{STR0020})
				EndIf
			EndIf

			SFC->(dbCloseArea())

		EndIf

   		RestArea(alAreaX)
   	EndIf

Return lRet

/*/{Protheus.doc} LxdUtilPer
	Obtiene el 5° día util del mes.
	La función es llamada en LOCXNF2, función RetDiaUtil.
	@type  Function
	@author Arturo Samaniego
	@since 04/09/2022
	@param 	cMes: Número de mes.
			cAno: Número de año.
	@return dRetData: Fecha de referencia.
	/*/
Function LxdUtilPer(cMes, cAno)
Local nDia      := 1
Local nUtil     := 0
Local dRetData  := CTOD("//")
Local aFeriados := {}
Local dData     := CTOD("//")

	If Alltrim(cMes) == "12"
		cMes := "1"
		cAno := Str(Val(cAno)+1)
	Else
		cMes :=	Str(Val(cMes)+1)
	EndIF

	aFeriados := RetFeriados()

	While nUtil < 5
		dData:=CTOD((Str(nDia))+"/"+cMes+"/"+cAno)
		If ( dData == DataValida(dData)  .And. Ascan(aFeriados,Dtos(dData)) == 0    )
			dRetData := CTOD((Str(nDia))+"/"+cMes+"/"+cAno)
			nUtil++
		EndIf
		nDia++
	EndDo

Return dRetData


/*/{Protheus.doc} xNfOrigPer
	Función para validar si existe documento origen.
	La función es llamada en LOCXNF2, función VldNFOrig.
	@type  Function
	@author Arturo Samaniego
	@since 04/09/2022
	@param 	cTipo: Tipo de documento
			nI: Número de ítem.
			aDadosI: Array con ítems.
			nPosNFOri: Posición del campo NfOrig.
			nPosSerOri: Posición del campo SerOrig.
	@return lRet: .T. si cumple con las condiciones.
	/*/
Function xNfOrigPer(cTipo,nI,aDadosI,nPosNFOri,nPosSerOri)
Local nZ	:= 0
Local lRet	:= .T.

Default cTipo      := ""
Default nI         := 0
Default aDadosI    := {}
Default nPosNFOri  := 0
Default nPosSerOri := 0

	If !Empty(aDadosI[nI][nPosNFOri]) .And. Strzero(cTipo,2)$"02|03|04|05|06|07|08|09"
		For nZ:=1 To Len(aDadosI)
			If !aDadosI[nZ][Len(aDadosI[nZ])]
				If !Empty(aDadosI[nZ][nPosNFOri]) .And. !aDadosI[nZ][nPosNFOri]+aDadosI[nZ][nPosSerOri] == aDadosI[nI][nPosNFOri]+aDadosI[nI][nPosSerOri]
					Aviso(STR0019,STR0036+" ("+aDadosI[nZ][nPosNFOri]+" "+aDadosI[nZ][nPosSerOri]+")",{STR0020})
					lRet := .F.
				EndIf
			EndIf
		Next
	EndIf

Return lRet


/*/{Protheus.doc} VdDocItPer
	Valida documento informado en D2_NFORI/D1_NFORI con serie en D2_SERIORI/D1_SERIORI para NDC/NCC.
	La función es llamada en LOCXNF2, función LxVldDocIt.
	@type  Function
	@author Arturo Samaniego
	@since 04/09/2022
	@param 	cNumeroDoc: Número de documento.
			cSerie: Serie del documento.
			cEspecie: Especie del documento.
			lM485PE: Valor del Punto de Entrada M465DORIFE. Default .T.
	@return lRet: .T. si cumple con las validaciones.
	/*/
Function VdDocItPer(cNumeroDoc, cSerie, cEspecie, lM485PE)
Local lRet	   := .T.
Local aArea	   := {}
Local cCpoSerO := ""
Local cCpoDocO := ""
Local cCliForE := ""
Local cLojaE   := ""

Default cNumeroDoc	:= ""
Default cSerie		:= ""
Default cEspecie	:= ""
Default lM485PE     := .T. 

	cCpoSerO := IIf(cEspecie=="NDC","D2_SERIORI","D1_SERIORI")
	cCpoDocO := IIf(cEspecie=="NDC","D2_NFORI","D1_NFORI")
	cCliForE := IIf(cEspecie=="NDC",M->F2_CLIENTE,M->F1_FORNECE)
	cLojaE   := IIf(cEspecie=="NDC",M->F2_LOJA,M->F1_LOJA)

	aArea := GetArea()

	If lM485PE
		If !Empty(cNumeroDoc) .And. !Empty(cSerie)
			dbSelectArea("SF2")
			SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			If !(SF2->(MsSeek(xFilial("SF2") + cNumeroDoc + cSerie + cCliForE + cLojaE)))
				MsgAlert(STR0037 + AllTrim(cSerie) + "-" + AllTrim(cNumeroDoc) + StrTran(STR0038, '###', AllTrim(cCliForE) + "-" + AllTrim(cLojaE))) //"El documento original informado en el detalle (" //"), no existe para el cliente ###. Informe otro e intente nuevamente."
				lRet := .F.
			EndIf
		Else
			MsgAlert(STR0039 + RTrim(FWX3Titulo(cCpoDocO)) + "(" + cCpoDocO + ") " + STR0040 + RTrim(FWX3Titulo(cCpoSerO)) + "(" + cCpoDocO + ") " + STR0041) //"Los campos " - " y " - ", deben ser informados en el detalle."
			lRet := .F.
		EndIf
	EndIf
	
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} xUpdImpPer
	Actualiza valor de campos de SE2, para títulos de impuestos.
	La función es llamada en LOCXNF, función GeraTitImp.
	@type  Function
	@author Arturo Samaniego
	@since 04/09/2022
	@param 	nRecSE2: Número de registro de SE2.
			aRet: Array con valores de SE2.
			cCpoLvro: Campo de libro fiscal de impuesto.
			cParcela: Número de parcela.
	@return Nil
	/*/
Function xUpdImpPer(nRecSE2, aRet, cCpoLvro, cParcela)
Local nX := 0

Default nRecSE2  := 0
Default aRet     := {}
Default cCpoLvro := ""
Default cParcela := ""

	For nX :=1 to Len(aRet[1])
		SE2->(MsGoto(aRet[1][nX]))
		RecLock("SE2",.F.)
			Replace &("E2_PARIMP"+cCpoLvro) with cParcela
		MsUnlock()
	Next
	SE2->(MsGoto(nRecSE2))

Return
