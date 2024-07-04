#include "msmgadd.ch"
#INCLUDE "protheus.ch"

/*
_F_U_N_C_����������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � PCOA482  � AUTOR � Acacio Egas           � DATA � 30/04/08   ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Programa para manutencao do relacionamento de Partida/Contra ���
���������������������������������������������������������������������������Ĵ��
��� USO      � SIGAPCO                                                      ���
���������������������������������������������������������������������������Ĵ��
���_DOCUMEN_ � PCOA482                                                      ���
���_DESCRI_  � Programa para manutencao do Relacionamento de Partida/Contra ���
���_FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    ���
���          � partir do Menu ou a partir de uma funcao pulando assim o     ���
���          � browse principal e executando a chamada direta da rotina     ���
���          � selecionada.                                                 ���
���          � Exemplo: PCOA482(2) - Executa a chamada da funcao de visua-  ���
���          �                        zacao da rotina.                      ���
���������������������������������������������������������������������������Ĵ��
���_PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static aRecnos

Function PCOA482(nCallOpcx, lAuto, lProc)

Local xOldInt
Local lOldAuto
Local lRet := .T.

Default lProc := .F.

Private cTipo := '2'

If lAuto
	If Type('__cInternet') != 'U'
		xOldInt := __cInternet
	EndIf
	If Type('lMsHelpAuto') != 'U'
		lOldAuto := lMsHelpAuto
	EndIf
	lMsHelpAuto := .T.
	If !lProc
		__cInternet := 'AUTOMATICO'
	Endif	
EndIf

Private cCadastro	:= "Relacionamento Partida/Contra"
Private aRotina := MenuDef()

dbSelectArea("AM8")
dbSetOrder(1)

	If nCallOpcx <> Nil
		lRet := A482DLG("AM8",AM8->(RecNo()),nCallOpcx,lAuto)
	Else
		mBrowse(6,1,22,75,"AM8",,,,,,,,,,,,,,"AM8_TIPO='" + cTipo + "'")
	EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A482DLG   �Autor  �Acacio Egas         � Data �  04/30/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Dialog para montar MsmGet com Alguns campos.               ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAPCO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A482DLG(cAlias,nReg,nOpc,lAuto)

Local nOkOpc := 3
Local aCampos,aCpos
LOcal _nX,_nI
Local aCposAM8
Local lInc
Local aCordW 	:= {0,0,305,635}

Default nReg := AM8->(Recno())
Default lAuto:= .F.

INCLUI 	:= nOpc==3
ALTERA 	:= nOpc==4
EXCLUI 	:= nOpc==5

aRecnos := {}

aCposAM8 := GetaHeader("AM8",,)
RegToMemory("AM8",INCLUI)

aHeader := GetaHeader("AM9",,)
aCols := {}

// Monta aCols
If !INCLUI
	DbSelectArea("AM8")
	DbGoTo(nReg)
	DbSelectArea("AM9")
	DbSetOrder(1)
	DbSeek(xFilial("AM9")+AM8->AM8_ID)
	Do While !Eof() .and. AM9->AM9_ID==AM8->AM8_ID
		aAdd( aCols , Array(Len(aHeader)+1) )
		AEval(aHeader, {|x,y| aCols[Len(aCols)][y] := If(Alltrim(x[2])$"AM9_ALI_WT|AM9_REC_WT",NIL,If(x[10]='V',CriaVar(AllTrim(x[2])),FieldGet(FieldPos(x[2])) ) ) })
		aCols[Len(aCols),Len(aHeader)+1] := .F.			
		aAdd( aRecnos , RECNO() )
		DbSkip()
	EndDo
EndIf

// Cria Linha em branco no aCols zerado
If Len(aCols)=0
	aAdd( aCols , Array(Len(aHeader)+1) )
	AEval(aHeader, {|x,y| aCols[Len(aCols)][y] := If(Alltrim(x[2])$"AM9_ALI_WT|AM9_REC_WT",NIL,CriaVar(AllTrim(x[2])) ) })
	aCols[1,Len(aHeader)+1] := .F.
EndIf

lOk := Modelo3(cCadastro,"AM8","AM9",/*aMyEncho*/,{|| A482Lok() }/*cLinOk*/,'Pco482Tok()'/*cTudoOk*/,nOpc,nOpc,/*cFieldOk*/,.T.,/*nLinhas*/,/*aAltEnchoice*/,/*nFreeze*/,/*aButtons*/,aCordW,/*nSizeHeader*/)

