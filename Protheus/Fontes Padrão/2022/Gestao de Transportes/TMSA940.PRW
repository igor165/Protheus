#include "TMSA940.ch"
#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA0940 ³ Autor ³ Gustavo Almeida       ³ Data ³ 06/05/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grade Horario de Voo.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS 11.5                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSA940()

Private cCadastro := STR0001 //"Grade de Horario de Voo"
Private aRotina   := MenuDef()

If FindFunction('TMSChkVer') .And. !TMSChkVer('11','R5')
	Aviso(STR0031, STR0032 + Chr(10)+Chr(13) + STR0033, {STR0034}, 1) //"Versão Protheus" "Versão do sistema atual é inferior a 11.5" "Atualize o sistema!" "Ok"
	Return Nil
EndIf

dbSelectArea("DY6")
dbSetOrder(1)
dbGoTop()

mBrowse(06,01,22,75,"DY6")

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA940Mnt³ Autor ³ Gustavo Almeida       ³ Data ³06/05/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Interface do Cadastro de Grade de Voo.                      ³±±
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
Function TMSA940Mnt(cAlias, nReg, nOpcx)

Local aAreaDY7   := DY7->(GetArea())
Local nUsado     := 0
Local nOpcA      := 0
Local nPosAerDes := 0
Local nPosNomCia := 0
Local nPosNumVoo := 0
Local nPosTipVoo := 0
Local nCntFor    := 0
Local aPosObj    := {}
Local aObjects   := {}
Local aSize      := {}
Local aNoFields  := {}
Local aVisual    := {}
Local oDlg

Private aHeader  := {}
Private aCols    := {}
Private oEncD    := {}
Private oGetD    := {}
Private aColsBkp := {}
Private cCodReg  := ''

Aadd(aNoFields,"DY7_CODREG")
Aadd(aNoFields,"DY7_AERORI")

// Campo da Enchoice principal
RegToMemory("DY6", Inclui)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Array aHeader.                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader:= APBuildHeader("DY7", aNoFields)
nUsado:=Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Array aCols.                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Inclui
	DY7->(dbSetOrder(1)) //DY7_FILIAL+DY7_AERORI+DY7_ITEM
	DY7->(dbSeek(xFilial("DY7")+DY6->DY6_AERORI+DY6->DY6_CDRDES))

	While DY7->(!Eof()) .And. DY7->(DY7_FILIAL+DY7_AERORI+DY7_CODREG) == xFilial("DY7")+DY6->(DY6_AERORI+DY6_CDRDES) 

		Aadd(aCols,Array(nUsado+1))

		For nCntFor := 1 To nUsado
			If ( aHeader[nCntFor][10] != "V" )
				aCols[Len(aCols)][nCntFor] := DY7->(FieldGet(FieldPos(aHeader[nCntFor][2])))
			Else
				aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
			EndIf
		Next

		aCols[Len(aCols)][nUsado+1] := .F.
		DY7->(dbSkip())

	Enddo

	nPosAerDes := Ascan(aHeader,{|x| AllTrim(Upper(x[2])) == "DY7_AERDES"})
	nPosNomCia := Ascan(aHeader,{|x| AllTrim(Upper(x[2])) == "DY7_NOMCIA"})
	nPosNumVoo := Ascan(aHeader,{|x| AllTrim(Upper(x[2])) == "DY7_NUMVOO"})
	nPosTipVoo := Ascan(aHeader,{|x| AllTrim(Upper(x[2])) == "DY7_TIPVOO"})

	aCols := aSort( aCols,,, { | x , y | x[nPosAerDes]+x[nPosNomCia]+x[nPosNumVoo]+x[nPosTipVoo] < y[nPosAerDes]+y[nPosNomCia]+y[nPosNumVoo]+y[nPosTipVoo] } )

Else

	If Empty(aCols)
		Aadd(aCols,Array(nUsado+1))

		For nCntFor := 1 To nUsado
			aCols[1][nCntFor] := CriaVar(aHeader[nCntFor][2])
		Next nCntFor

		aCols[Len(aCols)][nUsado+1] := .F.

	EndIf

EndIf


If	Empty(GDFieldGet('DY7_ITEM',1))
	GDFieldPut('DY7_ITEM',StrZero(1,Len(DY7->DY7_ITEM)),1)
	aColsBkp := aClone(aCols)
EndIf

aSize   := MsAdvSize()
AAdd(aObjects,{020,020,.T.,.T.})

AAdd(aObjects,{080,080,.T.,.T.})
aInfo   := {aSize[1],aSize[2],aSize[3],aSize[4],5,5}
aPosObj := MsObjSize(aInfo,aObjects,.T.)

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 to aSize[6],aSize[5] Of oMainWnd PIXEL

	oEncD := MsMGet():New(cAlias,nReg,nOpcx,,,,aVisual,aPosObj[1],,nOpcx,,,,,,.T.)

	oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"TMSA940LOk()","TMSA940TOk()","+DY7_ITEM",.T.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, If(oGetd:TudoOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()})

If nOpcA == 1 .And. nOpcx <> 2
	Begin Transaction
		TMSA940Grv(nOpcx)
	End Transaction
EndIf

RestArea(aAreaDY7)

Return NIL

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA940LOk³ Autor ³ Gustavo Almeida       ³ Data ³06/05/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de digitacao de linha                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSA940LOk()
Local lRet := .T.

