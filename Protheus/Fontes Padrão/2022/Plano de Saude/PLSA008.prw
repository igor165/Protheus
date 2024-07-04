#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include 'PLSA008.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PLSA008  ³ Autor ³Fábio S. dos Santos	³ Data ³12/08/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela de cadastro de Perfil de acesso menu do Portal        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TOTVS - SIGAPLS			                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA008()
Local oDlgPer 
Local aCpoB7I		:= {"B7I_CODSEQ","B7I_DESCRI","B7I_TIPPOR","B7I_CODPOR","B7I_DATCRI"}
Local nOpcPer		:= 0
Local nCont			:= 0
Private oGetB7I, oEncGbj, oFolder1, oFolder2, oSim, oNao, oAcesso
Private aAcesso		:= {}
Private aLocais		:= {}
Private aDadosAux	:= {}
Private aHeadB7I 	:= {}
Private aColsB7I	:= {} 
Private aAuxAce		:= {}
Private nPosCodSeq	:= 0 
Private nPosDescri	:= 0 
Private nPosTIPPOR	:= 0 
Private nPosCODPOR	:= 0
Private nPosDATCRI	:= 0

oSim   := LoadBitmap(GetResources(), "BR_VERDE")
oNao   := LoadBitmap(GetResources(), "BR_VERMELHO")

If MsgYesNo(STR0020,STR0021) //Deseja atualizar os menus dos perfis?#Atenção
	Processa({||PLS08ATMN()},STR0022,STR0023) //Atualização de Menus#Atualizando Menus...Aguarde!
EndIf

DEFINE MSDIALOG oDlgPer Title OemToAnsi(STR0001/*"Permissões"*/) From 120,000 TO 650,430 OF oMainWnd Pixel
                                                          
HS_BDados("B7I", @aHeadB7I, @aColsB7I,, 1,, "",,,,,,,,,,,,,,,aCpoB7I ,,,,)
nPosCodSeq := aScan(aHeadB7I, {|aVet| aVet[2] == "B7I_CODSEQ"})
nPosDescri := aScan(aHeadB7I, {|aVet| aVet[2] == "B7I_DESCRI"})
nPosTIPPOR := aScan(aHeadB7I, {|aVet| aVet[2] == "B7I_TIPPOR"})
nPosCODPOR := aScan(aHeadB7I, {|aVet| aVet[2] == "B7I_CODPOR"})
nPosDATCRI := aScan(aHeadB7I, {|aVet| aVet[2] == "B7I_DATCRI"})

DbSelectArea("B7J")
DbSetorder(1)
If DbSeek(xFilial("B7J") + aColsB7I[1,nPosCodSeq])
	While !B7J->(Eof()) .And. B7J->B7J_CODPER == aColsB7I[1,nPosCodSeq] 		
		aAdd(aAcesso,{IiF(B7J->B7J_PERACE == "1", "S","N"), Posicione("AI8",1,xFilial("AI8")+ aColsB7I[1,nPosCODPOR] + B7J->B7J_CODMNU,"AI8_TEXTO"), B7J->B7J_CODMNU, aColsB7I[1,nPosCodSeq], aColsB7I[1,nPosCODPOR]}) 
		B7J->(DbSkip())
	End
EndIf

If Len(aAcesso) < 1
	aColsB7I[1][aScan(aHeadB7I,{|x| Trim(x[2])=="B7I_CODSEQ"})] := "000001"	 
	aAdd(aAcesso,{"N", "", "", "", ""}) 
EndIf

@ 35, 05 FOLDER oFolder1 SIZE 207, 090  OF oDlgPer PIXEL PROMPTS "Informe um Perfil" /*"Permissões"*/
oGetB7I := MsNewGetDados():New(35, 10, 95, 205, GD_UPDATE + GD_DELETE + GD_INSERT,,,"+B7I_CODSEQ",,,999999,,,,oFolder1, aHeadB7I, aColsB7I)
oGetB7I:bChange := {|| PLSVERACE() }
oGetB7I:oBrowse:bGotFocus := {|| PLSVERACE() }
oGetB7I:bDelOk := {|| PLSDELLIN() }

