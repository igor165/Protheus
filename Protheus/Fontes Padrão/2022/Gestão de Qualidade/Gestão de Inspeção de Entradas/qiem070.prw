#include "QIEM070.CH"
#include "PROTHEUS.CH"


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QIEM070	� Autor � Vera Lucia S. Simoes  � Data � 08/02/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Transferencia de Pendencias do Follow-up NNC   ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
�������������������������������������������������������������������������Ĵ��
��� STR		 � Ultimo utilizado: 0009                                     ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := {{"Pesquisar", "AxPesqui",  0, 1,,.F.},;		
				{STR0012,"A240Visual", 0, 2},; //"Visualizar"
				{STR0013,   "M070Inclui", 0, 3},; //"Incluir"	
				{STR0014,   "M070Altera", 0, 6},;//Alterar	
				{STR0015,   "M070Deleta", 0, 5}} //"Excluir"	
				
Return aRotina

Function QIEM070()
Local nOpcA 	 := 0
Local nAcols	 := 0					// No. elementos do aCols
Local lGravaOk   := .T.
Local oDlg
Local oGet
Local oSize 
Local oGroup
Local aAlter    := {}
Local cAlias	:= "QE5"
Local aSizeAut 	:= MsAdvSize()
Local aObjects	:= {	{ 600, 100, .T., .T. } }, nAlias := Select("QAA")
Local aInfo 	:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 } 
Local aPosObj 	:= MsObjSize( aInfo, aObjects, .T. )
Local aGets		:= {}
Local aTela		:= {}

Private cCadastro := ""
Private aHeader	  := {}
Private aCols	  := {}
Private nUsado    := 0
Private nOpc      := 4
Private nPosRes
Private nPosDRe
Private nPosNomUsu 
Private nPosFilRes 

Private aRotina := MenuDef()
							
//��������������������������������������������������������������Ŀ
//� Verifica se o usuario tem o nivel exigido para transferencia �
//����������������������������������������������������������������
// Nivel 102: Transfere Pendencias
If !QA_NivAces(102,STR0006)	// "Usu�rio n�o tem o n�vel de acesso exigido."
	Return(.F.)
EndIf

INCLUI	:= .T.
ALTERA	:= .F.
EXCLUI	:= .F.
aCols 	:= {}
aHeader	:= {}


Aadd(aHeader,{ "","LEGENDA","@BMP",0,0,"","","","QAA","R"})

//�����������������Ŀ
//� Monta o aHeader �
//�������������������
// Campo Filial do Usuario	
Q070GetSX3("QAA_FILIAL") // 1

// Campo Matricula do Usuario
Q070GetSX3("QAA_MAT") // 2

// Campo Nome do Usuario
Q070GetSX3("QAA_NOME") // 3

// Campo Data de Demissao
Q070GetSX3("QAA_FIM") // 4

// Campo Equipe Follow-up de NNC
Q070GetSX3("QE5_EQUIPE") // 5

// Campo Filial do Novo Usuario
Q070GetSX3("QE5_FILRES") // 6
nPosFilRes := Len(aHeader)

// Campo novo usuario
cValid := AllTrim( GetSx3Cache("QE5_RESPON", "X3_VALID"))
If ! Empty(cValid)
	cValid += " .And. "
Endif
cValid += "M070Status()"

Q070GetSX3("QE5_RESPON", cValid) // 7
nPosRes    := Len(aHeader)

// Campo Nome do novo Usuario
Q070GetSX3("QE5_NOMUSU") //8
nPosDRe    := Len(aHeader)
nPosNomUsu := Len(aHeader)

// Inclui coluna de registro atraves de funcao generica
ADHeadRec("QAA",aHeader)
nPosAli := Ascan(aHeader,{|x| AllTrim(x[2]) == "QAA_ALI_WT"})
nPosRec := Ascan(aHeader,{|x| AllTrim(x[2]) == "QAA_REC_WT"})

nUsado := Len(aHeader)

//����������������������������������������������������������������������Ŀ
//� Verifica a posicao dos campos no aHeader p/ posterior consistencia   �
//������������������������������������������������������������������������

//��������������������������������������������������������Ŀ
//� Follow-up de NNCs:                                     �
//� Verifica o arquivo de associacao de Responsaveis a     �
//� Equipes de Follow-up (QE5), e se algum foi demitido,   �
//� deve ser substituido.                                  �
//����������������������������������������������������������	

DbSelectArea("QAA")
Set Filter To
dbSetOrder(1)
DbGoTop()

