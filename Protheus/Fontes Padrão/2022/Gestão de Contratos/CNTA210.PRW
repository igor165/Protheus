#INCLUDE "PROTHEUS.CH"
#INCLUDE "CNTA210.ch"        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CNTA210  � Autor � Marcelo Custodio      � Data �29.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Amarracao Tipo de Contrato X Tipo de Documento X Situacao  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CNTA210()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CNTA210(nPosArotina,lAutomato)
Private cCadastro := STR0001 //Cadastro de Cau��es

PRIVATE aRotina := MenuDef()

DEFAULT nPosArotina := 0
DEFAULT lAutomato   := .F.

dbSelectArea("CNJ")
dbSetOrder(1)

If	nPosArotina > 0
	bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e) }" )
	Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina,lAutomato)
Else
	mBrowse(6,1,22,75,"CNJ")
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �CN210Manut� Autor � Marcelo Custodio      � Data �29.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � gerencia a edicao/inclusao/alteracao da tabela CNJ         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN210Manut()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CN210Manut(cAlias,nReg,nOpc,lAutomato)
Local aSize := MsAdvSize()
Local aObjects := {}
Local aNoFields:= {"CNJ_SITUAC","CNJ_TPCTO","CNJ_DESCTC"}//Colunas exibidas na enchoice 
Local aCpoEnch := {}//Colunas exibidas na enchoice
Local aPosObj  := {}
Local aInfo    := {}
Local cSeek    := ""
Local cWhile   := ""
Local cCampo	:= ""
Local oDlg

PRIVATE aTela := {}
PRIVATE aGets := {}

PRIVATE oGetd
Private aHeader := {}
Private aCols   := {}

DEFAULT lAutomato := .F. 

Aadd(aObjects, { 100,  50, .T., .T. } )
Aadd(aObjects, { 100, 140, .T., .T. } )

aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
aPosObj := MsObjSize(aInfo, aObjects,.T.)

CNJ->(dbGoTo(nReg))
dbSelectArea("SX3")
MsSeek("CNJ")

//������������������������������������������������������Ŀ
//� Verifica campos da CNJ  - Monta Enchoice             �
//��������������������������������������������������������
While !Eof() .And. SX3->X3_ARQUIVO == "CNJ"
	cCampo := SX3->X3_CAMPO
	If X3Uso(X3_USADO) .And. cNivel >= GetSx3Cache(cCampo,'X3_NIVEL')
		If Ascan(aNoFields,AllTrim(cCampo)) > 0 .Or. GetSx3Cache(cCampo,'X3_PROPRI') == "U" //Verifica se o campo vai para a enchoice ou getdados
			aAdd(aCpoEnch,cCampo)//Adiciona campo na enchoice
			If	( GetSx3Cache(cCampo,'X3_CONTEXT') == "V" .Or. aRotina[nOpc,4] == 3 )
				M->&(cCampo) := CriaVar(cCampo)
			Else
				M->&(cCampo) := CNJ->(FieldGet(FieldPos(cCampo)))
			EndIf
		EndIf
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo

If aRotina[nOpc,4] != 3
	dbSelectArea("CNJ")
	dbGoTo(nReg)
	
   cSeek	 := xFilial("CNJ")+CNJ->CNJ_SITUAC+CNJ->CNJ_TPCTO
   cWhile := "CNJ_FILIAL+CNJ_SITUAC+CNJ_TPCTO" 
	FillGetDados(nOPc,"CNJ",1,cSeek,{|| &cWhile },{|| .T. },aNoFields,,,,,,aHeader,aCols)				
Else
	FillGetDados(nOpc,"CNJ",1,,,,aNoFields,,,,,.T.,aHeader,aCols)
EndIf

//-- lAutomato, recurso exclusivo para teste da automa��o disparado pelo CNTA060TestCase
If	lAutomato
	If nOpc == 5
		CN210Grv({},{},{},nOpc,nReg)
	ElseIf FindFunction("GetParAuto")
		aRetAuto := GetParAuto("CNTA210TESTCASE")
		If	EnchAuto("CNJ",aRetAuto[1],,,aCpoEnch) .And. MsGetDAuto( aRetAuto[2],  {|| CN210LinOK(lAutomato) }, {|| CN210CabOk(aCpoEnch,oDlg,nReg,nOpc,lAutomato) .And. CN210VldTd(lAutomato) } , aRetAuto[1],nOpc)
			CN210Grv(aCols,aHeader,aCpoEnch,nOpc,nReg)
		EndIf	 	
	EndIf
