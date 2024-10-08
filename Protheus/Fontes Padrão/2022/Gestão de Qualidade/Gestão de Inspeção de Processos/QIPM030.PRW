#INCLUDE "TOTVS.CH"
#INCLUDE "qipm030.CH"
#include "PROTHEUS.ch"
#Define PARETO "6"      

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � qipm030  � Autor � Marcelo Pimentel      � Data � 12/04/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de geracao do Diagrama de Pareto                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaQIP                                                    ���
���          � Obs.: Se nao especificar a revisao do produto, considera a ���
���          � revisao vigente na data producao   limite (ate), para exi- ���
���          � bir os ensaios para escolha e para identificar os Limites  ���
���          � Engenharia. Neste caso (revisao em branco) serao conside-  ���
���          � radas as medicoes de todas as revisoes que existirem no    ���
���          � periodo, mesmo que haja diferenca de especificacao do en-  ���
���          � saio, de uma revisao para outra.                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function qipm030
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local cAlias  := Alias()
Local cRevi   := "  "
Local cTit    := OemToAnsi(STR0001)	// "Diagrama de Pareto"
Local lCont   := .T.
Local lBrwEns := .f.
Local oTempT	:= NIL

PRIVATE cIndex1
PRIVATE nIndex,nOpt1 := 1
PRIVATE cMarca := GetMark() 
PRIVATE  __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
PRIVATE lProduto   := .F.
Private lExistChart := FindFunction("QIEMGRAFIC") .AND. GetBuild() >= "7.00.170117A" //controle se executa o grafico modelo novo ou por DLL

//��������������������������������������������������������������Ŀ
//� mv_par01: Produto              ? (Um ou Todos)               �
//� mv_par02: Revisao              ? (Uma ou Todas)              �
//� mv_par03: Data da Producao De  ?                             �
//� mv_par04: Data da Producao Ate'?                             �
//� mv_par05: Ensaiador De         ?                             � 
//� mv_par06: Ensaiador Ate'       ?                       		 �
//� mv_par07: Operacao De          ?                      		 �
//� mv_par08: Operacao Ate'        ?                             �
//� mv_par09: Laboratorio De       ?                             �
//� mv_par10: Laboratorio Ate'     ?                             �
//� mv_par11: Laboratorio Ate'     ? (Sim ou Nao)		 		 �
//� mv_par12: Roteiro De     	   ?			     			 �
//� mv_par13: Roteiro Ate'	       ?                			 �
//����������������������������������������������������������������   

If Pergunte("QPM030",.T.)
	// Se nao definiu os parametros Ate', assume "ZZZZ"
	mv_par06 := Iif(Empty(mv_par06),Replicate("Z",TamSx3("QPR_ENSR")[1]),mv_par06)

	//������������������������������������������������������������������Ŀ
	//� Valida o Produto / Revisao                                       �
	//��������������������������������������������������������������������
	If !Empty(mv_par01)
		mv_par01 := Upper(mv_par01)
		If Empty(mv_par02)	// Nao especificou a revisao
			If !QP6->(dbSeek(xFilial("QP6")+mv_par01))
				Help(" ",1,"QIEPRODNAO")	// "Produto nao cadastrado."
				lCont := .F.
			EndIf
		Else
			If !QP6->(dbSeek(xFilial("QP6")+mv_par01+Inverte(mv_par02)))
				Help(" ",1,"QIEPRRVNAO")	// "Produto/Revisao nao cadastrados."
				lCont := .F.
			EndIf
		EndIf
	EndIf

	If lCont
		//������������������������������������������������������������������Ŀ
		//� Identifica a revisao a ser adotada                               �
		//��������������������������������������������������������������������
		// Se especificou o Produto:
		// Se nao especificou a revisao, assume a revisao vigente na data final
		If !Empty(mv_par01)
			lBrwEns := .t.
			If !Empty(mv_par02)
				cRevi := mv_par02
			Else
				cRevi := QA_UltRevEsp(mv_par01,mv_par04,,,"QIP") 
			EndIf
		EndIf
		//������������������������������������������������������������������Ŀ
		//� Chamada da Funcao para montar o Browse para escolha dos ensaios  �
		//��������������������������������������������������������������������
		If lBrwEns
			lCont := M030BrwEns(cRevi,cTit,@oTempT)
		EndIf

		//���������������������������������������������������������������������Ŀ
		//� Chamada da Funcao para montar o Browse para escolha das Classes NC  �
		//�����������������������������������������������������������������������
		If lCont
			M030BrwCla(cRevi,cTit,lBrwEns)
		EndIf

		dbSelectArea("TRB")
		Set Filter to
		oTempT:Delete()
	EndIf
