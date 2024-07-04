#include "PMSA320.CH"
#include "protheus.ch"
Static lSQL := Upper(TcSrvType()) != "AS/400" .and. Upper(TcSrvType()) != "ISERIES" .and. ! ("POSTGRES" $ Upper(TCGetDB()))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA320  ³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de apontamentos dos recursos.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Fabio Rogerio ³07/01/02³XXXXXX³Implementado o controle de usuario        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSA320(aRotAuto,nOpcAuto,aGetCpos,cUser)

Local lPMS320Auto := .F.	
Local lContinua   := .T.
Local cFiltro     := ""
Local lPM320FIL   := ExistBlock("PM320FIL")
Local lPMS320FIL  := ExistBlock("PMS320FIL")
Local aFilTopBot  := {'xFilial("AFU")+"1"', 'xFilial("AFU")+"1"'}
Local cFiltraAFU  := 'AFU_FILIAL == "'+xFilial("AFU")+'" .AND. AFU_CTRRVS == "1"'

Default cUser := Nil                             

PMSX3Field("AFU_RECURS", "X3_VALID", 'ExistCpo("AE8")')

If AMIIn(44) .And. !PMSBLKINT()
	If PmsChkAFU(.T.)
		PRIVATE cCadastro	:= STR0015 //"Apontamento de Recursos"
		PRIVATE aRotina := MenuDef()
	
		If nOpcAuto<>Nil
			If nOpcAuto>0 
				If aRotAuto <> NIL .AND. (aGetCpos == NIL .OR. len(aGetCpos) == 0 )
					#IFDEF TOP // VALIDAÇÃO POIS O MENUDEF MUDA DE ACORDO COM O AMBIENTE.
						If (nOpcAuto==3 .or. (nOpcAuto==8 .or. nOpcAuto==9)) // Rotina automatica somente para as opcoes 3,7 e 9 (incluir, alterar e excluir)
							lPMS320Auto := .T.
							aGetCpos := aRotAuto
						Else
							lContinua := .F.
						EndIf
					#ELSE
						If (nOpcAuto==3 .or. (nOpcAuto==7 .or. nOpcAuto==8)) // Rotina automatica somente para as opcoes 3,7 e 8 (incluir, alterar e excluir)
							lPMS320Auto := .T.
							aGetCpos := aRotAuto
						Else
							lContinua := .F.
						EndIf
					#ENDIF
				EndIf
				
				If lContinua 
					dbSelectArea("AFU")
					bBlock := &( "{ |x,y,z,k,w,a,b,c| lContinua := " + aRotina[ nOpcAuto,2 ] + "(x,y,z,k,w,a,b,c) }" )
					Eval( bBlock,Alias(),AFU->(Recno()),nOpcAuto,,,aGetCpos,lPMS320Auto,cUser )
				EndIf
			EndIf
		Else
			//
			//	PE para realizar o filtro no arquivo AFU antes de apresentar na browse.
			//
			If lPM320FIL
				cFiltro:=ExecBlock("PM320FIL", .F., .F.)
				If ValType(cFiltro ) == "C" .and. !Empty(cFiltro)
					DbSelectArea("AFU")
					Set Filter to &cFiltro
					AFU->(DbGotop())
				EndIf
			EndIf

			If lPMS320Fil
				aFilTopBot := aClone(ExecBlock("PMS320Fil",.F.,.F., aFilTopBot ))
		 		mBrowse( 6, 1,22,75,"AFU",,,,,,,aFilTopBot[1] , aFilTopBot[2])
			Else
				// Instanciamento da Classe de Browse
				oBrowse := FWMBrowse():New()
				// Definição da tabela do Browse
				oBrowse:SetAlias('AFU')
				
				// Definição de filtro
				If lPM320FIL
					oBrowse:SetFilterDefault( cFiltro )
				Else
					oBrowse:SetFilterDefault( cFiltraAFU )
				EndIf
				
				// Titulo da Browse
				oBrowse:SetDescription(cCadastro)
				// Opcionalmente pode ser desligado a exibição dos detalhes
				oBrowse:DisableDetails()
				// Ativação da Classe
				oBrowse:Activate()
				
			EndIf
				
			dbClearFilter()

		EndIf
	EndIf
EndIf
Return( lContinua ) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms320Psq³ Autor ³ Edson Maricate         ³ Data ³ 24-10-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta uma tela de pesquisa no Browse .                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms320Psq(cAlias,nRecNo,nOpcx)
Local aPesq     := {}
Local aArea     := GetArea()
Local cDescri   := ""
Local cAux		:= ""
Local nIndex    := 0
Local nRet      := 0

DEFAULT cAlias := Alias()
                   
dbSelectArea("SIX")
dbSetOrder(1)
dbSeek(cAlias)
While SIX->(!Eof()) .AND. SIX->INDICE == cAlias

	If SIX->SHOWPESQ =="S"

		// retira o campo AFU_CTRRVS dos índices do AFU
		cAux := SixDescricao()
		cDescri := Substr(cAux, At("+", cAux) + 1)
		
		If IsDigit(SIX->ORDEM)
			nIndex  := Val(SIX->ORDEM)
		Else
			nIndex  := Asc(SIX->ORDEM)-55
		EndIf
		
		aAdd( aPesq ,{cDescri ,nIndex } )
	
    EndIf
	
	SIX->(dbSkip())
EndDo

RestArea(aArea)

nRet := WndxPesqui(,aPesq,xFilial()+"1",.F.)
Return nRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms320Dlg³ Autor ³ Edson Maricate         ³ Data ³ 24-10-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de manipuacao dos apontamentos de recursos.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA320                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms320Dlg(cAlias,nRecNo,nOpcx,xRes1,xRes2,aGetCpos,lAuto,cUser,l710Estorna)
Local oDlg
Local nRecAFU
Local aCampos
Local lOk			:= .F.
Local lContinua		:= .T.
Local l320Inclui	:= .F.
Local l320Visual	:= .F.
Local l320Altera	:= .F.
Local l320Exclui	:= .F.
Local nX			:= 0
Local dDataFec 	:= MVUlmes()
Local cTpApont    := ""
Local cEDTPai := ""
Local lRejeicao	:= AF8->AF8_PAR002=="1" .Or. AF8->AF8_PAR002=="2"
Local lPM320INC := ExistBlock("PM320INC")
Local lPM320ALT := ExistBlock("PM320ALT")
Local lPM320EXC := ExistBlock("PM320EXC")

PRIVATE nRecAlt		:= 0
PRIVATE l320		:= .T.

Default cUser := Nil
Default l710Estorna := .F.

// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
If !lAuto
	Do Case
		Case aRotina[nOpcx][4] == 2
			l320Visual  := .T.
			Visual 		:= .T.
			Inclui 		:= .F.
			Altera 		:= .F.
			Exclui 		:= .F.
		Case aRotina[nOpcx][4] == 3
			l320Inclui	:= .T.
			Visual 		:= .F.
			Inclui 		:= .T.
			Altera 		:= .F.
			Exclui 		:= .F.
		Case aRotina[nOpcx][4] == 4
			l320Altera	:= .T.
			Visual 		:= .F.
			Inclui 		:= .F.
			Altera 		:= .T.
			Exclui 		:= .F.
			nRecAlt		:= AFU->(RecNo())
		Case aRotina[nOpcx][4] == 5
			l320Exclui	:= .T.
			l320Visual	:= .T.
			Visual 		:= .F.
			Inclui 		:= .F.
			Altera 		:= .F.
			Exclui 		:= .F.		
	EndCase
Else       
	// Rotina automatica somente para as opcoes 3,8 e 9 (incluir, alterar e excluir)
	#IFDEF TOP // VALIDAÇÃO POIS O MENUDEF MUDA DE ACORDO COM O AMBIENTE.
		Do Case
			Case nOpcx	 == 3
				l320Inclui	:= .T.
				Visual 		:= .F.
				Inclui 		:= .T.
				Altera 		:= .F.
				Exclui 		:= .F.
			Case nOpcx	 == 8
				l320Altera	:= .T.
				Visual 		:= .F.
				Inclui 		:= .F.
				Altera 		:= .T.
				Exclui 		:= .F.
				nRecAlt		:= AFU->(RecNo())
			Case nOpcx	 == 9
				l320Exclui	:= .T.
				If l710Estorna
					l320Visual	:= .F.
				Else
					l320Visual	:= .T.
				EndIf
				Visual 		:= .F.
				Inclui 		:= .F.
				Altera 		:= .F.
				Exclui 		:= .T.		
		EndCase
	#ELSE
		Do Case
		Case nOpcx	 == 3
			l320Inclui	:= .T.
			Visual 		:= .F.
			Inclui 		:= .T.
			Altera 		:= .F.
			Exclui 		:= .F.
		Case nOpcx	 == 7
			l320Altera	:= .T.
			Visual 		:= .F.
			Inclui 		:= .F.
			Altera 		:= .T.
			Exclui 		:= .F.
			nRecAlt		:= AFU->(RecNo())
		Case nOpcx	 == 8
			l320Exclui	:= .T.
			l320Visual	:= .T.
			Visual 		:= .F.
			Inclui 		:= .F.
			Altera 		:= .F.
			Exclui 		:= .T.		
		EndCase
	#ENDIF
Endif

// carrega as variaveis de memoria
RegToMemory("AFU",l320Inclui)

If Len(M->AFU_HORAI) == 4 //Hora formatada errada "10:01" (Len = 5) -> "10:1" (Len = 4)
	M->AFU_HORAI := aGetCpos[aScan(aGetCpos,{|x|AllTrim(x[1])=="AFU_HORAI"})][2]
EndIf

If Len(M->AFU_HORAF) == 4 //Hora formatada errada "10:01" (Len = 5) -> "10:1" (Len = 4)
	M->AFU_HORAF := aGetCpos[aScan(aGetCpos,{|x|AllTrim(x[1])=="AFU_HORAF"})][2]
EndIf
// tratamento do array aGetCpos com os campos Inicializados do AFU
If aGetCpos <> Nil
	aCampos	:= {}
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AFU")
	While !Eof() .and. SX3->X3_ARQUIVO == "AFU"
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nPosCpo	:= aScan(aGetCpos,{|x| x[1]==Alltrim(X3_CAMPO)})
			If nPosCpo > 0
				If aGetCpos[nPosCpo][3]
					aAdd(aCampos,AllTrim(X3_CAMPO))
				EndIf
			Else
				aAdd(aCampos,AllTrim(X3_CAMPO))
			EndIf
		EndIf
		dbSkip()
	End
	For nX := 1 to Len(aGetCpos)
		cCpo	:= "M->"+Trim(aGetCpos[nX][1])
		&cCpo	:= aGetCpos[nX][2]
	Next nX
	
EndIf

If !Empty(M->AFU_PROJET) .and. (!l320Visual .OR. l320Exclui)
	If !PmsVldFase("AF8", M->AFU_PROJET, "86")
		lContinua := .F.
	EndIf
EndIf 
                   
// verificar data do ultimo fechamento do Projeto
If lContinua .AND. (l320Altera .Or. l320Exclui)
	AF8->(dbSetOrder(1))
	If AF8->(MsSeek(xFilial()+M->AFU_PROJET))
		If !Empty(AF8->AF8_ULMES) .and. (DTOS(AF8->AF8_ULMES) >= dtos(M->AFU_DATA))
			Aviso(STR0025 ,STR0051 + DTOC(AF8->AF8_ULMES) + STR0052,{STR0027 },2)  //"Operacao Invalida" ## "Esta operacao nao podera ser efetuada pois este projeto ja esta fechado com data " ## ". Verifique o apontamento selecionado." ## "Fechar"
			lContinua :=.F.
		EndIf
	EndIf
EndIf

If lContinua .and. l320Exclui .and. AFU->AFU_PREREC == "1" .and. !l710Estorna
	Aviso(STR0015 ,STR0067 ,{"Ok"},2) //"Apontamento de Recursos" //"Apontamento de Recursos não pode ser excluido, pois foi gerado a partir de um pré-apontamento."
	lContinua	:=.F.
EndIf

If lContinua .AND. !l320Inclui
	If !SoftLock("AFU")
		lContinua := .F.
	Else
		nRecAFU := AFU->(RecNo())
	Endif

	// verifica os direitos do usuario
	Do Case
		Case l320Visual .and. !l320Exclui
			If !PmsChkUser(AFU->AFU_PROJET,AFU->AFU_TAREFA,,"",2,"RECURS",AFU->AFU_REVISA,cUser,.F.)
				Aviso(STR0058,STR0059,{STR0060},2)
				lContinua	:=.F.
			EndIf
		Case l320Altera
			If !PmsChkUser(AFU->AFU_PROJET,AFU->AFU_TAREFA,,"",3,"RECURS",AFU->AFU_REVISA,cUser,.F.)
				Aviso(STR0058,STR0059,{STR0060},2)
				lContinua	:=.F.
			EndIf
		Case l320Exclui
			If !PmsChkUser(AFU->AFU_PROJET,AFU->AFU_TAREFA,,"",4,"RECURS",AFU->AFU_REVISA,cUser,.F.)
				Aviso(STR0058,STR0059,{STR0060},2)
				lContinua	:=.F.
			EndIf
	EndCase
EndIf

If l320Exclui .And. lPM320EXC
	lContinua := ExecBlock("PM320EXC", .F., .F. )
EndIf	


If lContinua
	// se a rotina nao for automatica, mostra a tela	
	If !lAuto
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO TranslateBottom(.F.,28),80 OF oMainWnd
			oEnch := MsMGet():New("AFU",AFU->(RecNo()),nOpcx,,,,,{,,(oDlg:nClientHeight - 24)/2,},aCampos,3,,,,oDlg)
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||Iif(Pms320Vld(oEnch ,l320Exclui ,,M->AFU_HORAF,,,l320Visual) ,(oDlg:End(),lOk:=.T.) ,NIL)},{||oDlg:End()})

	//
	// Eh uma rotina automatica
	//
	Else
		Private aTELA[0][0]
		Private aGETS[0]
		Private aAutoCab := aclone(aGetCpos)
		
		// se for visualizacao, nao deve validar campos.
		If l320Visual .AND. (!l320Inclui .AND. !l320Altera .AND. !l320Exclui)
			lOk := .F.
		Else
			If EnchAuto(cAlias,aAutoCab,{|| Obrigatorio(aGets,aTela) .And. Pms320Vld(,l320Exclui ,M->AFU_HORAI,M->AFU_HORAF,,.T.,l320Visual) .And. iIf(!l320Exclui,PMS320Grv() .And. PMS300HRI(M->AFU_HORAI) .And. PMS300HRF(M->AFU_HORAF),.T.) },nOpcx)
				lOk := .T.
			EndIf
		EndIf
	EndIf
