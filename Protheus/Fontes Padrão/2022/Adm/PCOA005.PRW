#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCOA005.CH" 

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOA005	� Autor � Luiz Enrique	     	  � Data � 22/07/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Acoes. - Planejamento Orcamentario.					 ���
���			 � AS OPCOES DE INCLUSAO E ALTERACAO, FORAM RETIRADAS POR    	 ���
���			 � DEFINICAO DE REGRA DE NEGOCIO. POREM AS FUNCOES DE VALIDACOES���
���			 � FORAM MANTIDAS PARA USO FUTURO: VldExcAca() e VldAltAca()  	 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function PCOA005 ()

Private aRotina 	:= {} 
Private cCadastro	:= STR0001 //"A��es do Planejamento Or�ament�rio"  

dbSelectArea("AMI")
dbSetOrder(1)
dbGoTop()

aAdd( aRotina ,{"Pesquisar" 	,"AxPesqui",0,1})
aAdd( aRotina ,{"Visualizar"	,"AxVisual",0,2})

mBrowse(,,,,"AMI")

Return 

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �VldExcAca � Autor � Luiz Enrique	     	  � Data � 22/07/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a Exclusao no Cadastro de Acoes.							 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function VldExcAca()

Local lret := .T.

Local aRet:=FunRetPadr (Nil,AMI->AMI_CODEVT)	//Verifica se Acao e Padrao	

If aRet[2]  
	MsgBox(STR0002) //"A A��o em quest�o � padr�o e n�o pode ser Excluida."
	Return .f.
Endif

AMH->(DbGoTop())
While AMH->(!Eof())
	If AMI->AMI_CODEVT == AMH->AMH_CODEVT
		lRet := .f.
		Exit
	EndIf
	AMH->(DbSkip())
EndDo

If !lret
	Aviso(STR0003,STR0004,{STR0005},2,STR0006)  // "Aten��o" //"Imposs�vel Excluir. Existem Fases associadas a esta A��o." // "Voltar" // "Exclus�o de A��o"
EndIf

Return lRet   

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �VldAltAca � Autor � Luiz Enrique	     	  � Data � 22/07/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a Inclusao e ALteracao no Cadastro de Acoes.			 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function VldAltAca()

Local lret := .T.
Local nRecAtu:= AMI->(Recno())

Local aRet:=FunRetPadr (Nil,AMI->AMI_CODEVT)	//Verifica se Acao e Padrao	

If aRet[2]  
	MsgBox(STR0007) //"A A��o em quest�o � padr�o e n�o pode ser Alterada."
	Return .f.
Endif 

AMI->(DbGoTop())

While AMI->(!Eof()) 
	If AMI->AMI_CODEVT == M->AMI_CODEVT .And. nRecAtu <> AMI->(Recno())
		lRet:=.f.
		Exit
	Endif
	AMI->(Dbskip())
Enddo

If !lret
	Aviso(STR0003,STR0008,{STR0005},2,STR0009) //"Aten��o" //"Opera��o Inv�lida. C�digo da A��o j� existente." //"Voltar" //"Manuten��o da A��o"
EndIf

AMI->(DbGoto(nRecAtu))

Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FunRetPadr� Autor � Luiz Enrique	     	  � Data � 22/07/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna um Array contendo: 											 ���
���			 � 1- Valor logico da existencia da Fase Padrao - Defaut = .F.	 ���
���			 � 2- Valor logico da existencia da Acao Padrao - Defaut = .F.	 ���
���			 � 3- Array com os codigos Padrao das Fases.							 ���
���			 � 4- Array com os codigos Padrao das Acoes.					   	 ��� 
���������������������������������������������������������������������������Ĵ��
���Parametro � cFase: Opcional, Informa codigo da Fase a ser pesquisada ou  ���
���   		 � cAcao: Opcional, Informa codigo da Acao a ser pesquisada.	 ���
���������������������������������������������������������������������������Ĵ��
��� Retorno  � aRetPadrao: {lExiteFase,lExistAcao,aFases,aAcoes}            ���
���   		 � lExiteFase 	=	{T ou F na existencia da Fase recebida}		 ���
���   		 � lExistAcao	=	{T ou F na existencia da acao recebida}		 ���
���   		 � aFases  		=	{codigos das Fases Padrao}							 ���
���   		 � aAcoes  		=	{codigos das Acoes Padrao}							 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function FunRetPadr (cFase,cAcao)

Local nLp
Local aAcoes	:= {}
Local aFases	:= {}
Local aF			:= {}
Local aA			:= {} 

Local aAreaAMI	:= GetArea("AMI")
Local aAreaAMG	:= GetArea("AMG")
Local aAreaAMH	:= GetArea("AMH")

Local lretF		:=.f.
Local lretA		:=.f.

PCO5ARRPAD (@aFases,@aAcoes)
     
AMI->(dbSetOrder(2)) //ACOES:			Filial + Descricao
AMG->(dbSetOrder(2)) //FASES:			Filial + Descricao
AMH->(dbSetOrder(1)) //AMARRACAO:	Filial + Codigos da Fase + Codigo da Acao 

//Monta Array com os codigos das FASES Padrao
aF:= {} 
For nLp:= 1 To Len(aFases)  
	AMG->(DbSeek(xFilial()+Upper(aFases[nLp,1])))	
	aAdd(aF,{AMG->AMG_COD})	
Next

//Monta Array com os codigos das ACOES Padrao
aA:= {} 
For nLp:= 1 To Len(aAcoes)
	AMI->(DbSeek(xFilial()+Upper(aAcoes[nLp,1])))
	aAdd(aA,{AMI->AMI_CODEVT})	
Next

If!Empty(cFase)
	lretF := Ascan(aF,{|x| x[01] == cFase}) > 0
Endif

If!Empty(cAcao)
	lretA := Ascan(aA,{|x| x[01] == cAcao}) > 0
Endif

aRetPadrao:={lretF,lretA,aF,aA}

RestArea(aAreaAMI)
RestArea(aAreaAMG)
RestArea(aAreaAMH)

Return aRetPadrao  

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOEdiAcao� Autor � Luiz Enrique	        � Data � 22/07/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se a Alteracao do campo e permitida considerando os ���
���			 � codigos padroes das ACOES.						 						 ���
���			 � Utilizado no X3_WHEN dos campos AMI_CODEVT e AMI_DESCRI.		 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function PCOEdiAcao()

Local aRet
Local lRet:= .F.  

aRet:=FunRetPadr (Nil,M->AMI_CODEVT)	//Verifica se Fase Padrao
lRet:=aRet[2] 

Return lRet

