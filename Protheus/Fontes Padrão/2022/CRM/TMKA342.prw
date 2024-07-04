#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA342.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMKA342   �Autor  �Vendas Clientes     � Data �  23/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Qualificar o suspect. Gerando um prospect caso este seja    ���
���          �qualificado.                                                ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codigo do suspect a ser qualificado                 ���
���          �ExpC2 - Loja do suspect a ser qualificado                   ���
���          �ExpO3 - Objeto da tela do cadastro de suspect               ���
���          �ExpN4 - Opcao do retorno da tela, caso se confirme a tela   ���
���          �ExpC5 - Codigo do vendedor associado ao suspect             ���
�������������������������������������������������������������������������͹��
���Uso       �SIGATMK                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TMKA342(	cCodigo	, cLoja	, oDlgSusp	, nOpcA	,;
					cGetVend)

Local aArea	   		:= GetArea()					// Salva posicionamento atual
Local aAreaSA1		:= SA1->(GetArea())			// Armazena area do SA1
Local aAreaSUS		:= SUS->(GetArea())			// Armazena area do ACH
Local aAreaPE		:= {}							// Armazena posicionamento antes de executar o PE
Local aCmbMot  		:= {{},{}}						// Array com motivos de desqualificacao
Local cCmbMot		:= ""							// Motivo selecionado para desqualificacao
Local cGetObs		:= ""							// Texto descritivo da desqualificacao
Local cGetNomeV		:= ""							// Nome do vendedor
Local cConcorr		:= ""							// Concorrente associado a desqualificacao
Local lGeraOp  		:= .T.							// Flag que identifica a geracao de oportunidade
Local lOk			:= .F.							// Identifica se o usuario confirmou a tela
Local nStatus  		:= 1							// Item selecionado no objeto radio
Local nX			:= 0							// Auxiliar de loop ou busca
Local aRadioOp		:= {STR0001,STR0002}			// Opcoes da qualificacao (qualificado ou desqualificado)
Local lTk342Ini		:= ExistBlock("TK342INI")		// Indicador de existencia do ponto de entrada TK342INI
Local lTk342Fim		:= ExistBlock("TK342FIM")		// Indicador de existencia do ponto de entrada TK342FIM
Local nTamACH_OBS	:= TamSx3("ACH_OBS")[1]			// Tamanho do campo ACH_OBS
Local lGravou		:= .F.							// Indica se a gravacao do prospect ocorreu normalmente
Local oConcorr										// Objeto do textbox do concorrente
Local oGeraOp										// Objeto da checkbox de geracao de oportunidade
Local oGetObs										// Objeto do textbox multiline de observacao
Local oGetVend										// Objeto do textbox do codigo do vendedor
Local oGetNomeV										// Objeto do textbox do nome do vendedor
Local oRdStatus 									// Objeto radio de selecao da qualificacao
Local oGrpPrinc										// Objeto do groupbox principal
Local oGrpDesq										// Objeto do groupbox de qualificacao
Local oGrpQual										// Objeto do groupbox de desqualificacao
Local oCmbMot  										// Objeto do combo de motivos
Local oSayMot  										// Objeto do label Motivo
Local oSayCon										// Objeto do label Concorrente
Local oSayObs										// Objeto do label Observacao
Local oSayVend										// Objeto do Vendedor
Local oDlg											// Objeto da tela de qualificacao
Local lRet			:= .T.							// Retorno do ponto de entrada 
Local lContinua		:= .T.							// Indica se a qualificacao pode prosseguir
Local cCGC			:= ""							// CPF/CNPJ do suspect 
Local lRodizio		:= .F.							// Executa rodizio para selecao de vendedor
Local aPDFields		:= {"A1_NOME","US_NOME","A3_NOME"}

// Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)

If Funname()<>"TMKA341"
   cGetVend:=Space(TamSx3("A3_COD")[1]) 			// Codigo do vendedor da oportunidade
Endif

