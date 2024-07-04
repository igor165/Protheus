#INCLUDE "ATFA290.CH"
#INCLUDE "PROTHEUS.CH"

//********************************
// Controle de multiplas moedas  *
//********************************
Static lMultMoed := .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �ATFA290   � Autor � Marcelo Akama         � Data � 21.07.09 ��� 
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao do Cadastro de Taxas Regulamentadas             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ATFA290()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function ATFA290()

Private aRotina := MenuDef()
PRIVATE cCadastro := STR0001

// Ajusta gatinhos
a290AtuSX7()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"SNH")	

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ATF290Alt � Autor � Marcelo Akama         � Data � 21.07.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Alteracao de cadastro de taxas regulamentadas              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �ATF290Alt()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function ATF290Alt(cAlias,nReg,nOpc)
Local	nOpcA
Local	aCampoSNH := {}

//��������������������������������������������������������������Ŀ
//� Carrega matriz com campos que serao alterados neste cadastro �
//����������������������������������������������������������������
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SNH")

While !Eof() .And. (X3_ARQUIVO == cAlias)
	IF X3USO(X3_USADO).and. cNivel >= X3_NIVEL   
		AADD(aCampoSNH,X3_CAMPO)                   //Campos a serem alterados, exceto os campos chave.
	EndIF
	dbSkip()
EndDO

dbSelectArea(cAlias)

Private aTELA[0][0],aGETS[0]

nOpcA:=0
dbSelectArea(cAlias)
dbSetOrder(1)
nOpca := AxAltera(cAlias,nReg,nOpc,aCampoSNH,,,,"A290VldAlt()" )

dbGoTo( nReg )
dbSelectArea(cAlias)
Return .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ATF290Del � Autor � Marcelo Akama         � Data � 21.07.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exclusao de cadastro de taxas regulamentadas               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �ATF290Del()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function ATF290Del(cAlias,nReg,nOpc)
Local nOpcA
Local aCampoSNH := {}
Local aArea		:= GetArea()
Local aAreaSN1	:= SN1->(GetArea())
Local lExcluir	:= .F.

//��������������������������������������������������������������Ŀ
//� Carrega matriz com campos que serao alterados neste cadastro �
//����������������������������������������������������������������
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SNH")

While !Eof() .And. (X3_ARQUIVO == cAlias)
	IF X3USO(X3_USADO).and. cNivel >= X3_NIVEL   
		AADD(aCampoSNH,X3_CAMPO)                   //Campos a serem alterados, exceto os campos chave.
	EndIF
	dbSkip()
EndDO

dbSelectArea(cAlias)

Private aTELA[0][0],aGETS[0]

nOpcA:=0
dbSelectArea(cAlias)
dbSetOrder(1)
dbGoTo( nReg )
If !Empty(SNH->NH_CODIGO)
	dbSelectArea("SN1")
	SN1->(dbSetOrder(7))
	If !SN1->(dbSeek(xFilial("SN1")+SNH->NH_CODIGO))
		lExcluir := .T.
	EndIf

	// Verifica se a taxa regulamentada esta sendo usada em algum grupo de bens.
	If  lExcluir
		lExcluir:= a290VLDSNG(SNH->NH_CODIGO)
	EndIf
	

	If lExcluir
		nOpca := AxDeleta(cAlias,nReg,nOpc)
	EndIf
EndIf

RestArea(aAreaSN1)
RestArea(aArea)

dbGoTo( nReg )
dbSelectArea(cAlias)

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATF290ErrM�Autor  �Marcelo Akama       � Data �  24/07/2009 ���
�������������������������������������������������������������������������͹��
���Desc.     �Caixa de dialogo para exibir os erros encontrados durante o ���
���          �processo                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ATF290ErrM(cErros)
Local oDlg, oMemo, oBtn, oGrp

DEFINE MSDIALOG oDlg FROM 0,0 TO 400,400 PIXEL TITLE STR0002

oGrp := tGroup():New(3, 3, 201, 197, "", oDlg, , , .T.)
oMemo:= tMultiget():New(5,5,{|u|if(Pcount()>0,cErros:=u,cErros)},oDlg,190,175,,.T.,,,,.T.)
@ 185, 145 BUTTON oBtn PROMPT STR0003 OF oDlg PIXEL ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

