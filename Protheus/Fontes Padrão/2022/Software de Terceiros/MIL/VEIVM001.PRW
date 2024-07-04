// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 0     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "VEIVM001.ch"
#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVM001 ³ Autor ³  Manoel               ³ Data ³ 06/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pedidos a Fabrica                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM001

PRIVATE aRotina   := MenuDef()
PRIVATE cChaInt, cChassi, cCodTes, nCusVei, nVBaIcm, nAliIcm, nTotIcm
PRIVATE lChaTemp  := .f.
PRIVATE cBIcm0    := FlagQtVei := .t.
PRIVATE cEstFor, cLojFor, nOpcMnu
PRIVATE cCadastro   := OemToAnsi(STR0001) //"Cancel - <Ctrl-X>"
PRIVATE cFiltrVVFS := "VVF_TESFRE#VVF_VALMOV#VVF_FORPRO#VVF_OPEMOV#VVF_DATFAB#VVF_DATEMI#VVF_DESACE#VVF_ICMRET#VVF_DTHEMI#VVF_CODBCO#VVF_CODAGE#VVF_CODCOM#VVF_TOTSEG#VVF_TOTFRE#VVF_TOTICM#VVF_VBAICM#VVF_ALIICM#VVF_ICMRET#VVF_VBAIPI#VVF_ALIIPI#VVF_VALIPI#VVF_CONFRE#VVF_NUMPED#VVF_NUMTRA#VVF_TRACPA#VVF_SERNFI#VVF_NUMNFI#VVF_FORPAG#VVF_DESFPG"
PRIVATE cFiltrVVG  := "VVG_CODIND#VVG_TOTFRE#VVG_DESACE##VVG_TOTSEG#VVG_CENCUS#VVG_CONTA #VVG_VALUNI#VVG_VCNVEI#VVG_CODTES#VVG_VALDES#VVG_VBAICM#VVG_ALIICM#VVG_ICMCOM#VVG_VBAIPI#VVG_ALIIPI#VVG_VALIPI#VVG_REDCUS#VVG_ASSIMP#VVG_VALASS#VVG_VALREV#VVG_SEGVIA#VVG_VALFRE#VVG_ESTVEI#VVG_OBSERV#VVG_CONFRE"
PRIVATE cOpeMov := Subs(OemToAnsi(STR0002),1,1) //"1" Pedidos a Fabrica //"Ok - <Ctrl-O>"
PRIVATE lMsHelpAuto  := .t.
PRIVATE lMsFinalAuto := .f.
PRIVATE lMsErroAuto  := .f.     
Private lA1_IBGE := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
Private lA2_IBGE := If(SA2->(FieldPos("A2_IBGE"))>0,.t.,.f.)
aCampoVV1 := {}
M->VVF_QTDVEI := 1

Inclui := .t.

if len(aRotina) == 0
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("VVF")
cIndex := CriaTrab(nil,.f.)
cKey   := IndexKey()
cCondicao :='VVF->VVF_OPEMOV == "1"'
IndRegua("VVF",cIndex,"VVF_FILIAL+(DtoS(VVF_DATMOV))",,cCondicao,OemToAnsi(STR0006))  // "Selecionando Registros..." //"1=Pedidos Fabrica"

mBrowse( 6, 1,22,75,"VVF")
dbSelectArea("VVF")
Set Filter to
RetIndex("VVF")
DbsetOrder(1)
#IFNDEF TOP
	If File(cIndex+OrdBagExt())
		fErase(cIndex+OrdBagExt())
	Endif
#ENDIF


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AFUNC01  ³ Autor ³  Manoel               ³ Data ³ 25/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela de Entrada de Veiculos (Pedidos a Fabrica)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFUNC01(cAlias,nReg,nOpc)

Local nRecno:= Recno()
Local nOrdem:= IndexOrd()
Local nControl	:= 0, nOk:=0
Local aPages:= {}, aVar:={}
Local oDlgFolder, ni
Local oFont
Local cPrimeiro:=""
Local bCampo		:= { |nCPO| Field(nCPO) }
Local aTitles  := {OemToAnsi(STR0049),OemToAnsi(STR0050)}
Local nCntFor,_ni := 0

