#INCLUDE "CTBA060.CH"
#INCLUDE "PROTHEUS.CH"

STATIC __lCTA060CV := .F.
STATIC lCTB060AUT := .F.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBA060  � Autor � J�lio Wittwer         � Data � 29/10/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastramento de Classe de Valores - SIGACTB               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBA060()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBA060(aRotAuto,nOpcAuto)

Local aCores := {	{ "CTH_BLOQ == '1'" , "BR_VERMELHO"	},; // Conta Bloqueada
					{ "CTH_BLOQ == '2' .AND. ( ( Empty( CTH_DTEXIS ) .Or. CTH_DTEXIS <= dDatabase ) .AND. ( Empty( CTH_DTEXSF ) .Or. CTH_DTEXSF >= dDatabase ) )" , "BR_VERDE"   	},; // Sem Restri��o
					{ "CTH_BLOQ == '2' .AND. ( ! Empty( CTH_DTEXIS ) .AND. CTH_DTEXIS >= dDatabase )" , "BR_AMARELO"	},; // Exercicio N�o Iniciado
					{ "CTH_BLOQ == '2' .AND. ( ! Empty( CTH_DTEXSF ) .AND. CTH_DTEXSF <= dDatabase )" , "BR_CINZA"		} } // Exercicio Finalizado

PRIVATE aRotina := MenuDef()

PRIVATE cCadastro := OemToAnsi(STR0006)+CtbSayApro("CTH")  //"Cadastro Classe de Valores"
__lCTA060CV := CtbMovSaldo("CTH")

Private Inclui := .F.
Private Altera := .F.
Private Exclui := .F.

DEFAULT aRotAuto := {}
DEFAULT nOpcAuto := 3

If !__lCTA060CV
	Help(" ",1,"NCONSALCV")
	Return
Endif

If Len(aRotAuto) > 0
	lCTB060AUT := .T.
Else
	SetKey(VK_F12,{|a,b|AcessaPerg("CTB060",.T.)})
EndIf


Pergunte("CTB060",.F.)

If lCTB060Aut
	PRIVATE aAutoCab   := Aclone(aRotAuto)
	MBrowseAuto(nOpcAuto,aAutoCab,"CTH")
