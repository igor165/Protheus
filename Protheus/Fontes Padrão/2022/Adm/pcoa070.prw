#INCLUDE "pcoa070.ch"
#Define BMP_ON  "LBOK"
#Define BMP_OFF "LBNO"
/*
_F_U_N_C_����������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � PCOA070  � AUTOR � Edson Maricate        � DATA � 24.01.2004 ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Programa para configuracao dos pontos de bloqueio            ���
���������������������������������������������������������������������������Ĵ��
��� USO      � SIGAPCO                                                      ���
���������������������������������������������������������������������������Ĵ��
���_DOCUMEN_ � PCOA070                                                      ���
���_DESCRI_  � Programa para configuracao dos pontos de bloqueio            ���
���_FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    ���
���          � partir do Menu ou a partir de uma funcao pulando assim o     ���
���          � browse principal e executando a chamada direta da rotina     ���
���          � selecionada.                                                 ���
���          � Exemplo: PCOA070(2) - Executa a chamada da funcao de visua-  ���
���          �                        zacao da rotina.                      ���
���������������������������������������������������������������������������Ĵ��
���_PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Function PCOA070(nCallOpcx)
Local lRet		:= .T.

SaveInter()

Private cCadastro	:= STR0001 //"Configura��o do Lan�amento de Bloqueio"
Private aRotina := MenuDef()

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	If nCallOpcx <> Nil
		lRet := A070DLG("AKA",AKA->(RecNo()),nCallOpcx)
	Else
		mBrowse(6,1,22,75,"AKA")
	EndIf
EndIf

RestInter()

Return lRet 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A070DLG   �Autor  �Edson Maricate      � Data � 24-01-2004  ���
�������������������������������������������������������������������������͹��
���Desc.     � Tratamento da tela de Inclusao/Alteracao/Exclusao/Visuali- ���
���          � zacao                                                      ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A070DLG(cAlias,nRecnoAKA,nOpcx)
Local oDlg
Local lCancel  := .F.
Local aButtons
Local aUsButtons := {}
Local oEnchAKA

Local oGdAKI
Local aHeadAKI
Local aColsAKI
Local nLenAKI   := 0 // Numero de campos em uso no AKI
Local nLinAKI   := 0 // Linha atual do acols
Local aRecAKI   := {} // Recnos dos registros
Local nGetD
Local nPosAtivo
Local l070Inclui := .F.
Local l070Altera := .F.
Local l070Exclui := .F.

If			aRotina[nOpcx][4] == 2
				l070Inclui := .F.
				l070Altera := .F.
				l070Exclui := .F.
ElseIf 	aRotina[nOpcx][4] == 4
				l070Inclui := .F.
				l070Altera := .T.
				l070Exclui := .F.
				nOpcx := 4
EndIf

//������������������������������������������������������������������������Ŀ
//� Adiciona botoes do usuario na EnchoiceBar                              �
//��������������������������������������������������������������������������
If ExistBlock( "PCOA0702" )
	//P_E������������������������������������������������������������������������Ŀ
	//P_E� Ponto de entrada utilizado para inclusao de botoes de usuarios         �
	//P_E� na tela de configuracao dos lancamentos                                �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
	//P_E�  Ex. :  User Function PCOA0702                                         �
	//P_E�         Return { 'PEDIDO', {|| MyFun() },"Exemplo de Botao" }          �
	//P_E��������������������������������������������������������������������������

	If ValType( aUsButtons := ExecBlock( "PCOA0702", .F., .F. ) ) == "A"
		aButtons := {}
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 0,0 TO 480,640 PIXEL
oDlg:lMaximized := .T.

// Carrega dados do AKA para memoria
RegToMemory("AKA",.F.)

//������������������������������������������������������������������������Ŀ
//� Enchoice com os dados dos Lancamentos                                  �
//��������������������������������������������������������������������������
oEnchAKA := MSMGet():New('AKA',,2,,,,,{0,0,(oDlg:nClientHeight/6)-12,(oDlg:nClientWidth/2)},,,,,,oDlg,,,,,,.T.,,,)
oEnchAKA:oBox:Align := CONTROL_ALIGN_TOP

//������������������������������������������������������������������������Ŀ
//� Montagem do aHeader do AKI                                             �
//��������������������������������������������������������������������������
aHeadAKI := GetaHeader("AKI")
nLenAKI  := Len(aHeadAKI) + 1
nPosAtivo:= AScan(aHeadAKI,{|x| Upper(AllTrim(x[2])) == "AKI_ATIVO" })

If nPosAtivo = 0
	MsgInfo(STR0005) //"A utilizacao do campo AKI_ATIVO e obrigatoria. O Campo 'AKI_ATIVO' n�o est� dispon�vel, contate o Suporte Microsiga para ativ�-lo."
	Return .F.
EndIf
//������������������������������������������������������������������������Ŀ
//� Montagem do aCols do AKI                                               �
//��������������������������������������������������������������������������
aColsAKI := {}
DbSelectArea("AKI")
DbSetOrder(1)
DbSeek(xFilial()+AKA->AKA_PROCES+AKA_ITEM)

While !l070Inclui .And. !Eof() .And. AKI->AKI_FILIAL + AKI->AKI_PROCES + AKI->AKI_ITEM == xFilial() + AKA->AKA_PROCES + AKA->AKA_ITEM
	AAdd(aColsAKI,Array( nLenAKI ))
	nLinAKI++
	// Varre o aHeader para preencher o acols
	AEval(aHeadAKI, {|x,y| aColsAKI[nLinAKI][y] := IIf(x[10] == "V", CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) ) })

	// Deleted
	aColsAKI[nLinAKI][nLenAKI] := .F.
	
	// Adiciona o Recno no aRec
	AAdd( aRecAKI, AKI->( Recno() ) )
	
	AKI->(DbSkip())
EndDo

// Verifica se n�o foi criada nenhuma linha para o aCols
If Len(aColsAKI) = 0
	AAdd(aColsAKI,Array( nLenAKI ))
	nLinAKI++

	// Varre o aHeader para preencher o acols
	AEval(aHeadAKI, {|x,y| aColsAKI[nLinAKI][y] := IIf(Upper(AllTrim(x[2])) == "AKI_SEQ", StrZero(1,Len(AKI->AKI_SEQ)),CriaVar(AllTrim(x[2])) ) })
	
	// Deleted
	aColsAKI[nLinAKI][nLenAKI] := .F.
EndIf

//�����������������������������������������������Ŀ
//� GetDados com os Pontos de Lancamento          �
//�������������������������������������������������
If nOpcx = 3 .Or. nOpcx = 4
	nGetD:= GD_INSERT+GD_UPDATE+GD_DELETE
Else
	nGetD := 0
EndIf
oGdAKI:= MsNewGetDados():New(0,0,100,100,nGetd,,,"+AKI_SEQ",,,9999,,,,oDlg,aHeadAKI,aColsAKI)
oGdAKI:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGdAKI:CARGO := AClone(aRecAKI)
oGdAKI:oBrowse:blDblClick:={|| If( (nOpcx == 3 .Or. nOpcx == 4) .And. oGdAKI:oBrowse:nColPos == nPosAtivo , A070BMP(@oGdAKI,nPosAtivo), oGdAKI:EditCell() ) }

// Quando nao for MDI chama centralizada.
If SetMDIChild()
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(A070Ok(nOpcx,oEnchAKA,oGdAKI),oDlg:End(),) },{|| lCancel := .T., oDlg:End() },,aButtons)
Else
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(A070Ok(nOpcx,oEnchAKA,oGdAKI),oDlg:End(),) },{|| lCancel := .T., oDlg:End() },,aButtons)
EndIf

If lCancel
	RollBackSX8()
EndIf


Return !lCancel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � A070Ok   �Autor  �Guilherme C. Leal   � Data �  11/26/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao do botao OK da enchoice bar, valida e faz o         ���
���          � tratamento adequado das informacoes.                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A070Ok(nOpcx,oEnchAKA,oGdAKI)
Local nI
If nOpcx != 4 // Sempre sera alteracao, qq coisa diferente retorna .T.
	Return .T.
EndIf

If !A070Vld(nOpcx,oEnchAKA,oGdAKI)
	Return .F.
EndIf

If nOpcx = 4 // Alteracao

	// Grava as configuracoes dos Lancamento
	For nI := 1 To Len(oGdAKI:aCols)
		If nI <= Len(oGdAKI:Cargo) .And. oGdAKI:Cargo[nI] > 0
			AKI->(DbGoto(oGdAKI:Cargo[nI]))
			Reclock("AKI",.F.)
		Else
			If oGdAKI:aCols[nI][Len(oGdAKI:aCols[nI])] // Verifica se a linha esta deletada
				Loop
			Else
				Reclock("AKI",.T.)
			EndIf
		EndIf
	
		If oGdAKI:aCols[nI][Len(oGdAKI:aCols[nI])] // Verifica se a linha esta deletada
			AKI->(DbDelete())
		Else
			// Varre o aHeader e grava com base no acols
			AEval(oGdAKI:aHeader,{|x,y| FieldPut( FieldPos(x[2]) , oGdAKI:aCols[nI][y] ) })
			Replace AKI_FILIAL With xFilial()
			Replace AKI_PROCES With AKA->AKA_PROCESS
			Replace AKI_ITEM   With AKA->AKA_ITEM

		EndIf

		MsUnlock()
	Next nI
EndIf

If __lSX8
	ConfirmSX8()
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � A070Vld  �Autor  �Guilherme C. Leal   � Data �  11/26/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao de validacao dos campos.                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A070Vld(nOpcx,oEnchAKA,oGdAKI)
Local nI
Local nPosField
If nOpcx != 4
	Return .T.
EndIf

For nI := 1 To Len(oGdAKI:aCols)
	// Busca por campos obrigatorios que nao estjam preenchidos
	nPosField := AScanx(oGdAKI:aHeader,{|x,y| x[17] .And. Empty(oGdAKI:aCols[nI][y]) })
	If nPosField > 0
		SX2->(dbSetOrder(1))
		SX2->(MsSeek("AKD"))
		HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+STR0006 + AllTrim(oGdAKI:aHeader[nPosField][1]) + STR0007+Str(nI,3,0),3,1) //"Campo: "###"Linha: " //"Campo: "###"Linha: "
		Return .F.
	EndIf
Next nI

Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A070BMP   �Autor  �Guilherme C. Leal   � Data �  22/12/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Altera bitmap de uso do lancamento.                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A070BMP(oGdAKI,nPosAtivo)
If !oGdAKI:aCols[oGdAKI:nAt][Len(oGdAKI:aHeader)+1]
	If oGdAKI:aCols[oGdAKI:nAt][nPosAtivo] == BMP_ON
		oGdAKI:aCols[oGdAKI:nAt][nPosAtivo]:= BMP_OFF
	Else
		oGdAKI:aCols[oGdAKI:nAt][nPosAtivo]:= BMP_ON
	EndIf
EndIf


/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �17/11/06 ���
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
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()
Local aUsRotina := {}
Local aRotina 	:= {	{ STR0002,		"AxPesqui", 0 , 1},;    //"Pesquisar"
								{ STR0003, 	"A070DLG" , 0 , 2},;    //"Visualizar"
								{ STR0004, 		"A070DLG" , 0 , 4}} //"Alterar"
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )

	//������������������������������������������������������������������������Ŀ
	//� Adiciona botoes do usuario no aRotina                                  �
	//��������������������������������������������������������������������������

	If ExistBlock( "PCOA0701" )
		//P_E������������������������������������������������������������������������Ŀ
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de Configuracao dos Lancamentos                         �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA0701                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E��������������������������������������������������������������������������
		If ValType( aUsRotina := ExecBlock( "PCOA0701", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf      
EndIf	
Return(aRotina)