#INCLUDE "pcoa462.ch"
#INCLUDE "PROTHEUS.CH"

/*
_F_U_N_C_����������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � PCOA462  � AUTOR � Paulo Carnelossi      � DATA � 26/03/08   ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Programa para manutencao Relacionamento entre Grupos Verbas  ���
���������������������������������������������������������������������������Ĵ��
��� USO      � SIGAPCO                                                      ���
���������������������������������������������������������������������������Ĵ��
���_DOCUMEN_ � PCOA462                                                      ���
���_DESCRI_  � Programa para manutencao de Relacionamento Entre Grupo Verbas���
���_FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    ���
���          � partir do Menu ou a partir de uma funcao pulando assim o     ���
���          � browse principal e executando a chamada direta da rotina     ���
���          � selecionada.                                                 ���
���          � Exemplo: PCOA462(2) - Executa a chamada da funcao de visua-  ���
���          �                        zacao da rotina.                      ���
���������������������������������������������������������������������������Ĵ��
���_PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PCOA462(nCallOpcx, lAuto, lProc)
Local xOldInt
Local lOldAuto
Local lRet := .T.

Default lProc := .F.

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

Private cCadastro	:= STR0001 //"Relacionamento Entre Grupos de Verbas"
Private aRotina := MenuDef()

dbSelectArea("AM6")
dbSetOrder(1)

	If nCallOpcx <> Nil
		lRet := A462DLG("AM6",AM6->(RecNo()),nCallOpcx,lAuto)
	Else
		mBrowse(6,1,22,75,"AM6",,,,,, )
	EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A462DLG   �Autor  �Guilherme C. Leal   � Data �  11/26/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Tratamento da tela de Inclusao/Alteracao/Exclusao/Visuali- ���
���          � zacao                                                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A462DLG(cAlias,nRecnoAM6,nCallOpcx,lAuto)
Local oDlg
Local lCancel  := .F.
Local aButtons	:= {}
Local aUsButtons := {}
Local oEnchAM6

Local aHeadAM6
Local aColsAM6
Local nLenAM6   := 0 // Numero de campos em uso no AM6
Local nLinAM6   := 0 // Linha atual do acols
Local aRecAM6   := {} // Recnos dos registros
Local nGetD

Local aCposEnch
Local aUsField
Local aAreaAM6 := AM6->(GetArea()) // Salva Area do AM6
Local aEnchAuto  // Array com as informacoes dos campos da enchoice qdo for automatico
Local xOldInt
Local lOldAuto
Local lOk := .F.
Local nX 
Local cGrpPai
Local lProc := .F.
Local bConfirma := {|| lOk := A462Ok(nCallOpcx,oGdAM6:Cargo,aEnchAuto,oGdAM6:aCols,oGdAM6:aHeader), If(lOk, oDlg:End(),NIL) }
Local bCancela 	:= {|| lCancel := .T., oDlg:End() }
Local aCposVisual := {}

If ValType(lAuto) != "L" 
	lAuto := .F.
EndIf

Private INCLUI  := (nCallOpcx = 3)

Private oGdAM6
PRIVATE aTELA[0][0],aGETS[0]

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

If lAuto .And. nCallOpcx != 4
	Return .F.
EndIf

If nCallOpcx != 3 .And. ValType(nRecnoAM6) == "N" .And. nRecnoAM6 > 0
	DbSelectArea(cAlias)
	DbGoto(nRecnoAM6)
	If EOF() .Or. BOF()
		HELP("  ",1,"PCOREGINV",,AllTrim(Str(nRecnoAM6)))
		Return .F.
	EndIf
	aAreaAM6 := AM6->(GetArea()) // Salva Area do AM6 por causa do Recno e do Indice
EndIf

//������������������������������������������������������������������������Ŀ
//� Adiciona botoes do usuario na EnchoiceBar                              �
//��������������������������������������������������������������������������
If ExistBlock( "PCOA4622" )
	//P_E������������������������������������������������������������������������Ŀ
	//P_E� Ponto de entrada utilizado para inclusao de botoes de usuarios         �
	//P_E� na tela de Relacionamento entre Grupos de Grupos de Verbas             �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
	//P_E�  Ex. :  User Function PCOA4622                                         �
	//P_E�         Return { 'PEDIDO', {|| MyFun() },"Exemplo de Botao" }          �
	//P_E��������������������������������������������������������������������������

	If ValType( aUsButtons := ExecBlock( "PCOA4622", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

If !lAuto
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 0,0 TO 480,650 PIXEL  //"Relacionamento Entre Grupos de Verbas"
	oDlg:lMaximized := .T.
EndIf

aCposEnch := {"AM6_GRPPAI","AM6_DESPAI","AM6_PERC", "NOUSER"}

//������������������������������������������������������������������������Ŀ
//� Ponto de entrada para adicionar campos no cabecalho                    �
//��������������������������������������������������������������������������
If ExistBlock( "PCOA4623" )
	//P_E������������������������������������������������������������������������Ŀ
	//P_E� Ponto de entrada utilizado para adicionar campos no cabecalho          �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as os campos a serem adicionados           �
	//P_E�               Ex. :  User Function PCOA4623                            �
	//P_E�                      Return {"AM6_FIELD1","AM6_FIELD2"}                �
	//P_E��������������������������������������������������������������������������
	If ValType( aUsField := ExecBlock( "PCOA4623", .F., .F. ) ) == "A"
		AEval( aUsField, { |x| AAdd( aCposEnch, x ) } )
	EndIf
EndIf

// Carrega dados do AM6 para memoria
RegToMemory("AM6",INCLUI)

If !lAuto
	//������������������������������������������������������������������������Ŀ
	//� Enchoice com os dados dos Lancamentos                                  �
	//��������������������������������������������������������������������������
	oEnchAM6 := MSMGet():New('AM6',,nCallOpcx,,,,aCposEnch,{0,0,23,23},,,,,,oDlg,,,,,,,,,)
	oEnchAM6:oBox:Align := CONTROL_ALIGN_TOP
EndIf
//������������������������������������������������������������������������Ŀ
//� Montagem do aHeader do AM6                                             �
//��������������������������������������������������������������������������
aHeadAM6 := GetaHeader("AM6",,aCposEnch,@aEnchAuto,aCposVisual, .T. /*lWalk_Thru*/)
nLenAM6  := Len(aHeadAM6) + 1

