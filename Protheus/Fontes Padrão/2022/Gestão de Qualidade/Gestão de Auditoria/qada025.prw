#include "QADA025.CH"
#include "PROTHEUS.CH"
 
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QADA025  � Autor � Paulo Emidio de Barros� Data � 08/11/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro dos Topicos do Check List  						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQAD                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Paulo Emidio�18/12/00�------�Foram ajustados e complementados os STR's ���
���            �	    �      �e os arquivos CH's, para que os mesmos pos���
���            �	    �      �sam ser traduzidos.						  ���
���Eduardo S.  �29/11/02�------�Acerto para validar o preench. do topico. ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function MenuDef()

Local aRotina := {{ STR0001, "AxPesqui"  , 0, 1,,.F.},;  //"Pesquisar"
	            { STR0002, "Qad025Man",  0, 2},;  //"Visualizar"
	            { STR0003, "Qad025Man" , 0, 3},;  //"Incluir"
	            { STR0004, "Qad025Man" , 0, 4},;  //"Alterar"
	            { STR0005, "Qad025Man" , 0, 5, 3}}//"Excluir"

Return aRotina

Function QADA025()
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0006) //"Topicos"

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

//Avisa o cliente sobre as atualiza��es que ser�o realizadas no SIGAQAD.
//QAvisoQad()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse(6,1,22,75,"QU3")

Return(NIL)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Qad025Man � Autor � Paulo Emidio de Barros� Data �09/11/2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao dos Topicos									  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Alias posicionado                                   ���
���          � ExpN1: Numero do registro posicionado                      ���
���          � ExpN2: Opcao do menu selecionada                           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � NIL                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Qad025Man(cAlias,nReg,nOpcx)  
Local nOpcA      := 0
Local oDlg       := ""
Local oGet
Local aSveArea   := GetArea()
Local cChkLst    := CriaVar("QU3_CHKLST")
Local cChkRev    := CriaVar("QU3_REVIS")
Local dUltRev    := CriaVar("QU3_ULTREV") 
Local cChkDsc    := CriaVar("QU2_DESCRI")
Local oGetChkLst 
Local oGetChkRev 
Local oGetUltRev
Local oGetChkDsc
Local aSizeAut	:= MsAdvSize(,.F.)
Local aObjects := {}  
Local aInfo := {} 
Local aPosObj := {} 
Local aNoFields := {"QU3_CHKLST", "QU3_REVIS", "QU3_ULTREV"}

   

Static nOrdSX3

//��������������������������������������������������������������Ŀ
//� Define variaveis para edicao do dados				         �
//����������������������������������������������������������������
Private aHeader := {}
Private aCols   := {}
Private nUsado  := 0
Private aRegTop :={}                                

Private nPosChkIte  
Private nPosChkDsc 

Private cSeek  := QU3->QU3_FILIAL+QU3->QU3_CHKLST+QU3->QU3_REVIS
Private cWhile := "QU3->QU3_FILIAL+QU3->QU3_CHKLST+QU3->QU3_REVIS"

//�����������������������������������������������������������������Ŀ
//� Se o Check List estiver efetivado, nao e possivel a manipulacao �
//� dos registros.												    �
//�������������������������������������������������������������������
If (nOpcx == 4 .or. nOpcx == 5)
	If !QadChkEfet(QU3->QU3_CHKLST+QU3->QU3_REVIS,.F.)
		Return(NIL)
	EndIf       
EndIf

//��������������������������������������������������������������Ŀ
//� Salva a integridade 										 �
//����������������������������������������������������������������
dbSelectArea("QU3")
dbSetOrder(1)      

