// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 13     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "OFIOA510.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOA510 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 23/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Controle de valor de Garantia por periodo (VPH/VPI)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA510()
Local lExistVPH  := .f. // Verifica a existencia da tabela VPH
Local lExistVPI  := .f. // Verifica a existencia da tabela VPI
Private cCadastro:= OemToAnsi(STR0001)
Private aRotina  := MenuDef()
Private cTitulo  := cCadastro
DbSelectArea("SX2")
If DbSeek("VPH")
	lExistVPH := .t.
EndIf
If DbSeek("VPI")
	lExistVPI := .t.
EndIf
If lExistVPH .and. lExistVPI // Verifica a existencia das tabelas VPH/VPI
	DbSelectArea("VPH")
	DbSetOrder(2) // Data Inicial
	mBrowse( 6, 1,22 ,75,"VPH")
Else
	MsgAlert(STR0019,STR0009)
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OF510    ³ Autor ³ Andre Luis Almeida    ³ Data ³ 23/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta tela                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OF510(cAlias, nReg, nOpc,cTexto)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local bCampo   := { |nCPO| Field(nCPO) }
Local nOpca := 0
Local oDlg1 ,cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk , nCntFor := 0 , _ni := 0 , nUsado := 0
Local nPosRec := 0
Private aCpoEnchoice  :={}
Private aTELA[0][0],aGETS[0], nLenaCols:=0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VPH",.t.)
aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VPH")
While !Eof().and.(x3_arquivo=="VPH")
	If X3USO(x3_usado).and.cNivel>=x3_nivel.And.!(Alltrim(x3_campo) $ [VPH_CODIGO])
		AADD(aCpoEnchoice,x3_campo)
	Endif
	&("M->"+x3_campo) := CriaVar(x3_campo)
	dbSkip()
End
&("M->"+x3_campo) := CriaVar("VPH_CODIGO")
If !(Inclui)
	DbSelectArea("VPH")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de acesso para a Modelo 3                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case nOpc == 3 && Incluir
		nOpcE:=3
		nOpcG:=2
		Inclui:=.t.
		Altera:=.f.
	Case nOpc == 4 && Alterar
		nOpcE :=4
		nOpcG :=2
		Altera:= .t.
		Inclui:= .f.
	Case nOpc == 2 && Visualizar
		nOpcE:=2
		nOpcG:=2
	Otherwise      && Excluir
		nOpcE:=5
		nOpcG:=5
EndCase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSeek("VPI")
aHeader:={}
While !Eof().And.(x3_arquivo=="VPI")
	If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(Alltrim(x3_campo) $ [VPI_CODIGO])
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		&("M->"+x3_campo) := CriaVar(x3_campo)
	Endif
	dbSkip()
End
// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VPI")
ADHeadRec("VPI",aHeader)
// Posicao do registro
nPosRec:=Len(aHeader)
nUsado :=Len(aHeader)
dbSelectArea("VPI")
dbSetOrder(1)
dbSeek(xFilial("VPI")+M->VPH_CODIGO)
If nOpc == 3 .Or. !(Found())
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VPI"
		Else
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		EndIf
	Next
Else
	aCols:={}
	While !Eof() .And. VPI->VPI_FILIAL == xFilial("VPI") .And. M->VPH_CODIGO == VPI_CODIGO
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := VPI->(RecNo())
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VPI"
			Else
				aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
			EndIf
		Next
		aCols[Len(aCols),nUsado+1]:=.F.
		dbSkip()
	End
	nLenaCols:=Len(aCols)
