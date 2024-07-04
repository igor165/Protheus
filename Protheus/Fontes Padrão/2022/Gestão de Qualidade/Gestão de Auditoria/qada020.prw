#INCLUDE "QADA020.CH"
#INCLUDE "PROTHEUS.CH"
 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QADA020  � Autor � Paulo Emidio de Barros� Data � 18/10/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Check List									  ���
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
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()

Local aRotina := { {STR0001, "AxPesqui" ,  0 , 1,,.F.},;  // "Pesquisar"
			  	  {STR0002, "QA20Visual",  0 , 2   },;    // "Visualizar"
				  {STR0003, "QA20Inclui",  0 , 3   },;	  // "Incluir"
				  {STR0004, "QA20Altera",  0 , 4   },;	  // "Alterar"
				  {STR0005, "QA20Deleta",  0 , 5, 3},;	  // "Excluir"
				  {STR0006, "QA20Efetiv",  0 , 2   },;	  // "E&fetiva"
				  {STR0007, "QA20Copia" ,  0 , 2   },;	  // "Copia"
				  {STR0021, "QA20Dupl"  ,  0 , 2   },;	  // "Duplica" 
				  {STR0008, "QA020Leg"  ,  0 , 2,,.F.}}   // "Legenda"

Return aRotina

Function QADA020(aRotAuto, nOpc)
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local aSitChkLst := {}

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0009) //"Check List"
Private lQD20Auto := ( aRotAuto <> NIL )
Private aAcho := {"QU2_CHKLST", "QU2_REVIS" , "QU2_DESCRI", "QU2_OBSERV", "QU2_ULTREV"}

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

//��������������������������������������������������������������Ŀ
//� Status do CheckList											 �
//����������������������������������������������������������������
Aadd(aSitChkLst,{"Q020LegPen()","BR_CINZA"})
Aadd(aSitChkLst,{"Q020LegVig()","BR_VERDE"})
Aadd(aSitChkLst,{"Q020LegObs()","BR_VERMELHO"})

//Avisa o cliente sobre as atualiza��es que ser�o realizadas no SIGAQAD.   
/*If !lQD20Auto
	QAvisoQad()
EndIf*/

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
If ( lQD20Auto )
	MsRotAuto(nOpc,aRotAuto,"QU2")	
Else
	mBrowse( 6, 1,22,75,"QU2",,"QU2_EFETIV",,,,aSitChkLst)
EndIf

Return(.T.)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q020LegVig� Autor � Paulo Emidio de Barros� Data �22/10/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Condicao da exibicao da legenda de checklists vigentes	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q020LegVig												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Q020LegVig()
Local lRetorno := .F.

If QU2->QU2_EFETIV == "1"  
	lRetorno := .T.
EndIf
Return(lRetorno)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q020LegObs� Autor � Paulo Emidio de Barros� Data �22/10/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Condicao da exibicao da legenda de checklists obsoletos	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q020LegObs												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Q020LegObs()
Local lRetorno := .F. 

If QU2->QU2_EFETIV == "2" 
	lRetorno := .T.
EndIf
Return(lRetorno)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q020LegPen� Autor � Paulo Emidio de Barros� Data �22/10/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Condicao da exibicao da legenda de checklists pendentes	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q020LegPen												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Q020LegPen()
Local lRetorno := .F. 

If QU2->QU2_EFETIV == "3"
	lRetorno := .T. 
