#include "PMSA700.CH"
#include "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA700  ³ Autor ³ Guilherme Santos      ³ Data ³ 05-11-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Pré-apontamentos dos recursos.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSA700(aRotAuto, nOpcAuto, aGetCpos, cUser)

Local lPMS700Auto	:= .F.
Local lContinua		:= .T.
Local cFiltro		:= ""
Local bFiltraBrw 	:= {}
Local aIndexAJK 	:= {}
Local cFiltraAJK := 'AJK_FILIAL == "'+xFilial("AJK")+'" .AND. AJK_CTRRVS == "1"'
Local oBrowse

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atribui falso pois utiliza validacoes³
//³em comum com a rotina PMSA700.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE l700		:= .T.

Default cUser := Nil

If AMIIn(44)
	If PmsChkAJK(.T.)
		PRIVATE cCadastro	:= STR0001 //"Pre Apontamento de Recursos"
		PRIVATE aRotina		:= MenuDef()
	
		If nOpcAuto <> NIL
			If nOpcAuto > 0 
				If aRotAuto <> NIL .AND. (aGetCpos == NIL .OR. Len(aGetCpos) == 0 )
					If (nOpcAuto==3 .or. (nOpcAuto==4 .or. nOpcAuto==5))
						lPMS700Auto := .T.
						aGetCpos := aRotAuto
					Else
						lContinua := .F.
					EndIf
				EndIf
				
				If lContinua 
					dbSelectArea("AJK")
					bBlock := &( "{ |x,y,z,k,w,a,b,c| " + aRotina[ nOpcAuto,2 ] + "(x,y,z,k,w,a,b,c) }" )
					Eval( bBlock,Alias(),AJK->(Recno()),nOpcAuto,,,aGetCpos,lPMS700Auto,cUser )
				EndIf
			EndIf
		Else
			//
			//	PE para realizar o filtro no arquivo AJK antes de apresentar na browse.
			//
			If ExistBlock("PM700FIL")
				cFiltro:=ExecBlock("PM700FIL", .F., .F.)
				If ValType(cFiltro ) == "C" .and. !Empty(cFiltro)
					DbSelectArea("AJK")
					Set Filter to &cFiltro
					AJK->(DbGotop())
				EndIf
				mBrowse( 6, 1,22,75,"AJK",,,,,,,'xFilial("AJK")+"1"' , 'xFilial("AJK")+"1"')
				
				dbClearFilter()
			Else
				// Instanciamento da Classe de Browse
				oBrowse := FWMBrowse():New()
				// Definição da tabela do Browse
				oBrowse:SetAlias('AJK')
				
				// Definição de filtro
				oBrowse:SetFilterDefault( cFiltraAJK )
				
				// Titulo da Browse
				oBrowse:SetDescription(cCadastro)
				// Opcionalmente pode ser desligado a exibição dos detalhes
				oBrowse:DisableDetails()
				// Ativação da Classe
				oBrowse:Activate()
			EndIf

		EndIf
	EndIf
EndIf
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms700Psq³ Autor ³ Guilherme Santos       ³ Data ³ 06-11-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta uma tela de pesquisa no Browse .                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms700Psq(cAlias,nRecNo,nOpcx)
Local aPesq     := {}
Local aArea     := GetArea()
Local cDescri   := ""
Local cAux		:= ""
Local nIndex    := 0
                   
dbSelectArea("SIX")
dbSetOrder(1)
dbSeek(cAlias)
While SIX->(!Eof()) .AND. SIX->INDICE == cAlias

	If SIX->SHOWPESQ =="S"

		// retira o campo AJK_CTRRVS dos índices do AJK
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

WndxPesqui(,aPesq,xFilial()+"1",.F.)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms700Dlg³ Autor ³ Guilherme Santos       ³ Data ³ 06-11-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de manipulacao dos pre-apontamentos de recursos.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA700                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms700Dlg(cAlias,nRecNo,nOpcx,xRes1,xRes2,aGetCpos,lAuto,cUser)
Local oDlg
Local nRecAJK
Local aCampos
Local aCamposEdit
Local lOk         := .F.
Local lContinua   := .T.
Local l700Visual  := .F.
Local l700Exclui  := .F.
Local nX          := 0
Local dDataFec    := MVUlmes()
Local cTpApont    := ""

PRIVATE l700Inclui := .F.
PRIVATE l700Altera := .F.
PRIVATE nRecAlt    := 0
PRIVATE l700       := .T.
PRIVATE nTotal     := 0

Default cUser := Nil

// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
Do Case
	Case aRotina[nOpcx][4] == 2
		l700Visual  := .T.
		Visual 		:= .T.
		Inclui 		:= .F.
		Altera 		:= .F.
		Exclui 		:= .F.
	Case aRotina[nOpcx][4] == 3
		l700Inclui	:= .T.
		Visual 		:= .F.
		Inclui 		:= .T.
		Altera 		:= .F.
		Exclui 		:= .F.
	Case aRotina[nOpcx][4] == 4
		l700Altera	:= .T.
		Visual 		:= .F.
		Inclui 		:= .F.
		Altera 		:= .T.
		Exclui 		:= .F.
		nRecAlt		:= AJK->(RecNo())
	Case aRotina[nOpcx][4] == 5
		l700Exclui	:= .T.
		l700Visual	:= .T.
		Visual 		:= .F.
		Inclui 		:= .F.
		Altera 		:= .F.
		Exclui 		:= .F.
EndCase

// carrega as variaveis de memoria
RegToMemory("AJK",l700Inclui)

// tratamento do array aGetCpos com os campos Inicializados do AJK
aCampos	:= {}
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("AJK")
While !Eof() .and. SX3->X3_ARQUIVO == "AJK"
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

// Não permite editar o campo MOTIVO
aCamposEdit := {}
aEval(aCampos ,{|x|iIf(x$"AJK_CODME1;AJK_MOTIVO" ,.T. ,aAdd(aCamposEdit,x)) })

// Carrega as variaveis de memoria (campos da tabela AJK) de acordo com o array aGetcpos
If aGetCpos <> Nil 
	For nX := 1 to Len(aGetCpos)
		cCpo	:= "M->"+Trim(aGetCpos[nX][1])
		&cCpo	:= aGetCpos[nX][2]
	Next nX
EndIf

If !Empty(M->AJK_PROJET) .and. (!l700Visual .OR. l700Exclui)
	If !PmsVldFase("AF8", M->AJK_PROJET, "88")
		lContinua := .F.
	EndIf
EndIf 
                   
// verificar data do ultimo fechamento do Projeto
If lContinua .And. (l700Altera .Or. l700Exclui)
	AF8->(dbSetOrder(1))
	If AF8->(MsSeek(xFilial()+M->AJK_PROJET))
		If !Empty(AF8->AF8_ULMES) .and. (DTOS(AF8->AF8_ULMES) >= dtos(M->AJK_DATA))
			Aviso(STR0002 ,STR0003 + DTOC(AF8->AF8_ULMES) + STR0004,{STR0005},2) //"Operacao Invalida"###"Esta operacao nao podera ser efetuada pois este projeto ja esta fechado com data "###". Verifique o apontamento selecionado."###"Fechar"
			lContinua :=.F.
		EndIf
	EndIf
EndIf

//
// Se for inclusão com os campos projeto, revisao e tarefa preenchidos, verifica se o usuario tem permissão de execuão da rotina
//
If lContinua .AND. l700Inclui .and. !Empty(M->AJK_PROJET) .and. !Empty(M->AJK_REVISA) .and. !Empty(M->AJK_TAREFA)
	If !PmsChkUser(M->AJK_PROJET,M->AJK_TAREFA,,"",3,"PREREC",M->AJK_REVISA,cUser)
		Aviso(STR0006,STR0007,{"Ok"},2) //"Usuário sem Permissão."###"Usuário sem permissão para executar a operacao selecionada. Verifique os direitos do usuário na estrutura deste projeto ou o projeto selecionado."
		lContinua	:=.F.
	EndIf
EndIf

