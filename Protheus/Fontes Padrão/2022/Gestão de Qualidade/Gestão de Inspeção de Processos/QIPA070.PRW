#include "QIPA070.CH"
#include "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ QIPA070  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 28.09.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Amarracao Prod.xCliente - Ensaio³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Sigaqip                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo Piment³03/07/01³META  ³Remodelagem da rotina podendo efetuar   ³±±
±±³              ³        ³      ³as opcoes existentes no browse.         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Static Function MenuDef()

Local aRotina := {	{STR0024	,"AxPesqui"		, 0 , 1,,.F.},; //"Pesquisar"
					{STR0025	,"QP070Manu"	, 0 , 2},; //"Visualizar"
					{STR0026	,"QP070Manu"	, 0 , 3},; //"Incluir"
					{STR0027	,"QP070Manu"	, 0 , 4},; //"Alterar"
					{STR0028	,"QP070Del"		, 0 , 5 , 3 } } //"Excluir"
					
Return aRotina

Function QIPA070()
PRIVATE cCadastro:= STR0001	//"Amarração Produto x Cliente"
PRIVATE lFase3   := ChkFile("QQ4") 
PRIVATE __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
PRIVATE lProduto   := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa 	 ³
//³ ----------- Elementos contidos por dimensao ------------	 ³
//³ 1. Nome a aparecer no cabecalho 							 ³
//³ 2. Nome da Rotina associada									 ³
//³ 3. Usado pela rotina										 ³
//³ 4. Tipo de Transa‡„o a ser efetuada							 ³
//³	 1 - Pesquisa e Posiciona em um Banco de Dados				 ³
//³	 2 - Simplesmente Mostra os Campos							 ³
//³	 3 - Inclui registros no Bancos de Dados					 ³
//³	 4 - Altera o registro corrente								 ³
//³	 5 - Remove o registro corrente do Banco de Dados			 ³
//³	 6 - Nao permite inclusao na getdados						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef()
						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama a funcao de QIPA071 que contem alterações relacionadas a Fase3			        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QIPA071()

Return NIL

Function QP070C_Top()
Return xFilial("QQ7")+"S"

Function QP070C_Bot()
Return xFilial("QQ7")+"S"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QP070Del   ³ Autor ³ Marcelo Pimentel      ³ Data ³ 03/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Exclusao da amarracao Produto x Cliente                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP070Del(cAlias,nReg,nOpc)
Local oTempTable	:= NIL
Local oDlg
Local cXMark		:= ''
Local cArqTrab	:= ''
Local aStru		:= {}
Local cChaveQQ7	:= ''
Local aCampos		:= {}
Local aButtons  	:= {}
Private oMark

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aStru,{ "TB_OK"   	,	"C",01,0} )
Aadd( aStru,{ "TB_OPER"		,	"C",TamSX3("QQK_OPERAC")[1]	,0} )
Aadd( aStru,{ "TB_CODREC"	,	"C",TamSX3("QQK_CODIGO")[1]	,0} )
Aadd( aStru,{ "TB_LABOR"	,	"C",TamSX3("QP7_LABOR")[1]	,0} )
Aadd( aStru,{ "TB_ENSAIO"	,	"C",TamSX3("QP7_ENSAIO")[1]	,0} )
Aadd( aStru,{ "TB_ENSOBR"	,	"C",TamSX3("QP7_ENSOBR")[1]	,0} )
Aadd( aStru,{ "TB_CERTIF"	,	"C",TamSX3("QP7_CERTIF")[1]	,0} )
Aadd( aStru,{ "TB_DESENS"	,	"C",TamSX3("QP1_DESCPO")[1]	,0} )
Aadd( aStru,{ "TB_CARTA"	,	"C",TamSX3("QP1_CARTA")[1]	,0} )
Aadd( aStru,{ "TB_CHAVE"	,	"C",TamSX3("QA2_CHAVE")[1]	,0} )
Aadd( aStru,{ "TB_CLIENTE"	,	"C",TamSX3("QQ7_CLIENT")[1]	,0} )
Aadd( aStru,{ "TB_PRODUTO"	,	"C",TamSX3("QQ7_PRODUT")[1]	,0} )
Aadd( aStru,{ "TB_LOJA"		,	"C",TamSX3("QQ7_LOJA")[1]	,0} )

oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aStru )
oTempTable:AddIndex("indice1", {"TB_OPER"} )
oTempTable:Create()

