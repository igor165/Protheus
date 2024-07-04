// ษออออออออหออออออออป
// บ Versao บ 19     บ
// ศออออออออสออออออออผ

#INCLUDE "OFIOA280.ch"
#Include "PROTHEUS.CH"

#DEFINE nMaxRight (oDlgChk:nClientWidth/2)
#DEFINE nMaxHeight (oDlgChk:nClientHeight/2)
#DEFINE nMetade (oDlgChk:nClientHeight/4)

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  08/01/2018
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "006574_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ OFIOA280 ณ Autor ณ  Ricardo Farinelli    ณ Data ณ 01/11/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Check-list de oficina (veiculos)                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOA280(cFonte)
Private aRotina := MenuDef()
PRIVATE aMemos := {{"VA8_OBSMEM","VA8_OBSERV"}}
Private cCadastro := STR0006 // Checklist de Veiculos (Oficina)
Private cObjetiv  := STR0006 // Checklist de Veiculos (Oficina) - variavel utilizada no OFIOM410
Default cFonte := ""
dbSelectArea("VA8")
dbSetOrder(1)
if cFonte == "OFIOM140"
	FilBrowse("VA8",{},"VA8->VA8_NUMOSV == '"+VO1->VO1_NUMOSV+"' .AND. VA8->VA8_ENTSAI == '1' ",.t.) 	// Filtra a OS
Endif
mBrowse( 6, 1,22,75,"VA8")
if cFonte == "OFIOM140"
	dbClearFilter()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOFIOA280I บAutor  ณRicardo Farinelli   บ Data ณ  01/11/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTrata a manutencao do check-list                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOA280I(cAlias1,nReg,nOpc)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor  := 0
Local cCadastro := STR0007 //"Checklist de Veiculos"
Local aButtons	 := nil
Local oDlgChk,oBtnAva
Local nOpcG
Local nOpcE
Local nOpcao := 0
Local aCpoEnchoice := {}
Local cLinOk := "OA280LINOK()", cTudoOk := "OA280TUDOK()", cFieldOk := "OA280FILOK()"
Local nwnk   := 0
Private oEnchochk
Private nOpcX := nOpc
Private oGetDados1
Private aHeader := {}, aCols := {}
Private aTELA[0][0],aGETS[0]
Private oBtnNew
Private cCodigo := ""	// esta variavel eh utilizada no filtro da consulta va0 para poder filtrar
// pelo codigo pai do item generico de checklist da avaliacao
Private atelas := {} // Controle de angulos de visualizacao de figuras
Private cCodIte := "" // vide cCodigo

If EXISTBLOCK("PEOA280B")
  aButtons := ExecBlock("PEOA280B")
Else
  aButtons := { {"BUDGETY", {||OFIOR300()}, OemToAnsi(STR0008)} } //"Checklist do Veiculo" - Impressao do relatorio
Endif

RegToMeMory("VA8",Inclui)
nOpcG := nOpcX
nOpcE := nOpcX

OA280Ench(aCpoEnchoice) // Monta o Vetor com os campos para a Enchoice
OA280aHeader("VSR","aHeader","VSR_NUMOSV") // Monta aHeader/aCols para o VSR
OA280aCols("VSR",1,xFilial("VSR")+VA8->VA8_NUMOSV,"aCols","VSR_FILIAL+VSR_NUMOSV") // Monta aCols para o VSR

if funname() == "OFIOM350"
	if Inclui
		lFound := !(Dbseek(xFilial("VA8")+VSO->VSO_NUMOSV+VSO->VSO_PLAVEI))
		if lFound == .t.
			M->VA8_PLAVEI := VSO->VSO_PLAVEI
		Endif
	Endif
Endif
If !Inclui
	For nwnk := 1 To Len(aCols)
		// Carrega a Descricao do Grupo para o campo do aCols
		aCols[nwnk,FG_POSVAR("VSR_DESGRU")] := VM500Desc("VA0",aCols[nwnk,FG_POSVAR("VSR_CODGRU")],1,FG_POSVAR("VSR_DESGRU"),"VA0_DESCRI")
		// Carrega a Descricao do Item do Grupo Generico para o campo do aCols
		aCols[nwnk,FG_POSVAR("VSR_DESITE")] := VM500Desc("VA0",aCols[nwnk,FG_POSVAR("VSR_ITEM")],1,FG_POSVAR("VSR_DESITE"),"VA0_DESCRI")
		// Carrega a Descricao do Item da Avaria para o campo do aCols
		aCols[nwnk,FG_POSVAR("VSR_DESAVA")] := VM500Desc("VA4",aCols[nwnk,FG_POSVAR("VSR_AVARIA")],1,FG_POSVAR("VSR_DESAVA"),"VA4_DESCRI")
	Next
Endif

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 160 , .T., .F. } )  //Cabecalho
AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
AAdd( aObjects, { 1, 10, .T. , .F. } )  //list box superior

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlgChk TITLE cCadastro From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

oEnchoChk:= MsMGet():New("VA8" ,nReg,nOpcX,,,,aCpoEnchoice,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,,,,,oDlgChk,,.T.,.F.)

oGetDados1  := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpcX,cLinOk,cTudoOk,"",If(nOpcX > 2 .and. nOpcX < 5,.t.,.f.),,1,,,cFieldOk,,,,oDlgChk)

DEFINE SBUTTON oBtnNew TYPE 01 FROM aPosObj[3,1],aPosObj[3,4]-30 OF oDlgChk ACTION .T.
DEFINE SBUTTON oBtnAva TYPE 15 FROM aPosObj[3,1],aPosObj[3,4]-70 OF oDlgChk ENABLE ONSTOP STR0009 ACTION 	OA280AVAVI() When (Inclui .or. Altera)  //"Avaliacao Visual"

ACTIVATE MSDIALOG oDlgChk ON INIT Enchoicebar(oDlgChk,{||nOpcao := 1,If(!Obrigatorio(aGets,aTela),nOpcao := 0,If(!OA280TUDOK(),nOpcao:= 0,oDlgChk:End()))},{||nOpcao := 2,oDlgChk:End()},,aButtons)

If nOpcao==1 .and. (Inclui .or. Altera)
	Fs_Grv280oa(nOpc)
Elseif nOpcao == 1
	Fs_Grv280oa(nOpc)
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOA280aHeader      ณRicardo Farinelli   บ Data ณ  10/23/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o aHeader conforme o Alias informado                  บฑฑ
ฑฑบParametrosณcAlias     = alias do arquivo a ser montado                 บฑฑ
ฑฑบ          ณcAheader   = nome da variavel array a ser criado            บฑฑ
ฑฑบ          ณcNaoCpo    = campos para excluir da getdados                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OA280aHeader(cAlias,cHeader,cNaoCpo)
Local aAlias := sGetaRea()
Local nPosRec:= 0

sGetArea(aAlias,Alias())

dbSelectArea("SX3")
dbSetOrder(1)
Dbseek(cAlias)
While !Eof() .And. (SX3->X3_ARQUIVO == cAlias)
	IF X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .and. !(SX3->X3_CAMPO == "VSR_PLAVEI") .and. Iif(cNaoCpo<>Nil,!SX3->X3_CAMPO$cNaoCpo,.T.)
		AADD(&(cHeader),{ TRIM(x3titulo()),;
		SX3->X3_CAMPO,;
		SX3->X3_PICTURE,;
		SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL,;
		SX3->X3_VALID,;
		SX3->X3_USADO,;
		SX3->X3_TIPO,;
		SX3->X3_ARQUIVO,;
		SX3->X3_CONTEXT,;
		SX3->X3_RELACAO,;
		SX3->X3_RESERV })
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo

// Inclui coluna de registro atraves de funcao generica
dbSelectArea(cAlias)
ADHeadRec(cAlias,&(cHeader))
// Posicao do registro
nPosRec:=Len(&(cHeader))
nUsado :=Len(&(cHeader))

