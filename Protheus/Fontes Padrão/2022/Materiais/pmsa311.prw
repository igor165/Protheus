#include "pmsa311.ch"
#include "protheus.ch"

STATIC __lRejec 	:= .F.       	///	VARIAVEL PRECISA ESTAR DISPON�VEL NA PMS311GRAVA() QUANDO H� INTEGRA��O QNC (MV_QTMKPMS) 3 ou 4.
STATIC __cQNCRej	:= ""
STATIC __cQNCDEP	:= ""
STATIC __cNEWQUO	:= ""

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PMSA311Aut� Autor � Cristiano Denardi     � Data � 26-10-2005 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Adaptacao para a chamada da rotina automatica no padrao de   ���
���          � sequencia dos parametros recebidos.                          ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PMSA311Aut(aRotAut,nOpc,aPergs)
/*
	.: Estrutura de aPergs :.
	-------------------------
	{
	1 - (Sim/Nao)Deseja atualizar as confirmacoes posteriores para considerar a (alteracao/exclusao/inclusao) efetuada ?
	2 - (Sim/Nao)Deseja excluir as confirmacoes cujos percentuais forem menores que 0% ou maiores que 100% ?
	}
	PS: Usado somente para o uso do Portal com WebServices
*/
Local lRetAut 		:= .F.
Local nA      		:= 0
Local lPerg1  		:= .F.
Local lPerg2  		:= .F.
Local lAxPerg 		:= .F.

Default aRotAut	:= {}
Default nOpc		:= 0
Default aPergs	:= {.T.,.T.}

If Len(aPergs) == 2
	For nA := 1 To 2
	 	Do Case
	 		Case ValType(aPergs[nA])=="C"
	 			lAxPerg := 	aPergs[nA]			== "1" .Or.;
	 							Upper(aPergs[nA])	== "S" .Or.;
	 							Upper(aPergs[nA])	== "SIM"
	 		Case ValType(aPergs[nA])=="N"
	 			lAxPerg := aPergs[nA] == 1
	 		Case ValType(aPergs[nA])=="L"
	 			lAxPerg := aPergs[nA]
	 	EndCase
	 	If nA == 1
	 		lPerg1 := lAxPerg
	 	ElseIf nA == 2
		 	lPerg2 := lAxPerg
	 	Endif
 	Next nA
Endif

If Len(aRotAut) > 0 .And. nOpc > 0
	lRetAut := PMSA311(nOpc,,aRotAut,lPerg1,lPerg2)
Else
	lRetAut := .F.
Endif
Return lRetAut

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � PMSA311  � Autor � Edson Maricate        � Data � 09-02-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Controle das Tarefas Realizadas do Projeto.      ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PMSA311(nCallOpcx,aGetCpos,aRotAuto,lWSPerg1,lWSPerg2)
Local lPMS311Auto := .F.
Local lContinua   := .T.
Local lSavAlt := .F.
Local lSavInc := .F.
Local lRet := .T.

Private cCadastro	:= STR0001 //"Tarefas Realizadas"

Default lWSPerg1 := .F.
Default lWSPerg2 := .F.

// Protegendo var para Portal PMS
If Type("Altera") <> "U"
	lSavAlt := Altera
Endif
If Type("Inclui") <> "U"
	lSavInc := Inclui
Endif

SaveInter()

Private aRotina := MenuDef()

If AMIIn(44)
	If nCallOpcx <> Nil
		If nCallOpcx > 0
			If aRotAuto <> Nil .And. (aGetCpos == Nil .Or. Len(aGetCpos) == 0)
				If (nCallOpcx==3 .Or. (nCallOpcx==4 .Or. nCallOpcx==5)) // Rotina automatica somente para as opcoes 3,4 e 5 (incluir, alterar e excluir)
					lPMS311Auto := .T.
					aGetCpos    := aRotAuto
				Else
					lContinua := .F.
				EndIf
			Else
				lContinua := .F.
				lRet := PMS311Dlg("AFF",AFF->(RecNo()),nCallOpcx,,,aGetCpos)
			EndIf

			If lContinua
				dbSelectArea("AFF")
				bBlock := &( "{ |x,y,z,k,w,a,b,c,d| " + aRotina[ nCallOpcx,2 ] + "(x,y,z,k,w,a,b,c,d) }" )
				Eval( bBlock,Alias(),AFF->(Recno()),nCallOpcx,,,aGetCpos,lPMS311Auto,lWSPerg1,lWSPerg2 )
			EndIf
		EndIf
	Else
		mBrowse(6,1,22,75,"AFF")
	EndIf

EndIf
RestInter()

If Type("Inclui") <> "U"
	Inclui := lSavInc
Endif
If Type("Altera") <> "U"
	Altera := lSavAlt
Endif

Return lRet


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PMS311Dlg� Autor � Edson Maricate         � Data � 09-02-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Programa de Inclusao,Alteracao,Visualizacao e Exclusao        ���
���          �do Controle de Tarefas Realizadas.                            ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PMS311Dlg(cAlias,nReg,nOpcx,xR1,xR2,aGetCpos,lAuto,lWSPrg1,lWSPrg2)

Local lContinua	:= .T.
Local lGravaOk		:= .F.
Local aAreaAFF		:= AFF->(GetArea())
Local aButtons		:= {}
Local aGetEnch
Local nRecAFF
Local oDlg
Local nx := 0
Local nQtdAnt := 0
Local lCanDel := .T.

Local aUsButtons := {}

Local cAFFProj  := ""
Local cAFFRev   := ""
Local cAFFTask  := ""
Local cAFFDate  := ""
Local cAFFQuant := ""

Local oEnchoice := Nil
Local oX := Nil
Local lOk		 := .F.

PRIVATE	Inclui 		:= .F.
PRIVATE	Altera		:= .F.
PRIVATE	Exclui		:= .F.
PRIVATE l311Inclui	:= .F.
PRIVATE l311Visual	:= .F.
PRIVATE l311Altera	:= .F.
PRIVATE l311Exclui	:= .F.

Private nOpc := nOpcx

Private lCntPrg	:= .F. // Auxilia para executar o If inicial
Default lAuto	:= .F.
Default lWSPrg1	:= .F.
Default lWSPrg2	:= .F.
Default lCntPrg	:= .F. // Auxilia para executar o If inicial


// define os botoes utilizados na barra de ferramentas
aButtons := {{"BMPINCLUIR", {||PmsPl311AE()}, STR0015}}  //"Detalhes"

// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
Do Case
	Case aRotina[nOpcx][4] == 2
		l311Visual := .T.
	Case aRotina[nOpcx][4] == 3
		l311Inclui	:= .T.
		Inclui 		:= .T.
	Case aRotina[nOpcx][4] == 4
		l311Altera	:= .T.
		Altera		:= .T.
	Case aRotina[nOpcx][4] == 5
		l311Exclui	:= .T.
		l311Visual	:= .T.
		EXCLUI 		:= .T.
EndCase

dbSelectArea("AFF")
RegToMemory("AFF",l311Inclui)
RegToMemory("AF9",.F.)

If l311Altera
	M->AFF_USER	  := RetCodUsr()
	M->AFF_NOMUSE := CriaVar("AFF_NOMUSE")
EndIf

If lContinua .And. l311Altera .Or. l311Exclui
	If !SoftLock("AFF") .Or. !MaCanAltAFF("AFF",.T.)
		lContinua := .F.
	Else
		nRecAFF := AFF->(RecNo())
	Endif
EndIf

// tratamento do array aGetCpos com os campos Inicializados do AFF
If lContinua .And. aGetCpos <> Nil
	aGetEnch	:= {}
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AFF")
	While !Eof() .and. SX3->X3_ARQUIVO == "AFF"
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nPosCpo	:= aScan(aGetCpos,{|x| x[1]==Alltrim(X3_CAMPO)})
			If nPosCpo > 0
				If aGetCpos[nPosCpo][3]
					aAdd(aGetEnch,AllTrim(X3_CAMPO))
				EndIf
			Else
				aAdd(aGetEnch,AllTrim(X3_CAMPO))
			EndIf
		EndIf
		dbSkip()
	End
	For nx := 1 to Len(aGetCpos)
		cCpo	:= "M->"+Trim(aGetCpos[nx][1])
		&cCpo	:= aGetCpos[nx][2]
	Next nx

	// verifica se confirmacao ja' existe para esta data.
	// para a rotina automatica
	If lContinua .And. l311Inclui .And. lAuto
		If !ExistChav("AFF",M->AFF_PROJET+M->AFF_REVISA+M->AFF_TAREFA+DTOS(M->AFF_DATA))
			lContinua := .F.
			Aviso(	STR0010	 ,;	//"Atencao"
			        STR0045	 +;	//"Ja existe confirmacao para esta data, impossivel incluir."
					CRLF	 +;
					STR0046	 ,;	//"Caso seja necessario, edite confirmacao existente."
					{STR0012})		//"OK"
		Endif
	Endif
EndIf

If lContinua .And. ExistTemplate("PMS311INIC")
	lContinua := ExecTemplate("PMS311INIC",.F.,.F.,{ l311Inclui ,l311Altera ,l311Exclui } )
EndIf

If lContinua .And. l311Inclui .And. ExistBlock("PMA311IN")
	lContinua := ExecBlock("PMA311IN",.F.,.F.)
EndIf

If lContinua .And. l311Altera .And. ExistBlock("PMA311AL")
	lContinua := ExecBlock("PMA311AL",.F.,.F.)
