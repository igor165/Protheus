#INCLUDE "PCOA500.ch" 
#INCLUDE "PROTHEUS.CH"

/*
_F_U_N_C_����������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � PCOA500  � AUTOR � Paulo Carnelossi      � DATA � 01/03/2006 ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Programa para manutencao de solicitacao de contingencia  a   ���
���          � partir do bloqueio de lancamentos por processo               ���
���������������������������������������������������������������������������Ĵ��
��� USO      � SIGAPCO                                                      ���
���������������������������������������������������������������������������Ĵ��
���_DOCUMEN_ � PCOA500                                                      ���
���_DESCRI_  � Programa para manutencao de solicitacao de contingencia a    ���
���          � partir do bloqueio                                           ���
���_FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    ���
���          � partir do Menu ou a partir de uma funcao pulando assim o     ���
���          � browse principal e executando a chamada direta da rotina     ���
���          � selecionada.                                                 ���
���          � Exemplo: PCOA500(2) - Executa a chamada da funcao de visua-  ���
���          �                        zacao da rotina.                      ���
���������������������������������������������������������������������������Ĵ��
���          � Adaptado em 14/11/07 por Rafael Marin para utilizar tabe�as  ���
���          � Padroes (ZU1,ZU2,ZU3,ZU4,ZU6 -> ALI,ALJ,ALK,ALL,ALM)         ���
���������������������������������������������������������������������������Ĵ��
���_PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Function PCOA500(nCallOpcx,lAuto,aCposVs)

Local lRet      := .T.                             
Local xOldInt
Local lOldAuto
Local bF12		:=	SetKey(VK_F12)
Local aDados 	:= {}

DbSelectArea("ALJ")
If ValType(lAuto) != "L" 
	lAuto := .F.
EndIf

If lAuto
	If Type('__cInternet') != 'U'
		xOldInt := __cInternet
	EndIf
	If Type('lMsHelpAuto') != 'U'
		lOldAuto := lMsHelpAuto
	EndIf
	lMsHelpAuto := .T.
	__cInternet := STR0055 //"AUTOMATICO"
EndIf

Private aCposVisual	:= aCposVs
Private cCadastro	:= STR0001 //"Manuten��o de Contingencia Or�ament�ria"
Private aRotina 	:= MenuDef()

Private cFiltroRot :=	""
SetKey(VK_F12,{|| PergFilter()})
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	If PergFilter() 
		If nCallOpcx <> Nil
			lRet := PCOA500DLG("ALI",ALI->(RecNo()),nCallOpcx,,,lAuto)
		Else
			mBrowse(6,1,22,75,"ALI",,,,,, PCOA500LEG() )
		EndIf
	Endif
EndIf
dbSelectArea("ALI")
dbSetOrder(1)
Set Filter to

lMsHelpAuto := lOldAuto
__cInternet := xOldInt
SetKey(VK_F12,bF12)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA500DLG�Autor  �Paulo Carnelossi    � Data �  01/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Tratamento da tela de Inclusao/Alteracao/Exclusao/Visuali- ���
���          � zacao                                                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOA500DLG(cAlias,nRecnoALI,nCallaRot,cR1,cR2,lAuto)
Local oDlg
Local lCancel  := .F.
Local aButtons	:= {}//{{'PMSPESQ',{||PcoA010Pesq() },"Consulta Padrao","Pesquisa"} }
Local aUsButtons := {}
Local oEnchALI

Local aHeadALJ
Local aColsALJ
Local nLenALJ   := 0 // Numero de campos em uso no ALJ
Local nLinALJ   := 0 // Linha atual do acols
Local aRecALJ   := {} // Recnos dos registros
Local nGetD
Local cCdContigencia
Local aCposEnch
Local aUsField
Local aAreaALI := ALI->(GetArea()) // Salva Area do ALI
Local aAreaALJ := ALJ->(GetArea()) // Salva Area do ALI
Local aEnchAuto  // Array com as informacoes dos campos da enchoice qdo for automatico
Local xOldInt
Local lOldAuto
Local nRecALI := nRecnoALI
Local aCpos_Nao := {}
Local nPosVal1, nPosVal2, nPosVal3, nPosVal4, nPosVal5
Local nPosIDRef, nPosIdent, nPosUM
Local aAuxArea
Local nCallOpcx	:=	aRotina[nCallARot,4]
Local lVld5001	:= .T.
Local lA500Usr	:= ExistBlock("PCOA5001",.F.,.F.)
Local cChaveAKD,aAreaAKD

Private INCLUI  := (nCallOpcx = 3)
Private oGdALJ
PRIVATE aTELA[0][0],aGETS[0]

If !AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	Return .F.
EndIf

If ValType(lAuto) != "L" 
	lAuto := .F.
EndIf

If lAuto
	If Type('__cInternet') != 'U'
		xOldInt := __cInternet
	EndIf
	If Type('lMsHelpAuto') != 'U'
		lOldAuto := lMsHelpAuto
	EndIf
	lMsHelpAuto := .T.
	__cInternet := STR0055 //"AUTOMATICO"
EndIf

If lAuto .And. !(nCallOpcx = 4 .Or. nCallOpcx = 6)
	Return .F.
EndIf

If nCallOpcx != 3 .And. ValType(nRecnoALI) == "N" .And. nRecnoALI > 0
	DbSelectArea(cAlias)
	DbGoto(nRecnoALI)
	If EOF() .Or. BOF()
		HELP("  ",1,"PCOREGINV",,AllTrim(Str(nRecnoALI)))
		Return .F.
	EndIf
	aAreaALI := ALI->(GetArea()) // Salva Area do ALI por causa do Recno e do Indice
EndIf

If lA500Usr .and. (nCallOpcx == 4 .Or. nCallOpcx == 5)

	//P_E������������������������������������������������������������������������Ŀ
	//P_E� Ponto de entrada utilizado para validar o acesso a alteracao de        �
	//P_E� contingencia.                                                          �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Logico (Pemite ou nao o acesso a rotina de contigencia)   �
	//P_E�  Ex. :  User Function PCOA5001                                         �
	//P_E�         Return ( __cUserId =="000001" )                                �
	//P_E��������������������������������������������������������������������������

	lVld5001 := ExecBlock("PCOA5001",.F.,.F.)
	lVld5001 := If(VALTYPE(lVld5001)="L",lVld5001,.T.)
	If !lVld5001
		Return .F.
	EndIf

EndIf

//******************************************************
// Exclus�o so ser� permitida pela alcada em aprovacao *
//******************************************************

If !lA500Usr .And. nCallOpcx == 5
	
	DbSelectArea("ALI")
	DbSetOrder(1)
	If ALI->ALI_STATUS == "03" .And. !FWIsAdmin( __cUserID )//Admin
		Aviso(STR0011, STR0056, {"Ok"}, 2)	// "Contingencia ja liberada e n�o pode ser excluida!"
		Return .F.
	EndIf
	
	If Alltrim(ALI->ALI_USER) != RetCodUsr() .And. !FWIsAdmin( __cUserID )
		Aviso(STR0011, STR0015, {"Ok"}, 2) //"Aten��o"###"A alterara��o ou exclus�o da solicita��o de contingencia somente podera ser efetuada por al�ada competente."
		Return .F.
	EndIf

EndIf

DbSelectArea("ALJ")
DbSetOrder(1)
DbSeek(ALI->ALI_FILIAL + ALI->ALI_CDCNTG)

//***********************************************
// Verrifica se a Contingencia ja foi utilizada *
//***********************************************

cChaveAKD := "ALJ"+&(IndexKey())
aAreaAKD := AKD->(GetArea())
DbSelectArea("AKD")
DbSetOrder(10)
If nCallOpcx != 2 .AND. DbSeek(xFilial("AKD") + cChaveAKD ) .AND. AKD->AKD_ITEM=="01" //Verifica se tem lan�amento de Contigencia
	Aviso( STR0011 , STR0050 , {"Ok"}, 2) 		//"Aten��o"###"J� existe movimento para a contingencia selecionada."
	RestArea(aAreaAKD)
	Return(.F.)
EndIf
RestArea(aAreaAKD)

//������������������������������������������������������������������������Ŀ
//� Adiciona botoes do usuario na EnchoiceBar                              �
//��������������������������������������������������������������������������
If ExistBlock( "PCOA500BTN" )
	//P_E������������������������������������������������������������������������Ŀ
	//P_E� Ponto de entrada utilizado para inclusao de botoes de usuarios         �
	//P_E� na tela de configuracao dos lancamentos                                �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
	//P_E�  Ex. :  User Function PCOA500BTN                                       �
	//P_E�         Return { 'PEDIDO', {|| MyFun() },"Exemplo de Botao" }          �
	//P_E��������������������������������������������������������������������������

	If ValType( aUsButtons := ExecBlock( "PCOA500BTN", .F., .F. ) ) == "A"
		aButtons := {}
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

If !lAuto

	DEFINE MSDIALOG oDlg TITLE STR0016 FROM 0,0 TO 480,650 PIXEL //"Manuten��o de Contingencia Orcamentaria"
	oDlg:lMaximized := .T.

EndIf

aCposEnch := PcoCpoEnchoice("ALI", aCpos_Nao)

//������������������������������������������������������������������������Ŀ
//� Ponto de entrada para adicionar campos no cabecalho                    �
//��������������������������������������������������������������������������
If ExistBlock( "PCOA500CAB" )
	//P_E������������������������������������������������������������������������Ŀ
	//P_E� Ponto de entrada utilizado para adicionar campos no cabecalho          �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as os campos a serem adicionados           �
	//P_E�               Ex. :  User Function PCOA500CAB                          �
	//P_E�                      Return {"ALI_FIELD1","ALI_FIELD2"}                �
	//P_E��������������������������������������������������������������������������
	If ValType( aUsField := ExecBlock( "PCOA500CAB", .F., .F. ) ) == "A"
		AEval( aUsField, { |x| AAdd( aCposEnch, x ) } )
	EndIf
EndIf

// Carrega dados do ALI para memoria
RegToMemory("ALI",INCLUI)

If !lAuto
	//������������������������������������������������������������������������Ŀ
	//� Enchoice com os dados dos Lancamentos                                  �
	//��������������������������������������������������������������������������
	oEnchALI := MSMGet():New('ALI',,nCallOpcx,,,,aCposEnch,{0,0,90,23},,,,,,oDlg,,,,,,,,,)
	oEnchALI:oBox:Align := CONTROL_ALIGN_TOP
EndIf

//������������������������������������������������������������������������Ŀ
//� Montagem do aHeader do ALJ                                             �
//��������������������������������������������������������������������������
aHeadALJ := GetaHeader("ALJ",,aCposEnch,@aEnchAuto,aCposVisual)
nLenALJ  := Len(aHeadALJ) + 1

nPosVal1  := AScan(aHeadALJ,{|x| Upper(AllTrim(x[2])) == "ALJ_VAL1"})
nPosVal2  := AScan(aHeadALJ,{|x| Upper(AllTrim(x[2])) == "ALJ_VAL2"})
nPosVal3  := AScan(aHeadALJ,{|x| Upper(AllTrim(x[2])) == "ALJ_VAL3"})
nPosVal4  := AScan(aHeadALJ,{|x| Upper(AllTrim(x[2])) == "ALJ_VAL4"})
nPosVal5  := AScan(aHeadALJ,{|x| Upper(AllTrim(x[2])) == "ALJ_VAL5"})
nPosIDRef := AScan(aHeadALJ,{|x| Upper(AllTrim(x[2])) == "ALJ_IDREF"})
nPosIdent := AScan(aHeadALJ,{|x| Upper(AllTrim(x[2])) == "ALJ_IDENT"})
nPosUM    := AScan(aHeadALJ,{|x| Upper(AllTrim(x[2])) == "ALJ_UM"})

If nPosIDRef > 0
	aHeadALJ[nPosIDRef][4] := 0
EndIf

//������������������������������������������������������������������������Ŀ
//� Montagem do aCols do ALJ                                               �
//��������������������������������������������������������������������������

aColsALJ := {}

If !INCLUI
	cCdContigencia := ALI->ALI_FILIAL + ALI->ALI_CDCNTG

	DbSelectArea("ALJ")
	DbSetOrder(1)
	DbSeek(cCdContigencia)
	
	While nCallOpcx != 3 .And. !Eof() .And. ALJ->ALJ_FILIAL + ALJ->ALJ_CDCNTG == cCdContigencia
		AAdd(aColsALJ,Array( nLenALJ ))
		nLinALJ++
		// Varre o aHeader para preencher o acols
		AEval(aHeadALJ, {|x,y| aColsALJ[nLinALJ][y] := IIf(x[10] == "V", CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) ) })

		If nPosVal1 > 0
			aColsALJ[nLinALJ][nPosVal1] := PCOPlanCel(ALJ->ALJ_VALOR1,ALJ->ALJ_CLASSE)
		EndIf
	
		If nPosVal2 > 0
			aColsALJ[nLinALJ][nPosVal2] := PCOPlanCel(ALJ->ALJ_VALOR2,ALJ->ALJ_CLASSE)
		EndIf
		
		If nPosVal3 > 0
			aColsALJ[nLinALJ][nPosVal3] := PCOPlanCel(ALJ->ALJ_VALOR3,ALJ->ALJ_CLASSE)
		EndIf
	
		If nPosVal4 > 0
			aColsALJ[nLinALJ][nPosVal4] := PCOPlanCel(ALJ->ALJ_VALOR4,ALJ->ALJ_CLASSE)
		EndIf
	
		If nPosVal5 > 0
			aColsALJ[nLinALJ][nPosVal5] := PCOPlanCel(ALJ->ALJ_VALOR5,ALJ->ALJ_CLASSE)
		EndIf
		
		If nPosIdent > 0 .And. !Empty(ALJ->ALJ_IDREF)
			aAuxArea := GetArea()
			AK6->(dbSetOrder(1))
			AK6->(dbSeek(xFilial()+ALJ->ALJ_CLASSE))
			If !Empty(AK6->AK6_VISUAL)
				dbSelectArea(Substr(ALJ->ALJ_IDREF,1,3))
				dbSetOrder(Val(Substr(ALJ->ALJ_IDREF,4,2)))
				dbSeek(Substr(ALJ->ALJ_IDREF,6,Len(ALJ->ALJ_IDREF)))
				aColsALJ[nLinALJ][nPosIdent] := &(AK6->AK6_VISUAL)
			EndIf
			RestArea(aAuxArea)
		EndIf
		If nPosUM > 0
			AK6->(dbSetOrder(1))
			AK6->(dbSeek(xFilial()+AK2->AK2_CLASSE))
			aAuxArea := GetArea()
			If !Empty(AK6->AK6_UM)
				If !Empty(AK2->AK2_CHAVE)
					dbSelectArea(Substr(AK2->AK2_CHAVE,1,3))
					dbSetOrder(Val(Substr(AK2->AK2_CHAVE,4,2)))
					dbSeek(Substr(AK2->AK2_CHAVE,6,Len(AK2->AK2_CHAVE)))
				EndIf
				aColsALJ[nLinALJ][nPosUM] := &(AK6->AK6_UM)
			EndIf
			RestArea(aAuxArea)
		EndIf
	
		// Deleted
		aColsALJ[nLinALJ][nLenALJ] := .F.
		
		// Adiciona o Recno no aRec
		AAdd( aRecALJ, ALJ->( Recno() ) )
		
		ALJ->(DbSkip())
		
	EndDo
EndIf

// Verifica se n�o foi criada nenhuma linha para o aCols
If Len(aColsALJ) = 0
	AAdd(aColsALJ,Array( nLenALJ ))
	nLinALJ++
	// Varre o aHeader para preencher o acols
	AEval(aHeadALJ, {|x,y| aColsALJ[nLinALJ][y] := IIf(Upper(AllTrim(x[2])) == "ALJ_ID", StrZero(1,Len(ALJ->ALJ_ID)),CriaVar(AllTrim(x[2])) ) })
	
	// Deleted
	aColsALJ[nLinALJ][nLenALJ] := .F.
EndIf

If !lAuto
	//�����������������������������������������������Ŀ
	//� GetDados com os Lancamentos                   �
	//�������������������������������������������������
	If nCallOpcx = 3 .Or. nCallOpcx = 4
//		nGetD:= GD_INSERT+GD_UPDATE+GD_DELETE
		nGetD:= GD_UPDATE+GD_DELETE
	Else
		nGetD := 0
	EndIf
	oGdALJ:= MsNewGetDados():New(0,0,100,100,nGetd,"PCOA500LOK",,"+ALJ_ID",,,9999,,,,oDlg,aHeadALJ,aColsALJ)
	oGdALJ:AddAction("ALJ_IDENT",{||PCOIdentF3("ALJ")})
	oGdALJ:AddAction("ALJ_VAL1",{||PCOEditCell(oGdALJ)})
	oGdALJ:AddAction("ALJ_VAL2",{||PCOEditCell(oGdALJ)})
	oGdALJ:AddAction("ALJ_VAL3",{||PCOEditCell(oGdALJ)})
	oGdALJ:AddAction("ALJ_VAL4",{||PCOEditCell(oGdALJ)})
	oGdALJ:AddAction("ALJ_VAL5",{||PCOEditCell(oGdALJ)})
	
	oGdALJ:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGdALJ:CARGO := AClone(aRecALJ)

	// Quando nao for MDI chama centralizada.
	If SetMDIChild()
		ACTIVATE MSDIALOG oDlg ON INIT (oGdALJ:oBrowse:Refresh(),EnchoiceBar(oDlg,{|| If(obrigatorio(aGets,aTela).And.A500Ok(nCallOpcx,nRecALI,oGdALJ:Cargo,aEnchAuto,oGdALJ:aCols,oGdALJ:aHeader),oDlg:End(),) },{|| lCancel := .T., oDlg:End() },,aButtons))
	Else
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (oGdALJ:oBrowse:Refresh(),EnchoiceBar(oDlg,{|| If(obrigatorio(aGets,aTela).And.A500Ok(nCallOpcx,nRecALI,oGdALJ:Cargo,aEnchAuto,oGdALJ:aCols,oGdALJ:aHeader),oDlg:End(),) },{|| lCancel := .T., oDlg:End() },,aButtons) )
	EndIf
Else
	lCancel := !A500Ok(nCallOpcx,nRecALI,aRecALJ,aEnchAuto,aColsALJ,aHeadALJ,lAuto)
EndIf

If lCancel
	RollBackSX8()
EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt

RestArea(aAreaALJ)
RestArea(aAreaALI)
Return !lCancel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � A500Ok   �Autor  �Guilherme C. Leal   � Data �  11/26/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao do botao OK da enchoice bar, valida e faz o         ���
���          � tratamento adequado das informacoes.                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A500Ok(nCallOpcx,nRecALI,aRecALJ,aEnchAuto,aColsALJ,aHeadALJ,lAuto)
Local nI
Local nX
Local aAreaALJ	:= ALJ->(GetArea())
Local aAreaALI	:= ALI->(GetArea())
Local aRecAux   := aClone(aRecALJ)
Local bCampo 	:= {|n| FieldName(n) }
Local nPosVal1	:= AScan(aHeadALJ,{|x| Upper(AllTrim(x[2])) == "ALJ_VAL1"})
Local nPosVal2  := AScan(aHeadALJ,{|x| Upper(AllTrim(x[2])) == "ALJ_VAL2"})
Local nPosVal3  := AScan(aHeadALJ,{|x| Upper(AllTrim(x[2])) == "ALJ_VAL3"})
Local nPosVal4  := AScan(aHeadALJ,{|x| Upper(AllTrim(x[2])) == "ALJ_VAL4"})
Local nPosVal5  := AScan(aHeadALJ,{|x| Upper(AllTrim(x[2])) == "ALJ_VAL5"})
Local nPosClas	:= AScan(aHeadALJ,{|x| Upper(AllTrim(x[2])) == "ALJ_CLASSE"})
Local cContg	:= ''
Local cFilterAux
Local cUser

If nCallOpcx = 1 .Or. nCallOpcx = 2 // Pesquisar e Visualizar
	Return .T.
EndIf

If !A500Vld(nCallOpcx,aRecALJ,aEnchAuto,aColsALJ,aHeadALJ)
	Return .F.
EndIf

ALI->(DbSetOrder(1))
ALJ->(DbSetOrder(1))

If nCallOpcx = 3 // Inclusao
	dbSelectArea("ALI")
	Reclock("ALI",.T.)
	// Grava Campos do Cabecalho
	If lAuto
		For nX := 1 To Len(aEnchAuto)
			FieldPut(FieldPos(aEnchAuto[nX][2]),&( "M->" + aEnchAuto[nX][2] ))
		Next nX
    Else
		For nx := 1 TO FCount()
			FieldPut(nx,M->&(EVAL(bCampo,nx)))
		Next nx
	EndIf
	ALI->ALI_FILIAL := xFilial("ALI")
	MsUnlock()	

	// Grava Lancamentos
	For nI := 1 To Len(aColsALJ)
		If aColsALJ[nI][Len(aColsALJ[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("ALJ",.T.)
		EndIf

		// Varre o aHeader e grava com base no acols
		AEval(aHeadALJ,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsALJ[nI][y])), ) })

		// Grava campos que nao estao disponiveis na tela
		Replace ALJ_FILIAL With xFilial()
		Replace ALJ_CDCNTG With ALI->ALI_CDCNTG
		Replace ALJ_VALOR1  With PcoPlanVal(aColsALJ[nI][nPosVal1],aColsALJ[nI][nPosClas])
		Replace ALJ_VALOR2  With PcoPlanVal(aColsALJ[nI][nPosVal2],aColsALJ[nI][nPosClas])
		Replace ALJ_VALOR3  With PcoPlanVal(aColsALJ[nI][nPosVal3],aColsALJ[nI][nPosClas])
		Replace ALJ_VALOR4  With PcoPlanVal(aColsALJ[nI][nPosVal4],aColsALJ[nI][nPosClas])
		Replace ALJ_VALOR5  With PcoPlanVal(aColsALJ[nI][nPosVal5],aColsALJ[nI][nPosClas])
		MsUnlock()
		
	Next nI
	
ElseIf nCallOpcx = 4 // Alteracao

	dbSelectArea("ALI")
	dbGoto(nRecALI)
	Reclock("ALI",.F.)

	// Grava Campos do Cabecalho
	If lAuto
		For nX := 1 To Len(aEnchAuto)
			FieldPut(FieldPos(aEnchAuto[nX][2]),&( "M->" + aEnchAuto[nX][2] ))
		Next nX
    Else
		For nx := 1 TO FCount()
			FieldPut(nx,M->&(EVAL(bCampo,nx)))
		Next nx
	EndIf	
	MsUnlock()	

	// Grava Lancamentos
	dbSelectArea("ALJ")
	//primeiro exclui os registros
	For nI := 1 TO Len(aRecAux)
		If !aColsALJ[nI][Len(aColsALJ[nI])]
			dbGoto(aRecAux[nI])
			Reclock("ALJ",.F.)
				// Varre o aHeader e grava com base no acols
				AEval(aHeadALJ,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsALJ[nI][y])), ) })
				// Grava campos que nao estao disponiveis na tela
				Replace ALJ_FILIAL With xFilial()
				Replace ALJ_CDCNTG With ALI->ALI_CDCNTG
				Replace ALJ_VALOR1  With PcoPlanVal(aColsALJ[nI][nPosVal1],aColsALJ[nI][nPosClas])
				Replace ALJ_VALOR2  With PcoPlanVal(aColsALJ[nI][nPosVal2],aColsALJ[nI][nPosClas])
				Replace ALJ_VALOR3  With PcoPlanVal(aColsALJ[nI][nPosVal3],aColsALJ[nI][nPosClas])
				Replace ALJ_VALOR4  With PcoPlanVal(aColsALJ[nI][nPosVal4],aColsALJ[nI][nPosClas])
				Replace ALJ_VALOR5  With PcoPlanVal(aColsALJ[nI][nPosVal5],aColsALJ[nI][nPosClas])
			MsUnlock()
		Else
			Reclock("ALJ",.F.)
			DbDelete()
			MsUnlock()		
		EndIf
    Next
/*
	//depois grava novos registros
	If Len(aRecAux) < Len(aColsALJ)
		For nI := Len(aRecAux) + 1 To Len(aColsALJ)
			If aColsALJ[nI][Len(aColsALJ[nI])] // Verifica se a linha esta deletada
				Loop
			Else
				Reclock("ALJ",.T.)
			EndIf
	
			// Varre o aHeader e grava com base no acols
			AEval(aHeadALJ,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsALJ[nI][y])), ) })
	
			// Grava campos que nao estao disponiveis na tela
			Replace ALJ_FILIAL With xFilial()
			Replace ALJ_CDCNTG With ALI->ALI_CDCNTG
			Replace ALJ_VALOR1  With PcoPlanVal(aColsALJ[nI][nPosVal1],ALJ->ALJ_CLASSE)
			Replace ALJ_VALOR2  With PcoPlanVal(aColsALJ[nI][nPosVal2],ALJ->ALJ_CLASSE)
			Replace ALJ_VALOR3  With PcoPlanVal(aColsALJ[nI][nPosVal3],ALJ->ALJ_CLASSE)
			Replace ALJ_VALOR4  With PcoPlanVal(aColsALJ[nI][nPosVal4],ALJ->ALJ_CLASSE)		
			Replace ALJ_VALOR5  With PcoPlanVal(aColsALJ[nI][nPosVal5],ALJ->ALJ_CLASSE)
			MsUnlock()
			
		Next nI
    EndIf
*/
ElseIf nCallOpcx = 5 // Exclusao

	dbSelectArea("ALJ")
	// Grava Lancamentos
	PcoIniLan("000356")
	For nI := 1 To Len(aRecALJ)
		dbGoto(aRecALJ[nI])
		PcoDetLan("000356","02","PCOA530",.T.) // Deleta Empenho caso exista
		Reclock("ALJ",.F.)
		dbDelete()
		MsUnlock()
	Next nI
	PcoFinLan("000356")
	IF (ALLTRIM(ALI->ALI_PROCWF)<>"")
		nTipoWF := (SuperGetMV("MV_PCOWFCT", , 0)) 
		If nTipoWF != 0  
			If nTipoWF == 1
				// Matando o processo de WorkFlow se registro for apagado (Email)
				WFKillProcess( ALI->ALI_PROCWF )
			Else
				cUser := FWWFColleagueId( __cUserID )
				// Matando o processo de WorkFlow se registro for apagado (Fluig)
				If !Empty(cUser)
					CancelProcess(VAL(ALI_PROCWF), cUser, STR0052) //"Excluido atrav�s do sistema."
				Else
					Help(" ", 1, "PCOA500USR", , STR0053 + UsrRetName(__cUserID) + STR0054, 1, 0) //"O usu�rio " + "######" + " n�o existe no Fluig"
				EndIf
			EndIf
		EndIf
	EndIf
	
	//********************************************
	// Apaga todos os registros da Contingencia  *
	//********************************************
	dbSelectArea("ALI")
	cFilterAux := dbFilter()
	SET FILTER TO  
	dbGoto(nRecALI)
	cContg := ALI->ALI_CDCNTG
	DbSetOrder(1)
	DbSeek(xFilial("ALI")+cContg)
	Do While !Eof() .and. xFilial("ALI")+ALI->ALI_CDCNTG == xFilial("ALI")+cContg
		Reclock("ALI",.F.)
		dbDelete()
		MsUnlock()
		DbSkip()
	EndDo
	SET FILTER TO &cFilterAux
