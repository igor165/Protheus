#include "PROTHEUS.CH"
#include "PLSA070.CH"
#include "PLSMGER.CH"
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA070 � Autor � Tulio Cesar            � Data � 31.03.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Cadastro de Doencas                                        ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSA070()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial.                              ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
��� 20.02.01 � XXXX � Tulio Cesar � Tratar nao poder excluir se houver    ����
���          �      �             � movimentacao.                         ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSA070
//��������������������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                               �
//����������������������������������������������������������������������������
PRIVATE aRotina 	:= MenuDef()
PRIVATE cCadastro := Fundesc()
//��������������������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                              �
//����������������������������������������������������������������������������
BA9->(DbSetOrder(1))
BA9->(DbGoTop())
BA9->(mBrowse(06,01,22,75,"BA9"))
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal                                                  �
//����������������������������������������������������������������������������
Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PL070MOV � Autor � Tulio Cesar           � Data � 31.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Movimentacao do Cadastro de Doencas                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PL070MOV(cAlias,nReg,nOpc)
Local I__f := 0
//��������������������������������������������������������������������������Ŀ
//� Define Variaveis...                                                      �
//����������������������������������������������������������������������������
LOCAL	aAC    := { STR0003 , STR0001  }
LOCAL nOpca	 := 0
LOCAL oDlg
LOCAL aPosObj   := {}
LOCAL aObjects  := {}
LOCAL aSize     := {}
LOCAL aInfo     := {}
Local lEspelhar := GetNewPar("MV_INTCID ",.F.)
Local lNovGAS	:=.T.
Local lAchou	:=.F.

PRIVATE oEnchoice
PRIVATE oGet
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE aHeader
PRIVATE aCols
PRIVATE aVetTrab := {}
PRIVATE aChave := {}
//��������������������������������������������������������������������������Ŀ
//� Monta aCols e aHeader...                                                 �
//����������������������������������������������������������������������������
Store Header "BAA" TO aHeader For .T.
If nOpc == K_Incluir
	Copy "BA9" TO Memory Blank
	Store COLS Blank "BAA" TO aCols FROM aHeader
Else
	Copy "BA9" TO MEMORY
	
	BAA->(DbSetOrder(1))
	If BAA->(MsSeek(xFilial("BAA")+BA9->BA9_CODDOE))
		Store COLS "BAA" TO aCols FROM aHeader VETTRAB aVetTrab While BAA->(BAA_FILIAL+BAA_CODDOE) == BA9->(BA9_FILIAL+BA9_CODDOE)
	Else
		Store COLS Blank "BAA" TO aCols FROM aHeader
	EndIf
EndIf
//��������������������������������������������������������������������������Ŀ
//� Define Dialogo...                                                        �
//����������������������������������������������������������������������������

aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T. )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5]of oMainWnd PIXEL
oEnchoice := MSMGET():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,,.F.)
//��������������������������������������������������������������������������Ŀ
//� Monta GetDados ...                                                       �
//����������������������������������������������������������������������������

If Val(GetVersao(.F.)) >= 12 // Caso a versao seja maior ou igual a 12
	aDifSize:= {,,,,35,3,,}
	oGet := TPLSBrw():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],nil,oDlg,nil,,nil,nil,nil,.T.,nil,.T.,nil,aHeader,aCols,.F.,"BAA",nOpc,PLSRetTit("BAA"),nil,nil,nil,,,,,,,,,,,,,,aDifSize)
Else
	oGet := TPLSBrw():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],nil,oDlg,nil,,nil,nil,nil,.T.,nil,.T.,nil,aHeader,aCols,.F.,"BAA",nOpc,PLSRetTit("BAA"))
EndIf

