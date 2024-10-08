#include "PROTHEUS.CH"
#include "PLSMGER.CH"
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA182 � Autor � Paulo Carnelossi       � Data � 13.06.03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Internacao                                                 ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSA182()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial.                              ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
��� 01.07.03 �      � Tulio Cesar � Apos informar a data de inclusao      ����
���          �      �             � gerar a senha aleatoria...            ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSA182()
//��������������������������������������������������������������������������Ŀ
//� Define variaveis PRIVATE...                                              �
//����������������������������������������������������������������������������
PRIVATE aRotina   := MenuDef()
PRIVATE cCadastro := "Data de Internacao"

PRIVATE aCdCores  := { { 'BR_VERDE'    ,'Autorizada'              },;
                        { 'BR_VERMELHO' ,'Autorizada Parcial'          },;
                        { 'BR_AMARELO'  ,'Nao Autorizada'  },;
                        { 'BR_MARRON'   ,'Aguardando finalizacao do atendimento' }}

PRIVATE aCores    := { { 'BE4_STATUS = "1"',aCdCores[1,1] },;
                        { 'BE4_STATUS = "2"',aCdCores[2,1] },;
                        { 'BE4_STATUS = "3"',aCdCores[3,1] },;
                        { 'BE4_STATUS = "4"',aCdCores[4,1] }}
//��������������������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE...                                           �
//����������������������������������������������������������������������������
BE4->(DbSetOrder(1))
BE4->(DbSeek(xFilial("BE4")))
BE4->(mBrowse(006,001,022,075,"BE4" , , , , , Nil    , aCores, , , ,nil))
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal...                                               �
//����������������������������������������������������������������������������
Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PLSA182Mov � Autor � Paulo Carnelossi    � Data � 13.06.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Alimentacao da data de internacao              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA182Mov(cAlias,nReg,nOpc)
Local I__f := 0
//��������������������������������������������������������������������������Ŀ
//� Define variaveis de uso generico...                                      �
//����������������������������������������������������������������������������
LOCAL nOpcA      := 0                                                           
LOCAL oDlg                   
LOCAL aCampos    := {}
LOCAL nFor          
LOCAL nPos                    
LOCAL oSay
Local oGet
Local oEncInt  

//��������������������������������������������������������������������������Ŀ
//� Uso na enchoiceBar...                                                    �
//����������������������������������������������������������������������������
LOCAL aButtons   := {}                             
LOCAL bOK        := {|| nOpca := 1,If(.T.,oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
LOCAL bCancel    := {|| oDlg:End() }

LOCAL dDatInt	:= IF(nOpc==K_Incluir,dDataBase,BE4->BE4_DATPRO)
LOCAL cHorInt  := IF(nOpc==K_Incluir,StrTran(Time(),":",""),BE4->BE4_HORPRO)
Local lDataInt := .T.   
Local cSenhaPLS

//��������������������������������������������������������������������������Ŀ
//� Define fonte...                                                          �
//����������������������������������������������������������������������������
Local oFont
LOCAL oFontAutor

If nOpc == K_Incluir .And. ! Empty(BE4->BE4_DATPRO)
   Aviso( "JA GRAVADO", "J� est� alimentada a data de internacao para esta GIH. Utilize a rotina de altera��o!", { "Ok" }, 2 ) 
   Return
ElseIf nOpc == K_Incluir .And. BE4->BE4_STATUS == "3"
   Aviso( "JA GRAVADO", "A guia nao foi autorizada.", { "Ok" }, 2 ) 
   Return
ElseIf nOpc == K_Alterar .And. Empty(BE4->BE4_DATPRO)
   Aviso( "NAO EXISTENTE", "N�o foi alimentada data de internacao para esta GIH. Utilize a rotina de inclus�o!", { "Ok" }, 2 ) 
   Return

ElseIf (nOpc == K_Alterar .OR. nOpc == K_Excluir) .And. A182BQV()
   Aviso( "NAO ALTERAR", "N�o pode ser alterada a data de internacao para esta GIH, por existirem apontamentos de evolu��o de di�rias. Exclua primeiro as evolu��es cadastradas!", { "Ok" }, 2 ) 
   Return

ElseIf nOpc == K_Visualizar .OR. nOpc == K_Excluir
   lDataInt := .F.   
   
EndIf   
//��������������������������������������������������������������������������Ŀ
//� Define fontes utilizadas somente nesta funcao...                         �
//����������������������������������������������������������������������������
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-010 BOLD
                                            
//��������������������������������������������������������������������������Ŀ
//� Monta dados da enchoice...                                               �
//����������������������������������������������������������������������������
Copy "BE4" To Memory

//��������������������������������������������������������������������������Ŀ
//� Monta os campos que serao exibidos para o caso de aut. internacao...     �
//����������������������������������������������������������������������������
STORE FIELDS "BE4" TO aCampos

For nFor := 1 To Len(__aNotCampos)
    nPos := Ascan(aCampos,{|x| x = __aNotCampos[nFor]})
    If nPos > 0
       aDel(aCampos,nPos)
    Endif   
Next

// Cria Dialog...
DEFINE MSDIALOG oDlg TITLE cCadastro FROM ndLinIni,000 TO ndLinFin,ndColFin OF GetWndDefault()

@ 032, 003 GROUP oGrupo TO 073, 393 PIXEL OF oDlg LABEL " "+"Incluir Data de Interna��o" +" "  COLOR CLR_HBLUE, CLR_HRED
@ 045, 070  Say oSay PROMPT "Data da Interna��o" SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE
@ 045, 125  Say oSay PROMPT ": " SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE
@ 042, 130  MSGET oGet VAR dDatInt SIZE 0,0 OF oDlg FONT oFont PICTURE "@D" WHEN lDataInt VALID A360CHEBLO(M->BE4_CODRDA,dDatInt) PIXEL 
@ 045, 220  Say oSay PROMPT "Hora da Interna��o" SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE
@ 045, 275  Say oSay PROMPT ": " SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE
@ 042, 280  MSGET oGet VAR cHorInt SIZE 0,0 OF oDlg FONT oFont PICTURE "@R 99:99" WHEN lDataInt PIXEL 

// Exibe say...
@ 065,287 SAY oSay PROMPT "Internacao Numero   "  SIZE 220,010 OF oDlg PIXEL FONT oFontAutor
@ 065,335 SAY oSay PROMPT BE4->BE4_CODOPE+"."+BE4->BE4_ANOINT+"."+BE4->BE4_MESINT+"."+BE4->BE4_NUMINT SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED FONT oFontAutor
If ! Empty(BE4->BE4_SENHA)
   @ 065,240 SAY oSay PROMPT "Senha "  SIZE 220,010 OF oDlg PIXEL FONT oFontAutor
   @ 065,257 SAY oSay PROMPT BE4->BE4_SENHA SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED FONT oFontAutor
Endif

// Cria Enchoice...
oEncInt := BE4->(MSMGET():New("BE4",BE4->(Recno()),K_Visualizar,,,,aCampos,{075,001,210,393},aCampos,,,,,oDlg,,,.F.))
M->BE4_USUARI := BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)

// Ativa Dialog...
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOK, bCancel, nOpc == K_Excluir, aButtons)