EndIf

If __lSX8
	ConfirmSX8()
EndIf

ALJ->(RestArea(aAreaALJ))
ALI->(RestArea(aAreaALI))

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � A500Vld  �Autor  �Guilherme C. Leal   � Data �  11/26/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao de validacao dos campos.                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A500Vld(nCallOpcx,aRecALJ,aEnchAuto,aColsALJ,aHeadALJ)
Local nI
Local nPosTipo
If !(nCallOpcx = 3 .Or. nCallOpcx = 4 .Or. nCallOpcx = 6)
	Return .T.
EndIf


If ( AScan(aEnchAuto,{|x| x[17] .And. Empty( &( "M->" + x[2] ) ) } ) > 0 )
	HELP("  ",1,"OBRIGAT")
	Return .F.
EndIf

For nI := 1 To Len(aColsALJ)
	// Busca por campos obrigatorios que nao estejam preenchidos
	nPosField := AScanx(aHeadALJ,{|x,y| x[17] .And. Empty(aColsALJ[nI][y]) })
	If nPosField > 0
		SX2->(dbSetOrder(1))
		SX2->(MsSeek("ALJ"))
		HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+STR0034+ AllTrim(aHeadALJ[nPosField][1])+CHR(10)+CHR(13)+STR0035+Str(nI,3,0),3,1) //"Campo: "###"Linha: "
		Return .F.
	EndIf