sRestArea(aAlias)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOA280aCols        ณRicardo Farinelli   บ Data ณ  10/23/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o aHeader conforme o Alias informado                  บฑฑ
ฑฑบParametrosณcAlias     = alias do arquivo a ser montado                 บฑฑ
ฑฑบ          ณnOrdem     = Ordem do arquivo em caso de alteracao/exc/vis. บฑฑ
ฑฑบ          ณcChave     = Chave de pesquisa em caso de alt/exc/vis.      บฑฑ
ฑฑบ          ณcAcols     = variavel que ira receber o conteudo            บฑฑ
ฑฑบ          ณcCond      = variavel de escopo da tabela para alt/exc/vis. บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OA280aCols(cAlias,nOrdem,cChave,caCols,cCond)
Local nY
Local aAlias := sGetArea()
sGetArea(aAlias,Alias())
sGetArea(aAlias,cAlias)

If Inclui
	aadd(ACols,Array(Len(aHeader)+1))
	For nY := 1 To Len(aHeader)
		If IsHeadRec(aHeader[nY][2])
			ACols[1][nY] := 0
		ElseIf IsHeadAlias(aHeader[nY][2])
			ACols[1][nY] := cAlias
		Else
			ACols[1][nY] := CriaVar(aHeader[nY][2])
			ACols[1][Len(ACols[1])] := .F.
		EndIf
	Next nY
Else
	&(cAlias)->(DbsetOrder(nOrdem))
	If &(cAlias)->(Dbseek(cChave))
		DbselectArea(cAlias)
		Do While &(cAlias)->(&cCond) == cChave .and. !(&(cAlias)->(Eof()))
			aadd(ACols,Array(Len(aHeader)+1))
			For ny:=1 to Len(aHeader)
				If IsHeadRec(aHeader[ny,2])
					ACols[Len(ACols),ny] := &(cAlias)->(RecNo())
				ElseIf IsHeadAlias(aHeader[ny,2])
					ACols[Len(ACols),ny] := cAlias
				Else
					ACols[Len(ACols),ny]:=If(aHeader[ny,10] # "V",FieldGet(FieldPos(aHeader[ny,2])),CriaVar(aHeader[ny,2],Inclui))
				EndIf
			Next
			ACols[Len(ACols),Len(ACols[Len(ACols)])] := .f.
			&(cAlias)->(Dbskip())
		Enddo
	Else
		aadd(ACols,Array(Len(aHeader)+1))
		For nY := 1 To Len(aHeader)
			If IsHeadRec(aHeader[nY][2])
				ACols[1][nY] := 0
			ElseIf IsHeadAlias(aHeader[nY][2])
				ACols[1][nY] := cAlias
			Else
				ACols[1][nY] := CriaVar(aHeader[nY][2])
			EndIf
		Next nY
		ACols[1][Len(ACols[1])] := .F.
	Endif
Endif
sRestArea(aAlias)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOA280ENCH บAutor  ณRicardo Farinelli   บ Data ณ  10/23/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a Enchoice do VA8                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OA280Ench(aCpoEnchoice)
Local aAlias := SGetArea()
SGetArea(aAlias,Alias())

DbSelectArea("SX3")
DbGotop()
DbSeek("VA8")

While x3_arquivo == "VA8" .and. !eof()
	If X3USO(x3_usado).and.cNivel>=x3_nivel
		AADD(aCpoEnchoice,x3_campo)
	Endif
	dbSkip()
EndDo
SRestArea(aAlias)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRV280OA       ณRicardo Farinelli   บ Data ณ  10/29/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a gravacao dos dados nos respectivos arquivos        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GRV280OA(nOpc)
Local lFound := .F.,nwnk

If nOpc <> 5
	Begin Transaction
	DbselectArea("VA8") // Cabecalho Check-list
	DbsetOrder(1)
	if nOpc == 3 .and. Empty(M->VA8_NUMOSV)
		lFound := .t.
	Else
		lFound := !(Dbseek(xFilial("VA8")+M->VA8_NUMOSV+M->VA8_PLAVEI))
	Endif
	RecLock("VA8",lFound)
	FG_GRAVAR("VA8")
	If VA8->(FieldPos("VA8_OBSMEM")) > 0
		MSMM(VA8->VA8_OBSMEM,TamSx3("VA8_OBSERV")[1],,&(aMemos[1][2]),1,,,"VA8","VA8_OBSMEM")
	Endif
	MsUnlock()
	if funname() == "OFIOM350"
		dbSelectArea("VA8")
		RecLock("VA8",.f.)
		VA8->VA8_NUMAGE := VSO->VSO_NUMIDE
		VA8->VA8_PLAVEI := VSO->VSO_PLAVEI
		if Empty(M->VA8_ENTSAI)
			VA8->VA8_ENTSAI := "0"
		Endif
		MsUnlock()
	Else
		dbSelectArea("VA8")
		RecLock("VA8",.f.)
		VA8->VA8_PLAVEI := M->VA8_PLAVEI
		if Empty(M->VA8_ENTSAI)
			VA8->VA8_ENTSAI := "0"
		Endif
		MsUnlock()
	Endif
	DbselectArea("VSR") // Estado Geral do Veiculo
	DbsetOrder(1)
	// Coloca os deletados primeiro
	Asort(aCols,,,{|x,y| x[len(x)] > y[Len(y)] })
	For nwnk := 1 To Len(aCols)
		lFound := !(Dbseek(xFilial("VSR")+M->VA8_NUMOSV+aCols[nwnk,FG_POSVAR("VSR_CODGRU")]+aCols[nwnk,FG_POSVAR("VSR_ITEM")]+aCols[nwnk,FG_POSVAR("VSR_AVARIA")]))
		RecLock("VSR",lFound)
		If aCols[nwnk,Len(aCols[nwnk])] .and. !lFound
			Dbdelete()
		Else
			FG_GRAVAR("VSR",aCols,aHeader,nwnk)
			VSR_NUMOSV := M->VA8_NUMOSV
		Endif
		VSR->VSR_PLAVEI := M->VA8_PLAVEI
		MsUnlock()
		dbSelectArea("VSR")
		RecLock("VSR",.f.)
		VSR->VSR_NUMAGE := VSO->VSO_NUMIDE
		VSR->VSR_PLAVEI := M->VA8_PLAVEI
		MsUnlock()
	Next
	End Transaction
Elseif nOpc == 5
	Begin Transaction
	DbselectArea("VSR")
	DbsetOrder(1)
	VSR->(Dbseek(xFilial("VSR")+M->VA8_NUMOSV))
	Do While VSR->(VSR_FILIAL+VSR_NUMOSV) == xFilial("VSR")+VA8->VA8_NUMOSV .and. !VSR->(Eof())
		RecLock("VSR",.F.)
		Dbdelete()
		MsUnLock()
		Dbskip()
	Enddo
	
	DbselectArea("VA8") // Cabecalho checklist
	DbsetOrder(1)
	RecLock("VA8",.F.)
	dbDelete()
	MsUnLock()
	End Transaction
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOA280AVAVIบAutor  ณRicardo Farinelli   บ Data ณ  10/30/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta a Avaliacao visual do veiculo                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OA280AVAVI()
Local nVezes := 0, cFigPri := "", aAlias := SGetArea()
aTelas := {}
sGetArea(aAlias,"VA6")
If PERGUNTE("OA280A",.T.)
	cFigPri := MV_PAR01
Else
	Return
Endif
VA6->(DbsetOrder(1))
If VA6->(Dbseek(xFilial("VA6")+cFigPri))
	cFigPri := VA6->VA6_CODLAY
Endif
Do While .T.
	AAdd(aTelas,{VA6->VA6_CODIGO,VA6->VA6_CODLAY,VA6->VA6_PAI," "})
	nVezes++
	If Empty(VA6->VA6_PAI)
		Exit
	Else
		VA6->(dbseek(xFilial("VA6")+VA6->VA6_PAI))
	Endif
Enddo

OA280ViewImg(cFigPri)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOA280PRX  บAutor  ณRicardo Farinelli   บ Data ณ  10/30/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChamada da funcao com parametros para mudanca de angulo da  บฑฑ
ฑฑบ          ณfigura                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OA280PRX()
OA280ViewImg(,.T.)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Funao	    ณOA280ViewImgณ Autor ณ Eduardo Motta/Ricardo F.     ณ Data ณ 06/07/2000 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descriao   ณ Vizualizador do lay-out de imagens                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Parametros  ณ cCod   : Codigo do lay-out                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OA280ViewImg(cCod,lLado)
Local oGet1,oGet2,oGet3,oGet4, oBut1,oBut2
Local nTela := 1,cCodigo := ""
Local aPartes
Local cNome
Local cArquivo
Local oDlg
Local nI,nCont
Local cDescricao
Local oCima,oBaixo,oEsq,oDir
Local nOpcao := 0
Local nPos
Local lProx := .F.
Default lLado := .F.

If cCod<> nil
	cCodigo := cCod
	If (nPos := Ascan(aTelas,{|x| x[4]=="X"}) ) == 0
		nPos  := 1
		nPos2 := Ascan(aTelas,{|x| x[2]==cCodigo})
		If nPos2 > 0
			aTelas[nPos2,4]:= "X"
			If !Empty(aTelas[nPos2,3])
				lProx := .T.
			Endif
		Endif
	Endif
Else
	If lLado
		nPos := Ascan(aTelas,{|x| x[4]=="X"})
		If nPos > 0
			If !Empty(aTelas[nPos,3])
				nPos2 := Ascan(aTelas,{|x| x[1]==aTelas[nPos,3]})
				aTelas[nPos,4] := " "
				aTelas[nPos2,4] := "X"
				cCodigo := aTelas[nPos2,2]
				If !Empty(aTelas[nPos2,3])
					lProx := .T.
				Endif
			Endif
		Endif
	Endif
Endif

aPartes := OA280LoadFig(cCodigo)
If Len(aPartes)==0
	MsgStop(OemToAnsi(STR0010)) //"Nao existem figuras parametrizadas para visualizacao"
	Return
Endif
DEFINE MSDIALOG oDlg FROM 0,0 TO 500,500 TITLE OemToAnsi(STR0011) PIXEL //"Visualizacao das Partes do Veiculo"

For nI := 1 to Len(aPartes)
	cNome := aPartes[nI,1]
	cArquivo := Trim(aPartes[nI,9])
	&cNome := TBtnAutFmt():New(10,20 , "", oDlg,,,,,,Trim(aPartes[nI,4]),,,,cArquivo)
	&cNome:nTop := aPartes[nI,2]
	&cNome:nLeft:= aPartes[nI,3]
	&cNome:CREADVAR  := cNome
	&cNome:BLCLICKED := {|x| OA280ViewFil(x,aPartes)  }
Next

If lProx
	DEFINE SBUTTON oBut2 TYPE 21 FROM (oDlg:nClientHeight/2)-25,(oDlg:nClientWidth/2)-30 OF oDlg ENABLE ONSTOP OemToAnsi(STR0012)  ACTION OA280PRX()  //"Proximo Angulo"
Else
	// so para ganhar foco e funcionar o OK da enchoicebar
	DEFINE SBUTTON oBut99 TYPE 21 FROM 5000,5000 OF oDlg ENABLE ONSTOP "" ACTION .T.
Endif

ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||nOpcao:=1 ,oDlg:End()},{||nOpcao:=2,oDlg:End()})
nPos := Ascan(aTelas,{|x| x[2]==cCodigo})
If nPos > 0
	nPos2 := Ascan(aTelas,{|x| x[3]==aTelas[nPos,1]})
	If nPos2 > 0
		aTelas[nPos,4] := " "
		aTelas[nPos2,4] := "X"
		cCodigo := aTelas[nPos2,2]
	Else
		aTelas[nPos,4] := "X"
		cCodigo := aTelas[nPos,2]
	Endif
