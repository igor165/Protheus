
#INCLUDE "QIEA060.CH"
#include "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEA060  � Autor � Cleber Souza          � Data � 05/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Grupo de Produtos               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao   				  ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*///
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001)  ,"AxPesqui"  , 0 , 1,,.F.},;     //"Pesquisa" 
                     {OemToAnsi(STR0002)  ,"QE060GPr"  , 0 , 2},;     //"Visualiza"
                     {OemToAnsi(STR0003)  ,"QE060GPr"  , 0 , 3},;     //"Incluir" 
                     {OemToAnsi(STR0004)  ,"QE060GPr"  , 0 , 4},;     //"Alterar" 
                     {OemToAnsi(STR0005)  ,"QE060GPr"  , 0 , 5 , 3} } //"Excluir"  

Return aRotina

Function QIEA060(xAutoCab,xAutoItens,nOpcAuto)

PRIVATE l060Auto   := xAutoCab <> NIL  .And. xAutoItens <> NIL
PRIVATE aAutoCab   := {}
PRIVATE aAutoItens := {}

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0006)  //"Grupos de Produtos" 

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

DEFAULT nOpcAuto := 3

//�������������������������������������������Ŀ
//�Tratamento de Rotina Automatica            �
//���������������������������������������������
If  ( Type("l060Auto") <> "U" .And. l060Auto )
	aAutoCab   := xAutoCab
	aAutoItens := xAutoItens
	MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"QE3")
	xAutoCab   := aAutoCab
	xAutoItens := aAutoItens	
Else
	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	mBrowse( 6, 1,22,75,"QE3")
EndIf

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A060GPr  � Autor � Cleber Souza          � Data � 05/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastra Produtos dos Grupos                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A060GPr(ExpC1,ExpN1,ExpN2)                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada no menu                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/ 

Function QE060GPr(cAlias,nReg,nOpc)                 

Local nOpcA     := 0
Local nX        := 0
Local nY        := 0
Local oSize
Local aStruAlias := FWFormStruct(3, "QE3")[3]

Private oGet,oEncQE3  
Private aCpoQE3  := {{},{}} 
Private nPosPro  := 0
Private nPosDPr  := 0      
Private aCols   := {}
Private aHeader := {}