cXMark := GetMark()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefinicao do aCampos para utilizar no MarkBrow             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos := {	{"TB_OK"		,""," "}		,;	//"Ok"
				{"TB_ENSAIO"	,"",STR0007	}	,;	//"Ensaio"
				{"TB_DESENS"	,"",STR0008	}	,;	//"Descricao"
				{"TB_LABOR"		,"",STR0006	}	,;	//"Laboratorio"
				{"TB_CODREC"	,"",STR0002	}	,;	//"Roteiro"
				{"TB_OPER"		,"",STR0003	}	,;	//"Operacao"
				{"TB_ENSOBR"	,"",STR0004	}	,;	//"Ensaio Obrig."
				{"TB_CERTIF"	,"",STR0005	}	,;	//"Consta Certif."
				{"TB_CARTA"		,"",STR0009	} }		//"Carta"
				
nOpca := 0
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM 150,3 TO 388,613 OF oMainWnd PIXEL		//"Amarra‡Æo Produto x Cliente"
//Efetuado tratamento para que o aRotina esteja no modo alteracao, para mostrar os campos no QQ7 - Na visualizacao e Exclusao
If !INCLUI
	aRotina[nOpc][4] := 4
EndIf

RegToMemory("QQ7")
EnChoice("QQ7",nReg,nOpc,,,,, {  15,  1, 45, 304 })
oMark := MsSelect():New("TRB","TB_OK",,aCampos,,"x",{49,1,118,304})
oMark:bAval	:= {|| .T. }
oMark:oBrowse:Refresh()
oMark:oBrowse:SetFocus()
QP070Ens(QQ7->QQ7_PRODUT,QQ7->QQ7_CLIENT,QQ7->QQ7_LOJA)
VerifChav(QQ7->QQ7_PRODUT,QQ7->QQ7_CLIENT,QQ7->QQ7_LOJA,oDlg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria botao para visualizacao do Documento    	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ          
AAdd(aButtons,{"RELATORIO",{|| qp070Texto("TRB",Recno(),nOpc)},STR0019,STR0031}) //"Observacoes..."###"Observac"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nopca:=1,If(A070Ok(M->QQ7_CLIENT,M->QQ7_LOJA),oDlg:End(),nOpca:=0)},{||nopca:=0,oDlg:End()},,aButtons)

If nOpca == 1
	cChaveQQ7 := xFilial("QQ7")+M->QQ7_PRODUT+M->QQ7_CLIENT+M->QQ7_LOJA
	Begin Transaction
	dbSelectArea('QQ7')
	dbSetOrder(1)
	If dbSeek(cChaveQQ7)
		While !EOF() .And. QQ7_FILIAL+QQ7_PRODUT+QQ7_CLIENT+QQ7_LOJA==cChaveQQ7
			RecLock("QQ7")
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf
	End Transaction
EndIf

oTempTable:Delete() //-- Deleta arquivo temporario

dbSelectArea("QQ7")
dbGoTop()
dbSetOrder(4)
dbGoto(nReg)
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QP070Manu  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 28/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Tela de manutencao Amarracao Produto x Cliente :INC/ALT/VIS  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP070Manu(cAlias,nReg,nOpc)
Local oDlg
Local cXMark		:= ''
Local aStru			:={}
Local aCampos		:={}
Local aButtons		:={}
Local oEnchoice
Local oTmpTable := Nil

Private cChave		:=''
Private oMark

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aStru,{ "TB_OK"   	,	"C",01,0} )
Aadd( aStru,{ "TB_OPER"		,	"C",TamSX3("QQK_OPERAC")[1]	,0} )
Aadd( aStru,{ "TB_CODREC"	,	"C",TamSX3("QQK_CODIGO")[1]	,0} )
Aadd( aStru,{ "TB_LABOR"	,	"C",TamSX3("QP7_LABOR")[1]	,0} )
Aadd( aStru,{ "TB_ENSAIO"	,	"C",TamSX3("QP7_ENSAIO")[1]	,0} )
Aadd( aStru,{ "TB_ENSOBR"	,	"C",TamSX3("QP7_ENSOBR")[1]	,0} )
Aadd( aStru,{ "TB_CERTIF"	,	"C",TamSX3("QP7_CERTIF")[1]	,0} )
Aadd( aStru,{ "TB_DESENS"	,	"C",TamSX3("QP1_DESCPO")[1]	,0} )
Aadd( aStru,{ "TB_CARTA"	,	"C",TamSX3("QP1_CARTA")[1]	,0} )
Aadd( aStru,{ "TB_CHAVE"	,	"C",TamSX3("QA2_CHAVE")[1]	,0} )
Aadd( aStru,{ "TB_CLIENTE"	,	"C",TamSX3("QQ7_CLIENT")[1]	,0} )
Aadd( aStru,{ "TB_PRODUTO"	,	"C",TamSX3("QQ7_PRODUT")[1]	,0} )
Aadd( aStru,{ "TB_LOJA"		,	"C",TamSX3("QQ7_LOJA")[1]	,0} )

