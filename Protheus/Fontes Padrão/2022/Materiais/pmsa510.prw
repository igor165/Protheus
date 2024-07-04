#INCLUDE "PMSA510.CH"
#INCLUDE "PROTHEUS.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA510  ³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de apontamentos diretos no projeto                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSA510(aRotAuto,nOpcAuto,aGetCpos)
PRIVATE cCadastro	:= STR0001 //"Apontamento Direto"
PRIVATE aRotina := MenuDef()

If AMIIn(44) .And. !PMSBLKINT()
	If PmsChkAJC(.T.)
		If nOpcAuto<>Nil
			dbSelectArea("AJC")
			nPos :=  nOpcAuto
			If ( nPos # 0 )
				bBlock := &( "{ |x,y,z,k,w,a| " + aRotina[ nPos,2 ] + "(x,y,z,k,w,a) }" )
				Eval( bBlock,Alias(),AJC->(Recno()),nPos,,,aGetCpos)
			EndIf
		Else
			// Instanciamento da Classe de Browse
			oBrowse := FWMBrowse():New()
			// Definição da tabela do Browse
			oBrowse:SetAlias('AJC')
			
			// Definição de filtro
			oBrowse:SetFilterDefault( 'AJC_FILIAL == "'+xFilial("AJC")+'" .AND. AJC_CTRRVS == "1"' )
			
			// Titulo da Browse
			oBrowse:SetDescription(cCadastro)
			// Opcionalmente pode ser desligado a exibição dos detalhes
			oBrowse:DisableDetails()
			// Ativação da Classe
			oBrowse:Activate()
		EndIf
	EndIf
EndIf
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms510Psq³ Autor ³ Edson Maricate         ³ Data ³ 24-10-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta uma tela de pesquisa no Browse .                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms510Psq(cAlias,nRecNo,nOpcx)
Local aArea     := GetArea()
Local aPesq     := {}
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

		// retira o campo AJC_CTRRVS dos índices do AJC
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

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms510Dlg³ Autor ³ Edson Maricate         ³ Data ³ 24-10-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de manipuacao dos apontamentos de recursos.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA510                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms510Dlg(cAlias,nRecNo,nOpcx,xRes1,xRes2,aGetCpos)
Local oDlg
Local nRecAJC
Local aCampos
Local lOk			:= .F.
Local lContinua		:= .T.
Local l510Inclui	:= .F.
Local l510Visual	:= .F.
Local l510Altera	:= .F.
Local l510Exclui	:= .F.
Local nX			:= 0

PRIVATE nRecAlt		:= 0
PRIVATE l510		:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case aRotina[nOpcx][4] == 2
		l510Visual := .T.
	Case aRotina[nOpcx][4] == 3
		l510Inclui	:= .T.
	Case aRotina[nOpcx][4] == 4
		l510Altera	:= .T.
		nRecAlt		:= AJC->(RecNo())
	Case aRotina[nOpcx][4] == 5
		l510Exclui	:= .T.
		l510Visual	:= .T.
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as variaveis de memoria.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("AJC",l510Inclui)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento do array aGetCpos com os campos Inicializados do AJC    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aGetCpos <> Nil
	aCampos	:= {}
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AJC")
	While !Eof() .and. SX3->X3_ARQUIVO == "AJC"
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


If (l510Altera .Or. l510Exclui )
	AF8->(dbSetOrder(1))
	AF8->(dbSeek(xFilial()+AJC->AJC_PROJET))
	If AF8->AF8_ULMES >= AJC->AJC_DATA
		Aviso("Operacao Invalida","Esta operacao nao podera ser efetuada pois este projeto ja esta fechado com data "+DTOC(AF8->AF8_ULMES)+". Verifique o apontamento selecionado.",{"Fechar"},2) 
		Return
	EndIf
EndIf


If !l510Inclui
	If !SoftLock("AJC")
		lContinua := .F.
	Else
		nRecAJC := AJC->(RecNo())
	Endif
EndIf

If lContinua
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO TranslateBottom(.F.,28),80 OF oMainWnd
	oEnch := MsMGet():New("AJC",AJC->(RecNo()),nOpcx,,,,,{,,(oDlg:nClientHeight - 4)/2,},aCampos,3,,,,oDlg)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||Iif(PMS510vld(oEnch,l510Excluir,nOpcx),(oDlg:End(),lOk:=.T.),NIL)},{||oDlg:End()}) 
	
