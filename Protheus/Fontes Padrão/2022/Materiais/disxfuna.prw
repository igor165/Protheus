#include "PROTHEUS.CH"

Function _XFunNaoExiste()
DBRECALL()
return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao	 �FEmbtoUni � Autor � Waldemiro L. Lustosa  � Data � 11/08/1999 ���
���������������������������������������������������������������������������Ĵ��
��� Descricao� Fun��o de Convers�o - Quantidade de Embalagens para Quantida-���
���			 � de em Unidades.															 ���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � Especifico (DISTRIBUIDORES)											 ���
���������������������������������������������������������������������������Ĵ��
��� Sintaxe  � FEmbtoUni(ExpC1,ExpC2)													 ���
���������������������������������������������������������������������������Ĵ��
���Par�metros� ExpC1 - Quantidade em Embalagens (utilizando sempre o formato���
���			 � 		  9999/999, podendo variar apenas a quantidade de		 ���
���			 � 		  n�meros utilizados.											 ���
���			 � ExpC2 - C�digo do Produto a ser pesquisado.						 ���
���������������������������������������������������������������������������Ĵ��
��� Retorno  � ExpN1 - Quantidade em Unidades de Produto 						 ���
���������������������������������������������������������������������������Ĵ��
��� Descricao da Revisao									� Responsavel �	Data	 ���
���������������������������������������������������������������������������Ĵ��
���																�				  �	/	/	 ���
���������������������������������������������������������������������������Ĵ��
���																�				  �			 ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function FEmbtoUni(cQtdEmbal,cCodItOrNot)

Local nRet   := 0 
Local aArea  := GetArea()
Local nPosAt := 0

// �����������������������������������������������������������������Ŀ
// � Verifico se produto, caso informado, n�o tenha vindo em branco, �
// � mesmo que esta fun��o esteja sendo utilizada em relat�rios ou	�
// � em processamentos, executo o Help, estas rotinas precisam tratar�
// � a situa��o. �����������������������������������������������������
// ���������������
If Type("cCodItOrNot") == "C" .And. Empty(cCodItOrNot)
	Help(" ",1,"FDPRODNAOI") // Produto n�o informado
Else
	// ������������������������������������������������������������������Ŀ
	// � Verifica se existe conte�do a ser convertido no campo informado  �
	// ��������������������������������������������������������������������
	If !Empty(StrTran(StrTran(cQtdEmbal,"/",""),"0",""))

		// ���������������������������������������Ŀ
		// � Armazena �reas de Trabalho utilizadas �
		// �����������������������������������������
		dbSelectArea("SB1")
		// ���������������������������������������������������������������������Ŀ
		// � Busca Quantidade na Unidade Padr�o do Produto informado, verifica a �
		// � formata��o e efetua a convers�o �������������������������������������
		// �����������������������������������
		dbSelectArea("SB1")
		dbSetOrder(1)
      If Empty(cCodItOrNot) .Or. dbSeek(xFilial()+cCodItOrNot)
			If	FieldPos("B1_QTDUPAD")>0
				If !Empty(SB1->B1_QTDUPAD)
					nPosAt := At("/",cQtdEmbal)
					If nPosAt > 0
							nRet := ( Val(Left(cQtdEmbal,nPosAt-1)) * SB1->B1_QTDUPAD ) + Val(Right(cQtdEmbal,Len(cQtdEmbal)-nPosAt))
					Else
						// M�scara incorreta
						Help(" ",1,"FDMASKINVA")
					EndIf
				Else
					// Quantidade na Unidade Padr�o n�o cadastrada
					Help(" ",1,"FDCONVUPAD",,SB1->B1_COD,05,10)
				EndIf
			EndIf
		EndIf
      If !Empty(cCodItOrNot) .And. !Found()
			// Produto n�o existe no SB1
         Help(" ",1,"NOPRODUTO",,cCodItOrNot,05,01)
		EndIf

		// ���������������������������������������Ŀ
		// � Restaura �reas de Trabalho utilizadas �
		// �����������������������������������������

	EndIf
EndIf

RestArea(aArea)

Return(nRet)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao	 �FUnitoEmb � Autor � Waldemiro L. Lustosa  � Data � 11/08/1999 ���
���������������������������������������������������������������������������Ĵ��
��� Descricao� Fun��o de Convers�o - Quantidade em Unidades para Quantidade ���
���			 � em Embalagens. 															 ���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � Especifico (DISTRIBUIDORES)											 ���
���������������������������������������������������������������������������Ĵ��
��� Sintaxe  � FUnitoEmb(ExpN1,ExpC1)													 ���
���������������������������������������������������������������������������Ĵ��
���Par�metros� ExpN1 - Quantidade em Unidades										 ���
���			 � ExpC1 - C�digo do Produto a ser pesquisado.						 ���
���������������������������������������������������������������������������Ĵ��
��� Retorno  � ExpC3 - Quantidade em Embalagens 									 ���
���������������������������������������������������������������������������Ĵ��
��� Descricao da Revisao									� Responsavel �	Data	 ���
���������������������������������������������������������������������������Ĵ��
���																�				  �	/	/	 ���
���������������������������������������������������������������������������Ĵ��
���																�				  �			 ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function FUnitoEmb(nQuantidade,cCodItOrNot,cPictEmb)

Local cRet := " ", aArea := {}, cPictMV, nPosAt
Local nRight, nLeft, _i, nQtdLeft := 0, nQtdRight := 0

// �����������������������������������������������������������������Ŀ
// � Verifico se produto, caso informado, n�o tenha vindo em branco, �
// � mesmo que esta fun��o esteja sendo utilizada em relat�rios ou	�
// � em processamentos, executo o Help, estas rotinas precisam tratar�
// � a situa��o. �����������������������������������������������������
// ���������������
If Type("cCodItOrNot") == "C" .And. Empty(cCodItOrNot)
	Help(" ",1,"FDPRODNAOI") // Produto n�o informado
Else
	//���������������������������������������Ŀ
	//� Armazena �reas de Trabalho utilizadas �
	//�����������������������������������������
	Aadd( aArea, { Alias(), IndexOrd(), Recno() } )
	dbSelectArea("SB1")
	Aadd( aArea, { Alias(), IndexOrd(), Recno() } )

   cPictMV := IIf(Empty(cPictEmb),Alltrim(GetMV("MV_PICTDIS")),cPictEmb)
	nPosAt := At("/",cPictMV)  
	If !Empty(cPictMV) .And. nPosAt > 0 .And. ValType(nQuantidade) == "N"
		dbSelectArea("SB1")
		dbSetOrder(1)
      If Empty(cCodItOrNot) .Or. dbSeek(xFilial()+cCodItOrNot)
			nLeft  := 0
			nRight := 0
			For _i := 1 to Len(cPictMV)
				If Subs(cPictMV,_i,1) == "9" .And. _i < nPosAt
					nLeft++
				ElseIf Subs(cPictMV,_i,1) == "9" .And. _i > nPosAt
					nRight++
				EndIf
			Next _i
			If	SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD)
				nQtdLeft  := Int(nQuantidade / SB1->B1_QTDUPAD)
				nQtdRight := Int(nQuantidade % SB1->B1_QTDUPAD)
				cRet := Str(nQtdLeft,nLeft,0) + "/" + Str(nQtdRight,nRight,0)
			Else
				cRet := Str(nQuantidade,nLeft,0) + "/" + Str(0,nRight,0)
			EndIf
		EndIf
      If !Empty(cCodItOrNot) .And. !Found()
			// Produto n�o existe no SB1
         Help(" ",1,"NOPRODUTO",,cCodItOrNot,05,01)
		EndIf
	Else
		// Picture inv�lida para este campo
		Help(" ",1,"FDNOPICT",,cPictMV,05,10)
	EndIf

	//���������������������������������������Ŀ
	//� Restaura �reas de Trabalho utilizadas �
	//�����������������������������������������
	For _i := Len(aArea) to 1 Step -1
		dbSelectArea(aArea[_i][1])
		dbSetOrder(aArea[_i][2])
		If Recno() != aArea[_i][3]
			dbGoto(aArea[_i][3])
		EndIf
	Next _i
EndIf

Return(cRet)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao	 �FChkEmbal � Autor � Waldemiro L. Lustosa  � Data � 11/08/1999 ���
���������������������������������������������������������������������������Ĵ��
��� Descricao� Fun��o de Valida��o da Campo de Embalagem digitado.			 ���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � Especifico (DISTRIBUIDORES)											 ���
���������������������������������������������������������������������������Ĵ��
��� Sintaxe  � FChkEmbal(ExpC1,ExpC2)													 ���
���������������������������������������������������������������������������Ĵ��
���Par�metros� ExpC1 - Quantidade em Embalagens (utilizando sempre o formato���
���			 � 		  9999/999, podendo variar apenas a quantidade de		 ���
���			 � 		  n�meros utilizados.											 ���
���			 � ExpC2 - C�digo do Produto a ser Pesquisado.						 ���
���������������������������������������������������������������������������Ĵ��
��� Retorno  � ExpL1 - .T. ou .F.														 ���
���������������������������������������������������������������������������Ĵ��
��� Descricao da Revisao									� Responsavel �	Data	 ���
���������������������������������������������������������������������������Ĵ��
���																�				  �	/	/	 ���
���������������������������������������������������������������������������Ĵ��
���																�				  �			 ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function FChkEmbal(cQtdEmbal,cCodItOrNot)

Local nPosAt, lRet := .T., aArea := {}
Local _i  := 0

// �����������������������������������������������������������������Ŀ
// � Verifico se produto, caso informado, n�o tenha vindo em branco, �
// � mesmo que esta fun��o esteja sendo utilizada em relat�rios ou	�
// � em processamentos, executo o Help, estas rotinas precisam tratar�
// � a situa��o. �����������������������������������������������������
// ���������������
If Type("cCodItOrNot") == "C" .And. Empty(cCodItOrNot)
	Help(" ",1,"FDPRODNAOI") // Produto n�o informado
Else

	// ���������������������������������������Ŀ
	// � Armazena �reas de Trabalho utilizadas �
	// �����������������������������������������
	Aadd( aArea, { Alias(), IndexOrd(), Recno() } )
	dbSelectArea("SB1")
	Aadd( aArea, { Alias(), IndexOrd(), Recno() } )

	dbSelectArea("SB1")
	dbSetOrder(1)
   If ( Empty(cCodItOrNot) .Or. dbSeek(xFilial()+cCodItOrNot) ) .And. SB1->B1_TIPO != "PV"
		// ����������������������������������������������������������������Ŀ
		// � Verifica se pelo menos a barra existe no campo e se o segundo  �
		// � par�metro foi informado ����������������������������������������
		// ���������������������������
		cQtdEmbal := Alltrim(cQtdEmbal)
		nPosAt := At("/",cQtdEmbal)
		If nPosAt == 0
			lRet := .F.
		Else
			If Empty(SB1->B1_QTDUPAD)
				// Quantidade na Unidade Padr�o n�o cadastrada
				Help(" ",1,"FDCONVUPAD",,SB1->B1_COD,05,10)
				lRet := .F.
			Else
				If Val(Right(cQtdEmbal,Len(cQtdEmbal)-nPosAt)) > SB1->B1_QTDUPAD
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	// ���������������������������������������Ŀ
	// � Restaura �reas de Trabalho utilizadas �
	// �����������������������������������������
	For _i := Len(aArea) to 1 Step -1
		dbSelectArea(aArea[_i][1])
		dbSetOrder(aArea[_i][2])
		If Recno() != aArea[_i][3]
			dbGoto(aArea[_i][3])
		EndIf
	Next _i

EndIf

Return(lRet)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao	 �BuscaCols � Autor � Waldemiro L. Lustosa  � Data � 13/08/1999 ���
���������������������������������������������������������������������������Ĵ��
��� Descricao� Fun��o de Busca de dados em um aCols na posi��o "n"          ���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � Gen�rico 																	 ���
���������������������������������������������������������������������������Ĵ��
��� Sintaxe  � BuscaCols(ExpC1)															 ���
���������������������������������������������������������������������������Ĵ��
���Par�metros� ExpC1 - Campo do aCols a ser pesquisado.							 ���
���������������������������������������������������������������������������Ĵ��
��� Retorno  � ExpU1 - Conte�do do Campo naquela posi��o do aCols 			 ���
���������������������������������������������������������������������������Ĵ��
��� Descricao da Revisao									� Responsavel �	Data	 ���
���������������������������������������������������������������������������Ĵ��
���																�				  �	/	/	 ���
���������������������������������������������������������������������������Ĵ��
���																�				  �			 ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function BuscaCols(cCampo)

Return aCols[n][aScan(aHeader,{|x|AllTrim(x[2])==cCampo})]



/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � CriarSX6   � Autor � Marcos Cesar        � Data � 21/10/1999 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Cria parametro no arquivo SX6.                               ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � CriarSX6(ExpC1,ExpC2,ExpC3,ExpC4)                            ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Par�metros� ExpC1 : Nome do Parametro                                    ���
���          � ExpC2 : Tipo do dado (Numerico, Caracter, etc.)              ���
���          � ExpC3 : Descricao                                            ���
���          � ExpC4 : Conteudo                                             ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Siga Distribution                                            ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function CriarSX6(cNome, cTipo, cDescricao, cConteudo)

Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �DxAcresLin� Autor �Silvio Cazela          � Data � 24.11.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina Para Pular Para Linha Abaixo Quando Digitado        ���
���          � Quantidado na GetDados do Pedido de Venda.                 ���
�������������������������������������������������������������������������Ĵ��
���Utilizacao� Distribution                                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function DxAcresLin(cCampo)

//��������������������������������������������������Ŀ
//�Utilizado como ultima validacao do campo, passando�
//�como parametro o campo em que a mesma esta sendo  �
//�utilizada.                                        �
//����������������������������������������������������


Local cAlias := Alias()
Local nReg   := Recno()
Local lRet   := .T.
Local cVariavel := "M->"+cCampo
Local cConteudo := &cVariavel
Private nPosQuant, nPosProd

nPosCpo := Ascan(aHeader,{|x| Upper(AllTrim(x[2])) == cCampo})

If cConteudo > 0 .and. n == 1
	oGetDad:oBrowse:bEditcol := { || Iif(aCols[n][Ascan(aHeader,{|x| Upper(AllTrim(x[2])) == cCampo})]>0 .And. oGetDad:LinhaOk(),(oGetDad:oBrowse:GoDown(),oGetDad:oBrowse:nColPos := 1) ,Nil)}
	n:= Len(acols)
	oGetDad:oBrowse:Refresh()
Endif	

dbSelectarea(cAlias)
dbGoto(nReg)

Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �D630Descon| Autor � Silvio Cazela         � Data �15.03.2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravacao dos Falgs de Indenizacoes e Extrado de Descontos  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
���Revis�o	 � 													  � Data �			  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function D630Descon(cPedido)

Local nCnt     := 0
Local cTipo    := ""
Local cChave   := ""
Local cVerba   := Upper(AllTrim(GetMv("MV_VERBA")))
Local nVerba   := 0
Local nVerbaBn := 0
Local nLimite  := GetNewPar("MV_INDPERC",80)/100
Local nTotPed  := 0
Local nValInd  := 0

DbSelectArea("SC6")           
DbSetOrder(1)
DbSeek(xFilial("SC6")+cPedido)
While !eof() .and. SC6->C6_NUM == cPedido
	SC9->(dbSetOrder(1))
	If SC9->(dbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM))
		If (SC9->C9_BLEST == "  " ) .And. ( SC9->C9_BLEST != "10" .And. SC9->C9_BLCRED != "10" )
			nTotPed := nTotPed + SC6->C6_VALOR
		Endif
	Endif						
	DbSelectArea("SC6")           
	DbSkip()
