#INCLUDE "QPPA160.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QPPA160  � Autor � Robson Ramiro A. Olive� Data � 20.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Plano de Controle                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPA160(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPPAP                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��� Robson Ramiro�20/02/02�VERSAO� Efetuado os ajustes 609 x 710          ���
��� Robson Ramiro�25/06/02�Melhor� Permissao para inclusao de +1 Operacao ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui"  , 0, 1,,.F.},;  	//"Pesquisar"
					{ OemToAnsi(STR0002), "PPA160Visu", 0, 2},;		 	//"Visualizar"
					{ OemToAnsi(STR0003), "PPA160Incl", 0, 3},;		  	//"Incluir"
					{ OemToAnsi(STR0004), "PPA160Alte", 0, 4},;		  	//"Alterar"
					{ OemToAnsi(STR0005), "PPA160Excl", 0, 5},;			//"Excluir"
					{ OemToAnsi(STR0009), "QPPR160(.T.)", 0, 6,,.T.} }	//"Imprimir"

Return aRotina

Function QPPA160
//���������������������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                                �
//�����������������������������������������������������������������������������
Private cCadastro := OemToAnsi(STR0006)  //"Plano de Controle"

Private aRotina := MenuDef()

DbSelectArea("QKM")                            

DbSelectArea("QKL")    
DbSetOrder(1)

mBrowse( 6, 1, 22, 75,"QKL",,,,,,)

Return

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �PPA160Visu  � Autor � Robson Ramiro A.Olivei� Data �20.08.01  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para Visualizacao                                     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA160Visu(ExpC1,ExpN1,ExpN2)                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                     ���
���          � ExpN1 = Numero do registro                                   ���
���          � ExpN2 = Numero da opcao                                      ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PPA160Visu(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local aButtons	:= {}

Private aHeader	 := {}
Private aCols	 := {}
Private nUsado	 :=	0
Private oGet	 := NIL
Private oGetPlan := NIL
Private aSize    := MsAdvSize()

DbSelectArea(cAlias)

//��������������������������������������������������������������Ŀ
//� Monta Enchoice Modelo3                                       �
//����������������������������������������������������������������

DEFINE MSDIALOG oDlg TITLE cCadastro ; //"Plano de Controle"
						FROM 120,000 TO 516,aSize[5] OF oMainWnd PIXEL
						
RegToMemory("QKL")


oGetPlan := MsMGet():New("QKL",nReg,nOpc,,,,,{014,003,IF(aSize[4]<=206,100,140),aSize[3]},,,,,,oDlg)
oGetPlan:oBox:Align := CONTROL_ALIGN_TOP

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
PP160Ahead("QKM")

nUsado	:= Len(aHeader)              

PP160Acols(nOpc)

aButtons := {	{ "EDIT"		, { || QPP160APRO(nOpc) }	, OemToAnsi(STR0007), OemToAnsi(STR0010) },;	//"Aprovar / Limpar"###"Apro/Lim"
				{ "BMPVISUAL"	, { || QPPR160() }			, OemToAnsi(STR0008), OemToAnsi(STR0011) }} 	//"Visualizar/Imprimir"###"Vis/Prn"

oGet := MSGetDados():New(138,00,198,333, nOpc,"AllwaysTrue","AllwaysTrue","+QKM_ITEM",.T.)
If SetMDIChild()
	oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
Endif	


//����������������������������������������������������������������������������Ŀ
//� Ponto de Entrada criado para inclusao de botoes auxiliares na enchoicebar  �
//������������������������������������������������������������������������������
If ExistBlock("QPPAPBUTAUX")
	aButtons := ExecBlock("QPPAPBUTAUX",.f., .f., {nOpc,aButtons})
EndIf

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}, , aButtons),oGet:oBrowse:Refresh())

Return