If nOpcX !=3
	FillGetDados(nOpcX,cAlias,1     ,cSeek ,{|| &cWhile},         , aNoFields,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpcX,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
Else
	FillGetDados(nOpcX,cAlias,1     ,      ,             ,         , aNoFields,          ,        ,      ,        ,  .T.  ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpcX,Alias ,nOrdem,cSeek  ,bSeekWhile   ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
EndIf

nPosChkIte := Ascan(aHeader,{|x| AllTrim(x[2]) == "QU3_CHKITE"})
nPosChkDsc := Ascan(aHeader,{|x| AllTrim(x[2]) == "QU3_DESCRI"})

AAdd( aObjects, { 000, 040, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })
aInfo  := { aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 2, 2 }
aPosObj:= MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],0 To aSizeAut[6],aSizeAut[5] Of oMainWnd Pixel 		

//��������������������������������������������������������������Ŀ
//� Bloco com as atualizacoes das variaveis e objetos     		 �
//����������������������������������������������������������������
@ 03.5,001   SAY RetTitle("QU3_CHKLST")
@ 03.4,006.5 MSGET oGetChkLst VAR cChkLst F3 "QBC" PICTURE PesqPict("QU3","QU3_CHKLST");
  	VALID If(Empty(cChkLst),(Help("",1,"025NCHKLST",,OemToAnsi(STR0009),1),.F.),; // "Check List nao informado"
  	CheckSX3("QU3_CHKLST",cChkLst) .And. If(qPsqChkLst(cChkLst,cChkRev,.F.,.F.),(cChkDsc:=QU2->QU2_DESCRI,oGetChkDsc:Refresh()),.F.));
	WHEN VisualSX3("QU3_CHKLST") .And.	If(nOpcx==3,.T.,Q025AtuVar(@oGetChkLst,@oGetChkRev,@oGetUltRev,@oGetChkDsc,@cChkLst,@cChkRev,@dUltRev,@cChkDsc) .And. .F.)
	
@ 03.5,017   SAY RetTitle("QU3_REVIS")
@ 03.4,022.5 MSGET oGetChkRev VAR cChkRev PICTURE PesqPict("QU3","QU3_REVIS");
	VALID  NAOVAZIO(cChkRev) .AND. CheckSX3("QU3_REVIS",cChkRev) .And. FREEFORUSE("QU2",cChkLst+cChkRev) .AND. If(qPsqChkLst(cChkLst,cChkRev,.F.,.F.)	,(cChkDsc:=QU2->QU2_DESCRI,oGetChkDsc:Refresh()),.F.);
	WHEN VisualSX3("QU3_REVIS") .And. If(nOpcx==3,.T.,.F.)

@ 03.5,028   SAY RetTitle("QU3_ULTREV")
@ 03.4,033.5 MSGET oGetUltRev VAR dUltRev SIZE 35,8 PICTURE PesqPict("QU3","QU3_ULTREV");
	VALID CheckSX3("QU3_ULTREV",dUltRev) WHEN  VisualSX3("QU3_ULTREV")
	
@ 04.5,001   SAY RetTitle("QU2_DESCRI") Size 50,6
@ 04.4,006.5 MSGET oGetChkDsc VAR cChkDsc PICTURE PesqPict("QU2", "QU2_DESCRI"); 			
	VALID CheckSX3("QU3_DESCRI",cChkDsc);
	WHEN VisualSX3("QU2_DESCRI") .And. .F. Size 261,6
                                             
oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"Q025LinOk","Q025TudOk",,.T.,,,,999)
	
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA :=1,If(oGet:TudoOk(),oDlg:End(),nOpcA:=0)},{||oDlg:End()})

If nOpcA == 1

	Begin Transaction
        
        //��������������������������������������������������������������Ŀ
		//� Realiza a manutencao dos dados no QUC						 �
		//����������������������������������������������������������������
		If nOpcx # 2			
			If nOpcx == 3 .Or. nOpcx == 4
				Q025GrvTop(nOpcx,cChkLst,cChkRev,dUltRev)			
			ElseIf nOpcx ==5 
				Q025DelTop(nOpcx,cChkLst,cChkRev)			
			EndIf			
			
			//��������������������������������������������������������������Ŀ
			//� Processa os gatilhos										 �
			//����������������������������������������������������������������	
			EvalTrigger()			
		EndIf			
				
	End Transaction
	
Endif
                      
//Restaura a Ordem original do SX3
dbSelectArea("SX3")
dbSetorder(nOrdSX3)