Endif
If Len(aCols)>0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo       :=STR0001
	If cTexto<>Nil .and. ValType(cTexto) == "C"
		cTitulo := cTexto
	Endif
	cAliasEnchoice:="VPH"
	cAliasGetD    :="VPI"
	cLinOk        :="FG_OBRIGAT()"
	cTudOk        :=""
	cFieldOk      :="FG_MEMVAR()"
	If Inclui
		DbSelectArea("VPH")
		DbSetOrder(2) // Data Inicial
		DbGoBottom()
		If !Eof()
			M->VPH_DATINI := VPH->VPH_DATFIN+1
		Else
			M->VPH_DATINI := ctod("01/"+strzero(month(dDatabase),2)+"/"+strzero(year(dDatabase),4))
		EndIf
		M->VPH_DATFIN := ctod("01/"+strzero(IIF(month(M->VPH_DATINI)+1>12,1,month(M->VPH_DATINI)+1),2)+"/"+strzero(year(M->VPH_DATINI)+IIF(month(M->VPH_DATINI)+1>12,1,0),4))-1
	EndIf
	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 5 , 70 , .T. , .F. } )  //Cabecalho
	AAdd( aObjects, { 1 , 10 , .T. , .T. } )  //list box superior
	
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects,.F.)
	
	DEFINE MSDIALOG oDlg1 TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL
	
	EnChoice(cAliasEnchoice,nReg,nOpc,,,,aCpoEnchoice,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.F.)
	
	oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,cLinOk,cTudOk,"",If(nOpc > 2 .and. nOpc < 5,.t.,.f.),,,,,cFieldOk)
	oGetDados:oBrowse:bChange := {|| FG_AALTER("VPI",nLenaCols,oGetDados)}
	ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| if(FS_OA510GRA(nOpc),oDlg1:End(), .f. ) },{|| oDlg1:End() })
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_OA510GRA³ Autor ³ Andre Luis Almeida    ³ Data ³ 23/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao³ Inclui/Altera/Exclui (VPH)                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OA510GRA(nOpc)
Local lRet := .t.
Local ni := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar processamento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc # 2
	If Inclui .or. Altera // Grava VPH
		For ni:=1 to Len(aCpoEnchoice) // Verifica campos obrigatorios
			If X3Obrigat(aCpoEnchoice[ni]) .and. Empty(&("M->"+aCpoEnchoice[ni]))
				Help(" ",1,"OBRIGAT",,RetTitle(aCpoEnchoice[ni])+space(50),3,0 )
				Return .f.
			EndIf
		Next
	EndIf
	lMsHelpAuto  := .t.
	lMsFinalAuto := .f.
	Begin Transaction
	DbSelectArea("VPH")
	DbSetOrder(1) // Codigo
	DbSeek(xFilial("VPH")+M->VPH_CODIGO)
	If Inclui .or. Altera // Grava VPH
		If !RecLock("VPH", !Found() )
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DbSelectArea("VPH")
			DbSetOrder(2) // Data Inicial
			DisarmTransaction()
			Break
			Return .f.
		EndIf
		If Inclui
			M->VPH_CODIGO := GetSXENum("VPH","VPH_CODIGO")
			ConfirmSX8()
		EndIf
		FG_GRAVAR("VPH")
		MsUnlock()
		If Inclui
			DbSelectArea("VPH")
			DbSetOrder(2) // Data Inicial
			DbGoBottom()
			M->VPH_DATINI := VPH->VPH_DATFIN+1
			M->VPH_DATFIN := ctod("01/"+strzero(IIF(month(M->VPH_DATINI)+1>12,1,month(M->VPH_DATINI)+1),2)+"/"+strzero(year(M->VPH_DATINI)+IIF(month(M->VPH_DATINI)+1>12,1,0),4))-1
		EndIf
	ElseIf !(Inclui .or. Altera) .And. Found() // Exclui VPH
		DbSelectArea("VPI")
		DbSetOrder(1)
		If !DbSeek(xFilial("VPI")+VPH->VPH_CODIGO) // Verifica a Existencia do filho (VPI)
			&& Deleta
			DbSelectArea("VPH")
			If !RecLock("VPH",.F.,.T.)
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DbSelectArea("VPH")
				DbSetOrder(2) // Data Inicial
				DisarmTransaction()
				Break
			EndIf
			dbdelete()
			MsUnlock()
			WriteSx2("VPH")
		Else
			MsgAlert(STR0008,STR0009) //"Impossivel EXCLUIR, ja houve registro de garantia no periodo." "Atencao"
		EndIf
	EndIf
	DbSelectArea("VPH")
	DbSetOrder(2) // Data Inicial
	End Transaction
EndIf
DbSelectArea("VPH")
If !lRet
	MostraErro()
EndIf
lMsHelpAuto := .f.
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OF510SIM ³ Autor ³ Andre Luis Almeida    ³ Data ³ 25/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ SIMULACAO com todas as OS em aberto                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OF510SIM(cAlias, nReg, nOpc,cTexto)
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cAliasEnchoice := "VPH"
Local oDlg1
Local ni := 0
Private nVlrACUMUL := 0
Private nPerACUMUL := 0
Private nTotAbe    := 0
Private nTotPec    := 0
Private nTotSrv    := 0
Private aCpoEnchoice := {}
Private lMarcar    := .f.
Private nOpcao     := 1
Private aNewBot    := {}
Private aOS        := {}
Private oOk        := LoadBitmap( GetResources(), "LBTIK" )
Private oNo        := LoadBitmap( GetResources(), "LBNO" )
DbSelectArea("VPH")
DbSetOrder(2) // Data Inicial
DbSeek(xFilial("VPH")+dtos(dDataBase),.t.)
If RecCount() > 0
	If VPH->VPH_DATINI # dDataBase .and. ( !Bof() .or. Eof() )
		VPH->(DbSkip(-1))
	EndIf
EndIf

aNewBot := {{"BMPTRG"   ,{|| FS_SIMULAR() },(UPPER(STR0007))} ,; // SIMULAR
			{"IMPRESSAO",{|| FS_IMPRIMIR() },(STR0028) }} // Imprimir

