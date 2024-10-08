#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "FRTA271B.CH"
Static __lFirst := .T. 
 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FR271BGeraSL� Autor� Cesar Eduardo Valadao� Data �07/08/2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a gravacao dos campos dos arquivos.                ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FR271BGeraSL(cAlias, aArray, lAppend, lUnLock)
Local cOldAlias:=Alias(), lRet:=.T.
Default lAppend := .F.
Default lUnLock := .T.
dbSelectArea(cAlias)
If !lAppend .And. !lUnLock
	lRet := MsRLock()
Else
	lRet := RecLock(cAlias, lAppend)
EndIf
If lRet
	AEval(aArray, {|x| FieldPut(FieldPos(x[1]), x[2])})
Else
	ConOut("Impossible lock on file "+cAlias+" Record:"+AllTrim(Str(Recno()))+".")
EndIf
If lRet .And. lUnLock
	dbCommit()
	MsUnLock()
EndIf
If !Empty(cOldAlias)
	dbSelectArea(cOldAlias)
EndIf
Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FR271BGerSLI� Autor� Cesar Eduardo Valadao � Data�07/08/2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a gravacao dos campos do SLI.                      ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT                                                    ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data   � Bops �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Erik W.B. �19/04/07�124560�Alterada a utiliza��o da chamada            ���
���          �        �      �SubStr(cUsuario,7,15) por cUserName         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FR271BGerSLI(cEstacao, cTipo, cMsg, cDecisao, lUnLock, _cUsuario, _dData, _cHora)
Local aSLI, lRet
Default cDecisao := "ABANDONA"
Default lUnLock  := .T.
Default _cUsuario:= cUserName
Default _dData   := dDataBase
Default _cHora   := Time()
lAppend := !SLI->(dbSeek(xFilial("SLI")+PadR(cEstacao,4)+cTipo))
If !lAppend
	If Empty(SLI->LI_MSG)
		lAppend := .F.
	Else
		If cDecisao == "ABANDONA"
			Return(NIL)
		ElseIf cDecisao == "SOBREPOE"
			lAppend := .F.
		ElseIf cDecisao == "NOVO"
			lAppend := .T.
		EndIf
	EndIf
EndIf	
aSLI := {{"LI_FILIAL",	xFilial("SLI")},;
		 {"LI_ESTACAO",	cEstacao},;
		 {"LI_TIPO",	cTipo},;
		 {"LI_USUARIO",	_cUsuario},;
		 {"LI_DATA",	_dData},;
		 {"LI_HORA",	_cHora},;
		 {"LI_MSG",		cMsg}}
lRet := FR271BGeraSL("SLI", aSLI, lAppend, lUnLock)
Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FR271BGSLH� Autor � Cesar Eduardo Valadao � Data �15/05/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a gravacao dos campos do SLH.                      ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT                                                    ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data   � Bops �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Erik W.B. �19/04/07�124560�Alterada a utiliza��o da chamada            ���
���          �        �      �SubStr(cUsuario,7,15) por cUserName         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FR271BGSLH(cAlias, cSituacao)
Static lFirst:=.T., lUsaSLH, lGravaFi, aFiliais:={}
Local i, aSLH, cChave, cOldAlias:=Alias()
Local nRecnoSM0
Local lOk:=.F.
Local cAux

If ValType(lGravaFi) == "U"						// Controla se deve replicar o SLH para todas as filiais
	nRecnoSM0 := SM0->(Recno())
	cAux := FWModeAccess("SBI",3)
	lGravaFi := cAux != FWModeAccess("SB0",3)
	SM0->(DBEval({|| AAdd(aFiliais,FWGETCODFILIAL)}, {|| SM0->M0_CODIGO==cEmpAnt}))
	SM0->(dbGoTo(nRecnoSM0))
EndIf

lUsaSLH := FR271BUsaSLH()

