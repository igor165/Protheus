#include "QIEM030.CH" 
#include "PROTHEUS.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QIEM030	³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 20/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Transferencia de Pendencias da Permissao Uso   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ STR		 ³ Ultimo utilizado: 0009                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo       ³25/04/00³------³ Incluido o quinto parametro como 3 no  ³±±
±±³Marcelo       ³25/04/00³------³ array aRotina.                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIEM030
Local nOpcA 	 := 0
Local nAcols	 := 0					// No. elementos do aCols
Local lGravaOk   := .T.
Local oDlg
Local oGet
Local aAlter
Local cAlias	 := "QF2"
Local cMVQELAUSQ := SuperGetMv("MV_QELAUSQ")

Private cCadastro := ""
Private aHeader[0]
Private nUsado    :=0
Private aCols	  := {}
Private nOpc      := 4
Private aRotina   := {{"Pesquisar" ,"AxPesqui"  , 0, 1},;
                      {"Visualizar","A240Visual" , 0, 2},;
					  {"Incluir"   ,"M030Inclui" , 0, 3},;
					  {"Alterar"   ,"M030Altera" , 0, 6},;
					  {"Excluir"   ,"M030Deleta" , 0, 5,3}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o usuario tem o nivel exigido para transferencia ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Nivel 102: Transfere Pendencias
If !QA_NivAces(102,STR0009)	// "Usuário não tem o nível de acesso exigido."
	Return(.F.)
EndIf
	
aCols 	:= {}
aHeader	:= {}

// Monta o aHeader

// Campo Filial do Usuario
Aadd(aHeader, Q030GETSX3("QAA_FILIAL","",""))

// Campo Matricula do Usuario
Aadd(aHeader, Q030GETSX3("QAA_MAT","",""))

// Campo Nome do Usuario
Aadd(aHeader, Q030GETSX3("QAA_NOME","",""))

// Campo Data de Demissao
Aadd(aHeader, Q030GETSX3("QAA_FIM","",""))

// Campo Funcao do Usuario (D=Destinatario, U=Usuario Qualidade, E=Emissor)
Aadd(aHeader, Q030GETSX3("QF3_STATUS",STR0001,"@!"))

// Campo Numero da Permissao Uso
Aadd(aHeader, Q030GETSX3("QF2_NUMERO","",""))

// Campo Status da Permissao de Uso
Aadd(aHeader, Q030GETSX3("QF2_NUMERO","",""))

// Campo Fornecedor
Aadd(aHeader, Q030GETSX3("QF2_FORNEC","",""))

// Campo Loja do Fornecedor
Aadd(aHeader, Q030GETSX3("QF2_LOJFOR","",""))

// Campo Produto
Aadd(aHeader, Q030GETSX3("QF2_PRODUT","",""))

// Campo Data Entrada
Aadd(aHeader, Q030GETSX3("QF2_DTENTR","",""))

// Campo Lote
Aadd(aHeader, Q030GETSX3("QF2_LOTE","",""))

// Campo Filial novo usuario
Aadd(aHeader, Q030GETSX3("QF3_FILMAT",STR0002,"")) // "Filial Novo Responsável"

// Campo novo usuario
Aadd(aHeader, Q030GETSX3("QF3_MAT",STR0003,"")) // "Novo Responsável"

// Campo Apelido do novo Usuario
Aadd(aHeader, Q030GETSX3("QF3_NOMMAT","",""))

nUsado := Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona as PUs com status Em aberto. Se o Usuario da ³
//³ Qualidade ou os Destinatarios tiverem sido demitidos,  ³
//³ eles deverao ser substituidos. Isto devera ser feito   ³
//³ na opcao Transferencia de Pendencias, no menu Miscela- ³
//³ nea, por uma pessoa com nivel de acesso devido.        ³
//³ Se existir uma PU aberta que o emissor tiver sido demi-³
//³ tido, nao troca, porque fica como historico da PU.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
QF3->(dbSetOrder(1))

dbSelectArea("QF2")
dbSetOrder(1)
dbSeek(xFilial("QF2"))
	
While !Eof() .And. QF2_FILIAL == xFilial("QF2")
   // Verifica todas as PUs em aberto
	If QF2->QF2_STATUS == "E"	// Pu com status Em Aberto
   	// Verifica se o Usuario da Qualidade esta demitido
		QAA->(dbSetOrder(1))
  		If QAA->(dbSeek(QF2->QF2_FILQLD+QF2->QF2_MATQLD)) .And. ;
   				QAA->QAA_STATUS == "2"
 					
	  		// Alimenta o aCols
			aadd(aCols,Array(nUsado+1))	// Cria novo vetor acols
			nAcols := Len(aCols)
	
			aCols[nAcols][1]  := QF2->QF2_FILQLD
			aCols[nAcols][2]  := QF2->QF2_MATQLD
			aCols[nAcols][3]  := QAA->QAA_NOME
			aCols[nAcols][4]  := QAA->QAA_FIM
			aCols[nAcols][5]  := "Usuario Qualidade"
			aCols[nAcols][6]  := QF2->QF2_NUMERO
			aCols[nAcols][7]  := QF2->QF2_STATUS
			aCols[nAcols][8]  := QF2->QF2_FORNEC
			aCols[nAcols][9]  := QF2->QF2_LOJFOR
			aCols[nAcols][10] := QF2->QF2_PRODUT
			aCols[nAcols][11] := QF2->QF2_DTENTR
			aCols[nAcols][12] := QF2->QF2_LOTE
			aCols[nAcols][13] := CriaVar(Alltrim("QF3_FILMAT"))
			aCols[nAcols][14] := CriaVar(Alltrim("QF3_MAT"))
			aCols[nAcols][15] := Space(Len(QAA->QAA_APELID))
			aCols[nAcols][16] := .F.
   	EndIf

		// Verifica se os Destinatarios desta PU estao demitidos
		If QF3->(dbSeek(xFilial("QF3")+QF2->QF2_FORNEC+QF2->QF2_LOJFOR+;
					QF2->QF2_PRODUT+DtoS(QF2->QF2_DTENTR)+QF2->QF2_LOTE+;
					QF2->QF2_NUMERO))
			While QF3->QF3_FILIAL+QF3->QF3_FORNEC+QF3->QF3_LOJFOR+;
						QF3->QF3_PRODUT+DtoS(QF3->QF3_DTENTR)+QF3->QF3_LOTE+;
						QF3->QF3_NUMERO == xFilial("QF3")+QF2->QF2_FORNEC+;
						QF2->QF2_LOJFOR+QF2->QF2_PRODUT+DtoS(QF2->QF2_DTENTR)+;
						QF2->QF2_LOTE+	QF2->QF2_NUMERO .And. !QF3->(Eof())

				// Se o destinatario nao tiver dado laudo
				If QF3->QF3_STATUS == "E"
					QAA->(dbSetOrder(1))
	   			If QAA->(dbSeek(QF3->QF3_FILMAT+QF3->QF3_MAT)) .And. ;
	   					QAA->QAA_STATUS == "2"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Monta vetor aCols ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aadd(aCols,Array(nUsado+1))	// Cria novo vetor acols
						nAcols := Len(aCols)
					
						aCols[nAcols][1] := QF3->QF3_FILMAT
						aCols[nAcols][2] := QF3->QF3_MAT
						aCols[nAcols][3] := QAA->QAA_NOME
						aCols[nAcols][4] := QAA->QAA_FIM
						aCols[nAcols][5] := "Destinatario"
						aCols[nAcols][6] := QF2->QF2_NUMERO
						aCols[nAcols][7] := QF2->QF2_STATUS
						aCols[nAcols][8] := QF2->QF2_FORNEC
						aCols[nAcols][9] := QF2->QF2_LOJFOR
						aCols[nAcols][10] := QF2->QF2_PRODUT
						aCols[nAcols][11] := QF2->QF2_DTENTR
						aCols[nAcols][12] := QF2->QF2_LOTE
						aCols[nAcols][13] := CriaVar(Alltrim("QF3_FILMAT"))
						aCols[nAcols][14] := CriaVar(Alltrim("QF3_MAT"))
						aCols[nAcols][15] := Space(Len(QAA->QAA_APELID))
						aCols[nAcols][16] := .F.
	  				EndIf	
	  			EndIf	
   			QF3->(dbSkip())
   		EndDo	
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existem Pendencias para o Usuario Qual. (laudo) para Baixar ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cMVQELAUSQ == "S" .And. QF2->QF2_STATUS == "P"
  		// Verifica se o Usuario da Qualidade esta demitido
		QAA->(dbSetOrder(1))
		If QAA->(dbSeek(QF2->QF2_FILQLD+QF2->QF2_MATQLD)) .And. ;
				QAA->QAA_STATUS == "2"
 					
	  		// Alimenta o aCols
			aadd(aCols,Array(nUsado+1))	// Cria novo vetor acols
			nAcols := Len(aCols)
	
			aCols[nAcols][1]  := QF2->QF2_FILQLD
			aCols[nAcols][2]  := QF2->QF2_MATQLD
			aCols[nAcols][3]  := QAA->QAA_NOME
			aCols[nAcols][4]  := QAA->QAA_FIM
			aCols[nAcols][5]  := "Usuario Qualidade"
			aCols[nAcols][6]  := QF2->QF2_NUMERO
			aCols[nAcols][7]  := QF2->QF2_STATUS
			aCols[nAcols][8]  := QF2->QF2_FORNEC
			aCols[nAcols][9]  := QF2->QF2_LOJFOR
			aCols[nAcols][10] := QF2->QF2_PRODUT
			aCols[nAcols][11] := QF2->QF2_DTENTR
			aCols[nAcols][12] := QF2->QF2_LOTE
			aCols[nAcols][13] := CriaVar(Alltrim("QF3_FILMAT"))
			aCols[nAcols][14] := CriaVar(Alltrim("QF3_MAT"))
			aCols[nAcols][15] := Space(Len(QAA->QAA_APELID))
			aCols[nAcols][16] := .F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existem Pendencias Encerramento como Usuario Qualidade ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QF2->QF2_ENCQLD == "S"
		QAA->(dbSetOrder(1))
		If QAA->(dbSeek(QF2->QF2_FILQLD + QF2->QF2_MATQLD)) .And. ;
				QAA->QAA_STATUS == "2"
 					
	  		// Alimenta o aCols
			aadd(aCols,Array(nUsado+1))	// Cria novo vetor acols
			nAcols := Len(aCols)

			aCols[nAcols][1]  := QF2->QF2_FILQLD
			aCols[nAcols][2]  := QF2->QF2_MATQLD
			aCols[nAcols][3]  := QAA->QAA_NOME
			aCols[nAcols][4]  := QAA->QAA_FIM
			aCols[nAcols][5]  := "Usuario Qualidade"
			aCols[nAcols][6]  := QF2->QF2_NUMERO
			aCols[nAcols][7]  := QF2->QF2_STATUS
			aCols[nAcols][8]  := QF2->QF2_FORNEC
			aCols[nAcols][9]  := QF2->QF2_LOJFOR
			aCols[nAcols][10] := QF2->QF2_PRODUT
			aCols[nAcols][11] := QF2->QF2_DTENTR
			aCols[nAcols][12] := QF2->QF2_LOTE
			aCols[nAcols][13] := CriaVar(Alltrim("QF3_FILMAT"))
			aCols[nAcols][14] := CriaVar(Alltrim("QF3_MAT"))
			aCols[nAcols][15] := Space(Len(QAA->QAA_APELID))
			aCols[nAcols][16] := .F.
		EndIf
   EndIf

	dbSelectArea("QF2")
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe dados para transferencia ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCols) == 0
	MessageDlg(STR0004,,2)	// "Não hã dados para transferência."
