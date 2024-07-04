#INCLUDE "PCOA171.ch"
#INCLUDE "PROTHEUS.CH"

STATIC _cTipoDB := Alltrim(Upper(TCGetDB()))

/*/
_F_U_N_C_����������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � PCOA171  � AUTOR � Paulo Carnelossi      � DATA � 16/11/2004 ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Programa de manutecao dos conta orc ger.orcamentaria         ���
���������������������������������������������������������������������������Ĵ��
��� USO      � SIGAPCO                                                      ���
���������������������������������������������������������������������������Ĵ��
���_DOCUMEN_ � PCOA171                                                      ���
���_DESCRI_  � Programa de manutecao dos CO da planilha orcamentaria        ���
���_FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal a  ���
���          � partir do Menu ou a partir de uma funcao pulando assim o     ���
���          � browse principal e executando a chamada direta da rotina     ���
���          � selecionada.                                                 ���
���          � Exemplos: PCOA171(2) - Executa a chamada da funcao de visua- ���
���          �                        zacao da rotina.                      ���
���          �           PCOA171()  - Executa a chamada da funcao pela      ���
���          �                        mBrowse.                              ���
���������������������������������������������������������������������������Ĵ��
���_PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PCOA171(nCallOpcx,aGetCpos,cNivelCO)
Local nRecAKO

//���������������������������������������������������������Ŀ
//� Salva a interface.                                      �
//�����������������������������������������������������������
SaveInter()

PRIVATE cCadastro	:= STR0001 //"Visao Gerencial Orcamentaria - Contas Gerenciais Orcamentarias "
Private aRotina := MenuDef()

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	If nCallOpcx == Nil
		mBrowse(6,1,22,75,"AKO")
	Else
		cNivelCO	:= Soma1(cNivelCO)
		nRecAKO		:= Pco171Dlg("AKO",AKO->(RecNo()),nCallOpcx,,,aGetCpos,cNivelCO)
	EndIf
EndIf
//���������������������������������������������������������Ŀ
//� Restaura a interface.                                   �
//�����������������������������������������������������������
RestInter()
Return nRecAKO

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Pco171Dlg� Autor � Paulo Carnelossi       � Data � 16/11/2004 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Inclusao,Alteracao,Visualizacao e Exclusao       ���
���          � de contas gerenciais orcamentarias.                          ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function Pco171Dlg(cAlias,nReg,nOpcx,xReserv,yReserv,aGetCpos,cNivelCO)

Local l171Inclui	:= .F.
Local l171Visual	:= .F.
Local l171Altera	:= .F.
Local l171Exclui	:= .F.
Local lContinua		:= .T.

Local oDlg

Local nRecAKO
Local nOpc			:= 0
Local nX			:= 0

Local aCampos		:= {}
Local aSize			:= {}
Local aObjects		:= {}                                                            
Local aButtons      := {}

PRIVATE oEnch

DEFAULT cNivelCO := "001"

//���������������������������������������������������������Ŀ
//� Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  �
//�����������������������������������������������������������
Do Case                              
	Case aRotina[nOpcx][4] == 2
		l171Visual := .T.
		Inclui := .F.
		Altera := .F.
	Case aRotina[nOpcx][4] == 3
		l171Inclui	:= .T.
		Inclui := .T.
		Altera := .F.
	Case aRotina[nOpcx][4] == 4
		l171Altera	:= .T.
		Inclui := .F.
		Altera := .T.
	Case aRotina[nOpcx][4] == 5
		l171Exclui	:= .T.
		l171Visual	:= .T.
EndCase


//��������������������������������������������������������Ŀ
//� Trava o registro do AKO - Alteracao,Visualizacao       �
//����������������������������������������������������������
If l171Altera.Or.l171Exclui
	If !SoftLock("AKO")
		lContinua := .F.
	Else
		nRecAKO := AKO->(RecNo())
		If l171Exclui .And. ! Pcoa171CanExcl()
			lContinua := .F.
		EndIf
	Endif
EndIf  


If lContinua
	//��������������������������������������������������������������Ŀ
	//� Carrega as variaveis de memoria AKO                          �
	//����������������������������������������������������������������
	RegToMemory("AKO",l171Inclui)
	If l171Inclui
		M->AKO_NIVEL := cNivelCO
	EndIf
	//��������������������������������������������������������������������Ŀ
	//� Tratamento do array aGetCpos com os campos Inicializados do AKO    �
	//����������������������������������������������������������������������
	If aGetCpos <> Nil
		aCampos	:= {}
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AKO")
		While !Eof() .and. SX3->X3_ARQUIVO == "AKO"
			IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
				nPosCpo	:= aScan(aGetCpos,{|x| x[1]==Alltrim(X3_CAMPO)})
				If nPosCpo > 0
					If aGetCpos[nPosCpo][3]
						aAdd(aCampos,AllTrim(X3_CAMPO))
					EndIf
				Else
					aAdd(aCampos,AllTrim(X3_CAMPO))
				EndIf
			EndIf
			dbSkip()
		End
		For nx := 1 to Len(aGetCpos)
			cCpo	:= "M->"+Trim(aGetCpos[nx][1])
			&cCpo	:= aGetCpos[nx][2]
		Next nx
	EndIf

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO TranslateBottom(.F.,28),80 OF oMainWnd
		
	oEnch := MsMGet():New("AKO",AKO->(RecNo()),nOpcx,,,,,{,,(oDlg:nClientHeight - 4)/2,},If(Empty(aCampos),NIL,aCampos),3,,,,oDlg)
	oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
		
	//������������������������������������������������������������������������Ŀ
	//� Adiciona botoes do usuario no Browse                                   �
	//��������������������������������������������������������������������������
	If ExistBlock( "PCOA1712" )
		//P_E�������������������������������������������������������������������������Ŀ
		//P_E� Ponto de entrada utilizado para inclusao de botoes de usuario na toolbar�
		//P_E� da tela de itens do orcamento.                                          �
		//P_E� Parametros : Nenhum                                                     �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na toolbar   �
		//P_E�               Ex. :  User Function PCOA1712                             �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}              �
		//P_E���������������������������������������������������������������������������
		aButtons:= ExecBlock("PCOA1712",.F.,.F.)
	EndIf
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(	Obrigatorio(oEnch:aGets,oEnch:aTela).And.oGD:TudoOk(),(nOpc:=1,oDlg:End()),Nil)},{||oDlg:End()},,aButtons)
EndIf


If (nOpc == 1) .And. (l171Inclui .Or. l171Altera .Or. l171Exclui)
	Begin Transaction
		PCO171Grava(l171Altera,l171Exclui,@nRecAKO)
    End Transaction
EndIf

Return nRecAKO

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PCO171Grava� Autor � Paulo Carnelossi     � Data � 16/11/2004 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Faz a gravacao da conta orcamentaria gerencial                ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �PCOA171                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PCO171Grava(lAltera,lDeleta,nRecAKO)
Local bCampo 	:= {|n| FieldName(n) }
Local nX		:= 0

If !lDeleta
	//������������������������������������������������������Ŀ
	//� Grava o arquivo AKO                                  �
	//��������������������������������������������������������
	If lAltera
		AKO->(dbGoto(nRecAKO))
		RecLock("AKO",.F.)
	Else
		RecLock("AKO",.T.)
	EndIf
	For nx := 1 TO FCount()
		FieldPut(nx,M->&(EVAL(bCampo,nx)))
	Next nx
	AKO->AKO_FILIAL := xFilial("AKO")
	MsUnlock()	
	nRecAKO	:= AKO->(RecNo())

Else
	AKO->(dbGoto(nRecAKO))
	RecLock("AKO",.F.,.T.)
	dbDelete()
	MsUnlock()
EndIf

Return

Static Function MenuDef()
Local aRotina 	:= {	{ STR0002, "AxPesqui"  , 0 , 1},;  //"Pesquisar"
							{ STR0003, "PCO171Dlg", 0 , 2},;  //"Visualizar"
							{ STR0004, "PCO171Dlg", 0 , 3 },;  //"Incluir"
							{ STR0005, "PCO171Dlg", 0 , 4 },;  //"Alterar"
							{ STR0006, "PCO171Dlg", 0 , 5 }}  //"Excluir"
							
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//������������������������������������������������������������������������Ŀ
	//� Adiciona botoes do usuario no Browse                                   �
	//��������������������������������������������������������������������������
	If ExistBlock( "PCOA1711" )
		//P_E������������������������������������������������������������������������Ŀ
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de orcamentos                                           �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA1711                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E��������������������������������������������������������������������������
		If ValType( aUsRotina := ExecBlock( "PCOA1711", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Pcoa171CanExcl�Autor  �Microsiga       � Data �  12/17/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se nao tem dependencia amarrada a conta            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Pcoa171CanExcl()
Local aArea := GetArea()
Local lRet := .T.
Local cQuery := ""
Local _lOracle
Local _lInformix
Local _lDB2

_lOracle	:= "ORACLE"   $ _cTipoDB
_lDB2		:= "DB2"      $ _cTipoDB
_lInformix 	:= "INFORMIX"   $ _cTipoDB

//verifica se a conta eh sintetica e se tem conta abaixo dela
If _lOracle .Or. _lInformix
	cQuery += " SELECT NVL( COUNT(AKO_CO), 0) QTDCO FROM "+RetSqlName("AKO") 
ElseIf  _lDB2 
	cQuery += " SELECT COALESCE( COUNT(AKO_CO), 0) QTDCO FROM "+RetSqlName("AKO") 
Else
	cQuery += " SELECT ISNULL( COUNT(AKO_CO), 0) QTDCO FROM "+RetSqlName("AKO") 
EndIf

cQuery += " WHERE AKO_FILIAL = '"+xFilial("AKO")+"' "
cQuery += " AND AKO_CODIGO = '"+AKO->AKO_CODIGO+"' "
cQuery += " AND AKO_COPAI = '"+AKO->AKO_CO+"' "
cQuery += " AND D_E_L_E_T_  = ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea( .t., "TOPCONN", Tcgenqry( , , cQuery ), "AKOCG", .F., .T. )

lRet := AKOCG->( QTDCO == 0 )
AKOCG->( dbCloseArea() )

If !lRet
	Aviso(STR0007, STR0008, {"Ok"})  //"Atencao"##"Conta com dependencias, primeiro deve excluir as contas amarradas."
EndIf

RestArea(aArea)

Return(lRet)
