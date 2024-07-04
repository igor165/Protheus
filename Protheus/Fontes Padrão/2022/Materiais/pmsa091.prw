#include "pmsa091.ch"
#include "protheus.ch"

/*/{Protheus.doc} PMSA091
Cadastro de CheckList da tarefa

@return ${return}, ${return_description}

@author Marcelo Akama
@since  05-05-2010
@version 1.0
/*/
Function PMSA091()

PRIVATE cCadastro	:= STR0001 //"Check List"
PRIVATE aRotina := MenuDef()

If AMIIn(44) .And. !PMSBLKINT()
	mBrowse(6,1,22,75,"AJQ")
EndIf

Return


/*/{Protheus.doc} PMSA091Inc
Programa de inclusao de Check List

@param cAlias, character, Alias do Arquivo
@param nReg, num�rico, Numero do registro
@param nOpc, num�rico, Numero da opcao selecionada
@return ${return}, ${return_description}

@author Marcelo Akama
@since 05/05/10
@version 1.0

/*/
Function PMSA091Inc(cAlias,nReg,nOpc)
Local aButtons	:= {}
Local aInfo		:= {}
Local aObjects	:= {}
Local aPosObj		:= {}
Local aSize		:= {}
Local cGetD		:= ".T."
Local nCont		:= 0
Local nOpca		:= 0
Local nUsado		:= 0
Local nX			:= 0
Local oDlg
Local oEnch
Local oLayer
Local oLayer1
Local oLayer2

Private aHeader	:= {}
Private aCols		:= {}
Private aTELA[0][0]
Private aGETS[0]

//�����������������������������������������������������������������������Ŀ
//� Inicializa os dados da Enchoice                                       �
//�������������������������������������������������������������������������
RegToMemory( "AJQ", .T., .T. )
//�����������������������������������������������������������������������Ŀ
//� Montagem do aheader                                                   �
//�������������������������������������������������������������������������
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("AJN")
Do While !Eof() .And. SX3->X3_ARQUIVO=="AJN"
	If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
		nUsado++
		Aadd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE ,;
			SX3->X3_TAMANHO ,;
			SX3->X3_DECIMAL ,;
			SX3->X3_VALID	,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_ARQUIVO ,;
			SX3->X3_CONTEXT } )
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo
//�����������������������������������������������������������������������Ŀ
//� Montagem do acols                                                     �
//�������������������������������������������������������������������������
aadd(aCols,Array(nUsado+1))
For nX := 1 To nUsado
	If Trim(aHeader[nX][2]) == "AJN_ORDEM"
		aCols[1][nX] := StrZero(1,TamSX3("AJN_ORDEM")[1])
	Else
		aCols[1][nX] := CriaVar(aHeader[nX][2])
	EndIf
Next nX
aCols[1][nUsado+1] := .F.

//�����������������������������������������������������������������������Ŀ
//� Calculo do tamanho dos objetos                                        �
//�������������������������������������������������������������������������
aSize := MsAdvSize()

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

oLayer := FwLayer():New()
	
oLayer:init(oDlg,.F.)
		
oLayer:addLine("MGET", 20, .F.)
oLayer:addLine("GETDADOS", 80, .F.)
		
oLayer1 := oLayer:getLinePanel("MGET")
oLayer2 := oLayer:getLinePanel("GETDADOS") 

oEnch := MsMGet():New("AJQ", nReg, nOpc, , , , ,,/*{"AJQ_CODIGO","AJQ_DESCRI"}*/,3,,,,oLayer1)
oEnch:oBox:Align := CONTROL_ALIGN_TOP

oGetD:=MsGetDados():New(1,2,2,2,nOpc,"PMSA091LOk","PMSA091TOk","+AJN_ORDEM",.T.,,1,,999,"PMSA091FOk",,,,oLayer2)
oGetD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
cGetD:= cGetD + " .and. oGetD:TudoOk()"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(.T.,If( !Obrigatorio(aGets,aTela) .Or. !(&(cGetD)),nOpcA:=0,oDlg:End()),nOpcA:=0)},{||oDlg:End()},,aButtons) CENTERED

