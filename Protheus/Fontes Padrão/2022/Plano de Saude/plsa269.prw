#include "PROTHEUS.CH"
#include "PLSMGER.CH"   

#DEFINE drCredenciado	"BR_AZUL"
#DEFINE drReembolso		"BR_LARANJA"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA269   �Autor  �Totvs			     � Data �  10/13/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �CADASTRO - DATAS DE PAGAMENTO.                      		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA269() 
PRIVATE aCores   	:= {	{"BXT->BXT_REEMB == '0'",drCredenciado },;
							{"BXT->BXT_REEMB == '1'",drReembolso   }}
PRIVATE aRotina 	:= MenuDef()
PRIVATE cCadastro 	:= "Cadastro de Datas de Pagamento"
//���������������������������������������������������������������������������
//� Validacao
//���������������������������������������������������������������������������
If !PLSALIASEXI("BXT")
	MsgAlert( "N�o � poss�vel utilizar esta rotina! (Execute o compatibilizador da rotina)" )
	Return                                                  
EndIf
//��������������������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                              �
//����������������������������������������������������������������������������
BXT->(DbSetOrder(1)) //BXT_FILIAL+BXT_CODINT+BXT_ANO+BXT_MES+BXT_REEMB
BXT->(DbGoTop())
BXT->(mBrowse(06,01,22,75,"BXT",,,,,,aCores))

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PLSA269MOV� Autor � Totvs			        � Data � 31.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Movimentacao do Cadastro de Datas de Pagamento             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSA269MOV(cAlias,nReg,nOpc)
LOCAL I__f 		  := 0
//��������������������������������������������������������������������������Ŀ
//� Define Variaveis...                                                      �
//����������������������������������������������������������������������������
LOCAL nStackSx8   := GetSx8Len()
LOCAL aAC    	  := {"",""} 
LOCAL nOpca	 	  := 0
LOCAL oDlg
LOCAL aPosObj     := {}
LOCAL aObjects    := {}
LOCAL aSize       := {}
LOCAL aInfo       := {}
LOCAL bOK         := {|| nOpca := 1,If(PLS269OK(nOpc) .And. Obrigatorio(aGets,aTela).And.oGet:TudoOK(),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
LOCAL bCancel     := {||oDlg:End()}	
LOCAL lDtPagto 	  := GETNEWPAR("MV_PLSDTPG",.F.) 		
Local nOpcx        := nOpc 

PRIVATE oEnchoice
PRIVATE oGet
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE aHeader
PRIVATE aCols
PRIVATE aVetTrab  := {}
PRIVATE aChave 	  := {}   

If !lDtPagto .And. nOpc == 3// Inclusao
	MsgStop("� permitido a inclusao de Data de Pagto somente quando o parametro MV_PLSDTPG estiver ativo."+;
	        "Quando ativado, a cria��o do PEG e a rotina de Pagamento M�dico ser�o por Data de Pagto.")
	Return
Endif
//��������������������������������������������������������������������������Ŀ
//� Monta aCols e aHeader...                                                 �
//����������������������������������������������������������������������������
Store Header "BXU" TO aHeader For .T.

If nOpcx == K_Incluir

	Store COLS Blank "BXU" TO aCols FROM aHeader
Else

	BXU->(DbSetOrder(1))
	If !BXU->(MsSeek(xFilial("BXU")+BXT->(BXT_CODINT+BXT_ANO+BXT_MES+BXT_REEMB)))                                                                                                                  
		Store COLS Blank "BXU" TO aCols FROM aHeader
	Else 
		Store COLS "BXU" TO aCols FROM aHeader VETTRAB aVetTrab ;
		While BXU->(BXU_FILIAL+BXU_CODINT+BXU_ANO+BXU_MES+BXU_REEMB) == BXT->(BXT_FILIAL+BXT_CODINT+BXT_ANO+BXT_MES+BXT_REEMB)
	EndIf
	
	
   If Len(aCols) == 0
      Store COLS Blank "BXU" TO aCols FROM aHeader
   EndIf
   
EndIf

//��������������������������������������������������������������������������Ŀ
//� Define Dialogo...                                                        �
//����������������������������������������������������������������������������
aSize := MsAdvSize()
AAdd( aObjects, { 50, 50, .T., .T. } )
AAdd( aObjects, { 200, 200, .T., .T. } )
aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T. )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL       
If nOpcx == K_Incluir
	Copy "BXT" TO Memory Blank
Else
	Copy "BXT" TO MEMORY
Endif

CursorWait()
//��������������������������������������������������������������������������Ŀ
//� Monta Echoice ...                                                        �
//����������������������������������������������������������������������������
oEnchoice := MSMGET():New(cAlias,nReg,nOpcx,,,,,aPosObj[1],,,,,,oDlg,,,.F.)  
//��������������������������������������������������������������������������Ŀ
//� Monta GetDados ...                                                       �
//����������������������������������������������������������������������������
oGet    := TPLSBrw():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],nil,oDlg      ,nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aHeader,aCols  ,.F.,"BXU",nOpcx,PLSRetTit("BXU")                             ,nil,nil,nil,aVetTrab,'PL269VAL','PL269DEL')
//��������������������������������������������������������������������������Ŀ
//� Ativa o Dialogo...                                                       �
//����������������������������������������������������������������������������
ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,bOk,bCancel,.F.,{})  })
//��������������������������������������������������������������������������Ŀ
//� Rotina de gravacao dos dados...                                          �
//����������������������������������������������������������������������������
If nOpca == K_OK
   If nOpcx <> K_Visualizar 
       BXT->(DbGoTo(nReg))  
   PLUPTENC("BXT",nOpc)   
   
   aChave := {	{"BXU_CODINT"	,M->BXT_CODINT	},;
   				{"BXU_ANO"		,M->BXT_ANO		},;
				{"BXU_MES"		,M->BXT_MES		},;
				{"BXU_REEMB"	,M->BXT_REEMB	} }

   oGet:Grava(aChave) 