Else
	//�������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros						�
	//� mv_par01		// Gera Cl.Vlr Sup? Autom/Formula/Digit	  	�
	//� mv_par02		// Formula Cl. Vlr Sup						�
	//� mv_par03		// Cadastro em Arvore (Nao/Sim/Perguntar)	�
	//���������������������������������������������������������������

	If mv_par03 == 2
		CtbaTree("CTH")
		SET KEY VK_F12 to
		Return
	ElseIf mv_par03 == 3
		If MsgYesNo(STR0010)
			CtbaTree("CTH")
			SET KEY VK_F12 to
			Return
		EndIf
	EndIf

	mBrowse( 6, 1,22,75,"CTH",,,,,,aCores)

	dbSetOrder(1)

	SET KEY VK_F12 to
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CTBA060Inc� Autor � Lucimara Soares       � Data � 22/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inclus�o de Classe de Valor         			              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ctba060Inc(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Ctba060Inc(cAlias, nReg, nOpc)
LOCAL nY    := 0
LOCAL nOpcA := 0
Local aEaiRet	:= {}

PRIVATE aCposHistor := {}

DEFAULT nOpc := 3

Inclui := .T.
Altera := .F.
Exclui := .F.

Begin Transaction

If !lCTB060AUT		// SE FOR ROTINA AUTOMATICA
	nOpcA := AxInclui(cAlias, nReg, nOpc,,,,"Ct060TudOk(nOpc)")
Else
	nOpcA := AxInclui(cAlias,nReg,nOpc,/*aAcho*/,/*cFunc*/   ,/*aCpos*/,"Ct060TudOk(nOpc)",/*lF3*/,  ,   ,/*aParam*/,aAutoCab  ,/*lVirtual*/,/*lMaximized*/)
EndIf

If nOpcA == 1
	//�����������������������������������������������������������������������Ŀ
	//� Grava Hist�rico de Altera��es na tabela CW8.                          �
	//�������������������������������������������������������������������������
	If nOpc == 3
		CTBGrvHist(xFilial("CTH"),"CTH"		,CTH->CTH_CLVL,       ,ValType(CTH->CTH_CLVL),"CTH_CLVL",""       ,CTH->CTH_CLVL,nOpc)
		//		   cFilTabela	 ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo             ,cCampo,cValorAnt,cValorNovo   ,nOpc)
	Else
		For nY := 1 To Len(aCposHistor)
			aCposHistor[nY][3] := CTH->&(EVAL(bCampo,nY))
			If aCposHistor[nY][2] <> aCposHistor[nY][3]
				CTBGrvHist(xFilial("CTH"),"CTH"     ,CTH->CTH_CLVL,      ,ValType(aCposHistor[nY][1]),aCposHistor[nY][1],aCposHistor[nY][2],aCposHistor[nY][3],nOpc)
				//           cFilTabela	 ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo                 ,cCampo            ,cValorAnt         ,cValorNovo        ,nOpc)
   	    	EndIf
   		Next nY
	EndIf

	//Ponto de Entrada ap�s a inclus�o
	If ExistBlock("CT060INC")
		ExecBlock("CT060INC",.F.,.F.,{nOpc})
 	Endif

	//Integra��o via Mensagem �nica
	If FindFunction('FwHasEAI') .And. FWHasEAI('CTBA060',.T.,,.T.)
		aEaiRet:= FWIntegDef('CTBA060',,,,'CTBA060')
		If ValType(aEaiRet) <> "A" .or. len(aEaiRet) < 2
			aEaiRet := {.F., ""}
		Endif
		If !aEaiRet[1]
			Help(,, "HELP",, AllTrim(aEaiRet[2]), 1, 0,,,,,, {STR0034})  // "Problemas na integra��o EAI. Transa��o n�o executada."
			DisarmTransaction()
		EndIf
	EndIf
EndIf

End Transaction

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CTBA060Alt� Autor � Renato F. Campos      � Data � 22/08/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Altera��o da Classe de Valor        			              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ctba060Alt(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function CTBA060Alt(cAlias,nReg,nOpc)
LOCAL nY     := 0
LOCAL bCampo := {|nCPO| Field(nCPO)}
LOCAL nOpcA  := 0
Local aEaiRet := {}

PRIVATE aCposHistor := {}

DEFAULT nOpc := 4

Inclui := .F.
Altera := .T.
Exclui := .F.

Begin Transaction

If !lCTB060AUT		// SE FOR ROTINA AUTOMATICA
	nOpcA := AxAltera(cAlias, nReg, nOpc,,,,,"Ct060TudOk(4)")
Else
	nOpcA := AxAltera(cAlias, nReg, nOpc,,,,,"Ct060TudOk(4)",/*lF3*/,  ,   ,/*aParam*/,aAutoCab  ,/*lVirtual*/,/*lMaximized*/)
EndIf

If nOpcA == 1
	//�����������������������������������������������������������������������Ŀ
	//� Grava Hist�rico de Altera��es na tabela CW4.                          �
	//�������������������������������������������������������������������������
	If nOpc == 3
		CTBGrvHist(xFilial("CTH"),"CTH"		,CTH->CTH_CLVL,       ,ValType(CTH->CTH_CLVL),"CTH_CLVL",""       ,CTH->CTH_CLVL,nOpc)
		//		   cFilTabela	 ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo             ,cCampo,cValorAnt,cValorNovo   ,nOpc)
	Else
		For nY := 1 To Len(aCposHistor)
			aCposHistor[nY][3] := CTH->&(EVAL(bCampo,nY))
			If aCposHistor[nY][2] <> aCposHistor[nY][3]
				CTBGrvHist(xFilial("CTH"),"CTH"     ,CTH->CTH_CLVL,      ,ValType(aCposHistor[nY][1]),aCposHistor[nY][1],aCposHistor[nY][2],aCposHistor[nY][3],nOpc)
				//           cFilTabela	 ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo                 ,cCampo            ,cValorAnt         ,cValorNovo        ,nOpc)
   	    	EndIf
   		Next nY
	EndIf

	//Ponto de Entrada ap�s a altera��o
	If ExistBlock("CT060ALT")
		ExecBlock("CT060ALT",.F.,.F.,{nOpc})
 	Endif

	//Integra��o via Mensagem �nica
	If FindFunction('FwHasEAI') .And. FWHasEAI('CTBA060',.T.,,.T.)
		aEaiRet:= FWIntegDef('CTBA060',,,,'CTBA060')
		If ValType(aEaiRet) <> "A" .or. len(aEaiRet) < 2
			aEaiRet := {.F., ""}
		Endif
		If !aEaiRet[1]
			Help(,, "HELP",, AllTrim(aEaiRet[2]), 1, 0,,,,,, {STR0034})  // "Problemas na integra��o EAI. Transa��o n�o executada."
			DisarmTransaction()
		EndIf
	EndIf
EndIf

End Transaction

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �CtbClVlLP � Autor � Pilar S. Albaladejo   � Data � 21.02.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao  para informacoes de Lucros e Perdas - SX3       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �CtbCLVLLP(cCodigo)                                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo da Classe de Valor                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CtbCLVLLP(cCodigo)

LOCAL nEndereco
LOCAL nEnd1
Local nEnd2

M->CTH_CLVLLP := cCodigo

If (nEndereco := Ascan(aGets,{ |x| Subs(x,9,7) == "CTH_CLVLLP" } )) > 0
	nEnd1 := Val(Subs(aGets[nEndereco],1,2))
	nEnd2 := Val(Subs(aGets[nEndereco],3,1))*2
	aTela[nEnd1][nEnd2] := M->CTH_CLVLLP
	lRefresh := .T.
EndIf

Return .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ctb060NoRe� Autor � Simone Mie Sato       � Data � 22/05/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica se o cod. red. CLVL foi preenchdio com Analiticas! ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctb060NoRe()                                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T./.F.                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Valida��o no SX3 do campo CTH_RES (Cod. Reduzido)          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum.                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION CTB060NoRe()

Local lRet := .T.

If M->CTH_CLASSE == "1"	.And. !empty(M->CTH_RES)// Sint�tico e preenchido
	Help(" ",1,"CA060SINT")
	lRet:=.F.	
Endif

Return lRet

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ctba060del� Autor � Lucimara Soares		  � Data � 17/04/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de exclusao de Classe de Valor                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ctba060Del(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctba060Del(cAlias,nReg,nOpc)

Local aSaveArea:= GetArea()
LOCAL nOpcA 	:= 0
Local lRet		:= .T.
Local oDlg
Local bCampo
Local i
Local aInfo     := {}
Local aPosObj   := {}
Local aObjects  := {}
Local aAreaCTH	:= {}
Local aEaiRet		:= {}

PRIVATE aCposHistor := {}
DEFAULT nReg := (cAlias)->(Recno())

Inclui := .F.
Altera := .F.
Exclui := .T.

//��������������������������������������������������������������Ŀ
//� Carrega Variaveis de Memoria                                 �
//����������������������������������������������������������������
dbSelectArea(cAlias)
bCampo := {|nCPO| Field(nCPO) }
FOR i := 1 TO FCount()
	M->&(EVAL(bCampo,i)) := FieldGet(i)
NEXT i

Private aTELA[0][0],aGETS[0]

//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
dbSelectArea(cAlias)
dbSetOrder(1)
If !SoftLock(cAlias)
	Return
EndIf


If !lCTB060AUT		// SE FOR ROTINA AUTOMATICA
	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 100, .t., .t. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	aPos := {aSize[7],000,aSize[6],aSize[5]}
	ENChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0004), ,aPosObj[1])  //"Quanto � exclus�o?"
	nOpca := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},;
											 {|| nOpca := 1,oDlg:End()})