@ 130, 05 FOLDER oFolder2 SIZE 207, 130  OF oDlgPer PIXEL PROMPTS STR0001 /*"Permissões"*/
@ 05, 10 LISTBOX oAcesso FIELDS HEADER "", STR0002/*"Processos"*/ FIELDSIZES 15,170 SIZE 180,085 PIXEL OF oFolder2:aDialogs[1] 
oAcesso:SetArray(aAcesso)
oAcesso:bLine := {|| {Iif(aAcesso[oAcesso:nAt,1]== "S",oSim,oNao),aAcesso[oAcesso:nAt,2]}}
oAcesso:bLDblClick := {|| aAcesso[oAcesso:nAt,1]:= Iif(aAcesso[oAcesso:nAt,1]=="S","N","S"),oAcesso:DrawSelect(),PLSGRVACES()}

@ 95, 035 BitMap NAME "BR_VERMELHO" SIZE 8, 8 NOBORDER Of oFolder2:aDialogs[1] PIXEL
@ 95, 045 Say STR0003 /*"Acesso Negado"*/ Of oFolder2:aDialogs[1] PIXEL 

@ 95, 105 BitMap NAME "BR_VERDE" SIZE 8, 8 NOBORDER Of oFolder2:aDialogs[1] PIXEL
@ 95, 115 Say STR0004 /*"Acesso Liberado"*/ Of oFolder2:aDialogs[1] PIXEL

ACTIVATE MSDIALOG oDlgPer CENTERED ON INIT EnchoiceBar(oDlgPer, {|| nOpcPer := 1, oDlgPer:End() }, {|| oDlgPer:End(),nOpcPer := 0},,)

If nOpcPer == 1
	PLSGRVACES(.T.)
EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PLSVERACE  ³ Autor ³ Fábio S. dos Santos   ³ Data ³13/08/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica o código do portal e carrego na grid.				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TOTVS - SIGAPLS                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVERACE(cCodPor)
Local nPos			:= 0 
Local nCont  		:= 0
        
Default cCodPor		:= Space(6) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se já tem dados gravados pra carrregar a grid dos acessos                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
B7J->(DbSetOrder(1))
If B7J->(DbSeek(xFilial("B7J") + oGetB7I:aCols[oGetB7I:nAt,nPosCODSEQ]))
	aAcesso := {}
	While !B7J->(Eof()) .And. B7J->B7J_CODPER == oGetB7I:aCols[oGetB7I:nAt,nPosCODSEQ] 		
		aAdd(aAcesso,{IiF(B7J->B7J_PERACE == "1", "S","N"), Posicione("AI8",1,xFilial("AI8")+ oGetB7I:aCols[oGetB7I:nAt,nPosCODPOR] + B7J->B7J_CODMNU,"AI8_TEXTO"), B7J->B7J_CODMNU, oGetB7I:aCols[oGetB7I:nAt,nPosCODSEQ], oGetB7I:aCols[oGetB7I:nAt,nPosCODPOR]}) 
		B7J->(DbSkip())
	End
	oAcesso:SetArray(aAcesso)
	oAcesso:bLine := {|| {Iif(aAcesso[oAcesso:nAt,1]== "S",oSim,oNao),aAcesso[oAcesso:nAt,2]}}
	oAcesso:Refresh() 