Endif

Return nOpcao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณOA280ViewFil ณ Autor ณEduardo Motta/Ricardo Data ณ 03/07/00 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Verifica a existencia de um filho na figura, se tiver      ณฑฑ
ฑฑณ          ณ vizualiza o Filho                                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ oBmp   : Objeto BMP                                        ณฑฑ
ฑฑณ          ณ aPartes: Array com os dados das partes do veiculo          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OA280ViewFil(oBmp,aPartes)
Local nLoc := AScan(aPartes,{|x| Trim(x[1]) == Trim(oBmp:cReadVar)})
Local oDlgGru,oGetGru,oDesc1,oGetIte,oDesc2,oGetAva,oDesc3,nValGru,nOpcao
Local cGGvm500,cDes1vm500,cGIvm500,cDes2vm500,cGAvm500,cDes3vm500
Local aAlias := sGetArea()
sGetArea(aAlias,"VA0")
sGetArea(aAlias,"VA4")
sGetArea(aAlias,"VA5")
sGetArea(aAlias,"VA2")

cGGvm500 := CriaVar("VAA_CODGRU")
cDes1vm500  := CriaVar("VAA_DESGRU")
cGIvm500 := CriaVar("VAA_ITEM")
cDes2vm500  := CriaVar("VAA_DESGRU")
cGAvm500 := CriaVar("VAA_AVARIA")
cDes3vm500  := CriaVar("VAA_DESAVA")
VA0->(DbsetOrder(2))
VA4->(DbSetOrder(1))
VA2->(DbsetOrder(1))
VA5->(DbsetOrder(1))

If nLoc > 0
	If !Empty(aPartes[nLoc,7])
		OA280ViewImg(aPartes[nLoc,7])
	Else
		If !Empty(aPartes[nLoc,11])
			cGGvm500 := aPartes[nLoc,11]
			DEFINE MSDIALOG oDlgGru FROM 000,000 TO 150,350 TITLE  OemToAnsi(STR0013) OF oMainWnd PIXEL //"Avaria detectada"
			
			@ 018,03 SAY OemToAnsi(STR0014) OF oDlgGru Size 20,8 Pixel  //"Grupo"
			@ 018,30 MSGET oGetGru VAR cGGvm500 PICT "@!" F3 "VR6" OF ODlgGru Size 20,8 Pixel When ((VA0->(DbSetOrder(2)),.T.) .and. VA0->(Dbseek(xFilial("VA0")+Space(Len(cGGvm500))+cGGvm500)) .and. (cDes1vm500 := VA0->VA0_DESCRI,cCodigo := VA0->VA0_CODIGO,.F.))
			@ 018,70 MSGET oGesDes1 VAR cDes1vm500 When (.F.) Size 100,8 Pixel
			@ 031,03 SAY OemToAnsi(STR0015) OF oDlgGru Size 20,8 Pixel  //"Item"
			@ 031,30 MSGET oGetIte VAR cGIvm500 PICT "@!" F3 "VR7" OF ODlgGru Size 20,8 Pixel VALID ((VA0->(DbSetOrder(2)),.T.) .and. VA0->(Dbseek(xFilial("VA0")+cGGvm500+cGIvm500)) .and.  (cDes2vm500 := VA0->VA0_DESCRI,cCodIte := VA0->VA0_CODIGO,.T.))
			@ 031,70 MSGET oGesDes2 VAR cDes2vm500 When (.F.) Size 100,8 Pixel
			@ 046,03 SAY OemToAnsi(STR0016) OF oDlgGru Size 20,8 Pixel  //"Avaria"
			@ 046,30 MSGET oGetAva VAR cGAvm500 PICT "@!" F3 "VA4" OF ODlgGru Size 20,8 Pixel VALID (VA4->(Dbseek(xFilial("VA4")+cGAvm500)) .and. (cDes3vm500 := VA4->VA4_DESCRI,cCodIte := VA0->VA0_CODIGO,.T.))
			@ 046,70 MSGET oGesDes3 VAR cDes3vm500 When .F. Size 100,8 Pixel
			
			ACTIVATE MSDIALOG oDlgGru CENTER ON INIT Enchoicebar(oDlgGru,{||nOpcao := 1,oDlgGru:End()},{||nOpcao := 2,oDlgGru:End()})
			If nOpcao == 1
				OA280AAdd(cGGvm500,cGIvm500,cGAvm500)
			Endif
		Endif
	EndIf
EndIf

sRestArea(aAlias)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOA280LoadFig      ณRicardo Farinelli   บ Data ณ  10/30/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a carga das partes que formam a figura               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OA280LoadFig(cCodigo)
Local aPartes := {}
VVU->(DbSetOrder(1))
VVU->(DbSeek(xFilial("VVU")+cCodigo))
cDescricao := VVU->VVU_DESC