Next nI

Return .T.

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOA500LOK  � Autor � Paulo Carnelossi    � Data � 25/08/05   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da LinOK da Getdados                                ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �PCOXFUN                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PCOA500LOK()
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
���Fun��o    �PCOA500Leg� Autor � Paulo Carnelossi      � Data � 01/03/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta as legendas da mBrowse.                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �PCOA500Leg                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PCOA500Leg(cAlias)
Local aLegenda := 	{ 	{"BR_AZUL"    	, STR0017 },;	//"Bloqueado p/ sistema (aguardando outros niveis)"
						{"DISABLE" 		, STR0018 },;	//"Aguardando Liberacao do usuario"
						{"ENABLE"   	, STR0019 },;	//"Liberado pelo usuario"
						{"BR_LARANJA"	, STR0021 },;	//"Liberado por outro usuario"
						{"BR_PRETO"   	, STR0020 },;	//"Cancelado"
						{"BR_CINZA"		, STR0041 }}	//"Cancelado por outro usuario"

						
Local aRet := {}
aRet := {}
	                           
If cAlias == Nil
	Aadd(aRet, { 'ALI->ALI_STATUS == "01"', aLegenda[1][1] } )
	Aadd(aRet, { 'ALI->ALI_STATUS == "02"', aLegenda[2][1] } )
	Aadd(aRet, { 'ALI->ALI_STATUS == "03"', aLegenda[3][1] } )
	Aadd(aRet, { 'ALI->ALI_STATUS == "05"', aLegenda[4][1] } )
	Aadd(aRet, { 'ALI->ALI_STATUS == "04"', aLegenda[5][1] } )
	Aadd(aRet, { 'ALI->ALI_STATUS == "06"', aLegenda[6][1] } )      	