Else
	If Len(aAuxAce) > 0 //Array com os itens que foram alterados 
		For nCont := 1 To Len(aAuxAce)
			If (nPos := aScan(aAuxAce[nCont], {|aVet| aVet[4] == oGetB7I:aCols[oGetB7I:nAt,nPosCODSEQ] .AND. aVet[5] == oGetB7I:aCols[oGetB7I:nAt,nPosCODPOR]})) > 0 //codigo sequencial e codigo portal
				nTamArray := Len(aAuxAce[nCont])
				aAcesso := {}
				While aAuxAce[nCont,nPos,4] == oGetB7I:aCols[oGetB7I:nAt,nPosCODSEQ] .And. aAuxAce[nCont,nPos,5] == oGetB7I:aCols[oGetB7I:nAt,nPosCODPOR]
					aAdd(aAcesso, {aAuxAce[nCont,nPos,1], aAuxAce[nCont,nPos,2], aAuxAce[nCont,nPos,3], aAuxAce[nCont,nPos,4], aAuxAce[nCont,nPos,5]})  
					nPos ++
					If nPos > nTamArray
						Exit
					EndIf 
				End
				oAcesso:SetArray(aAcesso)
				oAcesso:bLine := {|| {Iif(aAcesso[oAcesso:nAt,1]== "S",oSim,oNao),aAcesso[oAcesso:nAt,2]}}
				oAcesso:Refresh()
				Exit
			EndIf
		Next nCont
	EndIf
	If nPos == 0 //caso incluiu um perfil novo e não alterou
		AI8->(DbSetOrder(1))
		If AI8->(DbSeek(xFilial("AI8")+Iif(Empty(AllTrim(cCodPor)),oGetB7I:aCols[oGetB7I:nAt,nPosCODPOR],cCodPor)))//mudou de linha e/ou entrou na rotina, cCodPor = gatilho (editou o campo tipo de portal)
			aAcesso := {}
			While !AI8->(Eof()) .And. AI8->AI8_PORTAL == Iif(Empty(AllTrim(cCodPor)),oGetB7I:aCols[oGetB7I:nAt,nPosCODPOR],cCodPor)
				If !Empty(AI8->AI8_CODPAI)
					aAdd(aAcesso,{"S",AI8->AI8_TEXTO,AI8->AI8_CODMNU,oGetB7I:aCols[oGetB7I:nAt,nPosCODSEQ], Iif(Empty(AllTrim(cCodPor)),oGetB7I:aCols[oGetB7I:nAt,nPosCODPOR],cCodPor)})
				EndIf
			AI8->(DbSkip())
			End 
			//Pode ocorrer que na base temos um registro na AI8 sem código do Portal e código Pai, onde ocasionava erro ao abrir a rotina pela primeira vez.
			If (Len(aAcesso) < 1)
				aAdd(aAcesso, {"N", "", "", "", ""} )
			EndIf	
			oAcesso:SetArray(aAcesso)
			oAcesso:bLine := {|| {Iif(aAcesso[oAcesso:nAt,1]== "S",oSim,oNao),aAcesso[oAcesso:nAt,2]}}
			oAcesso:Refresh()
		Else
			aAcesso := {}
			aAdd(aAcesso,{"N", "", "", "", ""})	
			oAcesso:SetArray(aAcesso)
			oAcesso:bLine := {|| {Iif(aAcesso[oAcesso:nAt,1]== "S",oSim,oNao),aAcesso[oAcesso:nAt,2]}}
			oAcesso:Refresh()
		EndIf
	EndIf	
EndIf
If oGetB7I:aCols[oGetB7I:nAt,nPosTIPPOR] == "1"
	cCodPor := "000008"
ElseIf oGetB7I:aCols[oGetB7I:nAt,nPosTIPPOR] == "2" .Or. oGetB7I:aCols[oGetB7I:nAt,nPosTIPPOR] == "3" 
	cCodPor := "000010"
Else
	cCodPor := ""