EndIf   

dbSelectArea(cAlias)
Return NIL
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M030BrwEns � Autor � Marcelo Pimentel    � Data � 12/04/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta browse para a escolha dos ensaios - MarkBrowse       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � M030BrwEns(ExpC1,ExpC2,ExpC3)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Revisao                                            ���
���          � ExpC2 = Titulo da Janela                                   ���
���          � ExpC3 = Arquivo temporario ensaios (a ser criado - @)      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � qipm030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function M030BrwEns(cRevi,cTit,oTempTable)
Local oTempTable	:= NIL
Local aStru 		:= {}
Local nOpcA 		:= 0
Local lRetu 		:= .T.
Local aCpos 		:= {}
Local oMark, oDlg
Local cEnsNew		:= ''
Local cEnsBack	:= ''   

Local aEnsBack := {}

Private lInverte	:= .F.

//��������������������������������������������������������������Ŀ
//� Cria Arquivo de Trabalho                                     �
//����������������������������������������������������������������
Aadd( aStru,{ "TB_OK"   	, 	"C",02,0} )
Aadd( aStru,{ "TB_ENSAIO"	,	"C",TamSX3("QP7_ENSAIO")[1],0} )
Aadd( aStru,{ "TB_DESCRI"  ,  "C",TamSX3("QP1_DESCPO")[1],0} )

oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aStru )
oTempTable:AddIndex("indice1", {"TB_ENSAIO"} )
oTempTable:Create()

//��������������������������������������������������������������Ŀ
//� Redefinicao do acpos para utilizar no MarkBrow               �
//����������������������������������������������������������������
acpos := {{"TB_OK"		,"","  "},;
			{"TB_ENSAIO"	,"",OemToAnsi(STR0003)},;	// "Ensaio"
			{"TB_DESCRI"	,"",OemToAnsi(STR0004)}}	// "Descri��o"

//��������������������������������������������������������������Ŀ
//� Alimenta arquivo temporario dos Ensaios                      �
//����������������������������������������������������������������
// Ensaios mensuraveis
QP7->(dbSeek(xFilial("QP7")+mv_par01+cRevi))
While !QP7->(Eof()) .And. QP7->QP7_FILIAL == xFilial("QP7");
		.And. QP7->QP7_PRODUT == mv_par01 .And. QP7->QP7_REVI == cRevi

	//Filtra as Operacoes selecionadas
	If QP7->QP7_CODREC < mv_par12 .Or. QP7->QP7_CODREC > mv_par13
		QP7->(dbSkip())
		Loop
	EndIf

	//Verifica as operacoes selecionadas		
	If	QP7->QP7_OPERAC < mv_par07 .Or. QP7->QP7_OPERAC > mv_par08
		QP7->(dbSkip())
		Loop
	EndIF

	//Verifica os Laboratorios selecionados	
	If QP7->QP7_LABOR  < mv_par09 .Or. QP7->QP7_LABOR  > mv_par10
		QP7->(dbSkip())
		Loop
	EndIF
		
	cEnsNew := 	AllTrim(QP7->QP7_ENSAIO)
	If ASCAN( aEnsBack, Alltrim(cEnsNew) ) > 0
		QP7->(dbSkip())
		Loop
	EndIf
	AADD(aEnsBack, Alltrim(QP7->QP7_ENSAIO))
	RecLock("TRB",.T.)
	TRB->TB_ENSAIO	:= QP7->QP7_ENSAIO
	TRB->TB_DESCRI	:= QIPXDeEn(QP7->QP7_ENSAIO)
	QP7->(dbSkip())
