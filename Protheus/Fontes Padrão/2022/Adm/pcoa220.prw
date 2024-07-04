#include "protheus.ch"
#include "pcoa220.ch"
#include "msgraphi.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA220   �Autor  �Paulo Carnelossi    � Data �  12/12/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro para consultas a cubos gerenciais referente a      ���
���          �periodos anteriores ao que esta sendo orcado na planilha    ���
���          �atual                                                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOA220(nCallOpcx)
Private cCadastro	:= STR0001 //"Cadastro de Consultas Pre-Configuradas Cubos Gerenciais"
Private aRotina := MenuDef()	
	If nCallOpcx <> Nil
		A220DLG("AL8",AL8->(RecNo()),nCallOpcx)
	Else
		mBrowse(6,1,22,75,"AL8")
	EndIf


Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A220DLG   �Autor  �Paulo Carnelossi    � Data �  12/12/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Tratamento da tela de Inclusao/Alteracao/Exclusao/Visuali- ���
���          � zacao                                                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A220DLG(cAlias,nRecnoAL8,nCallOpcx)
Local oDlg
Local lCancel  := .F.
Local aButtons := { }
Local aUsButtons := {}
Local oEnchAL8
Local oFolder

Local aHeadAL9
Local aColsAL9
Local nLenAL9   := 0 // Numero de campos em uso no AL9
Local nLinAL9   := 0 // Linha atual do acols
Local aRecAL9   := {} // Recnos dos registros
Local nGetD


Local oBarAL9
Local oBtnAL9

Private oGdAL9
Private INCLUI  := (nCallOpcx = 3)

If !AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	Return .F.
EndIf

If nCallOpcx != 3 .And. ValType(nRecnoAL8) == "N" .And. nRecnoAL8 > 0
	DbSelectArea(cAlias)
	DbGoto(nRecnoAL8)
	If EOF() .Or. BOF()
		HELP("  ",1,"PCOREGINV",,AllTrim(Str(nRecnoAL8)))
		Return .F.
	EndIf
EndIf