nRegVVF := VVF->(recno())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbselectarea("VVF")
if nOpc == 3
	Retindex()
Endif
dbSelectArea("SX3")
dbSeek("VVF")
acpoEncS  := {}
While !Eof().and.(x3_arquivo=="VVF")
	if X3USO(x3_usado).and.cNivel>=x3_nivel .and. !alltrim(x3_Campo) $ cFiltrVVFS
		AADD(acpoEncS,x3_campo)
	Endif
	if INCLUI
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo


if !Inclui
	RegToMemory("VVF",.f.)
	DbSelectArea("VVF")
	DbGoto(nRegVVF)

	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSeek("VVG")
aHeader:={}
While !Eof().And.(x3_arquivo=="VVG")
	if X3USO(x3_usado).And.cNivel>=x3_nivel .and. !alltrim(x3_Campo) $ cFiltrVVG
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
		wVar := "M->"+x3_campo
		&wVar := CriaVar(x3_campo)
	Endif
	dbSkip()
End

dbSelectArea("SX3")
dbSeek("VV1")

While !EOF() .And. (X3_ARQUIVO == "VV1")
	IF X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
		If !x3_campo $ "VV1_CHASSI#VV1_CODORI#VV1_ESTVEI#VV1_PROATU#VV1_NOMPRO#VV1_PROANT#VV1_NOMPAN#VV1_LJPANT#VV1_LJPATU"
			AADD(aCampoVV1,X3_CAMPO)
			wVar := "M->"+x3_campo
			&wVar:= CriaVar(x3_campo)
		Endif
	EndIF
	dbSkip()
EndDO

Do Case
	Case nOpc == 3 && Incluir
		nOpcE:=3
		nOpcG:=3
	Case nOpc == 2 && Visualizar
		nOpcE:=2
		nOpcG:=2
	Case nOpc == 1 && Pesquisar
		nOpcE:=1
		nOpcG:=1
	Otherwise && Excluir
		nOpcE:=4
		nOpcG:=4
EndCase

if nOpc == 3
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
Else
	aCols:={}
	dbSelectArea("VVG")
	dbSetOrder(1)
	dbSeek(xFilial()+M->VVF_TRACPA)
	While !eof() .and. VVG->VVG_FILIAL == xFilial("VVG") .and. M->VVF_TRACPA == VVG_TRACPA
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
		Next
		aCols[Len(aCols),nUsado+1]:=.F.
		dbSkip()
	End
Endif