/*
aPartes[x,01] := Nome do Objeto
aPartes[x,02] := NTOP
aPartes[x,03] := NLEFT
aPartes[x,04] := Descricao (Hint)
aPartes[x,05] := (cod block LCLICK)
aPartes[x,06] := (cod block RCLICK)
aPartes[x,07] := Filho
aPartes[x,08] := Descricao do Filho
aPartes[x,09] := Caminho da Figura 1
aPartes[x,10] := Caminho da Figura 2
aPartes[x,11] := Grupo Generico
aPartes[x,12] := Deletato (.T. / .F.)

*/

VVV->(DbSetOrder(1))
VVV->(DbSeek(xFilial("VVV")+cCodigo))
While VVV->VVV_FILIAL == xFilial("VVV") .and. VVV->VVV_CODIGO == cCodigo .and. ! (VVV->(Eof()))
	AADD(aPartes,{"OFIG"+VVV->VVV_ORDEM,VVV->VVV_NTOP,VVV->VVV_NLEFT,VVV->VVV_DESC,"","",VVV->VVV_FILHO,VVV->VVV_DESFIL,VVV->VVV_FIG1,VVV->VVV_FIG2,VVV->VVV_CODGRU,.F.})
	VVV->(DbSkip())
EndDo

Return aPartes
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOA280AADD บAutor  ณRicardo Farinelli   บ Data ณ  10/30/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInsere avarias no acols da getdados do checklist            บฑฑ
ฑฑบParametrosณcGru    = Grupo generico                                    บฑฑ
ฑฑบ          ณcIte    = Item  generico                                    บฑฑ
ฑฑบ          ณcAva    = Avaria cadastrada no VA5                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OA280AADD(cGru,cIte,cAva)
Local nwnk := 0,lNew := .F.
Local nPos1 := FG_POSVAR("VSR_CODGRU")
Local nPos2 := FG_POSVAR("VSR_ITEM")
Local nPos3 := FG_POSVAR("VSR_AVARIA")

lNew := .T.
For nwnk := 1 To Len(aCols)
	If !aCols[nwnk,Len(aCols[nwnk])]
		If Len(aCols)==1 .and. Empty(aCols[1,nPos1]+aCols[1,nPos2]+aCols[1,nPos3])
			aCols[1,nPos1] := cGru
			aCols[1,nPos2] := cIte
			aCols[1,nPos3] := cAva
			aCols[1,FG_POSVAR("VSR_DESGRU")] := VM500Desc("VA0",aCols[Len(aCols),FG_POSVAR("VSR_CODGRU")],1,FG_POSVAR("VSR_DESGRU"),"VA0_DESCRI")
			aCols[1,FG_POSVAR("VSR_DESITE")] := VM500Desc("VA0",aCols[Len(aCols),FG_POSVAR("VSR_ITEM")],1,FG_POSVAR("VSR_DESITE"),"VA0_DESCRI")
			aCols[1,FG_POSVAR("VSR_DESAVA")] := VM500Desc("VA4",aCols[Len(aCols),FG_POSVAR("VSR_AVARIA")],1,FG_POSVAR("VSR_DESAVA"),"VA4_DESCRI")
			lNew := .F.
		Else
			If aCols[nwnk,nPos1]+aCols[nwnk,nPos2]+aCols[nwnk,nPos3]==cGru+cIte+cAva
				lNew := .F.
			Endif
		Endif
	Endif
Next
If lNew
	AAdd(aCols,Array(Len(aHeader)+1))
	For nwnk:=1 to Len(aHeader)
		aCols[Len(aCols),nwnk]:=CriaVar(aHeader[nwnk,2],Inclui)
	Next
	aCols[Len(aCols),nPos1] := cGru
	aCols[Len(aCols),nPos2] := cIte
	aCols[Len(aCols),nPos3] := cAva
	aCols[Len(aCols),Len(aCols[Len(aCols)])] := .f.
	aCols[Len(aCols),FG_POSVAR("VSR_DESGRU")] := VM500Desc("VA0",aCols[Len(aCols),FG_POSVAR("VSR_CODGRU")],1,FG_POSVAR("VSR_DESGRU"),"VA0_DESCRI")
	aCols[Len(aCols),FG_POSVAR("VSR_DESITE")] := VM500Desc("VA0",aCols[Len(aCols),FG_POSVAR("VSR_ITEM")],1,FG_POSVAR("VSR_DESITE"),"VA0_DESCRI")
	aCols[Len(aCols),FG_POSVAR("VSR_DESAVA")] := VM500Desc("VA4",aCols[Len(aCols),FG_POSVAR("VSR_AVARIA")],1,FG_POSVAR("VSR_DESAVA"),"VA4_DESCRI")
Endif

oGetDados1:oBrowse:Default()
oGetDados1:oBrowse:Refresh()
oGetDados1:ForceRefresh()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOA280FILOKบAutor  ณRicardo Farinelli   บ Data ณ  10/30/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a validacao de campos                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OA280FILOK()

If ReadVar()=="M->VSR_CODGRU"
	// Carrega a Descricao do Grupo para o campo do aCols
	aCols[n,FG_POSVAR("VSR_DESGRU")] := VM500Desc("VA0",M->VSR_CODGRU,1,FG_POSVAR("VSR_DESGRU"),"VA0_DESCRI")
	// Atualiza a variavel de memoria para o filtro do campo item
	cCodigo := M->VSR_CODGRU
Elseif ReadVar()=="M->VSR_ITEM"
	// Carrega a Descricao do Item do Grupo Generico para o campo do aCols
	aCols[n,FG_POSVAR("VSR_DESITE")] := VM500Desc("VA0",M->VSR_ITEM,1,FG_POSVAR("VSR_DESITE"),"VA0_DESCRI")
	cCodIte := M->VSR_ITEM
Elseif ReadVar()=="M->VSR_AVARIA"
	// Carrega a Descricao do Item da Avaria para o campo do aCols
	aCols[n,FG_POSVAR("VSR_DESAVA")] := VM500Desc("VA4",M->VSR_AVARIA,1,FG_POSVAR("VSR_DESAVA"),"VA4_DESCRI")
Endif

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM280LINOKบAutor  ณRicardo Farinelli   บ Data ณ  10/23/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a Linha Digitada nas GetDados                        บฑฑ
ฑฑบParametrosณnx - opcional, numero da linha a validar                    บฑฑ
ฑฑบ          ณlTudook - opcional, ind.a chamada da rotina pela tudook     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OA280LINOK(nX,lTudook)
Local nwnk := 0,nwnk2 := 0,cChave,cChave2,cChave3
Local nPos := 0,nPos2:= 0,nPos3:= 0
Default lTudook := .F.

cChave := 	"VSR_CODGRU"
cChave2:=  	"VSR_ITEM"
cChave3:=  	"VSR_AVARIA"

If nX<>Nil
	n := nX
Endif

nPos := FG_POSVAR(cChave)
nPos2:= FG_POSVAR(cChave2)
nPos3:= FG_POSVAR(cChave3)

// Testa para saber se existem itens validos na linha do acols
lValid := .F.
For nwnk2 := 1 To Len(aCols)
	If !aCols[nwnk2,Len(aCols[nwnk2])] .and. !Empty(aCols[nwnk2,1])
		For nwnk := 1 To Len(aCols[nwnk2])-1
			If !Empty(aCols[nwnk2,nwnk])
				lValid := .T.
				Exit
			Endif
		Next
	Endif
Next
If !lValid .and. !lTudook
	lValid := .T.
Endif
//If Len(aCols) > 1
//	lValid := .T.
//Endif

If lValid
	For nwnk := 1 to Len(aCols)
		If !aCols[nwnk,Len(aCols[nwnk])] .and. nwnk <> n .and.;
			aCols[nwnk,nPos] == aCols[n,nPos] .and. !aCols[n,Len(aCols[n])]
			If nPos2>0 .and. nPos3>0
				If aCols[nwnk,nPos]+aCols[nwnk,nPos2]+aCols[nwnk,nPos3] == aCols[n,nPos]+aCols[n,nPos2]+aCols[n,nPos3]
					Help(" ",1,"EXISTCHAV")
					Return (.F.)
				Endif
			Endif
		Endif
		If !aCols[nwnk,Len(aCols[nwnk])] .and. Empty(aCols[nwnk,nPos])
			If nPos2>0
				If Empty(aCols[nwnk,nPos2])
					Help(" ",1,"OBRIGAT")
					Return (.F.)
				Endif
			Endif
			Help(" ",1,"OBRIGAT")
			Return (.F.)
		Endif
	Next
	If !FG_OBRIGAT()
		Return .F.
	Endif