//������������������������������������������������������������Ŀ
//�Verifica se o rodizio sera executado - Somente para base TOP�
//��������������������������������������������������������������
#IFDEF TOP
	If FindFunction("FATA570") .AND. SX2->(DbSeek("ADI"))
		lRodizio	:= SuperGetMv("MV_TMKRODZ",,.F.)
	EndIf
#ENDIF

//������������������������������������������������������������Ŀ
//�Verifica se a rotina pode ser executada, devido a existencia�
//�dos novos campos na tabela ACH                              �
//��������������������������������������������������������������
If 	(ACH->(FieldPos("ACH_MIDIA" )) == 0) .OR.;
	(ACH->(FieldPos("ACH_CONCOR")) == 0) .OR.;
	(ACH->(FieldPos("ACH_MOTIVO")) == 0) .OR.;
	(ACH->(FieldPos("ACH_CONCOR")) == 0) .OR.;
	(ACH->(FieldPos("ACH_OBS"   )) == 0)

	MsgInfo(STR0016,STR0015)//"Para utilizar a funcionalidade de qualifica��o, � necess�rio que o Administrador do sistema execute a rotina U_TMKUPDACH."###"Aten��o"
	Return .F.

End
                                    
cConcorr := ACH->ACH_CONCOR
//��������������������������������������Ŀ
//�Ponto de entrada antes da qualificacao�
//����������������������������������������
If lTk342Ini
	
	aAreaPE	:= GetArea()
	lRet := U_TK342INI(@cGetVend)
	
	If ValType(lRet) == "L" .AND. !lRet
		RestArea(aAreaPE)
		Return .F.
	EndIf
	                
	If !Empty(cGetVend)
		cGetNomeV	:= Capital(Posicione("SA3",1,xFilial("SA3")+cGetVend,"A3_NOME"))
	EndIf
	
	RestArea(aAreaPE)
	
EndIf

//���������������������������������������������������������Ŀ
//�Se for executar o rodizio, ignora o vendedor selecionado �
//�no ponto de entrada                                      �
//�����������������������������������������������������������
If lRodizio
	cGetVend	:= ""
	cGetNomeV	:= STR0020 //"SELECAO AUTOMATICA"
EndIf

//�������������������������������������������Ŀ
//�Nao permite qualificar um suspect nao salvo�
//���������������������������������������������
If INCLUI
	MsgInfo(STR0003 + CRLF +;//"A qualifica��o n�o pode ser realizada para um suspect ainda n�o gravado."
			STR0004,STR0005)//"Finalize a inclus�o e acesse novamente esta op��o, em modo de altera��o."###"Salve o registro"
	Return .F.
EndIf

//��������������������������������������������������������������Ŀ
//�Verifica se ja existe uma entidade (prospect ou cliente) com o�
//�CNPJ/CPF do suspect atual, nao permitindo a duplicidade de    �
//�informacoes                                                   �
//����������������������������������������������������������������
cCGC	:= AllTrim(M->ACH_CGC)
cCGC	:= StrTran(cCGC,".","")
cCGC	:= StrTran(cCGC,"-","")
cCGC	:= StrTran(cCGC,"/","")

DbSelectArea("SA1")
DbSetOrder(3) //A1_FILIAL+A1_CGC

If !(lContinua := !DbSeek(xFilial("SA1")+cCGC)) 
	
	FATPDLogUser('TMKA342')	// Log de Acesso LGPD
	MsgInfo(STR0019 + CRLF +; //"O suspect n�o poder� ser qualificado pois j� existe um cliente com o mesmo CPF/CNPJ do suspect atual:"
		SA1->A1_COD + " - " + AllTrim(Capital(FATPDObfuscate(SA1->A1_NOME,"A1_NOME")))  )
EndIf

If lContinua 
	DbSelectArea("SUS")
	DbSetOrder(4) //US_FILIAL+US_CGC
	If !(lContinua := !DbSeek(xFilial("SUS")+cCGC)) 
		
		FATPDLogUser('TMKA342')	// Log de Acesso LGPD
		MsgInfo(STR0019 + CRLF +; //"O suspect n�o poder� ser qualificado pois j� existe um cliente com o mesmo CPF/CNPJ do suspect atual:"
			SUS->US_COD + " - " + AllTrim(Capital(FATPDObfuscate(SUS->US_NOME,"US_NOME"))) )
	EndIf