If VPH->VPH_DATFIN >= dDataBase
	nVlrACUMUL := VPH->VPH_VALACU
	nPerACUMUL := VPH->VPH_PERACU
	FS_LEVANTAOS()
	DbSelectArea("VPH")
	Aadd(aCpoEnchoice,"VPH_DATINI") // Colocar Campos FIXOS para colocar a caixa (VALOR e % ACUMULADO) em cima do campo
	Aadd(aCpoEnchoice,"VPH_DATFIN") // Colocar Campos FIXOS para colocar a caixa (VALOR e % ACUMULADO) em cima do campo
	Aadd(aCpoEnchoice,"VPH_VALGAR") // Colocar Campos FIXOS para colocar a caixa (VALOR e % ACUMULADO) em cima do campo
	Aadd(aCpoEnchoice,"VPH_PERAVI") // Colocar Campos FIXOS para colocar a caixa (VALOR e % ACUMULADO) em cima do campo
	Aadd(aCpoEnchoice,"VPH_VALACU") // Colocar Campos FIXOS para colocar a caixa (VALOR e % ACUMULADO) em cima do campo
	Aadd(aCpoEnchoice,"VPH_PERACU") // Colocar Campos FIXOS para colocar a caixa (VALOR e % ACUMULADO) em cima do campo
	For ni := 1 to len(aCpoEnchoice)
		&("M->"+aCpoEnchoice[ni]) := CriaVar(aCpoEnchoice[ni])
	Next

	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 1 , 70 , .T. , .F. } ) // Enchoice
	AAdd( aObjects, { 1 , 10 , .T. , .F. } ) // MsGet
	AAdd( aObjects, { 1 , 50 , .T. , .T. } ) // ListBox
	
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects,.F.)
	
	DEFINE MSDIALOG oDlg1 TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

	EnChoice(cAliasEnchoice,nReg,2,,,,aCpoEnchoice,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.F.)

	@ aPosObj[2,1],005 SAY VPH->(RetTitle("VPH_VALACU")) SIZE 60,8 OF oDlg1 PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1],040 MSGET oVALACUP VAR nVlrACUMUL PICTURE "@E 99,999,999,999.99" SIZE 90,08 OF oDlg1 PIXEL COLOR CLR_BLACK WHEN .f.
	@ aPosObj[2,1],040 MSGET oVALACUV VAR nVlrACUMUL PICTURE "@E 99,999,999,999.99" SIZE 90,08 OF oDlg1 PIXEL COLOR CLR_HRED WHEN .f.
	@ aPosObj[2,1],160 SAY VPH->(RetTitle("VPH_PERACU")) SIZE 60,8 OF oDlg1 PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1],195 MSGET oPERACUP VAR nPerACUMUL PICTURE "@E 99999.99" SIZE 55,08 OF oDlg1 PIXEL COLOR CLR_BLACK WHEN .f.
	@ aPosObj[2,1],195 MSGET oPERACUV VAR nPerACUMUL PICTURE "@E 99999.99" SIZE 55,08 OF oDlg1 PIXEL COLOR CLR_HRED WHEN .f.
	oVALACUP:lVisible := .f.
	oPERACUP:lVisible := .f.
	oVALACUV:lVisible := .f.
	oPERACUV:lVisible := .f.
	// ( ( ( Vlr Acumulado / Vlr Garantia ) * 100 ) >= % minimo para aviso ) //
	If ( ( ( nVlrACUMUL / VPH->VPH_VALGAR ) * 100 ) >= VPH->VPH_PERAVI )
		oVALACUV:lVisible := .t.
		oPERACUV:lVisible := .t.
	Else
		oVALACUP:lVisible := .t.
		oPERACUP:lVisible := .t.
	EndIf
	//ListBox
	@ aPosObj[3,1],aPosObj[3,2] LISTBOX oLbx FIELDS HEADER OemToAnsi(" "),OemToAnsi(Alltrim(RetTitle("VO1_NUMOSV"))+" / "+Alltrim(RetTitle("VOO_TIPTEM"))),RetTitle("VPI_CHASSI"),RetTitle("VPI_VALPEC"),RetTitle("VPI_VALSRV"),RetTitle("VPI_VALTOT") COLSIZES 10,60,85,48,48,48 SIZE aPosObj[3,4]-2,aPosObj[3,3]-aPosObj[3,1] OF oDlg1 PIXEL ON DBLCLICK (aOS[oLbx:nAt,1]:=!aOS[oLbx:nAt,1],FS_TOTAL(oLbx:nAt))
	oLbx:SetArray(aOS)
	oLbx:bLine := { || {If(aOS[oLbx:nAt,1],oOk,oNo),aOS[oLbx:nAt,2],aOS[oLbx:nAt,3],FG_AlinVlrs(Transform(aOS[oLbx:nAt,4],"@E 99,999,999,999.99")),FG_AlinVlrs(Transform(aOS[oLbx:nAt,5],"@E 99,999,999,999.99")),FG_AlinVlrs(Transform(aOS[oLbx:nAt,6],"@E 99,999,999,999.99"))}}
	@ aPosObj[3,1],aPosObj[3,2]+1 CHECKBOX oTK VAR lMarcar PROMPT "" OF oDlg1 ON CLICK FS_TIK( lMarcar ) SIZE 08,08 PIXEL COLOR CLR_BLUE
	
	ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{ || oDlg1:End() }, { || oDlg1:End() },,aNewBot)