If lContinua .AND. !l700Inclui
	If !SoftLock("AJK")
		lContinua := .F.
	Else
		nRecAJK := AJK->(RecNo())
	Endif

	// verifica os direitos do usuario
	Do Case
		Case l700Visual .and. !l700Exclui
			If !PmsChkUser(AJK->AJK_PROJET, AJK->AJK_TAREFA, NIL, "", 2, "PREREC", AJK->AJK_REVISA, cUser, .F.)
				Aviso(STR0006,STR0007,{"Ok"},2) //"Usuário sem Permissão."###"Usuário sem permissão para executar a operacao selecionada. Verifique os direitos do usuário na estrutura deste projeto ou o projeto selecionado."
				lContinua	:=.F.
			EndIf
		Case l700Altera
			If !PmsChkUser(AJK->AJK_PROJET, AJK->AJK_TAREFA, NIL, "", 3, "PREREC", AJK->AJK_REVISA, cUser, .F.)
				Aviso(STR0006,STR0007,{"Ok"},2) //"Usuário sem Permissão."###"Usuário sem permissão para executar a operacao selecionada. Verifique os direitos do usuário na estrutura deste projeto ou o projeto selecionado."
				lContinua	:=.F.
			EndIf
		Case l700Exclui
			If !PmsChkUser(AJK->AJK_PROJET, AJK->AJK_TAREFA, NIL, "", 4, "PREREC", AJK->AJK_REVISA, cUser, .F.)
				Aviso(STR0006,STR0007,{"Ok"},2) //"Usuário sem Permissão."###"Usuário sem permissão para executar a operacao selecionada. Verifique os direitos do usuário na estrutura deste projeto ou o projeto selecionado."
				lContinua	:=.F.
			EndIf
	EndCase
	
	If lContinua .AND. (l700Altera .Or. l700Exclui)
		If M->AJK_SITUAC =="2" // aprova
			Aviso(STR0002 ,STR0030,{"Ok"},2)  
			lContinua	:=.F.
		EndIf
	EndIf
	
EndIf

If l700Exclui .And. ExistBlock("PM700EXC")
	lContinua := ExecBlock("PM700EXC", .F., .F. )
EndIf	

If lContinua
	// se a rotina nao for automatica, mostra a tela	
	If !lAuto
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO TranslateBottom(.F.,28),80 OF oMainWnd
			oEnch := MsMGet():New("AJK",AJK->(RecNo()),nOpcx,,,,aCampos,{,,(oDlg:nClientHeight - 4)/2,},aCamposEdit,3,,,,oDlg)
		If nOpcx == 3 // Na inclusão nome do aprovador deve estar em branco.
			M->AJK_NOMAPR := ""
		EndIf	
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||IIf(!l700Exclui,If(Obrigatorio(oEnch:aGets,oEnch:aTela) .And. PMS700HRF() .And. PMS700Grv(),(oDlg:End(),lOk:=.T.),Nil),(oDlg:End(),lOk:=.T.))},{||oDlg:End()}) //"PRODUTO"###"Selecionar Tarefa"
	//
	// Eh uma rotina automatica
	//
	Else
		Private aTELA[0][0]
		Private aGETS[0]
		Private aAutoCab := aclone(aGetCpos)
		
		// se for visualizacao, nao deve validar campos.
		If l700Visual .AND. (!l700Inclui .AND. !l700Altera .AND. !l700Exclui)
			lOk := .F.
		Else
			If EnchAuto(cAlias,aAutoCab,{|| Obrigatorio(aGets,aTela) .And. Pms700ValOpe(If(lAuto,cUser,Nil)) .And. iIf(!l700Exclui,PMS700Grv() .And. PMS700HRI() .And. PMS700HRF(M->AJK_HORAF),.T.) },nOpcx)
				lOk := .T.
			EndIf
		EndIf
	EndIf
EndIf

If lOk .And. (l700Inclui .Or. l700Altera .Or. l700Exclui)
	If l700Inclui 
		// verifica os direitos do usuario na inclusao
		If !PmsChkUser(M->AJK_PROJET,M->AJK_TAREFA,,"",3,"PREREC",M->AJK_REVISA,cUser)
			Aviso(STR0006,STR0007,{"Ok"},2) //"Usuário sem Permissão."###"Usuário sem permissão para executar a operacao selecionada. Verifique os direitos do usuário na estrutura deste projeto ou o projeto selecionado."
			lContinua	:=.F.
		EndIf
	ElseIf l700Altera

		// verifica os direitos do usuario na alteracao
		If !PmsChkUser(AJK->AJK_PROJET,AJK->AJK_TAREFA,,"",3,"PREREC",AJK->AJK_REVISA,cUser)
			Aviso(STR0006,STR0007,{"Ok"},2) //"Usuário sem Permissão."###"Usuário sem permissão para executar a operacao selecionada. Verifique os direitos do usuário na estrutura deste projeto ou o projeto selecionado."
			lContinua	:=.F.
		EndIf
	EndIf
	If lContinua    
		cTpApont := Posicione("AE8",1,xFilial("AE8")+M->AJK_RECURS,"AE8_TPREAL")                             
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apenas verifica esta condição caso o tipo de recurso (AE8_TPREAL) esteja configurado como (1=Custo Medio/FIFO)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If dDataFec >= dDataBase .AND. cTpApont == "1" // tipo apontamento 1=Custo Medio/FIFO
			Help ( " ", 1, "FECHTO" )
			lContinua := .F.
		EndIf	
	   
		if lContinua
			Begin Transaction
				Pms700Grava(nRecAJK,l700Exclui)
			End Transaction
		Endif
	EndIf
EndIf

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms700Grava³ Autor ³ Guilherme Santos     ³ Data ³ 06-11-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a gravacao do apontamento do recurso.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA700                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms700Grava(nRecAJK,lDeleta,lAvalAJK1,lAvalAJK2)

Local lAltera	:= (nRecAJK!=Nil)
Local bCampo 	:= {|n| FieldName(n) }
Local nX		:= 0

DEFAULT lAvalAJK1	:= .T.
DEFAULT lAvalAJK2	:= .T.

If !lDeleta
	If lAltera
		dbSelectArea("AJK")
		dbGoto(nRecAJK)
		
		DbSelectArea("AF8")
		DbSetOrder(1)
		DbSeek(xFilial("AF8") + AJK->AJK_PROJET)

		dbSelectArea("AJK")
		RecLock("AJK",.F.)
	Else
		dbSelectArea("AJK")
		RecLock("AJK",.T.)
	EndIf
	For nx := 1 TO FCount()
		FieldPut(nx,M->&(EVAL(bCampo,nx)))
	Next nx
	
	AJK->AJK_REVISA := AF8->AF8_REVISA
	AJK->AJK_FILIAL	:= xFilial("AJK")
	AJK->AJK_CTRRVS	:= "1"

	If !(AJK->AJK_SITUAC $ "2;3")
		AJK->AJK_SITUAC := "1"
	Endif

	// Se for um pre-apontamento rejeitado.
	If M->AJK_SITUAC == "3"
		AJK->AJK_USRAPR := ""
	EndIf
	
	MsUnlock()
	MSMM(NIL, TamSx3("AJK_OBS")[1], NIL, M->AJK_OBS, 1, NIL, NIL, "AJK", "AJK_CODMEM")
	If M->AJK_SITUAC == "3"
		MSMM(M->AJK_CODME1, TamSx3("AJK_MOTIVO")[1], NIL, M->AJK_MOTIVO, 2, NIL, NIL, "AJK", "AJK_CODME1")
	EndIf

	If ExistBlock("PMSGrvAJK")
		ExecBlock("PMSGrvAJK", .F., .F., {	AJK->AJK_FILIAL,AJK->AJK_CTRRVS,;
											AJK->AJK_PROJET,AJK->AJK_REVISA,;
											AJK->AJK_TAREFA,AJK->AJK_RECURS,;
											AJK->AJK_DATA	})
	EndIf
	
	MsUnlock()	
Else
	AJK->(dbGoto(nRecAJK))
	
	If ExistBlock("PMDelAJK")
		ExecBlock("PMDelAJK", .F., .F., { nRecAJK })
	EndIf	

	RecLock("AJK",.F.,.T.)
	dbDelete()
	MsUnlock()
EndIf

Return NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS700Data³ Autor ³ Guilherme Santos      ³ Data ³ 06/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a data em relacao a data do Ultimo fechamento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMS700                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms700Data()
Local lRet   := .T.         
Local cProjeto
Local dData
Local cHoraIni
Local cHoraFim
Local nQtdHora
Local nPosHQtd  := 0
Local nPosHoraI := 0 
Local nPosHoraF := 0 
Local lAutomato  := Iif (IsBlind(),.T.,.F.)
Local aColPMS700  := {}