EndIf

dbSelectArea("AFF")

If lContinua

	// adiciona botoes do usuario na EnchoiceBar
	If ExistBlock( "PMA311BT" )

		//P_E������������������������������������������������������������������������Ŀ
		//P_E� Ponto de entrada utilizado para inclusao de botoes de usuarios         �
		//P_E� na tela de confirmacoes                                                �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�  Ex. :  User Function PMA311BT                                         �
		//P_E�         Return { 'PEDIDO', {|| MyFun() },"Exemplo de Botao" }          �
		//P_E��������������������������������������������������������������������������

		If ValType( aUsButtons := ExecBlock( "PMA311BT", .F., .F. ) ) == "A"
			AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
		EndIf
	EndIf

	// se a rotina nao for automatica, mostra a tela
	If !lAuto
		DEFINE MSDIALOG oDlg TITLE STR0007 FROM 0,0 TO 31,78 OF oMainWnd //"Controle de Execucao"

			// confirma��o
			oX := MsMGet():New(cAlias,nReg,nOpcx,,,,, {1, 1, 100, 307},aGetEnch,3,,,,oDlg)
			oX:oBox:Align := CONTROL_ALIGN_ALLCLIENT

			// tarefa
			M->AF9_OBS := MSMM(AF9->AF9_CODMEM,TamSX3("AF9_OBS")[1],,,3,,,"AF9", "AF9_CODMEM")
			oEnchoice := MsMGet():New("AF9",AF9->(RecNo()),2,,,,,{144,1,235,307},,3,,,,oDlg,,,)
			oEnchoice:oBox:Align := CONTROL_ALIGN_BOTTOM

			FATPDLogUser("PMS311DLG")

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||iIf(Obrigatorio(oX:aGets,oX:aTela) .And. AffTudok(l311Inclui,l311Exclui,l311Altera),(lGravaOk:=.T.,lOk:=.T.,oDlg:End()),Nil)},{|| oDlg:End()},,aButtons) CENTERED

	// eh uma rotina automatica
	Else
		Private aGets := {}
		Private aTela := {}

		// se for visualizacao, nao deve validar campos.
		If l311Visual .AND. (!l311Inclui .AND. !l311Altera .AND. !l311Exclui)
			lOk := .F.
		Else
			If EnchAuto(cAlias,aGetCpos,{|| Obrigatorio(aGets,aTela) .And. AffTudok(l311Inclui,l311Exclui,l311Altera) },nOpcx)
				lOk      := .T.
				lGravaOk := .T.
			EndIf
		EndIf
	EndIf
EndIf

If (l311Inclui .Or. l311Altera .Or. l311Exclui ).And. lGravaOk .And. lOk
	If l311Exclui .And. ExistBlock("PMA311EX")
		If !ExecBlock("PMA311EX",.F.,.F.)
			Return
		EndIf
	EndIf

	If l311Altera .Or. l311Exclui
		cAFFProj  := AFF->AFF_PROJET
		cAFFRev   := AFF->AFF_REVISA
		cAFFTask  := AFF->AFF_TAREFA
		cAFFDate  := DToS(AFF->AFF_DATA)
		cAFFQuant := AFF->AFF_QUANT

		nQtdAnt := AFF->AFF_QUANT
	EndIf

	Begin Transaction
		MsAguarde( {|| PMS311Grava(l311Exclui,nRecAFF),,STR0054 } )//"Gravando a Confirma��o da tarefa"
	End Transaction

	If l311Inclui
		nQtdAnt   := M->AFF_QUANT

		cAFFProj  := M->AFF_PROJET
		cAFFRev   := M->AFF_REVISA
		cAFFTask  := M->AFF_TAREFA
		cAFFDate  := DToS(M->AFF_DATA)
		cAFFQuant := M->AFF_QUANT
	EndIf

	// recalcular os apontamentos posteriores a data
	If l311Altera .And. PMSExistAFF(AFF->AFF_PROJET, AFF->AFF_REVISA, AFF->AFF_TAREFA, DToS(AFF->AFF_DATA + 1))
		If lAuto
			lCntPrg := lWsPrg1
		Else
			If Aviso(STR0027,; //"Atualizar confirmacoes"
				       STR0028,; //"Deseja atualizar as confirmacoes posteriores para considerar a alteracao efetuada?"
				       {STR0032, STR0033}, 3) == 1 //"Sim"###"Nao"
				lCntPrg := .T.
			Else
		 		lCntPrg := .F.
		 	Endif
		Endif

		If lCntPrg

			AFF->(dbGoto(nRecAFF))

			If lAuto
				lCntPrg := lWsPrg2
			Else

				//
				// Confirma��o do usu�rio para deletar as confirma��es
				// que resultem em quantidade <= 0 ou
				// quantidade > quantidade da tarefa
				//
				If Aviso(STR0027,; //"Atualizar confirmacoes"
 				         STR0034,; //"Deseja excluir as confirmacoes cujos percentuais forem menores que 0% ou maiores que 100%?"
				         {STR0032, STR0033}, 3) == 1 //"Sim"###"Nao"
					lCntPrg := .T.
			 	Else
			 		lCntPrg := .F.
			 	Endif
			Endif

			//
			// Confirma��o do usu�rio para deletar as confirma��es
			// que resultem em quantidade <= 0 ou
			// quantidade > quantidade da tarefa
			//
			lCanDel := lCntPrg

			// recalcula os apontamentos, sugerindo a diferen�a entre
			// a quantidade anterior e a quantidade alterada como valor
			// a ser aplicado
			PMS311Rec(AFF->AFF_PROJET, AFF->AFF_REVISA, AFF->AFF_TAREFA,;
			          DToS(AFF_DATA), GetNewDiff(AFF->AFF_QUANT - nQtdAnt,lAuto), lCanDel)
		EndIf
	EndIf

	// recalcular os apontamentos posteriores a data
	If l311Exclui .And. PMSExistAFF(AFF->AFF_PROJET, AFF->AFF_REVISA, AFF->AFF_TAREFA, DToS(AFF->AFF_DATA + 1))
		If lAuto
			lCntPrg := lWsPrg1
		Else
			If Aviso(	STR0027,;  //"Atualizar confirmacoes"
		         		STR0029,;  //"Deseja atualizar as confirmacoes posteriores para considerar a exclusao efetuada?"
		         		{STR0032, STR0033}, 3) == 1 //"Sim"###"Nao"
				lCntPrg := .T.
			Else
		 		lCntPrg := .F.
		 	Endif
		Endif

		If lCntPrg
			If lAuto
				lCntPrg := lWsPrg2
			Else
				//
				// Confirma��o do usu�rio para deletar as confirma��es
				// que resultem em quantidade <= 0 ou
				// quantidade > quantidade da tarefa
				//
				If Aviso(	STR0027,; //"Atualizar confirmacoes"
				         	STR0034,; //"Deseja excluir as confirmacoes cujos percentuais forem menores que 0% ou maiores que 100%?"
				         	{STR0032, STR0033}, 3) == 1 //"Sim"###"Nao"
					lCntPrg := .T.
				Else
			 		lCntPrg := .F.
			 	Endif
			Endif

			lCanDel := lCntPrg

			// recalcula os apontamentos, sugerindo a quantidade
			// do apontamento exclu�do como valor a ser aplicado
			PMS311Rec(cAFFProj, cAFFRev, cAFFTask, cAFFDate, GetNewDiff(cAFFQuant * -1,lAuto), lCanDel)
		EndIf
	EndIf

	// recalcular os apontamentos posteriores a data
	If l311Inclui .And. PMSExistAFF(AFF->AFF_PROJET, AFF->AFF_REVISA, AFF->AFF_TAREFA, DToS(AFF->AFF_DATA + 1))
		If lAuto
			lCntPrg := lWsPrg1
		Else
			If Aviso(	STR0027,;  //"Atualizar confirmacoes"
		         		STR0030,;  //"Deseja atualizar as confirmacoes posteriores para considerar a inclus�o efetuada?"
		         		{STR0032, STR0033}, 3) == 1 //"Sim"###"Nao"
				lCntPrg := .T.
			Else
		 		lCntPrg := .F.
		 	Endif
		Endif

		If lCntPrg
			If lAuto
				lCntPrg := lWsPrg1
			Else

				//
				// Confirma��o do usu�rio para deletar as confirma��es
				// que resultem em quantidade <= 0 ou
				// quantidade > quantidade da tarefa
				//
				If Aviso(	STR0027,; //"Atualizar confirmacoes"
				         	STR0034,; //"Deseja excluir as confirmacoes cujos percentuais forem menores que 0% ou maiores que 100%?"
				         	{STR0032, STR0033}, 3) == 1 //"Sim"###"Nao"
					lCntPrg := .T.
				Else
			 		lCntPrg := .F.
			 	Endif
			Endif

			lCanDel := lCntPrg

			// recalcula os apontamentos, sugerindo a quantidade
			// do apontamento inclu�do como valor a ser aplicado
			PMS311Rec(cAFFProj, cAFFRev, cAFFTask, cAFFDate, GetNewDiff(cAFFQuant,lAuto), lCanDel)
		EndIf

	EndIf
EndIf