oGet:aVetTrab := aClone(aVetTrab)
//��������������������������������������������������������������������������Ŀ
//� Ativa o Dialogo...                                                       �
//���������������������������������������������������������������������������� 



ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,{|| nOpca := 1,If(Obrigatorio(aGets,aTela).And.oGet:TudoOK(),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) },{||oDlg:End()},.F.,{})  })
//��������������������������������������������������������������������������Ŀ
//� Rotina de gravacao dos dados...                                          �
//����������������������������������������������������������������������������
If nOpca == K_OK
	//��������������������������������������������������������������������������Ŀ
	//� No caso de exclusao verifico se houve movimentacao...                    �
	//����������������������������������������������������������������������������
	If nOpc == K_Excluir
		//No nomento nao irei tratar pois tera de ser criada uma chave por este campo na tabela de movimentacao.
	Endif
	
	If nOpc == K_Incluir
		If lEspelhar
			If  ! Empty(M->BA9_CODDOE)
				DbSelectarea ("GAS")
				GAS->(DbSetOrder(1))
				lNovGAS := (GAS->(MsSeek(xFilial("GAS")+M->BA9_CODDOE)))
			Else
				lNovGAS := .T.
			Endif
		Endif
		
		If  ! LNovGAS
			DbSelectarea ("BBL")
			BBL->(DbSetOrder(2))
			If 	BBL->(MsSeek(xFilial("BBL")+"PLSA070   "+"BA9"+"GAS"))
				RecLock("GAS", .T.)
				GAS->GAS_FILIAL := xFilial("GAS")
				PlsSinc("PLSA070   ","BA9","GAS")
				GAS->GAS_LOGARQ := HS_LOGARQ()
				MsUnlock()
			Else
				If GetNewPar("MV_PLSMSGS","1") == "1"
					MsgAlert(OemtoAnsi(STR0012)) //"Arquivo de sincronismo entre BA9 x GAS nao esta integro. Verifique!"
				Endif
			Endif
		Endif
	ElseIf nOpc == K_Alterar
		If lEspelhar
			DbSelectarea ("GAS")
			GAS->(DbSetOrder(1))
			If BA9->(FieldPos("BA9_REFIGH"))>0
				If !Empty(M->BA9_REFIGH) .and.  GAS->(MsSeek(xFilial("GAS")+M->BA9_REFIGH))  //Verifique se Existe  Relacionamento Tabela do Gest�o Hospitalar p Realizar Sincronismo
					lAchou:= PLSAVERGH(M->BA9_REFIGH) // Verifica se Poder� ser Sincronizado o Codigo no Gest�o Hospitalar
				Else
					lAchou:= GAS->(MsSeek(xFilial("GAS")+M->BA9_CODDOE))
				Endif
				If lAchou
					DbSelectarea ("BBL")
					BBL->(DbSetOrder(2))
					If 	BBL->(MsSeek(xFilial("BBL")+"PLSA070   "+"BA9"+"GAS"))
						RecLock("GAS", .F.)
						PlsSinc("PLSA070   ","BA9","GAS")
						GAS->GAS_LOGARQ := HS_LOGARQ()
						MsUnlock()
					Else
						If GetNewPar("MV_PLSMSGS","1") == "1"
							MsgAlert(OemtoAnsi(STR0012)) //"Arquivo de sincronismo entre BA9 x GAS nao esta integro. Verifique!"
						Endif
						
					Endif
				Endif
			Endif
		Endif
		
	ElseIf nOpc == K_Excluir
		If lEspelhar
			DbSelectarea ("GAS")
			GAS->(DbSetOrder(1))
			If GAS->(MsSeek(xFilial("GAS")+M->BA9_CODDOE)) .and. PLSAVERGH(M->BA9_CODDOE)
				DbSelectarea ("BBL")
				BBL->(DbSetOrder(2))
				If BBL->(MsSeek(xFilial("BBL")+"PLSA070   "+"BA9"+"GAS"))
					RecLock("GAS", .F.)
					DbDelete()
					MsUnlock()
				Else
					If GetNewPar("MV_PLSMSGS","1") == "1"
						MsgAlert(OemtoAnsi(STR0012)) //"Arquivo de sincronismo entre BA9 x GAS nao esta integro. Verifique!"
					Endif
				Endif
				
			Endif
		Endif
		
	EndIf
	
	PLUPTENC("BA9",nOpc)
	
	aChave := { {"BAA_CODDOE",M->BA9_CODDOE} }
	
	oGet:Grava(aChave)
	
	
Endif
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina...                                                         �
//����������������������������������������������������������������������������
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PLSAVERGH� Autor �				        � Data � 18/08/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validacao  do Sincronismo do CID                ���
��� Verifica se o Cid do Gest�o Hospitalar pode ser Alterado ou Excluido  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/        

Static Function PLSAVERGH (cCodCid)
Local aArea := GetArea()
Local lRet	 := .T.

If HS_CountTB("GHH", "GHH_CODCID = '" + cCodCid+ "'")  > 0
	HS_MsgInf(STR0013,STR0014, STR0011) //""O Cid Referente  ao Gest�o Hospitalar n�o sofrer� Altera��es pois possue Relacionamento com Procedimento"  ",###"Cadastro de Doen�a"###"Sincronismo"
    lRet := .F.							
Endif


RestArea(aArea)
Return(lRet)



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �26/12/2006���
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
Private aRotina := {	{ STR0004 , 'AxPesqui' , 0 , K_Pesquisar	,0 ,.F.},; //'Pesquisar'
                      { STR0005 , 'PL070MOV' , 0 , K_Visualizar	,0 ,Nil},; //'Visualizar'
                      { STR0006 , 'PL070MOV' , 0 , K_Incluir		,0 ,Nil},; //'Incluir'
                      { STR0007 , 'PL070MOV' , 0 , K_Alterar		,0 ,Nil},; //'Alterar'
                      { STR0008 , 'PL070MOV' , 0 , K_Excluir		,0 ,Nil} } //'Excluir'
Return(aRotina)