EndIf
EndIf
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina...                                                         �
//����������������������������������������������������������������������������
Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Totvs			        � Data �13/10/2010���
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
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()     

aRotina := {{ 'Pesquisar' 	, 'AxPesqui'   , 0 , K_Pesquisar	,0 ,.F.},; 
            { 'Visualizar' 	, 'PLSA269MOV' , 0 , K_Visualizar	,0 ,Nil},; 
            { 'Incluir' 	, 'PLSA269MOV' , 0 , K_Incluir		,0 ,Nil},; 
            { 'Alterar' 	, 'PLSA269MOV' , 0 , K_Alterar		,0 ,Nil},; 
            { 'Excluir'		, 'PLSA269MOV' , 0 , K_Excluir		,0 ,Nil},;
            { 'Legenda'		, 'PLSA269LEG' , 0 , 0				,0 ,Nil}}    

Return(aRotina)          
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA269LEG�Autor  �Totvs			     � Data � 19/06/2010  ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao que exibe na tela o status da solicitacao de compras,���
���          �indicando cada situacao com uma cor.                        ���
�������������������������������������������������������������������������͹��
���Uso       �PROTHEUS 11 - PLANO DE SAUDE                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA269LEG()
Local cCadLeg := "Tipo de pagamento"

BrwLegenda(cCadLeg		,"Tipo de pagamento" 	  ,;
		   {{drCredenciado	,"Pagamento Credenciado"} ,;
		    {drReembolso	,"Pagamento Reembolso"	} })

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PL269VAL  �Autor  �Totvs			     � Data �  10/13/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �VALIDACAOES DA GET DADOS                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PL269VAL()
LOCAL lRet		:= .T.
LOCAL aFeriados	:= RetFeriados()
LOCAL nPos		:= 0
LOCAL nCompet	:= GetMv("MV_PLSQTDT")	
//��������������������������������������������������������������������������Ŀ
//� Verifica se a data de pagemento eh sabado, domingo ou feriado.           �
//����������������������������������������������������������������������������
lRet := PLVLDSD(M->BXU_DATPAG)
//��������������������������������������������������������������������������Ŀ
//� Verifica se a data de pagamento eh maior que o mes da competencia.       �
//����������������������������������������������������������������������������
If StrZero(YEAR(M->BXU_DATPAG),4)+StrZero(MONTH(M->BXU_DATPAG),2) < M->BXT_ANO+M->BXT_MES
    Aviso('Aviso',"A data de pagamento n�o pode ser  menor que a compet�ncia cadastrada acima",{"Ok"},2,"")      
	lRet:=.F.
Endif	
//��������������������������������������������������������������������������Ŀ
//� Verifica se a data de pagamento ja foi usada em competencia anterior     �
//����������������������������������������������������������������������������
BXU->( DbSetOrder(3) )//BXU_FILIAL+BXU_CODINT+DTOS(BXU_DATPAG)+BXU_REEMB
If BXU->(msSeek(xFilial("BXU")+M->BXT_CODINT+DtoS(M->BXU_DATPAG)+Alltrim(M->BXT_REEMB)))
    Aviso('Aviso',"A data de pagamento ja foi cadastrada em competencia anterior",{"Ok"},2,"")     
	lRet:=.F.
EndIf	
//��������������������������������������������������������������������������Ŀ
//� Verifica se a data de pagamento cadastrada eh maior que a anterior.      �
//����������������������������������������������������������������������������
nPos := PLRETPOS("BXU_DATPAG",aHeader)
If Ascan(aCols,{ |x| M->BXU_DATPAG <= x[nPos] }) > 0 
	Aviso('Aviso',"Esta data deve ser maior que a data de pagamento anterior.",{"Ok"},2,"")  
	lRet:=.F.