Else
	nOpc := 4
	aAlter := {"QF3_FILMAT","QF3_MAT"}
    aRotina[nOpc,4] := 6

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0005) FROM 150,1 TO 390,560 OF oMainWnd PIXEL	 // "Pendencias"
	@ 21,  2 TO 101, 278 LABEL "" OF oDlg  PIXEL

	oGet := MSGetDados():New(29,6, 97,273,nOpc,"QEM030LiOk","QEM030TuOk","",.T.,aAlter,1)

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpca:=1,Iif(oGet:TudoOk(),oDlg:End(),nOpca:=0)},{||oDlg:End()})
	
	If nOpcA == 1
		Begin Transaction
			lGravaOk := M030GrvPen()
			If !lGravaOk
				Help(" ",1,"A010NAOGRV")
			Else	
				//Processa Gatilhos
				EvalTrigger()
			EndIf
		End Transaction
	EndIf 		
EndIf

dbSelectArea(cAlias)
Return nOpcA

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QEM030LiOk³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 20/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta' Ok - Getdados das Penden.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEM030													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QEM030LiOk(o)
Local lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o novo responsavel existe e nao esta demitido ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QAA->(dbSetOrder(1))
If !QAA->(dbSeek(aCols[n,13]+aCols[n,14]))	// Filial novo resp + Novo resp
	MessageDlg(STR0007,,1)	// "Responsável não cadastrado."
	lRet := .F.