oTmpTable := FWTemporaryTable():New( "TRB" )
oTmpTable:SetFields(aStru)
oTmpTable:Create()
DbSelectArea("TRB")

cXMark := GetMark()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefinicao do aCampos para utilizar no MarkBrow             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos := {	{"TB_OK"		,""," "}		,;	//"Ok"
				{"TB_ENSAIO"	,"",STR0007	}	,;	//"Ensaio"
				{"TB_DESENS"	,"",STR0008	}	,;	//"Descricao"
				{"TB_LABOR"		,"",STR0006	}	,;	//"Laboratorio"
				{"TB_CODREC"	,"",STR0002	}	,;	//"Roteiro"
				{"TB_OPER"		,"",STR0003	}	,;	//"Operacao"
				{"TB_ENSOBR"	,"",STR0004	}	,;	//"Ensaio Obrig."
				{"TB_CERTIF"	,"",STR0005	}	,;	//"Consta Certif."
				{"TB_CARTA"		,"",STR0009	} }		//"Carta"
				
nOpca := 0
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM 150,3 TO 388,613 OF oMainWnd PIXEL		//"Amarra‡Æo Produto x Cliente"
//Efetuado tratamento para que o aRotina esteja no modo alteracao, para mostrar os campos no QQ7 - Na visualizacao e Exclusao
If !INCLUI
	aRotina[nOpc][4] := 4
EndIf
RegToMemory("QQ7",(INCLUI))
oEnchoice := Msmget():New("QQ7",nReg,nOpc,,,,, {  15,  1, 45, 304 })

oMark := MsSelect():New("TRB","TB_OK",,aCampos,,"x",{49,1,118,304})

If nOpc == 3 .Or. nOpc == 4
	oMark:oBrowse:bAllMark	:= {| | QP070MkAll(oDlg,nOpc)}
Else
	oMark:bAval				:= {|| .T. }
EndIf
oMark:oBrowse:Refresh()
oMark:oBrowse:SetFocus()

If !INCLUI
	QP070Ens(QQ7->QQ7_PRODUT,QQ7->QQ7_CLIENT,QQ7->QQ7_LOJA)
	VerifChav(QQ7->QQ7_PRODUT,QQ7->QQ7_CLIENT,QQ7->QQ7_LOJA,oDlg)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria botao para Observacao                   	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aButtons,{"RELATORIO",{|| qp070Texto("TRB",Recno(),nOpc)},STR0019,STR0031}) //"Observacoes..."###"Observac"

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{||nopca:=1,If(A070Ok(M->QQ7_CLIENT,M->QQ7_LOJA),oDlg:End(),nOpca:=0)},{||nopca:=0,oDlg:End()},,aButtons),;
								AlignObject(oDlg,{oEnchoice:oBox,oMark:oBrowse},1,,{60}))

If nOpca == 1
	Begin Transaction
		a070Grava(M->QQ7_PRODUT,M->QQ7_CLIENT,M->QQ7_LOJA)
	End Transaction
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta Arquivo Temporario                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
dbCloseArea()
oTmpTable:Delete()

dbSelectArea("QQ7")
dbGoTop()
dbSetOrder(4)
dbGoto(nReg)
Return(.T.)
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QP070MkAll ³ Autor ³Marcelo Pimentel     ³ Data ³ 19/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inverte Marcadas/Desmarcadas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIPA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP070MkAll(oDlg,nOpcao)
Local nRecno:= Recno()
dbGotop()
While !Eof()
	RecLock("TRB",.F.)
	If Empty(TRB->TB_OK)
		Replace TRB->TB_OK With "x"
	Else
		Replace TRB->TB_OK With " "
	Endif
	MsUnlock()
	dbSkip()