End

If INCLUI

	For nCnt := 1 to len(aDistrInd)
	
		cTipo  := aDistrInd[nCnt][1]
		cChave := xFilial("SC6")+cPedido+aDistrInd[nCnt][9]+aDistrInd[nCnt][4]
		
		If cTipo == "I"
		
			nValInd := aDistrInd[nCnt][3]
			
			If nValInd>(nTotPed*nLimite)
				aDistrInd[nCnt][3] := nTotPed*nLimite
				DbSelectArea("SC5")
				RecLock("SC5",.f.)
				SC5->C5_DESCONT := aDistrInd[nCnt][3]
				MsUnLock()
			Endif 

			//������������������������������������������������������Ŀ
			//�Se houve indenizacao gravo status da indenizaxao com P�
			//��������������������������������������������������������
			
			DbSelectArea("DB1")
			DbSetOrder(1)
			If DbSeek(xFilial("DB1")+aDistrInd[nCnt][2]) .And. ( aDistrInd[nCnt][3] > 0 )
				RecLock("DB1",.f.)
					DB1->DB1_OK := "P "
				MsUnLock()
			Endif				
				
			DbSelectArea("DB2")
			DbSetOrder(1)
			If DbSeek(xFilial("DB2")+aDistrInd[nCnt][2]) .And. ( aDistrInd[nCnt][3] > 0 )
				While !eof() .and. ( DB2->DB2_NUM == aDistrInd[nCnt][2] )
					RecLock("DB2",.f.)
					DB2->DB2_STATUS := "P"
					DB2->Db2_DOC    := cPedido
					MsUnLock()
					DbSkip()
				Enddo      
			Endif				
		Endif 
		
		//�����������������������������������������������������������������������Ŀ
		//� Gravacao do Extrato de Descontos de Indenizacao                       �
		//�������������������������������������������������������������������������
		
		
		DbSelectArea("SC6")
		DbSetOrder(1)
		If DbSeek(cChave) .or. aDistrInd[nCnt][1]=="I"
			DbSelectArea("DBH")
			RecLock("DBH",.t.)
			DBH->DBH_FILIAL := xFilial("DBH")
			DBH->DBH_TPDESC := aDistrInd[nCnt][1]
			DBH->DBH_TIPO   := "P" //Pedido
			DBH->DBH_STATUS := "P" //Pedido
			DBH->DBH_CLIENT := M->C5_CLIENTE
			DBH->DBH_LOJA   := M->C5_LOJACLI
			DBH->DBH_CODDES := aDistrInd[nCnt][2]
			DBH->DBH_PRODUT := Iif(cTipo=="I","INDENIZACAO",aDistrInd[nCnt][4])
			DBH->DBH_VALDES := aDistrInd[nCnt][3]
			DBH->DBH_DATA   := ddatabase
			DBH->DBH_OK     := "NC"
			DBH->DBH_OBS    := "EM PEDIDO"
			DBH->DBH_PEDIDO := cPedido
			DBH->DBH_ITEMPV := aDistrInd[nCnt][5]
			DBH->DBH_SERIE  := ""
			DBH->DBH_DOC    := ""
			DBH->DBH_ITEM   := ""
			DBH->DBH_PERC   := aDistrInd[nCnt][6]*100
			DBH->DBH_KIBON  := aDistrInd[nCnt][7]
			DBH->DBH_DISTR  := aDistrInd[nCnt][8]
			MsUnLock()
		Endif
		

		//Baixa no Controle de Verbas
		If cVerba # "N" .and. aDistrInd[nCnt][1]#"I"
			If cVerba$"EG"
				nVbEmp := 0
				DbSelectArea("DB6")
				DbSetOrder(3)
				DbGoTop()
				While !eof()
					If DB6->DB6_DATAI <= ddatabase .and. DB6->DB6_DATAF >= ddatabase
						RecLock("DB6",.f.)
						DB6->DB6_SALDO := DB6->DB6_SALDO - aDistrInd[nCnt][3]
						MsUnLock()
						Exit
					Endif
					DbSkip()
				End
			Endif
			If cVerba$"CG"
				DbSelectArea("DBJ")
				DbSetOrder(1)
				If DbSeek(xFilial("DBJ")+M->C5_CLIENTE+M->C5_LOJACLI)
					If DBJ->DBJ_DATAI <= ddatabase .and. DBJ->DBJ_DATAF >= ddatabase
						RecLock("DBJ",.f.)
						DBJ->DBJ_SALDO := DBJ->DBJ_SALDO - aDistrInd[nCnt][3] + nVerba
						MsUnLock()
					Endif
				Endif
			Endif
		Endif

	Next

	If AllTrim(Upper(GetMv("MV_VERBABN"))) == "S"
		DbSelectArea("SC6")
		DbSetOrder(1)
		DbSeek(xFilial("SC6")+cPedido)
		While !Eof() .and. SC6->C6_NUM == cPedido
			If Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_TPMOV") == "B"
				nVerbaBn := nVerbaBn + SC6->C6_VALOR
			Endif
			DbSkip()
		End
	
		DbSelectArea("DB6")
		DbSetOrder(3)
		DbGoTop()
		While !eof()
			If DB6->DB6_DATAI <= ddatabase .and. DB6->DB6_DATAF >= ddatabase
				RecLock("DB6",.f.)
				DB6->DB6_SALDOBN := DB6->DB6_SALDOBN - nVerbaBn
				MsUnLock()
				Exit
			Endif
			DbSkip()
		End
	Endif

Elseif ALTERA

	DbSelectArea("DBH")
	DbSetOrder(7)
	For nCnt := 1 to len(aDistrInd)
	
		//Exclusao do Extrato de Descontos
		If DbSeek(xFilial("DBH")+cPedido+aDistrInd[nCnt][5])
			RecLock("DBH",.f.)
			nVerba := DBH->DBH_VALDES
			DbDelete()
			MsUnLock()
		Endif
				
		//Recalculo do Extrato de Descontos
		DbSelectArea("DBH")
		RecLock("DBH",.t.)
		DBH->DBH_FILIAL := xFilial("DBH")
		DBH->DBH_TPDESC := aDistrInd[nCnt][1]
		DBH->DBH_TIPO   := "P" //Pedido
		DBH->DBH_STATUS := "P" //Pedido
		DBH->DBH_CLIENT := M->C5_CLIENTE
		DBH->DBH_LOJA   := M->C5_LOJACLI
		DBH->DBH_CODDES := aDistrInd[nCnt][2]
		DBH->DBH_PRODUT := Iif(cTipo=="I","INDENIZACAO",aDistrInd[nCnt][4])
		DBH->DBH_VALDES := aDistrInd[nCnt][3]
		DBH->DBH_DATA   := ddatabase
		DBH->DBH_OK     := "NC"
		DBH->DBH_OBS    := "EM PEDIDO"
		DBH->DBH_PEDIDO := cPedido
		DBH->DBH_ITEMPV := aDistrInd[nCnt][5]
		DBH->DBH_SERIE  := ""
		DBH->DBH_DOC    := ""
		DBH->DBH_ITEM   := ""
		DBH->DBH_PERC   := aDistrInd[nCnt][6]*100
		DBH->DBH_KIBON  := aDistrInd[nCnt][7]
		DBH->DBH_DISTR  := aDistrInd[nCnt][8]
		MsUnLock()

		//Baixa no Controle de Verbas
		If cVerba # "N" .and. aDistrInd[nCnt][1]#"I"
			If cVerba$"EG"
				nVbEmp := 0
				DbSelectArea("DB6")
				DbSetOrder(3)
				DbGoTop()
				While !eof()
					If DB6->DB6_DATAI <= ddatabase .and. DB6->DB6_DATAF >= ddatabase
						RecLock("DB6",.f.)
						DB6->DB6_SALDO := DB6->DB6_SALDO - aDistrInd[nCnt][3] + nVerba
						MsUnLock()
						Exit
					Endif
					DbSkip()
				End
			Endif
			If cVerba$"CG"
				DbSelectArea("DBJ")
				DbSetOrder(1)
				If DbSeek(xFilial("DBJ")+M->C5_CLIENTE+M->C5_LOJACLI)
					If DBJ->DBJ_DATAI <= ddatabase .and. DBJ->DBJ_DATAF >= ddatabase
						RecLock("DBJ",.f.)
						DBJ->DBJ_SALDO := DBJ->DBJ_SALDO - aDistrInd[nCnt][3] + nVerba
						MsUnLock()
					Endif
				Endif
			Endif
		Endif
	Next