EndIf 	 
Return(cCodPor)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PLSGRVACES ³ Autor ³ Fábio S. dos Santos   ³ Data ³13/08/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os acessos.											³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TOTVS - SIGAPLS                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSGRVACES(lGrav)
Local nI 	:= 0
Local nX 	:= 0
Local nPos	:= 0
Local lAchou	:= .F.
Local cTipOper	:= ""
Local nCont  	:= 0
Default lGrav := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se confirmou a gravação dos dados.								                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If lGrav
	For nX := 1 To Len(oGetB7I:aCols)
		If  !oGetB7I:aCols[nX,Len(aHeadB7I)+1] //verifica se deletou a linha
			DbSelectArea("B7I")
			DbSetOrder(1)
			If DbSeek(xFilial("B7I") + oGetB7I:aCols[nX,1] + oGetB7I:aCols[nX,3] + oGetB7I:aCols[nX,4])
				RecLock("B7I",.F.)
			Else
				RecLock("B7I",.T.)
			EndIf
			B7I->B7I_FILIAL := xFilial("B7I")
			B7I->B7I_CODSEQ := oGetB7I:aCols[nX,1]
			B7I->B7I_DESCRI := oGetB7I:aCols[nX,2]
			B7I->B7I_TIPPOR := oGetB7I:aCols[nX,3] 	
			B7I->B7I_CODPOR := oGetB7I:aCols[nX,4]
			B7I->B7I_DATCRI := oGetB7I:aCols[nX,5]
			MsUnLock()
			DbSelectArea("B7J")
			DbSetOrder(1)//B7J_FILIAL+B7J_CODPER+B7J_CODMNU+B7J_PERACE
			If (nPos := aScan(aAcesso, {|aVet| aVet[4] == oGetB7I:aCols[nX,1] .AND. aVet[5] == oGetB7I:aCols[nX,4]})) > 0 //array atual
				For nI := 1 To Len(aAcesso)
					If DbSeek(xFilial("B7J") + B7I->B7I_CODSEQ + aAcesso[nI,3])
						RecLock("B7J",.F.)
					Else
						RecLock("B7J",.T.)
					EndIf
					B7J->B7J_FILIAL := xFilial("B7J")
					B7J->B7J_CODPER := B7I->B7I_CODSEQ
					B7J->B7J_CODMNU := aAcesso[nI,3]
					B7J->B7J_PERACE := Iif(aAcesso[nI,1] == "S","1","2") 
					MsUnLock() 
				Next nI
			ElseIf Len(aAuxAce) > 0 //array alterado
				For nCont := 1 To Len(aAuxAce)
					If (nPos := aScan(aAuxAce[nCont], {|aVet| aVet[4] == oGetB7I:aCols[nX,1] .AND. aVet[5] == oGetB7I:aCols[nX,4]})) > 0 //codigo sequencial e codigo portal
						nTamArray := Len(aAuxAce[nCont])
						While aAuxAce[nCont,nPos,4] == oGetB7I:aCols[nX,1] .And. aAuxAce[nCont,nPos,5] == oGetB7I:aCols[nX,4]
							If DbSeek(xFilial("B7J") + B7I->B7I_CODSEQ + aAuxAce[nCont,nPos,3])
								RecLock("B7J",.F.)
							Else
								RecLock("B7J",.T.)
							EndIf
							B7J->B7J_FILIAL := xFilial("B7J")
							B7J->B7J_CODPER := B7I->B7I_CODSEQ
							B7J->B7J_CODMNU := aAuxAce[nCont,nPos,3]
							B7J->B7J_PERACE := Iif(aAuxAce[nCont,nPos,1] == "S","1","2") 
									
							MsUnLock()   
							nPos ++
							If nPos > nTamArray
								Exit
							EndIf 
						End
						Exit
					EndIf
				Next nCont	
			EndIf		
			If nPos == 0 //não teve alteração
				DbSelectArea("B7J")
				DbSetOrder(1)//B7J_FILIAL+B7J_CODPER+B7J_CODMNU+B7J_PERACE
				If !DbSeek(xFilial("B7J")+oGetB7I:aCols[nX,1])//se não encontrou, foi perfil adicionado e que não teve nenhum acesso alterado
					AI8->(DbSetOrder(1))
					If AI8->(DbSeek(xFilial("AI8")+oGetB7I:aCols[nX,4]))
						While !AI8->(Eof()) .And. AI8->AI8_PORTAL == oGetB7I:aCols[nX,4]
							If !Empty(AI8->AI8_CODPAI)
								RecLock("B7J",.T.)
								B7J->B7J_FILIAL := xFilial("B7J")
								B7J->B7J_CODPER := B7I->B7I_CODSEQ
								B7J->B7J_CODMNU := AI8->AI8_CODMNU
								B7J->B7J_PERACE := "1"
								MsUnlock()
							EndIf
							AI8->(DbSkip())
						End 
					EndIf
				EndIf
			EndIf
		Else
			DbSelectArea("B7I")
			DbSetOrder(1)
			If DbSeek(xFilial("B7I") + oGetB7I:aCols[nX,1] + oGetB7I:aCols[nX,3] + oGetB7I:aCols[nX,4])
				RecLock("B7I",.F.)
				Dbdelete()
				MsUnlock()
				DbSelectArea("B7J")
				DbSetOrder(1)
				If DbSeek(xFilial("B7J") + oGetB7I:aCols[nX,1])
					While !B7J->(Eof()) .And. B7J->B7J_CODPER == oGetB7I:aCols[nX,1]
						RecLock("B7I",.F.)
						Dbdelete()
						MsUnlock()
						B7J->(DbSkip())
					End
				EndIf
				DbSelectArea("B7H")
				DbSetOrder(1)
				If DbSeek(xFilial("B7H") + oGetB7I:aCols[nX,1])
					RecLock("B7H",.F.)
					B7H->B7H_FILIAL := xFilial("B7H")
					B7H->B7H_DATALT := dDatabase
					B7H->B7H_HORALT := Time()
					B7H->B7H_CODPER := oGetB7I:aCols[nX,1]
					B7H->B7H_DESPER	:= oGetB7I:aCols[nX,2]
					B7H->B7H_TIPOPE := "5"
					B7H->B7H_CODUSR	:= __cUserId
					MsUnlock()
				EndIf
			EndIf
		EndIf
		DbSelectArea("B7H")
		DbSetOrder(1)
		If DbSeek(xFilial("B7H") + B7I->B7I_CODSEQ)
			RecLock("B7H",.F.)
			cTipOper := "4"
		Else
			RecLock("B7H",.T.)
			cTipOper := "3"
		EndIf
		B7H->B7H_FILIAL := xFilial("B7H")
		B7H->B7H_DATALT := dDatabase
		B7H->B7H_HORALT := Time()
		B7H->B7H_CODPER := B7I->B7I_CODSEQ
		B7H->B7H_DESPER	:= B7I->B7I_DESCRI
		B7H->B7H_TIPOPE := cTipOper
		B7H->B7H_CODUSR	:= __cUserId
		MsUnlock()
	Next nX