If lOk

	// Grava AM8
	DbSelectArea("AM8")
	If ALTERA .or. EXCLUI
		DbGoTo(nReg)
	EndIf
	If ALTERA .or. INCLUI

			cId := MaxId()
			RecLock("AM8",INCLUI)
			AM8->AM8_FILIAL	:= xFilial("AM8")
			AM8->AM8_TIPO	:= cTipo
			If INCLUI
				AM8->AM8_ID		:= StrZero(cId,6)
			EndIf
			AEval(aCposAM8, {|x,y|  If(!(Alltrim(x[2])$"AM8_ALI_WT|AM8_REC_WT") .and. x[10]<>"V" , FieldPut(FieldPos(x[2]),&("M->"+x[2])) , .F. )  })
		MsUnLock()

	ElseIf EXCLUI

		RecLock("AM8",INCLUI)
			DbDelete()
		MsUnLock()
	
	EndIf
	
	// Grava AM9
	DbSelectArea("AM9")
	For _nX := 1 To Len(aCols)
		
		If (aCols[_nX,Len(aHeader)+1] .and. Len(aRecnos)<=_nX) .or. EXCLUI // Deletado
		
			DbGoto(aRecnos[_nX])
			RecLock("AM9",.F.)
				DbDelete()
			MsUnLock()
		
		ElseIf INCLUI .or. Len(aRecnos) < _nX

			RecLock("AM9",.T.)
				AM9->AM9_FILIAL	:= xFilial("AM9")
				AM9->AM9_ID		:= AM8->AM8_ID
				AEval(aHeader, {|x,y|  If(!(Alltrim(x[2])$"AM9_ALI_WT|AM9_REC_WT") .and. x[10]<>"V" , FieldPut(FieldPos(x[2]),aCols[_nX,y]) , .F. )  })	
			MsUnLock()
		
		ElseIf ALTERA

			DbGoto(aRecnos[_nX])
			RecLock("AM9",.F.)
				AEval(aHeader, {|x,y|  If(!(Alltrim(x[2])$"AM9_ALI_WT|AM9_REC_WT") .and. x[10]<>"V" , FieldPut(FieldPos(x[2]),aCols[_nX,y]) , .F. )  })	
			MsUnLock()
		
		EndIf
	Next
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A482Lok �Autor  �Acacio Egas         � Data �  04/30/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o da Linha da GetDados.                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAPCO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A482Lok(nLin)

Local lRet 		:= .T.
Local lOk		:= .T.
Default nLin 	:= n

//������������������������������������������������������������������������Ŀ
//� Ponto de entrada para valida��o da Linha Ok                            �
//��������������������������������������������������������������������������
If ExistBlock( "PCOA4822" )
	//P_E������������������������������������������������������������������������Ŀ
	//P_E� Ponto de entrada utilizado para valida��o da linha da GetDados         �
	//P_E�                                                                        �
	//P_E� Parametros : Valida��o Padr�o                                          �
	//P_E� Retorno    : Logico                                                    �
	//P_E� Ex.        : User Function PCOA4822                                    �
	//P_E�              Return {.T.)						                      �
	//P_E��������������������������������������������������������������������������
	If ValType( lOk := ExecBlock( "PCOA4822", .F., .F. , lRet ) ) == "L"
		lRet := lOk
	EndIf
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A482Tok �Autor  �Acacio Egas         � Data �  04/30/08     ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o do tudo Ok da GetDados.                          ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAPCO                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Pco482Tok()

Local lRet 		:= .T.
Local lOk		:= .T.
Local _nX,nTotPrc
Local nPosPerc := aScan(aHeader , {|x| ALLTRIM(x[2])== "AM9_PERC" })

