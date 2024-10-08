#INCLUDE "OMSM020.ch"
#include "FiveWin.ch"
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � DFata41  � Autor � Marcos Cesar          � Data � 20/07/1999 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Curva CAP : Essa curva tem como objetivo classificar os cli- ���
���          � entes quanto a frequencia de visitas, baseando-se no numero  ���
���          � de PDVs e na media mensal de vendas.                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � DFata41()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Especifico p/ Distribuidora Antarctica.                      ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS � Motivo da Alteracao                      ���
���������������������������������������������������������������������������Ĵ��
��� Cristiane    �11.02.00�      � Conversao p/ Protheus (DISM020)          ���
��� Moreto       �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Function DISM020()

Local oBtn1,oBtn2,oBtn3
Local oDlg

DEFINE MSDIALOG oDlg FROM 96,13 TO 310,592 TITLE STR0001 PIXEL //"Curva CAP"
//	@ 06,6 To 66,284
	@ 13,15 SAY OemToAnsi(STR0002) SIZE 250,7 OF oDlg PIXEL //"Este programa tem como objetivo classificar os clientes quanto a frequencia de visitas,"
	@ 23,15 SAY OemToAnsi(STR0003) SIZE 200,7 OF oDlg PIXEL //"baseando-se no numero de PDVs e na media mensal de vendas."

   @ 090,185 BUTTON oBtn1 PROMPT STR0004  ACTION (oDlg:End(),A41Proc()) SIZE 34,11 OF oDlg PIXEL //"Classificar"
   @ 090,223 BUTTON oBtn2 PROMPT STR0005  ACTION M020ClasCAP() SIZE 34,11 OF oDlg PIXEL //"Criterios"
	@ 090,260 BUTTON oBtn3 PROMPT STR0006  ACTION (oDlg:End()) SIZE 34,11 OF oDlg PIXEL //"Sair"
ACTIVATE DIALOG oDlg CENTERED

Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � A41Proc  � Autor � Marcos Cesar          � Data � 20/07/1999 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Processamento.                                    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � A41Proc()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � DFata41                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function A41Proc()

//��������������������������������������������������������������Ŀ
//� Array contendo o Total Geral de PDVs e do Potencial. Estrutu-�
//� ra.                                                          �
//�                                                              �
//� aArray[1] : Total de PDVs                                    �
//� aArray[2] : Total do Potencial de Venda                      �
//����������������������������������������������������������������

Local aTotal 		:= { 0, 0 }
Local oTempTable	:= Nil
//��������������������������������������������������������������Ŀ
//� Array contendo os Campos do Arquivo de Trabalho.             �
//����������������������������������������������������������������
Local aCamposTRB := {{ "TRB_COD"   , "C",  6, 0 },;  // Codigo do Cliente
					{ "TRB_LOJA"  , "C",  2, 0 },;  // Loja do Cliente
					{ "TRB_POTENC", "N", 12, 0 },;  // Potencial de Venda (Cerveja + Refrigerante)
					{ "TRB_CHAVE" , "C", 15, 0 }}   // Chave Descendente de Indexacao (Potencial * -1)

//��������������������������������������������������������������Ŀ
//� Cria, Abre e Indexa o Arquivo de Trabalho.                   �
//����������������������������������������������������������������
oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aCamposTRB )
oTempTable:AddIndex("01", {"TRB_CHAVE"} )
oTempTable:Create()

//��������������������������������������������������������������Ŀ
//� Geracao do Arquivo de Trabalho.                              �
//����������������������������������������������������������������
Processa( { || A41Trab(@aTotal) }, STR0008) //"Gerando Arquivo de Trabalho"

//��������������������������������������������������������������Ŀ
//� Processamento da Curva CAP.                                  �
//����������������������������������������������������������������
Processa( { || A41Curva(@aTotal) }, STR0001) //"Curva CAP"

//��������������������������������������������������������������Ŀ
//� Deleta o Arquivo de Trabalho.                                �
//����������������������������������������������������������������
oTempTable:Delete()

Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � A41Trab    � Autor � Marcos Cesar        � Data � 20/07/1999 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Geracao do Arquivo de Trabalho.                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � A41Trab()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � DFata41                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function A41Trab(aTotal)

Local nTotalPot := 0

//��������������������������������������������������������������Ŀ
//� Le o Arquivo SA1 (Cadastro de Clientes).                     �
//����������������������������������������������������������������
dbSelectArea("SA1")
ProcRegua(LastRec())
dbSetOrder(1)
dbSeek(xFilial())