Elseif !INCLUI .and. !ALTERA // Exclusao

	DbSelectArea("DB2")
	DbSetOrder(2)
	If DbSeek(xFilial("DB2")+cPedido+"P")
		While !eof() .and. DB2->DB2_DOC == cPedido .and. DB2->DB2_STATUS == "P"
			RecLock("DB2",.f.)
			DB2->DB2_STATUS := "L"
			DB2->DB2_SALDO  := DB2->DB2_VLTOT
			MsUnLock()
			DbSelectArea("DB1")
			DbSetOrder(1)
			DbSeek(xFilial("DB1")+DB2->DB2_NUM)
			RecLock("DB1",.f.)
			DB1->DB1_OK := "L "
			MsUnLock()
			DbSelectArea("DB2")
			DbSkip()
		End
	Endif

	//�����������������������������������������������������������������������Ŀ
	//� Excluir Registro do Extrato de Descontos de Indenizacao               �
	//�������������������������������������������������������������������������

	DbSelectArea("DBH")
	DbSetOrder(7)
	DbSeek(xFilial("DBH")+cPedido)
	While !eof() .and. DBH_PEDIDO == cPedido
		nVerba := nVerba + iif(DBH->DBH_TPDESC#"I",DBH->DBH_VALDES,0)
		RecLock("DBH",.f.)
		DbDelete()
		MsUnLock()
		DbSkip()
	End

	//Baixa no Controle de Verbas
	If cVerba # "N"
		If cVerba$"EG"
			nVbEmp := 0
			DbSelectArea("DB6")
			DbSetOrder(3)
			DbGoTop()
			While !eof()
				If DB6->DB6_DATAI <= ddatabase .and. DB6->DB6_DATAF >= ddatabase
					RecLock("DB6",.f.)
					DB6->DB6_SALDO := DB6->DB6_SALDO + nVerba
					MsUnLock()
					Exit
				Endif
				DbSkip()
			End
		Endif
		If cVerba$"CG"
			DbSelectArea("DBJ")
			DbSetOrder(1)
			If DbSeek(xFilial("DBJ")+M->C5_CLIENTE+M->C5_LOJACLI)
				If DBJ->DBJ_DATAI <= ddatabase .and. DBJ->DBJ_DATAF >= ddatabase
					RecLock("DBJ",.f.)
					DBJ->DBJ_SALDO := DBJ->DBJ_SALDO + nVerba
					MsUnLock()
				Endif
			Endif
		Endif
	Endif

Endif

Return .t.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �D630Deleta| Autor � Silvio Cazela         � Data �22.03.2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Extorno de Geracao de Notas (Descontos/Indenizacoes)       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
���Revis�o	 � 													  � Data �			  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function D630Deleta(cNotaSer,aPedido)

Local aArea   := Alias()
Local x       := 0

DbSelectArea("DBH")
DbSetOrder(1)	
DbSeek(xFilial("DBH")+cNotaSer)
While !eof() .and. DBH->DBH_DOC+DBH->DBH_SERIE == cNotaSer
	RecLock("DBH",.f.)
	DBH->DBH_STATUS := iif(DBH->DBH_TPDESC="B","X","P")
	DBH->DBH_OBS    := "NF "+cNotaSer+" Cancelada em "+dtoc(ddatabase)
	DBH->DBH_OK     := "NC"
	MsUnLock()
	DbSkip()
End

DbSelectArea("DB2")
DbSetOrder(1)
If DbSeek(xFilial("DB2")+Subs(cNotaSer,1,TAMSX3("F2_DOC")[1])+Subs(cNotaSer,TAMSX3("F2_DOC")[1]+1,SerieNfId("SF2",6,"F2_SERIE")))
	While !eof() .and. DB2->DB2_NOTA+DB2->DB2_SERIE == cNotaSer
		RecLock("DB2",.f.)
		DB2->DB2_STATUS := "P "
		DB2->DB2_NOTA   := Space(TAMSX3("F2_DOC")[1])
		DB2->DB2_SERIE  := Space(SerieNfId("SF2",6,"F2_SERIE"))
		MsUnLock()
		DbSelectArea("DB1")
		DbSetOrder(1)
		If DbSeek(xFilial("DB1")+DB2->DB2_NUM)
			RecLock("DB1",.f.)
			DB1->DB1_OK := "P "
			MsUnLock()
		Endif
		DbSelectArea("DB2")		
		DbSkip()
	End
Endif

//Extorno de Carga
For x:=1 to len(aPedido)
	dbselectarea("SC5")
	dbsetorder(1)
	If dbseek(xFilial("SC5")+aPedido[x][1])
		RecLock("SC5",.f.)
		Replace  C5_Transp   with  Space(06),;
	  			 C5_Entreg   with  Space(03),;
				 C5_Ajud     with  Space(03),;
				 C5_Ajud2    with  Space(03),;
				 C5_Ajud3    with  Space(03),;
				 C5_NumCg    with  Space(06)
		MsUnLock()
	EndIf
Next

DbSelectArea(aArea)

Return .t.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �D630DelItem|Autor � Silvio Cazela         � Data �22.03.2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Extorno de Geracao de Notas (Descontos/Indenizacoes) Item  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
���Revis�o	 � 													  � Data �			  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function D520DelItem()

//Bonificacao
If AllTrim(Upper(GetMv("MV_VERBABN"))) == "S"
	DbSelectArea("DB6")
	DbSetOrder(3)
	DbGoTop()
	While !eof()
		If DB6->DB6_DATAI <= ddatabase .and. DB6->DB6_DATAF >= ddatabase
			RecLock("DB6",.f.)
			DB6->DB6_SALDOBN := DB6->DB6_SALDOBN + SD2->D2_TOTAL
			MsUnLock()
			Exit
		Endif
		DbSkip()
	End
Endif

//Carregamento
dbselectarea("SC5")
dbsetorder(1)
If dbseek(xFilial("SC5")+SD2->D2_PEDIDO)
	RecLock("SC5",.f.)
	Replace  C5_Transp   with  Space(06),;
				C5_Entreg   with  Space(03),;
				C5_Ajud     with  Space(03),;
				C5_Ajud2    with  Space(03),;
				C5_Ajud3    with  Space(03),;
				C5_NumCg    with  Space(06)
	MsUnLock()
EndIf

Return NIL

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � DC6TPMOV � Autor � Alex Egydio           � Data � 16/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � C6_TPMOV                                                     ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function DC6TPMOV()
//�����������������������������������������������������������������Ŀ
//� Funcao utilizada para verificar a ultima versao dos fontes      �
//� SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        �
//�������������������������������������������������������������������
IF !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

M->C6_TES := D410VlC6Tp()
If Empty(M->C6_TES)
	M->C6_TES := RetFldProd(SB1->B1_COD,"B1_TS")
Endif	
Return(.T.)
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � DUBQTEMB � Autor � Silvio Cazela         � Data � 17/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � UB_QTEMB                                                     ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function DUBQTEMB()

Local aArea := {Alias(),IndexOrd(),RecNo()}

DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xFilial("SB1")+BuscaCols("UB_PRODUTO"))
M->UB_QUANT   := If(SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD),FEmbtoUni(M->UB_QTEMB),BuscaCols("UB_QUANT"))
DbSelectArea(aArea[1])
DbSetOrder(aArea[2])
DbGoTo(aArea[3])

M->UB_UNSVEN  := BuscaCols("UB_QUANT") * SB1->B1_CONV

DbSelectArea("DA1")
DbSetOrder(1)
DbSeek(xFilial("DA1")+BuscaCols("UB_TABESP")+BuscaCols("UB_PRODUTO"))
M->UB_VRUNIT  := If(BuscaCols("UB_TABESP") <> "999",DA1->DA1_UNILIQ,BuscaCols("UB_VRUNIT"))
DbSelectArea(aArea[1])
DbSetOrder(aArea[2])
DbGoTo(aArea[3])

M->UB_VLRITEM := BuscaCols("UB_QUANT")*BuscaCols("UB_VRUNIT")
M->UB_PREMB   := IF(BuscaCols("UB_TABESP") <> "999",DA1->DA1_PRCLIQ,M->UB_PREMB)
M->UB_QTEMB   := If(SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD),FUnitoEmb(BuscaCols("UB_QUANT")),BuscaCols("UB_QTEMB"))
																															
Return .t.
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � DUBTABESP� Autor � Silvio Cazela         � Data � 17/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � UB_TABESP                                                    ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function DUBTABESP()

Local aArea := {Alias(),IndexOrd(),RecNo()}

DbSelectArea("DA1")
DbSetOrder(1)
DbSeek(xFilial("DA1")+BuscaCols("UB_TABESP")+BuscaCols("UB_PRODUTO"))
M->UB_VRUNIT  := IF(BuscaCols("UB_TABESP") <> "999",DA1->DA1_UNILIQ,BuscaCols("UB_VRUNIT"))
DbSelectArea(aArea[1])
DbSetOrder(aArea[2])
DbGoTo(aArea[3])

M->UB_PRCLIQ  := If(BuscaCols("UB_TABESP") <> "999",DA1->DA1_UNILIQ,BuscaCols("UB_PRCEMB"))
M->UB_UNITAR  := If(BuscaCols("UB_TABESP") <> "999",DA1->DA1_UNITAR,BuscaCols("UB_VRUNIT"))
M->UB_VLRITEM := BuscaCols("UB_VRUNIT")*BuscaCols("UB_QUANT")
M->UB_PREMB   := IF(BuscaCols("UB_TABESP") <> "999",DA1->DA1_PRCLIQ,M->UB_PREMB)

Return .t.

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � DDANQTEMD� Autor � Silvio Cazela         � Data � 17/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � DAN_QTEMBD                                                   ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D330QTEMD()
Local aArea   := {Alias(),IndexOrd(),RecNo()}
Local nDanCod := aScan(aHeader,{|x|Alltrim(x[2])=="DAN_COD"})
Local nQtDev  := aScan(aHeader,{|x|Alltrim(x[2])=="DAN_QTDEV"})
Local nQtEmbD := aScan(aHeader,{|x|Alltrim(x[2])=="DAN_QTEMBD"})
Local nSegDev := aScan(aHeader,{|x|Alltrim(x[2])=="DAN_SEGDEV"})
Local cCampo  := ReadVar()

DbSelectArea("SB1")
DbSetOrder(1)
If DbSeek(XFILIAL("SB1")+aCols[n,nDanCod])

	Do Case
		Case cCampo == "M->DAN_QTDEV"
		
			If nQtEmbd > 0
				aCols[n,nQtEmbD] := If(SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD),FUnitoEmb(BuscaCols("DAN_QTDEV")),aCols[n,nQtEmbD])
			Endif
			
			If nSegdev > 0	
				aCols[n,nSegDev]:= ConvUm(SB1->B1_COD,M->DAN_QTDEV,0,2)
			Endif
		Case cCampo == "M->DAN_QTEMBD"                         
		
			aCols[n,nQtDev]     := If(SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD),FEmbtoUni(M->DAN_QTEMBD),aCols[n,nQtDev])
			
			If nSegdev > 0	
				aCols[n,nSegDev]:= ConvUm(SB1->B1_COD,aCols[n,nQtDev],0,2)
			Endif
			
		Case cCampo == "M->DAN_SEGDEV"
		
			aCols[n,nQtDev]     := ConvUm(SB1->B1_COD,0,M->DAN_SEGDEV,1)
			
			If nQtEmbd > 0
				aCols[n,nQtEmbD] := If(SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD),FUnitoEmb(BuscaCols("DAN_QTDEV")),aCols[n,nQtEmbD])
			Endif
			
	Endcase				
	   
Endif
	
DbSelectArea(aArea[1])
DbSetOrder(aArea[2])
DbGoTo(aArea[3])
Return .t.

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �D330QTEMBQ� Autor � Silvio Cazela         � Data � 17/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � DAN_QTEMBQ                                                   ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D330QTEMBQ()
Local aArea  := {Alias(),IndexOrd(),RecNo()}
Local nDANCod:=aScan(aHeader,{|x|Alltrim(x[2])=="DAN_COD"})
Local nQtQue :=aScan(aHeader,{|x|Alltrim(x[2])=="DAN_QTQUE"})
Local nQtEmbq:=aScan(aHeader,{|x|Alltrim(x[2])=="DAN_QTEMBQ"})
Local nSegQue:=aScan(aHeader,{|x|Alltrim(x[2])=="DAN_SEGQUE"})

