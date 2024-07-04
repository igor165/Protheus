#include "Protheus.ch"
#include "TMSAI25.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAI25  ³ Autor ³ Richard Anderson      ³ Data ³ 22.11.06   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Percentual de Frete por Pais                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSAI25()

Private cCadastro	:= STR0001 //-- Percentual de Frete por País
Private aRotina		:= {{ STR0002  , "AxPesqui" , 0, 1 },; //"Pesquisar"
				          { STR0003  , "TMAI25Mnt" , 0, 2 },; //"Visualizar"
 				          { STR0004  , "TMAI25Mnt" , 0, 3 },; //"Incluir"
				          { STR0005  , "TMAI25Mnt" , 0, 4 },; //"Alterar"
				          { STR0006  , "TMAI25Mnt" , 0, 5 }}  //"Excluir"

dbSelectArea("DI4")
dbSetOrder(1)
dbGoTop()

mBrowse(06,01,22,75,"DI4")

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI25Mnt ³ Autor ³ Richard Anderson     ³ Data ³22.11.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Interface do Cadastro de Percentual de Frete por Pais       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Alias da tabela                                      ³±±
±±³          ³ ExpN2: Numero do Registro                                   ³±±
±±³          ³ ExpN3: Opcao do aRotina                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAI25Mnt(cAlias, nReg, nOpcx)

Local nUsado    := 0
Local nOpcA     := 0
Local aAreaDI4  := DI4->(GetArea())

Local aGet      := {}
Local aPosObj   := {} 
Local aObjects  := {}
Local aRecno    := {}
Local aSize     := MsAdvSize( .F. )             
Local nCntFor   := 0
Local aNoFields := {}
Local oDlg
Local aFldDI4	:= {}
Local nI		:= 0
Local nPosDI4	:= 0

Private aHeader := {}
Private aCols   := {} 
Private cRota   := IIf(!Inclui,DI4->DI4_ROTA  ,CriaVar("DI4_ROTA"))
Private cDesRot := CriaVar("DI4_DESROT")
Private oDesRot := {}
Private cIncote := IIf(!Inclui,DI4->DI4_INCOTE,CriaVar("DI4_INCOTE"))
Private oGetD   := {}

Aadd(aNoFields,"DI4_ROTA"  )
Aadd(aNoFields,"DI4_DESROT")
Aadd(aNoFields,"DI4_INCOTE")

aFldDI4 := ApBuildHeader("DI4")

If (nPosDI4 := aScan(aFldDI4, {|x| AllTrim(x[2]) == "DI4_ROTA"})) > 0
	aAdd(aGet, {aFldDI4[nPosDI4][1], aFldDI4[nPosDI4][3], aFldDI4[nPosDI4][9]})
EndIf

If (nPosDI4 := aScan(aFldDI4, {|x| AllTrim(x[2]) == "DI4_INCOTE"})) > 0
	aAdd(aGet, {aFldDI4[nPosDI4][1], aFldDI4[nPosDI4][3], aFldDI4[nPosDI4][9]})
EndIf

aFldDI4 := ApBuildHeader("DI4", aNoFields)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Array aHeader.                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len(aFldDI4)
	nUsado += 1
	Aadd(aHeader, aFldDI4[nI])
Next

aSize(aFldDI4, 0)
aFldDI4 := Nil
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Array aCols.                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Inclui
	DI4->(dbSetOrder(1))
	DI4->(dbSeek(xFilial("DI4")+cRota+cIncote))
	While DI4->(!Eof()) .And. DI4->(DI4_FILIAL+DI4_ROTA+DI4_INCOTE) == xFilial("DI4")+cRota+cIncote
		Aadd(aCols,Array(nUsado+1))
		For nCntFor := 1 To nUsado
			If ( aHeader[nCntFor][10] != "V" )
				aCols[Len(aCols)][nCntFor] := DI4->(FieldGet(FieldPos(aHeader[nCntFor][2])))
			Else
				aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
			EndIf
		Next
		aCols[Len(aCols)][nUsado+1] := .F.
		DI4->(dbSkip())
	Enddo
Else
	If Empty(aCols)
		Aadd(aCols,Array(nUsado+1))

		For nCntFor := 1 To nUsado
			aCols[1][nCntFor] := CriaVar(aHeader[nCntFor][2])
		Next nCntFor

		aCols[Len(aCols)][nUsado+1] := .F.
	EndIf
EndIf

If	Empty(GDFieldGet('DI4_ITEM',1))
	GDFieldPut('DI4_ITEM',StrZero(1,Len(DI4->DI4_ITEM)),1)
EndIf
		
AAdd( aObjects, { 100, 61, .T., .F. } )
AAdd( aObjects, { 100, 60, .T., .T. } )
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 } 
aPosObj := MsObjSize( aInfo, aObjects ) 
	
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 to aSize[6],aSize[5] Of oMainWnd PIXEL

	@ 35,005 SAY   aGet[1][1] SIZE 50,7 OF oDlg PIXEL	
	@ 35,040 MSGET cRota      PICTURE aGet[1][2] F3 "DA8"  VALID TMAI25Vld() WHEN Inclui SIZE 0,7 OF oDlg PIXEL	
	@ 35,085 MSGET oDesRot    VAR cDesRot PICTURE "@!"     WHEN .F. SIZE 120,7 OF oDlg PIXEL	
	@ 49,005 SAY   aGet[2][1] SIZE 50,7 OF oDlg PIXEL	
	@ 49,040 MSGET cIncote    PICTURE aGet[2][2] F3 "MP"   VALID TMAI25Vld() WHEN Inclui SIZE 0,7 OF oDlg PIXEL	
		
	oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"TMAI25LOk()","TMAI25TOk()","+DI4_ITEM",.T.,,,,1)
	oGetD:oBrowse:bDelete := { || .F. }     // Nao Permite a deletar Linhas
			
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, If(oGetd:TudoOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()})			