If lUsaSLH
	dbSelectArea(cAlias)
	cChave := &(IndexKey(1))
	If cAlias $ "SB1/SB0"
		cAlias := "SB1"										// O alias de todos os registros serah SB1.
		cChave := xFilial("SB0")+Substr(cChave,3,999)		// A filial de todos os registros serah do SB0.
	EndIf
	aSLH := {{"LH_FILIAL",  xFilial("SLH")},;
			 {"LH_ALIAS",   cAlias},;
			 {"LH_SITUA",   cSituacao},;
			 {"LH_CHAVE",   cChave},;
			 {"LH_DTALT",   dDataBase},;
			 {"LH_HRALT",   Time()},;
			 {"LH_USUARIO", cUsuerName}}
	If ! (lOk := ChkFile("SLH"))
		// "Aguarde... Atualizando o Log das Modifica��es!!!" ### "Aten��o"
		LJMsgRun(STR0003, STR0002, {|| lOk:=FR271BChkFile()})
	EndIf
	If lOk
		If lGravaFi
			For i := 1 To Len(aFiliais)
				aSLH[1][2] := aFiliais[i]
				aSLH[4][2] := aFiliais[i]+Substr(aSLH[4][2],3)
				FR271BGeraSL("SLH", aSLH, .T.)
			Next
		Else
			FR271BGeraSL("SLH", aSLH, .T.)
		EndIf
	Else
		// "O Arquivo de Log das Modifica��es (SLH) n�o pode ser atualizado. "
		// "As informa��es alteradas N�O estar�o dispon�veis na pr�xima Carga nas Esta��es." ### "Aten��o"
		MsgStop(STR0004+STR0005, STR0002)
	EndIf
	dbSelectArea(cOldAlias)
EndIf
Return(NIL)
    
Static Function FR271BChkFile
Local i, lOk
For i := 1 To 10
	If (lOk := ChkFile("SLH"))
		Return(.T.)
	EndIf
	Sleep(1000)
Next
Return(lOk)

Static Function FR271BUsaSLH
Local nHandle, lRet:=.F., cMV_DIRCFRT
cMV_DIRCFRT := GetMV("MV_DIRCFRT")
nHandle := FCreate(cMV_DIRCFRT+"TEMP.TMP")
If nHandle != -1
	lRet := .T.
	FClose(nHandle)
	FErase(cMV_DIRCFRT+"TEMP.TMP")
EndIf
Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FR271BPegaIT� Autor� Cesar Eduardo Valadao � Data�07/08/2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Transforma o Numero Item Para 2 Bytes.                     ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT                                                    ���
��������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������Ĵ��
���Alteracao � Solange Zanardi                                            ���
���02/09/2003� Transf. do caracter recebido para maiusculo                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FR271BPegaIT(uItem)
Static aItems := {}
Local cI		:= 0
Local i		:= 0
Local j 		:= 0
Local aTemp	:= {}
Local nTamSL2	:= 0
Local nLimite	:= 0
Local lMvSomaOld	:= SuperGetMv("MV_SOMAOLD",,.F.) //apos o 99� item ser� "A0" ou "9A"? Regra semelhante ao SOMA1()

// Se o campo for caracter transformar em maiusculo por seguran�a e tirar espa�o em braco
If ValType(uItem) == "C"
   uItem := AllTrim(uItem)
   uItem := upper(uItem)   
EndIf

