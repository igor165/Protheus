#INCLUDE "TOTVS.CH"
#INCLUDE "QAXA040.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QAXA040  ³ Autor ³Eduardo de Souza       ³ Data ³ 02/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Ausencia Temporaria                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QAXA040()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA040 - Siga Quality (Generico)                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³   Data   ³  BOPS  ³Programador ³ Alteracao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 22/08/02 ³  ----  ³Eduardo S.  ³Acerto para apresentar somente os usua³±±
±±³          ³        ³            ³rios referente a filial selecionada.  ³±±
±±³ 08/01/03 ³  ----  ³Eduardo S.  ³Alterado para permitir pesquisar usua-³±±
±±³          ³        ³            ³rios de outras filiais.               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function MenuDef()

Local aRotina  := {{OemToAnsi(STR0002),"AxPesqui"  , 0, 1,,.F.},; // "Pesquisar"
					 {OemToAnsi(STR0003),"QX040Telas",	0, 2},; // "Visualizar"
					 {OemToAnsi(STR0004),"QX040Telas",	0, 3},; // "Incluir"
					 {OemToAnsi(STR0005),"QX040Telas",	0, 4},; // "Alterar"
					 {OemToAnsi(STR0006),"QX040Telas",	0, 5},; // "Excluir"
					 {OemToAnsi(STR0010),"QX040Legen",	0, 6,,.F.} } // "Legenda"

Return aRotina

Function QAXA040()

Local aCores := {}
Local cFiltro:= ""

Private cFilMat  := xFilial("QAA")
Private aRotina  := MenuDef()

DbSelectArea("QAE")
DbSetOrder(1)
cFiltro:= "QAE_MODULO == "+AllTrim(Str(nModulo))
Set Filter To &(cFiltro)
DbGotop()

aCores:= {	{'QAE->QAE_STATUS == "2"','ENABLE' },;
				{'QAE->QAE_STATUS == "1"','BR_AMARELO'} }

mBrowse(006,001,022,075,"QAE",,,,,, aCores)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX040Telas³ Autor ³ Eduardo de Souza      ³ Data ³ 02/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela Ausencia Temporaria                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX040Telas(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias do arquivo                                   ³±±
±±³          ³ ExpN1 - Numero do registro                                 ³±±
±±³          ³ ExpN2 - Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX040Telas(cAlias,nReg,nOpc)

Local oDlg
Local nI      := 0
Local nOpcao  := 0
Local nOrdQAE := QAE->(IndexOrd())
Local aColsAux:= {}
Local lDeleta := .F.
Local aUsrMat := QA_USUARIO()
Local lAcsUsr := .F.

Private lAcsTod  := .F.
Private cFilDep  := xFilial("QAD")
Private bCampo   := {|nCPO| Field( nCPO ) }
Private aHeader  := {}
Private aCols	  := {}
Private nUsado	  := 0
Private nPosFil  := 0
Private aNiv     := {}
Private lAlter   := .F.
Private cMatFil  := aUsrMat[2]
Private cMatCod  := aUsrMat[3]
Private cMatDep  := aUsrMat[4]
Private cMatMail := aUsrMat[5]
Private aTELA[0][0]
Private aGETS[0]
Private nQAConPad:= 6
Private nSaveSX8
Private nPosPen
Private nPosFUs
Private nPosUsr
Private nPosNom
Private nPosDep

If nModulo == 24
	Private cTamAno  := Space(TamSX3("QD0_ANO")[1])
	Private cTamNum  := Space(TamSX3("QD0_NUMERO")[1])
	Private cTamDocto:= Space(TamSX3("QDH_DOCTO")[1])
	Private cTamRv   := Space(TamSX3("QDH_RV")[1])
EndIf

DbSelectArea("QAE")
DbSetOrder(1)

If nOpc == 3 
   nSaveSX8	:= GetSX8Len()
   For nI := 1 To FCount()
       cCampo := Eval( bCampo, nI )
       lInit  := .F.
       If ExistIni( cCampo )
          lInit := .T.
          M->&( cCampo ) := InitPad( GetSx3Cache(cCampo, 'X3_RELACAO') )
          If ValType( M->&( cCampo ) ) = "C"
             M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo, 'X3_TAMANHO') )
          EndIf
          If M->&( cCampo ) == Nil
             lInit := .F.
          EndIf
       EndIf
       If !lInit
          M->&( cCampo ) := FieldGet( nI )
          If ValType( M->&( cCampo ) ) = "C"
             M->&( cCampo ) := Space( Len( M->&( cCampo ) ) )
          ElseIf ValType( M->&( cCampo ) ) = "N"
             M->&( cCampo ) := 0
          ElseIf ValType( M->&( cCampo ) ) = "D"
             M->&( cCampo ) := CtoD( "  /  /  " )
          ElseIf ValType( M->&( cCampo ) ) = "L"
             M->&( cCampo ) := .f.
          EndIf
       EndIf
   Next nI
	M->QAE_FILIAL:= xFilial("QAE") 
Else
   For nI := 1 To FCount()
       M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
   Next nI
   If FWModeAccess("QAD")=="E"
   	cFilDep:= QAE->QAE_FILMAT
   EndIf
EndIf

If nOpc <> 2
	If nOpc == 4 .Or. nOpc == 5
		If M->QAE_STATUS == "2"
			Help(" ",1,"QX040FIM") // "Ausencia Temporaria Finalizada, nao e permitido sua manutencao."
			Return .F.
		EndIf
		If nOpc == 4 .And. M->QAE_FLAG == "S"
			lAlter:= .T.
		EndIf
		If nOpc == 5 .And. M->QAE_FLAG == "S"
			Help(" ",1,"QX040NEXC") // "Ausencia Temporaria esta sendo utilizada, nao e permitida sua Exclusao.",
			Return .F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acessa somente os Lancamentos do proprio Usuario  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If VerSenha(106) // ACESSO USUARIO
		lAcsUsr:= .T.
		If (nOpc == 4 .Or. nOpc == 5) .And. M->QAE_FILMAT+M->QAE_MAT <> cMatFil+cMatCod
			lAcsUsr:= .F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acessa Todos Lancamentos                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If VerSenha(105) // ACESSO TODOS USUARIOS
		lAcsTod:= .T.
	EndIf

	If !lAcsUsr .And. !lAcsTod
	  	Help(" ",1,"QX040USRNP") // "Usuario nao tem permissao para fazer manutencao no Cadastro de Ausencia Temporaria"
		Return .F.		
	EndIf
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM 000,000 TO 385,625 OF oMainWnd PIXEL //"Ausencia Temporaria"

oGetAus:= MsMGet():New("QAE",nReg,nOpc,,,,,{033,002,086,312})

If nOpc == 3 .And. !lAcsTod
	M->QAE_FILMAT:= cMatFil
	M->QAE_MAT   := cMatCod
	M->QAE_NOME  := QA_NUSR(cMatFil,cMatCod,.T.)
	M->QAE_DEPTO := cMatDep
	M->QAE_NDEPTO:= QA_NDEPT(cMatDep,.T.)
EndIf

If nOpc == 3 .Or. (nOpc == 4 .And. !lAlter)
	lDeleta:= .T.
Else
	lDeleta:= .F.
EndIf

If nOpc != 3
	aArea := GetArea()

	dbSelectArea("QAF")
	dbSetOrder(1)
	dbSeek(QAE->QAE_FILIAL+QAE->QAE_ANO+QAE->QAE_NUMERO)
	
	Private cSeek  := QAF->QAF_FILIAL+QAF->QAF_ANO+QAF->QAF_NUMERO
	Private cWhile := "QAF->QAF_FILIAL+QAF->QAF_ANO+QAF->QAF_NUMERO"
	
	RestArea(aArea)
EndIf


@ 086,002 SAY OemToAnsi(STR0007) SIZE 100,010 OF oDlg COLOR CLR_HRED,CLR_WHITE PIXEL // "Usuario Destino"

If nOpc !=3
	FillGetDados(nOpc,"QAF" ,1     ,cSeek ,{|| &cWhile},         ,         ,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
Else
	FillGetDados(nOpc,"QAF" ,1     ,      ,             ,         ,         ,          ,        ,      ,        ,  .T.  ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile   ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
EndIf

nPosPen:= Ascan(aHeader, { |x| Trim(x[2]) == "QAF_TPPEND" })
nPosFUs:= Ascan(aHeader, { |x| Trim(x[2]) == "QAF_FILMAT" })
nPosUsr:= Ascan(aHeader, { |x| Trim(x[2]) == "QAF_MAT" })
nPosNom:= Ascan(aHeader, { |x| Trim(x[2]) == "QAF_NOME" })
nPosDep:= Ascan(aHeader, { |x| Trim(x[2]) == "QAF_DEPTO" })

aColsAux:= Aclone(aCols)

nUsado := Len(aHeader)

oGet:= MSGetDados():New(094,002,190,312,If(lAlter,2,nOpc),"QX040LinOk",," ",lDeleta)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(nOpc == 2 .Or. nOpc == 5,(nOpcao:= 1,oDlg:End()),If(Obrigatorio(aGets,aTela) .And. QX040VldF(),;
														(QX040Final(),nOpcao:= 1,oDlg:End()),))},{|| oDlg:End()}) CENTERED
If nOpc <> 2 .And. nOpcao == 1
	If nOpc == 3 .Or. nOpc == 4
		QX040GrAus(nOpc,aColsAux)
	ElseIf nOpc == 5
		QX040Dele()
	EndIf                       
	
	IF MSGNOYES(OemToAnsi(STR0030))  //"Atualizar Lancamentos, esta Atualizacao pode ser um processo demorado. Confirma?"
		MsgRun(OemToAnsi(STR0031),OemToAnsi(STR0012),{|| QDX040Atu()})   //"Atualizando Lancamentos de Ausencia Temporaria..."
	Else
		MsgStop(OemToAnsi(STR0032))	  //"Esta Atualizacao NAO foi realizada. E acontecerá somente no proximo Log-in que qualquer usuario no Modulo SIGAQDO (CONTROLE DE DOCUMENTOS)"
	Endif

ElseIf nOpc == 3
	While (GetSX8Len() > nSaveSx8)
		Rollbacksx8()
	End
EndIf

QAE->(DbSetOrder(nOrdQAE))

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QX040LinOk ³ Autor ³ Eduardo de Souza     ³ Data ³ 03/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX040LinOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QAXA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX040LinOk


Local lRet   := .t.
Local nCont  := 0
Local nPos01 := Ascan(aHeader,{ |X| Upper(Alltrim(X[2])) = "QAF_TPPEND"})
Local nPos02 := Ascan(aHeader,{ |X| Upper(Alltrim(X[2])) = "QAF_MAT"})
Local nPosDel:= Len(aHeader) + 1