While !Eof() .And. SA1->A1_FILIAL == xFilial()
	IncProc()

	//��������������������������������������������������������������Ŀ
	//� Calcula o Potencial Total (Cerveja + Refrigerante).          �
	//����������������������������������������������������������������
	nTotalPot := SA1->A1_POTCERV + SA1->A1_POTREFR

	//��������������������������������������������������������������Ŀ
	//� Grava o Arquivo de Trabalho.                                 �
	//����������������������������������������������������������������
	dbSelectArea("TRB")
	RecLock("TRB", .T.)

	TRB->TRB_COD    := SA1->A1_COD
	TRB->TRB_LOJA   := SA1->A1_LOJA
	TRB->TRB_POTENC := nTotalPot
	TRB->TRB_CHAVE  := StrZero(1000000000 - nTotalPot, 15, 0)

	MsUnLock()

	//��������������������������������������������������������������Ŀ
	//� Atualiza o Array contendo o Total Geral.                     �
	//����������������������������������������������������������������
	aTotal[1] := aTotal[1] + 1
	aTotal[2] := aTotal[2] + nTotalPot

	dbSelectArea("SA1")
	dbSkip()
End

Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � A41Curva   � Autor � Marcos Cesar        � Data � 20/07/1999 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Processamento da Curva CAP.                                  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � A41Curva()                                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � DFata41                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function A41Curva(aTotal)

Local nPercPDV := 0
Local nPercPot := 0

//��������������������������������������������������������������Ŀ
//� Le o Arquivo de Trabalho.                                    �
//����������������������������������������������������������������
dbSelectArea("TRB")
ProcRegua(LastRec())
dbGoTop()

While !Eof()
	IncProc()

	//��������������������������������������������������������������Ŀ
	//� Acumula o Percentual de PDVs.                                �
	//����������������������������������������������������������������
	nPercPDV := nPercPDV + ( (1 / aTotal[1]) * 100 )

	//��������������������������������������������������������������Ŀ
	//� Acumula o Percentual do Potencial de Venda.                  �
	//����������������������������������������������������������������
	nPercPot := nPercPot + ( (TRB->TRB_POTENC / aTotal[2]) * 100 )

	//��������������������������������������������������������������Ŀ
	//� Pesquisa o Arquivo DAT (Criterios de Classificacao da Curva  �
	//� CAP) p/ verificar em qual Classificacao o Cliente se enquadra�
	//����������������������������������������������������������������
	dbSelectArea("DAT")
	dbSetOrder(1)
	dbSeek(xFilial())

	While !Eof() .And. DAT->DAT_FILIAL == xFilial()
		If (nPercPDV >= DAT->DAT_M1PDV .And. nPercPDV <= DAT->DAT_M2PDV) .Or.;
			(nPercPot >= DAT->DAT_M1POT .And. nPercPot <= DAT->DAT_M2POT)
			//��������������������������������������������������������������Ŀ
			//� Pesquisa o Arquivo SA1 (Cadastro de Clientes) p/ gravar a    �
			//� Classificacao do Cliente.                                    �
			//����������������������������������������������������������������
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial() + TRB->TRB_COD + TRB->TRB_LOJA)

			If Found()
				RecLock("SA1", .F.)

				SA1->A1_CAP := DAT->DAT_CLASS

				MsUnLock()
			EndIf

			Exit
		EndIf

		dbSelectArea("DAT")
		dbSkip()
	End

	dbSelectArea("TRB")
	dbSkip()
