#INCLUDE "PCOA041.ch"
#INCLUDE "PROTHEUS.CH"

#Define BMP_ON  "LBOK"
#Define BMP_OFF "LBNO"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA041   �Autor  � Daniel Leme        � Data �  31/08/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Programa para configuracao dos lancamentos                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � PCO                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function PCOA041(nCallOpcx)
Private cCadastro	:= STR0001 //"Configura��o de Lan�amentos"
Private aRotina := MenuDef()

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	If nCallOpcx <> Nil
		A041DLG("AKB",AKB->(RecNo()),nCallOpcx)
	Else
		mBrowse(6,1,22,75,"AKB")
	EndIf
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A041DLG   �Autor  � Daniel Leme        � Data �  31/08/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Tratamento da tela de Inclusao/Alteracao/Exclusao/Visuali- ���
���          � zacao                                                      ���
�������������������������������������������������������������������������͹��
���Uso       � PCO                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A041DLG(cAlias,nRecnoAKB,nCallOpcx)
Local oDlg
Local lCancel  := .F.
Local aButtons
Local aUsButtons := {}
Local oEnchAKB

Local oGdAMK
Local aHeadAMK
Local aColsAMK
Local nLenAMK   := 0 // Numero de campos em uso no AMK
Local nLinAMK   := 0 // Linha atual do acols
Local aRecAMK   := {} // Recnos dos registros
Local nGetD
Local nPosAtivo

If nCallOpcx > 2  // As unicas opcoes disponiveis para essa rotina sao visualizacao e alteracao
	nCallOpcx := 4
EndIf

Private INCLUI  := (nCallOpcx = 3)

If !AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	Return .F.
EndIf

If nCallOpcx != 3 .And. ValType(nRecnoAKB) == "N" .And. nRecnoAKB > 0
	DbSelectArea(cAlias)
	DbGoto(nRecnoAKB)
	If EOF() .Or. BOF()
		HELP("  ",1,"PCOREGINV",,AllTrim(Str(nRecnoAKB)))
		Return .F.
	EndIf
EndIf


DEFINE MSDIALOG oDlg TITLE STR0005 FROM 0,0 TO 480,640 PIXEL //"Configura��o Lan�amentos"
oDlg:lMaximized := .T.

// Carrega dados do AKB para memoria
RegToMemory("AKB",.F.)

//������������������������������������������������������������������������Ŀ
//� Enchoice com os dados dos Lancamentos                                  �
//��������������������������������������������������������������������������
oEnchAKB := MSMGet():New('AKB',,2,,,,,{0,0,(oDlg:nClientHeight/6)-12,(oDlg:nClientWidth/2)},,,,,,oDlg,,,,,,.T.,,,)
oEnchAKB:oBox:Align := CONTROL_ALIGN_TOP

//������������������������������������������������������������������������Ŀ
//� Montagem do aHeader do AMK                                             �
//��������������������������������������������������������������������������
aHeadAMK := GetaHeader("AMK")
nLenAMK  := Len(aHeadAMK) + 1
nPosAtivo:= AScan(aHeadAMK,{|x| Upper(AllTrim(x[2])) == "AMK_ATIVO" })

If nPosAtivo = 0
	Help("   ",1,"NOAMKATIVOPCOA041",,STR0006,3,0) //"O Campo 'AMK_ATIVO' n�o est� dispon�vel, contate o Suporte Microsiga para ativ�-lo."
	Return .F.
EndIf
//������������������������������������������������������������������������Ŀ
//� Montagem do aCols do AMK                                               �
//��������������������������������������������������������������������������
aColsAMK := {}
DbSelectArea("AMK")
DbSetOrder(1)
DbSeek(xFilial()+AKB->AKB_PROCES+AKB_ITEM)

While nCallOpcx != 3 .And. !Eof() .And. AMK->AMK_FILIAL + AMK->AMK_PROCES + AMK->AMK_ITEM == xFilial() + AKB->AKB_PROCES + AKB->AKB_ITEM

	AAdd(aColsAMK,Array( nLenAMK ))
	nLinAMK++
	// Varre o aHeader para preencher o acols
	AEval(aHeadAMK, {|x,y| aColsAMK[nLinAMK][y] := IIf(x[10] == "V", CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) ) })

	// Deleted
	aColsAMK[nLinAMK][nLenAMK] := .F.

	// Adiciona o Recno no aRec
	AAdd( aRecAMK, AMK->( Recno() ) )

	AMK->(DbSkip())
EndDo

// Verifica se n�o foi criada nenhuma linha para o aCols
If Len(aColsAMK) = 0
	AAdd(aColsAMK,Array( nLenAMK ))
	nLinAMK++

	// Varre o aHeader para preencher o acols
	AEval(aHeadAMK, {|x,y| aColsAMK[nLinAMK][y] := IIf(Upper(AllTrim(x[2])) == "AMK_SEQ", StrZero(1,Len(AMK->AMK_SEQ)),CriaVar(AllTrim(x[2])) ) })

	// Deleted
	aColsAMK[nLinAMK][nLenAMK] := .F.
EndIf