/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �PPA160Incl  � Autor � Robson Ramiro A.Olivei� Data �20.08.01  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para Inclusao                                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA160Incl(ExpC1,ExpN1,ExpN2)                                ��� 
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                     ���
���          � ExpN1 = Numero do registro                                   ���
���          � ExpN2 = Numero da opcao                                      ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PPA160Incl(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local lOk 		:= .F.
Local aButtons	:= {}
Local nTamGet	:=	QPPTAMGET("QKM_ITEM",1)

Private aHeader	:= {}
Private aCols	:= {}
Private nUsado	:=	0
Private oGet	:= NIL
Private oGetPlan := NIL
Private aSize    := MsAdvSize()

DbSelectArea(cAlias)


//��������������������������������������������������������������Ŀ
//� Monta Enchoice Modelo3                                       �
//����������������������������������������������������������������

DEFINE MSDIALOG oDlg TITLE cCadastro ; // //"Plano de Controle"
						FROM 120,000 TO 516,aSize[5] OF oMainWnd PIXEL
						
RegToMemory("QKL",.T.)						

oGetPlan := MsMGet():New("QKL",nReg,nOpc,,,,,{014,003,IF(aSize[4]<=206,100,140),aSize[3]},,,,,,oDlg)
oGetPlan:oBox:Align := CONTROL_ALIGN_TOP

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
PP160Ahead("QKM")

nUsado	:= Len(aHeader)

PP160Acols(nOpc)

aButtons := {{ "EDIT" , { || QPP160APRO(nOpc) }, OemToAnsi(STR0007), OemToAnsi(STR0010) }} //"Aprovar / Limpar"###"Apro/Lim"
				
DbSelectArea("QKM")	

oGet := MSGetDados():New(138,00,198,333, nOpc,"PP160LinOk","PP160TudOk","+QKM_ITEM",.T.,,,,nTamGet)
oGet:oBrowse:bGotFocus := {|| QPAVLDIN()}
If SetMDIChild()
	oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
Endif	

//����������������������������������������������������������������������������Ŀ
//� Ponto de Entrada criado para inclusao de botoes auxiliares na enchoicebar  �
//������������������������������������������������������������������������������
If ExistBlock("QPPAPBUTAUX")
	aButtons := ExecBlock("QPPAPBUTAUX",.f., .f., {nOpc,aButtons})
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP160TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons)

If lOk
	A160Grav(nOpc)
	If ExistBlock("QPP160GRV")
		ExecBlock("QPP160GRV", .f., .f., {nOpc,nReg})
	EndIf
Endif
Return