If aCols[n,nUsado+1] == .F.
	If nPos01 <> 0
		Aeval( aCols, { |X| If(X[nPosDel] == .F. .And. X[nPos01] == aCols[N,nPos01],nCont++,nCont)})
		If nCont > 1
			Help(" ",1,"QALCTOJAEX")
			lRet:= .F.
		EndIf
	EndIf
	If (Empty(aCols[n,nPos01]) .Or. Empty(aCols[n,nPos02])) .And. !aCols[n, nPosDel]
		Help(" ",1,"QDA050BRA") // "Campo Obrigatorio nao preenchido."
		lRet:= .F.
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX040GrAus³ Autor ³ Eduardo de Souza      ³ Data ³ 03/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Ausencia Temporaria                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX040GrAus(ExpN1,ExpA1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±³          ³ ExpA1 - Acols Auxiliar                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Quality Celerina                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QX040GrAus(nOpc,aColsAux)

Local lRecLock := .F.
Local nCnt     := 0
Local nCpo     := 0
Local nPos01   := Ascan(aHeader,{ |X| Upper(Alltrim(X[2])) = "QAF_TPPEND"})
Local nPos02   := Ascan(aHeader,{ |X| Upper(Alltrim(X[2])) = "QAF_FILMAT"})
Local nPos03   := Ascan(aHeader,{ |X| Upper(Alltrim(X[2])) = "QAF_MAT"})
Local nPos04   := Ascan(aHeader,{ |X| Upper(Alltrim(X[2])) = "QAF_DEPTO"})
Local nPosDel  := Len(aHeader) + 1

If nOpc == 3
	lRecLock:= .T.
	M->QAE_MODULO:= nModulo
	M->QAE_STATUS:= "1"
	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End
ElseIf nOpc == 4 .And. M->QAE_DTPREV <= M->QAE_DTINIC
	M->QAE_STATUS:= "2"
EndIf

Begin Transaction
DbSelectArea("QAE")
DbSetOrder(1)
RecLock("QAE",lRecLock)
For nCnt := 1 TO FCount()
	FieldPut(nCnt,M->&(Eval(bCampo,nCnt)))
Next nCnt	
QAE->(MsUnLock())
FKCOMMIT()

DbSelectArea("QAF")
DbSetOrder(1)
For nCnt:= 1 To Len(aCols)
	If !aCols[nCnt, nPosDel] .And. !Empty(aCols[nCnt,nPos01]) // Verifica se o item foi deletado
		If nOpc == 4 .And. nCnt <= Len(AcolsAux) .Or. (!(nOpc == 3) .And. ;
		   QAF->(DbSeek(M->QAE_FILIAL+M->QAE_ANO+M->QAE_NUMERO+Acols[nCnt,1]+Acols[nCnt,2]+Acols[nCnt,3]))) 

			If QAF->(DbSeek(M->QAE_FILIAL+M->QAE_ANO+M->QAE_NUMERO+AcolsAux[nCnt,1]+AcolsAux[nCnt,2]+AcolsAux[nCnt,3]))
				QAF->(Reclock("QAF",.F.))
				QAF->QAF_TPPEND := aCols[nCnt,nPos01]
				QAF->QAF_FILMAT := aCols[nCnt,nPos02]
				QAF->QAF_MAT    := aCols[nCnt,nPos03]
				QAF->QAF_DEPTO  := aCols[nCnt,nPos04]
				QAF->(MsUnLock())
				QAF->(FKCOMMIT())
			Endif
		Else
			QAF->(RecLock("QAF",.T.))
			QAF->QAF_FILIAL:= xFilial("QAF")
			QAF->QAF_ANO   := M->QAE_ANO
			QAF->QAF_NUMERO:= M->QAE_NUMERO
			QAF->QAF_TPPEND := aCols[nCnt,nPos01]
			QAF->QAF_FILMAT := aCols[nCnt,nPos02]
			QAF->QAF_MAT    := aCols[nCnt,nPos03]
			QAF->QAF_DEPTO  := aCols[nCnt,nPos04]
			QAF->(MsUnLock())
			QAF->(FKCOMMIT())
		EndIf
	Else
		If QAF->(DbSeek(M->QAE_FILIAL+M->QAE_ANO+M->QAE_NUMERO+Acols[nCnt,1]+Acols[nCnt,2]+Acols[nCnt,3]))
			QAF->(RecLock("QAF",.F.))
			QAF->(DbDelete())
			QAF->(MsUnlock())
			QAF->(FKCOMMIT())
			QAF->(DbSkip())
		EndIf
	EndIf
Next nCnt
End Transaction
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QX040Dele³ Autor ³ Eduardo de Souza      ³ Data ³ 03/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de exclusao de Ausencia Temporaria                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX040Dele()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Quality Celerina                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QX040Dele()


Begin Transaction
RecLock("QAE",.F.)
QAE->(DbDelete())
QAE->(MsUnlock())
FKCOMMIT()
QAE->(DbSkip())
If QAF->(DbSeek(M->QAE_FILIAL+M->QAE_ANO+M->QAE_NUMERO))
	While QAF->(!Eof()) .And. QAF->QAF_FILIAL+QAF->QAF_ANO+QAF->QAF_NUMERO == M->QAE_FILIAL+M->QAE_ANO+M->QAE_NUMERO
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aviso de Ausencia Temporaria.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QDS->(DbSetOrder(1))
		If QDS->(DbSeek(QAF->QAF_FILMAT+QAF->QAF_MAT+"P"+"TMP"))
			Reclock("QDS",.F.)
			QDS->(DbDelete())
			MsUnlock()
			FKCOMMIT()
		Endif

		RecLock("QAF",.F.)
		QAF->(DbDelete())
		QAF->(MsUnlock())
		FKCOMMIT()
		QAF->(DbSkip())
	EndDo
EndIf                   

End Transaction

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX040VldDt³ Autor ³ Eduardo de Souza      ³ Data ³ 03/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Data da Ausencia                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX040VldDt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Quality Celerina                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX040VldDt()

If M->QAE_DTPREV <= M->QAE_DTINIC
	Help(" ",1,"QX040DATA") // "Data Invalida ou Data Inicio menor ou igual que a Data Prevista."
	Return .F.
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX040VlDtF³ Autor ³ Eduardo de Souza      ³ Data ³ 09/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Data Fim da Ausencia                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX040VlDtF()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Quality Celerina                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX040VlDtF()

If M->QAE_DTFIM < M->QAE_DTINIC .Or. M->QAE_DTFIM >= M->QAE_DTPREV
	Help(" ",1,"QX040DTFIM") // "Data Fim deve ser maior que a Data Inicio e menor que a Data Prevista."
	Return .F.
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX040VlMot³ Autor ³ Eduardo de Souza      ³ Data ³ 09/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Motivo da Ausencia                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX040VlMot()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Quality Celerina                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX040VlMot()

Local aSX5QGx := {}
Local nPX5Filial	:= 1

If nModulo == 24
	aSX5QGx := FWGetSX5("QG",M->QAE_MOT)
	If !(Len(aSX5QGx)>0 .AND. aScan(aSX5QGx,{|x| x[nPX5Filial]==xFilial("SX5")})>0)
		Help(" ",1,"QX040NEMOT") // "Motivo da Ausencia Temporaria nao existe."
		Return .F.
	EndIf
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QX040Legen³ Autor ³Eduardo de Souza       ³ Data ³ 03/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QX040Legen()               										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Quality Celerina                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX040Legen()

Local aLegenda:= {}

Aadd( aLegenda, {'BR_AMARELO', OemtoAnsi(STR0008)} )	// "Ausencia Temporaria Em Andamento"
Aadd( aLegenda, {'ENABLE'    , OemtoAnsi(STR0009)} ) 	// "Ausencia Temporaria Finalizada"

BrwLegenda(OemToAnsi(STR0001),OemtoAnsi(STR0010),aLegenda)	// "Ausencia Temporaria" ### "Legenda"

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX040Selec³ Autor ³ Eduardo de Souza      ³ Data ³ 06/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona o Tipo de pendencia da Ausencia                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX040Selec()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX040Selec()

Local lRetorno := .T.

If Inclui .Or. Altera
	If nModulo == 24 // SIGAQDO
		lRetorno := QDX040TPen()
	Else
		Help(" ",1,"QX040NEXTP") // "Nao existe Tipo de pendencia para associar a Ausencia Temporaria."
	EndIf
EndIf

Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fSelecCli ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 15/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tratar o click da pergunte                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fSelecCli                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fSelecCli(oListBox,aNiv)

Local nI:= 0

aNiv[oListBox:nat,1]:= !aNiv[oListBox:nat,1]

If oListBox:nAt == 1	 // Todos
	For nI:= 2 To Len(aNiv)
		aNiv[nI,1] := aNiv[1,1]
	Next nI
Else
	If !aNiv[oListBox:nat,1]
		aNiv[1,1]:= .F.
	EndIf
EndIf

oListBox:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX040VldTP³ Autor ³ Eduardo de Souza      ³ Data ³ 06/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Tipo de Pendencia                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX040VldTP()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX040VldTP()

Local nI  := 0
Local lRet:= .F.

For nI:= 1 To Len(aNiv)
	If aNiv[nI,3] == M->QAF_TPPEND
		lRet:= .T.
		Exit
	EndIf
Next nI

If !lRet
	Help(" ",1,"QX040NEXTP") // "Nao existe Tipo de pendencia para associar a Ausencia Temporaria."
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX040VldUD³ Autor ³ Eduardo de Souza      ³ Data ³ 09/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Usuario Destino                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX040VldUD()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX040VldUD()

Local lRet   := .T.
Local nOrdQAE:= QAE->(IndexOrd())
Local nPosQAE:= QAE->(Recno())

QAE->(DbSetOrder(2))

WhemMat()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se Usuario existe.                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !QA_CHKMAT(aCols[n,2],M->QAF_MAT,.T.)
	lRet:= .F.
EndIf

If lRet

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se Usuario Destino eh diferente do Usuario Origem.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aCols[n,2]+M->QAF_MAT == M->QAE_FILMAT+M->QAE_MAT
		Help(" ",1,"QX040UNDES") // "Usuario Destino nao pode ser o mesmo que Usuario Origem."
		lRet:= .F.
	EndIf
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se ja existe Ausencia Temporaria no Periodo para o Usuario. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QAE->(DbSeek(aCols[n,2]+M->QAF_MAT+"1"))
			If M->QAE_DTINIC < QAE->QAE_DTPREV .And. M->QAE_DTPREV > QAE->QAE_DTINIC
				Help(" ",1,"QX040JEAP") // "Ja existe Ausencia Temporaria cadastrada no Periodo para este Usuario."	
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

QAE->(DbGoto(nPosQAE))
QAE->(DbSetOrder(nOrdQAE))
		
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QX040VldF³ Autor ³ Eduardo de Souza      ³ Data ³ 07/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Finalizacao do Cadastro da Ausencia Temporaria      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX040VldF()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Quality Celerina                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX040VldF()

Local lRet   := .T.
Local nOrdQAE:= QAE->(IndexOrd())
Local nPosQAE:= QAE->(Recno())
Local nCnt   := 0
Private aDoctos:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se ja existe Ausencia Temporaria no Periodo para o Usuario. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QAE->(DbSetOrder(2))
If QAE->(DbSeek(M->QAE_FILMAT+M->QAE_MAT+"1"))
	If QAE->QAE_FILIAL+QAE->QAE_ANO+QAE->QAE_NUMERO <> M->QAE_FILIAL+M->QAE_ANO+M->QAE_NUMERO
		If QAE->QAE_DTPREV > M->QAE_DTINIC
			Help(" ",1,"QX040JEAP") // "Ja existe Ausencia Temporaria cadastrada no Periodo para este Usuario."
			lRet:= .F.
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a Data Ate Ausencia e Maior que a Data De Ausencia.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If M->QAE_DTPREV <= M->QAE_DTINIC
		Help(" ",1,"QX040DATA") // "Data Invalida ou Data Inicio menor ou igual que a Data Prevista."
		lRet:= .F.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se Usuario Origem Existe ou possui status de Ativo.         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		If !QA_CHKMAT(M->QAE_FILMAT,M->QAE_MAT,.F.)
			Help(" ",1,"QX040USRNO") // "Usuario Origem nao existe no Cadastro de Usuarios."
			lRet:= .F.
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se Usuario Destino Existe ou possui status de Ativo.        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			For nCnt:= 1 To Len(aCols)
				If !aCols[nCnt,nUsado+1]
					If !QA_CHKMAT(aCols[nCnt,2],aCols[nCnt,3],.F.)
						Help(" ",1,"QX040USRND") // "Usuario Destino nao existe no Cadastro de Usuarios."
						lRet:= .F.
						Exit
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se ja existe Ausencia Temporaria no Periodo para o Usuario. ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If QAE->(DbSeek(aCols[nCnt,2]+aCols[nCnt,3]+"1"))
						If M->QAE_DTINIC < QAE->QAE_DTPREV .And. M->QAE_DTPREV > QAE->QAE_DTINIC
							Help(" ",1,"QX040JEAP") // "Ja existe Ausencia Temporaria cadastrada no Periodo para este Usuario."	
							lRet:= .F.
							Exit
						EndIf
					EndIf	
				EndIf
				If lRet .And. Empty(aCols[nCnt,1])		
					MsgStop(OemtoAnsi(STR0035),OemtoAnsi(STR0034))	//"O campo 'Tipo de Pendência' em branco !","Atencao !"
					lRet:= .F.
					Exit
				Endif
			Next nCnt
			IF lRet   				
				MsgRun(OemtoAnsi(STR0008),OemToAnsi(STR0001),{|| QDX040Lib(Aclone(aCols),M->QAE_FILMAT,M->QAE_DEPTO,M->QAE_MAT) })
				IF Len(aDoctos) > 0
					QDX40AuDlg(AClone(aDoctos))
					lRet:= .F.                
				ENDIF				
			Endif
		EndIf
	EndIf
EndIf

QAE->(DbSetOrder(nOrdQAE))
QAE->(DbGoto(nPosQAE))

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX040Final³ Autor ³ Eduardo de Souza      ³ Data ³ 10/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Finaliza Ausencia Temporaria.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX040Final()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX040Final()

Local nPosQAE   := QAE->(Recno())
Local nOrdQAE   := QAE->(IndexOrd())
Local nPosQAF   := QAF->(Recno())
Local nOrdQAF   := QAF->(IndexOrd())
Local nFilPos   := Ascan(aHeader,{ |X| Upper(Alltrim(X[2])) = "QAF_FILMAT"})
Local nMatPos   := Ascan(aHeader,{ |X| Upper(Alltrim(X[2])) = "QAF_MAT"})
Local nTPPendPos:= Ascan(aHeader,{ |X| Upper(Alltrim(X[2])) = "QAF_TPPEND"})
Local nCnt      := 0
Local nI        := 0
Local nPos      := 0
Local cFiltro   := "QAE->QAE_STATUS == '1'" 
Local nX        := 1
Local cMsg		:= ""
Local cSubject	:= ""
Local cHora		:= SubStr(Time(),1,5)
Local aMsg		:= {}
Local cTpMail	


Private bCampo  := {|nCPO| Field( nCPO ) }
Private aUsrMail:= {}

DbSelectArea("QAE")
Set Filter To &(cFiltro)

If !Empty(M->QAE_DTFIM)
	MsgRun(OemToAnsi(STR0011),OemToAnsi(STR0012),{|| QXTerAusTmp()}) //"Finalizando Lancamentos de Ausencia Temporaria..." ### "Aguarde..."
EndIf        
  
dbSelectArea("QAA")
dbSetOrder(1)

For nX := 1 TO Len(aCols) 
	If Dbseek(aCols[nX,2]+aCols[nX,3])
		nTPPendPos:= Ascan(aUsrMail,{ |X| Upper(Alltrim(X[1]))==(Alltrim(aCols[nX,3]))})
		If nTPPendPos == 0 
		   cTpMail := QAA->QAA_TPMAIL
		   If Empty(cTpMail)
		   	cTpMail:="1" 
 	       Endif
		   Q040AVM(cTpMail,aCols,nX,cHora,@aMsg)
		   AAdd (aUsrMail,{QAA->QAA_MAT,QAA->QAA_EMAIL, aMsg})
		Endif
	Else
		MessageDlg("Usuario: "+aCols[nX,3]+" nao existe no cadastro!")	//"Usuario nao existe no cadastro!"
	Endif	
Next nX

QaEnvMail(aUsrMail,,,,cMatMail)

QAE->(DbGoto(nPosQAE))	
QAF->(DbGoto(nPosQAF))
QAE->(DbSetOrder(nOrdQAE))
QAF->(DbSetOrder(nOrdQAF))

DbSelectArea("QAE")
Set Filter To

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QXTerAusTmp³ Autor ³ Eduardo de Souza     ³ Data ³ 10/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se existe Termino/Finalizacao Ausencia Temporaria.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QXTerAusTmp()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QXTerAusTmp()

If QAF->(DbSeek(QAE->QAE_FILIAL+QAE->QAE_ANO+QAE->QAE_NUMERO))
	While QAF->(!Eof()) .And. QAF->QAF_FILIAL+QAF->QAF_ANO+QAF->QAF_NUMERO == QAE->QAE_FILIAL+QAE->QAE_ANO+QAE->QAE_NUMERO
		If QAF->QAF_FLAG <> "I"
			QX040Devol(QAE->QAE_FILMAT,QAE->QAE_MAT,QAE->QAE_DEPTO,1)
		EndIf
		QAF->(DbSkip())
	EndDo
	If nModulo == 24 // SIGAQDO
		QDX040Term()
	EndIf
EndIf

M->QAE_STATUS:= "2"
   
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX040Devol³ Autor ³ Eduardo de Souza      ³ Data ³ 10/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Devolucao/Transferencia da Ausencia Temporaria.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX040Devol(ExpC1,ExpC2,ExpC3,ExpN1)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Usuario                                  ³±±
±±³          ³ ExpC2 - Usuario                                            ³±±
±±³          ³ ExpC3 - Departamento                                       ³±±
±±³          ³ ExpN1 - Tipo (1 - Dev. Origem )                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX040Devol(cFilUsr,cMat,cDepto,nTipo)

If nModulo == 24 // SIGAQDO
	QDX040Dev(cFilUsr,cMat,cDepto,nTipo)
EndIf

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                     ³
//³FUNCOES UTILIZADAS PELO MODULO CONTROLE DE DOCUMENTOS³
//³                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDX040Atu ³ Autor ³ Eduardo de Souza      ³ Data ³ 07/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza lancamentos de Ausencia Temporaria.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDX040Atu()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FQDO_USR() - QDOXFUN.PRW                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDX040Atu()

Local nI       := 0
Local cAttach  := ""
Local aUsrMat  := QA_USUARIO()
Local aDiv     := {}
Local cFiltro  := ""
Local nPosQAE  := 0
Local aLancQAF := {}
Local aQDSRecno:={}
Local nCnt
Local aMail      := {}
Local cDescQD1   := ""
Local lEmail     := .F.
Local aQAA       := {}
Local nCt        := 0  
Local aQdskey	 := {} 
Local aQd1key    := {}
Local lTrExis    := .F.

Private bCampo   := {|nCPO| Field( nCPO ) }
Private cMatFil  := aUsrMat[2]
Private cMatCod  := aUsrMat[3]
Private cMatDep  := aUsrMat[4]
Private cTamAno  := Space(TamSX3("QD0_ANO")[1])
Private cTamNum  := Space(TamSX3("QD0_NUMERO")[1])
Private cTamDocto:= Space(TamSX3("QDH_DOCTO")[1])
Private cTamRv   := Space(TamSX3("QDH_RV")[1])
Private Inclui   := .F.
Private aUsrMail := {}

QD1->(DbSetOrder(3))
QD0->(DbSetOrder(2))

DbSelectArea("QAA")
DbSelectArea("QAE")
DbSetOrder(4)
cFiltro:= 'QAE_STATUS == "1" .And. QAE_MODULO == '+AllTrim(Str(nModulo))

Set Filter To &(cFiltro)
DbGotop()

Begin Transaction
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe Termino de Ausencia Temporaria	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While QAE->(!Eof()) .And. QAE->QAE_FILIAL+QAE->QAE_STATUS == xFilial("QAE")+"1" .And. DTOS(QAE->QAE_DTPREV) < DTOS(dDataBase)
	QXTerAusTmp()
	RecLock("QAE",.F.)
	QAE->QAE_STATUS:= "2"
	QAE->QAE_DTFIM := dDataBase
	MsUnlock()
	FKCOMMIT()
	QAE->(DbGotop())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe lancamento de Ausencia Temporaria para o Dia. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QAE->(DbSetOrder(3))
QAE->(DbGotop())
While QAE->(!Eof()) .And. QAE->QAE_FILIAL+QAE->QAE_STATUS == xFilial("QAE")+"1" .And. DTOS(QAE->QAE_DTINIC) <= DTOS(dDataBase)
	QAF->(DbSetOrder(1))
	If QAF->(DbSeek(QAE->QAE_FILIAL+QAE->QAE_ANO+QAE->QAE_NUMERO))
		While QAF->(!Eof()) .And. QAF->QAF_FILIAL+QAF->QAF_ANO+QAF->QAF_NUMERO == QAE->QAE_FILIAL+QAE->QAE_ANO+QAE->QAE_NUMERO
			If QAF->QAF_FLAG <> "I"

				cQuery := " SELECT QD1.QD1_FILMAT,QD1.QD1_MAT,QD1.QD1_TPPEND,"
				cQuery += " QD1.QD1_FILIAL,QD1.QD1_DOCTO,QD1.QD1_RV,QD1.QD1_SIT,QD1.QD1_DEPTO,"
				cQuery += " QD1.R_E_C_N_O_,QAA.QAA_MAT,QAA.QAA_DISTSN "						
				cQuery += " FROM " + RetSqlName("QD1") +" QD1, "+ RetSqlName("QAA") +" QAA"
				cQuery += " WHERE QD1.QD1_FILMAT = '" + QAE->QAE_FILMAT +"'"
				cQuery += " AND QD1.QD1_MAT = '"+ QAE->QAE_MAT +"'"
				cQuery += " AND QD1.QD1_PENDEN = 'P' "
				cQuery += " AND QD1.QD1_TPPEND = '"+ QAF->QAF_TPPEND +"'"
				cQuery += " AND QD1.QD1_SIT <> 'I' "
				cQuery += " AND QD1.D_E_L_E_T_ <> '*' AND QAA.D_E_L_E_T_ <> '*'"
				cQuery += " AND QAA.QAA_FILIAL = '"+ QAF->QAF_FILMAT +"'"
				cQuery += " AND QAA.QAA_MAT = '"+ QAF->QAF_MAT +"'"

				If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
					cQuery += " ORDER BY 1,2,3,4,5,6"
				Else
					cQuery += " ORDER BY " + SqlOrder("QD1_FILMAT+QD1_MAT+QD1_TPPEND+QD1_FILIAL+QD1_DOCTO+QD1_RV")
				Endif
								
				cQuery := ChangeQuery(cQuery)
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QD1TRB",.T.,.T.)
				
				QD1TRB->(DBGotop())
				WHILE QD1TRB->(!Eof())
					If QD1TRB->QD1_TPPEND == "D  "
						If QDH->(DbSeek(QD1TRB->QD1_FILIAL+QD1TRB->QD1_DOCTO+QD1TRB->QD1_RV))
							IF QDH->QDH_FILMAT+QDH->QDH_MAT != QAF->QAF_FILMAT+QAF->QAF_MAT
								RecLock("QDH",.F.)
								QDH->QDH_FILMAT:= QAF->QAF_FILMAT
								QDH->QDH_MAT   := QAF->QAF_MAT
								QDH->(MsUnlock())
								FKCOMMIT()
							Endif
						EndIf
					EndIf
					If QD1TRB->QD1_TPPEND == "I  "
						//Verificacao de acesso de distribuicao para usuario destino da ausencia temporaria
						If QD1TRB->QAA_DISTSN = '2'
							MSGALERT(STR0043+CHR(13)+CHR(10)+STR0044+QD1TRB->QD1_DOCTO+" "+STR0045+QD1TRB->QD1_RV+CHR(13)+CHR(10)+STR0046+QAE->QAE_MAT+CHR(13)+CHR(10)+STR0047+QAF->QAF_MAT)
							QD1TRB->(DbSkip())
							Loop
						Endif
						If QDH->(DbSeek(QD1TRB->QD1_FILIAL+QD1TRB->QD1_DOCTO+QD1TRB->QD1_RV))
							IF 	QDH->QDH_FILDEP+QDH->QDH_DEPTOD != QAF->QAF_FILMAT+QAF->QAF_DEPTO
								RecLock("QDH",.F.)
								QDH->QDH_FILDEP:= QAF->QAF_FILMAT
								QDH->QDH_DEPTOD:= QAF->QAF_DEPTO
								QDH->(MsUnlock())
								FKCOMMIT()
							ENDIF
						EndIf
					EndIf
					
					cQuery := " SELECT QD0.R_E_C_N_O_ "
					cQuery += " FROM " + RetSqlName("QD0") +" QD0 "
					cQuery += " WHERE QD0.QD0_FILIAL = '" + QD1TRB->QD1_FILIAL +"'"
					cQuery += " AND QD0.QD0_DOCTO = '"+ QD1TRB->QD1_DOCTO +"'"
					cQuery += " AND QD0.QD0_RV = '"+ QD1TRB->QD1_RV +"'"
					cQuery += " AND QD0.QD0_AUT = '"+SubStr(QAF->QAF_TPPEND,1,1)+"'"
					cQuery += " AND (QD0.QD0_FILMAT = '"+QD1TRB->QD1_FILMAT+"' AND QD0.QD0_DEPTO = '"+QD1TRB->QD1_DEPTO+"' AND QD0.QD0_MAT = '"+QD1TRB->QD1_MAT +"')"
					cQuery += " AND NOT (QD0.QD0_FILMAT = '"+QAF->QAF_FILMAT+"' AND QD0.QD0_DEPTO = '"+QAF->QAF_DEPTO+"' AND QD0.QD0_MAT = '" +QAF->QAF_MAT +"')"
					cQuery += " AND QD0.QD0_FLAG <> 'I'"
					cQuery += " AND QD0.D_E_L_E_T_ <> '*'"
					
					cQuery := ChangeQuery(cQuery)
					
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QD0TRB",.T.,.T.)
					
					QD0TRB->(DBGotop())
					WHILE QD0TRB->(!Eof())
						QD0->(DbGoTo(QD0TRB->R_E_C_N_O_))
						RecLock("QD0",.F.)
						QD0->QD0_FILMAT:= QAF->QAF_FILMAT
						QD0->QD0_MAT   := QAF->QAF_MAT
						QD0->QD0_DEPTO := QAF->QAF_DEPTO
						If Empty(QD0->QD0_ANO) .And. Empty(QD0->QD0_NUMERO)
							QD0->QD0_ANO   := QAF->QAF_ANO
							QD0->QD0_NUMERO:= QAF->QAF_NUMERO
						EndIf
						QD0->(MsUnlock())
						FKCOMMIT()
						If QAE->QAE_FLAG <> "S"
							RecLock("QAE",.F.)
							QAE->QAE_FLAG:= "S"
							QAE->(MsUnlock())
							FKCOMMIT()
						EndIf
						QD0TRB->(DbSkip())
					EndDo
					
					DbSelectArea("QD0TRB")
					DBCLOSEAREA()
					DbSelectArea("QD1TRB")
					
					If (QD1TRB->QD1_TPPEND != "EC " .OR. QD1TRB->QD1_TPPEND != "DC ") .AND. QD1TRB->QD1_SIT <> "I"
						QD4->(DbSetOrder(1))
						If QD4->(MsSeek(QD1TRB->QD1_FILIAL+QD1TRB->QD1_DOCTO+QD1TRB->QD1_RV))
							While !QD4->(Eof()) .And. QD4->QD4_FILIAL+QD4->QD4_DOCTO+QD4->QD4_RV == QD1TRB->QD1_FILIAL+QD1TRB->QD1_DOCTO+QD1TRB->QD1_RV
								If  QD4->QD4_PENDEN == "P" .AND. (QD4->QD4_FILMAT+QD4->QD4_MAT == QAE->QAE_FILMAT+QAE->QAE_MAT)
									Reclock("QD4",.F.)
									QD4->QD4_FILMAT := QAF->QAF_FILMAT
									QD4->QD4_MAT	:= QAF->QAF_MAT
									MsUnlock()
									FKCOMMIT()
								Endif
								QD4->(dbSkip())
							Enddo
						Endif
					Endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³AVISOS QUE ACOMPANHA AS PENDENCIAS QUE SERAO TRANSF PELA AUSENCIA ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aQDSRecno:={}
					QD5->(DbSetOrder(1))
					QDS->(DbSetOrder(1))
					If QDS->(DbSeek(QAE->QAE_FILMAT+QAE->QAE_MAT+"P"))
						While QDS->(!EOF()) .AND. QAE->QAE_FILMAT+QAE->QAE_MAT+"P" == QDS->QDS_FILMAT+QDS->QDS_MAT+QDS->QDS_PENDEN
							IF QDS->QDS_DOCTO+QDS->QDS_RV == QD1TRB->QD1_DOCTO+QD1TRB->QD1_RV .AND. !(QDS->QDS_TPPEND $ "TMP.VEN")
								IF  Alltrim(QAF->QAF_TPPEND)!="I" .AND. QDS->QDS_TPPEND $ "QUE.REF.SAD"
									If QD5->(DbSeek(xFilial("QD5") + POSICIONE("QDH",1,QDS->QDS_FILIAL+QDS->QDS_DOCTO+QDS->QDS_RV,"QDH_CODTP") + QAF->QAF_TPPEND))
										If QD5->QD5_GREV == "S"
											AADD(aQDSRecno,QDS->(Recno()))
										Endif
									Endif
								ElseIF  Alltrim(QAF->QAF_TPPEND)=="I" .AND. QDS->QDS_TPPEND == "TRE"
									AADD(aQDSRecno,QDS->(Recno()))
								Endif
							Endif
							QDS->(DBSkip())
						EndDo
						For Ni:=1 To Len(aQDSRecno) 
							QDS->(DbGoto(aQDSRecno[Ni]))
							aQdskey:={}
							aadd(aQdskey,{QAF->QAF_FILMAT,QAF->QAF_MAT,QDS->QDS_PENDEN,QDS->QDS_TPPEND,QDS->QDS_DOCTO,QDS->QDS_RV})									
							QDS->(Dbgotop())											
							lTrExis:=iif (QDS->(DbSeek(aQdskey[1][1]+aQdskey[1][2]+aQdskey[1][3]+aQdskey[1][4]+aQdskey[1][5]+aQdskey[1][6])),.T.,.F.)									
							QDS->(DbSetOrder(1))		
							QDS->(DbGoto(aQDSRecno[Ni]))
							Reclock("QDS",.F.) 
							if !lTrExis									
								QDS->QDS_FILMAT:= QAF->QAF_FILMAT
								QDS->QDS_MAT   := QAF->QAF_MAT
								QDS->QDS_DEPTO := QAF->QAF_DEPTO                                    	
							Else
								QDS->(DbDelete())
							EndIf
							MsUnlock()
							FKCOMMIT()                        
						Next                                                 	
					Endif
					
					QD1->(DbGoTo(QD1TRB->R_E_C_N_O_))
					aQd1key:={}
					aadd(aQd1key,{QD1->QD1_FILIAL,QD1->QD1_DOCTO,QD1->QD1_RV,QAF->QAF_DEPTO,QAF->QAF_FILMAT,QAF->QAF_MAT,QD1->QD1_TPPEND,QD1->QD1_PENDEN})																
					QD1->(Dbsetorder(7))
					QD1->(Dbgotop())											
					lTrExis:=iif (QD1->(DbSeek(aQd1key[1][1]+aQd1key[1][2]+aQd1key[1][3]+aQd1key[1][4]+aQd1key[1][5]+aQd1key[1][6]+aQd1key[1][7]+aQd1key[1][8])),.T.,.F.)									
					QD1->(Dbsetorder(1))	
					QD1->(DbGoTo(QD1TRB->R_E_C_N_O_))							
					RecLock("QD1",.F.) 
					if !lTrExis
						QD1->QD1_FILMAT:= QAF->QAF_FILMAT
						QD1->QD1_MAT   := QAF->QAF_MAT
						QD1->QD1_DEPTO := QAF->QAF_DEPTO
						QD1->QD1_CARGO := POSICIONE("QAA" ,2, QAF->(QAF_FILMAT+QAF_DEPTO+QAF_MAT), "QAA_CODFUN")//QAA_FILIAL+QAA_CC+QAA_MAT
						If Empty(QD1->QD1_ANO) .And. Empty(QD1->QD1_NUMERO)
							QD1->QD1_ANO   := QAF->QAF_ANO
							QD1->QD1_NUMERO:= QAF->QAF_NUMERO
						EndIf
					Else
						QD1->(DbDelete())
					EndIf
					QD1->(MsUnlock())
					FKCOMMIT()
					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Inserindo as pendencias para exibi-las  no email.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					cDescQD1 := AllTrim(Tabela("Q7", QD1->QD1_TPPEND, .F.))
					AADD(aMail,{QD1->QD1_DOCTO, QD1->QD1_RV, Left(cDescQD1,50), QD1->QD1_DTGERA,QD1->QD1_TPPEND})										
					
					If QAE->QAE_FLAG <> "S"
						RecLock("QAE",.F.)
						QAE->QAE_FLAG:= "S"
						QAE->(MsUnlock())
						FKCOMMIT()
					EndIf
					
					QD1TRB->(DbSkip())
				EndDO
				
				DbSelectArea("QD1TRB")
				DBCLOSEAREA()
				DbSelectArea("QAE")

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³AVISOS DOC VENCIDOS QUE SERAO TRANSF PELA AUSENCIA ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aQDSRecno:={}
				QD5->(DbSetOrder(1))
				QDS->(DbSetOrder(1))
				If QDS->(DbSeek(QAE->QAE_FILMAT+QAE->QAE_MAT+"P"+"VEN"))
					While QDS->(!EOF()) .AND. QAE->QAE_FILMAT+QAE->QAE_MAT+"P"+"VEN" == QDS->QDS_FILMAT+QDS->QDS_MAT+QDS->QDS_PENDEN+QDS->QDS_TPPEND
						If QD5->(DbSeek(xFilial("QD5") + POSICIONE("QDH",1,QDS->QDS_FILIAL+QDS->QDS_DOCTO+QDS->QDS_RV,"QDH_CODTP") + QAF->QAF_TPPEND))
							If QD5->QD5_GREV == "S"
								AADD(aQDSRecno,{QDS->(Recno()),QDS->QDS_DOCTO,QDS->QDS_RV})
							Endif
						Endif
						QDS->(DbSkip())
					EndDo
					For Ni:=1 To Len(aQDSRecno)
						If !QDS->(DbSeek(QAF->QAF_FILMAT+QAF->QAF_MAT+"P"+"VEN"+aQDSRecno[Ni,2]+aQDSRecno[Ni,3]))	
							QDS->(DbGoto(aQDSRecno[Ni,1]))
							Reclock("QDS",.F.)
							QDS->QDS_FILMAT:= QAF->QAF_FILMAT
							QDS->QDS_MAT   := QAF->QAF_MAT
							QDS->QDS_DEPTO := QAF->QAF_DEPTO
							MsUnlock()
							FKCOMMIT() 						
						Endif
					Next
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava Aviso de Ausencia Temporaria.     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QDS->(DbSetOrder(1))
				If !QDS->(DbSeek(QAF->QAF_FILMAT+QAF->QAF_MAT+"P"+"TMP"+cTamDocto+cTamRv+QAE->QAE_ANO+QAE->QAE_NUMERO))
					QDXGvAviso("TMP",QAF->QAF_FILMAT,QAF->QAF_MAT,QAF->QAF_DEPTO,,,QAE->QAE_ANO+QAE->QAE_NUMERO,QAF->QAF_FILMAT)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Envia email avisando o usuario substituto para pendencia. ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If QAA->(DbSeek(QAF->QAF_FILMAT+QAF->QAF_MAT))
						If !Empty(QAA->QAA_EMAIL) .And. QAA->QAA_RECMAI == "1" 
							aDiv  := {{QAE->QAE_ANO,QAE->QAE_NUMERO,DTOC(QAE->QAE_DTINIC),DTOC(QAE->QAE_DTPREV),QAXDescSX5("QG",QAE->QAE_MOT,""),QAE->QAE_DEPTO } }
							lEmail:= .T.
							AADD(aQAA,{QAA->QAA_EMAIL, QAE->QAE_FILMAT, QAA->QAA_APELID, QAE->QAE_MAT,cAttach})
						EndIf
					EndIf
				EndIf
			EndIf
			QAF->(DbSkip())
		EndDo
	EndIf

    If lEmail 
      For nCt:=1 To Len(aQAA) 
		FQdoTpMail(@aUsrMail,,,,aQAA[nCt,1],"TMP",aQAA[nCt,2],aQAA[nCt,3],aQAA[nCt,4],aQAA[nCt,5],,aDiv,,,aMail)
	  Next	
    Endif


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe Transferencia de Ausencia Temporaria.         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aLancQAF:= {}
	DbSelectArea("QAF")
	QAF->(DbSetOrder(1))
	If QAF->(DbSeek(QAE->QAE_FILIAL+QAE->QAE_ANO+QAE->QAE_NUMERO))
		While QAF->(!Eof()) .And. QAF->QAF_FILIAL+QAF->QAF_ANO+QAF->QAF_NUMERO == QAE->QAE_FILIAL+QAE->QAE_ANO+QAE->QAE_NUMERO
			If QAF->QAF_FLAG <> "I"
				aAdd(aLancQAF,{QAF->QAF_FILMAT,QAF->QAF_MAT,QAF->QAF_DEPTO,QAF->QAF_TPPEND})
			EndIf
			QAF->(DbSkip())
		EndDo
	EndIf
	QAE->(DbSetOrder(1))
	nPosQAE:= QAE->(Recno())
	cFilUsr:= QAE->QAE_FILMAT
	cMat   := QAE->QAE_MAT
	QAF->(DbSetOrder(2))
	For nCnt:= 1 To Len(aLancQAF)
		If QAF->(DbSeek(cFilUsr+cMat+aLancQAF[nCnt,4]))
			While QAF->(!Eof()) .And. QAF->QAF_FILMAT+QAF->QAF_MAT+QAF->QAF_TPPEND == cFilUsr+cMat+aLancQAF[nCnt,4]
				If QAF->QAF_FLAG <> "I"
					If QAE->(DbSeek(QAF->QAF_FILIAL+QAF->QAF_ANO+QAF->QAF_NUMERO))
						If QAE->QAE_DTINIC <= dDataBase
							For nI:= 1 To FCount()
								M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
							Next nI
							RecLock("QAF",.F.)
							QAF->QAF_FLAG:= "I"
							QAF->(MsUnlock())
							FKCOMMIT()
							QX040Devol(aLancQAF[nCnt,1],aLancQAF[nCnt,2],aLancQAF[nCnt,3])
							QAF->(DbSetOrder(1))
							nPos:= QAF->(Recno())
							If !QAF->(DbSeek(M->QAF_FILIAL+M->QAF_ANO+M->QAF_NUMERO+M->QAF_TPPEND+aLancQAF[nCnt,1]+aLancQAF[nCnt,2]))
								RecLock("QAF",.T.)
								For nI:= 1 to FCount()
									FieldPut(nI, M->&(Eval(bCampo,nI)))
								Next nI
								QAF->QAF_FILMAT:= aLancQAF[nCnt,1]
								QAF->QAF_MAT   := aLancQAF[nCnt,2]
								QAF->QAF_DEPTO := aLancQAF[nCnt,3]
								QAF->QAF_FLAG  := "T"
								QAF->(MsUnLock())
								FKCOMMIT()
							EndIf
							QAF->(DbGoto(nPos))
						EndIf
					EndIf
				EndIf
				QAF->(DbSetOrder(2))
				QAF->(DbSkip())
			EndDo
		EndIf
	Next nCnt
	QAE->(DbSetOrder(3))
	QAE->(DbGoto(nPosQAE))
	QAE->(DbSkip())
EndDo

End Transaction

QaEnvMail(aUsrMail,,,,aUsrMat[5])

DbSelectArea("QAE")
DbSetOrder(1)
Set Filter To

QD1->(DbSetOrder(1))
QD0->(DbSetOrder(1))

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDX040TPen³ Autor ³ Eduardo de Souza      ³ Data ³ 14/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega os tipos de pendencias.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDX040TPen()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDX040TPen()

Local oDlg
Local oListbox
Local oOk    := LoaDbitmap( GetResources(),"ENABLE")
Local oNo    := LoaDbitmap( GetResources(),"LBNO")
Local cMvpar := &(ReadVar()) // Carrega Nome da Variavel do Get em Questao
Local cMvret := ReadVar() // Iguala Nome da Variavel ao Nome variavel de Retorno
Local nOpcao := 0
Local nCnt   := 0
Local oFilUsr
Local oCodUsr
Local oDesUsr
Local cFilUsr	:= xFilial("QAA")
Local cCodUsr	:= Space(TamSx3("QAA_MAT" )[1])
Local cDesUsr	:= Space(TamSx3("QAA_NOME")[1])
Local lPrimeiro := .T.
Local lRetorno 	:= .T.
Local lOk	 	:= .F.
Local nI	    := 0
Local aSX5Q7	:= FWGetSX5("Q7") 
Local nPX5Filial:= 1
Local nPX5Chave	:= 3
Local nPX5Descr	:= 4

Private nQaConpad	:= Nil

aNiv:= {}
Aadd(aNiv,{If("O  " $ cMvpar,.T.,.F.),OemToAnsi(STR0021),"O  "}) // "Todos"

If Len(aSX5Q7)>0 .AND. aScan(aSX5Q7,{|x| x[nPX5Filial]==xFilial("SX5")})>0
	For nI := 1 to Len(aSX5Q7)
		If xFilial("SX5")==aSX5Q7[nI][nPX5Filial] .AND. ;
		  !Empty(aSX5Q7[nI][nPX5Chave]) .And. !(Substr(aSX5Q7[nI][nPX5Chave],1,3) $ "L  ")
			If Substr(aSX5Q7[nI][nPX5Chave],1,3) $ cMvpar
				Aadd(aNiv,{.T.,Alltrim(aSX5Q7[nI][nPX5Descr]),Substr(aSX5Q7[nI][nPX5Chave],1,3)})
			Else
				Aadd(aNiv,{.F.,Alltrim(aSX5Q7[nI][nPX5Descr]),Substr(aSX5Q7[nI][nPX5Chave],1,3)})
			Endif
		EndIf
	Next nI
Else
	Help(" ",1,"QDOR050SIT")		// Parametro Default
	AADD(aNiv,{If("D  "$cMvpar,.T.,.F.),OemToAnsi(STR0014),"D  "}) //"Digita‡ao"
	AADD(aNiv,{If("E  "$cMvpar,.T.,.F.),OemToAnsi(STR0015),"E  "}) //"Elabora‡ao"
	AADD(aNiv,{If("R  "$cMvpar,.T.,.F.),OemToAnsi(STR0016),"R  "}) //"Revisao"
	AADD(aNiv,{If("A  "$cMvpar,.T.,.F.),OemToAnsi(STR0017),"A  "}) //"Aprova‡ao"
	AADD(aNiv,{If("H  "$cMvpar,.T.,.F.),OemToAnsi(STR0018),"H  "}) //"Homologa‡ao"
	AADD(aNiv,{If("I  "$cMvpar,.T.,.F.),OemToAnsi(STR0019),"I  "}) //"Distribui‡ao"
EndIf

If Len(aNiv) > 0
	DEFINE MSDIALOG oDlg FROM 000,000 TO 180,420 TITLE OemToAnsi(STR0020) PIXEL //"Escolha Padrao"
	@ 005,003 LISTBOX oListBox;
					FIELDS HEADER " ",OemToAnsi(STR0013); // "Tipo de Pendencia"
					SIZE 135,057 PIXEL;
					ON DbLCLICK (fSelecCli(@oListBox,aNiv),oFilUsr:SetFocus())
	oListBox:SetArray(aNiv)
	oListBox:bLine  := { || {If(aNiv[oListBox:nAt,1],oOk,oNo),aNiv[oListBox:nAt,2]}}

	@ 065,003 TO 088,208 LABEL OemToAnsi(STR0022) OF oDlg PIXEL //"Usuario"
	@ 075,006 	MSGET oFilUsr VAR cFilUsr PICTURE Repl("@!",FWSizeFilial()) F3 "SM0" SIZE 055,008 OF oDlg PIXEL;
	          	VALID QA_CHKFIL(cFilUsr,@cFilMat) WHEN QDX040Marc(aNiv)

	@ 075,070 	MSGET oCodUsr VAR cCodUsr PICTURE '@!' F3 "QDE" SIZE 044,008 OF oDlg PIXEL;
				WHEN QDX040Marc(aNiv);
				VALID (	cDesUsr:= QA_NUSR(cFilUsr,cCodUsr,.T.),	oDesUsr:Refresh(),;
					(lOk:=M->QAE_FILMAT+M->QAE_MAT!=cFilUsr+cCodUsr),IF(!lOk,Help(" ",1,"QX040UNDES"),""),lOk)
				
	@ 075,120 MSGET oDesUsr VAR cDesUsr SIZE 85,008 OF oDlg PIXEL WHEN .f.

	DEFINE SBUTTON FROM 005,175 TYPE 1;
	ACTION 	If	(QDX040Marc(aNiv) .And. (Empty(cFilUsr) .Or. Empty(cCodUsr) .Or.;
				Empty(cDesUsr)),;
						(nOpcao := 0,Help(" ",1,"QD050FNE")), (nOpcao:= 1,oDlg:End())) ENABLE OF oDlg PIXEL
	DEFINE SBUTTON FROM 049,175 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg PIXEL
		
	ACTIVATE MSDIALOG oDlg CENTERED
		
	If nOpcao == 1
		WhemMat()
		If QDX040Marc(aNiv)		// Ao selecionar mais de um deve informar o usuario
			For nCnt:= 2 TO Len(aNiv)
				If 	aNiv[nCnt,1] .And.;
					(Ascan(aCols, { |x|	x[nPosPen] = aNiv[nCnt,3] .And. ! x[nUsado + 1] })) = 0
					If ! lPrimeiro
						aAdd(aCols,Array(nUsado+1))
						For nI := 1 to nUsado
							If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
								aCols[Len(aCols),nI] := QAF->(FieldGet(FieldPos(aHeader[nI,2])))
							ElseIf AllTrim(Upper(aHeader[nI,2])) == "QAF_REC_WT" .Or.;//Campos do Walk Thru
								   AllTrim(Upper(aHeader[nI,2])) == "QAF_ALI_WT"
								Skip
							Else                                        // Campo Virtual
								cCpo := AllTrim(Upper(aHeader[nI,2]))
								aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
							EndIf
						Next nI
					Else
						&cMvRet:= aNiv[nCnt,3]
					Endif
					
				   //	lRetorno  := .F.
					lPrimeiro := .F.
					aCols[Len(aCols),nUsado+1] := .F.
					aCols[Len(aCols), nPosPen] := aNiv[nCnt,3]
					aCols[Len(aCols), nPosFUs] := cFilUsr
					aCols[Len(aCols), nPosUsr] := cCodUsr
					aCols[Len(aCols), nPosNom] := QA_NUsr(cFilUsr, cCodUsr, .T.)
					QAA->(DbSeek(cFilUsr + cCodUsr))
					aCols[Len(aCols), nPosDep] := QAA->QAA_CC
				Endif
			Next nCnt
		Else
			cMvpar:= ""
			For nCnt:= 2 TO Len(aNiv)
				cMvpar+= If(aNiv[nCnt,1],aNiv[nCnt,3],"")
			Next nCnt
			If Empty(cMvPar)
				cMvPar:= Space(3)
			EndIf
			&cMvRet:= cMvpar
		Endif
	EndIf
Else
	Help(" ",1,"QX040NEXTP") // "Nao existe Tipo de pendencia para associar a Ausencia Temporaria."
EndIf

Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDX040Marc ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 14/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna se foi efetuada marca de mais de um tipo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDX040Marc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QDX040Marc(aNiv)

Local nRetorno := 0, nCnt := 0

For nCnt:= 2 TO Len(aNiv)
	nRetorno += If(aNiv[nCnt,1],1,0)
Next nCnt

Return nRetorno >= 1

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDX040Term ³ Autor ³ Eduardo de Souza     ³ Data ³ 14/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Termino / Finalizacao da Ausencia Temporaria.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDX040Term()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDX040Term()

Local nI     := 0
Local nPosQD0:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se Usuario Destino Liberou alguma Etapa.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("QD0")
QD0->(DbSetOrder(3))
If QD0->(DbSeek(xFilial("QD0")+QAE->QAE_ANO+QAE->QAE_NUMERO))
	While QD0->(!Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_ANO+QD0->QD0_NUMERO == xFilial("QD0")+QAE->QAE_ANO+QAE->QAE_NUMERO
		If QD0->QD0_FLAG == "I"
			QD0->(DbSkip())
			Loop
		EndIf
		nPosQD0:= QD0->(Recno())
		For nI:= 1 To FCount()
			M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
		Next nI
		RecLock("QD0",.F.)
		QD0->QD0_FLAG := "I"
		QD0->(DbDelete())
		QD0->(MsUnLock())
		FKCOMMIT()

		QD0->(DbSetOrder(2))
		If !QD0->(DbSeek(M->QD0_FILIAL+M->QD0_DOCTO+M->QD0_RV+M->QD0_AUT+QAE->QAE_FILMAT+QAE->QAE_DEPTO+QAE->QAE_MAT))
			RecLock("QD0",.T.)
			For nI:= 1 to FCount()
				FieldPut(nI, M->&(Eval(bCampo,nI)))
			Next nI
			QD0->QD0_FILMAT:= QAE->QAE_FILMAT
			QD0->QD0_MAT   := QAE->QAE_MAT
			QD0->QD0_DEPTO := QAE->QAE_DEPTO
			QD0->QD0_ANO   := cTamAno
			QD0->QD0_NUMERO:= cTamNum
			QD0->QD0_FLAG  := ""
			QD0->(MsUnLock())
			FKCOMMIT()
		EndIf
		QD0->(DbSetOrder(3))
		QD0->(DbGoto(nPosQD0))
		QD0->(DbSkip())
	EndDo
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDX040Dev ³ Autor ³ Eduardo de Souza      ³ Data ³ 14/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Devolucao/Transferencia da Ausencia Temporaria.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDX040Dev(ExpC1,ExpC2,ExpC3,ExpN1)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Usuario                                  ³±±
±±³          ³ ExpC2 - Usuario                                            ³±±
±±³          ³ ExpC3 - Departamento                                       ³±±
±±³          ³ ExpN1 - Tipo (1 - Dev. Origem )                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDX040Dev(cFilUsr,cMat,cDepto,nTipo)

Local cAttach  	:= ""
Local aDiv     	:= {}
Local Ni

Default nTipo:= 0

QD0->(DbSetOrder(2))
QD1->(DbSetOrder(3))
If QD1->(DbSeek(QAF->QAF_FILMAT+QAF->QAF_MAT+"P"+QAF->QAF_TPPEND+QAF->QAF_ANO+QAF->QAF_NUMERO))
	While QD1->(!Eof()) .And. QD1->QD1_FILMAT+QD1->QD1_MAT+QD1->QD1_PENDEN+QD1->QD1_TPPEND+QD1->QD1_ANO+QD1->QD1_NUMERO == QAF->QAF_FILMAT+QAF->QAF_MAT+"P"+QAF->QAF_TPPEND+QAF->QAF_ANO+QAF->QAF_NUMERO
		
		If QD1->QD1_TPPEND == "D  "
			If QDH->(DbSeek(QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV))
				RecLock("QDH",.F.)
				QDH->QDH_FILMAT:= cFilUsr
				QDH->QDH_MAT   := cMat
				QDH->(MsUnlock())
				FKCOMMIT()
			EndIf		
		EndIf
		If QD1->QD1_TPPEND == "I  "
			If QDH->(DbSeek(QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV))
				RecLock("QDH",.F.)
				QDH->QDH_FILDEP:= cFilUsr
				QDH->QDH_DEPTOD:= cDepto
				QDH->(MsUnlock())								
				FKCOMMIT()
			EndIf
		EndIf						
		If QD0->(DbSeek(QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+SubStr(QD1->QD1_TPPEND,1,1)+QD1->QD1_FILMAT+QD1->QD1_DEPTO+QD1->QD1_MAT))
			While QD0->(!Eof()) .And.	QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV+QD0->QD0_AUT+QD0->QD0_FILMAT+QD0->QD0_DEPTO+QD0->QD0_MAT == ;
				QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+SubStr(QD1->QD1_TPPEND,1,1)+QD1->QD1_FILMAT+QD1->QD1_DEPTO+QD1->QD1_MAT
				If QD0->QD0_FLAG <> "I"
					RecLock("QD0",.F.)
					QD0->QD0_FILMAT:= cFilUsr
					QD0->QD0_MAT   := cMat
					QD0->QD0_DEPTO := cDepto
					If nTipo == 1 // "Devolucao para Origem"
						QD0->QD0_ANO   := cTamAno
						QD0->QD0_NUMERO:= cTamNum
					EndIf
					QD0->(MsUnlock())
					FKCOMMIT()
				EndIf
				QD0->(DbSkip())
			EndDo
		EndIf
		
		If (QD1->QD1_TPPEND != "EC " .OR. QD1->QD1_TPPEND != "DC ") .AND. QD1->QD1_SIT <> "I"
			QD4->(DbSetOrder(1))
			If QD4->(MsSeek(QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV))
				While !QD4->(Eof()) .And. QD4->QD4_FILIAL+QD4->QD4_DOCTO+QD4->QD4_RV == QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV
					If  QD4->QD4_PENDEN == "P" .AND. (QD4->QD4_FILMAT+QD4->QD4_MAT == QD1->QD1_FILMAT+QD1->QD1_MAT)
						Reclock("QD4",.F.)
						QD4->QD4_FILMAT := cFilUsr
						QD4->QD4_MAT	:= cMat
						MsUnlock()
						FKCOMMIT()
					Endif
					QD4->(dbSkip())
				Enddo
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³AVISOS QUE ACOMPANHA AS PENDENCIAS QUE SERAO TRANSF PELA AUSENCIA ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aQDSRecno:={}
		QD5->(DbSetOrder(1))
		QDS->(DbSetOrder(1))
		If QDS->(DbSeek(QAF->QAF_FILMAT+QAF->QAF_MAT+"P"))
			While QDS->(!EOF()) .AND. QAF->QAF_FILMAT+QAF->QAF_MAT+"P" == QDS->QDS_FILMAT+QDS->QDS_MAT+QDS->QDS_PENDEN			
				IF QDS->QDS_DOCTO+QDS->QDS_RV == QD1->QD1_DOCTO+QD1->QD1_RV .AND. !(QDS->QDS_TPPEND $ "TMP.VEN")
					IF  Alltrim(QAF->QAF_TPPEND)!="I" .AND. QDS->QDS_TPPEND $ "QUE.REF.SAD"
						If QD5->(DbSeek(xFilial("QD5") + POSICIONE("QDH",1,QDS->QDS_FILIAL+QDS->QDS_DOCTO+QDS->QDS_RV,"QDH_CODTP") + QAF->QAF_TPPEND))
							If QD5->QD5_GREV == "S"
								AADD(aQDSRecno,QDS->(Recno()))
							Endif
						Endif
					ElseIF  Alltrim(QAF->QAF_TPPEND)=="I" .AND. QDS->QDS_TPPEND == "TRE"
						AADD(aQDSRecno,QDS->(Recno()))
					Endif
				Endif
				QDS->(DbSkip())
			EndDo
			For Ni:=1 To Len(aQDSRecno)
				QDS->(DbGoto(aQDSRecno[Ni]))
				Reclock("QDS",.F.)
				QDS->QDS_FILMAT:= cFilUsr
				QDS->QDS_MAT   := cMat
				QDS->QDS_DEPTO := cDepto
				MsUnlock()
				FKCOMMIT()
			Next			
		Endif								
                                                                
		If QD1->QD1_SIT <> "I"
			RecLock("QD1",.F.)
			QD1->QD1_FILMAT:= cFilUsr
			QD1->QD1_MAT   := cMat
			QD1->QD1_DEPTO := cDepto
			QD1->QD1_CARGO := POSICIONE("QAA" ,2, cFilUsr+cDepto+cMat, "QAA_CODFUN")//QAA_FILIAL+QAA_CC+QAA_MAT
			If nTipo == 1 // "Devolucao para Origem"
				QD1->QD1_ANO   := cTamAno
				QD1->QD1_NUMERO:= cTamNum
			EndIf
			QD1->(MsUnlock())
			FKCOMMIT()
		EndIf
		QD1->(DbSeek(QAF->QAF_FILMAT+QAF->QAF_MAT+"P"+QAF->QAF_TPPEND+QAF->QAF_ANO+QAF->QAF_NUMERO))
	EndDo
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³AVISOS DOC VENCIDOS QUE SERAO TRANSF PELA AUSENCIA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aQDSRecno:={}
QD5->(DbSetOrder(1))
QDS->(DbSetOrder(1))
If QDS->(DbSeek(QAF->QAF_FILMAT+QAF->QAF_MAT+"P"+"VEN"))
	While QDS->(!EOF()) .AND. QAF->QAF_FILMAT+QAF->QAF_MAT+"P"+"VEN" == QDS->QDS_FILMAT+QDS->QDS_MAT+QDS->QDS_PENDEN+QDS->QDS_TPPEND
		If QD5->(DbSeek(xFilial("QD5") + POSICIONE("QDH",1,QDS->QDS_FILIAL+QDS->QDS_DOCTO+QDS->QDS_RV,"QDH_CODTP") + QAF->QAF_TPPEND))
			If QD5->QD5_GREV == "S"
				AADD(aQDSRecno,{QDS->(Recno()),QDS->QDS_DOCTO,QDS->QDS_RV})
			Endif
		Endif
		QDS->(DbSkip())
	EndDo
	For Ni:=1 To Len(aQDSRecno)
		If !QDS->(DbSeek(cFilUsr+cMat+"P"+"VEN"+aQDSRecno[Ni,2]+aQDSRecno[Ni,3]))	
			QDS->(DbGoto(aQDSRecno[Ni,1]))
			Reclock("QDS",.F.)
			QDS->QDS_FILMAT:= cFilUsr
			QDS->QDS_MAT   := cMat
			QDS->QDS_DEPTO := cDepto
			MsUnlock()
			FKCOMMIT()
		Endif	
	Next
Endif

	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava Aviso de Ausencia Temporaria.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo <> 1 // Transferencia para outro usuario destino
	QDS->(DbSetOrder(1))
	If !QDS->(DbSeek(cFilUsr+cMat+"P"+"TMP"+cTamDocto+cTamRv+QAE->QAE_ANO+QAE->QAE_NUMERO))
		QDXGvAviso("TMP",cFilUsr,cMat,cDepto,,,QAE->QAE_ANO+QAE->QAE_NUMERO,cFilUsr)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Envia email avisando o usuario substituto para pendencia. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QAA->(DbSeek(cFilUsr+cMat))
			If !Empty(QAA->QAA_EMAIL) .And. QAA->QAA_RECMAI == "1"
				aDiv := {{QAE->QAE_ANO,QAE->QAE_NUMERO,DTOC(QAE->QAE_DTINIC),DTOC(QAE->QAE_DTPREV),QAXDescSX5("QG",QAE->QAE_MOT,""),QAE->QAE_DEPTO }}
				FQdoTpMail(@aUsrMail,,,,QAA->QAA_EMAIL,"TMP",QAE->QAE_FILMAT,QAA->QAA_APELID,QAE->QAE_MAT,cAttach,,aDiv)
			EndIf
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Baixa o Aviso ao Termino da Ausencia Temporaria.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QDS->(DbSetOrder(1))
If QDS->(DbSeek(QAF->QAF_FILMAT+QAF->QAF_MAT+"P"+"TMP"+cTamDocto+cTamRv+QAF->QAF_ANO+QAF->QAF_NUMERO))
	RecLock("QDS",.F.)
	QDS->QDS_PENDEN := "B"
	QDS->QDS_DTBAIX:= dDataBase
	QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
	QDS->QDS_FMATBX := cMatFil
	QDS->QDS_MATBX  := cMatCod
	QDS->QDS_DEPBX  := cMatDep
	QDS->(MsUnlock())
	FKCOMMIT()
EndIf

Return	


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WhemMat   ºAutor  ³Telso Carneiro      º Data ³  04/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Controle da Whem do campo Filial e Matricula               º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function WhemMat()
	nPosFIL:=Ascan(aGets,{|X| "QAE_FILMAT"$X } )
	nPosMAT:=Ascan(aGets,{|X| "QAE_MAT"$X } )		
	IF !EMPTY(M->QAE_FILMAT) .AND. !EMPTY(M->QAE_MAT)
		oGetAus:AENTRYCTRLS[nPosFIL]:BWHEN:={|X| .F. }
		oGetAus:AENTRYCTRLS[nPosMAT]:BWHEN:={|X| .F. }
	ENDIF         		
Return .T.		

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QA_SitAuseºAutor  ³Telso Carneiro      º Data ³  11/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica a Existencia de Ausencia Temporaria para o Usuarioº±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QA_SitAuse(cMatFil,cMatCod,cTpend)

Local lRet	 := .F.
Local aArea	 := GetArea()
Local cQuery := ""     
Local cFilNov:= ""
Local cMatNov:= ""
Local cDepNov:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe lancamento de Ausencia Temporaria  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	       
cQuery := " SELECT QAF.QAF_TPPEND,QAF.QAF_FILMAT,QAF.QAF_MAT,QAF.QAF_DEPTO "
cQuery += " FROM " + RetSqlName("QAE")+" QAE ,"+ RetSqlName("QAF")+" QAF "
cQuery += " WHERE QAE.QAE_FILIAL = '"+xFilial("QAE")+"'
cQuery += " AND QAE.QAE_STATUS = '1' AND QAE.QAE_MODULO = "+AllTrim(Str(nModulo))
cQuery += " AND QAE.QAE_FILIAL = QAF.QAF_FILIAL AND QAF.QAF_FLAG <> 'I'"
cQuery += " AND QAE.QAE_ANO = QAF.QAF_ANO AND QAE.QAE_NUMERO = QAF.QAF_NUMERO "
cQuery += " AND QAE.QAE_FILMAT = '" + cMatFil +"'"
cQuery += " AND QAE.QAE_MAT = '" + cMatCod +"'"
cQuery += " AND QAE.D_E_L_E_T_ <> '*' AND QAF.D_E_L_E_T_ <> '*'"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QAETRB",.T.,.T.)

QAETRB->(DBGotop())
WHILE QAETRB->(!Eof())
	IF SUBS(QAETRB->QAF_TPPEND,1,1)==cTpend
		cFilNov:= QAETRB->QAF_FILMAT	
		cMatNov:= QAETRB->QAF_MAT	    
		cDepNov:= QAETRB->QAF_DEPTO
		lRet:= .T.
		Exit
	Endif
	QAETRB->(DbSkip())
EndDO

DBCLOSEAREA()


RestARea(aArea)

Return({lRet,cFilNov,cMatNov,cDepNov})


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDX040Lib ºAutor  ³Telso Carneiro      º Data ³  12/05/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica a Existencia de Doctos que possa afetar a		  º±±
±±º			 ³	 Ausencia Temporaria para o Usuario                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QDX040Lib(aColsAux,cMatFil,cMatDep,cMatCod)
Local cQuery := ""
Local nI	 := 0
Local nFilMat:= GdFieldPos("QAF_FILMAT",aHeader)
Local nMat   := GdFieldPos("QAF_MAT"   ,aHeader)
Local nDepto := GdFieldPos("QAF_DEPTO" ,aHeader)
Local nTPpend:= GdFieldPos("QAF_TPPEND",aHeader)
Local aArea	 := GetARea()                                                                          

QAA->(DbSetOrder(1))        
QAA->(DBSeek(cMatFil+cMatCod))
cMatCar:=QAA->QAA_CODFUN
	       
For nI:=1 to LEN(aColsAux)
	IF !aColsAux[nI,Len(aColsAux[nI])]  //Nao deletado
		cQuery := " SELECT QDH.QDH_DOCTO, QDH.QDH_RV "
		cQuery += " FROM " + RetSqlName("QDH")+" QDH "
		cQuery += " WHERE QDH.QDH_FILIAL = '"+xFilial("QDH")+"'
		cQuery += " AND QDH.QDH_STATUS <> 'L  ' "     //LEITURA E DISTRIBUICAO
		cQuery += " AND QDH.QDH_OBSOL <> 'S'" 
		cQuery += " AND QDH.D_E_L_E_T_ <> '*'"
						  
		cQuery += " AND 
		cQuery += "("					
		cQuery += " ((EXISTS(SELECT QD0.R_E_C_N_O_ FROM "+ RetSqlName("QD0")+" QD0 WHERE QDH.QDH_FILIAL = QD0.QD0_FILIAL "
		cQuery += " AND QDH.QDH_DOCTO = QD0.QD0_DOCTO AND QDH.QDH_RV = QD0.QD0_RV AND QD0.QD0_FLAG <> 'I'"						
		cQuery += " AND QD0.QD0_AUT = '"+Substr(aColsAux[nI,nTPpend],1,1)+"'"		
		cQuery += " AND QD0.QD0_FILMAT = '"+cMatFil+"' AND QD0.QD0_MAT = '"+cMatCod+"' AND QD0.QD0_DEPTO = '"+cMatDep+"'"
		cQuery += " AND QD0.D_E_L_E_T_ <> '*')"
		
		cQuery += " AND EXISTS(SELECT QD0.R_E_C_N_O_ FROM "+ RetSqlName("QD0")+" QD0 WHERE QDH.QDH_FILIAL = QD0.QD0_FILIAL "
		cQuery += " AND QDH.QDH_DOCTO = QD0.QD0_DOCTO AND QDH.QDH_RV = QD0.QD0_RV AND QD0.QD0_FLAG <> 'I'"						
		cQuery += " AND QD0.QD0_AUT = '"+Substr(aColsAux[nI,nTPpend],1,1)+"'"		
		cQuery += " AND QD0.QD0_FILMAT = '"+aColsAux[nI,nFilMat]+"' AND QD0.QD0_MAT = '"+aColsAux[nI,nMat]+"' AND QD0.QD0_DEPTO = '"+aColsAux[nI,nDepto]+"'"
		cQuery += " AND QD0.D_E_L_E_T_ <> '*'))"
		cQuery += " OR 
		cQuery += " (EXISTS(SELECT QD1.R_E_C_N_O_ FROM "+ RetSqlName("QD1")+" QD1 WHERE QDH.QDH_FILIAL = QD1.QD1_FILIAL "
		cQuery += " AND QDH.QDH_DOCTO = QD1.QD1_DOCTO AND QDH.QDH_RV = QD1.QD1_RV AND QD1.QD1_SIT <> 'I'"						
		cQuery += " AND QD1.QD1_TPPEND = '"+Substr(aColsAux[nI,nTPpend],1,1)+"'"		
		cQuery += " AND QD1.QD1_FILMAT = '"+cMatFil+"' AND QD1.QD1_MAT = '"+cMatCod+"' AND QD1.QD1_DEPTO = '"+cMatDep+"'"
		cQuery += " AND QD1.D_E_L_E_T_ <> '*'))"
		
		cQuery += " AND EXISTS(SELECT QD1.R_E_C_N_O_ FROM "+ RetSqlName("QD1")+" QD1 WHERE QDH.QDH_FILIAL = QD1.QD1_FILIAL "
		cQuery += " AND QDH.QDH_DOCTO = QD1.QD1_DOCTO AND QDH.QDH_RV = QD1.QD1_RV AND QD1.QD1_SIT <> 'I'"						
		cQuery += " AND QD1.QD1_TPPEND = '"+Substr(aColsAux[nI,nTPpend],1,1)+"'"		
		cQuery += " AND QD1.QD1_FILMAT = '"+aColsAux[nI,nFilMat]+"' AND QD1.QD1_MAT = '"+aColsAux[nI,nMat]+"' AND QD1.QD1_DEPTO = '"+aColsAux[nI,nDepto]+"'"
		cQuery += " AND QD1.D_E_L_E_T_ <> '*'))"												

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a Existencia da matriz de Responsabilidade na     ³
		//³ para a Ausencia e valida o usuario transferido        	   ³
		//³ pertence a matriz de Responsabilidade                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QAA->(DBSeek(aColsAux[nI,nFilMat]+aColsAux[nI,nMat]))
		cUsrCar:=QAA->QAA_CODFUN
		
		IF cMatDep <> aColsAux[nI,nDepto] .OR. cMatCar <> cUsrCar 

			cQuery += " OR (EXISTS(SELECT QD0.R_E_C_N_O_ FROM "+ RetSqlName("QD0")+" QD0 WHERE QDH.QDH_FILIAL = QD0.QD0_FILIAL "
			cQuery += " AND QDH.QDH_DOCTO = QD0.QD0_DOCTO AND QDH.QDH_RV = QD0.QD0_RV AND QD0.QD0_FLAG <> 'I'"						
			cQuery += " AND QD0.QD0_AUT = '"+Substr(aColsAux[nI,nTPpend],1,1)+"'"		
			cQuery += " AND QD0.QD0_FILMAT = '"+cMatFil+"' AND QD0.QD0_MAT = '"+cMatCod+"' AND QD0.QD0_DEPTO = '"+cMatDep+"'"
			cQuery += " AND QD0.D_E_L_E_T_ <> '*')"

			cQuery += " AND EXISTS(SELECT QDD.R_E_C_N_O_ FROM "+ RetSqlName("QDD")+" QDD WHERE QDH.QDH_FILIAL = QDD.QDD_FILIAL "
			cQuery += " AND QDH.QDH_CODTP = QDD.QDD_CODTP "						
			cQuery += " AND QDD.QDD_AUT = '"+Substr(aColsAux[nI,nTPpend],1,1)+"'"		
			//cQuery += " AND QDD.QDD_FILA = '"+aColsAux[nI,nFilMat]+"' AND QDD.QDD_CARGOA = '"+cUsrCar+"' AND QDD.QDD_DEPTOA = '"+aColsAux[nI,nDepto]+"'"
			cQuery += " AND QDD.D_E_L_E_T_ <> '*'))"												
			
		Endif
		cQuery += ")"					

		cQuery := ChangeQuery(cQuery)				
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QD0TRB",.T.,.T.)
		
		QD0TRB->(DBGotop())
		WHILE QD0TRB->(!Eof())
			AADD(aDoctos,{QD0TRB->QDH_DOCTO,QD0TRB->QDH_RV,	aColsAux[nI,nTPpend],;
						   aColsAux[nI,nFilMat],aColsAux[nI,nMat],QA_NUSR(aColsAux[nI,nFilMat],aColsAux[nI,nMat]),aColsAux[nI,nDepto]} ) 
			QD0TRB->(DbSKIP())				
		Enddo
				
		QD0TRB->(DBCLOSEAREA())
	Endif
Next

RestARea(aArea)
                        
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDX40AuDlgºAutor  ³Telso Carneiro      º Data ³  13/05/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de Apresentaca das Inconsistencias da Ausencia Temp.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QX040VldF (Validacao da Tela)                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QDX40AuDlg(aDoctos)

Local oDlg,oList3,oFilUsr,oCodUsr,oDesUsr
Local cFilUsr:=M->QAE_FILMAT  
Local cCodUsr:=M->QAE_MAT
Local cDesUsr:=QA_NUSR(M->QAE_FILMAT,M->QAE_MAT)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001)+" - "+OemToAnsi(STR0023) FROM 000,000 TO 385,625 OF oMainWnd PIXEL //"Ausencia Temporaria" //"Inconsistencia"

@ 005,003 TO 028,165 LABEL OemToAnsi(STR0022) OF oDlg PIXEL //"Filial/Usuario"
@ 012,006 MSGET oFilUsr VAR cFilUsr SIZE 010,008 OF oDlg PIXEL WHEN .F.
@ 012,025 MSGET oCodUsr VAR cCodUsr SIZE 044,008 OF oDlg PIXEL	WHEN .F.			
@ 012,075 MSGET oDesUsr VAR cDesUsr SIZE 85,008 OF oDlg PIXEL WHEN .f.

@ 005,168 SAY OemToAnsi(STR0024) SIZE 200,007 OF oDlg COLOR CLR_HRED,CLR_WHITE PIXEL	 //"Documentos com Inconsistencia na Ausencia Temporaria "
@ 013,168 SAY OemToAnsi(STR0025) SIZE 200,007 OF oDlg COLOR CLR_HRED,CLR_WHITE  PIXEL	 //"entre Usuarios de mesma Responsabilidade, "
@ 021,168 SAY OemToAnsi(STR0033) SIZE 200,007 OF oDlg COLOR CLR_HRED,CLR_WHITE  PIXEL	 //"ou Responsáveis no Tipo de Documento."

@ 030,003 LISTBOX oList3 FIELDS HEADER Alltrim(TitSx3("QDH_DOCTO")[1]),;
                                  		Alltrim(TitSx3("QDH_RV")[1]),;
                                   		Alltrim(TitSx3("QAF_TPPEND")[1]),;
										Alltrim(TitSx3("QAF_FILMAT")[1]),;
                                        Alltrim(TitSx3("QAF_MAT")[1]),;
                                        Alltrim(TitSx3("QAF_NOME")[1]),;
                                        Alltrim(TitSx3("QAF_DEPTO")[1]) SIZE 308,140 PIXEL

oList3:SetArray(aDoctos)
oList3:bLine := { || { aDoctos[oList3:nAt,1],aDoctos[oList3:nAt,2],aDoctos[oList3:nAt,3],aDoctos[oList3:nAt,4],aDoctos[oList3:nAt,5],aDoctos[oList3:nAt,6],aDoctos[oList3:nAt,7]}}
oList3:GoTop()
oList3:Refresh()

DEFINE SBUTTON FROM 175,250 TYPE 6 ACTION QAXR040(aDoctos) ENABLE OF oDlg PIXEL
DEFINE SBUTTON FROM 175,280 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QAXR040  ³ Autor ³ Leandro S. Sabino     ³ Data ³ 24/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Ausencia Temporaria						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs:      ³ (Versao Relatorio Personalizavel) 		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA040	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function QAXR040(aDoctos)
Local oReport

If TRepInUse()
    oReport := ReportDef(aDoctos)
    oReport:PrintDialog()
Else
	QAXR040R3(aDoctos)
EndIF    

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef()   ³ Autor ³ Leandro Sabino   ³ Data ³ 24.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montar a secao				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDef()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(aDoctos)   
Local oReport 
Local oSection1 
Local oSection2 

oReport   := TReport():New("QAXR040",OemToAnsi(STR0027),,{|oReport| RF040Imp(oReport,aDoctos)},OemToAnsi(STR0024)+OemToAnsi(STR0025))
//"Documentos com Inconsistencia na Ausencia Temporaria##"Este programa tem como objetivo imprimir relatorio "## "## "entre Usuarios de mesma Responsabilidade. "

oSection1 := TRSection():New(oReport,TitSx3("QAF_NOME")[1],{"QAA"})
oReport:SetLandscape(.T.)
TRCell():New(oSection1,"QAE_FILMAT","   ",(TitSx3("QAF_FILIAL")[1]),,16,/*lPixel*/,/*{||}*/)//"Filial"
TRCell():New(oSection1,"QAE_MAT"   ,"   ",(TitSx3("QAE_MAT")[1])   ,,15,/*lPixel*/,/*{||}*/)//"Codigo do Usuario"
TRCell():New(oSection1,"QAE_NOME"  ,"   ",(TitSx3("QAF_NOME")[1])  ,,20,/*lPixel*/,/*{||}*/)//"Usuario"
TRPosition():New(oReport:Section(1),"QAA", 1, {|| M->QAE_FILMAT+M->QAE_MAT})

oSection2 := TRSection():New(oSection1,TitSx3("QDH_DOCTO")[1]) //"Documento"
oSection2:SetTotalInLine(.F.)
TRCell():New(oSection2,"QDH_DOCTO"  ,"   ",(TitSx3("QDH_DOCTO")[1]),,16,/*lPixel*/,/*{||}*/)//"Doc."
TRCell():New(oSection2,"QDH_RV"		,"   ",(TitSx3("QDH_RV")[1])	 ,,3 ,/*lPixel*/,/*{||}*/)//"Revisao"
TRCell():New(oSection2,"QAF_TPPEND"	,"   ",(TitSx3("TAQ_PENDEN")[1]),,17,/*lPixel*/,/*{||}*/)//"Tipo"
TRCell():New(oSection2,"Filial"	    ,"   ",(TitSx3("QAF_FILIAL")[1]),,3 ,/*lPixel*/,/*{||}*/)//"Filial"
TRCell():New(oSection2,"QAF_MAT"	,"   ",(TitSx3("QAF_MAT")[1])  ,,13 ,/*lPixel*/,/*{||}*/)//"Usuario"
TRCell():New(oSection2,"QAA_NOME"	,"   ",(TitSx3("QAA_NOME")[1])  ,,25 ,/*lPixel*/,/*{||}*/)//"Usuario"
TRCell():New(oSection2,"QAF_DEPTO"	,"   ",(TitSx3("QAF_DEPTO")[1]) ,,38,/*lPixel*/,/*{||}*/)//"Cod. Depto"

Return oReport


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RF040Imp      ³ Autor ³ Leandro Sabino   ³ Data ³ 24.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprimir os campos do relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RF040Imp(ExpO1)   	     	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oReport- Objeto oPrint                                     ³±±
±±³          | aDoctos- Array com o Doctos Inconsistentes                 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADR045                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RF040Imp(oReport,aDoctos)
Local oSection1   := oReport:Section(1)
Local oSection2   := oReport:Section(1):Section(1)
Local nI          := 0
Local cTpPend     := ""

oSection1:Init()
oSection1:Cell("QAE_FILMAT"):SetValue(M->QAE_FILMAT)//"Filial"
oSection1:Cell("QAE_MAT"):SetValue(M->QAE_MAT)//"Cod Usuario"
oSection1:Cell("QAE_NOME"):SetValue(QA_NUSR(M->QAE_FILMAT,M->QAE_MAT))//"Usuario"
oSection1:PrintLine()

oSection2:Init()
         
For nI:= 1 To Len(aDoctos)
	oSection2:Cell("QDH_DOCTO"):SetValue(aDoctos[nI,1])//"Doc."
	oSection2:Cell("QDH_RV"):SetValue(aDoctos[nI,2])//"Revisao"
	Do Case
		Case aDoctos[nI,3] == "D"
			cTpPend:= OemToAnsi(STR0014) //"Digita‡ao"
	 	Case aDoctos[nI,3] == "E"
			cTpPend:= OemToAnsi(STR0015) //"Elabora‡ao"
	 	Case aDoctos[nI,3] == "R"
			cTpPend:= OemToAnsi(STR0016) //"Revisao"
	 	Case aDoctos[nI,3] == "A"
			cTpPend:= OemToAnsi(STR0017)//"Aprova‡ao"
	 	Case aDoctos[nI,3] == "H"                                               
			cTpPend:= OemToAnsi(STR0018) //"Homologa‡ao"
	 	Case aDoctos[nI,3] == "I"
			cTpPend:= OemToAnsi(STR0019) //"Distribui‡ao"
	EndCase         			                      
	oSection2:Cell("QAF_TPPEND"):SetValue(aDoctos[nI,3]+" "+cTpPend)//"Tipo"
	oSection2:Cell("Filial"):SetValue(aDoctos[nI,4])// Filial
	oSection2:Cell("QAF_MAT"):SetValue(aDoctos[nI,5]+" "+AllTrim(aDoctos[nI,6]))//Cod. Usuario+ "Nome"
	oSection2:Cell("QAA_NOME"):SetValue(AllTrim(aDoctos[nI,6]))//"Nome"
	oSection2:Cell("QAF_DEPTO"):SetValue(aDoctos[nI,7]+" "+AllTrim(QA_NDEPT(aDoctos[nI,7],.T.,cFilDep)))//"Cod. Depto + "Descricao"
	oSection2:PrintLine()
Next                                                      

oSection1:Finish()
oSection2:Finish()

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAXR040R3 ºAutor  ³Telso Carneiro      º Data ³  13/05/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio de Doctos Inconsistencia na Ausencia Temporaria   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QDX40AuDlg                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QAXR040R3(aDoctos)

Local cDesc1       := STR0026 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2       := STR0024 //"Documentos com Inconsistencia na Ausencia Temporaria "
Local cDesc3       := STR0025 //"entre Usuarios de mesma Responsabilidade. "
Local cPict        := ""
Local titulo       := STR0027 //"Docs.Inconsistencia Ausencia Temp."
Local nLin         := 80

Local Cabec1       := OemToAnsi(STR0022)
Local Cabec2       := M->QAE_FILMAT +"       "+M->QAE_MAT+" - "+QA_NUSR(M->QAE_FILMAT,M->QAE_MAT)
Local imprime      := .T.
Local aOrd 		   := {}

Private limite     := 80
Private tamanho    := "P"
Private nomeprog   := "QAXR040"
Private nTipo      := 18
Private aReturn    := { STR0028, 1, STR0029, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey   := 0
Private m_pag      := 01
Private wnrel      := "QAXR040" 

Private cString := "QAF"

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| QDX40AuRel(Cabec1,Cabec2,Titulo,nLin,aDoctos) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³QDX40AuRelº Autor ³ Telso Carneiro     º Data ³  13/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QAXR040                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function QDX40AuRel(Cabec1,Cabec2,Titulo,nLin,aDoctos)

Local nI
Local cCabec3 := (TitSx3("QDH_DOCTO")[1])+" "+ALLTRIM(TitSx3("QDH_RV")[1])+" "+(TitSx3("QAF_TPPEND")[1])+"     "+OemToAnsi(STR0007)+SPACE(18)+(TitSx3("QAF_DEPTO")[1])                                 	
Local cTpPend := ""

SetRegua(len(aDoctos))

For nI:=1 TO Len(aDoctos)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica o cancelamento pelo usuario...                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
   IncRegua()
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio. . .                            ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If nLin > 60
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)                   
      nLin := 9
      @nLin,00 PSAY cCabec3                  
      nLin++                                 
   	  @nLin,000 Psay __PrtThinLine() 
      nLin++                                 
   Endif

	Do Case
		Case aDoctos[nI,3] == "D"
			cTpPend:= OemToAnsi(STR0014) //"Digita‡ao"
	 	Case aDoctos[nI,3] == "E"
			cTpPend:= OemToAnsi(STR0015) //"Elabora‡ao"
	 	Case aDoctos[nI,3] == "R"
			cTpPend:= OemToAnsi(STR0016) //"Revisao"
	 	Case aDoctos[nI,3] == "A"
			cTpPend:= OemToAnsi(STR0017)//"Aprova‡ao"
	 	Case aDoctos[nI,3] == "H"                                               
			cTpPend:= OemToAnsi(STR0018) //"Homologa‡ao"
	 	Case aDoctos[nI,3] == "I"
			cTpPend:= OemToAnsi(STR0019) //"Distribui‡ao"
	EndCase         			                      
   
   @nLin,00 PSAY aDoctos[nI,1]+" "+aDoctos[nI,2]+" "+aDoctos[nI,3]+" "+cTpPend
   @nLin,38 PSAY aDoctos[nI,4]+" "+aDoctos[nI,5]+"-"+SUBS(aDoctos[nI,6],1,18)+" "+aLLTRIM(aDoctos[nI,7])
   nLin++                                           

Next


SET DEVICE TO SCREEN

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAX040QDD ºAutor  ³Telso Carneiro      º Data ³  10/04/2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica a Existencia da matriz de Responsabilidade na     º±±
±±º          ³ para a Ausencia e valida o usuario transferido        	  º±±
±±º          ³ pertence a matriz de Responsabilidade        			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QDX040QDD(aDoctos,cTpPen,cUsrFil,cUsrMat,cDepto,cCargo,cCodTP,cDocFil,cDocCod,cDocRv)
Local aArea  := GetArea()
Local lResp	 := .T.

QDD->(DbSetOrder(1))
If QDD->(DbSeek(cDocFil+cCodTP+cTpPen))
	lResp:=.F.
	While QDD->(!Eof()) .And. QDD->QDD_FILIAL+QDD->QDD_CODTP+QDD->QDD_AUT == cDocFil+cCodTP+cTpPen
		IF QDD->QDD_FILA==cUsrFil .AND. QDD->QDD_DEPTOA==cDepto .And.  QDD->QDD_CARGOA==cCargo
			lResp:=.T.
		Endif
		QDD->(DbSkip())
	Enddo
	IF !lResp
		AADD(aDoctos,{cDocCod,cDocRv,cTpPen,cUsrFil,cUsrMat,QA_NUSR(cUsrFil,cUsrMat),cDepto} )
	Endif
EndIf

ResTArea(aArea)
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAIncNom  ºAutor  ³Rafael S. Bernardi  º Data ³  12/01/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicialiazador padrao para o campo vitual QAF_NOME          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QAXA040                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QAIncNom()

	Local nIndFIL := Nil
	Local nIndMAT := Nil
	Local nX      := Nil

	For nX := 1 To Len(aHeader)
		If ascan(aHeader[nX],"QAF_FILMAT") != 0
			nIndFIL := nX
		EndIf
	Next nX

	For nX := 1 To Len(aHeader)
		If ascan(aHeader[nX],"QAF_MAT") != 0
			nIndMAT := nX
		EndIf
	Next nX

	If Len(aHeader) > 0;
	   .And. aCols[Len(aCols)][nIndFIL] <> NIL;
	   .And. aCols[Len(aCols)][nIndMAT] <> NIL

		Posicione("QAA", 1, aCols[Len(aCols)][nIndFIL]+aCols[Len(aCols)][nIndMAT], "QAA_NOME")
		Return QAA->QAA_NOME
	EndIf

Return " "


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q040AVM   ºAutor  ³Eliane Machado      º Data ³  08/24/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³Envia e-mail aos substitutos da tarefa                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QAXA040                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
                
Function Q040AVM(cTpMail,aCols,nX,cHora,aMsg)
Local cSubject                    
Local cMsg     

cSubject:= OemToAnsi(STR0036)+" - "+DTOC(dDataBase)+" - "+cHora //"Aviso de transferencia de assuntos pendentes"
If cTpMail == "1"
	cMsg:= '<html><title>SIGAQDO</title><body>'
	cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
	cMsg+= '  <tr><td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606"'
	cMsg+= '  borderColorDark="#0099cc" bgColor="#0099cc" height="1">'
	cMsg+= '  <p align="center"><FONT face="Courier New" color="#ffffff" size="4">'
	cMsg+= '  <b>'+OemToAnsi(STR0037)+'</b></font></p></td></tr><tr><td align="left" width="606" height="32">' // "MENSAGEM"
	cMsg+= '  <p align="center">'+OemToAnsi(STR0038)+OemToAnsi(STR0039)+'</p></td></tr>'  //"Existe(m) pendencia(s) de transferencia(s) de documento(s), favor liquidar rapidamente, e/ou" // "Consulte o relatorio de transferencia."
	cMsg+= '</table><br>'

	cMsg+= '<br>'
	cMsg+= OemToAnsi(STR0040)+'<br>'+Alltrim(QA_NUSR(aCols[nX,2],aCols[nX,3])) //"Atenciosamente"
	cMsg+= '  <br>'+Alltrim(QA_NDEPT(aCols[nX,5]))
	cMsg+= '  <br><p><font size="2"><em>'+OemToAnsi(STR0041)+'</em></font></p></body></html>' // "Mensagem criada automaticamente pelo Modulo Sigaqdo - Controle de Documentos"

Else
   cMsg:= OemToAnsi(STR0038)+CHR(13)+CHR(10)  //"Existe(m) pendencia(s) de transferencia(s) de documento(s), favor liquidar rapidamente, e/ou"
   cMsg+= OemToAnsi(STR0042)+CHR(13)+CHR(10)+CHR(13)+CHR(10)  //"Consulte o Relatorio de Transferencia. "
				
   cMsg+= OemToAnsi(STR0040)+CHR(13)+CHR(10)//"Atenciosamente"
   cMsg+= Alltrim(QA_NUSR(aCols[nX,2],aCols[nX,3]))+CHR(13)+CHR(10)
   cMsg+= Alltrim(QA_NDEPT(aCols[nX,5]))+CHR(13)+CHR(10)+CHR(13)+CHR(10)
   cMsg+= OemToAnsi(STR0041) // "Mensagem criada automaticamente pelo Modulo SIGAQDO - Controle de Documentos"		
EndIf
   aMsg:= { { cSubject,cMsg,"" } }
Return NIL