RestArea(aAreaAFF)
Return lGravaOk

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PMS311Grava� Autor � Edson Maricate       � Data � 09-02-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Programa de gravacao de Tarefas Realizadas.                   ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PMS311Grava(lDeleta,nRecAFF)
Local nx := 0
Local bCampo 	:= {|n| FieldName(n) }
Local aArea		:= GetArea()
Local aAreaAF9  := {}
Local aArea2AF9 := {}
Local aAreaAN8  := {}
Local nQTMKPMS	:= GetNewPar("MV_QTMKPMS",0)
Local cAcao 	:= ""
Local cRevaca 	:= ""
Local cAF9found := ""
Local cUsuario	:= ""

If ValType(nQTMKPMS) != "N"
	nQTMKPMS := 0
EndIf

If !lDeleta
	If !Empty(RetCodUsr())
		cUsuario := RetCodUsr() //Usu�rio do protheus
	Else
		cUsuario := UsrPrtErp() //Usuario do portal
	EndIf
	If nRecAFF <> Nil
		AFF->(dbGoto(nRecAFF))
		PmsAvalAFF("AFF",2)
		RecLock("AFF",.F.)
	Else
		RecLock("AFF",.T.)
	EndIf
	For nx := 1 TO FCount()
		FieldPut(nx,M->&(EVAL(bCampo,nx)))
	Next nx
	AFF->AFF_FILIAL	:= xFilial("AFF")
	AFF->AFF_USER	:= cUsuario
	MsUnlock()
	MSMM(,TamSx3("AFF_OBS")[1],,m->AFF_OBS,1,,,"AFF","AFF_CODMEM")
	PmsAvalAFF("AFF",1)

	If M->AFF_PERC == 100
		/*BEGINDOC
		//������������������������������Ŀ
		//�INTEGRA��O QNC x PLANO DE ACAO�
		//��������������������������������
		ENDDOC*/
		dbSelectArea("AF9")
		aAreaAF9  := AF9->(GetArea())
		dbSetOrder(1)
		If MsSeek(xFilial("AF9")+AFF->AFF_PROJET+AFF->AFF_REVISA+AFF->AFF_TAREFA,.F.)
			If !Empty(AF9->AF9_ACAO)
				If __lRejec//Se � uma rejei��o,
					// Busca outas taerfas que foram abertas em paralelo
					AF9->(dbSetOrder(6))
					cAcao 		:= AF9->AF9_ACAO
					cRevaca 	:= AF9->AF9_REVACA
					aArea2AF9	:= AF9->(GetArea())
					AF9->(dbSeek(xFilial("AF9")+cAcao+cRevaca,.F.))
					While AF9->(!EOF()) .AND. AF9->AF9_ACAO+AF9->AF9_REVACA == cAcao+cRevaca
						   	RegToMemory("AFF",.F.)
							RecLock("AFF",.T.)
							For nx := 1 TO FCount()
								FieldPut(nx,M->&(EVAL(bCampo,nx)))
							Next nx
							AFF->AFF_FILIAL	:= xFilial("AFF")
							AFF->AFF_USER	:= cUsuario
							AFF->AFF_TAREFA	:= AF9->AF9_TAREFA
							MsUnlock()
							MSMM(,TamSx3("AFF_OBS")[1],,"Tarefa rejeitada",1,,,"AFF","AFF_CODMEM")
						AF9->(DbSkip())
					EndDo
					RestArea(aArea2AF9)

					dbSelectArea("QI5")
					QNC50BXPEND(AF9->AF9_ACAO,AF9->AF9_REVACA,AF9->AF9_TPACAO,__cQNCRej,__cQNCDEP,__cNEWQUO,M->AFF_OBS)//Rejeitou
					// atualiza a hora total executada
					QN5AltPrz(AF9->AF9_FNC,AF9->AF9_REVFNC,AF9->AF9_TPACAO,,,QNCPrzHR2(PMS320THr(AFF->AFF_PROJET,AFF->AFF_REVISA,AFF->AFF_TAREFA),"D","H","H","H"))

				Else	//Caso contr�rio.
					Q50BXTMKPMS(xFilial("QI5"),AF9->AF9_ACAO,AF9->AF9_REVACA,AF9->AF9_TPACAO,.F.,M->AFF_TAREFA,M->AFF_OBS)
					// atualiza a hora total executada
					QN5AltPrz(AF9->AF9_FNC,AF9->AF9_REVFNC,AF9->AF9_TPACAO,,,QNCPrzHR2(PMS320THr(AFF->AFF_PROJET,AFF->AFF_REVISA,AFF->AFF_TAREFA),"D","H","H","H"))
				EndIf
			EndIf
	  	EndIf
		RestArea(aAreaAF9)

		dbSelectArea("AF9")
		aAreaAF9  := AF9->(GetArea())
		dbSetOrder(1)
		If MsSeek(xFilial("AF9")+AFF->AFF_PROJET+AFF->AFF_REVISA+AFF->AFF_TAREFA,.F.)
			dbSelectArea("AN8")
			aAreaAN8  := AN8->(GetArea())
			AN8->(dbSetOrder(1)) //AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA+DTOS(AN8_DATA)+AN8_HORA+AN8_TRFORI
			If AN8->( MsSeek( xFilial("AN8")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA) ) )
				Do While !AN8->(Eof()) .And. AN8->(AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA)==xFilial("AN8")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)
					If AN8->AN8_STATUS=='1'
						RecLock("AN8",.F.)
						AN8->AN8_STATUS := '3'
						MsUnlock()
					EndIf
					AN8->(dbSkip())
				EndDo
		  	EndIf
			RestArea(aAreaAN8)
		EndIf
	EndIf
	If ExistBlock("PMA311GRV")
		ExecBlock("PMA311GRV",.F.,.F.)
 	EndIf

Else
	AFF->(dbGoto(nRecAFF))
	PmsAvalAFF("AFF",2)
	PmsAvalAFF("AFF",3)
EndIf

RestArea(aArea)

Return


/*/{Protheus.doc} PmsEdtStartStop
Inicia/Termina uma EDT

@param nOpc, numerico, ${param_descr}
@param oTree, objeto, ${param_descr}

@return ${return}, ${return_description}

@author Michel
@since 01/06/01
@version 1.0
/*/
Function PmsEdtStartStop(nOpc,oTree)
Local aCposAff   := {}
Local aOpc       := {STR0008,STR0009} //"Inicio da Tarefa"###"Fim da Tarefa"
Local cAlias     := Substr(cCargo,1,3)
Local cCargo     := oTree:GetCargo()
Local lOk        := .F.
Local lStartStop := .F.
Local nRec       := Val(Substr(cCargo,4))
Local oDlg
Local oEnch

Private nStartStop := If(nOpc==1,0,100)

DbSelectArea(cAlias)

DbGoto(nRec)
If AF9_EDT == "1"
	Aviso(STR0010,STR0011,{STR0012}) //"Aten��o"###"Apenas tarefas podem ser iniciadas/finalizadas"###"OK"
	Return .F.
EndIf

DbSelectArea("AFF")

If DbSeek( xFilial("AF9")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA ) .and. nOpc == 1
	Aviso(STR0010,STR0013,{STR0012}) //"Aten��o"###"A tarefa j� foi inicializada"###"OK"
	Return .F.
else
	If !Found() .and. nOpc == 2
		lStartStop := .T.
	EndIf
EndIf

If nOpc == 2
	DbSeek( xFilial("AF9")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+"Z",.T. )
	DbSkip(-1)
	If AFF_PROJET+AFF_REVISA+AFF_TAREFA == AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA  .and. AFF_QUANT == AF9->AF9_QUANT
		Aviso(STR0010,STR0014,{STR0012}) //"Aten��o"###"A tarefa j� foi finalizada"###"OK"
		Return .F.
	EndIf
EndIf
RegToMemory("AFF", .T.)


// array contendo os campos que podem ser alterados pela Enchoice
AAdd(aCposAff,"AFF_DATA")
AAdd(aCposAff,"AFF_OCORRE")
AAdd(aCposAff,"AFF_OBSERV")

m->AFF_DATA := dDataBase
m->AFF_PERC   := 0
m->AFF_QUANT  := 0
m->AFF_FILIAL := xFilial("AF9")
m->AFF_PROJET := AF9->AF9_PROJET
m->AFF_REVISA := AF9->AF9_REVISA
m->AFF_DATA   := dDataBase
m->AFF_TAREFA := AF9->AF9_TAREFA

If nOpc == 2
	m->AFF_PERC  := 100
	m->AFF_QUANT := AF9->AF9_QUANT
EndIf

DEFINE MSDIALOG oDlg TITLE aOpc[nOpc] From 8,0 to 24,78
	oEnch := MsMGet():New("AFF", 0, 3,,,,, { 16, 1, 118, 307 },aCposAff , 3,,,,oDlg)
	oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| lOk := .T.,oDlg:End()},{|| oDlg:End()})

If lOk
	If lStartStop
		M->AFF_QUANT := AF9->AF9_QUANT
	EndIf
	If !MsSeek( xFilial("AFF") + m->AFF_PROJET + m->AFF_REVISA + m->AFF_TAREFA + DTOS(m->AFF_DATA) )
		nRec := NIL
	Else
		nRec := Recno()
	EndIf
	Begin Transaction
		PMS311Grava(.F.,nRec)
	End Transaction
	oTree:Refresh()
EndIf