//Avalia se ao menos um dia está disponível para voo
If  GDFieldGet('DY7_SEMAN1',n) == "2" .And. GDFieldGet('DY7_SEMAN2',n) == "2" .And. GDFieldGet('DY7_SEMAN3',n) == "2" .And. GDFieldGet('DY7_SEMAN4',n) == "2" .And. ;
	GDFieldGet('DY7_SEMAN5',n) == "2" .And. GDFieldGet('DY7_SEMAN1',n) == "2" .And. GDFieldGet('DY7_SEMAN1',n) == "2"
	Help('',1,'TMSA94001') //"Ao menos um dia deve estar disponível para Voô"
	lRet := .F.
EndIf
If lRet
	//-- Nao avalia linhas deletadas.
	If	!GDDeleted( n )
		If lRet := MaCheckCols(aHeader,aCols,n)
			//-- Analisa se ha itens duplicados na GetDados.
			lRet := GDCheckKey( { "DY7_AERDES","DY7_CODCIA","DY7_LOJCIA","DY7_NUMVOO" }, 4 )
		EndIf
	EndIf
EndIf
Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA940TOk³ Autor ³ Gustavo Almeida       ³ Data ³06/05/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de confirmacao para gravacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ JAMEF                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSA940TOk()

Local lRet   := .T.

//-- Analisa se os campos obrigatorios da GetDados foram informados.
If	lRet
	lRet := oGetD:ChkObrigat( n )
EndIf

//-- Analisa o linha ok.
If lRet
	lRet := TMSA940LOk()
EndIf

//-- Analisa se todas os itens da GetDados estao deletados.
If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
	Help( ' ', 1, 'OBRIGAT2') //Um ou alguns campos obrigatorios nao foram preenchidos no Browse.
	lRet := .F.
EndIf

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA940Vld³ Autor ³ Gustavo Almeida       ³ Data ³06/05/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de digitacao de campos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSA940Vld(cCampo)

Local lRet    := .T.
Local cCodCia := ""
Local cLojCia := ""

Default cCampo  := AllTrim(Upper(ReadVar()))

If "DY6_AERORI" $ cCampo

	lRet := ExistCpo('SX5','M9'+M->DY6_AERORI,1)

	If lRet .And. !Empty(M->DY6_CDRDES) //-- Verifica se existe grade de voo cadastrada para o aeroporto de origem e região de destino.
		lRet := ExistChav('DY6',M->DY6_AERORI+M->DY6_CDRDES,1)
	EndIf

	If lRet
		M->DY6_NOMAER := Tabela('M9',M->DY6_AERORI,.F.)
	EndIf

ElseIf "DY6_CDRDES" $ cCampo 

	lRet := ExistCpo("DUY",M->DY6_CDRDES,1)

	If lRet .And. !Empty(M->DY6_CDRDES) //-- Verifica se existe grade de voo cadastrada para o aeroporto de origem e região de destino.
		lRet := ExistChav('DY6',M->DY6_AERORI+M->DY6_CDRDES,1)
	EndIf

	If lRet
		cCodReg := Iif(Empty(cCodReg), M->DY6_CDRDES, cCodReg)
		If cCodReg <> M->DY6_CDRDES
			If MsgYesNo( STR0002 )  //"Você optou por trocar o Codigo da Região. Essa alteração irá limpar os Aeroportos já selecionados. Continua? "
				aCols := aClone(aColsBkp)
				oGetD:Refresh()
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If lRet
		M->DY6_DESREG := Posicione("DUY",1,xFilial("DUY")+M->DY6_CDRDES,"DUY_DESCRI")
	EndIf

ElseIf "DY7_AERDES" $ cCampo

	If !TMSA940DD7(.T.)
		lRet := .F.
	EndIf

	If lRet
		GDFieldPut('DY7_NOMAER',Tabela('M9',M->DY7_AERDES,.F.))
	EndIf

ElseIf "DY7_CODCIA" $ cCampo .Or. "DY7_LOJCIA" $ cCampo 

	SA2->(DbSetOrder(1))
	aAreaSA2 := SA2->(GetArea())

	//-- Tratamento de variaveis não existentes
	If "DY7_CODCIA" $ cCampo
		cCodCia := M->DY7_CODCIA
		cLojCia := GDFieldGet('DY7_LOJCIA')
	Else
		cCodCia := GDFieldGet('DY7_CODCIA')
		cLojCia := M->DY7_LOJCIA
	EndIf

	If !Empty(cCodCia) .And. !Empty(cLojCia) .And. SA2->( MsSeek( xFilial("SA2") + cCodCia + cLojCia ))

		If Empty(SA2->A2_TIPAWB)
			lRet := .F.
			Help("",1,"TMSA32018",,cCodCia + " - " + cLojCia,5,1) //Tipo de AWB nao informado no cadastro de Fornecedores:
			Return(.F.)
		EndIf

	ElseIf !Empty(cCodCia) .And. !Empty(cLojCia) 
		Help('',1,'REGNOIS') //"Nao existe registro relacionado a este codigo"
		lRet := .F.
		RestArea(aAreaSA2)
	EndIf

	If lRet
		GDFieldPut('DY7_NOMCIA',SA2->A2_NOME)
	EndIf

