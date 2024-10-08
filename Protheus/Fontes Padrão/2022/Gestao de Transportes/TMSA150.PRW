#include "PROTHEUS.ch"
#Include "FWMVCDEF.CH"
#Include "TmsA150.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Tmsa150  � Autor � Robson Alves          � Data �08.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro Configuracao de Documentos.                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tmsa150()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codificacao inicial           ���
�������������������������������������������������������������������������͹��
���Programador    �  Data    � BOPS � Motivo da Alteracao                 ���
�������������������������������������������������������������������������͹��
���Mauro Paladini � 14/08/13 �      � Conversao para padrao MVC           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TmsA150()
Local oBrowse := Nil

Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DUI")
oBrowse:SetDescription(STR0001) //"Configuracao de Documentos"
oBrowse:Activate()

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ModelDef � Autor � Mauro Paladini        � Data �09.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Modelo de dados                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oModel Objeto do Modelo                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ModelDef()

Local oModel	:= Nil
Local oStruDT3	:= Nil
Local bPreValid	:= Nil
Local bPosValid := Nil
Local bComValid := Nil
Local bCancel	:= Nil

oStruDT3	:= FWFormStruct(1,"DUI")

oModel:= MpFormMOdel():New("TMSA150",  /*bPreValid*/ , /*bPosValid*/ , /*bComValid*/ ,/*bCancel*/ )
oModel:AddFields("MdFieldDUI",Nil,oStruDT3,/*prevalid*/,,/*bCarga*/)
oModel:SetDescription(STR0001) //"Configuracao de Documentos"
oModel:GetModel("MdFieldDUI"):SetDescription(STR0001) //"Configuracao de Documentos"
oModel:SetPrimaryKey({"DUI_FILIAL","DUI_DOCTMS"})

Return ( oModel )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ViewDef  � Autor � Mauro Paladini        � Data �09.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe browse de acordo com a estrutura                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oView do objeto oView                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ViewDef()
Local oModel := FwLoadModel("TMSA150")
Local oView := Nil

oView := FwFormView():New()
oView:SetModel(oModel)
oView:AddField('VwFieldDUI', FWFormStruct(2,"DUI") , 'MdFieldDUI') 
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("VwFieldDUI","TELA")

Return(oView)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MenuDef  � Autor � Mauro Paladini        � Data �14.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � MenuDef com as rotinas do Browse                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina array com as rotina do MenuDef                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Private aRotina := {}

ADD OPTION aRotina TITLE STR0004 ACTION "PesqBrw"         OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSA150" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TMSA150" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.TMSA150" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.TMSA150" OPERATION 5 ACCESS 0 //"Excluir"

Return ( aRotina )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tmsa150Val� Autor � Larson Zordan         � Data �08.07.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a serie dos documentos                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tmsa150Valid(ExpC1)                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Serie                                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TmsA150Valid(cSerie)
Local lChgX5Fil := ExistBlock("CHGX5FIL")
Local lRet      := .T.
Local cFilSX5   := xFilial('SX5')

Default cSerie  := ''

IF lChgX5Fil
	cFilSX5 := ExecBlock("CHGX5FIL",.F.,.F.)
Endif

//-- Verifica se a serie esta cadastrada na tabela 01 - Series de notas fiscais.
SX5->( DbSetOrder( 1 ) )
If SX5->( !MsSeek( cFilSX5 + '01'+ cSerie ) )
	Help('',1,'NORECNO')
	lRet := .F.	
EndIf

If lRet .And. SubStr(cSerie,1,3) $ "PED" .Or. SubStr(cSerie,1,3) $ "COL"
	Help(" ",1,"TMSA15001") //Serie de documentos "PED" nao permitida"
	lRet := .F.	
EndIf

Return lRet
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA150Whn� Autor � Eduardo de Souza      � Data � 20/08/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se o campo podera ser alterado                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tmsa150Whn()                                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function TMSA150Whn()
Local cCampo := ReadVar()
Local lRet   := .T.