Return .T.


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AffTudok  �Autor  �Michel              � Data �  22/06/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida uma EDT para seu valor ser 0 ou 100% concluida       ���
���          �e sua data seja <> de Vazia                                 ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function AffTudok(lIncLui,lExclui,lAltera)
Local lRet := ValidEdt("M->AFF_PERC",lExclui) .And. ValidEdt("M->AFF_QUANT",lExclui) .And. NaoVazio(M->AFF_DATA)
Local aArea := GetArea()
Local aAreaAF9 := {}
Local aAreaAFD := {}
Local aAreaAFP := {}
Local aAreaSE1 := {}
Local aAreaAFT := {}
Local aAreaAFA := {}
Local aAreaAE8 := {}

Local aHeaderANA
Local aColsANA 		:= {}
Local aMotivos		:= {}
Local cGetOpc		:= GD_INSERT+GD_DELETE+GD_UPDATE
Local oGDItens
Local nInc			:= 0
Local nPosTpErro	:= 0
Local nPosDesc		:= 0
Local nRet			:= 0
Local oMotivo
Local oBtn1
Local oBtn2
Local oSay2
Local oDlg
Local cAcao 		:= ""
Local cRevaca 	:= ""
Local aArea2AF9	:= {}
Local aColsRej 	:= {}
Local aHeadRej 	:= {}
Local nLoop 		:= 0
Local aFields 	:= {}

Private aGets   	:= {}
Private aTela   	:= {}
Private bLinGtd		:= {|| If(Valtype(oGDItens)="O",oGDItens:nAt,0) }
Private INCLUI		:= .T.
Private oEnch
Private oGetD

// pesquisa se existe uma tarefa com relacionamento
// fim-no-inicio a tarefa atual. se existir, n�o permitir incluir
// a confirma��o se a tarefa predecessora n�o estiver confirmada em 100%.
If GetNewPar("MV_PMSPRE",  2) == 1
	dbSelectArea("AFD")
	aAreaAFD := AFD->(GetArea())
	dbSetOrder(1) //AFD_FILIAL + AFD_PROJET + AFD_REVISA + AFD_TAREFA + AFD_ITEM

	If MsSeek(xFilial("AFD") + M->AFF_PROJET + M->AFF_REVISA + M->AFF_TAREFA)
		While !AFD->(Eof()) .And.;
			AFD->AFD_FILIAL + AFD->AFD_PROJET + AFD->AFD_REVISA + AFD->AFD_TAREFA =;
			xFilial("AFD")  + M->AFF_PROJET   + M->AFF_REVISA   + M->AFF_TAREFA

			If AFD->AFD_TIPO == "1"
				If !IsConcluded(AFD->AFD_PROJET, AFD->AFD_REVISA, AFD->AFD_PREDEC)
					Aviso(STR0024,STR0035,{STR0026},2)  //"Atencao"###"N�o � poss�vel confirmar esta tarefa pois h� uma tarefa precedessora (fim-no-in�cio) que ainda n�o foi confirmada em 100%.""###"Fechar"
					lRet := .F.
					Exit
				EndIf
			EndIf

			AFD->(dbSkip())
		End
	EndIf
	RestArea(aAreaAFD)
EndIf

If lRet .And. (lInclui .Or. lAltera)
	lRet := PmsVlRelac(M->AFF_PROJET, M->AFF_REVISA, M->AFF_TAREFA, M->AFF_PERC)
EndIf

If lRet	.And. (lExclui .Or. lAltera)
	If lExclui
		nPerc	:=	0
	Else
		nPerc	:=	M->AFF_PERC
	Endif

	dbSelectArea("AFT")
	aAreaAFT := AFT->(GetArea())
	dbSetOrder(2)
	dbSelectArea("SE1")
	aAreaSE1 := SE1->(GetArea())
	dbSetOrder(2)
	dbSelectArea("AFP")
	aAreaAFP := AFP->(GetArea())
	dbSetOrder(1)
	cSeek := xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
	MsSeek(cSeek)
	While lRet	.And.  !Eof() .And. cSeek==AFP_FILIAL+AFP_PROJETO+AFP_REVISA+AFP_TAREFA
		If AFP->AFP_DTATU==AFF->AFF_DATA
			If nPerc <= AFP_PERC

				// verifica se existem titulos Normais gerados para o
				// evento, que tiveram movimentos
				dbSelectArea("SE1")
				MsSeek(PmsFilial("SE1", "AFP")+AFP->AFP_CLIENT+AFP->AFP_LOJA+AFP->AFP_PREFIX+AFP->AFP_NUM)
				While lRet	.And. !Eof() .And. PmsFilial("SE1", "AFP")+AFP->AFP_CLIENT+AFP->AFP_LOJA+AFP->AFP_PREFIX+AFP->AFP_NUM==;
									E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM

					If !(SE1->E1_TIPO$MVNOTAFIS) .Or. !Empty(SE1->E1_BAIXA) .Or. SE1->E1_VALOR <> SE1->E1_SALDO .Or. !(SE1->E1_SITUACA $ " 0")
						dbSelectArea("AFT")
						If MsSeek(xFilial()+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA) .And. AFT->AFT_EVENTO==AFP->AFP_ITEM
							Aviso(STR0036,STR0037+CRLF+;
									STR0038+SE1->E1_TIPO+STR0039+SE1->E1_PREFIXO+CRLF+;
									STR0040 +SE1->E1_NUM+STR0041+SE1->E1_PARCELA+CRLF+CRLF+;
									STR0042+	If(lExclui, STR0043,STR0044+Alltrim(Str(AFP->AFP_PERC))+"%."),{"Ok"},3)
							lRet	:=	.F.
						EndIf
					Endif
					dbSelectArea("SE1")
         			DbSkip()
				Enddo
			EndIf
		EndIf
		dbSelectArea("AFP")
		dbSkip()
	EndDo
	RestArea(aAreaAFT)
	RestArea(aAreaSE1)
	RestArea(aAreaAFP)

Endif