Else			
	//�����������������������������Ŀ
	//� Monta dialog                �
	//�������������������������������
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
	//������������������������������������������������������Ŀ
	//� Configura Enchoice                                   �
	//��������������������������������������������������������
	EnChoice( cAlias, nReg, nOpc,,,,aCpoEnch, aPosObj[1], , , , , , , , .T.)
	//������������������������������������������������������Ŀ
	//� Configura getdados                                   �
	//��������������������������������������������������������
	oGetd	:=MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],IIF(aRotina[nOpc,4]!=3 .And. aRotina[nOpc,4]!=4,0,GD_INSERT+GD_UPDATE+GD_DELETE),"CN210LinOK()",,,,,,,,,oDlg,aHeader,aCols)
	oGetd:oBrowse:bGotFocus	:= {||CN210CabOk(aCpoEnch,oDlg,nReg,nOpc) }
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela) .And. CN210CabOk(aCpoEnch,oDlg,nReg,nOpc) .And. CN210VldTd() .And. CN210LinOK(),(CN210Grv(oGetd:aCols,oGetd:aHeader,aCpoEnch,nOpc,nReg),oDlg:End()),)},{||(oDlg:End())})
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �CN210Grv  � Autor � Marcelo Custodio      � Data �29.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Executa grava��o dos itens da amarracao                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN210Grv(aExp01,aExp02,aExp03,nExp04,nExp05)               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aExp01 - Linhas da getdados                                ���
���          � aExp02 - Cabecalho da getdados                             ���
���          � aExp03 - Itens exibidos na Enchoice                        ���
���          � nExp04 - Opcao selecionada pelo usuario                    ���
���          � aExp05 - Registro atual da tabela                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CN210Grv(aCols,aHeader,aCpoEnch,nOpc,nReg)
Local nx
Local nUsado := len(aHeader)
Local nCpo                  
Local cFilCod := xFilial("CNJ")
Local nPosTDc := aScan(aHeader,{|x| AllTrim(x[2]) == "CNJ_TPDOC"})
Local cSituac := ""
Local cTpCto  := ""

dbSelectArea("CNJ")
dbSetOrder(1)

dbGoTo(nReg)
cSituac := CNJ->CNJ_SITUAC
cTpCto  := CNJ->CNJ_TPCTO

Do Case
	Case aRotina[nOpc,4] == 3//Inclusao
		//������������������������������������������������������Ŀ
		//� Replica cabecalho para todos os registros            �
		//��������������������������������������������������������
		For nx:= 1 to len(aCols)
			If !aCols[nx,nUsado+1]
				RecLock("CNJ",.T.)
				For nCpo:=1 to len(aCpoEnch)//Preenche campos da enchoice
					If aCpoEnch[nCpo] == "CNJ_SITUAC"
					CNJ->&(aCpoEnch[nCpo]) := PadL(M->&(aCpoEnch[nCpo]),2,"0")
					Else
					CNJ->&(aCpoEnch[nCpo]) := M->&(aCpoEnch[nCpo])
					EndIF
				Next
				For nCpo:=1 to len(aHeader)//Preenche campos da getdados
					CNJ->&(aHeader[nCpo,2]) := aCols[nx,nCpo]
				Next
				CNJ->CNJ_FILIAL := cFilCod
				MsUnlock()
			EndIf
		Next
	Case aRotina[nOpc,4] == 4//Alteracao
		dbGoto(nReg)
		//-- Exclui itens
		CNJ->(DbSetOrder(1))		
		For nx:= 1 to len(aCols)
			If CNJ->(MsSeek(cFilCod+cSituac+cTpCto))
				RecLock("CNJ",.F.)
				dbDelete()
				MsUnlock()
			EndIF
		Next nx
		dbGoto(nReg)
		For nx:= 1 to len(aCols)
			If !aCols[nx,nUsado+1]
				If CNJ->(MsSeek(cFilCod+cSituac+cTpCto+aCols[nX,nPosTDc]))
					RecLock("CNJ",.F.)//Edita registro
				Else
					RecLock("CNJ",.T.)//Cria registro
					CNJ->CNJ_FILIAL := cFilCod
				EndIF
				For nCpo:=1 to len(aCpoEnch)//Preenche campos da enchoice
					CNJ->&(aCpoEnch[nCpo]) := M->&(aCpoEnch[nCpo])
				Next
				For nCpo:=1 to len(aHeader)//Preenche campos da getdados
					CNJ->&(aHeader[nCpo,2]) := aCols[nx,nCpo]
				Next
				MsUnlock()
			EndIf
		Next		
	Case aRotina[nOpc,4] == 5//Exclusao
		//������������������������������������������������������Ŀ
		//� Exclui todos os registros da configuracao            �
		//��������������������������������������������������������
		dbSeek(cFilCod+M->CNJ_SITUAC+M->CNJ_TPCTO)
		While !Eof() .And. CNJ->CNJ_FILIAL == cFilCod .And. CNJ->CNJ_SITUAC == M->CNJ_SITUAC .And. CNJ->CNJ_TPCTO == M->CNJ_TPCTO
			RecLock("CNJ",.F.)
			dbDelete()
			MsUnlock()
			CNJ->(dbSkip())
		EndDo