Else
	If Len(aAuxAce) > 0 //verifica se gravou array com os acessos alterados e procura o acesso gravado pra alterar
		For nCont := 1 To Len(aAuxAce)
			If (nPos := aScan(aAuxAce[nCont], {|aVet| aVet[3] == aAcesso[oAcesso:nAt,3] .And. aVet[4] == aAcesso[oAcesso:nAt,4] .AND. aVet[5] == aAcesso[oAcesso:nAt,5]})) > 0 //codigo menu, sequencial e codigo portal
				aAuxAce[nCont,nPos,1] := aAcesso[oAcesso:nAt,1]
				lAchou := .T.
			EndIf
		Next nCont
		If !lAchou
			aAdd(aAuxAce,aClone(aAcesso))
		EndIf
	Else
		//caso não tenha alterado nenhum acesso, grava o array completo
		aAdd(aAuxAce,aClone(aAcesso))
	EndIf
EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PLSPERACE  ³ Autor ³ Fábio S. dos Santos   ³ Data ³18/08/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica o usuário e o código do perfil informado.			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPLS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPERACE(nOpc)
Local lRet		:= .T.
Local cQuery	:= ""
PutHelp("PPLSA008001",{STR0005 + " " + STR0006, STR0008, STR0013 + " " + STR0018 + " !"},{},{},.T.)
PutHelp("SPLSA008001",{STR0019,"",""},{},{},.T.) // "Informe um perfil de Empresa."

PutHelp("PPLSA008002",{STR0005 + " " + STR0006, STR0008, STR0013 + " " + STR0007 + " !"},{},{},.T.)
PutHelp("SPLSA008002",{STR0012,"",""},{},{},.T.) // "Informe um perfil de Beneficiário."

PutHelp("PPLSA008003",{STR0005 + " " + STR0018, STR0008, STR0013 + " " + STR0006 + " !"},{},{},.T.)
PutHelp("SPLSA008003",{STR0014,"",""},{},{},.T.) // "Informe um perfil de Prestador."

PutHelp("PPLSA008004",{STR0005 + " " + STR0018, STR0008, STR0013 + " " + STR0007 + " !"},{},{},.T.)
PutHelp("SPLSA008004",{STR0012,"",""},{},{},.T.) // "Informe um perfil de Beneficiário."

PutHelp("PPLSA008005",{STR0005 + " " + STR0007, STR0008, STR0013 + " " + STR0006 + " !"},{},{},.T.)
PutHelp("SPLSA008005",{STR0014,"",""},{},{},.T.) // "Informe um perfil de Prestador."