//������������������������������������������������������������������������Ŀ
//� Adiciona botoes do usuario na EnchoiceBar                              �
//��������������������������������������������������������������������������
If ExistBlock( "PCOA2202" )
	//P_E������������������������������������������������������������������������Ŀ
	//P_E� Ponto de entrada utilizado para inclusao de botoes de usuarios         �
	//P_E� na tela de processos                                                   �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
	//P_E�  Ex. :  User Function PCOA2202                                         �
	//P_E�         Return { 'PEDIDO', {|| MyFun() },"Exemplo de Botao" }          �
	//P_E��������������������������������������������������������������������������

	If ValType( aUsButtons := ExecBlock( "PCOA2202", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

DEFINE MSDIALOG oDlg TITLE STR0001 FROM 0,0 TO 480,640 PIXEL //"Cadastro de Consultas Pre-Configuradas Cubos Gerenciais"
oDlg:lMaximized := .T.

// Carrega dados do AL8 para memoria
RegToMemory("AL8",INCLUI)

//������������������������������������������������������������������������Ŀ
//� Enchoice com os dados do Processo                                      �
//��������������������������������������������������������������������������
oEnchAL8 := MSMGet():New('AL8',,nCallOpcx,,,,,{0,0,(oDlg:nClientHeight/6)-12,(oDlg:nClientWidth/2)},,,,,,oDlg,,,,,,.T.,,,)
oEnchAL8:oBox:Align := CONTROL_ALIGN_TOP

//������������������������������������������������������������������������Ŀ
//� Folder com os Pontos de Lancamento e Pontos de Bloqueio                �
//��������������������������������������������������������������������������
oFolder  := TFolder():New(oDlg:nHeight/6,0,{STR0009},{''},oDlg,1,,,.T.,,(oDlg:nWidth/2),oDlg:nHeight/3,) //"Configuracoes de Cubo"
oFolder:Align := CONTROL_ALIGN_ALLCLIENT

//������������������������������������������������������������������������Ŀ
//� Montagem do aHeader do AL9                                             �
//��������������������������������������������������������������������������
aHeadAL9 := GetaHeader("AL9")
nLenAL9  := Len(aHeadAL9) + 1

//������������������������������������������������������������������������Ŀ
//� Montagem do aCols do AL9                                               �
//��������������������������������������������������������������������������
aColsAL9 := {}
DbSelectArea("AL9")
DbSetOrder(1)
DbSeek(xFilial("AL9")+AL8->AL8_CODIGO)
If nCallOpcx != 3
	While AL9->(!Eof() .And. AL9_FILIAL+AL9_CODIGO == xFilial("AL9")+AL8->AL8_CODIGO)
		AAdd(aColsAL9,Array( nLenAL9 ))
		nLinAL9++
		// Varre o aHeader para preencher o acols
		AEval(aHeadAL9, {|x,y| aColsAL9[nLinAL9][y] := IIf(x[10] == "V", CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) ) })
	
		// Deleted
		aColsAL9[nLinAL9][nLenAL9] := .F.
		
		// Adiciona o Recno no aRec
		AAdd( aRecAL9, AL9->( Recno() ) )
		
		AL9->(DbSkip())
	EndDo
EndIf

// Verifica se n�o foi criada nenhuma linha para o aCols
If Len(aColsAL9) = 0
	AAdd(aColsAL9,Array( nLenAL9 ))
	nLinAL9++

	// Varre o aHeader para preencher o acols
	AEval(aHeadAL9, {|x,y| aColsAL9[nLinAL9][y] := IIf(Upper(AllTrim(x[2])) == "AL9_ITEM", StrZero(1,Len(AL9->AL9_ITEM)),CriaVar(AllTrim(x[2])) ) })

	// Deleted
	aColsAL9[nLinAL9][nLenAL9] := .F.
EndIf

//�����������������������������������������������Ŀ
//� GetDados com os Pontos de Lancamento          �
//�������������������������������������������������
If nCallOpcx = 3 .Or. nCallOpcx = 4
	nGetD:= GD_INSERT+GD_UPDATE+GD_DELETE
Else
	nGetD := 0
EndIf

oGdAL9:= MsNewGetDados():New(0,0,100,100,nGetd,,,"+AL9_ITEM",,,9999,,,,oFolder:aDialogs[1],aHeadAL9,aColsAL9)
oGdAL9:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGdAL9:CARGO := AClone(aRecAL9)

// Quando nao for MDI chama centralizada.
If SetMDIChild()
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(A220Ok(nCallOpcx,oEnchAL8,oGdAL9),(A220Grv(nCallOpcx,oEnchAL8,oGdAL9),oDlg:End()),) },{|| lCancel := .T., oDlg:End() },,aButtons)
Else
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(A220Ok(nCallOpcx,oEnchAL8,oGdAL9),(A220Grv(nCallOpcx,oEnchAL8,oGdAL9),oDlg:End()),) },{|| lCancel := .T., oDlg:End() },,aButtons)
EndIf

Return !lCancel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � A220Ok   �Autor  �Paulo Carnelossi    � Data �  12/11/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao do botao OK da enchoice bar, valida e faz o         ���
���          � tratamento adequado das informacoes.                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A220Ok(nCallOpcx,oEnchAL8,oGdAL9)
Local lRet := .F.

If nCallOpcx = 1 .Or. nCallOpcx = 2 // Pesquisar e Visualizar
	lRet := .T.
EndIf

If !A220Vld(nCallOpcx,oEnchAL8,oGdAL9)
	lRet := .F. 
Else
	lRet := .T. 
EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � A220Grv  �Autor  �Paulo Carnelossi    � Data �  12/11/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao de gravacao das configuracoes de visao gerencial ao ���
���          � pressionar o botao OK da enchoice bar.                     ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A220Grv(nCallOpcx,oEnchAL8,oGdAL9)
Local nI
Local cCampo

