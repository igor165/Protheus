#INCLUDE "TOTVS.CH"
#INCLUDE "QMTA141.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE OBJ_ESCALA      1                            
#DEFINE OBJ_PONTO       2
#DEFINE OBJ_MEDICAO_1   3 
#DEFINE OBJ_MEDICAO_2   4    

#DEFINE OBJ_MEDICAO_4   5
#DEFINE OBJ_OBSERVACAO  6
#DEFINE OBJ_MEDEXT      7
#DEFINE OBJ_PADSEC      8
#DEFINE OBJ_INSTUTIL    9
#DEFINE OBJ_NAOCONFOR  10
#DEFINE OBJ_INCERT_B   11
#DEFINE OBJ_MEDICAO_3  12 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140MoFirst³ Autor ³ Denis Martins	 	 ³ Data ³ 8/13/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta a estrutura do Folder 								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oDlg - Tela, oBtn - Botao Inv., nOpcx 					   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³                                                    		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140Inclui - Get do Repe/Repro 							   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Denis     ³ 21/02/02 ³ Acerto na construcao da getdados de medicoes 	   ³±±
±±³Denis     ³ 21/02/02 ³ Acerto nos display's das incertezas do tipo B e  ³±±  
±±³          ³          ³ gravacao correta dos laboratorios externos. 	   ³±±  
±±³Denis     ³ 04/03/02 ³ Apos delecao de uma calibracao, salvar a freq. e ³±±
±±³          ³          ³ data de afericao anterior.      				   ³±±
±±³Denis     ³ 15/03/02 ³ Melhora de Performance - Retirado Show/Hide das  ³±±
±±³          ³          ³ montagens de folders.           				   ³±±
±±³Denis     ³ 20/03/02 ³ Para escala com caracteristicas Variavel, recalcu³±±
±±³          ³          ³ lar os limites inferior/superior.(Qmt141VVar())  ³±±
±±³Denis     ³ 21/03/02 ³ Melhoria na rotina de impressao do label do labo-³±±
±±³          ³          ³ ratorio externo.                                 ³±±
±±³Denis     ³ 15/10/02 ³ Apos digitacao do primeiro laboratorio externo/  ³±±
±±³          ³          ³ nro certificado sugerir esses dados para as dema-³±±
±±³          ³          ³ is escalas(externas sem medicoes).               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140MoFirst(oDlgPri,oBtn,nOpcx,oSayD)
Local nx
Local cEscss  	:= ""
Local cPtos		:= ""
Local nPEscs	:= 0                 
Local nPPads	:= 0
Local nLin	:= 0 	
Private cBUtMed := GetNewPar("MV_QBNDMED", "1") 
DEFAULT lNaoObrigt := .T.

nLin := 10

//Monta todos os aheader's
MontaHea()

lAtributo := Upper(Alltrim(aMedicoes[nPosAmed,nPosGer,1,3])) == "A"
oBtn:Disable()                                         
oBtn:Hide()  
//oSayD:Disable()
//oSayD:Hide()

aTitEsc	:= {} 

nGot	:= 1 //Forca a primeira vez - primeiro folder

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Array com os padroes para a escala corrente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ALTERA .OR. INCLUI
	For nx := Len(aMedicoes) To 1 step -1

		IF (Posicione("QMR",1,xFilial("QMR")+cMtInstr+cMtRevIns+aMedicoes[nx,nPosEsc], 'QMR_CAOBRI') <> "S" .And. !lNaoObrigt)
		
			ADEL( aMedicoes, nx )
			ASIZE( aMedicoes, LEN(aMedicoes) - 1 )

		ENDIF	

	Next nx
ENDIF

For nx := 1 To Len(aMedicoes)

	cInsEsc := ""
	cInsEsc := A141InsEsc(cMtInstr,aMedicoes[nx,nPosEsc])

	If !Empty(cInsEsc) //Caso seja Escala/Instrumento Malha
		aMedicoes[nx][nPosCar] := aMedicoes[nx][nPosEsc]
		aMedicoes[nx][nPosEsc] := cInsEsc
	Endif	

	AADD(aEscPad,{aMedicoes[nx][nPosEsc],aMedicoes[nx][nPosPad]})
	If Ascan(aTitEsc,{|x| x == aMedicoes[nx][1]}) == 0
		Aadd(aTitEsc,aMedicoes[nx][nPosEsc])
	EndIf	

Next nx

If Len(aTitEsc) > 0
	@ 145-nLin,004	SAY OemToAnsi(STR0116) SIZE	61,15 OF oDlgPri PIXEL FONT oArialGr COLOR CLR_BLUE //Faixa(s) 61,15
	@ 145-nLin,161	SAY OemToAnsi(STR0117) SIZE	65,15 OF oDlgPri PIXEL FONT oArialGr COLOR CLR_BLUE //Padrao(oes) 85,15
	@ 145-nLin,066	COMBOBOX oCbxEsc	VAR	cEscal ITEMS aTitEsc SIZE 82,4 OF oDlgPri PIXEL  //75,55
	@ 145-nLin,056	BITMAP oBmpEsc		RESOURCE "BR_PRETO"  SIZE 10,15 NOBORDER OF oDlgPri PIXEL //75,45
	@ 145-nLin,226  BITMAP oBmpPad		RESOURCE "BR_PRETO"  SIZE 10,15 NOBORDER OF oDlgPri PIXEL //77,155

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Desenha o folder principal(controle) para referencia³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Aeval(aEscPad,{|x| Aadd(aFolder,NIL)})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza montagem dos padroes da primeira escala³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTitPad := {}

	Eval({||nGot := a140bStOption(),a140MontPad(oDlgPri,@oBmpEsc,nGot,@oBmpPad),oCbxPad:Refresh()})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Mostra resultado das Escalas / Padroes ao clicar nos respectivos botoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//	oBtnEsc:bAction := {|| nPosAnt := nPosAmed,a141ContrFld(nGot:=oFolderFix:nOption,oFolderFix:nOption,.F.),A140ShwEsc(oDlgPri,oBmpEsc,oBmpPad,oFolderFix)}
//	oBtnPad:bAction := {|| nPosAnt := nPosAmed,a141ContrFld(nGot:=oFolderFix:nOption,oFolderFix:nOption,.F.),A140ShwPad(oCbxEsc,oCbxPad,oFolderFix,oDlgPri),A141AprPad(oDlgPri,oBmpPad,oBmpEsc)} 

	nPosAmed   := Ascan(aMedicoes, { |x| Alltrim(x[1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt]) .and. Alltrim(x[2]) == Alltrim(oCbxPad:aItems[oCbxPad:nAt])})
	nPosEscPad := Ascan(aEscPad  , { |x| Alltrim(x[1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt]) .and. Alltrim(x[2]) == Alltrim(oCbxPad:aItems[oCbxPad:nAt])})

	oCbxEsc:SetFocus()  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza montagem de todos os folder's com seus respectivos objetos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	a140ShwITB(oFolderFix:aDialogs[7])
	a140ShwNco(oFolderFix:aDialogs[6])
	a140ShwIns(oFolderFix:aDialogs[5])
	a140ShwSec(oFolderFix:aDialogs[4]) //Folder Padrões Secundarios
	a140ShwExt(oFolderFix:aDialogs[3]) //Folder Medições Externas
	a140ShwObs(oFolderFix:aDialogs[2]) //Folder Observações
	a140ShwMed(oFolderFix:aDialogs[1]) //Folder Medições

	//Integridade - Permitir incluir/alterar as getdados
	If Inclui .or. Altera
		aObjetos[OBJ_PADSEC][2]:oBrowse:nOpc := 3
		aObjetos[OBJ_PADSEC][2]:Refresh()
		If aObjetos[OBJ_INSTUTIL] <> Nil
			aObjetos[OBJ_INSTUTIL][4]:oBrowse:nOpc := 3
			aObjetos[OBJ_INSTUTIL][4]:Refresh()
		Endif
		If aObjetos[OBJ_NAOCONFOR] <> Nil
			aObjetos[OBJ_NAOCONFOR][2]:oBrowse:nOpc := 3
			aObjetos[OBJ_NAOCONFOR][2]:Refresh()
		Endif
		If aObjetos[OBJ_INCERT_B] <> Nil	
			aObjetos[OBJ_INCERT_B][3]:oBrowse:nOpc := 3
			aObjetos[OBJ_INCERT_B][3]:Refresh()
		Endif	
	Else
		aObjetos[OBJ_PADSEC][2]:oBrowse:nOpc := 2
		aObjetos[OBJ_INSTUTIL][4]:oBrowse:nOpc := 2
		aObjetos[OBJ_NAOCONFOR][2]:oBrowse:nOpc := 2
		aObjetos[OBJ_INCERT_B][3]:oBrowse:nOpc := 2
	Endif
	
	oFolderFix:nOption := nGot
	oFolderFix:lReadOnly := .F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atribui valor a nPosAnt para poder salvar aCols corretamente e³
	//³se posiciona no folter atual                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oFolderFix:bSetOption :={|nAt|nPosAnt := nPosAmed,a141ContrFld(nGot:=nAt,oFolderFix:nOption)} //nGot      

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A cada mundanca no combo da escala deve-se:                      ³
	//³- Verificar a posicao do folter a qual estou posicionado;        ³
	//³- Atribuir valor da medicao atual para salvar aCols corretamente;³
	//³- Verificar se mudei de folder;                                  ³
	//³- Atualiza status da minha escala.								³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oCbxEsc:bChange:= {||nGot := a140bStOption(),nPosAnt := nPosAmed,a140MontPad(oDlgPri,@oBmpEsc,nGot,@oBmpPad),;
							oCbxPad:Refresh(),;
                            a141ChanFolder(),;
							a141AprEsc(oDlgPri,oBmpEsc,oBmpPad,Nil)}

	SetKey(VK_F8,{|| a140MudPad()}) 	

	SetKey(VK_F5,{|| If(Len(aMedicoes) > 0,(nPosAnt := nPosAmed,a141ContrFld(nGot:=oFolderFix:nOption,oFolderFix:nOption,.F.),A140ShwEsc(oDlgPri,oBmpEsc,oBmpPad,oFolderFix)),.F.)}) 	
	
	SetKey(VK_F6,{|| If(Len(aMedicoes) > 0,(nPosAnt := nPosAmed,a141ContrFld(nGot:=oFolderFix:nOption,oFolderFix:nOption,.F.),A140ShwPad(oCbxEsc,oCbxPad,oFolderFix,oDlgPri),A141AprPad(oDlgPri,oBmpPad,oBmpEsc)),.F.)}) 	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se existir o parametro MV_QBNDMED e o mesmo estiver com conteudo igual "1",   ³
	//³o sistema ira sugerir a primeira escala e primeiro padrao ainda nao digitado. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If cBUtMed == "1"
		If !Inclui 
			For nx := 1 To Len(aMedicoes)
				cEscss  := ""
				cPtos	:= ""
				nPEscs	:= 0                 
				nPPads	:= 0
				If Empty(aMedicoes[nx][4][1][1])
					cEscss  := aMedicoes[nx][1] 
					cPtos	:= aMedicoes[nx][2]     
					nPEscs	:= Ascan(oCbxEsc:aItems, { |x| Alltrim(x) == Alltrim(cEscss)})
					nPPads	:= Ascan(oCbxPad:aItems, { |x| Alltrim(x) == Alltrim(cPtos)})
					If nPPads == 0
						cEscal := cEscss
						a140MontPad(oDlgPri,oBmpEsc,nGot,oBmpPad) 
						nPPads := Ascan(oCbxPad:aItems, { |x| Alltrim(x) == Alltrim(cPtos)})				
					Endif
					If nPEscs > 0 .and. nPPads > 0
						oCbxEsc:nAt := nPEscs
						oCbxPad:nAt := nPPads
					Endif 
					Exit
				Endif
			Next nx
	    Endif
	Endif	    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A cada mundanca no combo do padrao deve-se:                      ³
	//³- Verificar a posicao do folter a qual estou posicionado;        ³
	//³- Atribuir valor da medicao atual para salvar aCols corretamente;³
	//³- Verificar se mudei de folder;                                  ³
	//³- Atualiza status da minha escala.								³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oCbxPad:bChange := {||nGot := a140bStOption(),nPosAnt := nPosAmed,;
                            a141ChanFolder(),;
							a141AprPad(oDlgPri,oBmpPad,oBmpEsc)} 
							

Endif

Return .t. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a141ChanFolder   ºAutor  ³Denis Martins       º Data ³  12/05/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se alterou folder para atualizacao da amedicoes, caso con-º±±
±±º          ³trario somente atualiza a aCols.                            		 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        		 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a141ChanFolder()
Local lFez := .T.

oFolderFix:bChange :={|nAt|lFez := .F.}
oFolderFix:bSetOption :={|nAt|lFez := .F.,nPosAnt := nPosAmed,a141ContrFld(nGot:=nAt,oFolderFix:nOption)}

If lFez
	Eval({||a141ContrFld(oFolderFix:nOption,oFolderFix:nOption)})
Endif
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a141ContrFldºAutor  ³Denis Martins       º Data ³  07/20/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pelo controle do folder apos receber o     º±±
±±º          ³click(ganhar foco).                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA141                                                    	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a141ContrFld(nGot,nLost,lMonta)
Local cEscall
Local cPadraos
Local nPosEscPad
Local lRet	:= .T.
Local lPressao := .F.
Local lRelogio := .F.
Local cString	:= "QM8_VLRINI|QM8_VLRFIM" 
Local aResult := {}
Local cPicture
Local oTmr
Local nTamo := 0
Local nLie	:= 0
Local nLse	:= 0
Local cUtlCpo := ""
Local nx := 1
Local oGet3
Local nDesPd := 0
Local aAret  := GetArea()
Local aGetA9 := QM9->(GetArea())
Local cTamEsc := GetNewPar("MV_QDECPAD","1") //Considerar o tamanho de casas decimais do padrao(1) ou escala(2)
Local aSize   := FWGetDialogSize(oMainWnd)

Default lMonta := .T.
Private cVarial

// Desabilita tecla de atalho de mudanca de Padrao/Ponto
SetKey(VK_F8,{||Nil})

nPosAmed := Ascan(aMedicoes, { |x| Alltrim(x[1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt]) .and. Alltrim(x[2]) == Alltrim(oCbxPad:aItems[oCbxPad:nAt])})
nPosEscPad	:= Ascan(aEscPad  , { |x| Alltrim(x[1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt]) .and. Alltrim(x[2]) == Alltrim(oCbxPad:aItems[oCbxPad:nAt])})

cEscall := oCbxEsc:aItems[oCbxEsc:nAt]
cPadraos:= oCbxPad:aItems[oCbxPad:nAt]

oCbxPad:Refresh() 
lAtributo := Upper(Alltrim(aMedicoes[nPosAmed,nPosGer,1,3])) == "A"

If aFolder[nPosEscPad] == NIL // Verificar a integridade do Array
	aFolder[nPosEscPad] := {oCbxEsc:aItems[oCbxEsc:nAt],oCbxPad:aItems[oCbxPad:nAt]}	
Endif

//Integridade - Permitir incluir/alterar as getdados
If Inclui .or. Altera
	If aObjetos[OBJ_PADSEC] <> Nil
		aObjetos[OBJ_PADSEC][2]:oBrowse:nOpc := 3
	Endif	
	If aObjetos[OBJ_INSTUTIL] <> Nil
		aObjetos[OBJ_INSTUTIL][4]:oBrowse:nOpc := 3
	Endif
	If aObjetos[OBJ_NAOCONFOR] <> Nil
		aObjetos[OBJ_NAOCONFOR][2]:oBrowse:nOpc := 3
	Endif	
	If aObjetos[OBJ_INCERT_B] <> Nil
		aObjetos[OBJ_INCERT_B][3]:oBrowse:nOpc := 3 
	Endif	
Else	
	aObjetos[OBJ_PADSEC][2]:oBrowse:nOpc := 2
	aObjetos[OBJ_INSTUTIL][4]:oBrowse:nOpc := 2
	aObjetos[OBJ_NAOCONFOR][2]:oBrowse:nOpc := 2
	aObjetos[OBJ_INCERT_B][3]:oBrowse:nOpc := 2 
Endif

Do Case
	Case oFolderFix:nOption == 1 //Medicoes
		If aMedicoes[nPosAnt,nPosGer,1,1] == 0 .and. aMedicoes[nPosAnt,nPosGer,1,4] == "E"
			If aObjetos[ OBJ_MEDICAO_1 ][5]:aCols <> Nil				 
				aCols := aObjetos[ OBJ_MEDICAO_1 ][5]:aCols
			Endif	
		Else
			If aObjetos[ OBJ_MEDICAO_1 ][6]:aCols <> Nil				 
				aCols := aObjetos[ OBJ_MEDICAO_1 ][6]:aCols
			Endif	
		Endif
		Eval({ || aMedicoes[nPosAnt,nPosMed] := aCols})
		If Alltrim(aMedicoes[nPosAnt][nPosPad]) == "PADRAOEXT"
			aMedicoes[nPosAnt,nPosGer,1,9]	:= IIf(nDesPad <> NIL,nDesPad,0)		
			aMedicoes[nPosAnt,nPosGer,1,10]	:= IIf(nInsTot <> NIL,nInsTot,0)
		Endif
		
	Case oFolderFix:nOption == 2 //Observacoes	
		aMedicoes[nPosAnt,nPosObs,1,2] := cTextos
		aObjetos[OBJ_OBSERVACAO][1]:SetText("")
		aObjetos[OBJ_OBSERVACAO][1]:Hide()

	Case oFolderFix:nOption == 3 //Medicoes Externas		
		aObjetos[OBJ_MEDEXT][1]:Hide()
		aObjetos[OBJ_MEDEXT][8]:oBrowse:lDisablePaint := .T.  
		aObjetos[OBJ_MEDEXT][8]:oBrowse:Refresh(.T.)
		aObjetos[OBJ_MEDEXT][8]:ForceRefresh()			
		aObjetos[OBJ_MEDEXT][9]:cCaption := Space(20)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Permite sugerir Laboratorio Externo/Nro.Certificado para todas as escalas³
		//³Externas sem Numero de Medicoes quando da opcao incluir                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
 		If aMedicoes[nPosAnt,nPosGer,1,1] == 0 .or. aMedicoes[nPosAnt,nPosGer,1,4] == "E"
			If lRepLab .and. Inclui
				If !Empty(aMedicoes[nPosAnt,nPosExt,1,1]) .or. !Empty(aMedicoes[nPosAnt,nPosExt,1,2])
					If MsgYesNo(OemToAnsi(STR0132),OemToAnsi(STR0133)) //"Caso exista(m) mais laboratorio(s) externo(s)/nro(s).certificado(s),deseja replicar esses dados para todas as escalas ?" //"Lab.Externo/Certificado"
						For nx := 1 To Len(aMedicoes)
							If aMedicoes[nx,nPosGer,1,1] == 0 .or. aMedicoes[nx,nPosGer,1,4] == "E"
								aMedicoes[nx,nPosExt,1,1] := oLabExt:cText
								aMedicoes[nx,nPosExt,1,2] := oNroCer:cText
							Endif
						Next nx
					Endif
					lRepLab := .F.
				Endif
			Endif
        Endif
	Case oFolderFix:nOption == 4 // Padroes Secundarios
		SetKey(VK_F4,{||NIL }) 
		If aMedicoes[nPosAnt,nPosGer,1,5] == "S" .Or. aMedicoes[nPosAnt,nPosGer,1,4] <> "I"
		   lRet := .T.	
		Else
			If oGetSec:aCols <> NIL
				Eval({ || a140DelNil(aObjetos[OBJ_PADSEC][2]),aMedicoes[nPosAnt,nPosSec] := oGetSec:aCols})
				aCols := aMedicoes[nPosAnt][nPosSec]
			Endif	
			aObjetos[OBJ_PADSEC][1]:Hide()			
		Endif

	Case oFolderFix:nOption == 5 // Instr.Utilizados
		If aMedicoes[nPosAnt,nPosGer,1,5] <> "S" .Or. aMedicoes[nPosAnt,nPosGer,1,4] <> "I"
			lRet := .T.
		Else			
			If oGetIns:aCols <> NIL 
				Eval({ || a140DelNil(aObjetos[OBJ_INSTUTIL][4]),aMedicoes[nPosAnt,nPosIns] := oGetIns:aCols})
			Endif
		Endif
		aObjetos[OBJ_PADSEC][1]:Hide()				

	Case oFolderFix:nOption == 6 // Nao Conformidades
		If oGetNco:aCols <> NIL
			aObjetos[OBJ_NAOCONFOR][2]:ForceRefresh()
			Eval({ || a140DelNil(aObjetos[OBJ_NAOCONFOR][2]),aMedicoes[nPosAnt,nPosNco] := oGetNco:aCols})
		Endif	
		aObjetos[OBJ_NAOCONFOR][2]:Hide()

	Case oFolderFix:nOption == 7 // Incerteza Tipo B
		If aMedicoes[nPosAMed,nPosGer,1,4] == "E" .and. aMedicoes[nPosAMed,nPosGer,1,8] == "N"
			lRet := .T.
		Else
			If oGetItb:aCols <> NIL
				aObjetos[OBJ_INCERT_B][3]:ForceRefresh()
				Eval({ || a140DelNil(aObjetos[OBJ_INCERT_B][3]),aMedicoes[nPosAnt,nPosITB] := oGetItb:aCols})
			Endif
		Endif	
		aObjetos[OBJ_INCERT_B][1]:Hide()
EndCase

Do Case 
	Case nGot == 1 
		If Len((aMedicoes[nPosAMed,nPosMed,1])) > 3
			If aMedicoes[nPosAMed,nPosGer,1,2] == "3"   // Tipo de Calibracao Pressao
				lPressao := .T.
			ElseIf aMedicoes[nPosAMed,nPosGer,1,2] == "9"   // Tipo de Calibracao Relogio
				lRelogio := .T.
			EndIf		
		Elseif Len((aMedicoes[nPosAMed,nPosMed,1])) == 2
			cString	:= "QM8_VLRFIM"
		EndIf
	
		aHeader := {}
		
		If !lAtributo
			If !lPressao .and. !lRelogio
				If aMedicoes[nPosAMed,nPosGer,1,2] $ "1|4"   // Tipo Calibracao Simples / Calibrador...
					aHeader := aClone(aHeadSim)
				Else	
					aHeader := aClone(aHeadTot)
				Endif	
			Else
				If lPressao
					aHeader := aClone(aHeadPre)
				ElseIf lRelogio
					aHeader := aClone(aHeadRel)
				Endif
			Endif
		Else
			aHeader := aClone(aHeadAtr)
		EndIf    
		
		DEFINE TIMER oTmr INTERVAL 1 ACTION oGetMed2:ForceRefresh()
		oTmr:DeActivate()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega o Array aCols a partir do Array aMedicoes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    lUniGual := .F.
		aCols := {}
		If !latributo
			aCols 	:= aClone(aMedicoes[nPosAmed,nPosMed])
			nUsado	:= Len(acols[1])	
			If !aMedicoes[nPosAmed,nPosGer,1,2] $ "4|8"
				lRetUnid := a140TamDec(@nTam,@cNomin,@cUniMed,@nCoef,nPosAmed)
			Else
				lRetUnid:= .T.
				nTam	:= QA_NUMDEC(aMedicoes[nPosAmed,nPosEsp])
				nCoef	:= 1	 		
			Endif	
	
			If nCoef == 1
				lUniGual := .T.
			Endif	                          
		Else
			aCols			:= {{"",.F.}}                                            
			aCols[1][1] 	:= aMedicoes[nPosAmed,nPosMed,1,1]
			aCols[1][2]		:= aMedicoes[nPosAmed,nPosMed,1,2]
			nUsado			:= Len(acols[1])	
			lRetUnid 		:= .T. // Quando for atributo, aceitar qq unidade de medida.
		Endif				
		
		nDesPad		:= aMedicoes[nPosAmed,nPosGer,1,9] //nLin_aMed
		nInsTot		:= aMedicoes[nPosAmed,nPosGer,1,10] //nLin_aMed
		
		If lRetUnid
			aRotina[3,4] := 6
			If aMedicoes[nPosAmed,nPosGer,1,1] == 0 .and. aMedicoes[nPosAmed,nPosGer,1,4] == "E"
				//oBtnPad:Disable()
				//oBtnPad:Refresh()
				aObjetos[ OBJ_MEDICAO_1 ][1]:Show()
				aObjetos[ OBJ_MEDICAO_1 ][1]:lTransparent := .F.
				aObjetos[ OBJ_MEDICAO_1 ][2]:Show()
				aObjetos[ OBJ_MEDICAO_1 ][2]:lTransparent := .F.
				aObjetos[ OBJ_MEDICAO_1 ][1]:Refresh()    
				
				@  5000,5000	MSGET  oGet3 VAR nDesPd	OF oFolderFix:aDialogs[1]	PIXEL SIZE 35,7.5 
				aObjetos[ OBJ_MEDICAO_1 ][3]:bLostFocus := {||oGet3:SetFocus()}            
				
				If lMonta
					aObjetos[ OBJ_MEDICAO_1 ][5]:oBrowse:lDisablePaint := .T.
					aObjetos[ OBJ_MEDICAO_1 ][5]:= MsNewGetDados():New(12,2,(aSize[3] / 2) - 170, (aSize[4] / 2) - 8,nTipoMd,{||AllwaysTrue()},,,,,,,,{||.F.},oFolderFix:aDialogs[1],aHeader,aCols)
					aObjetos[ OBJ_MEDICAO_1 ][5]:oBrowse:lDisablePaint := .F.  
				Endif
	
				aObjetos[ OBJ_MEDICAO_1 ][5]:oBrowse:Refresh(.T.)			
	
				If lMonta
					aObjetos[ OBJ_MEDICAO_1 ][5]:ForceRefresh()			
				Endif	
				//Igualo as GetDados, motivo: Evitar problemas com transform's de aHeader.
				aObjetos[ OBJ_MEDICAO_1 ][6] := aObjetos[ OBJ_MEDICAO_1 ][5] 
				aObjetos[ OBJ_MEDICAO_1 ][5]:oBrowse:bValid := {||aObjetos[ OBJ_MEDICAO_1 ][6]:ForceRefresh(),aMedicoes[nPosAmed,nPosMed] :=  aCols } //aObjetos[ OBJ_MEDICAO_1 ][5]:aCols}
				aObjetos[ OBJ_MEDICAO_1 ][3]:SetText(nDesPad)	
				aObjetos[ OBJ_MEDICAO_1 ][3]:Show()
				aObjetos[ OBJ_MEDICAO_1 ][3]:Refresh()
				aObjetos[ OBJ_MEDICAO_1 ][4]:SetText(nInsTot)
				aObjetos[ OBJ_MEDICAO_1 ][4]:Show()
				aObjetos[ OBJ_MEDICAO_1 ][4]:Refresh()
				aObjetos[ OBJ_MEDICAO_1 ][7]:Hide()
				aObjetos[ OBJ_MEDICAO_1 ][8]:Hide()
				aObjetos[ OBJ_MEDICAO_1 ][9]:Hide()
				//aObjetos[ OBJ_MEDICAO_1 ][10]:Disable()
				aObjetos[ OBJ_MEDICAO_1 ][10]:Hide()
				aObjetos[ OBJ_MEDICAO_1 ][11]:Hide()
				//aObjetos[ OBJ_MEDICAO_1 ][12]:Disable()
				aObjetos[ OBJ_MEDICAO_1 ][12]:Hide()
				aObjetos[ OBJ_MEDICAO_1 ][13]:Hide()
				aObjetos[ OBJ_MEDICAO_1 ][14]:Hide()
				aObjetos[ OBJ_MEDICAO_1 ][15]:Hide()
				aObjetos[ OBJ_MEDICAO_1 ][16]:Hide()
				aObjetos[ OBJ_MEDICAO_1 ][17]:Hide()
				aObjetos[ OBJ_MEDICAO_1 ][18]:Hide()
				aObjetos[ OBJ_MEDICAO_1 ][19]:Hide()
				aObjetos[ OBJ_MEDICAO_1 ][20]:Hide()
			Else 
	
				If aObjetos[ OBJ_MEDICAO_1 ][3] <> Nil
					aObjetos[ OBJ_MEDICAO_1 ][3]:Hide() 
					aObjetos[ OBJ_MEDICAO_1 ][4]:Hide()
				Endif			
	
				//oBtnPad:Enable()
				//oBtnPad:Refresh()
				If Alltrim(aMedicoes[nPosAmed][nPosPad]) == "PADRAOEXT"
					aObjetos[OBJ_MEDICAO_1][1]:Show()
					aObjetos[OBJ_MEDICAO_1][2]:Show()					
					aObjetos[OBJ_MEDICAO_1][3]:Show()
					aObjetos[OBJ_MEDICAO_1][4]:Show()
				Else
					aObjetos[ OBJ_MEDICAO_1 ][1]:Hide()
					aObjetos[ OBJ_MEDICAO_1 ][2]:Hide()
					aObjetos[ OBJ_MEDICAO_1 ][3]:Hide()
					aObjetos[ OBJ_MEDICAO_1 ][4]:Hide()
				Endif
				
				If lMonta
					aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:lDisablePaint := .T.
	                aObjetos[ OBJ_MEDICAO_1 ][6]:ForceRefresh()
					aObjetos[ OBJ_MEDICAO_1 ][6]:= MsNewGetDados():New(12,2,(aSize[3] / 2) - 170, (aSize[4] / 2) - 8,nTipoMd,{||AllwaysTrue()},,,,,,,,{||.F.},oFolderFix:aDialogs[1],aHeader,aCols)
					aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:lDisablePaint := .F.  
				Endif
	
				aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:Refresh(.T.)
	
				If lMonta
					aObjetos[ OBJ_MEDICAO_1 ][6]:ForceRefresh()			
				Endif	
	
				//Igualo as GetDados, motivo: Evitar problemas com transform's de aHeader.
				aObjetos[ OBJ_MEDICAO_1 ][5]:= aObjetos[ OBJ_MEDICAO_1 ][6]
				aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:bValid := {||aObjetos[ OBJ_MEDICAO_1 ][5]:ForceRefresh(),aMedicoes[nPosAmed,nPosMed] := aObjetos[ OBJ_MEDICAO_1 ][6]:aCols}
		
				If lOnline .and. !Upper(cPorta) == "TECLADO"
					nTam := QA_NUMDEC(aMedicoes[nPosAmed][nPosEsp])
					If aMedicoes[nPosAmed,nPosGer,1,3] <> "A"
						aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:bLDblClick :={|| aCols[aObjetos[ OBJ_MEDICAO_1 ][6]:nAt][aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:nColPos]:=MSRPortQM2(oTmr , cPorta , cBaudRate, nTeste, cData, nStop,cTimeout,nTam ),qmt140VCpos(oGetMed1)}				
					Endif	
				Endif
	
				If lMonta
					aObjetos[ OBJ_MEDICAO_1 ][6]:ForceRefresh()                      
				Endif	
	
				//aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:bValid := {||aMedicoes[nPosAmed,nPosMed] := aCols }//aObjetos[ OBJ_MEDICAO_1 ][6]:aCols}    
			Endif
	
			//Caso seja tipo soma e utilize parametro para considerar casas decimais da escala
			nTamSo := nTam
			If lTamSom
				If aMedicoes[nPosAMed,nPosGer,1,2] == "5"
					If !Empty(QM9->QM9_ESCALI)
				   		nTam := QA_NUMDEC(QM9->QM9_ESCALI) 
					Else
						nTam := QA_NUMDEC(aMedicoes[nPosAMed,nPosEsp])
					Endif
				Endif
			Endif 
			If Empty(cUtlCpo)                 
				cUtlCpo := aMedicoes[nPosAMed,nPosEsp]
			Endif		
			aObjetos[ OBJ_MEDICAO_1 ][7]:Hide()
			aObjetos[ OBJ_MEDICAO_1 ][8]:Hide()
			aObjetos[ OBJ_MEDICAO_1 ][9]:Hide()
			//aObjetos[ OBJ_MEDICAO_1 ][10]:Disable()
			aObjetos[ OBJ_MEDICAO_1 ][10]:Hide()
			aObjetos[ OBJ_MEDICAO_1 ][11]:Hide()
			//aObjetos[ OBJ_MEDICAO_1 ][12]:Disable()
			aObjetos[ OBJ_MEDICAO_1 ][12]:Hide()
			aObjetos[ OBJ_MEDICAO_1 ][13]:Hide()
			aObjetos[ OBJ_MEDICAO_1 ][14]:Hide()
			aObjetos[ OBJ_MEDICAO_1 ][15]:Hide()
			aObjetos[ OBJ_MEDICAO_1 ][16]:Hide()
			aObjetos[ OBJ_MEDICAO_1 ][17]:Hide()
			aObjetos[ OBJ_MEDICAO_1 ][18]:Hide()
			aObjetos[ OBJ_MEDICAO_1 ][19]:Hide()
			aObjetos[ OBJ_MEDICAO_1 ][20]:Hide()
	
			nGetEsp	:= SuperVal(aMedicoes[nPosAmed,nPosEsp])
		
			If aMedicoes[nPosAMed,nPosGer,1,15] == "1" //.Or. nTipo <> 3
				//Tipo Interno/Externo exceto Padrao Atributo
				If aMedicoes[nPosAmed,nPosGer,1,1] <> 0 .and. Alltrim(aMedicoes[nPosAmed,nPosGer,1,3]) <> "A"
					//Caso seja tipo soma e utilize o parametro para considerar casas decimais da escala
					If lTamSom
						If aMedicoes[nPosAMed,nPosGer,1,2] = '5'	
							If !Empty(QM9->QM9_ESCALI)
				   				nTam := QA_NUMDEC(QM9->QM9_ESCALI) 
							Else
								nTam := QA_NUMDEC(aMedicoes[nPosAMed,nPosEsp])
							Endif
						Endif
					Endif
					aObjetos[OBJ_MEDICAO_1][8]:Show()
					aObjetos[OBJ_MEDICAO_1][8]:Refresh()
				Else
					aObjetos[OBJ_MEDICAO_1][8]:Hide()			
				Endif	
			Else	// Variavel
				If aMedicoes[nPosAmed,nPosGer,1,4] <> "E" 
					aObjetos[OBJ_MEDICAO_1][12]:Enable() 
					qm141m9()
					aObjetos[OBJ_MEDICAO_1][12]:bLostFocus := {|| qm141BlockObj12()}
					aObjetos[OBJ_MEDICAO_1][12]:bValid := {||nTamo := qm141m9(),nLIE := 0,nLSE := 0,;                 
	    	   		  If(ValType(nGetEsp)=="C",nGetEsp:=SuperVal(nGetEsp),),;
						  aMedicoes[nPosAMed,nPosEsp] := StrTran(Str(nGetEsp,Len(aMedicoes[nPosAmed,nPosEsp]),nTamo),".",","),;
						  cVarial := aMedicoes[nPosAMed,nPosEsp],;
						  nLIE := Qmt141VVar(nCoef,nLie,.T.,.F.),;
						  nLSE := Qmt141VVar(nCoef,nLse,.F.,.F.)}   
				Endif 
			If cTamEsc == "1"	
				cPicture := QMT140Pics(,QM9->QM9_ESCALI,.F.)
			Else
				cPicture := QMT140Pics(,cUtlCpo,.F.)			
			EndIf
				If aMedicoes[nPosAmed,nPosGer,1,1] == 0 .and. aMedicoes[nPosAmed,nPosGer,1,4] == "E"	
				   	//aObjetos[OBJ_MEDICAO_1][12]:Disable()	
					aObjetos[OBJ_MEDICAO_1][12]:Hide()				
					If !lAtributo
						If !lUniGual
							cVarial := StrTran(Str(nGetEsp*nCoef,Len(aMedicoes[nPosAMed,nPosEsp]),QA_NumDec(cUtlCpo)),".",",")
						Else
							cVarial := StrTran(Str(nGetEsp,Len(aMedicoes[nPosAMed,nPosEsp]),QA_NumDec(cUtlCpo)),".",",")
						Endif
						cPicture := QMT140Pics(,cUtlCpo,.F.)
						aObjetos[OBJ_MEDICAO_1][10]:Picture := cPicture
						aObjetos[OBJ_MEDICAO_1][10]:PictVar := cPicture   
						aObjetos[OBJ_MEDICAO_1][10]:SetText(cVarial)      
						aObjetos[OBJ_MEDICAO_1][10]:Enable()
						aObjetos[OBJ_MEDICAO_1][10]:Show()
						aObjetos[OBJ_MEDICAO_1][10]:Refresh()
					Else
						If aMedicoes[nPosAMed,nPosGer,1,15] <> "1" .and. (aMedicoes[nPosAmed,nPosGer,1,1] <> 0 .and. aMedicoes[nPosAmed,nPosGer,1,4] <> "E")
						aObjetos[OBJ_MEDICAO_1][10]:Picture := cPicture
							aObjetos[OBJ_MEDICAO_1][10]:PictVar := cPicture
							aObjetos[OBJ_MEDICAO_1][10]:SetText(cVarial)      
							aObjetos[OBJ_MEDICAO_1][12]:Show()				
							aObjetos[OBJ_MEDICAO_1][12]:Refresh()				
						Endif	
					EndIf
				Else     
					If aMedicoes[nPosAmed,nPosGer,1,1] <> 0 .and. Alltrim(aMedicoes[nPosAmed,nPosGer,1,3]) <> "A"				
						aObjetos[OBJ_MEDICAO_1][11]:Show()  
						aObjetos[OBJ_MEDICAO_1][11]:Refresh() 
					Else 
						aObjetos[OBJ_MEDICAO_1][11]:Hide() 				
					Endif	
					If !lAtributo
						If !lUniGual
							cVarial := StrTran(Str(nGetEsp/* *nCoef */,Len(aMedicoes[nPosAMed,nPosEsp]),QA_NumDec(cUtlCpo)),".",",")
						Else
							cVarial := StrTran(Str(nGetEsp,Len(aMedicoes[nPosAMed,nPosEsp]),QA_NumDec(cUtlCpo)),".",",")
						Endif
						aObjetos[OBJ_MEDICAO_1][10]:Picture := cPicture
						aObjetos[OBJ_MEDICAO_1][10]:PictVar := cPicture
						aObjetos[OBJ_MEDICAO_1][10]:SetText(cVarial)
						aObjetos[OBJ_MEDICAO_1][10]:cText := cVarial 
						aObjetos[OBJ_MEDICAO_1][10]:Refresh()
						aObjetos[OBJ_MEDICAO_1][12]:Enable()
						aObjetos[OBJ_MEDICAO_1][12]:Picture := cPicture
						aObjetos[OBJ_MEDICAO_1][12]:PictVar := cPicture
						aObjetos[OBJ_MEDICAO_1][12]:SetText(cVarial)      
						aObjetos[OBJ_MEDICAO_1][12]:Show()
						aObjetos[OBJ_MEDICAO_1][12]:Refresh()
					EndIf
				Endif
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se nao for atributo, exibe valor maximo e minimo    ³
			//³ Se for Calibrador mostra LIE / LSE                  ³
			//³ Senao mostra intervalo (especificado +- tolerancia  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aMedicoes[nPosAMed,nPosGer,1,3] <> "A"
				If aMedicoes[nPosAMed,nPosGer,1,2] $ "4|8" 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ja e verifica o tipo de calculo da tolerancia (1-Numerico / 2-Percentual)³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aObjetos[OBJ_MEDICAO_1][13]:SetText(STR0034+aMedicoes[nPosAmed,nPosGer,1,18])
					aObjetos[OBJ_MEDICAO_1][13]:Show()
					aObjetos[OBJ_MEDICAO_1][13]:Refresh()
					aObjetos[OBJ_MEDICAO_1][14]:SetText(STR0035+aMedicoes[nPosAmed,nPosGer,1,19])
					aObjetos[OBJ_MEDICAO_1][14]:Show()
					aObjetos[OBJ_MEDICAO_1][14]:Refresh()				
					aObjetos[OBJ_MEDICAO_1][15]:Hide()
					aObjetos[OBJ_MEDICAO_1][16]:Hide()				
				Else
					aObjetos[OBJ_MEDICAO_1][13]:Hide()
					aObjetos[OBJ_MEDICAO_1][14]:Hide()
					aObjetos[OBJ_MEDICAO_1][15]:Show()
					aObjetos[OBJ_MEDICAO_1][16]:Show()				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica o tipo de calculo da tolerancia (1-Numerico / 2-Percentual)³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nEspec := SuperVal(aMedicoes[nPosAMed,nPosEsp])
					nMinim := SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])
					nMaxim := SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])
					If Alltrim(aMedicoes[nPosAMed,nPosGer,1,21]) <> "1" 
						If !lUniGual
							nLIE :=	/* nEspec - ((nMinim * nEspec ) / 100)// */SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */ - ((SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */) * SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])*nCoef)/100
							nLSE :=	/* nEspec + ((nMaxim * nEspec ) / 100)// */SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */ + ((SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */) * SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])*nCoef)/100
						Else
							nLIE :=	SuperVal(aMedicoes[nPosAMed,nPosEsp]) - (SuperVal(aMedicoes[nPosAMed,nPosEsp]) * SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2]))/100
							nLSE :=	SuperVal(aMedicoes[nPosAMed,nPosEsp]) + (SuperVal(aMedicoes[nPosAMed,nPosEsp]) * SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1]))/100
						Endif	
					Else
						If !lUniGual
							nLIE :=	nEspec - nMinim//SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */ - SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])*nCoef
							nLSE :=	nEspec + nMaxim//SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */ + SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])*nCoef		
						Else
							nLIE :=	SuperVal(aMedicoes[nPosAMed,nPosEsp]) - SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])
							nLSE :=	SuperVal(aMedicoes[nPosAMed,nPosEsp]) + SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])
						Endif
					Endif
					If !lUniGual
						cPicture := QMT140Pics(,StrTran(Str(nLIE,Len(aMedicoes[nPosAMed,nPosEsp]),QA_NumDec(aMedicoes[nPosAMed,nPosEsp])),".",","),.F.)
						aObjetos[OBJ_MEDICAO_1][17]:SetText(nLIE)//SetText(SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */ - SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])*nCoef)
						aObjetos[OBJ_MEDICAO_1][17]:Show()
						aObjetos[OBJ_MEDICAO_1][17]:Refresh()
						aObjetos[OBJ_MEDICAO_1][18]:SetText(nLSE)//SetText(SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */ + SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])*nCoef)
						aObjetos[OBJ_MEDICAO_1][18]:Show()				
						aObjetos[OBJ_MEDICAO_1][19]:Hide()
						aObjetos[OBJ_MEDICAO_1][20]:Hide()				
					Else
						aObjetos[OBJ_MEDICAO_1][17]:Hide()
						aObjetos[OBJ_MEDICAO_1][18]:Hide()				
	
						cPicture := QMT140Pics(,StrTran(Str(nLIE,Len(aMedicoes[nPosAMed,nPosEsp]),nTam),".",","),.F.) //QA_NumDec(aMedicoes[nPosAMed,nPosEsp]) - Denis
						aObjetos[OBJ_MEDICAO_1][19]:SetText("")
						aObjetos[OBJ_MEDICAO_1][19]:Hide()
						aObjetos[OBJ_MEDICAO_1][19]:SetText(SuperVal(aMedicoes[nPosAMed,nPosEsp]) - SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2]))
						aObjetos[OBJ_MEDICAO_1][19]:cCaption := StrTran(Str(nLIE,Len(aMedicoes[nPosAMed,nPosEsp]),nTam),".",",") //QA_NumDec(cUtlCpo)
						aObjetos[OBJ_MEDICAO_1][19]:cTitle := StrTran(Str(nLIE,Len(aMedicoes[nPosAMed,nPosEsp]),nTam),".",",")	//QA_NumDec(cUtlCpo)
						aObjetos[OBJ_MEDICAO_1][19]:Show()
						aObjetos[OBJ_MEDICAO_1][19]:Refresh()
						aObjetos[OBJ_MEDICAO_1][19]:lTransparent := .F.
	
						cPicture := QMT140Pics(,StrTran(Str(nLSE,Len(aMedicoes[nPosAMed,nPosEsp]),nTam),".",","),.F.) //QA_NumDec(aMedicoes[nPosAMed,nPosEsp])
						aObjetos[OBJ_MEDICAO_1][20]:cCaption := StrTran(Str(nLSE,Len(aMedicoes[nPosAMed,nPosEsp]),nTam),".",",") //QA_NumDec(cUtlCpo)
						aObjetos[OBJ_MEDICAO_1][20]:cTitle := StrTran(Str(nLSE,Len(aMedicoes[nPosAMed,nPosEsp]),nTam),".",",") //QA_NumDec(cUtlCpo)
						aObjetos[OBJ_MEDICAO_1][20]:Show()
						aObjetos[OBJ_MEDICAO_1][20]:Refresh()
						aObjetos[OBJ_MEDICAO_1][20]:lTransparent := .F.
					Endif   	          
				EndIf
			Endif
			aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:SetFocus()
			aObjetos[ OBJ_MEDICAO_1 ][5]:oBrowse:SetFocus()
		Else
			oFolderFix:lReadOnly := .T.
			oCbxEsc:lReadOnly	 := .T.
			oCbxPad:lReadOnly	 := .T.
		Endif
	Case nGot == 2
		If lRetUnid	
			aRotina[3,4] := 3
			If !Empty(aMedicoes[nPosAmed,nPosObs,1,2])
				cTextos := aMedicoes[nPosAmed,nPosObs,1,2]
			Else
				cTextos := Space(TamSX3("QA2_TEXTO")[1])			
			Endif         
			aObjetos[OBJ_OBSERVACAO][1]:SetText(cTextos)
			aObjetos[OBJ_OBSERVACAO][1]:Refresh()
			aObjetos[OBJ_OBSERVACAO][1]:Show()
			aObjetos[OBJ_OBSERVACAO][1]:Refresh()
			aObjetos[OBJ_OBSERVACAO][1]:SetFocus()
		Else
			oFolderFix:lReadOnly := .T.
			oCbxEsc:lReadOnly	:= .T.
			oCbxPad:lReadOnly	:= .T.
		Endif
	Case nGot == 3 
		If lRetUnid	
			aRotina[3,4] := 3
			If Alltrim(aMedicoes[nPosAmed,12,1,4]) == "E"
				aObjetos[OBJ_MEDEXT][1]:Show()
				aObjetos[OBJ_MEDEXT][2]:Show()
				aObjetos[OBJ_MEDEXT][3]:Show()
				aObjetos[OBJ_MEDEXT][4]:Show()
				aObjetos[OBJ_MEDEXT][5]:Enable()
				aObjetos[OBJ_MEDEXT][5]:cText := aMedicoes[nPosAmed,nPosExt,1,1] 
				aObjetos[OBJ_MEDEXT][5]:SetText(aObjetos[OBJ_MEDEXT][5]:cText)	
				aObjetos[OBJ_MEDEXT][5]:Show()
				aObjetos[OBJ_MEDEXT][5]:SetFocus()
				aObjetos[OBJ_MEDEXT][6]:cText := aMedicoes[nPosAmed,nPosExt,1,2] 
				aObjetos[OBJ_MEDEXT][6]:SetText(aObjetos[OBJ_MEDEXT][6]:cText)										
				aObjetos[OBJ_MEDEXT][6]:Show()										
				aObjetos[OBJ_MEDEXT][7]:Hide()
				aObjetos[OBJ_MEDEXT][7]:Refresh()
				aObjetos[OBJ_MEDEXT][8]:oBrowse:lDisablePaint := .T.  
				aObjetos[OBJ_MEDEXT][8]:oBrowse:Refresh(.T.)
				aObjetos[OBJ_MEDEXT][8]:ForceRefresh()			
				aObjetos[OBJ_MEDEXT][9]:cCaption := qmt141NoLab(aObjetos[OBJ_MEDEXT][5]:cText,aObjetos[OBJ_MEDEXT][9])
				aObjetos[OBJ_MEDEXT][9]:Refresh()
			Else
				aObjetos[OBJ_MEDEXT][5]:Disable()
				aObjetos[OBJ_MEDEXT][5]:Hide()
				aObjetos[OBJ_MEDEXT][7]:Show()												
				aObjetos[OBJ_MEDEXT][1]:Hide()
				aObjetos[OBJ_MEDEXT][2]:Hide()
				aObjetos[OBJ_MEDEXT][3]:Hide()
				aObjetos[OBJ_MEDEXT][4]:Hide()
				aObjetos[OBJ_MEDEXT][6]:Hide()										
				aObjetos[OBJ_MEDEXT][8]:oBrowse:lDisablePaint := .T.  
				aObjetos[OBJ_MEDEXT][8]:oBrowse:Refresh(.T.)
				aObjetos[OBJ_MEDEXT][8]:ForceRefresh()			                    
				aObjetos[OBJ_MEDEXT][9]:cCaption :=	 Space(20)   
			Endif	
		Else
			oFolderFix:lReadOnly := .T.
			oCbxEsc:lReadOnly	:= .T.
			oCbxPad:lReadOnly	:= .T.
		Endif
	Case nGot == 4 
		SetKey(VK_F4,{|| a140PadSec()}) 
		If lRetUnid	
			aCols := {}
			aRotina[3,4] := 3
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega o Array aCols a partir do Array aMedicoes e aHeader ja carregado ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        aHeader := aClone(aHeadQMS)
	        
			aCols := aClone(aMedicoes[nPosAmed,nPosSec])
	
			nUsado	:= Len(oGetSec:aCols[1])		
	 		If aMedicoes[nPosAmed,nPosGer,1,5] == "S" .Or. aMedicoes[nPosAmed,nPosGer,1,4] <>  "I"
				aObjetos[OBJ_PADSEC][1]:Show()
				aObjetos[OBJ_PADSEC][2]:Hide()
			Else
				oGetSec:aHeader := aHeader
				oGetSec:aCols := aCols
				aObjetos[OBJ_PADSEC][2]:aHeader := aHeader
				aObjetos[OBJ_PADSEC][2]:aCols := aCols
				aObjetos[OBJ_PADSEC][2]:ForceRefresh()
				If Inclui .or. Altera
					aRotina[3,4] := 3
					aObjetos[OBJ_PADSEC][2]:oBrowse:nOpc := 3
				Endif				
				aObjetos[OBJ_PADSEC][2]:oBrowse:Refresh()
				aObjetos[OBJ_PADSEC][2]:oBrowse:lDisablePaint := .F.
				aObjetos[OBJ_PADSEC][2]:Show()                
				aObjetos[OBJ_PADSEC][2]:ForceRefresh()
				aObjetos[OBJ_PADSEC][1]:Hide()					
				aObjetos[OBJ_PADSEC][2]:oBrowse:bDrawSelect := {|| A140ChgGet( aObjetos[OBJ_PADSEC][2],oFolderFix:aDialogs[4] )}
				aObjetos[OBJ_PADSEC][2]:oBrowse:bValid := {|| A140DelNil(aObjetos[OBJ_PADSEC][2])}//,oGetSec:ForceRefresh()}//bLostFocus
				aObjetos[OBJ_PADSEC][2]:oBrowse:SetFocus()
			Endif
		Else
			oFolderFix:lReadOnly := .T.
			oCbxEsc:lReadOnly	:= .T.
			oCbxPad:lReadOnly	:= .T.
		Endif
	Case nGot == 5 
		If lRetUnid
			aRotina[3,4] := 3
			aHeader := aClone(aObjetos[OBJ_INSTUTIL][3])    	
    	
			aCols 	:= aClone(aMedicoes[nPosAmed,nPosIns])
			nUsado	:= Len(oGetIns:aCols[1])

			If aMedicoes[nPosAmed,nPosGer,1,5] <> "S" .Or. aMedicoes[nPosAmed,nPosGer,1,4] <> "I"
				aObjetos[OBJ_INSTUTIL][1]:Show()
				aObjetos[OBJ_INSTUTIL][1]:Refresh()
				aObjetos[OBJ_INSTUTIL][2]:Show()	
				aObjetos[OBJ_INSTUTIL][2]:Refresh()           
				aObjetos[OBJ_INSTUTIL][4]:ForceRefresh()
				aObjetos[OBJ_INSTUTIL][4]:oBrowse:lDisablePaint := .T.
				aObjetos[OBJ_INSTUTIL][4]:ForceRefresh()
				aObjetos[OBJ_INSTUTIL][4]:oBrowse:Refresh(.T.)								
				aObjetos[OBJ_INSTUTIL][4]:Hide()
			Else
				aObjetos[OBJ_INSTUTIL][1]:Hide()
				aObjetos[OBJ_INSTUTIL][2]:Hide()	
				aObjetos[OBJ_INSTUTIL][4]:aHeader := aHeader
				aObjetos[OBJ_INSTUTIL][4]:aCols := aCols
				aObjetos[OBJ_INSTUTIL][4]:ForceRefresh()
				If Inclui .or. Altera
					aObjetos[OBJ_INSTUTIL][4]:oBrowse:nOpc := 3
				Endif	
				aObjetos[OBJ_INSTUTIL][4]:oBrowse:Refresh()
				aObjetos[OBJ_INSTUTIL][4]:oBrowse:lDisablePaint := .F.
				aObjetos[OBJ_INSTUTIL][4]:ForceRefresh()
				aObjetos[OBJ_INSTUTIL][4]:oBrowse:Refresh(.T.)								
				aObjetos[OBJ_INSTUTIL][4]:Show() 
				aObjetos[OBJ_INSTUTIL][4]:oBrowse:SetFocus()		
			Endif
		Else
			oFolderFix:lReadOnly := .T.
			oCbxEsc:lReadOnly	:= .T.
			oCbxPad:lReadOnly	:= .T.
		Endif
	Case nGot == 6 
		If lRetUnid
			aRotina[3,4] := 3
        	aHeader := aClone(aObjetos[OBJ_NAOCONFOR][1])
			aCols	:= aClone(aMedicoes[nPosAmed,nPosNco])
			nUsado	:= Len(oGetNco:aCols[1])
			aObjetos[OBJ_NAOCONFOR][2]:aHeader := aHeader
			aObjetos[OBJ_NAOCONFOR][2]:aCols := aCols
			aObjetos[OBJ_NAOCONFOR][2]:oBrowse:Refresh()
			aObjetos[OBJ_NAOCONFOR][2]:ForceRefresh()					
			aObjetos[OBJ_NAOCONFOR][2]:oBrowse:bDrawSelect := {||A140ChgGet(aObjetos[OBJ_NAOCONFOR][2],oFolderFix:aDialogs[6]) }
			If Inclui .or. Altera
				aRotina[3,4] := 3
				aObjetos[OBJ_NAOCONFOR][2]:oBrowse:nOpc := 3
			Endif				
			aObjetos[OBJ_NAOCONFOR][2]:oBrowse:Refresh()
			aObjetos[OBJ_NAOCONFOR][2]:oBrowse:lDisablePaint := .F.
			aObjetos[OBJ_NAOCONFOR][2]:Show()
			aObjetos[OBJ_NAOCONFOR][2]:ForceRefresh()		
			If Inclui .or. Altera
				aRotina[3,4] := 3
			Endif	
			aObjetos[OBJ_NAOCONFOR][2]:oBrowse:SetFocus()
		Else
			oFolderFix:lReadOnly := .T.
			oCbxEsc:lReadOnly	:= .T.
			oCbxPad:lReadOnly	:= .T.
		Endif		
	Case nGot == 7 
		If lRetUnid
			aRotina[3,4] := 3
			If aMedicoes[nPosAMed,nPosGer,1,4] == "E" .and. aMedicoes[nPosAMed,nPosGer,1,8] == "N"
				aObjetos[OBJ_INCERT_B][1]:Show()
				aObjetos[OBJ_INCERT_B][1]:Refresh()
				aObjetos[OBJ_INCERT_B][2]:Show()
				aObjetos[OBJ_INCERT_B][2]:Refresh()
				aObjetos[OBJ_INCERT_B][3]:oBrowse:lDisablePaint := .T.
				aObjetos[OBJ_INCERT_B][3]:Hide()
				aObjetos[OBJ_INCERT_B][4]:Hide()
				aObjetos[OBJ_INCERT_B][5]:Hide()
				aObjetos[OBJ_INCERT_B][6]:Hide()
				aObjetos[OBJ_INCERT_B][7]:Hide()
				aObjetos[OBJ_INCERT_B][8]:Hide()
				aObjetos[OBJ_INCERT_B][9]:Hide()
				aObjetos[OBJ_INCERT_B][10]:Hide()
				aObjetos[OBJ_INCERT_B][11]:Hide()
				aObjetos[OBJ_INCERT_B][12]:Hide()
				aObjetos[OBJ_INCERT_B][13]:Hide()
				aObjetos[OBJ_INCERT_B][14]:Hide()
				aObjetos[OBJ_INCERT_B][15]:Hide()
				aObjetos[OBJ_INCERT_B][16]:Hide()
				aObjetos[OBJ_INCERT_B][17]:Hide()
				aObjetos[OBJ_INCERT_B][18]:Hide()
				aObjetos[OBJ_INCERT_B][19]:Hide()
				aObjetos[OBJ_INCERT_B][20]:Hide()
				aObjetos[OBJ_INCERT_B][21]:Hide()
			Else 
				aResult := A140Calc(nPosAmed)
				If Len(aResult) > 1
					If Len(aResult) > 3
						If aResult[2,5] > aResult[4,5]
							aMedicoes[nPosAmed,nPosGer,1,16] := aResult[2,5]
						Else
							aMedicoes[nPosAmed,nPosGer,1,16] := aResult[4,5]
						EndIf
					Else
						aMedicoes[nPosAmed,nPosGer,1,16] := aResult[2,5]
					EndIf
				Else
					aMedicoes[nPosAmed,nPosGer,1,16] := aResult[1,5]
				EndIf
				
				aHeader := aObjetos[OBJ_INCERT_B][22]
				aCols	:= aClone(aMedicoes[nPosAMed,nPosITB])		
				nUsado	:= Len(oGetItb:aCols[1])
				aObjetos[OBJ_INCERT_B][3]:aHeader := aHeader                	
				aObjetos[OBJ_INCERT_B][3]:aCols := aCols                	
				aObjetos[OBJ_INCERT_B][1]:Hide()
				aObjetos[OBJ_INCERT_B][2]:Hide()
				aObjetos[OBJ_INCERT_B][3]:ForceRefresh()			
				If Inclui .or. Altera
					aObjetos[OBJ_INCERT_B][3]:oBrowse:nOpc := 3					
				Endif	
				aObjetos[OBJ_INCERT_B][3]:oBrowse:Refresh()
				aObjetos[OBJ_INCERT_B][3]:oBrowse:lDisablePaint := .F.
				aObjetos[OBJ_INCERT_B][3]:Show()	
				aObjetos[OBJ_INCERT_B][3]:ForceRefresh()			
				
				a141WhRes(oFolderFix:aDialogs[7],nPosAmed)

				aObjetos[OBJ_INCERT_B][4]:Show()
				aObjetos[OBJ_INCERT_B][5]:Show()
				aObjetos[OBJ_INCERT_B][6]:Show()
				aObjetos[OBJ_INCERT_B][7]:Show()
				aObjetos[OBJ_INCERT_B][8]:Show()
				aObjetos[OBJ_INCERT_B][9]:Show()
				aObjetos[OBJ_INCERT_B][10]:Show()
				aObjetos[OBJ_INCERT_B][11]:Show()
				aObjetos[OBJ_INCERT_B][12]:Show()
				aObjetos[OBJ_INCERT_B][13]:Show()
				aObjetos[OBJ_INCERT_B][14]:Show()
				aObjetos[OBJ_INCERT_B][15]:Show()
				aObjetos[OBJ_INCERT_B][16]:Show()
				aObjetos[OBJ_INCERT_B][17]:Show()
				aObjetos[OBJ_INCERT_B][18]:Show()
				aObjetos[OBJ_INCERT_B][19]:Show()
				aObjetos[OBJ_INCERT_B][20]:Show()
				aObjetos[OBJ_INCERT_B][21]:Show()
				aObjetos[OBJ_INCERT_B][3]:oBrowse:SetFocus()
			Endif

            If Inclui .or. Altera
				aObjetos[OBJ_INCERT_B][3]:oBrowse:nOpc := 3
				aRotina[3,4] := 3				
			Endif	
		Else
			oFolderFix:lReadOnly := .T.
			oCbxEsc:lReadOnly	:= .T.
			oCbxPad:lReadOnly	:= .T.
		Endif	
EndCase	

// Habilita tecla de atalho de mudanca de Padrao/Ponto
SetKey(VK_F8,{|| a140MudPad()})

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a140MontPadºAutor  ³Denis Martins       º Data ³  07/20/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pela montagem dos padroes da escala e ins-º±±
±±º          ³trumentos correntes.                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QMTA141                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a140MontPad(oDlgPri,oBmpEsc,nGot,oBmpPad) 
Local nx
Local lRet := .T.                        
Local nLin := 0

nLin := 10

aTitPad := {}

If !Empty(cEscal)  
	For nx := 1 To Len(aMedicoes)
		If Alltrim(cEscal) == Alltrim(aMedicoes[nx][1])
			Aadd(aTitPad,aMedicoes[nx][2])
		Endif
	Next nx     
	
	If Len(aTitPad) > 0
		@ 145-nLin ,236 COMBOBOX oCbxPad VAR cPadr ITEMS aTitPad SIZE 82,8 OF oDlgPri PIXEL //75,165
		oCbxPad:bValid := {|| oCbxPad:Refresh()}

		oCbxPad:bChange := {||nGot := a140bStOption(),nPosAnt := nPosAmed,;
                            a141ChanFolder(),;
							a141AprPad(oDlgPri,oBmpPad,oBmpEsc)} 
	Else
		lRet := .F.
	Endif
Endif

oCbxEsc:SetFocus()  

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140Start ³ Autor ³ Fernando Godoy		³ Data ³ 8/25/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se pode montar o Folder							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 - Handle o Objeto Bitmap com a foto do instrumento	  ³±±
±±³			 ³ExpL1 - .T. Indica que ja foi montada a estrutura do dbTree ³±±
±±³			 ³ExpO2 - Handle do Objeto Get do Instrumento				  ³±±
±±³			 ³ExpO3 - Handle do Objeto Get da Data de entrada			  ³±±
±±³			 ³ExpO4 - Handle do Objeto Get do Repe/Repro 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140Inclui         										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140Start(lJaMontTre,cMtInstr,dMtData,cMtRepRepr,cMtResp,cMtTotHr,cMtRevIns,oDlgPri,oBtn,nOpcx,cMtSeq,oSayD)
Local lRet		 := .T.
Local cEscalaQM 
Local cRevEscala
Local cFEsc := ""
Local lContinua := .F.
Local lRetu := .f.
Local lQSOMINC := SuperGetMv("MV_QSOMINC",.F.,.F.) //Soma o valor da incerteza total para o calculo da incerteza padrão secundario (.T./.F.).
PRIVATE lNaoObrigt := .F.

cMtInstr	:= M->QM6_INSTR
dMtData		:= M->QM6_DATA
cMtRepRepr	:= M->QM6_REPEPR
cMtResp		:= M->QM6_RESP
cMtTotHr	:= M->QM6_TOTHOR
cMtRevIns	:= M->QM6_REVINS
cMtSeq		:= M->QM6_CSEQ

If Inclui
	If QA_VerNum(@cMtRepRepr)
		If QMT140Chv(cMtResp,cMtTotHr,cMtRepRepr,cMtInstr,cMtRevIns,dMtData,oDlgPri,oBtn,cMtSeq,@cMtFilRes)
			If !Empty(cMtInstr) .And. !Empty(cMtRevIns) .And. !Empty(dMtData) .And. !Empty(cMtResp)
				If !lJaMontTre
					If MsgYesNo(STR0007,STR0008) //"Confirma os dados?" ### "Atencao"
						If MsgYesNo("Deseja carregar as faixas não obrigatórias?",STR0008) //"Confirma os dados?" ### "Atencao"
							lNaoObrigt := .T.
						EndIf
					   dbSelectArea("QM2")
					   dbSetOrder(1)   
					   If dbSeek(xFilial("QM2")+cMtInstr+Inverte(cMtRevIns))
					      cEscalaQM := QM2->QM2_TIPO
					      dbSelectArea("QM1")
					      dbSetOrder(01)     
					      If dbSeek(xFilial("QM1")+cEscalaQM)
					         cRevEscala := QM1->QM1_REVTIP
					         dbSelectArea("QMK")
					         dbSetOrder(01)
					         If !dbSeek(xFilial("QMK")+cEscalaQM+Inverte(cRevEscala))
					            MsgStop(OemToAnsi(STR0104)+Trim(cEscalaQM)+" - "+OemToAnsi(STR0105)+cRevEscala+" e/ou nao existe padroes associados a essas escalas")  
  					            lRet := .F.
//								oMtInstr:SetFocus() 
							 Else
								cFEsc := ""
							 	While QMK->(!Eof()) .and. QMK->QMK_FILIAL+QMK->QMK_TIPO+QMK->QMK_REVTIP ==;
							 		xFilial("QMK")+cEscalaQM+cRevEscala
									//Buscar escalas para verificar se as mesmas percentem ao tipo calibrador/calibrador
									//completo pois esses tipos de escalas nao apresentam padroes no QMC / QMA
									dbSelectArea("QM9")
									dbSetOrder(1)                                                            
									If dbSeek(xFilial("QM9")+QMK->QMK_ESCALA)
										If !(QM9->QM9_TIPAFE $ "4|8| ")
											dbSelectArea("QMC")
											dbSetOrder(1)
											//Nao pode ser QMK_REVINV porque causara incosistencia quando da geracao de revisao da familia
											If !dbSeek(xFilial("QMC")+QMK->QMK_ESCALA+Inverte(QM9->QM9_REVESC))
												//Se nao encontrar em escalas diferente do tipo soma
												dbSelectArea("QMA")
												dbSetOrder(01)
												If !dbSeek(xFilial("QMA")+QMK->QMK_ESCALA+QM9->QM9_REVESC)
													If !(QMK->QMK_ESCALA $ cFEsc)
														cFEsc += QMK->QMK_ESCALA+" "
													Endif
												Else
													lRet := .T.
													lContinua := .T.
												Endif
											Else
												lRet := .T.
												lContinua := .T.
											Endif
										Else
											lRet := .T.
											lContinua := .T.
										Endif
									Endif
									dbSelectArea("QMK")
									QMK->(dbSkip())
								Enddo

								If !Empty(cFEsc)
									MsgInfo(STR0003+Upper(cFEsc),STR0002)  //"Nao existe(m) padrao(oes) associado(s) a(s) escala(s) " "Escala(s) sem Padrao(oes)"
								Endif

								If lContinua
									lRet := .T.
								Else
									lRet := .F.								
								Endif
							 Endif						         
					      Endif      
					   Endif            
					   If lRet
							LjMsgRun( STR0090,,{ || lRetu := A140CarMed() },CLR_BLUE)							
							If lRetu
								If lQSOMINC //Soma o valor da incerteza total para o calculo da incerteza padrão secundario (.T./.F.).
									FSomaIncer(@aMedicoes)
								EndIf
								LjMsgRun( STR0090,,{ || lRetu := A140MoFirst(oDlgPri,@oBtn,nOpcx/*, oSayD */)},CLR_BLUE)							
								If lRetu
									lJaMontTre := .T.
									lConEnch := .F.
									oEnchoice1:Refresh()
									oBtn:Disable()
									oBtn:Hide()
									//oSayD:Hide()
								EndIf
							Else
								lRet := .F.
							Endif
						Endif
					EndIf
				EndIf
			Else
				MessageDlg(STR0009,,3)	//"Deve-se informar os Campos Instrumento,Data e Responsavel, para prosseguir."
				lRet := .f.
			EndIf
		Else
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf
Else
	If !A140CarMed()
		lRet := .F.
	Endif
EndIf

If lRet
	lAtual := .F.
	If oEnchoice1 <> Nil
		oEnchoice1:Refresh()	
	Endif	
Endif
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140ChgGet³ Autor ³ Fernando Godoy		³ Data ³ 8/31/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se incluiu mais de uma vez linha em branco no acols³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 - Handle do Objeto getdados 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpL1 - .T. ou .F. 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140ShwSec												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140ChgGet( oGetDad,oFldFix )

Local lRet		:= .T.
Local nI 		:= 1
Local nVezes	:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se deixar a ultima linha em branco, deleta a mesma ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len(aCols)
	If Empty(aCols[nI,1])
		nVezes++
	EndIf
Next nI
If nVezes > 1
	Adel( aCols, Len(aCols) )
	ASize( aCols, Len( aCols) - 1)
	oGetDad:oBrowse:nAt := Len( aCols )
	oGetDad:oBrowse:Refresh()
EndIf
If oGetDad:oBrowse:nAt <> Len(oGetDad:aCols) .And. Empty(oGetDad:aCols[Len(oGetDad:aCols),1])
	Adel( oGetDad:aCols, Len(oGetDad:aCols) )
	ASize( oGetDad:aCols, Len( oGetDad:aCols) - 1)
	oGetDad:oBrowse:nAt := Len( oGetDad:aCols )
	oGetDad:oBrowse:Refresh()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³MontAmed	³ Autor ³ Fernando Godoy		³ Data ³ 8/26/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta array de medicoes de acordo com as caracteristicas	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Padrao atual							  			  ³±±
±±³			 ³ExpC2 - Revisao do Padrao atual				  	  		  ³±±
±±³			 ³ExpC3 - Tipo de Medicao . Exp: Atributo 				  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpA1 - Array em branco com o numero de medicoes 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs		 ³O posicionamento do QM9 esta na funcao que chama esta		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto ³ 15/06/00 ³ Alteracoes para calibrar Tipo de Calibracao Re- ³±±
±±³          ³          ³ logio.                        		  		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MontAmed(cPadrao,cRevPad,cTipCalc)

Local aMed		:= {}
Local aArea 	:= GetArea()
Local cTipo 	:= ""
Local nI 		:= 1
Local nNumMed	:= 1
Local lQuery	:= .F.
Local cEsc      := ""

Default cPadrao := ""
Default cRevPad := Space(2)

lQuery := .T.

If QM9->QM9_NROMED > 0							//COLETA == "S"
	If QM9->QM9_NROMED > 0
		Do Case
			Case QM9->QM9_TIPAFE $ "1|4"		//	Simples ou Calibrador
				cTipo := "S"
			Case QM9->QM9_TIPAFE $ "2|5|8"	//	Completa, Soma ou Calibrador Completo
				cTipo := "C"
			Case QM9->QM9_TIPAFE $ "3|9"		//	Pressao ou Relogio
				cTipo := "P"
		EndCase
		dbSelectArea("QM8")
		dbSetOrder(1)
		If dbSeek(xFilial("QM8")+cMtInstr+cMtRevIns+Dtos(dMtData)+cSeql+;
			QM9->QM9_ESCALA+QM9->QM9_REVESC+cPadrao+cRevPad+StrZero(nNumMed,2))
			If lQuery

				cQuery2 := "SELECT QM8.QM8_VLRINI, QM8.QM8_VLRFIM, QM8.QM8_VLRIND, QM8.QM8_VLRFID, QM8.QM8_ATRIB FROM  " + RetSqlName('QM8')+ " QM8 " 
				cQuery2 += " WHERE QM8.QM8_FILIAL = '"+ FWxFilial("QM8") +"'" 
				If QMT141(cMtInstr)
					cQuery2 += "  	AND QM8.QM8_INSTR = "+FwQtToChr(cMtInstr)
				Else
					cQuery2 += "  	AND QM8.QM8_INSTR = '" + cMtInstr + "' "
				Endif
				cQuery2 += "  	AND QM8.QM8_REVINS  = '" + cMtRevIns + "'   "
			 	cQuery2 += " 	AND QM8.QM8_DATA  = '"+Dtos(dMtData)+"' "
				cQuery2 += " 	AND QM8.QM8_CSEQ  = '"+cSeql+"' "
				If QMT141(QM9->QM9_ESCALA)
					cQuery2 += " 	AND QM8.QM8_ESCALA  = "+FwQtToChr(QM9->QM9_ESCALA)
				Else
					cQuery2 += " 	AND QM8.QM8_ESCALA  = '"+QM9->QM9_ESCALA+"' "
				Endif
				cQuery2 += " 	AND QM8.QM8_REVESC  = '"+QM9->QM9_REVESC+"' "
				cQuery2 += " 	AND QM8.QM8_REVPAD  = '"+cRevPad+"' "
				If QMT141(cPadrao)
					cQuery2 += " 	AND QM8.QM8_PADRAO  = "+FwQtToChr(cPadrao)
				Else
					cQuery2 += " 	AND QM8.QM8_PADRAO  = '"+cPadrao+"' "
				Endif
				cQuery2 += " 	AND QM8.D_E_L_E_T_ <> '*'"
				cQuery2 += "    ORDER BY "+SqlOrder(IndexKey())
		 		cQuery2 := ChangeQuery(cQuery2)

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),"QM8QMT",.T.,.T.)

		 		While QM8QMT->(!Eof())
					If Upper(Alltrim(cTipCalc)) <> "A"
						If cTipo == "S"
							Aadd(aMed, {QM8QMT->QM8_VLRFIM,.F.})
						Elseif cTipo == "C"
							Aadd(aMed,{QM8QMT->QM8_VLRINI,QM8QMT->QM8_VLRFIM,.F.})
						Elseif cTipo == "P"
							Aadd(aMed, {QM8QMT->QM8_VLRINI,QM8QMT->QM8_VLRFIM,;
								QM8QMT->QM8_VLRIND,QM8QMT->QM8_VLRFID,.F.})
						EndIf
					Else
						Aadd(aMed, {QM8QMT->QM8_ATRIB,.F.})
					EndIf
					dbSkip()
				EndDo

				QM8QMT->(DBCLOSEAREA())

			Else

				While !Eof() .And. xFilial("QM8")+cMtInstr+cMtRevIns+Dtos(dMtData)+cSeql+;
					QM9->QM9_ESCALA+QM9->QM9_REVESC+cPadrao+cRevPad==;
					QM8->QM8_FILIAL+QM8->QM8_INSTR+QM8->QM8_REVINS+;
					Dtos(QM8->QM8_DATA)+QM8->QM8_CSEQ+QM8->QM8_ESCALA+QM8->QM8_REVESC+;
					QM8->QM8_PADRAO+QM8->QM8_REVPAD
						If Upper(Alltrim(cTipCalc)) <> "A"
							If cTipo == "S"
								Aadd(aMed, {QM8->QM8_VLRFIM,.F.})
							Elseif cTipo == "C"
								Aadd(aMed,{QM8->QM8_VLRINI,QM8->QM8_VLRFIM,.F.})
							Elseif cTipo == "P"
								Aadd(aMed, {QM8->QM8_VLRINI,QM8->QM8_VLRFIM,;
									QM8->QM8_VLRIND,QM8->QM8_VLRFID,.F.})
							EndIf
						Else
							Aadd(aMed, {QM8->QM8_ATRIB,.F.})
						EndIf
						nNumMed++
					dbSkip()
				EndDo
				
			Endif

		Else
		
			For nI := 1 To QM9->QM9_NROMED
				If Upper(Alltrim(cTipCalc)) <> "A"
					If cTipo == "S"
						Aadd(aMed, {Criavar("QM8_VLRFIM"),.F.} )
					Elseif cTipo == "C"
						Aadd(aMed, {Criavar("QM8_VLRINI"),Criavar("QM8_VLRFIM"),.F.} )
					Elseif cTipo == "P"
						Aadd(aMed, {Criavar("QM8_VLRINI"),Criavar("QM8_VLRFIM"),;
							Criavar("QM8_VLRIND"),Criavar("QM8_VLRFID"),.F.} )
					EndIf
				Else
					Aadd(aMed, {Criavar("QM8_ATRIB"),.F.} )
				EndIf
			Next nI
		EndIf
	Else
		Aadd(aMed, {Criavar("QM8_ATRIB"),.F.} )
	EndIf
Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso for padrao externo Criava medicoes como atributo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Alltrim(cPadrao) == "PADRAOEXT"
		dbSelectArea("QM8")
		dbSetOrder(1)
		If dbSeek(xFilial("QM8")+cMtInstr+cMtRevIns+Dtos(dMtData)+cSeql+;
			QM9->QM9_ESCALA+QM9->QM9_REVESC+cPadrao+cRevPad+StrZero(nNumMed,2))

			Aadd(aMed, {QM8->QM8_ATRIB,.F.} )
		Else
			Aadd(aMed, {Criavar("QM8_ATRIB"),.F.} )
		Endif
	Else
		Aadd(aMed, {Criavar("QM8_ATRIB"),.F.} )
	EndIf
EndIf

RestArea(aArea)

Return aMed

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³MontTexto ³ Autor ³ Fernando Godoy		³ Data ³ 8/26/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna o texto gravado para cada padrao.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Escala atual										  ³±±
±±³			 ³ExpC2 - Padrao atual										  ³±±
±±³			 ³ExpC3 - Revisao da escala									  ³±±
±±³			 ³ExpC4 - Revisao do padrao									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpA1 - Array com a chave e Texto.						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MontTexto(cEscala,cPadrao,cRevEsc,cRevPad)
Local cChave	:= CriaVar("QM7_CHAVE",.F.)
Local aArea 	:= GetArea()
Local cTexto	:= ""
Local aTexto	:= {}
Local nOrderQm7:= 1
Local nRecnoQm7:= 1

dbSelectArea("QM7")
nOrderQm7:= IndexOrd()
nRecnoQm7:= Recno()
dbSetOrder(1)

If dbSeek(xFilial("QM7")+cMtInstr+cMtRevIns+Dtos(dMtData)+cSeql+cEscala+cRevEsc+cPadrao+cRevPad)
	cChave := QM7->QM7_CHAVE
	cTexto := QA_Rectxt(cChave,"QMTA140O",1,75,"QA2") 
Else
	cTexto := CriaVar("QA2_TEXTO",.F.)
EndIf

Aadd(aTexto,{cChave,cTexto})

dbSelectArea("QM7")
dbSetOrder(nOrderQm7)
dbGoto(nRecnoQm7)

RestArea(aArea)

Return aTexto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³MontPSec	³ Autor ³ Godoy / Wanderley		³ Data ³ 8/28/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta array de Padroes Secundarios da medicao				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Escala utilizada 									  ³±±
±±³			 ³ExpC2 - Padrao utilizado 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Array contendo os PS								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ A140CarMed												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto ³ 17/05/00 ³ Inclusao do parâmetro : 				  		  ³±±
±±³          ³          ³ ExpD1 : Data da última calibração          	  ³±±
±±³          ³          ³ Busca o Padrão Secundário da última calibração  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MontPSec(cEscala,cPadrao,dDatAnt,cSeqs,cUnPd)

Local aPS		:= {}
Local aArea 	:= GetArea()
Local laPS		:= .F.
Local nIncer	:= 0
Local nDec		:= 0
Local cSeqa		:= ""
Local cSeqPr	:= ""
Local nPdsec	:= 0
Local aAreaQM7  := QM7->(GetArea())
Local dDataPr
Local cRevPr	:= ""
Local cQM6Instr := ""
Local lFzQ6		:= .F.					
Local lSugPds	:= GetMv("MV_QSUPADS") == "1"
Local cEscSe	:= ""
Local cRvcSe	:= ""
Local nQM9Reg   := QM9->(RecNo())
Local nQM9Rec   := QM9->(IndexOrd())
Local cEscSec   := ""
Local cRevEsc   := ""
Local dQMSdat	:= ""
Local lJaPas	:= .f.
Local cUnpMed	:= ""
Local nQmsRec	:= 0
Local nX    	:= 0
Local lQSOMINC := SuperGetMv("MV_QSOMINC",.F.,.F.) //Soma o valor da incerteza total para o calculo da incerteza padrão secundario (.T./.F.).

dbSelectArea("QMS")
dbSetOrder(3)

aGrvSeq := {}

If lSugPds
	If Inclui
		If dbSeek(xFilial("QMS")+cMtInstr)
			dQMSdat := dMtData                   
			While !Eof() .And. xFilial("QMS")+cMtInstr == QMS->QMS_FILIAL+QMS->QMS_INSTR
				If Inclui //Somente em caso de inclusao procuro a data que me satisfaca no caso de alteracao deve-se ser a data exata.
					If DtoS(QMS->QMS_DATA) <= DTOS(dMtData) //.and. DtoS(QMS->QMS_DATA) <> DtoS(dQMSdat)
						If QMS->QMS_ESCALA+QMS->QMS_PONTO == cEscala+cPadrao
							dQMSdat := QMS->QMS_DATA
							nQMSRec := QMS->(RecNo())
							cRvsInt := QMS->QMS_REVINS
						Endif
					Endif   
				Else
					If DtoS(QMS->QMS_DATA) == DTOS(dMtData)
						nQMSRec := QMS->(RecNo())  
						cRvsInt := QMS->QMS_REVINS						
						Exit
					Endif
				Endif
				dbSelectArea("QMS")
				dbSkip()
			Enddo
			If nQMSRec > 0    
				QMS->(dbSetOrder(1))
				If dbSeek(xFilial("QMS")+cMtInstr+cRvsInt+DTOS(dQMSdat)+cEscala+cPadrao)
					While QMS->(!Eof()) .and. xFilial("QMS")+cMtInstr+cRvsInt+DTOS(dQMSdat)+;
						cEscala+cPadrao == QMS->QMS_FILIAL+QMS->QMS_INSTR+QMS->QMS_REVINS+DtoS(QMS->QMS_DATA)+QMS->QMS_ESCALA+QMS->QMS_PONTO
							If Inclui 
								dbSelectArea("QM6")
								dbSetOrder(4)
								If dbSeek(xFilial("QM6")+QMS->QMS_PADSEC)
									While QM6->(!Eof())							
										If DtoS(QM6->QM6_DATA) <= DtoS(dMtData)
											cSeqa		:= QM6->QM6_CSEQ
											dDataPr		:= QM6->QM6_DATA
											cRevPr		:= QM6->QM6_REVINS    
											cQM6Instr	:= QM6->QM6_INSTR                      
											If QMTXSTAT(QM6->QM6_STATUS)
												lFzQ6	:= .T.					
											Endif
											Exit
										Endif
							    		dbSelectArea("QM6")
								   	dbSkip()
							    	Enddo
								Endif												

								If lFzQ6
									nIncer  := - 1
									nDec    := 0
									cEscSec := ""
									cRevEsc := ""
									dbSelectArea("QM7")
									dbSetOrder(1)
									If dbSeek(xFilial("QM7")+cQM6Instr+cRevPr+DtoS(dDataPr)+cSeqa)
										While QM7->(!Eof()) .and. xFilial("QM7")+cQM6Instr+cRevPr+Dtos(dDataPr)+cSeqa ==;
											QM7->QM7_FILIAL+QM7->QM7_INSTR+QM7->QM7_REVINS+DtoS(QM7->QM7_DATA)+QM7->QM7_CSEQ									
											If Alltrim(QMS->QMS_ESCPAD) == Alltrim(QM7->QM7_ESCALA) .and.;
												Alltrim(QM7->QM7_CSEQ) == Alltrim(cSeqa)
												laPs := .T.
												If ( SuperVal(QM7->QM7_INCERT) > SuperVal(nIncer) )
													nIncer := SuperVal(QM7->QM7_INCERT)																	
													nDec   := QA_NUMDEC(QM7->QM7_INCERT)
													nIncer := StrTran(Str(nIncer,Len(QM7->QM7_INCERT),nDec),".",",")
													cEscSec := QM7->QM7_ESCALA
													cRevEsc := QM7->QM7_REVESC
												Endif	
											Endif             	
											dbSelectArea("QM7")
											dbSetOrder(1)
											dbSkip()
										Enddo			
										If laPS 
											nPdSec	:= Ascan(aPs, { |x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(QMS->QMS_PADSEC)+Alltrim(QMS->QMS_ESCPAD)})													
											If nPdSec == 0
												dbSelectArea("QM9")
												dbSetOrder(1)
												If dbSeek(xFilial("QM9")+cEscSec+Inverte(cRevEsc))
													If !Empty(cUnPd)
														If cUnPd <> QM9->QM9_UNIMED
															dbSelectArea("SAP")
															dbSetOrder(1)
															If dbSeek(xFilial("SAP")+QM9->QM9_UNIMED+cUnPd)
																nIncer := SuperVal(nIncer) * SAP->AP_COEF                   
																nIncer := StrTran(Str(nIncer,Len(QM7->QM7_INCERT),nDec),".",",")
															Endif
														Endif      
													Endif
												Endif
												Aadd( aPs , { QMS->QMS_PADSEC, QMS->QMS_ESCPAD,nIncer,.F. })
											Endif	
										Endif	
									Endif
								Endif
							Endif	
					dbSelectArea("QMS")
					dbSkip()
				EndDo
			Endif                      
		Endif
	Endif
	Else //Caso de uma alteracao, busca os registros direto do QMS
		QMS->(dbSetOrder(1))
		If dbSeek(xFilial("QMS")+cMtInstr+cMtRevIns+DtoS(dMtData))
			While !Eof() .And. xFilial("QMS")+cMtInstr+cMtRevIns+DtoS(dMtData) ==;
				QMS->QMS_FILIAL+QMS->QMS_INSTR+QMS->QMS_REVINS+DtoS(QMS->QMS_DATA)
				If Alltrim(QMS->QMS_CSEQ) == Alltrim(cSeqs)
					If Alltrim(QMS->QMS_ESCALA)+Alltrim(QMS->QMS_PONTO) == Alltrim(cEscala)+Alltrim(cPadrao)
						If Empty(QMS->QMS_CSEQPR)
							cSeqPr := "00"
						Else
							cSeqPr := QMS->QMS_CSEQPR	
						Endif
						nPdSec	:= Ascan(aPs, { |x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(QMS->QMS_PADSEC)+Alltrim(QMS->QMS_ESCPAD)})													
						If nPdSec == 0
							Aadd( aPs , { QMS->QMS_PADSEC, QMS->QMS_ESCPAD,QMS->QMS_INCERT,.F. })
							laPs := .T.							
						Endif	
					Endif
				Endif
			dbSelectArea("QMS")
			dbSkip()
			EndDo
		Else
			If dbSeek(xFilial("QMS")+cMtInstr+cMtRevIns+DTOS(dDatAnt)+cSeql)
				While !Eof() .And. xFilial("QMS")+cMtInstr+cMtRevIns+DtoS(dDatAnt)+cSeqs ==;
					QMS->QMS_FILIAL+QMS->QMS_INSTR+QMS->QMS_REVINS+DtoS(QMS->QMS_DATA)+QMS->QMS_CSEQ
					If a141VlPads(cMtInstr,cEscala)	// Verifica se o padrao e valido
	    			    If Alltrim(QMS->QMS_ESCALA)+Alltrim(QMS->QMS_PONTO) == Alltrim(cEscala)+Alltrim(cPadrao)
							If Empty(QMS->QMS_CSEQPR)
								cSeqPr := "00"
							Else
								cSeqPr := QMS->QMS_CSEQPR
							Endif
							If Alltrim(cSeqPr) == 	Alltrim(QM6->QM6_CSEQ)
								Aadd( aPs , { QMS->QMS_PADSEC, QMS->QMS_ESCPAD,QMS->QMS_INCERT,.F. })
			        			laPs := .T.
							Endif											
						Endif
					EndIf
					dbSelectArea("QMS")
					dbSkip()
				EndDo
			EndIf
		EndIf
	Endif
Else
	QMS->(dbSetOrder(1))
	If Inclui
		If dbSeek(xFilial("QMS")+cMtInstr+cMtRevIns)
			dQMSdat := dMtData                   
			While !Eof() .And. xFilial("QMS")+cMtInstr+cMtRevIns == QMS->QMS_FILIAL+QMS->QMS_INSTR+QMS->QMS_REVINS
				If Inclui //Somente em caso de inclusao procuro a data que me satisfaca no caso de alteracao deve-se ser a data exata.
					If DtoS(QMS->QMS_DATA) <= DTOS(dMtData) //.and. DtoS(QMS->QMS_DATA) <> DtoS(dQMSdat)
						If QMS->QMS_ESCALA+QMS->QMS_PONTO == cEscala+cPadrao
							dQMSdat := QMS->QMS_DATA
							nQMSRec := QMS->(RecNo())
						Endif
					Endif   
				Else
					If DtoS(QMS->QMS_DATA) == DTOS(dMtData)
						nQMSRec := QMS->(RecNo())  
						Exit
					Endif
				Endif
				dbSelectArea("QMS")
				dbSkip()
			Enddo
			If nQMSRec > 0
				If dbSeek(xFilial("QMS")+cMtInstr+cMtRevIns+DTOS(dQMSdat)+cEscala+cPadrao)
					While QMS->(!Eof()) .and. xFilial("QMS")+cMtInstr+cMtRevIns+DTOS(dQMSdat)+;
						cEscala+cPadrao == QMS->QMS_FILIAL+QMS->QMS_INSTR+QMS->QMS_REVINS+DtoS(QMS->QMS_DATA)+QMS->QMS_ESCALA+QMS->QMS_PONTO
						If a141VlPadS(cMtInstr,cEscala,QMS->QMS_PADSEC,QMS->QMS_DATA)	// Verifica se o padrao eh valido
							If Inclui 
								dbSelectArea("QM6")
								dbSetOrder(4)
								If dbSeek(xFilial("QM6")+QMS->QMS_PADSEC)
									While QM6->(!Eof())							
										If DtoS(QM6->QM6_DATA) <= DtoS(dMtData)
											cSeqa		:= QM6->QM6_CSEQ
											dDataPr		:= QM6->QM6_DATA
											cRevPr		:= QM6->QM6_REVINS    
											cQM6Instr	:= QM6->QM6_INSTR                      
											If QMTXSTAT(QM6->QM6_STATUS)
												lFzQ6	:= .T.					
											Endif
											Exit
										Endif
							    		dbSelectArea("QM6")
								   	dbSkip()
							    	Enddo
								Endif												

								If lFzQ6
									nIncer  := - 1
									nDec    := 0
									cEscSec := ""
									cRevEsc := ""
									dbSelectArea("QM7")
									dbSetOrder(1)
									If dbSeek(xFilial("QM7")+cQM6Instr+cRevPr+DtoS(dDataPr)+cSeqa)
										While QM7->(!Eof()) .and. xFilial("QM7")+cQM6Instr+cRevPr+Dtos(dDataPr)+cSeqa ==;
											QM7->QM7_FILIAL+QM7->QM7_INSTR+QM7->QM7_REVINS+DtoS(QM7->QM7_DATA)+QM7->QM7_CSEQ									
											If Alltrim(QMS->QMS_ESCPAD) == Alltrim(QM7->QM7_ESCALA) .and.;
												Alltrim(QM7->QM7_CSEQ) == Alltrim(cSeqa)
												laPs := .T.
												If ( SuperVal(QM7->QM7_INCERT) > SuperVal(nIncer) )
													nIncer := SuperVal(QM7->QM7_INCERT)																	
													nDec   := QA_NUMDEC(QM7->QM7_INCERT)
													nIncer := StrTran(Str(nIncer,Len(QM7->QM7_INCERT),nDec),".",",")
													cEscSec := QM7->QM7_ESCALA
													cRevEsc := QM7->QM7_REVESC
													dDataPr := QM7->QM7_DATA
												Endif	
											Endif             	
											dbSelectArea("QM7")
											dbSetOrder(1)
											dbSkip()
										Enddo			
										If laPS 
											nPdSec	:= Ascan(aPs, { |x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(QMS->QMS_PADSEC)+Alltrim(QMS->QMS_ESCPAD)})													
											If nPdSec == 0
												dbSelectArea("QM9")
												dbSetOrder(1)
												If dbSeek(xFilial("QM9")+cEscSec+Inverte(cRevEsc))
													If !Empty(cUnPd)
														If cUnPd <> QM9->QM9_UNIMED
															dbSelectArea("SAP")
															dbSetOrder(1)
															If dbSeek(xFilial("SAP")+QM9->QM9_UNIMED+cUnPd)
																nIncer := SuperVal(nIncer) * SAP->AP_COEF                   
																nIncer := StrTran(Str(nIncer,Len(QM7->QM7_INCERT),nDec),".",",")
															Endif
														Endif      
													Endif
												Endif
												Aadd( aPs , { QMS->QMS_PADSEC, QMS->QMS_ESCPAD,nIncer,.F.,dDataPr })
											Endif	
										Endif	
									Endif
								Endif
							Else
								Aadd( aPs , { QMS->QMS_PADSEC, QMS->QMS_ESCPAD,QMS->QMS_INCERT,.F.,dDataPr })
								laPS := .T.							
							Endif
						Endif

					dbSelectArea("QMS")
					dbSkip()
				EndDo
			Endif                      
		Endif
	Endif
	Else //Caso de uma alteracao, busca os registros direto do QMS
		If dbSeek(xFilial("QMS")+cMtInstr+cMtRevIns+DtoS(dMtData))
			While !Eof() .And. xFilial("QMS")+cMtInstr+cMtRevIns+DtoS(dMtData) ==;
				QMS->QMS_FILIAL+QMS->QMS_INSTR+QMS->QMS_REVINS+DtoS(QMS->QMS_DATA)
				If Alltrim(QMS->QMS_CSEQ) == Alltrim(cSeqs)
					If Alltrim(QMS->QMS_ESCALA)+Alltrim(QMS->QMS_PONTO) == Alltrim(cEscala)+Alltrim(cPadrao)
						If Empty(QMS->QMS_CSEQPR)
							cSeqPr := "00"
						Else
							cSeqPr := QMS->QMS_CSEQPR	
						Endif
						nPdSec	:= Ascan(aPs, { |x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(QMS->QMS_PADSEC)+Alltrim(QMS->QMS_ESCPAD)})													
						If nPdSec == 0
							Aadd( aPs , { QMS->QMS_PADSEC, QMS->QMS_ESCPAD,QMS->QMS_INCERT,.F. })
							laPs := .T.							
						Endif	
					Endif
				Endif
			dbSelectArea("QMS")
			dbSkip()
			EndDo
		Else
			If dbSeek(xFilial("QMS")+cMtInstr+cMtRevIns+DTOS(dDatAnt)+cSeql)
				While !Eof() .And. xFilial("QMS")+cMtInstr+cMtRevIns+DtoS(dDatAnt)+cSeqs ==;
					QMS->QMS_FILIAL+QMS->QMS_INSTR+QMS->QMS_REVINS+DtoS(QMS->QMS_DATA)+QMS->QMS_CSEQ
					If a141VlPads(cMtInstr,cEscala)	// Verifica se o padrao e valido
	    			    If Alltrim(QMS->QMS_ESCALA)+Alltrim(QMS->QMS_PONTO) == Alltrim(cEscala)+Alltrim(cPadrao)
							If Empty(QMS->QMS_CSEQPR)
								cSeqPr := "00"
							Else
								cSeqPr := QMS->QMS_CSEQPR
							Endif
							If Alltrim(cSeqPr) == 	Alltrim(QM6->QM6_CSEQ)
								Aadd( aPs , { QMS->QMS_PADSEC, QMS->QMS_ESCPAD,QMS->QMS_INCERT,.F. })
			        			laPs := .T.
							Endif											
						Endif
					EndIf
					dbSelectArea("QMS")
					dbSkip()
				EndDo
			EndIf
		EndIf
	Endif
Endif   

QM9->(dbGoTo(nQM9Reg))
QM9->(dbSetOrder(nQM9Rec))

If !laPs
	Aadd(aPs,{Criavar("QMS_PADSEC"),Criavar("QMS_ESCPAD"),Criavar("QMS_INCERT"),.F.})
EndIf

If !lQSOMINC //Soma o valor da incerteza total para o calculo da incerteza padrão secundario (.T./.F.).
	For nX := 1 To Len(aPs)
		If VALTYPE(aPs[nX, Len(aPs[nX])]) $ "D"
			aDel(aPs[nX],Len(aPs[nX])) //Remove a data
			aSize(aPs[nX],Len(aPs[nX])-1) //Restaura tamanho array
		EndIf
	Next nX
EndIf

RestArea(aArea)
RestArea(aAreaQM7)

Return(aPs)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³MontPIns	³ Autor ³ Fernando Godoy	    ³ Data ³ 8/31/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega array com os Instrumentos Utilizados para gravavao  ³±±
±±³			 ³no array principal aMedicoes.						  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Escala utilizada.							  		  ³±±
±±³			 ³ExpC2 - Padrao utilizado.							  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpA1 - Array com os instrumentos utilizados			  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140CarMed() 									  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto ³ 17/05/00 ³ Inclusao do parametro : 				  		  ³±±
±±³          ³          ³ ExpD1 : Data da ultima calibracao          	  ³±±
±±³          ³          ³ Busca o Instr. Utilizado da ultima calibração   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MontPIns(cEscala,cPadrao,dDatAnt,cSeqs,cUnPd)

Local aIu		:= {}
Local aArea 	:= GetArea()
Local laIu		:= .F.
Local nIncer	:= 0
Local nDec		:= 0
Local cSeqa		:= ""
Local cSeqPr	:= ""
Local nPdUIT	:= 0
Local aAreaQM7  := QM7->(GetArea())
Local dDataPr
Local cIndice	:= ""
Local cQM6Instr := ""
Local lFzQI		:= .F.
Local lSugPds	:= GetMv("MV_QSUPADS") == "1"
Local cEscSec	:= ""
Local cRevEsc	:= ""
Local nQM9Reg   := QM9->(RecNo())
Local nQM9Rec   := QM9->(IndexOrd())
Local nQMIRec	:= 0
dbSelectArea("QMI")
dbSetOrder(3)

aGrvSeq := {}

If lSugPds
	If Inclui
		If dbSeek(xFilial("QMI")+cMtInstr)
			dQMSdat := dMtData                   
			While !Eof() .And. xFilial("QMI")+cMtInstr == QMI->QMI_FILIAL+QMI->QMI_INSTR
				If Inclui //Somente em caso de inclusao procuro a data que me satisfaca no caso de alteracao deve-se ser a data exata.
					If DtoS(QMI->QMI_DATA) <= DTOS(dMtData) //.and. DtoS(QMS->QMS_DATA) <> DtoS(dQMSdat)
						If QMI->QMI_ESCALA+QMI->QMI_PONTO == cEscala+cPadrao
							dQMIdat := QMI->QMI_DATA
							nQMIRec := QMI->(RecNo())
							cRvsInt := QMI->QMI_REVINS
						Endif
					Endif   
				Else
					If DtoS(QMI->QMI_DATA) == DTOS(dMtData)
						nQMIRec := QMI->(RecNo())  
						cRvsInt := QMI->QMI_REVINS						
						Exit
					Endif
				Endif
				dbSelectArea("QMI")
				dbSkip()
			Enddo
			If nQMIRec > 0    
				QMI->(dbSetOrder(1))
				If dbSeek(xFilial("QMI")+cMtInstr+cRvsInt+DTOS(dQMIdat)+cSeqs+cEscala+cPadrao)
					While QMI->(!Eof()) .and. xFilial("QMI")+cMtInstr+cRvsInt+DTOS(dQMIdat)+cSeqs+;
						cEscala+cPadrao == QMI->QMI_FILIAL+QMI->QMI_INSTR+QMI->QMI_REVINS+DtoS(QMI->QMI_DATA)+QMI->QMI_CSEQ+QMI->QMI_ESCALA+QMI->QMI_PONTO
							If Inclui 
								dbSelectArea("QM6")
								dbSetOrder(4)
								If dbSeek(xFilial("QM6")+QMI->QMI_INSUT)
									While QM6->(!Eof())							
										If DtoS(QM6->QM6_DATA) <= DtoS(dMtData)
											cSeqa		:= QM6->QM6_CSEQ
											dDataPr		:= QM6->QM6_DATA
											cRevPr		:= QM6->QM6_REVINS    
											cQM6Instr	:= QM6->QM6_INSTR                      
											If QMTXSTAT(QM6->QM6_STATUS)
												lFzQI	:= .T.					
											Endif
											Exit
										Endif
							    		dbSelectArea("QM6")
								   	dbSkip()
							    	Enddo
								Endif												

								If lFzQI
									nIncer  := - 1
									nDec    := 0
									cEscSec := ""
									cRevEsc := ""
									dbSelectArea("QM7")
									dbSetOrder(1)
									If dbSeek(xFilial("QM7")+cQM6Instr+cRevPr+DtoS(dDataPr)+cSeqa)
										While QM7->(!Eof()) .and. xFilial("QM7")+cQM6Instr+cRevPr+Dtos(dDataPr)+cSeqa ==;
											QM7->QM7_FILIAL+QM7->QM7_INSTR+QM7->QM7_REVINS+DtoS(QM7->QM7_DATA)+QM7->QM7_CSEQ									
											If Alltrim(QMI->QMI_ESCPAD) == Alltrim(QM7->QM7_ESCALA) .and.;
												Alltrim(QM7->QM7_CSEQ) == Alltrim(cSeqa)
												laIu := .T.
												If ( SuperVal(QM7->QM7_INCERT) > SuperVal(nIncer) )
													nIncer := SuperVal(QM7->QM7_INCERT)																	
													nDec   := QA_NUMDEC(QM7->QM7_INCERT)
													nIncer := StrTran(Str(nIncer,Len(QM7->QM7_INCERT),nDec),".",",")
													cEscSec := QM7->QM7_ESCALA
													cRevEsc := QM7->QM7_REVESC
												Endif	
											Endif             	
											dbSelectArea("QM7")
											dbSetOrder(1)
											dbSkip()
										Enddo			
										If laIu 
											nPdUIT	:= Ascan(aIu, { |x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(QMI->QMI_INSUT)+Alltrim(QMI->QMI_ESCPAD)})													
											If nPdUIT == 0
												dbSelectArea("QM9")
												dbSetOrder(1)
												If dbSeek(xFilial("QM9")+cEscSec+Inverte(cRevEsc))
													If !Empty(cUnPd)
														If cUnPd <> QM9->QM9_UNIMED
															dbSelectArea("SAP")
															dbSetOrder(1)
															If dbSeek(xFilial("SAP")+QM9->QM9_UNIMED+cUnPd)
																nIncer := SuperVal(nIncer) * SAP->AP_COEF                   
																nIncer := StrTran(Str(nIncer,Len(QM7->QM7_INCERT),nDec),".",",")
															Endif
														Endif      
													Endif
												Endif
												Aadd( aIu , { QMI->QMI_INSUT, QMI->QMI_ESCPAD,nIncer,.F. })
											Endif	
										Endif	
									Endif
								Endif
							Endif	
					dbSelectArea("QMI")
					dbSkip()
				EndDo
			Endif                      
		Endif
	Endif
	Else //Caso de uma alteracao, busca os registros direto do QMI
		QMI->(dbSetOrder(1))
		If dbSeek(xFilial("QMI")+cMtInstr+cMtRevIns+DtoS(dMtData)) //+cSeqs
			While !Eof() .And. xFilial("QMI")+cMtInstr+cMtRevIns+DtoS(dMtData) ==; //+cSeqs
				QMI->QMI_FILIAL+QMI->QMI_INSTR+QMI->QMI_REVINS+DtoS(QMI->QMI_DATA)	 //+QMI->QMI_CSEQ
				If Alltrim(QMI->QMI_CSEQ) == Alltrim(cSeqs)
					If Alltrim(QMI->QMI_ESCALA)+Alltrim(QMI->QMI_PONTO) == Alltrim(cEscala)+Alltrim(cPadrao)
						If Empty(QMI->QMI_CSEQPR)
							cSeqPr := "00"
						Else
							cSeqPr := QMI->QMI_CSEQPR	
						Endif
						nPdUIT	:= Ascan(aIu, { |x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(QMI->QMI_INSUT)+Alltrim(QMI->QMI_ESCPAD)})													
						If nPdUIT == 0
							Aadd( aIu , { QMI->QMI_INSUT, QMI->QMI_ESCPAD,QMI->QMI_INCERT,.F. })
							laIu := .T.							
						Endif	
					Endif
				Endif
			dbSelectArea("QMI")
			dbSkip()
			EndDo
		Else
			If dbSeek(xFilial("QMI")+cMtInstr+cMtRevIns+DTOS(dDatAnt)+cSeqs)
				While !Eof() .And. xFilial("QMI")+cMtInstr+cMtRevIns+DtoS(dDatAnt)+cSeqs ==;
					QMI->QMI_FILIAL+QMI->QMI_INSTR+QMI->QMI_REVINS+DtoS(QMI->QMI_DATA)+QMI->QMI_CSEQ
					If a141VlIu(cMtInstr,cEscala)// Verifica se o padrao e valido
	    			    If Alltrim(QMI->QMI_ESCALA)+Alltrim(QMI->QMI_PONTO) == Alltrim(cEscala)+Alltrim(cPadrao)
							If Empty(QMI->QMI_CSEQPR)
								cSeqPr := "00"
							Else
								cSeqPr := QMI->QMI_CSEQPR
							Endif
							If Alltrim(cSeqPr) == 	Alltrim(QM6->QM6_CSEQ)
								Aadd( aIu , { QMI->QMI_INSUT, QMI->QMI_ESCPAD,QMI->QMI_INCERT,.F. })
			        			laIu := .T.
							Endif											
						Endif
					EndIf
					dbSelectArea("QMI")
					dbSkip()
				EndDo
			EndIf
		EndIf
	Endif
Else
	QMI->(dbSetOrder(1))
	If Inclui
		If dbSeek(xFilial("QMI")+cMtInstr+cMtRevIns)
			dQMIdat := dMtData                   
			While !Eof() .And. xFilial("QMI")+cMtInstr+cMtRevIns == QMI->QMI_FILIAL+QMI->QMI_INSTR+QMI->QMI_REVINS
				If Inclui //Somente em caso de inclusao procuro a data que me satisfaca no caso de alteracao deve-se ser a data exata.
					If DtoS(QMI->QMI_DATA) <= DTOS(dMtData) //.and. DtoS(QMS->QMS_DATA) <> DtoS(dQMSdat)
						If QMI->QMI_ESCALA+QMI->QMI_PONTO == cEscala+cPadrao
							dQMIdat := QMI->QMI_DATA
							nQMIRec := QMI->(RecNo())
						Endif
					Endif   
				Else
					If DtoS(QMI->QMI_DATA) == DTOS(dMtData)
						nQMIRec := QMI->(RecNo())  
						Exit
					Endif
				Endif
				dbSelectArea("QMI")
				dbSkip()
			Enddo
			If nQMIRec > 0
				If dbSeek(xFilial("QMI")+cMtInstr+cMtRevIns+DTOS(dQMIdat)+cSeqs+cEscala+cPadrao)
					While QMI->(!Eof()) .and. xFilial("QMI")+cMtInstr+cMtRevIns+DTOS(dQMIdat)+cSeqs+;
						cEscala+cPadrao == QMI->QMI_FILIAL+QMI->QMI_INSTR+QMI->QMI_REVINS+DtoS(QMI->QMI_DATA)+QMI->QMI_CSEQ+QMI->QMI_ESCALA+QMI->QMI_PONTO
							If a141VlIu(cMtInstr,cEscala,QMI->QMI_INSUT,QMI->QMI_DATA)	// Verifica se o padrao eh valido
							If Inclui 
								dbSelectArea("QM6")
								dbSetOrder(4)
								If dbSeek(xFilial("QM6")+QMI->QMI_INSUT)
									While QM6->(!Eof())							
										If DtoS(QM6->QM6_DATA) <= DtoS(dMtData)
											cSeqa		:= QM6->QM6_CSEQ
											dDataPr		:= QM6->QM6_DATA
											cRevPr		:= QM6->QM6_REVINS    
											cQM6Instr	:= QM6->QM6_INSTR                      
											If QMTXSTAT(QM6->QM6_STATUS)
												lFzQI	:= .T.					
											Endif
											Exit
										Endif
							    		dbSelectArea("QM6")
								   	dbSkip()
							    	Enddo
								Endif												

								If lFzQI
									nIncer  := - 1
									nDec    := 0
									cEscSec := ""
									cRevEsc := ""
									dbSelectArea("QM7")
									dbSetOrder(1)
									If dbSeek(xFilial("QM7")+cQM6Instr+cRevPr+DtoS(dDataPr)+cSeqa)
										While QM7->(!Eof()) .and. xFilial("QM7")+cQM6Instr+cRevPr+Dtos(dDataPr)+cSeqa ==;
											QM7->QM7_FILIAL+QM7->QM7_INSTR+QM7->QM7_REVINS+DtoS(QM7->QM7_DATA)+QM7->QM7_CSEQ									
											If Alltrim(QMI->QMI_ESCPAD) == Alltrim(QM7->QM7_ESCALA) .and.;
												Alltrim(QM7->QM7_CSEQ) == Alltrim(cSeqa)
												laIu := .T.
												If ( SuperVal(QM7->QM7_INCERT) > SuperVal(nIncer) )
													nIncer := SuperVal(QM7->QM7_INCERT)																	
													nDec   := QA_NUMDEC(QM7->QM7_INCERT)
													nIncer := StrTran(Str(nIncer,Len(QM7->QM7_INCERT),nDec),".",",")
													cEscSec := QM7->QM7_ESCALA
													cRevEsc := QM7->QM7_REVESC
												Endif	
											Endif             	
											dbSelectArea("QM7")
											dbSetOrder(1)
											dbSkip()
										Enddo			
										If laIu 
											nPdUIT	:= Ascan(aIu, { |x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(QMI->QMI_INSUT)+Alltrim(QMI->QMI_ESCPAD)})													
											If nPdUIT == 0
												dbSelectArea("QM9")
												dbSetOrder(1)
												If dbSeek(xFilial("QM9")+cEscSec+Inverte(cRevEsc))
													If !Empty(cUnPd)
														If cUnPd <> QM9->QM9_UNIMED
															dbSelectArea("SAP")
															dbSetOrder(1)
															If dbSeek(xFilial("SAP")+QM9->QM9_UNIMED+cUnPd)
																nIncer := SuperVal(nIncer) * SAP->AP_COEF                   
																nIncer := StrTran(Str(nIncer,Len(QM7->QM7_INCERT),nDec),".",",")
															Endif
														Endif      
													Endif
												Endif
												Aadd( aIu , { QMI->QMI_INSUT, QMI->QMI_ESCPAD,nIncer,.F. })
											Endif	
										Endif	
									Endif
								Endif
							Endif	
						Else
							Aadd( aIu , { QMI->QMI_INSUT, QMI->QMI_ESCPAD,;
							QMI->QMI_INCERT,.F. })
							laIu := .T.
						Endif

					dbSelectArea("QMI")
					dbSkip()
				EndDo
			Endif                      
		Endif
	Endif
	Else //Caso de uma alteracao, busca os registros direto do QMI
		If dbSeek(xFilial("QMI")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeqs)
			While !Eof() .And. xFilial("QMI")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeqs ==;
				QMI->QMI_FILIAL+QMI->QMI_INSTR+QMI->QMI_REVINS+DtoS(QMI->QMI_DATA)+QMI->QMI_CSEQ
				If Alltrim(QMI->QMI_CSEQ) == Alltrim(cSeqs)
					If Alltrim(QMI->QMI_ESCALA)+Alltrim(QMI->QMI_PONTO) == Alltrim(cEscala)+Alltrim(cPadrao)
						If Empty(QMI->QMI_CSEQPR)
							cSeqPr := "00"
						Else
							cSeqPr := QMI->QMI_CSEQPR	
						Endif
						nPdUIT	:= Ascan(aIu, { |x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(QMI->QMI_INSUT)+Alltrim(QMI->QMI_ESCPAD)})													
						If nPdUIT == 0
							Aadd( aIu , { QMI->QMI_INSUT, QMI->QMI_ESCPAD,QMI->QMI_INCERT,.F. })
							laIu := .T.							
						Endif	
					Endif
				Endif
			dbSelectArea("QMI")
			dbSkip()
			EndDo
		Else
			If dbSeek(xFilial("QMI")+cMtInstr+cMtRevIns+DTOS(dDatAnt)+cSeqs)
				While !Eof() .And. xFilial("QMI")+cMtInstr+cMtRevIns+DtoS(dDatAnt)+cSeqs ==;
					QMI->QMI_FILIAL+QMI->QMI_INSTR+QMI->QMI_REVINS+DtoS(QMI->QMI_DATA)+QMI->QMI_CSEQ
					If a141VlIu(cMtInstr,cEscala)// Verifica se o padrao e valido
	    			    If Alltrim(QMI->QMI_ESCALA)+Alltrim(QMI->QMI_PONTO) == Alltrim(cEscala)+Alltrim(cPadrao)
							If Empty(QMI->QMI_CSEQPR)
								cSeqPr := "00"
							Else
								cSeqPr := QMI->QMI_CSEQPR
							Endif
							If Alltrim(cSeqPr) == 	Alltrim(QM6->QM6_CSEQ)
								Aadd( aIu , { QMI->QMI_INSUT, QMI->QMI_ESCPAD,QMI->QMI_INCERT,.F. })
			        			laIu := .T.
							Endif											
						Endif
					EndIf
					dbSelectArea("QMI")
					dbSkip()
				EndDo
			EndIf
		EndIf
	Endif
Endif   

QM9->(dbGoTo(nQM9Reg))
QM9->(dbSetOrder(nQM9Rec))

If !laIu
	Aadd(aIu,{Criavar("QMI_INSUT"),Criavar("QMI_ESCPAD"),Criavar("QMI_INCERT"),.F.})
EndIf

RestArea(aArea)
RestArea(aAreaQM7)

Return(aIu)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³MontNco	³ Autor ³ Fernando Godoy		³ Data ³ 9/1/1998 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta array com as nao conformidades do instrumento 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Escala utilizada.									  ³±±
±±³			 ³ExpC2 - Padrao utilizado.									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpA1 - Array com as nao conformidades					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140ChTree												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MontNco(cEscala,cPadrao)
Local aNco	:= {}
Local aArea := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ha Nao-Conformidades j  existentes para ³
//³ o instrumento.										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QMJ")
dbSetOrder(1)
If dbSeek(xFilial("QMJ")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeql+cEscala+cPadrao)
	While !Eof() .And. xFilial("QMJ")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeql+;
		cEscala+cPadrao == QMJ->QMJ_FILIAL+QMJ->QMJ_INSTR+QMJ->QMJ_REVINS+;
		Dtos(QMJ->QMJ_DATA)+QMJ->QMJ_CSEQ+QMJ->QMJ_ESCALA+QMJ->QMJ_PONTO

		SAG->(dbSeek(xFilial("SAG")+QMJ->QMJ_NAOCON))

		Aadd( aNco , { QMJ->QMJ_NAOCON, SAG->AG_DESCPO,;
			QMJ->QMJ_CLASS,.F. })

		dbSkip()
	EndDo
Else
	Aadd(aNco,{Criavar("QMJ_NAOCON"),Criavar("QMJ_DESC"),;
		Criavar("QMJ_CLASS"),.F.})
Endif

RestArea(aArea)

Return aNco

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³MontITB	³ Autor ³ Wanderley Goncalves   ³ Data ³ 9/8/1998 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta array com as Incertezas do Tipo B 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Escala											  ³±±
±±³			 ³ExpC2 - Padrao											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpA1 - Array com as Incertezas do Tipo B					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140ChTree												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MontITB(cEscala,cPadrao)
Local aITB := {}
Local aArea := GetArea()  
Local nQMxDat := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ha Incertezas Tipo B j  existentes para 			³
//³ o instrumento.(Considerar QMX_CSEQ no QUARK e/ou prox.versao )	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("QMX")
QMX->(DbSetOrder(1))

If lSugIncB
	If QMX->(DbSeek(xFilial("QMX")+cMtInstr+cMtRevIns))
		Do while xFilial("QMX")+cMtInstr+cMtRevIns	== QMX->QMX_FILIAL+QMX->QMX_INSTR+QMX->QMX_REVINS
			If QMX->QMX_DATA <= dMtData
				If QMX->QMX_ESCALA+QMX->QMX_PONTO+QMX->QMX_CSEQ == cEscala+cPadrao+cSeql
					nQMxDat := QMX->(RecNo())
				Endif
			Else
				Exit
			Endif
			If nQMxDat > 0
		   		QMX->(dbGoTo(nQMxDat))	
					If QMV->(DbSeek(xFilial("QMV")+QMX->QMX_CODINC))
						If Alltrim(QMX->QMX_CSEQ) == Alltrim(cSeql)
							If !Inclui
									Aadd( aITB , { QMX->QMX_CODINC, QMV->QMV_SIMB, QMV->QMV_FONTE,;
									QMX->QMX_VALINC,QMV->QMV_DISTR, QMX->QMX_DIV,;
									QMX->QMX_CSENS,QMX->QMX_UI,QMX->QMX_VI,.F. })      
							Else    	
									If !Empty(GetSx3Cache("QMV_VALINC","X3_TAMANHO")) .Or. GetRPORelease() > "12.1.027"
										Aadd( aITB , { QMW->QMW_CODINC, QMV->QMV_SIMB, ;
													QMV->QMV_FONTE,  ; 
													QMV->QMV_VALINC, QMV->QMV_DISTR,  ;
													QMV->QMV_DIV, QMV->QMV_CSENS,;
													CriaVar("QMX_UI"),CriaVar("QMX_VI"),.F. })
									Else
										Aadd( aITB , { QMX->QMX_CODINC, QMV->QMV_SIMB, QMV->QMV_FONTE,;
										CriaVar("QMX_VALINC"), QMV->QMV_DISTR, QMX->QMX_DIV,;
										QMX->QMX_CSENS,CriaVar("QMX_UI"),CriaVar("QMX_VI"),.F. })      
									EndIf 
							Endif				
					    Endif
			        Endif
			    nQMxDat:=0
			Endif
			QMX->(dbSkip())
		Enddo	
       /*
		If nQMxDat > 0
			QMX->(dbGoTo(nQMxDat))	
			If QMV->(DbSeek(xFilial("QMV")+QMX->QMX_CODINC))
				If Alltrim(QMX->QMX_CSEQ) == Alltrim(cSeql)//Alltrim(QMX->QMX_ESCALA+QMX->QMX_PONTO) == Alltrim(cEscala+cPadrao)
					If !Inclui
						Aadd( aITB , { QMX->QMX_CODINC, QMV->QMV_SIMB, QMV->QMV_FONTE,;
									QMX->QMX_VALINC,QMV->QMV_DISTR, QMX->QMX_DIV,;
									QMX->QMX_CSENS,QMX->QMX_UI,QMX->QMX_VI,.F. })      
					Else    	
						Aadd( aITB , { QMX->QMX_CODINC, QMV->QMV_SIMB, QMV->QMV_FONTE,;
									CriaVar("QMX_VALINC"),QMV->QMV_DISTR, QMX->QMX_DIV,;
									QMX->QMX_CSENS,CriaVar("QMX_UI"),CriaVar("QMX_VI"),.F. })      
					Endif				
				Endif
									
			Else
				//Caso nao exista Incerteza do Tipo B para escala/padrao, verifica se existe incerteza de tipo B para a respectiva familia.
				dbSelectArea("QMW")
				DbSetOrder(1)
				dbSelectArea("QM2")
				DbSetOrder(1)
				If dbseek(xFilial("QM2")+cMtInstr+Inverte(cMtRevIns))
					If QMW->(DbSeek(xFilial("QMW")+QM2->QM2_TIPO))
						While QMW->(!Eof()) .And. xFilial("QMW")+QM2->QM2_TIPO==;
							QMW->QMW_FILIAL+QMW->QMW_TIPO
							If QMV->(DbSeek(xFilial("QMV")+QMW->QMW_CODINC))
								Aadd( aITB , { QMW->QMW_CODINC, QMV->QMV_SIMB, ;
											QMV->QMV_FONTE, CriaVar("QMX_VALINC"),QMV->QMV_DISTR,;
											QMV->QMV_DIV, QMV->QMV_CSENS,;
											CriaVar("QMX_UI"),CriaVar("QMX_VI"),.F. })
							EndIf
							QMW->(dbSkip())
						EndDo
					Else
						Aadd( aITB, { CriaVar("QMX_CODINC"), CriaVar("QMX_SIMB"),;
							CriaVar("QMX_FONTE") , CriaVar("QMX_VALINC"), CriaVar("QMX_DISTR"),;
							CriaVar("QMX_DIV"), CriaVar("QMX_CSENS"), CriaVar("QMX_UI"),;
							CriaVar("QMX_VI"), .F.} )
					EndIf
				Endif			
			EndIf
			*/
	Else
		dbSelectArea("QMW")
		DbSetOrder(1)
		dbSelectArea("QM2")
		DbSetOrder(1)
		If dbseek(xFilial("QM2")+cMtInstr+Inverte(cMtRevIns))
			If QMW->(DbSeek(xFilial("QMW")+QM2->QM2_TIPO))
				While QMW->(!Eof()) .And. xFilial("QMW")+QM2->QM2_TIPO==;
					QMW->QMW_FILIAL+QMW->QMW_TIPO
					If QMV->(DbSeek(xFilial("QMV")+QMW->QMW_CODINC))
						If  !Empty(GetSx3Cache("QMV_VALINC","X3_TAMANHO")) .Or. GetRPORelease() > "12.1.027"
							Aadd( aITB , { QMW->QMW_CODINC, QMV->QMV_SIMB, ;
										QMV->QMV_FONTE,  ; 
										QMV->QMV_VALINC, QMV->QMV_DISTR,  ;
										QMV->QMV_DIV, QMV->QMV_CSENS,;
										CriaVar("QMX_UI"),CriaVar("QMX_VI"),.F. })
						Else
							Aadd( aITB , { QMW->QMW_CODINC, QMV->QMV_SIMB, ;
										QMV->QMV_FONTE,  ; 
										CriaVar("QMX_VALINC"), QMV->QMV_DISTR,  ;
										QMV->QMV_DIV, QMV->QMV_CSENS,;
										CriaVar("QMX_UI"),CriaVar("QMX_VI"),.F. })
						EndIf
					EndIf
					QMW->(dbSkip())
				EndDo
			Else
				Aadd( aITB, { CriaVar("QMX_CODINC"), CriaVar("QMX_SIMB"),;
					CriaVar("QMX_FONTE") , CriaVar("QMX_VALINC"), CriaVar("QMX_DISTR"),;
					CriaVar("QMX_DIV"), CriaVar("QMX_CSENS"), CriaVar("QMX_UI"),;
					CriaVar("QMX_VI"), .F.} )
			EndIf
		Endif
	EndIf
Else
	If QMX->(DbSeek(xFilial("QMX")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeql+cEscala+cPadrao))
		Do while xFilial("QMX")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeql+cEscala+cPadrao ==;
			QMX->QMX_FILIAL+QMX->QMX_INSTR+QMX->QMX_REVINS+DtoS(QMX->QMX_DATA)+QMX->QMX_CSEQ+;
			QMX->QMX_ESCALA+QMX->QMX_PONTO
			If QMV->(DbSeek(xFilial("QMV")+QMX->QMX_CODINC))
				If Alltrim(QMX->QMX_CSEQ) == Alltrim(cSeql)//Alltrim(QMX->QMX_ESCALA+QMX->QMX_PONTO) == Alltrim(cEscala+cPadrao)
					Aadd( aITB , { QMX->QMX_CODINC, QMV->QMV_SIMB, QMV->QMV_FONTE,;
							QMX->QMX_VALINC,QMV->QMV_DISTR, QMX->QMX_DIV,;
							QMX->QMX_CSENS,QMX->QMX_UI,QMX->QMX_VI,.F. })
				Endif					
			EndIf
			QMX->(DbSkip())
		EndDo
	Else
		dbSelectArea("QMW")
		DbSetOrder(1)
		dbSelectArea("QM2")
		DbSetOrder(1)
		If dbseek(xFilial("QM2")+cMtInstr+Inverte(cMtRevIns))
			If QMW->(DbSeek(xFilial("QMW")+QM2->QM2_TIPO))
				While QMW->(!Eof()) .And. xFilial("QMW")+QM2->QM2_TIPO==;
					QMW->QMW_FILIAL+QMW->QMW_TIPO
					If QMV->(DbSeek(xFilial("QMV")+QMW->QMW_CODINC))
						If  !Empty(GetSx3Cache("QMV_VALINC","X3_TAMANHO")) .Or. GetRPORelease() > "12.1.027"
							Aadd( aITB , { QMW->QMW_CODINC, QMV->QMV_SIMB, ;
										QMV->QMV_FONTE,  ; 
										QMV->QMV_VALINC, QMV->QMV_DISTR,  ;
										QMV->QMV_DIV, QMV->QMV_CSENS,;
										CriaVar("QMX_UI"),CriaVar("QMX_VI"),.F. })
						Else
							Aadd( aITB , { QMW->QMW_CODINC, QMV->QMV_SIMB, ;
										QMV->QMV_FONTE,  ; 
										CriaVar("QMX_VALINC"), QMV->QMV_DISTR,  ;
										QMV->QMV_DIV, QMV->QMV_CSENS,;
										CriaVar("QMX_UI"),CriaVar("QMX_VI"),.F. })
						EndIf
					EndIf
					QMW->(dbSkip())
				EndDo
			Else
				Aadd( aITB, { CriaVar("QMX_CODINC"), CriaVar("QMX_SIMB"),;
					CriaVar("QMX_FONTE") , CriaVar("QMX_VALINC"), CriaVar("QMX_DISTR"),;
					CriaVar("QMX_DIV"), CriaVar("QMX_CSENS"), CriaVar("QMX_UI"),;
					CriaVar("QMX_VI"), .F.} )
			EndIf
		Endif
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se esta vazio para retornar com pelo menos uma linha ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aITB) == 0
	Aadd( aITB, { CriaVar("QMX_CODINC"), CriaVar("QMX_SIMB"),;
		CriaVar("QMX_FONTE") , CriaVar("QMX_VALINC"), CriaVar("QMX_DISTR"),;
		CriaVar("QMX_DIV"), CriaVar("QMX_CSENS"), CriaVar("QMX_UI"),;
		CriaVar("QMX_VI"), .F.} )
EndIf

RestArea(aArea)

Return aITB

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140ShwObs³ Autor ³ Fernando Godoy		³ Data ³ 8/27/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Desenha o GetMemo para a observacao						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Array que vai receber o texto atual				  ³±±
±±³			 ³ExpC1 - Varial com o texto atual ja formatado para a tela   ³±±
±±³			 ³ExpO1 - Handle do Objeto Memo								  ³±±
±±³			 ³ExpC2 - Chave de pesquisa no QA2 - Arquivo de textos		  ³±±
±±³			 ³ExpO2 - Handle da Dialog ativa 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140ChgTree()												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140ShwObs(oFldFix)
Local lVisual	:= Iif(Inclui .Or. Altera,.F.,.T.)
Local oTextos   := NIL
Local aObj 		:= {}
Local oBtnA     := NIL 
Local aSize     := FWGetDialogSize(oMainWnd)                                      
lAtributo := Upper(Alltrim(aMedicoes[nPosAmed,nPosGer,1,3])) == "A"

cTextos	:= aMedicoes[nPosAmed,nPosObs,1,2]
If !aMedicoes[nPosAmed,nPosGer,1,2] $ "4|8"
	If !lAtributo
		lRetUnid := a140TamDec(@nTam,@cNomin,@cUniMed,@nCoef,nPosAmed)
	Endif	
Else 
	lRetUnid := .T.
Endif	

DEFINE SBUTTON oBtnA FROM 170,170 TYPE 1 ENABLE OF oFldFix ACTION oBtnA:SetFocus()

@ 10,35 GET oTextos VAR cTextos   SIZE aSize[3], aSize[3] / 5 OF oFldFix MEMO NO VSCROLL PIXEL FONT oCouNew

If lVisual	// Apenas Visualizacao (Readonly para poder movimentar o scroll)
	oTextos:lReadOnly := .t.
EndIf
//oTextos:bValid := {|| oBtnA:SetFocus(),oBtnA:Refresh(),aMedicoes[nPosAmed,nPosObs,1,2] := cTextos } //bLostFocus
//oTextos:bGotFocus := { || oTextos:nPos := 0,oTextos:Refresh()}
oTextos:SetFocus()
oTextos:Refresh()
//oTextos:Hide()
Aadd(aObj,oTextos)
aObjetos[OBJ_OBSERVACAO] := aObj

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140ShwExt³ Autor ³ Fernando Godoy		³ Data ³ 8/28/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra na telas os gets caso seja medicao externa.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 - Handle da Dialog ativa 							  ³±±
±±³			 ³ExpO2 - Handle do Objeto Laboratorio Externo				  ³±±
±±³			 ³ExpO3 - Handle do Certificado								  ³±±
±±³			 ³ExpN1 - Linha atual no Array aMedicoes					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140ChgTree()												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140ShwExt(oFldFix)
Local cMtLabExt	:= aMedicoes[nPosAmed,nPosExt,1,1]
Local cMtNroCer	:= aMedicoes[nPosAmed,nPosExt,1,2]
Local lVisual	:= Iif(Inclui .Or. Altera,.F.,.T.)
Local oSay1
Local oSay2
Local oGrp
Local oIcon
Local aObj := {}    
Local oNomeLab
Local cNomeLab := Space(20)
Local aSize    := FWGetDialogSize(oMainWnd) 

oGetText := MsNewGetDados():New(900,900,900,900,nTipo,{||AllwaysTrue()},,,,,,,,{||.F.},oFldFix,aHeader,aCols)

@ 10,065 Group oGrp TO aSize[3] / 5, aSize[3] LABEL "" OF oFldFix PIXEL  //88,297
@ .8,009 ICON  oIcon RESOURCE "RPMDES"   OF oFldFix NOBORDER
@ 30,070 SAY   oSay1 PROMPT   STR0010	 OF oFldFix PIXEL SIZE 55,10 //"Laboratório Externo:"
@ 42,070 SAY   oSay2 PROMPT   STR0011	 OF oFldFix PIXEL SIZE 60,10 //"Numero do Certificado:"
@ 28,130 MSGET oLabExt VAR cMtLabExt F3 "QMO   "	VALID Eval( {|| Iif(Empty(cMtLabExt),.T.,Iif(ExistCpo2("QMO",cMtLabExt,1,STR0012),.T.,.F.))}) COLOR CLR_BLUE SIZE 82,10 OF oFldFix  PIXEL  //"Laboratorio nao cadastrado. Informe um valido."

//oLabExt:Disable()
oLabExt:Refresh()
//oGetText := MsGetDados():New(200,200,200,300,nTipo,"AllwaysTrue","AllwaysTrue",,.F.,,,,,,,,,oFolderFix)

//oGrp:Hide() 
//oIcon:Hide()
//oSay1:Hide()           
//oSay2:Hide() 
//oLabExt:Hide() 

Aadd(aObj,oGrp) //1
Aadd(aObj,oIcon) //2
Aadd(aObj,oSay1) //3
Aadd(aObj,oSay2) //4
Aadd(aObj,oLabExt) //5 

@ 30,250 SAY oNomeLab PROMPT cNomeLab SIZE 150,10 OF oFldFix PIXEL //"descrição do laboratório"

@ 40,130 GET oNroCer VAR cMtNroCer SIZE 50,10 OF oFldFix PIXEL
oLabExt:bGotFocus := {|| oLabExt:SetPos(0),oLabExt:Refresh()}
		
oNroCer:bGotFocus	:= { || qmt141NoLab(cMtLabExt,oNomeLab),oNroCer:SetPos(0)} //qmt141NoLab(cMtLabExt,oFolderFix:aDialogs[3])
		
oLabExt:bLostFocus := {|| aMedicoes[nPosAmed,nPosExt,1,1] := oLabExt:cText, oNroCer:SetFocus()}
oNroCer:bLostFocus := {|| aMedicoes[nPosAmed,nPosExt,1,2] := oNroCer:cText, a141ContrFld()}

If lVisual	// Visualizacao
	oLabExt:Disable()
	oNroCer:Disable()
Endif
//oNroCer:Hide()	
Aadd(aObj,oNroCer) //6

@ 36,250 SAY oLbx  PROMPT OemToAnsi(STR0118); //"O destino da calibracao desta escala e INTERNA." 
		SIZE 300,7.5 OF oFldFix PIXEL FONT oArialGr COLOR CLR_HRED
oLbx:lTransparent := .F.
oLbx:Hide()	
Aadd(aObj,oLbx)	//7

Aadd(aObj,oGetText) //8
                       
Aadd(aObj,oNomeLab) //9

aObjetos[ OBJ_MEDEXT ] := aObj

lAtributo := Upper(Alltrim(aMedicoes[nPosAmed,nPosGer,1,3])) == "A"

If !aMedicoes[nPosAmed,nPosGer,1,2] $ "4|8"
	If !lAtributo
		lRetUnid := a140TamDec(@nTam,@cNomin,@cUniMed,@nCoef,nPosAmed)
	Endif	
Else
	lRetUnid := .T.
Endif	

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140ShwSec³ Autor ³ Wanderley /Fernando G.³ Data ³ 28/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastra Padrao Secundario por Medicao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Linha atual do Array aMedicoes					  ³±±
±±³			 ³ExpO1 - Handle do Objeto Getdados 						  ³±±
±±³			 ³ExpO2 - Handle da Dialog ativa.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140ChgTree()												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140ShwSec(oFldFix)
Local aArea    := GetArea()
Local oLbxD    := NIL
Local aObj     := {}
Local aStruQMS := FWFormStruct(3, "QMS",,.F.)[3]
Local nX       := 0
Local aSize    := FWGetDialogSize(oMainWnd)

If Len(aHeadQMS) = 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva a integridade dos campos de Bancos de Dados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX2")  // Posiciona pq. rotinas internas utilizam inf. do SX2
	dbSeek("QMS")
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta vetor Aheader a ser utilizado na getdados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := {}
	For nX := 1 To Len(aStruQMS)
		If aStruQMS[nX,1] $ "QMS_PADSEC|QMS_ESCPAD|QMS_INCERT"
			Aadd(aHeader, Q141GetSX3(aStruQMS[nX,1], "", "") )
		EndIf
	Next nX
	aHeadQMS := aClone(aHeader)		
	RestArea(aArea)
Else
	aHeader := aClone(aHeadQMS)
Endif		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega o Array aCols a partir do Array aMedicoes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aCols 	:= aClone(aMedicoes[nPosAmed,nPosSec])
		
@ 36,21 SAY oLbxD  PROMPT OemToAnsi(STR0119); //"Esta faixa NAO permite digitar padroes secundarios.";
	SIZE 500,7.5 OF oFolderFix:aDialogs[4] PIXEL FONT oArialGr COLOR CLR_HRED 
	Aadd(aObj,oLbxD) //1
	oLbxD:Hide()
oGetSec := MsNewGetDados():New(12,2,(aSize[3] / 2) - 170, (aSize[4] / 2) - 8,nTipo,{|| AllwaysTrue() },,,,,,,,,oFolderFix:aDialogs[4],aHeadQMS,aCols) //GD_INSERT+GD_UPDATE+GD_DELETE

nUsado	:= Len(oGetSec:aCols[1])

//oGetSec := MSGetDados():New(6,2,88,300,nTipo,"AllwaysTrue","AllwaysTrue",,.T.,;
//			,,,,,,,,oFolderFix:aDialogs[4])
oGetSec:oBrowse:bDrawSelect := {|| A140ChgGet( oGetSec,oFolderFix:aDialogs[4] )}
oGetSec:oBrowse:bValid := {|| A140DelNil(oGetSec),oGetSec:ForceRefresh()}//bLostFocus
oGetSec:ForceRefresh()
oGetSec:oBrowse:lDisablePaint := .T.
Aadd(aObj,oGetSec) //2
Aadd(aObj,oFolderFix:aDialogs[4])
aObjetos[OBJ_PADSEC] := aObj

lAtributo := Upper(Alltrim(aMedicoes[nPosAmed,nPosGer,1,3])) == "A"

If !aMedicoes[nPosAmed,nPosGer,1,2] $ "4|8"
	If !lAtributo
		lRetUnid := a140TamDec(@nTam,@cNomin,@cUniMed,@nCoef,nPosAmed)
	Endif	
Else
	lRetUnid := .T.
Endif	
aHeader := {}
aCols	:= {}
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140ShwIns³ Autor ³ Fernando Godoy		³ Data ³ 8/31/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra getdados de Instrumentos Utilizados na tela		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Linha atual do Array aMedicoes					  ³±±
±±³			 ³ExpO1 - Handle do Objeto Getdados 						  ³±±
±±³			 ³ExpO2 - Handle da Dialog ativa.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140ChgTree()												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140ShwIns(oFldFix)

Local aArea := GetArea()
Local oLbx
Local oLbx2
Local aObj := {}
Local aStruQMI := FWFormStruct(3, "QMI",,.F.)[3]
Local nX := 0
Local aSize  := FWGetDialogSize(oMainWnd)

@ 37,73 SAY oLbx	PROMPT OemToAnsi(STR0120)	SIZE 300,7.5 OF oFolderFix:aDialogs[5] PIXEL FONT oArialGr COLOR CLR_HRED //"Essa escala NAO permite utilizar o controle de "
@ 44,73 SAY oLbx2	PROMPT OemToAnsi(STR0121)	SIZE 310,7.5 OF oFolderFix:aDialogs[5] PIXEL FONT oArialGr COLOR CLR_HRED //"instrumento na calibracao de seus pontos"
oLbx:Hide()
oLbx2:Hide()
Aadd(aObj,oLbx) //1
Aadd(aObj,oLbx2)//2	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor Aheader a ser utilizado na getdados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
aHeader := {}
For nX := 1 To Len(aStruQMI)
	If aStruQMI[nX,1] $ "QMI_INSUT |QMI_ESCPAD|QMI_INCERT"
		Aadd(aHeader, Q141GetSX3(aStruQMI[nX,1], "", "") )
	EndIf
Next nX
Aadd(aObj,aHeader)
RestArea(aArea)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega o Array aCols a partir do Array aMedicoes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols 	:= aClone(aMedicoes[nPosAmed,nPosIns])
			
//If Empty(aMedicoes[nPosAmed,nPosIns,1,1])
//oGetIns := MSGetDados():New(3,3,88,300,nTipo,"AllwaysTrue","AllwaysTrue",,.t.,;
//				,,,,,,,,oFolderFix:aDialogs[5]) //oGetIns
//Endif

oGetIns := MsNewGetDados():New(12,2,(aSize[3] / 2) - 170, (aSize[4] / 2) - 8,nTipo,{||AllwaysTrue()},,,,,,,,,oFolderFix:aDialogs[5],aHeader,aCols)

oGetIns:oBrowse:bDrawSelect 	:= {|| A140ChgGet( oGetIns,oFolderFix:aDialogs[5] ) }
oGetIns:oBrowse:bValid := {|| A140DelNil(oGetIns),aMedicoes[nPosAmed,nPosIns] := aClone(oGetIns:aCols),oGetIns:ForceRefresh()} //bLostFocus
oGetIns:ForceRefresh()
oGetIns:oBrowse:lDisablePaint := .T.
nUsado	:= Len(oGetIns:aCols[1])

Aadd(aObj,oGetIns) //4

aObjetos[OBJ_INSTUTIL] := aObj

lAtributo := Upper(Alltrim(aMedicoes[nPosAmed,nPosGer,1,3])) == "A"

If !aMedicoes[nPosAmed,nPosGer,1,2] $ "4|8"
	If !lAtributo
		lRetUnid := a140TamDec(@nTam,@cNomin,@cUniMed,@nCoef,nPosAmed)
	Endif	
Else
	lRetUnid := .T.
Endif	
aHeader := {}
aCols	:= {}
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140ShwNco³ Autor ³ Fernando Godoy		³ Data ³ 8/31/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra Getdados de Nao conformidades na tela				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Linha atual no Array aMedicoes					  ³±±
±±³			 ³ExpO1 - Handle do Objeto Getdados 						  ³±±
±±³			 ³ExpO2 - Handle da Dialog ativa.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140ChgTree()												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140ShwNco(oFldFix)
Local aArea    := GetArea()
Local aStruQMJ := FWFormStruct(3, "QMJ",,.F.)[3]
Local nX       := 0
Local aSize    := FWGetDialogSize(oMainWnd)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX2")  // Posiciona pq. rotinas internas utilizam inf. do SX2
dbSeek("QMJ")
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor Aheader a ser utilizado na getdados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := {}
For nX := 1 To Len(aStruQMJ)
	If aStruQMJ[nX,1] $ "QMJ_NAOCON|QMJ_DESC  |QMJ_CLASS "
		Aadd(aHeader, Q141GetSX3(aStruQMJ[nX,1], "", "") )
	EndIf
Next nX
AAdd(aObj,aHeader) //1
RestArea(aArea)
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega o Array aCols a partir do Array aMedicoes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols 	:= aClone(aMedicoes[nPosAmed,nPosNco])

//oGetNco := MsGetDados():New(3,3,88,300,nTipo,"AllwaysTrue","AllwaysTrue",,.t.,; //212
//		,,,,,,,,oFolderFix:aDialogs[6])
		
oGetNco := MsNewGetDados():New(2,2,(aSize[3] / 2) - 170, (aSize[4] / 2) - 5,nTipo,{||AllwaysTrue()},,,,,,,,,oFolderFix:aDialogs[6],aHeader,aCols)
oGetNco:oBrowse:bDrawSelect 	:= {|| A140ChgGet( oGetNco,oFolderFix:aDialogs[6] ) }
oGetNco:oBrowse:bValid			:= {|| A140DelNil(oGetNco),aMedicoes[nPosAmed,nPosNco] := aClone(oGetNco:aCols),oGetNco:ForceRefresh()}

nUsado	:= Len(oGetNco:aCols[1])

If Inclui .or. Altera
	oGetNco:oBrowse:nOpc := 3
Endif
oGetNco:ForceRefresh()
oGetNco:oBrowse:lDisablePaint := .T.
Aadd(aObj,oGetNco) //2
 
aObjetos[OBJ_NAOCONFOR] := aObj

lAtributo := Upper(Alltrim(aMedicoes[nPosAmed,nPosGer,1,3])) == "A"

If !aMedicoes[nPosAmed,nPosGer,1,2] $ "4|8"
	If !lAtributo
		lRetUnid := a140TamDec(@nTam,@cNomin,@cUniMed,@nCoef,nPosAmed)
	Endif	
Else
	lRetUnid := .T.
Endif	
aHeader := {}
aCols	:= {}
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140ShwPad³ Autor ³ Fernando Godoy	 	³ Data ³ 8/31/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra na tela informacoes sobre o padrao				  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 - Handle da Dialog ativa.					  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140ChgTree()									  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto ³ 15/06/00 ³ Alteracoes para calibrar Tipo de Calibracao Re- ³±±
±±³          ³          ³ logio.                        		  		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140ShwPad(oCbxEsc,oCbxPad,oFolderFix,oDlgPri)

Local nTipoMed 	:= 0
Local lNoColMed	:= .F.	// Coleta ou nao medicoes
Local aResult		:= {}
Local lAtrib_Ok	:= .F.
Local nDesPadP		
Local nInsTotP		
Local lVisual		:= Iif(Inclui .Or. Altera,.F.,.T.)
Local oGrp1
Local oGrp2
Local oGrp4
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oSay9
Local oSay10
Local oSay11
Local oSay12
Local oSay13
Local oSay14
Local oSay15
Local oSay16
Local oSay17
Local oSay18
Local oSay19
Local oSay20
Local oSay21
Local oSay22
Local oSay23
Local oSay24
Local oSay25
Local oSay26
Local oSay27
Local oSay28
Local oSay29
Local oSay30
Local oSay32                
Local oSay33
Local oSay34
Local oBtn
Local oIcon2
Local aObj := {}
Local nLoop
Local lPressao := .F.
Local lRelogio := .F.
Local lSoma		:= .F.
Local lFez		:= .F.
Local lCompl	:= .F.
Local lCalibC	:= .F.
Local lCalib	:= .F. 
Local lMaior	:= .F.
Local lSimples	:= .F.
Local nLin_aMed
Local oDlgPad
Local nOpca		:= 0
Local nPsRow	:= aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:nRowPos 
Local nx		:= 1

SetKey(VK_F5,{|| Nil })
SetKey(VK_F6,{|| Nil })
SetKey(VK_F8,{|| Nil })

nLin_aMed := Ascan(aMedicoes, { |x| Alltrim(x[1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt]) .and. Alltrim(x[2]) == Alltrim(oCbxPad:aItems[oCbxPad:nAt])})													

nDesPadP		:= aMedicoes[nLin_aMed,nPosGer,1,9]
nInsTotP		:= aMedicoes[nLin_aMed,nPosGer,1,10]
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se e Tipo de Calibracao Pressao ou Relogio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aMedicoes[nLin_aMed,nPosGer,1,2] == "3"   // Tipo de Calibracao Pressao
	lPressao := .T.
ElseIf aMedicoes[nLin_aMed,nPosGer,1,2] == "9"   // Tipo de Calibracao Relogio
	lRelogio := .T.
ElseIf aMedicoes[nLin_aMed,nPosGer,1,2] == "5"   // Tipo de Calibracao Soma
	lSoma		:= .T.
ElseIf aMedicoes[nLin_aMed,nPosGer,1,2] == "2"   // Tipo Calibracao Completa
	lCompl	:= .T.
ElseIf aMedicoes[nLin_aMed,nPosGer,1,2] == "8"   // Tipo Calibracao Calib. Completa
	lCalibC	:= .T.
ElseIf aMedicoes[nLin_aMed,nPosGer,1,2] == "4"   // Tipo Calibracao Calibrador
	lCalib	:= .T. 
ElseIf aMedicoes[nLin_aMed,nPosGer,1,2] == "1"   // Tipo Calibracao Simples
	lSimples	:= .T.	
EndIf		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se e possivel mostrar o resultado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aMedicoes[nLin_aMed,nPosMed])	
	nTipoMed 	:= Len(aMedicoes[nLin_aMed,nPosMed,1,1])
Else
	lNoColMed	:= .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Medicao e externa sem lancamento de medicoes para dar ³
//³ Get na incerteza e no desvio padrao . 										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aMedicoes[nLin_aMed,nPosGer,1,4] == "E" .And.;	
	aMedicoes[nLin_aMed,nPosGer,1,1] == 0					
	lNoColMed	:= .T.
	lMaior		:= .T.
Endif

lAtributo := Upper(Alltrim(aMedicoes[nPosAmed,nPosGer,1,3])) == "A"

If aMedicoes[nLin_aMed,nPosGer,1,3] <> "A"
	If !lAtributo
		lRetUnid := a140TamDec(@nTam,@cNomin,@cUniMed,@nCoef,nPosAmed)
	Endif	
Else
	lRetUnid := .T.
Endif

If lRetUnid
	CursorWait()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama rotina de calculo que retorna array com todos os resultados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aResult := A140Calc(nLin_aMed)
	For nLoop := (Len(aResult)+1) TO 4
		Aadd(aResult,{ 0,0,0,0,0,0, .F., .F., .F., "" } )
	Next nLoop
	
	CursorArrow()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Medicao e externa sem lancamento de medicoes para dar               ³
	//³ Get na incerteza e no desvio padrao . 								³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DEFINE MSDIALOG oDlgPad TITLE cCadastro+OemToAnsi(STR0134) FROM 20,190  TO 280,675 OF GetWndDefault() PIXEL // " - Resultados"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cabe‡alho fixo na tela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aoBjetos[OBJ_PONTO] == NIL	
		If !lNoColMed
			If aMedicoes[nLin_aMed,nPosGer,1,3] <> "A"
				lFez := .T.
				@ .6,60 GROUP oGrp1 TO 94,130 LABEL OemToAnsi(STR0135) OF oDlgPad PIXEL //"Nao Corrigido(s)"
				@ 5,03 SAY oSay1  PROMPT STR0017 SIZE 50,7.5 OF oDlgPad PIXEL //'Média dos valores:'
				@ 14,3 SAY oSay2  PROMPT STR0018 SIZE 50,7.5 OF oDlgPad PIXEL //'Desvio Médio:'
				@ 23,3 SAY oSay3  PROMPT OemToAnsi(STR0136) SIZE 50,7.5 OF oDlgPad PIXEL // "Desvio Padrao Exp."
				@ 32,3 SAY oSay4  PROMPT STR0019 SIZE 50,7.5 OF oDlgPad PIXEL //'Incerteza:'
				@ 41,3 SAY oSay5  PROMPT STR0014 SIZE 50,7.5 OF oDlgPad PIXEL //"Incerteza Total:"
				@ 50,3 SAY oSay6  PROMPT STR0020 SIZE 50,7.5 OF oDlgPad PIXEL //'Erro Sistemático:'
				If aMedicoes[nLin_aMed,nPosGer,1,6] = "1"
					@ 59,3 SAY oSay7  PROMPT STR0021 SIZE 50,7.5 OF oDlgPad PIXEL //'Exatidão:'
					@ 68,3 SAY oSay8  PROMPT STR0022 SIZE 50,7.5 OF oDlgPad PIXEL //'Aceitabilidade:'
					@ 77,3 SAY oSay9  PROMPT STR0023 SIZE 50,7.5 OF oDlgPad PIXEL //'Adequação ao Uso:'
				Else
					@ 59,3 SAY oSay7  PROMPT STR0021 SIZE 50,7.5 OF oDlgPad PIXEL COLOR CLR_GRAY//'Exatidão:'
					@ 68,3 SAY oSay8  PROMPT STR0022 SIZE 50,7.5 OF oDlgPad PIXEL COLOR CLR_GRAY//'Aceitabilidade:'
					@ 77,3 SAY oSay9  PROMPT STR0023 SIZE 50,7.5 OF oDlgPad PIXEL COLOR CLR_GRAY//'Adequação ao Uso:'
				Endif
			
				@ 84.8,3 SAY oSay10 PROMPT STR0024 SIZE 50,7.5 OF oDlgPad PIXEL COLOR CLR_HRED //'Status:'
				@ 05,75 SAY oSay11  PROMPT aResult[1,1] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,StrTran(/* Str */CVALTOCHAR(aResult[1][1]*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",","),.T.) // 'M‚dia dos valores'
				@ 14,75 SAY oSay12  PROMPT aResult[1,2] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,StrTran(/* STr */CVALTOCHAR(aResult[1][2]*nCoef/* ,Len(aMedicoes[nLin_aMed,nPosEsp]),nTam */),".",","),.T.) // 'Desvio M‚dio'
				@ 23,75 SAY oSay13  PROMPT aResult[1,3] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,StrTran(/* STr */CVALTOCHAR(aResult[1][3]*nCoef/* ,Len(aMedicoes[nLin_aMed,nPosEsp]),nTam */),".",","),.T.) // 'Desvio PadrÆo'
				@ 32,75 SAY oSay14  PROMPT aResult[1,4] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,StrTran(/* STr */CVALTOCHAR(aResult[1][4]*nCoef/* ,Len(aMedicoes[nLin_aMed,nPosEsp]),nTam */),".",","),.T.) // 'Incerteza'
				@ 41,75 SAY oSay15  PROMPT aResult[1,5] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,StrTran(/* STr */CVALTOCHAR(aResult[1][5]*nCoef/* ,Len(aMedicoes[nLin_aMed,nPosEsp]),nTam */),".",","),.T.) // 'Incerteza Total'
				@ 50,75 SAY oSay16  PROMPT aResult[1,6] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,StrTran(/* STr */CVALTOCHAR(aResult[1][6]*nCoef/* ,Len(aMedicoes[nLin_aMed,nPosEsp]),nTam */),".",","),.T.) // 'Incerteza Total'
				AAdd(aObj,oSay11) //1
				AAdd(aObj,oSay12) //2
				AAdd(aObj,oSay13) //3
				AAdd(aObj,oSay14) //4
				AAdd(aObj,oSay15) //5
				AAdd(aObj,oSay16)	 //6		
				If aMedicoes[nLin_aMed,nPosGer,1,6] == "1"
					@ 59,75 SAY oSay17  PROMPT Iif(aResult[1,7],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[1,7],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
					@ 68,75 SAY oSay18  PROMPT Iif(aResult[1,8],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[1,8],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
					@ 77,75 SAY oSay19  PROMPT Iif(aResult[1,9],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[1,9],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
				Else
					@ 59,75 SAY oSay17  PROMPT Space(15) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL
					@ 68,75 SAY oSay18  PROMPT Space(15) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL
					@ 77,75 SAY oSay19  PROMPT Space(15) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL
				Endif
				@ 84.9,75 SAY oSay20  PROMPT Iif(aResult[1,10] == "A",STR0028,STR0029) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[1,10] == "A",CLR_BLUE,CLR_HRED) //"Aprovado" ### "Reprovado"
				AAdd(aObj,oSay17) //7
				AAdd(aObj,oSay18) //8
				AAdd(aObj,oSay19)	 //9		
				AAdd(aObj,oSay20)	 //10					
			Endif
			// Se for Tipo de Calibracao PRESSAO / RELOGIO / SOMA	/ COMPLETA
			If lPressao .or. lRelogio .or. lSoma .or. lCompl .or. lCalibC .and. aMedicoes[nLin_aMed,nPosGer,1,3] <> "A"
				If aMedicoes[nLin_aMed,nPosGer,1,3] <> "A"
					@ .6,129 GROUP oGrp2 TO 94,215 LABEL OemToAnsi(STR0137) OF oDlgPad PIXEL //"Corrigido(s)"
					@ 05,160 SAY oSay21  PROMPT aResult[2,1] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,StrTran(/* Str */CVALTOCHAR(aResult[2][1]*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",","),.T.) // 'M‚dia dos valores'
					@ 14,160 SAY oSay22  PROMPT aResult[2,2] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,StrTran(/* Str */CVALTOCHAR(aResult[2][2]*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",","),.T.) // 'Desvio M‚dio'
					@ 23,160 SAY oSay23  PROMPT aResult[2,3] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,StrTran(/* Str */CVALTOCHAR(aResult[2][3]*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",","),.T.) // 'Desvio PadrÆo'
					@ 32,160 SAY oSay24  PROMPT aResult[2,4] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,StrTran(/* Str */CVALTOCHAR(aResult[2][4]*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",","),.T.) // 'Incerteza'
					@ 41,160 SAY oSay25  PROMPT aResult[2,5] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,StrTran(/* Str */CVALTOCHAR(aResult[2][5]*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",","),.T.) // 'Incerteza Total'
					@ 50,160 SAY oSay26  PROMPT aResult[2,6] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,StrTran(/* Str */CVALTOCHAR(aResult[2][6]*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",","),.T.) // 'Incerteza Total'
					If aMedicoes[nLin_aMed,nPosGer,1,6] == "1" .and. (lPressao .or. lCompl .or. lSoma .or. lRelogio .or. lCalibC)
						@ 59,160 SAY oSay27  PROMPT Iif(aResult[2,7],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[2,7],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
						@ 68,160 SAY oSay28  PROMPT Iif(aResult[2,8],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[2,8],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
						@ 77,160 SAY oSay29  PROMPT Iif(aResult[2,9],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[2,9],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
					Else
						@ 59,160 SAY oSay27  PROMPT Space(15) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL
						@ 68,160 SAY oSay28  PROMPT Space(15) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL
						@ 77,160 SAY oSay29  PROMPT Space(15) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL
					Endif
			
					@ 84.9,160 SAY oSay30 PROMPT Iif(aResult[2,10] == "A",STR0028,STR0029) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[2,10] == "A",CLR_BLUE,CLR_HRED) //"Aprovado" ### "Reprovado"

					AAdd(aObj,oSay21) //11
					AAdd(aObj,oSay22) //12
					AAdd(aObj,oSay23)	 //13		
					AAdd(aObj,oSay24)	 //14					
					AAdd(aObj,oSay25) //15
					AAdd(aObj,oSay26) //16
					AAdd(aObj,oSay27)	 //17		
					AAdd(aObj,oSay28)	 //18					
					AAdd(aObj,oSay29) //19
					AAdd(aObj,oSay30) //20
			
					If !lFez //Ja montou 1 vez
						@ 05,75 SAY oSay11  PROMPT aResult[1,1] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,StrTran(/* Str */CVALTOCHAR(aResult[1][1]*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",","),.T.) // 'M‚dia dos valores'
						@ 14,75 SAY oSay12  PROMPT aResult[1,2] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,StrTran(/* Str */CVALTOCHAR(aResult[1][1]*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",","),.T.) // 'Desvio M‚dio'
						@ 23,75 SAY oSay13  PROMPT aResult[1,3] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,StrTran(/* Str */CVALTOCHAR(aResult[1][1]*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",","),.T.) // 'Desvio PadrÆo'
						@ 32,75 SAY oSay14  PROMPT aResult[1,4] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,StrTran(/* Str */CVALTOCHAR(aResult[1][1]*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",","),.T.) // 'Incerteza'
						@ 41,75 SAY oSay15  PROMPT aResult[1,5] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,StrTran(/* Str */CVALTOCHAR(aResult[1][1]*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",","),.T.) // 'Incerteza Total'
						@ 50,75 SAY oSay16  PROMPT aResult[1,6] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,StrTran(/* Str */CVALTOCHAR(aResult[1][1]*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",","),.T.) // 'Incerteza Total'3
						If lVisual .or. aMedicoes[nLin_aMed,nPosGer,1,6] == "1"
							@ 59,75 SAY oSay17  PROMPT Iif(aResult[1,7],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[1,7],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
							@ 68,75 SAY oSay18  PROMPT Iif(aResult[1,8],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[1,8],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
							@ 77,75 SAY oSay19  PROMPT Iif(aResult[1,9],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[1,9],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
						Endif
						@ 84.9,75 SAY oSay20  PROMPT Iif(aResult[1,10] == "A",STR0028,STR0029) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[1,10] == "A",CLR_BLUE,CLR_HRED) //"Aprovado" ### "Reprovado"
					Endif
			
					If !lSoma .and. !lCompl .and. !lCalibC
						@ 94,160 BUTTON oBtn PROMPT Iif(lPressao,STR0025,Iif(lRelogio,STR0098,""));  //"&Descida >>" //"&Decrescente >>"
						ACTION A140ChgBut(oBtn,oDlgPad,aObjetos);
						OF oDlgPad PIXEL SIZE 45,10
						Aadd(aObj,oBtn)
					Endif
				Endif
			Endif
		Endif
	
		lAtrib_Ok := aMedicoes[nLin_aMed,nPosMed,1,1] == "A"

		If lSimples .or. lCalib
			If aMedicoes[nLin_aMed,nPosGer,1,3] <> "A"
				oGrp1:SetText(STR0137)
				oGrp1:Refresh()
			Endif				
		Endif


		// Se for tipo de calibracao ATRIBUTO
		If aMedicoes[nLin_aMed,nPosGer,1,3] == "A" //.and. !lNoColMed .and. !lMaior
                     
			@ 59,78 GROUP oGrp4 TO 81,164 OF oDlgPad PIXEL
			@ 67.2,99 SAY oSay34  PROMPT STR0024 SIZE 50,7.5 OF oDlgPad PIXEL //'Status:'
			If !Empty(aMedicoes[nLin_aMed,nPosMed,1,1]) .And. (lCalibC .or. lCalib .or. lSimples .or. lCompl .or. lPressao .or. lRelogio .or. lSoma)
				@ 84.9,7 SAY Space(20) SIZE 50,7.5 OF oDlgPad
				@ 67.2,116 SAY oSay32  PROMPT Iif(lAtrib_Ok,STR0028,STR0029) SIZE 27.5,7.5 OF oDlgPad PIXEL COLOR Iif(lAtrib_Ok,CLR_BLUE,CLR_HRED)//"Aprovado" ### "Reprovado"
				AAdd(aObj,oSay32)
			ElseIf lCalibC .or. lCalib	.or. lSimples .or. lCompl .or. lPressao .or. lRelogio .or. lSoma
				@ 67.2,16 ICON oIcon2 RESOURCE "NOMEDICAO" OF oDlgPad NOBORDER
				@ 67.2,116 SAY oSay33  PROMPT STR0030 SIZE 35,7.5 OF oDlgPad PIXEL //"Sem Medição"
				AAdd(aObj,oSay33)
			Elseif !lCalibC .or. !lCalib	.or. !lSimples .or. !lCompl .or. !lPressao .or. !lRelogio .or. !lSoma
				@ 84.9,7 SAY Space(20) SIZE 50,7.5 OF oDlgPad
				@ 67.2,116 SAY oSay32  PROMPT Iif(aMedicoes[nLin_aMed,nPosMed,1,1]=="A",STR0028,Iif(aMedicoes[nLin_aMed,nPosMed,1,1]=="R",STR0029,STR0139)) SIZE 37.5,7.5 OF oDlgPad PIXEL COLOR Iif(aMedicoes[nLin_aMed,nPosMed,1,1]=="A",CLR_BLUE,CLR_HRED)//"Aprovado" ### "Reprovado" ###"Não Informado"
				AAdd(aObj,oSay32)			
			Endif
			AAdd(aObj,oSay34)			
		Endif
		aObjetos[OBJ_PONTO] := aObj
	Else
		If !lNoColMed
			If aMedicoes[nLin_aMed,nPosGer,1,3] <> "A"
   			For nx := 1 to 6
					aObjetos[OBJ_PONTO][nx]:SetText(aResult[1,nx]) 
					aObjetos[OBJ_PONTO][nx]:Show()
					aObjetos[OBJ_PONTO][nx]:Refresh()	
				Next 
				If aMedicoes[nLin_aMed,nPosGer,1,6] == "1"
					aObjetos[OBJ_PONTO][7]:SetText(Iif(aResult[1,7],STR0026,STR0027))			 
					aObjetos[OBJ_PONTO][8]:SetText(Iif(aResult[1,8],STR0026,STR0027))			
					aObjetos[OBJ_PONTO][9]:SetText(Iif(aResult[1,9],STR0026,STR0027))			
				Else
					aObjetos[OBJ_PONTO][7]:SetText("")			 
					aObjetos[OBJ_PONTO][8]:SetText("")			
					aObjetos[OBJ_PONTO][9]:SetText("")			
				Endif
				aObjetos[OBJ_PONTO][10]:SetText(Iif(aResult[1,10] == "A",STR0028,STR0029))			
			Endif

			If lPressao .or. lRelogio .or. lSoma .or. lCompl .or. lCalibC
		   	nTot := 0
				For nx := 11 to 16
					nTot++
					aObjetos[OBJ_PONTO][nx]:SetText(aResult[2,nTot])			
					aObjetos[OBJ_PONTO][nx]:Show()
					aObjetos[OBJ_PONTO][nx]:Refresh()
				Next nx
				If aMedicoes[nLin_aMed,nPosGer,1,6] == "1" .and. (lPressao .or. lCompl .or. lSoma .or. lRelogio .or. lCalibC)
					aObjetos[OBJ_PONTO][17]:SetText(Iif(aResult[2,7],STR0026,STR0027))			 
					aObjetos[OBJ_PONTO][18]:SetText(Iif(aResult[2,8],STR0026,STR0027))			
					aObjetos[OBJ_PONTO][19]:SetText(Iif(aResult[2,9],STR0026,STR0027))			
				Else
					aObjetos[OBJ_PONTO][17]:SetText("")
					aObjetos[OBJ_PONTO][18]:SetText("")
					aObjetos[OBJ_PONTO][19]:SetText("")
				Endif
				aObjetos[OBJ_PONTO][20]:SetText(aResult[2,10] == "A",STR0028,STR0029)			
			Endif	
		Endif	
	Endif                      
	
	If ExistBlock("QMT141TVA")	
		ExecBlock("QMT141TVA",.F.,.F.,{oDlgPad,aMedicoes[nLin_aMed,nPosGer,1,2],aMedicoes[nLin_aMed,nPosGer,1,3],aMedicoes[nLin_aMed,nPosGer,1,4],aResult})	
	Endif	
	
	DEFINE SBUTTON FROM 115,211 TYPE 2 ENABLE OF oDlgPad ACTION ( nOpcA := 2,oDlgPad:End() )
	ACTIVATE MSDIALOG oDlgPad Centered
Else
	oFolderFix:lReadOnly := .T.
	oCbxEsc:lReadOnly	:= .T.
	oCbxPad:lReadOnly	:= .T.
Endif
//Controle para Refresh da GetDados Medicoes
If oFolderFix:nOption == 1
	If aMedicoes[nLin_aMed,nPosGer,1,1] <> 0 //.and. aMedicoes[nLin_aMed,nPosGer,1,4] <> "E"
		If aMedicoes[nLin_aMed,nPosGer,1,1] > 1
			If lPressao .or. lRelogio .or. lSoma .or. lCompl
				aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:SetFocus()
				aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:nRowPos := nPsRow
			ElseIf lCalibC .or. lCalib .or.	lSimples	
				aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:SetFocus()
				aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:nRowPos := nPsRow
//				aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:Refresh()				
//				aObjetos[ OBJ_MEDICAO_1 ][6]:ForceRefresh()	
			Endif 
		Endif	
	Endif
Endif

//Integridade - Permitir incluir/alterar as getdados
If Inclui .or. Altera
	aObjetos[OBJ_PADSEC][2]:oBrowse:nOpc := 3
	aObjetos[OBJ_INSTUTIL][4]:oBrowse:nOpc := 3
	aObjetos[OBJ_NAOCONFOR][2]:oBrowse:nOpc := 3
	aObjetos[OBJ_INCERT_B][3]:oBrowse:nOpc := 3 
Else	
	aObjetos[OBJ_PADSEC][2]:oBrowse:nOpc := 2
	aObjetos[OBJ_INSTUTIL][4]:oBrowse:nOpc := 2
	aObjetos[OBJ_NAOCONFOR][2]:oBrowse:nOpc := 2
	aObjetos[OBJ_INCERT_B][3]:oBrowse:nOpc := 2 
Endif

SetKey(VK_F8,{|| a140MudPad()}) 	
SetKey(VK_F5,{|| If(Len(aMedicoes) > 0,(nPosAnt := nPosAmed,a141ContrFld(nGot:=oFolderFix:nOption,oFolderFix:nOption,.F.),A140ShwEsc(oDlgPri,oBmpEsc,oBmpPad,oFolderFix)),.F.)}) 	
SetKey(VK_F6,{|| If(Len(aMedicoes) > 0,(nPosAnt := nPosAmed,a141ContrFld(nGot:=oFolderFix:nOption,oFolderFix:nOption,.F.),A140ShwPad(oCbxEsc,oCbxPad,oFolderFix,oDlgPri),A141AprPad(oDlgPri,oBmpPad,oBmpEsc)),.F.)}) 	

aObjetos[OBJ_PONTO] := NIL

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140ShwMed³ Autor ³ Fernando Godoy	    ³ Data ³ 8/31/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra a getdados de medicoes						  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Linha atual no Array aMedicoes					  ³±±
±±³			 ³ExpO1 - Handle da Dialog Ativa							  ³±±
±±³			 ³ExpO2 - Handle do Objeto Getdados							  ³±±
±±³			 ³ExpO3 - Handle do Objeto Say						  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140ChgTree()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto ³ 15/06/00 ³ Alteracoes para calibrar Tipo de Calibracao Re- ³±±
±±³          ³          ³ logio.                        		 		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140ShwMed(oFldFix)

Local oSayLIE
Local oSayLIE1
Local oSayLSE
Local oSayLSE1
Local oSayMin
Local oSayMax
Local lPressao := .F.
Local cString	:= "QM8_VLRINI|QM8_VLRFIM"
Local oGetEsp
Local oSayEsp
Local oSayEsp1
Local lRelogio := .F.
Local lRet		:= .T.
Local cUniMed
Local aObjs		:= {}
Local nLin_aMed 
Local oSay1
Local oSay2
Local oGet1
Local oGet2
Local lVisual := IIF(Inclui .or. Altera,.F.,.T.)
Local nLIE	:= 0
Local nLSE	:= 0
Local oTmr
Local nTamo := 0
Local cUtlCpo	:= ""
Local oGet3
Local nDesPd	:= 0
Local aAret  := {}
Local aGetA9 := {}
Local aSize  := FWGetDialogSize(oMainWnd)

lUniGual := .F.

nLin_aMed := Ascan(aMedicoes, { |x| Alltrim(x[1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt]) .and. Alltrim(x[2]) == Alltrim(oCbxPad:aItems[oCbxPad:nAt])})													

nGetEsp	:= SuperVal(aMedicoes[nPosAmed,nPosEsp])
If Len((aMedicoes[nPosAMed,nPosMed,1])) > 3
	If aMedicoes[nPosAMed,nPosGer,1,2] == "3"   // Tipo de Calibracao Pressao
		lPressao := .T.
	ElseIf aMedicoes[nPosAMed,nPosGer,1,2] == "9"   // Tipo de Calibracao Relogio
		lRelogio := .T.
	EndIf		
Elseif Len((aMedicoes[nPosAMed,nPosMed,1])) == 2
	cString	:= "QM8_VLRFIM"
EndIf

If !lAtributo
	If !lPressao .and. !lRelogio
		If aMedicoes[nPosAMed,nPosGer,1,2] $ "1|4"   // Tipo Calibracao Simples
			aHeader := aClone(aHeadSim)
		Else	
			aHeader := aClone(aHeadTot)
		Endif	
	Else
		If lPressao
			aHeader := aClone(aHeadPre)
		ElseIf lRelogio
			aHeader := aClone(aHeadRel)
		Endif
	Endif
Else
	aHeader := aClone(aHeadAtr)
EndIf    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega o Array aCols a partir do Array aMedicoes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !latributo
	aCols 	:= aClone(aMedicoes[nPosAmed,nPosMed])
	nUsado	:= Len(aCols[1])		
	If !aMedicoes[nPosAmed,nPosGer,1,2] $ "4|8"
		lRetUnid := a140TamDec(@nTam,@cNomin,@cUniMed,@nCoef,nPosAmed)
	Else 
		lRetUnid := .T.
		nTam	:= QA_NUMDEC(aMedicoes[nPosAmed,nPosEsp])
		nCoef	:= 1
	Endif	

	If nCoef == 1
		lUniGual := .T.
	Endif	                          
Else
	aCols := {{"",.F.}}                                            
	aCols[1][1] 	:= aMedicoes[nPosAmed,nPosMed,1,1]
	aCols[1][2]		:= aMedicoes[nPosAmed,nPosMed,1,2]
	lRetUnid 		:= .T. // Quando for atributo, aceitar qq unidade de medida.
Endif	

nDesPad		:= aMedicoes[nPosAmed,nPosGer,1,9] //nLin_aMed
nInsTot		:= aMedicoes[nPosAmed,nPosGer,1,10] //nLin_aMed

DEFINE TIMER oTmr INTERVAL 1 ACTION oGetMed1:ForceRefresh()
oTmr:DeActivate()

If lRet
	If lRetUnid
		aRotina[3,4] := 6 // Nao pode incluir linhas na Getdados
//		oBtnPad:Disable()
//		oBtnPad:Refresh()  
		@  1,4	SAY oSay1  PROMPT STR0088	OF oFolderFix:aDialogs[1]	PIXEL SIZE 40,7.5 FONT oArialBo COLOR CLR_BLUE//"Maior Desvio:" //29,6
		@  1,100 SAY oSay2  PROMPT STR0014	OF oFolderFix:aDialogs[1]	PIXEL SIZE 55,7.5 FONT oArialBo COLOR CLR_BLUE//"Incerteza Total:" //41,6
		
        oSay1:lTransparent := .F.
		oSay2:lTransparent := .F.
        oSay1:Hide()
        oSay2:Hide()
		Aadd(aObjs,oSay1)	//1	   
		Aadd(aObjs,oSay2)	//2	   		
		
		@  1,42	MSGET  oGet1 VAR nDesPad	OF oFolderFix:aDialogs[1]	PIXEL SIZE 35,7.5 VALID Eval( { || RetDesPa(@oGet1,nPosAmed,,@nDesPad),.t. } ) //29
		@  1,143 MSGET oGet2 VAR nInsTot	OF oFolderFix:aDialogs[1]	PIXEL SIZE 35,7.5 VALID Eval( { || RetDesIn(@oGet2,nPosAmed,,@nInsTot),.t. } ) //41		
		@  5000,5000 MSGET oGet3 VAR nDesPd OF oFolderFix:aDialogs[1]	PIXEL SIZE 35,7.5

		oGet1:bLostFocus := {||oGet3:SetFocus()}

//		oGet1:bChange := {||oGet3:SetFocus()}
//		oGet2:bLostFocus := {||oGet1:SetFocus()}
		oGet1:Hide()
		oGet2:Hide()		
		Aadd(aObjs,oGet1)		//3
		Aadd(aObjs,oGet2)		//4		

		//oGetMed1 := MsNewGetDados():New(12,2,(aSize[3] / 2) - 170, (aSize[4] / 2) - 8,nTipoMd,{||AllwaysTrue()},,,,,,,,{||.F.},oFolderFix:aDialogs[1],aHeader,aCols)
		oGetMed1 := MsNewGetDados():New(12,2,(aSize[3] / 2) - 170, (aSize[4] / 2) - 8,nTipoMd,{||AllwaysTrue()},,,,,,,,{||.F.},oFolderFix:aDialogs[1],aHeader,aCols)
		oGetMed1:ForceRefresh()            

//		oGetMed1:oBrowse:bLostFocus := {||If(oFolderFix:nOption == 1,aMedicoes[nPosAmed,nPosMed] := oGetMed1:aCols,.T.)}
		If lVisual
			oGet1:Disable()     
			oGet2:Disable()     
		Endif
//		oBtnPad:Enable()
//		oBtnPad:Refresh()
		oGetMed2 := oGetMed1
//		oGetMed2 := MsNewGetDados():New(12,2,88,300,nTipo,{||AllwaysTrue()},,,,,,,,{||.F.},oFolderFix:aDialogs[1],aHeader,aCols)
//		oGetMed2:ForceRefresh()
        
		If aMedicoes[nPosAmed,nPosGer,1,1] <> 0 .and. aMedicoes[nLin_aMed,nPosGer,1,4] <> "E"	
			oGetMed1:oBrowse:lDisablePaint := .F.      
			oGetMed2 := oGetMed1
			oGetMed2:oBrowse:lDisablePaint := .T.		
		Else
			oGetMed1:oBrowse:lDisablePaint := .T.		
			oGetMed1 := oGetMed2
			oGetMed2:oBrowse:lDisablePaint := .F.		
		Endif	
		Aadd(aObjs,oGetMed1) //5	
		Aadd(aObjs,oGetMed2)	//6
		//Caso seja tipo soma e utilize parametro para considerar casas decimais da escala
		nTamSo := nTam
		If lTamSom
			If aMedicoes[nPosAMed,nPosGer,1,2] = '5'	
				If !Empty(QM9->QM9_ESCALI)
			   		nTam := QA_NUMDEC(QM9->QM9_ESCALI) 
				Else
					nTam := QA_NUMDEC(aMedicoes[nPosAMed,nPosEsp])
				Endif
			Endif
		Endif
		
		@ 1,99 SAY oSayEsp PROMPT STR0033 +;
			IIf(!lAtributo,IIf(lUniGual,Alltrim(StrTran(Str(SuperVal(aMedicoes[nPosAmed,nPosEsp])*nCoef,Len(aMedicoes[nPosAmed,nPosEsp]),nTam),".",",")),;
			Alltrim(StrTran(Str(SuperVal(aMedicoes[nPosAmed,nPosEsp])*nCoef,;
			Len(aMedicoes[nPosAmed,nPosEsp]),nTam),".",","))),"");
			PIXEL SIZE 200,7 OF oFolderFix:aDialogs[1] COLOR CLR_BLUE	//"Especificado: "
			AADD(aObjs,oSayEsp) //7
//			oSayEsp:lTransparent := .F.			
			oSayEsp:Hide()            
			
		@ 1,4 SAY oSayEsp PROMPT STR0033 +;
			IIf(!lAtributo,IIf(lUniGual,Alltrim(StrTran(Str(SuperVal(aMedicoes[nPosAmed,nPosEsp])*nCoef,Len(aMedicoes[nPosAmed,nPosEsp]),nTam),".",",")),;
			Alltrim(StrTran(Str(SuperVal(aMedicoes[nPosAmed,nPosEsp])*nCoef,;
			Len(aMedicoes[nPosAmed,nPosEsp]),nTam),".",","))),"");
			PIXEL SIZE 200,7 OF oFolderFix:aDialogs[1] COLOR CLR_BLUE	//"Especificado: "
			AADD(aObjs,oSayEsp) //8
//			oSayEsp:lTransparent := .F.
			oSayEsp:Hide() 

		@ 1,99 SAY oSayEsp1 PROMPT STR0033 PIXEL SIZE 200,7 OF oFolderFix:aDialogs[1] COLOR CLR_BLUE //"Especificado: "
		Aadd(aObjs,oSayEsp1) //9
//		oSayEsp1:lTransparent := .F.
		oSayEsp1:Hide()  

		If !lUniGual
			cVarial := StrTran(Str(nGetEsp*nCoef,Len(aMedicoes[nPosAMed,nPosEsp]),QA_NumDec(aMedicoes[nPosAMed,nPosEsp])),".",",")
		Else
			cVarial := StrTran(Str(nGetEsp,Len(aMedicoes[nPosAMed,nPosEsp]),QA_NumDec(aMedicoes[nPosAMed,nPosEsp])),".",",")
		Endif
		@ 1,138 MSGET oGetEsp VAR nGetEsp PIXEL SIZE 50,2 OF oFolderFix:aDialogs[1];
			COLOR CLR_BLUE PICTURE /* "@E 99999.9999" */qmt140Pict();
			VALID Eval( { || aMedicoes[nPosAMed,nPosEsp] := cVarial } )
			Aadd(aObjs,oGetEsp) //10
			oGetEsp:Hide()	
			//oGetEsp:Disable()				

			@  5000,5000	MSGET  oGet3 VAR nDesPd	OF oFolderFix:aDialogs[1]	PIXEL SIZE 35,7.5 

			oGetEsp:bLostFocus := {||aMedicoes[nPosAMed,nPosEsp] := cVarial,oGet3:SetFocus()}            

		If lTamSom
			If aMedicoes[nPosAMed,nPosGer,1,2] = '5'	
				If !Empty(QM9->QM9_ESCALI)
			   		nTam := QA_NUMDEC(QM9->QM9_ESCALI) 
				Else
					nTam := QA_NUMDEC(aMedicoes[nPosAMed,nPosEsp])
				Endif
			Endif
		Endif 
		@ 1,4 SAY oSayEsp1 PROMPT STR0033 PIXEL SIZE 200,7 OF oFolderFix:aDialogs[1] COLOR CLR_BLUE //"Especificado: "
		oSayEsp1:lTransparent := .F.
		Aadd(aObjs,oSayEsp1) //11
		oSayEsp1:Hide()
        aAret  := GetArea()
		aGetA9 := QM9->(GetArea())

		dbSelectArea("QM9")
		dbSetOrder(1)
		If dbSeek(xFilial("QM9")+aMedicoes[nPosAnt,nPosEsc])
			If !Empty(AllTrim(QM9->QM9_ESCALI))
				nTamo := QA_NumDec(QM9->QM9_ESCALI)
				cPicture := QMT140Pics(,QM9->QM9_ESCALI,.F.)
			Else
				nTamo := QA_NumDec(aMedicoes[nPosAMed,nPosEsp])
				cPicture := QMT140Pics(,aMedicoes[nPosAMed,nPosEsp],.F.)
			EndIf
		Endif
		RestArea(aGetA9)
        RestArea(aAret)		
		If !lUniGual
			cVarial := StrTran(Str(nGetEsp*nCoef,Len(aMedicoes[nPosAMed,nPosEsp]),If(QA_NumDec(aMedicoes[nPosAMed,nPosEsp]) == 0, nTamo, QA_NumDec(aMedicoes[nPosAMed,nPosEsp]))),".",",")
		Else
			cVarial := StrTran(Str(nGetEsp,Len(aMedicoes[nPosAMed,nPosEsp]),If(QA_NumDec(aMedicoes[nPosAMed,nPosEsp]) == 0, nTamo, QA_NumDec(aMedicoes[nPosAMed,nPosEsp]))),".",",")
		Endif

		@ 1,40 MSGET oGetEsp VAR nGetEsp PIXEL SIZE 35,2 OF oFolderFix:aDialogs[1];
			COLOR CLR_BLUE PICTURE /* "@E 99999.9999" */qmt140Pict();
			VALID Eval	( { || aMedicoes[nPosAMed,nPosEsp] := cVarial } )          

			@  5000,5000	MSGET  oGet3 VAR nDesPd	OF oFolderFix:aDialogs[1]	PIXEL SIZE 35,7.5 

			oGetEsp:bLostFocus := {||RetDesPa(oGetEsp,nPosAmed,oGetEsp:cText,@nDesPad),oGetEsp:Refresh(), Iif(Valtype(cVarial) <> "U",aMedicoes[nPosAMed,nPosEsp] := cVarial,),oGet3:SetFocus()}            

		If lTamSom
			If aMedicoes[nPosAMed,nPosGer,1,2] = '5'	
				If !Empty(QM9->QM9_ESCALI)
					nTamo := QA_NUMDEC(QM9->QM9_ESCALI)
				Else
					nTamo := QA_NUMDEC(aMedicoes[nPosAMed,nPosEsp])
				Endif
			Else
	   			nTamo := QA_NUMDEC(aMedicoes[nPosAmed,nPosEsp])
			Endif
    	Else
   			nTamo := QA_NUMDEC(aMedicoes[nPosAmed,nPosEsp])
		Endif 

		oGetEsp:bValid := {|| nTamo := QA_NUMDEC(aMedicoes[nPosAmed,nPosEsp]),;
							  If(Valtype(nGetEsp) == "C",nGetEsp := SuperVal(nGetEsp),),;							  
							  aMedicoes[nPosAMed,nPosEsp] := StrTran(Str(nGetEsp,Len(aMedicoes[nPosAmed,nPosEsp]),nTamo),".",","),;
							  cVarial := aMedicoes[nPosAMed,nPosEsp],;
							  nLIE := Qmt141VVar(nCoef,nLie,.T.,.T.),;
							  nLSE := Qmt141VVar(nCoef,nLse,.F.,.T.)}

		Aadd(aObjs,oGetEsp) //12
		//oGetEsp:Disable()
		oGetEsp:Hide()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao for atributo, exibe valor maximo e minimo    ³
		//³ Se for Calibrador mostra LIE / LSE                  ³
		//³ Senao mostra intervalo (especificado +- tolerancia  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ja e verifica o tipo de calculo da tolerancia (1-Numerico / 2-Percentual)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 1,90 SAY oSayLIE PROMPT STR0034+Alltrim(aMedicoes[nPosAMed,nPosGer,1,18]) PIXEL SIZE 100,7 OF oFolderFix:aDialogs[1] COLOR CLR_BLUE //"LIE: "
		@ 1,190 SAY oSayLSE PROMPT STR0035+	Alltrim(aMedicoes[nPosAMed,nPosGer,1,19]) PIXEL SIZE 100,7 OF oFolderFix:aDialogs[1] COLOR CLR_BLUE //"LSE: "
		oSayLIE:lTransparent := .F.		
		oSayLSE:lTransparent := .F.
		
		Aadd(aObjs,oSayLIE) //13
		Aadd(aObjs,oSayLSE) //14
		oSayLie:Hide()
		oSayLse:Hide()
 
		@ 1,90 SAY oSayLIE1 PROMPT STR0092 PIXEL SIZE 100,7 OF oFolderFix:aDialogs[1] COLOR CLR_BLUE// "Minimo: "
		@ 1,190 SAY oSayLSE1 PROMPT STR0093 PIXEL SIZE 100,7 OF oFolderFix:aDialogs[1] COLOR CLR_BLUE// "Maximo: "

		oSayLie1:lTransparent := .F. 
		oSayLse1:lTransparent := .F.
		
		Aadd(aObjs,oSayLIE1) //15
		Aadd(aObjs,oSayLSE1) //16
		oSayLie1:Hide()
		oSayLse1:Hide()		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o tipo de calculo da tolerancia (1-Numerico / 2-Percentual)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nEspec := SuperVal(aMedicoes[nPosAMed,nPosEsp])
		nMinim := SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])
		nMaxim := SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])
		If Alltrim(aMedicoes[nPosAMed,nPosGer,1,21]) <> "1" 
			If !lUniGual
				nLIE :=	nEspec - ((nMinim * nEspec ) / 100)//SuperVal(aMedicoes[nPosAMed,nPosEsp])*nCoef - ((SuperVal(aMedicoes[nPosAMed,nPosEsp])*nCoef) * SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])*nCoef)/100
				nLSE :=	nEspec + ((nMaxim * nEspec ) / 100)//SuperVal(aMedicoes[nPosAMed,nPosEsp])*nCoef + ((SuperVal(aMedicoes[nPosAMed,nPosEsp])*nCoef) * SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])*nCoef)/100
			Else
				nLIE :=	SuperVal(aMedicoes[nPosAMed,nPosEsp]) - (SuperVal(aMedicoes[nPosAMed,nPosEsp]) * SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2]))/100
				nLSE :=	SuperVal(aMedicoes[nPosAMed,nPosEsp]) + (SuperVal(aMedicoes[nPosAMed,nPosEsp]) * SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1]))/100
			Endif	
		Else
			If !lUniGual
				nLIE :=	nEspec - nMinim//SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */ - SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])*nCoef
				nLSE :=	nEspec + nMaxim//SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */ + SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])*nCoef		
			Else
				nLIE :=	SuperVal(aMedicoes[nPosAMed,nPosEsp]) - SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])
				nLSE :=	SuperVal(aMedicoes[nPosAMed,nPosEsp]) + SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])
			Endif
		Endif

		If aMedicoes[nPosAMed,nPosGer,1,2] = '5'
			If lTamSom
				If !Empty(QM9->QM9_ESCALI)
					nTamo := QA_NUMDEC(QM9->QM9_ESCALI)
				Else
					nTamo := QA_NUMDEC(aMedicoes[nPosAMed,nPosEsp])
				Endif
			Else
				nTamo := QA_NUMDEC(aMedicoes[nPosAMed,nPosEsp])
			Endif
		Endif 

		If Empty(cUtlCpo)		
			cUtlCpo := aMedicoes[nPosAMed,nPosEsp]
		Endif
		@ 1,110 SAY oSayMin PROMPT nLIE;
			PIXEL PICTURE QMT140Pics(,StrTran(Str(SuperVal(cUtlCpo)*nCoef,Len(aMedicoes[nPosAMed,nPosEsp]),nTam),".",","),.F.);
			SIZE 80,7 OF oFolderFix:aDialogs[1] COLOR CLR_BLUE
		oSayMin:lTransparent := .F.
		oSayMin:Hide()
		    	
		@ 1,210 SAY oSayMax PROMPT nLSE;
			PIXEL PICTURE QMT140Pics(,StrTran(Str(SuperVal(cUtlCpo)*nCoef,Len(aMedicoes[nPosAMed,nPosEsp]),nTam),".",","),.F.);
			SIZE 100,7 OF oFolderFix:aDialogs[1] COLOR CLR_BLUE 
		oSayMax:Hide()
		oSayMax:lTransparent := .F.
		AADD(aObjs,oSayMin) //17
		AADD(aObjs,oSayMax) //18

		@ 1,110 SAY oSayMin PROMPT nLIE;
			PIXEL PICTURE QMT140Pics(,StrTran(Str(SuperVal(cUtlCpo),Len(aMedicoes[nPosAMed,nPosEsp]),nTam),".",","),.F.);//QMT140Pics(,cUtlCpo,.F.);
			SIZE 80,7 OF oFolderFix:aDialogs[1] COLOR CLR_BLUE
				
		@ 1,210 SAY oSayMax PROMPT nLSE;
			PIXEL PICTURE QMT140Pics(,StrTran(Str(SuperVal(cUtlCpo),Len(aMedicoes[nPosAMed,nPosEsp]),nTam),".",","),.F.);
			SIZE 100,7 OF oFolderFix:aDialogs[1] COLOR CLR_BLUE
		
		oSayMin:Hide()
		oSayMax:Hide()
		oSayMin:lTransparent := .F.
		oSayMax:lTransparent := .F.

		AADD(aObjs,oSayMin) //19
		AADD(aObjs,oSayMax) //20

		aObjetos[ OBJ_MEDICAO_1 ] := aObjs 
    
		aRotina[3,4] := 6

		If aMedicoes[nPosAmed,nPosGer,1,1] == 0 .and. aMedicoes[nLin_aMed,nPosGer,1,4] == "E"	
			aObjetos[OBJ_MEDICAO_1][1]:Show()			
			aObjetos[OBJ_MEDICAO_1][2]:Show()			
			aObjetos[OBJ_MEDICAO_1][3]:Show()			
			aObjetos[OBJ_MEDICAO_1][4]:Show()			
			aObjetos[OBJ_MEDICAO_1][5]:oBrowse:lDisablePaint := .F.
			aObjetos[OBJ_MEDICAO_1][5]:Show()			
			aObjetos[OBJ_MEDICAO_1][5]:oBrowse:Refresh()
		Else 
			aObjetos[OBJ_MEDICAO_1][5]:oBrowse:lDisablePaint := .F. 
			If lOnline .and. aMedicoes[nPosAmed,nPosGer,1,3] <> "A"
				nTam := QA_NUMDEC(aMedicoes[nPosAmed][nPosEsp])
				aObjetos[OBJ_MEDICAO_1][5]:oBrowse:bLDBLClick := {|| aCols[aObjetos[ OBJ_MEDICAO_1 ][5]:nAt][aObjetos[OBJ_MEDICAO_1][5]:oBrowse:nColPos]:=MSRPortQM2(oTmr , cPorta , cBaudRate, nTeste, cData, nStop,cTimeout,nTam ),qmt140VCpos(aObjetos[OBJ_MEDICAO_1][5])}				
			Endif	
			aObjetos[OBJ_MEDICAO_1][5]:Show()			
			aObjetos[OBJ_MEDICAO_1][5]:ForceRefresh()  
		Endif        

		If aMedicoes[nPosAMed,nPosGer,1,15] == "1" //.Or. nTipo <> 3 //Especificado Fixo
			If aMedicoes[nPosAmed,nPosGer,1,1] == 0 .and. aMedicoes[nLin_aMed,nPosGer,1,4] == "E"	
				If Alltrim(aMedicoes[nPosAmed,nPosPad]) <> "PADRAOEXT"
					aObjetos[OBJ_MEDICAO_1][7]:Show()
				Endif	
			Else
				If Alltrim(aMedicoes[nPosAmed,nPosGer,1,1]) <> "0" /*aMedicoes[nLin_aMed,nPosGer,1,4] <> "E"*/	
					If Alltrim(aMedicoes[nPosAmed,nPosGer,1,3]) <> "A"
						aObjetos[OBJ_MEDICAO_1][8]:Show()
					Endif	
				Endif	
			Endif	
		Else	// Especificado Variavel
			If aMedicoes[nPosAmed,nPosGer,1,1] == 0 .and. aMedicoes[nLin_aMed,nPosGer,1,4] == "E"	
				aObjetos[OBJ_MEDICAO_1][9]:Show() 
				If !lAtributo
					If !lUniGual
						cVarial := StrTran(Str(nGetEsp*nCoef,Len(aMedicoes[nPosAMed,nPosEsp]),QA_NumDec(aMedicoes[nPosAMed,nPosEsp])),".",",")
					Else
						cVarial := StrTran(Str(nGetEsp,Len(aMedicoes[nPosAMed,nPosEsp]),QA_NumDec(aMedicoes[nPosAMed,nPosEsp])),".",",")
					Endif
					aObjetos[OBJ_MEDICAO_1][10]:Show()
				EndIf
			Else
				If !lAtributo
					aObjetos[OBJ_MEDICAO_1][11]:Show()
					If !lUniGual
						cVarial := StrTran(Str(nGetEsp*nCoef,Len(aMedicoes[nPosAMed,nPosEsp]),QA_NumDec(aMedicoes[nPosAMed,nPosEsp])),".",",")
					Else
						cVarial := StrTran(Str(nGetEsp,Len(aMedicoes[nPosAMed,nPosEsp]),QA_NumDec(aMedicoes[nPosAMed,nPosEsp])),".",",")
					Endif
					
					cPicture := QMT140Pics(,aMedicoes[nPosAMed,nPosEsp],.F.)
					aObjetos[OBJ_MEDICAO_1][12]:Picture := cPicture
					aObjetos[OBJ_MEDICAO_1][12]:SetText(cVarial)      
					aObjetos[OBJ_MEDICAO_1][12]:Show()
					aObjetos[OBJ_MEDICAO_1][12]:Refresh()
					oGetEsp:Refresh()
				EndIf
			Endif
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao for atributo, exibe valor maximo e minimo    ³
		//³ Se for Calibrador mostra LIE / LSE                  ³
		//³ Senao mostra intervalo (especificado +- tolerancia  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aMedicoes[nPosAMed,nPosGer,1,3] <> "A"
			If aMedicoes[nPosAMed,nPosGer,1,2] $ "4|8" 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ja e verifica o tipo de calculo da tolerancia (1-Numerico / 2-Percentual)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aObjetos[OBJ_MEDICAO_1][13]:Show()
				aObjetos[OBJ_MEDICAO_1][14]:Show()				
				aObjetos[OBJ_MEDICAO_1][15]:Hide()
				aObjetos[OBJ_MEDICAO_1][16]:Hide()				
			Else
				aObjetos[OBJ_MEDICAO_1][13]:Hide()
				aObjetos[OBJ_MEDICAO_1][14]:Hide()				
				aObjetos[OBJ_MEDICAO_1][15]:SetText(STR0092)
				aObjetos[OBJ_MEDICAO_1][15]:Show()
				aObjetos[OBJ_MEDICAO_1][16]:SetText(STR0093)				
				aObjetos[OBJ_MEDICAO_1][16]:Show()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica o tipo de calculo da tolerancia (1-Numerico / 2-Percentual)³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nEspec := SuperVal(aMedicoes[nPosAMed,nPosEsp])
				nMinim := SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])
				nMaxim := SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])
				If Alltrim(aMedicoes[nPosAMed,nPosGer,1,21]) <> "1"					
					If !lUniGual
						nLIE :=	nEspec - ((nMinim * nEspec ) / 100)//SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */ - ((SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */) * SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])*nCoef)/100
						nLSE :=	nEspec + ((nMaxim * nEspec ) / 100)//SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */ + ((SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */) * SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])*nCoef)/100
					Else
						nLIE :=	SuperVal(aMedicoes[nPosAMed,nPosEsp]) - (SuperVal(aMedicoes[nPosAMed,nPosEsp]) * SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2]))/100
						nLSE :=	SuperVal(aMedicoes[nPosAMed,nPosEsp]) + (SuperVal(aMedicoes[nPosAMed,nPosEsp]) * SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1]))/100
					Endif	
				Else
					If !lUniGual
						nLIE :=	nEspec - nMinim//SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */ - SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])*nCoef
						nLSE :=	nEspec + nMaxim//SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */ + SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])*nCoef		
					Else
						nLIE :=	SuperVal(aMedicoes[nPosAMed,nPosEsp]) - SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])
						nLSE :=	SuperVal(aMedicoes[nPosAMed,nPosEsp]) + SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])
					Endif
				Endif

				If !lUniGual
					aObjetos[OBJ_MEDICAO_1][17]:Show()
					aObjetos[OBJ_MEDICAO_1][18]:Show()				
				Else
					
					aObjetos[OBJ_MEDICAO_1][19]:Show() 
					aObjetos[OBJ_MEDICAO_1][20]:Show()				
				Endif   	          
			EndIf
        Endif
		If Alltrim(aMedicoes[nPosAmed][nPosPad]) == "PADRAOEXT"
			aObjetos[OBJ_MEDICAO_1][1]:Show()
			aObjetos[OBJ_MEDICAO_1][2]:Show()					
			aObjetos[OBJ_MEDICAO_1][3]:Show()
			aObjetos[OBJ_MEDICAO_1][4]:Show()						
			aObjetos[OBJ_MEDICAO_1][7]:Hide()
			aObjetos[OBJ_MEDICAO_1][8]:Hide()					
			aObjetos[OBJ_MEDICAO_1][9]:Hide()
			aObjetos[OBJ_MEDICAO_1][11]:Hide()						
		Endif
	Endif
Endif	

Return aObjetos[ OBJ_MEDICAO_1 ]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140ShwEsc³ Autor ³ Fernando Godoy		³ Data ³ 8/31/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra na tela informacoes sobre a escala 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 - Handle da Dialog ativa.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140ChgTree()									  			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140ShwEsc(oDlgPri,oBmpEsc,oBmpPad,oFolderFix)
Local nLoop 		:= 1
Local nCntFor		:= 0
Local nIncTotEsc	:= 0
Local nErrSisEsc	:= 0
Local nTotPad		:= 0
Local nNumDec		:= 0
Local nCoef := 1
Local nLin_aMed 
Local lExatEsc 	:= .T.
Local lAceiEsc 	:= .T.
Local lAdeqEsc 	:= .T.
Local cValor		:= ""
Local cCadastro 
Local aResult		:= {}
Local aRetorno 	:= {}
Local aRelResu := {}
Local oGrp
Local oGrp1
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oSay9
Local oSay10
Local oSay11
Local oSay12
Local oSay13
Local oSay14
Local oSay15
Local oSay16
Local oSay17
Local oSay18
Local oSay19
Local oSay20
Local oIcon
Local oDlgEsc
Local nOpca := 0
Local nMaxErr := 0
Local lRet := .T.

SetKey(VK_F8,{|| Nil }) 	
SetKey(VK_F5,{|| Nil }) 	
SetKey(VK_F6,{|| Nil }) 	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aRelResu : contem os dados para impressao dos Parametros       ³
//³            de Analise para o Tipo de Calibracao Relogio e      ³
//³            Histerese para Pressao                          	   ³
//³ Conteudo :                                                     ³
//³ Posicao 													   ³
//³ 1		- Escala                                               ³
//³ 2		- Maior Erro de Indicacao Crescente                    ³
//³ 3		- Menor Erro de Indicacao Crescente                    ³
//³ 4		- Maior Erro de Indicacao Total (Crescente/Decrescente)³
//³ 5		- Menor Erro de Indicacao Total (Crescente/Decrescente)³
//³ 6		- Desvio Maximo no sentido Crescente                   ³
//³ 7		- Desvio Total (Crescente/Decrescente)                 ³
//³ 8		- Erro de Retorno                                      ³
//³ 9		- Diferenca do mesmo ponto Crescente e Decrescente     ³
//³ 10		- Histerese											   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLin_aMed := Ascan(aMedicoes, { |x| Alltrim(x[1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt])}) //.and. Alltrim(x[2]) == Alltrim(oCbxPad:aItems[oCbxPad:nAt])})													
cCadastro := OemToAnsi(STR0122)+oCbxEsc:aItems[oCbxEsc:nAt] //"Resultado Escala - "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o numero de padroes existentes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nLoop := 1 To Len(aMedicoes)
	lRetUnid := a140TamDec(@nTam,@cNomin,@cUniMed,@nCoef,nPosAMed)
	If lRetUnid
		If Alltrim(aMedicoes[nLoop][nPosEsc]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt])
			nTotPad := nLoop
			If aMedicoes[nLoop,nPosGer,1,4] == "E"	.and. aMedicoes[nLoop,nPosGer,1,1] == 0
				nNumDec	:= QA_NumDec(aMedicoes[nLoop,nPosGer,1,9])+QA_NUMDEC(StrTran(Str(nCoef),".",","))
				If Valtype(aMedicoes[nLoop,nPosGer,1,9]) == "N"
					cValor	:= StrTran(/* Str */CVALTOCHAR(SuperVal(aMedicoes[nLoop,nPosGer,1,9])*nCoef/* ,Len(Alltrim(Str(aMedicoes[nLoop,nPosGer,1,9]))),nTam */),".",",")
				Else
					cValor	:= StrTran(/* Str */CVALTOCHAR(SuperVal(aMedicoes[nLoop,nPosGer,1,9])*nCoef/* ,Len(aMedicoes[nLoop,nPosGer,1,9]),nTam */),".",",")
				Endif	
			Else
				If QA_NumDec(aMedicoes[nLoop,nPosEsp])+QA_NumDec(StrTran(Str(nCoef),".",",")) > nNumDec
					nNumDec	:= QA_NumDec(aMedicoes[nLoop,nPosEsp])+QA_NUMDEC(StrTran(Str(nCoef),".",","))
					cValor	:= StrTran(/* Str */CVALTOCHAR(SuperVal(aMedicoes[nLoop,nPosEsp])*nCoef/* ,Len(aMedicoes[nLoop,nPosEsp]),nTam */),".",",")
				EndIf
			EndIf
  		EndIf
	Else
		lRet := .F.
		oFolderFix:lReadOnly := .T.
		oCbxEsc:lReadOnly	:= .T.
		oCbxPad:lReadOnly	:= .T.
		Exit
	Endif
Next nLoop

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega aResult com resultado de final de todos os pontos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lRet
DEFINE MSDIALOG oDlgEsc TITLE cCadastro FROM 20,190  TO 280,675 OF GetWndDefault() PIXEL
If lRetUnid
	For nLoop := nLin_aMed To nTotPad
		aRetorno := a140Calc( nLoop )
		If Len(aRetorno) == 2
			Aadd( aResult, aRetorno[2] )
		Elseif Len(aRetorno) == 4
			Aadd( aResult, aRetorno[2] )
			Aadd( aResult, aRetorno[4] )
		Else
			Aadd( aResult, aRetorno[1] )
		EndIf
	Next nLoop

	nLin_aMed := Ascan(aMedicoes, { |x| Alltrim(x[1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt]) .and. Alltrim(x[2]) == Alltrim(oCbxPad:aItems[oCbxPad:nAt])})													
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica resultado final da Escala, considerando: 				  	³
	//³																	  	³
	//³ Incerteza Total := Maior Incerteza Total dentre os pontos		  	³
	//³ Erro Sistem tico := Maior Desvio M‚dio dentre os pontos 		  	³
	//³ Os crit‚rios de exatid„o, aceitabilidade e adequa‡„o ao uso s„o a-	³
	//³ ceitos, desde que cada crit‚rio tenha aceita‡„o em todos os pontos	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aResult) > 0
		nIncTotEsc := QmtNum(aResult[1,5]) // Incerteza Total do Primeiro Ponto
		nErrSisEsc := QmtNum(aResult[1,2]) // Desvio M‚dio do Primeiro Ponto
		nMaxErr		:= QmtNum(aResult[1,6])// Maior Erro Maximo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula Parametros para Analise do Tipo de Calibracao Relogio e Pressao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aRelResu,QmtNum(aResult[1,11]))	// Maior Erro de Indicacao Crescente 						1
		AADD(aRelResu,QmtNum(aResult[1,11]))	// Menor Erro de Indicacao Crescente  						2
		AADD(aRelResu,QmtNum(aResult[1,11]))	// Maior Erro de Indicacao Total (Crescente/Decrescente)    3
		AADD(aRelResu,QmtNum(aResult[1,11]))	// Menor Erro de Indicacao Total (Crescente/Decrescente)    4
		AADD(aRelResu,QmtNum(aResult[1,11]))	// Desvio Maximo no sentido Crescente                       5
		AADD(aRelResu,QmtNum(aResult[1,11]))	// Desvio Total (Crescente/Decrescente)                     6
		AADD(aRelResu,0)						// Erro de Retorno                                          7
		AADD(aRelResu,QmtNum(aResult[1,11]))	// Diferenca do mesmo ponto Crescente e Decrescente         8
		AADD(aRelResu,0)						// Histerese                                                9
		
		If aMedicoes[nLin_aMed,nPosGer,1,6] == '1'  // Se tipo de laudo = Incerteza c/ Conf.Metrol.
			lExatEsc := aResult[1,7] // Exatid„o do Primeiro Ponto
			lAceiEsc := aResult[1,8] // Aceita‡„o do Primeiro Ponto
			lAdeqEsc := aResult[1,9] // Adequa‡„o ao Uso do Primeiro Ponto
		EndIf
		For nCntFor := 2 to Len(aResult)
			nIncTotEsc := Iif(QmtNum(aResult[nCntFor,5]) > nIncTotEsc, QmtNum(aResult[nCntFor,5]), nIncTotEsc)
			nErrSisEsc := Iif(QmtNum(aResult[nCntFor,2]) > nErrSisEsc, QmtNum(aResult[nCntFor,2]), nErrSisEsc)
			nMaxErr	  := Iif(QmtNum(aResult[nCntFor,6]) > nMaxErr   , QmtNum(aResult[nCntFor,6]), nMaxErr   )
			If aMedicoes[nLin_aMed,nPosGer,1,6] == '1'  // Se tipo de laudo = Incerteza c/ Conf.Metrol.
				If !empty(aResult[nCntFor,10]) //Se status nao estiver em branco
					lExatEsc := Iif(lExatEsc,Iif(aResult[nCntFor,7],.T.,.F.),.F.)
					lAceiEsc := Iif(lAceiEsc,Iif(aResult[nCntFor,8],.T.,.F.),.F.)
					lAdeqEsc := Iif(lAdeqEsc,Iif(aResult[nCntFor,9],.T.,.F.),.F.)
				EndIf
			EndIf
			If aMedicoes[nLin_aMed,nPosGer,1,2] == "3"		// Tipo de Calibracao Pressao
				If (nCntFor/2) = INT(nCntFor/2)					// Coluna e par (Decrescente)
					aRelResu[ 8]	:= ABS(aRelResu[ 8] - QmtNum(aResult[nCntFor,11]))
					If aRelResu[ 8] > aRelResu[ 7]
						aRelResu[ 7]  	:= aRelResu[ 8]
						aRelResu[ 9]	:= QmtNum(aResult[nCntFor,12])
					EndIf
				Else														// Coluna e impar (Crescente)
					aRelResu[ 8]	:= QmtNum(aResult[nCntFor,11])
				EndIf
			ElseIf aMedicoes[nLin_aMed,nPosGer,1,2] == "9"   // Tipo de Calibracao Relogio
				If (nCntFor/2) = INT(nCntFor/2)						// Coluna e par (Decrescente)
					aRelResu[ 3]	:=		Iif(QmtNum(aResult[nCntFor,11]) > aRelResu[ 3], QmtNum(aResult[nCntFor,11]), aRelResu[ 3])
					aRelResu[ 4]	:=		Iif(QmtNum(aResult[nCntFor,11]) < aRelResu[ 4], QmtNum(aResult[nCntFor,11]), aRelResu[ 4])
					aRelResu[ 6]	:= 		ABS(aRelResu[ 3] - aRelResu[ 4])
					aRelResu[ 8]	:=		ABS(aRelResu[ 8] - QmtNum(aResult[nCntFor,11]))
					aRelResu[ 7]  	:=		Iif(aRelResu[ 8] > aRelResu[ 7],aRelResu[ 8], aRelResu[ 7])
					aRelResu[ 9]	:=		aRelResu[ 7] / Sqrt(12)
				Else 															// Coluna e impar (Crescente)
					aRelResu[ 1]	:= 	Iif(QmtNum(aResult[nCntFor,11]) > aRelResu[ 1], QmtNum(aResult[nCntFor,11]), aRelResu[ 1])
					aRelResu[ 2]	:= 	Iif(QmtNum(aResult[nCntFor,11]) < aRelResu[ 2], QmtNum(aResult[nCntFor,11]), aRelResu[ 2])
					aRelResu[ 5]	:= 	ABS(aRelResu[ 1]-aRelResu[ 2])
					aRelResu[ 3]	:= 	Iif(QmtNum(aResult[nCntFor,11]) > aRelResu[ 3], QmtNum(aResult[nCntFor,11]), aRelResu[ 3])
					aRelResu[ 4]	:= 	Iif(QmtNum(aResult[nCntFor,11]) < aRelResu[ 4], QmtNum(aResult[nCntFor,11]), aRelResu[ 4])
					aRelResu[ 6]	:= 	ABS(aRelResu[ 3]-aRelResu[ 4])
					aRelResu[ 8]	:= 	QmtNum(aResult[nCntFor,11])
				EndIf
			EndIf
		Next nCntFor
		If aMedicoes[nLin_aMed,nPosGer,1,2] == "3" .and.;	// Tipo de Calibracao Pressao
			aRelResu[ 9] <> 0
			aRelResu[ 9]	:= (aRelResu[ 7] / aRelResu[ 9]) * 100
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dados do Cabecalho ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	@ 1.1,2.3 ICON oIcon RESOURCE "ESCALA" OF oDlgEsc
	
	If aMedicoes[nLin_aMed,nPosGer,1,2] <> "9"
		@ 10,18 GROUP oGrp TO 113,131 LABEL STR0036 OF oDlgEsc PIXEL		//"Resultados da Escala"
	Endif	
	@ 35,30 SAY oSay1 PROMPT STR0037 SIZE 60, 7.5 OF oDlgEsc PIXEL //'Incerteza Total:'
	@ 43,30 SAY oSay2 PROMPT STR0088 SIZE 60, 7.5 OF oDlgEsc PIXEL //'Maior Desvio:'
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dados do Resultado da escala ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aMedicoes[nLin_aMed,nPosGer,1,4] == "E" .and. aMedicoes[nLin_aMed,nPosGer,1,1] == 0
		//Se for externo sem medicoes
		@ 35,84 SAY oSay6 PROMPT nIncTotEsc SIZE 35,7.5 OF oDlgEsc RIGHT PIXEL
		@ 43,84 SAY oSay7 PROMPT nErrSisEsc SIZE 35,7.5 OF oDlgEsc RIGHT PIXEL
	Else
		@ 35,84 SAY oSay6 PROMPT nIncTotEsc	SIZE 35,7.5 OF oDlgEsc RIGHT PIXEL PICTURE QMT140Pics("nIncTotEsc",cValor)
		@ 43,84 SAY oSay7 PROMPT nErrSisEsc	SIZE 35,7.5 OF oDlgEsc RIGHT PIXEL PICTURE QMT140Pics("nErrSisEsc",cValor)
		@ 51,30 SAY oSay2 PROMPT STR0123	SIZE 60, 7.5 OF oDlgEsc PIXEL //'Maior Erro:'	
		@ 51,84 SAY oSay7 PROMPT nMaxErr	SIZE 35,7.5 OF oDlgEsc RIGHT PIXEL PICTURE QMT140Pics("nMaxErr",cValor)		
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros para Analise do Tipo de Calibracao Relogio ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aMedicoes[nLin_aMed,nPosGer,1,2] == "9" //Tipo Relogio
		@ 1.1,2.3 ICON oIcon RESOURCE "ESCALA" OF oDlgEsc
		@ 8,18	GROUP	oGrp	TO 113,131 LABEL STR0036 OF oDlgEsc PIXEL		//"Resultados da Escala"
		@ 35,30 SAY oSay1 PROMPT STR0037 SIZE 60, 7.5 OF oDlgEsc PIXEL //'Incerteza Total:'
		@ 43,30 SAY oSay2 PROMPT STR0088 SIZE 60, 7.5 OF oDlgEsc PIXEL //'Maior Desvio:'                
		If aMedicoes[nLin_aMed,nPosGer,1,4] == "E" .and. aMedicoes[nLin_aMed,nPosGer,1,1] == 0
			//Se for Externo sem Medicoes
			@ 35,84 SAY oSay6 PROMPT nIncTotEsc SIZE 35,7.5 OF oDlgEsc RIGHT PIXEL
			@ 43,84 SAY oSay7 PROMPT nErrSisEsc SIZE 35,7.5 OF oDlgEsc RIGHT PIXEL
		Else
			@ 35,84 SAY oSay6 PROMPT nIncTotEsc SIZE 35,7.5 OF oDlgEsc RIGHT PIXEL PICTURE QMT140Pics("nIncTotEsc",cValor)
			@ 43,84 SAY oSay7 PROMPT nErrSisEsc SIZE 35,7.5 OF oDlgEsc RIGHT PIXEL PICTURE QMT140Pics("nErrSisEsc",cValor)
			@ 51,84 SAY oSay7 PROMPT nMaxErr    SIZE 35,7.5 OF oDlgEsc RIGHT PIXEL PICTURE QMT140Pics("nMaxErr",cValor)			
		EndIf
		@ 8,130	GROUP	oGrp1 TO 113,225 LABEL STR0102 OF oDlgEsc PIXEL //"Parametros de Analise"
		@ 35,132	SAY oSay11	PROMPT STR0099 		SIZE 50,7.5		OF oDlgEsc PIXEL //"Desvio Max.Cres. (fe)"
		@ 43,132	SAY oSay12	PROMPT STR0100 		SIZE 50,7.5		OF oDlgEsc PIXEL //"Desvio total (fges)"
		@ 51,132	SAY oSay13	PROMPT STR0101 		SIZE 50,7.5		OF oDlgEsc PIXEL //"Erro de retorno (fu)"
		@ 35,187	SAY oSay14  PROMPT aRelResu[5]	SIZE 35,7.5		OF oDlgEsc RIGHT PIXEL PICTURE QMT140Pics("nDesMasC",cValor)
		@ 43,187	SAY oSay15  PROMPT aRelResu[6]	SIZE 35,7.5		OF oDlgEsc RIGHT PIXEL PICTURE QMT140Pics("nDesTotal",cValor)
		@ 51,187	SAY oSay16  PROMPT aRelResu[7]	SIZE 35,7.5		OF oDlgEsc RIGHT PIXEL PICTURE QMT140Pics("nDesRet",cValor)
	
	Endif
	If aMedicoes[nLin_aMed,nPosGer,1,6] == "1" //Com Confirmacao Metrologica
		@ 59,30 SAY oSay3 PROMPT STR0038 SIZE 50, 7.5 OF oDlgEsc PIXEL //'Exatidão:'
		@ 67,30 SAY oSay4 PROMPT STR0039 SIZE 50, 7.5 OF oDlgEsc PIXEL //'Aceitabilidade:'
		@ 75,30 SAY oSay5 PROMPT STR0040 SIZE 50, 7.5 OF oDlgEsc PIXEL //'Adequação ao Uso:'
		@ 59,84 SAY oSay8  PROMPT Iif(lExatEsc,STR0026,STR0027) SIZE 35,7.5 OF oDlgEsc PIXEL COLOR Iif(lExatEsc,CLR_BLUE,CLR_HRED) RIGHT //"Aceito" ### "Rejeitado"
		@ 67,84 SAY oSay9  PROMPT Iif(lAceiEsc,STR0026,STR0027) SIZE 35,7.5 OF oDlgEsc PIXEL COLOR Iif(lAceiEsc,CLR_BLUE,CLR_HRED) RIGHT //"Aceito" ### "Rejeitado"
		@ 75,84 SAY oSay10 PROMPT Iif(lAdeqEsc,STR0026,STR0027) SIZE 35,7.5 OF oDlgEsc PIXEL COLOR Iif(lAdeqEsc,CLR_BLUE,CLR_HRED) RIGHT //"Aceito" ### "Rejeitado"
		If !(aMedicoes[nLin_aMed,nPosGer,1,2] $ "1|2|4|5|8")
			@ 81,30 SAY oSay17 PROMPT STR0103 SIZE 50, 7.5 OF oDlgEsc PIXEL //"Histerese"
			@ 81,84 SAY oSay18  PROMPT aRelResu[ 9]  SIZE 35,7.5 OF oDlgEsc RIGHT PIXEL PICTURE QMT140Pics("nHistere",cValor)
		Endif
	Else
		@ 59,30 SAY	oSay3 	PROMPT Space(30)		SIZE 50,7.5 OF oDlgEsc PIXEL
		@ 67,30 SAY	oSay4 	PROMPT Space(30)		SIZE 50,7.5 OF oDlgEsc PIXEL
		@ 75,30 SAY	oSay5 	PROMPT Space(30) 		SIZE 50,7.5 OF oDlgEsc PIXEL
		@ 59,84 SAY	oSay8		PROMPT Space(30)		SIZE 35,7.5 OF oDlgEsc PIXEL
		@ 67,84 SAY	oSay9		PROMPT Space(30)		SIZE 35,7.5 OF oDlgEsc PIXEL
		@ 75,84 SAY	oSay10 	PROMPT Space(30)		SIZE 35,7.5 OF oDlgEsc PIXEL
		If !(aMedicoes[nLin_aMed,nPosGer,1,2] $ "1|2|4|5|8")
			@ 59,30 SAY	oSay19	PROMPT STR0103 		SIZE 50,7.5 OF oDlgEsc PIXEL	//"Histerese"
			@ 59,84 SAY	oSay20	PROMPT aRelResu[ 9]	SIZE 35,7.5 OF oDlgEsc RIGHT PIXEL PICTURE QMT140Pics("nHistere",cValor)
		Endif
	Endif
Endif

DEFINE SBUTTON FROM 115,211 TYPE 2 ENABLE OF oDlgESc ACTION ( nOpcA := 2,oDlgEsc:End() )

ACTIVATE MSDIALOG oDlgEsc Centered
Endif
If oFolderFix:nOption == 1
	If aMedicoes[nLin_aMed,nPosGer,1,1] <> 0 //.and. aMedicoes[nLin_aMed,nPosGer,1,4] <> "E"
		If aMedicoes[nLin_aMed,nPosGer,1,1] > 1
			If aMedicoes[nLin_aMed,nPosGer,1,2] $ "1|4"		
				aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:SetFocus()
				aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:nRowPos := 1
			Else
				aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:SetFocus()
				aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:nRowPos := 2
			Endif
		Endif	
	Endif
Endif
//Integridade - Permitir incluir/alterar as getdados
If Inclui .or. Altera
	aObjetos[OBJ_PADSEC][2]:oBrowse:nOpc := 3
	aObjetos[OBJ_INSTUTIL][4]:oBrowse:nOpc := 3
	aObjetos[OBJ_NAOCONFOR][2]:oBrowse:nOpc := 3        
	aObjetos[OBJ_INCERT_B][3]:oBrowse:nOpc := 3 
Else	
	aObjetos[OBJ_PADSEC][2]:oBrowse:nOpc := 2
	aObjetos[OBJ_INSTUTIL][4]:oBrowse:nOpc := 2
	aObjetos[OBJ_NAOCONFOR][2]:oBrowse:nOpc := 2
	aObjetos[OBJ_INCERT_B][3]:oBrowse:nOpc := 2 
Endif

A141AprEsc(oDlgPri,oBmpEsc,oBmpPad,aResult) //Atualiza o status da Escala
a141AprPad(oDlgPri,oBmpPad,oBmpEsc) //Atualiza o status do Padrao

SetKey(VK_F8,{|| a140MudPad()}) 	
SetKey(VK_F5,{|| If(Len(aMedicoes) > 0,(nPosAnt := nPosAmed,a141ContrFld(nGot:=oFolderFix:nOption,oFolderFix:nOption,.F.),A140ShwEsc(oDlgPri,oBmpEsc,oBmpPad,oFolderFix)),.F.)}) 	
SetKey(VK_F6,{|| If(Len(aMedicoes) > 0,(nPosAnt := nPosAmed,a141ContrFld(nGot:=oFolderFix:nOption,oFolderFix:nOption,.F.),A140ShwPad(oCbxEsc,oCbxPad,oFolderFix,oDlgPri),A141AprPad(oDlgPri,oBmpPad,oBmpEsc)),.F.)}) 	

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140ShwITB³ Autor ³ Fernando Godoy		  ³ Data ³ 8/31/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra na tela a Getdados de Incerteza do tipo B 			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Pagina Folder Atual  								    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140ChgTree()												    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140ShwITB(oFldFix)
Local aArea := GetArea()
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oSay9
Local oSay10
Local oSay11
Local oSay12
Local oSay13
Local oSay14
Local oGrp1
Local oGrp2
Local oGrp3
Local oGrp4
Local oGrp5
Local aResult	:= {}
Local aObj 		:= {}
Local aStruQMX := FWFormStruct(3, "QMX",,.F.)[3]
Local nX
Local aSize    := FWGetDialogSize(oMainWnd)

If Inclui .or. Altera
	aRotina[3,4] := 3
Endif	

lAtributo := Upper(Alltrim(aMedicoes[nPosAmed,nPosGer,1,3])) == "A"

If !aMedicoes[nPosAmed,nPosGer,1,2] $ "4|8"
	If !lAtributo
		lRetUnid := a140TamDec(@nTam,@cNomin,@cUniMed,@nCoef,nPosAmed)
	Endif	
Else
	lRetUnid := .T.
Endif	

If lRetUnid
	@ 34,65 SAY oSay1 PROMPT OemToAnsi(STR0124)	SIZE 500,7.5 OF oFolderFix:aDialogs[7] PIXEL FONT oArialGr COLOR CLR_HRED //"Essa Escala/Padrao NAO permite utilizar o Controle de "
	@ 40,110 SAY oSay2 PROMPT OemToAnsi(STR0125) SIZE 500,7.5 OF oFolderFix:aDialogs[7] PIXEL FONT oArialGr COLOR CLR_HRED //"Essa Escala/Padrao NAO permite utilizar o Controle de "		
	oSay1:Hide()
	oSay2:Hide()
	Aadd(aObj,oSay1) //1
	Aadd(aObj,oSay2) //2		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva a integridade dos campos de Bancos de Dados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX2")  // Posiciona pq. rotinas internas utilizam inf. do SX2
	dbSeek("QMW")
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta vetor Aheader a ser utilizado na getdados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := {}
	For nX := 1 To Len(aStruQMX)
		If aStruQMX[nX,1] $ "QMX_SIMB  |QMX_FONTE |QMX_DISTR "+;
			"QMX_CODINC|QMX_VALINC|QMX_DIV   |QMX_CSENS |QMX_UI    |QMX_VI    "
			Aadd(aHeader, Q141GetSX3(aStruQMX[nX,1], "", "") )
		EndIf
	Next nX	
	RestArea(aArea)
		
	If lRetUnid
		aResult := A140Calc(nPosAmed)
		If Len(aResult) > 1
			If Len(aResult) > 3
				If aResult[2,5] > aResult[4,5]
					aMedicoes[nPosAmed,nPosGer,1,16] := aResult[2,5]
				Else
					aMedicoes[nPosAmed,nPosGer,1,16] := aResult[4,5]
				EndIf
			Else
				aMedicoes[nPosAmed,nPosGer,1,16] := aResult[2,5]
			EndIf
		Else
			aMedicoes[nPosAmed,nPosGer,1,16] := aResult[1,5]
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega o Array aCols a partir do Array aMedicoes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCols 	:= aClone(aMedicoes[nPosAmed,nPosITB])
		
		oGetITB := MsNewGetDados():New(2,2,(aSize[3] / 2) - 200, (aSize[4] / 2) - 8,nTipo,{||QMT140TITB()},,,,,,,,,oFolderFix:aDialogs[7],aHeader,aCols) //AllwaysTrue()
		oGetITB:oBrowse:bDrawSelect := {|| A140ChgGet( oGetITB,oFolderFix:aDialogs[7] ),A141WhRes(oFolderFix:aDialogs[7],nPosAmed)}
		oGetITB:oBrowse:bDelOk  := {|| A140ChgGet( oGetITB,oFolderFix:aDialogs[7] ),A141WhRes(oFolderFix:aDialogs[7],nPosAmed) } 
		oGetITB:oBrowse:bValid  := {|| A140DelNil(oGetITB),aMedicoes[nPosAmed,nPosITB] := aClone(oGetITB:aCols),oGetITB:ForceRefresh()} //bLostFocus
		
		oGetITB:ForceRefresh()
	    oGetITB:oBrowse:lDisablePaint := .T. 
		Aadd(aObj,oGetITB) //3

		nUsado	:= Len(oGetItb:aCols[1])
				
		@ 100,003 Group oGrp1 TO 130,020	PIXEL OF oFolderFix:aDialogs[7]
		@ 100,019 Group oGrp2 TO 130,082	PIXEL OF oFolderFix:aDialogs[7]
		@ 100,081 Group oGrp3 TO 130,148	PIXEL OF oFolderFix:aDialogs[7]
		@ 100,147 Group oGrp4 TO 130,215	PIXEL OF oFolderFix:aDialogs[7]
		@ 100,214 Group oGrp5 TO 130,373	PIXEL OF oFolderFix:aDialogs[7]
		
		oGrp1:Hide()
		oGrp2:Hide()
		oGrp3:Hide()
		oGrp4:Hide()
		oGrp5:Hide()
		Aadd(aObj,oGrp1) //4
		Aadd(aObj,oGrp2) //5
		Aadd(aObj,oGrp3) //6
		Aadd(aObj,oGrp4) //7
		Aadd(aObj,oGrp5) //8

		@ 101,008 SAY oSay3	  PROMPT STR0041 	SIZE 6.5,8	PIXEL OF oFolderFix:aDialogs[7] //"Uc"
		@ 101,022 SAY oSay4	  PROMPT STR0042 	SIZE 57.5,8	PIXEL OF oFolderFix:aDialogs[7] //"Inc.Padron.Combinada"
		@ 101,084 SAY oSay5	  PROMPT STR0043 	SIZE 50,8	PIXEL OF oFolderFix:aDialogs[7] //"Nor"
		@ 101,149 SAY oSay6	  PROMPT STR0044 	SIZE 36,8	PIXEL OF oFolderFix:aDialogs[7] COLOR CLR_BLUE //"Ui =          "
		@ 110,008 SAY oSay7	  PROMPT STR0045 	SIZE 6.5,8	PIXEL OF oFolderFix:aDialogs[7] //"U"
		@ 110,022 SAY oSay8	  PROMPT STR0046 	SIZE 57.5,8	PIXEL OF oFolderFix:aDialogs[7] //"Inc.Expandida"
		@ 110,084 SAY oSay9	  PROMPT STR0047 	SIZE 50,8	PIXEL OF oFolderFix:aDialogs[7] //"Nor k = 2"
		@ 110,149 SAY oSay10  PROMPT STR0048 	SIZE 36,8	PIXEL OF oFolderFix:aDialogs[7] COLOR CLR_BLUE //"Ui =          "
		@ 119,008 SAY oSay11  PROMPT STR0048	SIZE 6.5,8	PIXEL OF oFolderFix:aDialogs[7] //"Ui =          "
		@ 119,022 SAY oSay12  PROMPT STR0049	SIZE 57.5,8	PIXEL OF oFolderFix:aDialogs[7] //"Inc.Expandida"
		@ 119,084 SAY oSay13  PROMPT STR0050	SIZE 50,8	PIXEL OF oFolderFix:aDialogs[7] COLOR CLR_HRED //"Nor kp =       "
		@ 119,149 SAY oSay14  PROMPT STR0051	SIZE 36,8	PIXEL OF oFolderFix:aDialogs[7] COLOR CLR_BLUE //"Ui =          "
		@ 110,216 SAY oSay15  PROMPT STR0052	SIZE 36,8	PIXEL OF oFolderFix:aDialogs[7] COLOR CLR_HRED //"Veff =       "
			
		oSay3:Hide()
		oSay4:Hide()
		oSay5:Hide()
		oSay6:Hide()
		oSay7:Hide()
		oSay8:Hide()															
		oSay9:Hide()
		oSay10:Hide()
		oSay11:Hide()
		oSay12:Hide()
		oSay13:Hide()
		oSay14:Hide()															
		oSay15:Hide()															

		Aadd(aObj,oSay3) //9
		Aadd(aObj,oSay4) //10
		Aadd(aObj,oSay5) //11
		Aadd(aObj,oSay6) //12
		Aadd(aObj,oSay7) //13
		Aadd(aObj,oSay8) //14
		Aadd(aObj,oSay9) //15
		Aadd(aObj,oSay10) //16
		Aadd(aObj,oSay11) //17
		Aadd(aObj,oSay12) //18
		Aadd(aObj,oSay13) //19
		Aadd(aObj,oSay14) //20
		Aadd(aObj,oSay15) //21
			
		Aadd(aObj,aHeader) //22
			
		aObjetos[OBJ_INCERT_B] := aObj 
			
		A141WhRes(oFolderFix:aDialogs[7],nPosAmed)
			
	Endif	
Endif
aHeader := {}
aCols	:= {} 
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³BsLegenda ³ Autor ³ Fernando Godoy	    ³ Data ³ 9/1/1998 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Desenha uma legenda com bitmaps na tela 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 - Handle da Janela onde sera incerido os Bitmaps 	  ³±±
±±³			 ³ExpA1 - Array Bi-dimensional com Nome Bitmap,Texto		  ³±±
±±³			 ³ExpN1 - Linha onde sera pintado o primeiro bmp			  ³±±
±±³			 ³ExpN2 - Coluna onde sra pintado o primeniro bmp			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Generico													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*Function BsLegenda( oDlgPri, aBmp_Text,nLin,nCol )
Local oGroup
Local nLoop 		:= 0
Local aRes			:= {}
Local nNrBmps		:= 0
Local nColIni		:= 0
Local oBmp

Default oDlg		:= GetWndDefault()
Default aBmp_text := {{"DISABLE","Desabilitado"}}
Default nLin		:= 5
Default nCol		:= 5

nColIni := nCol

@ nLin-4, nCol-4 TO nLin+10, nCol+10 LABEL "Legenda" OF oDlg

For nLoop := 1 To Len(aBmp_Text)
	@ nLin, nCol BITMAP RESOURCE aBmp_Text[nLoop,1] NOBORDER OF oDlg PIXEL
	@ nLin, nCol+15 SAY aBmp_Text[nLoop,2] OF oDlg PIXEL
	nCol	+= 30
	If nLoop > 3
		nLin	+= 10
		nCol	:= nColIni
	EndIf
Next nLoop

Return Nil
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140GrvAll³ Autor ³ Fernando Godoy		³ Data ³ 8/25/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava as informacoes Contidas no array aMedicoes 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 - Handle da Dialog mae								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpL1 - .T. Confirmou - .F. Nao confirmou					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140Inclui - Botao Ok da ToolBar							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140GrvAll(oDlgPri,nOpcx)

Local oDlgados
Local oDlgFim
Local oGrp1
Local oGrp2
Local oBmp
Local oRad1
Local oRad2
Local oRad3
Local oRad4
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oSay9
Local oSay10
Local oSay11
Local oSay12
Local oSay13
Local oSay14
Local oSay15
Local oSay16
Local oSay17
Local oSay18
Local oSay19
Local oSay20
Local oSay21
Local oList
Local oBtn1
Local oBtn2
Local oIcon
Local oIcon2
Local oMeter
Local oMemo
Local oMemo2
Local oMemo3
Local aHandle		:= {}
Local nPosAtu		:= 1
Local lContinua	:= .F. 
Local nRad1 		:= Iif(Altera .or. Inclui,RetCond(),;
					   Iif(QM6->QM6_COND=="A",1,Iif(QM6->QM6_COND=="C",2,3)))
Local nRad2 		:= 3
Local nRad3 		:= 1
Local nRad4			:= 1
Local nNumPag		:= 8
Local aList 		:= RetStatus("T")
Local cStatAtu
Local aResult		:= {}
Local nLoop 		:= 0
Local nLoop2		:= 0
Local nRad2Atu 	:= 3	// Guarda o valor inicial do laudo
Local aShow 		:= {}
Local cStrIni		:= ""
Local aStatus		:= A140MudaFr( nRad1, nOpcx )
Local dDataVal 	:= Ctod("  /  /  ","DDMMYY")
Local aResFim		:= {}
Local cTextFr		:= ""
Local cTextCal 	:= ""
Local oBmpImp
Local cSemana     := ""
Local nFile			:= 0
Local aImpCer	:= {}
Local lVisual := IIf(Inclui .or. Altera,.F.,.T.)
Local nx := 1
Local lPosAtuFim := .F.
Local oGrp3
Private cList 		:= RetStatus("A")
Private cStaAnt
Private cMemo1		:= RetTextAtu(1)
Private cMemo2		:= RetTextAtu(2)
Private cMemo3		:= RetTextAtu(3)
Private cFreq		:= ""
Private aQmtEnt		:= {}
Private aArrayIC	:= {}
Private aDateFrq	:= {}

cStatAtu 	:= cList // Guarda o valor inicial do status
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe ponto de entrada p/ assi-³
//³	natura eletronica                    		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetUnid // Se existir a conversao de unidade de medida
If Altera .or. lVisual
	If !Empty(QM6->QM6_STATUS)
		cStaAnt := PegaStatus(QM6->QM6_STATUS)
	Else
		cStaAnt := PegaStatus(cList)	   			
	Endif
Else
   cStaAnt := PegaStatus(cList)	   
Endif

Aadd(aImpCer, {cMtInstr,dMtData,cMtResp,cMtRevIns,cMtTotHr,cMtRepRepr})

If ExistBlock("QMT140OK")
	lContinua := ExecBlock("QMT140OK",.F.,.F.)
	If !lContinua
	   lBlkGrv:=.F.
	Else
	   lBlkGrv:=.T.
	Endif   
EndIf

If ExistBlock("QMT140AS")
	lContinua := .T. // Não existe checagem de falta de dados
	lBlkGrv := ExecBlock("QMT140AS",.F.,.F.,{nOpcx})
EndIf

If lBlkGrv
	If lEscSchu 	
		nRad3 := 2
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³												³
	//³ Verifica se Informa condicao de Recebimento ³
	//³												³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If cFreqSch == "S"
		If Empty(aStatus[1])
		   If lEscSchu 
				If nRad3 == 2
					cTextCal	:= aStatus[4]				
				Else
					cTextCal	:= aStatus[1]				
				Endif
		   Else
			   cTextCal	:= aStatus[1]
		   Endif
		   cTextFr	:= aStatus[4]
		   dDataVal	:= aStatus[7]   
		Else   
			//ÚÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pergunta ³
			//ÀÄÄÄÄÄÄÄÄÄÄÙ
			If aStatus[2] == "P"
				If lEscSchu 
					If nRad3 == 2
						cTextCal	:= aStatus[4]				
					Else
						cTextCal	:= aStatus[1]				
					Endif
				Else
					cTextCal	:= aStatus[1]
				Endif
				cTextFr		:= aStatus[4]				
				If aStatus[9] == "M" .or. aStatus[9] == "D"
					dDataVal	:= aStatus[5]				
				Else
					dDataVal	:= aStatus[7]				
				Endif	
				//ÚÄÄÄÄÄÄÄ¿
				//³ Aviso ³
				//ÀÄÄÄÄÄÄÄÙ
			Elseif aStatus[2] == "A"
				cTextCal	:= aStatus[1]
				cTextFr		:= aStatus[4]
				dDataVal	:= aStatus[7]
			EndIf
		EndIf
	Else
		cTextFr		:= aStatus[4]
		dDataVal	:= aStatus[7]
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³													³
	//³ Verifica status dos pontos para sugerir o laudo ³
	//³													³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If Altera .or. Inclui // Se for visualizacao, pegar o que esta gravado
		For nLoop := 1 To Len(aMedicoes)
			aResult := A140Calc( nLoop )
			nloop2 := Len(aResult)  // Pega a ultima coluna (equivale a final)
			If !Upper(aResult[nLoop2,10]) $ "A "
				nRad2 := 1
				Exit
			EndIf
		Next nLoop
	Else
		nRad2 := If(QM6->QM6_LAUDO=="A",3,If(QM6->QM6_LAUDO="R",1,2))
	EndIf

	//+-------------------------------------------------+
	//¦Ponto de Entrada para que seja tratada a Data de ¦
	//¦Frequencia e calibracao para o instrumento.      ¦
	//+-------------------------------------------------+
	If ExistBlock("QMT140Df")                                                 
        dDataVal := ExecBlock("QMT140Df",.F.,.F.,{dDataVal,If(nRad2==1,"R","A")})
	EndIf                                                                     
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se e reprovado para sugerir Status Inativo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Altera .or. Inclui // Se for visualizacao, pegar o que esta gravado
		If nRad2 == 1
			cList 	:= RetStatus("I")
			cStatAtu := cList
		EndIf
	EndIf
	
	nRad2Atu  := nRad2	// Atribui o status para guardar
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³																³
	//³ Caso tenha medicao externa checa se foram digitados os dados³
	//³																³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lContinua := A140ChkExt() // Verifica se digitou No.Certificado e Laboratorio
	
	If lContinua .and. !ExistBlock("qmt140AA")
		lContinua := A140ChkIDm() // Verifica se digitou incerteza e desvio
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada para que seja tratada a Data de Frequencia ³
	//³e Frequencia de Afericao									   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If ExistBlock("QMT140FrAf")                                                 
        dbSelectArea("QM2")
        dbSetOrder(1)
        If dbSeek(xFilial("QM2")+cMtInstr+Inverte(cMtRevIns))
			cFreq 	:= Str(QM2->QM2_FREQAF,0)
        Endif
        aDateFrq := ExecBlock("QMT140FrAf",.F.,.F.,{@dDataVal,If(nRad2==1,"R","A"),@cFreq,nOpcx,cMtInstr,cMtRevIns,cSeql,dMtData})
        dDataVal := aDateFrq[1]
        cFreq	 := aDateFrq[3]
        //Garantir retorno da variavel com tipo caracter
		If Valtype(cFreq) == "N"
			cFreq := Alltrim(Str(cFreq,0))
		Endif
		cTextFr  := OemToAnsi(STR0005)+cFreq+OemToAnsi(STR0004)+" "+OemToAnsi(STR0006)+DtoC(dDataVal)				
	EndIf                                                                     

	If lContinua
		lContinua := .F.	// Seta para falso p/ Quando ALT+F4 não gravar
		DEFINE MSDIALOG oDlgFim FROM 58,1 TO 310,450 TITLE OemToAnsi(STR0053) PIXEL OF oDlgPri  //"Finalizacao"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cabecalho padrao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                       
		@ 1,1 GROUP oGrp3 TO 290, 413 LABEL " " OF oDlgFim  PIXEL
		oGrp3:Hide()
		@ 005, 007 BITMAP oBmp RESOURCE "CELERINA" SIZE 065, 107 OF oDlgFim ADJUST PIXEL NOBORDER
		@ 003, 076 GROUP oGrp1 TO 104, 217 LABEL "" OF oDlgFim  PIXEL
		oGrp1:Hide()
		@ 110, 115 BUTTON oBtn1 PROMPT STR0054 SIZE 44, 11 OF oDlgFim PIXEL ACTION (lContinua := A140ChgTel(aHandle,1,@nPosAtu,oBtn1,oBtn2,oDlgFim,@nNumPag,cStatAtu,nRad2Atu,@aResFim,@cTextFr, @cFreq,@dDataVal,@cTextCal,aStatus,@lPosAtuFim)) //"&Cancelar"
		@ 110, 159 BUTTON oBtn2 PROMPT STR0055 SIZE 44, 11 OF oDlgFim PIXEL ACTION (lContinua := A140ChgTel(aHandle,2,@nPosAtu,oBtn1,oBtn2,oDlgFim,@nNumPag,cStatAtu,nRad2Atu,@aResFim,@cTextFr, @cFreq,@dDataVal,@cTextCal,aStatus,@lPosAtuFim)) //"&Avançar >>
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Justificativa para nao digitacao de todas as medicoes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 0.5, 10 ICON oIcon2 RESOURCE "CLIPS" OF oDlgFim NOBORDER
		@ 005, 103 SAY oSay8 PROMPT STR0056 SIZE 096, 30 OF oDlgFim PIXEL //"Digite abaixo a justificativa para a não digitação de todas as medições."
		@ 035, 082 GET oMemo VAR cMemo1 SIZE 116,50 OF oDlgFim MEMO NO VSCROLL PIXEL
		oMemo:bGotFocus := { || oMemo:nPos := 0,oMemo:Refresh()}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Condicao de Recebimento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 005, 082 SAY oSay1 PROMPT STR0057 + Capital(cMtInstr)+":" SIZE 116, 22 OF oDlgFim PIXEL //"Informe aqui a Condição de Recebimento do instrumento "
		@ 045, 100 RADIO oRad1 VAR nRad1 ITEMS STR0058,STR0059,STR0060 OF oDlgFim PIXEL SIZE 50,13 //"Ava&ria" ### "&Conforme" ### "&Não Conforme"
		If Alltrim(cFreqSch) <> "S"
			oSay1:Disable()
			oRad1:Disable()
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validade e Frequencia da calibracao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  		cSemana := RetSem(dDataVal)
		@ 053, 076 GROUP oGrp2 TO 108,205 OF oDlgFim PIXEL
	   	@ 004, 082 SAY oSay2  PROMPT (StrTran(STR0061,"%@@",Capital(cMtInstr))) OF oDlgFim PIXEL SIZE 116,75 //"Abaixo está a Validade e Frequência de Calibração para o instrumento %@@. Se você optou pelo uso da tabela de Schumacher poderá surgir uma pergunta sobre a alteração do período de calibração."
        @ 070, 082 SAY oSay11 PROMPT STR0062 OF oDlgFim PIXEL SIZE 130,30 //"Confirma a mudança:"
		@ 090, 082 SAY oSay3  PROMPT cTextFr OF oDlgFim PIXEL SIZE 70,75 FONT oArialBo   
		//Define o conteudo padrao do radio button tabela de Schumacker como NAO         
		If lEscSchu
			nRad3 := 2
		Endif	
		@ 065, 165 RADIO oRad3 VAR nRad3 ITEMS STR0063,STR0064 OF oDlgFim PIXEL SIZE 25,10 //"&Sim" ### "&Não"
		@ 055, 082 SAY oSay15 PROMPT cTextCal OF oDlgFim PIXEL SIZE 70,32 //70,27  
		@ 090, 165 SAY oSay16 PROMPT STR0089   OF oDlgFim PIXEL SIZE 30,06 // "Semana: "
		@ 095, 166 SAY oSay17 PROMPT cSemana  OF oDlgFim PIXEL SIZE 35,06
		
		If aStatus[2] == "P"
			A140ChgFrq(aStatus,@cTextFr,oRad3:nOption,oSay3,@cFreq,@dDataVal,@cSemana,oSay17)
		EndIf
		
		oRad3:bChange	:= {|| A140ChgFrq(aStatus,@cTextFr,oRad3:nOption,oSay3,@cFreq,@dDataVal,@cSemana,oSay17) }

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Laudo final ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		@ 005, 082 SAY oSay4 PROMPT STR0065 OF oDlgFim PIXEL SIZE 130,45 //"Informe agora o laudo final do instrumento. O sistema já traz um laudo sugerido que foi calculado, caso este for alterado será solicitado um texto com a justificativa da mudança do laudo."
		@ 050, 105 RADIO oRad2 VAR nRad2 ITEMS STR0066,STR0067,STR0068 OF oDlgFim PIXEL SIZE 70,10 //"Re&provado" ### "Ap&rovado Condicional" ### "Apro&vado"
		
		@ 085, 082 SAY oSay19 PROMPT STR0091 + ;
		If(QM6->QM6_LAUDO=="A",GetMv("MV_QAPROV"),If(QM6->QM6_LAUDO="R",GetMv("MV_QREPRO"),GetMv("MV_QAPCON"))) OF oDlgFim PIXEL SIZE 116,13 FONT oArialBo

		If !Altera
			oSay19:SetText(Space(10))		
		EndIf                                  

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Condicao do Instrumento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 005, 082 SAY oSay5 PROMPT STR0069+Capital(cMtInstr)+STR0070 OF oDlgFim PIXEL SIZE 116,40 //"Informe a condição atual do instrumento " ### " na lista abaixo. O sistema sempre traz a última condição informada."
		@ 042, 103 LISTBOX oList VAR cList SIZE 65, 35 OF oDlgFim ITEMS aList PIXEL
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Status final do Instrumento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		@ 005, 082 SAY oSay6  PROMPT STR0071+Capital(cMtInstr)+":" OF oDlgFim PIXEL SIZE 116,30 //"Este é o Laudo final do Instrumento "
		@ 030, 082 SAY oSay12 PROMPT STR0072+oRad1:aItems[oRad1:nOption] OF oDlgFim PIXEL SIZE 116,10 //"Cond.Recebimento:  "
		@ 045, 082 SAY oSay13 PROMPT cTextFr OF oDlgFim PIXEL SIZE 80,30
		oSay13:Hide()
		@ 065, 082 SAY oSay14 PROMPT STR0073+cList OF oDlgFim PIXEL SIZE 116,10 //"Cond.Atual.Instr.:  "
		If Inclui .or. Altera 
			@ 073, 082 SAY oSay20 PROMPT OemToAnsi(STR0115)+Alltrim(cList) OF oDlgFim PIXEL SIZE 170,10 //Cond.Instr.Nesta Medicao: 
		ElseIf lVisual
			@ 073, 082 SAY oSay20 PROMPT OemToAnsi(STR0115)+Alltrim(cStaAnt) OF oDlgFim PIXEL SIZE 170,10  					
		Else 
			@ 073, 082 SAY oSay20 PROMPT OemToAnsi(STR0115)+Alltrim(cList) OF oDlgFim PIXEL SIZE 170,10  					
			cStaAnt := cList
    	Endif                                                                                                                
		@ 080, 082 SAY oSay7 PROMPT oRad2:aItems[oRad2:nOption]OF oDlgFim PIXEL SIZE 80,10 FONT oArialBo COLOR Iif(oRad2:nOption == 1,CLR_HRED,Iif(oRad2:nOption == 2,CLR_YELLOW,CLR_BLUE))
		@ 056, 155 SAY oSay18 PROMPT STR0089+" "+cSemana OF oDlgFim PIXEL SIZE 45,07 // "Semana : "
		
		@ 5.3, 022.8 ICON oIcon RESOURCE Iif(oRad2:nOption == 1,"QMT_NO",Iif(oRad2:nOption == 2,"QMT_COND","QMT_OK")) OF oDlgFim NOBORDER
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Justificativa para a mudanca do laudo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 005, 103 SAY oSay9 PROMPT STR0074+Capital(cMtInstr)+"." SIZE 96, 30 OF oDlgFim PIXEL //"Digite abaixo a justificativa pela mudança do laudo do instrumento "
		@ 035, 082 GET oMemo2 VAR cMemo2 SIZE 116,50 OF oDlgFim MEMO NO VSCROLL PIXEL
		oMemo2:bGotFocus := {|| oMemo2:nPos := 0,oMemo2:Refresh()}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Justificativa para a mudancao de status do instrumento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 005, 103 SAY oSay10 PROMPT STR0075+Capital(cMtInstr)+"." SIZE 96, 30 OF oDlgFim PIXEL //"Digite abaixo a justificativa pela mudança do status do instrumento "
		@ 035, 082 GET oMemo3 VAR cMemo3 SIZE 116,50 OF oDlgFim MEMO NO VSCROLL PIXEL
		oMemo3:bGotFocus := { || oMemo3:nPos :=0,oMemo3:Refresh()}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega Array com os Handles ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd( aHandle, oSay1 )	// 1
		Aadd( aHandle, oRad1 )	// 2
		Aadd( aHandle, oSay2 )	// 3        
		Aadd( aHandle, oSay3 )	// 4        
		Aadd( aHandle, oSay4 )	// 5
		Aadd( aHandle, oRad2 )	// 6
		Aadd( aHandle, oSay5 )	// 7
		Aadd( aHandle, oList )	// 8
		Aadd( aHandle, oSay6 )	// 9
		Aadd( aHandle, oSay7 )	// 10
		Aadd( aHandle, oIcon )	// 11
		Aadd( aHandle, oSay8 )	// 12
		Aadd( aHandle, oMemo )	// 13
		Aadd( aHandle, oSay9 )	// 14
		Aadd( aHandle, oMemo2)	// 15
		Aadd( aHandle, oSay10)	// 16
		Aadd( aHandle, oMemo3)	// 17
		Aadd( aHandle, oSay11)	// 18 	       
		Aadd( aHandle, oRad3)	// 19		       
		Aadd( aHandle, oSay12)	// 20
		Aadd( aHandle, oSay13)	// 21
		Aadd( aHandle, oSay14)	// 22
		Aadd( aHandle, oIcon2)	// 23
		Aadd( aHandle, oSay15)	// 24		        
		Aadd( aHandle, oGrp2 )	// 25		        
		Aadd( aHandle, oGrp1 )	// 26
		Aadd( aHandle, oSay16)	// 27         
		Aadd( aHandle, oSay17)  // 28         
		Aadd( aHandle, oSay18)  // 29
		Aadd( aHandle, oSay19)  // 30
		Aadd( aHandle, oSay20)  // 31		  
		Aadd( aHandle, oGrp3)   // 32		 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa a string que contem os handles da primeira tela ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aShow := A140TelAtv( nNumPag,aHandle,nRad2Atu,cStatAtu )
		If aShow[1] 		// Mostra primeiro a tela Just.Nao.Med
			cStrIni	:= "12#13#23#26"
			nPosAtu	:= 1  
		Elseif aShow[2]	// Mostra primeiro a tela de Condicao de Recebimento
			cStrIni	:= "01#02#26"
			nPosAtu	:= 2      
		ElseIf aShow[3]     // Mostra primeiro a tela de Frequencia e Validade					// Mostra primeiro a tela de Frequencia e Validade
			If aStatus[2] == "A"
				cStrIni	:= "03#04#24#25#27#28"
			Elseif aStatus[2] == "P"   
			   If Alltrim(cFreqSch) == "S"
					cStrIni	:= "03#04#18#24#19#25#27#28"
				Else
					cStrIni	:= "03#04#24#25#27#28"
				Endif	
			Else
				cStrIni	:= "03#04#25#27#28"
			EndIf
			nPosAtu	:= 3
		Else
			cStrIni := "09#20#21#22#10#29#11#31"
			nPosAtu := 4
		EndIf
		
		If Empty(aStatus[2]) // Rotina Inclusao - Controle de Frequencia
			If !ExistBlock("QMT140FrAf")
				cFreq := Str(aStatus[8])
			Endif
		Else
			If !ExistBlock("QMT140FrAf")
				cFreq := Str(aStatus[6])			
			Endif	
		Endif

			ShowHide(aHandle,{cStrIni})
			ACTIVATE MSDIALOG oDlgFim CENTER //ON INIT ShowHide(aHandle,{cStrIni})
		
		Release Objects oBmp
	EndIf
	
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso conforme grava os dados nos arquivos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. (Inclui .Or. Altera)
	
	CursorWait()
	
	DEFINE MSDIALOG oDlgados FROM 87,001 TO 147,343 TITLE OemToAnsi(STR0106)PIXEL; //Gravacao
	STYLE Nor( WS_CAPTION, DS_MODALFRAME )
	
	@ 04,10 SAY OemToAnsi(STR0107) SIZE 76, 7 OF oDlgados PIXEL //Atualizando os arquivos...
	
	@13,05 METER oMeter VAR nFile SIZE 159,7 OF oDlgados PIXEL BARCOLOR GetSysColor(13),GetSysColor() COLOR GetSysColor(),GetSysColor(13) NOPERCENTAGE
	
	oDlgados:bStart := { || A140Grvdad( aResFim,cMemo1,cMemo2,cMemo3,cFreq,dDataVal,oMeter ) ,oDlgados:End() }

	ACTIVATE MSDIALOG oDlgados CENTER

	If ExistBlock("QMT140GM")  
		For nx := 1 To Len(aMedicoes)
			aArrayIC := a140Calc(nx)
			If Len(aArrayIC) == 2
				Aadd( aQmtEnt, aArrayIC[2] )
			Elseif Len(aArrayIC) == 4
				Aadd( aQmtEnt, aArrayIC[2] )
				Aadd( aQmtEnt, aArrayIC[4] )
			Else
				Aadd( aQmtEnt, aArrayIC[1] )
			EndIf
		Next nx	
		ExecBlock("QMT140GM",.F.,.F.,{cMtInstr,cMtRevIns,dMtData,lBlkGrv,nOpcx,aQmtEnt,@cFreq,cSeql})
	Endif	

	If ExistBlock("QMT141SC") //Imprime de qualquer relatorio e/ou consistencias
		ExecBlock("QMT141SC",.F.,.F.,{cMtInstr,cMtRevIns,dMtData,lBlkGrv,nOpcx,cSeql})
	Endif
    
	If ExistBlock("QMT140IC") // Impressao de certificado e/ou demais relatorios
		ExecBlock("QMT140IC",.F.,.F.,{cMtInstr,cMtRevIns,dMtData,lBlkGrv,nOpcx,cSeql})
	Else
	    If Inclui .or. Altera
	    	If lBlkGrv //Soh imprimir certificado se ocorrer gravacao de dados
	    	nRad3 := 2
			DEFINE MSDIALOG oDlgFim FROM 58,1 TO 290,413 TITLE OemToAnsi(STR0113) PIXEL OF oDlgPri  //Impressao do Certificado
			@ 005, 007 BITMAP oBmpImp RESOURCE "CELERINA" SIZE 065, 107 OF oDlgFim ADJUST PIXEL NOBORDER
			@ 005, 103 SAY oSay1 PROMPT OemToAnsi(STR0112) SIZE 096, 30 OF oDlgFim PIXEL FONT oArialBo//Deseja imprimir Certificado?
			@ 033, 082 SAY oSay21 PROMPT OemToAnsi(STR0126)+Chr(13)+Chr(10)+OemToAnsi(STR0127) OF oDlgFim PIXEL SIZE 150,22 //Para padroes subjetivos, imprime padroes para calibracao ?
			@ 047, 160 RADIO oRad4 VAR nRad4 ITEMS STR0128,STR0129 OF oDlgFim PIXEL SIZE 25,10 //"S&im" ### "N&ao"
			@ 068, 082 SAY oSay11 PROMPT STR0114 OF oDlgFim PIXEL SIZE 116,22 //Imprime Analise das Ultimas Pecas Produzidas?
			@ 075, 160 RADIO oRad3 VAR nRad3 ITEMS STR0130,STR0131 OF oDlgFim PIXEL SIZE 25,10 //"&Sim" ### "&Nao"
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se conteudo do parametro MV_QICEWOD for igual a "1" o sistema ira imprimir o certificado  ³
			//³de calibracao em Word.                                                                    ³
			//³*** Importante: Deve-se estar com o word atualizado                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If GetMv("MV_QICEWOD") == "2" 
				@ 100, 115 BUTTON oBtn1 PROMPT OemToAnsi(STR0063) SIZE 44, 11 OF oDlgFim PIXEL ACTION (AAdd(aImpCer[1],nRad3),AAdd(aImpCer[1],nRad4),AAdd(aImpCer[1],cSeql),QMTR030(aImpCer),oDlgFim:End())
			Else
				@ 100, 115 BUTTON oBtn1 PROMPT OemToAnsi(STR0063) SIZE 44, 11 OF oDlgFim PIXEL ACTION (AAdd(aImpCer[1],nRad3),AAdd(aImpCer[1],nRad4),AAdd(aImpCer[1],cSeql),QMTR280(aImpCer),oDlgFim:End())
        	Endif

			@ 100, 159 BUTTON oBtn2 PROMPT OemToAnsi(STR0064) SIZE 44, 11 OF oDlgFim PIXEL ACTION (oDlgFim:End()) //Nao
		
			ACTIVATE MSDIALOG oDlgFim CENTER
		
			Release Objects oBmpImp
			Endif	
		Endif	
	EndIf
	
	CursorArrow()
	
EndIf
Endif

If nOpcx == 6
	Inclui := .F.
ElseIf nOpcx == 3
	Inclui := .T.
Endif		       


IF Len(aColAnx) >= 1
	cAliasAnex 	:= "QN7"   	// Variaveis utilizadas em QncACols, QncAHead e 
	aCols 		:= aClone(aColAnx)  // FQNCANEXO
	aHeader		:= aClone(aHeadAnx)
	nAColsAtu 	:= 0        
	nUsado		:= 0
  	QMTGAnexo(nOpcx)
EndIf

Return lContinua
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 	³A140ChgBut³ Autor ³ Fernando Godoy	       ³ Data ³ 9/9/1998 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o 	³Altera a tela de Resultado de padroes para Subida ou Descida³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros	³ExpO1 - Handle do Botao									 ³±±
±±³			 	³ExpA1 - Array com os novos valores							 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 	³Nil 													  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 	³A140ShwPad												  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto 	³Melhor ³ Alteracoes para calibrar Tipo de Calibracao Relogio³±±
±±³Denis Martins³Melhor ³ Utilizacao de QPages para mostrar resultados Relo- ³±±
±±³             ³       ³ gio ou Pressao.  	           				  	     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140ChgBut(oBtn,oDlgPad,aObjetos)
Local nLoop		:= 1
Local aResult
Local nLin_aMed 
Local lUniGual	:= .F.
Local nx		:= 1
                
nLin_aMed := Ascan(aMedicoes, { |x| Alltrim(x[1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt]) .and. Alltrim(x[2]) == Alltrim(oCbxPad:aItems[oCbxPad:nAt])})													
aResult := A140Calc(nLin_aMed)
For nLoop := Len(aResult) TO 4
	Aadd(aResult,{ 0,"", 0, 0, "", 0, "", "", "", "" } )
Next nLoop

a140TamDec(@nTam,@cNomin,@cUniMed,@nCoef,nPosAMed)

If nCoef == 1
	lUniGual := .T.
Endif	

If Alltrim(Upper(oBtn:cCaption)) == STR0076 .Or.; //"<< &SUBIDA"
   Alltrim(Upper(oBtn:cCaption)) == STR0097 		  //"&CRESCENTE >>"
	If aMedicoes[nLin_aMed,nPosGer,1,2] == "3"   // Tipo de Calibracao Pressao
		oBtn:cCaption := STR0025 //"&Descida >>"
	ElseIf aMedicoes[nLin_aMed,nPosGer,1,2] == "9"   // Tipo de Calibracao Relogio
		oBtn:cCaption := STR0098 //"&Decrescente >>"
	EndIf		

	oBtn:Refresh()
	If aObjetos[OBJ_PONTO] == NIL
		@ 05,75 SAY oSay11  PROMPT aResult[1,1] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp], StrTran(/* Str */CVALTOCHAR(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",",")),.T.) // 'M‚dia dos valores'
		@ 14,75 SAY oSay12  PROMPT aResult[1,2] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp], StrTran(/* Str */CVALTOCHAR(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",",")),.T.) // 'Desvio M‚dio'
		@ 23,75 SAY oSay13  PROMPT aResult[1,3] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp], StrTran(/* Str */CVALTOCHAR(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",",")),.T.) // 'Desvio PadrÆo'
		@ 32,75 SAY oSay14  PROMPT aResult[1,4] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp], StrTran(/* Str */CVALTOCHAR(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",",")),.T.) // 'Incerteza'
		@ 41,75 SAY oSay15  PROMPT aResult[1,5] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp], StrTran(/* Str */CVALTOCHAR(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",",")),.T.) // 'Incerteza Total'
		@ 50,75 SAY oSay16  PROMPT aResult[1,6] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp], StrTran(/* Str */CVALTOCHAR(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",",")),.T.) // 'Incerteza Total'
		@ 05,160 SAY oSay21  PROMPT aResult[2,1] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp],StrTran(/* Str */CVALTOCHAR(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",",")),.T.) // 'M‚dia dos valores'
		@ 14,160 SAY oSay22  PROMPT aResult[2,2] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp],StrTran(/* Str */CVALTOCHAR(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",",")),.T.) // 'Desvio M‚dio'
		@ 23,160 SAY oSay23  PROMPT aResult[2,3] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp],StrTran(/* Str */CVALTOCHAR(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",",")),.T.) // 'Desvio PadrÆo'
		@ 32,160 SAY oSay24  PROMPT aResult[2,4] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp],StrTran(/* Str */CVALTOCHAR(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",",")),.T.) // 'Incerteza'
		@ 41,160 SAY oSay25  PROMPT aResult[2,5] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp],StrTran(/* Str */CVALTOCHAR(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",",")),.T.) // 'Incerteza Total'
		@ 50,160 SAY oSay26  PROMPT aResult[2,6] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp],StrTran(/* Str */CVALTOCHAR(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef/* ,Len(aMedicoes[nLin_amed,nPosEsp]),nTam */),".",",")),.T.) // 'Incerteza Total'
		If aMedicoes[nLin_aMed,nPosGer,1,6] == "1" //.and. (Inclui .or. Altera)
			@ 59,75 SAY oSay17	PROMPT Iif(aResult[1,7],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[1,7],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
			@ 68,75 SAY oSay18	PROMPT Iif(aResult[1,8],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[1,8],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
			@ 77,75 SAY oSay19	PROMPT Iif(aResult[1,9],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[1,9],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
			@ 59,160 SAY oSay27	PROMPT Iif(aResult[2,7],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[2,7],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
			@ 68,160 SAY oSay28	PROMPT Iif(aResult[2,8],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[2,8],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
			@ 77,160 SAY oSay29	PROMPT Iif(aResult[2,9],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[2,9],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
		Endif
		@ 84.9,75 SAY oSay20  PROMPT Iif(aResult[1,10] == "A",STR0028,STR0029) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[1,10] == "A",CLR_BLUE,CLR_HRED) //"Aprovado" ### "Reprovado"
		@ 84.9,160 SAY oSay30 PROMPT Iif(aResult[2,10] == "A",STR0028,STR0029) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[2,10] == "A",CLR_BLUE,CLR_HRED) //"Aprovado" ### "Reprovado"
	Else
		For nx := 1 to 6
			aObjetos[OBJ_PONTO][nx]:SetText(aResult[1,nx])	 
			aObjetos[OBJ_PONTO][nx]:Show()
			aObjetos[OBJ_PONTO][nx]:Refresh()
		Next nx

   	nTot := 0

		For nx := 11 to 16
   			nTot++
			aObjetos[OBJ_PONTO][nx]:SetText(aResult[2,nTot])	 
			aObjetos[OBJ_PONTO][nx]:Show()
			aObjetos[OBJ_PONTO][nx]:Refresh()
	    Next
	
		If aMedicoes[nLin_aMed,nPosGer,1,6] == "1" //.and. (Inclui .or. Altera)
			aObjetos[OBJ_PONTO][7]:SetText(Iif(aResult[1,7],STR0026,STR0027))
			If aResult[1,7]
				aObjetos[OBJ_PONTO][7]:nClrText := CLR_BLUE		
			Else
				aObjetos[OBJ_PONTO][7]:nClrText := CLR_HRED
			Endif

			aObjetos[OBJ_PONTO][8]:SetText(Iif(aResult[1,8],STR0026,STR0027))
			If aResult[1,8]
				aObjetos[OBJ_PONTO][8]:nClrText := CLR_BLUE		
			Else
				aObjetos[OBJ_PONTO][8]:nClrText := CLR_HRED
			Endif

			aObjetos[OBJ_PONTO][9]:SetText(Iif(aResult[1,9],STR0026,STR0027))
			If aResult[1,9]
				aObjetos[OBJ_PONTO][9]:nClrText := CLR_BLUE		
			Else
				aObjetos[OBJ_PONTO][9]:nClrText := CLR_HRED
			Endif

			aObjetos[OBJ_PONTO][17]:SetText(Iif(aResult[2,7],STR0026,STR0027))
			If aResult[2,7]
				aObjetos[OBJ_PONTO][17]:nClrText := CLR_BLUE		
			Else
				aObjetos[OBJ_PONTO][17]:nClrText := CLR_HRED				
			Endif
		
			aObjetos[OBJ_PONTO][18]:SetText(Iif(aResult[2,8],STR0026,STR0027))
			If aResult[2,8]
				aObjetos[OBJ_PONTO][18]:nClrText := CLR_BLUE		
			Else
				aObjetos[OBJ_PONTO][18]:nClrText := CLR_HRED
			Endif

			aObjetos[OBJ_PONTO][19]:SetText(Iif(aResult[2,9],STR0026,STR0027))		 
			If aResult[2,9]
				aObjetos[OBJ_PONTO][19]:nClrText := CLR_BLUE				
			Else
				aObjetos[OBJ_PONTO][19]:nClrText := CLR_HRED				
			Endif                                           
		
			aObjetos[OBJ_PONTO][7]:Show()
			aObjetos[OBJ_PONTO][8]:Show()
			aObjetos[OBJ_PONTO][9]:Show()
			aObjetos[OBJ_PONTO][17]:Show()
			aObjetos[OBJ_PONTO][18]:Show()
			aObjetos[OBJ_PONTO][19]:Show()
		Endif
	
		aObjetos[OBJ_PONTO][10]:SetText(IIf(aResult[1,10] == "A",STR0028,STR0029))			
		If aResult[1,10] == "A"
			aObjetos[OBJ_PONTO][10]:nClrText := CLR_BLUE	
		Else
			aObjetos[OBJ_PONTO][10]:nClrText := CLR_HRED	
		Endif
	
		aObjetos[OBJ_PONTO][20]:SetText(IIf(aResult[2,10] == "A",STR0028,STR0029))			
		If aResult[2,10] == "A"
			aObjetos[OBJ_PONTO][20]:nClrText := CLR_BLUE
		Else
			aObjetos[OBJ_PONTO][20]:nClrText := CLR_HRED	
		Endif
	
		aObjetos[OBJ_PONTO][10]:Show()
		aObjetos[OBJ_PONTO][20]:Show()	
	Endif
Else
	If aMedicoes[nLin_aMed,nPosGer,1,2] == "3"   // Tipo de Calibracao Pressao
		oBtn:cCaption := STR0076 //"<< &SUBIDA"
	ElseIf aMedicoes[nLin_aMed,nPosGer,1,2] == "9"   // Tipo de Calibracao Relogio
		oBtn:cCaption := STR0097 //"&CRESCENTE >>"
	EndIf		
	
	oBtn:Refresh()
	If aObjetos[OBJ_PONTO] == NIL
		@ 05,75 SAY oSay11  PROMPT aResult[3,1] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp],StrTran(Str(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef,Len(aMedicoes[nLin_amed,nPosEsp]),nTam),".",",")),.T.) // 'M‚dia dos valores'
		@ 14,75 SAY oSay12  PROMPT aResult[3,2] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp],StrTran(Str(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef,Len(aMedicoes[nLin_amed,nPosEsp]),nTam),".",",")),.T.) // 'Desvio M‚dio'
		@ 23,75 SAY oSay13  PROMPT aResult[3,3] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp],StrTran(Str(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef,Len(aMedicoes[nLin_amed,nPosEsp]),nTam),".",",")),.T.) // 'Desvio PadrÆo'
		@ 32,75 SAY oSay14  PROMPT aResult[3,4] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp],StrTran(Str(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef,Len(aMedicoes[nLin_amed,nPosEsp]),nTam),".",",")),.T.) // 'Incerteza'
		@ 41,75 SAY oSay15  PROMPT aResult[3,5] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp],StrTran(Str(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef,Len(aMedicoes[nLin_amed,nPosEsp]),nTam),".",",")),.T.) // 'Incerteza Total'
		@ 50,75 SAY oSay16  PROMPT aResult[3,6] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp],StrTran(Str(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef,Len(aMedicoes[nLin_amed,nPosEsp]),nTam),".",",")),.T.) // 'Incerteza Total'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dados da medicao final - Valores Descida (PRESSAO ou RELOGIO) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		@ 05,160 SAY oSay21  PROMPT aResult[4,1] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp],StrTran(Str(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef,Len(aMedicoes[nLin_amed,nPosEsp]),nTam),".",",")),.T.) // 'M‚dia dos valores'
		@ 14,160 SAY oSay22  PROMPT aResult[4,2] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp],StrTran(Str(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef,Len(aMedicoes[nLin_amed,nPosEsp]),nTam),".",",")),.T.) // 'Desvio M‚dio'
		@ 23,160 SAY oSay23  PROMPT aResult[4,3] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp],StrTran(Str(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef,Len(aMedicoes[nLin_amed,nPosEsp]),nTam),".",",")),.T.) // 'Desvio PadrÆo'
		@ 32,160 SAY oSay24  PROMPT aResult[4,4] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp],StrTran(Str(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef,Len(aMedicoes[nLin_amed,nPosEsp]),nTam),".",",")),.T.) // 'Incerteza'
		@ 41,160 SAY oSay25  PROMPT aResult[4,5] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp],StrTran(Str(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef,Len(aMedicoes[nLin_amed,nPosEsp]),nTam),".",",")),.T.) // 'Incerteza Total'
		@ 50,160 SAY oSay26  PROMPT aResult[4,6] SIZE 50,7.5 OF oDlgPad RIGHT PIXEL PICTURE QMT140Pics(,IIf(lUniGual,aMedicoes[nLin_amed,nPosEsp],StrTran(Str(SuperVal(aMedicoes[nLin_amed,nPosEsp])*nCoef,Len(aMedicoes[nLin_amed,nPosEsp]),nTam),".",",")),.T.) // 'Incerteza Total'

		If aMedicoes[nLin_aMed,nPosGer,1,6] == "1" .and. (aMedicoes[nLin_aMed,nPosGer,1,2] == "3" .or. aMedicoes[nLin_aMed,nPosGer,1,2] == "9")
			@ 59,75	SAY	oSay17  PROMPT Iif(aResult[3,7],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[3,7],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
			@ 68,75	SAY	oSay18  PROMPT Iif(aResult[3,8],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[3,8],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
			@ 77,75	SAY	oSay19  PROMPT Iif(aResult[3,9],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[3,9],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
			@ 59,160	SAY	oSay27  PROMPT Iif(aResult[4,7],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[4,7],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
			@ 68,160	SAY	oSay28  PROMPT Iif(aResult[4,8],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[4,8],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
			@ 77,160	SAY	oSay29  PROMPT Iif(aResult[4,9],STR0026,STR0027) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[4,9],CLR_BLUE,CLR_HRED) //"Aceito" ### "Rejeitado"
		Endif
		@ 84.9,75	SAY	oSay20	PROMPT Iif(aResult[3,10] == "A",STR0028,STR0029) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[3,10] == "A",CLR_BLUE,CLR_HRED) //"Aprovado" ### "Reprovado"
		@ 84.9,160	SAY	oSay30	PROMPT Iif(aResult[4,10] == "A",STR0028,STR0029) SIZE 50,7.5 OF oDlgPad RIGHT PIXEL COLOR Iif(aResult[4,10] == "A",CLR_BLUE,CLR_HRED) //"Aprovado" ### "Reprovado"
	Else
		For nx := 1 to 6
			aObjetos[OBJ_PONTO][nx]:Hide()	
			aObjetos[OBJ_PONTO][nx]:SetText(aResult[3,nx])
			aObjetos[OBJ_PONTO][nx]:Show()				
		Next nx            
	
		nTot := 0
	     
		For nx := 11 to 16
			nTot++
			aObjetos[OBJ_PONTO][nx]:SetText(aResult[4,nTot]) 
			aObjetos[OBJ_PONTO][nx]:Show()
		Next nx	

		If aMedicoes[nLin_aMed,nPosGer,1,6] == "1" .and. (aMedicoes[nLin_aMed,nPosGer,1,2] == "3" .or. aMedicoes[nLin_aMed,nPosGer,1,2] == "9")
			aObjetos[OBJ_PONTO][7]:SetText(Iif(aResult[3,7],STR0026,STR0027))
			If aResult[3,7]
				aObjetos[OBJ_PONTO][7]:nClrText := CLR_BLUE		
			Else
				aObjetos[OBJ_PONTO][7]:nClrText := CLR_HRED
			Endif
		
			aObjetos[OBJ_PONTO][8]:SetText(Iif(aResult[3,8],STR0026,STR0027))
			If aResult[3,8]
				aObjetos[OBJ_PONTO][8]:nClrText := CLR_BLUE
			Else
				aObjetos[OBJ_PONTO][8]:nClrText	 := CLR_HRED	
			Endif

			aObjetos[OBJ_PONTO][9]:SetText(Iif(aResult[3,9],STR0026,STR0027))
			If aResult[3,9]
				aObjetos[OBJ_PONTO][9]:nClrText := CLR_BLUE
			Else                               
				aObjetos[OBJ_PONTO][9]:nClrText := CLR_HRED
			Endif
		
			aObjetos[OBJ_PONTO][17]:SetText(Iif(aResult[4,7],STR0026,STR0027))
			If aResult[4,7]
				aObjetos[OBJ_PONTO][17]:nClrText := CLR_BLUE
			Else                     
				aObjetos[OBJ_PONTO][17]:nClrText := CLR_HRED
			Endif
		
			aObjetos[OBJ_PONTO][18]:SetText(Iif(aResult[4,8],STR0026,STR0027))		
			If aResult[4,8]
				aObjetos[OBJ_PONTO][18]:nClrText := CLR_BLUE
			Else
				aObjetos[OBJ_PONTO][18]:nClrText := CLR_HRED
			Endif
		
			aObjetos[OBJ_PONTO][19]:SetText(Iif(aResult[4,9],STR0026,STR0027))
			If aResult[4,9]
				aObjetos[OBJ_PONTO][19]:nClrText := CLR_BLUE		
			Else
				aObjetos[OBJ_PONTO][19]:nClrText := CLR_HRED		
			Endif
		Endif             
	
		aObjetos[OBJ_PONTO][10]:SetText(Iif(aResult[3,10] == "A",STR0028,STR0029))
		If aResult[3,10] == "A"
			aObjetos[OBJ_PONTO][10]:nClrText := CLR_BLUE	
		Else
			aObjetos[OBJ_PONTO][10]:nClrText := CLR_HRED	
		Endif
	
		aObjetos[OBJ_PONTO][20]:SetText(Iif(aResult[4,10] == "A",STR0028,STR0029))		
		If aResult[4,10] == "A"
			aObjetos[OBJ_PONTO][20]:nClrText := CLR_BLUE	
		Else
			aObjetos[OBJ_PONTO][20]:nClrText := CLR_HRED	
		Endif
	Endif	
EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A141WhDiv³ Autor ³ Wanderley Goncalves   ³ Data ³ 9/1/1998 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Indica se divisor pode ou nao ser alterado				  ³±±
±±³			 ³ (Pode ser alterado somente se Distribuicao for igual a U   ³±±
±±³Descri‡„o ³ ou outro a ser acrescentado pelo usuario) 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Logico													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_When QMV_DIV											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A141WhDiv()
Local lRet := .t.

If aCols[oGetITB:oBrowse:nAt,5] $ "N|M|R|T"
	lRet := .f.                    
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A141VlCi	³ Autor ³ Fernando Godoy		³ Data ³ 9/10/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida se Incerteza ja foi informada na Getdados atual 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³No														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpL1 - V ou F											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QMX->QMX_CODINC (Validacao) 								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A141VlCi( )
Local lRet	:= .T.
Local nLoop := 0

For nLoop := 1 To Len(aCols)
	If Alltrim(Upper(M->QMX_CODINC)) == Alltrim(Upper(aCols[nLoop,1])) .And.;
		nLoop <> n
		MessageDlg(STR0077) //"Esta Incerteza ja foi informada nesta medicao, Informe outra."
		lRet := .F.
		Exit
	EndIf
Next nLoop

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A141WhRes ³ Autor ³ Fernando Godoy		³ Data ³ 9/10/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula o valor da incerteza padronizada					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³DrawSelect Getdados Incerteza tipo B 						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A141WhRes(oFldFix,nPosAmed)
Local nValor	:= 0
Local nDivisor := 1
Local cVlrInc	:= oGetITB:aCols[oGetITB:oBrowse:nAt,4]	// Valor da Incerteza
Local cDivisor  := oGetITB:aCols[oGetITB:oBrowse:nAt,6]	// Divisor                   
Local cCoefSen  := oGetITB:aCols[oGetITB:oBrowse:nAt,7]	// Coef. Sensib. 
Local cTotal	:= "" 
Local cTotal2	:= "" 
Local nTotal	:= 0
Local nVeff 	:= 0
Local cVeff 	:= ""
Local nValMin	:= 0
Local nValMax	:= 0
Local nMedMin	:= 0
Local nMedMax	:= 0
Local nKp		:= 0
Local cKp		:= ""
Local nIEC		:= 0	 // Incerteza expandida calculada
Local cIEC		:= ""
Local lPtItb	:= .F.
Local cSumItb	:= GetNewPar("MV_QSUMITB","2")
Local cCalIncer := GetNewPar("MV_QMCALIN","1")
Local nLoop		:= 1

DEFAULT nPosAmed := 0

nPosAmed := Ascan(aMedicoes, { |x| Alltrim(x[1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt]) .and. Alltrim(x[2]) == Alltrim(oCbxPad:aItems[oCbxPad:nAt])})

aMedicoes[nPosAmed,nPosGer,1,17,1] := ""
aMedicoes[nPosAmed,nPosGer,1,17,2] := ""

nUsado := Len(oGetItb:aCols[1])

If Empty(cVlrInc) 
	cVlrInc := M->QMX_VALINC
EndIf

If !Empty(cVlrInc) .And. !Empty(cDivisor) .And. !Empty(cCoefSen)

	SET DECIMALS TO 8

	If !oGetITB:aCols[oGetITB:oBrowse:nAt,nUsado] // Nao deletado
		If Upper(Left(cDivisor,1)) == "R"
			If Upper(Alltrim(cDivisor)) == "RN" //Tratamento para Normal R3
				nDivisor := Sqrt(3)
			Else				
				nDivisor := Sqrt(SuperVal(Substr(cDivisor,2,Len(cDivisor))))
			Endif	                                                                                      		
		Else
			nDivisor := SuperVal(cDivisor)
		EndIf

		nValor := (SuperVal(cVlrInc) * SuperVal(cCoefSen)) / nDivisor
		If cCalIncer == "1"
			oGetITB:aCols[oGetITB:oBrowse:nAt,8] := AlgSignif(nValor,5,.T.)
		Else
			oGetITB:aCols[oGetITB:oBrowse:nAt,8] := AlgSignif(nValor,5,.F.)
		EndIF
	Else
		oGetITB:aCols[oGetITB:oBrowse:nAt,8] := CriaVar("QMX_UI")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o valor da incerteza padronizada combinada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nLoop := 1 To Len(oGetITB:aCols)
		If oGetITB:aCols[nLoop,nUsado]	// Deletado
			Loop
		EndIf
		If ValType(oGetITB:aCols[nLoop,8]) == "C"
			oGetITB:aCols[nLoop,8] := StrTran(oGetITB:aCols[nLoop,8],".",",",1,Len(oGetITB:aCols[nLoop,8]))
			nTotal += SuperVal(oGetITB:aCols[nLoop,8])**2	
		Else
			nTotal += Val(oGetITB:aCols[nLoop,8])**2
		Endif
	Next nLoop

	nTotal	:= Sqrt(nTotal)
	cTotal	:= AllTrim(AlgSignif(nTotal,5))
	aObjetos[OBJ_INCERT_B][12]:SetText("Ui = "+ cTotal)  
	aObjetos[OBJ_INCERT_B][12]:Show()	
	aMedicoes[nPosAmed,nPosGer,1,17,1] := cTotal
	cTotal2 := cTotal   
	
	If Valtype(aMedicoes[nPosAmed,nPosGer,1,16]) == "C"
		aMedicoes[nPosAmed,nPosGer,1,16] := Val(aMedicoes[nPosAmed,nPosGer,1,16])
	Endif	
 
// 	If aMedicoes[nPosAmed,nPosGer,1,16] > nTotal / 2

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o valor da incerteza expandida ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTotal := AllTrim(AlgSignif(nTotal*2))
		aObjetos[OBJ_INCERT_B][16]:SetText("Ui = "+ cTotal) //17
		aObjetos[OBJ_INCERT_B][16]:Show()                   //17

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o valor de Veff ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		For nLoop := 1 To Len(oGetITB:aCols)
			If oGetITB:aCols[nLoop,nUsado]	// Deletado
				Loop
			EndIf
			If "M->QMX_VI" $ ReadVar() .And. nLoop == oGetITB:oBrowse:NROWPOS
				cQmxVi := M->QMX_VI
			Else
				cQmxVi := oGetITB:aCols[nLoop,9]
			EndIf
			If !empty(cQmxVi)
				nVeff+= (SuperVal(oGetITB:aCols[nLoop,8])**4)*((10)**10)/Val(cQmxVi)*((10)**10)
			EndIf
		Next
		nVeff := (nTotal**4)*((10)**10)/nVeff*((10)**10)

		cVeff := AllTrim(AlgSignif(nVeff))
		aObjetos[OBJ_INCERT_B][21]:SetText("Veff = "+cVeff)
		aObjetos[OBJ_INCERT_B][21]:Show()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o valor de Kp	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		nValMin := RetStud(nVeff,aMedicoes[nPosAmed,nPosGer,1,14],.T.)
		nValMax := RetStud(nVeff,aMedicoes[nPosAmed,nPosGer,1,14],.F.)
		nMedMin := Int(nVeff)
		nMedMax := Int(nVeff)+1

		nKp := (((nVeff-nMedMin)*(nValMax-nValMin))/(nMedMax-nMedMin))+nValMin

		cKp := AllTrim(AlgSignif(nKp))                             
		aObjetos[OBJ_INCERT_B][19]:SetText("Nor kp = "+cKp)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o valor da Incerteza Expandida Calculada   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nIEC := nTotal * nKp

		cIEC := AllTrim(AlgSignif(nIEC))
		
		If nKp <= 0
			cIEC := ""		
		Endif
		
		aObjetos[OBJ_INCERT_B][20]:SetText("Ui = "+cIEC)
		aMedicoes[nPosAmed,nPosGer,1,17,2] := cIEC //Associa Incerteza Expandida
    //Else
		aObjetos[OBJ_INCERT_B][12]:SetText("Ui =        ")		
		aObjetos[OBJ_INCERT_B][16]:SetText("Ui =        ")     //17
		aObjetos[OBJ_INCERT_B][19]:SetText("Nor kp =    ")
		aObjetos[OBJ_INCERT_B][20]:SetText("Ui =        ")		
		aObjetos[OBJ_INCERT_B][21]:SetText("Veff =      ")

		aObjetos[OBJ_INCERT_B][12]:SetText("Ui = "+cTotal2)		
		aObjetos[OBJ_INCERT_B][12]:Show()
		cTotal := AllTrim(AlgSignif(nTotal*2))
		aObjetos[OBJ_INCERT_B][16]:SetText("Ui = "+cTotal)     //17
		aObjetos[OBJ_INCERT_B][16]:Show()
		aObjetos[OBJ_INCERT_B][19]:SetText("Nor kp = "+cKp)
		aObjetos[OBJ_INCERT_B][19]:Show()
		aObjetos[OBJ_INCERT_B][20]:SetText("Ui = "+cIEC)		
		aObjetos[OBJ_INCERT_B][20]:Show()
		aObjetos[OBJ_INCERT_B][21]:SetText("Veff = "+cVeff)
		aObjetos[OBJ_INCERT_B][21]:Show()
//	EndIf

	SET DECIMALS TO 2

Else
	oGetItb:aCols[oGetITB:oBrowse:nAt,8] := CriaVar("QMX_UI")
	aObjetos[OBJ_INCERT_B][12]:SetText("Ui =        ")		
	aObjetos[OBJ_INCERT_B][16]:SetText("Ui =        ")      
	aObjetos[OBJ_INCERT_B][19]:SetText("Nor kp =    ")
	aObjetos[OBJ_INCERT_B][20]:SetText("Ui =        ")		
	aObjetos[OBJ_INCERT_B][21]:SetText("Veff =      ")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o conteudo do parametro MV_QSUMITB - soma incerteza tipo A ³
//³incerteza tipo B													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cSumItb == "1"
	For nLoop := 1 To Len(oGetITB:aCols)
		If oGetITB:aCols[oGetITB:oBrowse:nAt,nUsado] // Deletado
			lPtItb := .F.
		Else
			lPtItb := .T.
			Exit			
		EndIf
	Next nLoop

	If !lPtItb
		aMedicoes[nPosAmed,nPosGer,1,17,1] := ""
		aMedicoes[nPosAmed,nPosGer,1,17,2] := ""
	Endif
EndIf

oFolderFix:aDialogs[7]:Refresh()
oGetITB:oBrowse:Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³AlgSignif ³ Autor ³ Fernando Godoy		³ Data ³ 9/10/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna numero com 3 casas decimais significativas		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nValor -> Valor a ser convertido							  ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³cValor -> Valor convertido								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QMTA141													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AlgSignif( nValor, nVCount ,lVer)

Local nLoop 	:= 0
Local nVal		:= 0
Local cValor	:= ""
Local nVezes	:= 0
Default nValor  := 0
Default nVCount := 3
Default lVer    := .F.
cValor := Str(nValor)

For nLoop := 1 To Len(cValor)
	If Substr(cValor,nLoop,1) == "."
		For nVal := nLoop To Len(cValor)
		    If lVer = .T.
				If Val(SubsTr(cValor,nVal,1)) >= 0 .And. nVezes < nVCount  
					nVezes ++
						If nVezes == nVCount
							Exit
						EndIf
				Else
					If nVezes >= 1
						nVal--
						Exit
				    EndIf
				Endif
			Else
				If Val(SubsTr(cValor,nVal,1)) > 0 .And. nVezes < nVCount  
					nVezes ++
					If nVezes == nVCount
						Exit
					EndIf
				Else
					If nVezes >= 1
						nVal--
						Exit
					EndIf
				EndIf
			EndIf
		Next nVal
	EndIf
Next nLoop

If nVal <> 0
	cValor := Substr(cValor,1,nVal)
Endif

Return(cValor)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³RetStud	³ Autor ³ Fernando Godoy		³ Data ³ 9/11/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna Valor procurado na Tabela de Student				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 -> Numero de Medicoes								  ³±±
±±³			 ³ ExpN2 -> Nivel de Confianca								  ³±±
±±³			 ³ ExpL1 -> Logico: .T. para anterior (ou o atual) 			  ³±±
±±³			 ³ 					  .F. para posterior 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpN2 -> Valor encontrado na tabela 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetStud(nMed,nNConf,lPos)
Local aStudent := {}
Local nValor := 0
Local nPos := If(nNConf=="95",1,2)
Default lPos := .T.

nMed := Int(nMed)

If nMed > 0
	aadd( aStudent, {12.706, 63.657 } )
	aadd( aStudent, { 4.303,  9.925 } )
	aadd( aStudent, { 3.182,  5.841 } )
	aadd( aStudent, { 2.776,  4.604 } )
	aadd( aStudent, { 2.571,  4.032 } )
	aadd( aStudent, { 2.447,  3.707 } )
	aadd( aStudent, { 2.365,  3.499 } )
	aadd( aStudent, { 2.306,  3.355 } )
	aadd( aStudent, { 2.262,  3.250 } )
	aadd( aStudent, { 2.228,  3.169 } )
	aadd( aStudent, { 2.201,  3.106 } )
	aadd( aStudent, { 2.179,  3.055 } )
	aadd( aStudent, { 2.160,  3.012 } )
	aadd( aStudent, { 2.145,  2.977 } )
	aadd( aStudent, { 2.131,  2.947 } )
	aadd( aStudent, { 2.120,  2.921 } )
	aadd( aStudent, { 2.110,  2.898 } )
	aadd( aStudent, { 2.101,  2.878 } )
	aadd( aStudent, { 2.093,  2.861 } )
	aadd( aStudent, { 2.086,  2.845 } )
	aadd( aStudent, { 2.080,  2.831 } )
	aadd( aStudent, { 2.074,  2.819 } )
	aadd( aStudent, { 2.069,  2.807 } )
	aadd( aStudent, { 2.064,  2.797 } )
	aadd( aStudent, { 2.060,  2.787 } )
	aadd( aStudent, { 2.056,  2.779 } )
	aadd( aStudent, { 2.052,  2.771 } )
	aadd( aStudent, { 2.048,  2.763 } )
	aadd( aStudent, { 2.045,  2.756 } )
	aadd( aStudent, { 2.042,  2.750 } )
	aadd( aStudent, { 2.021,  2.704 } )
	aadd( aStudent, { 2.000,  2.550 } )
	aadd( aStudent, { 1.980,  2.617 } )
	aadd( aStudent, { 1.950,  2.576 } )

	If nMed <= 30
		nValor := aStudent[nMed,nPos]
	Elseif nMed < 40
		If lPos
			nValor := aStudent[30,nPos] // Linha para medicoes == 30
		Else
			nValor := aStudent[31,nPos] // Linha para medicoes == 40
		EndIf
	Elseif nMed < 60
		If lPos
			nValor := aStudent[31,nPos] // Linha para medicoes == 40
		Else
			nValor := aStudent[32,nPos] // Linha para medicoes == 60
		EndIf
	Elseif nMed < 120
		If lPos
			nValor := aStudent[32,nPos] // Linha para medicoes == 60
		Else
			nValor := aStudent[33,nPos] // Linha para medicoes == 120
		EndIf
	Else // Medicoes acima de 120
		If lPos
			nValor := aStudent[33,nPos] // Linha para medicoes == 120
		Else
			nValor := aStudent[34,nPos] // Linha para medicoes == Infinito
		EndIf
	EndIf
Else
	nValor := 0
EndIf

Return(nValor)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ A140Exc	³ Autor ³ Fernando Godoy		³ Data ³ 09/14/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa de atualizacao de Resultados - Delecao da medicao ³±±
±±³			 ³ que est  posicionada.									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A210Exc(ExpC1,ExpN1,ExpN2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo									  ³±±
±±³			 ³ ExpN1 = Numero do registro 								  ³±±
±±³			 ³ ExpN2 = Opcao selecionada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QMTA140													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140Exc(cAlias,nReg,nOpc)

Local oDlgExc
Local oMens
Local oFnt
Local nOpcA 	:= 0
Local cChave	:= ""
Local nLoop 	:= 0
Local cEspec	:= ""
Local cMtInstr	:= ""
Local cMtRevIns	:= ""
Local dMtData	:= Ctod("  /  /  ","DDMMYY")
Local aDelQA2	:= {}
Local nx		:= 1
Local lRet		:= .T.
Local cQPathQMT := GETMV("MV_QMTPATH",.T.,"\SYSTEM\DOCS\")

If !Right( cQPathQMT,1 ) == "\"
	cQPathQMT := cQPathQMT + "\"
Endif

Private cSeql	:= QM6->QM6_CSEQ

DEFINE FONT oFnt Name "Arial" BOLD

DEFINE MSDIALOG oDlgExc FROM	84,71 TO 231,509 TITLE OemToAnsi(STR0078) PIXEL //"Exclusão de Resultados"

	@  1, 3 TO 33, 184 OF oDlgExc  PIXEL
	@ 35, 3 TO 68, 218 OF oDlgExc  PIXEL

	DEFINE SBUTTON FROM 03,189 TYPE 1 ENABLE OF oDlgExc ACTION ( nOpcA := 1,oDlgExc:End() )
	DEFINE SBUTTON FROM 16,189 TYPE 2 ENABLE OF oDlgExc ACTION ( nOpcA := 2,oDlgExc:End() )

	@ 05, 006 SAY STR0079 SIZE 50, 7 OF oDlgExc PIXEL //"Instrumento:"
	@ 05, 135 SAY STR0138 SIZE 50, 7 OF oDlgExc PIXEL //"Sequencia.:"
	@ 15, 006 SAY STR0081 SIZE 50, 7 OF oDlgExc PIXEL //"Data:"
	@ 15, 70 SAY STR0082 SIZE 50, 7 OF oDlgExc PIXEL //"Responsável:"
	@ 25, 006 SAY STR0083 SIZE 50, 7 OF oDlgExc PIXEL //"Hora Entrada:"
	@ 25, 70 SAY STR0084 SIZE 50, 7 OF oDlgExc PIXEL //"Repe/Repro:"

	@ 05, 040 SAY Alltrim(QM6->QM6_INSTR)+" - "+QM6->QM6_REVINS	OF oDlgExc SIZE 80,7 PIXEL COLOR CLR_BLUE
	@ 05, 170 SAY Alltrim(QM6->QM6_CSEQ)  	OF oDlgExc SIZE 20,7 PIXEL COLOR CLR_BLUE
	@ 15, 030 SAY QM6->QM6_DATA		OF oDlgExc SIZE 30,7 PIXEL COLOR CLR_BLUE
	@ 15, 105 SAY QM6->QM6_RESP		OF oDlgExc SIZE 30,7 PIXEL COLOR CLR_BLUE
	@ 25, 040 SAY QM6->QM6_TOTHOR 	OF oDlgExc SIZE 30,7 PIXEL COLOR CLR_BLUE
	@ 25, 105 SAY QM6->QM6_REPEPR 	OF oDlgExc SIZE 30,7 PIXEL COLOR CLR_BLUE

	@ 39, 015 SAY oMens PROMPT STR0085 SIZE 190, 30 OF oDlgExc PIXEL COLOR CLR_BLUE //"Esta rotina permite a Exclusão de todos os resultados desta Medição. Utilize a opção de Reprogramação de Calibração no Menu Miscelânea, para reprogramar uma data de Calibração."
	
ACTIVATE MSDIALOG oDlgExc CENTERED

Release objects oFnt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso confirmar, exclui. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcA == 1

	dbSelectArea("QM6")
	cMtInstr := QM6->QM6_INSTR
	cMtRevIns:= QM6->QM6_REVINS
	dMtData	:= QM6->QM6_DATA
	
	lRet := Qmt140DelCa(.F.,QM6->QM6_INSTR,QM6->QM6_DATA,nOpc)
	
	If lRet

	Begin Transaction

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a Delecao da justificativa de cada linha - QA3 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QA3")
		dbSetOrder(1)
		cChave := QM6->QM6_CHAVE

		For nLoop := 1 To 3
			cEspec := Iif(nLoop == 1,"QMTA140L",Iif(nLoop == 2,"QMTA140M","QMTA140S"))
			If dbSeek(xFilial("QA3")+cEspec+cChave)
			   While !Eof() .and. QA3->QA3_ESPEC+QA3->QA3_CHAVE == cEspec+cChave
					RecLock("QA3",.F.)
					dbDelete()
					MsUnLock()
				dbSkip()
				Enddo	
			EndIf
		Next nLoop

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui os dados do QM8 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QM8")
		dbSetOrder(1)
		If dbSeek(xFilial("QM8")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeql)
			While !Eof() .And. xFilial("QM8")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeql ==;
				QM8->QM8_FILIAL+QM8->QM8_INSTR+QM8->QM8_REVINS+Dtos(QM8->QM8_DATA)+QM8->QM8_CSEQ
				RecLock("QM8",.F.)
				dbDelete()
				MsUnLock()
				dbSkip()
			EndDo
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exlui os Instrumentos Utilizados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QMI")
		dbSetOrder(1)
		If dbSeek(xFilial("QMI")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeql)
			While !Eof() .And. xFilial("QMI")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeql == ;
				QMI->QMI_FILIAL+QMI->QMI_INSTR+QMI->QMI_REVINS+Dtos(QMI->QMI_DATA)+QMI->QMI_CSEQ
				RecLock("QMI",.F.)
				dbDelete()
				MsUnLock()
				dbSkip()
			EndDo
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui as Incertezas do Tipo B ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QMX")
		dbSetOrder(1)
		If dbSeek(xFilial("QMX")+cMtInstr+cMtRevIns+DtoS(dMtData))
			While !Eof() .And. xFilial("QMX")+cMtInstr+cMtRevIns+DtoS(dMtData) ==;
				QMX->QMX_FILIAL+QMX->QMX_INSTR+QMX->QMX_REVINS+Dtos(QMX->QMX_DATA)
				If Alltrim(QMX->QMX_CSEQ) == Alltrim(cSeql)
					RecLock("QMX",.F.)
					dbDelete()
					MsUnLock()
				Endif	
				dbSkip()
			EndDo
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui as Nao Conformidades³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QMJ")
		dbSetOrder(1)
		If dbSeek(xFilial("QMJ")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeql)
			While !Eof() .And. xFilial("QMJ")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeql ==;
				QMJ->QMJ_FILIAL+QMJ->QMJ_INSTR+QMJ->QMJ_REVINS+Dtos(QMJ->QMJ_DATA)+QMJ->QMJ_CSEQ 
				cCodNC 		:= QMJ->QMJ_CODNC
				cCodRevNC	:= QMJ->QMJ_REVNC
				If !Empty(QMJ->QMJ_CODNC) 
					aCpoQNC := {}
					aCpoQNC := {xFilial("QI2"),cCodNC,cCodRevNC}				
					QncGera(2,aCpoQNC)					
				Endif
				RecLock("QMJ",.F.)
				dbDelete()
				MsUnLock()
				dbSkip()
			EndDo
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui dos Padroes Secundarios ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QMS")
		dbSetOrder(1)
		If dbSeek(xFilial("QMS")+cMtInstr+cMtRevIns+DtoS(dMtData))
			While !Eof() .And. xFilial("QMS")+cMtInstr+cMtRevIns+DtoS(dMtData)==;
				QMS->QMS_FILIAL+QMS->QMS_INSTR+QMS->QMS_REVINS+Dtos(QMS->QMS_DATA)
				If Alltrim(QMS->QMS_CSEQ) == Alltrim(cSeql)
					RecLock("QMS",.F.)
					dbDelete()
					MsUnLock()
				Endif
				dbSkip()
			EndDo
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exlui os Padroes do Tipo Soma ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QMT")
		dbSetOrder(1)
		If dbSeek(xFilial("QMT")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeql)
			While !Eof() .And. xFilial("QMT")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeql ==;
				QMT->QMT_FILIAL+QMT->QMT_INSTR+QMT->QMT_REVINS+Dtos(QMT->QMT_DATA)+QMT->QMT_CSEQ
				RecLock("QMT",.F.)
				dbDelete()
				MsUnLock()
				dbSkip()
			EndDo
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acerta Frequencia e Validade de Schumacker 	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		dbSelectArea("QM2")
		dbSetOrder(1)
		If dbSeek(xFilial("QM2") + cMtInstr + Inverte(cMtRevIns) )
			RecLock("QM2",.F.)
			If !Empty(QM2->QM2_FREQAN)
				QM2->QM2_FREQAF := QM2->QM2_FREQAN  
			Endif
			If !Empty(QM2->QM2_VALDAN)	
				QM2->QM2_VALDAF := QM2->QM2_VALDAN 
			Endif	
			MsUnLock()
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui os dados do QM7 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QM7")
		dbSetOrder(1)
		If dbSeek(xFilial("QM7")+cMtInstr+cMtRevIns+DtoS(dMtData)+cSeql)
			While QM7->QM7_FILIAL + QM7->QM7_INSTR + QM7->QM7_REVINS +;
				dtoS(QM7->QM7_DATA)+QM7->QM7_CSEQ == xFilial("QM7")+cMtInstr+cMtRevIns+;
				dtoS(dMtData)+cSeql .And. QM7->(!Eof())

				Aadd(aDelQA2,{QM7->QM7_CHAVE})

				dbSelectArea("QM7")
				RecLock("QM7",.F.)
				dbDelete()
				MsUnLock()
				dbSkip()
			EndDo
		EndIf

        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui no QN7 os documentos
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QN7")
		dbSetOrder(1)
		If dbSeek(xFilial("QN7") + cMtInstr + cMtRevIns + Dtos(dMtData) + cSeql)
			While QN7->QN7_FILIAL+QN7->QN7_INSTR+QN7->QN7_REV+DTOS(QN7_DATA)+QN7->QN7_SEQINS == xFilial("QN7")+cMtInstr+cMtRevIns+Dtos(dMtData)+cSeql .And. QN7->(!Eof())
				// Deleto o arquivo 
				If File(cQPathQMT+AllTrim(QN7->QN7_ANEXO))
					FErase(cQPathQMT+AllTrim(QN7->QN7_ANEXO))	
				Endif
				// Deleto o registro
				RecLock("QN7",.F.)
				dbDelete()
				MsUnLock()
				dbSkip()
			EndDo
		EndIf



		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui no QM6 os dados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QM6")
		dbSetOrder(1)
		dbSeek(xFilial("QM6") + cMtInstr + cMtRevIns + Dtos(dMtData) + cSeql)
		RecLock("QM6",.F.)
		dbDelete()
		MsUnLock()

		For nx := 1 To Len(aDelQA2)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Efetua a Delecao da justificativa de cada linha - QA3 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QA2")
			dbSetOrder(1)
			cEspec := "QMTA140O"
			If dbSeek(xFilial("QA2")+cEspec+aDelQA2[nx][1])
				Do while xFilial("QA2")+cEspec+aDelQA2[nx][1] ==;
							QA2->QA2_FILIAL+QA2->QA2_ESPEC+QA2->QA2_CHAVE
					RecLock("QA2",.F.)
					dbDelete()
					MsUnLock()
					QA2->(DbSkip())
				Enddo
			EndIf
		Next nx

	End Transaction

	Endif
	
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A140ChgTel³ Autor ³ Fernando Godoy		³ Data ³ 9/17/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra a tela correspondente.								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Array com os Handles dos Objetos.					  ³±±
±±³			 ³ExpN1 - 1 - Botao Volta pressionado / 2 - Botao Avanca Press³±±
±±³			 ³ExpN2 - Numero da tela que esta ativa						  ³±±
±±³			 ³ExpO1 - Handle do Botao Voltar 							  ³±±
±±³			 ³ExpO2 - Handle do Botao Avancar							  ³±±
±±³			 ³ExpO3 - Handle da Dialog Mae								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpL1 - .T. Indica que Confirmou tudo / .F. indica que 	  ³±±
±±³			 ³cancelou e vai voltar para as medicoes					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140GrvAll() - Botao Avanca e Volta						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140ChgTel(aHandle,nBotao,nPosAtu,oBtn1,oBtn2,oDlgFim,nNumPag,;
	cStatAtu,nRad2Atu,aResFim,cTextFr, cFreq,dDataVal,cTextCal,aStatus,lPosAtuFim)

Local lRet		:= .F.
Local aInUse	:= {}
Local nLoop 	:= 0
Local nFirst	:= 0

Default lPosAtuFim := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as telas que estao ativas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aInUse := A140TelAtv( nNumPag,aHandle,nRad2Atu,cStatAtu )
For nLoop := 1 To Len(aInUse)
	If aInUse[nLoop]
		nFirst := nLoop
		Exit
	EndIf
Next nLoop

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aumenta ou diminui a pagina ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nBotao == 1 	 // Botao Voltar
	oBtn2:Enable()
	oBtn2:Refresh()
	For nLoop := nPosAtu - 1 To 1 Step -1
		If !aInUse[nLoop]
			nPosAtu--
		Else
			Exit
		EndIf
	Next nLoop                
	nPosAtu--
	If nPosAtu < 1
		lRet	:= .F.
		nPosAtu := 1
//		oDlgFim:End() 
	EndIf
Elseif nBotao == 2 // Botao Avancar
	If ( nPosAtu == 1 .AND. !A140VerMed() .AND. QMT141MV(cMemo1) ) .OR.;
	   ( nPosAtu == 5 .AND. nRad2Atu <> aHandle[6]:nOption .AND.;
	     QMT141MV(cMemo2) ) .OR.;
	   ( nPosAtu == 7 .AND. Alltrim(cStatAtu) <> Alltrim(aHandle[8]:GetSelText()) .AND.;
	     QMT141MV(cMemo3) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ - Na pagina de Justificativa para a nao digitacao de todas as medicoes, ³
		//³ se o usuario nao digitou as medicoes e a justificativa, nao deixa       ³
		//³ avancar; OU                                                             ³
		//³ - Na pagina de Justificativa para mudanca no laudo, se o usuario mudou  ³ 
		//³ o Laudo e nao digitou a justificativa, nao deixa avancar.               ³
		//³ - Na pagina de Justificativa para mudanca de status, se o usuario mudou  ³ 
		//³ o Status e nao digitou a justificativa, nao deixa avancar.               ³
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		msgstop(STR0094,STR0008)	//"Justificativa não encontrada.","Atenção"
	Else
		For nLoop := nPosAtu + 1 To Len(aInUse)
			If aInUse[nLoop]
				Exit
			EndIf
			nPosAtu++
		Next nLoop
		nPosAtu++
		If nPosAtu > nNumPag
			nPosAtu := nNumPag
			lRet := .T.
//			oDlgFim:End()
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Acao a ser tomada... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case nPosAtu == 1 // Justificativa pela nao dig. de medicoes
		aHandle[32]:Show()
		ShowHide(aHandle,{"12#13#23#26"})
	Case nPosAtu == 2 // Condicao de recebimento
		aHandle[32]:Show()
		ShowHide(aHandle,{"01#02#26"})
	Case nPosAtu == 3 //Frequencia e Validade
		If Alltrim(cFreqSch) == "S"
			aHandle[32]:Show()
			aStatus := A140MudaFr( aHandle[2]:nOption )
			If Empty(aStatus[1])
			   If !ExistBlock("QMT140FrAf")                                                 
				   dDataVal	:= aStatus[7]   
				   cFreq := Str(aStatus[8])
			   Endif					   
			   aHandle[4]:SetText(aStatus[4])
			   ShowHide(aHandle,{"03#04#25#27#28"})
			Else
				If aStatus[2] == "P"
					cTextCal := aStatus[1] 
					aHandle[4]:SetText(aStatus[3])
					If aHandle[19]:nOption == 1
						If Alltrim(aStatus[9]) == "D" .or. Alltrim(aStatus[9]) == "M"
						   If !ExistBlock("QMT140FrAf")                                                 
								dDataVal := aStatus[5]
								cFreq := Str(aStatus[6])
						   Endif		
						Endif
					Else
						If !ExistBlock("QMT140FrAf")                                                 
							cFreq := Str(aStatus[8])					
						Endif	
						If lEscSchu
					        aHandle[4]:SetText(aStatus[4])
						Endif						
					Endif
					ShowHide(aHandle,{"03#04#18#24#19#25#27#28"})
				Elseif aStatus[2] == "A"
					cTextCal := aStatus[1]
					aHandle[4]:SetText(aStatus[3])
					If !ExistBlock("QMT140FrAf")                                                 
						cFreq := Str(aStatus[8])					
					Endif	
					ShowHide(aHandle,{"03#04#24#25#27#28"})
				EndIf
			EndIf
		Else
			If !ExistBlock("QMT140FrAf")
				aHandle[4]:SetText(aStatus[3])
			Else
				aHandle[4]:SetText(OemToAnsi(STR0005)+cFreq+OemToAnsi(STR0004)+" "+OemToAnsi(STR0006)+DtoC(dDataVal))
			Endif	
			ShowHide(aHandle,{"03#04#25#27#28"})
		EndIf

	Case nPosAtu == 4 // Laudo
		aHandle[32]:Show()
		ShowHide(aHandle,{"05#06#26#30"})

	Case nPosAtu == 5 //Pagina de Justificativa para mudanca no laudo
		aHandle[32]:Show()
		ShowHide(aHandle,{"14#15#23#26"})
		If nRad2Atu == aHandle[6]:nOption
			aHandle[15]:cText := CriaVar("QA3_TEXTO")
			aHandle[15]:Refresh()
		EndIf

	Case nPosAtu == 6 // Status do instrumento
		aHandle[32]:Show()
		ShowHide(aHandle,{"07#08#26"})                                    
		
	Case nPosAtu == 7 // Justificativa pela mudanca de status
		aHandle[32]:Show()
		ShowHide(aHandle,{"16#17#23#26"})
		If Alltrim(cStatAtu) == Alltrim(aHandle[8]:GetSelText())
			aHandle[17]:cText := CriaVar("QA3_TEXTO")
			aHandle[17]:Refresh()
		EndIf

	Case nPosAtu == 8 // Resultado final
		aHandle[32]:Show()
		aHandle[20]:SetText(OemToAnsi(STR0110)+ RetString(aHandle[2]:aItems[aHandle[2]:nOption]))
		aHandle[20]:Refresh()
		aHandle[21]:SetText(cTextFr)
		aHandle[21]:Refresh()
		aHandle[22]:SetText(OemToAnsi(STR0111)+Alltrim(SubStr(RetString(aHandle[8]:GetSelText()),1,19)))
		aHandle[22]:Refresh()
		aHandle[10]:SetText(RetString(aHandle[6]:aItems[aHandle[6]:nOption]))
		aHandle[10]:nClrText := Iif(aHandle[6]:nOption == 1,CLR_HRED,Iif(aHandle[6]:nOption == 2,CLR_YELLOW,CLR_GREEN))
		aHandle[10]:Refresh()
		aHandle[11]:SetBmp( Iif(aHandle[6]:nOption == 1,"QMT_NO",Iif(aHandle[6]:nOption == 2,"QMT_COND","QMT_OK")) )
		aHandle[11]:Refresh()

		If Alltrim(cFreqSch) == "S"
			If aStatus[2] == "P"
				If aHandle[19]:nOption == 1
					aHandle[21]:SetText(aStatus[3])
				Else
					aHandle[21]:SetText(aStatus[4])									
				Endif	
			ElseIf aStatus[2] == "A"
				aHandle[21]:SetText(aStatus[4])									
			Endif
			ShowHide(aHandle,{"09#10#11#20#21#22#26#29#31"})
		Else
			ShowHide(aHandle,{"09#10#11#21#22#26#29#31"})
		EndIf
	EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com Informacoes para futura gravacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aResFim := {}
Aadd( aResFim, Iif(aHandle[6]:nOption == 1,"R",IIf(aHandle[6]:nOption == 2,"C","A")) )
Aadd( aResFim, Ctod(Right(cTextFr,8),"DDMMYY"))
Aadd( aResFim, Iif(aHandle[2]:nOption == 1, "A",Iif(aHandle[2]:nOption == 2,"C","N")) )
Aadd( aResFim, Left(aHandle[8]:GetSelText(),1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica qual e o Caption dos Botoes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPosAtu == nNumPag
	oBtn2:cCaption := STR0086 //"&Concluir"
Else
	oBtn2:cCaption := STR0055 //"&Avançar >>"
EndIf
If nPosAtu == nFirst
	oBtn1:cCaption := STR0054 //"&Cancelar"
Else
	oBtn1:cCaption := STR0087 //"<< &Voltar"
EndIf

If lPosAtuFim 
  	If nBotao == 2 //Avancar
	  	lRet := .T.
	  	lPosAtuFim := .F.
	  	oDlgFim:End()	
	Endif 	
Else
	If nPosAtu >= 8     
	   lRet := .t.
	   lPosAtuFim := .T.
	   If !Inclui .and. !Altera	 //No caso de visualizacao de tela de calibracoes
		   oDlgFim:End()
	   Endif		   
	Endif
Endif

If nPosAtu < 1
	lRet	:= .t.
	nPosAtu := 1
	oDlgFim:End() 
EndIf

If nBotao == 1
	lPosAtuFim = .F.	
	If oDlgFim <> Nil
		If nPosAtu <= 1
			lRet	:= .f.
			nPosAtu := 1
			oDlgFim:End()
		Endif 	
	Endif
Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³RetDesPa  ³ Autor ³ Wanderley Goncalves   ³ Data ³12/05/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna desvio padrao       								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 -                                   				  ³±±
±±³			 ³ExpN1 -                                                     ³±±
±±³			 ³ExpC1 -                                                     ³±±
±±³			 ³Expn2 -                              						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpL1 -                                                	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140ShwPad()                       						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetDesPa(oGet1,nLin_aMed,cVar,nDesPad)
Local nTamcVar := Len(Alltrim(cVar))
Local nx := 0
Local nVar := 0
Local nTamDc := 1
lRet := .t.              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Medicao e externa sem lancamento de medicoes para dar ³
//³ Get na incerteza e no desvio padrao . 										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !( aMedicoes[nLin_aMed,nPosGer,1,4] == "E" .And.;	
	 aMedicoes[nLin_aMed,nPosGer,1,1] == 0 )
	nTamDc := Iif(Empty(AllTrim(cVarial)),QA_NUMDEC(cVar),QA_NUMDEC(cVarial))
Else	
	nTamDc := QA_NUMDEC(cVar)
EndIf
cVar := oGet1:cText
If !empty(cVar)
	For nx := 1 to nTamcVar
		If !IsDigit(SubStr(Alltrim(cVar),nx,1)) .and. !(SubStr(AllTrim(cVar),nx,1)) $ ".,-"
			lRet := .F.                     
			oGet1:cText := CriaVar("QM7_INCERT")
			cVar := oGet1:cText
			oGet1:SetText(cVar)
			oGet1:cText := cVar
			oGet1:Refresh()
		Endif
	Next nx 	
	If lRet
		If Valtype(cVar) <> "C" 
			cVar := StrTran(Str(cVar,10,nTamDc),".",",")			
		Else
			cVar := StrTran(cVar,".",",")						
		Endif
		nVar := At(".",cVar)
		If Qa_VerNum(@cVar)    
			aMedicoes[nLin_aMed,nPosGer,1,9] := cVar
			nDesPad := cVar
			oGet1:SetText(cVar)
			oGet1:cText := cVar
			oGet1:Refresh()
			lRet := .t.
		EndIf  
	Else
		oGet1:SetText(cVar)
		oGet1:cText := cVar
	Endif
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³RetDesIn  ³ Autor ³ Wanderley Goncalves   ³ Data ³12/05/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna Incerteza total     								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 -                                   				  ³±±
±±³			 ³ExpN1 -                                                     ³±±
±±³			 ³ExpC1 -                                                     ³±±
±±³			 ³Expn2 -                              						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpL1 -                                                	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140ShwPad()                       						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetDesIn(oGet2,nLin_aMed,cVar2,nInsTot)
Local nTamcVar := Len(Alltrim(cVar2))
Local nx := 0
Local nVar := 0
Local nTamDc := 1
lRet := .t.
nTamDc := QA_NUMDEC(cVar2)

If !empty(cVar2)
	For nx := 1 to nTamcVar
		If !IsDigit(SubStr(Alltrim(cVar2),nx,1)) .and. !(SubStr(AllTrim(cVar),nx,1)) $ ".,-"
			lRet := .F.                     
			oGet2:cText := CriaVar("QM7_INCERT")
			cVar2 := oGet2:cText
			oGet2:SetText(cVar2)
			oGet2:cText := cVar2
			oGet2:Refresh() 
		Endif
	Next nx 	
	If lRet
		If Valtype(cVar2) <> "C" 
			cVar2 := StrTran(Str(cVar2,10,nTamDc),".",",")			
		Else
			cVar2 := StrTran(cVar2,".",",")						
		Endif
		nVar := At(".",cVar2)
		If Qa_VerNum(@cVar2)    
			aMedicoes[nLin_aMed,nPosGer,1,10] := cVar2
			nInsTot := cVar2
			oGet2:SetText(cVar2)
			oGet2:cText := cVar2
			lRet := .t.
		EndIf  
	Else
		oGet2:SetText(cVar2)
		oGet2:cText := cVar2
	Endif
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QMT141MV  ³ Autora³ Iuri Seto             ³ Data ³13/04/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se o campo memo está vazio        				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1        												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpL1 -                                                	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QMTa141()                          						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT141MV(cMemo)

Local lRet
Local nLoop 
Local aChr := {}

Aadd( aChr, 10) //Ctrl+Return
Aadd( aChr, 13)	//ENTER
Aadd( aChr, 32)	//Espaco          
Aadd( aChr,  9)	//Ctrl+TAB          

lRet := .T.
cMemo := Alltrim(cMemo)
For nLoop := 1 To Len(cMemo) 
	If Ascan( aChr, Asc(Substr(cMemo,nLoop,1)) ) == 0
		lRet := .F.
		Exit                                     
	Endif
NEXT nLoop

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A1141InsEsc ³ Autora³ Iuri Seto           ³ Data ³ 15/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se é instrumento Malha e retorna o codigo do      ³±±
±±³          ³ instrumento que se refere a escalha atual.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Codigo do Instrumento         					  ³±±
±±³          ³ ExpC2 : Escala do Instrumento         					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpC1 : Código do Instrumento Filho/Escala do Instrumento  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QMTA141													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A141InsEsc(cMtInstr,cEscala)
Local cOldAlias := Select()
LocaL nReg := Recno()
Local cInsEsc

//cInsEsc := cEscala
dbSelectArea("QM2")
dbSetOrder(7)
If QM2->(dbSeek(xFilial("QM2")+"0"+cMtInstr+cEscala))
	cInsEsc := QM2->QM2_INSTR	
Else
	cInsEsc := ""
EndIf

dbSelectArea(cOldAlias)
dbGoto(nReg)
Return(cInsEsc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³a141VlPadS³ Autora³ Iuri Seto             ³ Data ³ 16/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida os padrões secundários importados da calibração      ³±±
±±³          ³anterior.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Escala utilizada									  ³±±
±±³			 ³ExpC2 - Padrao utilizado									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Array contendo os PS								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ MontPSec									  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                         
Function a141VlPadS(cMtInstr,cEscala)
Local cOldAlias := Select()
Local nReg		:= Recno()                         
Local nRec		
Local nOrder
Local lRetu		:= .T.
Local aArQM6	:= {}

If lRetu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Padrao Secundario ‚ o	  ³
	//³ Instrumento que esta sofrendo medicao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QMS->QMS_PADSEC == cMtInstr 
		lRetu := .F.
	EndIf
EndIf

If lRetu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Padrao Secund.  esta' cadastrado  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ExistCpo2("QM2",QMS->QMS_PADSEC,,)
	  lRetu := .F.
	EndIf
EndIf

If lRetu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Padrao Secundario ‚ v lido ³
	//³ Data de validade e Aprovado				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("QM2")
	nOrder := QM2->(IndexOrd())
	nRec := QM2->(recno())
	DbSetOrder(1)
	DbSeek(xFilial("QM2")+QMS->QMS_PADSEC)  

	If !Inclui .And. !Altera
		If QMS->QMS_PADSEC == QM2->QM2_INSTR
			lRetu := .T.
		Endif	
	Else
		If QM2->QM2_VALDAF < ddatabase .or. QM2->QM2_STATUS = "R"
			lRetu := .F.
		EndIf
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Padrao Secundario pertence ao grupo ³
	//³ de Tipos Secund rios.					   		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetu
		If !A141LISTPS(cEscala,QM2->QM2_TIPO)
			lRetu := .F.
		EndIf
	EndIf
	
	DbSelectArea("QM2")
	DbSetOrder(nOrder)
	DbGoto(nRec)

EndIf

If lRetu
	dbSelectArea("QM6")
	dbSetOrder(2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Garantir integridade dos padroes secundarios e dos responsaveis no    ³
	//³momento da alteracao da calibracao.                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArQM6 := GetArea() 
	If QM6->(DbSeek(xFilial("QM6")+QM2->QM2_INSTR+QM2->QM2_REVINS))
		QM7->(DbSetOrder(1))
		If !( QM7->(DbSeek(xFilial("QM7")+QM6->QM6_INSTR+;
				QM6->QM6_REVINS+DtoS(QM6->QM6_DATA)+QM6->QM6_CSEQ)))
			// "O Instrumento informado ainda nao sobreu medicao, sendo assim nao podera ser utilizado nesta opcao. Inclua medições para o mesmo primeiro."
			lRetu := .F.
		EndIf
	Else
		//"O Instrumento informado ainda não sobreu medicao, sendo assim não podera ser utilizado nesta opcao. Inclua medicoes para o mesmo primeiro."
		lRetu := .F.
	EndIf
	RestArea(aArQM6)
EndIf

dbSelectArea(cOldAlias)
dbGoto(nReg)

Return(lRetu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A141ListPS³ Autora³ Iuri Seto             ³ Data ³ 16/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtro para Selecao de Padroes Secundarios				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A141ListPS()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Escala											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ A141VlPadS            									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A141ListPS(cEscala,cTipo)
Local lRet		:= .F.
Local cPertMt140 := ""

QMH->(DbSetOrder(1))
If QMH->(dbSeek(xFilial("QMH")+cEscala))
	Do while QMH->QMH_ESCALA == cEscala .And. QMH->QMH_FILIAL == xFilial("QMH")
		cPertMt140 += QMH->QMH_PADSEC
		QMH->(DbSkip())
	EndDo	
EndIf

If cTipo $ cPertMt140
	lRet := .T.
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³a141VlIU	³ Autora³ Iuri Seto             ³ Data ³ 16/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo de Instrumento Utilizado			  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA141                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a141VlIU(cMtInstr,cEscala) 
Local cOldAlias := Select()
Local nReg   	:= Recno()
Local nRec 
Local nOrder
Local lRetu 	:= .t.
Local aArQM6	:= {}
If lRetu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Instr.Utilizado ‚ o Instrumento ³
	//³ que esta sofrendo medicao 					  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QMI->QMI_INSUT == cMtInstr
		lRetu := .F.
	EndIf
EndIf

If lRetu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Instr.Utilizado esta' cadastrado  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ExistCpo2("QM2",QMI->QMI_INSUT,,)
		lRetu := .F.
	EndIf
EndIf

If lRetu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Instr.Utilizado ‚ v lido ³
	//³ Data de validade e Aprovado			   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("QM2")
	nOrder := QM2->(IndexOrd())
	nRec := QM2->(recno())
	DbSetOrder(1)
	DbSeek(xFilial("QM2")+QMI->QMI_INSUT)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No caso de visualizacao, nao consistir validade de afericao do instrumento³
	//³pois o registro ja foi gravado e impresso o certificado.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Inclui .or. !Altera
		If QMI->QMI_DATA == QM6->QM6_DATA 
			lRetu := .T.
		Endif
	Else
		If QM2->QM2_VALDAF < ddatabase .or. QM2->QM2_STATUS = "R"
			lRetu := .F.
		EndIf
	Endif	
EndIf
DbSelectArea("QM2")
DbSetOrder(nOrder)
DbGoto(nRec)

If lRetu
	DbSelectArea("QM6")
	QM6->(DbSetOrder(2))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Garantir integridade dos instrumentos utilizados e dos responsaveis no³
	//³momento da alteracao da calibracao.                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArQM6 := GetArea() 
	If QM6->(DbSeek(xFilial("QM6")+QM2->QM2_INSTR+QM2->QM2_REVINS))
		QM7->(DbSetOrder(1))
		If !( QM7->(DbSeek(xFilial("QM7")+QM6->QM6_INSTR+;
				QM6->QM6_REVINS+DtoS(QM6->QM6_DATA)+QM6->QM6_CSEQ)))
			//"O Instrumento informado ainda nao sofreu medicao, sendo assim nao podera ser utilizado nesta opcao. Inclua medicoes para o mesmo primeiro."
			lRetu := .F.
		EndIf
	Else
		//"O Instrumento informado ainda nao sofreu medicao, sendo assim não podera ser utilizado nesta opcao. Inclua medicoes para o mesmo primeiro."
		lRetu := .F.	
	EndIf
	RestArea(aArQM6)
EndIf

dbSelectArea(cOldAlias)
dbGoto(nReg)

Return lRetu

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt141NoLabºAutor  ³Denis Martins       º Data ³  06/01/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Mostra nome(fantasia) do laboratorio externo, apos digitar o º±±
±±º          ³codigo do laboratorio.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA141(a140shwext)                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt141NoLab(cMtLabExt,oNomeLab)

dbSelectArea("QMO")
dbSetOrder(01)
If dbSeek(xFilial("QMO")+cMtLabExt)
	cNomeLab := QMO->QMO_FANT
Else
	cNomeLab := Space(20)	
Endif	

aObjetos[OBJ_MEDEXT][9]:cCaption := cNomeLab
aObjetos[OBJ_MEDEXT][9]:Show()
aObjetos[OBJ_MEDEXT][9]:Refresh()
Return cNomeLab

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Qmt141AtribºAutor  ³Denis Martins       º Data ³  06/01/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Evitar digitacao de mais de uma linha de Acols qdo o tipo de º±±
±±º          ³padrao for atributo.                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA141                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt141Atrib(lAtributo)
Local lRet := .T.
If lAtributo
   If aCols[oGetMed2:oBrowse:nAt][1] > 1 .and. Len(aCols)+1
      lRet := .F.
   Endif
Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a140TamDecºAutor  ³Denis Martins       º Data ³  06/17/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o tamanho de casas decimais a ser considerada nas teº±±
±±º          ³las de calibracoes qdo a Unidade de Medida em questao e difeº±±
±±º          ³rente da Unidade de Medidao da Escala.					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA140/QMTA141                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a140TamDec(nTam,cNomin,cUniMed,nCoef,nLin_aMed)
Local lRetu := .T.
Local cTamEsc := GetNewPar("MV_QDECPAD","1") //Considerar o tamanho de casas decimais do padrao
nPosPad := 02 //Deve-se fixar, pois a funcao a140shwsec e a140shwins retorna 01
If aMedicoes[nLin_aMed,nPosGer,1,1] <> 0 
	dbSelectArea("QM3")
	dbSetOrder(1)
	dbSeek(xFilial("QM3")+aMedicoes[nLin_aMed][nPosPad])
	
	dbSelectArea("QM9")
	dbSetOrder(1)
	dbSeek(xFilial("QM9")+aMedicoes[nLin_aMed][nPosEsc])    
	If !Found() //Caso seja instrumento/Escala Malha
		dbSeek(xFilial("QM9")+aMedicoes[nLin_aMed][nPosCar])    	
	Endif
	
	If  !(aMedicoes[nLin_aMed,nPosGer,1,2]) $ "4|8|5"
		cNomin  := QM3->QM3_ESPEC
		cUniMed := QM3->QM3_UNIMED
	ElseIf aMedicoes[nLin_aMed,nPosGer,1,2] <> "5"
		dbSelectArea("QMG")
		dbSetOrder(1)
		dbSeek(xFilial("QMG")+cMtInstr+cMtRevIns+aMedicoes[nLin_aMed][nPosPad])
		//Solicitacao Rogerio - Romi, para Calibradores/Calibrador Completo com escalas
		//atributo nao validar unidade de medida.		
		If Upper(Alltrim(aMedicoes[nPosAmed,nPosGer,1,3])) == "A"		
			cNomin  := QMG->QMG_NOMIN
			cUniMed := QM9->QM9_UNIMED
		Else
			cNomin  := QMG->QMG_NOMIN
			cUniMed := QMG->QMG_UNIMED
		Endif	
	ElseIf aMedicoes[nLin_aMed,nPosGer,1,2] == "5"
		dbSelectArea("QMA")
		dbSetOrder(1)
		dbSeek(xFilial("QMA")+QM9->QM9_ESCALA+QM9->QM9_REVESC+aMedicoes[nLin_aMed][nPosPad]) 
		cUniMed := QM9->QM9_UNIMED
		cNomin  := aMedicoes[nLin_aMed,nPosEsp]//QMA->QMA_TOLER
	Endif
	
	If cUniMed <> QM9->QM9_UNIMED
		dbSelectArea("SAP")
		dbSetOrder(1)
		If dbSeek(xFilial("SAP")+cUniMed+QM9->QM9_UNIMED)
			nCoef := SAP->AP_COEF
		Else
			lRetu := .F.
			Help( " ", 1, "A140UNIDIF" )//Unidades de Medidas Incompativeis. Cadastre as mesmas.
		Endif
	Else
		nCoef := 1
	Endif
	
	If Alltrim(cTamEsc) == "1" 
		If lTamSom	
			If !Empty(QM9->QM9_ESCALI)
				nTam := QA_NUMDEC(QM9->QM9_ESCALI)
			Else
				nTam := QA_NUMDEC(aMedicoes[nLin_aMed,nPosEsp])
			Endif	
		Else
			nTam := QA_NUMDEC(aMedicoes[nLin_aMed,nPosEsp])
		Endif
	Else
		nTam := QA_NUMDEC(cNomin)
	Endif
Endif

Return lRetu

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A141AprEsc() ºAutor  ³Denis Martins       º Data ³  07/30/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controlar status de cada escala - Aprovado / Reprovado / Nao   º±±
±±º          ³digaitado                                        	           	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                          	             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A141AprEsc(oDlgPri,oBmpEsc,oBmpPad,aResult)
Local nLin_aMed:= Ascan(aMedicoes, { |x| Alltrim(x[1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt]) .and. Alltrim(x[2]) == Alltrim(oCbxPad:aItems[oCbxPad:nAt])})
Local cColor	:= "BR_PRETO"
Local nx
Local lMonPreto := .F. 
Local lMonVerm  := .F.
Local lMonVed   := .F.
Local nPosicao  := 0

If aResult <> NIL
	If !Empty(aMedicoes[nLin_aMed,4,1,1]) 
		For nx := 1 To Len(aResult)                 
			If aResult[nx][10] == "R"
				lMonVerm := .T.
				lMonVed  := .F.
				lMonPreto:= .F.				
				Exit          	
			ElseIf aResult[nx][10] == "A"
				lMonVed	:= .T.
				lMonVerm	:= .F.
				lMonPreto:= .F.
			Endif
		Next nx	
	Else
		lMonPreto := .T.	 
		lMonVerm	 := .F.
		lMonVed	 := .F.			
	Endif
Else
	If aMedicoes[nLin_aMed,nPosGer,1,1] <> 0	
		If aMedicoes[nLin_aMed,nPosGer,1,2] $ "1|4" // Simples
   	   nPosicao := 1
		ElseIf aMedicoes[nLin_aMed,nPosGer,1,2] $ "2|3|5|8|9" // Dif. de Simples
			If Upper(Alltrim(aMedicoes[nLin_aMed,nPosGer,1,3])) == "A"
				nPosicao := 1							  	
			Else
  				nPosicao := 2
			Endif
		Endif

		For nx := 1 to Len(aEscPad)
			If Alltrim(aEscPad[nx][1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt])
				nLin_aMed	:= Ascan(aEscPad,{ |x| Alltrim(x[1]) == Alltrim(aEscPad[nx][1]) .and. Alltrim(x[2]) == Alltrim(aEscPad[nx][2])})
				aResult := a140Calc(nx)
				If Upper(Alltrim(aMedicoes[nLin_aMed,nPosGer,1,3])) == "A" .And. (Empty(aMedicoes[nLin_aMed,nPosGer,1,2]) .And. aMedicoes[nLin_aMed,nPosGer,1,4] == "E") .Or. aMedicoes[nLin_aMed,nPosGer,1,2] $ "1|2|3|4|5|8|9" 
					nPosicao := 1							  	
				Else
  					nPosicao := 2
				Endif

				If !Empty(aMedicoes[nLin_aMed,4,1,1]) 
					If aResult[nPosicao][10] == "R"          
						lMonVerm := .T.
						lMonVed  := .F.
						lMonPreto:= .F.				
						Exit // Se encontrou 1 (um) suficiente para reprovar a escala
					ElseIf aResult[nPosicao][10] == "A"          
						lMonVerm := .F.
						lMonVed  := .T.
						lMonPreto:= .F.							
					Endif
					If aMedicoes[nLin_aMed,nPosGer,1,2] $ "3|9" //Pressao ou Relogio
						If Upper(Alltrim(aMedicoes[nLin_aMed,nPosGer,1,3])) == "A"
							nPosicao := 1
							If aResult[nPosicao][10] == "R"          
								lMonVerm := .T.
								lMonVed  := .F.
								lMonPreto:= .F.				
								Exit // Se encontrou 1 (um) suficiente para reprovar a escala
							ElseIf aResult[nPosicao][10] == "A"          
								lMonVerm := .F.
								lMonVed  := .T.
								lMonPreto:= .F.							
							Endif
						Else
							If aResult[nPosicao+2][10] == "R"          
								lMonVerm := .T.
								lMonVed  := .F.
								lMonPreto:= .F.				
								Exit // Se encontrou 1 (um) suficiente para reprovar a escala
							ElseIf aResult[nPosicao+2][10] == "A"          
								lMonVerm := .F.
								lMonVed  := .T.
								lMonPreto:= .F.							
							Endif
						Endif
				   Endif
				Else 
					lMonVerm := .F.
					lMonVed  := .F.
					lMonPreto:= .T.				
				Endif		
			Endif	
		Next	
	Endif	
Endif	

If lMonVerm
	cColor := "BR_VERMELHO"
	oBmpEsc:SetBmp(cColor)
	oBmpEsc:Show()			
	oBmpEsc:Refresh()			
ElseIf lMonVed
	cColor := "BR_VERDE"
	oBmpEsc:SetBmp(cColor)
	oBmpEsc:Show()			
	oBmpEsc:Refresh()						
ElseIf lMonPreto
	cColor := "BR_PRETO"
	oBmpEsc:SetBmp(cColor)
	oBmpEsc:Show()			
	oBmpEsc:Refresh()							
Endif                               

a141AprPad(oDlgPri,oBmpPad,oBmpEsc)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a141AprPadºAutor  ³Denis Martins       º Data ³  07/30/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controlar o status de cada padrao - Aprovado / Reprovado    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA141                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a141AprPad(oDlgPri,oBmpPad,oBmpEsc)

Local nLin_aMed	:= Ascan(aEscPad,{ |x| Alltrim(x[1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt]) .and. Alltrim(x[2]) == Alltrim(oCbxPad:aItems[oCbxPad:nAt])})
Local cColor		:= "BR_PRETO"
Local aResult		:= {}           
Local nPosicao		:= 0
Local lAchou		:= .T.
Local nx			:= 1

If !Empty(aMedicoes[nLin_aMed,4,1,1]) //Se nao estiver vazio procura o status
	aResult := a140Calc(nLin_aMed)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica qual e o tipo da ESCALA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aMedicoes[nLin_aMed,nPosGer,1,1] <> 0 .And. aMedicoes[nLin_aMed,nPosGer,1,4] <> "E" .Or. ISDIGIT(ALLTRIM(aMedicoes[nLin_aMed,4,1,1]))
		If aMedicoes[nLin_aMed,nPosGer,1,2] $ "1|4" // Simples - Calibrador
	   	   nPosicao := 1
		ElseIf aMedicoes[nLin_aMed,nPosGer,1,2] $ "2|3|5|8|9" // Dif. de Simples
			If Upper(Alltrim(aMedicoes[nLin_aMed,nPosGer,1,3])) == "A"
				nPosicao := 1							  	
			Else
  				nPosicao := 2
			Endif
		Endif
		If aResult[nPosicao,10] == "R"  
			cColor := "BR_VERMELHO" 
			oBmpPad:SetBmp(cColor)	
			oBmpPad:Refresh()				
		ElseIf aResult[nPosicao,10] == "A"
			cColor := "BR_VERDE"
			oBmpPad:SetBmp(cColor)
			oBmpPad:Refresh()		
		Endif	
		
		If aMedicoes[nLin_aMed,nPosGer,1,2] $ "3|9" //Pressao ou Relogio
			If Upper(Alltrim(aMedicoes[nLin_aMed,nPosGer,1,3])) == "A"
				nPosicao := 1
				If aResult[nPosicao,10] <> "R"
					If aResult[nPosicao,10] == "R"  
						cColor := "BR_VERMELHO" 
						oBmpPad:SetBmp(cColor)
						oBmpPad:Refresh()				
					ElseIf aResult[nPosicao,10] == "A"
						cColor := "BR_VERDE"
						oBmpPad:SetBmp(cColor)
						oBmpPad:Refresh()		
					Endif	
				Endif	
			Else
				If aResult[nPosicao,10] <> "R"
					If aResult[nPosicao+2,10] == "R"  
						cColor := "BR_VERMELHO" 
						oBmpPad:SetBmp(cColor)
						oBmpPad:Refresh()				
					ElseIf aResult[nPosicao+2,10] == "A"
						cColor := "BR_VERDE"
						oBmpPad:SetBmp(cColor)
						oBmpPad:Refresh()		
					Endif	
				Endif	
			Endif	
		Endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o Tipo de Calibracao for Externa (Aprovado / Reprovado)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aMedicoes[nLin_aMed,4,1,1])
			If aMedicoes[nLin_aMed,4,1,1] == "A"
				cColor := "BR_VERDE" 
				oBmpPad:SetBmp(cColor)
				oBmpPad:Refresh()				
			ElseIf aMedicoes[nLin_aMed,4,1,1] == "R"
				cColor := "BR_VERMELHO" 
				oBmpPad:SetBmp(cColor)
				oBmpPad:Refresh()				
			Endif
		Endif
	Endif	
Else 
	cColor := "BR_PRETO"
	oBmpPad:SetBmp(cColor)
	oBmpPad:Refresh()		
Endif                         

If Len(aEscPad) <= 80 //Atualiza status de escala ateh 80 pontos/padroes.
	For nx := 1 To Len(aEscPad)
		If Alltrim(aEscPad[nx][1]) == Alltrim(oCbxEsc:aItems[oCbxEsc:nAt])
			nLin_aMed	:= Ascan(aEscPad,{ |x| Alltrim(x[1]) == Alltrim(aEscPad[nx][1]) .and. Alltrim(x[2]) == Alltrim(aEscPad[nx][2])})
			aResult := a140Calc(nx)
			If aMedicoes[nLin_aMed,nPosGer,1,1] <> 0 .And. aMedicoes[nLin_aMed,nPosGer,1,4] <> "E"	
				If aMedicoes[nLin_aMed,nPosGer,1,2] $ "1|4" // Simples
					nPosicao := 1
				ElseIf aMedicoes[nLin_aMed,nPosGer,1,2] $ "2|3|5|8|9" // Dif. de Simples
  					If Upper(Alltrim(aMedicoes[nLin_aMed,nPosGer,1,3])) == "A"
						nPosicao := 1							  	
  					Else
		  				nPosicao := 2
  					Endif
				Endif 
				If !Empty(aMedicoes[nx,4,1,1])
					If aResult[nPosicao][10] == "R"
						cColor := "BR_VERMELHO" 
						oBmpEsc:SetBmp(cColor)
						oBmpEsc:Refresh()
						Exit				
					ElseIF aResult[nPosicao][10] == "A"
						cColor := "BR_VERDE" 
						oBmpEsc:SetBmp(cColor)
						oBmpEsc:Refresh()				
					Endif
				
					If aMedicoes[nLin_aMed,nPosGer,1,2] $ "3|9" //Pressao ou Relogio
						If Upper(Alltrim(aMedicoes[nLin_aMed,nPosGer,1,3])) == "A"
							nPosicao := 1
							If aResult[nPosicao,10] <> "R"
								If aResult[nPosicao,10] == "R"  
									cColor := "BR_VERMELHO" 
//								oBmpPad:SetBmp(cColor)
//								oBmpPad:Refresh()				
								ElseIf aResult[nPosicao,10] == "A"
									cColor := "BR_VERDE"
//								oBmpPad:SetBmp(cColor)
//								oBmpPad:Refresh()		
								Endif	
							Endif	
						Else
							If aResult[nPosicao][10] <> "R"
								If aResult[nPosicao+2][10] == "R"
									cColor := "BR_VERMELHO" 
									oBmpEsc:SetBmp(cColor)
									oBmpEsc:Refresh()
									Exit				
								ElseIF aResult[nPosicao+2][10] == "A"
									cColor := "BR_VERDE" 
									oBmpEsc:SetBmp(cColor)
									oBmpEsc:Refresh()				
								Endif
							Endif	
						Endif
					Endif
				Else
					lAchou := .F.
				Endif	
			Else
				If !Empty(aMedicoes[nx,4,1,1])
					If aMedicoes[nx,4,1,1] == "A"
						cColor := "BR_VERDE" 
						oBmpEsc:SetBmp(cColor)
						oBmpEsc:Refresh()
					ElseIf aMedicoes[nx,4,1,1] == "R"
						cColor := "BR_VERMELHO" 
						oBmpEsc:SetBmp(cColor)
						oBmpEsc:Refresh()				
					Endif
				Else
					lAchou := .F.
				Endif
			Endif
		Endif	
	Next nx
Else
	lAchou := .f.
Endif
If !lAchou
	cColor := "BR_PRETO" 
	oBmpEsc:SetBmp(cColor)
	oBmpEsc:Refresh()				
Endif

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a140bStOptionºAutor  ³Denis Martins		º Data ³  03/16/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Obtem posicao do folder que estou posicionado.              	 º±±
±±º          ³                                                            	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA140 / QMTA141                                          	 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a140bStOption()
oFolderFix:bSetOption :={|nAt|nGot := nAt}
Return nGot
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt140VCposºAutor  ³Denis Martins       º Data ³  01/22/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica Medicao fora do Especificado quando estiver utili-  º±±
±±º          ³zando instrumento conectado a porta						   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA140/141/142                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt140VCpos(oGetDad)

Local nPosIni := 0
Local nPosFim := 0
Local nPosInd := 0
Local nPosFid := 0

nPosIni := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM8_VLRINI" })
nPosFim := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM8_VLRFIM" })
nPosInd := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM8_VLRIND" })
nPosFid := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM8_VLRFID" })

If oGetDad:oBrowse:nColPos == 1
	If nPosIni > 0
		M->QM8_VLRINI := aCols[oGetDad:oBrowse:nAt][oGetDad:oBrowse:nColPos]
		Qmt140VEsp("QM8_VLRINI")
	Else
		M->QM8_VLRIND := aCols[oGetDad:oBrowse:nAt][oGetDad:oBrowse:nColPos]
		Qmt140VEsp("QM8_VLRIND")
	Endif
Else
	If nPosFim > 0
		M->QM8_VLRFIM := aCols[oGetDad:oBrowse:nAt][oGetDad:oBrowse:nColPos]
		Qmt140VEsp("QM8_VLRFIM")
	Else
		M->QM8_VLRFID := aCols[oGetDad:oBrowse:nAt][oGetDad:oBrowse:nColPos]
		Qmt140VEsp("QM8_VLRFID")
	Endif
Endif
	
Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Qmt141VVarºAutor  ³Denis Martins       º Data ³  03/19/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pelo calculo de LIE / LSE para escalas   º±±
±±º          ³com valor especificado variavel.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp1 - Coeficiente multiplicador de conversao;              º±±
±±º          ³Exp2 - Valor calculado de limite inferior ou Superior;      º±±
±±º          ³Exp3 - Flag para Limite inferior ou Superior.               º±±
±±º          ³Exp4 - Verifica a primeira montangem para Show/Hide correto º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt141VVar(nCoef,nValor,lLie,lPrimer)
Local nEspec := SuperVal(aMedicoes[nPosAMed,nPosEsp])
Local nMinim := SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])
Local nMaxim := SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])

If Alltrim(aMedicoes[nPosAMed,nPosGer,1,21]) <> "1" 
	If !lUniGual
		If lLie
			nValor :=	nEspec - (((nMinim / 100) * nEspec ))//SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */ - ((SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */) * SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])*nCoef)/100
		Else
			nValor :=	nEspec + (((nMinim / 100) * nEspec ))//SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */ + ((SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */) * SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])*nCoef)/100
		Endif			
	Else
		If lLie
			nValor :=	SuperVal(aMedicoes[nPosAMed,nPosEsp]) - (SuperVal(aMedicoes[nPosAMed,nPosEsp]) * SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2]))/100
		Else			
			nValor :=	SuperVal(aMedicoes[nPosAMed,nPosEsp]) + (SuperVal(aMedicoes[nPosAMed,nPosEsp]) * SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1]))/100
		Endif	
	Endif	
Else
	If !lUniGual
		If lLie
			nValor :=	nEspec - nMinim//SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */ - SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])*nCoef
		Else			
			nValor :=	nEspec + nMaxim//SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */ + SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])*nCoef		
		Endif			
	Else     
		If lLie
			nValor :=	SuperVal(aMedicoes[nPosAMed,nPosEsp]) - SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])
		Else	
			nValor :=	SuperVal(aMedicoes[nPosAMed,nPosEsp]) + SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])
		Endif			
	Endif
Endif

If !lPrimer
	If aMedicoes[nPosAMed,nPosGer,1,3] <> "A"
		If aMedicoes[nPosAMed,nPosGer,1,2] $ "4|8" 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ja e verifica o tipo de calculo da tolerancia (1-Numerico / 2-Percentual)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aObjetos[OBJ_MEDICAO_1][13]:SetText(STR0034+aMedicoes[nPosAmed,nPosGer,1,18])
			aObjetos[OBJ_MEDICAO_1][13]:Show()
			aObjetos[OBJ_MEDICAO_1][13]:Refresh()
			aObjetos[OBJ_MEDICAO_1][14]:SetText(STR0035+aMedicoes[nPosAmed,nPosGer,1,19])
			aObjetos[OBJ_MEDICAO_1][14]:Show()
			aObjetos[OBJ_MEDICAO_1][14]:Refresh()				
			aObjetos[OBJ_MEDICAO_1][15]:Hide()
			aObjetos[OBJ_MEDICAO_1][16]:Hide()				
		Else
			aObjetos[OBJ_MEDICAO_1][13]:Hide()
			aObjetos[OBJ_MEDICAO_1][14]:Hide()
			aObjetos[OBJ_MEDICAO_1][15]:Show()
			aObjetos[OBJ_MEDICAO_1][16]:Show()				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o tipo de calculo da tolerancia (1-Numerico / 2-Percentual)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If Alltrim(aMedicoes[nPosAMed,nPosGer,1,21]) <> "2" 
				If !lUniGual
					If lLie
						aObjetos[OBJ_MEDICAO_1][17]:SetText(nValor)//SetText(SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */ - SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])*nCoef)
						aObjetos[OBJ_MEDICAO_1][17]:Show()
						aObjetos[OBJ_MEDICAO_1][17]:Refresh()
					Else	
						aObjetos[OBJ_MEDICAO_1][18]:SetText(nValor)//SetText(SuperVal(aMedicoes[nPosAMed,nPosEsp])/* *nCoef */ + SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])*nCoef)
						aObjetos[OBJ_MEDICAO_1][18]:Show()				
					Endif
					aObjetos[OBJ_MEDICAO_1][19]:Hide()
					aObjetos[OBJ_MEDICAO_1][20]:Hide()				
				Else
					aObjetos[OBJ_MEDICAO_1][17]:Hide()
					aObjetos[OBJ_MEDICAO_1][18]:Hide()				

					If lLie
						aObjetos[OBJ_MEDICAO_1][19]:SetText("")					
						aObjetos[OBJ_MEDICAO_1][19]:Hide()
						aObjetos[OBJ_MEDICAO_1][19]:SetText(SuperVal(aMedicoes[nPosAMed,nPosEsp]) - SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2]))
						aObjetos[OBJ_MEDICAO_1][19]:cCaption := StrTran(Str(nValor,Len(aMedicoes[nPosAMed,nPosEsp]),QA_NumDec(aMedicoes[nPosAMed,nPosEsp])),".",",")
						aObjetos[OBJ_MEDICAO_1][19]:cTitle := StrTran(Str(nValor,Len(aMedicoes[nPosAMed,nPosEsp]),QA_NumDec(aMedicoes[nPosAMed,nPosEsp])),".",",")
						aObjetos[OBJ_MEDICAO_1][19]:Show()
						aObjetos[OBJ_MEDICAO_1][19]:lTransparent := .F.
					Else
						aObjetos[OBJ_MEDICAO_1][20]:SetText(SuperVal(aMedicoes[nPosAMed,nPosEsp]) + SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1]))
						aObjetos[OBJ_MEDICAO_1][20]:cCaption := StrTran(Str(nValor,Len(aMedicoes[nPosAMed,nPosEsp]),QA_NumDec(aMedicoes[nPosAMed,nPosEsp])),".",",")
						aObjetos[OBJ_MEDICAO_1][20]:cTitle := StrTran(Str(nValor,Len(aMedicoes[nPosAMed,nPosEsp]),QA_NumDec(aMedicoes[nPosAMed,nPosEsp])),".",",")
						aObjetos[OBJ_MEDICAO_1][20]:Show()
						aObjetos[OBJ_MEDICAO_1][20]:lTransparent := .F.
					Endif
				Endif   	          
			Else //Percentual
				If !lUniGual
					If lLie
						aObjetos[OBJ_MEDICAO_1][17]:SetText(nValor)//SetText(SuperVal(aMedicoes[nPosAMed,nPosEsp])*nCoef - (SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])/100)*nCoef)
						aObjetos[OBJ_MEDICAO_1][17]:Show()
						aObjetos[OBJ_MEDICAO_1][17]:Refresh()
					Else	
						aObjetos[OBJ_MEDICAO_1][18]:SetText(nValor)//SetText(SuperVal(aMedicoes[nPosAMed,nPosEsp])*nCoef + (SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])/100)*nCoef)
						aObjetos[OBJ_MEDICAO_1][18]:Show()				
					Endif
					aObjetos[OBJ_MEDICAO_1][19]:Hide()
					aObjetos[OBJ_MEDICAO_1][20]:Hide()				
				Else
					aObjetos[OBJ_MEDICAO_1][17]:Hide()
					aObjetos[OBJ_MEDICAO_1][18]:Hide()				

					If lLie
						aObjetos[OBJ_MEDICAO_1][19]:SetText("")					
						aObjetos[OBJ_MEDICAO_1][19]:Hide()
						aObjetos[OBJ_MEDICAO_1][19]:SetText(SuperVal(aMedicoes[nPosAMed,nPosEsp]) - (SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,2])/100))
						aObjetos[OBJ_MEDICAO_1][19]:cCaption := StrTran(Str(nValor,Len(aMedicoes[nPosAMed,nPosEsp]),QA_NumDec(aMedicoes[nPosAMed,nPosEsp])),".",",")
						aObjetos[OBJ_MEDICAO_1][19]:cTitle := StrTran(Str(nValor,Len(aMedicoes[nPosAMed,nPosEsp]),QA_NumDec(aMedicoes[nPosAMed,nPosEsp])),".",",")
						aObjetos[OBJ_MEDICAO_1][19]:Show()
						aObjetos[OBJ_MEDICAO_1][19]:lTransparent := .F.
					Else
						aObjetos[OBJ_MEDICAO_1][20]:SetText(SuperVal(aMedicoes[nPosAMed,nPosEsp]) + (SuperVal(aMedicoes[nPosAMed,nPosGer,1,7,1])/100))
						aObjetos[OBJ_MEDICAO_1][20]:cCaption := StrTran(Str(nValor,Len(aMedicoes[nPosAMed,nPosEsp]),QA_NumDec(aMedicoes[nPosAMed,nPosEsp])),".",",")
						aObjetos[OBJ_MEDICAO_1][20]:cTitle := StrTran(Str(nValor,Len(aMedicoes[nPosAMed,nPosEsp]),QA_NumDec(aMedicoes[nPosAMed,nPosEsp])),".",",")
						aObjetos[OBJ_MEDICAO_1][20]:Show()
						aObjetos[OBJ_MEDICAO_1][20]:lTransparent := .F.
					Endif
				Endif   	          
			EndIf
		Endif	
	Endif	
Endif	
Return nValor
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMTA141   ºAutor  ³Denis Martins       º Data ³  08/05/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega o proximo padrao a ser digitado. Qdo chegar no ulti-º±±
±±º          ³mo, posiciona no primeiro                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA140/141/142                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a140MudPad()

Local nContF8 := oCbxPad:nAt + 1 
Local nPsRow 
If nContF8 <= Len(oCbxPad:aItems)
//	oCbxPad:aItems[nContF8]
	oCbxPad:nAt := nContF8
	cPadr := oCbxPad:aItems[oCbxPad:nAt]
	oCbxPad:Refresh() 
Else
	nContF8 := 1	
//	oCbxPad:aItems[nContF8]
	oCbxPad:nAt := 1
	cPadr := oCbxPad:aItems[nContF8]	 
	oCbxPad:Refresh()	
Endif 
//Controle para Refresh da GetDados Medicoes
If oFolderFix:nOption == 1
	nPsRow := aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:nRowPos
	If aMedicoes[nPosAmed,nPosGer,1,1] <> 0
		If aMedicoes[nPosAmed,nPosGer,1,1] > 1
			aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:SetFocus()
			aObjetos[ OBJ_MEDICAO_1 ][6]:oBrowse:nRowPos := nPsRow
		Endif	
	Endif
Endif
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontaHea	ºAutor  ³Denis Martins       º Data ³  20/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pela montagem de todos os aHeaders dos diº±±
±±º          ³ferentes tipos de escalas                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA140 / QMTA141 e QMTA142                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MontaHea()
Local cString	:= "QM8_VLRINI|QM8_VLRFIM" 
Local cStrSim	:= "QM8_VLRFIM"
Local aStruQM8 := FWFormStruct(3, "QM8",,.F.)[3]
Local nX 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor Aheader a ser utilizado na getdados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeadPre := {}
aHeadRel := {}
aHeadAtr := {}
aHeadTot := {}
aHeadSim := {}
For nX := 1 To Len(aStruQM8)	
	If aStruQM8[nX,1] $ cStrSim
		Aadd(aHeadSim, Q141GetSX3(aStruQM8[nX,1], "", "", 2) )
	EndIf
	If aStruQM8[nX,1] $ cString
		Aadd(aHeadTot, Q141GetSX3(aStruQM8[nX,1], "", "", 2) )
		Aadd(aHeadPre, Q141GetSX3(aStruQM8[nX,1], QAGetX3Tit(aStruQM8[nX,1]) + STR0031, "", 2) )
		Aadd(aHeadRel, Q141GetSX3(aStruQM8[nX,1], QAGetX3Tit(aStruQM8[nX,1]) + STR0095, "", 2) )
	EndIf
	If aStruQM8[nX,1] == "QM8_VLRIND" .Or. aStruQM8[nX,1] == "QM8_VLRFID"
		Aadd(aHeadPre, Q141GetSX3(aStruQM8[nX,1], QAGetX3Tit(aStruQM8[nX,1]) + STR0032, "", 2) )
		Aadd(aHeadRel, Q141GetSX3(aStruQM8[nX,1], QAGetX3Tit(aStruQM8[nX,1]) + STR0096, "", 2) )
	EndIf
	If aStruQM8[nX,1] $ "QM8_ATRIB "
		Aadd(aHeadAtr, Q141GetSX3(aStruQM8[nX,1], "", "", 2) )
	EndIf
Next nX	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT140TITBºAutor  ³Denis Martins       º Data ³  03/12/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existe incerteza do tipo B.                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA141                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT140TITB(lCad)
Local lRet	:= .T.
Local nx	:= 1	
Default lCad:= .F.

If lCad
	dbSelectArea("QMV")
	dbSetOrder(1)
	If !dbSeek(xFilial("QMV")+oGetItb:aCols[n][1])
		lRet := .F.
		M->QMX_CODINC	:= CriaVar("QMX_CODINC",.F.)
		M->QMX_SIMB		:= CriaVar("QMX_SIMB",.F.)
		M->QMX_FONTE	:= CriaVar("QMX_FONTE",.F.)
		M->QMX_VALINC	:= CriaVar("QMX_VALINC",.F.)
		M->QMX_DISTR	:= CriaVar("QMX_DISTR",.F.)
		M->QMX_DIV		:= CriaVar("QMX_DIV",.F.)
		M->QMX_CSENS	:= CriaVar("QMX_CSENS",.F.)
		M->QMX_UI		:= CriaVar("QMX_UI",.F.)
		M->QMX_VI		:= CriaVar("QMX_VI",.F.)		
	Endif
Endif

If lRet
	For nx := 1 To Len(oGetItb:aCols)
	 //	If oGetItb:aCols[n][1] == oGetItb:aCols[nx][1] .and. n <> 1 .and. !oGetItb:aCols[nx][Len(oGetItb:aCols[nx])]
		If nx <> n .AND. oGetItb:aCols[n][1] == oGetItb:aCols[nx][1] .and. n <> 1 .and. !oGetItb:aCols[nx][Len(oGetItb:aCols[nx])]
			MsgAlert ("Não é permitido incluir  mesma incerteza mais de uma vez!","Aviso")
			lRet := .F.
			If lCad
				M->QMX_CODINC	:= CriaVar("QMX_CODINC",.F.)
				M->QMX_SIMB		:= CriaVar("QMX_SIMB",.F.)
				M->QMX_FONTE	:= CriaVar("QMX_FONTE",.F.)
				M->QMX_VALINC	:= CriaVar("QMX_VALINC",.F.)
				M->QMX_DISTR	:= CriaVar("QMX_DISTR",.F.)
				M->QMX_DIV		:= CriaVar("QMX_DIV",.F.)
				M->QMX_CSENS	:= CriaVar("QMX_CSENS",.F.)
				M->QMX_UI		:= CriaVar("QMX_UI",.F.)
				M->QMX_VI		:= CriaVar("QMX_VI",.F.)		
			Endif
			Exit
		Endif
	Next nx
Endif

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qm141m9   ºAutor  ³Denis Martins       º Data ³  10/31/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA141                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qm141m9()
Local aGetA9 := QM9->(GetArea())
Local aArea  := GetArea()
Local nTamo	 := 0 
Local cTamEsc := GetNewPar("MV_QDECPAD","1") //Considerar o tamanho de casas decimais do padrao(1) ou escala(2)

If aMedicoes[nPosAmed,nPosGer,1,2] = '5'
	If lTamSom	
		dbSelectArea("QM9")
		dbSetOrder(1)
		If dbSeek(xFilial("QM9")+aMedicoes[nPosAmed,nPosEsc])
			Iif(!Empty(AllTrim(QM9->QM9_ESCALI)),nTamo := QA_NumDec(QM9->QM9_ESCALI),nTamo := QA_NumDec(aMedicoes[nPosAMed,nPosEsp]))
				If cTamEsc == "1" .AND. !Empty(AllTrim(QM9->QM9_ESCALI))
					aObjetos[OBJ_MEDICAO_1][12]:Picture :=QMT140Pics(,QM9->QM9_ESCALI,.F.)
				Else
					aObjetos[OBJ_MEDICAO_1][12]:Picture :=QMT140Pics(,aMedicoes[nPosAMed,nPosEsp],.F.)
				EndIf
			aObjetos[OBJ_MEDICAO_1][12]:Show()
		Endif	
	Else
		nTamo := QA_NumDec(aMedicoes[nPosAmed,nPosEsp])
		aObjetos[OBJ_MEDICAO_1][12]:Picture := QMT140Pics(,aMedicoes[nPosAmed,nPosEsp],.F.)
		aObjetos[OBJ_MEDICAO_1][12]:Show()
	Endif
Else
	dbSelectArea("QM9")
	dbSetOrder(1)
	If dbSeek(xFilial("QM9")+aMedicoes[nPosAmed,nPosEsc])
		If cTamEsc == "1" .AND. !Empty(AllTrim(QM9->QM9_ESCALI))
			nTamo := QA_NumDec(QM9->QM9_ESCALI)
			aObjetos[OBJ_MEDICAO_1][12]:Picture :=QMT140Pics(,QM9->QM9_ESCALI,.F.)
		Else
			nTamo:=QA_NumDec(aMedicoes[nPosAMed,nPosEsp])
			aObjetos[OBJ_MEDICAO_1][12]:Picture :=QMT140Pics(,aMedicoes[nPosAMed,nPosEsp],.F.)
		EndIf
		aObjetos[OBJ_MEDICAO_1][12]:Show()
		aObjetos[OBJ_MEDICAO_1][12]:Show()
   	Endif
EndIf

RestArea(aGetA9) 
RestArea(aArea)
Return nTamo

Function qm141BlockObj12()

If ValType(nGetEsp)=="C"
	cVarial := nGetEsp
	nGetEsp:= SuperVal(nGetEsp)
Else                  
	cVarial := StrTran( Str(SuperVal(nGetEsp),10,QA_NUMDEC(aMedicoes[nPosAMed,nPosEsp])),".",",")
EndIf

RetDesPa(aObjetos[OBJ_MEDICAO_1][12],nPosAmed,nGetEsp,@nDesPad)

If ValType(aObjetos[OBJ_MEDICAO_1][12]:cText)=="C"
	aObjetos[OBJ_MEDICAO_1][12]:cText := StrTran( Str(SuperVal(aObjetos[OBJ_MEDICAO_1][12]:cText),10,QA_NUMDEC(aMedicoes[nPosAMed,nPosEsp])),".",",")
EndIf

qm141m9()

If ValType(nGetEsp)=="C"
	aMedicoes[nPosAMed,nPosEsp] := StrTran(Str(SuperVal(nGetEsp)*nCoef,10,QA_NUMDEC(aMedicoes[nPosAMed,nPosEsp])),".",",") 
Else
	aMedicoes[nPosAMed,nPosEsp] := StrTran( Str(nGetEsp*nCoef,10,QA_NUMDEC(aMedicoes[nPosAMed,nPosEsp])),".",",")
EndIf

nGetEsp := StrTran( Str(SuperVal(nGetEsp),10,QA_NUMDEC(aMedicoes[nPosAMed,nPosEsp])),".",",")

Return Nil


//----------------------------------------------------------------------
/*/{Protheus.doc} Q215GetSX3 
Busca dados da SX3 
@author Brunno de Medeiros da Costa
@since 11/04/2018
@version 1.0
@return aHeaderTmp
/*/
//---------------------------------------------------------------------- 
Static Function Q141GetSX3(cCampo, cTitulo, cWhen, nOpc)
Local aHeaderTmp := {}
DEFAULT nOpc := 1
If nOpc == 1
	aHeaderTmp:= {IIf(Empty(cTitulo), QAGetX3Tit(cCampo), cTitulo),;
	              GetSx3Cache(cCampo,'X3_CAMPO'),;
	              GetSx3Cache(cCampo,'X3_PICTURE'),;
	              GetSx3Cache(cCampo,'X3_TAMANHO'),;
	              GetSx3Cache(cCampo,'X3_DECIMAL'),;
	              GetSx3Cache(cCampo,'X3_VALID'),;              
	              GetSx3Cache(cCampo,'X3_USADO'),;
	              GetSx3Cache(cCampo,'X3_TIPO'),;
	              GetSx3Cache(cCampo,'X3_F3'),;
	              GetSx3Cache(cCampo,'X3_CONTEXT'),;
	              QAGetX3Cmb(cCampo),;
	              GetSx3Cache(cCampo,'X3_RELACAO'),;
	              IIf(Empty(cWhen), GetSx3Cache(cCampo, 'X3_WHEN'), cWhen),;
	              GetSx3Cache(cCampo,'X3_VISUAL'),;
	              GetSx3Cache(cCampo,'X3_VLDUSER'),;
	              GetSx3Cache(cCampo,'X3_PICTVAR'),;
	              GetSx3Cache(cCampo,'X3_OBRIGAT') } 
Else
	aHeaderTmp:= {IIf(Empty(cTitulo), QAGetX3Tit(cCampo), cTitulo),;
					GetSx3Cache(cCampo,'X3_CAMPO'),;
					GetSx3Cache(cCampo,'X3_PICTURE'),;
					GetSx3Cache(cCampo,'X3_TAMANHO'),;
					GetSx3Cache(cCampo,'X3_DECIMAL'),;
					GetSx3Cache(cCampo,'X3_VALID'),;
					GetSx3Cache(cCampo,'X3_USADO'),;
					GetSx3Cache(cCampo,'X3_TIPO'),;
					GetSx3Cache(cCampo,'X3_F3'),;
					GetSx3Cache(cCampo,'X3_CONTEXT') } 
EndIf
Return aHeaderTmp


/*/{Protheus.doc} QMTA141GT
//Gatilho de dicionario do campo
//Objeto atualizar a legenda do COMBOBOX oCbxPad  
@author carlos.augusto/marcelo.ferrari
@since 09/05/2019
@version 12.1.23
@return pValor O proprio campo
@type function
/*/
Function QMTA141GT(pValor)
	Local nGot
	Local nValor := pValor
	
	nGot	:= a140bStOption()
	nPosAnt	:= nPosAmed
	/*a141ChanFolder()*/ 
	a141AprPad(oDlgPri,oBmpPad,oBmpEsc)
	
Return nValor

/*/{Protheus.doc} FSomaIncer()
Recalculo das medições considerando as incertezas do tipo B quando existe instrumento relacionado ao padrão secundário.
@type  Static Function
@author Rafael Kleestadt da Cruz
@since 04/03/2020
@version version
@param aMedicoes, array, dados da medição atual
@return aMedicoes, array, dados da mediação recalculados considerando as incertezas do tipo B
@example
(examples)
@see (links_or_references)
/*/
Static Function FSomaIncer(aMedicoes)

Local nX := 0
Local nY := 0
Local nZ := 0
Local aMedBkp := aMedicoes
Local aMedRet := aMedicoes
Local cMtInstBkp := cMtInstr
Local dMtDataBkp := dMtData	

For nX := 1 To Len(aMedBkp)
	For nY := 1 To Len(aMedBkp[nX, 6])
		If !Empty(aMedBkp[nX, 6, nY, 1])
			cMtInstr := aMedBkp[nX, 6, nY, 1] //Instrumento Pad. Secundário
			dMtData	 := aMedBkp[nX, 6, nY, 5] //Data Medição Instrumento Pad. Secundário

			aMedicoes := {}
			
			a140CarMed() //Obtém dados da medição do instrumento pai

			For nZ := 1 To Len(aMedicoes)
				aResult := A140Calc( nZ ) //Calcula resultado da medição por linha
			Next nZ

			nIncertTot := SUPERVAL(aResult[1,5])
			aMedRet[nX,6,nY,3] := STRTRAN(ALLTRIM(STR(SUPERVAL(aMedRet[nX,6,nY,3]) + nIncertTot)),".",",")
			aDel(aMedRet[nX,6,nY],5) //Remove a data
			aSize(aMedRet[nX,6,nY],Len(aMedRet[nX,6,nY])-1) //Restaura tamanho array
		EndIf
	Next nY
Next nX

//Restaura variaveis privadas
aMedicoes := aMedRet //Atualiza aMedicoes
cMtInstr  := cMtInstBkp  
dMtData	  := dMtDataBkp  

Return aMedicoes


Function fFunc(cMtNroCer,oNroCer)

oNroCer:SetPos(0)
aMedicoes[nPosAmed,nPosExt,1,2] := Iif(Empty(cMtNroCer),oNroCer:cText,cMtNroCer) 
oNroCer:Refresh()

Return .T.


/*/{Protheus.doc} QMT141
Função que valida a existencia de aspas simples dos campos do QMT 
@type function
@version  
@author thiago.rover
@since 25/02/2021
@return return_type, return_description
/*/
Static Function QMT141(cValor)

Local nI := 0
	
	For nI:= 1 to len(cValor)
		If cValTOChar(ASC(Substr(cValor,nI,1)) ) $ '39' // ASC(" ' ") Aspas simples
			Return .T.	
		EndIf
	Next nI	

return .F.