Endif
Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOA280TUDOKบAutor  ณRicardo Farinelli   บ Data ณ  10/23/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a Tela Toda digitada                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OA280TUDOK()
Local nwnk2
If !Inclui .and. !Altera
	Return .T.
Endif
For nwnk2 := 1 To Len(aCols)
	If !OA280LINOK(nwnk2,.T.)
		Return (.F.)
	Endif
Next
Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MenuDef  บ Autor ณ Thiago 			 บ Data ณ  13/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta aRotina ( MenuDef )           		                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := { {STR0001		,"AxPesqui"	, 0 , 1},; //Pequisar
					{STR0002	,"OFIOA280I", 0 , 2},; //Visualizar
					{STR0003	,"OFIOA280I", 0 , 3},; //Incluir
					{STR0004	,"OFIOA280I", 0 , 4},; 	//Alterar
					{STR0005	,"OFIOA280I", 0 , 5},; 	//Excluir
					{STR0017	,"OFIOA280G", 0 , 3}} 	//Gerar Agenda na Oficina ou CEV
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOFIOA280G บ Autor ณ Andre Luis Almeida บ Data ณ  15/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gerar Agenda na Oficina ou CEV                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOA280G()
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.F.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor := 0
Local nTam := 0
Local nDist:= 55 // distancia entre o get e o SAy
Local nLin := 11
////////////////////////////////////////////////////////////////////////////////////////////
Local ni := 0
Local nj := 0
Local nMax  := 42
Local cComb := ""
Private overde    := LoadBitmap( GetResources(), "BR_verde")
Private overmelho := LoadBitmap( GetResources(), "BR_vermelho")
Private dDtIni    := (dDataBase-day(dDataBase))+1
Private dDtFin    := dDataBase
Private aCampo    := {}
Private nCkRad1   := 1
Private nCkRad2   := 1
Private aGrp      := {}
Private aMod      := {}
Private cMarca    := space(3)
Private lMarcarV  := .t.
Private lA1_IBGE  := If(SA1->(FieldPos("A1_IBGE"))#0,.t.,.f.)
Private cTitulo   := ""
For ni := 1 to nMax
	Private &("cC"+strzero(ni,2)) := ""
	Private &("aR"+strzero(ni,2)) := {}
	Private &("cR"+strzero(ni,2)) := ""
Next
Private cObjSlv := ""
If type("cObjetiv") == "U"
	cObjetiv := ""
EndIf
cObjSlv := cObjetiv
ni := 0
dbSelectArea("SX3")
dbSetOrder(1)
DbSeek("VA8")
While !Eof() .And. (SX3->X3_ARQUIVO == "VA8")
	If X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .and. SX3->X3_TIPO="C" .and. SX3->X3_TAMANHO=1 .and. !Empty(X3CBOX())
		ni++
		If ni <= nMax
			&("cC"+strzero(ni,2)) := RetTitle(SX3->X3_CAMPO)
			aAdd(aCampo,{SX3->X3_CAMPO,RetTitle(SX3->X3_CAMPO)})
			nj := 0
			cComb := X3CBOX()
			aAdd(&("aR"+strzero(ni,2))," ")
			While len(cComb) > 1
				nj := If(at(";",cComb)==0,len(cComb)+1,at(";",cComb))
				aAdd(&("aR"+strzero(ni,2)),substr(cComb,1,nj-1))
				cComb := Alltrim(substr(cComb,nj+1,len(cComb)))
			EndDo
			&("cR"+strzero(ni,2)) := " "
		EndIf
	EndIf
	DbSelectArea("SX3")
	DbSkip()
EndDo
nMax := ni
FS_TIK(0) // Carrega Grupos e Modelos

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 20 , .T. , .F. } )  //Cabecalho
AAdd( aObjects, { 01, 138, .T. , .F. } )
AAdd( aObjects, { 01, 10 , .T. , .T. } )  //list box superior

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oAgOFI TITLE STR0018 From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL//Geracao das Listas de Contato para Agendamento

@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,1]+230 LABEL STR0019 OF oAgOFI PIXEL // "Periodo"
@ aPosObj[1,1]+008,aPosObj[1,2]+006 SAY STR0020 SIZE 100,10 OF oAgOFI PIXEL COLOR CLR_BLUE // "Referente a data da abertura da OS:"
@ aPosObj[1,1]+007,aPosObj[1,2]+108 MSGET oDtIni VAR dDtIni VALID(!Empty(dDtIni),FS_VAL280()) PICTURE "@D" SIZE 44,8 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+008,aPosObj[1,2]+158 SAY STR0021 SIZE 25,10 OF oAgOFI PIXEL COLOR CLR_BLUE // "ate"
@ aPosObj[1,1]+007,aPosObj[1,2]+171 MSGET oDtFin VAR dDtFin VALID(dDtFin>=dDtIni,FS_VAL280()) PICTURE "@D" SIZE 44,8 OF oAgOFI PIXEL COLOR CLR_BLUE

nTam := ( aPosObj[1,4] / 4 ) //varaivel que armazena o resutlado da divisao da tela.

@ aPosObj[2,1],aPosObj[2,2] TO aPosObj[2,3],aPosObj[2,4] LABEL STR0022 OF oAgOFI PIXEL // "Considerar"
// 1a.Coluna //
If nMax >= 1
	@ aPosObj[2,1]+(nLin*1),aPosObj[2,2]+(nTam*0)+010 SAY cC01 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*1)-1,aPosObj[2,2]+(nTam*0)+nDist MSCOMBOBOX oR01 VAR cR01 ITEMS aR01 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 2
	@ aPosObj[2,1]+(nLin*2),aPosObj[2,2]+(nTam*0)+010 SAY cC02 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*2)-1,aPosObj[2,2]+(nTam*0)+nDist MSCOMBOBOX oR02 VAR cR02 ITEMS aR02 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 3
	@ aPosObj[2,1]+(nLin*3),aPosObj[2,2]+(nTam*0)+010 SAY cC03 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*3)-1,aPosObj[2,2]+(nTam*0)+nDist MSCOMBOBOX oR03 VAR cR03 ITEMS aR03 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 4
	@ aPosObj[2,1]+(nLin*4),aPosObj[2,2]+(nTam*0)+010 SAY cC04 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*4)-1,aPosObj[2,2]+(nTam*0)+nDist MSCOMBOBOX oR04 VAR cR04 ITEMS aR04 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 5
	@ aPosObj[2,1]+(nLin*5),aPosObj[2,2]+(nTam*0)+010 SAY cC05 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*5)-1,aPosObj[2,2]+(nTam*0)+nDist MSCOMBOBOX oR05 VAR cR05 ITEMS aR05 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 6
	@ aPosObj[2,1]+(nLin*6),aPosObj[2,2]+(nTam*0)+010 SAY cC06 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*6)-1,aPosObj[2,2]+(nTam*0)+nDist MSCOMBOBOX oR06 VAR cR06 ITEMS aR06 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 7
	@ aPosObj[2,1]+(nLin*7),aPosObj[2,2]+(nTam*0)+010 SAY cC07 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*7)-1,aPosObj[2,2]+(nTam*0)+nDist MSCOMBOBOX oR07 VAR cR07 ITEMS aR07 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 8
	@ aPosObj[2,1]+(nLin*8),aPosObj[2,2]+(nTam*0)+010 SAY cC08 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*8)-1,aPosObj[2,2]+(nTam*0)+nDist MSCOMBOBOX oR08 VAR cR08 ITEMS aR08 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 9
	@ aPosObj[2,1]+(nLin*9),aPosObj[2,2]+(nTam*0)+010 SAY cC09 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*9)-1,aPosObj[2,2]+(nTam*0)+nDist MSCOMBOBOX oR09 VAR cR09 ITEMS aR09 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 10
	@ aPosObj[2,1]+(nLin*10),aPosObj[2,2]+(nTam*0)+010 SAY cC10 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*10)-1,aPosObj[2,2]+(nTam*0)+nDist MSCOMBOBOX oR10 VAR cR10 ITEMS aR10 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 11
	@ aPosObj[2,1]+(nLin*11),aPosObj[2,2]+(nTam*0)+010 SAY cC11 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*11)-1,aPosObj[2,2]+(nTam*0)+nDist MSCOMBOBOX oR11 VAR cR11 ITEMS aR11 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
