#INCLUDE "PCOA171.ch"
#INCLUDE "PROTHEUS.CH"

STATIC _cTipoDB := Alltrim(Upper(TCGetDB()))

/*/
_F_U_N_C_苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲UNCAO    � PCOA171  � AUTOR � Paulo Carnelossi      � DATA � 16/11/2004 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰ESCRICAO � Programa de manutecao dos conta orc ger.orcamentaria         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� USO      � SIGAPCO                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡DOCUMEN_ � PCOA171                                                      潮�
北砡DESCRI_  � Programa de manutecao dos CO da planilha orcamentaria        潮�
北砡FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal a  潮�
北�          � partir do Menu ou a partir de uma funcao pulando assim o     潮�
北�          � browse principal e executando a chamada direta da rotina     潮�
北�          � selecionada.                                                 潮�
北�          � Exemplos: PCOA171(2) - Executa a chamada da funcao de visua- 潮�
北�          �                        zacao da rotina.                      潮�
北�          �           PCOA171()  - Executa a chamada da funcao pela      潮�
北�          �                        mBrowse.                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PCOA171(nCallOpcx,aGetCpos,cNivelCO)
Local nRecAKO

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Salva a interface.                                      �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
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
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Restaura a interface.                                   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
RestInter()
Return nRecAKO

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲un噮o    砅co171Dlg� Autor � Paulo Carnelossi       � Data � 16/11/2004 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噮o � Programa de Inclusao,Alteracao,Visualizacao e Exclusao       潮�
北�          � de contas gerenciais orcamentarias.                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Generico                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
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


//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Trava o registro do AKO - Alteracao,Visualizacao       �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Carrega as variaveis de memoria AKO                          �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	RegToMemory("AKO",l171Inclui)
	If l171Inclui
		M->AKO_NIVEL := cNivelCO
	EndIf
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Tratamento do array aGetCpos com os campos Inicializados do AKO    �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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
		
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Adiciona botoes do usuario no Browse                                   �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If ExistBlock( "PCOA1712" )
		//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//P_E� Ponto de entrada utilizado para inclusao de botoes de usuario na toolbar�
		//P_E� da tela de itens do orcamento.                                          �
		//P_E� Parametros : Nenhum                                                     �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na toolbar   �
		//P_E�               Ex. :  User Function PCOA1712                             �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}              �
		//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
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
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲un噮o    砅CO171Grava� Autor � Paulo Carnelossi     � Data � 16/11/2004 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噮o 矲az a gravacao da conta orcamentaria gerencial                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      砅COA171                                                       潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PCO171Grava(lAltera,lDeleta,nRecAKO)
Local bCampo 	:= {|n| FieldName(n) }
Local nX		:= 0

If !lDeleta
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Grava o arquivo AKO                                  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Adiciona botoes do usuario no Browse                                   �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If ExistBlock( "PCOA1711" )
		//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de orcamentos                                           �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA1711                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		If ValType( aUsRotina := ExecBlock( "PCOA1711", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砅coa171CanExcl篈utor  矼icrosiga       � Data �  12/17/12   罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     砎erifica se nao tem dependencia amarrada a conta            罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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