conout(cErros)

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATF290Vlr �Autor  �Marcelo Akama       � Data �  21/07/2009 ���
�������������������������������������������������������������������������͹��
���Desc.     �Converte texto para string verificando separador de decimais���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ATF290Vlr(cTxt)
Local nPosDF :=  AT('.',cTxt)
Local nPosDL := RAT('.',cTxt)
Local nPosCF :=  AT(',',cTxt)
Local nPosCL := RAT(',',cTxt)
Local nRet  := nil

If nPosDF==0
	If nPosCF>0
		If nPosCF==nPosCL
			cTxt := StrTran(cTxt, ',', '.')		// 123,45 -> 123.45
		Else
			cTxt := StrTran(cTxt, ',', '')		// 123,456,789 -> 123456789
		EndIf
	EndIf
Else
	If nPosCF==0
		If nPosDF<>nPosDL
			cTxt := StrTran(cTxt, '.', '')		// 123.456.789 -> 123456789
		EndIf
	Else
		If nPosDF<>nPosDL .And. nPosCF<>nPosCL
			cTxt := StrTran(cTxt, '.', '')		// 1.234.567,890,123 -> 1234567890123
			cTxt := StrTran(cTxt, ',', '')
		ElseIf nPosDL<nPosCL
			cTxt := StrTran(cTxt, '.', '')		// 1.234,56 -> 1234.56
			cTxt := StrTran(cTxt, ',', '.')		// 1.234.567,89 -> 1234567.89
		Else
			cTxt := StrTran(cTxt, ',', '')		// 1,234.56 -> 1234.56  // 1,234,567.89 -> 1234567.89
		EndIf
	EndIf
EndIf

nRet := val(cTxt)

Return nRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetLine  �Autor  �Marcelo Akama       � Data �   22/07/2009 ���
�������������������������������������������������������������������������͹��
���Desc.     �Extrai a primeira linha da string e le informacoes do       ���
���          �arquivo quando necessario                                   ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GetLine(cTxt, cLine, cErros, nHandle, nError)
Local nPos
Local nLen
Local lRet := .F.
Local cBuf := ""
Local nLidos

DEFAULT cErros := ""

nLen:=2
nPos:=AT(chr(13)+chr(10), cTxt) // Procura CRLF
If nPos == 0 // Se nao encontrou, tenta
	nPos:=AT(chr(13), cTxt) // Procura CR
	nLen:=1
EndIf
If nPos == 0
	nPos:=AT(chr(10), cTxt) // Procura LF
	nLen:=1
EndIf

If nPos == 0 .And. nHandle <> nil // Se nao encontrar, le mais um bloco do arquivo
	nLidos:=FREAD( nHandle, @cBuf, nBufSize )
	nError:=FERROR()
	If nError==0
		If nLidos == 0
			nPos := len(cTxt)
		Else
			cTxt := cTxt + cBuf
			nLen:=2
			nPos:=AT(chr(13)+chr(10), cTxt) // Procura CRLF
			If nPos == 0 // Se nao encontrou, tenta
				nPos:=AT(chr(13), cTxt) // Procura CR
				nLen:=1
			EndIf
			If nPos == 0
				nPos:=AT(chr(10), cTxt) // Procura LF
				nLen:=1
			EndIf
		EndIf
	EndIf
EndIf

If nPos == 0
	If Len(cTxt)>0
		cErros += STR0004 + " - " + "CRLF" + " " + STR0005 + Chr(13) + Chr(10)
	EndIf
Else
	cLine := Left(cTxt, nPos-1)
	cTxt := Stuff(cTxt,1,nPos+nLen-1,'')
	lRet := .T.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetToken  �Autor  �Marcelo Akama       � Data �  22/07/2009 ���
�������������������������������������������������������������������������͹��
���Desc.     �Extrai o primeiro token da string                           ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GetToken(cTxt, cToken, cErros)
Local nPos
Local lRet := .F.
Local cBuf := ""

DEFAULT cErros := ""

nPos:=AT(';', cTxt) // Procura o separador

If nPos == 0
	If Len(cTxt)>0
		cToken := cTxt
		cTxt   := ""
		lRet   := .T.
	Else
		cErros += STR0004 + " - " + STR0006 + Chr(13) + Chr(10)
	EndIf
Else
	cToken := Left(cTxt, nPos-1)
	cTxt   := Stuff(cTxt,1,nPos,'')
	lRet   := .T.
EndIf

If lRet
	cToken := Alltrim(cToken)
	If left(cToken,1) == '"'
		If Type(cToken)="C"
			cToken:=&(cToken)
		EndIf
	EndIf