EndIf

If lOk .And. (l320Inclui .Or. l320Altera .Or. l320Exclui)
	If l320Inclui 

		cEDTpai := PMSReadValue("AF9", 1, ;
		                        xFilial("AF9") + M->AFU_PROJET + M->AFU_REVISA + M->AFU_TAREFA, ;
		                        "AF9_EDTPAI", "")

		// verifica os direitos do usuario na inclusao
		If !PmsChkUser(M->AFU_PROJET,M->AFU_TAREFA,,cEDTPai,3,"RECURS",M->AFU_REVISA,cUser)
			Aviso(STR0058,STR0059,{STR0060},2)
			lContinua	:=.F.
		EndIf
		If lContinua .And. lPM320INC
			lContinua := ExecBlock("PM320INC", .F., .F. )
		EndIf
	ElseIf l320Altera

		cEDTpai := PMSReadValue("AF9", 1, ;
		                        xFilial("AF9") + AFU->AFU_PROJET + AFU->AFU_REVISA + AFU->AFU_TAREFA, ;
		                        "AF9_EDTPAI", "")

		// verifica os direitos do usuario na alteracao
		If !PmsChkUser(AFU->AFU_PROJET,AFU->AFU_TAREFA,,cEDTPai,3,"RECURS",AFU->AFU_REVISA,cUser)
			Aviso(STR0058,STR0059,{STR0060},2)
			lContinua	:=.F.
		EndIf

		If lContinua .And. lPM320ALT
			lContinua := ExecBlock("PM320ALT", .F., .F. )
		EndIf
	EndIf
	If lContinua    
		cTpApont := Posicione("AE8",1,xFilial("AE8")+M->AFU_RECURS,"AE8_TPREAL")                             
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apenas verifica esta condição caso o tipo de recurso (AE8_TPREAL) esteja configurado como (1=Custo Medio/FIFO)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If dDataFec >= dDataBase .AND. cTpApont == "1" // tipo apontamento 1=Custo Medio/FIFO
			Help ( " ", 1, "FECHTO" )
			lContinua := .F.
		EndIf	
		
		AF8->(dbSetOrder(1))
		AF8->(MsSeek(xFilial("AF8")+M->AFU_PROJET))
		lRejeicao := AF8->AF8_PAR002=="1" .Or. AF8->AF8_PAR002=="2"
		//If lContinua .And. lRejeicao
			/*If !l320Inclui
				If Pms320ChkA( AFU->AFU_PROJET, AFU->AFU_REVISA, AFU->AFU_TAREFA, AFU->AFU_RECURS, AFU->AFU_DATA, AFU->AFU_HORAF, AFU->AFU_HQUANT)
					Aviso(STR0065,STR0088,{STR0060},2) //"Apontamento de Recurso"##"Operação não permitida, pois existem apontamentos de outros recursos posteriores a data e hora informadas"##"Ok"
					lContinua := .F.
				EndIf
			EndIf
			If lContinua
				If Pms320ChkA( M->AFU_PROJET, M->AFU_REVISA, M->AFU_TAREFA, M->AFU_RECURS, M->AFU_DATA, M->AFU_HORAF, M->AFU_HQUANT)
					Aviso(STR0065,STR0088,{STR0060},2) //"Apontamento de Recurso"##"Operação não permitida, pois existem apontamentos de outros recursos posteriores a data e hora informadas"##"Ok"
					lContinua := .F.
				EndIf
			EndIF*/
		//EndIf
		
		If lContinua
			Begin Transaction   
				Pms320Grava(nRecAFU,l320Exclui)
			End Transaction
		EndIf
	EndIf
EndIf

Return( lContinua .and. lOk )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms320Grava³ Autor ³ Edson Maricate       ³ Data ³ 24-10-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a gravacao do apontamento do recurso.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA320                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms320Grava(nRecAFU,lDeleta,lAvalAFU1,lAvalAFU2,aConfig,aIgnora)

Local lAltera	:= (nRecAFU!=Nil)
Local bCampo 	:= {|n| FieldName(n) }
Local nX		:= 0
Local nHorasTot	:= 0
Local aArea
Local aAreaAF9
Local aAreaAFA
Local aAreaAFU
Local lRejeicao	:= AF8->AF8_PAR002=="1" .Or. AF8->AF8_PAR002=="2"
Local nHrsRegra
Local cHoraIni
Local cHoraFim
Local aRet
Local aApont
Local nRetrab
Local aAux
Local lPMDelAFU	:= ExistBlock("PMDelAFU")
Local lPMExRegr := ExistBlock("PMExRegr")
Local lExecRegr	:= .T.
Local lValido
Local cAN3Tipo
Local cHrFimDg

Private nHoras		:= 0
Private nSaldo		:= 0
Private nApont		:= 0
Private cRespAtu	:= ''
Private cRespAnt	:= ''

DEFAULT lAvalAFU1	:= .T.
DEFAULT lAvalAFU2	:= .T.
DEFAULT aIgnora		:= {}
                