//��������������������������������������������������������������Ŀ
//� Cria o vetor com os campos a serem utilizados na Enchoice  �
//����������������������������������������������������������������
For nX := 1 To Len(aStruAlias)
	If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL")
		Aadd(aCpoQE3[1],aStruAlias[nX,1])
		Aadd(aCpoQE3[2],GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT"))
	EndIf
Next nX

//��������������������������������������������������������������Ŀ
//� Cria as variaveis para edicao na Enchoice     		        �
//����������������������������������������������������������������
RegToMemory(cAlias,If(nOpc==3,.T.,.F.),.F.)  


/* Documenta��o dos parametros do Metodo FillGetDados
FillGetDados  (nOpc,; 			// numero correspondente � opera��o a ser executada, exemplo: 3 - inclus�o, 4 altera��o e etc;
               Alias,       	// area a ser utilizada;
               nOrdem,      	// ordem correspondente a chave de �ndice para preencher o  acols;
               cSeek,       	// chave utilizada no posicionamento da �rea para preencher o acols; 
               bSeekWhile,  	// bloco contendo a express�o a ser comparada com cSeekKey na condi��o  do While. 
               uSeekFor,    	// pode ser utilizados de duas maneiras:
							 	   1 - bloco-de-codigo, condicao a ser utilizado para executar o Loop no While;
							 	   2 - array bi-dimensional contendo N condicoes, em que o 1 elemento o bloco condicional, o 2 bloco a ser executado se verdadeiro e o 3 e bloco a ser executado se falso:
							 	   Exemplo:
							 	   {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
               aNoFields,   	// array contendo os campos que n�o estar�o no aHeader;
               aYesFields,  	// array contendo somente os campos que estar�o no aHeader;
               lOnlyYes,    	// se verdadeiro, exibe apenas os campos de usu�rio;
               cQuery,      	// query a ser executada para preencher o acols;
               bMontCols,    	// bloco contendo funcao especifica para preencher o aCols; 
               lEmpty,       	// 
               aHeaderAux,   	// 
               aColsAux,     	// 
               bAfterCols,   	// 
               bBeforeCols,  	// 
               bAfterHeader,    // 
               cAliasQry)       // 
*/

cWhile  := Alltrim(RetSIX("QEA","1",.T.,{"QEA_PRODUT"}))
cSeek 	:= RetSIX("QE3","1",.T.)

FillGetDados(	nOpc,; 							// numero correspondente � opera��o a ser executada, exemplo: 3 - inclus�o, 4 altera��o e etc;
               	"QEA",;       					// area a ser utilizada;
               	1,;      						// nOrdem - ordem correspondente a chave de �ndice para preencher o  acols;
               	Iif((nOpc == 3),"",&cSeek),;  	// chave utilizada no posicionamento da �rea para preencher o acols; 
               	{|| &cWhile},; 					// bloco contendo a express�o a ser comparada com cSeekKey na condi��o  do While. 
               	{|| .T.},;  					// uSeekFor
               	,;  						 	// aNoFields - array contendo os campos que n�o estarao no aHeader;
               	,;  							// aYesFields - array contendo somente os campos que estarao no aHeader;
               	.F.,;      						// se verdadeiro, exibe apenas os campos de usu�rio;
                '',;      						// cQuery - query a ser executada para preencher o acols;
               	,;    				   			// bloco contendo funcao especifica para preencher o aCols; 
               	Iif((nOpc == 3),.T.,.F.),;  	// lEmpty 
               	,; 								// aHeaderAux
               	,; 		   						// aColsAux
               	,; 								// bAfterCols
               	,; 								// bBeforeCols
               	,; 								// bAfterHeader
               	'') 							// cAliasQry
               	
//����������������������������������������������������������������������Ŀ
//� Verifica a posicao dos campos no aHeader p/ posterior consistencia   �
//������������������������������������������������������������������������
nPosPro  := Ascan(aHeader,{|x| x[2] = "QEA_PRODUT"})
nPosDPr  := Ascan(aHeader,{|x| x[2] = "QEA_DESPRO"})  

QE060AfCols( aHeader, aCols )

//��������������������������������������������������������������Ŀ
//� Calcula dimens�es                                            �
//����������������������������������������������������������������
oSize := FwDefSize():New()

oSize:AddObject( "ENCHOICE"	,  100, 30, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "GETDADOS"	,  100, 70, .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

If ( Type("l060Auto") == "U" .Or. ! l060Auto )
	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0006) FROM ;
								oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL 	 //"Grupos de Produtos"

		oEncQE3 := MsMGet():New(cAlias,nReg,nOpc,,,,,{;
									oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI"),;
						 			oSize:GetDimension("ENCHOICE","LINEND"),oSize:GetDimension("ENCHOICE","COLEND")},,,,,,oDlg,,.T.,,,,,,,.T.)
		oGet    := MsGetDados():New(oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
						 				oSize:GetDimension("GETDADOS","LINEND"),oSize:GetDimension("GETDADOS","COLEND"),;
						 				nOpc,"QE060lOk","QE060TOk",,.T.,NIL,NIL,NIL,5000)			

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(oGet:TudoOk(),oDlg:End(),nOpcA:=0)},{||oDlg:End()}) CENTERED  
Else  
	If EnchAuto(cAlias,aAutoCab,{|| Obrigatorio(aGets,aTela)},aRotina[nOpc][4]) .and. MsGetDAuto(aAutoItens,"QE060lOk",{|| QE060TOk()},aAutoCab,aRotina[nOpc][4])      
		nOpcA := 1
	EndIf
EndIF