dbSelectArea(cAlias)
              
RestArea(aSveArea)

Return(nOpcA)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q025Linok � Autor � Paulo Emidio de Barros� Data �09/11/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao dos itens da Getdados                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void q025LinOk()                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA025                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q025LinOk()
Local lRetorno := .T.
Local cItem 
Local nItem
      
If Empty(aCols[N,nPosChkIte])
	If !aCols[N,Len(aCols[N])]
		Help("",1,"025NTOPIC") // "Topico nao Informado"
		lRetorno := .F.
	EndIf
ElseIf Empty(aCols[N,nPosChkDsc])
	If !aCols[N,Len(aCols[N])]
		Help("",1,"025DESCVAZ")	// Descricao do Topico nao Informada.
		lRetorno := .F.
	EndIf	
EndIf                  
            
cItem := aCols[N,nPosChkIte]

If lRetorno
	For nItem := 1 to Len(aCols)		
		If aCols[nItem,nPosChkIte] == cItem
			If !aCols[N,Len(aCols[nItem])] .And. !aCols[nItem,Len(aCols[nItem])]
				If N # nItem
					Help("",1,"Q025TOPJIN") // Topico ja informado
					lRetorno := .F.
				 	Exit
		        EndIf
			EndIf
		EndIf
	Next nItem
EndIf

Return(lRetorno)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q025TudOk � Autor � Paulo Emidio de Barros� Data �09/11/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao dos itens da Getdados apos a confirmacao         ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void Q025TudOk()                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA025                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q025TudOk()
Local lRetorno := .T.
Local nX 

Private nCont   := 0

Aeval( aCols, { |x| If(x[Len(aHeader)+1] == .T. ,nCont++,nCont)})

If nCont == Len(aCols)
	Help("",1,"025DESCVAZ")
	lRetorno := .F.
Else
	For nX := 1 To Len(aCols)
	    
		If Empty(aCols[nX,nPosChkDsc])
			If !aCols[nX][Len(aCols[nX])] .And. nCont ==0
				Help("",1,"025DESCVAZ")
				lRetorno := .F.
			EndIf	
		EndIf
		
	Next                  

Endif

Return(lRetorno)         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q025GrvTop� Autor � Paulo Emidio de Barros� Data �09/11/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a gravacao dos dados 							  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void Q025GrvTop(nOpcx,cNumAud)                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� EXPN1 = Numero da Opcao retornada pelo aRotina             ���
���          � EXPC1 = Numero da Auditoria Selecionada					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA025                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q025GrvTop(nOpcx,cChkLst,cChkRev,dUltRev)
Local lRetorno := .T.
Local nX
Local nY
Local lAltQues := .F.
Local cChkAtu  := ""
Local cCReAtu  := ""
Local cTopAtu  := ""
Local aRegTop  := {}

dbSelectArea("QU3")
dbSetOrder(1)
dbSeek(xFilial("QU3")+cChkLst+cChkRev)
While QU3->(!EOF()) .And. QU3->QU3_FILIAL == xFilial("QU3") .And.;
      QU3->QU3_CHKLST == cChkLst .And. QU3->QU3_REVIS == cChkRev
	aAdd(aRegTop,QU3->(Recno()))
	QU3->(dbSkip())
EndDo