If !lDeleta

	// Verifica se o controle de rejeicao esta ativo para executar as regras de apontamento
	If lRejeicao
		aArea := GetArea()
		aAreaAF9 := AF9->(GetArea())
		aAreaAFA := AFA->(GetArea())
        
        // Busca Responsavel da tarefa
		cRespAtu := ""
		Dbselectarea("AFA")
		Dbsetorder(1)
		AFA->( MsSeek(xfilial("AFA")+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA) )
		Do While !AFA->(Eof()) .And. AFA->(AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA)==xfilial("AFA")+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA
			If !empty(AFA->AFA_RECURS) .And. AFA->AFA_RESP=="1"
				cRespAtu:=AFA->AFA_RECURS
			EndIf
			AFA->(dbSkip())
		EndDo
		
		// Verifica a quantidade de horas apontadas na tarefa
		nApont := 0
		Dbselectarea("AFU")
		Dbsetorder(1)
		AFU->( MsSeek(xfilial("AFU")+"1"+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA) )
		Do While !AFU->(Eof()) .And. AFU->(AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA)==xfilial("AFU")+"1"+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA
			If AScan( aIgnora, AFU->(Recno()) ) == 0
				nApont := nApont + AFU->AFU_HQUANT
			EndIf
			AFU->(dbSkip())
		EndDo

        // Verifica quantidade de horas de retrabalho da tarefa
        nRetrab := 0
		dbselectarea("AN2")
		dbsetorder(2) //AN2_FILIAL+AN2_CTRRVS+AN2_PROJET+AN2_REVISA+AN2_TAREFA+DTOS(AN2_DATA)+AN2_RECURS
		AN2->( MsSeek(xfilial("AN2")+"1"+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA) )
		Do While !AN2->(Eof()) .And. AN2->(AN2_FILIAL+AN2_CTRRVS+AN2_PROJET+AN2_REVISA+AN2_TAREFA)==xFilial("AN2")+"1"+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA
			nRetrab := nRetrab + AN2->AN2_HQUANT
			AN2->(dbSkip())
		EndDo
		
		// Verifica os apontamentos apos o apontamento que esta sendo incluido
		// Os apontamentos posteriores nao sao contabilizados pois serao refeitos apos a inclusao
		aApont := {}
		Dbselectarea("AFU")
		Dbsetorder(5) //AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA+DTOS(AFU_DATA)+AFU_RECURS
		AFU->( MsSeek(xfilial("AFU")+"1"+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA) )
		Do While !AFU->(Eof()) .And. AFU->(AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA)==xfilial("AFU")+"1"+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA
			If AFU->AFU_RECURS == M->AFU_RECURS .And. AFU->(DTOS(AFU_DATA)+AFU_HORAI) > M->(DTOS(AFU_DATA)+AFU_HORAF) .And. AScan( aIgnora, AFU->(Recno()) ) == 0
				nApont := nApont - AFU->AFU_HQUANT
				AADD(aApont, {AFU->(Recno()), AFU->AFU_DATA, AFU->AFU_HORAI})
				dbSelectArea("AN2")
				AN2->(dbSetOrder(1)) //AN2_FILIAL+AN2_CTRRVS+AN2_PROJET+AN2_REVISA+AN2_TAREFA+AN2_RECURS+DTOS(AN2_DATA)
				If AN2->(MsSeek( AFU->(AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA+AFU_RECURS+DTOS(AFU_DATA)) ))
					nRetrab := nRetrab - AN2->AN2_HQUANT
					RecLock("AN2",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
				dbSelectArea("AFU")
			EndIf
			AFU->(dbSkip())
		EndDo

		AF9->(DbSetOrder(1))
		AF9->(MsSeek( xFilial("AF9")+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA ))
		AFA->(DbSetOrder(5))
		AFA->(MsSeek( xFilial("AFA")+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA+M->AFU_RECURS ))
		
		nHorasTot := AF9->AF9_HDURAC
		
		nHoras := M->AFU_HQUANT
		nSaldo := nHorasTot - nApont
		cRespAnt := PegaRespAnt( AF9->AF9_ACAO, AF9->AF9_REVACA, AF9->AF9_TPACAO )
		If AF8->AF8_PAR002=="1"
			nApont := PegApontAnt( AF9->AF9_ACAO, AF9->AF9_REVACA, AF9->AF9_TPACAO )
		EndIf
		nApont := nApont - nRetrab
		
		cHoraIni := M->AFU_HORAI
		cHrFimDg := M->AFU_HORAF
		
		// Alteracao deve excluir os registros da AN2
		If lAltera
			AFU->(dbGoTo(nRecAFU))
			dbSelectArea("AN2")
			AN2->(dbSetOrder(1)) //AN2_FILIAL+AN2_CTRRVS+AN2_PROJET+AN2_REVISA+AN2_TAREFA+AN2_RECURS+DTOS(AN2_DATA)
			If AN2->(MsSeek( AFU->(AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA+AFU_RECURS+DTOS(AFU_DATA)) ))
				RecLock("AN2",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
			dbSelectArea("AFU")
		EndIf
		
		If nHoras == 0
			M->AFU_TPHORA := "1"
			Pms320GvAux(nRecAFU,lAvalAFU1,lAvalAFU2,aConfig)
			If lAltera
				nRecAFU := nil
			EndIf
		Else
			dbSelectArea("AN3")
			dbSetOrder(1)
			AN3->(dbSeek(xFilial("AN3")))
			Do While nHoras>0 .And. !AN3->(Eof()) .And. AN3->AN3_FILIAL == xFilial("AN3")
				lValido :=  .F.				
				If &(AN3->AN3_REGRA)
					lValido := .T.
					nHrsRegra := &(AN3->AN3_HORAS)
					cAN3Tipo := AN3->AN3_TIPO
				EndIf
				AN3->(dbSkip())
				If lValido					
					nHoras := nHoras - nHrsRegra
					nSaldo := nSaldo - nHrsRegra
					If nSaldo < 0 .And. nApont > 0
						nApont := nApont - nHrsRegra
					EndIf
					If (nHoras>0 .And. !AN3->(Eof()) .And. AN3->AN3_FILIAL == xFilial("AN3"))
						aRet := PMSDTaskF(M->AFU_DATA,cHoraIni,AF9->AF9_CALEND,nHrsRegra,M->AFU_PROJET,M->AFU_RECURS)
						cHoraF := aRet[4]
					Else
						cHoraF := cHrFimDg
					EndIf
					M->AFU_HORAI  := cHoraIni
					M->AFU_HORAF  := cHoraF
					M->AFU_HQUANT := nHrsRegra
					M->AFU_TPHORA := cAN3Tipo
					Pms320GvAux(nRecAFU,lAvalAFU1,lAvalAFU2,aConfig)
					If lAltera
						nRecAFU := nil
					EndIf
					cHoraIni := cHoraF
				EndIf
			EndDo
		EndIf

		aAreaAFU := AFU->(GetArea())
		aSort(aApont,,, {|x, y| DTOS(x[2]) + x[3] < DTOS(y[2]) + y[3] })
		aAux := {}
		AEval( aApont, { |x| AAdd( aAux, x[1] ) } )
		
		// Refaz os apontamentos apos o apontamento incluido/alterado
		For nX := 1 to Len(aAux)
			AFU->(dbGoTo(aAux[nX]))
			RegToMemory("AFU",.F.)
			Pms320Grava(AFU->(Recno()),.F.,lAvalAFU1,lAvalAFU2,aConfig,aAux)
			aAux[nX]:=nil
		Next

		RestArea(aAreaAFU)

		RestArea(aAreaAF9)
		RestArea(aAreaAFA)
		RestArea(aArea)

	Else
		Pms320GvAux(nRecAFU,lAvalAFU1,lAvalAFU2,aConfig)
	EndIf
	
Else
	AFU->(dbGoto(nRecAFU))
	
	If lPMDelAFU
		ExecBlock("PMDelAFU", .F., .F., { nRecAFU })
	EndIf	
	       
	If lAvalAFU2
		PmsAvalAFU("AFU",2)
		PmsAvalAFU("AFU",3)
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms320GvAux³ Autor ³ Marcelo Akama        ³ Data ³ 20-07-2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a gravacao do apontamento do recurso.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA320                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pms320GvAux(nRecAFU,lAvalAFU1,lAvalAFU2,aConfig)

Local lAltera	:= (nRecAFU!=Nil)
Local bCampo 	:= {|n| FieldName(n) }
Local nX		:= 0
Local nHorasTot	:= 0
Local cAssunto
Local cMsg
Local cTo
Local cCC
Local aApontAnt
Local nApontAnt
Local nHoras
Local nPos
Local aRet
Local aAreaAF9
Local aAreaAFU
Local lPM320GRV := ExistBlock("PM320GRV")
Local lPMSGrvAFU := ExistBlock("PMSGrvAFU")

DEFAULT lAvalAFU1	:= .T.
DEFAULT lAvalAFU2	:= .T.

If lAltera
	dbSelectArea("AFU")
	dbGoto(nRecAFU)
	If lAvalAFU2
		PmsAvalAFU("AFU",2)	
	EndIf
	RecLock("AFU",.F.)
Else
	dbSelectArea("AFU")
	RecLock("AFU",.T.)
EndIf
For nx := 1 TO FCount()
	FieldPut(nx,M->&(EVAL(bCampo,nx)))
Next nx
AFU->AFU_FILIAL	:= xFilial("AFU")
AFU->AFU_CTRRVS	:= "1"
MsUnlock()
MSMM(,TamSx3("AFU_OBS")[1],,M->AFU_OBS,1,,,"AFU","AFU_CODMEM")

If aConfig<>nil .And. lPM320GRV
	ExecBlock("PM320GRV", .F., .F.,{@aConfig})
EndIf      			

If lAvalAFU1
	PmsAvalAFU("AFU",1)
EndIf

If lPMSGrvAFU
	ExecBlock("PMSGrvAFU", .F., .F., {	AFU->AFU_FILIAL,AFU->AFU_CTRRVS,;
										AFU->AFU_PROJET,AFU->AFU_REVISA,;
										AFU->AFU_TAREFA,AFU->AFU_RECURS,;
										AFU->AFU_DATA	})
EndIf

MsUnlock()

If AFU->AFU_TPHORA == "3" .And. AF9->AF9_REVACA > "00"
	aApontAnt := {}
	nApontAnt := 0
	aAreaAF9 := AF9->(GetArea())
	aAreaAFU := AFU->(GetArea())
	dbselectarea("AF9")
	dbsetorder(6)
	If AF9->(MsSeek(xfilial("AF9")+AF9->AF9_ACAO+strzero(val(AF9->AF9_REVACA)-1,2)+AF9->AF9_TPACAO))
		Dbselectarea("AFU")
		Dbsetorder(5) //AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA+DTOS(AFU_DATA)+AFU_RECURS
		AFU->( MsSeek(xfilial("AFU")+"1"+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA) )
		Do While !AFU->(Eof()) .And. AFU->(AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA)==xfilial("AFU")+"1"+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
			If AFU->AFU_RECURS == cRespAnt
				nApontAnt += AFU->AFU_HQUANT
			Else
				nX := Len(aApontAnt)
				
				If nX > 0
					If aApontAnt[nX][1]<>AFU->AFU_RECURS
						nX := 0
					EndIF
				EndIf
				
				If nX > 0
					aApontAnt[nX][2] := aApontAnt[nX][2]+AFU->AFU_HQUANT
				Else
					AADD(aApontAnt, {AFU->AFU_RECURS, AFU->AFU_HQUANT})
				EndIF
			EndIf
			AFU->(dbSkip())
		EndDo
	EndIf
	RestArea(aAreaAF9)
	RestArea(aAreaAFU)
	
	nPos := Len(aApontAnt)
	dbselectarea("AN2")
	dbsetorder(2) //AN2_FILIAL+AN2_CTRRVS+AN2_PROJET+AN2_REVISA+AN2_TAREFA+DTOS(AN2_DATA)+AN2_RECURS
	MsSeek(xFilial("AN2")+AFU->(AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA))
	Do While !AN2->(Eof()) .And. xFilial("AN2")+AFU->(AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA)==AN2->(AN2_FILIAL+AN2_CTRRVS+AN2_PROJET+AN2_REVISA+AN2_TAREFA)
	    If nApontAnt >= AN2->AN2_HQUANT
	    	nApontAnt := nApontAnt - AN2->AN2_HQUANT
	    Else
	    	nHoras := AN2->AN2_HQUANT - nApontAnt
	    	nApontAnt := 0
	    	Do While nPos>0 .And. nHoras>0
	    		If aApontAnt[nPos][2] > nHoras
	    			aApontAnt[nPos][2] := aApontAnt[nPos][2] - nHoras
	    			nHoras := 0
	    		Else
	    			nHoras := nHoras - aApontAnt[nPos][2]
	    			aApontAnt[nPos][2] := 0
	    			nPos--
	    		EndIf
	    	EndDo
	    EndIf
		AN2->(dbSkip())
	EndDo

	If nApontAnt >= AFU->AFU_HQUANT
		dbSelectArea("AN2")
		RecLock("AN2",.T.)
		AN2->AN2_FILIAL	:= xFilial("AN2")
		AN2->AN2_CTRRVS	:= AFU->AFU_CTRRVS
		AN2->AN2_PROJET	:= AFU->AFU_PROJET
		AN2->AN2_REVISA	:= AFU->AFU_REVISA
		AN2->AN2_TAREFA	:= AFU->AFU_TAREFA
		AN2->AN2_RECURS	:= AFU->AFU_RECURS
		AN2->AN2_DOCUME	:= AFU->AFU_DOCUME
		AN2->AN2_DATA	:= AFU->AFU_DATA
		AN2->AN2_HORAI	:= AFU->AFU_HORAI
		AN2->AN2_HORAF	:= AFU->AFU_HORAF
		AN2->AN2_HQUANT	:= AFU->AFU_HQUANT
		AN2->AN2_RECORI	:= cRespAnt
		MsUnlock()
	Else
		nHoras := AFU->AFU_HQUANT - nApontAnt

		If nApontAnt >0
			dbSelectArea("AN2")
			RecLock("AN2",.T.)
			AN2->AN2_FILIAL	:= xFilial("AN2")
			AN2->AN2_CTRRVS	:= AFU->AFU_CTRRVS
			AN2->AN2_PROJET	:= AFU->AFU_PROJET
			AN2->AN2_REVISA	:= AFU->AFU_REVISA
			AN2->AN2_TAREFA	:= AFU->AFU_TAREFA
			AN2->AN2_RECURS	:= AFU->AFU_RECURS
			AN2->AN2_DOCUME	:= AFU->AFU_DOCUME
			AN2->AN2_DATA	:= AFU->AFU_DATA
			AN2->AN2_HORAI	:= AFU->AFU_HORAI
			AN2->AN2_HORAF	:= AFU->AFU_HORAF
			AN2->AN2_HQUANT	:= nApontAnt
			AN2->AN2_RECORI	:= cRespAnt
			MsUnlock()
        EndIf

    	nApontAnt := 0
    	Do While nPos>0 .And. nHoras>0
			dbSelectArea("AN2")
			RecLock("AN2",.T.)
			AN2->AN2_FILIAL	:= xFilial("AN2")
			AN2->AN2_CTRRVS	:= AFU->AFU_CTRRVS
			AN2->AN2_PROJET	:= AFU->AFU_PROJET
			AN2->AN2_REVISA	:= AFU->AFU_REVISA
			AN2->AN2_TAREFA	:= AFU->AFU_TAREFA
			AN2->AN2_RECURS	:= AFU->AFU_RECURS
			AN2->AN2_DOCUME	:= AFU->AFU_DOCUME
			AN2->AN2_DATA	:= AFU->AFU_DATA
			AN2->AN2_HORAI	:= AFU->AFU_HORAI
			AN2->AN2_HORAF	:= AFU->AFU_HORAF
			AN2->AN2_RECORI	:= aApontAnt[nPos][1]

    		If aApontAnt[nPos][2] > nHoras
				AN2->AN2_HQUANT	:= nHoras
    			aApontAnt[nPos][2] := aApontAnt[nPos][2] - nHoras
    			nHoras := 0
    		Else
				AN2->AN2_HQUANT	:= aApontAnt[nPos][2]
    			nHoras := nHoras - aApontAnt[nPos][2]
    			aApontAnt[nPos][2] := 0
    			nPos--
    		EndIf

			MsUnlock()
    	EndDo
	EndIf

EndIf


If AFU->AFU_TPHORA == "2" .Or. AFU->AFU_TPHORA == "3"
	// Localiza o evento de notificacao do projeto
	DbSelectArea("AN6")
	AN6->( DbSetOrder(1) )
	AN6->( DbSeek( xFilial("AN6") + AFU->AFU_PROJET + "000000000000004" ) )
	Do While !AN6->(Eof()) .And. xFilial("AN6") + AFU->AFU_PROJET == AN6->( AN6_FILIAL + AN6_PROJET ) .And. AN6->AN6_EVENT == "000000000000004"
		// Se o campo funcao de usuario estiver preenchido deve Macroexecutar
		If !Empty( AN6->AN6_USRFUN )
			&(AN6->AN6_USRFUN)
		EndIf

		// Obtem o assunto da notificacao
		cAssunto := STR0084 // "Notificação de Evento - Horas Excedidas"
		If !Empty( AN6->AN6_ASSUNT )
			cAssunto := AN6->AN6_ASSUNT
		EndIf

		// macro executa para obter o titulo
		If Left( AllTrim( AN6->AN6_ASSUNT ), 1 ) = "="
			cAssunto := Right( cAssunto, Len( cAssunto ) -1 )
			cAssunto := &(cAssunto)
		EndIf

		// Obtem o destinatario
		cTo	:= PASeekPara( AFU->AFU_RECURS, AN6->AN6_PARA )
		cCC	:= PASeekPara( AFU->AFU_RECURS, AN6->AN6_COPIA )

		// Cria a mensagem
		cMsg := AN6->AN6_MSG

		// macro executa para obter a mensagem
		If Left( AllTrim( AN6->AN6_MSG ), 1 ) = "="
			cMsg := Right( cMsg, Len( cMsg ) -1 )
			cMsg := &(cMsg)
		EndIf

        //Deve ser gerada uma notificação de evento do projeto encaminhando um e-mail para o superior do recurso;
		If !Empty( cTO )
			PMSSendMail(	cAssunto,; 						// Assunto
							cMsg,;							// Mensagem
							cTO,;							// Destinatario
							cCC,;							// Destinatario - Copia
							.T. )							// Se requer dominio na autenticacao
		EndIf

		AN6->( DbSkip() )

	EndDo
EndIf

Return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS320Data³ Autor ³ Edson Maricate        ³ Data ³ 29/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a data em relacao a data do Ultimo fechamento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMS320                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms320Data()
Local lRet   := .T.

// verificar data do ultimo fechamento do Projeto
If l320
	AF8->(dbSetOrder(1))
	AF8->(MsSeek(xFilial() + M->AFU_PROJET))
		
		If AF8->AF8_ULMES >= M->AFU_DATA
			Aviso(STR0025, STR0051 + DTOC(AF8->AF8_ULMES) + STR0052, {STR0027 }, 2)  //"Operacao Invalida" ## "Esta operacao nao podera ser efetuada pois este projeto ja esta fechado com data " ## ". Verifique o apontamento selecionado." ## "Fechar"
			lRet:=.F.
		EndIf
	

	If lRet
		M->AFU_HQUANT	:= 0
		M->AFU_HORAI	:= Space(Len(M->AFU_HORAI))
		M->AFU_HORAF	:= Space(Len(M->AFU_HORAF))
	EndIf
Else
	AF8->(dbSetOrder(1))
	AF8->(MsSeek(xFilial() + aCols[n, aScan(aHeader,{|x|Alltrim(x[2])=="AFU_PROJET"})]))

		If AF8->AF8_ULMES >= M->AFU_DATA
			Aviso(STR0025, STR0051 + DTOC(AF8->AF8_ULMES) + STR0052, {STR0027 }, 2)  //"Operacao Invalida" ## "Esta operacao nao podera ser efetuada pois este projeto ja esta fechado com data " ## ". Verifique o apontamento selecionado." ## "Fechar"
			lRet:=.F.
		EndIf

	
	If lRet
		aCols[n,aScan(aHeader,{|x|Alltrim(x[2])=="AFU_HQUANT"})] := 0
		aCols[n,aScan(aHeader,{|x|Alltrim(x[2])=="AFU_HORAI"})]	 := Space(Len(AFU->AFU_HORAI))
		aCols[n,aScan(aHeader,{|x|Alltrim(x[2])=="AFU_HORAF"})]	 := Space(Len(AFU->AFU_HORAF))
	EndIf
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms320Sel³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria uma janela de consula das tarefas do Projeto.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms320Sel()

Local aRet := PmsSelTsk(STR0023,"AF8/AFC/AF9","AF9",STR0024) //"Selecione a Tarefa"###"Selecao Invalida. Esta consulta permite apenas a selecao das Tarefas do projeto. Varifique o elemento selecionado."

If !Empty(aRet)
	AF9->(dbGoto(aRet[2]))

	// valida a permissao do usuario
	If Pms320ValOpe() 
		M->AFU_PROJET	:= AF9->AF9_PROJET
		M->AFU_TAREFA	:= AF9->AF9_TAREFA
		M->AFU_REVISA	:= AF9->AF9_REVISA
	EndIf
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms320ValOpe³ Autor ³ Fabio Rogerio Pereira  ³ Data ³ 07-01-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a permissao do usuario.						           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                               	       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pms320ValOpe(cUsr)
Local lRet:= .T.
Default cUsr := Nil

If !PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,3,"RECURS",AF9->AF9_REVISA,cUsr)//Alterar
	Aviso(STR0025,STR0026,{STR0027},2) //"Operacao Invalida"###"Operacao nao disponivel para o usuario nesta tarefa!"###"Fechar"
	lRet:= .F.
EndIf         

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms320Per³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclusao de apontamentos por periodo                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms320Per()

Local aConfig
Local dX
Local nX
Local aRecur       := {}
Local aParamFields := {}
Local aRetPe       := {}
Local cProj        := ""
Local cTrf         := ""
Local lHabProj     := ".T."
Local lHabTrf      := "PmsSetF3('AF9',2,mv_par03)"
Local cConsProj    := "AF8"
Local cConsTrf     := "AF9"
Local lContinua    := .T.

Local nSaldo		:= 0
Local lBlqApt		:= AF8->AF8_PAR001=="1"
Local nQtdInfo		:= 0
Local nDifHrs		:= 0
Local aCalcHr		:= {}
Local cMsg			:= ""
Local cTO			:= ""
Local cCC			:= ""
Local cCalend		:= ""
Local cAssunto		:= ""
Local lPMS320CPO := ExistBlock("PMS320CPO") 
Local cMensagem := ""

Private l320 := .T.
Private nRecAlt := 0 

If Type("aGetCpo") == "U" .OR. !(aScan(aGetCpo,{|x| x[1] =="AFU_PROJET"}) > 0) .AND.;
 !(aScan(aGetCpo,{|x| x[1] =="AFU_TAREFA"}) > 0) //Nao preenche os campo projeto e tarefa caso a tarefa nao tenha sido selecionada. 		       
   cProj := SPACE(Len(AFU->AFU_PROJET))
   cTrf := SPACE(Len(AFU->AFU_TAREFA))
   lContinua := .T.
Else
   cProj 	 := aGetCpo[aScan(aGetCpo,{|x| x[1] =="AFU_PROJET"})][2] //Preenche o campo Projeto.
   lHabProj  := ".F."  																//Desabilita o preenchimento manual do campo projeto.
   cConsProj := ""     																//Desabilita a consulta via F3 do campo projeto.
   cTrf      := aGetCpo[aScan(aGetCpo,{|x| x[1] =="AFU_TAREFA"})][2] //Preenche o campo Tarefa.
   lHabTrf   := ".F."                                                 //Desabilita o preenchimento manual do campo tarefa.
   cConsTrf  := ""                                                    //Desabilita a consulta via F3 do campo tarefa.
   lContinua := PmsVldFase("AF8", cProj, "86")
EndIF

If lContinua
	
	aAdd(aParamFields, {1,STR0029,SPACE(Len(AFU->AFU_RECURS)),"@!","Vazio(mv_par01).Or.ExistCpo('AE8',mv_par01,1)","AE8","",60,.F.})  //"Cod. Recurso"
	aAdd(aParamFields, {1,STR0062,SPACE(Len(AE8->AE8_EQUIP)),"@!","Vazio(mv_par02) .Or. ExistCpo('AED',mv_par02,1)","AED","",70,.F.})  //"Equipe"
	aAdd(aParamFields, {1,STR0030,cProj,"@!","Vazio(mv_par03).Or.(ExistCpo('AF8',mv_par03,1).AND. PmsVldFase('AF8', AF8->AF8_PROJET, '86'))",cConsProj,lHabProj,65,.T.})  //"Cod. Projeto"
	aAdd(aParamFields, {1,STR0031,cTrf,"@!","Vazio(mv_par04).Or.ExistCpo('AF9',mv_par03+PmsRevAtu(mv_par03)+mv_par04,1)",cConsTrf,lHabTrf,70,.T.})  //"Cod. Tarefa"
	aAdd(aParamFields, {1,STR0032,CTOD("  /  /  "),"","","","",55,.T.}) //"Data Inicial"
	aAdd(aParamFields, {1,STR0033,CTOD("  /  /  "),"","mv_par06>mv_par05","","",55,.T.}) //"Data Final"
	aAdd(aParamFields, {1,STR0034,"  :  ","99:99","Vazio(mv_par07).Or.AtVldHora(mv_par07).AND.PMS320QHS()","","",25,.T.}) //"Hora Inicial"
	aAdd(aParamFields, {1,STR0035,"  :  ","99:99","Vazio(mv_par08).Or.AtVldHora(mv_par08).AND.PMS320QHS()","","",25,.T.}) //"Hora Final"
	aAdd(aParamFields, {1,STR0036,0,"@E 99,999,999,999.99","","",".F.",55,.F.}) //"Qtde.Hras.Diaria"
	aAdd(aParamFields, {4,STR0037,.F.,STR0038,40,,.F.}) //"Dias da semana"###"Domingo"
	aAdd(aParamFields, {4,"",.T.,STR0039,50,,.F.}) //"Segunda-Feira"
	aAdd(aParamFields, {4,"",.T.,STR0040,40,,.F.}) //"Terca-Feira"
	aAdd(aParamFields, {4,"",.T.,STR0041,40,,.F.}) //"Quarta-Feira"
	aAdd(aParamFields, {4,"",.T.,STR0042,40,,.F.}) //"Quinta-Feira"
	aAdd(aParamFields, {4,"",.T.,STR0043,40,,.F.}) //"Sexta-Feira"
	aAdd(aParamFields, {4,"",.F.,STR0044,40,,.F.})
	
		aAdd(aParamFields, {1,"Documento", Space(Len(AFU->AFU_PROJET)), "@!", "", "", "", 65, .F.}) //"Documento"
	
	If lPMS320CPO
	   aRetPe := ExecBlock("PMS320CPO",.F.,.F.,{aParamFields})
	   If ValType(aRetPE) == "A" //verifica se a variavel aRetPe e um vetor apos receber o retorno do ponto de entrada
	   	aParamFields := aClone(aRetPe) //atribui ao array aParamFields o valor do array aRetPe
	   EndIf
	EndIf
	
	If ParamBox(aParamFields,STR0045,@aConfig,{||Pms320Ok(aConfig)}) //"Sabado"###"Gerar Apontamentos por Periodo"
		// Gera os recursos pela equipe ou simplesmente o recurso informado.
		aRecur	:= Pms320EqRec(aConfig)
		If !Empty(aRecur)			
			For dx := aConfig[5] to aConfig[6]
				If aConfig[DOW(dx)+9]
					For nX:= 1 to Len(aRecur)
						// Verifica se esta habilitado no projeto o bloqueio de horas excedentes.
						If lBlqApt // .AND. PACtrlHoras( aConfig[3] )
							nQtdInfo	:= PmsHrsItvl(	dx, aConfig[7], dx, aConfig[8], ;
														ReadValue("AE8", 1, xFilial("AE8") + aRecur[nX], "AE8_CALEND"),;
														aConfig[3], aRecur[nX], , .T.)
							nSaldo		:= PA320ChkApon( aConfig[3], PmsRevAtu(aConfig[3]), aConfig[4], aRecur[nX], nQtdInfo, dx )
							If nSaldo <= 0
								Exit
							EndIf
						Else
							nQtdInfo	:= PmsHrsItvl(	dx, aConfig[7], dx, aConfig[8], ;
														ReadValue("AE8", 1, xFilial("AE8") + aRecur[nX], "AE8_CALEND"),;
														aConfig[3], aRecur[nX], , .T.)
                        EndIf

						Begin Transaction

							RegToMemory("AFU",.T.)

							M->AFU_FILIAL := xFilial("AFU")
							M->AFU_CTRRVS := "1"
							M->AFU_RECURS := aRecur[nX]
							M->AFU_PROJET := aConfig[3]
							M->AFU_TAREFA := aConfig[4]
							M->AFU_REVISA := PmsRevAtu(aConfig[3])
							M->AFU_DATA   := dx
							M->AFU_HORAI  := aConfig[7]
							M->AFU_HORAF  := aConfig[8]
							M->AFU_HQUANT := nQtdInfo
						                   
							If ReadValue("AE8", 1, xFilial("AE8") + aRecur[nX], "AE8_TPREAL") $ "235"
								M->AFU_CUSTO1 := M->AFU_HQUANT * ReadValue("AE8", 1, xFilial("AE8") + aRecur[nX], "AE8_CUSFIX")
								M->AFU_CUSTO2 := xMoeda(M->AFU_CUSTO1, 1, 2, M->AFU_DATA)
								M->AFU_CUSTO3 := xMoeda(M->AFU_CUSTO1, 1, 3, M->AFU_DATA)
								M->AFU_CUSTO4 := xMoeda(M->AFU_CUSTO1, 1, 4, M->AFU_DATA)
								M->AFU_CUSTO5 := xMoeda(M->AFU_CUSTO1, 1, 5, M->AFU_DATA)
							EndIf

								If !Empty(aConfig[17])
									M->AFU_DOCUME := aConfig[17]
								EndIf
							
							//Verifica se já existe apontamento no periodo informado
							If PMS300HRI(aConfig[7]) .AND. PMS300HRF(aConfig[8])
								// Verifica se esta habilitado no projeto o bloqueio de horas excedentes.
								If lBlqApt .AND. nSaldo > 0 // .AND. PACtrlHoras( M->AFU_PROJET )
									//Este deve gerar um apontamento com o saldo de horas e gerar um pré-apontamento com a diferença de horas. 
									If nQtdInfo > nSaldo
										nDifHrs := nQtdInfo - nSaldo
	
										// Define o apontamento com o saldo
										cCalend		:= Posicione("AE8",1,xFilial("AE8")+M->AFU_RECURS,"AE8_CALEND")
										aCalcHr		:= PMSADDHrs( M->AFU_DATA, M->AFU_HORAI, cCalend, nSaldo, M->AFU_PROJET, M->AFU_RECURS )
										M->AFU_HQUANT	:= nSaldo
										If !Empty( aCalcHr )
											M->AFU_HORAF := aCalcHr[2]
										EndIf
									EndIf
								EndIf

								Pms320Grava(,.F.,.T.,,@aConfig)
	
								// Verifica se esta habilitado no projeto o bloqueio de horas excedentes.
								// Com o excedente, eh gerado um pre-apontamento
								If lBlqApt // .AND. PACtrlHoras( AFU->AFU_PROJET )
									cCalend	:= Posicione("AE8",1,xFilial("AE8")+AFU->AFU_RECURS,"AE8_CALEND")
									aCalcHr	:= PMSADDHrs( AFU->AFU_DATA, AFU->AFU_HORAF, cCalend, nDifHrs, AFU->AFU_PROJET, AFU->AFU_RECURS )
									If !Empty( aCalcHr ) .AND. nDifHrs > 0
										DbSelectArea( "AJK" )
										RecLock( "AJK", .T. )
										AJK->AJK_FILIAL	:= xFilial( "AJK" )
										AJK->AJK_CTRRVS	:= "1"
										AJK->AJK_PROJET	:= AFU->AFU_PROJET
										AJK->AJK_TAREFA	:= AFU->AFU_TAREFA
										AJK->AJK_REVISA	:= AFU->AFU_REVISA
										AJK->AJK_RECURS	:= AFU->AFU_RECURS
										AJK->AJK_HQUANT	:= nDifHrs
										AJK->AJK_DATA	:= aCalcHr[1]
										AJK->AJK_HORAI	:= AFU->AFU_HORAF
										AJK->AJK_HORAF	:= aCalcHr[2]
										AJK->AJK_SITUAC	:= "1"	// Pendente
										AJK->( MsUnLock() )
	
										// Localiza o evento de notificacao do projeto
										DbSelectArea( "AN6" )
										AN6->( DbSetOrder( 1 ) )
										AN6->( DbSeek( xFilial( "AN6" ) + AFU->AFU_PROJET + StrZero( 1, TamSX3( "AN6_EVENT" )[1] )) )
										Do While AN6->( !Eof() ) .AND. AN6->( AN6_FILIAL + AN6_PROJET + AN6_EVENT ) == xFilial( "AN6" ) + AFU->AFU_PROJET + StrZero( 1, TamSX3( "AN6_EVENT" )[1] )
											// Se o campo funcao de usuario estiver preenchido deve Macroexecutar
											If !Empty( AN6->AN6_USRFUN )
												&(AN6->AN6_USRFUN)
											EndIf
	
											// Obtem o assunto da notificacao
											cAssunto := STR0084 // "Notificação de Evento - Horas Excedidas"
											If !Empty( AN6->AN6_ASSUNT )
												cAssunto := AN6->AN6_ASSUNT
											EndIf
	
											// macro executa para obter o titulo
											If Left( AllTrim( AN6->AN6_ASSUNT ), 1 ) = "="
												cAssunto := Right( cAssunto, Len( cAssunto ) -1 )
												cAssunto := &(cAssunto)
											EndIf
	
											// Obtem o destinatario
											cTo	:= PASeekPara( AFU->AFU_RECURS, AN6->AN6_PARA )
											cCC	:= PASeekPara( AFU->AFU_RECURS, AN6->AN6_COPIA )
	
											// Cria a mensagem
											cMsg := AN6->AN6_MSG
	
											// macro executa para obter a mensagem
											If Left( AllTrim( AN6->AN6_MSG ), 1 ) = "="
												cMsg := Right( cMsg, Len( cMsg ) -1 )
												cMsg := &(cMsg)
											EndIf
	
											/*
											cMsg := STR0079 + AFU->AFU_RECURS + CRLF	// "Foi gerado um pré-apontamento para o recurso "
											cMsg += STR0080 + AllTrim( AFU->AFU_PROJET ) + CRLF
											cMsg += STR0081 + AllTrim( AFU->AFU_TAREFA ) + CRLF
											cMsg += STR0082 + AllTrim( Str( nDifHrs ) ) + CRLF
											cMsg += STR0083 + DtoC( aCalcHr[1] ) + CRLF
	                                        */
	                                        
									        //Deve ser gerada uma notificação de evento do projeto encaminhando um e-mail para o superior do recurso;
											If !Empty( cTO )
												PMSSendMail(	cAssunto,; 						// Assunto
																cMsg,;							// Mensagem
																cTO,;							// Destinatario
																cCC,;							// Destinatario - Copia
																.T. )							// Se requer dominio na autenticacao
											EndIf
										
											AN6->( DbSkip() )
										End
									EndIf
								EndIf
								
							Else
								
								cMensagem += STR0089 + " " + STR0029 + ": " + aRecur[nX] +" " + STR0083 + DTOC(dx)+", " + STR0034 + ": " + aConfig[7] + ", " + STR0035 + ": " + aConfig[8] + CRLF //"Tentativa de apontamento."#"Recurso"#"Data"#"Hora Ini"#"Hora Fim"  
							
							EndIf
							
						End Transaction
					Next nX
				EndIf
			Next dX
		EndIf		
	EndIf

	If !Empty(cMensagem)
		Aviso(STR0046,STR0047+CRLF+cMensagem,{STR0060},3) //"Atencao!"###"Ja existem apontamentos deste(s) recurso(s) gravados neste periodo. Verifique o periodo informado." //"Ok"
	EndIf
	
EndIf	

Return( NIL )
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³P320ExPer ºAutor  ³Clóvis Magenta      º Data ³  07/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina que realiza a exclusao de apontamento por período.  º±±
±±º          ³ Esta rotina funcionará somente para ambiente TOP. 		     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA300 - PMSA320                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function P320ExPer()

Local oDlg              
Local oBox
Local oOk := LoadBitmap( GetResources(), "LBOK" )
Local oNo := LoadBitmap( GetResources(), "LBNO" )
Local oMainWnd
Local aConfig
Local dX
Local nX
Local aRecur      := {}
Local aParamFields:= {}
Local aRetPe      := {}
Local cProj       := ""
Local cTrf        := ""
Local lHabProj    := ".T."
Local lHabTrf     := "PmsSetF3('AF9',2,mv_par03)"
Local cConsProj   := "AF8"
Local cConsTrf    := "AF9"
Local cTemp			:= ""
Local cQuery		:= ""
Local cRecursos 	:= ""
Local cHorai 		:= ""
Local cHoraf 		:= ""
Local aColunas 	:= { ' ' ,'Projeto' ,'Revisão' ,'Tarefa' , 'Recurso' , 'Data','Hora Início','Hora Fim','Documento','Recno'}
Local aListAFU		:= {}
Local lOk			:= .F.

Local lBlqApt		:= AF8->AF8_PAR001=="1"
Local lRet			:= .T.

If Type("aGetCpo") == "U" .OR. !(aScan(aGetCpo,{|x| x[1] =="AFU_PROJET"}) > 0) .AND.;
 !(aScan(aGetCpo,{|x| x[1] =="AFU_TAREFA"}) > 0) //Nao preenche os campo projeto e tarefa caso a tarefa nao tenha sido selecionada.
   cProj := SPACE(Len(AFU->AFU_PROJET))
   cTrf := SPACE(Len(AFU->AFU_TAREFA))
Else
   cProj 	 := aGetCpo[aScan(aGetCpo,{|x| x[1] =="AFU_PROJET"})][2] //Preenche o campo Projeto.
   lHabProj  := ".F."  																//Desabilita o preenchimento manual do campo projeto.
   cConsProj := ""     																//Desabilita a consulta via F3 do campo projeto.
   cTrf      := aGetCpo[aScan(aGetCpo,{|x| x[1] =="AFU_TAREFA"})][2] //Preenche o campo Tarefa.
   lHabTrf   := ".F."                                                 //Desabilita o preenchimento manual do campo tarefa.
   cConsTrf  := ""                                                    //Desabilita a consulta via F3 do campo tarefa.
EndIF

aAdd(aParamFields, {1,STR0029,SPACE(Len(AFU->AFU_RECURS)),"@!","Vazio(mv_par01).Or.ExistCpo('AE8',mv_par01,1)","AE8","",60,.F.})  //"Cod. Recurso"
aAdd(aParamFields, {1,STR0062,SPACE(Len(AE8->AE8_EQUIP)),"@!","Vazio(mv_par02) .Or. ExistCpo('AED',mv_par02,1)","AED","",70,.F.})  //"Equipe"
aAdd(aParamFields, {1,STR0030,cProj,"@!","Vazio(mv_par03).Or.(ExistCpo('AF8',mv_par03,1).AND. PmsVldFase('AF8', AF8->AF8_PROJET, '86'))",cConsProj,lHabProj,65,.T.,.T.})  //"Cod. Projeto"
aAdd(aParamFields, {1,STR0031,cTrf,"@!","Vazio(mv_par04).Or.ExistCpo('AF9',mv_par03+PmsRevAtu(mv_par03)+mv_par04,1)",cConsTrf,lHabTrf,70,.T.,.T.})  //"Cod. Tarefa"
aAdd(aParamFields, {1,STR0032,CTOD("  /  /  "),"","","","",55,.T.}) //"Data Inicial"
aAdd(aParamFields, {1,STR0033,CTOD("  /  /  "),"","mv_par06>mv_par05","","",55,.T.}) //"Data Final"                                                                		
aAdd(aParamFields, {1,STR0034,"  :  ","99:99","Vazio(mv_par07).Or.AtVldHora(mv_par07).AND.PMS320QHS()","","",25,.T.}) //"Hora Inicial"
aAdd(aParamFields, {1,STR0035,"  :  ","99:99","Vazio(mv_par08).Or.AtVldHora(mv_par08).AND.PMS320QHS()","","",25,.T.}) //"Hora Final"
aAdd(aParamFields, {1,STR0036,0,"@E 99,999,999,999.99","","",".F.",55,.F.}) //"Qtde.Hras.Diaria"
aAdd(aParamFields, {4,STR0037,.F.,STR0038,40,,.F.}) //"Dias da semana"###"Domingo"
aAdd(aParamFields, {4,"",.T.,STR0039,50,,.F.}) //"Segunda-Feira"
aAdd(aParamFields, {4,"",.T.,STR0040,40,,.F.}) //"Terca-Feira"
aAdd(aParamFields, {4,"",.T.,STR0041,40,,.F.}) //"Quarta-Feira"
aAdd(aParamFields, {4,"",.T.,STR0042,40,,.F.}) //"Quinta-Feira"
aAdd(aParamFields, {4,"",.T.,STR0043,40,,.F.}) //"Sexta-Feira"
aAdd(aParamFields, {4,"",.F.,STR0044,40,,.F.}) //"Sabado"

aAdd(aParamFields, {1,"Documento", Space(Len(AFU->AFU_PROJET)), "@!", "", "", "", 65, .F.}) //"Documento"


If ParamBox(aParamFields,STR0074,@aConfig,{|| .T./*Pms320Ok(aConfig)*/}) //"Sabado"###"Excluir Apontamentos por Periodo"
	// Gera os recursos pela equipe ou simplesmente o recurso informado.
	aRecur	:= Pms320EqRec(aConfig)

	For nX:=1 to len(aRecur)
		If Empty(cRecursos)
			cRecursos += "'"+aRecur[nX]+"'"
		Else
			cRecursos += ",'" + aRecur[nX]+"'"
		Endif
	Next nX
	
//	cHorai := Substr(aConfig[7],1,2)+Substr(aConfig[7],4,2)
//	cHoraf := Substr(aConfig[8],1,2)+Substr(aConfig[8],4,2)
	cHorai := aConfig[7]
	cHoraf := aConfig[8]
	
	If !Empty(aRecur)
		For dx := aConfig[5] to aConfig[6]
			If aConfig[DOW(dx)+9]
					
				cQuery	:= " Select AFU_PROJET, AFU_REVISA, AFU_TAREFA, AFU_RECURS, AFU_DATA, AFU_HORAI, AFU_HORAF, AFU_DOCUME, R_E_C_N_O_ as AFURECNO FROM "+RetSqlName("AFU")
				cQuery	+= " WHERE AFU_FILIAL = '"+xFilial("AFU")+"' AND "
				cQuery	+= " AFU_RECURS IN ("+cRecursos+") AND "
				cQuery	+= " AFU_DATA = '" +DtoS(dX)+"' AND "
				cQuery	+= " AFU_HORAI >= '" +cHorai+ "' AND AFU_HORAI <= '" +cHoraf+ "' AND "
				cQuery	+= " AFU_HORAF >= '" +cHorai+ "' AND AFU_HORAF <= '" +cHoraf+ "' AND "
				cQuery	+= " AFU_PROJET = '"+aConfig[3]+"' AND AFU_REVISA = '"+PmsRevAtu(aConfig[3])+"' AND AFU_TAREFA = '"+aConfig[4]+"' AND "

				If !Empty(aConfig[17])                  
					cQuery	+= " AFU_DOCUME = '"+aConfig[17]+"' AND "
				EndIf
				

				cQuery	+= " D_E_L_E_T_ = '' "
			 
				cQuery 	:= ChangeQuery(cQuery)
				cTemp 	:= GetNextAlias()
				dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTemp, .T., .T.)

				Begin Transaction
					dbSelectArea("AFU")								
					While (cTemp)->(!EOF())
						aAdd(aListAFU,{ .F., (cTemp)->AFU_PROJET , (cTemp)->AFU_REVISA , (cTemp)->AFU_TAREFA , (cTemp)->AFU_RECURS , StoD((cTemp)->AFU_DATA), (cTemp)->AFU_HORAI, (cTemp)->AFU_HORAF, (cTemp)->AFU_DOCUME, (cTemp)->AFURECNO })
						(cTemp)->(dbSkip())
					EndDo
								
					MsUnlock()
				End Transaction
				(cTemp)->(dbclosearea())
			EndIf
		Next dX
	EndIf		
