#INCLUDE "pcoa060.ch"
#Define BMP_ON  "LBOK"
#Define BMP_OFF "LBNO"
/*
_F_U_N_C_����������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � PCOA060  � AUTOR � Edson Maricate        � DATA � 24.01.2004 ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Programa para configuracao dos pontos de bloqueio            ���
���������������������������������������������������������������������������Ĵ��
��� USO      � SIGAPCO                                                      ���
���������������������������������������������������������������������������Ĵ��
���_DOCUMEN_ � PCOA060                                                      ���
���_DESCRI_  � Programa para configuracao dos pontos de bloqueio            ���
���_FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    ���
���          � partir do Menu ou a partir de uma funcao pulando assim o     ���
���          � browse principal e executando a chamada direta da rotina     ���
���          � selecionada.                                                 ���
���          � Exemplo: PCOA060(2) - Executa a chamada da funcao de visua-  ���
���          �                        zacao da rotina.                      ���
���������������������������������������������������������������������������Ĵ��
���_PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Function PCOA060(nCallOpcx)
Local lRet 	:= .T.

SaveInter()

Private cCadastro	:= STR0001 //"Configura��o de Bloqueios Ativos"
Private aRotina := MenuDef()

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )

	If nCallOpcx <> Nil
		lRet := A060DLG("AKA",AKA->(RecNo()),nCallOpcx)
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
���Programa  �A060DLG   �Autor  �Edson Maricate      � Data � 24-01-2004  ���
�������������������������������������������������������������������������͹��
���Desc.     � Tratamento da tela de Inclusao/Alteracao/Exclusao/Visuali- ���
���          � zacao                                                      ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A060DLG(cAlias,nRecnoAKA,nOpcx)
Local oDlg
Local lCancel  := .F.
Local aButtons
Local aUsButtons := {}
Local oEnchAKA

Local oGdAKH
Local aHeadAKH
Local aColsAKH
Local nLenAKH   := 0 // Numero de campos em uso no AKH
Local nLinAKH   := 0 // Linha atual do acols
Local aRecAKH   := {} // Recnos dos registros
Local nGetD
Local nPosAtivo
Local l060Inclui := .F.
Local l060Altera := .F.
Local l060Exclui := .F.

//������������������������������������������������������������������������Ŀ
//� Adiciona botoes do usuario na EnchoiceBar                              �
//��������������������������������������������������������������������������
If ExistBlock( "PCOA0602" )
	//P_E������������������������������������������������������������������������Ŀ
	//P_E� Ponto de entrada utilizado para inclusao de botoes de usuarios         �
	//P_E� na tela de configuracao dos lancamentos                                �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
	//P_E�  Ex. :  User Function PCOA0602                                         �
	//P_E�         Return { 'PEDIDO', {|| MyFun() },"Exemplo de Botao" }          �
	//P_E��������������������������������������������������������������������������

	If ValType( aUsButtons := ExecBlock( "PCOA0602", .F., .F. ) ) == "A"
		aButtons := {}
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

If			aRotina[nOpcx][4] == 2
				l060Inclui := .F.
				l060Altera := .F.
				l060Exclui := .F.
ElseIf 	aRotina[nOpcx][4] == 4
				l060Inclui := .F.
				l060Altera := .T.
				l060Exclui := .F.
				nOpcx := 4
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
//� Montagem do aHeader do AKH                                             �
//��������������������������������������������������������������������������
aHeadAKH := GetaHeader("AKH")
nLenAKH  := Len(aHeadAKH) + 1
nPosAtivo:= AScan(aHeadAKH,{|x| Upper(AllTrim(x[2])) == "AKH_ATIVO" })

If nPosAtivo = 0
	MsgInfo(STR0005) //"A utilizacao do campo AKH_ATIVO e obrigatoria. O Campo 'AKH_ATIVO' n�o est� dispon�vel, contate o Suporte Microsiga para ativ�-lo."
	Return .F.
EndIf
//������������������������������������������������������������������������Ŀ
//� Montagem do aCols do AKH                                               �
//��������������������������������������������������������������������������
aColsAKH := {}
DbSelectArea("AKH")
DbSetOrder(1)
DbSeek(xFilial()+AKA->AKA_PROCES+AKA_ITEM)

While !l060Inclui .And. !Eof() .And. AKH->AKH_FILIAL + AKH->AKH_PROCES + AKH->AKH_ITEM == xFilial() + AKA->AKA_PROCES + AKA->AKA_ITEM
	AAdd(aColsAKH,Array( nLenAKH ))
	nLinAKH++
	// Varre o aHeader para preencher o acols
	AEval(aHeadAKH, {|x,y| aColsAKH[nLinAKH][y] := IIf(x[10] == "V", CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) ) })

	// Deleted
	aColsAKH[nLinAKH][nLenAKH] := .F.
	
	// Adiciona o Recno no aRec
	AAdd( aRecAKH, AKH->( Recno() ) )
	
	AKH->(DbSkip())
EndDo

// Verifica se n�o foi criada nenhuma linha para o aCols
If Len(aColsAKH) = 0
	AAdd(aColsAKH,Array( nLenAKH ))
	nLinAKH++

	// Varre o aHeader para preencher o acols
	AEval(aHeadAKH, {|x,y| aColsAKH[nLinAKH][y] := IIf(Upper(AllTrim(x[2])) == "AKH_SEQ", StrZero(1,Len(AKH->AKH_SEQ)),CriaVar(AllTrim(x[2])) ) })
	
	// Deleted
	aColsAKH[nLinAKH][nLenAKH] := .F.
EndIf

//�����������������������������������������������Ŀ
//� GetDados com os Pontos de Lancamento          �
//�������������������������������������������������
If nOpcx = 3 .Or. nOpcx = 4
	nGetD:= GD_INSERT+GD_UPDATE+GD_DELETE
Else
	nGetD := 0
EndIf
oGdAKH:= MsNewGetDados():New(0,0,100,100,nGetd,,,"+AKH_SEQ",,,9999,,,,oDlg,aHeadAKH,aColsAKH)
oGdAKH:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGdAKH:CARGO := AClone(aRecAKH)
oGdAKH:oBrowse:blDblClick:={|| If( (nOpcx == 3 .Or. nOpcx == 4) .And. oGdAKH:oBrowse:nColPos == nPosAtivo , A060BMP(@oGdAKH,nPosAtivo), oGdAKH:EditCell() ) }

// Quando nao for MDI chama centralizada.
If SetMDIChild()
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(A060Ok(nOpcx,oEnchAKA,oGdAKH),oDlg:End(),) },{|| lCancel := .T., oDlg:End() },,aButtons)
Else
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(A060Ok(nOpcx,oEnchAKA,oGdAKH),oDlg:End(),) },{|| lCancel := .T., oDlg:End() },,aButtons)
EndIf

If lCancel
	RollBackSX8()
EndIf


Return !lCancel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � A060Ok   �Autor  �Guilherme C. Leal   � Data �  11/26/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao do botao OK da enchoice bar, valida e faz o         ���
���          � tratamento adequado das informacoes.                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A060Ok(nOpcx,oEnchAKA,oGdAKH)
Local nI
If nOpcx != 4 // Sempre sera alteracao, qq coisa diferente retorna .T.
	Return .T.
EndIf

If !A060Vld(nOpcx,oEnchAKA,oGdAKH)
	Return .F.
EndIf

If nOpcx = 4 // Alteracao

	// Grava as configuracoes dos Lancamento
	For nI := 1 To Len(oGdAKH:aCols)
		If nI <= Len(oGdAKH:Cargo) .And. oGdAKH:Cargo[nI] > 0
			AKH->(DbGoto(oGdAKH:Cargo[nI]))
			Reclock("AKH",.F.)
		Else
			If oGdAKH:aCols[nI][Len(oGdAKH:aCols[nI])] // Verifica se a linha esta deletada
				Loop
			Else
				Reclock("AKH",.T.)
			EndIf
		EndIf
	
		If oGdAKH:aCols[nI][Len(oGdAKH:aCols[nI])] // Verifica se a linha esta deletada
			AKH->(DbDelete())
		Else
			// Varre o aHeader e grava com base no acols
			AEval(oGdAKH:aHeader,{|x,y| FieldPut( FieldPos(x[2]) , oGdAKH:aCols[nI][y] ) })
			Replace AKH_FILIAL With xFilial()
			Replace AKH_PROCES With AKA->AKA_PROCESS
			Replace AKH_ITEM   With AKA->AKA_ITEM

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
���Programa  � A060Vld  �Autor  �Guilherme C. Leal   � Data �  11/26/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao de validacao dos campos.                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A060Vld(nOpcx,oEnchAKA,oGdAKH)
Local nI
Local nPosField
If nOpcx != 4
	Return .T.
EndIf

For nI := 1 To Len(oGdAKH:aCols)
	// Busca por campos obrigatorios que nao estjam preenchidos
	nPosField := AScanx(oGdAKH:aHeader,{|x,y| x[17] .And. Empty(oGdAKH:aCols[nI][y]) })
	If nPosField > 0
		SX2->(dbSetOrder(1))
		SX2->(MsSeek("AKD"))
		HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+STR0006 + AllTrim(oGdAKH:aHeader[nPosField][1]) + STR0007+Str(nI,3,0),3,1) //"Campo: "###"Linha: " //"Campo: "###"Linha: "
		Return .F.
	EndIf
Next nI

Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A060BMP   �Autor  �Guilherme C. Leal   � Data �  22/12/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Altera bitmap de uso do lancamento.                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A060BMP(oGdAKH,nPosAtivo)
If !oGdAKH:aCols[oGdAKH:nAt][Len(oGdAKH:aHeader)+1]
	If oGdAKH:aCols[oGdAKH:nAt][nPosAtivo] == BMP_ON
		oGdAKH:aCols[oGdAKH:nAt][nPosAtivo]:= BMP_OFF
	Else
		oGdAKH:aCols[oGdAKH:nAt][nPosAtivo]:= BMP_ON
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
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
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
Local aRotina 	:= {	{ STR0002,		"AxPesqui", 0 , 1, ,.F.},;    //"Pesquisar"
							{ STR0003, 	"A060DLG" , 0 , 2},;    //"Visualizar"
							{ STR0004, 		"A060DLG" , 0 , 4}} //"Alterar"
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )

	//������������������������������������������������������������������������Ŀ
	//� Adiciona botoes do usuario no aRotina                                  �
	//��������������������������������������������������������������������������

	If ExistBlock( "PCOA0601" )
		//P_E������������������������������������������������������������������������Ŀ
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de Configuracao dos Lancamentos                         �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA0601                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E��������������������������������������������������������������������������
		If ValType( aUsRotina := ExecBlock( "PCOA0601", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)
