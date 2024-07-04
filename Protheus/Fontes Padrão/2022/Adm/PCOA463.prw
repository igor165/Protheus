#INCLUDE "pcoa463.ch"
#INCLUDE "PROTHEUS.CH"

/*
_F_U_N_C_����������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � PCOA463  � AUTOR � Paulo Carnelossi      � DATA � 26/03/08   ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Programa para manutencao Relacionamento entre Grupos Verbas  ���
���������������������������������������������������������������������������Ĵ��
��� USO      � SIGAPCO                                                      ���
���������������������������������������������������������������������������Ĵ��
���_DOCUMEN_ � PCOA463                                                      ���
���_DESCRI_  � Programa para manutencao de Relacionamento Entre Grupo Verbas���
���_FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    ���
���          � partir do Menu ou a partir de uma funcao pulando assim o     ���
���          � browse principal e executando a chamada direta da rotina     ���
���          � selecionada.                                                 ���
���          � Exemplo: PCOA463(2) - Executa a chamada da funcao de visua-  ���
���          �                        zacao da rotina.                      ���
���������������������������������������������������������������������������Ĵ��
���_PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Function PCOA463(nCallOpcx, lAuto, lProc)
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

Private cCadastro	:= STR0001 //"Roteiro Verbas Salariais Relacionadas"
Private aRotina := MenuDef()

dbSelectArea("AMA")
dbSetOrder(1)

If nCallOpcx <> Nil
	lRet := A463DLG("AMA",AMA->(RecNo()),nCallOpcx,lAuto)

Else
	cFiltro	:= PcoFilConf("AMA")
	
	If !Empty(cFiltro)
		MBrowse(6,1,22,75,"AMA",,,,,,,,,,,,,,cFiltro)
	EndIf
EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A463DLG   �Autor  �Guilherme C. Leal   � Data �  11/26/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Tratamento da tela de Inclusao/Alteracao/Exclusao/Visuali- ���
���          � zacao                                                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A463DLG(cAlias,nRecnoAMA,nCallOpcx,lAuto)
Local oDlg
Local lCancel  := .F.
Local aButtons	:= {}
Local aUsButtons := {}
Local oEnchAMA

Local aHeadAM7
Local aHeadAMA
Local aColsAM7
Local nLenAM7   := 0 // Numero de campos em uso no AM7
Local nLinAM7   := 0 // Linha atual do acols
Local aRecAM7   := {} // Recnos dos registros
Local nGetD

Local aCposEnch
Local aUsField
Local aAreaAMA := AMA->(GetArea()) // Salva Area do AMA
Local aAreaAM7 := AM7->(GetArea()) // Salva Area do AM7

Local aEnchAuto  // Array com as informacoes dos campos da enchoice qdo for automatico 
Local aGetDAuto  // Array com as informacoes dos campos da getdados qdo for automatico
Local xOldInt
Local lOldAuto
Local lOk := .F.
Local nX
Local cIdGrup
Local lProc := .F.
Local bConfirma := {|| lOk := A463Ok(nCallOpcx,oGdAM7:Cargo,aEnchAuto,oGdAM7:aCols,oGdAM7:aHeader,aGetDAuto), If(lOk, oDlg:End(),NIL) }
Local bCancela 	:= {|| lCancel := .T., oDlg:End() }
Local aCposVisual := {}
Local nPos_Sequen

If ValType(lAuto) != "L"
	lAuto := .F.
EndIf

Private INCLUI  := (nCallOpcx = 3)

Private oGdAM7
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

If nCallOpcx != 3 .And. ValType(nRecnoAMA) == "N" .And. nRecnoAMA > 0

	DbSelectArea(cAlias)
	DbGoto(nRecnoAMA)
	If EOF() .Or. BOF()
		HELP("  ",1,"PCOREGINV",,AllTrim(Str(nRecnoAMA)))
		Return .F.
	EndIf
	aAreaAMA := AMA->(GetArea()) // Salva Area do AM7 por causa do Recno e do Indice
	
EndIf

//������������������������������������������������������������������������Ŀ
//� Adiciona botoes do usuario na EnchoiceBar                              �
//��������������������������������������������������������������������������
If ExistBlock( "PCOA4632" )

	//P_E������������������������������������������������������������������������Ŀ
	//P_E� Ponto de entrada utilizado para inclusao de botoes de usuarios         �
	//P_E� na tela de Relacionamento entre Grupos de Grupos de Verbas             �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
	//P_E�  Ex. :  User Function PCOA4632                                         �
	//P_E�         Return { 'PEDIDO', {|| MyFun() },"Exemplo de Botao" }          �
	//P_E��������������������������������������������������������������������������
	
	If ValType( aUsButtons := ExecBlock( "PCOA4632", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

If !lAuto
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 0,0 TO 480,650 PIXEL  //"Roteiro Verbas Salariais Relacionadas"
	oDlg:lMaximized := .T.
EndIf

aCposEnch := {"AMA_CODIGO","AMA_DESCRI","AMA_VARCOD","AMA_TPCOD","NOUSER"}


//������������������������������������������������������������������������Ŀ
//� Ponto de entrada para adicionar campos no cabecalho                    �
//��������������������������������������������������������������������������
If ExistBlock( "PCOA4633" )                                                 

	//P_E������������������������������������������������������������������������Ŀ
	//P_E� Ponto de entrada utilizado para adicionar campos no cabecalho          �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as os campos a serem adicionados           �
	//P_E�               Ex. :  User Function PCOA4633                            �
	//P_E�                      Return {"AM7_FIELD1","AM7_FIELD2"}                �
	//P_E��������������������������������������������������������������������������
	If ValType( aUsField := ExecBlock( "PCOA4633", .F., .F. ) ) == "A"
		AEval( aUsField, { |x| AAdd( aCposEnch, x ) } )
	EndIf
	
EndIf

// Carrega dados do AMA para memoria
RegToMemory("AMA",INCLUI)

If INCLUI
	If !Empty(MV_PAR02)
		M->AMA_TPCOD	:= MV_PAR02
	Endif
	
	If !Empty(MV_PAR03)
		M->AMA_VARCOD	:= MV_PAR03
	Endif
EndIf


//������������������������������������������������������������������������Ŀ
//� Montagem do aHeader do AM7                                             �
//��������������������������������������������������������������������������
aHeadAM7 := GetaHeader("AM7",,{"AM7_IDGRUP","AM7_DESCRI"},@aGetDAuto,aCposVisual, .T. /*lWalk_Thru*/)