If lRet .AND. (M->AFF_PERC == 100)
	__lRejec 	:= .F.       	///	VARIAVEL PRECISA ESTAR DISPON�VEL NA PMS311GRAVA() QUANDO H� INTEGRA��O QNC (MV_QTMKPMS) 3 ou 4.

	dbSelectArea("AF9")
	aAreaAF9 := AF9->(GetArea())
	dbSetOrder(1)
	If MsSeek(xFilial("AF9")+M->AFF_PROJET + M->AFF_REVISA + M->AFF_TAREFA)
		//
		// Se PMS esta integrado com QNC
		//
		If !Empty(AF9->AF9_ACAO) .AND. !Empty(AF9->AF9_REVACA) .AND. !Empty(AF9->AF9_TPACAO)
			///Define as etapas que n�o tem obrigatoriedade
			__cQNCRej	:= ""
			__cQNCDEP	:= ""
			__cNEWQUO	:= ""

			MsAguarde({||lRet := QAltObrigEtp(AF9->AF9_ACAO ,AF9->AF9_REVACA ,AF9->AF9_TPACAO,.T.,@__lRejec,@__cQNCRej,@__cQNCDEP,@__cNEWQUO)} ,"Proximas etapas/passos","Processando o Plano de a��o: "+Transform(AF9->AF9_ACAO,X3Picture("AF9_ACAO"))+"/"+Transform(AF9->AF9_REVACA,X3Picture("AF9_REVACA")))

			// Se houver rejeicao do plano de acao, visualiza a tela
			// para informar os tipos de erros e os motivos da rejeicao
			If __lRejec
				dbSelectArea("AE8")
				aAreaAE8 := AE8->(GetArea())
				dbSetOrder(1)
				dbSelectArea("AFA")
				aAreaAFA := AFA->(GetArea())
				dbSetOrder(1)
				// Busca outas tarefas que foram abertas em paralelo
				// se houver tarefas parcialmente executadas, deve apresetnar mensagem ao usuario
				// para que os recursos com a tarefa em paralelo encerrem.
				cAcao 		:= AF9->AF9_ACAO
				cRevaca 	:= AF9->AF9_REVACA
				aArea2AF9	:= AF9->(GetArea())
				AF9->(dbSetOrder(6))
				AF9->(dbSeek(xFilial("AF9")+cAcao+cRevaca,.F.))
				While AF9->(!EOF()) .AND. AF9->(AF9_FILIAL+AF9_ACAO+AF9_REVACA) == xFilial("AF9")+cAcao+cRevaca
					// Busca pelas OUTRAS tarefas com o mesmo plano e revis�o
					If  xFilial("AF9")+M->AFF_PROJET + M->AFF_REVISA + M->AFF_TAREFA<>AF9->(AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA)
						// se a tarefa em paralelo est� em execucao
						If !Empty(AF9->AF9_DTATUI) .And. Empty(AF9->AF9_DTATUF)
							dbSelectArea("AFA")
							dbSeek(xFilial("AFA")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA))
							Do While !AFA->(Eof()) .And. AFA->(AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA)==xFilial("AFA")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)
								If AE8->(dbSeek(xFilial("AE8")+AFA->AFA_RECURS))
									cAFA_RECUR := AFA->AFA_RECURS
									cAF8_DESCR := AE8->AE8_DESCRI
								EndIf
								If AFA->AFA_RESP = "S"
									EXIT
								EndIf
								AFA->(dbSkip())
							EndDo
							aAdd( aColsRej, {cAFA_RECUR,cAF8_DESCR,AF9->AF9_TAREFA,AF9->AF9_DESCRI,AF9->AF9_DTATUI,PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataBase),.F.})
						EndIf
					EndIf
					dbSelectArea("AF9")
					DbSkip()
				EndDo
				RestArea(aArea2AF9)
				RestArea(aAreaAFA)
				RestArea(aAreaAE8)

				// REJEICAO SOMENTE PODE OCORRER QUANDO AS TAREFAS EM PARALELO FOREM ENCERRADAS
				// Titulo da janela : rejeicao Tarefas em paralelo
				// Mensagem:
				// grade: Codigo/Nome recurso, Codigo/Descricao Tarefa,  Data real inicio e % executado
				If !Empty(aColsRej)

					lRet := .F.

					aHeadRej := {}
					aFields := {"AFA_RECURS","AE8_DESCRI","AF9_TAREFA","AF9_DESCRI","AF9_DTATUI","AFF_PERC"}

					SX3->(dbSelectArea("SX3"))
					SX3->(dbSetOrder(2))
					For nLoop := 1 to len(aFields)

						If SX3->(dbSeek(aFields[nLoop])).AND. X3USO(SX3->X3_USADO)

							aAdd(aHeadRej,{ TRIM(X3TITULO()) ,SX3->X3_CAMPO ,SX3->X3_PICTURE;
							               ,SX3->X3_TAMANHO ,SX3->X3_DECIMAL ,SX3->X3_VALID;
							               ,SX3->X3_USADO ,SX3->X3_TIPO ,SX3->X3_ARQUIVO ,SX3->X3_CONTEXT } )
						EndIf
					Next nLoop

					DEFINE MSDIALOG oDlg TITLE STR0055 FROM 0, 0 TO 260,675 PIXEL //"Rejeicao com Tarefas em paralelo"
					@  10,   5 SAY oSay2 PROMPT STR0056 SIZE 300, 14 OF oDlg PIXEL //"Tarefas abaixo em execu��o. O plano de a��o somente pode ser rejeitado quando as mesmas forem encerradas."

					oGDItens:= MsNewGetDados():New( 030,005,105,325, 0,,,,,,,,,, oDlg, aHeadRej, aColsRej )

					@ 110, 280 BUTTON oBtn2 PROMPT STR0051 SIZE 37, 12 ACTION (oDlg:End()) OF oDlg PIXEL //"Cancela"
					ACTIVATE MSDIALOG oDlg CENTERED

				EndIf

				If lRet
					//***************
					// Monta aCols	*
					//***************
					aHeaderANA			:= GetaHeader( "ANC", { "ANC_TIPERR", "ANC_MOTIVO" /*exibir*/ }, { "ANA_SEVCOD" /*nao exibir*/} )
					aAdd( aColsANA, { Space( TamSX3( "ANC_TIPERR" )[1] ), Space( TamSX3( "ANC_MOTIVO" )[1] ), NIL } )
					aColsANA[Len(aColsANA),Len(aHeaderANA) + 1] := .F.

					DEFINE MSDIALOG oDlg TITLE STR0047 + " " + AF9->AF9_TAREFA FROM 0, 0 TO 250,450 PIXEL //"Tarefa"

					@  10,   5 SAY oSay2 PROMPT STR0048 SIZE 25, 7 OF oDlg PIXEL //"Motivo:"

					oGDItens:= MsNewGetDados():New( 020,005,105,225, cGetOpc,,,,,,,,,, oDlg, aHeaderANA, aColsANA )

					@ 110, 147 BUTTON oBtn1 PROMPT STR0049 SIZE 37, 12 ACTION IIf( !VldRjtTrf( oGDItens, aScan( aHeaderANA, { |x| x[2] == "ANC_MOTIVO" } ) ), MsgInfo( STR0050 ), (lRet := .T., oDlg:End()) ) OF oDlg PIXEL //"Ok"##"Motivo nao informado"
					@ 110, 187 BUTTON oBtn2 PROMPT STR0051 SIZE 37, 12 ACTION (lRet := .F., oDlg:End()) OF oDlg PIXEL //"Cancela"
					ACTIVATE MSDIALOG oDlg CENTERED

					// Atualiza o array a motivos com as informacoes digitadas
					aMotivos := {}
					If lRet
						nPosTpErro	:= aScan( aHeaderANA, { |x| x[2] == "ANC_TIPERR" } )
						nPosDesc	:= aScan( aHeaderANA, { |x| x[2] == "ANC_MOTIVO" } )

						For nInc := 1 To Len( oGDItens:aCols )
							aAdd( aMotivos, { oGDItens:aCols[nInc][nPosTpErro], oGDItens:aCols[nInc][nPosDesc], 0 } )
						Next
					EndIf
				EndIf

			EndIf
		EndIf
	EndIf
	RestArea(aAreaAF9)

	If lRet .And. !__lRejec
		lRet := SIMCHLok()[1]
	EndIf

EndIf

If lRet .And. ExistBlock("PMA311VL")
	lRet  := ExecBlock("PMA311VL",.F.,.F.,{__lRejec,__cQNCRej})
EndIf

// Grava os motivos de rejeicoes do plano de acao
If lRet .And. __lRejec .And. !Empty( aMotivos )
	BEGIN TRANSACTION
		cAlias := "ANC"
		PMSGrvMotivo( .F., aMotivos, M->AFF_USER, AF9->( RecNo() ), AN8->( RecNo() ), QUS->QUS_ETPPRX, @cAlias )
		// Projeto TDI - TELXEZ Anexo no processo de rejeicao
		if MsgYesNo(STR0052) //  "Deseja incluir anexos para os motivos informados ?"
			//	chamar a rotina de exibicao das rejeicoes com opcao de anexos
			if ! PMA311Anexo(cAlias, aHeaderANA, oGDItens:aCols, aMotivos)
				DisarmTransaction()
				lRet := .F.
			Endif
		Endif
	END TRANSACTION
EndIf

RestArea(aArea)

Return lRet


/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �PmsPl311AE� Autor � Edson Maricate        � Data �28.05.2003 ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Cria uma tela de consulta das Autorizacoes de Entrega geradas���
���          �pelas confirmacoes.                                          ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       �Materiais                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PmsPl311AE()

Local oDlg
Local aViewPC	:= {}
Local aArea		:= GetArea()
Local aAreaSC7:= SC7->(GetArea())

SC7->(dbSetOrder(1))

dbSelectArea("AJ9")
dbSetOrder(1)
If dbSeek(xFilial()+AFF->AFF_PROJET+AFF->AFF_REVISA+AFF->AFF_TAREFA+DTOS(AFF->AFF_DATA))
	While !Eof() .And. 	xFilial()+AFF->AFF_PROJET+AFF->AFF_REVISA+AFF->AFF_TAREFA+DTOS(AFF->AFF_DATA)==AJ9->AJ9_FILIAL+AJ9->AJ9_PROJET+AJ9->AJ9_REVISA+AJ9_TAREFA+DTOS(AJ9->AJ9_DATA)
		dbSelectArea("SC7")
		dbSetOrder(1)
		If dbSeek(xFilial()+AJ9->AJ9_NUMAE+AJ9->AJ9_ITEMAE)
			aAdd(aViewPC,{C7_NUM,C7_ITEM,C7_PRODUTO+"-"+C7_DESCRI,TransForm(C7_QUANT,PesqPict("SC7","C7_QUANT")),TransForm(C7_QUJE,PesqPict("SC7","C7_QUJE")),C7_DATPRF})
		EndIf
		dbSelectArea("AJ9")
		dbSkip()
	End
	DEFINE MSDIALOG oDlg FROM 85,35 to 325,605 TITLE STR0016 Of oMainWnd PIXEL //"Confirmacao : Autorizacoes de Entrega"
		oListBox := TWBrowse():New( 16,1,284,105,,{STR0017,STR0018,STR0019,STR0020,STR0021,STR0022},,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Num.AE"###"Item AE"###"Produto"###"Quantidade"###"Qtde. Entregue"###"Necessidade"
		oListBox:SetArray(aViewPC)
		oListBox:bLine := { || aViewPC[oListBox:nAT]}
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,{{"BMPINCLUIR",{||MaViewPC(aViewPC[oListBox:nAT][1])},STR0023}} ) //"+Detalhes"
Else
	Aviso(STR0024,STR0025,{STR0026},2)  //"Atencao"###"Nao existem Autorizacoes de Entrega geradas a partir desta confirmacao."###"Fechar"
EndIf

RestArea(aAreaSC7)
RestArea(aArea)
Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PMS311Rec� Autor � Adriano Ueda           � Data � 08/11/2004 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Fun��o para o rec�lculo de confirma��es efetuadas posterior-  ���
���          �mente, para uma tarefa espec�fica                             ���
���          �                                                              ���
���          �Para cada confirma��o da tarefa que seja posterior a data     ���
���          �(cDate) informada ser� somada um diferen�a (nDiff).           ���
���          �                                                              ���
���          �Ap� a soma, se a quantidade confirmada for negativa, ser�     ���
���          �considerada como quantidade zero, e assim, a confirma��o ser� ���
���          �automaticamente exclu�da.                                     ���
���          �                                                              ���
���          �Se a quantidade confirmada for maior que a quantidade da      ���
���          �tarefa, ser� considerada a quantidade da tarefa. Deste modo,  ���
���          �                                                              ���
���          � 0 < AFF_QUANT + nDiff <= AF9_QUANT,                          ���
���          �                                                              ���
���          �onde nDiff >= 0 ou nDiff <= 0                                 ���
���������������������������������������������������������������������������Ĵ��
���Par�metros�cProject - c�digo do projeto                                  ���
���          �cRev     - revis�o                                            ���
���          �cTask    - c�digo da tarefa                                   ���
���          �cDate    - data a partir da qual ser� recalculada as confirm. ���
���          �nAFFDiff - diferen�a a ser somada a tarefa                    ���
���          �lCanDel  - indica se a tarefa pode ser exclu�da               ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �O n�mero de confirma��es alteradas.                           ���
���          �                                                              ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Gen�rico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PMS311Rec(cProject, cRev, cTask, cDate, nAFFDiff, lCanDel)
Local aAreaAFF   := AFF->(GetArea())
Local nAF9Quant  := 0   // quantidade da tarefa
Local nUpdConf   := 0   // n�mero de confirma��es recalculadas
Local nAFFNewQtd := .F. // indica se a qtd conf. � maior que a qtd tarefa