If Len(aCols)>0
	
	Private oFolder
	Private nOpcao := nOpc
	Private lOk:=.F.
	Private aSvAtela := {{},{},{}}
	Private aSvAGets := {{},{},{}}
	Private aTela :={}
	Private aGets :={}
	Private oEnc01
	Private oEnc02
	nOpca     := 0
	
	
	cAliasEnchoice:="VVF"
	cAliasGetD    :="VVG"
	cLinOk        :="FS_NpLinha(),CheckCols(n,aCols)"
	cTudOk        :="Allwaystrue()"
	cFieldOk      :="FG_MEMVAR()" //FS_ATRV000()"
	
	
	Aadd(aPages,"HEADER 1")
	nControl++
	Aadd(aPages,"HEADER 2")
	nControl++
	Aadd(aPages,"HEADER 3")
	nControl++

	SETAPILHA()
	DEFINE MSDIALOG oDlgFolder TITLE cCadastro FROM  4.5,0 To 25.5,80 OF oMainWnd
	oFolder := TFolder():New(1,0,aTitles,aPages,oDlgFolder,,,,.F.,.F.,345,180,)
	oFolder:bSetOption := {|x| if(FS_TrataAba(x),if(oFolder:nOption == 2,FG_GravaVV1(),.t.),.f.) }

	FG_INIFOLDER("oFolder",2)

	//oFolder:aDialogs[1]:oFont := oDlgFolder:oFont
	//oFolder:aDialogs[2]:oFont := oDlgFolder:oFont

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Enchoice 01	- Cabecalho da NF		                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTela := {}
	aGets := {}
	dbSelectArea("VVF")
	Zero()
	oEnc01:= MsMGet():New("VVF" ,nReg ,nOpcao,,,,aCpoEncS,{1,1,90,315},aCpoEncS,2,,,,oFolder:aDialogs[1],,,.F.,"aSvATela[1]")
	oEnc01:oBox:bGotFocus   := {|| AL_EntraEnc(1,"VVF")}
	oEnc01:oBox:bLostFocus  := {|| AL_SaiEnc(1)}
	aSvATela[1] := aClone(aTela)
	aSvAGets[1] := aClone(aGets)

   oGetDados := MsGetDados():New(92,1,133,315,nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk,,,,oFolder:aDialogs[1])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Enchoice 02	- Dados do Veiculo   	                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTela := {}
	aGets := {}
	dbSelectArea("VV1")
	RegToMemory('VV1')
	oEnc02:=MsMGet():New("VV1",nReg,nOpcao,,,,aCampoVV1,{15,1,132,315},aCampoVV1,2,,,,oFolder:aDialogs[2],,,.F.,"aSvATela[2]")
	oEnc02:oBox:bGotFocus   := {|| AL_EntraEnc(2,"VV1")}
	oEnc02:oBox:bLostFocus  := {|| AL_SaiEnc(2)}
	aSvATela[2] := aClone(aTela)
	aSvAGets[2] := aClone(aGets)

	ACTIVATE MSDIALOG oDlgFolder CENTER ON INIT (EnchoiceBar(oDlgFolder, {|| nOpca:=1,if(FS_GRVENT1(nOpc),oDlgFolder:End(),nOpca := 2)},{||nOpca := 2,oDlgFolder:End()}))
	SETAPILHA()

Endif

dbSelectArea("VVF")
cIndex := CriaTrab(nil,.f.)
cKey   := IndexKey()
cCondicao :='VVF->VVF_OPEMOV == "1"'
IndRegua("VVF",cIndex,"VVF_FILIAL+(DtoS(VVF_DATMOV))",,cCondicao,OemToAnsi(STR0006))  // "Selecionando Registros..." //"1=Pedidos Fabrica"

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_GRVENT1³Autor  ³  Manoel               ³ Data ³ 31/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao e Integracao de Veiculos Pedidos a Fabrica        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRVENT1(nOpc)

Begin  Transaction

   if nopc == 4 // Cancelamento
   	FS_CancEnt(cAlias, nReg, nOpc)
   Else
   	FS_ChaTemp("2")
   Endif
   Altera := .t.

End Transaction
lMsHelpAuto := .f.


if !lMsErroAuto
   Return .t.
Else
	MostraErro()
   Return .f.
Endif

Return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_ChaTemp    ³ Autor ³ Manoel                ³ Data ³ 22/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Criacao de Chassis Automaticos em Pedidos a Fabrica            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Veiculos                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ChaTemp(cParamet)
Local qtv := 0
* cParamet == "1" -> inicializa campo Chassi com o proximo numero disponivel
* cParamet == "2" -> cria no VV1, a qtd de veiculos Temporarios informados pelo
*                    usuario, com mesmo modelo e cor informados na digitacao do
*                    primeiro Veiculo.