EndIf

If !lContinua 
	RestArea(aAreaSA1)
	RestArea(aAreaSUS)
	RestArea(aArea)
	Return .F.
EndIf

//������������������������������������������������������������������Ŀ
//�Se o suspect estiver com o status 'desqualificado' inicia o objeto�
//�radio posicionado na opcao de desqualificacao                     �
//��������������������������������������������������������������������
If M->ACH_STATUS == '5'
	nStatus := 2
EndIf

//���������������������Ŀ
//�Recupera memo gravado�
//�����������������������
cGetObs		:= AllTrim(StrTran(ACH->ACH_OBS,'\0',CRLF))

//���������������������������������������Ŀ
//�Le a lista de opcoes de desqualificacao�
//�����������������������������������������
SX5->(DbSetOrder(1))
SX5->(DbSeek( xFilial("SX5") + "A6" ))

While !SX5->(Eof()) 					.AND.;
	SX5->X5_FILIAL == xFilial("SX5")	.AND.;
	SX5->X5_TABELA == "A6"
	Aadd(aCmbMot[1],SX5->X5_CHAVE)
	Aadd(aCmbMot[2],Capital(AllTrim(SX5->X5_DESCRI)))
	SX5->(DbSkip())
End 

//�����������������������������Ŀ
//�Localiza o motivo selecionado�
//�������������������������������
If !Empty(ACH->ACH_MOTIVO)
	If (nX	:= aScan(aCmbMot[1],{|x|AllTrim(x) == AllTrim(ACH->ACH_MOTIVO)})) > 0
		cCmbMot	:= aCmbMot[2][nX]
	EndIf
EndIf

