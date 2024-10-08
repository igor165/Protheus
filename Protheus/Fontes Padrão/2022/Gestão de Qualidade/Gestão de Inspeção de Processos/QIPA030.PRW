#Include "QIPA030.CH"
#include "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPA030  � Autor � Marcelo Pimentel      � Data � 25/09/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Linhas de Produtos              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���Marcelo       �25/04/00�------� Incluido o quinto parametro como 3 no  ���
���Marcelo       �25/04/00�------� array aRotina.                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QIPA030
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
PRIVATE aRotina := { {OemToAnsi(STR0004),"AxPesqui"  , 0 , 1},;  // "Pesq."
                     {OemToAnsi(STR0005),"a030VGPr"  , 0 , 2},;  // "Visual."
                     {OemToAnsi(STR0006),"a030IGPr"  , 0 , 3},;  // "Incluir"
                     {OemToAnsi(STR0007),"a030IGPr"  , 0 , 4},;  // "Alterar"
                     {OemToAnsi(STR0008),"a030DGPr"  , 0 , 5 , 3},;  // "Excluir"
                     {OemToAnsi(STR0009),"a030PrGr"  , 0 , 4} }  // "pRodutos"

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0010)  //"Linhas de Produtos"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QQ5")

Return .T.
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � a030DGPr � Autor � Marcelo Pimentel      � Data � 25/09/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Linhas de Produtos - Delecao    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � a030DGPr(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION a030DGPr(cAlias,nReg,nOpc)
LOCAL nOpcA
LOCAL cCod
LOCAL oDlg 

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTELA[0][0],aGETS[0]

While .T.
	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	M->QQ5_DESCEQ := a030DEqu(QQ5->QQ5_EQUIPE)
	nOpcA:=0
	dbSelectArea(cAlias)
	RecLock(cAlias,.F.)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
		nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0011))  //"Quanto � exclus�o?"
		nOpca := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})

	dbSelectArea(cAlias)

	IF nOpcA == 2	// Confirma

		cCod := QQ5->QQ5_LINHA

		Begin Transaction

			//��������������������������������������������������������������Ŀ
			//� Apos passar por todas as verificacoes , deleta o registro    �
			//����������������������������������������������������������������
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.,.T.)
			dbDelete()
	
			//������������������������������������������������������Ŀ
			//� Apaga tambem do QQ6 -> Amarracao Linha X Produtos    �
			//��������������������������������������������������������
			dbSelectArea("QQ6")

			dbSeek( xFilial("QQ6")+cCod )
			While !EOF() .And. QQ6_FILIAL+QQ6_LINHA==xFilial("QQ6")+cCod
				RecLock("QQ6",.F.,.t.)
				dbDelete()
				dbSkip()
			EndDo

			// Nao limpa campo Linha das entregas cadastradas com o linha deletada,
			// para deixar como historico.

		End Transaction
	Else
		MsUnLock()

   EndIf
	
   Exit
EndDo