EndIf

Return lRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ATF290CSV � Autor � Marcelo Akama         � Data � 23.07.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Importacao/Exportacao de cadastro de taxas regulamentadas  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �ATF290CSV()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1 : Tipo da operacao ( 1=Exportacao / 2=Importacao )    ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function ATF290CSV(nOpc)
Local aRet  := {}
Local aArea := GetArea()

Private nBufSize := 4096

If ParamBox( {	{ 6, STR0007, SPACE(50), "", IIf(nOpc==1,"","IIf( Empty(mv_par01) .or. (FILE(mv_par01) .and. right(upper(rtrim(mv_par01)),4)=='.CSV'),.T., Aviso('"+STR0008+"','"+STR0009+"',{'"+STR0003+"'},2)==9 )"), "", 55, .T., STR0010 } }, IIf( nOpc==1, STR0011, STR0012 ), @aRet )

	If Empty(mv_par01)
		MsgStop(STR0013, STR0014)
	Else	
		If nOpc == 1
			Processa({|lEnd| ATF290Exp(aRet[1], @lEnd)}, STR0015) //"Exportando CSV. Aguarde..."
		Else
			Processa({|lEnd| ATF290Imp(aRet[1], @lEnd)}, STR0016) //"Importando CSV. Aguarde..."
		EndIf
	EndIf
		
EndIf

RestArea(aArea)

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ATF290Exp � Autor � Marcelo Akama         � Data � 21.07.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exportacao de cadastro de taxas regulamentadas             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �ATF290Exp()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function ATF290Exp(cFile, lEnd)
Local aArea		:= GetArea()
Local aAreaSNH	:= SNH->(GetArea())
Local nHandle
Local nLen1		:= TamSX3("NH_TAXA")[1]
Local nDec1		:= TamSX3("NH_TAXA")[2]
Local nLen2		:= TamSX3("NH_VIDA")[1]
Local nDec2		:= TamSX3("NH_VIDA")[2]

If File(cFile)
	If Aviso(STR0008, STR0017, {STR0018, STR0019},2) == 2 //"Aviso" // "Arquivo ja existe. Sobrescreve?" // "Sim", "Nao"
		Return
	EndIf
EndIf

If (nHandle := FCreate(cFile))== -1
	MsgStop(STR0020, STR0021 + " " + strzero(ferror(),4))
	Return
EndIf

dbSelectArea("SNH")
dbSetOrder(1)
dbGoTop()

ProcRegua(SNH->(RecCount()))

Do While !SNH->(Eof())
	IncProc(STR0022)
	FWrite(nHandle,'"'+SNH->NH_CODIGO+'";"'+SNH->NH_DESCRI+'";'+StrZero(SNH->NH_TAXA,nLen1,nDec1)+';'+StrZero(SNH->NH_VIDA,nLen2,nDec2)+CRLF)
	
	If lEnd
		Exit
	EndIf

	SNH->(dbSkip())
EndDo

FClose(nHandle)
RestArea(aAreaSNH)
RestArea(aArea)

Aviso(STR0008, STR0023, {STR0003}, 2) //"Aviso" // "Arquivo exportado com sucesso" // "Fechar"

Return



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ATF290Imp � Autor � Marcelo Akama         � Data � 21.07.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Importacao de cadastro de taxas regulamentadas             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �ATF290Imp()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function ATF290Imp(cFile, lEnd)
Local aArea		:= GetArea()
Local aAreaSNH	:= SNH->(GetArea())
Local nHandle
Local nTotal
Local cBuf		:= ''
Local cLin
Local nError
Local lOk		:= .T.
Local cCod, cDesc, cTaxa, nTaxa, cVida, nVida
Local nCount	:= 0
Local cErros	:= ''

If (nHandle := FOpen(cFile))== -1
	cErros += STR0024 + " - " + STR0021 + " "+strzero(ferror(),4) + Chr(13) + Chr(10)
	Return .F.
EndIf

dbSelectArea("SNH")
dbSetOrder(1)

// Determina o tamanho do arquivo
nTotal := FSeek(nHandle,0,2)

// Move o ponteiro do arquivo para o inicio
FSeek(nHandle,0)

ProcRegua(Round((nTotal/nBufSize)+.5,0))