//�����������������������������������������������Ŀ
//� GetDados com os Pontos de Lancamento          �
//�������������������������������������������������
If nCallOpcx = 3 .Or. nCallOpcx = 4
	nGetD:= GD_INSERT+GD_UPDATE+GD_DELETE
Else
	nGetD := 0
EndIf
oGdAMK:= MsNewGetDados():New(0,0,100,100,nGetd,,,"+AMK_SEQ",,,9999,,,,oDlg,aHeadAMK,aColsAMK)
oGdAMK:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGdAMK:CARGO := AClone(aRecAMK)
oGdAMK:oBrowse:blDblClick:={|| If( (nCallOpcx == 3 .Or. nCallOpcx == 4) .And. oGdAMK:oBrowse:nColPos == nPosAtivo , A041BMP(@oGdAMK,nPosAtivo), oGdAMK:EditCell() ) }

// Quando nao for MDI chama centralizada.
If SetMDIChild()
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(A041Ok(nCallOpcx,oEnchAKB,oGdAMK),oDlg:End(),) },{|| lCancel := .T., oDlg:End() },,aButtons)
Else
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(A041Ok(nCallOpcx,oEnchAKB,oGdAMK),oDlg:End(),) },{|| lCancel := .T., oDlg:End() },,aButtons)
EndIf

If lCancel
	RollBackSX8()
EndIf


Return !lCancel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � A041Ok   �Autor  � Daniel Leme        � Data �  31/08/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao do botao OK da enchoice bar, valida e faz o         ���
���          � tratamento adequado das informacoes.                       ���
�������������������������������������������������������������������������͹��
���Uso       � PCO                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A041Ok(nCallOpcx,oEnchAKB,oGdAMK)
Local nI
If nCallOpcx != 4 // Sempre sera alteracao, qq coisa diferente retorna .T.
	Return .T.
EndIf

If !A041Vld(nCallOpcx,oEnchAKB,oGdAMK)
	Return .F.
EndIf

If nCallOpcx = 4 // Alteracao

	// Grava as configuracoes dos Lancamento
	For nI := 1 To Len(oGdAMK:aCols)
		If nI <= Len(oGdAMK:Cargo) .And. oGdAMK:Cargo[nI] > 0
			AMK->(DbGoto(oGdAMK:Cargo[nI]))
			Reclock("AMK",.F.)
		Else
			If oGdAMK:aCols[nI][Len(oGdAMK:aCols[nI])] // Verifica se a linha esta deletada
				Loop
			Else
				Reclock("AMK",.T.)
			EndIf
		EndIf

		If oGdAMK:aCols[nI][Len(oGdAMK:aCols[nI])] // Verifica se a linha esta deletada
			AMK->(DbDelete())
		Else
			// Varre o aHeader e grava com base no acols
			AEval(oGdAMK:aHeader,{|x,y| FieldPut( FieldPos(x[2]) , oGdAMK:aCols[nI][y] ) })
			Replace AMK_FILIAL With xFilial()
			Replace AMK_PROCES With AKB->AKB_PROCESS
			Replace AMK_ITEM   With AKB->AKB_ITEM
			If GdFieldPos("AMK_TIPO",oGdAMK:aHeader) == 0
				Replace AMK_TIPO   With '"1"' //-- Sempre ser� cr�dito
			EndIf

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
���Programa  � A041Vld  �Autor  � Daniel Leme        � Data �  31/08/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao de validacao dos campos.                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � PCO                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A041Vld(nCallOpcx,oEnchAKB,oGdAMK)
Local nI
Local nPosField
If nCallOpcx != 4
	Return .T.
EndIf

For nI := 1 To Len(oGdAMK:aCols)
	// Busca por campos obrigatorios que nao estjam preenchidos
	nPosField := AScanx(oGdAMK:aHeader,{|x,y| x[17] .And. Empty(oGdAMK:aCols[nI][y]) })
	If nPosField > 0
		SX2->(dbSetOrder(1))
		SX2->(MsSeek("AKD"))
		HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+STR0007 + AllTrim(oGdAMK:aHeader[nPosField][1]) + STR0008+Str(nI,3,0),3,1) //"Campo: "###"Linha: " //"Campo: "###"Linha: "
		Return .F.
	EndIf
Next nI

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Daniel Leme           � Data �31/08/10  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Altera bitmap de uso do lancamento.                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A041BMP(oGdAMK,nPosAtivo)
If !oGdAMK:aCols[oGdAMK:nAt][Len(oGdAMK:aHeader)+1]
	If oGdAMK:aCols[oGdAMK:nAt][nPosAtivo] == BMP_ON
		oGdAMK:aCols[oGdAMK:nAt][nPosAtivo]:= BMP_OFF
	Else
		oGdAMK:aCols[oGdAMK:nAt][nPosAtivo]:= BMP_ON
	EndIf
EndIf


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Daniel Leme           � Data �31/08/10  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,	"AxPesqui", 0 , 1, ,.F.},;	//-- "Pesquisar"
							{ STR0003, 	"A041DLG" , 0 , 2},;				//-- "Visualizar"
							{ STR0004, 	"A041DLG" , 0 , 4}}				//-- "Lan�amentos"


Return(aRotina)