DEFINE MSDIALOG oDlg TITLE STR0006 FROM C(0),C(0) TO C(289),C(355) PIXEL STYLE DS_MODALFRAME STATUS //"Qualifica��o"

	//Labels da interface
	@ C(001),C(002) Group oGrpPrinc TO C(033),C(144) LABEL STR0006 PIXEL OF oDlg //"Qualifica��o"
	@ C(037),C(002) Group oGrpDesq  TO C(105),C(178) LABEL STR0007 PIXEL OF oDlg //"Motivo da Desqualifica��o:"
	@ C(037),C(002) Group oGrpQual  TO C(075),C(178) LABEL STR0008 PIXEL OF oDlg //"Op��es:"
	
	//Says da interface
	@ C(048),C(008) Say oSayMot  Prompt STR0009		SIZE C(44),C(8) PIXEL OF oDlg	//"Motivo:"
	@ C(061),C(008) Say oSayCon  Prompt STR0010		SIZE C(44),C(8) PIXEL OF oDlg	//"Concorrente:"
	@ C(061),C(008) Say oSayObs  Prompt STR0011		SIZE C(44),C(8) PIXEL OF oDlg	//"Observa��o:"
	@ C(057),C(017) Say oSayVend Prompt STR0018		SIZE C(44),C(8) PIXEL OF oDlg	//"Vendedor:"
	
    //Radio de selecao do status (qualificado ou desqualificado)
	@ C(011),C(006) Radio oRdStatus Var nStatus Items aRadioOp[1],aRadioOp[2] 3D Size C(122),C(011) PIXEL OF oDlg;
		ON CHANGE Tk342Det(	nStatus		, cCmbMot	, @oDlg		, @oGrpDesq	,;
							@oGrpQual	, @oGeraOp	, @oCmbMot	, @oGetObs 	,;
							@oConcorr	, @oSayMot	, @oSayCon	, @oSayObs	,;
							@oGetVend	, @oSayVend	, @oGetNomeV)

	//Check box para geracao de oportunidade	
	@ C(044),C(014) CheckBox oGeraOp Var lGeraOp Prompt STR0012 Size C(128),C(009) PIXEL OF oDlg;//"Gerar oportunidade"
		ON CLICK (IIf(lGeraOp,;
			(oSayVend:Enable(),oGetVend:Enable(),oGetNomeV:Enable()),;
			(oSayVend:Disable(),oGetVend:Disable(),oGetNomeV:Disable())))
	
	//Get para codigo do vendedor da oportunidade:
	@ C(056),C(039) MSGET oGetVend Var cGetVend Size C(033),C(009) F3 "SA3" Pixel of oDlg; 
	    Valid (Tk342Vend(nStatus,cGetVend,@oGetNomeV,@cGetNomeV) .AND. TK341RESV(cGetVend,M->ACH_RESERV) ); 
	    When !lRodizio
		
	@ C(056),C(078) MSGET oGetNomeV Var cGetNomeV Size C(089),C(009) When .F. COLOR CLR_BLACK Pixel of oDlg
	If FATPDActive() .And. FTPDUse(.T.)
		oGetNomeV:lObfuscate := FATPDIsObfuscate("A3_NOME")
	Endif
	//Combo para justificar a desqualificacao
	@ C(048),C(044) ComboBox oCmbMot Var cCmbMot Items aCmbMot[2] Size C(122),C(011) PIXEL OF oDlg;
		ON CHANGE Tk342Det(	nStatus		, cCmbMot	, @oDlg		, @oGrpDesq	,;
							@oGrpQual	, @oGeraOp	, @oCmbMot	, @oGetObs 	,;
							@oConcorr	, @oSayMot	, @oSayCon	, @oSayObs	,;
							@oGetVend	, @oSayVend	, @oGetNomeV)
    
	//Codigo do concorrente
	@ C(061),C(044) MSGET oConcorr Var cConcorr Size C(122),C(009) F3 "AC3" Pixel of oDlg;
		Valid ((nStatus == 2) .AND. (Empty(cConcorr) .OR. ExistCpo("AC3",cConcorr)))
	
	//Texto livre para justificar a desqualificacao
	@ C(061),C(044) GET oGetObs VAR cGetObs OF oDlg MULTILINE SIZE C(122), C(039) PIXEL
	

	DEFINE SBUTTON FROM C(006),C(150) TYPE 1 ENABLE OF oDlg;
		ACTION( Iif(Tk342TOk(	nStatus	, cCmbMot	, cConcorr	, lGeraOp	,;
								cGetVend, lRodizio	),;
		(lOk := .T., oDlg:End()),.F.) )
	
	DEFINE SBUTTON FROM C(019),C(150) TYPE 2 ENABLE OF oDlg ACTION( oDlg:End() )
                     
	//��������������������������������������������������������Ŀ
	//�Define propriedades e aciona metodos dos objetos da tela�
	//����������������������������������������������������������
	oGetObs:bvalid:= {||If(Len(cGetObs)>nTamACH_OBS,MsgInfo(STR0013),.T.)} //"Voc� excedeu o tamanho m�ximo do texto"
	oGetObs:Hide()
	oGrpDesq:Hide()
	oCmbMot:Hide()
	oConcorr:Hide() 
	oSayMot:Hide()
	oSayCon:Hide()
	oSayObs:Hide()
	oDlg:Move(oDlg:nTop,oDlg:nLeft,C(366),C(155))	
	oDlg:lEscClose := .F.
	
	//���������������������������������������������������������Ŀ
	//�Ajusta a propriedade dos objetos relacionados ao vendedor�
	//�����������������������������������������������������������
	If lGeraOp
		oSayVend:Enable()
		oGetVend:Enable()
		oGetNomeV:Enable()
	Else
		oSayVend:Disable()
		oGetVend:Disable()
		oGetNomeV:Disable()
	EndIf

	//����������������������������������������������������������Ŀ
	//�Ajusta o tamanho da tela de acordo com a opcao previamente�
	//�selecionada                                               �
	//������������������������������������������������������������
	Tk342Det(	nStatus		, cCmbMot	, @oDlg		, @oGrpDesq	,;
				@oGrpQual	, @oGeraOp	, @oCmbMot	, @oGetObs 	,;
				@oConcorr	, @oSayMot	, @oSayCon	, @oSayObs	,;
				@oGetVend	, @oSayVend	, @oGetNomeV)