DbSelectArea("SB1")
DbSetOrder(1)
If DbSeek(XFILIAL("SB1")+aCols[n,nDANCod])

	Do Case
		Case cCampo == "M->DAN_QTQUE"
		
			If nSegQue > 0	
				aCols[n,nSegQue]:= ConvUm(SB1->B1_COD,M->DAN_QTQUE,0,2)
			Endif
		
			If nQtEmbq > 0
				aCols[n,nQtEmbq] := If(SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD),FUnitoEmb(BuscaCols("DAN_QTQUE")),aCols[n,nQtEmbQ])
			Endif       
			
		Case cCampo == "M->DAN_QTEMBQ"
		
			aCols[n,nQtQue]     := If(SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD),FEmbtoUni(M->DAN_QTEMBQ),aCols[n,nQtQue])
			
			If nSegQue > 0	
				aCols[n,nSegQue]:= ConvUm(SB1->B1_COD,aCols[n,nQtQue],0,2)
			Endif
			
		Case cCampo == "M->DAN_SEGQUE"
			aCols[n,nQtQue]     := ConvUm(SB1->B1_COD,0,M->DAN_SEGQUE,1)
			If nQtEmbQ > 0
				aCols[n,nQtEmbQ] := If(SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD),FUnitoEmb(BuscaCols("DAN_QTQUE")),	aCols[n,nQtEmbQ])
			Endif
	Endcase				
	
Endif	
DbSelectArea(aArea[1])
DbSetOrder(aArea[2])
DbGoTo(aArea[3])
Return .t.

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �D330QTEMBO� Autor � Silvio Cazela         � Data � 17/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � DAN_QTEMBO                                                   ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D330QTEMBO()
Local aArea   := {Alias(),IndexOrd(),RecNo()}
Local nQtOut  := aScan(aHeader,{|x|Alltrim(x[2])=="DAN_QTOUT"})
Local nQtEmbO := aScan(aHeader,{|x|Alltrim(x[2])=="DAN_QTEMBO"})
Local nDANCod := aScan(aHeader,{|x|Alltrim(x[2])=="DAN_COD"})
Local nSegOut := aScan(aHeader,{|x|Alltrim(x[2])=="DAN_SEGOUT"})

DbSelectArea("SB1")
DbSetOrder(1)
If dbSeek(XFILIAL("SB1")+aCols[n,nDANCod])

	Do Case
		Case cCampo == "M->DAN_QTOUT"
		
			If nSegOut > 0	
				aCols[n,nSegOut]:= ConvUm(SB1->B1_COD,M->DAN_QTOUT,0,2)
			Endif
		
			If nQtEmbO > 0
				aCols[n,nQtEmbO] := If(SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD),FUnitoEmb(BuscaCols("DAN_QTOUT")),aCols[n,nQtEmbO])
			Endif       
			
		Case cCampo == "M->DAN_QTEMBO"
		
			aCols[n,nQtOut]     := If(SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD),FEmbtoUni(M->DAN_QTEMBD),aCols[n,nQtOut])
			
			If nSegOut > 0	
				aCols[n,nSegOut]:= ConvUm(SB1->B1_COD,aCols[n,nQtOut],0,2)
			Endif
			
		Case cCampo == "M->DAN_SEGOUT"
			aCols[n,nQtOut]     := ConvUm(SB1->B1_COD,0,M->DAN_SEGOUT,1)
			If nQtEmbO > 0
				aCols[n,nQtEmbO] := If(SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD),FUnitoEmb(BuscaCols("DAN_QTOUT")),	aCols[n,nQtEmbO])
			Endif
	Endcase				
	
Endif	
	
DbSelectArea(aArea[1])
DbSetOrder(aArea[2])
DbGoTo(aArea[3])

Return .t.
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � D290DAQNF� Autor � Silvio Cazela         � Data � 17/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � DAQ_NF                                                       ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D290DAQNF()
Local aArea  := {Alias(),IndexOrd(),RecNo()}
Local nSerie :=aScan(aHeader,{|x|Alltrim(x[2])=="DAQ_SERIE"})
Local nClient:=aScan(aHeader,{|x|Alltrim(x[2])=="DAQ_CLIENT"})
Local nLoja  :=aScan(aHeader,{|x|Alltrim(x[2])=="DAQ_LOJA"})

aCols[n,nSerie] := SD2->D2_SERIE
aCols[n,nClient]:= SD2->D2_CLIENTE
aCols[n,nLoja]  := SD2->D2_LOJA

DbSelectArea(aArea[1])
DbSetOrder(aArea[2])
DbGoTo(aArea[3])
Return .t.
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao   �D410VLC5CL� Autor � Octavio Moreira       � Data � 19/07/1999 ���
���������������������������������������������������������������������������Ĵ��
���Nome Orig.� RFATA40  �                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Descricao� Validacao do cliente digitado no cabecalho do pedido de venda���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (ANTARCTICA)                                      ���
���������������������������������������������������������������������������Ĵ��
��� Solicit. � Nerimar Mendes                                               ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Objetivos� Esse execblock deve preencher o codigo do cliente com zeros a���
���          � esquerda, visando facilitar a digitacao do usuario, que fica ���
���          � desobrigado de preencher completamente o codigo do cliente.  ���
���������������������������������������������������������������������������Ĵ��
��� Observ.  � Essa rotina e' chamada no X3_VALID do campo C5_CLIENTE e deve���
���          � ser revisada apos atualizacao de versao                      ���
���������������������������������������������������������������������������Ĵ��
��� Descricao da Revisao                           � Responsavel �   Data   ���
���������������������������������������������������������������������������Ĵ��
���Bloqueia Pedidos para clientes Inativos         �Karla        � 24.07.99 ���
���������������������������������������������������������������������������Ĵ��
���Conversao Protheus( D410VLC5CL )                �             �          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function D410VLC5CL()
Local cAlias,nOrder,nRecno,lRet
//��������������������������������������������������������������Ŀ
//� Verifica se nao e' devolucao ou beneficiamento               �
//����������������������������������������������������������������
If !M->C5_TIPO $ "BD"
   //��������������������������������������������������������������Ŀ
   //� Guarda registro original                                     �
   //����������������������������������������������������������������
   cAlias   := Alias()
   nOrder   := IndexOrd()
   nRecno   := Recno()
   lRet     :=.t.

   M->C5_CLIENTE := If(Val(M->C5_CLIENTE)==0,M->C5_CLIENTE,Strzero(Val(M->C5_CLIENTE),6))

   //��������������������������������������������������������������Ŀ
   //� Posiciona Cadastro de Clientes                               �
   //����������������������������������������������������������������
   dbSelectArea("SA1")
   dbSetOrder(1)
   dbSeek(xFilial()+M->C5_CLIENTE)
   If Found()
      While SA1->A1_COD == M->C5_CLIENTE .AND. !EOF()
         If SA1->A1_SITUACA == "02" .OR. SA1->A1_SITUACA == "03"
           lRet:=.f.
           DbSkip()
           Loop
         Else
           lRet:=.t.
           M->C5_LOJACLI:=SA1->A1_LOJA
           Exit
         Endif
      End
   Endif
   If !lRet
      Help("",1,"DSFATA401") //Cliente inativo
      dbSeek(xFilial()+M->C5_CLIENTE)
   Endif

   //��������������������������������������������������������������Ŀ
   //� Retorna ao registro original                                 �
   //����������������������������������������������������������������
   dbSelectArea(cAlias)
   dbSetOrder(nOrder)
   dbGoto(nRecno)
Else
   lRet := .t.
EndIf

Return(lRet)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �D410VLC6TP� Autor � Octavio Moreira       � Data � 19/08/1999 ���
���������������������������������������������������������������������������Ĵ��
���Nome Orig.� DFATA48  �                                                 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Execblock que retorna o TES a partir de parametros           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � DFata48()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros� SE4->E4_MODELO, SA1->A1_TIPO, _cAlmox (local), SB1->B1_COD   ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Especifico p/ Distribuidora                                  ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS � Motivo da Alteracao                      ���
���������������������������������������������������������������������������Ĵ��
���              �        �      � Conversao Protheus(D410VlC6Tp)           ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D410VlC6Tp()

Local cAlmox   := ""
Local cTpMov   := ""
Local cCfoRet  := ""
Local cModelo  := ""
Local cTipoCli := ""
Local cLocal   := ""
Local cTes     := CriaVar("C6_TES")
Local cCodProduto := ""
Local cSpaceProd  := CriaVar("B1_COD")
Local cSpaceLoc   := CriaVar("B1_LOCPAD")
Local cSpaceTp    := CriaVar("C6_TPMOV")      
Local cSpaceTpCli := CriaVar("A1_TIPO")      

//�����������������������������������������������������������������Ŀ
//� Funcao utilizada para verificar a ultima versao dos fontes      �
//� SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        �
//�������������������������������������������������������������������
IF !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

//��������������������������������������������������������������Ŀ
//� Prepara a variavel de local de estoque como parametro        �
//����������������������������������������������������������������

If ExistBlock("D410INT")
   ExecBlock("D410INT",.F.,.F.)
   Return(.T.)
Endif

If "_LOCAL" $ ReadVar()
   If FUNNAME(1)$"MATA410.MATA440.MATA450.MATA455.MATA456"
      cAlmox := M->C6_LOCAL
   Else
      cAlmox := M->UB_LOCAL
   EndIf
Else
	If FUNNAME(1)$"MATA410.MATA440.MATA450.MATA455.MATA456"
      cAlmox := BuscaCols("C6_LOCAL")
   Else
      cAlmox := BuscaCols("UB_LOCAL")
   EndIf
EndIf

//��������������������������������������������������������������Ŀ
//� Prepara a do tipo de movimento (do SC5 ou do SC6)            �
//����������������������������������������������������������������
If FUNNAME(1)$"MATA410.MATA440.MATA450.MATA455.MATA456"
   If !Empty(BuscaCols("C6_TPMOV"))
      cTpMov := BuscaCols("C6_TPMOV")
   Else
      cTpMov := M->C5_TPMOV
   EndIf
Else
   cTpMov := BuscaCols("UB_TPMOV")
EndIf

//��������������������������������������������������������������Ŀ
//� Pressupoe que o cliente, o produto e a condicao de pagamento �
//� estejam posicionados e chama a funcao que busca no DA2       �
//����������������������������������������������������������������
If FUNNAME(1)$"MATA410.MATA440.MATA450.MATA455.MATA456"
   cTesRet := DlaTesInt(cTpMov,M->C5_TIPOCLI,cAlmox,SB1->B1_COD)
Else
   cModelo     := cTpMov
   cTipoCli    := SA1->A1_TIPO
   cLocal      := cAlmox
   cCodProduto := SB1->B1_COD

   If cModelo == Nil .And. cTipoCli == Nil .And. cLocal == Nil .And. cCodProduto == Nil
      cTipoCli    := SA1->A1_TIPO
      cLocal      := cAlmoxar
      cCodProduto := SB1->B1_COD
   EndIf

   //��������������������������������������������������������������Ŀ
   //� Primeiro Seek no Arquivo DA2 (Cadastro De/Para de TES).      �
   //� Chave : Filial + Tipo Venda + Tipo Cliente + Local + Produto �
   //����������������������������������������������������������������
   dbSelectArea("DA2")
   dbSetOrder(1)
   If !dbSeek(xFilial() + cModelo + cTipoCli + cLocal + cCodProduto)

      //��������������������������������������������������������������Ŀ
      //� Segundo Seek no Arquivo DA2 (Cadastro De/Para de TES).       �
      //� Chave : Filial + Tipo Venda + Tipo Cliente + Local           �
      //����������������������������������������������������������������
      dbSelectArea("DA2")
      dbSetOrder(1)
      If !dbSeek(xFilial() + cModelo + cTipoCli + cLocal + cSpaceProd)

         //��������������������������������������������������������������Ŀ
         //� Terceiro Seek no Arquivo DA2 (Cadastro De/Para de TES).      �
         //� Chave : Filial + Tipo Venda + Tipo Cliente + Local           �
         //����������������������������������������������������������������
         dbSelectArea("DA2")
         dbSetOrder(1)
         If !dbSeek(xFilial() + cModelo + cTipoCli + cSpaceLoc + cSpaceProd)
            //��������������������������������������������������������������Ŀ
            //� Quarto Seek no Arquivo DA2 (Cadastro De/Para de TES).        �
            //� Chave : Filial + Tipo Venda + Tipo Cliente                   �
            //����������������������������������������������������������������
            dbSelectArea("DA2")
            dbSetOrder(1)
            dbSeek(xFilial() + cModelo + cSpaceTpCli + cSpaceLoc + cSpaceProd)
         EndIf
      EndIf
   EndIf

   //��������������������������������������������������������������Ŀ
   //� Verifica qual TES sera usado.                                �
   //����������������������������������������������������������������
   cTes := Iif(DA2->DA2_TES == "P  ", RetFldProd(SB1->B1_COD,"B1_TS"), DA2->DA2_TES)

   //��������������������������������������������������������������Ŀ
   //� Pesquisa o Arquivo SF4 (Tipos de Entrada e Saida).           �
   //����������������������������������������������������������������
   dbSelectArea("SF4")
   dbSetOrder(1)
   If !dbSeek(xFilial() + cTes)
      cTes := Space(3)
   EndIf
   cTesRet := cTes