DbSelectArea("QE5")
QE5->(dbSetOrder(1))
QE5->(dbSeek(xFilial("QE5")))
While !QE5->(Eof())
	// Verifica se o Responsavel associado a equipe esta demitido
  	If QAA->(dbSeek(QE5->QE5_FILRES+QE5->QE5_RESPON))
  		If ! QA_SitFolh()
			Aadd(aCols,Array(nUsado+1))	// Cria novo vetor acols
			nAcols := Len(aCols)
			aCols[nAcols,1] := "BR_VERMELHO"
			aCols[nAcols,2] := xFilial("QAA")
			aCols[nAcols,3] := QE5->QE5_RESPON
			aCols[nAcols,4] := QAA->QAA_NOME
			aCols[nAcols,5] := QAA->QAA_FIM
			aCols[nAcols,6] := QE5->QE5_EQUIPE
			aCols[nAcols,nPosFilRes] := CriaVar(Alltrim("QE5_FILRES"))
			aCols[nAcols,nPosRes] 	 := CriaVar(Alltrim("QAA_MAT"))
			aCols[nAcols,nPosNomUsu] := Space(Len(QAA->QAA_NOME))
			If nPosAli > 0 .and. nPosRec > 0
				aCols[nAcols,nPosAli] := "QAA"
				If IsHeadRec(aHeader[nPosRec,2])
					aCols[nAcols,nPosRec] := QAA->(RecNo())
				EndIf
			Endif
			aCols[nAcols,nUsado+1] := .F.
		EndIf
  	EndIf
  	QE5->(dbSkip())	
EndDo

//���������������������������������������������Ŀ
//� Verifica se existe dados para transferencia �
//�����������������������������������������������
If Len(aCols) == 0
	MessageDlg(STR0002,,2)	// "N�o h� dados para transfer�ncia."
Else
	nOpc := 4
	Aadd(aAlter,"QE5_FILRES")
	Aadd(aAlter,"QE5_RESPON")
    aRotina[nOpc,4] := 6

	//��������������������������������������������������������������Ŀ
	//� Calcula dimens�es                                            �
	//����������������������������������������������������������������
	oSize := FwDefSize():New()
	
	oSize:AddObject( "ENCHOICE"    ,  100, 30, .T., .T. )
	oSize:AddObject( "GETDADOS"   ,  100, 70, .T., .T. ) 
	
	oSize:lProp := .T. // Proporcional             
	oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
	
	oSize:Process() // Dispara os calculos  	
		
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0003) FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	
	oEnchoice := MsMGet():New(cAlias,,nOpc,,,,,;
							{ oSize:GetDimension("ENCHOICE","LININI"),;
							  oSize:GetDimension("ENCHOICE","COLINI"),;
							  oSize:GetDimension("ENCHOICE","LINEND"),;
							  oSize:GetDimension("ENCHOICE","COLEND")};
							  ,,,,,,oDlg,.T.,.T.,,,,,,,.T.) 
	
	oGroup := TGroup():Create(oDlg,oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
						 oSize:GetDimension("GETDADOS","LINEND"),oSize:GetDimension("GETDADOS","COLEND");
						,"Respons�veis",,,.T.)
	oGroup:oFont:= oFont
	
	oGetd:=  MsNewGetDados():New(aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4],GD_INSERT+GD_UPDATE+GD_DELETE,"AllwaysTrue","AllwaysTrue",,aAlter,,99,"AllwaysTrue",,"AllwaysTrue",oDlg, aHeader, aCols)

    ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{||nOpcA :=1,If(oGetd:TudoOk(),;
	If(!Obrigatorio(aGets,aTela),nOpcA := 0,oDlg:End()),nOpcA:=0)},{||oDlg:End()}))
	
	If nOpcA == 1
		MsgRun(STR0008,STR0009,{||M070GrvPen()}) //"Gravando novos responsaveis ..."###"Aguarde..."
	EndIf 
EndIf

dbSelectArea(cAlias)
Return nOpcA

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �QEM070LiOk� Autor � Vera Lucia S. Simoes  � Data � 08/02/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se a linha digitada esta' Ok - Getdados das Penden.���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado. 						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIEM070													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QEM070LiOk(o)
Local lRet := .T.

//�����������������������������������������������������������Ŀ
//� Verifica se o novo responsavel existe e nao esta demitido �
//�������������������������������������������������������������
QAA->(dbSetOrder(1))
If !QAA->(dbSeek(aCols[n,nPosFilRes]+aCols[n,nPosRes])) .And. ! Empty(aCols[n,nPosRes])  
	MessageDlg(STR0004,,1)	// "Respons�vel n�o cadastrado."
	lRet := .F.