EndDo

cEnsBack:= ''
cEnsNew	:= ''
aEnsBack:= {}

// Ensaios Texto
QP8->(dbSeek(xFilial("QP8")+mv_par01+cRevi))
While !QP8->(Eof()) .And. QP8->QP8_FILIAL == xFilial("QP8");
	.And. QP8->QP8_PRODUT == mv_par01 .And. QP8->QP8_REVI == cRevi
	
	//Verifica as Operacoes selecionadas
	If	QP8->QP8_OPERAC < mv_par07 .Or. QP8->QP8_OPERAC > mv_par08
		QP8->(dbSkip())
		Loop
	EndIf
	                                    
	//Verifica os Laboratorios selecionados	
	If QP8->QP8_LABOR  < mv_par09 .Or. QP8->QP8_LABOR  > mv_par10
		QP8->(dbSkip())
		Loop
	EndIF

	cEnsNew := 	AllTrim(QP8->QP8_ENSAIO)
	If ASCAN( aEnsBack, Alltrim(cEnsNew) ) > 0
		QP8->(dbSkip())
		Loop
	EndIf
	AADD(aEnsBack, Alltrim(QP8->QP8_ENSAIO))
	
	RecLock("TRB",.T.)
	TRB->TB_ENSAIO	:= QP8->QP8_ENSAIO
	TRB->TB_DESCRI	:= QIPXDeEn(QP8->QP8_ENSAIO)
	QP8->(dbSkip())
EndDo

dbSelectArea("TRB")
dbGoTop()
If BOF() .and. EOF()
	HELP(" ",1,"RECNO")         
	lRetu := .F.
Else
	While .T.
		DEFINE MSDIALOG oDlg TITLE cTit FROM 0,0 TO 350,740 TITLE STR0020 Of oMainWnd PIXEL
		
		oSize := FwDefSize():New(.T.,,,oDlg)
		oSize:AddObject( "CABECALHO",  150, 100, .T., .T. ) // Totalmente dimensionavel

		oSize:lProp 	:= .T. // Proporcional             
		oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
		
		oSize:Process() 	   // Dispara os calculos
		
		oMark := MsSelect():New("TRB","TB_OK",,acpos,lInverte,cMarca,{oSize:GetDimension("CABECALHO","LININI"),oSize:GetDimension("CABECALHO","COLINI"),;
					  														   oSize:GetDimension("CABECALHO","LINEND"),oSize:GetDimension("CABECALHO","COLEND")},,oDlg)
		oMark:oBrowse:lCanAllMark:=.T.
		oMark:oBrowse:lHasMark	 :=.T.
		oMark:bMark 			:= {| | M030Escol(cMarca,lInverte,oDlg)}
		oMark:oBrowse:bAllMark	:= {| | M030MarkAll(cMarca,oDlg)}
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||nOpcA:=0,oDlg:End()})
		If nOpcA <> 1
			lRetu := .f.
		Endif
		Exit
	EndDo
EndIf
Return(lRetu)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M030BrwCla � Autor � Marcelo Pimentel    � Data � 12/04/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta browse para a escolha das Classes de NC - MarkBrowse ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � M030BrwCla(ExpC1,ExpC2,ExpL1)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Revisao                                            ���
���          � ExpC2 = Titulo da Janela                                   ���
���          � ExpL1 = Indica se montou o Browse para escolha dos ensaios ���
�������������������������������������������������������������������������Ĵ��
���Uso       � qipm030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function M030BrwCla(cRevi,cTit,lBrwEns)
Local oTempTable	:= NIL
Local aStru 		:= {}
Local nOpcA 		:= 0
Local lRetu 		:= .F.
Local acpos 		:= {}
Local cDir			:= ""
Local oMark
Local oDlg
Local cArqTrb1

Private lInverte := .F.