EndIf  
//��������������������������������������������������������������������������Ŀ
//� Verificar a quantidade de competencias que poderao ser cadastradas.      �
//����������������������������������������������������������������������������
If nCompet <> 0 
	If Val(M->BXU_NUMDAT) > nCompet
		Aviso('Aviso',"O par�metro MV_PLSQTDT est� configurado para receber apenas" + Alltrim(STR(nCompet)) + "datas por compet�ncia.",{"Ok"},2,"")  
		lRet:=.F.
   	EndIf
EndIf	
//����������������������������������������������������������������������������
//� Fim da Rotina
//����������������������������������������������������������������������������
Return(lRet) 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLS269OK  �Autor  �Totvs			     � Data �  10/13/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �VALIDACAOES DA TELA	                                      ���
�������������������������������������������������������������������������͹��
���Uso       �PROTHEUS 11 - PLANO DE SAUDE                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLS269OK(nOpc)
Local lRet		:= .T.
//�������������������������������������������������������������������������������������Ŀ
//� Evita a duplic. da chave: BXT_FILIAL+BXT_CODINT+BXT_ANO+BXT_MES+BXT_REEMB	  		�
//���������������������������������������������������������������������������������������
If nOpc == 3 // Incluir
	BXT->(dbSetOrder(1))
	If BXT->(MsSeek(xFilial("BXT")+M->BXT_CODINT+M->BXT_ANO+M->BXT_MES+M->BXT_REEMB))
		Aviso('Aviso',"Confirma��o n�o permitida devido existir a compet�ncia "+ M->BXT_MES + "/" + M->BXT_ANO +" do tipo "+IIF(M->BXT_REEMB=="1","Reembolso","Credenciado")+" j� cadastrada!",{"Ok"},2,"")  
		lRet:=.F.
	EndIf
Endif

Return(lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSBXUDAT �Autor  �Totvs			     � Data �  10/13/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �VALIDACAOES campo Data Pagto                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSBXUDAT(dData,nOpc,lDel)
LOCAL lRet	   	:= .T.
LOCAL cSQL     	:= ""
LOCAL aArea    	:= GetArea() 
DEFAULT nOpc	:= K_Alterar
DEFAULT lDel	:= .F.                 

If !Empty(dData)
	cSQL := "SELECT R_E_C_N_O_  RecnoBDT FROM "+RetSQLName("BDT")+" "
	cSQL += " WHERE BDT_FILIAL = '"+ xFilial("BDT") +"' AND "
	cSQL += " BDT_CODINT  = '"+ M->BXT_CODINT 	+"' AND "
	cSQL += " BDT_ANO 	  = '"+ M->BXT_ANO 		+"' AND "
	cSQL += " BDT_MES     = '"+ M->BXT_MES 		+"' AND "
	cSQL += " BDT_REEMB   = '"+ M->BXT_REEMB 	+"' AND "
	cSQL += " BDT_DATPAG  = '"+ DtoS(dData) 	+"' AND "
	cSQL += " D_E_L_E_T_  = ''"
	 		
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBDT",.F.,.T.)
	
	If TrbBDT->( !Eof() )
		lRet := .F.       
		Aviso('Aviso','Data de Pagamento ja atribu�da a um Calend�rio de pagamento.',{"Ok"},2,"")
	EndIf
	
	TrbBDT->(dbCloseArea())
EndIf
	
RestArea(aArea)

Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSBXUDAT �Autor  �Totvs			     � Data �  10/13/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �VALIDACAOES campo Data Pagto                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PL269DEL()
LOCAL lRet := .T.
//���������������������������������������������������������������������������������������
//� Verifica se pode excluir
//���������������������������������������������������������������������������������������
lRet := PLSBXUDAT(BXU->BXU_DATPAG,K_Excluir,.T.) 
//���������������������������������������������������������������������������������������
//� Fim da Rotina
//���������������������������������������������������������������������������������������
Return(lRet)	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLVLDSD   �Autor  �Totvs			     � Data �  10/13/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �VALIDACAOES campo Data Pagto                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLVLDSD(dData)
LOCAL aFeriados	:= RetFeriados()
LOCAL lRet		:= .T.
//����������������������������������������������������������������������������
//� Verifica se a data eh sabado, domingo ou feriado.
//����������������������������������������������������������������������������
If Alltrim(Str(Dow(dData))) $ "7/1" .Or. ( aScan( aFeriados , DtoS(dData) ) > 0 )
	Aviso('Aviso',"A data n�o pode ser Sabado, Domingo ou Feriado",{"Ok"},2,"")       
	lRet:=.F.
EndIf
//����������������������������������������������������������������������������
//� Fim da Rotina
//����������������������������������������������������������������������������
Return lRet