nPos_ALI_WT := AScan(aHeadAM6,{|x| Upper(AllTrim(x[2])) == "AM6_ALI_WT"})
nPos_REC_WT := AScan(aHeadAM6,{|x| Upper(AllTrim(x[2])) == "AM6_REC_WT"})


//������������������������������������������������������������������������Ŀ
//� Montagem do aCols do AM6                                               �
//��������������������������������������������������������������������������

aColsAM6 := {}
DbSelectArea("AM6")
DbSetOrder(1)
DbSeek(xFilial()+AM6->AM6_GRPPAI)


cGrpPai := AM6->AM6_FILIAL + AM6->AM6_GRPPAI
While nCallOpcx != 3 .And. !Eof() .And. AM6->AM6_FILIAL + AM6->AM6_GRPPAI == cGrpPai
	AAdd(aColsAM6,Array( nLenAM6 ))
	nLinAM6++

	// Varre o aHeader para preencher o acols
	AEval(aHeadAM6, {|x,y| aColsAM6[nLinAM6][y] := If(Alltrim(x[2])$"AM6_ALI_WT|AM6_REC_WT",NIL,If(x[10] == "V" , CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) )) })
	
	If nPos_ALI_WT > 0
		aColsAM6[nLinAM6][nPos_ALI_WT] := "AM6"
	EndIf

	If nPos_REC_WT > 0
		aColsAM6[nLinAM6][nPos_REC_WT] := AM6->(Recno())
	EndIf
	
	// Deleted
	aColsAM6[nLinAM6][nLenAM6] := .F.
	AAdd( aRecAM6, AM6->( Recno() ) )

	AM6->(DbSkip())
	
EndDo

// Verifica se n�o foi criada nenhuma linha para o aCols
If Len(aColsAM6) = 0
	AAdd(aColsAM6,Array( nLenAM6 ))
	nLinAM6++
	// Varre o aHeader para preencher o acols
	AEval(aHeadAM6, {|x,y| aColsAM6[nLinAM6][y] := If( ! (x[2]$"AM6_ALI_WT|AM6_REC_WT"), CriaVar(AllTrim(x[2])), NIL) } )
	
	If nPos_ALI_WT > 0
		aColsAM6[nLinAM6][nPos_ALI_WT] := "AM6"
	EndIf

	If nPos_REC_WT > 0
		aColsAM6[nLinAM6][nPos_REC_WT] := 0
	EndIf

	// Deleted
	aColsAM6[nLinAM6][nLenAM6] := .F.