If cCampo == "M->DUI_DOCFAT"
	lRet :=	M->DUI_DOCTMS == Replicate('B',Len(DUI->DUI_DOCTMS)) .Or. M->DUI_DOCTMS == Replicate('C',Len(DUI->DUI_DOCTMS)) .Or. ;
			M->DUI_DOCTMS == Replicate('H',Len(DUI->DUI_DOCTMS)) .Or. M->DUI_DOCTMS == Replicate('I',Len(DUI->DUI_DOCTMS)) .Or. ;
			M->DUI_DOCTMS == Replicate('N',Len(DUI->DUI_DOCTMS)) .Or. M->DUI_DOCTMS == Replicate('O',Len(DUI->DUI_DOCTMS))
ElseIf cCampo == "M->DUI_SEROUT" .And. Type("M->DUI_DOCFAT") <> "U"
	lRet :=	M->DUI_DOCTMS == Replicate('2',Len(DUI->DUI_DOCTMS)) .Or. M->DUI_DOCTMS == Replicate('6',Len(DUI->DUI_DOCTMS)) .Or. ;
			M->DUI_DOCTMS == Replicate('7',Len(DUI->DUI_DOCTMS)) .Or. M->DUI_DOCTMS == Replicate('8',Len(DUI->DUI_DOCTMS)) .Or. ;
			M->DUI_DOCTMS == Replicate('9',Len(DUI->DUI_DOCTMS)) .Or. M->DUI_DOCTMS == Replicate('A',Len(DUI->DUI_DOCTMS)) .Or. ;
			M->DUI_DOCTMS == Replicate('M',Len(DUI->DUI_DOCTMS)) .Or. M->DUI_DOCTMS == Replicate('P',Len(DUI->DUI_DOCTMS))
EndIf

Return lRet
/*
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �TMSA150Ser� Autor � Patricia A. Salomao   � Data � 28/10/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcao Chamada pela Consulta DVO (SXB) - Campo DUI_SERIE   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA150Ser()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA150                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMSA150Ser()
Local lChgX5Fil := ExistBlock("CHGX5FIL")
Local cFilSX5   := xFilial('SX5')
Local aSerNF    := {}
Local cTitle    := STR0002
Local lOk       := .F.
Local oDlg, oItem, nOAt

If lChgX5Fil
	cFilSX5 := ExecBlock("CHGX5FIL",.F.,.F.)
EndIf

//-- Verifica se a serie esta cadastrada na tabela 01 - Series de notas fiscais.
SX5->( DbSetOrder( 1 ) )
SX5->( MsSeek( cFilSX5 + '01' ) )

While SX5->X5_FILIAL == cFilSX5 .And. SX5->X5_TABELA == "01"
	//�������������������������������������������������������������Ŀ
	//� Se a S�rie for CPF, n�o mostra no aChoice, pois � utilizada �
	//� internamente para emissao de Cupom Fiscal.                  �
	//���������������������������������������������������������������
	If AllTrim(SX5->X5_CHAVE)!="CPF" .And. AllTrim(SX5->X5_CHAVE)!="CP"
		AADD(aSerNF, {PadR(SX5->X5_CHAVE,3), X5Descri()})
	EndIf
	dbSelectArea("SX5")
	dbSkip()
EndDo

If Len(aSerNF) == 0
	Help('',1,'NORECNO')
	Return .F.
EndIf

//������������������������������������������������������������������������Ŀ
//�Montagem da janela de exibicao                                          �
//��������������������������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE cTitle From 150,200 To 305,600 OF oMainWnd PIXEL 
	@ 05,10 LISTBOX oItem VAR cOpc Fields HEADER OemToAnsi(STR0002), OemToAnsi(STR0003) SIZE 140,65  OF oDlg PIXEL 
	oItem:SetArray(aSerNF)
	oItem:bLine := { || {aSerNF[oItem:nAt,1], aSerNF[oItem:nAt,2]}}
	DEFINE SBUTTON FROM 03,160 TYPE 1 ENABLE OF oDlg ACTION (lOk:=.T.,oDlg:End())
	DEFINE SBUTTON FROM 18,160 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()
ACTIVATE MSDIALOG oDlg VALID (nOAT := oItem:nAT,.T.) CENTERED

If lOk .And. (Inclui .Or. Altera)
	If SX5->( MsSeek( cFilSX5 + '01' + aSerNF[nOAt, 1]) )
		&(ReadVar()) := aSerNF[nOAt, 1]
	EndIf
EndIf

Return lOk