EndIf

//��������������������������������������������������������������Ŀ
//� Acerta o cfo de acordo com o TES selecionado                 �
//����������������������������������������������������������������
If !Empty(cTesRet)
	dbSelectArea("SF4")
	dbSetOrder(1)
	dbSeek(xFilial("SF4")+cTesRet)

   If FUNNAME(1)$"MATA410.MATA440.MATA450.MATA455.MATA456"
      If M->C5_TIPO $ "DB"
         cCfoRet := IIF(M->C5_TIPOCLI!="X",iif(SA2->A2_EST == GetMv("MV_ESTADO"),SF4->F4_CF,"6"+Subs(SF4->F4_CF,2,LEN(SF4->F4_CF)-1)),"7"+Subs(F4_CF,2,LEN(SF4->F4_CF)-1))
      Else
         cCfoRet := IIF(M->C5_TIPOCLI!="X",iif(SA1->A1_EST == GetMv("MV_ESTADO"),SF4->F4_CF,"6"+Subs(SF4->F4_CF,2,LEN(SF4->F4_CF)-1)),"7"+Subs(F4_CF,2,LEN(SF4->F4_CF)-1))
      EndIf
   Else
      cCfoRet := IIF(SA1->A1_TIPO!="X",iif(SA1->A1_EST == GetMv("MV_ESTADO"),SF4->F4_CF,"6"+Subs(SF4->F4_CF,2,LEN(SF4->F4_CF)-1)),"7"+Subs(F4_CF,2,LEN(SF4->F4_CF)-1))
   EndIf
Else
	cCfoRet := "   "
EndIf