EndIf	
Return(lRetorno)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA20deleta� Autor � Paulo Emidio de Barros� Data �18/10/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Check List									  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QA20Deleta(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION QA20Deleta(cAlias,nReg,nOpc)
LOCAL nOpcA 
Local oDlg
Local nOldRecSM0
Local aFilAud    := {}                  
Local lDelChkLst := .T.
Local nX := 1
Local oSize
//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
              
lQD20Auto := If (ValType("lQD20Auto") == "U",.F., lQD20Auto)

//��������������������������������������������������������������Ŀ
//� Define tamanho da tela                                       �
//����������������������������������������������������������������
oSize := FwDefSize():New()
oSize:AddObject( "TELA" ,  100, 100, .T., .T. ) // Totalmente dimensionavel
oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

aPos	:= {	oSize:GetDimension("TELA","LININI"), oSize:GetDimension("TELA","COLINI"), ;
				(oSize:GetDimension("TELA","LINEND")), oSize:GetDimension("TELA","COLEND") }

//��������������������������������������������������������������Ŀ
//� Le as Filiais 						 						 �
//����������������������������������������������������������������
nOldrecSM0 := SM0->(Recno())
SM0->(dbGoTop())
While SM0->(!Eof())
	If SM0->M0_CODIGO == cEmpAnt //Empresa Atual
		Aadd(aFilAud,FWCodFil())
	EndIf       
	SM0->(dbSkip())
EndDo

//��������������������������������������������������������������Ŀ
//� Restaura a area do SM0										 �
//����������������������������������������������������������������
SM0->(dbGoTo(nOldRecSM0))

//��������������������������������������������������������������Ŀ
//� Verifica se o Check List esta efetivado						 �
//����������������������������������������������������������������
If QU2->QU2_EFETIV == "1"
	Help("",1,"020CHKVIG") // "Check List esta Vigente"
	Return
ElseIf QU2->QU2_EFETIV == "2"
	Help("",1,"020CHKOBS") // "Check List esta Obsoleto"
	Return
EndIf	

//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
nOpcA := 0
dbSelectArea(cAlias)
SoftLock(cAlias)
	
If !( lQD20Auto )
	DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
					        TO oSize:aWindSize[3],oSize:aWindSize[4] TITLE cCadastro OF oMainWnd PIXEL
	nOpcA := EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0012), aAcho,aPos)  //"Quanto a exclus�o?"
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 2,oDlg:End()})
Else
	nOpca := 1
EndIf
	
dbSelectArea(cAlias)
	
IF nOpcA == 1
		
	//��������������������������������������������������������������Ŀ
	//� Verifica se o Check List a ser excluido esta sendo utilizado �
	//� em alguma Auditoria.										 �
	//����������������������������������������������������������������
	QUF->(dbSetOrder(2))   
	If !Empty(xFilial("QUF"))
		For nX := 1 to Len(aFilAud)
			If (QUF->(dbSeek(aFilAud[nX]+QU2->QU2_CHKLST+QU2->QU2_REVIS)))
				lDelChkLst := .F.                                            
				Return(NIL)
			EndIf                       
		Next
	Else	
		If (QUF->(dbSeek(xFilial("QUF")+QU2->QU2_CHKLST+QU2->QU2_REVIS)))
			lDelChkLst := .F.
		EndIf
	EndIf	
					  
	If !lDelChkLst
		HELP(" ",1,"010EXISAUD")
		dbSelectArea(cAlias)
		MsUnLock()
		Return(NIL)
	EndIf		

	Begin Transaction
		
	//��������������������������������������������������������������Ŀ
	//� Apaga as questoes associadas aos Topicos e Check List		 �
	//����������������������������������������������������������������
	QU4->(dbSetOrder(1))
	QU4->(dbSeek(xFilial("QU4")+QU2->QU2_CHKLST+QU2->QU2_REVIS))
	While QU4->(!Eof()) .And. (QU2->QU2_CHKLST+QU2->QU2_REVIS)==; 
		(QU4->QU4_CHKLST+QU4->QU4_REVIS)				
		//Realiza a exclusao do Texto da Questao
		MsMM(QU4->QU4_TXTCHV,,,,2,,,,)		
		//Realiza a exclusao do Requisito da Questao
		MsMM(QU4->QU4_REQCHV,,,,2,,,,)		
		//Realiza a exclusao da Observacao da Questao
		MsMM(QU4->QU4_OBSCHV,,,,2,,,,)		

		RecLock("QU4",.F.)
		QU4->(dbDelete())
		MsUnLock()
		FKCOMMIT()

		QU4->(dbSkip())
	EndDo

	//��������������������������������������������������������������Ŀ
	//� Apaga os Topicos associados ao Check List					 �
	//����������������������������������������������������������������
	QU3->(dbSetOrder(1))
	QU3->(DbSeek(xFilial("QU3")+QU2->QU2_CHKLST+QU2->QU2_REVIS))
	While QU3->(!Eof()) .And. (QU2->QU2_CHKLST+QU2->QU2_REVIS)==;
		(QU3->QU3_CHKLST+QU3->QU3_REVIS)
		RecLock("QU3",.F.)
		QU3->(dbDelete())
		MsUnLock()
		FKCOMMIT()
		QU3->(dbSkip())	
	EndDo	    
			
	//��������������������������������������������������������������Ŀ
	//� Deleta o Registro do QU2									 �
	//����������������������������������������������������������������
	dbSelectArea(cAlias)
	RecLock(cAlias,.F.,.T.)
	dbDelete()
	MsUnLock()
	FKCOMMIT()
			
	End Transaction
		