Else
	nopcA := 2
EndIf

If nOpcA == 2
	//��������������������������������������������Ŀ
	//� Verifica se a CLValor x conta tem valores  �
	//����������������������������������������������
	IF ExiSalCQ("CTH",/*cFiltro*/,/*dDtIni*/,/*dDtFin*/,/*cConta*/,/*cCC*/,/*cItem*/,CTH->CTH_CLVL)
		lRet:=.F.
		Help(" ",1,"CLVLMOVIM")
	EndIF
	If lRet .And. ! Ct060TudOk(nOpc)
		lRet := .F.
	Endif
	IF lRet
		aAreaCTH := CTH->(GetArea())
		dbSelectARea("CTH")
		dbSetOrder(2)
		IF CTH->CTH_CLASSE == "1"			// Sintetica
			dbSkip( )
			If !Eof() .And. CTH->CTH_FILIAL == xFilial("CTH") .AND. Alltrim(M->CTH_CLVL) == ALLTRIM(CTH->CTH_CLSUP)
				Help(" ",1,"CLVLSINT")
				lRet:=.F.
			EndIf
		EndIf
		dbSetOrder(1)
		RestArea(aAreaCTH)
	EndIf

	If lRet
		lRet := VldEntPCO(cAlias,CTH->CTH_CLVL)
	Endif

	IF lRet
		BEGIN TRANSACTION
			//��������������������������������������������Ŀ
			//� Deleta a Classe de Valor do Cadastro       �
			//����������������������������������������������
			dbSelectArea(cAlias)
			MsGoTo(nReg)
			RecLock(cAlias,.F.,.T.)
			dbDelete()
			MsUnlock()
			//�����������������������������������������������������Ŀ
			//� Grava Hist�rico de Altera��es na tabela CW4.         �
			//��������������������������������������������������������
			CTBGrvHist(xFilial("CTH"),"CTH"     ,CTH->CTH_CLVL,      ,ValType(CTH->CTH_CLVL),"CTH_CLVL",CTH->CTH_CLVL,""        ,nOpc)
			//		   cFilTabela	 ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo             ,cCampo          ,cValorAnt   ,cValorNovo,nOpc)

			//Integra��o via Mensagem �nica
			If FindFunction('FwHasEAI') .And. FWHasEAI('CTBA060',.T.,,.T.)
				aEaiRet:= FWIntegDef('CTBA060',,,,'CTBA060')
				If ValType(aEaiRet) <> "A" .or. len(aEaiRet) < 2
					aEaiRet := {.F., ""}
				Endif
				If !aEaiRet[1]
					Help(,, "HELP",, AllTrim(aEaiRet[2]), 1, 0,,,,,, {STR0034})  // "Problemas na integra��o EAI. Transa��o n�o executada."
					DisarmTransaction()
				EndIf
			EndIf

		END TRANSACTION

		// Ponto de entrada apos a exclusao da classe de valor contabil - BOPS:130438 - 01/11/2007
		If ExistBlock("CTA60DEL")
			If ExecBlock("CTA60DEL",.F.,.F.,nOpc)
				Return .F.
			Endif
		Endif
	Endif
