#INCLUDE "PCOA520.ch"
#include "PROTHEUS.ch"

Static nNumLin := Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PCOA520  � Autor � Edson Maricate        � Data �13.10.1998���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grupos de Aprovacao                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Ajustes: Jamer Nunes - 21/12/2020                                     ���
���                                                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOA520()

PRIVATE nPosNomeUsr
PRIVATE  aAC :=  { STR0006,STR0007 },;			//"Abandona"###"Confirma" //"Abandona"###"Confirma"
aCRA:=  { STR0007,STR0008,STR0006 } //"Confirma"###"Redigita"###"Abandona"


//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
PRIVATE aRotina := MenuDef()

PRIVATE cCadastro := OemToAnsi(STR0009)  //"Grupos de Aprovacao"

DefNumlin()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("ALM")
dbSetOrder(1)

mBrowse(6,1,22,75,"ALM")

dbSelectArea("ALM")
dbSetOrder(1)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOA520INC� Autor � Edson Maricate        � Data �13.10.1998���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de inclusao de grupos aprovadores.                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void PCOA510INC(ExpC1,ExpN1)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOA520INC(cAlias,nReg,nOpcx)
LOCAL bCampo
LOCAL lGravaOK := .T.
LOCAL oDlg, oGet,oReq,oComp
Local aSizeAut		:= MsAdvSize(,.F.)   
Local aObjects		:= {}
Local aInfo 		:= {}
Local aPosObj		:= {}
Local oSize`
Local nX			:= 0
Local nY			:= 0

PRIVATE 	cSolic , dA110Data := dDataBase, nOpca := 0

//��������������������������������������������������������������Ŀ
//� Inicializa o numero com o ultimo + 1                         �
//����������������������������������������������������������������
dbSelectArea("ALM")
dbSetOrder(1)
nSavReg  := RecNo()
M->ALM_COD	:= CRIAVAR("ALM_COD")
M->ALM_DESC	:= CRIAVAR("ALM_DESC")

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private aTELA[0][0],aGETS[0],aHeader[0],Continua,nUsado:=0
bCampo := {|nCPO| Field(nCPO) }

//��������������������������������������������������������������Ŀ
//� ZU5va a integridade dos campos de Bancos de Dados            �
//����������������������������������������������������������������
dbSelectArea("SX3")
SX3->(dbSetOrder(1))
dbSeek( cAlias )
While !EOF() .And. (x3_arquivo == cAlias)
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. Trim(x3_campo) != "ALM_DESC";
		.And. !(Trim(x3_campo)$"ALM_COD")
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
		If AllTrim(x3_campo)=="ALM_USER"
			aHeader[Len(aHeader), 6] := "Pco_Vld_User()"
		EndIf
	Endif
	dbSkip()
End

nPosNomeUsr := Ascan(aHeader, {|x| alltrim(x[2]) == "ALM_NOME"})

PRIVATE aCOLS[1][nUsado+1]
dbSelectArea("SX3")
dbSeek( cAlias )
nUsado:=0
While !EOF() .And. (x3_arquivo == cAlias)
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. Trim(x3_campo) != "ALM_DESC";
		.And. !(Trim(x3_campo)$"ALM_COD")
		nUsado++
		If Trim(aHeader[nUsado][2]) == "ALM_ITEM"
			aCOLS[1][nUsado] := Repl("0",x3_tamanho-1)+"1"
		Else
			aCOLS[1][nUsado] := CriaVar(x3_campo)
		Endif
	Endif
	dbSkip()
End

aCOLS[1][nUsado+1] := .F.

Continua := .F.
nOpca := 0
AAdd( aObjects, { 0,    25, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects )
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0009) From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL // "Grupos de Aprovacao"

oSize := FwDefSize():New(.T.,,,oDlg)
oSize:AddObject( "CABECALHO",  100, 100, .T., .T. ) // Totalmente dimensionavel

oSize:lProp 	:= .T. // Proporcional             
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
oSize:Process() 	   // Dispara os calculos 

nX:= oSize:GetDimension("CABECALHO","LININI")
nY:= oSize:GetDimension("CABECALHO","COLINI")

@ nX  ,nY+10 SAY OemToAnsi(STR0010) OF oDlg PIXEL //"&C�digo"
@ nX  ,nY+40 MSGET M->ALM_COD  Picture "@!" F3 "AKJ" Valid !Empty(M->ALM_COD) .And.;
 A520VLDCPO(M->ALM_COD) When VisualSX3("ALM_COD") OF oDlg PIXEL SIZE 30,10 RIGHT
@ nX  ,nY+80 SAY OemToAnsi(STR0011) OF oDlg PIXEL  //"&Descricao"
@ nX  ,nY+120 MSGET M->ALM_DESC  Picture "@!"   Valid CheckSX3("ALM_DESC") When VisualSX3("ALM_DESC") OF oDlg PIXEL 

oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"PCOA520LOk","AllwaysTrue()","+ALM_ITEM",.T.,,,,nNumLin,,,,)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(Obrigatorio(aGets,aTela) .And. oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})

If nOpcA == 1
	Begin Transaction
	lGravaOk := PCOA520GRV(cAlias)
	If !lGravaOk
		Help(" ",1,"A085NAOREG")
	Else
		EvalTrigger()
	EndIf
	End Transaction
Endif 

dbSelectArea(cAlias)

Return nOpca

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOA520ALT� Autor � Edson Maricate        � Data �13.10.1998���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de inclusao de grupos aprovadores.                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void PCOA520ALT(ExpC1,ExpN1)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOA520ALT(cAlias,nReg,nOpcx)
LOCAL bCampo
LOCAL lGravaOK := .T.
LOCAL oDlg, oGet,oReq,oComp
LOCAL nAcols := 0
Local nCntFor:= 0
Local aSizeAut		:= MsAdvSize(,.F.)   
Local aObjects		:= {}
Local aInfo 		:= {}
Local aPosObj		:= {}
Local nX			:= 0
Local nY			:= 0
Local oSize

PRIVATE 	cSolic , dA110Data := dDataBase, nOpca := 0,aCols:={}

If nNumLin == Nil
	nNumLin := GetNewPar( 'MV_PCO520L' , 99 )

	If Valtype( nNumLin ) <> 'N'
		nNumLin := 99
	Endif
Endif

dbSelectArea("ALM")
nSavReg  := RecNo()
M->ALM_COD 		:= ALM->ALM_COD
M->ALM_DESC 	:= ALM->ALM_DESC
M->ALM_USER 	:= "" //Inicializo a vari�vel, evitando ocorr�ncia de erro no inicializador padr�o

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private aTELA[0][0],aGETS[0],aHeader[0],Continua,nUsado:=0
bCampo := {|nCPO| Field(nCPO) }

//��������������������������������������������������������������Ŀ
//� ZU5va a integridade dos campos de Bancos de Dados            �
//����������������������������������������������������������������
dbSelectArea("SX3")
dbSeek( cAlias )
While !EOF() .And. (x3_arquivo == cAlias)
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. Trim(x3_campo) != "ALM_DESC";
		.And. !(Trim(x3_campo)$"ALM_COD")
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
		If AllTrim(x3_campo)=="ALM_USER"
			aHeader[Len(aHeader), 6] := "Pco_Vld_User()"
		EndIf
	Endif
	dbSkip()
End

nPosNomeUsr := Ascan(aHeader, {|x| alltrim(x[2]) == "ALM_NOME"})

dbSelectArea("ALM")
dbSeek(xFilial("ALM")+ALM_COD)

While !Eof() .And. ALM_FILIAL+ALM_COD == xFilial("ALM")+M->ALM_COD
	aadd(aCols,Array(nUsado+1))
	nAcols ++
	For nCntFor := 1 To nUsado
		If ( aHeader[nCntFor][10] != "V")
			aCols[nAcols][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
		Else
			aCols[nAcols][nCntFor] := CriaVar(aHeader[nCntFor][2])
		EndIf
	Next nCntFor
	aCols[nAcols][nUsado+1] := .F.
	dbSkip()
EndDo

Continua := .F.
nOpca := 0
AAdd( aObjects, { 0,    25, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects )
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0009) From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL // "Grupos de Aprovacao"

oSize := FwDefSize():New(.T.,,,oDlg)
oSize:AddObject( "CABECALHO",  100, 25, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "GETDADOS" ,  100, 75, .T., .T. ) // Totalmente dimensionavel 
oSize:lProp 	:= .T. // Proporcional             
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
oSize:Process() 	   // Dispara os calculos 

nX  := oSize:GetDimension("CABECALHO","LININI")
nY := oSize:GetDimension("CABECALHO","COLINI")

@ nX  ,nY+10 SAY OemToAnsi(STR0010) OF oDlg PIXEL //"&C�digo"
@ nX  ,nY+40 MSGET M->ALM_COD  Picture "@!" When .F. OF oDlg PIXEL SIZE 30,10 RIGHT
@ nX  ,nY+80 SAY OemToAnsi(STR0011) OF oDlg PIXEL  //"&Descricao"
@ nX  ,nY+120 MSGET M->ALM_DESC  Picture "@!"   Valid CheckSX3("ALM_DESC") When VisualSX3("ALM_DESC") OF oDlg PIXEL 
oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"PCOA520LOk","AllwaysTrue()","+ALM_ITEM",.T.,,,,nNumLin,,,,)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})

If nOpcA == 1
	Begin Transaction
	lGravaOk := PCOA520GRV(cAlias)
	If !lGravaOk
		Help(" ",1,"A085NAOREG")
	Else
		EvalTrigger()
	EndIf
	End Transaction
Endif

dbSelectArea(cAlias)

Return nOpca

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOA520DEL� Autor � Edson Maricate        � Data �13.10.1998���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Delecao de grupos aprovadores.                 ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void PCOA520DEL(ExpC1,ExpN1)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOA520DEL(cAlias,nReg,nOpcx)
LOCAL bCampo
LOCAL lGravaOK := .T.
LOCAL oDlg, oGet,oReq,oComp
LOCAL nAcols := 0
Local nCntFor:= 0
LOCAL nOpc   := 0
Local nX     := 0
Local aSizeAut		:= MsAdvSize(,.F.)   
Local aObjects		:= {}
Local aInfo 		:= {}
Local aPosObj		:= {}
Local nX			:= 0
Local nY			:= 0
Local oSize

PRIVATE 	cSolic , dA110Data := dDataBase ,nOpca := 0,aCols:={}

dbSelectArea("ALM")
M->ALM_COD 		:= ALM->ALM_COD
M->ALM_DESC 	:= ALM->ALM_DESC
nSavReg  := RecNo()

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private aTELA[0][0],aGETS[0],aHeader[0],Continua,nUsado:=0
bCampo := {|nCPO| Field(nCPO) }

//��������������������������������������������������������������Ŀ
//� ZU5va a integridade dos campos de Bancos de Dados            �
//����������������������������������������������������������������
dbSelectArea("SX3")
dbSeek( cAlias )
While !EOF() .And. (x3_arquivo == cAlias)
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. Trim(x3_campo) != "ALM_DESC";
		.And. !(Trim(x3_campo)$"ALM_COD")
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
		If AllTrim(x3_campo)=="ALM_USER"
			aHeader[Len(aHeader), 6] := "Pco_Vld_User()"
		EndIf
	Endif
	dbSkip()
End

nPosNomeUsr := Ascan(aHeader, {|x| alltrim(x[2]) == "ALM_NOME"})

dbSelectArea("ALM")             
dbSeek(xFilial("ALM")+M->ALM_COD)

While	!Eof() .And. ALM_FILIAL+ALM_COD == xFilial("ALM")+M->ALM_COD
	aadd(aCols,Array(nUsado+1))
	nAcols ++
	For nCntFor := 1 To nUsado
		If ( aHeader[nCntFor][10] != "V")
			aCols[nAcols][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
		Else
			aCols[nAcols][nCntFor] := CriaVar(aHeader[nCntFor][2])
		EndIf
	Next nCntFor
	aCols[nAcols][nUsado+1] := .F.
	dbSkip()
EndDo

Continua := .F.
nOpca := 0
AAdd( aObjects, { 0,    25, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects )
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0009) From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL // "Grupos de Aprovacao"

oSize := FwDefSize():New(.T.,,,oDlg)
oSize:AddObject( "CABECALHO",  100, 25, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "GETDADOS" ,  100, 75, .T., .T. ) // Totalmente dimensionavel 
oSize:lProp 	:= .T. // Proporcional             
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
oSize:Process() 	   // Dispara os calculos 

nX := oSize:GetDimension("CABECALHO","LININI") 
nY := oSize:GetDimension("CABECALHO","COLINI")

@ nX , nY+10 SAY OemToAnsi(STR0010) OF oDlg PIXEL //"&C�digo"
@ nX , nY+40 MSGET M->ALM_COD  Picture "@!" When .F. OF oDlg PIXEL SIZE 30,10 RIGHT
@ nX , nY+80 SAY OemToAnsi(STR0011) OF oDlg PIXEL  //"&Descricao"
@ nX , nY+120 MSGET M->ALM_DESC  Picture "@!" When .F. OF oDlg PIXEL 

oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"PCOA520LOk","AllwaysTrue()","+ALM_ITEM",.T.)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpc:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})

If nOpc == 1
	Begin Transaction
	nPosItem := ASCAN(aHeader,{|x|x[2] = "ALM_ITEM"})
	dbSelectArea("ALM")
	dbSetOrder(1)
	For nx = 1 to Len(aCols)
		If dbSeek(xFilial("ALM")+M->ALM_COD+aCols[nx][nPosItem])
			Reclock("ALM",.F.,.T.)
			dbDelete()
		EndIf
	Next nx
	End Transaction
EndIf

dbSelectArea(cAlias)

Return nOpca

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOA520VIS� Autor � Edson Maricate        � Data �13.10.1998���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de visualizacao de grupos aprovadores.            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void PCOA520VIS(ExpC1,ExpN1)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOA520VIS(cAlias,nReg,nOpcx)
LOCAL bCampo
LOCAL lGravaOK := .T.
LOCAL oDlg, oGet,oReq,oComp
LOCAL nAcols := 0
Local nCntFor:= 0
Local aSizeAut		:= MsAdvSize(,.F.)   
Local aObjects		:= {}
Local aInfo 		:= {}
Local aPosObj		:= {}
Local x			:= 0
Local y			:= 0
Local oSize

PRIVATE 	cSolic , dA110Data := dDataBase,nOpca := 0
PRIVATE aCols := {}
//��������������������������������������������������������������Ŀ
//� Inicializa o numero com o ultimo + 1                         �
//����������������������������������������������������������������
dbSelectArea("ALM")
nSavReg  := RecNo()
M->ALM_COD 		:= ALM->ALM_COD
M->ALM_DESC 	:= ALM->ALM_DESC
//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private aTELA[0][0],aGETS[0],aHeader[0],Continua,nUsado:=0
bCampo := {|nCPO| Field(nCPO)}

//��������������������������������������������������������������Ŀ
//� ZU5va a integridade dos campos de Bancos de Dados            �
//����������������������������������������������������������������
dbSelectArea("SX3")
dbSeek( cAlias )
While !EOF() .And. (x3_arquivo == cAlias)
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. Trim(x3_campo) != "ALM_DESC";
		.And. !(Trim(x3_campo)$"ALM_COD")
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
		If AllTrim(x3_campo)=="ALM_USER"
			aHeader[Len(aHeader), 6] := "Pco_Vld_User()"
		EndIf
	Endif
	dbSkip()
End

nPosNomeUsr := Ascan(aHeader, {|x| alltrim(x[2]) == "ALM_NOME"})

dbSelectArea("ALM")             
dbSeek(xFilial("ALM")+M->ALM_COD)
While	!Eof() .And. ALM_FILIAL+ALM_COD == xFilial("ALM")+M->ALM_COD
	aadd(aCols,Array(nUsado+1))
	nAcols ++
	For nCntFor := 1 To nUsado
		If ( aHeader[nCntFor][10] != "V")
			aCols[nAcols][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
		Else
			aCols[nAcols][nCntFor] := CriaVar(aHeader[nCntFor][2])
		EndIf
	Next nCntFor
	aCols[nAcols][nUsado+1] := .F.
	dbSkip()
EndDo

Continua := .F.
nOpca := 0
AAdd( aObjects, { 0,    25, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects )
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0009) From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL // "Grupos de Aprovacao"

oSize := FwDefSize():New(.T.,,,oDlg)
oSize:AddObject( "CABECALHO",  100, 25, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "GETDADOS" ,  100, 75, .T., .T. ) // Totalmente dimensionavel 
oSize:lProp 	:= .T. // Proporcional             
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
oSize:Process() 	   // Dispara os calculos 

nX := oSize:GetDimension("CABECALHO","LININI")
nY := oSize:GetDimension("CABECALHO","COLINI")

@ nX , nY+10 SAY OemToAnsi(STR0010) OF oDlg PIXEL //"&C�digo"
@ nX , nY+40 MSGET M->ALM_COD  Picture "@!" When .F. OF oDlg PIXEL SIZE 30,10 RIGHT
@ nX , nY+80 SAY OemToAnsi(STR0011) OF oDlg PIXEL  //"&Descricao"
@ nX , nY+120 MSGET M->ALM_DESC  Picture "@!" When .F. OF oDlg PIXEL 
oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"PCOA520LOk","AllwaysTrue()","+ALM_ITEM",.T.)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})

dbSelectArea(cAlias)
Return nOpca


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOA520LOk� Autor � Edson Maricate        � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se a linha digitada esta' Ok                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MatP030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOA520LOk(o)
Local nx,lRet  := .T.
Local lDeleted := .F.
Local cSavOrd  := IndexOrd()
Local nPosUser := ASCAN(aHeader,{|x|x[2] = "ALM_USER"})
Local nPosNivel:= ASCAN(aHeader,{|x|x[2] = "ALM_NIVEL"})
Local nI	   := 0

If Empty(aCols[n][nPosUser]) .AND. Empty(aCols[n][nPosNivel]) .And. n==1
	lRet := .T.
EndIf

If ValType(aCols[n,Len(aCols[n])]) == "L"  /// Verifico se posso Deletar
	lDeleted := aCols[n,Len(aCols[n])]      /// Se esta Deletado
EndIf

If !lDeleted
	If Empty(aCols[n][nPosUser])  .And. lRet
		Help("   ",1,"NOUSERPCOA520",,STR0014,1,0) // "N�o � possivel cadastrar o grupo de aprova��o sem Usu�rio. Informe um usu�rio."
		lRet := .F.
	Endif
	If Empty(aCols[n][nPosNivel]) .And. lRet
		Help("   ",1,"NONIVELPCOA520",,STR0015,1,0) // "N�o � possivel cadastrar o grupo de aprova��o sem N�vel. Informe um n�vel."
		lRet := .F.
	Endif
	If lRet 
		For nI:=1 to Len(aCols)
			If nI <> n	.And. !aCols[nI,Len(aHeader)+1] .And. aCols[nI,nPosUser]==aCols[n,nPosUser] .and. aCols[nI,nPosNivel]==aCols[n,nPosNivel] 		
				Help(" ",1,"JAGRAVADO")	
				lRet := .F.			
			EndIf		
		Next nI
	EndIf
EndIf

dbSetOrder(cSavOrd)
Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOA520GRV� Autor � Edson Maricate        � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se a linha digitada esta ok                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MatA110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOA520GRV(cAlias)
Local nx ,ny
Local nPosItem := ASCAN(aHeader,{|x|x[2] = "ALM_ITEM"})
Local nPosUser := ASCAN(aHeader,{|x|x[2] = "ALM_USER"})

dbSelectArea(cAlias)

dbSelectArea("ALM")
dbSetOrder(1)
For nx = 1 to Len(aCols)
	If Empty(aCols[nx][nPosUser])
		loop
	EndIf
	If ValType(aCols[nx,Len(aCols[nx])]) == "L"
		lDeleted := aCols[nx,Len(aCols[nx])]      /// Se esta Deletado
	End
	If !lDeleted      /// Se nao esta Deletado
		If dbSeek(xFilial("ALM")+M->ALM_COD+aCols[nx][nPosItem])
			RecLock(cAlias,.F.)
		Else
			RecLock(cAlias,.T.)
		EndIf
		//���������������������������������������������������������Ŀ
		//� atualiza apenas os registros que nao foram encerrados   �
		//�����������������������������������������������������������
		For ny = 1 to Len(aHeader)
			If aHeader[ny][10] # "V"
				VarAux := Trim(aHeader[ny][2])
				Replace &VarAux. With aCols[nx][ny]
			Endif
		Next ny
		//����������������������������������������������������������Ŀ
		//� Atualiza dados padroes da cotacao                        �
		//������������������������������������������������������������
		Replace  ALM_FILIAL With xFilial("ALM"),;
		ALM_COD    With M->ALM_COD,;
		ALM_DESC   With M->ALM_DESC
		
	Else
		If dbSeek(xFilial("ALM")+M->ALM_COD+aCols[nx][nPosItem])
			Reclock("ALM",.F.,.T.)
			dbDelete()
		EndIf
	EndIf
Next nx

Return .T.

Function Pco_Vld_User()

If !Empty(M->ALM_USER) .And. nPosNomeUsr > 0
	aCols[n, nPosNomeUsr] := UsrRetName(M->ALM_USER)
EndIf

Return(UsrExist(M->ALM_USER))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �          �Autor  �Caio Quiqueto       � Data �  15/09/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica a existencia do campo na tabela AKJ                ���
���Paramentro �campo para a consulta                                      ���
���retorna o resultado da pesquisa                                        ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function A520VLDCPO(codigo)
	local resp
	local aArea 

	resp := existcpo("AKJ",codigo)

	If resp 

	   aArea := ALM->(GetArea())
	   ALM->(dbSetOrder(1))
	   ALM->(dbgotop())

	   if ALM->(dbSeek(xFilial("ALM")+codigo))
	      MsgAlert(OemToAnsi(STR0016))
	      resp := .F.
	   Endif    
	   
	   ALM->(RestArea(aArea))
    Endif 

return resp


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MenuDef  �Autor  � Pedro Pereira Lima � Data �  09/28/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRotina := {{STR0001,"AxPesqui"	,0,1},;	//"Pesquisar"
						{STR0002,"PCOA520VIS",0,2},; //"Visualizar"
						{STR0003,"PCOA520INC",0,3},; //"Incluir"
						{STR0004,"PCOA520ALT",0,4},; //"Alterar"
						{STR0005,"PCOA520DEL",0,5} } //"Excluir"
						
Return aRotina


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MenuDef  �Autor  � Totvs S.A.         � Data �  29/12/20   ���
�������������������������������������������������������������������������͹��
���Desc.     �   Valida��o Numero de linhas                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � PCOA520                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function DefNumlin() 

   If nNumLin == Nil
      nNumLin := GetNewPar( 'MV_PCO520L' , 99 )
	  If Valtype( nNumLin ) <> 'N'.OR. nNumLin < 1   //SE O PARAMETRO ESTIVER VAZIO O CONTEUDO TB CONSIDERA 99
		nNumLin := 99
	  Endif
   Endif
Return