aColPMS700 := PMS700aCol()

If !l700
	nPosHQtd  := aScan(aHeader,{|x| AllTrim(x[2])=="AJK_HQUANT"})
	nPosHoraI := aScan(aHeader,{|x| AllTrim(x[2])=="AJK_HORAI"})
	nPosHoraF := aScan(aHeader,{|x| AllTrim(x[2])=="AJK_HORAF"})
	
	cProjeto := aColPMS700[n,aScan(aHeader,{|x|Alltrim(x[2])=="AJK_PROJET"})]
	dData		:= M->AJK_DATA // Pego a data na memoria, mesmo usando aCols
	cHoraIni	:= aColPMS700[n,nPosHoraI]
	cHoraFim	:= aColPMS700[n,nPosHoraF]
	nQtdHora	:= aColPMS700[n,nPosHQtd]
Else
	cProjeto := M->AJK_PROJET
	dData		:= M->AJK_DATA
	cHoraIni	:= M->AJK_HORAI
	cHoraFim	:= M->AJK_HORAF
	nQtdHora	:= M->AJK_HQUANT	
EndIf

	AF8->(dbSetOrder(1))
	AF8->(MsSeek(xFilial() + cProjeto))
	
	If AF8->AF8_ULMES >= dData
		Aviso(STR0002, STR0003 + DTOC(AF8->AF8_ULMES) + STR0004, {STR0005}, 2) //"Operacao Invalida"###"Esta operacao nao podera ser efetuada pois este projeto ja esta fechado com data "###". Verifique o apontamento selecionado."###"Fechar"
		lRet:=.F.
	EndIf


If lRet
	If !l700
		aColPMS700[n,nPosHQtd]	:= 0
		aColPMS700[n,nPosHoraI]	:= Space(Len(cHoraIni))
		aColPMS700[n,nPosHoraF]	:= Space(Len(cHoraFim))		
	Else
		M->AJK_HQUANT	:= 0
		M->AJK_HORAI	:= Space(Len(M->AJK_HORAI))
		M->AJK_HORAF	:= Space(Len(M->AJK_HORAF))
	EndIf
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms700Sel³ Autor ³ Guilherme Santos       ³ Data ³ 06-11-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria uma janela de consula das tarefas do Projeto.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms700Sel()

Local aRet := PmsSelTsk(STR0008,"AF8/AFC/AF9","AF9",STR0009) //"Selecione a Tarefa"###"Selecao Invalida. Esta consulta permite apenas a selecao das Tarefas do projeto. Varifique o elemento selecionado."

If !Empty(aRet)
	AF9->(dbGoto(aRet[2]))

	// valida a permissao do usuario
	If Pms700ValOpe() 
		M->AJK_PROJET	:= AF9->AF9_PROJET
		M->AJK_TAREFA	:= AF9->AF9_TAREFA
		M->AJK_REVISA	:= AF9->AF9_REVISA
	EndIf
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms700ValOpe³ Autor ³ Fabio Rogerio Pereira  ³ Data ³ 06-11-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a permissao do usuario.						           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                               	       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pms700ValOpe(cUsr)
Local lRet:= .T.
Default cUsr := Nil

If !PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,3,"PREREC",AF9->AF9_REVISA,cUsr)//Alterar
	Aviso(STR0002,STR0010,{STR0005},2) //"Operacao Invalida"###"Operacao nao disponivel para o usuario nesta tarefa!"###"Fechar"
	lRet:= .F.
EndIf         

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms700Ok³ Autor ³ Edson Maricate          ³ Data ³ 06-11-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se todos os parametros estao corretos.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms700Ok(aConfig)
Local dx
Local nX
Local lRet	 := .T.
Local aRecur := {} 
	
	// se a hora inicial for maior ou igual a hora final
	If (Substr(aConfig[7],1,2) + Substr(aConfig[7],4,2) >= Substr(aConfig[8],1,2) + Substr(aConfig[8],4,2))
		Aviso(STR0011, STR0012, {"Ok"},2) //"Atencao!"###"A hora final nao podera ser menor que a hora inicial. Verifique a hora digitada"
		lRet := .F.
	EndIf

	If lRet .AND. Empty(aConfig[1]) .And. Empty(aConfig[2])
		Aviso(STR0011, STR0013, {"Ok"},2) //"Atencao!"###"O Campo Recurso ou o Campo Equipe deve ser preenchido."
		lRet := .F.
	Else
		aRecur := Pms700EqR(aConfig)
		If ! Empty( aRecur )
			For dx := aConfig[5] to aConfig[6]
				If aConfig[DOW(dx)+9]
					For nX:= 1 to Len(aRecur)
						dbSelectArea("AJK")
						dbSetOrder(2)
						dbSeek(xFilial("AJK")+"1"+aRecur[nX]+DTOS(dx))
						While !Eof() .And. lRet .And. xFilial("AJK")+"1"+aRecur[nX]+DTOS(dx)==;
											AJK->AJK_FILIAL+AJK->AJK_CTRRVS+AJK->AJK_RECURS+DTOS(AJK->AJK_DATA)
							If  (Substr(aConfig[7],1,2)+Substr(aConfig[7],4,2) >= Substr(AJK->AJK_HORAI,1,2)+Substr(AJK->AJK_HORAI,4,2) .And. Substr(aConfig[7],1,2)+SUbstr(aConfig[7],4,2) <= Substr(AJK->AJK_HORAF,1,2)+Substr(AJK->AJK_HORAF,4,2)).Or.;
								(Substr(aConfig[8],1,2)+Substr(aConfig[8],4,2) <= Substr(AJK->AJK_HORAI,1,2)+Substr(AJK->AJK_HORAI,4,2) .And. Substr(aConfig[8],1,2)+SUbstr(aConfig[8],4,2) >= Substr(AJK->AJK_HORAF,1,2)+Substr(AJK->AJK_HORAF,4,2))
								Aviso(STR0011, STR0014,{"Ok"},2) //"Atencao!"###"Ja existem apontamentos deste(s) recurso(s) gravados neste periodo. Verifique o periodo informado."
								lRet := .F.
								Exit
							EndIf
							
							dbskip()
						End
					Next nX
				EndIf
			Next dX
	    Else
			Aviso(STR0011, STR0015,{"Ok"},2) //"Atencao!"###"Não existe nenhum recurso ativo na equipe informada."
			lRet := .F.
			
	    EndIf
		If lRet .And. aConfig[9] > 24 
			Aviso(STR0011 , STR0016,{"Ok"},2) //"Atencao!"###"A quantidade de horas apontadas nao deve ser maior que 24hs!"
			lRet := .F.
		EndIf
		
	EndIf
	
Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms700Trf³ Autor ³ Guilherme Santos       ³ Data ³ 06-11-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao do projeto+revisao+tarefa.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms700Trf()
Local lRet	      := .F.
Local lAutomato   := Iif (IsBlind(),.T.,.F.)
Local aColPMS700  := {}

aColPMS700 := PMS700aCol()

If l700
	lRet := ExistCpo("AF9",M->AJK_PROJET+M->AJK_REVISA+M->AJK_TAREFA,1)
Else
	lRet := ExistCpo("AF9",aColPMS700[n][aScan(aHeader,{|x|Alltrim(x[2])=="AJK_PROJET"})] + aColPMS700[n][aScan(aHeader,{|x|Alltrim(x[2])=="AJK_REVISA"})]+M->AJK_TAREFA,1)
EndIf

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms700Grv³ Autor ³ Guilherme Santos       ³ Data ³ 06/11/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o custo do recurso conforme o apontamento(quantidade).³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMS700Grv()
Local lReturn := .T.

If ExistBlock("PMA700TOK")
	lReturn	:= ExecBlock("PMA700TOK", .F., .F.)
EndIf