FATPDLogUser('TMKA342')	// Log de Acesso LGPD

ACTIVATE MSDIALOG oDlg CENTERED 

If lOk // Se o usuario confirmou a tela
	
	//�������������������������������������������������������Ŀ
	//�Transforma o suspect em prospect ou grava os motivos da�
	//�desqualificacao                                        �
	//���������������������������������������������������������
	lGravou	:= Tk342Grava(	nStatus	, cCodigo	, cLoja		, cGetObs	,;
			   				cConcorr, cCmbMot	, aCmbMot	, lGeraOp	,;
			   				cGetVend, lRodizio	)

	//������������������������������������Ŀ
	//�Confirma e encerra a tela de suspect�
	//��������������������������������������	
	nOpcA := 1
	
	If Type("oDlgSusp") <> "U"
		oDlgSusp:End()
	EndIf
	
	//������������������������������������������������Ŀ
	//�Ponto de entrada apos a gravacao da qualificacao�
	//��������������������������������������������������
	If lGravou .AND. lTk342Fim
		aAreaPE	:= GetArea()
		U_TK342FIM((nStatus == 1),lGeraOp,cGetVend) 
		RestArea(aAreaPE)
	EndIf
	
EndIf

//Finaliza o gerenciamento dos campos com prote��o de dados.
FATPDUnLoad() 
RestArea(aArea)

Return(nStatus == 1)

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa   �   C()   � Autores � Norbert/Ernani/Mansano � Data �10/05/2005���
����������������������������������������������������������������������������Ĵ��
���Descricao  � Funcao responsavel por manter o Layout independente da       ���
���           � resolucao horizontal do Monitor do Usuario.                  ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function C(nTam)

Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor

If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf

//���������������������������Ŀ
//�Tratamento para tema "Flat"�
//�����������������������������
If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
	nTam *= 0.90
EndIf

Return Int(nTam)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk342Det  �Autor  �Vendas Clientes     � Data �  23/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Redimensiona a tela a partir da selecao do status do suspect���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SIGATMK                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Tk342Det(	nStatus	, cCmbMot	, oDlg		, oGrpDesq	,;
							oGrpQual, oGeraOp	, oCmbMot	, oGetObs	,;
							oConcorr, oSayMot	, oSayCon	, oSayObs	,;
							oGetVend, oSayVend	, oGetNomeV	)

Local nTop		:= 0		// Coordenada de tela do topo da janela

oDlg:CoorsUpdate()
nTop := oDlg:nTop

//����������������������������������������Ŀ
//�Correcao de coordenada para tema nao-MDI�
//������������������������������������������
If !((Alltrim(GetTheme()) == "FLAT").Or. (SetMdiChild()))
	nTop+=C(-1)
EndIf

//��������������������������������������������������Ŀ
//�Esconde ou mostra os objetos de acordo com a opcao�
//�selecionada pelo usuario                          �
//����������������������������������������������������
If nStatus == 1	//Qualificado

	//Redimensiona a tela
	oDlg:Move(nTop,oDlg:nLeft,C(366),C(175))
                   
	//Oculta objetos da desqualificacao
	oGrpDesq:Hide()
	oCmbMot:Hide()
	oGetObs:Hide()
	oConcorr:Hide() 
	oSayMot:Hide()
	oSayCon:Hide()
	oSayObs:Hide()

	//Exibe objetos da qualificacao
	oGrpQual:Show()
	oGeraOp:Show()
	oGetVend:Show()
	oSayVend:Show()
	oGetNomeV:Show()