//��������������������������������������������������������������������������Ŀ
//� Busca retorno contido no aRetorno...                                     �
//����������������������������������������������������������������������������
If nOpca == K_OK                       	                  
   If nOpc <> K_Visualizar
   
   	If nOpc == K_Excluir
   		dDatInt := Ctod(Space(8))
   		cHorInt := ""
   	EndIf	
   	
      //��������������������������������������������������������������������������Ŀ
      //� Inicia transacao...                                                      �
      //����������������������������������������������������������������������������
      Begin Transaction
      //��������������������������������������������������������������������������Ŀ
      //� Gravacao dos dados da internacao...                                      �
      //����������������������������������������������������������������������������
      A182BE4(dDatInt, cHorInt, nReg) // Grava Data e Hora Internacao (senha qdo for o caso)
      
      If nOpc == K_Incluir
			A182Final(BE4->BE4_SENHA)
      ElseIf nOpc == K_Excluir
      
      	If BQV->(dbSeek(xFilial("BQV")+BE4->BE4_CODOPE+BE4->BE4_ANOINT+BE4->BE4_MESINT+BE4->BE4_NUMINT))
	      	RecLock("BQV", .F.)
				BQV->(dbDelete())
				MsUnLock()
	   	EndIf
      
      EndIf
      //��������������������������������������������������������������������������Ŀ
      //� Finaliza transacao...                                                    �
      //����������������������������������������������������������������������������
      End Transaction

   Endif   
Endif
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal...                                               �
//����������������������������������������������������������������������������
Return	

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA182LEG � Autor � Paulo Carnelossi    � Data � 13.06.03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Exibe a legenda...                                         ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSA182Leg()
Local aLegenda := { { aCdCores[1,1],aCdCores[1,2] },;
                     { aCdCores[2,1],aCdCores[2,2] },;
                     { aCdCores[3,1],aCdCores[3,2] },;
                     { aCdCores[4,1],aCdCores[4,2] }}
BrwLegenda(cCadastro,"Status" ,aLegenda)
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA182   �Autor  �Microsiga           � Data �  06/17/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A182BQV()
Local aArea  := GetArea(), nCount := 0

BQV->(dbSeek(xFilial("BQV")+BE4->BE4_CODOPE+BE4->BE4_ANOINT+BE4->BE4_MESINT+BE4->BE4_NUMINT))