If !lAuto
	//������������������������������������������������������������������������Ŀ
	//� Enchoice com os dados dos Lancamentos                                  �
	//��������������������������������������������������������������������������
	oEnchAMA := MSMGet():New('AMA',,nCallOpcx,,,,aCposEnch,{0,0,40,40},,,,,,oDlg,,,,,,,,,)
	oEnchAMA:oBox:Align := CONTROL_ALIGN_TOP
EndIf

//������������������������������������������������������������������������Ŀ
//� Montagem do aHeader do AMA                                             �
//��������������������������������������������������������������������������
aHeadAMA := GetaHeader("AMA",, aCposEnch ,@aEnchAuto,aCposVisual, .T. /*lWalk_Thru*/)

nLenAM7  := Len(aHeadAM7) + 1

nPos_ALI_WT := AScan(aHeadAM7,{|x| Upper(AllTrim(x[2])) == "AM7_ALI_WT"})
nPos_REC_WT := AScan(aHeadAM7,{|x| Upper(AllTrim(x[2])) == "AM7_REC_WT"})
nPos_Sequen := AScan(aHeadAM7,{|x| Upper(AllTrim(x[2])) == "AM7_SEQUEN"})

//������������������������������������������������������������������������Ŀ
//� Montagem do aCols do AM7                                               �
//��������������������������������������������������������������������������

