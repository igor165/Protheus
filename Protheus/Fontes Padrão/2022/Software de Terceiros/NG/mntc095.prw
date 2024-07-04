#INCLUDE	"Protheus.ch"
#INCLUDE	"MsGraphi.ch"

#DEFINE _nVERSAO 1 //Versao do fonte
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MNTC095   �Autor  �Wagner S. de Lacerda� Data �  12/09/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � Consulta de Variacao dos Contadores.                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Tabelas   � ST9 - Bem                                                  ���
���          � STP - Ordens de Servico de Acompanhamento (Contador 1)     ���
���          � TPP - Ordens de Servico de Acompanhamento (Contador 2)     ���
�������������������������������������������������������������������������͹��
���Parametros� cParCodBem -> Opcional;                                    ���
���          �               Indica o Codigo do Bem para a consulta.      ���
���          �               Default: Codigo do Bem atual (a partir do    ���
���          �                        registro posicionado atualmente na  ���
���          �                        tabela ST9)                         ���
���          � cParCodFil -> Opcional;                                    ���
���          �               Indica o Codigo da Filial para a consulta.   ���
���          �               Default: xFilial("ST9")                      ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAMNT                                                    ���
�������������������������������������������������������������������������͹��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������͹��
���Programador �   Data     � Descricao                                   ���
�������������������������������������������������������������������������͹��
���            � xx/xx/xxxx �                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MNTC095(cParCodBem, cParCodFil)

//�����������������������������������������������������������������������Ŀ
//� Armazena variaveis p/ devolucao (NGRIGHTCLICK)                        �
//�������������������������������������������������������������������������
Local aNGBEGINPRM := NGBEGINPRM(_nVersao)

Local aTempColor := aClone( NGCOLOR() )

Local cOldCadast := If(Type("cCadastro") == "C",cCadastro,"")
Local lOldINCLUI := If(Type("INCLUI") == "L",INCLUI,.F.)
Local lOldALTERA := If(Type("ALTERA") == "L",ALTERA,.F.)

Default cParCodBem := ""
Default cParCodFil := ""

/* Variaveis da Tela */
Private oDlgVar, oPnlVar, aBtnDlgVar
Private oObjVar
Private oPnlCabec, oPnlMenu, oPnlGrafic

Private oBtnPeriod
Private oGraphic, nSerie1, nSerie2

Private oFontVar := TFont():New(, , 16, .T., .T.)
Private nCorVarF := CLR_BLACK
Private nCorVarB := CLR_WHITE
/**/

/* Variaveis Padroes da Rotina */
Private cVerCodBem := "", cVerNomBem := ""
Private cVerCodFil := ""

Private aContador1 := {}, aPeriodo1 := {}, aVariacao1 := {}
Private aContador2 := {}, aPeriodo2 := {}, aVariacao2 := {}
Private lContador1 := .F.
Private lContador2 := .F.

Private dDeData   := CTOD("")
Private dAteData  := CTOD("")
Private lTodoHist := .F.
Private oCbxCont, aCbxCont, cCbxCont
Private nTipPeriod := 0 //Visualizacao da Variacao

Private aSize    := MsAdvSize()
Private nLargura := 0
Private nAltura  := 0
/**/

/* Variaveis da Imagem */
Private cImgExtens := "BMP"
Private cImgSave   := "MNTC095."+cImgExtens