if cParamet == "1"  &&Chamado pelo SX3
	if(Inclui,M->VVG_CHASSI:="TEMP",M->VVG_CHASSI:=VVG->VVG_CHASSI)
		Return
	Elseif cParamet == "2"  && Chamado pelo PRW
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravacao do VVF                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if RecLock("VVF",.t.)
   		VVF->VVF_FILIAL := xFilial("VVF")
	   	VVF->VVF_OPEMOV := Subs(OemToAnsi(STR0002),1,1) //"1"   Pedidos a Fabrica //"Ok - <Ctrl-O>"
   		VVF->VVF_FORPRO := M->VVF_FORPRO
   		VVF->VVF_SITNFI := "1" && Valida
   		VVF->VVF_TRACPA := M->VVF_TRACPA
   		VVF->VVF_DATMOV := M->VVF_DATMOV
   		VVF->VVF_CODFOR := M->VVF_CODFOR
   		VVF->VVF_CODFOR := M->VVF_LOJA
   		VVF->VVF_QTDVEI := M->VVF_QTDVEI
   		VVF->VVF_DTHEMI := Dtoc(dDataBase) + [/] + Time()
   		ConfirmSx8("VVF")
   		MsUnlock()

   		DbSelectArea("VV1")
	   	FG_Seek("VV1","aCols[1,FG_POSVAR('VVG_CHASSI')]",2,.f.)
   		if RecLock("VV1",.f.)
      		VV1->VV1_FILIAL := xFilial("VV1")
      		VV1->VV1_TRACPA := VVF->VVF_TRACPA
      		VV1->VV1_CHASSI := "TEMP"+VV1->VV1_CHAINT
      		VV1->VV1_CODORI := aCols[1,FG_POSVAR("VVG_CODORI")]
      		VV1->VV1_SITVEI := "0" && Estoque (porém virtual)
      		VV1->VV1_ESTVEI := "0" && Novo
      		VV1->VV1_INDCAL := "5" && Pedido na Fabrica
      		VV1->VV1_LOCPAD := aCols[1,FG_POSVAR("VVG_LOCPAD")]
   	   	MsUnLock()
      		dbSelectArea("SX3")
      		dbSeek("VV1")
      		nCntFor := 0
      		While !Eof().and.(x3_arquivo=="VV1")
      			*              nCntFor++
      			cVar := x3_campo
      			*    	         if !cVar $ "VV1_OBSERV#VV1_OBSMEM" .and. x3_context == Space(1)
      			if !cVar $ "VV1_CHAINT#VV1_CHASSI#VV1_TRACPA#VV1_FILIAL#VV1_OBSERV#VV1_OBSMEM" .and. x3_context == Space(1)
      				DbSelectArea("VV1")
      				M->&cVar:= VV1->&cVar
      				DbSelectArea("SX3")
      			Endif
      			dbSkip()
      		Enddo
      		cCdInd := aCols[1,FG_POSVAR("VVG_CODIND")]
      		DbSelectArea("VVG")
      		if RecLock("VVG",If(Inclui,.t.,.f.))
         		VVG->VVG_FILIAL := xFilial("VVG")
         		VVG->VVG_TRACPA := VVF->VVF_TRACPA
         		VVG->VVG_CHAINT := VV1->VV1_CHAINT
         		VVG->VVG_CHASSI := VV1->VV1_CHASSI
         		VVG->VVG_CODIND := cCdInd
         		VVG->VVG_CODORI := aCols[1,FG_POSVAR("VVG_CODORI")]
         		VVG->VVG_LOCPAD := aCols[1,FG_POSVAR("VVG_LOCPAD")]
         		VVG->VVG_ESTVEI := "0" && Novo
         		MsUnlock()

         		For qtv = 2 to M->VVF_QTDVEI

         			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         			//³ Gravacao do VV1                                              ³
         			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         			DbselectArea("VV1")
         			if RecLock("VV1",.t.)
            			Inclui := .t.
            			VV1->VV1_FILIAL := xFilial("VV1")
            			VV1->VV1_CHAINT := CriaVar("VV1_CHAINT") &&GetSx8Num("VV1","VV1->VV1_CHAINT")
            			VV1->VV1_CHASSI := "TEMP" + VV1->VV1_CHAINT
            			VV1->VV1_TRACPA := VVF->VVF_TRACPA
            			VV1->VV1_CODMAR := M->VV1_CODMAR
            			VV1->VV1_MODVEI := M->VV1_MODVEI
            			VV1->VV1_COMMOD := M->VV1_COMMOD
            			VV1->VV1_CODORI := M->VV1_CODORI
            			VV1->VV1_PROATU := M->VV1_PROATU
            			VV1->VV1_PROANT := M->VV1_PROANT
            			VV1->VV1_PROVEI := M->VV1_PROVEI
            			VV1->VV1_CORVEI := M->VV1_CORVEI
            			VV1->VV1_SITVEI := M->VV1_SITVEI
            			VV1->VV1_ESTVEI := M->VV1_ESTVEI
            			VV1->VV1_FABMOD := M->VV1_FABMOD
            			VV1->VV1_COMVEI := M->VV1_COMVEI
            			VV1->VV1_INDCAL := M->VV1_INDCAL
            			VV1->VV1_TIPDIF := M->VV1_TIPDIF
            			VV1->VV1_NUMDIF := M->VV1_NUMDIF
            			VV1->VV1_RELDIF := M->VV1_RELDIF
            			VV1->VV1_RENAVA := M->VV1_RENAVA
            			VV1->VV1_CAPTRA := M->VV1_CAPTRA
            			VV1->VV1_PESBRU := M->VV1_PESBRU
            			VV1->VV1_QTDCIL := M->VV1_QTDCIL
            			VV1->VV1_QTDEIX := M->VV1_QTDEIX
            			VV1->VV1_DISEIX := M->VV1_DISEIX
            			VV1->VV1_TIPCAM := M->VV1_TIPCAM
            			VV1->VV1_CAMBIO := M->VV1_CAMBIO
            			VV1->VV1_TIPMOT := M->VV1_TIPMOT
            			VV1->VV1_NUMMOT := M->VV1_NUMMOT
            			VV1->VV1_SERMOT := M->VV1_SERMOT
            			VV1->VV1_CILMOT := M->VV1_CILMOT
            			VV1->VV1_POTMOT := M->VV1_POTMOT
            			VV1->VV1_TIPCAB := M->VV1_TIPCAB
            			VV1->VV1_NUMLOT := M->VV1_NUMLOT
            			VV1->VV1_SUGVDA := M->VV1_SUGVDA
            			VV1->VV1_ARQIMG := M->VV1_ARQIMG
            			VV1->VV1_LOCPAD := M->VV1_LOCPAD
            			MsUnLock()
            			ConfirmSx8("VV1")
                  Else
                     lOk := .f.
                     DisarmTransaction()
                     Break
                  Endif

         			DbselectArea("VVG")
         			if RecLock("VVG",.t.)
            			VVG->VVG_FILIAL := xFilial("VVG")
            			VVG->VVG_CHASSI := VV1->VV1_CHASSI
            			VVG->VVG_CHAINT := VV1->VV1_CHAINT
            			VVG->VVG_TRACPA := VVF->VVF_TRACPA
            			VVG->VVG_ESTVEI := VV1->VV1_ESTVEI
            			VVG->VVG_CODIND := cCdInd
            			VVG->VVG_CODORI := VV1->VV1_CODORI
            			VVG->VVG_LOCPAD := VV1->VV1_LOCPAD
            			MsUnLock()
                  Else
                     lOk := .f.
                     DisarmTransaction()
                     Break
                  Endif
         		Next
            Endif
         Else
            lOk := .f.
            DisarmTransaction()
            Break
         Endif
      Else
         lOk := .f.
         DisarmTransaction()
         Break
      Endif
   Else
      lOk := .f.
      DisarmTransaction()
      Break
   Endif
	Return