IF nOpcA == 1	// Confirma
                
	//��������������������������������������������������������������Ŀ
	//� Rotina de Exclusao do Grupo x Produtos						 �
	//����������������������������������������������������������������
	If nOpc == 5

		Begin Transaction

		//������������������������������������������������������Ŀ
		//� Apaga tambem do QEA -> Amarracao Grupo X Produtos    �
		//��������������������������������������������������������
		dbSelectArea('QEA')
		dbSetOrder(1)
		dbSeek( xFilial("QEA")+QE3->QE3_GRUPO )
		While !EOF() .And. QEA_FILIAL+QEA_GRUPO==xFilial("QEA")+QE3->QE3_GRUPO
			RecLock("QEA",.F.,.t.)
			dbDelete()
			MsUnLock()
			dbSkip()
		EndDo

		//��������������������������������������������������������������Ŀ
		//� Apos passar por todas as verificacoes , deleta o registro    �
		//����������������������������������������������������������������
		dbSelectArea(cAlias)
		RecLock(cAlias,.F.)
		dbDelete()
		MsUnLock()
	
		End Transaction

   	//��������������������������������������������������������������Ŀ
	//� Rotina de Altera��o / Inclus�o do Grupo x Produtos			 �
	//����������������������������������������������������������������
    ElseIf nOpc == 4 .or. nOpc == 3
    
	   	//��������������������������������������������������������������Ŀ
		//� Atualizacao do Cabecalho (QE3).								 �
		//����������������������������������������������������������������
		dbSelectArea("QE3")
		dbSetOrder(1)
		If !dbSeek(xFilial("QE3")+M->QE3_GRUPO)		    
			RecLock("QE3",.T.)
			QE3->QE3_FILIAL := xFilial("QE3")
		Else
			RecLock("QE3",.F.)
		EndIf
        Aeval(aCpoQE3[1],{|x,y|QE3->&(aCpoQE3[1,y]):=M->&(aCpoQE3[1,y])})
 		MsUnlock()

	   	//��������������������������������������������������������������Ŀ
		//� Grava o arquivo QEA											 �
		//����������������������������������������������������������������

		For nX := 1 to Len(aCols)
			If !Acols[nX,Len(aHeader)+1]	// Nao esta deletado
					dbSelectArea("QEA")
					dbSetOrder(1)
					If dbSeek(xFilial("QEA") + QE3->QE3_GRUPO + aCols[nX,nPosPro])			
						RecLock("QEA",.F.)	 
					Else
						RecLock("QEA",.T.) 
					Endif
					For nY := 1 to Len(aHeader)
						If aHeader[nY,10] # "V"
							cVar := Trim(aHeader[nY][2])
							Replace &cVar. With aCols[nX,nY]
						Endif
					Next nY
					RecLock("QEA",.F.)
					QEA->QEA_GRUPO  := QE3->QE3_GRUPO
					QEA->QEA_FILIAL := xFilial("QEA")
					MsUnLock()
			Else
			 	//���������������������������������������Ŀ
				//� Cancela o Produto no QEA              �
				//�����������������������������������������
				dbSelectArea("QEA")
				If dbSeek(xFilial("QEA") + QE3->QE3_GRUPO + aCols[nX,nPosPro])			
					RecLock("QEA",.F.)
					dbDelete()
					MsUnLock()
				EndIf
	 		EndIf
		Next nX
    EndIf
EndIF

Return
          

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QE060lOk  � Autor � Cleber Souza          � Data � 06/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se a linha digitada esta' Ok                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QE060lOk(o)

Local lRetu    :=.T.
Local nAchou   :=0
Local cProcura := aCols[n][nPosPro]

If !(aCols[n,Len(aCols[n])])

	//�������������������������������������������������������������Ŀ
	//� Verifica se campo Produto esta' preenchido                  �
	//���������������������������������������������������������������
	If !aCols[n][Len(aHeader)+1] .And. LastKey() != 5 .And. LastKey() != 27 .And. lRetu
		If Empty(aCols[n][nPosPro])
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
		If ! Empty(aCols[n][nPosPro])
			If ! ExistCpo("QE6",aCols[n][nPosPro])
				lRetu := .f.
			EndIf
		EndIf
	EndIf

	//������������������������������������������������������������Ŀ
	//� Verifica se o Produto esta' relacionado a outro Grupo      �
	//��������������������������������������������������������������
	If lRetu
		If !Empty(aCols[n][nPosPro])
			nReg := QEA->(Recno())
			QEA->(dbSetOrder(2))
			If QEA->(dbSeek(xFilial("QEA") + aCols[n][nPosPro]))
				If QEA->QEA_GRUPO <> QE3->QE3_GRUPO
					HELP(" ",1,"A060GRPEXI",,QEA->QEA_GRUPO,3,1)
					lRetu := .f.
				EndIf
			EndIf
			QEA->(dbSetOrder(1))
			QEA->(dbGoto(nReg))
		EndIf
	EndIf
EndIf
Return lRetu

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QE060TOk  � Autor � Cleber Souza          � Data � 06/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se toda a getdados esta' Ok                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QE060TOk(o)
Local nI
Local lRetu := .F.
Local nCnt  := 0