Default lCanDel  := .F. // indica se pode excluir a confirma��o exceder a faixa 0% - 100%

	dbSelectArea("AFF")
	AFF->(dbSetOrder(1))  //AFF_FILIAL + AFF_PROJET + AFF_REVISA + AFF_TAREFA + DTOS(AFF_DATA)

	// verifica se existe alguma confirma��o para a tarefa
	If AFF->(MsSeek(xFilial("AFF") + cProject + cRev + cTask))

		// so � poss�vel recalcular as confirma��es posteriores
		// pela quantidade se elas forem da mesma tarefa,
		// pois para uma mesma tarefa, alterando a quantidade, a
		// propor��o da porcentagem � a mesma.

		// recalcula as confirma��es posteriores ou iguais
		While AFF->AFF_FILIAL == xFilial("AFF") .And.;
		      AFF->AFF_PROJET == cProject .And.;
		      AFF->AFF_REVISA == cRev .And.;
		      AFF->AFF_TAREFA == cTask;

			If DToS(AFF->AFF_DATA) > cDate
				nAFFQuant  := AFF->AFF_QUANT
				nAF9Quant  := ReadValue("AF9", 1, xFilial("AF9") + cProject + cRev + cTask, "AF9_QUANT")
				nAFFNewQtd := 0

				// calcula a nova quantidade e verifica se o valor
				// � <= 0 ou >= a quantidade da tarefa (AF9_QUANT)
				If PMSNewQtd(nAF9Quant, nAFFQuant, nAFFDiff, @nAFFNewQtd) .And. lCanDel

					// estorna e exclui a confirmacao da tarefa, se a quantidade resultante
					// for <= 0 ou >= quantidade da tarefa (AF9_QUANT)
					PmsAvalAFF("AFF",2)
					PmsAvalAFF("AFF",3)

				Else
					PmsAvalAFF("AFF",2)
					// grava a nova quantidade da confirma��o
					Reclock("AFF", .F.)
					AFF->AFF_QUANT := nAFFNewQtd
					MsUnlock()
					PmsAvalAFF("AFF",1)

					nUpdConf++
				EndIf
			EndIf

			AFF->(dbSkip())
		End
	EndIf

	RestArea(aAreaAFF)
Return nUpdConf

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ReadValue� Autor � Adriano Ueda           � Data � 10/02/2005 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Fun��o para a leitura de um determinado campo, em um determi- ���
���          �nado alias.                                                   ���
���          �                                                              ���
���          �Utiliza a fun��o Posicione() para localizar e retornar        ���
���          �o campo. A diferen�a � que ela salva e restaura               ���
���          �o estado da base. Assim, o ponteiro n�o permanece posicionado ���
���          �no registro localizado, evitando algumas inconveni�ncias de   ���
���          �Posicione()                                                   ���
���������������������������������������������������������������������������Ĵ��
���Par�metros�cAlias - alias a ser utilizado para a procura                 ���
���          �nOrder - n�mero do �ndice a ser utilizado                     ���
���          �cKey   - chave a ser pesquisada                               ���
���          �cField - campo cujo valor ser� retornada                      ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �O conte�do do campo especificado por cField, localizado em    ���
���          �cAlias, utilizando o �ndice de ordem nOrder, atrav�s da chave ���
���          �de pesquisa cKey.                                             ���
���          �                                                              ���
���          �Retorna Nil se o registro n�o foi localizado ou se ocorreu    ���
���          �algum problema.                                               ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Gen�rico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function ReadValue(cAlias, nOrder, cKey, cField)
Local aArea   := (cAlias)->(GetArea())
Local uBuffer := Nil

	uBuffer := Posicione(cAlias, nOrder, cKey, cField)

	(cAlias)->(RestArea(aArea))
Return uBuffer

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PMSExistA� Autor � Adriano Ueda           � Data � 10/02/2005 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Fun��o que verifica se existe um confirma��o para a tarefa    ���
���          �informada a partir de uma determinada data.                   ���
���������������������������������������������������������������������������Ĵ��
���Par�metros�cProjet - c�digo do projeto a ser verificado                  ���
���          �cRevisa - vers�o do projeto a ser verificado                  ���
���          �cTarefa - tarefa a ser veriicada                              ���
���          �cData   - data a partir da qual ser� verificada               ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �Devolve .T., caso exista uma confirma��o com uma data >= cData���
���          �Devolve .F., caso contr�rio.                                  ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � PMSA311                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PMSExistAFF(cProjet, cRevisa, cTarefa, cData)
Local aAreaAFF := AFF->(GetArea())
Local lRetorno := .F.

	dbSelectArea("AFF")
	dbSetOrder(1)   //AFF_FILIAL + AFF_PROJET + AFF_REVISA + AFF_TAREFA + DTOS(AFF_DATA)

	AFF->(MsSeek(xFilial("AFF") + cProjet + cRevisa + cTarefa + cData, .T.))

	If !AFF->(Eof())
		If AFF->AFF_FILIAL == xFilial("AFF") .And. ;
		   AFF->AFF_PROJET == cProjet .And. ;
		   AFF->AFF_REVISA == cRevisa .And. ;
		   AFF->AFF_TAREFA == cTarefa .And. ;
		   DToS(AFF->AFF_DATA) >= cData
			lRetorno := .T.
		EndIf
	EndIf

	AFF->(RestArea(aAreaAFF))
Return lRetorno

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GetNewDif� Autor � Adriano Ueda           � Data � 10/02/2005 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Fun��o que recebe do usu�rio a quantidade a ser aplicada      ���
���          �nos apontamentos posteriores a uma data.                      ���
���          �                                                              ���
���          �Sugere nDiff como valor padr�o a ser aplicado                 ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Par�metros�nDiff - valor sugerido para o usu�rio                         ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �Retorna o valor a ser aplicado inserido pelo usu�rio ou se    ���
���          �a caixa de di�logo for cancelada, retorna o valor padr�o nDiff���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � PMSA311                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function GetNewDiff(nDiff,lAuto)
Local nNewDiff := nDiff
Local aParams := { 1,;
    	           STR0031,;  //"Quantidade:"
			       nDiff,;
			       "@E 9999.99",;
			       ,;
			       ,;
		  	       ,;
		    	   40,;
		      	   .T.}
Local aRet := {}

DEFAULT lAuto	:=	.F.

	If !lAuto .And. Parambox({aParams}, STR0027, aRet, , , .T.)
		nNewDiff := aRet[1]
	Else
		nNewDiff := nDiff
	EndIf
Return nNewDiff

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PMSNewQtd� Autor � Adriano Ueda           � Data � 10/02/2005 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Fun��o que calcula a nova quantidade da confirma��o da tarefa ���
���          �utilizando uma diferen�a.                                     ���
���������������������������������������������������������������������������Ĵ��
���Par�metros�nAF9Quant    - quantidade da tarefa                           ���
���          �nAFFQuant    - quantidade do apontamento da tarefa            ���
���          �nAFFDiff     - diferen�a a ser aplicada                       ���
���          �nAFFNewQuant - nova quantidade do apontamento da tarea        ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �Devolve o valor da nova quantidade do apontamento da tarefa   ���
���          �(nAFFNewQuant), cujo valor � nAFFQuant + nAFFDiff.            ���
���          �                                                              ���
���          �Devolve .T., se  0 < nAFFQuant + nAFFDiff <= nAF9Quant.       ���
���          �Devolve .F., caso contr�rio.                                  ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � PMSA311                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PMSNewQtd(nAF9Quant, nAFFQuant, nAFFDiff, nAFFNewQuant)
Local lOverflow := .F.

	// a soma quantidade + diferen�a deve esta limitada a
	// 0 < quantidade + diferen�a <= quantidade tarefa,
	// isto �, 0 < nQuant + Diff <= nAF9Quant
	If nAFFQuant + nAFFDiff <= 0
		nAFFQuant := 0
		lOverflow := .T.
	Else
		If nAFFQuant + nAFFDiff > nAF9Quant
			nAFFQuant := nAF9Quant

			lOverflow := .T.
		Else
			nAFFQuant += nAFFDiff
			lOverflow := .F.
		EndIf
	EndIf

	nAFFNewQuant := nAFFQuant