Else
	If ! QA_SitFolh()
		MessageDlg(STR0005,,1)	// "Respons�vel foi demitido."
		lRet := .F.
	EndIf
EndIf
Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �QEM070TuOk� Autor � Vera Lucia S. Simoes  � Data � 08/02/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se toda a getdados esta' Ok - Getdados das Penden. ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado. 						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIEM070													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QEM070TuOk(o)
Local nI
Local lRet := .T.

For nI := 1 to Len(aCols)
	If !QEM070LiOk(o)
		lRet := .F.
		Exit
	EndIf
Next
Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �M070GrvPen� Autor � Vera Lucia S. Simoes  � Data � 08/02/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Troca os responsaveis demitidos pelos novos                ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIEM070													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function M070GrvPen()
Local nI	:= 0

//�����������������������������Ŀ
//� Grava os novos responsaveis �
//�������������������������������

Begin Transaction
For nI := 1 to Len(aCols)
	// Se definiu novo responsavel, grava
	If Empty(aCols[nI,nPosRes])
		// Localiza o Responsavel antigo
		QE5->(dbSetOrder(1))
		If !QE5->(dbSeek(xFilial("QE5")+aCols[nI,6]+aCols[nI,nPosRes])) // Verifico se o usu�rio j� � responsavel e se n�o for transfiro
			If QE5->(dbSeek(xFilial("QE5")+aCols[nI,6]+aCols[nI,3]))  // Equipe+Responsavel
				RecLock("QE5",.F.)                  
				QE5->QE5_FILRES := aCols[nI,nPosFilRes]
				QE5->QE5_RESPON	:= aCols[nI,nPosRes]
				MsUnLock()
			EndIf 
		Else                                                                                 
			If QE5->(dbSeek(xFilial("QE5")+aCols[nI,6]+aCols[nI,3]))  // Equipe+Responsavel
				RecLock("QE5",.F.)                  
				dbDelete()
				MsUnLock()
			EndIf
		EndIf	
	EndIf	
Next nI	

EvalTrigger()
End Transaction

Return(.T.)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M070Status � Autor � Wagner Mobile Costa � Data � 14.02.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza o status indicando a situacao da transferencia    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEM070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function M070Status()

If ! Empty(aCols[n][nPosRes])
	aCols[n][1] := "BR_VERDE"
Else
	aCols[n][1] := "BR_VERMELHO"
Endif

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M070Legend � Autor � Wagner Mobile Costa � Data � 30.01.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao utilizada para criacao de Legenda QIEM070           ���
���          � Retorna a legenda para o Browse/Cria caixa da legenda      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEM070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function M070Legend(cAlias, nReg)

Local aLegenda 	:= {}
Local uRetorno 	:= .T.

If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	Aadd(uRetorno, { 	QA_FilSitF(), "BR_VERMELHO" } ) 
	Aadd(uRetorno, { 	'.T.', "BR_VERDE" } ) 

	Aadd(aRotina, { STR0007 ,"M070Legend", 0 , 0} )  //"Legenda"

Else
	aLegenda := { 	{ "BR_VERDE", STR0010 },; //"Novo responsavel Indicado"
					{ "BR_VERMELHO", STR0011 }} //"Transferencia pendente"
	
	BrwLegenda(cCadastro, "Legenda", aLegenda)
Endif

Return uRetorno

//----------------------------------------------------------------------
/*/{Protheus.doc} Q070GetSX3()
Montagem din�mica do aHeader
@author Luiz Henrique Bourscheid
@since 18/04/2018
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function Q070GetSX3(cCampo, cValid) 

Default cValid := ""

Aadd(aHeader,{ AllTrim(QAGetX3Tit(cCampo)), ;
			   cCampo, ;
			   GetSx3Cache(cCampo, "X3_PICTURE"), ;
			   GetSx3Cache(cCampo, "X3_TAMANHO"), ;
			   GetSx3Cache(cCampo, "X3_DECIMAL"), ;
			   IIf(Empty(cValid), GetSx3Cache(cCampo, "X3_VALID"), cValid), ;
			   GetSx3Cache(cCampo, "X3_USADO"), ;
			   GetSx3Cache(cCampo, "X3_TIPO"), ;
			   GetSx3Cache(cCampo, "X3_F3"), ;
			   GetSx3Cache(cCampo, "X3_CONTEXT")})

Return Nil