Else //Desqualificado

	//Oculta objetos especificos da qualificaco
	oGrpQual:Hide()
	oGeraOp:Hide()
	oGetVend:Hide()
	oSayVend:Hide()
	oGetNomeV:Hide()

	If ("CONCORR" $ Upper(cCmbMot)) .OR. ("COMPET" $ Upper(cCmbMot)) //Concorrente
		
		//Redimensiona a tela
		oDlg:Move(nTop,oDlg:nLeft,C(366),C(278)) 
		
		//Atualiza coordenadas
		oGetObs:nTop		:= C(150)
		oSayObs:nTop		:= C(150)
		oGrpDesq:nBottom	:= C(244)
		
		//Exibe label e campo de concorrente		
		oConcorr:Show()
		oSayCon:Show()
		
		oConcorr:SetFocus()

	Else //Outros motivos
	
		oDlg:Move(nTop,oDlg:nLeft,C(366),C(250))
		
		//Atualiza coordenadas
		oGrpDesq:nBottom := c(222)	
		oGetObs:nTop	:= c(122)
		oSayObs:nTop	:= c(122)
		
		//Oculta label e campo de concorrente
		oConcorr:Hide()
		oSayCon:Hide()

	EndIf
	
	//Exibe objetos da desqualificacao
	oSayMot:Show()
	oSayObs:Show()
	oGrpDesq:Show()
	oCmbMot:Show()
	oGetObs:Show()

Endif

oDlg:Refresh()

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk342Grava�Autor  �Vendas Clientes     � Data �  23/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Geracao do prospect a partir do suspect, atualizacao das in-���
���          �formacoes da tela.                                          ���
�������������������������������������������������������������������������͹��
���Uso       �SIGATMK                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Tk342Grava(	nStatus	, cCodigo	, cLoja		, cGetObs	,;
							cConcorr, cCmbMot	, aCmbMot	, lGeraOp	,;
							cGetVend, lRodizio	)
          
Local lQualif		:= (nStatus == 1)			   			// Indica se o suspect foi qualificado
Local nPos			:= 0						   			// Auxiliar de pesquisa em vetores
Local aCab			:= {}									// Vetor da MsExecAuto
Local lTk342Opr		:= ExistBlock("TK342OPR")				// Ponto de entrada na execucao da MsExecAuto
Local lRet			:= .F.						   			// Retorno da gravacao, .T. se tudo ocorrer OK
Local cProcVOp		:= SuperGetMV( "MV_TMKPROC",,"000001")	// Processo de vendas utilizado na oportunidade
Local cEstagOp		:= SuperGetMV( "MV_TMKESTA",,"000001")	// Estagio do processo de vendas utilizado na oportunidade
Local nLenSX8		:= GetSX8Len()				  			// Quantidade de reservas de numeros do SXE/SXF
Local lTk342Grv		:= ExistBlock("TK342Grv")				// P.E. ao termino da gravacao da qualificacao
Local cTabPreco		:= SuperGetMV( "MV_FTTABPR",,"")		// Tabela de preco da oportunidade
Local cNumOport		:= ""									// Numero da Oportunidade

// SLA
Local oSLARegister 											// Objeto de registro de SLA
Local oEntity												// Objeto de entidades
Local entities		:= {}									// Array com as entidades
Local severityCode 	:= SuperGetMV( "MV_TMKSEV",,100)		// Codigo da severidade (prospect com reserva)
Local codRespons	:= "000001"								// Codigo do responsavel        
// SLA

Private lMsErroAuto	:= .F.

