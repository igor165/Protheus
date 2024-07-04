#INCLUDE "QDOA121.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QDOA121  � Autor � Newton R. Ghiraldelli � Data � 29/07/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Recuperacao de Documentos Cancelados                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QDOA121()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico ( Windows )                                       ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Eduardo S.  �04/01/02�------� Alterado p/ visualizar docto tambem Html ���
���Eduardo S.  �27/02/02� META � Alterado para gerar Aviso de Referencia  ���
���            �        �      � de Documentos.                           ���
���Eduardo S.  �27/03/02� META � Alterado para utilizar o novo conceito de���
���            �        �      � arquivos de Usuarios do Quality.         ���
���Eduardo S.  �28/06/02� META � Alterado para visualizar Docto externo.  ���
���Eduardo S.  �18/07/02�------� Acerto para passar a especie do texto na ���
���            �        �      � duplicacao dos campos textos.            ���
���Eduardo S.  �13/08/02�016141� Alteracao na interface e inclusao do bo- ���
���            �        �      � tao "pesquisa" documentos cancelados.    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function	QDOA121()

Local aData	   := {}
Local nT       := 0
Local aQPath   := QDOPATH()
Local cQPathTrm:= aQPath[3]

Private oRad01
Private nRad01
Private oRad02
Private nRad02
Private bCampo    := { |nCPO| Field( nCPO ) }
Private cCadastro	:= OemToAnsi( STR0001 ) //"Cancelamento de Documentos"
Private aRotina   := { { "0", "0" ,0, 1 },{ "0", "0" ,0, 2 },{ "0", "0" ,0, 3 },;
{ "0", "0" ,0, 4 },{ "0", "0" ,0, 5 },{ "0", "0" ,0, 6 } }

Private lChCopia	:= .t.
Private cTpCopia  := OemToAnsi( STR0002 ) //"Copia Controlada"
Private cObjetivo := " "
Private cMotRevi  := " "
Private cApElabo	:= " "
Private cApRevis	:= " "
Private cApAprov	:= " "
Private cApHomol	:= " "
Private cElabora	:= " "
Private cRevisor	:= " "
Private cAprovad	:= " "
Private cHomolog	:= " "
Private cSumario  := " "
Private cRodape   := " "
Private cNomRece  := " "
Private cNomFilial:= Space(40)
Private cFilApSol := FWSizeFilial() //Space(2)
Private cCodApSol := Space(6)
Private cFilApDes := FWSizeFilial() //Space(2)
Private cCodApDes := Space(6)
Private cDtEmiss  := CtoD("  /  /  ","DDMMYY")
Private lPendencia:= .f.
Private lCritica 	:= .f.
Private lIncDepois  := .f.
Private lGeraRev	:= .f.
Private lAltDoc	    := .t.
Private lEditor	    := .t.
Private lSolicitacao:= .f.
Private lRefresh    := .t.
Private oWord      

DbSelectArea("QDH")
DbSetorder(1)
Set Filter to
//���������������������������������������Ŀ
//�Chama a Tela de Documentos Cancelados  �
//�����������������������������������������
DlgDocCan()

If Type("oWord") <> "U"
	If !Empty(oWord) .And. oWord <> "-1"
		OLE_CloseFile( oWord )
		OLE_CloseLink( oWord )
	Endif
Endif

aData  := DIRECTORY(cQPathTrm+"*.CEL")
For nT:= 1 to Len(aData)
	If File(cQPathTrm+AllTrim(aData[nT,1]))
		FErase(cQPathTrm+AllTrim(aData[nT,1]))
	Endif
Next
aData  := DIRECTORY(cQPathTrm+"*.HTM")
For nT:= 1 to Len(aData)
	If File(cQPathTrm+AllTrim(aData[nT,1]))
		QDRemDirHtm(AllTrim(aData[nT,1]))
	Endif
Next

Return