EndDo
dbGoto(nRecno)
oDlg:Refresh()
Return .T.
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A070Grava³ Autor ³ Marcelo Pimentel      ³ Data ³ 30/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava a amarra‡Æo dos produtos x Clientes dos ensaios      ³±±
±±³          ³ Selecionados.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIPA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A070Grava()
Local nC		:= 0
Local nX		:= 0
Local aCpos		:= {}
Local aStructQQ7 := FWFormStruct(3,"QQ7")[3]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica campos do usuario      		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aStructQQ7)
	If GetSx3Cache(aStruct[nX,1],"X3_PROPRI") == "U"
		Aadd(aCpos, GetSx3Cache(aStruct[nX,1],"X3_CAMPO"))
	EndIf
Next  

dbSelectArea("TRB")
dbGoTop()
While !Eof()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ja existe o registro.                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QQ7->(dbSetOrder(1))
	If QQ7->(dbSeek(xFilial("QQ7")+M->QQ7_PRODUT+M->QQ7_CLIENT+M->QQ7_LOJA+TRB->TB_LABOR+;
		TRB->TB_ENSAIO+TRB->TB_CODREC+TRB->TB_OPER))
		RecLock("QQ7",.F.)
		QQ7->(dbDelete())
		MsUnlock()
	EndIf

	If Empty(TRB->TB_OK)
		dbSelectArea("TRB")
		dbSkip()
		Loop
	EndIf
	
	dbSelectArea("QQ7")
	RecLock("QQ7",.T.)
	QQ7->QQ7_FILIAL		:=	xFilial("QQ7")
	QQ7->QQ7_PRODUT		:= M->QQ7_PRODUT
	QQ7->QQ7_CLIENT		:= M->QQ7_CLIENT
	QQ7->QQ7_LOJA		:= M->QQ7_LOJA
	QQ7->QQ7_LABOR		:= TRB->TB_LABOR
	QQ7->QQ7_ENSAIO		:= TRB->TB_ENSAIO
	QQ7->QQ7_OPERAC		:= TRB->TB_OPER
	QQ7->QQ7_CODREC 	:= TRB->TB_CODREC
	QQ7->QQ7_CHAVE		:= TRB->TB_CHAVE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a gravacao de campos de usuario        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nC := 1 To Len(aCpos)
		FieldPut(FieldPos(aCpos[nC]),M->&(aCpos[nC]))
	Next nC

	MsUnlock()
	dbSelectArea("TRB")
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava "S" no campo MBROWS do QQ7 para mostrar na MBrowse ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QP070Mbrow(xFilial("QQ7") + M->QQ7_PRODUT + M->QQ7_CLIENT + M->QQ7_LOJA)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ A070OK   ³ Autor ³ Marcelo Pimentel      ³ Data ³02.10.98  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Verifica se o cliente e a loja foram informados antes de   ³±±
±±³          ³ executar a grava‡Æo.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Qipa070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A070OK(cCli,cLoj)
Local lRet := .T.
If Empty(cCli) .Or. Empty(cLoj)
	Help(" ",1,"QA_CPOOBR")
	lRet := .F.
EndIf
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ VerifChav³ Autor ³ Marcelo Pimentel      ³ Data ³02.10.98  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Verifica se existe a amarra‡Æo Prod x Cliente              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Qipa070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VerifChav(cProd,cCliente,cLoja,oDlg)
Local cChave	:= '', nRecno := 0
dbGotop()
While !Eof()
	RecLock("TRB",.F.)
	TRB->TB_OK 			:=" "
	TRB->TB_CLIENTE		:=cCliente
	TRB->TB_LOJA		:=cLoja
	TRB->TB_PRODUTO		:=cProd
	MsUnlock()
	dbSkip()
EndDo

cChave	:= xFilial("QQ7")+cProd+cCliente+cLoja
dbSelectArea("QQ7")
dbSetOrder(1)
nRecno := Recno()
If dbSeek(cChave)
	While !Eof() .And. cChave == QQ7->QQ7_FILIAL+QQ7->QQ7_PRODUT+QQ7->QQ7_CLIENT+QQ7->QQ7_LOJA
		dbSelectArea("TRB")
		dbGoTop()
		While !Eof()
			If QQ7->QQ7_CODREC+QQ7->QQ7_OPERAC+QQ7->QQ7_LABOR+QQ7->QQ7_ENSAIO == ;
				TRB->TB_CODREC+TRB->TB_OPER+TRB->TB_LABOR+TRB->TB_ENSAIO
				RecLock("TRB",.F.)
				TRB->TB_OK	:="x"
				MsUnlock()
			EndIf
			RecLock("TRB",.F.)
			TRB->TB_CHAVE	:= QQ7->QQ7_CHAVE
			MsUnlock()
			dbSkip()
		EndDo
		dbSelectArea("QQ7")
		dbSkip()
	EndDo