//��������������������������������������������������������������Ŀ
//� Cria Arquivo de Trabalho                                     �
//����������������������������������������������������������������
Aadd( aStru,{ "TB_OK"   	, 	"C",02,0} )
Aadd( aStru,{ "TB_CLASSE"	,	"C",TamSX3("QEE_CLASSE")[1],0} )
Aadd( aStru,{ "TB_DESCRI"  ,  "C",TamSX3("QEE_DESCPO")[1],0} )

oTempTable := FWTemporaryTable():New( "TRB1" )
oTempTable:SetFields( aStru )
oTempTable:AddIndex("indice1", {"TB_CLASSE"} )
oTempTable:Create()

//��������������������������������������������������������������Ŀ
//� Redefinicao do acpos para utilizar no MarkBrow               �
//����������������������������������������������������������������
acpos := {{"TB_OK"		,"","  "},;
			{"TB_CLASSE"	,"",OemToAnsi(STR0005)},;	// "Classe NC"
			{"TB_DESCRI"	,"",OemToAnsi(STR0004)}}	// "Descri��o"

//��������������������������������������������������������������Ŀ
//� Alimenta arquivo temporario das Classes de Nao Conformidade  �
//����������������������������������������������������������������
QEE->(dbSeek(xFilial("QEE")))
While !QEE->(Eof()) .And. QEE->QEE_FILIAL == xFilial("QEE")
	RecLock("TRB1",.T.)
	TRB1->TB_CLASSE	:= QEE->QEE_CLASSE
	TRB1->TB_DESCRI	:= QEE->QEE_DESCPO
	QEE->(dbSkip())
EndDo

dbSelectArea("TRB1")
dbGoTop()
If BOF() .and. EOF()
	HELP(" ",1,"RECNO")
Else
	While .T.
		DEFINE MSDIALOG oDlg TITLE cTit From 9,0 To 23,68 OF oMainWnd
		oMark := MsSelect():New("TRB1","TB_OK",,acpos,lInverte,cMarca,{30,4,100,265})
		oMark:oBrowse:lCanAllMark:=.T.
		oMark:oBrowse:lHasMark	 :=.T.
		oMark:bMark 			:= {| | M030Esc1(cMarca,lInverte,oDlg)}
		oMark:oBrowse:bAllMark	:= {| | M030M1All(cMarca,oDlg)}
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||nOpcA:=0,oDlg:End()})
		If nOpcA == 1
			lRetu := .t.
		Endif
		Exit
	EndDo
EndIf

If lRetu
//	TRB1->(dbGoTop())
	//�����������������������������������������������������������������Ŀ
	//� Obtem o diretorio para a criacao dos arquivos de graficos (SPC) �
	//�������������������������������������������������������������������
	cDir := GetMv("MV_QDIRGRA")
			
	//��������������������������������������������������������������Ŀ
	//� Verifica se o diretorio do grafico e um  diretorio Local     �
	//����������������������������������������������������������������
	If !QA_VerQDir(cDir) 
		Return
	EndIf   
	
	//�����������������������������������Ŀ
	//� Chama a rotina que gera o Grafico �
	//�������������������������������������
	M030GerDP(cRevi,lBrwEns,cDir)
EndIf

oTempTable:Delete() //-- Deleta Arquivo Temporario Classes de NC

Return(lRetu)
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M030Marca  � Autor � Marcelo Pimentel    � Data � 12/04/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Avalia Marca.                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � qipm030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M030Marca()

dbSelectArea("TRB")
If LastKey() == K_ENTER
	RecLock(cTrb,.F.)
	TRB->TB_OK := Iif(Empty(TRB->TB_OK),cMarca," ")
	MsUnlock()
ElseIf LastKey() == K_ALT_M				// Marca todos
	dbGotop()
	While !Eof()
		RecLock("TRB",.F.)
		TRB->TB_OK := cMarca
		MsUnlock()
		dbSkip()
	EndDo
	dbGotop()
