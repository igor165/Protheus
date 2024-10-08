#INCLUDE "HSPAHP41.ch"
#INCLUDE "protheus.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO3     � Autor � MARCELO JOSE       � Data �  11/11/04   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRA NAO CONFORMIDADE DO PRONTUARIO ATRAVES DA CLASSE  ���
���          � qNC METHODO  NEW                                           ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HSPAHP41()

Private cCadastro := STR0001 //"Cadastro de Nao Conformidades"
Private aRotina   := MenuDef()
                      
Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cGsbRegGer := ""

Private cString := "GSE"

dbSelectArea("GSE")
dbSetOrder(1)

dbSelectArea(cString)
mBrowse( 6,1,22,75,cString,)

Return(Nil) 
/*****************************************************************************************************************/
Function HS_IncP41()
 axInclui("GSE",,3,,,,"HS_VIP41()") 
Return(.T.)          
/*****************************************************************************************************************/
Function HS_VIP41()
 Local cDescD, oQnc
 If Inclui 
  cDescD  := STR0003 + M->GSE_CODNAO + " / " + M->GSE_REGGER + " / " + M->GSE_CODEND + " / " + Alltrim(M->GSE_NOMPAC) //"SPP - No.Nao Conf./Pront./Ender./Nome     : "
  /* GERA OBJETO OCORRENCIA NAO CONFORME*/
  oQnc  := qNC():NEW(cDescD,M->GSE_COMENT,M->GSE_DATNCF,M->GSE_DATCON,STR0004,M->GSE_CODDIS,M->GSE_TPFIC,M->GSE_PRIORI) //"Nao conformidade referente ao SAME"
  M->GSE_OCORRE := oQnc:aRetQNC[2] 
  M->GSE_REVISA := oQnc:aRetQNC[3] 
 EndIf
 
Return(.T.) 

/*****************************************************************************************************************/
/********   AUTOR: MARCELO JOSE 11/11/04 CLASSE qNC RESPONSAVEL PELA INTEGRACAO DO SIGAHSP x SIGAQNC *************/
/*****************************************************************************************************************/
/********   esta classe tem dois METHODOS:NEW => RESPONSAVEL PELA GERACAO DE UMA NOVA OCORRENCIA     *************/
/********                                 PRI => RESPONSAVEL PELA IMPRESSAO DA FICHA DE OCORRENCIA   *************/
/*****************************************************************************************************************/
 
CLASS qNC

 DATA aCpoQNC
 DATA aRetQNC 
 METHOD NEW (pDescD,pComen,pDtOcor,pDtConc,pDescR,pCodDis,pClassi,pPriori) CONSTRUCTOR  
 METHOD PRI (pOcorr,pRevis) CONSTRUCTOR

ENDCLASS

/******/

METHOD New(pDescD,pComen,pDtOcor,pDtConc,pDescR,pCodDis,pClassi,pPriori) Class qNC
 ::aCpoQNC := {}
 ::aRetQNC := {}
 Aadd(::aCpoQNC,{"QI2_MEMO1" ,  pDescD  })   /* DESCRICAO DETALHADA MEMO-80            */
 Aadd(::aCpoQNC,{"QI2_MEMO2" ,  pComen  })   /* COMENTARIOS  m-80                      */ 
 Aadd(::aCpoQNC,{"QI2_OCORRE",  pDtOcor })   /* Dt.Ocorrencia  d-8                     */
 Aadd(::aCpoQNC,{"QI2_CONPRE",  pDtConc })   /* Dt.Conclusao Prevista d-8              */
 Aadd(::aCpoQNC,{"QI2_DESCR" ,  pDescR  })   /* DESCRICAO RESUMIDA   c-50              */
 Aadd(::aCpoQNC,{"QI2_TPFIC" ,  pClassi })   /* CLASSIFICACAO DA NAO CONFORMIDADE  c-1 */
 Aadd(::aCpoQNC,{"QI2_PRIORI",  pPriori })   /* PRIORIDADE  c-1                        */
 Aadd(::aCpoQNC,{"QI2_CODDIS",  pCodDis })   /* codigo da disposicao                   */
 ::aRetQNC := QNCGERA(1,::aCpoQNC)           
Return Self 

/******/

METHOD PRI(pOcorr,pRevis) Class qNC
 DbSelectArea("QI2")
 DbSetOrder(2)
 If DbSeek(xFilial("QI2") + pOcorr + pRevis )
  QNCR050(QI2->(Recno()))                    
 EndIf
Return Self


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Tiago Bandeira        � Data � 10/06/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Gera arquivo TXT para exportacao                      �
//�    4 - Recebe arquivo TXT                                    �
//����������������������������������������������������������������
Local aRotina :=	{{STR0005, "AxPesqui"                                  ,0,1, 0, nil},; //"Pesquisar"
                     {STR0006, "AxVisual"                                  ,0,2, 0, nil},; //"Visualizar"
                     {STR0007, "HS_IncP41()"                               ,0,3, 0, nil},; //"Incluir"
                     {STR0008, "AxAltera"                                  ,0,4, 0, nil},; //"Alterar"
                     {STR0009, "qNC():PRI(GSE->GSE_OCORRE,GSE->GSE_REVISA)",0,4, 0, nil},; //"Imprimir"
                     {STR0010, "AxDeleta"                                  ,0,5, 0, nil}}  //"Excluir"
Return(aRotina)