If FUNNAME(1)$"MATA410.MATA440.MATA450.MATA455.MATA456"
   aCols[n][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_CF"})]  := cCfoRet
   aCols[n][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_TES"})] := cTesRet
Else
   aCols[n][Ascan(aHeader,{|x|AllTrim(x[2])=="UB_CF"})]  := cCfoRet
   aCols[n][Ascan(aHeader,{|x|AllTrim(x[2])=="UB_TES"})] := cTesRet
EndIf

Return(.T.)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �D330VLMOT � Autor � Marcos Eduardo Rocha  � Data � 10/11/1999 ���
���������������������������������������������������������������������������Ĵ��
���Nome Orig.� DFATA61  �                                                   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � ExecBlock, disparado como Gatilho pelo DAN_MOTIVO, para      ���
���          � replicar o motivo de devolucao para todos os itens no acerto ���
���          � de carga.                                                    ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Especifico p/ Distribuidora Antarctica.                      ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      � Conversao Protheus( D330VlMot )          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D330VlMot()
Local nPosMotivo := Ascan(aHeader,{|x| AllTrim(x[2]) == "DAN_MOTIVO"})
Local nPosDescri := Ascan(aHeader,{|x| AllTrim(x[2]) == "DAN_DESMOT"})
Local nProc

For nProc := 1 To Len(Acols)
   If Empty(Acols[nProc,nPosMotivo])
      Acols[nProc,nPosMotivo] := Acols[n,nPosMotivo]
      Acols[nProc,nPosDescri] := Acols[n,nPosDescri]
   EndIf
Next

Return(.T.)
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �D410VLVEND� Autor � Marcos Cesar          � Data � 31/07/1999 ���
���������������������������������������������������������������������������Ĵ��
���Nome Orig.� DFATA45  �                                                 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rdmake p/ atualizar o Campo C5_VEND1 com o Codigo do Vendedor���
���          � relacionado ao Cliente. Caso exista mais de 1 Vendedor rela- ���
���          � cionado ao Cliente, o campo sera deixado em branco.          ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � DFata45()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Especifico p/ Distribuidora Antarctica.                      ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS � Motivo da Alteracao                      ���
���������������������������������������������������������������������������Ĵ��
���              �        �      � Conversao Protheus ( D410VlVend )        ���
���������������������������������������������������������������������������Ĵ��
���Berriel       �29/04/00�      �Exibir o vend p/+ de 1 rota               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D410VlVend()
Local cAliasAnt,nOrderAnt,nRecnoAnt
cCliente  := &(ReadVar())
cVendedor := Space(6)
nPercurso := 0
cPerc1    := space(06)
cPerc2    := space(06)
cCli1     := space(06)
cCli2     := space(06)

//��������������������������������������������������������������Ŀ
//� Salva o Ambiente.                                            �
//����������������������������������������������������������������
cAliasAnt := Alias()
nOrderAnt := IndexOrd()
nRecnoAnt := Recno()

//��������������������������������������������������������������Ŀ
//� Pesquisa o Arquivo DA7 (Cadastro de Clientes por Rota).      �
//����������������������������������������������������������������
dbSelectArea("DA7")
dbSetOrder(2)
dbSeek(xFilial() + cCliente + M->C5_LOJACLI)

While !Eof() .And. DA7->DA7_CLIENT == cCliente .And. DA7->DA7_LOJA == M->C5_LOJACLI

   dbSelectArea("DA5")
   dbSetOrder(1)
   dbSeek(xFilial()+DA7->DA7_PERCUR)

   If !Eof()
   	cVendedor := DA5->DA5_VENDED
   EndIf

	dbSelectArea("DA7")

   cPerc1 := DA7->DA7_PERCUR
   cCli1  := DA7->DA7_CLIENT
	dbSkip()
   cPerc2 := DA7->DA7_PERCUR
   cCli2  := DA7->DA7_CLIENT

   If (cPerc1 <> cPerc2) .and. (cCli1 == cCli2)
      nPercurso := nPercurso + 1
   Endif

EndDo

//��������������������������������������������������������������Ŀ
//� Caso o Cliente esteja cadastrado em dois ou mais Percursos,  �
//� retorna em branco o Codigo do Vendedor.                      �
//����������������������������������������������������������������
cVendedor := Iif(nPercurso == 0, cVendedor, Space(6))

//��������������������������������������������������������������Ŀ
//� Restaura o Ambiente.                                         �
//����������������������������������������������������������������
dbSelectArea(cAliasAnt)
dbSetOrder(nOrderAnt)
dbGoto(nRecnoAnt)

Return(cVendedor)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �DVLC6TES  � Autor � Almir Bandina         � Data � 08.02.00 ���
�������������������������������������������������������������������������Ĵ��
���Nome Orig.� RESTA02  �                                                 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calculo da Base e do ICMS retido de acordo com aliquota    ���
���          � interna ou do cadastro do produto quando for o caso, na    ���
���          � digitacao de notas fiscais de entrada.                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
���Revis�o   � Conversao Protheus( DVLC6TES )           � Data �          ���
���          �                                          �      �          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function DVLC6TES()
nBaseRet := BuscaCols("D1_BRICMS")
nIcmsRet := BuscaCols("D1_ICMSRET")
cTes     := BuscaCols("D1_TES")

If AllTrim(Upper(ReadVar())) == "M->D1_BRICMS"
	nBaseRet := &(ReadVar())
ElseIf AllTrim(Upper(ReadVar())) == "M->D1_ICMSRET"
	nIcmsRet := &(ReadVar())
ElseIf AllTrim(Upper(ReadVar())) == "M->D1_TES"
	cTes     := &(ReadVar())
EndIf

If SB1->B1_VLR_ICM != 0
	nBaseRet := (SB1->B1_VLR_ICM * BuscaCols("D1_QUANT")) / Max(SB1->B1_QTDUPAD,1)
	nIcmsPad := If(!Empty(SB1->B1_PICM),SB1->B1_PICM,GetMv("MV_ICMPAD"))/100
	nIcmsRet := (nBaseRet * nIcmsPad) - BuscaCols("D1_VALICM")
EndIf

aCols[n][(aScan(aHeader,{|x|AllTrim(x[2])=="D1_BRICMS" }))] := nBaseRet
aCols[n][(aScan(aHeader,{|x|AllTrim(x[2])=="D1_ICMSRET"}))] := nIcmsRet

Return(cTes)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � DVLE3HIST� Autor �Andreia Silva          � Data � 19.07.99 ���
�������������������������������������������������������������������������Ĵ��
���Nome Orig.� EFINA02  �                                                 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Calculo do INSS para pagamento de RPA's                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico para Antarctica - Bauru                         ���
�������������������������������������������������������������������������Ĵ��
��� Revisao  � Conversao Protheus( DVLE2HIST )          � Data �          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function DVLE2HIST()
//��������������������������������������������������������������Ŀ
//� Cria Variaveis                                               �
//����������������������������������������������������������������

nValor    := M->E2_VALOR
nINSS     := M->E2_INSS
nValAtu   := 0

If M->E2_TIPO == "RPA"
   nValAtu := nValor + nINSS
Else
   nValAtu := nValor
Endif

Return(nValAtu)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � DVL1E1HIS� Autor �Andreia Silva          � Data � 03.08.99 ���
�������������������������������������������������������������������������Ĵ��
���Nome Orig.� EFINA03  �                                                 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Calculo do INSS para pagamento de RPA's                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico para Antarctica - Bauru                         ���
�������������������������������������������������������������������������Ĵ��
��� Revisao  � Coversao Protheus( DVL1E2HIS )           � Data �          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function DVL1E2HIS()
//��������������������������������������������������������������Ŀ
//� Cria Variaveis                                               �
//����������������������������������������������������������������

If M->E2_TIPO == "RPA"

   nValorE2  := M->E2_VALOR
   nINSSE2   := M->E2_INSS
   nAtuValE2 := 0
   nAtuValE2 := nValorE2

   Return(nAtuValE2)
Else
   Return(M->E2_VLCRUZ)
Endif
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �D225TERUM � Autor �Andrea Marques Federson� Data � 30/06/99 ���
�������������������������������������������������������������������������Ĵ��
���Nome Orig.� DESTA07  �                                                 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inicializador Padrao 3a.Unidade de Medida                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
��� Revis�o  �                                          � Data �          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function D225TERUM(cCampo)
IF INCLUI
	cRetCpo  := ""
ELSE
	//��������������������������������������������������������������Ŀ
	//� Inicializa Variaveis                                         �
	//����������������������������������������������������������������
	//cCampo   := PARAMIXB						   Parametro ExecBlock (Campo)
	cProduto := cCampo + "COD" 		      // Produto
	cCod     := &(cProduto) 		         // Produto
	cTERUM   := "SB1->B1_TERUM"          // Terceira Unidade
	cRetCpo  := ""
	
	//��������������������������������������������������������������Ŀ
	//� Posiciona Cadastro de Produtos                               �
	//����������������������������������������������������������������
	dbselectarea ("SB1")
	dbsetorder(1)
	dbseek(xFilial("SB1") + cCod)	
	If eof()
		HELP(" ",1,"REGNOIS")	
	ELSE
		cRetCpo := &(cTERUM)
	ENDIF
ENDIF
//��������������������������������������������������������������Ŀ
//� Retorna Unidade de Medida                                    �
//����������������������������������������������������������������
Return(cRetCpo)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � DS460GRAV� Autor � Waldemiro L. Lustosa  � Data � 09/07/1999 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Grava��o do C9_NFISCAL (MATA460)                             ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                  ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
��� Projetos     �19.05.00�      �Conversao PROTHEUS a460grav               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function DS460GRAV()
Local awArea := { Alias(), IndexOrd(), Recno() }

If !Empty(SC9->C9_CARGA) 

   // �����������������������������������������������������������������Ŀ
   // � Posiciono o DAI e o DAK para uso destas informa��es no Ponto de �
   // � Entrada MSD2460.PRX ���������������������������������������������
   // �����������������������
   dbSelectArea("DAK")
   dbSetOrder(1)
   If dbSeek(xFilial("DAK")+SC9->C9_CARGA+SC9->C9_SEQCAR)
      dbSelectArea("DAI")
      dbSetOrder(1)
      dbSeek(xFilial("DAI")+SC9->C9_CARGA+SC9->C9_SEQCAR+SC9->C9_PEDIDO)
   EndIf

Else
   // �������������������������������������������Ŀ
   // � For�o o desposicionamento (por precau��o) �
   // ���������������������������������������������
   dbSelectArea("DAK")
   dbGoBottom()
   dbSkip()
   dbSelectArea("DAI")
   dbGoBottom()
   dbSkip()
EndIf

dbSelectArea(awArea[1])
dbSetOrder(awArea[2])
If Recno() != awArea[3]
   dbGoto(awArea[3])
EndIf  

Return 

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao   � DSSD2520 � Autor �Andrea Marques Federson� Data � 08/07/1999 ���
���������������������������������������������������������������������������Ĵ��
��� Descricao� Ponto de Entrada na Exclusao da NF de Saida                  ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                  ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
��� Waldemiro    �26/07/99�      � Adequa��o ao Tratamento de Segunda       ���
���              �        �      � Embalagem e Corre��es.                   ���
���������������������������������������������������������������������������Ĵ��
��� Waldemiro    �31/08/99�      � Reestrutura��o completa do processo de   ���
���              �        �      � atualiza��o/exclus�o dos arquivos DAI/DAK���
���              �        �      � (Montagem de Carga).                     ���
���������������������������������������������������������������������������Ĵ��
��� Projetos     �19/05/00�      �Conversao PROTHEUS MSD2520                ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function DSSD2520()
//��������������������������������������������������������������Ŀ
//� Guarda registro original                                     �
//����������������������������������������������������������������
Local cAlias := Alias()
Local nOrder := IndexOrd()
Local nRecno := Recno()
Local awArea := {}
Local n520Quant := 0
Local nCapArm := 0
Local cSeek,nRecSD2,lBuscaSC9,lExistNF,wi,cCODEMBA
//��������������������������������������������������������������Ŀ
//� Caso a carga esteja gerada, estorna os registros no DAI e DAK�
//����������������������������������������������������������������
If !Empty(SD2->D2_CARGA)

   // ��������������������������������Ŀ
   // � Guarda posi��es de arquivos    �
   // ����������������������������������
   dbSelectArea("SF2")
   Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
   dbSelectArea("SD2")
   Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
   dbSelectArea("SB1")
   Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
   dbSelectArea("SC9")
   Aadd( awArea, { Alias(), IndexOrd(), Recno() } )

   // �����������������������������������������������������������������Ŀ
   // � MsgStop tempor�rios, situa��es que n�o devem acontecer (s� em   �
   // � casos de falha de integridade de Base de Dados)                 �
   // �������������������������������������������������������������������
   If Empty(SF2->F2_CARGA)
      MsgStop("D2_CARGA preenchido com Carga "+SD2->D2_CARGA+" e F2_CARGA em branco na Nota "+SD2->D2_DOC)
   ElseIf SD2->D2_CARGA != Left(SF2->F2_CARGA,6)
      MsgStop("D2_CARGA e F2_CARGA incompat�veis na Nota "+SF2->F2_DOC)
   Else
      // ����������������������������������Ŀ
      // � Posiciono o DAI a partir do SF2  �
      // ������������������������������������
      dbSelectArea("DAI")
      dbSetOrder(1)
      If !dbSeek(xFilial()+SF2->F2_CARGA+SD2->D2_PEDIDO)
         MsgStop("Carga/Sequencia "+SF2->F2_CARGA+" do Pedido "+SD2->D2_PEDIDO+" n�o localizada no DAI")
      Else
         // ��������������������������������������������������������������������Ŀ
         // � Posiciono SB1 para acerto de Pesos e Capac. Volum�trica da Carga,  �
         // � note que os c�lculos s�o feitos mesmo que os registros do DAI e do �
         // � DAI sejam deletados.  ����������������������������������������������
         // �������������������������
         dbSelectArea("SB1")
         dbSetOrder(1)
         If dbSeek(xFilial()+SD2->D2_COD)
            dbSelectArea("DAK")
            dbSetOrder(1)
            If !dbSeek(xFilial()+Left(SF2->F2_CARGA,6))
               MsgStop("Carga "+Left(SF2->F2_CARGA,6)+" n�o encontrada no DAK")
            Else
               RecLock("DAK",.F.)
               DAK->DAK_PESO   := DAK->DAK_PESO - ( ( SB1->B1_PESO / SB1->B1_QTDUPAD ) * SD2->D2_QUANT )
               DAK->DAK_CAPVOL := DAK->DAK_CAPVOL - ( ( nCapArm / SB1->B1_QTDUPAD ) * SD2->D2_QUANT )
               MsUnlock()
            EndIf
            dbSelectArea("DAI")
            RecLock("DAI",.F.)
            DAI->DAI_PESO   := DAI->DAI_PESO - ( ( SB1->B1_PESO / SB1->B1_QTDUPAD ) * SD2->D2_QUANT )
            DAI->DAI_CAPVOL := DAI->DAI_CAPVOL - ( ( nCapArm / SB1->B1_QTDUPAD ) * SD2->D2_QUANT )
            MsUnlock()
         EndIf
         // ��������������������������������������������������������������������Ŀ
         // � Busco se este � o �ltimo item desta Nota Fiscal, caso sim, fa�o o  �
         // � tratamento abaixo descrito para excluir DAI e DAK.  ����������������
         // �������������������������������������������������������
         dbSelectArea("SD2")
         cSeek := D2_FILIAL+D2_DOC+D2_SERIE
         nRecSD2 := Recno()
         dbSkip()
         If Eof() .Or. D2_FILIAL+D2_DOC+D2_SERIE != cSeek
            dbGoto(nRecSD2)
            // ����������������������������������������������������������������Ŀ
            // � Verifico algum registro desta Carga no SC9, caso sim, mantenho �
            // � o arquivo DAK.  ������������������������������������������������
            // �������������������
            dbSelectArea("SC9")
            //EspOrder("SC9",1)
            DbSetOrder(5)				
            If dbSeek(xFilial()+Left(SF2->F2_CARGA,6))
               // ���������������������������������������������������������������Ŀ
               // � Verifico, nos registros encontrados no SC9 referentes a esta  �
               // � Carga, se algum deles diz respeito ao Pedido deste item da    �
               // � Nota (D2_PEDIDO), caso sim, n�o excluo o DAI (lBuscaSC9).     �
               // �����������������������������������������������������������������
               lBuscaSC9 := .F.
               While !Eof() .And. C9_FILIAL+C9_CARGA == xFilial()+Left(SF2->F2_CARGA,6)
                  If C9_PEDIDO == SD2->D2_PEDIDO
                     lBuscaSC9 := .T.
                     // ���������������������������������������������������������Ŀ
                     // � Caso, no DAI, consta o n�mero de Nota Fiscal que esta   �
                     // � sendo deletado, permito a continuidade do While at�     �
                     // � encontrar outra Nota Fiscal desta mesma Carga e gravar  �
                     // � o seu n�mero no DAI. ������������������������������������
                     // ������������������������
                     If DAI->DAI_NFISCA+DAI->DAI_SERIE == SD2->D2_DOC+SD2->D2_SERIE
                        If !Empty(C9_NFISCAL) .And. C9_NFISCAL != SD2->D2_DOC
                           dbSelectArea("DAI")
                           RecLock("DAI",.F.)
                           DAI->DAI_NFISCA := SC9->C9_NFISCAL
                           //DAI->DAI_SERIE  := SC9->C9_SERIENF
                           SerieNfId ("DAI",1,"DAI_SERIE",,,,SC9->C9_SERIENF)
                           MsUnLock()
                           Exit
                        EndIf
                     Else
                        Exit
                     EndIf
                  EndIf
                  dbSelectArea("SC9")
                  dbSkip()
               End
               If !lBuscaSC9
                  dbSelectArea("DAI")
                  RecLock("DAI",.F.,.T.)
                  dbDelete()
                  MsUnLock()
                  WriteSX2("DAI")
               Else
                  // �����������������������������������������������������������Ŀ
                  // � Caso no DAI ainda conste o n�mero da Nota Fiscal que esta �
                  // � sendo deletado, limpo este n�mero. ������������������������
                  // ��������������������������������������
                  If DAI->DAI_NFISCA+DAI->DAI_SERIE == SD2->D2_DOC+SD2->D2_SERIE
                     dbSelectArea("DAI")
                     RecLock("DAI",.F.)
                     DAI->DAI_NFISCA := ""
                     //DAI->DAI_SERIE  := ""
                     SerieNfId("DAI",4,"DAI_SERIE",,,"")                    
                     MsUnLock()
                  EndIf
               EndIf
               // ����������������������������������������������������������Ŀ
               // � Verifico novamente o SC9 para esta Carga buscando se     �
               // � ainda existe alguma Nota Fiscal, caso n�o, limpo o campo �
               // � DAK_FEZNF. �����������������������������������������������
               // ��������������
               lExistNF := .F.
               dbSelectArea("SC9")
               //EspOrder("SC9",1)
               DbSetOrder(5)				// C9_FILIAL + C9_AGREG
               dbSeek(xFilial()+Left(SF2->F2_CARGA,6))
               While !Eof() .And. C9_FILIAL+C9_CARGA == xFilial()+Left(SF2->F2_CARGA,6)
                  If !Empty(C9_NFISCAL)
                     lExistNF := .T.
                     Exit
                  EndIf
                  dbSkip()
               End
               If !lExistNF
                  dbSelectArea("DAK")
                  RecLock("DAK",.F.)
                  DAK->DAK_FEZNF := " "
                  MsUnLock()
               EndIf
            Else
               dbSelectArea("DAI")
               RecLock("DAI",.F.,.T.)
               dbDelete()
               MsUnLock()
               WriteSX2("DAI")
               dbSelectArea("DAK")
               RecLock("DAK",.F.,.T.)
               dbDelete()
               MsUnLock()
               WriteSX2("DAK")
            EndIf
         Else
            dbGoto(nRecSD2)
         EndIf
      EndIf
   EndIf

   //��������������������������������������������������������������Ŀ
   //� Retorna aos registros originais                              �
   //����������������������������������������������������������������
   For wi := Len(awArea) to 1 Step -1
      dbSelectArea(awArea[wi][1])
      dbSetOrder(awArea[wi][2])
      If Recno() != awArea[wi][3]
         dbGoto(awArea[wi][3])
      EndIf
   Next wi

EndIf

If SF2->F2_TIPO $ 'NBD' .AND. SF4->F4_CONTEMB == "S"

	//��������������������������������������������������������������Ŀ
	//� Posiciona Cadastro de Produtos (Codigo da Embalagem)         �
	//����������������������������������������������������������������
	cCODEMBA := SD2->D2_COD
	dbselectarea ("SB1")
	dbsetorder(1)
   If dbseek(xFilial("SB1") + SD2->D2_COD)

      If SB1->(FieldPos("B1_CONTEMB")) .And. SB1->B1_CONTEMB == "S"
         cCODEMBA := SB1->B1_CODEMBA
         n520Quant := SD2->D2_QUANT
         D520Estorn(cCODEMBA,n520Quant)
      EndIf

      If SB1->(FieldPos("B1_CODEMB2")) .And. SB1->B1_CONTEM2 == "S"
         cCODEMBA := SB1->B1_CODEMB2
         n520Quant := Int( SD2->D2_QUANT / SB1->B1_UNI2EMB ) + IIf( SD2->D2_QUANT % SB1->B1_UNI2EMB > 0, 1, 0 )
         D520Estorn(cCODEMBA,n520Quant)
      EndIf

   Endif

ENDIF

//��������������������������������������������������������������Ŀ
//� Retorna ao registro original                                 �
//����������������������������������������������������������������
dbSelectArea(cAlias)
dbSetOrder(nOrder)
dbGoto(nRecno)
Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Funcao	 � DSSD1100E� Autor �Andrea Marques Federson� Data �08/07/1999���
�������������������������������������������������������������������������Ĵ��
��� Descricao� Ponto de Entrada na Exclusao de NF de Entrada				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Especifico (DISTRIBUIDORES)										  ���
�������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                     ���
�������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                   ���
�������������������������������������������������������������������������Ĵ��
��� Waldemiro    �26/07/99�      �Corre��es e adequa��o ao tratamento de  ���
���              �        �      �Segunda Embalagem.                      ���
�������������������������������������������������������������������������Ĵ��
��� Projetos     �19/05/00�      �Conversao PROTHEUS SD1100E              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function DS100SD1E()
//��������������������������������������������������������������Ŀ
//� Guarda registro original												  �
//����������������������������������������������������������������
Local cALIAS	 := ALIAS()
Local nORDER	 := INDEXORD()
Local nRECNO	 := RECNO()
Local cCODEMBA,n100Quant

IF SF1->F1_TIPO $ 'NBD' .AND. SF4->F4_CONTEMB == "S"

	//��������������������������������������������������������������Ŀ
	//� Posiciona Cadastro de Produtos (Codigo da Embalagem) 		  �
	//����������������������������������������������������������������
	cCODEMBA := SD1->D1_COD
	dbselectarea ("SB1")
	dbsetorder(1)
	If dbseek(xFilial("SB1") + SD1->D1_COD)
		If SB1->(FieldPos("B1_CONTEMB")) .And. SB1->B1_CONTEMB == "S"
			cCODEMBA := SB1->B1_CODEMBA
			n100Quant := SD1->D1_QUANT
		EndIf
		If SB1->(FieldPos("B1_CODEMB2")) .And. SB1->B1_CONTEM2 == "S"
			cCODEMBA := SB1->B1_CODEMB2
			n100Quant := Int( SD1->D1_QUANT / SB1->B1_UNI2EMB ) + IIf( SD1->D1_QUANT % SB1->B1_UNI2EMB > 0, 1, 0 )
		EndIf
	EndIf

ENDIF

//��������������������������������������������������������������Ŀ
//� Retorna ao registro original 										  �
//����������������������������������������������������������������
DBSELECTAREA(cALIAS)
DBSETORDER(nORDER)
DBGOTO(nRECNO)
Return(.T.)
                 
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao   �F520Estorn� Autor � Waldemiro L. Lustosa  � Data � 26.07.1999 ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Function D520Estorn(cCodEmba,n520Quant)

//��������������������������������������������������������������Ŀ
//� Guarda Posicao dos Arquivos                                  �
//����������������������������������������������������������������
dbSelectArea("SB6")
nORDERSB6 := INDEXORD()
nRECNOSB6 := RECNO()

dbSelectArea("SB2")
nORDERSB2 := INDEXORD()
nRECNOSB2 := RECNO()

//���������������������������������������������������������Ŀ
//� Estorno dos Lancamentos Controle Poder Terceiros        �
//�����������������������������������������������������������
IF SF2->F2_TIPO == "N"
   dbSelectArea("SB6")
   dbSetOrder(3)
   dbSeek(xFilial()+SD2->D2_IDENTB6+cCodEmba+"R")
   IF !EOF()
      dbSelectArea("SB2")
      DBSETORDER(1)
      If dbSeek(xFilial()+cCODEMBA+SD2->D2_LOCAL)
         RecLock("SB2",.F.)
      Else
         CriaSB2(cCODEMBA,SD2->D2_LOCAL)
      EndIf
      Replace B2_QNPT With B2_QNPT - n520Quant
      dbSelectArea("SB6")
      RecLock("SB6",.F.,.T.)
      dbDelete()
      MsUnlock()
   ENDIF
ELSE
   dbSelectArea("SB6")
   dbSetOrder(3)
   dbSeek(xFilial()+SD2->D2_IDENTB6+cCODEMBA+"D")
   IF !EOF()
      dbSelectArea("SB2")
      DBSETORDER(1)
      If dbSeek(xFilial()+cCODEMBA+SD2->D2_LOCAL)
         RecLock("SB2",.F.)
      Else
         CriaSB2(cCODEMBA,SD2->D2_LOCAL)
      EndIf
      Replace B2_QTNP With B2_QTNP + n520Quant
      dbSelectArea("SB6")
      RecLock("SB6",.F.,.T.)
      dbDelete()
      MsUnlock()
   ENDIF

   //���������������������������������������������������������Ŀ
   //� Atualiza Saldo apos Exclusao                            �
   //�����������������������������������������������������������
   dbSELECTAREA ("SB6")
   DBSETORDER(3)
   DBSEEK(XFILIAL()+SD2->D2_IDENTB6+cCODEMBA+"R")
   IF !EOF()
      RECLOCK("SB6",.F.)
      SB6->B6_SALDO := SB6->B6_SALDO + n520Quant
   ENDIF
ENDIF

//��������������������������������������������������������������Ŀ
//� Retorna a posicao original                                   �
//����������������������������������������������������������������
dbSetOrder(nOrdersb2)
dbGoto(nRecnosb2)
dbSetOrder(nOrdersb6)
dbGoto(nRecnosb6)

Return NIL

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � D330QtDev� Autor � Alex Egydio           � Data � 16/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o ����
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � DAN_QTDEV                                                    ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D330QtDev()
Local nIdxOk:=SB1->(IndexOrd())
Local nDanCod:=aScan(aHeader,{|x|Alltrim(x[2])=="DAN_COD"})
Local nQteMbd:=aScan(aHeader,{|x|Alltrim(x[2])=="DAN_QTEMBD"})
SB1->(DbSetOrder(1))
If	SB1->(DbSeek(xFilial("SB1")+aCols[n,nDanCod]))
	aCols[n,nQteMbd] := Iif(SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD),FUnitoEmb(M->DAN_QTDEV),SPACE(8))
EndIf
SB1->(DbSetOrder(nIdxOk))
Return(.T.)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � D330QTQUE� Autor � Silvio Cazela         � Data � 17/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � DAN_QTQUE                                                    ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D330QTQUE()
Local aArea  := {Alias(),IndexOrd(),RecNo()}
Local nQtEmbQ:=aScan(aHeader,{|x|Alltrim(x[2])=="DAN_QTEMBQ"})
Local nDanCod:=aScan(aHeader,{|x|Alltrim(x[2])=="DAN_COD"})

aCols[n,nQtEmbQ]:= IF(SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD),FUnitoEmb(Posicione("SB1",1,XFILIAL("SB1")+aCols[n,nDanCod],"M->DAN_QTQUE")),SPACE(8))