/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �PPA160Alte  � Autor � Robson Ramiro A.Olivei� Data �20.08.01  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para Alteracao                                        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA160Alte(ExpC1,ExpN1,ExpN2)                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                     ���
���          � ExpN1 = Numero do registro                                   ���
���          � ExpN2 = Numero da opcao                                      ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PPA160Alte(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local lOk 		:= .F.
Local aButtons	:= {}
Local nTamGet	:=	QPPTAMGET("QKM_ITEM",1)
Local cTpPro    := ""
Local aArea     := {}

Private aHeader	:= {}
Private aCols	:= {}
Private nUsado	:=	0
Private oGet	:= NIL
Private oGetPlan := NIL
Private aSize    := MsAdvSize()

If !QPPVldAlt(QKL->QKL_PECA,QKL->QKL_REV,QKL->QKL_APRFOR)
	Return
Endif

/*If !Empty(QKL->QKL_APRFOR) .And. QKL->QKL_APRFOR <> cUserName
	Alert(STR0012)//"Plano de Controle se encontra aprovado por outro usuario! Sendo possivel apenas sua visualizacao."
	PPA160Visu(cAlias,nReg,2)
	Return()
Endif*/

If cAlias == "QKL"
	aArea := GetArea()
	DBSeek(xFilial("QKL")+QKL->QKL_PECA+QKL->QKL_REV+"Z",.T.)
	DbSkip(-1)
	cTpPro := QKL->QKL_TPPRO
	RestArea(aArea)
	If !Empty(AllTrim(cTpPro)) .AND. Val(cTpPro) > Val(QKL->QKL_TPPRO)
		Alert("Plano de Controle se encontra bloqueado pois j� existe para a mesma pe�a/revis�o uma outra fase de produ��o.")//"Plano de Controle se encontra bloqueado pois j� existe para a mesma pe�a/revis�o uma outra fase de produ��o."
		PPA160Visu(cAlias,nReg,2)
		Return()
	Endif  
EndIf


DbSelectArea(cAlias)
				
aCposAlt := {	"QKL_TPPRO"		,"QKL_PLAN"		,"QKL_DTREV"	,;
				"QKL_EQPRIN"	,"QKL_APRFOR" 	,"QKL_DTAFOR"	,;
				"QKL_DTINI"		,"QKL_APENCL"	,"QKL_DTAENG"	,;
				"QKL_APQUCL"	,"QKL_DTAQUA"	,"QKL_CONTAT" 	,;
				"QKL_OUTAP1"	,"QKL_DTOUT1"	,"QKL_OUTAP2" 	,;
				"QKL_DTOUT2"	}

//���������������������������������������������Ŀ
//� Ponto de entrada para alteracao do aCposAlt �
//�����������������������������������������������
If ExistBlock("QPP160ALT")
	aCposAlt := ExecBlock("QPP160ALT",.F., .f., {aCposAlt})
EndIf


//��������������������������������������������������������������Ŀ
//� Monta Enchoice Modelo3                                       �
//����������������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE cCadastro ; // //"Plano de Controle"
						FROM 120,000 TO 516,aSize[5] OF oMainWnd PIXEL

RegToMemory("QKL",.F.)						                           

oGetPlan := MsMGet():New("QKL",nReg,nOpc,,,,,{014,003,IF(aSize[4]<=206,100,140),aSize[3]},,,,,,oDlg)
oGetPlan:oBox:Align := CONTROL_ALIGN_TOP

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
PP160Ahead("QKM")

nUsado	:= Len(aHeader)

PP160Acols(nOpc)

DbSelectArea("QKM")						

aButtons := {	{ "EDIT" , { || QPP160APRO(nOpc) }, OemToAnsi(STR0007), OemToAnsi(STR0010) },;
				 	{ "NEXT" , { || QPP160EVOL(nOpc),oDlg:End()}, "Evoluir Fase de Produ��o", "Evolui"  } } //"Evoluir o Plano"###"Evolui"

oGet := MSGetDados():New(138,00,198,333, nOpc,"PP160LinOk","PP160TudOk","+QKM_ITEM",.T.,,,,nTamGet)
If SetMDIChild()
	oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
Endif	

//����������������������������������������������������������������������������Ŀ
//� Ponto de Entrada criado para inclusao de botoes auxiliares na enchoicebar  �
//������������������������������������������������������������������������������
If ExistBlock("QPPAPBUTAUX")
	aButtons := ExecBlock("QPPAPBUTAUX",.f., .f., {nOpc,aButtons})
EndIf

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||lOk := PP160TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons),oGet:oBrowse:Refresh())

If lOk
	A160Grav(nOpc)
	If ExistBlock("QPP160GRV")
		ExecBlock("QPP160GRV", .f., .f., {nOpc,nReg})
	EndIf
Endif

Return

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �PPA160Excl  � Autor � Robson Ramiro A.Olivei� Data �20.08.01  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para Exclusao                                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA160Excl(ExpC1,ExpN1,ExpN2)                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                     ���
���          � ExpN1 = Numero do registro                                   ���
���          � ExpN2 = Numero da opcao                                      ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PPA160Excl(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local aButtons	:= {}

Private aHeader	:= {}
Private aCols	:= {}
Private nUsado	:=	0
Private oGet	:= NIL
Private oGetPlan := NIL
Private aSize    := MsAdvSize()

If !QPPVldExc(QKL->QKL_REV,QKL->QKL_APRFOR)
	Return
Endif


DbSelectArea(cAlias)

//��������������������������������������������������������������Ŀ
//� Monta Enchoice Modelo3                                       �
//����������������������������������������������������������������

DEFINE MSDIALOG oDlg TITLE cCadastro; // //"Plano de Controle"
						FROM 120,000 TO 516,aSize[5] OF oMainWnd PIXEL
						
RegToMemory("QKL")						

oGetPlan := MsMGet():New("QKL",nReg,nOpc,,,,,{014,003,IF(aSize[4]<=206,100,140),aSize[3]},,,,,,oDlg)
oGetPlan:oBox:Align := CONTROL_ALIGN_TOP
						

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
PP160Ahead("QKM")

nUsado	:= Len(aHeader)

PP160Acols(nOpc)

aButtons := {	{ "EDIT"		, { || QPP160APRO(nOpc) }	, OemToAnsi(STR0007), OemToAnsi(STR0010) },;	//"Aprovar / Limpar"###"Apro/Lim"
				{ "BMPVISUAL"	, { || QPPR160() }			, OemToAnsi(STR0008), OemToAnsi(STR0011) }} 	//"Visualizar/Imprimir"###"Vis/Prn"

oGet := MSGetDados():New(138,00,198,333, nOpc,"AllwaysTrue","AllwaysTrue","+QKM_ITEM",.T.)

If SetMDIChild()
	oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
Endif	
//����������������������������������������������������������������������������Ŀ
//� Ponto de Entrada criado para inclusao de botoes auxiliares na enchoicebar  �
//������������������������������������������������������������������������������
If ExistBlock("QPPAPBUTAUX")
	aButtons := ExecBlock("QPPAPBUTAUX",.f., .f., {nOpc,aButtons})
EndIf

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| A160Dele(),oDlg:End()},{||oDlg:End()}, , aButtons),oGet:oBrowse:Refresh())