Return lReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Pms700EqR³ Autor ³ Guilherme Santos       ³ Data ³ 06-11-07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Ira retornar os recursos para a equipe informada no aConfig[2]³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pms700EqR(aConfig)
Local aArea     := {}
Local aRecur	:= {}
	
	If !Empty(aConfig[2])
		aArea	:= GetArea()
		AE8->(DbSetOrder(4))
		If AE8->(DbSeek(xFilial()+aConfig[2]))
			While AE8->AE8_FILIAL+AE8->AE8_EQUIP==xFilial()+aConfig[2]
				If AE8->AE8_ATIVO != "2"
					aAdd(aRecur,AE8->(AE8_RECURS))
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
±±³Programa  ³MenuDef   ³ Autor ³ Guilherme Santos      ³ Data ³ 06/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array aRotina:                                ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0017,"PMS700Psq" , 0 , 1,,.F.},; //"Pesquisar"
					 	{ STR0018,"PMS700Dlg" , 0 , 2 },; //"Visualizar"
						{ STR0019,"PMS700Dlg" , 0 , 3 },; //"Incluir"
						{ STR0020,"PMS700Dlg" , 0 , 4 },; //"Alterar"
						{ STR0021,"PMS700Dlg" , 0 , 5 } } //"Excluir"
Return(aRotina)								

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsChkAJK³ Autor ³ Guilherme Santos       ³ Data ³ 05-11-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica a existencia do arquivo AJK criado no SX3.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsChkAJK(lAviso)
Local lRet := .F.
Local aArea	:= GetArea()

dbSelectArea("SX2")
dbSetOrder(1)
If MsSeek("AJK")
	lRet := .T.
Else
	If lAviso
		Aviso(STR0022,STR0023,{STR0005},2) //"Atencao"###"Opcao nao disponivel nesta versao. Verifique a existecia do arquivo AJK no SX atual."###"Fechar"
	EndIf
EndIf

RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A700HrSld³ Autor ³ Reynaldo Miyashit      ³ Data ³  05/12/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a quantidade de horas restantes do recurso            ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A700HrSld(cProjeto ,cRevisa ,cTarefa ,cRecurso,nLinha)
Local nQtdTsk   := 0
Local nQtdApt   := 0
Local aArea     := GetArea()
Local aAreaAFA  := AFA->(GetArea())
Local aAreaAFU  := AFU->(GetArea())
Local nx        := 0
Local nHQuant   := 0
Local nAJKProj  := 0
Local nAJKRev   := 0
Local nAJKTrf   := 0
Local nAJKRec   := 0
Local nAJKSit   := 0
Local nQtdTot   := 0 
Local cProj     := ""
Local cRev      := ""
Local cTar      := ""
Local cRec      := ""
Local cSituac   := "" 
Local nPosRec		:=	0
Local nQtdPreAp	:=	0
Local lCalcula	:= .T.
Local lFunc701	:=	.F.
Local lAutomato  := Iif (IsBlind(),.T.,.F.)
Local aColPMS700  := {}


Default nLinha	:=	0

aColPMS700 := PMS700aCol()

nTotal:=0

lFunc701	:= IsInCallStack("PMSA701") .OR. lAutomato .and. Type("oGet:aCols") <> "U"

If lFunc701
	nHQuant   := aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_HQUANT"})
	nAJKProj  := aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_PROJET"})
	nAJKRev   := aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_REVISA"})
	nAJKTrf   := aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_TAREFA"})
	nAJKRec   := aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_RECURS"})
	nAJKSit   := aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_SITUAC"})
	nPosRec	  :=aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_REC_WT"})
Endif
IF nLinha>0 .and. lFunc701//pre apontamento mod 2
	nAt:=nLinha
ElseIf IsIncallStack("InitPad") .and. lFunc701
	lCalcula:=.F.
ElseIf  ( Type("oGet:nAt") <> "U" )
	nAt	:= oGet:nAt	  
else
	lCalcula := Type("M->AJK_RECURS") <> "U" .and. !(Empty(M->AJK_RECURS))
	nAt	:= 999999
EndIf

If lCalcula
	dbSelectArea("AFA")
	dbSetOrder(5)
	MsSeek(xFilial("AFA")+cProjeto+cRevisa+cTarefa+cRecurso)
	While AFA->(!EOF()) .AND. ;
	      AFA->(AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA+AFA_RECURS) == xFilial("AFA")+cProjeto+cRevisa+cTarefa+cRecurso
		nQtdTsk += AFA->AFA_QUANT
		dbSkip()
	EndDo
	
	dbSelectArea("AFU")
	dbSetOrder(1)
	MsSeek(xFilial("AFU")+"1"+cProjeto+cRevisa+cTarefa+cRecurso)
	While AFU->(!EOF()) .AND. ;
	      AFU->(AFU_FILIAL+AFU_PROJET+AFU_REVISA+AFU_TAREFA+AFU_RECURS) == xFilial("AFU")+cProjeto+cRevisa+cTarefa+cRecurso
		nQtdApt += AFU->AFU_HQUANT
		dbSkip()
	EndDo
	
	dbSelectArea("AJK")
	dbSetOrder(1)
	MsSeek(xFilial("AJK")+"1"+cProjeto+cRevisa+cTarefa+cRecurso)
	While AJK->(!EOF()) .AND. ;
	      AJK->(AJK_FILIAL+AJK_PROJET+AJK_REVISA+AJK_TAREFA+AJK_RECURS) == xFilial("AJK")+cProjeto+cRevisa+cTarefa+cRecurso
			If AJK->AJK_SITUAC <> "3"
				If lFunc701//pre apontamento mod 2
					If aScan(aColPMS700,{|x|x[nPosRec] ==	AJK->(RECNO())})> 0
						dbSkip()
						Loop
					Endif
				Endif
				If !AJK->AJK_SITUAC == "2"
					nQtdPreAp += AJK->AJK_HQUANT
				EndIf
			EndIf
		dbSkip()
	EndDo
	
	If lFunc701 // somente quando for apontamento mod. II
		// Verifica se é uma inclusao
		If Len(aColPMS700)==1 .and. Empty( aColPMS700[1][nAJKProj] )	
	    	nQtdTsk := 0
		else
			For nx := 1 to Len(aColPMS700)
				cProj      := Iif( aColPMS700[nx][nAJKProj]==Nil, "", aColPMS700[nx][nAJKProj] )
				cRev       := Iif( aColPMS700[nx][nAJKRev] ==Nil, "", aColPMS700[nx][nAJKRev]  )	
				cTar       := Iif( aColPMS700[nx][nAJKTrf] ==Nil, "", aColPMS700[nx][nAJKTrf]	 )
				cRec       := Iif( aColPMS700[nx][nAJKRec] ==Nil, "", aColPMS700[nx][nAJKRec]  )
				cSituac    := Iif( aColPMS700[nx][nAJKSit] ==Nil, "", aColPMS700[nx][nAJKSit]  )
			    If nAt <> nx  
					IF (cProjeto+cRevisa+cTarefa+cRecurso == cProj+cRev+cTar+cRec) .AND. (empty(cSituac) .or. cSituac == "1") .AND. !(aColPMS700[nx][Len(aColPMS700[nx])] )
						nQtdTot  += Iif( aColPMS700[nx][nHQuant] ==Nil, 0, aColPMS700[nx][nHQuant]  )
					ENDIF
				Else
					If AllTrim(cSituac)=='2'//foi aprovado. O Registro foi calculado pela AFU e deve desconsiderar nesta linha
						nQtdTot:=nQtdTot-aColPMS700[nx][nHQuant]
					Endif
				Endif			
			Next nx
		EndIf	
	EndIf	                    

	RestArea(aAreaAFU)
	RestArea(aAreaAFA)
	RestArea(aArea)
	                                      
	nTotal := nQtdTsk - nQtdApt - nQtdTot - nQtdPreAp

Endif

Return Iif( nTotal<0 , 0 , nTotal )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS700HRI³ Autor ³ Reynaldo Miyashita     ³ Data ³ 06-12-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da hora inicial informada no apontamento do recurso.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS700HRI(cHora)
Local aArea        := GetArea()
Local aAreaAE8     := AE8->(GetArea())
Local aAreaAFU     := AFU->(GetArea())
Local aAreaAJK     := AJK->(GetArea())
Local cHoraI       := ""
Local cHoraF       := ""
Local cRecurso     := ""
Local lRet         := .T.
Local nInterv      := 60 / GetMV("MV_PRECISA")
Local x            := 0
Local nX           := 0
Local dData
Local nPos_RECURS  := 0
Local nPos_DATA    := 0
Local nPos_HORAI   := 0
Local nPos_HORAF   := 0
Local nPos_DOCUM   := 0
Local nPos_PROJETO := 0
Local nPos_TAREFA  := 0
Local nPos_HQUANT  := 0
Local nPos_SLDHR   := 0
Local nPos_SITUAC  := 0
Local nTam         := TamSx3("AJK_ITEM")[1]
Local nSaldo       := 0
Local nQtdHrAnt	   := 0
Local lAutomato	   := Iif (IsBlind(),.T.,.F.)
Local aColPMS700   := {}