Else
	BrwLegenda(cCadastro, STR0010, aLegenda) //"Legenda"
Endif

Return aRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PcoCpoEnchoice�Autor �Paulo Carnelossi � Data �  01/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna array com nomes dos campos referente ao alias       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PcoCpoEnchoice(cAlias, aCpos_Nao)
Local aCampos := {}
Local aArea := GetArea()
Local aAreaSX3 := SX3->(GetArea())

SX3->(DbSetOrder(1))
SX3->(MsSeek(cAlias))

While ! SX3->(Eof()) .And. SX3->x3_arquivo == cAlias
    If X3USO(SX3->x3_usado) .And. cNivel >= SX3->x3_nivel .And. ;
       aScan(aCpos_Nao, AllTrim(SX3->x3_campo))==0
	    aAdd(aCampos, AllTrim(SX3->x3_campo))
	EndIf    
	SX3->(DbSkip())
EndDo

RestArea(aArea)
RestArea(aAreaSX3)

Return aCampos


/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    �PCOEditCell� Autor �                       � Data �04.12.2007���
��������������������������������������������������������������������������Ĵ��
���Descri��o �                                                             ���
��������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPCO                                                      ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function PCOEditCell(oGd)
Local aDim
Local oDlg
Local oGet1
Local oBtn
Local cMacro := ''
Local cPict	:= ''
Local nRow   := oGD:oBrowse:nAt
Local oOwner := oGD:oBrowse:oWnd
Local cClasse	:= oGD:aCols[oGD:oBrowse:nAt][aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "ALJ_CLASSE"})]
Local nValor	:= PcoPlanVal(oGD:aCols[oGD:oBrowse:nAt][oGD:oBrowse:nColPos],cClasse)
Local bChange := { ||  nValor := &cMacro,.T. }
Local oRect := tRect():New(0,0,0,0)            // obtem as coordenadas da celula (lugar onde
Local cVlrFinal := ""