dbSelectArea(cAlias)
Return
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � a030IGPr � Autor � Marcelo Pimentel      � Data � 25/09/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa atualizacao Linhas Produtos - Inclusao/Alteracao  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � a030IGPr(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION a030IGPr(cAlias,nReg,nOpc)
LOCAL nOpcA:=0

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTELA[0][0],aGETS[0]

While .T.

	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	nOpcA:=0

	Begin Transaction

		if nOpc == 3  // Inclusao
			nOpcA:=AxInclui( cAlias, nReg, nOpc)

		elseif nOpc == 4  // Alteracao
			nOpcA:=AxAltera( cAlias, nReg, nOpc)
		endif

	End Transaction

   Exit
EndDo
dbSelectArea(cAlias)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � a030VGPr � Autor � Marcelo Pimentel      � Data � 25/09/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa atualizacao Linha Produtos - Visualizacao         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � a030VGPr(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function a030VGPr(cAlias, nReg, nOpc)

LOCAL bCampo
LOCAL i
LOCAL oDlg

PRIVATE aTela[0][0]
PRIVATE aGets[0]

bCampo := {|nCPO| Field(nCPO) }
For i := 1 TO FCount()
	M->&(EVAL(bCampo,i)) := FieldGet(i)
Next i

nReg         := Recno()

DEFINE MSDIALOG oDlg	;
TITLE cCadastro		;
FROM 9,0 TO 28,80		;
OF oMainWnd
	
EnChoice( cAlias, nReg, nOpc ) // 2, , , , , , , , , , , ,.t. )
lVar01 := 0
	
ACTIVATE MSDIALOG oDlg	;
ON INIT						;
EnchoiceBar(oDlg,{|| LVar01 := 1,oDlg:End()},{|| LVar01 := 2,oDlg:End()})	

dbSelectArea(cAlias)
Return LVar01
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � a030PrGr � Autor � Marcelo Pimentel      � Data � 25/09/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastra Produtos dos Linhas de Prod.                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � a030PrGr(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada no menu                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION a030PrGr(cAlias,nReg,nOpcx)
LOCAL nCnt,nSavRec
LOCAL nOpca:=0, nRecNc, lInclui := .f.
LOCAL oDlg, oGet			
LOCAL lGravaOk := .T.
Local aStruAlias := FWFormStruct(3, "QQ6")[3]
Local nX
Private nPosPro, nPosDPr

//��������������������������������������������������������������Ŀ
//� Verifica se ha' Produtos ja existentes para o Linha          �
//����������������������������������������������������������������
dbSelectArea("QQ6")
dbSetOrder(1)
nSavRec := RecNo()
dbSeek( xFilial("QQ6")+QQ5->QQ5_LINHA )

nRecNc := RecNo()
nCnt := 0
While !EOF() .And. QQ6_FILIAL+QQ6_LINHA == xFilial("QQ6")+QQ5->QQ5_LINHA
	nCnt++
	dbSkip()
End
lInclui := Iif(nCnt==0,.t.,.f.)
dbGoto(nRecNc)

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private aHeader[0],Continua:=.F.,nOpc:=3,nUsado:=0

//��������������������������������������������������������������Ŀ
//� Salva a integridade dos campos de Bancos de Dados            �
//����������������������������������������������������������������
dbSelectArea("SX2")	// Posiciona pq. rotinas internas utilizam inf. do SX2
dbSeek("QQ6")

//��������������������������������������������������������������Ŀ
//� Monta vetor Aheader a ser utilizado na getdados              �
//����������������������������������������������������������������
MontAhead("QQ6")	// QAXFUN

//����������������������������������������������������������������������Ŀ
//� Verifica a posicao dos campos no aHeader p/ posterior consistencia   �
//������������������������������������������������������������������������
nPosPro  := Ascan(aHeader,{|x| x[2] = "QQ6_PRODUT"})
nPosDPr  := Ascan(aHeader,{|x| x[2] = "QQ6_DESPRO"})

dbSelectArea("QQ6")
dbGoto(nRecNc)

//��������������������������������������������������������������Ŀ
//� Define vetor aCols para a getdados                           �
//����������������������������������������������������������������
If lInclui	// Def. vetor com 1 elemento, para a inclusao
	nCnt := 1
EndIf
PRIVATE aCOLS[nCnt,nUsado+1]

if !lInclui
	//��������������������������������������������������������������Ŀ
	//� Alimenta vetor aCols com os Produtos ja existentes           �
	//����������������������������������������������������������������
	nCnt := 0
	dbSelectArea("QQ6")
	While !EOF() .And. QQ6_FILIAL+QQ6_LINHA == xFilial("QQ6")+QQ5->QQ5_LINHA
		nCnt++
		nUsado:=0
		
		For nX := 1 To Len(aStruAlias)
			If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL") 
				nUsado++
				If GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT") # "V"
					aCOLS[nCnt,nUsado] := &("QQ6->"+aStruAlias[nX,1])
				ElseIF GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT") == "V"
					If aHeader[nUsado,2] == "QQ6_DESPRO"
						aCOLS[nCnt,nUsado] := QIPXDePr(QQ6->QQ6_PRODUT)
					Else
						aCOLS[nCnt,nUsado] := CriaVar(AllTrim(aStruAlias[nX,1]))
					EndIf
				Endif
			EndIf
		Next nX
		
		aCOLS[nCnt,nUsado+1] := .F.
		dbSelectArea("QQ6")
		dbSkip()
	Enddo
Else
	//��������������������������������������������������������������Ŀ
	//� Alimenta vetor aCols com um elemento em branco p/ inclusao   �
	//����������������������������������������������������������������
	nUsado:=0
	
	For nX := 1 To Len(aStruAlias)
		If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL") 
			nUsado++
			aCols[1,nUsado] := CriaVar(allTrim(aStruAlias[nX,1]))
		EndIf
	Next nX
	
	aCOLS[1,nUsado+1] := .F.
	nCnt := 0	// Retorna valor
EndIf

dbSelectArea("QQ6")
dbGoto(nRecNc)
Continua 	:= .F.
nOpca 		:= 0

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0010) From 9,0 To 28,80 OF oMainWnd	 // "Linhas de Produtos"

	@ 1.1 , .5	SAY OemToAnsi(STR0012) 		//"&Linha"
	@ 1.1 , 4 	SAY QQ5->QQ5_LINHA + ' - ' + QQ5->QQ5_DESCRI
	oGet := MSGetDados():New(41,5,130,315,nOpcx,"Qip030LOk","Qip030TOk",,.T.,,1)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nopca:=1,If(oGet:TudoOk(),oDlg:End(),nOpca:=0)},{||oDlg:End()})