DEFAULT cHora      := M->AJK_HORAI 

aColPMS700 := PMS700aCol()

If l700
	cRecurso := M->AJK_RECURS
	dData    := M->AJK_DATA
	cHoraI   := M->AJK_HORAI
	cHoraF   := M->AJK_HORAF
	
	If l700Altera
		nQtdHrAnt := AJK->AJK_HQUANT
	EndIf
Else
	nPos_RECURS  := aScan(aHeader,{|x|AllTrim(x[2])=="AJK_RECURS"})
	nPos_DATA    := aScan(aHeader,{|x|AllTrim(x[2])=="AJK_DATA"})
	nPos_HORAI   := aScan(aHeader,{|x|AllTrim(x[2])=="AJK_HORAI"})
	nPos_HORAF   := aScan(aHeader,{|x|AllTrim(x[2])=="AJK_HORAF"})
	nPos_PROJETO := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_PROJET"})
	nPos_TAREFA  := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_TAREFA"})
	nPos_HQUANT	 := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_HQUANT"})
	nPos_SLDHR	 := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_SLDHR"})
	nPos_SITUAC  := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_SITUAC"})
	cRecurso     := aColPMS700[n ,nPos_RECURS]
	dData        := aColPMS700[n ,nPos_DATA]
	cHoraI		 := aColPMS700[n ,nPos_HORAI]
	cHoraF	 	 := aColPMS700[n ,nPos_HORAF]	
EndIf 

For x := 1 to GetMv("MV_PRECISA")
	Do  Case 
		Case x == 1
			 If Val(Substr(cHora,4,2)) < nInterv
				 If Val(Substr(cHora,4,2)) < nInterv/2 
				    cHora := Substr(cHora,1,3)+"00"
				    exit
				 Else
				    cHora := Substr(cHora,1,3)+Alltrim(Str(nInterv))
				    exit
				 EndIf
		     EndIf

		Case x > 1 .AND. x < GetMv("MV_PRECISA")
			 If Val(Substr(cHora,4,2)) > (nInterv*(x-1)) .AND. Val(Substr(cHora,4,2)) < (nInterv*x)
			    If Val(Substr(cHora,4,2)) < ((nInterv*x)-(nInterv/2))
			       cHora := Substr(cHora,1,3)+Alltrim(Str(nInterv*(x-1)))
			       exit
				Else
			       cHora := Substr(cHora,1,3)+Alltrim(Str(nInterv*x))
			       exit
			 	EndIf
			 EndIf

		Case x == GetMv("MV_PRECISA")
			 If Val(Substr(cHora,4,2)) > (nInterv*(x-1)) .AND. Val(Substr(cHora,4,2)) < (nInterv*x)
			 	If Val(Substr(cHora,4,2)) < ((nInterv*x)-(nInterv/2)) .AND. Val(Substr(cHora,4,2)) > nInterv*(x-1)
			       cHora := Substr(cHora,1,3)+Alltrim(Str(nInterv*(x-1)))
			       exit
			    Else
			       cHora := Soma1(Substr(cHora,1,2))+":00"
			       exit
			    EndIf
			 EndIf
	End Case
Next x

//
// Conforme ISO 8601, o formato de hora de um dia deve ser efetuado da seguinte forma:
//
// Primeira hora do dia é 00:00 
// Ultima hora do dia é 23:59
//
// Sempre que se estiver se referindo a 1 dia.
//
//If cHora == "24:00"
  //	cHora := "23:59"
//EndIf           

M->AJK_HORAI := cHora

If !Empty(cRecurso) .And. !Empty(dData)
	dbSelectArea("AE8")
	dbSetOrder(1)
	MsSeek(xFilial('AE8')+cRecurso)

	If AE8->AE8_UMAX <= 100 
		If !l700
			For nX := 1 to Len(aColPMS700)
				If !(nX == n ) .AND. !aColPMS700[nX][Len(aHeader)+1] ;
					.AND. cRecurso == aColPMS700[nX][nPos_RECURS]  .AND. dData == aColPMS700[nX][nPos_DATA]
				  	If (;
				       	(Substr(cHora,1,2) + Substr(cHora,4,2) >= Substr(aColPMS700[nX][nPos_HORAI],1,2) + Substr(aColPMS700[nX][nPos_HORAI],4,2) .And.;
				       	Substr(cHora,1,2) + Substr(cHora,4,2) < Substr(aColPMS700[nX][nPos_HORAF],1,2) + Substr(aColPMS700[nX][nPos_HORAF],4,2));
				       	.Or. ;
				       	(Substr(cHora,1,2)  + Substr(cHora,4,2)  < Substr(aColPMS700[nX][nPos_HORAI],1,2) + Substr(aColPMS700[nX][nPos_HORAI],4,2) .And.;
				       	Substr(cHoraF,1,2) + Substr(cHoraF,4,2) > Substr(aColPMS700[nX][nPos_HORAI],1,2) + Substr(aColPMS700[nX][nPos_HORAI],4,2));
				       )
					   
						Aviso(STR0022,STR0028,{"Ok"},2) //"Atencao!"###"Ja existem apontamentos gravados para este recurso neste periodo. Verifique a hora informada"
						lRet := .F.
						Exit
						
					EndIf
				EndIf
			Next nX
		EndIf

		If lRet
			dbSelectArea("AFU")
			dbSetOrder(3)
			dbSeek(xFilial("AFU") + "1" + cRecurso + DTOS(dData))
			While !Eof() .And. lRet .And. xFilial("AFU") + "1" + cRecurso + DTOS(dData) ==;
									AFU->AFU_FILIAL + AFU->AFU_CTRRVS + AFU->AFU_RECURS + DTOS(AFU->AFU_DATA)
				
				//Caso seja executado sem interface, recebo o Recno do registro posicionado
				nRecAlt := Iif(!lAutomato,nRecAlt,AJK->(RecNo()))
				
				If nRecAlt != RecNo() .And. ;
				        (;
				        (Substr(cHora,1,2) + Substr(cHora,4,2) >= Substr(AFU->AFU_HORAI,1,2) + Substr(AFU->AFU_HORAI,4,2) .And.;
				         Substr(cHora,1,2) + Substr(cHora,4,2) < Substr(AFU->AFU_HORAF,1,2) + Substr(AFU->AFU_HORAF,4,2));
				        .Or. ;
				        (Substr(cHora,1,2)  + Substr(cHora,4,2)  < Substr(AFU->AFU_HORAI,1,2) + Substr(AFU->AFU_HORAI,4,2) .And.;
				         Substr(cHoraF,1,2) + Substr(cHoraF,4,2) > Substr(AFU->AFU_HORAI,1,2) + Substr(AFU->AFU_HORAI,4,2));
				        )
					lRet := .F.
					Exit
				EndIf
				dbSkip()
			EndDo
			If lRet
				dbSelectArea("AJK")
				dbSetOrder(2)
				dbSeek(xFilial("AJK") + "1" + cRecurso + DTOS(dData))
				While !Eof() .AND. lRet .AND. xFilial("AJK") + "1" + cRecurso + DTOS(dData) == AJK->AJK_FILIAL + AJK->AJK_CTRRVS + AJK->AJK_RECURS + DTOS(AJK->AJK_DATA)
                                                                         
					If (!l700 .AND. PMA700AJK(aHeader,aColPMS700)) .or. AJK->AJK_SITUAC == "3"
						AJK->( dbSkip() )
						Loop
					EndIf
					
					//Caso seja executado sem interface, recebo o Recno do registro posicionado
					nRecAlt := Iif(!lAutomato,nRecAlt,AJK->(RecNo()))
					
					      // isso serve para nao considerar a propria linha que esta sendo alterada.
					If nRecAlt != AJK->( RecNo() )  .and. ;
							(;                                
				        (Substr(cHora,1,2) + Substr(cHora,4,2) >= Substr(AJK->AJK_HORAI,1,2) + Substr(AJK->AJK_HORAI,4,2) .AND.;
				         Substr(cHora,1,2) + Substr(cHora,4,2) < Substr(AJK->AJK_HORAF,1,2) + Substr(AJK->AJK_HORAF,4,2));
				        .Or. ;
				        (Substr(cHora,1,2)  + Substr(cHora,4,2)  < Substr(AJK->AJK_HORAI,1,2) + Substr(AJK->AJK_HORAI,4,2) .AND.;
				         Substr(cHoraF,1,2) + Substr(cHoraF,4,2) > Substr(AJK->AJK_HORAI,1,2) + Substr(AJK->AJK_HORAI,4,2));
				        )

						lRet := .F.
						Exit
					EndIF
					
					AJK->( dbSkip() )
				EndDo
			EndIf
			If !lRet
				Aviso(STR0022,STR0028,{"Ok"},2) //"Atencao!"###"Ja existem apontamentos gravados para este recurso neste periodo. Verifique a hora informada"
			EndIf
		EndIf
	EndIf        
	
	If lRet .And. !Empty(cHoraF)
		If SubStr(cHora,1,2)+Substr(cHora,4,2) > Substr(cHoraF,1,2)+Substr(cHoraF,4,2)
			Aviso(STR0022,STR0029,{"Ok"},2) //"Atencao"###"A hora final nao podera ser menor que a hora inicial. Verifique a hora digitada" //'Ok'
			lRet := .F.
		EndIf
	EndIf
	If lRet .And. !Empty(cHoraF)
		If l700
			M->AJK_HQUANT := PmsHrsItvl(M->AJK_DATA,cHora,M->AJK_DATA,M->AJK_HORAF,AE8->AE8_CALEND,M->AJK_PROJET,cRecurso,,.T.)
			If !PMSVldSld(,,cRecurso,cHoraI,dData,cHora,nQtdHrAnt) // Valida saldo de horas disponivel
				lRet := .F.	
			EndIf				
		Else

			If PMSVldSld(aClone(aColPMS700), aClone(aHeader),cRecurso,cHora,dData,cHoraF) // Valida saldo de horas disponivel

				AE8->(dbSetOrder(1))
				AE8->(dbSeek(xFilial()+cRecurso))
				aColPMS700[n][nPos_HQUANT] := PmsHrsItvl(dData,cHora,dData,cHoraF,AE8->AE8_CALEND,aColPMS700[n][nPos_PROJETO],cRecurso,,.T.)
				
				For nx := 1 to Len(aColPMS700)
			   	If aColPMS700[nx][nPos_PROJETO] == aColPMS700[n][nPos_PROJETO] .AND.;
			   		aColPMS700[nx][nPos_TAREFA] 	== aColPMS700[n][nPos_TAREFA]  .AND.;
			   		aColPMS700[nx][nPos_RECURS] 	== aColPMS700[n][nPos_RECURS]  .AND.;
			   		!aColPMS700[nx][Len(aColPMS700[nx])]
				   		
			        	Do Case
			         	Case (nx == n) .AND. (!aColPMS700[nx][nPos_SITUAC] == "3") //Caso seja o apontamento alterado e nao esteja rejeitado informa o saldo para o proximo apontamento.
			         		nSaldo:=	aColPMS700[nx][nPos_SLDHR] - aColPMS700[nx][nPos_HQUANT]
			         	
			            Case (nx == n) .AND. (aColPMS700[nx][nPos_SITUAC] == "3") //Caso seja o apontamento alterado e esteja rejeitado informa o saldo para o proximo apontamento e altera a situacao para pendente.
			         		nSaldo:=	aColPMS700[nx][nPos_SLDHR] - aColPMS700[nx][nPos_HQUANT]
			         		aColPMS700[nx][nPos_SITUAC] := "1"			            
			          
			            Case (nx > n) .AND. (aColPMS700[nx][nPos_SITUAC] == "2") .OR. (aColPMS700[nx][nPos_SITUAC] == "3") //Caso seja o apontamento aprovado ou rejeitado repassa o saldo.
			            	aColPMS700[nx][nPos_SLDHR] := nSaldo
		
			            Case (nx > n) .AND. (!aColPMS700[nx][nPos_SITUAC] == "2") .AND. (!aColPMS700[nx][nPos_SITUAC] == "3")  //Caso seja apontamento posterior ao alterado atualiza o saldo exceto aprovado ou rejeitado.
			            	aColPMS700[nx][nPos_SLDHR] := nSaldo
			            	nSaldo -= aColPMS700[nx][nPos_HQUANT]
			         EndCase
			         
			      EndIf
			   Next nx
			   P701SldHr()
		  	Else
				lRet := .F.		  		
		  	EndIf
		EndIf	
	EndIf