If nOpcA == 1
	BEGIN TRANSACTION

		GrvChkLst(1)

	END TRANSACTION
EndIF

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PMSA091Alt� Autor � Marcelo Akama         � Data � 05/05/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de alteracao de Check List                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PMSA091Alt(cAlias,nReg,nOpc)                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PMSA091                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do Arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PMSA091Alt(cAlias,nReg,nOpc)
Local nOpcA := 0
Local aSize     := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local aRegNo    := {}
Local oDlg
Local nUsado    := 0
Local nX        := 0
Local cGetD     := ".T."
local aButtons  := {}
Local oLayer
Local oLayer1
Local oLayer2
Local oEnch

Private aHeader := {}
Private aCols   := {}
Private aTELA[0][0]
Private aGETS[0]

dbSelectArea(cAlias)
dbSetOrder(1)
If !SoftLock(cAlias)
	Return
EndIf

//�����������������������������������������������������������������������Ŀ
//� Inicializa os dados da Enchoice                                       �
//�������������������������������������������������������������������������
RegToMemory( "AJQ", .F., .T. )

//�����������������������������������������������������������������������Ŀ
//� Montagem do aheader                                                   �
//�������������������������������������������������������������������������
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("AJN")
Do While !Eof() .And. SX3->X3_ARQUIVO=="AJN"
	If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
		nUsado++
		Aadd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE ,;
			SX3->X3_TAMANHO ,;
			SX3->X3_DECIMAL ,;
			SX3->X3_VALID	,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_ARQUIVO ,;
			SX3->X3_CONTEXT } )
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo

//�����������������������������������������������������������������������Ŀ
//� Montagem do acols                                                     �
//�������������������������������������������������������������������������
dbSelectArea("AJM")
dbSetOrder(1)
dbSelectArea("AJN")
dbSetOrder(3) //AJN_FILIAL+AJN_CODIGO+AJN_ORDEM+AJN_ITEM
MsSeek(xFilial("AJN")+M->AJQ_CODIGO)
Do While !Eof() .And. xFilial("AJN") == AJN->AJN_FILIAL .And. M->AJQ_CODIGO == AJN->AJN_CODIGO
	AJM->(MsSeek(xFilial("AJM")+AJN->AJN_ITEM))
	AADD(aCols,Array(nUsado+1))
	For nX := 1 To nUsado
		If aHeader[nX][10]=="V"
			Do Case
				Case AllTrim(aHeader[nX][2]) == "AJN_DESCRI"
					aCols[Len(aCols)][nX] := AJM->AJM_DESCRI
				Otherwise
					aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2])
			EndCase
		Else
			aCols[Len(aCols)][nX] := AJN->(FieldGet(FieldPos(aHeader[nX][2])))
		EndIf
	Next nX
	aCols[Len(aCols)][nUsado+1] := .F.
	AADD(aRegNo,AJN->(RecNo()))
	dbSelectArea("AJN")
	dbSkip()
EndDo
If Empty(aCols)
	AADD(aCols,Array(nUsado+1))
	For nX := 1 To nUsado
		If Trim(aHeader[nX][2]) == "AJN_ORDEM"
			aCols[1][nX] := StrZero(1,TamSX3("AJN_ORDEM")[1])
		Else
			aCols[1][nX] := CriaVar(aHeader[nX][2])
		EndIf
	Next nX
	aCols[Len(aCols)][nUsado+1] := .F.
EndIf

//�����������������������������������������������������������������������Ŀ
//� Calculo do tamanho dos objetos                                        �
//�������������������������������������������������������������������������
aSize := MsAdvSize()

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

oLayer := FwLayer():New()
	
oLayer:init(oDlg,.F.)
		
oLayer:addLine("MGET", 20, .F.)
oLayer:addLine("GETDADOS", 80, .F.)
		
oLayer1 := oLayer:getLinePanel("MGET")
oLayer2 := oLayer:getLinePanel("GETDADOS") 

oEnch := MsMGet():New("AJQ", nReg, nOpc, , , , ,,/*{"AJQ_CODIGO","AJQ_DESCRI"}*/,3,,,,oLayer1)
oEnch:oBox:Align := CONTROL_ALIGN_TOP