For nI := 1 to Len(aCols)
	If !aCols[nI][Len(aCols[nI])]
		lRetu := .T.
	Else
		If ! QE060lOk(o)
			lRetu := .F.
			Exit
		EndIf
		nCnt++
	EndIf
Next

If nCnt == Len(aCols)
	MsgInfo(STR0007)//"E necessario associar pelo menos um produto ao grupo"
EndIF

Return(lRetu)  

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A060DEqu � Autor � Cleber Souza          � Data � 06/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gatilho para preencher a descricao da Equipe Follow-up     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A060DEqu(ExpC1,ExpL1)                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo da Equipe                                   ���
���          � ExpL1 = Indica se e' gatilho                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico-Cham. no X3_RELACAO,X3_INIBRW e gat. (QE3_EQUIPE) ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function A060DEqu(cCodEq,lGatilho)
lGatilho := Iif(lGatilho == NIL,.t.,lGatilho)

IF !Inclui .or. lGatilho	// Se Inic. Padrao ou gatilho a partir do cod. equipe
	QE4->(dbSetOrder(1))
	QE4->(dbSeek(xFilial("QE4") + cCodEq))
	Return(QE4->QE4_DESCRI)
Else
	Return Space(Len(QE4->QE4_DESCRI))
Endif  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A060VlPr � Autor � Cleber Souza          � Data � 06/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo Produto                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QieA060 - E' chamada no X3_VALID do cpo. QEA_PRODUT - SX3  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function A060VlPr()

Local lRetu := .t.
Local nI    := 0
Local nReg  := 0
Local cVar  := &(Readvar()) // Conteudo da variavel do campo NC

//����������������������������������������������������������������Ŀ
//� Verifica se mudou o Produto (Alterou o campo ja' digitado)     �
//������������������������������������������������������������������
If !Empty(aCols[n,nPosPro]) .And. !Empty(cVar) .And. aCols[n,nPosPro] <> cVar
	Help(" ",1,"A010ALTCHA")	// Campo nao pode ser alterado	
	lRetu := .f.
EndIf

If lRetu
	//�������������������������������������������������Ŀ
	//� Verifica se o Produto esta' cadastrado          �
	//���������������������������������������������������
	aCols[n][nPosPro] := M->QEA_PRODUT
	If ! ExistCpo("QE6",aCols[n][nPosPro])
		lRetu := .f.
	EndIf
EndIf

//���������������������������������������������������������Ŀ
//� Verifica se o Produto ja' existe p/ este Grupo          �
//�����������������������������������������������������������
If lRetu
	For nI := 1 to len(aCols)
		If cVar == acols[nI][nPosPro] .and. nI <> n // Se ja' existir este cod. NC
			Help(" ",1,"A060EXIPRO")
			lRetu := .f.
		EndIf
	Next nI
EndIf

//������������������������������������������������������������Ŀ
//� Verifica se o Produto esta' relacionado a outro Grupo      �
//��������������������������������������������������������������
If lRetu
	nReg := QEA->(Recno())
	QEA->(dbSetOrder(2))
	If QEA->(dbSeek(xFilial("QEA") + aCols[n][nPosPro]))
		If QEA->QEA_GRUPO <> M->QE3_GRUPO
			HELP(" ",1,"A060GRPEXI",,QEA->QEA_GRUPO,3,1)
			lRetu := .f.
		EndIf
	EndIf
	QEA->(dbSetOrder(1))
	QEA->(dbGoto(nReg))
EndIf

//�������������������������������������������������Ŀ
//� Preenche a Descricao do Produto                 �
//���������������������������������������������������
If lRetu
	aCols[n][nPosDPr] := QIEXDePr(aCols[n][nPosPro])
EndIf

Return(lRetu)


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �QE020AfCols �Autor  �Cicero Cruz         � Data �  17/01/04   ���
���������������������������������������������������������������������������͹��
���Desc.     � Rotina que carrega os campos Virtuais                        ���
���������������������������������������������������������������������������Ĵ��
���Uso       � QIEA060                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function QE060AfCols( aHeader, aCols )
Local nLinha := 0

For nLinha := 1 to Len(aCols)
	aCols[nLinha,nPosDPr] := Iif(!Empty(aCols[nLinha,nPosPro]),QIEXDePr(aCols[nLinha,nPosPro]),"")
Next

Return