ElseIf LastKey() == K_ALT_R				// Remove todas as marcas
	dbGotop()
	While !Eof()
		RecLock("TRB",.F.)
		TRB->TB_OK := " "
		MsUnlock()
		dbSkip()
	EndDo
	dbGotop()
EndIf
Return Nil
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M030Escol  � Autor � Marcelo Pimentel    � Data �12/04/99  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Escolhe os Ensaios                                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � qipm030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M030Escol(cMarca,lInverte,oDlg)
iF IsMark("TB_OK",cMarca,lInverte)
	RecLock("TRB",.F.)
	If !lInverte
		TRB->TB_OK	:= cMarca
	Else
		TRB->TB_OK	:= "  "
	Endif
	MsUnlock()
Else
	RecLock("TRB",.F.)
	If !lInverte
		TRB->TB_OK	:= "  "
	Else
		TRB->TB_OK	:= cMarca
	Endif
	MsUnlock()
Endif
oDlg:Refresh()
Return .T.
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M030Esc1   � Autor � Marcelo Pimentel    � Data � 12/04/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Escolhe as Classes de NC                                   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � qipm030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M030Esc1(cMarca,lInverte,oDlg)
iF IsMark("TB_OK",cMarca,lInverte)
	RecLock("TRB1",.F.)
	If !lInverte
		TRB1->TB_OK	:= cMarca
	Else
		TRB1->TB_OK	:= "  "
	Endif
	MsUnlock()
Else
	RecLock("TRB1",.F.)
	If !lInverte
		TRB1->TB_OK	:= "  "
	Else
		TRB1->TB_OK	:= cMarca
	Endif
	MsUnlock()
Endif
oDlg:Refresh()
Return .T.
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M030MarkAll� Autor �Marcelo Pimentel     � Data � 12/04/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inverte os Ensaios Marcados/Desmarcados                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � qipm030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M030MarkAll(cMarca,oDlg)
LOCAL nRecno:=Recno()
dbGotop()
Do While !Eof()
	RecLock("TRB",.F.)
	If Empty(TRB->TB_OK)
		TRB->TB_OK	:= cMarca
	Else
		TRB->TB_OK	:= "  "
	Endif
	MsUnlock()
	dbSkip()
EndDo
dbGoto(nRecno)
oDlg:Refresh()
Return .T.
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M030M1All  � Autor �Marcelo Pimentel     � Data � 12/04/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inverte as Classes NC Marcadas/Desmarcadas                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � qipm030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M030M1All(cMarca,oDlg)
LOCAL nRecno:=Recno()
dbGotop()
Do While !Eof()
	RecLock("TRB1",.F.)
	If Empty(TRB1->TB_OK)
		TRB1->TB_OK	:= cMarca
	Else
		TRB1->TB_OK	:= "  "
	Endif
	MsUnlock()
	dbSkip()
EndDo
dbGoto(nRecno)
oDlg:Refresh()
Return .T.
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M030M1     � Autor � Marcelo Pimentel    � Data � 12/04/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Avalia Marca.                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � qipm030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M030M1()

dbSelectArea("TRB1")
If LastKey() == K_ENTER
	RecLock("TRB1",.F.)
	TRB1->TB_OK := Iif(Empty(TRB1->TB_OK),cMarca," ")
	MsUnlock()
ElseIf LastKey() == K_ALT_M				// Marca todos
	dbGotop()
	While !Eof()
		RecLock("TRB1",.F.)
		TRB1->TB_OK := cMarca
		MsUnlock()
		dbSkip()
	EndDo
	dbGotop()
ElseIf LastKey() == K_ALT_R				// Remove todas as marcas
	dbGotop()
	While !Eof()
		RecLock("TRB1",.F.)
		TRB1->TB_OK := " "
		MsUnlock()
		dbSkip()
	EndDo
	dbGotop()