If Empty(cClasse)
   Return(cVlrFinal)
EndIf   

oGD:oBrowse:GetCellRect(oGD:oBrowse:nColPos,,oRect)   // a janela de edicao deve ficar)

aDim  := {oRect:nTop,oRect:nLeft,oRect:nBottom,oRect:nRight}

DEFINE MSDIALOG oDlg OF oOwner  FROM 0, 0 TO 0, 0 STYLE nOR( WS_VISIBLE, WS_POPUP ) PIXEL

PcoPlanCel(0,cClasse,,@cPict)
cMacro := "M->CELL"
&cMacro:= nValor

@ 0,0 MSGET oGet1 VAR &(cMacro) SIZE 0,0 OF oDlg FONT oOwner:oFont PICTURE cPict PIXEL HASBUTTON VALID Eval(bChange)
oGet1:Move(-2,-2, (aDim[ 4 ] - aDim[ 2 ]) + 4, aDim[ 3 ] - aDim[ 1 ] + 4 )

@ 0,0 BUTTON oBtn PROMPT "ze" SIZE 0,0 OF oDlg
oBtn:bGotFocus := {|| oDlg:nLastKey := VK_RETURN, oDlg:End(0)}

oGet1:cReadVar  := cMacro

ACTIVATE MSDIALOG oDlg ON INIT oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])