EndIf

RestArea(aAreaAJK)
RestArea(aAreaAFU)
RestArea(aAreaAE8)
RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS700HRF³ Autor ³ Reynaldo Miyashita     ³ Data ³ 06-12-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da hora final informada no apontamento do recurso.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS700HRF(cHora)
Local aArea        := GetArea()
Local aAreaAE8     := AE8->(GetArea())
Local aAreaAFU     := AFU->(GetArea())
Local aAreaAJK     := AJK->(GetArea())
Local cHoraI       := ""
Local cHoraF       := ""
Local cRecurso     := ""
Local nInterv      := 60 / GetMV("MV_PRECISA")
Local x            := 0
Local nX           := 0
Local lRet         := .T.
Local dData
Local nPos_DATA    := 0
Local nPos_HORAI   := 0
Local nPos_HORAF   := 0
Local nPos_PROJETO := 0
Local nPos_TAREFA  := 0
Local nPos_RECURS  := 0
Local nPos_HQUANT  := 0
Local nPos_SLDHR   := 0
Local nPos_SITUAC  := 0
Local nTam         := TamSx3("AJK_ITEM")[1]
Local nSaldo       := 0 
Local nQtdHrAnt    := 0 
Local lAutomato    := Iif (IsBlind(),.T.,.F.)
Local aColPMS700   := {}

Default cHora      := M->AJK_HORAF

aColPMS700 := PMS700aCol()

If l700
	cRecurso := M->AJK_RECURS
	dData    := M->AJK_DATA
	cHoraI   := M->AJK_HORAI
	cHoraF   := M->AJK_HORAF
	
	If l700Altera
		nQtdHrAnt := AJK->AJK_HQUANT
	EndIf
Else
	nPos_RECURS := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_RECURS"})
	nPos_DATA   := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_DATA"})
	nPos_HORAI  := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_HORAI"})
	nPos_HORAF  := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_HORAF"})
	nPos_PROJETO := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_PROJET"})
	nPos_TAREFA  := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_TAREFA"})
	nPos_HQUANT	 := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_HQUANT"})
	nPos_SLDHR	 := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_SLDHR"})
	nPos_SITUAC  := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_SITUAC"})
		
	cRecurso 	:= aColPMS700[n,nPos_RECURS]
	dData	   	:= aColPMS700[n,nPos_DATA]
	cHoraI   	:= aColPMS700[n,nPos_HORAI]
	cHoraF   	:= aColPMS700[n,nPos_HORAF]
EndIf

For x := 1 to GetMv("MV_PRECISA")
	Do  Case 
		Case x == 1
			 If Val(Substr(cHora,4,2)) < nInterv
				 If Val(Substr(cHora,4,2)) < nInterv/2 
				    cHora := Substr(cHora,1,3)+"00"
				    exit
				 Else
				    cHora := Substr(cHora,1,3)+Alltrim(Str(nInterv))
				    exit
				 EndIf
		     EndIf

		Case x > 1 .AND. x < GetMv("MV_PRECISA")
			 If Val(Substr(cHora,4,2)) > (nInterv*(x-1)) .AND. Val(Substr(cHora,4,2)) < (nInterv*x)
			    If Val(Substr(cHora,4,2)) < ((nInterv*x)-(nInterv/2))
			       cHora := Substr(cHora,1,3)+Alltrim(Str(nInterv*(x-1)))
			       exit
				Else
			       cHora := Substr(cHora,1,3)+Alltrim(Str(nInterv*x))
			       exit
			 	EndIf
			 EndIf

		Case x == GetMv("MV_PRECISA")
			 If Val(Substr(cHora,4,2)) > (nInterv*(x-1)) .AND. Val(Substr(cHora,4,2)) < (nInterv*x)
			 	If Val(Substr(cHora,4,2)) < ((nInterv*x)-(nInterv/2)) .AND. Val(Substr(cHora,4,2)) > nInterv*(x-1)
			       cHora := Substr(cHora,1,3)+Alltrim(Str(nInterv*(x-1)))
			       exit
			    Else
			       cHora := Soma1(Substr(cHora,1,2))+":00"
			       exit
			    EndIf
			 EndIf
	End Case