Else
	MsgStop(STR0017+CHR(13)+CHR(10)+CHR(13)+CHR(10)+Transform(dDataBase,"@D"),STR0009) // Impossivel SIMULAR, nao ha periodo cadastro para a data atual. // Atencao
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_LEVANTAOS³ Autor ³ Andre Luis Almeida   ³ Data ³ 23/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Levanta OS's e Valores em aberto para simular               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVANTAOS()
Local nPos := 0
Local aOSAux  := {}
Local aCodSer := {}
Local cTTpExc := GetNewPar("MV_EXCTTPG","") // Nao utilizar TIPOS DE TEMPO de EXCESSAO
aOS := {}
// Levantamento de VALORES (PECAS) //
DbSelectArea("VO3")
DbSetOrder(3) // Nro NF + Serie
DbGoTop()
Do While !Eof() .and. Empty(VO3->VO3_NUMNFI)
	If !Empty(VO3->VO3_NUMOSV) .and. Empty(VO3->VO3_DATFEC) .and. Empty(VO3->VO3_DATCAN) .and. !( VO3->VO3_TIPTEM $ cTTpExc ) // NAO CANCELADO e NAO FECHADO
		DbSelectArea("VOI")
		DbSetOrder(1) // Tipo de Tempo
		DbSeek(xFilial("VOI")+VO3->VO3_TIPTEM)
		If VOI->VOI_SITTPO == "2" // 2-Garantia
			nPos := aScan(aOS,{|x| x[2] == VO3->VO3_NUMOSV+" - "+VO3->VO3_TIPTEM })
			If nPos <= 0
				DbSelectArea("VO1")
				DbSetOrder(1) // Nro OS
				DbSeek(xFilial("VO1")+VO3->VO3_NUMOSV)
				Aadd(aOS,{ .f. , VO3->VO3_NUMOSV+" - "+VO3->VO3_TIPTEM , VO1->VO1_CHASSI , 0 , 0 , 0 } )
				nPos := len(aOS)
			EndIf
			DbSelectArea("SBM")
			DbSetOrder(1)
			DbSeek(xFilial("SBM")+VO3->VO3_GRUITE)
			DbSelectArea("VE4")
			DbSetOrder(1)
			DbSeek(xFilial("VE4")+SBM->BM_CODMAR)
			DbSelectArea("VO2")
			DbSetOrder(2) // NOSNUM
			DbSeek(xFilial("VO2")+VO3->VO3_NOSNUM)
			If VO2->VO2_DEVOLU == "1" // 1-Requisicao
				//				If VE4->VE4_PECGAR == "1"
				If VOI->VOI_VLPCAC == "2"
					aOS[nPos,4] += ( VO3->VO3_QTDREQ * FG_VALPEC(VO3->VO3_TIPTEM,"VO3->VO3_FORMUL",VO3->VO3_GRUITE,VO3->VO3_CODITE,,.f.,.t.) )
					aOS[nPos,6] += ( VO3->VO3_QTDREQ * FG_VALPEC(VO3->VO3_TIPTEM,"VO3->VO3_FORMUL",VO3->VO3_GRUITE,VO3->VO3_CODITE,,.f.,.t.) )
				Else
					aOS[nPos,4] += ( VO3->VO3_QTDREQ * VO3->VO3_VALPEC )
					aOS[nPos,6] += ( VO3->VO3_QTDREQ * VO3->VO3_VALPEC )
				EndIf
			Else // 0-Devolucao
				//				If VE4->VE4_PECGAR == "1"
				If VOI->VOI_VLPCAC == "2"
					aOS[nPos,4] -=	( VO3->VO3_QTDREQ * FG_VALPEC(VO3->VO3_TIPTEM,"VO3->VO3_FORMUL",VO3->VO3_GRUITE,VO3->VO3_CODITE,,.f.,.t.) )
					aOS[nPos,6] -=	( VO3->VO3_QTDREQ * FG_VALPEC(VO3->VO3_TIPTEM,"VO3->VO3_FORMUL",VO3->VO3_GRUITE,VO3->VO3_CODITE,,.f.,.t.) )
				Else
					aOS[nPos,4] -=	( VO3->VO3_QTDREQ * VO3->VO3_VALPEC )
					aOS[nPos,6] -=	( VO3->VO3_QTDREQ * VO3->VO3_VALPEC )
				EndIf
			EndIf
		EndIf
	EndIf
	DbSelectArea("VO3")
	DbSkip()
EndDo
// Levantamento de VALORES (SERVICOS) //
cTTpExc += GetNewPar("MV_EXCTTPR","") // Nao considerar TIPOS DE TEMPO quando for de RECALL (somente para servicos)
DbSelectArea("VO4")
DbSetOrder(7) // Nro NF + Serie
DbGoTop()
Do While !Eof() .and. Empty(VO4->VO4_NUMNFI)
	If !Empty(VO4->VO4_NUMOSV) .and. Empty(VO4->VO4_DATFEC) .and. Empty(VO4->VO4_DATCAN) .and. !( VO4->VO4_TIPTEM $ cTTpExc ) // NAO CANCELADO, NAO FECHADO
		DbSelectArea("VOI")
		DbSetOrder(1) // Tipo de Tempo
		DbSeek(xFilial("VOI")+VO4->VO4_TIPTEM)
		If VOI->VOI_SITTPO == "2" // 2-Garantia
			DbSelectArea("VO1")
			DbSetOrder(1) // Nro OS
			DbSeek(xFilial("VO1")+VO4->VO4_NUMOSV)
			DbSelectArea("VOK")
			DbSetOrder(1)
			DbSeek( xFilial("VOK") + VO4->VO4_TIPSER )
			DbSelectArea("VO6")
			DbSetOrder(2)
			DbSeek(xFilial("VO6")+FG_MARSRV(VO1->VO1_CODMAR, VO4->VO4_CODSER)+VO4->VO4_CODSER)
			nPos := aScan(aOS,{|x| x[2] == VO4->VO4_NUMOSV+" - "+VO4->VO4_TIPTEM })
			If nPos <= 0
				Aadd(aOS,{ .f. , VO4->VO4_NUMOSV+" - "+VO4->VO4_TIPTEM , VO1->VO1_CHASSI , 0 , 0 , 0 } )
				nPos := len(aOS)
			EndIf
			aCodSer := FG_CALVLSER( aCodSer , VO4->VO4_TIPTEM + VO4->VO4_TIPSER + VO6->VO6_CODSER , "A" )
			aOS[nPos,5] += aCodSer[1] // Valor Srv
			aOS[nPos,6] += aCodSer[1] // Valor Srv
		EndIf
	EndIf
	DbSelectArea("VO4")
	DbSkip()
EndDo
aOSAux := aClone(aOS)
aOS := {}
For nPos := 1 to len(aOSAux)
	If aOSAux[nPos,6] > 0 // Somente OS's com valores maiores que 0
		Aadd(aOS,{ aOSAux[nPos,1] , aOSAux[nPos,2] , aOSAux[nPos,3] , aOSAux[nPos,4] , aOSAux[nPos,5] , aOSAux[nPos,6] } )
	EndIf