cVlrFinal := PcoPlanCel(nValor,cClasse)
oGD:aCols[oGD:oBrowse:nAt][oGD:oBrowse:nColPos]	:= cVlrFinal
oGD:oBrowse:nAt := nRow
SetFocus(oGD:oBrowse:hWnd)
oGD:oBrowse:Refresh()

Return(cVlrFinal)   


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PCOA500AVL� Autor �                       � Data �03.12.2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cancela solicitacoes vencidas                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPCO                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PCOA500AVL(cAlias,nRecnoALI,nCallOpcx,cR1,cR2,lAuto)

If ALI->ALI_STATUS $ "03/05"
	Aviso(STR0011, STR0023, {"Ok"}) //"Aten��o"###"Solicita��o de contingencia ja liberada!"

ElseIf ALI->ALI_STATUS $ "04/06"
	Aviso(STR0011, STR0027, {"Ok"}) //  //"Aten��o"###"Solicita��o de contingencia ja Cancelada!"

ElseIf PCOA500DLG(cAlias,nRecnoALI,2,cR1,cR2,lAuto)  //visualizar

	If ALI_STATUS $ "01/02" .And. dDataBase > ALI->ALI_DTVALI
		If Aviso(STR0011, STR0024,{STR0025, STR0026}, 2) == 1 //"Aten��o"###"Solicita��o de contingencia com validade vencida! Cancelar ?"###"Sim"###"N�o"
			RecLock("ALI", .F.)
			ALI->ALI_STATUS := "04"  // Cancelado
			MsUnLock()
		EndIf
	EndIf
EndIf

Return
                                                        

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PCOA500BLQ� Autor �                       � Data �23.12.2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cancela solicitacao selecionada e as do mesmo nivel         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPCO                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PCOA500BLQ(cAlias,nRecnoALI,nCallOpcx,cR1,cR2,lAuto)

Local cFilterAux

If ALI->ALI_STATUS $ "03/05"
	Aviso(STR0011 , STR0023 ,{"Ok"}) //"Atencao"###"Solicita��o de contingencia ja liberada!"
ElseIf ALI->ALI_STATUS $ "04/06"
	Aviso(STR0011, STR0027, {"Ok"}) //"Atencao"###"Solicita��o de contingencia cancelada!"