If nOpcA == 1 .And. nOpcx <> 2
	Begin Transaction
		TMAI25Grv(nOpcx)
	End Transaction
EndIf	

RestArea(aAreaDI4)
	
Return NIL

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI25LOk ³ Autor ³ Richard Anderson     ³ Data ³22.11.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de digitacao de linha                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAI25LOk()
Local lRet := .T.
//-- Nao avalia linhas deletadas.
If	!GDDeleted( n )
   If lRet := MaCheckCols(aHeader,aCols,n)
	   //-- Analisa se ha itens duplicados na GetDados.
	   lRet := GDCheckKey( { 'DI4_PAIS' }, 4 )
	EndIf   
EndIf
Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI25TOk ³ Autor ³ Richard Anderson     ³ Data ³22.11.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de confirmacao para gravacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAI25TOk()

Local lRet   := .T.
Local nPPerc := GDFieldPos('DI4_PERFRE')
Local nTPerc := 0

//-- Analisa se os campos obrigatorios da GetDados foram informados.
If	lRet
	lRet := oGetD:ChkObrigat( n )
EndIf
//-- Analisa o linha ok.
If lRet
	lRet := TMAI25LOk()
EndIf

//-- Analisa se todas os itens da GetDados estao deletados.
If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
	Help( ' ', 1, 'OBRIGAT2') //Um ou alguns campos obrigatorios nao foram preenchidos no Browse.
	lRet := .F.
EndIf

If lRet
	Aeval(aCols,{ | e | nTPerc += e[nPPerc] })
	If nTPerc <> 100
		MsgAlert(STR0007)
		lRet := .F.
	EndIf
	If lRet .And. Inclui
		lRet := ExistChav("DI4",cRota+cIncote)
	EndIf	
EndIf	
		
Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI25Vld ³ Autor ³ Richard Anderson     ³ Data ³19.03.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de digitacao de campos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ EAL                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAI25Vld(cCampo)

Local   lRet    := .T.
Local   aRegDCA := {}
Local   nCnt    := 0
Local   nCols   := 0
Default cCampo  := AllTrim(Upper(ReadVar()))

If "CROTA" $ cCampo
	lRet := ExistCpo("DA8",cRota,1) 
	If lRet
		cDesRot := Posicione("DA8",1,xFilial("DA8")+cRota,"DA8_DESC")
		oDesRot:Refresh()
		aRegDCA := TmsRegDCA( cRota )
		If Ascan(aRegDCA,{ | e | !Empty(e[5]) }) == 0
			MsgAlert(STR0008)
			lRet  := .F.
		Else
			aCols := {}
			For nCnt := 1 To Len(aRegDCA)
				If !Empty(aRegDCA[nCnt,5]) .And. Ascan(aCols,{ | e | e[GDFieldPos('DI4_PAIS')] == aRegDCA[nCnt,5] }) == 0
					nCols += 1
					//-- Inclui nova linha no aCols
					TMSA210Cols()
					GDFieldPut('DI4_ITEM'  ,StrZero(nCols,Len(DI4->DI4_ITEM)),nCols)
					GDFieldPut('DI4_PAIS'  ,aRegDCA[nCnt,5],nCols)
					GDFieldPut('DI4_DEPAIS',Posicione('SYA',1,xFilial('SYA')+aRegDCA[nCnt,5],'YA_DESCR'),nCols)
				EndIf
			Next nCnt
			oGetD:nMax := nCols
			oGetD:oBrowse:Refresh()
		EndIf
	EndIf
ElseIf "DI4_PERFRE" $ cCampo
	lRet := (Positivo() .And. M->DI4_PERFRE <= 100)
EndIf
			
Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI25Grv ³ Autor ³ Richard Anderson     ³ Data ³22.11.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Gravacao                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAI25Grv(nOpcx)

Local nI     := 0
Local nCnt   := 0
Local nUsado := Len(aHeader)

DI4->(dbSetOrder(1))

If nOpcx == 3 .Or. nOpcx == 4
	For nCnt := 1 To Len(aCols)
		If !GdDeleted(nCnt)
			If DI4->(!MsSeek(xFilial("DI4")+cRota+cIncote+GdFieldGet("DI4_ITEM",nCnt)))
				RecLock("DI4",.T.)
				DI4->DI4_FILIAL := xFilial("DI4")
				DI4->DI4_ROTA   := cRota
				DI4->DI4_INCOTE := cIncote
				DI4->DI4_ITEM   := GdFieldGet("DI4_ITEM",nCnt)
			Else
				RecLock("DI4",.F.)
			EndIf
			For nI := 1 To nUsado
				If aHeader[nI,10] != 'V'
					DI4->(FieldPut(FieldPos(aHeader[nI,2]),GDFieldGet(aHeader[nI,2],nCnt)))
				EndIf
			Next
			MsUnlock()
		EndIf
	Next nCnt
ElseIf nOpcx == 5
	For nCnt := 1 To Len(aCols)
		If DI4->(MsSeek(xFilial("DI4")+cRota+cIncote+GdFieldGet("DI4_ITEM",nCnt)))
			RecLock("DI4",.F.)
			dbDelete()
			MsUnLock()
		EndIf
	Next nCnt					
EndIf	
Return