Next
If len(aOS) <= 0
	Aadd(aOS,{ .f. , " " , " " , 0 , 0 , 0 } )
Else
	Asort(aOS,,,{|x,y| x[2] < y[2]})
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³   FS_TIK   ³ Autor ³ Andre Luis Almeida   ³ Data ³ 23/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ TIK TOTAL (marcar/desmarcar)                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK( lMarcar )
Local ni := 0
Default lMarcar := .f.
nVlrACUMUL := VPH->VPH_VALACU
nPerACUMUL := VPH->VPH_PERACU
For ni := 1 to Len(aOS)
	If lMarcar
		aOS[ni,1] := .t.
		FS_TOTAL(ni)
	Else
		aOS[ni,1] := .f.
	EndIf
Next
oVALACUP:lVisible := .f.
oPERACUP:lVisible := .f.
oVALACUV:lVisible := .f.
oPERACUV:lVisible := .f.
// ( ( ( Vlr Acumulado / Vlr Garantia ) * 100 ) >= % minimo para aviso ) //
If ( ( ( nVlrACUMUL / VPH->VPH_VALGAR ) * 100 ) >= VPH->VPH_PERAVI )
	oVALACUV:lVisible := .t.
	oPERACUV:lVisible := .t.
Else
	oVALACUP:lVisible := .t.
	oPERACUP:lVisible := .t.
EndIf
oVALACUV:Refresh()
oPERACUV:Refresh()
oVALACUP:Refresh()
oPERACUP:Refresh()
oLbx:SetFocus()
oLbx:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³  FS_TOTAL  ³ Autor ³ Andre Luis Almeida   ³ Data ³ 23/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Totalizar o VALOR e % ACUMULADO                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TOTAL(nPos)
oVALACUP:lVisible := .f.
oPERACUP:lVisible := .f.
oVALACUV:lVisible := .f.
oPERACUV:lVisible := .f.
If aOS[nPos,1]
	nVlrACUMUL += aOS[nPos,6]
	nTotPec    += aOS[nPos,4]
	nTotSrv    += aOS[nPos,5]
Else
	nVlrACUMUL -= aOS[nPos,6]
	nTotPec    -= aOS[nPos,4]
	nTotSrv    -= aOS[nPos,5]
EndIf
nTotAbe := ( nTotPec + nTotSrv )
nPerACUMUL := ( ( nVlrACUMUL / VPH->VPH_VALGAR ) * 100 )
// ( ( ( Vlr Acumulado / Vlr Garantia ) * 100 ) >= % minimo para aviso ) //
If ( ( ( nVlrACUMUL / VPH->VPH_VALGAR ) * 100 ) >= VPH->VPH_PERAVI )
	oVALACUV:lVisible := .t.
	oPERACUV:lVisible := .t.
Else
	oVALACUP:lVisible := .t.
	oPERACUP:lVisible := .t.
EndIf
oVALACUV:Refresh()
oPERACUV:Refresh()
oVALACUP:Refresh()
oPERACUP:Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_SIMULAR ³ Autor ³ Andre Luis Almeida   ³ Data ³ 03/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Simulacao LIMITE MAXIMO                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SIMULAR()
Local ni := 0
Local nTotal := 0
nVlrACUMUL := VPH->VPH_VALACU
nPerACUMUL := VPH->VPH_PERACU
nTotPec := 0
nTotSrv := 0
nTotAbe := 0
DEFINE MSDIALOG oSimul FROM 000,000 TO 07,30 TITLE (UPPER(STR0007)+" - "+STR0020) OF oMainWnd  //SIMULACAO - Limite Maximo
@ 005,005 RADIO oRadio1 VAR nOpcao 3D SIZE 109,10 PROMPT OemToAnsi(STR0021),OemToAnsi(STR0022),OemToAnsi(STR0023) OF oSimul PIXEL //"Ordem cronologica de OS"/"Ordem Valores crescente da OS"/"Ordem Valores decrescente da OS"
DEFINE SBUTTON FROM 038,049 TYPE 1 ACTION oSimul:End() ENABLE OF oSimul
ACTIVATE MSDIALOG oSimul CENTER
If nOpcao == 1 // Ordem cronologica da OS
	Asort(aOS,,,{|x,y| x[2] < y[2]})
ElseIf nOpcao == 2 // Ordem Valores da OS crescente
	Asort(aOS,,,{|x,y| x[6] < y[6]})
ElseIf nOpcao == 3 // Ordem Valores da OS decrescente
	Asort(aOS,,,{|x,y| x[6] > y[6]})
EndIf
lMarcar := .t.
For ni := 1 to len(aOS)
	aOS[ni,1] := .f.
	If VPH->VPH_VALGAR >= ( VPH->VPH_VALACU + nTotal + aOS[ni,6] )
		nTotal  += aOS[ni,6]
		aOS[ni,1] := .t.
		FS_TOTAL(ni)
	Else
		lMarcar := .f.
	EndIf
Next
oTK:Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_IMPRIMIR³ Autor ³ Rafael G. Silva       ³ Data ³ 03/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Impressao da Simulacao (SELECIONADOS)                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRIMIR()