// 2a.Coluna //
If nMax >= 12
	@ aPosObj[2,1]+(nLin*1),aPosObj[2,2]+(nTam*1)+010 SAY cC12 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*1)-1,aPosObj[2,2]+(nTam*1)+nDist MSCOMBOBOX oR12 VAR cR12 ITEMS aR12 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 13
	@ aPosObj[2,1]+(nLin*2),aPosObj[2,2]+(nTam*1)+010 SAY cC13 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*2)-1,aPosObj[2,2]+(nTam*1)+nDist MSCOMBOBOX oR13 VAR cR13 ITEMS aR13 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 14
	@ aPosObj[2,1]+(nLin*3),aPosObj[2,2]+(nTam*1)+010 SAY cC14 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*3)-1,aPosObj[2,2]+(nTam*1)+nDist MSCOMBOBOX oR14 VAR cR14 ITEMS aR14 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 15
	@ aPosObj[2,1]+(nLin*4),aPosObj[2,2]+(nTam*1)+010 SAY cC15 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*4)-1,aPosObj[2,2]+(nTam*1)+nDist MSCOMBOBOX oR15 VAR cR15 ITEMS aR15 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 16
	@ aPosObj[2,1]+(nLin*5),aPosObj[2,2]+(nTam*1)+010 SAY cC16 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*5)-1,aPosObj[2,2]+(nTam*1)+nDist MSCOMBOBOX oR16 VAR cR16 ITEMS aR16 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 17
	@ aPosObj[2,1]+(nLin*6),aPosObj[2,2]+(nTam*1)+010 SAY cC17 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*6)-1,aPosObj[2,2]+(nTam*1)+nDist MSCOMBOBOX oR17 VAR cR17 ITEMS aR17 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 18
	@ aPosObj[2,1]+(nLin*7),aPosObj[2,2]+(nTam*1)+010 SAY cC18 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*7)-1,aPosObj[2,2]+(nTam*1)+nDist MSCOMBOBOX oR18 VAR cR18 ITEMS aR18 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 19
	@ aPosObj[2,1]+(nLin*8),aPosObj[2,2]+(nTam*1)+010 SAY cC19 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*8)-1,aPosObj[2,2]+(nTam*1)+nDist MSCOMBOBOX oR19 VAR cR19 ITEMS aR19 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 20
	@ aPosObj[2,1]+(nLin*9),aPosObj[2,2]+(nTam*1)+010 SAY cC20 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*9)-1,aPosObj[2,2]+(nTam*1)+nDist MSCOMBOBOX oR20 VAR cR20 ITEMS aR20 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 21
	@ aPosObj[2,1]+(nLin*10),aPosObj[2,2]+(nTam*1)+010 SAY cC21 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*10)-1,aPosObj[2,2]+(nTam*1)+nDist MSCOMBOBOX oR21 VAR cR21 ITEMS aR21 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 22
	@ aPosObj[2,1]+(nLin*11),aPosObj[2,2]+(nTam*1)+010 SAY cC22 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*11)-1,aPosObj[2,2]+(nTam*1)+nDist MSCOMBOBOX oR22 VAR cR22 ITEMS aR22 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
// 3a.Coluna //
If nMax >= 23
	@ aPosObj[2,1]+(nLin*1),aPosObj[2,2]+(nTam*2)+010 SAY cC23 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*1)-1,aPosObj[2,2]+(nTam*2)+nDist MSCOMBOBOX oR23 VAR cR23 ITEMS aR23 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 24
	@ aPosObj[2,1]+(nLin*2),aPosObj[2,2]+(nTam*2)+010 SAY cC24 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*2)-1,aPosObj[2,2]+(nTam*2)+nDist MSCOMBOBOX oR24 VAR cR24 ITEMS aR24 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 25
	@ aPosObj[2,1]+(nLin*3),aPosObj[2,2]+(nTam*2)+010 SAY cC25 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*3)-1,aPosObj[2,2]+(nTam*2)+nDist MSCOMBOBOX oR25 VAR cR25 ITEMS aR25 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 26
	@ aPosObj[2,1]+(nLin*4),aPosObj[2,2]+(nTam*2)+010 SAY cC26 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*4)-1,aPosObj[2,2]+(nTam*2)+nDist MSCOMBOBOX oR26 VAR cR26 ITEMS aR26 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 27
	@ aPosObj[2,1]+(nLin*5),aPosObj[2,2]+(nTam*2)+010 SAY cC27 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*5)-1,aPosObj[2,2]+(nTam*2)+nDist MSCOMBOBOX oR27 VAR cR27 ITEMS aR27 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 28
	@ aPosObj[2,1]+(nLin*6),aPosObj[2,2]+(nTam*2)+010 SAY cC28 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*6)-1,aPosObj[2,2]+(nTam*2)+nDist MSCOMBOBOX oR28 VAR cR28 ITEMS aR28 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 29
	@ aPosObj[2,1]+(nLin*7),aPosObj[2,2]+(nTam*2)+010 SAY cC29 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*7)-1,aPosObj[2,2]+(nTam*2)+nDist MSCOMBOBOX oR29 VAR cR29 ITEMS aR29 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 30
	@ aPosObj[2,1]+(nLin*8),aPosObj[2,2]+(nTam*2)+010 SAY cC30 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*8)-1,aPosObj[2,2]+(nTam*2)+nDist MSCOMBOBOX oR30 VAR cR30 ITEMS aR30 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 31
	@ aPosObj[2,1]+(nLin*9),aPosObj[2,2]+(nTam*2)+010 SAY cC31 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*9)-1,aPosObj[2,2]+(nTam*2)+nDist MSCOMBOBOX oR31 VAR cR31 ITEMS aR31 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 32
	@ aPosObj[2,1]+(nLin*10),aPosObj[2,2]+(nTam*2)+010 SAY cC32 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*10)-1,aPosObj[2,2]+(nTam*2)+nDist MSCOMBOBOX oR32 VAR cR32 ITEMS aR32 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
// 4a.Coluna //
If nMax >= 33
	@ aPosObj[2,1]+(nLin*1),aPosObj[2,2]+(nTam*3)+010 SAY cC33 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*1)-1,aPosObj[2,2]+(nTam*3)+nDist MSCOMBOBOX oR33 VAR cR33 ITEMS aR33 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 34
	@ aPosObj[2,1]+(nLin*2),aPosObj[2,2]+(nTam*3)+010 SAY cC34 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*2)-1,aPosObj[2,2]+(nTam*3)+nDist MSCOMBOBOX oR34 VAR cR34 ITEMS aR34 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 35
	@ aPosObj[2,1]+(nLin*3),aPosObj[2,2]+(nTam*3)+010 SAY cC35 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*3)-1,aPosObj[2,2]+(nTam*3)+nDist MSCOMBOBOX oR35 VAR cR35 ITEMS aR35 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 36
	@ aPosObj[2,1]+(nLin*4),aPosObj[2,2]+(nTam*3)+010 SAY cC36 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*4)-1,aPosObj[2,2]+(nTam*3)+nDist MSCOMBOBOX oR36 VAR cR36 ITEMS aR36 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 37
	@ aPosObj[2,1]+(nLin*5),aPosObj[2,2]+(nTam*3)+010 SAY cC37 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*5)-1,aPosObj[2,2]+(nTam*3)+nDist MSCOMBOBOX oR37 VAR cR37 ITEMS aR37 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 38
	@ aPosObj[2,1]+(nLin*6),aPosObj[2,2]+(nTam*3)+010 SAY cC38 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*6)-1,aPosObj[2,2]+(nTam*3)+nDist MSCOMBOBOX oR38 VAR cR38 ITEMS aR38 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 39
	@ aPosObj[2,1]+(nLin*7),aPosObj[2,2]+(nTam*3)+010 SAY cC39 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*7)-1,aPosObj[2,2]+(nTam*3)+nDist MSCOMBOBOX oR39 VAR cR39 ITEMS aR39 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 40
	@ aPosObj[2,1]+(nLin*8),aPosObj[2,2]+(nTam*3)+010 SAY cC40 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*8)-1,aPosObj[2,2]+(nTam*3)+nDist MSCOMBOBOX oR40 VAR cR40 ITEMS aR40 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 41
	@ aPosObj[2,1]+(nLin*9),aPosObj[2,2]+(nTam*3)+010 SAY cC41 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*9)-1,aPosObj[2,2]+(nTam*3)+nDist MSCOMBOBOX oR41 VAR cR41 ITEMS aR41 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf
If nMax >= 42
	@ aPosObj[2,1]+(nLin*10),aPosObj[2,2]+(nTam*3)+010 SAY cC42 SIZE 60,09 OF oAgOFI PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+(nLin*10)-1,aPosObj[2,2]+(nTam*3)+nDist MSCOMBOBOX oR42 VAR cR42 ITEMS aR42 SIZE 45,09 OF oAgOFI PIXEL COLOR CLR_BLUE
EndIf

@ aPosObj[3,1],aPosObj[3,2] TO aPosObj[3,3],aPosObj[3,4] LABEL STR0023 OF oAgOFI PIXEL // "Veiculo"

@ aPosObj[3,1]+010,aPosObj[3,2]+010 RADIO oRadio1 VAR nCkRad1 3D SIZE 40,10 PROMPT OemToAnsi(STR0024),OemToAnsi(STR0025) OF oAgOFI PIXEL ON CHANGE FS_TIK(nCkRad1) // "Grupos" / "Modelos"

@ aPosObj[3,1]+010,aPosObj[3,2]+nDist LISTBOX oLbGrp FIELDS HEADER OemToAnsi(""),OemToAnsi(STR0026),OemToAnsi(STR0027),OemToAnsi(STR0028) COLSIZES 10,25,40,80 SIZE aPosObj[3,4]-62,aPosObj[3,3]-aPosObj[2,3]-016 OF oAgOFI PIXEL ON DBLCLICK FS_TIK(10) // "Marca" / "Grupo" / "Descricao"
oLbGrp:SetArray(aGrp)
oLbGrp:bLine := { || {If(aGrp[oLbGrp:nAt,1],overde,overmelho),;
aGrp[oLbGrp:nAt,2] ,;
aGrp[oLbGrp:nAt,3] ,;
aGrp[oLbGrp:nAt,4] }}
@ aPosObj[3,1]+010,aPosObj[3,2]+nDist LISTBOX oLbMod FIELDS HEADER OemToAnsi(""),OemToAnsi(STR0026),OemToAnsi(STR0029),OemToAnsi(STR0028) COLSIZES 10,25,40,80 SIZE aPosObj[3,4]-62,aPosObj[3,3]-aPosObj[2,3]-016 OF oAgOFI PIXEL ON DBLCLICK FS_TIK(20) // "Marca" / "Modelo" / "Descricao"
oLbMod:SetArray(aMod)
oLbMod:bLine := { || {If(aMod[oLbMod:nAt,1],overde,overmelho),;
aMod[oLbMod:nAt,2] ,;
aMod[oLbMod:nAt,3] ,;
aMod[oLbMod:nAt,4] }}

oLbMod:lVisible := .f.

@ aPosObj[3,1]+013,aPosObj[3,2]+56 CHECKBOX oMarcarV VAR lMarcarV PROMPT "" OF oAgOFI ON CLICK If( FS_TIKTUDO( lMarcarV ) , .t. , ( lMarcarV:=!lMarcarV , oMarcarV:Refresh() ) ) SIZE 07,05 PIXEL COLOR CLR_BLUE

@ aPosObj[3,3]-018,aPosObj[3,2]+007 BUTTON oIncluir  PROMPT OemToAnsi(STR0033) OF oAgOFI SIZE 40,10 PIXEL  ACTION (OA280LEG())

@ aPosObj[3,1]+040,aPosObj[3,2]+010 SAY oTitMarca VAR (STR0026+":") SIZE 55,10 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+050,aPosObj[3,2]+010 MSGET oMarca VAR cMarca VALID FS_TIK(9) F3 "VE1" PICTURE "@!" SIZE 20,8 OF oAgOFI PIXEL COLOR CLR_BLUE

DEFINE SBUTTON FROM aPosObj[1,1]+004,aPosObj[1,4]-60 TYPE 1 ACTION Processa( {|| FS_FILTRA() } ) ENABLE OF oAgOFI PIXEL
DEFINE SBUTTON FROM aPosObj[1,1]+004,aPosObj[1,4]-30 TYPE 2 ACTION oAgOFI:End() ENABLE OF oAgOFI PIXEL

ACTIVATE MSDIALOG oAgOFI

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VAL280 บ Autor ณ Andre Luis Almeida บ Data ณ  15/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Zera Campos de Calculo das Datas (periodo)                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VAL280()
Local lRet := .t.
// Zera Campos de Calculo das Datas (periodo)
If dDtIni > dDtFin
	dDtFin := dDtIni
EndIf
oDtFin:Refresh()
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TIK    บ Autor ณ Andre Luis Almeida บ Data ณ  15/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao do Radio		     			                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TIK(nTipo)
Local cQuery  := ""
Local cQAlias := "SQLTAB"
Do Case
	Case nTipo == 1 // nCkRad1 == 1
		oLbGrp:lVisible := .t.
		oLbMod:lVisible := .f.
	Case nTipo == 2 // nCkRad1 == 2
		oLbGrp:lVisible := .f.
		oLbMod:lVisible := .t.
	Case nTipo == 10
		If !Empty(aGrp[oLbGrp:nAt,2])
			aGrp[oLbGrp:nAt,1]:=!aGrp[oLbGrp:nAt,1]
		EndIf
	Case nTipo == 20
		If !Empty(aMod[oLbMod:nAt,2])
			aMod[oLbMod:nAt,1]:=!aMod[oLbMod:nAt,1]
		EndIf
	Case nTipo == 0 .or. nTipo == 9 // Inicial ou Filtra Marca
		aGrp := {}
		aMod := {}
		cQuery := "SELECT VVR.* FROM "+RetSqlName("VVR")+" VVR WHERE VVR.VVR_FILIAL='"+xFilial("VVR")+"' AND "
		If !Empty(cMarca)
			cQuery += "VVR.VVR_CODMAR='"+cMarca+"' AND "
		EndIf
		cQuery += "VVR.D_E_L_E_T_=' ' ORDER BY VVR.VVR_CODMAR , VVR.VVR_GRUMOD "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
		If !( cQAlias )->( Eof() )
			Do While !( cQAlias )->( Eof() )
				Aadd(aGrp,{ lMarcarV ,( cQAlias )->( VVR_CODMAR ),( cQAlias )->( VVR_GRUMOD ),( cQAlias )->( VVR_DESCRI )})
				( cQAlias )->( DbSkip() )
			EndDo
		Else
			Aadd(aGrp,{.f.,"","",""})
		EndIf
		( cQAlias )->( dbCloseArea() )
		cQuery := "SELECT VV2.* FROM "+RetSqlName("VV2")+" VV2 WHERE VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND "
		If !Empty(cMarca)
			cQuery += "VV2.VV2_CODMAR='"+cMarca+"' AND "
		EndIf
		cQuery += "VV2.D_E_L_E_T_=' ' ORDER BY VV2.VV2_CODMAR , VV2.VV2_MODVEI "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
		If !( cQAlias )->( Eof() )
			Do While !( cQAlias )->( Eof() )
				Aadd(aMod,{ lMarcarV ,( cQAlias )->( VV2_CODMAR ),( cQAlias )->( VV2_MODVEI ),( cQAlias )->( VV2_DESMOD )})
				( cQAlias )->( DbSkip() )
			EndDo
		Else
			Aadd(aMod,{.f.,"","",""})
		EndIf
		( cQAlias )->( dbCloseArea() )
		If nTipo == 9
			oLbGrp:nAt := 1
			oLbGrp:SetArray(aGrp)
			oLbGrp:bLine := { || {If(aGrp[oLbGrp:nAt,1],overde,overmelho),;
			aGrp[oLbGrp:nAt,2] ,;
			aGrp[oLbGrp:nAt,3] ,;
			aGrp[oLbGrp:nAt,4] }}
			oLbGrp:Refresh()
			oLbMod:nAt := 1
			oLbMod:SetArray(aMod)
			oLbMod:bLine := { || {If(aMod[oLbMod:nAt,1],overde,overmelho),;
			aMod[oLbMod:nAt,2] ,;
			aMod[oLbMod:nAt,3] ,;
			aMod[oLbMod:nAt,4] }}
			oLbMod:Refresh()
		EndIf