PutHelp("PPLSA008006",{STR0005 + " " + STR0007, STR0008, STR0013 + " " + STR0018 + " !"},{},{},.T.)
PutHelp("SPLSA008006",{STR0019,"",""},{},{},.T.) // "Informe um perfil de Empresa."

PutHelp("PPLSA008007",{STR0009,STR0010 + " !" , },{},{},.T.)
PutHelp("SPLSA008007",{STR0015,STR0016,STR0017},{},{},.T.) // "Inclua um novo perfil."###Ou desvincule esse perfil no Cadastro de###usuários do portal.

If nOpc == 1
	B7I->(DbSetOrder(1))
	If B7I->(DbSeek(xFilial("B7I")+M->BSW_PERACE))
		If B7I->B7I_TIPPOR == "1" .And. M->BSW_TPPOR <> "1" //PRESTADOR 
			lRet := .F.
			If M->BSW_TPPOR == "2"
				Help("",1,"PLSA008001")			
			Else
				Help("",1,"PLSA008002")	
			EndIf 
			
			//STR0005 = "O Perfil selecionado é de" 
			//STR0006 = "Prestador"
			//STR0008 = ", não pode ser utilizado neste usuário"
			//STR0013 = ", pois ele é um"
			//STR0007 = "Beneficiário"	
		ElseIf B7I->B7I_TIPPOR == "2" .And. M->BSW_TPPOR <> "2" //EMPRESA
			lRet := .F.
			If M->BSW_TPPOR == "1"
				Help("",1,"PLSA008003")			
			Else
				Help("",1,"PLSA008004")	
			EndIf 	
			//STR0005 = "O Perfil selecionado é de" 
			//STR0007 = "Beneficiário"
			//STR0008 = ", não pode ser utilizado neste usuário"
			//STR0013 = ", pois ele é um"
			//STR0018 = "Empresa"
		ElseIf B7I->B7I_TIPPOR == "3" .And. M->BSW_TPPOR <> "3" //BENEFICIARIO
			lRet := .F.
			If M->BSW_TPPOR == "1"
				Help("",1,"PLSA008005")			
			Else
				Help("",1,"PLSA008006")	
			EndIf 	
			//STR0005 = "O Perfil selecionado é de" 
			//STR0007 = "Beneficiário"
			//STR0008 = ", não pode ser utilizado neste usuário"
			//STR0013 = ", pois ele é um"
			//STR0006 = "Prestador"
		Else
			lRet := .T. 
		EndIf
	EndIf
ElseIf nOpc == 2

	cQuery := "SELECT * FROM " + RetSqlName("BSW") + " BSW "
	cQuery += "WHERE BSW.BSW_FILIAL = '" + xFilial("BSW") + "' AND "
	cQuery += "BSW_PERACE = '" + oGetB7I:aCols[oGetB7I:nAt,nPosCODSEQ] + "' AND "
	cQuery += "BSW.D_E_L_E_T_ = ''"
	cQuery += "ORDER BY BSW_FILIAL, BSW_CODUSR"
	
	If Select("TRBBSW") > 0
		TRBBSW->(DbCloseArea())
	EndIf
	
	TCQUERY cQuery NEW ALIAS "TRBBSW"
		
	TRBBSW->(DbGoTop())
	
	If TRBBSW->(Eof())
		lRet	:= .T.
	Else
		Help("",1,"PLSA008003")	
		lRet	:= .F.
	EndIf
	
EndIf

Return lRet   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PLSDELLIN  ³ Autor ³ Fábio S. dos Santos   ³ Data ³18/08/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica o usuário e o código do perfil informado.			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TOTVS - SIGAPLS                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSDELLIN()
Local lRet := .T.
Local cQuery := ""
PutHelp("PPLSA008008",{STR0009,STR0011 + " !" , },{},{},.T.)
PutHelp("SPLSA008008",{STR0015,STR0016,STR0017},{},{},.T.) // "Inclua um novo perfil."###Ou desvincule esse perfil no Cadastro de###usuários do portal.
cQuery := "SELECT * FROM " + RetSqlName("BSW") + " BSW "
cQuery += "WHERE BSW.BSW_FILIAL = '" + xFilial("BSW") + "' AND "
cQuery += "BSW_PERACE = '" + oGetB7I:aCols[oGetB7I:nAt,nPosCODSEQ] + "' AND "
cQuery += "BSW.D_E_L_E_T_ = ''"
cQuery += "ORDER BY BSW_FILIAL, BSW_CODUSR"