Local cDesc1	:= ""
Local cDesc2	:= ""
Local cDesc3	:= ""
Local cAlias	:= ""
Local ni		:= 0
Local nTotPecImp:= 0
Local nTotSrvImp:= 0
Local nTotalAcu := 0
Private nLin    := 1
Private aReturn := { "" , 1 , "" , 1 , 2 , 1 , "" , 1 }
Private cTamanho:= "M"           // P/M/G
Private Limite  := 132           // 80/132/220
Private aOrdem  := {}            // Ordem do Relatorio
Private cTitulo := UPPER(STR0007) +" - "+ STR0001 //Controle de valor de Garantia por periodo/chassi
Private cNomProg:= "OFIOA510"
Private cNomeRel:= "OFIOA510"
Private nLastKey:= 0
Private cabec1  := ""
Private cabec2  := ""
Private nCaracter:=15
Private m_Pag   := 1
cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
	Return
EndIf
SetDefault(aReturn,cAlias)
Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer
For ni:=1 to len(aOS)
	If aOS[ni,1]
		nTotPecImp += aOS[ni,4]
		nTotSrvImp += aOS[ni,5]
	EndIf
Next
cabec1 := left(STR0010+" "+transform(VPH->VPH_DATINI,"@D") +" "+STR0024+" "+ transform(VPH->VPH_DATFIN,"@D")+space(40),40)+Right(space(14)+Alltrim(RetTitle("VPH_VALGAR")),14)+Right(Space(14)+Alltrim(RetTitle("VPI_VALPEC")),14) + Right(space(14)+Alltrim(RetTitle("VPI_VALSRV")),14)+Right(space(14)+Alltrim(RetTitle("VPI_VALTOT")),14)+Right(space(14)+STR0025,14)+Right(space(14)+Alltrim(RetTitle("VPH_VALACU")),14)+" "+STR0026  //Periodo  ### ate ###Ja Fechado ### %Garan.
cabec2 := left(Alltrim(RetTitle("VO1_NUMOSV"))+" / "+Alltrim(RetTitle("VOO_TIPTEM"))+space(20),20) + Left(Alltrim(RetTitle("VPI_CHASSI"))+space(20),20)+ Transform(VPH->VPH_VALGAR,"@E 999,999,999.99") + Transform(nTotPecImp,"@E 999,999,999.99")+ Transform(nTotSrvImp,"@E 999,999,999.99")+ Transform(nTotAbe,"@E 999,999,999.99")+ Transform(VPH->VPH_VALACU,"@E 999,999,999.99") + Transform(nVlrAcumul,"@E 999,999,999.99") +" "+ Transform(nPerAcumul,"@E 999.99%")
nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
For ni:=1 to len(aOS)
	If aOS[ni,1]
		If nLin >= 60
			nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
		EndIf
		nTotalAcu += aOS[ni,6]
		@ nLin++ , 00 psay left(aOS[ni,2]+space(20),20) + Left(aOS[ni,3]+space(34),34) + Transform(aOS[ni,4],"@E 999,999,999.99") + Transform(aOS[ni,5],"@E 999,999,999.99") + Transform(aOS[ni,6],"@E 999,999,999.99") +space(14) + Transform(nTotalAcu,"@E 999,999,999.99") +" "+ Transform((nTotalAcu/VPH->VPH_VALGAR)*100,"@E 999.99%")
	endif
Next
nTotalAcu += VPH->VPH_VALACU
nLin++
@ nLin++ , 00 psay left(STR0027+space(82),82) + Transform(VPH->VPH_VALACU,"@E 999,999,999.99") +space(14) + Transform(nTotalAcu,"@E 999,999,999.99") +" "+ Transform((nTotalAcu/VPH->VPH_VALGAR)*100,"@E 999.99%") //Ordens de Servicos de GARANTIA ja fechadas no periodo.
Ms_Flush()
Set Printer to
Set Device  to Screen
If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OFIOA510VAL³ Autor ³ Andre Luis Almeida   ³ Data ³ 25/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para validar DATAS (INICIAL/FINAL)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OFICINA ( Fechamento / Cancelamento )                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA510VAL(_nTip)
Local lRet := .t.
If _nTip == 1 .or. _nTip == 2 // Datas
	DbSelectArea("VPH")
	DbSetOrder(2) // Data Inicial
	DbSeek(xFilial("VPH")+dtos(M->VPH_DATINI),.t.)
	If _nTip == 1 // Data Inicial
		If RecCount() > 0
			If VPH->VPH_DATINI # M->VPH_DATINI .and. ( !Bof() .or. Eof() )
				VPH->(DbSkip(-1))
			EndIf
		EndIf
		If VPH->VPH_DATINI <= M->VPH_DATINI .and. M->VPH_DATINI <= VPH->VPH_DATFIN
			MsgStop(STR0018,STR0009) // "Data digitada invalida! Existe o periodo cadastro." / "Atencao"
			lRet := .f.
		EndIf
		M->VPH_DATFIN := ctod("")
	ElseIf _nTip == 2 // Data Final
		If M->VPH_DATFIN >= M->VPH_DATINI
			If !Eof()
				If M->VPH_DATFIN >= VPH->VPH_DATINI
					MsgStop(STR0018,STR0009) // "Data digitada invalida! Existe o periodo cadastro." / "Atencao"
					lRet := .f.
				EndIf
			EndIf
		Else
			lRet := .f.
		EndIf
	EndIf
ElseIf _nTip == 3 // Valor da Garantia
	If M->VPH_VALGAR <= 0
		lRet := .f.
	Else
		M->VPH_PERACU := ( ( M->VPH_VALACU / M->VPH_VALGAR ) * 100 )
	EndIf