EndIf

If !lAuto
	//�����������������������������������������������Ŀ
	//� GetDados com os Lancamentos                   �
	//�������������������������������������������������
	If nCallOpcx = 3 .Or. nCallOpcx = 4
		nGetD:= GD_INSERT+GD_UPDATE+GD_DELETE
	Else
		nGetD := 0
	EndIf
	oGdAM6:= MsNewGetDados():New(0,0,100,100,nGetd,"AM6LinOK",,"+AM6_ID",,,9999,,,,oDlg,aHeadAM6,aColsAM6)
	oGdAM6:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGdAM6:CARGO := AClone(aRecAM6)
	
	aButtons := aClone(AddToExcel(aButtons,{ 	{"ENCHOICE",,oEnchAM6:aGets,oEnchAM6:aTela},;
												{"GETDADOS",,oGdAM6:aHeader,oGdAM6:aCols} } ))

	If nCallOpcx != 3
		AM6->(RestArea(aAreaAM6)) // Retorna Area para que os dados da enchoice aparecam corretos
		oEnchAM6:Refresh()
	EndIf

	// Quando nao for MDI chama centralizada.
	If SetMDIChild()
		ACTIVATE MSDIALOG oDlg ON INIT ( oGdAM6:oBrowse:Refresh(), EnchoiceBar( oDlg, bConfirma, bCancela, , aButtons) )
	Else
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (oGdAM6:oBrowse:Refresh(),EnchoiceBar( oDlg, bConfirma, bCancela, , aButtons) )
	EndIf
Else              
	lCancel := ! A462Ok(nCallOpcx,aRecAM6,aEnchAuto,aColsAM6,aHeadAM6)
EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt

RestArea(aAreaAM6)
Return !lCancel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � A462Ok   �Autor  �Guilherme C. Leal   � Data �  11/26/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao do botao OK da enchoice bar, valida e faz o         ���
���          � tratamento adequado das informacoes.                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A462Ok(nCallOpcx,aRecAM6,aEnchAuto,aColsAM6,aHeadAM6)
Local nI
Local nX
Local aValor
Local aAreaAM6	:= AM6->(GetArea())
Local lRegravou	:=	.F.
Local nPosField

If nCallOpcx = 1 .Or. nCallOpcx = 2 // Pesquisar e Visualizar
	Return .T.
EndIf

If INCLUI
	If !ExistChav('AM6',M->AM6_GRPPAI)
		Return .F.	
	Endif
Endif

If !A462Vld(nCallOpcx,aRecAM6,aEnchAuto,aColsAM6,aHeadAM6)
	Return .F.
EndIf

//������������������������������������������������������������������������Ŀ
//� Ponto de entrada para validacao ou acao programada por usuario         �
//��������������������������������������������������������������������������
If ExistBlock( "PCOA4624" )
	If !ExecBlock("PCOA4624",.f.,.f.,{nCallOpcx,aEnchAuto,aColsAM6,aHeadAM6})
		Return .F.
	EndIf	
EndIf

AM6->(DbSetOrder(1))

If nCallOpcx = 3 // Inclusao

	// Grava Lancamentos
	For nI := 1 To Len(aColsAM6)

		If aColsAM6[nI][Len(aColsAM6[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("AM6",.T.)
		EndIf

		// Varre o aHeader e grava com base no acols
		AEval(aHeadAM6,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsAM6[nI][y])), ) })

		// Grava Campos do Cabecalho
		For nX := 1 To Len(aEnchAuto)
			nPosField := FieldPos(aEnchAuto[nX][2])
			If nPosField > 0
				FieldPut(nPosField,&( "M->" + aEnchAuto[nX][2] ))
			EndIf	
		Next nX

		// Grava campos que nao estao disponiveis na tela
		Replace AM6_FILIAL With xFilial()
		MsUnlock()
		
	Next nI
	