Do While lOk .and. GetLine(@cBuf, @cLin, cErros, nHandle, @nError)
	IncProc(STR0025)
	
	lOk := GetToken(@cLin, @cCod, cErros)
	If lOk
		lOk := GetToken(@cLin, @cDesc, cErros)
	EndIf
	If lOk
		lOk := GetToken(@cLin, @cTaxa, cErros)
	EndIf
	If lOk
		nTaxa:=ATF290Vlr(cTaxa)
		lOk := GetToken(@cLin, @cVida, cErros)
	EndIf
	If lOk
		nVida:=ATF290Vlr(cVida)
		If !SNH->(dbSeek( xFilial("SNH")+cCod ))
			Reclock("SNH", .T.)
			SNH->NH_FILIAL	:= xFilial("SNH")
			SNH->NH_CODIGO	:= cCod
			SNH->NH_DESCRI	:= cDesc
			SNH->NH_TAXA	:= nTaxa
			SNH->NH_VIDA	:= nVida
			SNH->(MsUnlock())
			nCount++
		EndIf
	EndIf
	
	If lEnd
		Exit
	EndIf

EndDo

FClose(nHandle)
RestArea(aAreaSNH)
RestArea(aArea)

If cErros<>""
	ATF290ErrM(cErros)
Else
	Aviso(STR0008, Alltrim(str(nCount))+' '+STR0026, {STR0003}, 2) //"Aviso" // ##"registros importados" // "Fechar"
EndIf

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A290CanAlt�Autor  � Marcelo Akama      � Data �  21/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se pode alterar a taxa regulamentada              ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
���Parametros�ExpC1 : Codigo do taxa regulamentada                        ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function A290CanAlt(cTaxa)

Local aArea		:= GetArea()
Local aAreaSN1	:= SN1->(GetArea())
Local aAreaSN3	:= SN3->(GetArea())
Local lRet		:= .T.
//********************************
// Controle de multiplas moedas  *
//********************************
Local nSomaDACM	:= 0

If ALTERA .and. !empty(cTaxa)
	dbSelectArea("SN3")
	SN3->(dbSetOrder(1))
	dbSelectArea("SN1")
	SN1->(dbSetOrder(7))
	SN1->(dbSeek(xFilial("SN1")+cTaxa))
	Do While lRet .and. !SN1->(Eof()) .and. SN1->N1_FILIAL+SN1->N1_TAXAPAD==xFilial("SN1")+cTaxa
		SN3->(dbSeek(xFilial("SN3")+SN1->N1_CBASE+SN1->N1_ITEM))
		Do While lRet .and. !SN3->(Eof()) .and. SN3->N3_FILIAL+SN3->N3_CBASE+SN3->N3_ITEM==xFilial("SN3")+SN1->N1_CBASE+SN1->N1_ITEM
			//********************************
			// Controle de multiplas moedas  *
			//********************************
			nSomaDACM	:= 0
			If lMultMoed
				AtfMultMoe(,,{|x| nSomaDACM	+= SN3->&(If(x>9,"N3_VRDAC","N3_VRDACM")+Alltrim(Str(x)))})
			Else
				nSomaDACM	+= SN3->N3_VRDACM1
				nSomaDACM	+= SN3->N3_VRDACM2
				nSomaDACM	+= SN3->N3_VRDACM3
				nSomaDACM	+= SN3->N3_VRDACM4
				nSomaDACM	+= SN3->N3_VRDACM5
			EndIf
			If nSomaDACM>0
				lRet := .F.
			EndIf
			SN3->(dbSkip())
		EndDo
		SN1->(dbSkip())
	EndDo
EndIf

RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A290VldAlt�Autor  � Marcelo Akama      � Data �  23/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida alteracao da taxa regulamentada                     ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
���Parametros�ExpC1 : Codigo do taxa regulamentada                        ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function A290VldAlt()

Local aArea		:= GetArea()
Local aAreaSN1	:= SN1->(GetArea())
Local aAreaSN3	:= SN3->(GetArea())
Local lRet		:= A290CanAlt(M->NH_CODIGO)