/*
	Static Function AL_InicioEnc()
	aTela := aClone(aSvATela[1])
	aGets := aClone(aSvAGets[1])
	dbSelectArea("VVF")
	Return .T.
*/
	Static Function AL_EntraEnc(nE,cAlias)
	aTela := AClone(aSvAtela[nE])
	aGets := AClone(aSvaGets[nE])
	dbSelectArea(cAlias)
	Return
	
	Static Function Al_Saienc(nE)
	aSvATela[nE]	:= aClone(aTela)
	aSvAGets[nE]   	:= aClone(aGets)
	return
		
Static Function MenuDef()
Local aRotina := {{ OemtoAnsi(STR0003),"Afunc01", 0 , 1},;   && Pesquisar //"Incluir"
						{ OemtoAnsi(STR0004),"Afunc01", 0 , 2},;   && Vizualizar //"Cancelar"
						{ OemtoAnsi(STR0005),"Afunc01", 0 , 3},;   && Incluir //"Entrada Normal de Veiculos"
						{ OemtoAnsi(STR0007),"Afunc01", 0 , 4},; && Excluir
						{ STR0051  ,"VM001_LVEI" , 0 , 2}}   //Pesquisa Chassi} }
Return aRotina  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³VM001_LVEI³Autor³ Andre Luis Almeida / Rafael ³Data³ 08/10/08 ³±±
±±ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr.³ Levantamento dos REGISTROS pelo Chassi do Veiculo            ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM001_LVEI()
Local nOpca := 0
Local nEmpAtu := SM0->(RecNo())
Local cEmpAtu := SM0->M0_CODIGO
Private aEmpAtu  := {}     
Private aLevPesq := {{"","","",ctod(""),"",0,""}}
Private cLevChas := left(space(50),len(VV1->VV1_CHASSI))
Private overd := LoadBitmap( GetResources() , "BR_VERDE" )
Private overm := LoadBitmap( GetResources() , "BR_VERMELHO" )
Private opret := LoadBitmap( GetResources() , "BR_PRETO" )
DbSelectArea("SM0")
DbGoTop()
Do While !Eof()
	if SM0->M0_CODIGO == cEmpAtu
		aAdd( aEmpAtu , { SM0->M0_CODFIL , SM0->M0_FILIAL } )
	EndIf
	DbSkip()