If Select("TRBBSW") > 0
	TRBBSW->(DbCloseArea())
EndIf

TCQUERY cQuery NEW ALIAS "TRBBSW"
	
TRBBSW->(DbGoTop())

If TRBBSW->(Eof())
	lRet	:= .T.
Else
	Help("",1,"PLSA008004")	
	lRet	:= .F.
EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PLSFILB7I  ³ Autor ³ Fábio S. dos Santos   ³ Data ³18/08/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtro da consulta padrão BSWB7I no campo BSW_PERACE.		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TOTVS - SIGAPLS                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSFILB7I()
Return(IF(M->BSW_TPPOR == '3',B7I->B7I_TIPPOR == '2', B7I->B7I_TIPPOR == '1') )                                                                                                                  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PLS08ATMN  ³ Autor ³ Fábio S. dos Santos   ³ Data ³20/02/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza os menus dos perfis de acordo com o AI8.			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TOTVS - SIGAPLS                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS08ATMN()
Local cQuery := ""

B7I->(DbSetOrder(1))
B7I->(DbSeek(xFilial("B7I")))

B7J->(DbSetOrder(1))
AI8->(DbSetOrder(1))

ProcRegua(AI8->(RecCount()))

While !B7I->(Eof())
	IncProc(STR0024)//"Processando menus incluídos..."
	
	If AI8->(DbSeek(xFilial("AI8")+B7I->B7I_CODPOR))
		While xFilial("B7I") == AI8->AI8_FILIAL .and. B7I->B7I_CODPOR == AI8->AI8_PORTAL 
			If !Empty(AI8->AI8_CODPAI) .And. (AI8->AI8_PORTAL == "000008" .Or. AI8->AI8_PORTAL == "000010")
				If !B7J->(DbSeek(xFilial("B7J")+B7I->B7I_CODSEQ+AI8->AI8_CODMNU))
					RecLock("B7J",.T.)
					B7J->B7J_FILIAL := xFilial("B7J")
					B7J->B7J_CODPER := B7I->B7I_CODSEQ
					B7J->B7J_CODMNU := AI8->AI8_CODMNU
					B7J->B7J_PERACE := "2" 
					MsUnLock() 
				EndIf	
			EndIf
			
			AI8->(DbSkip()) 
		End
	EndIf
	
	B7I->(DbSkip()) 
End

cQuery := "SELECT AI8_CODMNU FROM " + RetSqlName("AI8") + " AI8 "
cQuery += "WHERE AI8_FILIAL = '" + xFilial("AI8") + "' "
cQuery += "AND (AI8_PORTAL = '000008' OR AI8_PORTAL = '000010') "
cQuery += "AND D_E_L_E_T_ = '*' "

If Select("TRBAI8") > 0
	TRBAI8->(DbCloseArea())
EndIf
	
TCQUERY cQuery NEW ALIAS "TRBAI8"
		
TRBAI8->(DbGoTop())

ProcRegua(TRBAI8->(RecCount()))
TRBAI8->(DbGoTop())
While !TRBAI8->(Eof())
	IncProc(STR0025)//"Processando menus excluídos..."
	
	cQuery := "SELECT B7J.R_E_C_N_O_ AS REC FROM "+RetSQLName("B7J")+" B7J  WHERE B7J_FILIAL = '"+xFilial("B7J")+"' AND "
	cQuery += "B7J_CODMNU = '"+TRBAI8->AI8_CODMNU+"' AND B7J.D_E_L_E_T_ = ' ' "
	TCSQLExec(cQuery)
	TCQUERY cQuery NEW ALIAS "TRBB7J"

	While !TRBB7J->(Eof())
		B7J->(DbGoto(TRBB7J->(REC)))
		RecLock("B7J",.F.)
		B7J->(DbDelete())
		MsUnLock() 
		TRBB7J->(DbSkip())
	Enddo
	TRBB7J->(DbCloseArea())

	TRBAI8->(DbSkip())
End

Return