EndIf
              
If Len(aListAFU)>0
	
	DEFINE MSDIALOG oDlg TITLE STR0068 OF oMainWnd PIXEL FROM 0,0 TO 450,650

	If oBox==nil
		oBox	:= TWBrowse():New( 0, 0,450,650, ,aColunas,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	EndIf
	oBox:SetArray(aListAFU)
	oBox:bLine := { || {Iif(aListAFU[oBox:nAt,1],oOk,oNo),;
		 							 aListAFU[oBox:nAT,2],;
									 aListAFU[oBox:nAT,3],;
									 aListAFU[oBox:nAT,4],;
									 aListAFU[oBox:nAT,5],;
									 aListAFU[oBox:nAT,6],;
									 aListAFU[oBox:nAT,7],;
									 aListAFU[oBox:nAT,8],;
									 aListAFU[oBox:nAT,9],;
									 aListAFU[oBox:nAT,10] } }
									 
	oBox:Align := CONTROL_ALIGN_ALLCLIENT
	oBox:bLDblClick := {|| aListAFU[oBox:nAt,1] := !aListAFU[oBox:nAt,1]} 
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,{||lOk:=.T.,oDlg:End()},{||oDlg:End()}))
	
Endif

If lOk .AND. Aviso(STR0069,STR0070,{STR0071,STR0072},1) == 1

	Begin Transaction
		dbSelectArea("AFU")								
		For nX := 1 to Len(aListAFU)
			If aListAFU[nX][1]
				AFU->(dbGoTo(aListAFU[nX][10]))

				// Verifica se esta habilitado no projeto o bloqueio de horas excedentes.
				// Com o excedente, eh gerado um pre-apontamento
				If lBlqApt // .AND. PACtrlHoras( AFU->AFU_PROJET )
					DbSelectArea( "AJK" )
					AJK->( DbSetOrder( 1 ) )
					AJK->( DbSeek( xFilial( "AJK" ) + "1" + AFU->AFU_PROJET + AFU->AFU_REVISA + AFU->AFU_TAREFA + AFU->AFU_RECURS ) )
					While AJK->( !Eof() ) .AND. AJK->( AJK_FILIAL + AJK_CTRRVS + AJK_PROJET + AJK_REVISA + AJK_TAREFA + AJK_RECURS ) == xFilial( "AJK" ) + "1" + AFU->AFU_PROJET + AFU->AFU_REVISA + AFU->AFU_TAREFA + AFU->AFU_RECURS
						If AJK->AJK_SITUAC <> "3" .AND. AJK->AJK_DATA == AFU->AFU_DATA
							lRet := .F.
							Exit
						EndIf

						AJK->( DbSkip() )
					End

					If !lRet
						Help( " ", 1, "PA320EXCL",, STR0078, 1, 0 ) //"Este apontamento não pode ser excluído pois foi gerado um pré-apontamento com as horas excedentes!"
					EndIf
				EndIf

				If lRet
					Pms320Grava(AFU->(Recno()),.T.,,.T.)
				Endif
			Endif
		Next nX
	End Transaction
	