ElseIf PCOA500DLG(cAlias,nRecnoALI,2,cR1,cR2,lAuto)  //visualizar
	If Aviso(STR0011 , STR0028, {STR0025, STR0026}, 2) == 1 //"Atencao"###"Cancelar a solicita��o de contingencia ?"###"Sim"###"N�o"
		dbSelectArea("ALI")
		cFilterAux := dbFilter()
		SET FILTER TO 
		PCOA530ALC(6)
		SET FILTER TO &cFilterAux
		
		//P_E������������������������������������������������������������������������Ŀ
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios na     �
		//P_E� preparacao da contingencia para Solicita��o de Compras Customizado     �
		//P_E� Implementado para satisfazer o GAP087, na data de 24/02/2012           �
		//P_E��������������������������������������������������������������������������
		If ExistBlock( "PC500BLQ" )
			ExecBlock( "PC500BLQ", .F., .F.)
		EndIf
	EndIf
EndIf

Return
                            

                        
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PCOA500LIB� Autor �                       � Data �23.12.2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Libera contingencia selecionada                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPCO                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PCOA500LIB(cAlias,nRecnoALI,nCallOpcx,cR1,cR2,lAuto)

If ALI->ALI_STATUS $ "03/05"
	Aviso(STR0011, STR0023,{"Ok"}) //"Atencao"###"Solicita��o de contingencia ja liberada!"
ElseIf ALI->ALI_STATUS == "01"
	Aviso(STR0011, STR0029,{"Ok"}) //"Atencao"###"Solicita��o de contingencia aguardando liberacao de nivel anterior!"
ElseIf ALI->ALI_STATUS $ "04/06"
	Aviso(STR0011, STR0027,{"Ok"}) //"Atencao"###"Solicita��o de contingencia cancelada!"

ElseIf	PCOA500DLG(cAlias,nRecnoALI,4,cR1,cR2,lAuto)  //alterar
	If Aviso(STR0011, STR0030,{STR0025, STR0026}, 2) == 1 //"Atencao"###"Liberar a solicita��o de contingencia ?"###"Sim"###"Nao"
		PCOA500GER()
		dbSelectArea(cAlias)
//		SET FILTER TO &cFiltroRot.

		//P_E������������������������������������������������������������������������Ŀ
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios na     �
		//P_E� preparacao da contingencia para Solicita��o de Compras Customizado     �
		//P_E� Implementado para satisfazer o GAP087, na data de 24/02/2012           �
		//P_E��������������������������������������������������������������������������
		If ExistBlock( "PC500LIB" )
			ExecBlock( "PC500LIB", .F., .F.)
		EndIf
	EndIf
EndIf

Return

        
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PCOA500GER� Autor �                       � Data �23.12.2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera lancamento orcamentario para contingencias liberadas   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPCO                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PCOA500GER(lWF, cCodBlq, cUser)
Local cFilterAux := ""
DEFAULT lWF := .F.
//		PcoIniLan('000356')
		dbSelectArea("ALI")
		cFilterAux := dbFilter()
		SET FILTER TO 
		Begin Transaction                                                 
		nRec	:=	ALI->(Recno())
		If PCOA530ALC(4, cCodBlq, , lWF, cUser) //Se liberou ate o ultimo nivel gera os lancamentos
			ALI->(MsGoTo(nRec))
			//LINHAS ABAIXO INSERIDAS PARA POSIONAR CORRETAMENTE NA TABELA ALJ
			DBSELECTAREA("ALJ")
			DBSETORDER(1)

			If ALJ->(dbSeek(xFilial("ALJ")+ALI->ALI_CDCNTG))
				While !ALJ->(Eof()) .And. ALJ->(ALJ_FILIAL+ALJ_CDCNTG) ==  xFilial("ALJ")+ALI->ALI_CDCNTG 	
//					PcoDetLan('000356','01','PCOA500')
					ALJ->(dbSkip())
				EndDo	
			EndIf           
      	Endif
		End Transaction
//		PcoFinLan('000356')
		dbSelectArea("ALI")
		SET FILTER TO &cFilterAux
		
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PCOA500VND� Autor �                       � Data �23.12.2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cria um Get para edicao da celula da planilha de itens      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPCO                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PCOA500VND()
Local aRecVenc := {}
Local cFilterAux
Local nX 
Local aArea
Local lVld5002	:= .T.
Local lBlqVenc  := ExistBlock("PCOA5002",.F.,.F.)

If lBlqVenc

	//P_E������������������������������������������������������������������������Ŀ
	//P_E� Ponto de entrada utilizado para validar o acesso a rotina de bloqueio  �
	//P_E� de contingencias vencidas.                                             �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Logico (Permite ou nao o acesso a rotina)                 �
	//P_E�  Ex. :  User Function PCOA5002                                         �
	//P_E�         Return ( __cUserId=="000003" )                                 �
	//P_E��������������������������������������������������������������������������

	lVld5002 := ExecBlock("PCOA5002",.F.,.F.)
	lVld5002 := If(VALTYPE(lVld5002)="L",lVld5002,.F.)

EndIf

If  (FWIsAdmin( __cUserID ) .and. !lBlqVenc) .or. (lBlqVenc .and. lVld5002)

	dbSelectArea("ALI")
	cFilterAux := dbFilter()
	SET FILTER TO
	aArea	:=	GetArea()
	dbSelectArea("ALI")
	dbSetOrder(1)
	dbSeek(xFilial("ALI"))
	
	While ALI->(!Eof() .And. ALI_FILIAL == xFilial("ALI"))
	    //verifica as solicitacoes de contingencia em aberto ou em avaliacao
		If ALI->ALI_STATUS $ "01;02" .And. dDataBase > ALI->ALI_DTVALI
			aAdd(aRecVenc, ALI->(Recno()))
		EndIf
		ALI->(dbSkip())
	End
	If Len(aRecVenc) > 0 
		If Aviso(STR0011, STR0031, {STR0025, STR0026}, 2) == 1 //"Atencao"###"Bloqueia as solicita��es de contingencia vencidas ?"
		 	For nX := 1 TO Len(aRecVenc)
		    	dbSelectArea("ALI")
		   		dbGoto(aRecVenc[nX])
				PCOA530ALC(6) 
			 Next // nX
		Endif			 
	Else
		Aviso(STR0011, STR0032, {STR0008}) //"Atencao"###"Nao foi achada nenhuma contingencia vencida."###"Fechar"
	EndIf                
	RestArea(aArea)
	SET FILTER TO &cFilterAux
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PergFilter� Autor �                       � Data �23.12.2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Filtra browse inicial conforme resposta do pergunte         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPCO                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function PergFilter()
Local lRet	:=	.F.
Local lBlqVenc := ExistBlock("PCOA5003",.F.,.F.)
Local cFiltroRot