ElseIf 'DY7_AERPAR' $ cCampo

	If M->DY7_AERPAR == GDFieldGet('DY7_AERDES') .Or. M->DY7_AERPAR == M->DY6_AERORI
		MsgAlert(STR0005,STR0004) //"Aeroporto de parada nao pode ser igual ao Aeroporto de Origem/Destino"###"Atenção!"
		lRet := .F.
	EndIf

ElseIf 'DY7_PRESAI' $ cCampo

	lRet := AtVldHora(M->DY7_PRESAI)

	If lRet .And. Space(1) $ M->DY7_PRESAI
		Help('',1,'TMSA36067') //"Hora Invalida !"
		lRet := .F.
	EndIf

ElseIf 'DY7_PRECHG' $ cCampo

	lRet := AtVldHora(M->DY7_PRECHG)

	If lRet .And. Space(1) $ M->DY7_PRECHG
		Help('',1,'TMSA36067') //"Hora Invalida !"
		lRet := .F.
	EndIf

ElseIf 'DY7_PRELIB' $ cCampo

	lRet := AtVldHora(M->DY7_PRELIB) 

	If lRet .And. Space(1) $ M->DY7_PRELIB
		Help('',1,'TMSA36067') //"Hora Invalida !"
		lRet := .F.
	EndIf

EndIf

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA940Grv³ Autor ³ Gustavo Almeida       ³ Data ³06/05/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Gravacao                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSA940Grv(nOpcx)

Local cSeekDY7   := ""
Local nI         := 0
Local nCnt       := 0
Local nCntFor1   := 0
Local nUsado     := Len(aHeader)

DY6->(DbSetOrder(1))
DY7->(DbSetOrder(2))

If nOpcx == 3 .Or. nOpcx == 4

	DbSelectArea("DY6")
	If DY6->(DbSeek(xFilial("DY6") + M->DY6_AERORI + M->DY6_CDRDES ))
		RecLock("DY6",.F.)
	Else
		RecLock("DY6",.T.)
	EndIf

	For nCntFor1 := 1 To FCount()
		If "FILIAL" $ Field(nCntFor1)
			FieldPut(nCntFor1,xFilial("DY6"))
		Else
			If Type("M->" + FieldName(nCntFor1)) <> "U"
				FieldPut(nCntFor1,M->&(FieldName(nCntFor1)))
			EndIf
		EndIf
	Next nCntFor1

	DY6->(MsUnLock())

	dbSelectArea("DY7")
	For nCnt := 1 To Len(aCols)
		If !GdDeleted(nCnt)
			If DY7->(!MsSeek(xFilial("DY7")+M->DY6_AERORI + M->DY6_CDRDES + GdFieldGet("DY7_AERDES",nCnt) + GdFieldGet("DY7_CODCIA",nCnt) + GdFieldGet("DY7_LOJCIA",nCnt) + GdFieldGet("DY7_NUMVOO",nCnt) + GdFieldGet("DY7_TIPVOO",nCnt)  ))
				RecLock("DY7",.T.)
				DY7->DY7_FILIAL := xFilial("DY7")
				DY7->DY7_AERORI := M->DY6_AERORI
				DY7->DY7_CODREG := M->DY6_CDRDES
				DY7->DY7_ITEM   := GdFieldGet("DY7_ITEM",nCnt)
			Else
				RecLock("DY7",.F.)
			EndIf
			For nI := 1 To nUsado
				If aHeader[nI,10] != 'V'
					DY7->(FieldPut(FieldPos(aHeader[nI,2]),GDFieldGet(aHeader[nI,2],nCnt)))
				EndIf
			Next
			MsUnlock()
		ElseIf DY7->(MsSeek(xFilial("DY7")+M->DY6_AERORI + M->DY6_CDRDES + GdFieldGet("DY7_AERDES",nCnt) + GdFieldGet("DY7_CODCIA",nCnt) + GdFieldGet("DY7_LOJCIA",nCnt) + GdFieldGet("DY7_NUMVOO",nCnt) + GdFieldGet("DY7_TIPVOO",nCnt)  ))
			RecLock("DY7",.F.)
			dbDelete()
			MsUnLock()
		EndIf
	Next nCnt

ElseIf nOpcx == 5
	cSeekDY7 := xFilial("DY7")+M->DY6_AERORI+M->DY6_CDRDES

	If DY7->(DbSeek(cSeekDY7))
		While DY7->(!Eof()) .And. DY7->(xFilial("DY7")+DY7->DY7_AERORI+DY7->DY7_CODREG ) == cSeekDY7
			RecLock("DY7",.F.)
			DY7->(dbDelete())
			DY7->(MsUnlock())
			DY7->(DbSkip())
		EndDo
	EndIf

	//-- Tipos de registro
	RecLock("DY6",.F.)
	DY6->(dbDelete())
	DY6->(MsUnlock())

EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TMSA940DD7 ³ Autor ³ Gustavo Almeida      ³ Data ³06/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza aeroportos da regiao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA940DD7()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA940DD7(lValida)
Local aAreaAtu   := DY7->(GetArea())
Local aItens     := {}
Local aNewButton := {}
Local cQuery     := ""
Local cRegiao    := ""
Local cCadastro  := STR0006 //"Escolha o Aeroporto"
Local cAliasQry  := GetNextAlias()
Local cCodReg    := M->DY6_CDRDES
Local aRegiao    := TMSNivSup(cCodReg) // Obtem os niveis superiores da regiao
Local lRet       := .T.
Local lCancel    := .T.
Local nCntFor    := 0