EndCase
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TIKTUDOบ Autor ณ Andre Luis Almeida บ Data ณ  15/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca todos				     			                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TIKTUDO( lMarcar )
Local ni := 0
Default lMarcar := .f.
For ni := 1 to Len(aGrp)
	If !Empty(aGrp[ni,3])
		aGrp[ni,1] := lMarcar
	EndIf
Next
For ni := 1 to Len(aMod)
	If !Empty(aMod[ni,3])
		aMod[ni,1] := lMarcar
	EndIf
Next
lMarcarV := lMarcar
oLbGrp:Refresh()
oLbMod:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FILTRA บ Autor ณ Andre Luis Almeida บ Data ณ  15/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Realiza filtro 			     			                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_FILTRA()
Local cQuery  := ""
Local cQuery1 := ""
Local cQuery2 := ""
Local cQAlias := "SQLVO1"
Local cCliente:= "INICIAL"
Local cSA1    := ""
Local cSA1Nome:= ""
Local cSA1Fone:= ""
Local cChassi := ""
Local aModAux := {}
Local aGrpAux := {}
Local nPos    := 0
Local ni      := 0
Local lOk     := .f.
Local aAux    := {}
Local cAux    := ""
Local aClientes := {}
cTitulo       := STR0030 // "Lista CheckList"
If nCkRad1 == 1
	For ni := 1 to len(aGrp)
		If aGrp[ni,1]
			Aadd(aGrpAux,{aGrp[ni,2]+aGrp[ni,3]})
		EndIf
	Next
Else // nCkRad1 == 2
	For ni := 1 to len(aMod)
		If aMod[ni,1]
			Aadd(aModAux,{aMod[ni,2]+aMod[ni,3]})
		EndIf
	Next
EndIf
cNFilt := left(STR0030+" "+Transform(dDataBase,"@D")+space(30),30) // "Lista CheckList"
ProcRegua(4)
IncProc( STR0031 ) // "Levantando CheckList..."

// Objetivo //
cObjetiv := cObjSlv+CHR(13)+CHR(10)
cObjetiv += STR0020+" "+Transform(dDtIni,"@D")+" "+STR0021+" "+Transform(dDtFin,"@D")+CHR(13)+CHR(10) // Referente a data da abertura da OS: / ate

cQuery := "SELECT VO1.VO1_DATABE , VO1.VO1_PROVEI , VO1.VO1_LOJPRO , VV1.VV1_CHASSI , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VA8.* FROM "+RetSqlName("VO1")+" VO1 , "+RetSqlName("VV1")+" VV1 , "+RetSqlName("VA8")+" VA8 WHERE "
cQuery += "VO1.VO1_FILIAL='"+xFilial("VO1")+"' AND VO1.VO1_DATABE>='"+dtos(dDtIni)+"' AND VO1.VO1_DATABE<='"+dtos(dDtFin)+"' AND VA8.VA8_FILIAL='"+xFilial("VA8")+"' AND VA8.VA8_NUMOSV=VO1.VO1_NUMOSV AND "
cQuery += "VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=VO1.VO1_CHAINT "
For ni:= 1 to len(aCampo)
	If !Empty(&("cR"+strzero(ni,2)))
		cQuery += "AND VA8."+aCampo[ni,1]+"='"+&("cR"+strzero(ni,2))+"' "
		aAux := aClone(&("aR"+strzero(ni,2)))
		cAux := left(&("cR"+strzero(ni,2)),1)
		nPos := aScan(aAux,cAux)
		If nPos > 0
			cObjetiv += Alltrim(&("cC"+strzero(ni,2)))+": "+aAux[nPos]+CHR(13)+CHR(10)
		EndIf
	EndIf
Next
cQuery += "AND VO1.D_E_L_E_T_=' ' AND VV1.D_E_L_E_T_=' ' AND VA8.D_E_L_E_T_=' ' "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
If !( cQAlias )->( Eof() )
	Do While !( cQAlias )->( Eof() )
		DbSelectArea("VCF")
		DbSetOrder(1)
		If DbSeek( xFilial("VCF") + ( cQAlias )->( VO1_PROVEI ) + ( cQAlias )->( VO1_LOJPRO ) )
			If !Empty(VCF->VCF_BLOQAG)
				( cQAlias )->( DbSkip() )
				Loop
			EndIf
		EndIf
		nPos := 0
		If nCkRad1 == 1
			DbSelectArea("VV2")
			DbSetOrder(1)
			DbSeek( xFilial("VV2") + ( cQAlias )->( VV1_CODMAR ) + ( cQAlias )->( VV1_MODVEI ) )
			nPos := aScan(aGrpAux, {|x| x[1] == ( cQAlias )->( VV1_CODMAR ) + VV2->VV2_GRUMOD })
		Else // nCkRad1 == 2
			nPos := aScan(aModAux, {|x| x[1] == ( cQAlias )->( VV1_CODMAR ) + ( cQAlias )->( VV1_MODVEI ) })
		EndIf
		If nPos == 0
			( cQAlias )->( DbSkip() )
			Loop
		EndIf
		If cSA1 # ( cQAlias )->( VO1_PROVEI ) + ( cQAlias )->( VO1_LOJPRO )
			cSA1 := ( cQAlias )->( VO1_PROVEI ) + ( cQAlias )->( VO1_LOJPRO )
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + cSA1 )
			cSA1Nome := SA1->A1_NOME
			cSA1Fone := ""
			If lA1_IBGE
				DbSelectArea("VAM")
				DbSetOrder(1)
				DbSeek( xFilial("VAM") + SA1->A1_IBGE )
				cSA1Fone := "("+VAM->VAM_DDD+") "
			EndIf
			cSA1Fone += Alltrim(SA1->A1_TEL)
		EndIf
		Aadd(aClientes,{.t. ,;
						Transform(stod(( cQAlias )->( VO1_DATABE )),"@D") ,;
						( cQAlias )->( VO1_PROVEI ) ,;
						( cQAlias )->( VO1_LOJPRO ) ,;
						cSA1Nome ,;
						cSA1Fone ,;
						( cQAlias )->( VV1_CHASSI ) ,;
						"" ,;
						"" ,;
						0 ,;
						0 ,;
						0 ,;
						0 ,;
						0 ,;
						0 ,;
						0 })
		( cQAlias )->( DbSkip() )
	EndDo
EndIf
( cQAlias )->( dbCloseArea() )
IncProc( STR0032 ) // "Finalizando..."
OFIOM410CLI(aClientes,cTitulo)
IncProc( STR0032 ) // "Finalizando..."'
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOA280LEG  บ Autor ณ Andre Luis Almeida บ Data ณ  15/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Legenda	     			     			                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OA280LEG()
Local cCadastro := ""
Local aLegenda := { {"BR_VERDE",STR0034},{"BR_VERMELHO",STR0035}} //Produtivo # Nao Produtivo

BrwLegenda(cCadastro,STR0010 ,aLegenda) //Legenda
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOA280VAL  บ Autor ณ Thiago 			 บ Data ณ  13/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao da OS.			     			                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OA280VAL()
dbSelectArea("VO1")
dbSetOrder(1)
if dbSeek(xFilial("VO1")+M->VA8_NUMOSV)
	M->VA8_PLAVEI := VO1->VO1_PLAVEI
Endif
Return(.t.)