EndIf
DbGoto(nRecno)
oDlg:Refresh()
dbSelectArea("TRB")
dbGoTop()
Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qp070Texto³ Autor ³ Marcelo Pimentel      ³ Data ³ 09.03.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastra Texto do Produto            					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ qp070Texto(ExpC1,ExpN1,ExpN2)	                   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo									  ³±±
±±³			 ³ ExpN1 = Numero do registro 								  ³±±
±±³			 ³ ExpN2 = Opcao selecionada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function qp070Texto(cAlias,nReg,nOpc)
Local cChave	:=""
Local cCabec	:=""
Local cTitulo	:= OemtoAnsi(STR0021)		//"Produto"
Local nTamLin	:= TamSX3("QA2_TEXTO")[1]
Local cEspecie	:= "QIPA070 "				//Para gravacao de textos
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso seja Delecao ou Visualizacao a Observacao nao serah alteravel	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lEditObs	:= Iif(nOpc==2.Or.nOpc==5,.F.,.T.)	//Caso seja 
Local lRetTex   := .t.

axtextos := {}								//Vetor que contem os textos dos Produtos
cCabec	:= OemtoAnsi(STR0022)				//"Texto do Produto"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera/obtem a chave de ligacao com o texto do Produto/Rv  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
If Empty(TRB->TB_CHAVE)
	cChave := QA_CvKey(xFilial("QQ7")+M->QQ7_PRODUT+M->QQ7_CLIENT+M->QQ7_LOJA,"QQ7", 1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua a gravacao da chave em todo a arquivo tempor rio  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	a070grvChv(cChave)
Else
	cChave := TRB->TB_CHAVE
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Digita o Texto do Produto    							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRetTex := QA_TEXTO(cChave,cEspecie,nTamlin,cTitulo,STR0021+": "+AllTrim(M->QQ7_PRODUT)+"  - "+STR0023+M->QQ7_CLIENT+"-"+M->QQ7_LOJA,@axtextos,1,cCabec,lEditObs)		//"Produto"###"Cliente : "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava Texto do Produto no QA2							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetTex
	QA_GrvTxt(cChave,cEspecie,1,@axtextos)
EndIf
dbselectArea("TRB")
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³a070GrvChv³ Autor ³ Marcelo Pimentel      ³ Data ³02.10.98  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Efetua a gravacao da chave observacao no arquivo temporario³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Qipa070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function a070GrvChv(cChave)
LOCAL nRecno	:= 0
dbSelectArea("TRB")
nRecno	:=Recno()
dbGotop()
While !Eof()
	RecLock("TRB",.F.)
	TRB->TB_CHAVE	:= cChave
	MsUnlock()
	dbSkip()
EndDo
dbGoto(nRecno)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³QP070Ens  ³ Autor ³ Marcelo Pimentel      ³ Data ³02.10.98  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Carrega o arquivo temporario sobre os ensaios               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Qipa070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP070Ens(cProdut,cCliente,cLoja)
Local aARea	:= GetArea()
Local lRet  := .T.
Local cRevi := QA_UltRevEsp(cProdut,dDataBase,,,"QIP") 
				

If !Empty(cCliente) .Or. !Empty(cLoja)
	If ReadVar() = "M->QQ7_CLIENT" .And. Empty(cLoja)
		lRet := ExistCpo("SA1", cCliente)
	Else
		lRet := ExistCpo("SA1", cCliente + cLoja)
	Endif
Endif
If lRet .And. !Empty(cProdut) .And. !Empty(cCliente) .And. !Empty(cLoja)
	If Inclui
		QQ7->(dbSetOrder(1))
		If QQ7->(dbSeek(xFilial("QQ7")+cProdut+cCliente+cLoja))
			Help(" ",1,"QP070TCHV")	//Existe amarracao Produto x Cliente ja cadastrada.
			lRet := .F.
		EndIf
	EndIf
	
	If lRet .And. (ReadVar() = "M->QQ7_PRODUT" .Or. TRB->(LastRec()) = 0)
		If TRB->(LastRec())	 > 0
			TRB->(__DbZap())
		Endif
		QP7->(dbSeek(xFilial("QP7")+cProdut+cRevi))
		While !QP7->(Eof()) .And.QP7->QP7_FILIAL+QP7->QP7_PRODUT+QP7->QP7_REVI ==	xFilial("QP7")+cProdut+cRevi
			QP1->(dbSeek(xFilial("QP1")+QP7->QP7_ENSAIO))
			dbSelectArea("TRB")
			RecLock("TRB",.T.)
			TB_LABOR	:=QP7->QP7_LABOR
			TB_CODREC	:=QP7->QP7_CODREC
			TB_OPER		:=QP7->QP7_OPERAC
			TB_ENSAIO	:=QP7->QP7_ENSAIO
			TB_ENSOBR	:=Iif(QP7->QP7_ENSOBR=='S',STR0029,STR0030) //'Sim'###'Nao'
			TB_CERTIF   :=Iif(QP7->QP7_CERTIF=='S',STR0029,STR0030) //'Sim'###'Nao'
			TB_DESENS   :=QP1->QP1_DESCPO
			TB_CARTA	:=QP1->QP1_CARTA
			TB_FORMUL	:=QP7->QP7_FORMUL
			MsUnLock()
			QP7->(dbSkip())
		EndDo
		QP8->(dbSeek(xFilial("QP8")+cProdut+cRevi))
		While !QP8->(Eof()) .And. QP8->QP8_FILIAL+QP8->QP8_PRODUTO+QP8->QP8_REVI ==xFilial("QP8")+cProdut+cRevi
			QP1->(dbSeek(xFilial("QP1")+QP8->QP8_ENSAIO))
			dbSelectArea("TRB")
			RecLock("TRB",.T.)
			TB_LABOR	:=	QP8->QP8_LABOR
			TB_CODREC	:=	QP8->QP8_CODREC
			TB_OPER		:=	QP8->QP8_OPERAC
			TB_ENSAIO	:=	QP8->QP8_ENSAIO
			TB_ENSOBR	:=	Iif(QP8->QP8_ENSOBR=='S',STR0029,STR0030) //'Sim'###'Nao'
			TB_CERTIF	:=	Iif(QP8->QP8_CERTIF=='S',STR0029,STR0030) //'Sim'###'Nao'
			TB_DESENS	:=	QP1->QP1_DESCPO
			TB_CARTA	:=	QP1->QP1_CARTA
			MsUnLock()
			QP8->(dbSkip())
		EndDo
		
		dbSelectArea("TRB")
		dbGoTop()
		If BOF() .And. EOF()
			HELP(" ",1,"QP070NTENS")	//Nao existe especificacao de produtos cadastrado.
		EndIf
		oMark:oBrowse:Refresh()
		oMark:oBrowse:SetFocus()
	EndIf
EndIf
RestArea(aArea)
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QP070Mbrow³ Autor ³ Marcelo Pimentel      ³ Data ³04/6/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao que define qual sera o registro que contem "S" para  ³±±
±±³			 ³que na tela Mbrowse do Cadastro Amarracao Produto x Cliente ³±±
±±³			 ³mostrando somente o 1o. registro para melhor visualizacao.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³1 - <ExpC1> - Registro para pesquisa no QQ7				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Qipa070.prw												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QP070Mbrow( cChave )
Local aArea 	:= GetArea()
Local lFirst	:= .F.
Default cChave := ""

dbSelectArea("QQ7")
dbSetOrder(1)
If Empty(cChave)
	dbGoTop()
	cChave := QQ7_FILIAL+QQ7_PRODUT+QQ7_CLIENT+QQ7_LOJA
EndIf
If dbSeek( cChave )
	While !Eof() .And. cChave ==	QQ7->QQ7_FILIAL+QQ7->QQ7_PRODUT+QQ7->QQ7_CLIENT+QQ7->QQ7_LOJA
		If !lFirst
			cConteudo := "S"
			lFirst := .T.
		Else
			cConteudo := " "
		EndIf
		RecLock("QQ7",.F.)
		QQ7->QQ7_MBROWS := cConteudo
		MsUnLock()
		dbSkip()
	EndDo
Endif
RestArea(aArea)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³QP070Chv  ³ Autor ³ Marcelo Pimentel      ³ Data ³04.06.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Validacao dos campos chave                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Qipa070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP070Chv()
Local lRet := .T.
If !Empty(M->QQ7_PRODUT) .and. !Empty(M->QQ7_CLIENT) .and. !Empty(M->QQ7_LOJA)
   dbSelectArea("QQ7")
   dbSetOrder(1)
   If dbSeek( xFilial() + M->QQ7_PRODUT + M->QQ7_CLIENT + M->QQ7_LOJA )
      Help( " ", 1, "JAGRAVADO" )
      lRet := .F.
   Endif
EndIf
Return(lRet)