ElseIf _nTip == 4 // Percentual minimo para aviso por e-mail
	If	M->VPH_PERAVI <= 0 .or. M->VPH_PERAVI > 100
		lRet := .f.
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OFIOA510GRV³ Autor ³ Andre Luis Almeida   ³ Data ³ 25/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para gravar o VPI/VPH Garantia por periodo/chassi   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OFICINA ( Fechamento / Cancelamento )                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA510GRV(_nTip,_cNumOSV,_cTipTem)
Local lExistVPH  := .f. // Verifica a existencia da tabela VPH
Local lExistVPI  := .f. // Verifica a existencia da tabela VPI
Local nVlrPec    := 0
Local nVlrSrv    := 0
Local aArea      := {}
Local lOk        := .t.
Local lSendOK    := .f.
Local cError     := ""
Local cEMAIL     := "" // E-mail destinatario
Local cMensagem  := "" // E-mail (MENSAGEM)
Local cMailConta := GETMV("MV_EMCONTA") // Usuario/e-mail de envio
Local cMailServer:= GETMV("MV_RELSERV") // Server de envio
Local cMailSenha := GETMV("MV_EMSENHA") // Senha e-mail de envio
Local lAutentica := GetMv("MV_RELAUTH",,.F.)          // Determina se o Servidor de E-mail necessita de Autenticacao
Local cUserAut   := Alltrim(GetMv("MV_RELAUSR",," ")) // Usuario para Autenticacao no Servidor de E-mail
Local cPassAut   := Alltrim(GetMv("MV_RELAPSW",," ")) // Senha para Autenticacao no Servidor de E-mail
Local aSM0     := {}
aArea := sGetArea(aArea,Alias()) // SALVA ALIAS()
aArea := sGetArea(aArea,"VOI")
aArea := sGetArea(aArea,"VO1")
aArea := sGetArea(aArea,"VOO")
aArea := sGetArea(aArea,"SF2")
If !( _cTipTem $ GetNewPar("MV_EXCTTPG","") ) // Nao atualizar arquivos quando TIPOS DE TEMPO for de EXCESSAO (PECAS e SERVICOS)
	DbSelectArea("SX2")
	If DbSeek("VPH")
		lExistVPH := .t.
	EndIf
	If DbSeek("VPI")
		lExistVPI := .t.
	EndIf
	If lExistVPH .and. lExistVPI // Verifica a existencia das tabelas VPH/VPI
		DbSelectArea("VOI")
		DbSetOrder(1) // Tipo de Tempo
		DbSeek(xFilial("VOI")+_cTipTem)
		If VOI->VOI_SITTPO == "2" // 2-Garantia
			DbSelectArea("VPH")
			DbSetOrder(2) // Data Inicial
			DbSeek(xFilial("VPH")+dtos(dDataBase),.t.)
			If RecCount() > 0
				If VPH->VPH_DATINI # dDataBase .and. ( !Bof() .or. Eof() )
					VPH->(DbSkip(-1))
				EndIf
			EndIf
			If VPH->VPH_DATFIN >= dDataBase
				DbSelectArea("VO1")
				DbSetOrder(1) // Nro OS
				DbSeek(xFilial("VO1")+_cNumOSV)
				DbSelectArea("VOO")
				DbSetOrder(1) // Nro OS + Tipo de Tempo
				DbSeek(xFilial("VOO")+_cNumOSV+_cTipTem)
				If _nTip == 2 // Subtrair ( Cancelamento )
					lOk := .f.
					Set Delete Off // Utiliza todos os registros ( VALIDOS e DELETADOS )
					DbSelectArea("SF2")
					DbSetOrder(1) // NF + Serie
					DbSeek( xFilial("SF2") + VOO->VOO_NUMNFI + VOO->VOO_SERNFI )
					If VPH->VPH_DATINI <= SF2->F2_EMISSAO .and. VPH->VPH_DATFIN >= SF2->F2_EMISSAO
						lOk := .t.
					EndIf
					Set Delete On // Utiliza apenas os registros VALIDOS (nao utiliza os registros DELETADOS)
				EndIf
				If lOk
					nVlrPec += VOO->VOO_TOTPEC // Total de Pecas
					If !( _cTipTem $ GetNewPar("MV_EXCTTPR","") ) // Nao considerar TIPOS DE TEMPO for de RECALL (somente para servicos)
						nVlrSrv += VOO->VOO_TOTSRV   // Total de Servicos
					EndIf
					DbSelectArea("VPI")
					DbSetOrder(1) // Codigo + Chassi
					DbSeek(xFilial("VPI")+VPH->VPH_CODIGO+VO1->VO1_CHASSI)
					RecLock("VPI",!Found())
					VPI->VPI_FILIAL := xFilial("VPI")
					VPI->VPI_CODIGO := VPH->VPH_CODIGO
					VPI->VPI_CHASSI := VO1->VO1_CHASSI
					If _nTip == 1 // Somar ( Fechamento )
						VPI->VPI_VALPEC += nVlrPec
						VPI->VPI_VALSRV += nVlrSrv
						VPI->VPI_VALTOT += ( nVlrPec + nVlrSrv )
					ElseIf _nTip == 2 // Subtrair ( Cancelamento )
						If Found() // Retirar somente se tiver registro
							VPI->VPI_VALPEC -= nVlrPec
							VPI->VPI_VALSRV -= nVlrSrv
							VPI->VPI_VALTOT -= ( nVlrPec + nVlrSrv )
						EndIf
					EndIf
					MsUnLock()
					If VPI->VPI_VALTOT == 0 // Quando zerar valores apagar registro do VPI (filho)
						DbSelectArea("VPI")
						RecLock("VPI",.f.,.t.)
						dbDelete()
						MsUnLock()
					EndIf
					DbSelectArea("VPH")
					RecLock("VPH",.f.)
					If _nTip == 1 // Somar ( Fechamento )
						VPH->VPH_VALACU += ( nVlrPec + nVlrSrv )
					ElseIf _nTip == 2 // Subtrair ( Cancelamento )
						VPH->VPH_VALACU -= ( nVlrPec + nVlrSrv )
					EndIf
					if  ( ( VPH->VPH_VALACU / VPH->VPH_VALGAR ) * 100 ) > 999
						VPH->VPH_PERACU := 999
					Else
						VPH->VPH_PERACU := ( ( VPH->VPH_VALACU / VPH->VPH_VALGAR ) * 100 )
					Endif
					MsUnLock()
					If _nTip == 1 // Enviar E-mail somente quando Somar ( Fechamento )
						// ( ( ( Vlr Acumulado / Vlr Garantia ) * 100 ) >= % minimo para aviso ) //
						If ( ( ( VPH->VPH_VALACU / VPH->VPH_VALGAR ) * 100 ) >= VPH->VPH_PERAVI )
							// Cria E-mail //
							
							cEMAIL     := GetNewPar("MV_EMGARAN",cMailConta) // E-mail destinatario
							aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
							cBkpFil := SM0->(Recno())     
						    dbSelectArea("SM0")
						    dbSetOrder(1)
						    dbSeek(aSM0[1]+aSM0[2])
							If !Empty(cMailConta) .and. !Empty(cMailServer) .and. !Empty(cMailSenha) .and. !Empty(cEMAIL)
								cTitulo := STR0001
								cMensagem += "<center><table border=0 width=80%><tr>"
								If !Empty( GetNewPar("MV_ENDLOGO","") )
									cMensagem += "<td width=20%><img src="+GetNewPar("MV_ENDLOGO","")+"></td>"
								EndIf
								cMensagem += "<td align=center width=80%>"
								cMensagem += "<font size=3 face='verdana,arial' Color=#0000cc><b>"+aSM0[7]+"<br></font></b>"
								cMensagem += "<font size=1 face='verdana,arial' Color=black>"+SM0->M0_ENDENT+"<br>"+SM0->M0_CIDENT+" - "+SM0->M0_ESTENT+"<br>"+STR0016+" "+SM0->M0_TEL+"</font>" // Fone:
								cMensagem += "</td></tr></table><hr width=80%>"
								cMensagem += "<font size=3 face='verdana,arial' Color=black><b>"+cTitulo+"<br></font></b><hr width=80%><br>"
								cMensagem += "<table border=0 width=80%><tr>"
								cMensagem += "<td><font size=3 face='verdana,arial' Color=black>"+STR0010+"</font></td>" //Periodo:
								cMensagem += "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+Transform(VPH->VPH_DATINI,"@D")+" "+STR0011+" "+Transform(VPH->VPH_DATFIN,"@D")+"</b></font></td></tr>"
								cMensagem += "<tr><td><font size=3 face='verdana,arial' Color=black>"+STR0012+"</font></td>" //Valor Garantia:
								cMensagem += "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+Transform(VPH->VPH_VALGAR,"@E 99,999,999,999.99")+"</b></font></td></tr>"
								cMensagem += "<tr><td><font size=3 face='verdana,arial' Color=black>"+STR0013+"</font></td>" //Valor Acumulado:
								cMensagem += "<td><font size=3 face='verdana,arial' Color=red><b>"+Transform(VPH->VPH_VALACU,"@E 99,999,999,999.99")+" ( "+Transform(VPH->VPH_PERACU,"@E 999.99%")+" )</b></font></td></tr>"
								cMensagem += "</table><br><hr width=80%>"
								cMensagem += "</center>"
								SM0->(DbGoto(cBkpFil))
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Envia e-mail - Conecta uma vez com o servidor de e-mails                ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								lOk := .f.
								CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk
								If lOk
									lOk := .f.
									If lAutentica
										If !MailAuth(cUserAut,cPassAut)
											MsgStop(OemToAnsi(STR0014),OemToAnsi(STR0009)) // Erro no envio de e-Mail / Atencao
											DISCONNECT SMTP SERVER
										Else
											lOk := .t.
										EndIf
									Else
										lOk := .t.
									EndIf
									If lOk
										// Envia e-mail com os dados necessarios
										SEND MAIL FROM cMailConta to Alltrim(cEMAIL) SUBJECT (cTitulo) BODY cMensagem FORMAT TEXT RESULT lSendOk
										If !lSendOk
											//Erro no Envio do e-mail
											GET MAIL ERROR cError
											MsgStop(cError,OemToAnsi(STR0014)) // Erro no envio de e-Mail
										EndIf
										// Desconecta com o servidor de e-mails
										DISCONNECT SMTP SERVER
									EndIf
								Else
									MsgStop(OemToAnsi(STR0015+" "+chr(13)+chr(10)+cMailServer),OemToAnsi(STR0009)) // Nao foi possivel conectar no servidor de email # Atencao
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
sRestArea(aArea) // VOLTA ALIAS()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  MenuDef  ³ Autor ³ Andre Luis Almeida   ³ Data ³ 25/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta aRotina (opcoes)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := { { STR0002 ,"axPesqui", 0 , 1},;   //Pesquisar
{ STR0003 ,"OF510", 0 , 2},;    //Visualizar
{ STR0004 ,"OF510", 0 , 3},;    //Incluir
{ STR0005 ,"OF510", 0 , 4},;    //Alterar
{ STR0006 ,"OF510", 0 , 5},;    //Excluir
{ STR0007 ,"OF510SIM", 0 , 1}}  //Simulacao
Return aRotina