oGetD:=MsGetDados():New(1,2,2,2,nOpc,"PMSA091LOk","PMSA091TOk","+AJN_ORDEM",.T.,,1,,999,"PMSA091FOk",,,,oLayer2)
oGetD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
cGetD:= cGetD + " .and. oGetD:TudoOk()"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(.T.,If(!Obrigatorio(aGets,aTela) .Or. !(&(cGetD)),nOpcA:=0,oDlg:End()),nOpcA:=0)},{||oDlg:End()},,aButtons) CENTERED

If nOpcA == 1
	BEGIN TRANSACTION
	GrvChkLst(2,aRegNo)
	END TRANSACTION
Endif

MsUnlockAll()

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PMSA091Del� Autor � Marcelo Akama         � Data �05.05.2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Exclusao do Check List                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PMSA091Del(cAlias,nReg,nOpc)                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PMSA091                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do Arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PMSA091Del(cAlias,nReg,nOpc)

Local lRet		:= .T.
Local oDlg
LOCAL nOpcA 	:= 0
Local nOrder 	:= IndexOrd()
Local i
Local aSize     := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local aRegNo    := {}
Local nUsado    := 0
Local nX        := 0
Local aButtons  := {}
Local oLayer
Local oLayer1
Local oLayer2
Local oEnch 

Private aHeader := {}
Private aCols   := {}
Private aTELA[0][0]
Private aGETS[0]

dbSelectArea(cAlias)
dbSetOrder(1)

If !SoftLock(cAlias)
	Return
EndIf

//�����������������������������������������������������������������������Ŀ
//� Inicializa os dados da Enchoice                                       �
//�������������������������������������������������������������������������
RegToMemory( "AJQ", .F., .T. )
//�����������������������������������������������������������������������Ŀ
//� Montagem do aheader                                                   �
//�������������������������������������������������������������������������
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("AJN")
Do While !Eof() .And. SX3->X3_ARQUIVO=="AJN"
	If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
		nUsado++
		Aadd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE ,;
			SX3->X3_TAMANHO ,;
			SX3->X3_DECIMAL ,;
			SX3->X3_VALID	,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_ARQUIVO ,;
			SX3->X3_CONTEXT } )
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo

//�����������������������������������������������������������������������Ŀ
//� Montagem do acols                                                     �
//�������������������������������������������������������������������������
dbSelectArea("AJM")
dbSetOrder(1)
dbSelectArea("AJN")
dbSetOrder(3) //AJN_FILIAL+AJN_CODIGO+AJN_ORDEM+AJN_ITEM
MsSeek(xFilial("AJN")+M->AJQ_CODIGO)
Do While !Eof() .And. xFilial("AJN") == AJN->AJN_FILIAL .And. M->AJQ_CODIGO == AJN->AJN_CODIGO
	AJM->(MsSeek(xFilial("AJM")+AJN->AJN_ITEM))
	AADD(aCols,Array(nUsado+1))
	For nX := 1 To nUsado
		If aHeader[nX][10]=="V"
			Do Case
				Case AllTrim(aHeader[nX][2]) == "AJN_DESCRI"
					aCols[Len(aCols)][nX] := AJM->AJM_DESCRI
				Otherwise
					aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2])
			EndCase
		Else
			aCols[Len(aCols)][nX] := AJN->(FieldGet(FieldPos(aHeader[nX][2])))
		EndIf
	Next nX
	aCols[Len(aCols)][nUsado+1] := .F.
	aadd(aRegNo,AJN->(RecNo()))
	dbSelectArea("AJN")
	dbSkip()
EndDo

If Empty(aCols)
	aadd(aCols,Array(nUsado+1))
	For nX := 1 To nUsado
		If Trim(aHeader[nX][2]) == "AJN_ORDEM"
			aCols[1][nX] := StrZero(1,TamSX3("AJN_ORDEM")[1])
		Else
			aCols[1][nX] := CriaVar(aHeader[nX][2])
		EndIf
	Next nX
	aCols[Len(aCols)][nUsado+1] := .F.
EndIf