EndIf

If lOk .And. (l510Inclui .Or. l510Altera .Or. l510Excluir)
	Begin Transaction
		Pms510Grava(nRecAJC,l510Exclui)
	End Transaction
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms510Grava³ Autor ³ Edson Maricate       ³ Data ³ 24-10-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a gravacao do apontamento do recurso.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA510                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms510Grava(nRecAJC,lDeleta,lAvalAJC1,lAvalAJC2)

Local lAltera	:= (nRecAJC!=Nil)
Local bCampo 	:= {|n| FieldName(n) }
Local nX		:= 0

DEFAULT lAvalAJC1	:= .T.
DEFAULT lAvalAJC2	:= .T.

If !lDeleta
	If lAltera
		dbSelectArea("AJC")
		dbGoto(nRecAJC)
		RecLock("AJC",.F.)
	Else
		dbSelectArea("AJC")
		RecLock("AJC",.T.)
	EndIf
	For nx := 1 TO FCount()
		FieldPut(nx,M->&(EVAL(bCampo,nx)))
	Next nx
	AJC->AJC_FILIAL	:= xFilial("AJC")
	AJC->AJC_CTRRVS	:= "1"
	MSMM(,TamSx3("AJC_OBS")[1],,M->AJC_OBS,1,,,"AJC","AJC_CODMEM")

	If ExistBlock("PMSGrvAJC")
		ExecBlock("PMSGrvAJC", .F., .F., {	AJC->AJC_FILIAL,;
											AJC->AJC_CTRRVS,;
											AJC->AJC_PROJET,;
											AJC->AJC_REVISA,;
											AJC->AJC_TAREFA,;
											AJC->AJC_RECURS,;
											AJC->AJC_DATA	})
	EndIf
	
	MsUnlock()	
	/////////////////////////////////////////////////////////////////
	//
	// Integração com RM Corpore SOLUM, gera a apropriacao para o projeto.
	//
	/////////////////////////////////////////////////////////////////
	SLMPMSCOST(iIf(lAltera,1,0), "AJC", AJC->AJC_DATA, AJC->AJC_PROJET, AJC->AJC_TAREFA, AJC->AJC_COD, AJC->AJC_QUANT, AJC->AJC_CUSTO1)
	/////////////////////////////////////////////////////////////////
Else
	AJC->(dbGoto(nRecAJC))
	/////////////////////////////////////////////////////////////////
	//
	// Integração com RM Corpore SOLUM, gera a apropriacao para o projeto.
	//
	/////////////////////////////////////////////////////////////////
	SLMPMSCOST(2, "AJC")
	/////////////////////////////////////////////////////////////////
	RecLock("AJC",.F.,.T.)
	dbDelete()
	MsUnlocK()
EndIf


Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS510Data³ Autor ³ Edson Maricate        ³ Data ³ 29/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a data em relacao a data do Ultimo fechamento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMS510                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms510Data()
LOCAL lRet:=.T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificar data do ultimo fechamento do projeto.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AF8->(dbSetOrder(1))
AF8->(dbSeek(xFilial()+M->AJC_PROJET))
If AF8->AF8_ULMES >= M->AJC_DATA
	Aviso("Operacao Invalida","Esta operacao nao podera ser efetuada pois este projeto ja esta fechado com data "+DTOC(AF8->AF8_ULMES)+". Verifique o apontamento selecionado.",{"Fechar"},2) 
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms510ValOpe³ Autor ³ Fabio Rogerio Pereira  ³ Data ³ 07-01-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a permissao do usuario.						           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                               	       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pms510ValOpe()
Local lRet:= .T.