Private aTitulo  := {}

Default lValida  := .F.

DD7->(dbSetOrder(1))
If DD7->(!MsSeek(xFilial('DD7')+cCodReg))
	For nCntFor := 1 To Len(aRegiao)
		If !Empty(cRegiao)
			cRegiao += ", "
		EndIf
		cRegiao += "'"+aRegiao[nCntFor]+"'"
	Next nCntFor
Else
	cRegiao := "'"+cCodReg+"'"
EndIf

cQuery := " SELECT DD7_CODREG, DD7_CODAER, R_E_C_N_O_ DD7RECNO "
cQuery += "   FROM "+RetSqlName("DD7")
cQuery += "  WHERE DD7_FILIAL  = '"+xFilial("DD7")+"' " 
cQuery += "    AND DD7_CODREG IN ("+cRegiao+") "
cQuery += "    AND D_E_L_E_T_  = ' ' "
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )
While (cAliasQry)->(!Eof())
	Aadd(aItens,{ (cAliasQry)->DD7_CODAER, Tabela("M9",(cAliasQry)->DD7_CODAER,.F.), (cAliasQry)->DD7RECNO })
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbCloseArea())

If Len(aItens) > 0
	If lValida
		If Ascan(aItens,{ | e | e[1] == &("M->DY7_AERDES") }) == 0
			lRet := .F.
			Help('',1,'REGNOIS')
		EndIf
	Else

		Aadd( aTitulo, RetTitle('DD7_CODAER') )
		Aadd( aTitulo, RetTitle('DD7_NOMAER') )
		aCabec := aClone(aTitulo)

		AAdd(aNewButton, {15,{|nAt| TMSA940Vis(aItens[nAt,Len(aTitulo)+1],'DD7') } } )

		nRet := TmsF3Array( aTitulo, aItens, cCadastro, lCancel, aNewButton, aCabec )
		     // TmsF3Array( aHeadTms, aItemTms, cTitulo, lCancel, aNewButton, aCabec )

		If !Empty(nRet)
			DD7->(dbGoTo(aItens[nRet,Len(aTitulo)+1]))
		Else
			lRet := .F.
		EndIf

	EndIf
Else
	MsgAlert(STR0007 + AllTrim(cCodReg)) //"Não existem aeroportos relacionados a região "
	lRet := .F.
EndIf
RestArea(aAreaAtu)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA940Vis³ Autor ³ Gustavo Almeida    ³ Data ³  06/05/2011 ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para visualizar o cadastro de fornecedor            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA940Vis(nR,cA)

Local nRecno := nR
Local cAlias := cA
Local bInclui:= Inclui

If !Empty(cAlias) .And. nRecno > 0
	&(cAlias)->(dbGoTo(nRecno))
	AxVisual(cAlias,&(cAlias+"->(Recno())"),2)
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TMSA940Voo ³ Autor ³ Gustavo Almeida      ³ Data ³06/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exibe a grade de Voo                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA940Voo()

Local aAreaAtu := GetArea()
Local nI       := 0
Local nOpca    := 0
Local nAT      := 0
Local cTes     := ''

//-- ListBox
Local cLbx     := ''

//-- Controle de dimensoes de objetos
Local aObjects := {}
Local aInfo	   := {}
Local aPosObj  := {}
Local aSize	   := {}

//-- MsDialog
Local oDlgEsp

Local aCpoVld     := {}
Local aSetKeyOld  := {}
Local aButtons    := {}
Local aSemanas	   := {STR0008 , STR0009 , STR0010 , STR0011 , STR0012 , STR0013 , STR0014} //"Domingo"###"Segunda"###"Terça"###"Quarta"###"Quinta"###"Sexta"###"Sábado"

Private oLbxVoo
Private aVisErr   := {}
Private aComp     := {}
Private lTmpTrans := .F.