Endif

Return( NIL )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms320Ok³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se todos os parametros estao corretos.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms320Ok(aConfig)
Local dx
Local nX
Local lRet	 := .T.
Local aRecur := {} 

If !Empty(aConfig[1]) .and. !Empty(aConfig[2])
	If Aviso(STR0046,STR0077,{STR0075,STR0076},2) == 2  // Você já selecionou um recurso específico e não há necessidade de escolher a equipe, a menos que também deva ser gerado apontamento para toda a equipe. Deseja Continuar? - sim - não
		lRet := .F.
	Endif	
Endif
	
If lRet .and. SuperGetMV("MV_PMSVRAL", .F., 0) <> 0
	If !Empty(aConfig[1])
		If !IsAllocatedRes(aConfig[3], PmsAF8Ver(aConfig[3]), aConfig[4], aConfig[1])
			Aviso(STR0065, STR0066, {STR0027}, 2)
			lReturn := .F.
			Return lReturn	
		EndIf
	EndIf
EndIf

// se a hora inicial for maior ou igual a hora final
If lRet .and. (Substr(aConfig[7],1,2) + Substr(aConfig[7],4,2) >= Substr(aConfig[8],1,2) + Substr(aConfig[8],4,2))
	Aviso(STR0046, STR0064, {"Ok"},2) //"Atencao!"###"A hora final nao podera ser menor que a hora inicial. Verifique a hora digitada"
	lRet := .F.
EndIf

If lRet .AND. Empty(aConfig[1]) .And. Empty(aConfig[2])
	Aviso(STR0046, STR0063, {"Ok"},2) //"Atencao!"###"O Campo Recurso ou o Campo Equipe deve ser preenchido."
	lRet := .F.
Else
	aRecur := Pms320EqRec(aConfig)
	If ! Empty( aRecur ) 
		If ! IsInCallStack("Pms320Per")
			For dx := aConfig[5] to aConfig[6]
				If aConfig[DOW(dx)+9]
					For nX:= 1 to Len(aRecur)
						dbSelectArea("AFU")
						dbSetOrder(3)
						dbSeek(xFilial("AFU")+"1"+aRecur[nX]+DTOS(dx))
						While !Eof() .And. lRet .And. xFilial("AFU")+"1"+aRecur[nX]+DTOS(dx)==;
											AFU->AFU_FILIAL+AFU->AFU_CTRRVS+AFU->AFU_RECURS+DTOS(AFU->AFU_DATA)
							If  (Substr(aConfig[7],1,2)+Substr(aConfig[7],4,2) >= Substr(AFU->AFU_HORAI,1,2)+Substr(AFU->AFU_HORAI,4,2) .And. Substr(aConfig[7],1,2)+SUbstr(aConfig[7],4,2) <= Substr(AFU->AFU_HORAF,1,2)+Substr(AFU->AFU_HORAF,4,2)).Or.;
								(Substr(aConfig[8],1,2)+Substr(aConfig[8],4,2) <= Substr(AFU->AFU_HORAI,1,2)+Substr(AFU->AFU_HORAI,4,2) .And. Substr(aConfig[8],1,2)+SUbstr(aConfig[8],4,2) >= Substr(AFU->AFU_HORAF,1,2)+Substr(AFU->AFU_HORAF,4,2))
								Aviso(STR0046,STR0047,{"Ok"},2) //"Atencao!"###"Ja existem apontamentos deste(s) recurso(s) gravados neste periodo. Verifique o periodo informado."
								lRet := .F.
								Exit
							EndIf
							
							dbskip()
						End
					Next nX
				EndIf
			Next dX
		EndIf
    Else
		Aviso(STR0046, STR0061,{"Ok"},2) //"Atencao!"###"Não existe nenhum recurso ativo na equipe informada."
		lRet := .F.
		
    EndIf
	If lRet .And. aConfig[9] > 24 
		Aviso(STR0046, STR0057,{"Ok"},2) // Atencao! ### "A quantidade de horas apontadas nao deve ser maior que 24hs. !
		lRet := .F.
	EndIf
	
EndIf
	
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsRevAtu³ Autor ³                        ³ Data ³   -  -     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o numero da revisão do projeto.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsRevAtu(cProjeto)

Local cRev	:= ''

cRev := PmsAF8Ver(cProjeto)

Return( cRev )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms320USi³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta tela de inicio da utilizacao dos recursos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms320Usi(cAlias,nRecNo,nOpcx,xRes1,xRes2,aGetCpos)

Local oDlg
Local nRecAFU
Local aCampos
Local lOk			:= .F.
Local nX			:= 0
Local lContinua     := .T.

DEFAULT aGetCpos	:= {}

PRIVATE nRecAlt		:= 0
PRIVATE l320		:= .T.