EndIf
Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �M030GerDP � Autor � Marcelo Pimentel      � Data � 12/04/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera arquivo (SPC) para gerar o grafico                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � M030GerDP(ExpC1,ExpL1,ExpC2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Revisao do Produto                                  ���
���          � ExpL1: Indica se montou o browse para escolha dos ensaios  ���
���          � ExpC2: Diretorio para a geracao do arquivo SPC             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � qipm030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function M030GerDP(cRevi,lBrwEns,cDir)
Local aNC     := {}
Local aNcGraf := {}
Local aDados  := {}
Local aDad64  := {}
Local nPos    := 0 
Local nI      := 0
Local cArqSPC := ""
Local cReviQPK:= ""
Local cSenhas := "1"
 
QPR->(dbSetOrder(1))

// Seleciona as entregas de acordo com os parametros
QPK->(dbSetOrder(2))
QPK->(dbSeek(xFilial("QPK")+mv_par01+dtos(mv_par03), .T.))
While !QPK->(Eof()) .And. QPK->QPK_FILIAL == xFilial("QPK") .And. ;
	QPK->QPK_PRODUT == mv_par01 .And. QPK->QPK_DTPROD >= mv_par03 .And.;
	QPK->QPK_DTPROD <= mv_par04
	
	cReviQPK 	:= Iif(Empty(QPK->QPK_REVI),QA_UltRevEsp(QPK->QPK_PRODUT,,,,"QIP"),QPK->QPK_REVI) 
	
	// Seleciona as medicoes da entrega
	cChvQPR	:= (xFilial("QPR")+QPK->QPK_OP+QPK->QPK_LOTE+QPK->QPK_NUMSER)
	QPR->(dbSetOrder(9))
	QPR->(dbSeek(cChvQPR))
	
	While !QPR->(Eof()) .And. QPR->QPR_FILIAL == xFilial("QPR") .And.;
		QPR->QPR_OP+QPR->QPR_LOTE+QPR->QPR_NUMSER ==;
		QPK->QPK_OP+QPK->QPK_LOTE+QPK->QPK_NUMSER 

		// Se montou browse ensaios, verifica se escolheu este ensaio
		If lBrwEns	
			TRB->(dbSeek(QPR->QPR_ENSAIO))
			If TRB->(Eof()) .Or. Empty(TRB->TB_OK)
				QPR->(dbSkip())
				Loop
			EndIf
		EndIf

		// Verifica o Ensaiador
		If (!Empty(mv_par05) .And. QPR->QPR_ENSR < mv_par05) .Or. ;
			(!Empty(mv_par06) .And. QPR->QPR_ENSR > mv_par06)
			QPR->(dbSkip())
			Loop
		EndIf

		// Obtem chave de ligacao da medicao com os outros arquivos
		cChvMed := QPR->QPR_CHAVE

		// Verifica se a medicao apresenta NC
		If QPU->(dbSeek(xFilial("QPU")+cChvMed))
			While QPU->QPU_FILIAL+QPU->QPU_CODMED == xFilial("QPU")+cChvMed .And. !QPU->(Eof())
				// Verifica se a Classe da NC foi escolhida
				TRB1->(dbSeek(QPU->QPU_CLASSE))
				If TRB1->(Eof()) .Or. Empty(TRB1->TB_OK)
					QPU->(dbSkip())
					Loop
				EndIf

				nPos := ascan(aNC, { |x| x[1] == QPU->QPU_NAOCON })
				If nPos == 0
					// NC, Ocorrencia
					Aadd(aNC, { QPU->QPU_NAOCON, QPU->QPU_NUMNC })
				Else
					aNC[nPos][2]+= QPU->QPU_NUMNC
				EndIf
				QPU->(dbSkip())
			EndDo
		EndIf
		QPR->(dbSkip())
	EndDo
	QPK->(dbSkip())
EndDo

QPK->(dbSetOrder(1))
If Len(aNc) <> 0

	// Ordena o vetor de NCs em ordem descendente de ocorrencia de NCs
	aNC := aSort(aNC,,, { | x,y | x[2] > y[2] })
	//��������������������������������������������������������������Ŀ
	//� Gera array com as 11 NCs de maior ocorrencia, acumulando as  �
	//� demais na 12a.                                               �
	//����������������������������������������������������������������
	For nI := 1 to Len(aNC)
		If nI < 12
			// NC, Ocorrencia
			Aadd(aNcGraf, { aNC[nI,1], aNC[nI,2] })
		Elseif nI == 12
			If MV_PAR11 == 1
				Aadd(aNcGraf, { OemToAnsi(STR0009), aNC[nI,2] })  //"Outras"
			Else
			    Exit
			EndIf
		Else
			aNcGraf[12,2]+= aNC[nI,2]
		EndIf
	Next nI

	//��������������������������������������Ŀ
	//� Monta vetor com os dados do grafico  �
	//����������������������������������������
	Aadd(aDados,"QACHART.DLL - PARETO")
	
	//��������������������������������������������������������������Ŀ
	//� Ponto Entrada para impressao do titulo no grafico.           �
	//����������������������������������������������������������������
	If ExistBlock("QIPM030T")
		//�����������������Ŀ
		//� Grava o Titulo �
		//�������������������
		Aadd(aDados,"[TITLE]")
		Aadd(aDados,ExecBlock("QIPM030T",.F.,.F.))
	EndIf  
	
	Aadd(aDados,"[LANGUAGE]")
	Aadd(aDados,Upper(__Language) )

   	//��������������������������������������������������������������Ŀ
	//� Ponto Entrada para impressao do titulo no grafico.           �
	//����������������������������������������������������������������
	If ExistBlock("QIPM030F")
		//�����������������Ŀ
		//� Grava o Titulo �
		//�������������������
		Aadd(aDados,"[FOOT]")
		Aadd(aDados,ExecBlock("QIPM030F",.F.,.F.))
	EndIf
		
	Aadd(aDados,"[DADOS PARETO]")

	For nI := 1 to Len(aNcGraf)
		Aadd(aDados,AllTrim(Str(aNcGraf[nI,2]))+";"+aNcGraf[nI,1])
		Aadd(aDad64,{ AllTrim(Str( aNcGraf[nI,2])), aNcGraf[nI,1]})
	Next nI
	Aadd(aDados,"[FIM DADOS PARETO]")

	IF lExistChart 
		QIEMGRAFIC(aDad64, 2)
	Else
		// Gera o nome do arquivo SPC
		cArqSPC := M030NoArq(cDir)

		If !Empty(cArqSPC)
			//���������������������Ŀ
			//� Grava o arquivo SPC �
			//�����������������������
			lGera := GeraTxt32(aDados, cArqSPC, cDir)
			If lGera
				//��������������������������������������������������������������������������������������Ŀ
				//� Controle para abertura do grafico. Caso o grafico fique aberto por mais de 3 minutos �
				//� nao perca a conexao.																 �
				//����������������������������������������������������������������������������������������
				PtInternal(9,"FALSE")
			
				Calldll32("ShowChart",cArqSPC,"6",cDir,PARETO,Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO"))

				// Exclui o arquivo SPC gerado	
				Ferase(cDir+cArqSPC)
				PtInternal(9,"TRUE")
			EndIf
		EndIf
	EndIf
Else
	MessageDlg(OemToAnsi(STR0010),,3)	// "N�o foram encontradas N�o Conformidades, a partir dos dados solicitados."
EndIf
//��������������������������������������������������������������Ŀ
//� Restaura a Integridade dos dados                             �
//����������������������������������������������������������������
dbSelectArea("QPK")
Set Filter to
RetIndex("QPK")
dbSetOrder(1)

Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �M030NoArq � Autor � Marcelo Pimentel      � Data � 12/04/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera nome do arquivo SPC									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � qipm030													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function M030NoArq(cDir)
Local cArq	:= ""
Local nI 	:= 0
//������������������������������������������������Ŀ
//� Verifica o arquivo disponivel com extensao SPC �
//��������������������������������������������������
For nI := 1 to 99999
	cArq := "QIP" + StrZero(nI,5) + ".SPC"
	If !File(Alltrim(cDir)+cArq)
		Exit
	EndIf
Next nI
Return cArq