If INCLUI

	//-- Zera Teclas de Atalhos
	TmsKeyOff(aSetKey)

	//-- Variavel utilizado no PE TM320GRV
	If Type('_cObsTrans') == 'U'
		Public _cObsTrans := ''
	EndIf

	Aadd(aCpoVld, { M->DTV_NUMAWB, RetTitle('DTV_NUMAWB') })
	Aadd(aCpoVld, { M->DTV_VIAGEM, RetTitle('DTV_VIAGEM') })
	Aadd(aCpoVld, { M->DTV_CDRDES, RetTitle('DTV_CDRDES') })

	For nI := 1 To Len(aCpoVld)
		If Empty(aCpoVld[nI,1])
			MsgAlert(STR0015+AllTrim(aCpoVld[nI,2]),STR0004) //"Informe "###"Atenção!"
			Return Nil
		EndIf
	Next nI

	// funcao para calcular as cotacoes
	If Len(aComp) == 0
		Processa({|| CursorWait(), aComp := TMSA940Rec(), CursorArrow() },STR0016,STR0017,.F.) //"Elaborando Grade de Voo"###"Processando..."
	EndIf

	If Len(aComp) > 0


		//-- Realizado classificacao do aRet
		//----------------------------------
		//-- [17]-Dia da Semana 
		//-- [09]-Menor Hora de embarque 
		//-- [07]-Voo Direto
		//-- [07]-Voo com Escala
		//-- [07]-Voo com Conexao
		//-- [12]-Menor Preco
		aComp := ASort(aComp,,,{ | x, y | AllTrim(str(x[17])) + x[9] + x[7] + AllTrim(str(x[12])) < AllTrim(str(y[17])) + y[9] + y[7] + AllTrim(Str(y[12])) })

		//-- Calcula as dimensoes dos objetos
		aSize  := MsAdvSize( .T. )

		AAdd( aObjects, { 100, 60,.T.,.T. } )

		aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
		aPosObj:= MsObjSize( aInfo, aObjects,.T. )
		DEFINE MSDIALOG oDlgEsp TITLE STR0018 FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL  //"Grade de Voo"

				@ aPosObj[1,1], aPosObj[1,2] LISTBOX oLbxVoo VAR cLbx FIELDS HEADER	RetTitle('DTV_CODCIA') ,;    //01 
																						RetTitle('DY7_AERORI') ,;    //02
																						RetTitle('DY7_AERDES') ,;    //05
																						RetTitle('DY7_NUMVOO') ,;    //06
																						RetTitle('DY7_TIPVOO') ,;    //07
																						RetTitle('DY7_AERPAR') ,;    //08
																						STR0019                ,;    //17 //"Semana"
																						RetTitle('DY7_PRESAI') ,;    //09
																						RetTitle('DY7_PRECHG') ,;    //10
																						RetTitle('DY7_PRELIB') ,;    //11
																						RetTitle('DT6_VALFRE') ,;    //12
																						RetTitle('DTV_TABFRE') ,;    //13
																						RetTitle('DTV_TIPTAB') ,;    //14
																						RetTitle('DT0_DESTIP')  ;    //18
				SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1]-20 OF oDlgEsp ON DBLCLICK (.T.) PIXEL

				oLbxVoo:SetArray( aComp )

				oLbxVoo:bLine := { || {		aComp[ oLbxVoo:nAT, 5 ],;
											aComp[ oLbxVoo:nAT, 1 ],;
											aComp[ oLbxVoo:nAT, 2 ],;
											aComp[ oLbxVoo:nAT, 6 ],;
											aComp[ oLbxVoo:nAT, 7 ],;
											aComp[ oLbxVoo:nAT, 8 ],;
											aSemanas[ aComp[ oLbxVoo:nAT, 17 ] ],;
											TransForm(aComp[ oLbxVoo:nAT, 09 ], PesqPict('DY7','DY7_PRESAI')),;
											TransForm(aComp[ oLbxVoo:nAT, 10 ], PesqPict('DY7','DY7_PRECHG')),;
											TransForm(aComp[ oLbxVoo:nAT, 11 ], PesqPict('DY7','DY7_PRELIB')),;
											TransForm(aComp[ oLbxVoo:nAT, 12 ], PesqPict('DT8','DT8_VALTOT')),;
											aComp[ oLbxVoo:nAT, 15],;
											aComp[ oLbxVoo:nAT, 16],;
											aComp[ oLbxVoo:nAT, 18]}}

		ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||(nOpca := 1,nAT := oLbxVoo:nAT,oDlgEsp:End())},{||oDlgEsp:End()},,aButtons)

		If nOpca == 1 .And. TmsChkTES('5',@cTes)
			//-- Verifica se ja existe AWB para o fornecedor
			DTV->(dbSetOrder(1))
			If DTV->(MsSeek(xFilial("DTV") + M->DTV_NUMAWB)) .And. DTV->DTV_CODCIA + DTV->DTV_LOJCIA == aComp[nAT,3] + aComp[nAT,4]
				Help("",1,"TMSA32013",,aComp[nAT,3] + " - " + aComp[nAT,4], 5, 1) // AWB ja cadastrado para esse fornecedor.
			ElseIf Empty(aComp[nAT,14])
				Help("",1,"TMSA32016") //Condicao de Pagamento nao Informada no Cadastro do Fornecedor :                                          
			Else

				M->DTV_AERORI	:= aComp[nAT,01]
				M->DTV_AERDES	:= aComp[nAT,02]
				M->DTV_CODCIA	:= aComp[nAT,03]
				M->DTV_LOJCIA	:= aComp[nAT,04]
				M->DTV_NOMCIA	:= aComp[nAT,05]
				M->DTV_TABFRE	:= aComp[nAT,15]
				M->DTV_TIPTAB	:= aComp[nAT,16]
				aFrete			:= aComp[nAT,13]
				M->DTV_NUMVOO	:= aComp[nAT,06]

				If lTmpTrans
					While Empty(_cObsTrans)
						_cObsTrans := TMSA940Obs(_cObsTrans)
						If Empty(_cObsTrans)
							MsgAlert(STR0020,STR0004) //"É obrigatório informar o motivo por desprezar o tempo de translado."###"Atenção!"
						EndIf
					EndDo
					M->DTV_TMPTRA := '1' //-- 0=Utilizado;1=Desprezado
				Else
					M->DTV_TMPTRA := '0' //-- 0=Utilizado;1=Desprezado									
				EndIf

				//-- PE na opcao "Exibir Grade Voo" na Geracao de AWB para excutar rotinas especificas ou informar campos especificos.
				If ExistBlock("TMA940GRD")
					ExecBlock("TMA940GRD",.F.,.F.,{nAt})
				EndIf

				//-- Atualiza o vetor de composicao de frete.
				If Type('oLbx') == 'O'
					//-- Apresenta a composicao do frete
					TmsViewFrt('9')
					oLbx:Refresh()
				EndIf
			EndIf
		EndIf
	Else
		If Empty( aVisErr )
			Help('',1,'TMSA94002') //Não foi possível exibir a grade de vôo!
		Else
			TmsMsgErr( aVisErr )
		EndIf
	EndIf

	//-- Restaura Teclas de Atalhos
	TmsKeyOn(aSetKey)