Private cSrvBarra := If(IsSrvUnix(),"/","\")
Private cMV_Path  := Alltrim( SuperGetMV("MV_DIRACA",.F.,cSrvBarra+CurDir()) )// Path do arquivo logo .bmp do cliente
/**/

//Define Altura e Largura
If !(Alltrim(GetTheme()) == "FLAT") .And. !SetMdiChild()
	aSize[7] -= 50
	aSize[6] -= 30
ElseIf SetMdiChild()
	aSize[5] -= 03
EndIf
nAltura  := aSize[6]
nLargura := aSize[5]

INCLUI := .F.
ALTERA := .F.

//Define a Barra do Caminho da Imagem
If SubStr(cMV_Path,Len(cMV_Path)) <> cSrvBarra
	cMV_Path += cSrvBarra
EndIf

//Inicio funcional da Consulta
cCadastro := OemToAnsi("Consulta de Varia��o de Contadores")

dbSelectArea("ST9")
cVerCodBem := If(!Empty(cParCodBem), PADR(cParCodBem,TAMSX3("T9_CODBEM")[1]," "), ST9->T9_CODBEM)
cVerCodFil := If(!Empty(cParCodFil), cParCodFil, xFilial("ST9"))

//�����������������������������Ŀ
//� Valida o Bem                �
//�������������������������������
If !fValidaBem()
	fExit(cOldCadast, lOldINCLUI, lOldALTERA, aNGBEGINPRM)
	Return .F.
EndIf

//�����������������������������Ŀ
//� Busca os Contadores do Bem  �
//�������������������������������
dAteData := dDataBase //Data Atual
dDeData  := dAteData - (30 * 6) //Data Atual - 6 Meses

aCbxCont := {}
If lContador1 .Or. lContador2 //O primeiro contador DEVE estar disponivel caso haja o segundo contador
	aAdd(aCbxCont,"1"+"�"+" "+"Contador")
EndIf
If lContador2
	aAdd(aCbxCont,"2"+"�"+" "+"Contador")
EndIf
If lContador1 .And. lContador2
	aAdd(aCbxCont,"Ambos")
EndIf
cCbxCont := aCbxCont[1]

nTipPeriod := 4 //Mensal

Processa({|| fContador(1), fContador(2) }, "Aguarde...")
Processa({|| fVariacao(1), fVariacao(2) }, "Aguarde...")

aBtnDlgVar := {}
aAdd(aBtnDlgVar, {"salvar"   , {|| fGrfSalva() }, OemToAnsi("Salvar"+" "+"Gr�fico"), OemToAnsi("Salvar"), {|| .T.} })
aAdd(aBtnDlgVar, {"impressao", {|| fGrfImp()   }, OemToAnsi("Imprimir"+" "+"Gr�fico"), OemToAnsi("Imprimir"), {|| .T.} })

//�����������������������������Ŀ
//� Monta a Tela                �
//�������������������������������
nCorVarF := aTempColor[1]
nCorVarB := aTempColor[2]

DEFINE MSDIALOG oDlgVar TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] COLOR CLR_BLACK, CLR_WHITE OF oMainWnd PIXEL
	
	oDlgVar:lEscClose := .F.
	
	oDlgVar:lMaximized := .T.
	
	//Painel do Dialog
	oPnlVar := TPanel():New(01, 01, , oDlgVar, , , , CLR_BLACK, CLR_WHITE, 1000, 1000)
	oPnlVar:Align := CONTROL_ALIGN_ALLCLIENT
	
	//Layer
	oLayerVar := FWLayer():New()
	oLayerVar:Init(oPnlVar, .F.)
	
	fLayout() //Cria o Layout da Tela
	
	//�����������������������������Ŀ
	//� Cabecalho                   �
	//�������������������������������
	//Painel Pai do Cabecalho
	oPnlCabec := TPanel():New(01, 01, , oObjVar, , , , CLR_BLACK, nCorVarB, 100, 035, .T., .T.)
	oPnlCabec:Align := CONTROL_ALIGN_TOP
	
		//Bem
		TSay():New(005, 012, {|| OemToAnsi("Bem"+":")}, oPnlCabec, , oFontVar, , ;
									, ,.T., nCorVarF, , 050, 015)
		TSay():New(005, 050, {|| OemToAnsi(AllTrim(cVerCodBem) + " - " + AllTrim(cVerNomBem))}, oPnlCabec, , oFontVar, , ;
									, ,.T., nCorVarF, , 400, 015)
		
		//Visualizando Contador
		TSay():New(020, 012, {|| OemToAnsi("Contador"+":")}, oPnlCabec, , oFontVar, , ;
									, ,.T., nCorVarF, , 050, 010)
		oCbxCont := TComboBox():New(019, 050, {|u| If(PCount() > 0, cCbxCont := u, cCbxCont)},;
										aCbxCont, 060, 015, oPnlCabec, , {|| fCbxChange()};
										, , , , .T., , , , , , , , ,"cCbxCont")
		oCbxCont:bHelp := {|| ShowHelpCpo("Contador",;
								{"Selecione o Contador para mostrar no gr�fico."},2,;
								{},2)}
		
	//�����������������������������Ŀ
	//� Menu Lateral                �
	//�������������������������������
	//Painel Pai do Menu Lateral
	oPnlMenu := TPanel():New(01, 01, , oObjVar, , , , CLR_WHITE, nCorVarB, 12, 100)
	oPnlMenu:Align := CONTROL_ALIGN_LEFT
	
		//Botao para selecionar o Periodo
		oBtnPeriod := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_historico", , , , {|| fPeriodo()}, oPnlMenu, OemToAnsi("Selecionar Per�odo"))
		oBtnPeriod:Align := CONTROL_ALIGN_TOP
	
	//�����������������������������Ŀ
	//� Grafico                     �
	//�������������������������������
	//Painel Pai do Menu Lateral
	oPnlGrafic := TPanel():New(01, 01, , oObjVar, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oPnlGrafic:Align := CONTROL_ALIGN_ALLCLIENT
		
		//Seleciona como iniciar a visualizacao do grafico, montando ele no processo
		If lContador1 .And. lContador2
			oCbxCont:Select(3)
		ElseIf lContador1
			oCbxCont:Select(1)
		ElseIf lContador2
			oCbxCont:Select(2)
		EndIf
		If Type("oGraphic") <> "O"
			fGrafico() //Caso o 'Select' nao monte o grafico, aqui monta
		EndIf
	
ACTIVATE MSDIALOG oDlgVar ON INIT EnchoiceBar(oDlgVar, {|| oDlgVar:End() }, {|| oDlgVar:End() }, , aBtnDlgVar) CENTERED

//�����������������������������������������������������������������������Ŀ
//� Devolve variaveis armazenadas (NGRIGHTCLICK)                          �
//�������������������������������������������������������������������������
fExit(cOldCadast, lOldINCLUI, lOldALTERA, aNGBEGINPRM)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �fExit     �Autor  �Wagner S. de Lacerda� Data �  12/09/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para retornar as variaveis ao sair da consulta.     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   � .T.                                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros� cOldCadast --> Obrigatorio;                                ���
���          �                Indica o 'cCadastro' anterior.              ���
���          � lOldINCLUI --> Opcional;                                   ���
���          �                Indica o 'INCLUI' anterior.                 ���
���          � lOldALTERA --> Opcional;                                   ���
���          �                Indica o 'ALTERA' anterior.                 ���
���          � aNGBEGINPRM -> Opcional;                                   ���
���          �                Indica as demais variaveis para retornar.   ���
�������������������������������������������������������������������������͹��
���Uso       � MNTC095                                                    ���
�������������������������������������������������������������������������͹��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������͹��
���Programador �   Data     � Descricao                                   ���
�������������������������������������������������������������������������͹��
���            � xx/xx/xxxx �                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fExit(cOldCadast, lOldINCLUI, lOldALTERA, aNGBEGINPRM)

cCadastro := cOldCadast

INCLUI := lOldINCLUI
ALTERA := lOldALTERA

//�����������������������������������������������������������������������Ŀ
//� Devolve variaveis armazenadas (NGRIGHTCLICK)                          �
//�������������������������������������������������������������������������
NGRETURNPRM(aNGBEGINPRM)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �fLayout   �Autor  �Wagner S. de Lacerda� Data �  12/09/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria o Layout da tela.                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   � .T.                                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MNTC095                                                    ���
�������������������������������������������������������������������������͹��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������͹��
���Programador �   Data     � Descricao                                   ���
�������������������������������������������������������������������������͹��
���            � xx/xx/xxxx �                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fLayout()

//Linhas
oLayerVar:AddLine("Linha_Consulta" , 100, .F.)

//Colunas
oLayerVar:AddCollumn("Coluna_Consulta", 100, .F., "Linha_Consulta")

//Janelas
oLayerVar:AddWindow("Coluna_Consulta", "Janela_Consulta" , , 100,;
					.F., .F., /*bAction*/, "Linha_Consulta", /*bGotFocus*/)

//Objetos
oObjVar := oLayerVar:GetWinPanel("Coluna_Consulta" , "Janela_Consulta" , "Linha_Consulta")

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �fValidaBem�Autor  �Wagner S. de Lacerda� Data �  12/09/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida o Bem.                                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   � .T.                                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MNTC095                                                    ���
�������������������������������������������������������������������������͹��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������͹��
���Programador �   Data     � Descricao                                   ���
�������������������������������������������������������������������������͹��
���            � xx/xx/xxxx �                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fValidaBem()

dbSelectArea("ST9")
dbSetOrder(1)
If !dbSeek(cVerCodFil+cVerCodBem)
	ApMsgInfo("N�o foi poss�vel montar a consulta."+CRLF+CRLF+;
				"Motivo"+": "+"O Bem n�o est� cadastrado no sistema.","Aten��o")
	Return .F.
EndIf
cVerNomBem := ST9->T9_NOME

lContador1 := ( AllTrim(ST9->T9_TEMCONT) <> "N" )

dbSelectArea("TPE")
dbSetOrder(1)
lContador2 := dbSeek(ST9->T9_FILIAL+ST9->T9_CODBEM)

If !lContador1 .And. !lContador2
	ApMsgInfo("N�o foi poss�vel montar a consulta."+CRLF+CRLF+;
				"Motivo"+": "+"O Bem n�o � controlado por contador.","Aten��o")
	Return .F.
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �fContador �Autor  �Wagner S. de Lacerda� Data �  12/09/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca os Contadors do Bem no periodo determinado.          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   � .T.                                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros� nTipCont -> Opcional;                                      ���
���          �             Indica qual o Contador a buscar.               ���
���          �              1 - Contador 1 do Bem                         ���
���          �              2 - Contador 2 do Bem                         ���
���          �             Default: 1.                                    ���
�������������������������������������������������������������������������͹��
���Uso       � MNTC095                                                    ���
�������������������������������������������������������������������������͹��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������͹��
���Programador �   Data     � Descricao                                   ���
�������������������������������������������������������������������������͹��
���            � xx/xx/xxxx �                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fContador(nTipCont)

Local aDadosCont := {}
Local cCodFilTMP := ""

Local aBuscaCont := {}
Local lBuscaCont := .T.

Default nTipCont := 1

If nTipCont == 1
	aDadosCont := {"STP",;
					"STP->TP_CODBEM" , "STP->TP_ORDEM", "STP->TP_PLANO"  ,;
					"STP->TP_DTLEITU", "STP->TP_HORA" , "STP->TP_POSCONT",;
					"STP->TP_FILIAL"}
	
	lBuscaCont := lContador1
Else
	aDadosCont := {"TPP",;
					"TPP->TPP_CODBEM", "TPP->TPP_ORDEM", "TPP->TPP_PLANO"  ,;
					"TPP->TPP_DTLEIT", "TPP->TPP_HORA" , "TPP->TPP_POSCON",;
					"TPP->TPP_FILIAL"}
	
	lBuscaCont := lContador2
EndIf

cCodFilTMP := If(NGSX2MODO(aDadosCont[1]) == "E", cVerCodFil, xFilial(aDadosCont[1]))

//�����������������������������Ŀ
//� Busca Contador              �
//�������������������������������
aBuscaCont := {}

If lBuscaCont
	dbSelectArea(aDadosCont[1])
	dbSetOrder(5)
	dbSeek(cCodFilTMP+cVerCodBem+If(!lTodoHist,DTOS(dDeData),""),.T.)
	
	ProcRegua(LastRec() - RecNo())
	While !Eof() .And. &(aDadosCont[8]) == cCodFilTMP .And. AllTrim(&(aDadosCont[2])) == AllTrim(cVerCodBem) .And. If(!lTodoHist,&(aDadosCont[5]) <= dAteData,.T.)
		IncProc("Carregando"+" "+"Contador"+" "+cValToChar(nTipCont)+"...")
		
		//1             ; 2                ; 3                   ; 4               ; 5               ; 6
		//Codigo do Bem ; Ordem de Servico ; Plano de Manutencao ; Data da Leitura ; Hora da Leitura ; Posicao do Contador
		aAdd(aBuscaCont, {&(aDadosCont[2]), &(aDadosCont[3]), &(aDadosCont[4]), &(aDadosCont[5]), &(aDadosCont[6]), &(aDadosCont[7])})
		
		dbSelectArea(aDadosCont[1])
		dbSkip()
	End
EndIf

If Len(aBuscaCont) > 0
	aSort(aBuscaCont, , , {|x,y| DTOS(x[4])+x[5] < DTOS(y[4])+y[5] })
EndIf

If nTipCont == 1
	aContador1 := aClone( aBuscaCont )
Else
	aContador2 := aClone( aBuscaCont )
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �fVariacao �Autor  �Wagner S. de Lacerda� Data �  14/09/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � Define a Variacao para o grafico.                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   � .T.                                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros� nTipCont -> Opcional;                                      ���
���          �             Indica qual o Contador a buscar.               ���
���          �              1 - Contador 1 do Bem                         ���
���          �              2 - Contador 2 do Bem                         ���
���          �             Default: 1.                                    ���
�������������������������������������������������������������������������͹��
���Uso       � MNTC095                                                    ���
�������������������������������������������������������������������������͹��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������͹��
���Programador �   Data     � Descricao                                   ���
�������������������������������������������������������������������������͹��
���            � xx/xx/xxxx �                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fVariacao(nTipCont)

Local nX := 0

Local aPrdCont  := {}
Local aHistCont := {}
Local aVarCont  := {}
Local lTemCont  := .T.

Local aDtAux    := {}
Local dFirstDt  := CTOD("")
Local dLastDt   := CTOD("")
Local nDtDia    := 0
Local nDtAux    := 0
Local nDtMes    := 0
Local nDtAno    := 0
Local lDtFirst  := .F.
Local nDtFirst  := 0

Local nAuxiliar := 0
Local nJaExiste := 0

Default nTipCont := 1

If nTipCont == 1
	aHistCont := aClone( aContador1 )
	lTemCont  := ( lContador1 .And. Len(aContador1) > 0 )
Else
	aHistCont := aClone( aContador2 )
	lTemCont  := ( lContador2 .And. Len(aContador2) > 0 )
EndIf

//�����������������������������Ŀ
//� Acumula Contador no Periodo �
//�������������������������������
aPrdCont := {}
If lTemCont
	ProcRegua(Len(aHistCont))
	
	For nX := 1 To Len(aHistCont)
		IncProc("Carregando"+" "+"Per�odo"+" "+cValToChar(nTipCont)+"...")
		
		nJaExiste := 0
		
		If nTipPeriod == 2 .Or. nTipPeriod == 3 //Semanal ou Quinzenal
			//--- Define o Primeiro e o Ultimo dia do Mes
			nDtDia := 0
			nDtAux := 0
			nDtMes := Month(aHistCont[nX][4])
			nDtAno := Year(aHistCont[nX][4])
			
			dFirstDt := CTOD( "01/" + cValToChar(nDtMes) + "/" + cValToChar(nDtAno) )
			
			dLastDt := CTOD("")
			nAuxiliar := 31 //Maior dia possivel em qualquer mes
			While nAuxiliar > 28 .And. Empty(dLastDt) //28 = Menor dia possivel em qualquer mes (Fevereiro)
				dLastDt := CTOD( cValToChar(nAuxiliar) + "/" + cValToChar(nDtMes) + "/" + cValToChar(nDtAno) )
				nAuxiliar--
			End
		EndIf
		
		If nTipPeriod == 1
			//�����������������������������Ŀ
			//� Diario                      �
			//�������������������������������
			//--- Adiciona o Dia
			nJaExiste := aScan(aPrdCont, {|x| x[1] == aHistCont[nX][4] })
			If nJaExiste == 0
				//1    ; 2
				//Data ; Posicao do Contador
				aAdd(aPrdCont, {aHistCont[nX][4], aHistCont[nX][6]} )
			Else
				aPrdCont[nJaExiste][2] := Max(aPrdCont[nJaExiste][2], aHistCont[nX][6])
			EndIf
		ElseIf nTipPeriod == 2
			//�����������������������������Ŀ
			//� Semanal                     �
			//�������������������������������
			//--- Monta o Array com as Semanas do Mes/Ano
			//Este array ira armazenar as Datas nas respectivas semanas do mes
			//Primeira ; Segunda ; Terceira ; Quarta (semanas do mes)
			aDtAux := { {}, {}, {}, {} }
			lDtFirst := .T.
			
			While dFirstDt <= dLastDt
				nDtDia := DOW(dFirstDt)
				
				If lDtFirst //Primeiro Dia
					lDtFirst := .F.
					nDtFirst := nDtDia
					nDtAux := 1
				ElseIf nDtDia == nDtFirst .And. nDtAux < 4 //Quando o dia da semana for igual novamente, comeca uma nova (maximo sao quatro semanas)
					nDtAux++
				EndIf
				aAdd(aDtAux[nDtAux], dFirstDt)
				
				dFirstDt++
			End
			
			//--- Adiciona a Semana
			For nDtAux := 1 To Len(aDtAux)
				If aScan(aDtAux[nDtAux], {|x| x == aHistCont[nX][4] }) > 0
					nJaExiste := aScan(aPrdCont, {|x| x[1] == nDtAux .And. x[3] == nDtMes .And. x[4] == nDtAno })
					If nJaExiste == 0
						//1      ; 2                   ; 3   ; 4
						//Semana ; Posicao do Contador ; Mes ; Ano
						aAdd(aPrdCont, {nDtAux, aHistCont[nX][6], nDtMes, nDtAno} )
					Else
						aPrdCont[nJaExiste][2] := Max(aPrdCont[nJaExiste][2], aHistCont[nX][6])
					EndIf
				EndIf
			Next nDtAux
		ElseIf nTipPeriod == 3
			//�����������������������������Ŀ
			//� Quinzenal                   �
			//�������������������������������
			//--- Monta o Array com as Quinzenas do Mes/Ano
			//Este array ira armazenar as Datas nas respectivas quinzenas do mes
			//Primeira ; Segunda (quinzenas do mes)
			aDtAux := { {}, {} }
			lDtFirst := .T.
			
			While dFirstDt <= dLastDt
				nDtDia := DAY(dFirstDt)
				
				If lDtFirst //Primeiro Dia
					lDtFirst := .F.
					nDtAux := 1 //Primeira Quinzena
				ElseIf nDtDia > 15 //Segunda Quinzena
					nDtAux := 2
				EndIf
				aAdd(aDtAux[nDtAux], dFirstDt)
				
				dFirstDt++
			End
			
			//--- Adiciona a Quinzena
			For nDtAux := 1 To Len(aDtAux)
				If aScan(aDtAux[nDtAux], {|x| x == aHistCont[nX][4] }) > 0
					nJaExiste := aScan(aPrdCont, {|x| x[1] == nDtAux .And. x[3] == nDtMes .And. x[4] == nDtAno })
					If nJaExiste == 0
						//1        ; 2                   ; 3   ; 4
						//Quinzena ; Posicao do Contador ; Mes ; Ano
						aAdd(aPrdCont, {nDtAux, aHistCont[nX][6], nDtMes, nDtAno} )
					Else
						aPrdCont[nJaExiste][2] := Max(aPrdCont[nJaExiste][2], aHistCont[nX][6])
					EndIf
				EndIf
			Next nDtAux
		ElseIf nTipPeriod == 4
			//�����������������������������Ŀ
			//� Mensal                      �
			//�������������������������������
			//--- Adiciona o Mes
			nDtMes := Month(aHistCont[nX][4])
			nDtAno := Year(aHistCont[nX][4])
			
			nJaExiste := aScan(aPrdCont, {|x| x[1] == nDtMes .And. x[3] == nDtAno })
			If nJaExiste == 0
				//1   ; 2                   ; 3
				//Mes ; Posicao do Contador ; Ano
				aAdd(aPrdCont, {nDtMes, aHistCont[nX][6], nDtAno} )
			Else
				aPrdCont[nJaExiste][2] := Max(aPrdCont[nJaExiste][2], aHistCont[nX][6])
			EndIf
		ElseIf nTipPeriod == 5
			//�����������������������������Ŀ
			//� Semestral                   �
			//�������������������������������
			//--- Adiciona o Semestre
			nDtMes := If(Month(aHistCont[nX][4]) <= 6,1,2) //Semestre 1 ou 2
			nDtAno := Year(aHistCont[nX][4])
			
			nJaExiste := aScan(aPrdCont, {|x| x[1] == nDtMes .And. x[3] == nDtAno })
			If nJaExiste == 0
				//1        ; 2                   ; 3
				//Semestre ; Posicao do Contador ; Ano
				aAdd(aPrdCont, {nDtMes, aHistCont[nX][6], nDtAno} )
			Else
				aPrdCont[nJaExiste][2] := Max(aPrdCont[nJaExiste][2], aHistCont[nX][6])
			EndIf
		ElseIf nTipPeriod == 6
			//�����������������������������Ŀ
			//� Anual                       �
			//�������������������������������
			//--- Adiciona o Ano
			nDtAno := Year(aHistCont[nX][4])
			
			nJaExiste := aScan(aPrdCont, {|x| x[1] == nDtAno })
			If nJaExiste == 0
				//1   ; 2
				//Ano ; Posicao do Contador
				aAdd(aPrdCont, {nDtAno, aHistCont[nX][6]} )
			Else
				aPrdCont[nJaExiste][2] := Max(aPrdCont[nJaExiste][2], aHistCont[nX][6])
			EndIf
		EndIf
	Next nX
EndIf

//�����������������������������Ŀ
//� Variacao do Contador        �
//�������������������������������
aVarCont := {}
If lTemCont
	ProcRegua(Len(aPrdCont))
	
	For nX := 1 To Len(aPrdCont)
		IncProc("Carregando"+" "+"Varia��o"+" "+cValToChar(nTipCont)+"...")
		
		If nX == 1
			//A Primeira "Variacao" e' sempre zero, para comecar o grafico
			nAuxiliar := 0
			If nTipPeriod == 1 .Or. nTipPeriod == 6
				//�����������������������������Ŀ
				//� Diario/Anual                �
				//�������������������������������
				aAdd(aVarCont, {aPrdCont[nX][1], nAuxiliar} )
			ElseIf nTipPeriod == 2 .Or. nTipPeriod == 3
				//�����������������������������Ŀ
				//� Semanal/Quinzenal           �
				//�������������������������������
				aAdd(aVarCont, {aPrdCont[nX][1], nAuxiliar, aPrdCont[nX][3], aPrdCont[nX][4]} )
			ElseIf nTipPeriod == 4 .Or. nTipPeriod == 5
				//�����������������������������Ŀ
				//� Mensal/Semestral            �
				//�������������������������������
				aAdd(aVarCont, {aPrdCont[nX][1], nAuxiliar, aPrdCont[nX][3]} )
			EndIf
		Else
			If nTipPeriod == 1 .Or. nTipPeriod == 6
				//�����������������������������Ŀ
				//� Diario/Anual                �
				//�������������������������������
				aAdd(aVarCont, {aPrdCont[nX][1], ( aPrdCont[nX][2] - nAuxiliar )} )
			ElseIf nTipPeriod == 2 .Or. nTipPeriod == 3
				//�����������������������������Ŀ
				//� Semanal/Quinzenal           �
				//�������������������������������
				aAdd(aVarCont, {aPrdCont[nX][1], ( aPrdCont[nX][2] - nAuxiliar ), aPrdCont[nX][3], aPrdCont[nX][4]} )
			ElseIf nTipPeriod == 4 .Or. nTipPeriod == 5
				//�����������������������������Ŀ
				//� Mensal/Semestral            �
				//�������������������������������
				aAdd(aVarCont, {aPrdCont[nX][1], ( aPrdCont[nX][2] - nAuxiliar ), aPrdCont[nX][3]} )
			EndIf
		EndIf
		
		nAuxiliar := aPrdCont[nX][2]
	Next nX
EndIf

If nTipCont == 1
	aPeriodo1  := aClone( aPrdCont )
	aVariacao1 := aClone( aVarCont )
Else
	aPeriodo2  := aClone( aPrdCont )
	aVariacao2 := aClone( aVarCont )
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �fGrafico  �Autor  �Wagner S. de Lacerda� Data �  14/09/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta o Grafico.                                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   � .T.                                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros� lDestroy -> Opcional;                                      ���
���          �             Indica se deve destruir o objeto do Grafico.   ���
���          �              .T. - Destroi                                 ���
���          �              .F. - Nao destroi                             ���
���          �             Default: .F.                                   ���
�������������������������������������������������������������������������͹��
���Uso       � MNTC095                                                    ���
�������������������������������������������������������������������������͹��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������͹��
���Programador �   Data     � Descricao                                   ���
�������������������������������������������������������������������������͹��
���            � xx/xx/xxxx �                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fGrafico(lDestroy)

Default lDestroy := .F.

Private nMaiorY := 0

If lDestroy .And. Type("oGraphic") == "O"
	If nSerie1 <> 0
		oGraphic:DelSerie(nSerie1)
	EndIf
	If nSerie2 <> 0
		oGraphic:DelSerie(nSerie2)
	EndIf
	MsFreeObj(oGraphic)
EndIf

If Type("oGraphic") <> "O"
	oGraphic := TMSGraphic():New(001, 001, oPnlGrafic, , , , 1000, 1000)
	oGraphic:SetMargins(10, 10, 10, 10)
	oGraphic:SetTitle(OemToAnsi(AllTrim(cVerCodBem) + " - " + AllTrim(cVerNomBem)),;
						If(!lTodoHist,DTOC(dDeData)+" - "+DTOC(dAteData),OemToAnsi("Todo o Hist�rico")),;
						CLR_RED, A_CENTER, GRP_TITLE)
	oGraphic:SetTitle(OemToAnsi("Posi��o"), "", CLR_GRAY, A_LEFTJUST, GRP_TITLE)
	oGraphic:SetTitle(OemToAnsi("Per�odo"), "", CLR_GRAY, A_CENTER, GRP_FOOT)
	oGraphic:Align := CONTROL_ALIGN_ALLCLIENT
	
	oGraphic:l3D := .F.
	
	nSerie1 := 0
	nSerie2 := 0
EndIf

If nSerie1 <> 0
	oGraphic:DelSerie(nSerie1)
EndIf
If nSerie2 <> 0
	oGraphic:DelSerie(nSerie2)
EndIf

If oCbxCont:nAT == 1 .Or. oCbxCont:nAT == 3 //Contador 1 ou Ambos
	If !lContador1
		ApMsgInfo("N�o foi poss�vel montar a consulta."+CRLF+CRLF+;
					"Motivo"+": "+"O Bem n�o possui o primeiro contador.","Aten��o")
	EndIf
	//�����������������������������Ŀ
	//� Contador 1                  �
	//�������������������������������
	fGrfSerie(1)
EndIf

If oCbxCont:nAT == 2 .Or. oCbxCont:nAT == 3 //Contador 2 ou Ambos
	If !lContador2
		ApMsgInfo("N�o foi poss�vel montar a consulta."+CRLF+CRLF+;
					"Motivo"+": "+"O Bem n�o possui o segundo contador.","Aten��o")
	EndIf
	//�����������������������������Ŀ
	//� Contador 2                  �
	//�������������������������������
	fGrfSerie(2)
EndIf

nMaiorY := ( nMaiorY + 10 )
oGraphic:SetRangeY(0,nMaiorY)

oGraphic:l3D := .T.
oGraphic:l3D := .F.

oGraphic:Refresh()

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �fGrfSerie �Autor  �Wagner S. de Lacerda� Data �  19/09/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta a Serie do Grafico.                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   � .T.                                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros� nTipCont -> Opcional;                                      ���
���          �             Indica qual o Contador a buscar.               ���
���          �              1 - Contador 1 do Bem                         ���
���          �              2 - Contador 2 do Bem                         ���
���          �             Default: 1.                                    ���
�������������������������������������������������������������������������͹��
���Uso       � MNTC095                                                    ���
�������������������������������������������������������������������������͹��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������͹��
���Programador �   Data     � Descricao                                   ���
�������������������������������������������������������������������������͹��
���            � xx/xx/xxxx �                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fGrfSerie(nTipCont)

Local aTmpVar   := {}
Local cTipCont  := ""
Local nTmpSerie := 0
Local nTmpColor := 0

Local nX

Default nTipCont := 1

If nTipCont == 1 //Contador 1
	aTmpVar   := aClone( aVariacao1 )
	nTmpColor := CLR_GREEN
Else //Contador 2
	aTmpVar   := aClone( aVariacao2 )
	nTmpColor := CLR_BLUE
EndIf

cTipCont  := cValToChar(nTipCont)
nTmpSerie := oGraphic:CreateSerie(GRP_LINE, cTipCont+"�"+" "+"Contador", 0)
If Len(aTmpVar) > 0
	For nX := 1 To Len(aTmpVar)
		If aTmpVar[nX][2] > nMaiorY
			nMaiorY := aTmpVar[nX][2]
		EndIf
		
		If nTipPeriod == 1 .Or. nTipPeriod == 6
			//�����������������������������Ŀ
			//� Diario/Anual                �
			//�������������������������������
			oGraphic:Add(nTmpSerie, aTmpVar[nX][2],;
				If(nTipPeriod == 1,DTOC(aTmpVar[nX][1]),cValToChar(aTmpVar[nX][1])),;
			nTmpColor)
		ElseIf nTipPeriod == 2 .Or. nTipPeriod == 3
			//�����������������������������Ŀ
			//� Semanal/Quinzenal           �
			//�������������������������������
			oGraphic:Add(nTmpSerie, aTmpVar[nX][2],;
				cValToChar(aTmpVar[nX][1]) + "�" + " " + If(nTipPeriod == 2, "Semana","Quinzena") + " " + "de" + " " + ;
				PADL(aTmpVar[nX][3],2,"0") + "/" + cValToChar(aTmpVar[nX][4]),;
			nTmpColor)
		ElseIf nTipPeriod == 4 .Or. nTipPeriod == 5
			//�����������������������������Ŀ
			//� Mensal/Semestral            �
			//�������������������������������
			oGraphic:Add(nTmpSerie, aTmpVar[nX][2],;
				If(nTipPeriod == 4,MesExtenso(aTmpVar[nX][1]),cValToChar(aTmpVar[nX][1]) + "�" + "Semestre") + " " + "/" + " " + ;
				cValToChar(aTmpVar[nX][3]),;
			nTmpColor)
		EndIf
	Next nX
Else
	oGraphic:Add(nTmpSerie, 0, "", nTmpColor)
EndIf

If nTipCont == 1 //Contador 1
	nSerie1 := nTmpSerie
Else //Contador 2
	nSerie2 := nTmpSerie
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �fGrfSalva �Autor  �Wagner S. de Lacerda� Data �  19/09/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � Salva o Grafico.                                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   � .T.                                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MNTC095                                                    ���
�������������������������������������������������������������������������͹��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������͹��
���Programador �   Data     � Descricao                                   ���
�������������������������������������������������������������������������͹��
���            � xx/xx/xxxx �                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fGrfSalva()

Local cDirSave := ""

If Type("oGraphic") <> "O"
	Return .F.
EndIf

cDirSave := AllTrim( NGRetBusca(1,.T.) )

If File(cDirSave + cImgSave)
	FErase(cDirSave + cImgSave)
EndIf
If oGraphic:SaveToImage(cImgSave, cDirSave, cImgExtens)
	ApMsgInfo("Gr�fico salvo com sucesso!"+CRLF+CRLF+;
				"Caminho"+": '"+cDirSave+cImgSave+"'","Aten��o")
	Return .T.
Else
	ApMsgStop("N�o foi poss�vel salvar o gr�fico no diret�rio selecionado."+CRLF+CRLF+;
				"Caminho"+": '"+cDirSave+cImgSave+"'","Aten��o")
	Return .F.
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �fGrfImp   �Autor  �Wagner S. de Lacerda� Data �  19/09/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � Imprime o Grafico.                                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   � .T.                                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MNTC095                                                    ���
�������������������������������������������������������������������������͹��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������͹��
���Programador �   Data     � Descricao                                   ���
�������������������������������������������������������������������������͹��
���            � xx/xx/xxxx �                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fGrfImp()

Local cImgPath := ""

Local oPrintGrf
Local nPrintLin
Local cFileLogo := ""

If Type("oGraphic") <> "O"
	Return .F.
EndIf

cImgPath := cMV_Path + cImgSave

If File(cImgPath)
	Ferase(cImgPath)
Endif
If !oGraphic:SaveToImage(cImgSave, cMV_Path, cImgExtens)
	ApMsgStop("N�o foi poss�vel salvar o gr�fico para impress�o.","Aten��o")
	Return .F.
EndIf

oPrintGrf := TMSPrinter():New(OemToAnsi(cCadastro))
oPrintGrf:SetLandScape() //Paisagem
oPrintGrf:StartPage()

nPrintLin := 75
oPrintGrf:Line(nPrintLin,25,nPrintLin,3125)
nPrintLin := 150
cFileLogo := "lgrl"+SM0->M0_CODIGO+SM0->M0_CODFIL+".bmp"
If !File(cFileLogo)
	cFileLogo := "lgrl"+SM0->M0_CODIGO+".bmp"
EndIf
If File(cFileLogo)
	oSend(oPrintGrf, "SayBitmap",100,100, cFileLogo ,320,120 )
EndIf
oPrintGrf:Say(nPrintLin+20,1200,cCadastro)
oPrintGrf:Say(nPrintLin+45,2900,"Data"+": " + cValToChar(Date()))
oPrintGrf:Say(nPrintLin+80,2900,"Hora"+": " + Time())
nPrintLin := 300
oPrintGrf:Line(nPrintLin,25,nPrintLin,3125)
If File(cImgPath)
	oPrintGrf:SayBitmap(nPrintLin+100,100,cImgPath,3000,2000)
EndIf
oPrintGrf:EndPage()

oPrintGrf:Preview()

If File(cImgPath)
	Ferase(cImgPath)
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �fPeriodo  �Autor  �Wagner S. de Lacerda� Data �  14/09/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � Seleciona o Periodo do Grafico.                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   � .T.                                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MNTC095                                                    ���
�������������������������������������������������������������������������͹��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������͹��
���Programador �   Data     � Descricao                                   ���
�������������������������������������������������������������������������͹��
���            � xx/xx/xxxx �                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fPeriodo()

Local oDlgPeriod
Local oPnlPrdAll, oPnlPrdBOT

Local cDlgTitle := OemToAnsi("Per�odo da Consulta")
Local lOk := .F.

Local oObjTemp
Local oFontPrd  := TFont():New(, , , .T., .T.)

Private aTmpCbx := {"Di�rio","Semanal","Quinzenal","Mensal","Semestral","Anual"}
Private cTmpCbx := aTmpCbx[1]
Private nTmpCbx := nTipPeriod

Private dTmpDeDt  := dDeData
Private dTmpAteDt := dAteData
Private lTmpHist  := lTodoHist

Private oTmpCbx   := Nil
Private oTmpBtnOk := Nil
Private oTmpBtnCa := Nil

DEFINE MSDIALOG oDlgPeriod TITLE cDlgTitle FROM 0,0 TO 230,250 OF oMainWnd PIXEL
	
	//ALL
	oPnlPrdAll := TPanel():New(01, 01, , oDlgPeriod, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oPnlPrdAll:Align := CONTROL_ALIGN_ALLCLIENT
	
		//De Data
		@ 015,010 SAY OemToAnsi("De Data"+":") FONT oFontPrd COLOR CLR_BLACK OF oPnlPrdAll PIXEL
		oObjTemp := TGet():New(014, 050, {|u| If(PCount() > 0, dTmpDeDt := u, dTmpDeDt)}, oPnlPrdAll, 060, 008, "99/99/9999",;
									{|| fPrdValid(1) }, CLR_BLACK, , ,;
									.F., , .T., , .F., {|| !lTmpHist }, .F., .F., , .F., .F., , "dTmpDeDt", , , , .T./*lHasButton*/)
		oObjTemp:bHelp := {|| ShowHelpCpo("De Data",;
								{"Data inicial para a filtrar a consulta."},2,;
								{},2)}
		
		//Ate Data
		@ 030,010 SAY OemToAnsi("At� Data"+":") FONT oFontPrd COLOR CLR_BLACK OF oPnlPrdAll PIXEL
		oObjTemp := TGet():New(029, 050, {|u| If(PCount() > 0, dTmpAteDt := u, dTmpAteDt)}, oPnlPrdAll, 060, 008, "99/99/9999",;
									{|| fPrdValid(2) }, CLR_BLACK, , ,;
									.F., , .T., , .F., {|| !lTmpHist }, .F., .F., , .F., .F., , "dTmpAteDt", , , , .T./*lHasButton*/)
		oObjTemp:bHelp := {|| ShowHelpCpo("Ate Data",;
								{"Data final para a filtrar a consulta."},2,;
								{},2)}
		
		//Todo o Historico
		TCheckBox():New(050, 050, "Todo o Hist�rico", {|| lTmpHist }, oPnlPrdAll, 100, 015, , {|| lTmpHist := !lTmpHist, oTmpBtnOk:SetFocus() }, , , , , , .T., , ,)
		
		//Periodo
		@ 070,010 SAY OemToAnsi("Per�odo"+":") FONT oFontPrd COLOR CLR_BLACK OF oPnlPrdAll PIXEL
		oTmpCbx := TComboBox():New(069, 050, {|u| If(PCount() > 0, cTmpCbx := u, cTmpCbx)},;
										aTmpCbx, 060, 015, oPnlPrdAll, , {|| nTmpCbx := oTmpCbx:nAT };
										, , , , .T., , , , , , , , ,"cTmpCbx")
		oTmpCbx:Select(nTipPeriod)
	
	//BOT
	oPnlPrdBOT := TPanel():New(01, 01, , oDlgPeriod, , , , CLR_BLACK, CLR_WHITE, 100, 020, .T., .F.)
	oPnlPrdBOT:Align := CONTROL_ALIGN_BOTTOM
	
		//Botao OK
		oTmpBtnOk := SButton():New(003, 060, 1, {|| lOk := .T., If(fPrdValid(), oDlgPeriod:End(), lOk := .F.) }, oPnlPrdBOT, .T., , )
		//Botao Cancelar
		oTmpBtnCa := SButton():New(003, 095, 2, {|| lOk := .F., oDlgPeriod:End() }, oPnlPrdBOT, .T., , )
	
ACTIVATE MSDIALOG oDlgPeriod CENTERED

If lOk
	dDeData    := dTmpDeDt
	dAteData   := dTmpAteDt
	lTodoHist  := lTmpHist
	nTipPeriod := nTmpCbx
	
	Processa({|| fContador(1), fContador(2) }, "Aguarde...")
	Processa({|| fVariacao(1), fVariacao(2) }, "Aguarde...")
	fGrafico(.T.)
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �fPrdValid �Autor  �Wagner S. de Lacerda� Data �  14/09/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida o Periodo selecionado.                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   � .T.                                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros� nVldDt -> Opcional;                                        ���
���          �           Indica qual data deve ser validada.              ���
���          �            0 - Ambas (De Data e Ate Data)                  ���
���          �            1 - De Data somente                             ���
���          �            2 - Ate Data somente                            ���
���          �           Default: 0.                                      ���
�������������������������������������������������������������������������͹��
���Uso       � MNTC095                                                    ���
�������������������������������������������������������������������������͹��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������͹��
���Programador �   Data     � Descricao                                   ���
�������������������������������������������������������������������������͹��
���            � xx/xx/xxxx �                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fPrdValid(nVldDt)

Default nVldDt := 0

If nVldDt == 0 .Or. nVldDt == 1 //De Data
	If Empty(dTmpDeDt)
		ShowHelpDlg("Data Inv�lida",;
					{"A data inicial est� vazia."},2,;
					{"Favor preencher a data inicial."},2)
		Return .F.
	ElseIf dTmpDeDt > dDataBase
		ShowHelpDlg("Data Inv�lida",;
					{"A data inicial n�o pode ser superior � atual."},2,;
					{"Favor selecionar uma data adequada, que seja inferior � data atual."},2)
		Return .F.
	ElseIf !Empty(dTmpAteDt) .And. dTmpDeDt > dTmpAteDt
		ShowHelpDlg("Data Inv�lida",;
					{"A data inicial n�o pode ser superior � final."},2,;
					{"Favor selecionar uma data que seja inferior, ou igual, � data final."},2)
		Return .F.
	EndIf
EndIf
If nVldDt == 0 .Or. nVldDt == 2 //Ate Data
	If Empty(dTmpAteDt)
		ShowHelpDlg("Data Inv�lida",;
					{"A data final est� vazia."},2,;
					{"Favor preencher a data final."},2)
		Return .F.
	ElseIf dTmpAteDt > dDataBase
		ShowHelpDlg("Data Inv�lida",;
					{"A data final n�o pode ser superior � atual."},2,;
					{"Favor selecionar uma data adequada, que seja inferior � data atual."},2)
		Return .F.
	ElseIf !Empty(dTmpDeDt) .And. dTmpAteDt < dTmpDeDt
		ShowHelpDlg("Data Inv�lida",;
					{"A data final n�o pode ser inferior � inicial."},2,;
					{"Favor selecionar uma data que seja superior, ou igual, � data inicial."},2)
		Return .F.
	EndIf
EndIf

If nVldDt == 0 //Valida ambas as datas (De Data - Ate Data)
	If dTmpAteDt < dTmpDeDt
		ShowHelpDlg("Data Inv�lida",;
					{"A data final n�o pode ser inferior � inicial."},2,;
					{"Favor selecionar uma data que seja superior, ou igual, � data inicial."},2)
		Return .F.
	EndIf
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �fCbxChange�Autor  �Wagner S. de Lacerda� Data �  14/09/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � Mudanca no Combo de selecao da Visualizacao.               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   � .T.                                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MNTC095                                                    ���
�������������������������������������������������������������������������͹��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������͹��
���Programador �   Data     � Descricao                                   ���
�������������������������������������������������������������������������͹��
���            � xx/xx/xxxx �                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fCbxChange()

fGrafico()

Return .T.