If lQualif //Qualificado
	
	If lRodizio 
		cGetVend := Fata570(cCodigo)
	EndIf
	
	//��������������������������������Ŀ
	//�Transforma o suspect em prospect�
	//����������������������������������
	If Tk341GrvSTP(cCodigo,cLoja,.T.,cGetVend)
		
		ACH->(DbSeek( xFilial("ACH") + cCodigo + cLoja ))
	
		//������������������������������������������Ŀ
		//�Altera o status do suspect para 'prospect'�
		//��������������������������������������������
		M->ACH_STATUS := '6'
		M->ACH_CODPRO := ACH->ACH_CODPRO
		M->ACH_LOJPRO := ACH->ACH_LOJPRO 
		M->ACH_DESPRO := Posicione("SUS",1,xFilial("ACH")+M->(ACH_CODPRO+ACH_LOJPRO),"US_NOME")
		M->ACH_DTCONV := ACH->ACH_DTCONV
		
		lRet := .T.
		        
		//�����������������������Ŀ
		//�Geracao da oportunidade�
		//�������������������������
		If lGeraOp 
		
			AAdd(aCab,{"AD1_DESCRI"	, PadR(ACH->ACH_RAZAO,TAMSX3("AD1_DESCRI")[1])			, Nil	})
			AAdd(aCab,{"AD1_VEND"	, cGetVend						, Nil	})
			AAdd(aCab,{"AD1_DTINI"	, dDataBase						, Nil	})
			AAdd(aCab,{"AD1_DTFIM"	, dDataBase						, Nil	})
			AAdd(aCab,{"AD1_PROSPE"	, ACH->ACH_CODPRO				, Nil	})
			AAdd(aCab,{"AD1_LOJPRO"	, ACH->ACH_LOJPRO 				, Nil	})
			AAdd(aCab,{"AD1_PROVEN"	, cProcVOp						, Nil	})
			AAdd(aCab,{"AD1_STAGE"	, cEstagOp						, Nil	})
			AAdd(aCab,{"AD1_MOEDA"	, 1								, Nil	})
			AAdd(aCab,{"AD1_PRIOR"	, "3"							, Nil	})
			
			//Preenche a tabela de preco
			If AD1->(FieldPos("AD1_TABELA")) > 0 .AND. !Empty(cTabPreco)
				AAdd(aCab,{"AD1_TABELA"	, cTabPreco					, Nil	})
			EndIF

			//������������������������������������������������������Ŀ
			//�Ponto de entrada para utilizacao de campos especificos�
			//��������������������������������������������������������
			If lTk342Opr
				U_TK342OPR(@aCab)
			EndIf
			
			If ACH->( FieldPos( "ACH_RESERV" )) > 0
				If ACH->ACH_RESERV == "1"
					ExecCRMPro("000002")			//PROCESSO # "Suspect qualificado com oportunidade e reserva"
				EndIf
			Endif
		Else
			//������������������������������������Ŀ
			//�Suspect Qualificado sem oportunidade�
			//��������������������������������������
			ExecCRMPro("000003")					//PROCESSO # "Suspect Qualificado sem oportunidade"
		EndIf

		//������������������������Ŀ
		//�Gravacao da oportunidade�
		//��������������������������
		Begin Transaction
		
		If lGeraOp
			MSExecAuto({|x,y|FATA300(x,y)},3,aCab) 
			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
				lRet := .F.
			Else
				cNumOport	:= AD1->AD1_NROPOR
				lRet := .T.
			EndIf
		EndIf

		//����������������������������������������������������������Ŀ
		//�Se antes de ser qualificado o suspect foi desqualificado, �
		//�remove os dados da desqualificacao                        �
		//������������������������������������������������������������		
		If !lMsErroAuto
			RecLock("ACH",.F.)
			Replace ACH->ACH_OBS	With ""
			Replace ACH->ACH_CONCOR	With ""
			Replace ACH->ACH_MOTIVO	With ""
			MsUnLock()
		EndIf
		
		End Transaction

	EndIf

Else

	//���������������������������������������Ŀ
	//�Localiza o codigo do motivo selecionado�
	//�����������������������������������������
	nPos	:= aScan(aCmbMot[2],{|x|AllTrim(x) == AllTrim(cCmbMot)})
	
	//������������������������������������������������Ŀ
	//� Alterar o status do suspect para desqualificado�
	//��������������������������������������������������
	M->ACH_STATUS 	:= '5'
	M->ACH_OBS		:= StrTran(StrTran(AllTrim(cGetObs),Chr(13),'\0'),Chr(10),'')
	M->ACH_CONCOR	:= cConcorr
 	M->ACH_MOTIVO	:= IIf(nPos > 0, aCmbMot[1][nPos], "" )
	
	Begin Transaction
	
	RecLock("ACH",.F.)
	Replace ACH->ACH_OBS	With M->ACH_OBS
	Replace ACH->ACH_CONCOR	With M->ACH_CONCOR
	Replace ACH->ACH_MOTIVO	With M->ACH_MOTIVO
	MsUnLock()    
	
	End Transaction

	lRet := .T.        
	
	//����������������������Ŀ
	//�Suspect Desqualificado�
	//������������������������
	ExecCRMPro("000001")						//PROCESSO # "Suspect Desqualificado"
	