If Len(aItems) == 0			//Monta o Array Somente uma Vez
	nTamSL2	:= TamSX3("L2_ITEM")[1]
	cI := Space(nTamSL2)
	cI := StrTran(cI," ","9")
	nLimite := Val(cI)
	
	aTemp := {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
	
	For i := Asc("A") To Asc("Z")
		AAdd(aTemp, Chr(i))
	Next
	
	For i := 1 To nLimite
		AAdd(aItems, StrZero(i,nTamSL2,0))
	Next
	
	If !lMvSomaOld ///quando falso -> "9A/9B/9C....."
		For i := Asc("A") To Asc("Z")
			AAdd(aItems, "9"+ Chr(i))
		Next
	EndIf

	For i := Asc("A") To Asc("Z")
		For j := 1 To Len(aTemp)
			AAdd(aItems, Chr(i)+aTemp[j])
		Next
	Next
EndIf

If ValType(uItem) == "N" 
	uRet := aItems[uItem]
ElseIf ValType(uItem) == "C"
	uRet := AScan(aItems, uItem)
EndIf

Return uRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FR271BCancela� Autor� Cesar Eduardo Valadao� Data�14/11/2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza o cancelamento do SL, SL2 e SL4                    ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FR271BCancela(lDeletaSL1, lDeletaSL2, lDeletaSL4)

Local lOk := .T. 
Local lTplAbaste := .F.		//Verifica se Cupom eh referente a abastecimento( TPL Posto )

Default lDeletaSL1 := .T.
Default lDeletaSL2 := .T.
Default lDeletaSL4 := .T.

//�������������������������������������������������������������������������Ŀ
//� Foi adicionado esta trava devido a um problema no cancelamento do cupom	�
//� quando � enviado o pacote de gravacao.									�
//� Quando esta sendo incluido uma venda, e assim que o pacote foi enviado,	�
//� nao tiver dado tempo para a gravacao na retaguarda, o cancelamento		�
//� nao e feito na retaguarda, causando problemas de sincronizacao de base.	�
//���������������������������������������������������������������������������
If lDeletaSL1 .AND. lDeletaSL2 .AND. lDeletaSL4
	DbSelectArea( "SL1" )

	If !RecLock( "SL1", .F. )
		lOk := .F.
		MsgStop( STR0009 ) //"N�o foi poss�vel cancelar o cupom pois est� sendo utilizado no momento. Tente novamente."

	EndIf
EndIf

If lOk    
	//���������������������������������������������������������������������������Ŀ
	//�TPL Posto(Requisito XXXV/Teste 90-A): Nao pode excluir Venda quando origem �
	//�for abastecimento, devendo constar em "Abastecimentos Pendentes"           �
	//�����������������������������������������������������������������������������
	If HasTemplate("PCL") 
		DbSelectArea("LEG")
		LEG->(DbSetOrder(2))                       
		lTplAbaste := LEG->(DbSeek(xFilial("LEG") + SL1->L1_NUM))		
	EndIf
	//�������������������������������Ŀ
	//�Cancela as formas de pagamento �
	//���������������������������������
	If lDeletaSL4
		dbSelectArea("SL4")
		SL4->(dbSetOrder(1))
		SL4->(dbSeek(xFilial("SL4")+SL1->L1_NUM))
		While (SL4->L4_FILIAL+SL4->L4_NUM == xFilial("SL4")+SL1->L1_NUM) .And. !SL4->(EOF())
			RecLock("SL4",.F.)
			SL4->(dbDelete())
			SL4->(MsUnlock())
			SL4->(dbSkip())
		End
	EndIf
	//�������������������Ŀ
	//� Cancelar os Itens �
	//���������������������
	If lDeletaSL2 .AND. !lTplAbaste
		dbSelectArea("SL2")
		SL2->(dbSetOrder(1))
		SL2->(dbSeek(xFilial("SL2")+SL1->L1_NUM))
		While (SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM) .And. !SL2->(EOF())
			RecLock("SL2", .F.)
			SL2->(dbDelete())
			SL2->(MsUnLock())
			SL2->(dbSkip())
		End
	EndIf
	//������������������Ŀ
	//� Cancelar o Cupom �
	//��������������������
	If lDeletaSL1

		If HasTemplate("DRO")
			T_DROCancANVISA()
		EndIf
	
		//Eh necessario excluir os registros de troco criados no PDV...
		If cPaisLoc <> "BRA" .And. SuperGetMV("MV_LJTRLOC",,.F.)
			dbSelectArea("SE5")
			SE5->(dbSetOrder(2))
			If SE5->(dbSeek(xFilial("SE5")+"VL"+SL1->L1_SERIE+SL1->L1_DOC))	    	
				While !SE5->(Eof()) .And. xFilial("SE5")+"VL"+SE5->E5_PREFIXO+SE5->E5_NUMERO == xFilial("SE5")+"VL"+SL1->L1_SERIE+SL1->L1_DOC
					If Empty(SE5->E5_TIPO) .And. SE5->E5_MOEDA == "TC" .And. SE5->E5_RECPAG == "P" .And.;
					   SE5->E5_CLIFOR == SL1->L1_CLIENTE .And. SE5->E5_LOJA == SL1->L1_LOJA
					   
						RecLock("SE5",.F.)
						SE5->(dbDelete())
						SE5->(MsUnLock())					
					EndIf
				    SE5->(dbSkip())
				End
			EndIf
		EndIf
		If !lTplAbaste
			dbSelectArea("SL1")
			If RecLock("SL1", .F.).And. !SL1->(EOF())
				SL1->(dbDelete())
				SL1->(MsUnLock())
			EndIf
		EndIf
		//�����������������������������������������������������Ŀ
		//�Atualiza SL1 para permitir nova finalizacao de venda �
		//�������������������������������������������������������
		If lTplAbaste
			RecLock("SL1", .F.)

			REPLACE SL1->L1_CONFVEN	WITH "SSSSSSSNSSSS"
			REPLACE SL1->L1_IMPRIME WITH "2N"
			REPLACE SL1->L1_COND    WITH 000
			REPLACE SL1->L1_OPERACA WITH "O"
			REPLACE SL1->L1_CONDPG  WITH "001"
			
			REPLACE SL1->L1_NUMCFIS	WITH ""
			REPLACE SL1->L1_DINHEIR	WITH 0
			REPLACE SL1->L1_OPERADO	WITH ""
			REPLACE SL1->L1_TIPO	WITH ""
			REPLACE SL1->L1_DOC		WITH ""
			REPLACE SL1->L1_SERIE	WITH ""
			REPLACE SL1->L1_PDV		WITH ""
			REPLACE SL1->L1_HORA	WITH ""
			REPLACE SL1->L1_SITUA	WITH ""
	
			SL1->(MsUnLock())
		EndIf
	EndIf
EndIf

Return( NIL )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FR271BChkModo� Autor� Cesar Eduardo Valadao� Data�17/11/2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a checagem das filiais do SB1 e SBI. Devido ao SBI ���
���          � uma compilacao dos campos necessarios ao FrontLoja, eh     ���
���          � preciso que os dois arquivos tenham a mesma filial.        ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FR271BChkModo
Local cModoSB1, cModoSBI, cModoSB0, cModoSLH

cModoSB1 := FWModeAccess("SB1",3)
cModoSBI := FWModeAccess("SBI",3)
cModoSB0 := FWModeAccess("SB0",3)
cModoSLH := FWModeAccess("SLH",3)
//����������������������������������������������������Ŀ
//� Modos de abertura compativeis:                     �
//� - SB0, SB1, SBI e SLH COMPARTILHADOS,              �
//� - SB0, SB1, SBI e SLH EXCLUSIVOS,                  �
//� - SB1 e SBI COMPARTILHADOS e SB0 e SLH EXCLUSIVOS. �
//������������������������������������������������������
If cModoSB1 != cModoSBI
	// "Modo de abertura incompat�vel" ### "� necess�rio que as tabelas SB1 e SBI tenham o mesmo modo de abertura."
	Aviso(STR0006, STR0001, {"Ok"})
EndIf
If cModoSB0 != cModoSLH
	// "Modo de abertura incompat�vel" ### "� necess�rio que as tabelas SB0 e SLH tenham o mesmo modo de abertura."
	Aviso(STR0006, STR0007, {"Ok"})
EndIf
If cModoSB1=="E" .And. cModoSB0=="C"
	// "Modo de abertura incompat�vel" ### "N�o � poss�vel utilizar o modo de abertura EXCLUSIVO para a tabela SB1/SBI e COMPARTILHADO para a tabela SB0."
	Aviso(STR0006, STR0008, {"Ok"})
EndIf
Return(NIL)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FR271BSema� Autor � Cesar Eduardo Valadao � Data �28/06/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria um Semaforo em Arquivo.                               ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FR271BSemaforo(cTipo, cEstacao, nHandle)
If __lFirst
	MakeDir("\SEMAFORO\SIGAFRT\")
	__lFirst := .T.
EndIf
nHandle := MSFCreate("\SEMAFORO\SIGAFRT\"+StrTran(cTipo+cFilAnt+cEstacao," ","")+".L"+StrTran(cEmpAnt," ",""))
           
IF nHandle < 0
	Return(.F.)
EndIf
FR271BGerSLI( cEstacao, "CON", "|||||", "SOBREPOE" )
Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FR271BStat� Autor � Cesar Eduardo Valadao � Data �28/06/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica o Status de um Semaforo em Arquivo.               ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FR271BStatSema(cTipo, cEstacao)
Local nHandle
If __lFirst
	MakeDir("\SEMAFORO\SIGAFRT\")
	__lFirst := .F.
EndIf
nHandle := MSFCreate("\SEMAFORO\SIGAFRT\"+StrTran(cTipo+cFilAnt+cEstacao," ","")+".L"+StrTran(cEmpAnt," ",""))
IF nHandle < 0
	Return(.T.)
Endif        
FClose(nHandle)
Return(.F.)           

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FR271BBSLD� Autor � Mauro Sano            � Data �18/08/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Recebe o conteudo da tabela SLD                            ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT - Touch Screen                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FR271BBSLD()
Local aFormas	:= {}		// Retorna o array com as formas e Condicoes de pagamento da SLD

DbSelectArea( "SLD" ) 
DbSetOrder(1) //dolis
dbGotop()
While !EOF()
	aAdd( aFormas,{ Alltrim( SLD->LD_CODIGO), Alltrim( SLD->LD_TEXTO ), Alltrim( SLD->LD_FORMA ),Alltrim(SLD->LD_COND) } )    
	DbSkip()
End

Return( aFormas )  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FR271BBGrp� Autor � Mauro Vajman          � Data �07/11/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta a estrutura de classe de botoes (btnGroup e btnItem) ���
���          � com base no cadastro (SL7 e SL8)                           ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT - Touch Screen                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FR271BBGrp( oGroup )

	Local aArea := GetArea()

	Local cGroup
	Local oNewItem
	Local oNewGroup
	Local nLastRec

	/*
	Se o objeto oGroup for nil significa que a rotina est� sendo executada
	pela primeira vez (trata-se do grupo principal). O objeto grupo � criado
	com os dados do grupo principal
	*/
	If oGroup == nil
		cGroup := SuperGetMv( "MV_LJGRPPR", .T., "" )
		dbSelectArea( "SL7" )
		dbSeek( xFilial("SL7") + cGroup )
		oGroup := btnGroup():New( SL7->L7_CODIGO, SL7->L7_DESCRI )
	EndIf

	dbSelectArea( "SL8" )
	
	If dbSeek( xFilial("SL8") + oGroup:GetCode() )
	
		//Loop para localizar e armazenar todos os itens e sub-grupos do grupo em quest�o
		While ( !SL8->( EOF() ) ) .AND. ( SL8->L8_CODIGO == oGroup:GetCode() )

			//Se o campo L8_CODPROD contiver dados significa que trata-se de um bot�o de produto
			If !Empty( SL8->L8_CODPROD )
				oNewItem := btnItem():New( SL8->L8_CODPROD, &( LjMacroBotao( SL8->L8_TEXTO ) ), nil )
				If !Empty( SL8->L8_CORBTN )
					oNewItem:SetBackColor( Val( SL8->L8_CORBTN ) )
				EndIf
				If !Empty( SL8->L8_CORFNT )
					oNewItem:SetForeColor( Val( SL8->L8_CORFNT ) )
				EndIf
				oGroup:Add( "I", oNewItem )
			//caso contr�rio trata-se de um sub-grupo
			Else
				//Verifica se o grupo est� ativo
				dbSelectArea( "SL7" )
				If dbSeek( xFilial( "SL7" ) + SL8->L8_CODGRP )
					If SL7->L7_ATIVO == "1"
						//Instancia um novo objeto grupo 
						oNewGroup := btnGroup():New( SL8->L8_CODGRP, &( LjMacroBotao( SL8->L8_TEXTO ) ) )
						If !Empty( SL8->L8_CORBTN )
							oNewGroup:SetBackColor( Val( SL8->L8_CORBTN ) )
						EndIf
						If !Empty( SL8->L8_CORFNT )
							oNewGroup:SetForeColor( Val( SL8->L8_CORFNT ) )
						EndIf                                                                                 1
						
						//Adiciona o sub-grupo criado ao grupo atual
						nLastRec := SL8->( Recno() )
						//Executa a fun��o recursivamente para a cria��o do sub-grupo
						FR271BBGrp( @oNewGroup )
						// Volta ao registro no qual estava posicionado antes da recursividade
						oGroup:Add( "G", oNewGroup )
						//"Guarda" o registro atual para retornar ao sair da recursividade
						SL8->( dbGoto( nLastRec ) )
					EndIf
				EndIf
				dbSelectArea( "SL8" )
			EndIf

			dbSkip()
		End
	EndIf
	
	RestArea( aArea )

Return( nil )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FR271BVlGP� Autor � Mauro Sano            � Data �18/10/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se existe o conteudo de MV_LJGRPPR e valida se seu  ���
���          � conteudo existe no SL7.                                    ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT - Touch Screen                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FR271BVlGP( lExibe )
Local lRet 		:= .F.										// Retorno da funcao
Local cMv_LjGrp	:= SuperGetMv( "MV_LJGRPPR", .T., "" )		// Conteudo do MV_LJGRPPR
Default lExibe := .F.
            
If !Empty( cMv_LjGrp )
	DbSelectArea( "SL7" )
	If DbSeek( xFilial( "SL7" ) + AllTrim( cMv_LjGrp )  )
		lRet := .T.
	Else             
		If lExibe
			MsgStop( STR0010 )	
		Endif	
	Endif
Else 
	If lExibe
		MsgStop( STR0011 )
	Endif	
Endif			

Return( lRet )			
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FR271BSITUA� Autor � Vendas e CRM         � Data �18/10/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava a situacao em que a venda se encontra                ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FR271BSitua( cSitua )		

Local aSL1
//���������������������������������Ŀ
//� L1_SITUA						�
//� 00 - Venda Efetuada com Sucesso	�
//� 10 - Encerrado a Venda 			�
//� 11 - Nao imprimiu o TEF			�
//�����������������������������������
DEFAULT cSitua := ""  

aSL1 := {{"L1_SITUA", cSitua }}	

FR271BGeraSL("SL1", aSL1, .F.)

Return(Nil)
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �FR271BOnOfBmp�Autor  �Vendas Clientes     � Data �  12/06/08   ���
����������������������������������������������������������������������������͹��
���Desc.     �Verifica se o Server esta conectado ou nao usando a		     ���
���          � criacao do arquivo conexao.ini criado na pasta system         ���
����������������������������������������������������������������������������͹��
���Uso       � FRTA271H - Funcao FRTA271HTIMER                               ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function FR271BOnOfBmp(cEstacao)

Local lRet  := .T.  //variavel para passar o retorno da funcao

If file("conexao.frt")
	lRet  := .T.
Else
	lRet  := .F.
EndIf
Return (lRet)