EndCase
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �CN210VldTd� Autor � Marcelo Custodio      � Data �29.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Valida amarracao SituacaoXTipo de ContratoXTipo de Docs.   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN210VldTd()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CN210VldTd(lAutomato)
Local lRet := .T.
Local nPosTd:= 0
DEFAULT lAutomato := .F.

If	!lAutomato
	aHeader := AClone(oGetd:aHeader)
	aCols	:= AClone(oGetd:aCols)
EndIf

nPosTd:= aScan(aHeader,{|x| AllTrim(x[2])=="CNJ_TPDOC"})

if len(aCols) == 1 .And. (Empty(aCols[1,nPosTd]) .OR. aCols[1,len(aHeader)+1])
	Aviso("CNTA210",OemToAnsi(STR0008),{"OK"})
	lRet:=.F.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �CN210CabOk� Autor � Marcelo Custodio      � Data �29.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Valida cabecalho da amarracao                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN210CabOk(aExp01,oExp02,nExp03,nExp04)                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aExp01 - Itens exibidos na enchoice                        ���
���          � oExp02 - Dialog                                            ���
���          � nExp03 - Registro atual                                    ���
���          � nExp04 - Opcao selecionada pelo usuario                    ���
���          � lExp05 - Execu��o pelo robo de testes                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CN210CabOk(aCpoEnch,oDlg,nReg,nOpc,lAutomato)
Local lRet 	  	 := .T.
Local lAuxRet1 	 := .T.
Local lAlcDocCtr := .F.
Local n			 := 0
Local cSitOrg	 := ""
Local cTpcOrg	 := ""

DEFAULT lAutomato:=.F.

If(aRotina[nOpc,4] == 5)//Exclusao
	lRet := .T.
Else
	dbSelectArea("CNJ")
	dbSetOrder(1)
	
	If dbSeek(xFilial("CNJ")+M->CNJ_SITUAC+M->CNJ_TPCTO)
		If(aRotina[nOpc,4] == 3)//Inclusao
			lRet := .F.//Nao permite duplicacao
		Else
			//������������������������������������������������������Ŀ
			//� Armazena situacao e tipo de contrato alterados para  �
			//� comparacao com o original, pois em caso de alteracao �
			//� deve ser verificado se o registro encontrado nao se  �
			//� trata do mesmo em edicao                             �
			//��������������������������������������������������������
			cSitOrg := M->CNJ_SITUAC
			cTpcOrg := M->CNJ_TPCTO
			dbGoTo(nReg)
			If cSitOrg != CNJ->CNJ_SITUAC .OR. cTpcOrg != CNJ->CNJ_TPCTO
				lRet := .F.
			EndIf
		EndIf
	Else
		//Verifica se o contrato possui controle de al�ada para bloquear a amarra��o com a situa��o VIGENTE
		DbSelectArea("CN1")
		CN1->(DbSetOrder(1))
		If CN1->(DbSeek(xFilial("CN1")+M->(CNJ_TPCTO)))
			lAlcDocCtr := ( CN1->CN1_ALCCTR $ "0|1" )
			
			If lAlcDocCtr .AND. M->(CNJ_SITUAC) == "05"
				lRet 	 := .F.
				lAuxRet1 := .F.
			EndIf
		EndIf
	EndIf
	
	If !lRet
	
		If !lAuxRet1
			Aviso("CNTA210",OemToAnsi(STR0010)+CRLF+OemToAnsi(STR0011),{"OK"})	//"Este tipo de contrato possui controle de aprova��o por al�ada." ##
																				//"Nesse caso n�o � permitida a amarra��o de documentos com a situa��o VIGENTE."
		Else
			Aviso("CNTA210",OemToAnsi(STR0007),{"OK"}) //"A configura��o informada j� se encontrada registrada no sistema."
		EndIf
		If !lAutomato
			n := ascan(oDlg:acontrols,{|x| x:CREADVAR = "M->CNJ_SITUAC"})//Encontra posicao do controle referente a situacao
			if(n > 0)
				oDlg:acontrols[n]:SetFocus()//Move o foco para a situacao
			EndIF
		EndIf
	EndIF
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �CN210LinOk� Autor � Marcelo Custodio      � Data �29.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Valida linha da getdados                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN210linOk()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CN210LinOK(lAutomato)  
Local nPosTD  := 0
Local lRet    := .T.
Local nUsado  := 0
Local nA      := 1
Local nI      := 0
Local lRepetido := .F.
Local lExist	:= .F.