EndIf
MsUnlockAll()
MsGoTo(nReg)
RestArea(aSaveArea)
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Ctb060Sup � Autor � Simone Mie Sato       � Data � 03/10/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera o c�digo da cl.vlr sup. a partir da cl.vlr atual.      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctb060Sup(cCodigo)                                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Valida��o do SX3 do Campo CTH_CLVL                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo da Classe de Valor.        				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctb060Sup(cCodigo)
Local nEndereco
Local nEnd1,nEnd2
Local cMemMvs := Sv020Mem()		// Funcao que salva os mv_par??

//������������������������������������������������������Ŀ
//� Chamada a funcao que gera o cta superior             �
//��������������������������������������������������������

Pergunte("CTB060",.F.)

If mv_par01 != 3					// Automatico / Formula
	If mv_par01 == 1				// Automatico -> Formula Siga
		M->CTH_CLSUP	:= CtbClVlSup(cCodigo)
	ElseIf mv_par01 == 2			// Formula -> do usuario
		If !Empty(mv_par02)
			M->CTH_CLSUP:= &(mv_par02)
		EndIf
	EndIf
EndIf

If (nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "CTH_CLSUP" } )) > 0
	//������������������������������������������������������Ŀ
	//� Exibe na tela a Conta Superior Gerada                �
	//��������������������������������������������������������
	nEnd1	:= Val(Subs(aGets[nEndereco],1,2))
	nEnd2	:= Val(Subs(aGets[nEndereco],3,1))*2
	aTela[nEnd1][nEnd2] := M->CTH_CLSUP
	lRefresh := .T.