Next X

//
// Conforme ISO 8601, o formato de hora de um dia deve ser efetuado da seguinte forma:
//
// Primeira hora do dia é 00:00 
// Ultima hora do dia é 23:59
//
// Sempre que se estiver se referindo a 1 dia.
//
//If cHora == "24:00"
  //	cHora := "23:59"
//EndIf

M->AJK_HORAF := cHora

If !Empty(cRecurso) .And. !Empty(dData)

	dbSelectArea("AE8")
	dbSetOrder(1)
	MsSeek(xFilial('AE8')+cRecurso)
	
	If AE8->AE8_UMAX <= 100 
	
		If !l700
			For nX := 1 to Len(aColPMS700)
				If !(nX == n ) .AND. !aColPMS700[nX][Len(aHeader)+1] ;
				.AND. cRecurso == aColPMS700[nX][nPos_RECURS] .AND. dData == aColPMS700[nX][nPos_DATA]
					If (;
				        (Substr(cHora,1,2) + Substr(cHora,4,2) > Substr(aColPMS700[nX][nPos_HORAI],1,2) + Substr(aColPMS700[nX][nPos_HORAI],4,2)   .And.;
				         Substr(cHora,1,2) + Substr(cHora,4,2) < Substr(aColPMS700[nX][nPos_HORAF],1,2) + Substr(aColPMS700[nX][nPos_HORAF],4,2));
				         .Or.;
				        (Substr(cHora,1,2)  + Substr(cHora,4,2)  >= Substr(aColPMS700[nX][nPos_HORAF],1,2) + Substr(aColPMS700[nX][nPos_HORAF],4,2) .And.;
				         Substr(cHoraI,1,2) + Substr(cHoraI,4,2) < Substr(aColPMS700[nX][nPos_HORAF],1,2) + Substr(aColPMS700[nX][nPos_HORAF],4,2));
				        )
					   
						Aviso(STR0022,STR0028,{"Ok"},2) //"Atencao!"###"Ja existem apontamentos gravados para este recurso neste periodo. Verifique a hora informada"
						lRet := .F.
						Exit
					EndIf
				EndIf
			Next nX
			
		EndIf
	    
		If lRet
			dbSelectArea("AFU")
			dbSetOrder(3)
			dbSeek(xFilial("AFU")+"1"+cRecurso+DTOS(dData))
			While !Eof() .And. lRet .And. xFilial("AFU")+"1"+cRecurso+DTOS(dData)==;
								AFU->AFU_FILIAL+AFU->AFU_CTRRVS+AFU->AFU_RECURS+DTOS(AFU->AFU_DATA)
				
				//Caso seja executado sem interface, recebo o Recno do registro posicionado
				nRecAlt := Iif(!lAutomato,nRecAlt,AJK->(RecNo()))
				
				If nRecAlt != RecNo() .And. ;
				             (;
				             (Substr(cHora,1,2) + Substr(cHora,4,2) > Substr(AFU->AFU_HORAI,1,2) + Substr(AFU->AFU_HORAI,4,2)   .And.;
				              Substr(cHora,1,2) + Substr(cHora,4,2) < Substr(AFU->AFU_HORAF,1,2) + Substr(AFU->AFU_HORAF,4,2));
				              .Or.;
				             (Substr(cHora,1,2)  + Substr(cHora,4,2)  >= Substr(AFU->AFU_HORAF,1,2) + Substr(AFU->AFU_HORAF,4,2) .And.;
				              Substr(cHoraI,1,2) + Substr(cHoraI,4,2) < Substr(AFU->AFU_HORAF,1,2) + Substr(AFU->AFU_HORAF,4,2));
				             )
					lRet := .F.
					Exit
				EndIf
				dbskip()
			EndDo
		EndIf
		If lRet
			dbSelectArea("AJK")
			dbSetOrder(2)
			dbSeek(xFilial("AJK")+"1"+cRecurso+DTOS(dData))
			While !Eof() .And. lRet .And. xFilial("AJK")+"1"+cRecurso+DTOS(dData)==;
								AJK->AJK_FILIAL+AJK->AJK_CTRRVS+AJK->AJK_RECURS+DTOS(AJK->AJK_DATA)
                 //StrZero(oGet:nAt,nTam)<>AJK->AJK_ITEM .OR.
				If (!l700 .AND. PMA700AJK(aHeader,aColPMS700)) .or. AJK->AJK_SITUAC == "3"
					AJK->( dbSkip() )
					Loop
				EndIf
				
				//Caso seja executado sem interface, recebo o Recno do registro posicionado
				nRecAlt := Iif(!lAutomato,nRecAlt,AJK->(RecNo()))
				
				If nRecAlt != RecNo() .And. ;
				             (;
				             (Substr(cHora,1,2) + Substr(cHora,4,2) > Substr(AJK->AJK_HORAI,1,2) + Substr(AJK->AJK_HORAI,4,2)   .And.;
				              Substr(cHora,1,2) + Substr(cHora,4,2) < Substr(AJK->AJK_HORAF,1,2) + Substr(AJK->AJK_HORAF,4,2));
				              .Or.;
				             (Substr(cHora,1,2)  + Substr(cHora,4,2)  >= Substr(AJK->AJK_HORAF,1,2) + Substr(AJK->AJK_HORAF,4,2) .And.;
				              Substr(cHoraI,1,2) + Substr(cHoraI,4,2) < Substr(AJK->AJK_HORAF,1,2) + Substr(AJK->AJK_HORAF,4,2));
				             )
					lRet := .F.
					Exit            
					
				else
				
					IF (Substr(cHora,1,2)  + Substr(cHora,4,2)  <= Substr(cHoraI,1,2) + Substr(cHoraI,4,2)) .or.;
						(Substr(cHora,1,2)  + Substr(cHora,4,2)  == Substr(cHoraI,1,2) + Substr(cHoraI,4,2))
						lRet := .F.
						Exit
					EndIf
					
				EndIf          

				dbskip()
			EndDo
		EndIf
		If !lRet
			Aviso(STR0022,STR0028,{"Ok"},2) //"Atencao!"###"Ja existem apontamentos gravados para este recurso neste periodo. Verifique a hora informada"
		EndIf
	EndIf
	   
	If lRet .And. !Empty(cHoraI)
		If SubStr(cHora,1,2)+Substr(cHora,4,2) < Substr(cHoraI,1,2)+Substr(cHoraI,4,2)
			Aviso(STR0022,STR0029,{"Ok"},2) //"Atencao"###"A hora final nao podera ser menor que a hora inicial. Verifique a hora digitada" //'Ok'
			lRet := .F.
		EndIf    
		If l700			    
			M->AJK_HQUANT := PmsHrsItvl(M->AJK_DATA,M->AJK_HORAI,M->AJK_DATA,cHora,AE8->AE8_CALEND,M->AJK_PROJET,cRecurso,,.T.)
			If !PMSVldSld(,,cRecurso,cHoraI,dData,cHora,nQtdHrAnt) // Valida saldo de horas disponivel
				lRet := .F.	
			EndIf	
		Else

			If PMSVldSld(aClone(aColPMS700), aClone(aHeader),cRecurso,cHoraI,dData,cHora) // Valida saldo de horas disponivel

				AE8->(dbSetOrder(1))
				AE8->(dbSeek(xFilial()+cRecurso))
				aColPMS700[n][nPos_HQUANT] := PmsHrsItvl(dData,cHoraI,dData,cHora,AE8->AE8_CALEND,aColPMS700[n][nPos_PROJETO],cRecurso,,.T.)
				
				For nx := 1 to Len(aColPMS700)
			   	If aColPMS700[nx][nPos_PROJETO] == aColPMS700[n][nPos_PROJETO] .AND.;
			   		aColPMS700[nx][nPos_TAREFA] 	== aColPMS700[n][nPos_TAREFA]  .AND.;
			   		aColPMS700[nx][nPos_RECURS] 	== aColPMS700[n][nPos_RECURS]  .AND.;
			   		!aColPMS700[nx][Len(aColPMS700[nx])]
				   		
			        	Do Case
			         	Case (nx == n) .AND. (!aColPMS700[nx][nPos_SITUAC] == "3") //Caso seja o apontamento alterado e nao esteja rejeitado informa o saldo para o proximo apontamento. 
			         		nSaldo:=	aColPMS700[nx][nPos_SLDHR] - aColPMS700[nx][nPos_HQUANT]
									
			            Case (nx == n) .AND. (aColPMS700[nx][nPos_SITUAC] == "3") //Caso o seja o apontamento alterado e esteja rejeitado informa o saldo para o proximo apontamento e altera situacao para pendente. 
								nSaldo:=	aColPMS700[nx][nPos_SLDHR] - aColPMS700[nx][nPos_HQUANT]
			         		aColPMS700[nx][nPos_SITUAC] := "1"
			            
			            Case (nx >= n) .AND. (aColPMS700[nx][nPos_SITUAC] == "2") .OR. (aColPMS700[nx][nPos_SITUAC] == "3") //Caso seja o apontamento aprovado ou rejeitado repassa o saldo.
			            	aColPMS700[nx][nPos_SLDHR] := nSaldo
		
			            Case nx > n .AND. (!aColPMS700[nx][nPos_SITUAC] == "2") .AND. (!aColPMS700[nx][nPos_SITUAC] == "3")  //Caso seja apontamento posterior ao alterado atualiza o saldo exceto aprovado ou rejeitado.
			            	aColPMS700[nx][nPos_SLDHR] := nSaldo
			            	nSaldo -= aColPMS700[nx][nPos_HQUANT]
			         EndCase
			         
			      EndIf
			      P701SldHr()
				Next nx

		  	Else
				lRet := .F.		  		
		  	EndIf
		EndIf	
	EndIf