If EXCLUI

	//������������������������������������������������������������������������Ŀ
	//� Valida��o dos campos do cabe�alho.                                     �
	//��������������������������������������������������������������������������

	If !VldDe(M->AM8_CO+M->AM8_CLASSE+M->AM8_OPER+M->AM8_CC+M->AM8_ITCTB+M->AM8_CLVLR)

		lRet := .F.
		Aviso("Aten��o!","J� existe Relacionamento para est�s Entidades!",{"OK"})
	
	EndIf
	
	//������������������������������������������������������������������������Ŀ
	//� Valida��o dos campos dos Itens.                                        �
	//��������������������������������������������������������������������������
	If lRet
		nTotPrc	:= 0
		For _nX := 1 To Len(aCols)
		
			If !aCols[_Nx][Len(aCols[_Nx])] // N�o Deletada
				nTotPrc += aCols[_nX,nPosPerc]
			EndIf
		
		Next
	EndIf
	
	If lRet .and. nTotPrc<>100
	
		lRet := .F.
		Aviso("Aten��o!","O total dos percentuais deve ser 100%.",{"OK"})
	
	EndIf

EndIf	

//������������������������������������������������������������������������Ŀ
//� Ponto de entrada para valida��o do Tudo Ok.                            �
//��������������������������������������������������������������������������
If ExistBlock( "PCOA4823" )
	//P_E������������������������������������������������������������������������Ŀ
	//P_E� Ponto de entrada utilizado para valida��o do tudo Ok da tela.          �
	//P_E�                                                                        �
	//P_E� Parametros : Valida��o Padr�o                                          �
	//P_E� Retorno    : Logico                                                    �
	//P_E� Ex.        : User Function PCOA4823                                    �
	//P_E�              Return {.T.)						                      �
	//P_E��������������������������������������������������������������������������
	If ValType( lOk := ExecBlock( "PCOA4823", .F., .F. ,lRet) ) == "L"
		lRet := lOk
	EndIf
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �Acacio Egas         � Data �  04/30/08   ���
�������������������������������������������������������������������������͹��
���Uso       � PCOA482                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aUsRotina := {}
Local aRotina 	:= {		{ "Pesquisar"	,		"AxPesqui" , 0 , 1, ,.F.},;
							{ "Visualizar"	, 		"A482DLG"  , 0 , 2},;
							{ "Incluir"		, 		"A482DLG"  , 0 , 3},;
							{ "Alterar"		, 		"A482DLG"  , 0 , 4},;
							{ "Excluir"		, 		"A482DLG"  , 0 , 5};
					} 

	//������������������������������������������������������������������������Ŀ
	//� Adiciona botoes do usuario no aRotina                                  �
	//��������������������������������������������������������������������������
	If ExistBlock( "PCOA4821" )
		//P_E������������������������������������������������������������������������Ŀ
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de lan�amentos                                          �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA4821                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E��������������������������������������������������������������������������
		If ValType( aUsRotina := ExecBlock( "PCOA4821", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VldDe     �Autor  �Acacio Egas         � Data �  04/30/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida chave do AM8.                                       ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function VldDe(cChave)

LOcal lRet	:= .T.
Local aArea := GetArea()

DbSelectArea("AM8")
DbSetOrder(1)
If DbSeek(xFilial("AM8")+cTipo+cChave)

	If INCLUI .or. (aScan(aRecnos,Recno())==0 .and. ALTERA)
		lRet	:= .F.
	EndIf
	
EndIf
RestArea(aArea)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MaxId     �Autor  �Acacio Egas         � Data �  04/30/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Controla o ID para relacionamento AM8 e AM9.               ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MaxId()

Local cQuery
cQuery := "SELECT MAX(AM8_ID) AS ID FROM " + RetSqlName("AM8") + " AM8"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAM8", .T., .T. )
nRet := If( VALTYPE(TMPAM8->ID)<>"N" , 1 , TMPAM8->ID + 1 )
TMPAM8->(dbCloseArea())

Return nRet