If !PmsVldFase("AF8", AFU->AFU_PROJET, "86")
	lContinua := .F.
EndIf 

// verificar data do ultimo fechamento do projeto
	AF8->(dbSetOrder(1))
	AF8->(MsSeek(xFilial()+AFU->AFU_PROJET))
	If AF8->AF8_ULMES >= dDataBase
		Aviso(STR0025 ,STR0051 + DTOC(AF8->AF8_ULMES) + STR0052,{STR0027 },2) 
		lContinua := .F.
	EndIf

If lContinua 

	// carrega as variaveis de memoria
	RegToMemory("AFU",.T.)
	
	// carrega a Data de Inicio
	aAdd(aGetCpos,{"AFU_DATA",dDataBase,.T.})
	aAdd(aGetCpos,{"AFU_HORAI",Time(),.T.})

	// tratamento do array aGetCpos com os campos Inicializados do AFU
	If aGetCpos <> Nil
		aCampos	:= {}
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AFU")
		While !Eof() .and. SX3->X3_ARQUIVO == "AFU"
			IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
				nPosCpo	:= aScan(aGetCpos,{|x| x[1]==Alltrim(X3_CAMPO)})
				If !(Alltrim(X3_CAMPO)$"AFU_HORAF,AFU_HQUANT") 
					If nPosCpo > 0
						If aGetCpos[nPosCpo][3]
							aAdd(aCampos,AllTrim(X3_CAMPO))
						EndIf
					Else
						aAdd(aCampos,AllTrim(X3_CAMPO))
					EndIf
				EndIf
			EndIf
			dbSkip()
		End
		For nx := 1 to Len(aGetCpos)
			cCpo	:= "M->"+Trim(aGetCpos[nx][1])
			&cCpo	:= aGetCpos[nx][2]
		Next nx
	EndIf
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO TranslateBottom(.F.,28),80 OF oMainWnd
	oEnch := MsMGet():New("AFU",AFU->(RecNo()),nOpcx,,,,aCampos,{,,(oDlg:nClientHeight - 4)/2,},aCampos,3,,,,oDlg)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||iIf( Pms320Vld(oEnch ,.F. ,M->AFU_HORAI ,,__cUserID),(oDlg:End(),lOk:=.T.),NIL)},{||oDlg:End()})
	
	If lOk 
		Begin Transaction
			Pms320Grava(nRecAFU,.F.,.F.,.F.)
		End Transaction
	EndIf

EndIf

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms320USf³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta tela de finalizacao da utilizacao dos recursos          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms320Usf(cAlias,nRecNo,nOpcx,xRes1,xRes2,aGetCpos)

Local oDlg
Local nRecAFU		:= AFU->(RecNo())
Local aCampos
Local lOk			:= .F.
Local nX			:= 0
Local lContinua     := .T.

DEFAULT aGetCpos	:= {}

PRIVATE nRecAlt		:= 0
PRIVATE l320		:= .T.

If !Empty(AFU->AFU_HORAF)
	Aviso(STR0046,STR0050+STR0048+".",{"Ok"},2) //"Atencao!"###"A opcao de finalizar uso do recurso so podera ser utilizada nos apontamentos incluidos pela opcao '###'."
	lContinua:= .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificar data do ultimo fechamento do projeto.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua 
	AF8->(dbSetOrder(1))
	AF8->(MsSeek(xFilial()+AFU->AFU_PROJET))
	If AF8->AF8_ULMES >= AFU->AFU_DATA
		Aviso(STR0025 ,STR0051 + DTOC(AF8->AF8_ULMES) + STR0052,{STR0027 },2)  //"Operacao Invalida" ## "Esta operacao nao podera ser efetuada pois este projeto ja esta fechado com data " ## ". Verifique o apontamento selecionado." ## "Fechar"
		lContinua:= .F.
	EndIf
EndIf

If lContinua
	
	// carrega as variaveis de memoria
	RegToMemory("AFU",.F.)
	
	// carrega a Data de Inicio
	AE8->(dbSetOrder(1))
	AE8->(dbSeek(xFilial()+M->AFU_RECURS))
	aAdd(aGetCpos,{"AFU_HORAF",Time(),.T.})
	aAdd(aGetCpos,{"AFU_HQUANT",PmsHrsItvl(M->AFU_DATA,M->AFU_HORAI,M->AFU_DATA,Time(),AE8->AE8_CALEND,M->AFU_PROJET,M->AFU_RECURS,,.T.),.T.})
	
	// tratamento do array aGetCpos com os campos Inicializados do AFU
	If aGetCpos <> Nil
		aCampos	:= {}
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AFU")
		While !Eof() .and. SX3->X3_ARQUIVO == "AFU"
			IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
				nPosCpo	:= aScan(aGetCpos,{|x| x[1]==Alltrim(X3_CAMPO)})
				If nPosCpo > 0
					If aGetCpos[nPosCpo][3]
						aAdd(aCampos,AllTrim(X3_CAMPO))
					EndIf
				Else
					aAdd(aCampos,AllTrim(X3_CAMPO))
				EndIf
			EndIf
			dbSkip()
		End
		For nx := 1 to Len(aGetCpos)
			cCpo	:= "M->"+Trim(aGetCpos[nx][1])
			&cCpo	:= aGetCpos[nx][2]
		Next nx
	EndIf
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO TranslateBottom(.F.,28),80 OF oMainWnd
	oEnch := MsMGet():New("AFU",AFU->(RecNo()),nOpcx,,,,aCampos,{,,(oDlg:nClientHeight - 4)/2,},aCampos,3,,,,oDlg)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||iIf(Pms320Vld(oEnch ,.F. ,,M->AFU_HORAF ,__cUserID),(oDlg:End(),lOk:=.T.),Nil)},{||oDlg:End()}) //"PRODUTO"###"Selecionar Tarefa"
		
	If lOk 
		Begin Transaction
			Pms320Grava(nRecAFU,.F.,.T.,.F.)
		End Transaction
	EndIf
EndIf

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms320Trf³ Autor ³                        ³ Data ³   -  -     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao do projeto+revisao+tarefa.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms320Trf()
Local lRet	:= .F.
	
If l320
	lRet := ExistCpo("AF9",M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA,1)
Else
	lRet := ExistCpo("AF9",aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFU_PROJET"})]+aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFU_REVISA"})]+M->AFU_TAREFA,1)
EndIf

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms320Trf³ Autor ³                        ³ Data ³   -  -     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao do hora inicial e final da tarefa.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms320Hrf()

Local lHoraf 	:= Alltrim(ReadVar()) == 'M->AFU_HORAF'
Local lRet		:= .F.
Local nPosHrF	:= 0

If !l320
	nPosHrF:=aScan(aHeader,{|x|Alltrim(x[2])=="AFU_HORAF"})
Endif

If l320
	lRet := Vazio() .Or. (AtVldHora(M->AFU_HORAF).And.PMS300HRF(M->AFU_HORAF))
Elseif lHoraf
   lRet := Vazio() .Or. (AtVldHora(M->AFU_HORAF).And.PMS300HRF(M->AFU_HORAF))
Else
   lRet := Vazio() .Or. (AtVldHora(aCols[n][nPosHrF]).And.PMS300HRF(M->AFU_HORAF))
EndIf

Return( lRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms320Cust³ Autor ³                        ³ Data ³   -  -    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o custo do recurso conforme o apontamento(quantidade).³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms320Cust(nQuant)
Local aArea		:= GetArea()
Local aAreaAE8	:= AE8->(GetArea())
Local nPosCusto   := 0

If Type("aHeader") <> "U"
	nPosCusto := aScan(aHeader,{|x| AllTrim(x[2])=="AFU_CUSTO1"})// Valida se o campo de custo está no aheader 
EndIF

dbSelectArea("AE8")
dbSetOrder(1)
If l320
	MsSeek(xFilial()+M->AFU_RECURS)
Else
	MsSeek(xFilial()+aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="AFU_RECURS"})])
EndIf

If ExistTemplate("PMA320CST") .And. (GetMV("MV_PMSCCT") == "2") 
	ExecTemplate("PMA320CST",.F.,.F.,{nQuant})
Else

	If l320
		M->AFU_COD := AE8->AE8_PRDREA
	Else
		aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="AFU_COD"})] := AE8->AE8_PRDREA
	EndIf
	
	If AE8->AE8_TPREAL $"1235"
		If l320 .Or. nPosCusto == 0
			M->AFU_CUSTO1	:= AE8->AE8_CUSFIX*nQuant
			M->AFU_CUSTO2	:= xMoeda(M->AFU_CUSTO1	,1,2,M->AFU_DATA)
			M->AFU_CUSTO3	:= xMoeda(M->AFU_CUSTO1	,1,3,M->AFU_DATA)
			M->AFU_CUSTO4	:= xMoeda(M->AFU_CUSTO1	,1,4,M->AFU_DATA)
			M->AFU_CUSTO5	:= xMoeda(M->AFU_CUSTO1,1,5,M->AFU_DATA)
		Else
			aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="AFU_CUSTO1"})] := AE8->AE8_CUSFIX*nQuant
			aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="AFU_CUSTO2"})] := xMoeda(aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="AFU_CUSTO1"})],1,2,aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="AFU_DATA"})])
			aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="AFU_CUSTO3"})] := xMoeda(aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="AFU_CUSTO1"})],1,3,aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="AFU_DATA"})])		
			aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="AFU_CUSTO4"})] := xMoeda(aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="AFU_CUSTO1"})],1,4,aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="AFU_DATA"})])		
			aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="AFU_CUSTO5"})] := xMoeda(aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="AFU_CUSTO1"})],1,5,aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="AFU_DATA"})])
		EndIf
	EndIf
EndIf
	
RestArea(aAreaAE8)
RestArea(aArea)

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms320EqRec³ Autor ³ Daniel Sobreira       ³ Data ³ 27-10-05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Ira retornar os recursos para a equipe informada no aConfig[2]³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pms320EqRec(aConfig)
Local aArea     := {}
Local aRecur	:= {}
	
	If !Empty(aConfig[2])
		aArea	:= GetArea()
		AE8->(DbSetOrder(4))
		If AE8->(DbSeek(xFilial()+aConfig[2]))
			While AE8->AE8_FILIAL+AE8->AE8_EQUIP==xFilial()+aConfig[2]
				If AE8->AE8_ATIVO != "2"
					If SuperGetMV("MV_PMSVRAL", .F., 0) <> 0
						If IsAllocatedRes(aConfig[3], PmsAF8Ver(aConfig[3]), aConfig[4], AE8->AE8_RECURS)
							aAdd(aRecur, AE8->AE8_RECURS)
						EndIf
					Else
						aAdd(aRecur, AE8->AE8_RECURS)
					EndIf
					
				EndIf
				AE8->(DbSkip())
					
			End
		EndIf
		RestArea(aArea)
	Else
		aAdd(aRecur,aConfig[1])
	EndIf

Return (aRecur)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PMS311THr ³ Autor ³ Reynaldo Miyashita     ³ Data ³19/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula a quantidade de horas apontadas na tarefa          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorna a quantidade de horas apontadas na tarefa          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PMS320THr(cProjeto, cRevisa, cTarefa)
Local aArea     := GetArea()
Local aAreaAFU  := {}
Local nTotHoras := 0

cProjeto := Padr(cProjeto ,Len(AFU->AFU_PROJET))
cRevisa  := Padr(cRevisa ,Len(AFU->AFU_REVISA))
cTarefa  := Padr(cTarefa ,Len(AFU->AFU_TAREFA))

dbSelectArea("AFU")
aAreaAFU := AFU->(GetArea())
dbSetOrder(1)
MsSeek(xFilial("AFU")+"1"+cProjeto+cRevisa+cTarefa)
While AFU->(!EOF()) .AND. AFU->(AFU_FILIAL+"1"+AFU_PROJET+AFU_REVISA+AFU_TAREFA) == ;
      xFilial("AFU")+"1"+cProjeto+cRevisa+cTarefa

	nTotHoras += AFU->AFU_HQUANT
	
	dbSkip()
EndDo

RestArea(aAreaAFU)
RestArea(aArea)

Return nTotHoras
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³30/11/06 ³±±
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
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
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
#IFDEF TOP
Local aRotina 	:= {{ STR0002,"PMS320Psq" , 0 , 1,,.F.},;  //"Pesquisar"
								{ STR0003,"PMS320Dlg" , 0 , 2 },; //"Visualizar"
								{ STR0016,"PMS320Dlg" , 0 , 3 },; //"Incluir"
								{ STR0028,"PMS320Per" , 0 , 3 },; //"incl.pEriodo"
								{ STR0073,"P320ExPer" , 0 , 3 },; //"excl.pEriodo" ----> SOMENTE PARA AMBIENTES TOPCONNECT
								{ STR0048,"PMS320Usi" , 0 , 3 },; //"iniCiar uso"
								{ STR0049,"PMS320Usf" , 0 , 4 },; //"finalizar Uso"
								{ STR0017,"PMS320Dlg" , 0 , 4 },; //"Alterar"
								{ STR0018,"PMS320Dlg" , 0 , 5 } } //"Excluir"
#ELSE
Local aRotina 	:= {{ STR0002,"PMS320Psq" , 0 , 1,,.F.},;  //"Pesquisar"
								{ STR0003,"PMS320Dlg" , 0 , 2 },; //"Visualizar"
								{ STR0016,"PMS320Dlg" , 0 , 3 },; //"Incluir"
								{ STR0028,"PMS320Per" , 0 , 3 },; //"incl.pEriodo"
								{ STR0048,"PMS320Usi" , 0 , 3 },; //"iniCiar uso"
								{ STR0049,"PMS320Usf" , 0 , 4 },; //"finalizar Uso"
								{ STR0017,"PMS320Dlg" , 0 , 4 },; //"Alterar"
								{ STR0018,"PMS320Dlg" , 0 , 5 } } //"Excluir"
#ENDIF

Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Pms320Vld ³ Autor ³ Reynaldo Miyashita     ³ Data ³12/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ valida a dialog de apontamento de recursos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorna se passou pela validacao ou não                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Pms320Vld(oEnch ,l320Exclui ,cHoraI ,cHoraF ,cUsuario, lAuto, l320Visual)
Local aAreaAJK		:= AJK->( GetArea() )
Local lRet 			:= .T.
Local lBlqApt		:= AF8->AF8_PAR001=="1"
Local lPMSBQAP 	:= GetMv("MV_PMSBQAP",,.F.)   // Projeto TDI - TEHNAO Bloqueio de tarefas com horarios concorrentes