aColsAM7 := {}
DbSelectArea("AM7")
DbSetOrder(1)
DbSeek(xFilial()+AMA->AMA_CODIGO)

cIdGrup := AM7->AM7_FILIAL + AM7->AM7_IDGRUP
While nCallOpcx != 3 .And. !Eof() .And. AM7->AM7_FILIAL + AM7->AM7_IDGRUP == cIdGrup
	AAdd(aColsAM7,Array( nLenAM7 ))
	nLinAM7++
	
	// Varre o aHeader para preencher o acols
	AEval(aHeadAM7, {|x,y| aColsAM7[nLinAM7][y] := If(Alltrim(x[2])$"AM7_ALI_WT|AM7_REC_WT",NIL,If(x[10] == "V" , CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) )) })
	
	If nPos_ALI_WT > 0
		aColsAM7[nLinAM7][nPos_ALI_WT] := "AM7"
	EndIf
	
	If nPos_REC_WT > 0
		aColsAM7[nLinAM7][nPos_REC_WT] := AM7->(Recno())
	EndIf
	
	// Deleted
	aColsAM7[nLinAM7][nLenAM7] := .F.
	AAdd( aRecAM7, AM7->( Recno() ) )
	
	AM7->(DbSkip())
	
EndDo

// Verifica se n�o foi criada nenhuma linha para o aCols
If Len(aColsAM7) = 0
	AAdd(aColsAM7,Array( nLenAM7 ))
	nLinAM7++
	// Varre o aHeader para preencher o acols
	AEval(aHeadAM7, {|x,y| aColsAM7[nLinAM7][y] := If( ! (x[2]$"AM7_ALI_WT|AM7_REC_WT"), CriaVar(AllTrim(x[2])), NIL) } )
	
	If nPos_Sequen > 0
		aColsAM7[nLinAM7][nPos_Sequen] := StrZero(1, Len(AM7->AM7_SEQUEN))
	EndIf
	
	If nPos_ALI_WT > 0
		aColsAM7[nLinAM7][nPos_ALI_WT] := "AM7"
	EndIf
	
	If nPos_REC_WT > 0
		aColsAM7[nLinAM7][nPos_REC_WT] := 0
	EndIf
	
	// Deleted
	aColsAM7[nLinAM7][nLenAM7] := .F.
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
	oGdAM7:= MsNewGetDados():New(0,0,100,100,nGetd,"AM7LinOK",,"+AM7_SEQUEN",,,9999,,,,oDlg,aHeadAM7,aColsAM7)
	oGdAM7:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGdAM7:CARGO := AClone(aRecAM7)
	
	aButtons := aClone(AddToExcel(aButtons,{ 	{"ENCHOICE",,oEnchAMA:aGets,oEnchAMA:aTela},;
	{"GETDADOS",,oGdAM7:aHeader,oGdAM7:aCols} } ))
	
	If nCallOpcx != 3
		AMA->(RestArea(aAreaAMA)) // Retorna Area para que os dados da enchoice aparecam corretos
		oEnchAMA:Refresh()
	EndIf
	
	// Quando nao for MDI chama centralizada.
	If SetMDIChild()
		ACTIVATE MSDIALOG oDlg ON INIT ( oGdAM7:oBrowse:Refresh(), EnchoiceBar( oDlg, bConfirma, bCancela, , aButtons) )
	Else
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (oGdAM7:oBrowse:Refresh(),EnchoiceBar( oDlg, bConfirma, bCancela, , aButtons) )
	EndIf
Else
	lCancel := ! A463Ok(nCallOpcx,aRecAM7,aEnchAuto,aColsAMA,aHeadAMA,aGetDAuto)
EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt

RestArea(aAreaAM7)
RestArea(aAreaAMA)
Return !lCancel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � A463Ok   �Autor  �Guilherme C. Leal   � Data �  11/26/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao do botao OK da enchoice bar, valida e faz o         ���
���          � tratamento adequado das informacoes.                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A463Ok(nCallOpcx,aRecAM7,aEnchAuto,aColsAM7,aHeadAM7,aGetDAuto)
Local nI
Local nX
Local aValor
Local aAreaAM7	:= AM7->(GetArea())
Local lRegravou	:=	.F.
Local nPosField

If nCallOpcx = 1 .Or. nCallOpcx = 2 // Pesquisar e Visualizar
	Return .T.
EndIf

If INCLUI
	If ! ExistChav('AM7',M->AMA_CODIGO)
		Return .F.
	Endif
Endif

If ! A463Vld(nCallOpcx,aRecAM7,aEnchAuto,aColsAM7,aHeadAM7,aGetDAuto)
	Return .F.
EndIf

//������������������������������������������������������������������������Ŀ
//� Ponto de entrada para validacao ou acao programada por usuario         �
//��������������������������������������������������������������������������
If ExistBlock( "PCOA4634" )
	If !ExecBlock("PCOA4634",.f.,.f.,{nCallOpcx,aEnchAuto,aColsAM7,aHeadAM7,aGetDAuto})
		Return .F.
	EndIf
EndIf

AM7->(DbSetOrder(1))

If nCallOpcx = 3 // Inclusao
    
	AMA->(Reclock("AMA",.T.))
	// Grava Campos do Cabecalho
	For nX := 1 To Len(aEnchAuto)
		nPosField := AMA->(FieldPos(aEnchAuto[nX][2]))
		If nPosField > 0
			AMA->(FieldPut(nPosField,&("M->"+aEnchAuto[nX][2])))
		EndIf
	Next nX
    
	// Grava campos que nao estao disponiveis na tela
	Replace AMA->AMA_CFGPLN With AMB->AMB_CODIGO
	Replace AMA->AMA_FILIAL With xFilial("AMA")
	If aScan(aEnchAuto, {|x| Alltrim(Upper(x[2]))=="AMA_TPCOD" } ) == 0
		Replace AMA->AMA_TPCOD With M->AMA_TPCOD
	EndIf
			
	AMA->(MsUnlock())


	// Grava �tens do Roteiro
	For nI := 1 To Len(aColsAM7)			
	
		If aColsAM7[nI][Len(aColsAM7[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("AM7",.T.)
		EndIf
		
		// Varre o aHeader e grava com base no acols
		AEval(aHeadAM7,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsAM7[nI][y])), ) })
		
		
		// Grava campos que nao estao disponiveis na tela
		AM7_FILIAL := xFilial("AM7")		
		AM7_IDGRUP := M->AMA_CODIGO
		AM7_DESCR  := M->AMA_DESCRI
		MsUnlock()
		
	Next nI
	
ElseIf nCallOpcx = 4 // Alteracao	
    
	If AMA->(dbSeek(xfilial("AMA") + M->AMA_CODIGO))
		// Grava Campos do Cabecalho
		Reclock("AMA",.F.)
		For nX := 1 To Len(aEnchAuto)
			nPosField := FieldPos(aEnchAuto[nX][2])
			If nPosField > 0
				FieldPut(nPosField,&( "M->" + aEnchAuto[nX][2] ))
			EndIf
		Next nX     
		MsUnlock()
	EndIf	

	// Grava �tens do Roteiro
	For nI := 1 To Len(aColsAM7)
		
		lRegravou	:=	.F.
		If nI <= Len(aRecAM7) .And. aRecAM7[nI] > 0
			AM7->(DbGoto(aRecAM7[nI]))
			If aColsAM7[nI][Len(aColsAM7[nI])]
				lRegravou	:=	.T.
			EndIf
			Reclock("AM7",.F.)
		Else
			If aColsAM7[nI][Len(aColsAM7[nI])] // Verifica se a linha esta deletada
				Loop
			Else
				Reclock("AM7",.T.)
			EndIf
			lRegravou := .T.
		EndIf
		
		If aColsAM7[nI][Len(aColsAM7[nI])] // Verifica se a linha esta deletada
			AM7->(DbDelete())
		Else
			
			// Varre o aHeader e grava com base no acols
			AEval(aHeadAM7,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsAM7[nI][y])), ) })		
			
			// Grava campos que nao estao disponiveis na tela
			AM7_FILIAL :=  xFilial("AM7") 
			AM7_IDGRUP :=  M->AMA_CODIGO
			AM7_DESCRI :=  M->AMA_DESCRI
			MsUnlock()
			
			
			dbSelecTArea("AM7")
			
		EndIf
		
	Next nI
	