BQV->(DBEval({|| nCount++},,{||BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT ==;
						xFilial("BQV")+BE4->BE4_CODOPE+BE4->BE4_ANOINT+BE4->BE4_MESINT+BE4->BE4_NUMINT},,,.F.))
RestArea(aArea)

Return(nCount>1)



/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLSSENAUT� Autor � Tulio Cesar            � Data � 01.07.03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Gera uma senha aleatoria de autorizacao de internacao      ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSSenAut(dDataGer)
LOCAL cSenhaPLS	:= ''
LOCAL cLet1		:= ''
LOCAL cLet2		:= ''
LOCAL cLet3		:= ''        
Local nTam		:= TamSx3('BEA_SENHA')[1]   
DEFAULT dDataGer := Date()

If GetNewPar("MV_PLSMSEN","1") == "2"

   cLet1	:= CHR(65+Val(PLSRAND('25')))
   cLet2	:= CHR(65+Val(PLSRAND('25')))
   cLet3	:= CHR(65+Val(PLSRAND('25')))
   
   If VALTYPE(dDataGer) == "C"
   		cStr := cLet1+cLet2+cLet3+Subs(dDataGer,1,2)
   Else
   		cStr := cLet1+cLet2+cLet3+Subs(dtoc(dDataGer),1,2)
   EndIf
   
   cSenhaPLS := IIf( nTam > 5, PLSRAND( Replicate('9',nTam-5), cStr ), '99999')
   
Else
   cSenhaPLS := PLSRAND( Replicate('9',IIf(nTam < 9, 9, nTam ) ) )
Endif

Return(cSenhaPLS)    
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A182Final � Autor � Tulio Cesar          � Data � 01.07.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Exibir a senha de autorizacao de internacao                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Static Function A182Final(cSenhaPLS)
LOCAL oDlg

LOCAL oFontAutor                                    
LOCAL oFontTit
LOCAL oSay                   
//��������������������������������������������������������������������������Ŀ
//� Define fontes utilizadas somente nesta funcao...                         �
//����������������������������������������������������������������������������
DEFINE FONT oFontNum NAME "Arial" SIZE 000,-016 BOLD
DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-019 BOLD

DEFINE MSDIALOG oDlg TITLE "Senha de Autorizacao" FROM 009,000 TO 015,070 OF GetWndDefault()

@ 007,005 SAY oSay PROMPT "Senha   "  SIZE 220,010 OF oDlg PIXEL FONT oFontNum
@ 006,095 SAY oSay PROMPT cSenhaPLS SIZE 220,010 OF oDlg PIXEL FONT oFontAutor COLOR CLR_HRED

ACTIVATE MSDIALOG oDlg CENTERED

Return                                            

Function A182BE4(dDatInt, cHorInt, nReg)
LOCAL nH
   //��������������������������������������������������������������������������Ŀ
   //� Gravacao dos dados da internacao...                                      �
   //����������������������������������������������������������������������������
   BEJ->(DbSetOrder(1))
   BEJ->(DbSeek(xFilial("BEJ")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))
      
   BE4->(dbGoTo(nReg))
   
   nH := PLSAbreSem("P090SEMDEF.SMF")             
   BE4->(RecLock("BE4", .F.))
   BE4->BE4_DATPRO := dDatInt
   BE4->BE4_HORPRO := cHorInt
   If Empty(BE4->BE4_SENHA)          
     	 BE4->BE4_SENHA  := PLSSenAut(dDatInt)
   Endif   
   BE4->(MsUnLock())                          
   PLSFechaSem(nH,"P090SEMDEF.SMF")               

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �VerSis     � Autor � Eduardo Motta        | Data � 08.12.05 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Funcao intermediaria a PLSGETVERSAO para que nao de mensagem���
���          �de funcao nao existe caso a PLSGETVERSAO nao esteja compilad���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function VerSis()
Local nVersao := 7
If FindFunction("PLSGETVERSAO")
   nVersao := PlsGetVersao()
EndIf
Return nVersao

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �29/12/2006���
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
Private aRotina := {	{ STRPL01  ,'AxPesqui'  ,  0 , K_Pesquisar  , 0, .F.},;
											{ STRPL02 ,'PLSA182Mov',  0 , K_Visualizar , 0, Nil},;
											{ STRPL03    ,'PLSA182Mov',  0 , K_Incluir    , 0, Nil},;
											{ STRPL04    ,'PLSA182Mov',  0 , K_Alterar    , 0, Nil},;
											{ STRPL05    ,'PLSA182Mov',  0 , K_Excluir    , 0, Nil},;
											{ "Legenda"    ,"PLSA182LEG",  0 , 0            , 0, .F.} } 
Return(aRotina)