EndIf

RestArea(aAreaAJK)
RestArea(aAreaAFU)
RestArea(aAreaAE8)
RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS700HQT³ Autor ³ Reynaldo Miyashita     ³ Data ³ 06-12-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao quantidade de horas informada no apontamento.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS700HQT(nQuant)
Local lRet		:= .T.
Local cHoraI
Local cHoraF
Local lAutomato  := Iif (IsBlind(),.T.,.F.)
Local aColPMS700 := {}

aColPMS700 := PMS700aCol()

If l700
	cHoraI	:= M->AJK_HORAI
	cHoraF	:= M->AJK_HORAF
Else
	cHoraI	:= aColPMS700[n,aScan(aHeader,{|x| AllTrim(x[2])=="AJK_HORAI"})]
	cHoraF	:= aColPMS700[n,aScan(aHeader,{|x| AllTrim(x[2])=="AJK_HORAF"})]
EndIf

If nQuant > (Val(SubStr(cHoraF,1,2))-Val(SubStr(cHoraI,1,2))+(Val(SubStr(cHoraF,4,2))/60)-(Val(SubStr(cHoraI,4,2))/60)) .Or. nQuant > 24
	lRet := .F.
EndIf

Return lRet
           
           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  PMA700AJK  ºAutor  ³Clovis Magenta      º Data ³  03/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao verifica se o registro da AJK esta deletado no acolsº±±
±±º          ³ p nao o considerar no momento de uma nova inclusao de linhaº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS700HRF, PMS700HRI                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMA700AJK(aHeadAJK, aColAJK)
Local lRet := .F.          
Local nPos_RECURS := 0
Local nPos_DATA   := 0
Local nPos_HORAI  := 0
Local nPos_HORAF  := 0
Local nPos		  := 0

Default aHeadAJK:= {}
Default aColAJK := {}

nPos_RECURS := aScan(aHeadAJK,{|x|Alltrim(x[2])=="AJK_RECURS"})
nPos_DATA   := aScan(aHeadAJK,{|x|Alltrim(x[2])=="AJK_DATA"})
nPos_HORAI  := aScan(aHeadAJK,{|x|Alltrim(x[2])=="AJK_HORAI"})
nPos_HORAF  := aScan(aHeadAJK,{|x|Alltrim(x[2])=="AJK_HORAF"})   

// VERIFICA SE EXISTE UM REGISTRO IDENTICO NO ACOLS
nPos := aScan(aColAJK,{|x|Alltrim(x[nPos_RECURS])==Alltrim(AJK->AJK_RECURS) .AND. x[nPos_DATA]==AJK->AJK_DATA;
 				.AND. x[nPos_HORAI]==AJK->AJK_HORAI .AND. x[nPos_HORAF]==AJK->AJK_HORAF })
                                                   
// VERIFICA SE O REGISTRO ESTA COM STATUS DELETADO                      
If (nPos > 0) .and. (aColAJK[nPos][Len(aColAJK[nPos])])
	lRet := .T.
EndIf

Return lRet             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³PMSVldSld³ Autor ³ Marcos Pires     		  ³ Data ³ 30-07-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao do saldo de horas no apontamento.       				 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMS700HRF                                            			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSVldSld(aCols2, aHeader2,cRecurso,cHoraI,dData,cHoraF, nQtdHrAnt)

Local nx           := 0
Local nApontTot    := 0
Local nSaldoTot    := 0
Local nSaldo       := 0
Local lRet         := .T.
Local nPos_PROJETO := 0
Local nPos_TAREFA  := 0
Local nPos_RECURS  := 0
Local nPos_HQUANT  := 0
Local nPos_SLDHR   := 0
Local nPos_SITUAC  := 0
Local lAutomato  := Iif (IsBlind(),.T.,.F.)

If !l700

	nPos_PROJETO := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_PROJET"})
	nPos_TAREFA  := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_TAREFA"})
	nPos_RECURS  := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_RECURS"})
	nPos_HQUANT  := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_HQUANT"})
	nPos_SLDHR   := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_SLDHR"})
	nPos_SITUAC  := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_SITUAC"})
	
	AE8->(dbSetOrder(1))
	AE8->(dbSeek(xFilial()+cRecurso))      
	      
	aCols2[n][nPos_HQUANT] := PmsHrsItvl(dData,cHoraI,dData,cHoraF,AE8->AE8_CALEND,aCols2[n][nPos_PROJETO],cRecurso,,.T.)
					      
	For nx := 1 to Len(aCols2)
	   IF aCols2[nx][nPos_PROJETO] == aCols2[n][nPos_PROJETO] .AND.;
	      aCols2[nx][nPos_TAREFA]  == aCols2[n][nPos_TAREFA]  .AND.;
	      aCols2[nx][nPos_RECURS]  == aCols2[n][nPos_RECURS]  .AND.;
	      !aCols2[nx][Len(aCols2[nx])]
	   		
	      Do Case
	         Case nx == n //Caso seja o apontamento alterado informa o saldo para o proximo apontamento. 
	            nSaldoTot := aCols2[nx][nPos_SLDHR]
	            nApontTot := aCols2[nx][nPos_HQUANT]
	      EndCase    
	        
		EndIf
	Next nx 
Else

	nApontTot := M->AJK_HQUANT // Horas apontadas
	nSaldoTot := nTotal        //Saldo de horas
		
	If l700Altera
   	nSaldoTot += nQtdHrAnt //Soma saldo de horas com quantidade de horas original
		If nApontTot <= nSaldoTot //Avalia se as horas apontadas possui quantidade menor ou igual ao saldo total
			M->AJK_SLDHR := nSaldoTot - nApontTot //Atualiza o campo Saldo Horas
      EndIf
   EndIf
   
	If l700Inclui
		If nApontTot <= nTotal //Avalia se o apontamento de horas possui quantidade menor ou igual ao saldo.
			M->AJK_SLDHR := nTotal - nApontTot //Atualiza o campo Saldo Horas
      EndIf
	EndIf   
EndIf
	If nApontTot > nSaldoTot
		Aviso(STR0022,STR0031,{"Ok"},2) //"Atencao"###"Saldo de horas insuficiente para a realizacao do apontamento." //'Ok'
		lRet := .F.
	EndIf	
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} PMS700aCol()
	Função que retorna o array do aCols do objeto oGet quando for uma 
	execução por tela ou o aCols puro quando for uma execução por
	rotina automática
	
	@author	Squad CRM/Faturamento
	@version	P12
	@since	01/02/2019
	@return	aColPMS700, Array, Referencia para o array do aCols
*/
//-------------------------------------------------------------------
Function PMS700aCol()

	Local lExistoGet  := Type("oGet:aCols") <> "U"
	Local aColPMS700  := {}
	
	If !lExistoGet		
		If Type("aCols") <> "U"
			aColPMS700 := aCols
		EndIf
	Else
		aColPMS700 := oGet:aCols
	Endif

Return aColPMS700