If	Pergunte("PCO500",.T.)
	lRet	:=	.T.	
	
	cFiltroRot :=	If(!FWIsAdmin(__cUserID),"('"+__cUserID+"' == ALI_USER)","")

	If lBlqVenc
	
		//P_E������������������������������������������������������������������������Ŀ
		//P_E� Ponto de entrada utilizado para controle do filtro da Tela do Browse   �
		//P_E� Parametros : [1] = Filtro padrao aplicado no browse                    �
		//P_E� Retorno    : Filtro ADVPL utilizado no filtro do Browse.               �
		//P_E�  Ex. :  User Function PCOA5003                                         �
		//P_E�         Local cFil := Paramixb[1]                                      �
		//P_E�         Return ( cFil )                                                �
		//P_E��������������������������������������������������������������������������
	
		cFiltroRot := ExecBlock("PCOA5003",.F.,.F.,{cFiltroRot})
		
	EndIf	
	

	//������������������������������������������������������Ŀ
	//� Controle de Aprovacao : CR_STATUS -->                �
	//� 01 - Bloqueado p/ sistema (aguardando outros niveis) �
	//� 02 - Aguardando Liberacao do usuario                 �
	//� 03 - Liberado pelo usuario                    		 �
	//� 04 - Bloqueado pelo usuario                   		 �
	//� 05 - Liberado por outro usuario              		 �
	//��������������������������������������������������������
	//��������������������������������������������������������������Ŀ
	//� Inicaliza a funcao FilBrowse para filtrar a mBrowse          �
	//����������������������������������������������������������������
	dbSelectArea("ALI")
	dbSetOrder(1)
	Do Case
	Case mv_par01 == 1
		cFiltroRot += IIf(Empty(cFiltroRot),"",".And.")+"ALI_STATUS=='02'"
	Case mv_par01 == 2
		cFiltroRot +=  IIf(Empty(cFiltroRot),"",".And.")+"(ALI_STATUS=='03'.OR.ALI_STATUS=='05')"
	Case mv_par01 == 3
		cFiltroRot +=  IIf(Empty(cFiltroRot),"",".And.")+"(ALI_STATUS=='01'.OR.ALI_STATUS=='04')"
	OtherWise
		cFiltroRot +=  IIf(Empty(cFiltroRot),"",".And.")+"ALI_STATUS!='01'"
	EndCase

	dbSelectArea("ALI")
	dbSetOrder(1)
	If !Empty(cFiltroRot)
		SET FILTER TO &cFiltroRot
	Endif
Endif
Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Pco530Key� Autor �                       � Data �20.10.2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina de geracao de senha.                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPCO                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Pco530Key()

Local aArea := getArea()

Local lSenha	:= SUPERGETMV("MV_PCOCTGP",.F.,.F.)
Local lBlqKey  	:= ExistBlock("PCOA5004")
Local lVld5004	:= .F.

If lBlqKey

	//P_E������������������������������������������������������������������������Ŀ
	//P_E� Ponto de entrada utilizado para validar o acesso a rotina de           �
	//P_E� solicitacao de senhas.                                                 �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Logico (Permite ou nao o acesso a rotina)                 �
	//P_E�  Ex. :  User Function PCOA5004                                         �
	//P_E�         Return ( __cUserId=="000003" )                                 �
	//P_E��������������������������������������������������������������������������
	
	lVld5004	:= ExecBlock("PCOA5004",.F.,.F.)

EndIf

If lVld5004 .or. FWIsAdmin( __cUserID )

	If lSenha
	
		DbSelectArea("ALJ")
		DbSetOrder(1)
		DbSeek(xFilial("ALJ") + ALI->ALI_CDCNTG )
		Aviso( STR0046 , STR0045 + PcoCtngKey(),{STR0047}) //"A senha para utiliza��o da contingencia �:"###"Aten��o!"###"OK"
	
	Else

		Aviso(STR0046,STR0048,{STR0047})	//"Aten��o!"###"OK"###"O Controle de senha est� desativado!"

	EndIf

Else

	Aviso(STR0046,STR0049,{STR0047})//"Aten��o!"###"Usuario sem permisao para  solicitar senha de contingencia!"###"OK"

EndIf

RestArea(aArea)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MenuDef  � Autor �                       � Data �23.12.2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cria definicoes de botoes para menu da Janela               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPCO                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()
Local aRotina 	:= {	{ STR0002		,		"AxPesqui" 		, 0 , 1,0,.F.},;  //"Pesquisar"
							{ STR0003		, 		"PCOA500DLG" 	, 0 , 2},;  //"Visualizar"
							{ STR0004		, 		"PCOA500DLG" 	, 0 , 5},;  //"Excluir"
							{ STR0005		, 		"PCOA500LIB" 	, 0 , 4},;  //"Liberar"
							{ STR0006		, 		"PCOA500BLQ" 	, 0 , 4},;  //"Cancelar"
							{ STR0007		, 		"PCOA500VND"   	, 0 , 4},;  //"Blq. Vencidas"
							{ STR0009		, 		'MsAguarde({|lEnd| WFRETURN({ cEmpAnt, cFilAnt },.T.,.F.)},"'+STR0042+'","'+STR0043+'",.T.)' 	, 0 , 4},;  //"Receber WF" //"Aguarde..."###"Recebendo respostas de WorkFlow."
							{ STR0044		, 		"Pco530Key" 	, 0 , 4},; //"Senha"
							{ STR0010		, 		"PCOA500LEG"  	, 0 , 1} }  //"Legenda"
Local lPCO50Menu := ExistBlock("PCO500Men")

If lPCO50Menu
	aRotina := aClone(Execblock("PCO500Men",.F.,.F.,aRotina))
Endif

Return(aRotina)    