ElseIf nCallOpcx = 5 // Exclusao

	// Exclui Cabe�alho	
	If AMA->(dbSeek(xfilial("AMA") + M->AMA_CODIGO))
		Reclock("AMA",.F.)
		AMA->(DbDelete())
		MsUnlock()
	Endif	

	// Exclui �tens do Roteiro
	For nI := 1 To Len(aColsAM7)
		
		If nI <= Len(aRecAM7) .And. aRecAM7[nI] > 0
			AM7->(DbGoto(aRecAM7[nI]))
			
			Reclock("AM7",.F.)
			AM7->(DbDelete())
			MsUnLock()
		EndIf		
		
	Next nI
	
	
EndIf

AM7->(RestArea(aAreaAM7))

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � A463Vld  �Autor  �Guilherme C. Leal   � Data �  11/26/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao de validacao dos campos.                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A463Vld(nCallOpcx,aRecAM7,aEnchAuto,aColsAM7,aHeadAM7)
Local nI

If !(nCallOpcx = 3 .Or. nCallOpcx = 4 .Or. nCallOpcx = 5)
	Return .T.
EndIf

If ( AScan(aEnchAuto,{|x| If(Alltrim(x[2])$"AMA_ALI_WT|AMA_REC_WT", .F., x[17] .And. Empty( &( "M->" + x[2] ) ) ) } ) > 0 )
	HELP("  ",1,"OBRIGAT")
	Return .F.
EndIf

For nI := 1 To Len(aColsAM7)
	If ! aColsAM7[nI,Len(aHeadAM7)+1] //valida somente os que nao estao deletados
		// Busca por campos obrigatorios que nao estejam preenchidos
		nPosField := AScanx(aHeadAM7,{|x,y| if(Alltrim(x[2])$"AM7_ALI_WT|AM7_REC_WT", .F. , x[17] .And. Empty(aColsAM7[nI][y])) })
		If nPosField > 0
			SX2->(dbSetOrder(1))
			SX2->(MsSeek("AM7"))
			HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+STR0002+ AllTrim(aHeadAM7[nPosField][1])+CHR(10)+CHR(13)+STR0003+Str(nI,3,0),3,1)  //"Campo: "###"Linha: "
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
Function AM7LinOK()
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
�����������������������������������������������������������������������������
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
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
{ STR0005	, 		"A463DLG"  , 0 , 2},; //"Visualizar"
{ STR0006	, 		"A463DLG"  , 0 , 3},; //"Incluir"
{ STR0007	, 		"A463DLG"  , 0 , 4},; //"Alterar"
{ STR0008	, 		"A463DLG"  , 0 , 5};  //"Excluir"
}

//������������������������������������������������������������������������Ŀ
//� Adiciona botoes do usuario no aRotina                                  �
//��������������������������������������������������������������������������
If ExistBlock( "PCOA4631" )
	//P_E������������������������������������������������������������������������Ŀ
	//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
	//P_E� browse da tela de lan�amentos                                          �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
	//P_E�               Ex. :  User Function PCOA4631                            �
	//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
	//P_E��������������������������������������������������������������������������
	If ValType( aUsRotina := ExecBlock( "PCOA4631", .F., .F. ) ) == "A"
		AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
	EndIf
EndIf
Return(aRotina)