EndIf
RestArea(aAreaAtu)
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TMSA940Rec ³ Autor ³ Gustavo Almeida      ³ Data ³06/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao utilizado para fazer calculo das cotacoes.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA940Res()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA940Rec(lRecalculo)

Local aAreaAtu  := GetArea()
Local aMsgErr   := {}
Local aVisErr   := {}
Local aFrtAWB   := {}
Local aRet      := {}
Local aContr    := {}
Local aRetBox   := RetSx3Box( GetSX3Cache("DY7_TIPVOO","X3_CBOX"),,, 1 )
Local cQuery    := ""
Local cCPos     := ""
Local cHorIni   := ""
Local cHorFim   := ""
Local cAliasQry := GetNextAlias()
Local cCdrOri   := Padr(SuperGetMv('MV_CDRORI',,''),Len(DUY->DUY_GRPVEN)) //Regiao de Origem
Local nI        := 0
Local nSeek     := 0
Local nTotReg   := 0
Local nSemIni   := 0
Local nSemFim   := 0
Local nSemAtu   := 0
Local nCount    := 0
Local nQtdVoo   := Int(SuperGetMv('MV_LIMVOO',,5)) //Quantidade de voos que poderao ser exibidos na tela de Grade de Voo.
Local lCont     := .F.
Local dDatIni   := CtoD("  /  /  ")
Local dDatFim   := CtoD("  /  /  ")
Local lTMA940REC:= ExistBlock("TMA940REC")
Local lTMA940ORI:= ExistBlock("TMA940ORI")
Local lRetPE    := .F.
Local cAux		:= ""

Default lRecalculo := .F.

lTmpTrans := MsgNoYes(STR0021,STR0004) //"Deseja desprezar o tempo de Translado?"###"Atenção!"

If lTmpTrans
	//-- Despresa tempo de translado
	dDatIni := dDatFim := Date()
	cHorIni := cHorFim := Left(Time(),5)

	//-- Calcula a data e hora prevista
	SomaDiaHor( @dDatFim, @cHorFim, 24 )
	nSemIni := Dow(dDatIni)
	nSemFim := Dow(dDatFim)
EndIf

aEval(DY7->(DbStruct()),{|e| IIf(!Empty(cCPos), cCPos += ", ",""), cCPos += "DY7." + AllTrim(e[1])})

If lTMA940ORI
	cAux	:= ExecBlock("TMA940ORI",.F.,.F.,{cCdrOri})
	If !Empty(cAux)
		cCdrOri	:= cAux
	EndIf
EndIf

cQuery := " SELECT " + cCPos + " , SA2.A2_COD, SA2.A2_LOJA, SA2.A2_TIPO, SA2.A2_NREDUZ, SA2.A2_COND, DY7.R_E_C_N_O_ DY7RECNO "

If (DD7->(FieldPos('DD7_TMPTRA')) > 0)
	cQuery += "  ,(  SELECT DD7_TMPTRA "
	cQuery += "        FROM " + RetSqlName("DD7") + " DD7 "
	cQuery += "       WHERE DD7_FILIAL = '"  + xFilial('DD7') + "' "
	cQuery += "         AND DD7_CODAER = DY7_AERORI "
	cQuery += "         AND DD7_CODREG = '" + cCdrOri + "'"
	cQuery += "         AND DD7.D_E_L_E_T_ = ' ' ) AS TMPTRAN "
EndIf
cQuery += "   FROM " + RetSqlName("DY7") + " DY7 "
cQuery += "   JOIN " + RetSqlName("SA2") + " SA2 "
cQuery += "     ON A2_FILIAL = '"+xFilial("SA2")+"'"
cQuery += "    AND A2_COD = DY7_CODCIA "
cQuery += "    AND A2_LOJA = DY7_LOJCIA "
cQuery += "    AND A2_TIPAWB <> ' ' "
cQuery += "    AND SA2.D_E_L_E_T_ = ' ' "

cQuery += "  WHERE DY7_FILIAL = '"+xFilial("DY7")+"' "
cQuery += "    AND DY7_AERORI IN ( SELECT DD7_CODAER "
cQuery += "                          FROM " + RetSqlName("DD7") + " DD7 "
cQuery += "                         WHERE DD7_FILIAL = '" + xFilial('DD7') + "'"
cQuery += "                           AND DD7_CODREG = '" + cCdrOri + "' "
cQuery += "                           AND DD7.D_E_L_E_T_ = ' ' ) "

cQuery += "    AND DY7_CODREG = '" + M->DTV_CDRDES + "' " 

If !Empty(M->DTV_CODCIA).And. !Empty(M->DTV_LOJCIA)
	cQuery += "    AND DY7_CODCIA = '" + M->DTV_CODCIA + "' " 
	cQuery += "    AND DY7_LOJCIA = '" + M->DTV_LOJCIA + "' "  
EndIf