For nX := 1 To Len(aCols)
	
	//����������������������������������������������������������������������Ŀ
	//�Verifica se a linha foi deletada                                      �
	//������������������������������������������������������������������������
	If (aCols[nX,Len(aHeader)+1])//marca de exclusao
		
		//����������������������������������������������������������������������Ŀ
		//� posiciona no registro deletado e exclui o mesmo do banco de dados    �
		//������������������������������������������������������������������������
		If nOpcx == 4 //Alteracao
			If nX <= Len(aRegTop)
				dbGoTo(aRegTop[nX])
				
				//����������������������������������������������������������������������Ŀ
				//�Apaga as questoes associadas ao Topico								 �
				//������������������������������������������������������������������������
				QU4->(dbSetOrder(1))
				QU4->(dbSeek(xFilial("QU4")+QU3->QU3_CHKLST+QU3->QU3_REVIS+QU3->QU3_CHKITE))
				While !Eof() .And. xFilial("QU4") == QU4->QU4_FILIAL .And.;
					(QU4->QU4_CHKLST+QU4->QU4_REVIS+QU4->QU4_CHKITE) ==;
					(QU3->QU3_CHKLST+QU3->QU3_REVIS+QU3->QU3_CHKITE)
					//Realiza a exclusao do Texto da Questao
					MsMM(QU4->QU4_TXTCHV,,,,2,,,,)
					//Realiza a exclusao do Requisito da Questao
					MsMM(QU4->QU4_REQCHV,,,,2,,,,)
					//Realiza a exclusao da Observacao da Questao
					MsMM(QU4->QU4_OBSCHV,,,,2,,,,)
					
					RecLock("QU4",.F.,.T.)
					QU4->(dbDelete())
					MsUnlock()
					FKCOMMIT()
					QU4->(dbSkip())
				EndDo
				
				RecLock("QU3",.F.)
				QU3->(dbDelete())
				MsUnlock()
				
			EndIf
		EndIf		
	Else		
		//����������������������������������������������������������������������Ŀ
		//� Verifica se a Alteracao ser incluida ou modificada                   �
		//������������������������������������������������������������������������
		If nOpcx == 4 //Alteracao
			If nX <= Len(aRegTop)
				dbGoto(aRegTop[nX])
				//����������������������������������������������������������������������Ŀ
				//� Verifica se Houve Alteracao do codigo do Topico 					 �
				//������������������������������������������������������������������������
				IF (QU3->QU3_CHKITE <> aCols[nX,nPosChkIte])
					lAltQues:= .T.
					cChkAtu	:= QU3->QU3_CHKLST
					cCReAtu	:= QU3->QU3_REVIS
					cTopAtu	:= QU3->QU3_CHKITE
				Else
					lAltQues:=.F.
				Endif
				RecLock("QU3",.F.)
			Else
				RecLock("QU3",.T.)
			EndIf
			For nY := 1 to Len(aHeader)				
				//����������������������������������������������������������������������Ŀ
				//� Se o Campo nao for Virtual realiza a gravacao						 �
				//������������������������������������������������������������������������
				If ( aHeader[nY,10] <> "V" )
					QU3->(FieldPut(FieldPos(AllTrim(aHeader[nY,2])),aCols[nX,nY]))
				EndIf				
			Next nY
			
			//����������������������������������������������������������������������Ŀ
			//�Atualiza os dados padroes dos Topicos								 �
			//������������������������������������������������������������������������
			QU3->QU3_FILIAL := xFilial("QU3")
			QU3->QU3_CHKLST := cChkLst
			QU3->QU3_REVIS  := cChkRev
			QU3->QU3_ULTREV := dUltRev
			MsUnlock()
			FKCOMMIT()
			
		Else //Inclusao
			RecLock("QU3",.T.)
			For nY := 1 to Len(aHeader)				
				//����������������������������������������������������������������������Ŀ
				//� Se o Campo nao for Virtual realiza a gravacao						 �
				//������������������������������������������������������������������������
				If ( aHeader[nY,10] <> "V" )
					QU3->(FieldPut(FieldPos(AllTrim(aHeader[nY,2])),aCols[nX,nY]))
				EndIf				
			Next nY
			
			//����������������������������������������������������������������������Ŀ
			//�Atualiza os dados padroes dos Topicos								 �
			//������������������������������������������������������������������������
			QU3->QU3_FILIAL := xFilial("QU3")
			QU3->QU3_CHKLST := cChkLst
			QU3->QU3_REVIS  := cChkRev
			QU3->QU3_ULTREV := dUltRev
			MsUnlock()
			FKCOMMIT()
		EndIf
		
		IF lAltQues
			//����������������������������������������������������������������������Ŀ
			//�Altera as questoes associadas ao Topico								 �
			//������������������������������������������������������������������������
			dbSelectArea("QU4")
			QU4->(dbSetOrder(1))
			While QU4->(MsSeek(xFilial("QU4")+cChkAtu+cCReAtu+cTopAtu))
				RecLock("QU4",.F.)
				QU4->QU4_CHKITE:=aCols[nX,nPosChkIte]
				MsUnlock()
				FKCOMMIT()				
				QU4->(dbSkip())
			EndDo
			dbSelectArea("QU3")
			lAltQues:=.F.
		Endif
	EndIf
	