DEFAULT l320Exclui := .F.
DEFAULT lAuto := .F.

// Se não for excluir e os campos obrigatorios preenchidos
If !l320Exclui .AND. !l320Visual
	If !lAuto
		lRet := Obrigatorio(oEnch:aGets,oEnch:aTela)
	EndIf

	// Valida a hora inicial informada
	If lRet .AND. !Empty(cHoraI)
		lRet := PMS300HRI(cHoraI)
	EndIf

	// Valida a hora final informada
	If lRet .AND. !Empty(cHoraF)
		lRet := PMS300HRF(cHoraF)
	EndIf

EndIf

// Valida o usuario
If lRet .AND. !Empty(cUsuario)
	lRet := Pms320ValOpe(cUsuario)
EndIf

// valida se o produto foi associado a um insumo do projeto no CORPORE RM
lRet := lRet .AND. SlmValid(M->AFU_PROJET ,M->AFU_COD)

// Verifica se esta habilitado no projeto o bloqueio de horas excedentes.
// Com o excedente, eh gerado um pre-apontamento
If lBlqApt // .AND. PACtrlHoras( M->AFU_PROJET )
	If lRet .AND. l320Exclui
		DbSelectArea( "AJK" )
		AJK->( DbSetOrder( 1 ) )
		AJK->( DbSeek( xFilial( "AJK" ) + "1" + M->AFU_PROJET + M->AFU_REVISA + M->AFU_TAREFA + M->AFU_RECURS ) )
		While AJK->( !Eof() ) .AND. AJK->( AJK_FILIAL + AJK_CTRRVS + AJK_PROJET + AJK_REVISA + AJK_TAREFA + AJK_RECURS ) == xFilial( "AJK" ) + "1" + M->AFU_PROJET + M->AFU_REVISA + M->AFU_TAREFA + M->AFU_RECURS
			If AJK->AJK_SITUAC <> "3" .AND. AJK->AJK_DATA == AFU->AFU_DATA
				lRet := .F.
				Exit
			EndIf

			AJK->( DbSkip() )
		End

		If !lRet
			Help( " ", 1, "PA320EXCL",, STR0078, 1, 0 ) //"Este apontamento não pode ser excluído pois foi gerado um pré-apontamento com as horas excedentes!"
		EndIf
	Else
		lRet := lRet .AND. PAValApont( M->AFU_PROJET, M->AFU_REVISA, M->AFU_TAREFA, M->AFU_RECURS, M->AFU_HQUANT )
	EndIf
EndIf

// se existir o ponto de entrada valida o mesmo.
lRet := lRet .AND. PMS320Grv()

// Projeto TDI - TEHNAO - Bloqueio de tarefas com horarios concorrentes
// bloqueia o apontamento direto se o monitor estiver executando a mesma tarefa
if lRet .and. lPMSBQAP
	lRet := A320BLQAP(IsInCallStack("PMSMONIT"), xFilial("AF9"), M->AFU_PROJET, M->AFU_REVISA, M->AFU_TAREFA, M->AFU_RECURS, M->AFU_DATA, M->AFU_HORAI,)
Endif	
RestArea( aAreaAJK )	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMS320GRV ºAutor  ³Reynaldo Miyashita  º Data ³  02/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa ponto de entrada, caso exista. Execução é efetuada º±±
±±º          ³na validacao da dialog do apontamento de recurso            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS320Grv()
Local lReturn := .T.  
Local lPMA320TOK := ExistBlock("PMA320TOK")
	//
	// MV_PMSVRAL
	//	
	// 0 - desabilitado (default)
	// <> 0 - habilitado
	
	If SuperGetMV("MV_PMSVRAL", .F., 0) <> 0
		If !IsAllocatedRes(M->AFU_PROJET, M->AFU_REVISA, M->AFU_TAREFA, M->AFU_RECURS)
			Aviso(STR0065, STR0066, {STR0027}, 2) //"Apontamento de Recurso"##"É necessário que o recurso esteja alocado na tarefa para efetuar apontamento."##"Fechar"			
			lReturn := .F.
			Return lReturn	
		EndIf
	EndIf

	If lPMA320TOK
		lReturn	:= ExecBlock("PMA320TOK", .F., .F.)
	EndIf
Return lReturn

/*
   Verifica se o recurso cResource está alocado em uma 
   tarefa cTask de um projeto cProject.

FUNCAO INCLUSA DIA 11/05/09 PARA ADEQUAR O PARAMETRO 
MV_PMSVRAL PARA A VERSAO 912
*/
Static Function IsAllocatedRes(cProject, cRevision, cTask, cResource)
Local aArea := GetArea()
Local aAreaAFA := AFA->(GetArea())

Local lReturn := .F.

dbSelectArea("AFA")
AFA->(dbSetOrder(5))

// AFA - índice 5:	
// AFA_FILIAL + AFA_PROJET + AFA_REVISA + AFA_TAREFA + AFA_RECURS

lReturn := AFA->(MsSeek(xFilial("AFA") + cProject + cRevision + cTask + cResource))

RestArea(aAreaAFA)	
RestArea(aArea)
Return lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PegaRespAnºAutor  ³Marcelo Akama       º Data ³  16/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pega o responsável da tarefa anterior                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PegaRespAnt( cAcao, cRevAcao, cTpAcao)
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFA	:= AFA->(GetArea())
Local cRet		:= ""
Local cItem		:= ""

If AF8->AF8_PAR002=="1"
	If cRevAcao<="00"
		Return cRet
	EndIf
	cRevAnt := strzero(val(cRevAcao)-1,2)
	dbselectarea("AF9")
	dbsetorder(6)
	If AF9->(MsSeek(xFilial("AF9")+cAcao+cRevAnt+cTpAcao))
		Dbselectarea("AFA")
		Dbsetorder(1)
		AFA->( MsSeek(xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA) )
		Do While Empty(cRet) .And. !AFA->(Eof()) .And. AFA->(AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA)==xfilial("AFA")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)
			If !Empty(AFA->AFA_RECURS) .And. AFA->AFA_RESP=="1"
				cRet:=AFA->AFA_RECURS
			EndIf
			AFA->(dbSkip())
		EndDo
	EndIf
ElseIf AF8->AF8_PAR002=="2"
	dbselectarea("AFA")
	dbsetorder(1)
	MsSeek(xFilial("AFA")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA))
	Do While Empty(cItem) .And. !Eof() .And. AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA==xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
		If !Empty(AFA_RECURS) .And. AFA_RESP=="1"
			cItem:=AFA_RSPANT
		EndIf
		dbSkip()
	EndDo
	If !Empty(cItem)
		If MsSeek(xFilial("AFA")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)+cItem)
			cRet := AFA_RECURS
		EndIf
	EndIf
EndIf

RestArea(aAreaAF9)
RestArea(aAreaAFA)

Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PegApontAnºAutor  ³Marcelo Akama       º Data ³  04/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pega as horas apontadas na tarefa anterior                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PegApontAnt( cAcao, cRevAcao, cTpAcao )
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFU	:= AFU->(GetArea())
Local nRet		:= 0

If cRevAcao<="00"
	Return nRet
EndIf
cRevAnt := strzero(val(cRevAcao)-1,2)
dbselectarea("AF9")
dbsetorder(6)
If AF9->(MsSeek(xfilial("AF9")+cAcao+cRevAnt+cTpAcao))
	Dbselectarea("AFU")
	Dbsetorder(5) //AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA+DTOS(AFU_DATA)+AFU_RECURS
	AFU->( MsSeek(xfilial("AFU")+"1"+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA) )
	Do While !AFU->(Eof()) .And. AFU->(AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA)==xfilial("AFU")+"1"+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
		nRet := nRet + AFU->AFU_HQUANT
		AFU->(dbSkip())
	EndDo
Endif

RestArea(aAreaAF9)
RestArea(aAreaAFU)

Return nRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pms320ChkAºAutor  ³Marcelo Akama       º Data ³  04/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica a existencia de apontamentos de outros usuários   º±±
±±º          ³ com data e hora superior a data e hora informada           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms320ChkA( cProjet, cRevisa, cTarefa, cUser, dData, cHoraFim, nHQuant)
Local aArea		:= GetArea()
Local aAreaAFU	:= AFU->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFA	:= AFA->(GetArea())
Local lRet		:= .F.
Local nHorasTot	:= 0
Local aOutros	:= {}
Local aApont	:= {}
Local aNApont	:= {}
Local nRetrab
Local lRejeicao	:= IIf(AF8->(FieldPos("AF8_PAR002"))>0, AF8->AF8_PAR002=="1" .Or. AF8->AF8_PAR002=="2", .F.)

Private nHoras		:= 0
Private nSaldo		:= 0
Private nApont		:= 0
Private cRespAtu	:= ''
Private cRespAnt	:= ''

Dbselectarea("AFU")
Dbsetorder(5) //AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA+DTOS(AFU_DATA)+AFU_RECURS
AFU->( MsSeek(xfilial("AFU")+"1"+cProjet+cRevisa+cTarefa) )
Do While !lRet .And. !AFU->(Eof()) .And. AFU->(AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA)==xfilial("AFU")+"1"+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA
	If AFU->(DTOS(AFU_DATA)+AFU_HORAI) > DTOS(dData)+cHoraFim .And. AFU->AFU_RECURS<>cUser
		lRet := .T.
	EndIF
	AFU->(dbSkip())
EndDo

If lRejeicao .And. lRet //.And. nHQuant<>nil
/*
	nApont := 0
	Dbselectarea("AFU")
	Dbsetorder(1)
	AFU->( MsSeek(xfilial("AFU")+"1"+cProjet+cRevisa+cTarefa) )
	Do While !AFU->(Eof()) .And. AFU->(AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA)==xfilial("AFU")+"1"+cProjet+cRevisa+cTarefa
		nApont := nApont + AFU->AFU_HQUANT
		AFU->(dbSkip())
	EndDo

	AF9->(DbSetOrder(1))
	AF9->(MsSeek( xFilial("AF9")+cProjet+cRevisa+cTarefa ))

	nHorasTot := AF9->AF9_HDURAC
	nSaldo := nHorasTot - nApont
	
	lRet := nHQuant > nSaldo
*/
	cRespAtu := ""
	Dbselectarea("AFA")
	Dbsetorder(1)
	AFA->( MsSeek(xfilial("AFA")+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA) )
	Do While !AFA->(Eof()) .And. AFA->(AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA)==xfilial("AFA")+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA
		If !empty(AFA->AFA_RECURS) .And. AFA->AFA_RESP=="1"
			cRespAtu:=AFA->AFA_RECURS
		EndIf
		AFA->(dbSkip())
	EndDo
	
	nApont := 0
	Dbselectarea("AFU")
	Dbsetorder(1)
	AFU->( MsSeek(xfilial("AFU")+"1"+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA) )
	Do While !AFU->(Eof()) .And. AFU->(AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA)==xfilial("AFU")+"1"+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA
		nApont := nApont + AFU->AFU_HQUANT
		AFU->(dbSkip())
	EndDo

	nRetrab := 0
	dbselectarea("AN2")
	dbsetorder(2) //AN2_FILIAL+AN2_CTRRVS+AN2_PROJET+AN2_REVISA+AN2_TAREFA+DTOS(AN2_DATA)+AN2_RECURS
	AN2->( MsSeek(xfilial("AN2")+"1"+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA) )
	Do While !AN2->(Eof()) .And. AN2->(AN2_FILIAL+AN2_CTRRVS+AN2_PROJET+AN2_REVISA+AN2_TAREFA)==xFilial("AN2")+"1"+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA
		nRetrab := nRetrab + AN2->AN2_HQUANT
		AN2->(dbSkip())
	EndDo
		
	aApont := {}
	Dbselectarea("AFU")
	Dbsetorder(5) //AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA+DTOS(AFU_DATA)+AFU_RECURS
	AFU->( MsSeek(xfilial("AFU")+"1"+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA) )
	Do While !AFU->(Eof()) .And. AFU->(AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA)==xfilial("AFU")+"1"+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA
		If AFU->(DTOS(AFU_DATA)+AFU_HORAI) > M->(DTOS(AFU_DATA)+AFU_HORAF)
			If AFU->AFU_RECURS == M->AFU_RECURS
				nApont := nApont - AFU->AFU_HQUANT
			Else
				If AScan( aApont, AFU->AFU_TPHORA ) == 0
					AADD( aApont, AFU->AFU_TPHORA )
				EndIf
			EndIf
		EndIf
		AFU->(dbSkip())
	EndDo

	AF9->(DbSetOrder(1))
	AF9->(MsSeek( xFilial("AF9")+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA ))
	AFA->(DbSetOrder(5))
	AFA->(MsSeek( xFilial("AFA")+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA+M->AFU_RECURS ))
	
	nHorasTot := AF9->AF9_HDURAC
	
	nHoras := M->AFU_HQUANT
	nSaldo := nHorasTot - nApont
	cRespAnt := PegaRespAnt( AF9->AF9_ACAO, AF9->AF9_REVACA, AF9->AF9_TPACAO )
	nApont := PegApontAnt( AF9->AF9_ACAO, AF9->AF9_REVACA, AF9->AF9_TPACAO )
	nApont := nApont - nRetrab
	
	aNApont := {}
	If nHoras > 0
		dbSelectArea("AN3")
		dbSetOrder(1)
		AN3->(dbSeek(xFilial("AN3")))
		Do While nHoras>0 .And. !AN3->(Eof()) .And. AN3->AN3_FILIAL == xFilial("AN3")
			If &(AN3->AN3_REGRA)
				nHrsRegra := &(AN3->AN3_HORAS)
				nHoras := nHoras - nHrsRegra
				nSaldo := nSaldo - nHrsRegra
				If nSaldo < 0 .And. nApont > 0
					nApont := nApont - nHrsRegra
				EndIf
				If AScan( aNApont, AN3->AN3_TIPO ) == 0
					AADD( aNApont, AN3->AN3_TIPO )
				EndIf
			EndIf
			AN3->(dbSkip())
		EndDo
	EndIf

	If Len(aApont)>0 .And. Len(aNApont)>0
		lRet := aApont[1]<>aNApont[1] .Or. Len(aApont)>1 .Or. Len(aNApont)>1
	Else
		lRet := .F.
	EndIf
EndIf