Else
	If QAA->QAA_STATUS == "2"	
		MessageDlg(STR0008,,1)	// "Responsável foi demitido."
		lRet := .F.
	EndIf
EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QEM030TuOk³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 20/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se toda a getdados esta' Ok - Getdados das Penden. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEM030													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QEM030TuOk(o)
Local nI
Local lRet := .T.

For nI := 1 to Len(aCols)
	If !QEM030LiOk(o)
		lRet := .F.
		Exit
	EndIf
Next
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³M030GrvPen³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 21/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Troca os responsaveis demitidos pelos novos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEM030													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M030GrvPen()
Local nI	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava os novos responsaveis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QF2->(dbSetOrder(1))
QF3->(dbSetOrder(2))

For nI := 1 to Len(aCols)
	// Se definiu novo usuario, grava
	If !Empty(aCols[nI,13]) .And. !Empty(aCols[nI,14])
		If Left(aCols[nI,5],1) == "D"	// Destinatario
			// Localiza o destinatario da PU
			If QF3->(dbSeek(xFilial("QF3")+aCols[nI,8]+aCols[nI,9]+;
					aCols[nI,10]+Dtos(aCols[nI,11])+aCols[nI,12]+;
					aCols[nI,6]+aCols[nI,2]))
	
				While QF3->QF3_FILIAL+QF3->QF3_FORNEC+QF3->QF3_LOJFOR+;
							QF3->QF3_PRODUT+DtoS(QF3->QF3_DTENTR)+QF3->QF3_LOTE+;
							QF3->QF3_NUMERO+QF3->QF3_MAT == xFilial("QF3")+aCols[nI,8]+;
							aCols[nI,9]+aCols[nI,10]+Dtos(aCols[nI,11])+aCols[nI,12]+;
							aCols[nI,6]+aCols[nI,2] .And. !QF3->(Eof())
	
					If QF3->QF3_STATUS == "E"
						RecLock("QF3",.F.)
		   		        QF3->QF3_FILMAT	:= aCols[nI,13]
		      		    QF3->QF3_MAT	:= aCols[nI,14]
						MsUnLock()
						Exit
					EndIf
					QF3->(dbSkip())
				EndDo	
			EndIf	
	
		ElseIf Left(aCols[nI,5],1) == "U"	// Usuario Qualidade
			If QF2->(dbSeek(xFilial("QF2")+aCols[nI,8]+aCols[nI,9]+;
					aCols[nI,10]+Dtos(aCols[nI,11])+aCols[nI,12]+;
					aCols[nI,6]))
	
				RecLock("QF2",.F.)
		        QF2->QF2_FILQLD	:= aCols[nI,13]
		        QF2->QF2_MATQLD	:= aCols[nI,14]
				MsUnLock()
			EndIf	
		EndIf
	EndIf