//�����������������������������������������������������������������������Ŀ
//� Calculo do tamanho dos objetos                                        �
//�������������������������������������������������������������������������
aSize := MsAdvSize()

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

oLayer := FwLayer():New()
	
oLayer:init(oDlg,.F.)
		
oLayer:addLine("MGET", 20, .F.)
oLayer:addLine("GETDADOS", 80, .F.)
		
oLayer1 := oLayer:getLinePanel("MGET")
oLayer2 := oLayer:getLinePanel("GETDADOS") 

oEnch := MsMGet():New("AJQ", nReg, nOpc, , , , ,,/*{"AJQ_CODIGO","AJQ_DESCRI"}*/,3,,,,oLayer1)
oEnch:oBox:Align := CONTROL_ALIGN_TOP

oGetD:=MsGetDados():New(1,2,2,2,nOpc,"PMSA091LOk","PMSA091TOk","+AJN_ORDEM",.T.,,1,,999,"PMSA091FOk",,,,oLayer2)
oGetD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
cGetD:="oGetD:TudoOk()"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=2,oDlg:End()},{||nOpca := 1,oDlg:End()},,aButtons) CENTERED

If nOpcA == 2
	MsGoTo( nReg )

	BEGIN TRANSACTION

	//������������������������������������������������������Ŀ
	//� Apaga Itens										     �
	//��������������������������������������������������������
	dbSelectArea("AJN")
	DbSetOrder(1)
	dbSeek(xFilial("AJN")+AJQ->AJQ_CODIGO)
	Do While !AJN->(Eof()) .And. AJN->AJN_CODIGO == AJQ->AJQ_CODIGO
		Reclock("AJN",.F.,.T.)
		dbDelete()
		MsUnLock()
		dbSkip()
	EndDo

	//������������������������������������������������������Ŀ
	//� Apaga Conta no Arquivo de Cadastro					 �
	//��������������������������������������������������������
	dbSelectArea("AJQ")
	MsGoTo( nReg )
	RecLock("AJQ")
	dbDelete()
	MsUnLock()

	END TRANSACTION
EndIf

MsUnlockAll()

dbSelectArea(cAlias)
dbSetOrder(nOrder)
dbGoTo(nReg)

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PMSA091Vis� Autor � Marcelo Akama         � Data �05.05.2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Visualizacao do Check List                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PMSA091Vis(cAlias,nReg,nOpc)                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PMSA091                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do Arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PMSA091Vis(cAlias,nReg,nOpc)
Local nOpcA := 0
Local aSize     := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local aRegNo    := {}
Local oDlg
Local nUsado    := 0
Local nX        := 0
Local cGetD     := ".T."
Local aButtons  := {}
Local oLayer
Local oLayer1
Local oLayer2
Local oEnch

Private aHeader := {}
Private aCols   := {}
Private aTELA[0][0]
Private aGETS[0]

dbSelectArea(cAlias)
dbSetOrder(1)

//�����������������������������������������������������������������������Ŀ
//� Inicializa os dados da Enchoice                                       �
//�������������������������������������������������������������������������
RegToMemory( "AJQ", .F., .T. )

//�����������������������������������������������������������������������Ŀ
//� Montagem do aheader                                                   �
//�������������������������������������������������������������������������
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("AJN")
Do While !Eof() .And. SX3->X3_ARQUIVO=="AJN"
	If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
		nUsado++
		Aadd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE ,;
			SX3->X3_TAMANHO ,;
			SX3->X3_DECIMAL ,;
			SX3->X3_VALID	,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_ARQUIVO ,;
			SX3->X3_CONTEXT } )
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo

//�����������������������������������������������������������������������Ŀ
//� Montagem do acols                                                     �
//�������������������������������������������������������������������������
dbSelectArea("AJM")
dbSetOrder(1)
dbSelectArea("AJN")
dbSetOrder(3) //AJN_FILIAL+AJN_CODIGO+AJN_ORDEM+AJN_ITEM
MsSeek(xFilial("AJN")+M->AJQ_CODIGO)
Do While !Eof() .And. xFilial("AJN") == AJN->AJN_FILIAL .And. M->AJQ_CODIGO == AJN->AJN_CODIGO
	AJM->(MsSeek(xFilial("AJM")+AJN->AJN_ITEM))
	AADD(aCols,Array(nUsado+1))
	For nX := 1 To nUsado
		If aHeader[nX][10]=="V"
			Do Case
				Case AllTrim(aHeader[nX][2]) == "AJN_DESCRI"
					aCols[Len(aCols)][nX] := AJM->AJM_DESCRI
				Otherwise
					aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2])
			EndCase
		Else
			aCols[Len(aCols)][nX] := AJN->(FieldGet(FieldPos(aHeader[nX][2])))
		EndIf
	Next nX
	aCols[Len(aCols)][nUsado+1] := .F.
	aadd(aRegNo,AJN->(RecNo()))
	dbSelectArea("AJN")
	dbSkip()
EndDo

If Empty(aCols)
	aadd(aCols,Array(nUsado+1))
	For nX := 1 To nUsado
		If Trim(aHeader[nX][2]) == "AJN_ORDEM"
			aCols[1][nX] := StrZero(1,TamSX3("AJN_ORDEM")[1])
		Else
			aCols[1][nX] := CriaVar(aHeader[nX][2])
		EndIf
	Next nX
	aCols[Len(aCols)][nUsado+1] := .F.
EndIf

//�����������������������������������������������������������������������Ŀ
//� Calculo do tamanho dos objetos                                        �
//�������������������������������������������������������������������������
aSize := MsAdvSize()

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

oLayer := FwLayer():New()
	
oLayer:init(oDlg,.F.)
		
oLayer:addLine("MGET", 20, .F.)
oLayer:addLine("GETDADOS", 80, .F.)
		
oLayer1 := oLayer:getLinePanel("MGET")
oLayer2 := oLayer:getLinePanel("GETDADOS") 

oEnch := MsMGet():New("AJQ", nReg, nOpc, , , , ,,/*{"AJQ_CODIGO","AJQ_DESCRI"}*/,3,,,,oLayer1)
oEnch:oBox:Align := CONTROL_ALIGN_TOP

oGetD:=MsGetDados():New(1,2,2,2,nOpc,"PMSA091LOk","PMSA091TOk","+AJN_ORDEM",.T.,,1,,999,"PMSA091FOk",,,,oLayer2)
oGetD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
cGetD:="oGetD:TudoOk()"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(.T.,If(!Obrigatorio(aGets,aTela) .Or. !(&(cGetD)),nOpcA:=0,oDlg:End()),nOpcA:=0)},{||oDlg:End()},,aButtons) CENTERED

Return



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �GrvChkLst � Autor � Marcelo Akama         � Data �05.05.2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de gravacao do check list                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Sempre .T.                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1: 1 - Inclusao                                         ���
���          �       2 - Alteracao                                        ���
���          �       3 - Exclusao                                         ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function GrvChkLst(nOpcA,aRegNo)

Local aArea    := GetArea("AJN")
Local nX       := 0
Local nY       := 0
Local nMaxFor  := Len(aCols)
Local nDeleted := Len(aHeader)+1
Local nPOrd    := aScan(aHeader,{|x| AllTrim(x[2])=="AJN_ORDEM"})
Local nPIte    := aScan(aHeader,{|x| AllTrim(x[2])=="AJN_ITEM"})
Local bCampo   := {|nCPO| Field(nCPO) }
Local lTravou  := .F.