If lTmpTrans
	cQuery += " AND ((DY7_SEMAN" + AllTrim(Str(nSemIni)) + " = '1' "
	cQuery += "       AND DY7_PRESAI BETWEEN '" + StrTran(cHorIni,':','') + "' AND '2400' ) "
	If nSemIni <> nSemFim
		cQuery += "     OR (DY7_SEMAN" + AllTrim(Str(nSemFim)) + " = '1' "
		cQuery += "         AND DY7_PRESAI BETWEEN '0000' AND '" + StrTran(cHorFim,':','') + "' ) "
	EndIf
	cQuery +=  "     ) "
Else
	nSemIni := nSemAtu := Dow(Date())
	cQuery += " AND ( "
	For nI := 1 To 7
		If nSemAtu == 8
			nSemAtu := abs(nSemAtu - 7)
		EndIf
		cQuery += "   (DY7_SEMAN" + AllTrim(Str(nSemAtu)) + " = '1' ) "
		nSemAtu++
		If nSemIni == nSemAtu
			cQuery += " ) "
			Exit
		Else
			cQuery += "  OR "
		EndIf
	Next nI
EndIf
cQuery += "    AND DY7.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

While (cAliasQry)->(!Eof())
	nTotReg++
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbGoTop())
ProcRegua(nTotReg,16,4)

dDatIni := Date()
cHorIni := Left(Time(),5)
nCount  := 0

While (cAliasQry)->(!Eof())

	IncProc()

	If !lTmpTrans .And. !Empty(nQtdVoo)
		If nCount >= nQtdVoo
			Exit
		EndIf
	EndIf

	nSemAtu := Dow(dDatIni+nCount)
	nCount++
	//--Verifica se esta no intervalo de exibição.
	If (DD7->(FieldPos('DD7_TMPTRA')) > 0) .And. !lTmpTrans
		cCampoAtu := "DY7_SEMAN"+AllTrim(Str(nSemAtu))
		If (cAliasQry)->&(cCampoAtu) == '1' .And. nSemAtu == Dow(Date()) //-- Verifica se campo DY7_SEMAN? é a semana corrente.
			//-- Calcula a data e hora prevista
			SomaDiaHor( @dDatIni, @cHorIni, HoraToInt(Transform((cAliasQry)->TMPTRAN, '@R 99:99')) )
			If (cAliasQry)->DY7_PRESAI <= StrTran(cHorIni,':','')
				(cAliasQry)->(dbSkip())
				Loop
			EndIf
		ElseIf (cAliasQry)->&(cCampoAtu) == '2'
			(cAliasQry)->(dbSkip())
			Loop
		EndIf
	EndIf
	//-- Filtro na Grade de Voo
	If lTMA940REC
		lRetPE := ExecBlock("TMA940REC",.F.,.F.,{(cAliasQry)->DY7RECNO})
		If ValType(lRetPE) == "L"
			If !lRetPE
				(cAliasQry)->(dbSkip())
				Loop
			EndIf
		EndIf
	EndIf
	//-- Verifica se o Fornecedor tem contrato
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura do Array aContr :                              ³
	//³ aContr[n][1] - No. do Contrato                           ³
	//³ aContr[n][2] - Tabela de Frete                           ³
	//³ aContr[n][3] - Tipo da Tabela                            ³
	//³ aContr[n][4] - Tabela de Carreteiro                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aContr := TMSContrFor((cAliasQry)->A2_COD,(cAliasQry)->A2_LOJA,,DTQ->DTQ_SERTMS,DTQ->DTQ_TIPTRA,.F.)
	If !Empty(aContr)
		For nI := 1 To Len(aContr)
			//-- Calcula a composicao do frete, baseado na tabela de frete informada
			lCont := .F.
			DVG->(DbSetOrder(1))
			DVG->( MsSeek( xFilial('DVG') + aContr[nI,1] ))
			While DVG->(!Eof()) .And. (DVG->DVG_FILIAL + DVG->DVG_NCONTR == xFilial('DVG') + aContr[nI,1] )
				If DVG->DVG_TABFRE + DVG->DVG_TIPTAB == aContr[nI,2] + aContr[nI,3]
					If DVG->DVG_GRDVOO == '1' //--Sim
						lCont := .T.
						Exit
					EndIf
				EndIf
				DVG->(dbSkip())
			EndDo

			If !lCont
				Loop
			EndIf

			aMsgErr:= {}
			aFrtAWB:= {}
			aFrtAWB:= TmsCalFret(	aContr[nI,2]	,;
									aContr[nI,3]	,;
													,;
									cCdrOri			,;
									M->DTV_CDRDES	,;
													,;
													,;
									M->DTV_CODPRO	,;
													,;
													,;
													,;
													,;
									@aMsgErr		,;
													,;
									M->DTV_VALMERC	,;
									Max(M->DTV_PESO,M->DTV_PESOM3),;
									0				,;
									0				,;
									M->DTV_QTDVOL 	,;
													,,,,,,,,,,,,,,,,,,,;
									M->DTV_PESO		,;
									M->DTV_PESOM3	,;
													,;
									M->DTV_VALMER	,;
									M->DTV_QTDVOL	,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,;
									DTQ->DTQ_FILORI ,;
									DTQ->DTQ_VIAGEM)
			nSeek := Ascan( aFrtAWB,{|x| x[3] == 'TF' })

			If	Empty( nSeek ) .Or. nSeek != Len(aFrtAWB)
				AAdd(aMsgErr,{STR0022+(cAliasQry)->A2_COD+'-'+(cAliasQry)->A2_LOJA+' '+STR0023,'00',''}) //"Fornecedor: "###"Falha na linha totalizadora da composicao do frete"
			ElseIf Empty( aFrtAWB[ nSeek, 2 ] )
				AAdd(aMsgErr,{STR0022+(cAliasQry)->A2_COD+'-'+(cAliasQry)->A2_LOJA+' '+STR0024,'00',''})  //"Fornecedor: "###"Tabela de frete nao encontrada"
			Else
				TmsA040Imp( aFrtAWB, M->DTV_CODCIA, M->DTV_LOJCIA, cDocTms, '1', M->DTV_CDRDES, .T., @nAlqICM, M->DTV_FILDES, (cAliasQry)->A2_TIPO )

				If lTmpTrans
					cCampoAtu := "DY7_SEMAN"+AllTrim(Str(nSemIni))
					If (cAliasQry)->&(cCampoAtu) == '1'
						nSemAtu := nSemIni
					Else
						cCampoAtu := "DY7_SEMAN"+AllTrim(Str(nSemFim))
						If(cAliasQry)->&(cCampoAtu) == '1'
							nSemAtu := nSemFim
						EndIf
					EndIf
				EndIf

				Aadd( aRet, {	(cAliasQry)->DY7_AERORI			, ;	//01 - Aeroporto Origem
								(cAliasQry)->DY7_AERDES			, ;	//02 - Aeroporto Destino
								(cAliasQry)->A2_COD				, ;	//03 - Codigo Cliente
								(cAliasQry)->A2_LOJA			, ;	//04 - Loja Cliente
								AllTrim((cAliasQry)->A2_NREDUZ)	, ;	//05 - Nome Cliente
								(cAliasQry)->DY7_NUMVOO			, ;	//06 - Numero Voo
								AllTrim(aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == (cAliasQry)->DY7_TIPVOO} ), 3 ]), ;	//07 - Tipo do Voo 1-Direto;2-Escala;3-Conexao
								(cAliasQry)->DY7_AERPAR			, ;	//08 - Aeroporto Parada
								(cAliasQry)->DY7_PRESAI			, ;	//09 - Hora Prevista Saida
								(cAliasQry)->DY7_PRECHG			, ;	//10 - Hora Prevista Chegada
								(cAliasQry)->DY7_PRELIB			, ;	//11 - Hora Prevista Liberacao
								aFrtAWB[ nSeek, 6 ]				, ;	//12 - Valor Frete
								AClone(aFrtAWB)					, ;	//13 - Calculo do Frete
								(cAliasQry)->A2_COND  			, ;	//14 - Condicao de Pagamento
								aContr[nI,2]					, ;	//15 - Tabela de Frete
								aContr[nI,3]					, ;	//16 - Tipo Tabela de Frete 01-RODOVIARIO/02 - AEREO
								nSemAtu							, ;	//17 - Semana Atual
								Tabela("M5", aContr[nI,3],.F.)	, ;	//18 - Tipo Tabela de Frete 01-RODOVIARIO/02 - AEREO
								dDatIni							, ; //19 - Data inicial
								dDatFim							} ) //20 - Data Final
			EndIf
			If !Empty(aMsgErr)
				AaddMsgErr( aMsgErr, @aVisErr)
			EndIf
		Next nI
	EndIf
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbCloseArea())