EndDo
DbSelectArea("SM0")
DbGoTo(nEmpAtu)
DEFINE MSDIALOG oLevPesq TITLE OemtoAnsi(STR0052) FROM  01,05 TO 17,70 OF oMainWnd //Pesquisa Chassi
	@ 003,004 SAY STR0053 SIZE 80,7 OF oLevPesq PIXEL COLOR CLR_BLUE  //Veiculo:
  	@ 002,025 MSGET oLevChas VAR cLevChas F3 "VV1" VALID (FG_POSVEI("cLevChas",),FS_LEVVEI()) PICTURE "@!" SIZE 100,08 OF oLevPesq PIXEL
 	@ 002,212 BUTTON oNo PROMPT OemToAnsi(STR0054) OF oLevPesq SIZE 43,11 PIXEL ACTION (nOpca := 0, oLevPesq:End())  //SAIR
	@ 015,002 LISTBOX oLbLevPesq FIELDS HEADER OemToAnsi(""),;
																OemToAnsi(STR0055),; //Filial
																OemToAnsi(STR0056),;//Dt.Movimento
																OemToAnsi(STR0057),; //NF/Serie
																OemToAnsi(STR0058),; //Valor
																OemToAnsi(STR0059);//Fornecedor
																COLSIZES 10,35,35,25,40,150 SIZE 253,104 OF oLevPesq PIXEL ON DBLCLICK (nOpca := oLbLevPesq:nAt, oLevPesq:End() )
	oLbLevPesq:SetArray(aLevPesq)
	oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="1",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="0",oVerm,opret)),;
   							   	aLevPesq[oLbLevPesq:nAt,03],;
   							   	Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
   							   	aLevPesq[oLbLevPesq:nAt,05],;
	 									FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
   							   	aLevPesq[oLbLevPesq:nAt,07] }}
ACTIVATE MSDIALOG oLevPesq CENTER
dbSelectArea("VVF")   
if nOpca > 0 .and. Len(aLevPesq) >= nOpca 
  	//posiciona no registro
  	dbSetOrder(1)//TRACPA
  	DbSeek(left(aLevPesq[nOpca,3],2)+ aLevPesq[nOpca,1])