DEFAULT aRegNo := {}
//���������������������������������������������������������������Ŀ
//� Verifica a operacao                                           �
//�����������������������������������������������������������������
If nOpcA <> 3
	//���������������������������������������������������������������Ŀ
	//� Grava o cabecalho                                             �
	//�����������������������������������������������������������������
	dbSelectArea("AJQ")
	dbSetOrder(1)
	If MsSeek(xFilial("AJQ")+M->AJQ_CODIGO)
		RecLock("AJQ")
	Else
		RecLock("AJQ",.T.)
	EndIf

	For nY := 1 TO FCount()
		FieldPut(nY,M->&(EVAL(bCampo,nY)))
	Next nY
	AJQ->AJQ_FILIAL := xFilial("AJQ")

	AJQ->( FKCommit() )

	//���������������������������������������������������������������Ŀ
	//� Grava os itens                                                �
	//�����������������������������������������������������������������
	For nX := 1 To nMaxFor
		If ( Len(aRegNo) >= nX )
			dbSelectArea("AJN")
			MsGoto(aRegNo[nX])
			RecLock("AJN")
			lTravou := .T.
		Else
			If ( !aCols[nX][nDeleted] .And. !Empty(aCols[nX][nPOrd]) .And. !Empty(aCols[nX][nPIte]) )
				RecLock("AJN",.T.)
				lTravou := .T.
			Else
				lTravou := .F.
			EndIf
		EndIf
		If ( aCols[nX][nDeleted] )
			If lTravou
				dbSelectArea("AJN")
				dbDelete()
				MsUnLock()
			EndIf
		Else
			If lTravou
				//������������������������������������������������������������������������Ŀ
				//�Atualiza os itens                                                       �
				//��������������������������������������������������������������������������
				For nY := 1 to Len(aHeader)
					If aHeader[nY][10] <> "V"
						AJN->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
					EndIf
				Next nY
				AJN->AJN_FILIAL := xFilial("AJN")
				AJN->AJN_CODIGO := M->AJQ_CODIGO
			EndIf
		EndIf
	Next nX
Else

	//���������������������������������������������������������������Ŀ
	//�Exclucao dos itens                                             �
	//�����������������������������������������������������������������
	For nX := 1 To nMaxFor
		If ( Len(aRegNo) >= nX )
			dbSelectArea("AJN")
			MsGoto(aRegNo[nX])
			RecLock("AJN")
			dbDelete()
			MsUnlock()
		EndIf
	Next nX
	AJN->( FKCommit() )
	dbSelectArea("AJQ")
	dbSetOrder(1)
	If MsSeek(xFilial("AJQ")+M->AJQ_CODIGO)
		RecLock("AJQ")
		dbDelete()
		MsUnLock()
	EndIf

EndIf
//���������������������������������������������������������������Ŀ
//�Restaura a integridade da rotina                               �
//�����������������������������������������������������������������
RestArea(aArea)
Return(.T.)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PMSA091LOk� Autor � Marcelo Akama         � Data �05.05.2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de validacao da linhaOk da Getdados                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Expl1: Indica se a linha � valida                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PMSA091LOk()

Local nX        :=  1
Local nUsado    := Len(aHeader)
Local nPOrd     := aScan(aHeader,{|x| AllTrim(x[2])=="AJN_ORDEM"})
Local nPIte     := aScan(aHeader,{|x| AllTrim(x[2])=="AJN_ITEM"})
Local lRetorno  := .T.

//�����������������������������������������������������������������������Ŀ
//� Verifica os campo obrigatorios                                        �
//�������������������������������������������������������������������������
lRetorno := MaCheckCols(aHeader,aCols,N)
If !aCols[n][nUsado+1] .And. (!Empty(aCols[n][nPOrd]) .Or. !Empty(aCols[n][nPIte]))
	If Empty(aCols[n][nPOrd]) .Or. Empty(aCols[n][nPIte])
		Help(" ",1,STR0007,STR0008,STR0009,3,1) //"HELP"##"OBRIGATORIO"##"Favor preencher todos os campos obrigatorios."
		lRetorno := .F.
	EndIf
EndIf

//�����������������������������������������������������������������������Ŀ
//� Verifica a duplicidade de registros                                   �
//�������������������������������������������������������������������������
If lRetorno
	For nX := 1 To Len(aCols)
		If !aCols[nX][nUsado+1]  .And. !aCols[n][nUsado+1]
			If nX <> N
				// Valida se existe outra ordem igual
				If (aCols[n][nPOrd] == aCols[nX][nPOrd])
					Help(" ",1,"JAEXISTINF")
					lRetorno := .F.
				EndIf
			EndIf
		EndIf
	Next nX
EndIf