If ExistBlock("QPP160GRV")
	ExecBlock("QPP160GRV", .f., .f., {nOpc,nReg})
EndIf

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �PP160Acols� Autor � Robson Ramiro A. Olive� Data � 20.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega vetor aCols para a GetDados                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q010Acols()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA160                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PP160Acols(nOpc)
Local nI, nPos
Local nPosNOPE := aScan(aHeader,{ |x| AllTrim(x[2])== "QKM_NOPE" })
Local nPosNCAR := aScan(aHeader,{ |x| AllTrim(x[2])== "QKM_NCAR" })

//������������������������������������������������������Ŀ
//� Montagem do aCols               					 �
//��������������������������������������������������������

If nOpc == 3

	aCols := Array(1,nUsado+1)

	For nI = 1 To Len(aHeader)
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

	nPos			:= aScan(aHeader,{ |x| AllTrim(x[2])== "QKM_ITEM" })
	aCols[1,nPos]	:= StrZero(1,Len(aCols[1,nPos]))
	
	aCols[1,nUsado+1] := .F.	

Else
	
	DbSelectArea("QKM")
	DbSetOrder(3) 
	DbSeek(xFilial("QKM")+QKL->QKL_PECA+QKL->QKL_REV+QKL->QKL_TPPRO)

	Do While QKM->(!Eof()) .and. xFilial() == QKL->QKL_FILIAL     	.and.;
		 QKM->QKM_PECA+QKM->QKM_REV == QKL->QKL_PECA+QKL->QKL_REV

	If QKL->QKL_TPPRO <> QKM->QKM_TPPRO
		DbSkip()
		Loop
	EndIf

	aAdd(aCols,Array(nUsado+1))

	For nI := 1 to nUsado
   	
		If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
			aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
		Else										// Campo Virtual
			cCpo := AllTrim(Upper(aHeader[nI,2]))
			aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])

			If cCPO == "QKM_DESOPE"
				aCols[Len(aCols),nI] := Posicione("QKK",2,xFilial()+QKL->QKL_PECA+QKL->QKL_REV+aCols[Len(aCols),nPosNOPE],"QKK_DESC")
			Elseif cCPO == "QKM_DESCAR"
				aCols[Len(aCols),nI] := Posicione("QK2",2,xFilial()+QKL->QKL_PECA+QKL->QKL_REV+aCols[Len(aCols),nPosNCAR],"QK2_DESC")
			Endif
			
  			Endif
 			
	Next nI
  			
	aCols[Len(aCols),nUsado+1] := .F.
    	
	DbSkip()

Enddo
		
Endif

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PP160Ahead� Autor � Robson Ramiro A. Olive� Data � 20.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Monta Ahead para aCols                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP160Ahead()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA160                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PP160Ahead(cAlias)

Local aStruAlias := FWFormStruct(3, cAlias)[3]
Local nX

aHeader := {}
nUsado 	:= 0