RestArea(aAreaAFA)
RestArea(aAreaAF9)
RestArea(aAreaAFU)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PA320ChkAponºAutor³Totvs                      º Data ³ 22/06/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡…o ³Valida o apontamento do recurso na tarefa.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³PA320ChkApon( cProjeto, cTarefa, cRecurso )                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParƒmetros³ ExpC1 -> codigo do projeto onde o recurso deseja apontar.        º±±
±±º          ³ ExpC2 -> revisao do projeto                                      º±±
±±º          ³ ExpC3 -> codigo da tarefa para apontamento do recurso            º±±
±±º          ³ ExpC4 -> codigo do recurso                                       º±±
±±º          ³ ExpN1 -> quantidade do apontamento                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestao de Projetos                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA320ChkApon( cProjeto, cRevisa, cTarefa, cRecurso, nQtdeInfo, dData )
Local aAreaAF8		:= AF8->( GetArea() )
Local aAreaAF9		:= AF9->( GetArea() )
Local aAreaAE8		:= AE8->( GetArea() )
Local aAreaAFA		:= AFA->( GetArea() )
Local aAreaAFU		:= AFU->( GetArea() )
Local aAreaAJK		:= AJK->( GetArea() )
Local cCalend		:= ""
Local lRet 			:= .T.
Local nQtdeHrs		:= 0						// Qtde de horas do recurso
Local nQtdeApt		:= 0						// Qtde de horas apontadas na tarefa
Local nSaldo		:= 0

// Permite o apontamento de horas de uma tarefa que o recurso esteja alocado na tarefa;
DbSelectArea( "AFA" )
AFA->( DbSetOrder( 5 ) )
lRet := AFA->( DbSeek( xFilial( "AFA" ) + cProjeto + cRevisa + cTarefa + cRecurso ) )
If lRet
    // Considerar as horas alocadas de esforço do recurso na tarefa como Quantidade horas permitidas;
	nQtdeHrs := AFA->AFA_QUANT
	
	DbSelectArea( "AE8" )
	AE8->( DbSetOrder( 1 ) )
	If AE8->( DbSeek( xFilial( "AE8" ) + cRecurso ) )
		cCalend	:= AE8->AE8_CALEND
	EndIf

	// Apontamentos de horas
	DbSelectArea( "AFU" )
	AFU->( DbSetOrder( 1 ) )
	AFU->( DbSeek( xFilial( "AFU" ) + "1" + cProjeto + cRevisa + cTarefa ) )
	While AFU->( !Eof() ) .AND. AFU->( AFU_FILIAL + AFU_CTRRVS + AFU_PROJET + AFU_REVISA + AFU_TAREFA ) == xFilial( "AFU" ) + "1" + cProjeto + cRevisa + cTarefa
		If AllTrim( AFU->AFU_RECURS ) == AllTrim( cRecurso )
			nQtdeApt += AFU->AFU_HQUANT
	    EndIf

		AFU->( DbSkip() )
	End

	// Pré-Apontamentos Aprovados a serem aprovados
	DbSelectArea( "AJK" )
	AJK->( DbSetOrder( 1 ) )
	AJK->( DbSeek( xFilial( "AJK" ) + "1" + cProjeto + cRevisa + cTarefa ) )
	While AJK->( !Eof() ) .AND. AJK->( AJK_FILIAL + AJK_CTRRVS + AJK_PROJET + AJK_REVISA + AJK_TAREFA ) == xFilial( "AJK" ) + "1" + cProjeto + cRevisa + cTarefa
		// Situacao pendente
		If Empty( AJK->AJK_SITUAC ) .OR. AJK->AJK_SITUAC == "1"
			If AllTrim( AJK->AJK_RECURS ) == AllTrim( cRecurso )
				nQtdeApt += AJK->AJK_HQUANT
			EndIf
	    EndIf

		AJK->( DbSkip() )
	End

	// Obtem o saldo com base nas horas permitidas - horas apontadas
	nSaldo	:= nQtdeHrs - nQtdeApt
Else
	Help( " ", 1, "PXFUNAPON",, STR0085, 1, 0 ) //"O recurso não foi alocado para esta tarefa!"
EndIf

If lRet .AND. nSaldo <= 0
	//Ao incluir ou alterar um apontamento de horas do recurso que o saldo de horas for igual a zero deve 
	//apresentar uma mensagem advertindo o usuário que não pode incluir este apontamento;
	Help( " ", 1, "PXFUNAPON",, STR0086 + DtoC( dData ) + STR0087, 1, 0 ) //"O usuário não pode incluir este apontamento por insuficiencia de saldo!"
	lRet := .F.
EndIf

RestArea( aAreaAF8 )
RestArea( aAreaAF9 )
RestArea( aAreaAE8 )
RestArea( aAreaAFA )
RestArea( aAreaAFU )
RestArea( aAreaAJK )

Return nSaldo


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³A320BLQAP     ³ Autor ³Aldo Barbosa dos Santos ³ Data ³19/02/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³Exibe os apontamentos existentes na data                         ³±±
±±³           ³                                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A320BLQAP(lModo, cFil, cProj, cRev, cTar, cRecur, dData, cHora, cItem)
//lModo		-> .F. = apontamento direto; .T.=monitor de tarefas
//cFil		-> filial
//cProj		-> projeto
//cRev		-> revisao 
//cTar		-> tarefa
//cRecur		-> recurso	
//dData		-> data do apontamento
//cHora		-> hora do apontamento
//cItem		-> numero do item da acols (apontament  

Local aArea    := GetArea()
Local lRetorno := .T.


// Variaveis Private da Funcao
Private oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.                        
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.                        

// Privates das ListBoxes
Private aoBox := {}
Private ooBox

DEFINE FONT oFont NAME "Arial" SIZE 7,15 BOLD

// le as tabelas envolvidas e monta o arquivo e vetor de trabalho
aoBox := CarregaDados(lModo, cFil, cProj, cRev, cTar, cRecur, dData, cHora, cItem)
	  // aVet[1] -> Filial
	  //     [2] -> Projeto
	  //     [3] -> Revisao
	  //     [4] -> Tarefa
	  //     [5] -> Data
	  //     [6] -> Horario Inicial
	  //     [7] -> Horario Final
	  //     [8] -> Descricao

if ! Empty(aoBox)
	lRetorno := .F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Tela                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg TITLE "Apontamentos Concorrentes" FROM C(210),C(255) TO C(595),C(771) PIXEL
	
		if !lModo
			cMsg1 := "Existe uma tarefa em execucao no Monitor de Tarefas." 
			cMsg2 := "" 
			cMsg3 := "Este apontamento nao poderá ser incluido!" 
		Else	
			cMsg1 := "Existem apontamentos futuros ja realizados. Confirmando este apontamento, "
			cMsg2 := "a execucao no Monitor será interrompida se a execucao chegar em um dos    " 
			cMsg3 := "horarios já apontados. Deseja continuar com este apontamento ? " 
		Endif	
	
		@ C(004),C(005) Say "Filial:" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
		@ C(003),C(016) MsGet oEdit1 Var cFil When .F. Size C(010),C(009) COLOR CLR_BLACK PIXEL OF oDlg
	
		@ C(004),C(055) Say "Projeto:" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
		@ C(003),C(072) MsGet oEdit2 Var cProj When .F. Size C(040),C(009) COLOR CLR_BLACK PIXEL OF oDlg
	
		@ C(004),C(135) Say "Tarefa:" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
		@ C(003),C(150) MsGet oEdit3 Var cTar When .F. Size C(040),C(009) COLOR CLR_BLACK PIXEL OF oDlg
	
		@ C(017),C(005) Say "Data:" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
		@ C(016),C(016) MsGet oEdit1 Var dData When .F. Size C(015),C(009) COLOR CLR_BLACK PIXEL OF oDlg
	
		@ C(017),C(055) Say "Horario:" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
		@ C(016),C(072) MsGet oEdit2 Var cHora When .F. Size C(015),C(009) COLOR CLR_BLACK PIXEL OF oDlg
	
		if ! Empty(cItem)
			@ C(017),C(135) Say "Item:" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
			@ C(016),C(150) MsGet oEdit3 Var cItem When .F. Size C(010),C(009) COLOR CLR_BLACK PIXEL OF oDlg
	   Endif
	   
		// se for apontamento direto bloquear e nao dar opcao de continuar
		if ! lModo
			@ C(171),C(225) Button "Ok" Size C(027),C(012) PIXEL OF oDlg Action(lRetorno := .F.,oDlg:End() )
		Else	
			@ C(171),C(190) Button "Sim" Size C(027),C(012) PIXEL OF oDlg Action(lRetorno := .T.,oDlg:End() )
			@ C(171),C(225) Button "Nao" Size C(027),C(012) PIXEL OF oDlg Action(lRetorno := .F.,oDlg:End() )
		Endif	
	
		@ C(170),C(005) Say cMsg1 Size C(185),C(008) FONT oFont COLOR CLR_HRED PIXEL OF oDlg
		@ C(176),C(005) Say cMsg2 Size C(185),C(008) FONT oFont COLOR CLR_HRED PIXEL OF oDlg
		@ C(183),C(005) Say cMsg3 Size C(185),C(008) FONT oFont COLOR CLR_HRED PIXEL OF oDlg
	
	
		@ C(030),C(006)	ListBox ooBox Fields HEADER "Revisao","Data","Hr Inicial","Hr Final","Descricao";
								Size C(248),C(134) Of oDlg Pixel ColSizes 50,50 
		ooBox:SetArray(aoBox)
	
		// Cria ExecBlocks das ListBoxes
		ooBox:bLine := {|| {aoBox[ooBox:nAT,03],;  // Revisao
	                      aoBox[ooBox:nAT,05],;  // Data
	                      aoBox[ooBox:nAT,06],;  // Horario Inicial
	                      aoBox[ooBox:nAT,07],;  // Horario Final
	                      aoBox[ooBox:nAT,08],;  // Descricao
	                      }}
	
	ACTIVATE MSDIALOG oDlg CENTERED 
Endif
	
RestArea(aArea)

Return( lRetorno )
		


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³CarregaDados³ Autor ³Aldo Barbosa dos Santos    ³ Data ³19/02/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³Carrega os dados no arquivo de trabalho                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CarregaDados(lModo, cFil, cProj, cRev, cTar, cRecur, dData, cHora, cItem)
//lModo		-> .F. = apontamento direto; .T.=monitor de tarefas
//cFil		-> filial
//cProj		-> projeto
//cRev		-> revisao 
//cTar		-> tarefa
//cRecur		-> recurso	
//dData		-> data

Local aVet     := {}
Local lContinua := .T.
Local cAliasQry, cQuery

If lSQL
	// apontamento atraves do monitor
	cQuery := "Select AFW_FILIAL, AFW_PROJET, AFW_TAREFA, AFW_DATA, AFW_HORA, AFW_RECURS "
	cQuery += "From "+RetSqlName("AFW") + " AFW "
	cQuery += "Where AFW_FILIAL = '"+cFil+"' "
	cQuery += " and AFW_RECURS = '"+cRecur+"' "
	cQuery += " and AFW_PROJET = '"+cProj+"' "
	cQuery += " and AFW_TAREFA = '"+cTar+"' "
	cQuery += " and D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	
	TCSetField(cAliasQry,"AFW_DATA","D",8,0)
	TCSetField(cAliasQry,"AFW_HORA","C",5,0)
	
	if (cAliasQry)->( ! Eof())
		Aadd(aVet,{(cAliasQry)->AFW_FILIAL,;
		           (cAliasQry)->AFW_PROJET,;
		           cRev,;
		           (cAliasQry)->AFW_TAREFA,;
		           (cAliasQry)->AFW_DATA,;
		           (cAliasQry)->AFW_HORA,;
		           "",;
		           "Apontamento Monitor",;
		           (cAliasQry)->AFW_RECURS})
		(cAliasQry)->( DbcloseArea())
		MsErase(cAliasQry)
	Endif
	
	// verifica se o apontamento e o mesmo que esta em execucao
	if lModo .and. ! Empty(aVet)
		if cFil   == aVet[1,1] .and. ;
			cProj  == aVet[1,2] .and. ;
			cTar   == aVet[1,4] .and. ;
			dData  == aVet[1,5] .and. ;
		   cRecur == aVet[1,9]
		   aVet := {}
		   lContinua := .F.
		Endif	
	Endif
	
	if lModo .and. lContinua
		// selecao dos apontamentos ja efetivados
		cQuery := "SELECT AFU_FILIAL, AFU_PROJET, AFU_REVISA, AFU_TAREFA, AFU_DATA, AFU_HORAI, AFU_HORAF "
		cQuery += "FROM " + RetSqlName("AFU") + " "
		cQuery += "WHERE AFU_FILIAL = '"+cFil+"' "
		cQuery += " AND AFU_RECURS = '"+cRecur+"' "
		cQuery += " AND AFU_PROJET = '"+cProj+"' "
		cQuery += " AND AFU_TAREFA = '"+cTar+"' "
		cQuery += " AND AFU_DATA = '"+Dtos(dData)+"' "
		if lModo
			cQuery += " AND AFU_HORAI > '"+Left(Time(),5)+"' "
		Endif
		cQuery += " AND D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY AFU_DATA, AFU_HORAI "
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
		
		TCSetField(cAliasQry,"AFU_DATA","D",8,0)
		TCSetField(cAliasQry,"AFU_HORAI","C",5,0)
		TCSetField(cAliasQry,"AFU_HORAF","C",5,0)
	
		Do While (cAliasQry)->( ! Eof())
			Aadd(aVet,{(cAliasQry)->AFU_FILIAL,;
			           (cAliasQry)->AFU_PROJET,;
			           (cAliasQry)->AFU_REVISA,;
			           (cAliasQry)->AFU_TAREFA,;
			           (cAliasQry)->AFU_DATA,;
			           (cAliasQry)->AFU_HORAI,;
			           (cAliasQry)->AFU_HORAF,;
			           "",;
			           ""})
		           
			(cAliasQry)->( Dbskip())
		Enddo
		(cAliasQry)->( DbcloseArea())
		MsErase(cAliasQry)
	Endif
EndIf
Return( aClone( aVet ) )

//-------------------------------------------------------------------
/*/{Protheus.doc} PMS320QHS
Atualiza em tela a quantidade de horas do apontamento por periodo 
@author William Pianheri
@since 14/09/2017
@param
@version 1.0
/*/
//------------------------------------------------------------------
Function PMS320QHS()

Local cFilAE8	:= xFilial("AE8")

MV_PAR09	:=	PmsHrsItvl(	MV_PAR05, MV_PAR07, MV_PAR05, MV_PAR08, ReadValue("AE8", 1, cFilAE8 + MV_PAR01, "AE8_CALEND"), MV_PAR03, MV_PAR01, , .T.)

Return .T.