Return(lRetorno)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PMSA091FOk� Autor � Marcelo Akama         � Data �05.05.2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de validacao do campoOk da Getdados                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Expl1: Indica se o campo e valido                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PMSA091FOk()

Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PMSA091TOk� Autor � Marcelo Akama         � Data �05.05.2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de validacao do cTudoOk da Getdados                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Expl1: Indica se o o conte�do dos campos s�o v�lidos        ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PMSA091TOk()

Local nColOrd  := aScan(aHeader,{|x|Alltrim(x[2])=="AJN_ORDEM" })
Local nColIte  := aScan(aHeader,{|x|Alltrim(x[2])=="AJN_ITEM" })
Local nUsado   := Len(aHeader)
Local nLinPos  := 1
Local lRetorno := .T.
Local nX

For nX := 1 to Len(aCols)
	n	:= nX
	If !(aCols[n][Len(aHeader)+1]) .And. !Empty(aCols[n][nColOrd]) .Or. !Empty(aCols[n][nColIte])
		If !PMSA091LOk()
			lRetorno := .F.
			Exit
		EndIf
	EndIf
Next

Return(lRetorno)


/*/{Protheus.doc} MenuDef
Utilizacao de menu Funcional

@return ${return}, ${return_description}

@author Ana Paula N. Silva
@since 30/11/06
@version 1.0
@obs
Parametros do array a Rotina:
	1. Nome a aparecer no cabecalho
	2. Nome da Rotina associada
	3. Reservado
	4. Tipo de Transa��o a ser efetuada:
		1 - Pesquisa e Posiciona em um Banco de Dados
		2 - Simplesmente Mostra os Campos
		3 - Inclui registros no Bancos de Dados
		4 - Altera o registro corrente
		5 - Remove o registro corrente do Banco de Dados
	5. Nivel de acesso
	6. Habilita Menu Funcional

/*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002, "AxPesqui"  , 0 , 1,,.F.},; //"Pesquisar"
						{ STR0003, "PMSA091Vis", 0 , 2},;	 //"Visualizar"
						{ STR0004, "PMSA091Inc", 0 , 3},;	 //"Incluir"
						{ STR0005, "PMSA091Alt", 0 , 4},;	 //"Alterar"
						{ STR0006, "PMSA091Del", 0 , 5} } //"Excluir"
Return(aRotina)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �PA091VldTrf� Autor � Totvs                � Data � 30/11/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica se existe mais de um checklist por tipo de tarefa. ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Retorna True se nao existir a amarracao                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PA091VldTrf()
Local aArea		:= GetArea()
Local aAreaAJQ	:= AJQ->( GetArea() )
Local cCodigo	:= M->AJQ_CODIGO
Local cCodTrf	:= &( ReadVar() )
Local lRet		:= .T.

DbSelectArea( "SIX" )
DbSetOrder(1)

DbSelectArea( "AJQ" )
If SIX->(dbSeek("AJQ2"))
	AJQ->( DbSetOrder( 2 ) )
	AJQ->( DbSeek( xFilial( "AJQ" ) + cCodTrf ) )
	Do While AJQ->( !Eof() ) .And. AJQ->AJQ_FILIAL == xFilial( "AJQ" ) .And. AJQ->AJQ_TIPTAR == cCodTrf
		If AJQ->AJQ_CODIGO <> cCodigo
			lRet := .F.
		EndIf
		AJQ->( DbSkip() )
	EndDo
Else
	AJQ->( DbSetOrder( 1 ) )
	AJQ->( DbSeek( xFilial( "AJQ" ) ) )
	Do While AJQ->( !Eof() ) .AND. AJQ->AJQ_FILIAL == xFilial( "AJQ" )
		If AJQ->AJQ_CODIGO <> cCodigo
			If AJQ->AJQ_TIPTAR == cCodTrf
				lRet := .F.
			EndIf
		EndIf
		AJQ->( DbSkip() )
	EndDo
EndIf

If !lRet
	Help( " ", 1, STR0007, STR0010, STR0011, 3, 1 ) //"DUPLICADO"##"O tipo de tarefa informado j� foi vinculado � um checklist!"
EndIf

RestArea( aAreaAJQ )
RestArea( aArea )
Return lRet