DEFAULT lAutomato := .F.

If	!lAutomato
	aHeader := AClone(oGetd:aHeader)
	aCols   := AClone(oGetd:aCols)
	nA      := oGetd:nAt
EndIf
nPosTD := aScan(aHeader,{|x| AllTrim(x[2]) == "CNJ_TPDOC"})
nUsado := len(aHeader)+1

//Altera��o feita para automatiza��o do robo
//Verifica��o do conteudo informado para n�o permitir a grava��o de codigo inexistente
If lAutomato
	For nI := 1 to Len(aCols)
		If !Empty(aCols[nI,nPosTD])
			lExist := ExistCpo("CN5",aCols[nI,nPosTD])		
			If !lExist
				Help(" ",1,"REGNOIS")
				lRet := .F.			
			EndIf					
		EndIf
	Next nI
EndIf

//�������������������������������������������������������Ŀ
//� Verifica se existe outro item com a mesma configuracao�
//���������������������������������������������������������
if !Empty(aCols[nA,nPosTD])
	If Len( aCols ) > 1 .And. !aCols[nA][nUsado]
		
		For nI:= 1 To Len( aCols )
			If ( nI != nA ) .and. !aCols[nI][nUsado]
				If aCols[nI,nPosTD] == aCols[nA,nPosTD]
					lRepetido := .T.
					Exit
				Endif
			Endif
		Next nI
		
		If lRepetido
			lRet:=.F.
			Help(" ",1,"JAGRAVADO")
		End
	Endif
Else
	Aviso("CNTA210",OemToAnsi(STR0009),{"OK"})//"Preencha o tipo do documento"
	lRet := .F.
EndIf

Return lRet  

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Fabio Alves Silva     � Data �19/10/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
PRIVATE aRotina	:= 	{ 	{ STR0002, "AxPesqui"  	, 0, 1, 0, .F.},;//"Pesquisar"
						{ STR0003, "CN210Manut"	, 0, 2, 0, nil},;//"Visualizar"
						{ STR0004, "CN210Manut" , 0, 3, 0, nil},;//"Incluir"
						{ STR0005, "CN210Manut"	, 0, 4, 0, nil},;//"Alterar"
						{ STR0006, "CN210Manut"	, 0, 5, 0, nil} }//"Excluir"	

//������������������������������������������������������������������������Ŀ
//� Ponto de entrada utilizado para inserir novas opcoes no array aRotina  �
//��������������������������������������������������������������������������
If ExistBlock("CTA210MNU")
	ExecBlock("CTA210MNU",.F.,.F.)
EndIf
Return(aRotina) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �CN210TpDoc� Autor � Antenor Silva         � Data �21.03.2017���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Valida tipo de documentos                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN210TpDoc()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CN210TpDoc()
Local cValor  := &(ReadVar())
Local nPosTD  := 0
Local lRet    := .T.
Local nUsado  := 0
Local nA      := 1
Local nI      := 0

nPosTD := aScan(aHeader,{|x| AllTrim(x[2]) == "CNJ_TPDOC"})
nUsado := len(aHeader)+1

If !Empty(aCols[nA,nPosTD])
	If Len( aCols ) > 1 .And. !aCols[nA][nUsado]		
		For nI:= 1 To Len( aCols )
			If ( nI != nA ) .and. !aCols[nI][nUsado]
				If cValor == aCols[nI,nPosTD]
					lRet:=.F.
					Help(" ",1,"JAGRAVADO")
					Exit
				EndIf
			EndIf
		Next nI
	EndIf
EndIf

Return lRet