End

Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � DFata411 � Autor � Marcos Cesar          � Data � 20/07/1999 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Esse ExecBlock permite ao usuario, atraves de uma MultiLine, ���
���          � informar os criterios de classificacao da Curva CAP.         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � DFata411()                                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Especifico p/ Distribuidora Antarctica.                      ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS � Motivo da Alteracao                      ���
���������������������������������������������������������������������������Ĵ��
��� Cristiane    �11.02.00�      � Conversao p/ Protheus (DISM020) - RdMake ���
��� Moreto       �        �      � DFATA411.PRW -> Funcao M020ClasCAP       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function M020ClasCAP()
Local oDlg1
Local nA:= 0

	aHeader := {}
	aCols   := {}
	nUsado  := 0
	nOpcx   := 3
	aRotina := {{ STR0009,"AxPesqui", 0 , 1 },; //"Pesquisar"
					{ STR0010, "AxVisual",0 , 2 },; //"Visualizar"
					{ STR0011, "AxInclui",0 , 3 },; //"Incluir"
					{ STR0012, "AxAltera",0 , 4 },; //"Alterar"
					{ STR0013, "AxDeleta",0 , 5 } } //"Excluir"

	cCadastro := OemToAnsi(STR0014) //"Criterios de Classificacao da Curva CAP"
	cAlias    := "DAT"
	nReg      := 1

	FillGetDados(nOpcx,"DAT",1)

	//��������������������������������������������������������������Ŀ
	//� Dialog do Criterio de Classificacao.                         �
	//����������������������������������������������������������������
	DEFINE MSDIALOG oDlg1 FROM 200,0 TO 540,600 TITLE cCadastro PIXEL
		//��������������������������������������������������������������Ŀ
		//� Exibe a GetDados.                                            �
		//����������������������������������������������������������������
		oGetD:=MsGetDados():New(05,5,140,295,nOpcx,"AllWaysTrue()","M020Valid()",,.T.,,1)

		//��������������������������������������������������������������Ŀ
		//� Botoes.                                                      �
		//����������������������������������������������������������������
		DEFINE SBUTTON FROM 150,237 TYPE 01 ACTION (A411Grava(),oDlg1:End()) ENABLE OF oDlg1
		DEFINE SBUTTON FROM 150,267 TYPE 02 ACTION (oDlg1:End()) ENABLE OF oDlg1
	ACTIVATE DIALOG oDlg1 CENTERED

Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � A411Grava� Autor � Marcos Cesar          � Data � 20/07/1999 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Grava o Arquivo DAT (Criterios da Curva CAP).                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � A411Grava()                                                  ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � DFata411                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function A411Grava()

Local lRet  := .T.
Local nItem := 0
Local nPosClass := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_CLASS"})
Local nPosM1PDV := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_M1PDV"})
Local nPosM2PDV := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_M2PDV"})
Local nPosM1POT := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_M1POT"})
Local nPosM2POT := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_M2POT"})
Local nPosFreq  := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_FREQ"})
Local nA:= 0
//��������������������������������������������������������������Ŀ
//� Validacao dos Criterios informados.                          �
//����������������������������������������������������������������
lRet := M020Valid()

If lRet
	//��������������������������������������������������������������Ŀ
	//� Deleta os Registros no Arquivo DAT (Criterios de Classifica- �
	//� cao da Curva CAP).                                           �
	//����������������������������������������������������������������
	dbSelectArea("DAT")
	dbSetOrder(1)
	dbSeek(xFilial())

	While !Eof() .And. DAT->DAT_FILIAL == xFilial()
		RecLock("DAT", .F.)
			dbDelete()
		MsUnLock()

		dbSkip()
	End

	//��������������������������������������������������������������Ŀ
	//� Inclui os Registros no Arquivo DAT (Criterios de Classifica- �
	//� cao da Curva CAP).                                           �
	//����������������������������������������������������������������
	For nA := 1 To Len(aCols)
		//��������������������������������������������������������������Ŀ
		//� Verifica se esta Deletado.                                   �
		//����������������������������������������������������������������
		If aCols[nA][nUsado + 1]
			Loop
		EndIf

		nItem := nItem + 1

		//��������������������������������������������������������������Ŀ
		//� Grava o Arquivo DAT.                                         �
		//����������������������������������������������������������������
		dbSelectArea("DAT")
		RecLock("DAT", .T.)

		DAT->DAT_FILIAL := xFilial()
		DAT->DAT_ITEM   := StrZero(nItem,2)
		DAT->DAT_CLASS  := aCols[nA][nPosClass]
		DAT->DAT_M1PDV  := aCols[nA][nPosM1PDV]
		DAT->DAT_M2PDV  := aCols[nA][nPosM2PDV]
		DAT->DAT_M1POT  := aCols[nA][nPosM1POT]
		DAT->DAT_M2POT  := aCols[nA][nPosM2POT]
		DAT->DAT_FREQ   := aCols[nA][nPosFreq]

		MsUnLock()
	Next nA

EndIf

Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � DFata413 � Autor � Marcos Cesar          � Data � 21/07/1999 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Esse ExecBlock valida os Criterios informados pelo Usuario.  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � DFata413()                                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Especifico p/ Distribuidora Antarctica.                      ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS � Motivo da Alteracao                      ���
���������������������������������������������������������������������������Ĵ��
��� Cristiane    �11.02.00�      � Conversao p/ Protheus (DISM020) - RdMake ���
��� Moreto       �        �      � DFATA413.PRW -> M020Valid                ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Function M020Valid()