EndIf
If lTk342Grv
	ExecBlock( "TK342Grv",.F.,.F.,{lQualif,cNumOport})
Endif
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk342TOk  �Autor  �Vendas Clientes     � Data �  10/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao da tela de qualificacao do suspect.               ���
�������������������������������������������������������������������������͹��
���Uso       �SIGATMK                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Tk342TOk(	nStatus	, cCmbMot	, cConcorr	, lGeraOp	,;
							cGetVend, lRodizio	)

Local lRet		:= .T.
Local lTk342VOK	:= ExistBlock("TK342VOK")				// P.E. para confirmar o vendedor escolhido na qualifica��o - botao ok
Local aArea		:= GetArea()							// Salva posicionamento atual
Local cProcVOp	:= SuperGetMV( "MV_TMKPROC",,"000001")	// Processo de vendas utilizado na oportunidade
Local cEstagOp	:= SuperGetMV( "MV_TMKESTA",,"000001")	// Estagio do processo de vendas utilizado na oportunidade

DbSelectArea("AC2")
DbSetOrder(1) //AC2_FILIAL+AC2_PROVEN+AC2_STAGE

If !DbSeek(xFilial("AC2")+cProcVOp+cEstagOp)
	MsgStop(STR0021) //"O processo ou est�gio de vendas configurado nos par�metros MV_TMKPROC e MV_TMKESTA n�o existe."
	lRet := .F.
EndIf

If lRet .AND. lTk342VOK
	lRet := ExecBlock( "TK342VOK",.F.,.F.,{cGetVend,lRodizio,lGeraOp})
	//�����������������������������Ŀ
	//�Valida se o retorno eh logico�
	//�������������������������������
	If ( ValType( lRet ) <> "L" )
		lRet := .F.
	Endif
Endif
	
//����������������������������������������������������������Ŀ
//�Desqualificado por concorrencia sem concorrente preenchido�
//������������������������������������������������������������
If lRet .AND. (nStatus == 2) .AND. (("CONCORR" $ Upper(cCmbMot)).OR.("COMPET" $ Upper(cCmbMot)));
	.AND. Empty(cConcorr) .AND. lRet
	lRet := .F.
	MsgInfo(STR0014) //"Preencha o c�digo do concorrente"
EndIf

If lRet .AND. (nStatus == 1) .AND. lGeraOp .AND. Empty(cGetVend) .AND. !lRodizio
	lRet := .F.
	MsgInfo(STR0017) //"Preencha o c�digo do vendedor"
EndIf

RestArea(aArea)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk342Vend �Autor  �Vendas Clientes     � Data �  12/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida o campo vendedor e atualiza o nome na tela.          ���
�������������������������������������������������������������������������͹��
���Uso       �SIGATMK                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Tk342Vend(nStatus,cGetVend,oGetNomeV,cGetNomeV)

Local lRet := ((nStatus == 1) .AND. (Empty(cGetVend) .OR. ExistCpo("SA3",cGetVend)))

If lRet .AND. !Empty(cGetVend)
	cGetNomeV	:= Capital(Posicione("SA3",1,xFilial("SA3")+cGetVend,"A3_NOME"))
	oGetNomeV:Refresh()
EndIf

Return lRet

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usu�rio utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que ser�o verificados.
    @param aFields, Array, Array com todos os Campos que ser�o verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com prote��o de dados.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta fun��o deve utilizada somente ap�s 
    a inicializa��o das variaveis atravez da fun��o FATPDLoad.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, L�gico, Retorna se o campo ser� ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informa��es enviadas, 
    quando a regra de auditoria de rotinas com campos sens�veis ou pessoais estiver habilitada
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que ser� utilizada no log das tabelas
    @param nOpc, Numerico, Op��o atribu�da a fun��o em execu��o - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria n�o esteja aplicada, tamb�m retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun��o que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