DbSelectArea(aArea[1])
DbSetOrder(aArea[2])
DbGoTo(aArea[3])
Return .t.

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � D330QTOUT� Autor � Silvio Cazela         � Data � 17/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � DAN_QTOUT                                                    ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D330QTOUT()
Local aArea := {Alias(),IndexOrd(),RecNo()}
Local nDanCod:=aScan(aHeader,{|x|Alltrim(x[2])=="DAN_COD"})
Local nQtEmbo:=aScan(aHeader,{|x|Alltrim(x[2])=="DAN_QTEMBO"})

DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(XFILIAL("SB1")+aCols[n,nDanCod])

aCols[n,nQtEmbo]:= IF(SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD),FUnitoEmb(M->DAN_QTOUT),SPACE(8))

DbSelectArea(aArea[1])
DbSetOrder(aArea[2])
DbGoTo(aArea[3])

Return .t.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DA021TBPREFAutor  �Microsiga           � Data �  02/28/00   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para retorno de preco unitario                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Validacao nos campos C6_QTDVEN                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function D020TbPrc()

Local cTabela
Local nPrecoRet := 0
Local cProduto  := aCols[n][Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_PRODUTO"})]
Local nPosPreco := Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_PRCVEN"})
Local nPosPrUni := Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_PRUNIT"})
Local cTab      := ""       
Local nFrete    := 0

//���������������������������������������Ŀ
//�Se modulo de distribui��o estiver ativo�
//�����������������������������������������
		
cTabela := M->C5_TABELA
dbSelectarea("DA1")
dbSetOrder(1)
If dbSeek(xFilial("DA1")+cTabela+cProduto)
	nPrecoRet := DA1->DA1_PRCVEN
Endif		

aCols[n][nPosPreco] := nPrecoRet
aCols[n][nPosPrUni] := nPrecoRet

SysRefresh()

Return(.T.)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �D020VLPRD � Autor � Marcos Cesar          � Data � 30/06/1999 ���
���������������������������������������������������������������������������Ĵ��   
���Nome Orig.� DFATA048 �                                                 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � ExecBlock, disparado pela Validacao do Campo DA1_COD, p/ ve- ���
���          � rificar se ja existe o Produto no aCols.                     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � DFATA048()                                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Especifico p/ Distribuidora Antarctica.                      ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
��� Alex Egydio  �19.01.00�      �Conversao PROTHEUS                        ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D020VlPrd()

Local cCodProd := &(ReadVar())
Local lRet     := .T.
Local nPosProduto := Ascan(aHeader,{|x| Alltrim(x[2]) == "DA1_CODPRO"})
Local cRetorno := ""
Local nPosDesc := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_DESCRI"})
Local nB       := 0


//��������������������������������������������������������������Ŀ
//� Verifica se o Codigo ja existe no aCols.                     �
//����������������������������������������������������������������
For nB := 1 To Len(aCols)
	If nB <> n .And. aCols[nB][nPosProduto] == cCodProd
      Help(" ",1,"DS020TEMCOD")
  		lRet := .F.
	EndIf
Next nB

If lRet 
	//��������������������������������������������������������������Ŀ
	//� Pesquisa o Arquivo SB1 (Cadastro de Produtos).               �
	//����������������������������������������������������������������
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial() + cCodProd)
	
	//��������������������������������������������������������������Ŀ
	//� Define o retorno do ExecBlock.                               �
	//����������������������������������������������������������������
	aCols[n][nPosDesc] := Iif(Found(), SB1->B1_DESC   , Space(30))
	
Endif	

Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �DIPIAUT   � Autor �Andrea Marques Federson� Data � 31/05/99 ���
�������������������������������������������������������������������������Ĵ��
���Nome Orig.� DCOMA02  �                                                 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calculo o IPI de Pauta na Entrada da N.F.                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
��� Revis�o  � TI0607 - Almir Bandina                   � Data � 11.08.99 ���
���          � Reformulado programa para substituir di- �      �          ���
���          � versos gatilhos que eram executados.     �      �          ���
���          �                                          �      �          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������

