#INCLUDE "QPPA330.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA330  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 05.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Checklist Material a Granel                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA330(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PPAP                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui"  , 0, 1,,.F.},; 	//"Pesquisar"
					{ OemToAnsi(STR0002), "PPA330Roti", 0, 2},; 		//"Visualizar"
					{ OemToAnsi(STR0003), "PPA330Roti", 0, 3},; 		//"Incluir"
					{ OemToAnsi(STR0004), "PPA330Roti", 0, 4},; 		//"Alterar"
					{ OemToAnsi(STR0005), "PPA330Roti", 0, 5},; 		//"Excluir"
					{ OemToAnsi(STR0035), "QPPR330(.T.)", 0, 6,,.T.} }	//"Imprimir"

Return aRotina

Function QPPA330()

Private cFiltro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0006) //"Checklist Material a Granel"

Private aRotina := MenuDef()

DbSelectArea("QKY")
DbSetOrder(1)

cFiltro := 'QKY_NQST == "01"'

Set Filter To &cFiltro
mBrowse( 6, 1, 22, 75,"QKY",,,,,,)
Set Filter To

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA330Roti  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³05.07.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Manutencao dos Dados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA330Incl(ExpC1,ExpN1,ExpN2)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                     ³±±
±±³          ³ ExpN1 = Numero do registro                                   ³±±
±±³          ³ ExpN2 = Numero da opcao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPPA330                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PPA330Roti(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local lOk 			:= .F.
Local aCposVis		:= {}
Local aCposAlt		:= {}
Local aButtons		:= {}
Local nCont

Private aHeader		:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL

aCposVis := { 	"QKY_PECA", "QKY_REV", "QKY_RESP1", "QKY_CIACD1",;
				"QKY_RESP2", "QKY_CIACD2", "QKY_RESP3", "QKY_CIACD3" }

aCposAlt := aClone(aCposVis)

If nOpc == 2 .or. nOpc == 5
	aButtons := {{ "BMPVISUAL", { || QPPR330()}, OemToAnsi(STR0007), OemToAnsi(STR0036) }} //"Visualizar/Imprimir"###"Vis/Prn"
Endif

If nOpc == 4
	If !QPPVldAlt(QKY->QKY_PECA,QKY->QKY_REV)
		Return
	Endif
Endif

DbSelectArea(cAlias)

Set Filter To

RegToMemory("QKY",(nOpc == 3))

A330aHead(cAlias)
A330aCols(nOpc)


DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ;  //"Checklist Material a Granel"
						FROM 120,000 TO 516,780 OF oMainWnd PIXEL
				
Enchoice("QKY",nReg,nOpc, , , ,aCposVis ,{30,03,95,390}, aCposAlt, , , ,)

oGet := MSGetDados():New(97,02,198,390, nOpc,"AllwaysTrue","AllwaysTrue","+QKY_NQST",.T.,,,,27)


// Procedimento criado para deixar itens topicos com cor diferenciada.
For nCont := 1 To Len(aCols)
	If StrZero(nCont,2)$"01_13_21_24"
		aCols[nCont,nUsado+1]		:= .T.
	Else
		aCols[nCont,nUsado+1]		:= .F.
	Endif
Next nCont

oGet:oBrowse:bDelOk := {||Iif(	aCols[n,Len(aCols[n])]			,;
								aCols[n,Len(aCols[n])]:=.F.	,;
								aCols[n,Len(aCols[n])]:=.T. ),;
								oGet:oBrowse:Refresh()} // block que impede a delecao
                        

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP330TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, ,aButtons ) CENTERED

If lOk .and. (nOpc == 3 .or. nOpc == 4)
	PPA330Grav(nOpc)
Endif

If nOpc == 5 .and. lOk
	A330Dele()
Endif