AF9->(dbSetOrder(1))
AF9->(MsSeek(xFilial()+M->AJC_PROJET+M->AJC_REVISA+M->AJC_TAREFA))

	If !PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,3,"RECURS",AF9->AF9_REVISA)//Alterar
		Aviso(STR0008,STR0009,{STR0010},2) //"Operacao Invalida"###"Operacao nao disponivel para o usuario nesta tarefa!"###"Fechar"
		lRet:= .F.
	EndIf

Return(lRet)

/*/{Protheus.doc} ValTpApon

Valida os campos de codigo de produto, quantidade, Tipo de Despesa de acordo com o que foi preenchido no campo Tipo de Apontamento

@author Reynaldo Tetsu Miyashita

@since 22/10/2013

@version P11.5

@param nenhum 

@return logico, Se verdadeiro os campos foram preenchidos corretamente

/*/
Static Function ValTpApon()
Local lRet := .T.

	If M->AJC_TIPO == "1"
		lRet := ! Empty(M->AJC_COD) .And. ;
				SB1->(dbSeek(xFilial("SB1")+M->AJC_COD)) .And. ;
				M->AJC_QUANT > 0 .And. Empty(M->AJC_TIPOD)
		If ! lRet		
			Aviso(STR0008,STR0011,{STR0010},2)//"Operacao Invalida"###"Os campos Codigo Produto ou Quantidade devem ser preenchidos e o campo Tipo de Despesa deve estar vazio!"###"Fechar"
		EndIf
    ElseIf M->AJC_TIPO == "2"
		lRet := Empty(M->AJC_COD) .And. (M->AJC_QUANT == 0) .And. ;
				!Empty(M->AJC_TIPOD) .And. ;
				SX5->(dbSeek(xFilial("SX5")+"FD"+M->AJC_TIPOD))
		If ! lRet
		   Aviso(STR0008,STR0012,{STR0010},2)//"Operacao Invalida"###"Os campos Codigo Produto e Quantidade devem estar vazios e o campo Tipo de Despesa deve estar preenchido!"###"Fechar"
		EndIf   
    EndIf
    
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms510Ok³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se todos os parametros estao corretos.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms510Ok(aConfig)
Local lRet	:= .T.

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³01/12/06 ³±±
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
Local aRotina 	:= {	{ STR0002,"PMS510Psq"  , 0 , 1,,.F.},; //"Pesquisar"
						{ STR0003,"PMS510Dlg" , 0 , 2 },; //"Visualizar"
						{ STR0004,"PMS510Dlg" , 0 , 3 },; //"Incluir"
						{ STR0005,"PMS510Dlg",0 , 4  },; //"Alterar"
						{ STR0006,"PMS510Dlg",0 , 5 } } //"Excluir"
Local aBotAdic 	:= {} 

//PE para adição de botões no menu						
If ExistBlock("PMS510BOT") 
	aBotAdic := ExecBlock("PMS510BOT",.f.,.F.,aRotina)
    If ValType(aBotAdic) == "A"
        AEval(aBotAdic,{|x| AAdd(aRotina,x)})
    EndIf
Endif						
						
Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms510VLD³ Autor ³ Reynaldo Miyashita     ³ Data ³ 17-02-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a validacao da dialog.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMS510Vld(oEnch, l510Exclui, nOpcx)
Local lRet := .T.

	If ExistBlock("PM510VLD")
		lRet := ExecBlock("PM510VLD", .F., .F., {nOpcx})
	EndIf
	
	If !l510Excluir
		// valida so campos obrigatios
		lRet := Obrigatorio(oEnch:aGets,oEnch:aTela) 

		// caso exista integracao com CORPORE RM SOLUM, valida se o insumo esta associado a um projeto e o produto informados
		lRet := lRet .And. SlmValid(M->AJC_PROJET ,M->AJC_COD)
		
		// valida os campos de acordo com o campo Tipo de Apontamento foi preenchido
		lRet := lRet .And. ValTpApon()
		
		// faz a validacao dos usuarios	        
		lRet := lRet .And. Pms510ValOpe() 
           
  		// faz a validacao do ponto de entrada 
		If lRet .And. ExistBlock("PM510Grv")
			lRet := ExecBlock("PM510Grv", .F., .F.)
		EndIf
		
	EndIf
	   
Return lRet