Else
	MsUnLock()
		
EndIf
	
dbSelectArea(cAlias)

Return( NIL )

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA20Inclui� Autor � Paulo Emidio de Barros� Data �18/10/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Check List									  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QA20Inclui(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION QA20Inclui(cAlias,nReg,nOpc)
Local nOpcA := 0

If ( Type("lQD20Auto") == "U" )
	lQD20Auto := .f.
EndIf

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private aTELA[0][0]
Private aGETS[0]

//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
nOpcA := 0
	
Begin Transaction
	
	If !(lQD20Auto)
		nOpcA := AxInclui( cAlias, nReg, nOpc, aAcho,,,"QA20TudoOk()")
	Else
		nOpcA := AxIncluiAuto(cAlias,"QA20TudoOk()")
	EndIf
	
	If nOpcA == 1           
		RecLock("QU2",.F.)
		QU2->QU2_EFETIV := "3" 
		MsUnLock()
	EndIf
		
End Transaction  
	
dbSelectArea(cAlias)

Return(NIL)


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA20Altera� Autor � Paulo Emidio de Barros� Data �18/10/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Check List									  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Qa20Inclui(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION QA20Altera(cAlias,nReg,nOpc)
Local nOpcA :=0 

lQD20Auto := If(ValType("lQD20Auto") == "U",.F.,lQD20Auto)

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private aTELA[0][0]
Private aGETS[0]

//��������������������������������������������������������������Ŀ
//� Verifica se o Check List esta efetivado						 �
//����������������������������������������������������������������
If QU2->QU2_EFETIV == "1"
	Help("",1,"020CHKVIG") // "Check List esta Vigente"
	Return
ElseIf QU2->QU2_EFETIV == "2"
	Help("",1,"020CHKOBS") // "Check List esta Obsoleto"
	Return
EndIf	
	
//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
nOpcA :=0
	
Begin Transaction
	
	If ( lQD20Auto )
		nOpcA := AxIncluiAuto(cAlias,"AllWaysTrue()",,nOpc,QU2->(RecNo()))	
	Else
		nOpcA := AxAltera( cAlias, nReg, nOpc, aAcho, , , ,"AllWaysTrue()")
	EndIf

End Transaction
	
dbSelectArea(cAlias)
Return(NIL)


/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA20TudoOk� Autor �Paulo Emidio de Barros � Data � 20/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza as consistencias antes da gravacao dos dados		  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QA20TudoOk()
Local lRet := .F.

If QA20CkPd() // Valida para que nao seja usado o codigo do check-list padrao
	lRet := ExistChav("QU2",M->QU2_CHKLST+M->QU2_REVIS)
EndIf

Return(lRet)


/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA20Efetiv� Autor �Paulo Emidio de Barros � Data � 15/11/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a efetivacao do Check List						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QA20Efetiv()
Local lRetorno   := .T.
Local aAreaQU2   := QU2->(GetArea())  
Local cChkLst    := QU2->QU2_CHKLST
Local cNewChkLst := QU2->(QU2_CHKLST+QU2_REVIS)
Local oBrw
Local lQa20Vlef  := .T.

//��������������������������������������������������������������Ŀ
//�Verifica se o Check List ja esta efetivado           		 �
//����������������������������������������������������������������	
If QU2->QU2_EFETIV == "1"
	Help("",1,"020CHKVIG") // "Check List esta Vigente"
	Return
ElseIf QU2->QU2_EFETIV == "2"
	Help("",1,"020CHKOBS") // "Check List esta Obsoleto"
	Return
EndIf	

//��������������������������������������������������������������Ŀ
//�Verifica se existem topicos	associados ao Check List		 �
//����������������������������������������������������������������	
QU3->(dbSetOrder(1))
QU3->(dbSeek(xFilial("QU3")+QU2->QU2_CHKLST+QU2->QU2_REVIS))
If QU3->(Eof())
   	Help("",1,"020NEXITOP")
 	lRetorno := .F.
Else
	While QU3->(!Eof()) .And. QU3->QU3_FILIAL == xFilial("QU3") .And.;
		(QU3->QU3_CHKLST+QU3->QU3_REVIS) == cNewChkLst

		//��������������������������������������������������������������Ŀ
		//�Verifica se existem Questoes	associadas ao Check List		 �
		//����������������������������������������������������������������	
		QU4->(dbSetOrder(1))
		QU4->(dbSeek(xFilial("QU4")+QU3->QU3_CHKLST+	QU3->QU3_REVIS+	QU3->QU3_CHKITE))
		If QU4->(Eof())
 		   	Help("",1,"QADNOQST") //"Existe Topico sem Questao associada, verifique"
		 	lRetorno := .F.        
		 	Exit
		EndIf           
		QU3->(dbSkip())		
		
	EndDo	 	
EndIf

//��������������������������������������������������������������Ŀ
//�Ponto de Entrada para validar a efetiva��o do Check List 	 �
//����������������������������������������������������������������	
If Existblock("Qa20Vlef")
	lQa20Vlef := Execblock("Qa20Vlef",.F.,.F.,{QU2->QU2_FILIAL,QU2->QU2_CHKLST,QU2->QU2_REVIS})
	If ValType(lQa20Vlef) == 'L' .And. !lQa20Vlef // Se retornar falso sai da fun��o
		Return
	Endif
Endif               

//��������������������������������������������������������������Ŀ
//� Caso exista Topicos e questoes efetuva o Check List			 �
//����������������������������������������������������������������	
If lRetorno
	RecLock("QU2",.F.)
	QU2->QU2_EFETIV := "1"
	MsUnLock()
EndIf		


QU2->(dbSetorder(1))
QU2->(dbSeek(xFilial("QU2")+QU2->QU2_CHKLST))

While QU2->(!Eof()) .And. (QU2->QU2_FILIAL == xFilial("QU2")) .And. (QU2->QU2_CHKLST == cChkLst) 
	If QU2->(QU2_CHKLST+QU2_REVIS) # cNewChkLst 
		If QU2->QU2_EFETIV # "2" 
			RecLock("QU2",.F.) 
			QU2->QU2_EFETIV := "2"
			MsUnLock()
	    EndIf
	EndIf
	QU2->(dbSkip())
EndDo
oBrw := GetMBrowse()
oBrw:Refresh()

RestArea(aAreaQU2)
	
Return(NIL)


/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA20Copia � Autor �Paulo Emidio de Barros � Data � 15/11/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a copia de um Check List	efetivado 				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QA20Copia()
Local aSaveArea := GetArea()
Local cNewChkLst
Local cNewRevChk
Local cOldRevChk     
Local aRegist 
Local cNomCpo 
Local nSavRec
Local cMessage
Local nX	    := 1
Local lContinua := .T.

If Existblock ("QD020CPY")
	lContinua := Execblock("QD020CPY",.F.,.F.)
Endif

If QU2->QU2_EFETIV # "1" .And. lContinua
	//��������������������������������������������������������������Ŀ
	//�Verifica se o Check List esta efetivado           		     �
	//����������������������������������������������������������������	
   	Help("",1,"020CHKNEFE")                                            
   	
ElseIf QA20CkPd("QU2") .And. lContinua // Verifica se est� copiando o check-list padr�o
	//��������������������������������������������������������������Ŀ
	//�Copia a Nova Revisao do Check List							 �
	//����������������������������������������������������������������	
	dbSelectArea("QU2")
	cNewChkLst := QU2->QU2_CHKLST
	cOldRevChk := QU2->QU2_REVIS
    nSavRec    := QU2->(Recno())
    
    //��������������������������������������������������������������Ŀ
	//�Procura a ultima revisao do Check List						 �
	//����������������������������������������������������������������	
	While QU2->(!Eof()) .And. QU2->QU2_FILIAL == xFilial("QU2") .And.;
		QU2->QU2_CHKLST == cNewChkLst
		QU2->(dbSkip())
	EndDo		      
	QU2->(dbSkip(-1))
	cNewRevChk := StrZero(Val(QU2->QU2_REVIS)+1,2)

    //��������������������������������������������������������������Ŀ
	//� Realiza a gravacao do Check com a nova Revisao				 �
	//����������������������������������������������������������������	
	aRegist := {}	
	For nX := 1 to QU2->(fCount())
		 cNomCpo := FieldName(nX)
		 Aadd(aRegist,{cNomCpo,&cNomCpo})
	Next nX
	    
    RecLock("QU2",.T.)
    For nX := 1 To Len(aRegist)
        QU2->(FieldPut(FieldPos(aRegist[nX,1]),aRegist[nX,2]))
    Next                       
    QU2->QU2_REVIS  := cNewRevChk
    QU2->QU2_ULTREV := dDatabase
    QU2->QU2_EFETIV := "3"
    MsUnlock()
   	FKCOMMIT()

	QU2->(dbGoTo(nSavRec))		    

	//��������������������������������������������������������������Ŀ
	//�Copia a Nova Revisao dos Topicos associados ao Check List     �
	//����������������������������������������������������������������	
	dbSelectArea("QU3")
	dbSetOrder(1)
	dbSeek(xFilial("QU3")+cNewChkLst+cOldRevChk)
	While QU3->(!Eof()) .And. QU3->QU3_FILIAL == xFilial("QU3") .And.;
		(QU3->QU3_CHKLST+QU3->QU3_REVIS) == (cNewChkLst+cOldRevChk)
	
		aRegist := {}	
		For nX := 1 to QU3->(fCount())
			 cNomCpo := FieldName(nX)
			 Aadd(aRegist,{cNomCpo,&cNomCpo})
		Next nX
	    nSavRec := QU3->(Recno())

        //Realiza a gravacao dos Topicos	    
	    RecLock("QU3",.T.)
	    For nX := 1 To Len(aRegist)
	        QU3->(FieldPut(FieldPos(aRegist[nX,1]),aRegist[nX,2]))
	    Next                       
	    QU3->QU3_REVIS  := cNewRevChk
	    QU3->QU3_ULTREV := dDatabase
	    MsUnlock()
    	FKCOMMIT()

		QU3->(dbGoTo(nSavRec))	   
	    QU3->(dbSkip())

	EndDo	

	//��������������������������������������������������������������Ŀ
	//�Copia a Nova Revisao das Questoes associadas ao Check List    �
	//����������������������������������������������������������������	
	dbSelectArea("QU4")
	dbSetOrder(1)
	dbSeek(xFilial("QU4")+cNewChkLst+cOldRevChk)
	While QU4->(!Eof()) .And. QU4->QU4_FILIAL == xFilial("QU4") .And.;
		(QU4->QU4_CHKLST+QU4->QU4_REVIS) == (cNewChkLst+cOldRevChk)
		                                      
		aRegist :={}
		For nX := 1 to QU4->(fCount())
			 cNomCpo := FieldName(nX)
			 Aadd(aRegist,{cNomCpo,&cNomCpo})
		Next nX
	    nSavRec := QU4->(Recno())
	
		//��������������������������������������������������������������Ŀ
		//� Realiza a gravacao das questoes	menos as Chaves Textos MSMM  �
		//����������������������������������������������������������������	
	    RecLock("QU4",.T.)
	    For nX := 1 To Len(aRegist)
   	    	IF !(aRegist[nX,1]$'QU4_TXTCHV.QU4_REQCHV.QU4_OBSCHV')
		        QU4->(FieldPut(FieldPos(aRegist[nX,1]),aRegist[nX,2]))
		    Endif
	    Next                       
	    QU4->QU4_REVIS  := cNewRevChk
	    QU4->QU4_ULTREV := dDatabase
	    MsUnlock()
		FKCOMMIT()
	    
   		//��������������������������������������������������������������Ŀ
		//� Realiza a gravacao dos novos Textos MSMM	 				 �
		//����������������������������������������������������������������	
		For nX := 1 To Len(aRegist)
			DO CASE
				CASE aRegist[nX,1]=='QU4_TXTCHV'
					//Realiza a gravacao do Texto da Questao					
					IF !EMPTY(aRegist[nX,2])               
						MsMM(QU4_TXTCHV,,,MsMM(aRegist[nX,2]),1,,,'QU4','QU4_TXTCHV')
					Endif	
				CASE aRegist[nX,1]=='QU4_REQCHV'
					//Realiza a gravacao do Requisito da Questao
					IF !EMPTY(aRegist[nX,2])
						MsMM(QU4_REQCHV,,,MsMM(aRegist[nX,2]),1,,,'QU4','QU4_REQCHV')
					Endif	
				CASE aRegist[nX,1]=='QU4_OBSCHV'				
					//Realiza a gravacao da Observacao da Questao
					IF !EMPTY(aRegist[nX,2])
						MsMM(QU4_OBSCHV,,,MsMM(aRegist[nX,2]),1,,,'QU4','QU4_OBSCHV')
					Endif	
			EndCASE
		Next    
	    
		QU4->(dbGoTo(nSavRec))		    
	    QU4->(dbSkip())

	EndDo	

	cMessage := STR0013+AllTrim(cNewChkLst)+STR0014+cNewRevChk //"Foi gerado o Check List "###" com a Revisao "
	MsgAlert(cMessage)
	
EndIf
RestArea(aSaveArea)

Return(NIL)


/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA020Revi � Autor �Paulo Emidio de Barros � Data � 15/11/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se o codigo da Revisao e Numerico                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Qa020Revi()
Local lRetorno := .T.

If IsAlpha(M->QU2_REVIS) 
	Help("",1,"QAD010CHKC")
	lRetorno := .F.
	
EndIf                       

If Len(Alltrim(M->QU2_REVIS)) # Len(M->QU2_REVIS)
	Help("",1,"QAD010TAMI")
	lRetorno := .F.
	
EndIf

Return(lRetorno)


/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA020Leg  � Autor �Paulo Emidio de Barros � Data � 15/11/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe a Legenda dos Check-List							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QA020Leg()
Local aLegenda := {}
                                                                    	
Aadd(aLegenda,{"BR_VERDE",   OemToAnsi(STR0015)}) //"Vigente"
Aadd(aLegenda,{"BR_CINZA",   OemToAnsi(STR0016)}) //"Pendente" 
Aadd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0017)}) //"Obsoleto"