Set Filter To &cFiltro

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA330Grav³ Autor ³ Robson Ramiro A Olivei³ Data ³ 05.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Gravacao Chklist Material a Granel-Incl./Alter.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA330Grav(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA330                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA330Grav(nOpc)

Local nIt
Local nNumItem
Local nPosDel		:= Len(aHeader) + 1
Local lGraOk		:= .T.
Local nCPO

DbSelectArea("QKY")
DbSetOrder(1)
	
Begin Transaction

nNumItem := 1  // Contador para os Itens
	
For nIt := 1 To Len(aCols)
	
	If ALTERA
		If DbSeek(xFilial("QKY")+ M->QKY_PECA + M->QKY_REV + StrZero(nIt,2))
			RecLock("QKY",.F.)
		Else
			RecLock("QKY",.T.)
		Endif
	Else	                   
		RecLock("QKY",.T.)
	Endif

	If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado
	
		For nCpo := 1 To Len(aHeader)
			If aHeader[nCpo, 10] <> "V"
  				QKY->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
			Endif
		Next nCpo
                                                                              
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle de itens do acols / Chave invertida / Filial dos responsaveis ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QKY->QKY_NQST	:= StrZero(nNumItem,2)
		QKY->QKY_REVINV	:= Inverte(M->QKY_REV)
		QKY->QKY_FILRES	:= cFilAnt


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados da Enchoice                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QKY->QKY_FILIAL		:= xFilial("QKY")
		QKY->QKY_PECA   	:= M->QKY_PECA
		QKY->QKY_REV    	:= M->QKY_REV     
		QKY->QKY_RESP1		:= M->QKY_RESP1
		QKY->QKY_CIACD1		:= M->QKY_CIACD1
		QKY->QKY_RESP2		:= M->QKY_RESP2
		QKY->QKY_CIACD2		:= M->QKY_CIACD2
		QKY->QKY_RESP3		:= M->QKY_RESP3
		QKY->QKY_CIACD3		:= M->QKY_CIACD3

		nNumItem++	
	
		MsUnLock()
	Else
		QKY->QKY_FILIAL	:= xFilial("QKY")
		QKY->QKY_PECA 	:= M->QKY_PECA
		QKY->QKY_REV	:= M->QKY_REV
		QKY->QKY_NQST	:= StrZero(nNumItem,2)
		QKY->QKY_REVINV	:= Inverte(M->QKY_REV)
		QKY->QKY_RESP1	:= M->QKY_RESP1
		QKY->QKY_CIACD1	:= M->QKY_CIACD1
		QKY->QKY_RESP2	:= M->QKY_RESP2
		QKY->QKY_CIACD2	:= M->QKY_CIACD2
		QKY->QKY_RESP3	:= M->QKY_RESP3
		QKY->QKY_CIACD3	:= M->QKY_CIACD3
		QKY->QKY_FILRES	:= cFilAnt

		nNumItem++
		MsUnLock()
	Endif
	
Next nIt

End Transaction
				
DbSelectArea("QKY")
DbSetOrder(1)
		
Return lGraOk

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PP330TudOk ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 05.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para inclusao/alteracao geral                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP330TudOk                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPPA330                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PP330TudOk

Local lRetorno	:= .T.

If Empty(M->QKY_PECA) .or. Empty(M->QKY_REV)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
Endif

If INCLUI
	If !ExistChav("QKY",M->QKY_PECA+M->QKY_REV)
		lRetorno := .F.
		Help(" ",1,"JAGRAVADO")  // Campo ja Existe
	Endif
	If !ExistCpo("QK1",M->QKY_PECA+M->QKY_REV)
		lRetorno := .F.
		Help(" ",1,"REGNOIS")  // Nao existe amarracao
	Endif
Endif

Return lRetorno


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A330Dele ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 05.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fucao para exclusao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A330Dele()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA330                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A330Dele()

Local nRec
Local aArqRec := {}

DbSelectArea("QKY")
DbSeek(xFilial("QKY")+M->QKY_PECA+M->QKY_REV+"01")

Do While xFilial("QKY")+M->QKY_PECA+M->QKY_REV == QKY->QKY_FILIAL+QKY->QKY_PECA+QKY->QKY_REV ;
			.and. !Eof()

	aAdd(aArqRec, Recno())  //alimenta array com os enderecos a serem deletados
	DbSkip()
Enddo

Begin Transaction

If Len(aArqRec) > 0

	For nRec := 1 To Len(aArqRec)  // 27 Itens
 
		DbSelectArea("QKY")
		DbGoTo(aArqRec[nRec])
		RecLock("QKY",.F.)
		DbDelete()

	Next nRec

Endif

MsUnLock()
		
End Transaction

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A330Acols³ Autor ³ Robson Ramiro A. Olive³ Data ³ 08.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega vetor aCols para a GetDados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A150Acols()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA330                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A330Acols(nOpc)

Local nI, nJ, nPosNQST, nPosREQUIS
Local aArea 	:= GetArea()
Local aRequis	:= {}

aRequis := { 	STR0008,; //"VERIFICACAO DE PROJETO E DESENVOLVIMENTO DE PRODUTO"
				STR0009,; //"Matriz de Projeto"
				STR0010,; //"FMEA de Projeto"
				STR0011,; //"Caracteristicas Especiais do Produto"
				STR0012,; //"Registros de Projeto"
				STR0013,; //"Plano de Controle de Prototipo"
				STR0014,; //"Relatorio de Aprovacao de Aparencia"
				STR0015,; //"Amostras Padrao"
				STR0016,; //"Resultados dos Ensaios"
				STR0017,; //"Resultados Dimensionais"
				STR0018,; //"Auxiliares de Verificacao"
				STR0019,; //"Aprovacao de Engenharia"
				STR0020,; //"VERIFICACAO DE PROJETO E DESENVOLVIMENTO DE PROCESSO"
				STR0021,; //"Diagramas de Fluxo de Processo"
				STR0022,; //"FMEA de Processo"
				STR0023,; //"Caracteristicas Especiais de Processo"
				STR0024,; //"Plano de Controle de Pre-Lancamento "
				STR0025,; //"Plano de Controle de Producao"
				STR0026,; //"Estudos de Sistemas de Medicao"
				STR0027,; //"Aprovacao Interina"
				STR0028,; //"VALIDACAO DE PROCESSO E PRODUTO"
				STR0029,; //"Estudos Iniciais de Processo"
				STR0030,; //"Submissao do Certificado de Aprovacao da Peca (CFG-1001)"
				STR0031,; //"ELEMENTOS A SEREM COMPLETADOS QUANDO NECESSARIO"
				STR0032,; //"Contato no Local de Producao do Cliente"
				STR0033,; //"Alteracao de Documentacao"
				STR0034 } //"Consideracoes do Subcontratado"
							

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols               					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpc == 3

	aCols := Array(1,nUsado+1)

	For nI := 1 To Len(aHeader)
		If aHeader[nI,8] == "C"
			aCols[1,nI] := Space(aHeader[nI,4])
		ElseIf aHeader[nI,8] == "N"
			aCols[1,nI] := 0
		ElseIf aHeader[nI,8] == "D"
			aCols[1,nI] := dDataBase
		ElseIf aHeader[nI,8] == "M"
			aCols[1,nI] := ""
		Else
			aCols[1,nI] := .F.
		EndIf
	Next nI

	nPosNQST			:= aScan(aHeader,{ |x| AllTrim(x[2])== "QKY_NQST" 	})
	nPosREQUIS			:= aScan(aHeader,{ |x| AllTrim(x[2])== "QKY_REQUIS"	})

	aCols[1,nPosNQST]	:= StrZero(1,Len(aCols[1,nPosNQST]))
	aCols[1,nPosREQUIS]	:= aRequis[1]
	aCols[1,nUsado+1] 	:= .F.

	For nI := 2 To 27 // 27 perguntas
		aAdd(aCols,Array(nUsado+1))

		For nJ := 1 To Len(aHeader)
			If aHeader[nJ,8] == "C"
				aCols[Len(aCols),nJ] := Space(aHeader[nJ,4])
			Elseif aHeader[nJ,8] == "N"
				aCols[Len(aCols),nJ] := 0
			Elseif aHeader[nJ,8] == "D"
				aCols[Len(aCols),nJ] := CtoD(" / / ")
			Elseif aHeader[nJ,8] == "M"
				aCols[Len(aCols),nJ] := ""
			Else
				aCols[Len(aCols),nJ] := .F.
			EndIf
		Next nJ

		aCols[nI,nPosNQST]		:= StrZero(nI,Len(aCols[1,nPosNQST]))
		aCols[nI,nPosREQUIS]	:= aRequis[nI]
		aCols[nI,nUsado+1]		:= .F.
				
	Next nI

Else

	DbSelectArea("QKY")
	DbSetOrder(1)
	DbSeek(xFilial()+M->QKY_PECA+M->QKY_REV)

	Do While QKY->(!Eof()) .and. xFilial() == QKY->QKY_FILIAL .and.;
				QKY->QKY_PECA+QKY->QKY_REV == M->QKY_PECA+M->QKY_REV
			 	
		aAdd(aCols,Array(nUsado+1))
	
		For nI := 1 to nUsado
   	
			If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
				aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
			Else										// Campo Virtual
				cCpo := AllTrim(Upper(aHeader[nI,2]))
				aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
  			Endif
 			
		Next nI

		nPosREQUIS := aScan(aHeader,{ |x| AllTrim(x[2])== "QKY_REQUIS" })

		aCols[Len(aCols),nPosREQUIS] 	:= aRequis[Len(aCols)]
		aCols[Len(aCols),nUsado+1]		:= .F.

		DbSkip()

	Enddo
		
Endif

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A330Ahead³ Autor ³ Robson Ramiro A. Olive³ Data ³ 08.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Ahead para aCols                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A150Ahead()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA330                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A330Ahead(cAlias)

Local aArea := GetArea()
Local aStruAlias := FWFormStruct(3, cAlias)[3]
Local nX

aHeader := {}
nUsado 	:= 0

For nX := 1 To Len(aStruAlias)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ignora campos que nao devem aparecer na getdados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  Upper(AllTrim(aStruAlias[nX,1])) == "QKY_PECA" 	.or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKY_REV" 	.or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKY_RESP".or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKY_CIACD"
		Loop
	Endif
	
	If cNivel >= GetSX3Cache(aStruAlias[nX,1],"X3_NIVEL")
		nUsado++
 		aAdd(aHeader,{ Trim(QAGetX3Tit(aStruAlias[nX,1])),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_CAMPO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_PICTURE'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_TAMANHO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_DECIMAL'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_VALID'),;              
		              GetSx3Cache(aStruAlias[nX,1],'X3_USADO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_TIPO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_ARQUIVO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_CONTEXT')})
	Endif	
Next nX 

RestArea(aArea)

Return