Return lOverflow

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �IsConclud� Autor � Adriano Ueda           � Data � 01/06/2005 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Fun��o que verifica se a tarefa informada j� foi conclu�da    ���
���          �(j� existe uma confirma��o de 100% para ela)                  ���
���������������������������������������������������������������������������Ĵ��
���Par�metros�cProject - c�digo do projeto                                  ���
���          �cRev     - vers�o do projeto                                  ���
���          �cTask    - tarefa a ser verificada                            ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �Devolve .T., caso exista uma confirma��o de 100% para a tarefa���
���          �Devolve .F., caso contr�rio.                                  ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � PMSA311                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function IsConcluded(cProject, cRev, cTask)
Local aAreaAFF := AFF->(GetArea())
Local lRetorno := .F.

	dbSelectArea("AFF")
	dbSetOrder(1)   //AFF_FILIAL + AFF_PROJET + AFF_REVISA + AFF_TAREFA + DTOS(AFF_DATA)

	AFF->(MsSeek(xFilial("AFF") + cProject + cRev + cTask))

	While !AFF->(Eof()) .And. AFF->AFF_FILIAL == xFilial("AFF") .And. ;
	                          AFF->AFF_PROJET == cProject .And. ;
	                          AFF->AFF_REVISA == cRev .And. ;
	                          AFF->AFF_TAREFA == cTask

		If AFF->AFF_QUANT >= ReadValue("AF9", 1, xFilial("AF9") + cProject + cRev + cTask, "AF9_QUANT")
			lRetorno := .T.
			Exit
		EndIf

		AFF->(dbSkip())
	EndDo

	AFF->(RestArea(aAreaAFF))
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A311AffTud�Autor  �Reynaldo Miyashita  � Data �  26.09.05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Faz chamada da rotina AFFTudoOk() que valida uma EDT para   ���
���          �seu valor ser 0 ou 100%concluida e sua data seja <> de Vazia���
�������������������������������������������������������������������������͹��
���Uso       � PMSA310                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A311AFFTudok(lInclui,lExclui,lAltera)
Return( AFFTudok(lInclui,lExclui,lAltera) )

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
	Local aRotina := {{STR0002, "AxPesqui",  0, 1, , .F.}, ; //"Pesquisar"
	                  {STR0003, "PMS311Dlg", 0, 2}, ; //"Visualizar"
	                  {STR0004, "PMS311Dlg", 0, 3}, ; //"Incluir"
	                  {STR0005, "PMS311Dlg", 0, 4}, ; //"Alterar"
	                  {STR0006, "PMS311Dlg", 0, 5}} //"Excluir"
Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PmsVlRelac�Autor  �Marcelo Akama       � Data �  11/08/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se pode realizar confirmacoes na tarefa de acordo  ���
���          �com as predecessoras                                        ���
�������������������������������������������������������������������������͹��
���Uso       � PMS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PmsVlRelac(cProjet, cRevisa, cTarefa, nPerc, lShowMsg)
Local aArea		:= GetArea()
Local aAreaAFD	:= {}
Local aAreaAJ4	:= {}
Local aAreaAFF	:= {}
Local aAreaAFQ	:= {}
Local lRet		:= .t.
Local nPercPred
Local lEncerra
Local cQuery := ""
Local cAliasTMP := ""
#IFDEF TOP
Local lSQL		:= Upper(TcSrvType()) != "AS/400" .and. Upper(TcSrvType()) != "ISERIES" .and. ! ("POSTGRES" $ Upper(TCGetDB()))
#ELSE
Local lSQL		:= .F.
#ENDIF

DEFAULT cProjet	:= M->AFF_PROJET
DEFAULT cRevisa	:= M->AFF_REVISA
DEFAULT cTarefa	:= M->AFF_TAREFA
DEFAULT nPerc   := M->AFF_PERC
DEFAULT lShowMsg:= .T.

lEncerra := nPerc >= 100

dbSelectArea("AFF")
aAreaAFF := AFF->(GetArea())
AFF->(dbSetOrder(1)) //AFF_FILIAL+AFF_PROJET+AFF_REVISA+AFF_TAREFA+DTOS(AFF_DATA)

dbSelectArea("AFQ")
aAreaAFQ := AFQ->(GetArea())
AFQ->(dbSetOrder(1)) //AFQ_FILIAL+AFQ_PROJET+AFQ_REVISA+AFQ_EDT+DTOS(AFQ_DATA)

dbSelectArea("AFD")
aAreaAFD := AFD->(GetArea())
AFD->(dbSetOrder(1)) //AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA+AFD_ITEM
If AFD->( MsSeek(xFilial("AFD")+cProjet+cRevisa+cTarefa) )
	While lRet .And. !AFD->(Eof()) .And. AFD->(AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA)==xFilial("AFD")+cProjet+cRevisa+cTarefa
		If AFD->AFD_TPVREL=="1"
			If lSQL
				// horas ja apontadas no AFU em formato decimal
				cQuery := "SELECT R_E_C_N_O_ "
				cQuery += " FROM "+RetSqlName("AFF") + " AFF "
				cQuery += " WHERE AFF_FILIAL = '"+xFilial("AFF")+"'  "
				cQuery += " and AFF_PROJET = '"+AFD->AFD_PROJET+"' "
				cQuery += " and AFF_REVISA = '"+AFD->AFD_REVISA+"' "
				cQuery += " and AFF_TAREFA = '"+AFD->AFD_PREDEC+"' "
				cQuery += " and D_E_L_E_T_ = ' ' "
				cQuery += " ORDER BY AFF_DATA DESC "
				cQuery := ChangeQuery(cQuery)
				cAliasTMP := GetNextAlias()

				DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTMP,.F.,.T.)

				nPercPred := 0
				If (cAliasTMP)->(!Eof())
					If ! Empty((cAliasTMP)->R_E_C_N_O_)
						AFF->(dbGoto((cAliasTMP)->R_E_C_N_O_))
						nPercPred := PMS310QT(.F.,"AFF")
					EndIf
				EndIf
				(cAliasTMP)->(dbCloseArea())
			Else
				If AFF->( MsSeek(xFilial("AFF")+AFD->(AFD_PROJET+AFD_REVISA+AFD_PREDEC)) )
					Do While lRet .And. !AFF->(Eof()) .And. AFF->(AFF_FILIAL+AFF_PROJET+AFF_REVISA+AFF_TAREFA)==xFilial("AFF")+AFD->(AFD_PROJET+AFD_REVISA+AFD_PREDEC)
						AFF->(dbSkip())
					EndDo
					AFF->(dbSkip(-1))
					nPercPred := PMS310QT(.F.,"AFF")
				Else
					nPercPred := 0
				EndIf
			EndIf

			If nPercPred >=0 .And. !PmsVlRelac(AFD->AFD_PROJET, AFD->AFD_REVISA, AFD->AFD_PREDEC, nPerc, lShowMsg)
				nPercPred := 99
			EndIf
			If !IsInCallStack("PMSLSTREJ")
				Do Case
					Case AFD->AFD_TIPO=="1" // Fim no Inicio
						If nPercPred < 100
							If lShowMsg
								HELP("   ",1,"PMSA311TSK_FS")
							EndIF
							lRet := .F.
						EndIf
					Case AFD->AFD_TIPO=="2" // Inicio no Inicio
						If nPercPred <= 0
							If lShowMsg
								HELP("   ",1,"PMSA311TSK_SS")
							EndIf
							lRet := .F.
						EndIf
					Case AFD->AFD_TIPO=="3" // Fim no Fim
						If lEncerra .And. nPercPred < 100
							If lShowMsg
								HELP("   ",1,"PMSA311TSK_FF")
							EndIf
							lRet := .F.
						EndIf
					Case AFD->AFD_TIPO=="4" // Inicio no Fim
						If lEncerra .And. nPercPred <= 0
							If lShowMsg
								HELP("   ",1,"PMSA311TSK_SF")
							EndIf
							lRet := .F.
						EndIf
				EndCase
			EndIf
		EndIf
		AFD->(dbSkip())
	EndDo
EndIf