If nOpcA == 1
	Begin Transaction
		lGravaOk := a030GrvPr(cAlias)
		If lGravaOK
			//Processa Gatilhos
			EvalTrigger()
		EndIf	
	End Transaction
Endif

dbSelectArea(cAlias)
Return nOpca
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���                                                                       ���
���                                                                       ���
���                   ROTINAS DE CRITICA DE CAMPOS                        ���
���                                                                       ���
���                                                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Qip030LOk � Autor � Marcelo Pimentel      � Data � 25/09/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se a linha digitada esta' Ok                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QiPA030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Qip030LOk(o)

Local lRetu:=.T.
Local nAchou:=0
Local cProcura:=aCols[n,nPosPro]

If !(aCols[n,Len(aCols[n])])
	//�������������������������������������������������������������Ŀ
	//� Verifica se campo Produto esta' preenchido                  �
	//���������������������������������������������������������������
	If !aCols[n,nUsado+1] .And. LastKey() != 5 .And. LastKey() != 27 .And. lRetu
		If Empty(aCols[n,nPosPro])
			Help(" ",1,"QA_CPOOBR")
			lRetu:=.F.	
		EndIf
	EndIf
	If lRetu
		//�������������������������������������������������Ŀ
		//� Verifica se o Produto ja' existe                �
		//���������������������������������������������������
		nAchou := Ascan(aCols,{|x| x[nPosPro] == cProcura .And. !(x[Len(aCols[n])])})
		If nAchou > 0 .And. nAchou # n
			Help(" ",1,"A060EXIPRG")
			lRetu:=.F.
		EndIf
	EndIf

	//�������������������������������������������������Ŀ
	//� Verifica se o Produto esta' cadastrado          �
	//���������������������������������������������������
	If lRetu
		If ! Empty(aCols[n,nPosPro])
			If ! ExistCpo("QP6",aCols[n,nPosPro])
				lRetu := .f.
			EndIf
		EndIf
	EndIf

	//������������������������������������������������������������Ŀ
	//� Verifica se o Produto esta' relacionado a outra Linha      �
	//��������������������������������������������������������������
	If lRetu
		If !Empty(aCols[n,nPosPro])
			nReg := QQ6->(Recno())
			QQ6->(dbSetOrder(2))
			If QQ6->(dbSeek(xFilial("QQ6") + aCols[n,nPosPro]))
				If QQ6->QQ6_LINHA <> QQ5->QQ5_LINHA
					HELP(" ",1,"A030LINEXI",,QQ6->QQ6_LINHA,3,1)
					lRetu := .f.
				EndIf
			EndIf
			QQ6->(dbSetOrder(1))
			QQ6->(dbGoto(nReg))
		EndIf
	EndIf
EndIf
Return lRetu

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Qip030TOk � Autor � Marcelo Pimentel      � Data � 25/09/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se toda a getdados esta' Ok                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QiPA030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Qip030TOk(o)
Local nI, lRetu := .t.

For nI := 1 to Len(aCols)
	If ! Qip030LOk(o)
		lRetu := .f.
		Exit
	EndIf
Next

Return(lRetu)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �a030GrvPr � Autor � Marcelo Pimentel      � Data � 25/09/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava a amarracao Linha X Produto                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QiPA030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function a030GrvPr(cAlias)
Local nx 
Local ny  
Local nMaxArray := Len(aCols)
Local nPos      := 0

dbSelectArea("QQ6")

//������������������������������������������������������������Ŀ
//� Verifica qual a posicao do campo Produto no aHeader        �
//��������������������������������������������������������������
nPos := ASCAN(aHeader,{|x|x[2] = "QQ6_PRODUT"})