Next nI	
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QEM030VlRe³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 21/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Responsavel                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEM030 - E' chamada no X3_VALID do cpo. QF3_MAT - SX3     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QEM030VlRe()
Local lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o novo responsavel existe e nao esta demitido ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QAA->(dbSetOrder(1))
If !QAA->(dbSeek(aCols[n,13]+M->QF3_MAT))	//Filial novo resp + Novo resp
	MessageDlg(STR0007,,1)	// "Responsável não cadastrado."
	lRet := .F.
Else
	If QAA->QAA_STATUS == "2"	
		MessageDlg(STR0008,,1)	// "Responsável foi demitido."
		lRet := .F.
	EndIf
EndIf
// Atualiza apelido do Responsavel      
If lRet   
	aCols[n,15] := QAA->QAA_APELID
EndIf
Return(lRet)

//----------------------------------------------------------------------
/*/{Protheus.doc} Q030GETSX3 
Busca dados da SX3 
@author Gustavo Della Giustina
@since 20/03/2018
@version 1.0
@return aHeaderTmp
/*/
//---------------------------------------------------------------------- 
Static Function Q030GetSX3(cCampo, cTitulo, cPicture)
Local aHeaderTmp := {}
aHeaderTmp:= {AllTrim(IIf(Empty(cTitulo), QAGetX3Tit(cCampo), cTitulo)),;
              GetSx3Cache(cCampo,'X3_CAMPO'),;
              IIF(Empty(cPicture), GetSx3Cache(cCampo,'X3_PICTURE'), cPicture),;
              GetSx3Cache(cCampo,'X3_TAMANHO'),;
              GetSx3Cache(cCampo,'X3_DECIMAL'),;
              GetSx3Cache(cCampo,'X3_VALID'),;              
              GetSx3Cache(cCampo,'X3_USADO'),;
              GetSx3Cache(cCampo,'X3_TIPO'),;
              GetSx3Cache(cCampo,'X3_ARQUIVO'),;
              GetSx3Cache(cCampo,'X3_CONTEXT')}          
Return aHeaderTmp