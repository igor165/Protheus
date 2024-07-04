#include "PLSMGER.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � PLSA038 � Autor � Tulio Cesar          � Data � 04.06.2004 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � SubContrato X Diferenciacao de U.S p/  Unidade             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSA038
PRIVATE aRotina     := MenuDef()
PRIVATE cCadastro 	:= Fundesc() //"SubContrato X Diferenciacao de U.S/Ref para Cobranca e Co-Part."

PlsAtuHlp()
//���������������������������������������������������������������������Ŀ
//� Chama funcao de Browse...                                           �
//�����������������������������������������������������������������������
BS9->(mBrowse(06,01,22,75,"BS9"))
//���������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal...                                          �
//�����������������������������������������������������������������������
Return Nil
/*/
���������������������������������������������������������������������������
���������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Programa  � PLSA038BS9 � Autor � Tulio Cesar      � Data � 22.11.2003 ���
������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o campo BS9_CODUNM - Diferenciacao de U.S por Und  ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Function PLSA038BS9()
LOCAL lRet
LOCAL cMVPLSCIRD := GetNewPar("MV_PLSCIRD","PLSRETCH,PLSRETM2,PLSRETPA,PLSRETREA,PLSRETUCO")

lRet := BS9->(ExistChav("BS9",M->BS9_SUBCON+M->BS9_CODUNI,1))

If lRet

	BD3->(dbGoTop())

	lRet := BD3->(PlsSeek("BD3",1,"M->BS9_CODUNI","M->BS9_DESUNI","BD3_DESCRI"))
	
	If lRet
		If ! AllTrim(BD3->BD3_RDMAKE) $ cMVPLSCIRD
			lRet := .F.
			Help("",1,"PLSA365BS9")
		Endif   
	Endif

Endif

Return(lRet)


/*/
���������������������������������������������������������������������������
���������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Programa  � PLSA038BS9 � Autor � Tulio Cesar      � Data � 22.11.2003 ���
������������������������������������������������������������������������Ĵ��
���Descri��o � Valida as Vigencias da tabela BS9						 ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Function PlsVldBS9()
Local lRet     := .T.
Local cDatDe   := "BS9_VIGDE"
Local cDatAte  := "BS9_VIGATE" 
Local aArea	   := GetArea()                                          
LOCAL cSql		:= ""
LOCAL aMat 		:= {}

cSql := "SELECT * FROM "+RetSqlName("BS9")+" WHERE BS9_FILIAL = '"+xFilial("BS9")+"' "
cSql += "AND BS9_SUBCON = '"+M->BS9_SUBCON+"' "
cSql += "AND BS9_CODUNI = '"+M->BS9_CODUNI+"' "
cSql += "AND D_E_L_E_T_ = ' '"
PlsQuery(cSql, "TRBBS9")
                                                     
While !TRBBS9->( Eof() )
	If altera .and. TRBBS9->R_E_C_N_O_ == BS9->( Recno() )
		TRBBS9->( dbSkip() )
		
		Loop
	Endif
	
	If M->BS9_FINATE == TRBBS9->BS9_FINATE .AND. M->BS9_TABPRE == TRBBS9->BS9_TABPRE
		AaDd(aMat,{ TRBBS9->BS9_VIGDE, TRBBS9->BS9_VIGATE })
	Endif

	TRBBS9->( dbSkip() )
Enddo

// Valida apenas a matriz
lRet := PLSVLDVIG(nil,0,nil,cDatDe,cDatAte,{},nil,aMat)

TRBBS9->( dbCloseArea() )

RestArea(aArea)
Return(lRet)  


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �22/12/2006���
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
Private aRotina := { 	{ STRPL01				,'AxPesqui' , 0 ,K_Pesquisar	,0 ,.F.},;
											{ "Visualizar"	,'AxVisual' , 0 ,K_Visualizar	,0 ,Nil},;
											{ "Incluir"		,'TudoOkBS9' , 0 ,K_Incluir		,0 ,Nil},;
											{ "Alterar"	  	,'TudoOkBS9' , 0 ,K_Alterar		,0 ,Nil},;
											{ "Excluir"		,'AxDeleta' , 0 ,K_Excluir		,0 ,Nil} }
Return(aRotina)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA010   �Autor  �Microsiga           � Data �  17/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funca de validacao das datas de vigencia, chamada no       ���
���          � botao de OK da Rotina Cobertura / Co-Participacao.         ���
���          � Tabela - BHK - Grupo Cob x Co-participacao. 				  ���
�������������������������������������������������������������������������͹��
���Uso       � PLS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function TudoOkBS9(cAlias,nReg,nOpc)
Local nRet  := 0

Private INCLUI := .F.
Private ALTERA := .F.
Private EXCLUI := .F.

If nOpc == K_Incluir
	//INCLUSAO
	INCLUI := .T.
	ALTERA := .F.
	EXCLUI := .F.
	
	nRet   := AxInclui(cAlias,nReg,K_Incluir,,,,"PlsVldBS9()")     
ElseIf nOpc == K_Alterar
	//ALTERACAO
	INCLUI := .F.
	ALTERA := .T.
	EXCLUI := .F.
	
	nRet   := AxAltera(cAlias,nReg,K_Alterar,,,,,"PlsVldBS9()")  

EndIf

Return

Static Function PlsAtuHlp()

PutHelp("PBS9_CODUNI",{"C�digo da unidade de medida para qual ",;
						"� v�lido os valores informados."}, {},{},.T.)
Return