If nCallOpcx = 3 // Inclusao

	// Grava Processo
	Reclock("AL8",.T.)
	For nI := 1 To FCount()
		cCampo := Upper(AllTrim(FieldName(nI)))
		If cCampo == "AL8_FILIAL"
			FieldPut(nI,xFilial())
		Else
			FieldPut(nI, &("M->" + cCampo))
		EndIf
	Next nI
	MsUnlock()
	
	// Grava Pontos de Lancamento
	For nI := 1 To Len(oGdAL9:aCols)
		If oGdAL9:aCols[nI][Len(oGdAL9:aCols[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("AL9",.T.)
		EndIf

		// Varre o aHeader e grava com base no acols
		AEval(oGdAL9:aHeader,{|x,y| FieldPut(FieldPos(x[2]), oGdAL9:aCols[nI][y] ) })

		Replace AL9_FILIAL With xFilial()
		Replace AL9_CODIGO With AL8->AL8_CODIGO
		Replace AL9_CUBE With AL8->AL8_CUBE

		MsUnlock()

	Next nI
	
ElseIf nCallOpcx = 4 // Alteracao

	// Grava Processo
	Reclock("AL8",.F.)
	For nI := 1 To FCount()
		cCampo := Upper(AllTrim(FieldName(nI)))
		If cCampo == "AL8_FILIAL"
			FieldPut(nI,xFilial())
		Else
			FieldPut(nI, &("M->" + cCampo))
		EndIf
	Next nI
	MsUnlock()

	// Grava Pontos de Lancamento
	For nI := 1 To Len(oGdAL9:aCols)
		If nI <= Len(oGdAL9:Cargo) .And. oGdAL9:Cargo[nI] > 0
			AL9->(DbGoto(oGdAL9:Cargo[nI]))
			Reclock("AL9",.F.)
		Else
			If oGdAL9:aCols[nI][Len(oGdAL9:aCols[nI])] // Verifica se a linha esta deletada
				Loop
			Else
				Reclock("AL9",.T.)
			EndIf
		EndIf
	
		If oGdAL9:aCols[nI][Len(oGdAL9:aCols[nI])] // Verifica se a linha esta deletada
			AL9->(DbDelete())
		Else
			// Varre o aHeader e grava com base no acols
			AEval(oGdAL9:aHeader,{|x,y| FieldPut( FieldPos(x[2]) , oGdAL9:aCols[nI][y] ) })
			Replace AL9_FILIAL With xFilial()
			Replace AL9_CODIGO With AL8->AL8_CODIGO
			Replace AL9_CUBE With AL8->AL8_CUBE

		EndIf

		MsUnlock()
	Next nI

ElseIf nCallOpcx = 5 // Exclusao

	// Exclui Pontos de Lancamento
	For nI := 1 To Len(oGdAL9:aCols)
		If nI <= Len(oGdAL9:Cargo) .And. oGdAL9:Cargo[nI] > 0
			AL9->(DbGoto(oGdAL9:Cargo[nI]))
			Reclock("AL9",.F.)
			AL9->(DbDelete())
			MsUnLock()
		EndIf		
	Next nI

	// Exclui Processo
	Reclock("AL8",.F.)
	AL8->(DbDelete())
	MsUnLock()

EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � A220Vld  �Autor  �Paulo Carnelossi    � Data �  12/11/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao de validacao dos campos.                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A220Vld(nCallOpcx,oEnchAL8,oGdAL9)
Local nI
If (nCallOpcx = 3 .Or. nCallOpcx = 4) .And. ;
	!Obrigatorio(oEnchAL8:aGets,oEnchAL8:aTela)
	Return .F.
EndIf

For nI := 1 To Len(oGdAL9:aCols)
	// Busca por campos obrigatorios que nao estjam preenchidos
	nPosField := AScanx(oGdAL9:aHeader,{|x,y| x[17] .And. Empty(oGdAL9:aCols[nI][y]) })
	If nPosField > 0
		SX2->(dbSetOrder(1))
		SX2->(MsSeek("AKD"))
		HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+STR0007 + AllTrim(oGdAL9:aHeader[nPosField][1]) + STR0008+Str(nI,3,0),3,1) //"Campo: "###"Linha: " //"Campo: "###"Linha: "
		Return .F.
	EndIf
Next nI

Return .T.


/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �29/11/06 ���
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
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1},;    //"Pesquisar"
							{ STR0003,   	"A220DLG" , 0 , 2},;     //"Visualizar"
							{ STR0004, 		"A220DLG" , 0 , 3},;	  //"Incluir"
							{ STR0005, 		"A220DLG" , 0 , 4},;     //"Alterar"
							{ STR0006, 		"A220DLG" , 0 , 5}}      //"Excluir"
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//������������������������������������������������������������������������Ŀ
	//� Adiciona botoes do usuario no aRotina                                  �
	//��������������������������������������������������������������������������
	If ExistBlock( "PCOA2201" )
		//P_E������������������������������������������������������������������������Ŀ
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de processos                                            �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA2201                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E��������������������������������������������������������������������������
		If ValType( aUsRotina := ExecBlock( "PCOA2201", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf	
Return(aRotina)