/*/
Function DIPIPAUT()
Local cAlias,cTes,cProduto
Local nIndex,nRegis,nQuant,nQtSegum,nVCalc,nVUnit,nTotal := 0
Local lRet := .T.
Local nValDesc,nDesc,nBaseIPI,nValIPI,nValLiq := 0
Local nPosVCalc,nPosQuant,nPosQtSeg,nPosvUnit,nPosTotal,nPosVlDes

//�������������������������������������������������Ŀ
//�N�o executa esta funcao se estivermos na pre-nota�
//���������������������������������������������������

If !(Funname(1) == "MATA140")

	cAlias  := Alias()
	nIndex  := IndexOrd()
	nRegis  := Recno()
	lRet    := .T.         

	nPosVCalc := Ascan(aHeader,{|x|Trim(x[2])=="D1_VCALC"})
	nPosQtEmb := Ascan(aHeader,{|x|Trim(x[2])=="D1_QTEMB"})
	nPosPauta := Ascan(aHeader,{|x|Trim(x[2])=="D1_PAUTA"})
	nPosVlDes := Ascan(aHeader,{|x|Trim(x[2])=="D1_VALDESC"})

	nPosQuant := Ascan(aHeader,{|x|Trim(x[2])=="D1_QUANT"})
	nPosQtSeg := Ascan(aHeader,{|x|Trim(x[2])=="D1_QTSEGUM"})
	nPosvUnit := Ascan(aHeader,{|x|Trim(x[2])=="D1_VUNIT"})
	nPosTotal := Ascan(aHeader,{|x|Trim(x[2])=="D1_TOTAL"})
	nPosDesc  := Ascan(aHeader,{|x|Trim(x[2])=="D1_DESC"})
	nPosBIpi  := Ascan(aHeader,{|x|Trim(x[2])=="D1_BASEIPI"})
	nPosVlIpi := Ascan(aHeader,{|x|Trim(x[2])=="D1_VALIPI"})
	nPosVlLiq := Ascan(aHeader,{|x|Trim(x[2])=="D1_VALLIQ"})
	nPosProd  := Ascan(aHeader,{|x|Trim(x[2])=="D1_COD"})
	nPosTes   := Ascan(aHeader,{|x|Trim(x[2])=="D1_TES"})


	nQuant  := aCols[n][nPosQuant]
	nQtSegum:= aCols[n][nPosQtSeg]                                    
	nVUnit  := aCols[n][nPosvUnit]
	nVCalc  := aCols[n][nPosVCalc]
	nTotal  := aCols[n][nPosTotal]
	nValDesc:= aCols[n][nPosVlDes]
	nDesc   := aCols[n][nPosDesc]
	nBaseIPI:= aCols[n][nPosBIpi]
	nValIPI := aCols[n][nPosVlIpi]
	nValLiq := aCols[n][nPosVlLiq]
	cProduto:= aCols[n][nPosProd]
	cTes    := aCols[n][nPosTes]

	If AllTrim(Upper(ReadVar())) == "M->D1_QUANT"
   	nQuant := &(ReadVar())
	ElseIf AllTrim(Upper(ReadVar())) == "M->D1_QTSEGUM"
	   nQtSegum := &(ReadVar())
	ElseIf AllTrim(Upper(ReadVar())) == "M->D1_VCALC" 
	   nVCalc := &(ReadVar())
	ElseIf AllTrim(Upper(ReadVar())) == "M->D1_TOTAL"
	   nTotal := &(ReadVar())
	ElseIf AllTrim(Upper(ReadVar())) == "M->D1_VALDESC"
	   nValDesc := &(ReadVar())
	ElseIf AllTrim(Upper(ReadVar())) == "M->D1_DESC"
	   nDesc := &(ReadVar())
	ElseIf AllTrim(Upper(ReadVar())) == "M->D1_TES"
	   cTes := &(ReadVar())
	ElseIf AllTrim(Upper(ReadVar())) == "M->D1_BASEIPI"
	   nBaseIPI := &(ReadVar())
	ElseIf AllTrim(Upper(ReadVar())) == "M->D1_VALIPI"
	   nValIPI := &(ReadVar())
	EndIf

	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xFilial("SF4")+cTes,.F.)
	DbSelectarea("SB1")
	DbSetorder(1)
	If !DbSeek(xFilial("SB1")+cProduto,.F.)
	   Help(" ",1,"REGNOIS")
		lRet := .F.
	EndIf

	If nPosVCalc > 0 .And. nPosQtEmb > 0

		If AllTrim(Upper(ReadVar())) == "M->D1_QTEMB" .or.;
	   	AllTrim(Upper(ReadVar())) == "M->D1_PEDIDO" .or.;
		   AllTrim(Upper(ReadVar())) == "M->D1_QUANT"
			nQtSegum := nQuant * SB1->B1_CONV
			If AllTrim(Upper(ReadVar())) == "M->D1_PEDIDO"
			   DbSelectArea("SC7")
				DbSetOrder(4)
				DbSeek(xFilial("SC7")+cProduto+M->D1_PEDIDO,.F.)
	      	aCols[n][nPosQtEmb] := SC7->C7_QTEMB
		      nVCalc := SC7->C7_VCALC
   		   DbSetOrder(1)
			EndIf
		EndIf

		If AllTrim(Upper(ReadVar())) == "M->D1_VCALC"
   		nVUnit  := If(SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD),nVCalc/SB1->B1_QTDUPAD,nVCalc)
		EndIf

		If AllTrim(Upper(ReadVar())) == "M->D1_QUANT" .or.;
   		AllTrim(Upper(ReadVar())) == "M->D1_VCALC"
	   	nTotal  := Round(nVUnit * nQuant,2)
		EndIf

		If AllTrim(Upper(ReadVar())) == "M->D1_DESC"
   		nValDesc := NoRound((nTotal * nDesc)/100)
		EndIf

		If AllTrim(Upper(ReadVar())) == "M->D1_VALDESC"
	   	nDesc := (nValDesc / nTotal)*100
		EndIf

		nValLiq := nTotal - nValDesc

		If SF4->F4_PAUTA == "S"
	   	If !Empty(SB1->B1_VLR_IPI)
   			nValIPI  := Round((SB1->B1_VLR_IPI/SB1->B1_QTDUPAD)*nQuant,2)
				nBaseIPI := nValLiq
				aCols[n][nPosPauta] := SB1->B1_VLR_IPI
			Else
			   Help(" ",1,"HDCOMA021")
			   lRet := .F.
			EndIf
		EndIf

		aCols[n][nPosQtSeg] := nQtSegum
		aCols[n][nPosVUnit] := nVUnit
		aCols[n][nPosVCalc] := nVCalc
		aCols[n][nPosTotal] := nTotal
		aCols[n][nPosVlLiq] := nValLiq
		aCols[n][nPosVlIpi] := nValIPI
		aCols[n][nPosBIpi]  := nBaseIPI
		aCols[n][nPosVlDes] := nValDesc
		aCols[n][nPosDesc]  := nDesc
	
	Endif

	dbSelectArea(cAlias)
	dbSetOrder(nIndex)
	dbGoto(nRegis)
	
Endif	
	
	

Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �D630AltDes| Autor � Silvio Cazela         � Data �15.03.2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Modificacao de Flags - Indenizacoes e Extrado de Descontos ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
���Revis�o	 � 													  � Data �			  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function D630AltDes(cPedido)

Local aArea    := Alias()
Local nVerbaBn := 0
Local cNdbi    := ""
Local nInden   := Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_DESCONT")
Local nAbat    := 0
Local nSaldo   := 0

DbSelectArea("DBH")
DbSetOrder(7)	
DbSeek(xFilial("DBH")+cPedido)
While !eof() .and. DBH->DBH_PEDIDO == cPedido
	RecLock("DBH",.f.)
	DBH->DBH_DOC    := SF2->F2_DOC
	//DBH->DBH_SERIE  := SF2->F2_SERIE
	SerieNfId ("DBH",1,"DBH_SERIE",,,,SF2->F2_SERIE)
	DBH->DBH_ITEM   := Posicione("SD2",9,xFilial("SD2")+DBH->DBH_PEDIDO+DBH->DBH_ITEMPV,"D2_ITEM")
	DBH->DBH_STATUS := "C"
	DBH->DBH_OBS    := "CONCEDIDO EM NF"
	MsUnLock()
	DbSkip()
End

//DbSelectArea("DB2")

dbSelectarea("DB2")
DbSetOrder(4)
If DbSeek(xFilial("DB2")+cPedido)

	While !eof() .and. DB2->DB2_FILIAL+DB2->DB2_DOC == xFilial("DB2")+cPedido
		DbSelectArea("DB1")
		DbSetOrder(1)
		If DbSeek(xFilial("DB1")+DB2->DB2_NUM)
			RecLock("DB1",.f.)
			DB1->DB1_OK := "I "
			MsUnLock()
		Endif
   
		nRec := DB2->(Recno())


		nSaldo := DB2->DB2_SALDO
		nAbat  := iif(nSaldo<=nInden,nSaldo,nInden)
		nInden := nInden-nAbat

		If nAbat > 0		
			RecLock("DB2",.f.)
			DB2->DB2_STATUS := "I "
			DB2->DB2_NOTA   := SF2->F2_DOC
			//DB2->DB2_SERIE  := SF2->F2_SERIE
			SerieNfId ("DB2",1,"DB2_SERIE",,,,SF2->F2_SERIE)
			DB2->DB2_DTIND  := ddatabase
			DB2->DB2_SALDO  := DB2->DB2_SALDO - nAbat
			MsUnLock()      
		Endif
			
		dbSelectArea("DB2")		
		dbGoto(nRec)

		dbSelectArea("DB2")
		DbSkip()
	End
Endif

RecLock("SF2",.F.)
	SF2->F2_CARGA  := SC5->C5_NUMCG
	SF2->F2_ENTREG := SC5->C5_ENTREG
	SF2->F2_AJUD   := SC5->C5_AJUD
	SF2->F2_AJUD2  := SC5->C5_AJUD2
	SF2->F2_AJUD3  := SC5->C5_AJUD3
MsUnLock()

If !(SF2->F2_TIPO $ "DB")
	dbSelectArea("SE1")
	Reclock("SE1",.F.)
	SE1->E1_FORMAPG := SE4->E4_FORMA    
	If SE1->(FieldPos("E1_AGLTNF")) > 0 .And. SA1->(FieldPos("A1_AGLTNF")) > 0
		SE1->E1_AGLTNF  := SA1->A1_AGLUTNF
	Endif			
	SE1->E1_COND    := SF2->F2_COND
	SE1->E1_CARGA   := SF2->F2_CARGA
	
	If SE1->(FieldPos("E1_COBBANC")) > 0
		SE1->E1_COBBANC := SA1->A1_COBBANC	  
	Endif		

	If SE1->(FieldPos("E1_REDE")) > 0
		SE1->E1_REDE := SA1->A1_REDE
	EndIf
EndIf

//Bonificacao (Verba)
If AllTrim(Upper(GetMv("MV_VERBABN"))) == "S"
	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek(xFilial("SC6")+cPedido)
	While !Eof() .and. SC6->C6_NUM == cPedido
		cNdbi := Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_TPMOV")
		If cNdbi == "B"
			nVerbaBn := nVerbaBn + SD2->D2_TOTAL
		Endif
		DbSkip()
	End

	If nVerbaBn > 0
		DbSelectArea("DB6")
		DbSetOrder(3)
		DbGoTop()
		While !eof()
			If DB6->DB6_DATAI <= ddatabase .and. DB6->DB6_DATAF >= ddatabase
				RecLock("DB6",.f.)
				DB6->DB6_SALDOBN := DB6->DB6_SALDOBN - nVerbaBn
				MsUnLock()
				Exit
			Endif
			DbSkip()
		End
	
		//Extrato de Descontos
		DbSelectArea("DBH")
		RecLock("DBH",.t.)
		DBH->DBH_FILIAL := xFilial("DBH")
		DBH->DBH_TPDESC := "B"
		DBH->DBH_TIPO   := "P" //Pedido
		DBH->DBH_STATUS := "C" //Pedido
		DBH->DBH_CLIENT := SF2->F2_CLIENTE
		DBH->DBH_LOJA   := SF2->F2_LOJA
		DBH->DBH_CODDES := ""
		DBH->DBH_PRODUT := "BONIFICACAO"
		DBH->DBH_VALDES := nVerbaBn
		DBH->DBH_DATA   := ddatabase
		DBH->DBH_OK     := "NC"
		DBH->DBH_OBS    := "CONCEDIDO EM NF"
		DBH->DBH_PEDIDO := cPedido
		DBH->DBH_ITEMPV := ""
		//DBH->DBH_SERIE  := SF2->F2_SERIE
		SerieNfId ("DBH",1,"DBH_SERIE",,,,SF2->F2_SERIE)
		DBH->DBH_ITEM   := ""
		DBH->DBH_PERC   := 0
		DBH->DBH_KIBON  := 0
		DBH->DBH_DISTR  := 0
		MsUnLock()
	Endif
		

Endif

DbSelectArea(aArea)

Return .t.