For nX := 1 To Len(aStruAlias)
	//��������������������������������������������������
	//�Ignora campos que nao devem aparecer na getdados�
	//��������������������������������������������������
	If  Upper(AllTrim(aStruAlias[nX,1])) == "QKM_PECA" 	.or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKM_REV"   .or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKM_TPPRO"
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

Return



/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A160Grav � Autor � Robson Ramiro A Olivei� Data � 20.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Gravacao - Incl./Alter.                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A160Grav(ExpC1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Exp1N = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA160                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A160Grav(nOpc)

Local nIt     
Local nCont
Local nNumItem
Local nPosDel 	:= Len(aHeader) + 1
Local nCpo
Local bCampo	:= { |nCPO| Field(nCPO) }
Local lGraOk 	:= .T.   // Indica se todas as gravacoes obtiveram sucesso
Local cAtividade	:= "05 " // Definido no ID - QKZ

Begin Transaction

DbSelectArea("QKL")
DbSetOrder(1)

If INCLUI
	RecLock("QKL",.T.)
Else
	RecLock("QKL",.F.)
Endif

For nCont := 1 To FCount()

	If "FILIAL"$Field(nCont)
		FieldPut(nCont,xFilial("QKL"))
	Else
		FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
	Endif

Next nCont

//��������������������������������������������������������������Ŀ
//� Campos nao informados                                        �
//����������������������������������������������������������������
QKL->QKL_REVINV := Inverte(QKL->QKL_REV)

If !Empty(QKL->QKL_DTAFOR) .and. !Empty(QKL->QKL_APRFOR)
	QPP_CRONO(QKL->QKL_PECA,QKL->QKL_REV,cAtividade) // QPPXFUN - Atualiza Cronograma
Endif

MsUnLock()
FKCOMMIT()

DbSelectArea("QKM")    
DbSetOrder(3)

nNumItem := 1  // Contador para os Itens
	
For nIt := 1 To Len(aCols)

	If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

		If ALTERA
			If DbSeek(xFilial("QKM")+ M->QKL_PECA + M->QKL_REV + M->QKL_TPPRO + StrZero(nIt,Len(QKM->QKM_ITEM)))
				RecLock("QKM",.F.)
			Else
				RecLock("QKM",.T.)
			Endif			
		Else	                   
			RecLock("QKM",.T.)
		Endif
			
		For nCpo := 1 To Len(aHeader)
			If aHeader[nCpo, 10] <> "V"
				QKM->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
			EndIf
		Next nCpo

		//��������������������������������������������������������������Ŀ
		//� Campos Chave nao informados                                  �
		//����������������������������������������������������������������
		QKM->QKM_FILIAL	 := xFilial("QKM")
		QKM->QKM_PECA 	 := M->QKL_PECA
		QKM->QKM_REV 	 := M->QKL_REV
		QKM->QKM_REVINV	 := Inverte(QKL->QKL_REV)
		QKM->QKM_TPPRO	 := QKL->QKL_TPPRO
                                                                              
		//��������������������������������������������������������������Ŀ
		//� Controle de itens do acols                                   �
		//����������������������������������������������������������������
		QKM->QKM_ITEM := StrZero(nNumItem,Len(QKM->QKM_ITEM))

		nNumItem++

		MsUnlock()
    Else
		If DbSeek(xFilial("QKM")+ M->QKL_PECA + M->QKL_REV + M->QKL_TPPRO + StrZero(nIt,Len(QKM->QKM_ITEM)) )
			RecLock("QKM",.F.)
			DbDelete() 
			MsUnlock()
		Endif
	Endif

Next nIt
FKCOMMIT()

End Transaction
				
Return lGraOk


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A160Dele � Autor � Robson Ramiro A Olivei� Data � 20.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Exclusao                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A160Dele(ExpC1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Exp1N = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA160                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A160Dele()

DbSelectArea("QKM")
DbSetOrder(3)
If DbSeek(xFilial("QKM")+ QKL->QKL_PECA + QKL->QKL_REV + QKL->QKL_TPPRO )

	Do While !Eof() .and. ;
		QKL->QKL_PECA + QKL->QKL_REV + QKL->QKL_TPPRO == QKM_PECA + QKM_REV + QKM_TPPRO
		
		RecLock("QKM",.F.)
		DbDelete()
		MsUnLock()
		FKCOMMIT()
		DbSkip()
		
	Enddo

Endif

DbSelectArea("QKL")

RecLock("QKL",.F.)
DbDelete()
MsUnLock()        
FKCOMMIT()				
Return


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PP160LinOk� Autor � Robson Ramiro A. Olive� Data � 20.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para mudanca/inclusao de linhas               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP160LinOk                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function PP160LinOk

Local nPosDel     := Len(aHeader) + 1
Local nPosNCAR    := aScan(aHeader, { |x| AllTrim(x[2]) == "QKM_NCAR" }) 
Local nPosNOPE 	  := aScan(aHeader, { |x| Upper(AllTrim(x[2])) == "QKM_NOPE" })
Local nPosItem    := aScan(aHeader, { |x| AllTrim(x[2]) == "QKM_ITEM" })
Local lRetorno    := .T.   
Local cOrgPLCItem := (GetMv("MV_QORGPLC",.T.,"2"))
Local cNxtPos     := " "
Local nLenItem    := Len(aCols[n,nPosItem]) //Pega o Tamanho do Item
Local nCont       := 0

//������������������������������������������������������Ŀ
//� verifica se ao menos 1 amostra foi preenchida        �
//��������������������������������������������������������
If Empty(aCols[n,nPosNCAR]) .and. !aCols[n, nPosDel]
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
EndIf

If cOrgPLCItem == "1"  // Organiza por Item 
	cNxtPos:= STRZERO(VAL(aCols[n,nPosItem]),nLenItem)+AllTrim(aCols[n,nPosNOPE])
	
	//�������������������������������������������������������������Ŀ
	//�Organiza Posiciona e Refaz Itens no Acols baseada na operacao�
	//���������������������������������������������������������������
	If lRetorno
		nCont := 1
		aCols := aSort(aCols,,,{|x,y| STRZERO(VAL(x[nPosItem]),nLenItem)+x[nPosNOPE] < STRZERO(VAL(y[nPosItem]),nLenItem)+y[nPosNOPE]})  // organizo o array    
		oGet:oBrowse:Refresh() 
		oGet:oBrowse:nAt:= Ascan(aCols,{|x| STRZERO(VAL(x[nPosItem]),nLenItem)+AllTrim(x[nPosNOPE]) == cNxtPos}) // Coloco na  posi��o desejada
		Aeval(aCols,{ |x| x[nPosItem]:= strzero(nCont++,nLenItem)  } ) // Refaz a numeracao do Item
		oGet:oBrowse:Refresh()    
	Endif
Elseif cOrgPLCItem == "2" // Default organiza por  operacao  organiza��o alfanum�rica
	cNxtPos:= AllTrim(aCols[n,nPosNOPE])+STRZERO(VAL(aCols[n,nPosItem]),nLenItem)
	
	//�������������������������������������������Ŀ
	//� Organiza Posiciona e Refaz Itens no Acols �
	//���������������������������������������������
	If lRetorno
		nCont := 1
		aCols := aSort(aCols,,,{|x,y| x[nPosNOPE]+STRZERO(VAL(x[nPosItem]),nLenItem) < y[nPosNOPE]+STRZERO(VAL(y[nPosItem]),nLenItem)})  // Organizo o array
		oGet:oBrowse:Refresh()
		oGet:oBrowse:nAt:= Ascan(aCols,{|x| AllTrim(x[nPosNOPE])+STRZERO(VAL(x[nPosItem]),nLenItem) == cNxtPos}) // Coloco na  posi��o desejada
		Aeval(aCols,{ |x| x[nPosItem]:= strzero(nCont++,nLenItem)  } ) // Refaz a numeracao do Item
		oGet:oBrowse:Refresh()
	Endif
Else //Default organiza por  operacao  organiza��o Num�rica
	
	//�������������������������������������������Ŀ
	//� Organiza Posiciona e Refaz Itens no Acols �
	//���������������������������������������������
	If lRetorno
		nCont := 1
		aCols := aSort(aCols,,,{|x,y| Val(x[nPosNOPE]) < Val(y[nPosNOPE])})	// Ordenacao Numerica do aCols pela Operacao
		aCols := aSort(aCols,,,{|x,y| Val(x[nPosNOPE]) < Val(y[nPosNOPE])})	// Ordenacao Numerica do aCols pela Operacao
		Aeval(aCols,{|x| x[nPosItem]:= StrZero(nCont++,nLenItem)})	   			// Refaz a numeracao do Item
		oGet:oBrowse:Refresh()
	Endif 
EndIf	
Return lRetorno

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PP160TudOk� Autor � Robson Ramiro A. Olive� Data � 20.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para inclusao/alteracao geral                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP160TudOk                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/

Function PP160TudOk

Local lRetorno	:= .T.
Local nIt 		:= 0
Local nTot		:= 0
Local nPosDel  	:= Len(aHeader) + 1                      
Local nPosNCAR  := aScan(aHeader, { |x| AllTrim(x[2]) == "QKM_NCAR" })

//Verifica se na inclusao existe a peca + revisao
If INCLUI
	lRetorno := QPAVLDIN()
Endif

If lRetorno
	For nIt := 1 To Len(aCols)
		If aCols[nIt, nPosDel]
			nTot ++
		Endif
	Next nIt
	
	If !PP160LinOk() // Executo somente para organizar o acols
		lRetorno := .F.
	EndIf
	
	For nIt := 1 To Len(aCols)
		//������������������������������������������������������Ŀ
		//� verifica se ao menos 1 amostra foi preenchida        �
		//��������������������������������������������������������
		If Empty(aCols[nIt,nPosNCAR]) .and. !aCols[nIt, nPosDel]
			lRetorno := .F.
			Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
		EndIf
	Next nIt
	                
	If Empty(M->QKL_PECA) .or. Empty(M->QKL_REV) .or. nTot == Len(aCols)
		lRetorno := .F.
		Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
	EndIf
Endif

Return lRetorno

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �QPP160APRO� Autor � Robson Ramiro A.Olivei� Data � 20.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Aprova / Limpa                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPP160APRO(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao do mBrowse									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA160                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPP160APRO(nOpc)

If nOpc == 3 .or. nOpc == 4
	DbSelectArea("QAA")
	DbSetOrder(6)
	If Dbseek(Upper(cUserName))
		M->QKL_DTAFOR := Iif(Empty(M->QKL_DTAFOR), dDataBase, CtoD(" / / "))
		M->QKL_APRFOR := Iif(Empty(M->QKL_APRFOR), cUserName, Space(50))
	Else
		messagedlg(STR0013) //"O usu�rio logado n�o est� cadastrado no cadastro de usu�rios do m�dulo, portanto n�o poder� ser o aprovador"
	Endif	
Endif

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �QPAVLDIN  � Autor � Rafael S. Bernardi    � Data � 31/10/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Verifica se existem planos para essa peca                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPAVLDIN()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                 									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA160                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPAVLDIN()
Local lRet := .T.
Local aArea := GetArea()
Local aCombo := QPP160CBOX()
Local nIt
If INCLUI
	DBSelectArea("QKL")
	DBSetOrder(1)
	If(QKL->(DBSeek(xFilial("QKL") + M->QKL_PECA + M->QKL_REV + M->QKL_TPPRO)))
		Help("",1,"JAGRAVADO")
		lRet := .F.
	EndIf
Endif	                                   
If INCLUI
	DBSelectArea("QKL")
	DBSetOrder(1) 
	For nIt := 1 To Len(aCombo)
		If(QKL->(MSSeek( xFilial("QKL") + M->QKL_PECA + M->QKL_REV + AllTrim(STR(nIt)) ))) // Posiciono no ultimo
		    If VAL(QKL->QKL_TPPRO) <> 0
				Help("",1,"QJAEXTPPR")
				lRet := .F.	              
			EndIf
		Endif
	Next
EndIf
RestArea(aArea)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QPP160EVOL�Autor  �Cicero Cruz         � Data �  08/12/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que evolui o Plano nos estados -  Prototipo -> Pre- ���
���          � lancamento -> Producao                                     ���
�������������������������������������������������������������������������͹��
���Uso       � QPPA160                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function QPP160EVOL(nOpc)
Local aCombo			// Op��es do ComboBox
Local aRet   := {} 		// Array de retorno
Local nIt	 := 0		// Posi��o da op��o escolhida

If Val(QKL->QKL_TPPRO) <> 0 .AND. nOpc == 4 
	If MsgYesNo("Antes de executar este deve-se salvar o Plano de Controle, deseja salvar S/N.","Aten��o") .AND. PP160TudOk()
		// Gravo o Plano 
		A160Grav(nOpc)
		aCombo := QPP160CBOX()
		If Len(aCombo) >= 1
			// Monta Combo e oferece as alternativas
    	    aRet := QPPMONOPT(Val(QKL->QKL_TPPRO),aCombo)  
        	// Bloqueio o Plano                 
	        If aRet[1]
				nIt := aScan(aCombo, { |x| AllTrim(x) == AllTrim(aRet[2]) })
        		M->QKL_TPPRO := Alltrim(Str(nIt))

			    // Evoluo o Plano
				INCLUI := .T.
				A160Grav(3)	    
				INCLUI := .F.
    	    EndIf
    	EndIf
    EndIf
Else
	If Val(QKL->QKL_TPPRO) == 0
		Help("",1,"QNAOEVOLU")
	EndIf	
EndIf
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QPP160CBOX�Autor  �Cicero Cruz         � Data �  08/12/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao que copia os valores do CBOX                        ���
�������������������������������������������������������������������������͹��
���Uso       � QPPA160                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QPP160CBOX()
Local aRet     := {}
Local aArea    := GetArea()
Local cTexto   := ""
//1=Prototipo;2=Pre-Lancamento;3=Producao

cTexto := QAGetX3Cmb("QKL_TPPRO")
	
While !Empty(cTexto)
	nTexto:= At("=",cTexto)
	If nTexto > 0
		cTexto := Subs(cTexto,nTexto+1,Len(cTexto))
		nTexto:= At(";",cTexto)
		If nTexto > 0          
			cCombo := Subs(cTexto,1,nTexto-1)
			If !("Nao Evolui" $ cCombo)
				AAdd( aRet , cCombo  )
			EndIf
			cTexto := Subs(cTexto,nTexto+1,Len(cTexto))
		EndIf
	Else
		AAdd( aRet , cTexto  )
		cTexto := ""
	EndIf
EndDo
RestArea(aArea)
Return aRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QPPMONOPT �Autor  �Cicero Cruz         � Data �  08/12/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna a Op��o de evolu��o do plano                       ���
�������������������������������������������������������������������������͹��
���Uso       � QPPA160                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QPPMONOPT(nOptAtu,aCombo)
Local oDlg					// Objeto de tela 
Local oCombo				// Objeto de tela 
Local nI		:= 0	 	// Variavel Local do For
Local cCombo	:= ""		// Op��o escolhida
Local lOk       := .F.    	// Clicado bot�o OK
Local aItens    := {}     	// Itens Filtrados

For nI := 1 To Len(aCombo)
	If nI > nOptAtu
		AAdd( aItens , aCombo[nI]  )
	EndIf	
Next

If Len(aItens) >= 1         
	cCombo := aItens[1]

	DEFINE MSDIALOG oDlg FROM	35,37 TO 140,300 TITLE OemToAnsi("Op��es para Evolu��o de Fase de Produ��o") PIXEL	//"Op��es para Evolu��o do Plano"
	
	@ 017,005 COMBOBOX oCombo VAR cCombo ITEMS aItens SIZE 71, 50 OF oDlg PIXEL
	
	DEFINE SBUTTON FROM 011, 090 TYPE 1 ENABLE OF oDlg Action (lOk:=.T.,oDlg:End())
	DEFINE SBUTTON FROM 024, 090 TYPE 2 ENABLE OF oDlg Action (lOk:=.F.,oDlg:End())
	
	ACTIVATE MSDIALOG oDlg Centered
Else
	MsgInfo("N�o h� mais op��es de Evolu��o de fase de produ��o para esta pe�a.")
EndIf
	
Return {lOk,cCombo}