EndIf

Sv020Mem(cMemMvs)

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ct60TudOk � Autor � Lucimara Soares       � Data � 22/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica a pr�via exist�ncia de Classe de Valor            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ct060TudOk()    					                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum       								              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Ct060TudOk( nOpc )
LOCAL nY    := 0
LOCAL bCampo := {|nCPO| Field(nCPO) }
DEFAULT nOpc := 3

If nOpc == 3
	IF FkInUse() // se a integridade estiver ligada
		If CTH->CTH_CLVL == CTH->CTH_CLVLLP
			// limpa o campo CTH_CLVLLP, afim de evitar erro de referencia
			CTH->CTH_CLVLLP := ''
		Endif
	Endif

	If  ! ExistChav( "CTH", M->CTH_CLVL )
		Return .F.
	EndIf
ElseIf nOpc == 4
	IF M-> CTH_CLASSE != CTH->CTH_CLASSE
		IF ExiSalCQ("CTH",/*cFiltro*/,/*dDtIni*/,/*dDtFin*/,/*cConta*/,/*cCC*/,/*cItem*/,M->CTH_CLVL)
			Help( " " , 1 , "NALTCLASSE" ,, "da classe de valor, pois existem movimenta��es para o mesmo." ,3,0)
			Return .F.
		ENDIF
    ENDIF
EndIf

For nY := 1 To FCount()
	AADD(aCposHistor,{CTH->(FieldName(nY)),CTH->&(EVAL(bCampo,nY)),""})
Next nY

If ExistBlock("CTA060TOK")
	If !ExecBlock("CTA060TOK",.F.,.F.,nOpc)
		Return .F.
	EndIf
Endif

If ExistBlock("CTA060CLV")
	ExecBlock("CTA060CLV",.F.,.F.,{nOpc})
Endif

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBA040LEGEN � Autor � Renato F. Campos  � Data � 29/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe a legenda referente ao status                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBA060LEGEN()                                             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CTBA060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctba060leg()

BrwLegenda(STR0011,STR0012,{	{ "BR_VERDE"    , STR0013},;  //"Legenda"###"CVL do Centro de Custo"###"Sem Restri��o"
								{ "BR_VERMELHO" , STR0014},;  //"Bloqueado"
								{ "BR_AMARELO"	, STR0015},;  //"Exercicio N�o Inciado"
								{ "BR_CINZA"	, STR0016}})  //"Exercicio Finalizado"


Return Nil

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Paulo Carnelossi      � Data �07/03/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados         ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aCT060BUT := {}
Local nX := 0
Local aRotina := {	{ OemToAnsi(STR0001),"AxPesqui"		,0 , 1},;  //"Pesquisar"
					{ OemToAnsi(STR0002),"AxVisual"		,0 , 2},;  //"Visualizar"
					{ OemToAnsi(STR0003),"Ctba060Inc"	,0 , 3},;  //"Incluir"
					{ OemToAnsi(STR0004),"Ctba060Alt"	,0 , 4},;  //"Alterar"
					{ OemToAnsi(STR0005),"Ctba060Del"	,0 , 5},;  //"Excluir"
					{ OemToAnsi(STR0017),"Ctba060Imp"	,0 , 3},;	//"Importar"
					{ OemToAnsi(STR0018),"Ctba060Exp"	,0 , 4},;	//"Exportar"
					{ OemToAnsi(STR0011),"Ctba060leg"	,0 , 6},;	//"Legenda"
					{ OemToAnsi(STR0027),"MSDOCUMENT"   ,0 , 4} }	//"Conhecimento"