Next nX

Return(lRetorno)         


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q025DelTop� Autor � Paulo Emidio de Barros� Data �09/11/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a exclusao dos topicos e questoes				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void Q025delTop(nOpcx,cChkLst,cChkRev)                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� EXPN1 = Numero da Opcao retornada pelo aRotina             ���
���          � EXPC1 = Numero do Check-List								  ���
���          � EXPC2 = Numero da Revisao do Check-List					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA025                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q025DelTop(nOpcx,cChkLst,cChkRev)
Local lRetorno := .T.

dbSelectArea("QU3")
dbSetOrder(1)
dbSeek(xFilial("QU3")+cChkLst+cChkRev)
While !Eof() .And. xFilial("QU3") == QU3->QU3_FILIAL .And.;
	(QU3->QU3_CHKLST+ QU3->QU3_REVIS) == (cChkLst+cChkRev)

	//����������������������������������������������������������������������Ŀ
	//� Apaga as questoes associadas ao Topico.								 �
	//������������������������������������������������������������������������
	QU4->(dbSetOrder(1))
	QU4->(dbSeek(xFilial("QU4")+QU3->QU3_CHKLST+QU3->QU3_REVIS+QU3->QU3_CHKITE))
	While !Eof() .And. xFilial("QU4") == QU4->QU4_FILIAL .And.;
		(QU4->QU4_CHKLST+QU4->QU4_REVIS+QU4->QU4_CHKITE) ==;
		(QU3->QU3_CHKLST+QU3->QU3_REVIS+QU3->QU3_CHKITE)

		//Realiza a exclusao do Texto da Questao
		MsMM(QU4->QU4_TXTCHV,,,,2,,,,)		
		//Realiza a exclusao do Requisito da Questao
		MsMM(QU4->QU4_REQCHV,,,,2,,,,)		
		//Realiza a exclusao da Observacao da Questao
		MsMM(QU4->QU4_OBSCHV,,,,2,,,,)		

		RecLock("QU4",.F.,.T.)
		QU4->(dbDelete())    
		MsUnlock()
		QU4->(dbSkip())
	EndDo		
	
	RecLock("QU3",.F.,.T.)
	QU3->(dbDelete())
	MsUnlock()
	
	QU3->(dbSkip())	
EndDo	

Return(lRetorno)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q025AtuVar� Autor � Paulo Emidio de Barros� Data �09/11/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza as variaveis de Memoria							  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q025AtuVar(oGetChkLst,oGetChkRev,oGetUltRev,oGetChkDsc,;   ���
���          �cChkLst,cChkRev,dUltRev,cChkDsc)							  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 															  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA025                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q025AtuVar(oGetChkLst,oGetChkRev,oGetUltRev,oGetChkDsc,cChkLst,cChkRev,dUltRev,cChkDsc)    

//����������������������������������������������������������������������Ŀ
//� Pesquisa o Check List a ser editado atraves do regsitro corrente QU3 �
//������������������������������������������������������������������������
QU2->(dbSetOrder(1))
QU2->(dbSeek(xFilial("QU2")+QU3->QU3_CHKLST+QU3->QU3_REVIS))
If QU2->(!Eof())
	cChkLst := QU2->QU2_CHKLST
	cChkRev := QU2->QU2_REVIS
	dUltRev := QU2->QU2_ULTREV
	cChkDsc := QU2->QU2_DESCRI   

	oGetChkLst:Refresh()
	oGetChkRev:Refresh()
	oGetUltRev:Refresh()
	oGetChkDsc:Refresh()
EndIf                   

Return(.T.)