If lRet
	dbSelectArea("SN3")
	SN3->(dbSetOrder(1))
	dbSelectArea("SN1")
	SN1->(dbSetOrder(7))
	SN1->(dbSeek(xFilial("SN1")+M->NH_CODIGO))
	Do While lRet .and. !SN1->(Eof()) .and. SN1->N1_FILIAL+SN1->N1_TAXAPAD==xFilial("SN1")+M->NH_CODIGO
		SN3->(dbSeek(xFilial("SN3")+SN1->N1_CBASE+SN1->N1_ITEM))
		Do While lRet .and. !SN3->(Eof()) .and. SN3->N3_FILIAL+SN3->N3_CBASE+SN3->N3_ITEM==xFilial("SN3")+SN1->N1_CBASE+SN1->N1_ITEM
			Reclock("SN3", .F.)

			//********************************
			// Controle de multiplas moedas  *
			//********************************
			If lMultMoed
				AtfMultMoe("SN3","N3_TXDEPR",{|x| M->NH_TAXA })
			Else
				SN3->N3_TXDEPR1 := M->NH_TAXA
				SN3->N3_TXDEPR2 := M->NH_TAXA
				SN3->N3_TXDEPR3 := M->NH_TAXA
				SN3->N3_TXDEPR4 := M->NH_TAXA
				SN3->N3_TXDEPR5 := M->NH_TAXA
			EndIf
			SN3->(MsUnlock())
			SN3->(dbSkip())
		EndDo
		SN1->(dbSkip())
	EndDo
EndIf

RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)

Return lRet


/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marcelo Akama         � Data � 21.07.09 ���
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
���          �    1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
Local aRotina := {		{ STR0027	,"AxPesqui"		, 0 , 1,,.F.},;	//"Pesquisar"
	   					{ STR0028	,"AxVisual"		, 0 , 2},;		//"Visualizar"
						{ STR0029	,"AxInclui"		, 0 , 3},;		//"Incluir"
						{ STR0030	,"ATF290Alt"	, 0 , 4},;		//"Alterar"
						{ STR0031	,"ATF290Del"	, 0 , 5},;		//"Excluir"
						{ STR0032	,"ATF290CSV(2)"	, 0 , 3},;		//"Importar"
						{ STR0033	,"ATF290CSV(1)"	, 0 , 6} }		//"Exportar"
						
Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �a290AtuSX7� Autor � Totvs                 � Data � 24/09/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de processamento da gravacao do SX7                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function a290AtuSX7()
//  X7_CAMPO X7_SEQUENC X7_REGRA X7_CDOMIN X7_TIPO X7_SEEK X7_ALIAS X7_ORDEM X7_CHAVE X7_PROPRI X7_CONDIC

Local aSX7   := {}
Local aEstrut:= {}
Local i      := 0
Local j      := 0

If (cPaisLoc == "BRA")
	aEstrut:= {"X7_CAMPO","X7_SEQUENC","X7_REGRA","X7_CDOMIN","X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE","X7_PROPRI","X7_CONDIC"}
Else
	aEstrut:= {"X7_CAMPO","X7_SEQUENC","X7_REGRA","X7_CDOMIN","X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE","X7_PROPRI","X7_CONDIC"}
EndIf

Aadd(aSX7,{ PadR( "NH_VIDA", 10 ), "001","100/M->NH_VIDA","NH_TAXA","P","N","",0,"","S",""})
Aadd(aSX7,{ PadR( "NH_TAXA", 10 ), "001","100/M->NH_TAXA","NH_VIDA","P","N","",0,"","S",""})

ProcRegua( Len( aSX7 ) )

dbSelectArea("SX7")
dbSetOrder(1)
For i:= 1 To Len(aSX7)
	If MsSeek( aSX7[i][1] + aSX7[i][2] )
		RecLock( "SX7" )
		
		For j:=1 To Len( aSX7[i] )
			If !Empty( FieldName( FieldPos( aEstrut[j] ) ) )
				FieldPut( FieldPos( aEstrut[j] ), aSX7[i][j] )
			EndIf
		Next
		
		dbCommit()
		MsUnLock()
	EndIf
Next

Return




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �a290VLDSNG� Autor � Totvs                 � Data � 07/07/15 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � valida se ha grupo usando taxa cadastrada                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function a290VLDSNG(cCod)
Local cQryNg := ""
Local tRet :=.t.
		cAliasNg	:=	GetNextAlias()
		cQryNg := "SELECT *"          
		cQryNg += "FROM "+RetSqlName("SNG")+" WHERE "
		cQryNg += "NG_TAXAPAD='"+cCod+"' AND             
		cQryNg += "D_E_L_E_T_=' ' "
		cQryNg := ChangeQuery(cQryNg) 

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryNg),cAliasNg,.F.,.T.)
		If (cAliasNg)->(!Eof())
			Help(" ",1,"AF290DEL")
			tRet:= .F.
		ENDIF
		(cAliasNg)->(dbCloseArea())
Return tRet