dbSelectArea("AJ4")
aAreaAJ4 := AJ4->(GetArea())
AJ4->(dbSetOrder(1)) //AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_TAREFA+AJ4_ITEM
If AJ4->( MsSeek(xFilial("AJ4")+cProjet+cRevisa+cTarefa) )
	Do While lRet .And. !AJ4->(Eof()) .And. AJ4->(AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_TAREFA)==xFilial("AJ4")+cProjet+cRevisa+cTarefa
		If AJ4->AJ4_TPVREL="1"
			If lSQL
				// horas ja apontadas no AFU em formato decimal
				cQuery := "SELECT R_E_C_N_O_ "
				cQuery += " FROM "+RetSqlName("AFQ") + " AFQ "
				cQuery += " WHERE AFQ_FILIAL = '"+xFilial("AFQ")+"'  "
				cQuery += " and AFQ_PROJET = '"+AJ4->AJ4_PROJET+"' "
				cQuery += " and AFQ_REVISA = '"+AJ4->AJ4_REVISA+"' "
				cQuery += " and AFQ_EDT = '"+AJ4->AJ4_PREDEC+"' "
				cQuery += " and D_E_L_E_T_ = ' ' "
				cQuery += " ORDER BY AFQ_DATA DESC "
				cQuery := ChangeQuery(cQuery)
				cAliasTMP := GetNextAlias()

				DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTMP,.F.,.T.)

				nPercPred := 0
				If (cAliasTMP)->(!Eof())
					If ! Empty((cAliasTMP)->R_E_C_N_O_)
						AFQ->(dbGoto((cAliasTMP)->R_E_C_N_O_))
						nPercPred := PMS310QT(.F.,"AFF")
					EndIf
				EndIf
				(cAliasTMP)->(dbCloseArea())
			Else
				If AFQ->( MsSeek(xFilial("AFQ")+AJ4->(AJ4_PROJET+AJ4_REVISA+AJ4_PREDEC)) )
					Do While lRet .And. !AFQ->(Eof()) .And. AFQ->(AFQ_FILIAL+AFQ_PROJET+AFQ_REVISA+AFQ_EDT)==xFilial("AFQ")+AJ4->(AJ4_PROJET+AJ4_REVISA+AJ4_PREDEC)
						AFQ->(dbSkip())
					EndDo
					AFQ->(dbSkip(-1))
					nPercPred := PMS310QT(.F.,"AFQ")
				Else
					nPercPred := 0
				EndIf
			EndIf
			If nPercPred >=0 .And. !PmsVlRelac(AJ4->AJ4_PROJET, AJ4->AJ4_REVISA, AJ4->AJ4_PREDEC, nPerc, lShowMsg)
				nPercPred := 99
			EndIf
			Do Case
				Case AJ4->AJ4_TIPO=="1" // Fim no Inicio
					If nPercPred < 100
						If lShowMsg
							HELP("   ",1,"PMSA311WBS_FS")
						EndIf
						lRet := .F.
					EndIf
				Case AJ4->AJ4_TIPO=="2" // Inicio no Inicio
					If nPercPred <= 0
						If lShowMsg
							HELP("   ",1,"PMSA311WBS_SS")
						EndIf
						lRet := .F.
					EndIf
				Case AJ4->AJ4_TIPO=="3" // Fim no Fim
					If lEncerra .And. nPercPred < 100
						If lShowMsg
							HELP("   ",1,"PMSA311WBS_FF")
						EndIf
						lRet := .F.
					EndIf
				Case AJ4->AJ4_TIPO=="4" // Inicio no Fim
					If lEncerra .And. nPercPred <= 0
						If lShowMsg
							HELP("   ",1,"PMSA311WBS_SF")
						EndIf
						lRet := .F.
					EndIf
			EndCase
		EndIf
		AJ4->(dbSkip())
	EndDo
EndIf

If ExistBlock("PMA311VR")
	lRet := ExecBlock("PMA311VR",.F.,.F.,{cProjet, cRevisa, cTarefa, nPerc})
EndIf

RestArea(aAreaAFD)
RestArea(aAreaAJ4)
RestArea(aAreaAFF)
RestArea(aAreaAFQ)
RestArea(aArea)

Return lRet


/*����������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �PMA311Anex� Autor � Aldo Barbosa dos Santos      �21/05/2012 ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Inclusao de anexo para cada motivo de rejeicao					���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       �Materiais                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function PMA311Anexo(cAlias, aHeaderANA, aColsANA, aMotivos)
Local aAreaAnt	:= GetArea()
Local lRet 		:= .T.
Local aAlter	:= {"ARQANX",aHeaderANA[2,2]}
Local cGetOpc	:= GD_DELETE+GD_UPDATE
Local nA
Local oDlgAnx

Private aHeaderANX:= aClone(aHeaderANA)
Private aColsANX := {}
Private oGDAnexo

// permite que o campo motivo, seja somente consulta
aHeaderANX[02,14] := "V"

// inclui a coluna de marcacao do anexo
Aadd(aHeaderANX,{})
aIns(aHeaderANX,1)
aHeaderANX[1] := aClone(aHeaderANA[2])
aHeaderANX[1,01] := "Anexo"
aHeaderANX[1,02] := "ARQANX"
aHeaderANX[1,03] := "@BMP"
aHeaderANX[1,04] := 3
aHeaderANX[1,05] := 0
aHeaderANX[1,06] := ""
aHeaderANX[1,08] := "C" 			// tipo
aHeaderANX[1,17] :=.F.					 // nao obrigatorio

// inclui a coluna de recno
Aadd(aHeaderANX,{})
aHeaderANX[Len(aHeaderANX)] := aClone(aHeaderANA[2])
aHeaderANX[Len(aHeaderANX),01] := "REC_WT"
aHeaderANX[Len(aHeaderANX),02] := "REC_WT"
aHeaderANX[Len(aHeaderANX),03] := "99999999"
aHeaderANX[Len(aHeaderANX),04] := 8
aHeaderANX[Len(aHeaderANX),05] := 0
aHeaderANX[Len(aHeaderANX),06] := ""
aHeaderANX[Len(aHeaderANX),08] := "N" 			// tipo
aHeaderANX[Len(aHeaderANX),17] :=.F.			// nao obrigatorio

// cria o novo acols com numero de registro e anexo
For nA := 1 to Len(aMotivos)
	Aadd(aColsANX,{ " ", aMotivos[nA,1], aMotivos[nA,2], aMotivos[nA,3], .F. })
Next

aVetDiag := {0, 0, 360,700}
DEFINE MSDIALOG oDlgAnx TITLE STR0047 + " " + AF9->AF9_TAREFA FROM aVetDiag[1], aVetDiag[2] TO aVetDiag[3],aVetDiag[4] PIXEL STYLE nOR( DS_MODALFRAME, WS_POPUP, , WS_VISIBLE ) //"Tarefa"

@  10,   05 SAY oSay2 PROMPT STR0053 SIZE 115, 7 OF oDlgAnx PIXEL //"Inclusao de Anexos"

aVetGet := {020, 005, 145,348}
oGDAnexo:= MsNewGetDados():New( aVetGet[1],aVetGet[2],aVetGet[3],aVetGet[4], cGetOpc,/*PMA311LOK*/,/*PMA311TOK*/,/*+ANC_ITEM*/,aAlter,,/*100*/,/*PMA311FOK*/,,/*PMA311DEL*/,oDlgAnx,aHeaderANX,aColsANX )
oGDAnexo:AddAction( "ARQANX", {|| PMA311Anx(oGdAnexo, cAlias) } )  // Projeto TDI - TELXEZ - Anexo na rejeicao

aVetBtn := {158,287}
@ aVetBtn[1], aVetBtn[2] BUTTON oBtn1 PROMPT STR0049 SIZE 37, 12 ACTION ( lRet := PMA311Chk(1),if(lRet,oDlgAnx:End(),Nil)) OF oDlgAnx PIXEL //"Ok"
ACTIVATE MSDIALOG oDlgAnx CENTERED

RestArea(aAreaAnt)

Return( lRet )



/*����������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �PMA311Chk � Autor � Aldo Barbosa dos Santos      �31/05/2012 ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Verifica se o processo de rejeicao pode continuar				���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       �Materiais                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function PMA311Chk(nModo)
Local lRet	:= .T.

Default nModo	:= 1

Return( lRet )


/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �PMA311Anx   �Autor�Aldo Barbosa dos Santos� Data �  25/05/12   ���
����������������������������������������������������������������������������͹��
���Desc.     �Permite a exibicao do anexo                                    ���
���          �                                                               ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function PMA311Anx(oGdAnexo, cEntidade)

Local aArea		:= { (cEntidade)->( GetArea()), SX2->( GetArea()), GetArea() }
Local nPosRec	:= aScan( aHeaderANX, { |x| x[2] == "REC_WT" } )
Local nOpc		:= 1 // O valor deve ser sempre 1 devido a funcao MSDOCUMENT
Local cTipo		:= "ET" // "T"
Local lGravou	:= .T.
Local aRecAC9	:= {}
Local lRet		:= .F.
Local nPos		:= n
Local cUnico	:= ""
Local cCodEnt	:= ""
Local nA		:= 0

SaveInter()
// posiciona no registro que esta sendo editado
DbselectArea( cEntidade )
(cEntidade)->( DbGoTo(oGdAnexo:aCols[n,nPosRec]))

// localiza a chave do registro que esta sendo incluido o anexo
cUnico   := FWX2Unico(cEntidade)
cCodEnt  := (cEntidade)->( &cUnico )
cCodEnt  := PadR( cCodEnt, TamSX3("AC9_CODENT")[1] )

If Type("aRotina") <> "A"
	aRotina 	:= {	{ STR0057, "AxPesqui"  , 0 , 1,,.F.},	{ STR0058, "AxVisual"  , 0 , 2} }	//"Pesquisa"##"Visualiza"
Endif
n			:= 1  	// necessario pois na funcao MsDocument a variavel n nao e zerada e da erro se n > 1
lRet		:= MsDocument(cEntidade, oGdAnexo:aCols[n,nPosRec], nOpc, cTipo)
//lGravou	:= MsDocGrv( cAlias, cCodEnt, aRecAC9, .T. )
n			:= nPos	// retorna o valor anterior

// e necessario verificar se o anexo foi gravado mesmo lRet sendo .T. pois o usuario pode ter
// dado Ok mas ter excluido todos os anexos.
lRet		:= PmsMonAnexo(xFilial("AC9"),cEntidade,xFilial(cEntidade),cCodent)

RestInter()

For nA := 1 to Len(aArea)
	RestArea(aArea[nA])
Next nA
FreeObj(aArea)
Return( if(lRet,"clips_pq"," ") )

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informa��es enviadas, 
    quando a regra de auditoria de rotinas com campos sens�veis ou pessoais estiver habilitada
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que ser� utilizada no log das tabelas
    @param nOpc, Numerico, Op��o atribu�da a fun��o em execu��o - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria n�o esteja aplicada, tamb�m retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun��o que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