BrwLegenda(cCadastro,"Check List",aLegenda)

Return(NIL)


/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA20Dupl  � Autor �Telso Carneiro 		� Data � 31/03/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a duplicacao de um Check List	 				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QA20Dupl()
Local aSaveArea := GetArea()
Local cNewChkLst
Local cNewRevChk
Local cOldChkLst
Local cOldRevChk     
Local aRegist 
Local cNomCpo 
Local nSavRec
Local cMessage
Local nX		:= 1   
Local cPerg     := "QAD020    "
Local lContinua := .T.

If QU2->QU2_EFETIV == "2"
	Help("",1,"020CHKOBS") // "Check List esta Obsoleto"
	Return(NIL)
Endif

If !QA20CkPd("QU2") // Verifica se est� duplicando o check-list padr�o
	Return Nil
EndIf

IF Pergunte(cPerg,.T.)
	cNewChkLst:=MV_PAR01
	cNewRevChk:=MV_PAR02
    nSavRec   := QU2->(Recno())
	QU2->(DBSetOrder(1))
   	IF QU2->(DbSeek(xFilial("QU2")+cNewChkLst+cNewRevChk))
   	   Help("",1, "EXISTCHK" )
   	   QU2->(dbGoTo(nSavRec))		    
       Return(NIL)             
	Endif                        
	QU2->(dbGoTo(nSavRec))		                               