ElseIf nCallOpcx = 4 // Alteracao

	// Grava Lancamentos
	For nI := 1 To Len(aColsAM6)
	
		lRegravou	:=	.F.
		If nI <= Len(aRecAM6) .And. aRecAM6[nI] > 0
			AM6->(DbGoto(aRecAM6[nI]))
			If aColsAM6[nI][Len(aColsAM6[nI])]
				lRegravou	:=	.T.
			EndIf
			Reclock("AM6",.F.)
		Else
			If aColsAM6[nI][Len(aColsAM6[nI])] // Verifica se a linha esta deletada
				Loop
			Else
				Reclock("AM6",.T.)
			EndIf
			lRegravou := .T.
		EndIf
	
		If aColsAM6[nI][Len(aColsAM6[nI])] // Verifica se a linha esta deletada
			AM6->(DbDelete())
		Else
            
			// Varre o aHeader e grava com base no acols
			AEval(aHeadAM6,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsAM6[nI][y])), ) })
	
			// Grava Campos do Cabecalho
			For nX := 1 To Len(aEnchAuto)
				nPosField := FieldPos(aEnchAuto[nX][2])
				If nPosField > 0
					FieldPut(nPosField,&( "M->" + aEnchAuto[nX][2] ))
				EndIf	
			Next nX
	
			// Grava campos que nao estao disponiveis na tela
			Replace AM6_FILIAL With xFilial()
			MsUnlock()
			
			
			dbSelecTArea("AM6")
			
		EndIf

	Next nI

ElseIf nCallOpcx = 5 // Exclusao

	// Exclui Lancamentos
	For nI := 1 To Len(aColsAM6)

		If nI <= Len(aRecAM6) .And. aRecAM6[nI] > 0
			AM6->(DbGoto(aRecAM6[nI]))

			Reclock("AM6",.F.)
			AM6->(DbDelete())
			MsUnLock()
		EndIf		
		

	Next nI

EndIf

AM6->(RestArea(aAreaAM6))

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � A462Vld  �Autor  �Guilherme C. Leal   � Data �  11/26/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao de validacao dos campos.                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A462Vld(nCallOpcx,aRecAM6,aEnchAuto,aColsAM6,aHeadAM6)
Local nI

If !(nCallOpcx = 3 .Or. nCallOpcx = 4 .Or. nCallOpcx = 5)
	Return .T.
EndIf

If ( AScan(aEnchAuto,{|x| If(Alltrim(x[2])$"AM6_ALI_WT|AM6_REC_WT", .F., x[17] .And. Empty( &( "M->" + x[2] ) ) ) } ) > 0 )
	HELP("  ",1,"OBRIGAT")
	Return .F.
EndIf

For nI := 1 To Len(aColsAM6)
	If ! aColsAM6[nI,Len(aHeadAM6)+1] //valida somente os que nao estao deletados
		// Busca por campos obrigatorios que nao estejam preenchidos
		nPosField := AScanx(aHeadAM6,{|x,y| if(Alltrim(x[2])$"AM6_ALI_WT|AM6_REC_WT", .F. , x[17] .And. Empty(aColsAM6[nI][y])) })
		If nPosField > 0
			SX2->(dbSetOrder(1))
			SX2->(MsSeek("AM6"))
			HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+STR0002+ AllTrim(aHeadAM6[nPosField][1])+CHR(10)+CHR(13)+STR0003+Str(nI,3,0),3,1)  //"Campo: "###"Linha: "
			Return .F.
		EndIf
	EndIf	
Next nI

Return .T.

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PcoxGD1LinOK� Autor � Edson Maricate      � Data � 17-12-2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da LinOK da Getdados                                ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �PCOXFUN                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function AM6LinOK()
Local lRet			:= .T.

If !aCols[n][Len(aCols[n])]

	//������������������������������������������������������Ŀ
	//� Verifica os campos obrigatorios do SX3.              �
	//��������������������������������������������������������
	If lRet
		lRet := MaCheckCols(aHeader,aCols,n) 
	EndIf               

EndIf
	
Return lRet

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
Local aRotina 	:= {		{ STR0004	,		"AxPesqui" , 0 , 1, ,.F.},; //"Pesquisar"
							{ STR0005	, 		"A462DLG"  , 0 , 2},; //"Visualizar"
							{ STR0006	, 		"A462DLG"  , 0 , 3},; //"Incluir"
							{ STR0007	, 		"A462DLG"  , 0 , 4},; //"Alterar"
							{ STR0008	, 		"A462DLG"  , 0 , 5};  //"Excluir"
					} 

	//������������������������������������������������������������������������Ŀ
	//� Adiciona botoes do usuario no aRotina                                  �
	//��������������������������������������������������������������������������
	If ExistBlock( "PCOA4621" )
		//P_E������������������������������������������������������������������������Ŀ
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de lan�amentos                                          �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA4621                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E��������������������������������������������������������������������������
		If ValType( aUsRotina := ExecBlock( "PCOA4621", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
Return(aRotina)