endif       
Return

Static Function FS_LEVVEI()
Local cEmpAtu := ""
Local nEmpAtu := 0
Local lOk := .t.
Local cQuery := ""
Local cQAlVVF := "SQLVVF"
Local cFilLibs := ""
If !Empty(cLevChas)
	aLevPesq := {}
	cQuery := "SELECT VVF.VVF_TRACPA , VVF.VVF_SITNFI , VVF.VVF_FILIAL , VVF.VVF_DATMOV , VVF.VVF_NUMNFI , VVF.VVF_SERNFI , VVF.VVF_VALMOV , VVF.VVF_CODFOR , VVF.VVF_LOJA FROM "+RetSqlName("VVF")+" VVF , "+RetSqlName("VVG")+" VVG WHERE "
	cQuery += "VVG.VVG_CHASSI='"+cLevChas+"' AND VVF.VVF_FILIAL=VVG.VVG_FILIAL AND VVF.VVF_TRACPA=VVG.VVG_TRACPA AND "
	cFilLibs := FG_FilLib(2) // retorna apenas filiais que o usuario pode acessar
	If len(cFilLibs) > 1
		cQuery += "VVF.VVF_FILIAL IN ("
		While len(cFilLibs) > 1
			If SM0->M0_CODIGO == left(cFilLibs,2)
				cQuery += "'"+substr(cFilLibs,3,2)+"',"
			EndIf
			cFilLibs := substr(cFilLibs,6)
		EndDo
		cQuery := left(Alltrim(cQuery),len(Alltrim(cQuery))-1)+") AND "
	EndIf
	cQuery += "VVF.VVF_OPEMOV='1' AND VVF.D_E_L_E_T_=' ' AND VVG.D_E_L_E_T_=' ' ORDER BY VVF.VVF_DATMOV "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVVF, .F., .T. )
	Do While !( cQAlVVF )->( Eof() )
		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek( xFilial("SA2") + ( cQAlVVF )->( VVF_CODFOR ) + ( cQAlVVF )->( VVF_LOJA ) )
		cEmpAtu := ""
		nEmpAtu := Ascan(aEmpAtu,{|x| x[1] == ( cQAlVVF )->( VVF_FILIAL ) })
	   If nEmpAtu > 0 
	      cEmpAtu := left(aEmpAtu[nEmpAtu,2],15)
	   EndIf
		aAdd(aLevPesq,{ ( cQAlVVF )->( VVF_TRACPA ) , ( cQAlVVF )->( VVF_SITNFI ) , ( cQAlVVF )->( VVF_FILIAL )+"-"+cEmpAtu , stod(( cQAlVVF )->( VVF_DATMOV )) , ( cQAlVVF )->( VVF_NUMNFI )+"-"+( cQAlVVF )->( VVF_SERNFI ) , ( cQAlVVF )->( VVF_VALMOV ) , ( cQAlVVF )->( VVF_CODFOR )+"-"+( cQAlVVF )->( VVF_LOJA )+" "+SA2->A2_NOME })
		( cQAlVVF )->( DbSkip() )
	EndDo
	( cQAlVVF )->( dbCloseArea() )
	If len(aLevPesq) <= 0
		MsgAlert(STR0060 + " " + cLevChas,STR0061) //Nenhum Pedido encontrado para o Chassi - Atencao
		aLevPesq := {{"","","",ctod(""),"",0,""}}
		lOk := .f.
	EndIf
	oLbLevPesq:nAt := 1
	oLbLevPesq:SetArray(aLevPesq)
	oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="1",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="0",oVerm,opret)),;
	  							   	aLevPesq[oLbLevPesq:nAt,03],;
	  							   	Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
	  							   	aLevPesq[oLbLevPesq:nAt,05],;
	 									FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
	  							   	aLevPesq[oLbLevPesq:nAt,07] }}
	oLbLevPesq:SetFocus()
	oLbLevPesq:Refresh()
	If !lOk
		oLevChas:SetFocus()
	EndIf
EndIf
Return