/*����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �DlgDocCan � Autor � Newton R. Ghiraldelli � Data � 28/07/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela de Documentos Cancelados                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � DlgDocCan()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDODISTM	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function DlgDocCan()

Local oDlgDoc
Local oQDH
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4
Local oCadDoc
Local aDoc  := {}
Local lFecha:= .F.
Local bQDHLine1

Private cArqDoc  := ""
Private cIndDoc  := ""
Private cDocto	  := Space(016)
Private cRev	  := Space(003)
Private cTitulo  := Space(100)
Private cFil	  := Space(002)
Private cChTxt	  := Space(008)
Private cFilApSol:= FWSizeFilial() //Space(02)
Private cCodApSol:= Space(06)
Private cFilApDes:= FWSizeFilial() //Space(02)
Private cCodApDes:= Space(06)
Private cDtEmiss := dDatabase
Private Inclui   := .F.
Private cTpCopia := OemToansi(STR0002) //"C�pia Controlada"
Private cRodape  :=" "
Private cNomRece :=" "
Private cDepRece :=" "

MsgRun( OemToAnsi( STR0006 ), OemToAnsi( STR0007 ), { || GerDocCan(@aDoc) } ) //"Selecionando Documentos" ### "Aten��o"

If Len(aDoc) == 0
	MsgStop(OemToAnsi(STR0020)) // "N�o existem registros dispon�veis para a opera��o"
	Return
EndIf

DEFINE MSDIALOG oDlgDoc TITLE OemToAnsi(STR0008) FROM 000,000 TO 245,625 OF oMainWnd PIXEL //"Sele��o de Documentos Cancelados"

@ 005,004 TO 120,310 LABEL OemToAnsi(STR0028) OF oDlgDoc PIXEL //"Documentos Cancelados"
@ 015,007 LISTBOX	oQDH ;
FIELDS ;
HEADER OemToAnsi( STR0009 ),; //"Documento"
OemToAnsi( STR0010 ),; // "Revisao"
OemToAnsi( STR0011 );  // "T�tulo"
SIZE	270,100;
ON  DBLCLICK if(!ChkPsw(94).And.!ChkPsw(95),.f.,VisDocCan(aDoc, oQDH:nAt)) OF	oDlgDoc PIXEL;

bQDHLine1	:= {||If(oQDH:nAt > Len(aDoc),;
{ "", "", "" },;
{ aDoc[oQDH:nAt][1], aDoc[oQDH:nAt][2], aDoc[oQDH:nAt][3] }) }
oQDH:SetArray(aDoc)
oQDH:bLine 	:= bQDHLine1
oQDH:cToolTip := OemToAnsi( STR0025 )  //"Duplo click para Visualizar Documento"

DEFINE SBUTTON	oBtn1	FROM 015,279 TYPE 1 ENABLE OF oDlgDoc;
ACTION ( if(!ChkPsw(95),.f.,AtvDlgCan(@aDoc,oQDH:nAt)),;
oQDH:SetArray(aDoc),oQDH:bLine:= bQDHLine1,oQDH:UpStable(), oQDH:Refresh(),;
oDlgDoc:Refresh(), If(Len(aDoc)==0,(lFecha :=.t., oDlgDoc:End() ),) )
oBtn1:cToolTip:=OemToAnsi( STR0013 ) //"Reativa Documento Cancelado"
oBtn1:cCaption:=OemToAnsi(STR0029) //"Reativa"

DEFINE SBUTTON	oBtn2 FROM 028,279 TYPE 2	ENABLE OF oDlgDoc;
ACTION	( lFecha :=.t., oDlgDoc:End())
oBtn2:cToolTip:=OemToansi( STR0014 ) //"Cancelar"
oBtn2:cCaption:=OemToansi( STR0014 ) //"Cancelar"

DEFINE SBUTTON	oBtn3	FROM 041,279 TYPE 6	ENABLE OF oDlgDoc;
ACTION if(!ChkPsw(94),.f.,ImpDocCan(aDoc, oQDH:nAt))
oBtn3:cToolTip:=OemToAnsi( STR0012 ) //"Imprime Documento Cancelado"

@ 054,279 BUTTON oBtn4 PROMPT OemToAnsi(STR0030) ;
	  ACTION If(!ChkPsw(94).And.!ChkPsw(95),.f.,VisDocCan(aDoc, oQDH:nAt)) ;
	  SIZE 026,012 OF oCadDoc PIXEL 
		oBtN4:cToolTip := OemToAnsi(STR0023) 

@ 067,279 BUTTON oBtn4 PROMPT OemToAnsi(STR0027) ;
	  ACTION QD121PesqD(aDoc,@oQDH) ;
	  SIZE 026,012 OF oCadDoc PIXEL 
		oBtN4:cToolTip := OemToAnsi(STR0027) 

ACTIVATE	MSDIALOG	oDlgDoc VALID lFecha CENTERED

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � AtvDlgCan�Autor  �Eduardo de Souza       � Data � 07/06/01 ���
�������������������������������������������������������������������������Ĵ��
���Desc.     � Ativa Documento Cancelado                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � AtvDlgCan(ExpA1,ExpN1)                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 - Array contendo os Documentos Cancelados            ���
���          � ExpN1 - Posicaoo do Array                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QDOA121                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function AtvDlgCan(aDoc, nAt)

Local nCntDoc := Len(aDoc)
Local cChave  := " "
Local nI      := 0

Private lRefresh := .T.

If nCntDoc = 0 .Or. Empty(aDoc[nAt][1])
	MsgAlert( OemToAnsi( STR0015 ), OemToAnsi( STR0007 ) ) //"N�o existem registros dispon�veis para a opera��o" ### "Aten��o"
	return .t.
EndIf

If !MsgYesNo( OemToAnsi( STR0017 ), OemToAnsi( STR0007 ) ) //"Reativa Documento cancelado ?" ### "Aten��o"
	MsgAlert( OemToAnsi( STR0019 ), OemToAnsi( STR0007 ) ) //"Documento permanece cancelado!" ### "Aten��o"
	Return( .f. )
EndIf

DbSelectArea("QDH")
DbSetorder(1)
Set Filter to
If DbSeek( xFilial("QDH") + aDoc[nAt][1] +aDoc[nAt][2] )
	cRev        := QDH->QDH_RV
	nRegQDH     := QDH->(Recno() )
	cChave      := QDH->QDH_CHAVE
	dDataLimite := QDH->QDH_DTLIM
	
	For nI := 1 To FCount()
		M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
	Next nI		
	
	If !QD121kSRv( "QDH", 4, nRegQDH, .T.,"SAD" )  // Acerta proximo numero de revisao( QDOXFUN )
		MsgAlert( OemToAnsi( STR0021 ), OemToAnsi( STR0007 ) ) // "Nao foi poss�vel realizar a opera��o" ### "Aten��o"
		DbSelectArea("QDH")
		DbSetorder(1)
		DbGoto(nRegQDH)
		Return .f.
	Endif
	
	DbSelectArea( "QDH" )
	DbSetOrder( 1 )
	If QD050Telas( "QDH", QDH->(Recno()), 4 ) <> 1
		Begin Transaction
		QD050ApAll()
		//����������������������������������Ŀ
		//�Apaga os Questionario e Respostas �
		//������������������������������������
		QAG->(DbSetOrder(2))
		If QAG->(DbSeek(xFilial("QAG")+M->QDH_DOCTO+M->QDH_RV))
			While QAG->(!Eof()) .And. QAG->QAG_FILIAL+QAG->QAG_DOCTO+QAG->QAG_RVDOC == xFilial("QAG")+M->QDH_DOCTO+M->QDH_RV
				QAH->(DbSetOrder(1))
				If QAH->(DbSeek(xFilial("QAH")+QAG->QAG_QUEST+QAG->QAG_RV))
					While QAH->(!Eof()) .And. QAH->QAH_FILIAL+QAH->QAH_QUEST+QAH->QAH_RV == xFilial("QAH")+QAG->QAG_QUEST+QAG->QAG_RV
						RecLock("QAH",.F.)
						QAH->(DbDelete())
						QAH->(MsUnlock())
						FKCOMMIT()
						QAH->(DbSkip())
					EndDo
				ENDIF
				RecLock("QAG",.F.)
				QAG->(DbDelete())
				QAG->(MsUnlock())
				FKCOMMIT()
				QAG->(DbSkip())
			EndDo
		EndIf
		
		RecLock("QDH",.F.)
		QDH->(DbDelete())
		QDH->(MsUnlock())
		FKCOMMIT()
		End Transaction
		MsgAlert( OemToAnsi( STR0019 ), OemToAnsi( STR0007 ) ) //"Documento permanece cancelado!" ### "Aten��o"
	Else
		Set Filter to
		If DbSeek( xFilial("QDH")+aDoc[nAt][1]+aDoc[nAt][2] )
			RecLock("QDH", .F.)
			QDH->QDH_OBSOL  := "S"
			MsUnlock()
		EndIf
		
		MsgAlert( OemToAnsi( STR0018 ), OemToAnsi( STR0007 ) ) //"Documento foi reativado!" ### "Aten��o"
		//��������������������������������������Ŀ
		//�Remonta vetor de documentos cancelados�
		//����������������������������������������
		GerDocCan(@aDoc)
	EndIf
Endif

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GerDocCan � Autor � Newton R. Ghiraldelli � Data � 28/07/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Preenche vetor(aDoc) com documento Cancelado 		   	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GerDocCan(aDoc)              				                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOA121.PRW                           				           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function GerDocCan(aDoc)

aDoc:={}

DbSelectArea("QDH")
QDH->( DbSetOrder( 3 ) )
QDH->( DbSeek( xFilial( "QDH" ) + "L  " ) )
While !QDH->( Eof() ) .And. QDH->QDH_FILIAL = xFilial( "QDH" )
	If QDH->QDH_OBSOL == "N" .and. QDH->QDH_CANCEL == "S"
		Aadd( aDoc , { QDH->QDH_DOCTO, QDH->QDH_RV, QDH->QDH_TITULO } )
	EndIf
	QDH->(DbSkip())
EndDo

If Len(aDoc) > 0
	aDoc := aSort( aDoc,,,{ |x,y| x[1] + x[2] < y[1] + y[2] } )
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpDocCan �Autor  �Microsiga           � Data �  07/06/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Imprime documento cancelado                                 ���
�������������������������������������������������������������������������͹��
���Uso       �QDOA121.PRW							               				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function ImpDocCan( aDoc, nAt )

Local nC		  := 1
Local nCnt	  := Len(aDoc)
Private Inclui:= .f.

If nCnt == 0
	MsgAlert( OemToAnsi( STR0020 ), OemToAnsi( STR0007 ) ) //"N�o existem registros dispon�veis para a opera��o" ### "Aten��o"
	Return .t.
EndIf

DbSelectArea("QDH")
DbSetorder(1)
Set Filter To
leditor := .t.
If DbSeek( xFilial("QDH") + aDoc[nAt][1] +aDoc[nAt][2] )
	If QDH->QDH_DTOIE <> "E"
		While !Eof() .and. QDH->QDH_FILIAL + QDH->QDH_DOCTO + QDH->QDH_RV == xFilial("QDH") + aDoc[nAt][1] +aDoc[nAt][2]
			If QDH->QDH_OBSOL =="N" .and. QDH->QDH_CANCEL=="S"
				For nC := 1 To QDH->( FCount() )
					cCampo := Upper( AllTrim( QDH->( FieldName( nC ) ) ) )
					M->&cCampo. := QDH->( FieldGet( nC ) )
				Next
				cNomRece := " "
				cDepRece := " "
				ProcessaDoc( { || QdoDocRUsr( lEditor, .f. , cNomRece,,,,,.F. ) } )
				lEditor :=.f.
			Endif
			QDH->(DbSkip())
		Enddo
	Else
		MsgStop(OemToAnsi(STR0026),OemToAnsi(STR0007)) // "Nao imprime Documento do Tipo Externo" ### "Atencao"
	EndIf
EndIf
If !lEditor
	ProcessaDoc( { || QdoDocRUsr( .f., .t.,,,,,,.F. ) } )
EndIf

Return .t.

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    � QD121kSRv  � Autor �  Newton R. Ghiraldelli � Data � 15/07/99 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna o Proximo numero da Revisao e duplica os dados do     ���
���          � Docto para a proxima revisao                                  ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   �QD121kSRv(ExpC1, ExpN1, ExpN2, ExpL1, ExpC2 )                  ���
����������������������������������������������������������������������������Ĵ��
���Parametro �ExpC1: Alias do arquivo QA2                                    ���
���          �ExpN1: Numero da Opcao do Cadastro                             ���
���          �ExpN2: Numero do Registro do Alias()                           ���
���          �ExpL1: Expressao Logica definindo procura de Responsavel       ���
���          �ExpC2: Indica a especie de procura ( Docto ou Solicitacao )    ���
����������������������������������������������������������������������������Ĵ��
���Uso       �SIGAQDO - Generico                                             ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function QD121kSRv( cAlias, nOpc, nReg, lChkResp, cEsp )

Local aQPath := QDOPATH()
Local cCodAut
Local nC
Local lRespRv		:= .f.
Local nRegArq
Local cCampo
Local cAreaG
Local cTexto
Local cArqCpo
Local cQPath	 := aQPath[1] // Diretorio que contem os .CEL
Local aArquivos := {}
Local aUsrMat   := QA_USUARIO()
Local cMatFil   := aUsrMat[2]
Local cMatCod   := aUsrMat[3]
Local cMatDep   := aUsrMat[4]
Local nCpo		:= 1
Local nCont		:= 1
Local nI		:= 0
Local cVelChave := ""
Local aCargTxt  := ""
Local nLoATxt	:= ""
Local cTrCancel := GetNewPar("MV_QTRCANC","1")

Private cRv 		:= M->QDH_RV
Private aDoctos 	:= {}
Private lSAD 		:= If( cEsp == NIL, .F., If( AllTrim( cEsp ) == "SAD", .T., .F. ) )
Private aTxtREsul 	:= {}

lChkResp := If( lChkResp == NIL, .T., lChkResp )

// Verifica a variavel com o codigo do do documento nao esta vazia.
If Empty( M->QDH_DOCTO )
	Return .f.
Endif

// Procura pela existencia do documento especificado
DbSelectArea("QDH")
QDH->( DbSetOrder( 1 ) )
If !QDH->( DbSeek( M->QDH_FILIAL + M->QDH_DOCTO ) )
	M->QDH_RV :="000"
	M->QDH_REVINV:=INVERTE(M->QDH_RV)
	QD050ApAll()
	Return Inclui
Endif

//Cria vetor com todasas ocoorencias ( revisoes ) do documento
While !QDH->( Eof() ) .And. QDH->QDH_FILIAL + QDH->QDH_DOCTO == M->QDH_FILIAL + M->QDH_DOCTO
	Aadd( aDoctos, { QDH->QDH_OBSOL, QDH->QDH_STATUS, QDH->QDH_RV, QDH->QDH_CHAVE, QDH->QDH_FILIAL + QDH->QDH_DOCTO + QDH->QDH_RV, QDH->QDH_CANCEL } )
	QDH->( DbSkip() )
Enddo        

//��������������������������������������������������
//�Ordena o Array por ordem de Revisao             �
//��������������������������������������������������
aDoctos:= aSort(aDoctos,,,{ |x,y| Val(x[3]) < Val(y[3]) } )

// Procura pelas ocorrencias das revisoes obsoletas
For nC := Len( aDoctos ) TO 1 STEP -1 
// Volta a numeracao caso obsoleto e em leitura ou cancelado
	If aDoctos[ nC,1 ] == "S" .And. aDoctos[ nC,2 ] $ "L  "
		nC++
		Exit
	Endif
Next

// Procura pela ultima revisao e se a mesma nao for leitura ou for obsoleta nao permite gerar nova revisao.
QDH->( DbSeek( aDoctos[ Len(aDoctos),5 ] ) )

If nC < 1 .Or. nC > Len( aDoctos )
	nC := Len( aDoctos )
Endif

// Procura pela ultima revisao e se a mesma nao for leitura ou for obsoleta nao permite gerar nova revisao.
QDH->( DbSeek( aDoctos[ nC,5 ] ) )

cOLD_DOCTO := QDH->QDH_DOCTO
cOLD_RV    := QDH->QDH_RV
cOLD_DATA  := QDH->QDH_DTLIM
cCodAut    := " "
lRespRv    := .f.
// Verifica se usuario faz parte dos responsanveis
If lChkResp 	                                                            // Verifica se usuario faz parte dos responsanveis
	DbSelectArea( "QD0" )
	If DbSeek( QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV )
		While !Eof() .And. QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV == QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV
		 If cTrCancel=="1"
			If QD0->QD0_FILMAT+QD0->QD0_MAT == cMatFil+cMatCod
				cCodAut:= QD0->QD0_AUT
				
				// Verifica se Responsavel pode Gerar Revisao
				If QD5->(DbSeek( xFilial("QD5")+QDH->QDH_CODTP+QD0->QD0_AUT ))
					If QD5->QD5_GREV == "S"
						lRespRv := .T.
						Exit
					Endif
				Endif
			EndIf
		 Else
				cCodAut:= "E"			
				// Verifica se Responsavel pode Gerar Revisao
				If QD5->(DbSeek( xFilial("QD5")+QDH->QDH_CODTP+QD0->QD0_AUT ))
					If QD5->QD5_GREV == "S"
						lRespRv := .T.
						Exit
					Endif
				Endif
		 Endif
			DbSkip()
		Enddo
	Endif
	
	// Validacao do usuario
	If Empty( cCodAut ) .Or. !lRespRv                                         // -- Mensagem de Validacao
		MsgAlert( OemToAnsi( STR0022 ),OemToAnsi( STR0007 ) ) // "Usu�rio n�o autorizado a Reativar este Documento"  ### "Aten��o"
		Return( .f. )
	EndIf																							// Confirmacao da Geracao da Revisao
Endif

lGeraRev :=.t. //--FLAG DE GERACAO DE REVISAO

DbSelectArea( "QDH" )

M->QDH_RV     := aDoctos[ Len( aDoctos ), 3 ]
M->QDH_DTIMPL := CTOD( "  /  /  ", "DDMMYY" )
M->QDH_DTVIG  := CTOD( "  /  /  ", "DDMMYY" )
M->QDH_DTLIM  := CTOD( "  /  /  ", "DDMMYY" )
M->QDH_RV     := QDXFNNrRev( M->QDH_RV )
cRV           := M->QDH_RV
M->QDH_REVINV := INVERTE(M->QDH_RV) //Revisao Invertida
M->QDH_FILMAT := cMatFil
M->QDH_MAT    := cMatCod
M->QDH_DEPTOE := cMatDep
M->QDH_DTCAD  := dDataBase
M->QDH_HORCAD := SubStr( TIME(), 1, 5 )
M->QDH_STATUS := "D  "								// Digitacao
M->QDH_OBSOL  := "N"
M->QDH_DTVIG  := CTOD( "  /  /  " , "DDMMYY" )

cVelChave     := M->QDH_CHAVE
cCod      	  := M->QDH_DOCTO + "  RV:" + M->QDH_RV
cChave        := xFilial( "QDH" ) + cCod
cChave        := QA_CvKey( cChave, "QDH", 2 )
M->QDH_CHAVE  := cChave

QD050ApAll("OBJ,TXT,COM,REV,SUM,ITA,RED") 

QD050EdTxt( "REV", 4 ) // inclui Motivo Rev. no Cancelamento

//������������������������������������Ŀ
//�Inclui Motivo Rev. no Cancelamento  �
//��������������������������������������
If Ascan(aTxtREsul,{|x| alltrim(x[1])="REV" }) == 0
	Help(" ",1,"QD050MOTRV") // "O campo motivo da revisao e obrigatorio."
	Return .f.
EndIf

If M->QDH_DTOIE == "I"
	cTexto := STRZERO( VAL( QA_SEQU( "QDH", 6, "N" ) ), 6 )  + SubStr( StrZero( year( dDataBase ), 4 ),3 ,2 ) + ".CEL"
	While File( cQPath + cTexto )
		cTexto := STRZERO( VAL( QA_SEQU( "QDH", 6, "N" ) ), 6 )  + SubStr( StrZero( year( dDataBase ), 4 ),3 ,2 ) + ".CEL"
	Enddo
	If ExistBlock("QDOAP16")
		ExecBlock("QDOAP16",.F.,.F.,{cTexto, cQPath})
	Else
		_CopyFile( cQPath + AllTrim( M->QDH_NOMDOC ), cQPath + cTexto )
	EndIf
	M->QDH_NOMDOC := Alltrim( cTexto )
Endif


Begin Transaction
RecLock("QDH", .T.)
For nI := 1 TO FCount()
	FieldPut(nI,M->&(Eval(bCampo,nI)))
Next nI
QDH->QDH_DTFIM  := CTOD("  /  /  ","DDMMYY")
QDH->QDH_CANCEL := "N"
MsUnLock()
FKCOMMIT()

lRefresh := .t.

aArquivos := { "QD6", "QDB", "QD0", "QDG", "QDJ","QDZ" }
For nCont := 1 to Len( aArquivos )
	cAreaG    := aArquivos[ nCont ]
	DbSelectArea( cAreaG )
	If (cAreaG)->(DbSeek( QDH->QDH_FILIAL + cOLD_DOCTO + cOLD_RV ))
		cChave:= cAreaG + "->" + cAreaG + "_FILIAL+" +	cAreaG + "->" + cAreaG + "_DOCTO+" + cAreaG + "->" + cAreaG + "_RV"
		While !Eof() .And. QDH->QDH_FILIAL + cOLD_DOCTO + cOLD_RV == &cChave.
			If ( cAreaG == "QD0" .And. QD0->QD0_FLAG == "I" ).Or. ;
				( cAreaG == "QDG" .And. QDG->QDG_SIT == "I" )
				dbSkip()
				Loop
			Endif
			
			//���������������������������������������������������������������������������������Ŀ
			//� Verifica se existe Destinatarios nos Deptos                                     �
			//�����������������������������������������������������������������������������������
			If cAreaG == "QDJ"
				If !QDG->(dbSeek(M->QDH_FILIAL + cOLD_DOCTO + cOLD_RV + QDJ->QDJ_TIPO + QDJ->QDJ_FILMAT + QDJ->QDJ_DEPTO ))
					dbSkip()
					Loop
				Endif
			Endif
			
			nRegArq := Recno()
			For nCpo := 1 to FCount()
				cCampo       := Upper( Alltrim( FieldName( nCpo ) ) )
				M->&cCampo. := FieldGet( nCpo )
			Next
			If cAreaG == "QD0" .And. M->QD0_FLAG == "T"
				M->QD0_FLAG := " "
			Endif
			If cAreaG == "QD1" .And. M->QD1_SIT == "T"
				M->QD1_SIT := "A"
			Endif
			If RecLock( cAreaG, .t. )
				For nCpo := 1 to FCount()
					cCampo       := Upper( Alltrim( FieldName( nCpo ) ) )
					cArqCpo      := cAreaG+"->"+cCampo
					&( cArqCpo ) := M->&cCampo.
				Next
				&( cAreaG + "->" + cAreaG+ "_RV" ) := cRV
				MsUnlock()
				FKCOMMIT()
			Endif
			DbGoTo( nRegArq )
			DbSkip()
		Enddo
	Endif
Next

QDG->(dbSetOrder(1))

cEspecie := "OBJ     "																	// - Objetivo
F050COPTXT(cVelChave,M->QDH_CHAVE,cEspecie)
cEspecie := "SUM     "																	// - Sumario
F050COPTXT(cVelChave,M->QDH_CHAVE,cEspecie)
cEspecie := "REV     "																	// - Motivo da Revisao
nLoATxt  := ASCAN(aTxtREsul,{|X| x[1]==cEspecie .AND. X[2]==M->QDH_CHAVE})
If GetMv("MV_QDLHREV") == "N"
	aCargTxt := QA_RecTxt(cVelChave,cEspecie)
	aTxtREsul[nLoATxt,3,1,2]:=aCargTxt+" "+chr(13)+" "+aTxtREsul[nLoATxt,3,1,2]
Endif

//��������������������������������Ŀ
//�GRAVA NO QA2 os texto da(s) REV �
//����������������������������������
QA_GrvTxt( aTxtResul[nLoATxt,2], aTxtResul[nLoATxt,1], 1,aTxtResul[nLoATxt,3] )
FKCOMMIT()

DbSelectArea( "QD1" )
DbSetOrder( 1 )
RecLock( "QD1", .t., .t. )
QD1->QD1_FILIAL := M->QDH_FILIAL
QD1->QD1_DOCTO  := M->QDH_DOCTO
QD1->QD1_RV     := M->QDH_RV
QD1->QD1_TPPEND := "D  "
QD1->QD1_FILMAT := cMatFil
QD1->QD1_MAT    := cMatCod
QD1->QD1_DEPTO  := cMatDep
QD1->QD1_FMATBX := cMatFil
QD1->QD1_MATBX  := cMatCod
QD1->QD1_DEPBX  := cMatDep
QD1->QD1_DISTNE := "N"
QD1->QD1_PENDEN := "P"
QD1->QD1_DTGERA := dDataBase
QD1->QD1_HRGERA := SubStr( Time(), 1, 5 )
QD1->QD1_DTBAIX := CtoD("  /  /  ","DDMMYY")
QD1->QD1_LEUDOC := "N"
QD1->QD1_CHAVE  := M->QDH_CHAVE
DbSelectArea( "QAA" )
nOrdQAA := IndexOrd()
nRegQAA := Recno()
DbSetOrder(1)
If DbSeek( cMatFil + cMatCod )
	QD1->QD1_CARGO  := QAA->QAA_CODFUN
	QD1->QD1_TPDIST := QAA->QAA_TPRCBT
EndIf

DbSelectArea( "QAA" )
DbSetOrder( nOrdQAA )
DbGoTo( nRegQAA )
DbSelectArea( "QD1" )
DbSetOrder( 1 )
MsUnlock()

End Transaction

lRevisao := .T.

Return .t.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VisDocCan �Autor  �Eduardo de Souza    � Data �  10/12/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Visualiza Documentos Cancelados                             ���
�������������������������������������������������������������������������͹��
���Sintaxe   �VisDocCan(ExpA1,ExpN1)                                      ���
�������������������������������������������������������������������������͹��
���Parametros�ExpA1 - Array contendo Documentos Cancelados                ���
���          �ExpN1 - Posicao do Array                                    ���
�������������������������������������������������������������������������͹��
���Uso       �QDOA121.PRW							               				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function VisDocCan(aDoc, nAt)

Local oDlgVis
Local oVisDoc
Local oBtn1
Local oBtn2
Local nVisDoc:= 1

Private bCampo:= { |nCPO| Field( nCPO ) }

DbSelectArea("QDH")
DbSetorder(1)
Set Filter to

If QDH->(DbSeek(xFilial("QDH")+aDoc[nAt,1]+aDoc[nAt,2]))
	DEFINE MSDIALOG oDlgVis TITLE OemToAnsi(STR0023)+" ?" FROM 000, 000 TO 085, 342 PIXEL
	
	@ 010,010 RADIO oVisDoc VAR nVisDoc ITEMS OemToAnsi( STR0009 ), OemToAnsi( STR0024 );  //"Documento" ### "Cadastro de Documentos"
	3D SIZE 070,010 OF oDlgVis PIXEL
	
	DEFINE SBUTTON oBtn1 FROM 025, 105 TYPE 1 ENABLE OF oDlgVis;
	ACTION (QD121VisDoc(nVisDoc),oDlgVis:End())
	
	DEFINE SBUTTON oBtn2 FROM 025, 137 TYPE 2 ENABLE OF oDlgVis;
	ACTION  oDlgVis:End()
	
	ACTIVATE MSDIALOG oDlgVis CENTERED
EndIf

Return

/*�������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Fun�ao    � QD121VisDoc� Autor � Eduardo de Souza   � Data � 10/12/01 ���
������������������������������������������������������������������������Ĵ��
���Descri�ao � Visualizacao de Docto e Cadastro                          ���
������������������������������������������������������������������������Ĵ��
���Sintaxe   � QD121VisDoc(ExpN1)          				                   ���
������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Escolha da Visualizacao (1-Docto/2-Cadastro)      ���
������������������������������������������������������������������������Ĵ��
��� Uso      � QDOA121                                                   ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QD121VisDoc(nVisDoc)

If nVisDoc == 1
	QdoDocCon()
Else
	QD050Telas("QDH",QDH->(Recno()),8)
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � QD121PesqD� Autor � Eduardo de Souza     � Data � 13/08/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Pesquisa Documentos                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QD121PesqD()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOA121                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function QD121PesqD(aDoc,oQDH)

Local oDlgPesq
Local oCodDoc
Local cCodDoc:= Space(TamSx3("QDH_DOCTO" )[1])
Local nOpcao1:= 0
Local nPos   := 0

DEFINE MSDIALOG oDlgPesq TITLE OemToAnsi(STR0027) FROM 000,000 TO 090,300 OF oMainWnd PIXEL //"Pesquisa"

@ 003,003 TO 030,143 LABEL OemToAnsi(STR0009) OF oDlgPesq PIXEL //"Documento"

@ 011,006 MSGET oCodDoc VAR cCodDoc F3 "QDH" SIZE 080,010 OF oDlgPesq PIXEL

DEFINE SBUTTON FROM 031,085 TYPE 1 ENABLE OF oDlgPesq;
ACTION (nOpcao1:= 1,oDlgPesq:End())

DEFINE SBUTTON FROM 031,115 TYPE 2 ENABLE OF oDlgPesq;
ACTION oDlgPesq:End()

ACTIVATE MSDIALOG oDlgPesq CENTERED

If nOpcao1 == 1
	If (nPos:= aScan(aDoc,{|x| x[1] == cCodDoc} )) > 0
		oQDH:nAt:= nPos
		oQDH:Refresh()
	EndIf
	If nPos == 0
		Help(" ",1,"QD120DNE") // "Documento nao encontrado."
	EndIf
EndIf

Return