Local lRet := .T.
Local nAnt := 0
Local nPos := 0
Local nPosClass := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_CLASS"})
Local nPosM1PDV := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_M1PDV"})
Local nPosM2PDV := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_M2PDV"})
Local nPosM1POT := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_M1POT"})
Local nPosM2POT := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_M2POT"})
Local nPosFreq  := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_FREQ"})
Local nA			 := 0
//��������������������������������������������������������������Ŀ
//� Verifica se os Valores estao corretos.                       �
//����������������������������������������������������������������
If !aCols[n][nUsado + 1]
	//��������������������������������������������������������������Ŀ
	//� Verifica se existe Campo Obrigatorio em Branco.              �
	//����������������������������������������������������������������
	If Empty(aCols[n][nPosClass])
      Aviso(STR0016,STR0015,{'OK'})
		lRet := .F.
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Verifica se a Classificacao ja esta cadastrada.              �
	//����������������������������������������������������������������
	For nA := 1 To Len(aCols)
		If !aCols[nA][nUsado + 1] .And. nA <> n
			If aCols[nA][nPosClass] == aCols[n][nPosClass]
            Aviso(STR0016,STR0017,{'OK'})
				lRet := .F.

				Exit
			EndIf
		EndIf
	Next nA

	//��������������������������������������������������������������Ŀ
	//� Verifica se o Percentual de PDVs da Classificacao ultrapassa �
	//� 100 %.                                                       �
	//����������������������������������������������������������������
	If lRet .And. (aCols[n][nPosM1PDV] > 100 .Or. aCols[n][nPosM2PDV] > 100)
       Aviso(STR0016,STR0018,{'OK'})
		lRet := .F.
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Verifica se o Percentual de Potencial da Classificacao ultra-�
	//� passa 100 %.                                                 �
	//����������������������������������������������������������������
	If lRet .And. (aCols[n][nPosM1Pot] > 100 .Or. aCols[n][nPosM2Pot] > 100)
       Aviso(STR0016,STR0018,{'OK'})
		lRet := .F.
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Verifica se o Percentual de PDVs da Classificacao esta corre-�
	//� to.                                                          �
	//����������������������������������������������������������������
	If lRet .And. aCols[n][nPosM1PDV] > aCols[n][nPosM2PDV]
      Aviso(STR0016,STR0019,{'OK'})
		lRet := .F.
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Verifica se o Percentual de Potencial da Classificacao esta  �
	//� correto.                                                     �
	//����������������������������������������������������������������
	If lRet .And. aCols[n][nPosM1Pot] > aCols[n][nPosM2Pot]
      Aviso(STR0016,STR0020,{'OK'})
		lRet := .F.
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Compara os Percentuais com a Classificacao Anterior.         �
	//����������������������������������������������������������������
	nAnt := n - 1

	If nAnt >= 1 .And. !aCols[nAnt][nUsado + 1]
		//��������������������������������������������������������������Ŀ
		//� Verifica se o Percentual de PDVs da Classificacao esta corre-�
		//� to com o Percentual da Classificacao anterior.               �
		//����������������������������������������������������������������
		If lRet .And. aCols[n][nPosM1PDV] <= aCols[nAnt][nPosM2PDV]
         Aviso(STR0016,STR0021,{'OK'})			
			lRet := .F.
		EndIf

		//��������������������������������������������������������������Ŀ
		//� Verifica se o Percentual de Potencial da Classificacao esta  �
		//� correto com o Percentual da Classificacao anterior.          �
		//����������������������������������������������������������������
		If lRet .And. aCols[n][nPosM1Pot] <= Acols[nAnt][nPosM2Pot]
         Aviso(STR0016,STR0022,{'OK'})			
			lRet := .F.
		EndIf
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Compara os Percentuais com a Classificacao Posterior.        �
	//����������������������������������������������������������������
	nPos := n + 1

	If nPos <= Len(aCols) .And. !aCols[nPos][nUsado + 1]
		//��������������������������������������������������������������Ŀ
		//� Verifica se o Percentual de PDVs da Classificacao esta corre-�
		//� to com o Percentual da Classificacao posterior.              �
		//����������������������������������������������������������������
		If lRet .And. aCols[n][nPosM2PDV] >= aCols[nPos][nPosM1PDV]
         Aviso(STR0016,STR0023,{'OK'})
         lRet := .F.
		EndIf

		//��������������������������������������������������������������Ŀ
		//� Verifica se o Percentual de Potencial da Classificacao esta  �
		//� correto com o Percentual da Classificacao posterior.         �
		//����������������������������������������������������������������
		If lRet .And. aCols[n][nPosM2Pot] >= Acols[nPos][nPosM1Pot]
          Aviso(STR0016,STR0024,{'OK'})
			lRet := .F.
		EndIf
	EndIf
EndIf

Return(lRet)