RestArea(aAreaAtu)

Return aClone(aRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA940Obs³ Autor ³ Gustavo Almeida       ³ Data ³06/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Observacao do cancelamento do translado da grade de voo    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA940Obs()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA940Obs(cObs,lInclui)

Local oDlgObs

Default cObs    := ''
Default lInclui := .T.

//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)

DEFINE MSDIALOG oDlgObs TITLE STR0025 FROM 15,20 TO 25,62 //"Motivo por desprezar tempo de translado"

	@ 0.5,0.7  GET oGet VAR cObs OF oDlgObs MEMO size 150,40 WHEN lInclui

	DEFINE SBUTTON FROM 52,128 TYPE 1 ACTION (oDlgObs:End()) ENABLE OF oDlgObs

ACTIVATE MSDIALOG oDlgObs CENTERED

//-- restaura Teclas de Atalhos
TmsKeyOn(aSetKey)

Return cObs

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA940Whe ³ Autor ³ Gustavo Almeida      ³ Data ³06/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do Campo DY7_AERPAR                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA940Whe()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA940Whe() 

Local lRet   := .T. 
Local cCampo := AllTrim( ReadVar() )

If cCampo == "M->DY7_AERPAR"
	lRet := ( GDFieldGet("DY7_TIPVOO") <> "1" ) //-- Direto	
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Gustavo Almeida       ³ Data ³06/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local  aRotina := {	{ STR0026,"TmsXPesqui" , 0, 1,0,.F. },; //"Pesquisar"
					{ STR0027,"TMSA940Mnt" , 0, 2,0,NIL },; //"Visualizar"
					{ STR0028,"TMSA940Mnt" , 0, 3,0,NIL },; //"Incluir"
					{ STR0029,"TMSA940Mnt" , 0, 4,0,NIL },; //"Alterar"
					{ STR0030,"TMSA940Mnt" , 0, 5,0,NIL } } //"Excluir"
Return(aRotina)