//���������������������������������������������������������������?
//? P.E. Utilizado para adicionar botoes ao Menu Principal       ?
//?��������������������������������������������������������������?
If ExistBlock("CT060BUT")
	aCT060BUT := ExecBlock("CT060BUT",.F.,.F.,aRotina)
	
	IF ValType(aCT060BUT) == "A" .AND. Len(aCT060BUT) > 0
		For nX := 1 to len(aCT060BUT)
			aAdd(aRotina,aCT060BUT[nX])
		Next
	ENDIF
Endif
			
Return(aRotina)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBA060Exp�Autor  �Marcelo Akama       � Data �  13/08/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exporta as classes de valor para arquivo .CSV               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTBA060Exp()
Local aRet		:=	{}

SaveInter()

If ParamBox({	{6,STR0019,padr("",150),"",,"",90 ,.T.,STR0020,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},; //"Estrut. de classes de valor"###"Arquivo .CSV |*.CSV"
		STR0021,@aRet)  //"Exportar para estrutura de classes de valor"

	oProcess:= MsNewProcess():New( {|lEnd| CTBExpCSV( lEnd, oProcess, aRet[1], { {"CTH",1} } )} )
	oProcess:Activate()

EndIf

RestInter()

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBA060Imp�Autor  �Marcelo Akama       � Data �  13/08/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Importa classes de valor de arquivo .CSV                    ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTBA060Imp()
Local aRet	:= {}
Local aArea	:= CTH->(GetArea())
Local aCfg
Local cCampos

CTH->(dbGoTop())
If !( CTH->(Eof()) .And. CTH->(Bof()) )
	Aviso(STR0017,STR0022+CRLF+STR0023,{STR0024}) //"Importar"###"A importacao das classes de valor so pode ser"##"feita com o plano de contas vazio" //"Fechar"
	RestArea(aArea)
	Return .F.
EndIf

SaveInter()

cCampos:="CTH_CLVL,CTH_CLASSE,CTH_NORMAL,CTH_DESC01,CTH_DESC02,CTH_DESC03,CTH_DESC04,CTH_DESC05,CTH_BLOQ,CTH_DTBLIN,CTH_DTBLFI,CTH_DTEXIS,CTH_DTEXSF,CTH_CLVLLP,CTH_CLPON,CTH_BOOK,CTH_CLSUP,CTH_RES,CTH_CRGNV1,CTH_CRGNV2,CTH_CRGNV3,CTH_CLVM,CTH_CLRED"

aCfg := { { "CTH", cCampos, {||MsExecAuto({|x,y| CTBA060(x,y)}, xAutoCab, 3)} } }

If ParamBox({	{6,STR0019,padr("",150),"",,"", 90 ,.T.,STR0020,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},;	 //"Estrut. classes de valor"###"Arquivo .CSV |*.CSV"
		STR0025,@aRet)  //"Importar estrutura de classes de valor"

	oProcess:= MsNewProcess():New( {|lEnd| CTBImpCSV( lEnd, oProcess, aRet[1], aCfg )} )
	oProcess:Activate()
	lCTB060AUT := .F.

EndIf

RestInter()

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ctb040ClVl� Autor � Microsiga             � Data � 26/09/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao do Item Contabil Digitado -> SX3                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctb040ClVl()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctb040ClVl()

Local aSaveArea := GetArea()
Local lRet 		:= .T.

lRet := ExistChav("CTH",,1) .And. Ctb060Sup(M->CTH_CLVL) .And. CtbCLVLLP(M->CTH_CLVL) .And. FreeForUse("CTH", M->CTH_CLVL)

RestArea(aSaveArea)

// Verifica se a classe de valor que esta sendo incluido consta no cache como item invalido e atualiza o cache.
AtuVldEnt("CTH", M->CTH_CLVL)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Integra��o via mensagem �nica

@author Pedro Pereira Lima
@version P12
@since	20/03/2014
/*/
//-------------------------------------------------------------------
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return CTBI060(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