Else
    Return(NIL)
Endif

If Existblock ("QD020DUP")
	lContinua := Execblock("QD020DUP",.F.,.F.,{cNewChkLst,cNewRevChk})
Endif

//��������������������������������������������������������������Ŀ
//�Verifica retorno do Ponto de Entrada 	           		     �
//����������������������������������������������������������������
If lContinua
	//����������������������������������������������������������Ŀ
	//�Copia a Revisao do Check List							 �
	//������������������������������������������������������������
	dbSelectArea("QU2")            
	cOldChkLst := QU2->QU2_CHKLST
	cOldRevChk := QU2->QU2_REVIS

	aRegist := {}
	For nX := 1 to QU2->(fCount())
		cNomCpo := FieldName(nX)
		Aadd(aRegist,{cNomCpo,&cNomCpo})
	Next nX

	Begin Transaction
	//��������������������������������������������������������������Ŀ
	//� Realiza a gravacao do Novo Check com a nova Revisao			 �
	//����������������������������������������������������������������
	RecLock("QU2",.T.)
	For nX := 1 To Len(aRegist)
		QU2->(FieldPut(FieldPos(aRegist[nX,1]),aRegist[nX,2]))
	Next
	QU2->QU2_CHKLST	:= cNewChkLst
	QU2->QU2_REVIS  := cNewRevChk
	QU2->QU2_ULTREV := dDatabase
	QU2->QU2_EFETIV := "3"
	MsUnlock()
	FKCOMMIT()

	//��������������������������������������������������������������Ŀ
	//�Copia a Nova Revisao dos Topicos associados ao Check List     �
	//����������������������������������������������������������������
	dbSelectArea("QU3")
	dbSetOrder(1)
	dbSeek(xFilial("QU3")+cOldChkLst+cOldRevChk)
	While QU3->(!Eof()) .And. QU3->QU3_FILIAL == xFilial("QU3") .And.;
		(QU3->QU3_CHKLST+QU3->QU3_REVIS) == (cOldChkLst+cOldRevChk)
	
		aRegist := {}
		For nX := 1 to QU3->(fCount())
			cNomCpo := FieldName(nX)
			Aadd(aRegist,{cNomCpo,&cNomCpo})
		Next nX
		nSavRec := QU3->(Recno())
	
		//Realiza a gravacao dos Topicos
		RecLock("QU3",.T.)
		For nX := 1 To Len(aRegist)
			QU3->(FieldPut(FieldPos(aRegist[nX,1]),aRegist[nX,2]))
		Next
		QU3->QU3_CHKLST	:= cNewChkLst
		QU3->QU3_REVIS  := cNewRevChk
		QU3->QU3_ULTREV := dDatabase
		MsUnlock()
		FKCOMMIT()
	
		QU3->(dbGoTo(nSavRec))
		QU3->(dbSkip())
	
	EndDo

	//��������������������������������������������������������������Ŀ
	//�Copia a Nova Revisao das Questoes associadas ao Check List    �
	//����������������������������������������������������������������
	dbSelectArea("QU4")
	dbSetOrder(1)
	dbSeek(xFilial("QU4")+cOldChkLst+cOldRevChk)
	While QU4->(!Eof()) .And. QU4->QU4_FILIAL == xFilial("QU4") .And.;
		(QU4->QU4_CHKLST+QU4->QU4_REVIS) == (cOldChkLst+cOldRevChk)
	
		aRegist :={}
		For nX := 1 to QU4->(fCount())
			cNomCpo := FieldName(nX)
			Aadd(aRegist,{cNomCpo,&cNomCpo})
		Next nX
		nSavRec := QU4->(Recno())
	
		//��������������������������������������������������������������Ŀ
		//� Realiza a gravacao das questoes	menos as Chaves Textos MSMM  �
		//����������������������������������������������������������������
		RecLock("QU4",.T.)
		For nX := 1 To Len(aRegist)
			IF !(aRegist[nX,1]$'QU4_TXTCHV.QU4_REQCHV.QU4_OBSCHV')
				QU4->(FieldPut(FieldPos(aRegist[nX,1]),aRegist[nX,2]))
			Endif
		Next
		QU4->QU4_CHKLST	:= cNewChkLst
		QU4->QU4_REVIS  := cNewRevChk
		QU4->QU4_ULTREV := dDatabase
		MsUnlock()
		FKCOMMIT()
	
		//��������������������������������������������������������������Ŀ
		//� Realiza a gravacao dos novos Textos MSMM	 				 �
		//����������������������������������������������������������������
		For nX := 1 To Len(aRegist)
			DO CASE
				CASE aRegist[nX,1]=='QU4_TXTCHV'
					//Realiza a gravacao do Texto da Questao
					IF !EMPTY(aRegist[nX,2])
						MsMM(QU4_TXTCHV,,,MsMM(aRegist[nX,2]),1,,,'QU4','QU4_TXTCHV')
					Endif
				CASE aRegist[nX,1]=='QU4_REQCHV'
					//Realiza a gravacao do Requisito da Questao
					IF !EMPTY(aRegist[nX,2])
						MsMM(QU4_REQCHV,,,MsMM(aRegist[nX,2]),1,,,'QU4','QU4_REQCHV')
					Endif
				CASE aRegist[nX,1]=='QU4_OBSCHV'
					//Realiza a gravacao da Observacao da Questao
					IF !EMPTY(aRegist[nX,2])
						MsMM(QU4_OBSCHV,,,MsMM(aRegist[nX,2]),1,,,'QU4','QU4_OBSCHV')
					Endif
			EndCASE
		Next
	
		QU4->(dbGoTo(nSavRec))
		QU4->(dbSkip())
	
	EndDo
	End Transaction

	cMessage := STR0013+AllTrim(cNewChkLst)+STR0014+cNewRevChk //"Foi gerado o Check List "###" com a Revisao "
	MsgAlert(cMessage)

Endif

RestArea(aSaveArea)

Return(NIL)

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QA20CkPd � Autor � Paulo Fco. Cruz Neto  � Data � 04/03/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o do c�digo do check-list padr�o					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QA20CkPd(ExpC1)				                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Alias											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� */
Function QA20CkPd(cAlias)
Local lRet := .T.
Default cAlias := "M"

If &((cAlias)+"->QU2_CHKLST") == "999999"
	Alert(STR0022) //"N�o � poss�vel incluir/copiar/duplicar check-lists utilizando o c�digo do check-list padr�o - 999999"
	lRet := .F.
EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} QA20Visual()
Chamada da fun��o AxVisual
@author Luiz Henrique Bourscheid
@since 02/03/2018
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function QA20Visual(cAlias, nReg, nOpc)
Local nOpcA := 0
Local lQD20Auto := If(ValType("lQD20Auto") == "U",.F.,lQD20Auto)
	
AxVisual( cAlias, nReg, nOpc, aAcho)

Return 