//����������������������������Ŀ
//� Grava o arquivo QQ6        �
//������������������������������
For nX := 1 to nMaxArray
	If ! Empty(aCols[nX,nPos]) // Cod. Produto nao vazio
		If !Acols[nX,nUsado+1]	// Nao esta deletado
			If dbSeek(xFilial("QQ6") + QQ5->QQ5_LINHA + aCols[nX,nPos])
				RecLock("QQ6",.F.)	// Lock
			Else
				RecLock("QQ6",.T.)	// Append
			Endif
			For ny := 1 to Len(aHeader)
				If aHeader[ny,10] # "V"
					cVar := Trim(aHeader[ny,2])
					Replace &cVar. With aCols[nx,ny]
				Endif
			Next ny
			RecLock("QQ6",.F.)
			QQ6->QQ6_LINHA  := QQ5->QQ5_LINHA
			QQ6->QQ6_FILIAL := xFilial("QQ6")
		Else
		 	//���������������������������������������Ŀ
			//� Cancela o Produto no QQ6              �
			//�����������������������������������������
			If dbSeek(xFilial("QQ6") + QQ5->QQ5_LINHA + aCols[nX,nPos])
				RecLock("QQ6",.F.)
				dbDelete()
			EndIf
		EndIf
	EndIf
Next nx

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � a030VlPr � Autor � Marcelo Pimentel      � Data � 25/09/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo Produto                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QiPA030 - E' chamada no X3_VALID do cpo. QQ6_PRODUT - SX3  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function a030VlPr()
Local lRetu := .t., nI, nReg,;
		cVar := &(readvar()) // Conteudo da variavel do campo NC

//����������������������������������������������������������������Ŀ
//� Verifica se mudou o Produto (Alterou o campo ja' digitado)     �
//������������������������������������������������������������������
If !Empty(aCols[n,nPosPro]) .and. !Empty(cVar) .and. aCols[n,nPosPro] <> cVar
	Help(" ",1,"A010ALTCHA")	// Campo nao pode ser alterado	
	lRetu := .f.
EndIf

If lRetu
	//�������������������������������������������������Ŀ
	//� Verifica se o Produto esta' cadastrado          �
	//���������������������������������������������������
	aCols[n,nPosPro] := M->QQ6_PRODUT
	If ! ExistCpo("QP6",aCols[n,nPosPro])
		lRetu := .f.
	EndIf
EndIf

//���������������������������������������������������������Ŀ
//� Verifica se o Produto ja' existe p/ esta Linha          �
//�����������������������������������������������������������
If lRetu
	For nI := 1 to len(aCols)
		If cVar == acols[nI,nPosPro] .and. nI <> n
			Help(" ",1,"A030EXIPRO")
			lRetu := .f.
		EndIf
	Next nI
EndIf

//������������������������������������������������������������Ŀ
//� Verifica se o Produto esta' relacionado a outra Linha      �
//��������������������������������������������������������������
If lRetu
	nReg := QQ6->(Recno())
	QQ6->(dbSetOrder(2))
	If QQ6->(dbSeek(xFilial("QQ6") + aCols[n,nPosPro]))
		If QQ6->QQ6_LINHA <> QQ5->QQ5_LINHA
			HELP(" ",1,"A030LINEXI",,QQ6->QQ6_LINHA,3,1)
			lRetu := .f.
		EndIf
	EndIf
	QQ6->(dbSetOrder(1))
	QQ6->(dbGoto(nReg))
EndIf

//�������������������������������������������������Ŀ
//� Preenche a Descricao do Produto                 �
//���������������������������������������������������
If lRetu
	aCols[n,nPosDPr] := QIPXDePr(aCols[n,nPosPro])
EndIf
Return(lRetu)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � a030DEqu � Autor � Marcelo Pimentel      � Data � 25/09/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gatilho para preencher a descricao da Equipe Follow-up     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � a030DEqu(ExpC1,ExpL1)                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo da Equipe                                   ���
���          � ExpL1 = Indica se e' gatilho                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico-Cham. no X3_RELACAO,X3_INIBRW e gat. (QQ5_EQUIPE) ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function a030DEqu(cCodEq,lGatilho)
lGatilho := Iif(lGatilho == NIL,.t.,lGatilho)

IF !Inclui .or. lGatilho	// Se Inic. Padrao ou gatilho a partir do cod. equipe
	QP4->(dbSeek(xFilial("QP4") + cCodEq))
	Return(QP4->QP4_DESCRI)
Else
	Return Space(Len(QP4->QP4_DESCRI))
Endif
